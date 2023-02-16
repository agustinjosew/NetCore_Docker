# Define variables
$projectName = "MyProject"
$solutionPath = "C:\Projects\$projectName"
$apiName = "$projectName.API"
$docsPath = "$solutionPath\docs"

# Create solution and navigate to solution directory
dotnet new sln -n $projectName -o $solutionPath
Set-Location $solutionPath

# Create projects
dotnet new classlib -n "$projectName.Domain" -o "$solutionPath\src\$projectName.Domain"
dotnet new classlib -n "$projectName.Infrastructure" -o "$solutionPath\src\$projectName.Infrastructure"
dotnet new webapi -n $apiName -o "$solutionPath\src\$apiName"

# Add projects to solution
dotnet sln add "$solutionPath\src\$projectName.Domain\$projectName.Domain.csproj"
dotnet sln add "$solutionPath\src\$projectName.Infrastructure\$projectName.Infrastructure.csproj"
dotnet sln add "$solutionPath\src\$apiName\$apiName.csproj"

# Add project references
dotnet add "$solutionPath\src\$projectName.Infrastructure\$projectName.Infrastructure.csproj" reference "$solutionPath\src\$projectName.Domain\$projectName.Domain.csproj"
dotnet add "$solutionPath\src\$apiName\$apiName.csproj" reference "$solutionPath\src\$projectName.Domain\$projectName.Domain.csproj"
dotnet add "$solutionPath\src\$apiName\$apiName.csproj" reference "$solutionPath\src\$projectName.Infrastructure\$projectName.Infrastructure.csproj"

# Create directories for Swagger documentation
New-Item -ItemType Directory -Force -Path $docsPath
New-Item -ItemType Directory -Force -Path "$docsPath\swagger"

# Install NuGet packages
dotnet add "$solutionPath\src\$apiName\$apiName.csproj" package Swashbuckle.AspNetCore

# Add Swagger configuration to Startup.cs
Add-Content "$solutionPath\src\$apiName\Startup.cs" @"
services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "$projectName API", Version = "v1" });
});

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "$projectName API v1");
    c.RoutePrefix = string.Empty;
});
"@

# Build the solution
dotnet build

# Open the Swagger documentation in a browser
Start-Process "http://localhost:5000/swagger/index.html"
