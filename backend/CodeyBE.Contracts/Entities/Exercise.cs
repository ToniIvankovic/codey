using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Enumerations;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace CodeyBE.Contracts.Entities
{
    public class Exercise
    {

        [BsonElement("_id")]
        public ObjectId Id { get; set; }

        [BsonElement("id")]
        public int PrivateId { get; set; }

        [BsonElement("type")]
        public string Type { get; set; }

        [BsonElement("difficulty")]
        public double Difficulty { get; set; }

        [BsonElement("statement")]
        [BsonIgnoreIfNull]
        public string? Statement { get; set; }

        [BsonElement("statementCode")]
        [BsonIgnoreIfNull]
        public string? StatementCode { get; set; }

        [BsonElement("defaultGapLengths")]
        [BsonIgnoreIfNull]
        public List<int>? DefaultGapLengths { get; set; }

        [BsonElement("statementOutput")]
        [BsonIgnoreIfNull]
        public string? StatementOutput { get; set; }

        [BsonElement("question")]
        [BsonIgnoreIfNull]
        public string? Question { get; set; }

        [BsonElement("answerOptions")]
        [BsonIgnoreIfNull]
        public Dictionary<string, string>? AnswerOptions { get; set; }

        [BsonElement("correctAnswer")]
        [BsonIgnoreIfNull]
        public string? CorrectAnswer { get; set; }

        [BsonElement("correctAnswers")]
        [BsonIgnoreIfNull]
        public List<dynamic>? CorrectAnswers { get; set; }

        [BsonElement("raisesError")]
        [BsonIgnoreIfNull]
        public bool? RaisesError { get; set; }

        [BsonElement("specificTip")]
        [BsonIgnoreIfNull]
        public string? SpecificTip { get; set; }
        public Exercise(Exercise ex)
        {
            Id = ex.Id;
            PrivateId = ex.PrivateId;
            Type = ex.Type;
            Difficulty = ex.Difficulty;
            Statement = ex.Statement;
            StatementCode = ex.StatementCode;
            DefaultGapLengths = ex.DefaultGapLengths;
            StatementOutput = ex.StatementOutput;
            Question = ex.Question;
            AnswerOptions = ex.AnswerOptions;
            CorrectAnswer = ex.CorrectAnswer;
            CorrectAnswers = ex.CorrectAnswers;
            RaisesError = ex.RaisesError;
            SpecificTip = ex.SpecificTip;
        }

        public Exercise(int id, ExerciseCreationDTO exerciseCreationDTO)
        {
            PrivateId = id;
            Type = exerciseCreationDTO.Type;
            Difficulty = exerciseCreationDTO.Difficulty;
            Statement = exerciseCreationDTO.Statement;
            StatementCode = exerciseCreationDTO.StatementCode;
            DefaultGapLengths = exerciseCreationDTO.DefaultGapLengths;
            StatementOutput = exerciseCreationDTO.StatementOutput;
            Question = exerciseCreationDTO.Question;
            AnswerOptions = exerciseCreationDTO.AnswerOptions;
            CorrectAnswer = exerciseCreationDTO.CorrectAnswer;
            CorrectAnswers = exerciseCreationDTO.CorrectAnswers;
            RaisesError = exerciseCreationDTO.RaisesError;
            SpecificTip = exerciseCreationDTO.SpecificTip;
        }

    }

    public class ExerciseLA : Exercise
    {
        public ExerciseLA(Exercise ex) : base(ex)
        {
            if (ex.Type != ExerciseTypes.LONG_ANSWER)
            {
                throw new Exception($"Invalid exercise type conversion {ex.PrivateId} {ex.Type}");
            }
            if (ex.CorrectAnswers == null)
            {
                throw new Exception($"Missing field CorrectAnswers in exercise {ex.PrivateId} {ex.Type}");
            }
            AnswerOptions = ex.AnswerOptions;
            StatementOutput = ex.StatementOutput;
        }
    }

    public class ExerciseMC : Exercise
    {
        public ExerciseMC(Exercise ex) : base(ex)
        {
            if (ex.Type != ExerciseTypes.MULTIPLE_CHOICE)
            {
                throw new Exception($"Invalid exercise type conversion {ex.PrivateId} {ex.Type}");
            }
            if (ex.CorrectAnswer == null)
            {
                throw new Exception($"Missing field CorrectAnswer in exercise {ex.PrivateId} {ex.Type}");
            }
            if (ex.Question == null)
            {
                throw new Exception($"Missing field Question in exercise {ex.PrivateId} {ex.Type}");
            }
            if (ex.AnswerOptions == null)
            {
                throw new Exception($"Missing field AnswerOptions in exercise {ex.PrivateId} {ex.Type}");
            }
        }
    }
    public class ExerciseSA : Exercise
    {
        public ExerciseSA(Exercise ex) : base(ex)
        {
            if (ex.Type != ExerciseTypes.SHORT_ANSWER)
            {
                throw new Exception($"Invalid exercise type conversion {ex.PrivateId} {ex.Type}");
            }
            if (ex.CorrectAnswers == null && ex.RaisesError == null)
            {
                throw new Exception($"Missing field CorrectAnswers in exercise {ex.PrivateId} {ex.Type}");
            }
            if (ex.Question == null)
            {
                throw new Exception($"Missing field Question in exercise {ex.PrivateId} {ex.Type}");
            }
        }
    }
    public class ExerciseSCW : Exercise
    {

        public ExerciseSCW(Exercise ex) : base(ex)
        {
            if (ex.Type != ExerciseTypes.SHORT_CODE_WRITING)
            {
                throw new Exception($"Invalid exercise type conversion {ex.PrivateId} {ex.Type}");
            }
            if (ex.StatementCode == null)
            {
                throw new Exception($"Missing field StatementCode in exercise {ex.PrivateId} {ex.Type}");
            }
            if (ex.DefaultGapLengths == null)
            {
                throw new Exception($"Missing field DefaultGapLengths in exercise {ex.PrivateId} {ex.Type}");
            }
            if (ex.CorrectAnswers == null)
            {
                throw new Exception($"Missing field CorrectAnswers in exercise {ex.PrivateId} {ex.Type}");
            }
            //if (ex.StatementOutput == null)
            //{
            //    throw new Exception($"Missing field StatementOutput in exercise {ex.PrivateId} {ex.Type}");
            //}
        }
    }
}

