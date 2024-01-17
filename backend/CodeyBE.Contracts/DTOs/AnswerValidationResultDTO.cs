using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class AnswerValidationResultDTO
    {
        public int ExerciseID { get; set; }
        public bool IsCorrect { get; set; }

        public AnswerValidationResultDTO(AnswerValidationResult result)
        {
            ExerciseID = result.exercise.PrivateId;
            IsCorrect = result.IsCorrect;
        }
    }
}
