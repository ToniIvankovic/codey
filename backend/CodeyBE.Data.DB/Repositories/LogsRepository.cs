using CodeyBE.Contracts.Entities.Logs;
using CodeyBE.Contracts.Repositories;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Data.DB.Repositories
{
    public class LogsRepository(IMongoDbContext dbContext) : Repository<LogBasic>(dbContext, "logs"), ILogsRepository
    {
        public async override Task<LogBasic?> GetByIdAsync(int id)
        {
            return await _collection.Find(log => log.Id.ToString().Equals(id.ToString())).FirstOrDefaultAsync();
        }

        public void SaveLogAsync(LogBasic log)
        {
            _collection.InsertOneAsync(log);
        }

        public async Task<IEnumerable<LogExerciseAnswer>> GetAllLogExerciseAnswers()
        {
            return (await _collection.Find(log => log is LogExerciseAnswer).ToListAsync())
                .Cast<LogExerciseAnswer>()
                .ToList();
        }
    }
}
