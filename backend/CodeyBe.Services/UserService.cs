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
                throw new EntityNotFoundException($"User not found {user.Claims.Where(claim => claim.Type == ClaimTypes.Email).FirstOrDefault()?.Value}");

            bool solvedNewLesson = applicationUser.HighestLessonId == null
                || await lessonsService.LessonOrder((int)applicationUser.HighestLessonId, lessonReport.LessonId) < 0;
            if (solvedNewLesson)
            {
                await SetHighestSolvedLesson(applicationUser, lessonReport.LessonId);
                int nextLessonId = await lessonsService.GetNextLessonForLessonId(lessonReport.LessonId);
                await SetNextLesson(applicationUser, nextLessonId);

                if (await lessonsService.IsLastLessonInGroup(lessonReport.LessonId))
                {
                    Lesson lesson = await lessonsService.GetLessonByIDAsync(lessonReport.LessonId) ?? throw new EntityNotFoundException();
                    await SetHighestSolvedLessonGroup(applicationUser, lesson.LessonGroupId);

                    int nextLessonGroupId = await lessonGroupsService.GetNextLessonGroupForLessonGroupId(lesson.LessonGroupId);
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
        protected async Task SetNextLessonGroup(ApplicationUser applicationUser, int lessonGroupId)
        {
            applicationUser.NextLessonGroupId = lessonGroupId;
            await _userManager.UpdateAsync(applicationUser);
        }

    }
}
