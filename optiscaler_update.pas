unit optiscaler_update;

interface

uses
  Classes, SysUtils, Forms, ComCtrls, Buttons, Process,
  RegExpr, fpjson, jsonparser, zipper, Dialogs, StdCtrls, Graphics, DateUtils,
  constants, notificationunit, goverlay_strings;

// Function to get the correct OptiScaler installation path (Flatpak-aware)
function GetOptiScalerInstallPath: string;

type
  TDownloadProgressProc = procedure(APercent: Integer; const AStatus: string) of object;

// Check and automatically install OptiScaler if not present
// Returns True if OptiScaler is installed (or was successfully installed)
function CheckAndInstallOptiScaler(const AFGModPath: string; AIsStable: Boolean = True; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Check and automatically install/heal central FSR4 libraries (Latest, 4.1.1b, 4.0.2c)
function CheckAndInstallFsr4(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Fetch the latest HelixSR release (lonewolf0622/HelixSR) tag and .zip asset URL
function FetchHelixSRLatestRelease(out ATag, AUrl: string): Boolean;

// Fetch the latest DLSS-NR release tag and tar.gz download URL for specified arch ('rdna3' or 'rdna4')
function FetchDlssNrLatestRelease(const AArch: string; out ATag, AUrl: string): Boolean;

// Check and automatically install/heal the DLSS-NR runtime for specified arch
function CheckAndInstallDlssNr(const AArch: string; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Extract neural model weights from user-provided nvngx_dlssnr.dll or zip archive
function ExtractDlssNrModel(const ADllPath: string; out AErrorMsg: string; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Ensure extract_model.sh has structured progress markers for UI tracking
procedure SanitizeDlssNrExtractScript(const AScriptPath: string);

// Check whether the DLSS-NR runtime is installed in central storage
function IsDlssNrInstalled(const AArch: string = ''): Boolean;

// Check whether extracted DLSS-NR models (dlssnr.bin) exist in central storage
function IsDlssNrModelReady: Boolean;

// Retrieve the installed DLSS-NR version tag
function GetDlssNrVersion(const AArch: string = ''): string;

// Extract the latest release tag from a GitHub releases Atom XML feed.
// Returns the tag string (e.g. v1.2.3) or '' when no entry/tag can be found.
function ExtractReleaseTagFromAtomXml(const AXml: string): string;

// Fetch the latest release tag for a GitHub repository through its Atom feed
// (https://github.com/<owner>/<repo>/releases.atom). Returns '' on failure.
function FetchLatestReleaseTagFromAtom(const AOwner, ARepo: string): string;

// Resolve the active HelixSR amd_fidelityfx_dx12.dll path. Prefers the
// HelixSR-fsrfg subdirectory when present, otherwise the root directory.
function GetHelixSRDx12DllPath(const ARootPath: string): string;

// Check and automatically install/heal the HelixSR OptiScaler runtime (lonewolf0622/HelixSR)
function CheckAndInstallHelixSR(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Synchronize HelixSR companion libraries from the stable OptiScaler cache and
// guarantee the HelixSR Freeware License is redistributed as <TargetDir>/LICENSE.
// Passing an empty ATargetDir defaults to the HelixSR runtime path.
function EnsureHelixSRCompanionLibraries(const ATargetDir: string): Boolean;

// Check whether the HelixSR neural runtime has been compiled locally (HXSRNET1
// footer marker in amd_fidelityfx_dx12.dll, or weights/kernels payloads present)
function IsHelixSRCompiled(const ARootPath: string = ''): Boolean;

// Compile the HelixSR neural shaders/kernels on demand by running helixsr-setup.sh
function CompileHelixSR(AOnProgress: TDownloadProgressProc = nil): Boolean;

// Retrieve/clear the descriptive error recorded by the last HelixSR compilation.
function GetHelixSRLastCompileError: string;
procedure ClearHelixSRLastCompileError;

// Remove a stale/corrupted HelixSR Wine prefix before a new compilation run.
procedure CleanHelixSRWinePrefix;

// Validate that the given Wine executable can run (`--version`, exit code 0).
function IsWineExecutableValid(const AWinePath: string): Boolean;

// Resolve the best validated Wine runtime available on this host.
function FindWorkingWineForHelixSR: string;

// Harden the bundled helixsr-setup.sh (prefix purge, HELIXSR_WINE, system Wine
// preference and WINEARCH=win64 wrapper) so compilation is robust on Wine/Proton.
procedure SanitizeHelixSRSetupScript(const AWorkDir: string);

// Audit mandatory upscaler and DLSS libraries on disk
function HasMissingMandatoryLibraries(out AMissingList: TStringList): Boolean; overload;
function HasMissingMandatoryLibraries: Boolean; overload;

// Check and automatically install/update the OptiPatcher OptiScaler ASI plugin
// from the optiscaler/OptiPatcher rolling release.
function CheckAndInstallOptiPatcher(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Check whether a newer OptiPatcher rolling build is available on GitHub.
function IsOptiPatcherUpdateAvailable: Boolean;

// Import a custom OptiScaler build from a local directory
function ImportCustomOptiScalerBuild(const ASourceDir: string; out AErrorMsg: string): Boolean;

// Check and automatically install DLSS Enabler if not present
function CheckAndInstallDlssEnabler(AIsStable: Boolean = True; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

// Synchronize OptiScaler supporting libraries to DLSS Enabler cache directory
procedure SyncOptiScalerFilesToDlssEnabler(AIsStable: Boolean = True);

// Check and automatically install Streamline SDK if not present
function CheckAndInstallStreamlineSDK(AIsStable: Boolean = True; AForce: Boolean = False): Boolean;

// Validate if a shared library file exists and has valid ELF header and size
function IsValidSharedLibrary(const APath: string; AMinSizeBytes: Int64 = 65536): Boolean;

// Sanitize implicit Vulkan layer manifests (removes stale/corrupted manifests)
procedure SanitizeImplicitVulkanLayers;

// Check and automatically install vkSumi Vulkan layer if not present
function CheckAndInstallVkSumi(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Check whether the vkSumi Vulkan layer is installed (system or user space)
function IsVkSumiInstalled: Boolean;

// Read the locally recorded vkSumi version (goverlay.vars or version.txt)
function ReadLocalVkSumiVersion: string;

// Check whether a newer vkSumi release is available on GitHub
function IsVkSumiUpdateAvailable: Boolean;

// Parse the "tag_name" field from a vkSumi GitHub API response
function ParseVkSumiReleaseTag(const AJson: string): string;

// Check and automatically install MAKO Renderer Vulkan layer if not present
function IsMakoInstalled: Boolean;
function GetMakoLibraryPath: string;
function GetMakoInstalledVersion: string;
function GetMakoLatestRemoteVersion(out AUrl: string): string;
function CheckAndInstallMako(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
function InspectMakoLosslessDll(const ADllPath: string; out ADetails: string): Boolean;

// Check and automatically install lsfg-vk Vulkan layer if not present
function IsLsfgVkInstalled: Boolean;
function GetLsfgVkLibraryPath: string;
function GetLsfgVkInstalledVersion: string;
function ParseLsfgVkBuildsHtml(const AHtml: string; out AUrl: string): string;
function GetLsfgVkLatestRemoteVersion(out AUrl: string): string;
function CheckAndInstallLsfgVk(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Check and automatically install AFMF Vulkan layer if not present
function IsAfmfInstalled: Boolean;
function GetAfmfLibraryPath: string;
function GetAfmfInstalledVersion: string;
function GetAfmfLatestRemoteVersion(out AUrl: string): string;
function CheckAndInstallAfmf(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;

// Check and automatically install ReShade runtime and standard shaders
function ExtractArchive7z(const A7zFile, ADestPath: string): Boolean;
function ExtractTarArchive(const ATarFile, ADestPath: string; AStripComponents: Integer = 0): Boolean;
function IsReShadeInstalled: Boolean;
function GetReShadeInstalledVersion: string;
function ParseReShadeMeHtml(const AHtml: string; out AUrl: string): string;
function GetReShadeLatestRemoteVersion(out AUrl: string): string;
function CheckAndInstallReShade(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
function InstallReShadeShaderPack(const APackName, ARepoUrl: string; AOnProgress: TDownloadProgressProc = nil): Boolean;
function CheckAndInstallVkBasaltShaders(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;

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
    FDlssStableVersion: string;
    FDlssStableURL: string;
    FDlssEdgeVersion: string;
    FDlssEdgeURL: string;

    procedure LoadVersionsFromFile;
    procedure UpdateButtonClick(Sender: TObject);
    procedure InitializeTab;
    procedure CheckForUpdatesOnClick;
    function SelectAndImportCustomBuild: Boolean;
    procedure UpdateCustomBuildUI;
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
  FileUtil, LazFileUtils, BaseUnix, bgmod_resources, systemdetector, overlayunit, overlay_config, apputils, overlay_utils, IniFiles, StrUtils, configfile,
  helixsr_license_dialog;

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

var
  FHelixSRLastCompileError: string = '';

// Extract the latest release tag from a GitHub releases Atom XML feed.
// Inspection strategy: locate the first <entry> block, then read the tag either
// from its <link ... href=".../releases/tag/<tag>"> alternate link or, as a
// fallback, from the <id>tag:github.com,2008:Repository/<repo>/<tag></id> node.
function ExtractReleaseTagFromAtomXml(const AXml: string): string;
var
  EntryStart, EntryEnd, TagPos, IdPos, P1, P2: Integer;
  Entry: string;
begin
  Result := '';
  if AXml = '' then Exit;

  EntryStart := Pos('<entry>', AXml);
  if EntryStart = 0 then Exit;

  EntryEnd := PosEx('</entry>', AXml, EntryStart);
  if EntryEnd = 0 then
    Entry := Copy(AXml, EntryStart, Length(AXml) - EntryStart + 1)
  else
    Entry := Copy(AXml, EntryStart, EntryEnd - EntryStart);

  // Preferred: <link rel="alternate" ... href=".../releases/tag/<tag>">
  TagPos := Pos('/releases/tag/', Entry);
  if TagPos > 0 then
  begin
    P1 := TagPos + Length('/releases/tag/');
    P2 := P1;
    while (P2 <= Length(Entry)) and (Entry[P2] <> '"') and (Entry[P2] <> '<') and (Entry[P2] <> ' ') and (Entry[P2] <> '/') do
      Inc(P2);
    if P2 > P1 then
      Exit(Copy(Entry, P1, P2 - P1));
  end;

  // Fallback: <id>tag:github.com,2008:Repository/<numeric>/<tag></id>
  IdPos := Pos('2008:Repository/', Entry);
  if IdPos > 0 then
  begin
    P1 := IdPos + Length('2008:Repository/');
    while (P1 <= Length(Entry)) and (Entry[P1] in ['0'..'9']) do
      Inc(P1);
    if (P1 <= Length(Entry)) and (Entry[P1] = '/') then
      Inc(P1);
    P2 := P1;
    while (P2 <= Length(Entry)) and (Entry[P2] <> '<') and (Entry[P2] <> '"') and (Entry[P2] <> ' ') do
      Inc(P2);
    if P2 > P1 then
      Exit(Copy(Entry, P1, P2 - P1));
  end;
end;

// Fetch the latest release tag for a GitHub repository through its Atom feed.
function FetchLatestReleaseTagFromAtom(const AOwner, ARepo: string): string;
var
  Process: TProcess;
  OutputList: TStringList;
  TmpFile, RespText: string;
begin
  Result := '';
  if (AOwner = '') or (ARepo = '') then Exit;

  TmpFile := IncludeTrailingPathDelimiter(GetTempDir) + 'atom_' + AOwner + '_' + ARepo + '_' + IntToStr(fpgetpid) + '.xml';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('8');
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(TmpFile);
    Process.Parameters.Add('https://github.com/' + AOwner + '/' + ARepo + '/releases.atom');
    Process.Options := [poWaitOnExit];
    Process.Execute;
  finally
    Process.Free;
  end;

  if not FileExists(TmpFile) then Exit;

  OutputList := TStringList.Create;
  try
    OutputList.LoadFromFile(TmpFile);
    RespText := OutputList.Text;
  finally
    OutputList.Free;
    DeleteFile(TmpFile);
  end;

  Result := ExtractReleaseTagFromAtomXml(RespText);
end;

// Query the latest release of lonewolf0622/HelixSR from the GitHub API.
// Fills ATag with the release tag (e.g. v1.8.1) and AUrl with the .zip asset URL.
// Falls back to the Atom feed when the API cannot be reached or parsed.
function FetchHelixSRLatestRelease(out ATag, AUrl: string): Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  RespText, TmpFile, AtomTag, FileTag: string;
  KeyPos, ColonPos, QuoteStart, QuoteEnd, UrlPos: Integer;
begin
  Result := False;
  ATag := '';
  AUrl := '';

  TmpFile := IncludeTrailingPathDelimiter(GetTempDir) + 'helixsr_api.json';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(TmpFile);
    Process.Parameters.Add('https://api.github.com/repos/lonewolf0622/HelixSR/releases/latest');
    Process.Options := [poWaitOnExit];
    Process.Execute;
  finally
    Process.Free;
  end;

  if FileExists(TmpFile) then
  begin
    OutputList := TStringList.Create;
    try
      OutputList.LoadFromFile(TmpFile);
      RespText := OutputList.Text;
    finally
      OutputList.Free;
      DeleteFile(TmpFile);
    end;

    // Extract "tag_name": "vX.Y.Z"
    KeyPos := Pos('"tag_name"', RespText);
    if KeyPos > 0 then
    begin
      ColonPos := PosEx(':', RespText, KeyPos + 10);
      if ColonPos > 0 then
      begin
        QuoteStart := PosEx('"', RespText, ColonPos);
        if QuoteStart > 0 then
        begin
          QuoteEnd := PosEx('"', RespText, QuoteStart + 1);
          if QuoteEnd > QuoteStart then
            ATag := Copy(RespText, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
        end;
      end;
    end;

    // Extract the first browser_download_url that points to a .zip asset
    UrlPos := Pos('browser_download_url', RespText);
    while UrlPos > 0 do
    begin
      QuoteEnd := PosEx('.zip"', RespText, UrlPos);
      if QuoteEnd > 0 then
      begin
        KeyPos := PosEx('http', RespText, UrlPos);
        if (KeyPos > 0) and (KeyPos < QuoteEnd) then
        begin
          AUrl := Copy(RespText, KeyPos, QuoteEnd + 4 - KeyPos);
          Break;
        end;
      end;
      UrlPos := PosEx('browser_download_url', RespText, UrlPos + 20);
    end;
  end;

  // Fallback to the Atom feed when the REST API is unavailable or incomplete
  if (ATag = '') or (AUrl = '') then
  begin
    AtomTag := FetchLatestReleaseTagFromAtom('lonewolf0622', 'HelixSR');
    if AtomTag <> '' then
    begin
      ATag := AtomTag;
      if (ATag <> '') and (ATag[1] = 'v') then
        FileTag := Copy(ATag, 2, Length(ATag))
      else
        FileTag := ATag;
      AUrl := 'https://github.com/lonewolf0622/HelixSR/releases/download/' + ATag + '/HelixSR-' + FileTag + '.zip';
    end;
  end;

  Result := (ATag <> '') and (AUrl <> '');
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
    if FOptiTab.FOptVersionComboBox.ItemIndex = 2 then
    begin
      FOptiTab.UpdateCustomBuildUI;
      FOptiTab.FUpdateThread := nil;
      Exit;
    end;
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

      if (FLatestOptiTag <> '') and ((CurrentVersion = '') or (CurrentVersion = '—') or (CurrentVersion = '--')) then
      begin
        HasUpdate := True;
      end
      else if (FLatestOptiTag <> '') and (CurrentVersion <> '') then
      begin
        NormLatest := StringReplace(FLatestOptiTag, '-', '.', [rfReplaceAll]);
        NormCurrent := StringReplace(CurrentVersion, '-', '.', [rfReplaceAll]);
        HasUpdate := (CompareVersions(NormLatest, NormCurrent) > 0);
      end
      else
        HasUpdate := False;

      if HasUpdate then
      begin
        // Hint carries the bare tag for RefreshOsStatusDots; the caption is
        // the sentence the user reads and is not parsed back.
        FOptiTab.FOptiLabel2.Hint := FOptiTab.FormatDlssEnablerDisplayTag(FLatestOptiTag);
        FOptiTab.FOptiLabel2.Caption := 'Update Available ' + FOptiTab.FOptiLabel2.Hint;
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

      if (FLatestOptiTag <> '') and ((CurrentVersion = '') or (CurrentVersion = '—') or (CurrentVersion = '--')) then
      begin
        FOptiTab.FOptiLabel2.Hint := FLatestOptiTag;
        FOptiTab.FOptiLabel2.Caption := 'Update Available ' + FLatestOptiTag;
        FOptiTab.FOptiLabel2.Font.Color := clLime;
        FOptiTab.FOptiLabel2.Visible := True;
        HasUpdates := True;
      end
      else if (FLatestOptiTag <> '') and (CurrentVersion <> '') then
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
          FOptiTab.FOptiLabel2.Hint := FLatestOptiTag;
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
  // OptiPatcher checks/updates moved to the startup splash screen
  // (CheckAndInstallOptiPatcher run from TStartupDownloadThread.Execute).
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
          ShowMessage(Format(rsReleaseFetchFailed, [E.Message]));
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
  JSONObject, StableObj, EdgeObj, DlssStableObj, DlssEdgeObj: TJSONObject;
begin
  Result := False;
  AStableVer := '';
  AStableURL := '';
  AEdgeVer := '';
  AEdgeURL := '';
  FDlssStableVersion := '';
  FDlssStableURL := '';
  FDlssEdgeVersion := '';
  FDlssEdgeURL := '';
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

              // Parse DLSS Enabler entries from versions.json
              DlssStableObj := TJSONObject(JSONObject.Find('dlssenabler_stable'));
              if Assigned(DlssStableObj) then
              begin
                FDlssStableVersion := DlssStableObj.Get('version', '');
                FDlssStableURL     := DlssStableObj.Get('url', '');
              end;
              DlssEdgeObj := TJSONObject(JSONObject.Find('dlssenabler_edge'));
              if Assigned(DlssEdgeObj) then
              begin
                FDlssEdgeVersion := DlssEdgeObj.Get('version', '');
                FDlssEdgeURL     := DlssEdgeObj.Get('url', '');
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
          ShowMessage(Format(rsManifestFetchFailed, [E.Message]));
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
  OutputList: TStringList;
  Response, ItemName, TargetKeyword, TmpFile: string;
  StartPos, EndPos, NamePos, SpacePos: Integer;
  DummyStableVer, DummyStableURL, DummyEdgeVer, DummyEdgeURL: string;
begin
  Result := '';

  // 1. Check if DLSS Enabler version tag is available from versions.json manifest
  if AIsStable and (FDlssStableVersion <> '') then
    Exit(FDlssStableVersion)
  else if (not AIsStable) and (FDlssEdgeVersion <> '') then
    Exit(FDlssEdgeVersion);

  if FetchManifest(True, DummyStableVer, DummyStableURL, DummyEdgeVer, DummyEdgeURL) then
  begin
    if AIsStable and (FDlssStableVersion <> '') then
      Exit(FDlssStableVersion)
    else if (not AIsStable) and (FDlssEdgeVersion <> '') then
      Exit(FDlssEdgeVersion);
  end;

  // 2. Fall back to HTML directory scraping (bypassing GitHub API rate limit)
  if AIsStable then
    TargetKeyword := 'STABLE'
  else
    TargetKeyword := 'TRUNK';

  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  TmpFile := IncludeTrailingPathDelimiter(GetTempDir) + 'goverlay_de_tag.html';
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(TmpFile);
    Process.Parameters.Add('https://github.com/benjamimgois/OptiScaler-builds/tree/nightly-action/de');
    Process.Options := [poWaitOnExit];
    Process.Execute;
    if FileExists(TmpFile) then
    begin
      OutputList.LoadFromFile(TmpFile);
      Response := OutputList.Text;
      DeleteFile(TmpFile);
    end;

    StartPos := 1;
    while True do
    begin
      NamePos := PosEx('DLSS%20Enabler%20', Response, StartPos);
      if NamePos = 0 then
        NamePos := PosEx('/benjamimgois/OptiScaler-builds/blob/nightly-action/de/', Response, StartPos);
      if NamePos = 0 then Break;

      if Copy(Response, NamePos, 17) = 'DLSS%20Enabler%20' then
      begin
        StartPos := NamePos;
        EndPos := PosEx('.zip', Response, StartPos);
        if EndPos = 0 then Break;
        ItemName := Copy(Response, StartPos, EndPos + 4 - StartPos);
        ItemName := StringReplace(ItemName, '%20', ' ', [rfReplaceAll]);
      end
      else
      begin
        StartPos := NamePos + Length('/benjamimgois/OptiScaler-builds/blob/nightly-action/de/');
        EndPos := PosEx('"', Response, StartPos);
        if EndPos = 0 then Break;
        ItemName := Copy(Response, StartPos, EndPos - StartPos);
        ItemName := StringReplace(ItemName, '%20', ' ', [rfReplaceAll]);
      end;

      if (Pos(TargetKeyword, ItemName) > 0) and (Pos('DLSS', ItemName) > 0) then
      begin
        NamePos := Pos('DLSS Enabler ', ItemName);
        if NamePos > 0 then
        begin
          NamePos := NamePos + Length('DLSS Enabler ');
          SpacePos := PosEx(' ', ItemName, NamePos);
          if SpacePos > NamePos then
            Result := Copy(ItemName, NamePos, SpacePos - NamePos);
        end;
        Break;
      end;
      StartPos := EndPos + 1;
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
          ShowMessage(Format(rsDownloadCurlFailed, [Process.ExitStatus, AURL]));
        end
        else if not FileExists(ADestFile) then
        begin
          WriteLn('[ERROR] DownloadFile: File does not exist after download: ', ADestFile);
          ShowMessage(Format(rsDownloadMissingFile, [AURL]));
        end;
      end;

    except
      on E: Exception do
      begin
        WriteLn('[ERROR] DownloadFile: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage(Format(rsDownloadFailed, [E.Message, AURL]));
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
        ShowMessage(Format(rsZipExtractFailed, [E.Message]));
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
        ShowMessage(Format(rsSevenZipMissing, [A7zFile]));
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
        ShowMessage(Format(rsSevenZipFailed, [Process.ExitStatus, A7zFile]));
      end
      else
        WriteLn('[DEBUG] Extract7z: Extraction completed successfully');
    except
      on E: Exception do
      begin
        WriteLn('[ERROR] Extract7z: Exception - ', E.ClassName, ': ', E.Message);
        ShowMessage(Format(rsSevenZipError, [E.Message]));
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
              ShowMessage(Format(rsCopyFileFailed, [SearchRec.Name]));

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

    if not Result then
    begin
      WriteLn('[DEBUG] FetchFakeNvapiLatest: Using direct release URL fallback (bypassing GitHub API rate limit)');
      ATag := 'v1.4.1';
      AURL := 'https://github.com/optiscaler/fakenvapi/releases/latest/download/fakenvapi.7z';
      Result := True;
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
  // ATargetDir. Only DLLs, plugins/, and fakenvapi.ini
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
      'fi 2>/dev/null');
    SyncProc.Options := [poWaitOnExit];
    SyncProc.Execute;
  finally
    SyncProc.Free;
  end;
  WriteLn('[DEBUG] SyncPristineAssetsTo: synced pristine assets from ', Source, ' to ', Target);
end;

function ImportCustomOptiScalerBuild(const ASourceDir: string; out AErrorMsg: string): Boolean;
var
  CleanSourceDir, TargetDir, StableDir, OptiDll: string;
  FolderName: string;
  Proc: TProcess;
  VarsList, StableVars: TStringList;
  VarsFile: string;
  CompanionFiles: array[0..14] of string = (
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_framegeneration_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'amd_fidelityfx_vk.dll',
    'libxess.dll',
    'libxess_dx11.dll',
    'libxess_fg.dll',
    'libxell.dll',
    'fakenvapi.dll',
    'fakenvapi.ini',
    'nvngx_dlss.dll',
    'nvngx_dlssd.dll',
    'nvngx_dlssg.dll',
    'dlssg_to_fsr3_amd_is_better.dll',
    'OptiScaler.ini'
  );
  i: Integer;
  SrcFile, DstFile: string;
begin
  Result := False;
  AErrorMsg := '';
  CleanSourceDir := ExcludeTrailingPathDelimiter(Trim(ASourceDir));

  if (CleanSourceDir = '') or not DirectoryExists(CleanSourceDir) then
  begin
    AErrorMsg := 'The selected directory does not exist.';
    Exit;
  end;

  OptiDll := IncludeTrailingPathDelimiter(CleanSourceDir) + 'OptiScaler.dll';
  if not FileExists(OptiDll) then
  begin
    AErrorMsg := 'The selected directory does not contain OptiScaler.dll';
    Exit;
  end;

  TargetDir := GetBGModOriginalCustomPath;
  if not ForceDirectories(TargetDir) then
  begin
    AErrorMsg := 'Failed to create target directory: ' + TargetDir;
    Exit;
  end;

  WriteLn('[OPTISCALER-CUSTOM] Importing build from: ', CleanSourceDir);
  WriteLn('[OPTISCALER-CUSTOM] Target cache path: ', TargetDir);

  // Copy files from source directory into target cache
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('cp -rf --no-preserve=mode ' +
                        QuotedStr(IncludeTrailingPathDelimiter(CleanSourceDir) + '.') + ' ' +
                        QuotedStr(IncludeTrailingPathDelimiter(TargetDir)) + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // Inherit missing companion libraries from optiscaler-stable
  StableDir := GetBGModOriginalPath;
  if DirectoryExists(StableDir) then
  begin
    for i := 0 to High(CompanionFiles) do
    begin
      DstFile := IncludeTrailingPathDelimiter(TargetDir) + CompanionFiles[i];
      SrcFile := IncludeTrailingPathDelimiter(StableDir) + CompanionFiles[i];
      if not FileExists(DstFile) and FileExists(SrcFile) then
      begin
        WriteLn('[OPTISCALER-CUSTOM] Inheriting missing companion file: ', CompanionFiles[i]);
        CopyFile(SrcFile, DstFile);
      end;
    end;

    // Inherit plugins directory if missing
    if DirectoryExists(IncludeTrailingPathDelimiter(StableDir) + 'plugins') and
       not DirectoryExists(IncludeTrailingPathDelimiter(TargetDir) + 'plugins') then
    begin
      WriteLn('[OPTISCALER-CUSTOM] Inheriting plugins/ directory from stable cache');
      Proc := TProcess.Create(nil);
      try
        Proc.Executable := 'sh';
        Proc.Parameters.Add('-c');
        Proc.Parameters.Add('cp -rf --no-preserve=mode ' +
                            QuotedStr(IncludeTrailingPathDelimiter(StableDir) + 'plugins') + ' ' +
                            QuotedStr(IncludeTrailingPathDelimiter(TargetDir)) + ' 2>/dev/null');
        Proc.Options := [poWaitOnExit];
        Proc.Execute;
      finally
        Proc.Free;
      end;
    end;
  end;

  // Ensure bgmod wrapper binaries are present and executable
  if FileExists(IncludeTrailingPathDelimiter(GetBGModPath) + 'bgmod') then
    CopyFile(IncludeTrailingPathDelimiter(GetBGModPath) + 'bgmod', IncludeTrailingPathDelimiter(TargetDir) + 'bgmod');
  if FileExists(IncludeTrailingPathDelimiter(GetBGModPath) + 'bgmod-uninstaller') then
    CopyFile(IncludeTrailingPathDelimiter(GetBGModPath) + 'bgmod-uninstaller', IncludeTrailingPathDelimiter(TargetDir) + 'bgmod-uninstaller');
  if FileExists(IncludeTrailingPathDelimiter(GetBGModPath) + 'fgmod') then
    CopyFile(IncludeTrailingPathDelimiter(GetBGModPath) + 'fgmod', IncludeTrailingPathDelimiter(TargetDir) + 'fgmod');

  if FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'bgmod') then
    fpChmod(IncludeTrailingPathDelimiter(TargetDir) + 'bgmod', &755);
  if FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'bgmod-uninstaller') then
    fpChmod(IncludeTrailingPathDelimiter(TargetDir) + 'bgmod-uninstaller', &755);

  // Update or create goverlay.vars in optiscaler-custom/
  FolderName := ExtractFileName(CleanSourceDir);
  VarsFile := IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars';
  VarsList := TStringList.Create;
  try
    if FileExists(VarsFile) then
      VarsList.LoadFromFile(VarsFile);

    VarsList.Values['OptiScalerVersion'] := 'custom (' + FolderName + ')';

    // Inherit other keys from stable goverlay.vars if missing
    if DirectoryExists(StableDir) and FileExists(IncludeTrailingPathDelimiter(StableDir) + 'goverlay.vars') then
    begin
      StableVars := TStringList.Create;
      try
        StableVars.LoadFromFile(IncludeTrailingPathDelimiter(StableDir) + 'goverlay.vars');
        if VarsList.Values['fsrversion'] = '' then
          VarsList.Values['fsrversion'] := StableVars.Values['fsrversion'];
        if VarsList.Values['xessversion'] = '' then
          VarsList.Values['xessversion'] := StableVars.Values['xessversion'];
        if VarsList.Values['FakeNvapiVersion'] = '' then
          VarsList.Values['FakeNvapiVersion'] := StableVars.Values['FakeNvapiVersion'];
        if VarsList.Values['dlssversion'] = '' then
          VarsList.Values['dlssversion'] := StableVars.Values['dlssversion'];
        if VarsList.Values['optipatcher'] = '' then
          VarsList.Values['optipatcher'] := StableVars.Values['optipatcher'];
      finally
        StableVars.Free;
      end;
    end;

    VarsList.SaveToFile(VarsFile);
  finally
    VarsList.Free;
  end;

  Result := True;
end;

function TOptiscalerTab.SelectAndImportCustomBuild: Boolean;
var
  DirDlg: TSelectDirectoryDialog;
  ErrMsg: string;
begin
  Result := False;
  // Test mode: never open GUI dialogs
  if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then Exit;

  DirDlg := TSelectDirectoryDialog.Create(nil);
  try
    DirDlg.Title := 'Select Custom OptiScaler Folder (containing OptiScaler.dll)';
    DirDlg.InitialDir := GetUserDir;
    if DirDlg.Execute then
    begin
      if ImportCustomOptiScalerBuild(DirDlg.FileName, ErrMsg) then
      begin
        LoadVersionsFromFile;
        if Assigned(goverlayform) then
        begin
          goverlayform.RefreshHomeOptiStatus;
          goverlayform.RefreshOsStatusDots;
          if (goverlayform.FActiveGameName <> '') and Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 2) then
            goverlayform.CopyOptiScalerGameFiles(goverlayform.GetGameConfigDir(goverlayform.FActiveGameName));
        end;
        ShowToast(ntSuccess, 'Custom OptiScaler build imported successfully!', 4000);
        ShowToast(ntInfo, 'Missing companion libraries inherited from stable cache.', 4000);
        Result := True;
      end
      else if ErrMsg <> '' then
      begin
        ShowToast(ntWarning, ErrMsg, 5000);
      end;
    end;
  finally
    DirDlg.Free;
  end;
end;

procedure TOptiscalerTab.UpdateCustomBuildUI;
var
  IsCustom: Boolean;
begin
  IsCustom := Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 2);

  if IsCustom then
  begin
    if Assigned(FCheckupdBtn) then
    begin
      FCheckupdBtn.Caption := 'Select Folder...';
      FCheckupdBtn.Hint := 'Choose local folder with custom OptiScaler build';
      FCheckupdBtn.Visible := True;
      FCheckupdBtn.Enabled := True;
    end;
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Visible := False;
    if Assigned(FOptiLabel2) then
      FOptiLabel2.Visible := False;
  end
  else
  begin
    if Assigned(FCheckupdBtn) then
    begin
      FCheckupdBtn.Caption := 'Check updates';
      FCheckupdBtn.Hint := 'Check for OptiScaler updates';
    end;
  end;
end;

function TOptiscalerTab.GetBGModOriginalPathForChannel(IsStable: Boolean): string;
begin
  if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 2) then
    Result := GetBGModOriginalCustomPath
  else if IsStable then
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
    if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 2) then
    begin
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalCustomPath) + 'goverlay.vars'; // custom cache
      if not FileExists(VarsFilePath) then
        VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'; // fallback
    end
    else if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 1) then
    begin
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars'; // edge cache
      if not FileExists(VarsFilePath) then
        VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'; // stable cache
    end
    else
    begin
      VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'; // stable cache
      if not FileExists(VarsFilePath) then
        VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars'; // edge cache
    end;
  end;

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
    if FileExists(VarsFilePath) then
    begin
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

        // Sync combobox index based on version string (Global mode only)
        if goverlayform.FActiveGameName = '' then
        begin
          if Assigned(FFsrVersionComboBox) and (FsrVer = '4.1.1b') then
            FFsrVersionComboBox.ItemIndex := 1
          else if Assigned(FFsrVersionComboBox) and ((FsrVer = '4.0.2c') or (FsrVer = '4.0.2c (INT8)') or (FsrVer = '4.0.2c INT8')) then
            FFsrVersionComboBox.ItemIndex := 2
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
              if SameText(Key, 'dlssenablerversion') or SameText(Key, 'dlssenabler') then
                DlssEnablerVer := Value;
              if SameText(Key, 'streamlineversion') or SameText(Key, 'streamline') then
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
      if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 1) then
      begin
        DlssEdgeVars := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars';
        if not FileExists(DlssEdgeVars) then
          DlssEdgeVars := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars';
      end
      else
      begin
        DlssEdgeVars := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars';
        if not FileExists(DlssEdgeVars) then
          DlssEdgeVars := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars';
      end;
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
  // Custom Build has no remote repository or online updates to check on GitHub
  if Assigned(FOptVersionComboBox) and (FOptVersionComboBox.ItemIndex = 2) then
    Exit;

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
    FOptiLabel2.Hint := '';
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
      ShowMessage(Format(rsUpdateCheckFailed, [E.Message]));
  end;
end;

procedure TOptiscalerTab.InitializeTab;
var
  CurrentVersion: string;
  SavedSettings: TOptiScalerSettings;
  SavedOnChange: TNotifyEvent;
  ActiveGame: string;
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

    // Restore saved channel selection from config (primary source)
    if Assigned(FOptVersionComboBox) then
    begin
      SavedOnChange := FOptVersionComboBox.OnChange;
      FOptVersionComboBox.OnChange := nil;
      try
        ActiveGame := '';
        if Assigned(goverlayform) then
          ActiveGame := goverlayform.FActiveGameName;

        SavedSettings := Default(TOptiScalerSettings);
        if overlay_config.LoadOptiScalerConfig(ActiveGame, SavedSettings) and (SavedSettings.OptVersionItemIndex in [0, 1, 2]) then
        begin
          FOptVersionComboBox.ItemIndex := SavedSettings.OptVersionItemIndex;
          WriteLn('[DEBUG] InitializeTab: Restored saved channel selection for "', ActiveGame, '", ComboBox index = ', SavedSettings.OptVersionItemIndex);
        end
        else if not (FOptVersionComboBox.ItemIndex in [0, 1, 2]) then
        begin
          // Fallback: combobox not yet set by game-specific config, derive from installed version tag
          CurrentVersion := '';
          if Assigned(FOptiLabel) then
            CurrentVersion := FOptiLabel.Caption;
          WriteLn('[DEBUG] InitializeTab: Current OptiScaler version = "', CurrentVersion, '"');

          if Pos('custom', LowerCase(CurrentVersion)) > 0 then
          begin
            FOptVersionComboBox.ItemIndex := 2;
            WriteLn('[DEBUG] InitializeTab: Detected custom version, set ComboBox to index 2');
          end
          else if (Length(CurrentVersion) > 5) and (Copy(CurrentVersion, 1, 5) = 'edge-') then
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

    // Load current versions matching restored channel
    LoadVersionsFromFile;
    UpdateCustomBuildUI;

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
      else if FOptVersionComboBox.ItemIndex = 2 then
      begin
        SelectAndImportCustomBuild;
        Exit;
      end
      else
      begin
        ShowMessage(rsOptiScalerChannelInvalid);
        Exit;
      end;
    end
    else
    begin
      ShowMessage(rsOptiScalerChannelMissing);
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
            ShowMessage(Format(rsCacheCleanFailed, [E.Message]));
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

    // STEP 5b: Setup central FSR4 directories and download alternative FSR DLLs
    WriteLn('[DEBUG] UpdateButtonClick: Step 5b - Setting up central FSR4 directories...');
    EnsureFSR4Directories;

    // Copy native upscaler dll to FSR4/Latest
    if FileExists(IncludeTrailingPathDelimiter(OrigPath) + 'amd_fidelityfx_upscaler_dx12.dll') then
    begin
      CopyFile(IncludeTrailingPathDelimiter(OrigPath) + 'amd_fidelityfx_upscaler_dx12.dll',
               IncludeTrailingPathDelimiter(GetFSR4BasePath) + 'Latest' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll');
      WriteLn('[DEBUG] UpdateButtonClick: Copied native upscaler to FSR4/Latest');
    end;

    // Download 4.1.1b alternative upscaler dll
    UpdateStatus('Downloading FSR 4.1.1b');
    if DownloadFile('https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8-411b/amd_fidelityfx_upscaler_dx12.dll',
                    IncludeTrailingPathDelimiter(GetFSR4BasePath) + '4.1.1b' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
      WriteLn('[DEBUG] UpdateButtonClick: Downloaded FSR 4.1.1b')
    else
      WriteLn('[WARN] UpdateButtonClick: Failed to download FSR 4.1.1b DLL');

    // Download 4.0.2c alternative upscaler dll
    UpdateStatus('Downloading FSR 4.0.2c');
    if DownloadFile('https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll',
                    IncludeTrailingPathDelimiter(GetFSR4BasePath) + '4.0.2c' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
      WriteLn('[DEBUG] UpdateButtonClick: Downloaded FSR 4.0.2c')
    else
      WriteLn('[WARN] UpdateButtonClick: Failed to download FSR 4.0.2c DLL');

    // Clean up legacy directories if present
    if DirectoryExists(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_LATEST') then
      DeleteDirectory(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_LATEST', False);
    if DirectoryExists(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_INT8') then
      DeleteDirectory(IncludeTrailingPathDelimiter(OrigPath) + 'FSR4_INT8', False);
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
          ShowMessage(Format(rsVarsReadFailed, [E.Message]));
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

function IsValidSharedLibrary(const APath: string; AMinSizeBytes: Int64 = 65536): Boolean;
var
  FS: TFileStream;
  Magic: array[0..3] of Byte;
begin
  Result := False;
  if not FileExists(APath) then Exit;
  try
    FS := TFileStream.Create(APath, fmOpenRead or fmShareDenyNone);
    try
      if FS.Size < AMinSizeBytes then Exit;
      if FS.Read(Magic, 4) = 4 then
      begin
        // ELF header magic: 0x7F, 'E', 'L', 'F'
        Result := (Magic[0] = $7F) and (Magic[1] = Ord('E')) and (Magic[2] = Ord('L')) and (Magic[3] = Ord('F'));
      end;
    finally
      FS.Free;
    end;
  except
    Result := False;
  end;
end;

procedure SanitizeImplicitVulkanLayers;
var
  DataHome, CandidateDir, CandidateJson, TargetSo, JsonContent: string;
  CandidateDirs: array[0..1] of string;
  SL: TStringList;
  JsonData, LayerObj, PathData: TJSONData;
  d: Integer;
begin
  CandidateDirs[0] := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/';
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome <> '' then
    CandidateDirs[1] := IncludeTrailingPathDelimiter(DataHome) + 'vulkan/implicit_layer.d/'
  else
    CandidateDirs[1] := '';

  for d := 0 to 1 do
  begin
    CandidateDir := CandidateDirs[d];
    if (CandidateDir = '') or (not DirectoryExists(CandidateDir)) then Continue;

    // 1. Sanitize vksumi.json
    CandidateJson := CandidateDir + 'vksumi.json';
    if FileExists(CandidateJson) then
    begin
      TargetSo := '';
      try
        SL := TStringList.Create;
        try
          SL.LoadFromFile(CandidateJson);
          JsonContent := SL.Text;
        finally
          SL.Free;
        end;

        if JsonContent <> '' then
        begin
          JsonData := GetJSON(JsonContent);
          try
            if Assigned(JsonData) then
            begin
              LayerObj := JsonData.FindPath('layer');
              if Assigned(LayerObj) then
              begin
                PathData := LayerObj.FindPath('library_path');
                if Assigned(PathData) then
                  TargetSo := PathData.AsString;
              end;
            end;
          finally
            JsonData.Free;
          end;
        end;
      except
        TargetSo := '';
      end;

      // If library_path is missing, points to a non-existent file, or points to an invalid ELF binary:
      if (TargetSo = '') or (not FileExists(TargetSo)) or (not IsValidSharedLibrary(TargetSo)) then
      begin
        WriteLn('[CLEANUP] Removing corrupted or invalid vkSumi Vulkan layer manifest: ', CandidateJson);
        DeleteFile(CandidateJson);
        if (TargetSo <> '') and FileExists(TargetSo) and (not IsValidSharedLibrary(TargetSo)) then
        begin
          WriteLn('[CLEANUP] Removing corrupted vkSumi shared library file: ', TargetSo);
          DeleteFile(TargetSo);
        end;
      end;
    end;

    // 2. Sanitize MAKO implicit layers: check if library is missing or running in Flatpak
    if FileExists(CandidateDir + 'VkLayer_MAKO_render.json') then
    begin
      if IsRunningInFlatpak or
         ((not FileExists(IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/libmako-render.so')) and
          (not FileExists('/usr/lib/libmako-render.so')) and
          (not FileExists('/usr/lib/x86_64-linux-gnu/libmako-render.so')) and
          (not FileExists('/usr/lib64/libmako-render.so'))) then
      begin
        WriteLn('[CLEANUP] Removing broken or orphaned MAKO layer manifest: ', CandidateDir + 'VkLayer_MAKO_render.json');
        DeleteFile(CandidateDir + 'VkLayer_MAKO_render.json');
        if FileExists(CandidateDir + 'VkLayer_MAKO_render.x86.json') then
          DeleteFile(CandidateDir + 'VkLayer_MAKO_render.x86.json');
        if FileExists(CandidateDir + 'VkLayer_MAKO_spatial_scaling.json') then
          DeleteFile(CandidateDir + 'VkLayer_MAKO_spatial_scaling.json');
        if FileExists(CandidateDir + 'VkLayer_MAKO_spatial_scaling.x86.json') then
          DeleteFile(CandidateDir + 'VkLayer_MAKO_spatial_scaling.x86.json');
      end;
    end;
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
    Process.Parameters.Add('--fail');
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
                    AOnProgress(CurPct, AStatusPrefix);
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
    if (Result <> 0) and FileExists(AOutputFile) then
      DeleteFile(AOutputFile);
  finally
    Process.Free;
  end;

  if (Result = 0) and Assigned(AOnProgress) then
    AOnProgress(AEndPct, AStatusPrefix);
end;

procedure SyncOptiScalerFilesToDlssEnabler(AIsStable: Boolean = True);
var
  OptiDir, DestDir, FsrLatestSrc: string;
  SupportingFiles: array[0..17] of string = (
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_framegeneration_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'amd_fidelityfx_vk.dll',
    'amd_fidelityfx_loader_dx12.dll',
    'libxess.dll',
    'libxess_dx11.dll',
    'libxess_fg.dll',
    'libxell.dll',
    'dlssg_to_fsr3_amd_is_better.dll',
    'fakenvapi.dll',
    'fakenvapi.ini',
    'OptiScaler.ini',
    'OptiScaler.dll',
    'bgmod',
    'bgmod-uninstaller',
    'fgmod',
    'setup_linux.sh'
  );
  SupportingDirs: array[0..3] of string = (
    'D3D12_Optiscaler',
    'D3D12_OptiScaler',
    'plugins',
    'Licenses'
  );
  i: Integer;
  SrcFile, DstFile, SrcSubDir, DstSubDir: string;

  procedure CopyDirRecursive(const ASrc, ADst: string);
  var
    SR: TSearchRec;
    SPath, DPath: string;
  begin
    if not DirectoryExists(ADst) then
      ForceDirectories(ADst);
    SPath := IncludeTrailingPathDelimiter(ASrc);
    DPath := IncludeTrailingPathDelimiter(ADst);
    if FindFirst(SPath + '*', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Name <> '.') and (SR.Name <> '..') then
          begin
            if (SR.Attr and faDirectory) = faDirectory then
              CopyDirRecursive(SPath + SR.Name, DPath + SR.Name)
            else
              CopyFile(SPath + SR.Name, DPath + SR.Name);
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;
begin
  DestDir := IncludeTrailingPathDelimiter(GetDlssEnablerPath(AIsStable));
  ForceDirectories(DestDir);

  if AIsStable then
    OptiDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath)
  else
    OptiDir := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath);

  // If the matching channel OptiScaler directory does not exist or lacks key files, fallback to the other channel
  if not DirectoryExists(OptiDir) or not FileExists(OptiDir + 'amd_fidelityfx_upscaler_dx12.dll') then
  begin
    if not AIsStable and DirectoryExists(GetBGModOriginalPath) and FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'amd_fidelityfx_upscaler_dx12.dll') then
      OptiDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath)
    else if AIsStable and DirectoryExists(GetBGModOriginalEdgePath) and FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'amd_fidelityfx_upscaler_dx12.dll') then
      OptiDir := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath);
  end;

  if not DirectoryExists(OptiDir) then
  begin
    WriteLn('[DLSS-ENABLER] SyncOptiScalerFilesToDlssEnabler: Source OptiScaler directory not found: ', OptiDir);
    Exit;
  end;

  WriteLn('[DLSS-ENABLER] Synchronizing OptiScaler supporting files from ', OptiDir, ' to ', DestDir);

  // Copy individual supporting files
  for i := Low(SupportingFiles) to High(SupportingFiles) do
  begin
    SrcFile := OptiDir + SupportingFiles[i];
    DstFile := DestDir + SupportingFiles[i];

    if FileExists(SrcFile) then
    begin
      CopyFile(SrcFile, DstFile);
      if (SupportingFiles[i] = 'bgmod') or (SupportingFiles[i] = 'bgmod-uninstaller') or
         (SupportingFiles[i] = 'fgmod') or (SupportingFiles[i] = 'setup_linux.sh') then
        fpChmod(DstFile, &755);
    end;
  end;

  // Fallback for amd_fidelityfx_upscaler_dx12.dll from central FSR4/Latest if missing in OptiDir
  if not FileExists(DestDir + 'amd_fidelityfx_upscaler_dx12.dll') then
  begin
    FsrLatestSrc := IncludeTrailingPathDelimiter(GetFSR4BasePath) + 'Latest' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll';
    if FileExists(FsrLatestSrc) then
      CopyFile(FsrLatestSrc, DestDir + 'amd_fidelityfx_upscaler_dx12.dll');
  end;

  // Copy DLSS files if not already present in DestDir
  if not FileExists(DestDir + 'nvngx_dlss.dll') and FileExists(OptiDir + 'nvngx_dlss.dll') then
    CopyFile(OptiDir + 'nvngx_dlss.dll', DestDir + 'nvngx_dlss.dll');
  if not FileExists(DestDir + 'nvngx_dlssd.dll') and FileExists(OptiDir + 'nvngx_dlssd.dll') then
    CopyFile(OptiDir + 'nvngx_dlssd.dll', DestDir + 'nvngx_dlssd.dll');
  if not FileExists(DestDir + 'nvngx_dlssg.dll') and FileExists(OptiDir + 'nvngx_dlssg.dll') then
    CopyFile(OptiDir + 'nvngx_dlssg.dll', DestDir + 'nvngx_dlssg.dll');

  // Copy supporting directories
  for i := Low(SupportingDirs) to High(SupportingDirs) do
  begin
    SrcSubDir := OptiDir + SupportingDirs[i];
    DstSubDir := DestDir + SupportingDirs[i];
    if DirectoryExists(SrcSubDir) then
      CopyDirRecursive(SrcSubDir, DstSubDir);
  end;
end;

function CheckAndInstallDlssEnabler(AIsStable: Boolean = True; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  DestDir, VarsFilePath, DownloadUrl, TagName, ZipFile, TargetKeyword, ItemName, Response, TmpFile: string;
  DummyStableVer, DummyStableURL, DummyEdgeVer, DummyEdgeURL: string;
  Process: TProcess;
  VarsList, OutputList: TStringList;
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
    ChanLabel := 'Downloading DLSS-Enabler stable';
    StartPct := 40;
    EndPct := 70;
  end
  else
  begin
    ChanLabel := 'Downloading DLSS-Enabler edge';
    StartPct := 40;
    EndPct := 70;
  end;

  if not AForce and FileExists(VarsFilePath) and AlreadyExtracted then
  begin
    // Check if critical supporting files are missing (self-healing)
    if not FileExists(DestDir + 'dlssg_to_fsr3_amd_is_better.dll') or
       not FileExists(DestDir + 'amd_fidelityfx_upscaler_dx12.dll') or
       not FileExists(DestDir + 'fakenvapi.dll') or
       not FileExists(DestDir + 'libxess.dll') then
    begin
      WriteLn('[DLSS-ENABLER] Existing cache missing supporting libraries, running self-healing sync...');
      SyncOptiScalerFilesToDlssEnabler(AIsStable);
    end;

    if Assigned(AOnProgress) then
      AOnProgress(EndPct, ChanLabel);
    Result := True;
    Exit;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel);

  ForceDirectories(DestDir);
  if AIsStable then
    TargetKeyword := 'STABLE'
  else
    TargetKeyword := 'TRUNK';

  TagName := '';
  DownloadUrl := '';

  // 1. Try manifest first (versions.json from CDN)
  if Assigned(goverlayform) and Assigned(goverlayform.FOptiscalerUpdate) then
  begin
    if AIsStable and (goverlayform.FOptiscalerUpdate.FDlssStableURL <> '') then
    begin
      DownloadUrl := goverlayform.FOptiscalerUpdate.FDlssStableURL;
      TagName     := goverlayform.FOptiscalerUpdate.FDlssStableVersion;
    end
    else if (not AIsStable) and (goverlayform.FOptiscalerUpdate.FDlssEdgeURL <> '') then
    begin
      DownloadUrl := goverlayform.FOptiscalerUpdate.FDlssEdgeURL;
      TagName     := goverlayform.FOptiscalerUpdate.FDlssEdgeVersion;
    end;
  end;

  if (DownloadUrl = '') and Assigned(goverlayform) and Assigned(goverlayform.FOptiscalerUpdate) then
  begin
    goverlayform.FOptiscalerUpdate.FetchManifest(True, DummyStableVer, DummyStableURL, DummyEdgeVer, DummyEdgeURL);
    if AIsStable and (goverlayform.FOptiscalerUpdate.FDlssStableURL <> '') then
    begin
      DownloadUrl := goverlayform.FOptiscalerUpdate.FDlssStableURL;
      TagName     := goverlayform.FOptiscalerUpdate.FDlssStableVersion;
    end
    else if (not AIsStable) and (goverlayform.FOptiscalerUpdate.FDlssEdgeURL <> '') then
    begin
      DownloadUrl := goverlayform.FOptiscalerUpdate.FDlssEdgeURL;
      TagName     := goverlayform.FOptiscalerUpdate.FDlssEdgeVersion;
    end;
  end;

  if DownloadUrl <> '' then
    WriteLn('[DLSS-ENABLER] Found URL from versions.json manifest: ', DownloadUrl)
  else
  begin
    WriteLn('[DLSS-ENABLER] Fetching builds list via HTML directory scraping (bypassing GitHub API)...');
    Process := TProcess.Create(nil);
    OutputList := TStringList.Create;
    TmpFile := IncludeTrailingPathDelimiter(GetTempDir) + 'goverlay_de_install.html';
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: goverlay');
      Process.Parameters.Add('-o');
      Process.Parameters.Add(TmpFile);
      Process.Parameters.Add('https://github.com/benjamimgois/OptiScaler-builds/tree/nightly-action/de');
      Process.Options := [poWaitOnExit];
      Process.Execute;
      if FileExists(TmpFile) then
      begin
        OutputList.LoadFromFile(TmpFile);
        Response := OutputList.Text;
        DeleteFile(TmpFile);
      end;
    finally
      OutputList.Free;
      Process.Free;
    end;

    StartPos := 1;
    while True do
    begin
      NamePos := PosEx('DLSS%20Enabler%20', Response, StartPos);
      if NamePos = 0 then
        NamePos := PosEx('/benjamimgois/OptiScaler-builds/blob/nightly-action/de/', Response, StartPos);
      if NamePos = 0 then Break;

      if Copy(Response, NamePos, 17) = 'DLSS%20Enabler%20' then
      begin
        StartPos := NamePos;
        EndPos := PosEx('.zip', Response, StartPos);
        if EndPos = 0 then Break;
        ItemName := Copy(Response, StartPos, EndPos + 4 - StartPos);
        ItemName := StringReplace(ItemName, '%20', ' ', [rfReplaceAll]);
      end
      else
      begin
        StartPos := NamePos + Length('/benjamimgois/OptiScaler-builds/blob/nightly-action/de/');
        EndPos := PosEx('"', Response, StartPos);
        if EndPos = 0 then Break;
        ItemName := Copy(Response, StartPos, EndPos - StartPos);
        ItemName := StringReplace(ItemName, '%20', ' ', [rfReplaceAll]);
      end;

      if (Pos(TargetKeyword, ItemName) > 0) and (Pos('DLSS', ItemName) > 0) then
      begin
        NamePos := Pos('DLSS Enabler ', ItemName);
        if NamePos > 0 then
        begin
          NamePos := NamePos + Length('DLSS Enabler ');
          SpacePos := PosEx(' ', ItemName, NamePos);
          if SpacePos > NamePos then
            TagName := Copy(ItemName, NamePos, SpacePos - NamePos);
        end;

        DownloadUrl := 'https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/' + StringReplace(ItemName, ' ', '%20', [rfReplaceAll]);
        WriteLn('[DLSS-ENABLER] HTML directory scraping found URL: ', DownloadUrl);
        Break;
      end;
      StartPos := EndPos + 1;
    end;
  end;

  if TagName = '' then
  begin
    if AIsStable then TagName := '4.8.12' else TagName := '4.8.13.6';
  end;

  if DownloadUrl = '' then
  begin
    if AIsStable then
      DownloadUrl := 'https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.12%20STABLE%20757%204.8.12%202026-07-26T18-01Z%20K8HToGjQv.zip'
    else
      DownloadUrl := 'https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.13.6%20RC2%20TRUNK.zip';
  end;

  ZipFile := DestDir + 'dlssenabler.zip';
  WriteLn('[DLSS-ENABLER] Downloading ', DownloadUrl, ' to ', ZipFile);

  RunCurlWithProgress(DownloadUrl, ZipFile, StartPct, EndPct, ChanLabel + ' (core)', AOnProgress);

  if FileExists(ZipFile) then
  begin
    if FileSize(ZipFile) < 10000 then
    begin
      WriteLn('[DLSS-ENABLER] ERROR: Download failed or corrupt archive (size < 10KB)');
      DeleteFile(ZipFile);
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('version.dll (DLSS Enabler)') = -1) then
        AFailedFiles.Add('version.dll (DLSS Enabler)');
      Result := False;
      Exit;
    end;

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
  end
  else
  begin
    WriteLn('[DLSS-ENABLER] ERROR: dlssenabler.zip not found after download');
    if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('version.dll (DLSS Enabler)') = -1) then
      AFailedFiles.Add('version.dll (DLSS Enabler)');
    Result := False;
    Exit;
  end;

  if not FileExists(DestDir + 'version.dll') then
  begin
    WriteLn('[DLSS-ENABLER] ERROR: version.dll not found after extraction');
    if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('version.dll (DLSS Enabler)') = -1) then
      AFailedFiles.Add('version.dll (DLSS Enabler)');
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
  SyncOptiScalerFilesToDlssEnabler(AIsStable);

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

function CheckAndInstallFsr4(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  BaseDir, LatestPath, Ver411bPath, Ver402cPath, OrigDll: string;
  AllPresent: Boolean;
  ExitCode: Integer;
begin
  Result := True;
  BaseDir := IncludeTrailingPathDelimiter(GetFSR4BasePath);
  EnsureFSR4Directories;

  LatestPath := BaseDir + 'Latest' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll';
  Ver411bPath := BaseDir + '4.1.1b' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll';
  Ver402cPath := BaseDir + '4.0.2c' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll';

  AllPresent := FileExists(LatestPath) and FileExists(Ver411bPath) and FileExists(Ver402cPath);

  if not AForce and AllPresent then
  begin
    WriteLn('[FSR4] All FSR4 libraries are present in ', BaseDir);
    Exit(True);
  end;

  WriteLn('[FSR4] Verifying and downloading FSR4 libraries...');

  // 1. Latest: copy from OptiScaler stable cache if missing
  if AForce or not FileExists(LatestPath) then
  begin
    OrigDll := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'amd_fidelityfx_upscaler_dx12.dll';
    if FileExists(OrigDll) then
    begin
      CopyFile(OrigDll, LatestPath);
      WriteLn('[FSR4] Copied native upscaler to FSR4/Latest');
    end
    else
    begin
      WriteLn('[FSR4] Warning: native upscaler not found in ', OrigDll);
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('amd_fidelityfx_upscaler_dx12.dll (FSR4 Latest)') = -1) then
        AFailedFiles.Add('amd_fidelityfx_upscaler_dx12.dll (FSR4 Latest)');
      Result := False;
    end;
  end;

  // 2. FSR 4.1.1b
  if AForce or not FileExists(Ver411bPath) then
  begin
    if Assigned(AOnProgress) then
      AOnProgress(35, 'Downloading FSR 4.1.1b');
    ExitCode := RunCurlWithProgress(
      'https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8-411b/amd_fidelityfx_upscaler_dx12.dll',
      Ver411bPath, 35, 42, 'Downloading FSR 4.1.1b', AOnProgress);
    if (ExitCode <> 0) or not FileExists(Ver411bPath) then
    begin
      WriteLn('[FSR4] Failed to download FSR 4.1.1b');
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('amd_fidelityfx_upscaler_dx12.dll (FSR 4.1.1b)') = -1) then
        AFailedFiles.Add('amd_fidelityfx_upscaler_dx12.dll (FSR 4.1.1b)');
      Result := False;
    end
    else
      WriteLn('[FSR4] Successfully downloaded FSR 4.1.1b');
  end;

  // 3. FSR 4.0.2c
  if AForce or not FileExists(Ver402cPath) then
  begin
    if Assigned(AOnProgress) then
      AOnProgress(43, 'Downloading FSR 4.0.2c');
    ExitCode := RunCurlWithProgress(
      'https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll',
      Ver402cPath, 43, 50, 'Downloading FSR 4.0.2c', AOnProgress);
    if (ExitCode <> 0) or not FileExists(Ver402cPath) then
    begin
      WriteLn('[FSR4] Failed to download FSR 4.0.2c');
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('amd_fidelityfx_upscaler_dx12.dll (FSR 4.0.2c)') = -1) then
        AFailedFiles.Add('amd_fidelityfx_upscaler_dx12.dll (FSR 4.0.2c)');
      Result := False;
    end
    else
      WriteLn('[FSR4] Successfully downloaded FSR 4.0.2c');
  end;

  // Clean up legacy directories if present
  if DirectoryExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'FSR4_LATEST') then
    DeleteDirectory(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'FSR4_LATEST', False);
  if DirectoryExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'FSR4_INT8') then
    DeleteDirectory(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'FSR4_INT8', False);
end;

function EnsureHelixSRCompanionLibraries(const ATargetDir: string): Boolean;
var
  TargetDir, StableDir, LicensePath: string;
  LicenseLines: TStringList;
begin
  Result := False;

  if Trim(ATargetDir) = '' then
    TargetDir := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath)
  else
    TargetDir := IncludeTrailingPathDelimiter(Trim(ATargetDir));

  if not DirectoryExists(TargetDir) and not ForceDirectories(TargetDir) then
    Exit;

  // Synchronize companion libraries from the stable OptiScaler cache so that
  // even if the upstream archive lacks optiscaler/OptiScaler.dll it is populated.
  StableDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath);
  if DirectoryExists(StableDir) then
  begin
    ForceDirectories(TargetDir + 'optiscaler');
    if not FileExists(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll') and FileExists(StableDir + 'OptiScaler.dll') then
      CopyFile(StableDir + 'OptiScaler.dll', TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll');
    if not FileExists(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.dll') and FileExists(StableDir + 'fakenvapi.dll') then
      CopyFile(StableDir + 'fakenvapi.dll', TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.dll');
    if not FileExists(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.ini') and FileExists(StableDir + 'fakenvapi.ini') then
      CopyFile(StableDir + 'fakenvapi.ini', TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.ini');
  end;

  // Always redistribute the HelixSR Freeware License alongside the runtime.
  LicensePath := TargetDir + 'LICENSE';
  if not FileExists(LicensePath) then
  begin
    LicenseLines := TStringList.Create;
    try
      LicenseLines.Text := GetHelixSRLicenseText;
      try
        LicenseLines.SaveToFile(LicensePath);
        Result := True;
      except
        Result := False;
      end;
    finally
      LicenseLines.Free;
    end;
  end
  else
    Result := True;
end;

function GetHelixSRDx12DllPath(const ARootPath: string): string;
var
  Root: string;
begin
  Root := IncludeTrailingPathDelimiter(ARootPath);
  Result := Root + 'HelixSR-fsrfg' + PathDelim + 'amd_fidelityfx_dx12.dll';
  if not FileExists(Result) then
    Result := Root + 'amd_fidelityfx_dx12.dll';
end;

function CheckAndInstallHelixSR(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  TargetDir, Dx12Dll, OptiDll, SetupScript: string;
  Tag, DownloadUrl, TempZip, TempExtract, SubDir: string;
  Process: TProcess;
  ExitCode: Integer;
  VarsPath: string;
  VarsList: TStringList;
  Scan: TSearchRec;

  procedure CopyDirectoryTree(const ASrc, ADst: string);
  var
    SR: TSearchRec;
    SPath, DPath: string;
  begin
    if not DirectoryExists(ADst) then
      ForceDirectories(ADst);
    SPath := IncludeTrailingPathDelimiter(ASrc);
    DPath := IncludeTrailingPathDelimiter(ADst);
    if FindFirst(SPath + '*', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Name <> '.') and (SR.Name <> '..') then
          begin
            if (SR.Attr and faDirectory) = faDirectory then
              CopyDirectoryTree(SPath + SR.Name, DPath + SR.Name)
            else
              CopyFile(SPath + SR.Name, DPath + SR.Name);
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

  procedure PromoteHelixSRPayloads;
  begin
    // Promote HelixSR-fsrfg payloads to the runtime root when needed.
    if FileExists(TargetDir + 'HelixSR-fsrfg' + PathDelim + 'amd_fidelityfx_dx12.dll') and
       (not FileExists(TargetDir + 'amd_fidelityfx_dx12.dll') or AForce) then
      CopyFile(TargetDir + 'HelixSR-fsrfg' + PathDelim + 'amd_fidelityfx_dx12.dll',
        TargetDir + 'amd_fidelityfx_dx12.dll');
    if FileExists(TargetDir + 'HelixSR-fsrfg' + PathDelim + 'helixsr.ini') and
       not FileExists(TargetDir + 'helixsr.ini') then
      CopyFile(TargetDir + 'HelixSR-fsrfg' + PathDelim + 'helixsr.ini', TargetDir + 'helixsr.ini');
    if FileExists(TargetDir + 'helixsr-scaler' + PathDelim + 'OptiScaler.dll') and
       not FileExists(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll') then
    begin
      ForceDirectories(TargetDir + 'optiscaler');
      CopyFile(TargetDir + 'helixsr-scaler' + PathDelim + 'OptiScaler.dll',
        TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll');
    end;
  end;
begin
  Result := True;
  TargetDir := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath);
  ForceDirectories(TargetDir);

  Dx12Dll := GetHelixSRDx12DllPath(TargetDir);
  OptiDll := TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll';
  SetupScript := TargetDir + 'helixsr-setup.sh';

  // Synchronize companion libraries from the stable OptiScaler cache and make
  // sure the HelixSR Freeware License ships alongside the runtime.
  EnsureHelixSRCompanionLibraries(TargetDir);

  // Mirror the v2 layout before deciding whether a download is needed so an
  // existing HelixSR-fsrfg runtime is promoted to the root path.
  PromoteHelixSRPayloads;

  if not AForce and FileExists(Dx12Dll) and (IsHelixSRCompiled(TargetDir) or (FileExists(SetupScript) and FileExists(OptiDll))) then
  begin
    WriteLn('[HELIXSR] HelixSR runtime and companion libraries are satisfied in ', TargetDir);
    Exit(True);
  end;

  WriteLn('[HELIXSR] Verifying and downloading HelixSR release (lonewolf0622/HelixSR)...');
  if Assigned(AOnProgress) then
    AOnProgress(45, 'Downloading HelixSR runtime...');

  Tag := '';
  DownloadUrl := '';
  FetchHelixSRLatestRelease(Tag, DownloadUrl);

  // Only fall back to the baseline release URL on an initial installation
  // (i.e. when no HelixSR runtime is present yet) so an existing build is
  // never downgraded just because remote discovery failed.
  if DownloadUrl = '' then
  begin
    if not FileExists(Dx12Dll) then
    begin
      Tag := 'v1.9.0';
      DownloadUrl := 'https://github.com/lonewolf0622/HelixSR/releases/download/v1.9.0/HelixSR-1.9.0.zip';
    end;
  end;
  if Tag = '' then
    Tag := 'v1.9.0';

  if DownloadUrl = '' then
  begin
    WriteLn('[HELIXSR] No download URL available; keeping existing runtime');
    Exit(FileExists(Dx12Dll));
  end;

  TempZip := IncludeTrailingPathDelimiter(GetTempDir) + 'helixsr_download.zip';
  TempExtract := IncludeTrailingPathDelimiter(GetTempDir) + 'helixsr_extract' + PathDelim;
  if FileExists(TempZip) then
    DeleteFile(TempZip);
  if DirectoryExists(TempExtract) then
    DeleteDirectory(TempExtract, False);

  ExitCode := RunCurlWithProgress(DownloadUrl, TempZip, 46, 54, 'Downloading HelixSR', AOnProgress);
  if (ExitCode <> 0) or not FileExists(TempZip) then
  begin
    WriteLn('[HELIXSR] ERROR: Failed to download HelixSR from ', DownloadUrl);
    if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('HelixSR (OptiScaler & DLSS Model E runtime)') = -1) then
      AFailedFiles.Add('HelixSR (OptiScaler & DLSS Model E runtime)');
    Exit(False);
  end;

  ForceDirectories(TempExtract);
  Process := TProcess.Create(nil);
  try
    Process.Executable := '7z';
    Process.Parameters.Add('x');
    Process.Parameters.Add('-y');
    Process.Parameters.Add(TempZip);
    Process.Parameters.Add('-o' + ExcludeTrailingPathDelimiter(TempExtract));
    Process.Options := [poWaitOnExit];
    Process.Execute;
  finally
    Process.Free;
  end;

  // If the archive wraps its payload in a HelixSR-* subfolder, deploy that
  // subfolder's contents; otherwise deploy straight from the extract root.
  SubDir := '';
  if FindFirst(TempExtract + 'HelixSR-*', faDirectory, Scan) = 0 then
  begin
    try
      if (Scan.Name <> '.') and (Scan.Name <> '..') and ((Scan.Attr and faDirectory) = faDirectory) then
        SubDir := IncludeTrailingPathDelimiter(TempExtract) + Scan.Name;
    finally
      FindClose(Scan);
    end;
  end;

  if SubDir <> '' then
    CopyDirectoryTree(SubDir, TargetDir)
  else
    CopyDirectoryTree(TempExtract, TargetDir);

  // Clean up temp files
  if FileExists(TempZip) then
    DeleteFile(TempZip);
  if DirectoryExists(TempExtract) then
    DeleteDirectory(TempExtract, False);

  // Persist version tag in goverlay.vars
  VarsPath := TargetDir + 'goverlay.vars';
  VarsList := TStringList.Create;
  try
    if FileExists(VarsPath) then
      VarsList.LoadFromFile(VarsPath);
    VarsList.Values['OPTISCALER_HELIXSR_VERSION'] := Tag;
    VarsList.SaveToFile(VarsPath);
  finally
    VarsList.Free;
  end;

  // Synchronize companion libraries from stable OptiScaler cache so that even
  // if the upstream archive lacks optiscaler/OptiScaler.dll it is populated.
  // Also (re)writes the HelixSR Freeware License as <TargetDir>/LICENSE.
  EnsureHelixSRCompanionLibraries(TargetDir);

  // Ensure scripts and binaries have execution permissions
  fpChmod(PChar(TargetDir + 'helixsr-setup.sh'), &755);
  fpChmod(PChar(TargetDir + 'helixsr-uninstall.sh'), &755);
  if FileExists(TargetDir + 'setup/lib/model/launch_synth') then
    fpChmod(PChar(TargetDir + 'setup/lib/model/launch_synth'), &755);

  // Copy OptiScaler.dll and fakenvapi companion files to root if present in optiscaler subfolder
  if FileExists(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll') and not FileExists(TargetDir + 'OptiScaler.dll') then
    CopyFile(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll', TargetDir + 'OptiScaler.dll');
  if FileExists(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.dll') and not FileExists(TargetDir + 'fakenvapi.dll') then
    CopyFile(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.dll', TargetDir + 'fakenvapi.dll');
  if FileExists(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.ini') and not FileExists(TargetDir + 'fakenvapi.ini') then
    CopyFile(TargetDir + 'optiscaler' + PathDelim + 'fakenvapi.ini', TargetDir + 'fakenvapi.ini');

  PromoteHelixSRPayloads;

  Dx12Dll := GetHelixSRDx12DllPath(TargetDir);
  OptiDll := TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll';

  if not FileExists(Dx12Dll) or not FileExists(OptiDll) then
  begin
    WriteLn('[HELIXSR] ERROR: Extraction completed but mandatory DLLs missing');
    if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('HelixSR (OptiScaler & DLSS Model E runtime)') = -1) then
      AFailedFiles.Add('HelixSR (OptiScaler & DLSS Model E runtime)');
    Result := False;
  end
  else
    WriteLn('[HELIXSR] Successfully installed HelixSR release ', Tag);
end;

// Check whether the HelixSR neural runtime has been compiled locally.
// Returns True when amd_fidelityfx_dx12.dll carries the HXSRNET1 footer marker,
// or when the extracted weights/kernels payloads exist and are non-empty.
function IsHelixSRCompiled(const ARootPath: string): Boolean;
var
  Root, DllPath, WeightsPath, KernelsPath: string;
  Stream: TFileStream;
  Buf: array[0..31] of Byte;
  ReadLen: Integer;
  Tail: string;
begin
  Result := False;

  if ARootPath <> '' then
    Root := IncludeTrailingPathDelimiter(ARootPath)
  else
    Root := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath);

  DllPath := GetHelixSRDx12DllPath(Root);
  if FileExists(DllPath) then
  begin
    try
      Stream := TFileStream.Create(DllPath, fmOpenRead or fmShareDenyNone);
      try
        if Stream.Size >= 32 then
        begin
          Stream.Position := Stream.Size - 32;
          ReadLen := Stream.Read(Buf, SizeOf(Buf));
          if ReadLen > 0 then
          begin
            SetLength(Tail, ReadLen);
            Move(Buf[0], Tail[1], ReadLen);
            if Pos('HXSRNET1', Tail) > 0 then
              Exit(True);
          end;
        end;
      finally
        Stream.Free;
      end;
    except
      // Unreadable/corrupt DLL: fall through to the payload-based check.
    end;
  end;

  WeightsPath := Root + 'helixsr_weights.bin';
  KernelsPath := Root + 'helixsr_kernels.pak';
  if FileExists(WeightsPath) and FileExists(KernelsPath) then
  begin
    Result := False;
    try
      Stream := TFileStream.Create(WeightsPath, fmOpenRead or fmShareDenyNone);
      try
        Result := Stream.Size > 0;
      finally
        Stream.Free;
      end;
    except
      Result := False;
    end;
    if Result then
    begin
      Result := False;
      try
        Stream := TFileStream.Create(KernelsPath, fmOpenRead or fmShareDenyNone);
        try
          Result := Stream.Size > 0;
        finally
          Stream.Free;
        end;
      except
        Result := False;
      end;
    end;
  end;
end;

// Resolve the HelixSR data directory (honours XDG_DATA_HOME).
function GetHelixSRDataDir: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if Trim(DataHome) = '' then
    Result := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share' + PathDelim + 'HelixSR'
  else
    Result := IncludeTrailingPathDelimiter(DataHome) + 'HelixSR';
end;

function GetHelixSRLastCompileError: string;
begin
  Result := FHelixSRLastCompileError;
end;

procedure ClearHelixSRLastCompileError;
begin
  FHelixSRLastCompileError := '';
end;

procedure CleanHelixSRWinePrefix;
var
  PrefixDir: string;
begin
  PrefixDir := IncludeTrailingPathDelimiter(GetHelixSRDataDir) + 'wineprefix';
  if DirectoryExists(PrefixDir) then
  begin
    WriteLn('[HELIXSR] Removing stale Wine prefix: ', PrefixDir);
    DeleteDirectory(PrefixDir, False);
  end;
end;

function IsWineExecutableValid(const AWinePath: string): Boolean;
var
  Process: TProcess;
begin
  Result := False;
  if Trim(AWinePath) = '' then Exit;
  if not FileExists(AWinePath) then Exit;
  try
    Process := TProcess.Create(nil);
    try
      Process.Executable := AWinePath;
      Process.Parameters.Add('--version');
      Process.Options := [poWaitOnExit];
      Process.Execute;
      Result := Process.ExitStatus = 0;
    finally
      Process.Free;
    end;
  except
    Result := False;
  end;
end;

function FindWorkingWineForHelixSR: string;
var
  Candidates: TStringList;
  HomeDir, EnvWine, Candidate: string;
  I: Integer;

  procedure AddCandidate(const APath: string);
  begin
    if (Trim(APath) <> '') and (Candidates.IndexOf(APath) < 0) then
      Candidates.Add(APath);
  end;

  procedure AddDirCandidates(const ADirPattern, ASubPath: string);
  var
    SR: TSearchRec;
    BaseDir: string;
  begin
    BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(ADirPattern));
    if FindFirst(ADirPattern, faDirectory, SR) = 0 then
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) = faDirectory) then
          AddCandidate(IncludeTrailingPathDelimiter(BaseDir + SR.Name) + ASubPath);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

begin
  Result := '';
  Candidates := TStringList.Create;
  try
    HomeDir := IncludeTrailingPathDelimiter(GetUserDir);

    // 1) Explicitly supplied runtime.
    EnvWine := Trim(GetEnvironmentVariable('HELIXSR_WINE'));
    if (EnvWine <> '') and FileExists(EnvWine) then
      AddCandidate(EnvWine);

    // 2) Native system Wine.
    AddCandidate('/usr/bin/wine');
    AddCandidate('/usr/local/bin/wine');

    // 3) Steam custom compatibility tools (Proton-GE and friends).
    AddDirCandidates(HomeDir + '.local/share/Steam/compatibilitytools.d/*', 'files/bin/wine');
    AddDirCandidates(HomeDir + '.steam/root/compatibilitytools.d/*', 'files/bin/wine');

    // 4) Official stable Proton builds.
    AddCandidate(HomeDir + '.local/share/Steam/steamapps/common/Proton 9.0/files/bin/wine');
    AddCandidate(HomeDir + '.local/share/Steam/steamapps/common/Proton - Experimental/files/bin/wine');

    // 5) Any other Proton build as a last resort.
    AddDirCandidates(HomeDir + '.local/share/Steam/steamapps/common/Proton*', 'files/bin/wine');

    for I := 0 to Candidates.Count - 1 do
    begin
      Candidate := Candidates[I];
      if FileExists(Candidate) and IsWineExecutableValid(Candidate) then
        Exit(Candidate);
    end;
  finally
    Candidates.Free;
  end;
end;

procedure SanitizeHelixSRSetupScript(const AWorkDir: string);
var
  ScriptPath, OriginalText, NewText: string;
  Lines: TStringList;
  I, WineLine, EndLine, FirstProtonLine, Deletes: Integer;
  HasCleanupBefore: Boolean;

  function FindLineContaining(const ANeedle: string; AStart: Integer): Integer;
  var
    J: Integer;
  begin
    Result := -1;
    for J := AStart to Lines.Count - 1 do
      if Pos(ANeedle, Lines[J]) > 0 then
      begin
        Result := J;
        Exit;
      end;
  end;

begin
  ScriptPath := IncludeTrailingPathDelimiter(AWorkDir) + 'helixsr-setup.sh';
  if not FileExists(ScriptPath) then Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(ScriptPath);
    OriginalText := Lines.Text;

    // 1) Locate the Wine discovery block.
    WineLine := FindLineContaining('WINE=""', 0);
    if WineLine < 0 then
      WineLine := FindLineContaining('for p in', 0);

    // 2) Purge a stale prefix before any Wine setup (idempotent).
    HasCleanupBefore := False;
    if WineLine >= 0 then
    begin
      for I := 0 to WineLine do
        if Pos('rm -rf "$DATA/wineprefix"', Lines[I]) > 0 then
        begin
          HasCleanupBefore := True;
          Break;
        end;
    end;
    if not HasCleanupBefore then
    begin
      if WineLine < 0 then
        WineLine := FindLineContaining('# --- shader compiler', 0);
      if WineLine >= 0 then
        Lines.Insert(WineLine, 'rm -rf "$DATA/wineprefix"   # GOverlay: purge stale Wine prefix before setup');
    end;

    // 3) Replace the discovery block with a validated, prioritised fallback.
    WineLine := FindLineContaining('WINE=""', 0);
    if WineLine >= 0 then
    begin
      EndLine := -1;
      for I := WineLine + 1 to Lines.Count - 1 do
        if (Pos('[ -n "$WINE" ]', Lines[I]) > 0) or (Pos('no Proton or Wine found', Lines[I]) > 0) then
        begin
          EndLine := I;
          Break;
        end;
      if EndLine <= WineLine then
        EndLine := WineLine + 1;

      Deletes := EndLine - WineLine - 1;
      for I := 1 to Deletes do
        Lines.Delete(WineLine + 1);

      Lines.Insert(WineLine + 1, '# GOverlay: honour a pre-validated runtime supplied by GOverlay');
      Lines.Insert(WineLine + 2, 'if [ -n "${HELIXSR_WINE:-}" ] && [ -x "$HELIXSR_WINE" ]; then WINE="$HELIXSR_WINE"; fi');
      Lines.Insert(WineLine + 3, '# GOverlay: prefer a working system Wine before unverified Proton builds');
      Lines.Insert(WineLine + 4, 'if [ -z "$WINE" ] && command -v wine >/dev/null 2>&1; then WINE=$(command -v wine); fi');
      Lines.Insert(WineLine + 5, '# GOverlay: stable official Proton builds next');
      Lines.Insert(WineLine + 6, 'if [ -z "$WINE" ]; then');
      Lines.Insert(WineLine + 7, '    for p in "$HOME"/.local/share/Steam/steamapps/common/Proton\ 9.0/files/bin/wine \');
      Lines.Insert(WineLine + 8, '             "$HOME"/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/files/bin/wine \');
      Lines.Insert(WineLine + 9, '             "$HOME"/.steam/steam/steamapps/common/Proton\ 9.0/files/bin/wine \');
      Lines.Insert(WineLine + 10, '             "$HOME"/.steam/steam/steamapps/common/Proton\ -\ Experimental/files/bin/wine; do');
      Lines.Insert(WineLine + 11, '        if [ -x "$p" ]; then WINE="$p"; break; fi');
      Lines.Insert(WineLine + 12, '    done');
      Lines.Insert(WineLine + 13, 'fi');
      Lines.Insert(WineLine + 14, '# GOverlay: custom compatibility tools, then remaining Proton builds');
      Lines.Insert(WineLine + 15, 'if [ -z "$WINE" ]; then');
      Lines.Insert(WineLine + 16, '    for p in "$HOME"/.local/share/Steam/compatibilitytools.d/*/files/bin/wine \');
      Lines.Insert(WineLine + 17, '             "$HOME"/.steam/root/compatibilitytools.d/*/files/bin/wine \');
      Lines.Insert(WineLine + 18, '             "$HOME"/.local/share/Steam/steamapps/common/Proton*/files/bin/wine \');
      Lines.Insert(WineLine + 19, '             "$HOME"/.steam/steam/steamapps/common/Proton*/files/bin/wine; do');
      Lines.Insert(WineLine + 20, '        if [ -x "$p" ]; then WINE="$p"; break; fi');
      Lines.Insert(WineLine + 21, '    done');
      Lines.Insert(WineLine + 22, 'fi');
    end
    else
    begin
      // Fallback for an unexpected script layout: ensure HELIXSR_WINE and a
      // system-Wine probe precede the first Proton glob.
      FirstProtonLine := FindLineContaining('for p in', 0);
      if (FirstProtonLine >= 0) and (Pos('HELIXSR_WINE', Lines.Text) = 0) then
      begin
        Lines.Insert(FirstProtonLine, 'if [ -n "${HELIXSR_WINE:-}" ] && [ -x "$HELIXSR_WINE" ]; then WINE="$HELIXSR_WINE"; fi');
        Lines.Insert(FirstProtonLine + 1, 'if [ -z "$WINE" ] && command -v wine >/dev/null 2>&1; then WINE=$(command -v wine); fi');
      end;
    end;

    NewText := Lines.Text;

    // 4) Force win64 in the generated DXC wrapper.
    if Pos('WINEARCH=win64', NewText) = 0 then
    begin
      if Pos('WINEPREFIX="$DATA/wineprefix" WINEDEBUG=-all exec', NewText) > 0 then
        NewText := StringReplace(NewText, 'WINEPREFIX="$DATA/wineprefix" WINEDEBUG=-all exec',
          'WINEARCH=win64 WINEPREFIX="$DATA/wineprefix" WINEDEBUG=-all exec', [rfReplaceAll])
      else if Pos('WINEPREFIX="$DATA/wineprefix"', NewText) > 0 then
        NewText := StringReplace(NewText, 'WINEPREFIX="$DATA/wineprefix"',
          'WINEARCH=win64 WINEPREFIX="$DATA/wineprefix"', [rfReplaceAll]);
    end;

    if NewText <> OriginalText then
    begin
      Lines.Text := NewText;
      try
        Lines.SaveToFile(ScriptPath);
        WriteLn('[HELIXSR] Sanitized helixsr-setup.sh Wine/Proton discovery and prefix handling.');
      except
        on E: Exception do
          WriteLn('[HELIXSR] WARNING: could not write sanitized helixsr-setup.sh: ', E.Message);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

// Compile the HelixSR neural shaders/kernels on demand. Runs the bundled
// helixsr-setup.sh in the HelixSR runtime path and reports staged progress.
function CompileHelixSR(AOnProgress: TDownloadProgressProc): Boolean;
var
  WorkDir: string;
  Process: TProcess;
  Buffer: array[0..4095] of Byte;
  Count, i: Integer;
  Pending, Line, L, Cmd, WinePath: string;

  procedure EmitLine(const ALine: string);
  var
    PctPos, StartPos, PctVal: Integer;
    PctStr, LabelStr: string;
  begin
    L := LowerCase(ALine);

    // 0. Capture Wine/DXC failure signatures for actionable diagnostics.
    if Pos('c0000135', L) > 0 then
      FHelixSRLastCompileError := 'Wine prefix initialization failed (c0000135 STATUS_DLL_NOT_FOUND: kernel32.dll could not be loaded).'
    else if Pos('kernel32', L) > 0 then
      FHelixSRLastCompileError := 'Wine could not load kernel32.dll; the selected Wine/Proton runtime is unusable on this host.'
    else if Pos('could not open working directory', L) > 0 then
      FHelixSRLastCompileError := 'Wine could not open the prefix working directory (C:\windows\system32\).'
    else if Pos('no proton or wine found', L) > 0 then
      FHelixSRLastCompileError := 'No working Wine or Proton runtime was found for the shader compiler.'
    else if (Pos('dxc-wine.sh', L) > 0) and (Pos('failed', L) > 0) then
      FHelixSRLastCompileError := 'The DirectX Shader Compiler wrapper (dxc-wine.sh) failed to run through Wine/Proton.';

    if not Assigned(AOnProgress) then Exit;

    // 1. Detect percentage if emitted by helixsr_setup.py: "[helixsr-setup] [###---]  35% 0:12 extract weights"
    PctPos := Pos('%', ALine);
    if PctPos > 1 then
    begin
      StartPos := PctPos - 1;
      while (StartPos >= 1) and (ALine[StartPos] in ['0'..'9', ' ']) do
        Dec(StartPos);
      PctStr := Trim(Copy(ALine, StartPos + 1, PctPos - StartPos - 1));
      PctVal := StrToIntDef(PctStr, -1);
      if (PctVal >= 0) and (PctVal <= 100) then
      begin
        LabelStr := Trim(Copy(ALine, PctPos + 1, MaxInt));
        // Strip elapsed time if present, e.g. "0:12 label" or "1:05 label"
        if (Length(LabelStr) > 4) and ((LabelStr[2] = ':') or ((Length(LabelStr) > 5) and (LabelStr[3] = ':'))) then
        begin
          StartPos := Pos(' ', LabelStr);
          if StartPos > 0 then
            LabelStr := Trim(Copy(LabelStr, StartPos + 1, MaxInt));
        end;
        if LabelStr = '' then
          LabelStr := 'Compiling HelixSR neural shaders...';
        AOnProgress(PctVal, LabelStr);
        Exit;
      end;
    end;

    // 2. Setup script phases
    if Pos('downloading', L) > 0 then
      AOnProgress(15, Trim(ALine))
    else if Pos('python', L) > 0 then
      AOnProgress(20, 'Configuring Python runtime...')
    else if Pos('shader compiler', L) > 0 then
      AOnProgress(30, 'Configuring DirectX Shader Compiler...')
    else if Pos('weights', L) > 0 then
      AOnProgress(45, 'Extracting DLSS neural weights...')
    else if (Pos('ptx', L) > 0) or (Pos('tables', L) > 0) or (Pos('kernel', L) > 0) or (Pos('sources', L) > 0) then
      AOnProgress(65, 'Generating compute kernels...')
    else if (Pos('shaders', L) > 0) or (Pos('dxc', L) > 0) then
      AOnProgress(85, 'Compiling Direct3D 12 shaders...');
  end;

begin
  Result := False;
  WorkDir := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath);

  // Always start from a clean state: stale prefixes are the most common cause
  // of c0000135/kernel32 failures on subsequent runs.
  ClearHelixSRLastCompileError;
  CleanHelixSRWinePrefix;

  if not FileExists(WorkDir + 'helixsr-setup.sh') then
  begin
    WriteLn('[HELIXSR] Cannot compile: helixsr-setup.sh not found in ', WorkDir);
    FHelixSRLastCompileError := 'helixsr-setup.sh was not found in ' + WorkDir;
    Exit;
  end;

  SanitizeHelixSRSetupScript(WorkDir);

  if Assigned(AOnProgress) then
    AOnProgress(5, 'Preparing HelixSR neural compilation...');

  // Prefer a runtime that we have validated by executing it.
  WinePath := FindWorkingWineForHelixSR;
  Cmd := 'chmod +x ./helixsr-setup.sh ./setup/lib/model/launch_synth 2>/dev/null; ';
  if WinePath <> '' then
  begin
    WriteLn('[HELIXSR] Using validated Wine runtime: ', WinePath);
    Cmd := Cmd + 'export HELIXSR_WINE=' + QuotedStr(WinePath) + '; ';
  end
  else
    WriteLn('[HELIXSR] No validated Wine/Proton runtime found; relying on setup script discovery.');
  Cmd := Cmd + './helixsr-setup.sh --yes < /dev/null';

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'sh';
    Process.Parameters.Add('-c');
    Process.Parameters.Add(Cmd);
    Process.CurrentDirectory := ExcludeTrailingPathDelimiter(WorkDir);
    Process.Options := [poUsePipes, poStderrToOutPut];
    Process.Execute;

    Pending := '';
    while Process.Running or (Process.Output.NumBytesAvailable > 0) do
    begin
      Count := Process.Output.NumBytesAvailable;
      if Count > SizeOf(Buffer) then
        Count := SizeOf(Buffer);
      if Count > 0 then
      begin
        Count := Process.Output.Read(Buffer, Count);
        if Count > 0 then
        begin
          SetLength(Pending, Length(Pending) + Count);
          Move(Buffer[0], Pending[Length(Pending) - Count + 1], Count);

          repeat
            i := Pos(#10, Pending);
            if i > 0 then
            begin
              Line := Trim(Copy(Pending, 1, i - 1));
              Delete(Pending, 1, i);
              if Line <> '' then
              begin
                WriteLn('[HELIXSR] ', Line);
                EmitLine(Line);
              end;
            end;
          until i = 0;
        end;
      end
      else
        Sleep(20);
    end;

    if Pending <> '' then
    begin
      Line := Trim(Pending);
      if Line <> '' then
      begin
        WriteLn('[HELIXSR] ', Line);
        EmitLine(Line);
      end;
    end;

    Process.WaitOnExit;
    Result := IsHelixSRCompiled(WorkDir);

    if Result then
    begin
      // Promote the freshly compiled HelixSR-fsrfg runtime to the root path.
      if FileExists(WorkDir + 'HelixSR-fsrfg' + PathDelim + 'amd_fidelityfx_dx12.dll') then
        CopyFile(WorkDir + 'HelixSR-fsrfg' + PathDelim + 'amd_fidelityfx_dx12.dll',
          WorkDir + 'amd_fidelityfx_dx12.dll');
      // Ensure OptiScaler companion files are mirrored in root
      if FileExists(WorkDir + 'optiscaler' + PathDelim + 'OptiScaler.dll') and not FileExists(WorkDir + 'OptiScaler.dll') then
        CopyFile(WorkDir + 'optiscaler' + PathDelim + 'OptiScaler.dll', WorkDir + 'OptiScaler.dll');
      if FileExists(WorkDir + 'optiscaler' + PathDelim + 'fakenvapi.dll') and not FileExists(WorkDir + 'fakenvapi.dll') then
        CopyFile(WorkDir + 'optiscaler' + PathDelim + 'fakenvapi.dll', WorkDir + 'fakenvapi.dll');
      if FileExists(WorkDir + 'optiscaler' + PathDelim + 'fakenvapi.ini') and not FileExists(WorkDir + 'fakenvapi.ini') then
        CopyFile(WorkDir + 'optiscaler' + PathDelim + 'fakenvapi.ini', WorkDir + 'fakenvapi.ini');
    end;
  finally
    Process.Free;
  end;

  if (not Result) and (FHelixSRLastCompileError = '') then
    FHelixSRLastCompileError := 'HelixSR compilation failed: no compiled runtime was produced. Ensure Wine/Proton and Python are available.';

  if Assigned(AOnProgress) then
  begin
    if Result then
      AOnProgress(100, 'HelixSR neural runtime compiled successfully.')
    else
      AOnProgress(100, 'HelixSR compilation failed.');
  end;
end;

// True when a system-wide vkSumi Vulkan layer is present. System layers are
// managed by the distribution/package manager and must not be touched.
function VkSumiSystemLayersPresent: Boolean;
begin
  Result :=
    FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so') or
    FileExists('/usr/lib/extensions/vulkan/vkSumi/lib/i386-linux-gnu/libVkLayer_vksumi.so') or
    FileExists('/app/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so') or
    FileExists('/usr/share/vulkan/implicit_layer.d/vksumi.json') or
    FileExists('/usr/local/share/vulkan/implicit_layer.d/vksumi.json') or
    FileExists('/etc/vulkan/implicit_layer.d/vksumi.json') or
    FileExists('/app/share/vulkan/implicit_layer.d/vksumi.json');
end;

// Resolve the user-space vkSumi Vulkan layer manifest directory
// (<XDG_DATA_HOME|~/.local/share>/vulkan/implicit_layer.d/).
function GetUserVulkanImplicitDir: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := IncludeTrailingPathDelimiter(GetUserDir + '.local/share')
  else
    DataHome := IncludeTrailingPathDelimiter(DataHome);
  Result := DataHome + 'vulkan' + PathDelim + 'implicit_layer.d' + PathDelim;
end;

function IsVkSumiInstalled: Boolean;
var
  TargetSoFile, TargetJsonFile: string;
begin
  // System-wide layer (distribution package) takes precedence
  if VkSumiSystemLayersPresent then
    Exit(True);

  TargetSoFile := IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers' + PathDelim + 'vksumi' + PathDelim + 'libVkLayer_vksumi.so';
  TargetJsonFile := GetUserVulkanImplicitDir + 'vksumi.json';

  Result := FileExists(TargetSoFile) and
            IsValidSharedLibrary(TargetSoFile) and
            FileExists(TargetJsonFile);
end;

// Extract the "tag_name" value from a vkSumi GitHub API response.
function ParseVkSumiReleaseTag(const AJson: string): string;
var
  KeyPos, ColonPos, QuoteStart, QuoteEnd: Integer;
begin
  Result := '';
  if AJson = '' then Exit;

  KeyPos := Pos('"tag_name"', AJson);
  if KeyPos = 0 then Exit;

  ColonPos := PosEx(':', AJson, KeyPos + 10);
  if ColonPos = 0 then Exit;

  QuoteStart := PosEx('"', AJson, ColonPos);
  if QuoteStart = 0 then Exit;

  QuoteEnd := PosEx('"', AJson, QuoteStart + 1);
  if QuoteEnd > QuoteStart then
    Result := Copy(AJson, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
end;

// Read the locally recorded vkSumi version from the goverlay.vars files or,
// as a last resort, from <data>/layers/vksumi/version.txt.
function ReadLocalVkSumiVersion: string;
var
  Candidates: array[0..3] of string;
  VersionFile: string;
  VarsList: TStringList;
  i: Integer;
begin
  Result := '';

  Candidates[0] := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars';
  Candidates[1] := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars';
  Candidates[2] := GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod' + PathDelim + 'goverlay.vars';
  Candidates[3] := IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'goverlay.vars';

  for i := Low(Candidates) to High(Candidates) do
  begin
    if not FileExists(Candidates[i]) then Continue;
    VarsList := TStringList.Create;
    try
      VarsList.LoadFromFile(Candidates[i]);
      Result := Trim(VarsList.Values['vksumi']);
    finally
      VarsList.Free;
    end;
    if Result <> '' then Exit;
  end;

  VersionFile := IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers' + PathDelim + 'vksumi' + PathDelim + 'version.txt';
  if FileExists(VersionFile) then
  begin
    VarsList := TStringList.Create;
    try
      VarsList.LoadFromFile(VersionFile);
      if VarsList.Count > 0 then
        Result := Trim(VarsList[0]);
    finally
      VarsList.Free;
    end;
  end;
end;

// System layers are managed by package managers, so updates are only checked
// for the user-space runtime installed by GOverlay itself.
function IsVkSumiUpdateAvailable: Boolean;
var
  Process: TProcess;
  Response, LocalVer, RemoteTag: string;
begin
  Result := False;

  if IsRunningInFlatpak then Exit(False);

  // System layers are managed by package managers, do not check updates
  if FileExists('/usr/share/vulkan/implicit_layer.d/vksumi.json') or
     FileExists('/usr/local/share/vulkan/implicit_layer.d/vksumi.json') or
     FileExists('/etc/vulkan/implicit_layer.d/vksumi.json') or
     FileExists('/app/share/vulkan/implicit_layer.d/vksumi.json') then Exit(False);

  if not IsVkSumiInstalled then Exit(True);

  LocalVer := ReadLocalVkSumiVersion;
  if LocalVer = '' then Exit(True);

  Response := '';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--connect-timeout');
    Process.Parameters.Add('2');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('4');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('https://api.github.com/repos/reakjra/vkSumi/releases/latest');
    Process.Options := [poWaitOnExit, poUsePipes];
    Process.Execute;

    SetLength(Response, Process.Output.NumBytesAvailable);
    if Length(Response) > 0 then
      Process.Output.Read(Response[1], Length(Response));
  finally
    Process.Free;
  end;

  if Response = '' then Exit(False);

  RemoteTag := ParseVkSumiReleaseTag(Response);
  if RemoteTag = '' then Exit(False);

  Result := RemoteTag <> LocalVer;
end;

function HasMissingMandatoryLibraries(out AMissingList: TStringList): Boolean;
var
  OptiDir, DlssEnablerDir, FsrBase: string;
  ReShadeBin, ReShadeShaders: string;
begin
  AMissingList := TStringList.Create;

  OptiDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath);
  DlssEnablerDir := IncludeTrailingPathDelimiter(GetDlssEnablerPath(True));
  FsrBase := IncludeTrailingPathDelimiter(GetFSR4BasePath);
  ReShadeBin := IncludeTrailingPathDelimiter(GetReShadeBinPath);
  ReShadeShaders := IncludeTrailingPathDelimiter(GetReShadeShadersPath);

  // OptiScaler core
  if not FileExists(OptiDir + 'OptiScaler.dll') then
    AMissingList.Add('OptiScaler.dll');
  if not FileExists(OptiDir + 'amd_fidelityfx_upscaler_dx12.dll') then
    AMissingList.Add('amd_fidelityfx_upscaler_dx12.dll');

  // DLSS Enabler core
  if not FileExists(DlssEnablerDir + 'version.dll') then
    AMissingList.Add('version.dll (DLSS Enabler)');

  // NVIDIA DLSS companion DLLs
  if not FileExists(OptiDir + 'nvngx_dlss.dll') then
    AMissingList.Add('nvngx_dlss.dll');
  if not FileExists(OptiDir + 'nvngx_dlssd.dll') then
    AMissingList.Add('nvngx_dlssd.dll');
  if not FileExists(OptiDir + 'nvngx_dlssg.dll') then
    AMissingList.Add('nvngx_dlssg.dll');

  // FrameGen bridge
  if not FileExists(OptiDir + 'dlssg_to_fsr3_amd_is_better.dll') then
    AMissingList.Add('dlssg_to_fsr3_amd_is_better.dll');

  // FakeNVAPI
  if not FileExists(OptiDir + 'fakenvapi.dll') then
    AMissingList.Add('fakenvapi.dll');

  // FSR4 central directory DLLs
  if not FileExists(FsrBase + 'Latest' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
    AMissingList.Add('amd_fidelityfx_upscaler_dx12.dll (FSR4 Latest)');
  if not FileExists(FsrBase + '4.1.1b' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
    AMissingList.Add('amd_fidelityfx_upscaler_dx12.dll (FSR 4.1.1b)');
  if not FileExists(FsrBase + '4.0.2c' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
    AMissingList.Add('amd_fidelityfx_upscaler_dx12.dll (FSR 4.0.2c)');

  // ReShade runtime & standard shaders
  if not FileExists(ReShadeBin + 'ReShade64.dll') then
    AMissingList.Add('ReShade64.dll');
  if not FileExists(ReShadeBin + 'ReShade32.dll') then
    AMissingList.Add('ReShade32.dll');
  if not DirectoryExists(ReShadeShaders + 'Shaders') then
    AMissingList.Add('ReShade Standard Shaders');

  // vkBasalt ReShade shaders repository
  if not DirectoryExists(IncludeTrailingPathDelimiter(GetVkBasaltConfigDir) + 'reshade-shaders') then
    AMissingList.Add('vkBasalt ReShade Shaders');

  // AFMF Vulkan layer
  if not IsAfmfInstalled and not IsRunningInFlatpak then
    AMissingList.Add('afmf-linux layer');

  // vkSumi Vulkan layer
  if not IsVkSumiInstalled and not IsRunningInFlatpak then
    AMissingList.Add('vkSumi Vulkan layer');

  // HelixSR (OptiScaler & DLSS Model E runtime)
  if not FileExists(GetHelixSRDx12DllPath(GetBGModOriginalHelixSRPath)) then
    AMissingList.Add('HelixSR (OptiScaler & DLSS Model E runtime)');

  // OptiPatcher ASI plugin (OptiScaler)
  if not FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'plugins' + PathDelim + 'OptiPatcher.asi') and
     not FileExists(GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins' + PathDelim + 'OptiPatcher.asi') then
    AMissingList.Add('OptiPatcher (OptiScaler ASI plugin)');

  Result := AMissingList.Count > 0;
end;

function HasMissingMandatoryLibraries: Boolean;
var
  TempList: TStringList;
begin
  TempList := TStringList.Create;
  try
    Result := HasMissingMandatoryLibraries(TempList);
  finally
    TempList.Free;
  end;
end;

// Extract the "rolling-YYYY.MM.DD" version derived from the release
// "updated_at" field of an optiscaler/OptiPatcher GitHub API response.
// Returns '' when the field cannot be located or parsed.
function ParseOptiPatcherRollingVersion(const AJson: string): string;
var
  KeyPos, ColonPos, QuoteStart, QuoteEnd: Integer;
  DateVal: string;
begin
  Result := '';
  if AJson = '' then Exit;

  KeyPos := Pos('"updated_at"', AJson);
  if KeyPos = 0 then Exit;

  ColonPos := PosEx(':', AJson, KeyPos + 12);
  if ColonPos = 0 then Exit;

  QuoteStart := PosEx('"', AJson, ColonPos);
  if QuoteStart = 0 then Exit;

  QuoteEnd := PosEx('"', AJson, QuoteStart + 1);
  if QuoteEnd <= QuoteStart then Exit;

  DateVal := Copy(AJson, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
  if Length(DateVal) < 10 then Exit;

  DateVal := StringReplace(Copy(DateVal, 1, 10), '-', '.', [rfReplaceAll]);
  if (Length(DateVal) <> 10) or (Pos(',', DateVal) > 0) then Exit;

  Result := 'rolling-' + DateVal;
end;

// Read the locally recorded OptiPatcher version from the stable (or, as a
// fallback, edge) bgmod goverlay.vars file.
function ReadLocalOptiPatcherVersion: string;
var
  VarsFilePath: string;
  VarsList: TStringList;
begin
  Result := '';
  if FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars') then
    VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars'
  else if FileExists(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars') then
    VarsFilePath := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars'
  else
    VarsFilePath := '';

  if VarsFilePath = '' then Exit;

  VarsList := TStringList.Create;
  try
    VarsList.LoadFromFile(VarsFilePath);
    Result := VarsList.Values['optipatcher'];
  finally
    VarsList.Free;
  end;
end;

function IsOptiPatcherUpdateAvailable: Boolean;
var
  Process: TProcess;
  Response, RemoteVerStr, LocalVerStr, TargetAsiFile: string;
begin
  Result := False;

  TargetAsiFile := GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins' + PathDelim + 'OptiPatcher.asi';
  if not FileExists(TargetAsiFile) then
    Exit(True);

  LocalVerStr := ReadLocalOptiPatcherVersion;
  if LocalVerStr = '' then
    Exit(True);

  Response := '';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--connect-timeout');
    Process.Parameters.Add('2');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('4');
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

  RemoteVerStr := ParseOptiPatcherRollingVersion(Response);
  if RemoteVerStr = '' then Exit;

  Result := RemoteVerStr <> LocalVerStr;
end;

function CheckAndInstallOptiPatcher(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  Process: TProcess;
  Response, RemoteVerStr, LocalVerStr, VarsFilePath: string;
  VarsList: TStringList;
  PathsToUpdate: TStringList;
  TargetAsiFile, OrigPluginsDir, EdgePluginsDir, GlobalBgModPlugins, TmpAsiFile: string;
  i, LineIdx: Integer;
begin
  Result := False;

  if Assigned(AOnProgress) then
    AOnProgress(26, 'Checking OptiPatcher plugin...');

  TargetAsiFile := GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins' + PathDelim + 'OptiPatcher.asi';
  OrigPluginsDir := IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'plugins';
  EdgePluginsDir := IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'plugins';
  GlobalBgModPlugins := GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod' + PathDelim + 'plugins';

  LocalVerStr := ReadLocalOptiPatcherVersion;

  // Query the latest rolling release metadata (updated_at date).
  Response := '';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--connect-timeout');
    Process.Parameters.Add('3');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('6');
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

  RemoteVerStr := ParseOptiPatcherRollingVersion(Response);

  // Fast path: already up to date. Heal the stable/edge plugin caches when the
  // ASI file is present centrally but missing from one of them.
  if (not AForce) and (RemoteVerStr <> '') and (RemoteVerStr = LocalVerStr) and FileExists(TargetAsiFile) then
  begin
    if not FileExists(OrigPluginsDir + PathDelim + 'OptiPatcher.asi') then
    begin
      ForceDirectories(OrigPluginsDir);
      CopyFile(TargetAsiFile, OrigPluginsDir + PathDelim + 'OptiPatcher.asi');
    end;
    if not FileExists(EdgePluginsDir + PathDelim + 'OptiPatcher.asi') then
    begin
      ForceDirectories(EdgePluginsDir);
      CopyFile(TargetAsiFile, EdgePluginsDir + PathDelim + 'OptiPatcher.asi');
    end;
    if Assigned(AOnProgress) then
      AOnProgress(32, 'OptiPatcher is up to date');
    Result := True;
    Exit;
  end;

  // Remote check failed but a local copy already exists: keep it.
  if (RemoteVerStr = '') and FileExists(TargetAsiFile) and (not AForce) then
  begin
    WriteLn('[OPTIPATCHER-AUTO] Remote release check failed; keeping existing OptiPatcher.');
    Result := True;
    Exit;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(28, 'Downloading OptiPatcher plugin...');

  ForceDirectories(GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins');
  TmpAsiFile := GetGOverlayDataDir + 'optiscaler' + PathDelim + 'plugins' + PathDelim + 'OptiPatcher.asi.tmp';

  RunCurlWithProgress('https://github.com/optiscaler/OptiPatcher/releases/download/rolling/OptiPatcher.asi',
    TmpAsiFile, 28, 31, 'Downloading OptiPatcher plugin', AOnProgress);

  if (not FileExists(TmpAsiFile)) or (FileSize(TmpAsiFile) < 1000) then
  begin
    WriteLn('[OPTIPATCHER-AUTO] Download failed or invalid file size.');
    if FileExists(TmpAsiFile) then DeleteFile(TmpAsiFile);
    if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('OptiPatcher (OptiScaler ASI plugin)') = -1) then
      AFailedFiles.Add('OptiPatcher (OptiScaler ASI plugin)');
    Result := FileExists(TargetAsiFile);
    Exit;
  end;

  CopyFile(TmpAsiFile, TargetAsiFile);
  DeleteFile(TmpAsiFile);

  // Sync to the stable and edge plugin caches.
  ForceDirectories(OrigPluginsDir);
  CopyFile(TargetAsiFile, OrigPluginsDir + PathDelim + 'OptiPatcher.asi');
  ForceDirectories(EdgePluginsDir);
  CopyFile(TargetAsiFile, EdgePluginsDir + PathDelim + 'OptiPatcher.asi');

  // Sync to the global bgmod plugins when that profile tree exists.
  if DirectoryExists(GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod') then
  begin
    ForceDirectories(GlobalBgModPlugins);
    CopyFile(TargetAsiFile, GlobalBgModPlugins + PathDelim + 'OptiPatcher.asi');
  end;

  // Record the version in every goverlay.vars that already exists.
  PathsToUpdate := TStringList.Create;
  try
    PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars');
    PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars');
    PathsToUpdate.Add(GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod' + PathDelim + 'goverlay.vars');

    for i := 0 to PathsToUpdate.Count - 1 do
    begin
      VarsFilePath := PathsToUpdate[i];
      if not FileExists(VarsFilePath) then Continue;

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
  finally
    PathsToUpdate.Free;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(32, 'OptiPatcher installed');
  Result := True;
end;

function CheckAndInstallOptiScaler(const AFGModPath: string; AIsStable: Boolean = True; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
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
    ChanLabel := 'Downloading Optiscaler stable';
    StartPct := 0;
    EndPct := 40;
  end
  else
  begin
    TargetCacheDir := GetBGModOriginalEdgePath;
    ChanLabel := 'Downloading Optiscaler edge';
    StartPct := 0;
    EndPct := 40;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Checking ', ChanLabel, ' installation...');
  WriteLn('[AUTO-INSTALL] ========================================');
  
  // Check if OptiScaler.dll already exists in target cache
  if FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'OptiScaler.dll') then
  begin
    WriteLn('[AUTO-INSTALL] OptiScaler.dll already exists in ', TargetCacheDir, ', checking companion libraries and FSR4...');

    // 1. Check & heal NVIDIA DLSS DLLs
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll') then
    begin
      WriteLn('[AUTO-INSTALL] Self-healing: downloading missing nvngx_dlss.dll...');
      ExitCode := RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlss.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll', StartPct + 17, StartPct + 19, ChanLabel + ' (nvidia dlss)', AOnProgress);
      if (ExitCode <> 0) or not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll') then
        if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlss.dll') = -1) then
          AFailedFiles.Add('nvngx_dlss.dll');
    end;

    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll') then
    begin
      WriteLn('[AUTO-INSTALL] Self-healing: downloading missing nvngx_dlssd.dll...');
      ExitCode := RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssd.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll', StartPct + 19, StartPct + 21, ChanLabel + ' (nvidia dlss)', AOnProgress);
      if (ExitCode <> 0) or not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll') then
        if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlssd.dll') = -1) then
          AFailedFiles.Add('nvngx_dlssd.dll');
    end;

    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll') then
    begin
      WriteLn('[AUTO-INSTALL] Self-healing: downloading missing nvngx_dlssg.dll...');
      ExitCode := RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssg.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll', StartPct + 21, StartPct + 22, ChanLabel + ' (nvidia dlss)', AOnProgress);
      if (ExitCode <> 0) or not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll') then
        if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlssg.dll') = -1) then
          AFailedFiles.Add('nvngx_dlssg.dll');
    end;

    // 2. Check & heal framegen bridge
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll') then
    begin
      WriteLn('[AUTO-INSTALL] Self-healing: downloading missing dlssg_to_fsr3 DLL...');
      ExitCode := RunCurlWithProgress('https://github.com/benjamimgois/OptiScaler-builds/releases/download/dlssg-fsr3-0.130/dlssg_to_fsr3_amd_is_better.dll',
        IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll', StartPct + 22, StartPct + 23, ChanLabel + ' (framegen bridge)', AOnProgress);
      if (ExitCode <> 0) or not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll') then
        if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('dlssg_to_fsr3_amd_is_better.dll') = -1) then
          AFailedFiles.Add('dlssg_to_fsr3_amd_is_better.dll');
    end;

    // 3. Check & heal FakeNVAPI
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'fakenvapi.dll') then
    begin
      WriteLn('[AUTO-INSTALL] Self-healing: downloading missing FakeNVAPI...');
      try
        OptiscalerTabTemp := TOptiscalerTab.Create;
        try
          UserDir := GetUserDir;
          if OptiscalerTabTemp.FetchFakeNvapiLatest(FakeNvapiTag, FakeNvapiURL) then
          begin
            Fake7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-latest-auto.7z';
            ExitCode := RunCurlWithProgress(FakeNvapiURL, Fake7zPath, StartPct + 23, StartPct + 24, ChanLabel + ' (fakenvapi)', AOnProgress);
            if (ExitCode = 0) and FileExists(Fake7zPath) then
            begin
              Process := TProcess.Create(nil);
              try
                Process.Executable := '7z';
                Process.Parameters.Add('x');
                Process.Parameters.Add('-y');
                Process.Parameters.Add('-o' + TargetCacheDir);
                Process.Parameters.Add(Fake7zPath);
                Process.Options := [poWaitOnExit];
                Process.Execute;
              finally
                Process.Free;
              end;
              DeleteFile(Fake7zPath);
            end;
          end;
        finally
          OptiscalerTabTemp.Free;
        end;
      except
        on E: Exception do
          WriteLn('[AUTO-INSTALL] WARN: Self-healing FakeNVAPI failed: ', E.Message);
      end;
      if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'fakenvapi.dll') then
        if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('fakenvapi.dll') = -1) then
          AFailedFiles.Add('fakenvapi.dll');
    end;

    // 4. Check & heal FSR4 libraries
    CheckAndInstallFsr4(False, AOnProgress, AFailedFiles);

    // 5. Sync to DLSS Enabler
    SyncOptiScalerFilesToDlssEnabler(AIsStable);

    if Assigned(AOnProgress) then
      AOnProgress(EndPct, ChanLabel);
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
    ExitCode := RunCurlWithProgress(DownloadURL, SevenZFilePath, StartPct + 4, StartPct + 15, ChanLabel + ' (core)', AOnProgress);
    
    if (ExitCode <> 0) or not FileExists(SevenZFilePath) then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: Download failed');
      Exit;
    end;

    WriteLn('[AUTO-INSTALL] Download completed, extracting to ', TargetCacheDir, '...');

    if Assigned(AOnProgress) then
      AOnProgress(StartPct + 16, ChanLabel + ' (extracting core)');

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
    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlss.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll', StartPct + 17, StartPct + 19, ChanLabel + ' (nvidia dlss)', AOnProgress);
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlss.dll') then
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlss.dll') = -1) then
        AFailedFiles.Add('nvngx_dlss.dll');

    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssd.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll', StartPct + 19, StartPct + 21, ChanLabel + ' (nvidia dlss)', AOnProgress);
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssd.dll') then
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlssd.dll') = -1) then
        AFailedFiles.Add('nvngx_dlssd.dll');

    RunCurlWithProgress(URL_NVIDIA_DLSS_BASE + 'nvngx_dlssg.dll', IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll', StartPct + 21, StartPct + 22, ChanLabel + ' (nvidia dlss)', AOnProgress);
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'nvngx_dlssg.dll') then
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('nvngx_dlssg.dll') = -1) then
        AFailedFiles.Add('nvngx_dlssg.dll');

    // Download auxiliary dlssg_to_fsr3 DLL
    WriteLn('[AUTO-INSTALL] Downloading dlssg_to_fsr3 DLL...');
    RunCurlWithProgress('https://github.com/benjamimgois/OptiScaler-builds/releases/download/dlssg-fsr3-0.130/dlssg_to_fsr3_amd_is_better.dll',
      IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll', StartPct + 22, StartPct + 23, ChanLabel + ' (framegen bridge)', AOnProgress);
    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'dlssg_to_fsr3_amd_is_better.dll') then
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('dlssg_to_fsr3_amd_is_better.dll') = -1) then
        AFailedFiles.Add('dlssg_to_fsr3_amd_is_better.dll');

    // Fetch and download/extract latest FakeNVAPI
    WriteLn('[AUTO-INSTALL] Downloading FakeNVAPI...');
    FakeNvapiVerClean := '';
    if OptiscalerTabTemp.FetchFakeNvapiLatest(FakeNvapiTag, FakeNvapiURL) then
    begin
      WriteLn('[AUTO-INSTALL] Found FakeNVAPI tag: ', FakeNvapiTag);
      Fake7zPath := IncludeTrailingPathDelimiter(UserDir) + 'fakenvapi-latest-auto.7z';
      ExitCode := RunCurlWithProgress(FakeNvapiURL, Fake7zPath, StartPct + 23, StartPct + 24, ChanLabel + ' (fakenvapi)', AOnProgress);

      if (ExitCode = 0) and FileExists(Fake7zPath) then
      begin
        WriteLn('[AUTO-INSTALL] Extracting FakeNVAPI...');
        if Assigned(AOnProgress) then
          AOnProgress(StartPct + 24, ChanLabel + ' (extracting fakenvapi)');
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

    if not FileExists(IncludeTrailingPathDelimiter(TargetCacheDir) + 'fakenvapi.dll') then
      if Assigned(AFailedFiles) and (AFailedFiles.IndexOf('fakenvapi.dll') = -1) then
        AFailedFiles.Add('fakenvapi.dll');

    // Download and setup FSR upscaler DLLs
    CheckAndInstallFsr4(False, AOnProgress, AFailedFiles);

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
        AOnProgress(EndPct, ChanLabel);
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

function CheckAndInstallVkSumi(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  LayersDir, TargetSoFile, UserVulkanImplicitDir, TargetJsonFile: string;
  ChanLabel: string;
  StartPct, EndPct: Integer;
  DownloadUrl, TempArchiveFile, TempExtractDir, LatestTag, CandidateUrl: string;
  Process: TProcess;
  JsonSL, OutputList: TStringList;
  FoundFiles: TStringList;
  PathsToUpdate, VarsList: TStringList;
  RespFile, RespText: string;
  TagPos, UrlPos, QuoteStart, QuoteEnd: Integer;
  i, LineIdx: Integer;
begin
  Result := False;
  StartPct := 70;
  EndPct := 95;

  // In Flatpak, skip downloading; layer cannot and should not be written to host
  if IsRunningInFlatpak then
  begin
    WriteLn('[AUTO-INSTALL] Flatpak environment detected; skipping vkSumi host layer installation');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'vkSumi runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Checking vkSumi runtime';

  LayersDir := IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers' + PathDelim + 'vksumi' + PathDelim;
  TargetSoFile := LayersDir + 'libVkLayer_vksumi.so';

  UserVulkanImplicitDir := GetEnvironmentVariable('XDG_DATA_HOME');
  if UserVulkanImplicitDir = '' then
    UserVulkanImplicitDir := IncludeTrailingPathDelimiter(GetUserDir + '.local/share')
  else
    UserVulkanImplicitDir := IncludeTrailingPathDelimiter(UserVulkanImplicitDir);
  UserVulkanImplicitDir := UserVulkanImplicitDir + 'vulkan' + PathDelim + 'implicit_layer.d' + PathDelim;
  TargetJsonFile := UserVulkanImplicitDir + 'vksumi.json';

  // Check if system runtime exists or user-space runtime already exists
  if not AForce then
  begin
    if VkSumiSystemLayersPresent then
    begin
      WriteLn('[AUTO-INSTALL] vkSumi layer is already available');
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'vkSumi runtime ready');
      Exit(True);
    end;

    if (FileExists(TargetSoFile) and IsValidSharedLibrary(TargetSoFile) and FileExists(TargetJsonFile)) then
    begin
      if not IsVkSumiUpdateAvailable then
      begin
        WriteLn('[AUTO-INSTALL] vkSumi layer is already available');
        if Assigned(AOnProgress) then
          AOnProgress(EndPct, 'vkSumi runtime ready');
        Exit(True);
      end
      else
        WriteLn('[AUTO-INSTALL] vkSumi update available, proceeding with installation...');
    end;
  end;

  LatestTag := '';

  ChanLabel := 'Downloading vkSumi runtime';
  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Installing vkSumi Vulkan layer in user space...');
  WriteLn('[AUTO-INSTALL] ========================================');

  try
    ForceDirectories(LayersDir);
    ForceDirectories(UserVulkanImplicitDir);

    DownloadUrl := '';

    // Fetch latest release asset from GitHub API
    RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'vksumi_api.json';
    Process := TProcess.Create(nil);
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: goverlay');
      Process.Parameters.Add('-o');
      Process.Parameters.Add(RespFile);
      Process.Parameters.Add('https://api.github.com/repos/reakjra/vkSumi/releases/latest');
      Process.Options := [poWaitOnExit];
      Process.Execute;

      if FileExists(RespFile) then
      begin
        OutputList := TStringList.Create;
        try
          OutputList.LoadFromFile(RespFile);
          RespText := OutputList.Text;
        finally
          OutputList.Free;
          DeleteFile(RespFile);
        end;

        // Release tag used to track the installed version locally
        LatestTag := ParseVkSumiReleaseTag(RespText);

        // Parse all browser_download_url entries from GitHub release assets
        UrlPos := Pos('"browser_download_url"', RespText);
        while UrlPos > 0 do
        begin
          TagPos := PosEx(':', RespText, UrlPos);
          if TagPos > 0 then
          begin
            QuoteStart := PosEx('"', RespText, TagPos);
            if QuoteStart > 0 then
            begin
              QuoteEnd := PosEx('"', RespText, QuoteStart + 1);
              if QuoteEnd > QuoteStart then
              begin
                CandidateUrl := Copy(RespText, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
                if (Pos('-debug', CandidateUrl) = 0) and (Pos('http', CandidateUrl) = 1) then
                begin
                  if Pos('.pkg.tar.zst', CandidateUrl) > 0 then
                  begin
                    DownloadUrl := CandidateUrl;
                    Break; // Prefer .pkg.tar.zst
                  end
                  else if (Pos('.deb', CandidateUrl) > 0) and (DownloadUrl = '') then
                    DownloadUrl := CandidateUrl; // Fallback to .deb
                end;
              end;
            end;
          end;
          UrlPos := PosEx('"browser_download_url"', RespText, UrlPos + 22);
        end;
      end;
    finally
      Process.Free;
    end;

    if LatestTag = '' then
      LatestTag := 'v0.1.0';

    if DownloadUrl = '' then
      DownloadUrl := 'https://github.com/reakjra/vkSumi/releases/download/v0.1.0/vksumi-0.1.0-2-x86_64.pkg.tar.zst';

    WriteLn('[AUTO-INSTALL] vkSumi Download URL: ', DownloadUrl);
    if Pos('.deb', DownloadUrl) > 0 then
      TempArchiveFile := IncludeTrailingPathDelimiter(GetTempDir) + 'vksumi_download.deb'
    else
      TempArchiveFile := IncludeTrailingPathDelimiter(GetTempDir) + 'vksumi_download.pkg.tar.zst';

    TempExtractDir := IncludeTrailingPathDelimiter(GetTempDir) + 'vksumi_extract' + PathDelim;

    RunCurlWithProgress(DownloadUrl, TempArchiveFile, StartPct + 4, StartPct + 15, ChanLabel, AOnProgress);

    if FileExists(TempArchiveFile) then
    begin
      ForceDirectories(TempExtractDir);

      if Pos('.pkg.tar.zst', TempArchiveFile) > 0 then
      begin
        // Unpack tar.zst directly with tar
        Process := TProcess.Create(nil);
        try
          Process.Executable := 'tar';
          Process.Parameters.Add('-xf');
          Process.Parameters.Add(TempArchiveFile);
          Process.Parameters.Add('-C');
          Process.Parameters.Add(ExcludeTrailingPathDelimiter(TempExtractDir));
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;
      end
      else
      begin
        // Unpack deb with 7z
        Process := TProcess.Create(nil);
        try
          Process.Executable := '7z';
          Process.Parameters.Add('x');
          Process.Parameters.Add('-y');
          Process.Parameters.Add('-o' + ExcludeTrailingPathDelimiter(TempExtractDir));
          Process.Parameters.Add(TempArchiveFile);
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;

        // Unpack data.tar.* if present
        FoundFiles := FindAllFiles(TempExtractDir, 'data.tar*', False);
        try
          if FoundFiles.Count > 0 then
          begin
            Process := TProcess.Create(nil);
            try
              Process.Executable := 'tar';
              Process.Parameters.Add('-xf');
              Process.Parameters.Add(FoundFiles[0]);
              Process.Parameters.Add('-C');
              Process.Parameters.Add(ExcludeTrailingPathDelimiter(TempExtractDir));
              Process.Options := [poWaitOnExit];
              Process.Execute;
            finally
              Process.Free;
            end;
          end;
        finally
          FoundFiles.Free;
        end;
      end;

      // Find libVkLayer_vksumi.so in extracted tree
      FoundFiles := FindAllFiles(TempExtractDir, 'libVkLayer_vksumi.so', True);
      try
        if FoundFiles.Count > 0 then
        begin
          CopyFile(FoundFiles[0], TargetSoFile);
          WriteLn('[AUTO-INSTALL] Extracted libVkLayer_vksumi.so to: ', TargetSoFile);
        end;
      finally
        FoundFiles.Free;
      end;

      // Cleanup temp
      DeleteFile(TempArchiveFile);
      DeleteDirectory(TempExtractDir, False);
    end;

    // Fallback: If extraction didn't yield the .so, try direct download fallback
    if not FileExists(TargetSoFile) then
    begin
      WriteLn('[AUTO-INSTALL] Trying direct binary download for libVkLayer_vksumi.so...');
      RunCurlWithProgress('https://github.com/benjamimgois/OptiScaler-builds/releases/download/vksumi/libVkLayer_vksumi.so', TargetSoFile, StartPct + 16, StartPct + 20, ChanLabel + ' (fallback)', AOnProgress);
    end;

    if FileExists(TargetSoFile) and IsValidSharedLibrary(TargetSoFile) then
    begin
      // Create/Update vksumi.json
      JsonSL := TStringList.Create;
      try
        JsonSL.Add('{');
        JsonSL.Add('    "file_format_version": "1.0.0",');
        JsonSL.Add('    "layer": {');
        JsonSL.Add('        "name": "VK_LAYER_vksumi_color_grading",');
        JsonSL.Add('        "type": "GLOBAL",');
        JsonSL.Add('        "library_path": "' + TargetSoFile + '",');
        JsonSL.Add('        "api_version": "1.4.0",');
        JsonSL.Add('        "implementation_version": "1",');
        JsonSL.Add('        "description": "vkSumi runtime color grading (brightness, contrast, saturation, hue, gamma)",');
        JsonSL.Add('        "functions": {');
        JsonSL.Add('            "vkGetInstanceProcAddr": "vksumi_GetInstanceProcAddr",');
        JsonSL.Add('            "vkGetDeviceProcAddr": "vksumi_GetDeviceProcAddr"');
        JsonSL.Add('        },');
        JsonSL.Add('        "enable_environment": {');
        JsonSL.Add('            "ENABLE_VKSUMI": "1"');
        JsonSL.Add('        },');
        JsonSL.Add('        "disable_environment": {');
        JsonSL.Add('            "DISABLE_VKSUMI": "1"');
        JsonSL.Add('        }');
        JsonSL.Add('    }');
        JsonSL.Add('}');
        JsonSL.SaveToFile(TargetJsonFile);

        // Persist the installed release tag next to the layer for update checks
        JsonSL.Clear;
        JsonSL.Add(LatestTag);
        JsonSL.SaveToFile(LayersDir + 'version.txt');
      finally
        JsonSL.Free;
      end;

      // Record the version in every governed goverlay.vars file so
      // ReadLocalVkSumiVersion/IsVkSumiUpdateAvailable can track updates.
      PathsToUpdate := TStringList.Create;
      try
        PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalPath) + 'goverlay.vars');
        PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetBGModOriginalEdgePath) + 'goverlay.vars');
        PathsToUpdate.Add(GetGOverlayDataDir + 'gameconfig' + PathDelim + 'global' + PathDelim + 'bgmod' + PathDelim + 'goverlay.vars');
        PathsToUpdate.Add(IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'goverlay.vars');

        for i := 0 to PathsToUpdate.Count - 1 do
        begin
          if not FileExists(PathsToUpdate[i]) then Continue;
          VarsList := TStringList.Create;
          try
            VarsList.LoadFromFile(PathsToUpdate[i]);
            LineIdx := VarsList.IndexOfName('vksumi');
            if LineIdx >= 0 then
              VarsList[LineIdx] := 'vksumi=' + LatestTag
            else
              VarsList.Add('vksumi=' + LatestTag);
            VarsList.SaveToFile(PathsToUpdate[i]);
          finally
            VarsList.Free;
          end;
        end;
      finally
        PathsToUpdate.Free;
      end;

      WriteLn('[AUTO-INSTALL] Created Vulkan layer manifest at: ', TargetJsonFile);
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'vkSumi runtime installed');
      Result := True;
    end
    else
    begin
      if FileExists(TargetSoFile) then
      begin
        WriteLn('[AUTO-INSTALL] ERROR: Downloaded vkSumi file is corrupted or invalid ELF; removing: ', TargetSoFile);
        DeleteFile(TargetSoFile);
      end;
      if FileExists(TargetJsonFile) then
      begin
        WriteLn('[AUTO-INSTALL] ERROR: Removing stale vkSumi manifest: ', TargetJsonFile);
        DeleteFile(TargetJsonFile);
      end;
      WriteLn('[AUTO-INSTALL] ERROR: Failed to install vkSumi layer');
    end;
  except
    on E: Exception do
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallVkSumi: ', E.Message);
  end;
end;

function IsMakoInstalled: Boolean;
var
  LocalLayer: string;
begin
  LocalLayer := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json';
  Result := FileExists(LocalLayer) or
            FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
            FileExists('/etc/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
            FileExists('/usr/local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
            (FileExists(IncludeTrailingPathDelimiter(GetUserDir) + '.local/bin/mako-launch') and
             FileExists(IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/libmako-render.so'));
end;

function GetMakoLibraryPath: string;
var
  Candidate: string;
begin
  Result := '';
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/libmako-render.so';
  if FileExists(Candidate) then Exit(Candidate);

  if FileExists('/usr/lib/libmako-render.so') then Exit('/usr/lib/libmako-render.so');
  if FileExists('/usr/lib/x86_64-linux-gnu/libmako-render.so') then Exit('/usr/lib/x86_64-linux-gnu/libmako-render.so');
  if FileExists('/usr/local/lib/libmako-render.so') then Exit('/usr/local/lib/libmako-render.so');
  if FileExists('/usr/lib64/libmako-render.so') then Exit('/usr/lib64/libmako-render.so');
end;

function GetMakoInstalledVersion: string;
var
  StateFile, VersionFile, RawText: string;
  SL: TStringList;
  JsonData: TJSONData;
  JsonObj: TJSONObject;
begin
  Result := '';
  StateFile := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/mako-render/active-renderer.json';
  if FileExists(StateFile) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(StateFile);
      RawText := SL.Text;
      if RawText <> '' then
      begin
        try
          JsonData := GetJSON(RawText);
          try
            if Assigned(JsonData) and (JsonData is TJSONObject) then
            begin
              JsonObj := TJSONObject(JsonData);
              if JsonObj.IndexOfName('version') >= 0 then
                Result := Trim(JsonObj.Strings['version']);
            end;
          finally
            JsonData.Free;
          end;
        except
          // ignore parse errors
        end;
      end;
    finally
      SL.Free;
    end;
  end;

  if Result = '' then
  begin
    VersionFile := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/mako-render/MAKO-Renderer-version.txt';
    if FileExists(VersionFile) then
    begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile(VersionFile);
        if SL.Count > 0 then
          Result := Trim(SL[0]);
      finally
        SL.Free;
      end;
    end;
  end;

  if (Result <> '') and (Result[1] <> 'v') and (Result[1] in ['0'..'9']) then
    Result := 'v' + Result;
end;

function GetMakoLatestRemoteVersion(out AUrl: string): string;
var
  RespFile, RespText, TagName, DownloadUrl, AssetName, Tag, CleanTag: string;
  Process: TProcess;
  OutputList: TStringList;
  JsonData, AssetData: TJSONData;
  ReleasesArray, AssetsArray: TJSONArray;
  ReleaseObj, AssetObj: TJSONObject;
  i, j: Integer;
begin
  Result := '';
  AUrl := '';
  DownloadUrl := '';
  TagName := '';

  RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'mako_api.json';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(RespFile);
    Process.Parameters.Add(URL_MAKO_API_RELEASES);
    Process.Options := [poWaitOnExit];
    Process.Execute;

    if FileExists(RespFile) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(RespFile);
        RespText := OutputList.Text;
      finally
        OutputList.Free;
        DeleteFile(RespFile);
      end;

      if RespText <> '' then
      begin
        try
          JsonData := GetJSON(RespText);
          try
            if Assigned(JsonData) and (JsonData is TJSONArray) then
            begin
              ReleasesArray := TJSONArray(JsonData);
              for i := 0 to ReleasesArray.Count - 1 do
              begin
                if ReleasesArray.Types[i] = jtObject then
                begin
                  ReleaseObj := TJSONObject(ReleasesArray[i]);
                  TagName := ReleaseObj.Get('tag_name', '');
                  if Pos('render-v', TagName) = 1 then
                  begin
                    // Found matching release tag
                    Result := Copy(TagName, 8, MaxInt);
                    if (Result <> '') and (Result[1] <> 'v') then
                      Result := 'v' + Result;

                    // Locate Linux tarball asset
                    AssetData := ReleaseObj.FindPath('assets');
                    if Assigned(AssetData) and (AssetData is TJSONArray) then
                    begin
                      AssetsArray := TJSONArray(AssetData);
                      for j := 0 to AssetsArray.Count - 1 do
                      begin
                        if AssetsArray.Types[j] = jtObject then
                        begin
                          AssetObj := TJSONObject(AssetsArray[j]);
                          AssetName := AssetObj.Get('name', '');
                          if (Pos('-linux.tar.xz', AssetName) > 0) and (Pos('flatpak', LowerCase(AssetName)) = 0) then
                          begin
                            DownloadUrl := AssetObj.Get('browser_download_url', '');
                            Break;
                          end
                          else if (DownloadUrl = '') and (Pos('.tar.xz', AssetName) > 0) and (Pos('flatpak', LowerCase(AssetName)) = 0) then
                          begin
                            DownloadUrl := AssetObj.Get('browser_download_url', '');
                          end;
                        end;
                      end;
                    end;
                    Break;
                  end;
                end;
              end;
            end;
          finally
            JsonData.Free;
          end;
        except
          // ignore parse errors
        end;
      end;
    end;
  finally
    Process.Free;
  end;

  if DownloadUrl <> '' then
    AUrl := DownloadUrl
  else if Result <> '' then
    AUrl := 'https://github.com/eugeniosegala/MAKO/releases/download/render-' + Result + '/MAKO-Renderer-' + Result + '-linux.tar.xz'
  else
  begin
    // Remote discovery failed: fall back to the Atom feed before giving up.
    Tag := FetchLatestReleaseTagFromAtom('eugeniosegala', 'MAKO');
    if Tag <> '' then
    begin
      CleanTag := Tag;
      if Pos('render-', CleanTag) = 1 then
        Delete(CleanTag, 1, 7);
      Result := CleanTag;
      AUrl := 'https://github.com/eugeniosegala/MAKO/releases/download/' + Tag + '/MAKO-Renderer-' + CleanTag + '-linux.tar.xz';
    end
    else
    begin
      Result := '';
      AUrl := '';
    end;
  end;
end;

function CheckAndInstallMako(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  ChanLabel: string;
  StartPct, EndPct: Integer;
  DownloadUrl, RemoteVer, TempTarFile, TempExtractDir, InstallerPath: string;
  Process: TProcess;
begin
  Result := False;
  StartPct := 75;
  EndPct := 95;

  // In Flatpak, skip downloading; layer cannot and should not be written to host
  if IsRunningInFlatpak then
  begin
    WriteLn('[AUTO-INSTALL] Flatpak environment detected; skipping MAKO host layer installation');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'MAKO runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Checking MAKO runtime';

  if not AForce and IsMakoInstalled then
  begin
    WriteLn('[AUTO-INSTALL] MAKO layer is already available');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'MAKO runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Downloading MAKO runtime';
  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Installing MAKO Renderer in user space...');
  WriteLn('[AUTO-INSTALL] ========================================');

  try
    DownloadUrl := '';
    RemoteVer := GetMakoLatestRemoteVersion(DownloadUrl);

    if DownloadUrl = '' then
    begin
      // Never downgrade an existing install: if the MAKO layer is already
      // present, keep it instead of forcing the baseline render-v4.5.0.
      if IsMakoInstalled then
      begin
        WriteLn('[AUTO-INSTALL] MAKO remote discovery failed; keeping installed runtime');
        Exit(False);
      end;
      DownloadUrl := 'https://github.com/eugeniosegala/MAKO/releases/download/render-v4.5.0/MAKO-Renderer-v4.5.0-linux.tar.xz';
    end;

    WriteLn('[AUTO-INSTALL] MAKO Download URL: ', DownloadUrl);
    TempTarFile := IncludeTrailingPathDelimiter(GetTempDir) + 'mako_download.tar.xz';
    TempExtractDir := IncludeTrailingPathDelimiter(GetTempDir) + 'mako_extract_' + IntToStr(fpgetpid) + PathDelim;

    RunCurlWithProgress(DownloadUrl, TempTarFile, StartPct + 4, StartPct + 12, ChanLabel, AOnProgress);

    if FileExists(TempTarFile) then
    begin
      ForceDirectories(TempExtractDir);
      if Assigned(AOnProgress) then
        AOnProgress(StartPct + 14, 'Extracting MAKO renderer...');

      // Extract tar.xz
      Process := TProcess.Create(nil);
      try
        Process.Executable := 'tar';
        Process.Parameters.Add('-xJf');
        Process.Parameters.Add(TempTarFile);
        Process.Parameters.Add('-C');
        Process.Parameters.Add(ExcludeTrailingPathDelimiter(TempExtractDir));
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;

      InstallerPath := TempExtractDir + 'Install MAKO Renderer';
      if not FileExists(InstallerPath) then
        InstallerPath := TempExtractDir + 'bin' + PathDelim + 'mako-installer';

      if FileExists(InstallerPath) then
      begin
        if Assigned(AOnProgress) then
          AOnProgress(StartPct + 16, 'Installing MAKO renderer...');

        Process := TProcess.Create(nil);
        try
          Process.CurrentDirectory := ExcludeTrailingPathDelimiter(TempExtractDir);
          Process.Executable := '/bin/sh';
          Process.Parameters.Add('-c');
          Process.Parameters.Add('chmod +x "' + InstallerPath + '" 2>/dev/null; ' +
                                 'MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1 "' + InstallerPath + '" --install');
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;

        WriteLn('[AUTO-INSTALL] MAKO installer executed.');
      end
      else
        WriteLn('[AUTO-INSTALL] ERROR: Could not find installer in extracted archive');

      // Direct installation fallback if layer is not detected yet
      if not IsMakoInstalled then
      begin
        WriteLn('[AUTO-INSTALL] Running direct extraction fallback for MAKO layer...');
        Process := TProcess.Create(nil);
        try
          Process.Executable := '/bin/sh';
          Process.Parameters.Add('-c');
          Process.Parameters.Add(
            'mkdir -p "$HOME/.local/bin" "$HOME/.local/lib" "$HOME/.local/lib32" "$HOME/.local/share/vulkan/implicit_layer.d" "$HOME/.local/share/mako-render"; ' +
            'cp -rf "' + TempExtractDir + '"bin/* "$HOME/.local/bin/" 2>/dev/null; ' +
            'chmod +x "$HOME/.local/bin/mako"* 2>/dev/null; ' +
            'cp -rf "' + TempExtractDir + '"lib/* "$HOME/.local/lib/" 2>/dev/null; ' +
            'cp -rf "' + TempExtractDir + '"lib32/* "$HOME/.local/lib32/" 2>/dev/null; ' +
            'cp -rf "' + TempExtractDir + '"share/vulkan/implicit_layer.d/* "$HOME/.local/share/vulkan/implicit_layer.d/" 2>/dev/null; ' +
            'cp -rf "' + TempExtractDir + '"*.txt "' + TempExtractDir + '"*.json "$HOME/.local/share/mako-render/" 2>/dev/null; ' +
            'if [ ! -f "$HOME/.local/share/mako-render/active-renderer.json" ]; then ' +
            '  echo "{\"schema_version\":1,\"owner\":\"standalone\",\"version\":\"' + RemoteVer + '\"}" > "$HOME/.local/share/mako-render/active-renderer.json"; ' +
            'fi'
          );
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;
      end;

      // Cleanup temp
      DeleteFile(TempTarFile);
      DeleteDirectory(TempExtractDir, False);
    end;

    if IsMakoInstalled then
    begin
      WriteLn('[AUTO-INSTALL] MAKO Renderer installed successfully');
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'MAKO runtime installed');
      Result := True;
    end
    else
      WriteLn('[AUTO-INSTALL] ERROR: MAKO layer not detected after installation');
  except
    on E: Exception do
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallMako: ', E.Message);
  end;
end;

function InspectMakoLosslessDll(const ADllPath: string; out ADetails: string): Boolean;
var
  MakoCli: string;
  Process: TProcess;
  OutputList: TStringList;
  TmpOut: string;
  i: Integer;
  Line: string;
  Fp16Ok, Fp32Ok, Ls1Ok: Boolean;
begin
  Result := False;
  ADetails := '';
  if (ADllPath = '') or not FileExists(ADllPath) then
  begin
    ADetails := 'DLL file not found';
    Exit;
  end;

  MakoCli := IncludeTrailingPathDelimiter(GetUserDir) + '.local/bin/mako-cli';
  if not FileExists(MakoCli) then
  begin
    if IsCommandAvailable('mako-cli') then
      MakoCli := 'mako-cli'
    else
    begin
      ADetails := 'DLL located (mako-cli not installed for deep inspection)';
      Result := True;
      Exit;
    end;
  end;

  TmpOut := IncludeTrailingPathDelimiter(GetTempDir) + 'mako_inspect_' + IntToStr(fpgetpid) + '.txt';
  Process := TProcess.Create(nil);
  try
    Process.Executable := '/bin/sh';
    Process.Parameters.Add('-c');
    Process.Parameters.Add('"' + MakoCli + '" inspect-dll -d "' + ADllPath + '" > "' + TmpOut + '" 2>&1');
    Process.Options := [poWaitOnExit];
    Process.Execute;

    if FileExists(TmpOut) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(TmpOut);
        Fp16Ok := False;
        Fp32Ok := False;
        Ls1Ok := False;

        for i := 0 to OutputList.Count - 1 do
        begin
          Line := LowerCase(OutputList[i]);
          if (Pos('lsfg fp16 quality', Line) > 0) and (Pos('compatible', Line) > 0) then
            Fp16Ok := True;
          if (Pos('lsfg fp32 quality', Line) > 0) and (Pos('compatible', Line) > 0) then
            Fp32Ok := True;
          if (Pos('ls1 quality resources', Line) > 0) and (Pos('compatible', Line) > 0) then
            Ls1Ok := True;
          if Pos('result:', Line) > 0 then
            Result := (Pos('compatible', Line) > 0);
        end;

        ADetails := '● DLL inspected: ';
        if Fp16Ok and Fp32Ok then
          ADetails := ADetails + 'LSFG (FP16/FP32 OK)'
        else if Fp32Ok then
          ADetails := ADetails + 'LSFG (FP32 OK)'
        else
          ADetails := ADetails + 'LSFG compatible';

        if Ls1Ok then
          ADetails := ADetails + ' | LS1 Scaling OK'
        else
          ADetails := ADetails + ' | LS1 unavailable';
      finally
        OutputList.Free;
        DeleteFile(TmpOut);
      end;
    end
    else
    begin
      ADetails := 'DLL located';
      Result := True;
    end;
  finally
    Process.Free;
  end;
end;

function IsLsfgVkInstalled: Boolean;
var
  HomeDir, UserLayerDir: string;
begin
  HomeDir := GetUserDir;
  UserLayerDir := IncludeTrailingPathDelimiter(HomeDir) + '.local/share/vulkan/implicit_layer.d/';

  Result := FileExists(UserLayerDir + 'VkLayer_LSFGVK_frame_generation.json') or
            FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
            FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
            FileExists('/usr/local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
            FileExists('/app/lib/extensions/vulkan/lsfgvk/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
            FileExists(UserLayerDir + 'VkLayer_LS_frame_generation.json') or
            FileExists(UserLayerDir + 'VkLayer_LSFGVK.json') or
            FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') or
            FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') or
            FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') or
            FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK.json');
end;

function GetLsfgVkLibraryPath: string;
var
  Candidate: string;
begin
  Result := '';
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/liblsfg-vk-layer.so';
  if FileExists(Candidate) then Exit(Candidate);

  if FileExists('/usr/lib/liblsfg-vk-layer.so') then Exit('/usr/lib/liblsfg-vk-layer.so');
  if FileExists('/usr/lib/x86_64-linux-gnu/liblsfg-vk-layer.so') then Exit('/usr/lib/x86_64-linux-gnu/liblsfg-vk-layer.so');
  if FileExists('/usr/local/lib/liblsfg-vk-layer.so') then Exit('/usr/local/lib/liblsfg-vk-layer.so');
  if FileExists('/app/lib/extensions/vulkan/lsfgvk/lib/liblsfg-vk-layer.so') then Exit('/app/lib/extensions/vulkan/lsfgvk/lib/liblsfg-vk-layer.so');

  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/liblsfg-vk.so';
  if FileExists(Candidate) then Exit(Candidate);
  if FileExists('/usr/lib/liblsfg-vk.so') then Exit('/usr/lib/liblsfg-vk.so');
end;

function GetLsfgVkInstalledVersion: string;
var
  CliPath, LayerPath: string;
  Proc: TProcess;
  S: TStringList;
  Line, RawVer: string;
  i, p: Integer;
begin
  Result := '';
  RawVer := '';

  // 1. Try lsfg-vk-cli healthcheck
  CliPath := IncludeTrailingPathDelimiter(GetUserDir) + '.local/bin/lsfg-vk-cli';
  if not FileExists(CliPath) then
  begin
    if FileExists('/usr/bin/lsfg-vk-cli') then
      CliPath := '/usr/bin/lsfg-vk-cli'
    else if FileExists('/usr/local/bin/lsfg-vk-cli') then
      CliPath := '/usr/local/bin/lsfg-vk-cli'
    else if FileExists('/app/lib/extensions/vulkan/lsfgvk/bin/lsfg-vk-cli') then
      CliPath := '/app/lib/extensions/vulkan/lsfgvk/bin/lsfg-vk-cli'
    else
      CliPath := '';
  end;

  if (CliPath <> '') and FileExists(CliPath) then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := CliPath;
      Proc.Parameters.Add('healthcheck');
      Proc.Options := [poUsePipes, poWaitOnExit];
      try
        Proc.Execute;
        S := TStringList.Create;
        try
          S.LoadFromStream(Proc.Output);
          for i := 0 to S.Count - 1 do
          begin
            Line := Trim(S[i]);
            if Pos('Installed lsfg-vk-cli version:', Line) > 0 then
            begin
              p := Pos(':', Line);
              if p > 0 then
              begin
                RawVer := Trim(Copy(Line, p + 1, MaxInt));
                Break;
              end;
            end;
          end;
        finally
          S.Free;
        end;
      except
      end;
    finally
      Proc.Free;
    end;
  end;

  // 2. Direct inspect of Vulkan layer JSON file if healthcheck didn't yield version
  if (RawVer = '') and IsLsfgVkInstalled then
  begin
    LayerPath := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json';
    if not FileExists(LayerPath) then
      LayerPath := '/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json';
    if not FileExists(LayerPath) then
      LayerPath := '/app/lib/extensions/vulkan/lsfgvk/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json';

    if FileExists(LayerPath) then
    begin
      S := TStringList.Create;
      try
        S.LoadFromFile(LayerPath);
        for i := 0 to S.Count - 1 do
        begin
          Line := Trim(S[i]);
          if Pos('"implementation_version"', Line) > 0 then
          begin
            p := Pos(':', Line);
            if p > 0 then
            begin
              RawVer := Trim(Copy(Line, p + 1, MaxInt));
              RawVer := StringReplace(RawVer, '"', '', [rfReplaceAll]);
              RawVer := StringReplace(RawVer, ',', '', [rfReplaceAll]);
              RawVer := Trim(RawVer);
              if RawVer = '2' then RawVer := '2.0.0';
              Break;
            end;
          end;
        end;
      finally
        S.Free;
      end;
    end;
  end;

  // 3. Fallback: query package manager via TProcess
  if (RawVer = '') and not IsRunningInFlatpak then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := FindDefaultExecutablePath('sh');
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('pacman -Q lsfg-vk 2>/dev/null | awk ''{print $2}'' || ' +
                       'pacman -Q lsfg-vk-git 2>/dev/null | awk ''{print $2}'' || ' +
                       'dpkg-query -W -f=''${Version}'' lsfg-vk 2>/dev/null || ' +
                       'rpm -q --qf ''%{VERSION}'' lsfg-vk 2>/dev/null || echo ""');
      Proc.Options := [poUsePipes, poWaitOnExit];
      try
        Proc.Execute;
        S := TStringList.Create;
        try
          S.LoadFromStream(Proc.Output);
          if S.Count > 0 then RawVer := Trim(S[0]);
        finally
          S.Free;
        end;
      except
      end;
    finally
      Proc.Free;
    end;
  end;

  if RawVer <> '' then
  begin
    if Pos(':', RawVer) > 0 then
      RawVer := Copy(RawVer, Pos(':', RawVer) + 1, MaxInt);
    while (RawVer <> '') and (RawVer[1] in ['v', 'V']) do
      Delete(RawVer, 1, 1);
  end;

  Result := RawVer;
end;

function ParseLsfgVkBuildsHtml(const AHtml: string; out AUrl: string): string;
var
  OutputList: TStringList;
  Line, TagVer, Href: string;
  i, p1, p2: Integer;
begin
  Result := '';
  AUrl := '';
  if AHtml = '' then Exit;

  OutputList := TStringList.Create;
  try
    OutputList.Text := AHtml;
    for i := 0 to OutputList.Count - 1 do
    begin
      Line := OutputList[i];
      if Pos('Latest release (', Line) > 0 then
      begin
        p1 := Pos('(', Line);
        p2 := Pos(')', Line);
        if (p1 > 0) and (p2 > p1) then
        begin
          TagVer := Copy(Line, p1 + 1, p2 - p1 - 1);
          Result := Trim(TagVer);
        end;

        p1 := Pos('href="', Line);
        if p1 > 0 then
        begin
          Href := Copy(Line, p1 + 6, MaxInt);
          p2 := Pos('"', Href);
          if p2 > 0 then
            Href := Copy(Href, 1, p2 - 1);
          if Pos('http', Href) = 1 then
            AUrl := Href
          else
            AUrl := URL_LSFGVK_BUILDS + Href;
        end;

        if Result <> '' then Break;
      end;
    end;
  finally
    OutputList.Free;
  end;
end;

function GetLsfgVkLatestRemoteVersion(out AUrl: string): string;
var
  RespFile: string;
  Process: TProcess;
  OutputList: TStringList;
begin
  Result := '';
  AUrl := '';

  RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'lsfgvk_builds_' + IntToStr(fpgetpid) + '.html';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('10');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(RespFile);
    Process.Parameters.Add(URL_LSFGVK_BUILDS);
    Process.Options := [poWaitOnExit];
    Process.Execute;

    if FileExists(RespFile) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(RespFile);
        Result := ParseLsfgVkBuildsHtml(OutputList.Text, AUrl);
      finally
        OutputList.Free;
        DeleteFile(RespFile);
      end;
    end;
  finally
    Process.Free;
  end;

  if Result = '' then
  begin
    Result := '';
    AUrl := '';
  end;
end;

function CheckAndInstallLsfgVk(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  ChanLabel: string;
  StartPct, EndPct: Integer;
  DownloadUrl, RemoteVer, TempTarFile, LocalUserDir: string;
  Process: TProcess;
begin
  Result := False;
  StartPct := 85;
  EndPct := 98;

  // In Flatpak, skip downloading; layer is provided via Flathub extension
  if IsRunningInFlatpak then
  begin
    WriteLn('[AUTO-INSTALL] Flatpak environment detected; lsfg-vk is managed via VulkanLayer extension');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'lsfg-vk Flatpak extension ready');
    Result := True;
    Exit;
  end;

  if not AForce and IsLsfgVkInstalled then
  begin
    WriteLn('[AUTO-INSTALL] lsfg-vk layer is already available');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'lsfg-vk runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Downloading lsfg-vk runtime';
  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 2, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Installing lsfg-vk layer in user space...');
  WriteLn('[AUTO-INSTALL] ========================================');

  try
    DownloadUrl := '';
    RemoteVer := GetLsfgVkLatestRemoteVersion(DownloadUrl);
    if DownloadUrl = '' then
    begin
      // Never downgrade an existing install: if the lsfg-vk layer is already
      // present, keep it instead of forcing the baseline tarball.
      if IsLsfgVkInstalled then
      begin
        WriteLn('[AUTO-INSTALL] lsfg-vk remote discovery failed; keeping installed runtime');
        Exit(False);
      end;
      DownloadUrl := URL_LSFGVK_TARBALL;
    end;
    TempTarFile := IncludeTrailingPathDelimiter(GetTempDir) + 'lsfg_vk_download.tar.xz';
    LocalUserDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local';

    RunCurlWithProgress(DownloadUrl, TempTarFile, StartPct + 3, StartPct + 9, ChanLabel, AOnProgress);

    if FileExists(TempTarFile) then
    begin
      ForceDirectories(LocalUserDir);
      if Assigned(AOnProgress) then
        AOnProgress(StartPct + 10, 'Extracting lsfg-vk runtime...');

      Process := TProcess.Create(nil);
      try
        Process.Executable := 'tar';
        Process.Parameters.Add('-xf');
        Process.Parameters.Add(TempTarFile);
        Process.Parameters.Add('-C');
        Process.Parameters.Add(LocalUserDir);
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;

      // Ensure binaries are executable
      Process := TProcess.Create(nil);
      try
        Process.Executable := '/bin/sh';
        Process.Parameters.Add('-c');
        Process.Parameters.Add('chmod +x "$HOME/.local/bin/lsfg-vk-"* 2>/dev/null; true');
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;

      DeleteFile(TempTarFile);
    end;

    if IsLsfgVkInstalled then
    begin
      WriteLn('[AUTO-INSTALL] lsfg-vk runtime installed successfully');
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'lsfg-vk runtime ready');
      Result := True;
    end
    else
      WriteLn('[AUTO-INSTALL] ERROR: lsfg-vk layer not detected after installation');
  except
    on E: Exception do
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallLsfgVk: ', E.Message);
  end;
end;

function IsAfmfInstalled: Boolean;
var
  HomeDir, UserLayerDir: string;
begin
  HomeDir := GetUserDir;
  UserLayerDir := IncludeTrailingPathDelimiter(HomeDir) + '.local/share/vulkan/implicit_layer.d/';

  Result := FileExists(UserLayerDir + 'afmf-linux.json') or
            FileExists('/usr/share/vulkan/implicit_layer.d/afmf-linux.json') or
            FileExists('/usr/local/share/vulkan/implicit_layer.d/afmf-linux.json') or
            FileExists('/etc/vulkan/implicit_layer.d/afmf-linux.json') or
            FileExists('/app/share/vulkan/implicit_layer.d/afmf-linux.json');
end;

function GetAfmfLibraryPath: string;
var
  Candidate: string;
begin
  Result := '';
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/afmf-linux/libafmf-linux.so';
  if FileExists(Candidate) then Exit(Candidate);

  if FileExists('/usr/lib/afmf-linux/libafmf-linux.so') then Exit('/usr/lib/afmf-linux/libafmf-linux.so');
  if FileExists('/usr/lib/libafmf-linux.so') then Exit('/usr/lib/libafmf-linux.so');
  if FileExists('/usr/lib/x86_64-linux-gnu/afmf-linux/libafmf-linux.so') then Exit('/usr/lib/x86_64-linux-gnu/afmf-linux/libafmf-linux.so');
  if FileExists('/usr/lib/x86_64-linux-gnu/libafmf-linux.so') then Exit('/usr/lib/x86_64-linux-gnu/libafmf-linux.so');
  if FileExists('/usr/local/lib/afmf-linux/libafmf-linux.so') then Exit('/usr/local/lib/afmf-linux/libafmf-linux.so');
  if FileExists('/usr/local/lib/libafmf-linux.so') then Exit('/usr/local/lib/libafmf-linux.so');
  if FileExists('/app/lib/afmf-linux/libafmf-linux.so') then Exit('/app/lib/afmf-linux/libafmf-linux.so');
end;

function GetAfmfInstalledVersion: string;
var
  LayerPath, Line, RawVer, SubStr: string;
  S: TStringList;
  i, p1, p2: Integer;
  Proc: TProcess;
begin
  Result := '';
  RawVer := '';

  LayerPath := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/afmf-linux.json';
  if not FileExists(LayerPath) then
    LayerPath := '/usr/local/share/vulkan/implicit_layer.d/afmf-linux.json';
  if not FileExists(LayerPath) then
    LayerPath := '/usr/share/vulkan/implicit_layer.d/afmf-linux.json';
  if not FileExists(LayerPath) then
    LayerPath := '/etc/vulkan/implicit_layer.d/afmf-linux.json';
  if not FileExists(LayerPath) then
    LayerPath := '/app/share/vulkan/implicit_layer.d/afmf-linux.json';

  if FileExists(LayerPath) then
  begin
    S := TStringList.Create;
    try
      S.LoadFromFile(LayerPath);
      for i := 0 to S.Count - 1 do
      begin
        Line := Trim(S[i]);
        p1 := Pos('afmf-linux ', Line);
        if p1 > 0 then
        begin
          SubStr := Copy(Line, p1 + Length('afmf-linux '), MaxInt);
          p2 := Pos(':', SubStr);
          if p2 > 0 then
            RawVer := Trim(Copy(SubStr, 1, p2 - 1))
          else
          begin
            p2 := Pos('"', SubStr);
            if p2 > 0 then
              RawVer := Trim(Copy(SubStr, 1, p2 - 1));
          end;
          if RawVer <> '' then Break;
        end;
      end;
    finally
      S.Free;
    end;
  end;

  // Fallback: query package manager via TProcess
  if (RawVer = '') and not IsRunningInFlatpak then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := FindDefaultExecutablePath('sh');
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('pacman -Q afmf-linux 2>/dev/null | awk ''{print $2}'' || ' +
                          'pacman -Q afmf-linux-bin 2>/dev/null | awk ''{print $2}'' || ' +
                          'dpkg-query -W -f=''${Version}'' afmf-linux 2>/dev/null || ' +
                          'rpm -q --qf ''%{VERSION}'' afmf-linux 2>/dev/null || echo ""');
      Proc.Options := [poUsePipes, poWaitOnExit];
      try
        Proc.Execute;
        S := TStringList.Create;
        try
          S.LoadFromStream(Proc.Output);
          if S.Count > 0 then RawVer := Trim(S[0]);
        finally
          S.Free;
        end;
      except
      end;
    finally
      Proc.Free;
    end;
  end;

  if RawVer <> '' then
  begin
    if Pos(':', RawVer) > 0 then
      RawVer := Copy(RawVer, Pos(':', RawVer) + 1, MaxInt);
    while (RawVer <> '') and (RawVer[1] in ['v', 'V']) do
      Delete(RawVer, 1, 1);
  end;

  if (RawVer = '') and IsAfmfInstalled then
    RawVer := 'Installed';

  Result := RawVer;
end;

function GetAfmfLatestRemoteVersion(out AUrl: string): string;
var
  RespFile, RespText, TagName, DownloadUrl, AssetName, Tag, CleanTag: string;
  Process: TProcess;
  OutputList: TStringList;
  JsonData, AssetData: TJSONData;
  ReleaseObj, AssetObj: TJSONObject;
  AssetsArray: TJSONArray;
  i: Integer;
begin
  Result := '';
  AUrl := '';
  DownloadUrl := '';
  TagName := '';

  RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'afmf_api_' + IntToStr(fpgetpid) + '.json';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('10');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(RespFile);
    Process.Parameters.Add(URL_AFMF_API_RELEASES);
    Process.Options := [poWaitOnExit];
    Process.Execute;

    if FileExists(RespFile) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(RespFile);
        RespText := OutputList.Text;
      finally
        OutputList.Free;
        DeleteFile(RespFile);
      end;

      if RespText <> '' then
      begin
        try
          JsonData := GetJSON(RespText);
          try
            if Assigned(JsonData) and (JsonData is TJSONObject) then
            begin
              ReleaseObj := TJSONObject(JsonData);
              if ReleaseObj.IndexOfName('tag_name') <> -1 then
                TagName := ReleaseObj.Get('tag_name', '');

              if ReleaseObj.IndexOfName('assets') <> -1 then
              begin
                AssetData := ReleaseObj.FindPath('assets');
                if Assigned(AssetData) and (AssetData is TJSONArray) then
                begin
                  AssetsArray := TJSONArray(AssetData);
                  for i := 0 to AssetsArray.Count - 1 do
                  begin
                    AssetObj := TJSONObject(AssetsArray.Items[i]);
                    AssetName := AssetObj.Get('name', '');
                    if (Pos('.tar.xz', AssetName) > 0) and
                       (Pos('x86_64', AssetName) > 0) and
                       (Pos('.asc', AssetName) = 0) and
                       (Pos('.sha256', AssetName) = 0) and
                       (Pos('debug', AssetName) = 0) then
                    begin
                      DownloadUrl := AssetObj.Get('browser_download_url', '');
                      Break;
                    end;
                  end;
                end;
              end;
            end;
          finally
            JsonData.Free;
          end;
        except
        end;
      end;
    end;
  finally
    Process.Free;
  end;

  if TagName <> '' then
  begin
    while (TagName <> '') and (TagName[1] in ['v', 'V']) do
      Delete(TagName, 1, 1);
    Result := TagName;
    AUrl := DownloadUrl;
  end;

  if TagName = '' then
  begin
    // Remote discovery failed: fall back to the Atom feed before giving up.
    Tag := FetchLatestReleaseTagFromAtom('serialexperimentslainnnn', 'afmf-linux');
    if Tag <> '' then
    begin
      CleanTag := Tag;
      while (CleanTag <> '') and (CleanTag[1] in ['v', 'V']) do
        Delete(CleanTag, 1, 1);
      Result := CleanTag;
      AUrl := 'https://github.com/serialexperimentslainnnn/afmf-linux/releases/download/' + Tag + '/afmf-linux-' + CleanTag + '-x86_64.tar.xz';
    end;
  end;

  if Result = '' then
    AUrl := '';
end;

function CheckAndInstallAfmf(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  ChanLabel: string;
  StartPct, EndPct: Integer;
  DownloadUrl, RemoteVer, TempTarFile, LocalLibDir, LocalLayerDir, TempExtractDir: string;
  Process: TProcess;
begin
  Result := False;
  StartPct := 88;
  EndPct := 94;

  if IsRunningInFlatpak then
  begin
    WriteLn('[AUTO-INSTALL] Flatpak environment detected; skipping afmf-linux user layer installation');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'AFMF Flatpak layer check ready');
    Result := True;
    Exit;
  end;

  if not AForce and IsAfmfInstalled then
  begin
    WriteLn('[AUTO-INSTALL] afmf-linux layer is already available');
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'AFMF runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Downloading AFMF runtime';
  if Assigned(AOnProgress) then
    AOnProgress(StartPct + 1, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Installing afmf-linux layer in user space...');
  WriteLn('[AUTO-INSTALL] ========================================');

  try
    DownloadUrl := '';
    RemoteVer := GetAfmfLatestRemoteVersion(DownloadUrl);
    if DownloadUrl = '' then
    begin
      // Never downgrade an existing install: if the afmf-linux layer is
      // already present, keep it instead of forcing the baseline tarball.
      if IsAfmfInstalled then
      begin
        WriteLn('[AUTO-INSTALL] AFMF remote discovery failed; keeping installed runtime');
        Exit(False);
      end;
      DownloadUrl := URL_AFMF_TARBALL;
    end;
    TempTarFile := IncludeTrailingPathDelimiter(GetTempDir) + 'afmf_linux_download_' + IntToStr(fpgetpid) + '.tar.xz';
    TempExtractDir := IncludeTrailingPathDelimiter(GetTempDir) + 'afmf_unpack_' + IntToStr(fpgetpid);

    RunCurlWithProgress(DownloadUrl, TempTarFile, StartPct + 2, StartPct + 4, ChanLabel, AOnProgress);

    if FileExists(TempTarFile) then
    begin
      ForceDirectories(TempExtractDir);
      if Assigned(AOnProgress) then
        AOnProgress(StartPct + 4, 'Extracting AFMF runtime...');

      Process := TProcess.Create(nil);
      try
        Process.Executable := 'tar';
        Process.Parameters.Add('-xf');
        Process.Parameters.Add(TempTarFile);
        Process.Parameters.Add('-C');
        Process.Parameters.Add(TempExtractDir);
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;

      if Assigned(AOnProgress) then
        AOnProgress(StartPct + 5, 'Installing AFMF runtime...');

      Process := TProcess.Create(nil);
      try
        Process.Executable := FindDefaultExecutablePath('bash');
        if Process.Executable = '' then
          Process.Executable := FindDefaultExecutablePath('sh');
        Process.Parameters.Add('-c');
        Process.Parameters.Add('for d in "' + TempExtractDir + '"/afmf-linux*; do ' +
                               'if [ -f "$d/install.sh" ]; then chmod +x "$d/install.sh" && (cd "$d" && ./install.sh); break; fi; done');
        Process.Options := [poWaitOnExit];
        Process.Execute;
      finally
        Process.Free;
      end;

      // Ensure destination files exist; fallback manual install if install.sh did not complete
      LocalLibDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/lib/afmf-linux/';
      LocalLayerDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/';
      if not FileExists(LocalLibDir + 'libafmf-linux.so') or not FileExists(LocalLayerDir + 'afmf-linux.json') then
      begin
        Process := TProcess.Create(nil);
        try
          Process.Executable := FindDefaultExecutablePath('sh');
          Process.Parameters.Add('-c');
          Process.Parameters.Add('mkdir -p "' + LocalLibDir + '" "' + LocalLayerDir + '" && ' +
                                 'find "' + TempExtractDir + '" -name "libafmf-linux.so" -exec cp -f {} "' + LocalLibDir + '" \; && ' +
                                 'find "' + TempExtractDir + '" -name "afmf-linux.json" -exec cp -f {} "' + LocalLayerDir + '" \; && ' +
                                 'sed -i "s|\"library_path\": *\"[^\"]*\"|\"library_path\": \"' + LocalLibDir + 'libafmf-linux.so\"|" "' + LocalLayerDir + 'afmf-linux.json" 2>/dev/null; true');
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;
      end;

      DeleteFile(TempTarFile);
      if DirectoryExists(TempExtractDir) then
        DeleteDirectory(TempExtractDir, False);
    end;

    if IsAfmfInstalled then
    begin
      WriteLn('[AUTO-INSTALL] afmf-linux runtime installed successfully');
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'AFMF runtime ready');
      Result := True;
    end
    else
      WriteLn('[AUTO-INSTALL] ERROR: afmf-linux layer not detected after installation');
  except
    on E: Exception do
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallAfmf: ', E.Message);
  end;
end;

function ExtractArchive7z(const A7zFile, ADestPath: string): Boolean;
var
  Process: TProcess;
  Exe7z: string;
begin
  Result := False;
  if not FileExists(A7zFile) then Exit;
  Exe7z := FindDefaultExecutablePath('7z');
  if Exe7z = '' then Exe7z := FindDefaultExecutablePath('7za');
  if Exe7z = '' then Exe7z := FindDefaultExecutablePath('7zr');
  if Exe7z = '' then
  begin
    WriteLn('[ERROR] 7z executable not found on system');
    Exit;
  end;

  ForceDirectories(ADestPath);
  Process := TProcess.Create(nil);
  try
    Process.Executable := Exe7z;
    Process.Parameters.Add('x');
    Process.Parameters.Add('-y');
    Process.Parameters.Add('-o' + ADestPath);
    Process.Parameters.Add(A7zFile);
    Process.Options := [poWaitOnExit];
    Flush(Output);
    Process.Execute;
    Result := (Process.ExitStatus = 0);
  finally
    Process.Free;
  end;
end;

function ExtractTarArchive(const ATarFile, ADestPath: string; AStripComponents: Integer = 0): Boolean;
var
  Process: TProcess;
  TarExe: string;
begin
  Result := False;
  if not FileExists(ATarFile) then Exit;
  TarExe := FindDefaultExecutablePath('tar');
  if TarExe = '' then TarExe := 'tar';

  ForceDirectories(ADestPath);
  Process := TProcess.Create(nil);
  try
    Process.Executable := TarExe;
    Process.Parameters.Add('-xzf');
    Process.Parameters.Add(ATarFile);
    if AStripComponents > 0 then
      Process.Parameters.Add('--strip-components=' + IntToStr(AStripComponents));
    Process.Parameters.Add('-C');
    Process.Parameters.Add(ExcludeTrailingPathDelimiter(ADestPath));
    Process.Options := [poWaitOnExit];
    Process.Execute;
    Result := (Process.ExitStatus = 0);
  finally
    Process.Free;
  end;
end;

function IsReShadeInstalled: Boolean;
var
  BinDir, ShadersDir: string;
begin
  BinDir := IncludeTrailingPathDelimiter(GetReShadeBinPath);
  ShadersDir := IncludeTrailingPathDelimiter(GetReShadeShadersPath);
  Result := FileExists(BinDir + 'ReShade64.dll') and
            FileExists(BinDir + 'ReShade32.dll') and
            DirectoryExists(ShadersDir + 'Shaders');
end;

function GetReShadeInstalledVersion: string;
var
  VerFile, BinDir: string;
  SL: TStringList;
begin
  Result := '';
  VerFile := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'version.txt';
  if FileExists(VerFile) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(VerFile);
      if SL.Count > 0 then
        Result := Trim(SL[0]);
    finally
      SL.Free;
    end;
  end;

  if (Length(Result) > 0) and (Result[1] in ['v', 'V']) then
    Delete(Result, 1, 1);

  if Result = '' then
  begin
    BinDir := IncludeTrailingPathDelimiter(GetReShadeBinPath);
    if FileExists(BinDir + 'ReShade64.dll') or FileExists(BinDir + 'ReShade32.dll') then
      Result := '6.4.0';
  end;
end;

function ParseReShadeMeHtml(const AHtml: string; out AUrl: string): string;
var
  pStart, pEnd: Integer;
  Ver: string;
  UpperHtml: string;
const
  PREFIX = 'ReShade_Setup_';
  SUFFIX = '_Addon.exe';
begin
  Result := '';
  AUrl := '';
  pStart := Pos(PREFIX, AHtml);
  if pStart > 0 then
  begin
    pStart := pStart + Length(PREFIX);
    pEnd := Pos(SUFFIX, Copy(AHtml, pStart, MaxInt));
    if pEnd <= 0 then
    begin
      UpperHtml := UpperCase(Copy(AHtml, pStart, MaxInt));
      pEnd := Pos('_ADDON.EXE', UpperHtml);
    end;
    if pEnd > 0 then
    begin
      Ver := Copy(AHtml, pStart, pEnd - 1);
      if (Ver <> '') and (Ver[1] in ['0'..'9']) then
      begin
        Result := Ver;
        AUrl := 'https://reshade.me/downloads/ReShade_Setup_' + Ver + '_Addon.exe';
      end;
    end;
  end;
end;

function GetReShadeLatestRemoteVersion(out AUrl: string): string;
var
  RespFile, RespText, TagName: string;
  Process: TProcess;
  OutputList: TStringList;
  JsonData: TJSONData;
  TagsArray: TJSONArray;
  TagObj: TJSONObject;
  i: Integer;
begin
  Result := '';
  AUrl := '';

  // 1. Try querying GitHub tags API
  RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'reshade_tags_' + IntToStr(fpgetpid) + '.json';
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'curl';
    Process.Parameters.Add('-sL');
    Process.Parameters.Add('--max-time');
    Process.Parameters.Add('10');
    Process.Parameters.Add('-H');
    Process.Parameters.Add('User-Agent: goverlay');
    Process.Parameters.Add('-o');
    Process.Parameters.Add(RespFile);
    Process.Parameters.Add(URL_RESHADE_TAGS_API);
    Process.Options := [poWaitOnExit];
    Process.Execute;

    if FileExists(RespFile) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(RespFile);
        RespText := OutputList.Text;
      finally
        OutputList.Free;
        DeleteFile(RespFile);
      end;

      if RespText <> '' then
      begin
        try
          JsonData := GetJSON(RespText);
          try
            if Assigned(JsonData) and (JsonData is TJSONArray) then
            begin
              TagsArray := TJSONArray(JsonData);
              if TagsArray.Count > 0 then
              begin
                for i := 0 to TagsArray.Count - 1 do
                begin
                  if TagsArray.Types[i] = jtObject then
                  begin
                    TagObj := TJSONObject(TagsArray[i]);
                    TagName := TagObj.Get('name', '');
                    if TagName <> '' then
                    begin
                      if TagName[1] in ['v', 'V'] then
                        Delete(TagName, 1, 1);
                      if (TagName <> '') and (TagName[1] in ['0'..'9']) then
                      begin
                        Result := TagName;
                        AUrl := 'https://reshade.me/downloads/ReShade_Setup_' + Result + '_Addon.exe';
                        Break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          finally
            JsonData.Free;
          end;
        except
          // ignore json parse error (e.g. rate limit response)
        end;
      end;
    end;
  finally
    Process.Free;
  end;

  // 2. If GitHub tags API didn't return a version, try parsing reshade.me homepage
  if Result = '' then
  begin
    RespFile := IncludeTrailingPathDelimiter(GetTempDir) + 'reshade_home_' + IntToStr(fpgetpid) + '.html';
    Process := TProcess.Create(nil);
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('--max-time');
      Process.Parameters.Add('10');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: goverlay');
      Process.Parameters.Add('-o');
      Process.Parameters.Add(RespFile);
      Process.Parameters.Add(URL_RESHADE_HOME);
      Process.Options := [poWaitOnExit];
      Process.Execute;

      if FileExists(RespFile) then
      begin
        OutputList := TStringList.Create;
        try
          OutputList.LoadFromFile(RespFile);
          Result := ParseReShadeMeHtml(OutputList.Text, AUrl);
        finally
          OutputList.Free;
          DeleteFile(RespFile);
        end;
      end;
    finally
      Process.Free;
    end;
  end;

  // 3. Fallback to known safe baseline version
  if Result = '' then
  begin
    Result := FALLBACK_RESHADE_VERSION;
    AUrl := 'https://reshade.me/downloads/ReShade_Setup_' + Result + '_Addon.exe';
  end;
  if AUrl = '' then
    AUrl := 'https://reshade.me/downloads/ReShade_Setup_' + Result + '_Addon.exe';
end;

function CheckAndInstallReShade(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  StartPct, EndPct: Integer;
  ChanLabel: string;
  ReShadeExeUrl, ShadersTarUrl: string;
  TempExe, TempExtractDir, TempTar: string;
  BinDir, ShadersDir, PresetsDir, IniTemplatePath, VerFilePath: string;
  IniLines: TStringList;
  RemoteVer: string;
begin
  Result := False;
  StartPct := 90;
  EndPct := 95;

  EnsureReShadeDirectories;
  BinDir := IncludeTrailingPathDelimiter(GetReShadeBinPath);
  ShadersDir := IncludeTrailingPathDelimiter(GetReShadeShadersPath);
  PresetsDir := IncludeTrailingPathDelimiter(GetReShadePresetsPath);

  if not AForce and IsReShadeInstalled then
  begin
    WriteLn('[AUTO-INSTALL] ReShade runtime is already installed (version: ', GetReShadeInstalledVersion, ')');
    Flush(Output);
    if Assigned(AOnProgress) then
      AOnProgress(EndPct, 'ReShade runtime ready');
    Result := True;
    Exit;
  end;

  ChanLabel := 'Checking ReShade runtime';
  if Assigned(AOnProgress) then
    AOnProgress(StartPct, ChanLabel);

  WriteLn('[AUTO-INSTALL] ========================================');
  WriteLn('[AUTO-INSTALL] Installing ReShade (Add-on) in user space...');
  WriteLn('[AUTO-INSTALL] ========================================');
  Flush(Output);

  try
    // Step 1: Discover latest remote version and download installer
    RemoteVer := GetReShadeLatestRemoteVersion(ReShadeExeUrl);
    if ReShadeExeUrl = '' then
      ReShadeExeUrl := 'https://reshade.me/downloads/ReShade_Setup_' + RemoteVer + '_Addon.exe';

    TempExe := IncludeTrailingPathDelimiter(GetTempDir) + 'ReShade_Setup_Addon.exe';
    TempExtractDir := IncludeTrailingPathDelimiter(GetTempDir) + 'reshade_ext_' + IntToStr(fpgetpid) + PathDelim;

    if Assigned(AOnProgress) then
      AOnProgress(StartPct + 1, 'Downloading ReShade ' + RemoteVer + ' (Add-on)...');

    WriteLn('[AUTO-INSTALL] Downloading ReShade version: ', RemoteVer, ' from ', ReShadeExeUrl);
    Flush(Output);

    if RunCurlWithProgress(ReShadeExeUrl, TempExe, StartPct + 1, StartPct + 3, 'Downloading ReShade...', AOnProgress) = 0 then
    begin
      if FileExists(TempExe) then
      begin
        if Assigned(AOnProgress) then
          AOnProgress(StartPct + 3, 'Extracting ReShade runtime...');

        ForceDirectories(TempExtractDir);
        Flush(Output);
        if ExtractArchive7z(TempExe, TempExtractDir) then
        begin
          if FileExists(TempExtractDir + 'ReShade64.dll') then
            CopyFile(TempExtractDir + 'ReShade64.dll', BinDir + 'ReShade64.dll');
          if FileExists(TempExtractDir + 'ReShade32.dll') then
            CopyFile(TempExtractDir + 'ReShade32.dll', BinDir + 'ReShade32.dll');
          if FileExists(TempExtractDir + 'ReShade64.json') then
            CopyFile(TempExtractDir + 'ReShade64.json', BinDir + 'ReShade64.json');
          if FileExists(TempExtractDir + 'ReShade32.json') then
            CopyFile(TempExtractDir + 'ReShade32.json', BinDir + 'ReShade32.json');

          // Persist installed version metadata
          VerFilePath := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'version.txt';
          IniLines := TStringList.Create;
          try
            IniLines.Add(RemoteVer);
            IniLines.SaveToFile(VerFilePath);
          finally
            IniLines.Free;
          end;
        end
        else
        begin
          WriteLn('[AUTO-INSTALL] 7z extraction of ReShade setup failed');
          Flush(Output);
          if Assigned(AFailedFiles) then
            AFailedFiles.Add('ReShade runtime (7z extraction failed)');
        end;

        DeleteDirectory(TempExtractDir, False);
        DeleteFile(TempExe);
      end;
    end
    else
    begin
      WriteLn('[AUTO-INSTALL] Download of ReShade setup failed');
      Flush(Output);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('ReShade_Setup_' + RemoteVer + '_Addon.exe');
    end;

    // Step 2: Download standard shaders if missing
    if not DirectoryExists(ShadersDir + 'Shaders') or AForce then
    begin
      ShadersTarUrl := 'https://github.com/crosire/reshade-shaders/archive/refs/heads/slim.tar.gz';
      TempTar := IncludeTrailingPathDelimiter(GetTempDir) + 'reshade-shaders-slim.tar.gz';

      if Assigned(AOnProgress) then
        AOnProgress(StartPct + 3, 'Downloading Standard Shaders...');

      if RunCurlWithProgress(ShadersTarUrl, TempTar, StartPct + 3, StartPct + 4, 'Downloading Standard Shaders...', AOnProgress) = 0 then
      begin
        if FileExists(TempTar) then
        begin
          if Assigned(AOnProgress) then
            AOnProgress(StartPct + 4, 'Extracting Standard Shaders...');

          Flush(Output);
          ExtractTarArchive(TempTar, ShadersDir, 1);
          DeleteFile(TempTar);
        end;
      end
      else
      begin
        WriteLn('[AUTO-INSTALL] Download of standard shaders failed');
        Flush(Output);
        if Assigned(AFailedFiles) then
          AFailedFiles.Add('ReShade Standard Shaders');
      end;
    end;

    // Step 3: Ensure ReShade.ini template exists
    IniTemplatePath := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'ReShade.ini';
    if not FileExists(IniTemplatePath) then
    begin
      IniLines := TStringList.Create;
      try
        IniLines.Add('[GENERAL]');
        IniLines.Add('EffectSearchPaths=' + UnixPathToWinePath(ShadersDir + 'Shaders') + '\**');
        IniLines.Add('TextureSearchPaths=' + UnixPathToWinePath(ShadersDir + 'Textures') + '\**');
        IniLines.Add('IntermediateCachePath=' + UnixPathToWinePath(IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'cache'));
        IniLines.Add('PresetPath=' + UnixPathToWinePath(PresetsDir + 'DefaultPreset.ini'));
        IniLines.Add('KeyOverlay=36,0,0,0');
        IniLines.Add('');
        IniLines.Add('[INPUT]');
        IniLines.Add('KeyOverlay=36,0,0,0');
        IniLines.SaveToFile(IniTemplatePath);
      finally
        IniLines.Free;
      end;
    end;

    Result := IsReShadeInstalled;
    if Result then
    begin
      WriteLn('[AUTO-INSTALL] ReShade runtime (Add-on) installed successfully (version: ', GetReShadeInstalledVersion, ')');
      Flush(Output);
      if Assigned(AOnProgress) then
        AOnProgress(EndPct, 'ReShade runtime ready');
    end;
  except
    on E: Exception do
    begin
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallReShade: ', E.Message);
      Flush(Output);
    end;
  end;
end;

function InstallReShadeShaderPack(const APackName, ARepoUrl: string; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  TempTar, ShadersDir: string;
begin
  Result := False;
  ShadersDir := IncludeTrailingPathDelimiter(GetReShadeShadersPath);
  TempTar := IncludeTrailingPathDelimiter(GetTempDir) + 'reshade_pack_' + APackName + '.tar.gz';

  if Assigned(AOnProgress) then
    AOnProgress(10, 'Downloading ' + APackName + '...');

  if RunCurlWithProgress(ARepoUrl, TempTar, 10, 80, 'Downloading ' + APackName + '...', AOnProgress) = 0 then
  begin
    if FileExists(TempTar) then
    begin
      if Assigned(AOnProgress) then
        AOnProgress(85, 'Extracting ' + APackName + '...');

      Result := ExtractTarArchive(TempTar, ShadersDir, 1);
      DeleteFile(TempTar);
      if Result and Assigned(AOnProgress) then
        AOnProgress(100, APackName + ' installed');
    end;
  end;
end;

function CheckAndInstallVkBasaltShaders(AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  DestDir, TempTar, ShadersTarUrl: string;
  StartPct, EndPct: Integer;
begin
  Result := False;
  DestDir := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir) + 'reshade-shaders';
  if DirectoryExists(DestDir) and not AForce then
  begin
    Result := True;
    Exit;
  end;

  StartPct := 95;
  EndPct := 99;

  try
    ForceDirectories(DestDir);
    ShadersTarUrl := 'https://github.com/benjamimgois/reshade-shaders/archive/refs/heads/master.tar.gz';
    TempTar := IncludeTrailingPathDelimiter(GetTempDir) + 'vkbasalt-reshade-shaders-master.tar.gz';

    if Assigned(AOnProgress) then
      AOnProgress(StartPct, 'Downloading vkBasalt Shaders...');

    if RunCurlWithProgress(ShadersTarUrl, TempTar, StartPct, StartPct + 3, 'Downloading vkBasalt Shaders...', AOnProgress) = 0 then
    begin
      if FileExists(TempTar) then
      begin
        if Assigned(AOnProgress) then
          AOnProgress(StartPct + 3, 'Extracting vkBasalt Shaders...');

        Result := ExtractTarArchive(TempTar, DestDir, 1);
        DeleteFile(TempTar);

        if Result then
        begin
          WriteLn('[AUTO-INSTALL] vkBasalt ReShade shaders installed successfully to: ', DestDir);
          Flush(Output);
          if Assigned(AOnProgress) then
            AOnProgress(EndPct, 'vkBasalt Shaders ready');
        end
        else
        begin
          WriteLn('[AUTO-INSTALL] Tar extraction of vkBasalt shaders failed');
          Flush(Output);
          if Assigned(AFailedFiles) then
            AFailedFiles.Add('vkBasalt ReShade Shaders (extraction failed)');
        end;
      end;
    end
    else
    begin
      WriteLn('[AUTO-INSTALL] Download of vkBasalt shaders failed');
      Flush(Output);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('vkBasalt ReShade Shaders');
    end;
  except
    on E: Exception do
    begin
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallVkBasaltShaders: ', E.Message);
      Flush(Output);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('vkBasalt ReShade Shaders: ' + E.Message);
    end;
  end;
end;

// Query the latest DLSS-NR release for the given architecture from the GitHub
// API. Fills ATag with the release tag and AUrl with the matching .tar.gz asset
// URL, falling back to hand-picked baseline URLs when the API is rate limited
// or unreachable.
function FetchDlssNrLatestRelease(const AArch: string; out ATag, AUrl: string): Boolean;
var
  Owner, Repo, TmpFile, ApiUrl, RespText, Candidate, LowerCandidate: string;
  Process: TProcess;
  OutputList: TStringList;
  IsRdna3: Boolean;
  Attempt, TagPos, ColonPos, QuoteStart, QuoteEnd, UrlPos, HttpPos: Integer;
begin
  Result := False;
  ATag := '';
  AUrl := '';
  RespText := '';

  IsRdna3 := SameText(AArch, 'rdna3');
  if IsRdna3 then
  begin
    Owner := 'mauri870';
    Repo := 'DLSSNR-RDNA3';
  end
  else
  begin
    Owner := 'mochizuki0323';
    Repo := 'DLSSNR-AMD';
  end;

  TmpFile := IncludeTrailingPathDelimiter(GetTempDir) + 'dlssnr_api_' + AArch + '_' + IntToStr(fpgetpid) + '.json';

  for Attempt := 0 to 1 do
  begin
    if Attempt = 0 then
      ApiUrl := 'https://api.github.com/repos/' + Owner + '/' + Repo + '/releases/latest'
    else
      ApiUrl := 'https://api.github.com/repos/' + Owner + '/' + Repo + '/releases';

    Process := TProcess.Create(nil);
    try
      Process.Executable := 'curl';
      Process.Parameters.Add('--max-time');
      Process.Parameters.Add('15');
      Process.Parameters.Add('-sL');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: goverlay');
      Process.Parameters.Add('-o');
      Process.Parameters.Add(TmpFile);
      Process.Parameters.Add(ApiUrl);
      Process.Options := [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;

    RespText := '';
    if FileExists(TmpFile) then
    begin
      OutputList := TStringList.Create;
      try
        OutputList.LoadFromFile(TmpFile);
        RespText := OutputList.Text;
      finally
        OutputList.Free;
        DeleteFile(TmpFile);
      end;
    end;

    if RespText = '' then Continue;

    // Parse "tag_name": "vX.Y.Z"
    if ATag = '' then
    begin
      TagPos := Pos('"tag_name"', RespText);
      if TagPos > 0 then
      begin
        ColonPos := PosEx(':', RespText, TagPos + 10);
        if ColonPos > 0 then
        begin
          QuoteStart := PosEx('"', RespText, ColonPos);
          if QuoteStart > 0 then
          begin
            QuoteEnd := PosEx('"', RespText, QuoteStart + 1);
            if QuoteEnd > QuoteStart then
              ATag := Copy(RespText, QuoteStart + 1, QuoteEnd - QuoteStart - 1);
          end;
        end;
      end;
    end;

    // Locate the first browser_download_url that points to a suitable .tar.gz
    if AUrl = '' then
    begin
      UrlPos := Pos('browser_download_url', RespText);
      while UrlPos > 0 do
      begin
        HttpPos := PosEx('http', RespText, UrlPos);
        if HttpPos > 0 then
        begin
          QuoteEnd := PosEx('"', RespText, HttpPos);
          if QuoteEnd > HttpPos then
          begin
            Candidate := Copy(RespText, HttpPos, QuoteEnd - HttpPos);
            LowerCandidate := LowerCase(Candidate);
            if Pos('.tar.gz', LowerCandidate) > 0 then
            begin
              if IsRdna3 then
              begin
                if (Pos('rdna3', LowerCandidate) > 0) or (Pos('x86_64', LowerCandidate) > 0) then
                  AUrl := Candidate;
              end
              else
              begin
                if (Pos('x86_64', LowerCandidate) > 0) and
                   (Pos('rdna3', LowerCandidate) = 0) and
                   (Pos('i686', LowerCandidate) = 0) then
                  AUrl := Candidate;
              end;
            end;
          end;
        end;
        if AUrl <> '' then Break;
        UrlPos := PosEx('browser_download_url', RespText, UrlPos + 20);
      end;
    end;

    if (ATag <> '') and (AUrl <> '') then Break;
  end;

  // Fallback baseline URLs when the API is unavailable, rate limited or offline
  if (ATag = '') or (AUrl = '') then
  begin
    if IsRdna3 then
    begin
      ATag := '0.0.6';
      AUrl := 'https://github.com/mauri870/DLSSNR-RDNA3/releases/download/0.0.6/DLSSNR-AMD-Vulkan-Linux-0.0.6-linux-preview-54-gaa39228-x86_64-rdna3.tar.gz';
    end
    else
    begin
      ATag := 'v0.0.6-linux-preview';
      AUrl := 'https://github.com/mochizuki0323/DLSSNR-AMD/releases/download/v0.0.6-linux-preview/DLSSNR-AMD-Vulkan-Linux-0.0.6-linux-preview-x86_64.tar.gz';
    end;
  end;

  Result := (ATag <> '') and (AUrl <> '');
end;

// Check and automatically install/heal the DLSS-NR runtime for the requested
// architecture. Extracts the release tarball into the central storage and
// mirrors any previously extracted neural models next to it.
function CheckAndInstallDlssNr(const AArch: string; AForce: Boolean = False; AOnProgress: TDownloadProgressProc = nil; AFailedFiles: TStrings = nil): Boolean;
var
  TargetDir, Tag, DownloadUrl, TempTar, VarsPath, ModelsSrcDir, SubDir: string;
  OptiScalerDir, NrZip: string;
  VarsList: TStringList;
  LineIdx: Integer;
  Process: TProcess;
  NrSearch: TSearchRec;
begin
  Result := False;
  TargetDir := IncludeTrailingPathDelimiter(GetBGModDlssNrPath(AArch));
  ForceDirectories(TargetDir);

  if not AForce and
     (FileExists(TargetDir + 'dlssnr-amd' + PathDelim + 'dlssnr.bin') or
      FileExists(TargetDir + 'goverlay.vars') or
      FileExists(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll')) then
    Exit(True);

  try
    Tag := '';
    DownloadUrl := '';
    if not FetchDlssNrLatestRelease(AArch, Tag, DownloadUrl) then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: could not resolve DLSS-NR release for ', AArch);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('DLSS-NR release (' + AArch + ')');
      Exit(False);
    end;

    TempTar := IncludeTrailingPathDelimiter(GetTempDir) + 'dlssnr_' + AArch + '_' + IntToStr(fpgetpid) + '.tar.gz';
    if RunCurlWithProgress(DownloadUrl, TempTar, 90, 95, 'Downloading DLSS-NR runtime', AOnProgress) <> 0 then
    begin
      WriteLn('[AUTO-INSTALL] ERROR: DLSS-NR download failed for ', AArch);
      if FileExists(TempTar) then DeleteFile(TempTar);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('DLSS-NR runtime (' + AArch + ')');
      Exit(False);
    end;

    if not FileExists(TempTar) then Exit(False);

    // Preferred layout: root directory is a subfolder, so strip it.
    ExtractTarArchive(TempTar, TargetDir, 1);

    // Fallback: the archive root already holds the files directly.
    if not (DirectoryExists(TargetDir + 'dlssnr-amd') or
            FileExists(TargetDir + 'goverlay.vars') or
            FileExists(TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll')) then
      ExtractTarArchive(TempTar, TargetDir, 0);

    DeleteFile(TempTar);

    // The release bundles an OptiScaler-NR package alongside an upstream
    // extractor. Run it so OptiScaler.dll and its supporting DLLs are
    // unpacked into the runtime directory, ready for game deployment.
    OptiScalerDir := IncludeTrailingPathDelimiter(TargetDir) + 'optiscaler';
    if FileExists(IncludeTrailingPathDelimiter(OptiScalerDir) + 'extract_release.py') then
    begin
      NrZip := '';
      if FindFirst(IncludeTrailingPathDelimiter(OptiScalerDir) + 'OptiScaler-NR-*.zip', faAnyFile, NrSearch) = 0 then
      begin
        NrZip := IncludeTrailingPathDelimiter(OptiScalerDir) + NrSearch.Name;
        FindClose(NrSearch);
      end;
      if NrZip <> '' then
      begin
        WriteLn('[AUTO-INSTALL] Extracting OptiScaler-NR release: ', NrZip);
        Process := TProcess.Create(nil);
        try
          Process.Executable := 'python3';
          Process.Parameters.Add(IncludeTrailingPathDelimiter(OptiScalerDir) + 'extract_release.py');
          Process.Parameters.Add(NrZip);
          Process.Parameters.Add(OptiScalerDir);
          Process.Options := [poWaitOnExit];
          Process.Execute;
        finally
          Process.Free;
        end;
      end;
    end;

    // Record the installed tag next to the extracted runtime.
    VarsPath := TargetDir + 'goverlay.vars';
    VarsList := TStringList.Create;
    try
      if FileExists(VarsPath) then
        VarsList.LoadFromFile(VarsPath);
      LineIdx := VarsList.IndexOfName('OPTISCALER_DLSSNR_VERSION');
      if LineIdx >= 0 then
        VarsList[LineIdx] := 'OPTISCALER_DLSSNR_VERSION=' + Tag
      else
        VarsList.Add('OPTISCALER_DLSSNR_VERSION=' + Tag);
      VarsList.SaveToFile(VarsPath);
    finally
      VarsList.Free;
    end;

    // Mirror any extracted neural models into the runtime folder.
    ModelsSrcDir := IncludeTrailingPathDelimiter(GetBGModDlssNrModelsPath);
    if FileExists(ModelsSrcDir + 'dlssnr.bin') then
    begin
      SubDir := TargetDir + 'dlssnr-amd' + PathDelim;
      ForceDirectories(SubDir);
      CopyFile(ModelsSrcDir + 'dlssnr.bin', SubDir + 'dlssnr.bin');
      if FileExists(ModelsSrcDir + 'dlssnr-small.bin') then
        CopyFile(ModelsSrcDir + 'dlssnr-small.bin', SubDir + 'dlssnr-small.bin');
    end;

    WriteLn('[AUTO-INSTALL] DLSS-NR (', AArch, ') installed: ', Tag);
    if Assigned(AOnProgress) then
      AOnProgress(96, 'DLSS-NR runtime ready');
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('[AUTO-INSTALL] ERROR in CheckAndInstallDlssNr: ', E.Message);
      if Assigned(AFailedFiles) then
        AFailedFiles.Add('DLSS-NR runtime (' + AArch + '): ' + E.Message);
    end;
  end;
end;

procedure SanitizeDlssNrExtractScript(const AScriptPath: string);
var
  Lines: TStringList;
  Text: string;
begin
  if not FileExists(AScriptPath) then Exit;
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(AScriptPath);
      Text := Lines.Text;
      if Pos('[DLSS-NR]', Text) > 0 then Exit; // already sanitized

      // Insert structured progress markers into extract_model.sh stages
      Text := StringReplace(Text,
        'if ! python3 "$here/inspect_nr.py" "$src" --output "$work/probe"',
        'echo "[DLSS-NR] 10% Probing model DLL..."' + LineEnding +
        'if ! python3 "$here/inspect_nr.py" "$src" --output "$work/probe"',
        [rfReplaceAll]);

      Text := StringReplace(Text,
        'cp -- "$here/$2" "$w/graph/descriptor.json"',
        'cp -- "$here/$2" "$w/graph/descriptor.json"' + LineEnding +
        '    echo "[DLSS-NR] 25% Inspecting neural weights ($1)..."',
        [rfReplaceAll]);

      Text := StringReplace(Text,
        'python3 unpack_swin_family.py',
        'echo "[DLSS-NR] 40% Unpacking Swin transformer layers ($1)..."' + LineEnding +
        '     python3 unpack_swin_family.py',
        [rfReplaceAll]);

      Text := StringReplace(Text,
        'python3 unpack_splitswin.py',
        'echo "[DLSS-NR] 55% Unpacking Split-Swin and ViT layers ($1)..."' + LineEnding +
        '     python3 unpack_splitswin.py',
        [rfReplaceAll]);

      Text := StringReplace(Text,
        'python3 pack_model.py',
        'echo "[DLSS-NR] 75% Packing neural model $6..."' + LineEnding +
        '     python3 pack_model.py',
        [rfReplaceAll]);

      Lines.Text := Text;
      Lines.SaveToFile(AScriptPath);
    except
      on E: Exception do
        WriteLn('[DLSS-NR] Warning: Could not sanitize extract_model.sh: ', E.Message);
    end;
  finally
    Lines.Free;
  end;
end;

// Extract the neural model weights from a user-provided nvngx_dlssnr.dll (or
// archive) using the bundled extract_model.sh helper, then distribute the
// resulting weights to every installed DLSS-NR runtime.
function ExtractDlssNrModel(const ADllPath: string; out AErrorMsg: string; AOnProgress: TDownloadProgressProc = nil): Boolean;
var
  TargetModelsDir, ExtractScript, Rdna3SubDir, Rdna4SubDir: string;
  Process: TProcess;
  Buffer: array[0..4095] of Byte;
  Pending, Line, PctStr, LabelStr: string;
  Count, i, PctPos, StartPos, PctVal: Integer;
  LastTick: QWord;
  EstimatedPct: Integer;

  procedure EmitProgressLine(const ALine: string);
  var
    L: string;
  begin
    L := LowerCase(ALine);
    // Parse percent if present: e.g. "[DLSS-NR] 45% Unpacking..." or "45% Unpacking..."
    PctPos := Pos('%', ALine);
    if PctPos > 1 then
    begin
      StartPos := PctPos - 1;
      while (StartPos >= 1) and (ALine[StartPos] in ['0'..'9', ' ']) do
        Dec(StartPos);
      PctStr := Trim(Copy(ALine, StartPos + 1, PctPos - StartPos - 1));
      PctVal := StrToIntDef(PctStr, -1);
      if (PctVal >= 0) and (PctVal <= 100) then
      begin
        LabelStr := Trim(Copy(ALine, PctPos + 1, MaxInt));
        if LabelStr = '' then
          LabelStr := 'Extracting DLSS-NR model weights...';
        if PctVal > EstimatedPct then
          EstimatedPct := PctVal;
        if Assigned(AOnProgress) then
          AOnProgress(PctVal, LabelStr);
        Exit;
      end;
    end;

    // Detect keywords from stdout/stderr for error tracking
    if (Pos('cannot read nvngx_dlssnr', L) > 0) or (Pos('differ from the tested model', L) > 0) or
       (Pos('is not nvngx_dlssnr', L) > 0) or (Pos('no such file', L) > 0) or
       (Pos('error', L) > 0) or (Pos('failed', L) > 0) then
      AErrorMsg := Trim(ALine);

    if not Assigned(AOnProgress) then Exit;

    if (Pos('probe', L) > 0) or (Pos('probing', L) > 0) then
      AOnProgress(15, 'Probing DLSS-NR model DLL...')
    else if Pos('unpack_swin', L) > 0 then
      AOnProgress(35, 'Unpacking Swin transformer layers...')
    else if Pos('unpack_splitswin', L) > 0 then
      AOnProgress(45, 'Unpacking split-swin neural blocks...')
    else if Pos('unpack_vit', L) > 0 then
      AOnProgress(55, 'Unpacking Vision Transformer layers...')
    else if (Pos('unpack_preblock', L) > 0) or (Pos('unpack_postblock', L) > 0) then
      AOnProgress(65, 'Unpacking convolution pre/post-blocks...')
    else if (Pos('pack_model', L) > 0) or (Pos('packing', L) > 0) or (Pos('dlssnr.bin', L) > 0) then
      AOnProgress(75, 'Packing neural model binaries...')
    else if Pos('entries', L) > 0 then
      AOnProgress(85, 'Verifying model checksums and integrity...');
  end;

begin
  Result := False;
  AErrorMsg := '';

  if not FileExists(ADllPath) then
  begin
    AErrorMsg := 'DLSS-NR model file not found: ' + ADllPath;
    Exit;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(5, 'Validating nvngx_dlssnr.dll...');

  TargetModelsDir := IncludeTrailingPathDelimiter(GetBGModDlssNrModelsPath);
  ForceDirectories(TargetModelsDir);

  ExtractScript := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')) + 'model-tools' + PathDelim + 'extract_model.sh';
  if not FileExists(ExtractScript) then
    ExtractScript := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')) + 'model-tools' + PathDelim + 'extract_model.sh';

  if not FileExists(ExtractScript) then
  begin
    if Assigned(AOnProgress) then
      AOnProgress(10, 'Downloading DLSS-NR tools (RDNA3)...');
    CheckAndInstallDlssNr('rdna3', True, AOnProgress);
    ExtractScript := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')) + 'model-tools' + PathDelim + 'extract_model.sh';
    if not FileExists(ExtractScript) then
    begin
      if Assigned(AOnProgress) then
        AOnProgress(15, 'Downloading DLSS-NR tools (RDNA4)...');
      CheckAndInstallDlssNr('rdna4', True, AOnProgress);
      ExtractScript := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')) + 'model-tools' + PathDelim + 'extract_model.sh';
    end;
  end;

  if not FileExists(ExtractScript) then
  begin
    AErrorMsg := 'extract_model.sh helper not found';
    Exit;
  end;

  SanitizeDlssNrExtractScript(ExtractScript);

  if Assigned(AOnProgress) then
    AOnProgress(15, 'Executing DLSS-NR model extractor...');

  Process := TProcess.Create(nil);
  try
    Process.Executable := 'bash';
    Process.Parameters.Add(ExtractScript);
    Process.Parameters.Add(ADllPath);
    Process.Parameters.Add(TargetModelsDir);
    Process.Options := [poUsePipes, poStderrToOutPut];
    Process.Execute;

    EstimatedPct := 15;
    LastTick := GetTickCount64;
    Pending := '';

    while Process.Running or (Process.Output.NumBytesAvailable > 0) do
    begin
      Count := Process.Output.NumBytesAvailable;
      if Count > SizeOf(Buffer) then
        Count := SizeOf(Buffer);
      if Count > 0 then
      begin
        Count := Process.Output.Read(Buffer, Count);
        if Count > 0 then
        begin
          SetLength(Pending, Length(Pending) + Count);
          Move(Buffer[0], Pending[Length(Pending) - Count + 1], Count);

          repeat
            i := Pos(#10, Pending);
            if i > 0 then
            begin
              Line := Trim(Copy(Pending, 1, i - 1));
              Delete(Pending, 1, i);
              if Line <> '' then
              begin
                WriteLn('[DLSS-NR] ', Line);
                EmitProgressLine(Line);
              end;
            end;
          until i = 0;
        end;
      end
      else
      begin
        Sleep(25);
        if Process.Running and (GetTickCount64 - LastTick > 800) then
        begin
          LastTick := GetTickCount64;
          if EstimatedPct < 85 then
          begin
            Inc(EstimatedPct, 5);
            if Assigned(AOnProgress) then
              AOnProgress(EstimatedPct, 'Processing neural model weights...');
          end;
        end;
      end;
    end;

    if Pending <> '' then
    begin
      Line := Trim(Pending);
      if Line <> '' then
      begin
        WriteLn('[DLSS-NR] ', Line);
        EmitProgressLine(Line);
      end;
    end;

    Process.WaitOnExit;
  finally
    Process.Free;
  end;

  if not FileExists(TargetModelsDir + 'dlssnr.bin') then
  begin
    if AErrorMsg = '' then
      AErrorMsg := 'Model extraction did not produce dlssnr.bin';
    if Assigned(AOnProgress) then
      AOnProgress(100, 'DLSS-NR model extraction failed.');
    Exit;
  end;

  if Assigned(AOnProgress) then
    AOnProgress(90, 'Deploying weights to DLSS-NR runtimes...');

  Rdna3SubDir := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')) + 'dlssnr-amd' + PathDelim;
  if DirectoryExists(Rdna3SubDir) then
  begin
    CopyFile(TargetModelsDir + 'dlssnr.bin', Rdna3SubDir + 'dlssnr.bin');
    if FileExists(TargetModelsDir + 'dlssnr-small.bin') then
      CopyFile(TargetModelsDir + 'dlssnr-small.bin', Rdna3SubDir + 'dlssnr-small.bin');
  end;

  Rdna4SubDir := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')) + 'dlssnr-amd' + PathDelim;
  if DirectoryExists(Rdna4SubDir) then
  begin
    CopyFile(TargetModelsDir + 'dlssnr.bin', Rdna4SubDir + 'dlssnr.bin');
    if FileExists(TargetModelsDir + 'dlssnr-small.bin') then
      CopyFile(TargetModelsDir + 'dlssnr-small.bin', Rdna4SubDir + 'dlssnr-small.bin');
  end;

  if Assigned(AOnProgress) then
    AOnProgress(100, 'DLSS-NR model weights ready.');

  Result := True;
end;

// Check whether the DLSS-NR runtime is installed in central storage.
function IsDlssNrInstalled(const AArch: string = ''): Boolean;
var
  TargetDir: string;

  function CheckDir(const ADir: string): Boolean;
  begin
    Result := FileExists(ADir + 'goverlay.vars') or
              FileExists(ADir + 'optiscaler' + PathDelim + 'OptiScaler.dll') or
              DirectoryExists(ADir + 'dlssnr-amd');
  end;

begin
  TargetDir := IncludeTrailingPathDelimiter(GetBGModDlssNrPath(AArch));
  Result := CheckDir(TargetDir);

  if not Result and (AArch = '') then
  begin
    Result := CheckDir(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')));
    if not Result then
      Result := CheckDir(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')));
  end;
end;

// Check whether extracted DLSS-NR models (dlssnr.bin) exist in central storage.
function IsDlssNrModelReady: Boolean;
begin
  Result := FileExists(IncludeTrailingPathDelimiter(GetBGModDlssNrModelsPath) + 'dlssnr.bin') or
            FileExists(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')) + 'dlssnr-amd' + PathDelim + 'dlssnr.bin') or
            FileExists(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')) + 'dlssnr-amd' + PathDelim + 'dlssnr.bin');
end;

// Read OPTISCALER_DLSSNR_VERSION from a goverlay.vars file, returning '' when absent.
function ReadDlssNrVersionFromVars(const AVarsPath: string): string;
var
  VarsList: TStringList;
begin
  Result := '';
  if not FileExists(AVarsPath) then Exit;
  VarsList := TStringList.Create;
  try
    VarsList.LoadFromFile(AVarsPath);
    Result := VarsList.Values['OPTISCALER_DLSSNR_VERSION'];
  finally
    VarsList.Free;
  end;
end;

// Retrieve the installed DLSS-NR version tag.
function GetDlssNrVersion(const AArch: string = ''): string;
begin
  Result := ReadDlssNrVersionFromVars(IncludeTrailingPathDelimiter(GetBGModDlssNrPath(AArch)) + 'goverlay.vars');

  if Result = '' then
  begin
    Result := ReadDlssNrVersionFromVars(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3')) + 'goverlay.vars');
    if Result = '' then
      Result := ReadDlssNrVersionFromVars(IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4')) + 'goverlay.vars');
  end;
end;

end.
