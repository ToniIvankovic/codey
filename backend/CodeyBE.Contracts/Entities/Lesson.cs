using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class Lesson
    {
        [BsonElement("_id")]
        public ObjectId Id { get; set; }
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;

        //TODO: add DTOs with only IDs when transferring data and put a reference to the real object here
        [BsonElement("lessonGroup")]
        public int LessonGroupId { get; set; }
        [BsonElement("exercises")]
        public IEnumerable<int> Exercises { get; set; } = new List<int>();
        [BsonElement("id")]
        public int PrivateId { get; set; }
    }
}
