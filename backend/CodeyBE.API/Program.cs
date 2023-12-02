using CodeyBE.API;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

//IoC
Startup.ConfigureServices(builder.Services);

//builder.Services.AddScoped<IService, Service>();
//builder.Services.AddScoped<DbContext, ApplicationDbContext>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

//app.UseMiddleware<ExceptionMiddleware>();

app.Use(async (context, next) =>
{
    var request = context.Request;
    Console.WriteLine("Request User-Agent: " + request.Headers.UserAgent);
    await next(context);
});

app.MapControllers();

app.Run();
