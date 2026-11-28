unit game_discovery;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, BaseUnix, fpjson, jsonparser;

type
  TGameKind = (gkSteam, gkNonSteam);
  TGameSource = (gsSteam, gsHeroic, gsFaugus, gsLocal);

  TGameDiscoveryItem = record
    Kind:          TGameKind;
    Source:        TGameSource;
    Name:          string;
    AppID:         string;
    InstallDir:    string;
    LibPath:       string;
    SubPath:       string;
    IsAppImage:    Boolean;
    IsNativeLinux: Boolean;
    CoverPath:     string;
  end;

  TGameDiscoveryArray = array of TGameDiscoveryItem;
  TAppImageNameNormalizer = function(const AFileName: string): string;

// Normalize a directory path for cross-source deduplication.
function NormalizeDiscoveryPath(const APath: string): string;

// Return True if AGames already contains a non-Steam item matching ASubPath.
function HasDiscoveredPath(const AGames: TGameDiscoveryArray; const ASubPath: string): Boolean;

// Append AItem to AGames when its normalized SubPath is not already present (for non-Steam).
function AddDiscoveredGameUnique(var AGames: TGameDiscoveryArray; const AItem: TGameDiscoveryItem): Boolean;

// Return True if AFilePath is a regular executable file carrying the ELF magic header.
function IsElfExecutable(const AFilePath: string): Boolean;

// Return True if ADirName matches a known non-game asset, save, redist, or cache directory.
function IsIgnoredNonGameSubdir(const ADirName: string): Boolean;

// Return True if AFileName matches a known installer, redistributable, or crash-reporter executable.
function IsIgnoredHelperExeName(const AFileName: string): Boolean;

// Inspect ADir up to AMaxDepth for Windows or native Linux game executables.
function InspectGameFolder(const ADir: string; AMaxDepth: Integer;
  out AHasExe, AIsNativeLinux: Boolean): Boolean;

// Scan a manually added non-Steam folder (auto-detecting single-game vs library-root layout).
procedure DiscoverNonSteamFolder(const AFolderPath: string;
  var AGames: TGameDiscoveryArray; ANormalizeAppImage: TAppImageNameNormalizer = nil);

// Parse Heroic Legendary installed.json into AGames.
procedure ParseHeroicLegendaryInstalled(const AJsonFile: string; var AGames: TGameDiscoveryArray);

// Parse Heroic GOG installed.json (with optional gog_library.json title lookup) into AGames.
procedure ParseHeroicGogInstalled(const AInstalledJson, ALibraryJson: string;
  var AGames: TGameDiscoveryArray);

// Parse Heroic Nile installed.json (with optional nile_library.json title lookup) into AGames.
procedure ParseHeroicNileInstalled(const AInstalledJson, ALibraryJson: string;
  var AGames: TGameDiscoveryArray);

// Parse Heroic sideload_apps/library.json into AGames.
procedure ParseHeroicSideloadLibrary(const ALibraryJson: string; var AGames: TGameDiscoveryArray);

// Discover all installed games from a Heroic config root directory.
procedure DiscoverHeroicGamesInDir(const AHeroicConfigDir: string;
  var AGames: TGameDiscoveryArray);

// Parse a Faugus Launcher games.json file into AGames.
procedure ParseFaugusGamesJson(const AGamesJsonFile: string; var AGames: TGameDiscoveryArray);

// Score a Steam Store search candidate title against a query title (-1000 = reject, >= 500 = match).
function ScoreSteamSearchMatch(const AQuery, ACandidate: string): Integer;

implementation

function NormalizeDiscoveryPath(const APath: string): string;
var
  Trimmed: string;
begin
  Trimmed := Trim(APath);
  if Trimmed = '' then
    Exit('');
  Result := ExcludeTrailingPathDelimiter(ExpandFileName(Trimmed));
end;

function HasDiscoveredPath(const AGames: TGameDiscoveryArray; const ASubPath: string): Boolean;
var
  TargetNorm: string;
  i: Integer;
begin
  Result := False;
  TargetNorm := NormalizeDiscoveryPath(ASubPath);
  if TargetNorm = '' then
    Exit;

  for i := 0 to High(AGames) do
  begin
    if (AGames[i].Kind = gkNonSteam) and
       (NormalizeDiscoveryPath(AGames[i].SubPath) = TargetNorm) then
      Exit(True);
  end;
end;

function AddDiscoveredGameUnique(var AGames: TGameDiscoveryArray;
  const AItem: TGameDiscoveryItem): Boolean;
begin
  if (AItem.Kind = gkNonSteam) and HasDiscoveredPath(AGames, AItem.SubPath) then
    Exit(False);

  SetLength(AGames, Length(AGames) + 1);
  AGames[High(AGames)] := AItem;
  Result := True;
end;

function IsElfExecutable(const AFilePath: string): Boolean;
var
  Info: BaseUnix.Stat;
  FS: TFileStream;
  Magic: array[0..3] of Byte;
begin
  Result := False;
  if not FileExists(AFilePath) then
    Exit;

  if BaseUnix.fpStat(AFilePath, Info) <> 0 then
    Exit;
  if not fpS_ISREG(Info.st_mode) then
    Exit;
  // Require at least one execute bit (user/group/other)
  if (Info.st_mode and &111) = 0 then
    Exit;

  try
    FS := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyNone);
    try
      if FS.Read(Magic[0], 4) = 4 then
        Result := (Magic[0] = $7F) and (Magic[1] = Ord('E')) and
                  (Magic[2] = Ord('L')) and (Magic[3] = Ord('F'));
    finally
      FS.Free;
    end;
  except
    Result := False;
  end;
end;

function IsIgnoredNonGameSubdir(const ADirName: string): Boolean;
const
  IGNORED_DIRS: array[0..37] of string = (
    'prefixes', 'common', 'compatdata', 'shadercache', 'downloads', 'tmp', 'temp',
    'save', 'saves', 'movies', 'movie', 'video', 'videos', 'docs', 'doc',
    'ereg', 'redist', '_commonredist', 'directx', 'vcredist', 'logs', 'log',
    'cache', 'crash', 'crashdumps', 'widescreen_patch', 'patch', 'patches',
    'mods', 'config', 'configs', 'soundtrack', 'ost', 'artbook', 'extras',
    'manual', 'manuals', 'support'
  );
var
  Lower: string;
  i: Integer;
begin
  Lower := LowerCase(Trim(ADirName));
  for i := Low(IGNORED_DIRS) to High(IGNORED_DIRS) do
    if Lower = IGNORED_DIRS[i] then
      Exit(True);
  Result := False;
end;

function IsIgnoredHelperExeName(const AFileName: string): Boolean;
const
  HELPER_PREFIXES: array[0..14] of string = (
    'unins', 'vcredist', 'vc_redist', 'dxsetup', 'crashhandler',
    'crashreport', 'unitycrashhandler', 'ereg', 'ndp', 'dotnet',
    'physx', 'openal', 'oalinst', 'ue4prereq', 'ueprereq'
  );
var
  Lower: string;
  i: Integer;
begin
  Lower := LowerCase(ExtractFileName(AFileName));
  if (Lower = 'setup.exe') or (Lower = 'install.exe') or (Lower = 'redist.exe') then
    Exit(True);

  for i := Low(HELPER_PREFIXES) to High(HELPER_PREFIXES) do
    if Pos(HELPER_PREFIXES[i], Lower) = 1 then
      Exit(True);
  Result := False;
end;

function HasExecuteBit(const AFilePath: string): Boolean;
var
  Info: BaseUnix.Stat;
begin
  Result := (BaseUnix.fpStat(AFilePath, Info) = 0) and
            fpS_ISREG(Info.st_mode) and ((Info.st_mode and &111) <> 0);
end;

function InspectGameFolder(const ADir: string; AMaxDepth: Integer;
  out AHasExe, AIsNativeLinux: Boolean): Boolean;
var
  HasWinExe, HasLinuxBinary, HasLinuxScript: Boolean;

  procedure Scan(const ACurDir: string; ADepth: Integer);
  var
    SR: TSearchRec;
    FullPath, LowerName, Ext: string;
  begin
    if FindFirst(IncludeTrailingPathDelimiter(ACurDir) + '*', faAnyFile, SR) <> 0 then
      Exit;
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') then
          Continue;

        FullPath := IncludeTrailingPathDelimiter(ACurDir) + SR.Name;
        if (SR.Attr and faDirectory) <> 0 then
        begin
          if (ADepth < AMaxDepth) and (not IsIgnoredNonGameSubdir(SR.Name)) then
            Scan(FullPath, ADepth + 1);
          Continue;
        end;

        LowerName := LowerCase(SR.Name);
        Ext := LowerCase(ExtractFileExt(SR.Name));

        if Ext = '.exe' then
        begin
          if not IsIgnoredHelperExeName(SR.Name) then
            HasWinExe := True;
        end
        else if (Ext = '.appimage') or (Ext = '.x86_64') or (Ext = '.x86') then
          HasLinuxBinary := True
        else if Ext = '.sh' then
        begin
          if HasExecuteBit(FullPath) or (LowerName = 'start.sh') or
             (LowerName = 'run.sh') or (LowerName = 'launch.sh') then
            HasLinuxScript := True;
        end
        else if (Pos('.so.', LowerName) = 0) and (Ext <> '.so') and IsElfExecutable(FullPath) then
          HasLinuxBinary := True;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

begin
  HasWinExe := False;
  HasLinuxBinary := False;
  HasLinuxScript := False;

  if DirectoryExists(ADir) then
    Scan(ADir, 0);

  AHasExe := HasWinExe or HasLinuxBinary or HasLinuxScript;
  AIsNativeLinux := HasLinuxBinary or (HasLinuxScript and (not HasWinExe));
  Result := AHasExe;
end;

procedure DiscoverNonSteamFolder(const AFolderPath: string;
  var AGames: TGameDiscoveryArray; ANormalizeAppImage: TAppImageNameNormalizer = nil);
var
  CleanFolder, SubPath, GameName, Ext: string;
  RootHasNonAppImageExe, RootIsLinux, DeepHasExe, DeepIsLinux: Boolean;
  SubHasExe, SubIsLinux, FoundChildGame: Boolean;
  SR: TSearchRec;
  Item: TGameDiscoveryItem;

  function HasRootNonAppImageExe(const ADir: string; out AIsLinux: Boolean): Boolean;
  var
    RSR: TSearchRec;
    FullPath, LowerName, RExt: string;
    WinExe, LinuxBin, LinuxSh: Boolean;
  begin
    WinExe := False;
    LinuxBin := False;
    LinuxSh := False;
    if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*', faAnyFile, RSR) = 0 then
    try
      repeat
        if (RSR.Name = '.') or (RSR.Name = '..') then Continue;
        if (RSR.Attr and faDirectory) <> 0 then Continue;
        FullPath := IncludeTrailingPathDelimiter(ADir) + RSR.Name;
        LowerName := LowerCase(RSR.Name);
        RExt := LowerCase(ExtractFileExt(RSR.Name));
        if RExt = '.exe' then
        begin
          if not IsIgnoredHelperExeName(RSR.Name) then
            WinExe := True;
        end
        else if (RExt = '.x86_64') or (RExt = '.x86') then
          LinuxBin := True
        else if RExt = '.sh' then
        begin
          if HasExecuteBit(FullPath) or (LowerName = 'start.sh') or
             (LowerName = 'run.sh') or (LowerName = 'launch.sh') then
            LinuxSh := True;
        end
        else if (RExt <> '.appimage') and (Pos('.so.', LowerName) = 0) and
                (RExt <> '.so') and IsElfExecutable(FullPath) then
          LinuxBin := True;
      until FindNext(RSR) <> 0;
    finally
      FindClose(RSR);
    end;
    Result := WinExe or LinuxBin or LinuxSh;
    AIsLinux := LinuxBin or (LinuxSh and (not WinExe));
  end;

  function MakeLocalItem(const AName, ALibPath, ASubPath: string;
    AIsAppImage, AIsLinux: Boolean): TGameDiscoveryItem;
  begin
    Result := Default(TGameDiscoveryItem);
    Result.Kind := gkNonSteam;
    Result.Source := gsLocal;
    Result.Name := AName;
    Result.LibPath := ALibPath;
    Result.SubPath := ASubPath;
    Result.IsAppImage := AIsAppImage;
    Result.IsNativeLinux := AIsLinux;
  end;

begin
  CleanFolder := NormalizeDiscoveryPath(AFolderPath);
  if (CleanFolder = '') or (not DirectoryExists(CleanFolder)) then
    Exit;

  // If the selected folder itself contains a game executable at root, register
  // it as a single game and avoid turning its internal subfolders into cards.
  RootHasNonAppImageExe := HasRootNonAppImageExe(CleanFolder, RootIsLinux);
  if RootHasNonAppImageExe then
  begin
    GameName := ExtractFileName(CleanFolder);
    if GameName <> '' then
      AddDiscoveredGameUnique(AGames,
        MakeLocalItem(GameName, ExtractFileDir(CleanFolder), CleanFolder, False, RootIsLinux));
    Exit;
  end;

  FoundChildGame := False;
  if FindFirst(IncludeTrailingPathDelimiter(CleanFolder) + '*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then
        Continue;

      SubPath := IncludeTrailingPathDelimiter(CleanFolder) + SR.Name;

      if (SR.Attr and faDirectory) = 0 then
      begin
        Ext := LowerCase(ExtractFileExt(SR.Name));
        if Ext = '.appimage' then
        begin
          if Assigned(ANormalizeAppImage) then
            GameName := ANormalizeAppImage(SR.Name)
          else
            GameName := ChangeFileExt(SR.Name, '');
          if GameName <> '' then
          begin
            Item := MakeLocalItem(GameName, CleanFolder, SubPath, True, True);
            AddDiscoveredGameUnique(AGames, Item);
            FoundChildGame := True;
          end;
        end;
        Continue;
      end;

      if IsIgnoredNonGameSubdir(SR.Name) then
        Continue;

      if InspectGameFolder(SubPath, 2, SubHasExe, SubIsLinux) then
      begin
        Item := MakeLocalItem(SR.Name, CleanFolder, SubPath, False, SubIsLinux);
        AddDiscoveredGameUnique(AGames, Item);
        FoundChildGame := True;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;

  // Fallback for single-game folders whose executable resides one level deep (e.g. bin/game.exe)
  if (not FoundChildGame) and InspectGameFolder(CleanFolder, 1, DeepHasExe, DeepIsLinux) then
  begin
    GameName := ExtractFileName(CleanFolder);
    if GameName <> '' then
      AddDiscoveredGameUnique(AGames,
        MakeLocalItem(GameName, ExtractFileDir(CleanFolder), CleanFolder, False, DeepIsLinux));
  end;
end;

function LoadJsonFileSafe(const AFilePath: string): TJSONData;
var
  SL: TStringList;
begin
  Result := nil;
  if not FileExists(AFilePath) then
    Exit;
  SL := TStringList.Create;
  try
    try
      SL.LoadFromFile(AFilePath);
      if Trim(SL.Text) <> '' then
        Result := GetJSON(SL.Text);
    except
      FreeAndNil(Result);
    end;
  finally
    SL.Free;
  end;
end;

procedure PopulateHeroicTitleMap(const ALibraryJson, AArrayKey: string;
  AMap: TStringList);
var
  Data, ArrItem: TJSONData;
  RootObj, ItemObj: TJSONObject;
  Arr: TJSONArray;
  i: Integer;
  AppKey, Title: string;
begin
  Data := LoadJsonFileSafe(ALibraryJson);
  if not Assigned(Data) then
    Exit;
  try
    Arr := nil;
    if Data is TJSONArray then
      Arr := TJSONArray(Data)
    else if Data is TJSONObject then
    begin
      RootObj := TJSONObject(Data);
      ArrItem := RootObj.Find(AArrayKey);
      if not Assigned(ArrItem) then
        ArrItem := RootObj.Find('games');
      if Assigned(ArrItem) and (ArrItem is TJSONArray) then
        Arr := TJSONArray(ArrItem);
    end;

    if Assigned(Arr) then
    begin
      for i := 0 to Arr.Count - 1 do
      begin
        if not (Arr.Items[i] is TJSONObject) then Continue;
        ItemObj := TJSONObject(Arr.Items[i]);
        AppKey := Trim(ItemObj.Get('app_name', ''));
        if AppKey = '' then
          AppKey := Trim(ItemObj.Get('id', ''));
        Title := Trim(ItemObj.Get('title', ''));
        if (AppKey <> '') and (Title <> '') then
          AMap.Values[AppKey] := Title;
      end;
    end;
  finally
    Data.Free;
  end;
end;

procedure ParseHeroicLegendaryInstalled(const AJsonFile: string;
  var AGames: TGameDiscoveryArray);
var
  Data: TJSONData;
  RootObj, EntryObj: TJSONObject;
  i: Integer;
  InstallPath, Title, PlatformStr: string;
  Item: TGameDiscoveryItem;
begin
  Data := LoadJsonFileSafe(AJsonFile);
  if not Assigned(Data) then
    Exit;
  try
    if not (Data is TJSONObject) then
      Exit;
    RootObj := TJSONObject(Data);
    for i := 0 to RootObj.Count - 1 do
    begin
      if not (RootObj.Items[i] is TJSONObject) then
        Continue;
      EntryObj := TJSONObject(RootObj.Items[i]);
      if EntryObj.Get('is_dlc', False) then
        Continue;

      InstallPath := NormalizeDiscoveryPath(EntryObj.Get('install_path', ''));
      if (InstallPath = '') or (not DirectoryExists(InstallPath)) then
        Continue;

      Title := Trim(EntryObj.Get('title', ''));
      if Title = '' then
        Title := ExtractFileName(InstallPath);
      PlatformStr := EntryObj.Get('platform', '');

      Item := Default(TGameDiscoveryItem);
      Item.Kind := gkNonSteam;
      Item.Source := gsHeroic;
      Item.Name := Title;
      Item.AppID := RootObj.Names[i];
      Item.SubPath := InstallPath;
      Item.LibPath := ExtractFileDir(InstallPath);
      Item.IsNativeLinux := SameText(PlatformStr, 'linux');
      AddDiscoveredGameUnique(AGames, Item);
    end;
  finally
    Data.Free;
  end;
end;

procedure ParseHeroicGogInstalled(const AInstalledJson, ALibraryJson: string;
  var AGames: TGameDiscoveryArray);
var
  Data, InstData: TJSONData;
  RootObj, EntryObj: TJSONObject;
  Arr: TJSONArray;
  TitleMap: TStringList;
  i: Integer;
  AppName, InstallPath, Title, PlatformStr: string;
  Item: TGameDiscoveryItem;
begin
  Data := LoadJsonFileSafe(AInstalledJson);
  if not Assigned(Data) then
    Exit;

  TitleMap := TStringList.Create;
  try
    if ALibraryJson <> '' then
      PopulateHeroicTitleMap(ALibraryJson, 'games', TitleMap);

    Arr := nil;
    if Data is TJSONArray then
      Arr := TJSONArray(Data)
    else if Data is TJSONObject then
    begin
      RootObj := TJSONObject(Data);
      InstData := RootObj.Find('installed');
      if Assigned(InstData) and (InstData is TJSONArray) then
        Arr := TJSONArray(InstData);
    end;

    if not Assigned(Arr) then
      Exit;

    for i := 0 to Arr.Count - 1 do
    begin
      if not (Arr.Items[i] is TJSONObject) then
        Continue;
      EntryObj := TJSONObject(Arr.Items[i]);
      if EntryObj.Get('is_dlc', False) then
        Continue;

      InstallPath := NormalizeDiscoveryPath(EntryObj.Get('install_path', ''));
      if (InstallPath = '') or (not DirectoryExists(InstallPath)) then
        Continue;

      AppName := Trim(EntryObj.Get('appName', ''));
      if AppName = '' then
        AppName := Trim(EntryObj.Get('app_name', ''));
      Title := Trim(EntryObj.Get('title', ''));
      if (Title = '') and (AppName <> '') then
        Title := Trim(TitleMap.Values[AppName]);
      if Title = '' then
        Title := ExtractFileName(InstallPath);
      PlatformStr := EntryObj.Get('platform', '');

      Item := Default(TGameDiscoveryItem);
      Item.Kind := gkNonSteam;
      Item.Source := gsHeroic;
      Item.Name := Title;
      Item.AppID := AppName;
      Item.SubPath := InstallPath;
      Item.LibPath := ExtractFileDir(InstallPath);
      Item.IsNativeLinux := SameText(PlatformStr, 'linux');
      AddDiscoveredGameUnique(AGames, Item);
    end;
  finally
    TitleMap.Free;
    Data.Free;
  end;
end;

procedure ParseHeroicNileInstalled(const AInstalledJson, ALibraryJson: string;
  var AGames: TGameDiscoveryArray);
var
  Data: TJSONData;
  EntryObj: TJSONObject;
  Arr: TJSONArray;
  TitleMap: TStringList;
  i: Integer;
  AppId, InstallPath, Title: string;
  Item: TGameDiscoveryItem;
begin
  Data := LoadJsonFileSafe(AInstalledJson);
  if not Assigned(Data) then
    Exit;

  TitleMap := TStringList.Create;
  try
    if ALibraryJson <> '' then
      PopulateHeroicTitleMap(ALibraryJson, 'library', TitleMap);

    if not (Data is TJSONArray) then
      Exit;
    Arr := TJSONArray(Data);

    for i := 0 to Arr.Count - 1 do
    begin
      if not (Arr.Items[i] is TJSONObject) then
        Continue;
      EntryObj := TJSONObject(Arr.Items[i]);

      InstallPath := NormalizeDiscoveryPath(EntryObj.Get('path', ''));
      if (InstallPath = '') or (not DirectoryExists(InstallPath)) then
        Continue;

      AppId := Trim(EntryObj.Get('id', ''));
      Title := '';
      if AppId <> '' then
        Title := Trim(TitleMap.Values[AppId]);
      if Title = '' then
        Title := ExtractFileName(InstallPath);

      Item := Default(TGameDiscoveryItem);
      Item.Kind := gkNonSteam;
      Item.Source := gsHeroic;
      Item.Name := Title;
      Item.AppID := AppId;
      Item.SubPath := InstallPath;
      Item.LibPath := ExtractFileDir(InstallPath);
      Item.IsNativeLinux := False;
      AddDiscoveredGameUnique(AGames, Item);
    end;
  finally
    TitleMap.Free;
    Data.Free;
  end;
end;

procedure ParseHeroicSideloadLibrary(const ALibraryJson: string;
  var AGames: TGameDiscoveryArray);
var
  Data, GamesData, InstData: TJSONData;
  RootObj, EntryObj, InstObj: TJSONObject;
  Arr: TJSONArray;
  i: Integer;
  FolderPath, ExePath, Title, PlatformStr: string;
  IsDlc: Boolean;
  Item: TGameDiscoveryItem;
begin
  Data := LoadJsonFileSafe(ALibraryJson);
  if not Assigned(Data) then
    Exit;
  try
    if not (Data is TJSONObject) then
      Exit;
    RootObj := TJSONObject(Data);
    GamesData := RootObj.Find('games');
    if not (Assigned(GamesData) and (GamesData is TJSONArray)) then
      Exit;

    Arr := TJSONArray(GamesData);
    for i := 0 to Arr.Count - 1 do
    begin
      if not (Arr.Items[i] is TJSONObject) then
        Continue;
      EntryObj := TJSONObject(Arr.Items[i]);
      if not EntryObj.Get('is_installed', True) then
        Continue;

      FolderPath := Trim(EntryObj.Get('folder_name', ''));
      ExePath := '';
      PlatformStr := '';
      IsDlc := False;

      InstData := EntryObj.Find('install');
      if Assigned(InstData) and (InstData is TJSONObject) then
      begin
        InstObj := TJSONObject(InstData);
        ExePath := Trim(InstObj.Get('executable', ''));
        PlatformStr := InstObj.Get('platform', '');
        IsDlc := InstObj.Get('is_dlc', False);
      end;
      if IsDlc then
        Continue;

      if (FolderPath = '') and (ExePath <> '') then
        FolderPath := ExtractFileDir(ExePath);
      FolderPath := NormalizeDiscoveryPath(FolderPath);
      if (FolderPath = '') or (not DirectoryExists(FolderPath)) then
        Continue;

      Title := Trim(EntryObj.Get('title', ''));
      if Title = '' then
        Title := ExtractFileName(FolderPath);

      Item := Default(TGameDiscoveryItem);
      Item.Kind := gkNonSteam;
      Item.Source := gsHeroic;
      Item.Name := Title;
      Item.AppID := Trim(EntryObj.Get('app_name', ''));
      Item.SubPath := FolderPath;
      Item.LibPath := ExtractFileDir(FolderPath);
      Item.IsNativeLinux := SameText(PlatformStr, 'linux');
      AddDiscoveredGameUnique(AGames, Item);
    end;
  finally
    Data.Free;
  end;
end;

procedure DiscoverHeroicGamesInDir(const AHeroicConfigDir: string;
  var AGames: TGameDiscoveryArray);
var
  BaseDir: string;
begin
  if not DirectoryExists(AHeroicConfigDir) then
    Exit;
  BaseDir := IncludeTrailingPathDelimiter(AHeroicConfigDir);

  ParseHeroicLegendaryInstalled(
    BaseDir + 'legendaryConfig/legendary/installed.json', AGames);
  ParseHeroicGogInstalled(
    BaseDir + 'gog_store/installed.json',
    BaseDir + 'store_cache/gog_library.json', AGames);
  ParseHeroicNileInstalled(
    BaseDir + 'nile_config/nile/installed.json',
    BaseDir + 'store_cache/nile_library.json', AGames);
  ParseHeroicSideloadLibrary(
    BaseDir + 'sideload_apps/library.json', AGames);
end;

procedure ParseFaugusGamesJson(const AGamesJsonFile: string;
  var AGames: TGameDiscoveryArray);
var
  Data: TJSONData;
  Arr: TJSONArray;
  EntryObj: TJSONObject;
  i, e: Integer;
  Title, RawPath, PrefixPath, GameDir, CoverPath, CandidateExe, GameId, FaugusRoot: string;
  Item: TGameDiscoveryItem;
const
  COVER_EXTS: array[0..3] of string = ('.png', '.jpg', '.jpeg', '.webp');
begin
  Data := LoadJsonFileSafe(AGamesJsonFile);
  if not Assigned(Data) then
    Exit;
  FaugusRoot := IncludeTrailingPathDelimiter(ExtractFileDir(AGamesJsonFile));
  try
    if not (Data is TJSONArray) then
      Exit;
    Arr := TJSONArray(Data);
    for i := 0 to Arr.Count - 1 do
    begin
      if not (Arr.Items[i] is TJSONObject) then
        Continue;
      EntryObj := TJSONObject(Arr.Items[i]);
      if EntryObj.Get('hidden', False) then
        Continue;

      Title := Trim(EntryObj.Get('title', ''));
      if Title = '' then
        Title := Trim(EntryObj.Get('name', ''));
      if Title = '' then
        Continue;

      RawPath := Trim(EntryObj.Get('path', ''));
      PrefixPath := Trim(EntryObj.Get('prefix', ''));
      GameDir := '';

      if RawPath <> '' then
      begin
        if DirectoryExists(RawPath) then
          GameDir := NormalizeDiscoveryPath(RawPath)
        else if FileExists(RawPath) then
          GameDir := NormalizeDiscoveryPath(ExtractFileDir(RawPath))
        else if PrefixPath <> '' then
        begin
          CandidateExe := ExpandFileName(IncludeTrailingPathDelimiter(PrefixPath) + RawPath);
          if FileExists(CandidateExe) then
            GameDir := NormalizeDiscoveryPath(ExtractFileDir(CandidateExe));
        end;
      end;

      if (GameDir = '') or (not DirectoryExists(GameDir)) then
        Continue;

      GameId := Trim(EntryObj.Get('gameid', ''));
      CoverPath := Trim(EntryObj.Get('cover', ''));
      if (CoverPath <> '') and (not FileExists(CoverPath)) then
        CoverPath := '';

      if (CoverPath = '') and (GameId <> '') then
      begin
        for e := Low(COVER_EXTS) to High(COVER_EXTS) do
          if FileExists(FaugusRoot + 'covers' + PathDelim + GameId + COVER_EXTS[e]) then
          begin
            CoverPath := FaugusRoot + 'covers' + PathDelim + GameId + COVER_EXTS[e];
            Break;
          end;
        if CoverPath = '' then
          for e := Low(COVER_EXTS) to High(COVER_EXTS) do
            if FileExists(FaugusRoot + 'banners' + PathDelim + GameId + COVER_EXTS[e]) then
            begin
              CoverPath := FaugusRoot + 'banners' + PathDelim + GameId + COVER_EXTS[e];
              Break;
            end;
      end;

      Item := Default(TGameDiscoveryItem);
      Item.Kind := gkNonSteam;
      Item.Source := gsFaugus;
      Item.Name := Title;
      Item.AppID := GameId;
      Item.SubPath := GameDir;
      Item.LibPath := ExtractFileDir(GameDir);
      Item.IsNativeLinux := False;
      Item.CoverPath := CoverPath;
      AddDiscoveredGameUnique(AGames, Item);
    end;
  finally
    Data.Free;
  end;
end;

function NormalizeTitleForMatch(const S: string): string;
var
  Res: string;
  i: Integer;
begin
  Res := S;
  Res := StringReplace(Res, '™', '', [rfReplaceAll]);
  Res := StringReplace(Res, '®', '', [rfReplaceAll]);
  Res := StringReplace(Res, '©', '', [rfReplaceAll]);
  Res := LowerCase(Res);
  for i := 1 to Length(Res) do
    if Res[i] in [':', '-', '_', '/', '.', '''', ',', '!', '?', '&', '+'] then
      Res[i] := ' ';
  while Pos('  ', Res) > 0 do
    Res := StringReplace(Res, '  ', ' ', [rfReplaceAll]);
  Result := Trim(Res);
end;

procedure TokenizeNormalizedTitle(const ANorm: string; ATokens: TStringList);
var
  i, StartIdx: Integer;
  Tok: string;
begin
  ATokens.Clear;
  i := 1;
  while i <= Length(ANorm) do
  begin
    while (i <= Length(ANorm)) and (ANorm[i] = ' ') do
      Inc(i);
    if i > Length(ANorm) then Break;
    StartIdx := i;
    while (i <= Length(ANorm)) and (ANorm[i] <> ' ') do
      Inc(i);
    Tok := Copy(ANorm, StartIdx, i - StartIdx);
    if Tok <> '' then
      ATokens.Add(Tok);
  end;
end;

function NormalizeSequelToken(const ATok: string): string;
var
  i: Integer;
  AllDigits: Boolean;
begin
  Result := '';
  if ATok = '' then Exit;
  if ATok = 'ii' then Exit('2');
  if ATok = 'iii' then Exit('3');
  if ATok = 'iv' then Exit('4');
  if ATok = 'v' then Exit('5');
  if ATok = 'vi' then Exit('6');
  AllDigits := True;
  for i := 1 to Length(ATok) do
    if not (ATok[i] in ['0'..'9']) then
    begin
      AllDigits := False;
      Break;
    end;
  if AllDigits and (Length(ATok) <= 2) then
    Result := ATok;
end;

function HasTokenPhrase(const ANormText, APhrase: string): Boolean;
begin
  Result := Pos(' ' + APhrase + ' ', ' ' + ANormText + ' ') > 0;
end;

function ScoreSteamSearchMatch(const AQuery, ACandidate: string): Integer;
const
  HARD_REJECT_MARKERS: array[0..6] of string = (
    'soundtrack', 'ost', 'demo', 'dlc', 'season pass', 'artbook', 'vr'
  );
  PENALTY_MARKERS: array[0..6] of string = (
    'terminal cut', 'definitive edition', 'remastered', 'remake',
    'bundle', 'collection', 'pack'
  );
var
  NormQ, NormC, SeqQ, SeqC, SeqTok: string;
  QTokens, CTokens: TStringList;
  i, MatchedQ, ExtraC: Integer;
begin
  Result := -1000;
  NormQ := NormalizeTitleForMatch(AQuery);
  NormC := NormalizeTitleForMatch(ACandidate);
  if (NormQ = '') or (NormC = '') then Exit;
  if NormQ = NormC then Exit(1000);

  for i := Low(HARD_REJECT_MARKERS) to High(HARD_REJECT_MARKERS) do
    if HasTokenPhrase(NormC, HARD_REJECT_MARKERS[i]) and
       (not HasTokenPhrase(NormQ, HARD_REJECT_MARKERS[i])) then
      Exit(-1000);

  QTokens := TStringList.Create;
  CTokens := TStringList.Create;
  try
    TokenizeNormalizedTitle(NormQ, QTokens);
    TokenizeNormalizedTitle(NormC, CTokens);
    if (QTokens.Count = 0) or (CTokens.Count = 0) then Exit;

    SeqQ := '';
    for i := 0 to QTokens.Count - 1 do
    begin
      SeqTok := NormalizeSequelToken(QTokens[i]);
      if SeqTok <> '' then
      begin
        if SeqQ <> '' then SeqQ := SeqQ + ',';
        SeqQ := SeqQ + SeqTok;
      end;
    end;

    SeqC := '';
    for i := 0 to CTokens.Count - 1 do
    begin
      SeqTok := NormalizeSequelToken(CTokens[i]);
      if SeqTok <> '' then
      begin
        if SeqC <> '' then SeqC := SeqC + ',';
        SeqC := SeqC + SeqTok;
      end;
    end;

    if SeqQ <> SeqC then
      Exit(-1000);

    MatchedQ := 0;
    for i := 0 to QTokens.Count - 1 do
      if CTokens.IndexOf(QTokens[i]) >= 0 then
        Inc(MatchedQ);

    if MatchedQ < QTokens.Count then
      Exit(-1000);

    ExtraC := CTokens.Count - MatchedQ;
    if ExtraC < 0 then ExtraC := 0;

    Result := 800 - (ExtraC * 40);
    if Pos(NormQ + ' ', NormC + ' ') = 1 then
      Inc(Result, 100);

    for i := Low(PENALTY_MARKERS) to High(PENALTY_MARKERS) do
      if HasTokenPhrase(NormC, PENALTY_MARKERS[i]) and
         (not HasTokenPhrase(NormQ, PENALTY_MARKERS[i])) then
        Dec(Result, 400);
  finally
    CTokens.Free;
    QTokens.Free;
  end;
end;

end.
