unit gui_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Buttons, fpcunit, testregistry;

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
    procedure NavigateMangoHud;
    function MangoConfPath: string;
    procedure SaveMango;
    procedure CycleBtnUntil(ABtn: TBitBtn; const ACaption: string; AMaxClicks: Integer);
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
    // MangoHud tabs - full control coverage
    procedure TestMangoNavigateAndPreset;
    procedure TestMangoVisualTab;
    procedure TestMangoMetricsGpuTab;
    procedure TestMangoMetricsCpuTab;
    procedure TestMangoMetricsMemIoTab;
    procedure TestMangoMetricsOtherTab;
    procedure TestMangoPerformanceTab;
    procedure TestMangoExtrasTab;
    procedure TestMangoGlobalSideEffects;
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

// ────────────────────────── MangoHud tabs - full coverage ──────────────────────────

procedure TGoverlayGuiTests.NavigateMangoHud;
begin
  AssertTrue('mangohudLabel.OnClick is bound', Assigned(goverlayform.mangohudLabel.OnClick));
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
end;

function TGoverlayGuiTests.MangoConfPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/MangoHud.conf';
end;

procedure TGoverlayGuiTests.SaveMango;
begin
  // saveBitBtn routes by active page; sub-tab switches (visual/metrics/...)
  // only reflow, they never reload config, so no re-navigation is needed.
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
end;

procedure TGoverlayGuiTests.CycleBtnUntil(ABtn: TBitBtn; const ACaption: string; AMaxClicks: Integer);
var
  i: Integer;
begin
  for i := 1 to AMaxClicks do
  begin
    if ABtn.Caption = ACaption then Exit;
    AssertTrue('button bound: ' + ABtn.Name, Assigned(ABtn.OnClick));
    ABtn.OnClick(ABtn);
  end;
  AssertTrue(Format('button %s reached caption %s (now %s)',
    [ABtn.Name, ACaption, ABtn.Caption]), ABtn.Caption = ACaption);
end;

procedure TGoverlayGuiTests.TestMangoNavigateAndPreset;
begin
  NavigateMangoHud;
  AssertTrue('preset tab active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.presetTabSheet);
  AssertTrue('visual tab visible', goverlayform.visualTabSheet.TabVisible);
  AssertTrue('performance tab visible', goverlayform.performanceTabSheet.TabVisible);
  AssertTrue('metrics tab visible', goverlayform.metricsTabSheet.TabVisible);
  AssertTrue('extras tab visible', goverlayform.extrasTabSheet.TabVisible);

  // Full preset enables a broad set of metrics controls
  AssertTrue('fullBitBtn bound', Assigned(goverlayform.fullBitBtn.OnClick));
  goverlayform.fullBitBtn.OnClick(goverlayform.fullBitBtn);
  AssertTrue('full preset checks fps', goverlayform.fpsCheckBox.Checked);
  AssertTrue('full preset checks gpu load', goverlayform.gpuavgloadCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestMangoVisualTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.visualTabSheet;

  goverlayform.hudtitleEdit.Text := 'TestHUD';
  goverlayform.horizontalRadioButton.Checked := True;
  goverlayform.transpTrackBar.Position := 6;
  goverlayform.roundRadioButton.Checked := True;
  goverlayform.hudbackgroundColorButton.ButtonColor := $112233;
  goverlayform.fontsizeTrackBar.Position := 25;
  goverlayform.fontColorButton.ButtonColor := $00FF0000; // R=0,G=0,B=$FF
  goverlayform.toprightRadioButton.Checked := True;
  goverlayform.offsetxSpinEdit.Value := 12;
  goverlayform.offsetySpinEdit.Value := 7;
  goverlayform.hudonoffComboBox.Text := 'Shift_R+F12';
  goverlayform.hidehudCheckBox.Checked := True;
  goverlayform.hudcompactCheckBox.Checked := True;
  goverlayform.horizontalstrechCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('custom_text_center', Pos('custom_text_center=TestHUD', C) > 0);
  AssertTrue('horizontal', Pos('horizontal', C) > 0);
  AssertTrue('background_alpha=0.6', Pos('background_alpha=0.6', C) > 0);
  AssertTrue('round_corners=10', Pos('round_corners=10', C) > 0);
  AssertTrue('background_color hex', Pos('background_color=332211', C) > 0);
  AssertTrue('font_size=25', Pos('font_size=25', C) > 0);
  AssertTrue('text_color hex', Pos('text_color=0000FF', C) > 0);
  AssertTrue('position=top-right', Pos('position=top-right', C) > 0);
  AssertTrue('offset_x=12', Pos('offset_x=12', C) > 0);
  AssertTrue('offset_y=7', Pos('offset_y=7', C) > 0);
  AssertTrue('toggle_hud key', Pos('toggle_hud=Shift_R+F12', C) > 0);
  AssertTrue('no_display', Pos('no_display', C) > 0);
  AssertTrue('hud_compact', Pos('hud_compact', C) > 0);
  AssertTrue('horizontal_stretch=0', Pos('horizontal_stretch=0', C) > 0);
  AssertTrue('table_columns written', Pos('table_columns=', C) > 0);

  // Reverse direction
  goverlayform.hudtitleEdit.Text := '';
  goverlayform.verticalRadioButton.Checked := True;
  goverlayform.squareRadioButton.Checked := True; // radio groups uncheck via the sibling
  goverlayform.offsetxSpinEdit.Value := 0;
  goverlayform.hidehudCheckBox.Checked := False;
  goverlayform.bottomleftRadioButton.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('custom_text_center gone', Pos('custom_text_center=', C) = 0);
  AssertTrue('horizontal gone', Pos(#10'horizontal'#10, C) = 0);
  AssertTrue('round_corners=0', Pos('round_corners=0', C) > 0);
  AssertTrue('offset_x gone', Pos('offset_x=', C) = 0);
  AssertTrue('no_display gone', Pos('no_display', C) = 0);
  AssertTrue('position=bottom-left', Pos('position=bottom-left', C) > 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsGpuTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.gpunameEdit.Text := 'MyGPU';
  goverlayform.gpuavgloadCheckBox.Checked := True;
  goverlayform.gpuColorButton.ButtonColor := $00112233;
  goverlayform.gpuloadcolorCheckBox.Checked := True;
  goverlayform.vramusageCheckBox.Checked := True;
  goverlayform.vramColorButton.ButtonColor := $00ABCDEF;
  goverlayform.gpufreqCheckBox.Checked := True;
  goverlayform.gpumemfreqCheckBox.Checked := True;
  goverlayform.gputempCheckBox.Checked := True;
  goverlayform.gpumemtempCheckBox.Checked := True;
  goverlayform.gpujunctempCheckBox.Checked := True;
  goverlayform.gpufanCheckBox.Checked := True;
  goverlayform.gpupowerCheckBox.Checked := True;
  goverlayform.gpupowerlimitCheckBox.Checked := True;
  goverlayform.gpuefficiencyCheckBox.Checked := True;
  goverlayform.gpuvoltageCheckBox.Checked := True;
  goverlayform.gputhrottlingCheckBox.Checked := True;
  goverlayform.gputhrottlinggraphCheckBox.Checked := True;
  goverlayform.gpumodelCheckBox.Checked := True;
  goverlayform.vulkandriverCheckBox.Checked := True;
  CycleBtnUntil(goverlayform.gpuframesjouleBitBtn, 'Joules / Frame', 3);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('gpu_text', Pos('gpu_text=MyGPU', C) > 0);
  AssertTrue('gpu_stats', Pos('gpu_stats', C) > 0);
  AssertTrue('gpu_color hex', Pos('gpu_color=332211', C) > 0);
  AssertTrue('gpu_load_change', Pos('gpu_load_change', C) > 0);
  AssertTrue('gpu_load_color', Pos('gpu_load_color=', C) > 0);
  AssertTrue('vram', Pos('vram', C) > 0);
  AssertTrue('vram_color hex', Pos('vram_color=EFCDAB', C) > 0);
  AssertTrue('gpu_core_clock', Pos('gpu_core_clock', C) > 0);
  AssertTrue('gpu_mem_clock', Pos('gpu_mem_clock', C) > 0);
  AssertTrue('gpu_temp', Pos('gpu_temp', C) > 0);
  AssertTrue('gpu_mem_temp', Pos('gpu_mem_temp', C) > 0);
  AssertTrue('gpu_junction_temp', Pos('gpu_junction_temp', C) > 0);
  AssertTrue('gpu_fan', Pos('gpu_fan', C) > 0);
  AssertTrue('gpu_power', Pos('gpu_power', C) > 0);
  AssertTrue('gpu_power_limit', Pos('gpu_power_limit', C) > 0);
  AssertTrue('gpu_efficiency', Pos('gpu_efficiency', C) > 0);
  AssertTrue('gpu_voltage', Pos('gpu_voltage', C) > 0);
  AssertTrue('throttling_status', Pos('throttling_status', C) > 0);
  AssertTrue('throttling_status_graph', Pos('throttling_status_graph', C) > 0);
  AssertTrue('gpu_name', Pos('gpu_name', C) > 0);
  AssertTrue('vulkan_driver', Pos('vulkan_driver', C) > 0);
  AssertTrue('flip_efficiency (Joules/Frame caption)', Pos('flip_efficiency', C) > 0);

  // Reverse
  goverlayform.gpuavgloadCheckBox.Checked := False;
  goverlayform.vramusageCheckBox.Checked := False;
  goverlayform.gputempCheckBox.Checked := False;
  CycleBtnUntil(goverlayform.gpuframesjouleBitBtn, 'Frames / Joule', 3);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('gpu_stats gone', Pos('gpu_stats', C) = 0);
  AssertTrue('vram line gone', Pos(#10'vram'#10, C) = 0);
  AssertTrue('vram_color gone', Pos('vram_color', C) = 0);
  AssertTrue('gpu_temp gone', Pos('gpu_temp', C) = 0);
  AssertTrue('flip_efficiency gone', Pos('flip_efficiency', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsCpuTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.cpunameEdit.Text := 'MyCPU';
  goverlayform.cpuavgloadCheckBox.Checked := True;
  goverlayform.cpuColorButton.ButtonColor := $000000FF;
  goverlayform.cpuloadcoreCheckBox.Checked := True;
  CycleBtnUntil(goverlayform.coreloadtypeBitBtn, 'Graph', 4);
  goverlayform.cpuloadcolorCheckBox.Checked := True;
  goverlayform.cpufreqCheckBox.Checked := True;
  goverlayform.cputempCheckBox.Checked := True;
  goverlayform.cpupowerCheckBox.Checked := True;
  goverlayform.cpuefficiencyCheckBox.Checked := True;
  goverlayform.cpucoretypeCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('cpu_text', Pos('cpu_text=MyCPU', C) > 0);
  AssertTrue('cpu_stats', Pos('cpu_stats', C) > 0);
  AssertTrue('cpu_color hex', Pos('cpu_color=FF0000', C) > 0);
  AssertTrue('core_load', Pos('core_load', C) > 0);
  AssertTrue('core_bars (Graph caption)', Pos('core_bars', C) > 0);
  AssertTrue('cpu_load_change', Pos('cpu_load_change', C) > 0);
  AssertTrue('cpu_load_color', Pos('cpu_load_color=', C) > 0);
  AssertTrue('cpu_mhz', Pos('cpu_mhz', C) > 0);
  AssertTrue('cpu_temp', Pos('cpu_temp', C) > 0);
  AssertTrue('cpu_power', Pos('cpu_power', C) > 0);
  AssertTrue('cpu_efficiency', Pos('cpu_efficiency', C) > 0);
  AssertTrue('core_type', Pos('core_type', C) > 0);

  // Reverse
  goverlayform.cpuloadcoreCheckBox.Checked := False;
  goverlayform.cpufreqCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('core_load gone', Pos('core_load', C) = 0);
  AssertTrue('cpu_mhz gone', Pos('cpu_mhz', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsMemIoTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.diskioCheckBox.Checked := True;
  goverlayform.iordrwColorButton.ButtonColor := $0010FF10;
  goverlayform.swapusageCheckBox.Checked := True;
  goverlayform.ramusageCheckBox.Checked := True;
  goverlayform.ramColorButton.ButtonColor := $00FF10FF;
  goverlayform.ramtempCheckBox.Checked := True;
  goverlayform.procmemCheckBox.Checked := True;
  goverlayform.procvramCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('io_read', Pos('io_read', C) > 0);
  AssertTrue('io_write', Pos('io_write', C) > 0);
  AssertTrue('io_color hex', Pos('io_color=10FF10', C) > 0);
  AssertTrue('swap', Pos('swap', C) > 0);
  AssertTrue('ram', Pos('ram', C) > 0);
  AssertTrue('ram_color hex', Pos('ram_color=FF10FF', C) > 0);
  AssertTrue('ram_temp', Pos('ram_temp', C) > 0);
  AssertTrue('procmem', Pos('procmem', C) > 0);
  AssertTrue('proc_vram', Pos('proc_vram', C) > 0);

  // Reverse
  goverlayform.diskioCheckBox.Checked := False;
  goverlayform.ramusageCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('io_read gone', Pos('io_read', C) = 0);
  AssertTrue('ram line gone', Pos(#10'ram'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsOtherTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.batteryCheckBox.Checked := True;
  goverlayform.batteryColorButton.ButtonColor := $00333333;
  goverlayform.batterywattCheckBox.Checked := True;
  goverlayform.batterytimeCheckBox.Checked := True;
  goverlayform.deviceCheckBox.Checked := True;
  goverlayform.fpsCheckBox.Checked := True;
  goverlayform.fpsavgCheckBox.Checked := True;
  CycleBtnUntil(goverlayform.fpsavgBitBtn, '1% low', 4);
  goverlayform.frametimegraphCheckBox.Checked := True;
  goverlayform.frametimegraphColorButton.ButtonColor := $00444444;
  CycleBtnUntil(goverlayform.frametimetypeBitBtn, 'Histogram', 4);
  goverlayform.framecountCheckBox.Checked := True;
  goverlayform.engineversionCheckBox.Checked := True;
  goverlayform.engineColorButton.ButtonColor := $00555555;
  goverlayform.engineshortCheckBox.Checked := True;
  goverlayform.archCheckBox.Checked := True;
  goverlayform.wineCheckBox.Checked := True;
  goverlayform.wineColorButton.ButtonColor := $00666666;
  goverlayform.winesyncCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('battery', Pos('battery', C) > 0);
  AssertTrue('battery_color hex', Pos('battery_color=333333', C) > 0);
  AssertTrue('battery_watt', Pos('battery_watt', C) > 0);
  AssertTrue('battery_time', Pos('battery_time', C) > 0);
  AssertTrue('device_battery=gamepad', Pos('device_battery=gamepad', C) > 0);
  AssertTrue('device_battery_icon', Pos('device_battery_icon', C) > 0);
  AssertTrue('fps', Pos('fps', C) > 0);
  AssertTrue('fps_metrics 1% low', Pos('fps_metrics=avg,0.01', C) > 0);
  AssertTrue('frame_timing', Pos('frame_timing', C) > 0);
  AssertTrue('frametime_color hex', Pos('frametime_color=444444', C) > 0);
  AssertTrue('histogram', Pos('histogram', C) > 0);
  AssertTrue('frame_count', Pos('frame_count', C) > 0);
  AssertTrue('engine_version', Pos('engine_version', C) > 0);
  AssertTrue('engine_color hex (always written)', Pos('engine_color=555555', C) > 0);
  AssertTrue('engine_short_names', Pos('engine_short_names', C) > 0);
  AssertTrue('arch', Pos('arch', C) > 0);
  AssertTrue('wine', Pos('wine', C) > 0);
  AssertTrue('wine_color hex', Pos('wine_color=666666', C) > 0);
  AssertTrue('winesync', Pos('winesync', C) > 0);

  // Reverse: 0.1% low variant writes the other fps_metrics form
  CycleBtnUntil(goverlayform.fpsavgBitBtn, '0.1% low', 4);
  goverlayform.fpsCheckBox.Checked := False;
  goverlayform.wineCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('fps_metrics 0.1% low variant', Pos('fps_metrics=avg,0.001', C) > 0);
  AssertTrue('fps line gone', Pos(#10'fps'#10, C) = 0);
  AssertTrue('wine line gone', Pos(#10'wine'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoPerformanceTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.performanceTabSheet;

  goverlayform.showfpslimCheckBox.Checked := True;
  goverlayform.fpslimmetComboBox.ItemIndex := 1; // early
  goverlayform.fpslimtoggleComboBox.Text := 'Home';
  goverlayform.FFpsLimitEdit.Text := '120';
  goverlayform.resolutionCheckBox.Checked := True;
  goverlayform.refreshrateCheckBox.Checked := True;
  goverlayform.fcatCheckBox.Checked := True;
  goverlayform.fexstatsCheckBox.Checked := True;
  goverlayform.fsrCheckBox.Checked := True;
  goverlayform.hdrCheckBox.Checked := True;
  goverlayform.vpsCheckBox.Checked := True;
  goverlayform.fahrenheitCheckBox.Checked := True;
  goverlayform.gamemodestatusCheckBox.Checked := True;
  goverlayform.vkbasaltstatusCheckBox.Checked := True;
  goverlayform.vsyncComboBox.ItemIndex := 2;
  goverlayform.glvsyncComboBox.ItemIndex := 3; // literal 'n'
  goverlayform.filterRadioGroup.ItemIndex := 1; // bicubic
  goverlayform.afTrackBar.Position := 4;
  goverlayform.mipmapTrackBar.Position := 2;
  goverlayform.fpscolorCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('show_fps_limit', Pos('show_fps_limit', C) > 0);
  AssertTrue('fps_limit_method=early', Pos('fps_limit_method=early', C) > 0);
  AssertTrue('toggle_fps_limit=Home', Pos('toggle_fps_limit=Home', C) > 0);
  AssertTrue('fps_limit=120', Pos('fps_limit=120', C) > 0);
  AssertTrue('resolution', Pos('resolution', C) > 0);
  AssertTrue('refresh_rate', Pos('refresh_rate', C) > 0);
  AssertTrue('fcat', Pos('fcat', C) > 0);
  AssertTrue('fex_stats', Pos('fex_stats', C) > 0);
  AssertTrue('fsr', Pos('fsr', C) > 0);
  AssertTrue('hdr', Pos('hdr', C) > 0);
  AssertTrue('present_mode', Pos('present_mode', C) > 0);
  AssertTrue('temp_fahrenheit', Pos('temp_fahrenheit', C) > 0);
  AssertTrue('gamemode', Pos('gamemode', C) > 0);
  AssertTrue('vkbasalt', Pos('vkbasalt', C) > 0);
  AssertTrue('vsync=2', Pos('vsync=2', C) > 0);
  AssertTrue('gl_vsync=n literal', Pos('gl_vsync=n', C) > 0);
  AssertTrue('bicubic', Pos('bicubic', C) > 0);
  AssertTrue('af=4', Pos('af=4', C) > 0);
  AssertTrue('picmip=2', Pos('picmip=2', C) > 0);
  AssertTrue('fps_color_change', Pos('fps_color_change', C) > 0);
  // fps limit edit drives the two thresholds: 120 -> 60,120
  AssertTrue('fps_value=60,120', Pos('fps_value=60,120', C) > 0);

  // Reverse
  goverlayform.fpslimmetComboBox.ItemIndex := 0; // late
  goverlayform.FFpsLimitEdit.Text := '';
  goverlayform.filterRadioGroup.ItemIndex := 3; // retro
  goverlayform.afTrackBar.Position := 0;
  goverlayform.fsrCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('fps_limit_method=late', Pos('fps_limit_method=late', C) > 0);
  AssertTrue('fps_limit=0 fallback', Pos('fps_limit=0', C) > 0);
  AssertTrue('retro', Pos('retro', C) > 0);
  AssertTrue('bicubic gone', Pos('bicubic', C) = 0);
  AssertTrue('af gone at 0', Pos('af=', C) = 0);
  AssertTrue('fsr line gone', Pos(#10'fsr'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoExtrasTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.extrasTabSheet;

  goverlayform.distroinfoCheckBox.Checked := True;
  goverlayform.displayserverCheckBox.Checked := True;
  goverlayform.timeCheckBox.Checked := True;
  goverlayform.hudversionCheckBox.Checked := True;
  goverlayform.mediaCheckBox.Checked := True;
  goverlayform.mediaColorButton.ButtonColor := $00777777;
  goverlayform.networkCheckBox.Checked := True;
  if goverlayform.networkComboBox.Items.Count > 0 then
    goverlayform.networkComboBox.ItemIndex := 0;
  goverlayform.logfolderEdit.Text := '/tmp/testlogs';
  goverlayform.durationTrackBar.Position := 10;
  goverlayform.delayTrackBar.Position := 5;
  goverlayform.intervalTrackBar.Position := 100;
  goverlayform.logtoggleComboBox.Text := 'Shift_L+F10';
  goverlayform.versioningCheckBox.Checked := True;
  goverlayform.autouploadCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('distro custom_text', Pos('custom_text=-', C) > 0);
  AssertTrue('distro exec uname', Pos('exec=uname -r', C) > 0);
  AssertTrue('display_server', Pos('display_server', C) > 0);
  AssertTrue('time', Pos('time', C) > 0);
  AssertTrue('time_no_label', Pos('time_no_label', C) > 0);
  AssertTrue('version# literal', Pos('version#', C) > 0);
  AssertTrue('media_player', Pos('media_player', C) > 0);
  AssertTrue('media_player_color hex', Pos('media_player_color=777777', C) > 0);
  if goverlayform.networkComboBox.Items.Count > 0 then
    AssertTrue('network=<iface>', Pos('network=', C) > 0);
  AssertTrue('output_folder', Pos('output_folder=/tmp/testlogs', C) > 0);
  AssertTrue('log_duration=10', Pos('log_duration=10', C) > 0);
  AssertTrue('autostart_log=5', Pos('autostart_log=5', C) > 0);
  AssertTrue('log_interval=100', Pos('log_interval=100', C) > 0);
  AssertTrue('toggle_logging key', Pos('toggle_logging=Shift_L+F10', C) > 0);
  AssertTrue('log_versioning', Pos('log_versioning', C) > 0);
  AssertTrue('upload_logs', Pos('upload_logs', C) > 0);

  // Reverse
  goverlayform.timeCheckBox.Checked := False;
  goverlayform.mediaCheckBox.Checked := False;
  goverlayform.durationTrackBar.Position := 0;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('time line gone', Pos(#10'time'#10, C) = 0);
  AssertTrue('media_player gone', Pos('media_player', C) = 0);
  AssertTrue('log_duration gone at 0', Pos('log_duration=', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoGlobalSideEffects;
var
  C: string;
begin
  NavigateMangoHud;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  // Blacklist line auto-created with defaults when missing
  AssertTrue('blacklist line present', Pos('blacklist=', C) > 0);
  AssertTrue('blacklist contains zenity default', Pos('zenity', C) > 0);
  // bgmod.conf side-effects (same writer)
  AssertEquals('GOVERLAY_MANGOHUD flag', '1', ReadBgmodConf('Config', 'GOVERLAY_MANGOHUD'));
  AssertTrue('MANGOHUD_CONFIGFILE env points at conf',
    Pos('MangoHud.conf', ReadBgmodConf('Env', 'MANGOHUD_CONFIGFILE')) > 0);
end;

initialization
  RegisterTest(TGoverlayGuiTests);

end.
