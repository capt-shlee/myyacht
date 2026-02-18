<#
.SYNOPSIS
    MyYacht Safe Deployment Script (SafeShip)
.DESCRIPTION
    Safely commits, tags, and pushes changes to the repository.
    Ensures a rollback point exists before every deployment.
.PARAMETER Message
    Commit message for the update.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"

# 1. Check Git Status
Write-Host "⚓ Checking ship status..." -ForegroundColor Cyan
$status = git status --porcelain
if (-not $status) {
    Write-Host "  - No changes to commit. Proceeding to push existing commits?" -ForegroundColor Yellow
    $confirm = Read-Host "  - Type 'YES' to continue pushing without new commits"
    if ($confirm -ne 'YES') { exit }
} else {
    git add .
    git commit -m "$Message"
    Write-Host "  - Changes stowed and secured." -ForegroundColor Green
}

# 2. Operations check (Pull first)
Write-Host "⚓ Checking for incoming waves (git pull)..." -ForegroundColor Cyan
git pull origin main --rebase
if ($LASTEXITCODE -ne 0) {
    Write-Error "Conflict detected! Please resolve conflicts manually."
}

# 3. Create Safety Tag
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tagName = "backup-pre-deploy-$timestamp"
Write-Host "⚓ Dropping anchor (Creating backup tag: $tagName)..." -ForegroundColor Cyan
git tag $tagName
Write-Host "  - Anchor dropped. Rollback point secured." -ForegroundColor Green

# 4. Push to Remote
Write-Host "⚓ Setting sail (Pushing to origin)..." -ForegroundColor Cyan
git push origin main
git push origin $tagName

Write-Host "`n✅ SafeShip sequence complete!" -ForegroundColor Green
Write-Host "   - GitHub Actions will pick up the changes."
Write-Host "   - To rollback, run: .\scripts\rollback.ps1"
Write-Host "   - Monitor: https://github.com/capt-shlee/myyacht/actions"
