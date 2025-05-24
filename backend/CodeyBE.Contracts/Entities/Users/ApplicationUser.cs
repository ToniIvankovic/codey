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
        public int GamificationGroup { get; set; }

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
            var highestStreak = 0;
            var currentStreak = 0;
            var sortedXP = XPachieved.OrderByDescending(x => x.Key).ToList();
            DateTime? lastDate = null;

            for (int i = 0; i < sortedXP.Count; i++)
            {
                if (sortedXP[i].Value > 0 && (lastDate == null || sortedXP[i].Key.AddDays(1) == lastDate.Value))
                {
                    currentStreak++;
                    lastDate = sortedXP[i].Key; // Update lastDate to the current date

                    // Skip XP entries from the same day
                    while (i < sortedXP.Count - 1 && sortedXP[i].Key.Date == sortedXP[i + 1].Key.Date)
                    {
                        i++;
                    }
                }
                else
                {
                    if (currentStreak > highestStreak)
                    {
                        highestStreak = currentStreak;
                    }
                    currentStreak = 0;
                }
            }

            if (currentStreak > highestStreak)
            {
                highestStreak = currentStreak;
            }

            return highestStreak;
        }
    }
}
