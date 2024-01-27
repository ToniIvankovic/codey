using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using System.Security.Claims;

namespace CodeyBe.Services
{
    public class LessonsService(ILessonsRepository lessonsRepository, ILessonGroupsService lessonGroupsService, ILogsService logsService) : ILessonsService
    {
        private readonly ILessonsRepository _lessonsRepository = lessonsRepository;
        private readonly ILessonGroupsService _lessonGroupsService = lessonGroupsService;
        private readonly ILogsService _logsService = logsService;

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

        public Task EndLessonAsync(ClaimsPrincipal user, EndOfLessonReport lessonReport)
        {
            _logsService.EndOfLesson(user, lessonReport);
            //TODO: save progress in DB
            return Task.CompletedTask;
        }
    }
}
