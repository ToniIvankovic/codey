using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Configurations
{
    public class ApplicationDbContext : IMongoDbContext
    {
        public IMongoDatabase Database { get; }

        public ApplicationDbContext(string connectionString, string databaseName)
        {
            var _client = new MongoClient(connectionString);
            Database = _client.GetDatabase(databaseName);
        }
        public IMongoCollection<T> GetCollection<T>(string collectionName)
        {
            return Database.GetCollection<T>(collectionName);
        }
    }
}
