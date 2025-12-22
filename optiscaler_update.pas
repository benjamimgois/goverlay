unit optiscaler_update;

interface

uses
  Classes, SysUtils, Forms, ComCtrls, Buttons, Process,
  RegExpr, fpjson, jsonparser, zipper, Dialogs, StdCtrls, Graphics, DateUtils,
  constants;

// Function to get the correct OptiScaler installation path (Flatpak-aware)
function GetOptiScalerInstallPath: string;

type
  TOptiscalerTab = class
  private
    FUpdateBtn: TBitBtn;
    FCheckupdBtn: TBitBtn;
    FProgressBar: TProgressBar;
    FStatusLabel: TLabel;
    FDeckyLabel: TLabel;
    FOptiLabel: TLabel;
    FFakeNvapiLabel: TLabel;
    FXessLabel: TLabel;
    FFsrLabel: TLabel;
    FDeckyLabel2: TLabel;      // Label for update notification
    FFakeNvapiLabel2: TLabel;  // Label for update notification
    FNotificationLabel: TLabel; // Label for general notifications
    FFsrVersionComboBox: TComboBox; // ComboBox for FSR version selection
    FFGModPath: string;

    function GetLatestReleaseTag: string;
    function GetFakeNvapiReleaseTag: string;
    function DownloadFile(const AURL, ADestFile: string): Boolean;
    function ExtractZip(const AZipFile, ADestPath: string): Boolean;
    function Extract7z(const A7zFile, ADestPath: string): Boolean;
    procedure CopyDirectory(const ASource, ADest: string);
    procedure UpdateProgress(AProgress: Integer);
    procedure UpdateStatus(const AStatus: string);
    function ExtractOptiScalerVersion(const AFileName: string): string;
    procedure CheckForUpdates;
  public

    procedure LoadVersionsFromFile;
    procedure UpdateButtonClick(Sender: TObject);
    procedure InitializeTab;
    procedure CheckForUpdatesOnClick;
    property FGModPath: string read FFGModPath write FFGModPath;
    property UpdateBtn: TBitBtn read FUpdateBtn write FUpdateBtn;
    property CheckupdBtn: TBitBtn read FCheckupdBtn write FCheckupdBtn;
    property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
    property StatusLabel: TLabel read FStatusLabel write FStatusLabel;
    property DeckyLabel: TLabel read FDeckyLabel write FDeckyLabel;
    property OptiLabel: TLabel read FOptiLabel write FOptiLabel;
    property FakeNvapiLabel: TLabel read FFakeNvapiLabel write FFakeNvapiLabel;
    property XessLabel: TLabel read FXessLabel write FXessLabel;
    property FsrLabel: TLabel read FFsrLabel write FFsrLabel;
    property DeckyLabel2: TLabel read FDeckyLabel2 write FDeckyLabel2;
    property FakeNvapiLabel2: TLabel read FFakeNvapiLabel2 write FFakeNvapiLabel2;
    property NotificationLabel: TLabel read FNotificationLabel write FNotificationLabel;
    property FsrVersionComboBox: TComboBox read FFsrVersionComboBox write FFsrVersionComboBox;
  end;

implementation

uses
  FileUtil, LazFileUtils, BaseUnix;

// Function to detect if running in Flatpak environment
function IsRunningInFlatpak: Boolean;
begin
  Result := GetEnvironmentVariable('FLATPAK_ID') <> '';
end;

// Function to get the correct OptiScaler installation path
// Always returns ~/fgmod for both Flatpak and native installations
// Flatpak has --filesystem=home permission allowing access to user's home directory
function GetOptiScalerInstallPath: string;
var
  UserDir: string;
begin
  UserDir := GetUserDir;

  // Always use ~/fgmod regardless of Flatpak or native installation
  // Flatpak has --filesystem=home permission, so it can access user's home directory
  Result := IncludeTrailingPathDelimiter(UserDir) + 'fgmod';
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

function TOptiscalerTab.GetLatestReleaseTag: string;
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
        WriteLn('[ERROR] GetLatestReleaseTag: Failed to get response (exit: ', Process.ExitStatus, ', response empty: ', Response = '', ')');
        if Response <> '' then
          WriteLn('[ERROR] GetLatestReleaseTag: Response content: ', Copy(Response, 1, 200));
      end;



    except
      on E: Exception do
      begin
        WriteLn('[ERROR] GetLatestReleaseTag: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Error getting latest release: ' + E.Message + sLineBreak +
                   'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.GetFakeNvapiReleaseTag: string;
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
      WriteLn('[DEBUG] GetFakeNvapiReleaseTag: Fetching from ', URL_FAKENVAPI_API);

      // Use curl to get GitHub API for FakeNvapi
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add(URL_FAKENVAPI_API);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      WriteLn('[DEBUG] GetFakeNvapiReleaseTag: Curl exit status: ', Process.ExitStatus);
      WriteLn('[DEBUG] GetFakeNvapiReleaseTag: Response length: ', Length(Response), ' bytes');

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        WriteLn('[DEBUG] GetFakeNvapiReleaseTag: Parsing JSON response...');
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONObject) then
          begin
            WriteLn('[DEBUG] GetFakeNvapiReleaseTag: Valid JSON object received');
            JSONObject := TJSONObject(JSONData);
            Result := JSONObject.Get('tag_name', '');
            WriteLn('[DEBUG] GetFakeNvapiReleaseTag: tag_name = "', Result, '"');
          end
          else
            WriteLn('[ERROR] GetFakeNvapiReleaseTag: JSON data is not a valid object');
        finally
          JSONData.Free;
        end;
      end
      else
      begin
        WriteLn('[ERROR] GetFakeNvapiReleaseTag: Failed to get response (exit: ', Process.ExitStatus, ', response empty: ', Response = '', ')');
        if Response <> '' then
          WriteLn('[ERROR] GetFakeNvapiReleaseTag: Response content: ', Copy(Response, 1, 200));
      end;

      // If unable to get, show warning
      if Result = '' then
      begin
        WriteLn('[WARN] GetFakeNvapiReleaseTag: No version obtained, continuing without FakeNvapi');
        ShowMessage('Warning: Could not get FakeNvapi version automatically.' + sLineBreak +
                   'Continuing without FakeNvapi installation.');
      end;

    except
      on E: Exception do
      begin
        WriteLn('[ERROR] GetFakeNvapiReleaseTag: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Warning: Error getting FakeNvapi release: ' + E.Message + sLineBreak +
                   'Continuing without FakeNvapi installation.');
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
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
begin
  Result := False;
  Process := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    try
      Process.Executable := '7z';
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');  // Yes to all questions
      Process.Parameters.Add('-o' + ADestPath);
      Process.Parameters.Add(A7zFile);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      Result := Process.ExitStatus = 0;

      if not Result then
        ShowMessage('Error extracting 7z file. Exit code: ' + IntToStr(Process.ExitStatus));
    except
      on E: Exception do
        ShowMessage('Error executing 7z: ' + E.Message);
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

procedure TOptiscalerTab.LoadVersionsFromFile;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  DeckyVer, OptiVer, FakeNvapiVer, FsrVer: string;
begin
  // Build path to goverlay.vars
  VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';

  // Check if file exists
  if not FileExists(VarsFilePath) then
    Exit;

  // Initialize version strings
  DeckyVer := '';
  OptiVer := '';
  FakeNvapiVer := '';
  FsrVer := '';

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

          // Store values
          if Key = 'DeckyVersion' then
            DeckyVer := Value
          else if Key = 'OptiScalerVersion' then
            OptiVer := Value
          else if Key = 'FakeNvapiVersion' then
            FakeNvapiVer := Value
          else if Key = 'fsrversion' then
            FsrVer := Value;
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

    // Update XESS and FSR labels with fixed text
    if Assigned(FXessLabel) then
    begin
      try
        FXessLabel.Caption := 'decky built-in';
        FXessLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    if Assigned(FFsrLabel) then
    begin
      try
        // If fsrversion was found in goverlay.vars, use that value
        // Otherwise, use the default 'decky built-in'
        if FsrVer <> '' then
        begin
          FFsrLabel.Caption := FsrVer;

          // If the version is '4.0.2 (INT8)', set combobox to index 1
          if Assigned(FFsrVersionComboBox) and (FsrVer = '4.0.2 (INT8)') then
            FFsrVersionComboBox.ItemIndex := 1;
        end
        else
          FFsrLabel.Caption := 'decky built-in';
        FFsrLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

  except
    on E: Exception do
      // Silently ignore errors when loading versions
      Exit;
  end;
end;

procedure TOptiscalerTab.CheckForUpdatesOnClick;
var
  HasUpdates: Boolean;
begin
  HasUpdates := False;

  // Hide labels before checking
  if Assigned(FDeckyLabel2) then
    FDeckyLabel2.Visible := False;

  if Assigned(FFakeNvapiLabel2) then
    FFakeNvapiLabel2.Visible := False;

  // Hide notification label initially
  if Assigned(FNotificationLabel) then
    FNotificationLabel.Visible := False;

  // Check for updates if fgmod exists
  if DirectoryExists(FFGModPath) then
  begin
    CheckForUpdates;

    // Check if any update label is visible
    if Assigned(FDeckyLabel2) and FDeckyLabel2.Visible then
      HasUpdates := True;

    if Assigned(FFakeNvapiLabel2) and FFakeNvapiLabel2.Visible then
      HasUpdates := True;

    // Control button visibility based on updates
    if HasUpdates then
    begin
      // Hide checkupdBtn and show updateBtn
      if Assigned(FCheckupdBtn) then
        FCheckupdBtn.Visible := False;

      if Assigned(FUpdateBtn) then
        FUpdateBtn.Visible := True;
    end;
    // If no updates: just hide notification label (already hidden above)
    // Don't show any message
  end;
end;

procedure TOptiscalerTab.CheckForUpdates;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  StoredDeckyVersion, StoredFakeNvapiVersion: string;
  LatestDeckyVersion, LatestFakeNvapiVersion: string;
begin
  // Build path to goverlay.vars
  VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';

  // Check if file exists
  if not FileExists(VarsFilePath) then
    Exit;

  // Initialize stored versions
  StoredDeckyVersion := '';
  StoredFakeNvapiVersion := '';

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
            StoredDeckyVersion := Value
          else if Key = 'FakeNvapiVersion' then
            StoredFakeNvapiVersion := Value;
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

    // Check for FakeNvapi updates
    if StoredFakeNvapiVersion <> '' then
    begin
      LatestFakeNvapiVersion := GetFakeNvapiReleaseTag;
      if (LatestFakeNvapiVersion <> '') and (LatestFakeNvapiVersion <> StoredFakeNvapiVersion) then
      begin
        // Update available
        if Assigned(FFakeNvapiLabel2) then
        begin
          try
            FFakeNvapiLabel2.Caption := ' Update available ' + '(' + LatestFakeNvapiVersion + ')';
            FFakeNvapiLabel2.Visible := True;
            FFakeNvapiLabel2.Font.Color := clLime;
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
begin
  // Hide update labels initially
  if Assigned(FDeckyLabel2) then
    FDeckyLabel2.Visible := False;

  if Assigned(FFakeNvapiLabel2) then
    FFakeNvapiLabel2.Visible := False;

  // Check if fgmod folder exists
  if not DirectoryExists(FFGModPath) then
  begin
    // fgmod doesn't exist - change button caption to "Install"
    if Assigned(FUpdateBtn) then
    begin
      FUpdateBtn.AutoSize:=true;
      FUpdateBtn.Caption := 'Install OptiScaler';
      FUpdateBtn.visible := true;
      FCheckupdBtn.visible := false;
      FUpdateBtn.Color:=clteal;
    end;
  end
  else
  begin
    // fgmod exists - load current versions and set button to "Update"
    LoadVersionsFromFile;

    if Assigned(FUpdateBtn) then
    begin
      FUpdateBtn.Caption := 'Update';
      FUpdateBtn.visible := false;
      FCheckupdBtn.visible := true;
    end;
  end;
end;

procedure TOptiscalerTab.UpdateButtonClick(Sender: TObject);
var
  LatestTag: string;
  DeckyVersion: string;
  OptiVersion: string;
  FakeNvapiVersion: string;
  FakeNvapiURL: string;
  FakeNvapi7zPath: string;
  DownloadURL: string;
  ZipFilePath: string;
  ExtractPath: string;
  UserDir: string;
  AssetsSource, BinSource: string;
  AssetsPath, BinPath: string;
  SearchRec: TSearchRec;
  SevenZFile: string;
  VarsFile: TextFile;
  VarsFilePath: string;
begin
  WriteLn('[DEBUG] ========================================');
  WriteLn('[DEBUG] UpdateButtonClick: Starting OptiScaler installation/update');
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

    // 1. Get the latest tag from repository and store in variable
    WriteLn('[DEBUG] UpdateButtonClick: Step 1 - Getting latest release tag...');
    LatestTag := GetLatestReleaseTag;
    if LatestTag = '' then
    begin
      WriteLn('[ERROR] UpdateButtonClick: Failed to get latest release tag, aborting');
      ShowMessage('Could not get version for download.' + sLineBreak +
                 'Operation cancelled.');
      Exit;
    end;

    // Store version in DeckyVersion variable
    DeckyVersion := LatestTag;
    WriteLn('[DEBUG] UpdateButtonClick: DeckyVersion = "', DeckyVersion, '"');

    // Update DeckyLabel with the version (with safety check)
    if Assigned(FDeckyLabel) then
    begin
      try
        FDeckyLabel.Caption := DeckyVersion;
        FDeckyLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        on E: Exception do
        begin
          WriteLn('[ERROR] UpdateButtonClick: Could not update Decky label - ', E.Message);
          ShowMessage('Warning: Could not update Decky label: ' + E.Message);
        end;
      end;
    end;

    UpdateProgress(10);
    UpdateStatus('Downloading');

    // 2. Build download URL
    DownloadURL := Format('https://github.com/xXJSONDeruloXx/Decky-Framegen/releases/download/%s/Decky-Framegen.zip', [LatestTag]);
    ZipFilePath := IncludeTrailingPathDelimiter(UserDir) + 'Decky-Framegen.zip';
    WriteLn('[DEBUG] UpdateButtonClick: Step 2 - Building download URL');
    WriteLn('[DEBUG] UpdateButtonClick: Download URL = ', DownloadURL);
    WriteLn('[DEBUG] UpdateButtonClick: Zip file path = ', ZipFilePath);

    // 3. Download file to user's home
    WriteLn('[DEBUG] UpdateButtonClick: Step 3 - Downloading Decky-Framegen.zip...');
    if not DownloadFile(DownloadURL, ZipFilePath) then
    begin
      WriteLn('[ERROR] UpdateButtonClick: Download failed, aborting');
      ShowMessage('Failed to download file.');
      Exit;
    end;
    WriteLn('[DEBUG] UpdateButtonClick: Download completed successfully');
    UpdateProgress(50);
    UpdateStatus('Installing');

    // 4. Extract ZIP directly to user's home
    // The ZIP already contains a folder called Decky-Framegen
    WriteLn('[DEBUG] UpdateButtonClick: Step 4 - Extracting ZIP to ', UserDir);
    if not ExtractZip(ZipFilePath, UserDir) then
    begin
      WriteLn('[ERROR] UpdateButtonClick: ZIP extraction failed, aborting');
      ShowMessage('Failed to extract ZIP file.');
      Exit;
    end;
    WriteLn('[DEBUG] UpdateButtonClick: ZIP extraction completed');
    UpdateProgress(60);

    // 5. Create fgmod folder (Flatpak-aware path)
    ExtractPath := IncludeTrailingPathDelimiter(UserDir) + 'Decky-Framegen';
    FFGModPath := GetOptiScalerInstallPath;

    if DirectoryExists(FFGModPath) then
      DeleteDirectory(FFGModPath, False);
    ForceDirectories(FFGModPath);
    UpdateProgress(65);

    // 6. Copy assets and bin to fgmod
    AssetsSource := IncludeTrailingPathDelimiter(ExtractPath) + 'assets';
    BinSource := IncludeTrailingPathDelimiter(ExtractPath) + 'bin';

    if DirectoryExists(AssetsSource) then
    begin
      CopyDirectory(AssetsSource, IncludeTrailingPathDelimiter(FFGModPath) + 'assets');
      UpdateProgress(75);
    end
    else
      ShowMessage('Assets folder not found!');

    if DirectoryExists(BinSource) then
    begin
      CopyDirectory(BinSource, IncludeTrailingPathDelimiter(FFGModPath) + 'bin');
      UpdateProgress(85);
    end
    else
      ShowMessage('Bin folder not found!');

    // 7. Find and extract .7z file from bin folder
    WriteLn('[DEBUG] UpdateButtonClick: Step 7 - Looking for .7z file in bin folder...');
    SevenZFile := '';
    if FindFirst(IncludeTrailingPathDelimiter(FFGModPath) + 'bin' + PathDelim + '*.7z', faAnyFile, SearchRec) = 0 then
    begin
      try
        SevenZFile := IncludeTrailingPathDelimiter(FFGModPath) + 'bin' + PathDelim + SearchRec.Name;
        WriteLn('[DEBUG] UpdateButtonClick: Found .7z file: ', SevenZFile);

        // Extract OptiScaler version from filename
        OptiVersion := ExtractOptiScalerVersion(SearchRec.Name);
        WriteLn('[DEBUG] UpdateButtonClick: Extracted OptiVersion = "', OptiVersion, '"');

        // Update OptiLabel with the version (with safety check)
        if Assigned(FOptiLabel) and (OptiVersion <> '') then
        begin
          try
            FOptiLabel.Caption := OptiVersion;
            FOptiLabel.Font.Color := clOlive;
            Application.ProcessMessages;
          except
            on E: Exception do
            begin
              WriteLn('[ERROR] UpdateButtonClick: Could not update OptiScaler label - ', E.Message);
              ShowMessage('Warning: Could not update OptiScaler label: ' + E.Message);
            end;
          end;
        end;

      finally
        FindClose(SearchRec);
      end;
    end
    else
      WriteLn('[ERROR] UpdateButtonClick: No .7z file found in bin folder');

    if SevenZFile <> '' then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Extracting .7z file to ', FFGModPath);
      if Extract7z(SevenZFile, FFGModPath) then
      begin
        WriteLn('[DEBUG] UpdateButtonClick: .7z extraction successful');
        UpdateProgress(90);
      end
      else
      begin
        WriteLn('[ERROR] UpdateButtonClick: .7z extraction failed');
        ShowMessage('Failed to extract 7z file.');
      end;
    end
    else
    begin
      WriteLn('[ERROR] UpdateButtonClick: Cannot extract - no .7z file found');
      ShowMessage('.7z file not found in bin folder!');
    end;

    // 8. Move and rename specific .sh files from assets to fgmod root
    UpdateProgress(92);

    // Move fgmod.sh, fgmod-uninstaller.sh, and fgmod-remover.sh
    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod.sh',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod.sh');
    end;

    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod-uninstaller.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod-uninstaller.sh',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-uninstaller.sh');
    end;

    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod-remover.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(FFGModPath) + 'assets' + PathDelim + 'fgmod-remover.sh',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-remover.sh');
    end;

    UpdateProgress(95);

    // 9. Rename fgmod.sh to fgmod and give it execute permission
    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod.sh') then
    begin
      RenameFile(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod.sh',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod');

      // Make fgmod executable
      fpChmod(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod', &755);
    end;

    UpdateProgress(97);

    // 10. Delete assets and bin folders and all their contents
    AssetsPath := IncludeTrailingPathDelimiter(FFGModPath) + 'assets';
    BinPath := IncludeTrailingPathDelimiter(FFGModPath) + 'bin';

    if DirectoryExists(AssetsPath) then
    begin
      if DeleteDirectory(AssetsPath, False) then
        UpdateProgress(98)
      else
        ShowMessage('Warning: Could not delete assets folder');
    end;

    if DirectoryExists(BinPath) then
    begin
      if DeleteDirectory(BinPath, False) then
        UpdateProgress(99)
      else
        ShowMessage('Warning: Could not delete bin folder');
    end;

    // 11. Get FakeNvapi version and download
    WriteLn('[DEBUG] UpdateButtonClick: Step 11 - Getting FakeNvapi version...');
    FakeNvapiVersion := GetFakeNvapiReleaseTag;

    if FakeNvapiVersion <> '' then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: FakeNvapiVersion = "', FakeNvapiVersion, '"');

      // Update FakeNvapiLabel with the version (with safety check)
      if Assigned(FFakeNvapiLabel) then
      begin
        try
          FFakeNvapiLabel.Caption := FakeNvapiVersion;
          FFakeNvapiLabel.Font.Color := clOlive;
          Application.ProcessMessages;
        except
          on E: Exception do
          begin
            WriteLn('[ERROR] UpdateButtonClick: Could not update FakeNvapi label - ', E.Message);
            ShowMessage('Warning: Could not update FakeNvapi label: ' + E.Message);
          end;
        end;
      end;

      // Build FakeNvapi download URL - format: fakenvapi-v1.3.4.7z
      FakeNvapiURL := Format('https://github.com/optiscaler/fakenvapi/releases/download/%s/fakenvapi-%s.7z', [FakeNvapiVersion, FakeNvapiVersion]);
      FakeNvapi7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-' + FakeNvapiVersion + '.7z';
      WriteLn('[DEBUG] UpdateButtonClick: FakeNvapi URL = ', FakeNvapiURL);
      WriteLn('[DEBUG] UpdateButtonClick: FakeNvapi 7z path = ', FakeNvapi7zPath);

      // Download FakeNvapi .7z
      UpdateProgress(99);
      UpdateStatus('Downloading FakeNvapi');
      WriteLn('[DEBUG] UpdateButtonClick: Downloading FakeNvapi...');
      if DownloadFile(FakeNvapiURL, FakeNvapi7zPath) then
      begin
        WriteLn('[DEBUG] UpdateButtonClick: FakeNvapi download successful');
        UpdateStatus('Installing');
        // Extract FakeNvapi .7z to fgmod folder
        WriteLn('[DEBUG] UpdateButtonClick: Extracting FakeNvapi to ', FFGModPath);
        if Extract7z(FakeNvapi7zPath, FFGModPath) then
        begin
          WriteLn('[DEBUG] UpdateButtonClick: FakeNvapi extraction successful');
          UpdateProgress(100);
          // Delete temporary .7z file
          DeleteFile(FakeNvapi7zPath);
          WriteLn('[DEBUG] UpdateButtonClick: Deleted temporary FakeNvapi .7z file');
        end
        else
        begin
          WriteLn('[ERROR] UpdateButtonClick: FakeNvapi extraction failed');
          ShowMessage('Warning: Failed to extract FakeNvapi 7z file.');
          DeleteFile(FakeNvapi7zPath);
        end;
      end
      else
      begin
        WriteLn('[ERROR] UpdateButtonClick: FakeNvapi download failed');
        ShowMessage('Warning: Failed to download FakeNvapi.');
      end;
    end
    else
    begin
      WriteLn('[WARN] UpdateButtonClick: No FakeNvapi version obtained, skipping');
      UpdateProgress(100);
    end;

    // Clean up temporary files
    WriteLn('[DEBUG] UpdateButtonClick: Cleaning up temporary files...');
    DeleteFile(ZipFilePath);
    DeleteDirectory(ExtractPath, False);
    WriteLn('[DEBUG] UpdateButtonClick: Cleanup complete');

    // 12. Create goverlay.vars file with version information
    WriteLn('[DEBUG] UpdateButtonClick: Step 12 - Creating goverlay.vars file...');
    try
      VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';
      WriteLn('[DEBUG] UpdateButtonClick: goverlay.vars path = ', VarsFilePath);
      AssignFile(VarsFile, VarsFilePath);
      Rewrite(VarsFile);

      // Write header
      WriteLn(VarsFile, '################### File Generated by Goverlay ###################');

      // Write generation date and time
      WriteLn(VarsFile, 'GeneratedAt=' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));

      // Write version variables
      if DeckyVersion <> '' then
        WriteLn(VarsFile, 'DeckyVersion=' + DeckyVersion);

      if OptiVersion <> '' then
        WriteLn(VarsFile, 'OptiScalerVersion=' + OptiVersion);

      if FakeNvapiVersion <> '' then
        WriteLn(VarsFile, 'FakeNvapiVersion=' + FakeNvapiVersion);

      CloseFile(VarsFile);
      WriteLn('[DEBUG] UpdateButtonClick: goverlay.vars created successfully');
    except
      on E: Exception do
      begin
        WriteLn('[ERROR] UpdateButtonClick: Could not create goverlay.vars - ', E.Message);
        ShowMessage('Warning: Could not create goverlay.vars: ' + E.Message);
      end;
    end;

    UpdateProgress(100);

    // Create FSR4_LATEST and FSR4_INT8 folders and setup files
    WriteLn('[DEBUG] UpdateButtonClick: Setting up FSR4 variants...');
    try
      UpdateStatus('Setting up FSR4 variants');

      // Create FSR4_LATEST folder
      ForceDirectories(IncludeTrailingPathDelimiter(FFGModPath) + 'FSR4_LATEST');

      // Copy amd_fidelityfx_upscaler_dx12.dll to FSR4_LATEST
      if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'amd_fidelityfx_upscaler_dx12.dll') then
      begin
        CopyFile(IncludeTrailingPathDelimiter(FFGModPath) + 'amd_fidelityfx_upscaler_dx12.dll',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll');
      end;

      // Create FSR4_INT8 folder
      ForceDirectories(IncludeTrailingPathDelimiter(FFGModPath) + 'FSR4_INT8');

      // Download INT8 version to FSR4_INT8 folder
      if DownloadFile('https://github.com/xXJSONDeruloXx/OptiScaler-Bleeding-Edge/releases/download/amd-fsr-r-int8/amd_fidelityfx_upscaler_dx12.dll',
                      IncludeTrailingPathDelimiter(FFGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
      begin
        UpdateStatus('FSR4 variants ready');
      end
      else
        ShowMessage('Warning: Failed to download FSR4 INT8 variant.');
    except
      on E: Exception do
        ShowMessage('Warning: Could not setup FSR4 variants: ' + E.Message);
    end;

    UpdateStatus('Complete');

    WriteLn('[DEBUG] ========================================');
    WriteLn('[DEBUG] UpdateButtonClick: Installation completed successfully!');
    WriteLn('[DEBUG] ========================================');

    // Restore button text after completion
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Caption := 'Update';

    // 13. Update xessLabel1 and fsrlabel1 with text "decky built-in"
    if Assigned(FXessLabel) then
    begin
      try
        FXessLabel.Caption := 'decky built-in';
        FXessLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        on E: Exception do
          ShowMessage('Warning: Could not update Xess label: ' + E.Message);
      end;
    end;

    if Assigned(FFsrLabel) then
    begin
      try
        FFsrLabel.Caption := 'decky built-in';
        FFsrLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        on E: Exception do
          ShowMessage('Warning: Could not update Fsr label: ' + E.Message);
      end;
    end;

    // 14. Hide update notification labels after successful installation
    if Assigned(FDeckyLabel2) then
      FDeckyLabel2.Visible := False;

    if Assigned(FFakeNvapiLabel2) then
      FFakeNvapiLabel2.Visible := False;

    // 15. Update version labels with newly installed versions
    if Assigned(FDeckyLabel) and (DeckyVersion <> '') then
    begin
      try
        FDeckyLabel.Caption := DeckyVersion;
        FDeckyLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    if Assigned(FFakeNvapiLabel) and (FakeNvapiVersion <> '') then
    begin
      try
        FFakeNvapiLabel.Caption := FakeNvapiVersion;
        FFakeNvapiLabel.Font.Color := clOlive;
        Application.ProcessMessages;
      except
        // Ignore errors
      end;
    end;

    // 16. Show checkupdBitBtn again
    if Assigned(FCheckupdBtn) then
      FCheckupdBtn.Visible := True;

    // 17. Hide updateBitBtn after successful installation
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Visible := False;


  finally
    // Re-enable button
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Enabled := True;
    UpdateProgress(0);
    UpdateStatus('');
  end;
end;

end.
