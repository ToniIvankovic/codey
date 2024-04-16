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


        public async Task<JWTTokenDTO> LoginUser(UserRegistrationInternalDTO userDTO)
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

        public async Task<IdentityResult> RegisterStudent(UserRegistrationInternalDTO user)
        {
            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
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
            }, user.Password);
            return result;
        }

        public async Task<IdentityResult> RegisterCreator(UserRegistrationInternalDTO user)
        {
            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
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

        public async Task<IdentityResult> RegisterTeacher(UserRegistrationInternalDTO user)
        {

            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
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

        public async Task<ApplicationUser> EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport)
        {
            int XP_SOLVED_OLD = 40;
            int XP_SOLVED_NEW = 100;
            logsService.EndOfLesson(user, lessonReport);
            ApplicationUser? applicationUser = await GetUser(user) ??
                throw new EntityNotFoundException($"User not found " +
                $"{user.Claims.Where(claim => claim.Type == ClaimTypes.Email).FirstOrDefault()?.Value}");
            LessonGroup? reportedLessonGroup = await lessonGroupsService.GetLessonGroupByIDAsync(lessonReport.LessonGroupId)
                ?? throw new EntityNotFoundException($"Lesson group with id {lessonReport.LessonGroupId} not found.");

            bool solvedNewLesson = CheckIfSolvedNewLesson(lessonReport, applicationUser, reportedLessonGroup);

            int awardedXP;
            bool completedLessonGroup = false;
            if (solvedNewLesson)
            {
                completedLessonGroup = await SolvedNewLesson(lessonReport, applicationUser, reportedLessonGroup, completedLessonGroup);
                awardedXP = XP_SOLVED_NEW;
            }
            else
            {
                awardedXP = XP_SOLVED_OLD;
            }

            double userScore = applicationUser.Score;
            for (int i = 0; i < lessonReport.AnswersReport.Count; i++)
            {
                int exerciseId = lessonReport.AnswersReport[i].Key;
                bool correct = lessonReport.AnswersReport[i].Value;
                var exercise = await exercisesService.GetExerciseByIDAsync(lessonReport.AnswersReport[i].Key)
                    ?? throw new EntityNotFoundException($"Exercise with id {exerciseId} not found");
                bool isRepeatedExercise = lessonReport.AnswersReport
                    .Select(pair => pair.Key)
                    .Select(id => id == exerciseId)
                    .Count() > 1;
                userScore = AdjustUserScore(applicationUser.Score, exercise, lessonReport.AnswersReport[i].Value, isRepeatedExercise);
            }
            applicationUser.Score = userScore;

            applicationUser.XPachieved.Add(new KeyValuePair<DateTime, int>(DateTime.Now, awardedXP));
            await HandleQuestProgress(lessonReport, applicationUser, awardedXP, completedLessonGroup);

            applicationUser.TotalXP = ApplicationUser.CalculateTotalXP(applicationUser);

            await UpdateUser(applicationUser);
            return applicationUser;
        }

        private static bool CheckIfSolvedNewLesson(EndOfLessonReport lessonReport, ApplicationUser applicationUser, LessonGroup reportedLessonGroup)
        {
            int newlySolvedLessonIndex = reportedLessonGroup.LessonIds.IndexOf(lessonReport.LessonId);
            if (newlySolvedLessonIndex == -1)
            {
                throw new InvalidDataException($"Lesson with id {lessonReport.LessonId} not found in lesson group with id {lessonReport.LessonGroupId}");
            }
            int realNewLessonIndex = reportedLessonGroup.LessonIds.IndexOf((int)applicationUser.NextLessonId!);
            bool solvedNewLesson = (newlySolvedLessonIndex == realNewLessonIndex);
            return solvedNewLesson;
        }

        private async Task<bool> SolvedNewLesson(EndOfLessonReport lessonReport,
            ApplicationUser applicationUser,
            LessonGroup reportedLessonGroup,
            bool completedLessonGroup)
        {
            await SetHighestSolvedLesson(applicationUser, lessonReport.LessonId);
            try
            {
                int nextLessonId = await lessonsService.GetNextLessonForLessonId(lessonReport.LessonId, reportedLessonGroup);
                await SetNextLesson(applicationUser, nextLessonId);

                // If this is the last lesson in the lesson group, set the next lesson group
                if (reportedLessonGroup.LessonIds.IndexOf(lessonReport.LessonId) == reportedLessonGroup.LessonIds.Count - 1)
                {
                    completedLessonGroup = await SolvedNewLessonGroup(applicationUser, reportedLessonGroup);
                }
            }
            //TODO: Handle end of course
            catch (EntityNotFoundException) { }

            return completedLessonGroup;
        }

        private async Task<bool> SolvedNewLessonGroup(ApplicationUser applicationUser, LessonGroup reportedLessonGroup)
        {
            bool completedLessonGroup = true;
            await SetHighestSolvedLessonGroup(applicationUser, reportedLessonGroup.PrivateId);

            int? nextLessonGroupId = (await lessonGroupsService.GetNextLessonGroupForLessonGroupId(reportedLessonGroup.PrivateId))?.PrivateId;
            await SetNextLessonGroup(applicationUser, nextLessonGroupId);
            return completedLessonGroup;
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
                        newlyCompleted += UpdateGetXPQuest(awardedXP, quest);
                        break;
                    case QuestTypes.HIGH_ACCURACY:
                        newlyCompleted += UpdateHighAccuracyQuest(lessonReport.Accuracy, quest);
                        break;
                    case QuestTypes.HIGH_SPEED:
                        newlyCompleted += UpdateHighSpeedQuest(lessonReport.DurationMiliseconds, quest);
                        break;
                    case QuestTypes.COMPLETE_LESSON_GROUP:
                        newlyCompleted += UpdateCompleteLessonGroupQuest(completedLessonGroup, quest);
                        break;
                }
            }
            await UpdateUser(applicationUser);
            return newlyCompleted;
        }

        private static int UpdateCompleteLessonGroupQuest(bool completedLessonGroup, Quest quest)
        {
            quest.IsCompleted = completedLessonGroup;
            if (quest.IsCompleted)
            {
                return 1;
            }

            return 0;
        }

        private static int UpdateHighSpeedQuest(int durationMiliseconds, Quest quest)
        {
            quest.Progress += (durationMiliseconds / 1000.0 <= quest.Constraint) ? 1 : 0;
            if (quest.Progress == quest.NLessons)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
        }

        private static int UpdateHighAccuracyQuest(double accuracy, Quest quest)
        {
            quest.Progress += (accuracy >= quest.Constraint / 100.0) ? 1 : 0;
            if (quest.Progress == quest.NLessons)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
        }

        private static int UpdateGetXPQuest(int awardedXP, Quest quest)
        {
            quest.Progress += awardedXP;
            if (quest.Progress >= quest.Constraint)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
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

        private async Task SetHighestSolvedLesson(ApplicationUser applicationUser, int lessonId)
        {
            applicationUser.HighestLessonId = lessonId;
            await UpdateUser(applicationUser);
        }
        private async Task SetNextLesson(ApplicationUser applicationUser, int lessonId)
        {
            applicationUser.NextLessonId = lessonId;
            await UpdateUser(applicationUser);
        }
        private async Task SetHighestSolvedLessonGroup(ApplicationUser applicationUser, int lessonGroupId)
        {
            applicationUser.HighestLessonGroupId = lessonGroupId;
            await UpdateUser(applicationUser);
        }
        private async Task SetNextLessonGroup(ApplicationUser applicationUser, int? lessonGroupId)
        {
            if (lessonGroupId == null)
            {
                return;
            }
            applicationUser.NextLessonGroupId = lessonGroupId;
            await UpdateUser(applicationUser);
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
    }
}
