using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
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

        public async Task<LessonGroup> CreateAsync(LessonGroupCreationDTO lessonGroup)
        {
            int lastId = _collection
                .AsQueryable()
                .OrderByDescending(lessonGroup => lessonGroup.PrivateId)
                .FirstOrDefault()!.PrivateId;
            await _collection.InsertOneAsync(new LessonGroup
            {
                PrivateId = lastId + 1,
                Name = lessonGroup.Name,
                Tips = lessonGroup.Tips,
            });
            return (await GetByIdAsync(lastId + 1))!;
        }

        public async Task<LessonGroup> UpdateAsync(int id, LessonGroupCreationDTO lessonGroup)
        {
            UpdateResult updateResult = await _collection.UpdateOneAsync(
                                lessonGroup => lessonGroup.PrivateId == id,
                                Builders<LessonGroup>.Update
                                .Set(lessonGroup => lessonGroup.Name, lessonGroup.Name)
                                .Set(lessonGroup => lessonGroup.Tips, lessonGroup.Tips)
                                );
            if (!updateResult.IsAcknowledged || updateResult.ModifiedCount == 0)
            {
                throw new EntityNotFoundException("Update failed");
            }

            return (await GetByIdAsync(id))!;
        }

        public async Task DeleteAsync(int id)
        {
            DeleteResult deleteResult = await _collection.DeleteOneAsync(lessonGroup => lessonGroup.PrivateId == id);
            if (!deleteResult.IsAcknowledged || deleteResult.DeletedCount == 0)
            {
                throw new EntityNotFoundException("Delete failed");
            }
        }


    }
}
