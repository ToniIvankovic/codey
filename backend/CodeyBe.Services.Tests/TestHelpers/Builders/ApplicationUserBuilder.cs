namespace CodeyBe.Services.Tests.TestHelpers.Builders;

public class ApplicationUserBuilder
{
    private readonly ApplicationUser _user = new()
    {
        Email = "student@school.hr",
        UserName = "student@school.hr",
        NormalizedEmail = "STUDENT@SCHOOL.HR",
        NormalizedUserName = "STUDENT@SCHOOL.HR",
        Roles = ["STUDENT"],
        School = "Test School",
        CourseId = 1,
        TotalXP = 0,
        Score = 1,
        XPachieved = [],
        Quests = [],
        NextLessonId = 1,
        NextLessonGroupId = 1,
    };

    public ApplicationUserBuilder WithEmail(string email)
    {
        _user.Email = email;
        _user.UserName = email;
        _user.NormalizedEmail = email.ToUpperInvariant();
        _user.NormalizedUserName = email.ToUpperInvariant();
        return this;
    }

    public ApplicationUserBuilder WithSchool(string? school) { _user.School = school; return this; }
    public ApplicationUserBuilder WithRoles(params string[] roles) { _user.Roles = [.. roles]; return this; }
    public ApplicationUserBuilder WithCourseId(int courseId) { _user.CourseId = courseId; return this; }
    public ApplicationUserBuilder WithCourse(Course course) { _user.CourseId = course.PrivateId; _user.Course = course; return this; }
    public ApplicationUserBuilder WithTotalXP(int xp) { _user.TotalXP = xp; return this; }
    public ApplicationUserBuilder WithScore(double score) { _user.Score = score; return this; }

    public ApplicationUserBuilder WithXPachieved(DateTime date, int xp)
    {
        _user.XPachieved.Add(new KeyValuePair<DateTime, int>(date, xp));
        return this;
    }

    public ApplicationUserBuilder WithHighestLesson(int lessonId, int lessonGroupId)
    {
        _user.HighestLessonId = lessonId;
        _user.HighestLessonGroupId = lessonGroupId;
        return this;
    }

    public ApplicationUserBuilder WithNextLesson(int lessonId, int lessonGroupId)
    {
        _user.NextLessonId = lessonId;
        _user.NextLessonGroupId = lessonGroupId;
        return this;
    }

    public ApplicationUserBuilder WithQuestsForToday(params Quest[] quests)
    {
        _user.Quests ??= [];
        _user.Quests.Add(new KeyValuePair<DateOnly, ISet<Quest>>(
            DateOnly.FromDateTime(DateTime.Now),
            new HashSet<Quest>(quests)));
        return this;
    }

    public ApplicationUser Build() => _user;
}
