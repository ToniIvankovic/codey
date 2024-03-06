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
            bool correct;
            dynamic castAnswer;
            IEnumerable<dynamic> correctAnswers;
            //convert System.Text.Json.JsonElement answer to string
            if (exercise is ExerciseSA exerciseSA)
            {
                castAnswer = answer.ToString();
                correctAnswers = exerciseSA.CorrectAnswers!.Select(answer => ((string)answer));
                correct = ValidateAnswerSA(exerciseSA, castAnswer);

            }
            else if (exercise is ExerciseLA exerciseLA)
            {
                castAnswer = answer.ToString();
                correct = ValidateAnswerLA(exerciseLA, castAnswer);
                correctAnswers = exerciseLA.CorrectAnswers!.Select(answer => ((string)answer));
            }
            else if (exercise is ExerciseMC exerciseMC)
            {
                castAnswer = answer.ToString();
                correctAnswers = new List<string>([exerciseMC.CorrectAnswer!]);
                correct = exerciseMC.CorrectAnswer == castAnswer;
            }
            else if (exercise is ExerciseSCW exerciseSCW)
            {
                castAnswer = new List<string>();
                foreach (JsonElement element in answer.EnumerateArray())
                {
                    castAnswer.Add(element.GetString()!);
                }
                correctAnswers = exerciseSCW.CorrectAnswers!.Select(d => ((List<object>)d).Cast<string>().ToList()).ToList();
                correct = ValidateAnswerSCW((IEnumerable<IEnumerable<string>>)correctAnswers, castAnswer);
            }
            else
            {
                throw new NotImplementedException($"Unknown exercise type {exercise.Type}");
            }

            return new AnswerValidationResult(exercise,
                                                  correct,
                                                  castAnswer,
                                                  expectedAnswers: correctAnswers);
        }

        private bool ValidateAnswerSA(ExerciseSA exercise, string answer)
        {
            IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(d => ((string)d));
            return CompareAnswers(answer, correctAnswers, allowTrim: true, allowCaseInsensitive: true);
        }

        private bool ValidateAnswerSCW(IEnumerable<IEnumerable<string>> correctAnswers, IEnumerable<string> givenAnswers)
        {
            if (correctAnswers.Count() != givenAnswers.Count())
            {
                return false;
            }
            for (int i = 0; i < givenAnswers.Count(); i++)
            {
                string answer = givenAnswers.ElementAt(i);
                IEnumerable<string> correctAnswersFori = correctAnswers.ElementAt(i);
                bool currentMatch = CompareAnswers(
                    answer,
                    correctAnswers: correctAnswersFori,
                    allowTrim: true,
                    allowCaseInsensitive: true);

                if (!currentMatch)
                {
                    return false;
                }
            }
            return true;
        }

        private bool ValidateAnswerLA(ExerciseLA exercise, string answer)
        {
            IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(d => ((string)d));
            if (answer == null)
            {
                return false;
            }
            return CompareAnswers(answer, correctAnswers, allowTrim: true, allowCaseInsensitive: true);
        }

        private bool CompareAnswers(string answer, IEnumerable<string> correctAnswers, bool allowTrim, bool allowCaseInsensitive)
        {
            bool allowCaseInsensitiveTrim = allowTrim && allowCaseInsensitive;

            if (answer == null)
            {
                return false;
            }
            bool exactMatch = correctAnswers.Contains(answer);
            if (exactMatch)
            {
                return true;
            }

            bool trimMatch = correctAnswers.Contains(answer.Trim());
            if (allowTrim && trimMatch)
            {
                return true;
            }

            bool caseInsensitiveMatch = correctAnswers.Select(answer => answer.ToLower()).Contains(answer.ToLower());
            if (allowCaseInsensitive && caseInsensitiveMatch)
            {
                return true;
            }

            bool caseInsensitiveTrimMatch = correctAnswers.Select(answer => answer.ToLower().Trim()).Contains(answer.ToLower().Trim());
            if (allowCaseInsensitiveTrim && caseInsensitiveTrimMatch)
            {
                return true;
            }

            return false;
        }

    }
}
