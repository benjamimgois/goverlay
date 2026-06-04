unit home_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, Process, LCLIntf,
  themeunit, constants, hintsunit, apputils, overlayunit, systemdetector, optiscaler_update, StrUtils, FileUtil, Types,
  ComCtrls, goverlay_system, Math;

type
  THomeTabHelper = class
  private
    FForm: Tgoverlayform;
  public
    constructor Create(AForm: Tgoverlayform);
    procedure InitHomeTab;
    procedure ShowHomeTab(Sender: TObject = nil);
    procedure RefreshHomeModuleStatus;
    procedure RefreshHomeOptiStatus;
    procedure RefreshHomeDeps;
    procedure HomeDiagramPaint(Sender: TObject);
    procedure HomeBtnRowResize(Sender: TObject);
    procedure HomeGlobalBtnClick(Sender: TObject);
    procedure HomeGameBtnClick(Sender: TObject);
    procedure HomeGlobalBtnEnter(Sender: TObject);
    procedure HomeGlobalBtnLeave(Sender: TObject);
    procedure HomeGameBtnEnter(Sender: TObject);
    procedure HomeGameBtnLeave(Sender: TObject);
    procedure ClearConfigBtnClick(Sender: TObject);
    procedure ClearConfigBtnEnter(Sender: TObject);
    procedure ClearConfigBtnLeave(Sender: TObject);
    procedure HomeChannelComboChange(Sender: TObject);
    function  GetMangoHudVersion: string;
    function  GetVkBasaltVersion: string;
    function  GetVkSumiVersion: string;
    function  FindBinPath(const BinName: string): string;
    function  FindLibPath(const LibName: string): string;
  end;

implementation

constructor THomeTabHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;

procedure THomeTabHelper.InitHomeTab;
const
  CARD_M     = 16;
  CARD_P     = 18;   // padding inside card (left content margin)
  ROW_H      = 32;
  DOT_SZ     = 14;
  SEC_GAP    = 14;
  COL_W      = 200;
  ACCENT_W   = 4;    // left accent bar width
  // accent colors per section
  ACC_MOD    = $004488CC;  // blue  — Module Status
  ACC_DEP    = $0033AA55;  // green — Dependencies
  ACC_SYS    = $00CC8844;  // orange — System Info
var
  BG, CARD_BG, TXT_CLR, MUTED_CLR: TColor;

  DEP_NAMES: array[0..5] of string = (
    '7z', 'curl', 'git', 'gamemode', 'qt6pas', 'Nerd Fonts');
  MOD_NAMES: array[0..3] of string = ('MangoHud', 'vkBasalt', 'OptiScaler', 'vkSumi');

var
  Content:   ExtCtrls.TPanel;
  Card:      ExtCtrls.TPanel;
  BtnRow:    ExtCtrls.TPanel;
  AccBar:    ExtCtrls.TShape;
  Lbl:       StdCtrls.TLabel;
  Ico:       ExtCtrls.TImage;
  IconFile:  string;
  Sep:       ExtCtrls.TBevel;
  i, Row, Y, ColX: Integer;
  Dot:       ExtCtrls.TShape;

  function MkCard(AY, AH: Integer): ExtCtrls.TPanel;
  begin
    Result := ExtCtrls.TPanel.Create(FForm);
    Result.Parent     := Content;
    Result.BevelOuter := bvNone;
    Result.Color      := CARD_BG;
    Result.Caption    := '';
    Result.Tag        := 9998;
    Result.Left       := CARD_M;
    Result.Top        := AY;
    Result.Height     := AH;
    Result.Anchors    := [akLeft, akTop, akRight];
    Result.AnchorSideRight.Control := Content;
    Result.AnchorSideRight.Side    := asrRight;
    Result.BorderSpacing.Right     := CARD_M;
  end;

  // Colored left accent bar spanning the full card height
  procedure MkAccent(ACard: ExtCtrls.TPanel; AColor: TColor);
  begin
    AccBar := ExtCtrls.TShape.Create(FForm);
    AccBar.Parent      := ACard;
    AccBar.Shape       := stRectangle;
    AccBar.Brush.Color := AColor;
    AccBar.Pen.Style   := psClear;
    AccBar.Left        := 0;
    AccBar.Top         := 0;
    AccBar.Width       := ACCENT_W;
    AccBar.Height      := ACard.Height;
    AccBar.Anchors     := [akLeft, akTop, akBottom];
  end;

  function MkTitle(AParent: Controls.TWinControl; const AText: string; AY: Integer): StdCtrls.TLabel;
  begin
    Result := StdCtrls.TLabel.Create(FForm);
    Result.Parent     := AParent;
    Result.Caption    := AText;
    Result.Font.Bold  := True;
    Result.Font.Color := TXT_CLR;
    Result.Font.Size  := 10;
    Result.Left       := CARD_P;
    Result.Top        := AY;
    Result.AutoSize   := True;
  end;

  procedure MkSep(AParent: Controls.TWinControl; AY: Integer);
  begin
    Sep := ExtCtrls.TBevel.Create(FForm);
    Sep.Parent  := AParent;
    Sep.Style   := bsLowered;
    Sep.Shape   := bsTopLine;
    Sep.Left    := CARD_P;
    Sep.Top     := AY;
    Sep.Height  := 2;
    Sep.Anchors := [akLeft, akTop, akRight];
    Sep.AnchorSideRight.Control := AParent;
    Sep.AnchorSideRight.Side    := asrRight;
    Sep.BorderSpacing.Right     := CARD_P;
  end;

  function MkDot(AParent: Controls.TWinControl; AX, AY: Integer): ExtCtrls.TShape;
  begin
    Result := ExtCtrls.TShape.Create(FForm);
    Result.Parent      := AParent;
    Result.Shape       := stEllipse;
    Result.Brush.Color := $00888888;
    Result.Pen.Style   := psClear;
    Result.SetBounds(AX, AY, DOT_SZ, DOT_SZ);
  end;

  function MkBtnLabel(AParent: Controls.TWinControl; const ACaption: string;
    AFontSize: Integer; AColor: TColor; AFontName: string = ''): StdCtrls.TLabel;
  begin
    Result := StdCtrls.TLabel.Create(FForm);
    Result.Parent     := AParent;
    Result.Caption    := ACaption;
    Result.Alignment  := taCenter;
    Result.Layout     := tlCenter;
    Result.Align      := alTop;
    Result.Font.Size  := AFontSize;
    Result.Font.Color := AColor;
    if AFontName <> '' then Result.Font.Name := AFontName;
    Result.Cursor     := crHandPoint;
  end;

begin
  with FForm do
  begin
    // ── Theme-aware colors ──────────────────────────────────────────────────
    if CurrentTheme = tmLight then
    begin
      BG       := LighterBackgroundColor;  // $F5F5F5
      CARD_BG  := LightBackgroundColor;    // clWhite
      TXT_CLR  := LightTextColor;          // clBlack
      MUTED_CLR := $00606060;              // grey
    end
    else
    begin
      BG       := $001A1A1A;
      CARD_BG  := $00222222;
      TXT_CLR  := clWhite;
      MUTED_CLR := clSilver;
    end;

    // ── Tab sheet ────────────────────────────────────────────────────────────
    FHomeTabSheet := ComCtrls.TTabSheet.Create(goverlayPageControl);
    FHomeTabSheet.PageControl := goverlayPageControl;
    FHomeTabSheet.Caption     := 'Home';
    FHomeTabSheet.TabVisible  := False;
    FHomeTabSheet.Color       := BG;

    // ── Content panel fills the tab — no ScrollBox needed ────────────────────
    Content := ExtCtrls.TPanel.Create(FForm);
    Content.Parent    := FHomeTabSheet;
    Content.BevelOuter := bvNone;
    Content.Color     := BG;
    Content.Caption   := '';
    Content.Align     := alClient;

    Y    := CARD_M;

    // ── System (List) ────────────────────────────────────────────────────────
    Card := MkCard(Y, CARD_P * 2 + 24 + 5 * ROW_H + 8);
    MkTitle(Card, 'System', CARD_P);

    // Clear Configuration button (right side of System card)
    FClearConfigBtn := ExtCtrls.TPanel.Create(FForm);
    FClearConfigBtn.Parent      := Card;
    FClearConfigBtn.BevelOuter  := bvNone;
    FClearConfigBtn.BevelInner  := bvNone;
    FClearConfigBtn.ParentColor := True;     // transparent (matches card background)
    FClearConfigBtn.Caption     := 'Clear configuration';
    FClearConfigBtn.Font.Name   := 'Noto Sans';
    FClearConfigBtn.Font.Size   := 8;
    FClearConfigBtn.Font.Color  := TXT_CLR;
    FClearConfigBtn.Alignment   := taCenter;
    FClearConfigBtn.Cursor      := crHandPoint;
    FClearConfigBtn.Anchors     := [akTop, akRight];
    FClearConfigBtn.SetBounds(Card.Width - 140 - CARD_P, CARD_P, 140, 22);
    FClearConfigBtn.OnClick     := @ClearConfigBtnClick;
    FClearConfigBtn.OnMouseEnter:= @ClearConfigBtnEnter;
    FClearConfigBtn.OnMouseLeave:= @ClearConfigBtnLeave;

    MkSep(Card, CARD_P + 22);

    for i := 0 to 4 do
    begin
      Row  := CARD_P + 30 + i * ROW_H;
      ColX := CARD_P;

      Ico := ExtCtrls.TImage.Create(FForm);
      Ico.Parent := Card;
      Ico.Width  := 22;
      Ico.Height := 22;
      Ico.Left   := ColX;
      Ico.Top    := Row + (ROW_H - 22) div 2;
      Ico.Proportional := True;
      Ico.Center := True;
      Ico.Transparent := True;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      IconFile := '';
      case i of
        0: 
        begin 
          IconFile := 'data/icons/system/os.png'; 
          Lbl.Caption := GetSysLinuxDistribution + ' (' + GetKernelVersion + ')'; 
          Ico.Hint := 'OS / Kernel'; 
        end;
        1: 
        begin 
          IconFile := 'data/icons/system/cpu.png'; 
          Lbl.Caption := GetSysCPUModel; 
          Ico.Hint := 'CPU'; 
        end;
        2: 
        begin 
          IconFile := 'data/icons/system/gpu.png'; 
          Lbl.Caption := GetSysGPUModel; 
          Ico.Hint := 'GPU'; 
        end;
        3: 
        begin 
          IconFile := 'data/icons/system/driver.png'; 
          Lbl.Caption := GetSysGPUDriver; 
          Ico.Hint := 'Driver'; 
        end;
        4: 
        begin 
          IconFile := 'data/icons/system/package.png'; 
          Lbl.Caption := GetGOverlayInstallationType; 
          Ico.Hint := 'Installation'; 
        end;
      end;
      WriteLn(StdErr, '[HomeIcon] system icon="', IconFile, '" full="', GetAppBaseDir + IconFile, '" exists=', FileExists(GetAppBaseDir + IconFile));
      if FileExists(GetAppBaseDir + IconFile) then
        Ico.Picture.LoadFromFile(GetAppBaseDir + IconFile);

      Lbl.Font.Color := TXT_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := ColX + DOT_SZ + 16;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
      Lbl.ShowHint   := True;
      Lbl.Hint       := Lbl.Caption;
      Ico.ShowHint   := True;
    end;
    Inc(Y, Card.Height + SEC_GAP);

    // ── Libraries ────────────────────────────────────────────────────────────
    Card := MkCard(Y, CARD_P * 2 + 24 + 4 * ROW_H + 4);
    MkTitle(Card, 'Libraries', CARD_P);
    MkSep(Card, CARD_P + 22);

    // Module rows (MangoHud, vkBasalt, OptiScaler, vkSumi)
    for i := 0 to 3 do
    begin
      Row := CARD_P + 30 + i * ROW_H;
      Dot := MkDot(Card, CARD_P, Row + (ROW_H - DOT_SZ) div 2);
      Dot.ShowHint := True;
      FHomeModDots[i] := Dot;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := MOD_NAMES[i];
      Lbl.Font.Color := TXT_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := CARD_P + DOT_SZ + 8;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
      Lbl.ShowHint   := True;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := '—';
      Lbl.Font.Color := MUTED_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := CARD_P + DOT_SZ + 8 + 110;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
      Lbl.ShowHint   := True;
      FHomeModVerLbls[i] := Lbl;
    end;
    Inc(Y, Card.Height + SEC_GAP);

    // ── Card 2: Dependencies (3×2 grid) ──────────────────────────────────────
    Card := MkCard(Y, CARD_P * 2 + 24 + 2 * ROW_H + 8);
    MkTitle(Card, 'Dependencies', CARD_P);
    MkSep(Card, CARD_P + 22);

    for i := 0 to 5 do
    begin
      Row  := CARD_P + 30 + (i div 3) * ROW_H;
      ColX := CARD_P + (i mod 3) * COL_W;

      Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
      Dot.ShowHint := True;
      FHomeDepDots[i] := Dot;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := DEP_NAMES[i];
      Lbl.Font.Color := TXT_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := ColX + DOT_SZ + 6;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.Width      := COL_W - DOT_SZ - 10;
      Lbl.AutoSize   := False;
      Lbl.ShowHint   := True;
      FHomeDepLbls[i] := Lbl;
    end;
    Inc(Y, Card.Height + SEC_GAP);
  end;
end;

procedure THomeTabHelper.ShowHomeTab(Sender: TObject);
begin
  with FForm do
  begin
    SetNavActive(-1);

    goverlayPageControl.ShowTabs := False;
    vkbasalttabsheet.TabVisible  := False;
    vksumiTabSheet.TabVisible    := False;
    optiscalertabsheet.TabVisible := False;
    tweakstabsheet.TabVisible    := False;
    gamesTabSheet.TabVisible     := False;
    FHomeTabSheet.TabVisible     := True;
    goverlayPageControl.ActivePage := FHomeTabSheet;

    notificationLabel.Visible := False;
    commandPanel.Visible       := False;

    geSpeedButton.Visible     := False;
    geLabel.Visible           := False;
    goverlaybarPanel.Visible  := False;

    // Refresh all home tab sections
    Self.RefreshHomeOptiStatus;
    Self.RefreshHomeModuleStatus;
    Self.RefreshHomeDeps;
  end;
end;

procedure THomeTabHelper.RefreshHomeModuleStatus;
const
  CLR_OK      = $0044BB44;  // green
  CLR_MISSING = $004444BB;  // red
var
  Missing: TStringList;
  MangoOK, VkOK, OptiOK, SumiOK: Boolean;
  MangoVer, VkVer, SumiVer: string;
begin
  with FForm do
  begin
    if not Assigned(FHomeModDots[0]) then Exit;

    CheckDependencies(Missing);
    try
      MangoOK := (Missing.IndexOf('mangohud') < 0) and
                 (Missing.IndexOf('MangoHud runtime 25.08') < 0);
      VkOK    := (Missing.IndexOf('vkbasalt') < 0) and
                 (Missing.IndexOf('vkBasalt runtime 25.08') < 0);
      OptiOK  := FForm.IsOptiScalerInstalled;
      SumiOK  := (Missing.IndexOf('vksumi') < 0);
    finally
      Missing.Free;
    end;

    FHomeModDots[0].Brush.Color := Math.IfThen(MangoOK, CLR_OK, CLR_MISSING);
    FHomeModDots[1].Brush.Color := Math.IfThen(VkOK,    CLR_OK, CLR_MISSING);
    FHomeModDots[2].Brush.Color := Math.IfThen(OptiOK,  CLR_OK, CLR_MISSING);
    FHomeModDots[3].Brush.Color := Math.IfThen(SumiOK,  CLR_OK, CLR_MISSING);

    MangoVer := Self.GetMangoHudVersion;
    if MangoVer = '' then MangoVer := StrUtils.IfThen(MangoOK, 'installed', 'not found');
    FHomeModVerLbls[0].Caption := MangoVer;

    VkVer := Self.GetVkBasaltVersion;
    if VkVer = '' then VkVer := StrUtils.IfThen(VkOK, 'installed', 'not found');
    FHomeModVerLbls[1].Caption := VkVer;

    if OptiOK and Assigned(optlabel1) and (optlabel1.Caption <> '') then
      FHomeModVerLbls[2].Caption := optlabel1.Caption
    else if OptiOK then
      FHomeModVerLbls[2].Caption := 'installed'
    else
      FHomeModVerLbls[2].Caption := 'not found';

    SumiVer := Self.GetVkSumiVersion;
    if SumiVer = '' then SumiVer := StrUtils.IfThen(SumiOK, 'installed', 'not found');
    FHomeModVerLbls[3].Caption := SumiVer;
  end;
end;

procedure THomeTabHelper.RefreshHomeOptiStatus;
const
  CLR_OK   = $0044BB44;
  CLR_NONE = $00666666;

  procedure SetLib(Idx: Integer; SrcLbl: StdCtrls.TLabel);
  var Ver: string;
  begin
    with FForm do
    begin
      if not Assigned(FHomeOptiLbls[Idx]) then Exit;
      Ver := '';
      if Assigned(SrcLbl) then Ver := SrcLbl.Caption;
      FHomeOptiLbls[Idx].Caption := StrUtils.IfThen(Ver <> '', Ver, '—');
      if Assigned(FHomeLibDots[Idx]) then
        FHomeLibDots[Idx].Brush.Color := Math.IfThen((Ver <> '') and (Ver <> '--'), CLR_OK, CLR_NONE);
    end;
  end;

begin
  with FForm do
  begin
    // Update OptiScaler version in module status
    if Assigned(FHomeModVerLbls[2]) and Assigned(optlabel1) and (optlabel1.Caption <> '') then
      FHomeModVerLbls[2].Caption := optlabel1.Caption;

    // Library sub-rows: FakeNvAPI[0], Optipatcher[1], FSR[2], XeSS[3], DLSS[4]
    SetLib(0, fakenvapi1);
    SetLib(1, optipatcherLabel1);
    SetLib(2, fsrlabel1);
    SetLib(3, xessLabel1);
    SetLib(4, dlssLabel1);
  end;
end;

procedure THomeTabHelper.RefreshHomeDeps;
const
  DEP_KEYS: array[0..5] of string = (
    'p7zip', 'curl', 'git', 'gamemode', 'libqt6pas', 'nerdfonts');
  DEP_DISPLAY: array[0..5] of string = (
    '7z (p7zip)', 'curl', 'git', 'gamemode', 'qt6pas', 'Nerd Fonts');
  DEP_HINTS: array[0..5] of string = (
    'Archive tool required for OptiScaler extraction',
    'HTTP client used to download OptiScaler updates and covers',
    'Version control used to fetch fgmod scripts',
    'Feral GameMode daemon for CPU/GPU optimisation',
    'Qt6 Pascal bindings — required for the Goverlay GUI',
    'Nerd Font (e.g. ttf-nerd-fonts-symbols) — required for UI icons');
  CLR_OK      = $0044BB44;
  CLR_MISSING = $004444BB;  // RGB(187,68,68) — red in Lazarus BGR format
var
  Missing: TStringList;
  i: Integer;
begin
  with FForm do
  begin
    if not Assigned(FHomeDepDots[0]) then Exit;
    CheckDependencies(Missing);
    try
      for i := 0 to 5 do
      begin
        FHomeDepDots[i].Hint := DEP_HINTS[i];
        FHomeDepLbls[i].Hint := DEP_HINTS[i];
        if Missing.IndexOf(DEP_KEYS[i]) >= 0 then
        begin
          FHomeDepDots[i].Brush.Color := CLR_MISSING;
          FHomeDepDots[i].Pen.Color   := CLR_MISSING;
          FHomeDepLbls[i].Font.Color  := $00888888;
        end
        else
        begin
          FHomeDepDots[i].Brush.Color := CLR_OK;
          FHomeDepDots[i].Pen.Color   := CLR_OK;
          if CurrentTheme = tmLight then
            FHomeDepLbls[i].Font.Color := LightTextColor
          else
            FHomeDepLbls[i].Font.Color := clWhite;
        end;
      end;
    finally
      Missing.Free;
    end;
  end;
end;

procedure THomeTabHelper.HomeDiagramPaint(Sender: TObject);
const
  R = 40;
var
  Box: ExtCtrls.TPaintBox;
  Cv: Graphics.TCanvas;
  W, H, CX: Integer;
  PTop, PBL, PBR: TPoint;

  procedure DrawArrow(A, B: TPoint);
  var
    dx, dy, Len, nx, ny: Double;
    A2, B2: TPoint;
    px, py: Integer;
  begin
    dx := B.X - A.X; dy := B.Y - A.Y;
    Len := Sqrt(dx * dx + dy * dy);
    if Len < 1 then Exit;
    nx := dx / Len; ny := dy / Len;
    A2 := Point(A.X + Round(nx * R) + 2, A.Y + Round(ny * R) + 2);
    B2 := Point(B.X - Round(nx * R) - 2, B.Y - Round(ny * R) - 2);
    Cv.Pen.Color := $00888888;
    Cv.Pen.Width := 1;
    Cv.MoveTo(A2.X, A2.Y); Cv.LineTo(B2.X, B2.Y);
    // Arrow head at B2
    px := Round(nx * 8); py := Round(ny * 8);
    Cv.MoveTo(B2.X, B2.Y);
    Cv.LineTo(B2.X - px + Round(ny * 5), B2.Y - py - Round(nx * 5));
    Cv.MoveTo(B2.X, B2.Y);
    Cv.LineTo(B2.X - px - Round(ny * 5), B2.Y - py + Round(nx * 5));
    // Arrow head at A2
    Cv.MoveTo(A2.X, A2.Y);
    Cv.LineTo(A2.X + px + Round(ny * 5), A2.Y + py - Round(nx * 5));
    Cv.MoveTo(A2.X, A2.Y);
    Cv.LineTo(A2.X + px - Round(ny * 5), A2.Y + py + Round(nx * 5));
  end;

  procedure DrawCircle(CCx, CCy: Integer; BgCol: TColor; const L1, L2: string);
  var tw1, tw2: Integer;
  begin
    Cv.Brush.Color := BgCol;
    Cv.Pen.Color   := BgCol;
    Cv.Ellipse(CCx - R, CCy - R, CCx + R, CCy + R);
    Cv.Brush.Style := bsClear;
    Cv.Font.Color  := clWhite;
    Cv.Font.Size   := 8;
    Cv.Font.Style  := [fsBold];
    tw1 := Cv.TextWidth(L1);
    tw2 := Cv.TextWidth(L2);
    Cv.TextOut(CCx - tw1 div 2, CCy - 12, L1);
    Cv.TextOut(CCx - tw2 div 2, CCy + 2,  L2);
    Cv.Brush.Style := bsSolid;
  end;

begin
  Box := ExtCtrls.TPaintBox(Sender);
  Cv  := Box.Canvas;
  W   := Box.Width;
  H   := Box.Height;
  Cv.Brush.Color := $00252525;
  Cv.FillRect(Rect(0, 0, W, H));
  CX   := W div 2;
  PTop := Point(CX,       R + 10);
  PBL  := Point(CX - 80,  H - R - 10);
  PBR  := Point(CX + 80,  H - R - 10);
  DrawArrow(PTop, PBL);
  DrawArrow(PTop, PBR);
  DrawArrow(PBL,  PBR);
  DrawCircle(PTop.X, PTop.Y, $003F8B3F, 'NVIDIA', 'DLSS');
  DrawCircle(PBL.X,  PBL.Y,  $00882222, 'AMD',    'FSR');
  DrawCircle(PBR.X,  PBR.Y,  $002266BB, 'intel.', 'XeSS');
end;

procedure THomeTabHelper.HomeBtnRowResize(Sender: TObject);
begin
  with FForm do
  begin
    if Assigned(FHomeGlobalBtn) and Assigned(FHomeBtnRow) then
      FHomeGlobalBtn.Width := (FHomeBtnRow.ClientWidth - 16) div 2;
  end;
end;

procedure THomeTabHelper.HomeGlobalBtnClick(Sender: TObject);
begin
  FForm.mangohudLabelClick(nil);
end;

procedure THomeTabHelper.HomeGameBtnClick(Sender: TObject);
begin
  FForm.gamesLabelClick(nil);
end;

procedure THomeTabHelper.HomeGlobalBtnEnter(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
    ExtCtrls.TPanel(Sender).Color := $00283060;
end;

procedure THomeTabHelper.HomeGlobalBtnLeave(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
    ExtCtrls.TPanel(Sender).Color := $00202040;
end;

procedure THomeTabHelper.HomeGameBtnEnter(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
    ExtCtrls.TPanel(Sender).Color := $00284028;
end;

procedure THomeTabHelper.HomeGameBtnLeave(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
    ExtCtrls.TPanel(Sender).Color := $00203020;
end;

procedure THomeTabHelper.ClearConfigBtnClick(Sender: TObject);
var
  UserDir: string;
  Paths: array of string;
  i: Integer;
  AllDeleted: Boolean;
begin
  if MessageDlg('Clear Configuration',
    'All files and settings will be removed and GOverlay will return to its initial configuration.' + sLineBreak + sLineBreak +
    'Do you want to continue?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  UserDir := IncludeTrailingPathDelimiter(GetUserDir);
  AllDeleted := True;

  // Build list of paths to delete (regular + Flatpak)
  SetLength(Paths, 4);
  Paths[0] := UserDir + '.local/share/goverlay';
  Paths[1] := UserDir + '.config/goverlay';
  Paths[2] := UserDir + '.var/app/io.github.benjamimgois.goverlay/data/goverlay';
  Paths[3] := UserDir + '.var/app/io.github.benjamimgois.goverlay/config/goverlay';

  for i := 0 to High(Paths) do
  begin
    if DirectoryExists(Paths[i]) then
    begin
      try
        DeleteDirectory(Paths[i], False);
        WriteLn('[ClearConfig] Deleted: ', Paths[i]);
      except
        on E: Exception do
        begin
          WriteLn('[ClearConfig] ERROR deleting ', Paths[i], ': ', E.Message);
          AllDeleted := False;
        end;
      end;
    end;
  end;

  if AllDeleted then
    ShowMessage('Configuration cleared successfully.' + sLineBreak +
                'Please restart GOverlay.')
  else
    ShowMessage('Some configuration folders could not be removed.' + sLineBreak +
                'Please check file permissions and restart GOverlay.');
end;

procedure THomeTabHelper.ClearConfigBtnEnter(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
  begin
    ExtCtrls.TPanel(Sender).ParentColor := False;
    ExtCtrls.TPanel(Sender).Color := $001A1A88;  // dark red on hover
  end;
end;

procedure THomeTabHelper.ClearConfigBtnLeave(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
    ExtCtrls.TPanel(Sender).ParentColor := True;  // transparent (back to card background)
end;

procedure THomeTabHelper.HomeChannelComboChange(Sender: TObject);
begin
  // No longer used (channel combo removed from Home tab)
end;

function THomeTabHelper.GetMangoHudVersion: string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('mangohud --version 2>&1 | head -1');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function THomeTabHelper.GetVkBasaltVersion: string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('pacman -Q vkbasalt 2>/dev/null | awk ''{print $2}'' || ' +
                     'dpkg-query -W -f=''${Version}'' vkbasalt 2>/dev/null || ' +
                     'rpm -q --qf ''%{VERSION}'' vkbasalt 2>/dev/null || echo ""');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function THomeTabHelper.GetVkSumiVersion: string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('pacman -Q vksumi 2>/dev/null | awk ''{print $2}'' || ' +
                     'dpkg-query -W -f=''${Version}'' vksumi 2>/dev/null || ' +
                     'rpm -q --qf ''%{VERSION}'' vksumi 2>/dev/null || echo ""');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function THomeTabHelper.FindBinPath(const BinName: string): string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := 'which';
    P.Parameters.Add(BinName);
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function THomeTabHelper.FindLibPath(const LibName: string): string;
var
  P: TProcess;
  S: TStringList;
  Line: string;
  ArrowPos: Integer;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('ldconfig -p 2>/dev/null | grep "' + LibName + '" | head -1');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then
        begin
          Line := Trim(S[0]);
          // Format: "  libFoo.so (libc6,x86-64) => /usr/lib/libFoo.so"
          ArrowPos := Pos('=>', Line);
          if ArrowPos > 0 then
            Result := Trim(Copy(Line, ArrowPos + 2, MaxInt));
        end;
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

end.
