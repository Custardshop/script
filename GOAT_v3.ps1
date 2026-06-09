#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Onyx Crimson · Soft Luxury (Horizontal Display v2)
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
$cAccentGlow = [System.Drawing.Color]::FromArgb(230, 20,  55)    # Bright Glow
$cAccentDim  = [System.Drawing.Color]::FromArgb(110, 15,  30)    # Muted Crimson
$cWhite      = [System.Drawing.Color]::FromArgb(240, 240, 245)
$cMuted      = [System.Drawing.Color]::FromArgb(130, 130, 140)
$cPending    = [System.Drawing.Color]::FromArgb(75,  75,  85)
$logBg      = [System.Drawing.Color]::FromArgb(8,   8,   10)

# ── FONTS ──────────────────────────────────────────────────────────────────
$fTitle    = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$fontBold  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontSub   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$fontLog   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)

# ── MAIN FORM ──────────────────────────────────────────────────────────────
$form = New-Object DBForm
$form.Text            = "GOAT — GREATEST OF ALL TWEAKS [Premium Edition v4.0]"
$form.Size            = New-Object System.Drawing.Size(1120, 660)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cBg
$form.ForeColor       = $cWhite
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false

# ── LEFT PANEL: SYSTEM INFO & CONTROLS (TRANSPARENT BG) ─────────────────────
$leftPanel = New-Object DBPanel
$leftPanel.Size     = New-Object System.Drawing.Size(320, 600)
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

# Red Divider
$sep1 = New-Object DBPanel
$sep1.BackColor = $cAccent
$sep1.Location  = New-Object System.Drawing.Point(15, 75)
$sep1.Size      = New-Object System.Drawing.Size(280, 2)
$leftPanel.Controls.Add($sep1)

# System Information Group
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
    "CPU: $CPU",
    "RAM Total: $RAMTotal GB",
    "RAM Free: $RAMFree MB ($RAMPct% Used)"
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

# Control Panel Area
$lblControlTitle = New-Object System.Windows.Forms.Label
$lblControlTitle.Text      = "CONTROL PANEL"
$lblControlTitle.Font      = $fontBold
$lblControlTitle.ForeColor = $cWhite
$lblControlTitle.Location  = New-Object System.Drawing.Point(15, 255)
$lblControlTitle.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblControlTitle)

# Custom High-Quality Loading Bar Panel (แบ่งชั้นเรียงตัวชัดเจน ไม่ทับซ้อนกัน)
$progressBarPanel = New-Object DBPanel
$progressBarPanel.Location = New-Object System.Drawing.Point(15, 285)
$progressBarPanel.Size     = New-Object System.Drawing.Size(280, 24)
$progressBarPanel.BackColor= [System.Drawing.Color]::FromArgb(35, 35, 40)
$leftPanel.Controls.Add($progressBarPanel)

$script:ProgressPct = 0
$progressBarPanel.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    # วาดแถบ Progress บาร์ตามสถานะเปอร์เซ็นต์
    if ($script:ProgressPct -gt 0) {
        $fillW = [math]::Round(($script:ProgressPct / 100) * $s.Width)
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            [System.Drawing.Point]::new(0,0), [System.Drawing.Point]::new($s.Width,0),
            $cAccent, $cAccentGlow
        )
        $g.FillRectangle($brush, 0, 0, $fillW, $s.Height)
        $brush.Dispose()
    }
    
    # แสดงตัวเลข % ด้านบนหรือในกล่องหลอดโหลดให้เหมาะสมสวยงาม
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textBrush = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString("$script:ProgressPct %", $fontBold, $textBrush, [System.Drawing.RectangleF]::new(0, 0, $s.Width, $s.Height), $stringFormat)
    $textBrush.Dispose(); $stringFormat.Dispose()
})

# Status Message Labels
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text      = "Ready to deploy performance configurations."
$lblHint.Font      = $fontSub
$lblHint.ForeColor = $cMuted
$lblHint.Location  = New-Object System.Drawing.Point(15, 320)
$lblHint.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblHint)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text      = "Tweak Engine Status: Idling"
$lblCount.Font      = $fontSub
$lblCount.ForeColor = $cAccentGlow
$lblCount.Location  = New-Object System.Drawing.Point(15, 342)
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
$btnRun.Location        = New-Object System.Drawing.Point(15, 380)
$btnRun.Size            = New-Object System.Drawing.Size(280, 45)
$leftPanel.Controls.Add($btnRun)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text            = "RESTART SYSTEM"
$btnRestart.Font            = $fontBold
$btnRestart.BackColor       = [System.Drawing.Color]::FromArgb(45, 45, 50)
$btnRestart.ForeColor       = $cWhite
$btnRestart.FlatStyle       = "Flat"
$btnRestart.FlatAppearance.BorderSize = 0
$btnRestart.Location        = New-Object System.Drawing.Point(15, 440)
$btnRestart.Size            = New-Object System.Drawing.Size(280, 35)
$btnRestart.Visible         = $false
$leftPanel.Controls.Add($btnRestart)

# ── RIGHT PANEL UPPER: TWEAKS LIST (NO CHECKBOXES - TEXT VIEW ONLY) ────────
$rightUpperPanel = New-Object DBPanel
$rightUpperPanel.Size     = New-Object System.Drawing.Size(740, 360)
$rightUpperPanel.Location = New-Object System.Drawing.Point(345, 15)
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
$rightLowerPanel.Size     = New-Object System.Drawing.Size(740, 225)
$rightLowerPanel.Location = New-Object System.Drawing.Point(345, 390)
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
$txtLog.Size            = New-Object System.Drawing.Size(700, 170)
$txtLog.BackColor       = $logBg
$txtLog.ForeColor       = [System.Drawing.Color]::FromArgb(0, 230, 118)
$txtLog.Font            = $fontLog
$txtLog.ReadOnly        = $true
$txtLog.BorderStyle     = "None"
$rightLowerPanel.Controls.Add($txtLog)

# ── REALTIME LOGGING WRAPPER ───────────────────────────────────────────────
function Write-Log ($message, $type = "INFO") {
    $time = Get-Date -Format "HH:mm:ss"
    $logLine = "[$time] [$type] $message`r`n"
    $txtLog.AppendText($logLine)
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

Write-Log "GOAT Engine Premium Edition initialized successfully." "SYSTEM"
Write-Log "System structure layout compiled to horizontal canvas." "INFO"

# ── TWEAKS DEFINITIONS ─────────────────────────────────────────────────────
$script:Tasks = [ordered]@{
    "Disable Windows Telemetry & Data Collection"  = {
        Write-Log "Injecting Telemetry Restriction Policies..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Disable Cortana & Bing Search in Start Menu"   = {
        Write-Log "Purging WebSearch parameters from Explorer..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Optimize Network Settings for Low Latency"    = {
        Write-Log "Applying Global Network Throttling Index modifications..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Disable Xbox Game DVR & Game Bar"             = {
        Write-Log "Terminating Xbox game capturing framework..."
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Enable Ultimate Performance Power Plan"       = {
        Write-Log "Deploying Ultimate Performance Scheme Core..."
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    }
    "Optimize Memory & Disable Hibernation"        = {
        Write-Log "Flushing hiberfil.sys storage components..."
        powercfg -h off -ErrorAction SilentlyContinue
    }
    "Disable Unnecessary Visual Effects"           = {
        Write-Log "Minimizing DWM window metrics response scale..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](158,30,7,128,18,0,0,0)) -Force -ErrorAction SilentlyContinue
    }
    "Speed Up Menu & Mouse Hover Display Time"     = {
        Write-Log "Calibrating Hover response buffer to 0ms..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force -ErrorAction SilentlyContinue
    }
    "Disable Background Apps Framework"            = {
        Write-Log "Enforcing Background App Sync suspension globally..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue
    }
    "Clean Windows Updates & System Junk Files"    = {
        Write-Log "Cleaning temporary repositories & clearing Windows EventLogs..."
        @("$env:USERPROFILE\AppData\Local\Temp\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*") | ForEach-Object {
            Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# ── GENERATE DISPLAY LABELS (โชว์หัวข้อแบบไม่มี Checkbox) ──────────────────────
$script:TextLabels = @{}
$chX = 20
$chY = 45
$colCount = 0

foreach ($taskName in $script:Tasks.Keys) {
    # ใช้กล่อง Panel เล็กเป็นจุดแสดงสถานะด้านหน้าข้อความ
    $indicatorDot = New-Object DBPanel
    $indicatorDot.Size = New-Object System.Drawing.Size(8, 8)
    $indicatorDot.Location = New-Object System.Drawing.Point($chX, $chY + 6)
    $indicatorDot.BackColor = $cPending
    $rightUpperPanel.Controls.Add($indicatorDot)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $taskName
    $lbl.Font      = $fontSub
    $lbl.ForeColor = $cPending # เริ่มต้นให้เป็นสีเทาเพื่อรอทำ
    $lbl.Size      = New-Object System.Drawing.Size(320, 25)
    $lbl.Location  = New-Object System.Drawing.Point($chX + 15, $chY)
    $rightUpperPanel.Controls.Add($lbl)
    
    $script:TextLabels[$taskName] = @{ Label = $lbl; Dot = $indicatorDot }
    
    $colCount++
    if ($colCount -eq 2) {
        $chX = 20
        $chY += 55
        $colCount = 0
    } else {
        $chX = 370
    }
}

# ── PIPELINE ENGINE WORKER ──────────────────────────────────────────────────
$script:IsRunning = $false

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    
    $btnRestart.Visible  = $false
    $lblHint.Text        = "GOAT Tuning Modules in deployment..."
    $txtLog.Clear()
    Write-Log "Executing performance system pipeline..." "START"

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 500
    
    $timer.Add_Tick({
        if ($script:RunIndex -ge $script:TotalTasks) {
            $timer.Stop()
            $script:ProgressPct = 100
            $progressBarPanel.Invalidate()
            $lblHint.Text = "Optimization Completed Perfectly!"
            $lblCount.Text = "Tweak Engine Status: Done"
            Write-Log "Re-aligning operating kernel completes. System optimized!" "SUCCESS"
            $btnRestart.Visible = $true
            $script:IsRunning = $false
            return
        }
        
        $taskName = $script:TaskKeyList[$script:RunIndex]
        
        # อัปเดตสถานะสีข้อความฝั่ง Optimizations List แบบ Real-time
        $script:TextLabels[$taskName].Label.ForeColor = $cWhite
        $script:TextLabels[$taskName].Dot.BackColor = $cAccent
        $lblCount.Text = "Active: Tweak $(([math]::Min($script:RunIndex + 1, $script:TotalTasks))) / $script:TotalTasks"
        
        # คำนวณเปอร์เซ็นต์ปัจจุบันของหลอดโหลด
        $script:ProgressPct = [math]::Round(($script:RunIndex / $script:TotalTasks) * 100)
        $progressBarPanel.Invalidate()
        
        Write-Log "Optimizing Target -> $taskName" "RUN"
        $fn = $script:Tasks[$taskName]
        try { & $fn } catch { Write-Log "Failure adjusting parameters." "ERROR" }
        
        # ปรับสถานะข้อความเมื่อรันตัวนั้นเสร็จสิ้น
        $script:TextLabels[$taskName].Label.ForeColor = $cMuted
        $script:TextLabels[$taskName].Dot.BackColor = $cAccentDim
        
        $script:RunIndex++
    })
    
    $timer.Start()
})

$btnRestart.Add_Click({
    Write-Log "Sending hardware safe reset code..." "SYSTEM"
    shutdown /r /t 5 /c "GOAT Engine completed configuration tasks. Restarting..."
})

$form.ShowDialog() | Out-Null
