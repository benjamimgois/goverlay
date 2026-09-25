unit reshade_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons,
  ComCtrls, Math, themeunit, constants, hintsunit, apputils;

type
  TReshadePackInfo = record
    ID: string;
    Name: string;
    RepoUrl: string;
    CheckFile: string;
    Description: string;
  end;

  TReshadeMethod = (rmNone, rmReshade, rmVkBasalt);

  { TReshadeTabHelper }

  TReshadeTabHelper = class
  private
    FForm: TForm;
    FScrollBox: TScrollBox;
    FBgPanel: TPanel;

    // Card 0: Method
    FMethodCard: TPanel;
    FMethodTitleLbl: TLabel;
    FNoneRadio: TRadioButton;
    FNoneLogoImg: TImage;
    FReshadeRadio: TRadioButton;
    FReshadeLogoImg: TImage;
    FVkBasaltRadio: TRadioButton;
    FVkBasaltLogoImg: TImage;

    FNonePngLogo: TPortableNetworkGraphic;
    FNonePngDimmed: TPortableNetworkGraphic;
    FReshadePngLogo: TPortableNetworkGraphic;
    FReshadePngDimmed: TPortableNetworkGraphic;
    FVkBasaltPngLogo: TPortableNetworkGraphic;
    FVkBasaltPngDimmed: TPortableNetworkGraphic;

    FSelectedMethod: TReshadeMethod;
    FNoneNoticeLbl: TLabel;

    // Cards
    FStatusCard: TPanel;
    FShadersCard: TPanel;
    FConfigCard: TPanel;

    // Card 1: Config
    FConfigTitleLbl: TLabel;
    FToggleTitleLbl: TLabel;
    FToggleBtn: TBitBtn;
    FHotkeyComboBox: TComboBox;
    FHotkeyValue: string;
    FProxyTitleLbl: TLabel;
    FProxyComboBox: TComboBox;
    FLoading: Boolean;

    // Card 2: Shader Packages
    FShadersTitleLbl: TLabel;
    FOpenShadersBtn: TBitBtn;
    FPackPanels: array of TPanel;
    FPackNameLbls: array of TLabel;
    FPackDescLbls: array of TLabel;
    FPackStatusLbls: array of TLabel;
    FPackActionBtns: array of TBitBtn;

    // Card 3: Software Status
    FStatusTitleLbl: TLabel;
    FVersionComboBox: TComboBox;
    FStatDot: TShape;
    FStatNameLbl: TLabel;
    FStatVerLbl: TLabel;
    FVkStatDot: TShape;
    FVkStatNameLbl: TLabel;
    FVkStatVerLbl: TLabel;
    FUpdateBtn: TBitBtn;

    function IsLoading: Boolean;
    procedure OnPackActionClick(Sender: TObject);
    procedure OnUpdateBtnClick(Sender: TObject);
    procedure OnOpenShadersBtnClick(Sender: TObject);
    procedure OnHotkeyChange(Sender: TObject);
    procedure OnProxyChange(Sender: TObject);
    procedure OnMethodNoneClick(Sender: TObject);
    procedure OnMethodReshadeClick(Sender: TObject);
    procedure OnMethodVkBasaltClick(Sender: TObject);
    procedure UpdateMethodOpacity;
    procedure ApplyMethodSelection(AMethod: TReshadeMethod; ASave: Boolean = True);
    function MkCard(ATop, AHeight: Integer): TPanel;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;

    procedure BuildReShadeTab;
    procedure ReshadeScrollBoxResize(Sender: TObject);
    procedure ReflowReShadeTab(AContentW: Integer);
    procedure RefreshStatus;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure BeginLoad;
    procedure EndLoad;
    procedure ApplyCapturedKey(AKey: Word; AShift: TShiftState);
    procedure SyncHotkeyUI;
    procedure SelectMethod(AMethod: TReshadeMethod);
    procedure UpdateVkBasaltBanner(AVkInstalled: Boolean);

    property BgPanel: TPanel read FBgPanel;
    property ScrollBox: TScrollBox read FScrollBox;
    property MethodCard: TPanel read FMethodCard;
    property NoneRadio: TRadioButton read FNoneRadio;
    property ReshadeRadio: TRadioButton read FReshadeRadio;
    property VkBasaltRadio: TRadioButton read FVkBasaltRadio;
    property NoneLogoImg: TImage read FNoneLogoImg;
    property ReshadeLogoImg: TImage read FReshadeLogoImg;
    property VkBasaltLogoImg: TImage read FVkBasaltLogoImg;
    property SelectedMethod: TReshadeMethod read FSelectedMethod;
    property NoneNoticeLbl: TLabel read FNoneNoticeLbl;

    property StatusCard: TPanel read FStatusCard;
    property ShadersCard: TPanel read FShadersCard;
    property ConfigCard: TPanel read FConfigCard;
    property OptionsCard: TPanel read FConfigCard;
    property VersionComboBox: TComboBox read FVersionComboBox;
    property UpdateBtn: TBitBtn read FUpdateBtn;
    property OpenShadersBtn: TBitBtn read FOpenShadersBtn;
    property ProxyComboBox: TComboBox read FProxyComboBox;
    property HotkeyComboBox: TComboBox read FHotkeyComboBox;
    property ToggleBtn: TBitBtn read FToggleBtn;
    property StatDot: TShape read FStatDot;
    property StatNameLbl: TLabel read FStatNameLbl;
    property StatVerLbl: TLabel read FStatVerLbl;
    property VkStatDot: TShape read FVkStatDot;
    property VkStatNameLbl: TLabel read FVkStatNameLbl;
    property VkStatVerLbl: TLabel read FVkStatVerLbl;
  end;

const
  RESHADE_PACK_COUNT = 5;
  RESHADE_PACKS: array[0..RESHADE_PACK_COUNT - 1] of TReshadePackInfo = (
    (
      ID: 'standard';
      Name: 'Standard Effects (crosire)';
      RepoUrl: 'https://github.com/crosire/reshade-shaders/archive/refs/heads/slim.tar.gz';
      CheckFile: 'DisplayDepth.fx';
      Description: 'Core shaders, SMAA, FXAA, Bloom, LUT, Daltonize, Deband, and display calibration tools.'
    ),
    (
      ID: 'sweetfx';
      Name: 'SweetFX (CeeJayDK)';
      RepoUrl: 'https://github.com/CeeJayDK/SweetFX/archive/refs/heads/master.tar.gz';
      CheckFile: 'SweetFX/ASCII.fx';
      Description: 'Classic post-processing suite: CAS, CRT, Bloom, HDR, Curves, ColorMatrix, and Vibrance.'
    ),
    (
      ID: 'quint';
      Name: 'qUINT (Marty McFly)';
      RepoUrl: 'https://github.com/martymcmodding/qUINT/archive/refs/heads/master.tar.gz';
      CheckFile: 'qUINT_bloom.fx';
      Description: 'Next-gen screen-space shaders: MXAO, SSR, Depth of Field, Lightroom color grading.'
    ),
    (
      ID: 'astrayfx';
      Name: 'AstrayFX (BlueSkyDefender)';
      RepoUrl: 'https://github.com/BlueSkyDefender/AstrayFX/archive/refs/heads/master.tar.gz';
      CheckFile: 'Depth_Cues.fx';
      Description: 'Cinematic depth effects, volumetric lighting, and advanced perspective controls.'
    ),
    (
      ID: 'prod80';
      Name: 'Prod80 Color Grading';
      RepoUrl: 'https://github.com/prod80/prod80-ReShade-Repository/archive/refs/heads/master.tar.gz';
      CheckFile: 'PD80_01B_RT_Correct_Color.fx';
      Description: 'Professional studio photography curves, saturation, film contrast, and balance filters.'
    )
  );

implementation

uses
  overlayunit, optiscaler_tab, optiscaler_update, bgmod_resources, IniFiles, FileUtil;

const
  MARGIN   = 4;
  CARD_GAP = 6;
  CARD_P   = 14;

function ReShadeKeyToDisplayName(const AKeyVal: string): string;
var
  Parts: TStringArray;
  VkCode, CtrlVal, ShiftVal, AltVal: Integer;
  Prefix, KeyName: string;
begin
  if Trim(AKeyVal) = '' then
  begin
    Result := 'Home';
    Exit;
  end;

  Parts := AKeyVal.Split([',']);
  if Length(Parts) >= 1 then
  begin
    VkCode := StrToIntDef(Trim(Parts[0]), 36);
    CtrlVal := 0;
    ShiftVal := 0;
    AltVal := 0;
    if Length(Parts) >= 2 then CtrlVal := StrToIntDef(Trim(Parts[1]), 0);
    if Length(Parts) >= 3 then ShiftVal := StrToIntDef(Trim(Parts[2]), 0);
    if Length(Parts) >= 4 then AltVal := StrToIntDef(Trim(Parts[3]), 0);

    Prefix := '';
    if CtrlVal = 1 then Prefix := Prefix + 'Ctrl+';
    if AltVal = 1 then Prefix := Prefix + 'Alt+';
    if ShiftVal = 1 then Prefix := Prefix + 'Shift+';

    KeyName := OsHexToKeyStr(IntToStr(VkCode));
    if KeyName = '' then
      KeyName := 'VK ' + IntToStr(VkCode);

    Result := Prefix + KeyName;
  end
  else
    Result := 'Home';
end;

function FormatBytes(ABytes: Int64): string;
begin
  if ABytes >= 1048576 then
    Result := Format('%.1f MB', [ABytes / 1048576.0])
  else if ABytes >= 1024 then
    Result := Format('%.0f KB', [ABytes / 1024.0])
  else
    Result := IntToStr(ABytes) + ' B';
end;

type
  TReshadeAsyncInstallThread = class(TThread)
  private
    FPackIdx: Integer;
    FIsFullUpdate: Boolean;
    FHelper: TReshadeTabHelper;
    procedure SyncDone;
  protected
    procedure Execute; override;
  public
    constructor Create(AHelper: TReshadeTabHelper; APackIdx: Integer; AFullUpdate: Boolean = False);
  end;

constructor TReshadeAsyncInstallThread.Create(AHelper: TReshadeTabHelper; APackIdx: Integer; AFullUpdate: Boolean);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FHelper := AHelper;
  FPackIdx := APackIdx;
  FIsFullUpdate := AFullUpdate;
  Start;
end;

procedure TReshadeAsyncInstallThread.SyncDone;
begin
  if Assigned(FHelper) then
  begin
    FHelper.RefreshStatus;
    if Assigned(FHelper.FUpdateBtn) then
    begin
      FHelper.FUpdateBtn.Enabled := True;
      FHelper.FUpdateBtn.Caption := 'Check updates';
    end;
  end;
end;

procedure TReshadeAsyncInstallThread.Execute;
begin
  try
    if FIsFullUpdate then
    begin
      CheckAndInstallReShade(True, nil, nil);
    end
    else if (FPackIdx >= 0) and (FPackIdx < RESHADE_PACK_COUNT) then
    begin
      InstallReShadeShaderPack(RESHADE_PACKS[FPackIdx].ID, RESHADE_PACKS[FPackIdx].RepoUrl, nil);
    end;
  except
    on E: Exception do
      WriteLn('[RESHADE] Async install error: ', E.Message);
  end;
  Synchronize(@SyncDone);
end;

constructor TReshadeTabHelper.Create(AForm: TForm);
begin
  FForm := AForm;
  FSelectedMethod := rmReshade;
end;

destructor TReshadeTabHelper.Destroy;
begin
  FreeAndNil(FNonePngLogo);
  FreeAndNil(FNonePngDimmed);
  FreeAndNil(FReshadePngLogo);
  FreeAndNil(FReshadePngDimmed);
  FreeAndNil(FVkBasaltPngLogo);
  FreeAndNil(FVkBasaltPngDimmed);
  inherited Destroy;
end;

function TReshadeTabHelper.IsLoading: Boolean;
begin
  Result := FLoading;
end;

procedure TReshadeTabHelper.BeginLoad;
begin
  FLoading := True;
end;

procedure TReshadeTabHelper.EndLoad;
begin
  FLoading := False;
end;

procedure TReshadeTabHelper.ApplyCapturedKey(AKey: Word; AShift: TShiftState);
var
  CtrlVal, ShiftVal, AltVal: Integer;
begin
  CtrlVal := IfThen(ssCtrl in AShift, 1, 0);
  ShiftVal := IfThen(ssShift in AShift, 1, 0);
  AltVal := IfThen(ssAlt in AShift, 1, 0);
  FHotkeyValue := Format('%d,%d,%d,%d', [AKey, CtrlVal, ShiftVal, AltVal]);
  SyncHotkeyUI;
  if not FLoading then
    SaveConfig;
end;

procedure TReshadeTabHelper.SyncHotkeyUI;
begin
  if Assigned(FToggleBtn) then
    FToggleBtn.Caption := '⌨ ' + ReShadeKeyToDisplayName(FHotkeyValue);

  if Assigned(FHotkeyComboBox) then
  begin
    if (Pos('36,0,0,0', FHotkeyValue) = 1) or (FHotkeyValue = '36') then FHotkeyComboBox.ItemIndex := 0
    else if (Pos('113,0,1,0', FHotkeyValue) = 1) or (Pos('113', FHotkeyValue) = 1) then FHotkeyComboBox.ItemIndex := 1
    else if (Pos('35,0,0,0', FHotkeyValue) = 1) or (FHotkeyValue = '35') then FHotkeyComboBox.ItemIndex := 2
    else if (Pos('45,0,0,0', FHotkeyValue) = 1) or (FHotkeyValue = '45') then FHotkeyComboBox.ItemIndex := 3
    else if (Pos('33,0,0,0', FHotkeyValue) = 1) or (FHotkeyValue = '33') then FHotkeyComboBox.ItemIndex := 4
    else if (Pos('122,0,0,0', FHotkeyValue) = 1) or (FHotkeyValue = '122') then FHotkeyComboBox.ItemIndex := 5
    else FHotkeyComboBox.ItemIndex := -1;
  end;
end;

function TReshadeTabHelper.MkCard(ATop, AHeight: Integer): TPanel;
var
  Card: TPanel;
  IsLight: Boolean;
  CardBg: TColor;
begin
  IsLight := CurrentTheme = tmLight;
  CardBg := IfThen(IsLight, clWhite, DARK_CARD_BG);

  Card := TPanel.Create(FBgPanel);
  Card.Parent := FBgPanel;
  Card.BevelOuter := bvNone;
  Card.BorderStyle := bsNone;
  Card.Color := CardBg;
  Card.DoubleBuffered := True;
  Card.Top := ATop;
  Card.Height := AHeight;
  Card.Left := MARGIN;
  Card.Width := Max(200, FBgPanel.Width - (MARGIN * 2));
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Card.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  Result := Card;
end;

procedure TReshadeTabHelper.BuildReShadeTab;
var
  MainForm: Tgoverlayform;
  IsLight: Boolean;
  BgClr, TxtClr: TColor;
  i, PackY: Integer;
  PPanel: TPanel;
  IconPath: string;
begin
  MainForm := Tgoverlayform(FForm);
  if not Assigned(MainForm) or not Assigned(MainForm.reshadeTabSheet) then Exit;

  IsLight := CurrentTheme = tmLight;
  BgClr := IfThen(IsLight, $00F0F0F0, RGBToColor(22, 26, 40));
  TxtClr := IfThen(IsLight, LightTextColor, DarkTextColor);

  MainForm.reshadeTabSheet.Color := BgClr;

  // ScrollBox
  FScrollBox := TScrollBox.Create(MainForm.reshadeTabSheet);
  FScrollBox.Parent := MainForm.reshadeTabSheet;
  FScrollBox.Align := alClient;
  FScrollBox.AutoScroll := True;
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.HorzScrollBar.Visible := False;
  FScrollBox.Color := BgClr;
  FScrollBox.ParentColor := False;
  FScrollBox.OnResize := @ReshadeScrollBoxResize;

  // Background Container
  FBgPanel := TPanel.Create(FScrollBox);
  FBgPanel.Parent := FScrollBox;
  FBgPanel.BevelOuter := bvNone;
  FBgPanel.Color := BgClr;
  FBgPanel.Caption := '';
  FBgPanel.OnPaint := @MainForm.PresetsWrapperPaint;
  FBgPanel.Left := 0;
  FBgPanel.Top := 0;
  FBgPanel.Width := FScrollBox.ClientWidth;
  FBgPanel.Height := 580;

  // ----------------------------------------------------
  // Card 0: Method (Top: 10, Height: 108)
  // ----------------------------------------------------
  FMethodCard := MkCard(10, 108);

  FMethodTitleLbl := TLabel.Create(FMethodCard);
  FMethodTitleLbl.Parent := FMethodCard;
  StyleMainCard(FMethodCard, FMethodTitleLbl, 'Method');

  // Option 1: None
  FNoneRadio := TRadioButton.Create(FMethodCard);
  FNoneRadio.Parent := FMethodCard;
  FNoneRadio.Caption := '';
  StyleToggleControl(FNoneRadio);
  FNoneRadio.Checked := False;
  FNoneRadio.OnClick := @OnMethodNoneClick;

  FNoneLogoImg := TImage.Create(FMethodCard);
  FNoneLogoImg.Parent := FMethodCard;
  FNoneLogoImg.AntialiasingMode := amOn;
  FNoneLogoImg.StretchInEnabled := True;
  FNoneLogoImg.StretchOutEnabled := True;
  FNoneLogoImg.Transparent := True;
  FNoneLogoImg.Center := True;
  FNoneLogoImg.Proportional := True;
  FNoneLogoImg.Stretch := True;
  FNoneLogoImg.Cursor := crHandPoint;
  FNoneLogoImg.OnClick := @OnMethodNoneClick;

  // Option 2: ReShade
  FReshadeRadio := TRadioButton.Create(FMethodCard);
  FReshadeRadio.Parent := FMethodCard;
  FReshadeRadio.Caption := '';
  StyleToggleControl(FReshadeRadio);
  FReshadeRadio.Checked := True;
  FReshadeRadio.OnClick := @OnMethodReshadeClick;

  FReshadeLogoImg := TImage.Create(FMethodCard);
  FReshadeLogoImg.Parent := FMethodCard;
  FReshadeLogoImg.AntialiasingMode := amOn;
  FReshadeLogoImg.StretchInEnabled := True;
  FReshadeLogoImg.StretchOutEnabled := True;
  FReshadeLogoImg.Transparent := True;
  FReshadeLogoImg.Center := True;
  FReshadeLogoImg.Proportional := True;
  FReshadeLogoImg.Stretch := True;
  FReshadeLogoImg.Cursor := crHandPoint;
  FReshadeLogoImg.OnClick := @OnMethodReshadeClick;

  // Option 3: vkBasalt
  FVkBasaltRadio := TRadioButton.Create(FMethodCard);
  FVkBasaltRadio.Parent := FMethodCard;
  FVkBasaltRadio.Caption := '';
  StyleToggleControl(FVkBasaltRadio);
  FVkBasaltRadio.Checked := False;
  FVkBasaltRadio.OnClick := @OnMethodVkBasaltClick;

  FVkBasaltLogoImg := TImage.Create(FMethodCard);
  FVkBasaltLogoImg.Parent := FMethodCard;
  FVkBasaltLogoImg.AntialiasingMode := amOn;
  FVkBasaltLogoImg.StretchInEnabled := True;
  FVkBasaltLogoImg.StretchOutEnabled := True;
  FVkBasaltLogoImg.Transparent := True;
  FVkBasaltLogoImg.Center := True;
  FVkBasaltLogoImg.Proportional := True;
  FVkBasaltLogoImg.Stretch := True;
  FVkBasaltLogoImg.Cursor := crHandPoint;
  FVkBasaltLogoImg.OnClick := @OnMethodVkBasaltClick;

  // Load Method PNGs
  FNonePngLogo := TPortableNetworkGraphic.Create;
  FReshadePngLogo := TPortableNetworkGraphic.Create;
  FVkBasaltPngLogo := TPortableNetworkGraphic.Create;

  IconPath := GetAppBaseDir + 'assets/icons/upscaler_none.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/upscaler_none.png';
  if FileExists(IconPath) then FNonePngLogo.LoadFromFile(IconPath);

  IconPath := GetAppBaseDir + 'assets/icons/method_reshade.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/method_reshade.png';
  if FileExists(IconPath) then FReshadePngLogo.LoadFromFile(IconPath);

  IconPath := GetAppBaseDir + 'assets/icons/method_vkbasalt.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/method_vkbasalt.png';
  if FileExists(IconPath) then FVkBasaltPngLogo.LoadFromFile(IconPath);

  FNonePngDimmed := CreateDimmedPng(FNonePngLogo, 35);
  FReshadePngDimmed := CreateDimmedPng(FReshadePngLogo, 35);
  FVkBasaltPngDimmed := CreateDimmedPng(FVkBasaltPngLogo, 35);

  FNoneLogoImg.Picture.Assign(FNonePngLogo);
  FReshadeLogoImg.Picture.Assign(FReshadePngLogo);
  FVkBasaltLogoImg.Picture.Assign(FVkBasaltPngLogo);

  // Informational label for None state
  FNoneNoticeLbl := TLabel.Create(FBgPanel);
  FNoneNoticeLbl.Parent := FBgPanel;
  FNoneNoticeLbl.Caption := 'Post-processing is disabled. Select ReShade or vkBasalt above to configure effects.';
  FNoneNoticeLbl.Font.Color := IfThen(IsLight, clGray, clMedGray);
  FNoneNoticeLbl.Font.Size := 10;
  FNoneNoticeLbl.Alignment := taCenter;
  FNoneNoticeLbl.AutoSize := False;
  FNoneNoticeLbl.Visible := False;

  // ----------------------------------------------------
  // Card 1: Options (Top: 10, Height: 108)
  // ----------------------------------------------------
  FConfigCard := MkCard(10, 108);

  FConfigTitleLbl := TLabel.Create(FConfigCard);
  FConfigTitleLbl.Parent := FConfigCard;
  StyleMainCard(FConfigCard, FConfigTitleLbl, 'Options');

  FToggleTitleLbl := TLabel.Create(FConfigCard);
  FToggleTitleLbl.Parent := FConfigCard;
  FToggleTitleLbl.Caption := 'Toggle:';
  FToggleTitleLbl.Font.Color := TxtClr;
  FToggleTitleLbl.SetBounds(CARD_P, 40, 180, 20);

  FToggleBtn := TBitBtn.Create(FConfigCard);
  FToggleBtn.Parent := FConfigCard;
  FToggleBtn.Tag := 7;
  FToggleBtn.Anchors := [akLeft, akTop];
  FToggleBtn.Cursor := crHandPoint;
  FToggleBtn.OnClick := @MainForm.CaptureBtnClick;
  FToggleBtn.SetBounds(210, 36, 120, 28);
  FToggleBtn.Caption := '⌨ Home';
  StyleActionButton(FToggleBtn);

  FHotkeyComboBox := TComboBox.Create(FConfigCard);
  FHotkeyComboBox.Parent := FConfigCard;
  FHotkeyComboBox.Visible := False;
  FHotkeyComboBox.Style := csDropDownList;
  FHotkeyComboBox.Items.Add('Home (VK 36, Default)');
  FHotkeyComboBox.Items.Add('Shift+F2');
  FHotkeyComboBox.Items.Add('End (VK 35)');
  FHotkeyComboBox.Items.Add('Insert (VK 45)');
  FHotkeyComboBox.Items.Add('Page Up (VK 33)');
  FHotkeyComboBox.Items.Add('F11 (VK 122)');
  FHotkeyComboBox.ItemIndex := 0;
  FHotkeyComboBox.OnChange := @OnHotkeyChange;
  FHotkeyComboBox.SetBounds(210, 36, 220, 28);

  FProxyTitleLbl := TLabel.Create(FConfigCard);
  FProxyTitleLbl.Parent := FConfigCard;
  FProxyTitleLbl.Caption := 'Proxy DLL:';
  FProxyTitleLbl.Font.Color := TxtClr;
  FProxyTitleLbl.SetBounds(CARD_P, 74, 180, 20);

  FProxyComboBox := TComboBox.Create(FConfigCard);
  FProxyComboBox.Parent := FConfigCard;
  FProxyComboBox.Style := csDropDownList;
  FProxyComboBox.Items.Add('dxgi.dll (Default - DirectX 11/12)');
  FProxyComboBox.Items.Add('d3d11.dll (DirectX 11)');
  FProxyComboBox.Items.Add('d3d12.dll (DirectX 12)');
  FProxyComboBox.Items.Add('d3d9.dll (DirectX 9)');
  FProxyComboBox.Items.Add('opengl32.dll (OpenGL)');
  FProxyComboBox.ItemIndex := 0;
  FProxyComboBox.OnChange := @OnProxyChange;
  FProxyComboBox.SetBounds(210, 70, 220, 28);
  FProxyComboBox.Hint := 'OptiScaler Co-existence: When OptiScaler is active on dxgi.dll, ReShade is chained via OptiScaler.ini [ReShade] loader automatically.';
  FProxyComboBox.ShowHint := True;

  // ----------------------------------------------------
  // Card 2: Shaders (Top: 210, Height: 330)
  // ----------------------------------------------------
  FShadersCard := MkCard(210, 330);

  FShadersTitleLbl := TLabel.Create(FShadersCard);
  FShadersTitleLbl.Parent := FShadersCard;
  StyleMainCard(FShadersCard, FShadersTitleLbl, 'Shaders');

  FOpenShadersBtn := TBitBtn.Create(FShadersCard);
  FOpenShadersBtn.Parent := FShadersCard;
  FOpenShadersBtn.Caption := 'Open Shaders Directory';
  FOpenShadersBtn.Cursor := crHandPoint;
  FOpenShadersBtn.OnClick := @OnOpenShadersBtnClick;
  FOpenShadersBtn.SetBounds(Max(150, FShadersCard.Width - CARD_P - 180), 6, 180, 26);
  StyleActionButton(FOpenShadersBtn);

  SetLength(FPackPanels, RESHADE_PACK_COUNT);
  SetLength(FPackNameLbls, RESHADE_PACK_COUNT);
  SetLength(FPackDescLbls, RESHADE_PACK_COUNT);
  SetLength(FPackStatusLbls, RESHADE_PACK_COUNT);
  SetLength(FPackActionBtns, RESHADE_PACK_COUNT);

  PackY := 36;
  for i := 0 to RESHADE_PACK_COUNT - 1 do
  begin
    PPanel := TPanel.Create(FShadersCard);
    PPanel.Parent := FShadersCard;
    PPanel.BevelOuter := bvNone;
    PPanel.Color := IfThen(IsLight, RGBToColor(245, 245, 245), RGBToColor(20, 23, 35));
    PPanel.SetBounds(CARD_P, PackY, FShadersCard.Width - (CARD_P * 2), 52);
    FPackPanels[i] := PPanel;

    FPackNameLbls[i] := TLabel.Create(PPanel);
    FPackNameLbls[i].Parent := PPanel;
    FPackNameLbls[i].Caption := RESHADE_PACKS[i].Name;
    FPackNameLbls[i].Font.Bold := True;
    FPackNameLbls[i].Font.Color := TxtClr;
    FPackNameLbls[i].SetBounds(10, 6, 300, 18);

    FPackDescLbls[i] := TLabel.Create(PPanel);
    FPackDescLbls[i].Parent := PPanel;
    FPackDescLbls[i].Caption := RESHADE_PACKS[i].Description;
    FPackDescLbls[i].Font.Size := 9;
    FPackDescLbls[i].Font.Color := IfThen(IsLight, clGray, clMedGray);
    FPackDescLbls[i].SetBounds(10, 26, 500, 16);

    FPackStatusLbls[i] := TLabel.Create(PPanel);
    FPackStatusLbls[i].Parent := PPanel;
    FPackStatusLbls[i].Caption := 'Checking...';
    FPackStatusLbls[i].Font.Size := 9;
    FPackStatusLbls[i].Font.Color := TxtClr;
    FPackStatusLbls[i].SetBounds(PPanel.Width - 230, 16, 100, 20);

    FPackActionBtns[i] := TBitBtn.Create(PPanel);
    FPackActionBtns[i].Parent := PPanel;
    FPackActionBtns[i].Tag := i;
    FPackActionBtns[i].Caption := 'Install';
    FPackActionBtns[i].Cursor := crHandPoint;
    FPackActionBtns[i].OnClick := @OnPackActionClick;
    FPackActionBtns[i].SetBounds(PPanel.Width - 120, 12, 110, 28);
    StyleActionButton(FPackActionBtns[i]);

    Inc(PackY, 58);
  end;

  // ----------------------------------------------------
  // Card 3: Software status (Top: 550, Height: 100)
  // ----------------------------------------------------
  FStatusCard := MkCard(550, 100);

  FStatusTitleLbl := TLabel.Create(FStatusCard);
  FStatusTitleLbl.Parent := FStatusCard;
  StyleMainCard(FStatusCard, FStatusTitleLbl, 'Software status');

  // Row 1: ReShade
  FStatDot := TShape.Create(FStatusCard);
  FStatDot.Parent := FStatusCard;
  FStatDot.Shape := stEllipse;
  FStatDot.Brush.Color := $00666666;
  FStatDot.Pen.Style := psClear;
  FStatDot.SetBounds(CARD_P, 46, 8, 8);

  FStatNameLbl := TLabel.Create(FStatusCard);
  FStatNameLbl.Parent := FStatusCard;
  FStatNameLbl.Caption := 'ReShade';
  FStatNameLbl.Font.Color := $AAAAAA;
  FStatNameLbl.Font.Size := 9;
  FStatNameLbl.Font.Style := [fsBold];
  FStatNameLbl.AutoSize := True;
  FStatNameLbl.Transparent := True;
  FStatNameLbl.Left := CARD_P + 14;
  FStatNameLbl.Top := 42;

  FStatVerLbl := TLabel.Create(FStatusCard);
  FStatVerLbl.Parent := FStatusCard;
  FStatVerLbl.Caption := '—';
  FStatVerLbl.Font.Color := $00666666;
  FStatVerLbl.Font.Size := 9;
  FStatVerLbl.AutoSize := True;
  FStatVerLbl.Transparent := True;
  FStatVerLbl.Left := FStatNameLbl.Left + 65;
  FStatVerLbl.Top := 42;

  FUpdateBtn := TBitBtn.Create(FStatusCard);
  FUpdateBtn.Parent := FStatusCard;
  FUpdateBtn.Caption := 'Check updates';
  FUpdateBtn.Cursor := crHandPoint;
  FUpdateBtn.OnClick := @OnUpdateBtnClick;
  FUpdateBtn.SetBounds(FStatVerLbl.Left + FStatVerLbl.Width + 16, 36, 130, 28);
  StyleActionButton(FUpdateBtn);

  // Row 2: vkBasalt (below ReShade)
  FVkStatDot := TShape.Create(FStatusCard);
  FVkStatDot.Parent := FStatusCard;
  FVkStatDot.Shape := stEllipse;
  FVkStatDot.Brush.Color := $00666666;
  FVkStatDot.Pen.Style := psClear;
  FVkStatDot.SetBounds(CARD_P, 72, 8, 8);

  FVkStatNameLbl := TLabel.Create(FStatusCard);
  FVkStatNameLbl.Parent := FStatusCard;
  FVkStatNameLbl.Caption := 'vkBasalt';
  FVkStatNameLbl.Font.Color := $AAAAAA;
  FVkStatNameLbl.Font.Size := 9;
  FVkStatNameLbl.Font.Style := [fsBold];
  FVkStatNameLbl.AutoSize := True;
  FVkStatNameLbl.Transparent := True;
  FVkStatNameLbl.Left := CARD_P + 14;
  FVkStatNameLbl.Top := 68;

  FVkStatVerLbl := TLabel.Create(FStatusCard);
  FVkStatVerLbl.Parent := FStatusCard;
  FVkStatVerLbl.Caption := '—';
  FVkStatVerLbl.Font.Color := $00666666;
  FVkStatVerLbl.Font.Size := 9;
  FVkStatVerLbl.AutoSize := True;
  FVkStatVerLbl.Transparent := True;
  FVkStatVerLbl.Left := FVkStatNameLbl.Left + 65;
  FVkStatVerLbl.Top := 68;

  FSelectedMethod := rmReshade;
  LoadConfig;
  RefreshStatus;
end;

procedure TReshadeTabHelper.OnMethodNoneClick(Sender: TObject);
begin
  if FSelectedMethod = rmNone then Exit;
  ApplyMethodSelection(rmNone, not FLoading);
end;

procedure TReshadeTabHelper.OnMethodReshadeClick(Sender: TObject);
begin
  if FSelectedMethod = rmReshade then Exit;
  ApplyMethodSelection(rmReshade, not FLoading);
end;

procedure TReshadeTabHelper.OnMethodVkBasaltClick(Sender: TObject);
begin
  if FSelectedMethod = rmVkBasalt then Exit;
  ApplyMethodSelection(rmVkBasalt, not FLoading);
end;

procedure TReshadeTabHelper.SelectMethod(AMethod: TReshadeMethod);
begin
  ApplyMethodSelection(AMethod, not FLoading);
end;

procedure TReshadeTabHelper.UpdateMethodOpacity;
begin
  if Assigned(FNoneLogoImg) and Assigned(FNonePngLogo) and Assigned(FNonePngDimmed) then
  begin
    if FSelectedMethod = rmNone then
      FNoneLogoImg.Picture.Assign(FNonePngLogo)
    else
      FNoneLogoImg.Picture.Assign(FNonePngDimmed);
  end;

  if Assigned(FReshadeLogoImg) and Assigned(FReshadePngLogo) and Assigned(FReshadePngDimmed) then
  begin
    if FSelectedMethod = rmReshade then
      FReshadeLogoImg.Picture.Assign(FReshadePngLogo)
    else
      FReshadeLogoImg.Picture.Assign(FReshadePngDimmed);
  end;

  if Assigned(FVkBasaltLogoImg) and Assigned(FVkBasaltPngLogo) and Assigned(FVkBasaltPngDimmed) then
  begin
    if FSelectedMethod = rmVkBasalt then
      FVkBasaltLogoImg.Picture.Assign(FVkBasaltPngLogo)
    else
      FVkBasaltLogoImg.Picture.Assign(FVkBasaltPngDimmed);
  end;
end;

procedure TReshadeTabHelper.ApplyMethodSelection(AMethod: TReshadeMethod; ASave: Boolean);
var
  MainForm: Tgoverlayform;
begin
  FSelectedMethod := AMethod;
  if Assigned(FNoneRadio) then FNoneRadio.Checked := (AMethod = rmNone);
  if Assigned(FReshadeRadio) then FReshadeRadio.Checked := (AMethod = rmReshade);
  if Assigned(FVkBasaltRadio) then FVkBasaltRadio.Checked := (AMethod = rmVkBasalt);
  UpdateMethodOpacity;

  MainForm := Tgoverlayform(FForm);
  if Assigned(MainForm) then
  begin
    // Ensure vkBasalt cards are parented to FBgPanel
    if Assigned(MainForm.FVkReshadeCard) and (MainForm.FVkReshadeCard.Parent <> FBgPanel) then
    begin
      MainForm.FVkReshadeCard.Parent := FBgPanel;
      MainForm.FVkBuiltinCard.Parent := FBgPanel;
      MainForm.FVkPipelineCard.Parent := FBgPanel;
      MainForm.FVkToggleCard.Parent := FBgPanel;
    end;

    case AMethod of
      rmNone:
      begin
        if Assigned(FStatusCard) then FStatusCard.Visible := True;
        if Assigned(FConfigCard) then FConfigCard.Visible := False;
        if Assigned(FShadersCard) then FShadersCard.Visible := False;
        if Assigned(MainForm.FVkReshadeCard) then MainForm.FVkReshadeCard.Visible := False;
        if Assigned(MainForm.FVkBuiltinCard) then MainForm.FVkBuiltinCard.Visible := False;
        if Assigned(MainForm.FVkPipelineCard) then MainForm.FVkPipelineCard.Visible := False;
        if Assigned(MainForm.FVkToggleCard) then MainForm.FVkToggleCard.Visible := False;
        if Assigned(FNoneNoticeLbl) then FNoneNoticeLbl.Visible := True;
      end;

      rmReshade:
      begin
        if Assigned(FStatusCard) then FStatusCard.Visible := True;
        if Assigned(FConfigCard) then FConfigCard.Visible := True;
        if Assigned(FShadersCard) then FShadersCard.Visible := True;
        if Assigned(MainForm.FVkReshadeCard) then MainForm.FVkReshadeCard.Visible := False;
        if Assigned(MainForm.FVkBuiltinCard) then MainForm.FVkBuiltinCard.Visible := False;
        if Assigned(MainForm.FVkPipelineCard) then MainForm.FVkPipelineCard.Visible := False;
        if Assigned(MainForm.FVkToggleCard) then MainForm.FVkToggleCard.Visible := False;
        if Assigned(FNoneNoticeLbl) then FNoneNoticeLbl.Visible := False;
      end;

      rmVkBasalt:
      begin
        if Assigned(FStatusCard) then FStatusCard.Visible := False;
        if Assigned(FConfigCard) then FConfigCard.Visible := False;
        if Assigned(FShadersCard) then FShadersCard.Visible := False;
        if Assigned(MainForm.FVkReshadeCard) then MainForm.FVkReshadeCard.Visible := True;
        if Assigned(MainForm.FVkBuiltinCard) then MainForm.FVkBuiltinCard.Visible := True;
        if Assigned(MainForm.FVkPipelineCard) then MainForm.FVkPipelineCard.Visible := True;
        if Assigned(MainForm.FVkToggleCard) then MainForm.FVkToggleCard.Visible := True;
        if Assigned(FNoneNoticeLbl) then FNoneNoticeLbl.Visible := False;
      end;
    end;

    UpdateVkBasaltBanner(MainForm.IsVkBasaltInstalled);
  end;

  if Assigned(FScrollBox) then
    ReflowReShadeTab(FScrollBox.ClientWidth);

  if ASave and not FLoading then
    SaveConfig;
end;

procedure TReshadeTabHelper.UpdateVkBasaltBanner(AVkInstalled: Boolean);
var
  MainForm: Tgoverlayform;
  IsPostProcessingActive: Boolean;
begin
  MainForm := Tgoverlayform(FForm);
  if not Assigned(MainForm) then Exit;

  IsPostProcessingActive := (MainForm.ActiveToolIndex = 1);

  if FSelectedMethod = rmVkBasalt then
  begin
    if not AVkInstalled then
    begin
      if not Assigned(MainForm.FVkBasaltMissingBanner) then
        MainForm.FVkBasaltMissingBanner := MainForm.CreateDependencyWarningBanner(
          FBgPanel,
          'vkBasalt',
          'flatpak install org.freedesktop.Platform.VulkanLayer.vkBasalt',
          'vkbasalt',
          @MainForm.RecheckDependenciesClick,
          @MainForm.ViewStatusClick
        );
      MainForm.FVkBasaltMissingBanner.Parent := FBgPanel;
      MainForm.FVkBasaltMissingBanner.Visible := True;
      MainForm.FVkBasaltMissingBanner.BringToFront;
      if Assigned(MainForm.FVkReshadeCard) then MainForm.SetControlTreeEnabled(MainForm.FVkReshadeCard, False);
      if Assigned(MainForm.FVkBuiltinCard) then MainForm.SetControlTreeEnabled(MainForm.FVkBuiltinCard, False);
      if Assigned(MainForm.FVkPipelineCard) then MainForm.SetControlTreeEnabled(MainForm.FVkPipelineCard, False);
      if Assigned(MainForm.FVkToggleCard) then MainForm.SetControlTreeEnabled(MainForm.FVkToggleCard, False);
      if IsPostProcessingActive then
        MainForm.SetSaveBtnEnabled(False);
    end
    else
    begin
      if Assigned(MainForm.FVkBasaltMissingBanner) then
        MainForm.FVkBasaltMissingBanner.Visible := False;
      if Assigned(MainForm.FVkReshadeCard) then MainForm.SetControlTreeEnabled(MainForm.FVkReshadeCard, True);
      if Assigned(MainForm.FVkBuiltinCard) then MainForm.SetControlTreeEnabled(MainForm.FVkBuiltinCard, True);
      if Assigned(MainForm.FVkPipelineCard) then MainForm.SetControlTreeEnabled(MainForm.FVkPipelineCard, True);
      if Assigned(MainForm.FVkToggleCard) then MainForm.SetControlTreeEnabled(MainForm.FVkToggleCard, True);
      if IsPostProcessingActive then
        MainForm.SetSaveBtnEnabled(MainForm.FNavToolEnabled[1]);
    end;
  end
  else
  begin
    if Assigned(MainForm.FVkBasaltMissingBanner) then
      MainForm.FVkBasaltMissingBanner.Visible := False;
    if IsPostProcessingActive and ((FSelectedMethod = rmReshade) or (FSelectedMethod = rmNone)) then
      MainForm.SetSaveBtnEnabled(MainForm.FNavToolEnabled[1]);
  end;

  if Assigned(FScrollBox) then
    ReflowReShadeTab(FScrollBox.ClientWidth);
end;

procedure TReshadeTabHelper.ReshadeScrollBoxResize(Sender: TObject);
begin
  if Assigned(FScrollBox) then
    ReflowReShadeTab(FScrollBox.ClientWidth);
end;

procedure TReshadeTabHelper.ReflowReShadeTab(AContentW: Integer);
const
  TOP_ROW_H = 108;
  STATUS_H  = 100;
  BOTTOM_M  = 4;
var
  W, TargetCardW, HalfW, RightColW, RightColLeft, CurY, TopRowY, i, CheckW: Integer;
  ClientH, TotalH, ShadersH, CardBottomTop: Integer;
  FixedBelow, BuiltinH, PipelineH, ReshadeH, MinReshadeH, MinShadersH, MinTotalH: Integer;
  PackStep, PackH, PackY, OptLabelW: Integer;
  MainForm: Tgoverlayform;
  LogoW_None, LogoW_Reshade, LogoW_VkBasalt: Integer;
  GroupW_None, GroupW_Reshade, GroupW_VkBasalt: Integer;
  TotalGroupW, GapBetween, InnerW, X1, X2, X3, RadioY: Integer;
begin
  if not Assigned(FBgPanel) or not Assigned(FScrollBox) then Exit;

  CurY := MARGIN;
  ShadersH := 0;

  W := FScrollBox.ClientWidth;
  if AContentW > 100 then
    W := AContentW
  else if W < 500 then
    W := 500;

  FBgPanel.Width := W;
  TargetCardW := Max(200, W - (MARGIN * 2));
  HalfW := (TargetCardW - CARD_GAP) div 2;
  RightColW := TargetCardW - HalfW - CARD_GAP;
  RightColLeft := MARGIN + HalfW + CARD_GAP;

  MainForm := Tgoverlayform(FForm);

  // Ensure vkBasalt cards are parented to FBgPanel if created
  if Assigned(MainForm) and Assigned(MainForm.FVkReshadeCard) and (MainForm.FVkReshadeCard.Parent <> FBgPanel) then
  begin
    MainForm.FVkReshadeCard.Parent := FBgPanel;
    MainForm.FVkBuiltinCard.Parent := FBgPanel;
    MainForm.FVkPipelineCard.Parent := FBgPanel;
    MainForm.FVkToggleCard.Parent := FBgPanel;
  end;

  // Determine available client height
  ClientH := FScrollBox.ClientHeight;
  if ClientH < 400 then
  begin
    if Assigned(FForm) and (FForm.ClientHeight > 150) then
      ClientH := FForm.ClientHeight - 38
    else
      ClientH := 648;
  end;

  // vkBasalt warning banner at top of page (matching vkSumi tab style)
  if (FSelectedMethod = rmVkBasalt) and Assigned(MainForm) and
     Assigned(MainForm.FVkBasaltMissingBanner) and MainForm.FVkBasaltMissingBanner.Visible then
  begin
    MainForm.FVkBasaltMissingBanner.SetBounds(MARGIN, CurY, TargetCardW, 72);
    CurY := CurY + 72 + CARD_GAP;
  end;

  TopRowY := CurY;

  // 1. Method Card (occupies 50% of available horizontal space)
  if Assigned(FMethodCard) then
  begin
    FMethodCard.SetBounds(MARGIN, TopRowY, HalfW, TOP_ROW_H);
    InnerW := HalfW - 2 * CARD_P;
    LogoW_None := 38;
    LogoW_Reshade := 120;
    LogoW_VkBasalt := 105;

    GroupW_None := 22 + LogoW_None;
    GroupW_Reshade := 22 + LogoW_Reshade;
    GroupW_VkBasalt := 22 + LogoW_VkBasalt;
    TotalGroupW := GroupW_None + GroupW_Reshade + GroupW_VkBasalt;

    if InnerW < TotalGroupW then
    begin
      LogoW_Reshade := Max(80, (InnerW - GroupW_None - 44 - 8) * 120 div 225);
      LogoW_VkBasalt := Max(70, (InnerW - GroupW_None - 44 - 8) * 105 div 225);
      GroupW_Reshade := 22 + LogoW_Reshade;
      GroupW_VkBasalt := 22 + LogoW_VkBasalt;
      TotalGroupW := GroupW_None + GroupW_Reshade + GroupW_VkBasalt;
    end;

    if InnerW > TotalGroupW then
      GapBetween := (InnerW - TotalGroupW) div 2
    else
      GapBetween := 4;

    X1 := CARD_P;
    X2 := X1 + GroupW_None + GapBetween;
    X3 := HalfW - CARD_P - GroupW_VkBasalt;
    if X3 < X2 + GroupW_Reshade + 4 then
      X3 := X2 + GroupW_Reshade + 4;

    RadioY := 30 + (TOP_ROW_H - 30 - 36) div 2;

    if Assigned(FNoneRadio) then
      FNoneRadio.SetBounds(X1, RadioY + 8, 20, 20);
    if Assigned(FNoneLogoImg) then
      FNoneLogoImg.SetBounds(X1 + 22, RadioY + 8, LogoW_None, 20);

    if Assigned(FReshadeRadio) then
      FReshadeRadio.SetBounds(X2, RadioY + 8, 20, 20);
    if Assigned(FReshadeLogoImg) then
      FReshadeLogoImg.SetBounds(X2 + 22, RadioY, LogoW_Reshade, 36);

    if Assigned(FVkBasaltRadio) then
      FVkBasaltRadio.SetBounds(X3, RadioY + 8, 20, 20);
    if Assigned(FVkBasaltLogoImg) then
      FVkBasaltLogoImg.SetBounds(X3 + 22, RadioY, LogoW_VkBasalt, 36);
  end;

  case FSelectedMethod of
    rmNone:
    begin
      if Assigned(FStatusCard) then
        FStatusCard.Visible := True;
      CurY := TopRowY + TOP_ROW_H + CARD_GAP;
      if Assigned(FNoneNoticeLbl) then
      begin
        FNoneNoticeLbl.SetBounds(MARGIN + 10, CurY + 10, TargetCardW - 20, 40);
        CurY := CurY + 60;
      end;
      TotalH := Max(ClientH, CurY + STATUS_H + BOTTOM_M);
      CardBottomTop := TotalH - BOTTOM_M - STATUS_H;
      if Assigned(FStatusCard) then
        FStatusCard.SetBounds(MARGIN, CardBottomTop, TargetCardW, STATUS_H);
      CurY := CardBottomTop + STATUS_H + BOTTOM_M;
    end;

    rmReshade:
    begin
      if Assigned(FStatusCard) then
        FStatusCard.Visible := True;
      // Options card to the right of Method card
      if Assigned(FConfigCard) then
      begin
        FConfigCard.SetBounds(RightColLeft, TopRowY, RightColW, TOP_ROW_H);
        OptLabelW := 80;
        if Assigned(FToggleTitleLbl) then
          FToggleTitleLbl.SetBounds(CARD_P, 38, OptLabelW, 20);
        if Assigned(FToggleBtn) then
          FToggleBtn.SetBounds(CARD_P + OptLabelW + 8, 34, 110, 28);
        if Assigned(FProxyTitleLbl) then
          FProxyTitleLbl.SetBounds(CARD_P, 72, OptLabelW, 20);
        if Assigned(FProxyComboBox) then
          FProxyComboBox.SetBounds(CARD_P + OptLabelW + 8, 68, Max(100, RightColW - CARD_P * 2 - OptLabelW - 8), 28);
      end;

      CurY := TopRowY + TOP_ROW_H + CARD_GAP;
      MinShadersH := 280;
      MinTotalH := CurY + MinShadersH + CARD_GAP + STATUS_H + BOTTOM_M;
      TotalH := Max(ClientH, MinTotalH);
      CardBottomTop := TotalH - BOTTOM_M - STATUS_H;
      ShadersH := CardBottomTop - CARD_GAP - CurY;

      // Shaders card expands vertically to take available space
      if Assigned(FShadersCard) then
      begin
        FShadersCard.SetBounds(MARGIN, CurY, TargetCardW, ShadersH);
        if Assigned(FOpenShadersBtn) then
          FOpenShadersBtn.Left := Max(150, TargetCardW - CARD_P - FOpenShadersBtn.Width);
      end;

      // Software status card anchored to bottom
      if Assigned(FStatusCard) then
        FStatusCard.SetBounds(MARGIN, CardBottomTop, TargetCardW, STATUS_H);

      CurY := CardBottomTop + STATUS_H + BOTTOM_M;
    end;

    rmVkBasalt:
    begin
      if Assigned(FStatusCard) then
        FStatusCard.Visible := False;

      // Options card to the right of Method card
      if Assigned(MainForm) and Assigned(MainForm.FVkToggleCard) then
      begin
        MainForm.FVkToggleCard.SetBounds(RightColLeft, TopRowY, RightColW, TOP_ROW_H);
        OptLabelW := 80;
        if Assigned(MainForm.FVkToggleTitleLbl) then
        begin
          MainForm.FVkToggleTitleLbl.Caption := 'Options';
          MainForm.FVkToggleTitleLbl.SetBounds(CARD_P, 8, 120, 20);
        end;

        if Assigned(MainForm.FVkToggleLabel) then
          MainForm.FVkToggleLabel.SetBounds(CARD_P, 38, OptLabelW, 20);

        if Assigned(MainForm.FVkToggleCaptureBtn) then
          MainForm.FVkToggleCaptureBtn.SetBounds(CARD_P + OptLabelW + 8, 34, 110, 28);

        if Assigned(MainForm.FVkRestoreBtn) then
          MainForm.FVkRestoreBtn.SetBounds(CARD_P + OptLabelW + 8, 68, 140, 28);
      end;

      CurY := TopRowY + TOP_ROW_H + CARD_GAP;
      BuiltinH := 148;
      PipelineH := 72;
      FixedBelow := CARD_GAP + BuiltinH + CARD_GAP + PipelineH + BOTTOM_M;
      MinReshadeH := 110;
      MinTotalH := CurY + MinReshadeH + FixedBelow;
      TotalH := Max(ClientH, MinTotalH);
      ReshadeH := TotalH - CurY - FixedBelow;

      // Reshade effects card expands vertically to take available space
      if Assigned(MainForm) and Assigned(MainForm.FVkReshadeCard) then
      begin
        MainForm.FVkReshadeCard.SetBounds(MARGIN, CurY, TargetCardW, ReshadeH);
        CurY := CurY + ReshadeH + CARD_GAP;
      end;

      if Assigned(MainForm) and Assigned(MainForm.FVkBuiltinCard) then
      begin
        MainForm.FVkBuiltinCard.SetBounds(MARGIN, CurY, TargetCardW, BuiltinH);
        CurY := CurY + BuiltinH + CARD_GAP;
      end;

      // Effect Pipeline card anchored at the bottom
      if Assigned(MainForm) and Assigned(MainForm.FVkPipelineCard) then
      begin
        MainForm.FVkPipelineCard.SetBounds(MARGIN, CurY, TargetCardW, PipelineH);
        CurY := CurY + PipelineH + BOTTOM_M;
      end;

      if Assigned(MainForm) then
      begin
        MainForm.ReflowVkBasaltTab(TargetCardW);

        // Keep Options card controls properly positioned
        OptLabelW := 80;
        if Assigned(MainForm.FVkToggleLabel) then
          MainForm.FVkToggleLabel.SetBounds(CARD_P, 38, OptLabelW, 20);
        if Assigned(MainForm.FVkToggleCaptureBtn) then
          MainForm.FVkToggleCaptureBtn.SetBounds(CARD_P + OptLabelW + 8, 34, 110, 28);
        if Assigned(MainForm.FVkRestoreBtn) then
          MainForm.FVkRestoreBtn.SetBounds(CARD_P + OptLabelW + 8, 68, 140, 28);
      end;
    end;
  end;

  FBgPanel.Height := Max(FScrollBox.ClientHeight, CurY);

  // Status card internal layout
  if Assigned(FStatusCard) then
  begin
    FStatusCard.Width := TargetCardW;
    CheckW := 130;

    // Row 1: ReShade
    if Assigned(FStatDot) then
      FStatDot.SetBounds(CARD_P, 46, 8, 8);
    if Assigned(FStatNameLbl) then
    begin
      FStatNameLbl.Left := CARD_P + 14;
      FStatNameLbl.Top := 42;
    end;
    if Assigned(FStatVerLbl) and Assigned(FStatNameLbl) then
    begin
      FStatVerLbl.Left := FStatNameLbl.Left + FStatNameLbl.Width + 12;
      FStatVerLbl.Top := 42;
    end;
    if Assigned(FUpdateBtn) and Assigned(FStatVerLbl) then
      FUpdateBtn.SetBounds(FStatVerLbl.Left + FStatVerLbl.Width + 16, 36, CheckW, 28);

    // Row 2: vkBasalt (below ReShade)
    if Assigned(FVkStatDot) then
      FVkStatDot.SetBounds(CARD_P, 72, 8, 8);
    if Assigned(FVkStatNameLbl) then
    begin
      FVkStatNameLbl.Left := CARD_P + 14;
      FVkStatNameLbl.Top := 68;
    end;
    if Assigned(FVkStatVerLbl) and Assigned(FVkStatNameLbl) then
    begin
      FVkStatVerLbl.Left := FVkStatNameLbl.Left + FVkStatNameLbl.Width + 12;
      FVkStatVerLbl.Top := 68;
    end;
  end;

  // Shader packs internal layout
  if Assigned(FShadersCard) and (FSelectedMethod = rmReshade) then
  begin
    PackStep := (ShadersH - 36 - 8) div RESHADE_PACK_COUNT;
    if PackStep > 62 then PackStep := 62;
    if PackStep < 46 then PackStep := 46;
    PackH := Min(52, PackStep - 6);
    PackY := 36;

    for i := 0 to Length(FPackPanels) - 1 do
    begin
      if Assigned(FPackPanels[i]) then
      begin
        FPackPanels[i].SetBounds(CARD_P, PackY, TargetCardW - (CARD_P * 2), PackH);
        if Assigned(FPackActionBtns[i]) then
        begin
          FPackActionBtns[i].Left := FPackPanels[i].Width - 120;
          FPackActionBtns[i].Top := (PackH - 28) div 2;
        end;
        if Assigned(FPackStatusLbls[i]) then
        begin
          FPackStatusLbls[i].Left := FPackPanels[i].Width - 230;
          FPackStatusLbls[i].Top := (PackH - 20) div 2;
        end;
        if Assigned(FPackNameLbls[i]) then
        begin
          FPackNameLbls[i].Left := 10;
          FPackNameLbls[i].Top := IfThen(PackH >= 48, 6, 3);
        end;
        if Assigned(FPackDescLbls[i]) then
        begin
          FPackDescLbls[i].Left := 10;
          FPackDescLbls[i].Top := IfThen(PackH >= 48, 26, 20);
          FPackDescLbls[i].Width := Max(100, FPackPanels[i].Width - 250);
        end;
        Inc(PackY, PackStep);
      end;
    end;
  end;
end;

procedure TReshadeTabHelper.RefreshStatus;
const
  CLR_OK   = $0044BB44;   // green — library found
  CLR_NONE = $00666666;   // gray  — not installed
  PURPLE   = $BB99FF;
var
  BinDir, ShadersDir, CheckPath, VkVer: string;
  i: Integer;
  IsInstalled, HasDll: Boolean;
begin
  BinDir := IncludeTrailingPathDelimiter(GetReShadeBinPath);
  ShadersDir := IncludeTrailingPathDelimiter(GetReShadeShadersPath);

  // ReShade status
  HasDll := FileExists(BinDir + 'ReShade64.dll') or FileExists(BinDir + 'ReShade32.dll');
  if Assigned(FStatDot) and Assigned(FStatVerLbl) then
  begin
    if HasDll then
    begin
      FStatDot.Brush.Color := CLR_OK;
      FStatVerLbl.Caption := '6.4 (Add-on Edition)';
      FStatVerLbl.Font.Color := PURPLE;
    end
    else
    begin
      FStatDot.Brush.Color := CLR_NONE;
      FStatVerLbl.Caption := '—';
      FStatVerLbl.Font.Color := CLR_NONE;
    end;
    if Assigned(FStatNameLbl) then
      FStatVerLbl.Left := FStatNameLbl.Left + FStatNameLbl.Width + 12;
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Left := FStatVerLbl.Left + FStatVerLbl.Width + 16;
  end;

  // vkBasalt status
  if Assigned(FVkStatDot) and Assigned(FVkStatVerLbl) then
  begin
    VkVer := '';
    if Assigned(FForm) and (FForm is Tgoverlayform) then
      VkVer := Tgoverlayform(FForm).GetVkBasaltVersion;

    if VkVer <> '' then
    begin
      FVkStatDot.Brush.Color := CLR_OK;
      FVkStatVerLbl.Caption := VkVer;
      FVkStatVerLbl.Font.Color := PURPLE;
    end
    else
    begin
      FVkStatDot.Brush.Color := CLR_NONE;
      FVkStatVerLbl.Caption := '—';
      FVkStatVerLbl.Font.Color := CLR_NONE;
    end;
    if Assigned(FVkStatNameLbl) then
      FVkStatVerLbl.Left := FVkStatNameLbl.Left + FVkStatNameLbl.Width + 12;
  end;
  // Shaders status
  for i := 0 to RESHADE_PACK_COUNT - 1 do
  begin
    CheckPath := ShadersDir + 'Shaders' + PathDelim + RESHADE_PACKS[i].CheckFile;
    IsInstalled := FileExists(CheckPath) or (DirectoryExists(ShadersDir + 'Shaders') and (i = 0));
    if not IsInstalled then
    begin
      case i of
        3: IsInstalled := FileExists(ShadersDir + 'Shaders' + PathDelim + 'Clarity.fx') or
                          FileExists(ShadersDir + 'Shaders' + PathDelim + 'BloomingHDR.fx') or
                          FileExists(ShadersDir + 'Shaders' + PathDelim + 'RadiantGI.fx');
        4: IsInstalled := FileExists(ShadersDir + 'Shaders' + PathDelim + 'PD80_01A_RT_Correct_Contrast.fx') or
                          FileExists(ShadersDir + 'Shaders' + PathDelim + 'PD80_01_Color_Gamut.fx') or
                          FileExists(ShadersDir + 'Shaders' + PathDelim + 'prod80_01A_RT_Correct_Color.fx');
      end;
    end;

    FPackActionBtns[i].Enabled := True;
    if IsInstalled then
    begin
      FPackStatusLbls[i].Caption := '✔ Installed';
      FPackStatusLbls[i].Font.Color := clGreen;
      FPackActionBtns[i].Caption := 'Re-install';
    end
    else
    begin
      FPackStatusLbls[i].Caption := 'Not installed';
      FPackStatusLbls[i].Font.Color := clMedGray;
      FPackActionBtns[i].Caption := 'Install';
    end;
  end;
end;

procedure TReshadeTabHelper.OnPackActionClick(Sender: TObject);
var
  Idx: Integer;
  Btn: TBitBtn;
begin
  if not (Sender is TBitBtn) then Exit;
  Btn := TBitBtn(Sender);
  Idx := Btn.Tag;
  if (Idx >= 0) and (Idx < RESHADE_PACK_COUNT) then
  begin
    Btn.Enabled := False;
    Btn.Caption := 'Downloading...';
    TReshadeAsyncInstallThread.Create(Self, Idx, False);
  end;
end;

procedure TReshadeTabHelper.OnUpdateBtnClick(Sender: TObject);
begin
  FUpdateBtn.Enabled := False;
  FUpdateBtn.Caption := 'Updating...';
  TReshadeAsyncInstallThread.Create(Self, -1, True);
end;

procedure TReshadeTabHelper.OnOpenShadersBtnClick(Sender: TObject);
var
  ShadersDir: string;
begin
  ShadersDir := GetReShadeShadersPath;
  EnsureReShadeDirectories;
  ExecuteShellCommand('xdg-open ' + QuotedStr(ShadersDir) + ' &');
end;

procedure TReshadeTabHelper.OnHotkeyChange(Sender: TObject);
begin
  case FHotkeyComboBox.ItemIndex of
    0: FHotkeyValue := '36,0,0,0';       // Home
    1: FHotkeyValue := '113,0,1,0';      // Shift+F2
    2: FHotkeyValue := '35,0,0,0';       // End
    3: FHotkeyValue := '45,0,0,0';       // Insert
    4: FHotkeyValue := '33,0,0,0';       // Page Up
    5: FHotkeyValue := '122,0,0,0';      // F11
  end;
  if Assigned(FToggleBtn) then
    FToggleBtn.Caption := '⌨ ' + ReShadeKeyToDisplayName(FHotkeyValue);
  if FLoading then Exit;
  SaveConfig;
end;

procedure TReshadeTabHelper.OnProxyChange(Sender: TObject);
begin
  if FLoading then Exit;
  SaveConfig;
end;

procedure TReshadeTabHelper.LoadConfig;
var
  IniPath, ConfPath: string;
  Ini: TIniFile;
  KeyVal, ProxyVal, ReshadeVal, VkBasaltVal: string;
  LoadedMethod: TReshadeMethod;
begin
  FLoading := True;
  try
    LoadedMethod := rmNone;

    IniPath := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'ReShade.ini';
    if FileExists(IniPath) then
    begin
      Ini := TIniFile.Create(IniPath);
      try
        KeyVal := Ini.ReadString('INPUT', 'KeyOverlay', Ini.ReadString('GENERAL', 'KeyOverlay', '36,0,0,0'));
        FHotkeyValue := KeyVal;
        SyncHotkeyUI;

        ProxyVal := Ini.ReadString('GOVERLAY', 'DefaultProxy', 'dxgi.dll');
        if SameText(ProxyVal, 'dxgi.dll') then FProxyComboBox.ItemIndex := 0
        else if SameText(ProxyVal, 'd3d11.dll') then FProxyComboBox.ItemIndex := 1
        else if SameText(ProxyVal, 'd3d12.dll') then FProxyComboBox.ItemIndex := 2
        else if SameText(ProxyVal, 'd3d9.dll') then FProxyComboBox.ItemIndex := 3
        else if SameText(ProxyVal, 'opengl32.dll') then FProxyComboBox.ItemIndex := 4
        else FProxyComboBox.ItemIndex := 0;

        if Ini.ReadString('GOVERLAY', 'Enabled', '0') = '1' then
          LoadedMethod := rmReshade;
      finally
        Ini.Free;
      end;
    end
    else
    begin
      FHotkeyValue := '36,0,0,0';
      SyncHotkeyUI;
    end;

    if Assigned(FForm) and (FForm is Tgoverlayform) then
    begin
      ConfPath := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName) + 'bgmod.conf';
      if FileExists(ConfPath) then
      begin
        Ini := TIniFile.Create(ConfPath);
        try
          ReshadeVal := Ini.ReadString('Config', 'GOVERLAY_RESHADE', '0');
          VkBasaltVal := Ini.ReadString('Config', 'GOVERLAY_VKBASALT', '0');

          if ReshadeVal = '1' then
            LoadedMethod := rmReshade
          else if VkBasaltVal = '1' then
            LoadedMethod := rmVkBasalt
          else
            LoadedMethod := rmNone;

          ProxyVal := Ini.ReadString('Config', 'RESHADE_DLL', '');
          if ProxyVal <> '' then
          begin
            if SameText(ProxyVal, 'dxgi.dll') then FProxyComboBox.ItemIndex := 0
            else if SameText(ProxyVal, 'd3d11.dll') then FProxyComboBox.ItemIndex := 1
            else if SameText(ProxyVal, 'd3d12.dll') then FProxyComboBox.ItemIndex := 2
            else if SameText(ProxyVal, 'd3d9.dll') then FProxyComboBox.ItemIndex := 3
            else if SameText(ProxyVal, 'opengl32.dll') then FProxyComboBox.ItemIndex := 4;
          end;
        finally
          Ini.Free;
        end;
      end;
    end;

    ApplyMethodSelection(LoadedMethod, False);
  finally
    FLoading := False;
  end;
end;

procedure TReshadeTabHelper.SaveConfig;
var
  IniPath, ConfPath: string;
  Ini: TIniFile;
  KeyVal, ProxyVal: string;
begin
  if FLoading then Exit;  // Never save while loading — guards against queued Qt events

  IniPath := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'ReShade.ini';
  EnsureReShadeDirectories;

  case FHotkeyComboBox.ItemIndex of
    0: KeyVal := '36,0,0,0';       // Home
    1: KeyVal := '113,0,1,0';      // Shift+F2
    2: KeyVal := '35,0,0,0';       // End
    3: KeyVal := '45,0,0,0';       // Insert
    4: KeyVal := '33,0,0,0';       // Page Up
    5: KeyVal := '122,0,0,0';      // F11
  else
    if FHotkeyValue <> '' then
      KeyVal := FHotkeyValue
    else
      KeyVal := '36,0,0,0';
  end;
  FHotkeyValue := KeyVal;

  case FProxyComboBox.ItemIndex of
    0: ProxyVal := 'dxgi.dll';
    1: ProxyVal := 'd3d11.dll';
    2: ProxyVal := 'd3d12.dll';
    3: ProxyVal := 'd3d9.dll';
    4: ProxyVal := 'opengl32.dll';
  else
    ProxyVal := 'dxgi.dll';
  end;

  Ini := TIniFile.Create(IniPath);
  try
    Ini.WriteString('GENERAL', 'KeyOverlay', KeyVal);
    Ini.WriteString('INPUT', 'KeyOverlay', KeyVal);
    Ini.WriteString('GOVERLAY', 'DefaultProxy', ProxyVal);
    Ini.WriteString('GOVERLAY', 'Enabled', BoolToStr(FSelectedMethod = rmReshade, '1', '0'));
  finally
    Ini.Free;
  end;

  if Assigned(FForm) and (FForm is Tgoverlayform) then
  begin
    ConfPath := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName) + 'bgmod.conf';
    ForceDirectories(ExtractFilePath(ConfPath));
    Ini := TIniFile.Create(ConfPath);
    try
      case FSelectedMethod of
        rmReshade:
        begin
          Ini.WriteString('Config', 'GOVERLAY_RESHADE', '1');
          Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '0');
        end;
        rmVkBasalt:
        begin
          Ini.WriteString('Config', 'GOVERLAY_RESHADE', '0');
          Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '1');
        end;
        rmNone:
        begin
          Ini.WriteString('Config', 'GOVERLAY_RESHADE', '0');
          Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '0');
        end;
      end;
      Ini.WriteString('Config', 'RESHADE_DLL', ProxyVal);
    finally
      Ini.Free;
    end;

    if FSelectedMethod = rmVkBasalt then
      Tgoverlayform(FForm).SaveVkBasaltConfig;
  end;
end;

end.
