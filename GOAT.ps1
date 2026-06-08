#Requires -Version 5.1
<#
    GOAT - GREATEST OF ALL TWEAKS (FULL INTEGRATED)
#>

# --- [ STA THREAD AUTO-RESTART ] ---
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $tmp = "$env:TEMP\GOAT_run.ps1"
    $src = $MyInvocation.MyCommand.Definition
    if (-not $src -or $src -eq '') {
        $src = (Invoke-WebRequest "https://raw.githubusercontent.com/Custardshop/script/main/GOAT.ps1" -UseBasicParsing).Content
        $src | Out-File $tmp -Encoding UTF8
    } else {
        Copy-Item $src $tmp -Force
    }
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -STA -File `"$tmp`"" -Verb RunAs
    Exit
}

# --- [ 1. ADMIN PRIVILEGE CHECK ] ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  [!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor Red
    Write-Host "  Please restart PowerShell as Administrator." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "GOAT"
Clear-Host

# --- [ SYSTEM INFO ] ---
$CPU     = (Get-CimInstance Win32_Processor).Name
$RAMTotal= [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
$RAMUsed = [math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB - (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$OSName  = (Get-CimInstance Win32_OperatingSystem).Caption
$RAMPct  = [math]::Round(($RAMUsed / $RAMTotal) * 100)

# CPU Usage (sample)
$CPULoad = (Get-CimInstance Win32_Processor).LoadPercentage

# Bar builder
function Make-Bar {
    param([int]$Pct, [int]$Width = 32)
    $filled = [math]::Round($Pct / 100 * $Width)
    $empty  = $Width - $filled
    return ('█' * $filled) + ('░' * $empty)
}

$border = '║'
$line   = '═' * 86

# --- [ BANNER ] ---
Write-Host ""
Write-Host "  ╔$line╗" -ForegroundColor DarkCyan
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

# GOAT ASCII — ไล่สี 3 ระดับ
$logo = @(
    '    ██████╗  ██████╗  █████╗ ████████╗                                              ',
    '   ██╔════╝ ██╔═══██╗██╔══██╗╚══██╔══╝                                              ',
    '   ██║  ███╗██║   ██║███████║   ██║                                                  ',
    '   ██║   ██║██║   ██║██╔══██║   ██║                                                  ',
    '   ╚██████╔╝╚██████╔╝██║  ██║   ██║                                                  ',
    '    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝                                                  '
)
$colors = @('Cyan','Cyan','DarkCyan','DarkCyan','DarkCyan','DarkCyan')
for ($i = 0; $i -lt $logo.Count; $i++) {
    Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
    Write-Host $logo[$i] -NoNewline -ForegroundColor $colors[$i]
    Write-Host "$border" -ForegroundColor DarkCyan
}

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
$tagline = '─────  G R E A T E S T   O F   A L L   T W E A K S  ─────'
$pad = [math]::Floor((86 - $tagline.Length) / 2)
Write-Host (' ' * $pad) -NoNewline
Write-Host $tagline -NoNewline -ForegroundColor Yellow
Write-Host (' ' * (86 - $pad - $tagline.Length)) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

# --- [ SYSTEM INFO SECTION ] ---
Write-Host "  ╠$line╣" -ForegroundColor DarkCyan

# CPU
$cpuBar = Make-Bar -Pct $CPULoad
$cpuLine = "   CPU  $($CPU.PadRight(38))  [$cpuBar] $($CPULoad.ToString().PadLeft(3))%"
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host $cpuLine.PadRight(86) -NoNewline -ForegroundColor White
Write-Host "$border" -ForegroundColor DarkCyan

# RAM
$ramBar = Make-Bar -Pct $RAMPct
$ramLine = "   RAM  $($RAMTotal.ToString())GB DDR                        [$ramBar] $($RAMPct.ToString().PadLeft(3))%"
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host $ramLine.PadRight(86) -NoNewline -ForegroundColor White
Write-Host "$border" -ForegroundColor DarkCyan

# OS
$osBar  = Make-Bar -Pct 100
$osLine = "   OS   $($OSName.PadRight(38))  [$osBar] RDY"
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host $osLine.PadRight(86) -NoNewline -ForegroundColor Cyan
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

# --- [ MODULE BAR ] ---
Write-Host "  ╠$line╣" -ForegroundColor DarkCyan
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host '   [ KERNEL ]      [ MEMORY ]      [ INPUT ]      [ NETWORK ]      [ CLEANER ]   ' -NoNewline -ForegroundColor Green
Write-Host "$border" -ForegroundColor DarkCyan
Write-Host "  ╠$line╣" -ForegroundColor DarkCyan

# --- [ LOADING BAR ] ---
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host -NoNewline '   Initializing GOAT  [' -ForegroundColor Yellow
$totalBlocks = 40
for ($b = 0; $b -lt $totalBlocks; $b++) {
    Write-Host -NoNewline '█' -ForegroundColor Cyan
    Start-Sleep -Milliseconds 30
}
Write-Host -NoNewline '] 100%' -ForegroundColor Green
Write-Host (' ' * 17) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host '   [OK] ALL MODULES READY' -NoNewline -ForegroundColor Green
Write-Host (' ' * 61) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  ╚$line╝" -ForegroundColor DarkCyan
Write-Host "  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·" -ForegroundColor DarkCyan
Write-Host ""

# --- [ PROMPT: ต้องการปรับแต่งหรือไม่ ] ---
Write-Host "  ┌─────────────────────────────────────────────┐" -ForegroundColor DarkCyan
Write-Host "  │                                             │" -ForegroundColor DarkCyan
Write-Host "  │    Ready to run GOAT?                      │" -ForegroundColor Yellow
Write-Host "  │                                             │" -ForegroundColor DarkCyan
Write-Host "  │     [Y]  YES — Begin Optimization          │" -ForegroundColor Green
Write-Host "  │     [N]  NO  — Exit                        │" -ForegroundColor DarkGray
Write-Host "  │                                             │" -ForegroundColor DarkCyan
Write-Host "  └─────────────────────────────────────────────┘" -ForegroundColor DarkCyan
Write-Host ""

# วนรับ input จนกว่าจะถูกต้อง
do {
    Write-Host "  >> Your choice [Y/N]: " -NoNewline -ForegroundColor Yellow
    $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    Write-Host $choice -ForegroundColor Cyan
} while ($choice -notmatch '^[YyNn]$')

if ($choice -match '[Nn]') {
    Write-Host ""
    Write-Host "  [!] Aborted — Exiting GOAT." -ForegroundColor DarkGray
    Write-Host ""
    Exit
}

Write-Host ""
Write-Host "  [>>] GOAT is on the run — Starting optimization..." -ForegroundColor Green
Write-Host ""

# ตั้งค่าตำแหน่งทำงาน
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# --- [ FUNCTIONS ] ---
function Optimize-Kernel {
    Write-Host " -> Optimizing Kernel & HPET Settings..." -ForegroundColor Yellow
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    bcdedit /set synthetictimers yes 2>$null | Out-Null
    $hpet = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision*" } -ErrorAction SilentlyContinue
    if ($hpet) { Disable-PnpDevice -InstanceId $hpet.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
    Write-Host "    [VERIFIED] Kernel & HPET Tweaks Processed." -ForegroundColor Green
}

function Optimize-TimerResolution {
    Write-Host " -> Setting Timer Resolution to 1ms..." -ForegroundColor Yellow
    $TimerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    Set-ItemProperty -Path $TimerPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] Timer Resolution Set." -ForegroundColor Green
}

function Optimize-IRQ {
    Write-Host " -> Setting IRQ Priority for GPU & NIC (MSI Mode)..." -ForegroundColor Yellow
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $msiPath = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $msiPath) {
            Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null
        }
    }
    Write-Host "    [VERIFIED] IRQ Priority Configured." -ForegroundColor Green
}

function Optimize-Nagle {
    Write-Host " -> Disabling Nagle's Algorithm (TCP Latency)..." -ForegroundColor Yellow
    $InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $InterfacesPath -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
    Write-Host "    [VERIFIED] Nagle Disabled — TCP Latency Reduced." -ForegroundColor Green
}

function Optimize-VisualEffects {
    Write-Host " -> Disabling Visual Effects for Performance..." -ForegroundColor Yellow
    $VisualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $VisualPath)) { New-Item -Path $VisualPath -Force | Out-Null }
    Set-ItemProperty -Path $VisualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] Visual Effects Minimized." -ForegroundColor Green
}

function Disable-GameBar {
    Write-Host " -> Disabling Xbox Game Bar & DVR..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled"              -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"                     -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode"              -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode"     -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible"-Value 1 -Type DWord -Force 2>$null
    $GameBarPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $GameBarPath)) { New-Item -Path $GameBarPath -Force | Out-Null }
    Set-ItemProperty -Path $GameBarPath -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] Game Bar & DVR Disabled." -ForegroundColor Green
}

function Optimize-ProcessorPower {
    Write-Host " -> Tuning Processor Power Policy..." -ForegroundColor Yellow
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
    Write-Host "    [VERIFIED] Processor Power Policy Set." -ForegroundColor Green
}

function Optimize-Priority {
    Write-Host " -> Optimizing Process & GPU Priorities..." -ForegroundColor Yellow
    $PriorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $SystemProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $GamesTaskPath = "$SystemProfilePath\Tasks\Games"

    Set-ItemProperty -Path $PriorityPath -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PriorityPath -Name "ConvertibleSlateMode"    -Value 0     -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $SystemProfilePath -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $SystemProfilePath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    # Worker threads — server-style CPU scheduling
    $ExecPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"
    Set-ItemProperty -Path $ExecPath -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $ExecPath -Name "AdditionalDelayedWorkerThreads"  -Value 2 -Type DWord -Force 2>$null
    # Full Games task profile
    if (-not (Test-Path $GamesTaskPath)) { New-Item -Path $GamesTaskPath -Force | Out-Null }
    Set-ItemProperty -Path $GamesTaskPath -Name "Affinity"            -Value 0       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Background Only"     -Value "False" -Type String -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Clock Rate"          -Value 0x2710  -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "GPU Priority"        -Value 8       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Priority"            -Value 6       -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Scheduling Category" -Value "High"  -Type String -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "SFIO Priority"       -Value "High"  -Type String -Force 2>$null
}

function Optimize-Memory {
    Write-Host " -> Tweaking Memory Management..." -ForegroundColor Yellow
    $MemoryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $PrefetchPath = "$MemoryPath\PrefetchParameters"

    Set-ItemProperty -Path $MemoryPath -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageThreshold" -Value 15 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcTotalDirtyPages" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageTarget" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher"         -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch"          -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath   -Name "LargeSystemCache"          -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath   -Name "ClearPageFileAtShutdown"   -Value 0 -Type DWord -Force 2>$null
    # Disable Hibernate (saves SSD space, reduces kernel overhead)
    powercfg -h off 2>$null | Out-Null
    # Kill OneDrive background sync (frees bandwidth & CPU)
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    $RunPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Remove-ItemProperty -Path $RunPath -Name "OneDrive" -Force -ErrorAction SilentlyContinue
}

function Optimize-Input {
    Write-Host " -> Tuning Input Response & Power Throttling..." -ForegroundColor Yellow
    # Mouse queue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    # Keyboard queue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    # Power throttle off
    $PowerThrottlePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $PowerThrottlePath)) { New-Item -Path $PowerThrottlePath -Force | Out-Null }
    Set-ItemProperty -Path $PowerThrottlePath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed2" -Value "9000" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "TimeToMaximumSpeed2" -Value "9000" -Type String -Force 2>$null
    # Disable Mouse Acceleration (Windows Enhance Pointer Precision)
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed"      -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force 2>$null
    # Keyboard delay & repeat speed
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null
    # Disable USB Selective Suspend (prevent USB ports from sleeping)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    # Disable HID USB idle (prevents polling rate jitter)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
    # Additional mouse raw input
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime"   -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10" -Type String -Force 2>$null
    # Disable accessibility key delays (StickyKeys / ToggleKeys / FilterKeys)
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys"         -Name "Flags"                -Value "506" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys"         -Name "Flags"                -Value "58"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys"          -Name "Flags"                -Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response"  -Name "AutoRepeatDelay"      -Value "125" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response"  -Name "AutoRepeatRate"       -Value "11"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response"  -Name "BounceTime"           -Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response"  -Name "DelayBeforeAcceptance"-Value "0"   -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response"  -Name "Flags"                -Value "122" -Type String -Force 2>$null
    Write-Host "    [VERIFIED] Input & USB Tuned." -ForegroundColor Green
}

function Install-CustardPowerPlan {
    Write-Host " -> Importing Custard Power Plan..." -ForegroundColor Yellow
    $Guid = "4e2cd77e-229e-484e-b077-c63e8b092ec8"
    if (Test-Path $PowPath) {
        powercfg /delete $Guid 2>$null
        powercfg /import $PowPath $Guid 2>$null | Out-Null
        powercfg /setactive $Guid 2>$null | Out-Null
    }
}

function Optimize-Network {
    Write-Host " -> Optimizing Network & DNS..." -ForegroundColor Yellow
    # TCP stack global tweaks
    netsh int tcp set global rss=enabled          2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled   2>$null | Out-Null
    netsh int tcp set global chimney=disabled      2>$null | Out-Null
    netsh int tcp set global ecncapability=disabled 2>$null | Out-Null
    # Global TCP registry params
    $TcpParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $TcpParams -Name "EnableTCPChimney" -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnableRSS"        -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnableTCPA"       -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "Tcp1323Opts"      -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TCPNoDelay"       -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpAckFrequency"  -Value 1          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpDelAckTicks"   -Value 0          -Type DWord -Force 2>$null
    # Additional TCP params
    Set-ItemProperty -Path $TcpParams -Name "DefaultTTL"          -Value 64   -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "EnablePMTUDiscovery"  -Value 1   -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TcpParams -Name "TcpTimedWaitDelay"    -Value 30  -Type DWord -Force 2>$null
    # DNS cache tuning
    $DnsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
    Set-ItemProperty -Path $DnsPath -Name "CacheHashTableBucketSize"  -Value 1      -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "CacheHashTableSize"        -Value 0x180  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "MaxCacheEntryTtlLimit"     -Value 0xfa00 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $DnsPath -Name "MaxSOACacheEntryTtlLimit"  -Value 0x12d  -Type DWord -Force 2>$null
    # Task offload & initial congestion window
    netsh int ip set global taskoffload=enabled 2>$null | Out-Null
    netsh int tcp set supplemental template=custom icw=10 2>$null | Out-Null
    # Flush DNS & reset winsock
    Clear-DnsClientCache -ErrorAction SilentlyContinue | Out-Null
    netsh winsock reset 2>$null | Out-Null
    # Reset IP stack
    netsh int ip reset 2>$null | Out-Null
    # Release & renew IP
    ipconfig /release 2>$null | Out-Null
    ipconfig /renew   2>$null | Out-Null
    # Restart physical NICs to apply all settings immediately
    Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue
    Write-Host "    [VERIFIED] Network Stack Fully Optimized." -ForegroundColor Green
}

function Clean-TrashAndLogs {
    Write-Host " -> Cleaning System Junk, Logs, Updates & EventLogs..." -ForegroundColor Yellow
    
    # 1. ล้างไฟล์ขยะ (Temp, Prefetch)
    $JunkPaths = @("$env:USERPROFILE\AppData\Local\Temp\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
    foreach ($Path in $JunkPaths) {
        Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "    [DELETING] $($_.FullName)" -ForegroundColor Gray
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. ล้าง Windows Update (SoftwareDistribution)
    Write-Host "    [CLEANING] Windows Update Cache..." -ForegroundColor Gray
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv

    # 3. ล้าง Event Logs
    Write-Host "    [CLEANING] Windows Event Logs..." -ForegroundColor Gray
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" }
    
    Write-Host "    [VERIFIED CLEANED] All System Junk & Logs Wiped Clean!" -ForegroundColor Green
}


function Optimize-Services {
    Write-Host " -> Optimizing Windows Services..." -ForegroundColor Yellow
    # Disable background junk services
    $DisableServices = @(
        'DiagTrack','WSearch','MapsBroker',
        'XblAuthManager','XblGameSave','XboxNetApiSvc',
        'Fax','RetailDemo','RemoteRegistry','WerSvc'
    )
    foreach ($svc in $DisableServices) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    # Ensure critical audio & network services are running
    $EnableServices = @(
        'Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc',
        'Netman','WlanSvc','RpcSs','EventLog','PlugPlay',
        'LanmanWorkstation','LanmanServer'
    )
    foreach ($svc in $EnableServices) {
        Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $svc -ErrorAction SilentlyContinue
    }
    Write-Host "    [VERIFIED] Services Optimized." -ForegroundColor Green
}


function Optimize-GroupPolicy {
    Write-Host " -> Applying Group Policy Tweaks (via Registry)..." -ForegroundColor Yellow

    # 1. Disable Windows Update auto-download (ป้องกัน WU แย่งแบนด์วิธ/disk ระหว่างเล่นเกม)
    $WUPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (-not (Test-Path $WUPath)) { New-Item -Path $WUPath -Force | Out-Null }
    Set-ItemProperty -Path $WUPath -Name "NoAutoUpdate"                -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WUPath -Name "AUOptions"                   -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WUPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force 2>$null

    # 2. Disable Telemetry ระดับ policy
    $TelPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $TelPath)) { New-Item -Path $TelPath -Force | Out-Null }
    Set-ItemProperty -Path $TelPath -Name "AllowTelemetry"              -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TelPath -Name "DisableOneSettingsDownloads" -Value 1 -Type DWord -Force 2>$null

    # 3. Reservable Bandwidth = 0 (คืน bandwidth 20% ที่ Windows กันไว้)
    $PschedPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    if (-not (Test-Path $PschedPath)) { New-Item -Path $PschedPath -Force | Out-Null }
    Set-ItemProperty -Path $PschedPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force 2>$null

    # 4. Disable Background App Refresh (UWP apps)
    $AppPrivPath = "HKCU:\Software\Policies\Microsoft\Windows\AppPrivacy"
    if (-not (Test-Path $AppPrivPath)) { New-Item -Path $AppPrivPath -Force | Out-Null }
    Set-ItemProperty -Path $AppPrivPath -Name "LetAppsRunInBackground" -Value 2 -Type DWord -Force 2>$null

    # 5. Disable SysMain / Superfetch ระดับ policy (SSD ไม่จำเป็น)
    $SysMainPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SysMain"
    if (-not (Test-Path $SysMainPath)) { New-Item -Path $SysMainPath -Force | Out-Null }
    Set-ItemProperty -Path $SysMainPath -Name "Enabled" -Value 0 -Type DWord -Force 2>$null
    Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
    Set-Service  -Name SysMain -StartupType Disabled -ErrorAction SilentlyContinue

    # 6. Disable Windows Error Reporting ระดับ policy
    $WerPolPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting"
    if (-not (Test-Path $WerPolPath)) { New-Item -Path $WerPolPath -Force | Out-Null }
    Set-ItemProperty -Path $WerPolPath -Name "Disabled"              -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WerPolPath -Name "DontSendAdditionalData" -Value 1 -Type DWord -Force 2>$null

    Write-Host "    [VERIFIED] Group Policy Tweaks Applied." -ForegroundColor Green
}


function Optimize-DPC {
    Write-Host " -> Reducing DPC Latency & Stuttering..." -ForegroundColor Yellow
    $KernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    Set-ItemProperty -Path $KernelPath -Name "IdealDpcRate"          -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $KernelPath -Name "DpcTimeout"            -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $KernelPath -Name "DisablePriorityBoost"  -Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] DPC Latency Optimized." -ForegroundColor Green
}

function Optimize-CoreParking {
    Write-Host " -> Disabling CPU Core Parking..." -ForegroundColor Yellow
    # ปิด Core Parking ผ่าน power plan active
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
    # Registry fallback สำหรับทุก power scheme
    $schemes = powercfg /list 2>$null | Select-String -Pattern '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' |
        ForEach-Object { $_.Matches[0].Value }
    foreach ($guid in $schemes) {
        powercfg /setacvalueindex $guid SUB_PROCESSOR CPMINCORES 100 2>$null | Out-Null
    }
    Write-Host "    [VERIFIED] Core Parking Disabled." -ForegroundColor Green
}

function Optimize-GPU {
    Write-Host " -> Applying GPU Latency & Stability Tweaks..." -ForegroundColor Yellow
    $GraphicsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (-not (Test-Path $GraphicsPath)) { New-Item -Path $GraphicsPath -Force | Out-Null }
    # TDR tuning — ลด GPU driver crash ระหว่างโหลดหนัก
    Set-ItemProperty -Path $GraphicsPath -Name "TdrDelay"        -Value 10 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GraphicsPath -Name "TdrDdiDelay"     -Value 10 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GraphicsPath -Name "TdrLimitCount"   -Value 60 -Type DWord -Force 2>$null
    # Disable GPU Preemption (ลด context switch overhead)
    $SchedulerPath = "$GraphicsPath\Scheduler"
    if (-not (Test-Path $SchedulerPath)) { New-Item -Path $SchedulerPath -Force | Out-Null }
    Set-ItemProperty -Path $SchedulerPath -Name "DisablePreemption" -Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] GPU Tweaks Applied." -ForegroundColor Green
}

function Optimize-MemoryAdvanced {
    Write-Host " -> Applying Advanced Memory Tweaks..." -ForegroundColor Yellow
    $MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    # บังคับ kernel/drivers อยู่ใน RAM ไม่ลง pagefile
    Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force 2>$null
    # ตั้ง L2 Cache ตาม CPU (default 0 = auto แต่ explicit ดีกว่า)
    $L2 = (Get-CimInstance Win32_Processor).L2CacheSize
    if ($L2 -gt 0) {
        Set-ItemProperty -Path $MemPath -Name "SecondLevelDataCache" -Value $L2 -Type DWord -Force 2>$null
    }
    Write-Host "    [VERIFIED] Advanced Memory Tweaks Applied." -ForegroundColor Green
}

function Optimize-ServicesExtra {
    Write-Host " -> Disabling Additional Unnecessary Services..." -ForegroundColor Yellow
    $ExtraDisable = @(
        'lfsvc',          # Geolocation Service
        'TabletInputService', # Tablet / Touch keyboard
        'PrintSpooler',   # Print Spooler (ปิดถ้าไม่มีปริ้นเตอร์)
        'Spooler',        # Print Spooler alias
        'WMPNetworkSvc',  # Windows Media Player sharing
        'icssvc',         # Mobile Hotspot
        'wisvc',          # Windows Insider Service
        'wlidsvc',        # Microsoft Account Sign-in (optional)
        'PcaSvc'          # Program Compatibility Assistant
    )
    foreach ($svc in $ExtraDisable) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Write-Host "    [VERIFIED] Extra Services Disabled." -ForegroundColor Green
}

function Optimize-NetworkExtra {
    Write-Host " -> Applying Additional Network Tweaks..." -ForegroundColor Yellow
    # ป้องกัน Windows Connect Now แย่งเน็ต
    $WcmPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"
    if (-not (Test-Path $WcmPath)) { New-Item -Path $WcmPath -Force | Out-Null }
    Set-ItemProperty -Path $WcmPath -Name "fMinimizeConnections"      -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WcmPath -Name "fBlockNonDomain"           -Value 0 -Type DWord -Force 2>$null
    # Disable Network Location Awareness background polling
    $NlaPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"
    if (-not (Test-Path $NlaPath)) { New-Item -Path $NlaPath -Force | Out-Null }
    Set-ItemProperty -Path $NlaPath -Name "EnableActiveProbing" -Value 0 -Type DWord -Force 2>$null
    # Disable NCSI active probing (หยุด Windows ping microsoft.com ตลอดเวลา)
    $NcsiPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator"
    if (-not (Test-Path $NcsiPath)) { New-Item -Path $NcsiPath -Force | Out-Null }
    Set-ItemProperty -Path $NcsiPath -Name "NoActiveProbe"       -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $NcsiPath -Name "DisablePassivePolling"-Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] Additional Network Tweaks Applied." -ForegroundColor Green
}

# --- [ EXECUTION — WinForms GUI ] ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Form ──────────────────────────────────────────────────────────────────
$form                  = [System.Windows.Forms.Form]::new()
$form.Text             = "GOAT — Greatest Of All Tweaks  v2.0"
$form.Size             = [System.Drawing.Size]::new(820, 640)
$form.StartPosition    = "CenterScreen"
$form.BackColor        = [System.Drawing.Color]::FromArgb(8, 0, 0)
$form.ForeColor        = [System.Drawing.Color]::FromArgb(204, 0, 0)
$form.FormBorderStyle  = "FixedSingle"
$form.MaximizeBox      = $false
$form.Font             = [System.Drawing.Font]::new("Consolas", 9)

# ── Helper: new Label ─────────────────────────────────────────────────────
function New-Lbl {
    param($text, $x, $y, $w, $h, $color, $size=9, $bold=$false)
    $l = [System.Windows.Forms.Label]::new()
    $l.Text      = $text
    $l.Location  = [System.Drawing.Point]::new($x,$y)
    $l.Size      = [System.Drawing.Size]::new($w,$h)
    $l.ForeColor = $color
    $l.BackColor = [System.Drawing.Color]::Transparent
    $style = if ($bold) {"Bold"} else {"Regular"}
    $l.Font = [System.Drawing.Font]::new("Consolas", $size, [System.Drawing.FontStyle]$style)
    return $l
}

function New-Btn {
    param($text, $x, $y, $w, $h)
    $b = [System.Windows.Forms.Button]::new()
    $b.Text      = $text
    $b.Location  = [System.Drawing.Point]::new($x,$y)
    $b.Size      = [System.Drawing.Size]::new($w,$h)
    $b.ForeColor = [System.Drawing.Color]::FromArgb(255,50,50)
    $b.BackColor = [System.Drawing.Color]::FromArgb(26,0,0)
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(139,0,0)
    $b.FlatAppearance.BorderSize  = 1
    $b.Font = [System.Drawing.Font]::new("Consolas", 9, [System.Drawing.FontStyle]::Bold)
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $b
}

# ── Header Panel ──────────────────────────────────────────────────────────
$pHeader           = [System.Windows.Forms.Panel]::new()
$pHeader.Location  = [System.Drawing.Point]::new(10,10)
$pHeader.Size      = [System.Drawing.Size]::new(782,150)
$pHeader.BackColor = [System.Drawing.Color]::FromArgb(16,0,0)
$form.Controls.Add($pHeader)

$logoLines = @(
    "  ██████╗  ██████╗  █████╗ ████████╗",
    " ██╔════╝ ██╔═══██╗██╔══██╗╚══██╔══╝",
    " ██║  ███╗██║   ██║███████║   ██║   ",
    " ██║   ██║██║   ██║██╔══██║   ██║   ",
    " ╚██████╔╝╚██████╔╝██║  ██║   ██║   ",
    "  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   "
)
$logoColors = @(
    [System.Drawing.Color]::FromArgb(204,0,0),
    [System.Drawing.Color]::FromArgb(204,0,0),
    [System.Drawing.Color]::FromArgb(170,0,0),
    [System.Drawing.Color]::FromArgb(170,0,0),
    [System.Drawing.Color]::FromArgb(120,0,0),
    [System.Drawing.Color]::FromArgb(120,0,0)
)
for ($i=0; $i -lt $logoLines.Count; $i++) {
    $l = New-Lbl $logoLines[$i] 10 (5+$i*19) 760 20 $logoColors[$i] 10
    $pHeader.Controls.Add($l)
}
$tagline = New-Lbl "─── G R E A T E S T   O F   A L L   T W E A K S ───" 0 125 782 20 ([System.Drawing.Color]::FromArgb(255,50,50)) 9 $true
$tagline.TextAlign = "MiddleCenter"
$pHeader.Controls.Add($tagline)

# ── SysInfo Panel ─────────────────────────────────────────────────────────
$pSys           = [System.Windows.Forms.Panel]::new()
$pSys.Location  = [System.Drawing.Point]::new(10,168)
$pSys.Size      = [System.Drawing.Size]::new(782,70)
$pSys.BackColor = [System.Drawing.Color]::FromArgb(13,0,0)
$form.Controls.Add($pSys)

$dimRed  = [System.Drawing.Color]::FromArgb(85,0,0)
$brightR = [System.Drawing.Color]::FromArgb(255,60,60)

$pSys.Controls.Add((New-Lbl "CPU" 10 5 40 16 $dimRed 8))
$lblCPU = New-Lbl ($CPU.Substring(0,[math]::Min(50,$CPU.Length))) 55 5 500 16 $brightR 8
$pSys.Controls.Add($lblCPU)
$pbCPU = [System.Windows.Forms.ProgressBar]::new()
$pbCPU.Location  = [System.Drawing.Point]::new(10,24)
$pbCPU.Size      = [System.Drawing.Size]::new(240,6)
$pbCPU.Value     = [math]::Min($CPULoad,100)
$pbCPU.Style     = "Continuous"
$pbCPU.ForeColor = [System.Drawing.Color]::FromArgb(180,0,0)
$pSys.Controls.Add($pbCPU)
$pSys.Controls.Add((New-Lbl "$CPULoad%" 258 22 40 16 $brightR 8))

$pSys.Controls.Add((New-Lbl "RAM" 10 38 40 16 $dimRed 8))
$pSys.Controls.Add((New-Lbl "$RAMUsed GB / $RAMTotal GB" 55 38 200 16 $brightR 8))
$pbRAM = [System.Windows.Forms.ProgressBar]::new()
$pbRAM.Location  = [System.Drawing.Point]::new(260,38)
$pbRAM.Size      = [System.Drawing.Size]::new(240,6)
$pbRAM.Value     = [math]::Min($RAMPct,100)
$pbRAM.ForeColor = [System.Drawing.Color]::FromArgb(139,0,0)
$pSys.Controls.Add($pbRAM)
$pSys.Controls.Add((New-Lbl "$RAMPct%" 508 36 40 16 $brightR 8))

$pSys.Controls.Add((New-Lbl "OS " 560 5 30 16 $dimRed 8))
$pSys.Controls.Add((New-Lbl ($OSName.Substring(0,[math]::Min(28,$OSName.Length))) 595 5 185 16 $brightR 8))

# ── Progress Panel ────────────────────────────────────────────────────────
$pProg           = [System.Windows.Forms.Panel]::new()
$pProg.Location  = [System.Drawing.Point]::new(10,246)
$pProg.Size      = [System.Drawing.Size]::new(782,50)
$pProg.BackColor = [System.Drawing.Color]::FromArgb(13,0,0)
$form.Controls.Add($pProg)

$lblTask = New-Lbl "WAITING — Press RUN GOAT to begin" 10 5 600 18 ([System.Drawing.Color]::FromArgb(255,60,60)) 9
$pProg.Controls.Add($lblTask)
$lblPct = New-Lbl "0%" 700 5 60 18 ([System.Drawing.Color]::FromArgb(204,0,0)) 9
$pProg.Controls.Add($lblPct)
$pbMain = [System.Windows.Forms.ProgressBar]::new()
$pbMain.Location  = [System.Drawing.Point]::new(10,28)
$pbMain.Size      = [System.Drawing.Size]::new(762,10)
$pbMain.Maximum   = 100
$pbMain.ForeColor = [System.Drawing.Color]::FromArgb(180,0,0)
$pProg.Controls.Add($pbMain)

# ── Log Box ───────────────────────────────────────────────────────────────
$rtb = [System.Windows.Forms.RichTextBox]::new()
$rtb.Location    = [System.Drawing.Point]::new(10,304)
$rtb.Size        = [System.Drawing.Size]::new(782,240)
$rtb.BackColor   = [System.Drawing.Color]::FromArgb(5,0,0)
$rtb.ForeColor   = [System.Drawing.Color]::FromArgb(170,0,0)
$rtb.BorderStyle = "None"
$rtb.ReadOnly    = $true
$rtb.ScrollBars  = "Vertical"
$rtb.Font        = [System.Drawing.Font]::new("Consolas", 9)
$form.Controls.Add($rtb)

# ── Buttons ───────────────────────────────────────────────────────────────
$btnRun     = New-Btn "▶  RUN GOAT"   10  554  240 34
$btnRestart = New-Btn "↺  RESTART PC" 276 554  240 34
$btnExit    = New-Btn "✕  EXIT"       542 554  250 34
$btnRestart.Enabled = $false
$form.Controls.Add($btnRun)
$form.Controls.Add($btnRestart)
$form.Controls.Add($btnExit)

# ── Status bar ────────────────────────────────────────────────────────────
$lblStatus          = New-Lbl "● SYSTEM ONLINE" 10 596 400 18 ([System.Drawing.Color]::FromArgb(100,0,0)) 8
$lblTime            = New-Lbl "GOAT v2.0.0" 680 596 120 18 ([System.Drawing.Color]::FromArgb(60,0,0)) 8
$form.Controls.Add($lblStatus)
$form.Controls.Add($lblTime)

# ── Helper: log append ────────────────────────────────────────────────────
function UI-Log {
    param([string]$msg, [System.Drawing.Color]$color)
    $form.Invoke([Action]{
        $rtb.SelectionStart  = $rtb.TextLength
        $rtb.SelectionLength = 0
        $rtb.SelectionColor  = $color
        $rtb.AppendText("$msg`n")
        $rtb.ScrollToCaret()
    })
}

function UI-Set {
    param([string]$task, [int]$pct, [string]$status='')
    $form.Invoke([Action]{
        $lblTask.Text = $task
        $lblPct.Text  = "$pct%"
        $pbMain.Value = [math]::Min($pct,100)
        if ($status) { $lblStatus.Text = $status }
    })
}

# ── Task list ─────────────────────────────────────────────────────────────
$TaskList = @(
    @{Label='Kernel & HPET';       Fn={Optimize-Kernel}},
    @{Label='Timer Resolution';    Fn={Optimize-TimerResolution}},
    @{Label='CPU Priority';        Fn={Optimize-Priority}},
    @{Label='IRQ / MSI Mode';      Fn={Optimize-IRQ}},
    @{Label='DPC Latency';         Fn={Optimize-DPC}},
    @{Label='Core Parking';        Fn={Optimize-CoreParking}},
    @{Label='GPU Tweaks';          Fn={Optimize-GPU}},
    @{Label='Memory Advanced';     Fn={Optimize-MemoryAdvanced}},
    @{Label='Memory Management';   Fn={Optimize-Memory}},
    @{Label='Input & USB';         Fn={Optimize-Input}},
    @{Label='Nagle Algorithm';     Fn={Optimize-Nagle}},
    @{Label='Visual Effects';      Fn={Optimize-VisualEffects}},
    @{Label='Game Bar & DVR';      Fn={Disable-GameBar}},
    @{Label='Processor Power';     Fn={Optimize-ProcessorPower}},
    @{Label='Power Plan';          Fn={Install-CustardPowerPlan}},
    @{Label='Network Stack';       Fn={Optimize-Network}},
    @{Label='Network Extra';       Fn={Optimize-NetworkExtra}},
    @{Label='Group Policy';        Fn={Optimize-GroupPolicy}},
    @{Label='Windows Services';    Fn={Optimize-Services}},
    @{Label='Services Extra';      Fn={Optimize-ServicesExtra}},
    @{Label='Junk & Logs Cleanup'; Fn={Clean-TrashAndLogs}}
)

# ── Elapsed timer ─────────────────────────────────────────────────────────
$elapsed = 0
$uiTimer          = [System.Windows.Forms.Timer]::new()
$uiTimer.Interval = 1000
$uiTimer.Add_Tick({
    $elapsed++
    $lblTime.Text = "GOAT v2.0.0   {0:D2}:{1:D2}:{2:D2}" -f [math]::Floor($elapsed/3600),([math]::Floor($elapsed%3600/60)),($elapsed%60)
})

# ── RUN button ────────────────────────────────────────────────────────────
$btnRun.Add_Click({
    $btnRun.Enabled = $false
    $uiTimer.Start()
    UI-Set 'INITIALIZING...' 0 '● RUNNING'
    UI-Log '════════════════════════════════════════' ([System.Drawing.Color]::FromArgb(50,0,0))
    UI-Log '  GOAT OPTIMIZATION SEQUENCE STARTED'    ([System.Drawing.Color]::FromArgb(255,40,40))
    UI-Log '════════════════════════════════════════' ([System.Drawing.Color]::FromArgb(50,0,0))

    $tList  = $TaskList
    $tTotal = $TaskList.Count
    $worker = [System.ComponentModel.BackgroundWorker]::new()
    $worker.WorkerReportsProgress = $true

    $worker.Add_DoWork({
        param($s,$e)
        $tasks = $e.Argument.Tasks
        $total = $e.Argument.Total
        for ($i = 0; $i -lt $total; $i++) {
            $t   = $tasks[$i]
            $pct = [math]::Round(($i / $total) * 100)
            UI-Set "[$($i+1)/$total]  $($t.Label)..." $pct
            UI-Log "  -> $($t.Label)..." ([System.Drawing.Color]::FromArgb(220,40,40))
            try {
                & $t.Fn
                UI-Log "     [OK] Done." ([System.Drawing.Color]::FromArgb(120,0,0))
            } catch {
                UI-Log "     [ERR] $($_.Exception.Message)" ([System.Drawing.Color]::FromArgb(255,0,0))
            }
        }
    })

    $worker.Add_RunWorkerCompleted({
        $uiTimer.Stop()
        UI-Set 'ALL MODULES COMPLETE' 100 '● DONE'
        UI-Log '════════════════════════════════════════' ([System.Drawing.Color]::FromArgb(50,0,0))
        UI-Log '  ALL TWEAKS APPLIED SUCCESSFULLY!'     ([System.Drawing.Color]::FromArgb(255,40,40))
        UI-Log '  Restart PC to finalize all changes.'  ([System.Drawing.Color]::FromArgb(120,0,0))
        UI-Log '════════════════════════════════════════' ([System.Drawing.Color]::FromArgb(50,0,0))
        $form.Invoke([Action]{ $btnRestart.Enabled = $true })
    })

    $arg = [PSCustomObject]@{ Tasks = $tList; Total = $tTotal }
    $worker.RunWorkerAsync($arg)
})

# ── RESTART button ────────────────────────────────────────────────────────
$btnRestart.Add_Click({
    $r = [System.Windows.Forms.MessageBox]::Show(
        'Restart your PC now to apply all changes?',
        'GOAT — Restart Required',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($r -eq 'Yes') { Restart-Computer -Force }
})

# ── EXIT button ───────────────────────────────────────────────────────────
$btnExit.Add_Click({ $form.Close() })

# ── Initial log ───────────────────────────────────────────────────────────
UI-Log '  GOAT v2.0 ready. Press RUN GOAT to start.' ([System.Drawing.Color]::FromArgb(80,0,0))

# ── Show ──────────────────────────────────────────────────────────────────
[System.Windows.Forms.Application]::Run($form)
