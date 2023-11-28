using CodeyBE.Contracts.Repositories;
using CodeyBE.Data.DB.Configurations;
using CodeyBE.Data.DB.Repositories;

namespace CodeyBE.API
{
    // Startup.cs
    public class Startup
    {
        public static void ConfigureServices(IServiceCollection services)
        {
            // Other services...

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

            services.AddScoped<ILessonGroupsRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new LessonGroupsRepository(dbContext);
            });

            // Other configurations...
        }

        // Other methods...
    }

}
