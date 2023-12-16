using CodeyBe.Services;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBE.Data.DB.Configurations;
using CodeyBE.Data.DB.Repositories;

namespace CodeyBE.API
{
    // Startup.cs
    public class Startup
    {
        public static void ConfigureServices(IServiceCollection services)
        {
            // Configure the MongoDB context
            services.AddScoped<IMongoDbContext>(provider =>
            {
                IConfiguration configuration = provider.GetRequiredService<IConfiguration>();
                string? connectionString = configuration["database:ConnectionString"];
                string? databaseName = configuration["database:DatabaseName"];
                if(connectionString == null || databaseName == null)
                {
                    throw new Exception("Database configuration is missing");
                }
                return new ApplicationDbContext(connectionString, databaseName);
            });

            // Configure the repositories
            services.AddScoped<ILessonGroupsRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new LessonGroupsRepository(dbContext);
            });
            services.AddScoped<ILessonsRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new LessonsRepository(dbContext);
            });
            services.AddScoped<IExercisesRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new ExercisesRepository(dbContext);
            });

            // Configure the services
            services.AddScoped<ILessonGroupsService>(provider =>
            {
                return new LessonGroupsService(provider.GetRequiredService<ILessonGroupsRepository>());
            });
            services.AddScoped<ILessonsService>(provider =>
            {
                return new LessonsService(provider.GetRequiredService<ILessonsRepository>(), provider.GetRequiredService<ILessonGroupsService>());
            });
            services.AddScoped<IExercisesService>(provider =>
            {
                return new ExercisesService(provider.GetRequiredService<IExercisesRepository>(), provider.GetRequiredService<ILessonsService>());
            });
        }
    }

}
