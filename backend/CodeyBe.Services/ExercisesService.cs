using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBe.Services
{
    public class ExercisesService : IExercisesService
    {
        private readonly IExercisesRepository _exercisesRepository;
        private readonly ILessonsService _lessonsService;

        public ExercisesService(IExercisesRepository exercisesRepository, ILessonsService lessonsService)
        {
            _exercisesRepository = exercisesRepository;
            _lessonsService = lessonsService;
        }
        public Task<IEnumerable<Exercise>> GetAllExercisesAsync()
        {
            return _exercisesRepository.GetAllAsync();
        }

        public Task<Exercise?> GetExerciseByIDAsync(int id)
        {
            return _exercisesRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<Exercise>> GetExercisesForLessonAsync(int lessonId)
        {
            Lesson? lesson = await _lessonsService.GetLessonByIDAsync(lessonId);
            if (lesson == null)
            {
                return new List<Exercise>();
            }
            IEnumerable<int> exerciseIDs = lesson.Exercises;
            return _exercisesRepository.GetExercisesByID(exerciseIDs);
        }

        public async Task<bool> ValidateAnswer(string exerciseId, string answer)
        {
            Exercise? exercise = await _exercisesRepository.GetByIdAsync(int.Parse(exerciseId));
            if (exercise == null)
            {
                throw new ArgumentException($"Exercise with id {exerciseId} does not exist");
            }
            return ValidateAnswer(exercise, answer);
        }

        private bool ValidateAnswer(Exercise exercise, string answer)
        {
            if (exercise.Type == "SA")
            {
                return ValidateAnswerSA(exercise, answer);
            }
            else if (exercise.Type == "LA")
            {
                return ValidateAnswerLA(exercise, answer);
            }
            else
            {
                throw new NotImplementedException($"Unknown exercise type {exercise.Type}");
            }
        }

        private bool ValidateAnswerSA(Exercise exercise, string answer)
        {
            var correctAnswers = exercise.CorrectAnswers;
            if (answer == null || correctAnswers == null)
            {
                return false;
            }
            return correctAnswers.Contains(answer);
        }

        private bool ValidateAnswerLA(Exercise exercise, string answer)
        {
            var correctAnswers = exercise.CorrectAnswers;
            if (answer == null || correctAnswers == null)
            {
                return false;
            }
            return correctAnswers.Contains(answer);
        }

    }
}
