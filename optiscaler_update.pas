unit Optiscaler_Update;

interface

uses
  Classes, SysUtils, Forms, ComCtrls, Buttons, Process,
  RegExpr, fpjson, jsonparser, zipper, Dialogs, StdCtrls, Graphics, DateUtils;

type
  TOptiscalerTab = class
  private
    FUpdateBtn: TBitBtn;
    FProgressBar: TProgressBar;
    FStatusLabel: TLabel;
    FDeckyLabel: TLabel;
    FOptiLabel: TLabel;
    FFakeNvapiLabel: TLabel;
    FXessLabel: TLabel;
    FFsrLabel: TLabel;
    FFGModPath: string;

    function GetLatestReleaseTag: string;
    function GetFakeNvapiReleaseTag: string;
    function DownloadFile(const AURL, ADestFile: string): Boolean;
    function ExtractZip(const AZipFile, ADestPath: string): Boolean;
    function Extract7z(const A7zFile, ADestPath: string): Boolean;
    procedure CopyDirectory(const ASource, ADest: string);
    procedure UpdateProgress(AProgress: Integer);
    function ExtractOptiScalerVersion(const AFileName: string): string;
  public
    procedure UpdateButtonClick(Sender: TObject);
    property UpdateBtn: TBitBtn read FUpdateBtn write FUpdateBtn;
    property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
    property StatusLabel: TLabel read FStatusLabel write FStatusLabel;
    property DeckyLabel: TLabel read FDeckyLabel write FDeckyLabel;
    property OptiLabel: TLabel read FOptiLabel write FOptiLabel;
    property FakeNvapiLabel: TLabel read FFakeNvapiLabel write FFakeNvapiLabel;
    property XessLabel: TLabel read FXessLabel write FXessLabel;
    property FsrLabel: TLabel read FFsrLabel write FFsrLabel;
  end;

implementation

uses
  FileUtil, LazFileUtils, BaseUnix;

{ TOptiscalerTab }

procedure TOptiscalerTab.UpdateProgress(AProgress: Integer);
begin
  if Assigned(FProgressBar) then
  begin
    FProgressBar.Position := AProgress;
    Application.ProcessMessages;
  end;

  if Assigned(FStatusLabel) then
  begin
    FStatusLabel.Caption := IntToStr(AProgress) + '%';
    Application.ProcessMessages;
  end;
end;

function TOptiscalerTab.ExtractOptiScalerVersion(const AFileName: string): string;
var
  BaseName: string;
  RegEx: TRegExpr;
begin
  Result := '';

  // Get filename without path and extension
  BaseName := ChangeFileExt(ExtractFileName(AFileName), '');

  // Use regex to extract version pattern (numbers separated by dots)
  // Pattern: OptiScaler_X.X.X or similar
  RegEx := TRegExpr.Create;
  try
    // Match pattern like: 0.7.9 or 1.2.3.4
    RegEx.Expression := '(\d+\.\d+\.\d+(?:\.\d+)?)';

    if RegEx.Exec(BaseName) then
    begin
      Result := RegEx.Match[1];
    end;
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
      // Use curl to get GitHub API
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add('https://api.github.com/repos/xXJSONDeruloXx/Decky-Framegen/releases/latest');
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONObject) then
          begin
            JSONObject := TJSONObject(JSONData);
            Result := JSONObject.Get('tag_name', '');
          end;
        finally
          JSONData.Free;
        end;
      end;


    except
      on E: Exception do
      begin
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
      // Use curl to get GitHub API for FakeNvapi
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add('https://api.github.com/repos/optiscaler/fakenvapi/releases/latest');
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONObject) then
          begin
            JSONObject := TJSONObject(JSONData);
            Result := JSONObject.Get('tag_name', '');
          end;
        finally
          JSONData.Free;
        end;
      end;

      // If unable to get, show warning
      if Result = '' then
      begin
        ShowMessage('Warning: Could not get FakeNvapi version automatically.' + sLineBreak +
                   'Continuing without FakeNvapi installation.');
      end;

    except
      on E: Exception do
      begin
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
  OutputLine: string;
  OutputList: TStringList;
  ProgressRegex: TRegExpr;
  PercentStr: string;
  PercentValue: Integer;
begin
  Result := False;
  OutputLine := '';  // Initialize
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  ProgressRegex := TRegExpr.Create;
  try
    try
      // Configure wget to show progress
      Process.Executable := 'wget';
      Process.Parameters.Add('--progress=bar:force');
      Process.Parameters.Add('-O');
      Process.Parameters.Add(ADestFile);
      Process.Parameters.Add(AURL);
      Process.Options := [poUsePipes, poStderrToOutPut];
      Process.Execute;

      // Regex to capture wget percentage
      // Format: 10% [=====>     ] 1,234,567   123KB/s
      ProgressRegex.Expression := '(\d+)%';

      // Read progress in real time
      while Process.Running do
      begin
        if Process.Output.NumBytesAvailable > 0 then
        begin
          SetLength(OutputLine, Process.Output.NumBytesAvailable);
          Process.Output.Read(OutputLine[1], Length(OutputLine));

          // Try to extract percentage
          if ProgressRegex.Exec(OutputLine) then
          begin
            PercentStr := ProgressRegex.Match[1];
            if TryStrToInt(PercentStr, PercentValue) then
            begin
              // Map 0-100% of wget to 10-50% of total progress
              UpdateProgress(10 + Round((PercentValue / 100) * 40));
            end;
          end;
        end;
        Sleep(100);
        Application.ProcessMessages;
      end;

      // Read any remaining output
      while Process.Output.NumBytesAvailable > 0 do
      begin
        SetLength(OutputLine, Process.Output.NumBytesAvailable);
        Process.Output.Read(OutputLine[1], Length(OutputLine));
      end;

      Process.WaitOnExit;
      Result := (Process.ExitStatus = 0) and FileExists(ADestFile);

      if not Result then
        ShowMessage('Error downloading file via wget. Exit code: ' + IntToStr(Process.ExitStatus));

    except
      on E: Exception do
        ShowMessage('Error executing wget: ' + E.Message + sLineBreak +
                   'Make sure wget is installed: sudo apt-get install wget');
    end;
  finally
    ProgressRegex.Free;
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
  // Disable button
  if Assigned(FUpdateBtn) then
    FUpdateBtn.Enabled := False;

  try
    UpdateProgress(0);

    // Get user directory at the beginning
    UserDir := GetUserDir;

    // 1. Get the latest tag from repository and store in variable
    LatestTag := GetLatestReleaseTag;
    if LatestTag = '' then
    begin
      ShowMessage('Could not get version for download.' + sLineBreak +
                 'Operation cancelled.');
      Exit;
    end;

    // Store version in DeckyVersion variable
    DeckyVersion := LatestTag;

    // Update DeckyLabel with the version (with safety check)
    if Assigned(FDeckyLabel) then
    begin
      try
        FDeckyLabel.Caption := DeckyVersion;
        FDeckyLabel.Font.Color := clYellow;
        Application.ProcessMessages;
      except
        on E: Exception do
          ShowMessage('Warning: Could not update Decky label: ' + E.Message);
      end;
    end;

    ShowMessage('Version to be downloaded: ' + LatestTag);
    UpdateProgress(10);

    // 2. Build download URL
    DownloadURL := Format('https://github.com/xXJSONDeruloXx/Decky-Framegen/releases/download/%s/Decky-Framegen.zip', [LatestTag]);
    ZipFilePath := IncludeTrailingPathDelimiter(UserDir) + 'Decky-Framegen.zip';

    // 3. Download file to user's home
    if not DownloadFile(DownloadURL, ZipFilePath) then
    begin
      ShowMessage('Failed to download file.');
      Exit;
    end;
    UpdateProgress(50);

    // 4. Extract ZIP directly to user's home
    // The ZIP already contains a folder called Decky-Framegen
    if not ExtractZip(ZipFilePath, UserDir) then
    begin
      ShowMessage('Failed to extract ZIP file.');
      Exit;
    end;
    UpdateProgress(60);

    // 5. Create fgmod folder in user's home
    ExtractPath := IncludeTrailingPathDelimiter(UserDir) + 'Decky-Framegen';
    FFGModPath := IncludeTrailingPathDelimiter(UserDir) + 'fgmod';

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
    SevenZFile := '';
    if FindFirst(IncludeTrailingPathDelimiter(FFGModPath) + 'bin' + PathDelim + '*.7z', faAnyFile, SearchRec) = 0 then
    begin
      try
        SevenZFile := IncludeTrailingPathDelimiter(FFGModPath) + 'bin' + PathDelim + SearchRec.Name;

        // Extract OptiScaler version from filename
        OptiVersion := ExtractOptiScalerVersion(SearchRec.Name);

        // Update OptiLabel with the version (with safety check)
        if Assigned(FOptiLabel) and (OptiVersion <> '') then
        begin
          try
            FOptiLabel.Caption := OptiVersion;
            FOptiLabel.Font.Color := clYellow;
            Application.ProcessMessages;
          except
            on E: Exception do
              ShowMessage('Warning: Could not update OptiScaler label: ' + E.Message);
          end;
        end;

      finally
        FindClose(SearchRec);
      end;
    end;

    if SevenZFile <> '' then
    begin
      if Extract7z(SevenZFile, FFGModPath) then
        UpdateProgress(90)
      else
        ShowMessage('Failed to extract 7z file.');
    end
    else
      ShowMessage('.7z file not found in bin folder!');

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
    FakeNvapiVersion := GetFakeNvapiReleaseTag;

    if FakeNvapiVersion <> '' then
    begin
      // Update FakeNvapiLabel with the version (with safety check)
      if Assigned(FFakeNvapiLabel) then
      begin
        try
          FFakeNvapiLabel.Caption := FakeNvapiVersion;
          FFakeNvapiLabel.Font.Color := clYellow;
          Application.ProcessMessages;
        except
          on E: Exception do
            ShowMessage('Warning: Could not update FakeNvapi label: ' + E.Message);
        end;
      end;

      // Build FakeNvapi download URL - format: fakenvapi-v1.3.4.7z
      FakeNvapiURL := Format('https://github.com/optiscaler/fakenvapi/releases/download/%s/fakenvapi-%s.7z', [FakeNvapiVersion, FakeNvapiVersion]);
      FakeNvapi7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-' + FakeNvapiVersion + '.7z';

      // Download FakeNvapi .7z
      UpdateProgress(99);
      if DownloadFile(FakeNvapiURL, FakeNvapi7zPath) then
      begin
        // Extract FakeNvapi .7z to fgmod folder
        if Extract7z(FakeNvapi7zPath, FFGModPath) then
        begin
          UpdateProgress(100);
          // Delete temporary .7z file
          DeleteFile(FakeNvapi7zPath);
        end
        else
        begin
          ShowMessage('Warning: Failed to extract FakeNvapi 7z file.');
          DeleteFile(FakeNvapi7zPath);
        end;
      end
      else
        ShowMessage('Warning: Failed to download FakeNvapi.');
    end
    else
      UpdateProgress(100);

    // Clean up temporary files
    DeleteFile(ZipFilePath);
    DeleteDirectory(ExtractPath, False);

    // 12. Create goverlayvars.txt file with version information
    try
      VarsFilePath := IncludeTrailingPathDelimiter(FFGModPath) + 'goverlayvars.txt';
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
    except
      on E: Exception do
        ShowMessage('Warning: Could not create goverlayvars.txt: ' + E.Message);
    end;

    ShowMessage('Update completed successfully!' + sLineBreak +
                'Files installed in: ' + FFGModPath);

    // 13. Update xessLabel1 and fsrlabel1 with text "decky built-in"
    if Assigned(FXessLabel) then
    begin
      try
        FXessLabel.Caption := 'decky built-in';
        FXessLabel.Font.Color := clYellow;
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
        FFsrLabel.Font.Color := clYellow;
        Application.ProcessMessages;
      except
        on E: Exception do
          ShowMessage('Warning: Could not update Fsr label: ' + E.Message);
      end;
    end;

  finally
    // Re-enable button
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Enabled := True;
    UpdateProgress(0);
  end;
end;

end.
