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

        public LogEndLesson(string userId, int lessonId, int correctAnswers, int totalAnswers, int duration, double accuracy) : base(userId)
        {
            LessonId = lessonId;
            CorrectAnswers = correctAnswers;
            TotalAnswers = totalAnswers;
            Duration = duration;
            Accuracy = accuracy;
        }

        public LogEndLesson(string userId, EndOfLessonReport report) : base(userId)
        {
            LessonId = report.LessonId;
            CorrectAnswers = report.CorrectAnswers;
            TotalAnswers = report.TotalAnswers;
            Duration = report.DurationMiliseconds;
            Accuracy = report.Accuracy;
        }
    }
}
