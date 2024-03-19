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
            return (await GetAllLessonsAsync())
                .Where(lesson => lessonGroup.LessonIds.Contains(lesson.PrivateId))
                .OrderBy(lesson => lessonGroup.LessonIds.IndexOf(lesson.PrivateId));
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

        public async Task<List<Lesson>> GetLessonsByIDsAsync(List<int> ids)
        {
            return await _lessonsRepository.GetLessonsByIDsAsync(ids);
        }

        public int FirstLessonId => 10001;
    }
}
