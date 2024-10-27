// platform-one/setup.ps1
# Setup script for Platform One

Write-Host "Setting up Platform One Development Environment..." -ForegroundColor Blue

# Check prerequisites
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

if (-not (Test-Command node)) {
    Write-Host "Node.js is required but not installed. Aborting." -ForegroundColor Red
    exit 1
}

if (-not (Test-Command docker)) {
    Write-Host "Docker is required but not installed. Aborting." -ForegroundColor Red
    exit 1
}

# Create directories
Write-Host "Creating project structure..." -ForegroundColor Blue
$dirs = @(
    "apps/frontend/src",
    "apps/backend/src",
    "packages/common/src",
    "configs/dev",
    "infrastructure"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# Create environment files
Write-Host "Creating environment files..." -ForegroundColor Blue

# Root .env
@"
DB_USER=platform_dev
DB_PASSWORD=dev_password
DB_NAME=platform_dev
JWT_SECRET=dev_secret_key
NODE_ENV=development
"@ | Out-File -FilePath ".env" -Encoding UTF8

# Frontend .env
@"
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000
"@ | Out-File -FilePath "apps/frontend/.env" -Encoding UTF8

# Backend .env
@"
PORT=8000
DATABASE_URL=postgresql://platform_dev:dev_password@localhost:5432/platform_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET=dev_secret_key
"@ | Out-File -FilePath "apps/backend/.env" -Encoding UTF8

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Blue
npm install

# Start Docker services
Write-Host "Starting Docker services..." -ForegroundColor Blue
docker-compose up -d

# Wait for services
Write-Host "Waiting for services to be ready..." -ForegroundColor Blue
Start-Sleep -Seconds 10

# Setup database
Write-Host "Setting up database..." -ForegroundColor Blue
Push-Location apps/backend
npm run prisma:generate
npm run prisma:migrate
Pop-Location

# Build packages
Write-Host "Building packages..." -ForegroundColor Blue
npm run build

Write-Host "`nSetup complete! You can now start the development servers:" -ForegroundColor Green
Write-Host "1. Frontend: " -NoNewline
Write-Host "npm run dev --workspace=@platform-one/frontend" -ForegroundColor Blue
Write-Host "2. Backend: " -NoNewline
Write-Host "npm run dev --workspace=@platform-one/backend" -ForegroundColor Blue
Write-Host "`nOr use Docker Compose:"
Write-Host "docker-compose up" -ForegroundColor Blue