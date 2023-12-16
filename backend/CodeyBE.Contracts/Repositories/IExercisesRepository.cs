using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface IExercisesRepository : IRepository<Exercise>
    {
        IEnumerable<Exercise> GetExercisesByID(IEnumerable<int> ids);
    }
}
