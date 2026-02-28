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
// Strategy: native binary first, then Flatpak version as fallback.
// In Flatpak mode, uses flatpak-spawn --host to reach the host system.
procedure Tprotontricksform.SetupProtontricksProcess(AProcess: TProcess);
begin
  if not IsRunningInFlatpak then
  begin
    // Native mode: just use protontricks directly
    AProcess.Executable := 'protontricks';
  end
  else
  begin
    // Flatpak mode: try native protontricks on host first,
    // fallback to Flatpak version of protontricks
    AProcess.Executable := 'flatpak-spawn';
    AProcess.Parameters.Add('--host');

    if IsCommandAvailable('protontricks') then
      AProcess.Parameters.Add('protontricks')
    else
    begin
      // Fallback: invoke the Flatpak version of protontricks
      AProcess.Parameters.Add('flatpak');
      AProcess.Parameters.Add('run');
      AProcess.Parameters.Add('--command=protontricks');
      AProcess.Parameters.Add('com.github.Matoking.protontricks');
    end;
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
  ConfigPath1, ConfigPath2, Line, Path: String;
  F: TextFile;
  p1, p2: Integer;
begin
  Result := TStringList.Create;
  ConfigPath1 := GetEnvironmentVariable('HOME') + '/.steam/root/steamapps/libraryfolders.vdf';
  ConfigPath2 := GetEnvironmentVariable('HOME') + '/.local/share/Steam/steamapps/libraryfolders.vdf';
  
  if FileExists(ConfigPath1) then
  begin
    AssignFile(F, ConfigPath1);
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
            Result.Add(Copy(Line, p1 + 1, p2 - p1 - 1) + '/steamapps');
        end;
      end;
    end;
    CloseFile(F);
  end;

  if FileExists(ConfigPath2) then
  begin
    AssignFile(F, ConfigPath2);
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
  OutputLines: TStringList;
  Line, GameName, AppIDStr: String;
  i, p1, p2: Integer;
  ListItem: TListItem;
begin
  gamesListView.Items.Clear;
  AProcess := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    SetupProtontricksProcess(AProcess);
    AProcess.Parameters.Add('-l');
    AProcess.Options := [poWaitOnExit, poUsePipes];
    try
      AProcess.Execute;
      OutputLines.LoadFromStream(AProcess.Output);
    except
      ShowMessage('Error executing protontricks. Is it installed?');
      Exit;
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
            ListItem := gamesListView.Items.Add;
            ListItem.Caption := GameName;
            ListItem.SubItems.Add(AppIDStr);
            ListItem.SubItems.Add(GetPrefixWindowsVersion(AppIDStr));
          end;
        end;
      end;
    end;
  finally
    AProcess.Free;
    OutputLines.Free;
  end;
end;

end.
