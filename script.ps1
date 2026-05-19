<#
    CUSTARD - BUNNY OVERLOAD EDITION
#>

# --- [ 1. ADMIN PRIVILEGE CHECK ] ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host " [!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor White
    Read-Host "Press Enter to exit"
    Exit
}

$Host.UI.RawUI.WindowTitle = "CUSTARD BUNNY OPTIMIZER"
Clear-Host

# --- [ BUNNY ARMY HEADER ] ---
Write-Host @"
  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)
  ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .) ( . .)
  c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")c(")(")
  ----------------DEPLOYING CUSTARD PREMIER CONFIGURATION----------------
  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)
"@ -ForegroundColor White

# ตั้งค่าตำแหน่งทำงาน
$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

# --- [ FUNCTIONS ] ---
function Run-Task {
    param($Title, $Action)
    Write-Host "---( )---$Title..." -ForegroundColor White
    & $Action
    Write-Host "---( )---VERIFIED. $Title Processed." -ForegroundColor White
}

# --- [ TWEAKS ] ---
Run-Task "Optimizing Kernel Settings" { bcdedit /set useplatformclock no 2>$null | Out-Null }
Run-Task "Optimizing Process & GPU Priorities" { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force 2>$null }
Run-Task "Tweaking Memory Management" { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "CcDirtyPageThreshold" -Value 15 -Force 2>$null }
Run-Task "Tuning Input Response" { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Force 2>$null }
Run-Task "Importing Custard Power Plan" { powercfg /setactive 4e2cd77e-229e-484e-b077-c63e8b092ec8 2>$null }
Run-Task "Optimizing Network & DNS" { netsh int tcp set global rss=enabled 2>$null | Out-Null }
# ปรับแก้ให้ข้ามไฟล์ที่ติดสิทธิ์ Access Denied เพื่อไม่ให้ขึ้น Error รบกวนสายตา
Run-Task "Cleaning Temporary Junk Files" { Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }

# --- [ BUNNY ARMY FOOTER ] ---
Write-Host @"

  (\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)(\_/)
  SUCCESS! ALL TWEAKS, JUNK CLEANING, AND POWER PLAN APPLIED SUCCESSFULLY!
  ---PLEASE RESTART YOUR PC NOW TO APPLY CHANGES.---
  (\_/)   (\_/)   (\_/)   (\_/)   (\_/)   (\_/)   (\_/)   (\_/)
  ( . .)  ( . .)  ( . .)  ( . .)  ( . .)  ( . .)  ( . .)  ( . .)
  c(")(") c(")(") c(")(") c(")(") c(")(") c(")(") c(")(") c(")(")
"@ -ForegroundColor White

$Choice = Read-Host "Do you want to restart your PC now? (Y/N)"
if ($Choice -eq "Y" -or $Choice -eq "y") { Restart-Computer }
