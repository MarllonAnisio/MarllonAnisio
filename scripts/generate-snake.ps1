
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
# so run the command and check the exit code. Try npm package first, then fallback to
# running directly from the GitHub repo via npx user/repo syntax if package not found.

$generateCommands = @(
    @{ cmd = "npx --yes github-contribution-grid-snake -u $username -o $output --theme dark"; desc = "npm package" },
    @{ cmd = "npx --yes platane/github-contribution-grid-snake -u $username -o $output --theme dark"; desc = "GitHub repo fallback (platane)" }
)

$succeeded = $false
foreach ($entry in $generateCommands) {
    Write-Host "Trying generation via: $($entry.desc)"
    Write-Host "> $($entry.cmd)"
    & pwsh -NoProfile -Command $entry.cmd
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Generation succeeded using: $($entry.desc)"
        $succeeded = $true
        break
    } else {
        Write-Host "Attempt failed (exit code $LASTEXITCODE). Trying next fallback if available..."
    }
}

if (-not $succeeded) {
    Write-Error "All generation attempts failed. Last exit code: $LASTEXITCODE"
    Write-Host "Common causes:"
    Write-Host " - package not found on npm (HTTP 404) or the GitHub repo doesn't expose the CLI as expected"
    Write-Host " - network issues or npm auth problems"
    Write-Host "Suggested actions:"
    Write-Host " - Verifique manualmente se existe um pacote npm ou o repositório GitHub que fornece o CLI."
    Write-Host " - Considere usar uma GitHub Action que gere o SVG no runner e commite em 'output/'."
    Write-Host " - Se preferir, mantenha o placeholder SVG incluído no repositório (arquivo 'output/github-contribution-grid-snake.svg')."
    exit 1
}

Write-Host "Done. Output: $output"
