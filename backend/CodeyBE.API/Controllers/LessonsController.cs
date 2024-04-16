using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "STUDENT,CREATOR")]
    public class LessonsController(ILessonsService lessonsService) : ControllerBase
    {
        const string version = "v2";
        private readonly ILessonsService lessonsService = lessonsService;

        [Authorize(Roles = "CREATOR")]
        [HttpGet("all", Name = "getAllLessons")]
        [ProducesResponseType(typeof(IEnumerable<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Lesson>> GetAllLessons()
        {
            return await lessonsService.GetAllLessonsAsync();
        }

        //[Authorize(Roles = "CREATOR")]
        //[HttpGet("{id}", Name = "getLessonByID")]
        //[ProducesResponseType(typeof(Lesson), (int)HttpStatusCode.OK)]
        //public async Task<Lesson?> GetLessonByID(int id)
        //{
        //    return await lessonsService.GetLessonByIDAsync(id);
        //}

        [Authorize(Roles = "CREATOR,STUDENT")]
        [HttpGet(Name = "getLessonsByID")]
        [ProducesResponseType(typeof(List<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<List<Lesson>> GetLessonsByIDs([FromQuery] List<int> ids)
        {
            return await lessonsService.GetLessonsByIDsAsync(ids);
        }



        [Authorize(Roles = "STUDENT,CREATOR")]
        [HttpGet("lessonGroup/{lessonGroupId}", Name = "getLessonsForLessonGroup")]
        [ProducesResponseType(typeof(IEnumerable<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Lesson>> GetLessonsForLessonGroup(int lessonGroupId)
        {
            return await lessonsService.GetLessonsForLessonGroupAsync(lessonGroupId);
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPost(Name = "createLesson")]
        [ProducesResponseType(typeof(Lesson), (int)HttpStatusCode.Created)]
        public async Task<IActionResult> CreateLesson([FromBody] LessonCreationDTO lesson)
        {
            return Ok(await lessonsService.CreateLessonAsync(lesson));
        }

        [Authorize(Roles = "CREATOR")]
        [HttpPut("{id}", Name = "updateLesson")]
        [ProducesResponseType(typeof(Lesson), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateLesson(int id, [FromBody] LessonCreationDTO lesson)
        {
            try
            {
                return Ok(await lessonsService.UpdateLessonAsync(id, lesson));
            }
            catch (EntityNotFoundException e)
            {
                return NotFound(e.Message);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [Authorize(Roles = "CREATOR")]
        [HttpDelete("{id}", Name = "deleteLesson")]
        [ProducesResponseType((int)HttpStatusCode.NoContent)]
        public async Task<IActionResult> DeleteLesson(int id)
        {
            try
            {
                await lessonsService.DeleteLessonAsync(id);
                return Ok();
            }
            catch (Exception e)
            {
                return NotFound(e.Message);
            }
        }
    }
}
