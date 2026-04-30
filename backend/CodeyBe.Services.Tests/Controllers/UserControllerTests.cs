using System.Security.Claims;
using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBe.Services.Tests.Controllers;

public class UserControllerTests
{
    private readonly Mock<IUserService> _users = new();
    private readonly Mock<IInteractionService> _interaction = new();
    private readonly UserController _sut;

    public UserControllerTests()
    {
        _sut = new UserController(_users.Object, _interaction.Object);
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("student@school.hr", "STUDENT"));
        _interaction.Setup(s => s.GetClassForStuedntByTeacher(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).ReturnsAsync((Class?)null);
        _users.Setup(s => s.GenerateDailyQuestsForUser(It.IsAny<ApplicationUser>())).ReturnsAsync(new HashSet<Quest>());
    }

    private static ApplicationUser BuildUser() =>
        new ApplicationUserBuilder().WithCourse(EntityBuilders.Course(1)).Build();

    [Fact]
    public async Task RegisterUser_returns_ok_on_success()
    {
        var request = new UserRegistrationRequestDTO { Email = "new@school.hr", Password = "Password1", CourseId = 1, ConsentedToTerms = true };
        _users.Setup(s => s.RegisterStudent(request)).ReturnsAsync(IdentityResult.Success);

        var result = await _sut.RegisterUser(request);

        result.Should().BeOfType<OkObjectResult>();
    }

    [Fact]
    public async Task RegisterUser_returns_400_on_failure()
    {
        var request = new UserRegistrationRequestDTO { Email = "new@school.hr", Password = "bad", CourseId = 1, ConsentedToTerms = true };
        _users.Setup(s => s.RegisterStudent(request)).ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "too short" }));

        var result = await _sut.RegisterUser(request);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task LoginUser_returns_token_on_success()
    {
        _users.Setup(s => s.LoginUser(It.IsAny<UserLoginRequestDTO>()))
            .ReturnsAsync(new JWTTokenDTO { Token = "jwt-abc" });

        var result = await _sut.LoginUser(new Dictionary<string, string> { { "email", "x@s.hr" }, { "password", "p" } });

        var ok = result.Should().BeOfType<OkObjectResult>().Subject;
        ok.Value.Should().BeOfType<UserLoginDTO>().Which.Token.Should().Be("jwt-abc");
    }

    [Fact]
    public async Task LoginUser_maps_UserAuthenticationException_to_401()
    {
        _users.Setup(s => s.LoginUser(It.IsAny<UserLoginRequestDTO>())).ThrowsAsync(new UserAuthenticationException("bad password"));

        var result = await _sut.LoginUser(new Dictionary<string, string> { { "email", "x@s.hr" }, { "password", "p" } });

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(401);
    }

    [Fact]
    public async Task GetUserData_returns_dto_on_success()
    {
        _users.Setup(s => s.GetUser(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(BuildUser());

        var result = await _sut.GetUserData();

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().BeOfType<UserDataDTO>();
    }

    [Fact]
    public async Task GetUserData_maps_null_user_to_401()
    {
        _users.Setup(s => s.GetUser(It.IsAny<ClaimsPrincipal>())).ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.GetUserData();

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(401);
    }

    [Fact]
    public async Task EndLesson_returns_dto_with_awarded_xp()
    {
        var user = BuildUser();
        _users.Setup(s => s.EndLessonAsync(It.IsAny<ClaimsPrincipal>(), It.IsAny<EndOfLessonReport>())).ReturnsAsync(160);
        _users.Setup(s => s.GetUser(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(user);

        var report = new EndOfLessonReport { AnswersReport = [] };
        var result = await _sut.EndLesson(report);

        var ok = result.Should().BeOfType<OkObjectResult>().Subject;
        var dto = ok.Value.Should().BeOfType<EndOfLessonDTO>().Subject;
        dto.AwardedXP.Should().Be(160);
    }

    [Fact]
    public async Task EndLesson_maps_EntityNotFoundException_to_400()
    {
        _users.Setup(s => s.EndLessonAsync(It.IsAny<ClaimsPrincipal>(), It.IsAny<EndOfLessonReport>())).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.EndLesson(new EndOfLessonReport { AnswersReport = [] });

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task RegisterCreator_returns_ok_on_success()
    {
        var request = new StaffRegistrationRequestDTO { Email = "c@s.hr", Password = "Password1" };
        _users.Setup(s => s.RegisterCreator(request)).ReturnsAsync(IdentityResult.Success);

        var result = await _sut.RegisterCreator(request);

        result.Should().BeOfType<OkObjectResult>();
    }

    [Fact]
    public async Task RegisterCreator_returns_400_on_failure()
    {
        var request = new StaffRegistrationRequestDTO { Email = "c@s.hr", Password = "p" };
        _users.Setup(s => s.RegisterCreator(request)).ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "too short" }));

        var result = await _sut.RegisterCreator(request);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task RegisterTeacher_returns_400_on_failure()
    {
        var request = new StaffRegistrationRequestDTO { Email = "t@s.hr", Password = "p" };
        _users.Setup(s => s.RegisterTeacher(request)).ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "bad" }));

        var result = await _sut.RegisterTeacher(request);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task SwitchCourse_returns_dto_on_success()
    {
        var user = BuildUser();
        _users.Setup(s => s.SwitchCourseAsync(It.IsAny<ClaimsPrincipal>(), 2)).ReturnsAsync(user);

        var result = await _sut.SwitchCourse(new Dictionary<string, int> { { "courseId", 2 } });

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().BeOfType<UserDataDTO>();
    }

    [Fact]
    public async Task SwitchCourse_maps_EntityNotFoundException_to_404()
    {
        _users.Setup(s => s.SwitchCourseAsync(It.IsAny<ClaimsPrincipal>(), 2)).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.SwitchCourse(new Dictionary<string, int> { { "courseId", 2 } });

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(404);
    }

    [Fact]
    public async Task ChangePassword_returns_ok_on_success()
    {
        _users.Setup(s => s.ChangePassword(It.IsAny<ClaimsPrincipal>(), "old", "new")).Returns(Task.CompletedTask);

        var result = await _sut.ChangePassword(new Dictionary<string, string> { { "oldPassword", "old" }, { "newPassword", "new" } });

        result.Should().BeOfType<OkResult>();
    }

    [Fact]
    public async Task ChangePassword_maps_exception_to_400()
    {
        _users.Setup(s => s.ChangePassword(It.IsAny<ClaimsPrincipal>(), "old", "new")).ThrowsAsync(new InvalidOperationException("bad"));

        var result = await _sut.ChangePassword(new Dictionary<string, string> { { "oldPassword", "old" }, { "newPassword", "new" } });

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task UpdateUser_returns_dto_on_success()
    {
        var user = BuildUser();
        _users.Setup(s => s.GetUser(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(user);
        _users.Setup(s => s.UpdateUserData(user)).ReturnsAsync(user);

        var result = await _sut.UpdateUser(new Dictionary<string, string>
        {
            { "firstName", "A" }, { "lastName", "B" }, { "dateOfBirth", "2000-01-01" }
        });

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().BeOfType<UserDataDTO>();
    }

    [Fact]
    public async Task UpdateUser_maps_null_user_to_401()
    {
        _users.Setup(s => s.GetUser(It.IsAny<ClaimsPrincipal>())).ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.UpdateUser(new Dictionary<string, string>
        {
            { "firstName", "A" }, { "lastName", "B" }, { "dateOfBirth", "2000-01-01" }
        });

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(401);
    }
}
