using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Exceptions;
using CodeyBE.Contracts.Repositories;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Repositories
{
    public class ClassesRepository(IMongoDbContext dbContext) : Repository<Class>(dbContext, "classes"), IClassesRepository
    {
        public async Task<Class> CreateAsync(Class @class)
        {
            @class.PrivateId = (int)((_collection
                .Find(_ => true)
                .ToList()
                .OrderBy(_ => _.PrivateId)
                .LastOrDefault()
                ?.PrivateId ?? 0) + 1);
            _collection.InsertOne(@class);
            return (await GetByIdAsync(@class.PrivateId))!;
        }

        public Task DeleteAsync(int id)
        {
            _collection.DeleteOne(@class => @class.PrivateId == id);
            return Task.CompletedTask;
        }

        public async override Task<Class?> GetByIdAsync(int id)
        {
            return await _collection.Find(@class => @class.PrivateId == id).FirstOrDefaultAsync();
        }

        public async Task<Class> UpdateAsync(int id, Class @class)
        {
            UpdateResult updateResult = _collection.UpdateOne(
                            @class => @class.PrivateId == id,
                            Builders<Class>.Update
                                .Set(@class => @class.Name, @class.Name)
                                .Set(@class => @class.School, @class.School)
                                .Set(@class => @class.TeacherUsername, @class.TeacherUsername)
                                .Set(@class => @class.Students, @class.Students)
                        );
            if (!updateResult.IsAcknowledged)
            {
                throw new Exception("Update failed");
            }
            if (updateResult.MatchedCount == 0)
            {
                throw new EntityNotFoundException("Class not found");
            }
            if (updateResult.ModifiedCount == 0)
            {
                throw new NoChangesException("No changes");
            }

            return (await GetByIdAsync(id))!;
        }

        public async Task<IEnumerable<Class>> GetAllClassesForTeacher(string teacherUsername)
        {
            return await _collection
                .Find(@class => @class.TeacherUsername == teacherUsername)
                .ToListAsync();
        }

        public async Task<Class?> GetClassForStudent(ApplicationUser student)
        {
            if(student.Email == null)
            {
                throw new MissingFieldException("Student email is missing");
            }
            return await _collection
                .Find(@class => @class.School == student.School && @class.Students.Contains(student.Email))
                .FirstOrDefaultAsync();
        }
    }
}
