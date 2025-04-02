$repo = "git@github.com:kjanat/dotfiles.git"
$dotfilesDir = "$HOME\.dotfiles"
$backupDir = "$HOME\.dotfiles-backup"

if (-not (Test-Path $dotfilesDir)) {
    git clone --bare $repo $dotfilesDir
}

function Dotfiles {
    git --git-dir=$dotfilesDir --work-tree=$HOME @args
}

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$conflicts = Dotfiles checkout 2>&1
if ($LASTEXITCODE -ne 0) {
    $conflicts | Where-Object { $_ -match '^\s+(.+)$' } | ForEach-Object {
        $file = $Matches[1].Trim()
        $source = Join-Path $HOME $file
        $destination = Join-Path $backupDir $file
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        Move-Item -Path $source -Destination $destination -Force
    }
    Dotfiles checkout
}

Dotfiles config --local status.showUntrackedFiles no
Write-Host "Dotfiles successfully installed."
