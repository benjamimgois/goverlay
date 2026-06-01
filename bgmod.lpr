program bgmod;

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
  
  // Append to /tmp/bgmod.log
  try
    AssignFile(F, '/tmp/bgmod.log');
    if FileExists('/tmp/bgmod.log') then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, LogMsg);
    CloseFile(F);
  except
    // ignore logging failures
  end;
  
  // Append to game directory bgmod.log if resolved
  if GameDir <> '' then
  begin
    try
      AssignFile(F, IncludeTrailingPathDelimiter(GameDir) + 'bgmod.log');
      if FileExists(IncludeTrailingPathDelimiter(GameDir) + 'bgmod.log') then
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

procedure CopyDirectory(const SrcDir, DestDir: string);
var
  SR: TSearchRec;
  SrcFile, DestFile: string;
begin
  if not DirectoryExists(DestDir) then
    ForceDirectories(DestDir);
    
  if FindFirst(IncludeTrailingPathDelimiter(SrcDir) + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          SrcFile := IncludeTrailingPathDelimiter(SrcDir) + SR.Name;
          DestFile := IncludeTrailingPathDelimiter(DestDir) + SR.Name;
          
          if (SR.Attr and faDirectory) <> 0 then
            CopyDirectory(SrcFile, DestFile)
          else
          begin
            try
              if FileExists(DestFile) then
                DeleteFile(DestFile);
              CopyFile(SrcFile, DestFile);
              // Ensure permissions are copied
              fpChmod(DestFile, &755);
            except
              on E: Exception do
                Log('Failed to copy file ' + SrcFile + ' -> ' + DestFile + ': ' + E.Message);
            end;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

procedure SafeCopyFile(const Src, Dest: string);
begin
  if not FileExists(Src) then
  begin
    Log('Warning: Source file ' + Src + ' does not exist, skipping copy');
    Exit;
  end;
  try
    ForceDirectories(ExtractFilePath(Dest));
    if FileExists(Dest) then
      DeleteFile(Dest);
    if CopyFile(Src, Dest) then
    begin
      fpChmod(Dest, &755);
      Log('Successfully copied: ' + Src + ' -> ' + Dest);
    end
    else
      Log('Failed to copy: ' + Src + ' -> ' + Dest);
  except
    on E: Exception do
      Log('Exception copying ' + Src + ' -> ' + Dest + ': ' + E.Message);
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

procedure SafeBackupFile(const TargetDir, DllFile: string);
var
  FullSrc, FullDest: string;
begin
  FullSrc := IncludeTrailingPathDelimiter(TargetDir) + DllFile;
  FullDest := FullSrc + '.b';
  
  if FileExists(FullSrc) and not FileExists(FullDest) then
  begin
    try
      if RenameFile(FullSrc, FullDest) then
        Log('Backed up original ' + DllFile + ' -> ' + DllFile + '.b')
      else
        Log('Failed to backup ' + DllFile);
    except
      on E: Exception do
        Log('Exception backing up ' + DllFile + ': ' + E.Message);
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

var
  BgmodPath, DllName, DllBase, CurrentOverrides, NewOverrides, TempStr: string;
  GOverlayMangoHud, GOverlayVkBasalt, GOverlayOptiscaler, GOverlayTweaks, PreserveIni: Boolean;
  Ini: TIniFile;
  EnvList: TStringList;
  i, p, StartArgIdx: Integer;
  Key, Val, Line: string;
  Args: array of PChar;
  ArgsStrings: array of string;
  OrigDlls: array[0..4] of string = (
    'd3dcompiler_47.dll',
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_framegeneration_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'amd_fidelityfx_vk.dll'
  );
  ProxyDlls: array[0..5] of string = (
    'dxgi.dll',
    'winmm.dll',
    'dbghelp.dll',
    'version.dll',
    'wininet.dll',
    'winhttp.dll'
  );

begin
  BgmodPath := ExtractFilePath(ParamStr(0));
  
  // Resolve central GOverlay log path
  CentralLogDir := '';
  CentralLogFile := '';
  if BgmodPath <> '' then
  begin
    TempStr := ExcludeTrailingPathDelimiter(BgmodPath);
    Key := ExtractFileName(TempStr); // GameName or 'bgmod'
    Val := ExtractFilePath(TempStr); // Parent folder path (e.g. gameconfig/ or share/goverlay/)
    if Val <> '' then
    begin
      Line := ExtractFileName(ExcludeTrailingPathDelimiter(Val)); // 'gameconfig' or 'goverlay' or similar
      CurrentOverrides := ExtractFilePath(ExcludeTrailingPathDelimiter(Val)); // GOverlay base path (e.g. ~/.local/share/goverlay/)
      if LowerCase(Line) = 'gameconfig' then
      begin
        CentralLogDir := IncludeTrailingPathDelimiter(CurrentOverrides) + 'logs' + PathDelim + Key;
        CentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'bgmod.log';
      end
      else if LowerCase(Key) = 'bgmod' then
      begin
        CentralLogDir := IncludeTrailingPathDelimiter(Val) + 'logs';
        CentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'bgmod.log';
      end;
    end;
  end;
  
  // Default values
  GOverlayMangoHud := False;
  GOverlayVkBasalt := False;
  GOverlayOptiscaler := False;
  GOverlayTweaks := False;
  DllName := 'dxgi.dll';
  PreserveIni := True;
  
  EnvList := TStringList.Create;
  
  // Read configurations from bgmod.conf
  if FileExists(BgmodPath + 'bgmod.conf') then
  begin
    Ini := TIniFile.Create(BgmodPath + 'bgmod.conf');
    try
      GOverlayMangoHud := Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '0') = '1';
      GOverlayVkBasalt := Ini.ReadString('Config', 'GOVERLAY_VKBASALT', '0') = '1';
      GOverlayOptiscaler := Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '0') = '1';
      GOverlayTweaks := Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '0') = '1';
      DllName := Ini.ReadString('Config', 'DLL', 'dxgi.dll');
      PreserveIni := Ini.ReadString('Config', 'PRESERVE_INI', 'true') = 'true';
      
      Ini.ReadSectionValues('Env', EnvList);
    finally
      Ini.Free;
    end;
  end;
  
  // Resolve the game folder directory
  ResolveGameDirectory;
  
  Log('========================= bgmod initialization =========================');
  Log('bgmod location: ' + BgmodPath);
  Log('Game directory: ' + GameDir);
  Log('Config: MangoHud=' + BoolToStr(GOverlayMangoHud, '1', '0') + 
      ', vkBasalt=' + BoolToStr(GOverlayVkBasalt, '1', '0') + 
      ', OptiScaler=' + BoolToStr(GOverlayOptiscaler, '1', '0') + 
      ', Tweaks=' + BoolToStr(GOverlayTweaks, '1', '0') +
      ', DLL=' + DllName +
      ', PreserveIni=' + BoolToStr(PreserveIni, 'true', 'false'));
      
  // Copy and configure files for the game
  if GameDir <> '' then
  begin
    if not DirectoryExists(GameDir) then
      Log('Error: Resolved game directory does not exist: ' + GameDir)
    else if fpAccess(PChar(GameDir), W_OK) <> 0 then
      Log('Error: No write permission to game directory: ' + GameDir)
    else
    begin
      // --- OptiScaler Copy and Configuration ---
      if GOverlayOptiscaler then
      begin
        Log('Installing OptiScaler files...');
        // 1. Cleanup old injectors
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvngx.dll');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + '_nvngx.dll');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvngx-wrapper.dll');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'dlss-enabler.dll');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');
        
        // 2. Backup original DLLs
        for i := 0 to High(OrigDlls) do
          SafeBackupFile(GameDir, OrigDlls[i]);
          
        // 3. Backup proxy DLLs
        for i := 0 to High(ProxyDlls) do
          SafeBackupFile(GameDir, ProxyDlls[i]);
          
        // 4. Remove conflicting nvapi64 files
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvapi64.dll');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvapi64.dll.b');
        
        // 5. Core Install - Copy proxy DLL
        if FileExists(BgmodPath + 'renames' + PathDelim + DllName) then
        begin
          Log('Using pre-renamed dll ' + DllName);
          SafeCopyFile(BgmodPath + 'renames' + PathDelim + DllName, IncludeTrailingPathDelimiter(GameDir) + DllName);
        end
        else
        begin
          Log('Pre-renamed dll not found, falling back to OptiScaler.dll as ' + DllName);
          SafeCopyFile(BgmodPath + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + DllName);
        end;
        
        // 6. OptiScaler.ini Handling
        if PreserveIni and FileExists(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini') then
          Log('Preserving existing OptiScaler.ini')
        else
          SafeCopyFile(BgmodPath + 'OptiScaler.ini', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini');
          
        // 7. Copy plugins/ folder if it exists
        if DirectoryExists(BgmodPath + 'plugins') then
        begin
          Log('Installing ASI plugins directory...');
          CopyDirectory(BgmodPath + 'plugins', IncludeTrailingPathDelimiter(GameDir) + 'plugins');
        end;
        
        // 8. Copy supporting libraries
        SafeCopyFile(BgmodPath + 'libxess.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess.dll');
        SafeCopyFile(BgmodPath + 'libxess_dx11.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess_dx11.dll');
        SafeCopyFile(BgmodPath + 'libxess_fg.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess_fg.dll');
        SafeCopyFile(BgmodPath + 'libxell.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxell.dll');
        SafeCopyFile(BgmodPath + 'amd_fidelityfx_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_dx12.dll');
        SafeCopyFile(BgmodPath + 'amd_fidelityfx_framegeneration_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_framegeneration_dx12.dll');
        SafeCopyFile(BgmodPath + 'amd_fidelityfx_upscaler_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_upscaler_dx12.dll');
        SafeCopyFile(BgmodPath + 'amd_fidelityfx_vk.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_vk.dll');
        SafeCopyFile(BgmodPath + 'nvngx.dll', IncludeTrailingPathDelimiter(GameDir) + 'nvngx.dll');
        
        // 9. Copy Nukem FG
        SafeCopyFile(BgmodPath + 'dlssg_to_fsr3_amd_is_better.dll', IncludeTrailingPathDelimiter(GameDir) + 'dlssg_to_fsr3_amd_is_better.dll');
        
        // 10. Copy FakeNVAPI
        SafeCopyFile(BgmodPath + 'fakenvapi.dll', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.dll');
        SafeCopyFile(BgmodPath + 'fakenvapi.ini', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.ini');
        
        // 11. Copy uninstaller
        SafeCopyFile(BgmodPath + 'bgmod-uninstaller', IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller');
      end;
      
      // --- MangoHud Configuration Copy ---
      if GOverlayMangoHud then
        SafeCopyFile(BgmodPath + 'MangoHud.conf', IncludeTrailingPathDelimiter(GameDir) + 'MangoHud.conf');
        
      // --- vkBasalt Configuration Copy ---
      if GOverlayVkBasalt then
      begin
        SafeCopyFile(BgmodPath + 'vkBasalt.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf');
        SafeCopyFile(BgmodPath + 'vkSumi.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf');
      end;
    end;
  end;
  
  // Set up Environment Variables
  Log('Exporting environment variables...');
  
  // Export environment variables read from bgmod.conf [Env] section
  if GOverlayTweaks then
  begin
    for i := 0 to EnvList.Count - 1 do
    begin
      Line := EnvList[i];
      p := Pos('=', Line);
      if p > 0 then
      begin
        Key := Copy(Line, 1, p - 1);
        Val := Copy(Line, p + 1, MaxInt);
        SetEnvironmentVariable(Key, Val);
        Log('Export [Env]: ' + Key + '=' + Val);
      end;
    end;
  end;
  
  // Export explicit config flags
  if GOverlayMangoHud then
  begin
    SetEnvironmentVariable('MANGOHUD', '1');
    Log('Export: MANGOHUD=1');
  end;
  if GOverlayVkBasalt then
  begin
    SetEnvironmentVariable('ENABLE_VKBASALT', '1');
    SetEnvironmentVariable('ENABLE_VKSUMI', '1');
    Log('Export: ENABLE_VKBASALT=1, ENABLE_VKSUMI=1');
  end;
  if GOverlayOptiscaler then
  begin
    DllBase := ChangeFileExt(DllName, '');
    CurrentOverrides := GetEnvironmentVariable('WINEDLLOVERRIDES');
    if CurrentOverrides <> '' then
      NewOverrides := CurrentOverrides + ',' + DllBase + '=n,b'
    else
      NewOverrides := DllBase + '=n,b';
    SetEnvironmentVariable('WINEDLLOVERRIDES', NewOverrides);
    Log('Export WINEDLLOVERRIDES=' + NewOverrides);
  end;
  
  EnvList.Free;
  
  // Execute the game
  StartArgIdx := 1;
  while (StartArgIdx <= ParamCount) and (ParamStr(StartArgIdx) = '--') do
    Inc(StartArgIdx);
    
  if StartArgIdx > ParamCount then
  begin
    Log('bgmod done (no command was specified).');
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
