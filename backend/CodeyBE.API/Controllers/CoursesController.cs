using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CoursesController(ICoursesService coursesService) : ControllerBase
    {
        [AllowAnonymous]
        [HttpGet("", Name = "getAllCourses")]
        public async Task<IEnumerable<CourseSummaryDTO>> GetAllCourses()
        {
            return (await coursesService.GetAllCoursesAsync())
                .Select(CourseSummaryDTO.FromCourse);
        }
    }
}
