using CodeyBE.Contracts.Entities;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseSCW_DTO : ExerciseDTO
    {
        public ExerciseSCW_DTO(Exercise ex) : base(ex)
        {
            // Check requirements
            _ = new ExerciseSCW(ex);
            StatementCode = ex.StatementCode!;
            DefaultGapLengths = ex.DefaultGapLengths!;
            StatementOutput = ex.StatementOutput!;
            CorrectAnswers = ex.CorrectAnswers!;
        }
        public string StatementCode { get; set; }
        public List<int> DefaultGapLengths { get; set; }
        public string StatementOutput { get; set; }
        public List<dynamic> CorrectAnswers { get; set; }
    }
}
