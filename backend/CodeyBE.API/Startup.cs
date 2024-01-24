using AspNetCore.Identity.Mongo;
using AspNetCore.Identity.Mongo.Model;
using CodeyBe.Services;
using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Repositories;
using CodeyBE.Contracts.Services;
using CodeyBE.Data.DB.Configurations;
using CodeyBE.Data.DB.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace CodeyBE.API
{
    // Startup.cs
    public static class Startup
    {
        public static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            // Configure the MongoDB context
            services.AddScoped<IMongoDbContext>(provider =>
            {
                IConfiguration configuration = provider.GetRequiredService<IConfiguration>();
                string? connectionString = configuration["database:ConnectionString"];
                string? databaseName = configuration["database:DatabaseName"];
                if (connectionString == null || databaseName == null)
                {
                    throw new Exception("Database configuration is missing");
                }
                return new ApplicationDbContext(connectionString, databaseName);
            });
            services.AddIdentityMongoDbProvider<ApplicationUser, MongoRole>(identityOptions =>
            {
                identityOptions.Password.RequiredLength = 8;
                identityOptions.Password.RequireLowercase = true;
                identityOptions.Password.RequireUppercase = true;
                identityOptions.Password.RequireDigit = true;
                identityOptions.Password.RequireNonAlphanumeric = false;
            },
            mongoIdentityOptions =>
            {

                mongoIdentityOptions.ConnectionString = configuration["database:ConnectionString"] + "/" + configuration["database:DatabaseName"];
                mongoIdentityOptions.UsersCollection = "Users";
                mongoIdentityOptions.RolesCollection = "Roles";
            });

            services.Configure<JWTSettings>(configuration.GetSection("JWTSettings"));
            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.SaveToken = true;
                options.RequireHttpsMetadata = false;
                options.TokenValidationParameters = new TokenValidationParameters()
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = configuration["JWTSettings:Issuer"],
                    ValidAudience = configuration["JWTSettings:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(configuration["JWTSettings:Key"]!)
                        ),
                    ValidateIssuerSigningKey = true,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };
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
            services.AddScoped<ILogsRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new LogsRepository(dbContext);
            });


            // Configure the services
            services.AddScoped<ILessonGroupsService, LessonGroupsService>();
            services.AddScoped<ILessonsService, LessonsService>();
            services.AddScoped<IExercisesService, ExercisesService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<ITokenGeneratorService, TokenGeneratorService>();
            services.AddScoped<ILogsService, LogsService>();
        }
    }

}
