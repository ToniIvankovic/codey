using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities;
using CodeyBE.Contracts.Enumerations;
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
                ExerciseTypes.MULTIPLE_CHOICE => new ExerciseMC(exercise),
                ExerciseTypes.SHORT_ANSWER => new ExerciseSA(exercise),
                ExerciseTypes.LONG_ANSWER => new ExerciseLA(exercise),
                ExerciseTypes.SHORT_CODE_WRITING => new ExerciseSCW(exercise),
                _ => new Exercise(exercise),
            };
        }

        Task<Exercise> CreateAsync(ExerciseCreationDTO exercise);
        Task<Exercise> UpdateAsync(int id, ExerciseCreationDTO exercise);
        Task DeleteAsync(int id);
    }
}
