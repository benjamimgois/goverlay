unit floating_dock;

{$mode objfpc}{$H+}

// ---------------------------------------------------------------------------
//  TFloatingActionDock — a compact pill-style floating action bar that sits
//  above the bottom-right corner of goverlayPanel. It hosts contextual buttons:
//
//    [ ▶ Preview ]   (optional — shown on MangoHud, vkBasalt, vkSumi)
//    [  ☰  Menu  ]   (optional — shown when active tab has popup menu options)
//    [   + Add   ]   (optional — shown on EnvVars tab)
//    [  ✦ Finish ]   (primary accent button, always visible when dock is shown)
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

    // Buttons (in pill, left-to-right layout)
    FPreviewBtn:     TSpeedButton;
    FMenuBtn:        TSpeedButton;
    FAddBtn:         TSpeedButton;
    FFinishBtn:      TSpeedButton;

    FPreviewVisible: Boolean;
    FMenuVisible:    Boolean;
    FAddVisible:     Boolean;

    FOnPreviewClick: TNotifyEvent;
    FOnMenuClick:    TNotifyEvent;
    FOnAddClick:     TNotifyEvent;
    FOnFinishClick:  TNotifyEvent;

    function  GetVisible: Boolean;
    procedure SetVisible(AValue: Boolean);
    procedure PillPaint(Sender: TObject);
    procedure FinishBtnClick(Sender: TObject);
    procedure MenuBtnClick(Sender: TObject);
    procedure PreviewBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure LayoutButtons;

  public
    constructor Create(AParent: TWinControl);
    destructor  Destroy; override;

    // Call when switching tabs:
    // AShowPreview: True for tabs with 3D preview support
    // AShowMenu: True for tabs with popup menu options
    // AShowAdd: True for EnvVars tab
    // AVisible: False to completely hide the dock (e.g. on Games tab)
    procedure UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean; AVisible: Boolean = True);

    procedure Show;
    procedure Hide;
    procedure BringToFront;

    property Visible:        Boolean      read GetVisible write SetVisible;
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

  // ---- Preview button ----
  FPreviewBtn             := TSpeedButton.Create(FDockPanel);
  FPreviewBtn.Parent      := FDockPanel;
  FPreviewBtn.Caption     := ' ▶ Preview';
  FPreviewBtn.Font.Name   := 'Noto Sans';
  FPreviewBtn.Font.Size   := 8;
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
  FMenuBtn.Font.Size      := 11;
  FMenuBtn.Font.Style     := [];
  FMenuBtn.Font.Color     := RGBToColor(180, 190, 205);
  FMenuBtn.Flat           := True;
  FMenuBtn.OnClick        := @MenuBtnClick;
  FMenuBtn.ShowHint       := True;
  FMenuBtn.Hint           := 'Options & presets menu';

  // ---- Add button (EnvVars) ----
  FAddBtn                 := TSpeedButton.Create(FDockPanel);
  FAddBtn.Parent          := FDockPanel;
  FAddBtn.Caption         := ' + Add';
  FAddBtn.Font.Name       := 'Noto Sans';
  FAddBtn.Font.Size       := 8;
  FAddBtn.Font.Style      := [fsBold];
  FAddBtn.Font.Color      := RGBToColor(180, 190, 205);
  FAddBtn.Flat            := True;
  FAddBtn.OnClick         := @AddBtnClick;
  FAddBtn.ShowHint        := True;
  FAddBtn.Hint            := 'Add custom environment variable';

  // ---- Finish button ----
  FFinishBtn              := TSpeedButton.Create(FDockPanel);
  FFinishBtn.Parent       := FDockPanel;
  FFinishBtn.Caption      := ' ✦ Finish';
  FFinishBtn.Font.Name    := 'Noto Sans';
  FFinishBtn.Font.Size    := 8;
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
  X, TotalPillW: Integer;
begin
  TotalPillW := INNER_PAD_X * 2 + FINISH_W;
  if FPreviewVisible then
    Inc(TotalPillW, PREVIEW_W + BTN_GAP);
  if FMenuVisible then
    Inc(TotalPillW, MENU_W + BTN_GAP);
  if FAddVisible then
    Inc(TotalPillW, ADD_W + BTN_GAP);

  // Resize the dock panel and reposition to right edge
  FDockPanel.Width  := TotalPillW;
  FDockPanel.Height := BTN_H + INNER_PAD_Y * 2;
  FDockPanel.Left   := FParent.ClientWidth - TotalPillW - DOCK_RIGHT;
  FDockPanel.Top    := FParent.ClientHeight - FDockPanel.Height - DOCK_BOTTOM;

  // Resize pill box
  FPillBox.Width  := TotalPillW;
  FPillBox.Height := FDockPanel.Height;

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

  if FMenuVisible then
  begin
    FMenuBtn.SetBounds(X, INNER_PAD_Y, MENU_W, BTN_H);
    FMenuBtn.Visible := True;
    Inc(X, MENU_W + BTN_GAP);
  end
  else
    FMenuBtn.Visible := False;

  if FAddVisible then
  begin
    FAddBtn.SetBounds(X, INNER_PAD_Y, ADD_W, BTN_H);
    FAddBtn.Visible := True;
    Inc(X, ADD_W + BTN_GAP);
  end
  else
    FAddBtn.Visible := False;

  FFinishBtn.SetBounds(X, INNER_PAD_Y, FINISH_W, BTN_H);
end;

// ---------------------------------------------------------------------------
// Pill painting
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.PillPaint(Sender: TObject);
var
  PB: TPaintBox;
  R: TRect;
  Rad, BX: Integer;
  IsSoloFinish: Boolean;
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

  IsSoloFinish := not FPreviewVisible and not FMenuVisible and not FAddVisible;

  if IsSoloFinish then
  begin
    // Standalone Finish pill: entire pill has the cyan accent fill
    PB.Canvas.Brush.Color := RGBToColor(32, 120, 180);
    PB.Canvas.Pen.Color   := RGBToColor(48, 190, 240);
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);
  end
  else
  begin
    // Multi-button pill: dark background
    PB.Canvas.Brush.Color := RGBToColor(24, 30, 42);
    PB.Canvas.Pen.Color   := RGBToColor(46, 58, 80);
    PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);

    // Finish button accent background (right portion)
    BX := FFinishBtn.Left;
    PB.Canvas.Brush.Color := RGBToColor(32, 120, 180);
    PB.Canvas.Pen.Color   := RGBToColor(32, 120, 180);
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

procedure TFloatingActionDock.AddBtnClick(Sender: TObject);
begin
  if Assigned(FOnAddClick) then FOnAddClick(Self);
end;

procedure TFloatingActionDock.FinishBtnClick(Sender: TObject);
begin
  if Assigned(FOnFinishClick) then FOnFinishClick(Self);
end;

// ---------------------------------------------------------------------------
// Public methods
// ---------------------------------------------------------------------------

procedure TFloatingActionDock.UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean; AVisible: Boolean = True);
begin
  SetVisible(AVisible);
  if not AVisible then Exit;

  FPreviewVisible := AShowPreview;
  FMenuVisible    := AShowMenu;
  FAddVisible     := AShowAdd;
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
