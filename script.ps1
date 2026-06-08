<#
    GOAT - GREATEST OF ALL TWEAKS (FULL INTEGRATED)
    Banner: Cyber Edition v2.0 â€” Red/Black Theme
#>

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 1 ] ADMIN PRIVILEGE CHECK
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 2 ] BANNER HELPERS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
    Write-Host ('â–ˆ' * $f) -ForegroundColor $fillColor  -NoNewline
    Write-Host ('â–‘' * $e) -ForegroundColor $emptyColor -NoNewline
}

function SysRow ($label, $detail, $pct, $fillColor) {
    $pctSafe = if ($null -ne $pct) { [int]$pct } else { 0 }
    W "  â•‘" DarkRed -NoNewline
    Write-Host "  " -NoNewline
    Write-Host $label.PadRight(6) -NoNewline -ForegroundColor DarkRed
    Write-Host "â”‚ " -NoNewline -ForegroundColor DarkGray
    Write-Host $detail.PadRight(36) -NoNewline -ForegroundColor Gray
    Write-Host " [" -NoNewline -ForegroundColor DarkGray
    Bar $pctSafe 28 $fillColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($pctSafe.ToString().PadLeft(3))%" -NoNewline -ForegroundColor $fillColor
    Write-Host (' ' * 2) -NoNewline
    W "â•‘" DarkRed
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 3 ] TUI PROGRESS HELPERS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$script:TaskList  = @()
$script:TaskDone  = @()
$script:TotalTask = 14
$script:TaskIdx   = 0
$W    = 96
$edge = 'â•' * $W

function Draw-TaskBox {
    param([string]$CurrentName = '', [bool]$Done = $false)

    $boxW = 60
    $innerW = $boxW - 4

    Write-Host ""
    Write-Host "  " -NoNewline; W "â•”$('â•' * $boxW)â•—" DarkRed
    Write-Host "  " -NoNewline; W "â•‘" DarkRed -NoNewline
    $title = " RUNNING OPTIMIZATIONS"
    Write-Host $title.PadRight($boxW) -NoNewline -ForegroundColor Red
    W "â•‘" DarkRed
    Write-Host "  " -NoNewline; W "â• $('â•' * $boxW)â•£" DarkRed

    foreach ($i in 0..($script:TaskList.Count - 1)) {
        $name = $script:TaskList[$i]
        Write-Host "  " -NoNewline; W "â•‘" DarkRed -NoNewline
        Write-Host "  " -NoNewline
        if ($i -lt $script:TaskIdx) {
            Write-Host "âœ” " -NoNewline -ForegroundColor Green
            Write-Host $name.PadRight($innerW - 6) -NoNewline -ForegroundColor DarkGray
            Write-Host "DONE" -NoNewline -ForegroundColor DarkGreen
        } elseif ($i -eq $script:TaskIdx -and -not $Done) {
            Write-Host "â–º " -NoNewline -ForegroundColor Red
            Write-Host $name.PadRight($innerW - 10) -NoNewline -ForegroundColor White
            Write-Host "RUNNING..." -NoNewline -ForegroundColor Yellow
        } else {
            Write-Host "  " -NoNewline -ForegroundColor DarkGray
            Write-Host $name.PadRight($innerW - 4) -NoNewline -ForegroundColor DarkGray
            Write-Host "    " -NoNewline
        }
        W "â•‘" DarkRed
    }

    Write-Host "  " -NoNewline; W "â• $('â•' * $boxW)â•£" DarkRed

    $pct     = [math]::Round($script:TaskIdx / $script:TotalTask * 100)
    $barW    = $boxW - 18
    $filled  = [math]::Round($pct / 100 * $barW)
    $empty   = $barW - $filled

    Write-Host "  " -NoNewline; W "â•‘" DarkRed -NoNewline
    Write-Host "  OVERALL [" -NoNewline -ForegroundColor DarkGray
    Write-Host ('â–ˆ' * $filled) -NoNewline -ForegroundColor Red
    Write-Host ('â–‘' * $empty)  -NoNewline -ForegroundColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($pct.ToString().PadLeft(3))%" -NoNewline -ForegroundColor Red
    Write-Host "  " -NoNewline
    W "â•‘" DarkRed

    Write-Host "  " -NoNewline; W "â•š$('â•' * $boxW)â•" DarkRed
    Write-Host ""

    Write-Progress -Activity "GOAT Optimization" -Status "$($script:TaskIdx)/$($script:TotalTask) modules" -PercentComplete $pct
}

function Start-Task ([string]$Name) {
    $script:TaskList += $Name
    Clear-Host
    Draw-Banner
    Draw-TaskBox
}

function Finish-Task {
    $script:TaskIdx++
    Clear-Host
    Draw-Banner
    Draw-TaskBox
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 4 ] SYSTEM INFO
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$CPU      = (Get-CimInstance Win32_Processor).Name
$CPULoad  = (Get-CimInstance Win32_Processor).LoadPercentage
if ($null -eq $CPULoad) { $CPULoad = 0 }
$CPULoad  = [int]$CPULoad

$RAMTotal = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$RAMFree  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$RAMUsed  = [math]::Round($RAMTotal - $RAMFree, 1)
$RAMPct   = [math]::Round(($RAMUsed / $RAMTotal) * 100)
$OSName   = (Get-CimInstance Win32_OperatingSystem).Caption

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 5 ] BANNER DRAW FUNCTION (à¹€à¸£à¸µà¸¢à¸à¸‹à¹‰à¸³à¹„à¸”à¹‰)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
function Draw-Banner {
    W ""
    W "  â•”$edgeâ•—" DarkRed
    W "  â•‘" DarkRed -NoNewline; W ('â–“' * $W) Red -NoNewline; W "â•‘" DarkRed
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed

    $logo = @(
        '    â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—    ',
        '   â–ˆâ–ˆâ•”â•â•â•â•â• â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â•šâ•â•â–ˆâ–ˆâ•”â•â•â•    ',
        '   â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘        ',
        '   â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘        ',
        '   â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘        ',
        '    â•šâ•â•â•â•â•â•  â•šâ•â•â•â•â•â• â•šâ•â•  â•šâ•â•   â•šâ•â•        '
    )
    $logoColors = @('Red','Red','DarkRed','DarkRed','Red','DarkRed')
    foreach ($i in 0..($logo.Count - 1)) {
        W "  â•‘" DarkRed -NoNewline
        Write-Host (Center $logo[$i] $W).PadRight($W) -NoNewline -ForegroundColor $logoColors[$i]
        W "â•‘" DarkRed
    }

    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed
    W "  â•‘" DarkRed -NoNewline
    Write-Host (Center "Â·  G R E A T E S T   O F   A L L   T W E A K S  Â·" $W).PadRight($W) -NoNewline -ForegroundColor DarkYellow
    W "â•‘" DarkRed
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed

    W "  â• $edgeâ•£" DarkRed
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed
    SysRow "CPU" ($CPU.Substring(0, [math]::Min(36, $CPU.Length))) $CPULoad 'Red'
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed
    SysRow "RAM" "$RAMUsed GB / $RAMTotal GB DDR" $RAMPct 'DarkYellow'
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed
    SysRow "OS " ($OSName.Substring(0, [math]::Min(36, $OSName.Length))) 100 'DarkRed'
    W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed

    W "  â• $edgeâ•£" DarkRed
    W "  â•‘" DarkRed -NoNewline
    $mods = @('KERNEL','MEMORY','INPUT','NETWORK','IRQ/MSI','POWER','SERVICES','CLEANER')
    Write-Host "  " -NoNewline
    foreach ($m in $mods) {
        Write-Host "[ " -NoNewline -ForegroundColor DarkGray
        Write-Host $m   -NoNewline -ForegroundColor Red
        Write-Host " ] " -NoNewline -ForegroundColor DarkGray
    }
    $modLen = 2 + ($mods | ForEach-Object { "[ $_ ] ".Length } | Measure-Object -Sum).Sum
    Write-Host (' ' * [math]::Max(0, $W - $modLen)) -NoNewline
    W "â•‘" DarkRed
    W "  â• $edgeâ•£" DarkRed
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 6 ] DRAW INITIAL BANNER + LOADING BAR
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Draw-Banner

W "  â•‘" DarkRed -NoNewline
Write-Host "  INITIALIZING  [" -NoNewline -ForegroundColor DarkYellow
$total  = 50
$colors = @('DarkRed','DarkRed','Red','Red','Yellow','Red','Red','DarkRed','DarkRed')
for ($b = 0; $b -lt $total; $b++) {
    $ci = [math]::Min($b * ($colors.Count - 1) / ($total - 1), $colors.Count - 1)
    Write-Host 'â–ˆ' -NoNewline -ForegroundColor $colors[[math]::Floor($ci)]
    Start-Sleep -Milliseconds 22
}
Write-Host "]" -NoNewline -ForegroundColor DarkYellow
Write-Host " 100% " -NoNewline -ForegroundColor Red
$afterLoad = $W - 2 - "  INITIALIZING  [".Length - $total - "] 100% ".Length
Write-Host (' ' * [math]::Max(0, $afterLoad)) -NoNewline
W "â•‘" DarkRed

W "  â•‘" DarkRed -NoNewline
Write-Host "  " -NoNewline
Write-Host "âœ” " -NoNewline -ForegroundColor Red
Write-Host "ALL MODULES READY" -NoNewline -ForegroundColor Red
Write-Host (' ' * ($W - 22)) -NoNewline
W "â•‘" DarkRed
W "  â•‘" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W "â•‘" DarkRed

W "  â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•¦$(('â•' * 46))â•£" DarkRed
W "  â•‘" DarkRed -NoNewline
Write-Host "   â–º  READY TO RUN GOAT?                         " -NoNewline -ForegroundColor DarkYellow
W "â•‘" DarkRed -NoNewline
Write-Host "  â–¸ Press " -NoNewline -ForegroundColor DarkGray
Write-Host "Y" -NoNewline -ForegroundColor Red
Write-Host " to begin optimization           " -NoNewline -ForegroundColor DarkGray
W "â•‘" DarkRed

W "  â•‘" DarkRed -NoNewline
Write-Host "                                                  " -NoNewline
W "â•‘" DarkRed -NoNewline
Write-Host "  â–¸ Press " -NoNewline -ForegroundColor DarkGray
Write-Host "N" -NoNewline -ForegroundColor DarkGray
Write-Host " to exit                           " -NoNewline -ForegroundColor DarkGray
W "â•‘" DarkRed
W "  â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•©$(('â•' * 46))â•" DarkRed

W ""
$ts = Get-Date -Format "yyyy-MM-dd  HH:mm:ss"
Write-Host "  " -NoNewline
Write-Host "â— " -NoNewline -ForegroundColor Red
Write-Host "SYSTEM ONLINE" -NoNewline -ForegroundColor DarkRed
Write-Host "   v2.0.0   $ts" -ForegroundColor DarkGray
W ""

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 7 ] INPUT
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
do {
    Write-Host "  >> " -NoNewline -ForegroundColor DarkRed
    Write-Host "Your choice " -NoNewline -ForegroundColor Gray
    Write-Host "[Y/N]" -NoNewline -ForegroundColor DarkYellow
    Write-Host " : " -NoNewline -ForegroundColor Gray
    $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    Write-Host $choice -ForegroundColor Red
} while ($choice -notmatch '^[YyNn]$')

if ($choice -match '[Nn]') {
    W "`n  [âœ–] Aborted â€” Exiting GOAT.`n" DarkGray
    Exit
}

W "`n  [âœ”] GOAT is on the run â€” Starting optimization...`n" Red

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 8 ] WORKING DIRECTORY & POWER PLAN FILE
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 9 ] OPTIMIZATION FUNCTIONS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
function Optimize-Kernel {
    Start-Task "Kernel & HPET"
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    bcdedit /set synthetictimers yes 2>$null | Out-Null
    $hpet = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision*" } -ErrorAction SilentlyContinue
    if ($hpet) { Disable-PnpDevice -InstanceId $hpet.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
    Finish-Task
}

function Optimize-TimerResolution {
    Start-Task "Timer Resolution"
    $TimerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    Set-ItemProperty -Path $TimerPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
    Finish-Task
}

function Optimize-IRQ {
    Start-Task "IRQ / MSI Mode"
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $msiPath = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $msiPath) {
            Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null
        }
    }
    Finish-Task
}

function Optimize-Nagle {
    Start-Task "Nagle Algorithm"
    $InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $InterfacesPath -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
    Finish-Task
}

function Optimize-VisualEffects {
    Start-Task "Visual Effects"
    $VisualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $VisualPath)) { New-Item -Path $VisualPath -Force | Out-Null }
    Set-ItemProperty -Path $VisualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
    Finish-Task
}

function Disable-GameBar {
    Start-Task "Game Bar & DVR"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled"               -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"                      -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode"               -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode"      -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
    $GameBarPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $GameBarPath)) { New-Item -Path $GameBarPath -Force | Out-Null }
    Set-ItemProperty -Path $GameBarPath -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
    Finish-Task
}

function Optimize-ProcessorPower {
    Start-Task "Processor Power"
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
    Finish-Task
}

function Optimize-Priority {
    Start-Task "Process Priority"
    $PriorityPath      = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $SystemProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $GamesTaskPath     = "$SystemProfilePath\Tasks\Games"
    $ExecPath          = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"
    Set-ItemProperty -Path $PriorityPath -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PriorityPath -Name "ConvertibleSlateMode"    -Value 0    -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $SystemProfilePath -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $SystemProfilePath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    Set-ItemProperty -Path $ExecPath -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $ExecPath -Name "AdditionalDelayedWorkerThreads"  -Value 2 -Type DWord -Force 2>$null
    if (-not (Test-Path $GamesTaskPath)) { New-Item -Path $GamesTaskPath -Force | Out-Null }
    Set-ItemProperty -Path $GamesTaskPath -Name "Affinity"            -Value 0       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Background Only"     -Value "False" -Type String -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Clock Rate"          -Value 0x2710  -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "GPU Priority"        -Value 8       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Priority"            -Value 6       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Scheduling Category" -Value "High"  -Type String -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "SFIO Priority"       -Value "High"  -Type String -Force 2>$null
    Finish-Task
}

function Optimize-Memory {
    Start-Task "Memory Management"
    $MemoryPath   = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $PrefetchPath = "$MemoryPath\PrefetchParameters"
    Set-ItemProperty -Path $MemoryPath -Name "SystemCacheDirtyPageThreshold" -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageThreshold"          -Value 15 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcTotalDirtyPages"             -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageTarget"             -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher"  -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch"  -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath   -Name "LargeSystemCache"  -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath   -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null
    powercfg -h off 2>$null | Out-Null
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Finish-Task
}

function Optimize-Input {
    Start-Task "Input & USB"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $PowerThrottlePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $PowerThrottlePath)) { New-Item -Path $PowerThrottlePath -Force | Out-Null }
    Set-ItemProperty -Path $PowerThrottlePath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed"       -Value "0"    -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1"  -Value "0"    -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2"  -Value "0"    -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime"   -Value "0"    -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"    -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys"        -Name "Flags"                 -Value "506" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys"        -Name "Flags"                 -Value "58"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys"         -Name "Flags"                 -Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay"       -Value "125" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate"        -Value "11"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "BounceTime"            -Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "DelayBeforeAcceptance" -Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags"                 -Value "122" -Type String -Force 2>$null
    Finish-Task
}

function Install-CustardPowerPlan {
    Start-Task "Custard Power Plan"
    $Guid = "4e2cd77e-229e-484e-b077-c63e8b092ec8"
    if (Test-Path $PowPath) {
        powercfg /delete $Guid 2>$null
        powercfg /import $PowPath $Guid 2>$null | Out-Null
        powercfg /setactive $Guid 2>$null | Out-Null
    }
    Finish-Task
}

function Optimize-Network {
    Start-Task "Network & DNS"
    netsh int tcp set global rss=enabled            2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal  2>$null | Out-Null
    netsh int tcp set global timestamps=disabled     2>$null | Out-Null
    netsh int tcp set global chimney=disabled        2>$null | Out-Null
    netsh int tcp set global ecncapability=disabled  2>$null | Out-Null
    $TcpParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $TcpParams -Name "EnableTCPChimney"    -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnableRSS"           -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnableTCPA"          -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "Tcp1323Opts"         -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TCPNoDelay"          -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpAckFrequency"     -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpDelAckTicks"      -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "DefaultTTL"          -Value 64         -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnablePMTUDiscovery" -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpTimedWaitDelay"   -Value 30         -Type DWord -Force 2>$null
    $DnsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
    Set-ItemProperty -Path $DnsPath -Name "CacheHashTableBucketSize" -Value 1       -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "CacheHashTableSize"       -Value 0x180   -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "MaxCacheEntryTtlLimit"    -Value 0xfa00  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "MaxSOACacheEntryTtlLimit" -Value 0x12d   -Type DWord -Force 2>$null
    $InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $InterfacesPath -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
    netsh int ip set global taskoffload=enabled 2>$null | Out-Null
    netsh int tcp set supplemental template=custom icw=10 2>$null | Out-Null
    Clear-DnsClientCache -ErrorAction SilentlyContinue | Out-Null
    netsh winsock reset 2>$null | Out-Null
    netsh int ip reset  2>$null | Out-Null
    ipconfig /release   2>$null | Out-Null
    ipconfig /renew     2>$null | Out-Null
    Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue
    Finish-Task
}

function Optimize-Services {
    Start-Task "Windows Services"
    $DisableServices = @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')
    foreach ($svc in $DisableServices) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    $EnableServices = @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')
    foreach ($svc in $EnableServices) {
        Set-Service   -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $svc -ErrorAction SilentlyContinue
    }
    Finish-Task
}

function Clean-TrashAndLogs {
    Start-Task "Junk & Log Cleanup"
    $JunkPaths = @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")
    foreach ($Path in $JunkPaths) {
        Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" }
    Finish-Task
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 10 ] EXECUTION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Optimize-Kernel
Optimize-TimerResolution
Optimize-Priority
Optimize-IRQ
Optimize-Memory
Optimize-Input
Optimize-Nagle
Optimize-VisualEffects
Disable-GameBar
Optimize-ProcessorPower
Install-CustardPowerPlan
Optimize-Network
Optimize-Services
Clean-TrashAndLogs

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  [ 11 ] FINALIZATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Write-Progress -Activity "GOAT Optimization" -Completed
Clear-Host
Draw-Banner

W ""
W "  â•”$edgeâ•—" DarkRed
W "  â•‘" DarkRed -NoNewline
Write-Host (Center "âœ”  ALL TWEAKS AND SYSTEM CLEANUP COMPLETED!" $W).PadRight($W) -NoNewline -ForegroundColor Red
W "â•‘" DarkRed
W "  â•š$edgeâ•" DarkRed
W ""

if ((Read-Host "  Restart your PC now? (Y/N)") -match "[Yy]") { Restart-Computer }
