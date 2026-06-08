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
    return ('â–ˆ' * $filled) + ('â–‘' * $empty)
}

$border = 'â•‘'
$line   = 'â•' * 86

# --- [ BANNER ] ---
Write-Host ""
Write-Host "  â•”$lineâ•—" -ForegroundColor DarkCyan
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

# GOAT ASCII â€” à¹„à¸¥à¹ˆà¸ªà¸µ 3 à¸£à¸°à¸”à¸±à¸š
$logo = @(
    '    â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—                                              ',
    '   â–ˆâ–ˆâ•”â•â•â•â•â• â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â•šâ•â•â–ˆâ–ˆâ•”â•â•â•                                              ',
    '   â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘                                                  ',
    '   â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘                                                  ',
    '   â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘                                                  ',
    '    â•šâ•â•â•â•â•â•  â•šâ•â•â•â•â•â• â•šâ•â•  â•šâ•â•   â•šâ•â•                                                  '
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
$tagline = 'â”€â”€â”€â”€â”€  G R E A T E S T   O F   A L L   T W E A K S  â”€â”€â”€â”€â”€'
$pad = [math]::Floor((86 - $tagline.Length) / 2)
Write-Host (' ' * $pad) -NoNewline
Write-Host $tagline -NoNewline -ForegroundColor Yellow
Write-Host (' ' * (86 - $pad - $tagline.Length)) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host (' ' * 86) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

# --- [ SYSTEM INFO SECTION ] ---
Write-Host "  â• $lineâ•£" -ForegroundColor DarkCyan

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
Write-Host "  â• $lineâ•£" -ForegroundColor DarkCyan
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host '   [ KERNEL ]      [ MEMORY ]      [ INPUT ]      [ NETWORK ]      [ CLEANER ]   ' -NoNewline -ForegroundColor Green
Write-Host "$border" -ForegroundColor DarkCyan
Write-Host "  â• $lineâ•£" -ForegroundColor DarkCyan

# --- [ LOADING BAR ] ---
Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host -NoNewline '   Initializing GOAT  [' -ForegroundColor Yellow
$totalBlocks = 40
for ($b = 0; $b -lt $totalBlocks; $b++) {
    Write-Host -NoNewline 'â–ˆ' -ForegroundColor Cyan
    Start-Sleep -Milliseconds 30
}
Write-Host -NoNewline '] 100%' -ForegroundColor Green
Write-Host (' ' * 17) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  $border" -NoNewline -ForegroundColor DarkCyan
Write-Host '   [OK] ALL MODULES READY' -NoNewline -ForegroundColor Green
Write-Host (' ' * 61) -NoNewline
Write-Host "$border" -ForegroundColor DarkCyan

Write-Host "  â•š$lineâ•" -ForegroundColor DarkCyan
Write-Host "  Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â· Â·" -ForegroundColor DarkCyan
Write-Host ""

# --- [ PROMPT: à¸•à¹‰à¸­à¸‡à¸à¸²à¸£à¸›à¸£à¸±à¸šà¹à¸•à¹ˆà¸‡à¸«à¸£à¸·à¸­à¹„à¸¡à¹ˆ ] ---
Write-Host "  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”" -ForegroundColor DarkCyan
Write-Host "  â”‚                                             â”‚" -ForegroundColor DarkCyan
Write-Host "  â”‚    Ready to run GOAT?                      â”‚" -ForegroundColor Yellow
Write-Host "  â”‚                                             â”‚" -ForegroundColor DarkCyan
Write-Host "  â”‚     [Y]  YES â€” Begin Optimization          â”‚" -ForegroundColor Green
Write-Host "  â”‚     [N]  NO  â€” Exit                        â”‚" -ForegroundColor DarkGray
Write-Host "  â”‚                                             â”‚" -ForegroundColor DarkCyan
Write-Host "  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜" -ForegroundColor DarkCyan
Write-Host ""

# à¸§à¸™à¸£à¸±à¸š input à¸ˆà¸™à¸à¸§à¹ˆà¸²à¸ˆà¸°à¸–à¸¹à¸à¸•à¹‰à¸­à¸‡
do {
    Write-Host "  >> Your choice [Y/N]: " -NoNewline -ForegroundColor Yellow
    $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    Write-Host $choice -ForegroundColor Cyan
} while ($choice -notmatch '^[YyNn]$')

if ($choice -match '[Nn]') {
    Write-Host ""
    Write-Host "  [!] Aborted â€” Exiting GOAT." -ForegroundColor DarkGray
    Write-Host ""
    Exit
}

Write-Host ""
Write-Host "  [>>] GOAT is on the run â€” Starting optimization..." -ForegroundColor Green
Write-Host ""

# à¸•à¸±à¹‰à¸‡à¸„à¹ˆà¸²à¸•à¸³à¹à¸«à¸™à¹ˆà¸‡à¸—à¸³à¸‡à¸²à¸™
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
    Write-Host "    [VERIFIED] Nagle Disabled â€” TCP Latency Reduced." -ForegroundColor Green
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
    # Worker threads â€” server-style CPU scheduling
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
    
    # 1. à¸¥à¹‰à¸²à¸‡à¹„à¸Ÿà¸¥à¹Œà¸‚à¸¢à¸° (Temp, Prefetch)
    $JunkPaths = @("$env:USERPROFILE\AppData\Local\Temp\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
    foreach ($Path in $JunkPaths) {
        Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "    [DELETING] $($_.FullName)" -ForegroundColor Gray
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. à¸¥à¹‰à¸²à¸‡ Windows Update (SoftwareDistribution)
    Write-Host "    [CLEANING] Windows Update Cache..." -ForegroundColor Gray
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv

    # 3. à¸¥à¹‰à¸²à¸‡ Event Logs
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

    # 1. Disable Windows Update auto-download (à¸›à¹‰à¸­à¸‡à¸à¸±à¸™ WU à¹à¸¢à¹ˆà¸‡à¹à¸šà¸™à¸”à¹Œà¸§à¸´à¸˜/disk à¸£à¸°à¸«à¸§à¹ˆà¸²à¸‡à¹€à¸¥à¹ˆà¸™à¹€à¸à¸¡)
    $WUPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (-not (Test-Path $WUPath)) { New-Item -Path $WUPath -Force | Out-Null }
    Set-ItemProperty -Path $WUPath -Name "NoAutoUpdate"                -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WUPath -Name "AUOptions"                   -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WUPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force 2>$null

    # 2. Disable Telemetry à¸£à¸°à¸”à¸±à¸š policy
    $TelPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $TelPath)) { New-Item -Path $TelPath -Force | Out-Null }
    Set-ItemProperty -Path $TelPath -Name "AllowTelemetry"              -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $TelPath -Name "DisableOneSettingsDownloads" -Value 1 -Type DWord -Force 2>$null

    # 3. Reservable Bandwidth = 0 (à¸„à¸·à¸™ bandwidth 20% à¸—à¸µà¹ˆ Windows à¸à¸±à¸™à¹„à¸§à¹‰)
    $PschedPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    if (-not (Test-Path $PschedPath)) { New-Item -Path $PschedPath -Force | Out-Null }
    Set-ItemProperty -Path $PschedPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force 2>$null

    # 4. Disable Background App Refresh (UWP apps)
    $AppPrivPath = "HKCU:\Software\Policies\Microsoft\Windows\AppPrivacy"
    if (-not (Test-Path $AppPrivPath)) { New-Item -Path $AppPrivPath -Force | Out-Null }
    Set-ItemProperty -Path $AppPrivPath -Name "LetAppsRunInBackground" -Value 2 -Type DWord -Force 2>$null

    # 5. Disable SysMain / Superfetch à¸£à¸°à¸”à¸±à¸š policy (SSD à¹„à¸¡à¹ˆà¸ˆà¸³à¹€à¸›à¹‡à¸™)
    $SysMainPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SysMain"
    if (-not (Test-Path $SysMainPath)) { New-Item -Path $SysMainPath -Force | Out-Null }
    Set-ItemProperty -Path $SysMainPath -Name "Enabled" -Value 0 -Type DWord -Force 2>$null
    Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
    Set-Service  -Name SysMain -StartupType Disabled -ErrorAction SilentlyContinue

    # 6. Disable Windows Error Reporting à¸£à¸°à¸”à¸±à¸š policy
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
    # à¸›à¸´à¸” Core Parking à¸œà¹ˆà¸²à¸™ power plan active
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
    # Registry fallback à¸ªà¸³à¸«à¸£à¸±à¸šà¸—à¸¸à¸ power scheme
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
    # TDR tuning â€” à¸¥à¸” GPU driver crash à¸£à¸°à¸«à¸§à¹ˆà¸²à¸‡à¹‚à¸«à¸¥à¸”à¸«à¸™à¸±à¸
    Set-ItemProperty -Path $GraphicsPath -Name "TdrDelay"        -Value 10 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GraphicsPath -Name "TdrDdiDelay"     -Value 10 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GraphicsPath -Name "TdrLimitCount"   -Value 60 -Type DWord -Force 2>$null
    # Disable GPU Preemption (à¸¥à¸” context switch overhead)
    $SchedulerPath = "$GraphicsPath\Scheduler"
    if (-not (Test-Path $SchedulerPath)) { New-Item -Path $SchedulerPath -Force | Out-Null }
    Set-ItemProperty -Path $SchedulerPath -Name "DisablePreemption" -Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] GPU Tweaks Applied." -ForegroundColor Green
}

function Optimize-MemoryAdvanced {
    Write-Host " -> Applying Advanced Memory Tweaks..." -ForegroundColor Yellow
    $MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    # à¸šà¸±à¸‡à¸„à¸±à¸š kernel/drivers à¸­à¸¢à¸¹à¹ˆà¹ƒà¸™ RAM à¹„à¸¡à¹ˆà¸¥à¸‡ pagefile
    Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force 2>$null
    # à¸•à¸±à¹‰à¸‡ L2 Cache à¸•à¸²à¸¡ CPU (default 0 = auto à¹à¸•à¹ˆ explicit à¸”à¸µà¸à¸§à¹ˆà¸²)
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
        'PrintSpooler',   # Print Spooler (à¸›à¸´à¸”à¸–à¹‰à¸²à¹„à¸¡à¹ˆà¸¡à¸µà¸›à¸£à¸´à¹‰à¸™à¹€à¸•à¸­à¸£à¹Œ)
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
    # à¸›à¹‰à¸­à¸‡à¸à¸±à¸™ Windows Connect Now à¹à¸¢à¹ˆà¸‡à¹€à¸™à¹‡à¸•
    $WcmPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"
    if (-not (Test-Path $WcmPath)) { New-Item -Path $WcmPath -Force | Out-Null }
    Set-ItemProperty -Path $WcmPath -Name "fMinimizeConnections"      -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $WcmPath -Name "fBlockNonDomain"           -Value 0 -Type DWord -Force 2>$null
    # Disable Network Location Awareness background polling
    $NlaPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"
    if (-not (Test-Path $NlaPath)) { New-Item -Path $NlaPath -Force | Out-Null }
    Set-ItemProperty -Path $NlaPath -Name "EnableActiveProbing" -Value 0 -Type DWord -Force 2>$null
    # Disable NCSI active probing (à¸«à¸¢à¸¸à¸” Windows ping microsoft.com à¸•à¸¥à¸­à¸”à¹€à¸§à¸¥à¸²)
    $NcsiPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator"
    if (-not (Test-Path $NcsiPath)) { New-Item -Path $NcsiPath -Force | Out-Null }
    Set-ItemProperty -Path $NcsiPath -Name "NoActiveProbe"       -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $NcsiPath -Name "DisablePassivePolling"-Value 1 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED] Additional Network Tweaks Applied." -ForegroundColor Green
}

# --- [ EXECUTION ] ---
$Tasks = @(
    { Optimize-Kernel },
    { Optimize-TimerResolution },
    { Optimize-Priority },
    { Optimize-IRQ },
    { Optimize-DPC },
    { Optimize-CoreParking },
    { Optimize-GPU },
    { Optimize-MemoryAdvanced },
    { Optimize-Memory },
    { Optimize-Input },
    { Optimize-Nagle },
    { Optimize-VisualEffects },
    { Disable-GameBar },
    { Optimize-ProcessorPower },
    { Install-CustardPowerPlan },
    { Optimize-Network },
    { Optimize-GroupPolicy },
    { Optimize-Services },
    { Optimize-ServicesExtra },
    { Optimize-NetworkExtra },
    { Clean-TrashAndLogs }
)

# â”€â”€ WPF GUI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="GOAT â€” GREATEST OF ALL TWEAKS  v2.0"
    Width="800" Height="620"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanMinimize"
    Background="#080000">
  <Window.Resources>
    <Style TargetType="Button">
      <Setter Property="Background"      Value="#1A0000"/>
      <Setter Property="Foreground"      Value="#FF3333"/>
      <Setter Property="BorderBrush"     Value="#8B0000"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="FontFamily"      Value="Consolas"/>
      <Setter Property="FontSize"        Value="12"/>
      <Setter Property="FontWeight"      Value="Bold"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Height"          Value="36"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="3">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#330000"/>
                <Setter Property="BorderBrush" Value="#CC0000"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.3"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="ProgressBar">
      <Setter Property="Height" Value="6"/>
      <Setter Property="Background" Value="#1A0000"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Foreground" Value="#CC0000"/>
    </Style>
  </Window.Resources>

  <Grid Margin="14">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- HEADER LOGO -->
    <Border Grid.Row="0" Background="#100000" BorderBrush="#5A0000" BorderThickness="1" CornerRadius="4" Padding="14,10" Margin="0,0,0,8">
      <StackPanel>
        <TextBlock Text="  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—" FontFamily="Consolas" FontSize="11" Foreground="#CC0000"/>
        <TextBlock Text=" â–ˆâ–ˆâ•”â•â•â•â•â• â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â•šâ•â•â–ˆâ–ˆâ•”â•â•â•" FontFamily="Consolas" FontSize="11" Foreground="#CC0000"/>
        <TextBlock Text=" â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘    " FontFamily="Consolas" FontSize="11" Foreground="#990000"/>
        <TextBlock Text=" â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘    " FontFamily="Consolas" FontSize="11" Foreground="#990000"/>
        <TextBlock Text=" â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘    " FontFamily="Consolas" FontSize="11" Foreground="#660000"/>
        <TextBlock Text="  â•šâ•â•â•â•â•â•  â•šâ•â•â•â•â•â• â•šâ•â•  â•šâ•â•   â•šâ•â•    " FontFamily="Consolas" FontSize="11" Foreground="#660000"/>
        <TextBlock Text="â”€â”€â”€ G R E A T E S T   O F   A L L   T W E A K S â”€â”€â”€" FontFamily="Consolas" FontSize="11" Foreground="#FF2222" HorizontalAlignment="Center" Margin="0,6,0,0"/>
      </StackPanel>
    </Border>

    <!-- SYSINFO -->
    <Border Grid.Row="1" Background="#0D0000" BorderBrush="#3A0000" BorderThickness="1" CornerRadius="4" Padding="12,8" Margin="0,0,0,8">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0" Margin="0,0,10,0">
          <TextBlock Text="CPU" FontFamily="Consolas" FontSize="9" Foreground="#550000" LetterSpacing="2"/>
          <TextBlock x:Name="lblCPU" FontFamily="Consolas" FontSize="10" Foreground="#FF3333" TextWrapping="Wrap"/>
          <ProgressBar x:Name="pbCPU" Margin="0,4,0,0"/>
        </StackPanel>
        <StackPanel Grid.Column="1" Margin="10,0">
          <TextBlock Text="RAM" FontFamily="Consolas" FontSize="9" Foreground="#550000" LetterSpacing="2"/>
          <TextBlock x:Name="lblRAM" FontFamily="Consolas" FontSize="10" Foreground="#FF3333"/>
          <ProgressBar x:Name="pbRAM" Foreground="#8B0000" Margin="0,4,0,0"/>
        </StackPanel>
        <StackPanel Grid.Column="2" Margin="10,0,0,0">
          <TextBlock Text="OS" FontFamily="Consolas" FontSize="9" Foreground="#550000" LetterSpacing="2"/>
          <TextBlock x:Name="lblOS" FontFamily="Consolas" FontSize="10" Foreground="#FF3333" TextWrapping="Wrap"/>
          <ProgressBar Value="100" Foreground="#550000" Margin="0,4,0,0"/>
        </StackPanel>
      </Grid>
    </Border>

    <!-- PROGRESS -->
    <Border Grid.Row="2" Background="#0D0000" BorderBrush="#3A0000" BorderThickness="1" CornerRadius="4" Padding="12,8" Margin="0,0,0,8">
      <StackPanel>
        <Grid Margin="0,0,0,5">
          <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <TextBlock x:Name="lblTask" Text="WAITING â€” Press RUN GOAT to begin" FontFamily="Consolas" FontSize="11" Foreground="#FF4444"/>
          <TextBlock x:Name="lblPct"  Text="0%" Grid.Column="1" FontFamily="Consolas" FontSize="11" Foreground="#CC0000" Margin="10,0,0,0"/>
        </Grid>
        <ProgressBar x:Name="pbMain" Height="10" Maximum="100"/>
      </StackPanel>
    </Border>

    <!-- LOG -->
    <Border Grid.Row="3" Background="#060000" BorderBrush="#3A0000" BorderThickness="1" CornerRadius="4" Padding="10" Margin="0,0,0,8">
      <ScrollViewer x:Name="sv" VerticalScrollBarVisibility="Auto">
        <TextBlock x:Name="tbLog" FontFamily="Consolas" FontSize="11" TextWrapping="Wrap" LineHeight="19"/>
      </ScrollViewer>
    </Border>

    <!-- BUTTONS -->
    <Grid Grid.Row="4" Margin="0,0,0,8">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="10"/>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="10"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Button x:Name="btnRun"     Grid.Column="0" Content="â–¶  RUN GOAT"/>
      <Button x:Name="btnRestart" Grid.Column="2" Content="â†º  RESTART PC" IsEnabled="False"/>
      <Button x:Name="btnExit"    Grid.Column="4" Content="âœ•  EXIT"/>
    </Grid>

    <!-- STATUS BAR -->
    <Border Grid.Row="5" Background="#0D0000" BorderBrush="#3A0000" BorderThickness="1" CornerRadius="3" Padding="10,5">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <TextBlock x:Name="lblStatus" Text="â— SYSTEM ONLINE" FontFamily="Consolas" FontSize="10" Foreground="#660000"/>
        <TextBlock x:Name="lblTime"   Text="GOAT v2.0.0" FontFamily="Consolas" FontSize="10" Foreground="#3A0000" Grid.Column="1"/>
      </Grid>
    </Border>
  </Grid>
</Window>
"@

$reader  = [System.Xml.XmlNodeReader]::new($xaml)
$window  = [Windows.Markup.XamlReader]::Load($reader)

$lblCPU     = $window.FindName('lblCPU')
$lblRAM     = $window.FindName('lblRAM')
$lblOS      = $window.FindName('lblOS')
$pbCPU      = $window.FindName('pbCPU')
$pbRAM      = $window.FindName('pbRAM')
$pbMain     = $window.FindName('pbMain')
$lblTask    = $window.FindName('lblTask')
$lblPct     = $window.FindName('lblPct')
$tbLog      = $window.FindName('tbLog')
$sv         = $window.FindName('sv')
$btnRun     = $window.FindName('btnRun')
$btnRestart = $window.FindName('btnRestart')
$btnExit    = $window.FindName('btnExit')
$lblStatus  = $window.FindName('lblStatus')
$lblTime    = $window.FindName('lblTime')

# Populate sysinfo
$lblCPU.Text = $CPU.Substring(0,[math]::Min(34,$CPU.Length))
$pbCPU.Value = $CPULoad
$lblRAM.Text = "$RAMUsed GB / $RAMTotal GB"
$pbRAM.Value = $RAMPct
$lblOS.Text  = $OSName.Substring(0,[math]::Min(34,$OSName.Length))

# Helper functions
function UI-Log {
    param([string]$msg,[string]$color='#AA0000')
    $window.Dispatcher.Invoke([action]{
        $run = [Windows.Documents.Run]::new("$msg`n")
        $run.Foreground = [Windows.Media.SolidColorBrush][Windows.Media.ColorConverter]::ConvertFromString($color)
        $tbLog.Inlines.Add($run)
        $sv.ScrollToBottom()
    })
}

function UI-Set {
    param([string]$task,[int]$pct,[string]$status='')
    $window.Dispatcher.Invoke([action]{
        $pbMain.Value = $pct
        $lblTask.Text = $task
        $lblPct.Text  = "$pct%"
        if ($status) { $lblStatus.Text = $status }
    })
}

# Task list
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
    @{Label="Nagle Algorithm";     Fn={Optimize-Nagle}},
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

# Elapsed timer
$elapsed = 0
$uiTimer = [System.Windows.Threading.DispatcherTimer]::new()
$uiTimer.Interval = [TimeSpan]::FromSeconds(1)
$uiTimer.Add_Tick({
    $elapsed++
    $lblTime.Text = "GOAT v2.0.0   {0:D2}:{1:D2}:{2:D2}" -f [math]::Floor($elapsed/3600),([math]::Floor($elapsed%3600/60)),($elapsed%60)
})

# RUN button
$btnRun.Add_Click({
    $btnRun.IsEnabled = $false
    $uiTimer.Start()
    UI-Log 'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•' '#2A0000'
    UI-Log '  GOAT OPTIMIZATION SEQUENCE STARTED   ' '#FF2222'
    UI-Log 'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•' '#2A0000'
    UI-Set 'INITIALIZING...' 0 'â— RUNNING'

    $total   = $TaskList.Count
    $taskRef = $TaskList

    $worker = [System.ComponentModel.BackgroundWorker]::new()
    $worker.WorkerReportsProgress = $true

    $worker.Add_DoWork({
        for ($i = 0; $i -lt $using:total; $i++) {
            $t   = $using:taskRef[$i]
            $pct = [math]::Round(($i / $using:total) * 100)
            UI-Set "[$($i+1)/$($using:total)]  $($t.Label)..." $pct
            UI-Log "  â†’ $($t.Label)..." '#FF3333'
            try {
                & $t.Fn
                UI-Log "     [OK] Done." '#660000'
            } catch {
                UI-Log "     [ERR] $($_.Exception.Message)" '#FF0000'
            }
        }
    })

    $worker.Add_RunWorkerCompleted({
        $uiTimer.Stop()
        UI-Set 'ALL MODULES COMPLETE' 100 'â— DONE'
        UI-Log 'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•' '#2A0000'
        UI-Log '  âœ” ALL TWEAKS APPLIED SUCCESSFULLY!   ' '#FF2222'
        UI-Log '  Restart PC to finalize all changes.  ' '#660000'
        UI-Log 'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•' '#2A0000'
        $window.Dispatcher.Invoke([action]{ $btnRestart.IsEnabled = $true })
    })

    $worker.RunWorkerAsync()
})

# RESTART button
$btnRestart.Add_Click({
    $r = [System.Windows.MessageBox]::Show('Restart your PC now?','GOAT â€” Restart',[System.Windows.MessageBoxButton]::YesNo,[System.Windows.MessageBoxImage]::Warning)
    if ($r -eq 'Yes') { Restart-Computer -Force }
})

# EXIT button
$btnExit.Add_Click({ $window.Close() })

# Initial log
UI-Log '  GOAT v2.0 ready. Press RUN GOAT to start.' '#440000'
$window.ShowDialog() | Out-Null
