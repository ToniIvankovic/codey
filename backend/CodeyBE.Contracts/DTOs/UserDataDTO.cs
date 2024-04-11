using CodeyBE.Contracts.Entities.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class UserDataDTO
    {
        public required string Email { get; set; }
        public int? HighestLessonId { get; set; }
        public int? HighestLessonGroupId { get; set; }
        public int? NextLessonId { get; set; }
        public int? NextLessonGroupId { get; set; }
        public required List<string>? Roles { get; set; }
        public required int TotalXP { get; set; }
        public required List<KeyValuePair<DateTime, int>> XPachieved { get; set; }
        public int? ClassId { get; set; }

        public static UserDataDTO FromUser(ApplicationUser user)
        {
            return new UserDataDTO
            {
                Email = user.Email ?? throw new MissingFieldException("Email missing for user"),
                HighestLessonId = user.HighestLessonId,
                HighestLessonGroupId = user.HighestLessonGroupId,
                NextLessonId = user.NextLessonId,
                NextLessonGroupId = user.NextLessonGroupId,
                Roles = user.Roles,
                TotalXP = user.TotalXP,
                XPachieved = user.XPachieved,
            };
        }
    }
}
