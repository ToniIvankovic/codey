using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseORC_DTO : ExerciseDTO
    {
        public ExerciseORC_DTO(Exercise ex) : base(ex)
        {
            _ = new ExerciseORC(ex);
            AnswerOptionsList = ex.AnswerOptionsList!;
        }

        public List<List<string>> AnswerOptionsList { get; set; }
    }
}
