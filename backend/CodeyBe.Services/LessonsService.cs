using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using System.Security.Claims;

namespace CodeyBe.Services
{
    public class LessonsService(ILessonsRepository lessonsRepository, ILessonGroupsService lessonGroupsService) : ILessonsService
    {
        private readonly ILessonsRepository _lessonsRepository = lessonsRepository;
        private readonly ILessonGroupsService _lessonGroupsService = lessonGroupsService;

        public async Task<IEnumerable<Lesson>> GetAllLessonsAsync()
        {
            return await _lessonsRepository.GetAllAsync();
        }

        public async Task<Lesson?> GetLessonByIDAsync(int id)
        {
            return await _lessonsRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<Lesson>> GetLessonsForLessonGroupAsync(int lessonGroupId)
        {
            LessonGroup? lessonGroup = await _lessonGroupsService.GetLessonGroupByIDAsync(lessonGroupId);
            if (lessonGroup == null)
            {
                return new List<Lesson>();
            }
            IEnumerable<Lesson> allLessons = await GetAllLessonsAsync();
            return allLessons.Where(lesson => lesson.LessonGroupId == lessonGroup.PrivateId).ToList();
        }

        public async Task<LessonGroup?> GetLessonGroupByLessonIdAsync(int id)
        {
            Lesson? lesson = await GetLessonByIDAsync(id);
            if (lesson == null)
            {
                return await Task.FromResult<LessonGroup?>(null);
            }
            return await _lessonGroupsService.GetLessonGroupByIDAsync(lesson.LessonGroupId);
        }
        public async Task<int?> LessonOrder(int lesson1Id, int lesson2Id)
        {
            Lesson? lesson1 = await GetLessonByIDAsync(lesson1Id);
            Lesson? lesson2 = await GetLessonByIDAsync(lesson2Id);
            if (lesson1 == null || lesson2 == null)
            {
                return null;
            }
            return lesson1.PrivateId - lesson2.PrivateId;
        }

        public async Task<bool> IsLastLessonInGroup(int lessonId)
        {
            Lesson? lesson = await GetLessonByIDAsync(lessonId);
            if (lesson == null)
            {
                return false;
            }
            IEnumerable<Lesson> lessons = await GetLessonsForLessonGroupAsync(lesson.LessonGroupId);
            int maxLessonId = lessons.Max(lesson => lesson.PrivateId);
            return maxLessonId == lesson.PrivateId;
        }

        public async Task<int> GetNextLessonForLessonId(int lessonId)
        {
            Lesson? lesson = await GetLessonByIDAsync(lessonId) ?? throw new EntityNotFoundException($"Lesson with id {lessonId} not found.");
            return lesson.PrivateId + 1;
        }

        public async Task<Lesson> CreateLessonAsync(LessonCreationDTO lesson)
        {
            Lesson createdLesson = await _lessonsRepository.CreateAsync(lesson);
            return createdLesson;
        }

        public async Task<Lesson> UpdateLessonAsync(int id, LessonCreationDTO lesson)
        {
            Lesson updatedGroup = await _lessonsRepository.UpdateAsync(id, lesson);
            return updatedGroup;
        }

        public async Task DeleteLessonAsync(int id)
        {
            await _lessonsRepository.DeleteAsync(id);
        }

        public int FirstLessonId => 10001;
    }
}
