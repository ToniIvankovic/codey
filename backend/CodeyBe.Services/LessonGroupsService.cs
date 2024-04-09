using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBE.Contracts.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CodeyBE.Contracts.DTOs;

namespace CodeyBe.Services
{
    public class LessonGroupsService(ILessonGroupsRepository lessonGroupsRepository) : ILessonGroupsService
    {
        private readonly ILessonGroupsRepository _lessonGroupsRepository = lessonGroupsRepository;

        public int FirstLessonGroupId => 10001;

        public Task<IEnumerable<LessonGroup>> GetAllLessonGroupsAsync()
        {
            return _lessonGroupsRepository.GetAllAsync();
        }

        public Task<LessonGroup?> GetLessonGroupByIDAsync(int id)
        {
            return _lessonGroupsRepository.GetByIdAsync(id);
        }

        public async Task<LessonGroup?> GetNextLessonGroupForLessonGroupId(int lessonGroupId)
        {
            LessonGroup group = await GetLessonGroupByIDAsync(lessonGroupId) ?? throw new EntityNotFoundException();
            int order = group.Order + 1;
            LessonGroup? nextGroup = await _lessonGroupsRepository.GetLessonGroupByOrderAsync(order);
            return nextGroup;
        }

        public async Task<LessonGroup> CreateLessonGroupAsync(LessonGroupCreationDTO lessonGroup)
        {
            LessonGroup newGroup = await _lessonGroupsRepository.CreateAsync(lessonGroup);
            return newGroup;
        }

        public async Task DeleteLessonGroupAsync(int id)
        {
            await _lessonGroupsRepository.DeleteAsync(id);
        }

        public async Task<LessonGroup> UpdateLessonGroupAsync(int id, LessonGroupCreationDTO lessonGroup)
        {
            LessonGroup updatedGroup = await _lessonGroupsRepository.UpdateAsync(id, lessonGroup);
            return updatedGroup;
        }

        public async Task<List<LessonGroup>> UpdateLessonGroupOrderAsync(List<LessonGroupsReorderDTO> lessonGroupOrderList)
        {
            List<LessonGroup> reorderedGroups = await _lessonGroupsRepository.UpdateOrderAsync(lessonGroupOrderList);
            return reorderedGroups;
        }
    }
}
