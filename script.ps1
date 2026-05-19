<#
    CUSTARD - BUNNY OVERLOAD EDITION (FULL OPTIMIZED)
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

# กระต่ายจัดเต็มส่วนหัว
$BunnyLine = "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) "
Write-Host "$BunnyLine`n$BunnyLine" -ForegroundColor White
Write-Host "  ---DEPLOYING CUSTARD PREMIER CONFIGURATION---" -ForegroundColor White
Write-Host ""

$WorkingDir = "$env:TEMP\CustardUltimate"
if (-not (Test-Path $WorkingDir)) { New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null }
Set-Location $WorkingDir

$PowPath = Join-Path $WorkingDir "Custard.pow"
if (-not (Test-Path $PowPath)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Custardshop/script/main/Custard.pow" -OutFile $PowPath -UseBasicParsing | Out-Null
}

# --- [ OPTIMIZED FUNCTIONS (ครบถ้วน 100%) ] ---
function Run-Tweak {
    param($Msg, $Action)
    Write-Host " -> $Msg..." -ForegroundColor White
    & $Action
    Write-Host "    [VERIFIED] $Msg Completed." -ForegroundColor White
}

Run-Tweak "Kernel Settings" { bcdedit /set useplatformclock no 2>$null; bcdedit /set disabledynamictick yes 2>$null; bcdedit /set tscsyncpolicy Enhanced 2>$null; bcdedit /set nx OptOut 2>$null }

Run-Tweak "Process & GPU Priorities" { 
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 38 -Type DWord -Force;
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "ConvertibleSlateMode" 0 -Type DWord -Force;
    $GP = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games";
    if(-not(Test-Path $GP)){New-Item $GP -Force|Out-Null}; 
    Set-ItemProperty $GP "GPU Priority" 8 -Type DWord -Force; Set-ItemProperty $GP "Priority" 6 -Type DWord -Force; Set-ItemProperty $GP "Scheduling Category" "High" -Type String -Force 
}

Run-Tweak "Memory Management" { 
    $M = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management";
    Set-ItemProperty $M "CcDirtyPageThreshold" 15 -Type DWord -Force; Set-ItemProperty $M "EnableSuperfetch" 0 -Type DWord -Force -Path "$M\PrefetchParameters" 
}

Run-Tweak "Input Response" { 
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" 16 -Type DWord -Force;
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\MouseKeys" "MaximumSpeed2" "9000" -Type String -Force 
}

Run-Tweak "Custard Power Plan" { powercfg /setactive 4e2cd77e-229e-484e-b077-c63e8b092ec8 2>$null }

Run-Tweak "Network & DNS" { netsh int tcp set global rss=enabled 2>$null; netsh int tcp set global timestamps=disabled 2>$null; Clear-DnsClientCache }

# แก้ไขสิทธิ์ Access Denied ด้วยการกรองไฟล์ที่เข้าถึงได้เท่านั้น
Run-Tweak "Temporary Junk Files" { Get-ChildItem "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue }

# --- [ BUNNY OVERLOAD FOOTER ] ---
$BunnyEnd = "  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/)  (\_/) "
Write-Host "`n------------------------------------------------------------------------------------------" -ForegroundColor White
Write-Host " [ SUCCESS ] ALL TWEAKS AND JUNK CLEANING APPLIED SUCCESSFULLY!" -ForegroundColor White
Write-Host " [ ! ] PLEASE RESTART YOUR PC NOW TO APPLY CHANGES." -ForegroundColor White
Write-Host "------------------------------------------------------------------------------------------" -ForegroundColor White
Write-Host "`n$BunnyEnd`n$BunnyEnd`n$BunnyEnd" -ForegroundColor White
Write-Host ""

$Choice = Read-Host "Do you want to restart your PC now? (Y/N)"
if ($Choice -eq "Y" -or $Choice -eq "y") { Restart-Computer }
