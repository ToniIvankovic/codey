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
    }
}
