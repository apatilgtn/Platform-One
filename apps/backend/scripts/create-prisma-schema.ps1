# apps/backend/scripts/create-prisma-schema.ps1

# Ensure we're in the backend directory
$backendDir = Split-Path -Parent $PSScriptRoot
Set-Location $backendDir

# Create prisma directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "prisma" | Out-Null

# Create the schema file directly
@'
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
'@ | Out-File -FilePath "prisma/schema.prisma" -Encoding utf8NoBOM -NoNewline

# Create .env file if it doesn't exist
@'
DATABASE_URL="postgresql://platform_dev:dev_password@localhost:5432/platform_dev"
'@ | Out-File -FilePath ".env" -Encoding utf8NoBOM -NoNewline

# Install required packages
npm install -D prisma @prisma/client

# Generate Prisma client
npx prisma generate