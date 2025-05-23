﻿using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ExerciseDTO(Exercise ex)
    {
        public int PrivateId { get; set; } = ex.PrivateId;
        public string Type { get; set; } = ex.Type;
        public double Difficulty { get; set; } = ex.Difficulty;
        public string? Statement { get; set; } = ex.Statement;
        public string? SpecificTip { get; set; } = ex.SpecificTip;
    }
}
