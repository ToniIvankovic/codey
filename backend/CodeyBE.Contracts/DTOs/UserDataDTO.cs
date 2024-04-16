using CodeyBE.Contracts.Entities;
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
        public int? CurrentStreak { get; set; }
        public bool? DidLessonToday { get; set; }
        public bool? JustUpdatedStreak { get; set; }
        public required int? HighestStreak { get; set; }
        public ISet<Quest>? DailyQuests { get; set; }
        public required double Score { get; set; }

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
                TotalXP = ApplicationUser.CalculateTotalXP(user), //TODO: ApplicationUser field totalXP not used
                XPachieved = user.XPachieved,
                HighestStreak = CalculateHighestStreak(user),
                CurrentStreak = CalculateStreak(user),
                JustUpdatedStreak = CalculateDidLessonToday(user)
                    && user.XPachieved
                        .Select(u => u.Key.Date)
                        .Where(date => date == DateTime.Now.Date)
                        .Count() == 1,
                DidLessonToday = CalculateDidLessonToday(user),
                DailyQuests = user.Quests
                    ?.Where(q => q.Key == DateOnly.FromDateTime(DateTime.Now))
                    .SelectMany(q => q.Value)
                    .ToHashSet()
                    ?? [],
                Score = user.Score
            };
        }

        public static int CalculateStreak(ApplicationUser user)
        {
            var today = DateTime.Now.Date;
            var streak = 0;
            var datesSet = user.XPachieved
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


        public static bool CalculateDidLessonToday(ApplicationUser user)
        {
            return user.XPachieved.Any(x => x.Key.Date == DateTime.Now.Date);
        }

        public static int CalculateHighestStreak(ApplicationUser user)
        {
            var highestStreak = 0;
            var currentStreak = 0;
            var sortedXP = user.XPachieved.OrderByDescending(x => x.Key).ToList();
            for (int i = 0; i < sortedXP.Count; i++)
            {
                if (sortedXP[i].Value > 0)
                {
                    currentStreak++;
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
