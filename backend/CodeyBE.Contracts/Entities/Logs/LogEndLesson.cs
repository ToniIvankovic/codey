using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CodeyBE.Contracts.Entities;

namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogEndLesson : LogBasic
    {
        public int LessonId { get; set; }
        public int CorrectAnswers { get; set; }
        public int TotalAnswers { get; set; }
        public int Duration { get; set; }
        public double Accuracy { get; set; }

        public LogEndLesson(string userId, int userGroup, int lessonId, int correctAnswers, int totalAnswers, int duration, double accuracy) : base(userId, userGroup)
        {
            LessonId = lessonId;
            CorrectAnswers = correctAnswers;
            TotalAnswers = totalAnswers;
            Duration = duration;
            Accuracy = accuracy;
        }

        public LogEndLesson(string userId, int userGroup, EndOfLessonReport report) : base(userId, userGroup)
        {
            LessonId = report.LessonId;
            CorrectAnswers = report.CorrectAnswers;
            TotalAnswers = report.TotalAnswers;
            Duration = report.DurationMiliseconds;
            Accuracy = report.Accuracy;
        }
    }
}
