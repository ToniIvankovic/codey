using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;

namespace CodeyBe.Services
{
    public class LessonsService : ILessonsService
    {
        private readonly ILessonsRepository _lessonsRepository;
        private readonly ILessonGroupsService _lessonGroupsService;
        public LessonsService(ILessonsRepository lessonsRepository, ILessonGroupsService lessonGroupsService) {
            this._lessonsRepository = lessonsRepository;
            this._lessonGroupsService = lessonGroupsService;
        }

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
    }
}
