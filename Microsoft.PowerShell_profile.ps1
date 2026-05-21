# Force eza to use ~/.config/eza instead of AppData
$env:EZA_CONFIG_DIR = "$HOME\.config\eza"

# Ensure no old color variables interfere
$env:LS_COLORS = $null
$env:EZA_COLORS = $null

# Disable Python venv prompt change (handled by Oh My Posh)
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1

# 1. PRE-CHECKS & CONFIGURATION
Set-StrictMode -Version Latest

# Define preferred editors in order
$Editors = @("nvim", "pvim", "vim", "vi", "code", "codium", "notepad++", "sublime_text", "notepad")

# Select the first available editor (optimized loop)
foreach ($e in $Editors) {
    if (Get-Command $e -ErrorAction SilentlyContinue) {
        $Global:Editor = $e
        break
    }
}

# 2. HELPER FUNCTIONS

function Import-SafeModule {
    param([string]$ModuleName)
    if (-not (Get-Module -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Import-Module $ModuleName -ErrorAction SilentlyContinue
    }
}

function Run-IfAvailable {
    param(
        [string]$ToolName,
        [scriptblock]$Command,
        [scriptblock]$Fallback
    )
    if (Get-Command $ToolName -ErrorAction SilentlyContinue) {
        & $Command
    }
    elseif ($Fallback) {
        & $Fallback
    }
}

# Caches initialization scripts to speed up startup
function Invoke-CachedInit {
    param(
        [string]$Name,
        [string]$InitCommand
    )
    $CacheDir = Join-Path $HOME ".cache\powershell"
    if (-not (Test-Path $CacheDir)) { New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null }
    $CacheFile = Join-Path $CacheDir "$Name.ps1"
    
    if (-not (Test-Path $CacheFile)) {
        $init = Invoke-Expression $InitCommand
        $init | Out-File $CacheFile
    }
    . $CacheFile
}

# 3. INITIALIZATION
Import-SafeModule "Terminal-Icons"

# Dynamic Shell Detection
$ShellType = if ($PSVersionTable.PSVersion.Major -ge 6) { "pwsh" } else { "powershell" }

# Initialize Oh My Posh (no custom cache — oh-my-posh caches its own init script, and session IDs must be unique per session)
Run-IfAvailable -ToolName "oh-my-posh" -Command {
    oh-my-posh init $ShellType --config "$HOME\.poshthemes\hotanphat2.omp.json" | Invoke-Expression
}

# Initialize Zoxide
Run-IfAvailable -ToolName "zoxide" -Command {
    Invoke-CachedInit "zoxide" "zoxide init --cmd z powershell"
}

# 4. PSREADLINE CONFIGURATION
Import-SafeModule "PSReadLine"
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates

$BrandColors = @{
    "Operator"  = "#FFC90E"
    "Command"   = "#FFDB4D"
    "String"    = "#FFF2CC"
    "Variable"  = "#D6A600"
    "Parameter" = "#D1C08A"
    "Comment"   = "#75632D"
}
Set-PSReadLineOption -Colors $BrandColors

# 5. CORE FUNCTIONS
function Edit-Profile { & $Global:Editor $PROFILE }

function Reload-Profile {
    . $PROFILE
    Write-Host '[V] Profile Reloaded' -ForegroundColor Cyan
}

# Linux 'sudo' behavior using Windows Terminal Elevation (with fallback)
function sudo {
    $Shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        if (-not $args) {
            Start-Process wt -Verb RunAs
            return
        }
        $CmdString = $args -join ' '
        $ArgString = "new-tab -p $Shell -- $Shell -NoExit -Command `"$CmdString`""
        Start-Process wt -Verb RunAs -ArgumentList $ArgString
    } else {
        Start-Process $Shell -Verb RunAs -ArgumentList '-NoExit', '-Command', ($args -join ' ')
    }
}

function grep { $Input | Select-String -Pattern $args[0] }

function touch {
    foreach ($file in $args) {
        if (-not (Test-Path $file)) {
            New-Item -ItemType File -Path $file | Out-Null
        } else {
            (Get-Item $file).LastWriteTime = Get-Date
        }
    }
}

function df { Get-Volume }

# 6. ALIASES & SHORTCUTS
function .. { Set-Location .. }
function ... { Set-Location ../.. }

function ll {
    $passArgs = $args
    Run-IfAvailable -ToolName 'eza' -Command { eza -lah --icons --git @passArgs } -Fallback { Get-ChildItem -Force @passArgs | Format-Table -AutoSize }
}

# Git Workflow
function gstatus { git status }
function gadd { git add . }
function gcommit { git commit -m "$($args -join ' ')" }
function gpush { git push }
function gpull { git pull }
function gfetch { git fetch }
function gbranch { git branch }
function gdelete { git branch -d $args }
function gcheckout { git checkout $args }
function gswitch { git switch $args }
function gmerge { git merge $args }

function lazyg {
    git add .
    git commit -m "$($args -join ' ')"
    git push
}

function gnew { 
    if ($args.Count -gt 1) { git checkout -b $args[0] $args[1] } else { git checkout -b $args[0] }
}

# WSL Utilities
function wsll { wsl --list --verbose }
function wsllo { wsl --list --online }

# System
Set-Alias -Name 'sysinfo' -Value 'Get-ComputerInfo'
Set-Alias -Name 'which' -Value 'Get-Command'
Set-Alias -Name 'open' -Value 'Invoke-Item'

# 7. HELP FUNCTION
function Show-Help {
    Clear-Host
    Write-Host '::::::::::::::::::::::::::::::::::' -ForegroundColor DarkGray
    Write-Host '::::      Terminal Help       ::::' -ForegroundColor Yellow
    Write-Host '::::::::::::::::::::::::::::::::::' -ForegroundColor DarkGray
    Write-Host ''

    $F = '  {0,-16} {1}'
    
    Write-Host ' [ SYSTEM & NAV ]' -ForegroundColor Yellow
    Write-Host ($F -f '.., ...', 'Navigate up 1 or 2 levels')
    Write-Host ($F -f 'sudo [cmd]', 'Run as Admin (New Tab)')
    Write-Host ($F -f 'Edit-Profile', 'Edit this profile')
    Write-Host ($F -f 'Reload-Profile', 'Apply profile changes')
    Write-Host ($F -f 'sysinfo', 'Get-ComputerInfo')
    Write-Host ($F -f 'which [cmd]', 'Get-Command path')
    Write-Host ($F -f 'open [file]', 'Invoke-Item (Open file/folder)')
    Write-Host ''

    Write-Host ' [ LINUX STYLE ]' -ForegroundColor Yellow
    Write-Host ($F -f 'll', 'List files (eza with icons/git)')
    Write-Host ($F -f 'z [path]', 'Smart Jump (Zoxide)')
    Write-Host ($F -f 'grep [pat]', 'Select-String')
    Write-Host ($F -f 'touch [file]', 'Create or update file')
    Write-Host ($F -f 'df', 'Show disk volume info')
    Write-Host ''

    Write-Host ' [ GIT WORKFLOW ]' -ForegroundColor Yellow
    Write-Host ($F -f 'gstatus / gadd', 'git status / git add .')
    Write-Host ($F -f 'gcommit [msg]', 'git commit -m "..."')
    Write-Host ($F -f 'lazyg [msg]', 'add + commit + push')
    Write-Host ($F -f 'gpush / gpull', 'git push / git pull')
    Write-Host ($F -f 'gnew [name]', 'Create & switch to branch')
    Write-Host ''

    Write-Host ' [ WSL ]' -ForegroundColor Yellow
    Write-Host ($F -f 'wsll', 'wsl --list --verbose')
    Write-Host ($F -f 'wsllo', 'wsl --list --online')
    Write-Host ''
    
    Write-Host ' Type "Show-Help" to see this menu again.' -ForegroundColor DarkGray
}

# 8. WELCOME
Clear-Host
if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch }
