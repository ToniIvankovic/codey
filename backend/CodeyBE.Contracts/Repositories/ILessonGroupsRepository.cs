using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface ILessonGroupsRepository : IRepository<LessonGroup>
    {
        public Task<LessonGroup?> GetLessonGroupByOrderAsync(int order);
        Task<LessonGroup> CreateAsync(LessonGroupCreationDTO lessonGroup);
        Task DeleteAsync(int id);
        Task<LessonGroup> UpdateAsync(int id, LessonGroupCreationDTO lessonGroup);
        Task<List<LessonGroup>> UpdateOrderAsync(List<LessonGroupsReorderDTO> lessonGroupOrderList);
    }
}
