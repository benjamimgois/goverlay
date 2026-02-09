unit notificationunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, LCLType;

type
  TNotificationType = (ntSuccess, ntWarning, ntError, ntInfo);
  
  { TToastNotification }
  TToastNotification = class(TForm)
  private
    FNotifType: TNotificationType;
    FMessage: string;
    FDuration: Integer;
    FTimer: TTimer;
    FMessageLabel: TLabel;
    FIconLabel: TLabel;
    FCloseButton: TButton;
    FAnimationTimer: TTimer;
    FCurrentOpacity: Integer;
    FFadingOut: Boolean;
    
    procedure SetupUI;
    procedure GetNotificationColors(out ABgColor, ATextColor: TColor; out AIcon: string);
    procedure TimerTick(Sender: TObject);
    procedure AnimationTimerTick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AType: TNotificationType; 
                      const AMessage: string; ADuration: Integer = 3000); reintroduce;
    procedure ShowNotification;
    procedure HideNotification;
  end;

procedure ShowToast(AType: TNotificationType; const AMessage: string; 
                   ADuration: Integer = 3000);

implementation

uses
  themeunit;

var
  ActiveToasts: TList = nil;
  ToastYOffset: Integer = 10;

procedure ShowToast(AType: TNotificationType; const AMessage: string; 
                   ADuration: Integer = 3000);
var
  Toast: TToastNotification;
begin
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
  FCurrentOpacity := 0;
  FFadingOut := False;
  
  // Initialize active toasts list
  if ActiveToasts = nil then
    ActiveToasts := TList.Create;
  
  SetupUI;
end;

procedure TToastNotification.SetupUI;
var
  BgColor, TextColor: TColor;
  IconText: string;
  ScreenWidth, ScreenHeight: Integer;
  ToastWidth, ToastHeight: Integer;
  YPosition: Integer;
  i: Integer;
begin
  // Form properties
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  ToastWidth := 350;
  ToastHeight := 80;
  Width := ToastWidth;
  Height := ToastHeight;
  
  // Get screen dimensions
  ScreenWidth := Screen.Width;
  ScreenHeight := Screen.Height;
  
  // Calculate Y position based on existing toasts
  YPosition := ToastYOffset;
  for i := 0 to ActiveToasts.Count - 1 do
  begin
    if TToastNotification(ActiveToasts[i]).Visible then
      YPosition := YPosition + TToastNotification(ActiveToasts[i]).Height + 10;
  end;
  
  // Position in top-right corner
  Left := ScreenWidth - ToastWidth - 20;
  Top := YPosition;
  
  // Get colors based on notification type
  GetNotificationColors(BgColor, TextColor, IconText);
  
  Color := BgColor;
  
  // Icon label
  FIconLabel := TLabel.Create(Self);
  FIconLabel.Parent := Self;
  FIconLabel.Left := 15;
  FIconLabel.Top := (Height - 30) div 2;
  FIconLabel.Width := 30;
  FIconLabel.Height := 30;
  FIconLabel.Caption := IconText;
  FIconLabel.Font.Size := 18;
  FIconLabel.Font.Color := TextColor;
  FIconLabel.Alignment := taCenter;
  FIconLabel.Layout := tlCenter;
  
  // Message label
  FMessageLabel := TLabel.Create(Self);
  FMessageLabel.Parent := Self;
  FMessageLabel.Left := 55;
  FMessageLabel.Top := 10;
  FMessageLabel.Width := ToastWidth - 100;
  FMessageLabel.Height := Height - 20;
  FMessageLabel.Caption := FMessage;
  FMessageLabel.Font.Color := TextColor;
  FMessageLabel.Font.Size := 10;
  FMessageLabel.WordWrap := True;
  FMessageLabel.AutoSize := False;
  
  // Close button
  FCloseButton := TButton.Create(Self);
  FCloseButton.Parent := Self;
  FCloseButton.Left := ToastWidth - 35;
  FCloseButton.Top := 10;
  FCloseButton.Width := 25;
  FCloseButton.Height := 25;
  FCloseButton.Caption := '×';
  FCloseButton.Font.Size := 12;
  FCloseButton.Font.Color := TextColor;
  FCloseButton.OnClick := @CloseButtonClick;
  
  // Timer for auto-close
  FTimer := TTimer.Create(Self);
  FTimer.Interval := FDuration;
  FTimer.OnTimer := @TimerTick;
  FTimer.Enabled := False;
  
  // Animation timer
  FAnimationTimer := TTimer.Create(Self);
  FAnimationTimer.Interval := 20;
  FAnimationTimer.OnTimer := @AnimationTimerTick;
  FAnimationTimer.Enabled := False;
  
  // Mouse events for pause on hover
  OnMouseEnter := @FormMouseEnter;
  OnMouseLeave := @FormMouseLeave;
  FMessageLabel.OnMouseEnter := @FormMouseEnter;
  FMessageLabel.OnMouseLeave := @FormMouseLeave;
  
  // Add to active toasts
  ActiveToasts.Add(Self);
end;

procedure TToastNotification.GetNotificationColors(out ABgColor, 
  ATextColor: TColor; out AIcon: string);
begin
  // Use theme-aware colors
  if CurrentTheme = tmDark then
  begin
    case FNotifType of
      ntSuccess:
        begin
          ABgColor := RGBToColor(34, 139, 34);  // Forest Green
          ATextColor := clWhite;
          AIcon := '✓';
        end;
      ntWarning:
        begin
          ABgColor := RGBToColor(255, 165, 0);  // Orange
          ATextColor := clBlack;
          AIcon := '⚠';
        end;
      ntError:
        begin
          ABgColor := RGBToColor(220, 20, 60);  // Crimson
          ATextColor := clWhite;
          AIcon := '✗';
        end;
      ntInfo:
        begin
          ABgColor := RGBToColor(30, 144, 255);  // Dodger Blue
          ATextColor := clWhite;
          AIcon := 'ℹ';
        end;
    end;
  end
  else
  begin
    case FNotifType of
      ntSuccess:
        begin
          ABgColor := RGBToColor(76, 175, 80);  // Material Green
          ATextColor := clWhite;
          AIcon := '✓';
        end;
      ntWarning:
        begin
          ABgColor := RGBToColor(255, 193, 7);  // Material Amber
          ATextColor := clBlack;
          AIcon := '⚠';
        end;
      ntError:
        begin
          ABgColor := RGBToColor(244, 67, 54);  // Material Red
          ATextColor := clWhite;
          AIcon := '✗';
        end;
      ntInfo:
        begin
          ABgColor := RGBToColor(33, 150, 243);  // Material Blue
          ATextColor := clWhite;
          AIcon := 'ℹ';
        end;
    end;
  end;
end;

procedure TToastNotification.ShowNotification;
begin
  Show;
  FAnimationTimer.Enabled := True;
  FTimer.Enabled := True;
end;

procedure TToastNotification.HideNotification;
begin
  FFadingOut := True;
  FTimer.Enabled := False;
  FAnimationTimer.Enabled := True;
end;

procedure TToastNotification.TimerTick(Sender: TObject);
begin
  FTimer.Enabled := False;
  HideNotification;
end;

procedure TToastNotification.AnimationTimerTick(Sender: TObject);
begin
  if FFadingOut then
  begin
    // Fade out
    FCurrentOpacity := FCurrentOpacity - 10;
    if FCurrentOpacity <= 0 then
    begin
      FAnimationTimer.Enabled := False;
      ActiveToasts.Remove(Self);
      Close;
      Free;
    end
    else
      AlphaBlendValue := FCurrentOpacity;
  end
  else
  begin
    // Fade in
    FCurrentOpacity := FCurrentOpacity + 15;
    if FCurrentOpacity >= 255 then
    begin
      FCurrentOpacity := 255;
      FAnimationTimer.Enabled := False;
    end;
    AlphaBlendValue := FCurrentOpacity;
    AlphaBlend := True;
  end;
end;

procedure TToastNotification.CloseButtonClick(Sender: TObject);
begin
  HideNotification;
end;

procedure TToastNotification.FormMouseEnter(Sender: TObject);
begin
  // Pause auto-close when mouse is over
  FTimer.Enabled := False;
end;

procedure TToastNotification.FormMouseLeave(Sender: TObject);
begin
  // Resume auto-close when mouse leaves
  if not FFadingOut then
    FTimer.Enabled := True;
end;

initialization

finalization
  if Assigned(ActiveToasts) then
    FreeAndNil(ActiveToasts);

end.
