using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface IClassesRepository : IRepository<Class>
    {
        public Task<Class> CreateAsync(Class @class);
        public Task<Class> UpdateAsync(int id, Class @class);
        public Task DeleteAsync(int id);
        public Task<IEnumerable<Class>> GetAllClassesForTeacher(string teacherUsername);
    }
}
