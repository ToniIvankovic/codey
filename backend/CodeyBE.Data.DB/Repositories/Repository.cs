using CodeyBE.Contracts.Repositories;
using Microsoft.EntityFrameworkCore;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Repositories
{
    public abstract class Repository<TEntity> : IRepository<TEntity>
        where TEntity : class
    {
        protected readonly IMongoCollection<TEntity> _collection;

        public Repository(IMongoDbContext databaseContext, string collectionName)
        {
            var context = databaseContext;
            _collection = context.GetCollection<TEntity>(collectionName);
        }

        public virtual async Task<IEnumerable<TEntity>> GetAllAsync()
        {
            return await _collection.Find(_ => true).ToListAsync();
        }

        public abstract Task<TEntity?> GetByIdAsync(ObjectId id);

    }
}
