using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class LessonGroupsController : ControllerBase
    {
        const string version = "v2";
        private readonly ILessonGroupsRepository lessonGroupsRepository;
        private readonly ILogger<LessonGroupsController> _logger;

        public LessonGroupsController(ILogger<LessonGroupsController> logger, ILessonGroupsRepository lgRepo)
        {
            lessonGroupsRepository = lgRepo;
            _logger = logger;
        }


        [HttpGet(Name = "getAllLessonGroups")]
        [ProducesResponseType(typeof(IEnumerable<LessonGroup>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<LessonGroup>> GetAllLessonGroups()
        {
            return await lessonGroupsRepository.GetAllAsync();
        }

        [HttpGet("{id}", Name = "getLessonGroupByID")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<LessonGroup?> GetLessonGroupByID(int id)
        {
            return await lessonGroupsRepository.GetByIdAsync(id);
        }
    }
}
