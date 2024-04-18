using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using System.Security.Claims;

namespace CodeyBe.Services
{
    public class LogsService(ILogsRepository logsRepository) : ILogsService
    {
        private readonly ILogsRepository _logsRepository = logsRepository;

        public void AnsweredExercise(
            ApplicationUser applicationUser, 
            int exerciseId, 
            IEnumerable<dynamic> correctAnswer, 
            dynamic givenAnswer, 
            bool correct)
        {
            _logsRepository.SaveLogAsync(
                new LogExerciseAnswer(
                    userId: applicationUser.Email,
                    exerciseId,
                    correctAnswer,
                    givenAnswer,
                    correct,
                    applicationUser.Score
            ));
        }

        public void RequestedExercise(int exerciseId)
        {
            throw new NotImplementedException();
        }

        public void RequestedLesson(ClaimsPrincipal user, int lessonId)
        {
            _logsRepository.SaveLogAsync(
                new LogStartLesson(
                    userId: user.Claims.First(c => c.Type == ClaimTypes.Email).Value,
                    lessonId
            ));
        }

        public void EndOfLesson(ClaimsPrincipal user, EndOfLessonReport report)
        {
            _logsRepository.SaveLogAsync(
                new LogEndLesson(
                    userId: user.Claims.First(c => c.Type == ClaimTypes.Email).Value,
                    report
                    ));

        }

        public async Task<IEnumerable<LogExerciseAnswer>> GetLogExerciseAnswersForExercise(int exerciseId)
        {
            return (await _logsRepository.GetAllLogExerciseAnswers())
                .Where(l => l.ExerciseId == exerciseId)
                .ToList();
        }
    }
}
