unit floating_dock;

{$mode objfpc}{$H+}

// ---------------------------------------------------------------------------
//  TFloatingActionDock — a compact pill-style floating action bar that sits
//  above the bottom-right corner of goverlayPanel. It hosts contextual buttons:
//
//    [  ☰  Menu  ]   (optional — shown when active tab has popup menu options, always on the left)
//    [ ▶ Preview ]   (optional — shown on MangoHud, vkBasalt, vkSumi)
//    [   + Add   ]   (optional — shown on EnvVars tab)
//    [  ✓ Finish ]   (primary accent button, always visible on the right)
//
//  Call UpdateForTab(AShowPreview, AShowMenu, AShowAdd, AVisible) on tab switch.
// ---------------------------------------------------------------------------

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, Buttons,
  LCLIntf, LCLType, Math;

type

  { TFloatingActionDock }
  TFloatingActionDock = class(TObject)
  private
    FParent:         TWinControl;   // goverlayPanel
    FDockPanel:      TPanel;        // container

    // Inner pill paint box (draws the pill background)
    FPillBox:        TPaintBox;

    // Buttons (custom state-aware controls, left-to-right layout)
    FMenuBox:        TPaintBox;
    FPreviewBox:     TPaintBox;
    FAddBox:         TPaintBox;
    FFinishBox:      TPaintBox;     // primary accent button

    FMenuHovered:    Boolean;
    FMenuPressed:    Boolean;
    FPreviewHovered: Boolean;
    FPreviewPressed: Boolean;
    FAddHovered:     Boolean;
    FAddPressed:     Boolean;
    FFinishHovered:  Boolean;
    FFinishPressed:  Boolean;

    FPreviewVisible: Boolean;
    FMenuVisible:    Boolean;
    FAddVisible:     Boolean;
    FFinishVisible:  Boolean;
    FAddCaption:     string;

    FOnPreviewClick: TNotifyEvent;
    FOnMenuClick:    TNotifyEvent;
    FOnAddClick:     TNotifyEvent;
    FOnFinishClick:  TNotifyEvent;

    function  GetVisible: Boolean;
    procedure SetVisible(AValue: Boolean);
    function  GetFinishFillColor: TColor;
    function  GetFinishBorderColor: TColor;
    procedure PillPaint(Sender: TObject);

    // Painting handlers
    procedure MenuPaint(Sender: TObject);
    procedure PreviewPaint(Sender: TObject);
    procedure AddPaint(Sender: TObject);
    procedure FinishPaint(Sender: TObject);

    // Mouse event handlers for Menu
    procedure MenuMouseEnter(Sender: TObject);
    procedure MenuMouseLeave(Sender: TObject);
    procedure MenuMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MenuMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MenuClick(Sender: TObject);

    // Mouse event handlers for Preview
    procedure PreviewMouseEnter(Sender: TObject);
    procedure PreviewMouseLeave(Sender: TObject);
    procedure PreviewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PreviewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PreviewClick(Sender: TObject);

    // Mouse event handlers for Add
    procedure AddMouseEnter(Sender: TObject);
    procedure AddMouseLeave(Sender: TObject);
    procedure AddMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AddMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AddClick(Sender: TObject);

    // Mouse event handlers for Finish
    procedure FinishMouseEnter(Sender: TObject);
    procedure FinishMouseLeave(Sender: TObject);
    procedure FinishMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FinishMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FinishClick(Sender: TObject);

    procedure LayoutButtons;

  public
    constructor Create(AParent: TWinControl);
    destructor  Destroy; override;

    // Call when switching tabs:
    // AShowPreview: True for tabs with 3D preview support
    // AShowMenu: True for tabs with popup menu options
    // AShowAdd: True for EnvVars/Games tab
    // AVisible: False to completely hide the dock (e.g. on Home tab)
    // AShowFinish: True to display the primary Finish button (False on Games tab)
    // AAddCaption: Button text for the Add button (e.g. '+ Add' or '+ Add Folder')
    procedure UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean; AVisible: Boolean = True;
      AShowFinish: Boolean = True; const AAddCaption: string = '+ Add');

    procedure Show;
    procedure Hide;
    procedure BringToFront;

    // Testing and interaction helpers
    procedure SimulateMenuHover(AHover: Boolean);
    procedure SimulateMenuPress(APressed: Boolean);
    procedure SimulatePreviewHover(AHover: Boolean);
    procedure SimulatePreviewPress(APressed: Boolean);
    procedure SimulateAddHover(AHover: Boolean);
    procedure SimulateAddPress(APressed: Boolean);
    procedure SimulateFinishHover(AHover: Boolean);
    procedure SimulateFinishPress(APressed: Boolean);
    procedure PerformMenuClick;
    procedure PerformPreviewClick;
    procedure PerformAddClick;
    procedure PerformFinishClick;

    property Visible:        Boolean      read GetVisible write SetVisible;
    property MenuHovered:    Boolean      read FMenuHovered;
    property MenuPressed:    Boolean      read FMenuPressed;
    property PreviewHovered: Boolean      read FPreviewHovered;
    property PreviewPressed: Boolean      read FPreviewPressed;
    property AddHovered:     Boolean      read FAddHovered;
    property AddPressed:     Boolean      read FAddPressed;
    property FinishHovered:  Boolean      read FFinishHovered;
    property FinishPressed:  Boolean      read FFinishPressed;
    property OnPreviewClick: TNotifyEvent read FOnPreviewClick write FOnPreviewClick;
    property OnMenuClick:    TNotifyEvent read FOnMenuClick    write FOnMenuClick;
    property OnAddClick:     TNotifyEvent read FOnAddClick     write FOnAddClick;
    property OnFinishClick:  TNotifyEvent read FOnFinishClick  write FOnFinishClick;
  end;

implementation

// ---------------------------------------------------------------------------
// Compact geometry constants
// ---------------------------------------------------------------------------
const
  DOCK_RIGHT    = 16;   // distance from right edge of parent (compact)
  DOCK_BOTTOM   = 14;   // distance from bottom edge of parent (compact)
  BTN_H         = 30;   // button height (compact)
  BTN_GAP       = 3;    // gap between buttons
  PREVIEW_W     = 88;   // width of preview button
  MENU_W        = 34;   // width of menu button
  ADD_W         = 76;   // width of add button
  FINISH_W      = 84;   // width of finish button
  INNER_PAD_X   = 6;    // horizontal padding inside pill
  INNER_PAD_Y   = 4;    // vertical padding inside pill (Total height = 38px)

// ---------------------------------------------------------------------------
// Helper: Draw secondary button chip with custom state-aware styling
// ---------------------------------------------------------------------------
procedure DrawSecondaryButton(PB: TPaintBox; AHovered, APressed: Boolean;
  const ACaption: string; AFontSize: Integer; AFontStyle: TFontStyles);
var
  R: TRect;
  TextW, TextH, TextX, TextY: Integer;
begin
  R := Rect(0, 0, PB.Width, PB.Height);

  if APressed then
  begin
    PB.Canvas.Brush.Color := RGBToColor(30, 38, 52);    // #1E2634
    PB.Canvas.Pen.Color   := RGBToColor(46, 61, 85);    // #2E3D55
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 6, 6);
    PB.Canvas.Font.Color  := RGBToColor(220, 230, 240);
  end
  else if AHovered then
  begin
    PB.Canvas.Brush.Color := RGBToColor(42, 53, 72);    // #2A3548 (sleek elevated slate)
    PB.Canvas.Pen.Color   := RGBToColor(61, 79, 110);   // #3D4F6E (subtle clean outline)
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 6, 6);
    PB.Canvas.Font.Color  := clWhite;
  end
  else
  begin
    PB.Canvas.Brush.Style := bsClear;
    PB.Canvas.Font.Color  := RGBToColor(180, 190, 205); // #B4BECB
  end;

  PB.Canvas.Font.Name   := 'Noto Sans';
  PB.Canvas.Font.Size   := AFontSize;
  PB.Canvas.Font.Style  := AFontStyle;
  PB.Canvas.Brush.Style := bsClear;

  TextW := PB.Canvas.TextWidth(ACaption);
  TextH := PB.Canvas.TextHeight(ACaption);
  TextX := (PB.Width - TextW) div 2;
  TextY := (PB.Height - TextH) div 2;
  PB.Canvas.TextOut(TextX, TextY, ACaption);
end;

// ---------------------------------------------------------------------------
// Constructor / Destructor
// ---------------------------------------------------------------------------

constructor TFloatingActionDock.Create(AParent: TWinControl);
var
  TotalPillW, TotalPillH: Integer;
begin
  inherited Create;
  FParent         := AParent;
  FPreviewVisible := True;
  FMenuVisible    := True;
  FAddVisible     := False;
  FFinishVisible  := True;
  FAddCaption     := '+ Add';

  FMenuHovered    := False;
  FMenuPressed    := False;
  FPreviewHovered := False;
  FPreviewPressed := False;
  FAddHovered     := False;
  FAddPressed     := False;
  FFinishHovered  := False;
  FFinishPressed  := False;

  TotalPillW := INNER_PAD_X * 2
              + PREVIEW_W + BTN_GAP
              + MENU_W    + BTN_GAP
              + FINISH_W;
  TotalPillH := BTN_H + INNER_PAD_Y * 2;

  // Anchor panel matching container background seamlessly
  FDockPanel                  := TPanel.Create(AParent);
  FDockPanel.Parent           := AParent;
  FDockPanel.BevelOuter       := bvNone;
  FDockPanel.BevelInner       := bvNone;
  FDockPanel.Color            := RGBToColor(22, 26, 40);
  FDockPanel.ParentBackground := False;
  FDockPanel.Width            := TotalPillW;
  FDockPanel.Height           := TotalPillH;
  FDockPanel.Anchors          := [akRight, akBottom];
  FDockPanel.Left             := AParent.ClientWidth - TotalPillW - DOCK_RIGHT;
  FDockPanel.Top              := AParent.ClientHeight - TotalPillH - DOCK_BOTTOM;

  // Pill background paint box
  FPillBox             := TPaintBox.Create(FDockPanel);
  FPillBox.Parent      := FDockPanel;
  FPillBox.Left        := 0;
  FPillBox.Top         := 0;
  FPillBox.Width       := FDockPanel.Width;
  FPillBox.Height      := FDockPanel.Height;
  FPillBox.Anchors     := [akLeft, akRight, akTop, akBottom];
  FPillBox.OnPaint     := @PillPaint;

  // ---- Menu button (custom state-aware painting) ----
  FMenuBox              := TPaintBox.Create(FDockPanel);
  FMenuBox.Parent       := FDockPanel;
  FMenuBox.Cursor       := crHandPoint;
  FMenuBox.OnPaint      := @MenuPaint;
  FMenuBox.OnMouseEnter := @MenuMouseEnter;
  FMenuBox.OnMouseLeave := @MenuMouseLeave;
  FMenuBox.OnMouseDown  := @MenuMouseDown;
  FMenuBox.OnMouseUp    := @MenuMouseUp;
  FMenuBox.OnClick      := @MenuClick;
  FMenuBox.ShowHint     := True;
  FMenuBox.Hint         := 'Options & presets menu';

  // ---- Preview button (custom state-aware painting) ----
  FPreviewBox              := TPaintBox.Create(FDockPanel);
  FPreviewBox.Parent       := FDockPanel;
  FPreviewBox.Cursor       := crHandPoint;
  FPreviewBox.OnPaint      := @PreviewPaint;
  FPreviewBox.OnMouseEnter := @PreviewMouseEnter;
  FPreviewBox.OnMouseLeave := @PreviewMouseLeave;
  FPreviewBox.OnMouseDown  := @PreviewMouseDown;
  FPreviewBox.OnMouseUp    := @PreviewMouseUp;
  FPreviewBox.OnClick      := @PreviewClick;
  FPreviewBox.ShowHint     := True;
  FPreviewBox.Hint         := 'Launch a quick 3D preview (pascube / vkcube)';

  // ---- Add button (EnvVars / Games, custom state-aware painting) ----
  FAddBox              := TPaintBox.Create(FDockPanel);
  FAddBox.Parent       := FDockPanel;
  FAddBox.Cursor       := crHandPoint;
  FAddBox.OnPaint      := @AddPaint;
  FAddBox.OnMouseEnter := @AddMouseEnter;
  FAddBox.OnMouseLeave := @AddMouseLeave;
  FAddBox.OnMouseDown  := @AddMouseDown;
  FAddBox.OnMouseUp    := @AddMouseUp;
  FAddBox.OnClick      := @AddClick;
  FAddBox.ShowHint     := True;
  FAddBox.Hint         := 'Add action';

  // ---- Finish button (custom state-aware painting) ----
  FFinishBox              := TPaintBox.Create(FDockPanel);
  FFinishBox.Parent       := FDockPanel;
  FFinishBox.Cursor       := crHandPoint;
  FFinishBox.OnPaint      := @FinishPaint;
  FFinishBox.OnMouseEnter := @FinishMouseEnter;
  FFinishBox.OnMouseLeave := @FinishMouseLeave;
  FFinishBox.OnMouseDown  := @FinishMouseDown;
  FFinishBox.OnMouseUp    := @FinishMouseUp;
  FFinishBox.OnClick      := @FinishClick;
  FFinishBox.ShowHint     := True;
  FFinishBox.Hint         := 'Get your Steam / Heroic launch command';

  LayoutButtons;
end;

destructor TFloatingActionDock.Destroy;
begin
  FDockPanel.Visible := False;
  inherited;
end;

function TFloatingActionDock.GetVisible: Boolean;
begin
  if Assigned(FDockPanel) then
    Result := FDockPanel.Visible
  else
    Result := False;
end;

procedure TFloatingActionDock.SetVisible(AValue: Boolean);
begin
  if Assigned(FDockPanel) then
  begin
    FDockPanel.Visible := AValue;
    if AValue then
      FDockPanel.BringToFront;
  end;
end;

procedure TFloatingActionDock.Show;
begin
  SetVisible(True);
end;

procedure TFloatingActionDock.Hide;
begin
  SetVisible(False);
end;

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.LayoutButtons;
var
  X, TotalPillW, AddW, VisibleBtnCount: Integer;
begin
  if Length(FAddCaption) > 6 then
    AddW := 104
  else
    AddW := ADD_W;

  TotalPillW := INNER_PAD_X * 2;
  VisibleBtnCount := 0;

  if FMenuVisible then
  begin
    Inc(TotalPillW, MENU_W);
    Inc(VisibleBtnCount);
  end;
  if FPreviewVisible then
  begin
    Inc(TotalPillW, PREVIEW_W);
    Inc(VisibleBtnCount);
  end;
  if FAddVisible then
  begin
    Inc(TotalPillW, AddW);
    Inc(VisibleBtnCount);
  end;
  if FFinishVisible then
  begin
    Inc(TotalPillW, FINISH_W);
    Inc(VisibleBtnCount);
  end;

  if VisibleBtnCount > 1 then
    Inc(TotalPillW, (VisibleBtnCount - 1) * BTN_GAP);

  if TotalPillW < INNER_PAD_X * 2 + 50 then
    TotalPillW := INNER_PAD_X * 2 + 50;

  // Resize the dock panel and reposition to right edge
  FDockPanel.Width  := TotalPillW;
  FDockPanel.Height := BTN_H + INNER_PAD_Y * 2;
  FDockPanel.Left   := FParent.ClientWidth - TotalPillW - DOCK_RIGHT;
  FDockPanel.Top    := FParent.ClientHeight - FDockPanel.Height - DOCK_BOTTOM;

  // Resize pill box
  FPillBox.Width  := TotalPillW;
  FPillBox.Height := FDockPanel.Height;

  // Place buttons left-to-right inside pill: [Menu] -> [Preview] -> [Add] -> [Finish]
  X := INNER_PAD_X;

  if FMenuVisible then
  begin
    FMenuBox.SetBounds(X, INNER_PAD_Y, MENU_W, BTN_H);
    FMenuBox.Visible := True;
    Inc(X, MENU_W + BTN_GAP);
  end
  else
    FMenuBox.Visible := False;

  if FPreviewVisible then
  begin
    FPreviewBox.SetBounds(X, INNER_PAD_Y, PREVIEW_W, BTN_H);
    FPreviewBox.Visible := True;
    Inc(X, PREVIEW_W + BTN_GAP);
  end
  else
    FPreviewBox.Visible := False;

  if FAddVisible then
  begin
    FAddBox.SetBounds(X, INNER_PAD_Y, AddW, BTN_H);
    FAddBox.Visible := True;
    Inc(X, AddW + BTN_GAP);
  end
  else
    FAddBox.Visible := False;

  if FFinishVisible then
  begin
    FFinishBox.SetBounds(X, INNER_PAD_Y, FINISH_W, BTN_H);
    FFinishBox.Visible := True;
  end
  else
    FFinishBox.Visible := False;
end;

// ---------------------------------------------------------------------------
// Pill & Button painting
// ---------------------------------------------------------------------------

function TFloatingActionDock.GetFinishFillColor: TColor;
begin
  if FFinishPressed then
    Result := RGBToColor(24, 95, 155)    // #185F9B (active pressed state)
  else if FFinishHovered then
    Result := RGBToColor(43, 148, 220)   // #2B94DC (vibrant illuminated hover)
  else
    Result := RGBToColor(32, 120, 180);  // #2078B4 (standard primary blue)
end;

function TFloatingActionDock.GetFinishBorderColor: TColor;
begin
  if FFinishPressed then
    Result := RGBToColor(32, 120, 180)
  else if FFinishHovered then
    Result := RGBToColor(85, 215, 255)   // #55D7FF (luminous cyan glow border)
  else
    Result := RGBToColor(48, 190, 240);
end;

procedure TFloatingActionDock.PillPaint(Sender: TObject);
var
  PB: TPaintBox;
  R: TRect;
  Rad, BX: Integer;
  IsSoloFinish: Boolean;
  FinishFill: TColor;
begin
  PB  := Sender as TPaintBox;
  R   := Rect(0, 0, PB.Width, PB.Height);
  Rad := PB.Height div 2;

  // 1. Clear full rect with container background to eliminate white edges
  PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.Pen.Color   := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(R);

  // 2. Drop shadow
  PB.Canvas.Brush.Color := RGBToColor(0, 0, 0);
  PB.Canvas.Pen.Color   := RGBToColor(0, 0, 0);
  PB.Canvas.RoundRect(R.Left + 2, R.Top + 2, R.Right + 2, R.Bottom + 2, Rad, Rad);

  IsSoloFinish := FFinishVisible and not FPreviewVisible and not FMenuVisible and not FAddVisible;
  FinishFill   := GetFinishFillColor;

  if IsSoloFinish then
  begin
    // Standalone Finish pill: entire pill has the state-aware cyan accent fill
    PB.Canvas.Brush.Color := FinishFill;
    PB.Canvas.Pen.Color   := GetFinishBorderColor;
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);
  end
  else
  begin
    // Multi-button pill: dark background
    PB.Canvas.Brush.Color := RGBToColor(24, 30, 42);
    PB.Canvas.Pen.Color   := RGBToColor(46, 58, 80);
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);

    if FFinishVisible then
    begin
      // Finish button accent background (right portion)
      BX := FFinishBox.Left;
      PB.Canvas.Brush.Color := FinishFill;
      PB.Canvas.Pen.Color   := FinishFill;
      // Draw right-rounded accent area
      PB.Canvas.RoundRect(BX, R.Top + 1, R.Right - 1, R.Bottom - 1, Rad - 1, Rad - 1);
      // Square off the left side of the accent area
      PB.Canvas.FillRect(Rect(BX, R.Top + 1, BX + Rad, R.Bottom - 1));

      // Separator line before finish button
      PB.Canvas.Pen.Color := RGBToColor(46, 58, 80);
      PB.Canvas.MoveTo(BX, R.Top + 4);
      PB.Canvas.LineTo(BX, R.Bottom - 4);
    end;
  end;
end;

procedure TFloatingActionDock.MenuPaint(Sender: TObject);
begin
  DrawSecondaryButton(FMenuBox, FMenuHovered, FMenuPressed, ' ☰', 11, []);
end;

procedure TFloatingActionDock.PreviewPaint(Sender: TObject);
begin
  DrawSecondaryButton(FPreviewBox, FPreviewHovered, FPreviewPressed, ' ▶ Preview', 8, [fsBold]);
end;

procedure TFloatingActionDock.AddPaint(Sender: TObject);
begin
  DrawSecondaryButton(FAddBox, FAddHovered, FAddPressed, ' ' + FAddCaption, 8, [fsBold]);
end;

procedure TFloatingActionDock.FinishPaint(Sender: TObject);
var
  PB: TPaintBox;
  TextW, TextH, TextX, TextY: Integer;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Font.Name  := 'Noto Sans';
  PB.Canvas.Font.Size  := 8;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := clWhite;
  PB.Canvas.Brush.Style := bsClear;

  TextW := PB.Canvas.TextWidth('✓ Finish');
  TextH := PB.Canvas.TextHeight('✓ Finish');
  TextX := (PB.Width - TextW) div 2;
  TextY := (PB.Height - TextH) div 2;
  PB.Canvas.TextOut(TextX, TextY, '✓ Finish');
end;

// ---------------------------------------------------------------------------
// Mouse events: Menu
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.MenuMouseEnter(Sender: TObject);
begin
  FMenuHovered := True;
  FPillBox.Invalidate;
  FMenuBox.Invalidate;
end;

procedure TFloatingActionDock.MenuMouseLeave(Sender: TObject);
begin
  FMenuHovered := False;
  FMenuPressed := False;
  FPillBox.Invalidate;
  FMenuBox.Invalidate;
end;

procedure TFloatingActionDock.MenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMenuPressed := True;
    FMenuBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.MenuMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMenuPressed := False;
    FMenuBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.MenuClick(Sender: TObject);
begin
  if Assigned(FOnMenuClick) then FOnMenuClick(Self);
end;

// ---------------------------------------------------------------------------
// Mouse events: Preview
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.PreviewMouseEnter(Sender: TObject);
begin
  FPreviewHovered := True;
  FPillBox.Invalidate;
  FPreviewBox.Invalidate;
end;

procedure TFloatingActionDock.PreviewMouseLeave(Sender: TObject);
begin
  FPreviewHovered := False;
  FPreviewPressed := False;
  FPillBox.Invalidate;
  FPreviewBox.Invalidate;
end;

procedure TFloatingActionDock.PreviewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPreviewPressed := True;
    FPreviewBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PreviewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPreviewPressed := False;
    FPreviewBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PreviewClick(Sender: TObject);
begin
  if Assigned(FOnPreviewClick) then FOnPreviewClick(Self);
end;

// ---------------------------------------------------------------------------
// Mouse events: Add
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.AddMouseEnter(Sender: TObject);
begin
  FAddHovered := True;
  FPillBox.Invalidate;
  FAddBox.Invalidate;
end;

procedure TFloatingActionDock.AddMouseLeave(Sender: TObject);
begin
  FAddHovered := False;
  FAddPressed := False;
  FPillBox.Invalidate;
  FAddBox.Invalidate;
end;

procedure TFloatingActionDock.AddMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FAddPressed := True;
    FAddBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.AddMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FAddPressed := False;
    FAddBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.AddClick(Sender: TObject);
begin
  if Assigned(FOnAddClick) then FOnAddClick(Self);
end;

// ---------------------------------------------------------------------------
// Mouse events: Finish
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.FinishMouseEnter(Sender: TObject);
begin
  FFinishHovered := True;
  FPillBox.Invalidate;
  FFinishBox.Invalidate;
end;

procedure TFloatingActionDock.FinishMouseLeave(Sender: TObject);
begin
  FFinishHovered := False;
  FFinishPressed := False;
  FPillBox.Invalidate;
  FFinishBox.Invalidate;
end;

procedure TFloatingActionDock.FinishMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FFinishPressed := True;
    FPillBox.Invalidate;
    FFinishBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.FinishMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FFinishPressed := False;
    FPillBox.Invalidate;
    FFinishBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.FinishClick(Sender: TObject);
begin
  if Assigned(FOnFinishClick) then FOnFinishClick(Self);
end;

// ---------------------------------------------------------------------------
// Testing and interaction helpers
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.SimulateMenuHover(AHover: Boolean);
begin
  if AHover then
    MenuMouseEnter(FMenuBox)
  else
    MenuMouseLeave(FMenuBox);
end;

procedure TFloatingActionDock.SimulateMenuPress(APressed: Boolean);
begin
  if APressed then
    MenuMouseDown(FMenuBox, mbLeft, [], 0, 0)
  else
    MenuMouseUp(FMenuBox, mbLeft, [], 0, 0);
end;

procedure TFloatingActionDock.SimulatePreviewHover(AHover: Boolean);
begin
  if AHover then
    PreviewMouseEnter(FPreviewBox)
  else
    PreviewMouseLeave(FPreviewBox);
end;

procedure TFloatingActionDock.SimulatePreviewPress(APressed: Boolean);
begin
  if APressed then
    PreviewMouseDown(FPreviewBox, mbLeft, [], 0, 0)
  else
    PreviewMouseUp(FPreviewBox, mbLeft, [], 0, 0);
end;

procedure TFloatingActionDock.SimulateAddHover(AHover: Boolean);
begin
  if AHover then
    AddMouseEnter(FAddBox)
  else
    AddMouseLeave(FAddBox);
end;

procedure TFloatingActionDock.SimulateAddPress(APressed: Boolean);
begin
  if APressed then
    AddMouseDown(FAddBox, mbLeft, [], 0, 0)
  else
    AddMouseUp(FAddBox, mbLeft, [], 0, 0);
end;

procedure TFloatingActionDock.SimulateFinishHover(AHover: Boolean);
begin
  if AHover then
    FinishMouseEnter(FFinishBox)
  else
    FinishMouseLeave(FFinishBox);
end;

procedure TFloatingActionDock.SimulateFinishPress(APressed: Boolean);
begin
  if APressed then
    FinishMouseDown(FFinishBox, mbLeft, [], 0, 0)
  else
    FinishMouseUp(FFinishBox, mbLeft, [], 0, 0);
end;

procedure TFloatingActionDock.PerformMenuClick;
begin
  MenuClick(FMenuBox);
end;

procedure TFloatingActionDock.PerformPreviewClick;
begin
  PreviewClick(FPreviewBox);
end;

procedure TFloatingActionDock.PerformAddClick;
begin
  AddClick(FAddBox);
end;

procedure TFloatingActionDock.PerformFinishClick;
begin
  FinishClick(FFinishBox);
end;

// ---------------------------------------------------------------------------
// Public methods
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean; AVisible: Boolean = True;
  AShowFinish: Boolean = True; const AAddCaption: string = '+ Add');
begin
  SetVisible(AVisible);
  if not AVisible then Exit;

  FPreviewVisible := AShowPreview;
  FMenuVisible    := AShowMenu;
  FAddVisible     := AShowAdd;
  FFinishVisible  := AShowFinish;
  FAddCaption     := AAddCaption;
  LayoutButtons;
  FPillBox.Invalidate;
  FDockPanel.BringToFront;
end;

procedure TFloatingActionDock.BringToFront;
begin
  if FDockPanel.Visible then
    FDockPanel.BringToFront;
end;

end.
