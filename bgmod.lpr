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
  TargetExeName: string;
  CentralLogDir: string;
  CentralLogFile: string;
  BgmodPath: string;
  ConfigDir: string;
  SourceDir: string;
  HasGamePerformance: Boolean;
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

procedure AppendFileContent(const SrcPath, DestPath: string);
var
  SrcF, DestF: TextFile;
  Line: string;
begin
  if not FileExists(SrcPath) or (DestPath = '') then Exit;
  try
    AssignFile(SrcF, SrcPath);
    Reset(SrcF);
    AssignFile(DestF, DestPath);
    if FileExists(DestPath) then
      Append(DestF)
    else
      Rewrite(DestF);
    WriteLn(DestF, FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - --- Content from ' + ExtractFileName(SrcPath) + ' ---');
    while not Eof(SrcF) do
    begin
      ReadLn(SrcF, Line);
      WriteLn(DestF, Line);
    end;
    CloseFile(SrcF);
    CloseFile(DestF);
  except
    // ignore copy failures
  end;
end;

procedure EnsureOptiScalerLogging(const AIniPath: string);
var
  Ini: TIniFile;
begin
  if not FileExists(AIniPath) then Exit;
  try
    Ini := TIniFile.Create(AIniPath);
    try
      if (Ini.ReadString('Log', 'LogToFile', 'auto') = 'auto') or (Ini.ReadString('Log', 'LogToFile', 'false') = 'false') then
        Ini.WriteString('Log', 'LogToFile', 'true');
      if Ini.ReadString('Log', 'LogToConsole', 'auto') = 'auto' then
        Ini.WriteString('Log', 'LogToConsole', 'true');
      if Ini.ReadString('Log', 'LogLevel', 'auto') = 'auto' then
        Ini.WriteString('Log', 'LogLevel', '2');
      if Ini.ReadString('Log', 'LogFileName', 'auto') = 'auto' then
        Ini.WriteString('Log', 'LogFileName', 'OptiScaler.log');
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure InitToolLogFile(const APath, AToolName, AGameDir, AConfigPath: string);
var
  F: TextFile;
begin
  if APath = '' then Exit;
  try
    if not DirectoryExists(ExtractFilePath(APath)) then
      ForceDirectories(ExtractFilePath(APath));
    AssignFile(F, APath);
    if FileExists(APath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - ========================= ' + AToolName + ' logging initialized =========================');
    if AGameDir <> '' then
      WriteLn(F, FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - Game directory: ' + AGameDir);
    if AConfigPath <> '' then
      WriteLn(F, FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - Config: ' + AConfigPath);
    CloseFile(F);
  except
    // ignore logging failures
  end;
end;

procedure RunSubprocessLogger(ReadFd, OrigStderrFd: cint; 
  const MakoCent, MakoGame, LsfgCent, LsfgGame, OptiCent, OptiGame, SumiCent, SumiGame, BasaltCent, BasaltGame, InternalOptiLog: string;
  LogMako, LogLsfg, LogOpti, LogSumi, LogBasalt: Boolean);
var
  MakoCentFd, MakoGameFd: cint;
  LsfgCentFd, LsfgGameFd: cint;
  OptiCentFd, OptiGameFd: cint;
  SumiCentFd, SumiGameFd: cint;
  BasaltCentFd, BasaltGameFd: cint;
  Buf: array[0..4095] of char;
  N: TsSize;
  i: Integer;
  LineBuf, Line, OutLine, LowLine: string;
  IsMako, IsLsfg, IsOpti, IsSumi, IsBasalt: Boolean;
begin
  MakoCentFd := -1; MakoGameFd := -1;
  LsfgCentFd := -1; LsfgGameFd := -1;
  OptiCentFd := -1; OptiGameFd := -1;
  SumiCentFd := -1; SumiGameFd := -1;
  BasaltCentFd := -1; BasaltGameFd := -1;

  if LogMako and (MakoCent <> '') then
    MakoCentFd := fpOpen(PChar(MakoCent), O_WRONLY or O_CREAT or O_APPEND, &644);
  if LogMako and (MakoGame <> '') then
    MakoGameFd := fpOpen(PChar(MakoGame), O_WRONLY or O_CREAT or O_APPEND, &644);

  if LogLsfg and (LsfgCent <> '') then
    LsfgCentFd := fpOpen(PChar(LsfgCent), O_WRONLY or O_CREAT or O_APPEND, &644);
  if LogLsfg and (LsfgGame <> '') then
    LsfgGameFd := fpOpen(PChar(LsfgGame), O_WRONLY or O_CREAT or O_APPEND, &644);

  if LogOpti and (OptiCent <> '') then
    OptiCentFd := fpOpen(PChar(OptiCent), O_WRONLY or O_CREAT or O_APPEND, &644);
  if LogOpti and (OptiGame <> '') then
    OptiGameFd := fpOpen(PChar(OptiGame), O_WRONLY or O_CREAT or O_APPEND, &644);

  if LogSumi and (SumiCent <> '') then
    SumiCentFd := fpOpen(PChar(SumiCent), O_WRONLY or O_CREAT or O_APPEND, &644);
  if LogSumi and (SumiGame <> '') then
    SumiGameFd := fpOpen(PChar(SumiGame), O_WRONLY or O_CREAT or O_APPEND, &644);

  if LogBasalt and (BasaltCent <> '') then
    BasaltCentFd := fpOpen(PChar(BasaltCent), O_WRONLY or O_CREAT or O_APPEND, &644);
  if LogBasalt and (BasaltGame <> '') then
    BasaltGameFd := fpOpen(PChar(BasaltGame), O_WRONLY or O_CREAT or O_APPEND, &644);

  LineBuf := '';
  while True do
  begin
    N := fpRead(ReadFd, @Buf, SizeOf(Buf));
    if N <= 0 then Break;

    // Forward all raw stderr traffic to original stderr so console and Steam logs stay intact
    if OrigStderrFd >= 0 then
      fpWrite(OrigStderrFd, @Buf, N);

    for i := 0 to N - 1 do
    begin
      if Buf[i] = #10 then
      begin
        Line := TrimRight(LineBuf);
        LineBuf := '';
        if Line <> '' then
        begin
          LowLine := LowerCase(Line);
          OutLine := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - ' + Line + LineEnding;

          if LogMako then
          begin
            IsMako := (Pos('mako', LowLine) > 0) or 
                      (Pos('lsfg', LowLine) > 0) or 
                      (Pos('lossless', LowLine) > 0);
            if IsMako then
            begin
              if MakoCentFd >= 0 then fpWrite(MakoCentFd, PChar(OutLine), Length(OutLine));
              if MakoGameFd >= 0 then fpWrite(MakoGameFd, PChar(OutLine), Length(OutLine));
            end;
          end;

          if LogLsfg then
          begin
            IsLsfg := (Pos('lsfg', LowLine) > 0) or 
                      (Pos('lossless', LowLine) > 0);
            if IsLsfg then
            begin
              if LsfgCentFd >= 0 then fpWrite(LsfgCentFd, PChar(OutLine), Length(OutLine));
              if LsfgGameFd >= 0 then fpWrite(LsfgGameFd, PChar(OutLine), Length(OutLine));
            end;
          end;

          if LogOpti then
          begin
            IsOpti := (Pos('optiscaler', LowLine) > 0) or 
                      (Pos('nvngx', LowLine) > 0) or 
                      (Pos('fakenvapi', LowLine) > 0);
            if IsOpti then
            begin
              if OptiCentFd >= 0 then fpWrite(OptiCentFd, PChar(OutLine), Length(OutLine));
              if OptiGameFd >= 0 then fpWrite(OptiGameFd, PChar(OutLine), Length(OutLine));
            end;
          end;

          if LogSumi then
          begin
            IsSumi := (Pos('vksumi', LowLine) > 0);
            if IsSumi then
            begin
              if SumiCentFd >= 0 then fpWrite(SumiCentFd, PChar(OutLine), Length(OutLine));
              if SumiGameFd >= 0 then fpWrite(SumiGameFd, PChar(OutLine), Length(OutLine));
            end;
          end;

          if LogBasalt then
          begin
            IsBasalt := (Pos('vkbasalt', LowLine) > 0);
            if IsBasalt then
            begin
              if BasaltCentFd >= 0 then fpWrite(BasaltCentFd, PChar(OutLine), Length(OutLine));
              if BasaltGameFd >= 0 then fpWrite(BasaltGameFd, PChar(OutLine), Length(OutLine));
            end;
          end;
        end;
      end
      else if Buf[i] <> #13 then
        LineBuf := LineBuf + Buf[i];
    end;
  end;

  if LineBuf <> '' then
  begin
    Line := TrimRight(LineBuf);
    LowLine := LowerCase(Line);
    OutLine := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - ' + Line + LineEnding;

    if LogMako and ((Pos('mako', LowLine) > 0) or (Pos('lsfg', LowLine) > 0) or (Pos('lossless', LowLine) > 0)) then
    begin
      if MakoCentFd >= 0 then fpWrite(MakoCentFd, PChar(OutLine), Length(OutLine));
      if MakoGameFd >= 0 then fpWrite(MakoGameFd, PChar(OutLine), Length(OutLine));
    end;

    if LogLsfg and ((Pos('lsfg', LowLine) > 0) or (Pos('lossless', LowLine) > 0)) then
    begin
      if LsfgCentFd >= 0 then fpWrite(LsfgCentFd, PChar(OutLine), Length(OutLine));
      if LsfgGameFd >= 0 then fpWrite(LsfgGameFd, PChar(OutLine), Length(OutLine));
    end;

    if LogOpti and ((Pos('optiscaler', LowLine) > 0) or (Pos('nvngx', LowLine) > 0) or (Pos('fakenvapi', LowLine) > 0)) then
    begin
      if OptiCentFd >= 0 then fpWrite(OptiCentFd, PChar(OutLine), Length(OutLine));
      if OptiGameFd >= 0 then fpWrite(OptiGameFd, PChar(OutLine), Length(OutLine));
    end;

    if LogSumi and (Pos('vksumi', LowLine) > 0) then
    begin
      if SumiCentFd >= 0 then fpWrite(SumiCentFd, PChar(OutLine), Length(OutLine));
      if SumiGameFd >= 0 then fpWrite(SumiGameFd, PChar(OutLine), Length(OutLine));
    end;

    if LogBasalt and (Pos('vkbasalt', LowLine) > 0) then
    begin
      if BasaltCentFd >= 0 then fpWrite(BasaltCentFd, PChar(OutLine), Length(OutLine));
      if BasaltGameFd >= 0 then fpWrite(BasaltGameFd, PChar(OutLine), Length(OutLine));
    end;
  end;

  if MakoCentFd >= 0 then fpClose(MakoCentFd);
  if MakoGameFd >= 0 then fpClose(MakoGameFd);
  if LsfgCentFd >= 0 then fpClose(LsfgCentFd);
  if LsfgGameFd >= 0 then fpClose(LsfgGameFd);
  if OptiCentFd >= 0 then fpClose(OptiCentFd);
  if OptiGameFd >= 0 then fpClose(OptiGameFd);
  if SumiCentFd >= 0 then fpClose(SumiCentFd);
  if SumiGameFd >= 0 then fpClose(SumiGameFd);
  if BasaltCentFd >= 0 then fpClose(BasaltCentFd);
  if BasaltGameFd >= 0 then fpClose(BasaltGameFd);
  if ReadFd >= 0 then fpClose(ReadFd);
  if OrigStderrFd >= 0 then fpClose(OrigStderrFd);

  // Sync internal OptiScaler.log if created by the game DLL
  if LogOpti and (InternalOptiLog <> '') and FileExists(InternalOptiLog) then
  begin
    if OptiCent <> '' then
      AppendFileContent(InternalOptiLog, OptiCent);
  end;

  fpExit(0);
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
  UpscalerType: Integer;
  Ini: TIniFile;
  IsStable: Boolean;
  ChannelFolder: string;
begin
  UpscalerType := 0;
  IsStable := True;
  if FileExists(IncludeTrailingPathDelimiter(LocalBgmodPath) + 'bgmod.conf') then
  begin
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(LocalBgmodPath) + 'bgmod.conf');
    try
      UpscalerType := Ini.ReadInteger('Config', 'UPSCALER_TYPE', 0);
      IsStable := Ini.ReadInteger('Config', 'OPT_CHANNEL', 0) <> 1;
    finally
      Ini.Free;
    end;
  end;

  if UpscalerType = 1 then
  begin
    if IsStable then
      ChannelFolder := 'dlssenabler-stable'
    else
      ChannelFolder := 'dlssenabler-edge';
  end
  else if IsStable then
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
  VersionKeys: array[0..2] of string = ('optiscalerversion', 'fakenvapiversion', 'fsrversion');
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
          if (UpperCase(SR.Name) = 'BGMOD.CONF') or (UpperCase(SR.Name) = 'OPTISCALER.INI') or (UpperCase(SR.Name) = 'FAKENVAPI.INI') then
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

procedure PreserveFileTimestamp(const Src, Dest: string);
var
  sb: stat;
  ub: utimbuf;
begin
  if (FpStat(PChar(Src), sb) = 0) then
  begin
    ub.actime := sb.st_atime;
    ub.modtime := sb.st_mtime;
    FpUtime(PChar(Dest), @ub);
  end;
end;

procedure SafeCopyFile(const Src, Dest: string; APreserveTimestamp: Boolean = False);
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
      if APreserveTimestamp then
        PreserveFileTimestamp(Src, Dest);
      Log('Successfully copied: ' + Src + ' -> ' + Dest);
    end
    else
      Log('Failed to copy: ' + Src + ' -> ' + Dest);
  except
    on E: Exception do
      Log('Exception copying ' + Src + ' -> ' + Dest + ': ' + E.Message);
  end;
end;

procedure SyncOptiScalerIni(const AConfigDir, AGameDir: string; APreserveIni: Boolean);
var
  ConfigIni, GameIni: string;
  AgeConfig, AgeGame: TDateTime;
  ConfigExists, GameExists: Boolean;
begin
  ConfigIni := IncludeTrailingPathDelimiter(AConfigDir) + 'OptiScaler.ini';
  GameIni := IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.ini';

  ConfigExists := FileExists(ConfigIni);
  GameExists := FileExists(GameIni);

  if not ConfigExists and not GameExists then
    Exit;

  if not ConfigExists and GameExists then
  begin
    Log('OptiScaler.ini found only in game directory. Syncing to config directory...');
    SafeCopyFile(GameIni, ConfigIni, True);
    EnsureOptiScalerLogging(GameIni);
    Exit;
  end;

  if ConfigExists and not GameExists then
  begin
    Log('OptiScaler.ini not found in game directory. Initializing from config directory...');
    SafeCopyFile(ConfigIni, GameIni, True);
    EnsureOptiScalerLogging(GameIni);
    Exit;
  end;

  if not APreserveIni then
  begin
    Log('PreserveIni is false. Overwriting OptiScaler.ini in game directory...');
    SafeCopyFile(ConfigIni, GameIni, True);
    EnsureOptiScalerLogging(GameIni);
    Exit;
  end;

  if FileAge(ConfigIni, AgeConfig) and FileAge(GameIni, AgeGame) then
  begin
    if AgeGame > AgeConfig then
    begin
      Log('Game directory OptiScaler.ini is newer (modified in-game). Syncing back to config directory...');
      SafeCopyFile(GameIni, ConfigIni, True);
    end
    else if AgeConfig > AgeGame then
    begin
      Log('Config directory OptiScaler.ini is newer (modified in GOverlay). Syncing to game directory...');
      SafeCopyFile(ConfigIni, GameIni, True);
    end
    else
      Log('OptiScaler.ini is up to date.');
  end;
  EnsureOptiScalerLogging(GameIni);
end;

procedure SyncFakeNvapiIni(const AConfigDir, AGameDir: string);
var
  ConfigIni, GameIni: string;
  AgeConfig, AgeGame: TDateTime;
  ConfigExists, GameExists: Boolean;
begin
  ConfigIni := IncludeTrailingPathDelimiter(AConfigDir) + 'fakenvapi.ini';
  GameIni := IncludeTrailingPathDelimiter(AGameDir) + 'fakenvapi.ini';

  ConfigExists := FileExists(ConfigIni);
  GameExists := FileExists(GameIni);

  if not ConfigExists and not GameExists then
    Exit;

  if not ConfigExists and GameExists then
  begin
    Log('fakenvapi.ini found only in game directory. Syncing to config directory...');
    SafeCopyFile(GameIni, ConfigIni, True);
    Exit;
  end;

  if ConfigExists and not GameExists then
  begin
    Log('fakenvapi.ini not found in game directory. Initializing from config directory...');
    SafeCopyFile(ConfigIni, GameIni, True);
    Exit;
  end;

  if FileAge(ConfigIni, AgeConfig) and FileAge(GameIni, AgeGame) then
  begin
    if AgeGame > AgeConfig then
    begin
      Log('Game directory fakenvapi.ini is newer. Syncing back to config directory...');
      SafeCopyFile(GameIni, ConfigIni, True);
    end
    else if AgeConfig > AgeGame then
    begin
      Log('Config directory fakenvapi.ini is newer. Syncing to game directory...');
      SafeCopyFile(ConfigIni, GameIni, True);
    end
    else
      Log('fakenvapi.ini is up to date.');
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

function GetInstalledUpscalerType(const TargetDir: string): Integer;
var
  VarsPath, Val: string;
begin
  Result := -1;
  VarsPath := IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars';
  if FileExists(VarsPath) then
  begin
    Val := ReadVarFromFile(VarsPath, 'upscalertype');
    if Val = '1' then Exit(1);
    if Val = '0' then Exit(0);

    Val := ReadVarFromFile(VarsPath, 'dlssenablerversion');
    if Val <> '' then Exit(1);

    Val := ReadVarFromFile(VarsPath, 'optiscalerversion');
    if Val <> '' then Exit(0);
  end;

  if DirectoryExists(IncludeTrailingPathDelimiter(TargetDir) + 'OptiScaler') then
    Exit(1);
  if DirectoryExists(IncludeTrailingPathDelimiter(TargetDir) + 'D3D12_OptiScaler') or
     FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'OptiScaler.dll') then
    Exit(0);
end;

procedure WriteVarToFile(const FilePath, Key, Value: string);
var
  SL: TStringList;
  idx, SepPos: Integer;
  Line, K: string;
  Found: Boolean;
begin
  SL := TStringList.Create;
  try
    if FileExists(FilePath) then
      SL.LoadFromFile(FilePath);
    Found := False;
    for idx := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[idx]);
      SepPos := Pos('=', Line);
      if SepPos > 0 then
      begin
        K := Trim(Copy(Line, 1, SepPos - 1));
        if SameText(K, Key) then
        begin
          SL[idx] := Key + '=' + Value;
          Found := True;
          Break;
        end;
      end;
    end;
    if not Found then
      SL.Add(Key + '=' + Value);
    SL.SaveToFile(FilePath);
  finally
    SL.Free;
  end;
end;

procedure PurgeUpscalerFromGameDir(const AGameDir, ABackupsDir: string);
var
  i: Integer;
begin
  Log('Purging installed upscaler files from game directory...');
  for i := 0 to High(ProxyDlls) do
    SafeCleanOrRestore(AGameDir, ABackupsDir, ProxyDlls[i], False);

  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.ini');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.log');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.asi');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'dlss-enabler.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'dlss-enabler-upscaler.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'dlss-enabler.log');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvngx.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + '_nvngx.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvngx-wrapper.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvapi64.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'fakenvapi.ini');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'fakenvapi.log');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'fakenvapi.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'libxess.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'libxess_dx11.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'libxess_fg.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'libxell.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'amd_fidelityfx_dx12.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'amd_fidelityfx_loader_dx12.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'amd_fidelityfx_framegeneration_dx12.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'amd_fidelityfx_upscaler_dx12.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'amd_fidelityfx_vk.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvngx_dlss.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvngx_dlssd.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'nvngx_dlssg.dll');
  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'dlssg_to_fsr3_amd_is_better.dll');

  SafeDeleteDirectory(IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler');
  SafeDeleteDirectory(IncludeTrailingPathDelimiter(AGameDir) + 'D3D12_OptiScaler');
  if DirectoryExists(IncludeTrailingPathDelimiter(AGameDir) + 'plugins') then
  begin
    CleanDirectory(IncludeTrailingPathDelimiter(BgmodPath) + 'plugins', IncludeTrailingPathDelimiter(AGameDir) + 'plugins');
    RemoveDir(IncludeTrailingPathDelimiter(AGameDir) + 'plugins');
  end;

  SafeDeleteFile(IncludeTrailingPathDelimiter(AGameDir) + 'goverlay.vars');
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
      
      TargetExeName := ExtractFileName(Arg);
      GameDir := ExtractFilePath(Arg);
      Log('Resolved GameDir from argument: ' + GameDir + ' (exe: ' + TargetExeName + ')');
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
          TargetExeName := ExtractFileName(ExePath);
          GameDir := ExtractFilePath(ExePath);
          Log('Resolved Lutris GameDir: ' + GameDir + ' (exe: ' + TargetExeName + ')');
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
  DllName, DllBase, CurrentOverrides, NewOverrides, TempStr, GlobalBgmodPath, OptiBaseDir: string;
  TomlPath, LsfgDllPath, LsfgFlow, LsfgPerf, LsfgHdr, LsfgLegacy, LsfgPacing, LsfgPerfStr, LsfgHdrStr, LsfgLegacyStr, InterpolationMethod, LsfgGpu: string;
  MakoScalingEnabled, MakoScalingMethod, MakoScalingFactor, MakoScalingSharpness, MakoScalingSs: string;
  MakoAdaptive, MakoTargetFps, MakoAdaptiveMaxMult, MakoSteady2xCap, MakoAllowFp16: string;
  MakoBaseFpsCap, MakoRefreshThreshold, MakoFgLive, MakoUltraPerf: string;
  ProfileName, CurProfile: string;
  LsfgMult: Integer;
  TomlLines: TStringList;
  GOverlayMangoHud, GOverlayVkBasalt, GOverlayVkSumi, GOverlayOptiscaler, GOverlayTweaks, GOverlayLossless, PreserveIni: Boolean;
  UpscalerType, InstalledUpscaler: Integer;
  Ini: TIniFile;
  EnvList, EnvStrings: TStringList;
  BackupsDir: string;
  IsPerGameProfile: Boolean;
  i, p, StartArgIdx, EnvCount: Integer;
  Key, Val, Line: string;
  EnvArgs: array of PChar;
  Args: array of PChar;
  ArgsStrings: array of string;
  MakoCentralLogFile, MakoGameLogFile: string;
  LsfgCentralLogFile, LsfgGameLogFile: string;
  OptiCentralLogFile, OptiGameLogFile, InternalOptiLogPath: string;
  SumiCentralLogFile, SumiGameLogFile: string;
  BasaltCentralLogFile, BasaltGameLogFile: string;
  HasAnyToolLogging: Boolean;
  PipeFds: array[0..1] of cint;
  ForkPid: TPid;
  OrigStderr: cint;


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
  GOverlayVkSumi := False;
  GOverlayOptiscaler := False;
  GOverlayTweaks := False;
  GOverlayLossless := False;
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
      GOverlayVkSumi := Ini.ReadString('Config', 'GOVERLAY_VKSUMI', '0') = '1';
      GOverlayOptiscaler := Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '0') = '1';
      GOverlayTweaks := Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '0') = '1';
      GOverlayLossless := Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0') = '1';
      InterpolationMethod := LowerCase(Trim(Ini.ReadString('Config', 'INTERPOLATION_METHOD', '')));
      if InterpolationMethod = '' then
      begin
        if GOverlayLossless then
          InterpolationMethod := 'mako'
        else
          InterpolationMethod := 'none';
      end;
      if InterpolationMethod = 'none' then
        GOverlayLossless := False;

      UpscalerType := Ini.ReadInteger('Config', 'UPSCALER_TYPE', 0);
      DllName := Ini.ReadString('Config', 'DLL', 'dxgi.dll');
      PreserveIni := Ini.ReadString('Config', 'PRESERVE_INI', 'true') = 'true';
      
      LsfgDllPath := Ini.ReadString('Config', 'LS_DLL_PATH', Ini.ReadString('Env', 'LSFG_DLL_PATH', ''));
      LsfgMult := Ini.ReadInteger('Config', 'LS_MULTIPLIER', Ini.ReadInteger('Env', 'LSFG_MULTIPLIER', 2));
      LsfgFlow := Ini.ReadString('Config', 'LS_FLOW_SCALE', Ini.ReadString('Env', 'LSFG_FLOW_SCALE', '1.0'));
      LsfgPerf := Ini.ReadString('Config', 'LS_PERFORMANCE_MODE', Ini.ReadString('Env', 'LSFG_PERFORMANCE_MODE', '0'));
      LsfgHdr := Ini.ReadString('Config', 'LS_HDR_MODE', Ini.ReadString('Env', 'LSFG_HDR_MODE', '0'));
      LsfgLegacy := Ini.ReadString('Config', 'LS_NO_FP16', Ini.ReadString('Env', 'LSFG_LEGACY', '1'));
      LsfgPacing := Ini.ReadString('Config', 'LS_PACING', Ini.ReadString('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE', 'fifo'));
      LsfgGpu := Ini.ReadString('Config', 'LS_GPU', Ini.ReadString('Env', 'LSFG_GPU', ''));
      
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
      ', vkSumi=' + BoolToStr(GOverlayVkSumi, '1', '0') + 
      ', OptiScaler=' + BoolToStr(GOverlayOptiscaler, '1', '0') + 
      ', Tweaks=' + BoolToStr(GOverlayTweaks, '1', '0') +
      ', Lossless=' + BoolToStr(GOverlayLossless, '1', '0') +
      ', Method=' + InterpolationMethod +
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
        InstalledUpscaler := GetInstalledUpscalerType(GameDir);
        if (InstalledUpscaler >= 0) and (InstalledUpscaler <> UpscalerType) then
        begin
          Log('Upscaler switch detected (installed=' + IntToStr(InstalledUpscaler) + ', target=' + IntToStr(UpscalerType) + '). Purging previous upscaler files...');
          PurgeUpscalerFromGameDir(GameDir, BackupsDir);
        end;

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
          SyncOptiScalerIni(ConfigDir, GameDir, PreserveIni);
          SyncFakeNvapiIni(ConfigDir, GameDir);
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
          if UpscalerType = 1 then
          begin
            // 5a. First copy base OptiScaler files from optiscaler-stable if available
            OptiBaseDir := GetEnvironmentVariable('XDG_DATA_HOME');
            if OptiBaseDir = '' then OptiBaseDir := GetUserDir + '.local/share';
            OptiBaseDir := IncludeTrailingPathDelimiter(OptiBaseDir) + 'goverlay' + PathDelim + 'optiscaler-stable' + PathDelim;
            if FileExists(OptiBaseDir + 'OptiScaler.dll') then
            begin
              Log('Installing base OptiScaler files for DLSS Enabler...');
              SafeCopyFile(OptiBaseDir + 'fakenvapi.dll', IncludeTrailingPathDelimiter(GameDir) + 'fakenvapi.dll');
              SafeCopyFile(OptiBaseDir + 'libxess.dll', IncludeTrailingPathDelimiter(GameDir) + 'libxess.dll');
              if DirectoryExists(OptiBaseDir + 'plugins') then
                CopyDirectory(OptiBaseDir + 'plugins', IncludeTrailingPathDelimiter(GameDir) + 'plugins');
            end;

            // 5b. Overwrite OptiScaler.dll with DLSS Enabler version.dll
            if FileExists(SourceDir + 'version.dll') then
            begin
              Log('Installing DLSS Enabler version.dll as OptiScaler.dll');
              SafeCopyFile(SourceDir + 'version.dll', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');
            end
            else if FileExists(SourceDir + 'OptiScaler.dll') then
            begin
              SafeCopyFile(SourceDir + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');
            end;

            // 5c. Copy OptiScaler.dll as the target proxy DLL
            Log('Using OptiScaler.dll as proxy DLL ' + DllName);
            SafeCopyFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + DllName);
          end
          else if FileExists(SourceDir + 'renames' + PathDelim + DllName) then
          begin
            Log('Using pre-renamed dll ' + DllName);
            SafeCopyFile(SourceDir + 'renames' + PathDelim + DllName, IncludeTrailingPathDelimiter(GameDir) + DllName);
          end
          else
          begin
            Log('Pre-renamed dll not found, falling back to OptiScaler.dll as ' + DllName);
            SafeCopyFile(SourceDir + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + DllName);
          end;
          
          // 6. OptiScaler.ini & fakenvapi.ini Handling
          SyncOptiScalerIni(ConfigDir, GameDir, PreserveIni);
          SyncFakeNvapiIni(ConfigDir, GameDir);
            
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

          // 7c. Copy OptiScaler/ directory if it exists (DLSS Enabler)
          if DirectoryExists(SourceDir + 'OptiScaler') then
          begin
            Log('Installing OptiScaler directory...');
            CopyDirectory(SourceDir + 'OptiScaler', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler');
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
          
          // Streamline SDK libraries
          SafeCopyFile(SourceDir + 'sl.common.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.common.dll');
          SafeCopyFile(SourceDir + 'sl.dlss.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.dlss.dll');
          SafeCopyFile(SourceDir + 'sl.dlss_g.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.dlss_g.dll');
          SafeCopyFile(SourceDir + 'sl.interposer.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.interposer.dll');
          SafeCopyFile(SourceDir + 'sl.nis.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.nis.dll');
          SafeCopyFile(SourceDir + 'sl.reflex.dll', IncludeTrailingPathDelimiter(GameDir) + 'sl.reflex.dll');
          
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
          WriteVarToFile(IncludeTrailingPathDelimiter(GameDir) + 'goverlay.vars', 'upscalertype', IntToStr(UpscalerType));
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
        SafeCopyFile(BgmodPath + 'vkBasalt.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf')
      else
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkBasalt.conf');

      // --- vkSumi Configuration Copy ---
      if GOverlayVkSumi then
        SafeCopyFile(BgmodPath + 'vkSumi.conf', IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf')
      else
        SafeDeleteFile(IncludeTrailingPathDelimiter(GameDir) + 'vkSumi.conf');
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
  HasGamePerformance := False;
  for i := 0 to EnvList.Count - 1 do
  begin
    Line := EnvList[i];
    if SameText(Trim(Line), 'game-performance') or SameText(Trim(Line), 'game-performance=1') or
       SameText(Copy(Trim(Line), 1, 17), 'game-performance=') then
    begin
      HasGamePerformance := True;
      Continue;
    end;
    p := Pos('=', Line);
    if p > 0 then
    begin
      Key := Copy(Line, 1, p - 1);
      Val := Copy(Line, p + 1, MaxInt);
      if SameText(Key, 'game-performance') then
      begin
        HasGamePerformance := True;
        Continue;
      end;
      // Always export DXIL_SPIRV_CONFIG and MANGOHUD_CONFIGFILE.
      // Export LSFG_* / LSFGVK_* environment variables if GOverlayLossless is enabled.
      // Other environment variables are exported if GOverlayTweaks is enabled.
      if (Key = 'MANGOHUD_CONFIGFILE') or (Key = 'DXIL_SPIRV_CONFIG') or
         (GOverlayLossless and ((Pos('LSFG_', Key) = 1) or (Pos('LSFGVK_', Key) = 1))) or
         GOverlayTweaks then
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
    Log('Export: ENABLE_VKBASALT=1');
    SetEnvVarInList(EnvStrings, 'VKBASALT_LOG_LEVEL', 'info');
    Log('Export: VKBASALT_LOG_LEVEL=info');
    if CentralLogDir <> '' then
    begin
      SetEnvVarInList(EnvStrings, 'VKBASALT_LOG_FILE', IncludeTrailingPathDelimiter(CentralLogDir) + 'vkbasalt.log');
      Log('Export: VKBASALT_LOG_FILE=' + IncludeTrailingPathDelimiter(CentralLogDir) + 'vkbasalt.log');
    end;
  end;
  if GOverlayVkSumi then
  begin
    SetEnvVarInList(EnvStrings, 'ENABLE_VKSUMI', '1');
    Log('Export: ENABLE_VKSUMI=1');
    SetEnvVarInList(EnvStrings, 'VKSUMI_DEBUG', '1');
    Log('Export: VKSUMI_DEBUG=1');
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
  
  if GOverlayLossless then
  begin
    if InterpolationMethod = 'lsfg' then
    begin
      TomlPath := IncludeTrailingPathDelimiter(ConfigDir) + 'lsfg.toml';
      TomlLines := TStringList.Create;
      try
        // If lsfg.toml already exists, load existing settings from it
        if FileExists(TomlPath) then
        begin
          TomlLines.LoadFromFile(TomlPath);
          for i := 0 to TomlLines.Count - 1 do
          begin
            Line := Trim(TomlLines[i]);
            if (Line = '') or (Line[1] = '#') or (Line[1] = '[') then Continue;
            p := Pos('=', Line);
            if p > 0 then
            begin
              Key := LowerCase(Trim(Copy(Line, 1, p - 1)));
              Val := Trim(Copy(Line, p + 1, MaxInt));
              if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] in ['"', '''']) then
                Val := Copy(Val, 2, Length(Val) - 2);
              if (Key = 'dll') and (LsfgDllPath = '') then LsfgDllPath := Val
              else if Key = 'multiplier' then LsfgMult := StrToIntDef(Val, LsfgMult)
              else if Key = 'flow_scale' then LsfgFlow := Val
              else if Key = 'performance_mode' then LsfgPerfStr := Val
              else if Key = 'hdr_mode' then LsfgHdrStr := Val
              else if (Key = 'legacy') or (Key = 'no_fp16') then LsfgLegacyStr := Val
              else if (Key = 'pacing') or (Key = 'experimental_present_mode') then LsfgPacing := Val;
            end;
          end;
        end;
        
        if LsfgFlow = '' then LsfgFlow := '1.0';
        if (LsfgPerfStr <> 'true') and (LsfgPerfStr <> 'false') then
        begin
          if LsfgPerf = '1' then LsfgPerfStr := 'true' else LsfgPerfStr := 'false';
        end;
        if (LsfgHdrStr <> 'true') and (LsfgHdrStr <> 'false') then
        begin
          if LsfgHdr = '1' then LsfgHdrStr := 'true' else LsfgHdrStr := 'false';
        end;
        if (LsfgLegacyStr <> 'true') and (LsfgLegacyStr <> 'false') then
        begin
          if LsfgLegacy = '1' then LsfgLegacyStr := 'true' else LsfgLegacyStr := 'false';
        end;
        
        TomlLines.Clear;
        TomlLines.Add('version = 1');
        TomlLines.Add('');
        TomlLines.Add('[global]');
        TomlLines.Add('dll = "' + LsfgDllPath + '"');
        TomlLines.Add('');
        TomlLines.Add('[[game]]');
        TomlLines.Add('exe = "pascube"');
        TomlLines.Add('dll = "' + LsfgDllPath + '"');
        TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
        TomlLines.Add('flow_scale = ' + LsfgFlow);
        TomlLines.Add('performance_mode = ' + LsfgPerfStr);
        TomlLines.Add('hdr_mode = ' + LsfgHdrStr);
        TomlLines.Add('legacy = ' + LsfgLegacyStr);
        TomlLines.Add('experimental_present_mode = "' + LsfgPacing + '"');
        TomlLines.Add('');
        TomlLines.Add('[[game]]');
        TomlLines.Add('exe = "vkcube"');
        TomlLines.Add('dll = "' + LsfgDllPath + '"');
        TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
        TomlLines.Add('flow_scale = ' + LsfgFlow);
        TomlLines.Add('performance_mode = ' + LsfgPerfStr);
        TomlLines.Add('hdr_mode = ' + LsfgHdrStr);
        TomlLines.Add('legacy = ' + LsfgLegacyStr);
        TomlLines.Add('experimental_present_mode = "' + LsfgPacing + '"');
        
        if TargetExeName <> '' then
        begin
          TomlLines.Add('');
          TomlLines.Add('[[game]]');
          TomlLines.Add('exe = "' + TargetExeName + '"');
          TomlLines.Add('dll = "' + LsfgDllPath + '"');
          TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
          TomlLines.Add('flow_scale = ' + LsfgFlow);
          TomlLines.Add('performance_mode = ' + LsfgPerfStr);
          TomlLines.Add('hdr_mode = ' + LsfgHdrStr);
          TomlLines.Add('legacy = ' + LsfgLegacyStr);
          TomlLines.Add('experimental_present_mode = "' + LsfgPacing + '"');
        end;
        
        TomlLines.SaveToFile(TomlPath);
        
        SetEnvVarInList(EnvStrings, 'LSFG_CONFIG', TomlPath);
        Log('Export: LSFG_CONFIG=' + TomlPath);
        if LsfgGpu <> '' then
        begin
          SetEnvVarInList(EnvStrings, 'LSFG_GPU', LsfgGpu);
          Log('Export: LSFG_GPU=' + LsfgGpu);
        end;
      finally
        TomlLines.Free;
      end;
    end
    else // mako
    begin
      TomlPath := IncludeTrailingPathDelimiter(ConfigDir) + 'conf.toml';
      TomlLines := TStringList.Create;
      try
        // If conf.toml or lsfg.toml already exists, load existing settings
        if FileExists(TomlPath) then
        begin
          CurProfile := '';
          TomlLines.LoadFromFile(TomlPath);
          for i := 0 to TomlLines.Count - 1 do
          begin
            Line := Trim(TomlLines[i]);
            if (Line = '') or (Line[1] = '#') then Continue;
            if Pos('[[profile]]', Line) > 0 then
            begin
              CurProfile := '';
              Continue;
            end;
            p := Pos('=', Line);
            if p > 0 then
            begin
              Key := LowerCase(Trim(Copy(Line, 1, p - 1)));
              Val := Trim(Copy(Line, p + 1, MaxInt));
              if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] in ['"', '''']) then
                Val := Copy(Val, 2, Length(Val) - 2);
              if Key = 'name' then
              begin
                CurProfile := LowerCase(Val);
                Continue;
              end;
              if (TargetExeName <> '') and ((CurProfile = 'pascube') or (CurProfile = 'vkcube')) then
                Continue;
              if (Key = 'dll') and (LsfgDllPath = '') then LsfgDllPath := Val
              else if Key = 'multiplier' then LsfgMult := StrToIntDef(Val, LsfgMult)
              else if Key = 'flow_scale' then LsfgFlow := Val
              else if Key = 'performance_mode' then LsfgPerfStr := Val
              else if Key = 'ultra_performance' then MakoUltraPerf := Val
              else if Key = 'allow_fp16' then MakoAllowFp16 := Val
              else if (Key = 'legacy') or (Key = 'no_fp16') then
              begin
                if (Val = 'true') or (Val = '1') then MakoAllowFp16 := 'false' else MakoAllowFp16 := 'true';
              end
              else if Key = 'frame_generation_enabled' then MakoFgLive := Val
              else if Key = 'frame_generation_refresh_threshold' then MakoRefreshThreshold := Val
              else if Key = 'base_fps_cap' then MakoBaseFpsCap := Val
              else if Key = 'adaptive' then MakoAdaptive := Val
              else if Key = 'target_fps' then MakoTargetFps := Val
              else if Key = 'adaptive_max_multiplier' then MakoAdaptiveMaxMult := Val
              else if Key = 'adaptive_auto_base_fps_cap' then MakoSteady2xCap := Val
              else if Key = 'scaling_enabled' then MakoScalingEnabled := Val
              else if Key = 'scaling_method' then MakoScalingMethod := Val
              else if Key = 'scaling_factor' then MakoScalingFactor := Val
              else if Key = 'scaling_sharpness' then MakoScalingSharpness := Val
              else if Key = 'scaling_supersampling' then MakoScalingSs := Val
              else if (Key = 'pacing') or (Key = 'experimental_present_mode') then LsfgPacing := Val;
            end;
          end;
        end
        else if FileExists(IncludeTrailingPathDelimiter(ConfigDir) + 'lsfg.toml') then
        begin
          TomlLines.LoadFromFile(IncludeTrailingPathDelimiter(ConfigDir) + 'lsfg.toml');
          for i := 0 to TomlLines.Count - 1 do
          begin
            Line := Trim(TomlLines[i]);
            if (Line = '') or (Line[1] = '#') or (Line[1] = '[') then Continue;
            p := Pos('=', Line);
            if p > 0 then
            begin
              Key := LowerCase(Trim(Copy(Line, 1, p - 1)));
              Val := Trim(Copy(Line, p + 1, MaxInt));
              if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] in ['"', '''']) then
                Val := Copy(Val, 2, Length(Val) - 2);
              if (Key = 'dll') and (LsfgDllPath = '') then LsfgDllPath := Val
              else if Key = 'multiplier' then LsfgMult := StrToIntDef(Val, LsfgMult)
              else if Key = 'flow_scale' then LsfgFlow := Val
              else if Key = 'performance_mode' then LsfgPerfStr := Val
              else if (Key = 'legacy') or (Key = 'no_fp16') then
              begin
                if (Val = 'true') or (Val = '1') then MakoAllowFp16 := 'false' else MakoAllowFp16 := 'true';
              end
              else if (Key = 'pacing') or (Key = 'experimental_present_mode') then LsfgPacing := Val;
            end;
          end;
        end;

        if LsfgFlow = '' then LsfgFlow := '1.00';
        if LsfgPerfStr = '' then LsfgPerfStr := 'false';
        if MakoUltraPerf = '' then MakoUltraPerf := 'false';
        if MakoAllowFp16 = '' then MakoAllowFp16 := 'true';
        if MakoFgLive = '' then MakoFgLive := 'true';
        if MakoRefreshThreshold = '' then MakoRefreshThreshold := '0';
        if MakoBaseFpsCap = '' then MakoBaseFpsCap := '0';
        if MakoAdaptive = '' then MakoAdaptive := 'false';
        if MakoTargetFps = '' then MakoTargetFps := '90';
        if MakoAdaptiveMaxMult = '' then MakoAdaptiveMaxMult := '3';
        if MakoSteady2xCap = '' then MakoSteady2xCap := 'false';
        if MakoScalingEnabled = '' then MakoScalingEnabled := 'false';
        if MakoScalingMethod = '' then MakoScalingMethod := 'ls1';
        if MakoScalingFactor = '' then MakoScalingFactor := '1.50';
        if MakoScalingSharpness = '' then MakoScalingSharpness := '0.80';
        if MakoScalingSs = '' then MakoScalingSs := 'false';

        TomlLines.Clear;
        TomlLines.Add('version = 2');
        TomlLines.Add('');
        TomlLines.Add('dll = "' + LsfgDllPath + '"');
        TomlLines.Add('allow_fp16 = ' + MakoAllowFp16);
        TomlLines.Add('');

        // Profile: pascube
        TomlLines.Add('[[profile]]');
        TomlLines.Add('name = "pascube"');
        TomlLines.Add('active_in = ["pascube"]');
        if MakoScalingEnabled = 'true' then
        begin
          TomlLines.Add('scaling_enabled = true');
          TomlLines.Add('scaling_method = "' + MakoScalingMethod + '"');
          TomlLines.Add('scaling_factor = ' + MakoScalingFactor);
          TomlLines.Add('scaling_supersampling = ' + MakoScalingSs);
          TomlLines.Add('scaling_sharpness = ' + MakoScalingSharpness);
        end
        else
          TomlLines.Add('scaling_enabled = false');

        if MakoAdaptive = 'true' then
        begin
          TomlLines.Add('frame_generation_enabled = true');
          TomlLines.Add('adaptive = true');
          TomlLines.Add('target_fps = ' + MakoTargetFps);
          TomlLines.Add('adaptive_max_multiplier = ' + MakoAdaptiveMaxMult);
          TomlLines.Add('adaptive_auto_base_fps_cap = ' + MakoSteady2xCap);
        end
        else if LsfgMult >= 2 then
        begin
          TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
          TomlLines.Add('frame_generation_enabled = ' + MakoFgLive);
          TomlLines.Add('adaptive = false');
        end
        else
        begin
          TomlLines.Add('frame_generation_enabled = false');
          TomlLines.Add('adaptive = false');
        end;
        TomlLines.Add('frame_generation_refresh_threshold = ' + MakoRefreshThreshold);
        TomlLines.Add('base_fps_cap = ' + MakoBaseFpsCap);
        TomlLines.Add('performance_mode = ' + LsfgPerfStr);
        TomlLines.Add('ultra_performance = ' + MakoUltraPerf);
        TomlLines.Add('flow_scale = ' + LsfgFlow);
        TomlLines.Add('pacing = "none"');
        TomlLines.Add('');

        // Profile: vkcube
        TomlLines.Add('[[profile]]');
        TomlLines.Add('name = "vkcube"');
        TomlLines.Add('active_in = ["vkcube"]');
        if MakoScalingEnabled = 'true' then
        begin
          TomlLines.Add('scaling_enabled = true');
          TomlLines.Add('scaling_method = "' + MakoScalingMethod + '"');
          TomlLines.Add('scaling_factor = ' + MakoScalingFactor);
          TomlLines.Add('scaling_supersampling = ' + MakoScalingSs);
          TomlLines.Add('scaling_sharpness = ' + MakoScalingSharpness);
        end
        else
          TomlLines.Add('scaling_enabled = false');

        if MakoAdaptive = 'true' then
        begin
          TomlLines.Add('frame_generation_enabled = true');
          TomlLines.Add('adaptive = true');
          TomlLines.Add('target_fps = ' + MakoTargetFps);
          TomlLines.Add('adaptive_max_multiplier = ' + MakoAdaptiveMaxMult);
          TomlLines.Add('adaptive_auto_base_fps_cap = ' + MakoSteady2xCap);
        end
        else if LsfgMult >= 2 then
        begin
          TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
          TomlLines.Add('frame_generation_enabled = ' + MakoFgLive);
          TomlLines.Add('adaptive = false');
        end
        else
        begin
          TomlLines.Add('frame_generation_enabled = false');
          TomlLines.Add('adaptive = false');
        end;
        TomlLines.Add('frame_generation_refresh_threshold = ' + MakoRefreshThreshold);
        TomlLines.Add('base_fps_cap = ' + MakoBaseFpsCap);
        TomlLines.Add('performance_mode = ' + LsfgPerfStr);
        TomlLines.Add('ultra_performance = ' + MakoUltraPerf);
        TomlLines.Add('flow_scale = ' + LsfgFlow);
        TomlLines.Add('pacing = "none"');

        if TargetExeName <> '' then
        begin
          ProfileName := ChangeFileExt(ExtractFileName(TargetExeName), '');
          if ProfileName = '' then ProfileName := TargetExeName;
          TomlLines.Add('');
          TomlLines.Add('[[profile]]');
          TomlLines.Add('name = "' + ProfileName + '"');
          TomlLines.Add('active_in = ["' + TargetExeName + '", "' + ProfileName + '", "' + ProfileName + '.exe", "' + ProfileName + '_dx12.exe", "' + ProfileName + '_dx11.exe", "' + LowerCase(ProfileName) + '_dx12.exe", "' + LowerCase(ProfileName) + '_dx11.exe", "wine64-preloader", "wine-preloader"]');
          if MakoScalingEnabled = 'true' then
          begin
            TomlLines.Add('scaling_enabled = true');
            TomlLines.Add('scaling_method = "' + MakoScalingMethod + '"');
            TomlLines.Add('scaling_factor = ' + MakoScalingFactor);
            TomlLines.Add('scaling_supersampling = ' + MakoScalingSs);
            TomlLines.Add('scaling_sharpness = ' + MakoScalingSharpness);
          end
          else
            TomlLines.Add('scaling_enabled = false');

          if MakoAdaptive = 'true' then
          begin
            TomlLines.Add('frame_generation_enabled = true');
            TomlLines.Add('adaptive = true');
            TomlLines.Add('target_fps = ' + MakoTargetFps);
            TomlLines.Add('adaptive_max_multiplier = ' + MakoAdaptiveMaxMult);
            TomlLines.Add('adaptive_auto_base_fps_cap = ' + MakoSteady2xCap);
          end
          else if LsfgMult >= 2 then
          begin
            TomlLines.Add('multiplier = ' + IntToStr(LsfgMult));
            TomlLines.Add('frame_generation_enabled = ' + MakoFgLive);
            TomlLines.Add('adaptive = false');
          end
          else
          begin
            TomlLines.Add('frame_generation_enabled = false');
            TomlLines.Add('adaptive = false');
          end;
          TomlLines.Add('frame_generation_refresh_threshold = ' + MakoRefreshThreshold);
          TomlLines.Add('base_fps_cap = ' + MakoBaseFpsCap);
          TomlLines.Add('performance_mode = ' + LsfgPerfStr);
          TomlLines.Add('ultra_performance = ' + MakoUltraPerf);
          TomlLines.Add('flow_scale = ' + LsfgFlow);
          TomlLines.Add('pacing = "none"');
        end;
        
        TomlLines.SaveToFile(TomlPath);
        TomlLines.SaveToFile(IncludeTrailingPathDelimiter(ConfigDir) + 'lsfg.toml');
        
        SetEnvVarInList(EnvStrings, 'ENABLE_MAKO', '1');
        SetEnvVarInList(EnvStrings, 'MAKO_CONFIG', TomlPath);
        SetEnvVarInList(EnvStrings, 'MAKO_DISABLE_HDR_EXPOSURE', '1');
        SetEnvVarInList(EnvStrings, 'DISABLE_GAMESCOPE_WSI', '1');
        SetEnvVarInList(EnvStrings, 'DISABLE_LSFG', '1');
        SetEnvVarInList(EnvStrings, 'DISABLE_LSFGVK', '1');
        SetEnvVarInList(EnvStrings, 'LSFG_CONFIG', TomlPath);
        if ProfileName <> '' then
        begin
          SetEnvVarInList(EnvStrings, 'MAKO_PROFILE', ProfileName);
          Log('Export: MAKO_PROFILE=' + ProfileName);
        end;
        if MakoScalingEnabled = 'true' then
        begin
          SetEnvVarInList(EnvStrings, 'ENABLE_MAKO_SPATIAL_SCALING', '1');
          Log('Export: ENABLE_MAKO_SPATIAL_SCALING=1');
        end;
        if LsfgGpu <> '' then
        begin
          SetEnvVarInList(EnvStrings, 'MAKO_GPU', LsfgGpu);
          SetEnvVarInList(EnvStrings, 'LSFG_GPU', LsfgGpu);
          Log('Export: MAKO_GPU=' + LsfgGpu);
        end;
        Log('Export: ENABLE_MAKO=1');
        Log('Export: MAKO_CONFIG=' + TomlPath);
        Log('Export: LSFG_CONFIG=' + TomlPath);
      finally
        TomlLines.Free;
      end;
    end;
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
  
  if HasGamePerformance and GOverlayTweaks then
  begin
    Log('Using wrapper: game-performance');
    SetLength(ArgsStrings, ParamCount - StartArgIdx + 2);
    SetLength(Args, ParamCount - StartArgIdx + 3);
    ArgsStrings[0] := 'game-performance';
    Args[0] := PChar(ArgsStrings[0]);
    for i := StartArgIdx to ParamCount do
    begin
      ArgsStrings[i - StartArgIdx + 1] := ParamStr(i);
      Args[i - StartArgIdx + 1] := PChar(ArgsStrings[i - StartArgIdx + 1]);
      Log('Arg ' + IntToStr(i - StartArgIdx + 1) + ': ' + ArgsStrings[i - StartArgIdx + 1]);
    end;
    Args[ParamCount - StartArgIdx + 2] := nil;
  end
  else
  begin
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
  end;
  
  Log('------------------------------------------------------------------------');
  Log('Launching subprocess: ' + ArgsStrings[0]);
  Log('------------------------------------------------------------------------');
  
  // Setup tool logging in CentralLogDir and GameDir
  MakoCentralLogFile := '';
  MakoGameLogFile := '';
  LsfgCentralLogFile := '';
  LsfgGameLogFile := '';
  OptiCentralLogFile := '';
  OptiGameLogFile := '';
  SumiCentralLogFile := '';
  SumiGameLogFile := '';
  BasaltCentralLogFile := '';
  BasaltGameLogFile := '';
  InternalOptiLogPath := '';

  if GOverlayLossless and (InterpolationMethod = 'mako') then
  begin
    if ProfileName = '' then
      ProfileName := ExtractFileName(ExcludeTrailingPathDelimiter(ConfigDir));

    if CentralLogDir <> '' then
    begin
      MakoCentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'mako.log';
      InitToolLogFile(MakoCentralLogFile, 'MAKO', GameDir, TomlPath);
      Log('MAKO central log: ' + MakoCentralLogFile);
    end;
    if (GameDir <> '') and DirectoryExists(GameDir) and (fpAccess(PChar(GameDir), W_OK) = 0) then
    begin
      MakoGameLogFile := IncludeTrailingPathDelimiter(GameDir) + 'mako.log';
      InitToolLogFile(MakoGameLogFile, 'MAKO', GameDir, TomlPath);
      Log('MAKO game log: ' + MakoGameLogFile);
    end;
  end;

  if GOverlayLossless and (InterpolationMethod = 'lsfg') then
  begin
    if ProfileName = '' then
      ProfileName := ExtractFileName(ExcludeTrailingPathDelimiter(ConfigDir));

    if CentralLogDir <> '' then
    begin
      LsfgCentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'lsfg.log';
      InitToolLogFile(LsfgCentralLogFile, 'lsfg-vk', GameDir, TomlPath);
      Log('lsfg-vk central log: ' + LsfgCentralLogFile);
    end;
    if (GameDir <> '') and DirectoryExists(GameDir) and (fpAccess(PChar(GameDir), W_OK) = 0) then
    begin
      LsfgGameLogFile := IncludeTrailingPathDelimiter(GameDir) + 'lsfg.log';
      InitToolLogFile(LsfgGameLogFile, 'lsfg-vk', GameDir, TomlPath);
      Log('lsfg-vk game log: ' + LsfgGameLogFile);
    end;
  end;

  if GOverlayOptiscaler then
  begin
    if GameDir <> '' then
      InternalOptiLogPath := IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.log';

    if CentralLogDir <> '' then
    begin
      OptiCentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'optiscaler.log';
      InitToolLogFile(OptiCentralLogFile, 'OptiScaler', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'OptiScaler.ini');
      Log('OptiScaler central log: ' + OptiCentralLogFile);
    end;
    if (GameDir <> '') and DirectoryExists(GameDir) and (fpAccess(PChar(GameDir), W_OK) = 0) then
    begin
      OptiGameLogFile := IncludeTrailingPathDelimiter(GameDir) + 'optiscaler.log';
      InitToolLogFile(OptiGameLogFile, 'OptiScaler', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'OptiScaler.ini');
      Log('OptiScaler game log: ' + OptiGameLogFile);
    end;
  end;

  if GOverlayVkSumi then
  begin
    if CentralLogDir <> '' then
    begin
      SumiCentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'vksumi.log';
      InitToolLogFile(SumiCentralLogFile, 'vkSumi', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'vkSumi.conf');
      Log('vkSumi central log: ' + SumiCentralLogFile);
    end;
    if (GameDir <> '') and DirectoryExists(GameDir) and (fpAccess(PChar(GameDir), W_OK) = 0) then
    begin
      SumiGameLogFile := IncludeTrailingPathDelimiter(GameDir) + 'vksumi.log';
      InitToolLogFile(SumiGameLogFile, 'vkSumi', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'vkSumi.conf');
      Log('vkSumi game log: ' + SumiGameLogFile);
    end;
  end;

  if GOverlayVkBasalt then
  begin
    if CentralLogDir <> '' then
    begin
      BasaltCentralLogFile := IncludeTrailingPathDelimiter(CentralLogDir) + 'vkbasalt.log';
      InitToolLogFile(BasaltCentralLogFile, 'vkBasalt', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'vkBasalt.conf');
      Log('vkBasalt central log: ' + BasaltCentralLogFile);
    end;
    if (GameDir <> '') and DirectoryExists(GameDir) and (fpAccess(PChar(GameDir), W_OK) = 0) then
    begin
      BasaltGameLogFile := IncludeTrailingPathDelimiter(GameDir) + 'vkbasalt.log';
      InitToolLogFile(BasaltGameLogFile, 'vkBasalt', GameDir, IncludeTrailingPathDelimiter(ConfigDir) + 'vkBasalt.conf');
      Log('vkBasalt game log: ' + BasaltGameLogFile);
    end;
  end;

  HasAnyToolLogging := (GOverlayLossless and ((InterpolationMethod = 'mako') or (InterpolationMethod = 'lsfg'))) or GOverlayOptiscaler or GOverlayVkSumi or GOverlayVkBasalt;

  // If any tool logging is enabled, spawn background stderr filter process
  if HasAnyToolLogging and (
     (MakoCentralLogFile <> '') or (MakoGameLogFile <> '') or
     (LsfgCentralLogFile <> '') or (LsfgGameLogFile <> '') or
     (OptiCentralLogFile <> '') or (OptiGameLogFile <> '') or
     (SumiCentralLogFile <> '') or (SumiGameLogFile <> '') or
     (BasaltCentralLogFile <> '') or (BasaltGameLogFile <> '')
  ) then
  begin
    if fpPipe(PipeFds) = 0 then
    begin
      OrigStderr := fpDup(2);
      ForkPid := fpFork;
      if ForkPid = 0 then
      begin
        // Child: background logger process
        fpClose(PipeFds[1]);
        RunSubprocessLogger(PipeFds[0], OrigStderr,
          MakoCentralLogFile, MakoGameLogFile,
          LsfgCentralLogFile, LsfgGameLogFile,
          OptiCentralLogFile, OptiGameLogFile,
          SumiCentralLogFile, SumiGameLogFile,
          BasaltCentralLogFile, BasaltGameLogFile,
          InternalOptiLogPath,
          (GOverlayLossless and (InterpolationMethod = 'mako')),
          (GOverlayLossless and (InterpolationMethod = 'lsfg')),
          GOverlayOptiscaler, GOverlayVkSumi, GOverlayVkBasalt
        );
      end
      else if ForkPid > 0 then
      begin
        // Parent: redirect stderr to pipe write end and proceed to execvpe
        fpClose(PipeFds[0]);
        fpDup2(PipeFds[1], 2);
        fpClose(PipeFds[1]);
        if OrigStderr >= 0 then fpClose(OrigStderr);
      end;
    end;
  end;

  execvpe(Args[0], @Args[0], @EnvArgs[0]);
  
  // If we reach here, execvpe failed
  Log('Error: execvpe failed');
  EnvStrings.Free;
  Halt(127);
end.
