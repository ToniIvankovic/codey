using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.DTOs
{
    public record CourseSummaryDTO(int Id, string Name, string ShortName, string Description)
    {
        public static CourseSummaryDTO FromCourse(Course course) => new(course.PrivateId, course.Name, course.ShortName, course.Description);
    }
}
