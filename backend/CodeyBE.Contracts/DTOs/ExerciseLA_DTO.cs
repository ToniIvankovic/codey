﻿using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseLA_DTO : ExerciseDTO
    {
        public ExerciseLA_DTO(Exercise ex) : base(ex)
        {
            // Check requirements
            _ = new ExerciseLA(ex);
            AnswerOptions = ex.AnswerOptions!;
            CorrectAnswers = ex.CorrectAnswers!;
            StatementOutput = ex.StatementOutput;
        }

        public Dictionary<string, string> AnswerOptions { get; set; }
        public List<dynamic> CorrectAnswers { get; set; }
        public string? StatementOutput { get; set; }
    }
}
