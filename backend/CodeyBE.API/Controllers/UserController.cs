using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class UserController(IUserService userService, IInteractionService interactionService) : ControllerBase
    {
        private readonly IInteractionService interactionService = interactionService;

        [AllowAnonymous]
        [HttpPost("register", Name = "register")]
        [ProducesResponseType(typeof(UserRegistrationResponseDTO), (int)HttpStatusCode.OK)]
        // Change the parameter to expect your Request DTO directly
        public async Task<IActionResult> RegisterUser([FromBody] UserRegistrationRequestDTO request)
        {
            // No more dictionary parsing! 
            var result = await userService.RegisterStudent(request);

            if (result.Succeeded)
            {
                return Ok(new UserRegistrationResponseDTO
                {
                    Message = ["User created successfully"]
                });
            }

            return StatusCode(400, new UserRegistrationResponseDTO
            {
                Message = result.Errors.Select(error => error.Description).ToList()
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
                var token = await userService.LoginUser(new UserLoginRequestDTO
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
                return new OkObjectResult(await ProduceUserDataDTO(applicationUser));
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
                int awardedXp = await userService.EndLessonAsync(User, lessonReport);
                var dto = await ProduceUserDataDTO((await userService.GetUser(User))!);
                return new OkObjectResult(new EndOfLessonDTO
                {
                    User = dto,
                    AwardedXP = awardedXp,
                });
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

        private async Task<UserDataDTO> ProduceUserDataDTO(ApplicationUser applicationUser)
        {
            var dto = UserDataDTO.FromUser(applicationUser);
            dto.ClassId = (await interactionService.GetClassForStuedntByTeacher(User, applicationUser.UserName!))?.PrivateId;
            if (dto.DailyQuests.IsNullOrEmpty())
            {
                dto.DailyQuests = await userService.GenerateDailyQuestsForUser(applicationUser);
            }
            return dto;
        }


        [Authorize(Roles = "ADMIN")]
        [HttpPost("register/creator", Name = "registerCreator")]
        [ProducesResponseType(typeof(UserRegistrationResponseDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> RegisterCreator([FromBody] StaffRegistrationRequestDTO request)
        {
            var result = await userService.RegisterCreator(request);
            if (result.Succeeded)
            {
                return Ok(new UserRegistrationResponseDTO
                {
                    Message = ["User created successfully"]
                });
            }
            return StatusCode(400, new UserRegistrationResponseDTO
            {
                Message = result.Errors.Select(error => error.Description)
            });
        }

        [Authorize(Roles = "ADMIN")]
        [HttpPost("register/teacher", Name = "registerTeacher")]
        [ProducesResponseType(typeof(UserRegistrationResponseDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> RegisterTeacher([FromBody] StaffRegistrationRequestDTO request)
        {
            var result = await userService.RegisterTeacher(request);
            if (!result.Succeeded)
            {
                return StatusCode(400, new UserRegistrationResponseDTO
                {
                    Message = result.Errors.Select(error => error.Description)
                });
            }
            return Ok(new UserRegistrationResponseDTO
            {
                Message = ["User created successfully"]
            });
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("course", Name = "switchCourse")]
        [ProducesResponseType(typeof(UserDataDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> SwitchCourse([FromBody] Dictionary<string, int> body)
        {
            try
            {
                var courseId = body["courseId"];
                var updatedUser = await userService.SwitchCourseAsync(User, courseId);
                return new OkObjectResult(await ProduceUserDataDTO(updatedUser));
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(404, e.Message);
            }
        }

        [HttpPost("change-password", Name = "changePassword")]
        [ProducesResponseType((int)HttpStatusCode.OK)]
        public async Task<IActionResult> ChangePassword([FromBody] Dictionary<string, string> body)
        {
            var oldPassword = body["oldPassword"];
            var newPassword = body["newPassword"];
            try
            {
                await userService.ChangePassword(User, oldPassword, newPassword);
                return Ok();
            }
            catch (Exception e)
            {
                return StatusCode(400, e.Message);
            }
        }

        [HttpPut("", Name = "updateUser")]
        [ProducesResponseType(typeof(UserDataDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateUser([FromBody] Dictionary<string, string> body)
        {
            try
            {
                ApplicationUser? applicationUser = await userService.GetUser(User) ?? throw new EntityNotFoundException();
                var firstName = body["firstName"]?.Trim() ?? "";
                var lastName = body["lastName"]?.Trim() ?? "";
                if (firstName.Length > 20)
                {
                    return StatusCode(400, "Ime smije imati najviše 20 znakova");
                }
                if (lastName.Length > 20)
                {
                    return StatusCode(400, "Prezime smije imati najviše 20 znakova");
                }
                applicationUser.FirstName = firstName;
                applicationUser.LastName = lastName;
                if (body.TryGetValue("dateOfBirth", out var rawDob) && !string.IsNullOrWhiteSpace(rawDob))
                {
                    applicationUser.DateOfBirth = DateOnly.Parse(rawDob);
                }
                else
                {
                    applicationUser.DateOfBirth = null;
                }
                if (body.TryGetValue("leaderboardName", out var rawLeaderboardName))
                {
                    var leaderboardName = rawLeaderboardName?.Trim() ?? "";
                    if (string.IsNullOrEmpty(leaderboardName))
                    {
                        return StatusCode(400, "Ime na ljestvici ne smije biti prazno");
                    }
                    if (leaderboardName.Length > 30)
                    {
                        return StatusCode(400, "Ime na ljestvici smije imati najviše 30 znakova");
                    }
                    applicationUser.LeaderboardName = leaderboardName;
                }
                var newUser = await userService.UpdateUserData(applicationUser);
                return new OkObjectResult(await ProduceUserDataDTO(newUser));
            }
            catch (Exception e) when (e is UserAuthenticationException || e is EntityNotFoundException)
            {
                return StatusCode(401, e.Message);
            } catch (Exception e)
            {
                return StatusCode(400, e.Message);
            }
        }

        [HttpDelete("leaderboard-name", Name = "resetLeaderboardName")]
        [ProducesResponseType(typeof(UserDataDTO), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> ResetLeaderboardName()
        {
            try
            {
                ApplicationUser? applicationUser = await userService.GetUser(User) ?? throw new EntityNotFoundException();
                applicationUser.LeaderboardName = null;
                var newUser = await userService.UpdateUserData(applicationUser);
                return new OkObjectResult(await ProduceUserDataDTO(newUser));
            }
            catch (Exception e) when (e is UserAuthenticationException || e is EntityNotFoundException)
            {
                return StatusCode(401, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(400, e.Message);
            }
        }
    }
}
