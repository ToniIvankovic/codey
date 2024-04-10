using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
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
            }, user.Password);
            return result;
        }

        public async Task<ApplicationUser?> GetUser(ClaimsPrincipal user)
        {
            return await _userManager.FindByEmailAsync(user.FindFirst(ClaimTypes.Email)?.Value ?? throw new EntityNotFoundException());
        }

        public async Task<ApplicationUser> EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport)
        {
            int XP_SOLVED_OLD = 30;
            int XP_SOLVED_NEW = 100;
            logsService.EndOfLesson(user, lessonReport);
            ApplicationUser? applicationUser = await GetUser(user) ??
                throw new EntityNotFoundException($"User not found " +
                $"{user.Claims.Where(claim => claim.Type == ClaimTypes.Email).FirstOrDefault()?.Value}");
            LessonGroup? reportedLessonGroup = await lessonGroupsService.GetLessonGroupByIDAsync(lessonReport.LessonGroupId)
                ?? throw new EntityNotFoundException($"Lesson group with id {lessonReport.LessonGroupId} not found.");

            bool solvedNewLesson;
            // If the user has not solved any lessons yet, the new lesson is solved
            if (applicationUser.HighestLessonId == null)
            {
                solvedNewLesson = true;
            }
            // Otherwise, check if the new lesson is newer than the highest solved lesson
            else
            {
                int newlySolvedLessonIndex = reportedLessonGroup.LessonIds.IndexOf(lessonReport.LessonId);
                if (newlySolvedLessonIndex == -1)
                {
                    throw new InvalidDataException($"Lesson with id {lessonReport.LessonId} not found in lesson group with id {lessonReport.LessonGroupId}");
                }
                int realNewLessonIndex = reportedLessonGroup.LessonIds.IndexOf((int)applicationUser.NextLessonId!);
                solvedNewLesson = (newlySolvedLessonIndex == realNewLessonIndex);
            }

            if (solvedNewLesson)
            {
                await SetHighestSolvedLesson(applicationUser, lessonReport.LessonId);
                try
                {

                    int nextLessonId = await lessonsService.GetNextLessonForLessonId(lessonReport.LessonId, reportedLessonGroup);
                    await SetNextLesson(applicationUser, nextLessonId);


                    // If this is the last lesson in the lesson group, set the next lesson group
                    if (reportedLessonGroup.LessonIds.IndexOf(lessonReport.LessonId) == reportedLessonGroup.LessonIds.Count - 1)
                    {
                        await SetHighestSolvedLessonGroup(applicationUser, reportedLessonGroup.PrivateId);

                        int? nextLessonGroupId = (await lessonGroupsService.GetNextLessonGroupForLessonGroupId(reportedLessonGroup.PrivateId))?.PrivateId;
                        await SetNextLessonGroup(applicationUser, nextLessonGroupId);
                    }
                }
                //TODO: Handle end of course
                catch (EntityNotFoundException) { }
                applicationUser.TotalXP += XP_SOLVED_NEW;
                applicationUser.XPachieved.Add(new KeyValuePair<DateTime, int>(DateTime.Now, XP_SOLVED_NEW));
            }
            else
            {
                applicationUser.TotalXP += XP_SOLVED_OLD;
                applicationUser.XPachieved.Add(new KeyValuePair<DateTime, int>(DateTime.Now, XP_SOLVED_OLD));
            }
            _userManager.UpdateAsync(applicationUser).Wait();
            return applicationUser;
        }

        protected async Task SetHighestSolvedLesson(ApplicationUser applicationUser, int lessonId)
        {
            applicationUser.HighestLessonId = lessonId;
            await _userManager.UpdateAsync(applicationUser);
        }
        protected async Task SetNextLesson(ApplicationUser applicationUser, int lessonId)
        {
            applicationUser.NextLessonId = lessonId;
            await _userManager.UpdateAsync(applicationUser);
        }
        protected async Task SetHighestSolvedLessonGroup(ApplicationUser applicationUser, int lessonGroupId)
        {
            applicationUser.HighestLessonGroupId = lessonGroupId;
            await _userManager.UpdateAsync(applicationUser);
        }
        protected async Task SetNextLessonGroup(ApplicationUser applicationUser, int? lessonGroupId)
        {
            if (lessonGroupId == null)
            {
                return;
            }
            applicationUser.NextLessonGroupId = lessonGroupId;
            await _userManager.UpdateAsync(applicationUser);
        }
    }
}
