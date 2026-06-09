unit howto;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Buttons, StdCtrls, Process;

type

  { ThowtoForm }

  ThowtoForm = class(TForm)
    nextBitBtn: TBitBtn;
    closehowtoBitBtn: TBitBtn;
    previousBitBtn: TBitBtn;
    steamPaintBox: TPaintBox;
    steamlogoImage: TImage;
    steamImage: TImage;
    howtoPageControl: TPageControl;
    heroic2Image: TImage;
    heroic1Image: TImage;
    heroiclogoImage: TImage;
    heroicPaintBox: TPaintBox;
    steamSheet: TTabSheet;
    heroicSheet: TTabSheet;
    Timer1: TTimer;
    procedure closehowtoBitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure heroicPaintBoxPaint(Sender: TObject);
    procedure nextBitBtnClick(Sender: TObject);
    procedure nextButtonClick(Sender: TObject);
    procedure previousBitBtnClick(Sender: TObject);
    procedure previousButtonClick(Sender: TObject);
    procedure steamPaintBoxPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    FStartTick: Cardinal;
    nextButton: TBitBtn;
    previousButton: TBitBtn;
    FVideoProcess: TProcess;
    FPlayBtn: TSpeedButton;
    FStopBtn: TSpeedButton;
    procedure StartSteamVideo;
    procedure StopVideo;
    procedure SteamSheetShow(Sender: TObject);
    procedure SteamSheetHide(Sender: TObject);
    procedure HeroicSheetShow(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CreateVideoButtons;

  public

  end;

var
  howtoForm: ThowtoForm;

implementation

{$R *.lfm}

{ ThowtoForm }

procedure ThowtoForm.FormCreate(Sender: TObject);
begin
  //Hide tabs
  howtoPageControl.ShowTabs := False;
  howtoPageControl.ActivePageIndex := 0;

  //Set initial page
  howtoPageControl.ActivePage:=steamSheet;

  //Turbulence animation start - Refined for Dynamic Glassmorphism
  FStartTick := GetTickCount;
  Timer1.Interval := 60; // Slower for subtle frosted effect
  Timer1.Enabled := True;
  Timer1.OnTimer := @Timer1Timer;
  steamPaintBox.OnPaint := @steamPaintBoxPaint;
  heroicPaintBox.OnPaint := @heroicPaintBoxPaint;

  // Video tab events
  steamSheet.OnShow := @SteamSheetShow;
  steamSheet.OnHide := @SteamSheetHide;
  heroicSheet.OnShow := @HeroicSheetShow;

  OnClose := @FormClose;

  // Create video play/stop buttons
  CreateVideoButtons;
end;

procedure ThowtoForm.closehowtoBitBtnClick(Sender: TObject);
begin
  howtoform.close;
end;

procedure ThowtoForm.steamPaintBoxPaint(Sender: TObject);
const
  BlockSize = 8;
  BaseR = 18; BaseG = 22; BaseB = 28;
var
  X, Y, TWidth, THeight: Integer;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  RectRight, RectBottom: Integer;
begin
  TWidth := steamPaintBox.Width;
  THeight := steamPaintBox.Height;
  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  for Y := 0 to (THeight div BlockSize) do
  begin
    for X := 0 to (TWidth div BlockSize) do
    begin
      OffsetX := Sin((X * 8 * 0.008) + TimeElapsed * 0.2) + Sin((Y * 8 * 0.01) + TimeElapsed * 0.25);
      OffsetY := Cos((X * 8 * 0.01) - TimeElapsed * 0.15) + Cos((Y * 8 * 0.008) - TimeElapsed * 0.2);
      Factor := 1.0 + 0.15 * (OffsetX + OffsetY) * 0.5;

      R := Round(BaseR * Factor); G := Round(BaseG * Factor); B := Round(BaseB * Factor);
      RectRight := (X + 1) * BlockSize; if RectRight > TWidth then RectRight := TWidth;
      RectBottom := (Y + 1) * BlockSize; if RectBottom > THeight then RectBottom := THeight;

      steamPaintBox.Canvas.Brush.Color := RGBToColor(R, G, B);
      steamPaintBox.Canvas.FillRect(Rect(X * BlockSize, Y * BlockSize, RectRight, RectBottom));
    end;
  end;

  // Glass Details
  steamPaintBox.Canvas.Pen.Color := $282828;
  steamPaintBox.Canvas.Line(0, 0, 0, THeight);
  steamPaintBox.Canvas.Pen.Color := $FFF200;
  steamPaintBox.Canvas.Line(TWidth - 1, 0, TWidth - 1, THeight);
end;

procedure ThowtoForm.heroicPaintBoxPaint(Sender: TObject);
const
  BlockSize = 8;
  BaseR = 18; BaseG = 22; BaseB = 28;
var
  X, Y, TWidth, THeight: Integer;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  RectRight, RectBottom: Integer;
begin
  TWidth := heroicPaintBox.Width;
  THeight := heroicPaintBox.Height;
  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  for Y := 0 to (THeight div BlockSize) do
  begin
    for X := 0 to (TWidth div BlockSize) do
    begin
      OffsetX := Sin((X * 8 * 0.008) + TimeElapsed * 0.2) + Sin((Y * 8 * 0.01) + TimeElapsed * 0.25);
      OffsetY := Cos((X * 8 * 0.01) - TimeElapsed * 0.15) + Cos((Y * 8 * 0.008) - TimeElapsed * 0.2);
      Factor := 1.0 + 0.15 * (OffsetX + OffsetY) * 0.5;

      R := Round(BaseR * Factor); G := Round(BaseG * Factor); B := Round(BaseB * Factor);
      RectRight := (X + 1) * BlockSize; if RectRight > TWidth then RectRight := TWidth;
      RectBottom := (Y + 1) * BlockSize; if RectBottom > THeight then RectBottom := THeight;

      heroicPaintBox.Canvas.Brush.Color := RGBToColor(R, G, B);
      heroicPaintBox.Canvas.FillRect(Rect(X * BlockSize, Y * BlockSize, RectRight, RectBottom));
    end;
  end;

  // Glass Details
  heroicPaintBox.Canvas.Pen.Color := $282828;
  heroicPaintBox.Canvas.Line(0, 0, 0, THeight);
  heroicPaintBox.Canvas.Pen.Color := $FFF200;
  heroicPaintBox.Canvas.Line(TWidth - 1, 0, TWidth - 1, THeight);
end;

procedure ThowtoForm.nextBitBtnClick(Sender: TObject);
begin
  howtoPageControl.ActivePage:=heroicSheet;
end;

procedure ThowtoForm.nextButtonClick(Sender: TObject);
begin
  if howtoPageControl.ActivePageIndex < howtoPageControl.PageCount - 1 then
  begin
    howtoPageControl.ActivePageIndex := howtoPageControl.ActivePageIndex + 1;

    // Update button states
    previousButton.Enabled := True;
    nextButton.Enabled := howtoPageControl.ActivePageIndex < howtoPageControl.PageCount - 1;
  end;
end;

procedure ThowtoForm.previousBitBtnClick(Sender: TObject);
begin
  howtoPageControl.ActivePage:=steamSheet;
end;

procedure ThowtoForm.previousButtonClick(Sender: TObject);
begin
  if howtoPageControl.ActivePageIndex > 0 then
  begin
    howtoPageControl.ActivePageIndex := howtoPageControl.ActivePageIndex - 1;

    // Update button states
    previousButton.Enabled := howtoPageControl.ActivePageIndex > 0;
    nextButton.Enabled := True;
  end;
end;

procedure ThowtoForm.Timer1Timer(Sender: TObject);
begin
  steamPaintBox.Invalidate;
  heroicPaintBox.Invalidate;
end;

procedure ThowtoForm.CreateVideoButtons;
begin
  // Play button on steamSheet
  FPlayBtn := TSpeedButton.Create(steamSheet);
  FPlayBtn.Parent := steamSheet;
  FPlayBtn.Caption := '▶  Watch Tutorial';
  FPlayBtn.Font.Style := [fsBold];
  FPlayBtn.Font.Size := 11;
  FPlayBtn.Width := 160;
  FPlayBtn.Height := 40;
  FPlayBtn.Left := (steamSheet.ClientWidth - FPlayBtn.Width) div 2;
  FPlayBtn.Top := (steamSheet.ClientHeight - FPlayBtn.Height) div 2;
  FPlayBtn.Flat := True;
  FPlayBtn.OnClick := @PlayBtnClick;

  // Stop button (hidden initially)
  FStopBtn := TSpeedButton.Create(steamSheet);
  FStopBtn.Parent := steamSheet;
  FStopBtn.Caption := '✕  Stop Video';
  FStopBtn.Font.Style := [fsBold];
  FStopBtn.Font.Size := 10;
  FStopBtn.Width := 120;
  FStopBtn.Height := 32;
  FStopBtn.Left := steamSheet.ClientWidth - FStopBtn.Width - 20;
  FStopBtn.Top := 20;
  FStopBtn.Flat := True;
  FStopBtn.Visible := False;
  FStopBtn.OnClick := @StopBtnClick;
end;

procedure ThowtoForm.PlayBtnClick(Sender: TObject);
begin
  FPlayBtn.Visible := False;
  FStopBtn.Visible := True;
  StartSteamVideo;
end;

procedure ThowtoForm.StopBtnClick(Sender: TObject);
begin
  StopVideo;
  FStopBtn.Visible := False;
  FPlayBtn.Visible := True;
end;

procedure ThowtoForm.StartSteamVideo;
var
  VideoPath: String;
  WidgetHandle: PtrUInt;
  VideoRect: TRect;
begin
  StopVideo;

  VideoPath := ExtractFilePath(ParamStr(0)) + 'assets/video/bgmod-1.mp4';
  if not FileExists(VideoPath) then Exit;

  WidgetHandle := PtrUInt(Self.Handle);
  if WidgetHandle = 0 then Exit;

  // Calculate video area within the paintbox
  VideoRect := Rect(20, 20, steamPaintBox.Width - 20, steamPaintBox.Height - 20);

  FVideoProcess := TProcess.Create(nil);
  FVideoProcess.Executable := '/usr/bin/mpv';
  FVideoProcess.Parameters.Add('--wid=' + IntToStr(WidgetHandle));
  FVideoProcess.Parameters.Add('--no-border');
  FVideoProcess.Parameters.Add('--loop-file=inf');
  FVideoProcess.Parameters.Add('--mute=yes');
  FVideoProcess.Parameters.Add('--geometry=' + IntToStr(VideoRect.Left) + ':' + IntToStr(VideoRect.Top));
  FVideoProcess.Parameters.Add('--autofit=' + IntToStr(VideoRect.Width) + 'x' + IntToStr(VideoRect.Height));
  FVideoProcess.Parameters.Add(VideoPath);
  FVideoProcess.Options := [poNoConsole];
  FVideoProcess.Execute;
end;

procedure ThowtoForm.StopVideo;
begin
  if Assigned(FVideoProcess) then
  begin
    if FVideoProcess.Running then
      FVideoProcess.Terminate(0);
    FreeAndNil(FVideoProcess);
  end;
end;

procedure ThowtoForm.SteamSheetShow(Sender: TObject);
begin
  // Video does NOT auto-start; user clicks Play button
  FPlayBtn.Visible := True;
  FStopBtn.Visible := False;
end;

procedure ThowtoForm.SteamSheetHide(Sender: TObject);
begin
  StopVideo;
end;

procedure ThowtoForm.HeroicSheetShow(Sender: TObject);
begin
  StopVideo;
end;

procedure ThowtoForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StopVideo;
end;

end.

