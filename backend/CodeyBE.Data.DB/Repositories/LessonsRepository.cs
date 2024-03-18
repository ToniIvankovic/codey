using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
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

        public async Task<Lesson> CreateAsync(LessonCreationDTO lesson)
        {
            int nextId = _collection
                .AsQueryable()
                .OrderByDescending(lesson => lesson.PrivateId)
                .FirstOrDefault()!.PrivateId + 1;
            await _collection.InsertOneAsync(new Lesson
            {
                PrivateId = nextId,
                Name = lesson.Name,
                Exercises = lesson.Exercises,
            });
            return (await GetByIdAsync(nextId))!;
        }

        public async Task<Lesson> UpdateAsync(int id, LessonCreationDTO lesson)
        {
            UpdateResult updateResult = await _collection.UpdateOneAsync(
                                lesson => lesson.PrivateId == id,
                                Builders<Lesson>.Update
                                .Set(lesson => lesson.Name, lesson.Name)
                                .Set(lesson => lesson.Exercises, lesson.Exercises)
                                );
            if (!updateResult.IsAcknowledged || updateResult.ModifiedCount == 0)
            {
                throw new EntityNotFoundException("Update failed");
            }

            return (await GetByIdAsync(id))!;
        }

        public async Task DeleteAsync(int id)
        {
            DeleteResult deleteResult = await _collection.DeleteOneAsync(lesson => lesson.PrivateId == id);
            if (!deleteResult.IsAcknowledged || deleteResult.DeletedCount == 0)
            {
                throw new EntityNotFoundException("Delete failed");
            }
        }
    }
}
