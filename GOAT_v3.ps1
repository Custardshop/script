#Requires -Version 5.1

<#
  GOAT — GREATEST OF ALL TWEAKS
  Premium Edition v4.0 · Onyx Crimson · Soft Luxury (Horizontal Edition)
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

# ── COLOR PALETTE (Onyx Crimson & Soft Luxury) ─────────────────────────────
$bgColor    = [System.Drawing.Color]::FromArgb(18, 18, 18)        # Dark Onyx
$cardBg     = [System.Drawing.Color]::FromArgb(28, 28, 30)        # Soft Dark Slate
$accentColor= [System.Drawing.Color]::FromArgb(186, 12, 47)       # Crimson Red
$textColor  = [System.Drawing.Color]::FromArgb(240, 240, 245)     # Soft Luxury Off-White
$mutedText  = [System.Drawing.Color]::FromArgb(150, 150, 160)     # Muted Gray
$logBg      = [System.Drawing.Color]::FromArgb(10, 10, 12)        # Deep Black for Logs

# ── MAIN FORM (HORIZONTAL LAYOUT) ──────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT — GREATEST OF ALL TWEAKS [Premium Edition v4.0]"
$form.Size            = New-Object System.Drawing.Size(1100, 650)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $bgColor
$form.ForeColor       = $textColor
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$fontSub   = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fontBold  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontLog   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)

# ── LEFT PANEL: SYSTEM INFO & CONTROLS ─────────────────────────────────────
$leftPanel = New-Object System.Windows.Forms.Panel
$leftPanel.Size     = New-Object System.Drawing.Size(320, 610)
$leftPanel.Location = New-Object System.Drawing.Point(10, 10)
$leftPanel.BackColor= $cardBg
$form.Controls.Add($leftPanel)

# Brand Header
$lblBrand = New-Object System.Windows.Forms.Label
$lblBrand.Text      = "G O A T"
$lblBrand.Font      = $fontTitle
$lblBrand.ForeColor = $accentColor
$lblBrand.Location  = New-Object System.Drawing.Point(20, 20)
$lblBrand.Size      = New-Object System.Drawing.Size(280, 35)
$leftPanel.Controls.Add($lblBrand)

$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text      = "Premium Edition v4.0 · Onyx Crimson"
$lblVersion.Font      = $fontSub
$lblVersion.ForeColor = $mutedText
$lblVersion.Location  = New-Object System.Drawing.Point(20, 55)
$lblVersion.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblVersion)

# Separator Line
$sep1 = New-Object System.Windows.Forms.Label
$sep1.BackColor = $accentColor
$sep1.Location  = New-Object System.Drawing.Point(20, 85)
$sep1.Size      = New-Object System.Drawing.Size(280, 2)
$leftPanel.Controls.Add($sep1)

# System Info Stats Group
$lblSysTitle = New-Object System.Windows.Forms.Label
$lblSysTitle.Text      = "SYSTEM INFORMATION"
$lblSysTitle.Font      = $fontBold
$lblSysTitle.ForeColor = $textColor
$lblSysTitle.Location  = New-Object System.Drawing.Point(20, 100)
$lblSysTitle.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblSysTitle)

$sysDetails = @(
    "OS: $OSName",
    "User: $UserName @ $PCName",
    "CPU: $CPU",
    "RAM Total: $RAMTotal GB",
    "RAM Free: $RAMFree MB ($RAMPct% Used)"
)

$yOffset = 125
foreach ($detail in $sysDetails) {
    $lblDetail = New-Object System.Windows.Forms.Label
    $lblDetail.Text      = $detail
    $lblDetail.Font      = $fontSub
    $lblDetail.ForeColor = $mutedText
    $lblDetail.Location  = New-Object System.Drawing.Point(20, $yOffset)
    $lblDetail.Size      = New-Object System.Drawing.Size(280, 22)
    $leftPanel.Controls.Add($lblDetail)
    $yOffset += 22
}

# Separator Line 2
$sep2 = New-Object System.Windows.Forms.Label
$sep2.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 55)
$sep2.Location  = New-Object System.Drawing.Point(20, 250)
$sep2.Size      = New-Object System.Drawing.Size(280, 1)
$leftPanel.Controls.Add($sep2)

# Action Controls Group
$lblControlTitle = New-Object System.Windows.Forms.Label
$lblControlTitle.Text      = "CONTROL PANEL"
$lblControlTitle.Font      = $fontBold
$lblControlTitle.ForeColor = $textColor
$lblControlTitle.Location  = New-Object System.Drawing.Point(20, 265)
$lblControlTitle.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblControlTitle)

# Progress Bar (จัดวางแยกส่วน ไม่ให้ทับซ้อน)
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 300)
$progressBar.Size     = New-Object System.Drawing.Size(280, 20)
$progressBar.Style    = "Blocks"
$leftPanel.Controls.Add($progressBar)

# Progress Status Labels
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text      = "Ready to optimize your system."
$lblHint.Font      = $fontSub
$lblHint.ForeColor = $mutedText
$lblHint.Location  = New-Object System.Drawing.Point(20, 330)
$lblHint.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblHint)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text      = "Selected Tasks: 0 / 0"
$lblCount.Font      = $fontSub
$lblCount.ForeColor = $accentColor
$lblCount.Location  = New-Object System.Drawing.Point(20, 350)
$lblCount.Size      = New-Object System.Drawing.Size(280, 20)
$leftPanel.Controls.Add($lblCount)

# Action Buttons
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text            = "RUN GOAT TWEAKS"
$btnRun.Font            = $fontBold
$btnRun.BackColor       = $accentColor
$btnRun.ForeColor       = $textColor
$btnRun.FlatStyle       = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Location        = New-Object System.Drawing.Point(20, 390)
$btnRun.Size            = New-Object System.Drawing.Size(280, 45)
$leftPanel.Controls.Add($btnRun)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text            = "RESTART COMPUTER"
$btnRestart.Font            = $fontBold
$btnRestart.BackColor       = [System.Drawing.Color]::FromArgb(45, 45, 48)
$btnRestart.ForeColor       = $textColor
$btnRestart.FlatStyle       = "Flat"
$btnRestart.FlatAppearance.BorderSize = 0
$btnRestart.Location        = New-Object System.Drawing.Point(20, 445)
$btnRestart.Size            = New-Object System.Drawing.Size(280, 35)
$btnRestart.Visible         = $false
$leftPanel.Controls.Add($btnRestart)


# ── RIGHT PANEL UPPER: TWEAKS SELECTION (SCROLLABLE) ──────────────────────
$rightUpperPanel = New-Object System.Windows.Forms.Panel
$rightUpperPanel.Size     = New-Object System.Drawing.Size(740, 360)
$rightUpperPanel.Location = New-Object System.Drawing.Point(340, 10)
$rightUpperPanel.BackColor= $cardBg
$rightUpperPanel.AutoScroll = $true
$form.Controls.Add($rightUpperPanel)

$lblTweakTitle = New-Object System.Windows.Forms.Label
$lblTweakTitle.Text      = "SELECT OPTIMIZATIONS"
$lblTweakTitle.Font      = $fontBold
$lblTweakTitle.ForeColor = $textColor
$lblTweakTitle.Location  = New-Object System.Drawing.Point(20, 15)
$lblTweakTitle.Size      = New-Object System.Drawing.Size(300, 20)
$rightUpperPanel.Controls.Add($lblTweakTitle)

# ── RIGHT PANEL LOWER: REALTIME LOG BOX ────────────────────────────────────
$rightLowerPanel = New-Object System.Windows.Forms.Panel
$rightLowerPanel.Size     = New-Object System.Drawing.Size(740, 240)
$rightLowerPanel.Location = New-Object System.Drawing.Point(340, 380)
$rightLowerPanel.BackColor= $cardBg
$form.Controls.Add($rightLowerPanel)

$lblLogTitle = New-Object System.Windows.Forms.Label
$lblLogTitle.Text      = "REALTIME EXECUTION LOG"
$lblLogTitle.Font      = $fontBold
$lblLogTitle.ForeColor = $textColor
$lblLogTitle.Location  = New-Object System.Drawing.Point(20, 10)
$lblLogTitle.Size      = New-Object System.Drawing.Size(300, 20)
$rightLowerPanel.Controls.Add($lblLogTitle)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location        = New-Object System.Drawing.Point(20, 35)
$txtLog.Size            = New-Object System.Drawing.Size(700, 185)
$txtLog.BackColor       = $logBg
$txtLog.ForeColor       = [System.Drawing.Color]::FromArgb(0, 230, 118) # Matrix Green
$txtLog.Font            = $fontLog
$txtLog.ReadOnly        = $true
$txtLog.BorderStyle     = "None"
$rightLowerPanel.Controls.Add($txtLog)


# ── LOGGING FUNCTION ───────────────────────────────────────────────────────
function Write-Log ($message, $type = "INFO") {
    $time = Get-Date -Format "HH:mm:ss"
    $logLine = "[$time] [$type] $message`r`n"
    $txtLog.AppendText($logLine)
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

Write-Log "GOAT Engine Premium Edition initialized successfully." "SYSTEM"
Write-Log "Ready to apply system tweaks." "INFO"


# ── TWEAKS DEFINITION & MAPPING ───────────────────────────────────────────
$script:Tasks = [ordered]@{
    "Disable Windows Telemetry & Data Collection"  = {
        Write-Log "Disabling Windows Telemetry services..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -ErrorAction SilentlyContinue
    }
    "Disable Cortana & Bing Search in Start Menu"   = {
        Write-Log "Removing Cortana and Bing Web Search from Start Menu..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Optimize Network Settings for Low Latency"    = {
        Write-Log "Applying Network Throttling and Latency Patches..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Disable Xbox Game DVR & Game Bar"             = {
        Write-Log "Disabling Xbox Live Background DVR Services..."
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force -ErrorAction SilentlyContinue
    }
    "Enable Ultimate Performance Power Plan"       = {
        Write-Log "Activating Windows Ultimate Performance Plan GUID..."
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    }
    "Optimize Memory & Disable Hibernation"        = {
        Write-Log "Disabling Hibernation to free up C:\ storage..."
        powercfg -h off -ErrorAction SilentlyContinue
    }
    "Disable Unnecessary Visual Effects"           = {
        Write-Log "Adjusting Visual Effects settings for pure performance..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](158,30,7,128,18,0,0,0)) -Force -ErrorAction SilentlyContinue
    }
    "Speed Up Menu & Mouse Hover Display Time"     = {
        Write-Log "Reducing MenuShowDelay to 0 ms..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force -ErrorAction SilentlyContinue
    }
    "Disable Background Apps Framework"            = {
        Write-Log "Stopping Universal App Background Sync..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue
    }
    "Clean Windows Updates & System Junk Files"    = {
        Write-Log "Executing Temporary Files and EventLogs Flush..."
        @("$env:USERPROFILE\AppData\Local\Temp\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*") | ForEach-Object {
            Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
    }
}

# ── DYNAMIC CHECKBOX GENERATION (2-COLUMN GRID TO PREVENT OVERLAP) ────────
$script:CheckBoxes = @{}
$chX = 20
$chY = 45
$colCount = 0

foreach ($taskName in $script:Tasks.Keys) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text     = $taskName
    $cb.Font     = $fontSub
    $cb.ForeColor= $textColor
    $cb.Size     = New-Object System.Drawing.Size(330, 45) # ขนาดกว้างพอดีสี่เหลี่ยม ไม่ตัดคำหาย
    $cb.Location = New-Object System.Drawing.Point($chX, $chY)
    $cb.Checked  = $true
    
    $cb.Add_CheckedChanged({
        $selected = ($script:CheckBoxes.Values | Where-Object { $_.Checked }).Count
        $lblCount.Text = "Selected Tasks: $selected / $($script:CheckBoxes.Count)"
    })
    
    $rightUpperPanel.Controls.Add($cb)
    $script:CheckBoxes[$taskName] = $cb
    
    # สลับคอลัมน์ซ้าย-ขวา เพื่อให้อยู่ในสัดส่วนสี่เหลี่ยมแนวนอนที่เหมาะสม
    $colCount++
    if ($colCount -eq 2) {
        $chX = 20
        $chY += 50
        $colCount = 0
    } else {
        $chX = 370
    }
}

$lblCount.Text = "Selected Tasks: $($script:CheckBoxes.Count) / $($script:CheckBoxes.Count)"

# ── ENGINE RUN LOGIC ───────────────────────────────────────────────────────
$script:IsRunning = $false

$btnRun.Add_Click({
    if ($script:IsRunning) { return }
    $script:IsRunning   = $true
    $script:RunIndex    = 0
    $script:DoneCount   = 0
    $script:TaskKeyList = @($script:Tasks.Keys)
    $script:TotalTasks  = $script:TaskKeyList.Count
    
    $btnRestart.Visible  = $false
    $lblHint.Text        = "GOAT Engine is working..."
    $txtLog.Clear()
    Write-Log "Starting GOAT Premium Optimization Suite..." "START"

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 400
    
    $timer.Add_Tick({
        if ($script:RunIndex -ge $script:TotalTasks) {
            $timer.Stop()
            $progressBar.Value = 100
            $lblHint.Text = "Optimization Completed!"
            Write-Log "All selected tweaks applied successfully! System Is Now GOATed." "SUCCESS"
            $btnRestart.Visible = $true
            $script:IsRunning = $false
            return
        }
        
        $taskName = $script:TaskKeyList[$script:RunIndex]
        $cb = $script:CheckBoxes[$taskName]
        
        if ($cb.Checked) {
            Write-Log "Executing: $taskName" "RUN"
            $fn = $script:Tasks[$taskName]
            try { & $fn } catch { Write-Log "Error executing $taskName" "ERROR" }
            $script:DoneCount++
        } else {
            Write-Log "Skipped: $taskName" "SKIP"
        }
        
        $script:RunIndex++
        $pct = [math]::Round(($script:RunIndex / $script:TotalTasks) * 100)
        $progressBar.Value = $pct
    })
    
    $timer.Start()
})

$btnRestart.Add_Click({
    Write-Log "Initiating system reboot..." "SYSTEM"
    shutdown /r /t 5 /c "GOAT Tweaks Applied. Rebooting in 5 seconds..."
})

$form.ShowDialog() | Out-Null
