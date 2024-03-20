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
        public override async Task<IEnumerable<LessonGroup>> GetAllAsync()
        {
            return (await base.GetAllAsync()).OrderBy(lgr => lgr.Order).ToList();
        }
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
            int newOrder = lessonGroup.Order ?? _collection
                .AsQueryable()
                .OrderByDescending(lessonGroup => lessonGroup.Order)
                .FirstOrDefault()!.Order + 1;
            int newId = lastId + 1;
            await _collection.InsertOneAsync(new LessonGroup
            {
                PrivateId = newId,
                Name = lessonGroup.Name,
                Tips = lessonGroup.Tips,
                LessonIds = lessonGroup.Lessons.ToList(),
                Order = newOrder,
            });
            return (await GetByIdAsync(newId))!;
        }

        public async Task<LessonGroup> UpdateAsync(int id, LessonGroupCreationDTO lessonGroup)
        {
            UpdateResult updateResult = await _collection.UpdateOneAsync(
                                lessonGroup => lessonGroup.PrivateId == id,
                                Builders<LessonGroup>.Update
                                .Set(lessonGroup => lessonGroup.Name, lessonGroup.Name)
                                .Set(lessonGroup => lessonGroup.Tips, lessonGroup.Tips)
                                .Set(lessonGroup => lessonGroup.LessonIds, lessonGroup.Lessons.ToList())
                                .Set(lessonGroup => lessonGroup.Order, lessonGroup.Order)
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

        public async Task<LessonGroup?> GetLessonGroupByOrderAsync(int order)
        {
            return await _collection.Find(lessonGroup => lessonGroup.Order == order).FirstOrDefaultAsync();
        }

        public async Task<List<LessonGroup>> UpdateOrderAsync(List<LessonGroupsReorderDTO> lessonGroupOrderList)
        {
            var updates = new List<WriteModel<LessonGroup>>();

            foreach (var lessonGroupOrder in lessonGroupOrderList)
            {
                var filter = Builders<LessonGroup>.Filter.Eq(lessonGroup => lessonGroup.PrivateId, lessonGroupOrder.Id);
                var update = Builders<LessonGroup>.Update.Set(lessonGroup => lessonGroup.Order, lessonGroupOrder.Order);
                updates.Add(new UpdateOneModel<LessonGroup>(filter, update));
            }

            await _collection.BulkWriteAsync(updates);
            return (await GetAllAsync()).ToList();

        }
    }
}
