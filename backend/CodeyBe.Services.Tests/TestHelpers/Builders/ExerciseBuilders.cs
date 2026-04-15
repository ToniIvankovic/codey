using CodeyBE.Contracts.DTOs;

namespace CodeyBe.Services.Tests.TestHelpers.Builders;

public static class ExerciseBuilders
{
    public static Exercise BaseExercise(int id, string type, double difficulty = 1.0, int courseId = 1)
    {
        return new Exercise(id, new ExerciseCreationDTO
        {
            Type = type,
            Difficulty = (int)difficulty,
            CourseId = courseId,
        })
        {
            Difficulty = difficulty,
        };
    }

    public static ExerciseMC MultipleChoice(int id = 1, string correctAnswer = "A", double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.MULTIPLE_CHOICE, difficulty);
        ex.Question = "Q?";
        ex.AnswerOptions = new Dictionary<string, string> { { "A", "first" }, { "B", "second" } };
        ex.CorrectAnswer = correctAnswer;
        return new ExerciseMC(ex);
    }

    public static ExerciseSA ShortAnswer(int id = 1, string[]? correctAnswers = null, double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.SHORT_ANSWER, difficulty);
        ex.Question = "Q?";
        ex.CorrectAnswers = [.. (correctAnswers ?? ["answer"]).Cast<dynamic>()];
        return new ExerciseSA(ex);
    }

    public static ExerciseLA LongAnswer(int id = 1, string[]? correctAnswers = null, double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.LONG_ANSWER, difficulty);
        ex.Question = "Q?";
        ex.CorrectAnswers = [.. (correctAnswers ?? ["long answer"]).Cast<dynamic>()];
        ex.AnswerOptionsList = [["long", "answer"]];
        return new ExerciseLA(ex);
    }

    public static ExerciseSCW ShortCodeWriting(int id = 1, List<string>? correctAnswers = null, double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.SHORT_CODE_WRITING, difficulty);
        ex.StatementCode = "code(___)";
        ex.DefaultGapLengths = [5];
        List<dynamic> answers = [correctAnswers ?? ["code"]];
        ex.CorrectAnswers = answers;
        return new ExerciseSCW(ex);
    }

    public static ExerciseORC OrderRearrangeCode(int id = 1, double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.ORDER_REARRANGE_CODE, difficulty);
        ex.AnswerOptionsList = [["line1"], ["line2"], ["line3"]];
        return new ExerciseORC(ex);
    }

    public static ExerciseMTC Match(int id = 1, double difficulty = 1.0)
    {
        var ex = BaseExercise(id, ExerciseTypes.MATCH, difficulty);
        ex.AnswerOptionsList = [["a", "b"], ["1", "2"]];
        return new ExerciseMTC(ex);
    }
}
