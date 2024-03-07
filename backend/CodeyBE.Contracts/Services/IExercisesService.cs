using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
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
                "MC" => new ExerciseMC_DTO((ExerciseMC) exercise),
                "SA" => new ExerciseSA_DTO((ExerciseSA) exercise),
                "LA" => new ExerciseLA_DTO((ExerciseLA) exercise),
                "SCW" => new ExerciseSCW_DTO((ExerciseSCW) exercise),
                _ => new ExerciseDTO(exercise),
            };
        }

        Task<Exercise> CreateExerciseAsync(ExerciseCreationDTO exercise);
        Task<Exercise> UpdateExerciseAsync(int id, ExerciseCreationDTO exercise);
        Task DeleteExerciseAsync(int id);
    }
}
