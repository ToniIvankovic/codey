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
        void RequestedLesson(ClaimsPrincipal user, int lessonId);
        void RequestedExercise(int exerciseId);
        void AnsweredExercise(ClaimsPrincipal user, int exerciseId, IEnumerable<string> correctAnswers, string givenAnswer, bool correct);
    }
}
