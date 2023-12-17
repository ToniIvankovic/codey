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
        public int PrivateId { get; set; }

        [BsonElement("type")]
        public string Type { get; set; }

        [BsonElement("difficulty")]
        public int Difficulty { get; set; }

        [BsonElement("statement")]
        public string? Statement { get; set; } = string.Empty;

        [BsonElement("statementCode")]
        public string? StatementCode { get; set; } = string.Empty;

        [BsonElement("question")]
        public string? Question { get; set; } = string.Empty;
        
        [BsonElement("answerOptions")]
        public Dictionary<string, string>? AnswerOptions { get; set; }
        
        [BsonElement("correctAnswer")]
        public string? CorrectAnswer { get; set; } = string.Empty;

        // TODO: alternative answer checker
        
        [BsonElement("raisesError")]
        public bool? RaisesError { get; set; }

        [BsonElement("specificTip")]
        public string? SpecificTip { get; set; } = string.Empty;
    }
}
