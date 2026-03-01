using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;

namespace CodeyBe.Services
{
    public class CoursesService(ICoursesRepository coursesRepository) : ICoursesService
    {
        public async Task<IEnumerable<Course>> GetAllCoursesAsync()
        {
            return await coursesRepository.GetAllAsync();
        }

        public async Task<Course> GetCourseByIdAsync(int id)
        {
            return await coursesRepository.GetByIdAsync(id)
                ?? throw new EntityNotFoundException($"Course with id {id} not found");
        }
    }
}
