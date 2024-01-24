using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface IExercisesService
    {
        public Task<IEnumerable<Exercise>> GetAllExercisesAsync();
        public Task<Exercise?> GetExerciseByIDAsync(int id);
        public Task<IEnumerable<Exercise>> GetExercisesForLessonAsync(int lessonId);

        public Task<AnswerValidationResult> ValidateAnswer(int exerciseId, string answer);
        public ExerciseDTO MapToSpecificExerciseDTOType(Exercise exercise);
    }
}
