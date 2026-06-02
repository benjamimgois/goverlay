unit tweaks_md3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, Buttons, Grids, Graphics, Types, Dialogs, Math, Forms, overlayunit;

type
  TTweakRow = record
    CheckBox: TCheckBox;
    Category: string;
    VarName: string;
    Description: string;
  end;

const
  TWEAK_ROW_COUNT = 27;
  TWEAK_ROWS: array[0..TWEAK_ROW_COUNT - 1] of TTweakRow = (
    (CheckBox: nil; Category: 'General';    VarName: 'SteamDeck=1';                      Description: 'Simulate Steam Deck hardware'),
    (CheckBox: nil; Category: 'General';    VarName: '#gamemode';                        Description: 'Use Feral Gamemode set of optimisations'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_ENABLE_HDR=1';              Description: 'Enable HDR'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_ENABLE_WAYLAND=1';          Description: 'Enable Wayland'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_LOG=1';                     Description: 'Active Proton Logs'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_USE_SDL=1';                 Description: 'Use SDL input instead steam input'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'RADV_PERFTEST=rt,emulate_rt';      Description: 'Emulates Ray Tracing on GPUs without native support'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_HIDE_NVIDIA_GPU=1';         Description: 'Hide Nvidia GPU'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_ENABLE_NVAPI=1';            Description: 'Force enable NVAPI'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_USE_WINED3D=1';             Description: 'Use old WINED3D'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'MESA_LOADER_DRIVER_OVERRIDE=zink'; Description: 'Uses OpenGL over Vulkan translation (ZINK)'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'RADV_DEBUG=nofastclears';          Description: 'Disables fast clear optimization (AMD)'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_FSR4_UPGRADE=1';            Description: 'Automatically upgrade FSR to the latest version'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_DLSS_UPGRADE=1';            Description: 'Automatically upgrade DLSS to the latest version'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_XESS_UPGRADE=1';            Description: 'Automatically upgrade XeSS to the latest version'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_PRIORITY_HIGH=1';           Description: 'Higher priority for games'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_USE_WOW64=1';               Description: 'Windows 64-bit compatibility'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_FORCE_LARGE_ADDRESS_AWARE=1'; Description: 'Allows 32-bit games to use more than 2GB RAM'),
    (CheckBox: nil; Category: 'Performance';VarName: 'STAGING_SHARED_MEMORY=1';          Description: 'Memory optimization for AMD GPUs'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_NO_NTSYNC=1';               Description: 'Disable NTSYNC'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_HEAP_DELAY_FREE=1';         Description: 'Delay in heap allocation (Wine)'),
    (CheckBox: nil; Category: 'Graphics';   VarName: '#winedetectionenable=false';       Description: 'Enable RE Engine Ray Tracing workaround'),
    (CheckBox: nil; Category: 'Latency reduction'; VarName: 'LOW_LATENCY_LAYER=1';       Description: '[low_latency_layer] Expose to enable the layer'),
    (CheckBox: nil; Category: 'Latency reduction'; VarName: 'LOW_LATENCY_LAYER_REFLEX=1'; Description: '[low_latency_layer] Expose Reflex support (VK_NV_low_latency2) instead of AMD Anti-Lag 2'),
    (CheckBox: nil; Category: 'Latency reduction'; VarName: 'LOW_LATENCY_LAYER_SPOOF_NVIDIA=1'; Description: '[low_latency_layer] Report device as NVIDIA GPU (breaks FSR4 upgrade path)'),
    (CheckBox: nil; Category: 'Latency reduction'; VarName: 'DXVK_CONFIG="dxgi.hideAmdGpu = True"'; Description: '[low_latency_layer] Also hide AMD GPU, but it''s safer than SPOOF_NVIDIA'),
    (CheckBox: nil; Category: 'Latency reduction'; VarName: 'ENABLE_LAYER_MESA_ANTI_LAG=1';     Description: '[MESA] Enable AMD Anti-Lag 2')
  );

type
  TTweaksMD3Helper = class
  private
    FForm: Tgoverlayform;
  public
    constructor Create(AForm: Tgoverlayform);
    procedure InitTweaksMD3;
    procedure Paint(Sender: TObject);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScrollChange(Sender: TObject);
    procedure FABClick(Sender: TObject);
    procedure FABPaint(Sender: TObject);
    function ItemHeight: Integer;
    function HeaderHeight: Integer;
  end;

function GetTweakRowCheckBox(Form: Tgoverlayform; Index: Integer): TCheckBox;

implementation

function GetTweakRowCheckBox(Form: Tgoverlayform; Index: Integer): TCheckBox;
begin
  case Index of
    0: Result := Form.simdeckCheckBox;
    1: Result := Form.gamemodeCheckBox;
    2: Result := Form.enhdrCheckBox;
    3: Result := Form.enwaylandCheckBox;
    4: Result := Form.actprotonlogsCheckBox;
    5: Result := Form.usesdlCheckBox;
    6: Result := Form.emurtCheckBox;
    7: Result := Form.hidenvidiaCheckBox;
    8: Result := Form.forcenvapiCheckBox;
    9: Result := Form.wined3dCheckBox;
    10: Result := Form.forcezinkCheckBox;
    11: Result := Form.nofastclearsCheckBox;
    12: Result := Form.FFSR4UpgradeCheckBox;
    13: Result := Form.FDLSSUpgradeCheckBox;
    14: Result := Form.FXeSSUpgradeCheckBox;
    15: Result := Form.highpriCheckBox;
    16: Result := Form.wow64CheckBox;
    17: Result := Form.largeaddressCheckBox;
    18: Result := Form.stagememCheckBox;
    19: Result := Form.disablentsyncCheckBox;
    20: Result := Form.heapdelayCheckBox;
    21: Result := Form.FReEngineRTCheckBox;
    22: Result := Form.FLowLatencyCheckBox;
    23: Result := Form.FLowLatencyReflexCheckBox;
    24: Result := Form.FLowLatencySpoofNvidiaCheckBox;
    25: Result := Form.FLowLatencyHideAmdGpuCheckBox;
    26: Result := Form.FAntilagCheckBox;
  else
    Result := nil;
  end;
end;

constructor TTweaksMD3Helper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;

function TTweaksMD3Helper.ItemHeight: Integer;
begin
  Result := 44;
end;

function TTweaksMD3Helper.HeaderHeight: Integer;
begin
  Result := 36;
end;

procedure TTweaksMD3Helper.InitTweaksMD3;
var
  i: Integer;
const
  BG = $001A192E; // RGB(22, 25, 37) — dark blue-grey background
begin
  // Default all categories expanded
  FForm.FTweaksCatExpanded[0] := True;
  FForm.FTweaksCatExpanded[1] := True;
  FForm.FTweaksCatExpanded[2] := True;
  FForm.FTweaksCatExpanded[3] := True;
  FForm.FTweaksScrollPos := 0;
  FForm.FTweaksHoverIdx := -1;

  // Hide old LFM visual elements from the Tweaks tab
  FForm.tweaksImage.Visible := False;
  FForm.tweaksText.Visible  := False;
  FForm.tweaksText2.Visible := False;
  FForm.tweaksLabel.Visible := False;
  FForm.tweaksShape.Visible := False;

  // PaintBox fills the tab but leaves room for the bottom bar (40px + padding)
  FForm.FTweaksPaintBox := TPaintBox.Create(FForm);
  FForm.FTweaksPaintBox.Parent      := FForm.tweaksTabSheet;
  FForm.FTweaksPaintBox.Align       := alNone;
  FForm.FTweaksPaintBox.Anchors     := [akLeft, akTop, akRight, akBottom];
  FForm.FTweaksPaintBox.SetBounds(0, 0, FForm.tweaksTabSheet.ClientWidth,
                            FForm.tweaksTabSheet.ClientHeight - 50);
  FForm.FTweaksPaintBox.Color       := BG;
  FForm.FTweaksPaintBox.OnPaint     := @FForm.TweaksMD3Paint;
  FForm.FTweaksPaintBox.OnMouseMove := @FForm.TweaksMD3MouseMove;
  FForm.FTweaksPaintBox.OnMouseDown := @FForm.TweaksMD3MouseDown;
  FForm.FTweaksPaintBox.OnMouseWheel:= @FForm.TweaksMD3MouseWheel;
  
  // Vertical scrollbar (right edge)
  FForm.FTweaksScrollBar := TScrollBar.Create(FForm);
  FForm.FTweaksScrollBar.Parent      := FForm.tweaksTabSheet;
  FForm.FTweaksScrollBar.Kind        := sbVertical;
  FForm.FTweaksScrollBar.Align       := alRight;
  FForm.FTweaksScrollBar.Width       := 14;
  FForm.FTweaksScrollBar.Visible     := False;
  FForm.FTweaksScrollBar.OnChange    := @FForm.TweaksMD3ScrollChange;

  // Floating Action Button — circular "+"
  FForm.FTweaksFABBtn := TSpeedButton.Create(FForm);
  FForm.FTweaksFABBtn.Parent       := FForm.tweaksTabSheet;
  FForm.FTweaksFABBtn.Width        := 48;
  FForm.FTweaksFABBtn.Height       := 48;
  FForm.FTweaksFABBtn.Left         := FForm.tweaksTabSheet.ClientWidth - 64;
  FForm.FTweaksFABBtn.Top          := FForm.tweaksTabSheet.ClientHeight - 96; // above Save button
  FForm.FTweaksFABBtn.Anchors      := [akRight, akBottom];
  FForm.FTweaksFABBtn.Caption      := '+';
  FForm.FTweaksFABBtn.Font.Size    := 24;
  FForm.FTweaksFABBtn.Font.Style   := [fsBold];
  FForm.FTweaksFABBtn.Font.Color   := clWhite;
  FForm.FTweaksFABBtn.Flat         := True;
  FForm.FTweaksFABBtn.ShowHint     := True;
  FForm.FTweaksFABBtn.Hint         := 'Add custom environment variable';
  FForm.FTweaksFABBtn.OnClick      := @FForm.TweaksMD3FABClick;
  FForm.FTweaksFABBtn.OnPaint      := @FForm.TweaksMD3FABPaint;

  // Hidden checkbox for AMD Anti-Lag 2 (not in LFM — created dynamically)
  FForm.FAntilagCheckBox := TCheckBox.Create(FForm);
  FForm.FAntilagCheckBox.Parent      := FForm;
  FForm.FAntilagCheckBox.Visible     := False;
  FForm.FAntilagCheckBox.Name        := 'antilagCheckBox';
  FForm.FAntilagCheckBox.Caption     := 'Enable AMD Anti-Lag 2';

  // Hidden checkboxes for upgrade tweaks (not in LFM — created dynamically)
  FForm.FFSR4UpgradeCheckBox := TCheckBox.Create(FForm);
  FForm.FFSR4UpgradeCheckBox.Parent  := FForm;
  FForm.FFSR4UpgradeCheckBox.Visible := False;
  FForm.FFSR4UpgradeCheckBox.Name    := 'fsr4upgradeCheckBox';
  FForm.FFSR4UpgradeCheckBox.Caption := 'Automatically upgrade FSR to the latest version';

  FForm.FDLSSUpgradeCheckBox := TCheckBox.Create(FForm);
  FForm.FDLSSUpgradeCheckBox.Parent  := FForm;
  FForm.FDLSSUpgradeCheckBox.Visible := False;
  FForm.FDLSSUpgradeCheckBox.Name    := 'dlssupgradeCheckBox';
  FForm.FDLSSUpgradeCheckBox.Caption := 'Automatically upgrade DLSS to the latest version';

  FForm.FXeSSUpgradeCheckBox := TCheckBox.Create(FForm);
  FForm.FXeSSUpgradeCheckBox.Parent  := FForm;
  FForm.FXeSSUpgradeCheckBox.Visible := False;
  FForm.FXeSSUpgradeCheckBox.Name    := 'xessupgradeCheckBox';
  FForm.FXeSSUpgradeCheckBox.Caption := 'Automatically upgrade XeSS to the latest version';

  FForm.FReEngineRTCheckBox := TCheckBox.Create(FForm);
  FForm.FReEngineRTCheckBox.Parent  := FForm;
  FForm.FReEngineRTCheckBox.Visible := False;
  FForm.FReEngineRTCheckBox.Name    := 'reenginertCheckBox';
  FForm.FReEngineRTCheckBox.Caption := 'Enable RE Engine Ray Tracing workaround';

  FForm.FLowLatencyCheckBox := TCheckBox.Create(FForm);
  FForm.FLowLatencyCheckBox.Parent  := FForm;
  FForm.FLowLatencyCheckBox.Visible := False;
  FForm.FLowLatencyCheckBox.Name    := 'lowLatencyCheckBox';
  FForm.FLowLatencyCheckBox.Caption := 'Expose to enable the layer';

  FForm.FLowLatencyReflexCheckBox := TCheckBox.Create(FForm);
  FForm.FLowLatencyReflexCheckBox.Parent  := FForm;
  FForm.FLowLatencyReflexCheckBox.Visible := False;
  FForm.FLowLatencyReflexCheckBox.Name    := 'lowLatencyReflexCheckBox';
  FForm.FLowLatencyReflexCheckBox.Caption := 'Expose Reflex support (VK_NV_low_latency2) instead of AMD Anti-Lag 2';

  FForm.FLowLatencySpoofNvidiaCheckBox := TCheckBox.Create(FForm);
  FForm.FLowLatencySpoofNvidiaCheckBox.Parent  := FForm;
  FForm.FLowLatencySpoofNvidiaCheckBox.Visible := False;
  FForm.FLowLatencySpoofNvidiaCheckBox.Name    := 'lowLatencySpoofNvidiaCheckBox';
  FForm.FLowLatencySpoofNvidiaCheckBox.Caption := 'Report device as NVIDIA GPU (breaks FSR4 upgrade path)';

  FForm.FLowLatencyHideAmdGpuCheckBox := TCheckBox.Create(FForm);
  FForm.FLowLatencyHideAmdGpuCheckBox.Parent  := FForm;
  FForm.FLowLatencyHideAmdGpuCheckBox.Visible := False;
  FForm.FLowLatencyHideAmdGpuCheckBox.Name    := 'lowLatencyHideAmdGpuCheckBox';
  FForm.FLowLatencyHideAmdGpuCheckBox.Caption := 'Also hide AMD GPU, but it''s safer than SPOOF_NVIDIA';

  // Hidden grid used as data store for custom variables (visual is PaintBox)
  FForm.FTweaksGrid := TStringGrid.Create(FForm);
  FForm.FTweaksGrid.Parent      := FForm;
  FForm.FTweaksGrid.Visible     := False;
  FForm.FTweaksGrid.ColCount    := 4;
  FForm.FTweaksGrid.RowCount    := 1 + TWEAK_ROW_COUNT;
  FForm.FTweaksGrid.FixedRows   := 1;
  for i := 0 to TWEAK_ROW_COUNT - 1 do
  begin
    FForm.FTweaksGrid.Cells[0, i + 1] := '0';
    FForm.FTweaksGrid.Cells[1, i + 1] := TWEAK_ROWS[i].Category;
    FForm.FTweaksGrid.Cells[2, i + 1] := TWEAK_ROWS[i].VarName;
    FForm.FTweaksGrid.Cells[3, i + 1] := TWEAK_ROWS[i].Description;
  end;
end;

procedure TTweaksMD3Helper.FABPaint(Sender: TObject);
var
  Btn: TSpeedButton;
  R: TRect;
  PlusW, PlusH: Integer;
begin
  Btn := Sender as TSpeedButton;
  R := Rect(0, 0, Btn.Width, Btn.Height);

  // Circle background
  Btn.Canvas.Brush.Color := RGBToColor(48, 190, 240); // accent cyan
  Btn.Canvas.Pen.Color   := RGBToColor(48, 190, 240);
  Btn.Canvas.Ellipse(R);

  // Shadow ring
  Btn.Canvas.Pen.Color := RGBToColor(38, 160, 210);
  Btn.Canvas.Ellipse(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1);

  // Draw "+" manually in the centre
  Btn.Canvas.Font.Name  := 'DejaVu Sans';
  Btn.Canvas.Font.Size  := 22;
  Btn.Canvas.Font.Style := [fsBold];
  Btn.Canvas.Font.Color := clWhite;
  PlusW := Btn.Canvas.TextWidth('+');
  PlusH := Btn.Canvas.TextHeight('+');
  Btn.Canvas.TextOut((Btn.Width - PlusW) div 2, (Btn.Height - PlusH) div 2 - 1, '+');
end;

procedure TTweaksMD3Helper.Paint(Sender: TObject);

  procedure DrawToggle(ACanvas: TCanvas; AX, AY: Integer; AOn: Boolean);
  var
    TrackColor: TColor;
    ThumbLeft, ThumbTop, ThumbRight, ThumbBottom: Integer;
  const
    TRACK_W = 44;
    TRACK_H = 24;
    THUMB_D = 18;
    RADIUS  = 12;
    Pad     = 3;
  begin
    // Track colour
    if AOn then
      TrackColor := RGBToColor(60, 180, 80)   // green
    else
      TrackColor := RGBToColor(70, 70, 70);   // grey

    ACanvas.Brush.Color := TrackColor;
    ACanvas.Pen.Color   := TrackColor;
    ACanvas.Pen.Width   := 1;

    // Central rectangle
    ACanvas.FillRect(AX + RADIUS, AY, AX + TRACK_W - RADIUS, AY + TRACK_H);

    // Left cap (semi-circle)
    ACanvas.Ellipse(AX, AY, AX + RADIUS * 2, AY + TRACK_H);

    // Right cap (semi-circle)
    ACanvas.Ellipse(AX + TRACK_W - RADIUS * 2, AY, AX + TRACK_W, AY + TRACK_H);

    // Thumb
    if AOn then
      ThumbLeft := AX + TRACK_W - THUMB_D - Pad
    else
      ThumbLeft := AX + Pad;
    ThumbTop    := AY + (TRACK_H - THUMB_D) div 2;
    ThumbRight  := ThumbLeft + THUMB_D;
    ThumbBottom := ThumbTop + THUMB_D;

    // Subtle outer ring/shadow
    ACanvas.Brush.Color := RGBToColor(200, 200, 200);
    ACanvas.Pen.Color   := RGBToColor(160, 160, 160);
    ACanvas.Pen.Width   := 1;
    ACanvas.Ellipse(ThumbLeft, ThumbTop, ThumbRight, ThumbBottom);

    // White thumb body
    ACanvas.Brush.Color := clWhite;
    ACanvas.Pen.Color   := clWhite;
    ACanvas.Pen.Width   := 1;
    ACanvas.Ellipse(ThumbLeft + 2, ThumbTop + 2, ThumbRight - 2, ThumbBottom - 2);
  end;

  procedure DrawHeader(ACanvas: TCanvas; const ARect: TRect; const ACat: string; const AIcon: string; AExpanded: Boolean; AHover: Boolean);
  var
    TxtH: Integer;
    Arrow: string;
    IconX, TextX: Integer;
  begin
    if AHover then
      ACanvas.Brush.Color := RGBToColor(55, 95, 150)   // bright blue
    else
      ACanvas.Brush.Color := RGBToColor(40, 70, 115);  // dark blue
    ACanvas.FillRect(ARect);

    // Arrow (expand/collapse indicator)
    if AExpanded then
      Arrow := '▼'
    else
      Arrow := '▶';
    ACanvas.Font.Color  := RGBToColor(200, 200, 200);
    ACanvas.Font.Size   := 9;
    ACanvas.Font.Style  := [];
    ACanvas.Font.Name   := 'DejaVu Sans';
    ACanvas.TextOut(ARect.Left + 12, ARect.Top + (ARect.Height - ACanvas.TextHeight(Arrow)) div 2, Arrow);

    // Icon
    IconX := ARect.Left + 32;
    ACanvas.Font.Name   := 'Noto Color Emoji';
    ACanvas.Font.Size   := 14;
    ACanvas.Font.Style  := [];
    ACanvas.TextOut(IconX, ARect.Top + (ARect.Height - ACanvas.TextHeight(AIcon)) div 2, AIcon);

    // Category name
    TextX := IconX + 22;
    ACanvas.Font.Name  := 'DejaVu Sans';
    ACanvas.Font.Color := clWhite;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Size  := 9;
    TxtH := ACanvas.TextHeight(ACat);
    ACanvas.TextOut(TextX, ARect.Top + (ARect.Height - TxtH) div 2, ACat);
  end;

  procedure DrawItem(ACanvas: TCanvas; const ARect: TRect; const AVar, ADesc: string;
                     AChecked, AHover: Boolean; AIsCustom: Boolean);
  var
    ToggleX, ToggleY, DelX: Integer;
    VarRect, DescRect: TRect;
    Prefix, PrefixMesa, RestDesc: string;
    OldColor: TColor;
    PrefixW: Integer;
  const
    PAD = 16;
    DEL_W = 24;
  begin
    // Background
    if AChecked then
    begin
      if AHover then
        ACanvas.Brush.Color := RGBToColor(32, 44, 65)   // slightly lighter active slate-blue
      else
        ACanvas.Brush.Color := RGBToColor(25, 33, 48);  // subtle active slate-blue
    end
    else if AHover then
      ACanvas.Brush.Color := RGBToColor(50, 55, 70)   // grey-blue
    else
      ACanvas.Brush.Color := RGBToColor(22, 25, 37);  // dark background
    ACanvas.FillRect(ARect);

    // Bottom hairline separator
    ACanvas.Pen.Color := RGBToColor(40, 45, 60);
    ACanvas.Line(ARect.Left, ARect.Bottom - 1, ARect.Right, ARect.Bottom - 1);

    // Delete "×" button for custom rows (left side)
    if AIsCustom then
    begin
      DelX := ARect.Left + PAD;
      ACanvas.Font.Name  := 'DejaVu Sans';
      ACanvas.Font.Size  := 12;
      ACanvas.Font.Style := [fsBold];
      ACanvas.Font.Color := RGBToColor(220, 80, 80);  // red
      ACanvas.TextOut(DelX, ARect.Top + (ARect.Height - ACanvas.TextHeight('×')) div 2, '×');
    end;

    // Toggle switch (right side)
    ToggleX := ARect.Right - 60;
    ToggleY := ARect.Top + (ARect.Height - 24) div 2;
    DrawToggle(ACanvas, ToggleX, ToggleY, AChecked);

    // Description (top line, prominent)
    DescRect := ARect;
    if AIsCustom then
      DescRect.Left := ARect.Left + PAD + DEL_W + 4
    else
      DescRect.Left := ARect.Left + PAD;
    DescRect.Right := ToggleX - PAD;
    DescRect.Bottom := DescRect.Top + DescRect.Height div 2 + 2;
    ACanvas.Font.Name  := 'DejaVu Sans';
    ACanvas.Font.Size  := 9;
    ACanvas.Font.Style := [];
    if AIsCustom then
      ACanvas.Font.Color := RGBToColor(160, 160, 160)
    else
      ACanvas.Font.Color := clWhite;

    Prefix := '[low_latency_layer]';
    PrefixMesa := '[MESA]';
    if (Pos(Prefix, ADesc) = 1) then
    begin
      OldColor := ACanvas.Font.Color;
      ACanvas.Font.Color := RGBToColor(240, 180, 50); // golden yellow/orange
      ACanvas.TextRect(DescRect, DescRect.Left, DescRect.Top + 2, Prefix);
      PrefixW := ACanvas.TextWidth(Prefix);
      ACanvas.Font.Color := OldColor;
      RestDesc := Copy(ADesc, Length(Prefix) + 1, MaxInt);
      ACanvas.TextRect(DescRect, DescRect.Left + PrefixW, DescRect.Top + 2, RestDesc);
    end
    else if (Pos(PrefixMesa, ADesc) = 1) then
    begin
      OldColor := ACanvas.Font.Color;
      ACanvas.Font.Color := RGBToColor(48, 190, 240); // Cyan
      ACanvas.TextRect(DescRect, DescRect.Left, DescRect.Top + 2, PrefixMesa);
      PrefixW := ACanvas.TextWidth(PrefixMesa);
      ACanvas.Font.Color := OldColor;
      RestDesc := Copy(ADesc, Length(PrefixMesa) + 1, MaxInt);
      ACanvas.TextRect(DescRect, DescRect.Left + PrefixW, DescRect.Top + 2, RestDesc);
    end
    else
    begin
      ACanvas.TextRect(DescRect, DescRect.Left, DescRect.Top + 2, ADesc);
    end;

    // Variable name (below description, monospace, dimmed)
    VarRect := ARect;
    if AIsCustom then
      VarRect.Left := ARect.Left + PAD + DEL_W + 4
    else
      VarRect.Left := ARect.Left + PAD;
    VarRect.Right := ToggleX - PAD;
    VarRect.Top := DescRect.Bottom;
    ACanvas.Font.Name  := 'DejaVu Sans Mono';
    ACanvas.Font.Size  := 8;
    ACanvas.Font.Color := RGBToColor(150, 150, 150);
    ACanvas.TextRect(VarRect, VarRect.Left, VarRect.Top, AVar);
  end;

var
  PB: TPaintBox;
  Y, ItemH, HeadH: Integer;
  i, CatIdx: Integer;
  CatNames: array[0..3] of string;
  CatExpanded: array[0..3] of Boolean;
  HoverIdx, RowIdx: Integer;
  R: TRect;
  Chk: TCheckBox;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Brush.Color := RGBToColor(22, 25, 37);
  PB.Canvas.FillRect(PB.ClientRect);

  ItemH := ItemHeight;
  HeadH := HeaderHeight;
  CatNames[0] := 'General';
  CatNames[1] := 'Graphics';
  CatNames[2] := 'Performance';
  CatNames[3] := 'Latency reduction';
  CatExpanded := FForm.FTweaksCatExpanded;

  Y := -FForm.FTweaksScrollPos;
  RowIdx := 0;
  HoverIdx := FForm.FTweaksHoverIdx;

  for CatIdx := 0 to 3 do
  begin
    // Category header with icon
    R := Rect(0, Y, PB.Width, Y + HeadH);
    case CatIdx of
      0: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '⚙', CatExpanded[CatIdx], HoverIdx = RowIdx);
      1: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '🎮', CatExpanded[CatIdx], HoverIdx = RowIdx);
      2: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '⚡', CatExpanded[CatIdx], HoverIdx = RowIdx);
      3: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '⏱', CatExpanded[CatIdx], HoverIdx = RowIdx);
    end;
    Inc(Y, HeadH);
    Inc(RowIdx);

    if CatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatNames[CatIdx] then Continue;
        Chk := GetTweakRowCheckBox(FForm, i);
        R := Rect(0, Y, PB.Width, Y + ItemH);
        DrawItem(PB.Canvas, R, TWEAK_ROWS[i].VarName, TWEAK_ROWS[i].Description,
                 Assigned(Chk) and Chk.Checked, HoverIdx = RowIdx, False);
        Inc(Y, ItemH);
        Inc(RowIdx);
      end;
    end;
  end;

  // Custom variables header
  R := Rect(0, Y, PB.Width, Y + HeadH);
  DrawHeader(PB.Canvas, R, 'Custom', '✎', True, HoverIdx = RowIdx);
  Inc(Y, HeadH);
  Inc(RowIdx);

  // Custom rows from legacy grid (if any) or hidden listbox
  if Assigned(FForm.FTweaksGrid) and (FForm.FTweaksGrid.RowCount > 1 + TWEAK_ROW_COUNT) then
  begin
    for i := 1 + TWEAK_ROW_COUNT to FForm.FTweaksGrid.RowCount - 1 do
    begin
      R := Rect(0, Y, PB.Width, Y + ItemH);
      DrawItem(PB.Canvas, R, FForm.FTweaksGrid.Cells[2, i], FForm.FTweaksGrid.Cells[3, i],
               FForm.FTweaksGrid.Cells[0, i] = '1', HoverIdx = RowIdx, True);
      Inc(Y, ItemH);
      Inc(RowIdx);
    end;
  end;

  // Update scrollbar
  if Y + FForm.FTweaksScrollPos > PB.Height then
  begin
    FForm.FTweaksScrollBar.Max := Y + FForm.FTweaksScrollPos - PB.Height + 20;
    FForm.FTweaksScrollBar.PageSize := PB.Height;
    FForm.FTweaksScrollBar.Visible := True;
  end
  else
    FForm.FTweaksScrollBar.Visible := False;
end;

procedure TTweaksMD3Helper.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  OldHover, ItemH, HeadH, RowIdx, i, CatIdx: Integer;
  YPos: Integer;
  CatName: string;
  IsLatencyTweak: Boolean;
begin
  PB := Sender as TPaintBox;
  OldHover := FForm.FTweaksHoverIdx;
  FForm.FTweaksHoverIdx := -1;
  IsLatencyTweak := False;

  ItemH := ItemHeight;
  HeadH := HeaderHeight;
  YPos := -FForm.FTweaksScrollPos;
  RowIdx := 0;

  for CatIdx := 0 to 3 do
  begin
    case CatIdx of
      0: CatName := 'General';
      1: CatName := 'Graphics';
      2: CatName := 'Performance';
      3: CatName := 'Latency reduction';
    end;

    // Header
    if (Y >= YPos) and (Y < YPos + HeadH) then
    begin
      FForm.FTweaksHoverIdx := RowIdx;
      Break;
    end;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if FForm.FTweaksCatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatName then Continue;
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FForm.FTweaksHoverIdx := RowIdx;
          if CatName = 'Latency reduction' then
            IsLatencyTweak := True;
          Break;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
      if FForm.FTweaksHoverIdx >= 0 then Break;
    end;
  end;

  // Custom section
  if FForm.FTweaksHoverIdx < 0 then
  begin
    if (Y >= YPos) and (Y < YPos + HeadH) then
      FForm.FTweaksHoverIdx := RowIdx;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if Assigned(FForm.FTweaksGrid) then
      for i := 1 + TWEAK_ROW_COUNT to FForm.FTweaksGrid.RowCount - 1 do
      begin
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FForm.FTweaksHoverIdx := RowIdx;
          Break;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
  end;

  if IsLatencyTweak then
  begin
    if PB.Hint <> 'Needs Korthos low latency layer installed' then
    begin
      PB.Hint := 'Needs Korthos low latency layer installed';
      PB.ShowHint := True;
    end;
  end
  else
  begin
    if PB.Hint <> '' then
    begin
      PB.Hint := '';
      PB.ShowHint := False;
      Application.CancelHint;
    end;
  end;

  if OldHover <> FForm.FTweaksHoverIdx then
    PB.Invalidate;
end;

procedure TTweaksMD3Helper.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  ItemH, HeadH, RowIdx, i, CatIdx: Integer;
  YPos: Integer;
  CatName: string;
  ToggleX: Integer;
  Chk: TCheckBox;
begin
  if Button <> mbLeft then Exit;
  PB := Sender as TPaintBox;
  ItemH := ItemHeight;
  HeadH := HeaderHeight;
  YPos := -FForm.FTweaksScrollPos;
  RowIdx := 0;

  for CatIdx := 0 to 3 do
  begin
    case CatIdx of
      0: CatName := 'General';
      1: CatName := 'Graphics';
      2: CatName := 'Performance';
      3: CatName := 'Latency reduction';
    end;

    // Header click = toggle expand
    if (Y >= YPos) and (Y < YPos + HeadH) then
    begin
      FForm.FTweaksCatExpanded[CatIdx] := not FForm.FTweaksCatExpanded[CatIdx];
      PB.Invalidate;
      Exit;
    end;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if FForm.FTweaksCatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatName then Continue;
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          // Check if click is on toggle (right side)
          ToggleX := PB.Width - 66;
          if X >= ToggleX then
          begin
            Chk := GetTweakRowCheckBox(FForm, i);
            if Assigned(Chk) then
            begin
              if (Chk = FForm.FAntilagCheckBox) and (not Chk.Checked) and
                 (FForm.FLowLatencyCheckBox.Checked or FForm.FLowLatencyReflexCheckBox.Checked or
                  FForm.FLowLatencySpoofNvidiaCheckBox.Checked or FForm.FLowLatencyHideAmdGpuCheckBox.Checked) then
              begin
                ShowMessage('You cannot enable AMD Anti-Lag 2 [MESA] while any Korthos low latency layer option is active.');
              end
              else if ((Chk = FForm.FLowLatencyCheckBox) or (Chk = FForm.FLowLatencyReflexCheckBox) or
                       (Chk = FForm.FLowLatencySpoofNvidiaCheckBox) or (Chk = FForm.FLowLatencyHideAmdGpuCheckBox)) and
                      (not Chk.Checked) and FForm.FAntilagCheckBox.Checked then
              begin
                ShowMessage('You cannot enable any Korthos low latency layer option while AMD Anti-Lag 2 [MESA] is active.');
              end
              else if (Chk = FForm.FLowLatencySpoofNvidiaCheckBox) and (not Chk.Checked) and FForm.FLowLatencyHideAmdGpuCheckBox.Checked then
                ShowMessage('You cannot enable both ''LOW_LATENCY_LAYER_SPOOF_NVIDIA'' and ''DXVK_CONFIG="dxgi.hideAmdGpu = True"'' at the same time.')
              else if (Chk = FForm.FLowLatencyHideAmdGpuCheckBox) and (not Chk.Checked) and FForm.FLowLatencySpoofNvidiaCheckBox.Checked then
                ShowMessage('You cannot enable both ''LOW_LATENCY_LAYER_SPOOF_NVIDIA'' and ''DXVK_CONFIG="dxgi.hideAmdGpu = True"'' at the same time.')
              else
              begin
                Chk.Checked := not Chk.Checked;
                PB.Invalidate;
              end;
            end;
          end;
          Exit;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
    end;
  end;

  // Custom section header (no toggle)
  if (Y >= YPos) and (Y < YPos + HeadH) then
  begin
    Inc(YPos, HeadH);
    Inc(RowIdx);
  end
  else
    Inc(YPos, HeadH);

  // Custom rows
  if Assigned(FForm.FTweaksGrid) then
    for i := 1 + TWEAK_ROW_COUNT to FForm.FTweaksGrid.RowCount - 1 do
    begin
      if (Y >= YPos) and (Y < YPos + ItemH) then
      begin
        // Delete button hit area (left side, ~24x24 px)
        if (X >= 16) and (X < 40) then
        begin
          // Remove custom row from grid
          FForm.FTweaksGrid.DeleteRow(i);
          PB.Invalidate;
          Exit;
        end;
        ToggleX := PB.Width - 66;
        if X >= ToggleX then
        begin
          if FForm.FTweaksGrid.Cells[0, i] = '1' then
            FForm.FTweaksGrid.Cells[0, i] := '0'
          else
            FForm.FTweaksGrid.Cells[0, i] := '1';
          PB.Invalidate;
        end;
        Exit;
      end;
      Inc(YPos, ItemH);
    end;
end;

procedure TTweaksMD3Helper.MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  FForm.FTweaksScrollPos := FForm.FTweaksScrollPos - WheelDelta div 4;
  if FForm.FTweaksScrollPos < 0 then FForm.FTweaksScrollPos := 0;
  if FForm.FTweaksScrollPos > FForm.FTweaksScrollBar.Max then FForm.FTweaksScrollPos := FForm.FTweaksScrollBar.Max;
  FForm.FTweaksScrollBar.Position := FForm.FTweaksScrollPos;
  FForm.FTweaksPaintBox.Invalidate;
  Handled := True;
end;

procedure TTweaksMD3Helper.ScrollChange(Sender: TObject);
begin
  FForm.FTweaksScrollPos := FForm.FTweaksScrollBar.Position;
  FForm.FTweaksPaintBox.Invalidate;
end;

procedure TTweaksMD3Helper.FABClick(Sender: TObject);
var
  Val: string;
  Row: Integer;
begin
  Val := Trim(InputBox('Custom Environment Variable',
                       'Enter the variable (e.g. MY_VAR=1):', ''));
  if Val = '' then Exit;

  if not Assigned(FForm.FTweaksGrid) then Exit;
  Row := FForm.FTweaksGrid.RowCount;
  FForm.FTweaksGrid.RowCount := Row + 1;
  FForm.FTweaksGrid.Cells[0, Row] := '1';
  FForm.FTweaksGrid.Cells[1, Row] := 'Custom';
  FForm.FTweaksGrid.Cells[2, Row] := Val;
  FForm.FTweaksGrid.Cells[3, Row] := '';
  FForm.FTweaksPaintBox.Invalidate;
end;

end.
