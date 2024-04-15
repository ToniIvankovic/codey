using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Enumerations;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface IExercisesService
    {
        public Task<IEnumerable<Exercise>> GetAllExercisesAsync();
        public Task<Exercise?> GetExerciseByIDAsync(int id);
        public Task<IEnumerable<Exercise>> GetExercisesForLessonAsync(int lessonId);

        public Task<AnswerValidationResult> ValidateAnswer(int exerciseId, JsonElement answer);
        public static ExerciseDTO MapToSpecificExerciseDTOType(Exercise exercise)
        {
            return exercise.Type switch
            {
                ExerciseTypes.MULTIPLE_CHOICE => new ExerciseMC_DTO((ExerciseMC)exercise),
                ExerciseTypes.SHORT_ANSWER => new ExerciseSA_DTO((ExerciseSA)exercise),
                ExerciseTypes.LONG_ANSWER => new ExerciseLA_DTO((ExerciseLA)exercise),
                ExerciseTypes.SHORT_CODE_WRITING => new ExerciseSCW_DTO((ExerciseSCW)exercise),
                _ => new ExerciseDTO(exercise),
            };
        }

        Task<Exercise> CreateExerciseAsync(ExerciseCreationDTO exercise);
        Task<Exercise> UpdateExerciseAsync(int id, ExerciseCreationDTO exercise);
        Task DeleteExerciseAsync(int id);
    }
}
