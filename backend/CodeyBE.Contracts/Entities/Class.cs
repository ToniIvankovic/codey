using CodeyBE.Contracts.Entities.Users;
using MongoDB.Bson;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class Class
    {
        public ObjectId Id { get; set; }
        public int PrivateId { get; set; }
        public required string Name { get; set; }
        public required string School { get; set; }
        public required string TeacherUsername { get; set; }
        public required List<string> Students { get; set; } = [];
    }
}
