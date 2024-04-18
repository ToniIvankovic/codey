using CodeyBE.Contracts.Entities.Logs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface ILogsRepository : IRepository<LogBasic>
    {
        public void SaveLogAsync(LogBasic log);
        public Task<IEnumerable<LogExerciseAnswer>> GetAllLogExerciseAnswers();
    }
}
