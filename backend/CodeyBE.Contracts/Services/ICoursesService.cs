using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.Services
{
    public interface ICoursesService
    {
        Task<IEnumerable<Course>> GetAllCoursesAsync();
        Task<Course> GetCourseByIdAsync(int id);
    }
}
