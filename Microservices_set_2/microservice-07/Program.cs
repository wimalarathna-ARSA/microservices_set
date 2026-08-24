using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);
var port = Environment.GetEnvironmentVariable("PORT") ?? "3007";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();
var serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "service-csharp-07";
var platform = Environment.GetEnvironmentVariable("PLATFORM") ?? "render";

long incomingRequests = 0;
long processingRequests = 0;

app.Use(async (context, next) =>
{
    Interlocked.Increment(ref incomingRequests);
    try
    {
        await next();
    }
    finally
    {
        Interlocked.Increment(ref processingRequests);
    }
});

app.MapGet("/", () => "Hello from Microservice 07 (C# ASP.NET Core)");

app.MapGet("/ping", () => Results.Ok(new { status = "ok", service = serviceName }));

app.MapGet("/spike", (int? duration) =>
{
    int dur = duration ?? 10;
    DateTime endTime = DateTime.UtcNow.AddSeconds(dur);
    while (DateTime.UtcNow < endTime)
    {
        Math.Sqrt(64 * 64 * 64 * 64);
    }
    return Results.Ok(new { message = $"CPU spiked for {dur} seconds", service = serviceName });
});

app.MapGet("/metrics", () =>
{
    long inc = Interlocked.Read(ref incomingRequests);
    long proc = Interlocked.Read(ref processingRequests);
    long queue = Math.Max(0, inc - proc);

    return Results.Ok(new
    {
        platform = platform,
        service = serviceName,
        timestamp = DateTime.UtcNow.ToString("o"),
        cpu_usage_percent = 0.0,
        incoming_requests = inc,
        processing_requests = proc,
        queue_length = queue,
        measurement_method = "application_runtime",
        cpu_allocation = $"{Environment.ProcessorCount}vCPU"
    });
});

app.Run();