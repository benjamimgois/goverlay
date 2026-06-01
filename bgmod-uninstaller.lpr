program bgmod_uninstaller;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles, Process, BaseUnix, Unix;

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

procedure Log(const Msg: string);
var
  F: TextFile;
  LogMsg: string;
begin
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
  i: Integer;
begin
  GameDir := '';
  
  // 1. Check command line arguments for .exe
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if LowerCase(ExtractFileExt(Arg)) = '.exe' then
    begin
      // Game launcher replacements
      if (Pos('Cyberpunk 2077', Arg) > 0) and (Pos('REDprelauncher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'REDprelauncher.exe', 'bin/x64/Cyberpunk2077.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Witcher 3', Arg) > 0) and (Pos('REDprelauncher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'REDprelauncher.exe', 'bin/x64_dx12/witcher3.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Baldurs Gate 3', Arg) > 0) and (Pos('Launcher/LariLauncher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'Launcher/LariLauncher.exe', 'bin/bg3_dx11.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Baldurs Gate 3', Arg) > 0) and (Pos('Launcher\LariLauncher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'Launcher\LariLauncher.exe', 'bin/bg3_dx11.exe', [rfReplaceAll, rfIgnoreCase])
      else if ((Pos('HITMAN 3', Arg) > 0) or (Pos('HITMAN World of Assassination', Arg) > 0)) and (Pos('Launcher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'Launcher.exe', 'Retail/HITMAN3.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('SYNCED', Arg) > 0) and (Pos('Launcher/sop_launcher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'Launcher/sop_launcher.exe', 'SYNCED.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('2KLauncher', Arg) > 0) and (Pos('2KLauncher/LauncherPatcher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, '2KLauncher/LauncherPatcher.exe', 'DoesntMatter.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Warhammer 40,000 DARKTIDE', Arg) > 0) and (Pos('launcher/Launcher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'launcher/Launcher.exe', 'binaries/Darktide.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Warhammer Vermintide 2', Arg) > 0) and (Pos('launcher/Launcher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'launcher/Launcher.exe', 'binaries_dx12/vermintide2_dx12.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('Satisfactory', Arg) > 0) and (Pos('FactoryGameSteam.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'FactoryGameSteam.exe', 'Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('FINAL FANTASY XIV Online', Arg) > 0) and (Pos('boot/ffxivboot.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'boot/ffxivboot.exe', 'game/ffxiv_dx11.exe', [rfReplaceAll, rfIgnoreCase])
      else if (Pos('DuneAwakening', Arg) > 0) and (Pos('Launcher/FuncomLauncher.exe', Arg) > 0) then
        Arg := StringReplace(Arg, 'Launcher/FuncomLauncher.exe', 'DuneSandbox/Binaries/Win64/DuneSandbox-Win64-Shipping.exe', [rfReplaceAll, rfIgnoreCase]);
        
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

procedure SafeRestoreFile(const TargetDir, DllFile: string);
var
  FullSrc, FullDest: string;
begin
  FullSrc := IncludeTrailingPathDelimiter(TargetDir) + DllFile + '.b';
  FullDest := IncludeTrailingPathDelimiter(TargetDir) + DllFile;
  
  if FileExists(FullSrc) then
  begin
    try
      SafeDeleteFile(FullDest);
      if RenameFile(FullSrc, FullDest) then
        Log('Restored original ' + DllFile)
      else
        Log('Failed to restore ' + DllFile);
    except
      on E: Exception do
        Log('Exception restoring ' + DllFile + ': ' + E.Message);
    end;
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
  FilesToClean: array[0..38] of string = (
    'OptiScaler.dll', 'dxgi.dll', 'winmm.dll', 'dbghelp.dll', 'version.dll', 'wininet.dll', 'winhttp.dll',
    'OptiScaler.ini', 'OptiScaler.log', 'OptiScaler.asi',
    'dlssg_to_fsr3_amd_is_better.dll', 'dlssg_to_fsr3.ini', 'dlssg_to_fsr3.log',
    'nvapi64.dll', 'fakenvapi.ini', 'fakenvapi.log', 'fakenvapi.dll',
    'libxess.dll', 'libxess_dx11.dll', 'libxess_fg.dll', 'libxell.dll', 'nvngx.dll', 'nvngx.ini',
    'amd_fidelityfx_dx12.dll', 'amd_fidelityfx_framegeneration_dx12.dll', 'amd_fidelityfx_upscaler_dx12.dll', 'amd_fidelityfx_vk.dll',
    'nvngx_dlss.dll', 'nvngx_dlssd.dll', 'nvngx_dlssg.dll',
    'dlss-enabler.dll', 'dlss-enabler-upscaler.dll', 'dlss-enabler.log',
    'nvngx-wrapper.dll', '_nvngx.dll', 'dlssg_to_fsr3_amd_is_better-3.0.dll',
    'MangoHud.conf', 'vkBasalt.conf', 'vkSumi.conf'
  );
  OriginalDlls: array[0..14] of string = (
    'd3dcompiler_47.dll', 'amd_fidelityfx_dx12.dll', 'amd_fidelityfx_framegeneration_dx12.dll', 
    'amd_fidelityfx_upscaler_dx12.dll', 'amd_fidelityfx_vk.dll', 'libxess.dll', 'libxess_dx11.dll', 
    'libxess_fg.dll', 'libxell.dll', 'dxgi.dll', 'winmm.dll', 'dbghelp.dll', 'version.dll', 
    'wininet.dll', 'winhttp.dll'
  );

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
      
      // 1. Remove copied files
      for i := 0 to High(FilesToClean) do
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + FilesToClean[i]);
        
      // 2. Remove plugins folder
      SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'plugins');
      
      // 3. Restore backups
      for i := 0 to High(OriginalDlls) do
        SafeRestoreFile(GameDir, OriginalDlls[i]);
        
      // 4. Remove wrappers and script configs
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
