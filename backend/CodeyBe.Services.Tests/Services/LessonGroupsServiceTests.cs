using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class LessonGroupsServiceTests
{
    private readonly Mock<ILessonGroupsRepository> _repo = new();
    private readonly LessonGroupsService _sut;

    public LessonGroupsServiceTests()
    {
        _sut = new LessonGroupsService(_repo.Object);
    }

    [Fact]
    public async Task GetFirstLessonGroupIdAsync_returns_order_1_group_id()
    {
        var group = EntityBuilders.LessonGroup(id: 42, order: 1);
        _repo.Setup(r => r.GetLessonGroupByOrderAsync(1, 1)).ReturnsAsync(group);

        var id = await _sut.GetFirstLessonGroupIdAsync(1);

        id.Should().Be(42);
    }

    [Fact]
    public async Task GetFirstLessonGroupIdAsync_throws_when_no_group_exists()
    {
        _repo.Setup(r => r.GetLessonGroupByOrderAsync(1, 1)).ReturnsAsync((LessonGroup?)null);

        Func<Task> act = () => _sut.GetFirstLessonGroupIdAsync(1);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task GetAllLessonGroupsAsync_filters_by_course()
    {
        var all = new List<LessonGroup>
        {
            EntityBuilders.LessonGroup(id: 1, courseId: 1),
            EntityBuilders.LessonGroup(id: 2, courseId: 2),
            EntityBuilders.LessonGroup(id: 3, courseId: 1),
        };
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(all);

        var result = (await _sut.GetAllLessonGroupsAsync(1)).ToList();

        result.Select(g => g.PrivateId).Should().BeEquivalentTo([1, 3]);
    }

    [Fact]
    public async Task GetNextLessonGroupForLessonGroupId_throws_when_current_missing()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync((LessonGroup?)null);

        Func<Task> act = () => _sut.GetNextLessonGroupForLessonGroupId(1);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }

    [Fact]
    public async Task GetNextLessonGroupForLessonGroupId_returns_next_by_order()
    {
        var current = EntityBuilders.LessonGroup(id: 1, courseId: 1, order: 3);
        var next = EntityBuilders.LessonGroup(id: 2, courseId: 1, order: 4);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(current);
        _repo.Setup(r => r.GetLessonGroupByOrderAsync(1, 4)).ReturnsAsync(next);

        var result = await _sut.GetNextLessonGroupForLessonGroupId(1);

        result.Should().Be(next);
    }

    [Fact]
    public async Task GetNextLessonGroupForLessonGroupId_returns_null_at_last_group()
    {
        var current = EntityBuilders.LessonGroup(id: 1, order: 99);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(current);
        _repo.Setup(r => r.GetLessonGroupByOrderAsync(It.IsAny<int>(), 100)).ReturnsAsync((LessonGroup?)null);

        var result = await _sut.GetNextLessonGroupForLessonGroupId(1);

        result.Should().BeNull();
    }

    [Fact]
    public async Task CreateLessonGroupAsync_delegates_to_repo()
    {
        var dto = new LessonGroupCreationDTO { Name = "L", Lessons = [1], CourseId = 1 };
        var created = EntityBuilders.LessonGroup(id: 1);
        _repo.Setup(r => r.CreateAsync(dto)).ReturnsAsync(created);

        var result = await _sut.CreateLessonGroupAsync(dto);

        result.Should().Be(created);
    }

    [Fact]
    public async Task UpdateLessonGroupOrderAsync_delegates_to_repo()
    {
        var input = new List<LessonGroupsReorderDTO> { new() { Id = 1, Order = 2 } };
        var output = new List<LessonGroup> { EntityBuilders.LessonGroup(id: 1, order: 2) };
        _repo.Setup(r => r.UpdateOrderAsync(input)).ReturnsAsync(output);

        var result = await _sut.UpdateLessonGroupOrderAsync(input);

        result.Should().BeEquivalentTo(output);
    }
}
