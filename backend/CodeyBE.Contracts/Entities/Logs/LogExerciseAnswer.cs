namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogExerciseAnswer(string userId,
        int userGroup,
        int exerciseId,
        IEnumerable<dynamic> correctAnswer,
        dynamic givenAnswer,
        bool correct,
        double studentScore)
        : LogBasic(userId, userGroup)
    {
        public int ExerciseId { get; set; } = exerciseId;
        public IEnumerable<dynamic> CorrectAnswer { get; set; } = correctAnswer;
        public dynamic GivenAnswer { get; set; } = givenAnswer;
        public bool MarkedCorrect { get; set; } = correct;
        public double StudentScore { get; set; } = studentScore;
    }
}
