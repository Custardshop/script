# Converted from GOAT_tweaks.bat
# NOTE: Original BAT preserved below as comments only.
# @echo off
# :: ============================================================
# :: GOAT - GREATEST OF ALL TWEAKS v4.0 + AllT v5.3 MERGED
# :: Run as Administrator
# :: ============================================================
# net session >nul 2>&1
# if %errorlevel% neq 0 (
#     echo [ERROR] Please run as Administrator.
#     pause
#     exit /b
# )
# 
# echo [GOAT] Starting optimizations...
# echo.
# 
# :: ── 01. KERNEL AND HPET ─────────────────────────────────────
# echo [01] Kernel and HPET...
# bcdedit /set useplatformclock no >nul 2>&1
# bcdedit /set useplatformtick yes >nul 2>&1
# bcdedit /set disabledynamictick yes >nul 2>&1
# bcdedit /set tscsyncpolicy Enhanced >nul 2>&1
# bcdedit /set nx OptOut >nul 2>&1
# bcdedit /set synthetictimers yes >nul 2>&1
# bcdedit /set nospeculationcontrol 1 >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
# 
# :: ── 02. TIMER RESOLUTION ────────────────────────────────────
# echo [02] Timer Resolution...
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul 2>&1
# 
# :: ── 03. PROCESS PRIORITY ────────────────────────────────────
# echo [03] Process Priority...
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 42 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d 33554432 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v AdditionalCriticalWorkerThreads /t REG_DWORD /d 2 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1
# :: [AllT] Game Tasks extra
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
# :: [AllT] Power throttling attribute unlock
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f2c1-98bb-455b-9e09-ae4c1e16cb45" /v Attributes /t REG_DWORD /d 2 /f >nul 2>&1
# 
# :: ── 04. IRQ MSI MODE ────────────────────────────────────────
# echo [04] IRQ MSI Mode...
# powershell -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI' -EA SilentlyContinue | ForEach-Object { $p = ($_.PSPath + '\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties'); if (Test-Path $p) { Set-ItemProperty -Path $p -Name MSISupported -Value 1 -Type DWord -Force } }" >nul 2>&1
# 
# :: ── 05. MEMORY MANAGEMENT ───────────────────────────────────
# echo [05] Memory Management...
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SystemCacheDirtyPageThreshold /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
# powercfg -h off >nul 2>&1
# taskkill /f /im OneDrive.exe >nul 2>&1
# reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >nul 2>&1
# 
# :: ── 06. STORAGE OPTIMIZATIONS ───────────────────────────────
# echo [06] Storage Optimizations...
# fsutil behavior set disable8dot3 1 >nul 2>&1
# fsutil behavior set disablelastaccess 1 >nul 2>&1
# fsutil behavior set disabledeletenotify 0 >nul 2>&1
# powershell -Command "Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter } | ForEach-Object { Optimize-Volume -DriveLetter $_.DriveLetter -ReTrim -EA SilentlyContinue }" >nul 2>&1
# 
# :: ── 07. INPUT AND USB ───────────────────────────────────────
# echo [07] Input and USB...
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 16 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 16 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v IdleEnable /t REG_DWORD /d 0 /f >nul 2>&1
# :: [AllT] Extra mouse/keyboard
# reg add "HKCU\Control Panel\Mouse" /v MouseHoverTime /t REG_SZ /d 0 /f >nul 2>&1
# :: [AllT] Disable accessibility hotkeys
# reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f >nul 2>&1
# reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d 58 /f >nul 2>&1
# reg add "HKCU\Control Panel\Accessibility\MouseKeys" /v Flags /t REG_SZ /d 0 /f >nul 2>&1
# 
# :: ── 08. NAGLE ALGORITHM ─────────────────────────────────────
# echo [08] Nagle Algorithm...
# powershell -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name TcpAckFrequency -Value 1 -Type DWord -Force -EA SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name TCPNoDelay -Value 1 -Type DWord -Force -EA SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name TcpDelAckTicks -Value 0 -Type DWord -Force -EA SilentlyContinue }" >nul 2>&1
# 
# :: ── 09. VISUAL EFFECTS ──────────────────────────────────────
# echo [09] Visual Effects...
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
# reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
# reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
# :: [AllT] Extra visual tweaks
# reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul 2>&1
# reg add "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d 0 /f >nul 2>&1
# 
# :: ── 10. GAME BAR AND DVR ────────────────────────────────────
# echo [10] Game Bar and DVR...
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
# reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKCU\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableXamlStartMenu /t REG_DWORD /d 0 /f >nul 2>&1
# :: Disable Game Mode
# reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\GameBar" /v GamePanelStartupTipIndex /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\DirectX\GraphicsSettings" /v HwSchMode /t REG_DWORD /d 1 /f
# 
# :: ── 11. PROCESSOR POWER ─────────────────────────────────────
# echo [11] Processor Power...
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
# powercfg /setactive SCHEME_CURRENT >nul 2>&1
# powercfg /hibernate off >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1
# 
# :: ── 12. CPU CORE PARKING ────────────────────────────────────
# echo [12] CPU Core Parking...
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMin /t REG_DWORD /d 0 /f >nul 2>&1
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 >nul 2>&1
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 >nul 2>&1
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR HETEROCLASS1INITIALPERF 100 >nul 2>&1
# powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR HETEROCLASS0FLOORPERF 100 >nul 2>&1
# powercfg /setactive SCHEME_CURRENT >nul 2>&1
# 
# :: ── 13. GPU AND DISPLAY ─────────────────────────────────────
# echo [13] GPU and Display...
# :: HAGS ปิด (ค่า 2 = ปิด, 1 = เปิด)
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrLevel /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 60 /f >nul 2>&1
# 
# :: ── 14. AUDIO LATENCY ───────────────────────────────────────
# echo [14] Audio Latency...
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v Affinity /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Background Only" /t REG_SZ /d False /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v Priority /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1
# 
# :: ── 15. NETWORK AND DNS ─────────────────────────────────────
# echo [15] Network and DNS...
# :: TCP Global
# netsh int tcp set global rss=enabled >nul 2>&1
# netsh int tcp set global autotuninglevel=normal >nul 2>&1
# netsh int tcp set global timestamps=disabled >nul 2>&1
# netsh int tcp set global chimney=disabled >nul 2>&1
# :: [AllT] TCP extras
# netsh int tcp set global rsc=disabled >nul 2>&1
# netsh int tcp set heuristics disabled >nul 2>&1
# netsh int tcp set global ecncapability=enabled >nul 2>&1
# netsh int tcp set global fastopen=enabled >nul 2>&1
# :: [AllT] UDP
# netsh int udp set global uro=disabled >nul 2>&1
# :: [AllT] Congestion provider CUBIC
# netsh int tcp set supplemental template=custom congestionprovider=cubic >nul 2>&1
# netsh int tcp set supplemental template=custom icw=10 >nul 2>&1
# netsh int tcp set supplemental template=custom initialrto=750 >nul 2>&1
# :: TCP Registry
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f >nul 2>&1
# :: [AllT] TCP Registry extras
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUDiscovery /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableRSS /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPChimney /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f >nul 2>&1
# :: [AllT] UDP / AFD
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v FastSendDatagramThreshold /t REG_DWORD /d 65536 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultReceiveWindow /t REG_DWORD /d 16384 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultSendWindow /t REG_DWORD /d 16384 /f >nul 2>&1
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v FastCopyReceiveThreshold /t REG_DWORD /d 1536 /f >nul 2>&1
# :: [AllT] QoS
# reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_SZ /d 1 /f >nul 2>&1
# :: [AllT] DNS Multicast off + NetBIOS disable
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >nul 2>&1
# powershell -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name NetbiosOptions -Value 2 -EA SilentlyContinue }" >nul 2>&1
# :: [AllT] NIC - Disable LSO + Interrupt Moderation
# powershell -Command "Get-NetAdapter -Physical | Where-Object { $_.Status -ne 'Not Present' } | ForEach-Object { Disable-NetAdapterLso -Name $_.Name -EA SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword '*InterruptModeration' -RegistryValue 0 -EA SilentlyContinue }" >nul 2>&1
# :: DNS + flush
# powershell -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Physical } | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ('1.1.1.1','8.8.8.8') -EA SilentlyContinue; Disable-NetAdapterPowerManagement -Name $_.Name -EA SilentlyContinue }" >nul 2>&1
# ipconfig /flushdns >nul 2>&1
# netsh winsock reset >nul 2>&1
# netsh int ip reset >nul 2>&1
# 
# :: ── 16. PRIVACY AND TELEMETRY ───────────────────────────────
# echo [16] Privacy and Telemetry...
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUPowerManagement /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f >nul 2>&1
# 
# :: ── 17. WINDOWS SERVICES ────────────────────────────────────
# echo [17] Windows Services...
# for %%s in (DiagTrack WSearch MapsBroker XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc Fax RetailDemo RemoteRegistry WerSvc) do (
#     sc stop %%s >nul 2>&1
#     sc config %%s start= disabled >nul 2>&1
# )
# for %%s in (Audiosrv AudioEndpointBuilder Dhcp NlaSvc Netman WlanSvc RpcSs EventLog PlugPlay LanmanWorkstation LanmanServer) do (
#     sc config %%s start= auto >nul 2>&1
#     sc start %%s >nul 2>&1
# )
# 
# :: ── 18. JUNK AND LOG CLEANUP ────────────────────────────────
# echo [18] Junk and Log Cleanup...
# rd /s /q "%TEMP%" >nul 2>&1
# rd /s /q "C:\Windows\Temp" >nul 2>&1
# rd /s /q "C:\Windows\Prefetch" >nul 2>&1
# rd /s /q "%WINDIR%\SoftwareDistribution\Download" >nul 2>&1
# net stop wuauserv >nul 2>&1
# net stop UsoSvc >nul 2>&1
# rd /s /q "C:\Windows\SoftwareDistribution" >nul 2>&1
# net start wuauserv >nul 2>&1
# for /f "tokens=*" %%L in ('wevtutil.exe el') do wevtutil.exe cl "%%L" >nul 2>&1
# :: [AllT] Clear Recycle Bin
# powershell -Command "Clear-RecycleBin -Force -EA SilentlyContinue" >nul 2>&1
# 
# :: ── 19. PER-PROCESS GAME PRIORITY (IFEO) [AllT] ─────────────
# echo [19] Per-Process Game Priority...
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cs2.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cs2.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\r5apex.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\r5apex.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RainbowSix.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RainbowSix.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Overwatch.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Overwatch.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TslGame.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TslGame.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\EscapeFromTarkov.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\EscapeFromTarkov.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RocketLeague.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RocketLeague.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cod.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cod.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\helldivers2.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\helldivers2.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discovery.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discovery.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\deadlock.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\deadlock.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\XDefiant.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
# reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\XDefiant.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
# 
# :: ── DONE ────────────────────────────────────────────────────
# echo.
# echo [GOAT] All tweaks applied. Restart your PC to finalize system-level changes.
# pause


# --- System.ini / Win.ini compatibility block ---
$systemIni = Join-Path $env:windir 'system.ini'
$winIni = Join-Path $env:windir 'win.ini'
$ini = @"
; for 16-bit app support
[386Enh]
MinTimeSlice=1
AvgTimeSlice=1
MaxTimeSlice=1
WinTimeSlice=1,1
NetAsyncTimeout=0
SyncTimeDivisor=1
TimeWindowMinutes=0
Latency=1
SampleRate=1
UseHWTimeStamp=1
Auto-Detect-CPU=TRUE
CpuSnooze=0
MaxBiosPipes=128
MinBiosPipes=128
DoubleBuffer=0
Chunksize=5000000
LoadTop=0
SystemReg=0
FastBlt=1

[drivers]
wave=mmdrv.dll
timer=timer.drv

[mci]
mciwave=mmsystem.dll

[timer]
TimeSliceUpdateTickCount=1

[NonWindowsApp]
MouseExclusive=1
"@
Copy-Item $systemIni "$systemIni.backup" -Force -ErrorAction SilentlyContinue
Copy-Item $winIni "$winIni.backup" -Force -ErrorAction SilentlyContinue
Add-Content $systemIni "`r`n$ini"
Add-Content $winIni "`r`n$ini"
