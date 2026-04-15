using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class LessonsServiceTests
{
    private readonly Mock<ILessonsRepository> _lessonsRepo = new();
    private readonly Mock<ILessonGroupsService> _lessonGroups = new();
    private readonly LessonsService _sut;

    public LessonsServiceTests()
    {
        _sut = new LessonsService(_lessonsRepo.Object, _lessonGroups.Object);
    }

    [Fact]
    public async Task GetAllLessonsAsync_delegates_to_repository()
    {
        var lessons = new List<Lesson> { EntityBuilders.Lesson(1), EntityBuilders.Lesson(2) };
        _lessonsRepo.Setup(r => r.GetAllAsync(42)).ReturnsAsync(lessons);

        var result = await _sut.GetAllLessonsAsync(42);

        result.Should().BeEquivalentTo(lessons);
    }

    [Fact]
    public async Task GetLessonByIDAsync_returns_null_when_not_found()
    {
        _lessonsRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Lesson?)null);

        var result = await _sut.GetLessonByIDAsync(99);

        result.Should().BeNull();
    }

    [Fact]
    public async Task GetLessonsForLessonGroupAsync_throws_when_group_missing()
    {
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(5)).ReturnsAsync((LessonGroup?)null);

        Func<Task> act = () => _sut.GetLessonsForLessonGroupAsync(5);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task GetLessonsForLessonGroupAsync_returns_hardcoded_adaptive_lessons_for_adaptive_group()
    {
        var adaptiveGroup = EntityBuilders.LessonGroup(id: 10, adaptive: true);
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(10)).ReturnsAsync(adaptiveGroup);

        var result = (await _sut.GetLessonsForLessonGroupAsync(10)).ToList();

        result.Should().HaveCount(2);
        result.Select(l => l.PrivateId).Should().BeEquivalentTo([99998, 99999]);
        result.Should().OnlyContain(l => l.Adaptive == true);
    }

    [Fact]
    public async Task GetLessonsForLessonGroupAsync_returns_lessons_in_group_order()
    {
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [3, 1, 2]);
        var allLessons = new List<Lesson>
        {
            EntityBuilders.Lesson(1),
            EntityBuilders.Lesson(2),
            EntityBuilders.Lesson(3),
        };
        _lessonGroups.Setup(s => s.GetLessonGroupByIDAsync(1)).ReturnsAsync(group);
        _lessonsRepo.Setup(r => r.GetAllAsync()).ReturnsAsync(allLessons);

        var result = (await _sut.GetLessonsForLessonGroupAsync(1)).ToList();

        result.Select(l => l.PrivateId).Should().Equal(3, 1, 2);
    }

    [Fact]
    public async Task GetNextLessonIdForLessonId_returns_next_in_same_group()
    {
        var group = EntityBuilders.LessonGroup(id: 1, lessonIds: [10, 20, 30]);

        var nextId = await _sut.GetNextLessonIdForLessonId(20, group);

        nextId.Should().Be(30);
    }

    [Fact]
    public async Task GetNextLessonIdForLessonId_advances_to_next_group_when_at_end()
    {
        var current = EntityBuilders.LessonGroup(id: 1, lessonIds: [10, 20]);
        var next = EntityBuilders.LessonGroup(id: 2, lessonIds: [30, 40]);
        _lessonGroups.Setup(s => s.GetNextLessonGroupForLessonGroupId(1)).ReturnsAsync(next);

        var nextId = await _sut.GetNextLessonIdForLessonId(20, current);

        nextId.Should().Be(30);
    }

    [Fact]
    public async Task GetNextLessonIdForLessonId_throws_when_no_next_group()
    {
        var current = EntityBuilders.LessonGroup(id: 1, lessonIds: [10]);
        _lessonGroups.Setup(s => s.GetNextLessonGroupForLessonGroupId(1)).ReturnsAsync((LessonGroup?)null);

        Func<Task> act = () => _sut.GetNextLessonIdForLessonId(10, current);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task CreateLessonAsync_rejects_exercise_limit_of_zero()
    {
        var dto = new LessonCreationDTO { Name = "L", CourseId = 1, ExerciseLimit = 0 };

        Func<Task> act = () => _sut.CreateLessonAsync(dto);

        await act.Should().ThrowAsync<ArgumentException>();
        _lessonsRepo.Verify(r => r.CreateAsync(It.IsAny<LessonCreationDTO>()), Times.Never);
    }

    [Fact]
    public async Task CreateLessonAsync_allows_null_and_minus_one_limit()
    {
        _lessonsRepo.Setup(r => r.CreateAsync(It.IsAny<LessonCreationDTO>()))
            .ReturnsAsync(EntityBuilders.Lesson(1));

        await _sut.CreateLessonAsync(new LessonCreationDTO { Name = "a", CourseId = 1, ExerciseLimit = null });
        await _sut.CreateLessonAsync(new LessonCreationDTO { Name = "b", CourseId = 1, ExerciseLimit = -1 });
        await _sut.CreateLessonAsync(new LessonCreationDTO { Name = "c", CourseId = 1, ExerciseLimit = 10 });

        _lessonsRepo.Verify(r => r.CreateAsync(It.IsAny<LessonCreationDTO>()), Times.Exactly(3));
    }

    [Fact]
    public async Task DeleteLessonAsync_delegates_to_repo()
    {
        await _sut.DeleteLessonAsync(7);

        _lessonsRepo.Verify(r => r.DeleteAsync(7), Times.Once);
    }
}
