unit benchmarkresultsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math,
  fpjson, jsonparser, systemdetector, configmanager;

type
  THardwareRef = record
    Name: string;
    Score: Integer;
    IsCurrent: Boolean;
    Specs: string;
  end;

  TBenchmarkResultsForm = class(TForm)
    constructor Create(AOwner: TComponent); override;
    procedure FormResize(Sender: TObject);
  private
    FPanelTop: TPanel;
    FShapeScore: TPaintBox;
    FLabelTitle: TLabel;
    FLabelScore: TLabel;

    FPanelClient: TPanel;
    FPanelLeft: TPanel;
    FPanelRight: TPanel;

    // Left column cards
    FCardSingle: TPanel;
    FCardMulti: TPanel;
    FCardGPU: TPanel;
    FCardHistory: TPanel;

    // Labels on CPU Single-Thread Card
    FValSingleLbl: TLabel;
    FScoreSingleLbl: TLabel;
    
    // Labels on CPU Multi-Thread Card
    FValMultiLbl: TLabel;
    FScoreMultiLbl: TLabel;
    
    // Labels on GPU Card
    FValGPULbl: TLabel;
    FScoreGPULbl: TLabel;

    // History Labels
    FHistoryLabels: array[0..4] of TLabel;

    // Right column comparison card
    FCardComp: TPanel;
    FLabelCompTitle: TLabel;
    FPanelBars: TPanel;

    FCurrentScore: Integer;
    FCurrentSpecs: string;
    FValueCPUSingle, FScoreCPUSingle: string;
    FValueCPUMulti, FScoreCPUMulti: string;
    FValueGPURender, FScoreGPURender: string;

    FHistoryCount: Integer;
    FHistoryScores: array[0..4] of Integer;
    FHistoryTimes: array[0..4] of string;

    FHWRefs: array[0..8] of THardwareRef;

    procedure LoadResults;
    procedure BuildUI;
    procedure RebuildBars;
    function GetCPUThreadCount: Integer;

    procedure FormPaint(Sender: TObject);
    procedure CardPaint(Sender: TObject);
    procedure RowPanelPaint(Sender: TObject);
  public
    procedure RefreshResults;
  end;

var
  BenchmarkResultsForm: TBenchmarkResultsForm;

const
  COLOR_BG = $302B2A; // BGR for #2a2b30
  COLOR_CARD = $3C3635; // BGR for #35363c
  COLOR_SCORE_CARD = $443E3D; // BGR for #3d3e44
  COLOR_TRACK = $2A2625; // BGR for #25262a
  COLOR_BAR_DEFAULT = $645046; // BGR for #465064
  COLOR_CYAN = $FFF000; // BGR for #00f0ff
  COLOR_TEXT_GREY = $999999;
  COLOR_TEXT_LIGHT = $CCCCCC;

implementation

procedure DbgLog(const Msg: string);
var
  LogPath: string;
  F: TextFile;
begin
  WriteLn(StdErr, '[ResultsForm] ' + Msg);
  try
    LogPath := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'benchmark_debug.log';
    TConfigManager.EnsureDirectoryExists(TConfigManager.GetGoverlayFolder);
    AssignFile(F, LogPath);
    if FileExists(LogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, '[ResultsForm] ' + Msg);
    CloseFile(F);
  except
    // ignore
  end;
end;

function FormatScore(Val: Integer): string;
var
  S: string;
  i: Integer;
begin
  S := IntToStr(Val);
  Result := '';
  for i := 1 to Length(S) do
  begin
    Result := Result + S[i];
    if ((Length(S) - i) mod 3 = 0) and (i < Length(S)) then
      Result := Result + '.';
  end;
end;

function BlendColors(Color1, Color2: TColor; Alpha: Byte): TColor;
var
  R1, G1, B1, R2, G2, B2: Byte;
begin
  R1 := Red(Color1); G1 := Green(Color1); B1 := Blue(Color1);
  R2 := Red(Color2); G2 := Green(Color2); B2 := Blue(Color2);
  Result := RGBToColor(
    (R1 * Alpha + R2 * (255 - Alpha)) div 255,
    (G1 * Alpha + G2 * (255 - Alpha)) div 255,
    (B1 * Alpha + B2 * (255 - Alpha)) div 255
  );
end;

function GetBgColorAtPoint(Pt: TPoint; FormWidth, FormHeight: Integer): TColor;
var
  CX, CY: Integer;
  MaxDist, Dist, Ratio: Double;
  R_c, G_c, B_c, R_e, G_e, B_e: Byte;
begin
  CX := FormWidth div 2;
  CY := FormHeight div 2;
  MaxDist := Sqrt(CX * CX + CY * CY);
  if MaxDist <= 0 then MaxDist := 1;
  
  Dist := Sqrt(Sqr(Pt.X - CX) + Sqr(Pt.Y - CY));
  Ratio := Dist / MaxDist;
  if Ratio < 0 then Ratio := 0;
  if Ratio > 1 then Ratio := 1;
  
  // Center is #3a3b3f (58, 59, 63)
  // Edge is #202124 (32, 33, 36)
  R_c := 58; G_c := 59; B_c := 63;
  R_e := 32; G_e := 33; B_e := 36;
  
  Result := RGBToColor(
    Round(R_c + (R_e - R_c) * Ratio),
    Round(G_c + (G_e - G_c) * Ratio),
    Round(B_c + (B_e - B_c) * Ratio)
  );
end;

procedure DrawRadialGradient(ACanvas: TCanvas; Rect: TRect; ColorCenter, ColorEdge: TColor);
var
  CX, CY, i, Steps: Integer;
  R_c, G_c, B_c, R_e, G_e, B_e: Byte;
  Ratio: Double;
  Rx, Ry: Integer;
begin
  CX := (Rect.Left + Rect.Right) div 2;
  CY := (Rect.Top + Rect.Bottom) div 2;
  
  R_c := Red(ColorCenter); G_c := Green(ColorCenter); B_c := Blue(ColorCenter);
  R_e := Red(ColorEdge); G_e := Green(ColorEdge); B_e := Blue(ColorEdge);
  
  // Fill background with edge color first
  ACanvas.Brush.Color := ColorEdge;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Style := psClear;
  ACanvas.FillRect(Rect);
  
  Steps := 120;
  for i := Steps downto 1 do
  begin
    Ratio := i / Steps; // 1.0 down to 0.0
    Rx := Round((CX - Rect.Left) * Ratio);
    Ry := Round((CY - Rect.Top) * Ratio);
    
    ACanvas.Brush.Color := RGBToColor(
      Round(R_e + (R_c - R_e) * Ratio),
      Round(G_e + (G_c - G_e) * Ratio),
      Round(B_e + (B_c - B_e) * Ratio)
    );
    ACanvas.Ellipse(CX - Rx, CY - Ry, CX + Rx, CY + Ry);
  end;
end;

procedure DrawPillGradientHorizontal(ACanvas: TCanvas; Rect: TRect; ColorStart, ColorEnd: TColor);
var
  X, Y1, Y2: Integer;
  R_start, G_start, B_start: Byte;
  R_end, G_end, B_end: Byte;
  Ratio: Double;
  W, H, R, CX1, CX2: Integer;
  CY, DX, DY: Integer;
begin
  R_start := Red(ColorStart); G_start := Green(ColorStart); B_start := Blue(ColorStart);
  R_end := Red(ColorEnd); G_end := Green(ColorEnd); B_end := Blue(ColorEnd);
  
  W := Rect.Right - Rect.Left;
  H := Rect.Bottom - Rect.Top;
  if (W <= 0) or (H <= 0) then Exit;
  
  R := H div 2;
  CY := Rect.Top + R;
  CX1 := Rect.Left + R;
  CX2 := Rect.Right - R;
  
  for X := Rect.Left to Rect.Right do
  begin
    if X < CX1 then
    begin
      DX := CX1 - X;
      if DX > R then DX := R;
      DY := Round(Sqrt(R * R - DX * DX));
      Y1 := CY - DY;
      Y2 := CY + DY;
    end
    else if X > CX2 then
    begin
      DX := X - CX2;
      if DX > R then DX := R;
      DY := Round(Sqrt(R * R - DX * DX));
      Y1 := CY - DY;
      Y2 := CY + DY;
    end
    else
    begin
      Y1 := Rect.Top;
      Y2 := Rect.Bottom;
    end;
    
    Ratio := (X - Rect.Left) / W;
    ACanvas.Pen.Color := RGBToColor(
      Round(R_start + (R_end - R_start) * Ratio),
      Round(G_start + (G_end - G_start) * Ratio),
      Round(B_start + (B_end - B_start) * Ratio)
    );
    ACanvas.Line(X, Y1, X, Y2);
  end;
end;

procedure TBenchmarkResultsForm.FormPaint(Sender: TObject);
begin
  DrawRadialGradient(Self.Canvas, Self.ClientRect, RGBToColor(58, 59, 63), RGBToColor(32, 33, 36));
end;

procedure TBenchmarkResultsForm.CardPaint(Sender: TObject);
var
  Ctrl: TControl;
  TargetCanvas: TCanvas;
  Pt: TPoint;
  Rect: TRect;
  BgColor, CardBgColor, BorderCol: TColor;
  MidPt: TPoint;
begin
  if not (Sender is TControl) then Exit;
  Ctrl := TControl(Sender);
  if Ctrl is TPanel then
    TargetCanvas := TPanel(Ctrl).Canvas
  else if Ctrl is TPaintBox then
    TargetCanvas := TPaintBox(Ctrl).Canvas
  else
    Exit;
    
  Pt := Ctrl.ClientToParent(Point(0, 0), Self);
  Rect := Ctrl.ClientRect;
  
  MidPt := Point(Pt.X + Ctrl.Width div 2, Pt.Y + Ctrl.Height div 2);
  BgColor := GetBgColorAtPoint(MidPt, Self.ClientWidth, Self.ClientHeight);
  
  // Blend with #1e1f22 (30, 31, 34) at 55% opacity (140)
  CardBgColor := BlendColors(RGBToColor(30, 31, 34), BgColor, 140);
  
  // Border: #ffffff (255, 255, 255) with 15% opacity (40) on top of CardBgColor
  BorderCol := BlendColors(RGBToColor(255, 255, 255), CardBgColor, 40);
  
  // Draw rounded rect background
  TargetCanvas.Brush.Color := CardBgColor;
  TargetCanvas.Brush.Style := bsSolid;
  TargetCanvas.Pen.Style := psClear;
  TargetCanvas.RoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, 16, 16);
  
  // Draw border
  TargetCanvas.Brush.Style := bsClear;
  TargetCanvas.Pen.Color := BorderCol;
  TargetCanvas.Pen.Width := 1;
  TargetCanvas.RoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, 16, 16);
end;

procedure TBenchmarkResultsForm.RowPanelPaint(Sender: TObject);
var
  P: TPanel;
  Idx: Integer;
  Ref: THardwareRef;
  TrackRect, FillRect: TRect;
  BarH, BarY: Integer;
  Proportion: Double;
  FillW: Integer;
  MaxScore: Integer;
  ColorStart, ColorEnd: TColor;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  Idx := P.Tag;
  Ref := FHWRefs[Idx];
  
  MaxScore := FHWRefs[0].Score;
  if MaxScore = 0 then MaxScore := 1;
  
  if Ref.IsCurrent then
  begin
    BarH := 18;
    BarY := 26;
  end
  else
  begin
    BarH := 14;
    BarY := 26;
  end;
  
  TrackRect := Rect(0, BarY, P.ClientWidth, BarY + BarH);
  
  // Draw track background
  DrawPillGradientHorizontal(P.Canvas, TrackRect, COLOR_TRACK, COLOR_TRACK);
  
  // Draw fill bar
  Proportion := Ref.Score / MaxScore;
  FillW := Round(Proportion * TrackRect.Width);
  if FillW < BarH then FillW := BarH;
  
  FillRect := Rect(0, BarY, FillW, BarY + BarH);
  
  if Ref.IsCurrent then
  begin
    ColorStart := RGBToColor(37, 99, 235); // #2563eb
    ColorEnd := RGBToColor(0, 240, 255);   // #00f0ff
    DrawPillGradientHorizontal(P.Canvas, FillRect, ColorStart, ColorEnd);
    
    // Draw neon outline glow
    P.Canvas.Brush.Style := bsClear;
    P.Canvas.Pen.Color := RGBToColor(122, 230, 255);
    P.Canvas.Pen.Width := 1;
    P.Canvas.Ellipse(FillRect.Left, FillRect.Top, FillRect.Left + BarH, FillRect.Bottom);
    P.Canvas.Ellipse(FillRect.Right - BarH, FillRect.Top, FillRect.Right, FillRect.Bottom);
    P.Canvas.Line(FillRect.Left + BarH div 2, FillRect.Top, FillRect.Right - BarH div 2, FillRect.Top);
    P.Canvas.Line(FillRect.Left + BarH div 2, FillRect.Bottom - 1, FillRect.Right - BarH div 2, FillRect.Bottom - 1);
  end
  else
  begin
    ColorStart := RGBToColor(58, 65, 80);  // #3a4150
    ColorEnd := RGBToColor(79, 88, 108);   // #4f586c
    DrawPillGradientHorizontal(P.Canvas, FillRect, ColorStart, ColorEnd);
  end;
end;

constructor TBenchmarkResultsForm.Create(AOwner: TComponent);
begin
  DbgLog('Create constructor start.');
  inherited CreateNew(AOwner);
  DbgLog('CreateNew called. Building UI...');
  BuildUI;
  DbgLog('UI Built. Setting OnResize...');
  Self.OnResize := @FormResize;
  Self.OnPaint := @FormPaint;
  // Initialize defaults
  FCurrentScore := 0;
  FCurrentSpecs := 'CPU: 1T | GPU: Unknown';
  FValueCPUSingle := '0 MIPS';
  FScoreCPUSingle := '(0 points)';
  FValueCPUMulti := '0 MIPS';
  FScoreCPUMulti := '(0 points)';
  FValueGPURender := '0.0 FPS';
  FScoreGPURender := '(0 points)';
  FHistoryCount := 0;
  DbgLog('Create constructor end.');
end;

procedure TBenchmarkResultsForm.FormResize(Sender: TObject);
begin
  if Assigned(FShapeScore) and Assigned(FPanelTop) then
  begin
    FShapeScore.Left := (FPanelTop.ClientWidth - FShapeScore.Width) div 2;
    if Assigned(FLabelTitle) then
    begin
      FLabelTitle.AdjustSize;
      FLabelTitle.Left := FShapeScore.Left + (FShapeScore.Width - FLabelTitle.Width) div 2;
    end;
    if Assigned(FLabelScore) then
    begin
      FLabelScore.AdjustSize;
      FLabelScore.Left := FShapeScore.Left + (FShapeScore.Width - FLabelScore.Width) div 2;
    end;
  end;

  if Assigned(FPanelLeft) and Assigned(FPanelClient) then
    FPanelLeft.Width := Round(FPanelClient.ClientWidth * 0.44);

  RebuildBars;
end;

procedure TBenchmarkResultsForm.BuildUI;
var
  TitleLbl, DescLbl: TLabel;
  i: Integer;
begin
  // Set up form properties
  Self.Color := COLOR_BG;
  Self.Font.Name := 'DejaVu Sans';
  Self.Font.Color := clWhite;
  Self.Width := 1024;
  Self.Height := 768;
  Self.Position := poScreenCenter;
  Self.Caption := 'Benchmark Results - PasCube';

  // Hero section panel
  FPanelTop := TPanel.Create(Self);
  FPanelTop.Parent := Self;
  FPanelTop.Align := alTop;
  FPanelTop.Height := 140;
  FPanelTop.BevelOuter := bvNone;
  FPanelTop.BevelInner := bvNone;
  FPanelTop.ParentBackground := True;

  // Score PaintBox (replacing Shape)
  FShapeScore := TPaintBox.Create(Self);
  FShapeScore.Parent := FPanelTop;
  FShapeScore.Width := 460;
  FShapeScore.Height := 110;
  FShapeScore.Top := 15;
  FShapeScore.OnPaint := @CardPaint;

  // Labels inside score card
  FLabelTitle := TLabel.Create(Self);
  FLabelTitle.Parent := FPanelTop;
  FLabelTitle.Caption := 'BENCHMARK COMPLETE!';
  FLabelTitle.Font.Size := 12;
  FLabelTitle.Font.Color := COLOR_TEXT_LIGHT;
  FLabelTitle.Transparent := True;
  FLabelTitle.AutoSize := True;
  FLabelTitle.Top := FShapeScore.Top + 18;
  FLabelTitle.BringToFront;

  FLabelScore := TLabel.Create(Self);
  FLabelScore.Parent := FPanelTop;
  FLabelScore.Caption := '0';
  FLabelScore.Font.Size := 38;
  FLabelScore.Font.Style := [fsBold];
  FLabelScore.Font.Color := RGBToColor(59, 130, 246); // Electric Blue #3b82f6
  FLabelScore.Transparent := True;
  FLabelScore.AutoSize := True;
  FLabelScore.Top := FShapeScore.Top + 42;
  FLabelScore.BringToFront;

  // Container panel
  FPanelClient := TPanel.Create(Self);
  FPanelClient.Parent := Self;
  FPanelClient.Align := alClient;
  FPanelClient.BevelOuter := bvNone;
  FPanelClient.BevelInner := bvNone;
  FPanelClient.ParentBackground := True;

  // Panel Left
  FPanelLeft := TPanel.Create(Self);
  FPanelLeft.Parent := FPanelClient;
  FPanelLeft.Align := alLeft;
  FPanelLeft.BevelOuter := bvNone;
  FPanelLeft.BevelInner := bvNone;
  FPanelLeft.ParentBackground := True;
  FPanelLeft.Width := 440;

  // Panel Right
  FPanelRight := TPanel.Create(Self);
  FPanelRight.Parent := FPanelClient;
  FPanelRight.Align := alClient;
  FPanelRight.BevelOuter := bvNone;
  FPanelRight.BevelInner := bvNone;
  FPanelRight.ParentBackground := True;

  // 1. CPU Single-Thread Card
  FCardSingle := TPanel.Create(Self);
  FCardSingle.Parent := FPanelLeft;
  FCardSingle.AnchorSideTop.Control := FPanelLeft;
  FCardSingle.AnchorSideTop.Side := asrTop;
  FCardSingle.AnchorSideLeft.Control := FPanelLeft;
  FCardSingle.AnchorSideLeft.Side := asrLeft;
  FCardSingle.AnchorSideRight.Control := FPanelLeft;
  FCardSingle.AnchorSideRight.Side := asrRight;
  FCardSingle.Anchors := [akTop, akLeft, akRight];
  FCardSingle.Height := 135;
  FCardSingle.BevelOuter := bvNone;
  FCardSingle.BevelInner := bvNone;
  FCardSingle.ParentBackground := True;
  FCardSingle.ParentColor := True;
  FCardSingle.OnPaint := @CardPaint;
  FCardSingle.BorderSpacing.Bottom := 10;
  FCardSingle.BorderSpacing.Left := 20;
  FCardSingle.BorderSpacing.Right := 10;
  FCardSingle.BorderSpacing.Top := 5;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := FCardSingle;
  TitleLbl.Caption := '⚡ CPU Single-Thread';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := RGBToColor(96, 165, 250); // Soft Tech Blue #60a5fa
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValSingleLbl := TLabel.Create(Self);
  FValSingleLbl.Parent := FCardSingle;
  FValSingleLbl.Caption := '0 MIPS';
  FValSingleLbl.Font.Size := 20;
  FValSingleLbl.Font.Style := [fsBold];
  FValSingleLbl.Font.Color := clWhite;
  FValSingleLbl.Top := 26;
  FValSingleLbl.Left := 12;

  FScoreSingleLbl := TLabel.Create(Self);
  FScoreSingleLbl.Parent := FCardSingle;
  FScoreSingleLbl.Caption := '(0 points)';
  FScoreSingleLbl.Font.Size := 11;
  FScoreSingleLbl.Font.Color := COLOR_TEXT_LIGHT;
  FScoreSingleLbl.Top := 56;
  FScoreSingleLbl.Left := 12;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := FCardSingle;
  DescLbl.Caption := 'Important for basic physics, game logic, and minimum FPS rate.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 80;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 2. CPU Multi-Thread Card
  FCardMulti := TPanel.Create(Self);
  FCardMulti.Parent := FPanelLeft;
  FCardMulti.AnchorSideTop.Control := FCardSingle;
  FCardMulti.AnchorSideTop.Side := asrBottom;
  FCardMulti.AnchorSideLeft.Control := FPanelLeft;
  FCardMulti.AnchorSideLeft.Side := asrLeft;
  FCardMulti.AnchorSideRight.Control := FPanelLeft;
  FCardMulti.AnchorSideRight.Side := asrRight;
  FCardMulti.Anchors := [akTop, akLeft, akRight];
  FCardMulti.Height := 135;
  FCardMulti.BevelOuter := bvNone;
  FCardMulti.BevelInner := bvNone;
  FCardMulti.ParentBackground := True;
  FCardMulti.ParentColor := True;
  FCardMulti.OnPaint := @CardPaint;
  FCardMulti.BorderSpacing.Bottom := 10;
  FCardMulti.BorderSpacing.Left := 20;
  FCardMulti.BorderSpacing.Right := 10;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := FCardMulti;
  TitleLbl.Caption := '⚡ CPU Multi-Thread';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := RGBToColor(96, 165, 250); // Soft Tech Blue #60a5fa
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValMultiLbl := TLabel.Create(Self);
  FValMultiLbl.Parent := FCardMulti;
  FValMultiLbl.Caption := '0 MIPS';
  FValMultiLbl.Font.Size := 20;
  FValMultiLbl.Font.Style := [fsBold];
  FValMultiLbl.Font.Color := clWhite;
  FValMultiLbl.Top := 26;
  FValMultiLbl.Left := 12;

  FScoreMultiLbl := TLabel.Create(Self);
  FScoreMultiLbl.Parent := FCardMulti;
  FScoreMultiLbl.Caption := '(0 points)';
  FScoreMultiLbl.Font.Size := 11;
  FScoreMultiLbl.Font.Color := COLOR_TEXT_LIGHT;
  FScoreMultiLbl.Top := 56;
  FScoreMultiLbl.Left := 12;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := FCardMulti;
  DescLbl.Caption := 'Important for open-world asset streaming, advanced physics, and complex AI.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 80;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 3. GPU Vulkan Render Card
  FCardGPU := TPanel.Create(Self);
  FCardGPU.Parent := FPanelLeft;
  FCardGPU.AnchorSideTop.Control := FCardMulti;
  FCardGPU.AnchorSideTop.Side := asrBottom;
  FCardGPU.AnchorSideLeft.Control := FPanelLeft;
  FCardGPU.AnchorSideLeft.Side := asrLeft;
  FCardGPU.AnchorSideRight.Control := FPanelLeft;
  FCardGPU.AnchorSideRight.Side := asrRight;
  FCardGPU.Anchors := [akTop, akLeft, akRight];
  FCardGPU.Height := 135;
  FCardGPU.BevelOuter := bvNone;
  FCardGPU.BevelInner := bvNone;
  FCardGPU.ParentBackground := True;
  FCardGPU.ParentColor := True;
  FCardGPU.OnPaint := @CardPaint;
  FCardGPU.BorderSpacing.Bottom := 10;
  FCardGPU.BorderSpacing.Left := 20;
  FCardGPU.BorderSpacing.Right := 10;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := FCardGPU;
  TitleLbl.Caption := '⚡ GPU Vulkan Render';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := RGBToColor(96, 165, 250); // Soft Tech Blue #60a5fa
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValGPULbl := TLabel.Create(Self);
  FValGPULbl.Parent := FCardGPU;
  FValGPULbl.Caption := '0.0 FPS';
  FValGPULbl.Font.Size := 20;
  FValGPULbl.Font.Style := [fsBold];
  FValGPULbl.Font.Color := clWhite;
  FValGPULbl.Top := 26;
  FValGPULbl.Left := 12;

  FScoreGPULbl := TLabel.Create(Self);
  FScoreGPULbl.Parent := FCardGPU;
  FScoreGPULbl.Caption := '(0 points)';
  FScoreGPULbl.Font.Size := 11;
  FScoreGPULbl.Font.Color := COLOR_TEXT_LIGHT;
  FScoreGPULbl.Top := 56;
  FScoreGPULbl.Left := 12;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := FCardGPU;
  DescLbl.Caption := 'Determines the maximum frame rate (FPS) and graphical fidelity.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 80;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 4. Test History Card
  FCardHistory := TPanel.Create(Self);
  FCardHistory.Parent := FPanelLeft;
  FCardHistory.AnchorSideTop.Control := FCardGPU;
  FCardHistory.AnchorSideTop.Side := asrBottom;
  FCardHistory.AnchorSideBottom.Control := FPanelLeft;
  FCardHistory.AnchorSideBottom.Side := asrBottom;
  FCardHistory.AnchorSideLeft.Control := FPanelLeft;
  FCardHistory.AnchorSideLeft.Side := asrLeft;
  FCardHistory.AnchorSideRight.Control := FPanelLeft;
  FCardHistory.AnchorSideRight.Side := asrRight;
  FCardHistory.Anchors := [akTop, akBottom, akLeft, akRight];
  FCardHistory.BevelOuter := bvNone;
  FCardHistory.BevelInner := bvNone;
  FCardHistory.ParentBackground := True;
  FCardHistory.ParentColor := True;
  FCardHistory.OnPaint := @CardPaint;
  FCardHistory.BorderSpacing.Bottom := 20;
  FCardHistory.BorderSpacing.Left := 20;
  FCardHistory.BorderSpacing.Right := 10;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := FCardHistory;
  TitleLbl.Caption := '⚡ Test History';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := RGBToColor(96, 165, 250); // Soft Tech Blue #60a5fa
  TitleLbl.Top := 8;
  TitleLbl.Left := 24;

  // Header
  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := FCardHistory;
  TitleLbl.Caption := 'Pos   |   Score   |   Date & Time';
  TitleLbl.Font.Size := 9;
  TitleLbl.Font.Style := [fsBold];
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 30;
  TitleLbl.Left := 24;

  for i := 0 to 4 do
  begin
    FHistoryLabels[i] := TLabel.Create(Self);
    FHistoryLabels[i].Parent := FCardHistory;
    FHistoryLabels[i].Caption := '';
    FHistoryLabels[i].Font.Size := 9;
    FHistoryLabels[i].Top := 50 + i * 20;
    FHistoryLabels[i].Left := 24;
  end;

  // Build Right Column structures
  FCardComp := TPanel.Create(Self);
  FCardComp.Parent := FPanelRight;
  FCardComp.Align := alClient;
  FCardComp.BevelOuter := bvNone;
  FCardComp.BevelInner := bvNone;
  FCardComp.ParentBackground := True;
  FCardComp.ParentColor := True;
  FCardComp.OnPaint := @CardPaint;
  FCardComp.BorderSpacing.Bottom := 20;
  FCardComp.BorderSpacing.Left := 10;
  FCardComp.BorderSpacing.Right := 20;
  FCardComp.BorderSpacing.Top := 5;

  FLabelCompTitle := TLabel.Create(Self);
  FLabelCompTitle.Parent := FCardComp;
  FLabelCompTitle.Caption := 'HARDWARE COMPARISON';
  FLabelCompTitle.Font.Size := 11;
  FLabelCompTitle.Font.Style := [fsBold];
  FLabelCompTitle.Font.Color := RGBToColor(96, 165, 250); // Soft Tech Blue #60a5fa
  FLabelCompTitle.Top := 12;
  FLabelCompTitle.Left := 16;

  FPanelBars := TPanel.Create(Self);
  FPanelBars.Parent := FCardComp;
  FPanelBars.Align := alClient;
  FPanelBars.BevelOuter := bvNone;
  FPanelBars.BevelInner := bvNone;
  FPanelBars.ParentBackground := True;
  FPanelBars.BorderSpacing.Top := 36;
  FPanelBars.BorderSpacing.Left := 16;
  FPanelBars.BorderSpacing.Right := 16;
  FPanelBars.BorderSpacing.Bottom := 16;
end;

procedure TBenchmarkResultsForm.LoadResults;
var
  FilePath: string;
  SL: TStringList;
  Parser: TJSONParser;
  JSONDoc: TJSONData;
  HistoryArray: TJSONArray;
  LatestResultObj: TJSONObject;
  PhasesArray: TJSONArray;
  TotalScore: Integer;
  i: Integer;
  PhaseName: string;
  PhaseScore: Integer;
  PhaseFPSAvg: Double;
begin
  try
    FilePath := ExtractFilePath(ParamStr(0)) + 'benchmark_results.json';
    DbgLog('LoadResults: FilePath = ' + FilePath);
    if not FileExists(FilePath) then
    begin
      DbgLog('LoadResults: File does not exist: ' + FilePath);
      Exit;
    end;

    DbgLog('LoadResults: File exists, loading...');
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FilePath);
      DbgLog('LoadResults: File loaded (' + IntToStr(SL.Count) + ' lines). Parsing...');
      Parser := TJSONParser.Create(SL.Text);
      try
        JSONDoc := Parser.Parse;
        try
          if JSONDoc is TJSONObject then
          begin
            HistoryArray := TJSONObject(JSONDoc).Arrays['history'];
            if Assigned(HistoryArray) and (HistoryArray.Count > 0) then
            begin
              FHistoryCount := Min(HistoryArray.Count, 5);
              for i := 0 to FHistoryCount - 1 do
              begin
                FHistoryScores[i] := TJSONObject(HistoryArray.Items[i]).Integers['total_score'];
                FHistoryTimes[i] := StringReplace(TJSONObject(HistoryArray.Items[i]).Strings['timestamp'], 'T', ' ', [rfReplaceAll]);
              end;

              LatestResultObj := TJSONObject(HistoryArray.Items[0]);
              TotalScore := LatestResultObj.Integers['total_score'];
              FCurrentScore := TotalScore;
              FLabelScore.Caption := FormatScore(TotalScore);

              FCurrentSpecs := 'CPU: ' + IntToStr(GetCPUThreadCount) + 'T | GPU: ' + LatestResultObj.Strings['device'];

              PhasesArray := LatestResultObj.Arrays['phases'];
              if Assigned(PhasesArray) then
              begin
                for i := 0 to PhasesArray.Count - 1 do
                begin
                  PhaseName := TJSONObject(PhasesArray.Items[i]).Strings['name'];
                  PhaseScore := TJSONObject(PhasesArray.Items[i]).Integers['score'];
                  PhaseFPSAvg := TJSONObject(PhasesArray.Items[i]).Floats['fps_avg'];

                  if (PhaseName = 'CPU Single-Thread') or (PhaseName = 'CPU Light') then
                  begin
                    FValueCPUSingle := FormatScore(Round(PhaseFPSAvg)) + ' MIPS';
                    FScoreCPUSingle := '(' + FormatScore(PhaseScore) + ' points)';
                  end
                  else if (Pos('CPU Multi-Thread', PhaseName) = 1) or (PhaseName = 'CPU Heavy') then
                  begin
                    FValueCPUMulti := FormatScore(Round(PhaseFPSAvg)) + ' MIPS';
                    FScoreCPUMulti := '(' + FormatScore(PhaseScore) + ' points)';
                  end
                  else if (PhaseName = 'GPU Vulkan Render') or (PhaseName = 'GPU Particles') or (PhaseName = 'Combined') then
                  begin
                    FValueGPURender := FormatFloat('0.0', PhaseFPSAvg) + ' FPS';
                    FScoreGPURender := '(' + FormatScore(PhaseScore) + ' points)';
                  end;
                end;
              end;
            end;
          end;
        finally
          JSONDoc.Free;
        end;
      finally
        Parser.Free;
      end;
    finally
      SL.Free;
    end;
    DbgLog('LoadResults complete.');
  except
    on E: Exception do
      DbgLog('LoadResults Exception: ' + E.Message);
  end;
end;

procedure TBenchmarkResultsForm.RebuildBars;
var
  HWRefs: array[0..8] of THardwareRef;
  TempHW: THardwareRef;
  i, j: Integer;
  MaxScore: Integer;
  RowPanel: TPanel;
  NameLbl, ScoreLbl, SpecsLbl: TLabel;
  TrackShape, FillShape: TShape;
  Proportion: Double;
  BarW: Integer;
  ControlChild: TControl;
  CurY: Integer;
begin
  DbgLog('RebuildBars start.');
  if not Assigned(FPanelBars) then
  begin
    DbgLog('RebuildBars: FPanelBars is nil!');
    Exit;
  end;

  // Clear existing controls
  while FPanelBars.ControlCount > 0 do
  begin
    ControlChild := FPanelBars.Controls[0];
    ControlChild.Free;
  end;

  HWRefs[0].Name := 'Nintendo Switch'; HWRefs[0].Score := 400; HWRefs[0].IsCurrent := false;
  HWRefs[0].Specs := 'CPU: Tegra X1 4C | RAM: 4GB LPDDR4 | GPU: Maxwell 256 | OS: Horizon';
  HWRefs[1].Name := 'Steam Deck'; HWRefs[1].Score := 1300; HWRefs[1].IsCurrent := false;
  HWRefs[1].Specs := 'CPU: Zen 2 4C/8T | RAM: 16GB LPDDR5 | GPU: RDNA2 8CU | OS: SteamOS';
  HWRefs[2].Name := 'ROG Ally X'; HWRefs[2].Score := 2100; HWRefs[2].IsCurrent := false;
  HWRefs[2].Specs := 'CPU: Z1 Extreme | RAM: 24GB LPDDR5X | GPU: RDNA3 12CU | OS: Win11';
  HWRefs[3].Name := 'Entry Gamer PC'; HWRefs[3].Score := 2800; HWRefs[3].IsCurrent := false;
  HWRefs[3].Specs := 'CPU: i3 12100F | RAM: 16GB DDR4 | GPU: RX 6600 8GB | OS: Win11';
  HWRefs[4].Name := 'Xbox Series'; HWRefs[4].Score := 3200; HWRefs[4].IsCurrent := false;
  HWRefs[4].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 52CU | OS: Custom OS';
  HWRefs[5].Name := 'PlayStation 5'; HWRefs[5].Score := 4500; HWRefs[5].IsCurrent := false;
  HWRefs[5].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 36CU | OS: Custom OS';
  HWRefs[6].Name := 'Mid-Range Gamer PC'; HWRefs[6].Score := 6500; HWRefs[6].IsCurrent := false;
  HWRefs[6].Specs := 'CPU: R5 7600 | RAM: 32GB DDR5 | GPU: RTX 4060 Ti | OS: Win11';
  HWRefs[7].Name := 'High-End Gamer PC'; HWRefs[7].Score := 12500; HWRefs[7].IsCurrent := false;
  HWRefs[7].Specs := 'CPU: R7 7800X3D | RAM: 32GB DDR5 | GPU: RTX 4080 Super | OS: Win11';
  HWRefs[8].Name := 'Current System'; HWRefs[8].Score := FCurrentScore; HWRefs[8].IsCurrent := true;
  HWRefs[8].Specs := FCurrentSpecs;

  // Sort descending by score
  for i := 0 to 7 do
    for j := i + 1 to 8 do
      if HWRefs[i].Score < HWRefs[j].Score then
      begin
        TempHW := HWRefs[i];
        HWRefs[i] := HWRefs[j];
        HWRefs[j] := TempHW;
      end;

  // Copy sorted refs to class member for paint handlers
  for i := 0 to 8 do
    FHWRefs[i] := HWRefs[i];

  MaxScore := HWRefs[0].Score;
  if MaxScore = 0 then MaxScore := 1;

  CurY := 0;
  for i := 0 to 8 do
  begin
    RowPanel := TPanel.Create(Self);
    RowPanel.Parent := FPanelBars;
    RowPanel.BevelOuter := bvNone;
    RowPanel.BevelInner := bvNone;
    RowPanel.ParentBackground := True;
    RowPanel.Left := 0;
    RowPanel.Width := FPanelBars.ClientWidth;
    RowPanel.Tag := i;
    RowPanel.OnPaint := @RowPanelPaint;
    
    if HWRefs[i].IsCurrent then
      RowPanel.Height := 72
    else
      RowPanel.Height := 54;
      
    RowPanel.Top := CurY;
    CurY := CurY + RowPanel.Height + 6;

    // Name label
    NameLbl := TLabel.Create(Self);
    NameLbl.Parent := RowPanel;
    NameLbl.Caption := HWRefs[i].Name;
    NameLbl.Font.Size := 10;
    if HWRefs[i].IsCurrent then
    begin
      NameLbl.Font.Color := RGBToColor(0, 240, 255);
      NameLbl.Font.Style := [fsBold];
    end
    else
      NameLbl.Font.Color := clWhite;
    NameLbl.Top := 2;
    NameLbl.Left := 0;

    // Score label
    ScoreLbl := TLabel.Create(Self);
    ScoreLbl.Parent := RowPanel;
    ScoreLbl.Caption := FormatScore(HWRefs[i].Score) + ' points';
    ScoreLbl.Font.Size := 10;
    if HWRefs[i].IsCurrent then
    begin
      ScoreLbl.Font.Color := RGBToColor(0, 240, 255);
      ScoreLbl.Font.Style := [fsBold];
    end
    else
      ScoreLbl.Font.Color := COLOR_TEXT_LIGHT;
    ScoreLbl.Top := 2;
    ScoreLbl.Left := RowPanel.ClientWidth - ScoreLbl.Width - 4;
    ScoreLbl.Anchors := [akTop, akRight];

    // Specs under the bar if current system
    if HWRefs[i].IsCurrent then
    begin
      SpecsLbl := TLabel.Create(Self);
      SpecsLbl.Parent := RowPanel;
      SpecsLbl.Caption := HWRefs[i].Specs;
      SpecsLbl.Font.Size := 8;
      SpecsLbl.Font.Color := COLOR_TEXT_LIGHT;
      SpecsLbl.Top := 48;
      SpecsLbl.Left := 4;
    end;
  end;
end;

procedure TBenchmarkResultsForm.RefreshResults;
var
  i: Integer;
begin
  DbgLog('RefreshResults start.');
  try
    LoadResults;
  
  // Update left column metrics
  FValSingleLbl.Caption := FValueCPUSingle;
  FValSingleLbl.AdjustSize;
  FScoreSingleLbl.Caption := FScoreCPUSingle;
  FScoreSingleLbl.AdjustSize;

  FValMultiLbl.Caption := FValueCPUMulti;
  FValMultiLbl.AdjustSize;
  FScoreMultiLbl.Caption := FScoreCPUMulti;
  FScoreMultiLbl.AdjustSize;

  FValGPULbl.Caption := FValueGPURender;
  FValGPULbl.AdjustSize;
  FScoreGPULbl.Caption := FScoreGPURender;
  FScoreGPULbl.AdjustSize;

  // Update history labels
  for i := 0 to 4 do
  begin
    if i < FHistoryCount then
    begin
      FHistoryLabels[i].Caption := Format('%d   |   %s points   |   %s', [i+1, FormatScore(FHistoryScores[i]), FHistoryTimes[i]]);
      if i = 0 then
      begin
        FHistoryLabels[i].Font.Color := RGBToColor(0, 240, 255);
        FHistoryLabels[i].Font.Style := [fsBold];
      end
      else
      begin
        FHistoryLabels[i].Font.Color := clWhite;
        FHistoryLabels[i].Font.Style := [];
      end;
      FHistoryLabels[i].Visible := True;
    end
    else
      FHistoryLabels[i].Visible := False;
  end;

    DbgLog('Calling RebuildBars...');
    RebuildBars;
  except
    on E: Exception do
      DbgLog('RefreshResults Exception: ' + E.Message);
  end;
  DbgLog('RefreshResults end.');
end;

function TBenchmarkResultsForm.GetCPUThreadCount: Integer;
var
  SL: TStringList;
  i: Integer;
begin
  Result := 1;
  if FileExists('/proc/cpuinfo') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/proc/cpuinfo');
      Result := 0;
      for i := 0 to SL.Count - 1 do
        if Pos('processor', SL[i]) = 1 then
          Inc(Result);
    finally
      SL.Free;
    end;
  end;
  if Result = 0 then Result := 1;
end;

end.
