using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using System.Security.Claims;

namespace CodeyBe.Services
{
    public class LogsService(ILogsRepository logsRepository) : ILogsService
    {
        private readonly ILogsRepository _logsRepository = logsRepository;

        public void AnsweredExercise(ClaimsPrincipal user, int exerciseId, IEnumerable<string> correctAnswer, string givenAnswer, bool correct)
        {
            _logsRepository.SaveLogAsync(
                new LogExerciseAnswer(
                    userId: user.Claims.First(c => c.Type == ClaimTypes.Email).Value,
                    exerciseId,
                    correctAnswer,
                    givenAnswer,
                    correct
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
    }
}
