
param(
    [string]$username = "MarllonAnisio",
    [string]$output = "output/github-contribution-grid-snake.svg"
)

function Ensure-OutputDir {
    $dir = Split-Path -Path $output -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm not found. Install Node.js (includes npm) before running this script."
    exit 1
}

Ensure-OutputDir

Write-Host "Generating contribution snake for user '$username' -> $output"

# Run npx to generate the SVG. PowerShell doesn't support the bash-style '||' operator,
# so run the command and check the exit code.
& npx --yes github-contribution-grid-snake -u $username -o $output --theme dark

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to generate snake using npx. Exit code: $LASTEXITCODE"
    Write-Host "Common causes:"
    Write-Host " - package not found on npm (HTTP 404)"
    Write-Host " - network issues or npm auth problems"
    Write-Host "Suggested actions:"
    Write-Host " - Verifique se o pacote 'github-contribution-grid-snake' existe no npm."
    Write-Host " - Tente executar manualmente: npx --yes github-contribution-grid-snake -u $username -o $output --theme dark"
    Write-Host " - Se o pacote não existir, considere usar uma GitHub Action que gere o SVG e o coloque em 'output/' ou mantenha o placeholder SVG."
    exit 1
}

Write-Host "Done. Output: $output"
