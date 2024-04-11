using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
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
    public class InteractionService(UserManager<ApplicationUser> userManager,
        IUserService userService,
        IClassesRepository classesRepository) : IInteractionService
    {
        private readonly UserManager<ApplicationUser> _userManager = userManager;
        private readonly IUserService _userService = userService;
        private readonly IClassesRepository _classesRepository = classesRepository;

        public async Task<Class> CreateClass(ClaimsPrincipal userTeacher, ClassCreationDTO classCreationDTO)
        {
            ApplicationUser? teacher = await _userService.GetUser(userTeacher)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            await CheckStudentListRequirements(teacher, classCreationDTO.StudentUsernames);
            Class @class = new()
            {
                Name = classCreationDTO.Name,
                School = teacher.School ?? throw new MissingFieldException($"No school for teacher {teacher.Email}"),
                TeacherUsername = teacher.Email ?? throw new MissingFieldException($"No email for teacher"),
                Students = classCreationDTO.StudentUsernames,
            };
            return await _classesRepository.CreateAsync(@class);
        }

        public async Task<Class> UpdateClass(ClaimsPrincipal user, int id, ClassCreationDTO classCreationDTO)
        {
            ApplicationUser? teacher = await _userService.GetUser(user)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            await CheckStudentListRequirements(teacher, classCreationDTO.StudentUsernames);
            Class existingClass = await _classesRepository.GetByIdAsync(id)
                ?? throw new EntityNotFoundException($"No class found with ID {id}");
            if (existingClass.TeacherUsername != teacher.Email)
            {
                throw new UnauthorizedAccessException($"Teacher is not allowed to update this class " +
                    $"because it belongs to another school ({existingClass.School})");
            }
            existingClass.Name = classCreationDTO.Name;
            existingClass.Students = classCreationDTO.StudentUsernames;
            return await _classesRepository.UpdateAsync(existingClass.PrivateId, existingClass);
        }

        private async Task CheckStudentListRequirements(ApplicationUser teacher, List<string> StudentUsernames)
        {
            foreach (string studentUsername in StudentUsernames)
            {
                ApplicationUser? student = await _userManager.FindByNameAsync(studentUsername)
                    ?? throw new EntityNotFoundException($"Student {studentUsername} not found in the database");
                if (student.School != teacher.School)
                {
                    throw new UnauthorizedAccessException($"Student {studentUsername} does not belong to teacher's school");
                }
                var _class = await GetClassForStuedntByTeacher(teacher, studentUsername);
                if (_class != null)
                {
                    throw new InvalidDataException($"Student {studentUsername} is already in a class {_class.Name}");
                }
            }
        }

        public async Task DeleteClass(ClaimsPrincipal user, int id)
        {
            ApplicationUser? teacher = await _userService.GetUser(user)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            Class existingClass = await _classesRepository.GetByIdAsync(id)
                ?? throw new EntityNotFoundException($"No class found with ID {id}");
            if (existingClass.TeacherUsername != teacher.Email)
            {
                throw new UnauthorizedAccessException("Teacher is not allowed to delete this class");
            }
            await _classesRepository.DeleteAsync(existingClass.PrivateId);
        }

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

        public async Task<IEnumerable<Class>> GetAllClassesForTeacher(ClaimsPrincipal user)
        {
            ApplicationUser? teacher = await _userService.GetUser(user)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            return await _classesRepository.GetAllClassesForTeacher(teacher.Email
                ?? throw new MissingFieldException("No teacher email"));

        }

        public async Task<Class?> GetClassForStudentSelf(ClaimsPrincipal userStudent, string studentUsername)
        {
            ApplicationUser? student = await _userService.GetUser(userStudent)
                ?? throw new EntityNotFoundException("Student not found in the database");
            return await _classesRepository.GetClassForStudent(student);
        }
        public async Task<Class?> GetClassForStuedntByTeacher(ClaimsPrincipal userTeacher, string studentUsername)
        {
            ApplicationUser? teacher = await _userService.GetUser(userTeacher)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            return await GetClassForStuedntByTeacher(teacher, studentUsername);
        }
        public async Task<Class?> GetClassForStuedntByTeacher(ApplicationUser teacher, string studentUsername)
        {
            ApplicationUser? student = await _userManager.FindByNameAsync(studentUsername)
                ?? throw new EntityNotFoundException("Student not found in the database");
            if (student.School != teacher.School)
            {
                throw new UnauthorizedAccessException("Teacher is not allowed to access this student");
            }

            return await _classesRepository.GetClassForStudent(student);
        }

        public async Task<Leaderboard> GetLeaderboardForStudentSelf(ClaimsPrincipal userStudent)
        {
            ApplicationUser? student = await _userService.GetUser(userStudent)
                ?? throw new EntityNotFoundException("Student not found in the database");
            Class? _class = await GetClassForStudentSelf(userStudent, student.UserName!)
                ?? throw new EntityNotFoundException("Student is not in any class");
            return ProduceLeaderboardForClass(_class);
        }

        public async Task<Leaderboard> GetLeaderboardForClass(ClaimsPrincipal userTeacher, int classId)
        {
            ApplicationUser? teacher = await _userService.GetUser(userTeacher)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            Class? _class = await _classesRepository.GetByIdAsync(classId)
                ?? throw new EntityNotFoundException($"No class found with ID {classId}");
            if (_class.TeacherUsername != teacher.Email)
            {
                throw new UnauthorizedAccessException("Teacher is not allowed to access this class");
            }
            return ProduceLeaderboardForClass(_class);
        }

        private Leaderboard ProduceLeaderboardForClass(Class @class)
        {
            return new Leaderboard
            {
                ClassId = @class.PrivateId,
                Students = _userManager.Users
                    .Where(user => @class.Students.Contains(user.UserName!))
                    .OrderByDescending(student => student.TotalXP)
                    .Select(UserDataDTO.FromUser)
                    .ToList(),
            };
        }
    }
}
