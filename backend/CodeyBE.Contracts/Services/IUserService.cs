using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Users;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface IUserService
    {
        public Task<IdentityResult> RegisterUser(UserRegistrationInternalDTO user);
        public Task<JWTTokenDTO> LoginUser(UserRegistrationInternalDTO user);
    }
}
