using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseSA_DTO : ExerciseDTO
    {
        public ExerciseSA_DTO(Exercise ex) : base(ex)
        {
            // Check requirements
            _ = new ExerciseSA(ex);
            StatementCode = ex.StatementCode;
            Question = ex.Question!;
            RaisesError = ex.RaisesError;
            CorrectAnswers = ex.CorrectAnswers;
            StatementOutput = ex.StatementOutput;
        }
        public string? StatementCode { get; set; }
        public string Question { get; set; }
        public bool? RaisesError { get; set; }
        public List<dynamic>? CorrectAnswers { get; set; }
        public string? StatementOutput { get; set; }
    }
}
