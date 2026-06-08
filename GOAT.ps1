#Requires -Version 5.1
<#
    GOAT - GREATEST OF ALL TWEAKS
    Terminal Edition v2.0 - Red/Black Theme
#>

# ── ADMIN CHECK ────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "`n  [!] ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor Red
    Write-Host "  Restart PowerShell as Administrator.`n" -ForegroundColor DarkGray
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "GOAT // GREATEST OF ALL TWEAKS"
$Host.UI.RawUI.BackgroundColor = 'Black'
$Host.UI.RawUI.ForegroundColor = 'Red'
Clear-Host

try {
    $w = $Host.UI.RawUI.WindowSize; $w.Width = 100
    $b = $Host.UI.RawUI.BufferSize; $b.Width = 100
    $Host.UI.RawUI.BufferSize = $b
    $Host.UI.RawUI.WindowSize = $w
} catch {}

# ── CHARS ──────────────────────────────────────────────────────────────────
$h  = [string][char]9552  # ═
$tl = [string][char]9556  # ╔
$tr = [string][char]9559  # ╗
$bl = [string][char]9562  # ╚
$br = [string][char]9565  # ╝
$vl = [string][char]9553  # ║
$ml = [string][char]9568  # ╠
$mr = [string][char]9571  # ╣
$fi = [string][char]9608  # █
$em = [string][char]9617  # ░
$xt = [string][char]9574  # ╦
$xb = [string][char]9577  # ╩

# ── HELPERS ────────────────────────────────────────────────────────────────
$W    = 96
$edge = $h * $W

function W ($text, $color = 'Red', [switch]$NoNewline) {
    if ($NoNewline) { Write-Host $text -ForegroundColor $color -NoNewline }
    else            { Write-Host $text -ForegroundColor $color }
}

function Center ($text, $width = 98) {
    $pad = [math]::Max(0, [math]::Floor(($width - $text.Length) / 2))
    return (' ' * $pad) + $text
}

function Bar ($pct, $width = 28, $fillColor = 'Red', $emptyColor = 'DarkGray') {
    $f = [math]::Round($pct / 100 * $width)
    $e = $width - $f
    Write-Host ($fi * $f) -ForegroundColor $fillColor  -NoNewline
    Write-Host ($em * $e) -ForegroundColor $emptyColor -NoNewline
}

function SysRow ($label, $detail, $pct, $fillColor) {
    $pctSafe = if ($null -ne $pct) { [int]$pct } else { 0 }
    W "  $vl" DarkRed -NoNewline
    Write-Host "  " -NoNewline
    Write-Host $label.PadRight(6) -NoNewline -ForegroundColor DarkRed
    Write-Host "$([char]9474) " -NoNewline -ForegroundColor DarkGray
    Write-Host $detail.PadRight(36) -NoNewline -ForegroundColor Gray
    Write-Host " [" -NoNewline -ForegroundColor DarkGray
    Bar $pctSafe 28 $fillColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($pctSafe.ToString().PadLeft(3))%" -NoNewline -ForegroundColor $fillColor
    Write-Host (' ' * 2) -NoNewline
    W $vl DarkRed
}

# ── SYSTEM INFO ────────────────────────────────────────────────────────────
$CPU      = (Get-CimInstance Win32_Processor).Name
$CPULoad  = (Get-CimInstance Win32_Processor).LoadPercentage
if ($null -eq $CPULoad) { $CPULoad = 0 }
$CPULoad  = [int]$CPULoad
$RAMTotal = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$RAMFree  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$RAMUsed  = [math]::Round($RAMTotal - $RAMFree, 1)
$RAMPct   = [math]::Round(($RAMUsed / $RAMTotal) * 100)
$OSName   = (Get-CimInstance Win32_OperatingSystem).Caption

# ── TASK TRACKING ──────────────────────────────────────────────────────────
$script:TaskList  = @()
$script:TaskIdx   = 0
$script:TotalTask = 14

function Draw-TaskBox {
    $boxW   = 62
    $innerW = $boxW - 4
    Write-Host ""
    Write-Host "  " -NoNewline; W "$tl$($h * $boxW)$tr" DarkRed
    Write-Host "  " -NoNewline; W $vl DarkRed -NoNewline
    Write-Host " RUNNING OPTIMIZATIONS".PadRight($boxW) -NoNewline -ForegroundColor Red
