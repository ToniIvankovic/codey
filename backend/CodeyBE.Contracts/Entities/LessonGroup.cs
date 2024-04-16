using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class LessonGroup
    {
        [BsonElement("_id")]
        public ObjectId Id { get; set; }
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;
        [BsonElement("tips")]
        [BsonIgnoreIfNull]
        public string? Tips { get; set; }
        [BsonElement("id")]
        public int PrivateId { get; set; }
        [BsonElement("order")]
        public int Order { get; set; }
        [BsonElement("lessons")]
        public List<int> LessonIds { get; set; } = [];
        [BsonElement("adaptive")]
        [BsonIgnoreIfNull]
        public bool? Adaptive { get; set; }
        [BsonElement("recommendedLevel")]
        [BsonIgnoreIfNull]
        public double? RecommendedLevel { get; set; }

    }
}
