#Requires -Version 5.1

<#
GOAT - GREATEST OF ALL TWEAKS
GUI Edition v3.0 - Monochrome Dark Theme
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

$CPUShort  = if ($CPU.Length -gt 30) { $CPU.Substring(0,30)+"…" } else { $CPU }
$GPUShort  = if ($GPU.Length -gt 30) { $GPU.Substring(0,30)+"…" } else { $GPU }
$OSShort   = if ($OSName.Length -gt 30) { $OSName.Substring(0,30)+"…" } else { $OSName }
$UserShort = if ("$UserName @ $PCName".Length -gt 30) { "$UserName @ $PCName".Substring(0,30)+"…" } else { "$UserName @ $PCName" }

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
$cDone      = [System.Drawing.Color]::FromArgb(100, 100, 100)
$cDoneDim   = [System.Drawing.Color]::FromArgb(40, 40, 40)
$cGreen     = [System.Drawing.Color]::FromArgb(160, 200, 120)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fMono8    = New-Object System.Drawing.Font("Consolas", 8)
$fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$fMono10   = New-Object System.Drawing.Font("Consolas", 10)
$fMonoBold = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$fLogo     = New-Object System.Drawing.Font("Arial Black", 42, [System.Drawing.FontStyle]::Bold)
$fLogoBold = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)

# ── TASK DEFINITIONS ───────────────────────────────────────────────────────
$script:Tasks = [ordered]@{
    "kernel"   = "Kernel and HPET"
    "timer"    = "Timer Resolution"
    "priority" = "Process Priority"
    "irq"      = "IRQ MSI Mode"
    "memory"   = "Memory Management"
    "input"    = "Input and USB"
    "nagle"    = "Nagle Algorithm"
    "visual"   = "Visual Effects"
    "gamebar"  = "Game Bar and DVR"
    "power"    = "Processor Power"
    "network"  = "Network and DNS"
    "services" = "Windows Services"
    "cleanup"  = "Junk and Log Cleanup"
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
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
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

# ── FORM ───────────────────────────────────────────────────────────────────
[int]$rowH       = 40
[int]$taskCount  = 13
[int]$listHeight = ($taskCount * $rowH) + 20   # 540
[int]$formWidth = 1240 # New width for horizontal layout
[int]$formHeight = 36 + 155 + 28 + ($listHeight + 20) + 86 + 10 # Adjusted height for horizontal layout

$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT // GREATEST OF ALL TWEAKS v3.0"
$form.Size            = New-Object System.Drawing.Size($formWidth, $formHeight)
$form.MinimumSize     = New-Object System.Drawing.Size($formWidth, $formHeight)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false
$form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── SCANLINE ANIMATION TIMER ───────────────────────────────────────────────
$script:ScanY = -2
$scanTimer = New-Object System.Windows.Forms.Timer
$scanTimer.Interval = 18

# ── TOP BAR ────────────────────────────────────────────────────────────────
$topBar = New-Object System.Windows.Forms.Panel
$topBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$topBar.Height    = 36
$topBar.BackColor = $cSurface

$topBar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
})

$lblTopTitle = New-Object System.Windows.Forms.Label
$lblTopTitle.Text      = "GOAT.ps1  —  admin"
$lblTopTitle.Font      = $fMono8
$lblTopTitle.ForeColor = $cGray
$lblTopTitle.AutoSize  = $false
$lblTopTitle.Size      = New-Object System.Drawing.Size(300, 36)
$lblTopTitle.Location  = New-Object System.Drawing.Point(60, 0)
$lblTopTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblTopTitle.BackColor = [System.Drawing.Color]::Transparent
$topBar.Controls.Add($lblTopTitle)

$lblAdminBadge = New-Object System.Windows.Forms.Label
$lblAdminBadge.Text      = "ADMIN"
$lblAdminBadge.Font      = $fMono8
$lblAdminBadge.ForeColor = $cGray
$lblAdminBadge.AutoSize  = $false
$lblAdminBadge.Size      = New-Object System.Drawing.Size(60, 18)
$lblAdminBadge.Location  = New-Object System.Drawing.Point($formWidth - 80, 9)
$lblAdminBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblAdminBadge.BackColor = $cSurface2
$topBar.Controls.Add($lblAdminBadge)

$topBar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $g.DrawRectangle($pen, $formWidth - 80, 9, 60, 18)
    $pen.Dispose()
    foreach ($pos in @(12, 22, 32)) {
        $br = New-Object System.Drawing.SolidBrush($cGrayDim)
        $g.FillEllipse($br, $pos, 13, 8, 8)
        $br.Dispose()
    }
})

# ── HERO PANEL ─────────────────────────────────────────────────────────────
$heroPanel = New-Object System.Windows.Forms.Panel
$heroPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$heroPanel.Height    = 155
$heroPanel.BackColor = $cSurface

$heroPanel.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # scanline
    $scanBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18,255,255,255))
    $g.FillRectangle($scanBr, 0, $script:ScanY, $s.Width, 2)
    $scanBr.Dispose()

    # logo outline
    $gp   = New-Object System.Drawing.Drawing2D.GraphicsPath
    $sf   = [System.Drawing.StringFormat]::GenericDefault
    $gp.AddString("GOAT", $fLogo.FontFamily, [int][System.Drawing.FontStyle]::Bold, $g.DpiY * 42 / 72, [System.Drawing.PointF]::new(20, 18), $sf)
    $outPen = New-Object System.Drawing.Pen($cWhite, 1.2)
    $g.DrawPath($outPen, $gp)
    $outPen.Dispose(); $gp.Dispose()

    # subtitle
    $subBr = New-Object System.Drawing.SolidBrush($cGray)
    $subFont = New-Object System.Drawing.Font("Consolas", 8)
    $g.DrawString("GREATEST OF ALL TWEAKS  ·  v3.0", $subFont, $subBr, 24, 120)
    $subBr.Dispose(); $subFont.Dispose()

    # sys info right
    $sysBr  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(55,55,55))
    $sysVal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(110,110,110))
    $sf2    = New-Object System.Drawing.StringFormat
    $sf2.Alignment = [System.Drawing.StringAlignment]::Far
    $sf3    = New-Object System.Drawing.StringFormat
    $sf3.Alignment = [System.Drawing.StringAlignment]::Near
    $sysF   = New-Object System.Drawing.Font("Consolas", 8)
    $rightX = $s.Width - 24

    $rows = @(18, 38, 58, 78, 98)
    $lblX = $rightX - 200

    $g.DrawString("USER", $sysF, $sysBr, $lblX, $rows[0], $sf2)
    $g.DrawString($UserShort, $sysF, $sysVal, $rightX, $rows[0], $sf2)
    $g.DrawString("CPU",  $sysF, $sysBr, $lblX, $rows[1], $sf2)
    $g.DrawString($CPUShort, $sysF, $sysVal, $rightX, $rows[1], $sf2)
    $g.DrawString("GPU",  $sysF, $sysBr, $lblX, $rows[2], $sf2)
    $g.DrawString($GPUShort, $sysF, $sysVal, $rightX, $rows[2], $sf2)
    $g.DrawString("RAM",  $sysF, $sysBr, $lblX, $rows[3], $sf2)
    $ramStr = "$RAMUsed / $($RAMTotal) GB  ($RAMPct%)"
    $g.DrawString($ramStr, $sysF, $sysVal, $rightX, $rows[3], $sf2)
    $g.DrawString("OS",   $sysF, $sysBr, $lblX, $rows[4], $sf2)
    $g.DrawString($OSShort, $sysF, $sysVal, $rightX, $rows[4], $sf2)

    $divPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30,30,30), 1)
    $g.DrawLine($divPen, $s.Width - 300, 10, $s.Width - 300, $s.Height - 14)
    $divPen.Dispose()

    $sysBr.Dispose(); $sysVal.Dispose(); $sysF.Dispose(); $sf2.Dispose(); $sf3.Dispose()

    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
})

$scanTimer.Add_Tick({
    $script:ScanY += 3
    if ($script:ScanY -gt $heroPanel.Height + 4) { $script:ScanY = -2 }
    $heroPanel.Invalidate()
})
$scanTimer.Start()

# ── SECTION HEADER ─────────────────────────────────────────────────────────
$sectionBar = New-Object System.Windows.Forms.Panel
$sectionBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$sectionBar.Height    = 28
$sectionBar.BackColor = $cBg

$lblSection = New-Object System.Windows.Forms.Label
$lblSection.Text      = "OPTIMIZATION MODULES"
$lblSection.Font      = $fMono8
$lblSection.ForeColor = $cGrayDim
$lblSection.AutoSize  = $false
$lblSection.Size      = New-Object System.Drawing.Size(300, 28)
$lblSection.Location  = New-Object System.Drawing.Point(24, 0)
$lblSection.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblSection.BackColor = [System.Drawing.Color]::Transparent
$sectionBar.Controls.Add($lblSection)

$lblDoneCount = New-Object System.Windows.Forms.Label
$lblDoneCount.Text      = "0 / 13"
$lblDoneCount.Font      = $fMono8
$lblDoneCount.ForeColor = $cGrayDim
$lblDoneCount.AutoSize  = $false
$lblDoneCount.Size      = New-Object System.Drawing.Size(50, 18)
$lblDoneCount.Location  = New-Object System.Drawing.Point($formWidth - 80, 5)
$lblDoneCount.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblDoneCount.BackColor = $cSurface2
$sectionBar.Controls.Add($lblDoneCount)

$sectionBar.Add_Paint({
    param($s,$e)
    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $e.Graphics.DrawRectangle($pen, $formWidth - 80, 5, 50, 18)
    $pen.Dispose()
})

# ── FOOTER ─────────────────────────────────────────────────────────────────
$footer = New-Object System.Windows.Forms.Panel
$footer.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$footer.Height    = 86
$footer.BackColor = $cSurface

$footer.Add_Paint({
    param($s,$e)
    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
    $pen.Dispose()
})

# Progress Area (Left)
$overallTrack = New-Object System.Windows.Forms.Panel
$overallTrack.Location  = New-Object System.Drawing.Point(24, 18)
$overallTrack.Size      = New-Object System.Drawing.Size($formWidth - 300, 8)
$overallTrack.BackColor = $cBorderDim
$footer.Controls.Add($overallTrack)

$overallFill = New-Object System.Windows.Forms.Panel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 8)
$overallFill.BackColor = $cWhite
$overallTrack.Controls.Add($overallFill)

$lblPct = New-Object System.Windows.Forms.Label
$lblPct.Text      = "PROGRESS  0%  ·  READY"
$lblPct.Font      = $fMono8
$lblPct.ForeColor = $cWhiteDim
$lblPct.AutoSize  = $false
$lblPct.Size      = New-Object System.Drawing.Size($formWidth - 300, 18)
$lblPct.Location  = New-Object System.Drawing.Point(24, 36)
$lblPct.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblPct.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblPct)

$lblFooterHint = New-Object System.Windows.Forms.Label
$lblFooterHint.Text      = "Run GOAT to apply performance tweaks. Restart is recommended after completion."
$lblFooterHint.Font      = $fMono8
$lblFooterHint.ForeColor = $cGrayDim
$lblFooterHint.AutoSize  = $false
$lblFooterHint.Size      = New-Object System.Drawing.Size($formWidth - 300, 18)
$lblFooterHint.Location  = New-Object System.Drawing.Point(24, 56)
$lblFooterHint.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblFooterHint.BackColor = [System.Drawing.Color]::Transparent
$footer.Controls.Add($lblFooterHint)

# Action Buttons (Right)
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART PC"
$btnRestart.Font      = $fMono9
$btnRestart.ForeColor = $cGray
$btnRestart.BackColor = $cSurface2
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cBorder
$btnRestart.FlatAppearance.BorderSize  = 1
$btnRestart.Size      = New-Object System.Drawing.Size(110, 34)
$btnRestart.Location  = New-Object System.Drawing.Point($formWidth - 250, 26)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({
    $answer = [System.Windows.Forms.MessageBox]::Show("Restart this PC now?", "GOAT Complete", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($answer -eq [System.Windows.Forms.DialogResult]::Yes) { Restart-Computer -Force }
})
$footer.Controls.Add($btnRestart)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "RUN GOAT"
$btnRun.Font      = $fMonoBold
$btnRun.ForeColor = $cBg
$btnRun.BackColor = $cWhite
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize  = 0
$btnRun.Size      = New-Object System.Drawing.Size(110, 34)
$btnRun.Location      = New-Object System.Drawing.Point($formWidth - 128, 26)
$footer.Controls.Add($btnRun)

# ── MAIN CONTENT CONTAINER ──────────────────────────────────────────────────
$mainContent = New-Object System.Windows.Forms.Panel
$mainContent.Dock      = [System.Windows.Forms.DockStyle]::Fill
$mainContent.BackColor = $cBg
$mainContent.Padding   = New-Object System.Windows.Forms.Padding(24, 10, 24, 10)

# ── TASK SCROLL PANEL ──────────────────────────────────────────────────────
$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.Size         = New-Object System.Drawing.Size(760, $listHeight + 20)
$scrollPanel.Location     = New-Object System.Drawing.Point(24, 10)
$scrollPanel.BackColor   = $cBg
$scrollPanel.AutoScroll  = $true
$mainContent.Controls.Add($scrollPanel)

# ── LIVE LOG PANEL ──────────────────────────────────────────────────────────
[int]$logPanelWidth = 400
[int]$logPanelHeight = $listHeight + 20

$logPanel = New-Object System.Windows.Forms.Panel
$logPanel.Size      = New-Object System.Drawing.Size($logPanelWidth, $logPanelHeight)
$logPanel.Location  = New-Object System.Drawing.Point(24 + 760 + 20, 10)
$logPanel.BackColor = $cSurface2
$logPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$mainContent.Controls.Add($logPanel)

$logTitle = New-Object System.Windows.Forms.Label
$logTitle.Text      = "OPTIMIZATION LOG"
$logTitle.Font      = $fMonoBold
$logTitle.ForeColor = $cWhite
$logTitle.AutoSize  = $false
$logTitle.Size      = New-Object System.Drawing.Size($logPanelWidth - 20, 20)
$logTitle.Location  = New-Object System.Drawing.Point(10, 10)
$logTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$logPanel.Controls.Add($logTitle)

$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Text            = "Ready to optimize system..."
$logTextBox.Font            = $fMono9
$logTextBox.ForeColor       = $cWhiteDim
$logTextBox.BackColor       = $cSurface2
$logTextBox.BorderStyle     = [System.Windows.Forms.BorderStyle]::None
$logTextBox.Multiline       = $true
$logTextBox.ReadOnly        = $true
$logTextBox.ScrollBars      = [System.Windows.Forms.ScrollBars]::Vertical
$logTextBox.Size            = New-Object System.Drawing.Size($logPanelWidth - 20, $logPanelHeight - 45)
$logTextBox.Location        = New-Object System.Drawing.Point(10, 35)
$logPanel.Controls.Add($logTextBox)

# ── ADD CONTROLS TO FORM ──────────────────────────────────────────────────
# Order: Bottom, Fill, then Top panels (last added is topmost)
$form.Controls.Add($footer)      # Bottom
$form.Controls.Add($mainContent) # Fill middle
$form.Controls.Add($sectionBar)  # Top
$form.Controls.Add($heroPanel)   # Top
$form.Controls.Add($topBar)      # Top

# ── BUILD TASK ROWS ────────────────────────────────────────────────────────
$script:TaskRows = @{}
$taskKeys        = @($script:Tasks.Keys)
[int]$yPos       = 6
[int]$totalH     = $taskKeys.Count * $rowH + 20

$innerPanel = New-Object System.Windows.Forms.Panel
$innerPanel.Size      = New-Object System.Drawing.Size(740, $totalH)
$innerPanel.Location  = New-Object System.Drawing.Point(0, 0)
$innerPanel.BackColor = [System.Drawing.Color]::Transparent
$scrollPanel.Controls.Add($innerPanel)

$taskIndex = 0
foreach ($key in $taskKeys) {
    $label    = $script:Tasks[$key]
    $idxLabel = ($taskIndex + 1).ToString("00")

    $row = New-Object System.Windows.Forms.Panel
    $row.Size      = New-Object System.Drawing.Size(740, $rowH)
    $row.Location  = New-Object System.Drawing.Point(0, $yPos)
    $row.BackColor = [System.Drawing.Color]::Transparent
    $row.Tag       = "pending"
    $innerPanel.Controls.Add($row)

    $row.Add_Paint({
        param($s,$e)
        $g    = $e.Graphics
        $state = $s.Tag

        if ($state -eq "running") {
            $hBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22,22,22))
            $g.FillRectangle($hBr, 0, 0, $s.Width, $s.Height)
            $hBr.Dispose()
            $hPen = New-Object System.Drawing.Pen($cBorder, 1)
            $g.DrawLine($hPen, 0, 0, $s.Width, 0)
            $g.DrawLine($hPen, 0, $s.Height-1, $s.Width, $s.Height-1)
            $hPen.Dispose()
        }

        $sepPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(20,20,20), 1)
        $g.DrawLine($sepPen, 24, $s.Height-1, $s.Width-24, $s.Height-1)
        $sepPen.Dispose()
    })

    # index
    $lblIdx = New-Object System.Windows.Forms.Label
    $lblIdx.Text      = $idxLabel
    $lblIdx.Font      = $fMono8
    $lblIdx.ForeColor = $cGrayDim
    $lblIdx.AutoSize  = $false
    $lblIdx.Size      = New-Object System.Drawing.Size(28, $rowH)
    $lblIdx.Location  = New-Object System.Drawing.Point(24, 0)
    $lblIdx.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $lblIdx.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblIdx)

    # dot indicator
    $dot = New-Object System.Windows.Forms.Panel
    $dot.Size      = New-Object System.Drawing.Size(10, 10)
    $dot.Location  = New-Object System.Drawing.Point(62, 14)
    $dot.BackColor = [System.Drawing.Color]::Transparent
    $dot.Tag       = "pending"
    $dot.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        switch ($s.Tag) {
            "pending" {
                $pen = New-Object System.Drawing.Pen($cGrayDim, 1)
                $g.DrawEllipse($pen, 1, 1, 7, 7)
                $pen.Dispose()
            }
            "running" {
                $br = New-Object System.Drawing.SolidBrush($cWhite)
                $g.FillEllipse($br, 1, 1, 7, 7)
                $br.Dispose()
            }
            "done" {
                $br = New-Object System.Drawing.SolidBrush($cGray)
                $g.FillEllipse($br, 1, 1, 7, 7)
                $br.Dispose()
                $ckPen = New-Object System.Drawing.Pen($cSurface, 1.2)
                $g.DrawLine($ckPen, 2, 5, 4, 7)
                $g.DrawLine($ckPen, 4, 7, 8, 3)
                $ckPen.Dispose()
            }
        }
    })
    $row.Controls.Add($dot)

    # name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $label
    $lblName.Font      = $fMono10
    $lblName.ForeColor = $cGrayDim
    $lblName.AutoSize  = $false
    $lblName.Size      = New-Object System.Drawing.Size(220, $rowH)
    $lblName.Location  = New-Object System.Drawing.Point(82, 0)
    $lblName.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $lblName.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblName)

    # bar track
    $barTrack = New-Object System.Windows.Forms.Panel
    $barTrack.Location  = New-Object System.Drawing.Point(316 - 40, 18)
    $barTrack.Size      = New-Object System.Drawing.Size(360, 4)
    $barTrack.BackColor = $cBorderDim
    $row.Controls.Add($barTrack)

    $barFill = New-Object System.Windows.Forms.Panel
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barFill.Size      = New-Object System.Drawing.Size(0, 4)
    $barFill.BackColor = $cWhite
    $barTrack.Controls.Add($barFill)

    # status
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text      = "pending"
    $lblStatus.Font      = $fMono8
    $lblStatus.ForeColor = $cGrayDim
    $lblStatus.AutoSize  = $false
    $lblStatus.Size      = New-Object System.Drawing.Size(72, $rowH)
    $lblStatus.Location  = New-Object System.Drawing.Point(708 - 40, 0)
    $lblStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $lblStatus.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblStatus)

    $script:TaskRows[$key] = @{
        Row    = $row
        Idx    = $lblIdx
        Dot    = $dot
        Name   = $lblName
        Bar    = $barFill
        Track  = $barTrack
        Status = $lblStatus
    }

    $yPos      += $rowH
    $taskIndex++
}

# ── BLINK TIMER ────────────────────────────────────────────────────────────
$script:BlinkOn    = $true
$script:BlinkKey   = $null
$blinkTimer        = New-Object System.Windows.Forms.Timer
$blinkTimer.Interval = 520
$blinkTimer.Add_Tick({
    if ($script:BlinkKey -and $script:TaskRows.ContainsKey($script:BlinkKey)) {
        $r = $script:TaskRows[$script:BlinkKey]
        $r.Dot.Tag = "running"
        $r.Dot.Invalidate()
        $script:BlinkOn = -not $script:BlinkOn
    }
})

# ── STATE SETTER ───────────────────────────────────────────────────────────
function Set-TaskState ($key, $state) {
    if (-not $script:TaskRows.ContainsKey($key)) { return }
    $r = $script:TaskRows[$key]
    switch ($state) {
        "running" {
            $r.Row.Tag         = "running"
            $r.Dot.Tag         = "running"
            $r.Idx.ForeColor   = $cWhiteDim
            $r.Name.ForeColor  = $cWhite
            $r.Name.Font       = $fLogoBold
            $r.Status.Text     = "running..."
            $r.Status.ForeColor = $cWhiteDim
            $r.Bar.BackColor   = $cWhite
            $r.Bar.Width       = 60
            $r.Row.Invalidate()
            $r.Dot.Invalidate()
            $script:BlinkKey = $key
            $blinkTimer.Start()
        }
        "done" {
            $blinkTimer.Stop()
            $script:BlinkKey = $null
            $r.Row.Tag         = "done"
            $r.Dot.Tag         = "done"
            $r.Idx.ForeColor   = $cGray
            $r.Name.ForeColor  = $cGray
            $r.Name.Font       = $fMono10
            $r.Status.Text     = "done"
            $r.Status.ForeColor = $cGray
            $r.Bar.BackColor   = $cGray
            $r.Bar.Width       = $r.Track.Width
            $r.Row.Invalidate()
            $r.Dot.Invalidate()
        }
    }
}

# ── SMOOTH BAR ANIMATION TIMER ─────────────────────────────────────────────
$script:AnimKey    = $null
$script:AnimTarget = 0
$animTimer         = New-Object System.Windows.Forms.Timer
$animTimer.Interval = 16
$animTimer.Add_Tick({
    if ($script:AnimKey -and $script:TaskRows.ContainsKey($script:AnimKey)) {
        $bar = $script:TaskRows[$script:AnimKey].Bar
        if ($bar.Width -lt $script:AnimTarget) {
            $bar.Width = [math]::Min($bar.Width + 6, $script:AnimTarget)
        }
    }
})

# ── PROGRESS AND ACTION HELPERS ────────────────────────────────────────────
function Set-OverallProgress ([int]$done, [int]$total, [string]$stateText) {
    if ($total -le 0) { $total = 1 }
    $pct = [math]::Round(($done / $total) * 100)
    $pct = [math]::Max(0, [math]::Min(100, $pct))
    $overallFill.Width = [math]::Round($overallTrack.Width * $pct / 100)
    $lblPct.Text       = "PROGRESS  $pct%  ·  $stateText"
    $lblDoneCount.Text = "$done / $total"
    $sectionBar.Invalidate()
}

function Set-RunButtonStyle ([string]$mode) {
    switch ($mode) {
        "ready" {
            $btnRun.Enabled = $true
            $btnRun.Text = "RUN GOAT"
            $btnRun.BackColor = $cWhite
            $btnRun.ForeColor = $cBg
            $btnRun.FlatAppearance.BorderSize = 0
        }
        "running" {
            $btnRun.Enabled = $false
            $btnRun.Text = "RUNNING..."
            $btnRun.BackColor = $cSurface2
            $btnRun.ForeColor = $cGrayDim
            $btnRun.FlatAppearance.BorderColor = $cBorder
            $btnRun.FlatAppearance.BorderSize = 1
        }
        "complete" {
            $btnRun.Enabled = $false
            $btnRun.Text = "COMPLETE"
            $btnRun.BackColor = $cSurface2
            $btnRun.ForeColor = $cGray
            $btnRun.FlatAppearance.BorderColor = $cBorder
            $btnRun.FlatAppearance.BorderSize = 1
        }
    }
}

# ── LOGGING ────────────────────────────────────────────────────────────────
function Write-Log ([string]$msg) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logTextBox.AppendText("[$timestamp] $msg`r`n")
    $logTextBox.SelectionStart = $logTextBox.Text.Length
    $logTextBox.ScrollToCaret()
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
        Write-Log "Success: $($script:Tasks[$prevKey]) complete."
        Set-OverallProgress $script:DoneCount $script:TotalTasks "RUNNING"
        $form.Refresh()
    }

    if ($script:RunIndex -ge $script:TotalTasks) {
        $runTimer.Stop()
        $animTimer.Stop()
        if ($script:JobWorker) { $script:JobWorker | Remove-Job -Force -ErrorAction SilentlyContinue }
        $script:IsRunning    = $false
        Write-Log "All tasks completed successfully."
        Set-OverallProgress $script:TotalTasks $script:TotalTasks "COMPLETE"
        $lblPct.ForeColor    = $cWhite
        $lblFooterHint.Text  = "Optimization complete. Restart your PC to apply all system-level changes."
$lblFooterHint.Location = New-Object System.Drawing.Point(24, 56) # Ensure footer hint is correctly positioned
$btnRestart.Location = New-Object System.Drawing.Point($formWidth - 250, 26) # Ensure restart button is correctly positioned
$btnRun.Location = New-Object System.Drawing.Point($formWidth - 128, 26) # Ensure run button is correctly positioned
        $btnRestart.Visible  = $true
        Set-RunButtonStyle "complete"
        return
    }

    $key    = $script:TaskKeyList[$script:RunIndex]
    Write-Log "Action: Optimizing $($script:Tasks[$key])..."
    Set-TaskState $key "running"

    $script:AnimKey    = $key
    $script:AnimTarget = $script:TaskRows[$key].Track.Width
    $script:TaskRows[$key].Bar.Width = 0
    $animTimer.Start()

    $r = $script:TaskRows[$key].Row
    $scrollPanel.AutoScrollPosition = New-Object System.Drawing.Point(0, [Math]::Max(0, $r.Top - 60))
    $form.Refresh()
    $script:RunIndex++

    $fnName = $script:FnMap[$key]
    $script:JobWorker = Start-Job -ScriptBlock {
        param($fn)
        function Invoke-Kernel { bcdedit /set useplatformclock no 2>$null|Out-Null; bcdedit /set useplatformtick yes 2>$null|Out-Null; bcdedit /set disabledynamictick yes 2>$null|Out-Null; bcdedit /set tscsyncpolicy Enhanced 2>$null|Out-Null; bcdedit /set nx OptOut 2>$null|Out-Null; bcdedit /set synthetictimers yes 2>$null|Out-Null; $h=Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.FriendlyName -like "*High Precision*"}; if($h){Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue} }
        function Invoke-TimerResolution { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null }
        function Invoke-IRQ { Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue|ForEach-Object{ $p="$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"; if(Test-Path $p){Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null} } }
        function Invoke-Nagle { $iP="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; Get-ChildItem $iP -ErrorAction SilentlyContinue|ForEach-Object{ Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force 2>$null } }
        function Invoke-VisualEffects { $vp="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; if(-not(Test-Path $vp)){New-Item -Path $vp -Force|Out-Null}; Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-GameBar { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null; $gp="HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null}; Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-ProcessorPower { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null|Out-Null; powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null|Out-Null; powercfg /setactive SCHEME_CURRENT 2>$null|Out-Null }
        function Invoke-Priority { $pp="HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"; $sp="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; $gp="$sp\Tasks\Games"; $ep="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"; Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null; Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null; Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null; if(-not(Test-Path $gp)){New-Item -Path $gp -Force|Out-Null}; Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null; Set-ItemProperty -Path $gp -Name "SFIO Priority" -Value "High" -Type String -Force 2>$null }
        function Invoke-Memory { $mp="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null; powercfg -h off 2>$null|Out-Null; taskkill /f /im OneDrive.exe 2>$null|Out-Null; Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue }
        function Invoke-Input { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null; $pt="HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"; if(-not(Test-Path $pt)){New-Item -Path $pt -Force|Out-Null}; Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable" -Value 0 -Type DWord -Force 2>$null }
        function Invoke-Network { netsh int tcp set global rss=enabled 2>$null|Out-Null; netsh int tcp set global autotuninglevel=normal 2>$null|Out-Null; netsh int tcp set global timestamps=disabled 2>$null|Out-Null; netsh int tcp set global chimney=disabled 2>$null|Out-Null; $tp="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Set-ItemProperty -Path $tp -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "DefaultTTL" -Value 64 -Type DWord -Force 2>$null; Clear-DnsClientCache -ErrorAction SilentlyContinue|Out-Null; netsh winsock reset 2>$null|Out-Null; netsh int ip reset 2>$null|Out-Null; ipconfig /release 2>$null|Out-Null; ipconfig /renew 2>$null|Out-Null; Get-NetAdapter|Where-Object{$_.Physical}|Restart-NetAdapter -ErrorAction SilentlyContinue }
        function Invoke-Services { @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')|ForEach-Object{ Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue; Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue }; @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')|ForEach-Object{ Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service -Name $_ -ErrorAction SilentlyContinue } }
        function Invoke-Cleanup { @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")|ForEach-Object{ Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue|Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }; Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue; Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service -Name wuauserv -ErrorAction SilentlyContinue; wevtutil.exe el|ForEach-Object{ wevtutil.exe cl "$_" 2>$null } }
        try { & $fn } catch {}
    } -ArgumentList $fnName
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $logTextBox.Text = ""
    Write-Log "Initializing GOAT v3.0..."
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:DoneCount   = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    $btnRestart.Visible  = $false
    $lblFooterHint.Text  = "GOAT is running. Please wait until every module is complete."
    Set-OverallProgress 0 $script:TotalTasks "RUNNING"
    Set-RunButtonStyle "running"
    $runTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
