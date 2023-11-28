using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using Microsoft.EntityFrameworkCore;
using MongoDB.Bson;
using MongoDB.Driver;

namespace CodeyBE.Data.DB.Repositories
{
    public class LessonGroupsRepository(IMongoDbContext dbContext) : Repository<LessonGroup>(dbContext, "lesson_groups"), ILessonGroupsRepository
    {
        public override async Task<IEnumerable<LessonGroup>> GetAllAsync()
        {
            return await _collection.Find(_ => true).ToListAsync();
        }

        public override async Task<LessonGroup?> GetByIdAsync(ObjectId id)
        {
            return await _collection.Find(lessonGroup => lessonGroup.Id == id).FirstOrDefaultAsync();
        }
    }
}
