using CodeyBE.Contracts.DTOs;
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

        public async Task<AnswerValidationResult> ValidateAnswer(string exerciseId, string answer)
        {
            Exercise? exercise = await _exercisesRepository.GetByIdAsync(int.Parse(exerciseId));
            if (exercise == null)
            {
                throw new ArgumentException($"Exercise with id {exerciseId} does not exist");
            }
            return ValidateAnswer(exercise, answer);
        }

        private AnswerValidationResult ValidateAnswer(Exercise exercise, string answer)
        {
            if (exercise.Type == "SA")
            {

                bool correct = ValidateAnswerSA(exercise, answer);
                return new AnswerValidationResult(exercise,
                                                  correct,
                                                  answer,
                                                  expectedAnswers: exercise.CorrectAnswers);
            }
            else if (exercise.Type == "LA")
            {
                bool correct = ValidateAnswerLA(exercise, answer);
                return new AnswerValidationResult(exercise, correct, answer, expectedAnswers: exercise.CorrectAnswers);
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

        public ExerciseDTO MapToSpecificExerciseDTOType(Exercise exercise)
        {
            return exercise.Type switch
            {
                "MC" => new ExerciseMC_DTO(exercise),
                "SA" => new ExerciseSA_DTO(exercise),
                "LA" => new ExerciseLA_DTO(exercise),
                _ => new ExerciseDTO(exercise),
            };
        }
    }
}
