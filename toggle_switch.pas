unit toggle_switch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, LCLType, LCLIntf, StdCtrls,
  IntfGraphics, FPimage, GraphType, Math;

type
  TToggleSwitchSize = (tssCompact, tssNormal);

  { TToggleSwitch }
  TToggleSwitch = class(TCustomControl)
  private
    FChecked: Boolean;
    FCaption: string;
    FOnChange: TNotifyEvent;
    FSize: TToggleSwitchSize;
    FLinkedCheckBox: TCheckBox;
    FUpdatingFromLinked: Boolean;
    procedure SetChecked(AValue: Boolean);
    procedure SetCaption(const AValue: string);
    procedure SetSize(AValue: TToggleSwitchSize);
    procedure LinkedCheckBoxChange(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure DoOnChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LinkToCheckBox(ACheckBox: TCheckBox);
    procedure SyncFromLinked;
    function GetOptimalWidth: Integer;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property Caption: string read FCaption write SetCaption;
    property Size: TToggleSwitchSize read FSize write SetSize default tssCompact;
    property LinkedCheckBox: TCheckBox read FLinkedCheckBox;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Enabled;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Visible;
    property TabOrder;
    property TabStop default True;
    property Font;
    property ParentFont;
    property Color;
    property ParentColor;
  end;

procedure ClearToggleBitmapCache;

implementation

var
  // Cache indexed by [Size (0..1), Checked (0..1), Enabled (0..1)]
  GToggleCache: array[0..1, 0..1, 0..1] of TBitmap;

type
  TRGBASample = record
    R, G, B, A: Double;
  end;

function SampleToggle(ASize: TToggleSwitchSize; AChecked, AEnabled: Boolean;
                      sx, sy: Double): TRGBASample;
var
  TrackW, TrackH: Double;
  Radius, HalfW: Double;
  ThumbRadius, ThumbD: Double;
  ThumbX, ThumbY: Double;
  TrackCenterX, TrackCenterY: Double;
  dx, dy, DistTrack, DistThumb, DistShadow: Double;
  TrackR, TrackG, TrackB: Double;
  BorderR, BorderG, BorderB: Double;
  ThumbR, ThumbG, ThumbB: Double;
begin
  if ASize = tssNormal then
  begin
    TrackW      := 38.0;
    TrackH      := 20.0;
    Radius      := 10.0;
    ThumbD      := 14.0;
    ThumbRadius := 7.0;
  end
  else
  begin
    // Compact: 28 x 16 px
    TrackW      := 28.0;
    TrackH      := 16.0;
    Radius      := 8.0;
    ThumbD      := 10.0;
    ThumbRadius := 5.0;
  end;

  // Track centered inside image bounds with 1px padding
  TrackCenterX := 1.0 + TrackW * 0.5;
  TrackCenterY := 1.0 + TrackH * 0.5;
  HalfW        := (TrackW - 2.0 * Radius) * 0.5; // straight portion half-width

  // Thumb Center
  ThumbY := TrackCenterY;
  if AChecked then
    ThumbX := 1.0 + TrackW - Radius
  else
    ThumbX := 1.0 + Radius;

  // Colors
  if AEnabled then
  begin
    if AChecked then
    begin
      // Modern vibrant green (#2ECC71)
      TrackR := 46.0;  TrackG := 204.0; TrackB := 113.0;
      BorderR := 39.0; BorderG := 174.0; BorderB := 96.0;
      ThumbR := 255.0; ThumbG := 255.0; ThumbB := 255.0; // Pure white
    end
    else
    begin
      // Sleek modern dark slate (#2C3244)
      TrackR := 44.0;  TrackG := 50.0;  TrackB := 68.0;
      BorderR := 58.0; BorderG := 66.0;  BorderB := 88.0;
      ThumbR := 215.0; ThumbG := 220.0; ThumbB := 230.0; // Crisp light silver
    end;
  end
  else
  begin
    if AChecked then
    begin
      TrackR := 32.0;  TrackG := 78.0;  TrackB := 46.0;
      BorderR := 28.0; BorderG := 64.0;  BorderB := 38.0;
      ThumbR := 125.0; ThumbG := 135.0; ThumbB := 130.0;
    end
    else
    begin
      TrackR := 30.0;  TrackG := 34.0;  TrackB := 44.0;
      BorderR := 38.0; BorderG := 42.0;  BorderB := 54.0;
      ThumbR := 80.0;  ThumbG := 85.0;  ThumbB := 98.0;
    end;
  end;

  // 1. Distance to Thumb Circle
  DistThumb := Sqrt(Sqr(sx - ThumbX) + Sqr(sy - ThumbY)) - ThumbRadius;

  // 2. Distance to Thumb Drop Shadow (slightly offset downwards by 0.75px)
  DistShadow := Sqrt(Sqr(sx - ThumbX) + Sqr(sy - (ThumbY + 0.75))) - (ThumbRadius + 0.5);

  // 3. Distance to Track Pill (Stadium)
  dx := Max(Abs(sx - TrackCenterX) - HalfW, 0.0);
  dy := Abs(sy - TrackCenterY);
  DistTrack := Sqrt(Sqr(dx) + Sqr(dy)) - Radius;

  // Evaluation:
  if DistThumb <= 0.0 then
  begin
    // Inside thumb
    Result.R := ThumbR;
    Result.G := ThumbG;
    Result.B := ThumbB;
    Result.A := 1.0;
  end
  else if (DistTrack <= 0.0) then
  begin
    // Inside track
    if (DistShadow <= 0.0) and AEnabled then
    begin
      // Soft drop shadow over track
      Result.R := TrackR * 0.70;
      Result.G := TrackG * 0.70;
      Result.B := TrackB * 0.70;
      Result.A := 1.0;
    end
    else if DistTrack >= -0.9 then
    begin
      // Subtle 1px outer track border
      Result.R := BorderR;
      Result.G := BorderG;
      Result.B := BorderB;
      Result.A := 1.0;
    end
    else
    begin
      Result.R := TrackR;
      Result.G := TrackG;
      Result.B := TrackB;
      Result.A := 1.0;
    end;
  end
  else
  begin
    // Outside track
    Result.R := 0.0;
    Result.G := 0.0;
    Result.B := 0.0;
    Result.A := 0.0;
  end;
end;

function RenderToggleBitmap(ASize: TToggleSwitchSize; AChecked, AEnabled: Boolean): TBitmap;
const
  SAMPLES_PER_AXIS = 4; // 4x4 = 16 subpixel samples per pixel for extreme smoothness
var
  W, H: Integer;
  Bmp: TBitmap;
  IntfImg: TLazIntfImage;
  px, py, si, sj: Integer;
  sx, sy: Double;
  Step: Double;
  Sample: TRGBASample;
  SumR, SumG, SumB, SumA: Double;
  TotalSamples: Double;
  FinalR, FinalG, FinalB, FinalA: Byte;
  C: TFPColor;
begin
  if ASize = tssNormal then
  begin
    W := 40;
    H := 22;
  end
  else
  begin
    W := 30;
    H := 18;
  end;

  Bmp := TBitmap.Create;
  Bmp.SetSize(W, H);
  Bmp.PixelFormat := pf32bit;
  Bmp.Transparent := True;

  IntfImg := TLazIntfImage.Create(W, H, [riqfRGB, riqfAlpha]);
  try
    Step := 1.0 / SAMPLES_PER_AXIS;
    TotalSamples := SAMPLES_PER_AXIS * SAMPLES_PER_AXIS;

    for py := 0 to H - 1 do
    begin
      for px := 0 to W - 1 do
      begin
        SumR := 0.0; SumG := 0.0; SumB := 0.0; SumA := 0.0;

        for sj := 0 to SAMPLES_PER_AXIS - 1 do
        begin
          sy := py + (sj + 0.5) * Step;
          for si := 0 to SAMPLES_PER_AXIS - 1 do
          begin
            sx := px + (si + 0.5) * Step;
            Sample := SampleToggle(ASize, AChecked, AEnabled, sx, sy);
            if Sample.A > 0.0 then
            begin
              SumR := SumR + Sample.R * Sample.A;
              SumG := SumG + Sample.G * Sample.A;
              SumB := SumB + Sample.B * Sample.A;
              SumA := SumA + Sample.A;
            end;
          end;
        end;

        if SumA > 0.0 then
        begin
          FinalA := EnsureRange(Round((SumA / TotalSamples) * 255.0), 0, 255);
          FinalR := EnsureRange(Round(SumR / SumA), 0, 255);
          FinalG := EnsureRange(Round(SumG / SumA), 0, 255);
          FinalB := EnsureRange(Round(SumB / SumA), 0, 255);

          C.Red   := FinalR or (FinalR shl 8);
          C.Green := FinalG or (FinalG shl 8);
          C.Blue  := FinalB or (FinalB shl 8);
          C.Alpha := FinalA or (FinalA shl 8);
        end
        else
        begin
          C.Red   := 0;
          C.Green := 0;
          C.Blue  := 0;
          C.Alpha := 0;
        end;

        IntfImg.Colors[px, py] := C;
      end;
    end;

    Bmp.LoadFromIntfImage(IntfImg);
  finally
    IntfImg.Free;
  end;

  Result := Bmp;
end;

function GetToggleBitmap(ASize: TToggleSwitchSize; AChecked, AEnabled: Boolean): TBitmap;
var
  SIdx, CIdx, EIdx: Integer;
begin
  SIdx := Ord(ASize);
  CIdx := Ord(AChecked);
  EIdx := Ord(AEnabled);

  if GToggleCache[SIdx, CIdx, EIdx] = nil then
    GToggleCache[SIdx, CIdx, EIdx] := RenderToggleBitmap(ASize, AChecked, AEnabled);

  Result := GToggleCache[SIdx, CIdx, EIdx];
end;

procedure ClearToggleBitmapCache;
var
  s, c, e: Integer;
begin
  for s := 0 to 1 do
    for c := 0 to 1 do
      for e := 0 to 1 do
      begin
        if Assigned(GToggleCache[s, c, e]) then
        begin
          GToggleCache[s, c, e].Free;
          GToggleCache[s, c, e] := nil;
        end;
      end;
end;

{ TToggleSwitch }

constructor TToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];
  FChecked     := False;
  FCaption     := '';
  FSize        := tssCompact;
  FLinkedCheckBox := nil;
  FUpdatingFromLinked := False;
  Height       := 20;
  Width        := 120;
  TabStop      := True;
  ParentColor  := True;
  Font.Color   := clWhite;
  Font.Size    := 9;
  Font.Name    := 'Sans';
  Font.Quality := fqAntialiased;
end;

destructor TToggleSwitch.Destroy;
begin
  FLinkedCheckBox := nil;
  inherited Destroy;
end;

procedure TToggleSwitch.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  Invalidate;

  if Assigned(FLinkedCheckBox) and (not FUpdatingFromLinked) then
  begin
    FUpdatingFromLinked := True;
    try
      FLinkedCheckBox.Checked := FChecked;
    finally
      FUpdatingFromLinked := False;
    end;
  end;

  DoOnChange;
end;

procedure TToggleSwitch.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue;
  Invalidate;
end;

procedure TToggleSwitch.SetSize(AValue: TToggleSwitchSize);
begin
  if FSize = AValue then Exit;
  FSize := AValue;
  Invalidate;
end;

procedure TToggleSwitch.DoOnChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TToggleSwitch.LinkedCheckBoxChange(Sender: TObject);
begin
  if FUpdatingFromLinked then Exit;
  if Assigned(FLinkedCheckBox) then
  begin
    FUpdatingFromLinked := True;
    try
      Checked := FLinkedCheckBox.Checked;
      Enabled := FLinkedCheckBox.Enabled;
    finally
      FUpdatingFromLinked := False;
    end;
  end;
end;

procedure TToggleSwitch.LinkToCheckBox(ACheckBox: TCheckBox);
begin
  FLinkedCheckBox := ACheckBox;
  if Assigned(ACheckBox) then
  begin
    ACheckBox.Visible := False;
    FCaption          := ACheckBox.Caption;
    Hint              := ACheckBox.Hint;
    ShowHint          := ACheckBox.ShowHint;
    Enabled           := ACheckBox.Enabled;
    FChecked          := ACheckBox.Checked;
    Width             := GetOptimalWidth;
    Invalidate;
  end;
end;

procedure TToggleSwitch.SyncFromLinked;
begin
  if Assigned(FLinkedCheckBox) then
  begin
    FUpdatingFromLinked := True;
    try
      if FChecked <> FLinkedCheckBox.Checked then
      begin
        FChecked := FLinkedCheckBox.Checked;
        Invalidate;
      end;
      if Enabled <> FLinkedCheckBox.Enabled then
      begin
        Enabled := FLinkedCheckBox.Enabled;
        Invalidate;
      end;
      if FCaption <> FLinkedCheckBox.Caption then
      begin
        FCaption := FLinkedCheckBox.Caption;
        Width    := GetOptimalWidth;
        Invalidate;
      end;
    finally
      FUpdatingFromLinked := False;
    end;
  end;
end;

function TToggleSwitch.GetOptimalWidth: Integer;
var
  TW, PadW: Integer;
begin
  if FSize = tssNormal then
    TW := 40
  else
    TW := 30;

  PadW := 4;
  if FCaption <> '' then
    Result := TW + PadW + Canvas.TextWidth(FCaption) + 6
  else
    Result := TW;
end;

procedure TToggleSwitch.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    SetFocus;
    Checked := not Checked;
  end;
end;

procedure TToggleSwitch.MouseEnter;
begin
  inherited MouseEnter;
  Cursor := crHandPoint;
end;

procedure TToggleSwitch.MouseLeave;
begin
  inherited MouseLeave;
  Cursor := crDefault;
end;

procedure TToggleSwitch.Paint;
var
  Bmp: TBitmap;
  TrackX, TrackY, TextX, TextY: Integer;
begin
  Bmp := GetToggleBitmap(FSize, FChecked, Enabled);

  TrackX := 0;
  TrackY := (ClientHeight - Bmp.Height) div 2;

  Canvas.Draw(TrackX, TrackY, Bmp);

  // Label text to the right of toggle
  if FCaption <> '' then
  begin
    Canvas.Font.Assign(Font);
    if Enabled then
      Canvas.Font.Color := clWhite
    else
      Canvas.Font.Color := RGBToColor(120, 125, 140);

    Canvas.Brush.Style := bsClear;
    TextX := TrackX + Bmp.Width + 4;
    TextY := (ClientHeight - Canvas.TextHeight(FCaption)) div 2;
    Canvas.TextOut(TextX, TextY, FCaption);
  end;
end;

initialization
  FillChar(GToggleCache, SizeOf(GToggleCache), 0);

finalization
  ClearToggleBitmapCache;

end.
