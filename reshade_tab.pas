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

  { TReshadeTabHelper }

  TReshadeTabHelper = class
  private
    FForm: TForm;
    FScrollBox: TScrollBox;
    FBgPanel: TPanel;

    // Cards
    FStatusCard: TPanel;
    FShadersCard: TPanel;
    FConfigCard: TPanel;

    // Card 1: Config
    FConfigTitleLbl: TLabel;
    FEnableCheckBox: TCheckBox;
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
    FStatDot: TShape;
    FStatNameLbl: TLabel;
    FStatVerLbl: TLabel;
    FUpdateBtn: TBitBtn;

    function IsLoading: Boolean;
    procedure OnPackActionClick(Sender: TObject);
    procedure OnUpdateBtnClick(Sender: TObject);
    procedure OnOpenShadersBtnClick(Sender: TObject);
    procedure OnEnableChange(Sender: TObject);
    procedure OnHotkeyChange(Sender: TObject);
    procedure OnProxyChange(Sender: TObject);
    function MkCard(ATop, AHeight: Integer): TPanel;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;

    procedure BuildReShadeTab;
    procedure ReflowReShadeTab(AContentW: Integer);
    procedure RefreshStatus;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure BeginLoad;
    procedure EndLoad;
    procedure ApplyCapturedKey(AKey: Word; AShift: TShiftState);
    procedure SyncHotkeyUI;

    property StatusCard: TPanel read FStatusCard;
    property ShadersCard: TPanel read FShadersCard;
    property ConfigCard: TPanel read FConfigCard;
    property UpdateBtn: TBitBtn read FUpdateBtn;
    property OpenShadersBtn: TBitBtn read FOpenShadersBtn;
    property EnableCheckBox: TCheckBox read FEnableCheckBox;
    property ProxyComboBox: TComboBox read FProxyComboBox;
    property HotkeyComboBox: TComboBox read FHotkeyComboBox;
    property ToggleBtn: TBitBtn read FToggleBtn;
    property StatDot: TShape read FStatDot;
    property StatNameLbl: TLabel read FStatNameLbl;
    property StatVerLbl: TLabel read FStatVerLbl;
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
      CheckFile: 'AstrayFX/Depth_Alpha.fx';
      Description: 'Cinematic depth effects, volumetric lighting, and advanced perspective controls.'
    ),
    (
      ID: 'prod80';
      Name: 'Prod80 Color Grading';
      RepoUrl: 'https://github.com/prod80/prod80-ReShade-Repository/archive/refs/heads/master.tar.gz';
      CheckFile: 'prod80_01A_RT_Correct_Color.fx';
      Description: 'Professional studio photography curves, saturation, film contrast, and balance filters.'
    )
  );

implementation

uses
  overlayunit, optiscaler_tab, optiscaler_update, bgmod_resources, IniFiles, FileUtil;

const
  CARD_P = 16;
  CARD_GAP = 12;

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
    FHelper.RefreshStatus;
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
end;

destructor TReshadeTabHelper.Destroy;
begin
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
  Card.Left := CARD_P;
  Card.Width := Max(200, FBgPanel.Width - (CARD_P * 2));
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
begin
  MainForm := Tgoverlayform(FForm);
  if not Assigned(MainForm) or not Assigned(MainForm.reshadeTabSheet) then Exit;

  IsLight := CurrentTheme = tmLight;
  BgClr := IfThen(IsLight, $00F0F0F0, RGBToColor(22, 25, 37));
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

  // Background Container
  FBgPanel := TPanel.Create(FScrollBox);
  FBgPanel.Parent := FScrollBox;
  FBgPanel.BevelOuter := bvNone;
  FBgPanel.Color := BgClr;
  FBgPanel.Caption := '';
  FBgPanel.Left := 0;
  FBgPanel.Top := 0;
  FBgPanel.Width := FScrollBox.ClientWidth;
  FBgPanel.Height := 580;

  // ----------------------------------------------------
  // Card 1: Config (Top: 10, Height: 134)
  // ----------------------------------------------------
  FConfigCard := MkCard(10, 134);

  FConfigTitleLbl := TLabel.Create(FConfigCard);
  FConfigTitleLbl.Parent := FConfigCard;
  StyleMainCard(FConfigCard, FConfigTitleLbl, 'Config');

  FEnableCheckBox := TCheckBox.Create(FConfigCard);
  FEnableCheckBox.Parent := FConfigCard;
  FEnableCheckBox.Caption := 'Enable ReShade';
  FEnableCheckBox.Font.Color := TxtClr;
  FEnableCheckBox.Font.Style := [fsBold];
  FEnableCheckBox.SetBounds(CARD_P, 36, 240, 24);
  FEnableCheckBox.OnChange := @OnEnableChange;

  FToggleTitleLbl := TLabel.Create(FConfigCard);
  FToggleTitleLbl.Parent := FConfigCard;
  FToggleTitleLbl.Caption := 'Toggle:';
  FToggleTitleLbl.Font.Color := TxtClr;
  FToggleTitleLbl.SetBounds(CARD_P, 70, 180, 20);

  FToggleBtn := TBitBtn.Create(FConfigCard);
  FToggleBtn.Parent := FConfigCard;
  FToggleBtn.Tag := 7;
  FToggleBtn.Anchors := [akLeft, akTop];
  FToggleBtn.Cursor := crHandPoint;
  FToggleBtn.OnClick := @MainForm.CaptureBtnClick;
  FToggleBtn.SetBounds(210, 66, 120, 28);
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
  FHotkeyComboBox.SetBounds(210, 66, 220, 28);

  FProxyTitleLbl := TLabel.Create(FConfigCard);
  FProxyTitleLbl.Parent := FConfigCard;
  FProxyTitleLbl.Caption := 'Default Proxy DLL:';
  FProxyTitleLbl.Font.Color := TxtClr;
  FProxyTitleLbl.SetBounds(CARD_P, 104, 180, 20);

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
  FProxyComboBox.SetBounds(210, 100, 220, 28);
  FProxyComboBox.Hint := 'OptiScaler Co-existence: When OptiScaler is active on dxgi.dll, ReShade is chained via OptiScaler.ini [ReShade] loader automatically.';
  FProxyComboBox.ShowHint := True;

  // ----------------------------------------------------
  // Card 2: Shaders (Top: 154, Height: 330)
  // ----------------------------------------------------
  FShadersCard := MkCard(154, 330);

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
  // Card 3: Software status (Top: 494, Height: 68)
  // ----------------------------------------------------
  FStatusCard := MkCard(494, 68);

  FStatusTitleLbl := TLabel.Create(FStatusCard);
  FStatusTitleLbl.Parent := FStatusCard;
  StyleMainCard(FStatusCard, FStatusTitleLbl, 'Software status');

  FUpdateBtn := TBitBtn.Create(FStatusCard);
  FUpdateBtn.Parent := FStatusCard;
  FUpdateBtn.Caption := 'Check / Update ReShade';
  FUpdateBtn.Cursor := crHandPoint;
  FUpdateBtn.OnClick := @OnUpdateBtnClick;
  FUpdateBtn.SetBounds(Max(300, FStatusCard.Width - CARD_P - 180), 6, 180, 26);
  StyleActionButton(FUpdateBtn);

  FStatDot := TShape.Create(FStatusCard);
  FStatDot.Parent := FStatusCard;
  FStatDot.Shape := stEllipse;
  FStatDot.Brush.Color := $00666666;
  FStatDot.Pen.Style := psClear;
  FStatDot.SetBounds(CARD_P, 42, 8, 8);

  FStatNameLbl := TLabel.Create(FStatusCard);
  FStatNameLbl.Parent := FStatusCard;
  FStatNameLbl.Caption := 'ReShade';
  FStatNameLbl.Font.Color := $AAAAAA;
  FStatNameLbl.Font.Size := 9;
  FStatNameLbl.Font.Style := [fsBold];
  FStatNameLbl.AutoSize := True;
  FStatNameLbl.Transparent := True;
  FStatNameLbl.Left := CARD_P + 14;
  FStatNameLbl.Top := 37;

  FStatVerLbl := TLabel.Create(FStatusCard);
  FStatVerLbl.Parent := FStatusCard;
  FStatVerLbl.Caption := '—';
  FStatVerLbl.Font.Color := $00666666;
  FStatVerLbl.Font.Size := 9;
  FStatVerLbl.AutoSize := True;
  FStatVerLbl.Transparent := True;
  FStatVerLbl.Left := FStatNameLbl.Left + 65;
  FStatVerLbl.Top := 37;

  LoadConfig;
  RefreshStatus;
end;

procedure TReshadeTabHelper.ReflowReShadeTab(AContentW: Integer);
var
  TargetCardW, i: Integer;
begin
  if not Assigned(FBgPanel) or not Assigned(FScrollBox) then Exit;

  FBgPanel.Width := FScrollBox.ClientWidth;
  if Assigned(FStatusCard) then
    FBgPanel.Height := Max(FScrollBox.ClientHeight, FStatusCard.Top + FStatusCard.Height + 10);
  TargetCardW := Max(200, FBgPanel.Width - (CARD_P * 2));

  if Assigned(FConfigCard) then FConfigCard.Width := TargetCardW;
  if Assigned(FShadersCard) then
  begin
    FShadersCard.Width := TargetCardW;
    if Assigned(FOpenShadersBtn) then
      FOpenShadersBtn.Left := Max(150, TargetCardW - CARD_P - FOpenShadersBtn.Width);
  end;
  if Assigned(FStatusCard) then
  begin
    FStatusCard.Width := TargetCardW;
    if Assigned(FUpdateBtn) then
      FUpdateBtn.Left := Max(300, TargetCardW - CARD_P - FUpdateBtn.Width);
    if Assigned(FStatNameLbl) and Assigned(FStatVerLbl) then
      FStatVerLbl.Left := FStatNameLbl.Left + FStatNameLbl.Width + 12;
  end;

  for i := 0 to Length(FPackPanels) - 1 do
  begin
    if Assigned(FPackPanels[i]) then
    begin
      FPackPanels[i].Width := TargetCardW - (CARD_P * 2);
      if Assigned(FPackActionBtns[i]) then
        FPackActionBtns[i].Left := FPackPanels[i].Width - 120;
      if Assigned(FPackStatusLbls[i]) then
        FPackStatusLbls[i].Left := FPackPanels[i].Width - 230;
      if Assigned(FPackDescLbls[i]) then
        FPackDescLbls[i].Width := Max(100, FPackPanels[i].Width - 250);
    end;
  end;
end;

procedure TReshadeTabHelper.RefreshStatus;
const
  CLR_OK   = $0044BB44;   // green — library found
  CLR_NONE = $00666666;   // gray  — not installed
  PURPLE   = $BB99FF;
var
  BinDir, ShadersDir, CheckPath: string;
  i: Integer;
  IsInstalled, HasDll: Boolean;
begin
  BinDir := IncludeTrailingPathDelimiter(GetReShadeBinPath);
  ShadersDir := IncludeTrailingPathDelimiter(GetReShadeShadersPath);

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
  end;

  for i := 0 to RESHADE_PACK_COUNT - 1 do
  begin
    CheckPath := ShadersDir + 'Shaders' + PathDelim + RESHADE_PACKS[i].CheckFile;
    IsInstalled := FileExists(CheckPath) or (DirectoryExists(ShadersDir + 'Shaders') and (i = 0));

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

procedure TReshadeTabHelper.OnEnableChange(Sender: TObject);
begin
  if FLoading then Exit;
  SaveConfig;
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
  KeyVal, ProxyVal: string;
begin
  FLoading := True;
  try
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

        FEnableCheckBox.Checked := Ini.ReadString('GOVERLAY', 'Enabled', '0') = '1';
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
          FEnableCheckBox.Checked := Ini.ReadString('Config', 'GOVERLAY_RESHADE', '0') = '1';
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
    Ini.WriteString('GOVERLAY', 'Enabled', BoolToStr(FEnableCheckBox.Checked, '1', '0'));
  finally
    Ini.Free;
  end;

  if Assigned(FForm) and (FForm is Tgoverlayform) then
  begin
    ConfPath := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName) + 'bgmod.conf';
    ForceDirectories(ExtractFilePath(ConfPath));
    Ini := TIniFile.Create(ConfPath);
    try
      Ini.WriteString('Config', 'GOVERLAY_RESHADE', BoolToStr(FEnableCheckBox.Checked, '1', '0'));
      Ini.WriteString('Config', 'RESHADE_DLL', ProxyVal);
    finally
      Ini.Free;
    end;
  end;
end;

end.
