using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.DTOs
{
    public record CourseSummaryDTO(int Id, string Name, string ShortName, string Description, int? DefaultExerciseLimit, bool ScwTextWrap)
    {
        public static CourseSummaryDTO FromCourse(Course course) => new(course.PrivateId, course.Name, course.ShortName, course.Description, course.DefaultExerciseLimit, course.ScwTextWrap);
    }
}
