unit benchmarkresultsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math,
  fpjson, jsonparser, systemdetector;

type
  TBenchmarkResultsForm = class(TForm)
    constructor Create(AOwner: TComponent); override;
    procedure FormResize(Sender: TObject);
  private
    FPanelTop: TPanel;
    FShapeScore: TShape;
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
    FShapeComp: TShape;
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

    procedure LoadResults;
    procedure BuildUI;
    procedure RebuildBars;
    function GetCPUThreadCount: Integer;
  public
    procedure RefreshResults;
  end;

  THardwareRef = record
    Name: string;
    Score: Integer;
    IsCurrent: Boolean;
    Specs: string;
  end;

var
  BenchmarkResultsForm: TBenchmarkResultsForm;

const
  COLOR_BG = $302BC2A; // BGR for #2a2b30
  COLOR_CARD = $3C3635; // BGR for #35363c
  COLOR_SCORE_CARD = $443E3D; // BGR for #3d3e44
  COLOR_TRACK = $2A2625; // BGR for #25262a
  COLOR_BAR_DEFAULT = $645046; // BGR for #465064
  COLOR_CYAN = $FFF000; // BGR for #00f0ff
  COLOR_TEXT_GREY = $999999;
  COLOR_TEXT_LIGHT = $CCCCCC;

implementation

constructor TBenchmarkResultsForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildUI;
  Self.OnResize := @FormResize;
  // Initialize defaults
  FCurrentScore := 0;
  FCurrentSpecs := 'CPU: 1T | GPU: Unknown';
  FValueCPUSingle := '0 MIPS';
  FScoreCPUSingle := '(0 pts)';
  FValueCPUMulti := '0 MIPS';
  FScoreCPUMulti := '(0 pts)';
  FValueGPURender := '0.0 FPS';
  FScoreGPURender := '(0 pts)';
  FHistoryCount := 0;
end;

procedure TBenchmarkResultsForm.FormResize(Sender: TObject);
begin
  if Assigned(FShapeScore) and Assigned(FPanelTop) then
    FShapeScore.Left := (FPanelTop.ClientWidth - FShapeScore.Width) div 2;

  if Assigned(FPanelLeft) and Assigned(FPanelClient) then
    FPanelLeft.Width := Round(FPanelClient.ClientWidth * 0.44);

  RebuildBars;
end;

procedure TBenchmarkResultsForm.BuildUI;
var
  CardPanel: TPanel;
  Shape: TShape;
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
  Self.Caption := 'Resultados do Benchmark - PasCube';

  // Hero section panel
  FPanelTop := TPanel.Create(Self);
  FPanelTop.Parent := Self;
  FPanelTop.Align := alTop;
  FPanelTop.Height := 140;
  FPanelTop.BevelOuter := bvNone;
  FPanelTop.Color := COLOR_BG;

  // Score Shape
  FShapeScore := TShape.Create(Self);
  FShapeScore.Parent := FPanelTop;
  FShapeScore.Shape := stRoundRect;
  FShapeScore.Brush.Color := COLOR_SCORE_CARD;
  FShapeScore.Pen.Color := COLOR_SCORE_CARD;
  FShapeScore.Width := 460;
  FShapeScore.Height := 110;
  FShapeScore.Top := 15;

  // Labels inside score card
  FLabelTitle := TLabel.Create(Self);
  FLabelTitle.Parent := FPanelTop;
  FLabelTitle.Caption := 'BENCHMARK COMPLETE!';
  FLabelTitle.Font.Size := 12;
  FLabelTitle.Font.Color := COLOR_TEXT_LIGHT;
  FLabelTitle.Alignment := taCenter;
  FLabelTitle.AutoSize := False;
  FLabelTitle.Width := FShapeScore.Width;
  FLabelTitle.Top := FShapeScore.Top + 18;
  FLabelTitle.AnchorSideLeft.Control := FShapeScore;
  FLabelTitle.AnchorSideLeft.Side := asrLeft;
  FLabelTitle.AnchorSideRight.Control := FShapeScore;
  FLabelTitle.AnchorSideRight.Side := asrRight;
  FLabelTitle.Anchors := [akLeft, akRight];

  FLabelScore := TLabel.Create(Self);
  FLabelScore.Parent := FPanelTop;
  FLabelScore.Caption := '0';
  FLabelScore.Font.Size := 38;
  FLabelScore.Font.Style := [fsBold];
  FLabelScore.Font.Color := clWhite;
  FLabelScore.Alignment := taCenter;
  FLabelScore.AutoSize := False;
  FLabelScore.Width := FShapeScore.Width;
  FLabelScore.Top := FShapeScore.Top + 40;
  FLabelScore.AnchorSideLeft.Control := FShapeScore;
  FLabelScore.AnchorSideLeft.Side := asrLeft;
  FLabelScore.AnchorSideRight.Control := FShapeScore;
  FLabelScore.AnchorSideRight.Side := asrRight;
  FLabelScore.Anchors := [akLeft, akRight];

  // Container panel
  FPanelClient := TPanel.Create(Self);
  FPanelClient.Parent := Self;
  FPanelClient.Align := alClient;
  FPanelClient.BevelOuter := bvNone;
  FPanelClient.Color := COLOR_BG;

  // Panel Left
  FPanelLeft := TPanel.Create(Self);
  FPanelLeft.Parent := FPanelClient;
  FPanelLeft.Align := alLeft;
  FPanelLeft.BevelOuter := bvNone;
  FPanelLeft.Color := COLOR_BG;
  FPanelLeft.Width := 440;

  // Panel Right
  FPanelRight := TPanel.Create(Self);
  FPanelRight.Parent := FPanelClient;
  FPanelRight.Align := alClient;
  FPanelRight.BevelOuter := bvNone;
  FPanelRight.Color := COLOR_BG;

  // 1. CPU Single-Thread Card
  CardPanel := TPanel.Create(Self);
  CardPanel.Parent := FPanelLeft;
  CardPanel.Align := alTop;
  CardPanel.Height := 115;
  CardPanel.BevelOuter := bvNone;
  CardPanel.Color := COLOR_BG;
  CardPanel.BorderSpacing.Bottom := 10;
  CardPanel.BorderSpacing.Left := 20;
  CardPanel.BorderSpacing.Right := 10;
  CardPanel.BorderSpacing.Top := 5;

  Shape := TShape.Create(Self);
  Shape.Parent := CardPanel;
  Shape.Align := alClient;
  Shape.Shape := stRoundRect;
  Shape.Brush.Color := COLOR_CARD;
  Shape.Pen.Color := COLOR_CARD;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := CardPanel;
  TitleLbl.Caption := '⚡ CPU Single-Thread';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValSingleLbl := TLabel.Create(Self);
  FValSingleLbl.Parent := CardPanel;
  FValSingleLbl.Caption := '0 MIPS';
  FValSingleLbl.Font.Size := 20;
  FValSingleLbl.Font.Style := [fsBold];
  FValSingleLbl.Font.Color := clWhite;
  FValSingleLbl.Top := 26;
  FValSingleLbl.Left := 12;

  FScoreSingleLbl := TLabel.Create(Self);
  FScoreSingleLbl.Parent := CardPanel;
  FScoreSingleLbl.Caption := '(0 pts)';
  FScoreSingleLbl.Font.Size := 11;
  FScoreSingleLbl.Font.Color := COLOR_TEXT_GREY;
  FScoreSingleLbl.Top := 35;
  FScoreSingleLbl.Left := 180;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := CardPanel;
  DescLbl.Caption := 'Importante para física básica, lógica do jogo e taxa de FPS mínima.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 65;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 2. CPU Multi-Thread Card
  CardPanel := TPanel.Create(Self);
  CardPanel.Parent := FPanelLeft;
  CardPanel.Align := alTop;
  CardPanel.Height := 115;
  CardPanel.BevelOuter := bvNone;
  CardPanel.Color := COLOR_BG;
  CardPanel.BorderSpacing.Bottom := 10;
  CardPanel.BorderSpacing.Left := 20;
  CardPanel.BorderSpacing.Right := 10;

  Shape := TShape.Create(Self);
  Shape.Parent := CardPanel;
  Shape.Align := alClient;
  Shape.Shape := stRoundRect;
  Shape.Brush.Color := COLOR_CARD;
  Shape.Pen.Color := COLOR_CARD;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := CardPanel;
  TitleLbl.Caption := '⚡ CPU Multi-Thread';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValMultiLbl := TLabel.Create(Self);
  FValMultiLbl.Parent := CardPanel;
  FValMultiLbl.Caption := '0 MIPS';
  FValMultiLbl.Font.Size := 20;
  FValMultiLbl.Font.Style := [fsBold];
  FValMultiLbl.Font.Color := clWhite;
  FValMultiLbl.Top := 26;
  FValMultiLbl.Left := 12;

  FScoreMultiLbl := TLabel.Create(Self);
  FScoreMultiLbl.Parent := CardPanel;
  FScoreMultiLbl.Caption := '(0 pts)';
  FScoreMultiLbl.Font.Size := 11;
  FScoreMultiLbl.Font.Color := COLOR_TEXT_GREY;
  FScoreMultiLbl.Top := 35;
  FScoreMultiLbl.Left := 180;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := CardPanel;
  DescLbl.Caption := 'Importante para streaming de assets em mundo aberto, física avançada e IA complexa.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 65;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 3. GPU Vulkan Render Card
  CardPanel := TPanel.Create(Self);
  CardPanel.Parent := FPanelLeft;
  CardPanel.Align := alTop;
  CardPanel.Height := 115;
  CardPanel.BevelOuter := bvNone;
  CardPanel.Color := COLOR_BG;
  CardPanel.BorderSpacing.Bottom := 10;
  CardPanel.BorderSpacing.Left := 20;
  CardPanel.BorderSpacing.Right := 10;

  Shape := TShape.Create(Self);
  Shape.Parent := CardPanel;
  Shape.Align := alClient;
  Shape.Shape := stRoundRect;
  Shape.Brush.Color := COLOR_CARD;
  Shape.Pen.Color := COLOR_CARD;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := CardPanel;
  TitleLbl.Caption := '⚡ GPU Vulkan Render';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  FValGPULbl := TLabel.Create(Self);
  FValGPULbl.Parent := CardPanel;
  FValGPULbl.Caption := '0.0 FPS';
  FValGPULbl.Font.Size := 20;
  FValGPULbl.Font.Style := [fsBold];
  FValGPULbl.Font.Color := clWhite;
  FValGPULbl.Top := 26;
  FValGPULbl.Left := 12;

  FScoreGPULbl := TLabel.Create(Self);
  FScoreGPULbl.Parent := CardPanel;
  FScoreGPULbl.Caption := '(0 pts)';
  FScoreGPULbl.Font.Size := 11;
  FScoreGPULbl.Font.Color := COLOR_TEXT_GREY;
  FScoreGPULbl.Top := 35;
  FScoreGPULbl.Left := 180;

  DescLbl := TLabel.Create(Self);
  DescLbl.Parent := CardPanel;
  DescLbl.Caption := 'Determina a taxa máxima de quadros (FPS) e a fidelidade visual dos gráficos.';
  DescLbl.Font.Size := 8;
  DescLbl.Font.Color := COLOR_TEXT_GREY;
  DescLbl.WordWrap := True;
  DescLbl.Top := 65;
  DescLbl.Left := 12;
  DescLbl.Width := 380;
  DescLbl.Anchors := [akLeft, akTop, akRight];

  // 4. Test History Card
  CardPanel := TPanel.Create(Self);
  CardPanel.Parent := FPanelLeft;
  CardPanel.Align := alClient;
  CardPanel.BevelOuter := bvNone;
  CardPanel.Color := COLOR_BG;
  CardPanel.BorderSpacing.Bottom := 20;
  CardPanel.BorderSpacing.Left := 20;
  CardPanel.BorderSpacing.Right := 10;

  Shape := TShape.Create(Self);
  Shape.Parent := CardPanel;
  Shape.Align := alClient;
  Shape.Shape := stRoundRect;
  Shape.Brush.Color := COLOR_CARD;
  Shape.Pen.Color := COLOR_CARD;

  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := CardPanel;
  TitleLbl.Caption := '⚡ Histórico de Testes';
  TitleLbl.Font.Size := 10;
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 8;
  TitleLbl.Left := 12;

  // Header
  TitleLbl := TLabel.Create(Self);
  TitleLbl.Parent := CardPanel;
  TitleLbl.Caption := 'Pos   |   Pontuação   |   Data e Hora';
  TitleLbl.Font.Size := 9;
  TitleLbl.Font.Style := [fsBold];
  TitleLbl.Font.Color := COLOR_TEXT_LIGHT;
  TitleLbl.Top := 30;
  TitleLbl.Left := 16;

  for i := 0 to 4 do
  begin
    FHistoryLabels[i] := TLabel.Create(Self);
    FHistoryLabels[i].Parent := CardPanel;
    FHistoryLabels[i].Caption := '';
    FHistoryLabels[i].Font.Size := 9;
    FHistoryLabels[i].Top := 50 + i * 20;
    FHistoryLabels[i].Left := 16;
  end;

  // Build Right Column structures
  FCardComp := TPanel.Create(Self);
  FCardComp.Parent := FPanelRight;
  FCardComp.Align := alClient;
  FCardComp.BevelOuter := bvNone;
  FCardComp.Color := COLOR_BG;
  FCardComp.BorderSpacing.Bottom := 20;
  FCardComp.BorderSpacing.Left := 10;
  FCardComp.BorderSpacing.Right := 20;
  FCardComp.BorderSpacing.Top := 5;

  FShapeComp := TShape.Create(Self);
  FShapeComp.Parent := FCardComp;
  FShapeComp.Align := alClient;
  FShapeComp.Shape := stRoundRect;
  FShapeComp.Brush.Color := COLOR_CARD;
  FShapeComp.Pen.Color := COLOR_CARD;

  FLabelCompTitle := TLabel.Create(Self);
  FLabelCompTitle.Parent := FCardComp;
  FLabelCompTitle.Caption := 'HARDWARE COMPARISON';
  FLabelCompTitle.Font.Size := 11;
  FLabelCompTitle.Font.Style := [fsBold];
  FLabelCompTitle.Font.Color := COLOR_TEXT_LIGHT;
  FLabelCompTitle.Top := 12;
  FLabelCompTitle.Left := 16;

  FPanelBars := TPanel.Create(Self);
  FPanelBars.Parent := FCardComp;
  FPanelBars.Align := alClient;
  FPanelBars.BevelOuter := bvNone;
  FPanelBars.Color := COLOR_CARD;
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
  FilePath := ExtractFilePath(ParamStr(0)) + 'benchmark_results.json';
  if not FileExists(FilePath) then Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(FilePath);
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
            FLabelScore.Caption := Format('%,d', [TotalScore]);

            FCurrentSpecs := 'CPU: ' + IntToStr(GetCPUThreadCount) + 'T | GPU: ' + LatestResultObj.Strings['device'];

            PhasesArray := LatestResultObj.Arrays['phases'];
            if Assigned(PhasesArray) then
            begin
              for i := 0 to PhasesArray.Count - 1 do
              begin
                PhaseName := TJSONObject(PhasesArray.Items[i]).Strings['name'];
                PhaseScore := TJSONObject(PhasesArray.Items[i]).Integers['score'];
                PhaseFPSAvg := TJSONObject(PhasesArray.Items[i]).Floats['fps_avg'];

                if PhaseName = 'CPU Light' then
                begin
                  FValueCPUSingle := Format('%,d MIPS', [Round(PhaseFPSAvg)]);
                  FScoreCPUSingle := Format('(%,d pts)', [PhaseScore]);
                end
                else if PhaseName = 'CPU Heavy' then
                begin
                  FValueCPUMulti := Format('%,d MIPS', [Round(PhaseFPSAvg)]);
                  FScoreCPUMulti := Format('(%,d pts)', [PhaseScore]);
                end
                else if (PhaseName = 'GPU Particles') or (PhaseName = 'Combined') then
                begin
                  // Handle GPU rendering results
                  FValueGPURender := Format('%.1f FPS', [PhaseFPSAvg]);
                  FScoreGPURender := Format('(%,d pts)', [PhaseScore]);
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
  if not Assigned(FPanelBars) then Exit;

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
  HWRefs[3].Name := 'PC Gamer Basico'; HWRefs[3].Score := 2800; HWRefs[3].IsCurrent := false;
  HWRefs[3].Specs := 'CPU: i3 12100F | RAM: 16GB DDR4 | GPU: RX 6600 8GB | OS: Win11';
  HWRefs[4].Name := 'Xbox Series'; HWRefs[4].Score := 3200; HWRefs[4].IsCurrent := false;
  HWRefs[4].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 52CU | OS: Custom OS';
  HWRefs[5].Name := 'PlayStation 5'; HWRefs[5].Score := 4500; HWRefs[5].IsCurrent := false;
  HWRefs[5].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 36CU | OS: Custom OS';
  HWRefs[6].Name := 'PC Gamer Medio'; HWRefs[6].Score := 6500; HWRefs[6].IsCurrent := false;
  HWRefs[6].Specs := 'CPU: R5 7600 | RAM: 32GB DDR5 | GPU: RTX 4060 Ti | OS: Win11';
  HWRefs[7].Name := 'PC Gamer Avancado'; HWRefs[7].Score := 12500; HWRefs[7].IsCurrent := false;
  HWRefs[7].Specs := 'CPU: R7 7800X3D | RAM: 32GB DDR5 | GPU: RTX 4080 Super | OS: Win11';
  HWRefs[8].Name := 'Sistema Atual'; HWRefs[8].Score := FCurrentScore; HWRefs[8].IsCurrent := true;
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

  MaxScore := HWRefs[0].Score;
  if MaxScore = 0 then MaxScore := 1;

  CurY := 0;
  for i := 0 to 8 do
  begin
    RowPanel := TPanel.Create(Self);
    RowPanel.Parent := FPanelBars;
    RowPanel.BevelOuter := bvNone;
    RowPanel.Color := COLOR_CARD;
    RowPanel.Left := 0;
    RowPanel.Width := FPanelBars.ClientWidth;
    
    if HWRefs[i].IsCurrent then
      RowPanel.Height := 72
    else
      RowPanel.Height := 52;
      
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
    ScoreLbl.Caption := Format('%,d pts', [HWRefs[i].Score]);
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

    // Bar Track
    TrackShape := TShape.Create(Self);
    TrackShape.Parent := RowPanel;
    TrackShape.Shape := stRoundRect;
    TrackShape.Brush.Color := COLOR_TRACK;
    TrackShape.Pen.Color := COLOR_TRACK;
    TrackShape.Top := 22;
    TrackShape.Left := 0;
    TrackShape.Height := 16;
    TrackShape.Width := RowPanel.ClientWidth;
    TrackShape.Anchors := [akLeft, akTop, akRight];

    // Bar Fill
    Proportion := HWRefs[i].Score / MaxScore;
    BarW := Round(Proportion * TrackShape.Width);
    if BarW < 4 then BarW := 4;

    FillShape := TShape.Create(Self);
    FillShape.Parent := RowPanel;
    FillShape.Shape := stRoundRect;
    FillShape.Top := 22;
    FillShape.Left := 0;
    FillShape.Height := 16;
    FillShape.Width := BarW;

    if HWRefs[i].IsCurrent then
    begin
      FillShape.Brush.Color := RGBToColor(0, 240, 255);
      FillShape.Pen.Color := clWhite;
      FillShape.Pen.Width := 2;
    end
    else
    begin
      FillShape.Brush.Color := COLOR_BAR_DEFAULT;
      FillShape.Pen.Color := COLOR_BAR_DEFAULT;
    end;

    // Specs under the bar if current system
    if HWRefs[i].IsCurrent then
    begin
      SpecsLbl := TLabel.Create(Self);
      SpecsLbl.Parent := RowPanel;
      SpecsLbl.Caption := HWRefs[i].Specs;
      SpecsLbl.Font.Size := 8;
      SpecsLbl.Font.Color := COLOR_TEXT_LIGHT;
      SpecsLbl.Top := 44;
      SpecsLbl.Left := 4;
    end;
  end;
end;

procedure TBenchmarkResultsForm.RefreshResults;
var
  i: Integer;
begin
  LoadResults;
  
  // Update left column metrics
  FValSingleLbl.Caption := FValueCPUSingle;
  FScoreSingleLbl.Caption := FScoreCPUSingle;
  FScoreSingleLbl.Left := FValSingleLbl.Left + FValSingleLbl.Width + 12;

  FValMultiLbl.Caption := FValueCPUMulti;
  FScoreMultiLbl.Caption := FScoreCPUMulti;
  FScoreMultiLbl.Left := FValMultiLbl.Left + FValMultiLbl.Width + 12;

  FValGPULbl.Caption := FValueGPURender;
  FScoreGPULbl.Caption := FScoreGPURender;
  FScoreGPULbl.Left := FValGPULbl.Left + FValGPULbl.Width + 12;

  // Update history labels
  for i := 0 to 4 do
  begin
    if i < FHistoryCount then
    begin
      FHistoryLabels[i].Caption := Format('%d   |   %,d pts   |   %s', [i+1, FHistoryScores[i], FHistoryTimes[i]]);
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

  RebuildBars;
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
