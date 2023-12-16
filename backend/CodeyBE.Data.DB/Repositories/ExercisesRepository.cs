using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Repositories
{
    public class ExercisesRepository(IMongoDbContext dbContext) : Repository<Exercise>(dbContext, "exercises"), IExercisesRepository
    {
        public override async Task<Exercise?> GetByIdAsync(int id)
        {
            return await _collection.Find(exercise => exercise.PrivateId == id).FirstOrDefaultAsync();
        }

        public IEnumerable<Exercise> GetExercisesByID(IEnumerable<int> ids)
        {
            return _collection.Find(exercise => ids.Contains(exercise.PrivateId)).ToList();
        }
    }
}
