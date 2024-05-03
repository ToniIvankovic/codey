using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using Microsoft.IdentityModel.Tokens;
using System.Collections.Generic;
using System.Security.Claims;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;
using System.Text.RegularExpressions;

namespace CodeyBe.Services
{
    public partial class ExercisesService(
        IExercisesRepository exercisesRepository,
        ILessonsService lessonsService,
        ILessonGroupsService lessonGroupsService,
        ILogsService logsService) : IExercisesService
    {
        private readonly IExercisesRepository _exercisesRepository = exercisesRepository;
        private readonly ILessonsService _lessonsService = lessonsService;
        private readonly ILessonGroupsService _lessonGroupsService = lessonGroupsService;
        private readonly ILogsService _logsService = logsService;

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
            Lesson lesson = await _lessonsService.GetLessonByIDAsync(lessonId)
                ?? throw new EntityNotFoundException($"No lesson found with id {lessonId}");
            IEnumerable<int> exerciseIDs = lesson.Exercises;
            IEnumerable<Exercise> exercises = _exercisesRepository.GetExercisesByID(exerciseIDs);
            exercises = EnrichExercisesList(exercises);
            return exercises;
        }

        public async Task<IEnumerable<Exercise>> GetExercisesForAdaptiveLessonAsync(ApplicationUser user)
        {
            const int N_EXERCISES = 15;
            const double RATIO_EASIER = 0.3;
            int highestLessonGroup = (int)user.HighestLessonGroupId!;
            LessonGroup lessonGroup = await _lessonGroupsService.GetLessonGroupByIDAsync(highestLessonGroup)
                ?? throw new EntityNotFoundException($"No lesson group found with id {highestLessonGroup}");
            List<LessonGroup> eligibleLessonGroups = [
                .. (await _lessonGroupsService.GetAllLessonGroupsAsync())
                                .Where(lgr => lgr.Order <= lessonGroup.Order && !(lgr.Adaptive ?? false))
                                .OrderBy(lgr => lgr.Order)
,
            ];
            List<Lesson> eligibleLessons = [
                .. await Task.WhenAll(
                    eligibleLessonGroups
                        .SelectMany(lg => lg.LessonIds)
                        .Select(lessonId => _lessonsService.GetLessonByIDAsync(lessonId))
                        .ToList()
                )
            ];
            List<Exercise> eligibleExercises = [
                .. await Task.WhenAll(
                    eligibleLessons
                        .SelectMany(lesson => lesson.Exercises)
                        .Select(exerciseId => _exercisesRepository.GetByIdAsync(exerciseId))
                        .ToList()
                )
            ];
            //make sure that the exercises are unique
            eligibleExercises = [.. eligibleExercises.ToHashSet()];
            List<Exercise> easierExercises = eligibleExercises
                .Where(exercise => exercise.Difficulty < user.Score)
                .ToList();
            List<Exercise> harderExercises = eligibleExercises
                .Where(exercise => exercise.Difficulty > user.Score)
                .ToList();
            int nEasier = (int)(N_EXERCISES * RATIO_EASIER);
            int nHarder = N_EXERCISES - nEasier;
            List<Exercise> selectedExercises = [
                .. PickNExercisesRouletteWheel(easierExercises, nEasier, user.Score),
                .. PickNExercisesRouletteWheel(harderExercises, nHarder, user.Score)
            ];
            selectedExercises = EnrichExercisesList(selectedExercises).ToList();
            return selectedExercises.OrderBy(ex => ex.Difficulty);
        }

        private static List<Exercise> PickNExercisesRouletteWheel(List<Exercise> exercises, int n, double userScore)
        {
            double sumDistances = (double)exercises
                .Select(exercise => 1 / Math.Abs(exercise.Difficulty - userScore))
                .Sum();
            List<double> probabilities = exercises
                .Select(exercise => (1 / Math.Abs(exercise.Difficulty - userScore)) / sumDistances)
                .ToList();
            List<Exercise> selectedExercises = [];
            for (int i = 0; i < n; i++)
            {
                double random = new Random().NextDouble();
                double cumulativeProbability = 0;
                for (int j = 0; j < exercises.Count; j++)
                {
                    cumulativeProbability += probabilities[j];
                    if (random <= cumulativeProbability)
                    {
                        selectedExercises.Add(exercises[j]);
                        exercises.RemoveAt(j);
                        break;
                    }
                }
            }
            return selectedExercises;
        }

        private IEnumerable<Exercise> EnrichExercisesList(IEnumerable<Exercise> exercises)
        {
            exercises = exercises.Select(exercise =>
             {
                 if (exercise is ExerciseLA exerciseLA)
                 {
                     if (exerciseLA.AnswerOptions.IsNullOrEmpty() && exerciseLA.CorrectAnswers != null)
                         GenerateAnswerOptionsForExerciseLA(exerciseLA);
                 }
                 return exercise;
             });
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

        public async Task<double> GetSuggestedDifficultyForExerciseAsync(int exerciseId)
        {
            Exercise? exercise = await _exercisesRepository.GetByIdAsync(exerciseId)
                ?? throw new ArgumentException($"Exercise with id {exerciseId} does not exist");
            Dictionary<bool, List<double>> statistics = await GetStatisticScoresForExerciseAsync(exerciseId);
            if (statistics[true].Count == 0 && statistics[false].Count == 0)
            {
                return exercise.Difficulty;
            }
            double difficulty = CalculateSuggestedDifficultyFromStatistics(statistics);
            return difficulty;
        }
        public async Task<Dictionary<bool, double?>> GetAverageScoresForExerciseAsync(int exerciseId)
        {
            _ = await _exercisesRepository.GetByIdAsync(exerciseId)
                ?? throw new ArgumentException($"Exercise with id {exerciseId} does not exist");
            Dictionary<bool, List<double>> statistics = await GetStatisticScoresForExerciseAsync(exerciseId);

            var dict = new Dictionary<bool, double?>();
            if (statistics[true].Count == 0)
            {
                dict[true] = null;
            }
            else
            {
                dict[true] = statistics[true].Average();
            }
            if (statistics[false].Count == 0)
            {
                dict[false] = null;
            }
            else
            {
                dict[false] = statistics[false].Average();
            }
            return dict;

        }

        private async Task<Dictionary<bool, List<double>>> GetStatisticScoresForExerciseAsync(int exerciseId)
        {
            List<LogExerciseAnswer> logs = (await _logsService.GetLogExerciseAnswersForExercise(exerciseId)).ToList();
            Dictionary<bool, List<double>> scores = [];
            scores[true] = logs.Where(log => log.MarkedCorrect).Select(log => log.StudentScore).ToList();
            scores[false] = logs.Where(log => !log.MarkedCorrect).Select(log => log.StudentScore).ToList();
            return scores;
        }

        private double CalculateSuggestedDifficultyFromStatistics(Dictionary<bool, List<double>> statistics)
        {
            if (statistics[false].Count == 0)
            {
                return statistics[true].Average();
            }
            if (statistics[true].Count == 0)
            {
                return statistics[false].Max();
            }
            const int MAX_DIFFICULTY = 100;
            List<double> suggestedDifficulties = [];
            for (int i = 1; i < MAX_DIFFICULTY; i++)
            {
                suggestedDifficulties.Add(i);
            }
            // Find the first difficulty that has more than 60% correct answers
            // Bear in mind that incorrectly answered exercises are repeated so usually 50% accuracy is the minimum
            foreach (double suggestedDifficulty in suggestedDifficulties)
            {
                int numCorrect = 0;
                int numIncorrect = 0;
                numCorrect += statistics[true]
                    .Where(s => s >= suggestedDifficulty)
                    .Count();
                numIncorrect += statistics[false]
                    .Where(s => s >= suggestedDifficulty)
                    .Count();
                if (numCorrect != 0 && 
                    numCorrect / (double)(numCorrect + numIncorrect) > 0.6)
                {
                    return suggestedDifficulty;
                }
                if(numCorrect == 0 && numIncorrect == 0)
                {
                    break;
                }
            }
            // if no difficulty has more than 50% correct answers, return the maximum score that ever tried to solve it
            return new List<double>(){
                statistics[true].Max(),
                statistics[false].Max()
            }.Max();
        }
    }
}
