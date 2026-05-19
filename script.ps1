<#
    CUSTARD PREMIER OPTIMIZER v15.0 - PowerShell Edition
    Inspired by Chris Titus Tech Optimization Style.
#>

# --- [ 1. ADMIN PRIVILEGE CHECK ] ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  [!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor Red
    Write-Host "  -------------------------------------------------" -ForegroundColor Red
    Write-Host "  Please restart PowerShell as Administrator." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "CUSTARD PREMIER OPTIMIZER v15.0 - POWERSHELL"
Clear-Host

# ตั้งค่า Path ของไฟล์พลังงาน
$PowPath = Join-Path $PSScriptRoot "Custard.pow"

# --- [ FUNCTIONS ] ---
function Optimize-Kernel {
    Write-Host " -> Optimizing Kernel Settings..." -ForegroundColor Cyan
    bcdedit /set useplatformclock no | Out-Null
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set tscsyncpolicy Enhanced | Out-Null
    bcdedit /set nx OptOut | Out-Null
}

function Optimize-Priority {
    Write-Host " -> Optimizing Process & GPU Priorities..." -ForegroundColor Cyan
    $PriorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $SystemProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $GamesTaskPath = "$SystemProfilePath\Tasks\Games"

    Set-ItemProperty -Path $PriorityPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
    Set-ItemProperty -Path $PriorityPath -Name "ConvertibleSlateMode" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force
    Set-ItemProperty -Path $SystemProfilePath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
    
    if (-not (Test-Path $GamesTaskPath)) { New-Item -Path $GamesTaskPath -Force | Out-Null }
    Set-ItemProperty -Path $GamesTaskPath -Name "GPU Priority" -Value 8 -Type DWord -Force
    Set-ItemProperty -Path $GamesTaskPath -Name "Priority" -Value 6 -Type DWord -Force
    Set-ItemProperty -Path $GamesTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force
}

function Optimize-Memory {
    Write-Host " -> Tweaking Memory Management..." -ForegroundColor Cyan
    $MemoryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $PrefetchPath = "$MemoryPath\PrefetchParameters"

    Set-ItemProperty -Path $MemoryPath -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageThreshold" -Value 15 -Type DWord -Force
    Set-ItemProperty -Path $MemoryPath -Name "CcTotalDirtyPages" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageTarget" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force
    Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Processor" -Name "Cstates" -Value 0 -Type DWord -Force
}

function Optimize-Input {
    Write-Host " -> Tuning Input Response & Power Throttling..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force
    
    $PowerThrottlePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $PowerThrottlePath)) { New-Item -Path $PowerThrottlePath -Force | Out-Null }
    Set-ItemProperty -Path $PowerThrottlePath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed2" -Value "9000" -Type String -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "TimeToMaximumSpeed2" -Value "9000" -Type String -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DXGKrnl" -Name "MonitorLatencyTolerance" -Value 0 -Type DWord -Force
}

function Install-CustardPowerPlan {
    Write-Host " -> Importing Custard Power Plan..." -ForegroundColor Cyan
    $Guid = "4e2cd77e-229e-484e-b077-c63e8b092ec8"

    if (Test-Path $PowPath) {
        powercfg /delete $Guid 2>$null
        powercfg /import $PowPath $Guid | Out-Null
        powercfg /setactive $Guid | Out-Null
        Write-Host " [SUCCESS] Custard Power Plan Applied." -ForegroundColor Green
    } else {
        Write-Host " [!] ERROR: Custard.pow missing." -ForegroundColor Red
    }
}

function Optimize-Network {
    Write-Host " -> Optimizing Network & DNS..." -ForegroundColor Cyan
    netsh int tcp set global rss=enabled | Out-Null
    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global timestamps=disabled | Out-Null
    Clear-DnsClientCache | Out-Null
    netsh winsock reset | Out-Null
}

# --- [ 2. RUNNING TWEAKS ] ---
$Tasks = @(
    @{ Name = "Kernel Optimization"; Func = { Optimize-Kernel } },
    @{ Name = "Priority & Profiles Tweak"; Func = { Optimize-Priority } },
    @{ Name = "Memory Management Tweak"; Func = { Optimize-Memory } },
    @{ Name = "Input & Latency Optimization"; Func = { Optimize-Input } },
    @{ Name = "Custard Power Plan Injection"; Func = { Install-CustardPowerPlan } },
    @{ Name = "Network Tweaks & Reset"; Func = { Optimize-Network } }
)

Write-Host "==========================================================================================" -ForegroundColor Magenta
Write-Host "                      DEPLOYING CUSTARD PREMIER CONFIGURATION                             " -ForegroundColor White -BackgroundColor DarkMagenta
Write-Host "==========================================================================================" -ForegroundColor Magenta
Write-Host ""

for ($i = 0; $i -lt $Tasks.Count; $i++) {
    $Percent = [math]::Round((($i + 1) / $Tasks.Count) * 100)
    Write-Progress -Activity "Applying Tweaks" -Status "Executing: $($Tasks[$i].Name)" -PercentComplete $Percent
    & $Tasks[$i].Func
    Start-Sleep -Milliseconds 200
}

# --- [ 3. FINALIZATION ] ---
Clear-Host
Write-Host ""
Write-Host "__________________________________________________________________________________________" -ForegroundColor Green
Write-Host ""
Write-Host " [ SUCCESS ] ALL TWEAKS AND CUSTARD POWER PLAN APPLIED SUCCESSFULLY!" -ForegroundColor Green
Write-Host " [ ! ] PLEASE RESTART YOUR PC NOW TO APPLY CHANGES." -ForegroundColor Yellow
Write-Host "__________________________________________________________________________________________" -ForegroundColor Green
Write-Host ""

$Choice = Read-Host "Do you want to restart your PC now? (Y/N)"
if ($Choice -eq "Y" -or $Choice -eq "y") {
    Restart-Computer
}
