using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseMTC_DTO : ExerciseDTO
    {
        public ExerciseMTC_DTO(Exercise ex) : base(ex)
        {
            _ = new ExerciseMTC(ex);
            AnswerOptionsList = ex.AnswerOptionsList!;
        }

        public List<List<string>> AnswerOptionsList { get; set; }
    }
}
