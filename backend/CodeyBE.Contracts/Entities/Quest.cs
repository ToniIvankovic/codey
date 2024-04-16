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


        public static int UpdateCompleteLessonGroupQuest(bool completedLessonGroup, Quest quest)
        {
            quest.IsCompleted = completedLessonGroup;
            if (quest.IsCompleted)
            {
                return 1;
            }

            return 0;
        }

        public static int UpdateHighSpeedQuest(int durationMiliseconds, Quest quest)
        {
            quest.Progress += (durationMiliseconds / 1000.0 <= quest.Constraint) ? 1 : 0;
            if (quest.Progress == quest.NLessons)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
        }

        public static int UpdateHighAccuracyQuest(double accuracy, Quest quest)
        {
            quest.Progress += (accuracy >= quest.Constraint / 100.0) ? 1 : 0;
            if (quest.Progress == quest.NLessons)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
        }

        public static int UpdateGetXPQuest(int awardedXP, Quest quest)
        {
            quest.Progress += awardedXP;
            if (quest.Progress >= quest.Constraint)
            {
                quest.IsCompleted = true;
                return 1;
            }

            return 0;
        }
    }
}
