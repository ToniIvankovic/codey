using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.IdentityModel.Tokens;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;
using System.Text.RegularExpressions;

namespace CodeyBe.Services
{
    public partial class ExercisesService(IExercisesRepository exercisesRepository, ILessonsService lessonsService) : IExercisesService
    {
        private readonly IExercisesRepository _exercisesRepository = exercisesRepository;
        private readonly ILessonsService _lessonsService = lessonsService;

        public async Task<IEnumerable<Exercise>> GetAllExercisesAsync()
        {
            return EnrichExercisesList(await _exercisesRepository.GetAllAsync());
        }

        public async Task<Exercise?> GetExerciseByIDAsync(int id)
        {
            Exercise? exercise = await _exercisesRepository.GetByIdAsync(id);
            if (exercise != null)
            {
                exercise = EnrichExercisesList(new List<Exercise> { exercise }).ElementAt(0);
            }
            return exercise;
        }

        public async Task<Exercise> CreateExerciseAsync(ExerciseCreationDTO exercise)
        {
            // Checking requirements
            ValidateExerciseCreationDTO(exercise);
            DeserializeCorrectAnswers(exercise);

            // Creating the exercise in DB
            Exercise newExercise = await _exercisesRepository.CreateAsync(exercise);
            return newExercise;
        }

        public async Task<Exercise> UpdateExerciseAsync(int id, ExerciseCreationDTO exercise)
        {
            // Checking requirements
            ValidateExerciseCreationDTO(exercise);
            DeserializeCorrectAnswers(exercise);

            // Updating the exercise in DB
            Exercise updatedExercise = await _exercisesRepository.UpdateAsync(id, exercise);
            return updatedExercise;
        }
        private static void DeserializeCorrectAnswers(ExerciseCreationDTO exercise)
        {
            if (exercise.Type == "SCW")
            {
                exercise.CorrectAnswers = DeserializeJsonListListString(exercise.CorrectAnswers!);
            }
            else if (exercise.Type == "SA" || exercise.Type == "LA")
            {
                exercise.CorrectAnswers = DeserializeJsonListString(exercise.CorrectAnswers!);
            }
        }

        private static List<dynamic> DeserializeJsonListListString(List<dynamic> answers)
        {
            IEnumerable<dynamic> castAnswers = answers
                                .Select(answer => ((JsonElement)answer)
                                    .EnumerateArray()
                                    .Select(d => d.GetString())
                                    .ToList());
            return castAnswers.ToList();
        }
        private static List<dynamic> DeserializeJsonListString(List<dynamic> answers)
        {
            IEnumerable<dynamic> castAnswers = answers.Select(answer => ((JsonElement)answer).GetString()!);
            return castAnswers.ToList();
        }


        private void ValidateExerciseCreationDTO(ExerciseCreationDTO dto)
        {
            Exercise generalExercise = new Exercise(0, dto);
            IExercisesRepository.MapToSpecificExerciseType(generalExercise);
        }

        public async Task DeleteExerciseAsync(int id)
        {
            //TODO: check if the exercise is used in any lesson
            await _exercisesRepository.DeleteAsync(id);
        }

        public async Task<IEnumerable<Exercise>> GetExercisesForLessonAsync(int lessonId)
        {
            Lesson? lesson = await _lessonsService.GetLessonByIDAsync(lessonId);
            if (lesson == null)
            {
                return new List<Exercise>();
            }
            IEnumerable<int> exerciseIDs = lesson.Exercises;
            IEnumerable<Exercise> exercises = _exercisesRepository.GetExercisesByID(exerciseIDs);
            exercises = EnrichExercisesList(exercises);
            return exercises;
        }

        private IEnumerable<Exercise> EnrichExercisesList(IEnumerable<Exercise> exercises)
        {
            exercises = exercises.Select(exercise =>
             {
                 if (exercise is ExerciseLA exerciseLA)
                 {
                     if(exerciseLA.AnswerOptions.IsNullOrEmpty() && exerciseLA.CorrectAnswers != null)
                     GenerateAnswerOptionsForExerciseLA(exerciseLA);
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
                castAnswer = answer.EnumerateArray()
                    .Select(element => element.GetString())
                    .ToList();
                correctAnswers = exerciseSCW.CorrectAnswers!.Select(d => ((List<string>)d).Cast<string>().ToList()).ToList();
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
            IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(d => (string)d);
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
            IEnumerable<string> correctAnswers = exercise.CorrectAnswers!.Select(d => (string)d);
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
