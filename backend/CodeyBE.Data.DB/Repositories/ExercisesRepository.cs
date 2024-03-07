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
            Exercise newExercise = new Exercise(nextId, exercise);
            await _collection.InsertOneAsync(newExercise);
            return (await GetByIdAsync(nextId))!;
        }
        public async Task<Exercise> UpdateAsync(int id, ExerciseCreationDTO exercise)
        {

            UpdateResult updateResult = await _collection.UpdateOneAsync(
                                exercise => exercise.PrivateId == id,
                                Builders<Exercise>.Update
                                .Set(exercise => exercise.Type, exercise.Type)
                                .Set(exercise => exercise.Difficulty, exercise.Difficulty)
                                .Set(exercise => exercise.Statement, exercise.Statement)
                                .Set(exercise => exercise.StatementCode, exercise.StatementCode)
                                .Set(exercise => exercise.DefaultGapLengths, exercise.DefaultGapLengths)
                                .Set(exercise => exercise.DefaultGapLines, exercise.DefaultGapLines)
                                .Set(exercise => exercise.StatementOutput, exercise.StatementOutput)
                                .Set(exercise => exercise.Question, exercise.Question)
                                .Set(exercise => exercise.AnswerOptions, exercise.AnswerOptions)
                                .Set(exercise => exercise.CorrectAnswer, exercise.CorrectAnswer)
                                .Set(exercise => exercise.CorrectAnswers, exercise.CorrectAnswers)
                                .Set(exercise => exercise.RaisesError, exercise.RaisesError)
                                .Set(exercise => exercise.SpecificTip, exercise.SpecificTip)
                                );
            if (!updateResult.IsAcknowledged || updateResult.MatchedCount == 0)
            {
                throw new EntityNotFoundException("Update failed");
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
