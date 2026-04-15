using AspNetCore.Identity.Mongo.Model;
using MongoDB.Bson.Serialization.Attributes;
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
        public int GamificationGroup { get; set; }
        [BsonElement("courseId")]
        public int CourseId { get; set; }
        [BsonIgnore]
        private Course? _course;

        [BsonIgnore]
        public Course Course
        {
            get => _course ?? throw new InvalidOperationException("Course was not initialized.");
            set => _course = value;
        }

        public int CalculateTotalXP()
        {
            return XPachieved.Sum(x => x.Value);
        }

        public int CalculateStreak()
        {
            var today = DateTime.Now.Date;
            var streak = 0;
            var datesSet = XPachieved
                .Where(entry => entry.Value > 0)
                .Select(entry => entry.Key.Date)
                .ToHashSet();
            if (!datesSet.Contains(today))
            {
                today = today.AddDays(-1);
            }
            while (datesSet.Contains(today))
            {
                streak++;
                today = today.AddDays(-1);
            }
            return streak;
        }


        public bool DidLessonToday()
        {
            return XPachieved.Any(x => x.Key.Date == DateTime.Now.Date);
        }

        public int CalculateHighestStreak()
        {
            var activeDates = XPachieved
                .Where(entry => entry.Value > 0)
                .Select(entry => entry.Key.Date)
                .Distinct()
                .OrderBy(date => date)
                .ToList();

            var highest = 0;
            var current = 0;
            DateTime? previous = null;
            foreach (var date in activeDates)
            {
                current = previous is not null && date == previous.Value.AddDays(1) ? current + 1 : 1;
                if (current > highest) highest = current;
                previous = date;
            }
            return highest;
        }
    }
}
