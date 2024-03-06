using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Text.Json;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "STUDENT")]
    public class ExercisesController(IExercisesService exercisesService, ILogsService loggingService) : ControllerBase
    {

        const string version = "v2";
        private readonly IExercisesService exercisesService = exercisesService;
        private readonly ILogsService loggingService = loggingService;

        [HttpGet(Name = "getAllExercises")]
        [ProducesResponseType(typeof(IEnumerable<object>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<object>> GetAllExercises()
        {
            return (await exercisesService.GetAllExercisesAsync())
                .Select(exercise => IExercisesService.MapToSpecificExerciseDTOType(exercise))
                .ToList<object>();
        }

        [HttpGet("{id}", Name = "getExerciseByID")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<Exercise?> GetExerciseByID(int id)
        {
            return await exercisesService.GetExerciseByIDAsync(id);
        }


        [HttpGet("lesson/{lessonId}", Name = "getExercisesForLesson")]
        [ProducesResponseType(typeof(IEnumerable<object>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<object>> GetExercisesForLesson(int lessonId)
        {
            var user = User;
            loggingService.RequestedLesson(user, lessonId);
            return (await exercisesService.GetExercisesForLessonAsync(lessonId))
                .Select(exercise => IExercisesService.MapToSpecificExerciseDTOType(exercise))
                .ToList<object>();
        }

        [HttpPost("{exerciseId}", Name = "validateAnswer")]
        [ProducesResponseType(typeof(AnswerValidationResultDTO), (int)HttpStatusCode.OK)]
        public async Task<AnswerValidationResultDTO> ValidateAnswer(int exerciseId, [FromBody] Dictionary<string, dynamic> body)
        {
            var answer = body["answer"];
            AnswerValidationResult result = await exercisesService.ValidateAnswer(exerciseId, answer);
            var exercise = (await exercisesService.GetExerciseByIDAsync(exerciseId))!;
            //TODO: log the whole exercise
            loggingService.AnsweredExercise(User, exerciseId, result.CorrectAnswers, result.GottenAnswer, result.IsCorrect);
            return new AnswerValidationResultDTO(result);
        }
    }
}
