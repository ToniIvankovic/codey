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
        public int? HighestLessonId { get; set; }
        public int? HighestLessonGroupId { get; set; }
        public int? NextLessonId { get; set; }
        public int? NextLessonGroupId { get; set; }
        public int TotalXP { get; set; } = 0;
        public List<KeyValuePair<DateTime, int>> XPachieved { get; set; } = [];
    }
}
