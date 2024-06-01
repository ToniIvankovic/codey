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
    [Authorize(Roles = "STUDENT,CREATOR,TEACHER")]
    public class LessonGroupsController(ILessonGroupsService lessonGroupsService) : ControllerBase
    {
        const string version = "v2";
        private readonly ILessonGroupsService _lessonGroupsService = lessonGroupsService;

        [HttpGet(Name = "getAllLessonGroups")]
        [ProducesResponseType(typeof(IEnumerable<LessonGroup>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<LessonGroup>> GetAllLessonGroups()
        {
            return await _lessonGroupsService.GetAllLessonGroupsAsync();
        }

        [Authorize(Roles = "CREATOR,TEACHER")]
        [HttpGet("{id}", Name = "getLessonGroupByID")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<LessonGroup?> GetLessonGroupByID(int id)
        {
            return await _lessonGroupsService.GetLessonGroupByIDAsync(id);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPost(Name = "createLessonGroup")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> CreateLessonGroup([FromBody] LessonGroupCreationDTO lessonGroup)
        {
            return Ok(await _lessonGroupsService.CreateLessonGroupAsync(lessonGroup));
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("{id}", Name = "updateLessonGroup")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateLessonGroup(int id, [FromBody] LessonGroupCreationDTO lessonGroup)
        {
            try
            {
                return Ok(await _lessonGroupsService.UpdateLessonGroupAsync(id, lessonGroup));
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("", Name = "updateLessonGroupsOrder")]
        [ProducesResponseType(typeof(LessonGroup), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateLessonGroupsOrder([FromBody] List<LessonGroupsReorderDTO> lessonGroupOrderList)
        {
            try
            {
                return Ok(await _lessonGroupsService.UpdateLessonGroupOrderAsync(lessonGroupOrderList));
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
                await _lessonGroupsService.DeleteLessonGroupAsync(id);
                return Ok();
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }

    }
}
