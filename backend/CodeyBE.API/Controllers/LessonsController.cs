using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class LessonsController
    {
        const string version = "v2";
        private readonly ILogger<LessonsController> _logger;
        private readonly ILessonsRepository lessonsRepository;

        public LessonsController(ILogger<LessonsController> logger, ILessonsRepository lessonsRepository)
        {
            _logger = logger;
            this.lessonsRepository = lessonsRepository;
        }

        [HttpGet(Name = "getAllLessons")]
        [ProducesResponseType(typeof(IEnumerable<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Lesson>> GetAllLessons()
        {
            return await lessonsRepository.GetAllAsync();
        }

        [HttpGet("{id}", Name = "getLessonByID")]
        [ProducesResponseType(typeof(Lesson), (int)HttpStatusCode.OK)]
        public async Task<Lesson?> GetLessonByID(int id)
        {
            return await lessonsRepository.GetByIdAsync(id);
        }
    }
}
