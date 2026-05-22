# Adds ~/.claude to the user PATH so the glm.bat CLI can be invoked from anywhere.
# Safe to re-run; only modifies PATH if the directory is not already in it.

$claudePath = "$env:USERPROFILE\.claude"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')

if ($currentPath -notlike "*$claudePath*") {
    $newPath = if ($currentPath) { "$currentPath;$claudePath" } else { $claudePath }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "[OK] Added to user PATH: $claudePath" -ForegroundColor Green
    Write-Host "Open a new terminal / restart VS Code for the change to take effect."
} else {
    Write-Host "[INFO] Already in PATH: $claudePath" -ForegroundColor Yellow
}
