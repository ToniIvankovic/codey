using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class LessonGroupCreationDTO
    {
        public required string Name { get; set; }
        public string? Tips { get; set; }
        public required IEnumerable<int> Lessons { get; set; }
        public int? Order { get; set; }
        public bool? Adaptive { get; set; }
    }
}
