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

        public async Task<Class> CreateClass(ClaimsPrincipal user, ClassCreationDTO classCreationDTO)
        {
            ApplicationUser? teacher = await _userService.GetUser(user)
                ?? throw new EntityNotFoundException("Teacher not found in the database");
            //TODO check if students belong to the teacher's school
            //TODO check if students belong to another class
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
            //TODO check if students belong to the teacher's school
            //TODO check if students belong to another class
            Class existingClass = await _classesRepository.GetByIdAsync(id)
                ?? throw new EntityNotFoundException($"No class found with ID {id}");
            if (existingClass.TeacherUsername != teacher.Email)
            {
                throw new UnauthorizedAccessException("Teacher is not allowed to update this class");
            }
            existingClass.Name = classCreationDTO.Name;
            existingClass.Students = classCreationDTO.StudentUsernames;
            return await _classesRepository.UpdateAsync(existingClass.PrivateId, existingClass);
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
    }
}
