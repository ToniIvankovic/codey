using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
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
        private readonly IExercisesRepository exercisesRepository;

        public ExercisesController(ILogger<ExercisesController> logger, IExercisesRepository exercisesRepository)
        {
            _logger = logger;
            this.exercisesRepository = exercisesRepository;
        }

        [HttpGet(Name = "getAllExercises")]
        [ProducesResponseType(typeof(IEnumerable<Exercise>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Exercise>> GetAllLessons()
        {
            return await exercisesRepository.GetAllAsync();
        }

        [HttpGet("{id}", Name = "getExerciseByID")]
        [ProducesResponseType(typeof(Exercise), (int)HttpStatusCode.OK)]
        public async Task<Exercise?> GetExerciseByID(int id)
        {
            return await exercisesRepository.GetByIdAsync(id);
        }
    }
}
