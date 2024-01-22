using CodeyBE.Contracts.DTOs;
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
    public class UserController(IUserService userService)
    {

        [AllowAnonymous]
        [HttpPost("register", Name = "register")]
        [ProducesResponseType(typeof(UserRegistrationDTO), (int)HttpStatusCode.OK)]
        public async Task<UserRegistrationDTO> RegisterUser([FromBody] Dictionary<string, string> body)
        {
            var email = body["email"];
            var password = body["password"];
            var result = await userService.RegisterUser(new UserRegistrationInternalDTO
            {
                Email = email,
                Password = password
            });
            return new UserRegistrationDTO
            {
                success = result.Succeeded,
                message = result?.Errors.Select(e => e.Description)
            };
        }

        [AllowAnonymous]
        [HttpPost("login", Name = "login")]
        [ProducesResponseType(typeof(UserLoginDTO), (int)HttpStatusCode.OK)]
        public async Task<UserLoginDTO> LoginUser([FromBody] Dictionary<string, string> body)
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
                return new UserLoginDTO
                {
                    token = token.Token,
                    success = true,
                };
            } catch(UserAuthenticationException e)
            {
                return new UserLoginDTO
                {
                    success = false,
                    message = [e.Message]
                };
            } catch(EntityNotFoundException e)
            {
                return new UserLoginDTO
                {
                    success = false,
                    message = [e.Message]
                };
            }
        }
    }
}
