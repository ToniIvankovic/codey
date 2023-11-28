using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class LessonGroupsController : ControllerBase
    {
        private readonly ILessonGroupsRepository lessonGroupsRepository;
        private readonly ILogger<LessonGroupsController> _logger;

        public LessonGroupsController(ILogger<LessonGroupsController> logger, ILessonGroupsRepository lgRepo)
        {
            lessonGroupsRepository = lgRepo;
            _logger = logger;
        }


        [HttpGet(Name = "GetLessonGroups")]
        public async Task<IEnumerable<LessonGroup>> Get()
        {
            return await lessonGroupsRepository.GetAllAsync();
        }
    }
}
