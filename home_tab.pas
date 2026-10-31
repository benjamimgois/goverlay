unit home_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, Process, LCLIntf,
  themeunit, constants, hintsunit, apputils, overlayunit, systemdetector, optiscaler_update, bgmod_resources, StrUtils, FileUtil, Types,
  ComCtrls, goverlay_system, Math, goverlay_strings, overlay_config, configmanager;

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
    procedure RefreshHomeMakoStatus;
    procedure RefreshHomeDeps;
    procedure HomeDiagramPaint(Sender: TObject);
    procedure HomeCardPaint(Sender: TObject);
    procedure ClearConfigBtnPaint(Sender: TObject);
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
    procedure NicknameClick(Sender: TObject);
    procedure HomeChannelComboChange(Sender: TObject);
    function  GetMangoHudVersion: string;
    function  GetVkBasaltVersion: string;
    function  GetVkSumiVersion: string;
    function  GetLsfgVkVersion: string;
    function  GetMakoVersion: string;
    function  GetAfmfVersion: string;
    function  IsHelixSrInstalled: Boolean;
    function  GetHelixSrVersion: string;
    function  IsDlssEnablerInstalled: Boolean;
    function  GetDlssEnablerVersion: string;
    function  GetVkNemuVersion: string;
    procedure RefreshHomeVkNemuStatus;
    function  FindBinPath(const BinName: string): string;
    function  FindLibPath(const LibName: string): string;
  end;

implementation

uses
  lossless_scaling_tab;

constructor THomeTabHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;

procedure THomeTabHelper.InitHomeTab;
const
  CARD_M     = 8;
  CARD_P     = 14;   // padding inside card (left content margin)
  ROW_H      = 26;
  DOT_SZ     = 12;
  SEC_GAP    = 10;
  COL_W      = 360;  // 2-column width for Libraries and Dependencies
  ACCENT_W   = 4;    // left accent bar width
  // accent colors per section
  ACC_MOD    = $004488CC;  // blue  — Module Status
  ACC_DEP    = $0033AA55;  // green — Dependencies
  ACC_SYS    = $00CC8844;  // orange — System Info
var
  BG, CARD_BG, TXT_CLR, MUTED_CLR: TColor;

  DEP_NAMES: array[0..6] of string = (
    '7z', 'curl', 'git', 'gamemode',
    {$IFDEF LCLqt6}
    'qt6pas',
    {$ELSE}
    'qt5pas',
    {$ENDIF}
    'Nerd Fonts',
    'Korthos low latency');
  MOD_NAMES: array[0..11] of string = ('MangoHud', 'vkBasalt', 'OptiScaler', 'DLSS Enabler', 'vkSumi', 'lsfg-vk', 'MAKO', 'ReShade', 'afmf-linux', 'HelixSR', 'DLSS-NR', 'vkNemu');

var
  Content:   ExtCtrls.TPanel;
  Card:      ExtCtrls.TPanel;
  BtnRow:    ExtCtrls.TPanel;
  AccBar:    ExtCtrls.TShape;
  Lbl:       StdCtrls.TLabel;
  Ico:       ExtCtrls.TImage;
  IconFile:  string;
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
    Result.OnPaint    := @HomeCardPaint;
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
  var
    Line: ExtCtrls.TShape;
  begin
    Line := ExtCtrls.TShape.Create(FForm);
    Line.Parent := AParent;
    Line.Shape := stRectangle;
    Line.Pen.Style := psClear;
    if CurrentTheme = tmLight then
      Line.Brush.Color := RGBToColor(220, 224, 232)
    else
      Line.Brush.Color := RGBToColor(42, 50, 72);
    Line.Left := CARD_P;
    Line.Top := AY;
    Line.Height := 1;
    Line.Anchors := [akLeft, akTop, akRight];
    Line.AnchorSideRight.Control := AParent;
    Line.AnchorSideRight.Side := asrRight;
    Line.BorderSpacing.Right := CARD_P;
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
      BG        := LightBackgroundColor;
      CARD_BG   := RGBToColor(245, 246, 248);
      TXT_CLR   := LightTextColor;
      MUTED_CLR := $00606060;
    end
    else
    begin
      BG        := RGBToColor(22, 26, 40);
      CARD_BG   := RGBToColor(27, 32, 46);
      TXT_CLR   := clWhite;
      MUTED_CLR := RGBToColor(145, 155, 175);
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
    Card := MkCard(Y, CARD_P * 2 + 24 + 7 * ROW_H + 8);
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
    FClearConfigBtn.SetBounds(Card.Width - 146 - CARD_P, CARD_P - 2, 146, 24);
    FClearConfigBtn.OnClick     := @ClearConfigBtnClick;
    FClearConfigBtn.OnPaint     := @ClearConfigBtnPaint;
    FClearConfigBtn.OnMouseEnter:= @ClearConfigBtnEnter;
    FClearConfigBtn.OnMouseLeave:= @ClearConfigBtnLeave;

    MkSep(Card, CARD_P + 22);

    for i := 0 to 6 do
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
        5:
        begin
          IconFile := 'data/icons/system/fingerprint.png';
          Lbl.Caption := 'Client ID: ' + GetGoverlayClientID;
          Ico.Hint := 'Client ID';
        end;
        6:
        begin
          IconFile := 'data/icons/system/user.png';
          if GetUserNickname <> '' then
            Lbl.Caption := 'Pascube nickname: ' + GetUserNickname + '  [click to edit]'
          else
            Lbl.Caption := 'Pascube nickname: Anonymous  [click to set]';
          Ico.Hint := 'Click to set display nickname for leaderboards';
          Lbl.Cursor := crHandPoint;
          Ico.Cursor := crHandPoint;
          Lbl.OnClick := @NicknameClick;
          Ico.OnClick := @NicknameClick;
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
    Card := MkCard(Y, CARD_P * 2 + 24 + 6 * ROW_H + 4);
    MkTitle(Card, 'Libraries', CARD_P);
    MkSep(Card, CARD_P + 22);

    // Module rows (MangoHud, vkBasalt, OptiScaler, DLSS Enabler, vkSumi, lsfg-vk, MAKO, ReShade, afmf-linux, HelixSR, DLSS-NR, vkNemu)
    for i := 0 to 11 do
    begin
      ColX := CARD_P + (i div 6) * 360;
      Row := CARD_P + 30 + (i mod 6) * ROW_H;
      Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
      Dot.ShowHint := True;
      FHomeModDots[i] := Dot;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := MOD_NAMES[i];
      Lbl.Font.Color := TXT_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := ColX + DOT_SZ + 8;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
      Lbl.ShowHint   := True;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := '—';
      Lbl.Font.Color := MUTED_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := ColX + DOT_SZ + 8 + 110;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
      Lbl.ShowHint   := True;
      FHomeModVerLbls[i] := Lbl;
    end;
    Inc(Y, Card.Height + SEC_GAP);

    // ── Card 2: Dependencies (2 columns) ─────────────────────────────────────
    Card := MkCard(Y, CARD_P * 2 + 24 + 4 * ROW_H + 8);
    MkTitle(Card, 'Dependencies', CARD_P);
    MkSep(Card, CARD_P + 22);

    for i := 0 to 6 do
    begin
      ColX := CARD_P + (i div 4) * COL_W;
      Row  := CARD_P + 30 + (i mod 4) * ROW_H;

      Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
      Dot.ShowHint := True;
      FHomeDepDots[i] := Dot;

      Lbl := StdCtrls.TLabel.Create(FForm);
      Lbl.Parent     := Card;
      Lbl.Caption    := DEP_NAMES[i];
      Lbl.Font.Color := TXT_CLR;
      Lbl.Font.Size  := 9;
      Lbl.Left       := ColX + DOT_SZ + 8;
      Lbl.Top        := Row + (ROW_H - 16) div 2;
      Lbl.AutoSize   := True;
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
    if Assigned(reshadeTabSheet) then
      reshadeTabSheet.TabVisible := False;
    vksumiTabSheet.TabVisible    := False;
    optiscalertabsheet.TabVisible := False;
    losslessScalingTabSheet.TabVisible := False;
    tweakstabsheet.TabVisible    := False;
    if Assigned(launchArgsTabSheet) then
      launchArgsTabSheet.TabVisible := False;
    gamesTabSheet.TabVisible     := False;
    FHomeTabSheet.TabVisible     := True;
    goverlayPageControl.ActivePage := FHomeTabSheet;

    notificationLabel.Visible := False;
    commandPanel.Visible       := False;

    geSpeedButton.Visible     := False;
    geLabel.Visible           := False;
    goverlaybarPanel.Visible  := False;
    goverlayPageControl.BorderSpacing.Bottom := 0;

    if Assigned(FFADock) then
      FFADock.UpdateForTab(False, False, False, False);

    // Refresh all home tab sections
    Self.RefreshHomeOptiStatus;
    Self.RefreshHomeModuleStatus;
    Self.RefreshHomeDeps;
  end;
end;

procedure THomeTabHelper.RefreshHomeModuleStatus;
const
  CLR_OK       = $0044CC55;  // vibrant emerald green
  CLR_MISSING  = $005555EE;  // vibrant rose/coral red
var
  Missing: TStringList;
  HomeDir, UserLayerDir, XdgLayerDir, LocalLib, LocalBin: string;
  MangoOK, VkOK, OptiOK, DlssOK, SumiOK, LsfgOK, MakoOK, ReShadeOK, AfmfOK, HelixSrOK: Boolean;
  MangoSystem, VkSystem, OptiSystem, DlssSystem, SumiSystem, LsfgSystem, MakoSystem, ReShadeSystem, AfmfSystem, HelixSrSystem: Boolean;
  VkUser, SumiUser, LsfgUser, MakoUser, AfmfUser, VkNemuUser: Boolean;
  DlssNrOK, DlssNrReady, DlssNrSystem: Boolean;
  VkNemuOK, VkNemuSystem: Boolean;
  MangoVer, VkVer, OptiVer, DlssVer, SumiVer, LsfgVer, LsfgRemoteVer, MakoVer, MakoRemoteVer, AfmfVer, AfmfRemoteVer, HelixSrVer: string;
  ReShadeVer, DlssNrVer, VkNemuVer: string;

  procedure SetModuleStatus(AIndex: Integer; AInstalled, AIsSystem: Boolean; const AVersion: string);
  var
    HintText, DisplayVer: string;
  begin
    if not Assigned(FForm.FHomeModDots[AIndex]) then Exit;

    if AInstalled then
    begin
      FForm.FHomeModDots[AIndex].Brush.Color := CLR_OK;
      FForm.FHomeModDots[AIndex].Pen.Color   := CLR_OK;
      if AIsSystem then
        HintText := 'System package'
      else
        HintText := 'Installed in user space (GOverlay)';
      DisplayVer := AVersion;
      if DisplayVer = '' then
        DisplayVer := 'installed';
    end
    else
    begin
      FForm.FHomeModDots[AIndex].Brush.Color := CLR_MISSING;
      FForm.FHomeModDots[AIndex].Pen.Color   := CLR_MISSING;
      HintText := 'Not installed';
      DisplayVer := 'not found';
    end;

    FForm.FHomeModDots[AIndex].Hint := HintText;
    FForm.FHomeModDots[AIndex].ShowHint := True;

    if Assigned(FForm.FHomeModVerLbls[AIndex]) then
    begin
      FForm.FHomeModVerLbls[AIndex].Caption := DisplayVer;
      FForm.FHomeModVerLbls[AIndex].Font.Color := CLR_TEXT_MUTED;
      FForm.FHomeModVerLbls[AIndex].Hint := HintText;
      FForm.FHomeModVerLbls[AIndex].ShowHint := True;
    end;
  end;

begin
  with FForm do
  begin
    if not Assigned(FHomeModDots[0]) then Exit;

    HomeDir := IncludeTrailingPathDelimiter(GetUserDir);
    UserLayerDir := HomeDir + '.local/share/vulkan/implicit_layer.d/';
    XdgLayerDir := GetUserVulkanImplicitDir;
    LocalLib := HomeDir + '.local/lib/';
    LocalBin := HomeDir + '.local/bin/';

    Missing := FForm.GetCachedMissingDeps;

    // 0. MangoHud
    MangoOK := (Missing.IndexOf(DEP_MANGOHUD) < 0) and
               (Missing.IndexOf(DEP_MANGOHUD_RUNTIME) < 0);
    MangoSystem := MangoOK and not FileExists(LocalBin + 'mangohud');
    MangoVer := Self.GetMangoHudVersion;
    SetModuleStatus(0, MangoOK, MangoSystem, MangoVer);

    // 1. vkBasalt
    VkSystem := FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') or
                FileExists('/etc/vulkan/implicit_layer.d/vkBasalt.json') or
                FileExists('/usr/local/share/vulkan/implicit_layer.d/vkBasalt.json') or
                FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/x86_64-linux-gnu/vkbasalt/libvkbasalt.so') or
                FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/i386-linux-gnu/vkbasalt/libvkbasalt.so') or
                FileExists('/usr/lib/libvkbasalt.so') or
                FileExists('/usr/lib64/libvkbasalt.so') or
                FileExists('/usr/lib/x86_64-linux-gnu/libvkbasalt.so');
    VkUser := FileExists(UserLayerDir + 'vkBasalt.json') or
              FileExists(XdgLayerDir + 'vkBasalt.json') or
              DirectoryExists(LocalLib + 'vkbasalt');
    VkOK := VkSystem or VkUser or optiscaler_update.IsVkBasaltInstalled or
            ((Missing.IndexOf(DEP_VKBASALT) < 0) and (Missing.IndexOf(DEP_VKBASALT_RUNTIME) < 0));
    VkVer := Self.GetVkBasaltVersion;
    SetModuleStatus(1, VkOK, VkSystem, VkVer);

    // 2. OptiScaler
    OptiSystem := FileExists('/usr/share/optiscaler') or FileExists('/usr/lib/optiscaler');
    OptiOK := FForm.IsOptiScalerInstalled or OptiSystem;
    OptiVer := '';
    if OptiOK and Assigned(optlabel1) and (optlabel1.Caption <> '') then
      OptiVer := optlabel1.Caption;
    SetModuleStatus(2, OptiOK, OptiSystem, OptiVer);

    // 3. DLSS Enabler
    DlssSystem := FileExists('/usr/share/dlss-enabler') or FileExists('/usr/lib/dlss-enabler');
    DlssOK := Self.IsDlssEnablerInstalled or DlssSystem;
    DlssVer := Self.GetDlssEnablerVersion;
    SetModuleStatus(3, DlssOK, DlssSystem, DlssVer);

    // 4. vkSumi
    SumiSystem := VkSumiSystemLayersPresent;
    SumiUser := FileExists(UserLayerDir + 'vksumi.json') or
                FileExists(XdgLayerDir + 'vksumi.json') or
                FileExists(IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers/vksumi/libVkLayer_vksumi.so');
    SumiOK := SumiSystem or (SumiUser and IsVkSumiInstalled);
    SumiVer := Self.GetVkSumiVersion;
    SetModuleStatus(4, SumiOK, SumiSystem, SumiVer);

    // 5. lsfg-vk
    LsfgSystem := FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
                  FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
                  FileExists('/usr/local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
                  FileExists('/app/lib/extensions/vulkan/lsfgvk/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') or
                  FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') or
                  FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json');
    LsfgUser := FileExists(UserLayerDir + 'VkLayer_LSFGVK_frame_generation.json') or
                FileExists(XdgLayerDir + 'VkLayer_LSFGVK_frame_generation.json') or
                FileExists(UserLayerDir + 'VkLayer_LS_frame_generation.json') or
                FileExists(UserLayerDir + 'VkLayer_LSFGVK.json') or
                FileExists(LocalLib + 'liblsfg-vk-layer.so');
    LsfgOK := LsfgSystem or (LsfgUser and (IsLsfgVkInstalled or (Missing.IndexOf(DEP_LSFGVK) < 0)));
    LsfgVer := Self.GetLsfgVkVersion;
    while (LsfgVer <> '') and (LsfgVer[1] in ['v', 'V']) do
      Delete(LsfgVer, 1, 1);
    SetModuleStatus(5, LsfgOK, LsfgSystem, LsfgVer);

    LsfgRemoteVer := '';
    if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).LsfgUpdateAvailable then
      LsfgRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).LsfgRemoteVer;
    while (LsfgRemoteVer <> '') and (LsfgRemoteVer[1] in ['v', 'V']) do
      Delete(LsfgRemoteVer, 1, 1);
    if (LsfgRemoteVer <> '') and (LsfgVer <> '') and (LsfgRemoteVer <> LsfgVer) and Assigned(FHomeModVerLbls[5]) then
    begin
      FHomeModVerLbls[5].Caption := LsfgVer + ' → ' + LsfgRemoteVer;
      FHomeModVerLbls[5].Font.Color := $0044AAFF;
    end;

    // 6. MAKO
    MakoSystem := FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
                  FileExists('/etc/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
                  FileExists('/usr/local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json') or
                  (FileExists('/usr/bin/mako-launch') and FileExists('/usr/lib/libmako-render.so'));
    MakoUser := FileExists(UserLayerDir + 'VkLayer_MAKO_render.json') or
                FileExists(XdgLayerDir + 'VkLayer_MAKO_render.json') or
                FileExists(LocalLib + 'libmako-render.so') or
                FileExists(LocalBin + 'mako-launch');
    MakoOK := MakoSystem or (MakoUser and (IsMakoInstalled or (Missing.IndexOf(DEP_MAKO) < 0)));
    MakoVer := Self.GetMakoVersion;
    while (MakoVer <> '') and (MakoVer[1] in ['v', 'V']) do
      Delete(MakoVer, 1, 1);
    SetModuleStatus(6, MakoOK, MakoSystem, MakoVer);

    MakoRemoteVer := '';
    if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).MakoUpdateAvailable then
      MakoRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).MakoRemoteVer;
    while (MakoRemoteVer <> '') and (MakoRemoteVer[1] in ['v', 'V']) do
      Delete(MakoRemoteVer, 1, 1);
    if (MakoRemoteVer <> '') and (MakoVer <> '') and (MakoRemoteVer <> MakoVer) and Assigned(FHomeModVerLbls[6]) then
    begin
      FHomeModVerLbls[6].Caption := MakoVer + ' → ' + MakoRemoteVer;
      FHomeModVerLbls[6].Font.Color := $0044AAFF;
    end;

    // 7. ReShade
    ReShadeSystem := FileExists('/usr/share/reshade') or FileExists('/usr/share/goverlay/reshade');
    ReShadeOK := IsReShadeInstalled or ReShadeSystem;
    ReShadeVer := '';
    if ReShadeOK then
      ReShadeVer := GetReShadeInstalledVersion + ' (Add-on Edition)';
    SetModuleStatus(7, ReShadeOK, ReShadeSystem, ReShadeVer);

    // 8. afmf-linux
    AfmfSystem := FileExists('/usr/share/vulkan/implicit_layer.d/afmf-linux.json') or
                  FileExists('/etc/vulkan/implicit_layer.d/afmf-linux.json') or
                  FileExists('/usr/local/share/vulkan/implicit_layer.d/afmf-linux.json') or
                  FileExists('/app/share/vulkan/implicit_layer.d/afmf-linux.json');
    AfmfUser := FileExists(UserLayerDir + 'afmf-linux.json') or
                FileExists(XdgLayerDir + 'afmf-linux.json') or
                FileExists(LocalLib + 'libafmf.so') or
                FileExists(LocalLib + 'afmf-linux/libafmf-linux.so');
    AfmfOK := AfmfSystem or (AfmfUser and IsAfmfInstalled);
    AfmfVer := Self.GetAfmfVersion;
    while (AfmfVer <> '') and (AfmfVer[1] in ['v', 'V']) do
      Delete(AfmfVer, 1, 1);
    SetModuleStatus(8, AfmfOK, AfmfSystem, AfmfVer);

    AfmfRemoteVer := '';
    if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).AfmfUpdateAvailable then
      AfmfRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).AfmfRemoteVer;
    while (AfmfRemoteVer <> '') and (AfmfRemoteVer[1] in ['v', 'V']) do
      Delete(AfmfRemoteVer, 1, 1);
    if (AfmfRemoteVer <> '') and (AfmfVer <> '') and (AfmfRemoteVer <> AfmfVer) and Assigned(FHomeModVerLbls[8]) then
    begin
      FHomeModVerLbls[8].Caption := AfmfVer + ' → ' + AfmfRemoteVer;
      FHomeModVerLbls[8].Font.Color := $0044AAFF;
    end;

    // 9. HelixSR
    HelixSrSystem := FileExists('/usr/share/HelixSR');
    HelixSrOK := Self.IsHelixSrInstalled or HelixSrSystem;
    HelixSrVer := Self.GetHelixSrVersion;
    SetModuleStatus(9, HelixSrOK, HelixSrSystem, HelixSrVer);

    // 10. DLSS-NR
    DlssNrSystem := FileExists('/usr/lib/libdlss_nr.so') or FileExists('/usr/lib64/libdlss_nr.so');
    DlssNrOK := IsDlssNrInstalled;
    DlssNrReady := IsDlssNrModelReady;
    if DlssNrOK and DlssNrReady then
    begin
      FHomeModDots[10].Brush.Color := CLR_OK;
      if DlssNrSystem then
        FHomeModDots[10].Hint := 'System package'
      else
        FHomeModDots[10].Hint := 'Installed in user space (GOverlay)';
    end
    else if DlssNrOK and not DlssNrReady then
    begin
      FHomeModDots[10].Brush.Color := $0044AAFF;
      FHomeModDots[10].Hint := 'DLSS-NR runtime is installed, but neural model weights need extraction';
    end
    else
    begin
      FHomeModDots[10].Brush.Color := CLR_MISSING;
      FHomeModDots[10].Hint := 'Not installed';
    end;
    FHomeModDots[10].Pen.Color := FHomeModDots[10].Brush.Color;
    FHomeModDots[10].ShowHint := True;

    DlssNrVer := GetDlssNrVersion;
    if DlssNrVer = '' then
      DlssNrVer := StrUtils.IfThen(DlssNrOK, 'installed', 'not found');
    if Assigned(FHomeModVerLbls[10]) then
    begin
      FHomeModVerLbls[10].Caption := DlssNrVer;
      FHomeModVerLbls[10].Font.Color := CLR_TEXT_MUTED;
      FHomeModVerLbls[10].Hint := FHomeModDots[10].Hint;
      FHomeModVerLbls[10].ShowHint := True;
    end;

    // 11. vkNemu
    VkNemuSystem := VkNemuSystemLayersPresent;
    VkNemuUser := FileExists(UserLayerDir + 'vknemu.json') or
                  FileExists(XdgLayerDir + 'vknemu.json') or
                  FileExists(IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers/vknemu/libVkLayer_vknemu.so');
    VkNemuOK := VkNemuSystem or (VkNemuUser and IsVkNemuInstalled);
    VkNemuVer := Self.GetVkNemuVersion;
    while (VkNemuVer <> '') and (VkNemuVer[1] in ['v', 'V']) do
      Delete(VkNemuVer, 1, 1);
    SetModuleStatus(11, VkNemuOK, VkNemuSystem, VkNemuVer);
  end;
end;

procedure THomeTabHelper.RefreshHomeOptiStatus;
const
  CLR_OK       = $0044BB44;
  CLR_NONE     = $00666666;

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

var
  DlssVer: string;
begin
  with FForm do
  begin
    // Update OptiScaler version in module status
    if Assigned(FHomeModVerLbls[2]) and Assigned(optlabel1) and (optlabel1.Caption <> '') then
      FHomeModVerLbls[2].Caption := optlabel1.Caption;

    // Update DLSS Enabler version in module status
    if Assigned(FHomeModVerLbls[3]) then
    begin
      DlssVer := Self.GetDlssEnablerVersion;
      if (DlssVer <> '') and (DlssVer <> '--') then
      begin
        FHomeModVerLbls[3].Caption := DlssVer;
        if Assigned(FHomeModDots[3]) then FHomeModDots[3].Brush.Color := $0044BB44;
      end;
    end;

    // Library sub-rows: FakeNvAPI[0], Optipatcher[1], FSR[2], XeSS[3], DLSS[4]
    SetLib(0, fakenvapi1);
    SetLib(1, optipatcherLabel1);
    SetLib(2, fsrlabel1);
    SetLib(3, xessLabel1);
    SetLib(4, dlssLabel1);
  end;
end;

procedure THomeTabHelper.RefreshHomeMakoStatus;
var
  LsfgLocalVer, LsfgRemoteVer: string;
  LsfgHasUpdate: Boolean;
  MakoLocalVer, MakoRemoteVer: string;
  MakoHasUpdate: Boolean;
  AfmfLocalVer, AfmfRemoteVer: string;
  AfmfHasUpdate: Boolean;
begin
  with FForm do
  begin
    // 1. Update lsfg-vk (index 5)
    if Assigned(FHomeModVerLbls[5]) then
    begin
      LsfgLocalVer := Self.GetLsfgVkVersion;
      while (LsfgLocalVer <> '') and (LsfgLocalVer[1] in ['v', 'V']) do
        Delete(LsfgLocalVer, 1, 1);

      LsfgRemoteVer := '';
      LsfgHasUpdate := False;
      if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).LsfgUpdateAvailable then
      begin
        LsfgRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).LsfgRemoteVer;
        LsfgHasUpdate := True;
      end;
      while (LsfgRemoteVer <> '') and (LsfgRemoteVer[1] in ['v', 'V']) do
        Delete(LsfgRemoteVer, 1, 1);

      if LsfgHasUpdate and (LsfgRemoteVer <> '') and (LsfgLocalVer <> '') and (CompareVersions(LsfgRemoteVer, LsfgLocalVer) > 0) then
      begin
        FHomeModVerLbls[5].Caption := LsfgLocalVer + ' → ' + LsfgRemoteVer;
        FHomeModVerLbls[5].Font.Color := $0044AAFF;
        if Assigned(FHomeModDots[5]) then
          FHomeModDots[5].Brush.Color := $0044BB44;
      end
      else if LsfgLocalVer <> '' then
      begin
        FHomeModVerLbls[5].Caption := LsfgLocalVer;
        FHomeModVerLbls[5].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[5]) then
          FHomeModDots[5].Brush.Color := $0044BB44;
      end
      else if IsLsfgVkInstalled then
      begin
        FHomeModVerLbls[5].Caption := 'installed';
        FHomeModVerLbls[5].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[5]) then
          FHomeModDots[5].Brush.Color := $0044BB44;
      end
      else
      begin
        FHomeModVerLbls[5].Caption := 'not found';
        FHomeModVerLbls[5].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[5]) then
          FHomeModDots[5].Brush.Color := $004444BB;
      end;
    end;

    // 2. Update MAKO (index 6)
    if Assigned(FHomeModVerLbls[6]) then
    begin
      MakoLocalVer := Self.GetMakoVersion;
      while (MakoLocalVer <> '') and (MakoLocalVer[1] in ['v', 'V']) do
        Delete(MakoLocalVer, 1, 1);

      MakoRemoteVer := '';
      MakoHasUpdate := False;
      if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).MakoUpdateAvailable then
      begin
        MakoRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).MakoRemoteVer;
        MakoHasUpdate := True;
      end;
      while (MakoRemoteVer <> '') and (MakoRemoteVer[1] in ['v', 'V']) do
        Delete(MakoRemoteVer, 1, 1);

      if MakoHasUpdate and (MakoRemoteVer <> '') and (MakoLocalVer <> '') and (CompareVersions(MakoRemoteVer, MakoLocalVer) > 0) then
      begin
        FHomeModVerLbls[6].Caption := MakoLocalVer + ' → ' + MakoRemoteVer;
        FHomeModVerLbls[6].Font.Color := $0044AAFF;
        if Assigned(FHomeModDots[6]) then
          FHomeModDots[6].Brush.Color := $0044BB44;
      end
      else if MakoLocalVer <> '' then
      begin
        FHomeModVerLbls[6].Caption := MakoLocalVer;
        FHomeModVerLbls[6].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[6]) then
          FHomeModDots[6].Brush.Color := $0044BB44;
      end
      else if IsMakoInstalled then
      begin
        FHomeModVerLbls[6].Caption := 'installed';
        FHomeModVerLbls[6].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[6]) then
          FHomeModDots[6].Brush.Color := $0044BB44;
      end
      else
      begin
        FHomeModVerLbls[6].Caption := 'not found';
        FHomeModVerLbls[6].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[6]) then
          FHomeModDots[6].Brush.Color := $004444BB;
      end;
    end;

    // 3. Update afmf-linux (index 8)
    if Assigned(FHomeModVerLbls[8]) then
    begin
      AfmfLocalVer := Self.GetAfmfVersion;
      while (AfmfLocalVer <> '') and (AfmfLocalVer[1] in ['v', 'V']) do
        Delete(AfmfLocalVer, 1, 1);

      AfmfRemoteVer := '';
      AfmfHasUpdate := False;
      if Assigned(FLosslessScalingHelper) and TLosslessScalingTabHelper(FLosslessScalingHelper).AfmfUpdateAvailable then
      begin
        AfmfRemoteVer := TLosslessScalingTabHelper(FLosslessScalingHelper).AfmfRemoteVer;
        AfmfHasUpdate := True;
      end;
      while (AfmfRemoteVer <> '') and (AfmfRemoteVer[1] in ['v', 'V']) do
        Delete(AfmfRemoteVer, 1, 1);

      if AfmfHasUpdate and (AfmfRemoteVer <> '') and (AfmfLocalVer <> '') and (CompareVersions(AfmfRemoteVer, AfmfLocalVer) > 0) then
      begin
        FHomeModVerLbls[8].Caption := AfmfLocalVer + ' → ' + AfmfRemoteVer;
        FHomeModVerLbls[8].Font.Color := $0044AAFF;
        if Assigned(FHomeModDots[8]) then
          FHomeModDots[8].Brush.Color := $0044BB44;
      end
      else if AfmfLocalVer <> '' then
      begin
        FHomeModVerLbls[8].Caption := AfmfLocalVer;
        FHomeModVerLbls[8].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[8]) then
          FHomeModDots[8].Brush.Color := $0044BB44;
      end
      else if IsAfmfInstalled then
      begin
        FHomeModVerLbls[8].Caption := 'installed';
        FHomeModVerLbls[8].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[8]) then
          FHomeModDots[8].Brush.Color := $0044BB44;
      end
      else
      begin
        FHomeModVerLbls[8].Caption := 'not found';
        FHomeModVerLbls[8].Font.Color := CLR_TEXT_MUTED;
        if Assigned(FHomeModDots[8]) then
          FHomeModDots[8].Brush.Color := $004444BB;
      end;
    end;
  end;
end;

procedure THomeTabHelper.RefreshHomeDeps;
const
  {$IFDEF LCLqt6}
  DEP_KEYS: array[0..6] of string = (
    DEP_P7ZIP, DEP_CURL, DEP_GIT, DEP_GAMEMODE, DEP_LIBQT6PAS, DEP_NERDFONTS,
    DEP_LOW_LATENCY_LAYER);
  DEP_DISPLAY: array[0..6] of string = (
    '7z (p7zip)', 'curl', 'git', 'gamemode', 'qt6pas', 'Nerd Fonts', 'Korthos low latency');
  DEP_HINTS: array[0..6] of string = (
    'Archive tool required for OptiScaler extraction',
    'HTTP client used to download OptiScaler updates and covers',
    'Version control used to fetch fgmod scripts',
    'Feral GameMode daemon for CPU/GPU optimisation',
    'Qt6 Pascal bindings — required for the Goverlay GUI',
    'Nerd Font (e.g. ttf-nerd-fonts-symbols) — required for UI icons',
    'Vulkan Low Latency layer — latency reduction layer');
  {$ELSE}
  DEP_KEYS: array[0..6] of string = (
    DEP_P7ZIP, DEP_CURL, DEP_GIT, DEP_GAMEMODE, DEP_LIBQT5PAS, DEP_NERDFONTS,
    DEP_LOW_LATENCY_LAYER);
  DEP_DISPLAY: array[0..6] of string = (
    '7z (p7zip)', 'curl', 'git', 'gamemode', 'qt5pas', 'Nerd Fonts', 'Korthos low latency');
  DEP_HINTS: array[0..6] of string = (
    'Archive tool required for OptiScaler extraction',
    'HTTP client used to download OptiScaler updates and covers',
    'Version control used to fetch fgmod scripts',
    'Feral GameMode daemon for CPU/GPU optimisation',
    'Qt5 Pascal bindings — required for the Goverlay GUI',
    'Nerd Font (e.g. ttf-nerd-fonts-symbols) — required for UI icons',
    'Vulkan Low Latency layer — latency reduction layer');
  {$ENDIF}
  CLR_OK      = $0044CC55;  // vibrant emerald green
  CLR_MISSING = $005555EE;  // vibrant rose/coral red
var
  Missing: TStringList;
  i: Integer;
begin
  with FForm do
  begin
    if not Assigned(FHomeDepDots[0]) then Exit;
    Missing := FForm.GetCachedMissingDeps;
    for i := 0 to 6 do
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

procedure THomeTabHelper.HomeCardPaint(Sender: TObject);
var
  P: TPanel;
  BgColor, BorderColor, ParentBg: TColor;
  R: TRect;
begin
  P := TPanel(Sender);
  if CurrentTheme = tmLight then
  begin
    ParentBg    := LightBackgroundColor;
    BgColor     := RGBToColor(245, 246, 248);
    BorderColor := RGBToColor(218, 222, 230);
  end
  else
  begin
    ParentBg    := RGBToColor(22, 26, 40);
    BgColor     := RGBToColor(27, 32, 46);
    BorderColor := RGBToColor(46, 56, 80);
  end;
  P.Canvas.Brush.Color := ParentBg;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);

  R := Rect(0, 0, P.ClientWidth, P.ClientHeight);
  P.Canvas.Brush.Color := BgColor;
  P.Canvas.Pen.Color   := BorderColor;
  P.Canvas.Pen.Width   := 1;
  P.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 12, 12);
end;

procedure THomeTabHelper.ClearConfigBtnPaint(Sender: TObject);
var
  P: TPanel;
  BgColor, BorderColor, TextColor: TColor;
  R: TRect;
begin
  P := TPanel(Sender);
  if P.Tag = 1 then
  begin
    BgColor     := RGBToColor(120, 36, 44);
    BorderColor := RGBToColor(180, 50, 60);
    TextColor   := clWhite;
  end
  else
  begin
    if CurrentTheme = tmLight then
    begin
      BgColor     := RGBToColor(235, 238, 245);
      BorderColor := RGBToColor(200, 205, 218);
      TextColor   := RGBToColor(60, 70, 90);
    end
    else
    begin
      BgColor     := RGBToColor(36, 44, 62);
      BorderColor := RGBToColor(55, 66, 92);
      TextColor   := RGBToColor(180, 190, 210);
    end;
  end;
  P.Canvas.Brush.Color := IfThen(CurrentTheme = tmLight, RGBToColor(245, 246, 248), RGBToColor(27, 32, 46));
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);

  R := Rect(0, 0, P.ClientWidth, P.ClientHeight);
  P.Canvas.Brush.Color := BgColor;
  P.Canvas.Pen.Color   := BorderColor;
  P.Canvas.Pen.Width   := 1;
  P.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);

  P.Canvas.Font.Name   := 'Noto Sans';
  P.Canvas.Font.Size   := 8;
  P.Canvas.Font.Color  := TextColor;
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.TextOut((P.ClientWidth - P.Canvas.TextWidth(P.Caption)) div 2,
                   (P.ClientHeight - P.Canvas.TextHeight(P.Caption)) div 2, P.Caption);
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
  if MessageDlg(rsClearConfigTitle, rsClearConfigPrompt,
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // Remove all user-space layers and binaries
  UninstallAllUserModules;

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
        if not CleanDirectoryPreservingBackups(Paths[i]) then
          AllDeleted := False;
        if FForm is Tgoverlayform then
          Tgoverlayform(FForm).FClearedConfig := True;
        WriteLn('[ClearConfig] Cleaned (preserving backups): ', Paths[i]);
      except
        on E: Exception do
        begin
          WriteLn('[ClearConfig] ERROR cleaning ', Paths[i], ': ', E.Message);
          AllDeleted := False;
        end;
      end;
    end;
  end;

  Self.RefreshHomeModuleStatus;
  Self.RefreshHomeDeps;
  Self.RefreshHomeOptiStatus;

  if AllDeleted then
    ShowMessage(rsClearConfigDone)
  else
    ShowMessage(rsClearConfigPartial);
end;

procedure THomeTabHelper.ClearConfigBtnEnter(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
  begin
    ExtCtrls.TPanel(Sender).Tag := 1;
    ExtCtrls.TPanel(Sender).Invalidate;
  end;
end;

procedure THomeTabHelper.ClearConfigBtnLeave(Sender: TObject);
begin
  if Sender is ExtCtrls.TPanel then
  begin
    ExtCtrls.TPanel(Sender).Tag := 0;
    ExtCtrls.TPanel(Sender).Invalidate;
  end;
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
  if IsRunningInFlatpak then Exit;
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
  if IsRunningInFlatpak then Exit;
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
  LocalVer: string;
begin
  Result := '';

  // 1. Check local user-space version recorded by GOverlay
  LocalVer := ReadLocalVkSumiVersion;
  if LocalVer <> '' then
    Exit(LocalVer);

  // 2. Fall back to package managers for system-wide installs
  if IsRunningInFlatpak then Exit;
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

function THomeTabHelper.GetLsfgVkVersion: string;
var
  LsVer: string;
begin
  LsVer := GetLsfgVkInstalledVersion;
  if LsVer <> '' then
    Exit(LsVer);
  if IsLsfgVkInstalled then
    Exit('installed');

  Result := '';
end;

function THomeTabHelper.GetMakoVersion: string;
var
  MakoVer: string;
begin
  MakoVer := GetMakoInstalledVersion;
  if MakoVer <> '' then
    Exit(MakoVer);
  if IsMakoInstalled then
    Exit('installed');

  Result := '';
end;

function THomeTabHelper.GetAfmfVersion: string;
var
  AfmfVer: string;
begin
  AfmfVer := GetAfmfInstalledVersion;
  if AfmfVer <> '' then
    Exit(AfmfVer);
  if IsAfmfInstalled then
    Exit('installed');

  Result := '';
end;

function THomeTabHelper.IsHelixSrInstalled: Boolean;
var
  HelixPath: string;
begin
  HelixPath := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath);
  Result := FileExists(GetHelixSRDx12DllPath(HelixPath)) or
            FileExists(HelixPath + 'helixsr_setup.json') or
            FileExists('/usr/share/HelixSR');
end;

function THomeTabHelper.GetHelixSrVersion: string;
var
  HelixDir, VarsPath, Ver: string;
  HelixVars: TStringList;
begin
  Result := '';
  HelixDir := IncludeTrailingPathDelimiter(GetBGModOriginalHelixSRPath);
  if not FileExists(GetHelixSRDx12DllPath(HelixDir)) and
     not FileExists(HelixDir + 'helixsr_setup.json') and
     not FileExists('/usr/share/HelixSR') then
    Exit;

  VarsPath := HelixDir + 'goverlay.vars';
  if FileExists(VarsPath) then
  begin
    HelixVars := TStringList.Create;
    try
      HelixVars.LoadFromFile(VarsPath);
      Ver := HelixVars.Values['OPTISCALER_HELIXSR_VERSION'];
    finally
      HelixVars.Free;
    end;
  end;

  if Ver = '' then
    Ver := FALLBACK_HELIXSR_VERSION;

  Result := Ver;
end;

function THomeTabHelper.GetVkNemuVersion: string;
var
  P: TProcess;
  S: TStringList;
  LocalVer: string;
begin
  Result := '';

  // 1. Check local user-space version recorded by GOverlay
  LocalVer := ReadLocalVkNemuVersion;
  if LocalVer <> '' then
    Exit(LocalVer);

  // 2. Fall back to package managers for system-wide installs
  if IsRunningInFlatpak then Exit;
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('pacman -Q vknemu 2>/dev/null | awk ''{print $2}'' || ' +
                     'dpkg-query -W -f=''${Version}'' vknemu 2>/dev/null || ' +
                     'rpm -q --qf ''%{VERSION}'' vknemu 2>/dev/null || echo ""');
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

procedure THomeTabHelper.RefreshHomeVkNemuStatus;
const
  CLR_OK      = $0044CC55;
  CLR_MISSING = $005555EE;
var
  VkNemuOK, VkNemuSystem, VkNemuUser: Boolean;
  VkNemuVer, HintText: string;
  HomeDir, UserLayerDir, XdgLayerDir: string;
begin
  with FForm do
  begin
    if not Assigned(FHomeModDots[11]) then Exit;

    HomeDir := IncludeTrailingPathDelimiter(GetUserDir);
    UserLayerDir := HomeDir + '.local/share/vulkan/implicit_layer.d/';
    XdgLayerDir := GetUserVulkanImplicitDir;

    VkNemuSystem := VkNemuSystemLayersPresent;
    VkNemuUser := FileExists(UserLayerDir + 'vknemu.json') or
                  FileExists(XdgLayerDir + 'vknemu.json') or
                  FileExists(IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'layers/vknemu/libVkLayer_vknemu.so');
    VkNemuOK := VkNemuSystem or (VkNemuUser and IsVkNemuInstalled);

    if VkNemuOK then
    begin
      FHomeModDots[11].Brush.Color := CLR_OK;
      FHomeModDots[11].Pen.Color   := CLR_OK;
      if VkNemuSystem then
        HintText := 'System package'
      else
        HintText := 'Installed in user space (GOverlay)';
    end
    else
    begin
      FHomeModDots[11].Brush.Color := CLR_MISSING;
      FHomeModDots[11].Pen.Color   := CLR_MISSING;
      HintText := 'Not installed';
    end;

    FHomeModDots[11].Hint := HintText;
    FHomeModDots[11].ShowHint := True;

    VkNemuVer := Self.GetVkNemuVersion;
    if VkNemuVer = '' then
      VkNemuVer := StrUtils.IfThen(VkNemuOK, 'installed', 'not found');
    while (VkNemuVer <> '') and (VkNemuVer[1] in ['v', 'V']) do
      Delete(VkNemuVer, 1, 1);

    if Assigned(FHomeModVerLbls[11]) then
    begin
      FHomeModVerLbls[11].Caption := VkNemuVer;
      FHomeModVerLbls[11].Font.Color := CLR_TEXT_MUTED;
      FHomeModVerLbls[11].Hint := HintText;
      FHomeModVerLbls[11].ShowHint := True;
    end;
  end;
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

function THomeTabHelper.IsDlssEnablerInstalled: Boolean;
begin
  Result := FileExists(IncludeTrailingPathDelimiter(GetDlssEnablerPath(True)) + 'version.dll') or
            FileExists(IncludeTrailingPathDelimiter(GetDlssEnablerPath(False)) + 'version.dll');
end;

function THomeTabHelper.GetDlssEnablerVersion: string;
var
  VarsPath: string;
  VarsList: TStringList;
  IsStable: Boolean;
begin
  Result := '';

  if Assigned(FForm) and Assigned(FForm.dlssEnablerVersionLabel) and
     (FForm.dlssEnablerVersionLabel.Caption <> '') and (FForm.dlssEnablerVersionLabel.Caption <> '--') then
  begin
    Result := FForm.dlssEnablerVersionLabel.Caption;
    Exit;
  end;

  IsStable := True;
  if Assigned(FForm) and Assigned(FForm.optversionComboBox) and (FForm.optversionComboBox.ItemIndex = 1) then
    IsStable := False;

  VarsPath := IncludeTrailingPathDelimiter(GetDlssEnablerPath(IsStable)) + 'goverlay.vars';
  if not FileExists(VarsPath) then
    VarsPath := IncludeTrailingPathDelimiter(GetDlssEnablerPath(not IsStable)) + 'goverlay.vars';

  if FileExists(VarsPath) then
  begin
    VarsList := TStringList.Create;
    try
      VarsList.LoadFromFile(VarsPath);
      Result := VarsList.Values['dlssenablerversion'];
      if Result = '' then
        Result := VarsList.Values['dlssenabler'];
      if Result = '' then
        Result := VarsList.Values['dlssenablertag'];
    finally
      VarsList.Free;
    end;
  end;
end;

procedure THomeTabHelper.NicknameClick(Sender: TObject);
var
  NewNick: string;
begin
  NewNick := InputBox('Pascube nickname', 'Enter display nickname for leaderboard benchmark uploads:', GetUserNickname);
  SaveUserNickname(NewNick);
  InitHomeTab;
end;

end.
