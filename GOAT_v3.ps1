#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Onyx Crimson · Soft Luxury
#>

# ── ADMIN AUTO-ELEVATE ────────────────────────────────────────────────────
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

function Trim-String($s, $len) { if ($s.Length -gt $len) { $s.Substring(0,$len)+"…" } else { $s } }
$CPUShort  = Trim-String $CPU 34
$GPUShort  = Trim-String $GPU 34
$OSShort   = Trim-String $OSName 34
$UserShort = Trim-String "$UserName @ $PCName" 34

# ── DOUBLE BUFFER HELPER ───────────────────────────────────────────────────
$doubleBufferCode = @"
using System;
using System.Windows.Forms;
public class DBPanel : Panel {
    public DBPanel() { this.DoubleBuffered = true; this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true); }
}
public class DBForm : Form {
    public DBForm() { this.DoubleBuffered = true; }
}
"@
Add-Type -TypeDefinition $doubleBufferCode -ReferencedAssemblies System.Windows.Forms

# ── PALETTE — ONYX CRIMSON ─────────────────────────────────────────────────
$cBg         = [System.Drawing.Color]::FromArgb(8,   8,   10)
$cSurface    = [System.Drawing.Color]::FromArgb(14,  14,  18)
$cCard       = [System.Drawing.Color]::FromArgb(20,  20,  26)
$cCardHover  = [System.Drawing.Color]::FromArgb(26,  26,  34)
$cBorder     = [System.Drawing.Color]::FromArgb(44,  44,  56)
$cBorderFine = [System.Drawing.Color]::FromArgb(30,  30,  40)

# Crimson accent palette
$cAccent     = [System.Drawing.Color]::FromArgb(180, 30,  50)    # deep crimson
$cAccentGlow = [System.Drawing.Color]::FromArgb(220, 50,  70)    # bright crimson
$cAccentDim  = [System.Drawing.Color]::FromArgb(100, 20,  30)    # muted crimson
$cAccentFill = [System.Drawing.Color]::FromArgb(40,  180, 30, 50) # translucent

$cWhite      = [System.Drawing.Color]::FromArgb(245, 240, 238)
$cWhiteDim   = [System.Drawing.Color]::FromArgb(170, 165, 162)
$cMuted      = [System.Drawing.Color]::FromArgb(90,  86,  90)
$cDimText    = [System.Drawing.Color]::FromArgb(52,  50,  55)
$cDone       = [System.Drawing.Color]::FromArgb(70,  68,  72)
$cDoneFill   = [System.Drawing.Color]::FromArgb(35,  34,  38)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fUI8      = New-Object System.Drawing.Font("Segoe UI", 8)
$fUI9      = New-Object System.Drawing.Font("Segoe UI", 9)
$fUI10     = New-Object System.Drawing.Font("Segoe UI", 10)
$fUISemi   = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
$fUIBold11 = New-Object System.Drawing.Font("Segoe UI Bold", 11)
$fUIBold9  = New-Object System.Drawing.Font("Segoe UI Bold", 9)
$fMono8    = New-Object System.Drawing.Font("Consolas", 8)
$fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$fTitle    = New-Object System.Drawing.Font("Segoe UI Black", 28, [System.Drawing.FontStyle]::Bold)
$fCap      = New-Object System.Drawing.Font("Segoe UI", 7)

# ── TASK DEFINITIONS ───────────────────────────────────────────────────────
$script:Tasks = [ordered]@{
    "kernel"   = "Kernel & HPET"
    "timer"    = "Timer Resolution"
    "priority" = "Process Priority"
    "irq"      = "IRQ / MSI Mode"
    "memory"   = "Memory Management"
    "input"    = "Input & USB"
    "nagle"    = "Nagle Algorithm"
    "visual"   = "Visual Effects"
    "gamebar"  = "Game Bar & DVR"
    "power"    = "Processor Power"
    "network"  = "Network & DNS"
    "services" = "Windows Services"
    "cleanup"  = "Junk & Log Cleanup"
}

$script:TaskDesc = [ordered]@{
    "kernel"   = "BCD boot flags, platform clock, TSC sync"
    "timer"    = "GlobalTimerResolutionRequests registry"
    "priority" = "Win32 priority separation, MMCSS"
    "irq"      = "PCI MSI interrupt mode enforcement"
    "memory"   = "Prefetch, pagefile, Superfetch, OneDrive"
    "input"    = "Mouse accel, USB suspend, queue size"
    "nagle"    = "TCP ACK frequency, delayed ACK disable"
    "visual"   = "Animation, transparency, DWM effects"
    "gamebar"  = "GameDVR, FSE, Xbox overlay disable"
    "power"    = "CPU min/max P-state 100% lock"
    "network"  = "RSS, autotuning, Winsock reset, DNS"
    "services" = "Telemetry, Xbox, Fax, Search disable"
    "cleanup"  = "Temp files, SoftwareDistribution, logs"
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

# ── OPTIMIZATION FUNCTIONS ─────────────────────────────────────────────────
function Invoke-Kernel {
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    bcdedit /set synthetictimers yes 2>$null | Out-Null
    $h = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like "*High Precision*" }
    if ($h) { Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
}
function Invoke-TimerResolution {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
}
function Invoke-IRQ {
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $p) { Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null }
    }
}
function Invoke-Nagle {
    $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
}
function Invoke-VisualEffects {
    $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
    Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
}
function Invoke-GameBar {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
    $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
}
function Invoke-ProcessorPower {
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
}
function Invoke-Priority {
    $pp = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $sp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $gp = "$sp\Tasks\Games"
    $ep = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"
    Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "GPU Priority"        -Value 8      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Priority"            -Value 6      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null
    Set-ItemProperty -Path $gp -Name "SFIO Priority"       -Value "High" -Type String -Force 2>$null
}
function Invoke-Memory {
    $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown"       -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
    powercfg -h off 2>$null | Out-Null
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
}
function Invoke-Input {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }
    Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseSpeed"      -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseThreshold1" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse"    -Name "MouseThreshold2" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay"   -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed"   -Value "31" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
}
function Invoke-Network {
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    netsh int tcp set global autotuninglevel=disabled 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled 2>$null | Out-Null
    netsh int tcp set global chimney=disabled 2>$null | Out-Null
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
}
function Invoke-Services {
    @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc') | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer') | ForEach-Object {
        Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
}
function Invoke-Cleanup {
    @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*") | ForEach-Object {
        Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
}

# ── ROUNDED RECT HELPER ────────────────────────────────────────────────────
function Get-RoundedRect([int]$x,[int]$y,[int]$w,[int]$h,[int]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x,          $y,          $r*2, $r*2, 180, 90)
    $path.AddArc($x+$w-$r*2,  $y,          $r*2, $r*2, 270, 90)
    $path.AddArc($x+$w-$r*2,  $y+$h-$r*2,  $r*2, $r*2,   0, 90)
    $path.AddArc($x,          $y+$h-$r*2,  $r*2, $r*2,  90, 90)
    $path.CloseFigure()
    return $path
}

# ── LAYOUT CONSTANTS ───────────────────────────────────────────────────────
[int]$formW      = 860
[int]$headerH    = 180
[int]$subbarH    = 44
[int]$rowH       = 52
[int]$taskCount  = 13
[int]$listH      = ($taskCount * $rowH) + 16
[int]$footerH    = 96
[int]$formH      = 36 + $headerH + $subbarH + $listH + $footerH + 8

# ── MAIN FORM ──────────────────────────────────────────────────────────────
$form = New-Object DBForm
$form.Text            = "GOAT — Greatest Of All Tweaks  v4.0"
$form.Size            = New-Object System.Drawing.Size($formW, $formH)
$form.MinimumSize     = New-Object System.Drawing.Size($formW, $formH)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false
$form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── TITLE BAR STRIP ────────────────────────────────────────────────────────
$titleBar = New-Object DBPanel
$titleBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$titleBar.Height    = 36
$titleBar.BackColor = $cSurface

$titleBar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    # bottom separator
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60,180,30,50), 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
    # window-control dots
    $colors = @([System.Drawing.Color]::FromArgb(255,90,90), [System.Drawing.Color]::FromArgb(255,190,60), [System.Drawing.Color]::FromArgb(60,200,80))
    for ($i=0;$i -lt 3;$i++) {
        $br = New-Object System.Drawing.SolidBrush($colors[$i])
        $g.FillEllipse($br, 14+($i*20), 13, 10, 10)
        $br.Dispose()
    }
    # path label
    $br2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60,60,70))
    $g.DrawString("GOAT.ps1  —  Administrator", $fMono8, $br2, 80, 12)
    $br2.Dispose()
    # version badge
    $badgePath = Get-RoundedRect 754 10 60 16 4
    $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80,180,30,50), 1)
    $g.DrawPath($pen2, $badgePath)
    $pen2.Dispose()
    $badgePath.Dispose()
    $br3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180,30,50))
    $g.DrawString("v4.0", $fMono8, $br3, 768, 13)
    $br3.Dispose()
})

# ── HERO / HEADER ─────────────────────────────────────────────────────────
$heroPanel = New-Object DBPanel
$heroPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$heroPanel.Height    = $headerH
$heroPanel.BackColor = $cSurface

$heroPanel.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # subtle gradient bg
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0),
        [System.Drawing.Point]::new(0,$s.Height),
        [System.Drawing.Color]::FromArgb(14,14,18),
        [System.Drawing.Color]::FromArgb(10,10,14)
    )
    $g.FillRectangle($gb, 0, 0, $s.Width, $s.Height)
    $gb.Dispose()

    # accent glow strip (left edge)
    $glowBr = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0),
        [System.Drawing.Point]::new(5,0),
        [System.Drawing.Color]::FromArgb(200,180,30,50),
        [System.Drawing.Color]::FromArgb(0,180,30,50)
    )
    $g.FillRectangle($glowBr, 0, 24, 4, $s.Height - 48)
    $glowBr.Dispose()

    # GOAT title
    $titleBr = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString("GOAT", $fTitle, $titleBr, 24, 22)
    $titleBr.Dispose()

    # red dot accent after title
    $dotBr = New-Object System.Drawing.SolidBrush($cAccent)
    $g.FillEllipse($dotBr, 165, 28, 8, 8)
    $dotBr.Dispose()

    # subtitle line
    $subBr = New-Object System.Drawing.SolidBrush($cMuted)
    $g.DrawString("GREATEST OF ALL TWEAKS", $fCap, $subBr, 26, 78)
    $subBr.Dispose()

    # thin separator line under subtitle
    $sepBr = New-Object System.Drawing.SolidBrush($cAccentDim)
    $g.FillRectangle($sepBr, 24, 96, 160, 1)
    $sepBr.Dispose()

    # sys info — right card
    $cardPath = Get-RoundedRect ($s.Width - 296) 16 270 ($s.Height - 32) 10
    $cardBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(26,26,32))
    $g.FillPath($cardBr, $cardPath)
    $cardBr.Dispose()
    $cardPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(44,44,56), 1)
    $g.DrawPath($cardPen, $cardPath)
    $cardPen.Dispose()
    $cardPath.Dispose()

    $labelBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100,30,50))
    $valBr   = New-Object System.Drawing.SolidBrush($cWhiteDim)
    $sfR = New-Object System.Drawing.StringFormat
    $sfR.Alignment = [System.Drawing.StringAlignment]::Far
    $rx = $s.Width - 30
    $rows = @(26, 52, 78, 104, 130)
    $labels = @("USER","CPU","GPU","RAM","OS")
    $vals   = @($UserShort, $CPUShort, $GPUShort, "$RAMUsed / $($RAMTotal) GB  ($RAMPct%)", $OSShort)
    for ($i=0; $i -lt 5; $i++) {
        $g.DrawString($labels[$i], $fCap, $labelBr, $rx-240, $rows[$i], $sfR)
        # thin divider between label and val
        $divPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40,40,50), 1)
        $g.DrawLine($divPen, $rx-236, $rows[$i]+4, $rx-230, $rows[$i]+4)
        $divPen.Dispose()
        $g.DrawString($vals[$i], $fCap, $valBr, $rx, $rows[$i], $sfR)
    }
    $labelBr.Dispose(); $valBr.Dispose(); $sfR.Dispose()

    # divider bottom
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30,30,40), 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
})

# ── MODULE HEADER BAR ──────────────────────────────────────────────────────
$subBar = New-Object DBPanel
$subBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$subBar.Height    = $subbarH
$subBar.BackColor = $cBg

$lblModTitle = New-Object System.Windows.Forms.Label
$lblModTitle.Text      = "OPTIMIZATION MODULES"
$lblModTitle.Font      = $fCap
$lblModTitle.ForeColor = [System.Drawing.Color]::FromArgb(80,76,82)
$lblModTitle.AutoSize  = $false
$lblModTitle.Size      = New-Object System.Drawing.Size(300, $subbarH)
$lblModTitle.Location  = New-Object System.Drawing.Point(28, 0)
$lblModTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblModTitle.BackColor = [System.Drawing.Color]::Transparent
$subBar.Controls.Add($lblModTitle)

$lblDoneCount = New-Object System.Windows.Forms.Label
$lblDoneCount.Text      = "0 / 13"
$lblDoneCount.Font      = $fMono8
$lblDoneCount.ForeColor = $cAccentDim
$lblDoneCount.AutoSize  = $false
$lblDoneCount.Size      = New-Object System.Drawing.Size(56, 22)
$lblDoneCount.Location  = New-Object System.Drawing.Point(770, 11)
$lblDoneCount.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblDoneCount.BackColor = [System.Drawing.Color]::Transparent
$subBar.Controls.Add($lblDoneCount)

$subBar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    # badge border around count
    $path = Get-RoundedRect 768 9 60 24 5
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80,180,30,50), 1)
    $g.DrawPath($pen, $path)
    $pen.Dispose(); $path.Dispose()
    # bottom rule
    $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,22,28), 1)
    $g.DrawLine($pen2, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen2.Dispose()
})

# ── FOOTER ─────────────────────────────────────────────────────────────────
$footer = New-Object DBPanel
$footer.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$footer.Height    = $footerH
$footer.BackColor = $cSurface

$footer.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(44,44,56), 1)
    $g.DrawLine($pen, 0, 0, $s.Width, 0)
    $pen.Dispose()
    # accent glow on top border
    $gl = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
        [System.Drawing.Color]::FromArgb(0,180,30,50),
        [System.Drawing.Color]::FromArgb(120,180,30,50)
    )
    $g.FillRectangle($gl, 0, 0, $s.Width/2, 1)
    $gl.Dispose()
})

# progress track
$trackBg = New-Object DBPanel
$trackBg.Location  = New-Object System.Drawing.Point(28, 20)
$trackBg.Size      = New-Object System.Drawing.Size(480, 6)
$trackBg.BackColor = [System.Drawing.Color]::FromArgb(28,28,36)
$footer.Controls.Add($trackBg)

$trackBg.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 3
    $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28,28,36))
    $g.FillPath($br, $path); $br.Dispose(); $path.Dispose()
})

$overallFill = New-Object DBPanel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 6)
$overallFill.BackColor = $cAccent
$trackBg.Controls.Add($overallFill)

$overallFill.Add_Paint({
    param($s,$e)
    if ($s.Width -lt 2) { return }
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
        [System.Drawing.Color]::FromArgb(140,20,36), $cAccentGlow
    )
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 3
    $g.FillPath($gb, $path)
    $gb.Dispose(); $path.Dispose()
})

$lblPct = New-Object System.Windows.Forms.Label
$lblPct.Text      = "READY  ·  0%"
$lblPct.Font      = $fUI8
$lblPct.ForeColor = $cMuted
$lblPct.AutoSize  = $false
$lblPct.Size      = New-Object System.Drawing.Size(480, 20)
$lblPct.Location  = New-Object System.Drawing.Point(28, 34)
$lblPct.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblPct)

$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text      = "Run GOAT to apply all performance optimizations.  A system restart is recommended after completion."
$lblHint.Font      = $fCap
$lblHint.ForeColor = [System.Drawing.Color]::FromArgb(52,50,55)
$lblHint.AutoSize  = $false
$lblHint.Size      = New-Object System.Drawing.Size(480, 18)
$lblHint.Location  = New-Object System.Drawing.Point(28, 58)
$lblHint.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblHint)

# Restart button (hidden until done)
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART"
$btnRestart.Font      = $fUI9
$btnRestart.ForeColor = $cAccentGlow
$btnRestart.BackColor = [System.Drawing.Color]::FromArgb(30,14,18)
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cAccentDim
$btnRestart.FlatAppearance.BorderSize  = 1
$btnRestart.Size      = New-Object System.Drawing.Size(100, 36)
$btnRestart.Location  = New-Object System.Drawing.Point(530, 29)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({
    $ans = [System.Windows.Forms.MessageBox]::Show("Restart this PC now to apply all changes?", "GOAT Complete", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($ans -eq [System.Windows.Forms.DialogResult]::Yes) { Restart-Computer -Force }
})
$footer.Controls.Add($btnRestart)

# Run button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "RUN GOAT"
$btnRun.Font      = $fUIBold9
$btnRun.ForeColor = $cWhite
$btnRun.BackColor = $cAccent
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize  = 0
$btnRun.Size      = New-Object System.Drawing.Size(120, 36)
$btnRun.Location  = New-Object System.Drawing.Point(642, 29)
$footer.Controls.Add($btnRun)

$btnRun.Add_Paint({
    param($s,$e)
    if (-not $s.Enabled) { return }
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 6
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new(0,$s.Height),
        [System.Drawing.Color]::FromArgb(220,50,70), [System.Drawing.Color]::FromArgb(150,20,40)
    )
    $g.FillPath($gb, $path)
    $gb.Dispose(); $path.Dispose()
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $br = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString($s.Text, $s.Font, $br, [System.Drawing.RectangleF]::new(0,0,$s.Width,$s.Height), $sf)
    $br.Dispose(); $sf.Dispose()
})

# ── SCROLL + INNER PANEL ──────────────────────────────────────────────────
$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.Dock        = [System.Windows.Forms.DockStyle]::Fill
$scrollPanel.BackColor   = $cBg
$scrollPanel.AutoScroll  = $true

[int]$innerH = ($taskCount * $rowH) + 24
$innerPanel  = New-Object DBPanel
$innerPanel.Size      = New-Object System.Drawing.Size($formW - 4, $innerH)
$innerPanel.Location  = New-Object System.Drawing.Point(0, 0)
$innerPanel.BackColor = [System.Drawing.Color]::Transparent
$scrollPanel.Controls.Add($innerPanel)

# ── FORM CONTROL ORDER ─────────────────────────────────────────────────────
$form.Controls.Add($footer)
$form.Controls.Add($scrollPanel)
$form.Controls.Add($subBar)
$form.Controls.Add($heroPanel)
$form.Controls.Add($titleBar)

# ── BUILD TASK ROWS ────────────────────────────────────────────────────────
$script:TaskRows = @{}
$taskKeys        = @($script:Tasks.Keys)
[int]$yPos       = 8
[int]$tidx       = 0

foreach ($key in $taskKeys) {
    $label = $script:Tasks[$key]
    $desc  = $script:TaskDesc[$key]
    $idxTxt = ($tidx + 1).ToString("00")

    $row = New-Object DBPanel
    $row.Size      = New-Object System.Drawing.Size($formW - 20, $rowH)
    $row.Location  = New-Object System.Drawing.Point(10, $yPos)
    $row.BackColor = [System.Drawing.Color]::Transparent
    $row.Tag       = "pending"
    $innerPanel.Controls.Add($row)

    $rowKey = $key
    $row.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $st = $s.Tag
        $rc = 6

        if ($st -eq "running") {
            $path = Get-RoundedRect 0 2 ($s.Width-1) ($s.Height-4) $rc
            $cardBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(26,20,24))
            $g.FillPath($cardBr, $path); $cardBr.Dispose()
            $cardPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80,180,30,50), 1)
            $g.DrawPath($cardPen, $path); $cardPen.Dispose()
            $path.Dispose()
        } elseif ($st -eq "done") {
            $path = Get-RoundedRect 0 2 ($s.Width-1) ($s.Height-4) $rc
            $cardBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18,18,22))
            $g.FillPath($cardBr, $path); $cardBr.Dispose()
            $path.Dispose()
        }

        # subtle bottom divider
        $dp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,22,28), 1)
        $g.DrawLine($dp, 28, $s.Height-1, $s.Width-28, $s.Height-1)
        $dp.Dispose()
    })

    # index label
    $lblIdx = New-Object System.Windows.Forms.Label
    $lblIdx.Text      = $idxTxt
    $lblIdx.Font      = $fMono8
    $lblIdx.ForeColor = [System.Drawing.Color]::FromArgb(50,46,52)
    $lblIdx.AutoSize  = $false
    $lblIdx.Size      = New-Object System.Drawing.Size(30, $rowH)
    $lblIdx.Location  = New-Object System.Drawing.Point(22, 0)
    $lblIdx.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $lblIdx.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblIdx)

    # status dot (custom painted)
    $dot = New-Object DBPanel
    $dot.Size      = New-Object System.Drawing.Size(12, 12)
    $dot.Location  = New-Object System.Drawing.Point(62, 20)
    $dot.BackColor = [System.Drawing.Color]::Transparent
    $dot.Tag       = "pending"
    $dot.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        switch ($s.Tag) {
            "pending" {
                $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50,46,52), 1.2)
                $g.DrawEllipse($pen, 1, 1, 9, 9)
                $pen.Dispose()
            }
            "running" {
                $gb = New-Object System.Drawing.Drawing2D.RadialGradientBrush(
                    [System.Drawing.PointF]::new(6,6), 6,
                    $cAccentGlow, $cAccent
                )
                $g.FillEllipse($gb, 1, 1, 9, 9)
                $gb.Dispose()
            }
            "done" {
                $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80,180,30,50))
                $g.FillEllipse($br, 1, 1, 9, 9)
                $br.Dispose()
                # checkmark
                $ck = New-Object System.Drawing.Pen($cAccent, 1.5)
                $ck.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
                $ck.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
                $g.DrawLine($ck, 3, 6, 5, 8)
                $g.DrawLine($ck, 5, 8, 9, 3)
                $ck.Dispose()
            }
        }
    })
    $row.Controls.Add($dot)

    # module name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $label
    $lblName.Font      = $fUI10
    $lblName.ForeColor = [System.Drawing.Color]::FromArgb(70,66,72)
    $lblName.AutoSize  = $false
    $lblName.Size      = New-Object System.Drawing.Size(200, 26)
    $lblName.Location  = New-Object System.Drawing.Point(84, 8)
    $lblName.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblName)

    # description sub-label
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text      = $desc
    $lblDesc.Font      = $fCap
    $lblDesc.ForeColor = [System.Drawing.Color]::FromArgb(44,42,46)
    $lblDesc.AutoSize  = $false
    $lblDesc.Size      = New-Object System.Drawing.Size(220, 16)
    $lblDesc.Location  = New-Object System.Drawing.Point(84, 32)
    $lblDesc.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblDesc)

    # progress track
    $barTrack = New-Object DBPanel
    $barTrack.Location  = New-Object System.Drawing.Point(330, 24)
    $barTrack.Size      = New-Object System.Drawing.Size(360, 4)
    $barTrack.BackColor = [System.Drawing.Color]::Transparent
    $barTrack.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $path = Get-RoundedRect 0 0 $s.Width $s.Height 2
        $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28,28,36))
        $g.FillPath($br, $path); $br.Dispose(); $path.Dispose()
    })
    $row.Controls.Add($barTrack)

    $barFill = New-Object DBPanel
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barFill.Size      = New-Object System.Drawing.Size(0, 4)
    $barFill.BackColor = $cAccent
    $barFill.Add_Paint({
        param($s,$e)
        if ($s.Width -lt 2) { return }
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $path = Get-RoundedRect 0 0 $s.Width $s.Height 2
        $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
            [System.Drawing.Color]::FromArgb(120,20,36), $cAccentGlow
        )
        $g.FillPath($gb, $path); $gb.Dispose(); $path.Dispose()
    })
    $barTrack.Controls.Add($barFill)

    # status label
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text      = "—"
    $lblStatus.Font      = $fCap
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(44,42,46)
    $lblStatus.AutoSize  = $false
    $lblStatus.Size      = New-Object System.Drawing.Size(80, $rowH)
    $lblStatus.Location  = New-Object System.Drawing.Point(716, 0)
    $lblStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $lblStatus.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblStatus)

    $script:TaskRows[$key] = @{
        Row    = $row
        Idx    = $lblIdx
        Dot    = $dot
        Name   = $lblName
        Desc   = $lblDesc
        Bar    = $barFill
        Track  = $barTrack
        Status = $lblStatus
    }

    $yPos += $rowH
    $tidx++
}

# ── BLINK TIMER ────────────────────────────────────────────────────────────
$script:BlinkOn  = $true
$script:BlinkKey = $null
$blinkTimer = New-Object System.Windows.Forms.Timer
$blinkTimer.Interval = 480
$blinkTimer.Add_Tick({
    if ($script:BlinkKey -and $script:TaskRows.ContainsKey($script:BlinkKey)) {
        $r = $script:TaskRows[$script:BlinkKey]
        $script:BlinkOn = -not $script:BlinkOn
        $r.Dot.Invalidate()
    }
})

# ── STATE SETTER ───────────────────────────────────────────────────────────
function Set-TaskState($key, $state) {
    if (-not $script:TaskRows.ContainsKey($key)) { return }
    $r = $script:TaskRows[$key]
    switch ($state) {
        "running" {
            $r.Row.Tag          = "running"
            $r.Dot.Tag          = "running"
            $r.Idx.ForeColor    = $cAccentDim
            $r.Name.ForeColor   = $cWhite
            $r.Name.Font        = $fUISemi
            $r.Desc.ForeColor   = [System.Drawing.Color]::FromArgb(90,86,90)
            $r.Status.Text      = "running"
            $r.Status.ForeColor = $cAccentGlow
            $r.Bar.Width        = 40
            $r.Row.Invalidate(); $r.Dot.Invalidate()
            $script:BlinkKey = $key
            $blinkTimer.Start()
        }
        "done" {
            $blinkTimer.Stop()
            $script:BlinkKey    = $null
            $r.Row.Tag          = "done"
            $r.Dot.Tag          = "done"
            $r.Idx.ForeColor    = [System.Drawing.Color]::FromArgb(60,56,62)
            $r.Name.ForeColor   = $cDone
            $r.Name.Font        = $fUI10
            $r.Desc.ForeColor   = [System.Drawing.Color]::FromArgb(44,42,46)
            $r.Status.Text      = "done"
            $r.Status.ForeColor = $cAccentDim
            $r.Bar.Width        = $r.Track.Width
            $r.Bar.Invalidate()
            $r.Row.Invalidate(); $r.Dot.Invalidate()
        }
    }
}

# ── SMOOTH BAR ANIMATION ───────────────────────────────────────────────────
$script:AnimKey    = $null
$script:AnimTarget = 0
$animTimer = New-Object System.Windows.Forms.Timer
$animTimer.Interval = 16
$animTimer.Add_Tick({
    if ($script:AnimKey -and $script:TaskRows.ContainsKey($script:AnimKey)) {
        $bar = $script:TaskRows[$script:AnimKey].Bar
        if ($bar.Width -lt $script:AnimTarget) {
            $bar.Width = [math]::Min($bar.Width + 8, $script:AnimTarget)
            $bar.Invalidate()
        }
    }
})

# ── PROGRESS HELPERS ───────────────────────────────────────────────────────
function Set-OverallProgress([int]$done, [int]$total, [string]$stateText) {
    if ($total -le 0) { $total = 1 }
    $pct = [math]::Max(0, [math]::Min(100, [math]::Round(($done / $total) * 100)))
    $overallFill.Width = [math]::Round($trackBg.Width * $pct / 100)
    $overallFill.Invalidate()
    $lblPct.Text       = "$stateText  ·  $pct%"
    $lblDoneCount.Text = "$done / $total"
    $subBar.Invalidate()
}

function Set-RunButtonStyle([string]$mode) {
    switch ($mode) {
        "ready" {
            $btnRun.Enabled   = $true
            $btnRun.Text      = "RUN GOAT"
            $btnRun.BackColor = $cAccent
            $btnRun.ForeColor = $cWhite
            $btnRun.FlatAppearance.BorderSize = 0
            $btnRun.Invalidate()
        }
        "running" {
            $btnRun.Enabled   = $false
            $btnRun.Text      = "RUNNING…"
            $btnRun.BackColor = [System.Drawing.Color]::FromArgb(30,28,32)
            $btnRun.ForeColor = $cMuted
            $btnRun.FlatAppearance.BorderColor = $cBorderFine
            $btnRun.FlatAppearance.BorderSize  = 1
        }
        "complete" {
            $btnRun.Enabled   = $false
            $btnRun.Text      = "COMPLETE"
            $btnRun.BackColor = [System.Drawing.Color]::FromArgb(30,28,32)
            $btnRun.ForeColor = $cAccentDim
            $btnRun.FlatAppearance.BorderColor = $cAccentDim
            $btnRun.FlatAppearance.BorderSize  = 1
        }
    }
}

# ── RUN LOGIC ──────────────────────────────────────────────────────────────
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
        Set-TaskState $prevKey "done"
        $script:DoneCount++
        Set-OverallProgress $script:DoneCount $script:TotalTasks "RUNNING"
        $form.Refresh()
    }

    if ($script:RunIndex -ge $script:TotalTasks) {
        $runTimer.Stop()
        $animTimer.Stop()
        if ($script:JobWorker) { $script:JobWorker | Remove-Job -Force -ErrorAction SilentlyContinue }
        $script:IsRunning   = $false
        Set-OverallProgress $script:TotalTasks $script:TotalTasks "COMPLETE"
        $lblPct.ForeColor   = $cAccentGlow
        $lblHint.Text       = "All modules complete.  Restart your PC to apply all system-level changes."
        $lblHint.ForeColor  = $cAccentDim
        $btnRestart.Visible = $true
        Set-RunButtonStyle "complete"
        return
    }

    $key = $script:TaskKeyList[$script:RunIndex]
    Set-TaskState $key "running"
    $script:AnimKey    = $key
    $script:AnimTarget = $script:TaskRows[$key].Track.Width
    $script:TaskRows[$key].Bar.Width = 0
    $animTimer.Start()

    $r = $script:TaskRows[$key].Row
    $scrollPanel.AutoScrollPosition = New-Object System.Drawing.Point(0, [Math]::Max(0, $r.Top - 80))
    $form.Refresh()
    $script:RunIndex++

    $fnName = $script:FnMap[$key]
    $script:JobWorker = Start-Job -ScriptBlock {
        param($fn)
        function Invoke-Kernel { bcdedit /set useplatformclock no 2>$null|Out-Null;bcdedit /set useplatformtick yes 2>$null|Out-Null;bcdedit /set disabledynamictick yes 2>$null|Out-Null;bcdedit /set tscsyncpolicy Enhanced 2>$null|Out-Null;bcdedit /set nx OptOut 2>$null|Out-Null;bcdedit /set synthetictimers yes 2>$null|Out-Null;$h=Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.FriendlyName -like "*High Precision*"};if($h){Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue} }
        function Invoke-TimerResolution { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null }
        function Invoke-IRQ { Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue|ForEach-Object{$p="$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties";if(Test-Path $p){Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null}} }
        function Invoke-Nagle { $iP="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces";Get-ChildItem $iP -ErrorAction SilentlyContinue|ForEach-Object{Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force 2>$null} }
        function Invoke-VisualEffects { $vp="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects";if(-not(Test-Path $vp)){New-Item -Path $vp -Force|Out-Null};Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null;Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-GameBar { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null;$gp="HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR";if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null};Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-ProcessorPower { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null|Out-Null;powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null|Out-Null;powercfg /setactive SCHEME_CURRENT 2>$null|Out-Null }
        function Invoke-Priority { $pp="HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl";$sp="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile";$gp="$sp\Tasks\Games";$ep="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive";Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null;Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null;Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null;Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null;if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null};Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force 2>$null;Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force 2>$null;Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null;Set-ItemProperty -Path $gp -Name "SFIO Priority" -Value "High" -Type String -Force 2>$null }
        function Invoke-Memory { $mp="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management";Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null;Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null;Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null;Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null;powercfg -h off 2>$null|Out-Null;taskkill /f /im OneDrive.exe 2>$null|Out-Null;Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue }
        function Invoke-Input { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null;$pt="HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling";if(-not(Test-Path $pt)){New-Item -Path $pt -Force|Out-Null};Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Type String -Force 2>$null;Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null;Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-Network { netsh int tcp set global rss=enabled 2>$null|Out-Null;netsh int tcp set global autotuninglevel=disabled 2>$null|Out-Null;netsh int tcp set global timestamps=disabled 2>$null|Out-Null;netsh int tcp set global chimney=disabled 2>$null|Out-Null;$tp="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters";Set-ItemProperty -Path $tp -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null;Set-ItemProperty -Path $tp -Name "DefaultTTL" -Value 64 -Type DWord -Force 2>$null;Clear-DnsClientCache -ErrorAction SilentlyContinue|Out-Null;netsh winsock reset 2>$null|Out-Null;netsh int ip reset 2>$null|Out-Null;ipconfig /release 2>$null|Out-Null;ipconfig /renew 2>$null|Out-Null;Get-NetAdapter|Where-Object{$_.Physical}|Restart-NetAdapter -ErrorAction SilentlyContinue }
        function Invoke-Services { @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')|ForEach-Object{Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue;Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue};@('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')|ForEach-Object{Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue;Start-Service -Name $_ -ErrorAction SilentlyContinue} }
        function Invoke-Cleanup { @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")|ForEach-Object{Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue|Remove-Item -Recurse -Force -ErrorAction SilentlyContinue};Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue;Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue;Start-Service -Name wuauserv -ErrorAction SilentlyContinue;wevtutil.exe el|ForEach-Object{wevtutil.exe cl "$_" 2>$null} }
        try { & $fn } catch {}
    } -ArgumentList $fnName
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:DoneCount   = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    $btnRestart.Visible  = $false
    $lblHint.Text        = "GOAT is running.  Please wait until all modules are complete."
    $lblHint.ForeColor   = $cMuted
    $lblPct.ForeColor    = $cMuted
    Set-OverallProgress 0 $script:TotalTasks "RUNNING"
    Set-RunButtonStyle "running"
    $runTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
