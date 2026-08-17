unit floating_overlay;

{$mode objfpc}{$H+}

// ---------------------------------------------------------------------------
//  floating_overlay.pas
//  Provides:
//    1. TFloatingToast: Unobtrusive floating auto-save badge anchored at the
//       bottom-left corner of the main container, with auto-fadeout.
//    2. TFloatingProgressBanner: Floating download progress banner positioned
//       at the top of the interface displaying percentage and status in English.
// ---------------------------------------------------------------------------

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  LCLIntf, LCLType, Math;

type

  { TFloatingToast }
  TFloatingToast = class(TObject)
  private
    FParent:       TWinControl;
    FToastPanel:   TPanel;
    FPaintBox:     TPaintBox;
    FTimer:        TTimer;
    FMessage:      string;

    procedure PaintBoxPaint(Sender: TObject);
    procedure TimerTick(Sender: TObject);
  public
    constructor Create(AParent: TWinControl);
    destructor  Destroy; override;

    procedure ShowToast(const AMessage: string = 'Settings saved'; ADurationMs: Integer = 1800);
    procedure HideToast;
    procedure BringToFront;
    procedure Reposition;
  end;

  { TFloatingProgressBanner }
  TFloatingProgressBanner = class(TObject)
  private
    FParent:       TWinControl;
    FBannerPanel:  TPanel;
    FPaintBox:     TPaintBox;
    FMessage:      string;
    FPercent:      Integer;

    function  GetVisible: Boolean;
    procedure PaintBoxPaint(Sender: TObject);
  public
    constructor Create(AParent: TWinControl);
    destructor  Destroy; override;

    procedure ShowProgress(const AMessage: string; APercent: Integer);
    procedure UpdateProgress(APercent: Integer; const AMessage: string = '');
    procedure HideProgress;
    procedure BringToFront;
    procedure Reposition;

    property Visible: Boolean read GetVisible;
  end;

implementation

const
  CLR_TOAST_BG      = $241C16;  // #161C24 dark navy/slate
  CLR_TOAST_BORDER  = $4C3B2E;  // #2E3B4C
  CLR_TOAST_TEXT    = $FFFFFF;
  CLR_TOAST_ACCENT  = $A9D938;  // #38D9A9 mint green (BGR)

  CLR_BANNER_BG     = $281E18;  // #181E28
  CLR_BANNER_BORDER = $6A4A28;  // #284A6A
  CLR_BANNER_TEXT   = $E2E8F0;  // #F0E8E2
  CLR_BANNER_MUTED  = $94A3B8;
  CLR_PROG_TRACK    = $3D2E24;  // #242E3D
  CLR_PROG_FILL     = $F0BE30;  // #30BEF0 cyan (BGR)

{ TFloatingToast }

constructor TFloatingToast.Create(AParent: TWinControl);
const
  TOAST_W = 160;
  TOAST_H = 34;
begin
  inherited Create;
  FParent  := AParent;
  FMessage := 'Settings saved';

  FToastPanel := TPanel.Create(AParent);
  FToastPanel.Parent := AParent;
  FToastPanel.BevelOuter := bvNone;
  FToastPanel.BevelInner := bvNone;
  FToastPanel.Color := RGBToColor(22, 26, 40);
  FToastPanel.ParentBackground := False;
  FToastPanel.Width := TOAST_W;
  FToastPanel.Height := TOAST_H;
  FToastPanel.Anchors := [akLeft, akBottom];
  FToastPanel.Left := 24;
  FToastPanel.Top := Max(10, AParent.ClientHeight - TOAST_H - 24);
  FToastPanel.Visible := False;

  FPaintBox := TPaintBox.Create(FToastPanel);
  FPaintBox.Parent := FToastPanel;
  FPaintBox.Align := alClient;
  FPaintBox.OnPaint := @PaintBoxPaint;

  FTimer := TTimer.Create(FToastPanel);
  FTimer.Enabled := False;
  FTimer.OnTimer := @TimerTick;
end;

destructor TFloatingToast.Destroy;
begin
  if Assigned(FTimer) then
    FTimer.Enabled := False;
  FToastPanel.Visible := False;
  inherited;
end;

procedure TFloatingToast.PaintBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
  R: TRect;
  Rad: Integer;
begin
  PB := Sender as TPaintBox;
  R := Rect(0, 0, PB.Width, PB.Height);
  Rad := PB.Height div 2;

  // Clear bounding rect with container background to eliminate white edges
  PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.Pen.Color   := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(R);

  // Drop shadow
  PB.Canvas.Brush.Color := RGBToColor(0, 0, 0);
  PB.Canvas.Pen.Color   := RGBToColor(0, 0, 0);
  PB.Canvas.RoundRect(R.Left + 2, R.Top + 2, R.Right + 2, R.Bottom + 2, Rad, Rad);

  // Background pill
  PB.Canvas.Brush.Color := RGBToColor(22, 28, 36);
  PB.Canvas.Pen.Color   := RGBToColor(46, 59, 76);
  PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);

  // Checkmark icon
  PB.Canvas.Font.Name  := 'Noto Sans';
  PB.Canvas.Font.Size  := 10;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := RGBToColor(56, 217, 169); // mint green
  PB.Canvas.Brush.Style := bsClear;
  PB.Canvas.TextOut(12, (PB.Height - PB.Canvas.TextHeight('✓')) div 2, '✓');

  // Text
  PB.Canvas.Font.Size  := 9;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := clWhite;
  PB.Canvas.TextOut(28, (PB.Height - PB.Canvas.TextHeight(FMessage)) div 2, FMessage);
  PB.Canvas.Brush.Style := bsSolid;
end;

procedure TFloatingToast.TimerTick(Sender: TObject);
begin
  FTimer.Enabled := False;
  FToastPanel.Visible := False;
end;

procedure TFloatingToast.ShowToast(const AMessage: string = 'Settings saved'; ADurationMs: Integer = 1800);
begin
  FMessage := AMessage;
  Reposition;
  FToastPanel.Visible := True;
  FToastPanel.BringToFront;
  FPaintBox.Invalidate;

  FTimer.Enabled := False;
  FTimer.Interval := ADurationMs;
  FTimer.Enabled := True;
end;

procedure TFloatingToast.HideToast;
begin
  FTimer.Enabled := False;
  FToastPanel.Visible := False;
end;

procedure TFloatingToast.BringToFront;
begin
  if FToastPanel.Visible then
    FToastPanel.BringToFront;
end;

procedure TFloatingToast.Reposition;
begin
  FToastPanel.Left := 24;
  FToastPanel.Top := Max(10, FParent.ClientHeight - FToastPanel.Height - 24);
end;

{ TFloatingProgressBanner }

function TFloatingProgressBanner.GetVisible: Boolean;
begin
  if Assigned(FBannerPanel) then
    Result := FBannerPanel.Visible
  else
    Result := False;
end;

constructor TFloatingProgressBanner.Create(AParent: TWinControl);
const
  BANNER_W = 380;
  BANNER_H = 54;
begin
  inherited Create;
  FParent  := AParent;
  FMessage := 'Downloading components...';
  FPercent := 0;

  FBannerPanel := TPanel.Create(AParent);
  FBannerPanel.Parent := AParent;
  FBannerPanel.BevelOuter := bvNone;
  FBannerPanel.BevelInner := bvNone;
  FBannerPanel.Color := RGBToColor(22, 26, 40);
  FBannerPanel.ParentBackground := False;
  FBannerPanel.Width := BANNER_W;
  FBannerPanel.Height := BANNER_H;
  FBannerPanel.Anchors := [akTop];
  FBannerPanel.Top := 16;
  FBannerPanel.Left := Max(10, (AParent.ClientWidth - BANNER_W) div 2);
  FBannerPanel.Visible := False;

  FPaintBox := TPaintBox.Create(FBannerPanel);
  FPaintBox.Parent := FBannerPanel;
  FPaintBox.Align := alClient;
  FPaintBox.OnPaint := @PaintBoxPaint;
end;

destructor TFloatingProgressBanner.Destroy;
begin
  FBannerPanel.Visible := False;
  inherited;
end;

procedure TFloatingProgressBanner.PaintBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
  R, BarR, FillR: TRect;
  Rad, TrackW, FillW: Integer;
  PctStr: string;
begin
  PB := Sender as TPaintBox;
  R := Rect(0, 0, PB.Width, PB.Height);
  Rad := 12;

  // Clear bounding rect with container background to eliminate white edges
  PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.Pen.Color   := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(R);

  // Drop shadow
  PB.Canvas.Brush.Color := RGBToColor(0, 0, 0);
  PB.Canvas.Pen.Color   := RGBToColor(0, 0, 0);
  PB.Canvas.RoundRect(R.Left + 3, R.Top + 3, R.Right + 3, R.Bottom + 3, Rad, Rad);

  // Background card
  PB.Canvas.Brush.Color := RGBToColor(24, 30, 40);
  PB.Canvas.Pen.Color   := RGBToColor(40, 74, 106);
  PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Rad, Rad);

  // Status Message text
  PB.Canvas.Font.Name  := 'Noto Sans';
  PB.Canvas.Font.Size  := 9;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := RGBToColor(240, 232, 226);
  PB.Canvas.Brush.Style := bsClear;
  PB.Canvas.TextOut(14, 10, FMessage);

  // Percentage text on right
  PctStr := IntToStr(EnsureRange(FPercent, 0, 100)) + '%';
  PB.Canvas.Font.Size  := 9;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := RGBToColor(48, 190, 240); // Cyan
  PB.Canvas.TextOut(PB.Width - PB.Canvas.TextWidth(PctStr) - 14, 10, PctStr);

  // Progress Bar Track
  BarR := Rect(14, 32, PB.Width - 14, 40);
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Brush.Color := RGBToColor(36, 46, 61);
  PB.Canvas.Pen.Color   := RGBToColor(36, 46, 61);
  PB.Canvas.RoundRect(BarR.Left, BarR.Top, BarR.Right, BarR.Bottom, 4, 4);

  // Progress Bar Fill
  TrackW := BarR.Right - BarR.Left;
  FillW := Round((TrackW * EnsureRange(FPercent, 0, 100)) / 100);
  if FillW > 0 then
  begin
    FillR := Rect(BarR.Left, BarR.Top, BarR.Left + FillW, BarR.Bottom);
    PB.Canvas.Brush.Color := RGBToColor(48, 190, 240); // Vivid cyan fill
    PB.Canvas.Pen.Color   := RGBToColor(48, 190, 240);
    PB.Canvas.RoundRect(FillR.Left, FillR.Top, FillR.Right, FillR.Bottom, 4, 4);
  end;
end;

procedure TFloatingProgressBanner.ShowProgress(const AMessage: string; APercent: Integer);
begin
  FMessage := AMessage;
  FPercent := APercent;
  Reposition;
  FBannerPanel.Visible := True;
  FBannerPanel.BringToFront;
  FPaintBox.Invalidate;
  Application.ProcessMessages;
end;

procedure TFloatingProgressBanner.UpdateProgress(APercent: Integer; const AMessage: string = '');
begin
  FPercent := APercent;
  if AMessage <> '' then
    FMessage := AMessage;
  if not FBannerPanel.Visible then
  begin
    Reposition;
    FBannerPanel.Visible := True;
    FBannerPanel.BringToFront;
  end;
  FPaintBox.Invalidate;
  Application.ProcessMessages;
end;

procedure TFloatingProgressBanner.HideProgress;
begin
  FBannerPanel.Visible := False;
  Application.ProcessMessages;
end;

procedure TFloatingProgressBanner.BringToFront;
begin
  if FBannerPanel.Visible then
    FBannerPanel.BringToFront;
end;

procedure TFloatingProgressBanner.Reposition;
begin
  FBannerPanel.Top := 16;
  FBannerPanel.Left := Max(10, (FParent.ClientWidth - FBannerPanel.Width) div 2);
end;

end.
