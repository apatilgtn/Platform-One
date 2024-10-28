# apps/backend/scripts/init-backend.ps1

# Function to write colored output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "Initializing Backend..."

# Ensure we're in the backend directory
$backendDir = Split-Path -Parent $PSScriptRoot
Set-Location $backendDir

# Clean up existing files
Write-ColorOutput Yellow "Cleaning up existing files..."
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue node_modules
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue prisma
Remove-Item -Force -ErrorAction SilentlyContinue package-lock.json
Remove-Item -Force -ErrorAction SilentlyContinue .env

# Create package.json
Write-ColorOutput Yellow "Creating package.json..."
@'
{
  "name": "platform-one-backend",
  "version": "1.0.0",
  "main": "src/index.ts",
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
'@ | Out-File -FilePath "package.json" -Encoding utf8NoBOM

# Install dependencies
Write-ColorOutput Yellow "Installing dependencies..."
npm install

# Create Prisma schema
Write-ColorOutput Yellow "Setting up Prisma..."
./scripts/create-prisma-schema.ps1

Write-ColorOutput Green "Backend initialization completed!"