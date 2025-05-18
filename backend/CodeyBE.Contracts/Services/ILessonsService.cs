using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface ILessonsService
    {
        public Task<int> GetFirstLessonIdAsync();
        public Task<IEnumerable<Lesson>> GetAllLessonsAsync();
        public Task<Lesson?> GetLessonByIDAsync(int id);
        public Task<IEnumerable<Lesson>> GetLessonsForLessonGroupAsync(int lessonGroupId);
        public Task<int> GetNextLessonIdForLessonId(int lessonId, LessonGroup lessonGroup);
        Task<Lesson> CreateLessonAsync(LessonCreationDTO lesson);
        Task<Lesson> UpdateLessonAsync(int id, LessonCreationDTO lesson);
        Task DeleteLessonAsync(int id);
        Task<List<Lesson>> GetLessonsByIDsAsync(List<int> id);
    }
}
