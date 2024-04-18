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
        public async Task<IEnumerable<UserDataDTO>> GetAllStudentsForTeacher()
        {
            return await Task.WhenAll(
                (await interactionService.GetAllStudentsForTeacher(User))
                .Select(async student => await ConstructUserDataDTO(student))
            );
        }

        [HttpGet("students", Name = "getStudentByQuery")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(IEnumerable<ApplicationUser>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<UserDataDTO>> GetStudentsByQuery([FromQuery] string? query)
        {
            return await Task.WhenAll(
                (await interactionService.GetStudentByQuery(User, query))
                .Select(async student => await ConstructUserDataDTO(student))
            ); ;
        }

        private async Task<UserDataDTO> ConstructUserDataDTO(ApplicationUser student)
        {
            var dto = UserDataDTO.FromUser(student);
            dto.ClassId = (await interactionService.GetClassForStuedntByTeacher(User, student.UserName!))?.PrivateId;
            return dto;
        }

        [HttpPost("classes", Name = "createClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(Class), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> CreateClass([FromBody] ClassCreationDTO classCreationDTO)
        {
            try
            {

                return Ok(await interactionService.CreateClass(User, classCreationDTO));
            }
            catch (UnauthorizedAccessException e)
            {
                return StatusCode(StatusCodes.Status403Forbidden, e.Message);
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(StatusCodes.Status404NotFound, e.Message);
            }
            catch (Exception e) when (e is MissingFieldException || e is InvalidDataException)
            {
                return StatusCode(StatusCodes.Status400BadRequest, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, e.Message);
            }
        }

        [HttpPut("classes/{id}", Name = "updateClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(Class), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> UpdateClass([FromRoute] int id, [FromBody] ClassCreationDTO classCreationDTO)
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

        [HttpGet("schools", Name = "getAllSchools")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        public async Task<IEnumerable<string>> GetAllSchools()
        {
            return await Task.FromResult(new List<string> { "School11", "School22", "School33" });
        }

        [HttpGet("classes/my", Name = "getClassForStudentSelf")]
        [Authorize(Roles = "STUDENT")]
        [ProducesResponseType(typeof(Class), (int)HttpStatusCode.OK)]
        public async Task<Class?> GetClassForStudentSelf()
        {
            return await interactionService.GetClassForStudentSelf(User, User.Identity?.Name!);
        }

        [HttpGet("leaderboard", Name = "getLeaderboardForStudentSelf")]
        [Authorize(Roles = "STUDENT")]
        [ProducesResponseType(typeof(Leaderboard), (int)HttpStatusCode.OK)]
        public async Task<IActionResult> GetLeaderboardForStudentSelf()
        {
            try
            {

                return Ok(await interactionService.GetLeaderboardForStudentSelf(User));
            }
            catch (EntityNotFoundException e)
            {
                return StatusCode(StatusCodes.Status404NotFound, e.Message);
            }
            catch (Exception e)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, e.Message);
            }
        }

        [HttpGet("leaderboard/{classId}", Name = "getLeaderboardForClass")]
        [Authorize(Roles = "TEACHER")]
        [ProducesResponseType(typeof(Leaderboard), (int)HttpStatusCode.OK)]
        public async Task<Leaderboard> GetLeaderboardForClass([FromRoute] int classId)
        {
            return await interactionService.GetLeaderboardForClass(User, classId);
        }
    }
}
