using CodeyBE.Contracts.Entities;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseSCW_DTO(Exercise ex) : ExerciseDTO(ex)
    {
        public string StatementCode { get; set; } = ex.StatementCode!;
        public List<int> DefaultGapLengths { get; set; } = ex.DefaultGapLengths!;
        public List<int> DefaultGapLines { get; set; } = ex.DefaultGapLines!;
        public string StatementOutput { get; set; } = ex.StatementOutput!;
    }
}
