using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
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

        [HttpGet("students/all", Name = "getStudentsForTeacher")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<ApplicationUser>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<ApplicationUser>> GetAllStudentsForTeacher()
        {
            return await interactionService.GetAllStudentsForTeacher(User);
        }

        [HttpGet("students", Name = "getStudentById")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<ApplicationUser>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<ApplicationUser>> GetStudentsByQuery([FromQuery] string? query)
        {
            return await interactionService.GetStudentByQuery(User, query);
        }

        [HttpPost("classes", Name = "createClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(Class), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> CreateClass([FromBody] ClassCreationDTO classCreationDTO)
        {
            return Ok(await interactionService.CreateClass(User, classCreationDTO));
        }

        [HttpPut("classes/{id}", Name = "updateClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(Class), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateClass([FromRoute] int id,[FromBody] ClassCreationDTO classCreationDTO)
        {
            try
            {
                return Ok(await interactionService.UpdateClass(User, id, classCreationDTO));
            }
            catch (UnauthorizedAccessException e)
            {
                return StatusCode(StatusCodes.Status403Forbidden, e.Message);
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(StatusCodes.Status404NotFound, e.Message);
            }
            catch (MissingFieldException e)
            {
                return StatusCode(StatusCodes.Status400BadRequest, e.Message);
            }
            catch (NoChangesException e)
            {
                return StatusCode(StatusCodes.Status204NoContent, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, e.Message);
            }
        }

        [HttpDelete("classes/{id}", Name = "deleteClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType((int)HttpStatusCode.OK)]
        public async Task<IActionResult> DeleteClass([FromRoute] int id)
        {
            try
            {
                await interactionService.DeleteClass(User, id);
                return Ok();
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(StatusCodes.Status404NotFound, e.Message);
            }
            catch (UnauthorizedAccessException e)
            {
                return StatusCode(StatusCodes.Status403Forbidden, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, e.Message);
            }
        }

        [HttpGet("classes", Name = "getAllClasses")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<Class>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<Class>> GetAllClasses()
        {
            return await interactionService.GetAllClassesForTeacher(User);
        }

    }
}
