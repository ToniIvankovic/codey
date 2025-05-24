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
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateOnly? DateOfBirth { get; set; }
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
        public required bool GamificationEnabled { get; set; }

        public static UserDataDTO FromUser(ApplicationUser user)
        {
            return new UserDataDTO
            {
                FirstName = user.FirstName,
                LastName = user.LastName,
                DateOfBirth = user.DateOfBirth,
                Email = user.Email ?? throw new MissingFieldException("Email missing for user"),
                HighestLessonId = user.HighestLessonId,
                HighestLessonGroupId = user.HighestLessonGroupId,
                NextLessonId = user.NextLessonId,
                NextLessonGroupId = user.NextLessonGroupId,
                Roles = user.Roles,
                TotalXP = user.CalculateTotalXP(), //TODO: ApplicationUser field totalXP not used
                XPachieved = user.XPachieved,
                HighestStreak = user.CalculateHighestStreak(),
                CurrentStreak = user.CalculateStreak(),
                JustUpdatedStreak = user.DidLessonToday()
                    && user.XPachieved
                        .Select(u => u.Key.Date)
                        .Where(date => date == DateTime.Now.Date)
                        .Count() == 1,
                DidLessonToday = user.DidLessonToday(),
                DailyQuests = user.Quests
                    ?.Where(q => q.Key == DateOnly.FromDateTime(DateTime.Now))
                    .SelectMany(q => q.Value)
                    .ToHashSet()
                    ?? [],
                Score = user.Score,
                GamificationEnabled = true // ENABLE IF TESTING WITH CONTROL GROUP user.GamificationGroup != 1
            };
        }
    }
}
