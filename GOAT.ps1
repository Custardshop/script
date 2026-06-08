#Requires -Version 5.1
<#
    GOAT - GREATEST OF ALL TWEAKS
    GUI Edition v2.2 - Fixed task order + background support
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

# ── COLORS & FONTS ─────────────────────────────────────────────────────────
$cBlack     = [System.Drawing.Color]::FromArgb(0,0,0)
$cDarkBg    = [System.Drawing.Color]::FromArgb(10,0,0)
$cRed       = [System.Drawing.Color]::FromArgb(220,30,30)
$cRedBright = [System.Drawing.Color]::FromArgb(255,60,60)
$cRedDim    = [System.Drawing.Color]::FromArgb(200,40,40)
$cRedDark   = [System.Drawing.Color]::FromArgb(80,10,10)
$cGreen     = [System.Drawing.Color]::FromArgb(40,200,40)
$cGray      = [System.Drawing.Color]::FromArgb(160,140,140)
$cWhite     = [System.Drawing.Color]::FromArgb(240,220,220)
$cTransBg   = [System.Drawing.Color]::FromArgb(160,0,0,0)   # พื้นหลังโปร่งใส row

$fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$fMono10   = New-Object System.Drawing.Font("Consolas", 10)
$fMonoBold = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)

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

# ── OPTIMIZATION FUNCTIONS ─────────────────────────────────────────────────
function Invoke-Kernel {
    bcdedit /set useplatformclock no    2>$null | Out-Null
    bcdedit /set useplatformtick yes    2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut              2>$null | Out-Null
    bcdedit /set synthetictimers yes    2>$null | Out-Null
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
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled"              -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"                       -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode"                -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode"       -Value 1 -Type DWord -Force 2>$null
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
    Set-ItemProperty -Path $sp -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
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

# ── FORM ───────────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT // GREATEST OF ALL TWEAKS"
$form.Size            = New-Object System.Drawing.Size(920, 720)
$form.MinimumSize     = New-Object System.Drawing.Size(920, 720)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBlack
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── BACKGROUND PAINT (ถ้ามีรูป) ───────────────────────────────────────────
if ($script:BgImage) {
    $form.Add_Paint({
        param($s,$e)
        $e.Graphics.DrawImage($script:BgImage, 0, 0, $s.Width, $s.Height)
    })
}

# ══════════════════════════════════════════════════════════════════════════
# NOTE: WinForms Dock=Top adds controls in REVERSE order visually
# (last Added control appears at top). We add controls bottom→top
# so that Top panel → sepTop → heroPanel → sepHero → sysBar → fill area
# ══════════════════════════════════════════════════════════════════════════

# ── FOOTER (add first → sits at bottom via Dock=Bottom) ───────────────────
$footer = New-Object System.Windows.Forms.Panel
$footer.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$footer.Height    = 54
$footer.BackColor = [System.Drawing.Color]::FromArgb(200,10,0,0)
$footer.Padding   = New-Object System.Windows.Forms.Padding(14,8,14,8)
$form.Controls.Add($footer)

$sepFoot = New-Object System.Windows.Forms.Panel
$sepFoot.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$sepFoot.Height    = 1
$sepFoot.BackColor = $cRedDark
$form.Controls.Add($sepFoot)

$overallBar = New-Object System.Windows.Forms.Panel
$overallBar.Location  = New-Object System.Drawing.Point(14, 10)
$overallBar.Size      = New-Object System.Drawing.Size(540, 6)
$overallBar.BackColor = $cRedDark
$footer.Controls.Add($overallBar)

$overallFill = New-Object System.Windows.Forms.Panel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 6)
$overallFill.BackColor = $cRed
$overallBar.Controls.Add($overallFill)

$lblPct = New-Object System.Windows.Forms.Label
$lblPct.Text      = "0%"
$lblPct.Font      = New-Object System.Drawing.Font("Consolas", 13, [System.Drawing.FontStyle]::Bold)
$lblPct.ForeColor = $cRed
$lblPct.AutoSize  = $true
$lblPct.Location  = New-Object System.Drawing.Point(560, 2)
$footer.Controls.Add($lblPct)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART PC"
$btnRestart.Font      = $fMonoBold
$btnRestart.ForeColor = $cRedDim
$btnRestart.BackColor = [System.Drawing.Color]::FromArgb(20,0,0)
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cRedDark
$btnRestart.Size      = New-Object System.Drawing.Size(110, 32)
$btnRestart.Location  = New-Object System.Drawing.Point(620, 0)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({ Restart-Computer -Force })
$footer.Controls.Add($btnRestart)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "RUN GOAT"
$btnRun.Font      = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$btnRun.ForeColor = $cWhite
$btnRun.BackColor = $cRed
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Size      = New-Object System.Drawing.Size(130, 36)
$btnRun.Location  = New-Object System.Drawing.Point(760, 0)
$footer.Controls.Add($btnRun)

# ── TASK LIST PANEL (Fill → goes between top sections and footer) ──────────
# ใช้ Panel เดียว วาด task ทั้งหมดด้วย absolute Location แทน Dock::Top
# เพื่อให้ลำดับถูกต้องเสมอ
$taskPanel = New-Object System.Windows.Forms.Panel
$taskPanel.Dock       = [System.Windows.Forms.DockStyle]::Fill
$taskPanel.BackColor  = [System.Drawing.Color]::Transparent
$taskPanel.AutoScroll = $true
$form.Controls.Add($taskPanel)

# ── SYS INFO BAR ──────────────────────────────────────────────────────────
$sepSys = New-Object System.Windows.Forms.Panel
$sepSys.Dock      = [System.Windows.Forms.DockStyle]::Top
$sepSys.Height    = 1
$sepSys.BackColor = $cRedDark
$form.Controls.Add($sepSys)

$sysBar = New-Object System.Windows.Forms.Panel
$sysBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$sysBar.Height    = 40
$sysBar.BackColor = [System.Drawing.Color]::FromArgb(210,10,0,0)
$form.Controls.Add($sysBar)

$cpuShort = if ($CPU.Length -gt 38) { $CPU.Substring(0,38)+"..." } else { $CPU }
$osShort  = if ($OSName.Length -gt 30) { $OSName.Substring(0,30)+"..." } else { $OSName }

$lblSys = New-Object System.Windows.Forms.Label
$lblSys.Text      = "CPU: $cpuShort   |   RAM: $RAMUsed / $RAMTotal GB  ($RAMPct%)   |   OS: $osShort"
$lblSys.Font      = $fMono9
$lblSys.ForeColor = $cRedDim
$lblSys.Dock      = [System.Windows.Forms.DockStyle]::Fill
$lblSys.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblSys.BackColor = [System.Drawing.Color]::Transparent
$sysBar.Controls.Add($lblSys)

# ── HERO PANEL ─────────────────────────────────────────────────────────────
$sepHero = New-Object System.Windows.Forms.Panel
$sepHero.Dock      = [System.Windows.Forms.DockStyle]::Top
$sepHero.Height    = 1
$sepHero.BackColor = $cRedDark
$form.Controls.Add($sepHero)

$heroPanel = New-Object System.Windows.Forms.Panel
$heroPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$heroPanel.Height    = 150
$heroPanel.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($heroPanel)

$heroPanel.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # dark overlay so logo is readable even over bg image
    $overlay = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160,0,0,0))
    $g.FillRectangle($overlay, 0, 0, $s.Width, $s.Height)
    $overlay.Dispose()

    # scanlines
    for ($y = 0; $y -lt $s.Height; $y += 4) {
        $g.DrawLine([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(12,120,0,0)), 0, $y, $s.Width, $y)
    }

    $logoFont = New-Object System.Drawing.Font("Consolas", 68, [System.Drawing.FontStyle]::Bold)
    $logoText = "G O A T"
    $sz = $g.MeasureString($logoText, $logoFont)
    $lx = ($s.Width - $sz.Width) / 2
    $ly = ($s.Height - $sz.Height) / 2 - 10

    foreach ($off in @(6,4,2)) {
        $gb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25,255,40,40))
        $g.DrawString($logoText, $logoFont, $gb, ($lx-$off), ($ly-$off/2))
        $g.DrawString($logoText, $logoFont, $gb, ($lx+$off), ($ly+$off/2))
        $gb.Dispose()
    }
    $mb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220,30,30))
    $g.DrawString($logoText, $logoFont, $mb, $lx, $ly)
    $mb.Dispose(); $logoFont.Dispose()

    $sf = New-Object System.Drawing.Font("Consolas", 9)
    $st = "·  G R E A T E S T   O F   A L L   T W E A K S  ·"
    $sz2 = $g.MeasureString($st, $sf)
    $sb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180,210,60,60))
    $g.DrawString($st, $sf, $sb, ($s.Width-$sz2.Width)/2, $ly+$sz.Height-10)
    $sb.Dispose(); $sf.Dispose()
})

# ── TOP BAR ────────────────────────────────────────────────────────────────
$sepTop = New-Object System.Windows.Forms.Panel
$sepTop.Dock      = [System.Windows.Forms.DockStyle]::Top
$sepTop.Height    = 2
$sepTop.BackColor = $cRed
$form.Controls.Add($sepTop)

$topBar = New-Object System.Windows.Forms.Panel
$topBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$topBar.Height    = 30
$topBar.BackColor = [System.Drawing.Color]::FromArgb(220,10,0,0)
$form.Controls.Add($topBar)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "GOAT  //  GREATEST OF ALL TWEAKS  //  v2.2"
$lblTitle.Font      = $fMono9
$lblTitle.ForeColor = $cRedDim
$lblTitle.AutoSize  = $false
$lblTitle.Dock      = [System.Windows.Forms.DockStyle]::Fill
$lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblTitle.BackColor = [System.Drawing.Color]::Transparent
$topBar.Controls.Add($lblTitle)

# ══════════════════════════════════════════════════════════════════════════
# ── BUILD TASK ROWS ด้วย absolute Y position (แก้ปัญหาลำดับสลับ) ─────────
# ══════════════════════════════════════════════════════════════════════════
$script:TaskRows = @{}
$taskKeys  = @($script:Tasks.Keys)
$rowHeight = 36
$headerH   = 28
$yPos      = $headerH   # เริ่มต้นหลัง header

# inner container ที่ scrollable — ต้องกำหนดขนาดตรงๆ
$innerH = $headerH + ($taskKeys.Count * $rowHeight) + 10
$innerPanel = New-Object System.Windows.Forms.Panel
$innerPanel.Size      = New-Object System.Drawing.Size(870, $innerH)
$innerPanel.Location  = New-Object System.Drawing.Point(0, 0)
$innerPanel.BackColor = [System.Drawing.Color]::Transparent
$taskPanel.Controls.Add($innerPanel)

# header label
$lblSectionTitle = New-Object System.Windows.Forms.Label
$lblSectionTitle.Text      = "  OPTIMIZATION MODULES  ($($taskKeys.Count) tweaks)"
$lblSectionTitle.Font      = $fMono9
$lblSectionTitle.ForeColor = $cRedDim
$lblSectionTitle.AutoSize  = $false
$lblSectionTitle.Size      = New-Object System.Drawing.Size(860, $headerH)
$lblSectionTitle.Location  = New-Object System.Drawing.Point(10, 0)
$lblSectionTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblSectionTitle.BackColor = [System.Drawing.Color]::FromArgb(180,15,0,0)
$innerPanel.Controls.Add($lblSectionTitle)

# วน loop ตามลำดับปกติ (index 0 → สุดท้าย) แล้วกำหนด Y โดยตรง
foreach ($key in $taskKeys) {
    $label = $script:Tasks[$key]

    $row = New-Object System.Windows.Forms.Panel
    $row.Size      = New-Object System.Drawing.Size(860, $rowHeight)
    $row.Location  = New-Object System.Drawing.Point(10, $yPos)
    $row.BackColor = [System.Drawing.Color]::FromArgb(150,8,0,0)
    $innerPanel.Controls.Add($row)

    # icon
    $icn = New-Object System.Windows.Forms.Label
    $icn.Text      = "--"
    $icn.Font      = $fMono10
    $icn.ForeColor = $cRedDim
    $icn.Size      = New-Object System.Drawing.Size(36, $rowHeight)
    $icn.Location  = New-Object System.Drawing.Point(4, 0)
    $icn.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $icn.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($icn)

    # name
    $nm = New-Object System.Windows.Forms.Label
    $nm.Text      = $label
    $nm.Font      = $fMono10
    $nm.ForeColor = $cRedDim
    $nm.Size      = New-Object System.Drawing.Size(270, $rowHeight)
    $nm.Location  = New-Object System.Drawing.Point(44, 0)
    $nm.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $nm.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($nm)

    # progress bar track
    $barTrack = New-Object System.Windows.Forms.Panel
    $barTrack.BackColor = [System.Drawing.Color]::FromArgb(60,80,0,0)
    $barTrack.Size      = New-Object System.Drawing.Size(370, 3)
    $barTrack.Location  = New-Object System.Drawing.Point(325, 16)
    $row.Controls.Add($barTrack)

    $barFill = New-Object System.Windows.Forms.Panel
    $barFill.BackColor = $cRed
    $barFill.Size      = New-Object System.Drawing.Size(0, 3)
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barTrack.Controls.Add($barFill)

    # status
    $st = New-Object System.Windows.Forms.Label
    $st.Text      = "PENDING"
    $st.Font      = $fMono9
    $st.ForeColor = $cRedDim
    $st.Size      = New-Object System.Drawing.Size(90, $rowHeight)
    $st.Location  = New-Object System.Drawing.Point(706, 0)
    $st.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $st.BackColor = [System.Drawing.Color]::Transparent
    $row.Controls.Add($st)

    # separator line
    $sep = New-Object System.Windows.Forms.Panel
    $sep.BackColor = [System.Drawing.Color]::FromArgb(40,80,0,0)
    $sep.Size      = New-Object System.Drawing.Size(860, 1)
    $sep.Location  = New-Object System.Drawing.Point(0, $rowHeight - 1)
    $row.Controls.Add($sep)

    $script:TaskRows[$key] = @{ Row=$row; Icon=$icn; Name=$nm; Bar=$barFill; BarTrack=$barTrack; Status=$st }
    $yPos += $rowHeight
}

# ── BLINK TIMER ────────────────────────────────────────────────────────────
$script:BlinkState = $true
$script:CurrentKey = $null
$blinkTimer = New-Object System.Windows.Forms.Timer
$blinkTimer.Interval = 500
$blinkTimer.Add_Tick({
    if ($script:CurrentKey -and $script:TaskRows.ContainsKey($script:CurrentKey)) {
        $st = $script:TaskRows[$script:CurrentKey].Status
        $st.ForeColor = if ($script:BlinkState) { $cRedBright } else { $cRedDark }
        $script:BlinkState = -not $script:BlinkState
    }
})

# ── UPDATE TASK STATE ──────────────────────────────────────────────────────
function Set-TaskState ($key, $state) {
    if (-not $script:TaskRows.ContainsKey($key)) { return }
    $r = $script:TaskRows[$key]
    switch ($state) {
        "running" {
            $r.Icon.ForeColor   = $cRedBright
            $r.Icon.Text        = ">>"
            $r.Name.ForeColor   = $cWhite
            $r.Status.Text      = "RUNNING..."
            $r.Status.ForeColor = $cRedBright
            $r.Bar.Width        = 100
            $r.Row.BackColor    = [System.Drawing.Color]::FromArgb(180,25,0,0)
            $script:CurrentKey  = $key
            $blinkTimer.Start()
        }
        "done" {
            $r.Icon.ForeColor   = $cGreen
            $r.Icon.Text        = "OK"
            $r.Name.ForeColor   = $cGray
            $r.Status.Text      = "DONE"
            $r.Status.ForeColor = $cGreen
            $r.Bar.Width        = $r.BarTrack.Width
            $r.Bar.BackColor    = $cGreen
            $r.Row.BackColor    = [System.Drawing.Color]::FromArgb(120,5,0,0)
            $script:CurrentKey  = $null
        }
    }
}

# ── RUN TIMER (Job-based, UI stays responsive) ────────────────────────────
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
        $overallFill.Width = [math]::Round($overallBar.Width * $pct / 100)
        $lblPct.Text = "$pct%"
        $form.Refresh()
    }

    if ($script:RunIndex -ge $script:TotalTasks) {
        $runTimer.Stop()
        if ($script:JobWorker) { $script:JobWorker | Remove-Job -Force -ErrorAction SilentlyContinue }
        $blinkTimer.Stop()
        $overallFill.Width  = $overallBar.Width
        $lblPct.Text        = "100%"
        $lblPct.ForeColor   = $cGreen
        $btnRestart.Visible = $true
        $btnRun.Text        = "COMPLETED"
        $btnRun.BackColor   = $cGreen
        $btnRun.ForeColor   = $cBlack
        return
    }

    $key = $script:TaskKeyList[$script:RunIndex]
    Set-TaskState $key "running"

    # scroll to show current task
    $r = $script:TaskRows[$key].Row
    $taskPanel.AutoScrollPosition = New-Object System.Drawing.Point(0, [Math]::Max(0, $r.Top - 50))
    $form.Refresh()
    $script:RunIndex++

    $fnName = $script:FnMap[$key]
    $script:JobWorker = Start-Job -ScriptBlock {
        param($fn)
        function Invoke-Kernel {
            bcdedit /set useplatformclock no    2>$null | Out-Null
            bcdedit /set useplatformtick yes    2>$null | Out-Null
            bcdedit /set disabledynamictick yes 2>$null | Out-Null
            bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
            bcdedit /set nx OptOut              2>$null | Out-Null
            bcdedit /set synthetictimers yes    2>$null | Out-Null
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
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"                       -Value 0 -Type DWord -Force 2>$null
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode"                -Value 2 -Type DWord -Force 2>$null
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode"       -Value 1 -Type DWord -Force 2>$null
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
            Set-ItemProperty -Path $sp -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
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
        try { & $fn } catch {}
    } -ArgumentList $fnName
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    $btnRun.Enabled     = $false
    $btnRun.Text        = "RUNNING..."
    $btnRun.BackColor   = [System.Drawing.Color]::FromArgb(140,20,20)
    $btnRun.ForeColor   = $cWhite
    $runTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
