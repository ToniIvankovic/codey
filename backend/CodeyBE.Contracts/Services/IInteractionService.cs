using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface IInteractionService
    {
        public Task<IEnumerable<ApplicationUser>> GetAllStudentsForTeacher(ClaimsPrincipal teacher);
        public Task<IEnumerable<ApplicationUser>> GetStudentByQuery(ClaimsPrincipal teacher, string? query);
        public Task<Class> CreateClass(ClaimsPrincipal user, ClassCreationDTO classCreationDTO);
        public Task<Class> UpdateClass(ClaimsPrincipal user, int id, ClassCreationDTO classCreationDTO);
        public Task DeleteClass(ClaimsPrincipal user, int id);
        public Task<IEnumerable<Class>> GetAllClassesForTeacher(ClaimsPrincipal user);
        public Task<Class?> GetClassForStudentSelf(ClaimsPrincipal userStudent, string studentUsername);
        public Task<Class?> GetClassForStuedntByTeacher(ApplicationUser teacher, string studentUsername);
        public Task<Class?> GetClassForStuedntByTeacher(ClaimsPrincipal userTeacher, string studentUsername);
        public Task<Leaderboard> GetLeaderboardForStudentSelf(ClaimsPrincipal user);
        public Task<Leaderboard> GetLeaderboardForClass(ClaimsPrincipal user, int classId);
    }
}
