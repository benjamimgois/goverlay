unit apputils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, StrUtils, Graphics, Types, Math,
  constants, configmanager, systemdetector;

/// <summary>Write a timestamped debug message to stderr.</summary>
procedure DbgLog(const Msg: string);

/// <summary>Compare two dot-separated version strings. Returns -1, 0, or 1.</summary>
function CompareVersions(const Version1, Version2: string): Integer;

/// <summary>Execute a shell command asynchronously (fire-and-forget).</summary>
procedure ExecuteShellCommand(const Command: string);

/// <summary>Send a desktop notification via D-Bus (or notify-send fallback).</summary>
procedure SendNotification(const Title, Message: string; const IconPath: string = '');

/// <summary>Return the XDG-compliant GOverlay log directory path.</summary>
function GetGOverlayLogPath(): string;

/// <summary>Execute a GUI command detached with nohup and redirect output to logs.</summary>
procedure ExecuteGUICommand(const Command: string);

/// <summary>Trigger a session logout appropriate for the current DE.</summary>
procedure ExecuteSessionLogout();

/// <summary>Create a directory if it doesn't already exist.</summary>
procedure CreateHostDirectory(const DirPath: string);

/// <summary>Find the goverlay icon file in standard icon paths.</summary>
function GetIconFile(): string;

/// <summary>Check whether a shared library exists in standard search paths.</summary>
function LibraryExists(const LibName: string): Boolean;

/// <summary>Check whether a kernel module is currently loaded.</summary>
function IsKernelModuleAvailable(const ModuleName: string): Boolean;

/// <summary>Check runtime dependencies and return a list of missing items.</summary>
function CheckDependencies(out Missing: TStringList): Boolean;

implementation

var
  GDbgT0: QWord = 0;  // Debug log baseline timestamp

procedure DbgLog(const Msg: string);
var
  T: QWord;
begin
  T := GetTickCount64;
  if GDbgT0 = 0 then GDbgT0 := T;
  WriteLn(StdErr, Format('[%6d ms] %s', [T - GDbgT0, Msg]));
end;

function CompareVersions(const Version1, Version2: string): Integer;
var
  V1Parts, V2Parts: TStringArray;
  i, Num1, Num2, MaxLen: Integer;
begin
  V1Parts := SplitString(Version1, '.');
  V2Parts := SplitString(Version2, '.');
  MaxLen := Max(Length(V1Parts), Length(V2Parts));
  for i := 0 to MaxLen - 1 do
  begin
    if i < Length(V1Parts) then
      Num1 := StrToIntDef(V1Parts[i], 0)
    else
      Num1 := 0;
    if i < Length(V2Parts) then
      Num2 := StrToIntDef(V2Parts[i], 0)
    else
      Num2 := 0;
    if Num1 < Num2 then
      Exit(-1)
    else if Num1 > Num2 then
      Exit(1);
  end;
  Result := 0;
end;

procedure ExecuteShellCommand(const Command: string);
var
  Process: TProcess;
begin
  Process := TProcess.Create(nil);
  try
    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add(Command);
    Process.Options := [poNoConsole];
    Process.Execute;
  finally
    Process.Free;
  end;
end;

procedure SendNotification(const Title, Message: string; const IconPath: string = '');
var
  Process: TProcess;
  DBusCommand: string;
  UseDBus: Boolean;
begin
  UseDBus := True;
  if UseDBus then
  begin
    DBusCommand := 'gdbus call --session --dest org.freedesktop.Notifications ' +
                   '--object-path /org/freedesktop/Notifications ' +
                   '--method org.freedesktop.Notifications.Notify ' +
                   '"' + Title + '" 0 ';
    if IconPath <> '' then
      DBusCommand := DBusCommand + '"' + IconPath + '" '
    else
      DBusCommand := DBusCommand + '"" ';
    DBusCommand := DBusCommand + '"' + Title + '" "' + Message + '" ' +
                   '[] {} 5000';
    Process := TProcess.Create(nil);
    try
      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add(DBusCommand);
      Process.Options := [poNoConsole];
      Process.Execute;
    finally
      Process.Free;
    end;
  end
  else
  begin
    Process := TProcess.Create(nil);
    try
      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      if IconPath <> '' then
        Process.Parameters.Add('notify-send -e -i "' + IconPath + '" "' + Title + '" "' + Message + '"')
      else
        Process.Parameters.Add('notify-send -e "' + Title + '" "' + Message + '"');
      Process.Options := [poNoConsole];
      Process.Execute;
    finally
      Process.Free;
    end;
  end;
end;

function GetGOverlayLogPath(): string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'logs';
end;

procedure ExecuteGUICommand(const Command: string);
var
  Process: TProcess;
  LogPath: string;
  NohupLogFile: string;
begin
  Process := TProcess.Create(nil);
  try
    LogPath := GetGOverlayLogPath;
    if not DirectoryExists(LogPath) then
      ForceDirectories(LogPath);
    NohupLogFile := IncludeTrailingPathDelimiter(LogPath) + 'nohup.out';
    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add('nohup sh -c ''' + Command + ''' >> "' + NohupLogFile + '" 2>&1 &');
    Process.Options := [];
    Process.Execute;
    Sleep(200);
  finally
    Process.Free;
  end;
end;

procedure ExecuteSessionLogout();
var
  DesktopEnv: string;
  UserName: string;
  LogoutCommand: string;
begin
  DesktopEnv := UpperCase(GetEnvironmentVariable('XDG_CURRENT_DESKTOP'));
  if DesktopEnv = '' then
    DesktopEnv := UpperCase(GetEnvironmentVariable('DESKTOP_SESSION'));

  if Pos('GNOME', DesktopEnv) > 0 then
    LogoutCommand := 'gnome-session-quit --logout --no-prompt'
  else if Pos('KDE', DesktopEnv) > 0 then
  begin
    if IsCommandAvailable('qdbus6') then
      LogoutCommand := 'qdbus6 org.kde.Shutdown /Shutdown logout'
    else if IsCommandAvailable('qdbus') then
      LogoutCommand := 'qdbus org.kde.ksmserver /KSMServer logout 0 0 0'
    else
    begin
      UserName := GetEnvironmentVariable('USER');
      LogoutCommand := 'loginctl terminate-user ' + UserName;
    end;
  end
  else if Pos('XFCE', DesktopEnv) > 0 then
    LogoutCommand := 'xfce4-session-logout --logout'
  else if Pos('MATE', DesktopEnv) > 0 then
    LogoutCommand := 'mate-session-save --logout'
  else if Pos('CINNAMON', DesktopEnv) > 0 then
    LogoutCommand := 'cinnamon-session-quit --logout --no-prompt'
  else
  begin
    UserName := GetEnvironmentVariable('USER');
    LogoutCommand := 'loginctl terminate-user ' + UserName;
  end;

  ExecuteShellCommand(LogoutCommand);
end;

procedure CreateHostDirectory(const DirPath: string);
begin
  if not DirectoryExists(DirPath) then
    ForceDirectories(DirPath);
end;

function GetIconFile(): string;
var
  Dirs: TStringDynArray;
  IconFile: string;
  DataDirs: string;
  i: Integer;
begin
  DataDirs := GetEnvironmentVariable('XDG_DATA_DIRS');
  IconFile := PATH_GOVERLAY_ICON;
  if Length(DataDirs) > 0 then
  begin
    Dirs := SplitString(DataDirs, ':');
    for i := Low(Dirs) to High(Dirs) do
    begin
      IconFile := Dirs[i] + '/icons/hicolor/128x128/apps/goverlay.png';
      if FileExists(IconFile) then
        Break;
    end;
  end;
  Result := IconFile;
end;

function LibraryExists(const LibName: string): Boolean;
const
  SearchPaths: array[0..2] of string = (
    '/usr/lib/',
    '/usr/lib64/',
    '/usr/local/lib/'
  );
var
  Path: string;
begin
  Result := False;
  for Path in SearchPaths do
    if FileExists(Path + LibName) then
      Exit(True);
end;

function IsKernelModuleAvailable(const ModuleName: string): Boolean;
var
  AProcess: TProcess;
  OutputLines: TStringList;
begin
  Result := False;
  AProcess := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('lsmod');
    AProcess.Options := [poUsePipes];
    AProcess.Execute;
    OutputLines.LoadFromStream(AProcess.Output);
    Result := OutputLines.Text.Contains(ModuleName);
  finally
    AProcess.Free;
    OutputLines.Free;
  end;
end;

function CheckDependencies(out Missing: TStringList): Boolean;
begin
  Missing := TStringList.Create;

  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('pascube') then
      Missing.Add('pascube');
  end;

  if IsRunningInFlatpak then
  begin
    if not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/x86_64-linux-gnu/libMangoHud.so') and
       not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/i386-linux-gnu/libMangoHud.so') then
      Missing.Add('MangoHud runtime 25.08');
    if not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/x86_64-linux-gnu/vkbasalt/libvkbasalt.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/i386-linux-gnu/vkbasalt/libvkbasalt.so') then
      Missing.Add('vkBasalt runtime 25.08');
  end
  else
  begin
    if not IsCommandAvailable('mangohud') then
      Missing.Add('mangohud');
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/vkBasalt.json') and
       not IsLibraryAvailable('libvkbasalt') then
      Missing.Add('vkbasalt');
  end;

  if not IsCommandAvailable('vkcube') then
    Missing.Add('vkcube');
  if not IsCommandAvailable('7z') then
    Missing.Add('p7zip');
  if not IsCommandAvailable('curl') then
    Missing.Add('curl');
  if not IsCommandAvailable('git') then
    Missing.Add('git');

  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('protontricks') then
      Missing.Add('protontricks');
  end;

  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('gamemoderun') then
      Missing.Add('gamemode');
  end;

  if not IsLibraryAvailable('libQt6Pas') then
    Missing.Add('libqt6pas');

  Result := Missing.Count = 0;
end;

end.
