#Requires -Version 5.1

<#
GOAT - GREATEST OF ALL TWEAKS
GUI Edition v3.0 - Minimalist Dark UI
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

# ── COLORS ─────────────────────────────────────────────────────────────────
$cBg0       = [System.Drawing.Color]::FromArgb(10, 10, 10)       # deepest bg
$cBg1       = [System.Drawing.Color]::FromArgb(15, 15, 15)       # panel bg
$cBg2       = [System.Drawing.Color]::FromArgb(20, 20, 20)       # row hover / running
$cBorder    = [System.Drawing.Color]::FromArgb(28, 28, 28)       # subtle border
$cRed       = [System.Drawing.Color]::FromArgb(204, 34, 34)      # primary accent
$cRedBright = [System.Drawing.Color]::FromArgb(255, 80, 80)      # running highlight
$cRedDim    = [System.Drawing.Color]::FromArgb(120, 30, 30)      # muted red
$cGreen     = [System.Drawing.Color]::FromArgb(80, 180, 80)      # done indicator
$cWhite     = [System.Drawing.Color]::FromArgb(230, 230, 230)    # primary text
$cGray1     = [System.Drawing.Color]::FromArgb(130, 130, 130)    # secondary text
$cGray2     = [System.Drawing.Color]::FromArgb(60, 60, 60)       # muted text
$cGray3     = [System.Drawing.Color]::FromArgb(35, 35, 35)       # track/line

# ── FONTS ──────────────────────────────────────────────────────────────────
# Inter ถ้าไม่มีจะ fallback เป็น Segoe UI อัตโนมัติ
$fMain     = New-Object System.Drawing.Font("Segoe UI", 9)
$fMainSm   = New-Object System.Drawing.Font("Segoe UI", 8)
$fBold     = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$fLight    = New-Object System.Drawing.Font("Segoe UI Light", 9)
$fMono     = New-Object System.Drawing.Font("Consolas", 8)
$fLogoLg   = New-Object System.Drawing.Font("Segoe UI Light", 36, [System.Drawing.FontStyle]::Regular)
$fLogoSub  = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)
$fRunBtn   = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)

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

# ── OPTIMIZATION FUNCTIONS (ไม่เปลี่ยน) ───────────────────────────────────
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

# ── HELPER: วาด separator line ─────────────────────────────────────────────
function New-SepLine {
    param($parent, $y)
    $sep = New-Object System.Windows.Forms.Panel
    $sep.Size      = New-Object System.Drawing.Size($parent.Width, 1)
    $sep.Location  = New-Object System.Drawing.Point(0, $y)
    $sep.BackColor = $cBorder
    $sep.Anchor    = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top
    $parent.Controls.Add($sep)
    return $sep
}

# ══════════════════════════════════════════════════════════════════════════
# FORM
# ══════════════════════════════════════════════════════════════════════════
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT — Greatest of All Tweaks"
$form.Size            = New-Object System.Drawing.Size(860, 700)
$form.MinimumSize     = New-Object System.Drawing.Size(860, 600)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg0
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── TITLE BAR STRIP ────────────────────────────────────────────────────────
$titleStrip = New-Object System.Windows.Forms.Panel
$titleStrip.Dock      = [System.Windows.Forms.DockStyle]::Top
$titleStrip.Height    = 2
$titleStrip.BackColor = $cRed
$form.Controls.Add($titleStrip)

# ── TOP BAR ────────────────────────────────────────────────────────────────
$topBar = New-Object System.Windows.Forms.Panel
$topBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$topBar.Height    = 28
$topBar.BackColor = $cBg1
$form.Controls.Add($topBar)

$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text      = "GOAT  ·  Greatest of All Tweaks  ·  v3.0"
$lblVersion.Font      = $fMono
$lblVersion.ForeColor = $cGray2
$lblVersion.Dock      = [System.Windows.Forms.DockStyle]::Fill
$lblVersion.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblVersion.BackColor = [System.Drawing.Color]::Transparent
$topBar.Controls.Add($lblVersion)

# ── HERO / LOGO PANEL ──────────────────────────────────────────────────────
$heroPanel = New-Object System.Windows.Forms.Panel
$heroPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$heroPanel.Height    = 120
$heroPanel.BackColor = $cBg1
$form.Controls.Add($heroPanel)

$heroPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # thin red line bottom
    $pen = New-Object System.Drawing.Pen($cBorder, 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()

    # ── wordmark: G · O · A · T ──
    $logoFont = New-Object System.Drawing.Font("Segoe UI Light", 38, [System.Drawing.FontStyle]::Regular)
    $dotFont  = New-Object System.Drawing.Font("Segoe UI Light", 28, [System.Drawing.FontStyle]::Regular)

    $letters  = @("G", "O", "A", "T")
    $dots     = @(" · ", " · ", " · ")

    # measure total width first
    $totalW = 0
    foreach ($l in $letters) { $totalW += $g.MeasureString($l, $logoFont).Width - 4 }
    foreach ($d in $dots)    { $totalW += $g.MeasureString($d, $dotFont).Width - 2 }

    $startX = ($s.Width - $totalW) / 2
    $baseY  = ($s.Height - $g.MeasureString("G", $logoFont).Height) / 2 - 10
    $cx = $startX

    $brushWhite = New-Object System.Drawing.SolidBrush($cWhite)
    $brushRed   = New-Object System.Drawing.SolidBrush($cRed)

    for ($i = 0; $i -lt 4; $i++) {
        $g.DrawString($letters[$i], $logoFont, $brushWhite, $cx, $baseY)
        $cx += $g.MeasureString($letters[$i], $logoFont).Width - 4
        if ($i -lt 3) {
            $g.DrawString($dots[$i], $dotFont, $brushRed, $cx, $baseY + 6)
            $cx += $g.MeasureString($dots[$i], $dotFont).Width - 2
        }
    }
    $brushWhite.Dispose(); $brushRed.Dispose(); $logoFont.Dispose(); $dotFont.Dispose()

    # ── subtitle ──
    $subFont  = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)
    $subText  = "GREATEST OF ALL TWEAKS"
    $subBrush = New-Object System.Drawing.SolidBrush($cGray2)
    $subSz    = $g.MeasureString($subText, $subFont)
    $g.DrawString($subText, $subFont, $subBrush, ($s.Width - $subSz.Width)/2, $baseY + 58)
    $subBrush.Dispose(); $subFont.Dispose()
})

# ── SYS INFO BAR ──────────────────────────────────────────────────────────
$sysBar = New-Object System.Windows.Forms.Panel
$sysBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$sysBar.Height    = 32
$sysBar.BackColor = $cBg0
$form.Controls.Add($sysBar)

$cpuShort = if ($CPU.Length -gt 42) { $CPU.Substring(0,42)+"…" } else { $CPU }
$osShort  = if ($OSName.Length -gt 28) { $OSName.Substring(0,28)+"…" } else { $OSName }

$lblSys = New-Object System.Windows.Forms.Label
$lblSys.Text      = "CPU  $cpuShort    ·    RAM  $RAMUsed / $RAMTotal GB  ($RAMPct%)    ·    OS  $osShort"
$lblSys.Font      = $fMono
$lblSys.ForeColor = $cGray2
$lblSys.Dock      = [System.Windows.Forms.DockStyle]::Fill
$lblSys.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblSys.BackColor = [System.Drawing.Color]::Transparent
$sysBar.Controls.Add($lblSys)

# thin border under sysbar
$sepSys = New-Object System.Windows.Forms.Panel
$sepSys.Dock      = [System.Windows.Forms.DockStyle]::Top
$sepSys.Height    = 1
$sepSys.BackColor = $cBorder
$form.Controls.Add($sepSys)

# ── FOOTER ────────────────────────────────────────────────────────────────
$footer = New-Object System.Windows.Forms.Panel
$footer.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$footer.Height    = 52
$footer.BackColor = $cBg1
$form.Controls.Add($footer)

$sepFoot = New-Object System.Windows.Forms.Panel
$sepFoot.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$sepFoot.Height    = 1
$sepFoot.BackColor = $cBorder
$form.Controls.Add($sepFoot)

# overall progress track
$overallTrack = New-Object System.Windows.Forms.Panel
$overallTrack.Location  = New-Object System.Drawing.Point(20, 24)
$overallTrack.Size      = New-Object System.Drawing.Size(520, 1)
$overallTrack.BackColor = $cGray3
$footer.Controls.Add($overallTrack)

$overallFill = New-Object System.Windows.Forms.Panel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 1)
$overallFill.BackColor = $cRed
$overallTrack.Controls.Add($overallFill)

# pct label
$lblPct = New-Object System.Windows.Forms.Label
$lblPct.Text      = "0%"
$lblPct.Font      = $fMono
$lblPct.ForeColor = $cGray2
$lblPct.AutoSize  = $true
$lblPct.Location  = New-Object System.Drawing.Point(550, 17)
$footer.Controls.Add($lblPct)

# restart button (hidden until done)
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "Restart PC"
$btnRestart.Font      = $fMain
$btnRestart.ForeColor = $cGray1
$btnRestart.BackColor = $cBg0
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cBorder
$btnRestart.FlatAppearance.BorderSize  = 1
$btnRestart.Size      = New-Object System.Drawing.Size(96, 28)
$btnRestart.Location  = New-Object System.Drawing.Point(644, 11)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({ Restart-Computer -Force })
$footer.Controls.Add($btnRestart)

# run button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "Run GOAT"
$btnRun.Font      = $fRunBtn
$btnRun.ForeColor = $cWhite
$btnRun.BackColor = $cRed
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize  = 0
$btnRun.FlatAppearance.MouseOverBackColor  = [System.Drawing.Color]::FromArgb(230, 40, 40)
$btnRun.FlatAppearance.MouseDownBackColor  = [System.Drawing.Color]::FromArgb(170, 20, 20)
$btnRun.Size      = New-Object System.Drawing.Size(110, 32)
$btnRun.Location  = New-Object System.Drawing.Point(750, 9)
$footer.Controls.Add($btnRun)

# ── SECTION LABEL ─────────────────────────────────────────────────────────
$secLabel = New-Object System.Windows.Forms.Panel
$secLabel.Dock      = [System.Windows.Forms.DockStyle]::Top
$secLabel.Height    = 28
$secLabel.BackColor = $cBg0
$form.Controls.Add($secLabel)

$lblSec = New-Object System.Windows.Forms.Label
$lblSec.Text      = "  OPTIMIZATION MODULES  ·  $($script:Tasks.Count) tweaks"
$lblSec.Font      = $fMono
$lblSec.ForeColor = $cGray2
$lblSec.Dock      = [System.Windows.Forms.DockStyle]::Fill
$lblSec.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblSec.BackColor = [System.Drawing.Color]::Transparent
$secLabel.Controls.Add($lblSec)

$sepSec = New-Object System.Windows.Forms.Panel
$sepSec.Dock      = [System.Windows.Forms.DockStyle]::Top
$sepSec.Height    = 1
$sepSec.BackColor = $cBorder
$form.Controls.Add($sepSec)

# ── TASK LIST PANEL ────────────────────────────────────────────────────────
$taskPanel = New-Object System.Windows.Forms.Panel
$taskPanel.Dock       = [System.Windows.Forms.DockStyle]::Fill
$taskPanel.BackColor  = $cBg0
$taskPanel.AutoScroll = $true
$form.Controls.Add($taskPanel)

# ── BUILD TASK ROWS ────────────────────────────────────────────────────────
$script:TaskRows = @{}
$taskKeys = @($script:Tasks.Keys)
[int]$rowH = 38
[int]$innerH = $taskKeys.Count * $rowH + 2

$innerPanel = New-Object System.Windows.Forms.Panel
$innerPanel.Size      = New-Object System.Drawing.Size(840, $innerH)
$innerPanel.Location  = New-Object System.Drawing.Point(0, 0)
$innerPanel.BackColor = [System.Drawing.Color]::Transparent
$taskPanel.Controls.Add($innerPanel)

for ($i = 0; $i -lt $taskKeys.Count; $i++) {
    $key   = $taskKeys[$i]
    $label = $script:Tasks[$key]
    [int]$yPos = $i * $rowH

    $row = New-Object System.Windows.Forms.Panel
    $row.Size      = New-Object System.Drawing.Size(840, $rowH)
    $row.Location  = New-Object System.Drawing.Point(0, $yPos)
    $row.BackColor = $cBg0
    $innerPanel.Controls.Add($row)

    # index number
    $idxStr = "{0:D2}" -f ($i + 1)
    $lblIdx = New-Object System.Windows.Forms.Label
    $lblIdx.Text      = $idxStr
    $lblIdx.Font      = $fMono
    $lblIdx.ForeColor = $cGray3
    $lblIdx.Size      = New-Object System.Drawing.Size(40, $rowH)
    $lblIdx.Location  = New-Object System.Drawing.Point(20, 0)
    $lblIdx.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $lblIdx.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblIdx)

    # task name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $label
    $lblName.Font      = $fMain
    $lblName.ForeColor = $cGray2
    $lblName.Size      = New-Object System.Drawing.Size(200, $rowH)
    $lblName.Location  = New-Object System.Drawing.Point(64, 0)
    $lblName.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $lblName.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblName)

    # progress track (thin 1px line)
    $barTrack = New-Object System.Windows.Forms.Panel
    $barTrack.BackColor = $cGray3
    $barTrack.Size      = New-Object System.Drawing.Size(430, 1)
    $barTrack.Location  = New-Object System.Drawing.Point(276, $rowH / 2)
    $row.Controls.Add($barTrack)

    $barFill = New-Object System.Windows.Forms.Panel
    $barFill.BackColor = $cGray3
    $barFill.Size      = New-Object System.Drawing.Size(0, 1)
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barTrack.Controls.Add($barFill)

    # dot indicator (4x4 at end of track)
    $dot = New-Object System.Windows.Forms.Panel
    $dot.BackColor = $cGray3
    $dot.Size      = New-Object System.Drawing.Size(4, 4)
    $dot.Location  = New-Object System.Drawing.Point(716, ($rowH / 2) - 1)
    $row.Controls.Add($dot)

    # status text
    $lblSt = New-Object System.Windows.Forms.Label
    $lblSt.Text      = "—"
    $lblSt.Font      = $fMono
    $lblSt.ForeColor = $cGray3
    $lblSt.Size      = New-Object System.Drawing.Size(80, $rowH)
    $lblSt.Location  = New-Object System.Drawing.Point(730, 0)
    $lblSt.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $lblSt.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($lblSt)

    # separator line
    $sepRow = New-Object System.Windows.Forms.Panel
    $sepRow.BackColor = $cBorder
    $sepRow.Size      = New-Object System.Drawing.Size(840, 1)
    $sepRow.Location  = New-Object System.Drawing.Point(0, ([int]$rowH - 1))
    $row.Controls.Add($sepRow)

    $script:TaskRows[$key] = @{
        Row      = $row
        Idx      = $lblIdx
        Name     = $lblName
        Bar      = $barFill
        BarTrack = $barTrack
        Dot      = $dot
        Status   = $lblSt
    }
}

# ── SMOOTH BAR ANIMATION TIMER ─────────────────────────────────────────────
# ใช้แทน blink — bar fill เดิน smooth จาก 0 → 100%
$script:AnimKey      = $null
$script:AnimTarget   = 0
$script:AnimCurrent  = 0

$animTimer = New-Object System.Windows.Forms.Timer
$animTimer.Interval = 16   # ~60 fps
$animTimer.Add_Tick({
    if (-not $script:AnimKey) { return }
    if (-not $script:TaskRows.ContainsKey($script:AnimKey)) { return }
    $bar = $script:TaskRows[$script:AnimKey].Bar
    $track = $script:TaskRows[$script:AnimKey].BarTrack
    $target = $track.Width
    # ease toward target
    $script:AnimCurrent += ($target - $script:AnimCurrent) * 0.08
    $newW = [math]::Min([math]::Round($script:AnimCurrent), $target)
    if ($bar.Width -ne $newW) { $bar.Width = $newW }
})

# ── SET TASK STATE ─────────────────────────────────────────────────────────
function Set-TaskState ($key, $state) {
    if (-not $script:TaskRows.ContainsKey($key)) { return }
    $r = $script:TaskRows[$key]
    switch ($state) {
        "running" {
            $r.Row.BackColor    = $cBg2
            $r.Idx.ForeColor    = $cRed
            $r.Name.ForeColor   = $cWhite
            $r.Bar.BackColor    = $cRed
            $r.Dot.BackColor    = $cRedBright
            $r.Status.Text      = "Running"
            $r.Status.ForeColor = $cRed
            $script:AnimKey     = $key
            $script:AnimCurrent = 0
            $r.Bar.Width        = 0
            $animTimer.Start()
        }
        "done" {
            $r.Row.BackColor    = $cBg0
            $r.Idx.ForeColor    = $cGray2
            $r.Name.ForeColor   = $cGray1
            $r.Bar.BackColor    = $cRed
            $r.Bar.Width        = $r.BarTrack.Width
            $r.Dot.BackColor    = $cRed
            $r.Status.Text      = "Done"
            $r.Status.ForeColor = $cRed
            if ($script:AnimKey -eq $key) { $script:AnimKey = $null }
        }
    }
}

# ── RUN TIMER ──────────────────────────────────────────────────────────────
$script:RunIndex    = 0
$script:TaskKeyList = @()
$script:TotalTasks  = 0
$script:IsRunning   = $false
$script:JobWorker   = $null

$runTimer = New-Object System.Windows.Forms.Timer
$runTimer.Interval = 80
$runTimer.Add_Tick({
    if ($script:JobWorker -and $script:JobWorker.State -eq 'Running') { return }

    if ($script:RunIndex -gt 0) {
        $prevKey = $script:TaskKeyList[$script:RunIndex - 1]
        Set-TaskState $prevKey "done"
        $pct = [math]::Round($script:RunIndex / $script:TotalTasks * 100)
        $overallFill.Width = [math]::Round($overallTrack.Width * $pct / 100)
        $lblPct.Text = "$pct%"
        $form.Refresh()
    }

    if ($script:RunIndex -ge $script:TotalTasks) {
        $runTimer.Stop()
        $animTimer.Stop()
        if ($script:JobWorker) { $script:JobWorker | Remove-Job -Force -ErrorAction SilentlyContinue }
        $overallFill.Width = $overallTrack.Width
        $lblPct.Text       = "100%"
        $lblPct.ForeColor  = $cGreen
        $btnRestart.Visible = $true
        $btnRun.Text        = "Completed"
        $btnRun.BackColor   = [System.Drawing.Color]::FromArgb(30, 80, 30)
        $btnRun.ForeColor   = $cGreen
        return
    }

    $key = $script:TaskKeyList[$script:RunIndex]
    Set-TaskState $key "running"
    $r = $script:TaskRows[$key].Row
    $taskPanel.AutoScrollPosition = New-Object System.Drawing.Point(0, [Math]::Max(0, $r.Top - 60))
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

# ── RUN BUTTON CLICK ───────────────────────────────────────────────────────
$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning    = $true
    $script:RunIndex     = 0
    $script:TaskKeyList  = @($script:Tasks.Keys)
    $script:TotalTasks   = $script:TaskKeyList.Count
    $btnRun.Enabled      = $false
    $btnRun.Text         = "Running…"
    $btnRun.BackColor    = [System.Drawing.Color]::FromArgb(160, 20, 20)
    $runTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
