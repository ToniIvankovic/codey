using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBe.Services.Tests.Controllers;

public class LessonGroupsControllerTests
{
    private readonly Mock<ILessonGroupsService> _lessonGroups = new();
    private readonly Mock<IUserService> _users = new();
    private readonly LessonGroupsController _sut;

    public LessonGroupsControllerTests()
    {
        _sut = new LessonGroupsController(_lessonGroups.Object, _users.Object);
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("user@school.hr", "STUDENT"));
    }

    [Fact]
    public async Task GetAllLessonGroups_returns_groups_for_user_course()
    {
        var groups = new List<LessonGroup> { EntityBuilders.LessonGroup(1), EntityBuilders.LessonGroup(2) };
        _users.Setup(s => s.GerUserCourseId(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(7);
        _lessonGroups.Setup(s => s.GetAllLessonGroupsAsync(7)).ReturnsAsync(groups);

        var result = await _sut.GetAllLessonGroups();

        result.Should().BeEquivalentTo(groups);
    }

    [Fact]
    public async Task GetLessonGroupByID_returns_group_from_service()
    {
        var group = EntityBuilders.LessonGroup(5);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(5)).ReturnsAsync(group);

        var result = await _sut.GetLessonGroupByID(5);

        result.Should().Be(group);
    }

    [Fact]
    public async Task CreateLessonGroup_wraps_service_result_in_ok()
    {
        var created = EntityBuilders.LessonGroup(9);
        var dto = new LessonGroupCreationDTO { Name = "G", CourseId = 1, Lessons = [] };
        _lessonGroups.Setup(s => s.CreateLessonGroupAsync(dto)).ReturnsAsync(created);

        var result = await _sut.CreateLessonGroup(dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(created);
    }

    [Fact]
    public async Task UpdateLessonGroup_returns_ok_on_success()
    {
        var updated = EntityBuilders.LessonGroup(3);
        var dto = new LessonGroupCreationDTO { Name = "G", CourseId = 1, Lessons = [] };
        _lessonGroups.Setup(s => s.UpdateLessonGroupAsync(3, dto)).ReturnsAsync(updated);

        var result = await _sut.UpdateLessonGroup(3, dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(updated);
    }

    [Fact]
    public async Task UpdateLessonGroup_maps_exception_to_not_found()
    {
        var dto = new LessonGroupCreationDTO { Name = "G", CourseId = 1, Lessons = [] };
        _lessonGroups.Setup(s => s.UpdateLessonGroupAsync(3, dto)).ThrowsAsync(new Exception("missing"));

        var result = await _sut.UpdateLessonGroup(3, dto);

        result.Should().BeOfType<NotFoundObjectResult>();
    }

    [Fact]
    public async Task UpdateLessonGroupsOrder_returns_ok_on_success()
    {
        var reorder = new List<LessonGroupsReorderDTO>();
        var updated = new List<LessonGroup> { EntityBuilders.LessonGroup(1) };
        _lessonGroups.Setup(s => s.UpdateLessonGroupOrderAsync(reorder)).ReturnsAsync(updated);

        var result = await _sut.UpdateLessonGroupsOrder(reorder);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(updated);
    }

    [Fact]
    public async Task DeleteLessonGroup_returns_ok_on_success()
    {
        _lessonGroups.Setup(s => s.DeleteLessonGroupAsync(4)).Returns(Task.CompletedTask);

        var result = await _sut.DeleteLessonGroup(4);

        result.Should().BeOfType<OkResult>();
    }

    [Fact]
    public async Task DeleteLessonGroup_maps_exception_to_not_found()
    {
        _lessonGroups.Setup(s => s.DeleteLessonGroupAsync(4)).ThrowsAsync(new Exception("nope"));

        var result = await _sut.DeleteLessonGroup(4);

        result.Should().BeOfType<NotFoundObjectResult>();
    }
}
