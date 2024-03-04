using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class Exercise
    {

        [BsonElement("_id")]
        public ObjectId Id { get; set; }

        [BsonElement("id")]
        public required int PrivateId { get; set; }

        [BsonElement("type")]
        public required string Type { get; set; }

        [BsonElement("difficulty")]
        public required int Difficulty { get; set; }

        [BsonElement("statement")]
        public string? Statement { get; set; }

        [BsonElement("statementCode")]
        public string? StatementCode { get; set; }

        [BsonElement("defaultGapLengths")]
        public List<int>? DefaultGapLengths { get; set; }

        [BsonElement("defaultGapLines")]
        public List<int>? DefaultGapLines { get; set; }

        [BsonElement("statementOutput")]
        public string? StatementOutput { get; set; }

        [BsonElement("question")]
        public string? Question { get; set; }
        
        [BsonElement("answerOptions")]
        public Dictionary<string, string>? AnswerOptions { get; set; }
        
        [BsonElement("correctAnswer")]
        public string? CorrectAnswer { get; set; }

        [BsonElement("correctAnswers")]
        public List<dynamic>? CorrectAnswers { get; set; }

        [BsonElement("raisesError")]
        public bool? RaisesError { get; set; }

        [BsonElement("specificTip")]
        public string? SpecificTip { get; set; }
    }
}
