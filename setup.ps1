<#
.SYNOPSIS
    Sets up dotfiles configuration for Windows PowerShell environment.

.DESCRIPTION
    This script configures the PowerShell environment for dotfiles management:
    1. Adds a 'dotfiles' function to the PowerShell profile
    2. Installs essential development tools using available package managers
    3. Configures optional components like Oh My Posh theme
    
    The dotfiles function provides a shortcut to manage dotfiles using Git
    with a bare repository approach.

.NOTES
    Author: kjanat
    Last Updated: May 13, 2025
    
    Part of the cross-platform dotfiles management solution.
    See README.md for more details.

.EXAMPLE
    ./setup.ps1
    
    Runs the setup process with default settings.

.LINK
    https://github.com/kjanat/dotfiles
#>

# Show colorful header 
$headerColor = 'Cyan'
Write-Host "`n==== Dotfiles Setup for PowerShell ====" -ForegroundColor $headerColor
Write-Host "Setting up dotfiles alias and installing essential tools...`n" -ForegroundColor $headerColor

# Setup PowerShell profile with dotfiles alias
$profilePath = $PROFILE.CurrentUserCurrentHost
$aliasLine = "function dotfiles { git --git-dir=`"$HOME\.dotfiles`" --work-tree=`"$HOME`" @args }"
$commentLine = "# Dotfiles management function - manages dotfiles stored in $HOME\.dotfiles"

# Create profile if it doesn't exist
if (-not (Test-Path $profilePath)) {
	Write-Host "Creating PowerShell profile at: $profilePath" -ForegroundColor 'Yellow'
	New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Add alias if it doesn't exist
if (-not (Select-String -Path $profilePath -Pattern 'dotfiles { git') ) {
	Add-Content -Path $profilePath -Value "`n$commentLine`n$aliasLine"
	Write-Host "✓ Alias 'dotfiles' added to PowerShell profile" -ForegroundColor 'Green'
} else {
	Write-Host "✓ Alias 'dotfiles' already exists in profile" -ForegroundColor 'Green'
}

# Install essential tools using available package managers
Write-Host "`nInstalling essential development tools..." -ForegroundColor $headerColor

if (Get-Command winget -ErrorAction SilentlyContinue) {
	# Use winget if available (newer Windows systems)
	Write-Host 'Using winget package manager' -ForegroundColor 'Yellow'
    
	# Essential tools
	Write-Host 'Installing Git...' -NoNewline
	winget install --id Git.Git -e --source winget | Out-Null
	Write-Host ' ✓' -ForegroundColor 'Green'
    
	Write-Host 'Installing Vim...' -NoNewline
	winget install --id GNU.Vim -e --source winget | Out-Null
	Write-Host ' ✓' -ForegroundColor 'Green'
    
	Write-Host 'Installing PowerShell 7...' -NoNewline
	winget install --id Microsoft.PowerShell -e --source winget | Out-Null
	Write-Host ' ✓' -ForegroundColor 'Green'
    
	# Optional: Install additional useful tools
	if ($PSVersionTable.PSVersion.Major -ge 7) {
		# Only install Oh My Posh on PowerShell 7+
		Write-Host 'Installing Oh My Posh...' -NoNewline
		winget install JanDeDobbeleer.OhMyPosh -e --source winget | Out-Null
		Write-Host ' ✓' -ForegroundColor 'Green'
	}
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
	# Fall back to Chocolatey if available
	Write-Host 'Using Chocolatey package manager' -ForegroundColor 'Yellow'
	choco install git vim -y
    
	# Install PowerShell Core if not already running it
	if ($PSVersionTable.PSVersion.Major -lt 7) {
		choco install pwsh -y
	}
} else {
	Write-Host 'No package manager found. Please install Git and Vim manually.' -ForegroundColor 'Red'
	Write-Host 'Download Git: https://git-scm.com/download/win' -ForegroundColor 'Yellow'
	Write-Host 'Download Vim: https://www.vim.org/download.php' -ForegroundColor 'Yellow'
}

# Configure Oh My Posh if installed
$ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
$themeFile = "$HOME\.themes\kjanat.omp.json"

if ($ohMyPoshCmd -and (Test-Path $themeFile)) {
	Write-Host "`nConfiguring Oh My Posh..." -ForegroundColor $headerColor
    
	# Add Oh My Posh initialization to profile if not already present
	if (-not (Select-String -Path $profilePath -Pattern 'oh-my-posh')) {
		$ompInit = @"

# Initialize Oh My Posh with custom theme
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$themeFile" | Invoke-Expression
}
"@
		Add-Content -Path $profilePath -Value $ompInit
		Write-Host '✓ Oh My Posh configured with custom theme' -ForegroundColor 'Green'
	} else {
		Write-Host '✓ Oh My Posh already configured in profile' -ForegroundColor 'Green'
	}
}

# Install PowerShell utility module for enhanced dotfiles management
$moduleSource = Join-Path $PSScriptRoot 'DotfilesUtility.psm1'
$modulesDir = "$HOME\Documents\PowerShell\Modules\DotfilesUtility"

if (Test-Path $moduleSource) {
	Write-Host "`nInstalling Dotfiles PowerShell module..." -ForegroundColor $headerColor
    
	if (-not (Test-Path $modulesDir)) {
		New-Item -ItemType Directory -Path $modulesDir -Force | Out-Null
	}
    
	Copy-Item -Path $moduleSource -Destination "$modulesDir\DotfilesUtility.psm1" -Force
    
	# Add module import to profile if not already present
	if (-not (Select-String -Path $profilePath -Pattern 'Import-Module DotfilesUtility')) {
		$moduleImport = @'

# Import dotfiles utility module
if (Get-Module -ListAvailable -Name DotfilesUtility) {
    Import-Module DotfilesUtility
}
'@
		Add-Content -Path $profilePath -Value $moduleImport
		Write-Host '✓ DotfilesUtility module installed and configured' -ForegroundColor 'Green'
	} else {
		Write-Host '✓ DotfilesUtility module already configured' -ForegroundColor 'Green'
	}
}

# Final instructions 
Write-Host "`n==== Setup Complete ====" -ForegroundColor $headerColor
Write-Host "To activate changes in current session, run: . $profilePath" -ForegroundColor 'Yellow'
Write-Host "Or restart PowerShell for changes to take effect automatically.`n" -ForegroundColor 'Yellow'

# Help info about dotfiles commands
Write-Host 'You can now use the following commands to manage your dotfiles:' -ForegroundColor $headerColor
Write-Host '  Basic Git commands:' -ForegroundColor 'White'
Write-Host '    dotfiles status       - Show status of dotfiles' -ForegroundColor 'White'
Write-Host '    dotfiles add <file>   - Track a new dotfile' -ForegroundColor 'White'
Write-Host "    dotfiles commit -m 'message' - Commit changes" -ForegroundColor 'White'
Write-Host '    dotfiles push         - Push changes to remote repo' -ForegroundColor 'White'
Write-Host ''
Write-Host '  Enhanced commands (after restart):' -ForegroundColor 'White'
Write-Host '    Sync-Dotfiles         - Pull changes and handle conflicts' -ForegroundColor 'White'
Write-Host '    Add-DotFile -Path <path> - Add and commit a new dotfile' -ForegroundColor 'White'
Write-Host "    Get-DotFilesStatus    - Show enhanced status with suggestions`n" -ForegroundColor 'White'
