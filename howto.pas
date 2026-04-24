unit howto;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Buttons;

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
  private
    FStartTick: Cardinal;
    nextButton: TBitBtn;
    previousButton: TBitBtn;

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

end.

