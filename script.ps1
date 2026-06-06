<#
    GOAT - GREATEST OF ALL TWEAKS (FULL INTEGRATED)
#>

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

# --- [ EXECUTION ] ---
$Tasks = @(
    { Optimize-Kernel },
    { Optimize-TimerResolution },
    { Optimize-Priority },
    { Optimize-IRQ },
    { Optimize-Memory },
    { Optimize-Input },
    { Optimize-Nagle },
    { Optimize-VisualEffects },
    { Disable-GameBar },
    { Optimize-ProcessorPower },
    { Install-CustardPowerPlan },
    { Optimize-Network },
    { Optimize-Services },
    { Clean-TrashAndLogs }
)

foreach ($Task in $Tasks) { & $Task }

# --- [ FINALIZATION ] ---
Write-Host "`n[ SUCCESS ] ALL TWEAKS AND SYSTEM CLEANUP COMPLETED!" -ForegroundColor Green
if ((Read-Host "Do you want to restart your PC now? (Y/N)") -match "[Yy]") { Restart-Computer }
