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
    [Authorize(Roles = "STUDENT")]
    public class LessonsController(ILessonsService lessonsService)
    {
        const string version = "v2";
        private readonly ILessonsService lessonsService = lessonsService;

        [HttpGet(Name = "getAllLessons")]
        [ProducesResponseType(typeof(IEnumerable<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Lesson>> GetAllLessons()
        {
            return await lessonsService.GetAllLessonsAsync();
        }

        [HttpGet("{id}", Name = "getLessonByID")]
        [ProducesResponseType(typeof(Lesson), (int)HttpStatusCode.OK)]
        public async Task<Lesson?> GetLessonByID(int id)
        {
            return await lessonsService.GetLessonByIDAsync(id);
        }

        [HttpGet("lessonGroup/{lessonGroupId}", Name = "getLessonsForLessonGroup")]
        [ProducesResponseType(typeof(IEnumerable<Lesson>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Lesson>> GetLessonsForLessonGroup(int lessonGroupId)
        {
            return await lessonsService.GetLessonsForLessonGroupAsync(lessonGroupId);
        }
    }
}
