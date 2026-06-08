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

# ── CHARS (defined as variables to survive encoding issues) ────────────────
$h  = [char]9552  # ═
$tl = [char]9556  # ╔
$tr = [char]9559  # ╗
$bl = [char]9562  # ╚
$br = [char]9565  # ╝
$vl = [char]9553  # ║
$ml = [char]9568  # ╠
$mr = [char]9571  # ╣
$fi = [char]9608  # █
$em = [char]9617  # ░
$hd = [char]9580  # ╬ (not used but kept)

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
    W $vl DarkRed
    Write-Host "  " -NoNewline; W "$ml$($h * $boxW)$mr" DarkRed

    foreach ($i in 0..($script:TaskList.Count - 1)) {
        $name = $script:TaskList[$i]
        Write-Host "  " -NoNewline; W $vl DarkRed -NoNewline
        Write-Host "  " -NoNewline
        if ($i -lt $script:TaskIdx) {
            Write-Host "OK " -NoNewline -ForegroundColor Green
            Write-Host $name.PadRight($innerW - 8) -NoNewline -ForegroundColor DarkGray
            Write-Host "DONE    " -NoNewline -ForegroundColor DarkGreen
        } elseif ($i -eq $script:TaskIdx) {
            Write-Host ">> " -NoNewline -ForegroundColor Red
            Write-Host $name.PadRight($innerW - 12) -NoNewline -ForegroundColor White
            Write-Host "RUNNING..." -NoNewline -ForegroundColor Yellow
        } else {
            Write-Host ("   " + $name).PadRight($innerW) -NoNewline -ForegroundColor DarkGray
        }
        W $vl DarkRed
    }

    Write-Host "  " -NoNewline; W "$ml$($h * $boxW)$mr" DarkRed

    $pct    = [math]::Round($script:TaskIdx / $script:TotalTask * 100)
    $barW   = $boxW - 20
    $filled = [math]::Round($pct / 100 * $barW)
    $empty  = $barW - $filled

    Write-Host "  " -NoNewline; W $vl DarkRed -NoNewline
    Write-Host "  OVERALL [" -NoNewline -ForegroundColor DarkGray
    Write-Host ($fi * $filled) -NoNewline -ForegroundColor Red
    Write-Host ($em * $empty)  -NoNewline -ForegroundColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($pct.ToString().PadLeft(3))%  " -NoNewline -ForegroundColor Red
    W $vl DarkRed

    Write-Host "  " -NoNewline; W "$bl$($h * $boxW)$br" DarkRed
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

# ── BANNER ─────────────────────────────────────────────────────────────────
function Draw-Banner {
    W ""
    W "  $tl$edge$tr" DarkRed
    W "  $vl" DarkRed -NoNewline; W ($fi * $W) Red -NoNewline; W $vl DarkRed
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed

    $logo = @(
        '    ######   ######   #####  ########    ',
        '   ##       ##   ## ##   ##    ##        ',
        '   ##  ###  ##   ## #######   ##         ',
        '   ##   ##  ##   ## ##   ##   ##         ',
        '    ######   ######  ##   ##  ##         ',
        '                                         '
    )
    $logoColors = @('Red','Red','DarkRed','DarkRed','Red','DarkRed')
    foreach ($i in 0..($logo.Count - 1)) {
        W "  $vl" DarkRed -NoNewline
        Write-Host (Center $logo[$i] $W).PadRight($W) -NoNewline -ForegroundColor $logoColors[$i]
        W $vl DarkRed
    }

    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed
    W "  $vl" DarkRed -NoNewline
    Write-Host (Center "·  G R E A T E S T   O F   A L L   T W E A K S  ·" $W).PadRight($W) -NoNewline -ForegroundColor DarkYellow
    W $vl DarkRed
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed

    W "  $ml$edge$mr" DarkRed
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed
    SysRow "CPU" ($CPU.Substring(0, [math]::Min(36, $CPU.Length))) $CPULoad 'Red'
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed
    SysRow "RAM" "$RAMUsed GB / $RAMTotal GB DDR" $RAMPct 'DarkYellow'
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed
    SysRow "OS " ($OSName.Substring(0, [math]::Min(36, $OSName.Length))) 100 'DarkRed'
    W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed

    W "  $ml$edge$mr" DarkRed
    W "  $vl" DarkRed -NoNewline
    $mods = @('KERNEL','MEMORY','INPUT','NETWORK','IRQ/MSI','POWER','SERVICES','CLEANER')
    Write-Host "  " -NoNewline
    foreach ($m in $mods) {
        Write-Host "[ " -NoNewline -ForegroundColor DarkGray
        Write-Host $m   -NoNewline -ForegroundColor Red
        Write-Host " ] " -NoNewline -ForegroundColor DarkGray
    }
    $modLen = 2 + ($mods | ForEach-Object { "[ $_ ] ".Length } | Measure-Object -Sum).Sum
    Write-Host (' ' * [math]::Max(0, $W - $modLen)) -NoNewline
    W $vl DarkRed
    W "  $ml$edge$mr" DarkRed
}

# ── DRAW BANNER + LOADING BAR ──────────────────────────────────────────────
Draw-Banner

W "  $vl" DarkRed -NoNewline
Write-Host "  INITIALIZING  [" -NoNewline -ForegroundColor DarkYellow
$total  = 50
$colors = @('DarkRed','DarkRed','Red','Red','Yellow','Red','Red','DarkRed','DarkRed')
for ($b = 0; $b -lt $total; $b++) {
    $ci = [math]::Min($b * ($colors.Count - 1) / ($total - 1), $colors.Count - 1)
    Write-Host $fi -NoNewline -ForegroundColor $colors[[math]::Floor($ci)]
    Start-Sleep -Milliseconds 22
}
Write-Host "] 100%" -NoNewline -ForegroundColor Green
$after = $W - 2 - "  INITIALIZING  [".Length - $total - "] 100%".Length
Write-Host (' ' * [math]::Max(0, $after)) -NoNewline
W $vl DarkRed

W "  $vl" DarkRed -NoNewline
Write-Host "  OK ALL MODULES READY" -NoNewline -ForegroundColor Green
Write-Host (' ' * ($W - 24)) -NoNewline
W $vl DarkRed
W "  $vl" DarkRed -NoNewline; W (' ' * $W) -NoNewline; W $vl DarkRed

$half = $h * 51
$half2 = $h * 46
W "  $ml$half${[char]9574}$half2$mr" DarkRed
W "  $vl" DarkRed -NoNewline
Write-Host "   >> READY TO RUN GOAT?                          " -NoNewline -ForegroundColor DarkYellow
W $vl DarkRed -NoNewline
Write-Host "  Press " -NoNewline -ForegroundColor DarkGray
Write-Host "Y" -NoNewline -ForegroundColor Red
Write-Host " to begin optimization           " -NoNewline -ForegroundColor DarkGray
W $vl DarkRed

W "  $vl" DarkRed -NoNewline
Write-Host (' ' * 52) -NoNewline
W $vl DarkRed -NoNewline
Write-Host "  Press " -NoNewline -ForegroundColor DarkGray
Write-Host "N" -NoNewline -ForegroundColor DarkGray
Write-Host " to exit                           " -NoNewline -ForegroundColor DarkGray
W $vl DarkRed
W "  $bl$half${[char]9577}$half2$br" DarkRed

W ""
$ts = Get-Date -Format "yyyy-MM-dd  HH:mm:ss"
Write-Host "  * " -NoNewline -ForegroundColor Red
Write-Host "SYSTEM ONLINE" -NoNewline -ForegroundColor DarkRed
Write-Host "   v2.0.0   $ts" -ForegroundColor DarkGray
W ""

# ── INPUT ──────────────────────────────────────────────────────────────────
do {
    Write-Host "  >> " -NoNewline -ForegroundColor DarkRed
    Write-Host "Your choice " -NoNewline -ForegroundColor Gray
    Write-Host "[Y/N]" -NoNewline -ForegroundColor DarkYellow
    Write-Host " : " -NoNewline -ForegroundColor Gray
    $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    Write-Host $choice -ForegroundColor Red
} while ($choice -notmatch '^[YyNn]$')

if ($choice -match '[Nn]') { W "`n  [X] Aborted.`n" DarkGray; Exit }
W "`n  [OK] Starting optimization...`n" Red

# ── WORKING DIR ────────────────────────────────────────────────────────────
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir
$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# ── OPTIMIZATION FUNCTIONS ─────────────────────────────────────────────────
function Optimize-Kernel {
    Start-Task "Kernel and HPET"
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
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
    Finish-Task
}
function Optimize-IRQ {
    Start-Task "IRQ MSI Mode"
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $msiPath = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $msiPath) { Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null }
    }
    Finish-Task
}
function Optimize-Nagle {
    Start-Task "Nagle Algorithm"
    $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
    Finish-Task
}
function Optimize-VisualEffects {
    Start-Task "Visual Effects"
    $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
    Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
    Finish-Task
}
function Disable-GameBar {
    Start-Task "Game Bar and DVR"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
    $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
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
    $pp = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $sp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $gp = "$sp\Tasks\Games"
    $ep = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"
    Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "GPU Priority"        -Value 8      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Priority"            -Value 6      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null
    Set-ItemProperty -Path $gp -Name "SFIO Priority"       -Value "High" -Type String -Force 2>$null
    Finish-Task
}
function Optimize-Memory {
    Start-Task "Memory Management"
    $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $pp = "$mp\PrefetchParameters"
    Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown"       -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $pp -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $pp -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
    powercfg -h off 2>$null | Out-Null
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Finish-Task
}
function Optimize-Input {
    Start-Task "Input and USB"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }
    Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseSpeed"       -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseThreshold1"  -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseThreshold2"  -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay"    -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed"    -Value "31" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
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
    Start-Task "Network and DNS"
    netsh int tcp set global rss=enabled           2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled    2>$null | Out-Null
    netsh int tcp set global chimney=disabled       2>$null | Out-Null
    $tp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $tp -Name "TCPNoDelay"      -Value 1  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $tp -Name "DefaultTTL"      -Value 64 -Type DWord -Force 2>$null
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
    @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc') | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer') | ForEach-Object {
        Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
    Finish-Task
}
function Clean-TrashAndLogs {
    Start-Task "Junk and Log Cleanup"
    @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*") | ForEach-Object {
        Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
    Finish-Task
}

# ── EXECUTION ──────────────────────────────────────────────────────────────
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

# ── FINALIZATION ───────────────────────────────────────────────────────────
Write-Progress -Activity "GOAT Optimization" -Completed
Clear-Host
Draw-Banner

W ""
W "  $tl$edge$tr" DarkRed
W "  $vl" DarkRed -NoNewline
Write-Host (Center "OK  ALL TWEAKS AND SYSTEM CLEANUP COMPLETED!" $W).PadRight($W) -NoNewline -ForegroundColor Red
W $vl DarkRed
W "  $bl$edge$br" DarkRed
W ""

if ((Read-Host "  Restart your PC now? (Y/N)") -match "[Yy]") { Restart-Computer }
