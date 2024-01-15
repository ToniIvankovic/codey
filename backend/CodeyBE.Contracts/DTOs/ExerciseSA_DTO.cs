using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseSA_DTO(Exercise ex) : ExerciseDTO(ex)
    {
        //public List<string>? CorrectAnswers { get; set; } = ex.CorrectAnswers;
    }
}
