using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class LessonGroupsController : ControllerBase
    {
        const string version = "v2";
        private readonly ILogger<LessonGroupsController> _logger;
        private readonly ILessonGroupsService lessonGroupsService;

        public LessonGroupsController(ILogger<LessonGroupsController> logger, ILessonGroupsService lessonGroupsService)
        {
            this.lessonGroupsService = lessonGroupsService;
            _logger = logger;
        }


        [HttpGet(Name = "getAllLessonGroups")]
        [ProducesResponseType(typeof(IEnumerable<LessonGroup>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<LessonGroup>> GetAllLessonGroups()
        {
            return await lessonGroupsService.GetAllLessonGroupsAsync();
        }

        [HttpGet("{id}", Name = "getLessonGroupByID")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<LessonGroup?> GetLessonGroupByID(int id)
        {
            return await lessonGroupsService.GetLessonGroupByIDAsync(id);
        }
    }
}
