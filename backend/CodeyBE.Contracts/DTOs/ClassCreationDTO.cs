﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class ClassCreationDTO
    {
        public required string Name { get; set; }
        public required List<string> StudentUsernames { get; set; }
    }
}
