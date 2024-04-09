using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface ILessonGroupsService
    {
        public int FirstLessonGroupId { get; }

        public Task<IEnumerable<LessonGroup>> GetAllLessonGroupsAsync();
        public Task<LessonGroup?> GetLessonGroupByIDAsync(int id);
        public Task<LessonGroup?> GetNextLessonGroupForLessonGroupId(int lessonGroupId);
        public Task<LessonGroup> CreateLessonGroupAsync(LessonGroupCreationDTO lessonGroup);
        public Task DeleteLessonGroupAsync(int id);
        public Task<LessonGroup> UpdateLessonGroupAsync(int id, LessonGroupCreationDTO lessonGroup);
        public Task<List<LessonGroup>> UpdateLessonGroupOrderAsync(List<LessonGroupsReorderDTO> lessonGroupOrderList);
    }
}
