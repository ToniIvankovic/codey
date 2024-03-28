using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface ILessonsRepository : IRepository<Lesson>
    {
        Task<Lesson> CreateAsync(LessonCreationDTO lesson);
        Task DeleteAsync(int id);
        Task<List<Lesson>> GetLessonsByIDsAsync(List<int> id);
        Task<Lesson> UpdateAsync(int id, LessonCreationDTO lesson);
    }
}
