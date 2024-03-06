using CodeyBE.Contracts.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Repositories
{
    public interface IExercisesRepository : IRepository<Exercise>
    {
        IEnumerable<Exercise> GetExercisesByID(IEnumerable<int> ids);

        public static Exercise MapToSpecificExerciseType(Exercise exercise)
        {
            return exercise.Type switch
            {
                "MC" => new ExerciseMC(exercise),
                "SA" => new ExerciseSA(exercise),
                "LA" => new ExerciseLA(exercise),
                "SCW" => new ExerciseSCW(exercise),
                _ => new Exercise(exercise),
            };
        }
    }
}
