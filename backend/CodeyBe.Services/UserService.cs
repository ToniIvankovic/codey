using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
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
    public class UserService(UserManager<ApplicationUser> userManager, ITokenGeneratorService tokenGenerator) : IUserService
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

        public async Task<IdentityResult> RegisterUser(UserRegistrationInternalDTO user)
        {
            IdentityResult result = await _userManager.CreateAsync(new ApplicationUser
            {
                UserName = user.Email,
                Email = user.Email,
                Roles = ["STUDENT"],
                Claims = [
                    new() {
                        ClaimType=ClaimTypes.Email, 
                        ClaimValue=user.Email 
                    },
                ]
            }, user.Password);
            return result;
        }
    }
}
