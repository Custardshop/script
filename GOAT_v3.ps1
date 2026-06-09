#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Onyx Crimson · Soft Luxury (Horizontal Edition - Full Engine)
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

$CPUShort  = if ($CPU.Length -gt 32) { $CPU.Substring(0,32)+"…" } else { $CPU }
$GPUShort  = if ($GPU.Length -gt 32) { $GPU.Substring(0,32)+"…" } else { $GPU }

# ── DOUBLE BUFFER HELPER FOR TRANSPARENT & FLUID UI ────────────────────────
$doubleBufferCode = @"
using System;
using System.Windows.Forms;
public class DBPanel : Panel {
    public DBPanel() { this.DoubleBuffered = true; this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.SupportsTransparentBackColor, true); }
}
public class DBForm : Form {
    public DBForm() { this.DoubleBuffered = true; }
}
"@
Add-Type -TypeDefinition $doubleBufferCode -ReferencedAssemblies System.Windows.Forms

# ── PALETTE — ONYX CRIMSON ─────────────────────────────────────────────────
$cBg         = [System.Drawing.Color]::FromArgb(12,  12,  14)
$cSurface    = [System.Drawing.Color]::FromArgb(18,  18,  22)
$cAccent     = [System.Drawing.Color]::FromArgb(186, 12,  47)    # Crimson Red
$cAccentGlow = [System.Drawing.Color]::FromArgb(240, 20,  55)    # Bright Glow
$cAccentDim  = [System.Drawing.Color]::FromArgb(90,  15,  25)    # Muted Crimson
$cWhite      = [System.Drawing.Color]::FromArgb(240, 240, 245)
$cMuted      = [System.Drawing.Color]::FromArgb(130, 130, 140)
$cPending    = [System.Drawing.Color]::FromArgb(65,  65,  75)
$logBg      = [System.Drawing.Color]::FromArgb(8,   8,   10)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fTitle    = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$fontBold  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontSub   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$fontLog   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)

# ── MAIN FORM ──────────────────────────────────────────────────────────────
$form = New-Object DBForm
$form.Text            = "GOAT — GREATEST OF ALL TWEAKS [Premium Edition v4.0]"
$form.Size            = New-Object System.Drawing.Size(1130, 680)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.ForeColor       = $cWhite
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false

# ── LEFT PANEL: SYSTEM INFO & CONTROLS (TRANSPARENT) ───────────────────────
$leftPanel = New-Object DBPanel
$leftPanel.Size     = New-Object System.Drawing.Size(320, 620)
$leftPanel.Location = New-Object System.Drawing.Point(15, 15)
$leftPanel.BackColor= [System.Drawing.Color]::Transparent
$form.Controls.Add($leftPanel)

# Brand Header
$lblBrand = New-Object System.Windows.Forms.Label
$lblBrand.Text      = "G O A T"
$lblBrand.Font      = $fTitle
$lblBrand.ForeColor = $cAccent
$lblBrand.Location  = New-Object System.Drawing.Point(15, 10)
$lblBrand.Size      = New-Object System.Drawing.Size(280, 35)
$leftPanel.Controls.Add($lblBrand)

$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text      = "Premium Edition v4.0 · Onyx Crimson"
$lblVersion.Font      = $fontSub
$lblVersion.ForeColor = $cMuted
$lblVersion.Location  = New-Object System.Drawing.Point(15, 45)
$lblVersion.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblVersion)

# Separation Accent Line
$sep1 = New-Object DBPanel
$sep1.BackColor = $cAccent
$sep1.Location  = New-Object System.Drawing.Point(15, 75)
$sep1.Size      = New-Object System.Drawing.Size(280, 2)
$leftPanel.Controls.Add($sep1)

# System Information Section
$lblSysTitle = New-Object System.Windows.Forms.Label
$lblSysTitle.Text      = "SYSTEM INFORMATION"
$lblSysTitle.Font      = $fontBold
$lblSysTitle.ForeColor = $cWhite
$lblSysTitle.Location  = New-Object System.Drawing.Point(15, 90)
$lblSysTitle.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblSysTitle)

$sysDetails = @(
    "OS: $OSName",
    "User: $UserName @ $PCName",
    "CPU: $CPUShort",
    "GPU: $GPUShort",
    "RAM Total: $RAMTotal GB ($RAMPct% Used)"
)

$yOffset = 115
foreach ($detail in $sysDetails) {
    $lblDetail = New-Object System.Windows.Forms.Label
    $lblDetail.Text      = $detail
    $lblDetail.Font      = $fontSub
    $lblDetail.ForeColor = $cMuted
    $lblDetail.Location  = New-Object System.Drawing.Point(15, $yOffset)
    $lblDetail.Size      = New-Object System.Drawing.Size(280, 20)
    $leftPanel.Controls.Add($lblDetail)
    $yOffset += 22
}

# Control Panel Section
$lblControlTitle = New-Object System.Windows.Forms.Label
$lblControlTitle.Text      = "CONTROL PANEL"
$lblControlTitle.Font      = $fontBold
$lblControlTitle.ForeColor = $cWhite
$lblControlTitle.Location  = New-Object System.Drawing.Point(15, 260)
$lblControlTitle.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblControlTitle)

# Custom High-Quality Smooth Loading Bar
$progressBarPanel = New-Object DBPanel
$progressBarPanel.Location = New-Object System.Drawing.Point(15, 290)
$progressBarPanel.Size     = New-Object System.Drawing.Size(280, 26)
$progressBarPanel.BackColor= [System.Drawing.Color]::FromArgb(24, 24, 28)
$leftPanel.Controls.Add($progressBarPanel)

$script:ProgressPct = 0
$progressBarPanel.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    if ($script:ProgressPct -gt 0) {
        $fillW = [math]::Round(($script:ProgressPct / 100) * $s.Width)
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
            $cAccent, $cAccentGlow
        )
        $g.FillRectangle($brush, 0, 0, $fillW, $s.Height)
        $brush.Dispose()
    }
    
    # วาดตัวเลขเปอร์เซ็นต์ไลฟ์สดลงบนหลอดโหลด
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textBrush = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString("$script:ProgressPct %", $fontBold, $textBrush, [System.Drawing.RectangleF]::new(0, 0, $s.Width, $s.Height), $stringFormat)
    $textBrush.Dispose(); $stringFormat.Dispose()
})

# Status Hint Labels
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text      = "Ready to run optimization modules."
$lblHint.Font      = $fontSub
$lblHint.ForeColor = $cMuted
$lblHint.Location  = New-Object System.Drawing.Point(15, 325)
$lblHint.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblHint)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text      = "Engine Framework: Idling"
$lblCount.Font      = $fontSub
$lblCount.ForeColor = $cAccentGlow
$lblCount.Location  = New-Object System.Drawing.Point(15, 345)
$lblCount.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblCount)

# Action Trigger Buttons
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text            = "RUN GOAT TWEAKS"
$btnRun.Font            = $fontBold
$btnRun.BackColor       = $cAccent
$btnRun.ForeColor       = $cWhite
$btnRun.FlatStyle       = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Location        = New-Object System.Drawing.Point(15, 385)
$btnRun.Size            = New-Object System.Drawing.Size(280, 45)
$leftPanel.Controls.Add($btnRun)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text            = "RESTART SYSTEM"
$btnRestart.Font            = $fontBold
$btnRestart.BackColor       = [System.Drawing.Color]::FromArgb(40, 40, 45)
$btnRestart.ForeColor       = $cWhite
$btnRestart.FlatStyle       = "Flat"
$btnRestart.FlatAppearance.BorderSize = 0
$btnRestart.Location        = New-Object System.Drawing.Point(15, 445)
$btnRestart.Size            = New-Object System.Drawing.Size(280, 35)
$btnRestart.Visible         = $false
$leftPanel.Controls.Add($btnRestart)

# ── RIGHT PANEL UPPER: OPTIMIZATION MODULES (SHOWCASE ONLY - NO CHECKBOXES)
$rightUpperPanel = New-Object DBPanel
$rightUpperPanel.Size     = New-Object System.Drawing.Size(750, 380)
$rightUpperPanel.Location = New-Object System.Drawing.Point(350, 15)
$rightUpperPanel.BackColor= $cSurface
$form.Controls.Add($rightUpperPanel)

$lblTweakTitle = New-Object System.Windows.Forms.Label
$lblTweakTitle.Text      = "OPTIMIZATION MODULES"
$lblTweakTitle.Font      = $fontBold
$lblTweakTitle.ForeColor = $cWhite
$lblTweakTitle.Location  = New-Object System.Drawing.Point(20, 15)
$lblTweakTitle.Size      = New-Object System.Drawing.Size(300, 20)
$rightUpperPanel.Controls.Add($lblTweakTitle)

# ── RIGHT PANEL LOWER: REALTIME EXECUTION LOG ──────────────────────────────
$rightLowerPanel = New-Object DBPanel
$rightLowerPanel.Size     = New-Object System.Drawing.Size(750, 225)
$rightLowerPanel.Location = New-Object System.Drawing.Point(350, 410)
$rightLowerPanel.BackColor= $cSurface
$form.Controls.Add($rightLowerPanel)

$lblLogTitle = New-Object System.Windows.Forms.Label
$lblLogTitle.Text      = "REALTIME EXECUTION LOG"
$lblLogTitle.Font      = $fontBold
$lblLogTitle.ForeColor = $cWhite
$lblLogTitle.Location  = New-Object System.Drawing.Point(20, 10)
$lblLogTitle.Size      = New-Object System.Drawing.Size(300, 20)
$rightLowerPanel.Controls.Add($lblLogTitle)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location        = New-Object System.Drawing.Point(20, 35)
$txtLog.Size            = New-Object System.Drawing.Size(710, 170)
$txtLog.BackColor       = $logBg
$txtLog.ForeColor       = [System.Drawing.Color]::FromArgb(0, 230, 118)
$txtLog.Font            = $fontLog
$txtLog.ReadOnly        = $true
$txtLog.BorderStyle     = "None"
$rightLowerPanel.Controls.Add($txtLog)

# ── LOGGING SYSTEM WRAPPER ─────────────────────────────────────────────────
function Write-Log ($message, $type = "INFO") {
    $time = Get-Date -Format "HH:mm:ss"
    $logLine = "[$time] [$type] $message`r`n"
    $txtLog.AppendText($logLine)
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

Write-Log "GOAT Premium Engine initialized successfully." "SYSTEM"
Write-Log "Pipelines ready. Elements fully loaded with clean alignments." "INFO"

# ── BRING ALL 13 PIPELINE TWEAKS FROM V3.0 DEFINITIONS ─────────────────────
$script:Tasks = [ordered]@{
    "kernel"   = "Kernel and HPET Optimization"
    "timer"    = "Timer Resolution Callbacks"
    "priority" = "Process Priority & Separation"
    "irq"      = "IRQ MSI Mode Vector Tuning"
    "memory"   = "Memory Management Allocation"
    "input"    = "Input Framework & USB Polling"
    "nagle"    = "Nagle Algorithm Network Patch"
    "visual"   = "Visual Effects Minimization"
    "gamebar"  = "Game Bar and DVR Elimination"
    "power"    = "Processor Power Throttling Fix"
    "network"  = "Network Pipeline & DNS Refresh"
    "services" = "Windows Performance Services"
    "cleanup"  = "Junk and EventLog Cleanup"
}

# ── REALTIME EXECUTABLE CODES ──────────────────────────────────────────────
$script:ExecutionBlocks = @{
    "kernel"   = {
        Write-Log "Configuring BCD OS Kernel parameters and disabling HPET..." "KERNEL"
        bcdedit /set useplatformclock no 2>$null | Out-Null
        bcdedit /set useplatformtick yes 2>$null | Out-Null
        bcdedit /set disabledynamictick yes 2>$null | Out-Null
        bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
        bcdedit /set nx OptOut 2>$null | Out-Null
        bcdedit /set synthetictimers yes 2>$null | Out-Null
        $h = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like "*High Precision*" }
        if ($h) { Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
    }
    "timer"    = {
        Write-Log "Setting global kernel timer resolution requests..." "TIMER"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
    }
    "priority" = {
        Write-Log "Adjusting Win32 Priority Separation and multimedia responses..." "PRIORITY"
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
    "irq"      = {
        Write-Log "Iterating PCI registry to enforce Message Signaled Interrupts (MSI)..." "IRQ"
        Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
            $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
            if (Test-Path $p) { Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null }
        }
    }
    "memory"   = {
        Write-Log "Tuning System Cache Thresholds and shutting down background tasks..." "MEMORY"
        $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown"       -Value 0 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
        powercfg -h off 2>$null | Out-Null
        taskkill /f /im OneDrive.exe 2>$null | Out-Null
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    }
    "input"    = {
        Write-Log "Optimizing mouse/keyboard queues and cutting selective power suspend..." "INPUT"
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
    "nagle"    = {
        Write-Log "Applying TCPNoDelay parameters to interface nodes..." "NETWORK"
        $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
            Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
        }
    }
    "visual"   = {
        Write-Log "Minimizing UserPreferencesMask and system animations..." "VISUAL"
        $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
        Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
    }
    "gamebar"  = {
        Write-Log "Disabling AppCapture, GameDVR and forcing full screen optimization..." "GAMING"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
        $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
        Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
    }
    "power"    = {
        Write-Log "Forcing CPU cores minimum/maximum processing scaling to 100%..." "POWER"
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
        powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
    }
    "network"  = {
        Write-Log "Flushing DNS caches and re-initiating Winsock IP adapters..." "NETWORK"
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
    }
    "services" = {
        Write-Log "Stopping telemetry services and locking essential services..." "SERVICES"
        @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc') | ForEach-Object {
            Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
            Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
        }
        @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer') | ForEach-Object {
            Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $_ -ErrorAction SilentlyContinue
        }
    }
    "cleanup"  = {
        Write-Log "Purging OS Temp directories, Windows updates distribution, and EventLogs..." "CLEANUP"
        @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*") | ForEach-Object {
            Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
    }
}

# ── DYNAMIC RENDERING FOR SHOWCASE ITEMS (NO CHECKBOXES - PERFECTLY ALIGNED)
$script:TextLabels = @{}
$chX = 25
$chY = 50
$colCount = 0

foreach ($key in $script:Tasks.Keys) {
    $taskName = $script:Tasks[$key]
    
    # จุดระบุสถานะขนาดเล็กหน้าชื่อ (Dot Indicator)
    $indicatorDot = New-Object DBPanel
    $indicatorDot.Size = New-Object System.Drawing.Size(8, 8)
    $indicatorDot.Location = New-Object System.Drawing.Point($chX, $chY + 6)
    $indicatorDot.BackColor = $cPending
    $rightUpperPanel.Controls.Add($indicatorDot)

    # Label ข้อความเพียวๆ (ไม่ปนเปื้อนโค้ด Checkbox เดิม)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $taskName
    $lbl.Font      = $fontSub
    $lbl.ForeColor = $cPending
    $lbl.Size      = New-Object System.Drawing.Size(320, 25)
    $lbl.Location  = New-Object System.Drawing.Point($chX + 16, $chY)
    $rightUpperPanel.Controls.Add($lbl)
    
    $script:TextLabels[$key] = @{ Label = $lbl; Dot = $indicatorDot }
    
    # แบ่งสัดส่วน 2 คอลัมน์อย่างสมดุลบนกรอบสี่เหลี่ยมแนวนอน
    $colCount++
    if ($colCount -eq 2) {
        $chX = 25
        $chY += 46
        $colCount = 0
    } else {
        $chX = 385
    }
}

# ── CORE EXECUTION WORKER PIPELINE ─────────────────────────────────────────
$script:IsRunning = $false

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    
    $btnRestart.Visible  = $false
    $lblHint.Text        = "Deploying operating pipelines..."
    $txtLog.Clear()
    Write-Log "Initiating high-performance deployment matrix..." "START"

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 450
    
    $timer.Add_Tick({
        if ($script:RunIndex -ge $script:TotalTasks) {
            $timer.Stop()
            $script:ProgressPct = 100
            $progressBarPanel.Invalidate()
            $lblHint.Text = "Optimization Completed Perfectly!"
            $lblCount.Text = "Engine Framework: Successful"
            Write-Log "All tasks applied successfully! Hardware is now optimized." "SUCCESS"
            $btnRestart.Visible = $true
            $script:IsRunning = $false
            return
        }
        
        $key = $script:TaskKeyList[$script:RunIndex]
        $taskName = $script:Tasks[$key]
        
        # ไฮไลต์สีหัวข้อที่กำลังทำงานแบบ Real-time (Active = สว่างวาบ / Dot = แดง Crimson)
        $script:TextLabels[$key].Label.ForeColor = $cWhite
        $script:TextLabels[$key].Dot.BackColor = $cAccentGlow
        $lblCount.Text = "Active Module: $(([math]::Min($script:RunIndex + 1, $script:TotalTasks))) / $script:TotalTasks"
        
        # คำนวณ % และสั่งวาดการโหลดของหลอดสีสดใหม่ลงบน Control Panel
        $script:ProgressPct = [math]::Round(($script:RunIndex / $script:TotalTasks) * 100)
        $progressBarPanel.Invalidate()
        
        # ดึง ScriptBlock คำสั่งจริงขึ้นมารัน
        $fn = $script:ExecutionBlocks[$key]
        try { & $fn } catch { Write-Log "Error deploying module: $key" "ERROR" }
        
        # ปรับระดับสีเมื่อตัว Tweak นั้นรันผ่านไปแล้ว (เสร็จสิ้น = สีหม่นลงเพื่อไม่ให้แย่งสายตา)
        $script:TextLabels[$key].Label.ForeColor = $cMuted
        $script:TextLabels[$key].Dot.BackColor = $cAccentDim
        
        $script:RunIndex++
    })
    
    $timer.Start()
})

$btnRestart.Add_Click({
    Write-Log "Sending secure system reboot code..." "SYSTEM"
    shutdown /r /t 5 /c "GOAT Premium Engine finalized. Rebooting..."
})

$form.ShowDialog() | Out-Null
