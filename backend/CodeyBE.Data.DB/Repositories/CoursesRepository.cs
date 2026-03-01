using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;

namespace CodeyBE.Data.DB.Repositories
{
    public class CoursesRepository(IMongoDbContext dbContext)
        : Repository<Course>(dbContext, "courses"), ICoursesRepository
    {
        public override async Task<Course?> GetByIdAsync(int id)
        {
            return await _collection.Find(c => c.PrivateId == id).FirstOrDefaultAsync();
        }
    }
}
