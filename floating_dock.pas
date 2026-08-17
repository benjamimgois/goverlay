unit floating_dock;

{$mode objfpc}{$H+}

// ---------------------------------------------------------------------------
//  TFloatingActionDock — a compact pill-style floating action bar that sits
//  above the bottom-right corner of goverlayPanel.  It hosts up to three
//  contextual buttons:
//
//    [ ▶ Preview ]   (optional — hidden on tabs without 3D support)
//    [  ☰  Menu  ]
//    [ ✦ Finish Config ]  (primary accent button, always visible)
//
//  Call UpdateForTab() whenever the active navigation tab changes.
// ---------------------------------------------------------------------------

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, Buttons, StdCtrls,
  LCLIntf, LCLType, Math;

type

  { TFloatingActionDock }
  TFloatingActionDock = class(TObject)
  private
    FParent:       TWinControl;   // goverlayPanel or similar
    FDockPanel:    TPanel;        // invisible container — clips all children

    // Inner pill paint box (draws the pill background)
    FPillBox:      TPaintBox;

    // Buttons (in pill, right-to-left layout)
    FFinishBtn:    TSpeedButton;
    FMenuBtn:      TSpeedButton;
    FPreviewBtn:   TSpeedButton;

    FPreviewVisible: Boolean;     // current state

    FOnPreviewClick: TNotifyEvent;
    FOnMenuClick:    TNotifyEvent;
    FOnFinishClick:  TNotifyEvent;

    procedure PillPaint(Sender: TObject);
    procedure FinishBtnClick(Sender: TObject);
    procedure MenuBtnClick(Sender: TObject);
    procedure PreviewBtnClick(Sender: TObject);
    procedure LayoutButtons;

  public
    constructor Create(AParent: TWinControl);
    destructor  Destroy; override;

    // Call after the parent has been resized or when switching tabs.
    // AShowPreview: True for tabs that support 3D preview (MangoHud, vkBasalt, vkSumi)
    procedure UpdateForTab(AShowPreview: Boolean);

    procedure BringToFront;

    property OnPreviewClick: TNotifyEvent read FOnPreviewClick write FOnPreviewClick;
    property OnMenuClick:    TNotifyEvent read FOnMenuClick    write FOnMenuClick;
    property OnFinishClick:  TNotifyEvent read FOnFinishClick  write FOnFinishClick;
  end;

implementation

// ---------------------------------------------------------------------------
// Geometry constants
// ---------------------------------------------------------------------------
const
  DOCK_RIGHT    = 24;   // distance from right edge of parent
  DOCK_BOTTOM   = 24;   // distance from bottom edge of parent
  BTN_H         = 36;   // button height
  BTN_GAP       = 4;    // gap between buttons
  PREVIEW_W     = 108;  // width of preview button
  MENU_W        = 44;   // width of menu button
  FINISH_W      = 140;  // width of finish button
  INNER_PAD_X   = 8;    // horizontal padding inside pill
  INNER_PAD_Y   = 6;    // vertical padding inside pill

  // Pill colours
  CLR_PILL_BG     = $2A2218;   // #18222A — very dark navy surface
  CLR_PILL_BORDER = $4E4030;   // #30404E — muted border
  CLR_PILL_SHADOW = $00000000; // not used directly (we draw manually)

  // Finish button accent
  CLR_FINISH_BG   = $B07820;   // #2078B0 — vivid cyan (BGR)
  CLR_FINISH_HV   = $C08830;   // hover lighten

  CLR_BTN_BG      = $3A2E22;   // standard button surface
  CLR_BTN_FG      = $C8C0B8;   // standard button text (muted white)
  CLR_FINISH_FG   = $FFFFFF;   // finish button text (white)
  CLR_ACCENT_FG   = $F0BE30;   // accent colour for finish label

// ---------------------------------------------------------------------------
// Constructor / Destructor
// ---------------------------------------------------------------------------

constructor TFloatingActionDock.Create(AParent: TWinControl);
var
  TotalPillW, TotalPillH: Integer;
begin
  inherited Create;
  FParent := AParent;
  FPreviewVisible := True;

  // Total pill size (calculated for max 3 buttons)
  TotalPillW := INNER_PAD_X * 2
              + PREVIEW_W + BTN_GAP
              + MENU_W    + BTN_GAP
              + FINISH_W;
  TotalPillH := BTN_H + INNER_PAD_Y * 2;

  // Invisible anchor panel — just used for positioning/clipping
  FDockPanel               := TPanel.Create(AParent);
  FDockPanel.Parent        := AParent;
  FDockPanel.BevelOuter    := bvNone;
  FDockPanel.BevelInner    := bvNone;
  FDockPanel.Color         := clNone;
  FDockPanel.ParentBackground := True;
  FDockPanel.Width         := TotalPillW;
  FDockPanel.Height        := TotalPillH;
  FDockPanel.Anchors       := [akRight, akBottom];
  FDockPanel.Left          := AParent.ClientWidth - TotalPillW - DOCK_RIGHT;
  FDockPanel.Top           := AParent.ClientHeight - TotalPillH - DOCK_BOTTOM;

  // Pill background paint box (fills the dock panel)
  FPillBox             := TPaintBox.Create(FDockPanel);
  FPillBox.Parent      := FDockPanel;
  FPillBox.Left        := 0;
  FPillBox.Top         := 0;
  FPillBox.Width       := FDockPanel.Width;
  FPillBox.Height      := FDockPanel.Height;
  FPillBox.Anchors     := [akLeft, akRight, akTop, akBottom];
  FPillBox.OnPaint     := @PillPaint;

  // ---- Preview button ----
  FPreviewBtn             := TSpeedButton.Create(FDockPanel);
  FPreviewBtn.Parent      := FDockPanel;
  FPreviewBtn.Caption     := ' ▶  Preview';
  FPreviewBtn.Font.Name   := 'Noto Sans';
  FPreviewBtn.Font.Size   := 9;
  FPreviewBtn.Font.Style  := [fsBold];
  FPreviewBtn.Font.Color  := RGBToColor(180, 190, 205);
  FPreviewBtn.Flat        := True;
  FPreviewBtn.OnClick     := @PreviewBtnClick;
  FPreviewBtn.ShowHint    := True;
  FPreviewBtn.Hint        := 'Launch a quick 3D preview (pascube / vkcube)';

  // ---- Menu button ----
  FMenuBtn                := TSpeedButton.Create(FDockPanel);
  FMenuBtn.Parent         := FDockPanel;
  FMenuBtn.Caption        := ' ☰';
  FMenuBtn.Font.Name      := 'Noto Sans';
  FMenuBtn.Font.Size      := 12;
  FMenuBtn.Font.Style     := [];
  FMenuBtn.Font.Color     := RGBToColor(180, 190, 205);
  FMenuBtn.Flat           := True;
  FMenuBtn.OnClick        := @MenuBtnClick;
  FMenuBtn.ShowHint       := True;
  FMenuBtn.Hint           := 'Options & presets menu';

  // ---- Finish button ----
  FFinishBtn              := TSpeedButton.Create(FDockPanel);
  FFinishBtn.Parent       := FDockPanel;
  FFinishBtn.Caption      := ' ✦ Finish Config';
  FFinishBtn.Font.Name    := 'Noto Sans';
  FFinishBtn.Font.Size    := 9;
  FFinishBtn.Font.Style   := [fsBold];
  FFinishBtn.Font.Color   := clWhite;
  FFinishBtn.Flat         := True;
  FFinishBtn.OnClick      := @FinishBtnClick;
  FFinishBtn.ShowHint     := True;
  FFinishBtn.Hint         := 'Get your Steam / Heroic launch command';

  LayoutButtons;
end;

destructor TFloatingActionDock.Destroy;
begin
  // FDockPanel and its children are owned by AParent — do not free here
  FDockPanel.Visible := False;
  inherited;
end;

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.LayoutButtons;
var
  X, TotalPillW: Integer;
begin
  // Determine total pill width based on preview visibility
  if FPreviewVisible then
    TotalPillW := INNER_PAD_X * 2
                + PREVIEW_W + BTN_GAP
                + MENU_W    + BTN_GAP
                + FINISH_W
  else
    TotalPillW := INNER_PAD_X * 2
                + MENU_W + BTN_GAP
                + FINISH_W;

  // Resize the dock panel
  FDockPanel.Width  := TotalPillW;
  FDockPanel.Left   := FParent.ClientWidth - TotalPillW - DOCK_RIGHT;

  // Resize pill box to match
  FPillBox.Width := TotalPillW;

  // Place buttons left-to-right inside pill
  X := INNER_PAD_X;

  if FPreviewVisible then
  begin
    FPreviewBtn.SetBounds(X, INNER_PAD_Y, PREVIEW_W, BTN_H);
    FPreviewBtn.Visible := True;
    Inc(X, PREVIEW_W + BTN_GAP);
  end
  else
    FPreviewBtn.Visible := False;

  FMenuBtn.SetBounds(X, INNER_PAD_Y, MENU_W, BTN_H);
  Inc(X, MENU_W + BTN_GAP);

  FFinishBtn.SetBounds(X, INNER_PAD_Y, FINISH_W, BTN_H);
end;

// ---------------------------------------------------------------------------
// Pill painting
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.PillPaint(Sender: TObject);
var
  PB: TPaintBox;
  R: TRect;
  Rad, BX, BW: Integer;
begin
  PB  := Sender as TPaintBox;
  R   := Rect(0, 0, PB.Width, PB.Height);
  Rad := (PB.Height) div 2;  // full pill radius

  // Drop shadow (simple offset rectangle, slightly darker)
  PB.Canvas.Brush.Color := RGBToColor(0, 0, 0);
  PB.Canvas.Pen.Color   := RGBToColor(0, 0, 0);
  PB.Canvas.RoundRect(R.Left + 3, R.Top + 4, R.Right + 3, R.Bottom + 4, Rad, Rad);

  // Pill background
  PB.Canvas.Brush.Color := RGBToColor(24, 30, 42);
  PB.Canvas.Pen.Color   := RGBToColor(46, 58, 80);
  PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);

  // Finish button accent background (right portion)
  BX := FFinishBtn.Left;
  BW := FINISH_W;
  PB.Canvas.Brush.Color := RGBToColor(32, 120, 180);   // cyan accent fill
  PB.Canvas.Pen.Color   := RGBToColor(32, 120, 180);
  // Draw right-rounded accent area
  PB.Canvas.RoundRect(BX, R.Top + 1, R.Right - 1, R.Bottom - 1, Rad - 1, Rad - 1);
  // Square off the left side of the accent area by drawing a filled rect
  PB.Canvas.FillRect(Rect(BX, R.Top + 1, BX + Rad, R.Bottom - 1));

  // Separator line between menu and finish
  PB.Canvas.Pen.Color := RGBToColor(46, 58, 80);
  PB.Canvas.MoveTo(BX, R.Top + 6);
  PB.Canvas.LineTo(BX, R.Bottom - 6);
end;

// ---------------------------------------------------------------------------
// Button click handlers
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.PreviewBtnClick(Sender: TObject);
begin
  if Assigned(FOnPreviewClick) then FOnPreviewClick(Self);
end;

procedure TFloatingActionDock.MenuBtnClick(Sender: TObject);
begin
  if Assigned(FOnMenuClick) then FOnMenuClick(Self);
end;

procedure TFloatingActionDock.FinishBtnClick(Sender: TObject);
begin
  if Assigned(FOnFinishClick) then FOnFinishClick(Self);
end;

// ---------------------------------------------------------------------------
// Public methods
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.UpdateForTab(AShowPreview: Boolean);
begin
  FPreviewVisible := AShowPreview;
  LayoutButtons;
  FPillBox.Invalidate;
  FDockPanel.BringToFront;
end;

procedure TFloatingActionDock.BringToFront;
begin
  FDockPanel.BringToFront;
end;

end.
