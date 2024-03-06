using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{

    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "STUDENT,CREATOR")]
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

        [Authorize(Roles = "CREATOR")]
        [HttpGet("{id}", Name = "getLessonGroupByID")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<LessonGroup?> GetLessonGroupByID(int id)
        {
            return await lessonGroupsService.GetLessonGroupByIDAsync(id);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPost(Name = "createLessonGroup")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> CreateLessonGroup([FromBody] LessonGroupCreationDTO lessonGroup)
        {
            var result = await lessonGroupsService.CreateLessonGroupAsync(lessonGroup);
            return Ok(result);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("{id}", Name = "updateLessonGroup")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateLessonGroup(int id, [FromBody] LessonGroupCreationDTO lessonGroup)
        {
            try
            {
                var result = await lessonGroupsService.UpdateLessonGroupAsync(id, lessonGroup);
                return Ok(result);
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpDelete("{id}", Name = "deleteLessonGroup")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> DeleteLessonGroup(int id)
        {

            try
            {
                await lessonGroupsService.DeleteLessonGroupAsync(id);
                return Ok();
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }

    }
}
