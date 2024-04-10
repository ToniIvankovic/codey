using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CodeyBE.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    [Authorize]
    public class InteractionController(IInteractionService interactionService) : ControllerBase
    {
        private readonly IInteractionService interactionService = interactionService;

        [HttpGet("students/all", Name ="getStudentsForTeacher")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<ApplicationUser>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<ApplicationUser>> GetAllStudentsForTeacher()
        {
            return await interactionService.GetAllStudentsForTeacher(User);
        }

        [HttpGet("students", Name = "getStudentById")]
        [Authorize(Roles ="TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<ApplicationUser>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<ApplicationUser>> GetStudentById([FromQuery] string? query)
        {
            return await interactionService.GetStudentByQuery(User, query);
        }
    }
}
