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

        public async Task<ApplicationUser?> GetUser(ClaimsPrincipal user)
        {
            return await _userManager.FindByEmailAsync(user.FindFirst(ClaimTypes.Email)?.Value ?? throw new EntityNotFoundException());
        }

        public async Task<ApplicationUser> EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport)
        {
            logsService.EndOfLesson(user, lessonReport);
            ApplicationUser? applicationUser = await GetUser(user) ??
                throw new EntityNotFoundException($"User not found " +
                $"{user.Claims.Where(claim => claim.Type == ClaimTypes.Email).FirstOrDefault()?.Value}");
            LessonGroup? lessonGroup = await lessonGroupsService.GetLessonGroupByIDAsync(lessonReport.LessonGroupId)
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
                LessonGroup nextLessonGroup = await lessonGroupsService.GetLessonGroupByIDAsync((int)applicationUser.NextLessonGroupId!)
                    ?? throw new EntityNotFoundException("User's next lesson group cannot be found");
                if (lessonGroup.Order < nextLessonGroup.Order)
                {
                    solvedNewLesson = false;
                }
                else if (lessonGroup.Order == nextLessonGroup.Order)
                {
                    int newSolvedLessonIndex = lessonGroup.LessonIds.IndexOf(lessonReport.LessonId);
                    int nextLessonToSolveIndex = lessonGroup.LessonIds.IndexOf((int)applicationUser.NextLessonId!);
                    solvedNewLesson = nextLessonToSolveIndex == -1 || newSolvedLessonIndex >= nextLessonToSolveIndex;
                }
                else
                {
                    throw new InvalidDataException("Invalid next lesson group ID");
                }
            }

            if (solvedNewLesson)
            {
                await SetHighestSolvedLesson(applicationUser, lessonReport.LessonId);
                int nextLessonId = await lessonsService.GetNextLessonForLessonId(lessonReport.LessonId, lessonGroup);
                await SetNextLesson(applicationUser, nextLessonId);

                // If this is the last lesson in the lesson group, set the next lesson group
                if (lessonGroup.LessonIds.IndexOf(lessonReport.LessonId) == lessonGroup.LessonIds.Count - 1)
                {
                    await SetHighestSolvedLessonGroup(applicationUser, lessonGroup.PrivateId);

                    int? nextLessonGroupId = (await lessonGroupsService.GetNextLessonGroupForLessonGroupId(lessonGroup.PrivateId))?.PrivateId;
                    await SetNextLessonGroup(applicationUser, nextLessonGroupId);
                }
            }
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
