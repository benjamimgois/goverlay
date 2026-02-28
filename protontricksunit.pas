unit protontricksunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Process, themeunit, constants, strutils, systemdetector, LCLType;

type

  { Tprotontricksform }

  Tprotontricksform = class(TForm)
    applyButton: TButton;
    closeButton: TButton;
    winVerComboBox: TComboBox;
    gamesListView: TListView;
    applyProgressBar: TProgressBar;
    statusLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure closeButtonClick(Sender: TObject);
    procedure applyButtonClick(Sender: TObject);
    procedure gamesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    procedure LoadGames;
    function GetPrefixWindowsVersion(AppID: String): String;
    function FindSteamappsPaths: TStringList;
    procedure SetupProtontricksProcess(AProcess: TProcess);
  public

  end;

var
  protontricksform: Tprotontricksform;

implementation

{$R *.lfm}

{ Tprotontricksform }

// Helper procedure to configure TProcess for protontricks execution.
// Strategy: native binary first; in Flatpak mode use flatpak-spawn --host.
// In Flatpak mode, uses flatpak-spawn --host to reach the host system.
procedure Tprotontricksform.SetupProtontricksProcess(AProcess: TProcess);
var
  HomeDir: String;
begin
  if not IsRunningInFlatpak then
  begin
    // Native mode: just use protontricks directly
    AProcess.Executable := 'protontricks';
  end
  else
  begin
    // Flatpak mode: use flatpak-spawn --host to break out of the sandbox.
    //
    // We do NOT try to auto-detect protontricks location because it is often
    // installed in ~/.local/bin/ (pip) which is not visible via /run/host/*.
    // We always call flatpak-spawn --host protontricks and let the host's
    // PATH resolve it.
    //
    // IMPORTANT: reset XDG env vars that Flatpak overrides so protontricks
    // finds Steam at ~/.local/share/Steam instead of the sandbox path.
    HomeDir := GetEnvironmentVariable('HOME');

    AProcess.Executable := 'flatpak-spawn';
    AProcess.Parameters.Add('--host');

    // Restore XDG base directories to standard host values
    AProcess.Parameters.Add('--env=XDG_DATA_HOME=' + HomeDir + '/.local/share');
    AProcess.Parameters.Add('--env=XDG_CONFIG_HOME=' + HomeDir + '/.config');
    AProcess.Parameters.Add('--env=XDG_CACHE_HOME=' + HomeDir + '/.cache');

    // Always call protontricks directly — let host PATH find it
    AProcess.Parameters.Add('protontricks');
  end;
end;


procedure Tprotontricksform.FormCreate(Sender: TObject);
begin
  ApplyTheme(Self, CurrentTheme);
  LoadGames;
end;

procedure Tprotontricksform.closeButtonClick(Sender: TObject);
begin
  Close;
end;

procedure Tprotontricksform.applyButtonClick(Sender: TObject);
var
  AppID, WinVer: String;
  AProcess: TProcess;
  ExitCode: Integer;
begin
  if gamesListView.Selected = nil then exit;
  if winVerComboBox.ItemIndex = -1 then exit;

  AppID := gamesListView.Selected.SubItems[0];
  WinVer := winVerComboBox.Text;

  // Show progress UI
  applyButton.Enabled := False;
  closeButton.Enabled := False;
  winVerComboBox.Enabled := False;
  gamesListView.Enabled := False;
  statusLabel.Caption := 'Applying Windows version ' + WinVer + ' to ' +
    gamesListView.Selected.Caption + '...';
  applyProgressBar.Visible := True;
  Application.ProcessMessages;

  ExitCode := 0;
  try
    AProcess := TProcess.Create(nil);
    try
      SetupProtontricksProcess(AProcess);
      AProcess.Parameters.Add(AppID);
      AProcess.Parameters.Add(WinVer);
      // Run without blocking: poNoConsole allows polling Process.Running
      AProcess.Options := [poUsePipes, poNoConsole];
      AProcess.Execute;

      // Poll until done, keeping the UI alive
      while AProcess.Running do
      begin
        Application.ProcessMessages;
        Sleep(100);
      end;

      ExitCode := AProcess.ExitCode;
    finally
      AProcess.Free;
    end;
  finally
    // Hide progress UI
    applyProgressBar.Visible := False;
    applyButton.Enabled := True;
    closeButton.Enabled := True;
    winVerComboBox.Enabled := True;
    gamesListView.Enabled := True;
  end;

  if ExitCode = 0 then
  begin
    statusLabel.Caption := '✓ Applied ' + WinVer + ' successfully!';
    LoadGames;
  end
  else
  begin
    statusLabel.Caption := '✗ protontricks exited with code ' + IntToStr(ExitCode) + '.';
    ShowMessage('Error: protontricks exited with code ' + IntToStr(ExitCode) +
      '. Make sure protontricks is installed.');
  end;
end;

procedure Tprotontricksform.gamesListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  VerIndex: Integer;
begin
  if Selected then
  begin
    VerIndex := winVerComboBox.Items.IndexOf(Item.SubItems[1]);
    if VerIndex >= 0 then
      winVerComboBox.ItemIndex := VerIndex;
  end;
end;

function Tprotontricksform.FindSteamappsPaths: TStringList;
var
  ConfigPath1, ConfigPath2, ConfigPath3, Line, Path: String;
  F: TextFile;
  p1, p2: Integer;

  procedure ParseLibraryFolders(const ConfigPath: String);
  begin
    if not FileExists(ConfigPath) then Exit;
    AssignFile(F, ConfigPath);
    Reset(F);
    while not EOF(F) do
    begin
      ReadLn(F, Line);
      if Pos('"path"', Line) > 0 then
      begin
        p1 := PosEx('"', Line, Pos('"path"', Line) + 6);
        if p1 > 0 then
        begin
          p2 := PosEx('"', Line, p1 + 1);
          if p2 > p1 then
          begin
            Path := Copy(Line, p1 + 1, p2 - p1 - 1) + '/steamapps';
            if Result.IndexOf(Path) = -1 then
              Result.Add(Path);
          end;
        end;
      end;
    end;
    CloseFile(F);
  end;

var
  HomeDir: String;
begin
  Result := TStringList.Create;
  HomeDir := GetEnvironmentVariable('HOME');

  // Native Steam paths
  ConfigPath1 := HomeDir + '/.steam/root/steamapps/libraryfolders.vdf';
  ConfigPath2 := HomeDir + '/.local/share/Steam/steamapps/libraryfolders.vdf';
  // Flatpak Steam path (com.valvesoftware.Steam)
  ConfigPath3 := HomeDir + '/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf';

  ParseLibraryFolders(ConfigPath1);
  ParseLibraryFolders(ConfigPath2);
  ParseLibraryFolders(ConfigPath3);
end;

function Tprotontricksform.GetPrefixWindowsVersion(AppID: String): String;
var
  SteamPaths: TStringList;
  RegPath, Line, VerStr, BuildStr: String;
  i, p1: Integer;
  F: TextFile;
  FoundSection: Boolean;
begin
  Result := 'unknown';
  SteamPaths := FindSteamappsPaths;
  try
    RegPath := '';
    for i := 0 to SteamPaths.Count - 1 do
    begin
      if FileExists(SteamPaths[i] + '/compatdata/' + AppID + '/pfx/system.reg') then
      begin
        RegPath := SteamPaths[i] + '/compatdata/' + AppID + '/pfx/system.reg';
        Break;
      end;
    end;

    if RegPath <> '' then
    begin
      AssignFile(F, RegPath);
      Reset(F);
      FoundSection := False;
      while not EOF(F) do
      begin
        ReadLn(F, Line);
        if Pos('[Software\\Microsoft\\Windows NT\\CurrentVersion]', Line) > 0 then
        begin
          FoundSection := True;
        end
        else if FoundSection and (Pos('[', Line) = 1) then
        begin
          Break; // next section
        end
        else if FoundSection and (Pos('"CurrentVersion"=', Line) = 1) then
        begin
          p1 := Pos('=', Line);
          VerStr := Copy(Line, p1 + 1, Length(Line) - p1);
          VerStr := StringReplace(VerStr, '"', '', [rfReplaceAll]);
          VerStr := Trim(VerStr);
        end
        else if FoundSection and (Pos('"CurrentBuildNumber"=', Line) = 1) then
        begin
          p1 := Pos('=', Line);
          BuildStr := Copy(Line, p1 + 1, Length(Line) - p1);
          BuildStr := StringReplace(BuildStr, '"', '', [rfReplaceAll]);
          BuildStr := Trim(BuildStr);
        end
        else if FoundSection and (Trim(Line) = '') then
        begin
          // End of section, calculate version
          if (VerStr = '6.3') and (StrToIntDef(BuildStr, 0) >= 22000) then Result := 'win11'
          else if (VerStr = '6.3') and (StrToIntDef(BuildStr, 0) >= 10240) then Result := 'win10'
          else if (VerStr = '10.0') then Result := 'win10'
          else if VerStr = '6.3' then Result := 'win81'
          else if VerStr = '6.2' then Result := 'win8'
          else if VerStr = '6.1' then Result := 'win7'
          else if VerStr = '6.0' then Result := 'winvista'
          else if VerStr = '5.1' then Result := 'winxp'
          else if VerStr <> '' then Result := VerStr;
          Break;
        end;
      end;
      CloseFile(F);
    end;
  finally
    SteamPaths.Free;
  end;
end;

procedure Tprotontricksform.LoadGames;
var
  AProcess: TProcess;
  OutputLines, SteamPaths, DbgPaths: TStringList;
  Line, GameName, AppIDStr, RegPath, WinVer: String;
  i, j, k, p1, p2: Integer;
  ListItem: TListItem;
  HasUnknown: Boolean;
  // Debug
  LogFile: TextFile;
  LogPath: String;
  GamesFound: Integer;
begin
  gamesListView.Items.Clear;

  // Write to the Flatpak app data dir - always writable by the sandbox
  LogPath := '/home/benjamim/.var/app/io.github.benjamimgois.goverlay/data/goverlay/logs/protontricks_debug.log';
  ForceDirectories(ExtractFilePath(LogPath));
  AssignFile(LogFile, LogPath);
  Rewrite(LogFile);

  WriteLn(LogFile, '=== GOverlay Protontricks Debug ===');
  WriteLn(LogFile, 'Time: ' + DateTimeToStr(Now));
  WriteLn(LogFile, '--- Environment ---');
  WriteLn(LogFile, 'FLATPAK_ID    = ' + GetEnvironmentVariable('FLATPAK_ID'));
  WriteLn(LogFile, 'HOME          = ' + GetEnvironmentVariable('HOME'));
  WriteLn(LogFile, 'XDG_DATA_HOME = ' + GetEnvironmentVariable('XDG_DATA_HOME'));
  WriteLn(LogFile, 'XDG_CONFIG_HOME = ' + GetEnvironmentVariable('XDG_CONFIG_HOME'));
  WriteLn(LogFile, 'STEAM_DIR     = ' + GetEnvironmentVariable('STEAM_DIR'));
  WriteLn(LogFile, 'IsRunningInFlatpak = ' + BoolToStr(IsRunningInFlatpak, True));

  AProcess := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    SetupProtontricksProcess(AProcess);
    AProcess.Parameters.Add('-l');
    AProcess.Options := [poWaitOnExit, poUsePipes, poStderrToOutPut];

    WriteLn(LogFile, '--- Command ---');
    WriteLn(LogFile, 'Executable: ' + AProcess.Executable);
    WriteLn(LogFile, 'Parameters:');
    for i := 0 to AProcess.Parameters.Count - 1 do
      WriteLn(LogFile, '  [' + IntToStr(i) + '] ' + AProcess.Parameters[i]);

    try
      AProcess.Execute;
      OutputLines.LoadFromStream(AProcess.Output);
    except
      on E: Exception do
      begin
        WriteLn(LogFile, '--- EXCEPTION ---');
        WriteLn(LogFile, E.ClassName + ': ' + E.Message);
        CloseFile(LogFile);
        ShowMessage('Error executing protontricks: ' + E.Message + sLineBreak +
                    'See ' + LogPath + ' for details.');
        Exit;
      end;
    end;

    WriteLn(LogFile, '--- Output (exit code: ' + IntToStr(AProcess.ExitCode) + ') ---');
    WriteLn(LogFile, 'Total lines: ' + IntToStr(OutputLines.Count));
    for i := 0 to OutputLines.Count - 1 do
      WriteLn(LogFile, OutputLines[i]);

    GamesFound := 0;

    // Debug: log what Steam paths FindSteamappsPaths finds
    WriteLn(LogFile, '--- Steam library paths ---');
    SteamPaths := FindSteamappsPaths;
    try
      WriteLn(LogFile, 'Paths found: ' + IntToStr(SteamPaths.Count));
      for i := 0 to SteamPaths.Count - 1 do
        WriteLn(LogFile, '  ' + SteamPaths[i] + '  [exists=' + BoolToStr(DirectoryExists(SteamPaths[i]), True) + ']');
    finally
      SteamPaths.Free;
    end;

    for i := 0 to OutputLines.Count - 1 do
    begin
      Line := OutputLines[i];
      if (Pos('(', Line) > 0) and (Pos(')', Line) > Pos('(', Line)) then
      begin
        if Pos('(WARNING)', Line) > 0 then continue;

        p2 := LastDelimiter(')', Line);
        p1 := LastDelimiter('(', Line);
        if p1 < p2 then
        begin
          AppIDStr := Copy(Line, p1 + 1, p2 - p1 - 1);
          GameName := Trim(Copy(Line, 1, p1 - 1));

          if StrToIntDef(AppIDStr, -1) <> -1 then
          begin
            // Debug: log system.reg lookup for first game only
            if GamesFound = 0 then
            begin
              WriteLn(LogFile, '--- system.reg lookup for first game: ' + GameName + ' (' + AppIDStr + ') ---');
              DbgPaths := FindSteamappsPaths;
              try
                for j := 0 to DbgPaths.Count - 1 do
                begin
                  RegPath := DbgPaths[j] + '/compatdata/' + AppIDStr + '/pfx/system.reg';
                  WriteLn(LogFile, '  Checking: ' + RegPath);
                  WriteLn(LogFile, '  Exists: ' + BoolToStr(FileExists(RegPath), True));
                end;
              finally
                DbgPaths.Free;
              end;
            end;

            WinVer := GetPrefixWindowsVersion(AppIDStr);
            WriteLn(LogFile, '  Version result for ' + AppIDStr + ': ' + WinVer);

            ListItem := gamesListView.Items.Add;
            ListItem.Caption := GameName;
            ListItem.SubItems.Add(AppIDStr);
            ListItem.SubItems.Add(WinVer);
            Inc(GamesFound);
          end;
        end;
      end;
    end;

    WriteLn(LogFile, '--- Result ---');
    WriteLn(LogFile, 'Games added to list: ' + IntToStr(GamesFound));

  finally
    CloseFile(LogFile);
    AProcess.Free;
    OutputLines.Free;
  end;

  // Show Flatseal hint if running in Flatpak and some versions are unknown
  // (user may have Steam libraries on external drives not accessible to the sandbox)
  if IsRunningInFlatpak and (GamesFound > 0) then
  begin
    HasUnknown := False;
    for k := 0 to gamesListView.Items.Count - 1 do
      if gamesListView.Items[k].SubItems[1] = 'unknown' then
      begin
        HasUnknown := True;
        Break;
      end;
    if HasUnknown then
      statusLabel.Caption := '⚠ Games on external drives show "unknown". Use Flatseal → Filesystem to grant read access to your Steam library path.';
  end;
end;

end.
