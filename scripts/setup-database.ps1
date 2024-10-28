# C:\Devops-Projects\Platform-One\scripts\setup-database.ps1

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Ensure we're in the project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Create init-scripts directory if it doesn't exist
if (-not (Test-Path "init-scripts")) {
    New-Item -ItemType Directory -Path "init-scripts"
}

# Create init.sql
$initSqlContent = @"
CREATE USER platform_dev WITH PASSWORD 'dev_password';
CREATE DATABASE platform_dev;
GRANT ALL PRIVILEGES ON DATABASE platform_dev TO platform_dev;
\c platform_dev
GRANT ALL ON SCHEMA public TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO platform_dev;
"@

Set-Content -Path "init-scripts/init.sql" -Value $initSqlContent -Encoding UTF8

# Create docker-compose.yml if it doesn't exist
$dockerComposeContent = @"
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
"@

Set-Content -Path "docker-compose.yml" -Value $dockerComposeContent -Encoding UTF8

# Stop existing containers
Write-ColorOutput Yellow "Stopping existing containers..."
docker-compose down -v

# Remove existing volume
Write-ColorOutput Yellow "Removing existing volumes..."
docker volume rm platform-one_postgres_data -f

# Start PostgreSQL
Write-ColorOutput Yellow "Starting PostgreSQL..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
Write-ColorOutput Yellow "Waiting for PostgreSQL to be ready..."
$maxAttempts = 30
$attempt = 1
$ready = $false

while (-not $ready -and $attempt -le $maxAttempts) {
    try {
        $result = docker-compose exec -T postgres pg_isready -U postgres
        if ($LASTEXITCODE -eq 0) {
            $ready = $true
            Write-ColorOutput Green "PostgreSQL is ready!"
        } else {
            Write-ColorOutput Yellow "Waiting for PostgreSQL... Attempt $attempt of $maxAttempts"
            Start-Sleep -Seconds 2
            $attempt++
        }
    } catch {
        Write-ColorOutput Yellow "Waiting for PostgreSQL... Attempt $attempt of $maxAttempts"
        Start-Sleep -Seconds 2
        $attempt++
    }
}

if (-not $ready) {
    Write-ColorOutput Red "Failed to connect to PostgreSQL after $maxAttempts attempts"
    exit 1
}

# Additional wait for init scripts
Write-ColorOutput Yellow "Waiting for initialization scripts to complete..."
Start-Sleep -Seconds 5

# Verify database setup
Write-ColorOutput Yellow "Verifying database setup..."
try {
    # Test connection as platform_dev user
    $test = docker-compose exec -T postgres psql -U platform_dev -d platform_dev -c "\dt"
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "Database setup verified successfully!"
    } else {
        Write-ColorOutput Red "Database verification failed"
        exit 1
    }
} catch {
    Write-ColorOutput Red "Database verification failed: $_"
    exit 1
}