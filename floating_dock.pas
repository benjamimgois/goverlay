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
  LCLIntf, LCLType;

type
  TDockButton = (btnNone, btnMenu, btnPreview, btnAdd, btnFinish);

  { TFloatingActionDock }
  TFloatingActionDock = class(TObject)
  private
    FParent:         TWinControl;   // goverlayPanel
    FDockPanel:      TPanel;        // container
    FPillBox:        TPaintBox;     // unified pill drawing surface

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

    // Computed button hit-test rects
    FMenuRect:       TRect;
    FPreviewRect:    TRect;
    FAddRect:        TRect;
    FFinishRect:     TRect;

    FOnPreviewClick: TNotifyEvent;
    FOnMenuClick:    TNotifyEvent;
    FOnAddClick:     TNotifyEvent;
    FOnFinishClick:  TNotifyEvent;

    function  GetVisible: Boolean;
    procedure SetVisible(AValue: Boolean);
    function  GetFinishFillColor: TColor;
    function  GetFinishBorderColor: TColor;
    function  GetButtonAt(AX, AY: Integer): TDockButton;

    procedure PillPaint(Sender: TObject);
    procedure PillMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PillMouseEnter(Sender: TObject);
    procedure PillMouseLeave(Sender: TObject);
    procedure PillMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PillMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PillClick(Sender: TObject);

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
    property PreviewVisible: Boolean      read FPreviewVisible;
    property MenuVisible:    Boolean      read FMenuVisible;
    property AddVisible:     Boolean      read FAddVisible;
    property FinishVisible:  Boolean      read FFinishVisible;
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

uses
  {$IFDEF LCLqt6}
  qt6,
  qtobjects,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets;

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
// Constructor / Destructor
// ---------------------------------------------------------------------------

constructor TFloatingActionDock.Create(AParent: TWinControl);
var
  SS: WideString;
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

  // Container panel matching parent interface background (#161A28)
  FDockPanel                  := TPanel.Create(AParent);
  FDockPanel.Parent           := AParent;
  FDockPanel.BevelOuter       := bvNone;
  FDockPanel.BevelInner       := bvNone;
  FDockPanel.BorderStyle      := bsNone;
  FDockPanel.Color            := RGBToColor(22, 26, 40);
  FDockPanel.ParentBackground := False;
  FDockPanel.Anchors          := [akRight, akBottom];

  {$IFDEF LCLqt6}
  if not FDockPanel.HandleAllocated then
    FDockPanel.HandleNeeded;
  if FDockPanel.HandleAllocated then
  begin
    QWidget_setAttribute(TQtWidget(FDockPanel.Handle).Widget, QtWA_TranslucentBackground, True);
    QFrame_setFrameStyle(QFrameH(TQtWidget(FDockPanel.Handle).Widget), 0);
    SS := 'QFrame, QWidget { border: none; background: transparent; }';
    QWidget_setStyleSheet(TQtWidget(FDockPanel.Handle).Widget, @SS);
  end;
  {$ENDIF}

  // Single unified pill paint box
  FPillBox              := TPaintBox.Create(FDockPanel);
  FPillBox.Parent       := FDockPanel;
  FPillBox.Align        := alClient;
  FPillBox.OnPaint      := @PillPaint;
  FPillBox.OnMouseMove  := @PillMouseMove;
  FPillBox.OnMouseEnter := @PillMouseEnter;
  FPillBox.OnMouseLeave := @PillMouseLeave;
  FPillBox.OnMouseDown  := @PillMouseDown;
  FPillBox.OnMouseUp    := @PillMouseUp;
  FPillBox.OnClick      := @PillClick;

  LayoutButtons;
end;

destructor TFloatingActionDock.Destroy;
begin
  if Assigned(FDockPanel) then
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
// Layout & Hit-testing
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

  // Resize the dock panel and reposition to bottom right
  FDockPanel.Width  := TotalPillW;
  FDockPanel.Height := BTN_H + INNER_PAD_Y * 2;
  FDockPanel.Left   := FParent.ClientWidth - TotalPillW - DOCK_RIGHT;
  FDockPanel.Top    := FParent.ClientHeight - FDockPanel.Height - DOCK_BOTTOM;

  FPillBox.SetBounds(0, 0, FDockPanel.Width, FDockPanel.Height);

  // Compute button hit-test rects
  X := INNER_PAD_X;

  if FMenuVisible then
  begin
    FMenuRect := Rect(X, INNER_PAD_Y, X + MENU_W, INNER_PAD_Y + BTN_H);
    Inc(X, MENU_W + BTN_GAP);
  end
  else
    FMenuRect := Rect(0, 0, 0, 0);

  if FPreviewVisible then
  begin
    FPreviewRect := Rect(X, INNER_PAD_Y, X + PREVIEW_W, INNER_PAD_Y + BTN_H);
    Inc(X, PREVIEW_W + BTN_GAP);
  end
  else
    FPreviewRect := Rect(0, 0, 0, 0);

  if FAddVisible then
  begin
    FAddRect := Rect(X, INNER_PAD_Y, X + AddW, INNER_PAD_Y + BTN_H);
    Inc(X, AddW + BTN_GAP);
  end
  else
    FAddRect := Rect(0, 0, 0, 0);

  if FFinishVisible then
  begin
    FFinishRect := Rect(X, 0, TotalPillW, FDockPanel.Height);
  end
  else
    FFinishRect := Rect(0, 0, 0, 0);
end;

function TFloatingActionDock.GetButtonAt(AX, AY: Integer): TDockButton;
var
  Pt: TPoint;
begin
  Pt := Point(AX, AY);
  if FMenuVisible and PtInRect(FMenuRect, Pt) then
    Result := btnMenu
  else if FPreviewVisible and PtInRect(FPreviewRect, Pt) then
    Result := btnPreview
  else if FAddVisible and PtInRect(FAddRect, Pt) then
    Result := btnAdd
  else if FFinishVisible and PtInRect(FFinishRect, Pt) then
    Result := btnFinish
  else
    Result := btnNone;
end;

// ---------------------------------------------------------------------------
// Pill & Button painting (Unified single-surface rendering)
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
  R, SubR: TRect;
  CornerDiam, BX: Integer;
  IsSoloFinish: Boolean;
  FinishFill, FGColor: TColor;
  TextW, TextH, TextX, TextY: Integer;
  IconW, IconH, IconX, IconY, CX, CY, ContentX, Gap, TotalW: Integer;
  PtsTop: array[0..4] of TPoint;
  PtsBot: array[0..4] of TPoint;
begin
  PB   := Sender as TPaintBox;
  R    := Rect(0, 0, PB.Width, PB.Height);
  CornerDiam := 12; // Slightly rounded corners (radius = 6px)

  // 1. Fill entire bounding box with interface background color (#161A28)
  PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Pen.Color   := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(R);

  {$IFDEF LCLqt6}
  if PB.Canvas.Handle <> 0 then
    TQtDeviceContext(PB.Canvas.Handle).setRenderHint(QPainterAntialiasing, True);
  {$ENDIF}

  IsSoloFinish := FFinishVisible and not FPreviewVisible and not FMenuVisible and not FAddVisible;
  FinishFill   := GetFinishFillColor;

  if IsSoloFinish then
  begin
    // Standalone Finish pill: entire pill has the state-aware accent fill
    PB.Canvas.Brush.Color := FinishFill;
    PB.Canvas.Brush.Style := bsSolid;
    PB.Canvas.Pen.Color   := GetFinishBorderColor;
    PB.Canvas.Pen.Width   := 1;
    PB.Canvas.RoundRect(0, 0, PB.Width, PB.Height, CornerDiam, CornerDiam);

    // Draw ✓ Finish centered
    PB.Canvas.Font.Name   := 'Noto Sans';
    PB.Canvas.Font.Size   := 8;
    PB.Canvas.Font.Style  := [fsBold];
    PB.Canvas.Font.Color  := clWhite;
    PB.Canvas.Brush.Style := bsClear;

    TextW := PB.Canvas.TextWidth('✓ Finish');
    TextH := PB.Canvas.TextHeight('✓ Finish');
    TextX := (PB.Width - TextW) div 2;
    TextY := (PB.Height - TextH) div 2;
    PB.Canvas.TextOut(TextX, TextY, '✓ Finish');
  end
  else
  begin
    // Multi-button dock: dark slate-navy background (#181E2A) with subtle border (#2E3A50)
    PB.Canvas.Brush.Color := RGBToColor(24, 30, 42);
    PB.Canvas.Brush.Style := bsSolid;
    PB.Canvas.Pen.Color   := RGBToColor(46, 58, 80);
    PB.Canvas.Pen.Width   := 1;
    PB.Canvas.RoundRect(0, 0, PB.Width, PB.Height, CornerDiam, CornerDiam);

    // 1. Finish button accent background (right portion)
    if FFinishVisible then
    begin
      BX := FFinishRect.Left;
      PB.Canvas.Brush.Color := FinishFill;
      PB.Canvas.Brush.Style := bsSolid;
      PB.Canvas.Pen.Color   := FinishFill;
      // Draw right-rounded accent area with matching slightly rounded right end
      PB.Canvas.RoundRect(BX, 0, PB.Width, PB.Height, CornerDiam, CornerDiam);
      // Square off the left side of the accent area so it meets the vertical separator cleanly
      PB.Canvas.FillRect(Rect(BX, 0, BX + CornerDiam div 2, PB.Height));

      // Separator line before finish button
      PB.Canvas.Pen.Color := RGBToColor(46, 58, 80);
      PB.Canvas.MoveTo(BX, 0);
      PB.Canvas.LineTo(BX, PB.Height);

      // Finish button text
      PB.Canvas.Font.Name   := 'Noto Sans';
      PB.Canvas.Font.Size   := 8;
      PB.Canvas.Font.Style  := [fsBold];
      PB.Canvas.Font.Color  := clWhite;
      PB.Canvas.Brush.Style := bsClear;

      TextW := PB.Canvas.TextWidth('✓ Finish');
      TextH := PB.Canvas.TextHeight('✓ Finish');
      TextX := BX + (FFinishRect.Right - BX - TextW) div 2;
      TextY := (PB.Height - TextH) div 2;
      PB.Canvas.TextOut(TextX, TextY, '✓ Finish');
    end;

    // 2. Menu button (☰)
    if FMenuVisible then
    begin
      SubR := FMenuRect;
      if FMenuPressed then
      begin
        PB.Canvas.Brush.Color := RGBToColor(30, 38, 52);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(46, 61, 85);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := RGBToColor(220, 230, 240);
      end
      else if FMenuHovered then
      begin
        PB.Canvas.Brush.Color := RGBToColor(42, 53, 72);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(61, 79, 110);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := clWhite;
      end
      else
        FGColor := RGBToColor(180, 190, 205);

      PB.Canvas.Font.Name   := 'Noto Sans';
      PB.Canvas.Font.Size   := 11;
      PB.Canvas.Font.Style  := [];
      PB.Canvas.Font.Color  := FGColor;
      PB.Canvas.Brush.Style := bsClear;

      TextW := PB.Canvas.TextWidth('☰');
      TextH := PB.Canvas.TextHeight('☰');
      TextX := SubR.Left + (SubR.Right - SubR.Left - TextW) div 2;
      TextY := SubR.Top + (SubR.Bottom - SubR.Top - TextH) div 2;
      PB.Canvas.TextOut(TextX, TextY, '☰');
    end;

    // 3. Preview button (eye icon + "Preview")
    if FPreviewVisible then
    begin
      SubR := FPreviewRect;
      if FPreviewPressed then
      begin
        PB.Canvas.Brush.Color := RGBToColor(30, 38, 52);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(46, 61, 85);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := RGBToColor(220, 230, 240);
      end
      else if FPreviewHovered then
      begin
        PB.Canvas.Brush.Color := RGBToColor(42, 53, 72);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(61, 79, 110);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := clWhite;
      end
      else
        FGColor := RGBToColor(180, 190, 205);

      PB.Canvas.Font.Name   := 'Noto Sans';
      PB.Canvas.Font.Size   := 8;
      PB.Canvas.Font.Style  := [fsBold];
      PB.Canvas.Font.Color  := FGColor;
      PB.Canvas.Brush.Style := bsClear;

      TextW := PB.Canvas.TextWidth('Preview');
      TextH := PB.Canvas.TextHeight('Preview');

      IconW := 14;
      IconH := 8;
      Gap   := 6;
      TotalW := IconW + Gap + TextW;
      ContentX := SubR.Left + (SubR.Right - SubR.Left - TotalW) div 2;

      IconX := ContentX;
      IconY := SubR.Top + (SubR.Bottom - SubR.Top - IconH) div 2;
      CX    := IconX + IconW div 2;
      CY    := IconY + IconH div 2;

      // Draw eye outline
      PB.Canvas.Pen.Color := FGColor;
      PB.Canvas.Pen.Width := 1;

      PtsTop[0] := Point(IconX, CY);
      PtsTop[1] := Point(IconX + 3, IconY + 1);
      PtsTop[2] := Point(CX, IconY);
      PtsTop[3] := Point(IconX + IconW - 3, IconY + 1);
      PtsTop[4] := Point(IconX + IconW, CY);

      PtsBot[0] := Point(IconX, CY);
      PtsBot[1] := Point(IconX + 3, IconY + IconH - 1);
      PtsBot[2] := Point(CX, IconY + IconH);
      PtsBot[3] := Point(IconX + IconW - 3, IconY + IconH - 1);
      PtsBot[4] := Point(IconX + IconW, CY);

      PB.Canvas.Polyline(PtsTop);
      PB.Canvas.Polyline(PtsBot);

      // Pupil center
      PB.Canvas.Brush.Color := FGColor;
      PB.Canvas.Brush.Style := bsSolid;
      PB.Canvas.Ellipse(CX - 1, CY - 1, CX + 2, CY + 2);

      // Draw text
      PB.Canvas.Brush.Style := bsClear;
      TextX := ContentX + IconW + Gap;
      TextY := SubR.Top + (SubR.Bottom - SubR.Top - TextH) div 2;
      PB.Canvas.TextOut(TextX, TextY, 'Preview');
    end;

    // 4. Add button (e.g. "+ Add")
    if FAddVisible then
    begin
      SubR := FAddRect;
      if FAddPressed then
      begin
        PB.Canvas.Brush.Color := RGBToColor(30, 38, 52);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(46, 61, 85);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := RGBToColor(220, 230, 240);
      end
      else if FAddHovered then
      begin
        PB.Canvas.Brush.Color := RGBToColor(42, 53, 72);
        PB.Canvas.Brush.Style := bsSolid;
        PB.Canvas.Pen.Color   := RGBToColor(61, 79, 110);
        PB.Canvas.RoundRect(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom, 6, 6);
        FGColor := clWhite;
      end
      else
        FGColor := RGBToColor(180, 190, 205);

      PB.Canvas.Font.Name   := 'Noto Sans';
      PB.Canvas.Font.Size   := 8;
      PB.Canvas.Font.Style  := [fsBold];
      PB.Canvas.Font.Color  := FGColor;
      PB.Canvas.Brush.Style := bsClear;

      TextW := PB.Canvas.TextWidth(FAddCaption);
      TextH := PB.Canvas.TextHeight(FAddCaption);
      TextX := SubR.Left + (SubR.Right - SubR.Left - TextW) div 2;
      TextY := SubR.Top + (SubR.Bottom - SubR.Top - TextH) div 2;
      PB.Canvas.TextOut(TextX, TextY, FAddCaption);
    end;
  end;
end;

// ---------------------------------------------------------------------------
// Mouse events
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.PillMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Btn: TDockButton;
  NewMenuHovered, NewPreviewHovered, NewAddHovered, NewFinishHovered: Boolean;
begin
  Btn := GetButtonAt(X, Y);
  NewMenuHovered    := (Btn = btnMenu);
  NewPreviewHovered := (Btn = btnPreview);
  NewAddHovered     := (Btn = btnAdd);
  NewFinishHovered  := (Btn = btnFinish);

  if (NewMenuHovered <> FMenuHovered) or
     (NewPreviewHovered <> FPreviewHovered) or
     (NewAddHovered <> FAddHovered) or
     (NewFinishHovered <> FFinishHovered) then
  begin
    FMenuHovered    := NewMenuHovered;
    FPreviewHovered := NewPreviewHovered;
    FAddHovered     := NewAddHovered;
    FFinishHovered  := NewFinishHovered;

    case Btn of
      btnMenu:    FPillBox.Hint := 'Options & presets menu';
      btnPreview: FPillBox.Hint := 'Launch a quick 3D preview (pascube / vkcube)';
      btnAdd:     FPillBox.Hint := 'Add action';
      btnFinish:  FPillBox.Hint := 'Get your Steam / Heroic launch command';
      else        FPillBox.Hint := '';
    end;
    FPillBox.ShowHint := (Btn <> btnNone);

    if Btn <> btnNone then
      FPillBox.Cursor := crHandPoint
    else
      FPillBox.Cursor := crDefault;

    FPillBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PillMouseEnter(Sender: TObject);
begin
  // Mouse entered pill container
end;

procedure TFloatingActionDock.PillMouseLeave(Sender: TObject);
begin
  if FMenuHovered or FPreviewHovered or FAddHovered or FFinishHovered or
     FMenuPressed or FPreviewPressed or FAddPressed or FFinishPressed then
  begin
    FMenuHovered    := False;
    FPreviewHovered := False;
    FAddHovered     := False;
    FFinishHovered  := False;
    FMenuPressed    := False;
    FPreviewPressed := False;
    FAddPressed     := False;
    FFinishPressed  := False;
    FPillBox.Cursor := crDefault;
    FPillBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PillMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Btn: TDockButton;
begin
  if Button = mbLeft then
  begin
    Btn := GetButtonAt(X, Y);
    FMenuPressed    := (Btn = btnMenu);
    FPreviewPressed := (Btn = btnPreview);
    FAddPressed     := (Btn = btnAdd);
    FFinishPressed  := (Btn = btnFinish);
    FPillBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PillMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMenuPressed    := False;
    FPreviewPressed := False;
    FAddPressed     := False;
    FFinishPressed  := False;
    FPillBox.Invalidate;
  end;
end;

procedure TFloatingActionDock.PillClick(Sender: TObject);
var
  P: TPoint;
  Btn: TDockButton;
begin
  P := FPillBox.ScreenToClient(Mouse.CursorPos);
  Btn := GetButtonAt(P.X, P.Y);
  case Btn of
    btnMenu:    if Assigned(FOnMenuClick) then FOnMenuClick(Self);
    btnPreview: if Assigned(FOnPreviewClick) then FOnPreviewClick(Self);
    btnAdd:     if Assigned(FOnAddClick) then FOnAddClick(Self);
    btnFinish:  if Assigned(FOnFinishClick) then FOnFinishClick(Self);
  end;
end;

// ---------------------------------------------------------------------------
// Testing and interaction helpers
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.SimulateMenuHover(AHover: Boolean);
begin
  FMenuHovered := AHover;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulateMenuPress(APressed: Boolean);
begin
  FMenuPressed := APressed;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulatePreviewHover(AHover: Boolean);
begin
  FPreviewHovered := AHover;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulatePreviewPress(APressed: Boolean);
begin
  FPreviewPressed := APressed;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulateAddHover(AHover: Boolean);
begin
  FAddHovered := AHover;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulateAddPress(APressed: Boolean);
begin
  FAddPressed := APressed;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulateFinishHover(AHover: Boolean);
begin
  FFinishHovered := AHover;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.SimulateFinishPress(APressed: Boolean);
begin
  FFinishPressed := APressed;
  if Assigned(FPillBox) then FPillBox.Invalidate;
end;

procedure TFloatingActionDock.PerformMenuClick;
begin
  if Assigned(FOnMenuClick) then FOnMenuClick(Self);
end;

procedure TFloatingActionDock.PerformPreviewClick;
begin
  if Assigned(FOnPreviewClick) then FOnPreviewClick(Self);
end;

procedure TFloatingActionDock.PerformAddClick;
begin
  if Assigned(FOnAddClick) then FOnAddClick(Self);
end;

procedure TFloatingActionDock.PerformFinishClick;
begin
  if Assigned(FOnFinishClick) then FOnFinishClick(Self);
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
  if Assigned(FPillBox) then FPillBox.Invalidate;
  FDockPanel.BringToFront;
end;

procedure TFloatingActionDock.BringToFront;
begin
  if FDockPanel.Visible then
    FDockPanel.BringToFront;
end;

end.
