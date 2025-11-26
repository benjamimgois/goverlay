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

implementation

function IsRunningInFlatpak: Boolean;
begin
  Result := GetEnvironmentVariable('FLATPAK_ID') <> '';
end;

function IsCommandAvailable(const CommandName: string): Boolean;
var
  AProcess: TProcess;
begin
  Result := False;
  AProcess := TProcess.Create(nil);
  try
    try
      AProcess.Executable := 'which';
      AProcess.Parameters.Add(CommandName);
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      Result := AProcess.ExitStatus = 0;
    except
      Result := False;
    end;
  finally
    AProcess.Free;
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
  AProcess: TProcess;
  GPUInfo: TStringList;
  Line: string;
begin
  Result := gpuUnknown;
  AProcess := TProcess.Create(nil);
  GPUInfo := TStringList.Create;
  try
    try
      AProcess.Executable := FindDefaultExecutablePath('lspci');
      AProcess.Parameters.Add('-nn');
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      GPUInfo.LoadFromStream(AProcess.Output);

      // Search for VGA or 3D controller
      for Line in GPUInfo do
      begin
        if (Pos('VGA', Line) > 0) or (Pos('3D controller', Line) > 0) then
        begin
          // Check for vendor identifiers
          if (Pos('AMD', Line) > 0) or (Pos('ATI', Line) > 0) or (Pos('[1002:', Line) > 0) then
            Result := gpuAMD
          else if (Pos('NVIDIA', Line) > 0) or (Pos('[10de:', Line) > 0) then
            Result := gpuNVIDIA
          else if (Pos('Intel', Line) > 0) or (Pos('[8086:', Line) > 0) then
            Result := gpuIntel;

          if Result <> gpuUnknown then
            Break;
        end;
      end;
    except
      Result := gpuUnknown;
    end;
  finally
    GPUInfo.Free;
    AProcess.Free;
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
  AProcess: TProcess;
  OutputList: TStringList;
begin
  Result := False;
  AProcess := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      // Use lsmod to check if nvidia module is loaded
      AProcess.Executable := 'lsmod';
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      OutputList.LoadFromStream(AProcess.Output);

      // Check if nvidia module appears in the output
      Result := OutputList.Text.Contains('nvidia');
    except
      Result := False;
    end;
  finally
    OutputList.Free;
    AProcess.Free;
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
  AProcess: TProcess;
  Output: TStringList;
  i: Integer;
  Line, InterfaceName: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    try
      AProcess.Executable := FindDefaultExecutablePath('ip');
      AProcess.Parameters.Add('link');
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      Output.LoadFromStream(AProcess.Output);

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
    except
      // If command fails, return empty list
    end;
  finally
    Output.Free;
    AProcess.Free;
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
  AProcess: TProcess;
  Output: TStringList;
begin
  Result := ExecutableName; // Default fallback

  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    try
      AProcess.Executable := 'which';
      AProcess.Parameters.Add(ExecutableName);
      AProcess.Options := [poWaitOnExit, poUsePipes];
      AProcess.Execute;

      if AProcess.ExitStatus = 0 then
      begin
        Output.LoadFromStream(AProcess.Output);
        if Output.Count > 0 then
          Result := Trim(Output[0]);
      end;
    except
      // If which fails, return the executable name as-is
      Result := ExecutableName;
    end;
  finally
    Output.Free;
    AProcess.Free;
  end;
end;

end.
