using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ExercisesController
    {

        const string version = "v2";
        private readonly ILogger<ExercisesController> _logger;
        private readonly IExercisesService exercisesService;

        public ExercisesController(ILogger<ExercisesController> logger, IExercisesService exercisesService)
        {
            _logger = logger;
            this.exercisesService = exercisesService;
        }

        [HttpGet(Name = "getAllExercises")]
        [ProducesResponseType(typeof(IEnumerable<ExerciseDTO>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<ExerciseDTO>> GetAllExercises()
        {
            return (await exercisesService.GetAllExercisesAsync()).Select(exercise =>
            {
                if (exercise.Type == "MC")
                {
                    return new ExerciseMC_DTO(exercise);
                }
                else if (exercise.Type == "SA")
                {
                    return new ExerciseSA_DTO(exercise);
                }
                else if (exercise.Type == "LA")
                {
                    return new ExerciseLA_DTO(exercise);
                }
                else
                {
                    return new ExerciseDTO(exercise);
                }
            });
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
            return (await exercisesService.GetExercisesForLessonAsync(lessonId)).Select<Exercise, object>(exercise =>
            {
                if (exercise.Type == "MC")
                {
                    return new ExerciseMC_DTO(exercise);
                }
                else if (exercise.Type == "SA")
                {
                    return new ExerciseSA_DTO(exercise);
                }
                else if (exercise.Type == "LA")
                {
                    return new ExerciseLA_DTO(exercise);
                }
                else
                {
                    throw new Exception("Unknown exercise type");
                }
            }); ;
        }

        [HttpPost("{exerciseId}", Name = "validateAnswer")]
        [ProducesResponseType(typeof(AnswerValidationResultDTO), (int)HttpStatusCode.OK)]
        public async Task<AnswerValidationResultDTO> ValidateAnswer(string exerciseId, [FromBody]Dictionary<string,string> body)
        {
            var answer = body["answer"];
            var result = await exercisesService.ValidateAnswer(exerciseId, answer);
            return new AnswerValidationResultDTO(result);
        }
    }
}
