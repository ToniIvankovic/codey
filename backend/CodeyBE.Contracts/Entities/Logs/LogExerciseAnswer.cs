namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogExerciseAnswer(string userId,
        int exerciseId,
        IEnumerable<string> correctAnswer,
        string givenAnswer,
        bool correct)
        : LogBasic(userId)
    {
        public int ExerciseId { get; set; } = exerciseId;
        public IEnumerable<string> CorrectAnswer { get; set; } = correctAnswer;
        public string GivenAnswer { get; set; } = givenAnswer;
        public bool MarkedCorrect { get; set; } = correct;
    }
}
