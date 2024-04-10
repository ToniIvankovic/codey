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
    public class Startup(IConfiguration configuration)
    {
        private IConfiguration Configuration { get; } = configuration;

        public static void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }

        public void ConfigureServices(IServiceCollection services)
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
                mongoIdentityOptions.ConnectionString = Configuration["database:ConnectionString"] + "/" + Configuration["database:DatabaseName"];
                mongoIdentityOptions.UsersCollection = Configuration["database:UsersCollectionName"];
                mongoIdentityOptions.RolesCollection = Configuration["database:UserRolesCollectionName"];
            });

            services.Configure<JWTSettings>(Configuration.GetSection("JWTSettings"));
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
                    ValidIssuer = Configuration["JWTSettings:Issuer"],
                    ValidAudience = Configuration["JWTSettings:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(Configuration["JWTSettings:Key"]!)
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
            services.AddScoped<IClassesRepository>(provider =>
            {
                IMongoDbContext dbContext = provider.GetRequiredService<IMongoDbContext>();
                return new ClassesRepository(dbContext);
            });


            // Configure the services
            services.AddScoped<ILessonGroupsService, LessonGroupsService>();
            services.AddScoped<ILessonsService, LessonsService>();
            services.AddScoped<IExercisesService, ExercisesService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<ITokenGeneratorService, TokenGeneratorService>();
            services.AddScoped<ILogsService, LogsService>();
            services.AddScoped<IInteractionService, InteractionService>();
        }
    }

}
