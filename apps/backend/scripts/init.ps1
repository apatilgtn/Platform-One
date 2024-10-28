# apps/backend/scripts/init.ps1

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Create directory structure
Write-ColorOutput Yellow "Creating directory structure..."
$directories = @(
    "src",
    "src/controllers",
    "src/models",
    "src/routes",
    "src/middleware",
    "src/utils",
    "prisma",
    "scripts"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Create package.json if it doesn't exist
if (-not (Test-Path "package.json")) {
    Write-ColorOutput Yellow "Creating package.json..."
    $packageJson = @{
        name = "platform-one-backend"
        version = "1.0.0"
        description = "Platform One Backend Service"
        main = "src/index.ts"
        scripts = @{
            dev = "ts-node-dev --respawn src/index.ts"
            build = "tsc"
            start = "node dist/index.ts"
            "prisma:generate" = "prisma generate"
            "prisma:migrate" = "prisma migrate dev"
        }
        dependencies = @{
            "@prisma/client" = "^4.16.2"
            express = "^4.18.2"
            cors = "^2.8.5"
            dotenv = "^16.0.3"
        }
        devDependencies = @{
            "@types/express" = "^4.17.17"
            "@types/node" = "^18.16.0"
            prisma = "^4.16.2"
            "ts-node" = "^10.9.1"
            "ts-node-dev" = "^2.0.0"
            typescript = "^5.0.4"
        }
    }

    $packageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath "package.json" -Encoding UTF8
}

# Run Prisma setup
Write-ColorOutput Yellow "Running Prisma setup..."
.\scripts\prisma-setup.ps1

Write-ColorOutput Green "Backend initialization completed!"