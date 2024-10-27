// platform-one/setup.bat
@echo off
setlocal enabledelayedexpansion

echo Setting up Platform One Development Environment...

:: Check prerequisites
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Node.js is required but not installed. Aborting.
    exit /b 1
)

where docker >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Docker is required but not installed. Aborting.
    exit /b 1
)

:: Create directories
echo Creating project structure...
mkdir apps\frontend\src 2>nul
mkdir apps\backend\src 2>nul
mkdir packages\common\src 2>nul
mkdir configs\dev 2>nul
mkdir infrastructure 2>nul

:: Create environment files
echo Creating environment files...

:: Root .env
echo DB_USER=platform_dev> .env
echo DB_PASSWORD=dev_password>> .env
echo DB_NAME=platform_dev>> .env
echo JWT_SECRET=dev_secret_key>> .env
echo NODE_ENV=development>> .env

:: Frontend .env
echo VITE_API_URL=http://localhost:8000> apps\frontend\.env
echo VITE_WS_URL=ws://localhost:8000>> apps\frontend\.env

:: Backend .env
echo PORT=8000> apps\backend\.env
echo DATABASE_URL=postgresql://platform_dev:dev_password@localhost:5432/platform_dev>> apps\backend\.env
echo REDIS_URL=redis://localhost:6379>> apps\backend\.env
echo JWT_SECRET=dev_secret_key>> apps\backend\.env

:: Install dependencies
echo Installing dependencies...
call npm install

:: Start Docker services
echo Starting Docker services...
docker-compose up -d

:: Wait for services
echo Waiting for services to be ready...
timeout /t 10 /nobreak

:: Setup database
echo Setting up database...
cd apps\backend
call npm run prisma:generate
call npm run prisma:migrate
cd ..\..

:: Build packages
echo Building packages...
call npm run build

echo Setup complete! You can now start the development servers:
echo 1. Frontend: npm run dev --workspace=@platform-one/frontend
echo 2. Backend: npm run dev --workspace=@platform-one/backend
echo.
echo Or use Docker Compose:
echo docker-compose up

endlocal