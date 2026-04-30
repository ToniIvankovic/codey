using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Enumerations;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Identity;

namespace CodeyBe.Services.Tests.Services;

public class UserServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManager = UserManagerMockFactory.Create();
    private readonly Mock<ITokenGeneratorService> _tokens = new();
    private readonly Mock<ILessonsService> _lessons = new();
    private readonly Mock<IExercisesService> _exercises = new();
    private readonly Mock<ILogsService> _logs = new();
    private readonly Mock<ILessonGroupsService> _lessonGroups = new();
    private readonly Mock<IUsersRepository> _usersRepo = new();
    private readonly Mock<ICoursesService> _courses = new();
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _sut = new UserService(
            _userManager.Object, _tokens.Object, _lessons.Object, _exercises.Object,
            _logs.Object, _lessonGroups.Object, _usersRepo.Object, _courses.Object);

        _userManager.Setup(m => m.UpdateAsync(It.IsAny<ApplicationUser>()))
            .ReturnsAsync(IdentityResult.Success);
    }

    // ------------------- LoginUser -------------------

    [Fact]
    public async Task LoginUser_returns_token_on_happy_path()
    {
        var user = new ApplicationUserBuilder().WithEmail("u@x.hr").WithRoles("STUDENT").Build();
        _userManager.Setup(m => m.FindByEmailAsync("u@x.hr")).ReturnsAsync(user);
        _userManager.Setup(m => m.CheckPasswordAsync(user, "pw")).ReturnsAsync(true);
        _userManager.Setup(m => m.GetClaimsAsync(user)).ReturnsAsync(new List<System.Security.Claims.Claim>());
        _tokens.Setup(t => t.GenerateToken(It.IsAny<IList<System.Security.Claims.Claim>>()))
            .Returns(new JWTTokenDTO { Token = "jwt", ExpiresAt = DateTime.UtcNow.AddHours(1) });

        var dto = await _sut.LoginUser(new UserLoginRequestDTO { Email = "u@x.hr", Password = "pw" });

        dto.Token.Should().Be("jwt");
    }

    [Fact]
    public async Task LoginUser_throws_when_email_unknown()
    {
        _userManager.Setup(m => m.FindByEmailAsync(It.IsAny<string>())).ReturnsAsync((ApplicationUser?)null);

        Func<Task> act = () => _sut.LoginUser(new UserLoginRequestDTO { Email = "nobody@x.hr", Password = "pw" });

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task LoginUser_throws_UserAuthenticationException_on_wrong_password()
    {
        var user = new ApplicationUserBuilder().WithEmail("u@x.hr").Build();
        _userManager.Setup(m => m.FindByEmailAsync("u@x.hr")).ReturnsAsync(user);
        _userManager.Setup(m => m.CheckPasswordAsync(user, "bad")).ReturnsAsync(false);

        Func<Task> act = () => _sut.LoginUser(new UserLoginRequestDTO { Email = "u@x.hr", Password = "bad" });

        await act.Should().ThrowAsync<UserAuthenticationException>();
    }

    // ------------------- Register* -------------------

    [Fact]
    public async Task RegisterStudent_creates_user_with_STUDENT_role()
    {
        _lessonGroups.Setup(s => s.GetFirstLessonGroupIdAsync(1)).ReturnsAsync(1);
        _lessons.Setup(s => s.GetFirstLessonIdAsync(1)).ReturnsAsync(1);
        ApplicationUser? captured = null;
        _userManager.Setup(m => m.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .Callback<ApplicationUser, string>((u, _) => captured = u)
            .ReturnsAsync(IdentityResult.Success);
        _userManager.Setup(m => m.Users).Returns(new List<ApplicationUser>().AsQueryable());

        var result = await _sut.RegisterStudent(new UserRegistrationRequestDTO
        {
            Email = "new@school.hr", Password = "pw", School = "Test School", CourseId = 1, ConsentedToTerms = true,
        });

        result.Succeeded.Should().BeTrue();
        captured!.Roles.Should().Contain("STUDENT");
        captured.Email.Should().Be("new@school.hr");
        captured.CourseId.Should().Be(1);
    }

    [Fact]
    public async Task RegisterCreator_creates_user_with_CREATOR_role()
    {
        _courses.Setup(s => s.GetAllCoursesAsync()).ReturnsAsync([EntityBuilders.Course(1)]);
        ApplicationUser? captured = null;
        _userManager.Setup(m => m.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .Callback<ApplicationUser, string>((u, _) => captured = u)
            .ReturnsAsync(IdentityResult.Success);

        var result = await _sut.RegisterCreator(new StaffRegistrationRequestDTO { Email = "c@x.hr", Password = "pw" });

        result.Succeeded.Should().BeTrue();
        captured!.Roles.Should().Contain("CREATOR");
    }

    [Fact]
    public async Task RegisterTeacher_creates_user_with_TEACHER_role_and_school()
    {
        _courses.Setup(s => s.GetAllCoursesAsync()).ReturnsAsync([EntityBuilders.Course(1)]);
        ApplicationUser? captured = null;
        _userManager.Setup(m => m.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .Callback<ApplicationUser, string>((u, _) => captured = u)
            .ReturnsAsync(IdentityResult.Success);

        var result = await _sut.RegisterTeacher(new StaffRegistrationRequestDTO
        {
            Email = "t@school.hr", Password = "pw", School = "Test School"
        });

        result.Succeeded.Should().BeTrue();
        captured!.Roles.Should().Contain("TEACHER");
        captured.School.Should().Be("Test School");
    }

    // ------------------- GetUser -------------------

    [Fact]
    public async Task GetUser_loads_from_users_repo_by_email()
    {
        var user = new ApplicationUserBuilder().WithEmail("u@x.hr").Build();
        _usersRepo.Setup(r => r.FindByEmailAsync("u@x.hr")).ReturnsAsync(user);

        var result = await _sut.GetUser(ClaimsPrincipalFactory.For("u@x.hr"));

        result.Should().Be(user);
    }

    [Fact]
    public async Task GetUser_throws_when_claims_missing_email()
    {
        Func<Task> act = () => _sut.GetUser(ClaimsPrincipalFactory.WithoutEmail());

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    // ------------------- EndLessonAsync -------------------

    private ApplicationUser StubCurrentUser(string email = "u@x.hr", int nextLessonId = 1)
    {
        var user = new ApplicationUserBuilder()
            .WithEmail(email)
            .WithNextLesson(nextLessonId, 1)
            .Build();
        _usersRepo.Setup(r => r.FindByEmailAsync(email)).ReturnsAsync(user);
        return user;
    }

    private static EndOfLessonReport Report(int lessonId = 1, int lessonGroupId = 1,
        int correct = 5, int total = 5, double accuracy = 1.0, int durationMs = 10_000)
        => new()
        {
            LessonId = lessonId,
            LessonGroupId = lessonGroupId,
            CorrectAnswers = correct,
            TotalAnswers = total,
            Accuracy = accuracy,
            DurationMiliseconds = durationMs,
            AnswersReport = [],
        };

    [Fact]
    public async Task EndLessonAsync_awards_XP_SOLVED_NEW_for_new_lesson()
    {
        var user = StubCurrentUser(nextLessonId: 1);
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [1, 2]);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);
        _lessons.Setup(s => s.GetNextLessonIdForLessonId(1, group)).ReturnsAsync(2);

        var awarded = await _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report(lessonId: 1));

        awarded.Should().Be(100);
        user.HighestLessonId.Should().Be(1);
        user.NextLessonId.Should().Be(2);
    }

    [Fact]
    public async Task EndLessonAsync_awards_XP_SOLVED_OLD_when_replaying_lesson()
    {
        var user = StubCurrentUser(nextLessonId: 2);
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [1, 2]);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);

        var awarded = await _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report(lessonId: 1));

        awarded.Should().Be(40);
    }

    [Fact]
    public async Task EndLessonAsync_throws_when_lesson_not_in_group()
    {
        StubCurrentUser(nextLessonId: 1);
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [1, 2]);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);

        Func<Task> act = () => _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report(lessonId: 99));

        await act.Should().ThrowAsync<InvalidDataException>();
    }

    [Fact]
    public async Task EndLessonAsync_throws_when_user_missing()
    {
        _usersRepo.Setup(r => r.FindByEmailAsync("ghost@x.hr")).ReturnsAsync((ApplicationUser?)null);

        Func<Task> act = () => _sut.EndLessonAsync(ClaimsPrincipalFactory.For("ghost@x.hr"), Report());

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task EndLessonAsync_throws_when_lesson_group_missing()
    {
        StubCurrentUser();
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(It.IsAny<int>())).ReturnsAsync((LessonGroup?)null);

        Func<Task> act = () => _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report());

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task EndLessonAsync_emits_log_via_LogsService()
    {
        var user = StubCurrentUser(nextLessonId: 1);
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [1, 2]);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);
        _lessons.Setup(s => s.GetNextLessonIdForLessonId(1, group)).ReturnsAsync(2);

        await _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report(lessonId: 1));

        _logs.Verify(l => l.EndOfLesson(user, It.IsAny<EndOfLessonReport>()), Times.Once);
    }

    [Fact]
    public async Task EndLessonAsync_advances_to_next_lesson_group_when_last_lesson_solved()
    {
        var user = StubCurrentUser(nextLessonId: 2);
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [1, 2]);
        var nextGroup = EntityBuilders.LessonGroup(id: 2);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);
        _lessons.Setup(s => s.GetNextLessonIdForLessonId(2, group))
            .ThrowsAsync(new EntityNotFoundException());
        _lessonGroups.Setup(s => s.GetNextLessonGroupForLessonGroupId(1)).ReturnsAsync(nextGroup);

        await _sut.EndLessonAsync(ClaimsPrincipalFactory.For("u@x.hr"), Report(lessonId: 2));

        user.HighestLessonGroupId.Should().Be(1);
        user.NextLessonGroupId.Should().Be(2);
    }

    // ------------------- GenerateDailyQuestsForUser -------------------

    [Fact]
    public async Task GenerateDailyQuestsForUser_returns_DAILY_QUEST_AMOUNT_distinct_quests_for_today()
    {
        var user = new ApplicationUserBuilder().Build();
        user.Quests = null;

        var quests = await _sut.GenerateDailyQuestsForUser(user);

        quests.Should().HaveCount(3);
        quests.Select(q => q.Type).Distinct().Should().HaveCount(3);
        quests.Should().OnlyContain(q => q.Date == DateOnly.FromDateTime(DateTime.Now));
    }

    // ------------------- ChangePassword -------------------

    [Fact]
    public async Task ChangePassword_happy_path_calls_UserManager()
    {
        var user = StubCurrentUser();
        _userManager.Setup(m => m.ChangePasswordAsync(user, "old", "new"))
            .ReturnsAsync(IdentityResult.Success);

        await _sut.ChangePassword(ClaimsPrincipalFactory.For("u@x.hr"), "old", "new");

        _userManager.Verify(m => m.ChangePasswordAsync(user, "old", "new"), Times.Once);
    }

    [Fact]
    public async Task ChangePassword_throws_UserAuthenticationException_on_wrong_old_password()
    {
        var user = StubCurrentUser();
        _userManager.Setup(m => m.ChangePasswordAsync(user, "wrong", "new"))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "Incorrect password." }));

        Func<Task> act = () => _sut.ChangePassword(ClaimsPrincipalFactory.For("u@x.hr"), "wrong", "new");

        await act.Should().ThrowAsync<UserAuthenticationException>();
    }

    [Fact]
    public async Task ChangePassword_throws_InvalidDataException_on_other_failure()
    {
        var user = StubCurrentUser();
        _userManager.Setup(m => m.ChangePasswordAsync(user, "old", "weak"))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "Password too short." }));

        Func<Task> act = () => _sut.ChangePassword(ClaimsPrincipalFactory.For("u@x.hr"), "old", "weak");

        await act.Should().ThrowAsync<InvalidDataException>();
    }

    // ------------------- SwitchCourseAsync -------------------

    [Fact]
    public async Task SwitchCourseAsync_updates_CourseId_and_persists()
    {
        var user = StubCurrentUser();
        _courses.Setup(s => s.GetCourseByIdAsync(2)).ReturnsAsync(EntityBuilders.Course(2));

        await _sut.SwitchCourseAsync(ClaimsPrincipalFactory.For("u@x.hr"), 2);

        user.CourseId.Should().Be(2);
        _userManager.Verify(m => m.UpdateAsync(user), Times.AtLeastOnce);
    }

    [Fact]
    public async Task SwitchCourseAsync_throws_when_course_not_found()
    {
        StubCurrentUser();
        _courses.Setup(s => s.GetCourseByIdAsync(99)).ThrowsAsync(new EntityNotFoundException());

        Func<Task> act = () => _sut.SwitchCourseAsync(ClaimsPrincipalFactory.For("u@x.hr"), 99);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    // ------------------- GerUserCourseId -------------------

    [Fact]
    public async Task GerUserCourseId_returns_users_course()
    {
        var user = new ApplicationUserBuilder().WithEmail("u@x.hr").WithCourseId(7).Build();
        _usersRepo.Setup(r => r.FindByEmailAsync("u@x.hr")).ReturnsAsync(user);

        var result = await _sut.GerUserCourseId(ClaimsPrincipalFactory.For("u@x.hr"));

        result.Should().Be(7);
    }

    // ------------------- GetAllUsersAsync / FindByUsernameAsync -------------------

    [Fact]
    public async Task GetAllUsersAsync_delegates_to_repo()
    {
        var users = new List<ApplicationUser> { new ApplicationUserBuilder().Build() };
        _usersRepo.Setup(r => r.GetAllAsync()).ReturnsAsync(users);

        var result = await _sut.GetAllUsersAsync();

        result.Should().BeEquivalentTo(users);
    }

    [Fact]
    public async Task FindByUsernameAsync_delegates_to_repo()
    {
        var user = new ApplicationUserBuilder().WithEmail("u@x.hr").Build();
        _usersRepo.Setup(r => r.FindByUsernameAsync("u@x.hr")).ReturnsAsync(user);

        var result = await _sut.FindByUsernameAsync("u@x.hr");

        result.Should().Be(user);
    }
}
