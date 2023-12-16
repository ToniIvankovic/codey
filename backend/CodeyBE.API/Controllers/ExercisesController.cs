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
        [ProducesResponseType(typeof(IEnumerable<Exercise>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Exercise>> GetAllLessons()
        {
            return await exercisesService.GetAllExercisesAsync();
        }

        [HttpGet("{id}", Name = "getExerciseByID")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<Exercise?> GetExerciseByID(int id)
        {
            return await exercisesService.GetExerciseByIDAsync(id);
        }

        [HttpGet("lesson/{lessonId}", Name = "getExercisesForLesson")]
        [ProducesResponseType(typeof(IEnumerable<Exercise>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Exercise>> GetExercisesForLesson(int lessonId)
        {
            return await exercisesService.GetExercisesForLessonAsync(lessonId);
        }
    }
}
