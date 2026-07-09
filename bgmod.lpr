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

function execvp(file_: PChar; argv: PPChar): Integer; cdecl; external 'c' name 'execvp';
function execvpe(file_: PChar; argv: PPChar; envp: PPChar): Integer; cdecl; external 'c' name 'execvpe';

procedure SetEnvVarInList(EnvStrings: TStringList; const AKey, AVal: string);
var
  idx: Integer;
  Prefix: string;
begin
  Prefix := AKey + '=';
  for idx := 0 to EnvStrings.Count - 1 do
  begin
    if Pos(Prefix, EnvStrings[idx]) = 1 then
    begin
      EnvStrings[idx] := Prefix + AVal;
      Exit;
    end;
  end;
  EnvStrings.Add(Prefix + AVal);
end;

function GetEnvVarFromList(EnvStrings: TStringList; const AKey: string): string;
var
  idx: Integer;
  Prefix: string;
begin
  Prefix := AKey + '=';
  for idx := 0 to EnvStrings.Count - 1 do
  begin
    if Pos(Prefix, EnvStrings[idx]) = 1 then
    begin
      Result := Copy(EnvStrings[idx], Length(Prefix) + 1, MaxInt);
      Exit;
    end;
  end;
  Result := '';
end;

var
  GameDir: string;
  CentralLogDir: string;
  CentralLogFile: string;
  BgmodPath: string;
  ConfigDir: string;
  SourceDir: string;

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
          if (UpperCase(SR.Name) <> 'ENGINE') and
             (UpperCase(SR.Name) <> 'BUGREPORTCLIENT') and
             (UpperCase(SR.Name) <> 'CRASHREPORTCLIENT') then
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

function GetGlobalBGModPath(const LocalBgmodPath: string): string;
var
  DataHome: string;
  PosFlatpak: Integer;
  FlatpakBase: string;
  Ini: TIniFile;
  IsStable: Boolean;
  ChannelFolder: string;
begin
  IsStable := True;
  if FileExists(IncludeTrailingPathDelimiter(LocalBgmodPath) + 'bgmod.conf') then
  begin
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(LocalBgmodPath) + 'bgmod.conf');
    try
      IsStable := Ini.ReadInteger('Config', 'OPT_CHANNEL', 0) <> 1;
    finally
      Ini.Free;
    end;
  end;

  if IsStable then
    ChannelFolder := 'optiscaler-stable'
  else
    ChannelFolder := 'optiscaler-edge';

  PosFlatpak := Pos('io.github.benjamimgois.goverlay', LocalBgmodPath);
  if PosFlatpak > 0 then
  begin
    FlatpakBase := Copy(LocalBgmodPath, 1, PosFlatpak + Length('io.github.benjamimgois.goverlay'));
    Result := IncludeTrailingPathDelimiter(FlatpakBase) + 'data' + PathDelim + 'goverlay' + PathDelim + ChannelFolder;
  end
  else
  begin
    DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
    if DataHome = '' then
      DataHome := GetUserDir + '.local/share';
    Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + ChannelFolder;
  end;
  Result := IncludeTrailingPathDelimiter(Result);
end;

// Compare specific keys between two goverlay.vars files.
// ignoreFsrVersion=True  -> only OptiScalerVersion/FakeNVAPI (cache sync check)
// ignoreFsrVersion=False -> also includes fsrversion (GameDir freshness check)
function NeedsUpdateWithKeys(const LocalPath, GlobalPath: string; IgnoreFsrVersion: Boolean): Boolean;
var
  LocalVars, GlobalVars: string;
  LocalSL, GlobalSL: TStringList;
  LocalVal, GlobalVal: string;
  VersionKeys: array[0..2] of string = ('optiscalerversion', 'fakenvapiversioN', 'fsrversion');
  k, LastKey: Integer;

  function GetValFromList(SL: TStringList; const AKey: string): string;
  var
    j, sp: Integer;
    ln, k2: string;
  begin
    Result := '';
    for j := 0 to SL.Count - 1 do
    begin
      ln := Trim(SL[j]);
      sp := Pos('=', ln);
      if sp > 0 then
      begin
        k2 := Trim(Copy(ln, 1, sp - 1));
        if SameText(k2, AKey) then
        begin
          Result := Trim(Copy(ln, sp + 1, Length(ln)));
          Exit;
        end;
      end;
    end;
  end;

begin
  Result := False;
  LocalVars  := IncludeTrailingPathDelimiter(LocalPath)  + 'goverlay.vars';
  GlobalVars := IncludeTrailingPathDelimiter(GlobalPath) + 'goverlay.vars';

  if not FileExists(GlobalVars) then Exit;
  if not FileExists(LocalVars) then
  begin
    Result := True;
    Exit;
  end;

  // When ignoring fsrversion (cache sync), only compare the first 2 keys.
  if IgnoreFsrVersion then
    LastKey := 1
  else
    LastKey := 2;

  LocalSL  := TStringList.Create;
  GlobalSL := TStringList.Create;
  try
    try
      LocalSL.LoadFromFile(LocalVars);
      GlobalSL.LoadFromFile(GlobalVars);
      for k := 0 to LastKey do
      begin
        LocalVal  := GetValFromList(LocalSL,  VersionKeys[k]);
        GlobalVal := GetValFromList(GlobalSL, VersionKeys[k]);
        if LocalVal <> GlobalVal then
        begin
          Result := True;
          Exit;
        end;
      end;
    except
      on E: Exception do
        Log('Error loading vars files for comparison: ' + E.Message);
    end;
  finally
    LocalSL.Free;
    GlobalSL.Free;
  end;
end;

// Cache → ConfigDir: ignore fsrversion (user preference, not a version change)
function NeedsLocalUpdate(const LocalPath, GlobalPath: string): Boolean;
begin
  Result := NeedsUpdateWithKeys(LocalPath, GlobalPath, True);
end;

// ConfigDir → GameDir: include fsrversion so an INT8/Latest change triggers reinstall
function NeedsGameDirUpdate(const LocalPath, GlobalPath: string): Boolean;
begin
  Result := NeedsUpdateWithKeys(LocalPath, GlobalPath, False);
end;



// Marker-based ownership check.
// A proxy DLL is GOverlay-owned when its name is a known GOverlay proxy DLL
// (per IsProxyDllName) and a goverlay.vars marker file exists in the same
// directory. The goverlay.vars marker is written by this installer (see the
// install block, which ends with SafeCopyFile(ConfigDir + 'goverlay.vars',
// ...)) and is therefore a channel-agnostic signature that GOverlay placed
// the DLLs there, regardless of whether OptiScaler was installed on the
// stable or bleeding-edge channel. This replaces the previous file-size
// comparison against bgmod/renames/<name>.dll / bgmod/OptiScaler.dll, which
// only matched the stable template and silently failed for bleeding-edge
// installs whose DLL has a different size, leaving proxy DLLs behind during
// the disabled-cleanup path here and during uninstaller runs.
function IsProxyDllName(const FileName: string): Boolean; forward;

function IsGOverlayProxyFile(const TargetDir, FileName: string): Boolean;
begin
  Result := False;
  if not IsProxyDllName(FileName) then Exit;
  Result := FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars');
end;

function IsProxyDllName(const FileName: string): Boolean;
begin
  Result := SameText(FileName, 'dxgi.dll') or
            SameText(FileName, 'winmm.dll') or
            SameText(FileName, 'dbghelp.dll') or
            SameText(FileName, 'version.dll') or
            SameText(FileName, 'wininet.dll') or
            SameText(FileName, 'winhttp.dll');
end;

procedure CopyDirectoryFiltered(const SrcDir, DestDir: string);
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
          if (UpperCase(SR.Name) = 'BGMOD.CONF') or (UpperCase(SR.Name) = 'OPTISCALER.INI') then
            Continue;
            
          SrcFile := IncludeTrailingPathDelimiter(SrcDir) + SR.Name;
          DestFile := IncludeTrailingPathDelimiter(DestDir) + SR.Name;
          
          if (SR.Attr and faDirectory) <> 0 then
            CopyDirectoryFiltered(SrcFile, DestFile)
          else
          begin
            try
              if FileExists(DestFile) then
                DeleteFile(DestFile);
              CopyFile(SrcFile, DestFile);
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

// Reads a key=value pair from a flat text vars file.
// Returns empty string if not found.
function ReadVarFromFile(const FilePath, Key: string): string;
var
  SL: TStringList;
  i, SepPos: Integer;
  Line, K, V: string;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FilePath);
    for i := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[i]);
      SepPos := Pos('=', Line);
      if SepPos > 0 then
      begin
        K := Trim(Copy(Line, 1, SepPos - 1));
        V := Trim(Copy(Line, SepPos + 1, Length(Line)));
        if SameText(K, Key) then
        begin
          Result := V;
          Exit;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

// After CopyDirectoryFiltered syncs the cache to ConfigDir, this restores
// the correct FSR DLL in ConfigDir based on the saved fsrversion value.
// This ensures the subsequent copy to GameDir picks the right DLL.
procedure RestoreFsrDllInConfigDir(const AConfigDir, ASourceDir: string);
var
  FsrVer, SrcDll, DestDll: string;
begin
  FsrVer := ReadVarFromFile(IncludeTrailingPathDelimiter(AConfigDir) + 'goverlay.vars', 'fsrversion');
  if (FsrVer = '4.0.2c INT8') or (FsrVer = '4.0.2c (INT8)') then
  begin
    SrcDll  := IncludeTrailingPathDelimiter(ASourceDir) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll';
    DestDll := IncludeTrailingPathDelimiter(AConfigDir) + 'amd_fidelityfx_upscaler_dx12.dll';
    if FileExists(SrcDll) then
    begin
      Log('Restoring FSR4 INT8 DLL in config dir after sync.');
      if FileExists(DestDll) then DeleteFile(DestDll);
      CopyFile(SrcDll, DestDll);
    end
    else
      Log('Warning: FSR4_INT8 DLL not found at: ' + SrcDll);
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

procedure CleanDirectory(const SrcDir, DestDir: string);
var
  SR: TSearchRec;
  SrcFile, DestFile: string;
begin
  if not DirectoryExists(SrcDir) or not DirectoryExists(DestDir) then Exit;
  
  if FindFirst(IncludeTrailingPathDelimiter(SrcDir) + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          SrcFile := IncludeTrailingPathDelimiter(SrcDir) + SR.Name;
          DestFile := IncludeTrailingPathDelimiter(DestDir) + SR.Name;
          
          if (SR.Attr and faDirectory) <> 0 then
          begin
            CleanDirectory(SrcFile, DestFile);
            RemoveDir(DestFile);
          end
          else
          begin
            if FileExists(DestFile) then
              SafeDeleteFile(DestFile);
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

// Restore an original DLL from the per-game backup folder, or fall through to
// the marker-based delete if no backup exists. The in-GameDir `<file>.b`
// mechanism is gone — backups now live in BackupsDir (outside GameDir) so
// they cannot be corrupted by reinstalls or Steam "Verify integrity".
procedure SafeCleanOrRestore(const TargetDir, BackupsDir, FileName: string; IsOriginalGameFile: Boolean);
var
  FullFile, FullBackup: string;
begin
  FullFile := IncludeTrailingPathDelimiter(TargetDir) + FileName;
  FullBackup := IncludeTrailingPathDelimiter(BackupsDir) + FileName;

  if FileExists(FullBackup) then
  begin
    try
      if FileExists(FullFile) then
        DeleteFile(FullFile);
      if CopyFile(FullBackup, FullFile) then
      begin
        Log('Restored original ' + FileName + ' from ' + BackupsDir);
        DeleteFile(FullBackup);
      end
      else
        Log('Failed to restore ' + FileName + ' from backup');
    except
      on E: Exception do
        Log('Exception restoring ' + FileName + ': ' + E.Message);
    end;
  end
  else if not IsOriginalGameFile then
  begin
    if IsProxyDllName(FileName) then
    begin
      if IsGOverlayProxyFile(TargetDir, FileName) then
        SafeDeleteFile(FullFile)
      else
        Log('Skipping deletion of third-party proxy DLL: ' + FullFile);
    end
    else
      SafeDeleteFile(FullFile);
  end;
end;

// Back up the genuine original DLL from GameDir into the per-game backup
// folder, never inside GameDir. The backup is only written on the first
// install for this game (when goverlay.vars is NOT yet present in GameDir),
// and only if the destination slot is empty. This double guard prevents the
// reinstall-corruption bug where a previously-installed GOverlay proxy
// (sitting in GameDir/<name> on the second install) would be backed up as
// "original" — because on reinstall, goverlay.vars already exists, so this
// function becomes a no-op and the original captured on the first install
// (or nothing, when the game shipped no such DLL) stays intact in
// BackupsDir. Uses CopyFile (not Rename) so the GameDir file is left in
// place for the subsequent overwrite by the proxy install step.
procedure SafeBackupFile(const GameDir, BackupsDir, DllFile: string);
var
  FullSrc, FullDest: string;
begin
  FullSrc := IncludeTrailingPathDelimiter(GameDir) + DllFile;
  FullDest := IncludeTrailingPathDelimiter(BackupsDir) + DllFile;

  if not FileExists(FullSrc) then Exit;
  if FileExists(IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars') then
  begin
    Log('Skipping backup of ' + DllFile + ' (game already has GOverlay install)');
    Exit;
  end;
  if FileExists(FullDest) then
  begin
    Log('Skipping backup of ' + DllFile + ' (backup slot already filled)');
    Exit;
  end;

  try
    if CopyFile(FullSrc, FullDest) then
      Log('Backed up original ' + DllFile + ' -> ' + BackupsDir + DllFile)
    else
      Log('Failed to backup ' + DllFile);
  except
    on E: Exception do
      Log('Exception backing up ' + DllFile + ': ' + E.Message);
  end;
end;

procedure ResolveGameDirectory;
var
  Arg, ExePath, LutrisId, Cmd: string;
  i, j, PosPipe: Integer;
  LauncherIni: TIniFile;
  LauncherList: TStringList;
  KeyLine, KeyName, EntryVal, TargetSub, Repl, CleanKey: string;
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
        if FileExists(ExtractFilePath(ParamStr(0)) + 'bgmod.conf') then
        begin
          LauncherIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'bgmod.conf');
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

var
  DllName, DllBase, CurrentOverrides, NewOverrides, TempStr, GlobalBgmodPath: string;
  GOverlayMangoHud, GOverlayVkBasalt, GOverlayOptiscaler, GOverlayTweaks, PreserveIni: Boolean;
  Ini: TIniFile;
  EnvList, EnvStrings: TStringList;
  BackupsDir: string;
  IsPerGameProfile: Boolean;
  i, p, StartArgIdx, EnvCount: Integer;
  Key, Val, Line: string;
  EnvArgs: array of PChar;
  Args: array of PChar;
  ArgsStrings: array of string;
  OrigDlls: array[0..13] of string = (
    'd3dcompiler_47.dll',
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_loader_dx12.dll',
    'amd_fidelityfx_framegeneration_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'amd_fidelityfx_vk.dll',
    'libxess.dll',
    'libxess_dx11.dll',
    'libxess_fg.dll',
    'libxell.dll',
    'nvngx.dll',
    'nvngx_dlss.dll',
    'nvngx_dlssd.dll',
    'nvngx_dlssg.dll'
  );
  ProxyDlls: array[0..6] of string = (
    'dxgi.dll',
    'winmm.dll',
    'dbghelp.dll',
    'version.dll',
    'wininet.dll',
    'winhttp.dll',
    'd3d12.dll'
  );


{$if defined(CPUAARCH64) and defined(LINUX)}
procedure Dummy_libc_csu_init; cdecl; public name '__libc_csu_init';
begin
end;

procedure Dummy_libc_csu_fini; cdecl; public name '__libc_csu_fini';
begin
end;
{$endif}

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
    
    ConfigDir := BgmodPath;
    if LowerCase(Key) = 'bgmod' then
    begin
      // Global mode: ConfigDir = gameconfig/global/ (full copy of bgmod/ with user configs)
      ConfigDir := IncludeTrailingPathDelimiter(Val) + 'gameconfig' + PathDelim + 'global' + PathDelim;
      // SourceDir: prefer gameconfig/global/ if it has DLLs, otherwise fall back to bgmod/
      if FileExists(ConfigDir + 'OptiScaler.dll') then
        SourceDir := ConfigDir
      else
        SourceDir := BgmodPath;
    end
    else
    begin
      SourceDir := GetGlobalBGModPath(BgmodPath);
      if SourceDir = '' then
        SourceDir := BgmodPath;
    end;

    // Resolve the per-game backup folder for original DLLs. It lives outside
    // GameDir (in the per-game config dir) so it cannot be corrupted by
    // repeated installs, channel switches, or Steam "Verify integrity". Only
    // create the folder when running in per-game mode (Key <> 'bgmod'): in
    // global-profile mode backups are skipped per design (collision risk
    // across games; the legacy global flow did not back up reliably anyway).
    IsPerGameProfile := LowerCase(Key) <> 'bgmod';
    BackupsDir := ConfigDir + 'backups' + PathDelim;
    if IsPerGameProfile and not DirectoryExists(BackupsDir) then
      ForceDirectories(BackupsDir);

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
  EnvStrings := TStringList.Create;
  
  // Read configurations from bgmod.conf
  if FileExists(ConfigDir + 'bgmod.conf') then
  begin
    Ini := TIniFile.Create(ConfigDir + 'bgmod.conf');
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
        if (SourceDir <> ConfigDir) and NeedsLocalUpdate(ConfigDir, SourceDir) then
        begin
          Log('OptiScaler update detected. Syncing local config files from ' + SourceDir);
          CopyDirectoryFiltered(SourceDir, ConfigDir);
          // Re-apply the saved FSR DLL version in ConfigDir after the sync overwrote it.
          RestoreFsrDllInConfigDir(ConfigDir, SourceDir);
        end;

        if FileExists(IncludeTrailingPathDelimiter(GameDir) + DllName) and
           FileExists(IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars') and
           not NeedsGameDirUpdate(IncludeTrailingPathDelimiter(GameDir), ConfigDir) then
        begin
          Log('OptiScaler files in game directory are already up to date, skipping copy.');
        end
        else
        begin
          Log('Installing/Updating OptiScaler files in game directory...');
          // 1. Cleanup old injectors
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvngx.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + '_nvngx.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvngx-wrapper.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'dlss-enabler.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');

          // 1b. Delete legacy in-GameDir <file>.b backups (untrusted post-bug).
          // The new isolated-folder backup mechanism does not use these; any
          // leftover .b files come from the previous buggy SafeBackupFile that
          // could store a previous GOverlay proxy as the "original". Removing
          // them is unconditional so the next uninstall cannot restore a proxy.
          for i := 0 to High(OrigDlls) do
            if FileExists(IncludeTrailingPathDelimiter(GameDir) + OrigDlls[i] + '.b') then
            begin
              SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + OrigDlls[i] + '.b');
              Log('Deleted legacy .b backup of ' + OrigDlls[i]);
            end;
          for i := 0 to High(ProxyDlls) do
            if FileExists(IncludeTrailingPathDelimiter(GameDir) + ProxyDlls[i] + '.b') then
            begin
              SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + ProxyDlls[i] + '.b');
              Log('Deleted legacy .b backup of ' + ProxyDlls[i]);
            end;

          // 2. Backup original DLLs
          for i := 0 to High(OrigDlls) do
            SafeBackupFile(GameDir, BackupsDir, OrigDlls[i]);

          // 3. Backup proxy DLLs
          for i := 0 to High(ProxyDlls) do
          begin
            if SameText(ProxyDlls[i], DllName) then
              SafeBackupFile(GameDir, BackupsDir, ProxyDlls[i])
            else
              SafeCleanOrRestore(GameDir, BackupsDir, ProxyDlls[i], False);
          end;
            
          // 4. Remove conflicting nvapi64 files
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvapi64.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvapi64.dll.b');
          
          // 5. Core Install - Copy proxy DLL
          if FileExists(SourceDir + 'renames' + PathDelim + DllName) then
          begin
            Log('Using pre-renamed dll ' + DllName);
            SafeCopyFile(SourceDir + 'renames' + PathDelim + DllName, IncludeTrailingPathDelimiter(GameDir) + DllName);
          end
          else
          begin
            Log('Pre-renamed dll not found, falling back to OptiScaler.dll as ' + DllName);
            SafeCopyFile(SourceDir + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + DllName);
          end;
          
          // 6. OptiScaler.ini Handling
          if PreserveIni and FileExists(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini') then
            Log('Preserving existing OptiScaler.ini')
          else
            SafeCopyFile(ConfigDir + 'OptiScaler.ini', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini');
            
          // 7. Copy plugins/ folder if it exists
          if DirectoryExists(SourceDir + 'plugins') then
          begin
            Log('Installing ASI plugins directory...');
            CopyDirectory(SourceDir + 'plugins', IncludeTrailingPathDelimiter(GameDir) + 'plugins');
          end;
          
          // 7b. Copy D3D12_OptiScaler/ folder if it exists
          if DirectoryExists(SourceDir + 'D3D12_OptiScaler') then
          begin
            Log('Installing D3D12_OptiScaler directory...');
            CopyDirectory(SourceDir + 'D3D12_OptiScaler', IncludeTrailingPathDelimiter(GameDir) + 'D3D12_OptiScaler');
          end
          else if DirectoryExists(SourceDir + 'D3D12_Optiscaler') then
          begin
            Log('Installing D3D12_Optiscaler directory...');
            CopyDirectory(SourceDir + 'D3D12_Optiscaler', IncludeTrailingPathDelimiter(GameDir) + 'D3D12_OptiScaler');
          end;
          
          // 8. Copy supporting libraries
          SafeCopyFile(SourceDir + 'libxess.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess.dll');
          SafeCopyFile(SourceDir + 'libxess_dx11.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess_dx11.dll');
          SafeCopyFile(SourceDir + 'libxess_fg.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess_fg.dll');
          SafeCopyFile(SourceDir + 'libxell.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxell.dll');
          SafeCopyFile(SourceDir + 'amd_fidelityfx_loader_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_loader_dx12.dll');
          if FileExists(SourceDir + 'amd_fidelityfx_dx12.dll') then
            SafeCopyFile(SourceDir + 'amd_fidelityfx_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_dx12.dll')
          else if FileExists(SourceDir + 'amd_fidelityfx_loader_dx12.dll') then
            SafeCopyFile(SourceDir + 'amd_fidelityfx_loader_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_dx12.dll');
          SafeCopyFile(SourceDir + 'amd_fidelityfx_framegeneration_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_framegeneration_dx12.dll');
          if FileExists(ConfigDir + 'amd_fidelityfx_upscaler_dx12.dll') then
            SafeCopyFile(ConfigDir + 'amd_fidelityfx_upscaler_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_upscaler_dx12.dll')
          else
            SafeCopyFile(SourceDir + 'amd_fidelityfx_upscaler_dx12.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_upscaler_dx12.dll');
          SafeCopyFile(SourceDir + 'amd_fidelityfx_vk.dll', IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_vk.dll');
          SafeCopyFile(SourceDir + 'nvngx.dll', IncludeTrailingPathDelimiter(GameDir) + 'nvngx.dll');
          SafeCopyFile(SourceDir + 'nvngx_dlss.dll', IncludeTrailingPathDelimiter(GameDir) + 'nvngx_dlss.dll');
          SafeCopyFile(SourceDir + 'nvngx_dlssd.dll', IncludeTrailingPathDelimiter(GameDir) + 'nvngx_dlssd.dll');
          SafeCopyFile(SourceDir + 'nvngx_dlssg.dll', IncludeTrailingPathDelimiter(GameDir) + 'nvngx_dlssg.dll');
          
          // 9. Copy Nukem FG
          SafeCopyFile(SourceDir + 'dlssg_to_fsr3_amd_is_better.dll', IncludeTrailingPathDelimiter(GameDir) + 'dlssg_to_fsr3_amd_is_better.dll');
          
          // 10. Copy FakeNVAPI
          SafeCopyFile(SourceDir + 'fakenvapi.dll', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.dll');
          if FileExists(ConfigDir + 'fakenvapi.ini') then
            SafeCopyFile(ConfigDir + 'fakenvapi.ini', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.ini')
          else
            SafeCopyFile(SourceDir + 'fakenvapi.ini', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.ini');
          
          // 11. Copy uninstaller
          SafeCopyFile(SourceDir + 'bgmod-uninstaller', IncludeTrailingPathDelimiter(GameDir) + 'bgmod-uninstaller');
          
          // 12. Copy version file to game folder
          SafeCopyFile(ConfigDir + 'goverlay.vars', IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars');
        end;
      end
      else
      begin
        Log('OptiScaler is disabled, checking for cleanup...');
        if FileExists(IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars') or
           FileExists(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll') or
           FileExists(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini') or
           FileExists(IncludeTrailingPathDelimiter(GameDir) + DllName) then
        begin
          Log('OptiScaler leftovers detected in game directory, cleaning up...');
          for i := 0 to High(OrigDlls) do
            SafeCleanOrRestore(GameDir, BackupsDir, OrigDlls[i], True);
          for i := 0 to High(ProxyDlls) do
            SafeCleanOrRestore(GameDir, BackupsDir, ProxyDlls[i], False);
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.ini');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.log');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.asi');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'nvapi64.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.ini');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.log');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'libxess.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'libxess_dx11.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'libxess_fg.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'libxell.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_dx12.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_loader_dx12.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_framegeneration_dx12.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_upscaler_dx12.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'amd_fidelityfx_vk.dll');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'dlssg_to_fsr3_amd_is_better.dll');
          SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'D3D12_OptiScaler');
          CleanDirectory(IncludeTrailingPathDelimiter(BgmodPath) + 'plugins', IncludeTrailingPathDelimiter(GameDir) + 'plugins');
          RemoveDir(IncludeTrailingPathDelimiter(GameDir) + 'plugins');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'bgmod.log');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'MangoHud.conf');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf');
          SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf');
          Log('Cleanup of disabled OptiScaler completed.');
        end
        else
          Log('OptiScaler is disabled, no leftovers found.');
      end;
      
      // --- MangoHud Configuration Copy ---
      if GOverlayMangoHud then
        SafeCopyFile(BgmodPath + 'MangoHud.conf', IncludeTrailingPathDelimiter(GameDir) + 'MangoHud.conf')
      else
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'MangoHud.conf');
        
      // --- vkBasalt Configuration Copy ---
      if GOverlayVkBasalt then
      begin
        SafeCopyFile(BgmodPath + 'vkBasalt.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf');
        SafeCopyFile(BgmodPath + 'vkSumi.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf');
      end
      else
      begin
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf');
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf');
      end;
    end;
  end;
  
  // Set up Environment Variables
  Log('Exporting environment variables...');
  
  // Initialize EnvStrings with current environment from envp
  EnvCount := 0;
  while envp[EnvCount] <> nil do
  begin
    EnvStrings.Add(StrPas(envp[EnvCount]));
    Inc(EnvCount);
  end;
  
  // Export environment variables read from bgmod.conf [Env] section
  for i := 0 to EnvList.Count - 1 do
  begin
    Line := EnvList[i];
    p := Pos('=', Line);
    if p > 0 then
    begin
      Key := Copy(Line, 1, p - 1);
      Val := Copy(Line, p + 1, MaxInt);
      // Always export DXIL_SPIRV_CONFIG and MANGOHUD_CONFIGFILE.
      // Other environment variables are exported if GOverlayTweaks is enabled.
      if (Key = 'MANGOHUD_CONFIGFILE') or (Key = 'DXIL_SPIRV_CONFIG') or GOverlayTweaks then
      begin
        SetEnvVarInList(EnvStrings, Key, Val);
        Log('Export [Env]: ' + Key + '=' + Val);
      end;
    end;
  end;
  
  // Export explicit config flags
  if GOverlayMangoHud then
  begin
    SetEnvVarInList(EnvStrings, 'MANGOHUD', '1');
    Log('Export: MANGOHUD=1');
  end;
  if GOverlayVkBasalt then
  begin
    SetEnvVarInList(EnvStrings, 'ENABLE_VKBASALT', '1');
    SetEnvVarInList(EnvStrings, 'ENABLE_VKSUMI', '1');
    Log('Export: ENABLE_VKBASALT=1, ENABLE_VKSUMI=1');
  end;
  if GOverlayOptiscaler then
  begin
    DllBase := ChangeFileExt(DllName, '');
    CurrentOverrides := GetEnvVarFromList(EnvStrings, 'WINEDLLOVERRIDES');
    if CurrentOverrides <> '' then
      NewOverrides := CurrentOverrides + ',' + DllBase + '=n,b'
    else
      NewOverrides := DllBase + '=n,b';
    SetEnvVarInList(EnvStrings, 'WINEDLLOVERRIDES', NewOverrides);
    Log('Export WINEDLLOVERRIDES=' + NewOverrides);
  end;
  
  EnvList.Free;
  
  // Serialize EnvStrings into EnvArgs
  SetLength(EnvArgs, EnvStrings.Count + 1);
  for i := 0 to EnvStrings.Count - 1 do
    EnvArgs[i] := PChar(EnvStrings[i]);
  EnvArgs[EnvStrings.Count] := nil;
  
  // Execute the game
  StartArgIdx := 1;
  while (StartArgIdx <= ParamCount) and (ParamStr(StartArgIdx) = '--') do
    Inc(StartArgIdx);
    
  if StartArgIdx > ParamCount then
  begin
    Log('bgmod done (no command was specified).');
    EnvStrings.Free;
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
  
  execvpe(Args[0], @Args[0], @EnvArgs[0]);
  
  // If we reach here, execvpe failed
  Log('Error: execvpe failed');
  EnvStrings.Free;
  Halt(127);
end.
