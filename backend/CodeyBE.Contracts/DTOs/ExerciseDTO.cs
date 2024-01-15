using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseDTO
    {
        public int PrivateId { get; set; }
        public string Type { get; set; }
        public int Difficulty { get; set; }
        public string? Statement { get; set; }
        public string? StatementCode { get; set; }
        public string? Question { get; set; }
        public string? SpecificTip { get; set; }

        public ExerciseDTO(Exercise ex)
        {
            PrivateId = ex.PrivateId;
            Type = ex.Type;
            Difficulty = ex.Difficulty;
            Statement = ex.Statement;
            StatementCode = ex.StatementCode;
            Question = ex.Question;
            SpecificTip = ex.SpecificTip;
        }
    }
}
