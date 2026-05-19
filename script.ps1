<#
    CUSTARD - BUNNY OVERLOAD (FULL STRUCTURE VERSION)
#>

# --- [ 1. ADMIN PRIVILEGE CHECK ] ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  [!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor White
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "CUSTARD BUNNY OPTIMIZER"
Clear-Host

# กระต่ายประกอบร่างส่วนหัว
Write-Host "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) " -ForegroundColor White
Write-Host "  ---DEPLOYING CUSTARD PREMIER CONFIGURATION---" -ForegroundColor White
Write-Host "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) " -ForegroundColor White
Write-Host ""

$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# --- [ FUNCTIONS (คงโครงสร้างเดิมแบบละเอียด) ] ---
function Optimize-Kernel {
    Write-Host " -> Optimizing Kernel Settings..." -ForegroundColor White
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    Write-Host "    [VERIFIED] Kernel Tweaks Processed." -ForegroundColor White
}

function Optimize-Priority {
    Write-Host " -> Optimizing Process & GPU Priorities..." -ForegroundColor White
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
    Write-Host "    [VERIFIED REGISTRY] Process Priorities Set." -ForegroundColor White
}

function Optimize-Memory {
    Write-Host " -> Tweaking Memory Management..." -ForegroundColor White
    $MemoryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $PrefetchPath = "$MemoryPath\PrefetchParameters"
    Set-ItemProperty -Path $MemoryPath -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageThreshold" -Value 15 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcTotalDirtyPages" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $MemoryPath -Name "CcDirtyPageTarget" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
    Write-Host "    [VERIFIED REGISTRY] Memory Tweaks Set." -ForegroundColor White
}

function Optimize-Input {
    Write-Host " -> Tuning Input Response..." -ForegroundColor White
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed2" -Value "9000" -Type String -Force 2>$null
    Write-Host "    [VERIFIED REGISTRY] Input Response Set." -ForegroundColor White
}

# เรียกใช้งานฟังก์ชันเดิม
Optimize-Kernel
Optimize-Priority
Optimize-Memory
Optimize-Input

# --- [ FINALIZATION ] ---
Write-Host ""
Write-Host "--- SUCCESS! ALL TWEAKS APPLIED SUCCESSFULLY ---" -ForegroundColor White
Write-Host "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) " -ForegroundColor White
Write-Host "  ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) " -ForegroundColor White
Write-Host "  c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(") " -ForegroundColor White

$Choice = Read-Host "Do you want to restart your PC now? (Y/N)"
if ($Choice -eq "Y" -or $Choice -eq "y") { Restart-Computer }
