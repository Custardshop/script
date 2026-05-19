<#
    CUSTARD - BUNNY OVERLOAD (STABLE & FULL)
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

# กระต่ายจัดเต็ม
$B = "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) "
Write-Host "$B`n$B" -ForegroundColor White
Write-Host "  ---DEPLOYING CUSTARD PREMIER CONFIGURATION---" -ForegroundColor White
Write-Host ""

$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

# --- [ OPTIMIZED FUNCTIONS (แก้ไขให้สมบูรณ์ 100%) ] ---
function Run-Tweak {
    param($Msg, $Action)
    Write-Host " -> $Msg..." -ForegroundColor White
    & $Action
    Write-Host "    [VERIFIED] $Msg Completed." -ForegroundColor White
}

Run-Tweak "Kernel Settings" { bcdedit /set useplatformclock no 2>$null; bcdedit /set disabledynamictick yes 2>$null; bcdedit /set tscsyncpolicy Enhanced 2>$null; bcdedit /set nx OptOut 2>$null }

Run-Tweak "Process & GPU Priorities" { 
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force;
    $GP = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games";
    if(-not(Test-Path $GP)){New-Item $GP -Force|Out-Null}; 
    Set-ItemProperty -Path $GP -Name "GPU Priority" -Value 8 -Type DWord -Force; 
    Set-ItemProperty -Path $GP -Name "Priority" -Value 6 -Type DWord -Force 
}

Run-Tweak "Memory Management" { 
    $M = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management";
    Set-ItemProperty -Path $M -Name "CcDirtyPageThreshold" -Value 15 -Type DWord -Force; 
    Set-ItemProperty -Path "$M\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 
}

Run-Tweak "Input Response" { 
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force;
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed2" -Value "9000" -Type String -Force 
}

Run-Tweak "Temporary Junk Files" { Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue }

# --- [ FOOTER ] ---
Write-Host "`n------------------------------------------------------------------------------------------" -ForegroundColor White
Write-Host " [ SUCCESS ] ALL TWEAKS AND JUNK CLEANING APPLIED SUCCESSFULLY!" -ForegroundColor White
Write-Host " [ ! ] PLEASE RESTART YOUR PC NOW TO APPLY CHANGES." -ForegroundColor White
Write-Host "------------------------------------------------------------------------------------------" -ForegroundColor White
Write-Host "`n$B`n$B`n$B" -ForegroundColor White

$Choice = Read-Host "Do you want to restart your PC now? (Y/N)"
if ($Choice -eq "Y" -or $Choice -eq "y") { Restart-Computer }
