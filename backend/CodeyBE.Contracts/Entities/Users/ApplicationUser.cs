using AspNetCore.Identity.Mongo.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities.Users
{
    public class ApplicationUser : MongoUser
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public int? HighestLessonId { get; set; }
        public int? HighestLessonGroupId { get; set; }
        public int? NextLessonId { get; set; }
        public int? NextLessonGroupId { get; set; }
        public int TotalXP { get; set; }
        public List<KeyValuePair<DateTime, int>> XPachieved { get; set; } = [];
        public string? School { get; set; }
        public List<KeyValuePair<DateOnly, ISet<Quest>>>? Quests { get; set; } = [];
        public double Score { get; set; } = 1;

        public static int CalculateTotalXP(ApplicationUser user)
        {
            return user.XPachieved.Sum(x => x.Value);
        }
    }
}
