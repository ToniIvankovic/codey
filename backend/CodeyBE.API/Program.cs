using CodeyBE.API;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddSwaggerGen();
//IoC
var startup = new Startup(builder.Configuration);
startup.ConfigureServices(builder.Services);

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
//{
//    app.UseSwagger();
//    app.UseSwaggerUI();
//}


//app.UseHttpsRedirection();

//app.Use(async (context, next) =>
//{
//    var request = context.Request;
//    Console.WriteLine("Request User-Agent: " + request.Headers.UserAgent);
//    //write the contents of the request body
//    if (request.Method == HttpMethods.Post && request.ContentLength > 0)
//    {
//        request.EnableBuffering();
//        var buffer = new byte[Convert.ToInt32(request.ContentLength)];
//        await request.Body.ReadAsync(buffer, 0, buffer.Length);
//        //get body string here...
//        var requestContent = Encoding.UTF8.GetString(buffer);
//        request.Body.Position = 0;  //rewinding the stream to 0
//    }
//    await next(context);
//});

Startup.Configure(app, app.Environment);

app.Run();
