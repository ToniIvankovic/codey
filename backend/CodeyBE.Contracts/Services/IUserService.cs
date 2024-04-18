using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface IUserService
    {
        public Task<IdentityResult> RegisterStudent(UserRegistrationRequestDTO user);
        public Task<IdentityResult> RegisterCreator(UserRegistrationRequestDTO user);
        public Task<IdentityResult> RegisterTeacher(UserRegistrationRequestDTO user);
        public Task<JWTTokenDTO> LoginUser(UserLoginRequestDTO user);
        public Task<ApplicationUser?> GetUser(ClaimsPrincipal user);
        public Task<ApplicationUser> EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport);
        public Task<ISet<Quest>> GenerateDailyQuestsForUser(ApplicationUser applicationUser);
    }
}
