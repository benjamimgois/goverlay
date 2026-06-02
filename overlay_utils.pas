unit overlay_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Graphics, Types, FileUtil, StrUtils, process,
  constants, configmanager, systemdetector, apputils;

var
  FONTS: TStringList;                   // Available system fonts cache

function GetUserConfigDir(): String;
function GetMangoHudConfigDir(): String;
function GetVkBasaltConfigDir(): String;
function GetVkSumiConfigDir(): String;
function GetGOverlayConfigDir(): String;
function GetGOverlayDataDir(): String;
function GetEnvironmentDConfigDir(): String;

function IsMangoHudGloballyEnabled(): Boolean;
procedure EnableMangoHudGlobally();
procedure DisableMangoHudGlobally();

function LoadFont(const Parametro: string; out Valor: TStringList): Boolean;
function GetStandardFontDirectories: TStringList;
procedure ListarFontesNoDiretorio(ComboBox: TComboBox);
procedure ListFontDirectories(out Dirs: TStringList);

procedure GetNetworkInterfaces(ComboBox: TComboBox);

implementation

function GetUserConfigDir(): String;
var
  UserConfig: String;
begin
  UserConfig := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if not DirectoryExists(UserConfig) then
  begin
    UserConfig := GetUserDir + '.config';
  end;
  Result := UserConfig;
end;

function GetMangoHudConfigDir(): String;
var
  ConfigHome: String;
begin
  if IsRunningInFlatpak then
  begin
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
    if ConfigHome = '' then
      ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'MangoHud';
end;

function GetVkBasaltConfigDir(): String;
var
  ConfigHome: String;
begin
  if IsRunningInFlatpak then
  begin
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'vkBasalt';
end;

// Function to get vkSumi config directory with proper XDG support
function GetVkSumiConfigDir(): String;
var
  ConfigHome: String;
begin
  if IsRunningInFlatpak then
  begin
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'vkSumi';
end;

function GetGOverlayConfigDir(): String;
var
  ConfigHome: String;
begin
  ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  if ConfigHome = '' then
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigHome = '' then
    ConfigHome := GetUserDir + '.config';
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'goverlay';
end;

function GetGOverlayDataDir(): String;
var
  DataHome: String;
  UserName: String;
begin
  DataHome := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
  if (DataHome = '') and IsRunningInFlatpak then
  begin
    UserName := GetEnvironmentVariable('USER');
    if UserName <> '' then
      DataHome := '/home/' + UserName + '/.local/share'
    else
      DataHome := GetUserDir + '.local/share';
  end;
  if DataHome = '' then
    DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay';
end;

function GetEnvironmentDConfigDir(): String;
var
  ConfigHome: String;
begin
  ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  if ConfigHome = '' then
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigHome = '' then
    ConfigHome := GetUserDir + '.config';
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'environment.d';
end;

function IsMangoHudGloballyEnabled(): Boolean;
var
  ConfigFile: String;
  FileContent: TStringList;
  i: Integer;
begin
  Result := False;
  ConfigFile := IncludeTrailingPathDelimiter(GetEnvironmentDConfigDir()) + 'mangohud.conf';
  if not FileExists(ConfigFile) then
    Exit;
  FileContent := TStringList.Create;
  try
    try
      FileContent.LoadFromFile(ConfigFile);
      for i := 0 to FileContent.Count - 1 do
      begin
        if Trim(FileContent[i]) = 'MANGOHUD=1' then
        begin
          Result := True;
          Break;
        end;
      end;
    except
      Result := False;
    end;
  finally
    FileContent.Free;
  end;
end;

procedure EnableMangoHudGlobally();
var
  ConfigDir, ConfigFile: String;
  FileContent: TStringList;
begin
  ConfigDir := GetEnvironmentDConfigDir();
  ConfigFile := IncludeTrailingPathDelimiter(ConfigDir) + 'mangohud.conf';
  if not DirectoryExists(ConfigDir) then
    ForceDirectories(ConfigDir);
  FileContent := TStringList.Create;
  try
    FileContent.Add('MANGOHUD=1');
    FileContent.SaveToFile(ConfigFile);
  finally
    FileContent.Free;
  end;
end;

procedure DisableMangoHudGlobally();
var
  ConfigFile: String;
begin
  ConfigFile := IncludeTrailingPathDelimiter(GetEnvironmentDConfigDir()) + 'mangohud.conf';
  if FileExists(ConfigFile) then
    DeleteFile(ConfigFile);
end;

function LoadFont(const Parametro: string; out Valor: TStringList): Boolean;
const
  BUF_SIZE = 2048;
var
  Process: TProcess;
  Output: TStream;
  BytesRead: longint;
  Buffer: array[1..BUF_SIZE] of byte;
  TempList: TStringList;
begin
  if Assigned(Valor) then
    FreeAndNil(Valor);

  Process := TProcess.Create(nil);
  Output := TMemoryStream.Create;
  Valor := TStringList.Create;
  Valor.Sorted := True;
  Valor.Duplicates := dupIgnore;

  Process.Executable := FindDefaultExecutablePath('sh');
  Process.Parameters.Add('-c');
  Process.Parameters.Add('fc-list -f "%{file}\n" :lang=en:fontformat=TrueType');
  Process.Options := [poUsePipes];
  Process.Execute;

  repeat
    BytesRead := Process.Output.Read(Buffer, BUF_SIZE);
    Output.Write(Buffer, BytesRead);
  until BytesRead = 0;

  Process.Free;

  TempList := TStringList.Create;
  try
    Output.Position := 0;
    TempList.LoadFromStream(Output);
    Valor.Text := StringReplace(TempList.Text, '\n', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  finally
    TempList.Free;
  end;

  Output.Free;
  Result := Valor.Text <> '';
end;

function GetStandardFontDirectories: TStringList;
var
  Dir: String;
  i: Integer;
begin
  Result := TStringList.Create;
  Result.Duplicates := dupIgnore;
  Result.Sorted := True;

  Result.Add('/usr/share/fonts');
  Result.Add('/usr/local/share/fonts');
  Result.Add(GetUserConfigDir + '/../.local/share/fonts');
  Result.Add(GetUserConfigDir + '/../.fonts');
  Result.Add('/run/current-system/sw/share/fonts');
  Result.Add(GetEnvironmentVariable('HOME') + '/.nix-profile/share/fonts');
  Result.Add('/var/lib/flatpak/exports/share/fonts');
  Result.Add(GetUserConfigDir + '/../.local/share/flatpak/exports/share/fonts');

  for i := Result.Count - 1 downto 0 do
  begin
    if not DirectoryExists(Result[i]) then
      Result.Delete(i);
  end;
end;

procedure ListarFontesNoDiretorio(ComboBox: TComboBox);
var
  Arquivos, AllFonts, FontDirs: TStringList;
  Arquivo, FontDir: String;
begin
  AllFonts := TStringList.Create;
  AllFonts.Duplicates := dupIgnore;
  AllFonts.Sorted := True;

  if LoadFont('fonts', FONTS) then
  begin
    for Arquivo in FONTS do
      AllFonts.Add(Arquivo);
  end
  else
  begin
    FontDirs := GetStandardFontDirectories;
    try
      for FontDir in FontDirs do
      begin
        if DirectoryExists(FontDir) then
        begin
          Arquivos := FindAllFiles(FontDir, '*.ttf', True);
          try
            for Arquivo in Arquivos do
              AllFonts.Add(Arquivo);
          finally
            Arquivos.Free;
          end;
        end;
      end;
    finally
      FontDirs.Free;
    end;
  end;

  try
    for Arquivo in AllFonts do
    begin
      ComboBox.Items.Add(ExtractFileName(Arquivo));
    end;
  finally
    AllFonts.Free;
  end;
end;

procedure ListFontDirectories(out Dirs: TStringList);
var
  FontDirs: TStringList;
  Arquivo, FontDir: String;
begin
  if LoadFont('fonts', FONTS) then
  begin
    for Arquivo in FONTS do
    begin
      Dirs.Add(ExtractFileDir(Arquivo));
    end;
  end
  else
  begin
    FontDirs := GetStandardFontDirectories;
    try
      for FontDir in FontDirs do
      begin
        if DirectoryExists(FontDir) then
          Dirs.Add(FontDir);
      end;
    finally
      FontDirs.Free;
    end;
  end;
end;

procedure GetNetworkInterfaces(ComboBox: TComboBox);
var
  Interfaces: TStringList;
  i: Integer;
begin
  ComboBox.Items.Clear;
  Interfaces := systemdetector.GetNetworkInterfaces;
  try
    for i := 0 to Interfaces.Count - 1 do
      ComboBox.Items.Add(Interfaces[i]);
  finally
    Interfaces.Free;
  end;
end;

initialization
  FONTS := nil;

finalization
  if Assigned(FONTS) then
    FreeAndNil(FONTS);

end.
