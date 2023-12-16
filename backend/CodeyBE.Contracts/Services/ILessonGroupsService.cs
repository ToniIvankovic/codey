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
        public Task<IEnumerable<LessonGroup>> GetAllLessonGroupsAsync();
        public Task<LessonGroup?> GetLessonGroupByIDAsync(int id);
    }
}
