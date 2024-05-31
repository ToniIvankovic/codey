using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Enumerations;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Identity;
using MongoDB.Bson;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBe.Services
{
    public class UserService(UserManager<ApplicationUser> userManager,
        ITokenGeneratorService tokenGenerator,
        ILessonsService lessonsService,
        IExercisesService exercisesService,
        ILogsService logsService,
        ILessonGroupsService lessonGroupsService) : IUserService
    {
        private readonly UserManager<ApplicationUser> _userManager = userManager;


        public async Task<JWTTokenDTO> LoginUser(UserLoginRequestDTO userDTO)
        {
            var user = await _userManager.FindByEmailAsync(userDTO.Email);
            if (user == null)
            {
                throw new EntityNotFoundException();
            }
            var result = await _userManager.CheckPasswordAsync(user, userDTO.Password);
            if (!result)
            {
                throw new UserAuthenticationException(UserAuthenticationException.INVALID_PASSWORD);
            }
            var claims = await _userManager.GetClaimsAsync(user);
            user.Roles.ForEach(role => claims.Add(new Claim(ClaimTypes.Role, role)));
            return tokenGenerator.GenerateToken(claims);
        }

        public async Task<IdentityResult> RegisterStudent(UserRegistrationRequestDTO user)
        {
            var userCount = _userManager.Users.Count();
            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
                FirstName = user.FirstName,
                LastName = user.LastName,
                DateOfBirth = user.DateOfBirth,
                UserName = user.Email,
                Email = user.Email,
                Roles = ["STUDENT"],
                Claims = [
                    new()
                    {
                        ClaimType = ClaimTypes.Email,
                        ClaimValue = user.Email
                    },
                ],
                HighestLessonGroupId = null,
                HighestLessonId = null,
                NextLessonGroupId = lessonGroupsService.FirstLessonGroupId,
                NextLessonId = lessonsService.FirstLessonId,
                TotalXP = 0,
                XPachieved = [],
                School = user.School,
                GamificationGroup = user.School == "Ostali" ? 0 : userCount % 2 + 1,
            }, user.Password);
            return result;
        }

        public async Task<IdentityResult> RegisterCreator(UserRegistrationRequestDTO user)
        {
            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
                FirstName = user.FirstName,
                LastName = user.LastName,
                DateOfBirth = user.DateOfBirth,
                UserName = user.Email,
                Email = user.Email,
                Roles = ["CREATOR"],
                Claims = [
                    new()
                    {
                        ClaimType = ClaimTypes.Email,
                        ClaimValue = user.Email
                    },
                ],
            }, user.Password);
            return result;
        }

        public async Task<IdentityResult> RegisterTeacher(UserRegistrationRequestDTO user)
        {

            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
                FirstName = user.FirstName,
                LastName = user.LastName,
                DateOfBirth = user.DateOfBirth,
                UserName = user.Email,
                Email = user.Email,
                Roles = ["TEACHER"],
                Claims = [
                    new()
                    {
                        ClaimType = ClaimTypes.Email,
                        ClaimValue = user.Email
                    },
                ],
                School = user.School,
            }, user.Password);
            return result;
        }

        public async Task<ApplicationUser?> GetUser(ClaimsPrincipal user)
        {
            return await _userManager.FindByEmailAsync(user.FindFirst(ClaimTypes.Email)?.Value ?? throw new EntityNotFoundException());
        }

        public async Task<int> EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport)
        {
            int XP_SOLVED_OLD = 40;
            int XP_SOLVED_NEW = 100;
            ApplicationUser? applicationUser = await GetUser(user) ??
                throw new EntityNotFoundException($"User not found " +
                $"{user.Claims.Where(claim => claim.Type == ClaimTypes.Email).FirstOrDefault()?.Value}");
            logsService.EndOfLesson(applicationUser, lessonReport);
            LessonGroup? reportedLessonGroup = await lessonGroupsService.GetLessonGroupByIDAsync(lessonReport.LessonGroupId)
                ?? throw new EntityNotFoundException($"Lesson group with id {lessonReport.LessonGroupId} not found.");

            bool solvedNewLesson = CheckIfSolvedNewLesson(lessonReport.LessonId, (int)applicationUser.NextLessonId!, reportedLessonGroup);

            int awardedXP;
            bool completedLessonGroup = false;
            if (solvedNewLesson)
            {
                await OnSolvedNewLesson(lessonReport.LessonId, applicationUser, reportedLessonGroup);
                completedLessonGroup = CheckIfCompletedNewLessonGroup(reportedLessonGroup, lessonReport.LessonId);
                if (completedLessonGroup)
                {
                    await OnCompletedNewLessonGroup(applicationUser, reportedLessonGroup);
                }

                awardedXP = XP_SOLVED_NEW;
            }
            else
            {
                awardedXP = XP_SOLVED_OLD;
            }
            int oldXp = applicationUser.TotalXP;
            applicationUser.XPachieved.Add(new KeyValuePair<DateTime, int>(DateTime.Now, awardedXP));
            await HandleQuestProgress(lessonReport, applicationUser, awardedXP, completedLessonGroup);

            applicationUser.TotalXP = ApplicationUser.CalculateTotalXP(applicationUser);
            int totalAwardedXP = applicationUser.TotalXP - oldXp;

            await UpdateUserScoreFromLessonReport(lessonReport.AnswersReport, applicationUser);

            await UpdateUser(applicationUser);
            return totalAwardedXP;
        }

        private async Task UpdateUserScoreFromLessonReport(
            List<KeyValuePair<int, bool>> answersReport,
            ApplicationUser applicationUser)
        {
            double userScore = applicationUser.Score;
            for (int i = 0; i < answersReport.Count; i++)
            {
                int exerciseId = answersReport[i].Key;
                bool correct = answersReport[i].Value;
                var exercise = await exercisesService.GetExerciseByIDAsync(answersReport[i].Key)
                    ?? throw new EntityNotFoundException($"Exercise with id {exerciseId} not found");
                bool isRepeatedExercise = answersReport
                    .Select(pair => pair.Key)
                    .Select(id => id == exerciseId)
                    .Count() > 1;
                userScore = AdjustUserScore(applicationUser.Score, exercise, answersReport[i].Value, isRepeatedExercise);
            }
            applicationUser.Score = userScore;
        }

        private static bool CheckIfSolvedNewLesson(int lessonId,
            int nextLessonId,
            LessonGroup reportedLessonGroup)
        {
            int newlySolvedLessonIndex = reportedLessonGroup.LessonIds.IndexOf(lessonId);
            if (newlySolvedLessonIndex == -1)
            {
                throw new InvalidDataException($"Lesson with id {lessonId} not found in lesson group with id {reportedLessonGroup.PrivateId}");
            }
            int realNewLessonIndex = reportedLessonGroup.LessonIds.IndexOf(nextLessonId);
            bool solvedNewLesson = (newlySolvedLessonIndex == realNewLessonIndex);
            return solvedNewLesson;
        }

        private async Task<bool> OnSolvedNewLesson(
            int lessonId,
            ApplicationUser applicationUser,
            LessonGroup reportedLessonGroup)
        {
            applicationUser.HighestLessonId = lessonId;
            try
            {
                int nextLessonId = await lessonsService.GetNextLessonIdForLessonId(lessonId, reportedLessonGroup);
                applicationUser.NextLessonId = nextLessonId;
            }
            //TODO: Handle end of course
            catch (EntityNotFoundException) { }
            return false;
        }

        private static bool CheckIfCompletedNewLessonGroup(LessonGroup reportedLessonGroup, int lessonId)
        {
            return reportedLessonGroup.LessonIds.IndexOf(lessonId) == reportedLessonGroup.LessonIds.Count - 1;
        }

        private async Task OnCompletedNewLessonGroup(ApplicationUser applicationUser, LessonGroup reportedLessonGroup)
        {
            applicationUser.HighestLessonGroupId = reportedLessonGroup.PrivateId;

            int? nextLessonGroupId = (await lessonGroupsService.GetNextLessonGroupForLessonGroupId(reportedLessonGroup.PrivateId))?.PrivateId;
            if (nextLessonGroupId == null)
            {
                return;
            }
            applicationUser.NextLessonGroupId = nextLessonGroupId;
            return;
        }

        private async Task HandleQuestProgress(EndOfLessonReport lessonReport, ApplicationUser applicationUser, int awardedXP, bool completedLessonGroup)
        {
            int newlySolvedQuests = await UpdateQuestProgress(applicationUser, lessonReport, awardedXP, completedLessonGroup);
            int questsXP = newlySolvedQuests * 50;
            if (questsXP > 0)
                applicationUser.XPachieved.Add(new KeyValuePair<DateTime, int>(DateTime.Now, questsXP));
        }

        private async Task<int> UpdateQuestProgress(ApplicationUser applicationUser,
            EndOfLessonReport lessonReport,
            int awardedXP,
            bool completedLessonGroup)
        {
            if (applicationUser.Quests == null)
            {
                await GenerateDailyQuestsForUser(applicationUser);
            }
            var todayQuests = applicationUser.Quests!
                .Where(q => q.Key == DateOnly.FromDateTime(DateTime.Now))
                .SelectMany(q => q.Value)
                .ToHashSet();
            int newlyCompleted = 0;
            foreach (var quest in todayQuests)
            {
                if (quest.IsCompleted)
                {
                    continue;
                }

                switch (quest.Type)
                {
                    case QuestTypes.GET_XP:
                        newlyCompleted += Quest.UpdateGetXPQuest(awardedXP, quest);
                        break;
                    case QuestTypes.HIGH_ACCURACY:
                        newlyCompleted += Quest.UpdateHighAccuracyQuest(lessonReport.Accuracy, quest);
                        break;
                    case QuestTypes.HIGH_SPEED:
                        newlyCompleted += Quest.UpdateHighSpeedQuest(lessonReport.DurationMiliseconds, quest);
                        break;
                    case QuestTypes.COMPLETE_LESSON_GROUP:
                        newlyCompleted += Quest.UpdateCompleteLessonGroupQuest(completedLessonGroup, quest);
                        break;
                }
            }
            await UpdateUser(applicationUser);
            return newlyCompleted;
        }


        public async Task<ISet<Quest>> GenerateDailyQuestsForUser(ApplicationUser applicationUser)
        {
            var XPGoal = 150;
            var accuracyGoal = 90;
            var speedGoal = 30;
            var NLessons = 2;
            var quests = new HashSet<Quest>
            {
                Quest.CreateGetXPQuest(XPGoal),
                Quest.CreateHighAccuracyQuest(accuracyGoal, NLessons),
                Quest.CreateHighSpeedQuest(speedGoal, NLessons),
                Quest.CreateCompleteLessonGroupQuest()
            };
            //shuffle quests
            quests = [.. quests.OrderBy(x => Guid.NewGuid()).Take(2)];
            applicationUser.Quests ??= [];
            applicationUser.Quests?.Add(new KeyValuePair<DateOnly, ISet<Quest>>(DateOnly.FromDateTime(DateTime.Now), quests));
            await UpdateUser(applicationUser);
            return quests;
        }

        private async Task<ApplicationUser> UpdateUser(ApplicationUser user)
        {
            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                throw new InvalidDataException(result.Errors.First().Description);
            }
            return user;
        }

        private static double AdjustUserScore(double userScore, Exercise exercise, bool correct, bool repeated)
        {
            const double POSITIVE_LEARNING_RATE = 0.05;
            const double NEGATIVE_LEARNING_RATE = 0.05;
            double exerciseScore = exercise.Difficulty;
            if (correct && exerciseScore > userScore)
            {
                if (repeated)
                {
                    userScore += (exerciseScore - userScore) * POSITIVE_LEARNING_RATE / 2;
                }
                else
                {
                    userScore += (exerciseScore - userScore) * POSITIVE_LEARNING_RATE;
                }
            }
            else if (!correct && exerciseScore < userScore)
            {
                userScore -= (userScore - exerciseScore) * NEGATIVE_LEARNING_RATE;
            }
            return userScore;
        }

        public async Task ChangePassword(ClaimsPrincipal user, string oldPassword, string newPassword)
        {
            ApplicationUser? applicationUser = await GetUser(user)
                ?? throw new EntityNotFoundException("User not found");
            var result = await _userManager.ChangePasswordAsync(applicationUser, oldPassword, newPassword);
            if (!result.Succeeded)
            {
                string reason = result.Errors.First().Description;
                if(reason == "Incorrect password.")
                {
                    throw new UserAuthenticationException(UserAuthenticationException.INVALID_PASSWORD);
                } else
                {
                    throw new InvalidDataException(reason);
                }
            }
        }

        public async Task<ApplicationUser> UpdateUserData(ApplicationUser applicationUser)
        {
            return await UpdateUser(applicationUser);
        }
    }
}
