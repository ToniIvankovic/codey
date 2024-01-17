using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class AnswerValidationResult
    {
        public Exercise exercise { get; set; }
        public bool IsCorrect { get; set; }
        public String GottenAnswer { get; set; }
        public IEnumerable<String>? CorrectAnswers { get; set; }

        public AnswerValidationResult(Exercise exercise, bool isCorrect, String gottenAnswer, IEnumerable<String>? expectedAnswers)
        {
            this.exercise = exercise;
            IsCorrect = isCorrect;
            GottenAnswer = gottenAnswer;
            CorrectAnswers = expectedAnswers;
        }
    }
}
