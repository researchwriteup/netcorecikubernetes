FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
# Replace this with your application name and respective path
COPY ["DotNetCoreDemo/DotNetCoreDemo.csproj", "DotNetCoreDemo/"] 
# Replace this with your application name and respective path
RUN dotnet restore "DotNetCoreDemo/DotNetCoreDemo.csproj" 
COPY . .
# Replace this with your application name and respective path
WORKDIR "/src/DotNetCoreDemo" 
# Replace this with your application name and respective path
RUN dotnet build "DotNetCoreDemo.csproj" -c Release -o /app 
# Replace this with your application name and respective path
FROM build AS publish
RUN dotnet publish "DotNetCoreDemo.csproj" -c Release -o /app 

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
# Replace this with your application name and respective path
ENTRYPOINT ["dotnet", "DotNetCoreDemo.dll"] 
