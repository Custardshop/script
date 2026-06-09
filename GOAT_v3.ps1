#Requires -Version 5.1

<#
GOAT - GREATEST OF ALL TWEAKS
GUI Edition v4.0 - Horizontal Grid + Live Log
#>

# ── ADMIN AUTO-ELEVATE ─────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo "powershell"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    try { [System.Diagnostics.Process]::Start($psi) | Out-Null } catch {}
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ── SYSTEM INFO ────────────────────────────────────────────────────────────
$CPU      = (Get-CimInstance Win32_Processor).Name
$RAMTotal = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$RAMFree  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$RAMUsed  = [math]::Round($RAMTotal - $RAMFree, 1)
$RAMPct   = [math]::Round(($RAMUsed / $RAMTotal) * 100)
$OSName   = (Get-CimInstance Win32_OperatingSystem).Caption
$UserName = $env:USERNAME
$PCName   = $env:COMPUTERNAME
$GPU      = (Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" -and $_.Name -notlike "*Remote*" } | Select-Object -First 1).Name
if (-not $GPU) { $GPU = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name }

$CPUShort  = if ($CPU.Length -gt 34) { $CPU.Substring(0,34)+"…" } else { $CPU }
$GPUShort  = if ($GPU.Length -gt 34) { $GPU.Substring(0,34)+"…" } else { $GPU }
$OSShort   = if ($OSName.Length -gt 34) { $OSName.Substring(0,34)+"…" } else { $OSName }

# ── COLORS ─────────────────────────────────────────────────────────────────
$cBg        = [System.Drawing.Color]::FromArgb(10, 10, 10)
$cSurface   = [System.Drawing.Color]::FromArgb(18, 18, 18)
$cSurface2  = [System.Drawing.Color]::FromArgb(24, 24, 24)
$cBorder    = [System.Drawing.Color]::FromArgb(38, 38, 38)
$cBorderDim = [System.Drawing.Color]::FromArgb(26, 26, 26)
$cWhite     = [System.Drawing.Color]::FromArgb(240, 240, 240)
$cWhiteDim  = [System.Drawing.Color]::FromArgb(160, 160, 160)
$cGray      = [System.Drawing.Color]::FromArgb(90, 90, 90)
$cGrayDim   = [System.Drawing.Color]::FromArgb(50, 50, 50)
$cDoneText  = [System.Drawing.Color]::FromArgb(100, 100, 100)
$cLogKey    = [System.Drawing.Color]::FromArgb(130, 130, 130)
$cLogVal    = [System.Drawing.Color]::FromArgb(75, 75, 75)
$cLogHead   = [System.Drawing.Color]::FromArgb(180, 180, 180)
$cGreen     = [System.Drawing.Color]::FromArgb(130, 180, 100)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fMono8     = New-Object System.Drawing.Font("Consolas", 8)
$fMono9     = New-Object System.Drawing.Font("Consolas", 9)
$fMono10    = New-Object System.Drawing.Font("Consolas", 10)
$fMonoBold9 = New-Object System.Drawing.Font("Consolas", 9,  [System.Drawing.FontStyle]::Bold)
$fMonoBold  = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$fLogo      = New-Object System.Drawing.Font("Arial Black", 38, [System.Drawing.FontStyle]::Bold)

# ── LOG SYSTEM ─────────────────────────────────────────────────────────────
$script:LogLines = [System.Collections.Generic.List[hashtable]]::new()

function Write-Log {
    param([string]$Module, [string]$Action, [string]$Detail = "")
    $ts = (Get-Date).ToString("HH:mm:ss")
    $script:LogLines.Add(@{ Time = $ts; Module = $Module; Action = $Action; Detail = $Detail })
    # Trigger log panel refresh (called from UI thread via timer)
}

# ── TASK DEFINITIONS ───────────────────────────────────────────────────────
# Each task has: Label, Description (shown in card), Icon char
$script:Tasks = [ordered]@{
    "kernel"   = @{ Label = "Kernel & HPET";      Desc = "Boot clock, tick policy, TSC sync, HPET disable" }
    "timer"    = @{ Label = "Timer Resolution";   Desc = "GlobalTimerResolutionRequests → 1 ms precision" }
    "priority" = @{ Label = "Process Priority";   Desc = "Win32PrioritySeparation, Games profile, SFIO High" }
    "irq"      = @{ Label = "IRQ MSI Mode";        Desc = "Enable MSI for all PCI devices to reduce latency" }
    "memory"   = @{ Label = "Memory Mgmt";        Desc = "Prefetcher, Superfetch off, OneDrive, hibernate off" }
    "input"    = @{ Label = "Input & USB";         Desc = "Mouse accel off, queue sizes, USB selective suspend" }
    "nagle"    = @{ Label = "Nagle Algorithm";    Desc = "TcpAckFrequency=1, TCPNoDelay per interface" }
    "visual"   = @{ Label = "Visual Effects";     Desc = "VisualFXSetting=2, animations & transitions off" }
    "gamebar"  = @{ Label = "Game Bar & DVR";     Desc = "AppCapture off, FSEBehaviorMode, policy disable" }
    "power"    = @{ Label = "Processor Power";    Desc = "ProcThrottle min/max = 100%, apply active scheme" }
    "network"  = @{ Label = "Network & DNS";      Desc = "RSS, TCP tuning, Winsock reset, DNS flush, renew" }
    "services" = @{ Label = "Windows Services";   Desc = "Disable telemetry/Xbox, ensure audio/net running" }
    "cleanup"  = @{ Label = "Junk Cleanup";       Desc = "Temp files, Prefetch, SoftwareDist, event logs" }
}

$script:FnMap = [ordered]@{
    "kernel"   = "Invoke-Kernel"
    "timer"    = "Invoke-TimerResolution"
    "priority" = "Invoke-Priority"
    "irq"      = "Invoke-IRQ"
    "memory"   = "Invoke-Memory"
    "input"    = "Invoke-Input"
    "nagle"    = "Invoke-Nagle"
    "visual"   = "Invoke-VisualEffects"
    "gamebar"  = "Invoke-GameBar"
    "power"    = "Invoke-ProcessorPower"
    "network"  = "Invoke-Network"
    "services" = "Invoke-Services"
    "cleanup"  = "Invoke-Cleanup"
}

# ── OPTIMIZATION FUNCTIONS (with logging) ─────────────────────────────────

function Invoke-Kernel {
    Write-Log "KERNEL" "bcdedit useplatformclock" "→ no"
    bcdedit /set useplatformclock no 2>$null | Out-Null
    Write-Log "KERNEL" "bcdedit useplatformtick" "→ yes"
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    Write-Log "KERNEL" "bcdedit disabledynamictick" "→ yes"
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    Write-Log "KERNEL" "bcdedit tscsyncpolicy" "→ Enhanced"
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    Write-Log "KERNEL" "bcdedit nx" "→ OptOut"
    bcdedit /set nx OptOut 2>$null | Out-Null
    Write-Log "KERNEL" "bcdedit synthetictimers" "→ yes"
    bcdedit /set synthetictimers yes 2>$null | Out-Null
    $h = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like "*High Precision*" }
    if ($h) {
        Write-Log "KERNEL" "HPET device" "→ Disabled"
        Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    } else {
        Write-Log "KERNEL" "HPET device" "→ not found / already off"
    }
}

function Invoke-TimerResolution {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    Write-Log "TIMER" "GlobalTimerResolutionRequests" "→ 1 (HKLM\...\kernel)"
    Set-ItemProperty -Path $path -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
}

function Invoke-IRQ {
    $count = 0
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $p) {
            Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null
            $count++
        }
    }
    Write-Log "IRQ" "MSISupported = 1" "→ applied to $count PCI device(s)"
}

function Invoke-Nagle {
    $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    $count = 0
    Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
        $count++
    }
    Write-Log "NAGLE" "TcpAckFrequency=1, TCPNoDelay=1, TcpDelAckTicks=0" "→ $count interface(s)"
}

function Invoke-VisualEffects {
    $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
    Write-Log "VISUAL" "VisualFXSetting" "→ 2 (Custom/Performance)"
    Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Write-Log "VISUAL" "UserPreferencesMask" "→ animations off (0x90,0x12,0x03...)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Write-Log "VISUAL" "MinAnimate" "→ 0 (window minimize anim off)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Write-Log "VISUAL" "TaskbarAnimations" "→ 0"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
}

function Invoke-GameBar {
    Write-Log "GAMEBAR" "AppCaptureEnabled" "→ 0"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
    Write-Log "GAMEBAR" "GameDVR_Enabled" "→ 0"
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
    Write-Log "GAMEBAR" "GameDVR_FSEBehaviorMode" "→ 2"
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
    $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Write-Log "GAMEBAR" "AllowGameDVR (Policy)" "→ 0 (disabled)"
    Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
}

function Invoke-ProcessorPower {
    Write-Log "POWER" "PROCTHROTTLEMIN" "→ 100%"
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    Write-Log "POWER" "PROCTHROTTLEMAX" "→ 100%"
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    Write-Log "POWER" "Active power scheme" "→ applied (SCHEME_CURRENT)"
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
}

function Invoke-Priority {
    $pp = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $sp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $gp = "$sp\Tasks\Games"
    $ep = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"
    Write-Log "PRIORITY" "Win32PrioritySeparation" "→ 0x2A (foreground boost)"
    Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Write-Log "PRIORITY" "SvcHostSplitThresholdInKB" "→ 32 GB (prevent svchost split)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Write-Log "PRIORITY" "SystemResponsiveness" "→ 0 (game mode)"
    Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null
    Write-Log "PRIORITY" "NetworkThrottlingIndex" "→ 0xFFFFFFFF (disabled)"
    Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    Write-Log "PRIORITY" "AdditionalCriticalWorkerThreads" "→ +2"
    Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Write-Log "PRIORITY" "Tasks\Games GPU Priority" "→ 8, CPU Priority → 6"
    Set-ItemProperty -Path $gp -Name "GPU Priority"        -Value 8      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Priority"            -Value 6      -Type DWord  -Force 2>$null
    Write-Log "PRIORITY" "Tasks\Games Scheduling Category" "→ High, SFIO → High"
    Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null
    Set-ItemProperty -Path $gp -Name "SFIO Priority"       -Value "High" -Type String -Force 2>$null
}

function Invoke-Memory {
    $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Write-Log "MEMORY" "SystemCacheDirtyPageThreshold" "→ 0 (unlimited cache flush)"
    Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Write-Log "MEMORY" "ClearPageFileAtShutdown" "→ 0 (faster shutdown)"
    Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null
    Write-Log "MEMORY" "EnablePrefetcher" "→ 3 (app + boot)"
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Write-Log "MEMORY" "EnableSuperfetch (SysMain)" "→ 0 (disabled)"
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
    Write-Log "MEMORY" "Hibernate" "→ off (powercfg -h off)"
    powercfg -h off 2>$null | Out-Null
    Write-Log "MEMORY" "OneDrive.exe" "→ killed + removed from Run key"
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
}

function Invoke-Input {
    Write-Log "INPUT" "MouseDataQueueSize" "→ 16"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Write-Log "INPUT" "KeyboardDataQueueSize" "→ 16"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }
    Write-Log "INPUT" "PowerThrottlingOff" "→ 1 (disable power throttle)"
    Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Write-Log "INPUT" "MouseSpeed/Threshold1/Threshold2" "→ 0 (accel off)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed"      -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"  -Type String -Force 2>$null
    Write-Log "INPUT" "KeyboardDelay=0, KeyboardSpeed=31" "→ fastest repeat"
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null
    Write-Log "INPUT" "USB DisableSelectiveSuspend" "→ 1 (always on)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Write-Log "INPUT" "HidUsb IdleEnable" "→ 0"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
}

function Invoke-Network {
    Write-Log "NETWORK" "TCP RSS" "→ enabled"
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    Write-Log "NETWORK" "autotuninglevel" "→ normal"
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    Write-Log "NETWORK" "timestamps" "→ disabled"
    netsh int tcp set global timestamps=disabled 2>$null | Out-Null
    Write-Log "NETWORK" "chimney offload" "→ disabled"
    netsh int tcp set global chimney=disabled 2>$null | Out-Null
    $tp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Write-Log "NETWORK" "TCPNoDelay=1, TcpAckFrequency=1" "→ global Tcpip params"
    Set-ItemProperty -Path $tp -Name "TCPNoDelay"      -Value 1  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1  -Type DWord -Force 2>$null
    Write-Log "NETWORK" "DefaultTTL" "→ 64"
    Set-ItemProperty -Path $tp -Name "DefaultTTL"      -Value 64 -Type DWord -Force 2>$null
    Write-Log "NETWORK" "DNS cache" "→ flushed"
    Clear-DnsClientCache -ErrorAction SilentlyContinue | Out-Null
    Write-Log "NETWORK" "Winsock + IP stack" "→ reset"
    netsh winsock reset 2>$null | Out-Null
    netsh int ip reset  2>$null | Out-Null
    Write-Log "NETWORK" "IP lease" "→ release + renew"
    ipconfig /release 2>$null | Out-Null
    ipconfig /renew   2>$null | Out-Null
    Write-Log "NETWORK" "Physical adapters" "→ restarted"
    Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue
}

function Invoke-Services {
    $disable = @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')
    $disable | ForEach-Object {
        Write-Log "SERVICES" "Disable: $_" "→ Stopped + StartupType=Disabled"
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    $ensure = @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')
    $ensure | ForEach-Object {
        Write-Log "SERVICES" "Ensure running: $_" "→ Automatic + Started"
        Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
}

function Invoke-Cleanup {
    $paths = @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")
    $paths | ForEach-Object {
        Write-Log "CLEANUP" "Delete files" "→ $_"
        Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Log "CLEANUP" "SoftwareDistribution" "→ cleared (wuauserv stopped)"
    Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Log "CLEANUP" "Windows Event Logs" "→ all logs cleared via wevtutil"
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
}

# ── LAYOUT CONSTANTS ───────────────────────────────────────────────────────
# Form: 1300 × 820
# Left pane (cards): 820px wide
# Right pane (log):  460px wide
# Card grid: 4 columns × 4 rows (13 cards, last slot = summary/run)

$formW   = 1300
$formH   = 820
$leftW   = 820
$rightW  = $formW - $leftW           # 480
$topH    = 120                        # header strip
$footH   = 64
$gridTop = $topH
$gridH   = $formH - $topH - $footH  # 636
$cols    = 4
$rows_n  = 4
$cardW   = [int]($leftW / $cols)     # 205
$cardH   = [int]($gridH / $rows_n)   # 159

# ── FORM ───────────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT v4.0 — Greatest of All Tweaks"
$form.Size            = New-Object System.Drawing.Size($formW, $formH)
$form.MinimumSize     = New-Object System.Drawing.Size($formW, $formH)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false
$form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── TOP HEADER ─────────────────────────────────────────────────────────────
$header = New-Object System.Windows.Forms.Panel
$header.Location  = New-Object System.Drawing.Point(0, 0)
$header.Size      = New-Object System.Drawing.Size($leftW, $topH)
$header.BackColor = $cSurface

$header.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # Logo outline
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $sf = [System.Drawing.StringFormat]::GenericDefault
    $gp.AddString("GOAT", $fLogo.FontFamily, [int][System.Drawing.FontStyle]::Bold, $g.DpiY * 38 / 72, [System.Drawing.PointF]::new(18, 12), $sf)
    $outPen = New-Object System.Drawing.Pen($cWhite, 1.1)
    $g.DrawPath($outPen, $gp)
    $outPen.Dispose(); $gp.Dispose()

    # Subtitle
    $br = New-Object System.Drawing.SolidBrush($cGray)
    $f  = New-Object System.Drawing.Font("Consolas", 8)
    $g.DrawString("GREATEST OF ALL TWEAKS  ·  v4.0", $f, $br, 22, 92)
    $br.Dispose(); $f.Dispose()

    # Sys info (right side of header)
    $lbr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45,45,45))
    $vbr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95,95,95))
    $sf2 = New-Object System.Drawing.StringFormat
    $sf2.Alignment = [System.Drawing.StringAlignment]::Far
    $f2 = New-Object System.Drawing.Font("Consolas", 8)
    $rx  = $s.Width - 18

    $g.DrawString("CPU",  $f2, $lbr, $rx - 230, 16,  $sf2)
    $g.DrawString($CPUShort, $f2, $vbr, $rx, 16, $sf2)
    $g.DrawString("GPU",  $f2, $lbr, $rx - 230, 34, $sf2)
    $g.DrawString($GPUShort, $f2, $vbr, $rx, 34, $sf2)
    $g.DrawString("RAM",  $f2, $lbr, $rx - 230, 52, $sf2)
    $g.DrawString("$RAMUsed / $RAMTotal GB  ($RAMPct%)", $f2, $vbr, $rx, 52, $sf2)
    $g.DrawString("OS",   $f2, $lbr, $rx - 230, 70, $sf2)
    $g.DrawString($OSShort, $f2, $vbr, $rx, 70, $sf2)
    $g.DrawString("USER", $f2, $lbr, $rx - 230, 88, $sf2)
    $g.DrawString("$UserName @ $PCName", $f2, $vbr, $rx, 88, $sf2)

    # divider line
    $dp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(28,28,28), 1)
    $g.DrawLine($dp, $s.Width - 290, 8, $s.Width - 290, $s.Height - 10)
    $dp.Dispose()

    $lbr.Dispose(); $vbr.Dispose(); $f2.Dispose(); $sf2.Dispose()

    # Bottom border
    $bp = New-Object System.Drawing.Pen($cBorder, 1)
    $g.DrawLine($bp, 0, $s.Height - 1, $s.Width, $s.Height - 1)
    $bp.Dispose()
})

$form.Controls.Add($header)

# ── SCANLINE ON HEADER ─────────────────────────────────────────────────────
$script:ScanY = -2
$scanTimer = New-Object System.Windows.Forms.Timer
$scanTimer.Interval = 18
$scanTimer.Add_Tick({
    $script:ScanY += 3
    if ($script:ScanY -gt $header.Height + 4) { $script:ScanY = -2 }
    $header.Invalidate()
})
$scanTimer.Start()

# ── CARD GRID PANEL ────────────────────────────────────────────────────────
$gridPanel = New-Object System.Windows.Forms.Panel
$gridPanel.Location  = New-Object System.Drawing.Point(0, $topH)
$gridPanel.Size      = New-Object System.Drawing.Size($leftW, $gridH)
$gridPanel.BackColor = $cBg
$form.Controls.Add($gridPanel)

# ── FOOTER ─────────────────────────────────────────────────────────────────
$footer = New-Object System.Windows.Forms.Panel
$footer.Location  = New-Object System.Drawing.Point(0, ($topH + $gridH))
$footer.Size      = New-Object System.Drawing.Size($leftW, $footH)
$footer.BackColor = $cSurface
$footer.Add_Paint({
    param($s,$e)
    $p = New-Object System.Drawing.Pen($cBorder, 1)
    $e.Graphics.DrawLine($p, 0, 0, $s.Width, 0)
    $p.Dispose()
})
$form.Controls.Add($footer)

# Progress bar track
$progTrack = New-Object System.Windows.Forms.Panel
$progTrack.Location  = New-Object System.Drawing.Point(18, 14)
$progTrack.Size      = New-Object System.Drawing.Size(440, 6)
$progTrack.BackColor = $cBorderDim
$footer.Controls.Add($progTrack)

$progFill = New-Object System.Windows.Forms.Panel
$progFill.Location  = New-Object System.Drawing.Point(0, 0)
$progFill.Size      = New-Object System.Drawing.Size(0, 6)
$progFill.BackColor = $cWhite
$progTrack.Controls.Add($progFill)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text      = "READY  ·  13 modules  ·  0%"
$lblStatus.Font      = $fMono8
$lblStatus.ForeColor = $cWhiteDim
$lblStatus.AutoSize  = $false
$lblStatus.Size      = New-Object System.Drawing.Size(450, 16)
$lblStatus.Location  = New-Object System.Drawing.Point(18, 30)
$lblStatus.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblStatus)

$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text      = "Run GOAT to apply all optimizations. A system restart is recommended after."
$lblHint.Font      = $fMono8
$lblHint.ForeColor = $cGrayDim
$lblHint.AutoSize  = $false
$lblHint.Size      = New-Object System.Drawing.Size(450, 14)
$lblHint.Location  = New-Object System.Drawing.Point(18, 48)
$lblHint.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblHint)

# Buttons
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART"
$btnRestart.Font      = $fMono9
$btnRestart.ForeColor = $cGray
$btnRestart.BackColor = $cSurface2
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cBorder
$btnRestart.FlatAppearance.BorderSize  = 1
$btnRestart.Size     = New-Object System.Drawing.Size(90, 32)
$btnRestart.Location = New-Object System.Drawing.Point(618, 16)
$btnRestart.Visible  = $false
$btnRestart.Add_Click({
    $ans = [System.Windows.Forms.MessageBox]::Show("Restart now?","GOAT",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if ($ans -eq [System.Windows.Forms.DialogResult]::Yes) { Restart-Computer -Force }
})
$footer.Controls.Add($btnRestart)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "RUN GOAT"
$btnRun.Font      = $fMonoBold9
$btnRun.ForeColor = $cBg
$btnRun.BackColor = $cWhite
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Size     = New-Object System.Drawing.Size(100, 32)
$btnRun.Location = New-Object System.Drawing.Point(720, 16)
$footer.Controls.Add($btnRun)

# ── RIGHT PANEL — LOG ──────────────────────────────────────────────────────
$logPanel = New-Object System.Windows.Forms.Panel
$logPanel.Location  = New-Object System.Drawing.Point($leftW, 0)
$logPanel.Size      = New-Object System.Drawing.Size($rightW, $formH)
$logPanel.BackColor = $cSurface
$form.Controls.Add($logPanel)

$logPanel.Add_Paint({
    param($s,$e)
    $p = New-Object System.Drawing.Pen($cBorder, 1)
    $e.Graphics.DrawLine($p, 0, 0, 0, $s.Height)
    $p.Dispose()
})

# Log header
$logHeader = New-Object System.Windows.Forms.Label
$logHeader.Text      = "ACTIVITY LOG"
$logHeader.Font      = $fMono8
$logHeader.ForeColor = $cGrayDim
$logHeader.AutoSize  = $false
$logHeader.Size      = New-Object System.Drawing.Size($rightW - 30, 36)
$logHeader.Location  = New-Object System.Drawing.Point(18, 0)
$logHeader.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$logHeader.BackColor = [System.Drawing.Color]::Transparent
$logPanel.Controls.Add($logHeader)

$logHeaderLine = New-Object System.Windows.Forms.Panel
$logHeaderLine.Location  = New-Object System.Drawing.Point(0, 35)
$logHeaderLine.Size      = New-Object System.Drawing.Size($rightW, 1)
$logHeaderLine.BackColor = $cBorder
$logPanel.Controls.Add($logHeaderLine)

# Log RichTextBox (custom styled)
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location        = New-Object System.Drawing.Point(0, 36)
$logBox.Size            = New-Object System.Drawing.Size($rightW, ($formH - 36 - 36))
$logBox.BackColor       = $cSurface
$logBox.ForeColor       = $cLogKey
$logBox.Font            = $fMono8
$logBox.ReadOnly        = $true
$logBox.BorderStyle     = [System.Windows.Forms.BorderStyle]::None
$logBox.ScrollBars      = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$logBox.WordWrap        = $true
$logBox.Padding         = New-Object System.Windows.Forms.Padding(10)
$logPanel.Controls.Add($logBox)

# Log footer (clear button)
$btnClearLog = New-Object System.Windows.Forms.Button
$btnClearLog.Text      = "CLEAR LOG"
$btnClearLog.Font      = $fMono8
$btnClearLog.ForeColor = $cGrayDim
$btnClearLog.BackColor = $cSurface2
$btnClearLog.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClearLog.FlatAppearance.BorderColor = $cBorderDim
$btnClearLog.FlatAppearance.BorderSize  = 1
$btnClearLog.Size     = New-Object System.Drawing.Size(90, 24)
$btnClearLog.Location = New-Object System.Drawing.Point(($rightW - 108), ($formH - 34))
$btnClearLog.Add_Click({
    $script:LogLines.Clear()
    $logBox.Clear()
})
$logPanel.Controls.Add($btnClearLog)

$lblLogCount = New-Object System.Windows.Forms.Label
$lblLogCount.Text      = "0 entries"
$lblLogCount.Font      = $fMono8
$lblLogCount.ForeColor = $cGrayDim
$lblLogCount.AutoSize  = $false
$lblLogCount.Size      = New-Object System.Drawing.Size(120, 24)
$lblLogCount.Location  = New-Object System.Drawing.Point(16, ($formH - 34))
$lblLogCount.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblLogCount.BackColor = [System.Drawing.Color]::Transparent
$logPanel.Controls.Add($lblLogCount)

# ── HELPER: APPEND TO LOG BOX ─────────────────────────────────────────────
function Append-LogEntry {
    param([hashtable]$entry)
    $logBox.SelectionStart  = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor  = [System.Drawing.Color]::FromArgb(42,42,42)
    $logBox.AppendText("$($entry.Time)  ")
    $logBox.SelectionColor  = $cLogHead
    $logBox.AppendText("[$($entry.Module)]  ")
    $logBox.SelectionColor  = $cLogKey
    $logBox.AppendText("$($entry.Action)")
    if ($entry.Detail -ne "") {
        $logBox.SelectionColor = $cLogVal
        $logBox.AppendText("  $($entry.Detail)")
    }
    $logBox.AppendText("`n")
    $logBox.ScrollToCaret()
    $lblLogCount.Text = "$($script:LogLines.Count) entries"
}

# ── BUILD CARD GRID ────────────────────────────────────────────────────────
$script:CardControls = @{}
$taskKeys = @($script:Tasks.Keys)

for ($i = 0; $i -lt $taskKeys.Count; $i++) {
    $key   = $taskKeys[$i]
    $info  = $script:Tasks[$key]
    $col   = $i % $cols
    $row   = [int]($i / $cols)
    $cx    = $col * $cardW
    $cy    = $row * $cardH

    $card = New-Object System.Windows.Forms.Panel
    $card.Location  = New-Object System.Drawing.Point($cx, $cy)
    $card.Size      = New-Object System.Drawing.Size($cardW, $cardH)
    $card.BackColor = $cBg
    $card.Tag       = "pending"
    $gridPanel.Controls.Add($card)

    # Card paint
    $cardRef = $card
    $card.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $state = $s.Tag
        $r = New-Object System.Drawing.Rectangle(1, 1, $s.Width - 2, $s.Height - 2)
        switch ($state) {
            "running" {
                $fillBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20,20,20))
                $g.FillRectangle($fillBr, $r)
                $fillBr.Dispose()
                $borderPen = New-Object System.Drawing.Pen($cWhiteDim, 1)
                $g.DrawRectangle($borderPen, $r)
                $borderPen.Dispose()
            }
            "done" {
                $fillBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(14,14,14))
                $g.FillRectangle($fillBr, $r)
                $fillBr.Dispose()
                $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(32,32,32), 1)
                $g.DrawRectangle($borderPen, $r)
                $borderPen.Dispose()
            }
            default {
                $borderPen = New-Object System.Drawing.Pen($cBorderDim, 1)
                $g.DrawRectangle($borderPen, $r)
                $borderPen.Dispose()
            }
        }
    })

    # Index label (top-left, small)
    $lblIdx = New-Object System.Windows.Forms.Label
    $lblIdx.Text      = ($i + 1).ToString("00")
    $lblIdx.Font      = $fMono8
    $lblIdx.ForeColor = $cGrayDim
    $lblIdx.AutoSize  = $false
    $lblIdx.Size      = New-Object System.Drawing.Size(30, 18)
    $lblIdx.Location  = New-Object System.Drawing.Point(10, 10)
    $lblIdx.BackColor = [System.Drawing.Color]::Transparent
    $card.Controls.Add($lblIdx)

    # Status dot (top-right)
    $dot = New-Object System.Windows.Forms.Panel
    $dot.Size      = New-Object System.Drawing.Size(8, 8)
    $dot.Location  = New-Object System.Drawing.Point(($cardW - 18), 13)
    $dot.BackColor = [System.Drawing.Color]::Transparent
    $dot.Tag       = "pending"
    $dot.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        switch ($s.Tag) {
            "pending" {
                $p = New-Object System.Drawing.Pen($cGrayDim, 1)
                $g.DrawEllipse($p, 0, 0, 6, 6)
                $p.Dispose()
            }
            "running" {
                $br = New-Object System.Drawing.SolidBrush($cWhite)
                $g.FillEllipse($br, 0, 0, 6, 6)
                $br.Dispose()
            }
            "done" {
                $br = New-Object System.Drawing.SolidBrush($cGray)
                $g.FillEllipse($br, 0, 0, 6, 6)
                $br.Dispose()
            }
        }
    })
    $card.Controls.Add($dot)

    # Module name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $info.Label
    $lblName.Font      = $fMonoBold9
    $lblName.ForeColor = $cGrayDim
    $lblName.AutoSize  = $false
    $lblName.Size      = New-Object System.Drawing.Size(($cardW - 20), 20)
    $lblName.Location  = New-Object System.Drawing.Point(10, 38)
    $lblName.BackColor = [System.Drawing.Color]::Transparent
    $card.Controls.Add($lblName)

    # Description
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text      = $info.Desc
    $lblDesc.Font      = New-Object System.Drawing.Font("Consolas", 7)
    $lblDesc.ForeColor = $cGrayDim
    $lblDesc.AutoSize  = $false
    $lblDesc.Size      = New-Object System.Drawing.Size(($cardW - 20), 52)
    $lblDesc.Location  = New-Object System.Drawing.Point(10, 62)
    $lblDesc.BackColor = [System.Drawing.Color]::Transparent
    $card.Controls.Add($lblDesc)

    # Progress bar
    $barTrack = New-Object System.Windows.Forms.Panel
    $barTrack.Location  = New-Object System.Drawing.Point(10, ($cardH - 28))
    $barTrack.Size      = New-Object System.Drawing.Size(($cardW - 20), 3)
    $barTrack.BackColor = $cBorderDim
    $card.Controls.Add($barTrack)

    $barFill = New-Object System.Windows.Forms.Panel
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barFill.Size      = New-Object System.Drawing.Size(0, 3)
    $barFill.BackColor = $cWhite
    $barTrack.Controls.Add($barFill)

    # State label (bottom)
    $lblState = New-Object System.Windows.Forms.Label
    $lblState.Text      = "PENDING"
    $lblState.Font      = $fMono8
    $lblState.ForeColor = $cGrayDim
    $lblState.AutoSize  = $false
    $lblState.Size      = New-Object System.Drawing.Size(($cardW - 20), 16)
    $lblState.Location  = New-Object System.Drawing.Point(10, ($cardH - 20))
    $lblState.BackColor = [System.Drawing.Color]::Transparent
    $card.Controls.Add($lblState)

    $script:CardControls[$key] = @{
        Card     = $card
        Idx      = $lblIdx
        Dot      = $dot
        Name     = $lblName
        Desc     = $lblDesc
        Bar      = $barFill
        Track    = $barTrack
        State    = $lblState
    }
}

# ── STATE SETTER FOR CARDS ────────────────────────────────────────────────
function Set-CardState ($key, $state) {
    if (-not $script:CardControls.ContainsKey($key)) { return }
    $c = $script:CardControls[$key]
    switch ($state) {
        "running" {
            $c.Card.Tag    = "running"
            $c.Dot.Tag     = "running"
            $c.Name.ForeColor  = $cWhite
            $c.Desc.ForeColor  = $cWhiteDim
            $c.State.Text      = "RUNNING..."
            $c.State.ForeColor = $cWhiteDim
            $c.Bar.BackColor   = $cWhite
            $c.Bar.Width       = 30
            $c.Card.Invalidate()
            $c.Dot.Invalidate()
            $script:BlinkKey = $key
            $blinkTimer.Start()
        }
        "done" {
            $blinkTimer.Stop()
            $script:BlinkKey = $null
            $c.Card.Tag    = "done"
            $c.Dot.Tag     = "done"
            $c.Name.ForeColor  = $cDoneText
            $c.Desc.ForeColor  = [System.Drawing.Color]::FromArgb(40,40,40)
            $c.State.Text      = "DONE"
            $c.State.ForeColor = $cDoneText
            $c.Bar.BackColor   = $cGray
            $c.Bar.Width       = $c.Track.Width
            $c.Card.Invalidate()
            $c.Dot.Invalidate()
        }
    }
}

# ── BLINK TIMER ────────────────────────────────────────────────────────────
$script:BlinkOn  = $true
$script:BlinkKey = $null
$blinkTimer = New-Object System.Windows.Forms.Timer
$blinkTimer.Interval = 520
$blinkTimer.Add_Tick({
    if ($script:BlinkKey -and $script:CardControls.ContainsKey($script:BlinkKey)) {
        $c = $script:CardControls[$script:BlinkKey]
        $c.Dot.Invalidate()
        $script:BlinkOn = -not $script:BlinkOn
    }
})

# ── SMOOTH BAR ANIM TIMER ─────────────────────────────────────────────────
$script:AnimKey    = $null
$script:AnimTarget = 0
$animTimer = New-Object System.Windows.Forms.Timer
$animTimer.Interval = 16
$animTimer.Add_Tick({
    if ($script:AnimKey -and $script:CardControls.ContainsKey($script:AnimKey)) {
        $bar = $script:CardControls[$script:AnimKey].Bar
        if ($bar.Width -lt $script:AnimTarget) {
            $bar.Width = [math]::Min($bar.Width + 5, $script:AnimTarget)
        }
    }
})

# ── LOG FLUSH TIMER ───────────────────────────────────────────────────────
# Polls for new log entries and appends to UI (bridges thread boundary)
$script:LastLogCount = 0
$logFlushTimer = New-Object System.Windows.Forms.Timer
$logFlushTimer.Interval = 120
$logFlushTimer.Add_Tick({
    $cur = $script:LogLines.Count
    if ($cur -gt $script:LastLogCount) {
        for ($li = $script:LastLogCount; $li -lt $cur; $li++) {
            Append-LogEntry $script:LogLines[$li]
        }
        $script:LastLogCount = $cur
    }
})

# ── PROGRESS HELPER ───────────────────────────────────────────────────────
function Set-Progress ([int]$done, [int]$total, [string]$text) {
    if ($total -le 0) { $total = 1 }
    $pct = [math]::Round(($done / $total) * 100)
    $progFill.Width  = [math]::Round($progTrack.Width * $pct / 100)
    $lblStatus.Text  = "$text  ·  $done / $total modules  ·  $pct%"
}

# ── RUN LOGIC ─────────────────────────────────────────────────────────────
$script:RunIndex    = 0
$script:TaskKeyList = @()
$script:TotalTasks  = 0
$script:IsRunning   = $false
$script:DoneCount   = 0
$script:JobWorker   = $null

$runTimer = New-Object System.Windows.Forms.Timer
$runTimer.Interval = 80

$runTimer.Add_Tick({
    if ($script:JobWorker -and $script:JobWorker.State -eq 'Running') { return }

    if ($script:RunIndex -gt 0) {
        $prevKey = $script:TaskKeyList[$script:RunIndex - 1]
        Set-CardState $prevKey "done"
        $script:DoneCount++
        Set-Progress $script:DoneCount $script:TotalTasks "RUNNING"
        $form.Refresh()
    }

    if ($script:RunIndex -ge $script:TotalTasks) {
        $runTimer.Stop()
        $animTimer.Stop()
        if ($script:JobWorker) { $script:JobWorker | Remove-Job -Force -ErrorAction SilentlyContinue }
        $script:IsRunning = $false

        Set-Progress $script:TotalTasks $script:TotalTasks "COMPLETE"
        $progFill.BackColor    = $cGreen
        $lblStatus.ForeColor   = $cWhite
        $lblHint.Text          = "Complete. Restart your PC to apply all system-level changes."
        $btnRestart.Visible    = $true
        $btnRun.Enabled        = $false
        $btnRun.Text           = "DONE"
        $btnRun.BackColor      = $cSurface2
        $btnRun.ForeColor      = $cGrayDim
        $btnRun.FlatAppearance.BorderColor = $cBorder
        $btnRun.FlatAppearance.BorderSize  = 1

        # Final log entry
        $script:LogLines.Add(@{ Time = (Get-Date).ToString("HH:mm:ss"); Module = "GOAT"; Action = "All $($script:TotalTasks) modules complete"; Detail = "→ restart recommended" })
        return
    }

    $key = $script:TaskKeyList[$script:RunIndex]
    Set-CardState $key "running"

    $script:AnimKey    = $key
    $script:AnimTarget = $script:CardControls[$key].Track.Width
    $script:CardControls[$key].Bar.Width = 0
    $animTimer.Start()
    $form.Refresh()
    $script:RunIndex++

    $fnName = $script:FnMap[$key]
    $logRef = $script:LogLines

    $script:JobWorker = Start-Job -ScriptBlock {
        param($fn, $logRef)

        function Write-Log {
            param([string]$Module,[string]$Action,[string]$Detail="")
            $ts = (Get-Date).ToString("HH:mm:ss")
            $logRef.Add(@{ Time=$ts; Module=$Module; Action=$Action; Detail=$Detail })
        }

        function Invoke-Kernel { Write-Log "KERNEL" "bcdedit useplatformclock" "→ no"; bcdedit /set useplatformclock no 2>$null|Out-Null; Write-Log "KERNEL" "bcdedit useplatformtick" "→ yes"; bcdedit /set useplatformtick yes 2>$null|Out-Null; Write-Log "KERNEL" "bcdedit disabledynamictick" "→ yes"; bcdedit /set disabledynamictick yes 2>$null|Out-Null; Write-Log "KERNEL" "bcdedit tscsyncpolicy" "→ Enhanced"; bcdedit /set tscsyncpolicy Enhanced 2>$null|Out-Null; Write-Log "KERNEL" "bcdedit nx" "→ OptOut"; bcdedit /set nx OptOut 2>$null|Out-Null; Write-Log "KERNEL" "bcdedit synthetictimers" "→ yes"; bcdedit /set synthetictimers yes 2>$null|Out-Null; $h=Get-PnpDevice -EA SilentlyContinue|Where-Object{$_.FriendlyName -like "*High Precision*"}; if($h){ Write-Log "KERNEL" "HPET device" "→ Disabled"; Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -EA SilentlyContinue }else{ Write-Log "KERNEL" "HPET device" "→ not found/already off" } }
        function Invoke-TimerResolution { Write-Log "TIMER" "GlobalTimerResolutionRequests" "→ 1"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null }
        function Invoke-IRQ { $cnt=0; Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -EA SilentlyContinue|ForEach-Object{ $p="$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"; if(Test-Path $p){ Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null; $cnt++ } }; Write-Log "IRQ" "MSISupported=1" "→ $cnt PCI device(s)" }
        function Invoke-Nagle { $iP="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; $cnt=0; Get-ChildItem $iP -EA SilentlyContinue|ForEach-Object{ Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force 2>$null; $cnt++ }; Write-Log "NAGLE" "TcpAckFrequency=1,TCPNoDelay=1,TcpDelAckTicks=0" "→ $cnt interface(s)" }
        function Invoke-VisualEffects { $vp="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; if(-not(Test-Path $vp)){New-Item -Path $vp -Force|Out-Null}; Write-Log "VISUAL" "VisualFXSetting" "→ 2"; Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null; Write-Log "VISUAL" "UserPreferencesMask" "→ animations off"; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null; Write-Log "VISUAL" "MinAnimate" "→ 0"; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null; Write-Log "VISUAL" "TaskbarAnimations" "→ 0"; Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-GameBar { Write-Log "GAMEBAR" "AppCaptureEnabled" "→ 0"; Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null; Write-Log "GAMEBAR" "GameDVR_Enabled" "→ 0"; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null; Write-Log "GAMEBAR" "GameDVR_FSEBehaviorMode" "→ 2"; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null; $gp="HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null}; Write-Log "GAMEBAR" "AllowGameDVR (Policy)" "→ 0"; Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-ProcessorPower { Write-Log "POWER" "PROCTHROTTLEMIN" "→ 100%"; powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null|Out-Null; Write-Log "POWER" "PROCTHROTTLEMAX" "→ 100%"; powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null|Out-Null; Write-Log "POWER" "Active scheme" "→ SCHEME_CURRENT applied"; powercfg /setactive SCHEME_CURRENT 2>$null|Out-Null }
        function Invoke-Priority { $pp="HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"; $sp="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; $gp="$sp\Tasks\Games"; $ep="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"; Write-Log "PRIORITY" "Win32PrioritySeparation" "→ 0x2A"; Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null; Write-Log "PRIORITY" "SvcHostSplitThresholdInKB" "→ 32 GB"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null; Write-Log "PRIORITY" "SystemResponsiveness" "→ 0"; Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null; Write-Log "PRIORITY" "NetworkThrottlingIndex" "→ 0xFFFFFFFF"; Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null; Write-Log "PRIORITY" "AdditionalCriticalWorkerThreads" "→ +2"; Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null; if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null}; Write-Log "PRIORITY" "Games GPU Priority=8, CPU=6" "→ Scheduling High, SFIO High"; Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null; Set-ItemProperty -Path $gp -Name "SFIO Priority" -Value "High" -Type String -Force 2>$null }
        function Invoke-Memory { $mp="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Write-Log "MEMORY" "SystemCacheDirtyPageThreshold" "→ 0"; Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null; Write-Log "MEMORY" "ClearPageFileAtShutdown" "→ 0"; Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null; Write-Log "MEMORY" "EnablePrefetcher" "→ 3"; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null; Write-Log "MEMORY" "EnableSuperfetch" "→ 0 (off)"; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null; Write-Log "MEMORY" "Hibernate" "→ off"; powercfg -h off 2>$null|Out-Null; Write-Log "MEMORY" "OneDrive" "→ killed + removed from Run"; taskkill /f /im OneDrive.exe 2>$null|Out-Null; Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -EA SilentlyContinue }
        function Invoke-Input { Write-Log "INPUT" "MouseDataQueueSize" "→ 16"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null; Write-Log "INPUT" "KeyboardDataQueueSize" "→ 16"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null; $pt="HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"; if(-not(Test-Path $pt)){New-Item -Path $pt -Force|Out-Null}; Write-Log "INPUT" "PowerThrottlingOff" "→ 1"; Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null; Write-Log "INPUT" "Mouse accel" "→ off (Speed/Threshold 0)"; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force 2>$null; Write-Log "INPUT" "KeyboardDelay=0, Speed=31" "→ fastest repeat"; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null; Write-Log "INPUT" "USB SelectiveSuspend" "→ disabled"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null; Write-Log "INPUT" "HidUsb IdleEnable" "→ 0"; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-Network { Write-Log "NETWORK" "TCP RSS" "→ enabled"; netsh int tcp set global rss=enabled 2>$null|Out-Null; Write-Log "NETWORK" "autotuninglevel" "→ normal"; netsh int tcp set global autotuninglevel=normal 2>$null|Out-Null; Write-Log "NETWORK" "timestamps" "→ disabled"; netsh int tcp set global timestamps=disabled 2>$null|Out-Null; Write-Log "NETWORK" "chimney" "→ disabled"; netsh int tcp set global chimney=disabled 2>$null|Out-Null; $tp="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Write-Log "NETWORK" "TCPNoDelay=1, TcpAckFrequency=1, TTL=64" "→ global"; Set-ItemProperty -Path $tp -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "DefaultTTL" -Value 64 -Type DWord -Force 2>$null; Write-Log "NETWORK" "DNS cache" "→ flushed"; Clear-DnsClientCache -EA SilentlyContinue|Out-Null; Write-Log "NETWORK" "Winsock + IP" "→ reset"; netsh winsock reset 2>$null|Out-Null; netsh int ip reset 2>$null|Out-Null; Write-Log "NETWORK" "IP lease" "→ release + renew"; ipconfig /release 2>$null|Out-Null; ipconfig /renew 2>$null|Out-Null; Write-Log "NETWORK" "Physical adapters" "→ restarted"; Get-NetAdapter|Where-Object{$_.Physical}|Restart-NetAdapter -EA SilentlyContinue }
        function Invoke-Services { $d=@('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc'); $d|ForEach-Object{ Write-Log "SERVICES" "Disable: $_" "→ Stopped+Disabled"; Stop-Service -Name $_ -Force -EA SilentlyContinue; Set-Service -Name $_ -StartupType Disabled -EA SilentlyContinue }; $e=@('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer'); $e|ForEach-Object{ Write-Log "SERVICES" "Ensure: $_" "→ Automatic+Started"; Set-Service -Name $_ -StartupType Automatic -EA SilentlyContinue; Start-Service -Name $_ -EA SilentlyContinue } }
        function Invoke-Cleanup { @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")|ForEach-Object{ Write-Log "CLEANUP" "Delete" "→ $_"; Get-ChildItem -Path $_ -Recurse -EA SilentlyContinue|Remove-Item -Recurse -Force -EA SilentlyContinue }; Write-Log "CLEANUP" "SoftwareDistribution" "→ cleared"; Stop-Service -Name wuauserv,UsoSvc -Force -EA SilentlyContinue; Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -EA SilentlyContinue; Start-Service -Name wuauserv -EA SilentlyContinue; Write-Log "CLEANUP" "Event Logs" "→ all cleared"; wevtutil.exe el|ForEach-Object{ wevtutil.exe cl "$_" 2>$null } }

        try { & $fn } catch { Write-Log "ERROR" "$fn failed" "→ $_" }

    } -ArgumentList $fnName, $logRef
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:DoneCount   = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    $script:LastLogCount = 0
    $btnRestart.Visible  = $false
    $lblHint.Text        = "GOAT is running — please wait until all modules complete."
    Set-Progress 0 $script:TotalTasks "RUNNING"
    $btnRun.Enabled   = $false
    $btnRun.Text      = "RUNNING..."
    $btnRun.BackColor = $cSurface2
    $btnRun.ForeColor = $cGrayDim
    $btnRun.FlatAppearance.BorderColor = $cBorder
    $btnRun.FlatAppearance.BorderSize  = 1
    $script:LogLines.Add(@{ Time=(Get-Date).ToString("HH:mm:ss"); Module="GOAT"; Action="Session started"; Detail="→ $($script:TotalTasks) modules queued" })
    $logFlushTimer.Start()
    $runTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
