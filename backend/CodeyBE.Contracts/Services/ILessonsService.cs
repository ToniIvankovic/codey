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
        public int FirstLessonId { get; }
        public Task<IEnumerable<Lesson>> GetAllLessonsAsync();
        public Task<Lesson?> GetLessonByIDAsync(int id);
        public Task<IEnumerable<Lesson>> GetLessonsForLessonGroupAsync(int lessonGroupId);
        public Task<LessonGroup?> GetLessonGroupByLessonIdAsync(int id);
        public Task<int?> LessonOrder(int lesson1Id, int lesson2Id);
        public Task<bool> IsLastLessonInGroup(int lessonId);
        public Task<int> GetNextLessonForLessonId(int lessonId);
        Task<Lesson> CreateLessonAsync(LessonCreationDTO lesson);
        Task<Lesson> UpdateLessonAsync(int id, LessonCreationDTO lesson);
        Task DeleteLessonAsync(int id);
    }
}
