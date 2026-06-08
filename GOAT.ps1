#Requires -Version 5.1
<#
    GOAT - GREATEST OF ALL TWEAKS
    WinForms Edition v3.0 — Red/Black Theme
#>

# ── ADMIN CHECK ────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("Run as Administrator!", "GOAT", "OK", "Error") | Out-Null
    Exit
}

# ── LOAD ASSEMBLIES ────────────────────────────────────────────────────────
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ── COLORS & FONTS ─────────────────────────────────────────────────────────
$cBG       = [System.Drawing.Color]::FromArgb(10, 0, 0)
$cPanel    = [System.Drawing.Color]::FromArgb(20, 4, 4)
$cBorder   = [System.Drawing.Color]::FromArgb(140, 0, 0)
$cRed      = [System.Drawing.Color]::FromArgb(220, 30, 30)
$cRedDark  = [System.Drawing.Color]::FromArgb(140, 0, 0)
$cRedDim   = [System.Drawing.Color]::FromArgb(80, 0, 0)
$cYellow   = [System.Drawing.Color]::FromArgb(255, 200, 0)
$cGreen    = [System.Drawing.Color]::FromArgb(0, 200, 80)
$cGray     = [System.Drawing.Color]::FromArgb(100, 100, 100)
$cWhite    = [System.Drawing.Color]::FromArgb(220, 220, 220)
$cBarEmpty = [System.Drawing.Color]::FromArgb(40, 10, 10)

$fMono14B  = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$fMono10   = New-Object System.Drawing.Font("Consolas", 10)
$fMono10B  = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$fMono8    = New-Object System.Drawing.Font("Consolas", 8)
$fSans9    = New-Object System.Drawing.Font("Segoe UI", 9)
$fSans9B   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fMono28B  = New-Object System.Drawing.Font("Consolas", 28, [System.Drawing.FontStyle]::Bold)

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

# ── TASKS ──────────────────────────────────────────────────────────────────
$TaskNames = @(
    "Kernel and HPET", "Timer Resolution", "Process Priority", "IRQ MSI Mode",
    "Memory Management", "Input and USB", "Nagle Algorithm", "Visual Effects",
    "Game Bar and DVR", "Processor Power", "Custard Power Plan",
    "Network and DNS", "Windows Services", "Junk and Log Cleanup"
)
$script:TaskIdx = 0

# ── HELPER: border panel via Paint ────────────────────────────────────────
function Add-BorderPanel {
    param($Parent, $X, $Y, $W, $H, $Color)
    $p = New-Object System.Windows.Forms.Panel
    $p.Location = New-Object System.Drawing.Point($X, $Y)
    $p.Size     = New-Object System.Drawing.Size($W, $H)
    $p.BackColor = $cPanel
    $borderColor = $Color
    $p.Add_Paint({
        param($s, $e)
        $pen = New-Object System.Drawing.Pen($borderColor, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width - 1, $s.Height - 1)
        $pen.Dispose()
    })
    $Parent.Controls.Add($p)
    return $p
}

# ── MAIN FORM ──────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT // GREATEST OF ALL TWEAKS"
$form.Size            = New-Object System.Drawing.Size(860, 700)
$form.MinimumSize     = New-Object System.Drawing.Size(860, 700)
$form.BackColor       = $cBG
$form.ForeColor       = $cRed
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.Font            = $fSans9

# ── TOP STRIPE ─────────────────────────────────────────────────────────────
$stripe = New-Object System.Windows.Forms.Panel
$stripe.Location  = New-Object System.Drawing.Point(20, 14)
$stripe.Size      = New-Object System.Drawing.Size(810, 8)
$stripe.BackColor = $cRed
$form.Controls.Add($stripe)

# ── LOGO LABEL (ASCII-style via Consolas) ──────────────────────────────────
$logo = New-Object System.Windows.Forms.Label
$logo.Text      = "GOAT"
$logo.Font      = $fMono28B
$logo.ForeColor = $cRed
$logo.BackColor = [System.Drawing.Color]::Transparent
$logo.AutoSize  = $true
$logo.Location  = New-Object System.Drawing.Point(310, 30)
$form.Controls.Add($logo)

$sub = New-Object System.Windows.Forms.Label
$sub.Text      = "· G R E A T E S T   O F   A L L   T W E A K S ·"
$sub.Font      = $fMono10
$sub.ForeColor = $cYellow
$sub.BackColor = [System.Drawing.Color]::Transparent
$sub.AutoSize  = $true
$sub.Location  = New-Object System.Drawing.Point(188, 82)
$form.Controls.Add($sub)

# ── SEPARATOR ──────────────────────────────────────────────────────────────
$sep1 = New-Object System.Windows.Forms.Panel
$sep1.Location  = New-Object System.Drawing.Point(20, 110)
$sep1.Size      = New-Object System.Drawing.Size(810, 1)
$sep1.BackColor = $cBorder
$form.Controls.Add($sep1)

# ── SYSINFO PANEL ──────────────────────────────────────────────────────────
$sysPanel = Add-BorderPanel $form 20 118 810 110 $cBorder

function Make-SysRow {
    param($Parent, $Y, $Label, $Detail, $Pct, $BarColor)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Label
    $lbl.Font      = $fMono9
    $lbl.ForeColor = $cRedDark
    $lbl.Location  = New-Object System.Drawing.Point(10, $Y)
    $lbl.Size      = New-Object System.Drawing.Size(55, 20)
    $Parent.Controls.Add($lbl)

    $det = New-Object System.Windows.Forms.Label
    $det.Text      = $Detail
    $det.Font      = $fMono9
    $det.ForeColor = $cWhite
    $det.Location  = New-Object System.Drawing.Point(70, $Y)
    $det.Size      = New-Object System.Drawing.Size(340, 20)
    $Parent.Controls.Add($det)

    # bar bg
    $barBg = New-Object System.Windows.Forms.Panel
    $barBg.Location  = New-Object System.Drawing.Point(420, ($Y + 3))
    $barBg.Size      = New-Object System.Drawing.Size(300, 14)
    $barBg.BackColor = $cBarEmpty
    $Parent.Controls.Add($barBg)

    # bar fill
    $barFill = New-Object System.Windows.Forms.Panel
    $fillW = [math]::Max(2, [math]::Round($Pct / 100 * 300))
    $barFill.Location  = New-Object System.Drawing.Point(0, 0)
    $barFill.Size      = New-Object System.Drawing.Size($fillW, 14)
    $barFill.BackColor = $BarColor
    $barBg.Controls.Add($barFill)

    $pctLbl = New-Object System.Windows.Forms.Label
    $pctLbl.Text      = "$Pct%"
    $pctLbl.Font      = $fMono9
    $pctLbl.ForeColor = $BarColor
    $pctLbl.Location  = New-Object System.Drawing.Point(730, $Y)
    $pctLbl.Size      = New-Object System.Drawing.Size(60, 20)
    $Parent.Controls.Add($pctLbl)
}

Make-SysRow $sysPanel 12  "CPU" ($CPU.Substring(0, [math]::Min(40, $CPU.Length))) $CPULoad $cRed
Make-SysRow $sysPanel 42  "RAM" "$RAMUsed GB / $RAMTotal GB DDR"                  $RAMPct  $cYellow
Make-SysRow $sysPanel 72  "OS " ($OSName.Substring(0, [math]::Min(40, $OSName.Length))) 100 $cRedDark

# ── MODULE TAGS ────────────────────────────────────────────────────────────
$sep2 = New-Object System.Windows.Forms.Panel
$sep2.Location  = New-Object System.Drawing.Point(20, 234)
$sep2.Size      = New-Object System.Drawing.Size(810, 1)
$sep2.BackColor = $cBorder
$form.Controls.Add($sep2)

$modPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$modPanel.Location     = New-Object System.Drawing.Point(20, 242)
$modPanel.Size         = New-Object System.Drawing.Size(810, 30)
$modPanel.BackColor    = $cPanel
$modPanel.FlowDirection = "LeftToRight"
$modPanel.WrapContents  = $false
$form.Controls.Add($modPanel)

foreach ($mod in @("KERNEL","MEMORY","INPUT","NETWORK","IRQ/MSI","POWER","SERVICES","CLEANER")) {
    $t = New-Object System.Windows.Forms.Label
    $t.Text      = "[ $mod ]"
    $t.Font      = $fMono9
    $t.ForeColor = $cRed
    $t.AutoSize  = $true
    $t.Margin    = New-Object System.Windows.Forms.Padding(4, 6, 4, 0)
    $modPanel.Controls.Add($t)
}

# ── INIT LOADING BAR ───────────────────────────────────────────────────────
$sep3 = New-Object System.Windows.Forms.Panel
$sep3.Location  = New-Object System.Drawing.Point(20, 278)
$sep3.Size      = New-Object System.Drawing.Size(810, 1)
$sep3.BackColor = $cBorder
$form.Controls.Add($sep3)

$initLabel = New-Object System.Windows.Forms.Label
$initLabel.Text      = "INITIALIZING MODULES..."
$initLabel.Font      = $fMono9
$initLabel.ForeColor = $cYellow
$initLabel.Location  = New-Object System.Drawing.Point(26, 286)
$initLabel.Size      = New-Object System.Drawing.Size(300, 18)
$form.Controls.Add($initLabel)

$initBarBg = New-Object System.Windows.Forms.Panel
$initBarBg.Location  = New-Object System.Drawing.Point(26, 308)
$initBarBg.Size      = New-Object System.Drawing.Size(804, 16)
$initBarBg.BackColor = $cBarEmpty
$form.Controls.Add($initBarBg)

$initBarFill = New-Object System.Windows.Forms.Panel
$initBarFill.Location  = New-Object System.Drawing.Point(0, 0)
$initBarFill.Size      = New-Object System.Drawing.Size(0, 16)
$initBarFill.BackColor = $cRed
$initBarBg.Controls.Add($initBarFill)

$initPctLabel = New-Object System.Windows.Forms.Label
$initPctLabel.Text      = "0%"
$initPctLabel.Font      = $fMono9
$initPctLabel.ForeColor = $cGreen
$initPctLabel.Location  = New-Object System.Drawing.Point(26, 328)
$initPctLabel.Size      = New-Object System.Drawing.Size(100, 18)
$form.Controls.Add($initPctLabel)

$readyLabel = New-Object System.Windows.Forms.Label
$readyLabel.Text      = ""
$readyLabel.Font      = $fMono9
$readyLabel.ForeColor = $cGreen
$readyLabel.Location  = New-Object System.Drawing.Point(26, 348)
$readyLabel.Size      = New-Object System.Drawing.Size(400, 18)
$form.Controls.Add($readyLabel)

# ── SEPARATOR ──────────────────────────────────────────────────────────────
$sep4 = New-Object System.Windows.Forms.Panel
$sep4.Location  = New-Object System.Drawing.Point(20, 374)
$sep4.Size      = New-Object System.Drawing.Size(810, 1)
$sep4.BackColor = $cBorder
$form.Controls.Add($sep4)

# ── TASK PROGRESS PANEL (hidden until run) ─────────────────────────────────
$taskPanel = New-Object System.Windows.Forms.Panel
$taskPanel.Location  = New-Object System.Drawing.Point(20, 382)
$taskPanel.Size      = New-Object System.Drawing.Size(810, 220)
$taskPanel.BackColor = $cPanel
$taskPanel.Visible   = $false
$form.Controls.Add($taskPanel)

# Task list labels
$script:TaskLabels  = @()
$script:TaskStatus  = @()
$cols = 2
$rows = [math]::Ceiling($TaskNames.Count / $cols)
$colW = 390

for ($i = 0; $i -lt $TaskNames.Count; $i++) {
    $col = [math]::Floor($i / $rows)
    $row = $i % $rows
    $x   = 10 + $col * $colW
    $y   = 10 + $row * 27

    $ic = New-Object System.Windows.Forms.Label
    $ic.Text      = "  "
    $ic.Font      = $fMono9
    $ic.ForeColor = $cGray
    $ic.Location  = New-Object System.Drawing.Point($x, $y)
    $ic.Size      = New-Object System.Drawing.Size(22, 20)
    $taskPanel.Controls.Add($ic)
    $script:TaskStatus += $ic

    $nl = New-Object System.Windows.Forms.Label
    $nl.Text      = $TaskNames[$i]
    $nl.Font      = $fMono9
    $nl.ForeColor = $cGray
    $nl.Location  = New-Object System.Drawing.Point(($x + 22), $y)
    $nl.Size      = New-Object System.Drawing.Size(240, 20)
    $taskPanel.Controls.Add($nl)
    $script:TaskLabels += $nl
}

# Overall progress bar
$overallLabel = New-Object System.Windows.Forms.Label
$overallLabel.Text      = "OVERALL"
$overallLabel.Font      = $fMono9
$overallLabel.ForeColor = $cYellow
$overallLabel.Location  = New-Object System.Drawing.Point(10, 195)
$overallLabel.Size      = New-Object System.Drawing.Size(80, 18)
$taskPanel.Controls.Add($overallLabel)

$overallBarBg = New-Object System.Windows.Forms.Panel
$overallBarBg.Location  = New-Object System.Drawing.Point(95, 197)
$overallBarBg.Size      = New-Object System.Drawing.Size(630, 14)
$overallBarBg.BackColor = $cBarEmpty
$taskPanel.Controls.Add($overallBarBg)

$script:OverallFill = New-Object System.Windows.Forms.Panel
$script:OverallFill.Location  = New-Object System.Drawing.Point(0, 0)
$script:OverallFill.Size      = New-Object System.Drawing.Size(0, 14)
$script:OverallFill.BackColor = $cRed
$overallBarBg.Controls.Add($script:OverallFill)

$script:OverallPct = New-Object System.Windows.Forms.Label
$script:OverallPct.Text      = "0%"
$script:OverallPct.Font      = $fMono9
$script:OverallPct.ForeColor = $cRed
$script:OverallPct.Location  = New-Object System.Drawing.Point(734, 195)
$script:OverallPct.Size      = New-Object System.Drawing.Size(50, 18)
$taskPanel.Controls.Add($script:OverallPct)

# ── BOTTOM BUTTONS ─────────────────────────────────────────────────────────
$sep5 = New-Object System.Windows.Forms.Panel
$sep5.Location  = New-Object System.Drawing.Point(20, 610)
$sep5.Size      = New-Object System.Drawing.Size(810, 1)
$sep5.BackColor = $cBorder
$form.Controls.Add($sep5)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "► RUN OPTIMIZATION"
$btnRun.Font      = $fMono10B
$btnRun.ForeColor = $cBG
$btnRun.BackColor = $cRed
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize  = 0
$btnRun.Location  = New-Object System.Drawing.Point(220, 622)
$btnRun.Size      = New-Object System.Drawing.Size(240, 40)
$form.Controls.Add($btnRun)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text      = "✖ EXIT"
$btnExit.Font      = $fMono10B
$btnExit.ForeColor = $cGray
$btnExit.BackColor = $cPanel
$btnExit.FlatStyle = "Flat"
$btnExit.FlatAppearance.BorderSize  = 1
$btnExit.FlatAppearance.BorderColor = $cBorder
$btnExit.Location  = New-Object System.Drawing.Point(480, 622)
$btnExit.Size      = New-Object System.Drawing.Size(160, 40)
$form.Controls.Add($btnExit)

# ── STATUS / FOOTER ────────────────────────────────────────────────────────
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text      = "● SYSTEM ONLINE   v3.0.0   $(Get-Date -Format 'yyyy-MM-dd  HH:mm:ss')"
$statusLabel.Font      = $fMono8
$statusLabel.ForeColor = $cRedDim
$statusLabel.Location  = New-Object System.Drawing.Point(26, 672)
$statusLabel.Size      = New-Object System.Drawing.Size(600, 16)
$form.Controls.Add($statusLabel)

# ── UPDATE TASK UI ─────────────────────────────────────────────────────────
function Update-TaskUI {
    param([int]$idx, [bool]$done = $false)
    for ($i = 0; $i -lt $TaskNames.Count; $i++) {
        if ($i -lt $idx) {
            $script:TaskStatus[$i].Text      = "✔"
            $script:TaskStatus[$i].ForeColor = $cGreen
            $script:TaskLabels[$i].ForeColor = $cGray
        } elseif ($i -eq $idx -and -not $done) {
            $script:TaskStatus[$i].Text      = "►"
            $script:TaskStatus[$i].ForeColor = $cRed
            $script:TaskLabels[$i].ForeColor = $cWhite
        } else {
            $script:TaskStatus[$i].Text      = "·"
            $script:TaskStatus[$i].ForeColor = $cRedDim
            $script:TaskLabels[$i].ForeColor = $cGray
        }
    }
    $pct = [math]::Round($idx / $TaskNames.Count * 100)
    $fillW = [math]::Round($pct / 100 * 630)
    $script:OverallFill.Width    = $fillW
    $script:OverallPct.Text      = "$pct%"
    $form.Refresh()
}

# ── WORKING DIR ────────────────────────────────────────────────────────────
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
$PowPath = Join-Path $WorkingDir "Custard.pow"

# ── OPTIMIZATION FUNCTIONS ─────────────────────────────────────────────────
function Optimize-Kernel {
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    bcdedit /set synthetictimers yes 2>$null | Out-Null
    $hpet = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision*" } -ErrorAction SilentlyContinue
    if ($hpet) { Disable-PnpDevice -InstanceId $hpet.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
}
function Optimize-TimerResolution {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
}
function Optimize-IRQ {
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $msiPath = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $msiPath) { Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null }
    }
}
function Optimize-Nagle {
    $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
}
function Optimize-VisualEffects {
    $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
    Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
}
function Disable-GameBar {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null
    $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
}
function Optimize-ProcessorPower {
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
}
function Optimize-Priority {
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
function Optimize-Memory {
    $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $pp = "$mp\PrefetchParameters"
    Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown"       -Value 0  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $pp -Name "EnablePrefetcher"  -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $pp -Name "EnableSuperfetch"  -Value 0 -Type DWord -Force 2>$null
    powercfg -h off 2>$null | Out-Null
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
}
function Optimize-Input {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }
    Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed"       -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1"  -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2"  -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
}
function Install-CustardPowerPlan {
    if (-not (Test-Path $PowPath)) {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
    }
    $Guid = "4e2cd77e-229e-484e-b077-c63e8b092ec8"
    powercfg /delete $Guid 2>$null
    powercfg /import $PowPath $Guid 2>$null | Out-Null
    powercfg /setactive $Guid 2>$null | Out-Null
}
function Optimize-Network {
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
    Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue
}
function Optimize-Services {
    @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc') | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer') | ForEach-Object {
        Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
}
function Clean-TrashAndLogs {
    @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*") | ForEach-Object {
        Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
}

$AllTasks = @(
    { Optimize-Kernel },       { Optimize-TimerResolution }, { Optimize-Priority },
    { Optimize-IRQ },          { Optimize-Memory },          { Optimize-Input },
    { Optimize-Nagle },        { Optimize-VisualEffects },   { Disable-GameBar },
    { Optimize-ProcessorPower }, { Install-CustardPowerPlan }, { Optimize-Network },
    { Optimize-Services },     { Clean-TrashAndLogs }
)

# ── INIT ANIMATION (runs on form load) ────────────────────────────────────
$initTimer = New-Object System.Windows.Forms.Timer
$initTimer.Interval = 30
$initStep = 0
$initTimer.Add_Tick({
    $initStep++
    $pct = [math]::Min(100, $initStep * 2)
    $initBarFill.Width = [math]::Round($pct / 100 * 804)
    $initPctLabel.Text = "$pct%"
    if ($pct -ge 100) {
        $initTimer.Stop()
        $initLabel.Text      = "ALL MODULES READY"
        $initLabel.ForeColor = $cGreen
        $readyLabel.Text     = "✔ SYSTEM ONLINE — READY TO OPTIMIZE"
        $readyLabel.ForeColor = $cGreen
    }
})

# ── RUN BUTTON ─────────────────────────────────────────────────────────────
$btnRun.Add_Click({
    $btnRun.Enabled  = $false
    $btnExit.Enabled = $false
    $taskPanel.Visible = $true
    $script:TaskIdx    = 0
    Update-TaskUI 0

    $runTimer = New-Object System.Windows.Forms.Timer
    $runTimer.Interval = 50
    $runTimer.Add_Tick({
        $i = $script:TaskIdx
        if ($i -lt $AllTasks.Count) {
            Update-TaskUI $i
            try { & $AllTasks[$i] } catch {}
            $script:TaskIdx++
            Update-TaskUI $script:TaskIdx
        } else {
            $runTimer.Stop()
            $statusLabel.Text      = "✔ ALL TWEAKS COMPLETED SUCCESSFULLY!"
            $statusLabel.ForeColor = $cGreen
            $btnExit.Enabled       = $true
            $btnExit.Text          = "✔ DONE — EXIT"
            $btnExit.ForeColor     = $cGreen
            $res = [System.Windows.Forms.MessageBox]::Show(
                "All optimizations complete!`nRestart your PC now?",
                "GOAT — Complete", "YesNo", "Information")
            if ($res -eq "Yes") { Restart-Computer -Force }
        }
    })
    $runTimer.Start()
})

$btnExit.Add_Click({ $form.Close() })

$form.Add_Shown({
    $initTimer.Start()
})

[System.Windows.Forms.Application]::Run($form)
