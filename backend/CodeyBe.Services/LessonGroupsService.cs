using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBE.Contracts.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBe.Services
{
    public class LessonGroupsService : ILessonGroupsService
    {
        private readonly ILessonGroupsRepository _lessonGroupsRepository;
        public LessonGroupsService(ILessonGroupsRepository lessonGroupsRepository) { 
            this._lessonGroupsRepository = lessonGroupsRepository;
        }

        public Task<IEnumerable<LessonGroup>> GetAllLessonGroupsAsync()
        {
            return _lessonGroupsRepository.GetAllAsync();
        }

        public Task<LessonGroup?> GetLessonGroupByIDAsync(int id)
        {
            return _lessonGroupsRepository.GetByIdAsync(id);
        }

        public async Task<int> GetNextLessonGroupForLessonGroupId(int lessonGroupId)
        {
            LessonGroup group = await GetLessonGroupByIDAsync(lessonGroupId) ?? throw new EntityNotFoundException();
            return group.PrivateId + 1;
        }

        public int FirstLessonGroupId => 10001;
    }
}
