unit systemdetector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, StrUtils, FileUtil;

type
  /// <summary>
  /// GPU vendor types
  /// </summary>
  TGPUVendor = (gpuUnknown, gpuAMD, gpuNVIDIA, gpuIntel);

  /// <summary>
  /// Session type (X11 or Wayland)
  /// </summary>
  TSessionType = (sessionUnknown, sessionX11, sessionWayland);

/// <summary>
/// Detects if the application is running inside a Flatpak sandbox
/// </summary>
/// <returns>True if running in Flatpak, False otherwise</returns>
function IsRunningInFlatpak: Boolean;

/// <summary>
/// Checks if a command is available in the system PATH
/// </summary>
/// <param name="CommandName">Name of the command to check</param>
/// <returns>True if command exists, False otherwise</returns>
function IsCommandAvailable(const CommandName: string): Boolean;

/// <summary>
/// Checks if a command is available on the host system (for Flatpak)
/// This is used for commands that are never inside the Flatpak sandbox
/// </summary>
/// <param name="CommandName">Name of the command to check</param>
/// <returns>True if command exists on host, False otherwise</returns>
function IsHostCommandAvailable(const CommandName: string): Boolean;

/// <summary>
/// Detects GPU vendor by reading /sys/bus/pci/devices (Flatpak-compatible)
/// </summary>
/// <returns>GPU vendor type</returns>
function DetectGPUVendorFromSys: TGPUVendor;

/// <summary>
/// Detects GPU vendor using lspci command (traditional method)
/// </summary>
/// <returns>GPU vendor type</returns>
function DetectGPUVendorFromLspci: TGPUVendor;

/// <summary>
/// Detects GPU vendor (automatically chooses method based on environment)
/// </summary>
/// <returns>GPU vendor type</returns>
function DetectGPUVendor: TGPUVendor;

/// <summary>
/// Converts GPU vendor enum to string
/// </summary>
/// <param name="Vendor">GPU vendor type</param>
/// <returns>Vendor name as string (AMD, NVIDIA, Intel, unknown)</returns>
function GPUVendorToString(Vendor: TGPUVendor): string;

/// <summary>
/// Checks if NVIDIA kernel module is loaded
/// </summary>
/// <returns>True if nvidia module is loaded, False otherwise</returns>
function IsNvidiaDriverLoaded: Boolean;

/// <summary>
/// Gets network interfaces from /sys/class/net (Flatpak-compatible)
/// </summary>
/// <returns>List of network interface names</returns>
function GetNetworkInterfacesFromSys: TStringList;

/// <summary>
/// Gets network interfaces using 'ip link' command (traditional method)
/// </summary>
/// <returns>List of network interface names</returns>
function GetNetworkInterfacesFromCommand: TStringList;

/// <summary>
/// Gets network interfaces (automatically chooses method based on environment)
/// </summary>
/// <returns>List of network interface names</returns>
function GetNetworkInterfaces: TStringList;

/// <summary>
/// Gets standard font directories for different distributions
/// </summary>
/// <returns>List of existing font directory paths</returns>
function GetStandardFontDirectories: TStringList;

/// <summary>
/// Detects the current session type (X11 or Wayland)
/// </summary>
/// <returns>Session type</returns>
function DetectSessionType: TSessionType;

/// <summary>
/// Converts session type enum to string
/// </summary>
/// <param name="SessionType">Session type</param>
/// <returns>Session type as string (x11, wayland, unknown)</returns>
function SessionTypeToString(Session: TSessionType): string;

/// <summary>
/// Finds the default executable path for a command
/// </summary>
/// <param name="ExecutableName">Name of the executable</param>
/// <returns>Full path to executable, or just the name if not found</returns>
function FindDefaultExecutablePath(const ExecutableName: string): string;

/// <summary>
/// Gets Linux distribution name
/// </summary>
function GetSysLinuxDistribution: string;

/// <summary>
/// Gets CPU model name
/// </summary>
function GetSysCPUModel: string;

/// <summary>
/// Gets GPU model name
/// </summary>
function GetSysGPUModel: string;

/// <summary>
/// Gets GPU Driver info
/// </summary>
function GetSysGPUDriver: string;

/// <summary>
/// Checks whether a shared library (e.g. 'libqt6pas') is available on the
/// current system. Works across Ubuntu, Debian, Fedora, OpenSUSE, Arch and
/// NixOS by first querying ldconfig and then scanning the standard lib dirs.
/// </summary>
/// <param name="LibName">Library base name without extension (e.g. 'libqt6pas')</param>
/// <returns>True if any matching .so file is found</returns>
function IsLibraryAvailable(const LibName: string): Boolean;

implementation


function RunCommand(const Executable: string; const Parameters: array of string; out Output: string): Boolean;
var
  AProcess: TProcess;
  i: Integer;
  SL: TStringList;
begin
  Result := False;
  Output := '';
  AProcess := TProcess.Create(nil);
  SL := TStringList.Create;
  try
    try
      AProcess.Executable := Executable;
      for i := Low(Parameters) to High(Parameters) do
        AProcess.Parameters.Add(Parameters[i]);
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      SL.LoadFromStream(AProcess.Output);
      Output := Trim(SL.Text);
      Result := AProcess.ExitStatus = 0;
    except
      Result := False;
    end;
  finally
    SL.Free;
    AProcess.Free;
  end;
end;

function IsRunningInFlatpak: Boolean;
begin
  Result := GetEnvironmentVariable('FLATPAK_ID') <> '';
end;

function IsCommandAvailable(const CommandName: string): Boolean;
var
  Output: string;
begin
  // We use 'which' to check if command exists
  Result := RunCommand('which', [CommandName], Output);
end;

function IsHostCommandAvailable(const CommandName: string): Boolean;
const
  // Common binary paths on Linux systems
  HostPaths: array[0..5] of string = (
    '/usr/bin/',
    '/usr/local/bin/',
    '/bin/',
    '/usr/games/',
    '/usr/local/games/',
    '/opt/bin/'
  );
var
  i: Integer;
  HostPath: string;
begin
  Result := False;
  
  // If not in Flatpak, use regular command check
  if not IsRunningInFlatpak then
  begin
    Result := IsCommandAvailable(CommandName);
    Exit;
  end;
  
  // In Flatpak: check common host paths directly via filesystem
  // The host /usr is typically mounted at /run/host/usr in Flatpak
  for i := Low(HostPaths) to High(HostPaths) do
  begin
    HostPath := '/run/host' + HostPaths[i] + CommandName;
    if FileExists(HostPath) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function DetectGPUVendorFromSys: TGPUVendor;
var
  SearchRec: TSearchRec;
  VendorFile, DeviceClassFile: string;
  VendorID: string;
  DeviceClass: string;
  VendorText: TStringList;
begin
  Result := gpuUnknown;

  // Search for VGA devices in /sys/bus/pci/devices/
  if FindFirst('/sys/bus/pci/devices/*', faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          DeviceClassFile := '/sys/bus/pci/devices/' + SearchRec.Name + '/class';
          VendorFile := '/sys/bus/pci/devices/' + SearchRec.Name + '/vendor';

          // Check if this is a VGA device (class 0x03xxxx)
          if FileExists(DeviceClassFile) and FileExists(VendorFile) then
          begin
            VendorText := TStringList.Create;
            try
              VendorText.LoadFromFile(DeviceClassFile);
              if VendorText.Count > 0 then
              begin
                DeviceClass := Trim(VendorText[0]);
                // VGA controller class starts with 0x03
                if (Length(DeviceClass) >= 4) and (Copy(DeviceClass, 1, 4) = '0x03') then
                begin
                  VendorText.Clear;
                  VendorText.LoadFromFile(VendorFile);
                  if VendorText.Count > 0 then
                  begin
                    VendorID := Trim(VendorText[0]);
                    // Check vendor IDs
                    case VendorID of
                      '0x1002': Result := gpuAMD;      // AMD/ATI
                      '0x10de': Result := gpuNVIDIA;   // NVIDIA
                      '0x8086': Result := gpuIntel;    // Intel
                    end;

                    if Result <> gpuUnknown then
                      Break; // Found a GPU, stop searching
                  end;
                end;
              end;
            finally
              VendorText.Free;
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

function DetectGPUVendorFromLspci: TGPUVendor;
var
  Output: string;
  Executable: string;
begin
  Result := gpuUnknown;
  Executable := FindDefaultExecutablePath('lspci');
  
  if RunCommand(Executable, ['-nn'], Output) then
  begin
    // Search for VGA or 3D controller in Output
    if (Pos('VGA', Output) > 0) or (Pos('3D controller', Output) > 0) then
    begin
      // Check for vendor identifiers
      if (Pos('AMD', Output) > 0) or (Pos('ATI', Output) > 0) or (Pos('[1002:', Output) > 0) then
        Result := gpuAMD
      else if (Pos('NVIDIA', Output) > 0) or (Pos('[10de:', Output) > 0) then
        Result := gpuNVIDIA
      else if (Pos('Intel', Output) > 0) or (Pos('[8086:', Output) > 0) then
        Result := gpuIntel;
    end;
  end;
end;

function DetectGPUVendor: TGPUVendor;
begin
  // Use Flatpak-compatible detection if running in sandbox or lspci not available
  if IsRunningInFlatpak or not IsCommandAvailable('lspci') then
    Result := DetectGPUVendorFromSys
  else
    Result := DetectGPUVendorFromLspci;
end;

function GPUVendorToString(Vendor: TGPUVendor): string;
begin
  case Vendor of
    gpuAMD: Result := 'AMD';
    gpuNVIDIA: Result := 'NVIDIA';
    gpuIntel: Result := 'Intel';
    else Result := 'unknown';
  end;
end;

function IsNvidiaDriverLoaded: Boolean;
var
  SL: TStringList;
begin
  Result := False;
  // Direct file read from /proc/modules is faster and works in sandboxes
  if FileExists('/proc/modules') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/proc/modules');
      Result := Pos('nvidia', SL.Text) > 0;
    finally
      SL.Free;
    end;
  end;
end;

function GetNetworkInterfacesFromSys: TStringList;
var
  SearchRec: TSearchRec;
  InterfaceName: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  // Read directly from /sys/class/net/
  if FindFirst('/sys/class/net/*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        InterfaceName := SearchRec.Name;
        // Filter out . and .. and loopback
        if (InterfaceName <> '.') and (InterfaceName <> '..') and (InterfaceName <> 'lo') then
        begin
          // Add common network interface types
          if (Pos('eth', InterfaceName) = 1) or
             (Pos('enp', InterfaceName) = 1) or
             (Pos('wlan', InterfaceName) = 1) or
             (Pos('wlp', InterfaceName) = 1) or
             (Pos('wlo', InterfaceName) = 1) then
          begin
            Result.Add(InterfaceName);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

function GetNetworkInterfacesFromCommand: TStringList;
var
  OutputStr: string;
  Output: TStringList;
  i: Integer;
  Line, InterfaceName: string;
  Executable: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  Executable := FindDefaultExecutablePath('ip');
  
  if RunCommand(Executable, ['link'], OutputStr) then
  begin
    Output := TStringList.Create;
    try
      Output.Text := OutputStr;
      
      // Parse ip link output
      for i := 0 to Output.Count - 1 do
      begin
        Line := Output[i];
        // Lines with interface names start with a number
        if (Length(Line) > 0) and (Line[1] in ['0'..'9']) then
        begin
          // Extract interface name (format: "2: enp0s3: <BROADCAST,...")
          Delete(Line, 1, Pos(':', Line));  // Remove number and first colon
          Line := Trim(Line);
          InterfaceName := Copy(Line, 1, Pos(':', Line) - 1);

          // Filter relevant interfaces
          if (InterfaceName <> 'lo') and
             ((Pos('eth', InterfaceName) = 1) or
              (Pos('enp', InterfaceName) = 1) or
              (Pos('wlan', InterfaceName) = 1) or
              (Pos('wlp', InterfaceName) = 1) or
              (Pos('wlo', InterfaceName) = 1)) then
          begin
            Result.Add(InterfaceName);
          end;
        end;
      end;
    finally
      Output.Free;
    end;
  end;
end;

function GetNetworkInterfaces: TStringList;
begin
  // Use Flatpak-compatible detection if running in sandbox or ip command not available
  if IsRunningInFlatpak or not IsCommandAvailable('ip') then
    Result := GetNetworkInterfacesFromSys
  else
    Result := GetNetworkInterfacesFromCommand;
end;

function GetStandardFontDirectories: TStringList;
var
  Dir: String;
  i: Integer;
begin
  Result := TStringList.Create;
  Result.Duplicates := dupIgnore;
  Result.Sorted := True;

  // Standard Linux font directories
  Result.Add('/usr/share/fonts');
  Result.Add('/usr/local/share/fonts');
  Result.Add(GetUserDir + '.local/share/fonts');
  Result.Add(GetUserDir + '.fonts');

  // NixOS-specific directories
  Result.Add('/run/current-system/sw/share/fonts');
  Result.Add(GetEnvironmentVariable('HOME') + '/.nix-profile/share/fonts');

  // Flatpak font directories
  Result.Add('/var/lib/flatpak/exports/share/fonts');
  Result.Add(GetUserDir + '.local/share/flatpak/exports/share/fonts');

  // Remove directories that don't exist
  i := Result.Count - 1;
  while i >= 0 do
  begin
    if not DirectoryExists(Result[i]) then
      Result.Delete(i);
    Dec(i);
  end;
end;

function DetectSessionType: TSessionType;
var
  SessionTypeStr: string;
begin
  SessionTypeStr := LowerCase(GetEnvironmentVariable('XDG_SESSION_TYPE'));

  if SessionTypeStr = 'wayland' then
    Result := sessionWayland
  else if SessionTypeStr = 'x11' then
    Result := sessionX11
  else
    Result := sessionUnknown;
end;

function SessionTypeToString(Session: TSessionType): string;
begin
  case Session of
    sessionX11: Result := 'x11';
    sessionWayland: Result := 'wayland';
    else Result := 'unknown';
  end;
end;

function FindDefaultExecutablePath(const ExecutableName: string): string;
var
  Output: string;
begin
  Result := ExecutableName; // Default fallback

  if RunCommand('which', [ExecutableName], Output) then
  begin
    if Output <> '' then
      Result := Output;
  end;
end;

function GetSysLinuxDistribution: string;
var
  SL: TStringList;
  Line: string;
begin
  Result := 'Unknown Linux';
  if FileExists('/etc/os-release') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/etc/os-release');
      for Line in SL do
      begin
        if Pos('PRETTY_NAME=', Line) = 1 then
        begin
          Result := StringReplace(Line, 'PRETTY_NAME=', '', []);
          Result := StringReplace(Result, '"', '', [rfReplaceAll]);
          Break;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

function GetSysCPUModel: string;
var
  SL: TStringList;
  Line: string;
begin
  Result := 'Unknown CPU';
  if FileExists('/proc/cpuinfo') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/proc/cpuinfo');
      for Line in SL do
      begin
        if Pos('model name', Line) = 1 then
        begin
          Result := Trim(Copy(Line, Pos(':', Line) + 1, Length(Line)));
          Break;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

function GetSysGPUModel: string;
var
  Output, Line, CleanName: string;
  SL: TStringList;
begin
  Result := 'Unknown GPU';
  if RunCommand('glxinfo', ['-B'], Output) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Output;
      for Line in SL do
      begin
        if Pos('OpenGL renderer string:', Trim(Line)) = 1 then
        begin
          CleanName := Trim(Copy(Trim(Line), 24, Length(Line)));
          if Pos('(', CleanName) > 0 then
            CleanName := Trim(Copy(CleanName, 1, Pos('(', CleanName) - 1));
          Result := CleanName;
          Break;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

function GetSysGPUDriver: string;
var
  Output, Line, CleanStr: string;
  SL: TStringList;
begin
  Result := 'Unknown Driver';
  if RunCommand('glxinfo', ['-B'], Output) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Output;
      for Line in SL do
      begin
        if Pos('OpenGL core profile version string:', Trim(Line)) = 1 then
        begin
          CleanStr := Trim(Copy(Trim(Line), Length('OpenGL core profile version string:') + 1, Length(Line)));
          if Pos('Mesa', CleanStr) > 0 then
            Result := Trim(Copy(CleanStr, Pos('Mesa', CleanStr), Length(CleanStr)))
          else if Pos('NVIDIA', CleanStr) > 0 then
            Result := Trim(Copy(CleanStr, Pos('NVIDIA', CleanStr), Length(CleanStr)))
          else
            Result := CleanStr;
          Break;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;


function IsLibraryAvailable(const LibName: string): Boolean;
// Standard lib directories to scan when ldconfig is unavailable or incomplete.
// Covers: Arch/Manjaro/CachyOS, Ubuntu/Debian (x86_64 + i386 + arm64),
//         Fedora/RHEL/CentOS, OpenSUSE, NixOS (system + default profile).
const
  LibDirs: array[0..14] of string = (
    '/usr/lib',
    '/usr/lib64',
    '/usr/lib/x86_64-linux-gnu',
    '/usr/lib/i386-linux-gnu',
    '/usr/lib/aarch64-linux-gnu',
    '/usr/local/lib',
    '/usr/local/lib64',
    '/lib',
    '/lib64',
    '/lib/x86_64-linux-gnu',
    '/lib/aarch64-linux-gnu',
    '/run/current-system/sw/lib',          // NixOS system profile
    '/nix/var/nix/profiles/default/lib',   // NixOS default profile
    '/run/host/usr/lib',                   // Flatpak host overlay
    '/run/host/usr/lib64'                  // Flatpak host overlay (64-bit)
  );
var
  LdOutput: string;
  Dir, Pattern: string;
  SR: TSearchRec;
  // Some distros use mixed-case filenames (e.g. Arch: libQt6Pas.so).
  // Build a lowercase variant for case-insensitive fallback scanning.
  LibNameLower: string;
begin
  LibNameLower := LowerCase(LibName);

  // Primary: query the runtime linker cache with case-insensitive grep.
  // Works on Ubuntu, Debian, Fedora, OpenSUSE, Arch and most others.
  if RunCommand('sh', ['-c', 'ldconfig -p 2>/dev/null | grep -qi ' + LibNameLower], LdOutput) then
  begin
    Result := True;
    Exit;
  end;

  // Fallback: scan known library directories.
  // Linux filesystems are case-sensitive, so try both the name as given
  // and a title-case variant that covers Arch's libQt6Pas.so convention.
  Result := False;
  for Dir in LibDirs do
  begin
    for Pattern in [LibName, LibNameLower] do
    begin
      if FindFirst(Dir + '/' + Pattern + '*.so*', faAnyFile, SR) = 0 then
      begin
        Result := True;
        FindClose(SR);
        Exit;
      end;
      FindClose(SR);
    end;
    FindClose(SR);
  end;
end;

end.
