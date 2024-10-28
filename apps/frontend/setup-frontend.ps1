# C:\Devops-Projects\Platform-One\apps\frontend\setup-frontend.ps1

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Clean up existing files
Write-ColorOutput Yellow "Cleaning up existing files..."
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue node_modules
Remove-Item -Force -ErrorAction SilentlyContinue package-lock.json

# Create necessary directories
Write-ColorOutput Yellow "Creating directory structure..."
New-Item -ItemType Directory -Force -Path "src/styles" | Out-Null

# Create tailwind.css
Write-ColorOutput Yellow "Creating Tailwind CSS file..."
@"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ | Out-File -FilePath "src/styles/tailwind.css" -Encoding utf8 -NoNewline

# Install dependencies
Write-ColorOutput Yellow "Installing dependencies..."
npm install

Write-ColorOutput Green "Frontend setup completed!"
Write-ColorOutput Yellow "You can now run 'npm run dev' to start the development server"