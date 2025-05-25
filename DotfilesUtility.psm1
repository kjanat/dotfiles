<#
.SYNOPSIS
    PowerShell module for enhanced dotfiles management
.DESCRIPTION
    Provides additional commands for managing dotfiles beyond 
    the basic Git commands provided by the dotfiles alias.
.NOTES
    Author: kjanat
    Version: 1.0
#>

# Ensure the dotfiles command is available
if (-not (Get-Command dotfiles -ErrorAction SilentlyContinue)) {
	function dotfiles { git --git-dir="$HOME\.dotfiles" --work-tree="$HOME" @args }
}

function Sync-Dotfiles {
	<#
    .SYNOPSIS
        Synchronizes dotfiles across machines
    .DESCRIPTION
        Pulls latest changes from remote, handles conflicts, and reports status
    .EXAMPLE
        Sync-Dotfiles
    #>
	Write-Host 'Syncing dotfiles from remote repository...' -ForegroundColor Cyan
    
	# Stash any local changes
	dotfiles stash
    
	# Pull latest changes
	$pullResult = dotfiles pull 2>&1
    
	# Check for conflicts
	if ($LASTEXITCODE -ne 0) {
		Write-Host 'Conflicts detected. Backing up local changes...' -ForegroundColor Yellow
        
		# Create backup directory if it doesn't exist
		$backupDir = "$HOME\.dotfiles-backup\$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
		New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        
		# Extract conflict file paths and back them up
		$conflictFiles = $pullResult | Where-Object { $_ -match 'CONFLICT \(.*\): .*' } | 
			ForEach-Object { $_ -replace 'CONFLICT \(.*\): .* in (.*)', '$1' }
        
		foreach ($file in $conflictFiles) {
			$relativePath = $file.Replace("$HOME\", '')
			$destination = Join-Path $backupDir $relativePath
            
			# Create directory structure
			$parentDir = Split-Path $destination -Parent
			if (-not (Test-Path $parentDir)) {
				New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
			}
            
			# Copy the file
			Copy-Item -Path $file -Destination $destination -Force
		}
        
		# Reset conflicts
		dotfiles reset --hard
		dotfiles pull
        
		Write-Host "Conflicts resolved. Local versions backed up to: $backupDir" -ForegroundColor Green
	} else {
		Write-Host 'Dotfiles synced successfully!' -ForegroundColor Green
	}
    
	# Apply any stashed changes
	$stashResult = dotfiles stash pop 2>&1
	if ($LASTEXITCODE -ne 0 -and $stashResult -notmatch 'No stash entries found') {
		Write-Host "Warning: Couldn't apply local changes automatically." -ForegroundColor Yellow
		Write-Host "Your changes are saved in the stash. Use 'dotfiles stash list' and 'dotfiles stash apply' to recover." -ForegroundColor Yellow
	}
    
	# Show status
	dotfiles status
}

function Add-DotFile {
	<#
    .SYNOPSIS
        Adds a new file to dotfiles tracking
    .DESCRIPTION
        Adds a file to dotfiles tracking and commits it with a meaningful message
    .PARAMETER Path
        Path to the file to add
    .PARAMETER Message
        Optional commit message
    .EXAMPLE
        Add-DotFile -Path "~/.gitconfig" -Message "Add Git configuration"
    #>
	param(
		[Parameter(Mandatory = $true)]
		[string]$Path,
        
		[Parameter(Mandatory = $false)]
		[string]$Message
	)
    
	# Convert ~ to $HOME
	if ($Path.StartsWith('~')) {
		$Path = $Path.Replace('~', $HOME)
	}
    
	# Check if file exists
	if (-not (Test-Path $Path)) {
		Write-Host "Error: File not found at $Path" -ForegroundColor Red
		return
	}
    
	# Get relative path
	$relativePath = $Path.Replace("$HOME\", '').Replace("$HOME/", '')
    
	# Generate commit message if not provided
	if (-not $Message) {
		$fileName = Split-Path $Path -Leaf
		$Message = "Add $fileName to dotfiles"
	}
    
	# Add and commit the file
	Write-Host "Adding $relativePath to dotfiles..." -ForegroundColor Cyan
	dotfiles add $Path
	dotfiles commit -m $Message
    
	Write-Host "File added successfully! Use 'dotfiles push' to upload to remote repository." -ForegroundColor Green
}

function Get-DotFilesStatus {
	<#
    .SYNOPSIS
        Shows enhanced status of dotfiles
    .DESCRIPTION
        Shows status of dotfiles including untracked configuration files
    .EXAMPLE
        Get-DotFilesStatus
    #>
    
	# Show tracked files status
	Write-Host '=== TRACKED DOTFILES STATUS ===' -ForegroundColor Cyan
	dotfiles status --short
    
	# Suggest common config files that aren't tracked
	Write-Host "`n=== SUGGESTED FILES TO TRACK ===" -ForegroundColor Yellow
    
	$commonDotfiles = @(
		'~\.gitconfig',
		'~\.vimrc',
		'~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1',
		'~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1',
		'~\.config\powershell\Microsoft.PowerShell_profile.ps1'
	)
    
	$suggestions = @()
    
	foreach ($file in $commonDotfiles) {
		$expandedPath = $file.Replace('~', $HOME)
		if (Test-Path $expandedPath) {
			$relativePath = $expandedPath.Replace("$HOME\", '')
            
			# Check if already tracked
			$isTracked = dotfiles ls-files --error-unmatch $relativePath 2>$null
			if ($LASTEXITCODE -ne 0) {
				$suggestions += $relativePath
			}
		}
	}
    
	if ($suggestions.Count -gt 0) {
		foreach ($suggestion in $suggestions) {
			Write-Host "  $suggestion" -ForegroundColor Gray
		}
		Write-Host "`nTo add these files, use: Add-DotFile -Path PATH" -ForegroundColor Yellow
	} else {
		Write-Host '  All common configuration files are already tracked!' -ForegroundColor Green
	}
}

# Export functions
Export-ModuleMember -Function Sync-Dotfiles, Add-DotFile, Get-DotFilesStatus
