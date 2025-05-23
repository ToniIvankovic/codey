﻿using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using Microsoft.EntityFrameworkCore;
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
                SpecificTips = lesson.SpecificTips,
            });
            return (await GetByIdAsync(nextId))!;
        }

        public async Task<Lesson> UpdateAsync(int id, LessonCreationDTO lessonCreationDTO)
        {
            // Unset the array field
            await _collection.UpdateOneAsync(
                lesson => lesson.PrivateId == id,
                Builders<Lesson>.Update.Unset(lesson => lesson.Exercises)
            );

            UpdateResult updateResult = await _collection.UpdateOneAsync(
                                lesson => lesson.PrivateId == id,
                                Builders<Lesson>.Update
                                .Set(lesson => lesson.Name, lessonCreationDTO.Name)
                                .Set(lesson => lesson.SpecificTips, lessonCreationDTO.SpecificTips)
                                .Set(lesson => lesson.Exercises, lessonCreationDTO.Exercises)
                                );
            if (!updateResult.IsAcknowledged)
            {
                throw new Exception("Update failed");
            }
            if (updateResult.MatchedCount == 0)
            {
                throw new EntityNotFoundException("Lesson not found");
            }
            if(updateResult.ModifiedCount == 0)
            {
                throw new NoChangesException("No changes");
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

        public async Task<List<Lesson>> GetLessonsByIDsAsync(List<int> ids)
        {
            return (await _collection
                .Find(lesson => ids.Contains(lesson.PrivateId))
                .ToListAsync())
                .OrderBy(lesson => ids.IndexOf(lesson.PrivateId))
                .ToList();
        }
    }
}
