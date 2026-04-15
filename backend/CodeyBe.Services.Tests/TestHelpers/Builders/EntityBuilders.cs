namespace CodeyBe.Services.Tests.TestHelpers.Builders;

public static class EntityBuilders
{
    public static Lesson Lesson(int id = 1, int courseId = 1, IEnumerable<int>? exercises = null, int? exerciseLimit = null, bool adaptive = false)
    {
        return new Lesson
        {
            PrivateId = id,
            CourseId = courseId,
            Name = $"Lesson {id}",
            Exercises = exercises ?? [10 + id, 20 + id],
            ExerciseLimit = exerciseLimit,
            Adaptive = adaptive ? true : null,
        };
    }

    public static LessonGroup LessonGroup(int id = 1, int courseId = 1, int order = 1, List<int>? lessonIds = null, bool adaptive = false)
    {
        return new LessonGroup
        {
            PrivateId = id,
            CourseId = courseId,
            Order = order,
            LessonIds = lessonIds ?? [1, 2, 3],
            Adaptive = adaptive ? true : null,
            Name = $"LG {id}",
        };
    }

    public static Course Course(int id = 1, int? defaultExerciseLimit = null)
    {
        return new Course
        {
            PrivateId = id,
            Name = $"Course {id}",
            ShortName = $"C{id}",
            Description = "",
            DefaultExerciseLimit = defaultExerciseLimit,
        };
    }

    public static Class Class(int id = 1, string school = "Test School", string teacherEmail = "teacher@school.hr", List<string>? students = null)
    {
        return new Class
        {
            PrivateId = id,
            Name = $"Class {id}",
            School = school,
            TeacherUsername = teacherEmail,
            Students = students ?? [],
        };
    }
}
