using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBe.Services.Tests.Controllers;

public class LessonsControllerTests
{
    private readonly Mock<ILessonsService> _lessons = new();
    private readonly Mock<IUserService> _users = new();
    private readonly LessonsController _sut;

    public LessonsControllerTests()
    {
        _sut = new LessonsController(_lessons.Object, _users.Object);
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("user@school.hr", "CREATOR"));
    }

    [Fact]
    public async Task GetAllLessons_returns_lessons_for_user_course()
    {
        var lessons = new List<Lesson> { EntityBuilders.Lesson(1), EntityBuilders.Lesson(2) };
        _users.Setup(s => s.GerUserCourseId(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(3);
        _lessons.Setup(s => s.GetAllLessonsAsync(3)).ReturnsAsync(lessons);

        var result = await _sut.GetAllLessons();

        result.Should().BeEquivalentTo(lessons);
    }

    [Fact]
    public async Task GetLessonsByIDs_delegates_to_service()
    {
        var lessons = new List<Lesson> { EntityBuilders.Lesson(5), EntityBuilders.Lesson(6) };
        _lessons.Setup(s => s.GetLessonsByIDsAsync(new List<int> { 5, 6 })).ReturnsAsync(lessons);

        var result = await _sut.GetLessonsByIDs([5, 6]);

        result.Should().BeEquivalentTo(lessons);
    }

    [Fact]
    public async Task GetLessonsForLessonGroup_delegates_to_service()
    {
        var lessons = new List<Lesson> { EntityBuilders.Lesson(1) };
        _lessons.Setup(s => s.GetLessonsForLessonGroupAsync(8)).ReturnsAsync(lessons);

        var result = await _sut.GetLessonsForLessonGroup(8);

        result.Should().BeEquivalentTo(lessons);
    }

    [Fact]
    public async Task CreateLesson_returns_ok_with_created_lesson()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1 };
        var created = EntityBuilders.Lesson(42);
        _lessons.Setup(s => s.CreateLessonAsync(dto)).ReturnsAsync(created);

        var result = await _sut.CreateLesson(dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(created);
    }

    [Fact]
    public async Task UpdateLesson_returns_ok_on_success()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1 };
        var updated = EntityBuilders.Lesson(3);
        _lessons.Setup(s => s.UpdateLessonAsync(3, dto)).ReturnsAsync(updated);

        var result = await _sut.UpdateLesson(3, dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(updated);
    }

    [Fact]
    public async Task UpdateLesson_maps_EntityNotFoundException_to_not_found()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1 };
        _lessons.Setup(s => s.UpdateLessonAsync(3, dto)).ThrowsAsync(new EntityNotFoundException("missing"));

        var result = await _sut.UpdateLesson(3, dto);

        result.Should().BeOfType<NotFoundObjectResult>();
    }

    [Fact]
    public async Task UpdateLesson_maps_NoChangesException_to_no_content()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1 };
        _lessons.Setup(s => s.UpdateLessonAsync(3, dto)).ThrowsAsync(new NoChangesException());

        var result = await _sut.UpdateLesson(3, dto);

        result.Should().BeOfType<NoContentResult>();
    }

    [Fact]
    public async Task UpdateLesson_maps_generic_exception_to_bad_request()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1 };
        _lessons.Setup(s => s.UpdateLessonAsync(3, dto)).ThrowsAsync(new InvalidOperationException("bad"));

        var result = await _sut.UpdateLesson(3, dto);

        result.Should().BeOfType<BadRequestObjectResult>();
    }

    [Fact]
    public async Task DeleteLesson_returns_ok_on_success()
    {
        _lessons.Setup(s => s.DeleteLessonAsync(5)).Returns(Task.CompletedTask);

        var result = await _sut.DeleteLesson(5);

        result.Should().BeOfType<OkResult>();
    }

    [Fact]
    public async Task DeleteLesson_maps_exception_to_not_found()
    {
        _lessons.Setup(s => s.DeleteLessonAsync(5)).ThrowsAsync(new Exception("nope"));

        var result = await _sut.DeleteLesson(5);

        result.Should().BeOfType<NotFoundObjectResult>();
    }
}
