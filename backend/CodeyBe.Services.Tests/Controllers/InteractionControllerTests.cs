using System.Security.Claims;
using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBe.Services.Tests.Controllers;

public class InteractionControllerTests
{
    private readonly Mock<IInteractionService> _interaction = new();
    private readonly InteractionController _sut;

    public InteractionControllerTests()
    {
        _sut = new InteractionController(_interaction.Object);
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("teacher@school.hr", "TEACHER"));
    }

    private static ApplicationUser Student(string username) =>
        new ApplicationUserBuilder().WithEmail(username).WithCourse(EntityBuilders.Course(1)).Build();

    [Fact]
    public async Task GetAllStudentsForTeacher_maps_students_to_dtos()
    {
        var s1 = Student("a@s.hr");
        var s2 = Student("b@s.hr");
        _interaction.Setup(s => s.GetAllStudentsForTeacher(It.IsAny<ClaimsPrincipal>())).ReturnsAsync([s1, s2]);
        _interaction.Setup(s => s.GetClassForStuedntByTeacher(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).ReturnsAsync((Class?)null);

        var result = (await _sut.GetAllStudentsForTeacher()).ToList();

        result.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetStudentsByQuery_passes_query_to_service()
    {
        _interaction.Setup(s => s.GetStudentByQuery(It.IsAny<ClaimsPrincipal>(), "foo")).ReturnsAsync([Student("x@s.hr")]);
        _interaction.Setup(s => s.GetClassForStuedntByTeacher(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).ReturnsAsync((Class?)null);

        var result = (await _sut.GetStudentsByQuery("foo")).ToList();

        result.Should().HaveCount(1);
        _interaction.Verify(s => s.GetStudentByQuery(It.IsAny<ClaimsPrincipal>(), "foo"), Times.Once);
    }

    [Fact]
    public async Task CreateClass_returns_ok_on_success()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        var created = EntityBuilders.Class(5);
        _interaction.Setup(s => s.CreateClass(It.IsAny<ClaimsPrincipal>(), dto)).ReturnsAsync(created);

        var result = await _sut.CreateClass(dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(created);
    }

    [Fact]
    public async Task CreateClass_maps_UnauthorizedAccessException_to_403()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        _interaction.Setup(s => s.CreateClass(It.IsAny<ClaimsPrincipal>(), dto)).ThrowsAsync(new UnauthorizedAccessException("nope"));

        var result = await _sut.CreateClass(dto);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(403);
    }

    [Fact]
    public async Task CreateClass_maps_EntityNotFoundException_to_404()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        _interaction.Setup(s => s.CreateClass(It.IsAny<ClaimsPrincipal>(), dto)).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.CreateClass(dto);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(404);
    }

    [Fact]
    public async Task CreateClass_maps_MissingFieldException_to_400()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        _interaction.Setup(s => s.CreateClass(It.IsAny<ClaimsPrincipal>(), dto)).ThrowsAsync(new MissingFieldException("field"));

        var result = await _sut.CreateClass(dto);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(400);
    }

    [Fact]
    public async Task CreateClass_maps_generic_exception_to_500()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        _interaction.Setup(s => s.CreateClass(It.IsAny<ClaimsPrincipal>(), dto)).ThrowsAsync(new Exception("boom"));

        var result = await _sut.CreateClass(dto);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(500);
    }

    [Fact]
    public async Task UpdateClass_returns_ok_on_success()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        var updated = EntityBuilders.Class(5);
        _interaction.Setup(s => s.UpdateClass(It.IsAny<ClaimsPrincipal>(), 5, dto)).ReturnsAsync(updated);

        var result = await _sut.UpdateClass(5, dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(updated);
    }

    [Fact]
    public async Task UpdateClass_maps_NoChangesException_to_204()
    {
        var dto = new ClassCreationDTO { Name = "C", StudentUsernames = [] };
        _interaction.Setup(s => s.UpdateClass(It.IsAny<ClaimsPrincipal>(), 5, dto)).ThrowsAsync(new NoChangesException());

        var result = await _sut.UpdateClass(5, dto);

        result.Should().BeOfType<StatusCodeResult>().Which.StatusCode.Should().Be(204);
    }

    [Fact]
    public async Task DeleteClass_returns_ok_on_success()
    {
        _interaction.Setup(s => s.DeleteClass(It.IsAny<ClaimsPrincipal>(), 4)).Returns(Task.CompletedTask);

        var result = await _sut.DeleteClass(4);

        result.Should().BeOfType<OkResult>();
    }

    [Fact]
    public async Task DeleteClass_maps_EntityNotFoundException_to_404()
    {
        _interaction.Setup(s => s.DeleteClass(It.IsAny<ClaimsPrincipal>(), 4)).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.DeleteClass(4);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(404);
    }

    [Fact]
    public async Task DeleteClass_maps_UnauthorizedAccessException_to_403()
    {
        _interaction.Setup(s => s.DeleteClass(It.IsAny<ClaimsPrincipal>(), 4)).ThrowsAsync(new UnauthorizedAccessException("nope"));

        var result = await _sut.DeleteClass(4);

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(403);
    }

    [Fact]
    public async Task GetAllClasses_delegates_to_service()
    {
        var classes = new List<Class> { EntityBuilders.Class(1), EntityBuilders.Class(2) };
        _interaction.Setup(s => s.GetAllClassesForTeacher(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(classes);

        var result = await _sut.GetAllClasses();

        result.Should().BeEquivalentTo(classes);
    }

    [Fact]
    public async Task GetAllSchools_returns_hardcoded_list()
    {
        var result = (await _sut.GetAllSchools()).ToList();

        result.Should().HaveCount(3);
    }

    [Fact]
    public async Task GetClassForStudentSelf_delegates_to_service()
    {
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("student@s.hr", "STUDENT"));
        var cls = EntityBuilders.Class(1);
        _interaction.Setup(s => s.GetClassForStudentSelf(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).ReturnsAsync(cls);

        var result = await _sut.GetClassForStudentSelf();

        result.Should().Be(cls);
    }

    [Fact]
    public async Task GetLeaderboardForStudentSelf_returns_ok_on_success()
    {
        var leaderboard = new Leaderboard { ClassId = 1, Students = [] };
        _interaction.Setup(s => s.GetLeaderboardForStudentSelf(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(leaderboard);

        var result = await _sut.GetLeaderboardForStudentSelf();

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(leaderboard);
    }

    [Fact]
    public async Task GetLeaderboardForStudentSelf_maps_EntityNotFoundException_to_404()
    {
        _interaction.Setup(s => s.GetLeaderboardForStudentSelf(It.IsAny<ClaimsPrincipal>())).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.GetLeaderboardForStudentSelf();

        result.Should().BeOfType<ObjectResult>().Which.StatusCode.Should().Be(404);
    }

    [Fact]
    public async Task GetLeaderboardForClass_delegates_to_service()
    {
        var leaderboard = new Leaderboard { ClassId = 2, Students = [] };
        _interaction.Setup(s => s.GetLeaderboardForClass(It.IsAny<ClaimsPrincipal>(), 2, 1)).ReturnsAsync(leaderboard);

        var result = await _sut.GetLeaderboardForClass(2, 1);

        result.Should().Be(leaderboard);
    }
}
