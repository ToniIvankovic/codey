using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBe.Services
{
    public class InteractionService(UserManager<ApplicationUser> userManager, IUserService userService) : IInteractionService
    {
        private readonly UserManager<ApplicationUser> _userManager = userManager;
        private readonly IUserService _userService = userService;
        public async Task<IEnumerable<ApplicationUser>> GetAllStudentsForTeacher(ClaimsPrincipal teacherCP)
        {
            ApplicationUser? teacher = await _userService.GetUser(teacherCP)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            var allStudents = _userManager.Users.Where(user => user.Roles.Contains("STUDENT"));
            var studentsForTeacher = allStudents.Where(user => teacher.School == user.School);
            return studentsForTeacher;
        }
        public async Task<IEnumerable<ApplicationUser>> GetStudentByQuery(ClaimsPrincipal teacherCP, string? query)
        {
            var allStudents = await GetAllStudentsForTeacher(teacherCP);
            if (query == null) return allStudents;
            var selectedStudents = allStudents.Where(user => user.NormalizedEmail?.Contains(query.ToUpper()) ?? false);
            selectedStudents.Concat(allStudents.Where(user => user.NormalizedUserName?.Contains(query.ToUpper()) ?? false));
            return selectedStudents;
        }
    }
}
