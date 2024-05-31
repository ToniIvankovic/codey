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
                    userGroup: applicationUser.GamificationGroup,
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

        public void RequestedLesson(ApplicationUser applicationUser, int lessonId)
        {
            _logsRepository.SaveLogAsync(
                new LogStartLesson(
                    userId: applicationUser.UserName!,
                    userGroup: applicationUser.GamificationGroup,
                    lessonId
            ));
        }

        public void EndOfLesson(ApplicationUser applicationUser, EndOfLessonReport report)
        {
            _logsRepository.SaveLogAsync(
                new LogEndLesson(
                    userId: applicationUser.UserName!,
                    userGroup: applicationUser.GamificationGroup,
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
