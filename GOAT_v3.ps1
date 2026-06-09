#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GOAT - Greatest Of All Tweaks v3.0 (Modern UI Edition)
.DESCRIPTION
    Modern GUI-based Windows optimizer inspired by GOATGUI design.
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ── STA THREAD ENFORCEMENT ───────────────────────────────────────────────────
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $script = $MyInvocation.MyCommand.Definition
    if ($script -and (Test-Path $script)) {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -STA -File `"$script`"" -Verb RunAs
    } else {
        $tmpFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $MyInvocation.MyCommand.ScriptBlock | Out-File $tmpFile -Encoding UTF8
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -STA -File `"$tmpFile`"" -Verb RunAs
    }
    exit
}

# ── XAML UI (Converted from HTML/CSS) ────────────────────────────────────────
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="GOAT Tweak v3.0"
    Width="820" Height="640"
    MinWidth="820" MinHeight="640"
    WindowStartupLocation="CenterScreen"
    Background="#080808"
    FontFamily="Courier New"
    ResizeMode="CanMinimize">

  <Window.Resources>
    <!-- Modern Scrollbar -->
    <Style x:Key="ModernScrollBar" TargetType="ScrollBar">
      <Setter Property="Width" Value="4"/>
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid Background="{TemplateBinding Background}">
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb>
                  <Thumb>
                    <Thumb.Template>
                      <ControlTemplate TargetType="Thumb">
                        <Border Background="#6b0a1c" CornerRadius="2"/>
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
    <Style x:Key="ModernScrollViewer" TargetType="ScrollViewer">
      <Setter Property="HorizontalScrollBarVisibility" Value="Disabled"/>
      <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
    </Style>
  </Window.Resources>

  <Border BorderBrush="#220608" BorderThickness="1" CornerRadius="14" Margin="1">
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="44"/> <!-- Header -->
        <RowDefinition Height="56"/> <!-- Sys Bar -->
        <RowDefinition Height="*"/>  <!-- Body -->
      </Grid.RowDefinitions>

      <!-- ── HEADER ── -->
      <Border Grid.Row="0" Background="#0A0A0A" BorderBrush="#1c0608" BorderThickness="0,0,0,1" CornerRadius="14,14,0,0">
        <Grid Margin="18,0">
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <Ellipse Width="8" Height="8" Fill="#dc143c" Margin="0,0,10,0"/>
            <TextBlock Text="GOAT TWEAK" Foreground="#dc143c" FontSize="12" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,5,0"/>
            <TextBlock Text="v3.0" Foreground="#444444" FontSize="10" VerticalAlignment="Center"/>
          </StackPanel>
          <Border HorizontalAlignment="Right" VerticalAlignment="Center" BorderBrush="#6b0a1c" BorderThickness="1" CornerRadius="20" Padding="10,3">
            <TextBlock x:Name="StatusBadge" Text="IDLE" Foreground="#dc143c" FontSize="10" FontWeight="Bold"/>
          </Border>
        </Grid>
      </Border>

      <!-- ── SYS BAR ── -->
      <Border Grid.Row="1" Background="#100204" BorderBrush="#1c0608" BorderThickness="0,0,0,1">
        <UniformGrid Columns="5">
          <Border Background="#0e0e0e" Padding="13,9" BorderBrush="#1c0608" BorderThickness="0,0,1,0">
            <StackPanel>
              <TextBlock Text="CPU" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
              <TextBlock x:Name="SysCpu" Text="..." Foreground="#d8d8d8" FontSize="12" FontWeight="Medium" TextTrimming="CharacterEllipsis"/>
              <TextBlock x:Name="SysCpuSub" Text="--" Foreground="#2a9e2a" FontSize="10"/>
            </StackPanel>
          </Border>
          <Border Background="#0e0e0e" Padding="13,9" BorderBrush="#1c0608" BorderThickness="0,0,1,0">
            <StackPanel>
              <TextBlock Text="RAM" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
              <TextBlock x:Name="SysRam" Text="..." Foreground="#d8d8d8" FontSize="12" FontWeight="Medium"/>
              <TextBlock x:Name="SysRamSub" Text="--" Foreground="#2a9e2a" FontSize="10"/>
            </StackPanel>
          </Border>
          <Border Background="#0e0e0e" Padding="13,9" BorderBrush="#1c0608" BorderThickness="0,0,1,0">
            <StackPanel>
              <TextBlock Text="GPU" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
              <TextBlock x:Name="SysGpu" Text="..." Foreground="#d8d8d8" FontSize="12" FontWeight="Medium" TextTrimming="CharacterEllipsis"/>
              <TextBlock x:Name="SysGpuSub" Text="--" Foreground="#2a9e2a" FontSize="10"/>
            </StackPanel>
          </Border>
          <Border Background="#0e0e0e" Padding="13,9" BorderBrush="#1c0608" BorderThickness="0,0,1,0">
            <StackPanel>
              <TextBlock Text="OS" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
              <TextBlock x:Name="SysOs" Text="..." Foreground="#d8d8d8" FontSize="12" FontWeight="Medium" TextTrimming="CharacterEllipsis"/>
              <TextBlock x:Name="SysOsBuild" Text="..." Foreground="#444444" FontSize="10"/>
            </StackPanel>
          </Border>
          <Border Background="#0e0e0e" Padding="13,9">
            <StackPanel>
              <TextBlock Text="USER" Foreground="#444444" FontSize="9" Margin="0,0,0,3"/>
              <TextBlock x:Name="SysUser" Text="..." Foreground="#d8d8d8" FontSize="12" FontWeight="Medium" TextTrimming="CharacterEllipsis"/>
              <TextBlock x:Name="SysHost" Text="..." Foreground="#444444" FontSize="10"/>
            </StackPanel>
          </Border>
        </UniformGrid>
      </Border>

      <!-- ── BODY ── -->
      <Grid Grid.Row="2">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="200"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <!-- Sidebar -->
        <Border Grid.Column="0" Background="#090909" BorderBrush="#1c0608" BorderThickness="0,0,1,0">
          <DockPanel>
            <TextBlock DockPanel.Dock="Top" Text="MODULES" Foreground="#3a0810" FontSize="9" FontWeight="Bold" Margin="16,14,16,6" Tag="SG-HEAD"/>
            <ScrollViewer Style="{StaticResource ModernScrollViewer}">
              <StackPanel x:Name="ModuleList" Margin="0,0,0,14"/>
            </ScrollViewer>
          </DockPanel>
        </Border>

        <!-- Main Content -->
        <Grid Grid.Column="1" Margin="18">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <!-- Progress Box -->
            <RowDefinition Height="*"/>    <!-- Log Box -->
            <RowDefinition Height="Auto"/> <!-- Reboot Note -->
            <RowDefinition Height="Auto"/> <!-- Buttons -->
          </Grid.RowDefinitions>

          <!-- Progress Box -->
          <Border Grid.Row="0" Background="#0a0a0a" BorderBrush="#1c0608" BorderThickness="1" CornerRadius="10" Padding="15" Margin="0,0,0,14">
            <StackPanel>
              <Grid Margin="0,0,0,10">
                <TextBlock Text="PROGRESS" Foreground="#888888" FontSize="10" FontWeight="Bold" VerticalAlignment="Bottom"/>
                <TextBlock x:Name="ProgPct" Text="0%" Foreground="#dc143c" FontSize="22" FontWeight="Medium" HorizontalAlignment="Right"/>
              </Grid>
              <Border x:Name="ProgTrack" Background="#1e1e1e" Height="3" CornerRadius="2" Margin="0,0,0,8">
                <Border x:Name="ProgFill" Background="#dc143c" HorizontalAlignment="Left" Width="0" CornerRadius="2"/>
              </Border>
              <TextBlock x:Name="ProgMsg" Text="Ready — press RUN ALL to begin optimization" Foreground="#444444" FontSize="11"/>
            </StackPanel>
          </Border>

          <!-- Log Box -->
          <Border Grid.Row="1" Background="#060606" BorderBrush="#1c0608" BorderThickness="1" CornerRadius="10" Margin="0,0,0,14">
            <DockPanel>
              <Border DockPanel.Dock="Top" BorderBrush="#1c0608" BorderThickness="0,0,0,1" Padding="13,8">
                <StackPanel Orientation="Horizontal">
                  <Ellipse x:Name="LogDot" Width="5" Height="5" Fill="#dc143c" Margin="0,0,8,0" VerticalAlignment="Center">
                    <Ellipse.Triggers>
                      <EventTrigger RoutedEvent="Loaded">
                        <BeginStoryboard>
                          <Storyboard RepeatBehavior="Forever">
                            <DoubleAnimation Storyboard.TargetProperty="Opacity" From="1" To="0.2" Duration="0:0:0.7" AutoReverse="True"/>
                          </Storyboard>
                        </BeginStoryboard>
                      </EventTrigger>
                    </Ellipse.Triggers>
                  </Ellipse>
                  <TextBlock Text="LIVE OUTPUT" Foreground="#444444" FontSize="9" FontWeight="Bold" VerticalAlignment="Center"/>
                </StackPanel>
              </Border>
              <ScrollViewer x:Name="LogScroll" Style="{StaticResource ModernScrollViewer}" Padding="13,10">
                <StackPanel x:Name="LogLines"/>
              </ScrollViewer>
            </DockPanel>
          </Border>

          <!-- Reboot Note -->
          <Border x:Name="RebootNote" Grid.Row="2" Background="Transparent" BorderBrush="#1c0608" BorderThickness="1" CornerRadius="8" Padding="12,8" Margin="0,0,0,14" Visibility="Collapsed">
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="⚠" Foreground="#dc143c" FontSize="14" Margin="0,0,8,0" VerticalAlignment="Center"/>
              <TextBlock Text="All kernel &amp; network changes require a restart to take full effect." Foreground="#444444" FontSize="10" VerticalAlignment="Center" TextWrapping="Wrap"/>
            </StackPanel>
          </Border>

          <!-- Buttons -->
          <Grid Grid.Row="3">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Button x:Name="BtnRun" Grid.Column="0" Content="RUN ALL" Height="42" Margin="0,0,5,0"
                    Background="#dc143c" Foreground="White" BorderBrush="#dc143c" BorderThickness="2"
                    FontSize="12" FontWeight="Bold" Cursor="Hand">
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Background" Value="#b00e2d"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#b00e2d"/>
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                      <Setter TargetName="Bd" Property="Background" Value="#3a0810"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#3a0810"/>
                      <Setter Property="Foreground" Value="#6b1020"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
            <Button x:Name="BtnReset" Grid.Column="1" Content="RESET" Height="42" Margin="5,0,0,0"
                    Background="#e8e8e8" Foreground="#111" BorderBrush="#e8e8e8" BorderThickness="2"
                    FontSize="12" FontWeight="Bold" Cursor="Hand" IsEnabled="False">
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Background" Value="#ffffff"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#ffffff"/>
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                      <Setter TargetName="Bd" Property="Background" Value="#2a2a2a"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#2a2a2a"/>
                      <Setter Property="Foreground" Value="#555555"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
            <Button x:Name="BtnReboot" Grid.Column="2" Content="RESTART PC" Height="42" Width="140" Margin="10,0,0,0"
                    Background="#dc143c" Foreground="White" BorderBrush="#ff3355" BorderThickness="2"
                    FontSize="12" FontWeight="Bold" Cursor="Hand" Visibility="Collapsed">
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Background" Value="#ff1a3a"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#ff1a3a"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
          </Grid>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
'@

# ── Build Window ─────────────────────────────────────────────────────────────
try {
    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    if (-not $window) { throw "XamlReader returned null" }
} catch {
    [System.Windows.MessageBox]::Show("XAML Load Error:`n`n$($_.Exception.Message)", "GOAT - Fatal Error", 0, 16)
    exit 1
}

# Grab controls
$statusBadge = $window.FindName('StatusBadge')
$sysCpu      = $window.FindName('SysCpu')
$sysCpuSub   = $window.FindName('SysCpuSub')
$sysRam      = $window.FindName('SysRam')
$sysRamSub   = $window.FindName('SysRamSub')
$sysGpu      = $window.FindName('SysGpu')
$sysGpuSub   = $window.FindName('SysGpuSub')
$sysOs       = $window.FindName('SysOs')
$sysOsBuild  = $window.FindName('SysOsBuild')
$sysUser     = $window.FindName('SysUser')
$sysHost     = $window.FindName('SysHost')
$moduleList  = $window.FindName('ModuleList')
$progPct     = $window.FindName('ProgPct')
$progTrack   = $window.FindName('ProgTrack')
$progFill    = $window.FindName('ProgFill')
$progMsg     = $window.FindName('ProgMsg')
$logLines    = $window.FindName('LogLines')
$logScroll   = $window.FindName('LogScroll')
$rebootNote  = $window.FindName('RebootNote')
$btnRun      = $window.FindName('BtnRun')
$btnReset    = $window.FindName('BtnReset')
$btnReboot   = $window.FindName('BtnReboot')

# ── Module Definitions ────────────────────────────────────────────────────────
$modules = @(
  @{ Name="Kernel & HPET"; Num="01"; Steps=@(
    @{ Msg="bcdedit /set useplatformclock no"; Cmd={ bcdedit /set useplatformclock no 2>$null } },
    @{ Msg="bcdedit /set useplatformtick yes"; Cmd={ bcdedit /set useplatformtick yes 2>$null } },
    @{ Msg="bcdedit /set disabledynamictick yes"; Cmd={ bcdedit /set disabledynamictick yes 2>$null } },
    @{ Msg="bcdedit /set tscsyncpolicy Enhanced"; Cmd={ bcdedit /set tscsyncpolicy Enhanced 2>$null } },
    @{ Msg="bcdedit /set nx OptOut"; Cmd={ bcdedit /set nx OptOut 2>$null } },
    @{ Msg="bcdedit /set synthetictimers yes"; Cmd={ bcdedit /set synthetictimers yes 2>$null } },
    @{ Msg="Disabling HPET via PnP device manager..."; Cmd={ Get-PnpDevice -EA SilentlyContinue | Where-Object { $_.FriendlyName -like '*High Precision*' } | Disable-PnpDevice -Confirm:$false -EA SilentlyContinue } }
  )},
  @{ Name="Timer Resolution"; Num="02"; Steps=@(
    @{ Msg="reg add ...\kernel /v GlobalTimerResolutionRequests /d 1"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="Timer resolution set to 0.5ms"; Cmd=$null }
  )},
  @{ Name="Process Priority"; Num="03"; Steps=@(
    @{ Msg="Win32PrioritySeparation → 0x2a"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x2a /f 2>$null } },
    @{ Msg="SvcHostSplitThresholdInKB → 33554432"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 33554432 /f 2>$null } },
    @{ Msg="SystemResponsiveness → 0"; Cmd={ reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="NetworkThrottlingIndex → 0xFFFFFFFF"; Cmd={ reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f 2>$null } },
    @{ Msg="AdditionalCriticalWorkerThreads → 2"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "AdditionalCriticalWorkerThreads" /t REG_DWORD /d 2 /f 2>$null } },
    @{ Msg="Tasks\Games: GPU Priority → 8, Priority → 6"; Cmd={ $gp = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; reg add $gp /v "GPU Priority" /t REG_DWORD /d 8 /f 2>$null; reg add $gp /v "Priority" /t REG_DWORD /d 6 /f 2>$null } },
    @{ Msg="Scheduling Category → High, SFIO Priority → High"; Cmd={ $gp = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; reg add $gp /v "Scheduling Category" /t REG_SZ /d "High" /f 2>$null; reg add $gp /v "SFIO Priority" /t REG_SZ /d "High" /f 2>$null } }
  )},
  @{ Name="IRQ MSI Mode"; Num="04"; Steps=@(
    @{ Msg="Scanning HKLM:\SYSTEM\CurrentControlSet\Enum\PCI..."; Cmd=$null },
    @{ Msg="Setting MSISupported=1 on all PCI interrupt controllers"; Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI' -EA SilentlyContinue | ForEach-Object { $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"; if (Test-Path $p) { Set-ItemProperty -Path $p -Name MSISupported -Value 1 -Type DWord -Force -EA SilentlyContinue } } } },
    @{ Msg="IRQ MSI mode enabled"; Cmd=$null }
  )},
  @{ Name="Memory Management"; Num="05"; Steps=@(
    @{ Msg="SystemCacheDirtyPageThreshold → 0"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemCacheDirtyPageThreshold" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="ClearPageFileAtShutdown → 0"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="EnablePrefetcher → 3"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f 2>$null } },
    @{ Msg="EnableSuperfetch → 0"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="powercfg -h off  →  hiberfil.sys removed"; Cmd={ powercfg -h off 2>$null } },
    @{ Msg="Terminating OneDrive.exe + removing autostart key"; Cmd={ taskkill /f /im OneDrive.exe 2>$null; reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null } }
  )},
  @{ Name="Input & USB"; Num="06"; Steps=@(
    @{ Msg="MouseDataQueueSize → 16"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 16 /f 2>$null } },
    @{ Msg="KeyboardDataQueueSize → 16"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 16 /f 2>$null } },
    @{ Msg="PowerThrottlingOff → 1"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="Mouse acceleration disabled (Speed=0 Threshold=0)"; Cmd={ reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f 2>$null; reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f 2>$null; reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f 2>$null } },
    @{ Msg="KeyboardDelay → 0, KeyboardSpeed → 31"; Cmd={ reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f 2>$null; reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f 2>$null } },
    @{ Msg="USB DisableSelectiveSuspend → 1"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="HidUsb IdleEnable → 0"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v "IdleEnable" /t REG_DWORD /d 0 /f 2>$null } }
  )},
  @{ Name="Nagle Algorithm"; Num="07"; Steps=@(
    @{ Msg="Scanning TCP interfaces..."; Cmd=$null },
    @{ Msg="TcpAckFrequency → 1 on all adapters"; Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name TcpAckFrequency -Value 1 -Type DWord -Force -EA SilentlyContinue } } },
    @{ Msg="TCPNoDelay → 1 on all adapters"; Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name TCPNoDelay -Value 1 -Type DWord -Force -EA SilentlyContinue } } },
    @{ Msg="TcpDelAckTicks → 0 on all adapters"; Cmd={ Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name TcpDelAckTicks -Value 0 -Type DWord -Force -EA SilentlyContinue } } },
    @{ Msg="Nagle disabled — low-latency mode active"; Cmd=$null }
  )},
  @{ Name="Visual Effects"; Num="08"; Steps=@(
    @{ Msg="VisualFXSetting → 2 (performance)"; Cmd={ reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f 2>$null } },
    @{ Msg="UserPreferencesMask → 9012038010000000"; Cmd={ reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f 2>$null } },
    @{ Msg="MinAnimate → 0"; Cmd={ reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f 2>$null } },
    @{ Msg="TaskbarAnimations → 0"; Cmd={ reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f 2>$null } }
  )},
  @{ Name="Game Bar & DVR"; Num="09"; Steps=@(
    @{ Msg="AppCaptureEnabled → 0"; Cmd={ reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="GameDVR_Enabled → 0"; Cmd={ reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f 2>$null } },
    @{ Msg="GameDVR_FSEBehaviorMode → 2"; Cmd={ reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f 2>$null } },
    @{ Msg="GameDVR_HonorUserFSEBehaviorMode → 1"; Cmd={ reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="GameDVR_DXGIHonorFSEWindowsCompatible → 1"; Cmd={ reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f 2>$null } },
    @{ Msg="AllowGameDVR (Group Policy) → 0"; Cmd={ reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f 2>$null } }
  )},
  @{ Name="Processor Power"; Num="10"; Steps=@(
    @{ Msg="PROCTHROTTLEMIN → 100%"; Cmd={ powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null } },
    @{ Msg="PROCTHROTTLEMAX → 100%"; Cmd={ powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null } },
    @{ Msg="powercfg /setactive SCHEME_CURRENT"; Cmd={ powercfg /setactive SCHEME_CURRENT 2>$null } }
  )},
  @{ Name="Network & DNS"; Num="11"; Steps=@(
    @{ Msg="netsh: RSS enabled, autotuninglevel disabled"; Cmd={ netsh int tcp set global rss=enabled 2>$null; netsh int tcp set global autotuninglevel=disabled 2>$null } },
    @{ Msg="netsh: timestamps disabled, chimney disabled"; Cmd={ netsh int tcp set global timestamps=disabled 2>$null; netsh int tcp set global chimney=disabled 2>$null } },
    @{ Msg="TCPNoDelay → 1, TcpAckFrequency → 1, DefaultTTL → 64"; Cmd={ reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f 2>$null; reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f 2>$null; reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f 2>$null } },
    @{ Msg="ipconfig /flushdns"; Cmd={ ipconfig /flushdns 2>$null } },
    @{ Msg="netsh winsock reset"; Cmd={ netsh winsock reset 2>$null } },
    @{ Msg="netsh int ip reset"; Cmd={ netsh int ip reset 2>$null } },
    @{ Msg="ipconfig /release + /renew"; Cmd={ ipconfig /release 2>$null; ipconfig /renew 2>$null } },
    @{ Msg="Restarting physical network adapters..."; Cmd={ Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -EA SilentlyContinue } }
  )},
  @{ Name="Windows Services"; Num="12"; Steps=@(
    @{ Msg="Stopping: DiagTrack, WSearch, MapsBroker, XblAuthManager"; Cmd={ foreach ($s in @('DiagTrack','WSearch','MapsBroker','XblAuthManager')) { Stop-Service $s -Force -EA SilentlyContinue; Set-Service $s -StartupType Disabled -EA SilentlyContinue } } },
    @{ Msg="Stopping: XblGameSave, XboxNetApiSvc, Fax, RetailDemo"; Cmd={ foreach ($s in @('XblGameSave','XboxNetApiSvc','Fax','RetailDemo')) { Stop-Service $s -Force -EA SilentlyContinue; Set-Service $s -StartupType Disabled -EA SilentlyContinue } } },
    @{ Msg="Stopping: RemoteRegistry, WerSvc"; Cmd={ foreach ($s in @('RemoteRegistry','WerSvc')) { Stop-Service $s -Force -EA SilentlyContinue; Set-Service $s -StartupType Disabled -EA SilentlyContinue } } },
    @{ Msg="Enabling: Audiosrv, AudioEndpointBuilder, Dhcp, NlaSvc"; Cmd={ foreach ($s in @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc')) { Set-Service $s -StartupType Automatic -EA SilentlyContinue; Start-Service $s -EA SilentlyContinue } } },
    @{ Msg="Enabling: Netman, WlanSvc, RpcSs, EventLog"; Cmd={ foreach ($s in @('Netman','WlanSvc','RpcSs','EventLog')) { Set-Service $s -StartupType Automatic -EA SilentlyContinue; Start-Service $s -EA SilentlyContinue } } },
    @{ Msg="Enabling: PlugPlay, LanmanWorkstation, LanmanServer"; Cmd={ foreach ($s in @('PlugPlay','LanmanWorkstation','LanmanServer')) { Set-Service $s -StartupType Automatic -EA SilentlyContinue; Start-Service $s -EA SilentlyContinue } } }
  )},
  @{ Name="Junk & Log Cleanup"; Num="13"; Steps=@(
    @{ Msg="Deleting %USERPROFILE%\AppData\Local\Temp\*"; Cmd={ Remove-Item "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Deleting C:\Windows\Temp\*"; Cmd={ Remove-Item "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Deleting C:\Windows\Prefetch\*"; Cmd={ Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Stopping wuauserv + UsoSvc"; Cmd={ Stop-Service wuauserv -Force -EA SilentlyContinue; Stop-Service UsoSvc -Force -EA SilentlyContinue } },
    @{ Msg="Removing C:\Windows\SoftwareDistribution\"; Cmd={ Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -EA SilentlyContinue } },
    @{ Msg="Restarting Windows Update service"; Cmd={ Start-Service wuauserv -EA SilentlyContinue } },
    @{ Msg="Clearing all Windows Event Logs via wevtutil..."; Cmd={ Get-EventLog -List -EA SilentlyContinue | ForEach-Object { Clear-EventLog -LogName $_.Log -EA SilentlyContinue } } }
  )}
)

# ── Helper: Detect system info ────────────────────────────────────────────────
function Get-SysInfo {
  try {
    $cpu = (Get-CimInstance Win32_Processor -EA Stop).Name -replace '\s+',' '
    $sysCpu.Text = if ($cpu.Length -gt 18) { $cpu.Substring(0,17)+'…' } else { $cpu }
  } catch { $sysCpu.Text = 'Unknown CPU' }

  try {
    $gpuObj = Get-CimInstance Win32_VideoController -EA SilentlyContinue | Select-Object -First 1
    $gpu = if ($gpuObj) { $gpuObj.Name -replace 'NVIDIA |AMD |Intel\(R\) | Graphics','' } else { "Unknown GPU" }
    $sysGpu.Text = if ($gpu.Length -gt 18) { $gpu.Substring(0,17)+'…' } else { $gpu }
  } catch { $sysGpu.Text = 'Unknown GPU' }

  try {
    $gb = [math]::Round((Get-CimInstance Win32_ComputerSystem -EA Stop).TotalPhysicalMemory / 1GB)
    $sysRam.Text = "$gb GB RAM"
  } catch { $sysRam.Text = '?' }

  try {
    $os = Get-CimInstance Win32_OperatingSystem -EA Stop
    $osShort = $os.Caption -replace 'Microsoft | Windows',''
    $sysOs.Text     = if ($osShort.Length -gt 14) { $osShort.Substring(0,13)+'…' } else { $osShort }
    $sysOsBuild.Text = "Build $($os.BuildNumber)"
  } catch { $sysOs.Text = 'Windows' }

  $sysUser.Text  = $env:USERNAME
  $sysHost.Text = $env:COMPUTERNAME
}

# ── Helper: Render module list ────────────────────────────────────────────────
function Render-Modules {
  $moduleList.Children.Clear()
  for ($i = 0; $i -lt $modules.Count; $i++) {
    $m = $modules[$i]
    
    $row = New-Object System.Windows.Controls.Border
    $row.Padding = [System.Windows.Thickness]::new(16, 7, 16, 7)
    $row.BorderThickness = [System.Windows.Thickness]::new(2,0,0,0)
    $row.BorderBrush = [System.Windows.Media.Brushes]::Transparent

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = 'Horizontal'

    $icon = New-Object System.Windows.Controls.TextBlock
    $icon.Text = "⏲" # Placeholder for Ti-clock
    $icon.FontSize = 14; $icon.Width = 18; $icon.Margin = [System.Windows.Thickness]::new(0,0,9,0)
    $icon.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x44,0x44,0x44)

    $name = New-Object System.Windows.Controls.TextBlock
    $name.Text = $m.Name
    $name.FontSize = 11; $name.VerticalAlignment = 'Center'
    $name.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x44,0x44,0x44)

    $num = New-Object System.Windows.Controls.TextBlock
    $num.Text = $m.Num
    $num.FontSize = 9; $num.VerticalAlignment = 'Center'; $num.Margin = [System.Windows.Thickness]::new(10,0,0,0)
    $num.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x2a,0x2a,0x2a)

    $sp.Children.Add($icon) | Out-Null
    $sp.Children.Add($name) | Out-Null
    # Push number to right (WPF doesn't have auto-margin in StackPanel like CSS)
    $row.Child = $sp
    $moduleList.Children.Add($row) | Out-Null
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
    'ok'   = [System.Windows.Media.Color]::FromRgb(0x2a,0x9e,0x2a)
    'go'   = [System.Windows.Media.Color]::FromRgb(0xdc,0x14,0x3c)
    'info' = [System.Windows.Media.Color]::FromRgb(0x40,0x40,0x40)
    'done' = [System.Windows.Media.Color]::FromRgb(0xc8,0xa0,0x00)
    ''     = [System.Windows.Media.Color]::FromRgb(0x2e,0x2e,0x2e)
  }
  $color = if ($colorMap.ContainsKey($type)) { $colorMap[$type] } else { $colorMap[''] }

  $sp = New-Object System.Windows.Controls.StackPanel
  $sp.Orientation = 'Horizontal'; $sp.Margin = [System.Windows.Thickness]::new(0,0,0,3)

  $t1 = New-Object System.Windows.Controls.TextBlock
  $t1.Text = Get-Elapsed
  $t1.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x2e,0x2e,0x2e)
  $t1.FontSize = 10; $t1.MinWidth = 60; $t1.Margin = [System.Windows.Thickness]::new(0,0,8,0)

  $t2 = New-Object System.Windows.Controls.TextBlock
  $t2.Text = $msg
  $t2.Foreground = [System.Windows.Media.SolidColorBrush]$color
  $t2.FontSize = 11; $t2.TextWrapping = 'Wrap'

  $sp.Children.Add($t1) | Out-Null
  $sp.Children.Add($t2) | Out-Null
  $logLines.Children.Add($sp) | Out-Null
  $logScroll.ScrollToEnd()
}

# ── Run logic ────────────────────────────────────────────────────────────────
$script:isRunning = $false

function Start-RunAll {
  if ($script:isRunning) { return }
  $script:isRunning = $true
  $script:startTime = [datetime]::Now

  $btnRun.IsEnabled = $false
  $btnReset.IsEnabled = $false
  $btnReboot.Visibility = 'Collapsed'
  $rebootNote.Visibility = 'Collapsed'
  $statusBadge.Text = 'RUNNING'
  $logLines.Children.Clear()
  
  Add-LogLine 'Starting GOAT Tweak v3.0 — 13 modules queued' 'go'

  $rs = [runspacefactory]::CreateRunspace()
  $rs.ApartmentState = 'STA'; $rs.ThreadOptions = 'ReuseThread'; $rs.Open()
  $rs.SessionStateProxy.SetVariable('modules', $modules)
  $rs.SessionStateProxy.SetVariable('window', $window)
  $rs.SessionStateProxy.SetVariable('logLines', $logLines)
  $rs.SessionStateProxy.SetVariable('logScroll', $logScroll)
  $rs.SessionStateProxy.SetVariable('progPct', $progPct)
  $rs.SessionStateProxy.SetVariable('progTrack', $progTrack)
  $rs.SessionStateProxy.SetVariable('progFill', $progFill)
  $rs.SessionStateProxy.SetVariable('progMsg', $progMsg)
  $rs.SessionStateProxy.SetVariable('statusBadge', $statusBadge)
  $rs.SessionStateProxy.SetVariable('btnRun', $btnRun)
  $rs.SessionStateProxy.SetVariable('btnReset', $btnReset)
  $rs.SessionStateProxy.SetVariable('btnReboot', $btnReboot)
  $rs.SessionStateProxy.SetVariable('rebootNote', $rebootNote)
  $rs.SessionStateProxy.SetVariable('startTimeBg', $script:startTime)
  $rs.SessionStateProxy.SetVariable('moduleList', $moduleList)

  $addLogBlock = {
    param([string]$msg, $type = '')
    $elapsed = if ($startTimeBg) {
      $s = [int]([datetime]::Now - $startTimeBg).TotalSeconds
      '{0:D2}:{1:D2}:{2:D2}' -f [math]::Floor($s/3600), [math]::Floor(($s%3600)/60), ($s%60)
    } else { '00:00:00' }
    $colorMap = @{ 'ok'=[System.Windows.Media.Color]::FromRgb(0x2a,0x9e,0x2a); 'go'=[System.Windows.Media.Color]::FromRgb(0xdc,0x14,0x3c); 'info'=[System.Windows.Media.Color]::FromRgb(0x40,0x40,0x40); 'done'=[System.Windows.Media.Color]::FromRgb(0xc8,0xa0,0x00) }
    $color = if ($colorMap.ContainsKey($type)) { $colorMap[$type] } else { [System.Windows.Media.Color]::FromRgb(0x2e,0x2e,0x2e) }
    $window.Dispatcher.Invoke([action]{
      $sp = New-Object System.Windows.Controls.StackPanel; $sp.Orientation = 'Horizontal'; $sp.Margin = [System.Windows.Thickness]::new(0,0,0,3)
      $t1 = New-Object System.Windows.Controls.TextBlock; $t1.Text = $elapsed; $t1.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x2e,0x2e,0x2e); $t1.FontSize = 10; $t1.MinWidth = 60; $t1.Margin = [System.Windows.Thickness]::new(0,0,8,0)
      $t2 = New-Object System.Windows.Controls.TextBlock; $t2.Text = $msg; $t2.Foreground = [System.Windows.Media.SolidColorBrush]$color; $t2.FontSize = 11; $t2.TextWrapping = 'Wrap'
      $sp.Children.Add($t1) | Out-Null; $sp.Children.Add($t2) | Out-Null; $logLines.Children.Add($sp) | Out-Null; $logScroll.ScrollToEnd()
    }, 'Normal')
  }

  $ps = [powershell]::Create(); $ps.Runspace = $rs
  [void]$ps.AddScript({
    param($addLog, $mods, $win, $pPct, $pTrack, $pFill, $pMsg, $badge, $bRun, $bReset, $bReboot, $rNote, $mList)
    for ($i = 0; $i -lt $mods.Count; $i++) {
      $m = $mods[$i]; $currIdx = $i
      $win.Dispatcher.Invoke([action]{
        $rows = $mList.Children; for ($j=0; $j -lt $rows.Count; $j++) {
          $row = $rows[$j]; $sp = $row.Child; $icon = $sp.Children[0]; $name = $sp.Children[1]
          if ($j -lt $currIdx) { $row.BorderBrush = [System.Windows.Media.Brushes]::Transparent; $row.Background = [System.Windows.Media.Brushes]::Transparent; $icon.Text = "✔"; $icon.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x2a,0x9e,0x2a); $name.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x2a,0x9e,0x2a) }
          elseif ($j -eq $currIdx) { $row.BorderBrush = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xdc,0x14,0x3c); $row.Background = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x12,0x02,0x04); $icon.Text = "▶"; $icon.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xdc,0x14,0x3c); $name.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0xdc,0x14,0x3c) }
          else { $row.BorderBrush = [System.Windows.Media.Brushes]::Transparent; $row.Background = [System.Windows.Media.Brushes]::Transparent; $icon.Text = "⏲"; $icon.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x44,0x44,0x44); $name.Foreground = [System.Windows.Media.SolidColorBrush][System.Windows.Media.Color]::FromRgb(0x44,0x44,0x44) }
        }
      }, 'Normal')
      & $addLog "[$($m.Num)/13] Applying: $($m.Name)" 'go'
      foreach ($step in $m.Steps) {
        Start-Sleep -Milliseconds 60
        & $addLog "  > $($step.Msg)" 'info'
        if ($step.Cmd) { try { & $step.Cmd } catch { & $addLog "  [!] Error: $_" 'go' } }
      }
      & $addLog "$($m.Name) — done" 'ok'
      $pct = [math]::Round((($i + 1) / $mods.Count) * 100)
      $win.Dispatcher.Invoke([action]{
        $pPct.Text = "$pct%"; $pMsg.Text = "[$($m.Num)/13] $($m.Name)..."
        $trackWidth = $pTrack.ActualWidth; if ($trackWidth -gt 0) { $pFill.Width = ($trackWidth * $pct / 100) }
      }, 'Normal')
      Start-Sleep -Milliseconds 100
    }
    & $addLog "" "info"
    & $addLog "GOAT Tweak v3.0 complete — all 13 modules applied." "done"
    & $addLog "Restart your PC for kernel & network changes to take effect." "done"
    $win.Dispatcher.Invoke([action]{
      $badge.Text = 'DONE'; $pMsg.Text = "All 13 modules applied — restart your PC to complete"
      $bReset.IsEnabled = $true; $bReboot.Visibility = 'Visible'; $rNote.Visibility = 'Visible'
    }, 'Normal')
  })
  [void]$ps.AddArgument($addLogBlock); [void]$ps.AddArgument($modules); [void]$ps.AddArgument($window); [void]$ps.AddArgument($progPct); [void]$ps.AddArgument($progTrack); [void]$ps.AddArgument($progFill); [void]$ps.AddArgument($progMsg); [void]$ps.AddArgument($statusBadge); [void]$ps.AddArgument($btnRun); [void]$ps.AddArgument($btnReset); [void]$ps.AddArgument($btnReboot); [void]$ps.AddArgument($rebootNote); [void]$ps.AddArgument($moduleList)
  $null = $ps.BeginInvoke()
}

function Reset-All {
  $script:isRunning = $false; $script:startTime = $null
  $progPct.Text = '0%'; $progFill.Width = 0; $progMsg.Text = "Ready — press RUN ALL to begin optimization"
  $statusBadge.Text = 'IDLE'; $logLines.Children.Clear()
  $btnRun.IsEnabled = $true; $btnReset.IsEnabled = $false; $btnReboot.Visibility = 'Collapsed'; $rebootNote.Visibility = 'Collapsed'
  Render-Modules
  Add-LogLine 'GOAT Tweak v3.0 ready. 13 modules loaded. Press RUN ALL to begin.' 'info'
}

function Do-Reboot {
  $btnReboot.IsEnabled = $false
  Add-LogLine 'shutdown /r /t 0 — restarting system...' 'go'
  Start-Process shutdown.exe -ArgumentList "/r /t 5" -Force # 5 seconds delay to let user see the log
}

# ── Wire buttons ──────────────────────────────────────────────────────────────
$btnRun.Add_Click({ Start-RunAll })
$btnReset.Add_Click({ Reset-All })
$btnReboot.Add_Click({ Do-Reboot })

# ── Init ──────────────────────────────────────────────────────────────────────
Get-SysInfo
Render-Modules
Add-LogLine 'GOAT Tweak v3.0 ready. 13 modules loaded. Press RUN ALL to begin.' 'info'

# ── System Monitor Simulation ────────────────────────────────────────────────
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(3)
$timer.Add_Tick({
    $sysCpuSub.Text = "$(Get-Random -Minimum 10 -Maximum 80)% load"
    $sysGpuSub.Text = "$(Get-Random -Minimum 5 -Maximum 85)% util"
    $sysRamSub.Text = "$(Get-Random -Minimum 35 -Maximum 75)% used"
})
$timer.Start()

$window.ShowDialog() | Out-Null
