using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;

namespace CodeyBE.Data.DB.Repositories
{
    public class ExercisesRepository(IMongoDbContext dbContext) : Repository<Exercise>(dbContext, "exercises"), IExercisesRepository
    {

        public override async Task<IEnumerable<Exercise>> GetAllAsync()
        {
            return (await base.GetAllAsync())
                .Select(ex => IExercisesRepository.MapToSpecificExerciseType(ex));
        }

        public override async Task<Exercise?> GetByIdAsync(int id)
        {
            Exercise? ex = await _collection
                .Find(exercise => exercise.PrivateId == id)
                .FirstOrDefaultAsync();
            if (ex == null)
            {
                return null;
            }

            return IExercisesRepository.MapToSpecificExerciseType(ex);
        }

        public IEnumerable<Exercise> GetExercisesByID(IEnumerable<int> ids)
        {
            return _collection
                .Find(exercise => ids.Contains(exercise.PrivateId))
                .ToList()
                .OrderBy(ex => ids.ToList().IndexOf(ex.PrivateId))
                .Select(ex => IExercisesRepository.MapToSpecificExerciseType(ex));
        }

        public async Task<Exercise> CreateAsync(ExerciseCreationDTO exercise)
        {
            int nextId = _collection
                .AsQueryable()
                .OrderByDescending(exercise => exercise.PrivateId)
                .FirstOrDefault()!.PrivateId + 1;
            Exercise newExercise = new(nextId, exercise);
            await _collection.InsertOneAsync(newExercise);
            return (await GetByIdAsync(nextId))!;
        }
        public async Task<Exercise> UpdateAsync(int id, ExerciseCreationDTO exercise)
        {
            Exercise existing = await _collection.Find(e => e.PrivateId == id).FirstOrDefaultAsync()
                ?? throw new EntityNotFoundException("Entity not found");

            Exercise replacement = new(id, exercise) { Id = existing.Id };

            ReplaceOneResult result = await _collection.ReplaceOneAsync(e => e.PrivateId == id, replacement);

            if (!result.IsAcknowledged)
            {
                throw new Exception("Update failed");
            }
            if (result.MatchedCount == 0)
            {
                throw new EntityNotFoundException("Entity not found");
            }
            if (result.ModifiedCount == 0)
            {
                throw new NoChangesException("No changes made");
            }

            return (await GetByIdAsync(id))!;
        }

        public async Task DeleteAsync(int id)
        {
            DeleteResult deleteResult = await _collection.DeleteOneAsync(exercise => exercise.PrivateId == id);
            if (!deleteResult.IsAcknowledged || deleteResult.DeletedCount == 0)
            {
                throw new EntityNotFoundException("Delete failed");
            }
        }

        public async Task<IEnumerable<Exercise>> GetAllAsync(int courseId)
        {
            return (await base.GetAllAsync())
                .Where(ex => ex.CourseId == courseId).ToList()
                .Select(ex => IExercisesRepository.MapToSpecificExerciseType(ex));
        }
    }
}
