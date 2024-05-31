using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;

namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogBasic(string userId, int userGroup)
    {
        [BsonId]
        public ObjectId Id { get; set; } 
        public string UserId { get; set; } = userId;
        public int UserGroup { get; set; } = userGroup;
        public DateTime Timestamp { get; set; } = DateTime.Now;
    }
}
