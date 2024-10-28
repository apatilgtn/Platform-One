# apps/backend/scripts/prisma-setup.ps1

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Define paths
$rootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$prismaDir = Join-Path $rootDir "prisma"
$envPath = Join-Path $rootDir ".env"

# Create Prisma directory
Write-ColorOutput Green "Creating Prisma directory..."
New-Item -ItemType Directory -Force -Path $prismaDir | Out-Null

# Create schema.prisma with explicit UTF8 encoding
$schemaContent = @'
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

# Create schema file with UTF8 encoding without BOM
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$schemaPath = Join-Path $prismaDir "schema.prisma"
[System.IO.File]::WriteAllLines($schemaPath, $schemaContent.Split("`n"), $Utf8NoBomEncoding)

Write-ColorOutput Green "Created schema.prisma at $schemaPath"

# Create .env file
$envContent = @'
# Database Connection
DATABASE_URL="postgresql://platform_dev:dev_password@localhost:5432/platform_dev"

# Server Configuration
PORT=8000
NODE_ENV=development

# Authentication
JWT_SECRET="your-secret-key"
JWT_EXPIRES_IN="1d"
'@

[System.IO.File]::WriteAllLines($envPath, $envContent.Split("`n"), $Utf8NoBomEncoding)
Write-ColorOutput Green "Created .env file at $envPath"

# Install required dependencies
Write-ColorOutput Yellow "Installing Prisma dependencies..."
try {
    # Install Prisma CLI and client
    npm install prisma @prisma/client --save-dev

    # Generate Prisma Client
    Write-ColorOutput Yellow "Generating Prisma Client..."
    npx prisma generate

    Write-ColorOutput Green "Prisma setup completed successfully!"
} catch {
    Write-ColorOutput Red "Error during Prisma setup: $_"
    exit 1
}