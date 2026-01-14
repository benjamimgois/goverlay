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
    FOptiLabel2: TLabel;       // Label for OptiScaler update notification
    FFakeNvapiLabel: TLabel;
    FXessLabel: TLabel;
    FFsrLabel: TLabel;
    FDeckyLabel2: TLabel;      // Label for update notification
    FFakeNvapiLabel2: TLabel;  // Label for update notification
    FNotificationLabel: TLabel; // Label for general notifications
    FFsrVersionComboBox: TComboBox; // ComboBox for FSR version selection
    FOptVersionComboBox: TComboBox; // ComboBox for OptiScaler channel selection
    FFGModPath: string;

    function GetLatestReleaseTag: string;
    function GetOptiScalerStableTag: string;
    function GetOptiScalerPreReleaseTag: string;
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
    property OptiLabel2: TLabel read FOptiLabel2 write FOptiLabel2;
    property FakeNvapiLabel: TLabel read FFakeNvapiLabel write FFakeNvapiLabel;
    property XessLabel: TLabel read FXessLabel write FXessLabel;
    property FsrLabel: TLabel read FFsrLabel write FFsrLabel;
    property DeckyLabel2: TLabel read FDeckyLabel2 write FDeckyLabel2;
    property FakeNvapiLabel2: TLabel read FFakeNvapiLabel2 write FFakeNvapiLabel2;
    property NotificationLabel: TLabel read FNotificationLabel write FNotificationLabel;
    property FsrVersionComboBox: TComboBox read FFsrVersionComboBox write FFsrVersionComboBox;
    property OptVersionComboBox: TComboBox read FOptVersionComboBox write FOptVersionComboBox;
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
  UserDir, UserName: string;
begin
  // Check if running in Flatpak
  if IsRunningInFlatpak then
  begin
    // Try to get the real user name
    UserName := GetEnvironmentVariable('USER');
    if UserName <> '' then
    begin
      // Use the Flatpak sandbox path for fgmod (security compliant)
      Result := '/home/' + UserName + '/.var/app/io.github.benjamimgois.goverlay/fgmod';
      Exit;
    end;
  end;

  UserDir := GetUserDir;

  // Native installation uses ~/fgmod
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
        ShowMessage('Error getting latest release: ' + E.Message + sLineBreak +
                   'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.GetOptiScalerStableTag: string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  i: Integer;
  TagName: string;
  RegEx: TRegExpr;
begin
  Result := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  RegEx := TRegExpr.Create;
  try
    try
      WriteLn('[DEBUG] GetOptiScalerStableTag: Fetching from ', URL_OPTISCALER_BUILDS_API);

      // Use curl to get GitHub API for OptiScaler-builds tags
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add(URL_OPTISCALER_BUILDS_API);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      WriteLn('[DEBUG] GetOptiScalerStableTag: Curl exit status: ', Process.ExitStatus);
      WriteLn('[DEBUG] GetOptiScalerStableTag: Response length: ', Length(Response), ' bytes');

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        WriteLn('[DEBUG] GetOptiScalerStableTag: Parsing JSON response...');

        // Validate response is JSON before parsing (to handle GitHub API errors/rate limiting)
        if (Length(Response) > 0) and ((Response[1] = '{') or (Response[1] = '[')) then
        begin
          JSONData := GetJSON(Response);
          try
            if Assigned(JSONData) and (JSONData is TJSONArray) then
            begin
            WriteLn('[DEBUG] GetOptiScalerStableTag: Valid JSON array received');
            JSONArray := TJSONArray(JSONData);

            if JSONArray.Count > 0 then
            begin
              WriteLn('[DEBUG] GetOptiScalerStableTag: Array has ', JSONArray.Count, ' tags');

              // First pass: Look for patched versions with -N suffix (e.g., 0.7.9-2)
              // These should take priority over non-patched versions
              RegEx.Expression := '^\d+\.\d+\.\d+-\d+$';

              for i := 0 to JSONArray.Count - 1 do
              begin
                JSONObject := TJSONObject(JSONArray[i]);
                TagName := JSONObject.Get('name', '');

                WriteLn('[DEBUG] GetOptiScalerStableTag: Checking tag[', i, '] = "', TagName, '" (looking for patched version)');

                // Check if tag matches patched semantic version pattern
                if RegEx.Exec(TagName) then
                begin
                  Result := TagName;
                  WriteLn('[DEBUG] GetOptiScalerStableTag: Found patched stable version tag = "', Result, '"');
                  Break;
                end;
              end;

              // Second pass: If no patched version found, look for regular semantic versions
              if Result = '' then
              begin
                WriteLn('[DEBUG] GetOptiScalerStableTag: No patched version found, looking for regular semantic version...');
                RegEx.Expression := '^\d+\.\d+\.\d+$';

                for i := 0 to JSONArray.Count - 1 do
                begin
                  JSONObject := TJSONObject(JSONArray[i]);
                  TagName := JSONObject.Get('name', '');

                  WriteLn('[DEBUG] GetOptiScalerStableTag: Checking tag[', i, '] = "', TagName, '"');

                  // Check if tag matches semantic version pattern (stable release)
                  if RegEx.Exec(TagName) then
                  begin
                    Result := TagName;
                    WriteLn('[DEBUG] GetOptiScalerStableTag: Found stable version tag = "', Result, '"');
                    Break;
                  end
                  else
                    WriteLn('[DEBUG] GetOptiScalerStableTag: Tag "', TagName, '" is not a stable version (pre-release), skipping');
                end;
              end;

              if Result = '' then
                WriteLn('[ERROR] GetOptiScalerStableTag: No stable version tag found in the array');
            end
            else
              WriteLn('[ERROR] GetOptiScalerStableTag: JSON array is empty');
          end
          else
            WriteLn('[ERROR] GetOptiScalerStableTag: JSON data is not an array');
        finally
          JSONData.Free;
        end;
        end
        else
        begin
          WriteLn('[ERROR] GetOptiScalerStableTag: API returned non-JSON response (possibly rate limited or error)');
          WriteLn('[ERROR] GetOptiScalerStableTag: Response preview: ', Copy(Response, 1, 200));
        end;
      end
      else
      begin
        WriteLn('[ERROR] GetOptiScalerStableTag: Failed to get response (exit: ', Process.ExitStatus, ', response empty: ', Response = '', ')');
        if Response <> '' then
          WriteLn('[ERROR] GetOptiScalerStableTag: Response content: ', Copy(Response, 1, 200));
      end;

    except
      on E: Exception do
      begin
        WriteLn('[ERROR] GetOptiScalerStableTag: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Error getting OptiScaler version: ' + E.Message + sLineBreak +
                   'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    RegEx.Free;
    OutputList.Free;
    Process.Free;
  end;
end;

function TOptiscalerTab.GetOptiScalerPreReleaseTag: string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  i: Integer;
  TagName: string;
  RegEx: TRegExpr;
begin
  Result := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  RegEx := TRegExpr.Create;
  try
    try
      WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Fetching from ', URL_OPTISCALER_BUILDS_API);

      // Use curl to get GitHub API for OptiScaler-builds tags
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add(URL_OPTISCALER_BUILDS_API);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Curl exit status: ', Process.ExitStatus);
      WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Response length: ', Length(Response), ' bytes');

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Parsing JSON response...');

        // Validate response is JSON before parsing (to handle GitHub API errors/rate limiting)
        if (Length(Response) > 0) and ((Response[1] = '{') or (Response[1] = '[')) then
        begin
          JSONData := GetJSON(Response);
          try
            if Assigned(JSONData) and (JSONData is TJSONArray) then
            begin
            WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Valid JSON array received');
            JSONArray := TJSONArray(JSONData);

            if JSONArray.Count > 0 then
            begin
              WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Array has ', JSONArray.Count, ' tags');

              // Look for tags starting with "edge-" (GitHub API returns them in reverse chronological order)
              // The first edge- tag we find will be the most recent
              RegEx.Expression := '^edge-';

              for i := 0 to JSONArray.Count - 1 do
              begin
                JSONObject := TJSONObject(JSONArray[i]);
                TagName := JSONObject.Get('name', '');

                WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Checking tag[', i, '] = "', TagName, '"');

                // Check if tag starts with "edge-"
                if RegEx.Exec(TagName) then
                begin
                  Result := TagName;
                  WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Found pre-release tag = "', Result, '"');
                  Break;
                end
                else
                  WriteLn('[DEBUG] GetOptiScalerPreReleaseTag: Tag "', TagName, '" does not start with "edge-", skipping');
              end;

              if Result = '' then
                WriteLn('[ERROR] GetOptiScalerPreReleaseTag: No pre-release tag found in the array');
            end
            else
              WriteLn('[ERROR] GetOptiScalerPreReleaseTag: JSON array is empty');
          end
          else
            WriteLn('[ERROR] GetOptiScalerPreReleaseTag: JSON data is not an array');
        finally
          JSONData.Free;
        end;
        end
        else
        begin
          WriteLn('[ERROR] GetOptiScalerPreReleaseTag: API returned non-JSON response (possibly rate limited or error)');
          WriteLn('[ERROR] GetOptiScalerPreReleaseTag: Response preview: ', Copy(Response, 1, 200));
        end;
      end
      else
      begin
        WriteLn('[ERROR] GetOptiScalerPreReleaseTag: Failed to get response (exit: ', Process.ExitStatus, ', response empty: ', Response = '', ')');
        if Response <> '' then
          WriteLn('[ERROR] GetOptiScalerPreReleaseTag: Response content: ', Copy(Response, 1, 200));
      end;

    except
      on E: Exception do
      begin
        WriteLn('[ERROR] GetOptiScalerPreReleaseTag: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage('Error getting OptiScaler pre-release version: ' + E.Message + sLineBreak +
                   'Check your internet connection and if curl is installed.');
      end;
    end;
  finally
    RegEx.Free;
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

      Process.Executable := '7z';
      Process.Parameters.Add('x');
      Process.Parameters.Add('-y');  // Yes to all questions
      Process.Parameters.Add('-o' + ADestPath);
      
      // Exclude fgmod files if they already exist (to preserve user's configuration)
      // Future versions of OptiScaler won't include fgmod files in the 7z archive
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


procedure TOptiscalerTab.LoadVersionsFromFile;
var
  VarsFilePath: string;
  VarsFile: TextFile;
  Line: string;
  Key, Value: string;
  SepPos: Integer;
  DeckyVer, OptiVer, FakeNvapiVer, FsrVer, XessVer: string;
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
  XessVer := '';

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
            XessVer := Value;
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

    // Update XESS label
    if Assigned(FXessLabel) then
    begin
      try
        // If xessversion was found in goverlay.vars, use that value
        // Otherwise, use the default 'built in'
        if XessVer <> '' then
          FXessLabel.Caption := XessVer
        else
          FXessLabel.Caption := 'built in';
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
        // Otherwise, use the default 'built in'
        if FsrVer <> '' then
        begin
          FFsrLabel.Caption := FsrVer;

          // If the version is '4.0.2 (INT8)', set combobox to index 1
          if Assigned(FFsrVersionComboBox) and (FsrVer = '4.0.2 (INT8)') then
            FFsrVersionComboBox.ItemIndex := 1;
        end
        else
          FFsrLabel.Caption := 'built in';
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
  CurrentVersion, LatestTag: string;
  IsStableChannel: Boolean;
begin
  HasUpdates := False;

  // Hide labels before checking
  if Assigned(FDeckyLabel2) then
    FDeckyLabel2.Visible := False;

  if Assigned(FOptiLabel2) then
    FOptiLabel2.Visible := False;

  // Hide notification label initially
  if Assigned(FNotificationLabel) then
    FNotificationLabel.Visible := False;

  // Determine channel based on ComboBox selection
  IsStableChannel := True;  // Default to stable
  if Assigned(FOptVersionComboBox) then
  begin
    if FOptVersionComboBox.ItemIndex = 0 then
      IsStableChannel := True
    else if FOptVersionComboBox.ItemIndex = 1 then
      IsStableChannel := False;
  end;

  // Always use ~/fgmod path
  FFGModPath := GetOptiScalerInstallPath;
  WriteLn('[DEBUG] CheckForUpdatesOnClick: Using path = ', FFGModPath);

  // Load versions from goverlay.vars if it exists
  if DirectoryExists(FFGModPath) then
  begin
    WriteLn('[DEBUG] CheckForUpdatesOnClick: Directory exists, loading versions from file...');
    LoadVersionsFromFile;
  end;

  // Check for OptiScaler updates based on selected channel
  if Assigned(FOptiLabel2) then
  begin
    // Check if fgmod exists
    if DirectoryExists(FFGModPath) then
    begin
      if Assigned(FOptiLabel) then
        CurrentVersion := FOptiLabel.Caption
      else
        CurrentVersion := '';

      // Get latest version based on selected channel
      if IsStableChannel then
      begin
        WriteLn('[DEBUG] CheckForUpdatesOnClick: Checking Stable channel updates...');
        LatestTag := GetOptiScalerStableTag;
      end
      else
      begin
        WriteLn('[DEBUG] CheckForUpdatesOnClick: Checking Bleeding-Edge channel updates...');
        LatestTag := GetOptiScalerPreReleaseTag;
      end;
    end
    else
    begin
      CurrentVersion := '';
      LatestTag := '';
    end;

    WriteLn('[DEBUG] CheckForUpdatesOnClick: Current OptiScaler version = "', CurrentVersion, '"');
    WriteLn('[DEBUG] CheckForUpdatesOnClick: Latest OptiScaler tag = "', LatestTag, '"');

    // Show update if tag is available and different from current
    if (LatestTag <> '') and (LatestTag <> CurrentVersion) then
    begin
      FOptiLabel2.Caption := 'Update Available ' + LatestTag;
      FOptiLabel2.Font.Color := clLime;
      FOptiLabel2.Visible := True;
      HasUpdates := True;
      WriteLn('[DEBUG] CheckForUpdatesOnClick: OptiScaler update available: ', LatestTag);
    end
    else
      WriteLn('[DEBUG] CheckForUpdatesOnClick: OptiScaler is up to date');
  end;

  // Check for Decky updates only if fgmod exists
  if DirectoryExists(FFGModPath) then
    CheckForUpdates;

  // Check if any update label is visible
  if Assigned(FDeckyLabel2) and FDeckyLabel2.Visible then
    HasUpdates := True;

  if Assigned(FOptiLabel2) and FOptiLabel2.Visible then
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

    // Detect if bleeding-edge version is installed
    if Assigned(FOptiLabel) then
    begin
      CurrentVersion := FOptiLabel.Caption;
      WriteLn('[DEBUG] InitializeTab: Current OptiScaler version = "', CurrentVersion, '"');

      // If version starts with "edge-", select bleeding-edge in ComboBox
      if (Length(CurrentVersion) > 5) and (Copy(CurrentVersion, 1, 5) = 'edge-') then
      begin
        if Assigned(FOptVersionComboBox) then
        begin
          FOptVersionComboBox.ItemIndex := 1;  // Select bleeding-edge
          WriteLn('[DEBUG] InitializeTab: Detected bleeding-edge version, set ComboBox to index 1');
        end;
      end
      else
      begin
        // Stable version
        if Assigned(FOptVersionComboBox) then
        begin
          FOptVersionComboBox.ItemIndex := 0;  // Select stable
          WriteLn('[DEBUG] InitializeTab: Detected stable version, set ComboBox to index 0');
        end;
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
begin
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

    // STEP 1: Always use ~/fgmod/ directory
    WriteLn('[DEBUG] UpdateButtonClick: Step 1 - Preparing fgmod directory...');
    FFGModPath := GetOptiScalerInstallPath;
    WriteLn('[DEBUG] UpdateButtonClick: fgmod path = ', FFGModPath);

    // Backup fgmod files before cleaning directory (to preserve user's configuration)
    // We backup: fgmod, fgmod-remover.sh, fgmod-uninstaller.sh
    FGModFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod';
    FGModBackupPath := IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod.backup';
    FGModBackupExists := False;
    
    // Backup main fgmod script
    if FileExists(FGModFilePath) then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Backing up fgmod file to preserve user configuration...');
      try
        if CopyFile(FGModFilePath, FGModBackupPath) then
        begin
          FGModBackupExists := True;
          WriteLn('[DEBUG] UpdateButtonClick: fgmod file backed up to: ', FGModBackupPath);
        end
        else
          WriteLn('[WARN] UpdateButtonClick: Failed to backup fgmod file');
      except
        on E: Exception do
          WriteLn('[WARN] UpdateButtonClick: Exception backing up fgmod: ', E.Message);
      end;
    end;
    
    // Backup fgmod-remover.sh
    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-remover.sh') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Backing up fgmod-remover.sh...');
      CopyFile(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-remover.sh',
               IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-remover.sh.backup');
    end;
    
    // Backup fgmod-uninstaller.sh
    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-uninstaller.sh') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Backing up fgmod-uninstaller.sh...');
      CopyFile(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-uninstaller.sh',
               IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-uninstaller.sh.backup');
    end;

    // If directory exists, delete all contents to ensure clean installation
    if DirectoryExists(FFGModPath) then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: fgmod directory exists, deleting contents for clean install...');
      try
        DeleteDirectory(FFGModPath, False);
        WriteLn('[DEBUG] UpdateButtonClick: Directory contents deleted successfully');
      except
        on E: Exception do
        begin
          WriteLn('[ERROR] UpdateButtonClick: Failed to delete directory contents: ', E.Message);
          ShowMessage('Error: Could not clean fgmod directory.' + sLineBreak + E.Message);
          Exit;
        end;
      end;
    end;

    // Create fresh directory
    WriteLn('[DEBUG] UpdateButtonClick: Creating fresh fgmod directory...');
    ForceDirectories(FFGModPath);

    // Restore fgmod files if they were backed up
    if FGModBackupExists then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Restoring fgmod file from backup...');
      try
        if CopyFile(FGModBackupPath, FGModFilePath) then
        begin
          // Make fgmod executable
          fpChmod(FGModFilePath, &755);
          WriteLn('[DEBUG] UpdateButtonClick: fgmod file restored and made executable');
        end
        else
          WriteLn('[WARN] UpdateButtonClick: Failed to restore fgmod file');
        // Delete backup file
        DeleteFile(FGModBackupPath);
      except
        on E: Exception do
          WriteLn('[WARN] UpdateButtonClick: Exception restoring fgmod: ', E.Message);
      end;
    end;
    
    // Restore fgmod-remover.sh if it was backed up
    if FileExists(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-remover.sh.backup') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Restoring fgmod-remover.sh from backup...');
      CopyFile(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-remover.sh.backup',
               IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-remover.sh');
      fpChmod(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-remover.sh', &755);
      DeleteFile(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-remover.sh.backup');
    end;
    
    // Restore fgmod-uninstaller.sh if it was backed up
    if FileExists(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-uninstaller.sh.backup') then
    begin
      WriteLn('[DEBUG] UpdateButtonClick: Restoring fgmod-uninstaller.sh from backup...');
      CopyFile(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-uninstaller.sh.backup',
               IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-uninstaller.sh');
      fpChmod(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod-uninstaller.sh', &755);
      DeleteFile(IncludeTrailingPathDelimiter(GetTempDir) + 'fgmod-uninstaller.sh.backup');
    end;

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
      ShowMessage('Could not get OptiScaler version for download.' + sLineBreak +
                 'Operation cancelled.');
      Exit;
    end;

    UpdateProgress(20);
    UpdateStatus('Downloading');

    // Build download URL for .7z file
    if IsStableChannel then
    begin
      // URL format: https://github.com/benjamimgois/OptiScaler-builds/releases/download/{tag}/optiscaler-stable.7z
      // Note: The stable release always uses the fixed filename "optiscaler-stable.7z"
      DownloadURL := Format('https://github.com/benjamimgois/OptiScaler-builds/releases/download/%s/optiscaler-stable.7z', [OptiScalerTag]);
      SevenZFilePath := IncludeTrailingPathDelimiter(UserDir) + 'optiscaler-stable.7z';
    end
    else
    begin
      // URL format: https://github.com/benjamimgois/OptiScaler-builds/releases/download/{tag}/optiscaler-edge.7z
      // Note: The bleeding-edge release always uses the fixed filename "optiscaler-edge.7z"
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
      ShowMessage('Failed to download OptiScaler file.');
      Exit;
    end;

    WriteLn('[DEBUG] UpdateButtonClick: Download completed successfully');
    UpdateProgress(50);
    UpdateStatus('Installing');

    // STEP 3: Extract .7z file directly to fgmod folder
    WriteLn('[DEBUG] UpdateButtonClick: Step 3 - Extracting .7z file to fgmod...');
    if not Extract7z(SevenZFilePath, FFGModPath) then
    begin
      WriteLn('[ERROR] UpdateButtonClick: 7z extraction failed, aborting');
      ShowMessage('Failed to extract .7z file.');
      Exit;
    end;

    WriteLn('[DEBUG] UpdateButtonClick: Extraction completed successfully');
    UpdateProgress(70);

    // STEP 4: Make fgmod.sh executable
    WriteLn('[DEBUG] UpdateButtonClick: Step 4 - Making fgmod.sh executable...');
    if FileExists(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod.sh') then
    begin
      // Rename fgmod.sh to fgmod
      RenameFile(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod.sh',
                 IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod');

      // Make fgmod executable (chmod 755)
      fpChmod(IncludeTrailingPathDelimiter(FFGModPath) + 'fgmod', &755);
      WriteLn('[DEBUG] UpdateButtonClick: fgmod is now executable');
    end
    else
      WriteLn('[WARN] UpdateButtonClick: fgmod.sh not found');

    UpdateProgress(80);

    // STEP 5: Read goverlay.vars and update all labels
    WriteLn('[DEBUG] UpdateButtonClick: Step 5 - Reading goverlay.vars file...');
    VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars';

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

    ShowMessage('OptiScaler installation completed successfully!');

  finally
    // Re-enable button
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Enabled := True;
    UpdateProgress(0);
    UpdateStatus('');
  end;
end;

end.
