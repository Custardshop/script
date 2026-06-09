#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Horizontal Landscape
  Theme: Onyx Crimson · Soft Luxury
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

# ── PALETTE — ONYX CRIMSON ─────────────────────────────────────────────────
$cBg         = [System.Drawing.Color]::FromArgb(8,   8,   10)
$cSurface    = [System.Drawing.Color]::FromArgb(14,  14,  18)
$cCard       = [System.Drawing.Color]::FromArgb(18,  18,  24)
$cCardHover  = [System.Drawing.Color]::FromArgb(24,  24,  32)
$cBorderFine = [System.Drawing.Color]::FromArgb(30,  30,  40)

# Crimson accent palette
$cAccent     = [System.Drawing.Color]::FromArgb(180, 30,  50)    # deep crimson
$cAccentGlow = [System.Drawing.Color]::FromArgb(220, 50,  70)    # bright crimson
$cAccentDim  = [System.Drawing.Color]::FromArgb(100, 20,  30)    # muted crimson

$cWhite      = [System.Drawing.Color]::FromArgb(245, 240, 238)
$cWhiteDim   = [System.Drawing.Color]::FromArgb(170, 165, 162)
$cMuted      = [System.Drawing.Color]::FromArgb(90,  86,  90)
$cDimText    = [System.Drawing.Color]::FromArgb(52,  50,  55)
$cDone       = [System.Drawing.Color]::FromArgb(70,  68,  72)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fUI8      = New-Object System.Drawing.Font("Segoe UI", 8)
$fUI9      = New-Object System.Drawing.Font("Segoe UI", 9)
$fUISemi   = New-Object System.Drawing.Font("Segoe UI Semibold", 9.5)
$fUIBold9  = New-Object System.Drawing.Font("Segoe UI Bold", 9)
$fMono8    = New-Object System.Drawing.Font("Consolas", 8)
$fMono9    = New-Object System.Drawing.Font("Consolas", 9)
$fTitle    = New-Object System.Drawing.Font("Segoe UI Black", 24, [System.Drawing.FontStyle]::Bold)
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
    "kernel"   = "Disable platform clock, optimize TSC synchronization."
    "timer"    = "Force global kernel timer resolution requests."
    "priority" = "Adjust Win32 separation and multimedia scheduling."
    "irq"      = "Enforce Message Signaled Interrupts on PCI devices."
    "memory"   = "Disable Superfetch, optimize dirty page thresholds."
    "input"    = "Remove mouse acceleration, disable USB power savings."
    "nagle"    = "Disable Nagle's algorithm for low-latency network packet transmission."
    "visual"   = "Optimize system responsiveness by disabling window animations."
    "gamebar"  = "Turn off Xbox Game DVR background capture and overlay."
    "power"    = "Lock CPU minimum and maximum P-states to full capacity."
    "network"  = "Enable RSS, configure TCP autotuning, flush DNS cache."
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

# ── FORM SETUP (HORIZONTAL LANDSCAPE) ──────────────────────────────────────
$form = New-Object DBForm
$form.Text            = "GOAT — Premium Edition v4.0"
$form.Size            = New-Object System.Drawing.Size(1160, 680)
$form.MinimumSize     = New-Object System.Drawing.Size(1160, 680)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false

# ── TITLE BAR (TOP STRIP) ──────────────────────────────────────────────────
$titleBar = New-Object DBPanel
$titleBar.Dock      = [System.Windows.Forms.DockStyle]::Top
$titleBar.Height    = 36
$titleBar.BackColor = $cSurface

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
    $g.DrawString("GOAT.dashboard.v4.0.landscape", $fMono8, $brText, 76, 12)
    $brText.Dispose()
    
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,22,26), 1)
    $g.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $pen.Dispose()
})

# ── LEFT SIDEBAR (HERO & SYSINFO) ─────────────────────────────────────────
$sidebar = New-Object DBPanel
$sidebar.Dock      = [System.Windows.Forms.DockStyle]::Left
$sidebar.Width     = 340
$sidebar.BackColor = $cSurface

$sidebar.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Accent Glow Left Edge
    $glowBr = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new(4,0),
        [System.Drawing.Color]::FromArgb(180,180,30,50), [System.Drawing.Color]::FromArgb(0,180,30,50)
    )
    $g.FillRectangle($glowBr, 0, 30, 4, 80)
    $glowBr.Dispose()

    # Brand Title
    $titleBr = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString("GOAT", $fTitle, $titleBr, 24, 26)
    $titleBr.Dispose()

    $dotBr = New-Object System.Drawing.SolidBrush($cAccent)
    $g.FillEllipse($dotBr, 142, 32, 7, 7)
    $dotBr.Dispose()

    $subBr = New-Object System.Drawing.SolidBrush($cMuted)
    $g.DrawString("GREATEST OF ALL TWEAKS", $fCap, $subBr, 26, 74)
    $subBr.Dispose()

    # System Info Header
    $g.DrawString("SPECIFICATIONS", $fCap, New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80,30,45)), 26, 140)

    # Box container for specs
    $boxPath = Get-RoundedRect 24 160 292 250 8
    $boxBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20,20,26))
    $g.FillPath($boxBr, $boxPath); $boxBr.Dispose()
    $boxPen = New-Object System.Drawing.Pen($cBorderFine, 1)
    $g.DrawPath($boxPen, $boxPath); $boxPen.Dispose(); $boxPath.Dispose()

    # Layout values
    $lblBr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,30,50))
    $valBr = New-Object System.Drawing.SolidBrush($cWhiteDim)
    $rows  = @(180, 222, 264, 306, 348)
    $names = @("IDENTITY", "PROCESSOR", "GRAPHICS", "MEMORY", "PLATFORM")
    $vals  = @($UserShort, $CPUShort, $GPUShort, "$RAMUsed / $($RAMTotal) GB  ($RAMPct%)", $OSShort)

    for($i=0; $i -lt 5; $i++) {
        $g.DrawString($names[$i], $fCap, $lblBr, 40, $rows[$i])
        $g.DrawString($vals[$i], $fCap, $valBr, 40, $rows[$i]+14)
    }
    $lblBr.Dispose(); $valBr.Dispose()

    # Separator Line
    $sepPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(24,24,30), 1)
    $g.DrawLine($sepPen, 0, $s.Height-1, $s.Width, $s.Height-1)
    $sepPen.Dispose()
})

# ── RIGHT CONTENT CONTROLLER (CONTAINER) ──────────────────────────────────
$mainContent = New-Object DBPanel
$mainContent.Dock      = [System.Windows.Forms.DockStyle]::Fill
$mainContent.BackColor = $cBg

# Sub Header inside Main Panel
$subHeader = New-Object DBPanel
$subHeader.Dock      = [System.Windows.Forms.DockStyle]::Top
$subHeader.Height    = 50
$subHeader.BackColor = $cBg

$lblMod = New-Object System.Windows.Forms.Label
$lblMod.Text      = "TUNING MODULES ARCHITECTURE"
$lblMod.Font      = $fCap
$lblMod.ForeColor = [System.Drawing.Color]::FromArgb(70,66,72)
$lblMod.Location  = New-Object System.Drawing.Point(24, 20)
$lblMod.AutoSize  = $true
$subHeader.Controls.Add($lblMod)

$lblCounter = New-Object System.Windows.Forms.Label
$lblCounter.Text      = "0 / 13 CHANNELS READY"
$lblCounter.Font      = $fMono8
$lblCounter.ForeColor = $cAccentDim
$lblCounter.Location  = New-Object System.Drawing.Point(620, 18)
$lblCounter.Size      = New-Object System.Drawing.Size(150, 20)
$lblCounter.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$subHeader.Controls.Add($lblCounter)

# Scrollable Panel for grid rows
$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.Dock        = [System.Windows.Forms.DockStyle]::Fill
$scrollPanel.AutoScroll  = $true
$scrollPanel.BackColor   = $cBg

[int]$rowW = 764
[int]$rowH = 46
[int]$yPos = 4
[int]$tidx = 0

$script:TaskRows = @{}
$taskKeys = @($script:Tasks.Keys)

foreach ($key in $taskKeys) {
    $label  = $script:Tasks[$key]
    $desc   = $script:TaskDesc[$key]
    $idxTxt = ($tidx + 1).ToString("00")

    $row = New-Object DBPanel
    $row.Size     = New-Object System.Drawing.Size($rowW, $rowH)
    $row.Location = New-Object System.Drawing.Point(16, $yPos)
    $row.BackColor = [System.Drawing.Color]::Transparent
    $row.Tag      = "pending"
    $scrollPanel.Controls.Add($row)

    $row.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $st = $s.Tag
        
        # Draw background container base on real-time state
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
        } else {
            $br = New-Object System.Drawing.SolidBrush($cCard)
            $g.FillPath($br, $path); $br.Dispose()
            $pen = New-Object System.Drawing.Pen($cBorderFine, 1)
            $g.DrawPath($pen, $path); $pen.Dispose()
        }
        $path.Dispose()

        # Channel Index
        $numBr = New-Object System.Drawing.SolidBrush(if($st -eq "done"){$cDimText}else{$cAccentDim})
        $g.DrawString($idxTxt, $fMono8, $numBr, 16, 16)
        $numBr.Dispose()

        # Task Heading
        $lblBr = New-Object System.Drawing.SolidBrush(if($st -eq "done"){$cDone}else{$cWhite})
        $g.DrawString($label, $fUISemi, $lblBr, 46, 13)
        $lblBr.Dispose()

        # Core Description string clipped neatly
        $descBr = New-Object System.Drawing.SolidBrush(if($st -eq "done"){[System.Drawing.Color]::FromArgb(34,34,38)}else{$cMuted})
        $g.DrawString($desc, $fUI8, $descBr, 190, 15)
        $descBr.Dispose()

        # Right status mapping
        if ($st -eq "done") {
            $statusStr = "PATCHED"
            $statusBr  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50,50,55))
        } elseif ($st -eq "running") {
            $statusStr = "INJECTING"
            $statusBr  = New-Object System.Drawing.SolidBrush($cAccentGlow)
        } else {
            $statusStr = "READY"
            $statusBr  = New-Object System.Drawing.SolidBrush($cDimText)
        }
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Far
        $g.DrawString($statusStr, $fMono8, $statusBr, ($s.Width - 24), 16, $sf)
        $statusBr.Dispose(); $sf.Dispose()
    })

    $row.Add_MouseEnter({ param($s,$e) if ($s.Tag -eq "pending") { $s.Tag = "hover"; $s.Invalidate() } })
    $row.Add_MouseLeave({ param($s,$e) if ($s.Tag -eq "hover")   { $s.Tag = "pending"; $s.Invalidate() } })

    $script:TaskRows[$key] = $row
    $yPos += $rowH + 4
    $tidx++
}

# ── CONTROL PANEL / FOOTER STRIP ──────────────────────────────────────────
$controlStrip = New-Object DBPanel
$controlStrip.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$controlStrip.Height    = 76
$controlStrip.BackColor = $cSurface

$controlStrip.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30,30,40), 1)
    $g.DrawLine($pen, 0, 0, $s.Width, 0)
    $pen.Dispose()
})

# Track Slider BG
$trackBg = New-Object DBPanel
$trackBg.Location  = New-Object System.Drawing.Point(24, 24)
$trackBg.Size      = New-Object System.Drawing.Size(440, 5)
$trackBg.BackColor = [System.Drawing.Color]::FromArgb(24,24,30)
$controlStrip.Controls.Add($trackBg)

$trackBg.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 2
    $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24,24,30))
    $g.FillPath($br, $path); $br.Dispose(); $path.Dispose()
})

$overallFill = New-Object DBPanel
$overallFill.Location  = New-Object System.Drawing.Point(0, 0)
$overallFill.Size      = New-Object System.Drawing.Size(0, 5)
$overallFill.BackColor = $cAccent
$trackBg.Controls.Add($overallFill)

$overallFill.Add_Paint({
    param($s,$e)
    if ($s.Width -lt 2) { return }
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
        [System.Drawing.Color]::FromArgb(140,22,36), $cAccentGlow
    )
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 2
    $g.FillPath($gb, $path); $gb.Dispose(); $path.Dispose()
})

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text      = "STANDBY PIPELINE READY"
$lblStatus.Font      = $fCap
$lblStatus.ForeColor = $cMuted
$lblStatus.Location  = New-Object System.Drawing.Point(24, 38)
$lblStatus.Size      = New-Object System.Drawing.Size(440, 20)
$controlStrip.Controls.Add($lblStatus)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text      = "RESTART SYSTEM"
$btnRestart.Font      = $fUI9
$btnRestart.ForeColor = $cAccentGlow
$btnRestart.BackColor = [System.Drawing.Color]::FromArgb(28,14,18)
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.FlatAppearance.BorderColor = $cAccentDim
$btnRestart.Size      = New-Object System.Drawing.Size(130, 32)
$btnRestart.Location  = New-Object System.Drawing.Point(500, 20)
$btnRestart.Visible   = $false
$btnRestart.Add_Click({
    $ans = [System.Windows.Forms.MessageBox]::Show("Restart the system now to enforce optimized states?", "Deployment Complete", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($ans -eq [System.Windows.Forms.DialogResult]::Yes) { Restart-Computer -Force }
})
$controlStrip.Controls.Add($btnRestart)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "INITIALIZE ENGINE"
$btnRun.Font      = $fUIBold9
$btnRun.ForeColor = $cWhite
$btnRun.BackColor = $cAccent
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Size      = New-Object System.Drawing.Size(140, 32)
$btnRun.Location  = New-Object System.Drawing.Point(640, 20)
$controlStrip.Controls.Add($btnRun)

$btnRun.Add_Paint({
    param($s,$e)
    if (-not $s.Enabled) { return }
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $path = Get-RoundedRect 0 0 $s.Width $s.Height 5
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new(0,$s.Height),
        [System.Drawing.Color]::FromArgb(210,40,60), [System.Drawing.Color]::FromArgb(140,20,36)
    )
    $g.FillPath($gb, $path); $gb.Dispose(); $path.Dispose()

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $br = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString($s.Text, $s.Font, $br, [System.Drawing.RectangleF]::new(0,0,$s.Width,$s.Height), $sf)
    $br.Dispose(); $sf.Dispose()
})

# Assemble Panels
$mainContent.Controls.Add($scrollPanel)
$mainContent.Controls.Add($controlStrip)
$mainContent.Controls.Add($subHeader)

$form.Controls.Add($mainContent)
$form.Controls.Add($sidebar)
$form.Controls.Add($titleBar)

# ── LOGIC AND ENGINE CONTROLLER ────────────────────────────────────────────
$script:IsRunning   = $false
$script:RunIndex    = 0
$script:DoneCount   = 0
$script:TaskKeyList = @($script:Tasks.Keys)
$script:TotalTasks  = $script:TaskKeyList.Count

$timerWorker = New-Object System.Windows.Forms.Timer
$timerWorker.Interval = 300

$timerWorker.Add_Tick({
    if ($script:RunIndex -lt $script:TotalTasks) {
        $key = $script:TaskKeyList[$script:RunIndex]
        $row = $script:TaskRows[$key]
        
        if ($row.Tag -ne "running") {
            $row.Tag = "running"
            $row.Invalidate()
            $fnName = $script:FnMap[$key]
            $lblStatus.Text = "DEPLOYING: $( $script:Tasks[$key].ToUpper() )"
            
            # Asynchronous script block delivery channel
            Start-Job -ScriptBlock {
                param($fn)
                function Invoke-Kernel { bcdedit /set useplatformclock no 2>$null; bcdedit /set useplatformtick yes 2>$null; bcdedit /set disabledynamictick yes 2>$null; bcdedit /set tscsyncpolicy Enhanced 2>$null; bcdedit /set nx OptOut 2>$null; bcdedit /set synthetictimers yes 2>$null; $h = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like "*High Precision*" }; if ($h) { Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue } }
                function Invoke-TimerResolution { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null }
                function Invoke-IRQ { Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object { $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"; if (Test-Path $p) { Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null } } }
                function Invoke-Nagle { $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force 2>$null } }
                function Invoke-VisualEffects { $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }; Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null }
                function Invoke-GameBar { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force 2>$null; $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }; Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null }
                function Invoke-ProcessorPower { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null; powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null; powercfg /setactive SCHEME_CURRENT 2>$null }
                function Invoke-Priority { $pp = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"; $sp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; $gp = "$sp\Tasks\Games"; $ep = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"; Set-ItemProperty -Path $pp -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null; Set-ItemProperty -Path $sp -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null; Set-ItemProperty -Path $ep -Name "AdditionalCriticalWorkerThreads" -Value 2 -Type DWord -Force 2>$null; if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }; Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force 2>$null; Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null; Set-ItemProperty -Path $gp -Name "SFIO Priority" -Value "High" -Type String -Force 2>$null }
                function Invoke-Memory { $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force 2>$null; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null; Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null; powercfg -h off 2>$null; taskkill /f /im OneDrive.exe 2>$null; Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue }
                function Invoke-Input { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null; $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"; if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }; Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Type String -Force 2>$null; Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable" -Value 0 -Type DWord -Force 2>$null }
                function Invoke-Network { netsh int tcp set global rss=enabled 2>$null; netsh int tcp set global autotuninglevel=disabled 2>$null; netsh int tcp set global timestamps=disabled 2>$null; netsh int tcp set global chimney=disabled 2>$null; $tp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Set-ItemProperty -Path $tp -Name "TcpNoDelay" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null; Set-ItemProperty -Path $tp -Name "DefaultTTL" -Value 64 -Type DWord -Force 2>$null; Clear-DnsClientCache -ErrorAction SilentlyContinue; netsh winsock reset 2>$null; netsh int ip reset 2>$null; ipconfig /release 2>$null; ipconfig /renew 2>$null; Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue }
                function Invoke-Services { @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')|ForEach-Object{ Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue; Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue }; @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')|ForEach-Object{ Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service -Name $_ -ErrorAction SilentlyContinue } }
                function Invoke-Cleanup { @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*")|ForEach-Object{ Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue|Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }; Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue; Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service -Name wuauserv -ErrorAction SilentlyContinue; wevtutil.exe el|ForEach-Object{ wevtutil.exe cl \"$_\" 2>$null } }
                try { & $fn } catch {}
            } -ArgumentList $fnName | Out-Null
        } else {
            $row.Tag = "done"
            $row.Invalidate()
            $script:DoneCount++
            
            $lblCounter.Text = "$($script:DoneCount) / 13 CHANNELS PATCHED"
            [int]$pct = [math]::Round(($script:DoneCount / $script:TotalTasks) * 100)
            $overallFill.Width = [int]($trackBg.Width * ($script:DoneCount / $script:TotalTasks))
            $lblStatus.Text = "TUNING PIPELINE ENGAGED  ·  $($pct)%"
            
            $script:RunIndex++
        }
    } else {
        $timerWorker.Stop()
        $lblStatus.Text     = "ENGINE OPTIMIZATION COMPLETED  ·  100%"
        $lblStatus.ForeColor = $cAccentGlow
        $btnRun.Enabled     = $false
        $btnRun.Visible     = $false
        $btnRestart.Location = $btnRun.Location
        $btnRestart.Visible = $true
        $script:IsRunning   = $false
    }
})

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning = $true
    $script:RunIndex  = 0
    $script:DoneCount = 0
    $btnRestart.Visible = $false
    $timerWorker.Start()
})

[void]$form.ShowDialog()
