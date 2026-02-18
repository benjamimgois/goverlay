unit hintsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls;

// Procedure to apply all hints to form components
procedure ApplyAllHints(AForm: TComponent);

implementation

procedure ApplyAllHints(AForm: TComponent);
var
  Component: TComponent;

  procedure SetHint(const ComponentName, HintText: string);
  begin
    Component := AForm.FindComponent(ComponentName);
    if Assigned(Component) and (Component is TControl) then
    begin
      TControl(Component).Hint := HintText;
      TControl(Component).ShowHint := True;
    end;
  end;

begin
  // ============================================================================
  // MANGOHUD - PRESET TAB
  // ============================================================================

  // Layouts
  SetHint('basicBitBtn', 'Basic layout' + LineEnding +
    'Displays FPS, frametime and essential information');
  SetHint('fullBitBtn', 'Full layout' + LineEnding +
    'Shows all available metrics');
  SetHint('fpsonlyBitBtn', 'FPS only' + LineEnding +
    'Displays only the FPS counter');
  SetHint('basichorizontalBitBtn', 'Basic horizontal layout' + LineEnding +
    'Basic layout in horizontal orientation');

  // Position
  SetHint('topleftRadioButton',     'Position: Top left corner');
  SetHint('topcenterRadioButton',   'Position: Top center');
  SetHint('toprightRadioButton',    'Position: Top right corner');
  SetHint('middleleftRadioButton',  'Position: Middle left');
  SetHint('middlerightRadioButton', 'Position: Middle right');
  SetHint('bottomleftRadioButton',  'Position: Bottom left corner');
  SetHint('bottomcenterRadioButton','Position: Bottom center');
  SetHint('bottomrightRadioButton', 'Position: Bottom right corner');

  // ============================================================================
  // MANGOHUD - PERFORMANCE TAB
  // ============================================================================

  // FPS
  SetHint('fpsCheckBox', 'Display FPS' + LineEnding +
    'Shows frames per second rate');
  SetHint('fpsavgCheckBox', 'Average FPS' + LineEnding +
    'Displays calculated average FPS');
  SetHint('framecountCheckBox', 'Frame counter' + LineEnding +
    'Shows total number of rendered frames');
  SetHint('frametimegraphCheckBox', 'Frametime graph' + LineEnding +
    'Displays rendering time graph');
  SetHint('showfpslimCheckBox', 'Show FPS limit' + LineEnding +
    'Displays FPS limiter value when active');

  // CPU
  SetHint('cputempCheckBox', 'CPU temperature' + LineEnding +
    'Shows current processor temperature');
  SetHint('cpupowerCheckBox', 'CPU power consumption' + LineEnding +
    'Displays processor power consumption in Watts');
  SetHint('cpufreqCheckBox', 'CPU frequency' + LineEnding +
    'Shows current clock frequency');
  SetHint('cpuavgloadCheckBox', 'Average CPU load' + LineEnding +
    'Displays average load of all cores');
  SetHint('cpuloadcoreCheckBox', 'Load per core' + LineEnding +
    'Shows individual load of each core');

  // GPU
  SetHint('gputempCheckBox', 'GPU temperature' + LineEnding +
    'Shows current graphics card temperature');
  SetHint('gpupowerCheckBox', 'GPU power consumption' + LineEnding +
    'Displays GPU power consumption in Watts');
  SetHint('gpufreqCheckBox', 'GPU frequency' + LineEnding +
    'Shows current GPU clock frequency');
  SetHint('gpufanCheckBox', 'Cooler speed' + LineEnding +
    'Displays fan speed in RPM or %');
  SetHint('gpumemfreqCheckBox', 'VRAM frequency' + LineEnding +
    'Shows video memory frequency');
  SetHint('gpujunctempCheckBox', 'Junction temperature' + LineEnding +
    'Internal GPU chip temperature (hotspot)');
  SetHint('gputhrottlingCheckBox', 'GPU throttling' + LineEnding +
    'Indicates when GPU is reducing performance');
  SetHint('gpuvoltageCheckBox', 'GPU voltage' + LineEnding +
    'Displays current graphics card voltage');

  // Memory
  SetHint('ramusageCheckBox', 'RAM usage' + LineEnding +
    'Shows used/total RAM memory');
  SetHint('vramusageCheckBox', 'VRAM usage' + LineEnding +
    'Displays used/total video memory');
  SetHint('swapusageCheckBox', 'SWAP usage' + LineEnding +
    'Shows swap memory usage');
  SetHint('procmemCheckBox', 'Process memory' + LineEnding +
    'Displays RAM used by game/application');
  SetHint('procvramCheckBox', 'Process VRAM' + LineEnding +
    'Shows VRAM used by game/application');

  // Disk I/O
  SetHint('diskioCheckBox', 'Disk I/O' + LineEnding +
    'Displays disk read and write');

  // ============================================================================
  // MANGOHUD - VISUAL TAB
  // ============================================================================

  SetHint('hudcompactCheckBox', 'Compact mode' + LineEnding +
    'Reduces spacing between elements');
  SetHint('fahrenheitCheckBox', 'Use Fahrenheit' + LineEnding +
    'Displays temperatures in °F instead of °C');
  SetHint('fpscolorCheckBox', 'Color FPS' + LineEnding +
    'Changes FPS color based on defined limits');
  SetHint('cpuloadcolorCheckBox', 'Color CPU load' + LineEnding +
    'Changes color based on processor load');
  SetHint('gpuloadcolorCheckBox', 'Color GPU load' + LineEnding +
    'Changes color based on GPU load');

  // ============================================================================
  // MANGOHUD - METRICS TAB
  // ============================================================================

  SetHint('archCheckBox', 'System architecture' + LineEnding +
    'Displays x86_64, ARM, etc.');
  SetHint('distroinfoCheckBox', 'Distribution information' + LineEnding +
    'Shows Linux name and version');
  SetHint('resolutionCheckBox', 'Resolution' + LineEnding +
    'Displays current screen resolution');
  SetHint('refreshrateCheckBox', 'Refresh rate' + LineEnding +
    'Shows monitor refresh rate in Hz');
  SetHint('displayserverCheckBox', 'Display server' + LineEnding +
    'Displays X11, Wayland, etc.');
  SetHint('timeCheckBox', 'Current time' + LineEnding +
    'Shows system time');
  SetHint('wineCheckBox', 'Wine version' + LineEnding +
    'Displays Wine/Proton version in use');
  SetHint('engineversionCheckBox', 'Engine version' + LineEnding +
    'Shows Vulkan/OpenGL version');
  SetHint('engineshortCheckBox', 'Short engine name' + LineEnding +
    'Uses abbreviations (VK, GL, DX)');
  SetHint('vulkandriverCheckBox', 'Vulkan driver' + LineEnding +
    'Displays Vulkan driver in use');
  SetHint('gpumodelCheckBox', 'GPU model' + LineEnding +
    'Shows full graphics card name');
  SetHint('hudversionCheckBox', 'MangoHud version' + LineEnding +
    'Displays MangoHud version');
  SetHint('gamemodestatusCheckBox', 'GameMode status' + LineEnding +
    'Indicates if GameMode is active');
  SetHint('vkbasaltstatusCheckBox', 'vkBasalt status' + LineEnding +
    'Indicates if vkBasalt is active');
  SetHint('batteryCheckBox', 'Battery' + LineEnding +
    'Shows battery charge level');
  SetHint('batterywattCheckBox', 'Battery consumption' + LineEnding +
    'Displays consumption in Watts');
  SetHint('batterytimeCheckBox', 'Battery time' + LineEnding +
    'Shows estimated remaining time');
  SetHint('deviceCheckBox', 'Device name' + LineEnding +
    'Displays system hostname');
  SetHint('mediaCheckBox', 'Media player' + LineEnding +
    'Shows music/video being played');
  SetHint('networkCheckBox', 'Network' + LineEnding +
    'Displays network traffic of selected interface');

  // ============================================================================
  // MANGOHUD - EXTRAS TAB
  // ============================================================================

  SetHint('fsrCheckBox', 'FSR indicator' + LineEnding +
    'Shows when FidelityFX Super Resolution is active');
  SetHint('hdrCheckBox', 'HDR indicator' + LineEnding +
    'Displays when HDR is enabled');
  SetHint('fcatCheckBox', 'FCAT' + LineEnding +
    'Frame Capture Analysis Tool - frame analysis');
  SetHint('ftraceCheckBox', 'Ftrace' + LineEnding +
    'Kernel function tracing');
  SetHint('dxapiCheckBox', 'DirectX API' + LineEnding +
    'Shows DirectX version in use');
  SetHint('winesyncCheckBox', 'Wine Sync' + LineEnding +
    'Displays synchronization method (fsync, esync)');
  SetHint('vpsCheckBox', 'VPS' + LineEnding +
    'Variable Pre-scaled - scaling information');
  SetHint('hidehudCheckBox', 'Hide HUD on start' + LineEnding +
    'Starts with overlay hidden (use shortcut to show)');
  SetHint('autouploadCheckBox', 'Auto upload logs' + LineEnding +
    'Automatically sends logs to flightlessmango.com');

  // ============================================================================
  // OPTISCALER
  // ============================================================================

  SetHint('spoofCheckBox', 'Spoof DLSS' + LineEnding +
    'Simulates DLSS inputs without spoofing' + LineEnding +
    'in compatible games');
  SetHint('fsrversionComboBox', 'FSR version' + LineEnding +
    'Select FidelityFX Super Resolution version');
  SetHint('optversionComboBox', 'OptiScaler channel' + LineEnding +
    'Stable: Stable version' + LineEnding +
    'Pre-release: Development version');
  SetHint('updateBitBtn', 'Update OptiScaler' + LineEnding +
    'Downloads and installs latest version');
  SetHint('optipatcherCheckBox', 'OptiPatcher' + LineEnding +
    'Applies compatibility patches' + LineEnding +
    'for specific games');

  // FakeNVAPI
  SetHint('forcenvapiCheckBox', 'Force NVAPI' + LineEnding +
    'Forces use of fake NVAPI implementation');
  SetHint('hidenvidiaCheckBox', 'Hide NVIDIA' + LineEnding +
    'Hides NVIDIA GPU from system');
  SetHint('forcelatencyflexCheckBox', 'Force Latency Flex' + LineEnding +
    'Forces Latency Flex enable');
  SetHint('forcereflexCheckBox', 'Force Reflex' + LineEnding +
    'Forces NVIDIA Reflex enable');

  // ============================================================================
  // VKBASALT
  // ============================================================================

  SetHint('casTrackBar', 'Contrast Adaptive Sharpening' + LineEnding +
    'Contrast-based adaptive sharpening' + LineEnding +
    '0.0 = Off, 1.0 = Maximum');
  SetHint('dlsTrackBar', 'Denoised Luma Sharpening' + LineEnding +
    'Luminance sharpening with noise reduction' + LineEnding +
    '0.0 = Off, 1.0 = Maximum');
  SetHint('fxaaTrackBar', 'Fast Approximate Anti-Aliasing' + LineEnding +
    'Fast anti-aliasing' + LineEnding +
    '0.0 = Off, 1.0 = Maximum');
  SetHint('smaaTrackBar', 'Subpixel Morphological Anti-Aliasing' + LineEnding +
    'High quality morphological anti-aliasing' + LineEnding +
    '0.0 = Off, 1.0 = Maximum');
  SetHint('reshaderefreshBitBtn', 'Update ReShade shaders' + LineEnding +
    'Downloads latest shaders from repository');

  // ============================================================================
  // TWEAKS
  // ============================================================================

  SetHint('gamemodeCheckBox', 'GameMode' + LineEnding +
    'Feral GameMode performance optimizations' + LineEnding +
    'Requires gamemode package installed');
  SetHint('forcezinkCheckBox', 'Force Zink' + LineEnding +
    'Uses Zink (OpenGL over Vulkan)');
  SetHint('enwaylandCheckBox', 'Enable Wayland' + LineEnding +
    'Forces Wayland use instead of XWayland');
  SetHint('disablentsyncCheckBox', 'Disable NTDLL Sync' + LineEnding +
    'Disables NTDLL synchronization in Wine');
  SetHint('nofastclearsCheckBox', 'Disable Fast Clears' + LineEnding +
    'RADV_DEBUG=nofastclears' + LineEnding +
    'Disables fast clear optimization (AMD)');
  SetHint('highpriCheckBox', 'High priority' + LineEnding +
    'Runs game with high system priority');
  SetHint('largeaddressCheckBox', 'Large Address Aware' + LineEnding +
    'Allows 32-bit games to use more than 2GB RAM');
  SetHint('emurtCheckBox', 'Emulate RT' + LineEnding +
    'Emulates Ray Tracing on GPUs without native support');
  SetHint('enhdrCheckBox', 'Enable HDR' + LineEnding +
    'Activates High Dynamic Range when available');
  SetHint('stagememCheckBox', 'Stage Memory' + LineEnding +
    'Memory optimization for AMD GPUs');
  SetHint('simdeckCheckBox', 'Simulate Steam Deck' + LineEnding +
    'Makes game detect system as Steam Deck');
  SetHint('wow64CheckBox', 'WOW64' + LineEnding +
    'Windows 64-bit compatibility mode');
  SetHint('fexstatsCheckBox', 'FEX Stats' + LineEnding +
    'FEX-Emu emulator statistics (ARM)');
  SetHint('emufp8CheckBox', 'Emulate FP8' + LineEnding +
    'Emulates FP8 floating point precision');
  SetHint('actprotonlogsCheckBox', 'Proton Logs' + LineEnding +
    'Activates detailed Proton logs');
  SetHint('heapdelayCheckBox', 'Heap Delay' + LineEnding +
    'Delay in heap allocation (Wine)');
  SetHint('ramtempCheckBox', 'RAM temperature' + LineEnding +
    'Displays memory module temperature');

  // ============================================================================
  // MAIN BUTTONS
  // ============================================================================

  SetHint('saveBitBtn', 'Save configurations' + LineEnding +
    'Applies and saves all changes');
  SetHint('copyBitBtn', 'Copy command' + LineEnding +
    'Copies launch command to clipboard');
  SetHint('gupdateBitBtn', 'Check for updates' + LineEnding +
    'Checks if there is a new GOverlay version');
  SetHint('checkupdBitBtn', 'Check MangoHud updates' + LineEnding +
    'Checks latest MangoHud version');
  SetHint('howtoBitBtn', 'How to use' + LineEnding +
    'Instructions for Steam, Heroic and other launchers');
  SetHint('themeToggleSpeedButton', 'Toggle theme' + LineEnding +
    'Switches between light and dark theme');
  SetHint('geSpeedButton', 'Global Enable' + LineEnding +
    'Automatically enables for all games using FGMOD');

  // ============================================================================
  // LOGGING
  // ============================================================================

  SetHint('logfolderBitBtn', 'Select log folder' + LineEnding +
    'Choose where logs will be saved');
  SetHint('delayTrackBar', 'Initial delay' + LineEnding +
    'Wait time before starting log (seconds)');
  SetHint('durationTrackBar', 'Log duration' + LineEnding +
    'Total log recording time (seconds)');
  SetHint('intervalTrackBar', 'Sampling interval' + LineEnding +
    'Data collection frequency (milliseconds)');
  SetHint('versioningCheckBox', 'Log versioning' + LineEnding +
    'Adds timestamp to log file names');

  // ============================================================================
  // FPS LIMITER
  // ============================================================================

  SetHint('fpslimmetComboBox', 'Limiter method' + LineEnding +
    'early: Lower latency' + LineEnding +
    'late: More stable');
  SetHint('fpslimtoggleComboBox', 'Limiter shortcut' + LineEnding +
    'Key to enable/disable FPS limit');
  SetHint('hudonoffComboBox', 'HUD shortcut' + LineEnding +
    'Key to show/hide overlay');
  SetHint('logtoggleComboBox', 'Log shortcut' + LineEnding +
    'Key to start/stop log recording');
  SetHint('vkbtogglekeyCombobox', 'vkBasalt shortcut' + LineEnding +
    'Key to enable/disable effects');

  // ============================================================================
  // VSYNC
  // ============================================================================

  SetHint('vsyncComboBox', 'VSync (Vulkan)' + LineEnding +
    '0 = Off' + LineEnding +
    '1 = On' + LineEnding +
    '2 = Mailbox mode' + LineEnding +
    '3 = Adaptive');
  SetHint('glvsyncComboBox', 'VSync (OpenGL)' + LineEnding +
    '-1 = Adaptive' + LineEnding +
    '0 = Off' + LineEnding +
    '1 = On');

  // ============================================================================
  // FILTERS
  // ============================================================================

  SetHint('afTrackBar', 'Anisotropic filtering' + LineEnding +
    'Improves texture quality at angles' + LineEnding +
    '0 = Off, 16 = Maximum');
  SetHint('mipmapTrackBar', 'Mipmap bias' + LineEnding +
    'Adjusts distant texture sharpness' + LineEnding +
    'Negative = Sharper, Positive = Softer');

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  SetHint('fontsizeTrackBar', 'Font size' + LineEnding +
    'Adjusts overlay text size');
  SetHint('transpTrackBar', 'Transparency' + LineEnding +
    'Overlay background opacity' + LineEnding +
    '0 = Transparent, 100 = Opaque');
  SetHint('menuscaleTrackBar', 'Menu scale' + LineEnding +
    'Overall overlay size' + LineEnding +
    '0.5 = 50%, 1.0 = 100%, 2.0 = 200%');
  SetHint('offsetSpinEdit', 'Offset' + LineEnding +
    'Distance from screen edge in pixels');

  // Color buttons
  SetHint('FontcolorButton', 'Font color' + LineEnding +
    'Default text color');
  SetHint('hudbackgroundColorButton', 'Background color' + LineEnding +
    'Overlay background color');
  SetHint('cpuColorButton', 'CPU color' + LineEnding +
    'CPU metrics text color');
  SetHint('gpuColorButton', 'GPU color' + LineEnding +
    'GPU metrics text color');
  SetHint('ramColorButton', 'RAM color' + LineEnding +
    'Memory usage text color');
  SetHint('vramColorButton', 'VRAM color' + LineEnding +
    'Video memory text color');
  SetHint('engineColorButton', 'Engine color' + LineEnding +
    'Engine information text color');
  SetHint('wineColorButton', 'Wine color' + LineEnding +
    'Wine information text color');
  SetHint('batteryColorButton', 'Battery color' + LineEnding +
    'Battery information text color');
  SetHint('mediaColorButton', 'Media player color' + LineEnding +
    'Media information text color');
end;

end.
