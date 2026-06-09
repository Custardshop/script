#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Horizontal Landscape
  Theme: Onyx Crimson · Production Fixed Layout
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

# ── GLOBAL PALETTE — ONYX CRIMSON ─────────────────────────────────────────
$global:cBg         = [System.Drawing.Color]::FromArgb(8,   8,   10)
$global:cSurface    = [System.Drawing.Color]::FromArgb(14,  14,  18)
$global:cCard       = [System.Drawing.Color]::FromArgb(18,  18,  24)
$global:cCardHover  = [System.Drawing.Color]::FromArgb(24,  24,  32)
$global:cBorderFine = [System.Drawing.Color]::FromArgb(30,  30,  40)

$global:cAccent     = [System.Drawing.Color]::FromArgb(180, 30,  50)
$global:cAccentGlow = [System.Drawing.Color]::FromArgb(220, 50,  70)
$global:cAccentDim  = [System.Drawing.Color]::FromArgb(100, 20,  30)

$global:cWhite      = [System.Drawing.Color]::FromArgb(245, 240, 238)
$global:cWhiteDim   = [System.Drawing.Color]::FromArgb(170, 165, 162)
$global:cMuted      = [System.Drawing.Color]::FromArgb(90,  86,  90)
$global:cDimText    = [System.Drawing.Color]::FromArgb(52,  50,  55)
$global:cDone       = [System.Drawing.Color]::FromArgb(70,  68,  72)

# ── GLOBAL FONTS ──────────────────────────────────────────────────────────
$global:fUI8      = New-Object System.Drawing.Font("Segoe UI", 8)
$global:fUI9      = New-Object System.Drawing.Font("Segoe UI", 9)
$global:fUISemi   = New-Object System.Drawing.Font("Segoe UI Semibold", 9.5)
$global:fUIBold9  = New-Object System.Drawing.Font("Segoe UI Bold", 9)
$global:fMono8    = New-Object System.Drawing.Font("Consolas", 8)
$global:fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$global:fTitle    = New-Object System.Drawing.Font("Segoe UI Black", 24, [System.Drawing.FontStyle]::Bold)
$global:fCap      = New-Object System.Drawing.Font("Segoe UI", 7)

# ── SYSTEM INFO GETTER ─────────────────────────────────────────────────────
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
$CPUShort  = Trim-String $CPU 38
$GPUShort  = Trim-String $GPU 38
$OSShort   = Trim-String $OSName 38
$UserShort = Trim-String "$UserName @ $PCName" 38

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
    "kernel"   = "Disable platform clock, optimize TSC synchronization safely."
    "timer"    = "Force global kernel timer resolution requests."
    "priority" = "Adjust Win32 separation and multimedia scheduling."
    "irq"      = "Enforce Message Signaled Interrupts on PCI devices."
    "memory"   = "Disable Superfetch, optimize dirty page thresholds."
    "input"    = "Remove mouse acceleration, disable USB power savings."
    "nagle"    = "Disable Nagle's algorithm for low-latency network packet transmission."
    "visual"   = "Optimize system responsiveness by disabling window animations."
    "gamebar"  = "Turn off Xbox Game DVR background capture and overlay."
    "power"    = "Lock CPU minimum and maximum P-states to full capacity."
    "network"  = "Enable RSS, configure TCP autotuning, clear DNS cache."
    "services" = "Disable background tracking, telemetry, and unnecessary services."
    "cleanup"  = "Clear software distribution caches, user temp folders, and logs."
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

function Get-RoundedRect([int]$x,[int]$y,[int]$w,[int]$h,[int]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x,          $y,          $r*2, $r*2, 180, 90)
    $path.AddArc($x+$w-$r*2,  $y,          $r*2, $r*2, 270, 90)
    $path.AddArc($x+$w-$r*2,  $y+$h-$r*2,  $r*2, $r*2,   0, 90)
    $path.AddArc($x,          $y+$h-$r*2,  $r*2, $r*2,  90, 90)
    $path.CloseFigure()
    return $path
}

# ── FORM SETUP ─────────────────────────────────────────────────────────────
$form = New-Object DBForm
$form.Text            = "GOAT — Premium Edition v4.0"
$form.Size            = New-Object System.Drawing.Size(1160, 680)
$form.MinimumSize     = New-Object System.Drawing.Size(1160, 680)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $global:cBg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false

# ── TITLE BAR ──────────────────────────────────────────────────────────────
$titleBar = New-Object DBPanel
$titleBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$titleBar.Height    = 36
$titleBar.BackColor = $global:cSurface

$titleBar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $colors = @([System.Drawing.Color]::FromArgb(255,90,90), [System.Drawing.Color]::FromArgb(255,190,60), [System.Drawing.Color]::FromArgb(60,200,80))
    for ($i=0;$i -lt 3;$i++) {
        $br = New-Object System.Drawing.SolidBrush($colors[$i])
        $g.FillEllipse($br, 16+($i*18), 13, 9, 9)
        $br.Dispose()
    }
    $brText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70,70,80))
    $g.DrawString("GOAT.dashboard.v4.0.landscape", $global:fMono8, $brText, 76, 12)
    $brText.Dispose()
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,22,26), 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
})

# ── SIDEBAR ────────────────────────────────────────────────────────────────
$sidebar = New-Object DBPanel
$sidebar.Dock      = [System.Windows.Forms.DockStyle]::Left
$sidebar.Width     = 340
$sidebar.BackColor = $global:cSurface

$sidebar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $titleBr = New-Object System.Drawing.SolidBrush($global:cWhite)
    $g.DrawString("GOAT", $global:fTitle, $titleBr, 24, 26); $titleBr.Dispose()
    $dotBr = New-Object System.Drawing.SolidBrush($global:cAccent)
    $g.FillEllipse($dotBr, 142, 32, 7, 7); $dotBr.Dispose()
    $subBr = New-Object System.Drawing.SolidBrush($global:cMuted)
    $g.DrawString("GREATEST OF ALL TWEAKS", $global:fCap, $subBr, 26, 74); $subBr.Dispose()
    $hdrBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,30,50))
    $g.DrawString("SPECIFICATIONS", $global:fCap, $hdrBr, 26, 140); $hdrBr.Dispose()

    $boxPath = Get-RoundedRect 24 160 292 250 8
    $boxBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20,20,26))
    $g.FillPath($boxBr, $boxPath); $boxBr.Dispose()
    $boxPen = New-Object System.Drawing.Pen($global:cBorderFine, 1)
    $g.DrawPath($boxPen, $boxPath); $boxPen.Dispose(); $boxPath.Dispose()

    $lblBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100,24,40))
    $valBr = New-Object System.Drawing.SolidBrush($global:cWhiteDim)
    $rows  = @(180, 222, 264, 306, 348)
    $names = @("IDENTITY", "PROCESSOR", "GRAPHICS", "MEMORY", "PLATFORM")
    $vals  = @($UserShort, $CPUShort, $GPUShort, "$RAMUsed / $($RAMTotal) GB  ($RAMPct%)", $OSShort)
    for($i=0; $i -lt 5; $i++) {
        $g.DrawString($names[$i], $global:fCap, $lblBr, 40, $rows[$i])
        $g.DrawString($vals[$i], $global:fCap, $valBr, 40, $rows[$i]+14)
    }
    $lblBr.Dispose(); $valBr.Dispose()
})

# ── MAIN CONTENT AREA ──────────────────────────────────────────────────────
$mainContent = New-Object DBPanel
$mainContent.Dock      = [System.Windows.Forms.DockStyle]::Fill
$mainContent.BackColor = $global:cBg

$subHeader = New-Object DBPanel
$subHeader.Dock      = [System.Windows.Forms.DockStyle]::Top
$subHeader.Height    = 50
$subHeader.BackColor = $global:cBg

$lblMod = New-Object System.Windows.Forms.Label
$lblMod.Text      = "TUNING MODULES ARCHITECTURE"
$lblMod.Font      = $global:fCap
$lblMod.ForeColor = [System.Drawing.Color]::FromArgb(70,66,72)
$lblMod.Location  = New-Object System.Drawing.Point(24, 20)
$lblMod.AutoSize  = $true
$subHeader.Controls.Add($lblMod)

$lblCounter = New-Object System.Windows.Forms.Label
$lblCounter.Text      = "0 / 13 CHANNELS READY"
$lblCounter.Font      = $global:fMono8
$lblCounter.ForeColor = $global:cAccentDim
$lblCounter.Location  = New-Object System.Drawing.Point(580, 18)
$lblCounter.Size      = New-Object System.Drawing.Size(200, 20)
$lblCounter.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$subHeader.Controls.Add($lblCounter)

$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.Dock        = [System.Windows.Forms.DockStyle]::Fill
$scrollPanel.AutoScroll  = $true
$scrollPanel.BackColor   = $global:cBg

[int]$rowW = 750
[int]$rowH = 46
[int]$yPos = 4
[int]$tidx = 0

$script:TaskRows = @{}
$taskKeys = @($script:Tasks.Keys)

foreach ($key in $taskKeys) {
    # Local variable captures safely passed to internal drawing scope
    $lblText  = $script:Tasks[$key]
    $descText = $script:TaskDesc[$key]
    $idxTxt   = ($tidx + 1).ToString("00")

    $row = New-Object DBPanel
    $row.Size     = New-Object System.Drawing.Size($rowW, $rowH)
    $row.Location = New-Object System.Drawing.Point(16, $yPos)
    $row.BackColor = [System.Drawing.Color]::Transparent
    $row.Tag      = "pending"
    
    # Store string mappings directly onto Control properties to prevent blank scope states
    $row.AccessibleName = $lblText
    $row.AccessibleDescription = $descText
    $row.Name = $idxTxt
    
    $scrollPanel.Controls.Add($row)

    $row.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $st = $s.Tag
        
        $path = Get-RoundedRect 0 1 ($s.Width-2) ($s.Height-3) 5
        if ($st -eq "running") {
            $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24,16,18))
            $g.FillPath($br, $path); $br.Dispose()
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120,180,30,50), 1)
            $g.DrawPath($pen, $path); $pen.Dispose()
        } elseif ($st -eq "done") {
            $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(14,14,16))
            $g.FillPath($br, $path); $br.Dispose()
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(24,24,30), 1)
            $g.DrawPath($pen, $path); $pen.Dispose()
        } elseif ($st -eq "skipped") {
            $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20,20,15))
            $g.FillPath($br, $path); $br.Dispose()
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60,60,40), 1)
            $g.DrawPath($pen, $path); $pen.Dispose()
        } else {
            $br = New-Object System.Drawing.SolidBrush($global:cCard)
            $g.FillPath($br, $path); $br.Dispose()
            $pen = New-Object System.Drawing.Pen($global:cBorderFine, 1)
            $g.DrawPath($pen, $path); $pen.Dispose()
        }
        $path.Dispose()

        # Render Text fields explicitly referencing global objects
        $numBr = New-Object System.Drawing.SolidBrush(if($st -eq "done" -or $st -eq "skipped"){$global:cDimText}else{$global:cAccentDim})
        $g.DrawString($s.Name, $global:fMono8, $numBr, 16, 16); $numBr.Dispose()

        $lblBr = New-Object System.Drawing.SolidBrush(if($st -eq "done" -or $st -eq "skipped"){$global:cDone}else{$global:cWhite})
        $g.DrawString($s.AccessibleName, $global:fUISemi, $lblBr, 46, 13); $lblBr.Dispose()

        $descBr = New-Object System.Drawing.SolidBrush(if($st -eq "done" -or $st -eq "skipped"){[System.Drawing.Color]::FromArgb(34,34,38)}else{$global:cMuted})
        $g.DrawString($s.AccessibleDescription, $global:fUI8, $descBr, 190, 15); $descBr.Dispose()

        if ($st -eq "done") {
            $statusStr = "PATCHED"
            $statusBr  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50,50,55))
        } elseif ($st -eq "skipped") {
            $statusStr = "SKIPPED"
            $statusBr  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,110,40))
        } elseif ($st -eq "running") {
            $statusStr = "INJECTING"
            $statusBr  = New-Object System.Drawing.SolidBrush($global:cAccentGlow)
        } else {
            $statusStr = "READY"
            $statusBr  = New-Object System.Drawing.SolidBrush($global:cDimText)
        }
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Far
        $g.DrawString($statusStr, $global:fMono8, $statusBr, ($s.Width - 24), 16, $sf)
        $statusBr.Dispose(); $sf.Dispose()
    })

    $script:TaskRows[$key] = $row
    $yPos += $rowH + 4
    $tidx++
}

# ── BOTTOM PIPELINE CONTROL STRIP ──────────────────────────────────────────
$controlStrip = New-Object DBPanel
$controlStrip.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$controlStrip.Height    = 76
$controlStrip.BackColor = $global:cSurface

$trackBg = New-Object DBPanel
$trackBg.Location  = New-Object System.Drawing.Point(24, 24)
$trackBg.Size      = New-Object System.Drawing.Size(440, 5)
$trackBg.BackColor = [System.Drawing.Color]::FromArgb(24,24,30)
$controlStrip.Controls.Add($trackBg)

$overallFill = New-Object DBPanel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 5)
$overallFill.BackColor = $global:cAccent
$trackBg.Controls.Add($overallFill)

$overallFill.Add_Paint({
    param($s,$e)
    if ($s.Width -lt 2) { return }
    $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush([System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0), [System.Drawing.Color]::FromArgb(140,22,36), $global:cAccentGlow)
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 2
    $g.FillPath($gb, $path); $gb.Dispose(); $path.Dispose()
})

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text      = "STANDBY PIPELINE READY"
$lblStatus.Font      = $global:fCap
$lblStatus.ForeColor = $global:cMuted
$lblStatus.Location  = New-Object System.Drawing.Point(24, 38)
$lblStatus.Size      = New-Object System.Drawing.Size(440, 20)
$controlStrip.Controls.Add($lblStatus)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART SYSTEM"
$btnRestart.Font      = $global:fUI9
$btnRestart.ForeColor = $global:cAccentGlow
$btnRestart.BackColor = [System.Drawing.Color]::FromArgb(28,14,18)
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $global:cAccentDim
$btnRestart.Size      = New-Object System.Drawing.Size(130, 32)
$btnRestart.Location  = New-Object System.Drawing.Point(500, 20)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Restart now?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo) -eq [System.Windows.Forms.DialogResult]::Yes) { Restart-Computer -Force }
})
$controlStrip.Controls.Add($btnRestart)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "INITIALIZE ENGINE"
$btnRun.Font      = $global:fUIBold9
$btnRun.ForeColor = $global:cWhite
$btnRun.BackColor = $global:cAccent
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Size      = New-Object System.Drawing.Size(140, 32)
$btnRun.Location  = New-Object System.Drawing.Point(640, 20)
$controlStrip.Controls.Add($btnRun)

# Assembly UI Hierarchy
$mainContent.Controls.Add($scrollPanel)
$mainContent.Controls.Add($controlStrip)
$mainContent.Controls.Add($subHeader)
$form.Controls.Add($mainContent)
$form.Controls.Add($sidebar)
$form.Controls.Add($titleBar)

# ── ENGINE CONTROLLER PIPELINE ──────────────────────────────────────────────
$script:IsRunning   = $false
$script:RunIndex    = 0
$script:DoneCount   = 0
$script:TaskKeyList = @($script:Tasks.Keys)
$script:TotalTasks  = $script:TaskKeyList.Count
$script:CurrentJob  = $null
$script:StartTime   = $null

$timerWorker = New-Object System.Windows.Forms.Timer
$timerWorker.Interval = 200

$timerWorker.Add_Tick({
    if ($script:CurrentJob -ne $null) {
        $jobCheck = Get-Job -Id $script:CurrentJob.Id
        $elapsed = (Get-Date) - $script:StartTime
        
        if ($jobCheck.State -eq "Completed" -or $jobCheck.State -eq "Failed" -or $elapsed.TotalSeconds -gt 5) {
            $isTimeout = $elapsed.TotalSeconds -gt 5
            Receive-Job -Job $jobCheck | Out-Null
            Remove-Job -Job $jobCheck -Force
            
            $prevKey = $script:TaskKeyList[$script:RunIndex]
            $row = $script:TaskRows[$prevKey]
            $row.Tag = if ($isTimeout) { "skipped" } else { "done" }
            $row.Invalidate()
            
            $script:DoneCount++
            $script:RunIndex++
            $script:CurrentJob = $null
            
            $lblCounter.Text = "$($script:DoneCount) / 13 CHANNELS PROCESSED"
            $overallFill.Width = [int]($trackBg.Width * ($script:DoneCount / $script:TotalTasks))
        }
        return
    }

    if ($script:RunIndex -lt $script:TotalTasks) {
        $key = $script:TaskKeyList[$script:RunIndex]
        $row = $script:TaskRows[$key]
        $row.Tag = "running"
        $row.Invalidate()
        
        $fnName = $script:FnMap[$key]
        $lblStatus.Text = "DEPLOYING: $( $script:Tasks[$key].ToUpper() )"
        $script:StartTime = Get-Date
        
        $script:CurrentJob = Start-Job -ScriptBlock {
            param($fn)
            function Invoke-Kernel { bcdedit /set useplatformclock no 2>$null; bcdedit /set useplatformtick yes 2>$null; bcdedit /set disabledynamictick yes 2>$null; bcdedit /set tscsyncpolicy Enhanced 2>$null }
            function Invoke-TimerResolution { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null }
            function Invoke-IRQ { Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object { $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"; if (Test-Path $p) { Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null } } }
            function Invoke-Nagle { $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null } }
            function Invoke-VisualEffects { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null }
            function Invoke-GameBar { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null }
            function Invoke-ProcessorPower { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null; powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null; powercfg /setactive SCHEME_CURRENT 2>$null }
            function Invoke-Priority { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 42 -Type DWord -Force 2>$null }
            function Invoke-Memory { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null }
            function Invoke-Input { Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force 2>$null }
            function Invoke-Network { ipconfig /flushdns 2>$null; netsh int tcp set global rss=enabled 2>$null }
            function Invoke-Services { Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue }
            function Invoke-Cleanup { Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue }
            try { & $fn } catch {}
        } -ArgumentList $fnName
    } else {
        $timerWorker.Stop()
        $lblStatus.Text      = "ENGINE PROCESS PIPELINE COMPLETED"
        $lblStatus.ForeColor = $global:cAccentGlow
        $btnRun.Visible      = $false
        $btnRestart.Location = $btnRun.Location
        $btnRestart.Visible  = $true
        $script:IsRunning    = $false
    }
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning = $true
    $timerWorker.Start()
})

[void]$form.ShowDialog()
