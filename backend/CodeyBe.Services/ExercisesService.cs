using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
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

        public async Task<AnswerValidationResult> ValidateAnswer(int exerciseId, JsonElement answer)
        {
            Exercise? exercise = await _exercisesRepository.GetByIdAsync(exerciseId);
            if (exercise == null)
            {
                throw new ArgumentException($"Exercise with id {exerciseId} does not exist");
            }
            return ValidateAnswer(exercise, answer);
        }

        private AnswerValidationResult ValidateAnswer(Exercise exercise, JsonElement answer)
        {
            //convert System.Text.Json.JsonElement answer to string

            if (exercise.Type == "SA")
            {
                string castAnswer = answer.ToString();
                IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(answer => ((string)answer));
                bool correct = ValidateAnswerSA(exercise, castAnswer);
                return new AnswerValidationResult(exercise,
                                                  correct,
                                                  castAnswer,
                                                  expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "LA")
            {
                string castAnswer = answer.ToString();
                bool correct = ValidateAnswerLA(exercise, castAnswer);
                IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(answer => ((string)answer));
                return new AnswerValidationResult(exercise,
                    correct,
                    castAnswer,
                    expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "MC")
            {
                string castAnswer = answer.ToString();
                IEnumerable<string> correctAnswers = new List<string>([exercise.CorrectAnswer!]);
                return new AnswerValidationResult(exercise,
                    exercise.CorrectAnswer == castAnswer,
                    castAnswer,
                    expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "SCW")
            {
                List<string> castAnswer = [];
                foreach (JsonElement element in answer.EnumerateArray())
                {
                    castAnswer.Add(element.GetString()!);
                }
                IEnumerable<IEnumerable<string>> correctAnswers = exercise.CorrectAnswers!.Select(d => ((List<object>)d).Cast<string>().ToList()).ToList();
                bool correct = ValidateAnswerSCW(correctAnswers, castAnswer);
                return new AnswerValidationResult(exercise,
                                        correct,
                                        castAnswer,
                                        expectedAnswers: correctAnswers);
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

        private bool ValidateAnswerSCW(IEnumerable<IEnumerable<string>> correctAnswers, IEnumerable<string> givenAnswers)
        {
            if (givenAnswers.IsNullOrEmpty() || correctAnswers.IsNullOrEmpty())
            {
                return false;
            }
            if (correctAnswers.Count() != givenAnswers.Count())
            {
                return false;
            }
            for (int i = 0; i < givenAnswers.Count(); i++)
            {
                for (int j = 0; j < correctAnswers.ElementAt(i).Count(); j++)
                {
                    if (correctAnswers.ElementAt(i).ElementAt(j) == givenAnswers.ElementAt(i))
                    {
                        break;
                    }
                    if(j == correctAnswers.ElementAt(i).Count() - 1)
                    {
                        return false;
                    }
                }
            }
            return true;
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
                "SCW" => new ExerciseSCW_DTO(exercise),
                _ => new ExerciseDTO(exercise),
            };
        }
    }
}
