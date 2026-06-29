unit sidebar_nav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Buttons, Graphics, Types, Dialogs, Math, Forms, Menus, IniFiles, StdCtrls, ComCtrls,
  overlayunit;

const
  // Nav rail constants
  NAV_ITEM_H      = 64;   // height of each nav item
  NAV_ITEM_W      = 211;  // width (same as sidebar)
  NAV_INDICATOR_W = 3;    // active indicator bar width
  NAV_ICON_SIZE   = 28;   // icon area size
  NAV_COLOR_BG        = $00281A16; // item bg — matches sidebar body (R=22,G=26,B=40)
  NAV_COLOR_HOVER     = $003A2820; // item hover (R=32,G=40,B=58)
  NAV_COLOR_ACTIVE    = $004C3830; // item active (R=48,G=56,B=76)
  NAV_COLOR_INDICATOR = clHighlight; // active indicator — system accent/selection color
  NAV_IND_GAMES = $0000A5FF;  // amber (R=255,G=165,B=0)  — Games category accent
  NAV_IND_TOOLS = clHighlight; // tools keep the system accent colour
  // Light theme nav colors
  NAV_LIGHT_BG        = $00E8E8E8;
  NAV_LIGHT_HOVER     = $00D0D0D0;
  NAV_LIGHT_ACTIVE    = $00C0C0C0;
  NAV_W_EXPANDED  = 211;
  NAV_W_COLLAPSED = 60;

type
  TSidebarNavHelper = class
  private
    FForm: Tgoverlayform;
  public
    constructor Create(AForm: Tgoverlayform);
    
    procedure BuildNavRail;
    procedure BuildSettingsButton;
    procedure SettingsBtnMouseEnter(Sender: TObject);
    procedure SettingsBtnMouseLeave(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure CubeAutoLaunchMenuItemClick(Sender: TObject);
    
    procedure BuildNavToolToggles;
    procedure BuildSmallToggleImages;
    procedure NavToolToggleClick(Sender: TObject);
    procedure UpdateNavToolToggleVisibility(AShowLabels: Boolean);
    procedure LoadGameToggleStates;
    function  GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
    procedure SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
    procedure ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
    function  ActiveToolIndex: Integer;
    procedure SetSaveBtnEnabled(AEnabled: Boolean);
    procedure SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
    procedure RemoveTweaksFromGameFGMod(const AFGModFile: string);
    procedure RemoveOptiScalerGameFiles(const AGameCfgDir: string);
    procedure CopyOptiScalerGameFiles(const AGameCfgDir: string);
    
    procedure RestoreNavRailColors;
    procedure SetNavActive(AIndex: Integer);
    procedure NavItemClick(Sender: TObject);
    procedure NavItemMouseEnter(Sender: TObject);
    procedure NavItemMouseLeave(Sender: TObject);
    procedure NavItemPaint(Sender: TObject);
    procedure ApplyNavCollapsed;
    procedure NavToggleClick(Sender: TObject);
    procedure NavAnimTick(Sender: TObject);
    procedure ApplyNavWidth(AWidth: Integer);
  end;

implementation

uses
  apputils, themeunit, configmanager, bgmod_resources, StrUtils;

constructor TSidebarNavHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;

procedure TSidebarNavHelper.BuildNavRail;
const
  // Item definitions: (unicode icon, caption, top offset)
  ITEMS: array[0..4] of record Icon, Caption: string; end = (
    (Icon: '󰊴'; Caption: 'Games'),
    (Icon: '󱁥'; Caption: 'MangoHud'),
    (Icon: '󰏘'; Caption: 'Post processing'),
    (Icon: '󰋮'; Caption: 'OptiScaler'),
    (Icon: '󰒓'; Caption: 'EnvVars')
  );
  TOP_START = 108;
var
  i: Integer;
  Item: TPanel;
  Indicator: TShape;
  IconPath: string;
  IconLbl: TLabel;
  CaptionLbl: TLabel;
  TopY: Integer;
  UIStateFile: string;
  SL: TStringList;
begin
  // Hide legacy shape+label widgets
  FForm.mangohudShape.Visible  := False;  FForm.mangohudLabel.Visible  := False;
  FForm.vkbasaltShape.Visible  := False;  FForm.vkbasaltLabel.Visible  := False;
  FForm.optiscalerShape.Visible := False; FForm.optiscalerLabel.Visible := False;
  FForm.tweaksShape.Visible    := False;  FForm.tweaksLabel.Visible    := False;

  SetLength(FForm.FNavItems,      Length(ITEMS));
  SetLength(FForm.FNavIndicators, Length(ITEMS));
  SetLength(FForm.FNavIcons,      Length(ITEMS));
  SetLength(FForm.FNavLabels,     Length(ITEMS));
  SetLength(FForm.FNavClickCBs,   Length(ITEMS));

  FForm.FNavClickCBs[0] := @FForm.gamesLabelClick;
  FForm.FNavClickCBs[1] := @FForm.mangohudLabelClick;
  FForm.FNavClickCBs[2] := @FForm.vkbasaltLabelClick;
  FForm.FNavClickCBs[3] := @FForm.optiscalerLabelClick;
  FForm.FNavClickCBs[4] := @FForm.tweaksLabelClick;

  FForm.FNavActive     := -1;
  FForm.FNavHoveredIdx := -1;
  FForm.FNavCollapsed    := False;
  FForm.FCubeAutoLaunch  := False;  // disabled by default

  // Restore sidebar collapsed state from previous session
  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  if FileExists(UIStateFile) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(UIStateFile);
      if (SL.Count > 0) and (SL[0] = '1') then
        FForm.FNavCollapsed := True;
      if (SL.Count > 1) and (SL[1] = '1') then
        FForm.FCubeAutoLaunch := True;
    finally
      SL.Free;
    end;
  end;

  FForm.FNavAnimCurrent := IfThen(FForm.FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED) * 10;
  FForm.FNavAnimTarget  := IfThen(FForm.FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);

  FForm.FNavAnimTimer := TTimer.Create(FForm);
  FForm.FNavAnimTimer.Interval := 12;  // ~80fps
  FForm.FNavAnimTimer.Enabled  := False;
  FForm.FNavAnimTimer.OnTimer  := @FForm.NavAnimTick;

  // Toggle button — small discrete arrow, bottom-right of logo area
  FForm.FNavToggleBtn := TSpeedButton.Create(FForm);
  FForm.FNavToggleBtn.Parent  := FForm;
  FForm.FNavToggleBtn.SetBounds(NAV_W_EXPANDED - 28, 53, 24, 24);
  FForm.FNavToggleBtn.Caption    := '«';
  FForm.FNavToggleBtn.Font.Size  := 11;
  FForm.FNavToggleBtn.Font.Color := $00666666;
  FForm.FNavToggleBtn.Flat    := True;
  FForm.FNavToggleBtn.Cursor  := crHandPoint;
  FForm.FNavToggleBtn.Color   := $00221F1E;
  FForm.FNavToggleBtn.OnClick := @FForm.NavToggleClick;

  // Small app icon shown in collapsed state instead of the full logo
  FForm.FNavSmallIcon := TImage.Create(FForm);
  FForm.FNavSmallIcon.Parent  := FForm;
  FForm.FNavSmallIcon.SetBounds((NAV_W_COLLAPSED - 40) div 2, 8, 40, 40);
  FForm.FNavSmallIcon.Stretch      := True;
  FForm.FNavSmallIcon.Proportional := True;
  FForm.FNavSmallIcon.Center       := True;
  FForm.FNavSmallIcon.Visible      := False;
  // Load icon — try installed path first, then local data dir
  IconPath := GetIconFile();
  if not FileExists(IconPath) then
    IconPath := FForm.GetAppBaseDir + 'data/icons/128x128/goverlay.png';
  if FileExists(IconPath) then
    try FForm.FNavSmallIcon.Picture.LoadFromFile(IconPath); except end;


  for i := 0 to High(ITEMS) do
  begin
    TopY := TOP_START + i * (NAV_ITEM_H + 4);

    // --- Item panel ---
    Item := TPanel.Create(FForm);
    Item.Parent  := FForm;
    Item.SetBounds(FForm.goverlayPaintBox.Left, FForm.goverlayPaintBox.Top + TopY, NAV_ITEM_W, NAV_ITEM_H);
    Item.BevelOuter := bvNone;
    Item.Caption := '';
    Item.Color   := NAV_COLOR_BG;
    Item.Cursor  := crHandPoint;
    Item.Tag     := i;
    Item.OnClick      := @FForm.NavItemClick;
    Item.OnMouseEnter := @FForm.NavItemMouseEnter;
    Item.OnMouseLeave := @FForm.NavItemMouseLeave;
    Item.OnPaint      := @FForm.NavItemPaint;

    // --- Active indicator bar (left edge) ---
    Indicator := TShape.Create(FForm);
    Indicator.Parent := Item;
    Indicator.SetBounds(0, 12, NAV_INDICATOR_W, NAV_ITEM_H - 24);
    Indicator.Brush.Color := NAV_COLOR_INDICATOR;
    Indicator.Pen.Color   := NAV_COLOR_INDICATOR;
    Indicator.Shape   := stRoundRect;
    Indicator.Visible := False;

    // --- Icon label (Nerd Font / Unicode) ---
    IconLbl := TLabel.Create(FForm);
    IconLbl.Parent := Item;
    IconLbl.SetBounds(16, (NAV_ITEM_H - NAV_ICON_SIZE) div 2, NAV_ICON_SIZE, NAV_ICON_SIZE);

    if i = 3 then
    begin
      IconLbl.Caption := ''; // Clear text

      FForm.FOptiScalerImg := TImage.Create(FForm);
      FForm.FOptiScalerImg.Parent := Item;
      FForm.FOptiScalerImg.SetBounds(18, (NAV_ITEM_H - 24) div 2, 24, 24);
      FForm.FOptiScalerImg.Stretch := True;
      FForm.FOptiScalerImg.Proportional := True;
      FForm.FOptiScalerImg.Center := True;
      FForm.FOptiScalerImg.Cursor := crHandPoint;
      FForm.FOptiScalerImg.Tag := i;
      FForm.FOptiScalerImg.OnClick      := @FForm.NavItemClick;
      FForm.FOptiScalerImg.OnMouseEnter := @FForm.NavItemMouseEnter;
      FForm.FOptiScalerImg.OnMouseLeave := @FForm.NavItemMouseLeave;

      IconPath := FForm.GetAppBaseDir + 'assets/icons/scale-up2.png';
      WriteLn(StdErr, '[NavIcon] scale-up2 path="', IconPath, '" exists=', FileExists(IconPath));
      if FileExists(IconPath) then
        try FForm.FOptiScalerImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[NavIcon] scale-up2 load error: ', E.Message); end;
    end
    else if i = 1 then
    begin
      IconLbl.Caption := ''; // Clear text

      FForm.FMangoHudImg := TImage.Create(FForm);
      FForm.FMangoHudImg.Parent := Item;
      FForm.FMangoHudImg.SetBounds(18, (NAV_ITEM_H - 24) div 2, 24, 24);
      FForm.FMangoHudImg.Stretch := True;
      FForm.FMangoHudImg.Proportional := True;
      FForm.FMangoHudImg.Center := True;
      FForm.FMangoHudImg.Cursor := crHandPoint;
      FForm.FMangoHudImg.Tag := i;
      FForm.FMangoHudImg.OnClick      := @FForm.NavItemClick;
      FForm.FMangoHudImg.OnMouseEnter := @FForm.NavItemMouseEnter;
      FForm.FMangoHudImg.OnMouseLeave := @FForm.NavItemMouseLeave;

      IconPath := FForm.GetAppBaseDir + 'assets/icons/mango-inactive.png';
      WriteLn(StdErr, '[NavIcon] mango-inactive path="', IconPath, '" exists=', FileExists(IconPath));
      if FileExists(IconPath) then
        try FForm.FMangoHudImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[NavIcon] mango-inactive load error: ', E.Message); end;
    end
    else
    begin
      IconLbl.Caption   := ITEMS[i].Icon;
    end;
    IconLbl.Font.Size := 18;
    IconLbl.Font.Color := $00AAAAAA;
    IconLbl.Font.Name  := 'Noto Sans';
    IconLbl.Transparent := True;
    IconLbl.Cursor := crHandPoint;
    IconLbl.Tag    := i;
    IconLbl.OnClick      := @FForm.NavItemClick;
    IconLbl.OnMouseEnter := @FForm.NavItemMouseEnter;
    IconLbl.OnMouseLeave := @FForm.NavItemMouseLeave;

    // --- Caption label ---
    CaptionLbl := TLabel.Create(FForm);
    CaptionLbl.Parent := Item;
    CaptionLbl.SetBounds(52, (NAV_ITEM_H - 16) div 2, NAV_ITEM_W - 60, 20);
    CaptionLbl.Caption   := ITEMS[i].Caption;
    CaptionLbl.Font.Size := 9;
    CaptionLbl.Font.Color := $00AAAAAA;
    CaptionLbl.Font.Name  := 'Noto Sans';
    CaptionLbl.Font.Style := [fsBold];
    CaptionLbl.Transparent := True;
    CaptionLbl.Cursor := crHandPoint;
    CaptionLbl.Tag    := i;
    CaptionLbl.OnClick      := @FForm.NavItemClick;
    CaptionLbl.OnMouseEnter := @FForm.NavItemMouseEnter;
    CaptionLbl.OnMouseLeave := @FForm.NavItemMouseLeave;

    FForm.FNavItems[i]      := Item;
    FForm.FNavIndicators[i] := Indicator;
    FForm.FNavIcons[i]      := IconLbl;
    FForm.FNavLabels[i]     := CaptionLbl;
  end;

  // Build per-tool toggle buttons (game mode only)
  BuildNavToolToggles;
  BuildSmallToggleImages;

  // Apply persisted collapsed state (no animation on startup)
  if FForm.FNavCollapsed then
    ApplyNavCollapsed;

  FForm.LoadGlobalThumb;
end;

procedure TSidebarNavHelper.BuildSettingsButton;
const
  BTN_SIZE       = 40;
  BTN_BOTTOM_PAD = 12;
var
  Sep: TMenuItem;
  SteamItem: TMenuItem;
  HeroicItem: TMenuItem;
begin
  // Transparent label — no background, just the gear icon over the sidebar gradient
  FForm.FSettingsIconLbl := TLabel.Create(FForm);
  FForm.FSettingsIconLbl.Parent       := FForm;
  FForm.FSettingsIconLbl.Caption      := '⚙';
  FForm.FSettingsIconLbl.Font.Color   := $00AAAAAA;  // dimmed like inactive nav items
  FForm.FSettingsIconLbl.Font.Height  := -24;
  FForm.FSettingsIconLbl.Font.Quality := fqAntialiased;
  FForm.FSettingsIconLbl.Transparent  := True;
  FForm.FSettingsIconLbl.Cursor       := crHandPoint;
  FForm.FSettingsIconLbl.AutoSize     := False;
  FForm.FSettingsIconLbl.Width        := BTN_SIZE;
  FForm.FSettingsIconLbl.Height       := BTN_SIZE;
  FForm.FSettingsIconLbl.Alignment    := taCenter;

  // Center horizontally inside the sidebar, fixed distance from bottom
  FForm.FSettingsIconLbl.AnchorSideLeft.Control := FForm.goverlayPaintBox;
  FForm.FSettingsIconLbl.AnchorSideLeft.Side    := asrCenter;
  FForm.FSettingsIconLbl.AnchorSideBottom.Control := FForm;
  FForm.FSettingsIconLbl.AnchorSideBottom.Side    := asrBottom;
  FForm.FSettingsIconLbl.BorderSpacing.Bottom     := BTN_BOTTOM_PAD;
  FForm.FSettingsIconLbl.Anchors := [akLeft, akBottom];

  FForm.FSettingsIconLbl.OnMouseEnter := @FForm.SettingsBtnMouseEnter;
  FForm.FSettingsIconLbl.OnMouseLeave := @FForm.SettingsBtnMouseLeave;
  FForm.FSettingsIconLbl.OnClick      := @FForm.SettingsBtnClick;

  // Dependencies status item at the top of the settings menu
  FForm.FDepsMenuItem := TMenuItem.Create(FForm.settingsMenu);
  FForm.FDepsMenuItem.Caption := 'Status';
  FForm.FDepsMenuItem.ImageIndex := 0;
  FForm.FDepsMenuItem.Enabled := True;
  FForm.FDepsMenuItem.OnClick := @FForm.ShowHomeTab;
  FForm.settingsMenu.Items.Insert(0, FForm.FDepsMenuItem);

  // Separator after deps item
  Sep := TMenuItem.Create(FForm.settingsMenu);
  Sep.Caption := '-';
  FForm.settingsMenu.Items.Insert(1, Sep);

  // Auto-launch cube toggle
  FForm.FCubeAutoLaunchItem := TMenuItem.Create(FForm.settingsMenu);
  FForm.FCubeAutoLaunchItem.Caption := 'Auto launch PasCube';
  FForm.FCubeAutoLaunchItem.ImageIndex := 4;
  FForm.FCubeAutoLaunchItem.Checked := FForm.FCubeAutoLaunch;
  FForm.FCubeAutoLaunchItem.OnClick := @FForm.CubeAutoLaunchMenuItemClick;
  FForm.settingsMenu.Items.Insert(2, FForm.FCubeAutoLaunchItem);

  Sep := TMenuItem.Create(FForm.settingsMenu);
  Sep.Caption := '-';
  FForm.settingsMenu.Items.Insert(4, Sep);

  // Video tutorial — submenu with Steam and Heroic
  FForm.FHowToMenuItem := TMenuItem.Create(FForm.settingsMenu);
  FForm.FHowToMenuItem.Caption := 'Video tutorial';
  FForm.FHowToMenuItem.ImageIndex := 18;

  SteamItem := TMenuItem.Create(FForm.FHowToMenuItem);
  SteamItem.Caption := 'Steam';
  SteamItem.ImageIndex := 3;
  SteamItem.OnClick := @FForm.howtoSteamClick;
  FForm.FHowToMenuItem.Add(SteamItem);

  HeroicItem := TMenuItem.Create(FForm.FHowToMenuItem);
  HeroicItem.Caption := 'Heroic';
  HeroicItem.ImageIndex := 38;
  HeroicItem.OnClick := @FForm.howtoHeroicClick;
  FForm.FHowToMenuItem.Add(HeroicItem);

  FForm.settingsMenu.Items.Insert(5, FForm.FHowToMenuItem);

  Sep := TMenuItem.Create(FForm.settingsMenu);
  Sep.Caption := '-';
  FForm.settingsMenu.Items.Insert(6, Sep);
end;

procedure TSidebarNavHelper.SettingsBtnMouseEnter(Sender: TObject);
begin
  if Assigned(FForm.FSettingsIconLbl) then
    FForm.FSettingsIconLbl.Font.Color := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
end;

procedure TSidebarNavHelper.SettingsBtnMouseLeave(Sender: TObject);
begin
  if Assigned(FForm.FSettingsIconLbl) then
    FForm.FSettingsIconLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
end;

procedure TSidebarNavHelper.SettingsBtnClick(Sender: TObject);
begin
  FForm.settingsMenu.PopUp;
end;

procedure TSidebarNavHelper.CubeAutoLaunchMenuItemClick(Sender: TObject);
var
  UIStateFile: string;
  SL: TStringList;
begin
  FForm.FCubeAutoLaunch := not FForm.FCubeAutoLaunch;
  FForm.FCubeAutoLaunchItem.Checked := FForm.FCubeAutoLaunch;

  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  SL := TStringList.Create;
  try
    SL.Add(IfThen(FForm.FNavCollapsed, '1', '0'));
    SL.Add(IfThen(FForm.FCubeAutoLaunch, '1', '0'));
    SL.SaveToFile(UIStateFile);
  finally
    SL.Free;
  end;
end;

procedure TSidebarNavHelper.BuildNavToolToggles;
const
  BTN_SIZE = 32;
var
  i: Integer;
  Btn: TSpeedButton;
begin
  for i := 0 to 3 do
  begin
    FForm.FNavToolEnabled[i] := True;
    Btn := TSpeedButton.Create(FForm);
    Btn.Parent    := FForm.FNavItems[i + 1];  // offset by 1: Games is at index 0
    Btn.SetBounds(NAV_ITEM_W - BTN_SIZE - 6, (NAV_ITEM_H - BTN_SIZE) div 2, BTN_SIZE, BTN_SIZE);
    Btn.Flat      := True;
    Btn.Caption   := '';
    Btn.Images    := FForm.globalbuttonImageList;
    Btn.ImageIndex := 1;  // 1 = ON
    Btn.Cursor    := crHandPoint;
    Btn.Tag       := i;
    Btn.OnClick   := @FForm.NavToolToggleClick;
    Btn.Visible   := False;
    FForm.FNavToolBtns[i] := Btn;
  end;
end;

procedure TSidebarNavHelper.BuildSmallToggleImages;
var
  SrcBmp, DstBmp: TBitmap;
  i: Integer;
begin
  if Assigned(FForm.FNavToolImgListSmall) then
    FreeAndNil(FForm.FNavToolImgListSmall);

  FForm.FNavToolImgListSmall := TImageList.Create(FForm);
  FForm.FNavToolImgListSmall.Width  := 20;
  FForm.FNavToolImgListSmall.Height := 9;

  for i := 0 to 1 do
  begin
    SrcBmp := TBitmap.Create;
    try
      SrcBmp.Width  := FForm.globalbuttonImageList.Width;
      SrcBmp.Height := FForm.globalbuttonImageList.Height;
      SrcBmp.Canvas.Brush.Color := clFuchsia;
      SrcBmp.Canvas.FillRect(0, 0, SrcBmp.Width, SrcBmp.Height);
      FForm.globalbuttonImageList.Draw(SrcBmp.Canvas, 0, 0, i);

      DstBmp := TBitmap.Create;
      try
        DstBmp.Width  := 20;
        DstBmp.Height := 9;
        DstBmp.Canvas.Brush.Color := clFuchsia;
        DstBmp.Canvas.FillRect(0, 0, DstBmp.Width, DstBmp.Height);
        DstBmp.Canvas.StretchDraw(Rect(0, 0, 20, 9), SrcBmp);
        FForm.FNavToolImgListSmall.AddMasked(DstBmp, clFuchsia);
      finally
        DstBmp.Free;
      end;
    finally
      SrcBmp.Free;
    end;
  end;
end;

procedure TSidebarNavHelper.NavToolToggleClick(Sender: TObject);
var
  Idx: Integer;
  NewEnabled: Boolean;
  GameCfgDir: string;
  ConfigFiles: array[0..2] of string;
begin
  Idx        := (Sender as TSpeedButton).Tag;
  NewEnabled := not FForm.FNavToolEnabled[Idx];
  FForm.FNavToolEnabled[Idx] := NewEnabled;
  // ImageIndex 1 = ON (green), 0 = OFF (red)
  FForm.FNavToolBtns[Idx].ImageIndex := IfThen(NewEnabled, 1, 0);

  if FForm.FActiveGameName <> '' then
  begin
    SetGameToolEnabled(FForm.FActiveGameName, Idx, NewEnabled);
    GameCfgDir := FForm.GetGameConfigDir(FForm.FActiveGameName);
    if not NewEnabled then
    begin
      // Delete the tool's config file when disabling (indices 0-2 only)
      ConfigFiles[0] := GameCfgDir + 'MangoHud.conf';
      ConfigFiles[1] := GameCfgDir + 'vkBasalt.conf';
      ConfigFiles[2] := GameCfgDir + 'OptiScaler.ini';
      if (Idx <= 2) and FileExists(ConfigFiles[Idx]) then
        DeleteFile(ConfigFiles[Idx]);
      if (Idx = 1) and FileExists(GameCfgDir + 'vkSumi.conf') then
        DeleteFile(GameCfgDir + 'vkSumi.conf');
      // Tweaks: remove all tweak export lines from the game's fgmod
      if Idx = 3 then
        RemoveTweaksFromGameFGMod(GameCfgDir + 'fgmod');
    end;
    // Ensure conditional export lines exist in the fgmod for tools that need them.
    // The GOVERLAY_X flag (set above) controls whether each line actually runs.
    if Idx = 0 then
      FForm.PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_MANGOHUD" == "1" ]] && export MANGOHUD=1',
        'MANGOHUD=1');
    if Idx = 1 then
    begin
      FForm.PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" == "1" ]] && export ENABLE_VKBASALT=1',
        'ENABLE_VKBASALT=1');
      FForm.PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" == "1" ]] && export ENABLE_VKSUMI=1',
        'ENABLE_VKSUMI=1');
    end;
    // OptiScaler toggle copies/removes all OptiScaler files and patches fgmod
    if Idx = 2 then
    begin
      FForm.PatchGameFGModWineDllOverrides(GameCfgDir + 'fgmod', NewEnabled);
      if NewEnabled then
        CopyOptiScalerGameFiles(GameCfgDir)
      else
        RemoveOptiScalerGameFiles(GameCfgDir);
    end;
  end;
  ApplyToolEnabledState(Idx, NewEnabled);
end;

procedure TSidebarNavHelper.UpdateNavToolToggleVisibility(AShowLabels: Boolean);
const
  BTN_FULL   = 32;  // button size in expanded mode
  BTN_SMALL  = 20;  // button size in collapsed mode
  ICON_TOP_C = 8;   // icon top offset in collapsed mode (shifted up to make room)
var
  i: Integer;
  ShouldShow: Boolean;
  BtnLeft, BtnTop, BtnW: Integer;
begin
  ShouldShow := FForm.FActiveGameName <> '';
  for i := 0 to 3 do
    if Assigned(FForm.FNavToolBtns[i]) then
    begin
      if ShouldShow then
      begin
        if AShowLabels then
        begin
          // Expanded: full-size button on the right side of the nav item
          BtnW    := BTN_FULL;
          BtnLeft := NAV_ITEM_W - BtnW - 6;
          BtnTop  := (NAV_ITEM_H - BtnW) div 2;
          FForm.FNavToolBtns[i].Images := FForm.globalbuttonImageList;
        end
        else
        begin
          // Collapsed: small button below the icon, horizontally centred
          BtnW    := BTN_SMALL;
          BtnLeft := (NAV_W_COLLAPSED - BtnW) div 2;
          BtnTop  := ICON_TOP_C + NAV_ICON_SIZE + 4;
          if Assigned(FForm.FNavToolImgListSmall) then
            FForm.FNavToolBtns[i].Images := FForm.FNavToolImgListSmall;
        end;
        FForm.FNavToolBtns[i].SetBounds(BtnLeft, BtnTop, BtnW, BtnW);
      end;
      FForm.FNavToolBtns[i].Visible := ShouldShow;
    end;
end;

procedure TSidebarNavHelper.LoadGameToggleStates;
var
  i: Integer;
  ToolOn: Boolean;
begin
  if FForm.FActiveGameName = '' then
  begin
    // Global mode: all tools enabled, hide toggles
    for i := 0 to 3 do
    begin
      FForm.FNavToolEnabled[i] := True;
      if Assigned(FForm.FNavToolBtns[i]) then
      begin
        FForm.FNavToolBtns[i].Visible    := False;
        FForm.FNavToolBtns[i].ImageIndex := 1;  // ON
      end;
      ApplyToolEnabledState(i, True);
    end;
    Exit;
  end;
  for i := 0 to 3 do
  begin
    ToolOn := GetGameToolEnabled(FForm.FActiveGameName, i);
    FForm.FNavToolEnabled[i] := ToolOn;
    if Assigned(FForm.FNavToolBtns[i]) then
      FForm.FNavToolBtns[i].ImageIndex := IfThen(ToolOn, 1, 0);
    ApplyToolEnabledState(i, ToolOn);
  end;
  // Update visibility, button size/position, and icon vertical position
  ApplyNavWidth(IfThen(FForm.FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED));
end;

function TSidebarNavHelper.GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
const
  FLAGS: array[0..3] of string = ('GOVERLAY_MANGOHUD', 'GOVERLAY_VKBASALT', 'GOVERLAY_OPTISCALER', 'GOVERLAY_TWEAKS');
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  Result := False;
  ConfigPath := FForm.GetGameConfigDir(AGameName) + 'bgmod.conf';
  if not FileExists(ConfigPath) then Exit;
  Ini := TIniFile.Create(ConfigPath);
  try
    Result := Ini.ReadString('Config', FLAGS[AToolIdx], '0') = '1';
  finally
    Ini.Free;
  end;
end;

procedure TSidebarNavHelper.SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
const
  FLAGS: array[0..3] of string = ('GOVERLAY_MANGOHUD', 'GOVERLAY_VKBASALT', 'GOVERLAY_OPTISCALER', 'GOVERLAY_TWEAKS');
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  ConfigPath := FForm.GetGameConfigDir(AGameName) + 'bgmod.conf';
  ForceDirectories(ExtractFilePath(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    if AEnabled then
      Ini.WriteString('Config', FLAGS[AToolIdx], '1')
    else
      Ini.WriteString('Config', FLAGS[AToolIdx], '0');
  finally
    Ini.Free;
  end;
end;

procedure TSidebarNavHelper.ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
begin
  case AToolIdx of
    0: // MangoHud spans several tab sheets
    begin
      FForm.SetControlTreeEnabled(FForm.presetTabSheet,       AEnabled);
      FForm.SetControlTreeEnabled(FForm.visualTabSheet,        AEnabled);
      FForm.SetControlTreeEnabled(FForm.performanceTabSheet,   AEnabled);
      FForm.SetControlTreeEnabled(FForm.metricsTabSheet,       AEnabled);
      FForm.SetControlTreeEnabled(FForm.extrasTabSheet,        AEnabled);
    end;
    1:
    begin
      FForm.SetControlTreeEnabled(FForm.vkbasaltTabsheet,    AEnabled);
      FForm.SetControlTreeEnabled(FForm.vksumiTabSheet,      AEnabled);
    end;
    2: FForm.SetControlTreeEnabled(FForm.optiscalertabsheet,  AEnabled);
    3: FForm.SetControlTreeEnabled(FForm.tweaksTabSheet,      AEnabled);
  end;
  // Disable Save when the toggled tool owns the currently visible tab
  if ActiveToolIndex = AToolIdx then
    SetSaveBtnEnabled(AEnabled);
end;

function TSidebarNavHelper.ActiveToolIndex: Integer;
var
  P: TTabSheet;
begin
  P := FForm.goverlayPageControl.ActivePage;
  if (P = FForm.presetTabSheet) or (P = FForm.visualTabSheet) or
     (P = FForm.performanceTabSheet) or (P = FForm.metricsTabSheet) or (P = FForm.extrasTabSheet) then
    Result := 0
  else if (P = FForm.vkbasaltTabsheet) or (P = FForm.vksumiTabSheet) then
    Result := 1
  else if P = FForm.optiscalertabsheet then
    Result := 2
  else if P = FForm.tweaksTabSheet then
    Result := 3
  else
    Result := -1;
end;

procedure TSidebarNavHelper.SetSaveBtnEnabled(AEnabled: Boolean);
begin
  FForm.saveBitBtn.Enabled := AEnabled;
  if AEnabled then
    FForm.saveBitBtn.Color := $008300   // original green
  else
    FForm.saveBitBtn.Color := $00666666; // grey when disabled
end;

procedure TSidebarNavHelper.SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
var
  i: Integer;
  Child: TControl;
begin
  ACtrl.Enabled := AEnabled;
  for i := 0 to ACtrl.ControlCount - 1 do
  begin
    Child := ACtrl.Controls[i];
    Child.Enabled := AEnabled;
    if Child is TWinControl then
      SetControlTreeEnabled(TWinControl(Child), AEnabled);
  end;
end;

procedure TSidebarNavHelper.RemoveTweaksFromGameFGMod(const AFGModFile: string);
var
  ConfigPath: string;
  Ini: TIniFile;
  DSpirvVal: string;
begin
  ConfigPath := ExtractFilePath(AFGModFile) + 'bgmod.conf';
  if not FileExists(ConfigPath) then Exit;
  Ini := TIniFile.Create(ConfigPath);
  try
    Ini.WriteString('Config', 'GOVERLAY_TWEAKS', '0');
    DSpirvVal := Ini.ReadString('Env', 'DXIL_SPIRV_CONFIG', '');
    Ini.EraseSection('Env');
    if DSpirvVal <> '' then
      Ini.WriteString('Env', 'DXIL_SPIRV_CONFIG', DSpirvVal);
  finally
    Ini.Free;
  end;
end;

procedure TSidebarNavHelper.RemoveOptiScalerGameFiles(const AGameCfgDir: string);
var
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(AGameCfgDir);
  ExecuteShellCommand(
    'rm -f ' +
    QuotedStr(Dir + 'OptiScaler.dll') + ' ' +
    QuotedStr(Dir + 'OptiScaler.ini') + ' ' +
    QuotedStr(Dir + 'fakenvapi.dll') + ' ' +
    QuotedStr(Dir + 'fakenvapi.ini') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_framegeneration_dx12.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_upscaler_dx12.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_vk.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_dx12.dll') + ' ' +
    QuotedStr(Dir + 'dlssg_to_fsr3_amd_is_better.dll') + ' ' +
    QuotedStr(Dir + 'libxess.dll') + ' ' +
    QuotedStr(Dir + 'libxess_dx11.dll') + ' ' +
    QuotedStr(Dir + 'libxess_fg.dll') + ' ' +
    QuotedStr(Dir + 'libxell.dll') + ' ' +
    QuotedStr(Dir + 'nvngx.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlss.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlssd.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlssg.dll') + ' ' +
    QuotedStr(Dir + 'setup_linux.sh') + ' ' +
    QuotedStr(Dir + 'setup_windows.bat') + ' ' +
    QuotedStr(Dir + '!! README_EXTRACT ALL FILES TO GAME FOLDER !!.txt') + ' 2>/dev/null');
  ExecuteShellCommand(
    'rm -rf ' +
    QuotedStr(Dir + 'D3D12_OptiScaler') + ' ' +
    QuotedStr(Dir + 'Licenses') + ' ' +
    QuotedStr(Dir + 'plugins') + ' 2>/dev/null');
end;

procedure TSidebarNavHelper.CopyOptiScalerGameFiles(const AGameCfgDir: string);
begin
  // Copy all files from .fgmod_original (no-clobber for scripts already present)
  ExecuteShellCommand('cp -rn ' + QuotedStr(GetFGModOriginalPath) + '/. ' +
    QuotedStr(AGameCfgDir) + ' 2>/dev/null');
end;

procedure TSidebarNavHelper.RestoreNavRailColors;
var
  i: Integer;
  BgActive, BgNormal, TextActive, TextInactive, ToggleColor: TColor;
begin
  if Length(FForm.FNavItems) = 0 then Exit;
  if CurrentTheme = tmLight then
  begin
    BgActive    := NAV_LIGHT_ACTIVE;
    BgNormal    := NAV_LIGHT_BG;
    TextActive  := clBlack;
    TextInactive := $00555555;
    ToggleColor := NAV_LIGHT_BG;
  end
  else
  begin
    BgActive    := NAV_COLOR_ACTIVE;
    BgNormal    := NAV_COLOR_BG;
    TextActive  := clWhite;
    TextInactive := $00AAAAAA;
    ToggleColor := $00221F1E;
  end;

  for i := 0 to High(FForm.FNavItems) do
  begin
    if i = FForm.FNavActive then
    begin
      FForm.FNavItems[i].Color       := BgActive;
      FForm.FNavIcons[i].Font.Color  := TextActive;
      FForm.FNavLabels[i].Font.Color := TextActive;
    end
    else
    begin
      FForm.FNavItems[i].Color       := BgNormal;
      FForm.FNavIcons[i].Font.Color  := TextInactive;
      FForm.FNavLabels[i].Font.Color := TextInactive;
    end;
    FForm.FNavItems[i].Invalidate;
  end;
  if Assigned(FForm.FNavToggleBtn) then
    FForm.FNavToggleBtn.Color := ToggleColor;
  if Assigned(FForm.FSettingsIconLbl) then
    FForm.FSettingsIconLbl.Font.Color := TextInactive;
end;

procedure TSidebarNavHelper.SetNavActive(AIndex: Integer);
var
  i: Integer;
  IconPath: string;
begin
  DbgLog(Format('  SetNavActive(%d) BEGIN', [AIndex]));
  FForm.FNavActive := AIndex;
  for i := 0 to High(FForm.FNavItems) do
  begin
    if i = AIndex then
    begin
      FForm.FNavIndicators[i].Visible     := True;
      FForm.FNavIndicators[i].Brush.Color := IfThen(i = 0, NAV_IND_GAMES, NAV_IND_TOOLS);
      FForm.FNavIndicators[i].Pen.Color   := IfThen(i = 0, NAV_IND_GAMES, NAV_IND_TOOLS);
      FForm.FNavIcons[i].Font.Color   := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      FForm.FNavLabels[i].Font.Color  := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      if (i = 3) and Assigned(FForm.FOptiScalerImg) then
      begin
        IconPath := FForm.GetAppBaseDir + 'assets/icons/scale-up2-active.png';
        if FileExists(IconPath) then
          try FForm.FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FForm.FMangoHudImg) then
      begin
        IconPath := FForm.GetAppBaseDir + 'assets/icons/mango-active.png';
        if FileExists(IconPath) then
          try FForm.FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
      end;
    end
    else
    begin
      FForm.FNavIndicators[i].Visible := False;
      FForm.FNavIcons[i].Font.Color   := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
      FForm.FNavLabels[i].Font.Color  := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
      if (i = 3) and Assigned(FForm.FOptiScalerImg) then
      begin
        IconPath := FForm.GetAppBaseDir + 'assets/icons/scale-up2.png';
        if FileExists(IconPath) then
          try FForm.FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FForm.FMangoHudImg) then
      begin
        IconPath := FForm.GetAppBaseDir + 'assets/icons/mango-inactive.png';
        if FileExists(IconPath) then
          try FForm.FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
      end;
    end;
    FForm.FNavItems[i].Invalidate;
  end;

  if FForm.FNavActive = 1 then
    FForm.StartCube
  else
    FForm.StopCube;
  DbgLog(Format('  SetNavActive(%d) END', [AIndex]));
end;

procedure TSidebarNavHelper.NavItemClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  if Assigned(FForm.FNavClickCBs[Idx]) then
    FForm.FNavClickCBs[Idx](FForm.FNavItems[Idx]);
end;

procedure TSidebarNavHelper.NavItemMouseEnter(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  FForm.FNavHoveredIdx := Idx;
  FForm.FNavItems[Idx].Invalidate;
end;

procedure TSidebarNavHelper.NavItemMouseLeave(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  FForm.FNavHoveredIdx := -1;
  FForm.FNavItems[Idx].Invalidate;
end;

procedure TSidebarNavHelper.NavItemPaint(Sender: TObject);
var
  P: TPanel;
  Idx: Integer;
  BgColor: TColor;
begin
  P   := TPanel(Sender);
  Idx := P.Tag;
  if CurrentTheme = tmLight then
  begin
    if Idx = FForm.FNavActive then      BgColor := NAV_LIGHT_ACTIVE
    else if Idx = FForm.FNavHoveredIdx then BgColor := NAV_LIGHT_HOVER
    else                              BgColor := NAV_LIGHT_BG;
  end
  else
  begin
    if Idx = FForm.FNavActive then      BgColor := NAV_COLOR_ACTIVE
    else if Idx = FForm.FNavHoveredIdx then BgColor := NAV_COLOR_HOVER
    else                              BgColor := NAV_COLOR_BG;
  end;
  P.Canvas.Brush.Color := BgColor;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);
end;

procedure TSidebarNavHelper.ApplyNavCollapsed;
var
  NavW: Integer;
begin
  NavW := IfThen(FForm.FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);
  FForm.FNavAnimCurrent := NavW * 10;
  ApplyNavWidth(NavW);

  if FForm.FNavCollapsed then
    FForm.FNavToggleBtn.Caption := '»'
  else
    FForm.FNavToggleBtn.Caption := '«';
end;

procedure TSidebarNavHelper.NavToggleClick(Sender: TObject);
var
  UIStateFile: string;
  SL: TStringList;
begin
  FForm.FNavCollapsed  := not FForm.FNavCollapsed;
  FForm.FNavAnimTarget := IfThen(FForm.FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);
  FForm.FNavAnimTimer.Enabled := True;

  // Persist state for next session
  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  SL := TStringList.Create;
  try
    SL.Add(IfThen(FForm.FNavCollapsed, '1', '0'));
    SL.Add(IfThen(FForm.FCubeAutoLaunch, '1', '0'));
    SL.SaveToFile(UIStateFile);
  finally
    SL.Free;
  end;
end;

procedure TSidebarNavHelper.NavAnimTick(Sender: TObject);
const
  EASE = 0.22; // fraction of remaining distance per tick (ease-out)
var
  PrevW, NextW: Integer;
begin
  PrevW := FForm.FNavAnimCurrent div 10;

  // Ease-out: move a fraction of remaining distance each tick
  FForm.FNavAnimCurrent := FForm.FNavAnimCurrent +
    Round((FForm.FNavAnimTarget * 10 - FForm.FNavAnimCurrent) * EASE);

  NextW := FForm.FNavAnimCurrent div 10;

  // Snap to target when close enough
  if Abs(NextW - FForm.FNavAnimTarget) <= 1 then
  begin
    FForm.FNavAnimCurrent := FForm.FNavAnimTarget * 10;
    FForm.FNavAnimTimer.Enabled := False;
    ApplyNavCollapsed;  // final state: show/hide labels etc.
    Exit;
  end;

  if NextW <> PrevW then
  begin
    DbgLog(Format('NavAnimTick: width %d -> %d', [PrevW, NextW]));
    ApplyNavWidth(NextW);
  end;
end;

procedure TSidebarNavHelper.ApplyNavWidth(AWidth: Integer);
var
  i, PanelLeft, ContentW: Integer;
  ShowLabels: Boolean;
begin
  DbgLog(Format('ApplyNavWidth(%d)', [AWidth]));
  PanelLeft  := AWidth;
  ShowLabels := AWidth > (NAV_W_COLLAPSED + NAV_W_EXPANDED) div 2;

  FForm.goverlayPaintBox.Width := AWidth;
  FForm.goverlayPanel.Left     := PanelLeft;
  FForm.goverlayPanel.Width    := Max(1, FForm.ClientWidth - PanelLeft);

  for i := 0 to High(FForm.FNavItems) do
  begin
    FForm.FNavItems[i].Width   := AWidth;
    FForm.FNavIcons[i].Left    := IfThen(ShowLabels, 16, (AWidth - NAV_ICON_SIZE) div 2);
    // In collapsed+game mode the button sits below the icon, so shift icon up
    FForm.FNavIcons[i].Top     := IfThen(ShowLabels or (FForm.FActiveGameName = ''),
                              (NAV_ITEM_H - NAV_ICON_SIZE) div 2, 8);
    FForm.FNavLabels[i].Visible := ShowLabels;
  end;

  // Show/hide the Games↔Tools separator section

  UpdateNavToolToggleVisibility(ShowLabels);

  if Assigned(FForm.FMangoHudImg) then
  begin
    FForm.FMangoHudImg.Left := IfThen(ShowLabels, 18, (AWidth - 24) div 2);
    FForm.FMangoHudImg.Top  := IfThen(ShowLabels or (FForm.FActiveGameName = ''),
                           (NAV_ITEM_H - 24) div 2, 8);
  end;
  if Assigned(FForm.FOptiScalerImg) then
  begin
    FForm.FOptiScalerImg.Left := IfThen(ShowLabels, 18, (AWidth - 24) div 2);
    FForm.FOptiScalerImg.Top  := IfThen(ShowLabels or (FForm.FActiveGameName = ''),
                             (NAV_ITEM_H - 24) div 2, 8);
  end;

  FForm.FNavToggleBtn.Left := IfThen(ShowLabels, AWidth - 28, AWidth - 26);

  FForm.goverlayimage.Visible  := ShowLabels;
  FForm.FNavSmallIcon.Visible  := not ShowLabels;
  FForm.FNavSmallIcon.Left     := (AWidth - 40) div 2;

  // dependenciesLabel and dependencieSpeedButton are permanently hidden;
  // dependency status is shown in the settings menu instead.

  // Reflow all content tabs whenever the sidebar width changes
  ContentW := Max(1, FForm.ClientWidth - AWidth);
  FForm.ReflowPresetTab(ContentW);
  FForm.ReflowVisualTab(ContentW);
  FForm.ReflowPerformanceTab(ContentW);
  FForm.ReflowMetricsTab(ContentW);
  FForm.ReflowExtrasTab(ContentW);
  FForm.ReflowOptiScalerTab(ContentW);
  FForm.ReflowOptiScalerTabNew(ContentW);
  FForm.ReflowVkBasaltTab(ContentW);
  FForm.ReflowVkSumiTab(ContentW);
  if FForm.FGamesLoaded then
    FForm.ReflowGamesGrid;

  // Repaint sidebar so the thumbnail scales with the nav width
  FForm.goverlayPaintBox.Invalidate;
end;

end.
