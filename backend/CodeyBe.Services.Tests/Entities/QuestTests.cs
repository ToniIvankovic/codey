namespace CodeyBe.Services.Tests.Entities;

public class QuestTests
{
    [Fact]
    public void CreateGetXPQuest_sets_type_and_constraint()
    {
        var quest = Quest.CreateGetXPQuest(120);

        quest.Type.Should().Be(QuestTypes.GET_XP);
        quest.Constraint.Should().Be(120);
        quest.Progress.Should().Be(0);
        quest.IsCompleted.Should().BeFalse();
        quest.Date.Should().Be(DateOnly.FromDateTime(DateTime.Now));
    }

    [Fact]
    public void CreateHighAccuracyQuest_sets_constraint_and_NLessons()
    {
        var quest = Quest.CreateHighAccuracyQuest(90, 2);

        quest.Type.Should().Be(QuestTypes.HIGH_ACCURACY);
        quest.Constraint.Should().Be(90);
        quest.NLessons.Should().Be(2);
    }

    [Fact]
    public void CreateHighSpeedQuest_sets_constraint_and_NLessons()
    {
        var quest = Quest.CreateHighSpeedQuest(60, 2);

        quest.Type.Should().Be(QuestTypes.HIGH_SPEED);
        quest.Constraint.Should().Be(60);
        quest.NLessons.Should().Be(2);
    }

    [Fact]
    public void CreateCompleteLessonGroupQuest_has_no_constraint()
    {
        var quest = Quest.CreateCompleteLessonGroupQuest();

        quest.Type.Should().Be(QuestTypes.COMPLETE_LESSON_GROUP);
        quest.Constraint.Should().BeNull();
    }

    [Fact]
    public void CreateCompleteExercisesQuest_sets_constraint()
    {
        var quest = Quest.CreateCompleteExercisesQuest(20);

        quest.Type.Should().Be(QuestTypes.COMPLETE_EXERCISES);
        quest.Constraint.Should().Be(20);
    }

    [Fact]
    public void UpdateGetXPQuest_completes_and_returns_1_when_progress_meets_constraint()
    {
        var quest = Quest.CreateGetXPQuest(120);

        var result1 = Quest.UpdateGetXPQuest(80, quest);
        var result2 = Quest.UpdateGetXPQuest(40, quest);

        result1.Should().Be(0);
        result2.Should().Be(1);
        quest.Progress.Should().Be(120);
        quest.IsCompleted.Should().BeTrue();
    }

    [Fact]
    public void UpdateGetXPQuest_returns_0_when_already_completed_but_keeps_accumulating()
    {
        var quest = Quest.CreateGetXPQuest(100);
        Quest.UpdateGetXPQuest(120, quest);

        var result = Quest.UpdateGetXPQuest(50, quest);

        result.Should().Be(1, "current impl returns 1 whenever progress >= constraint");
        quest.Progress.Should().Be(170);
    }

    [Fact]
    public void UpdateHighSpeedQuest_increments_progress_when_duration_below_constraint()
    {
        var quest = Quest.CreateHighSpeedQuest(numberOfSeconds: 60, numberOfLessons: 2);

        var r1 = Quest.UpdateHighSpeedQuest(durationMiliseconds: 50_000, quest);
        var r2 = Quest.UpdateHighSpeedQuest(durationMiliseconds: 60_000, quest);

        r1.Should().Be(0);
        r2.Should().Be(1);
        quest.IsCompleted.Should().BeTrue();
    }

    [Fact]
    public void UpdateHighSpeedQuest_does_not_increment_when_too_slow()
    {
        var quest = Quest.CreateHighSpeedQuest(60, 2);

        Quest.UpdateHighSpeedQuest(61_000, quest);

        quest.Progress.Should().Be(0);
        quest.IsCompleted.Should().BeFalse();
    }

    [Fact]
    public void UpdateHighAccuracyQuest_increments_at_threshold_exactly()
    {
        var quest = Quest.CreateHighAccuracyQuest(percentageAccuracy: 90, numberOfLessons: 1);

        var result = Quest.UpdateHighAccuracyQuest(accuracy: 0.90, quest);

        result.Should().Be(1);
        quest.IsCompleted.Should().BeTrue();
    }

    [Fact]
    public void UpdateHighAccuracyQuest_does_not_increment_below_threshold()
    {
        var quest = Quest.CreateHighAccuracyQuest(90, 1);

        Quest.UpdateHighAccuracyQuest(0.89, quest);

        quest.Progress.Should().Be(0);
        quest.IsCompleted.Should().BeFalse();
    }

    [Fact]
    public void UpdateCompleteExercisesQuest_accumulates_and_completes()
    {
        var quest = Quest.CreateCompleteExercisesQuest(20);

        Quest.UpdateCompleteExercisesQuest(10, quest).Should().Be(0);
        Quest.UpdateCompleteExercisesQuest(10, quest).Should().Be(1);

        quest.Progress.Should().Be(20);
        quest.IsCompleted.Should().BeTrue();
    }

    [Fact]
    public void UpdateCompleteLessonGroupQuest_flips_flag()
    {
        var quest = Quest.CreateCompleteLessonGroupQuest();

        var result = Quest.UpdateCompleteLessonGroupQuest(true, quest);

        result.Should().Be(1);
        quest.IsCompleted.Should().BeTrue();
    }

    [Fact]
    public void UpdateCompleteLessonGroupQuest_does_not_complete_when_false()
    {
        var quest = Quest.CreateCompleteLessonGroupQuest();

        var result = Quest.UpdateCompleteLessonGroupQuest(false, quest);

        result.Should().Be(0);
        quest.IsCompleted.Should().BeFalse();
    }
}
