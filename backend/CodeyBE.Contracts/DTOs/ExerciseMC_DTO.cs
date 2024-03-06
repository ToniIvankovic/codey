using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseMC_DTO(ExerciseMC ex) : ExerciseDTO(ex)
    {
        public string? StatementCode { get; set; } = ex.StatementCode;
        public string Question { get; set; } = ex.Question!;
        public Dictionary<string, string> AnswerOptions { get; set; } = ex.AnswerOptions!;
        public string CorrectAnswer { get; set; } = ex.CorrectAnswer!;
    }
}
