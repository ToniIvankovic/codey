using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class UserController(IUserService userService) : ControllerBase
    {

        [AllowAnonymous]
        [HttpPost("register", Name = "register")]
        [ProducesResponseType(typeof(UserRegistrationDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> RegisterUser([FromBody] Dictionary<string, string> body)
        {
            var email = body["email"];
            var password = body["password"];
            var result = await userService.RegisterUser(new UserRegistrationInternalDTO
            {
                Email = email,
                Password = password
            });
            if (result.Succeeded)
            {
                return Ok(new UserRegistrationDTO
                {
                    Message = ["User created successfully"]
                });
            }
            return StatusCode(400, new UserRegistrationDTO
            {
                Message = result.Errors.Select(error => error.Description)
            });
        }

        [AllowAnonymous]
        [HttpPost("login", Name = "login")]
        [ProducesResponseType(typeof(UserLoginDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> LoginUser([FromBody] Dictionary<string, string> body)
        {
            var email = body["email"];
            var password = body["password"];
            try
            {
                var token = await userService.LoginUser(new UserRegistrationInternalDTO
                {
                    Email = email,
                    Password = password
                });
                return new OkObjectResult(
                    new UserLoginDTO
                    {
                        Token = token.Token,
                    });
            }
            catch (Exception e) when (e is UserAuthenticationException || e is EntityNotFoundException)
            {
                return StatusCode(401, e.Message);
            }
        }

        [HttpGet("", Name = "getUserData")]
        [ProducesResponseType(typeof(UserDataDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> GetUserData()
        {
            try
            {
                ApplicationUser? applicationUser = await userService.GetUser(User) ?? throw new EntityNotFoundException();
                return new OkObjectResult(
                    new UserDataDTO
                    {
                        Email = applicationUser.Email,
                        HighestLessonId = applicationUser.HighestLessonId,
                        HighestLessonGroupId = applicationUser.HighestLessonGroupId,
                        NextLessonId = applicationUser.NextLessonId,
                        NextLessonGroupId = applicationUser.NextLessonGroupId
                    });
            }
            catch (Exception e) when (e is UserAuthenticationException || e is EntityNotFoundException)
            {
                return StatusCode(401, e.Message);
            }
        }

        [HttpPost("endedLesson", Name = "lessonResults")]
        [ProducesResponseType(typeof(UserDataDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> EndLesson([FromBody] EndOfLessonReport lessonReport)
        {
            try
            {
                ApplicationUser? applicationUser = await userService.EndLessonAsync(User, lessonReport);
                var dto = new UserDataDTO
                {
                    Email = applicationUser.Email,
                    HighestLessonId = applicationUser.HighestLessonId,
                    HighestLessonGroupId = applicationUser.HighestLessonGroupId,
                    NextLessonId = applicationUser.NextLessonId,
                    NextLessonGroupId = applicationUser.NextLessonGroupId
                };
                return new OkObjectResult(dto);
            } catch (EntityNotFoundException e)
            {
                return StatusCode(400, e.Message);
            }
        }
    }
}
