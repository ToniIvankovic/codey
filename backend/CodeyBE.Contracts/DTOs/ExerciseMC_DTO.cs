using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseMC_DTO : ExerciseDTO
    {
        public ExerciseMC_DTO(Exercise ex) : base(ex)
        {
            // Check requirements
            _ = new ExerciseMC(ex);
            StatementCode = ex.StatementCode!;
            Question = ex.Question!;
            AnswerOptions = ex.AnswerOptions!;
            CorrectAnswer = ex.CorrectAnswer!;
        }

        public string? StatementCode { get; set; }
        public string Question { get; set; }
        public Dictionary<string, string> AnswerOptions { get; set; }
        public string CorrectAnswer { get; set; }
    }
}
