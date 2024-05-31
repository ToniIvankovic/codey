using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface ILogsService
    {
        void RequestedLesson(ApplicationUser applicationUser, int lessonId);
        void RequestedExercise(int exerciseId);
        void AnsweredExercise(ApplicationUser applicationUser, int exerciseId, IEnumerable<dynamic> correctAnswers, dynamic givenAnswer, bool correct);
        void EndOfLesson(ApplicationUser applicationUser, EndOfLessonReport report);
        Task<IEnumerable<LogExerciseAnswer>> GetLogExerciseAnswersForExercise(int exerciseId);
    }
}
