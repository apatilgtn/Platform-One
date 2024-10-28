# setup.ps1

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Wait-ForPostgres {
    Write-ColorOutput Yellow "Waiting for PostgreSQL to be ready..."
    $maxAttempts = 30
    $attempt = 0
    $ready = $false

    while (-not $ready -and $attempt -lt $maxAttempts) {
        try {
            $attempt++
            $result = docker-compose exec postgres pg_isready -U platform_dev
            if ($LASTEXITCODE -eq 0) {
                $ready = $true
                Write-ColorOutput Green "PostgreSQL is ready!"
            } else {
                Write-ColorOutput Yellow "Waiting for PostgreSQL... (Attempt $attempt/$maxAttempts)"
                Start-Sleep -Seconds 2
            }
        } catch {
            Write-ColorOutput Yellow "Waiting for PostgreSQL... (Attempt $attempt/$maxAttempts)"
            Start-Sleep -Seconds 2
        }
    }

    if (-not $ready) {
        throw "PostgreSQL failed to start within the allowed time"
    }
}

# Stop and remove existing containers
Write-ColorOutput Yellow "Cleaning up existing Docker containers..."
docker-compose down -v

# Remove existing node_modules and build artifacts
Write-ColorOutput Yellow "Cleaning up existing build artifacts..."
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/backend/node_modules
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/frontend/node_modules
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/backend/prisma/migrations
Remove-Item -Force -ErrorAction SilentlyContinue apps/backend/.env
Remove-Item -Force -ErrorAction SilentlyContinue apps/frontend/.env

# Create Prisma schema
Write-ColorOutput Yellow "Creating Prisma schema..."
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

# Ensure Prisma directory exists
New-Item -ItemType Directory -Force -Path "apps/backend/prisma" | Out-Null
$prismaSchema | Out-File -FilePath "apps/backend/prisma/schema.prisma" -Encoding UTF8

# Create environment files
Write-ColorOutput Yellow "Creating environment files..."

# Backend .env
$backendEnv = @"
DATABASE_URL="postgresql://platform_dev:dev_password@localhost:5432/platform_dev"
JWT_SECRET="dev_secret_key"
PORT=8000
"@
$backendEnv | Out-File -FilePath "apps/backend/.env" -Encoding UTF8

# Frontend .env
$frontendEnv = @"
VITE_API_URL=http://localhost:8000
"@
$frontendEnv | Out-File -FilePath "apps/frontend/.env" -Encoding UTF8

# Start Docker services
Write-ColorOutput Yellow "Starting Docker services..."
docker-compose up -d postgres

# Wait for PostgreSQL
Wait-ForPostgres

# Install dependencies and initialize database
Write-ColorOutput Yellow "Installing dependencies and initializing database..."
try {
    # Install backend dependencies
    Set-Location apps/backend
    npm install
    
    # Initialize Prisma
    Write-ColorOutput Yellow "Generating Prisma client..."
    npx prisma generate
    if ($LASTEXITCODE -ne 0) { throw "Prisma generate failed" }

    # Run migrations
    Write-ColorOutput Yellow "Running database migrations..."
    npx prisma migrate dev --name init
    if ($LASTEXITCODE -ne 0) { throw "Prisma migrations failed" }
    
    Set-Location ../..
    
    # Install frontend dependencies
    Set-Location apps/frontend
    npm install
    Set-Location ../..

} catch {
    Write-ColorOutput Red "Error during setup: $_"
    Write-ColorOutput Yellow "Cleaning up..."
    docker-compose down -v
    exit 1
}

Write-ColorOutput Green "`nSetup completed successfully!"
Write-ColorOutput Yellow "To start the development servers:"
Write-ColorOutput White "1. Frontend (in a new terminal):"
Write-ColorOutput White "   cd apps/frontend && npm run dev"
Write-ColorOutput White "2. Backend (in a new terminal):"
Write-ColorOutput White "   cd apps/backend && npm run dev"
Write-ColorOutput Yellow "`nTo verify the database setup:"
Write-ColorOutput White "   cd apps/backend && npx prisma studio"