unit gui_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry;

type
  TGoverlayGuiTests = class(TTestCase)
  private
    function ReadGpuDriver: string;
    function ReadFileText(const APath: string): string;
    procedure NavigateVkBasaltTab;
    procedure NavigateVkSumiTab;
    procedure NavigateOptiScalerTab;
    procedure SeedOptiScalerFiles;
    function OptiIniPath: string;
    function FakeIniPath: string;
    function BgmodConfPath: string;
    function ReadBgmodConf(const ASection, AKey: string): string;
    procedure SaveOpti;
  published
    procedure TestFormCreated;
    procedure TestDriverToggleRoundTrip;
    procedure TestNavigateOptiScalerTab;
    procedure TestNavigateVkBasaltTab;
    procedure TestVkBasaltCasToggleSave;
    procedure TestNavigateVkSumiTab;
    procedure TestVkSumiContrastSaveAndRestore;
    // OptiScaler tab - full control coverage
    procedure TestOptiMenuScaleSave;
    procedure TestOptiShortcutKeySave;
    procedure TestOptiSpoofToggleSave;
    procedure TestOptiOverrideNvapiSave;
    procedure TestOptiPatcherToggleSave;
    procedure TestOptiFsrVersionPinned;
    procedure TestOptiPreferredUpscalerSave;
    procedure TestOptiForceFsr4Int8Save;
    procedure TestOptiFilenameDllSave;
    procedure TestOptiChannelSave;
    procedure TestOptiEmuFp8Save;
    procedure TestOptiForceReflexSave;
    procedure TestOptiLatencyFlexSave;
    procedure TestOptiTraceLogSave;
    procedure TestOptiUpdateButtonsGuarded;
    procedure TestOptiShortcutCaptureBound;
  end;

implementation

uses
  overlayunit, themeunit, IniFiles, FileUtil, test_isolation;

function TGoverlayGuiTests.ReadGpuDriver: string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetConfigFilePath);
  try
    Result := LowerCase(Trim(Ini.ReadString('OptiScaler', 'GpuDriver', '')));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.TestFormCreated;
begin
  AssertTrue('goverlayform is assigned', Assigned(goverlayform));
  AssertTrue('mesaRadioButton is assigned', Assigned(goverlayform.mesaRadioButton));
  AssertTrue('nvidiaRadioButton is assigned', Assigned(goverlayform.nvidiaRadioButton));
  AssertTrue('optiscalerLabel is assigned', Assigned(goverlayform.optiscalerLabel));
end;

procedure TGoverlayGuiTests.TestDriverToggleRoundTrip;
begin
  // Harness seeds GpuDriver=nvidia before the form is created. Both
  // transitions below are asserted, so the test is falsifiable.
  AssertEquals('seed state must be nvidia', 'nvidia', ReadGpuDriver);

  goverlayform.mesaRadioButton.Checked := True;
  AssertEquals('mesa persisted after checking mesa', 'mesa', ReadGpuDriver);
  AssertTrue('forcereflex enabled on mesa', goverlayform.forcereflexCheckBox.Enabled);

  goverlayform.nvidiaRadioButton.Checked := True;
  AssertEquals('nvidia persisted after checking nvidia', 'nvidia', ReadGpuDriver);
  AssertFalse('forcereflex disabled on nvidia', goverlayform.forcereflexCheckBox.Enabled);
  AssertFalse('spoof unchecked on nvidia', goverlayform.spoofCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestNavigateOptiScalerTab;
begin
  // TControl.Click is protected; invoking OnClick directly exercises the
  // exact .lfm binding -> handler chain, which is what this test verifies.
  AssertTrue('optiscalerLabel.OnClick is bound', Assigned(goverlayform.optiscalerLabel.OnClick));
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  AssertTrue('optiscaler tab is active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.optiscalerTabSheet);
end;

function TGoverlayGuiTests.ReadFileText(const APath: string): string;
var
  Lines: TStringList;
begin
  Result := '';
  if not FileExists(APath) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(APath);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TGoverlayGuiTests.NavigateVkBasaltTab;
begin
  // Pre-create reshade-shaders so vkbasaltTabSheetShow skips the git clone
  ForceDirectories(IsolatedHome + '/.config/vkBasalt/reshade-shaders');
  AssertTrue('vkbasaltLabel.OnClick is bound', Assigned(goverlayform.vkbasaltLabel.OnClick));
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
end;

procedure TGoverlayGuiTests.NavigateVkSumiTab;
begin
  // vkSumi has no sidebar label; it is a sibling tab next to vkBasalt.
  // Switching pages fires vkSumiTabSheetShow -> LoadVkSumiConfig.
  NavigateVkBasaltTab;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.vksumiTabSheet;
end;

procedure TGoverlayGuiTests.TestNavigateVkBasaltTab;
begin
  NavigateVkBasaltTab;
  AssertTrue('vkbasalt tab is active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.vkbasaltTabSheet);
  AssertTrue('vksumi tab becomes visible alongside vkbasalt',
    goverlayform.vksumiTabSheet.TabVisible);
end;

procedure TGoverlayGuiTests.TestVkBasaltCasToggleSave;
var
  ConfPath, Content: string;
begin
  NavigateVkBasaltTab;
  ConfPath := IsolatedHome + '/.config/vkBasalt/vkBasalt.conf';

  // CAS off -> save -> conf must not list cas in effects
  goverlayform.casTrackBar.Position := 0;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertFalse('cas absent from effects at position 0', Pos('effects = cas', Content) > 0);

  // CAS on -> save -> conf lists cas in effects
  goverlayform.casTrackBar.Position := 5;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('cas present in effects at position 5', Pos('effects = cas', Content) > 0);
end;

procedure TGoverlayGuiTests.TestNavigateVkSumiTab;
begin
  NavigateVkSumiTab;
  AssertTrue('vksumi tab is active',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.vksumiTabSheet);
  AssertTrue('vksumi trackbars were built', Assigned(goverlayform.FVsTrackbars[0]));
end;

procedure TGoverlayGuiTests.TestVkSumiContrastSaveAndRestore;
var
  ConfPath, Content: string;
begin
  NavigateVkSumiTab;
  ConfPath := IsolatedHome + '/.config/vkSumi/vkSumi.conf';

  // Contrast (index 1) to 150 -> 0.5 -> save via global Save button
  goverlayform.FVsTrackbars[1].Position := 150;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('contrast = 0.5 persisted', Pos('contrast = 0.5', Content) > 0);

  // Restore defaults -> contrast back to 0.0 (falsifiable both directions)
  AssertTrue('restore button bound', Assigned(goverlayform.FVsRestoreBtn));
  AssertTrue('restore button OnClick bound', Assigned(goverlayform.FVsRestoreBtn.OnClick));
  goverlayform.FVsRestoreBtn.OnClick(goverlayform.FVsRestoreBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('contrast = 0.0 after restore', Pos('contrast = 0.0', Content) > 0);
end;

// ────────────────────────── OptiScaler tab - full coverage ──────────────────────────

procedure TGoverlayGuiTests.NavigateOptiScalerTab;
begin
  AssertTrue('optiscalerLabel.OnClick is bound', Assigned(goverlayform.optiscalerLabel.OnClick));
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
end;

function TGoverlayGuiTests.OptiIniPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/OptiScaler.ini';
end;

function TGoverlayGuiTests.FakeIniPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/fakenvapi.ini';
end;

function TGoverlayGuiTests.BgmodConfPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/bgmod.conf';
end;

procedure TGoverlayGuiTests.SeedOptiScalerFiles;
var
  F: TextFile;
begin
  // SaveOptiScalerConfigCore only updates OptiScaler.ini / fakenvapi.ini when
  // they already exist (TConfigFile.Load gate) - seed realistic fixtures.
  ForceDirectories(ExtractFilePath(OptiIniPath));

  AssignFile(F, OptiIniPath);
  Rewrite(F);
  WriteLn(F, '[Menu]');
  WriteLn(F, 'ShortcutKey=auto');
  WriteLn(F, 'Scale=1.0');
  WriteLn(F);
  WriteLn(F, '[Upscalers]');
  WriteLn(F, 'Dx11Upscaler=auto');
  WriteLn(F, 'Dx12Upscaler=auto');
  WriteLn(F, 'VulkanUpscaler=auto');
  WriteLn(F);
  WriteLn(F, '[Spoofing]');
  WriteLn(F, 'Dxgi=auto');
  WriteLn(F, 'OverrideNvapiDll=auto');
  WriteLn(F);
  WriteLn(F, '[Plugins]');
  WriteLn(F, 'LoadAsiPlugins=auto');
  WriteLn(F);
  WriteLn(F, '[FSR]');
  WriteLn(F, 'Fsr4Update=auto');
  WriteLn(F, 'FsrAgilitySDKUpgrade=auto');
  WriteLn(F, 'Fsr4ForceEnableInt8=false');
  CloseFile(F);

  AssignFile(F, FakeIniPath);
  Rewrite(F);
  WriteLn(F, 'force_reflex=0');
  WriteLn(F, 'force_latencyflex=0');
  WriteLn(F, 'latencyflex_mode=0');
  WriteLn(F, 'enable_trace_logs=0');
  CloseFile(F);
end;

function TGoverlayGuiTests.ReadBgmodConf(const ASection, AKey: string): string;
var
  Ini: TIniFile;
begin
  Result := '';
  if not FileExists(BgmodConfPath) then Exit;
  Ini := TIniFile.Create(BgmodConfPath);
  try
    Result := Ini.ReadString(ASection, AKey, '');
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.SaveOpti;
begin
  // No navigation here: switching to the tab reloads config from disk and
  // would clobber the control state just set by the test. Tests navigate
  // once up front, then set controls, then save.
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
end;

procedure TGoverlayGuiTests.TestOptiMenuScaleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.menuscaleTrackBar.Position := 15;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Scale=1.5 persisted', Pos('Scale=1.5', Content) > 0);

  goverlayform.menuscaleTrackBar.Position := 10;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Scale=1.0 persisted', Pos('Scale=1.0', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiShortcutKeySave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.shortcutkeyComboBox.Text := '0x2d';
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('ShortcutKey=0x2d persisted', Pos('ShortcutKey=0x2d', Content) > 0);

  goverlayform.shortcutkeyComboBox.Text := 'auto';
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('ShortcutKey=auto persisted', Pos('ShortcutKey=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiSpoofToggleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True; // spoof only enabled on mesa
  goverlayform.spoofCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=false persisted', Pos('Dxgi=false', Content) > 0);

  goverlayform.spoofCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=auto persisted', Pos('Dxgi=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiOverrideNvapiSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.overrideCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('OverrideNvapiDll=true persisted', Pos('OverrideNvapiDll=true', Content) > 0);

  goverlayform.overrideCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('OverrideNvapiDll=auto persisted', Pos('OverrideNvapiDll=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiPatcherToggleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.optipatcherCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=true persisted', Pos('LoadAsiPlugins=true', Content) > 0);

  goverlayform.optipatcherCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=auto persisted', Pos('LoadAsiPlugins=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiFsrVersionPinned;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  // fsrversionComboBox has no OnChange binding; the pin happens via the
  // channel selector (optversionComboBoxChange -> fsrversionComboBoxChange).
  // TComboBox.ItemIndex does not fire OnChange programmatically, so invoke
  // the bound handler exactly as a user dropdown selection would.
  goverlayform.fsrversionComboBox.ItemIndex := 1;
  AssertTrue('optversionComboBox.OnChange bound', Assigned(goverlayform.optversionComboBox.OnChange));
  goverlayform.optversionComboBox.OnChange(goverlayform.optversionComboBox);
  AssertEquals('fsr version pinned to Latest (0)', 0, goverlayform.fsrversionComboBox.ItemIndex);

  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4Update=true persisted', Pos('Fsr4Update=true', Content) > 0);
  AssertTrue('FsrAgilitySDKUpgrade=true persisted', Pos('FsrAgilitySDKUpgrade=true', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiPreferredUpscalerSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.preferredUpscalerComboBox.ItemIndex := 1; // xess
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dx11Upscaler=xess persisted', Pos('Dx11Upscaler=xess', Content) > 0);
  AssertTrue('Dx12Upscaler=xess persisted', Pos('Dx12Upscaler=xess', Content) > 0);
  AssertTrue('VulkanUpscaler=xess persisted', Pos('VulkanUpscaler=xess', Content) > 0);

  goverlayform.preferredUpscalerComboBox.ItemIndex := 5; // dlss
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dx11Upscaler=dlss persisted', Pos('Dx11Upscaler=dlss', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiForceFsr4Int8Save;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.forceFsr4Int8CheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4ForceEnableInt8=true persisted', Pos('Fsr4ForceEnableInt8=true', Content) > 0);

  goverlayform.forceFsr4Int8CheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4ForceEnableInt8=false persisted', Pos('Fsr4ForceEnableInt8=false', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiFilenameDllSave;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.filenameComboBox.ItemIndex := 1; // version.dll
  SaveOpti;
  AssertEquals('DLL=version.dll persisted', 'version.dll', ReadBgmodConf('Config', 'DLL'));

  goverlayform.filenameComboBox.ItemIndex := 0; // dxgi.dll
  SaveOpti;
  AssertEquals('DLL=dxgi.dll persisted', 'dxgi.dll', ReadBgmodConf('Config', 'DLL'));
end;

procedure TGoverlayGuiTests.TestOptiChannelSave;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.optversionComboBox.ItemIndex := 1; // bleeding edge
  SaveOpti;
  AssertEquals('OPT_CHANNEL=1 persisted', '1', ReadBgmodConf('Config', 'OPT_CHANNEL'));

  goverlayform.optversionComboBox.ItemIndex := 0; // stable
  SaveOpti;
  AssertEquals('OPT_CHANNEL=0 persisted', '0', ReadBgmodConf('Config', 'OPT_CHANNEL'));
end;

procedure TGoverlayGuiTests.TestOptiEmuFp8Save;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.emufp8CheckBox.Checked := True;
  SaveOpti;
  AssertEquals('DXIL_SPIRV_CONFIG workaround persisted',
    'wmma_rdna3_workaround', ReadBgmodConf('Env', 'DXIL_SPIRV_CONFIG'));

  goverlayform.emufp8CheckBox.Checked := False;
  SaveOpti;
  AssertEquals('DXIL_SPIRV_CONFIG removed when unchecked',
    '', ReadBgmodConf('Env', 'DXIL_SPIRV_CONFIG'));
end;

procedure TGoverlayGuiTests.TestOptiForceReflexSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True; // reflex options only enabled on mesa
  goverlayform.forcereflexCheckBox.Checked := True;
  goverlayform.reflexComboBox.ItemIndex := 2;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex=2 persisted', Pos('force_reflex=2', Content) > 0);

  goverlayform.forcereflexCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex key removed when unchecked', Pos('force_reflex', Content) = 0);
end;

procedure TGoverlayGuiTests.TestOptiLatencyFlexSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.forcelatencyflexCheckBox.Checked := True;
  goverlayform.latencyflexComboBox.ItemIndex := 1;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_latencyflex=1 persisted', Pos('force_latencyflex=1', Content) > 0);
  AssertTrue('latencyflex_mode=1 persisted', Pos('latencyflex_mode=1', Content) > 0);

  goverlayform.forcelatencyflexCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_latencyflex=0 persisted', Pos('force_latencyflex=0', Content) > 0);
  AssertTrue('latencyflex_mode=0 persisted', Pos('latencyflex_mode=0', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiTraceLogSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.tracelogCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('enable_trace_logs=1 persisted', Pos('enable_trace_logs=1', Content) > 0);

  goverlayform.tracelogCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('enable_trace_logs=0 persisted', Pos('enable_trace_logs=0', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiUpdateButtonsGuarded;
begin
  // Both buttons are wired, but in GOVERLAY_TEST mode their handlers exit
  // before any network activity - clicking must be a harmless no-op.
  NavigateOptiScalerTab;
  AssertTrue('checkupdBitbtn bound', Assigned(goverlayform.checkupdBitbtn.OnClick));
  goverlayform.checkupdBitbtn.OnClick(goverlayform.checkupdBitbtn);
  AssertTrue('updatebitBtn bound', Assigned(goverlayform.updatebitBtn.OnClick));
  goverlayform.updatebitBtn.OnClick(goverlayform.updatebitBtn);
  AssertFalse('no OptiScaler download appeared',
    FileExists(IsolatedHome + '/.local/share/goverlay/gameconfig/global/OptiScaler.dll'));
end;

procedure TGoverlayGuiTests.TestOptiShortcutCaptureBound;
begin
  // Capture button opens a modal key-capture form; verify wiring only.
  NavigateOptiScalerTab;
  AssertTrue('shortcut capture button exists', Assigned(goverlayform.FOsShortcutCaptureBtn));
  AssertTrue('shortcut capture button bound', Assigned(goverlayform.FOsShortcutCaptureBtn.OnClick));
end;

initialization
  RegisterTest(TGoverlayGuiTests);

end.
