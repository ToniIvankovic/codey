using CodeyBe.Services.Tests.TestHelpers.Builders;

namespace CodeyBe.Services.Tests.Entities;

public class ApplicationUserTests
{
    [Fact]
    public void CalculateTotalXP_is_zero_with_no_entries()
    {
        var user = new ApplicationUserBuilder().Build();

        user.CalculateTotalXP().Should().Be(0);
    }

    [Fact]
    public void CalculateTotalXP_sums_all_entries()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-2), 100)
            .WithXPachieved(DateTime.Now.AddDays(-1), 40)
            .WithXPachieved(DateTime.Now, 60)
            .Build();

        user.CalculateTotalXP().Should().Be(200);
    }

    [Fact]
    public void DidLessonToday_false_when_no_entries_today()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-1), 100)
            .Build();

        user.DidLessonToday().Should().BeFalse();
    }

    [Fact]
    public void DidLessonToday_true_when_entry_today()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now, 40)
            .Build();

        user.DidLessonToday().Should().BeTrue();
    }

    [Fact]
    public void CalculateStreak_is_zero_with_no_entries()
    {
        var user = new ApplicationUserBuilder().Build();

        user.CalculateStreak().Should().Be(0);
    }

    [Fact]
    public void CalculateStreak_is_1_with_only_today()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now, 100)
            .Build();

        user.CalculateStreak().Should().Be(1);
    }

    [Fact]
    public void CalculateStreak_counts_consecutive_days_ending_today()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-2), 50)
            .WithXPachieved(DateTime.Now.AddDays(-1), 60)
            .WithXPachieved(DateTime.Now, 40)
            .Build();

        user.CalculateStreak().Should().Be(3);
    }

    [Fact]
    public void CalculateStreak_counts_consecutive_days_ending_yesterday_when_today_missing()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-3), 50)
            .WithXPachieved(DateTime.Now.AddDays(-2), 60)
            .WithXPachieved(DateTime.Now.AddDays(-1), 40)
            .Build();

        user.CalculateStreak().Should().Be(3);
    }

    [Fact]
    public void CalculateStreak_resets_after_gap()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-10), 40)
            .WithXPachieved(DateTime.Now.AddDays(-9), 40)
            .WithXPachieved(DateTime.Now.AddDays(-1), 40)
            .WithXPachieved(DateTime.Now, 40)
            .Build();

        user.CalculateStreak().Should().Be(2);
    }

    [Fact]
    public void CalculateStreak_ignores_entries_with_zero_xp()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now, 0)
            .Build();

        user.CalculateStreak().Should().Be(0);
    }

    [Fact]
    public void CalculateHighestStreak_matches_longest_consecutive_span()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-20), 40)
            .WithXPachieved(DateTime.Now.AddDays(-19), 40)
            .WithXPachieved(DateTime.Now.AddDays(-18), 40)
            .WithXPachieved(DateTime.Now.AddDays(-17), 40)
            .WithXPachieved(DateTime.Now.AddDays(-10), 40)
            .WithXPachieved(DateTime.Now.AddDays(-9), 40)
            .Build();

        user.CalculateHighestStreak().Should().Be(4);
    }

    [Fact]
    public void CalculateHighestStreak_multiple_entries_same_day_counts_as_one()
    {
        var user = new ApplicationUserBuilder()
            .WithXPachieved(DateTime.Now.AddDays(-1).AddHours(1), 40)
            .WithXPachieved(DateTime.Now.AddDays(-1).AddHours(12), 20)
            .WithXPachieved(DateTime.Now.AddHours(1), 40)
            .Build();

        user.CalculateHighestStreak().Should().Be(2);
    }
}
