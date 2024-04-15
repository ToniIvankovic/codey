using CodeyBE.Contracts.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class Quest
    {
        public required string Type { get; set; }
        public required DateOnly Date { get; set; }
        public int? Constraint { get; set; }
        public required int Progress { get; set; }
        public int? NLessons { get; set; }
        public required bool IsCompleted { get; set; }

        private Quest() { }
        public static Quest CreateGetXPQuest(int XP)
        {
            return new Quest
            {
                Type = QuestTypes.GET_XP,
                Date = DateOnly.FromDateTime(DateTime.Now),
                Constraint = XP,
                Progress = 0,
                IsCompleted = false
            };
        }
        public static Quest CreateHighAccuracyQuest(int percentageAccuracy, int numberOfLessons)
        {
            return new Quest
            {
                Type = QuestTypes.HIGH_ACCURACY,
                Date = DateOnly.FromDateTime(DateTime.Now),
                Constraint = percentageAccuracy,
                Progress = 0,
                NLessons = numberOfLessons,
                IsCompleted = false
            };
        }
        public static Quest CreateHighSpeedQuest(int numberOfSeconds, int numberOfLessons)
        {
            return new Quest
            {
                Type = QuestTypes.HIGH_SPEED,
                Date = DateOnly.FromDateTime(DateTime.Now),
                Constraint = numberOfSeconds,
                Progress = 0,
                NLessons = numberOfLessons,
                IsCompleted = false
            };
        }
        public static Quest CreateCompleteLessonGroupQuest()
        {
            return new Quest
            {
                Type = QuestTypes.COMPLETE_LESSON_GROUP,
                Date = DateOnly.FromDateTime(DateTime.Now),
                Progress = 0,
                IsCompleted = false
            };
        }
    }
}
