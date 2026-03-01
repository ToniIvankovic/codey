using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace CodeyBE.Contracts.Entities
{
    public class Course
    {
        [BsonElement("_id")]
        public ObjectId Id { get; set; }
        [BsonElement("privateId")]
        public int PrivateId { get; set; }
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;
        [BsonElement("shortName")]
        public string ShortName { get; set; } = string.Empty;
        [BsonElement("description")]
        public string Description { get; set; } = string.Empty;
    }
}
