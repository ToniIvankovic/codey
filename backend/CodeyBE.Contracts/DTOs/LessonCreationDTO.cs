namespace CodeyBE.Contracts.DTOs
{
    public class LessonCreationDTO
    {
        public required int LessonGroupId { get; set; }
        public required string Name { get; set; }
        public IEnumerable<int> Exercises { get; set; } = new List<int>();
    }
}
