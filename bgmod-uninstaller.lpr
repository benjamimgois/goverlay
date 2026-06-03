program bgmod_uninstaller;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles, Process, BaseUnix, Unix;

function GetBGModPath: string; forward;

function CopyFile(const Src, Dst: string): Boolean;
var
  SrcStream, DstStream: TFileStream;
begin
  Result := False;
  try
    SrcStream := TFileStream.Create(Src, fmOpenRead or fmShareDenyWrite);
    try
      DstStream := TFileStream.Create(Dst, fmCreate);
      try
        DstStream.CopyFrom(SrcStream, SrcStream.Size);
        Result := True;
      finally
        DstStream.Free;
      end;
    finally
      SrcStream.Free;
    end;
  except
    // ignore copy failures
  end;
end;

function setenv(name: PChar; value: PChar; overwrite: Integer): Integer; cdecl; external 'c' name 'setenv';
function execvp(file_: PChar; argv: PPChar): Integer; cdecl; external 'c' name 'execvp';

procedure SetEnvironmentVariable(const Name, Value: string);
begin
  setenv(PChar(Name), PChar(Value), 1);
end;

var
  GameDir: string;
  CentralLogDir: string;
  CentralLogFile: string;

procedure UpdateCentralLogPaths;
var
  DataHome, GameDirName: string;
begin
  if GameDir = '' then Exit;
  GameDirName := ExtractFileName(ExcludeTrailingPathDelimiter(GameDir));
  if GameDirName = '' then Exit;
  
  if CentralLogFile = '' then
  begin
    DataHome := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
    if DataHome = '' then
      DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
    if DataHome = '' then
      DataHome := GetUserDir + '.local/share';
      
    CentralLogDir := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'logs' + PathDelim + GameDirName;
    CentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'bgmod-uninstaller.log';
  end;
end;

procedure Log(const Msg: string);
var
  F: TextFile;
  LogMsg: string;
begin
  if (GameDir <> '') and (CentralLogFile = '') then
    UpdateCentralLogPaths;

  LogMsg := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - ' + Msg;
  WriteLn(LogMsg);
  
  // Append to /tmp/bgmod-uninstaller.log
  try
    AssignFile(F, '/tmp/bgmod-uninstaller.log');
    if FileExists('/tmp/bgmod-uninstaller.log') then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, LogMsg);
    CloseFile(F);
  except
    // ignore logging failures
  end;
  
  // Append to game directory bgmod-uninstaller.log if resolved
  if GameDir <> '' then
  begin
    try
      AssignFile(F, IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller.log');
      if FileExists(IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller.log') then
        Append(F)
      else
        Rewrite(F);
      WriteLn(F, LogMsg);
      CloseFile(F);
    except
      // ignore logging failures
    end;
  end;
  
  // Append to central GOverlay logs directory if resolved
  if CentralLogFile <> '' then
  begin
    try
      if not DirectoryExists(CentralLogDir) then
        ForceDirectories(CentralLogDir);
      AssignFile(F, CentralLogFile);
      if FileExists(CentralLogFile) then
        Append(F)
      else
        Rewrite(F);
      WriteLn(F, LogMsg);
      CloseFile(F);
    except
      // ignore logging failures
    end;
  end;
end;

function GetCommandOutput(const Cmd: string): string;
var
  Proc: TProcess;
  List: TStringList;
begin
  Result := '';
  Proc := TProcess.Create(nil);
  List := TStringList.Create;
  try
    Proc.Executable := '/bin/sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(Cmd);
    Proc.Options := [poUsePipes, poWaitOnExit];
    Proc.Execute;
    List.LoadFromStream(Proc.Output);
    Result := Trim(List.Text);
  except
    on E: Exception do
      Log('Error running shell command: ' + E.Message);
  end;
  List.Free;
  Proc.Free;
end;

function FindUEShippingExe(const BaseDir: string; Depth: Integer): string;
var
  SR: TSearchRec;
  SearchPath, Res: string;
begin
  Result := '';
  if Depth > 4 then Exit;
  
  if DirectoryExists(IncludeTrailingPathDelimiter(BaseDir) + 'Binaries' + PathDelim + 'Win64') then
  begin
    SearchPath := IncludeTrailingPathDelimiter(BaseDir) + 'Binaries' + PathDelim + 'Win64' + PathDelim + '*.exe';
    if FindFirst(SearchPath, faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) = 0 then
          begin
            Result := IncludeTrailingPathDelimiter(BaseDir) + 'Binaries' + PathDelim + 'Win64';
            Break;
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
      if Result <> '' then Exit;
    end;
  end;

  SearchPath := IncludeTrailingPathDelimiter(BaseDir) + '*';
  if FindFirst(SearchPath, faDirectory, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) <> 0) then
        begin
          if UpperCase(SR.Name) <> 'ENGINE' then
          begin
            Res := FindUEShippingExe(IncludeTrailingPathDelimiter(BaseDir) + SR.Name, Depth + 1);
            if Res <> '' then
            begin
              Result := Res;
              Break;
            end;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

procedure ResolveGameDirectory;
var
  Arg, ExePath, LutrisId, Cmd: string;
  i, j, PosPipe: Integer;
  LauncherIni: TIniFile;
  LauncherList: TStringList;
  KeyLine, KeyName, EntryVal, TargetSub, Repl, CleanKey, ConfPath: string;
begin
  GameDir := '';
  
  // 1. Check command line arguments for .exe
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if LowerCase(ExtractFileExt(Arg)) = '.exe' then
    begin
      // Game launcher replacements
      LauncherList := TStringList.Create;
      LauncherIni := nil;
      try
        ConfPath := ExtractFilePath(ParamStr(0)) + 'bgmod.conf';
        if not FileExists(ConfPath) then
          ConfPath := IncludeTrailingPathDelimiter(GetBGModPath) + 'bgmod.conf';
          
        if FileExists(ConfPath) then
        begin
          LauncherIni := TIniFile.Create(ConfPath);
          LauncherIni.ReadSectionValues('Launchers', LauncherList);
        end;
        
        if LauncherList.Count = 0 then
        begin
          LauncherList.Add('Cyberpunk 2077=REDprelauncher.exe|bin/x64/Cyberpunk2077.exe');
          LauncherList.Add('Witcher 3=REDprelauncher.exe|bin/x64_dx12/witcher3.exe');
          LauncherList.Add('Baldurs Gate 3=Launcher/LariLauncher.exe|bin/bg3_dx11.exe');
          LauncherList.Add('Baldurs Gate 3 Alt=Launcher\LariLauncher.exe|bin/bg3_dx11.exe');
          LauncherList.Add('HITMAN 3=Launcher.exe|Retail/HITMAN3.exe');
          LauncherList.Add('HITMAN World of Assassination=Launcher.exe|Retail/HITMAN3.exe');
          LauncherList.Add('SYNCED=Launcher/sop_launcher.exe|SYNCED.exe');
          LauncherList.Add('2KLauncher=2KLauncher/LauncherPatcher.exe|DoesntMatter.exe');
          LauncherList.Add('Warhammer 40,000 DARKTIDE=launcher/Launcher.exe|binaries/Darktide.exe');
          LauncherList.Add('Warhammer Vermintide 2=launcher/Launcher.exe|binaries_dx12/vermintide2_dx12.exe');
          LauncherList.Add('Satisfactory=FactoryGameSteam.exe|Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe');
          LauncherList.Add('FINAL FANTASY XIV Online=boot/ffxivboot.exe|game/ffxiv_dx11.exe');
          LauncherList.Add('DuneAwakening=Launcher/FuncomLauncher.exe|DuneSandbox/Binaries/Win64/DuneSandbox-Win64-Shipping.exe');
        end;
        
        for j := 0 to LauncherList.Count - 1 do
        begin
          KeyLine := LauncherList[j];
          PosPipe := Pos('=', KeyLine);
          if PosPipe > 0 then
          begin
            KeyName := Trim(Copy(KeyLine, 1, PosPipe - 1));
            CleanKey := KeyName;
            if Pos(' Alt', CleanKey) > 0 then
              CleanKey := Copy(CleanKey, 1, Pos(' Alt', CleanKey) - 1);
            if Pos(' alt', CleanKey) > 0 then
              CleanKey := Copy(CleanKey, 1, Pos(' alt', CleanKey) - 1);
              
            EntryVal := Trim(Copy(KeyLine, PosPipe + 1, MaxInt));
            PosPipe := Pos('|', EntryVal);
            if PosPipe > 0 then
            begin
              TargetSub := Trim(Copy(EntryVal, 1, PosPipe - 1));
              Repl := Trim(Copy(EntryVal, PosPipe + 1, MaxInt));
              
              if (Pos(CleanKey, Arg) > 0) and (Pos(TargetSub, Arg) > 0) then
              begin
                Arg := StringReplace(Arg, TargetSub, Repl, [rfReplaceAll, rfIgnoreCase]);
                Break;
              end;
            end;
          end;
        end;
      finally
        if Assigned(LauncherIni) then
          LauncherIni.Free;
        LauncherList.Free;
      end;
      
      GameDir := ExtractFilePath(Arg);
      Log('Resolved GameDir from argument: ' + GameDir);
      Break;
    end;
  end;
  
  // 2. Check command line arguments for Lutris game run ID
  if GameDir = '' then
  begin
    for i := 1 to ParamCount do
    begin
      Arg := ParamStr(i);
      if Pos('lutris:rungameid/', Arg) = 1 then
      begin
        LutrisId := Copy(Arg, Length('lutris:rungameid/') + 1, MaxInt);
        Log('Detected Lutris game ID: ' + LutrisId);
        
        Cmd := 'lutris_id=' + LutrisId + '; slug=$(lutris --list-games --json 2>/dev/null | jq -r ".[] | select(.id == $lutris_id) | .slug"); [ -n "$slug" ] && config_file=$(find ~/.config/lutris/games/ -iname "${slug}-*.yml" | head -1); [ -n "$config_file" ] && grep -E "^\s*exe:" "$config_file" | sed "s/.*exe:[[:space:]]*//"';
        ExePath := GetCommandOutput(Cmd);
        if ExePath <> '' then
        begin
          GameDir := ExtractFilePath(ExePath);
          Log('Resolved Lutris GameDir: ' + GameDir);
        end
        else
          Log('Failed to resolve Lutris slug or game configuration file');
        Break;
      end;
    end;
  end;
  
  // 3. Check STEAM_COMPAT_INSTALL_PATH fallback
  if GameDir = '' then
  begin
    GameDir := GetEnvironmentVariable('STEAM_COMPAT_INSTALL_PATH');
    if GameDir <> '' then
      Log('Resolved GameDir from STEAM_COMPAT_INSTALL_PATH: ' + GameDir);
  end;
  
  // 4. Unreal Engine subfolder resolution
  if (GameDir <> '') and DirectoryExists(IncludeTrailingPathDelimiter(GameDir) + 'Engine') then
  begin
    Log('UE Engine folder detected, searching for shipping executable...');
    ExePath := FindUEShippingExe(GameDir, 1);
    if ExePath <> '' then
    begin
      GameDir := ExePath;
      Log('Adjusted UE GameDir: ' + GameDir);
    end;
  end;
end;

procedure SafeDeleteFile(const Path: string);
begin
  if not FileExists(Path) then Exit;
  try
    if DeleteFile(Path) then
      Log('Cleaned up file: ' + Path)
    else
      Log('Failed to delete file: ' + Path);
  except
    on E: Exception do
      Log('Exception deleting ' + Path + ': ' + E.Message);
  end;
end;

procedure SafeDeleteDirectory(const Path: string);
var
  SR: TSearchRec;
  FileP: string;
begin
  if not DirectoryExists(Path) then Exit;
  
  if FindFirst(IncludeTrailingPathDelimiter(Path) + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          FileP := IncludeTrailingPathDelimiter(Path) + SR.Name;
          if (SR.Attr and faDirectory) <> 0 then
            SafeDeleteDirectory(FileP)
          else
            SafeDeleteFile(FileP);
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
  
  try
    if RemoveDir(Path) then
      Log('Removed directory: ' + Path)
    else
      Log('Failed to remove directory: ' + Path);
  except
    on E: Exception do
      Log('Exception removing directory ' + Path + ': ' + E.Message);
  end;
end;

procedure SafeCleanOrRestore(const TargetDir, FileName: string; IsOriginalGameFile: Boolean);
var
  FullFile, FullBackup: string;
begin
  FullFile := IncludeTrailingPathDelimiter(TargetDir) + FileName;
  FullBackup := FullFile + '.b';
  
  if FileExists(FullBackup) then
  begin
    try
      if FileExists(FullFile) then
        DeleteFile(FullFile);
      if RenameFile(FullBackup, FullFile) then
        Log('Restored original ' + FileName)
      else
        Log('Failed to restore ' + FileName);
    except
      on E: Exception do
        Log('Exception restoring ' + FileName + ': ' + E.Message);
    end;
  end
  else if not IsOriginalGameFile then
  begin
    SafeDeleteFile(FullFile);
  end;
end;


function GetBGModPath: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'bgmod';
end;

var
  UninstallerPath, TempStr, Key, Val, Line, CurrentOverrides: string;
  i, StartArgIdx: Integer;
  Args: array of PChar;
  ArgsStrings: array of string;
  IsGlobalUninstall: Boolean;


begin
  GameDir := '';
  UninstallerPath := ExtractFilePath(ParamStr(0));
  
  // Resolve central GOverlay log path
  CentralLogDir := '';
  CentralLogFile := '';
  if UninstallerPath <> '' then
  begin
    TempStr := ExcludeTrailingPathDelimiter(UninstallerPath);
    Key := ExtractFileName(TempStr); // GameName or 'bgmod'
    Val := ExtractFilePath(TempStr); // Parent folder path (e.g. gameconfig/ or share/goverlay/)
    if Val <> '' then
    begin
      Line := ExtractFileName(ExcludeTrailingPathDelimiter(Val));
      CurrentOverrides := ExtractFilePath(ExcludeTrailingPathDelimiter(Val));
      if LowerCase(Line) = 'gameconfig' then
      begin
        CentralLogDir := IncludeTrailingPathDelimiter(CurrentOverrides) + 'logs' + PathDelim + Key;
        CentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'bgmod-uninstaller.log';
      end
      else if LowerCase(Key) = 'bgmod' then
      begin
        CentralLogDir := IncludeTrailingPathDelimiter(Val) + 'logs';
        CentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'bgmod-uninstaller.log';
      end;
    end;
  end;

  IsGlobalUninstall := False;
  for i := 1 to ParamCount do
  begin
    if (ParamStr(i) = '--global') or (ParamStr(i) = '-g') then
    begin
      IsGlobalUninstall := True;
      Break;
    end;
  end;

  if IsGlobalUninstall then
  begin
    TempStr := GetBGModPath;
    Log('========================= bgmod global uninstall =========================');
    Log('Target directory to delete: ' + TempStr);
    if DirectoryExists(TempStr) then
    begin
      SafeDeleteDirectory(TempStr);
      Log('Global bgmod directory removed.');
    end
    else
      Log('Global bgmod directory not found.');
    Exit;
  end;

  // Resolve the game folder directory
  ResolveGameDirectory;
  
  Log('========================= bgmod uninstaller initialization =========================');
  Log('Uninstaller location: ' + UninstallerPath);
  Log('Game directory: ' + GameDir);

  if GameDir <> '' then
  begin
    if not DirectoryExists(GameDir) then
      Log('Error: Resolved game directory does not exist: ' + GameDir)
    else if fpAccess(PChar(GameDir), W_OK) <> 0 then
      Log('Error: No write permission to game directory: ' + GameDir)
    else
    begin
      Log('Starting uninstallation from game directory...');
      
      // Original game files (ONLY restore if backup exists, do NOT delete if no backup)
      SafeCleanOrRestore(GameDir, 'd3dcompiler_47.dll', True);
      SafeCleanOrRestore(GameDir, 'amd_fidelityfx_dx12.dll', True);
      SafeCleanOrRestore(GameDir, 'amd_fidelityfx_framegeneration_dx12.dll', True);
      SafeCleanOrRestore(GameDir, 'amd_fidelityfx_upscaler_dx12.dll', True);
      SafeCleanOrRestore(GameDir, 'amd_fidelityfx_vk.dll', True);
      SafeCleanOrRestore(GameDir, 'libxess.dll', True);
      SafeCleanOrRestore(GameDir, 'libxess_dx11.dll', True);
      SafeCleanOrRestore(GameDir, 'libxess_fg.dll', True);
      SafeCleanOrRestore(GameDir, 'libxell.dll', True);
      
      // Copied proxy/supporting files (restore if backup exists, otherwise safe to delete)
      SafeCleanOrRestore(GameDir, 'OptiScaler.dll', False);
      SafeCleanOrRestore(GameDir, 'dxgi.dll', False);
      SafeCleanOrRestore(GameDir, 'winmm.dll', False);
      SafeCleanOrRestore(GameDir, 'dbghelp.dll', False);
      SafeCleanOrRestore(GameDir, 'version.dll', False);
      SafeCleanOrRestore(GameDir, 'wininet.dll', False);
      SafeCleanOrRestore(GameDir, 'winhttp.dll', False);
      SafeCleanOrRestore(GameDir, 'OptiScaler.ini', False);
      SafeCleanOrRestore(GameDir, 'OptiScaler.log', False);
      SafeCleanOrRestore(GameDir, 'OptiScaler.asi', False);
      SafeCleanOrRestore(GameDir, 'dlssg_to_fsr3_amd_is_better.dll', False);
      SafeCleanOrRestore(GameDir, 'dlssg_to_fsr3.ini', False);
      SafeCleanOrRestore(GameDir, 'dlssg_to_fsr3.log', False);
      SafeCleanOrRestore(GameDir, 'nvapi64.dll', False);
      SafeCleanOrRestore(GameDir, 'fakenvapi.ini', False);
      SafeCleanOrRestore(GameDir, 'fakenvapi.log', False);
      SafeCleanOrRestore(GameDir, 'fakenvapi.dll', False);
      SafeCleanOrRestore(GameDir, 'nvngx.dll', True);
      SafeCleanOrRestore(GameDir, 'nvngx.ini', False);
      SafeCleanOrRestore(GameDir, 'nvngx_dlss.dll', True);
      SafeCleanOrRestore(GameDir, 'nvngx_dlssd.dll', True);
      SafeCleanOrRestore(GameDir, 'nvngx_dlssg.dll', True);
      SafeCleanOrRestore(GameDir, 'dlss-enabler.dll', False);
      SafeCleanOrRestore(GameDir, 'dlss-enabler-upscaler.dll', False);
      SafeCleanOrRestore(GameDir, 'dlss-enabler.log', False);
      SafeCleanOrRestore(GameDir, 'nvngx-wrapper.dll', False);
      SafeCleanOrRestore(GameDir, '_nvngx.dll', False);
      SafeCleanOrRestore(GameDir, 'dlssg_to_fsr3_amd_is_better-3.0.dll', False);
      SafeCleanOrRestore(GameDir, 'MangoHud.conf', False);
      SafeCleanOrRestore(GameDir, 'vkBasalt.conf', False);
      SafeCleanOrRestore(GameDir, 'vkSumi.conf', False);
      
      // Remove plugins folder
      SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'plugins');
      SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'D3D12_OptiScaler');
      
      // Remove wrappers and script configs
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'fgmod');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller.sh');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod-remover.sh');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod.conf');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod.log');
      SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller');
      
      Log('Uninstallation from game directory completed.');
    end;
  end;

  // Execute the game/original command if requested
  StartArgIdx := 1;
  while (StartArgIdx <= ParamCount) and ((ParamStr(StartArgIdx) = '--') or (ParamStr(StartArgIdx) = '--global') or (ParamStr(StartArgIdx) = '-g')) do
    Inc(StartArgIdx);
    
  if StartArgIdx > ParamCount then
  begin
    Log('bgmod uninstaller done.');
    Exit;
  end;
  
  TempStr := ParamStr(StartArgIdx);
  Log('Game Executable: ' + TempStr);
  
  SetLength(ArgsStrings, ParamCount - StartArgIdx + 1);
  SetLength(Args, ParamCount - StartArgIdx + 2);
  
  ArgsStrings[0] := TempStr;
  Args[0] := PChar(ArgsStrings[0]);
  
  for i := StartArgIdx + 1 to ParamCount do
  begin
    ArgsStrings[i - StartArgIdx] := ParamStr(i);
    Args[i - StartArgIdx] := PChar(ArgsStrings[i - StartArgIdx]);
    Log('Arg ' + IntToStr(i - StartArgIdx) + ': ' + ArgsStrings[i - StartArgIdx]);
  end;
  Args[ParamCount - StartArgIdx + 1] := nil;
  
  Log('------------------------------------------------------------------------');
  Log('Launching subprocess: ' + ArgsStrings[0]);
  Log('------------------------------------------------------------------------');
  
  execvp(Args[0], @Args[0]);
  
  // If we reach here, execvp failed
  Log('Error: execvp failed');
  Halt(127);
end.
