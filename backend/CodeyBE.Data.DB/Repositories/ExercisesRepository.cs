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
            var updateDefinition = Builders<Exercise>.Update;
            UpdateDefinition<Exercise>? updates = null;

            updates = updateDefinition.Set(e => e.Type, exercise.Type)
                .Set(e => e.Difficulty, exercise.Difficulty);
            if (exercise.Statement != null)
            {
                updates = updates.Set(e => e.Statement, exercise.Statement);
            }
            if (exercise.StatementCode != null)
            {
                updates = updates.Set(e => e.StatementCode, exercise.StatementCode);
            }
            if (exercise.DefaultGapLengths != null)
            {
                updates = updates.Set(e => e.DefaultGapLengths, exercise.DefaultGapLengths);
            }
            if (exercise.StatementOutput != null)
            {
                updates = updates.Set(e => e.StatementOutput, exercise.StatementOutput);
            }
            if (exercise.Question != null)
            {
                updates = updates.Set(e => e.Question, exercise.Question);
            }
            if (exercise.AnswerOptions != null)
            {
                updates = updates.Set(e => e.AnswerOptions, exercise.AnswerOptions);
            }
            if (exercise.CorrectAnswer != null)
            {
                updates = updates.Set(e => e.CorrectAnswer, exercise.CorrectAnswer);
            }
            if (exercise.CorrectAnswers != null)
            {
                updates = updates.Set(e => e.CorrectAnswers, exercise.CorrectAnswers);
            }
            if (exercise.RaisesError != null)
            {
                updates = updates.Set(e => e.RaisesError, exercise.RaisesError);
            }
            if (exercise.SpecificTip != null)
            {
                updates = updates.Set(e => e.SpecificTip, exercise.SpecificTip);
            }

            UpdateResult updateResult = await _collection.UpdateOneAsync(e => e.PrivateId == id, updates);

            if (!updateResult.IsAcknowledged)
            {
                throw new Exception("Update failed");
            }
            if(updateResult.MatchedCount == 0)
            {
                throw new EntityNotFoundException("Entity not found");
            }
            if (updateResult.ModifiedCount == 0)
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
    }
}
