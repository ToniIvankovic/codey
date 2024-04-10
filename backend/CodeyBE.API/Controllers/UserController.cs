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
            var school = body["school"];
            var result = await userService.RegisterStudent(new UserRegistrationInternalDTO
            {
                Email = email,
                Password = password,
                School = school
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
                return new OkObjectResult(ProduceUserDataDTO(applicationUser));
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
                var dto = ProduceUserDataDTO(applicationUser);
                return new OkObjectResult(dto);
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(400, e.Message);
            }
            catch (InvalidDataException e)
            {
                return StatusCode(400, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(500, e.Message);
            }
        }

        private static UserDataDTO ProduceUserDataDTO(ApplicationUser applicationUser)
        {
            return new UserDataDTO
            {
                Email = applicationUser.Email ?? throw new MissingFieldException("Email missing from user"),
                HighestLessonId = applicationUser.HighestLessonId,
                HighestLessonGroupId = applicationUser.HighestLessonGroupId,
                NextLessonId = applicationUser.NextLessonId,
                NextLessonGroupId = applicationUser.NextLessonGroupId,
                Roles = applicationUser.Roles,
                TotalXP = applicationUser.TotalXP
            };
        }

        [Authorize(Roles = "ADMIN")]
        [HttpPost("register/creator", Name = "registerCreator")]
        [ProducesResponseType(typeof(UserRegistrationDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> RegisterCreator([FromBody] Dictionary<string, string> body)
        {
            var email = body["email"];
            var password = body["password"];
            var result = await userService.RegisterCreator(new UserRegistrationInternalDTO
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

        [Authorize(Roles = "ADMIN")]
        [HttpPost("register/teacher", Name = "registerTeacher")]
        [ProducesResponseType(typeof(UserRegistrationDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> RegisterTeacher([FromBody] Dictionary<string, string> body)
        {
            string email, password, school;
            try
            {
                email = body["email"];
                password = body["password"];
                school = body["school"];
            }
            catch (KeyNotFoundException e)
            {
                return StatusCode(400, e.Message);
            }

            var result = await userService.RegisterTeacher(new UserRegistrationInternalDTO
            {
                Email = email,
                Password = password,
                School = school
            });
            if (!result.Succeeded)
            {
                return StatusCode(400, new UserRegistrationDTO
                {
                    Message = result.Errors.Select(error => error.Description)
                });
            }
            return Ok(new UserRegistrationDTO
            {
                Message = ["User created successfully"]
            });
        }
    }
}
