using System.Text.Json;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class ExercisesServiceTests
{
    private readonly Mock<IExercisesRepository> _exercisesRepo = new();
    private readonly Mock<ILessonsService> _lessons = new();
    private readonly Mock<ILessonGroupsService> _lessonGroups = new();
    private readonly Mock<ILogsService> _logs = new();
    private readonly Mock<ICoursesService> _courses = new();
    private readonly ExercisesService _sut;

    public ExercisesServiceTests()
    {
        _sut = new ExercisesService(_exercisesRepo.Object, _lessons.Object, _lessonGroups.Object, _logs.Object, _courses.Object);
    }

    private static JsonElement Json(object value) =>
        JsonDocument.Parse(JsonSerializer.Serialize(value)).RootElement;

    [Fact]
    public async Task GetAllExercisesAsync_delegates_to_repo()
    {
        var list = new List<Exercise> { ExerciseBuilders.MultipleChoice(1) };
        _exercisesRepo.Setup(r => r.GetAllAsync(1)).ReturnsAsync(list);

        var result = await _sut.GetAllExercisesAsync(1);

        result.Should().BeEquivalentTo(list);
    }

    [Fact]
    public async Task GetExerciseByIDAsync_returns_null_when_missing()
    {
        _exercisesRepo.Setup(r => r.GetByIdAsync(9)).ReturnsAsync((Exercise?)null);

        var result = await _sut.GetExerciseByIDAsync(9);

        result.Should().BeNull();
    }

    [Fact]
    public async Task DeleteExerciseAsync_delegates_to_repo()
    {
        await _sut.DeleteExerciseAsync(3);

        _exercisesRepo.Verify(r => r.DeleteAsync(3), Times.Once);
    }

    [Fact]
    public async Task GetExercisesForLessonAsync_throws_when_lesson_missing()
    {
        _lessons.Setup(s => s.GetLessonByIDAsync(1)).ReturnsAsync((Lesson?)null);

        Func<Task> act = () => _sut.GetExercisesForLessonAsync(1);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task GetExercisesForLessonAsync_returns_all_with_skipLimit()
    {
        var lesson = EntityBuilders.Lesson(id: 1, exercises: [1, 2, 3], exerciseLimit: 1);
        var exercises = new List<Exercise>
        {
            ExerciseBuilders.MultipleChoice(1, "A", 1.0),
            ExerciseBuilders.MultipleChoice(2, "B", 2.0),
            ExerciseBuilders.MultipleChoice(3, "C", 3.0),
        };
        _lessons.Setup(s => s.GetLessonByIDAsync(1)).ReturnsAsync(lesson);
        _exercisesRepo.Setup(r => r.GetExercisesByID(It.IsAny<IEnumerable<int>>())).Returns(exercises);

        var result = (await _sut.GetExercisesForLessonAsync(1, skipLimit: true)).ToList();

        result.Should().HaveCount(3);
    }

    [Fact]
    public async Task GetExercisesForLessonAsync_applies_lesson_exercise_limit()
    {
        var lesson = EntityBuilders.Lesson(id: 1, exercises: [1, 2, 3], exerciseLimit: 2);
        var course = EntityBuilders.Course(1);
        var exercises = new List<Exercise>
        {
            ExerciseBuilders.MultipleChoice(1, "A", 1.0),
            ExerciseBuilders.MultipleChoice(2, "B", 2.0),
            ExerciseBuilders.MultipleChoice(3, "C", 3.0),
        };
        _lessons.Setup(s => s.GetLessonByIDAsync(1)).ReturnsAsync(lesson);
        _courses.Setup(s => s.GetCourseByIdAsync(1)).ReturnsAsync(course);
        _exercisesRepo.Setup(r => r.GetExercisesByID(It.IsAny<IEnumerable<int>>())).Returns(exercises);

        var result = (await _sut.GetExercisesForLessonAsync(1)).ToList();

        result.Should().HaveCount(2);
    }

    [Fact]
    public async Task ValidateAnswer_MC_accepts_correct_letter()
    {
        var mc = ExerciseBuilders.MultipleChoice(1, correctAnswer: "B");
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(mc);

        var result = await _sut.ValidateAnswer(1, Json("B"));

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task ValidateAnswer_MC_rejects_wrong_letter()
    {
        var mc = ExerciseBuilders.MultipleChoice(1, correctAnswer: "B");
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(mc);

        var result = await _sut.ValidateAnswer(1, Json("A"));

        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public async Task ValidateAnswer_SA_accepts_trimmed_match()
    {
        var sa = ExerciseBuilders.ShortAnswer(1, ["hello"]);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(sa);

        var result = await _sut.ValidateAnswer(1, Json("  hello  "));

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task ValidateAnswer_SA_rejects_case_mismatch_because_SA_is_case_sensitive()
    {
        var sa = ExerciseBuilders.ShortAnswer(1, ["Hello"]);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(sa);

        var result = await _sut.ValidateAnswer(1, Json("hello"));

        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public async Task ValidateAnswer_LA_accepts_exact_answer()
    {
        var la = ExerciseBuilders.LongAnswer(1, ["a long answer"]);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(la);

        var result = await _sut.ValidateAnswer(1, Json("a long answer"));

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task ValidateAnswer_SCW_accepts_correct_gap_list()
    {
        var scw = ExerciseBuilders.ShortCodeWriting(1, ["x"]);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(scw);

        var result = await _sut.ValidateAnswer(1, Json(new[] { "x" }));

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task ValidateAnswer_SCW_rejects_wrong_gap()
    {
        var scw = ExerciseBuilders.ShortCodeWriting(1, ["x"]);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(scw);

        var result = await _sut.ValidateAnswer(1, Json(new[] { "y" }));

        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public async Task ValidateAnswer_ORC_accepts_identity_permutation()
    {
        var orc = ExerciseBuilders.OrderRearrangeCode(1);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(orc);

        var result = await _sut.ValidateAnswer(1, Json(new[] { 0, 1, 2 }));

        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public async Task ValidateAnswer_ORC_rejects_wrong_permutation()
    {
        var orc = ExerciseBuilders.OrderRearrangeCode(1);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(orc);

        var result = await _sut.ValidateAnswer(1, Json(new[] { 1, 0, 2 }));

        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public async Task ValidateAnswer_MTC_uses_client_reported_boolean()
    {
        var mtc = ExerciseBuilders.Match(1);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(mtc);

        (await _sut.ValidateAnswer(1, Json(true))).IsCorrect.Should().BeTrue();
        (await _sut.ValidateAnswer(1, Json(false))).IsCorrect.Should().BeFalse();
    }

    [Fact]
    public async Task ValidateAnswer_throws_when_exercise_missing()
    {
        _exercisesRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Exercise?)null);

        Func<Task> act = () => _sut.ValidateAnswer(99, Json("a"));

        await act.Should().ThrowAsync<ArgumentException>();
    }

    [Fact]
    public async Task GetSuggestedDifficultyForExerciseAsync_returns_exercise_difficulty_when_no_history()
    {
        var ex = ExerciseBuilders.MultipleChoice(1, difficulty: 5.5);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ex);
        _logs.Setup(l => l.GetLogExerciseAnswersForExercise(1)).ReturnsAsync(new List<LogExerciseAnswer>());

        var result = await _sut.GetSuggestedDifficultyForExerciseAsync(1);

        result.Should().Be(5.5);
    }

    [Fact]
    public async Task GetAverageScoresForExerciseAsync_returns_null_for_empty_buckets()
    {
        var ex = ExerciseBuilders.MultipleChoice(1);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ex);
        _logs.Setup(l => l.GetLogExerciseAnswersForExercise(1)).ReturnsAsync(new List<LogExerciseAnswer>());

        var result = await _sut.GetAverageScoresForExerciseAsync(1);

        result[true].Should().BeNull();
        result[false].Should().BeNull();
    }

    [Fact]
    public async Task GetAverageScoresForExerciseAsync_averages_non_empty_buckets()
    {
        var ex = ExerciseBuilders.MultipleChoice(1);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ex);
        _logs.Setup(l => l.GetLogExerciseAnswersForExercise(1))
            .ReturnsAsync(new List<LogExerciseAnswer>
            {
                new("u", 0, 1, ["a"], "a", correct: true, studentScore: 2.0),
                new("u", 0, 1, ["a"], "a", correct: true, studentScore: 4.0),
                new("u", 0, 1, ["a"], "x", correct: false, studentScore: 1.0),
            });

        var result = await _sut.GetAverageScoresForExerciseAsync(1);

        result[true].Should().Be(3.0);
        result[false].Should().Be(1.0);
    }

    [Fact]
    public async Task GetExercisesForAdaptiveLessonAsync_does_not_divide_by_zero_when_exercise_difficulty_equals_user_score()
    {
        var user = new ApplicationUserBuilder().WithScore(5.0).WithCourseId(1).WithHighestLesson(1, 1).Build();
        var course = EntityBuilders.Course(1, defaultExerciseLimit: 2);
        var group = EntityBuilders.LessonGroup(id: 1, order: 1, lessonIds: [1]);
        var lesson = EntityBuilders.Lesson(id: 1, exercises: [1, 2]);
        var equalsScore = ExerciseBuilders.MultipleChoice(1, difficulty: 5.0);
        var harder = ExerciseBuilders.MultipleChoice(2, difficulty: 10.0);
        _courses.Setup(s => s.GetCourseByIdAsync(1)).ReturnsAsync(course);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);
        _lessonGroups.Setup(s => s.GetAllLessonGroupsAsync(1)).ReturnsAsync([group]);
        _lessons.Setup(s => s.GetLessonByIDAsync(1)).ReturnsAsync(lesson);
        _exercisesRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(equalsScore);
        _exercisesRepo.Setup(r => r.GetByIdAsync(2)).ReturnsAsync(harder);

        Func<Task> act = () => _sut.GetExercisesForAdaptiveLessonAsync(user);

        await act.Should().NotThrowAsync();
    }
}
