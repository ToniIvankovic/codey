using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class AnswerValidationResult(Exercise exercise, bool isCorrect, dynamic gottenAnswer, IEnumerable<dynamic>? expectedAnswers)
    {
        public Exercise exercise { get; set; } = exercise;
        public bool IsCorrect { get; set; } = isCorrect;
        public dynamic GottenAnswer { get; set; } = gottenAnswer;
        public IEnumerable<dynamic>? CorrectAnswers { get; set; } = expectedAnswers;
    }
}
