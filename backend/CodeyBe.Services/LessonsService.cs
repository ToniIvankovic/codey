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
            LessonGroup? lessonGroup = await _lessonGroupsService.GetLessonGroupByIDAsync(lessonGroupId)
                ?? throw new EntityNotFoundException("Lesson group not found");
            if (lessonGroup.Adaptive ?? false)
            {
                return await Task.FromResult(GetLessonsForAdaptiveLessonGroupAsync(lessonGroup));
            }
            return (await GetAllLessonsAsync())
                .Where(lesson => lessonGroup.LessonIds.Contains(lesson.PrivateId))
                .OrderBy(lesson => lessonGroup.LessonIds.IndexOf(lesson.PrivateId));
        }

        private static List<Lesson> GetLessonsForAdaptiveLessonGroupAsync(LessonGroup lessonGroup)
        {
            return [
                new()
                {
                    PrivateId = 99998,
                    Name = "Adaptivna lekcija 1",
                    Adaptive = true,
                },
                new()
                {
                    PrivateId = 99999,
                    Name = "Adaptivna lekcija 2",
                    Adaptive = true,
                },
            ];
        }

        public async Task<int> GetNextLessonIdForLessonId(int lessonId, LessonGroup lessonGroup)
        {
            List<int> lessonsInCurrentGroup = [.. lessonGroup.LessonIds];
            int currentIndex = lessonsInCurrentGroup.IndexOf(lessonId);
            if (currentIndex < lessonsInCurrentGroup.Count - 1)
            {
                return lessonsInCurrentGroup[currentIndex + 1];
            }
            LessonGroup? nextLessonGroup = await _lessonGroupsService.GetNextLessonGroupForLessonGroupId(lessonGroup.PrivateId)
                ?? throw new EntityNotFoundException("Next lesson group not found");
            if (nextLessonGroup.Adaptive ?? false)
            {
                return GetLessonsForAdaptiveLessonGroupAsync(nextLessonGroup)[0].PrivateId;
            }
            return nextLessonGroup.LessonIds[0];
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

        public async Task<int> GetFirstLessonIdAsync()
        {
            var lgr = await _lessonGroupsService.GetFirstLessonGroupIdAsync();
            var lesson = (await GetLessonsForLessonGroupAsync(lgr)).FirstOrDefault();
            if (lesson == null)
            {
                throw new EntityNotFoundException("No lessons found");
            }
            return lesson?.PrivateId ?? throw new EntityNotFoundException("No lessons found");
        }

    }
}
