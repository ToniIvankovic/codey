using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Services;

public class CoursesServiceTests
{
    private readonly Mock<ICoursesRepository> _repo = new();
    private readonly CoursesService _sut;

    public CoursesServiceTests()
    {
        _sut = new CoursesService(_repo.Object);
    }

    [Fact]
    public async Task GetAllCoursesAsync_delegates_to_repo()
    {
        var courses = new List<Course> { EntityBuilders.Course(1), EntityBuilders.Course(2) };
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(courses);

        var result = await _sut.GetAllCoursesAsync();

        result.Should().BeEquivalentTo(courses);
    }

    [Fact]
    public async Task GetCourseByIdAsync_returns_course_when_found()
    {
        var course = EntityBuilders.Course(5);
        _repo.Setup(r => r.GetByIdAsync(5)).ReturnsAsync(course);

        var result = await _sut.GetCourseByIdAsync(5);

        result.Should().Be(course);
    }

    [Fact]
    public async Task GetCourseByIdAsync_throws_EntityNotFoundException_when_missing()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Course?)null);

        Func<Task> act = () => _sut.GetCourseByIdAsync(99);

        await act.Should().ThrowAsync<EntityNotFoundException>();
    }
}
