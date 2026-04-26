using CodeyBE.API.Controllers;
using CodeyBE.Contracts.Services;
using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Controllers;

public class CoursesControllerTests
{
    private readonly Mock<ICoursesService> _courses = new();
    private readonly CoursesController _sut;

    public CoursesControllerTests()
    {
        _sut = new CoursesController(_courses.Object);
    }

    [Fact]
    public async Task GetAllCourses_maps_course_entities_to_summary_dtos()
    {
        var courses = new List<Course>
        {
            EntityBuilders.Course(1, defaultExerciseLimit: 5),
            EntityBuilders.Course(2, defaultExerciseLimit: 10),
        };
        _courses.Setup(s => s.GetAllCoursesAsync()).ReturnsAsync(courses);

        var result = (await _sut.GetAllCourses()).ToList();

        result.Should().HaveCount(2);
        result[0].Id.Should().Be(1);
        result[0].DefaultExerciseLimit.Should().Be(5);
        result[1].Id.Should().Be(2);
    }

    [Fact]
    public async Task GetAllCourses_returns_empty_when_no_courses()
    {
        _courses.Setup(s => s.GetAllCoursesAsync()).ReturnsAsync([]);

        var result = await _sut.GetAllCourses();

        result.Should().BeEmpty();
    }
}
