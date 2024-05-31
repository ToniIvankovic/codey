using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities.Logs
{
    public class LogStartLesson(string userId, int userGroup, int lessonId) : LogBasic(userId, userGroup)
    {
        public int LessonId { get; set; } = lessonId;
    }
}
