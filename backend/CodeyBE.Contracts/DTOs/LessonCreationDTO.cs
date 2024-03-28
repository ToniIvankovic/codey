namespace CodeyBE.Contracts.DTOs
{
    public class LessonCreationDTO
    {
        public required string Name { get; set; }
        public string? SpecificTips { get; set; }
        public IEnumerable<int> Exercises { get; set; } = new List<int>();
    }
}
