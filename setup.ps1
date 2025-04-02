Write-Host "Setting up dotfiles alias and basic tools..."

$profilePath = $PROFILE.CurrentUserCurrentHost
$aliasLine = "function dotfiles { git --git-dir=`"$HOME\.dotfiles`" --work-tree=`"$HOME`" @args }"

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

if (-not (Select-String -Path $profilePath -Pattern "dotfiles { git") ) {
    Add-Content -Path $profilePath -Value "`n$aliasLine"
    Write-Host "Alias 'dotfiles' added to PowerShell profile: $profilePath"
} else {
    Write-Host "Alias already exists in profile."
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id Git.Git -e --source winget
    winget install --id GNU.Vim -e --source winget
    winget install --id Microsoft.PowerShell -e --source winget
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    choco install git vim -y
} else {
    Write-Host "No package manager found. Install Git/Vim manually."
}

Write-Host "Setup complete. Restart PowerShell or run `. $profilePath` to activate the alias."
