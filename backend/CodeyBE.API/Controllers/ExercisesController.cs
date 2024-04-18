using CodeyBe.Services;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
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
    [Authorize(Roles = "STUDENT,CREATOR")]
    public class ExercisesController(
        IExercisesService exercisesService,
        ILogsService loggingService,
        IUserService userService) : ControllerBase
    {

        const string version = "v2";
        private readonly IExercisesService _exercisesService = exercisesService;
        private readonly ILogsService _loggingService = loggingService;
        private readonly IUserService _userService = userService;

        [Authorize(Roles = "CREATOR")]
        [HttpGet(Name = "getAllExercises")]
        [ProducesResponseType(typeof(IEnumerable<object>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<object>> GetAllExercises()
        {
            return (await _exercisesService.GetAllExercisesAsync())
                .Select(exercise => IExercisesService.MapToSpecificExerciseDTOType(exercise))
                .ToList<object>();
        }

        [Authorize(Roles = "CREATOR")]
        [HttpGet("{id}", Name = "getExerciseByID")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<Exercise?> GetExerciseByID(int id)
        {
            return await _exercisesService.GetExerciseByIDAsync(id);
        }


        [Authorize(Roles = "STUDENT,CREATOR")]
        [HttpGet("lesson/{lessonId}", Name = "getExercisesForLesson")]
        [ProducesResponseType(typeof(IEnumerable<object>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<object>> GetExercisesForLesson(int lessonId)
        {
            var user = User;
            _loggingService.RequestedLesson(user, lessonId);
            return (await _exercisesService.GetExercisesForLessonAsync(lessonId))
                .Select(exercise => IExercisesService.MapToSpecificExerciseDTOType(exercise))
                .ToList<object>();
        }

        [Authorize(Roles = "STUDENT")]
        [HttpGet("lesson/adaptive", Name = "getExercisesForAdaptiveLesson")]
        [ProducesResponseType(typeof(IEnumerable<object>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<object>> GetExercisesForAdaptiveLesson(int lessonId)
        {
            var user = User;
            _loggingService.RequestedLesson(user, lessonId);
            var appUser = await _userService.GetUser(user)
                ?? throw new EntityNotFoundException("User not found");
            return (await _exercisesService.GetExercisesForAdaptiveLessonAsync(appUser))
                .Select(exercise => IExercisesService.MapToSpecificExerciseDTOType(exercise))
                .ToList<object>();
        }

        [Authorize(Roles = "STUDENT,CREATOR")]
        [HttpPost("{exerciseId}", Name = "validateAnswer")]
        [ProducesResponseType(typeof(AnswerValidationResultDTO), (int)HttpStatusCode.OK)]
        public async Task<AnswerValidationResultDTO> ValidateAnswer(int exerciseId, [FromBody] Dictionary<string, dynamic> body)
        {
            var answer = body["answer"];
            AnswerValidationResult result = await _exercisesService.ValidateAnswer(exerciseId, answer);
            var exercise = (await _exercisesService.GetExerciseByIDAsync(exerciseId))!;
            //TODO: log the whole exercise
            ApplicationUser applicationUser = await _userService.GetUser(User)
                ?? throw new EntityNotFoundException("User not found");
            _loggingService.AnsweredExercise(applicationUser, exerciseId, result.CorrectAnswers, result.GottenAnswer, result.IsCorrect);
            return new AnswerValidationResultDTO(result);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPost(Name = "createExercise")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> CreateExercise([FromBody] ExerciseCreationDTO exercise)
        {
            try
            {
                return Ok(await _exercisesService.CreateExerciseAsync(exercise));
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("{id}", Name = "updateExercise")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateExercise(int id, [FromBody] ExerciseCreationDTO exercise)
        {
            try
            {
                return Ok(await _exercisesService.UpdateExerciseAsync(id, exercise));
            }
            catch (NoChangesException)
            {
                return StatusCode(204);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpDelete("{id}", Name = "deleteExercise")]
        [ProducesResponseType((int)HttpStatusCode.OK)]
        public async Task<IActionResult> DeleteExercise(int id)
        {
            try
            {

                await _exercisesService.DeleteExerciseAsync(id);
                return Ok();
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpGet("difficulty/suggested/{exerciseId}", Name = "getSuggestedDifficultyForExercise")]
        [ProducesResponseType(typeof(double), (int)HttpStatusCode.OK)]
        public async Task<double> GetSuggestedDifficultyForExercise(int exerciseId)
        {
            return await _exercisesService.GetSuggestedDifficultyForExerciseAsync(exerciseId);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpGet("difficulty/average/{exerciseId}", Name = "getAverageScoresForExercise")]
        [ProducesResponseType(typeof(Dictionary<bool, double>), (int)HttpStatusCode.OK)]
        public async Task<Dictionary<bool, double?>> GetAverageScoresForExercise(int exerciseId)
        {
            return await _exercisesService.GetAverageScoresForExerciseAsync(exerciseId);
        }
    }
}

