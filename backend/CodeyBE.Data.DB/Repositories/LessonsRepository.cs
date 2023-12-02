using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Repositories
{
    public class LessonsRepository(IMongoDbContext dbContext) : Repository<Lesson>(dbContext, "lessons"), ILessonsRepository
    {
        public override async Task<Lesson?> GetByIdAsync(int id)
        {
            return await _collection.Find(lesson => lesson.PrivateId == id).FirstOrDefaultAsync();
        }
    }
}
