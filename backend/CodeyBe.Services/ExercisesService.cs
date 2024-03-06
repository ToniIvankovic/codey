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
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace CodeyBe.Services
{
    public partial class ExercisesService : IExercisesService
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
            IEnumerable<Exercise> exercises = _exercisesRepository.GetExercisesByID(exerciseIDs).Select(exercise =>
            {
                if (exercise is ExerciseLA)
                {
                    GenerateAnswerOptionsForExerciseLA((ExerciseLA)exercise);
                }
                return exercise;
            });
            exercises = exercises.OrderBy(exercise => exercise.PrivateId);
            return exercises;
        }

        private static void GenerateAnswerOptionsForExerciseLA(ExerciseLA exercise)
        {
            var correctAnswer = (string)exercise.CorrectAnswers![0];
            var parts = AnswerSplitterLARegex().Split(correctAnswer);
            exercise.AnswerOptions = [];
            for (int i = 0; i < parts.Length; i++)
            {
                if (parts[i].IsNullOrEmpty())
                    continue;

                exercise.AnswerOptions.Add(i.ToString(), parts[i]);
            }
        }

        [GeneratedRegex("(?<=[\\s\\n])|([\\(\\)])")]
        private static partial Regex AnswerSplitterLARegex();

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
                ExerciseSA exerciseSA = (ExerciseSA)exercise;
                string castAnswer = answer.ToString();
                IEnumerable<string> correctAnswers = exerciseSA.CorrectAnswers!.Select(answer => ((string)answer));
                bool correct = ValidateAnswerSA(exerciseSA, castAnswer);
                return new AnswerValidationResult(exerciseSA,
                                                  correct,
                                                  castAnswer,
                                                  expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "LA")
            {
                ExerciseLA exerciseLA = (ExerciseLA)exercise;
                string castAnswer = answer.ToString();
                bool correct = ValidateAnswerLA(exerciseLA, castAnswer);
                IEnumerable<string> correctAnswers = exerciseLA.CorrectAnswers!.Select(answer => ((string)answer));
                return new AnswerValidationResult(exerciseLA,
                    correct,
                    castAnswer,
                    expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "MC")
            {
                ExerciseMC exerciseMC = (ExerciseMC)exercise;
                string castAnswer = answer.ToString();
                IEnumerable<string> correctAnswers = new List<string>([exerciseMC.CorrectAnswer!]);
                return new AnswerValidationResult(exerciseMC,
                    exerciseMC.CorrectAnswer == castAnswer,
                    castAnswer,
                    expectedAnswers: correctAnswers);
            }
            else if (exercise.Type == "SCW")
            {
                ExerciseSCW exerciseSCW = (ExerciseSCW)exercise;
                List<string> castAnswer = [];
                foreach (JsonElement element in answer.EnumerateArray())
                {
                    castAnswer.Add(element.GetString()!);
                }
                IEnumerable<IEnumerable<string>> correctAnswers = exerciseSCW.CorrectAnswers!.Select(d => ((List<object>)d).Cast<string>().ToList()).ToList();
                bool correct = ValidateAnswerSCW(correctAnswers, castAnswer);
                return new AnswerValidationResult(exerciseSCW,
                                        correct,
                                        castAnswer,
                                        expectedAnswers: correctAnswers);
            }
            else
            {
                throw new NotImplementedException($"Unknown exercise type {exercise.Type}");
            }
        }

        private bool ValidateAnswerSA(ExerciseSA exercise, string answer)
        {
            List<dynamic> correctAnswers = exercise.CorrectAnswers!;
            if (answer == null)
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
                    if (j == correctAnswers.ElementAt(i).Count() - 1)
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        private bool ValidateAnswerLA(ExerciseLA exercise, string answer)
        {
            List<dynamic> correctAnswers = exercise.CorrectAnswers!;
            if (answer == null)
            {
                return false;
            }
            return correctAnswers.Contains(answer);
        }

    }
}
