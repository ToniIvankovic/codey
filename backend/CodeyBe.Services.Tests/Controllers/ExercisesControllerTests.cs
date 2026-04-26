using System.Text.Json;
using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers;
using CodeyBe.Services.Tests.TestHelpers.Builders;
using Microsoft.AspNetCore.Mvc;

namespace CodeyBe.Services.Tests.Controllers;

public class ExercisesControllerTests
{
    private readonly Mock<IExercisesService> _exercises = new();
    private readonly Mock<ILogsService> _logs = new();
    private readonly Mock<IUserService> _users = new();
    private readonly ExercisesController _sut;

    public ExercisesControllerTests()
    {
        _sut = new ExercisesController(_exercises.Object, _logs.Object, _users.Object);
        ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("student@school.hr", "STUDENT"));
    }

    private void AttachRoles(params string[] roles)
        => ControllerContextFactory.AttachUser(_sut, ClaimsPrincipalFactory.For("user@school.hr", roles));

    [Fact]
    public async Task GetAllExercises_maps_through_MapToSpecificExerciseDTOType()
    {
        AttachRoles("CREATOR");
        var ex = ExerciseBuilders.MultipleChoice(1);
        _users.Setup(s => s.GerUserCourseId(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(1);
        _exercises.Setup(s => s.GetAllExercisesAsync(1)).ReturnsAsync([ex]);

        var result = (await _sut.GetAllExercises()).ToList();

        result.Should().HaveCount(1);
    }

    [Fact]
    public async Task GetExerciseByID_delegates_to_service()
    {
        var ex = ExerciseBuilders.MultipleChoice(7);
        _exercises.Setup(s => s.GetExerciseByIDAsync(7)).ReturnsAsync(ex);

        var result = await _sut.GetExerciseByID(7);

        result.Should().Be(ex);
    }

    [Fact]
    public async Task GetExercisesForLesson_passes_skipLimit_true_for_creator()
    {
        AttachRoles("CREATOR");
        var user = new ApplicationUserBuilder().Build();
        _users.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(user);
        _exercises.Setup(s => s.GetExercisesForLessonAsync(5, true)).ReturnsAsync([ExerciseBuilders.MultipleChoice(1)]);

        var result = (await _sut.GetExercisesForLesson(5)).ToList();

        result.Should().HaveCount(1);
        _exercises.Verify(s => s.GetExercisesForLessonAsync(5, true), Times.Once);
    }

    [Fact]
    public async Task GetExercisesForLesson_passes_skipLimit_false_for_student()
    {
        AttachRoles("STUDENT");
        var user = new ApplicationUserBuilder().Build();
        _users.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(user);
        _exercises.Setup(s => s.GetExercisesForLessonAsync(5, false)).ReturnsAsync([]);

        await _sut.GetExercisesForLesson(5);

        _exercises.Verify(s => s.GetExercisesForLessonAsync(5, false), Times.Once);
        _logs.Verify(l => l.RequestedLesson(user, 5), Times.Once);
    }

    [Fact]
    public async Task GetExercisesForLesson_throws_when_user_not_found()
    {
        _users.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync((ApplicationUser?)null);

        Func<Task> act = () => _sut.GetExercisesForLesson(5);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task GetExercisesForAdaptiveLesson_logs_and_delegates()
    {
        var user = new ApplicationUserBuilder().Build();
        _users.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(user);
        _exercises.Setup(s => s.GetExercisesForAdaptiveLessonAsync(user)).ReturnsAsync([ExerciseBuilders.MultipleChoice(1)]);

        var result = (await _sut.GetExercisesForAdaptiveLesson(9)).ToList();

        result.Should().HaveCount(1);
        _logs.Verify(l => l.RequestedLesson(user, 9), Times.Once);
    }

    [Fact]
    public async Task ValidateAnswer_logs_and_returns_dto()
    {
        var user = new ApplicationUserBuilder().Build();
        var ex = ExerciseBuilders.MultipleChoice(1);
        var validation = new CodeyBE.Contracts.Entities.AnswerValidationResult(ex, true, "B", ["B"]);
        _users.Setup(s => s.GetUser(It.IsAny<System.Security.Claims.ClaimsPrincipal>())).ReturnsAsync(user);
        _exercises.Setup(s => s.GetExerciseByIDAsync(1)).ReturnsAsync(ex);
        _exercises.Setup(s => s.ValidateAnswer(1, It.IsAny<JsonElement>())).ReturnsAsync(validation);

        var body = new Dictionary<string, dynamic> { { "answer", JsonDocument.Parse("\"B\"").RootElement } };

        var result = await _sut.ValidateAnswer(1, body);

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task CreateExercise_returns_ok_on_success()
    {
        var dto = new ExerciseCreationDTO { Type = ExerciseTypes.MULTIPLE_CHOICE, CourseId = 1, Difficulty = 1 };
        var created = ExerciseBuilders.MultipleChoice(11);
        _exercises.Setup(s => s.CreateExerciseAsync(dto)).ReturnsAsync(created);

        var result = await _sut.CreateExercise(dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(created);
    }

    [Fact]
    public async Task CreateExercise_maps_exception_to_bad_request()
    {
        var dto = new ExerciseCreationDTO { Type = ExerciseTypes.MULTIPLE_CHOICE, CourseId = 1, Difficulty = 1 };
        _exercises.Setup(s => s.CreateExerciseAsync(dto)).ThrowsAsync(new ArgumentException("bad"));

        var result = await _sut.CreateExercise(dto);

        result.Should().BeOfType<BadRequestObjectResult>();
    }

    [Fact]
    public async Task UpdateExercise_returns_ok_on_success()
    {
        var dto = new ExerciseCreationDTO { Type = ExerciseTypes.MULTIPLE_CHOICE, CourseId = 1, Difficulty = 1 };
        var updated = ExerciseBuilders.MultipleChoice(2);
        _exercises.Setup(s => s.UpdateExerciseAsync(2, dto)).ReturnsAsync(updated);

        var result = await _sut.UpdateExercise(2, dto);

        result.Should().BeOfType<OkObjectResult>().Which.Value.Should().Be(updated);
    }

    [Fact]
    public async Task UpdateExercise_maps_NoChangesException_to_204()
    {
        var dto = new ExerciseCreationDTO { Type = ExerciseTypes.MULTIPLE_CHOICE, CourseId = 1, Difficulty = 1 };
        _exercises.Setup(s => s.UpdateExerciseAsync(2, dto)).ThrowsAsync(new NoChangesException());

        var result = await _sut.UpdateExercise(2, dto);

        result.Should().BeOfType<StatusCodeResult>().Which.StatusCode.Should().Be(204);
    }

    [Fact]
    public async Task DeleteExercise_returns_ok_on_success()
    {
        _exercises.Setup(s => s.DeleteExerciseAsync(3)).Returns(Task.CompletedTask);

        var result = await _sut.DeleteExercise(3);

        result.Should().BeOfType<OkResult>();
    }

    [Fact]
    public async Task DeleteExercise_maps_exception_to_not_found()
    {
        _exercises.Setup(s => s.DeleteExerciseAsync(3)).ThrowsAsync(new Exception("nope"));

        var result = await _sut.DeleteExercise(3);

        result.Should().BeOfType<NotFoundObjectResult>();
    }
}
