using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class EndOfLessonReport
    {
        [BsonElement("lessonId")]
        public int LessonId { get; set; }
        [BsonElement("lessonGroupId")]
        public int LessonGroupId { get; set; }
        [BsonElement("correctAnswers")]
        public int CorrectAnswers { get; set; }
        [BsonElement("totalAnswers")]
        public int TotalAnswers { get; set; }
        [BsonElement("duration")]
        public int Duration { get; set; }
        [BsonElement("accuracy")]
        public double Accuracy { get; set; }
    }
}
