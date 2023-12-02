using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using Microsoft.EntityFrameworkCore;
using MongoDB.Bson;
using MongoDB.Driver;

namespace CodeyBE.Data.DB.Repositories
{
    public class LessonGroupsRepository(IMongoDbContext dbContext) : Repository<LessonGroup>(dbContext, "lesson_groups"), ILessonGroupsRepository
    {
        public override async Task<LessonGroup?> GetByIdAsync(int id)
        {
            return await _collection.Find(lessonGroup => lessonGroup.PrivateId == id).FirstOrDefaultAsync();
        }
    }
}
