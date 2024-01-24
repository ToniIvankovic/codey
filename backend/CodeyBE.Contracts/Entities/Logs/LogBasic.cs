using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;

namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogBasic(string UserId)
    {
        [BsonId]
        public ObjectId Id { get; set; } 
        public string UserId { get; set; } = UserId;
        public DateTime Timestamp { get; set; } = DateTime.Now;
    }
}
