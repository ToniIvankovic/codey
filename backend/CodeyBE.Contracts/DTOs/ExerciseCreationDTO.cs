namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseCreationDTO
    {
        public required string Type { get; set; }
        public required int Difficulty { get; set; }
        public string? Statement { get; set; }
        public string? StatementCode { get; set; }
        public List<int>? DefaultGapLengths { get; set; }
        //public List<int>? DefaultGapLines { get; set; }
        public string? StatementOutput { get; set; }
        public string? Question { get; set; }
        public Dictionary<string, string>? AnswerOptions { get; set; }
        public string? CorrectAnswer { get; set; }
        public List<dynamic>? CorrectAnswers { get; set; }
        public bool? RaisesError { get; set; }
        public string? SpecificTip { get; set; }
    }
}
