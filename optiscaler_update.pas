unit optiscaler_update;

interface

uses
  Classes, SysUtils, Forms, ComCtrls, Buttons, Process,
  RegExpr, fpjson, jsonparser, zipper, Dialogs, StdCtrls, Graphics, DateUtils,
  constants, notificationunit;

// Function to get the correct OptiScaler installation path (Flatpak-aware)
function GetOptiScalerInstallPath: string;

type
  TDownloadProgressProc = procedure(APercent: Integer; const AStatus: string) of object;

// Check and automatically install OptiScaler if not present
// Returns True if OptiScaler is installed (or was successfully installed)
function CheckAndInstallOptiScaler(const AFGModPath: string; AIsStable: Boolean = True; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Check and automatically install DLSS Enabler if not present
function CheckAndInstallDlssEnabler(AIsStable: Boolean = True; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Check and automatically install Streamline SDK if not present
function CheckAndInstallStreamlineSDK(AIsStable: Boolean = True; AForce: Boolean = False): Boolean;

type
  TOptiscalerTab = class
  private
    FUpdateBtn: TBitBtn;
    FCheckupdBtn: TBitBtn;
    FProgressBar: TProgressBar;
    FStatusLabel: TLabel;
    FDeckyLabel: TLabel;
    FOptiLabel: TLabel;
    FOptiLabel2: TLabel;       // Label for OptiScaler update notification
    FFakeNvapiLabel: TLabel;
    FXessLabel: TLabel;
    FFsrLabel: TLabel;
    FDeckyLabel2: TLabel;      // Label for update notification
    FFakeNvapiLabel2: TLabel;  // Label for update notification
    FNotificationLabel: TLabel; // Label for general notifications
    FFsrVersionComboBox: TComboBox; // ComboBox for FSR version selection
    FOptVersionComboBox: TComboBox; // ComboBox for OptiScaler channel selection
    FOptiPatcherLabel: TLabel; // Label for OptiPatcher version
    FDlssLabel: TLabel;        // Label for DLSS download date
    FDlssEnablerLabel: TLabel; // Label for DLSS Enabler version
    FFGModPath: string;
    FUpdateThread: TThread;
    FOptiPatcherCheckThread: TThread;
    FLastOptiPatcherCheckTime: TDateTime;

    function FetchManifest(ASilent: Boolean; out AStableVer, AStableURL, AEdgeVer, AEdgeURL: string): Boolean;
    function GetLatestReleaseTag(ASilent: Boolean = False): string;
    function GetOptiScalerStableTag(ASilent: Boolean = False): string;
    function GetOptiScalerPreReleaseTag(ASilent: Boolean = False): string;
    function GetDlssEnablerLatestTag(AIsStable: Boolean = True; ASilent: Boolean = False): string;
    function FormatDlssEnablerDisplayTag(const ATag: string): string;
    function DownloadFile(const AURL, ADestFile: string): Boolean;
    function ExtractZip(const AZipFile, ADestPath: string): Boolean;
    function Extract7z(const A7zFile, ADestPath: string): Boolean;
    procedure CopyDirectory(const ASource, ADest: string);
    procedure UpdateProgress(AProgress: Integer);
    procedure UpdateStatus(const AStatus: string);
    function ExtractOptiScalerVersion(const AFileName: string): string;
    function FetchFakeNvapiLatest(out ATag, AURL: string): Boolean;
    function FetchVarsTxt(out AFsrStable, AFsrEdge, AXessStable, AXessEdge: string): Boolean;
    function ReadCachedOptiScalerVersion: string;
    procedure CheckForUpdates;
    procedure SyncPristineAssetsTo(const ASourceDir, ATargetDir: string);
    function GetBGModOriginalPathForChannel(IsStable: Boolean): string;

  public
    FOptiStableVersion: string;
    FOptiStableURL: string;
    FOptiEdgeVersion: string;
    FOptiEdgeURL: string;

    procedure LoadVersionsFromFile;
    procedure UpdateButtonClick(Sender: TObject);
    procedure InitializeTab;
    procedure CheckForUpdatesOnClick;
    procedure CheckAndUpdateOptiPatcherAsync;
    procedure OptiPatcherThreadTerminated(Sender: TObject);
    property FGModPath: string read FFGModPath write FFGModPath;
    property UpdateBtn: TBitBtn read FUpdateBtn write FUpdateBtn;
    property CheckupdBtn: TBitBtn read FCheckupdBtn write FCheckupdBtn;
    property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
    property StatusLabel: TLabel read FStatusLabel write FStatusLabel;
    property DeckyLabel: TLabel read FDeckyLabel write FDeckyLabel;
    property OptiLabel: TLabel read FOptiLabel write FOptiLabel;
    property OptiLabel2: TLabel read FOptiLabel2 write FOptiLabel2;
    property FakeNvapiLabel: TLabel read FFakeNvapiLabel write FFakeNvapiLabel;
    property XessLabel: TLabel read FXessLabel write FXessLabel;
    property FsrLabel: TLabel read FFsrLabel write FFsrLabel;
    property DeckyLabel2: TLabel read FDeckyLabel2 write FDeckyLabel2;
    property FakeNvapiLabel2: TLabel read FFakeNvapiLabel2 write FFakeNvapiLabel2;
    property NotificationLabel: TLabel read FNotificationLabel write FNotificationLabel;
    property FsrVersionComboBox: TComboBox read FFsrVersionComboBox write FFsrVersionComboBox;
    property OptVersionComboBox: TComboBox read FOptVersionComboBox write FOptVersionComboBox;
    property OptiPatcherLabel: TLabel read FOptiPatcherLabel write FOptiPatcherLabel;
    property DlssLabel: TLabel read FDlssLabel write FDlssLabel;
    property DlssEnablerLabel: TLabel read FDlssEnablerLabel write FDlssEnablerLabel;
  end;

  TOptiUpdateThread = class(TThread)
  private
    FOptiTab: TOptiscalerTab;
    FIsStableChannel: Boolean;
    FLatestDeckyVersion: string;
    FCheckDecky: Boolean;
    FSpawnedFGModPath: string;
  public
    FLatestOptiTag: string;
    procedure SyncUpdateUI;
    constructor Create(AOptiTab: TOptiscalerTab; AIsStable: Boolean; ACheckDecky: Boolean);
  protected
    procedure Execute; override;
  end;

implementation

uses
  FileUtil, LazFileUtils, BaseUnix, bgmod_resources, systemdetector, overlayunit, overlay_config, apputils, overlay_utils, IniFiles, StrUtils, configfile;

type
  TOptiPatcherCheckThread = class(TThread)
  private
    FOptiTab: TOptiscalerTab;
    FNewVersion: string;
    FUpdated: Boolean;
    procedure SyncUpdateUI;
  protected
    procedure Execute; override;
  public
    constructor Create(AOptiTab: TOptiscalerTab);
  end;

{ TOptiUpdateThread }

constructor TOptiUpdateThread.Create(AOptiTab: TOptiscalerTab; AIsStable: Boolean; ACheckDecky: Boolean);
begin
  inherited Create(True);
  FOptiTab := AOptiTab;
  FIsStableChannel := AIsStable;
  FCheckDecky := ACheckDecky;
  FLatestOptiTag := '';
  FLatestDeckyVersion := '';
  // Snapshot the path the thread was spawned against so SyncUpdateUI can
  // discard stale results when the active game (and thus FGModPath) has
  // changed between spawn and UI sync.
  FSpawnedFGModPath := AOptiTab.FFGModPath;
  FreeOnTerminate := True;
end;

procedure TOptiUpdateThread.Execute;
var
  IsDlssEnablerActive: Boolean;
begin
  WriteLn('[DEBUG] TOptiUpdateThread.Execute: Thread started');
  IsDlssEnablerActive := Assigned(goverlayform) and Assigned(goverlayform.dlssenablerRadioButton) and goverlayform.dlssenablerRadioButton.Checked;

  if IsDlssEnablerActive then
  begin
    WriteLn('[DEBUG] TOptiUpdateThread.Execute: Checking DLSS Enabler channel (OptiScaler-builds)...');
    FLatestOptiTag := FOptiTab.GetDlssEnablerLatestTag(FIsStableChannel, True);
  end
  else if FIsStableChannel then
  begin
    WriteLn('[DEBUG] TOptiUpdateThread.Execute: Checking Stable channel...');
    FLatestOptiTag := FOptiTab.GetOptiScalerStableTag(True);
  end
  else
  begin
    WriteLn('[DEBUG] TOptiUpdateThread.Execute: Checking Bleeding-Edge channel...');
    FLatestOptiTag := FOptiTab.GetOptiScalerPreReleaseTag(True);
  end;

  // Fetch Decky version if requested
  if FCheckDecky then
  begin
    WriteLn('[DEBUG] TOptiUpdateThread.Execute: Checking Decky version...');
    FLatestDeckyVersion := FOptiTab.GetLatestReleaseTag(True);
  end;

  WriteLn('[DEBUG] TOptiUpdateThread.Execute: Thread work completed. OptiTag = ', FLatestOptiTag, ', DeckyTag = ', FLatestDeckyVersion);

  if not Terminated then
  begin
    WriteLn('[DEBUG] TOptiUpdateThread.Execute: Synchronizing UI...');
    Synchronize(@SyncUpdateUI);
  end;
end;

procedure TOptiUpdateThread.SyncUpdateUI;
var
  HasUpdates, HasUpdate: Boolean;
  CurrentVersion: string;
  NormLatest, NormCurrent: string;
  CurrentIsEdge, IsCrossChannel, IsDlssEnablerActive: Boolean;
  VarsFilePath: string;
  VarsList: TStringList;
begin
  if Terminated then Exit;

  IsDlssEnablerActive := Assigned(goverlayform) and Assigned(goverlayform.dlssenablerRadioButton) and goverlayform.dlssenablerRadioButton.Checked;

  // Skip if channel changed since thread was spawned (only for standard OptiScaler)
  if not IsDlssEnablerActive and Assigned(FOptiTab.FOptVersionComboBox) then
  begin
    if (FIsStableChannel and (FOptiTab.FOptVersionComboBox.ItemIndex <> 0))
       or (not FIsStableChannel and (FOptiTab.FOptVersionComboBox.ItemIndex <> 1)) then
    begin
      WriteLn('[DEBUG] SyncUpdateUI: Channel changed since spawn, discarding results (spawned=', FIsStableChannel, ' current=', FOptiTab.FOptVersionComboBox.ItemIndex, ')');
      FOptiTab.FUpdateThread := nil;
      Exit;
    end;
  end;

  // Skip if the active game (FGModPath) changed since thread was spawned:
  // otherwise we would compare remote tags against the wrong game's vars.
  if FSpawnedFGModPath <> FOptiTab.FFGModPath then
  begin
    WriteLn('[DEBUG] SyncUpdateUI: FGModPath changed since spawn (spawned=', FSpawnedFGModPath, ' current=', FOptiTab.FFGModPath, '), discarding results');
    FOptiTab.FUpdateThread := nil;
    Exit;
  end;

  HasUpdates := False;

  // 1. Process Updates (OptiScaler or DLSS Enabler)
  if Assigned(FOptiTab.FOptiLabel2) then
  begin
    if IsDlssEnablerActive then
    begin
      CurrentVersion := '';
      VarsFilePath := IncludeTrailingPathDelimiter(GetDlssEnablerPath(FIsStableChannel)) + 'goverlay.vars';
      if FileExists(VarsFilePath) then
      begin
        VarsList := TStringList.Create;
        try
          VarsList.LoadFromFile(VarsFilePath);
          CurrentVersion := VarsList.Values['dlssenablertag'];
          if CurrentVersion = '' then
            CurrentVersion := VarsList.Values['optiScalerVersion'];
          if CurrentVersion = '' then
            CurrentVersion := VarsList.Values['OptiScalerVersion'];
          if CurrentVersion = '' then
            CurrentVersion := VarsList.Values['dlssenablerversion'];
          if CurrentVersion = '' then
            CurrentVersion := VarsList.Values['dlssenabler'];
        finally
          VarsList.Free;
        end;
      end;
      if (CurrentVersion = '') and Assigned(FOptiTab.FDlssEnablerLabel) then
        CurrentVersion := FOptiTab.FDlssEnablerLabel.Caption;

      HasUpdate := (FLatestOptiTag <> '') and (CurrentVersion <> '') and (CurrentVersion <> '—') and
                   (not SameText(CurrentVersion, FLatestOptiTag)) and
                   (Pos(CurrentVersion, FLatestOptiTag) <> 1) and
                   (Pos(FLatestOptiTag, CurrentVersion) <> 1);

      if HasUpdate then
      begin
        FOptiTab.FOptiLabel2.Caption := 'Update Available ' + FOptiTab.FormatDlssEnablerDisplayTag(FLatestOptiTag);
        FOptiTab.FOptiLabel2.Font.Color := clLime;
        FOptiTab.FOptiLabel2.Visible := True;
        if Assigned(FOptiTab.FUpdateBtn) then
          FOptiTab.FUpdateBtn.Visible := True;
        if Assigned(FOptiTab.FCheckupdBtn) then
          FOptiTab.FCheckupdBtn.Visible := False;
        HasUpdates := True;
      end
      else
        FOptiTab.FOptiLabel2.Visible := False;
    end
    else
    begin
      if Assigned(FOptiTab.FOptiLabel) then
        CurrentVersion := FOptiTab.FOptiLabel.Caption
      else
        CurrentVersion := '';

      if (FLatestOptiTag <> '') and (CurrentVersion <> '') then
      begin
        NormLatest := StringReplace(FLatestOptiTag, '-', '.', [rfReplaceAll]);
        NormCurrent := StringReplace(CurrentVersion, '-', '.', [rfReplaceAll]);
        if (Length(NormLatest) > 5) and (Copy(NormLatest, 1, 5) = 'edge.') then
          NormLatest := Copy(NormLatest, 6, MaxInt);
        if (Length(NormCurrent) > 5) and (Copy(NormCurrent, 1, 5) = 'edge.') then
          NormCurrent := Copy(NormCurrent, 6, MaxInt);
        if (Length(NormLatest) > 7) and (Copy(NormLatest, 1, 7) = 'stable.') then
          NormLatest := Copy(NormLatest, 8, MaxInt);
        if (Length(NormCurrent) > 7) and (Copy(NormCurrent, 1, 7) = 'stable.') then
          NormCurrent := Copy(NormCurrent, 8, MaxInt);

        CurrentIsEdge := (Length(CurrentVersion) > 5) and (Copy(CurrentVersion, 1, 5) = 'edge-');
        if FIsStableChannel then
          IsCrossChannel := CurrentIsEdge
        else
          IsCrossChannel := not CurrentIsEdge;

        if IsCrossChannel or (CompareVersions(NormLatest, NormCurrent) > 0) then
        begin
          FOptiTab.FOptiLabel2.Caption := 'Update Available ' + FLatestOptiTag;
          FOptiTab.FOptiLabel2.Font.Color := clLime;
          FOptiTab.FOptiLabel2.Visible := True;
          HasUpdates := True;
        end
        else
          FOptiTab.FOptiLabel2.Visible := False;
      end
      else
        FOptiTab.FOptiLabel2.Visible := False;
    end;
  end;

  // 2. Process Decky Updates
  if FCheckDecky and (FLatestDeckyVersion <> '') then
  begin
    if Assigned(FOptiTab.FDeckyLabel) and (FOptiTab.FDeckyLabel.Caption <> '') and (FOptiTab.FDeckyLabel.Caption <> '—') then
    begin
      if (FLatestDeckyVersion <> FOptiTab.FDeckyLabel.Caption) then
      begin
        if Assigned(FOptiTab.FDeckyLabel2) then
        begin
          FOptiTab.FDeckyLabel2.Caption := ' Update available ' + '(' + FLatestDeckyVersion + ')';
          FOptiTab.FDeckyLabel2.Visible := True;
          FOptiTab.FDeckyLabel2.Font.Color := clLime;
          HasUpdates := True;
          WriteLn('[DEBUG] TOptiUpdateThread.SyncUpdateUI: Decky update available: ', FLatestDeckyVersion);
        end;
      end
      else
      begin
        if Assigned(FOptiTab.FDeckyLabel2) then
          FOptiTab.FDeckyLabel2.Visible := False;
        WriteLn('[DEBUG] TOptiUpdateThread.SyncUpdateUI: Decky is up to date');
      end;
    end;
  end
  else
  begin
    if Assigned(FOptiTab.FDeckyLabel2) then
      FOptiTab.FDeckyLabel2.Visible := False;
  end;

  // 3. Update update button & check button visibility
  if HasUpdates then
  begin
    if Assigned(FOptiTab.FCheckupdBtn) then
      FOptiTab.FCheckupdBtn.Visible := False;
    if Assigned(FOptiTab.FUpdateBtn) then
    begin
      FOptiTab.FUpdateBtn.Caption := 'Update';
      FOptiTab.FUpdateBtn.Visible := True;
    end;
  end
  else
  begin
    if Assigned(FOptiTab.FCheckupdBtn) then
    begin
      FOptiTab.FCheckupdBtn.Visible := True;
      FOptiTab.FCheckupdBtn.Enabled := True;
    end;
    if Assigned(FOptiTab.FUpdateBtn) then
      FOptiTab.FUpdateBtn.Visible := False;
  end;

  // 4. Clean up thread pointer
  FOptiTab.FUpdateThread := nil;

  // 5. Refresh UI layout helpers in overlayunit
  if Assigned(goverlayform) then
  begin
    goverlayform.RefreshHomeOptiStatus;
    goverlayform.RefreshOsStatusDots;
  end;
  WriteLn('[DEBUG] TOptiUpdateThread.SyncUpdateUI: UI synchronization finished');
end;

{ TOptiPatcherCheckThread }

constructor TOptiPatcherCheckThread.Create(AOptiTab: TOptiscalerTab);
begin
  inherited Create(True);
  FOptiTab := AOptiTab;
  FNewVersion := '';
  FUpdated := False;
  FreeOnTerminate := True;
end;

procedure TOptiPatcherCheckThread.Execute;
var
  Process: TProcess;
  Response: string;
  KeyPos, ColonPos, QuoteStart, QuoteEnd: Integer;
  DateVal, RemoteDateStr, RemoteVerStr, LocalVerStr: string;
  VarsFilePath: string;
  VarsList: TStringList;
  TmpAsiFile, TargetAsiFile, OrigPluginsDir, EdgePluginsDir, ActivePluginsDir: string;
  PluginsDir: string;
  PathsToUpdate: TStringList;
  i, LineIdx: Integer;
begin
  try
    WriteLn('[OPTIPATCHER-AUTO] Checking latest rolling release from optiscaler/OptiPatcher...');

    Process := TProcess.Create(nil);
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: goverlay');
      Process.Parameters.Add('https://api.github.com/repos/optiscaler/OptiPatcher/releases/latest');
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      SetLength(Response, Process.Output.NumBytesAvailable);
      if Length(Response) > 0 then
        Process.Output.Read(Response[1], Length(Response));
    finally
      Process.Free;
    end;

    if Response = '' then Exit;

    RemoteDateStr := '';
    // Extract updated_at date string from release asset JSON
    // e.g. "updated_at":"2026-08-03T10:24:50Z"
    KeyPos := Pos('"updated_at"', Response);
    if KeyPos > 0 then
    begin
      ColonPos := PosEx(':', Response, KeyPos + 12);
      if ColonPos > 0 then
      begin
        QuoteStart := PosEx('"', Response, ColonPos);
        if QuoteStart > 0 then
        begin
          QuoteEnd := PosEx('"', Response, QuoteStart + 1);
          if (QuoteEnd > QuoteStart) then
          begin
            DateVal := Copy(Response, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
            if Length(DateVal) >= 10 then
            begin
              DateVal := Copy(DateVal, 1, 10);
              RemoteDateStr := StringReplace(DateVal, '-', '.', [rfReplaceAll]);
            end;
          end;
        end;
      end;
    end;

    if (RemoteDateStr = '') or (Length(RemoteDateStr) <> 10) or (Pos(',', RemoteDateStr) > 0) then
    begin
      WriteLn('[OPTIPATCHER-AUTO] Could not parse valid release date from GitHub response (got: ', RemoteDateStr, ').');
      Exit;
    end;

    RemoteVerStr := 'rolling-' + RemoteDateStr;

    // Read local version from goverlay.vars
    LocalVerStr := '';
    if Assigned(FOptiTab) and (FOptiTab.FFGModPath <> '') and FileExists(IncludeTrailingPathDelimiter(FOptiTab.FFGModPath) + 'goverlay.vars') then
      VarsFilePath := IncludeTrailingPathDelimiter(FOptiTab.FFGModPath) + 'goverlay.vars'
    else if FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars') then
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'
    else if FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars') then
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars'
    else
      VarsFilePath := '';

    if (VarsFilePath <> '') and FileExists(VarsFilePath) then
    begin
      VarsList := TStringList.Create;
      try
        VarsList.LoadFromFile(VarsFilePath);
        LocalVerStr := VarsList.Values['optipatcher'];
      finally
        VarsList.Free;
      end;
    end;

    TargetAsiFile := GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins' + PathDelim + 'OptiPatcher.asi';

    // If local version matches remote AND target file exists AND local version is valid
    if (LocalVerStr = RemoteVerStr) and FileExists(TargetAsiFile) and (Pos(',', LocalVerStr) = 0) then
    begin
      WriteLn('[OPTIPATCHER-AUTO] OptiPatcher is up to date (', LocalVerStr, ')');
      Exit;
    end;

    WriteLn('[OPTIPATCHER-AUTO] New OptiPatcher build detected (Local: ', LocalVerStr, ', Remote: ', RemoteVerStr, '). Downloading...');

    PluginsDir := GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins';
    ForceDirectories(PluginsDir);
    TmpAsiFile := PluginsDir + PathDelim + 'OptiPatcher.asi.tmp';

    Process := TProcess.Create(nil);
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('-o');
      Process.Parameters.Add(TmpAsiFile);
      Process.Parameters.Add('-A');
      Process.Parameters.Add('Goverlay/1.9 (Linux)');
      Process.Parameters.Add('https://github.com/optiscaler/OptiPatcher/releases/download/rolling/OptiPatcher.asi');
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;

    if not FileExists(TmpAsiFile) or (FileSize(TmpAsiFile) < 1000) then
    begin
      WriteLn('[OPTIPATCHER-AUTO] Download failed or invalid file size.');
      if FileExists(TmpAsiFile) then DeleteFile(TmpAsiFile);
      Exit;
    end;

    // Overwrite main target file
    CopyFile(TmpAsiFile, TargetAsiFile);
    DeleteFile(TmpAsiFile);

    // Sync to stable cache plugins/
    OrigPluginsDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'plugins';
    ForceDirectories(OrigPluginsDir);
    CopyFile(TargetAsiFile, OrigPluginsDir + PathDelim + 'OptiPatcher.asi');

    // Sync to edge cache plugins/
    EdgePluginsDir := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'plugins';
    ForceDirectories(EdgePluginsDir);
    CopyFile(TargetAsiFile, EdgePluginsDir + PathDelim + 'OptiPatcher.asi');

    // Sync to active game profile bgmod/plugins/
    if Assigned(FOptiTab) and (FOptiTab.FFGModPath <> '') and DirectoryExists(FOptiTab.FFGModPath) then
    begin
      ActivePluginsDir := IncludeTrailingPathDelimiter(FOptiTab.FFGModPath) + 'plugins';
      ForceDirectories(ActivePluginsDir);
      CopyFile(TargetAsiFile, ActivePluginsDir + PathDelim + 'OptiPatcher.asi');
    end;

    // Update goverlay.vars in all locations
    PathsToUpdate := TStringList.Create;
    try
      PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars');
      PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars');
      if Assigned(FOptiTab) and (FOptiTab.FFGModPath <> '') then
        PathsToUpdate.Add(IncludeTrailingPathDelimiter(FOptiTab.FFGModPath) + 'goverlay.vars');
      PathsToUpdate.Add(GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod' + PathDelim + 'goverlay.vars');

      for i := 0 to PathsToUpdate.Count - 1 do
      begin
        VarsFilePath := PathsToUpdate[i];
        if FileExists(VarsFilePath) then
        begin
          VarsList := TStringList.Create;
          try
            VarsList.LoadFromFile(VarsFilePath);
            LineIdx := VarsList.IndexOfName('optipatcher');
            if LineIdx >= 0 then
              VarsList[LineIdx] := 'optipatcher=' + RemoteVerStr
            else
              VarsList.Add('optipatcher=' + RemoteVerStr);
            VarsList.SaveToFile(VarsFilePath);
          finally
            VarsList.Free;
          end;
        end;
      end;
    finally
      PathsToUpdate.Free;
    end;

    FNewVersion := RemoteVerStr;
    FUpdated := True;
    Synchronize(@SyncUpdateUI);

  except
    on E: Exception do
      WriteLn('[OPTIPATCHER-AUTO] Exception in update thread: ', E.Message);
  end;
end;

procedure TOptiPatcherCheckThread.SyncUpdateUI;
begin
  if FUpdated and (FNewVersion <> '') and Assigned(FOptiTab) then
  begin
    if Assigned(FOptiTab.OptiPatcherLabel) then
    begin
      FOptiTab.OptiPatcherLabel.Caption := FNewVersion;
      FOptiTab.OptiPatcherLabel.Font.Color := clGreen;
    end;

    if Assigned(goverlayform) then
    begin
      goverlayform.RefreshHomeOptiStatus;
      goverlayform.RefreshOsStatusDots;
    end;

    ShowToast(ntSuccess, 'OptiPatcher auto-updated to ' + FNewVersion + '!', 4000);
  end;
end;

procedure TOptiscalerTab.CheckAndUpdateOptiPatcherAsync;
begin
  // Debounce checks: max 1 check per 60 seconds
  if (Now - FLastOptiPatcherCheckTime) < (1.0 / 1440.0) then Exit;

  if Assigned(FOptiPatcherCheckThread) then Exit;

  FLastOptiPatcherCheckTime := Now;
  FOptiPatcherCheckThread := TOptiPatcherCheckThread.Create(Self);
  FOptiPatcherCheckThread.OnTerminate := @OptiPatcherThreadTerminated;
  FOptiPatcherCheckThread.Start;
end;

procedure TOptiscalerTab.OptiPatcherThreadTerminated(Sender: TObject);
begin
  FOptiPatcherCheckThread := nil;
end;

// Function to get the correct OptiScaler installation path with XDG compliance
// Returns: ~/.local/share/goverlay/bgmod (Sandboxed in Flatpak)
function GetOptiScalerInstallPath: string;
begin
  // Use the central function from bgmod_resources to ensure consistency
  Result := GetBGModPath;
end;

{ TOptiscalerTab }

procedure TOptiscalerTab.UpdateProgress(AProgress: Integer);
begin
  if Assigned(FProgressBar) then
  begin
    FProgressBar.Position := AProgress;
    Application.ProcessMessages;
  end;

  // Show percentage on button (but don't change if resetting to 0)
  if Assigned(FUpdateBtn) and (AProgress > 0) then
  begin
    FUpdateBtn.Caption := IntToStr(AProgress) + '%';
    Application.ProcessMessages;
  end;
end;

procedure TOptiscalerTab.UpdateStatus(const AStatus: string);
begin
  if Assigned(FStatusLabel) then
  begin
    FStatusLabel.Caption := AStatus;
    Application.ProcessMessages;
  end;
end;

function TOptiscalerTab.ExtractOptiScalerVersion(const AFileName: string): string;
var
  BaseName: string;
  RegEx: TRegExpr;
begin
  Result := '';

  WriteLn('[DEBUG] ExtractOptiScalerVersion: Input filename = ', AFileName);

  // Get filename without path and extension
  BaseName := ChangeFileExt(ExtractFileName(AFileName), '');
  WriteLn('[DEBUG] ExtractOptiScalerVersion: Base name (no ext) = ', BaseName);

  // Use regex to extract version pattern (numbers separated by dots)
  // Pattern: OptiScaler_X.X.X or similar
  RegEx := TRegExpr.Create;
  try
    // Match pattern like: 0.7.9 or 1.2.3.4
    RegEx.Expression := '(\d+\.\d+\.\d+(?:\.\d+)?)';

    WriteLn('[DEBUG] ExtractOptiScalerVersion: Attempting regex match with pattern: ', RegEx.Expression);
    if RegEx.Exec(BaseName) then
    begin
      WriteLn('[DEBUG] ExtractOptiScalerVersion: Regex matched, MatchCount = ', RegEx.SubExprMatchCount);
      if RegEx.SubExprMatchCount >= 1 then
      begin
        Result := RegEx.Match[1];
        WriteLn('[DEBUG] ExtractOptiScalerVersion: Extracted version = "', Result, '"');
      end
      else
        WriteLn('[ERROR] ExtractOptiScalerVersion: Match found but SubExprMatchCount < 1');
    end
    else
      WriteLn('[WARN] ExtractOptiScalerVersion: No regex match found in basename');
  finally
    RegEx.Free;
  end;
end;

function TOptiscalerTab.GetLatestReleaseTag(ASilent: Boolean = False): string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONObject: TJSONObject;
begin
  Result := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      WriteLn('[DEBUG] GetLatestReleaseTag: Fetching from ', URL_DECKY_FRAMEGEN_API);

      // Use curl to get GitHub API
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add(URL_DECKY_FRAMEGEN_API);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      WriteLn('[DEBUG] GetLatestReleaseTag: Curl exit status: ', Process.ExitStatus);
      WriteLn('[DEBUG] GetLatestReleaseTag: Response length: ', Length(Response), ' bytes');

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        WriteLn('[DEBUG] GetLatestReleaseTag: Parsing JSON response...');

        // Validate response is JSON before parsing (to handle GitHub API errors/rate limiting)
        if (Length(Response) > 0) and ((Response[1] = '{') or (Response[1] = '[')) then
        begin
          JSONData := GetJSON(Response);
          try
            if Assigned(JSONData) and (JSONData is TJSONObject) then
            begin
            WriteLn('[DEBUG] GetLatestReleaseTag: Valid JSON object received');
            JSONObject := TJSONObject(JSONData);
            Result := JSONObject.Get('tag_name', '');
            WriteLn('[DEBUG] GetLatestReleaseTag: tag_name = "', Result, '"');
          end
          else
            WriteLn('[ERROR] GetLatestReleaseTag: JSON data is not a valid object');
        finally
          JSONData.Free;
        end;
        end
        else
        begin
          WriteLn('[ERROR] GetLatestReleaseTag: API returned non-JSON response (possibly rate limited or error)');
          WriteLn('[ERROR] GetLatestReleaseTag: Response preview: ', Copy(Response, 1, 200));
        end;
      end
      else
      begin
        WriteLn('[ERROR] GetLatestReleaseTag: Failed to get response (exit: ', Process.ExitStatus, ', response empty: ', Response = '', ')');
        if Response <> '' then
          WriteLn('[ERROR] GetLatestReleaseTag: Response content: ', Copy(Response, 1, 200));
      end;



    except
      on E: Exception do
      begin
        WriteLn('[ERROR] GetLatestReleaseTag: Exception - ', E.ClassName, ': ', E.Message);
        if not ASilent then
          ShowMessage('Error getting latest release: ' + E.Message + sLineBreak +
                     'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.FetchManifest(ASilent: Boolean; out AStableVer, AStableURL, AEdgeVer, AEdgeURL: string): Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONObject, StableObj, EdgeObj: TJSONObject;
begin
  Result := False;
  AStableVer := '';
  AStableURL := '';
  AEdgeVer := '';
  AEdgeURL := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      WriteLn('[DEBUG] FetchManifest: Fetching from ', URL_OPTISCALER_MANIFEST);
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');
      Process.Parameters.Add('-L');
      Process.Parameters.Add(URL_OPTISCALER_MANIFEST);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;
      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        if (Length(Response) > 0) and (Response[1] = '{') then
        begin
          JSONData := GetJSON(Response);
          try
            if Assigned(JSONData) and (JSONData is TJSONObject) then
            begin
              JSONObject := TJSONObject(JSONData);
              StableObj := TJSONObject(JSONObject.Find('stable'));
              if Assigned(StableObj) then
              begin
                AStableVer := StableObj.Get('version', '');
                AStableURL := StableObj.Get('url', '');
              end;
              EdgeObj := TJSONObject(JSONObject.Find('edge'));
              if Assigned(EdgeObj) then
              begin
                AEdgeVer := EdgeObj.Get('version', '');
                AEdgeURL := EdgeObj.Get('url', '');
              end;
              Result := (AStableVer <> '') and (AEdgeVer <> '');
            end;
          finally
            JSONData.Free;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        WriteLn('[ERROR] FetchManifest: Exception - ', E.ClassName, ': ', E.Message);
        if not ASilent then
          ShowMessage('Error getting OptiScaler manifest: ' + E.Message);
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.GetOptiScalerStableTag(ASilent: Boolean = False): string;
var
  StableVer, StableURL, EdgeVer, EdgeURL: string;
begin
  Result := '';
  if FetchManifest(ASilent, StableVer, StableURL, EdgeVer, EdgeURL) then
  begin
    FOptiStableVersion := StableVer;
    FOptiStableURL := StableURL;
    FOptiEdgeVersion := EdgeVer;
    FOptiEdgeURL := EdgeURL;
    Result := StableVer;
  end;
end;

function TOptiscalerTab.GetOptiScalerPreReleaseTag(ASilent: Boolean = False): string;
var
  StableVer, StableURL, EdgeVer, EdgeURL: string;
begin
  Result := '';
  if FetchManifest(ASilent, StableVer, StableURL, EdgeVer, EdgeURL) then
  begin
    FOptiStableVersion := StableVer;
    FOptiStableURL := StableURL;
    FOptiEdgeVersion := EdgeVer;
    FOptiEdgeURL := EdgeURL;
    Result := EdgeVer;
  end;
end;

function TOptiscalerTab.GetDlssEnablerLatestTag(AIsStable: Boolean = True; ASilent: Boolean = False): string;
var
  Process: TProcess;
  Response, ItemName, TargetKeyword: string;
  StartPos, EndPos, NamePos, SpacePos: Integer;
begin
  Result := '';
  if AIsStable then
    TargetKeyword := 'STABLE'
  else
    TargetKeyword := 'TRUNK';

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action');
    Process.Options := [poWaitOnExit, poUsePipes];
    Process.Execute;
    SetLength(Response, Process.Output.NumBytesAvailable);
    if Length(Response) > 0 then
      Process.Output.Read(Response[1], Length(Response));

    StartPos := 1;
    while True do
    begin
      NamePos := PosEx('"name"', Response, StartPos);
      if NamePos = 0 then Break;
      StartPos := NamePos + 6;
      StartPos := PosEx('"', Response, StartPos);
      if StartPos = 0 then Break;
      Inc(StartPos);
      EndPos := PosEx('"', Response, StartPos);
      if EndPos = 0 then Break;
      ItemName := Copy(Response, StartPos, EndPos - StartPos);
      StartPos := EndPos + 1;

      if (Pos(TargetKeyword, ItemName) > 0) and (Pos('DLSS Enabler ', ItemName) > 0) then
      begin
        NamePos := Pos('DLSS Enabler ', ItemName) + Length('DLSS Enabler ');
        SpacePos := PosEx(' ', ItemName, NamePos);
        if SpacePos > NamePos then
          Result := Copy(ItemName, NamePos, SpacePos - NamePos);
        Break;
      end;
    end;
  finally
    Process.Free;
  end;
end;

function TOptiscalerTab.FormatDlssEnablerDisplayTag(const ATag: string): string;
var
  Parts: TStringArray;
begin
  Result := ATag;
  if Result = '' then Exit;

  if Copy(Result, 1, 11) = 'OptiScaler_' then
    Result := Copy(Result, 12, MaxInt);

  Parts := Result.Split(['_']);
  if Length(Parts) >= 2 then
    Result := Parts[0] + '_' + Parts[1]
  else if Length(Parts) = 1 then
    Result := Parts[0];
end;

function TOptiscalerTab.DownloadFile(const AURL, ADestFile: string): Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
begin
  Result := False;
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      WriteLn('[DEBUG] DownloadFile: Starting download');
      WriteLn('[DEBUG] DownloadFile: URL = ', AURL);
      WriteLn('[DEBUG] DownloadFile: Destination = ', ADestFile);

      UpdateStatus('Downloading file...');

      // Use curl to download file with progress
      Process.Executable := 'curl';
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-#');  // Show progress bar
      Process.Parameters.Add('-o');
      Process.Parameters.Add(ADestFile);
      Process.Parameters.Add('-A');  // User agent
      Process.Parameters.Add('Goverlay/1.6 (Linux; Flatpak-compatible)');
      Process.Parameters.Add(AURL);
      // Don't use poWaitOnExit - we'll wait manually while processing UI events
      Process.Options := [poUsePipes];

      WriteLn('[DEBUG] DownloadFile: Executing curl...');
      Process.Execute;

      // Wait for download to complete while keeping UI responsive
      while Process.Running do
      begin
        Application.ProcessMessages;  // Keep UI responsive
        Sleep(100);  // Small delay to avoid excessive CPU usage
      end;

      WriteLn('[DEBUG] DownloadFile: Curl finished with exit status: ', Process.ExitStatus);

      // Read any output (curl progress goes to stderr)
      if Process.Stderr.NumBytesAvailable > 0 then
        OutputList.LoadFromStream(Process.Stderr);

      // Check if download succeeded
      if (Process.ExitStatus = 0) and FileExists(ADestFile) then
      begin
        WriteLn('[DEBUG] DownloadFile: Download successful, file exists at: ', ADestFile);
        Result := True;
        UpdateProgress(50);  // Mark download complete at 50%
      end
      else
      begin
        if Process.ExitStatus <> 0 then
        begin
          WriteLn('[ERROR] DownloadFile: Curl failed with exit code: ', Process.ExitStatus);
          ShowMessage('Error downloading file: curl exited with code ' + IntToStr(Process.ExitStatus) + sLineBreak +
                     'URL: ' + AURL + sLineBreak +
                     'Check your internet connection and if curl is installed.');
        end
        else if not FileExists(ADestFile) then
        begin
          WriteLn('[ERROR] DownloadFile: File does not exist after download: ', ADestFile);
          ShowMessage('Error: Downloaded file does not exist.' + sLineBreak +
                     'URL: ' + AURL);
        end;
      end;

    except
      on E: Exception do
      begin
        WriteLn('[ERROR] DownloadFile: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Error downloading file: ' + E.Message + sLineBreak +
                   'URL: ' + AURL + sLineBreak +
                   'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.ExtractZip(const AZipFile, ADestPath: string): Boolean;
var
  UnZipper: TUnZipper;
begin
  Result := False;
  UnZipper := TUnZipper.Create;
  try
    try
      UnZipper.FileName := AZipFile;
      UnZipper.OutputPath := ADestPath;
      UnZipper.Examine;
      UnZipper.UnZipAllFiles;
      Result := True;
    except
      on E: Exception do
        ShowMessage('Error extracting ZIP: ' + E.Message);
    end;
  finally
    UnZipper.Free;
  end;
end;

function TOptiscalerTab.Extract7z(const A7zFile, ADestPath: string): Boolean;
var
  Process: TProcess;
  OutputLines: TStringList;
  StdoutOutput, StderrOutput: string;
  FileInfo: TSearchRec;
  FullCommand: string;
begin
  Result := False;
  Process := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    try
      WriteLn('[DEBUG] Extract7z: Starting 7z extraction');
      WriteLn('[DEBUG] Extract7z: Source file = ', A7zFile);
      WriteLn('[DEBUG] Extract7z: Destination path = ', ADestPath);
      WriteLn('[DEBUG] Extract7z: File exists = ', FileExists(A7zFile));

      // Check file size if exists
      if FileExists(A7zFile) then
      begin
        if FindFirst(A7zFile, faAnyFile, FileInfo) = 0 then
        begin
          WriteLn('[DEBUG] Extract7z: File size = ', FileInfo.Size, ' bytes');
          FindClose(FileInfo);
        end;
      end
      else
      begin
        WriteLn('[ERROR] Extract7z: Source file does not exist!');
        ShowMessage('Error: 7z file not found at: ' + A7zFile);
        Exit;
      end;

      WriteLn('[DEBUG] Extract7z: Destination directory exists = ', DirectoryExists(ADestPath));

      Process.Executable := FindDefaultExecutablePath('7z');
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');  // Yes to all questions
      Process.Parameters.Add('-o' + ADestPath);
      
      // Exclude bgmod / fgmod files if they already exist (to preserve user's configuration)
      if FileExists(IncludeTrailingPathDelimiter(ADestPath) + 'bgmod') then
      begin
        Process.Parameters.Add('-xr!bgmod');
        WriteLn('[DEBUG] Extract7z: Excluding bgmod from extraction (file already exists)');
      end;
      if FileExists(IncludeTrailingPathDelimiter(ADestPath) + 'bgmod.conf') then
      begin
        Process.Parameters.Add('-xr!bgmod.conf');
        WriteLn('[DEBUG] Extract7z: Excluding bgmod.conf from extraction (file already exists)');
      end;
      if FileExists(IncludeTrailingPathDelimiter(ADestPath) + 'fgmod') then
      begin
        Process.Parameters.Add('-xr!fgmod');
        WriteLn('[DEBUG] Extract7z: Excluding fgmod from extraction (file already exists)');
      end;
      if FileExists(IncludeTrailingPathDelimiter(ADestPath) + 'fgmod.sh') then
      begin
        Process.Parameters.Add('-xr!fgmod.sh');
        WriteLn('[DEBUG] Extract7z: Excluding fgmod.sh from extraction (file already exists)');
      end;
      
      Process.Parameters.Add(A7zFile);
      Process.Options := [poWaitOnExit, poUsePipes];

      // Build full command string for debugging
      FullCommand := '7z x -y -o' + ADestPath + ' ' + A7zFile;
      WriteLn('[DEBUG] Extract7z: Full command = ', FullCommand);
      WriteLn('[DEBUG] Extract7z: Executing...');

      Process.Execute;

      WriteLn('[DEBUG] Extract7z: Process completed');
      WriteLn('[DEBUG] Extract7z: Exit status = ', Process.ExitStatus);

      // Capture stdout output
      if Process.Output.NumBytesAvailable > 0 then
      begin
        OutputLines.LoadFromStream(Process.Output);
        StdoutOutput := OutputLines.Text;
        WriteLn('[DEBUG] Extract7z: stdout output:');
        WriteLn(StdoutOutput);
      end
      else
        WriteLn('[DEBUG] Extract7z: No stdout output');

      // Capture stderr output
      if Process.Stderr.NumBytesAvailable > 0 then
      begin
        OutputLines.Clear;
        OutputLines.LoadFromStream(Process.Stderr);
        StderrOutput := OutputLines.Text;
        WriteLn('[ERROR] Extract7z: stderr output:');
        WriteLn(StderrOutput);
      end
      else
        WriteLn('[DEBUG] Extract7z: No stderr output');

      Result := Process.ExitStatus = 0;

      if not Result then
      begin
        WriteLn('[ERROR] Extract7z: Extraction failed with exit code ', Process.ExitStatus);
        WriteLn('[ERROR] Extract7z: 7z exit code 2 typically means: fatal error, file not found, or invalid archive');
        ShowMessage('Error extracting 7z file. Exit code: ' + IntToStr(Process.ExitStatus) +
                   sLineBreak + sLineBreak +
                   'Check terminal output for details.' + sLineBreak +
                   'File: ' + A7zFile);
      end
      else
        WriteLn('[DEBUG] Extract7z: Extraction completed successfully');
    except
      on E: Exception do
      begin
        WriteLn('[ERROR] Extract7z: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Error executing 7z: ' + E.Message);
      end;
    end;
  finally
    OutputLines.Free;
    Process.Free;
  end;
end;

procedure TOptiscalerTab.CopyDirectory(const ASource, ADest: string);
var
  SearchRec: TSearchRec;
  SourcePath, DestPath: string;
  SourceFile, DestFile: string;
begin
  if not DirectoryExists(ADest) then
    ForceDirectories(ADest);

  SourcePath := IncludeTrailingPathDelimiter(ASource);
  DestPath := IncludeTrailingPathDelimiter(ADest);

  if FindFirst(SourcePath + '*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          if (SearchRec.Attr and faDirectory) = faDirectory then
          begin
            // Recursive directory copy
            CopyDirectory(SourcePath + SearchRec.Name, DestPath + SearchRec.Name);
          end
          else
          begin
            // File copy with permission preservation for .sh files
            SourceFile := SourcePath + SearchRec.Name;
            DestFile := DestPath + SearchRec.Name;

            // Copy file
            if not CopyFile(SourceFile, DestFile) then
              ShowMessage('Error copying file: ' + SearchRec.Name);

            // If it's a .sh file, make it executable
            if LowerCase(ExtractFileExt(SearchRec.Name)) = '.sh' then
            begin
              fpChmod(DestFile, &755);  // rwxr-xr-x
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

function TOptiscalerTab.FetchFakeNvapiLatest(out ATag, AURL: string): Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONObject, AssetObj: TJSONObject;
  AssetsArray: TJSONArray;
  i: Integer;
begin
  Result := False;
  ATag := '';
  AURL := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      WriteLn('[DEBUG] FetchFakeNvapiLatest: Fetching from ', URL_FAKENVAPI_API);
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');
      Process.Parameters.Add('-L');
      Process.Parameters.Add('-A');
      Process.Parameters.Add('Goverlay/1.6 (Linux; Flatpak-compatible)');
      Process.Parameters.Add(URL_FAKENVAPI_API);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;
      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        if (Length(Response) > 0) and (Response[1] = '{') then
        begin
          JSONData := GetJSON(Response);
          try
            if Assigned(JSONData) and (JSONData is TJSONObject) then
            begin
              JSONObject := TJSONObject(JSONData);
              ATag := JSONObject.Get('tag_name', '');
              AssetsArray := TJSONArray(JSONObject.Find('assets'));
              if Assigned(AssetsArray) then
              begin
                for i := 0 to AssetsArray.Count - 1 do
                begin
                  AssetObj := TJSONObject(AssetsArray.Items[i]);
                  if Assigned(AssetObj) and SameText(ExtractFileExt(AssetObj.Get('name', '')), '.7z') then
                  begin
                    AURL := AssetObj.Get('browser_download_url', '');
                    Break;
                  end;
                end;
              end;
              Result := (ATag <> '') and (AURL <> '');
            end;
          finally
            JSONData.Free;
          end;
        end;
      end;
    except
      on E: Exception do
        WriteLn('[ERROR] FetchFakeNvapiLatest: Exception - ', E.ClassName, ': ', E.Message);
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.FetchVarsTxt(out AFsrStable, AFsrEdge, AXessStable, AXessEdge: string): Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  i: Integer;
  Line: string;
  SepPos: Integer;
  Key, Value: string;
begin
  Result := False;
  AFsrStable := '';
  AFsrEdge := '';
  AXessStable := '';
  AXessEdge := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');
      Process.Parameters.Add('-L');
      Process.Parameters.Add('-A');
      Process.Parameters.Add('Goverlay/1.6 (Linux; Flatpak-compatible)');
      Process.Parameters.Add('https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/vars.txt');
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;
      OutputList.LoadFromStream(Process.Output);
      if Process.ExitStatus = 0 then
      begin
        for i := 0 to OutputList.Count - 1 do
        begin
          Line := Trim(OutputList[i]);
          SepPos := Pos('=', Line);
          if SepPos > 0 then
          begin
            Key := Trim(Copy(Line, 1, SepPos - 1));
            Value := Trim(Copy(Line, SepPos + 1, Length(Line)));
            if SameText(Key, 'fsrstable') then
              AFsrStable := Value
            else if SameText(Key, 'fsredge') then
              AFsrEdge := Value
            else if SameText(Key, 'xessstable') then
              AXessStable := Value
            else if SameText(Key, 'xessedge') then
              AXessEdge := Value;
          end;
        end;
        Result := True;
      end;
    except
      on E: Exception do
        WriteLn('[ERROR] FetchVarsTxt: Exception - ', E.ClassName, ': ', E.Message);
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.ReadCachedOptiScalerVersion: string;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line, Key, Value: string;
  SepPos: Integer;
  IsStable: Boolean;
begin
  Result := '';
  IsStable := True;
  if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 1) then
    IsStable := False;
  VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPathForChannel(IsStable)) + 'goverlay.vars';
  if not FileExists(VarsFilePath) then Exit;
  try
    AssignFile(VarsFile, VarsFilePath);
    Reset(VarsFile);
    try
      while not Eof(VarsFile) do
      begin
        ReadLn(VarsFile, Line);
        if (Length(Line) > 0) and (Line[1] = '#') then Continue;
        SepPos := Pos('=', Line);
        if SepPos > 0 then
        begin
          Key := Copy(Line, 1, SepPos - 1);
          Value := Copy(Line, SepPos + 1, Length(Line));
          if SameText(Key, 'OptiScalerVersion') then
          begin
            Result := Trim(Value);
            Exit;
          end;
        end;
      end;
    finally
      CloseFile(VarsFile);
    end;
  except
    on E: Exception do
      WriteLn('[WARN] ReadCachedOptiScalerVersion: ', E.Message);
  end;
end;

procedure TOptiscalerTab.SyncPristineAssetsTo(const ASourceDir, ATargetDir: string);
var
  Source, Target: string;
  SyncProc: TProcess;
begin
  // Force-copy OptiScaler runtime assets from the pristine cache folder to
  // ATargetDir. Only DLLs, plugins/, FSR4_LATEST/, FSR4_INT8/, and fakenvapi.ini
  // are touched — user-editable files (bgmod.conf, OptiScaler.ini, MangoHud.conf,
  // etc.) are never overwritten by this routine, preserving per-game isolation.
  Source := IncludeTrailingPathDelimiter(ASourceDir);
  Target := IncludeTrailingPathDelimiter(ATargetDir);
  ForceDirectories(Target);
  SyncProc := TProcess.Create(nil);
  try
    SyncProc.Executable := 'sh';
    SyncProc.Parameters.Add('-c');
    SyncProc.Parameters.Add(
      'for f in ' + QuotedStr(Source) + '*.dll; do ' +
      '  [ -f "$f" ] && cp -f "$f" ' + QuotedStr(Target) + '; ' +
      'done; ' +
      'if [ -f ' + QuotedStr(Source + 'fakenvapi.ini') + ' ] && [ ! -f ' + QuotedStr(Target + 'fakenvapi.ini') + ' ]; then ' +
      '  cp ' + QuotedStr(Source + 'fakenvapi.ini') + ' ' + QuotedStr(Target) + '; ' +
      'fi; ' +
      'if [ -d ' + QuotedStr(Source + 'plugins') + ' ]; then ' +
      '  cp -rf ' + QuotedStr(Source + 'plugins') + ' ' + QuotedStr(Target) + '; ' +
      'fi; ' +
      'if [ -d ' + QuotedStr(Source + 'FSR4_LATEST') + ' ]; then ' +
      '  cp -rf ' + QuotedStr(Source + 'FSR4_LATEST') + ' ' + QuotedStr(Target) + '; ' +
      'fi; ' +
      'if [ -d ' + QuotedStr(Source + 'FSR4_INT8') + ' ]; then ' +
      '  cp -rf ' + QuotedStr(Source + 'FSR4_INT8') + ' ' + QuotedStr(Target) + '; ' +
      'fi 2>/dev/null');
    SyncProc.Options := [poWaitOnExit];
    SyncProc.Execute;
  finally
    SyncProc.Free;
  end;
  WriteLn('[DEBUG] SyncPristineAssetsTo: synced pristine assets from ', Source, ' to ', Target);
end;

function TOptiscalerTab.GetBGModOriginalPathForChannel(IsStable: Boolean): string;
begin
  if IsStable then
    Result := GetBGModOriginalPath
  else
    Result := GetBGModOriginalEdgePath;
end;

procedure TOptiscalerTab.LoadVersionsFromFile;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  DeckyVer, OptiVer, FakeNvapiVer, FsrVer, XessVer, OptiPatcherVer, DlssVer, DlssEnablerVer, StreamlineVer: string;
  DlssEdgeVars: string;
  DlssEdgeFile: TextFile;
begin
  // Build path to goverlay.vars
  VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';

  // If the file does not exist in FFGModPath, fall back to the active channel's cache folder
  if not FileExists(VarsFilePath) then
  begin
    VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'; // stable cache
    if not FileExists(VarsFilePath) then
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars'; // edge cache
  end;

  // Check if file exists
  if not FileExists(VarsFilePath) then
    Exit;

  // Initialize version strings
  DeckyVer := '';
  OptiVer := '';
  FakeNvapiVer := '';
  FsrVer := '';
  XessVer := '';
  OptiPatcherVer := '';
  DlssVer := '';
  DlssEnablerVer := '';
  StreamlineVer := '';

  try
    AssignFile(VarsFile, VarsFilePath);
    Reset(VarsFile);
    try
      while not Eof(VarsFile) do
      begin
        ReadLn(VarsFile, Line);

        // Skip header line (starts with #)
        if (Length(Line) > 0) and (Line[1] = '#') then
          Continue;

        // Parse KEY=VALUE
        SepPos := Pos('=', Line);
        if SepPos > 0 then
        begin
          Key := Copy(Line, 1, SepPos - 1);
          Value := Copy(Line, SepPos + 1, Length(Line));

          // Store values - support both old and new key names (case-insensitive)
          if SameText(Key, 'DeckyVersion') or SameText(Key, 'optiScalerVersion') or SameText(Key, 'OptiScalerVersion') then
            OptiVer := Value  // Support both optiScalerVersion and OptiScalerVersion
          else if SameText(Key, 'FakeNvapiVersion') then
            FakeNvapiVer := Value
          else if SameText(Key, 'fsrversion') then
            FsrVer := Value
          else if SameText(Key, 'xessversion') then
            XessVer := Value
          else if SameText(Key, 'optipatcher') then
            OptiPatcherVer := Value
          else if SameText(Key, 'dlssversion') then
            DlssVer := Value
          else if SameText(Key, 'dlssenablerversion') or SameText(Key, 'dlssenabler') then
            DlssEnablerVer := Value
          else if SameText(Key, 'streamlineversion') or SameText(Key, 'streamline') then
            StreamlineVer := Value;
        end;
      end;
    finally
      CloseFile(VarsFile);
    end;

    // Update labels with loaded versions
    if Assigned(FDeckyLabel) and (DeckyVer <> '') then
    begin
      try
        FDeckyLabel.Caption := DeckyVer;
        FDeckyLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    if Assigned(FOptiLabel) and (OptiVer <> '') then
    begin
      try
        FOptiLabel.Caption := OptiVer;
        FOptiLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    if Assigned(FFakeNvapiLabel) and (FakeNvapiVer <> '') then
    begin
      try
        FFakeNvapiLabel.Caption := FakeNvapiVer;
        FFakeNvapiLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    // Update XESS label — only when value was found in goverlay.vars
    if Assigned(FXessLabel) and (XessVer <> '') then
    begin
      try
        FXessLabel.Caption := XessVer;
        FXessLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    // Update FSR label — only when value was found in goverlay.vars
    if Assigned(FFsrLabel) and (FsrVer <> '') then
    begin
      try
        FFsrLabel.Caption := FsrVer;
        FFsrLabel.Font.Color := clOlive;

        // If the version is '4.0.2c (INT8)', set combobox to index 1 (Global mode only)
        if goverlayform.FActiveGameName = '' then
        begin
          if Assigned(FFsrVersionComboBox) and ((FsrVer = '4.0.2c (INT8)') or (FsrVer = '4.0.2c INT8')) then
            FFsrVersionComboBox.ItemIndex := 1
          else if Assigned(FFsrVersionComboBox) and ((FsrVer = 'Latest (FP8)') or (FsrVer = 'Latest')) then
            FFsrVersionComboBox.ItemIndex := 0;
        end;

        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    // Update OptiPatcher label
    if Pos(',', OptiPatcherVer) > 0 then
      OptiPatcherVer := '';

    if Assigned(FOptiPatcherLabel) and (OptiPatcherVer <> '') then
    begin
      try
        FOptiPatcherLabel.Caption := OptiPatcherVer;
        FOptiPatcherLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    // Update DLSS label (date only, no color change — preserved from LFM)
    if Assigned(FDlssLabel) and (DlssVer <> '') then
    begin
      try
        FDlssLabel.Caption := DlssVer;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    DlssEdgeVars := IncludeTrailingPathDelimiter(GetDlssEnablerPath((not Assigned(FOptVersionComboBox)) or (FOptVersionComboBox.ItemIndex <> 1))) + 'goverlay.vars';
    if FileExists(DlssEdgeVars) then
    begin
      try
        AssignFile(DlssEdgeFile, DlssEdgeVars);
        Reset(DlssEdgeFile);
        try
          while not Eof(DlssEdgeFile) do
          begin
            ReadLn(DlssEdgeFile, Line);
            SepPos := Pos('=', Line);
            if SepPos > 0 then
            begin
              Key := Copy(Line, 1, SepPos - 1);
              Value := Copy(Line, SepPos + 1, MaxInt);
              if (DlssEnablerVer = '') and (SameText(Key, 'dlssenablerversion') or SameText(Key, 'dlssenabler')) then
                DlssEnablerVer := Value;
              if (StreamlineVer = '') and (SameText(Key, 'streamlineversion') or SameText(Key, 'streamline')) then
                StreamlineVer := Value;
              if (OptiVer = '') then
              begin
                if SameText(Key, 'optiScalerVersion') or SameText(Key, 'OptiScalerVersion') then
                  OptiVer := Value;
              end;
            end;
          end;
        finally
          CloseFile(DlssEdgeFile);
        end;
      except
      end;
    end;

    if (OptiVer = '') then
    begin
      DlssEdgeVars := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars';
      if FileExists(DlssEdgeVars) then
      begin
        try
          AssignFile(DlssEdgeFile, DlssEdgeVars);
          Reset(DlssEdgeFile);
          try
            while not Eof(DlssEdgeFile) do
            begin
              ReadLn(DlssEdgeFile, Line);
              SepPos := Pos('=', Line);
              if SepPos > 0 then
              begin
                Key := Copy(Line, 1, SepPos - 1);
                Value := Copy(Line, SepPos + 1, MaxInt);
                if SameText(Key, 'optiScalerVersion') or SameText(Key, 'OptiScalerVersion') then
                begin
                  OptiVer := Value;
                  Break;
                end;
              end;
            end;
          finally
            CloseFile(DlssEdgeFile);
          end;
        except
        end;
      end;
    end;

    if (OptiVer <> '') and Assigned(FOptiLabel) then
    begin
      FOptiLabel.Caption := OptiVer;
      FOptiLabel.Font.Color := clOlive;
    end;

    if not (Assigned(goverlayform) and Assigned(goverlayform.dlssenablerRadioButton) and goverlayform.dlssenablerRadioButton.Checked) then
    begin
      DlssEnablerVer := '--';
      StreamlineVer := '--';
    end;

    if Assigned(FDlssEnablerLabel) then
      FDlssEnablerLabel.Caption := FormatDlssEnablerDisplayTag(DlssEnablerVer);
    if Assigned(goverlayform.dlssEnablerVersionLabel) then
      goverlayform.dlssEnablerVersionLabel.Caption := FormatDlssEnablerDisplayTag(DlssEnablerVer);
    if Assigned(goverlayform.streamlineVersionLabel) then
      goverlayform.streamlineVersionLabel.Caption := StreamlineVer;

  except
    on E: Exception do
      // Silently ignore errors when loading versions
      Exit;
  end;
end;


procedure TOptiscalerTab.CheckForUpdatesOnClick;
var
  IsStableChannel: Boolean;
begin
  // Test mode: never spawn network update threads (deterministic test runs)
  if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then Exit;

  if Assigned(FUpdateThread) then
  begin
    WriteLn('[DEBUG] CheckForUpdatesOnClick: Existing thread found, terminating for new check');
    FUpdateThread.Terminate;
    FUpdateThread := nil;
  end;

  // Hide labels before checking
  if Assigned(FDeckyLabel2) then
    FDeckyLabel2.Visible := False;

  if Assigned(FOptiLabel2) then
  begin
    FOptiLabel2.Caption := 'Searching for updates...';
    FOptiLabel2.Font.Color := clAqua;
    FOptiLabel2.Visible := True;
  end;

  // Hide notification label initially
  if Assigned(FNotificationLabel) then
    FNotificationLabel.Visible := False;

  // Disable the check button
  if Assigned(FCheckupdBtn) then
    FCheckupdBtn.Enabled := False;

  // Determine channel based on ComboBox selection
  IsStableChannel := True;  // Default to stable
  if Assigned(FOptVersionComboBox) then
  begin
    if FOptVersionComboBox.ItemIndex = 0 then
      IsStableChannel := True
    else if FOptVersionComboBox.ItemIndex = 1 then
      IsStableChannel := False;
  end;

  // Use ~/fgmod path only as fallback if FFGModPath is empty
  if FFGModPath = '' then
    FFGModPath := GetOptiScalerInstallPath;
  WriteLn('[DEBUG] CheckForUpdatesOnClick: Using path = ', FFGModPath);

  // Load versions from goverlay.vars if it exists
  if DirectoryExists(FFGModPath) then
  begin
    WriteLn('[DEBUG] CheckForUpdatesOnClick: Directory exists, loading versions from file...');
    LoadVersionsFromFile;
  end;

  // Spawn background thread for async check
  try
    FUpdateThread := TOptiUpdateThread.Create(Self, IsStableChannel, DirectoryExists(FFGModPath));
    WriteLn('[DEBUG] CheckForUpdatesOnClick: Spawned update checking thread');
    FUpdateThread.Start;
  except
    on E: Exception do
    begin
      FUpdateThread := nil;
      WriteLn('[WARNING] CheckForUpdatesOnClick: Failed to spawn update thread: ', E.Message);
    end;
  end;
end;

procedure TOptiscalerTab.CheckForUpdates;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  StoredDeckyVersion: string;
  LatestDeckyVersion: string;
begin
  // Build path to goverlay.vars
  VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';

  // Check if file exists
  if not FileExists(VarsFilePath) then
    Exit;

  // Initialize stored versions
  StoredDeckyVersion := '';

  try
    // Read stored versions from goverlay.vars
    AssignFile(VarsFile, VarsFilePath);
    Reset(VarsFile);
    try
      while not Eof(VarsFile) do
      begin
        ReadLn(VarsFile, Line);

        // Skip header line (starts with #)
        if (Length(Line) > 0) and (Line[1] = '#') then
          Continue;

        // Parse KEY=VALUE
        SepPos := Pos('=', Line);
        if SepPos > 0 then
        begin
          Key := Copy(Line, 1, SepPos - 1);
          Value := Copy(Line, SepPos + 1, Length(Line));

          if Key = 'DeckyVersion' then
            StoredDeckyVersion := Value;
        end;
      end;
    finally
      CloseFile(VarsFile);
    end;

    // Check for Decky updates
    if StoredDeckyVersion <> '' then
    begin
      LatestDeckyVersion := GetLatestReleaseTag;
      if (LatestDeckyVersion <> '') and (LatestDeckyVersion <> StoredDeckyVersion) then
      begin
        // Update available
        if Assigned(FDeckyLabel2) then
        begin
          try
            FDeckyLabel2.Caption := ' Update available ' + '(' + LatestDeckyVersion + ')';
            FDeckyLabel2.Visible := True;
            FDeckyLabel2.Font.Color := clLime;
            Application.ProcessMessages;
          except
            // Ignore errors
          end;
        end;
      end;
    end;

  except
    on E: Exception do
      ShowMessage('Error checking for updates: ' + E.Message);
  end;
end;

procedure TOptiscalerTab.InitializeTab;
var
  CurrentVersion: string;
  SavedSettings: TOptiScalerSettings;
  SavedOnChange: TNotifyEvent;
begin
  // Hide update labels initially
  if Assigned(FDeckyLabel2) then
    FDeckyLabel2.Visible := False;

  if Assigned(FOptiLabel2) then
    FOptiLabel2.Visible := False;

  // Check if fgmod folder exists
  if DirectoryExists(FFGModPath) then
  begin
    WriteLn('[DEBUG] InitializeTab: fgmod directory found');

    // Load current versions
    LoadVersionsFromFile;

    // Restore saved channel selection from config (primary source)
    if Assigned(FOptVersionComboBox) then
    begin
      SavedOnChange := FOptVersionComboBox.OnChange;
      FOptVersionComboBox.OnChange := nil;
      try
        SavedSettings := Default(TOptiScalerSettings);
      if overlay_config.LoadOptiScalerConfig('', SavedSettings) and (SavedSettings.OptVersionItemIndex in [0, 1]) then
      begin
        FOptVersionComboBox.ItemIndex := SavedSettings.OptVersionItemIndex;
        WriteLn('[DEBUG] InitializeTab: Restored saved channel selection, ComboBox index = ', SavedSettings.OptVersionItemIndex);
      end
      else if not (FOptVersionComboBox.ItemIndex in [0, 1]) then
      begin
        // Fallback: combobox not yet set by game-specific config, derive from installed version tag
        CurrentVersion := '';
        if Assigned(FOptiLabel) then
          CurrentVersion := FOptiLabel.Caption;
        WriteLn('[DEBUG] InitializeTab: Current OptiScaler version = "', CurrentVersion, '"');

        if (Length(CurrentVersion) > 5) and (Copy(CurrentVersion, 1, 5) = 'edge-') then
        begin
          FOptVersionComboBox.ItemIndex := 1;
          WriteLn('[DEBUG] InitializeTab: Detected bleeding-edge version, set ComboBox to index 1');
        end
        else
        begin
          FOptVersionComboBox.ItemIndex := 0;
          WriteLn('[DEBUG] InitializeTab: Detected stable version, set ComboBox to index 0');
        end;
      end
      else
        WriteLn('[DEBUG] InitializeTab: ComboBox already set by game config, index = ', FOptVersionComboBox.ItemIndex, '. Skipping fallback.');
      finally
        FOptVersionComboBox.OnChange := SavedOnChange;
      end;
    end;

    // Set button to "Update" mode
    if Assigned(FUpdateBtn) then
    begin
      FUpdateBtn.Caption := 'Update';
      FUpdateBtn.visible := false;
      FCheckupdBtn.visible := true;
    end;
  end
  else
  begin
    WriteLn('[DEBUG] InitializeTab: No installation found');

    // No installation found - default to stable (index 0)
    if Assigned(FOptVersionComboBox) then
    begin
      FOptVersionComboBox.ItemIndex := 0;
      WriteLn('[DEBUG] InitializeTab: Set ComboBox to stable (index 0) by default');
    end;

    // Change button caption to "Install"
    if Assigned(FUpdateBtn) then
    begin
      FUpdateBtn.AutoSize:=true;
      FUpdateBtn.Caption := 'Install OptiScaler';
      FUpdateBtn.visible := true;
      FCheckupdBtn.visible := false;
      FUpdateBtn.Color:=clteal;
    end;
  end;
end;

procedure TOptiscalerTab.UpdateButtonClick(Sender: TObject);
var
  OptiScalerTag: string;
  DownloadURL: string;
  SevenZFilePath: string;
  UserDir: string;
  VarsFile: TextFile;
  VarsFilePath: string;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  IsStableChannel: Boolean;
  FGModFilePath: string;
  FGModBackupPath: string;
  FGModBackupExists: Boolean;
  VarsList: TStringList;
  VarsIdx: Integer;
  DlssLineFound: Boolean;
  OptiLineFound: Boolean;
  OptiPatcherLineFound: Boolean;
  FsrLineFound: Boolean;
  SyncProc: TProcess;
  Ini: TIniFile;
  FakeNvapiTag: string;
  FakeNvapiURL: string;
  Fake7zPath: string;
  FakeNvapiVerClean: string;
  FakeNvapiLineFound: Boolean;
  XessLineFound: Boolean;
   FsrStableVal: string;
   FsrEdgeVal: string;
  XessStableVal: string;
  OptiCfg: TConfigFile;
  XessEdgeVal: string;
  FsrStableValTemp: string;
  FsrEdgeValTemp: string;
  XessStableValTemp: string;
  XessEdgeValTemp: string;
  TargetFsrVersion: string;
  TargetXessVersion: string;
  DestDir: string;
  CachedTag: string;
  SkipDownloadExtract: Boolean;
  OrigPath: string;
begin
  // Test mode: never download updates (deterministic test runs)
  if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then Exit;

  if Assigned(goverlayform) and Assigned(goverlayform.dlssenablerRadioButton) and goverlayform.dlssenablerRadioButton.Checked then
  begin
    WriteLn('[DEBUG] UpdateButtonClick: DLSS Enabler selected, updating DLSS Enabler...');
    UpdateStatus('Downloading DLSS Enabler...');
    if CheckAndInstallDlssEnabler((not Assigned(FOptVersionComboBox)) or (FOptVersionComboBox.ItemIndex <> 1), True) then
    begin
      if Assigned(FOptiLabel2) then
        FOptiLabel2.Visible := False;
      if Assigned(FUpdateBtn) then
        FUpdateBtn.Visible := False;
      if Assigned(FCheckupdBtn) then
        FCheckupdBtn.Visible := True;
      ShowToast(ntSuccess, 'DLSS Enabler updated successfully!', 3000);
      LoadVersionsFromFile;
      if Assigned(goverlayform) then
      begin
        goverlayform.RefreshHomeOptiStatus;
        goverlayform.RefreshOsStatusDots;
      end;
    end
    else
      ShowToast(ntError, 'Failed to update DLSS Enabler', 5000);

    if Assigned(FUpdateBtn) then
      FUpdateBtn.Enabled := True;
    Exit;
  end;

  WriteLn('[DEBUG] ========================================');
  WriteLn('[DEBUG] UpdateButtonClick: Starting OptiScaler installation/update (NEW SIMPLIFIED VERSION)');
  WriteLn('[DEBUG] ========================================');

  // Disable button
  if Assigned(FUpdateBtn) then
    FUpdateBtn.Enabled := False;

  try
    UpdateProgress(0);

    // Hide notification label when starting installation
    if Assigned(FNotificationLabel) then
      FNotificationLabel.Visible := False;

    // Get user directory at the beginning
    UserDir := GetUserDir;
    WriteLn('[DEBUG] UpdateButtonClick: User directory = ', UserDir);

    // Check if Stable Channel is selected (item 0) or Bleeding-Edge (item 1)
    IsStableChannel := False;
    if Assigned(FOptVersionComboBox) then
    begin
      if FOptVersionComboBox.ItemIndex = 0 then
      begin
        IsStableChannel := True;
        WriteLn('[DEBUG] UpdateButtonClick: Stable Channel selected');
      end
      else if FOptVersionComboBox.ItemIndex = 1 then
      begin
        IsStableChannel := False;
        WriteLn('[DEBUG] UpdateButtonClick: Bleeding-Edge Channel selected');
      end
      else
      begin
        ShowMessage('Please select a valid OptiScaler channel.');
        Exit;
      end;
    end
    else
    begin
      ShowMessage('OptiScaler channel not configured.');
      Exit;
    end;

    // STEP 1: Resolve the target cache directory based on the selected channel
    OrigPath := GetBGModOriginalPathForChannel(IsStableChannel);

    WriteLn('[DEBUG] UpdateButtonClick: Step 1 - Preparing cache directory...');
    FFGModPath := GetOptiScalerInstallPath;
    DestDir := GetGameConfigDir(goverlayform.FActiveGameName);
    WriteLn('[DEBUG] UpdateButtonClick: global bgmod path       = ', FFGModPath);
    WriteLn('[DEBUG] UpdateButtonClick: cache path (OrigPath)   = ', OrigPath);
    WriteLn('[DEBUG] UpdateButtonClick: active install dest     = ', DestDir);
    ForceDirectories(DestDir);

    UpdateProgress(10);

    // STEP 2: Get version tag based on selected channel
    if IsStableChannel then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Getting OptiScaler Stable tag...');
      OptiScalerTag := GetOptiScalerStableTag;
    end
    else
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Getting OptiScaler Bleeding-Edge tag...');
      OptiScalerTag := GetOptiScalerPreReleaseTag;
    end;

    // Verify we have a tag to proceed
    if OptiScalerTag = '' then
    begin
      WriteLn('[ERROR] UpdateButtonClick: No OptiScaler tag available, aborting');
      ShowToast(ntWarning, 'Could not retrieve OptiScaler version. Operation cancelled.', 5000);
      Exit;
    end;

    // Cache reuse: if OrigPath already contains OptiScalerVersion equal
    // to the freshly-fetched tag for this channel, skip the download/extract/
    // DLSS/FakeNVAPI/FSR4 steps and reuse the cached pristine assets. We still
    // sync DLLs to the active destination and regenerate goverlay.vars below.
    CachedTag := ReadCachedOptiScalerVersion;
    SkipDownloadExtract := (CachedTag <> '') and SameText(Trim(CachedTag), Trim(OptiScalerTag));
    if SkipDownloadExtract then
      WriteLn('[DEBUG] UpdateButtonClick: reusing cached folder (cached tag "', CachedTag, '" == requested "', OptiScalerTag, '")')
    else
      WriteLn('[DEBUG] UpdateButtonClick: cache miss (cached="', CachedTag, '" requested="', OptiScalerTag, '"), performing full download/extract');

    if not SkipDownloadExtract then
    begin
    // Wipe cache directory so the new release is extracted clean.
    if DirectoryExists(OrigPath) then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Cleaning cache directory for fresh extraction...');
      // Backup existing FakeNVAPI files in case online download fails
      if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.dll') then
        CopyFile(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.dll', IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.dll');
      if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.ini') then
        CopyFile(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.ini', IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.ini');
      if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'nvapi64.dll') then
        CopyFile(IncludeTrailingPathDelimiter(OrigPath) + 'nvapi64.dll', IncludeTrailingPathDelimiter(UserDir) + 'nvapi64_backup.dll');

      try
        DeleteDirectory(OrigPath, False);
      except
        on E: Exception do
          begin
            WriteLn('[ERROR] UpdateButtonClick: Failed to clean cache: ', E.Message);
            ShowMessage('Error: Could not clean cache directory.' + sLineBreak + E.Message);
            Exit;
          end;
      end;
    end;
    ForceDirectories(OrigPath);

    UpdateProgress(20);
    UpdateStatus('Downloading');

    // Build download URL for .7z file
    if IsStableChannel then
    begin
      DownloadURL := FOptiStableURL;
      if DownloadURL = '' then
        DownloadURL := Format('https://github.com/benjamimgois/OptiScaler-builds/releases/download/%s/optiscaler-stable.7z', [OptiScalerTag]);
      SevenZFilePath := IncludeTrailingPathDelimiter(UserDir) + 'optiscaler-stable.7z';
    end
    else
    begin
      DownloadURL := FOptiEdgeURL;
      if DownloadURL = '' then
        DownloadURL := Format('https://github.com/benjamimgois/OptiScaler-builds/releases/download/%s/optiscaler-edge.7z', [OptiScalerTag]);
      SevenZFilePath := IncludeTrailingPathDelimiter(UserDir) + 'optiscaler-edge.7z';
    end;

    WriteLn('[DEBUG] UpdateButtonClick: Download URL = ', DownloadURL);
    WriteLn('[DEBUG] UpdateButtonClick: 7z file path = ', SevenZFilePath);

    // Download OptiScaler .7z file
    WriteLn('[DEBUG] UpdateButtonClick: Downloading OptiScaler .7z file...');
    if not DownloadFile(DownloadURL, SevenZFilePath) then
    begin
      WriteLn('[ERROR] UpdateButtonClick: Download failed, aborting');
      ShowToast(ntError, 'Failed to download OptiScaler file', 5000);
      Exit;
    end;

    WriteLn('[DEBUG] UpdateButtonClick: Download completed successfully');
    UpdateProgress(50);
    UpdateStatus('Installing');

    // STEP 3: Extract .7z file to OrigPath (pristine store)
    WriteLn('[DEBUG] UpdateButtonClick: Step 3 - Extracting .7z file to cache folder...');
    if not Extract7z(SevenZFilePath, OrigPath) then
    begin
      WriteLn('[ERROR] UpdateButtonClick: 7z extraction failed, aborting');
      ShowToast(ntError, 'Failed to extract .7z file', 5000);
      Exit;
    end;

    // Ensure template OptiScaler.ini in cache uses Fsr4Update=auto
    if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'OptiScaler.ini') then
    begin
      OptiCfg := TConfigFile.Create;
      try
        if OptiCfg.Load(IncludeTrailingPathDelimiter(OrigPath) + 'OptiScaler.ini') then
        begin
          OptiCfg.SetValue('Fsr4Update=', 'auto');
          OptiCfg.Save;
        end;
      finally
        OptiCfg.Free;
      end;
    end;

    WriteLn('[DEBUG] UpdateButtonClick: Extraction completed successfully');
    UpdateProgress(70);

    // MOVE CONTENTS OF SUBFOLDER "OptiScaler" TO ROOT if it exists
    if DirectoryExists(IncludeTrailingPathDelimiter(OrigPath) + 'OptiScaler') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Moving files from OptiScaler/ subfolder to root...');
      SyncProc := TProcess.Create(nil);
      try
        SyncProc.Executable := 'sh';
        SyncProc.Parameters.Add('-c');
        SyncProc.Parameters.Add('cp -rf ' +
          QuotedStr(IncludeTrailingPathDelimiter(OrigPath) + 'OptiScaler/.') + ' ' +
          QuotedStr(OrigPath) + ' && rm -rf ' +
          QuotedStr(IncludeTrailingPathDelimiter(OrigPath) + 'OptiScaler'));
        SyncProc.Options := [poWaitOnExit];
        SyncProc.Execute;
      finally
        SyncProc.Free;
      end;
    end;

    // STEP 4: Make bgmod.sh executable in cache folder if it exists
    WriteLn('[DEBUG] UpdateButtonClick: Step 4 - Making bgmod.sh executable in cache folder...');
    if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'bgmod.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(OrigPath) + 'bgmod.sh',
                 IncludeTrailingPathDelimiter(OrigPath) + 'bgmod');
      fpChmod(IncludeTrailingPathDelimiter(OrigPath) + 'bgmod', &755);
      WriteLn('[DEBUG] UpdateButtonClick: bgmod is now executable');
    end;

    UpdateProgress(75);

    // STEP 5: Download NVIDIA DLSS DLLs into cache folder
    WriteLn('[DEBUG] UpdateButtonClick: Step 5 - Downloading NVIDIA DLSS DLLs into cache folder...');
    UpdateStatus('Downloading NVIDIA DLSS');
    if not DownloadFile(URL_NVIDIA_DLSS_BASE + 'nvngx_dlss.dll',
                        IncludeTrailingPathDelimiter(OrigPath) + 'nvngx_dlss.dll') then
      WriteLn('[WARN] UpdateButtonClick: Failed to download nvngx_dlss.dll, continuing...');
    UpdateProgress(80);
    if not DownloadFile(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssg.dll',
                        IncludeTrailingPathDelimiter(OrigPath) + 'nvngx_dlssg.dll') then
      WriteLn('[WARN] UpdateButtonClick: Failed to download nvngx_dlssg.dll, continuing...');
    UpdateProgress(88);

    // Download auxiliary dlssg_to_fsr3 DLL
    UpdateStatus('Downloading dlssg_to_fsr3 DLL');
    if not DownloadFile('https://github.com/benjamimgois/OptiScaler-builds/releases/download/dlssg-fsr3-0.130/dlssg_to_fsr3_amd_is_better.dll',
                        IncludeTrailingPathDelimiter(OrigPath) + 'dlssg_to_fsr3_amd_is_better.dll') then
      WriteLn('[WARN] UpdateButtonClick: Failed to download dlssg_to_fsr3_amd_is_better.dll, continuing...');

    // Fetch and download/extract latest FakeNVAPI
    UpdateStatus('Downloading FakeNVAPI');
    FakeNvapiVerClean := '';
    if FetchFakeNvapiLatest(FakeNvapiTag, FakeNvapiURL) then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Found FakeNVAPI tag: ', FakeNvapiTag);
      Fake7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-latest.7z';
      if DownloadFile(FakeNvapiURL, Fake7zPath) then
      begin
        WriteLn('[DEBUG] UpdateButtonClick: Extracting FakeNVAPI...');
        if Extract7z(Fake7zPath, OrigPath) then
          WriteLn('[DEBUG] UpdateButtonClick: FakeNVAPI extracted successfully')
        else
          WriteLn('[WARN] UpdateButtonClick: Failed to extract FakeNVAPI');
        DeleteFile(Fake7zPath);
      end
      else
        WriteLn('[WARN] UpdateButtonClick: Failed to download FakeNVAPI');

      // Strip leading 'v' for FakeNvapiVersion key
      FakeNvapiVerClean := FakeNvapiTag;
      if (Length(FakeNvapiVerClean) > 0) and (FakeNvapiVerClean[1] = 'v') then
        FakeNvapiVerClean := Copy(FakeNvapiVerClean, 2, Length(FakeNvapiVerClean) - 1);
    end
    else
      WriteLn('[WARN] UpdateButtonClick: Failed to fetch FakeNVAPI latest release info');

    // If FakeNVAPI download failed or files missing, restore backed-up assets
    if not FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.dll') and FileExists(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.dll') then
    begin
      WriteLn('[WARN] UpdateButtonClick: Restoring backed-up fakenvapi.dll...');
      CopyFile(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.dll', IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.dll');
    end;
    if not FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.ini') and FileExists(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.ini') then
    begin
      WriteLn('[WARN] UpdateButtonClick: Restoring backed-up fakenvapi.ini...');
      CopyFile(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.ini', IncludeTrailingPathDelimiter(OrigPath) + 'fakenvapi.ini');
    end;
    if not FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'nvapi64.dll') and FileExists(IncludeTrailingPathDelimiter(UserDir) + 'nvapi64_backup.dll') then
    begin
      WriteLn('[WARN] UpdateButtonClick: Restoring backed-up nvapi64.dll...');
      CopyFile(IncludeTrailingPathDelimiter(UserDir) + 'nvapi64_backup.dll', IncludeTrailingPathDelimiter(OrigPath) + 'nvapi64.dll');
    end;

    DeleteFile(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.dll');
    DeleteFile(IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi_backup.ini');
    DeleteFile(IncludeTrailingPathDelimiter(UserDir) + 'nvapi64_backup.dll');

    // STEP 5b: Setup FSR4 directories and download FSR INT8 DLL
    WriteLn('[DEBUG] UpdateButtonClick: Step 5b - Setting up FSR4_LATEST and FSR4_INT8 directories...');
    ForceDirectories(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_LATEST');
    ForceDirectories(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_INT8');

    // Copy current default upscaler dll to FSR4_LATEST
    if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'amd_fidelityfx_upscaler_dx12.dll') then
    begin
      CopyFile(IncludeTrailingPathDelimiter(OrigPath) + 'amd_fidelityfx_upscaler_dx12.dll',
               IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_LATEST/amd_fidelityfx_upscaler_dx12.dll');
      WriteLn('[DEBUG] UpdateButtonClick: Copied default upscaler from root to FSR4_LATEST');
    end;

    // Download INT8 upscaler dll
    UpdateStatus('Downloading FSR 4.0.2c (INT8)');
    if DownloadFile('https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll',
                    IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_INT8/amd_fidelityfx_upscaler_dx12.dll') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Downloaded INT8 upscaler to FSR4_INT8');
    end
    else
    begin
      WriteLn('[WARN] UpdateButtonClick: Failed to download FSR INT8 DLL');
    end;
    end; // close `if not SkipDownloadExtract then begin`

    // Sync DLLs/assets from OrigPath directly to the active install
    // destination (gameconfig/global/ or gameconfig/<game>/). Force-copy so a
    // channel switch actually replaces stale DLLs in the destination. Only
    // DLLs/plugins/FSR4/fakenvapi.ini are touched — user-editable files such
    // as bgmod.conf, OptiScaler.ini, MangoHud.conf are never clobbered here.
    WriteLn('[DEBUG] UpdateButtonClick: Syncing assets from cache to active destination...');
    UpdateStatus('Updating ' + DestDir);
    SyncPristineAssetsTo(OrigPath, DestDir);

    // Write/update DLSS download date in goverlay.vars
    VarsList := TStringList.Create;
    try
      try
        // Prefer the freshly-extracted OrigPath vars file; fall back to
        // the global copy so existing keys (optiScalerVersion, etc.) are preserved.
        if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'goverlay.vars') then
        begin
          VarsList.LoadFromFile(IncludeTrailingPathDelimiter(OrigPath) + 'goverlay.vars');
          WriteLn('[DEBUG] UpdateButtonClick: Loaded goverlay.vars from cache, lines = ', VarsList.Count);
        end
        else if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars') then
        begin
          VarsList.LoadFromFile(IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars');
          WriteLn('[DEBUG] UpdateButtonClick: Loaded goverlay.vars from global bgmod, lines = ', VarsList.Count);
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: No existing goverlay.vars found, will create new');

        DlssLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if Copy(VarsList[VarsIdx], 1, 12) = 'dlssversion=' then
          begin
            VarsList[VarsIdx] := 'dlssversion=' + FormatDateTime('ddmmyy', Now);
            DlssLineFound := True;
            Break;
          end;
        if not DlssLineFound then
        begin
          VarsList.Add('dlssversion=' + FormatDateTime('ddmmyy', Now));
          WriteLn('[DEBUG] UpdateButtonClick: Added new dlssversion line');
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: Updated existing dlssversion line');

        OptiLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 18), 'optiscalerversion=') then
          begin
            VarsList[VarsIdx] := 'OptiScalerVersion=' + OptiScalerTag;
            OptiLineFound := True;
            Break;
          end;
        if not OptiLineFound then
        begin
          VarsList.Add('OptiScalerVersion=' + OptiScalerTag);
          WriteLn('[DEBUG] UpdateButtonClick: Added new OptiScalerVersion line');
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: Updated existing OptiScalerVersion line');

        OptiPatcherLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 12), 'optipatcher=') then
          begin
            VarsList[VarsIdx] := 'optipatcher=rolling-' + FormatDateTime('yyyy.MM.dd', Now);
            OptiPatcherLineFound := True;
            Break;
          end;
        if not OptiPatcherLineFound then
        begin
          VarsList.Add('optipatcher=rolling-' + FormatDateTime('yyyy.MM.dd', Now));
          WriteLn('[DEBUG] UpdateButtonClick: Added new optipatcher line');
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: Updated existing optipatcher line');

        // Fetch dynamic versions from vars.txt
        FsrStableVal := '4.1.1';
        FsrEdgeVal := '4.1.1';
        XessStableVal := '3.0.1';
        XessEdgeVal := '3.0.1';

        WriteLn('[DEBUG] UpdateButtonClick: Fetching vars.txt...');
        if FetchVarsTxt(FsrStableValTemp, FsrEdgeValTemp, XessStableValTemp, XessEdgeValTemp) then
        begin
          if FsrStableValTemp <> '' then FsrStableVal := FsrStableValTemp;
          if FsrEdgeValTemp <> '' then FsrEdgeVal := FsrEdgeValTemp;
          if XessStableValTemp <> '' then XessStableVal := XessStableValTemp;
          if XessEdgeValTemp <> '' then XessEdgeVal := XessEdgeValTemp;
          WriteLn('[DEBUG] UpdateButtonClick: Successfully fetched vars.txt');
        end
        else
          WriteLn('[WARN] UpdateButtonClick: Failed to fetch vars.txt, using fallbacks');

        if IsStableChannel then
        begin
          TargetFsrVersion := FsrStableVal;
          TargetXessVersion := XessStableVal;
        end
        else
        begin
          TargetFsrVersion := FsrEdgeVal;
          TargetXessVersion := XessEdgeVal;
        end;

        // Write FakeNvapiVersion if clean tag exists
        if FakeNvapiVerClean <> '' then
        begin
          FakeNvapiLineFound := False;
          for VarsIdx := 0 to VarsList.Count - 1 do
            if SameText(Copy(VarsList[VarsIdx], 1, 17), 'fakenvapiversion=') then
            begin
              VarsList[VarsIdx] := 'FakeNvapiVersion=' + FakeNvapiVerClean;
              FakeNvapiLineFound := True;
              Break;
            end;
          if not FakeNvapiLineFound then
          begin
            VarsList.Add('FakeNvapiVersion=' + FakeNvapiVerClean);
            WriteLn('[DEBUG] UpdateButtonClick: Added FakeNvapiVersion line');
          end
          else
            WriteLn('[DEBUG] UpdateButtonClick: Updated FakeNvapiVersion line');
        end;

        // Write fsrversion
        FsrLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 11), 'fsrversion=') then
          begin
            VarsList[VarsIdx] := 'fsrversion=' + TargetFsrVersion;
            FsrLineFound := True;
            Break;
          end;
        if not FsrLineFound then
        begin
          VarsList.Add('fsrversion=' + TargetFsrVersion);
          WriteLn('[DEBUG] UpdateButtonClick: Added fsrversion line');
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: Updated fsrversion line');

        // Write xessversion
        XessLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 12), 'xessversion=') then
          begin
            VarsList[VarsIdx] := 'xessversion=' + TargetXessVersion;
            XessLineFound := True;
            Break;
          end;
        if not XessLineFound then
        begin
          VarsList.Add('xessversion=' + TargetXessVersion);
          WriteLn('[DEBUG] UpdateButtonClick: Added xessversion line');
        end
        else
          WriteLn('[DEBUG] UpdateButtonClick: Updated xessversion line');

        // Write upscalertype=0
        XessLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 14), 'upscalertype=') then
          begin
            VarsList[VarsIdx] := 'upscalertype=0';
            XessLineFound := True;
            Break;
          end;
        if not XessLineFound then
          VarsList.Add('upscalertype=0');

        // Save to cache folder (pristine store)
        VarsList.SaveToFile(IncludeTrailingPathDelimiter(OrigPath) + 'goverlay.vars');
        WriteLn('[DEBUG] UpdateButtonClick: dlssversion saved to cache folder');

        // Save to the active install destination (gameconfig/global/ when no
        // game is selected, or gameconfig/<game>/ when one is).
        ForceDirectories(DestDir);
        VarsList.SaveToFile(IncludeTrailingPathDelimiter(DestDir) + 'goverlay.vars');
        WriteLn('[DEBUG] UpdateButtonClick: dlssversion saved to ', DestDir);
      except
        on E: Exception do
          WriteLn('[WARN] UpdateButtonClick: Could not write dlssversion - ', E.Message);
      end;
    finally
      VarsList.Free;
    end;

    // STEP 6: Read goverlay.vars from cache folder and update all labels
    WriteLn('[DEBUG] UpdateButtonClick: Step 6 - Reading goverlay.vars file...');
    VarsFilePath := IncludeTrailingPathDelimiter(OrigPath) + 'goverlay.vars';

    if FileExists(VarsFilePath) then
    begin
      try
        WriteLn('[DEBUG] UpdateButtonClick: goverlay.vars found at ', VarsFilePath);
        AssignFile(VarsFile, VarsFilePath);
        Reset(VarsFile);

        try
          while not Eof(VarsFile) do
          begin
            ReadLn(VarsFile, Line);

            // Skip comments and header lines
            if (Length(Line) > 0) and (Line[1] <> '#') then
            begin
              SepPos := Pos('=', Line);
              if SepPos > 0 then
              begin
                Key := Copy(Line, 1, SepPos - 1);
                Value := Copy(Line, SepPos + 1, Length(Line));

                WriteLn('[DEBUG] UpdateButtonClick: Found key: "', Key, '" = "', Value, '"');

                // Update labels based on keys (case-insensitive)
                if SameText(Key, 'optiScalerVersion') or SameText(Key, 'OptiScalerVersion') then
                begin
                  if Assigned(FOptiLabel) then
                  begin
                    FOptiLabel.Caption := Value;
                    FOptiLabel.Font.Color := clOlive;
                    WriteLn('[DEBUG] UpdateButtonClick: Updated OptLabel to "', Value, '"');
                  end;
                end
                else if SameText(Key, 'FakeNvapiVersion') then
                begin
                  if Assigned(FFakeNvapiLabel) then
                  begin
                    FFakeNvapiLabel.Caption := Value;
                    FFakeNvapiLabel.Font.Color := clOlive;
                    WriteLn('[DEBUG] UpdateButtonClick: Updated FakeNvapiLabel to "', Value, '"');
                  end;
                end
                else if SameText(Key, 'fsrversion') then
                begin
                  if Assigned(FFsrLabel) then
                  begin
                    FFsrLabel.Caption := Value;
                    FFsrLabel.Font.Color := clOlive;
                    WriteLn('[DEBUG] UpdateButtonClick: Updated FsrLabel to "', Value, '"');
                  end;
                end
                else if SameText(Key, 'xessversion') then
                begin
                  if Assigned(FXessLabel) then
                  begin
                    FXessLabel.Caption := Value;
                    FXessLabel.Font.Color := clOlive;
                    WriteLn('[DEBUG] UpdateButtonClick: Updated XessLabel to "', Value, '"');
                  end;
                end
                else if SameText(Key, 'dlssversion') then
                begin
                  if Assigned(FDlssLabel) then
                  begin
                    FDlssLabel.Caption := Value;
                    WriteLn('[DEBUG] UpdateButtonClick: Updated DlssLabel to "', Value, '"');
                  end;
                end;
              end;
            end;
          end;
        finally
          CloseFile(VarsFile);
        end;

        WriteLn('[DEBUG] UpdateButtonClick: Finished reading goverlay.vars');
      except
        on E: Exception do
        begin
          WriteLn('[ERROR] UpdateButtonClick: Error reading goverlay.vars - ', E.Message);
          ShowMessage('Warning: Could not read goverlay.vars: ' + E.Message);
        end;
      end;
    end
    else
      WriteLn('[WARN] UpdateButtonClick: goverlay.vars file not found at ', VarsFilePath);

    UpdateProgress(90);

    // Clean up temporary downloaded file
    WriteLn('[DEBUG] UpdateButtonClick: Cleaning up temporary files...');
    DeleteFile(SevenZFilePath);
    WriteLn('[DEBUG] UpdateButtonClick: Cleanup complete');

    UpdateProgress(100);
    UpdateStatus('Complete');

    WriteLn('[DEBUG] ========================================');
    WriteLn('[DEBUG] UpdateButtonClick: Installation completed successfully!');
    WriteLn('[DEBUG] ========================================');

    // After successful installation, hide Update button and show Check Updates button
    if Assigned(FUpdateBtn) then
    begin
      FUpdateBtn.Visible := False;
      WriteLn('[DEBUG] UpdateButtonClick: Update button hidden');
    end;

    if Assigned(FCheckupdBtn) then
    begin
      FCheckupdBtn.Visible := True;
      WriteLn('[DEBUG] UpdateButtonClick: Check Updates button shown');
    end;

    // Hide optLabel2 after installation
    if Assigned(FOptiLabel2) then
    begin
      FOptiLabel2.Visible := False;
      WriteLn('[DEBUG] UpdateButtonClick: optLabel2 hidden after installation');
    end;

    ShowToast(ntSuccess, 'OptiScaler installed successfully!', 4000);

    // Persist channel selection to bgmod.conf so combobox survives restart
    if Assigned(FOptVersionComboBox) then
    begin
      Ini := TIniFile.Create(FFGModPath + PathDelim + 'bgmod.conf');
      try
        Ini.WriteInteger('Config', 'OPT_CHANNEL', FOptVersionComboBox.ItemIndex);
        WriteLn('[DEBUG] UpdateButtonClick: Saved OPT_CHANNEL=', FOptVersionComboBox.ItemIndex, ' to bgmod.conf');
      finally
        Ini.Free;
      end;
      Ini := TIniFile.Create(OrigPath + PathDelim + 'bgmod.conf');
      try
        Ini.WriteInteger('Config', 'OPT_CHANNEL', FOptVersionComboBox.ItemIndex);
      finally
        Ini.Free;
      end;
    end;

  finally
    // Re-enable button
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Enabled := True;
    UpdateProgress(0);
    UpdateStatus('');
  end;
end;

function RunCurlWithProgress(const AUrl, AOutputFile: string; AStartPct, AEndPct: Integer; const AStatusPrefix: string; AOnProgress: TDownloadProgressProc): Integer;
var
  Process: TProcess;
  Buffer: string;
  BytesRead, P, i: Integer;
  NumStr: string;
  PctVal: Double;
  CurPct, LastPct: Integer;
begin
  Result := -1;
  LastPct := AStartPct;
  if Assigned(AOnProgress) then
    AOnProgress(AStartPct, AStatusPrefix);

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-#');
    Process.Parameters.Add('-L');
    Process.Parameters.Add('--connect-timeout');
    Process.Parameters.Add('10');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(AOutputFile);
    Process.Parameters.Add(AUrl);
    Process.Options := [poUsePipes];
    Process.Execute;

    SetLength(Buffer, 512);
    while Process.Running or (Process.Stderr.NumBytesAvailable > 0) do
    begin
      if Process.Stderr.NumBytesAvailable > 0 then
      begin
        BytesRead := Process.Stderr.Read(Buffer[1], Length(Buffer));
        if BytesRead > 0 then
        begin
          P := BytesRead;
          while P >= 1 do
          begin
            if Buffer[P] = '%' then
            begin
              i := P - 1;
              while (i >= 1) and (Buffer[i] in ['0'..'9', '.']) do
                Dec(i);
              if i < P - 1 then
              begin
                NumStr := Copy(Buffer, i + 1, P - i - 1);
                PctVal := StrToFloatDef(NumStr, -1);
                if (PctVal >= 0) and (PctVal <= 100) then
                begin
                  CurPct := AStartPct + Round((AEndPct - AStartPct) * (PctVal / 100.0));
                  if (CurPct <> LastPct) and Assigned(AOnProgress) then
                  begin
                    LastPct := CurPct;
                    AOnProgress(CurPct, AStatusPrefix + Format(' (%d%%)', [Round(PctVal)]));
                  end;
                end;
              end;
              Break;
            end;
            Dec(P);
          end;
        end;
      end;
      Sleep(20);
    end;
    Result := Process.ExitStatus;
  finally
    Process.Free;
  end;

  if (Result = 0) and Assigned(AOnProgress) then
    AOnProgress(AEndPct, AStatusPrefix);
end;

function CheckAndInstallDlssEnabler(AIsStable: Boolean = True; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  DestDir, VarsFilePath, DownloadUrl, TagName, ZipFile, TargetKeyword, ItemName, Response: string;
  Process: TProcess;
  VarsList: TStringList;
  AlreadyExtracted: Boolean;
  StartPos, EndPos, NamePos, SpacePos: Integer;
  StartPct, EndPct: Integer;
  ChanLabel: string;
begin
  Result := False;
  DestDir := IncludeTrailingPathDelimiter(GetDlssEnablerPath(AIsStable));
  VarsFilePath := DestDir + 'goverlay.vars';
  AlreadyExtracted := FileExists(DestDir + 'version.dll');

  if AIsStable then
  begin
    ChanLabel := 'DLSS Enabler (Stable)';
    StartPct := 45;
    EndPct := 65;
  end
  else
  begin
    ChanLabel := 'DLSS Enabler (Edge)';
    StartPct := 75;
    EndPct := 95;
  end;

  if not AForce and FileExists(VarsFilePath) and AlreadyExtracted then
  begin
    if Assigned(AOnProgress) then
      AOnProgress(EndPct + 5, ChanLabel + ' ready');
    Result := True;
    Exit;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(StartPct - 3, 'DLSS Enabler: Checking builds...');

  ForceDirectories(DestDir);
  if AIsStable then
    TargetKeyword := 'STABLE'
  else
    TargetKeyword := 'TRUNK';

  TagName := '';
  DownloadUrl := '';

  WriteLn('[DLSS-ENABLER] Fetching builds list from OptiScaler-builds...');

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action');
    Process.Options := [poWaitOnExit, poUsePipes];
    Process.Execute;
    SetLength(Response, Process.Output.NumBytesAvailable);
    if Length(Response) > 0 then
      Process.Output.Read(Response[1], Length(Response));
  finally
    Process.Free;
  end;

  StartPos := 1;
  while True do
  begin
    NamePos := PosEx('"name"', Response, StartPos);
    if NamePos = 0 then Break;
    StartPos := NamePos + 6;
    StartPos := PosEx('"', Response, StartPos);
    if StartPos = 0 then Break;
    Inc(StartPos);
    EndPos := PosEx('"', Response, StartPos);
    if EndPos = 0 then Break;
    ItemName := Copy(Response, StartPos, EndPos - StartPos);

    if (Pos(TargetKeyword, ItemName) > 0) and (Pos('DLSS Enabler ', ItemName) > 0) then
    begin
      NamePos := Pos('DLSS Enabler ', ItemName) + Length('DLSS Enabler ');
      SpacePos := PosEx(' ', ItemName, NamePos);
      if SpacePos > NamePos then
        TagName := Copy(ItemName, NamePos, SpacePos - NamePos);

      // Extract download_url
      NamePos := PosEx('"download_url"', Response, EndPos);
      if NamePos > 0 then
      begin
        StartPos := PosEx('http', Response, NamePos);
        if StartPos > 0 then
        begin
          SpacePos := PosEx('"', Response, StartPos);
          if SpacePos > StartPos then
            DownloadUrl := Copy(Response, StartPos, SpacePos - StartPos);
        end;
      end;
      Break;
    end;
    StartPos := EndPos + 1;
  end;

  if TagName = '' then
  begin
    if AIsStable then TagName := '4.8.12' else TagName := '4.8.13.5';
  end;

  if DownloadUrl = '' then
  begin
    if AIsStable then
      DownloadUrl := 'https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.12%20STABLE%20757%204.8.12%202026-07-26T18-01Z%20K8HToGjQv.zip'
    else
      DownloadUrl := 'https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.13.5%20TRUNK.zip';
  end;

  ZipFile := DestDir + 'dlssenabler.zip';
  WriteLn('[DLSS-ENABLER] Downloading ', DownloadUrl, ' to ', ZipFile);

  RunCurlWithProgress(DownloadUrl, ZipFile, StartPct, EndPct, 'DLSS Enabler: Downloading ' + ChanLabel, AOnProgress);

  if FileExists(ZipFile) then
  begin
    WriteLn('[DLSS-ENABLER] Extracting zip archive into ', DestDir, '...');
    Process := TProcess.Create(nil);
    try
      Process.Executable := '7z';
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');
      Process.Parameters.Add('-o' + DestDir);
      Process.Parameters.Add(ZipFile);
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;
    DeleteFile(ZipFile);
  end;

  // Write goverlay.vars
  VarsList := TStringList.Create;
  try
    VarsList.Add('dlssenablerversion=' + TagName);
    VarsList.Add('dlssenablertag=' + TagName);
    VarsList.Add('upscalertype=1');
    VarsList.SaveToFile(VarsFilePath);
  finally
    VarsList.Free;
  end;

  CheckAndInstallStreamlineSDK(AIsStable, AForce);

  Result := FileExists(VarsFilePath) and FileExists(DestDir + 'version.dll');
end;

// Check and automatically install Streamline SDK if not present
function CheckAndInstallStreamlineSDK(AIsStable: Boolean = True; AForce: Boolean = False): Boolean;
var
  DestDir, VarsFilePath, DownloadUrl, TagName, ZipFile, TmpDir, Response: string;
  Process: TProcess;
  VarsList: TStringList;
  AlreadyExtracted: Boolean;
  StartPos, EndPos, AssetPos, TagPos: Integer;
begin
  Result := False;
  DestDir := IncludeTrailingPathDelimiter(GetDlssEnablerPath(AIsStable));
  VarsFilePath := DestDir + 'goverlay.vars';
  AlreadyExtracted := FileExists(DestDir + 'sl.common.dll') or FileExists(DestDir + 'sl.interposer.dll');

  if not AForce and AlreadyExtracted then
  begin
    Result := True;
    Exit;
  end;

  ForceDirectories(DestDir);
  TagName := '';
  DownloadUrl := '';

  WriteLn('[STREAMLINE-SDK] Checking latest release from NVIDIA-RTX/Streamline...');

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('https://api.github.com/repos/NVIDIA-RTX/Streamline/releases/latest');
    Process.Options := [poWaitOnExit, poUsePipes];
    Process.Execute;
    SetLength(Response, Process.Output.NumBytesAvailable);
    if Length(Response) > 0 then
      Process.Output.Read(Response[1], Length(Response));
  finally
    Process.Free;
  end;

  TagPos := Pos('"tag_name"', Response);
  if TagPos > 0 then
  begin
    TagPos := PosEx('"', Response, TagPos + 10);
    if TagPos > 0 then
    begin
      EndPos := PosEx('"', Response, TagPos + 1);
      if (EndPos > TagPos) then
      begin
        TagName := Copy(Response, TagPos + 1, EndPos - TagPos - 1);
        if (Length(TagName) > 1) and (TagName[1] = 'v') then
          TagName := Copy(TagName, 2, MaxInt);
      end;
    end;
  end;

  AssetPos := Pos('"browser_download_url"', Response);
  if AssetPos > 0 then
  begin
    StartPos := PosEx('http', Response, AssetPos);
    if StartPos > 0 then
    begin
      EndPos := PosEx('"', Response, StartPos);
      if (EndPos > StartPos) then
        DownloadUrl := Copy(Response, StartPos, EndPos - StartPos);
    end;
  end;

  if TagName = '' then TagName := '2.12.0';
  if DownloadUrl = '' then
    DownloadUrl := 'https://github.com/NVIDIA-RTX/Streamline/releases/download/v' + TagName + '/streamline-sdk-v' + TagName + '.zip';

  ZipFile := DestDir + 'streamline.zip';
  TmpDir := DestDir + 'streamline_tmp' + PathDelim;

  WriteLn('[STREAMLINE-SDK] Downloading ', DownloadUrl);

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(ZipFile);
    Process.Parameters.Add(DownloadUrl);
    Process.Options := [poWaitOnExit];
    Process.Execute;
  finally
    Process.Free;
  end;

  if FileExists(ZipFile) then
  begin
    WriteLn('[STREAMLINE-SDK] Extracting DLLs from /bin/x64/...');
    ForceDirectories(TmpDir);
    Process := TProcess.Create(nil);
    try
      Process.Executable := '7z';
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');
      Process.Parameters.Add('-o' + TmpDir);
      Process.Parameters.Add(ZipFile);
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;
    DeleteFile(ZipFile);

    Process := TProcess.Create(nil);
    try
      Process.Executable := 'sh';
      Process.Parameters.Add('-c');
      Process.Parameters.Add('find "' + TmpDir + '" -type f -path "*/bin/x64/*.dll" -exec cp -f {} "' + DestDir + '" \;');
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;

    Process := TProcess.Create(nil);
    try
      Process.Executable := 'rm';
      Process.Parameters.Add('-rf');
      Process.Parameters.Add(TmpDir);
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;
  end;

  VarsList := TStringList.Create;
  try
    if FileExists(VarsFilePath) then
      VarsList.LoadFromFile(VarsFilePath);
    VarsList.Values['streamlineversion'] := TagName;
    VarsList.SaveToFile(VarsFilePath);
  finally
    VarsList.Free;
  end;

  Result := FileExists(DestDir + 'sl.common.dll') or FileExists(DestDir + 'sl.interposer.dll');
end;

function CheckAndInstallOptiScaler(const AFGModPath: string; AIsStable: Boolean = True; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  OptiScalerTag: string;
  DownloadURL: string;
  SevenZFilePath: string;
  UserDir: string;
  Process: TProcess;
  ExitCode: Integer;
  OptiscalerTabTemp: TOptiscalerTab;
  VarsFilePath: string;
  VarsList: TStringList;
  VarsIdx: Integer;
  DlssLineFound: Boolean;
  OptiLineFound: Boolean;
  OptiPatcherLineFound: Boolean;
  FakeNvapiTag: string;
  FakeNvapiURL: string;
  Fake7zPath: string;
  FakeNvapiVerClean: string;
  FakeNvapiLineFound: Boolean;
  XessLineFound: Boolean;
  FsrLineFound: Boolean;
  FsrStableVal: string;
  FsrEdgeVal: string;
  XessStableVal: string;
  XessEdgeVal: string;
  FsrStableValTemp: string;
  FsrEdgeValTemp: string;
  XessStableValTemp: string;
  XessEdgeValTemp: string;
  TargetFsrVersion: string;
  TargetXessVersion: string;
  OptiCfg: TConfigFile;
  TargetCacheDir: string;
  ChanLabel: string;
  StartPct, EndPct: Integer;
begin
  Result := False;

  if AIsStable then
  begin
    TargetCacheDir := GetBGModOriginalPath;
    ChanLabel := 'OptiScaler (Stable)';
    StartPct := 0;
    EndPct := 25;
  end
  else
  begin
    TargetCacheDir := GetBGModOriginalEdgePath;
    ChanLabel := 'OptiScaler (Edge)';
    StartPct := 25;
    EndPct := 50;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel + ': Checking installation...');

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Checking ', ChanLabel, ' installation...');
  WriteLn('[AUTO-INSTALL] ========================================');
  
  // Check if OptiScaler.dll already exists in target cache
  if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler.dll') then
  begin
    WriteLn('[AUTO-INSTALL] OptiScaler.dll already exists in ', TargetCacheDir, ', no installation needed');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, ChanLabel + ': Already installed');
    Result := True;
    Exit;
  end;
  
  WriteLn('[AUTO-INSTALL] OptiScaler.dll not found in ', TargetCacheDir, ', starting automatic installation...');
  
  try
    OptiscalerTabTemp := TOptiscalerTab.Create;
    try
      // Get user directory
      UserDir := GetUserDir;
      
      // Get version tag
      OptiScalerTag := '';
      if AIsStable then
      begin
        WriteLn('[AUTO-INSTALL] Getting OptiScaler Stable tag...');
        OptiScalerTag := OptiscalerTabTemp.GetOptiScalerStableTag;
        DownloadURL := OptiscalerTabTemp.FOptiStableURL;
        if DownloadURL = '' then
          DownloadURL := Format('https://github.com/benjamimgois/OptiScaler-builds/releases/download/%s/optiscaler-stable.7z', [OptiScalerTag]);
        SevenZFilePath := IncludeTrailingPathDelimiter(UserDir) + 'optiscaler-stable-auto.7z';
      end
      else
      begin
        WriteLn('[AUTO-INSTALL] Getting OptiScaler Edge tag...');
        OptiScalerTag := OptiscalerTabTemp.GetOptiScalerPreReleaseTag;
        DownloadURL := OptiscalerTabTemp.FOptiEdgeURL;
        if DownloadURL = '' then
          DownloadURL := Format('https://github.com/benjamimgois/OptiScaler-builds/releases/download/%s/optiscaler-edge.7z', [OptiScalerTag]);
        SevenZFilePath := IncludeTrailingPathDelimiter(UserDir) + 'optiscaler-edge-auto.7z';
      end;

      if OptiScalerTag <> '' then
        WriteLn('[AUTO-INSTALL] Found ', ChanLabel, ' tag: ', OptiScalerTag)
      else
        WriteLn('[AUTO-INSTALL] No ', ChanLabel, ' tag found');
    
    // Verify we have a tag
    if OptiScalerTag = '' then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Could not get OptiScaler tag, aborting');
      Exit;
    end;
    
    WriteLn('[AUTO-INSTALL] Download URL: ', DownloadURL);
    WriteLn('[AUTO-INSTALL] Downloading...');
    
    // Download file using curl with progress updates
    ExitCode := RunCurlWithProgress(DownloadURL, SevenZFilePath, StartPct + 4, StartPct + 15, ChanLabel + ': Downloading core', AOnProgress);
    
    if (ExitCode <> 0) or not FileExists(SevenZFilePath) then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Download failed');
      Exit;
    end;

    WriteLn('[AUTO-INSTALL] Download completed, extracting to ', TargetCacheDir, '...');

    if Assigned(AOnProgress) then
      AOnProgress(StartPct + 16, ChanLabel + ': Extracting core...');

    // Extract to target cache directory
    Process := TProcess.Create(nil);
    try
      Process.Executable := '7z';
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');
      Process.Parameters.Add('-o' + TargetCacheDir);
      Process.Parameters.Add(SevenZFilePath);
      Process.Options := [poWaitOnExit];
      Process.Execute;
      ExitCode := Process.ExitStatus;
    finally
      Process.Free;
    end;

    if ExitCode <> 0 then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Extraction failed');
      DeleteFile(SevenZFilePath);
      Exit;
    end;

    WriteLn('[AUTO-INSTALL] Extraction to ', TargetCacheDir, ' completed');

    // Ensure template OptiScaler.ini in cache uses Fsr4Update=auto
    if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler.ini') then
    begin
      OptiCfg := TConfigFile.Create;
      try
        if OptiCfg.Load(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler.ini') then
        begin
          OptiCfg.SetValue('Fsr4Update=', 'auto');
          OptiCfg.Save;
        end;
      finally
        OptiCfg.Free;
      end;
    end;

    // MOVE CONTENTS OF SUBFOLDER "OptiScaler" TO ROOT if it exists
    if DirectoryExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler') then
    begin
      WriteLn('[AUTO-INSTALL] Moving files from OptiScaler/ subfolder to root...');
      Process := TProcess.Create(nil);
      try
        Process.Executable := 'sh';
        Process.Parameters.Add('-c');
        Process.Parameters.Add('cp -rf ' +
          QuotedStr(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler/.') + ' ' +
          QuotedStr(TargetCacheDir) + ' && rm -rf ' +
          QuotedStr(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler'));
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;
    end;

    // Rename bgmod.sh to bgmod in cache if it exists
    if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'bgmod.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(TargetCacheDir) + 'bgmod.sh',
                 IncludeTrailingPathDelimiter(TargetCacheDir) + 'bgmod');
      fpChmod(IncludeTrailingPathDelimiter(TargetCacheDir) + 'bgmod', &755);
    end;

    // Download NVIDIA DLSS DLLs to target cache
    WriteLn('[AUTO-INSTALL] Downloading NVIDIA DLSS DLLs...');
    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlss.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll', StartPct + 17, StartPct + 19, ChanLabel + ': Downloading NVIDIA DLSS (1/3)', AOnProgress);
    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssd.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll', StartPct + 19, StartPct + 21, ChanLabel + ': Downloading NVIDIA DLSS (2/3)', AOnProgress);
    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssg.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll', StartPct + 21, StartPct + 22, ChanLabel + ': Downloading NVIDIA DLSS (3/3)', AOnProgress);

    // Download auxiliary dlssg_to_fsr3 DLL
    WriteLn('[AUTO-INSTALL] Downloading dlssg_to_fsr3 DLL...');
    RunCurlWithProgress('https://github.com/benjamimgois/OptiScaler-builds/releases/download/dlssg-fsr3-0.130/dlssg_to_fsr3_amd_is_better.dll',
      IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll', StartPct + 22, StartPct + 23, ChanLabel + ': Downloading FrameGen bridge', AOnProgress);

    // Fetch and download/extract latest FakeNVAPI
    WriteLn('[AUTO-INSTALL] Downloading FakeNVAPI...');
    FakeNvapiVerClean := '';
    if OptiscalerTabTemp.FetchFakeNvapiLatest(FakeNvapiTag, FakeNvapiURL) then
    begin
      WriteLn('[AUTO-INSTALL] Found FakeNVAPI tag: ', FakeNvapiTag);
      Fake7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-latest-auto.7z';
      ExitCode := RunCurlWithProgress(FakeNvapiURL, Fake7zPath, StartPct + 23, StartPct + 24, ChanLabel + ': Downloading FakeNVAPI', AOnProgress);

      if (ExitCode = 0) and FileExists(Fake7zPath) then
      begin
        WriteLn('[AUTO-INSTALL] Extracting FakeNVAPI...');
        if Assigned(AOnProgress) then
          AOnProgress(StartPct + 24, ChanLabel + ': Extracting FakeNVAPI...');
        Process := TProcess.Create(nil);
        try
          Process.Executable := '7z';
          Process.Parameters.Add('x');
          Process.Parameters.Add('-y');
          Process.Parameters.Add('-o' + TargetCacheDir);
          Process.Parameters.Add(Fake7zPath);
          Process.Options := [poWaitOnExit];
          Process.Execute;
          ExitCode := Process.ExitStatus;
        finally
          Process.Free;
        end;

        if ExitCode = 0 then
          WriteLn('[AUTO-INSTALL] FakeNVAPI extracted successfully')
        else
          WriteLn('[AUTO-INSTALL] WARN: Failed to extract FakeNVAPI');
        DeleteFile(Fake7zPath);
      end
      else
        WriteLn('[AUTO-INSTALL] WARN: Failed to download FakeNVAPI');

      // Strip leading 'v' for FakeNvapiVersion key
      FakeNvapiVerClean := FakeNvapiTag;
      if (Length(FakeNvapiVerClean) > 0) and (FakeNvapiVerClean[1] = 'v') then
        FakeNvapiVerClean := Copy(FakeNvapiVerClean, 2, Length(FakeNvapiVerClean) - 1);
    end
    else
      WriteLn('[AUTO-INSTALL] WARN: Failed to fetch FakeNVAPI latest release info');

    // Download and setup FSR upscaler DLLs
    WriteLn('[AUTO-INSTALL] Setting up FSR4_LATEST and FSR4_INT8 directories...');
    ForceDirectories(IncludeTrailingPathDelimiter(TargetCacheDir) + 'FSR4_LATEST');
    ForceDirectories(IncludeTrailingPathDelimiter(TargetCacheDir) + 'FSR4_INT8');

    // Copy current default upscaler dll to FSR4_LATEST
    if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'amd_fidelityfx_upscaler_dx12.dll') then
    begin
      CopyFile(IncludeTrailingPathDelimiter(TargetCacheDir) + 'amd_fidelityfx_upscaler_dx12.dll',
               IncludeTrailingPathDelimiter(TargetCacheDir) + 'FSR4_LATEST/amd_fidelityfx_upscaler_dx12.dll');
      WriteLn('[AUTO-INSTALL] Copied default upscaler from root to FSR4_LATEST');
    end;

    // Download FSR INT8 DLL using curl with progress
    RunCurlWithProgress('https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll',
      IncludeTrailingPathDelimiter(TargetCacheDir) + 'FSR4_INT8/amd_fidelityfx_upscaler_dx12.dll', StartPct + 24, EndPct, ChanLabel + ': Downloading FSR components', AOnProgress);

    // Write/update DLSS download date in goverlay.vars
    VarsFilePath := IncludeTrailingPathDelimiter(TargetCacheDir) + 'goverlay.vars';
    VarsList := TStringList.Create;
    try
      try
        if FileExists(VarsFilePath) then
          VarsList.LoadFromFile(VarsFilePath);
        DlssLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if Copy(VarsList[VarsIdx], 1, 12) = 'dlssversion=' then
          begin
            VarsList[VarsIdx] := 'dlssversion=' + FormatDateTime('ddmmyy', Now);
            DlssLineFound := True;
            Break;
          end;
        if not DlssLineFound then
          VarsList.Add('dlssversion=' + FormatDateTime('ddmmyy', Now));

        OptiLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 18), 'optiscalerversion=') then
          begin
            VarsList[VarsIdx] := 'OptiScalerVersion=' + OptiScalerTag;
            OptiLineFound := True;
            Break;
          end;
        if not OptiLineFound then
        begin
          VarsList.Add('OptiScalerVersion=' + OptiScalerTag);
          WriteLn('[AUTO-INSTALL] Added new OptiScalerVersion line');
        end
        else
          WriteLn('[AUTO-INSTALL] Updated existing OptiScalerVersion line');

        OptiPatcherLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 12), 'optipatcher=') then
          begin
            VarsList[VarsIdx] := 'optipatcher=rolling-' + FormatDateTime('yyyy.MM.dd', Now);
            OptiPatcherLineFound := True;
            Break;
          end;
        if not OptiPatcherLineFound then
        begin
          VarsList.Add('optipatcher=rolling-' + FormatDateTime('yyyy.MM.dd', Now));
          WriteLn('[AUTO-INSTALL] Added new optipatcher line');
        end
        else
          WriteLn('[AUTO-INSTALL] Updated existing optipatcher line');

        // Fetch dynamic versions from vars.txt
        FsrStableVal := '4.1.1';
        FsrEdgeVal := '4.1.1';
        XessStableVal := '3.0.1';
        XessEdgeVal := '3.0.1';

        if OptiscalerTabTemp.FetchVarsTxt(FsrStableValTemp, FsrEdgeValTemp, XessStableValTemp, XessEdgeValTemp) then
        begin
          if FsrStableValTemp <> '' then FsrStableVal := FsrStableValTemp;
          if FsrEdgeValTemp <> '' then FsrEdgeVal := FsrEdgeValTemp;
          if XessStableValTemp <> '' then XessStableVal := XessStableValTemp;
          if XessEdgeValTemp <> '' then XessEdgeVal := XessEdgeValTemp;
          WriteLn('[AUTO-INSTALL] Successfully fetched vars.txt');
        end
        else
          WriteLn('[AUTO-INSTALL] WARN: Failed to fetch vars.txt, using fallbacks');

        if AIsStable then
        begin
          TargetFsrVersion := FsrStableVal;
          TargetXessVersion := XessStableVal;
        end
        else
        begin
          TargetFsrVersion := FsrEdgeVal;
          TargetXessVersion := XessEdgeVal;
        end;

        // Write FakeNvapiVersion if clean tag exists
        if FakeNvapiVerClean <> '' then
        begin
          FakeNvapiLineFound := False;
          for VarsIdx := 0 to VarsList.Count - 1 do
            if SameText(Copy(VarsList[VarsIdx], 1, 17), 'fakenvapiversion=') then
            begin
              VarsList[VarsIdx] := 'FakeNvapiVersion=' + FakeNvapiVerClean;
              FakeNvapiLineFound := True;
              Break;
            end;
          if not FakeNvapiLineFound then
          begin
            VarsList.Add('FakeNvapiVersion=' + FakeNvapiVerClean);
            WriteLn('[AUTO-INSTALL] Added FakeNvapiVersion line');
          end
          else
            WriteLn('[AUTO-INSTALL] Updated FakeNvapiVersion line');
        end;

        // Write fsrversion
        FsrLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 11), 'fsrversion=') then
          begin
            VarsList[VarsIdx] := 'fsrversion=' + TargetFsrVersion;
            FsrLineFound := True;
            Break;
          end;
        if not FsrLineFound then
        begin
          VarsList.Add('fsrversion=' + TargetFsrVersion);
          WriteLn('[AUTO-INSTALL] Added fsrversion line');
        end
        else
          WriteLn('[AUTO-INSTALL] Updated fsrversion line');

        // Write xessversion
        XessLineFound := False;
        for VarsIdx := 0 to VarsList.Count - 1 do
          if SameText(Copy(VarsList[VarsIdx], 1, 12), 'xessversion=') then
          begin
            VarsList[VarsIdx] := 'xessversion=' + TargetXessVersion;
            XessLineFound := True;
            Break;
          end;
        if not XessLineFound then
        begin
          VarsList.Add('xessversion=' + TargetXessVersion);
          WriteLn('[AUTO-INSTALL] Added xessversion line');
        end
        else
          WriteLn('[AUTO-INSTALL] Updated xessversion line');

        // Save to cache store
        VarsList.SaveToFile(VarsFilePath);
        WriteLn('[AUTO-INSTALL] dlssversion saved to ', TargetCacheDir);

        // Also save to gameconfig/global/ (active global config) if stable
        if AIsStable then
        begin
          ForceDirectories(goverlayform.GetGameConfigDir(''));
          VarsList.SaveToFile(IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir('')) + 'goverlay.vars');
          WriteLn('[AUTO-INSTALL] dlssversion saved to gameconfig/global/');
        end;
      except
        on E: Exception do
          WriteLn('[AUTO-INSTALL] WARN: Could not write dlssversion - ', E.Message);
      end;
    finally
      VarsList.Free;
    end;

    // Clean up download file
    DeleteFile(SevenZFilePath);

    // Verify installation in the target cache path
    if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler.dll') then
    begin
      WriteLn('[AUTO-INSTALL] ========================================');
      WriteLn('[AUTO-INSTALL] ', ChanLabel, ' installation completed!');
      WriteLn('[AUTO-INSTALL] ========================================');
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, ChanLabel + ': Installation complete');
      Result := True;
    end
    else
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Installation verification failed');
    end;
  finally
    OptiscalerTabTemp.Free;
  end;
  except
    on E: Exception do
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Exception during installation - ', E.Message);
    end;
  end;
end;

end.
