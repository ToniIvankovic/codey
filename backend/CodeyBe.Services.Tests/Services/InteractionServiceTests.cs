using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class InteractionServiceTests
{
    private readonly Mock<IUserService> _userService = new();
    private readonly Mock<IClassesRepository> _classesRepo = new();
    private readonly InteractionService _sut;

    private readonly ApplicationUser _teacher = new ApplicationUserBuilder()
        .WithEmail("teacher@school.hr")
        .WithSchool("Test School")
        .WithRoles("TEACHER")
        .Build();

    public InteractionServiceTests()
    {
        _sut = new InteractionService(_userService.Object, _classesRepo.Object);
    }

    private void StubTeacher()
    {
        _userService.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>()))
            .ReturnsAsync(_teacher);
    }

    private void StubStudent(ApplicationUser student)
    {
        _userService.Setup(s => s.FindByUsernameAsync(student.UserName!)).ReturnsAsync(student);
    }

    [Fact]
    public async Task CreateClass_creates_class_with_teacher_school_and_email()
    {
        var student = new ApplicationUserBuilder().WithEmail("s@school.hr").WithSchool("Test School").Build();
        StubTeacher();
        StubStudent(student);
        _classesRepo.Setup(r => r.GetClassForStudent(student)).ReturnsAsync((Class?)null);
        _classesRepo.Setup(r => r.CreateAsync(It.IsAny<Class>()))
            .ReturnsAsync((Class c) => c);

        var result = await _sut.CreateClass(
            ClaimsPrincipalFactory.For(_teacher.Email!, "TEACHER"),
            new ClassCreationDTO { Name = "C", StudentUsernames = [student.UserName!] });

        result.School.Should().Be(_teacher.School);
        result.TeacherUsername.Should().Be(_teacher.Email);
        result.Students.Should().ContainSingle().Which.Should().Be(student.UserName);
    }

    [Fact]
    public async Task CreateClass_throws_when_teacher_not_found()
    {
        _userService.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>()))
            .ReturnsAsync((ApplicationUser?)null);

        Func<Task> act = () => _sut.CreateClass(
            ClaimsPrincipalFactory.For("x@x.hr"),
            new ClassCreationDTO { Name = "C", StudentUsernames = [] });

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task CreateClass_throws_when_student_not_found()
    {
        StubTeacher();
        _userService.Setup(s => s.FindByUsernameAsync("ghost")).ReturnsAsync((ApplicationUser?)null);

        Func<Task> act = () => _sut.CreateClass(
            ClaimsPrincipalFactory.For(_teacher.Email!),
            new ClassCreationDTO { Name = "C", StudentUsernames = ["ghost"] });

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task CreateClass_throws_when_student_from_different_school()
    {
        var student = new ApplicationUserBuilder().WithEmail("s@other.hr").WithSchool("Other School").Build();
        StubTeacher();
        StubStudent(student);

        Func<Task> act = () => _sut.CreateClass(
            ClaimsPrincipalFactory.For(_teacher.Email!),
            new ClassCreationDTO { Name = "C", StudentUsernames = [student.UserName!] });

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task CreateClass_throws_when_student_already_in_another_class()
    {
        var student = new ApplicationUserBuilder().WithEmail("s@school.hr").WithSchool("Test School").Build();
        StubTeacher();
        StubStudent(student);
        _classesRepo.Setup(r => r.GetClassForStudent(student))
            .ReturnsAsync(EntityBuilders.Class(id: 7));

        Func<Task> act = () => _sut.CreateClass(
            ClaimsPrincipalFactory.For(_teacher.Email!),
            new ClassCreationDTO { Name = "C", StudentUsernames = [student.UserName!] });

        await act.Should().ThrowAsync<InvalidDataException>();
    }

    [Fact]
    public async Task UpdateClass_rejects_class_of_another_teacher()
    {
        StubTeacher();
        var otherTeachersClass = EntityBuilders.Class(id: 1, teacherEmail: "other@school.hr");
        _classesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(otherTeachersClass);

        Func<Task> act = () => _sut.UpdateClass(
            ClaimsPrincipalFactory.For(_teacher.Email!), 1,
            new ClassCreationDTO { Name = "C", StudentUsernames = [] });

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task DeleteClass_rejects_class_of_another_teacher()
    {
        StubTeacher();
        _classesRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(EntityBuilders.Class(id: 1, teacherEmail: "other@school.hr"));

        Func<Task> act = () => _sut.DeleteClass(ClaimsPrincipalFactory.For(_teacher.Email!), 1);

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task DeleteClass_delegates_to_repo_when_owned_by_teacher()
    {
        StubTeacher();
        _classesRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(EntityBuilders.Class(id: 1, teacherEmail: _teacher.Email!));

        await _sut.DeleteClass(ClaimsPrincipalFactory.For(_teacher.Email!), 1);

        _classesRepo.Verify(r => r.DeleteAsync(1), Times.Once);
    }

    [Fact]
    public async Task GetAllStudentsForTeacher_filters_by_school_and_student_role()
    {
        StubTeacher();
        var sameSchoolStudent = new ApplicationUserBuilder().WithEmail("a@school.hr").WithSchool("Test School").WithRoles("STUDENT").Build();
        var otherSchoolStudent = new ApplicationUserBuilder().WithEmail("b@other.hr").WithSchool("Other School").WithRoles("STUDENT").Build();
        var teacherSameSchool = new ApplicationUserBuilder().WithEmail("t@school.hr").WithSchool("Test School").WithRoles("TEACHER").Build();
        _userService.Setup(s => s.GetAllUsersAsync())
            .ReturnsAsync([sameSchoolStudent, otherSchoolStudent, teacherSameSchool]);

        var result = (await _sut.GetAllStudentsForTeacher(ClaimsPrincipalFactory.For(_teacher.Email!))).ToList();

        result.Should().ContainSingle().Which.Should().Be(sameSchoolStudent);
    }

    [Fact]
    public async Task GetStudentByQuery_matches_username_too()
    {
        StubTeacher();
        var byUsername = new ApplicationUserBuilder().WithEmail("zzz@school.hr").WithSchool("Test School").WithRoles("STUDENT").Build();
        byUsername.NormalizedUserName = "ALICE123";
        _userService.Setup(s => s.GetAllUsersAsync()).ReturnsAsync([byUsername]);

        var result = await _sut.GetStudentByQuery(ClaimsPrincipalFactory.For(_teacher.Email!), "alice");

        result.Should().Contain(byUsername);
    }

    [Fact]
    public async Task GetStudentByQuery_without_query_returns_all()
    {
        StubTeacher();
        var student = new ApplicationUserBuilder().WithEmail("a@school.hr").WithSchool("Test School").WithRoles("STUDENT").Build();
        _userService.Setup(s => s.GetAllUsersAsync()).ReturnsAsync([student]);

        var result = await _sut.GetStudentByQuery(ClaimsPrincipalFactory.For(_teacher.Email!), null);

        result.Should().ContainSingle().Which.Should().Be(student);
    }

    [Fact]
    public async Task GetLeaderboardForClass_rejects_teacher_who_does_not_own_class()
    {
        StubTeacher();
        _classesRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(EntityBuilders.Class(id: 1, teacherEmail: "other@school.hr"));

        Func<Task> act = () => _sut.GetLeaderboardForClass(ClaimsPrincipalFactory.For(_teacher.Email!), 1, 1);

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task GetLeaderboardForClass_filters_and_orders_by_TotalXP_desc()
    {
        StubTeacher();
        var c = EntityBuilders.Class(id: 1, school: _teacher.School!, teacherEmail: _teacher.Email!,
            students: ["a@school.hr", "b@school.hr"]);
        _classesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(c);
        var a = new ApplicationUserBuilder().WithEmail("a@school.hr").WithSchool(_teacher.School).WithRoles("STUDENT").WithCourseId(1).WithTotalXP(50).Build();
        var b = new ApplicationUserBuilder().WithEmail("b@school.hr").WithSchool(_teacher.School).WithRoles("STUDENT").WithCourseId(1).WithTotalXP(200).Build();
        var other = new ApplicationUserBuilder().WithEmail("c@school.hr").WithSchool(_teacher.School).WithRoles("STUDENT").WithCourseId(1).WithTotalXP(500).Build();
        // Missing Course navigation property — set to avoid the UserDataDTO.FromUser throw.
        a.Course = EntityBuilders.Course(1);
        b.Course = EntityBuilders.Course(1);
        _userService.Setup(s => s.GetAllUsersAsync()).ReturnsAsync([a, b, other]);

        var leaderboard = await _sut.GetLeaderboardForClass(ClaimsPrincipalFactory.For(_teacher.Email!), 1, 1);

        leaderboard.ClassId.Should().Be(1);
        leaderboard.Students.Should().HaveCount(2);
        leaderboard.Students[0].Email.Should().Be("b@school.hr");
        leaderboard.Students[1].Email.Should().Be("a@school.hr");
    }
}
