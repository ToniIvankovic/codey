using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class EndOfLessonDTO
    {
        public required UserDataDTO User { get; set; }
        public required int AwardedXP { get; set; }
    }
}
