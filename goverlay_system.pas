unit goverlay_system;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, FileUtil, LCLIntf, Graphics, Buttons, Dialogs,
  fpjson, jsonparser, StrUtils, constants, systemdetector, apputils, configmanager;

var
  GLatestVersion: string = '';          // Latest available Goverlay version from GitHub

function CompareVersions(const Version1, Version2: string): Integer;
function GetLatestGoverlayVersion: string;
function GetReleaseNotes(const AVersion: string): string;
procedure CheckGoverlayUpdate(const CurrentVersion, Channel: string; UpdateButton: TBitBtn);
function IsNvidiaModuleLoaded: Boolean;
function LibraryExists(const LibName: string): Boolean;
function IsKernelModuleAvailable(const ModuleName: string): Boolean;
function CheckDependencies(out Missing: TStringList): Boolean;
function GetKernelVersion: string;
procedure SaveDistroInfo;

implementation

uses
  Math;

// Function to compare version strings (e.g., "1.5.3" vs "1.6.0")
function CompareVersions(const Version1, Version2: string): Integer;
var
  V1Parts, V2Parts: TStringArray;
  i, Num1, Num2, MaxLen: Integer;
begin
  // Split versions by dot
  V1Parts := SplitString(Version1, '.');
  V2Parts := SplitString(Version2, '.');

  // Get the maximum length
  MaxLen := Max(Length(V1Parts), Length(V2Parts));

  // Compare each part
  for i := 0 to MaxLen - 1 do
  begin
    // Get numeric value (0 if part doesn't exist)
    if i < Length(V1Parts) then
      Num1 := StrToIntDef(V1Parts[i], 0)
    else
      Num1 := 0;

    if i < Length(V2Parts) then
      Num2 := StrToIntDef(V2Parts[i], 0)
    else
      Num2 := 0;

    // Compare this part
    if Num1 < Num2 then
      Exit(-1)  // Version1 is older
    else if Num1 > Num2 then
      Exit(1);  // Version1 is newer
  end;

  Result := 0;  // Versions are equal
end;

function GetLatestGoverlayVersion: string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  TagName: string;
  i: Integer;
  MaxVersion: string;
  ComparisonResult: Integer;
begin
  Result := '';
  MaxVersion := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      // Fetch only the last 4 tags to avoid GitHub API rate limits
      // Tags are returned in reverse chronological order (most recent first)
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      // Fetch only 3 tags to minimize API usage
      Process.Parameters.Add(URL_GOVERLAY_API_TAGS);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response from curl
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONArray) then
          begin
            JSONArray := TJSONArray(JSONData);

            // Iterate through all returned tags (up to 3)
            for i := 0 to JSONArray.Count - 1 do
            begin
              JSONObject := JSONArray.Objects[i];
              if Assigned(JSONObject) then
              begin
                TagName := JSONObject.Get('name', '');
                // Remove 'v' prefix if present (e.g., "v1.5.3" -> "1.5.3")
                if (TagName <> '') and (TagName[1] = 'v') then
                  Delete(TagName, 1, 1);

                // If this is the first valid tag, use it as initial max
                if MaxVersion = '' then
                begin
                  MaxVersion := TagName;
                end
                else
                begin
                  // Compare with current maximum version
                  ComparisonResult := CompareVersions(TagName, MaxVersion);
                  // If current tag is greater than max, update max
                  if ComparisonResult > 0 then
                    MaxVersion := TagName;
                end;
              end;
            end;

            Result := MaxVersion;
          end;
        finally
          JSONData.Free;
        end;
      end;
    except
      on E: Exception do
        Result := ''; // Keep silent behavior on error
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function GetReleaseNotes(const AVersion: string): string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response, TagName, BodyText, CleanVer: string;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  i: Integer;
begin
  Result := '';
  CleanVer := AVersion;
  if (CleanVer <> '') and (CleanVer[1] = 'v') then
    Delete(CleanVer, 1, 1);

  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');
      Process.Parameters.Add('-L');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      Process.Parameters.Add(URL_GOVERLAY_API_RELEASES);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONArray) then
          begin
            JSONArray := TJSONArray(JSONData);
            // First pass: try to find an exact match for the given version
            // that is NOT a prerelease (i.e. an official stable release).
            for i := 0 to JSONArray.Count - 1 do
            begin
              JSONObject := JSONArray.Objects[i];
              if Assigned(JSONObject) then
              begin
                TagName := JSONObject.Get('tag_name', '');
                if (TagName <> '') and (TagName[1] = 'v') then
                  Delete(TagName, 1, 1);

                if (TagName = CleanVer) and not JSONObject.Get('prerelease', False) then
                begin
                  BodyText := JSONObject.Get('body_html', '');
                  if BodyText = '' then
                    BodyText := JSONObject.Get('body', '');
                  if BodyText <> '' then
                  begin
                    Result := BodyText;
                    Break;
                  end;
                end;
              end;
            end;

            // Second pass: if no match found (e.g. current build is a nightly
            // with no matching official release), pick the body of the first
            // non-prerelease release — i.e. the latest official stable release.
            if Result = '' then
            begin
              for i := 0 to JSONArray.Count - 1 do
              begin
                JSONObject := JSONArray.Objects[i];
                if Assigned(JSONObject) and not JSONObject.Get('prerelease', False) then
                begin
                  BodyText := JSONObject.Get('body_html', '');
                  if BodyText = '' then
                    BodyText := JSONObject.Get('body', '');
                  if BodyText <> '' then
                  begin
                    Result := BodyText;
                    Break;
                  end;
                end;
              end;
            end;
          end;
        finally
          JSONData.Free;
        end;
      end;
    except
      on E: Exception do
        Result := '';
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;

  if Trim(Result) = '' then
  begin
    Result := '• Performance and stability improvements.' + LineEnding +
              '• User interface enhancements and updates.' + LineEnding + LineEnding +
              'For complete release notes, visit:' + LineEnding +
              'https://github.com/benjamimgois/goverlay/releases';
  end;
end;

// procedure to Check for goverlay update
procedure CheckGoverlayUpdate(const CurrentVersion, Channel: string; UpdateButton: TBitBtn);
var
  LatestVersion: string;
  ComparisonResult: Integer;
begin
  // MODIFICATION 1: Never show button if channel is "git" (development mode)
  if LowerCase(Channel) = 'git' then
  begin
    if Assigned(UpdateButton) then
      UpdateButton.Visible := False;
    Exit;
  end;

  // Get latest version from GitHub
  LatestVersion := GetLatestGoverlayVersion;
  GLatestVersion := LatestVersion;

  // If we got a valid version from GitHub
  if LatestVersion <> '' then
  begin
    // Compare versions numerically
    ComparisonResult := CompareVersions(CurrentVersion, LatestVersion);

    // MODIFICATION 2: Only show button if LatestVersion is GREATER than CurrentVersion
    if ComparisonResult < 0 then
    begin
      if Assigned(UpdateButton) then
      begin
        UpdateButton.Caption := 'New Version ' + LatestVersion + ' available';
        UpdateButton.BorderSpacing.Bottom := 60;
        UpdateButton.Visible := True;
      end;
    end
    else
    begin
      // If current version is equal or greater, hide the button
      if Assigned(UpdateButton) then
        UpdateButton.Visible := False;
    end;
  end
  else
  begin
    // If failed to get version from GitHub, hide the button
    if Assigned(UpdateButton) then
      UpdateButton.Visible := False;
  end;
end;

function IsNvidiaModuleLoaded: Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  Output: string;
begin
  Result := False;
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      // Use lsmod to check if nvidia module is loaded
      Process.Executable := 'lsmod';
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read output
      OutputList.LoadFromStream(Process.Output);
      Output := OutputList.Text;

      // Check if 'nvidia' appears in the output
      Result := Pos('nvidia', LowerCase(Output)) > 0;
    except
      on E: Exception do
        Result := False; // If error, assume not loaded
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

function LibraryExists(const LibName: string): Boolean;
const
  SearchPaths: array[0..2] of string = (
    '/usr/lib/',
    '/usr/lib64/',
    '/usr/local/lib/'
  );
var
  Path: string;
begin
  Result := False;
  for Path in SearchPaths do
    if FileExists(Path + LibName) then
      Exit(True);
end;

// Function to check for kernel modules
function IsKernelModuleAvailable(const ModuleName: string): Boolean;
var
  AProcess: TProcess;
  OutputLines: TStringList;
begin
  Result := False;
  AProcess := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('lsmod');
    AProcess.Options := [poUsePipes];
    AProcess.Execute;
    OutputLines.LoadFromStream(AProcess.Output);
    Result := OutputLines.Text.Contains(ModuleName);
  finally
    AProcess.Free;
    OutputLines.Free;
  end;
end;

// Function to check for dependencies
function CheckDependencies(out Missing: TStringList): Boolean;
begin
  Missing := TStringList.Create;



  // Check for Flatpak runtimes or native binaries
  if IsRunningInFlatpak then
  begin
    // Flatpak mode: check for .so files in container paths
    // MangoHud extension
    if not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/x86_64-linux-gnu/libMangoHud.so') and
       not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/i386-linux-gnu/libMangoHud.so') then
      Missing.Add('MangoHud runtime 25.08');

    // vkBasalt extension
    if not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/x86_64-linux-gnu/vkbasalt/libvkbasalt.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/i386-linux-gnu/vkbasalt/libvkbasalt.so') then
      Missing.Add('vkBasalt runtime 25.08');

    // vkSumi extension
    if not FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/i386-linux-gnu/libVkLayer_vksumi.so') then
      Missing.Add('vkSumi runtime');
  end
  else
  begin
    // Native: mangohud binary (all distros install it to PATH)
    if not IsCommandAvailable('mangohud') then
      Missing.Add('mangohud');

    // vkBasalt: check Vulkan layer JSON (distro-agnostic) then fall back to library scan
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/vkBasalt.json') and
       not IsLibraryAvailable('libvkbasalt') then
      Missing.Add('vkbasalt');

    // vkSumi: check Vulkan layer JSON then fall back to library scan
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vksumi.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/vksumi.json') and
       not FileExists(GetUserDir + '.local/share/vulkan/implicit_layer.d/vksumi.json') and
       not IsLibraryAvailable('libVkLayer_vksumi') then
      Missing.Add('vksumi');
  end;



  // check if 7z is available
  if not IsCommandAvailable('7z') then
    Missing.Add('p7zip');

  // check if curl is available
  if not IsCommandAvailable('curl') then
    Missing.Add('curl');

  // check if git is available
  if not IsCommandAvailable('git') then
    Missing.Add('git');

  // check if Nerd Font is available
  if not IsNerdFontInstalled then
    Missing.Add('nerdfonts');

  // check if protontricks is available
  // Skip check in Flatpak since we fallback to com.github.Matoking.protontricks Flatpak
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('protontricks') then
      Missing.Add('protontricks');
  end;

  // check if gamemoderun is available (required for GameMode feature in Tweaks tab)
  // Skip check in Flatpak since gamemoderun is on the host and we can't reliably detect it
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('gamemoderun') then
      Missing.Add('gamemode');
  end;

  // Check for libqt6pas (Qt6 Pascal bindings — required for Goverlay GUI).
  // Arch installs it as libQt6Pas.so; other distros use libqt6pas.so.
  // IsLibraryAvailable checks both via case-insensitive ldconfig + path scan.
  {$IFDEF LCLqt6}
  if not IsLibraryAvailable('libQt6Pas') then
    Missing.Add('libqt6pas');
  {$ELSE}
  if not IsLibraryAvailable('libQt5Pas') then
    Missing.Add('libqt5pas');
  {$ENDIF}

  // check if zenergy module is available
  // if not IsKernelModuleAvailable('zenergy') then
  //   Missing.Add('- zenergy kernel module');

  Result := Missing.Count = 0;
end;

// Function to get kernel version
function GetKernelVersion: string;
var
  Output: TStringList;
  AProcess: TProcess;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('uname');
    AProcess.Parameters.Add('-r');
    AProcess.Options := [poWaitOnExit, poUsePipes];
    AProcess.Execute;

    Output.LoadFromStream(AProcess.Output);
    if Output.Count > 0 then
      Result := Trim(Output[0]);  // Remove spaces
  finally
    Output.Free;
    AProcess.Free;
  end;
end;

procedure SaveDistroInfo;
var
  DistroInfo, VersionOrBuildID, KernelVersion, Line: string;
  SL: TStringList;
  SavePath: string;
  OutputSL: TStringList;
begin
  DistroInfo := '';
  VersionOrBuildID := '';
  SavePath := TConfigManager.GetGoverlayFolder;

  // check if /etc/os-release exists
  if FileExists('/etc/os-release') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/etc/os-release');

      for Line in SL do
      begin
        if Pos('PRETTY_NAME=', Line) = 1 then
          DistroInfo := StringReplace(Line, 'PRETTY_NAME=', '', []);
        if Pos('VERSION_ID=', Line) = 1 then
          VersionOrBuildID := StringReplace(Line, 'VERSION_ID=', '', []);
        if (Pos('BUILD_ID=', Line) = 1) and (VersionOrBuildID = '') then
          VersionOrBuildID := StringReplace(Line, 'BUILD_ID=', '', []);
      end;

      // remove quotes
      DistroInfo := StringReplace(DistroInfo, '"', '', [rfReplaceAll]);
      VersionOrBuildID := StringReplace(VersionOrBuildID, '"', '', [rfReplaceAll]);
    finally
      SL.Free;
    end;
  end;

  KernelVersion := GetKernelVersion;

  // create config dir if needed (use ForceDirectories to create full path)
  if not DirectoryExists(SavePath) then
    ForceDirectories(SavePath);

  // save Distro
  OutputSL := TStringList.Create;
  try
    OutputSL.Text := DistroInfo + ' (' + VersionOrBuildID + ')';
    OutputSL.SaveToFile(SavePath + '/distro');

    OutputSL.Text := KernelVersion;
    OutputSL.SaveToFile(SavePath + '/kernel');
  finally
    OutputSL.Free;
  end;
end;

end.
