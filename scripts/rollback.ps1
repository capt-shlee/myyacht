<#
.SYNOPSIS
    MyYacht Emergency Rollback Script
.DESCRIPTION
    Lists recent deployment backup tags and force-resets 'main' to a selected tag.
    Use this ONLY in emergencies.
#>

$ErrorActionPreference = "Stop"

Write-Host "🚨 EMERGENCY ROLLBACK SEQUENCE INITIATED 🚨" -ForegroundColor Red -BackgroundColor Yellow

# 1. Fetch latest state
Write-Host "⚓ Scanning designed rollback points..."
git fetch --tags

# 2. Find Backup Tags
$tags = git tag -l "backup-pre-deploy-*" | Sort-Object -Descending | Select-Object -First 10

if (-not $tags) {
    Write-Error "No safety anchors (backup tags) found! Cannot automate rollback."
}

Write-Host "`nAvailable Anchors:" -ForegroundColor Cyan
$i = 0
foreach ($t in $tags) {
    Write-Host " [$i] $t"
    $i++
}

# 3. Select Tag
$selection = Read-Host "`nSelect anchor index to return to (0-9)"
try {
    $targetTag = $tags[[int]$selection]
} catch {
    Write-Error "Invalid selection."
}

if (-not $targetTag) {
    Write-Error "Invalid selection."
}

# 4. Confirmation
Write-Host "`n⚠️  WARNING: HARSH MANEUVER AHEAD ⚠️" -ForegroundColor Red
Write-Host "This will DESTROY all changes on 'main' after [$targetTag]."
Write-Host "The repository will be reset to that state and FORCE PUSHED."
$conf = Read-Host "Type 'ROLLBACK' to confirm execution"

if ($conf -ne 'ROLLBACK') {
    Write-Host "Maneuver cancelled."
    exit
}

# 5. Execute Rollback
Write-Host "`n⚓ RETURNING TO ANCHOR POINT [$targetTag]..." -ForegroundColor Yellow
git reset --hard $targetTag
git push origin main --force

Write-Host "`n✅ Rollback execution sent." -ForegroundColor Green
Write-Host "GitHub Actions will rebuild the site from the selected point shortly."
