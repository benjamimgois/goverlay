unit notificationunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, LCLType, LCLIntf, Math,
  {$IFDEF LCLqt6}
  qt6,
  qtobjects,
  qtwidgets
  {$ELSE}
  {$IFDEF LCLqt5}
  qt5,
  qtobjects,
  qtwidgets
  {$ENDIF}
  {$ENDIF}
  ;

type
  TNotificationType = (ntSuccess, ntWarning, ntError, ntInfo);
  
  { TToastNotification }
  TToastNotification = class(TForm)
  private
    FNotifType: TNotificationType;
    FMessage: string;
    FDuration: Integer;
    FTimer: TTimer;
    FPaintBox: TPaintBox;
    FCloseHovered: Boolean;
    FCloseRect: TRect;
    
    // Theme & Styling colors
    FAccentColor: TColor;
    FBorderColor: TColor;
    FTitleColor: TColor;
    FMessageColor: TColor;
    FIconBadgeBg: TColor;
    FIconBadgeBorder: TColor;
    FIconText: string;
    FTitleText: string;
    
    procedure SetupUI;
    procedure ConfigureThemeColors;
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseEnter(Sender: TObject);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure TimerTick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AType: TNotificationType; 
                      const AMessage: string; ADuration: Integer = 3000); reintroduce;
    destructor Destroy; override;
    procedure ShowNotification;
    procedure HideNotification;
    procedure ResetDuration(ANewDuration: Integer);
    property NotifType: TNotificationType read FNotifType;
    property MessageText: string read FMessage;
  end;

procedure ShowToast(AType: TNotificationType; const AMessage: string; 
                   ADuration: Integer = 3000);

implementation

uses
  themeunit;

var
  ActiveToasts: TList = nil;
  ToastYOffset: Integer = 14;

procedure ShowToast(AType: TNotificationType; const AMessage: string; 
                   ADuration: Integer = 3000);
var
  Toast: TToastNotification;
  i: Integer;
begin
  // Deduplication: prevent identical toasts from stacking simultaneously
  if Assigned(ActiveToasts) then
  begin
    for i := 0 to ActiveToasts.Count - 1 do
    begin
      Toast := TToastNotification(ActiveToasts[i]);
      if Assigned(Toast) and (Toast.NotifType = AType) and (Toast.MessageText = AMessage) then
      begin
        Toast.ResetDuration(ADuration);
        Toast.BringToFront;
        Exit;
      end;
    end;
  end;

  Toast := TToastNotification.Create(Application, AType, AMessage, ADuration);
  Toast.ShowNotification;
end;

{ TToastNotification }

constructor TToastNotification.Create(AOwner: TComponent; 
  AType: TNotificationType; const AMessage: string; ADuration: Integer);
begin
  inherited CreateNew(AOwner);
  
  FNotifType := AType;
  FMessage := AMessage;
  FDuration := ADuration;
  FCloseHovered := False;
  
  if ActiveToasts = nil then
    ActiveToasts := TList.Create;
  
  SetupUI;
end;

destructor TToastNotification.Destroy;
begin
  if Assigned(FTimer) then
    FTimer.Enabled := False;
  if Assigned(ActiveToasts) then
    ActiveToasts.Remove(Self);
  inherited Destroy;
end;

procedure TToastNotification.ConfigureThemeColors;
begin
  if CurrentTheme = tmDark then
  begin
    // Deep dark surface (#10141d) to maximize contrast over GOverlay background cards (#181e2b)
    Color := RGBToColor(16, 20, 29);
    FMessageColor := RGBToColor(241, 245, 249); // High contrast text (#f1f5f9)

    case FNotifType of
      ntWarning:
        begin
          FAccentColor := RGBToColor(245, 158, 11);     // Vibrant Amber (#f59e0b)
          FBorderColor := RGBToColor(245, 158, 11);     // Full accent border outline
          FTitleColor := RGBToColor(251, 191, 36);      // Bright Amber title
          FIconBadgeBg := RGBToColor(46, 30, 14);       // Warm amber badge
          FIconBadgeBorder := RGBToColor(180, 110, 10);
          FIconText := '⚠';
          FTitleText := 'Warning';
        end;
      ntSuccess:
        begin
          FAccentColor := RGBToColor(16, 185, 129);     // Emerald (#10b981)
          FBorderColor := RGBToColor(16, 185, 129);     // Full accent border outline
          FTitleColor := RGBToColor(52, 211, 153);      // Mint title
          FIconBadgeBg := RGBToColor(14, 42, 28);
          FIconBadgeBorder := RGBToColor(16, 140, 95);
          FIconText := '✓';
          FTitleText := 'Success';
        end;
      ntError:
        begin
          FAccentColor := RGBToColor(239, 68, 68);      // Crimson (#ef4444)
          FBorderColor := RGBToColor(239, 68, 68);      // Full accent border outline
          FTitleColor := RGBToColor(248, 113, 113);     // Bright Red title
          FIconBadgeBg := RGBToColor(48, 18, 22);
          FIconBadgeBorder := RGBToColor(180, 40, 50);
          FIconText := '✕';
          FTitleText := 'Error';
        end;
      ntInfo:
        begin
          FAccentColor := RGBToColor(56, 189, 248);     // Cyan (#38bdf8)
          FBorderColor := RGBToColor(56, 189, 248);     // Full accent border outline
          FTitleColor := RGBToColor(56, 189, 248);      // Sky Cyan title
          FIconBadgeBg := RGBToColor(16, 36, 52);
          FIconBadgeBorder := RGBToColor(30, 120, 180);
          FIconText := 'ℹ';
          FTitleText := 'Information';
        end;
    end;
  end
  else
  begin
    Color := RGBToColor(255, 255, 255);
    FMessageColor := RGBToColor(30, 41, 59);

    case FNotifType of
      ntWarning:
        begin
          FAccentColor := RGBToColor(217, 119, 6);
          FBorderColor := RGBToColor(245, 158, 11);
          FTitleColor := RGBToColor(180, 83, 9);
          FIconBadgeBg := RGBToColor(254, 243, 199);
          FIconBadgeBorder := RGBToColor(251, 191, 36);
          FIconText := '⚠';
          FTitleText := 'Warning';
        end;
      ntSuccess:
        begin
          FAccentColor := RGBToColor(5, 150, 105);
          FBorderColor := RGBToColor(16, 185, 129);
          FTitleColor := RGBToColor(4, 120, 87);
          FIconBadgeBg := RGBToColor(209, 250, 229);
          FIconBadgeBorder := RGBToColor(110, 231, 183);
          FIconText := '✓';
          FTitleText := 'Success';
        end;
      ntError:
        begin
          FAccentColor := RGBToColor(220, 38, 38);
          FBorderColor := RGBToColor(239, 68, 68);
          FTitleColor := RGBToColor(185, 28, 28);
          FIconBadgeBg := RGBToColor(254, 226, 226);
          FIconBadgeBorder := RGBToColor(252, 165, 165);
          FIconText := '✕';
          FTitleText := 'Error';
        end;
      ntInfo:
        begin
          FAccentColor := RGBToColor(2, 132, 199);
          FBorderColor := RGBToColor(56, 189, 248);
          FTitleColor := RGBToColor(3, 105, 161);
          FIconBadgeBg := RGBToColor(224, 242, 254);
          FIconBadgeBorder := RGBToColor(125, 211, 252);
          FIconText := 'ℹ';
          FTitleText := 'Information';
        end;
    end;
  end;
end;

procedure TToastNotification.SetupUI;
var
  ScreenWidth, ScreenHeight: Integer;
  ToastWidth, ToastHeight: Integer;
  YPosition: Integer;
  i: Integer;
  CalcR: TRect;
begin
  ConfigureThemeColors;

  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  ToastWidth := 400;
  Width := ToastWidth;

  // Calculate message height using text metrics
  Canvas.Font.Name := UI_FONT_FAMILY;
  Canvas.Font.Size := 9;
  Canvas.Font.Style := [];
  CalcR := Rect(58, 34, ToastWidth - 36, 34);
  DrawText(Canvas.Handle, PChar(FMessage), Length(FMessage), CalcR,
    DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_CALCRECT);

  ToastHeight := Max(70, CalcR.Bottom + 16);
  Height := ToastHeight;

  // Close button rect (22x22)
  FCloseRect := Rect(ToastWidth - 30, 10, ToastWidth - 10, 30);

  // Single dedicated paintbox for flicker-free double-buffered rendering
  FPaintBox := TPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.OnPaint := @PaintBoxPaint;
  FPaintBox.OnMouseMove := @PaintBoxMouseMove;
  FPaintBox.OnMouseDown := @PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := @PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := @PaintBoxMouseLeave;

  // Screen positioning
  ScreenWidth := Screen.Width;
  ScreenHeight := Screen.Height;

  YPosition := ToastYOffset;
  for i := 0 to ActiveToasts.Count - 1 do
  begin
    if TToastNotification(ActiveToasts[i]).Visible then
      YPosition := YPosition + TToastNotification(ActiveToasts[i]).Height + 10;
  end;

  Left := ScreenWidth - ToastWidth - 24;
  Top := YPosition;

  // Auto-close timer
  FTimer := TTimer.Create(Self);
  FTimer.Interval := FDuration;
  FTimer.OnTimer := @TimerTick;
  FTimer.Enabled := False;

  ActiveToasts.Add(Self);
end;

procedure TToastNotification.PaintBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
  R, MsgR: TRect;
  CornerDiam: Integer;
  GW, GH, CW, CH: Integer;
begin
  PB := Sender as TPaintBox;
  R := Rect(0, 0, PB.Width, PB.Height);
  CornerDiam := 14; // 7px radius

  // 1. Fill background with elevated dark surface
  PB.Canvas.Brush.Color := Color;
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Pen.Color := Color;
  PB.Canvas.FillRect(R);

  {$IFDEF LCLqt6}
  if PB.Canvas.Handle <> 0 then
  begin
    TQtDeviceContext(PB.Canvas.Handle).setRenderHint(QPainterAntialiasing, True);
    TQtDeviceContext(PB.Canvas.Handle).setRenderHint(QPainterSmoothPixmapTransform, True);
    TQtDeviceContext(PB.Canvas.Handle).setRenderHint(QPainterTextAntialiasing, True);
  end;
  {$ENDIF}

  // 2. Concept B: Full Vibrant Accent Outline Border (2px)
  PB.Canvas.Brush.Color := Color;
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Pen.Color := FBorderColor;
  PB.Canvas.Pen.Width := 2;
  PB.Canvas.RoundRect(1, 1, PB.Width - 1, PB.Height - 1, CornerDiam, CornerDiam);

  // 3. Circular Icon Badge with Accent Outline
  PB.Canvas.Brush.Color := FIconBadgeBg;
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Pen.Color := FIconBadgeBorder;
  PB.Canvas.Pen.Width := 1;
  PB.Canvas.Ellipse(14, 14, 46, 46);

  // 4. Centered Icon Glyph
  PB.Canvas.Font.Name := UI_FONT_FAMILY;
  PB.Canvas.Font.Size := 13;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := FAccentColor;
  PB.Canvas.Brush.Style := bsClear;
  GW := PB.Canvas.TextWidth(FIconText);
  GH := PB.Canvas.TextHeight(FIconText);
  PB.Canvas.TextOut(14 + (32 - GW) div 2, 14 + (32 - GH) div 2, FIconText);

  // 5. Title in Status Accent Color (Concept B highlight)
  PB.Canvas.Font.Size := 10;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Font.Color := FTitleColor;
  PB.Canvas.Brush.Style := bsClear;
  PB.Canvas.TextOut(56, 12, FTitleText);

  // 6. High-Contrast Message Text with word-wrapping
  PB.Canvas.Font.Size := 9;
  PB.Canvas.Font.Style := [];
  PB.Canvas.Font.Color := FMessageColor;
  PB.Canvas.Brush.Style := bsClear;
  MsgR := Rect(56, 32, PB.Width - 34, PB.Height - 8);
  DrawText(PB.Canvas.Handle, PChar(FMessage), Length(FMessage), MsgR,
    DT_LEFT or DT_WORDBREAK or DT_NOPREFIX);

  // 7. Integrated Close Button
  if FCloseHovered then
  begin
    PB.Canvas.Brush.Color := FIconBadgeBg;
    PB.Canvas.Brush.Style := bsSolid;
    PB.Canvas.Pen.Color := FAccentColor;
    PB.Canvas.Pen.Width := 1;
    PB.Canvas.RoundRect(FCloseRect.Left, FCloseRect.Top, FCloseRect.Right, FCloseRect.Bottom, 4, 4);
    PB.Canvas.Font.Color := FAccentColor;
  end
  else
  begin
    PB.Canvas.Brush.Style := bsClear;
    if CurrentTheme = tmDark then
      PB.Canvas.Font.Color := RGBToColor(160, 174, 192)
    else
      PB.Canvas.Font.Color := RGBToColor(100, 116, 139);
  end;

  PB.Canvas.Font.Name := UI_FONT_FAMILY;
  PB.Canvas.Font.Size := 9;
  PB.Canvas.Font.Style := [fsBold];
  PB.Canvas.Brush.Style := bsClear;
  CW := PB.Canvas.TextWidth('✕');
  CH := PB.Canvas.TextHeight('✕');
  PB.Canvas.TextOut(FCloseRect.Left + (20 - CW) div 2, FCloseRect.Top + (20 - CH) div 2, '✕');
end;

procedure TToastNotification.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  HoveringClose: Boolean;
begin
  HoveringClose := PtInRect(FCloseRect, Point(X, Y));
  if HoveringClose <> FCloseHovered then
  begin
    FCloseHovered := HoveringClose;
    if FCloseHovered then
      FPaintBox.Cursor := crHandPoint
    else
      FPaintBox.Cursor := crDefault;
    FPaintBox.Invalidate;
  end;
end;

procedure TToastNotification.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and PtInRect(FCloseRect, Point(X, Y)) then
    HideNotification;
end;

procedure TToastNotification.PaintBoxMouseEnter(Sender: TObject);
begin
  if Assigned(FTimer) then
    FTimer.Enabled := False;
end;

procedure TToastNotification.PaintBoxMouseLeave(Sender: TObject);
begin
  if FCloseHovered then
  begin
    FCloseHovered := False;
    FPaintBox.Cursor := crDefault;
    FPaintBox.Invalidate;
  end;
  if Assigned(FTimer) then
    FTimer.Enabled := True;
end;

procedure TToastNotification.ResetDuration(ANewDuration: Integer);
begin
  FDuration := ANewDuration;
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FTimer.Interval := FDuration;
    FTimer.Enabled := True;
  end;
end;

procedure TToastNotification.ShowNotification;
begin
  Show;
  FTimer.Enabled := True;
end;

procedure TToastNotification.HideNotification;
begin
  FTimer.Enabled := False;
  Close;
  Free;
end;

procedure TToastNotification.TimerTick(Sender: TObject);
begin
  FTimer.Enabled := False;
  HideNotification;
end;

initialization

finalization
  if Assigned(ActiveToasts) then
    FreeAndNil(ActiveToasts);

end.
