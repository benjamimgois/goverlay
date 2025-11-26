unit howto;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
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

  //Turbulence animation start
  FStartTick := GetTickCount;
  Timer1.Interval := 50; // 20 fps aprox
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
  BlockSize = 4; // block size in pixels
var
  X, Y, TWidth, THeight: Integer;
  BaseR, BaseG, BaseB: Byte;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  RectRight, RectBottom: Integer;
begin
//Blueish
BaseR := 36;  // 0x24
BaseG := 50;  // 0x32
BaseB := 70;  // 0x46


  TWidth := steamPaintBox.Width;
  THeight := steamPaintBox.Height;

  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  Y := 0;
  while Y < THeight do
  begin
    X := 0;
    while X < TWidth do
    begin
      // Smaller coeeficients in X and Y gets bigger effects
      // Smaller timeelapsed get slower speeds
      OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.015) + TimeElapsed * 0.6);
      OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.45);

      Factor := 0.3 + 0.35 * (OffsetX + 1) + 0.35 * (OffsetY + 1);
      if Factor > 1.0 then Factor := 1.0;
      if Factor < 0.3 then Factor := 0.3;

      R := Round(BaseR * Factor);
      G := Round(BaseG * Factor);
      B := Round(BaseB * Factor);

      // Define block rectangle, taking care not to exceed limits
      RectRight := X + BlockSize - 1;
      if RectRight >= TWidth then
        RectRight := TWidth - 1;

      RectBottom := Y + BlockSize - 1;
      if RectBottom >= THeight then
        RectBottom := THeight - 1;

      steamPaintBox.Canvas.Brush.Color := RGBToColor(R, G, B);
      steamPaintBox.Canvas.FillRect(Rect(X, Y, RectRight + 1, RectBottom + 1));

      Inc(X, BlockSize);
    end;
    Inc(Y, BlockSize);
  end;
end;

procedure ThowtoForm.heroicPaintBoxPaint(Sender: TObject);
  const
  BlockSize = 4; // block size in pixels
var
  X, Y, TWidth, THeight: Integer;
  BaseR, BaseG, BaseB: Byte;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  RectRight, RectBottom: Integer;
begin
//Blueish (same as Steam theme)
BaseR := 36;  // 0x24
BaseG := 50;  // 0x32
BaseB := 70;  // 0x46

  TWidth := heroicPaintBox.Width;
  THeight := heroicPaintBox.Height;

  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  Y := 0;
  while Y < THeight do
  begin
    X := 0;
    while X < TWidth do
    begin
      // Smaller coeeficients in X and Y gets bigger effects
      // Smaller timeelapsed get slower speeds
      OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.015) + TimeElapsed * 0.6);
      OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.45);

      Factor := 0.3 + 0.35 * (OffsetX + 1) + 0.35 * (OffsetY + 1);
      if Factor > 1.0 then Factor := 1.0;
      if Factor < 0.3 then Factor := 0.3;

      R := Round(BaseR * Factor);
      G := Round(BaseG * Factor);
      B := Round(BaseB * Factor);

      // Define block rectangle, taking care not to exceed limits
      RectRight := X + BlockSize - 1;
      if RectRight >= TWidth then
        RectRight := TWidth - 1;

      RectBottom := Y + BlockSize - 1;
      if RectBottom >= THeight then
        RectBottom := THeight - 1;

      heroicPaintBox.Canvas.Brush.Color := RGBToColor(R, G, B);
      heroicPaintBox.Canvas.FillRect(Rect(X, Y, RectRight + 1, RectBottom + 1));

      Inc(X, BlockSize);
    end;
    Inc(Y, BlockSize);
  end;
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

