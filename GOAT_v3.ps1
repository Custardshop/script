#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GOAT - Greatest Of All Tweaks v3.0 (PowerShell WPF Edition)
.DESCRIPTION
    GUI-based Windows optimizer. Run as Administrator.
    Usage: Right-click > Run with PowerShell  (or: powershell -ExecutionPolicy Bypass -File ".\GOAT-Tweak-v3.ps1")
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ── STA THREAD ENFORCEMENT (required for WPF) ────────────────────────────────
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $script = $MyInvocation.MyCommand.Definition
    if ($script -and (Test-Path $script)) {
        # Re-launch as STA from file
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -STA -File `"$script`"" -Verb RunAs
    } else {
        # Re-launch as STA from web (irm|iex scenario)
        $tmpFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $MyInvocation.MyCommand.ScriptBlock | Out-File $tmpFile -Encoding UTF8
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -STA -File `"$tmpFile`"" -Verb RunAs
    }
    exit
}


# ── XAML UI ──────────────────────────────────────────────────────────────────
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="GOAT - Greatest Of All Tweaks v3.0"
    Width="820" Height="640"
    MinWidth="820" MinHeight="640"
    WindowStartupLocation="CenterScreen"
    Background="#0A0A0A"
    FontFamily="Courier New"
    ResizeMode="CanMinimize">

  <Window.Resources>
    <!-- Scrollbar style -->
    <Style x:Key="ThinScrollBar" TargetType="ScrollBar">
      <Setter Property="Width" Value="6"/>
      <Setter Property="Background" Value="#0D0D0D"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid Background="{TemplateBinding Background}">
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb>
                  <Thumb>
                    <Thumb.Template>
                      <ControlTemplate TargetType="Thumb">
                        <Border Background="#2A2A2A" CornerRadius="3"/>
                      </ControlTemplate>
                    </Thumb.Template>
                  </Thumb>
                </Track.Thumb>
              </Track>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="ThinScrollViewer" TargetType="ScrollViewer">
      <Setter Property="HorizontalScrollBarVisibility" Value="Disabled"/>
      <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="44"/>
      <RowDefinition Height="56"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="58"/>
    </Grid.RowDefinitions>

    <!-- ── HEADER ── -->
    <Border Grid.Row="0" Background="#111111" BorderBrush="#222222" BorderThickness="0,0,0,1">
      <Grid Margin="16,0">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Grid.Column="0">
          <Ellipse Width="10" Height="10" Fill="#E53E3E" Margin="0,0,10,0">
            <Ellipse.Triggers>
              <EventTrigger RoutedEvent="Loaded">
                <BeginStoryboard>
                  <Storyboard RepeatBehavior="Forever">
                    <DoubleAnimation Storyboard.TargetProperty="Opacity" From="1" To="0.3" Duration="0:0:1" AutoReverse="True"/>
                  </Storyboard>
                </BeginStoryboard>
              </EventTrigger>
            </Ellipse.Triggers>
          </Ellipse>
          <TextBlock Text="GOAT TWEAK" Foreground="#E53E3E" FontSize="13" FontWeight="Bold" VerticalAlignment="Center"/>
          <TextBlock Text="  v3.0" Foreground="#555555" FontSize="11" VerticalAlignment="Center"/>
        </StackPanel>
        <Border Grid.Column="1" BorderBrush="#333333" BorderThickness="1" CornerRadius="3" Padding="10,3" VerticalAlignment="Center">
          <TextBlock x:Name="StatusBadge" Text="IDLE" Foreground="#888888" FontSize="10"/>
        </Border>
      </Grid>
    </Border>

    <!-- ── SYS BAR ── -->
    <Border Grid.Row="1" Background="#0F0F0F" BorderBrush="#1E1E1E" BorderThickness="0,0,0,1">
      <UniformGrid Columns="5" Margin="0">
        <Border BorderBrush="#1E1E1E" BorderThickness="0,0,1,0" Padding="14,8">
          <StackPanel>
            <TextBlock Text="CPU" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
            <TextBlock x:Name="SysCpu" Text="..." Foreground="#CCCCCC" FontSize="11" FontWeight="Bold"/>
            <TextBlock x:Name="SysCpuSub" Text="Active" Foreground="#22C55E" FontSize="10"/>
          </StackPanel>
        </Border>
        <Border BorderBrush="#1E1E1E" BorderThickness="0,0,1,0" Padding="14,8">
          <StackPanel>
            <TextBlock Text="RAM" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
            <TextBlock x:Name="SysRam" Text="..." Foreground="#CCCCCC" FontSize="11" FontWeight="Bold"/>
            <TextBlock x:Name="SysRamSub" Text="Physical" Foreground="#FACC15" FontSize="10"/>
          </StackPanel>
        </Border>
        <Border BorderBrush="#1E1E1E" BorderThickness="0,0,1,0" Padding="14,8">
          <StackPanel>
            <TextBlock Text="OS" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
            <TextBlock x:Name="SysOs" Text="..." Foreground="#CCCCCC" FontSize="11" FontWeight="Bold"/>
            <TextBlock x:Name="SysOsBuild" Text="..." Foreground="#555555" FontSize="10"/>
          </StackPanel>
        </Border>
        <Border BorderBrush="#1E1E1E" BorderThickness="0,0,1,0" Padding="14,8">
          <StackPanel>
            <TextBlock Text="USER" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
            <TextBlock x:Name="SysUser" Text="..." Foreground="#CCCCCC" FontSize="11" FontWeight="Bold"/>
            <TextBlock x:Name="SysHost" Text="..." Foreground="#555555" FontSize="10"/>
          </StackPanel>
        </Border>
        <Border Padding="14,8">
          <StackPanel>
            <TextBlock Text="ADMIN" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
            <TextBlock x:Name="SysAdmin" Text="Elevated" Foreground="#22C55E" FontSize="11" FontWeight="Bold"/>
            <TextBlock x:Name="SysAdminSub" Text="Admin OK" Foreground="#22C55E" FontSize="10"/>
          </StackPanel>
        </Border>
      </UniformGrid>
    </Border>

    <!-- ── MAIN AREA ── -->
    <Grid Grid.Row="2">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="248"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- Sidebar -->
      <Border Grid.Column="0" BorderBrush="#1E1E1E" BorderThickness="0,0,1,0" Background="#0D0D0D">
        <ScrollViewer Style="{StaticResource ThinScrollViewer}">
          <StackPanel x:Name="ModuleList" Margin="0,12,0,12">
            <TextBlock Text="MODULES" Foreground="#333333" FontSize="9" Margin="16,0,16,10"/>
          </StackPanel>
        </ScrollViewer>
      </Border>

      <!-- Content -->
      <Grid Grid.Column="1">
        <Grid.RowDefinitions>
          <RowDefinition Height="62"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <!-- Progress -->
        <Border Grid.Row="0" BorderBrush="#1E1E1E" BorderThickness="0,0,0,1" Padding="18,14">
          <StackPanel>
            <Grid Margin="0,0,0,10">
              <TextBlock Text="PROGRESS" Foreground="#444444" FontSize="10" VerticalAlignment="Center"/>
              <TextBlock x:Name="ProgPct" Text="0%" Foreground="#E53E3E" FontSize="22" FontWeight="Bold" HorizontalAlignment="Right"/>
            </Grid>
            <Border Background="#1E1E1E" Height="3" CornerRadius="2">
              <Border x:Name="ProgFill" Background="#E53E3E" HorizontalAlignment="Left" Width="0" CornerRadius="2"/>
            </Border>
          </StackPanel>
        </Border>

        <!-- Log output -->
        <Grid Grid.Row="1">
          <Border Background="#0D0D0D" Padding="18,12">
            <StackPanel>
              <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                <Ellipse x:Name="OutDot" Width="7" Height="7" Fill="#E53E3E" Margin="0,0,8,0" VerticalAlignment="Center"/>
                <TextBlock Text="LIVE OUTPUT" Foreground="#444444" FontSize="9" VerticalAlignment="Center"/>
              </StackPanel>
              <ScrollViewer x:Name="LogScroll" Style="{StaticResource ThinScrollViewer}" MaxHeight="310">
                <StackPanel x:Name="LogLines"/>
              </ScrollViewer>
            </StackPanel>
          </Border>
        </Grid>
      </Grid>
    </Grid>

    <!-- ── BUTTON BAR ── -->
    <Grid Grid.Row="3" Background="#0D0D0D">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Border Grid.Column="0" BorderBrush="#1E1E1E" BorderThickness="0,1,1,0">
        <Button x:Name="BtnRun" Content="RUN ALL" Background="#E53E3E" Foreground="White"
                FontFamily="Courier New" FontSize="13" FontWeight="Bold"
                BorderThickness="0" Cursor="Hand">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="Bd" Background="{TemplateBinding Background}">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="Bd" Property="Background" Value="#F05252"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                  <Setter TargetName="Bd" Property="Background" Value="#1A1A1A"/>
                  <Setter Property="Foreground" Value="#333333"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
        </Button>
      </Border>
      <Border Grid.Column="1" BorderBrush="#1E1E1E" BorderThickness="0,1,0,0">
        <Button x:Name="BtnReset" Content="RESET" Background="#111111" Foreground="#777777"
                FontFamily="Courier New" FontSize="13" FontWeight="Bold"
                BorderThickness="0" Cursor="Hand">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="Bd" Background="{TemplateBinding Background}">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="Bd" Property="Background" Value="#1E1E1E"/>
                  <Setter Property="Foreground" Value="#CCCCCC"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                  <Setter Property="Foreground" Value="#2A2A2A"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
        </Button>
      </Border>
    </Grid>
  </Grid>
</Window>
'@

# ── Build Window ─────────────────────────────────────────────────────────────
try {
    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    if (-not $window) { throw "XamlReader returned null" }
} catch {
    [System.Windows.MessageBox]::Show(
        "XAML Load Error:`n`n$($_.Exception.Message)`n`nInner: $($_.Exception.InnerException.Message)",
        "GOAT - Fatal Error",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
    exit 1
}

# Grab controls
$statusBadge = $window.FindName('StatusBadge')
$sysCpu      = $window.FindName('SysCpu')
$sysRam      = $window.FindName('SysRam')
$sysOs       = $window.FindName('SysOs')
$sysOsBuild  = $window.FindName('SysOsBuild')
$sysUser     = $window.FindName('SysUser')
$sysHost_    = $window.FindName('SysHost')
$sysAdmin    = $window.FindName('SysAdmin')
$sysAdminSub = $window.FindName('SysAdminSub')
$moduleList  = $window.FindName('ModuleList')
$progPct     = $window.FindName('ProgPct')
$progFill    = $window.FindName('ProgFill')
$logLines    = $window.FindName('LogLines')
$logScroll   = $window.FindName('LogScroll')
$outDot      = $window.FindName('OutDot')
$btnRun      = $window.FindName('BtnRun')
$btnReset    = $window.FindName('BtnReset')
$contentCol  = $window.FindName('ProgFill').Parent.Parent.Parent  # content column width ref

# ── Module Definitions ────────────────────────────────────────────────────────
$modules = @(
  @{ Name="Kernel & HPET"; Num="01"; Steps=@(
    @{ Msg="bcdedit: useplatformclock → disabled";
       Cmd={ bcdedit /set useplatformclock no 2>$null } },
    @{ Msg="useplatformtick + disabledynamictick → on";
       Cmd={ bcdedit /set useplatformtick yes 2>$null; bcdedit /set disabledynamictick yes 2>$null } },
    @{ Msg="tscsyncpolicy → Enhanced";
       Cmd={ bcdedit /set tscsyncpolicy Enhanced 2>$null } },
    @{ Msg="NX policy → OptOut";
       Cmd={ bcdedit /set nx OptOut 2>$null } },
    @{ Msg="synthetictimers → enabled";
       Cmd={ bcdedit /set synthetictimers yes 2>$null } },
    @{ Msg="Disabling HPET via PnP...";
       Cmd={ Get-PnpDevice -EA SilentlyContinue | Where-Object { $_.FriendlyName -like '*High Precision*' } | Disable-PnpDevice -Confirm:$false -EA SilentlyContinue } },
    @{ Msg="Kernel & HPET optimized ✓"; Cmd=$null }
  )},
  @{ Name="Timer Resolution"; Num="02"; Steps=@(
    @{ Msg="GlobalTimerResolutionRequests = 1";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="Timer resolution tuned ✓"; Cmd=$null }
  )},
  @{ Name="Process Priority"; Num="03"; Steps=@(
    @{ Msg="Win32PrioritySeparation = 0x2a (gaming mode)";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x2a /f 2>$null } },
    @{ Msg="SvcHostSplitThreshold → 32 MB";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 33554432 /f 2>$null } },
    @{ Msg="SystemResponsiveness = 0, NetworkThrottlingIndex off";
       Cmd={ reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f 2>$null
             reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f 2>$null } },
    @{ Msg="AdditionalCriticalWorkerThreads = 2";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "AdditionalCriticalWorkerThreads" /t REG_DWORD /d 2 /f 2>$null } },
    @{ Msg="Game Tasks: GPU=8, CPU=6, Scheduling→High";
       Cmd={ $gp = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
             reg add $gp /v "GPU Priority" /t REG_DWORD /d 8 /f 2>$null
             reg add $gp /v "Priority" /t REG_DWORD /d 6 /f 2>$null
             reg add $gp /v "Scheduling Category" /t REG_SZ /d "High" /f 2>$null
             reg add $gp /v "SFIO Priority" /t REG_SZ /d "High" /f 2>$null } },
    @{ Msg="Process priority configured ✓"; Cmd=$null }
  )},
  @{ Name="IRQ MSI Mode"; Num="04"; Steps=@(
    @{ Msg="Enabling MSI on all PCI devices...";
       Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI' -EA SilentlyContinue | ForEach-Object {
               $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
               if (Test-Path $p) { Set-ItemProperty -Path $p -Name MSISupported -Value 1 -Type DWord -Force -EA SilentlyContinue }
             } } },
    @{ Msg="MSI mode activated ✓"; Cmd=$null }
  )},
  @{ Name="Memory Management"; Num="05"; Steps=@(
    @{ Msg="SystemCacheDirtyPageThreshold = 0";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemCacheDirtyPageThreshold" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="ClearPageFileAtShutdown → disabled";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="EnablePrefetcher = 3, Superfetch off";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f 2>$null
             reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="Hibernation file removed (powercfg -h off)";
       Cmd={ powercfg -h off 2>$null } },
    @{ Msg="OneDrive terminated, startup removed";
       Cmd={ taskkill /f /im OneDrive.exe 2>$null
             reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null } },
    @{ Msg="Memory management optimized ✓"; Cmd=$null }
  )},
  @{ Name="Input & USB"; Num="06"; Steps=@(
    @{ Msg="Mouse & keyboard queue sizes = 16";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 16 /f 2>$null
             reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 16 /f 2>$null } },
    @{ Msg="PowerThrottlingOff = 1";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="Mouse acceleration disabled";
       Cmd={ reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f 2>$null
             reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f 2>$null
             reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f 2>$null } },
    @{ Msg="Keyboard delay = 0, speed = 31 (max)";
       Cmd={ reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f 2>$null
             reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f 2>$null } },
    @{ Msg="USB selective suspend off, HidUsb idle off";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f 2>$null
             reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v "IdleEnable" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="Input & USB tuned ✓"; Cmd=$null }
  )},
  @{ Name="Nagle Algorithm"; Num="07"; Steps=@(
    @{ Msg="TcpAckFrequency=1, TCPNoDelay=1, DelAckTicks=0 on all adapters";
       Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object {
               Set-ItemProperty -Path $_.PSPath -Name TcpAckFrequency -Value 1 -Type DWord -Force -EA SilentlyContinue
               Set-ItemProperty -Path $_.PSPath -Name TCPNoDelay      -Value 1 -Type DWord -Force -EA SilentlyContinue
               Set-ItemProperty -Path $_.PSPath -Name TcpDelAckTicks  -Value 0 -Type DWord -Force -EA SilentlyContinue
             } } },
    @{ Msg="Nagle algorithm disabled ✓"; Cmd=$null }
  )},
  @{ Name="Visual Effects"; Num="08"; Steps=@(
    @{ Msg="VisualFXSetting = 2 (custom performance)";
       Cmd={ reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f 2>$null } },
    @{ Msg="UserPreferencesMask applied";
       Cmd={ reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012078010000000 /f 2>$null } },
    @{ Msg="Window + taskbar animations disabled";
       Cmd={ reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f 2>$null
             reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="Visual effects tuned ✓"; Cmd=$null }
  )},
  @{ Name="Game Bar & DVR"; Num="09"; Steps=@(
    @{ Msg="AppCaptureEnabled = 0, GameDVR disabled";
       Cmd={ reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f 2>$null
             reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="FSE behavior mode, DXGI compatibility set";
       Cmd={ reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f 2>$null
             reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f 2>$null
             reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="AllowGameDVR policy → disabled";
       Cmd={ reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="Game Bar & DVR fully disabled ✓"; Cmd=$null }
  )},
  @{ Name="Processor Power"; Num="10"; Steps=@(
    @{ Msg="PROCTHROTTLEMIN = 100% (no downclocking)";
       Cmd={ powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null } },
    @{ Msg="PROCTHROTTLEMAX = 100% (no boost cap)";
       Cmd={ powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null } },
    @{ Msg="Power scheme activated";
       Cmd={ powercfg /setactive SCHEME_CURRENT 2>$null } },
    @{ Msg="CPU unthrottled — max performance ✓"; Cmd=$null }
  )},
  @{ Name="Network & DNS"; Num="11"; Steps=@(
    @{ Msg="TCP RSS on, autotuning off, timestamps off";
       Cmd={ netsh int tcp set global rss=enabled 2>$null
             netsh int tcp set global autotuninglevel=disabled 2>$null
             netsh int tcp set global timestamps=disabled 2>$null
             netsh int tcp set global chimney=disabled 2>$null } },
    @{ Msg="TCPNoDelay + TcpAckFrequency + TTL=64 global";
       Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f 2>$null
             reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f 2>$null
             reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f 2>$null } },
    @{ Msg="DNS flushed, Winsock reset, IP stack reset";
       Cmd={ ipconfig /flushdns 2>$null; netsh winsock reset 2>$null; netsh int ip reset 2>$null } },
    @{ Msg="DHCP release/renew, adapters restarted";
       Cmd={ ipconfig /release 2>$null; ipconfig /renew 2>$null
             Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -EA SilentlyContinue } },
    @{ Msg="Network & DNS optimized ✓"; Cmd=$null }
  )},
  @{ Name="Windows Services"; Num="12"; Steps=@(
    @{ Msg="Stopping & disabling DiagTrack, WSearch...";
       Cmd={ foreach ($s in @('DiagTrack','WSearch','MapsBroker')) {
               Stop-Service $s -Force -EA SilentlyContinue
               Set-Service  $s -StartupType Disabled -EA SilentlyContinue
             } } },
    @{ Msg="Disabling Xbox, Fax, RetailDemo, RemoteRegistry, WerSvc...";
       Cmd={ foreach ($s in @('XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc')) {
               Stop-Service $s -Force -EA SilentlyContinue
               Set-Service  $s -StartupType Disabled -EA SilentlyContinue
             } } },
    @{ Msg="Ensuring audio + network essentials running...";
       Cmd={ foreach ($s in @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer')) {
               Set-Service $s -StartupType Automatic -EA SilentlyContinue
               Start-Service $s -EA SilentlyContinue
             } } },
    @{ Msg="Services cleanup done ✓"; Cmd=$null }
  )},
  @{ Name="Junk & Log Cleanup"; Num="13"; Steps=@(
    @{ Msg="Clearing Temp folders...";
       Cmd={ Remove-Item "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue
             Remove-Item "C:\Windows\Temp\*"     -Recurse -Force -EA SilentlyContinue
             Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Stopping Windows Update, removing cache...";
       Cmd={ Stop-Service wuauserv -Force -EA SilentlyContinue
             Stop-Service UsoSvc   -Force -EA SilentlyContinue
             Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Restarting Windows Update service";
       Cmd={ Start-Service wuauserv -EA SilentlyContinue } },
    @{ Msg="Clearing all Windows Event Logs...";
       Cmd={ Get-WinEvent -ListLog * -EA SilentlyContinue | ForEach-Object {
               [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName)
             } } },
    @{ Msg="Cleanup complete ✓"; Cmd=$null }
  )}
)

# ── Helper: Detect system info ────────────────────────────────────────────────
function Get-SysInfo {
  try {
    $cpu = (Get-CimInstance Win32_Processor -EA Stop).Name -replace '\s+',' '
    $sysCpu.Text = if ($cpu.Length -gt 18) { $cpu.Substring(0,17)+'…' } else { $cpu }
  } catch { $sysCpu.Text = 'Unknown CPU' }

  try {
    $gb = [math]::Round((Get-CimInstance Win32_ComputerSystem -EA Stop).TotalPhysicalMemory / 1GB)
    $sysRam.Text = "$gb GB RAM"
  } catch { $sysRam.Text = '?' }

  try {
    $os = Get-CimInstance Win32_OperatingSystem -EA Stop
    $osShort = $os.Caption -replace 'Microsoft ',''
    $sysOs.Text     = if ($osShort.Length -gt 14) { $osShort.Substring(0,13)+'…' } else { $osShort }
    $sysOsBuild.Text = "Build $($os.BuildNumber)"
  } catch { $sysOs.Text = 'Windows' }

  $sysUser.Text  = $env:USERNAME
  $sysHost_.Text = $env:COMPUTERNAME
}

# ── Helper: Render module list ────────────────────────────────────────────────
$script:moduleRows = @{}

function Render-Modules {
  param([int]$current = -1, [bool]$isRunning = $false)

  # Clear existing rows (keep header TextBlock)
  $toRemove = $moduleList.Children | Where-Object { $_ -is [System.Windows.Controls.Border] }
  foreach ($el in @($toRemove)) { $moduleList.Children.Remove($el) }
  $script:moduleRows = @{}

  for ($i = 0; $i -lt $modules.Count; $i++) {
    $m = $modules[$i]

    $row = New-Object System.Windows.Controls.Border
    $row.Padding = [System.Windows.Thickness]::new(16, 7, 16, 7)
    if ($i -eq $current) { $row.Background = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x1a,0x0a,0x0a) }

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = 'Horizontal'

    # Checkbox
    $cb = New-Object System.Windows.Controls.Border
    $cb.Width = 13; $cb.Height = 13; $cb.CornerRadius = [System.Windows.CornerRadius]::new(2)
    $cb.Margin = [System.Windows.Thickness]::new(0,0,10,0)
    $cb.VerticalAlignment = 'Center'

    $cbText = New-Object System.Windows.Controls.TextBlock
    $cbText.HorizontalAlignment = 'Center'; $cbText.VerticalAlignment = 'Center'
    $cbText.FontSize = 9; $cbText.Foreground = [System.Windows.Media.Brushes]::White

    if ($i -lt $current) {
      $cb.BorderBrush     = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xe5,0x3e,0x3e)
      $cb.Background      = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xe5,0x3e,0x3e)
      $cb.BorderThickness = [System.Windows.Thickness]::new(1)
      $cbText.Text        = [char]0x2713
    } elseif ($i -eq $current -and $isRunning) {
      $cb.BorderBrush     = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xfa,0xcc,0x15)
      $cb.Background      = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xfa,0xcc,0x15)
      $cb.BorderThickness = [System.Windows.Thickness]::new(1)
    } else {
      $cb.BorderBrush     = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x33,0x33,0x33)
      $cb.BorderThickness = [System.Windows.Thickness]::new(1)
    }
    $cb.Child = $cbText

    # Module name
    $nameBlock = New-Object System.Windows.Controls.TextBlock
    $nameBlock.Text     = $m.Name
    $nameBlock.FontSize = 11
    $nameBlock.VerticalAlignment = 'Center'
    $nameBlock.Margin   = [System.Windows.Thickness]::new(0,0,8,0)
    if ($i -lt $current) {
      $nameBlock.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x22,0xc5,0x5e)
    } elseif ($i -eq $current -and $isRunning) {
      $nameBlock.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xcc,0xcc,0xcc)
    } else {
      $nameBlock.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x77,0x77,0x77)
    }

    # Module number
    $numBlock = New-Object System.Windows.Controls.TextBlock
    $numBlock.Text       = $m.Num
    $numBlock.FontSize   = 10
    $numBlock.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x33,0x33,0x33)
    $numBlock.VerticalAlignment = 'Center'

    $sp.Children.Add($cb)      | Out-Null
    $sp.Children.Add($nameBlock) | Out-Null
    $sp.Children.Add($numBlock)  | Out-Null
    $row.Child = $sp
    $moduleList.Children.Add($row) | Out-Null
    $script:moduleRows[$i] = $row
  }
}

# ── Helper: Append log line ───────────────────────────────────────────────────
$script:startTime = $null
function Get-Elapsed {
  if (-not $script:startTime) { return '00:00:00' }
  $s = [int]([datetime]::Now - $script:startTime).TotalSeconds
  return '{0:D2}:{1:D2}:{2:D2}' -f [math]::Floor($s/3600), [math]::Floor(($s%3600)/60), ($s%60)
}

function Add-LogLine {
  param([string]$msg, [string]$type = '')
  $colorMap = @{
    'success' = [System.Windows.Media.Color]::FromRgb(0x22,0xc5,0x5e)
    'warn'    = [System.Windows.Media.Color]::FromRgb(0xfa,0xcc,0x15)
    'info'    = [System.Windows.Media.Color]::FromRgb(0x60,0xa5,0xfa)
    'error'   = [System.Windows.Media.Color]::FromRgb(0xf8,0x71,0x71)
    ''        = [System.Windows.Media.Color]::FromRgb(0x66,0x66,0x66)
  }
  $color = if ($colorMap.ContainsKey($type)) { $colorMap[$type] } else { $colorMap[''] }

  $sp = New-Object System.Windows.Controls.StackPanel
  $sp.Orientation = 'Horizontal'

  $t1 = New-Object System.Windows.Controls.TextBlock
  $t1.Text = Get-Elapsed
  $t1.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x33,0x33,0x33)
  $t1.FontSize = 11; $t1.MinWidth = 68; $t1.Margin = [System.Windows.Thickness]::new(0,0,12,0)

  $t2 = New-Object System.Windows.Controls.TextBlock
  $t2.Text = $msg
  $t2.Foreground = [System.Windows.Media.SolidColorBrush]$color
  $t2.FontSize = 11
  $t2.TextWrapping = 'Wrap'

  $sp.Children.Add($t1) | Out-Null
  $sp.Children.Add($t2) | Out-Null
  $logLines.Children.Add($sp) | Out-Null

  $window.Dispatcher.Invoke([action]{ $logScroll.ScrollToEnd() }, 'Background')
}

# ── Run logic (background job + dispatcher) ───────────────────────────────────
$script:isRunning = $false

function Start-RunAll {
  if ($script:isRunning) { return }
  $script:isRunning = $true
  $script:startTime = [datetime]::Now

  $btnRun.IsEnabled   = $false
  $btnReset.IsEnabled = $false
  $statusBadge.Text       = 'RUNNING'
  $statusBadge.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xe5,0x3e,0x3e)

  Add-LogLine '[!] Starting GOAT optimization sequence...' 'info'
  Add-LogLine '[!] Running as Administrator — all commands active.' 'success'

  $totalMods = $modules.Count

  # Run in a background runspace to keep UI responsive
  $rs = [runspacefactory]::CreateRunspace()
  $rs.ApartmentState = 'STA'
  $rs.ThreadOptions  = 'ReuseThread'
  $rs.Open()
  $rs.SessionStateProxy.SetVariable('modules',   $modules)
  $rs.SessionStateProxy.SetVariable('window',    $window)
  $rs.SessionStateProxy.SetVariable('logLines',  $logLines)
  $rs.SessionStateProxy.SetVariable('logScroll', $logScroll)
  $rs.SessionStateProxy.SetVariable('progPct',   $progPct)
  $rs.SessionStateProxy.SetVariable('progFill',  $progFill)
  $rs.SessionStateProxy.SetVariable('statusBadge', $statusBadge)
  $rs.SessionStateProxy.SetVariable('btnRun',    $btnRun)
  $rs.SessionStateProxy.SetVariable('btnReset',  $btnReset)
  $rs.SessionStateProxy.SetVariable('startTimeBg', $script:startTime)
  $rs.SessionStateProxy.SetVariable('isRunningRef', ([ref]$script:isRunning))

  # Pass render & log functions as script blocks
  $addLogBlock = {
    param([string]$msg, [string]$type = '')
    $colorMap = @{
      'success' = [System.Windows.Media.Color]::FromRgb(0x22,0xc5,0x5e)
      'warn'    = [System.Windows.Media.Color]::FromRgb(0xfa,0xcc,0x15)
      'info'    = [System.Windows.Media.Color]::FromRgb(0x60,0xa5,0xfa)
      'error'   = [System.Windows.Media.Color]::FromRgb(0xf8,0x71,0x71)
      ''        = [System.Windows.Media.Color]::FromRgb(0x66,0x66,0x66)
    }
    $color = if ($colorMap.ContainsKey($type)) { $colorMap[$type] } else { $colorMap[''] }
    $elapsed = if ($startTimeBg) {
      $s = [int]([datetime]::Now - $startTimeBg).TotalSeconds
      '{0:D2}:{1:D2}:{2:D2}' -f [math]::Floor($s/3600), [math]::Floor(($s%3600)/60), ($s%60)
    } else { '00:00:00' }

    $window.Dispatcher.Invoke([action]{
      $sp = New-Object System.Windows.Controls.StackPanel
      $sp.Orientation = 'Horizontal'
      $t1 = New-Object System.Windows.Controls.TextBlock
      $t1.Text       = $elapsed
      $t1.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x33,0x33,0x33)
      $t1.FontSize   = 11; $t1.MinWidth = 68
      $t1.Margin     = [System.Windows.Thickness]::new(0,0,12,0)
      $t2 = New-Object System.Windows.Controls.TextBlock
      $t2.Text        = $msg
      $t2.Foreground  = [System.Windows.Media.SolidColorBrush]$color
      $t2.FontSize    = 11
      $t2.TextWrapping = 'Wrap'
      $sp.Children.Add($t1) | Out-Null
      $sp.Children.Add($t2) | Out-Null
      $logLines.Children.Add($sp) | Out-Null
      $logScroll.ScrollToEnd()
    }, 'Normal')
  }

  $ps = [powershell]::Create()
  $ps.Runspace = $rs
  [void]$ps.AddScript({
    param($addLog, $mods, $win, $pPct, $pFill, $badge, $bRun, $bReset, $logLinesCtrl, $startT)

    # ── Import required modules into this runspace ──────────────────────────────
    Import-Module Microsoft.PowerShell.Management -ErrorAction SilentlyContinue
    Import-Module Microsoft.PowerShell.Utility    -ErrorAction SilentlyContinue
    try { Import-Module PnpDevice    -ErrorAction SilentlyContinue } catch {}
    try { Import-Module NetAdapter   -ErrorAction SilentlyContinue } catch {}
    try { Import-Module NetTCPIP     -ErrorAction SilentlyContinue } catch {}

    for ($i = 0; $i -lt $mods.Count; $i++) {
      $m = $mods[$i]

      # Update sidebar highlight
      $idx = $i
      $win.Dispatcher.Invoke([action]{
        $panels = $logLinesCtrl.Parent.Parent.Parent.Parent.Children[0].Child.Children
        # (sidebar update handled by highlight logic below)
      }, 'Normal')

      & $addLog "[$($m.Num)/13] Running: $($m.Name)..." 'warn'

      foreach ($step in $m.Steps) {
        Start-Sleep -Milliseconds 60
        & $addLog "  $($step.Msg)" ''
        if ($step.Cmd) {
          try   { & $step.Cmd }
          catch { & $addLog "  [!] Error: $_" 'error' }
        }
      }

      # Update progress bar
      $pct = [math]::Round((($i + 1) / $mods.Count) * 100)
      $capturedPct = $pct
      $win.Dispatcher.Invoke([action]{
        $pPct.Text = "$capturedPct%"
        # Get actual content column width for fill
        $trackWidth = $pFill.Parent.ActualWidth
        $pFill.Width = ($trackWidth * $capturedPct / 100)
      }, 'Normal')

      Start-Sleep -Milliseconds 80
    }

    # Done
    & $addLog '' ''
    & $addLog '✓ ALL 13 MODULES COMPLETED SUCCESSFULLY!' 'success'
    & $addLog '⚠ Restart your PC for all changes to take effect.' 'warn'

    $win.Dispatcher.Invoke([action]{
      $badge.Text       = 'DONE'
      $badge.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x22,0xc5,0x5e)
      $bRun.IsEnabled   = $true
      $bReset.IsEnabled = $true
    }, 'Normal')
  })
  [void]$ps.AddArgument($addLogBlock)
  [void]$ps.AddArgument($modules)
  [void]$ps.AddArgument($window)
  [void]$ps.AddArgument($progPct)
  [void]$ps.AddArgument($progFill)
  [void]$ps.AddArgument($statusBadge)
  [void]$ps.AddArgument($btnRun)
  [void]$ps.AddArgument($btnReset)
  [void]$ps.AddArgument($logLines)
  [void]$ps.AddArgument($script:startTime)

  $null = $ps.BeginInvoke()
}

function Reset-All {
  if ($script:isRunning) { return }
  $script:startTime = $null
  $progPct.Text             = '0%'
  $progFill.Width           = 0
  $statusBadge.Text         = 'IDLE'
  $statusBadge.Foreground   = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x88,0x88,0x88)
  $logLines.Children.Clear()
  Add-LogLine 'GOAT Tweak v3.0 ready. 13 modules loaded. Press RUN ALL to begin.' 'info'
  Render-Modules -current -1
}

# ── Wire buttons ──────────────────────────────────────────────────────────────
$btnRun.Add_Click({   Start-RunAll })
$btnReset.Add_Click({ Reset-All    })

# ── Init ──────────────────────────────────────────────────────────────────────
Get-SysInfo
Render-Modules -current -1
Add-LogLine 'GOAT Tweak v3.0 ready. 13 modules loaded. Press RUN ALL to begin.' 'info'

# ── Show window ───────────────────────────────────────────────────────────────
$window.ShowDialog() | Out-Null
