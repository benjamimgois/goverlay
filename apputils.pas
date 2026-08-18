unit apputils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, StrUtils, Graphics, Types, Math, BaseUnix, Unix,
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

/// <summary>Add a line to global log buffer (thread-safe).</summary>
procedure AddGlobalLog(const Msg: string);

/// <summary>Get a copy of all accumulated startup logs.</summary>
procedure GetGlobalLogs(DestList: TStrings);

/// <summary>Install TextRec stdout/stderr hooks to intercept all WriteLn calls.</summary>
procedure InstallStdoutHook;

/// <summary>Restore original stdout/stderr file descriptors and remove hooks.</summary>
procedure RestoreStdoutHook;

implementation

var
  GDbgT0: QWord = 0;  // Debug log baseline timestamp
  GGlobalLogList: TStringList = nil;
  GGlobalLogLock: TRTLCriticalSection;
  GRawLogBuffer: string = '';

type
  TLogPipeThread = class(TThread)
  private
    FReadFd: cInt;
    FOldStdoutFd: cInt;
  protected
    procedure Execute; override;
  public
    constructor Create(AReadFd, AOldStdoutFd: cInt);
  end;

constructor TLogPipeThread.Create(AReadFd, AOldStdoutFd: cInt);
begin
  inherited Create(False);
  FReadFd := AReadFd;
  FOldStdoutFd := AOldStdoutFd;
  FreeOnTerminate := True;
end;

procedure TLogPipeThread.Execute;
var
  Buffer: array[0..2047] of Char;
  BytesRead: TsSize;
  S: string;
begin
  while not Terminated do
  begin
    BytesRead := fpRead(FReadFd, Buffer[0], SizeOf(Buffer) - 1);
    if BytesRead <= 0 then Break;

    if FOldStdoutFd > 0 then
      fpWrite(FOldStdoutFd, Buffer[0], BytesRead);

    Buffer[BytesRead] := #0;
    SetString(S, Buffer, BytesRead);
    AddGlobalLog(S);
  end;
end;

var
  FOldStdoutFd: cInt = -1;
  FOldStderrFd: cInt = -1;
  FPipeInstalled: Boolean = False;

procedure AddGlobalLog(const Msg: string);
var
  I: Integer;
  LineStr: string;
begin
  EnterCriticalSection(GGlobalLogLock);
  try
    if not Assigned(GGlobalLogList) then
      GGlobalLogList := TStringList.Create;

    GRawLogBuffer := GRawLogBuffer + Msg;

    while Pos(#10, GRawLogBuffer) > 0 do
    begin
      I := Pos(#10, GRawLogBuffer);
      LineStr := Copy(GRawLogBuffer, 1, I - 1);
      if (Length(LineStr) > 0) and (LineStr[Length(LineStr)] = #13) then
        Delete(LineStr, Length(LineStr), 1);
      Delete(GRawLogBuffer, 1, I);

      GGlobalLogList.Add(LineStr);
    end;
  finally
    LeaveCriticalSection(GGlobalLogLock);
  end;
end;

procedure GetGlobalLogs(DestList: TStrings);
begin
  if not Assigned(DestList) then Exit;
  EnterCriticalSection(GGlobalLogLock);
  try
    if Assigned(GGlobalLogList) then
      DestList.Assign(GGlobalLogList);
  finally
    LeaveCriticalSection(GGlobalLogLock);
  end;
end;

const
  FD_CLOEXEC = 1;

procedure InstallStdoutHook;
var
  ExeName: string;
  PipeFds: array[0..1] of cInt;
begin
  if FPipeInstalled then Exit;
  if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then Exit;
  ExeName := LowerCase(ExtractFileName(ParamStr(0)));
  if Pos('test', ExeName) > 0 then Exit;
  FPipeInstalled := True;

  FOldStdoutFd := fpDup(1);
  FOldStderrFd := fpDup(2);
  if FOldStdoutFd >= 0 then
    FpFcntl(FOldStdoutFd, F_SETFD, FD_CLOEXEC);
  if FOldStderrFd >= 0 then
    FpFcntl(FOldStderrFd, F_SETFD, FD_CLOEXEC);

  if fpPipe(PipeFds) = 0 then
  begin
    FpFcntl(PipeFds[0], F_SETFD, FD_CLOEXEC);
    FpFcntl(PipeFds[1], F_SETFD, FD_CLOEXEC);

    fpDup2(PipeFds[1], 1);
    fpDup2(PipeFds[1], 2);
    fpClose(PipeFds[1]);

    TLogPipeThread.Create(PipeFds[0], FOldStdoutFd);
  end;
end;

procedure RestoreStdoutHook;
begin
  if not FPipeInstalled then Exit;
  if FOldStdoutFd >= 0 then
  begin
    fpDup2(FOldStdoutFd, 1);
    fpClose(FOldStdoutFd);
    FOldStdoutFd := -1;
  end;
  if FOldStderrFd >= 0 then
  begin
    fpDup2(FOldStderrFd, 2);
    fpClose(FOldStderrFd);
    FOldStderrFd := -1;
  end;
  FPipeInstalled := False;
end;

procedure DbgLog(const Msg: string);
var
  T: QWord;
  FormattedMsg: string;
begin
  T := GetTickCount64;
  if GDbgT0 = 0 then GDbgT0 := T;
  FormattedMsg := Format('[%6d ms] %s', [T - GDbgT0, Msg]);
  WriteLn(StdErr, FormattedMsg);
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
    Process.Options := [poNoConsole, poWaitOnExit];
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
  CleanCmd: string;
begin
  Process := TProcess.Create(nil);
  try
    LogPath := GetGOverlayLogPath;
    if not DirectoryExists(LogPath) then
      ForceDirectories(LogPath);
    NohupLogFile := IncludeTrailingPathDelimiter(LogPath) + 'nohup.out';
    CleanCmd := Trim(Command);
    if (Length(CleanCmd) > 0) and (CleanCmd[Length(CleanCmd)] = '&') then
      CleanCmd := Trim(Copy(CleanCmd, 1, Length(CleanCmd) - 1));

    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add('( ' + CleanCmd + ' ) 2>&1 | tee -a "' + NohupLogFile + '" &');
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
  IconFile, AppDir: string;
  DataDirs: string;
  i: Integer;
begin
  AppDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  IconFile := AppDir + 'assets/icons/goverlay.png';
  if FileExists(IconFile) then Exit(IconFile);

  IconFile := AppDir + 'data/icons/128x128/goverlay.png';
  if FileExists(IconFile) then Exit(IconFile);

  DataDirs := GetEnvironmentVariable('XDG_DATA_DIRS');
  if Length(DataDirs) > 0 then
  begin
    Dirs := SplitString(DataDirs, ':');
    for i := Low(Dirs) to High(Dirs) do
    begin
      IconFile := Dirs[i] + '/icons/hicolor/128x128/apps/goverlay.png';
      if FileExists(IconFile) then Exit(IconFile);
      IconFile := Dirs[i] + '/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png';
      if FileExists(IconFile) then Exit(IconFile);
    end;
  end;

  if FileExists(PATH_GOVERLAY_ICON) then Exit(PATH_GOVERLAY_ICON);
  Result := '/usr/share/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png';
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
  LsmodPath, Output: string;
begin
  Result := False;
  LsmodPath := FindDefaultExecutablePath('lsmod');
  if LsmodPath = '' then Exit;

  // Reading AProcess.Output straight after Execute only returns whatever has
  // already reached the pipe - one 4 KiB page here - so every module past that
  // point looks unloaded. RunCommand keeps draining until lsmod exits, without
  // the 64 KiB deadlock that poWaitOnExit on its own would risk.
  Output := '';
  if RunCommand(LsmodPath, [], Output) then
    Result := Output.Contains(ModuleName);
end;

function CheckDependencies(out Missing: TStringList): Boolean;
begin
  Missing := TStringList.Create;



  if IsRunningInFlatpak then
  begin
    if not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/x86_64-linux-gnu/libMangoHud.so') and
       not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/i386-linux-gnu/libMangoHud.so') then
      Missing.Add(DEP_MANGOHUD_RUNTIME);
    if not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/x86_64-linux-gnu/vkbasalt/libvkbasalt.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/i386-linux-gnu/vkbasalt/libvkbasalt.so') then
      Missing.Add(DEP_VKBASALT_RUNTIME);
    if not FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/i386-linux-gnu/libVkLayer_vksumi.so') then
      Missing.Add(DEP_VKSUMI_RUNTIME);
  end
  else
  begin
    if not IsCommandAvailable('mangohud') then
      Missing.Add(DEP_MANGOHUD);
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/vkBasalt.json') and
       not IsLibraryAvailable('libvkbasalt') then
      Missing.Add(DEP_VKBASALT);

    // vulkan-low-latency-layer: check Vulkan layer JSON then fall back to library scan
    if not FileExists('/usr/share/vulkan/implicit_layer.d/low_latency_layer.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/low_latency_layer.json') and
       not FileExists(GetUserDir + '.local/share/vulkan/implicit_layer.d/low_latency_layer.json') and
       not IsLibraryAvailable('libVkLayer_KORTHOS_LowLatency') then
      Missing.Add(DEP_LOW_LATENCY_LAYER);

    // lsfg-vk: check Vulkan layer JSON then fall back to library scan or binary
    if not FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') and
       not FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') and
       not FileExists(GetUserDir + '.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') and
       not FileExists(GetUserDir + '.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') and
       not IsLibraryAvailable('liblsfg-vk') and
       not IsLibraryAvailable('libVkLayer_LSFGVK') and
       not IsCommandAvailable('lsfg-vk-ui') then
      Missing.Add(DEP_LSFGVK);
  end;


  if not IsCommandAvailable('7z') then
    Missing.Add(DEP_P7ZIP);
  if not IsCommandAvailable('curl') then
    Missing.Add(DEP_CURL);
  if not IsCommandAvailable('git') then
    Missing.Add(DEP_GIT);

  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('protontricks') then
      Missing.Add(DEP_PROTONTRICKS);
  end;

  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('gamemoderun') then
      Missing.Add(DEP_GAMEMODE);
  end;

  {$IFDEF LCLqt6}
  if not IsLibraryAvailable('libQt6Pas') then
    Missing.Add(DEP_LIBQT6PAS);
  {$ELSE}
  if not IsLibraryAvailable('libQt5Pas') then
    Missing.Add(DEP_LIBQT5PAS);
  {$ENDIF}

  if not IsNerdFontInstalled then
    Missing.Add(DEP_NERDFONTS);

  Result := Missing.Count = 0;
end;

initialization
  InitCriticalSection(GGlobalLogLock);
  InstallStdoutHook;

finalization
  DoneCriticalSection(GGlobalLogLock);
  if Assigned(GGlobalLogList) then
    FreeAndNil(GGlobalLogList);

end.
