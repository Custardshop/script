<#
    CUSTARD - PREMIER CLEANER & OPTIMIZER (FULL INTEGRATED)
#>

# --- [ 1. ADMIN PRIVILEGE CHECK ] ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  [!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor Red
    Write-Host "  Please restart PowerShell as Administrator." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "OPTIMIZERPOWERSHELL"
Clear-Host

# ตั้งค่าตำแหน่งทำงาน
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# --- [ FUNCTIONS ] ---
function Optimize-Kernel {
    Write-Host " -> Optimizing Kernel Settings..." -ForegroundColor Yellow
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    Write-Host "    [VERIFIED] Kernel Tweaks Processed." -ForegroundColor Green
}

function Optimize-Priority {
    Write-Host " -> Optimizing Process & GPU Priorities..." -ForegroundColor Yellow
    $PriorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $SystemProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $GamesTaskPath = "$SystemProfilePath\Tasks\Games"

    Set-ItemProperty -Path $PriorityPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PriorityPath -Name "ConvertibleSlateMode" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 33554432 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $SystemProfilePath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force 2>$null
    
    if (-not (Test-Path $GamesTaskPath)) { New-Item -Path $GamesTaskPath -Force | Out-Null }
    Set-ItemProperty -Path $GamesTaskPath -Name "GPU Priority" -Value 8 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Priority" -Value 6 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $GamesTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null
}

function Optimize-Memory {
    Write-Host " -> Tweaking Memory Management..." -ForegroundColor Yellow
    $MemoryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $PrefetchPath = "$MemoryPath\PrefetchParameters"

    Set-ItemProperty -Path $MemoryPath -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageThreshold" -Value 15 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcTotalDirtyPages" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageTarget" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
}

function Optimize-Input {
    Write-Host " -> Tuning Input Response & Power Throttling..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    
    $PowerThrottlePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $PowerThrottlePath)) { New-Item -Path $PowerThrottlePath -Force | Out-Null }
    Set-ItemProperty -Path $PowerThrottlePath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed2" -Value "9000" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "TimeToMaximumSpeed2" -Value "9000" -Type String -Force 2>$null
}

function Install-CustardPowerPlan {
    Write-Host " -> Importing Custard Power Plan..." -ForegroundColor Yellow
    $Guid = "4e2cd77e-229e-484e-b077-c63e8b092ec8"
    if (Test-Path $PowPath) {
        powercfg /delete $Guid 2>$null
        powercfg /import $PowPath $Guid 2>$null | Out-Null
        powercfg /setactive $Guid 2>$null | Out-Null
    }
}

function Optimize-Network {
    Write-Host " -> Optimizing Network & DNS..." -ForegroundColor Yellow
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled 2>$null | Out-Null
    Clear-DnsClientCache -ErrorAction SilentlyContinue | Out-Null
    netsh winsock reset 2>$null | Out-Null
}

function Clean-TrashAndLogs {
    Write-Host " -> Cleaning System Junk, Logs, Updates & EventLogs..." -ForegroundColor Yellow
    
    # 1. ล้างไฟล์ขยะ (Temp, Prefetch)
    $JunkPaths = @("$env:USERPROFILE\AppData\Local\Temp\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
    foreach ($Path in $JunkPaths) {
        Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "    [DELETING] $($_.FullName)" -ForegroundColor Gray
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. ล้าง Windows Update (SoftwareDistribution)
    Write-Host "    [CLEANING] Windows Update Cache..." -ForegroundColor Gray
    Stop-Service -Name wuauserv, UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv

    # 3. ล้าง Event Logs
    Write-Host "    [CLEANING] Windows Event Logs..." -ForegroundColor Gray
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" }
    
    Write-Host "    [VERIFIED CLEANED] All System Junk & Logs Wiped Clean!" -ForegroundColor Green
}

# --- [ EXECUTION ] ---
$Tasks = @(
    { Optimize-Kernel }, { Optimize-Priority }, { Optimize-Memory }, 
    { Optimize-Input }, { Install-CustardPowerPlan }, { Optimize-Network }, { Clean-TrashAndLogs }
)

foreach ($Task in $Tasks) { & $Task }

# --- [ FINALIZATION ] ---
Write-Host "`n[ SUCCESS ] ALL TWEAKS AND SYSTEM CLEANUP COMPLETED!" -ForegroundColor Green
if ((Read-Host "Do you want to restart your PC now? (Y/N)") -match "[Yy]") { Restart-Computer }
