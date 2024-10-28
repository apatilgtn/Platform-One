# C:\Devops-Projects\Platform-One\setup-project.ps1

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Function to write file with UTF8 encoding without BOM
function Write-FileWithEncoding {
    param (
        [string]$Path,
        [string]$Content
    )
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBomEncoding)
}

# Create project structure
Write-ColorOutput Yellow "Creating project structure..."
$directories = @(
    "apps/frontend/src",
    "apps/frontend/public",
    "apps/backend/src",
    "apps/backend/prisma",
    "apps/backend/scripts",
    "packages/common/src",
    "packages/ui-components/src",
    "packages/api-client/src",
    "infrastructure/docker",
    "infrastructure/kubernetes",
    "infrastructure/terraform",
    "tools/scripts",
    "docs"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Create backend setup
Write-ColorOutput Yellow "Setting up backend..."

# Create Prisma schema
$prismaSchema = @'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  password  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Service {
  id          String   @id @default(cuid())
  name        String
  description String
  repository  String
  status      String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
'@

Write-FileWithEncoding -Path "apps/backend/prisma/schema.prisma" -Content $prismaSchema

# Create backend .env
$backendEnv = @'
DATABASE_URL="postgresql://platform_dev:dev_password@localhost:5432/platform_dev"
PORT=8000
JWT_SECRET="dev_secret_key"
'@

Write-FileWithEncoding -Path "apps/backend/.env" -Content $backendEnv

# Create backend package.json
$backendPackageJson = @'
{
  "name": "@platform-one/backend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev --respawn src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev"
  },
  "dependencies": {
    "@prisma/client": "4.16.2",
    "express": "4.18.2",
    "cors": "2.8.5",
    "dotenv": "16.0.3"
  },
  "devDependencies": {
    "@types/express": "4.17.17",
    "@types/node": "18.16.0",
    "prisma": "4.16.2",
    "ts-node": "10.9.1",
    "ts-node-dev": "2.0.0",
    "typescript": "5.0.4"
  }
}
'@

Write-FileWithEncoding -Path "apps/backend/package.json" -Content $backendPackageJson

# Create docker-compose.yml
$dockerCompose = @'
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_USER: platform_dev
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: platform_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U platform_dev"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
'@

Write-FileWithEncoding -Path "docker-compose.yml" -Content $dockerCompose

# Check if Docker is running
Write-ColorOutput Yellow "Checking Docker status..."
try {
    $dockerRunning = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "Docker is not running. Please start Docker Desktop and try again."
        exit 1
    }
} catch {
    Write-ColorOutput Red "Docker is not running or not installed. Please install Docker Desktop and try again."
    exit 1
}

# Start Docker services
Write-ColorOutput Yellow "Starting Docker services..."
docker-compose up -d postgres

# Wait for PostgreSQL
Write-ColorOutput Yellow "Waiting for PostgreSQL to be ready..."
$retries = 30
$ready = $false

while (-not $ready -and $retries -gt 0) {
    try {
        $result = docker-compose exec -T postgres pg_isready -U platform_dev
        if ($LASTEXITCODE -eq 0) {
            $ready = $true
            Write-ColorOutput Green "PostgreSQL is ready!"
        } else {
            Write-ColorOutput Yellow "Waiting for PostgreSQL... ($retries attempts remaining)"
            Start-Sleep -Seconds 2
            $retries--
        }
    } catch {
        Write-ColorOutput Yellow "Waiting for PostgreSQL... ($retries attempts remaining)"
        Start-Sleep -Seconds 2
        $retries--
    }
}

if (-not $ready) {
    Write-ColorOutput Red "PostgreSQL failed to start. Please check Docker logs."
    exit 1
}

# Setup backend
Write-ColorOutput Yellow "Installing backend dependencies..."
Push-Location apps/backend
try {
    npm install
    npx prisma generate
    npx prisma migrate dev --name init
} catch {
    Write-ColorOutput Red "Error during backend setup: $_"
    exit 1
} finally {
    Pop-Location
}

Write-ColorOutput Green "Setup completed successfully!"
Write-ColorOutput Yellow "Next steps:"
Write-ColorOutput White "1. Start the backend:"
Write-ColorOutput White "   cd apps/backend && npm run dev"
Write-ColorOutput White "2. Start the frontend (when ready):"
Write-ColorOutput White "   cd apps/frontend && npm run dev"