#Requires -Version 5.1
<#
    GOAT - GREATEST OF ALL TWEAKS
    GUI Edition v2.0 - WebView2 / Red-Black Theme
#>

# ── ADMIN CHECK ────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $ps = New-Object System.Diagnostics.ProcessStartInfo "powershell"
    $ps.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $ps.Verb = "runas"
    try { [System.Diagnostics.Process]::Start($ps) | Out-Null } catch {}
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── WEBVIEW2 CHECK & LOAD ──────────────────────────────────────────────────
$wv2Dll = $null
$searchPaths = @(
    "$env:ProgramFiles\Microsoft\EdgeWebView\Application",
    "$env:ProgramFiles(x86)\Microsoft\EdgeWebView\Application",
    "$env:LOCALAPPDATA\Microsoft\EdgeWebView\Application",
    "$env:ProgramFiles\Microsoft\Edge\Application",
    "$env:ProgramFiles(x86)\Microsoft\Edge\Application"
)
foreach ($base in $searchPaths) {
    if (Test-Path $base) {
        $found = Get-ChildItem $base -Recurse -Filter "Microsoft.Web.WebView2.WinForms.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $wv2Dll = $found.FullName; break }
    }
}
# Also check NuGet / script dir
$nugetPaths = @(
    "$PSScriptRoot\Microsoft.Web.WebView2.WinForms.dll",
    "$env:TEMP\WebView2\Microsoft.Web.WebView2.WinForms.dll"
)
foreach ($p in $nugetPaths) { if (Test-Path $p) { $wv2Dll = $p; break } }

$useWebView2 = $false
if ($wv2Dll) {
    try {
        Add-Type -Path $wv2Dll -ErrorAction Stop
        $useWebView2 = $true
    } catch { $useWebView2 = $false }
}

# ── SYSTEM INFO ────────────────────────────────────────────────────────────
$CPU      = (Get-CimInstance Win32_Processor).Name
$CPULoad  = [int](Get-CimInstance Win32_Processor).LoadPercentage
$RAMTotal = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$RAMFree  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$RAMUsed  = [math]::Round($RAMTotal - $RAMFree, 1)
$RAMPct   = [math]::Round(($RAMUsed / $RAMTotal) * 100)
$OSName   = (Get-CimInstance Win32_OperatingSystem).Caption

# ── OPTIMIZATION FUNCTIONS ─────────────────────────────────────────────────
function Invoke-Kernel {
    bcdedit /set useplatformclock no 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set nx OptOut 2>$null | Out-Null
    $hpet = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision*" } -ErrorAction SilentlyContinue
    if ($hpet) { Disable-PnpDevice -InstanceId $hpet.InstanceId -Confirm:$false -ErrorAction SilentlyContinue }
}
function Invoke-TimerResolution {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force 2>$null
}
function Invoke-IRQ {
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -ErrorAction SilentlyContinue | ForEach-Object {
        $p = "$($_.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (Test-Path $p) { Set-ItemProperty -Path $p -Name "MSISupported" -Value 1 -Type DWord -Force 2>$null }
    }
}
function Invoke-Nagle {
    $iP = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem $iP -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force 2>$null
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force 2>$null
    }
}
function Invoke-VisualEffects {
    $vp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vp)) { New-Item -Path $vp -Force | Out-Null }
    Set-ItemProperty -Path $vp -Name "VisualFXSetting" -Value 2 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force 2>$null
}
function Invoke-GameBar {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force 2>$null
    $gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "AllowGameDVR" -Value 0 -Type DWord -Force 2>$null
}
function Invoke-ProcessorPower {
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
    powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null
}
function Invoke-Priority {
    $sp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $gp = "$sp\Tasks\Games"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 0x2a -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "SystemResponsiveness"   -Value 0          -Type DWord -Force 2>$null
    Set-ItemProperty -Path $sp -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force 2>$null
    if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
    Set-ItemProperty -Path $gp -Name "GPU Priority"        -Value 8      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Priority"            -Value 6      -Type DWord  -Force 2>$null
    Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Type String -Force 2>$null
    Set-ItemProperty -Path $gp -Name "SFIO Priority"       -Value "High" -Type String -Force 2>$null
}
function Invoke-Memory {
    $mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty -Path $mp -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown"       -Value 0 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "$mp\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force 2>$null
    powercfg -h off 2>$null | Out-Null
    taskkill /f /im OneDrive.exe 2>$null | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
}
function Invoke-Input {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize"    -Value 16 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force 2>$null
    $pt = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $pt)) { New-Item -Path $pt -Force | Out-Null }
    Set-ItemProperty -Path $pt -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed"      -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"  -Type String -Force 2>$null
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Type String -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB"    -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb" -Name "IdleEnable"              -Value 0 -Type DWord -Force 2>$null
}
function Invoke-Network {
    netsh int tcp set global rss=enabled           2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled    2>$null | Out-Null
    netsh int tcp set global chimney=disabled       2>$null | Out-Null
    $tp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $tp -Name "TCPNoDelay"      -Value 1  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $tp -Name "TcpAckFrequency" -Value 1  -Type DWord -Force 2>$null
    Set-ItemProperty -Path $tp -Name "DefaultTTL"      -Value 64 -Type DWord -Force 2>$null
    Clear-DnsClientCache -ErrorAction SilentlyContinue | Out-Null
    netsh winsock reset 2>$null | Out-Null
    netsh int ip reset  2>$null | Out-Null
    ipconfig /release   2>$null | Out-Null
    ipconfig /renew     2>$null | Out-Null
    Get-NetAdapter | Where-Object { $_.Physical } | Restart-NetAdapter -ErrorAction SilentlyContinue
}
function Invoke-Services {
    @('DiagTrack','WSearch','MapsBroker','XblAuthManager','XblGameSave','XboxNetApiSvc','Fax','RetailDemo','RemoteRegistry','WerSvc') | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    @('Audiosrv','AudioEndpointBuilder','Dhcp','NlaSvc','Netman','WlanSvc','RpcSs','EventLog','PlugPlay','LanmanWorkstation','LanmanServer') | ForEach-Object {
        Set-Service   -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
}
function Invoke-Cleanup {
    @("$env:USERPROFILE\AppData\Local\Temp\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*") | ForEach-Object {
        Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Stop-Service -Name wuauserv,UsoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    wevtutil.exe el | ForEach-Object { wevtutil.exe cl "$_" 2>$null }
}

# ── TASK MAP ───────────────────────────────────────────────────────────────
$script:Tasks = [ordered]@{
    "kernel"     = @{ Label="Kernel and HPET";    Fn={ Invoke-Kernel } }
    "timer"      = @{ Label="Timer Resolution";   Fn={ Invoke-TimerResolution } }
    "priority"   = @{ Label="Process Priority";   Fn={ Invoke-Priority } }
    "irq"        = @{ Label="IRQ MSI Mode";       Fn={ Invoke-IRQ } }
    "memory"     = @{ Label="Memory Management";  Fn={ Invoke-Memory } }
    "input"      = @{ Label="Input and USB";      Fn={ Invoke-Input } }
    "nagle"      = @{ Label="Nagle Algorithm";    Fn={ Invoke-Nagle } }
    "visual"     = @{ Label="Visual Effects";     Fn={ Invoke-VisualEffects } }
    "gamebar"    = @{ Label="Game Bar and DVR";   Fn={ Invoke-GameBar } }
    "power"      = @{ Label="Processor Power";    Fn={ Invoke-ProcessorPower } }
    "network"    = @{ Label="Network and DNS";    Fn={ Invoke-Network } }
    "services"   = @{ Label="Windows Services";   Fn={ Invoke-Services } }
    "cleanup"    = @{ Label="Junk and Log Cleanup"; Fn={ Invoke-Cleanup } }
}

# ── HTML UI ────────────────────────────────────────────────────────────────
$taskRowsHtml = ""
foreach ($key in $script:Tasks.Keys) {
    $label = $script:Tasks[$key].Label
    $taskRowsHtml += @"
<div class="task-row" id="row-$key">
  <span class="task-icon" id="icon-$key">--</span>
  <span class="task-name" id="name-$key">$label</span>
  <div class="task-bar-track"><div class="task-bar-fill" id="bar-$key"></div></div>
  <span class="task-status" id="status-$key">PENDING</span>
</div>
"@
}

$cpuShort = if ($CPU.Length -gt 38) { $CPU.Substring(0,38) + "..." } else { $CPU }
$osShort  = if ($OSName.Length -gt 28) { $OSName.Substring(0,28) + "..." } else { $OSName }

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>GOAT</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Rajdhani:wght@500;700&display=swap');
  *{box-sizing:border-box;margin:0;padding:0;}
  html,body{height:100%;background:#000;color:#cc2200;font-family:'Share Tech Mono',monospace;overflow:hidden;}
  ::-webkit-scrollbar{width:4px;}
  ::-webkit-scrollbar-track{background:#0a0000;}
  ::-webkit-scrollbar-thumb{background:#500;}

  .topbar{background:#080000;border-bottom:1px solid #3a0000;padding:5px 14px;display:flex;align-items:center;gap:8px;-webkit-app-region:drag;user-select:none;}
  .dot{width:11px;height:11px;border-radius:50%;cursor:pointer;-webkit-app-region:no-drag;}
  .dot-r{background:#c0392b;} .dot-y{background:#2c2c2c;} .dot-g{background:#2c2c2c;}
  .dot-r:hover{background:#e74c3c;}
  .topbar-title{flex:1;text-align:center;font-size:10px;color:#500;letter-spacing:3px;}
  .version-badge{font-size:10px;color:#600;border:1px solid #300;padding:1px 8px;-webkit-app-region:no-drag;}

  .header{background:#050000;border-bottom:2px solid #c0392b;padding:14px 18px 10px;display:flex;justify-content:space-between;align-items:center;}
  .logo{font-family:'Rajdhani',sans-serif;font-size:30px;font-weight:700;color:#cc2200;letter-spacing:6px;}
  .logo-sub{font-size:9px;color:#600;letter-spacing:3px;margin-top:1px;}
  .header-right{text-align:right;}
  .ts{font-size:10px;color:#500;letter-spacing:1px;}

  .sysbar{background:#060000;border-bottom:1px solid #2a0000;padding:8px 18px;display:grid;grid-template-columns:repeat(3,1fr);gap:10px;}
  .sys-item .sys-label{font-size:9px;color:#600;letter-spacing:2px;}
  .sys-item .sys-val{font-size:11px;color:#cc2200;margin:2px 0;}
  .sys-bar-track{height:2px;background:#1a0000;}
  .sys-bar-fill{height:2px;background:#c0392b;transition:width 1s;}

  .modules{padding:7px 18px;display:flex;flex-wrap:wrap;gap:5px;border-bottom:1px solid #200;background:#040000;}
  .mod{border:1px solid #300;color:#600;font-size:9px;letter-spacing:2px;padding:2px 8px;cursor:default;}
  .mod.active{border-color:#c0392b;color:#cc2200;background:#0d0000;}

  .content{padding:12px 18px;overflow-y:auto;height:calc(100vh - 320px);}
  .section-label{font-size:9px;color:#500;letter-spacing:3px;margin-bottom:8px;border-left:2px solid #c0392b;padding-left:7px;}

  .task-row{display:grid;grid-template-columns:30px 1fr 90px 70px;align-items:center;gap:8px;padding:6px 0;border-bottom:1px solid #0d0000;}
  .task-icon{font-size:11px;color:#400;text-align:center;}
  .task-icon.done{color:#1a7a1a;} .task-icon.running{color:#c0392b;} .task-icon.waiting{color:#400;}
  .task-name{font-size:11px;color:#400;}
  .task-name.done{color:#444;} .task-name.running{color:#fff;} .task-name.waiting{color:#400;}
  .task-bar-track{height:2px;background:#111;}
  .task-bar-fill{height:2px;background:#c0392b;width:0%;transition:width 0.4s;}
  .task-bar-fill.done{background:#1a5c1a;width:100%;}
  .task-bar-fill.running{background:#c0392b;animation:pulse 1s ease-in-out infinite alternate;}
  @keyframes pulse{from{width:30%;}to{width:80%;}}
  .task-status{font-size:9px;text-align:right;letter-spacing:1px;color:#300;}
  .task-status.done{color:#1a7a1a;} .task-status.running{color:#c0392b;animation:blink 0.7s step-end infinite;}
  @keyframes blink{0%,100%{opacity:1;}50%{opacity:0;}}

  .footer{padding:10px 18px;border-top:1px solid #200;background:#040000;display:grid;grid-template-columns:1fr auto auto;gap:8px;align-items:center;}
  .overall-label{font-size:9px;color:#500;letter-spacing:2px;margin-bottom:4px;}
  .overall-track{height:4px;background:#111;}
  .overall-fill{height:4px;background:#c0392b;width:0%;transition:width 0.5s;}
  .overall-pct{font-size:20px;color:#c0392b;font-weight:700;min-width:50px;text-align:right;}

  .btn{font-family:'Share Tech Mono',monospace;font-size:11px;letter-spacing:2px;padding:8px 18px;border:none;cursor:pointer;transition:background 0.2s;}
  .btn-run{background:#c0392b;color:#000;}
  .btn-run:hover{background:#e74c3c;}
  .btn-run:disabled{background:#3a0000;color:#500;cursor:not-allowed;}
  .btn-restart{background:transparent;color:#600;border:1px solid #400;display:none;}
  .btn-restart:hover{border-color:#c0392b;color:#c0392b;}

  .done-banner{display:none;background:#0a0000;border:1px solid #c0392b;color:#c0392b;text-align:center;padding:10px;margin:10px 0;font-size:13px;letter-spacing:3px;}
</style>
</head>
<body>

<div class="topbar">
  <div class="dot dot-r" onclick="window.chrome && window.chrome.webview ? window.chrome.webview.postMessage('close') : window.close()" title="Close"></div>
  <div class="dot dot-y"></div>
  <div class="dot dot-g"></div>
  <div class="topbar-title">GOAT // GREATEST OF ALL TWEAKS</div>
  <div class="version-badge">v2.0</div>
</div>

<div class="header">
  <div>
    <div class="logo">G O A T</div>
    <div class="logo-sub">GREATEST OF ALL TWEAKS // GUI EDITION</div>
  </div>
  <div class="header-right">
    <div class="ts" id="clock">--:--:--</div>
    <div class="ts" id="datestamp">----/--/--</div>
  </div>
</div>

<div class="sysbar">
  <div class="sys-item">
    <div class="sys-label">CPU</div>
    <div class="sys-val">$cpuShort</div>
    <div class="sys-bar-track"><div class="sys-bar-fill" style="width:$CPULoad%"></div></div>
  </div>
  <div class="sys-item">
    <div class="sys-label">RAM</div>
    <div class="sys-val">$RAMUsed GB / $RAMTotal GB DDR</div>
    <div class="sys-bar-track"><div class="sys-bar-fill" style="width:$RAMPct%"></div></div>
  </div>
  <div class="sys-item">
    <div class="sys-label">OS</div>
    <div class="sys-val">$osShort</div>
    <div class="sys-bar-track"><div class="sys-bar-fill" style="width:100%"></div></div>
  </div>
</div>

<div class="modules" id="modbar">
  <div class="mod active">KERNEL</div>
  <div class="mod active">MEMORY</div>
  <div class="mod active">INPUT</div>
  <div class="mod active">NETWORK</div>
  <div class="mod active">IRQ/MSI</div>
  <div class="mod active">POWER</div>
  <div class="mod active">SERVICES</div>
  <div class="mod active">CLEANER</div>
</div>

<div class="content">
  <div class="section-label">OPTIMIZATION MODULES</div>
  <div id="task-list">
$taskRowsHtml
  </div>
  <div class="done-banner" id="done-banner">== ALL TWEAKS COMPLETED ==</div>
</div>

<div class="footer">
  <div>
    <div class="overall-label">OVERALL PROGRESS</div>
    <div class="overall-track"><div class="overall-fill" id="overall-fill"></div></div>
  </div>
  <div class="overall-pct" id="overall-pct">0%</div>
  <div style="display:flex;gap:8px;">
    <button class="btn btn-restart" id="btn-restart" onclick="restartPC()">RESTART PC</button>
    <button class="btn btn-run" id="btn-run" onclick="startOpt()">RUN GOAT</button>
  </div>
</div>

<script>
  const taskKeys = [$(($script:Tasks.Keys | ForEach-Object { "'$_'" }) -join ',')];
  const total = taskKeys.length;

  function tick(){
    const n=new Date();
    document.getElementById('clock').textContent=n.toLocaleTimeString('en-GB');
    document.getElementById('datestamp').textContent=n.toLocaleDateString('en-CA');
  }
  tick(); setInterval(tick,1000);

  function setTask(key, state){
    const icon=document.getElementById('icon-'+key);
    const name=document.getElementById('name-'+key);
    const bar=document.getElementById('bar-'+key);
    const status=document.getElementById('status-'+key);
    icon.className='task-icon '+state;
    name.className='task-name '+state;
    bar.className='task-bar-fill '+state;
    if(state==='done'){icon.textContent='OK';status.textContent='DONE';status.className='task-status done';}
    else if(state==='running'){icon.textContent='>>';status.textContent='RUNNING...';status.className='task-status running';}
    else{icon.textContent='--';status.textContent='PENDING';status.className='task-status';}
  }

  function setProgress(done){
    const pct=Math.round(done/total*100);
    document.getElementById('overall-fill').style.width=pct+'%';
    document.getElementById('overall-pct').textContent=pct+'%';
  }

  function startOpt(){
    document.getElementById('btn-run').disabled=true;
    if(window.chrome && window.chrome.webview){
      window.chrome.webview.postMessage('start');
    }
  }

  function restartPC(){
    if(window.chrome && window.chrome.webview){
      window.chrome.webview.postMessage('restart');
    }
  }

  window.updateTask = function(key, state){ setTask(key, state); };
  window.updateProgress = function(done){ setProgress(done); };
  window.showDone = function(){
    document.getElementById('done-banner').style.display='block';
    document.getElementById('btn-restart').style.display='inline-block';
  };
</script>
</body>
</html>
"@

# ── FORM ───────────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "GOAT // GREATEST OF ALL TWEAKS"
$form.Size            = New-Object System.Drawing.Size(860, 680)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = [System.Drawing.Color]::Black
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.Icon            = [System.Drawing.SystemIcons]::Application

# drag support for borderless window
$script:dragging = $false
$script:dragStart = [System.Drawing.Point]::Empty

if ($useWebView2) {
    # ── WEBVIEW2 PATH ──────────────────────────────────────────────────────
    $wv = New-Object Microsoft.Web.WebView2.WinForms.WebView2
    $wv.Dock = [System.Windows.Forms.DockStyle]::Fill
    $form.Controls.Add($wv)

    $wv.add_CoreWebView2InitializationCompleted({
        $wv.CoreWebView2.NavigateToString($html)
    })

    $wv.add_WebMessageReceived({
        param($s, $e)
        $msg = $e.TryGetWebMessageAsString()
        if ($msg -eq 'close') { $form.Close() }
        elseif ($msg -eq 'restart') { Restart-Computer -Force }
        elseif ($msg -eq 'start') {
            $bg = [System.ComponentModel.BackgroundWorker]::new()
            $bg.WorkerReportsProgress = $true
            $bg.add_DoWork({
                $done = 0
                foreach ($key in $script:Tasks.Keys) {
                    $bg.ReportProgress(0, @{ key=$key; state='running'; done=$done })
                    try { & $script:Tasks[$key].Fn } catch {}
                    $done++
                    $bg.ReportProgress(0, @{ key=$key; state='done'; done=$done })
                }
                $bg.ReportProgress(100, $null)
            })
            $bg.add_ProgressChanged({
                param($s2, $e2)
                if ($e2.ProgressPercentage -eq 100) {
                    $wv.CoreWebView2.ExecuteScriptAsync("window.showDone()") | Out-Null
                } else {
                    $d = $e2.UserState
                    $wv.CoreWebView2.ExecuteScriptAsync("window.updateTask('$($d.key)','$($d.state)')") | Out-Null
                    $wv.CoreWebView2.ExecuteScriptAsync("window.updateProgress($($d.done))") | Out-Null
                }
            })
            $bg.RunWorkerAsync()
        }
    })

    $wv.EnsureCoreWebView2Async($null) | Out-Null

} else {
    # ── FALLBACK: WinForms UI (ถ้าไม่มี WebView2) ─────────────────────────
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $panel.BackColor = [System.Drawing.Color]::Black
    $form.Controls.Add($panel)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "G O A T"
    $lbl.Font = New-Object System.Drawing.Font("Consolas", 28, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = [System.Drawing.Color]::Firebrick
    $lbl.AutoSize = $true
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $panel.Controls.Add($lbl)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = "GREATEST OF ALL TWEAKS // GUI EDITION"
    $sub.Font = New-Object System.Drawing.Font("Consolas", 9)
    $sub.ForeColor = [System.Drawing.Color]::DarkRed
    $sub.AutoSize = $true
    $sub.Location = New-Object System.Drawing.Point(32, 68)
    $panel.Controls.Add($sub)

    $sep = New-Object System.Windows.Forms.Panel
    $sep.BackColor = [System.Drawing.Color]::Firebrick
    $sep.Size = New-Object System.Drawing.Size(800, 2)
    $sep.Location = New-Object System.Drawing.Point(30, 90)
    $panel.Controls.Add($sep)

    $statusBox = New-Object System.Windows.Forms.RichTextBox
    $statusBox.Size = New-Object System.Drawing.Size(790, 440)
    $statusBox.Location = New-Object System.Drawing.Point(30, 100)
    $statusBox.BackColor = [System.Drawing.Color]::Black
    $statusBox.ForeColor = [System.Drawing.Color]::Firebrick
    $statusBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $statusBox.ReadOnly = $true
    $statusBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $panel.Controls.Add($statusBox)

    $btnRun = New-Object System.Windows.Forms.Button
    $btnRun.Text = "RUN GOAT"
    $btnRun.Size = New-Object System.Drawing.Size(140, 36)
    $btnRun.Location = New-Object System.Drawing.Point(680, 560)
    $btnRun.BackColor = [System.Drawing.Color]::Firebrick
    $btnRun.ForeColor = [System.Drawing.Color]::Black
    $btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnRun.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $panel.Controls.Add($btnRun)

    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Size = New-Object System.Drawing.Size(600, 8)
    $progress.Location = New-Object System.Drawing.Point(30, 572)
    $progress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progress.ForeColor = [System.Drawing.Color]::Firebrick
    $panel.Controls.Add($progress)

    $btnRun.Add_Click({
        $btnRun.Enabled = $false
        $statusBox.Clear()
        $bg = [System.ComponentModel.BackgroundWorker]::new()
        $bg.WorkerReportsProgress = $true
        $done = 0
        $bg.add_DoWork({
            foreach ($key in $script:Tasks.Keys) {
                $label = $script:Tasks[$key].Label
                $bg.ReportProgress([int]($done/$script:Tasks.Count*100), ">> $label...")
                try { & $script:Tasks[$key].Fn } catch {}
                $done++
                $bg.ReportProgress([int]($done/$script:Tasks.Count*100), "OK $label")
            }
            $bg.ReportProgress(100, "DONE")
        })
        $bg.add_ProgressChanged({
            param($s2,$e2)
            $progress.Value = [math]::Min($e2.ProgressPercentage, 100)
            if ($e2.UserState -eq "DONE") {
                $statusBox.AppendText("`r`n== ALL TWEAKS COMPLETED ==`r`n")
            } else {
                $statusBox.AppendText($e2.UserState + "`r`n")
                $statusBox.ScrollToCaret()
            }
        })
        $bg.RunWorkerAsync()
    })
}

[System.Windows.Forms.Application]::Run($form)
