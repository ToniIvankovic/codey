using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Services
{
    public interface ILessonsService
    {
        public Task<IEnumerable<Lesson>> GetAllLessonsAsync();
        public Task<Lesson?> GetLessonByIDAsync(int id);
        public Task<IEnumerable<Lesson>> GetLessonsForLessonGroupAsync(int lessonGroupId);
    }
}
