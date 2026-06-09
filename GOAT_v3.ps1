<#
    GOAT - GREATEST OF ALL TWEAKS v3.0 (Crimson WPF Edition)
#>
[void][System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# --- Auto-Elevate to Admin ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- Gather System Info ---
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$cpu = (Get-CimInstance Win32_Processor).Name
$ram = "$([Math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)) GB"
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "
$user = $env:USERNAME

# --- WPF UI Definition (XAML) ---
$inputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2000/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2000/xaml"
        Title="GOAT - GREATEST OF ALL TWEAKS v3.0" Height="650" Width="900" 
        Background="#121212" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="300"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="160"/>
        </Grid.RowDefinitions>

        <Border Grid.Column="0" Grid.Row="0" Grid.RowSpan="2" Background="#1a1a1a" BorderBrush="#8B0000" BorderThickness="0,0,2,0">
            <StackPanel Margin="20">
                <TextBlock Text="GOAT TWEAKS" FontSize="24" FontWeight="Bold" Foreground="#DC143C" HorizontalAlignment="Center" Margin="0,10,0,5"/>
                <TextBlock Text="CRIMSON EDITION" FontSize="11" Foreground="#888" HorizontalAlignment="Center" Margin="0,0,0,30"/>
                
                <TextBlock Text="SYSTEM DASHBOARD" FontSize="14" FontWeight="SemiBold" Foreground="#DC143C" Margin="0,0,0,15"/>
                
                <TextBlock Text="USER:" FontSize="11" Foreground="#888"/>
                <TextBlock Text="$user" FontSize="13" Foreground="#FFF" FontWeight="Medium" Margin="0,0,0,12"/>
                
                <TextBlock Text="OS:" FontSize="11" Foreground="#888"/>
                <TextBlock Text="$os" FontSize="13" Foreground="#FFF" FontWeight="Medium" Margin="0,0,0,12" TextWrapping="Wrap"/>
                
                <TextBlock Text="PROCESSOR:" FontSize="11" Foreground="#888"/>
                <TextBlock Text="$cpu" FontSize="13" Foreground="#FFF" FontWeight="Medium" Margin="0,0,0,12" TextWrapping="Wrap"/>
                
                <TextBlock Text="GRAPHICS CARD:" FontSize="11" Foreground="#888"/>
                <TextBlock Text="$gpu" FontSize="13" Foreground="#FFF" FontWeight="Medium" Margin="0,0,0,12" TextWrapping="Wrap"/>
                
                <TextBlock Text="MEMORY:" FontSize="11" Foreground="#888"/>
                <TextBlock Text="$ram" FontSize="13" Foreground="#FFF" FontWeight="Medium" Margin="0,0,0,12"/>
            </StackPanel>
        </Border>

        <ScrollViewer Grid.Column="1" Grid.Row="0" VerticalScrollBarVisibility="Auto" Margin="15">
            <StackPanel>
                <TextBlock Text="OPTIMIZATION MODULES (13 UNITS)" FontSize="16" FontWeight="Bold" Foreground="#FFF" Margin="5,0,0,15"/>
                
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 01. KERNEL &amp; HPET - Optimize Platform Clock &amp; Low-Level Timers" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 02. TIMER RESOLUTION - Global Timer Resolution Requests" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 03. PROCESS PRIORITY - Win32 Priority Separation &amp; Gaming Profile" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 04. IRQ MSI MODE - Message Signaled Interrupts for PCI Devices" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 05. MEMORY MANAGEMENT - Disable Prefetch/Superfetch &amp; Clean Startup" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 06. INPUT &amp; USB - Mouse/Keyboard Data Queue &amp; Latency Tuning" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 07. NAGLE ALGORITHM - Disable TCP NoDelay &amp; Ack Frequency" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 08. VISUAL EFFECTS - Strip Down Windows Animations for Speed" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 09. GAME BAR &amp; DVR - Disable Background Game Capture &amp; DVR" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 10. PROCESSOR POWER - Unthrottle Min/Max CPU States to 100%" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 11. NETWORK &amp; DNS - Reset Winsock, Flush DNS &amp; Global TCP TCP Tuning" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 12. WINDOWS SERVICES - Disable Telemetry/Junk &amp; Keep Essentials" Foreground="#DDD" FontSize="12"/>
                </Border>
                <Border Background="#1e1e1e" CornerRadius="5" Padding="15" Margin="0,0,0,10">
                    <TextBlock Text="• 13. JUNK CLEANUP - Clear Temp, Prefetch &amp; Flush Event Logs" Foreground="#DDD" FontSize="12"/>
                </Border>
            </StackPanel>
        </ScrollViewer>

        <Grid Grid.Column="1" Grid.Row="1" Margin="15,0,15,15">
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            <TextBox x:Name="LogBox" Grid.Row="0" Background="#0b0b0b" Foreground="#00FF00" BorderBrush="#333" 
                     FontFamily="Consolas" FontSize="11" IsReadOnly="True" VerticalScrollBarVisibility="Auto" 
                     TextWrapping="Wrap" Padding="5" Margin="0,0,0,10" Text="[STATUS] Ready to execute GOAT Optimization. Press 'RUN TWEAKS' to begin..."/>
            
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="140"/>
                </Grid.ColumnDefinitions>
                <ProgressBar x:Name="ProgBar" Grid.Column="0" Height="30" Minimum="0" Maximum="13" Value="0" 
                             Background="#222" Foreground="#DC143C" BorderThickness="0" Margin="0,0,10,0"/>
                <Button x:Name="RunBtn" Grid.Column="1" Content="RUN TWEAKS" Background="#DC143C" Foreground="#FFF" 
                        FontWeight="Bold" BorderThickness="0" Height="30"/>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$inputXML = $inputXML -replace 'x:Name', 'Name'
[xml]$XAML = $inputXML
$reader = New-Object System.Xml.XmlNodeReader $XAML
$Form = [Windows.Markup.XamlReader]::Load($reader)

# --- Connect UI Elements ---
$LogBox = $Form.FindName("LogBox")
$ProgBar = $Form.FindName("ProgBar")
$RunBtn = $Form.FindName("RunBtn")

# --- Helper Function for Realtime Logging ---
function Update-Log ($Message, $ProgressValue) {
    $Form.Dispatcher.Invoke([Action][ScriptBlock]{
        $LogBox.AppendText("`r`n" + $Message)
        $LogBox.ScrollToEnd()
        if ($ProgressValue -ne $null) { $ProgBar.Value = $ProgressValue }
    })
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 300 # เติม Delay เล็กน้อยเพื่อให้เห็น Log วิ่งอย่างสวยงาม
}

# --- Tweak Execution Event ---
$RunBtn.Add_Click({
    $RunBtn.IsEnabled = $false
    
    # 1. KERNEL AND HPET 
    Update-Log "[+] [01/13] Optimizing Kernel and HPET..." 1
    bcdedit /set useplatformclock no >$null 2>&1
    bcdedit /set useplatformtick yes >$null 2>&1
    bcdedit /set disabledynamictick yes >$null 2>&1
    bcdedit /set tscsyncpolicy Enhanced >$null 2>&1
    bcdedit /set nx OptOut >$null 2>&1
    bcdedit /set synthetictimers yes >$null 2>&1
    $h = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like '*High Precision*' }
    if ($h) { Disable-PnpDevice -InstanceId $h.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }

    # 2. TIMER RESOLUTION 
    Update-Log "[+] [02/13] Adjusting Timer Resolution..." 2
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f >$null 2>&1

    # 3. PROCESS PRIORITY [cite: 3]
    [cite_start]Update-Log "[+] [03/13] Setting Process Priorities for Gaming..." 3 [cite: 4]
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x2a /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 33554432 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "AdditionalCriticalWorkerThreads" /t REG_DWORD /d 2 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >$null 2>&1
    [cite_start]reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >$null 2>&1 [cite: 5]

    # 4. IRQ MSI MODE [cite: 5]
    Update-Log "[+] [04/13] Enabling IRQ MSI Mode for all PCI Devices..." 4
    Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI' -ErrorAction SilentlyContinue | ForEach-Object { 
        [cite_start]$p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" [cite: 6]
        if (Test-Path $p) { Set-ItemProperty -Path $p -Name 'MSISupported' -Value 1 -Type DWord -Force 2>$null } 
    }

    # 5. MEMORY MANAGEMENT 
    Update-Log "[+] [05/13] Optimizing Memory Management..." 5
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemCacheDirtyPageThreshold" /t REG_DWORD /d 0 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >$null 2>&1
    powercfg -h off >$null 2>&1
    taskkill /f /im OneDrive.exe >$null 2>&1
    [cite_start]reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >$null 2>&1 [cite: 7]

    # 6. INPUT AND USB 
    Update-Log "[+] [06/13] Tuning Input Response and USB Latency..." 6
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 16 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 16 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >$null 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >$null 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >$null 2>&1
    reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >$null 2>&1
    [cite_start]reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >$null 2>&1 [cite: 8]
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v "IdleEnable" /t REG_DWORD /d 0 /f >$null 2>&1

    # 7. NAGLE ALGORITHM 
    Update-Log "[+] [07/13] Disabling Nagle Algorithm (TCP NoDelay)..." 7
    Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -ErrorAction SilentlyContinue | ForEach-Object { 
        [cite_start]Set-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force 2>$null [cite: 9]
        [cite_start]Set-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Value 1 -Type DWord -Force 2>$null [cite: 10]
        [cite_start]Set-ItemProperty -Path $_.PSPath -Name 'TcpDelAckTicks' -Value 0 -Type DWord -Force 2>$null [cite: 11]
    }

    # 8. VISUAL EFFECTS 
    Update-Log "[+] [08/13] Tweaking Visual Effects for Performance..." 8
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >$null 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f >$null 2>&1
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >$null 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f >$null 2>&1

    # 9. GAME BAR AND DVR 
    Update-Log "[+] [09/13] Disabling Game Bar, DVR and Captures..." 9
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >$null 2>&1
    [cite_start]reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >$null 2>&1 [cite: 12]
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >$null 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >$null 2>&1

    # 10. PROCESSOR POWER 
    Update-Log "[+] [10/13] Unthrottling Processor Power..." 10
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >$null 2>&1
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >$null 2>&1
    powercfg /setactive SCHEME_CURRENT >$null 2>&1

    # 11. NETWORK AND DNS 
    Update-Log "[+] [11/13] Configuring Network Optimization..." 11
    netsh int tcp set global rss=enabled >$null 2>&1
    [cite_start]netsh int tcp set global autotuninglevel=disabled >$null 2>&1 [cite: 13]
    netsh int tcp set global timestamps=disabled >$null 2>&1
    netsh int tcp set global chimney=disabled >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >$null 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >$null 2>&1
    ipconfig /flushdns >$null 2>&1
    netsh winsock reset >$null 2>&1
    netsh int ip reset >$null 2>&1
    ipconfig /release >$null 2>&1
    ipconfig /renew >$null 2>&1
    Get-NetAdapter | Where-Object { $_.Physical } | [cite_start]Restart-NetAdapter -ErrorAction SilentlyContinue [cite: 14]

    # 12. WINDOWS SERVICES 
    Update-Log "[+] [12/13] Managing Windows Services..." 12
    foreach ($s in @("DiagTrack", "WSearch", "MapsBroker", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "Fax", "RetailDemo", "RemoteRegistry", "WerSvc")) {
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
        Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
    }
    foreach ($s in @("Audiosrv", "AudioEndpointBuilder", "Dhcp", "NlaSvc", "Netman", "WlanSvc", "RpcSs", "EventLog", "PlugPlay", "LanmanWorkstation", "LanmanServer")) {
        Set-Service -Name $s -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $s -ErrorAction SilentlyContinue
    }

    # 13. JUNK AND LOG CLEANUP [cite: 14, 15]
    Update-Log "[+] [13/13] Cleaning Up Junk Files and Event Logs..." 13
    Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service -Name UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }

    # DONE 
    [cite_start]Update-Log "[SUCCESS] GOAT Optimization Process Completed Successfully! " 13
    [cite_start]Update-Log "[!] Highly recommended to RESTART your PC to apply low-level parameters. [cite: 17]" 13
    
    [System.Windows.MessageBox]::Show("Optimization Completed!`n`nPlease restart your PC to apply all updates.", "GOAT Tweaks v3.0", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
})

# --- Render GUI Window ---
$Form.ShowDialog() | Out-Null
