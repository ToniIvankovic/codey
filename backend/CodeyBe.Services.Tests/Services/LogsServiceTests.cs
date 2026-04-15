using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Repositories;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class LogsServiceTests
{
    private readonly Mock<ILogsRepository> _repo = new();
    private readonly LogsService _sut;

    public LogsServiceTests()
    {
        _sut = new LogsService(_repo.Object);
    }

    [Fact]
    public void AnsweredExercise_saves_LogExerciseAnswer()
    {
        var user = new ApplicationUserBuilder().Build();

        _sut.AnsweredExercise(user, exerciseId: 10, correctAnswer: ["a"], givenAnswer: "a", correct: true);

        _repo.Verify(r => r.SaveLogAsync(It.Is<LogExerciseAnswer>(l =>
            l.ExerciseId == 10 && l.MarkedCorrect)), Times.Once);
    }

    [Fact]
    public void RequestedLesson_saves_LogStartLesson()
    {
        var user = new ApplicationUserBuilder().Build();

        _sut.RequestedLesson(user, 7);

        _repo.Verify(r => r.SaveLogAsync(It.IsAny<LogStartLesson>()), Times.Once);
    }

    [Fact]
    public void EndOfLesson_saves_LogEndLesson()
    {
        var user = new ApplicationUserBuilder().Build();
        var report = new EndOfLessonReport
        {
            LessonId = 1, LessonGroupId = 1, CorrectAnswers = 5, TotalAnswers = 5,
            Accuracy = 1.0, DurationMiliseconds = 1000, AnswersReport = []
        };

        _sut.EndOfLesson(user, report);

        _repo.Verify(r => r.SaveLogAsync(It.IsAny<LogEndLesson>()), Times.Once);
    }

    [Fact]
    public void RequestedExercise_is_not_implemented()
    {
        Action act = () => _sut.RequestedExercise(1);

        act.Should().Throw<NotImplementedException>();
    }

    [Fact]
    public async Task GetLogExerciseAnswersForExercise_filters_by_exercise()
    {
        var logs = new List<LogExerciseAnswer>
        {
            new("u", 0, exerciseId: 1, ["a"], "a", true, 1),
            new("u", 0, exerciseId: 2, ["b"], "b", false, 1),
            new("u", 0, exerciseId: 1, ["a"], "x", false, 1),
        };
        _repo.Setup(r => r.GetAllLogExerciseAnswers()).ReturnsAsync(logs);

        var result = (await _sut.GetLogExerciseAnswersForExercise(1)).ToList();

        result.Should().HaveCount(2).And.OnlyContain(l => l.ExerciseId == 1);
    }
}
