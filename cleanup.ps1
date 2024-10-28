# C:\Devops-Projects\Platform-One\cleanup.ps1

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Yellow "Cleaning up Platform One setup..."

# Stop Docker containers
Write-ColorOutput Yellow "Stopping Docker containers..."
docker-compose down -v

# Remove node_modules
Write-ColorOutput Yellow "Removing node_modules..."
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/backend/node_modules
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/frontend/node_modules

# Remove generated files
Write-ColorOutput Yellow "Removing generated files..."
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue apps/backend/prisma/migrations
Remove-Item -Force -ErrorAction SilentlyContinue apps/backend/.env
Remove-Item -Force -ErrorAction SilentlyContinue apps/backend/package-lock.json
Remove-Item -Force -ErrorAction SilentlyContinue apps/frontend/.env
Remove-Item -Force -ErrorAction SilentlyContinue apps/frontend/package-lock.json

Write-ColorOutput Green "Cleanup completed!"
Write-ColorOutput Yellow "You can now run setup-project.ps1 to reinitialize the project."