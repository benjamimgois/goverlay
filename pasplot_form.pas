unit pasplot_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, StrUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, CheckLst, Grids, LCLIntf, LCLType, Types,
  Process, themeunit, overlay_utils, configmanager;

type
  TGplotViewMode = (gvmTimeline, gvmSummary, gvmHardware);

  TGplotSystemSpecs = record
    OS: string;
    CPU: string;
    GPU: string;
    RAM: string;
    Kernel: string;
    Driver: string;
    CpuScheduler: string;
  end;

  TGplotSample = record
    ElapsedSec: Double;
    Fps: Double;
    FrametimeMs: Double;
    CpuLoad: Double;
    CpuPower: Double;
    GpuLoad: Double;
    CpuTemp: Double;
    GpuTemp: Double;
    GpuCoreClock: Double;
    GpuMemClock: Double;
    GpuVramUsed: Double;
    GpuPower: Double;
    RamUsed: Double;
    CpuMhz: Double;
  end;

  TGplotRunData = record
    FilePath: string;
    FileName: string;
    DisplayName: string;
    GameName: string;
    Specs: TGplotSystemSpecs;
    Samples: array of TGplotSample;
    SampleCount: Integer;
    DurationSec: Double;
    AvgFps: Double;
    MinFps: Double;
    MaxFps: Double;
    Fps1Low: Double;
    Fps01Low: Double;
    AvgFrametimeMs: Double;
    AvgGpuLoad: Double;
    AvgCpuLoad: Double;
    MaxGpuTemp: Double;
    MaxCpuTemp: Double;
    AvgGpuPower: Double;
    AvgCpuPower: Double;
    MaxVramUsed: Double;
    MaxRamUsed: Double;
  end;

  { TgplotForm }
  TgplotForm = class(TForm)
  private
    FBaseDataDir: string;
    FInitialGame: string;
    FViewMode: TGplotViewMode;
    FDiscoveredFiles: TStringList;
    FLoadedRuns: array of TGplotRunData;
    FHoverX: Integer;
    FHoverY: Integer;
    FHoverActive: Boolean;

    // Top toolbar
    FTopPanel: TPanel;
    FTitleLabel: TLabel;
    FGameLabel: TLabel;
    FGameComboBox: TComboBox;
    FRefreshBtn: TBitBtn;
    FOpenFolderBtn: TBitBtn;
    FDeleteRunBtn: TBitBtn;
    FExportPngBtn: TBitBtn;

    // Main body
    FBodyPanel: TPanel;
    FLeftPanel: TPanel;
    FRunsHeaderPanel: TPanel;
    FRunsTitleLabel: TLabel;
    FSelectAllBtn: TBitBtn;
    FClearSelBtn: TBitBtn;
    FRunCheckListBox: TCheckListBox;

    // Right area
    FRightPanel: TPanel;
    FViewTabsPanel: TPanel;
    FTimelineTabBtn: TBitBtn;
    FSummaryTabBtn: TBitBtn;
    FHardwareTabBtn: TBitBtn;
    FChartContainerPanel: TPanel;
    FChartPaintBox: TPaintBox;

    // Comparative table & specs footer
    FStatsPanel: TPanel;
    FStatsTitleLabel: TLabel;
    FStatsGrid: TStringGrid;
    FBottomBar: TPanel;
    FSpecsLabel: TLabel;

    procedure BuildUI;
    procedure ApplyThemeStyling;
    procedure SetViewMode(AValue: TGplotViewMode);
    procedure UpdateViewTabButtons;

    procedure GameComboChange(Sender: TObject);
    procedure RunCheckListClickCheck(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure ClearSelClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure DeleteRunClick(Sender: TObject);
    procedure ExportPngClick(Sender: TObject);
    procedure ViewTabBtnClick(Sender: TObject);

    procedure ChartPaintBoxPaint(Sender: TObject);
    procedure ChartPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChartPaintBoxMouseLeave(Sender: TObject);

    procedure LoadRunsForSelectedGame;
    procedure ReloadCheckedRunsData;
    procedure UpdateStatsGridAndSpecs;

    procedure DrawTimelineView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
    procedure DrawSummaryView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
    procedure DrawHardwareView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
  public
    constructor Create(AOwner: TComponent; const AInitialGame: string = ''; const ABaseDataDir: string = ''); reintroduce;
    destructor Destroy; override;

    procedure RefreshGamesAndRuns(const APreferredGame: string = '');
    procedure RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
    function ExportToPngFile(const AFilePath: string): Boolean;
    function SelectedRunCount: Integer;
    function GetActiveGameLogFolder: string;

    property GameComboBox: TComboBox read FGameComboBox;
    property RunCheckListBox: TCheckListBox read FRunCheckListBox;
    property TimelineTabBtn: TBitBtn read FTimelineTabBtn;
    property SummaryTabBtn: TBitBtn read FSummaryTabBtn;
    property HardwareTabBtn: TBitBtn read FHardwareTabBtn;
    property RefreshBtn: TBitBtn read FRefreshBtn;
    property OpenFolderBtn: TBitBtn read FOpenFolderBtn;
    property DeleteRunBtn: TBitBtn read FDeleteRunBtn;
    property ExportPngBtn: TBitBtn read FExportPngBtn;
    property ChartPaintBox: TPaintBox read FChartPaintBox;
    property StatsGrid: TStringGrid read FStatsGrid;
    property SpecsLabel: TLabel read FSpecsLabel;
    property ViewMode: TGplotViewMode read FViewMode write SetViewMode;
  end;

  TpasplotForm = TgplotForm;

function IsMangoHudSummaryCsv(const AFileName: string): Boolean;
function ExtractAppFromMangoHudCsvName(const AFileName: string): string;
function OrganizeMangoHudCsvLogs(const ABaseDataDir: string = ''): Integer;
function ParseMangoHudCsvFile(const AFilePath: string; out ARun: TGplotRunData): Boolean;
procedure ShowPasPlotDialog(AOwner: TComponent; const AInitialGame: string = ''; const ABaseDataDir: string = '');
procedure ShowGplotDialog(AOwner: TComponent; const AInitialGame: string = ''; const ABaseDataDir: string = '');

implementation

const
  SERIES_COLORS: array[0..5] of TColor = (
    $00F0BE30, // Cyan / Sky Blue (#30BEF0)
    $003688FF, // Orange (#FF8836)
    $0069E048, // Green (#48E069)
    $00E864D8, // Magenta (#D864E8)
    $0040D8F8, // Yellow (#F8D840)
    $006868FF  // Coral Red (#FF6868)
  );

function SanitizeLogDirName(const AName: string): string;
var
  I: Integer;
begin
  Result := Trim(AName);
  for I := 1 to Length(Result) do
    if Result[I] in ['/', '\', ':', '*', '?', '"', '<', '>', '|'] then
      Result[I] := '_';
end;

function IsDigitChar(C: Char): Boolean; inline;
begin
  Result := (C >= '0') and (C <= '9');
end;

function IsMangoHudSummaryCsv(const AFileName: string): Boolean;
var
  BaseName: string;
begin
  BaseName := LowerCase(ExtractFileName(AFileName));
  Result := EndsStr('_summary.csv', BaseName);
end;

function ExtractAppFromMangoHudCsvName(const AFileName: string): string;
var
  S: string;
  Len: Integer;
begin
  Result := '';
  S := ExtractFileName(AFileName);
  if not EndsText('.csv', S) then
    Exit;
  Delete(S, Length(S) - 3, 4); // strip .csv
  if EndsText('_summary', S) then
    Delete(S, Length(S) - 7, 8); // strip _summary

  Len := Length(S);
  // Pattern: <app>_YYYY-MM-DD_HH-MM-SS (suffix is 20 chars)
  if Len <= 20 then
    Exit;
  if (S[Len - 19] = '_') and
     IsDigitChar(S[Len - 18]) and IsDigitChar(S[Len - 17]) and
     IsDigitChar(S[Len - 16]) and IsDigitChar(S[Len - 15]) and
     (S[Len - 14] = '-') and
     IsDigitChar(S[Len - 13]) and IsDigitChar(S[Len - 12]) and
     (S[Len - 11] = '-') and
     IsDigitChar(S[Len - 10]) and IsDigitChar(S[Len - 9]) and
     (S[Len - 8] = '_') and
     IsDigitChar(S[Len - 7]) and IsDigitChar(S[Len - 6]) and
     (S[Len - 5] = '-') and
     IsDigitChar(S[Len - 4]) and IsDigitChar(S[Len - 3]) and
     (S[Len - 2] = '-') and
     IsDigitChar(S[Len - 1]) and IsDigitChar(S[Len]) then
  begin
    Result := Copy(S, 1, Len - 20);
  end;
end;

function FormatRunTimestampFromFileName(const AFileName: string): string;
var
  S: string;
  Len: Integer;
  DatePart, TimePart: string;
begin
  S := ChangeFileExt(ExtractFileName(AFileName), '');
  if EndsText('_summary', S) then
    Delete(S, Length(S) - 7, 8);
  Len := Length(S);
  if (Len > 20) and (S[Len - 19] = '_') and (S[Len - 8] = '_') then
  begin
    DatePart := Copy(S, Len - 18, 10);
    TimePart := StringReplace(Copy(S, Len - 7, 8), '-', ':', [rfReplaceAll]);
    Result := DatePart + ' ' + TimePart;
  end
  else
    Result := S;
end;

function MoveFileSafe(const ASrc, ADest: string): Boolean;
var
  InStream, OutStream: TFileStream;
begin
  Result := False;
  if not FileExists(ASrc) then Exit;
  if SameFileName(ASrc, ADest) then Exit(True);
  if FileExists(ADest) then
    DeleteFile(ADest);
  if RenameFile(ASrc, ADest) then
    Exit(True);
  try
    InStream := TFileStream.Create(ASrc, fmOpenRead or fmShareDenyNone);
    try
      OutStream := TFileStream.Create(ADest, fmCreate);
      try
        OutStream.CopyFrom(InStream, InStream.Size);
      finally
        OutStream.Free;
      end;
    finally
      InStream.Free;
    end;
    DeleteFile(ASrc);
    Result := True;
  except
    Result := False;
  end;
end;

function OrganizeMangoHudCsvLogs(const ABaseDataDir: string): Integer;
var
  BaseDir, LogsRoot: string;
  ScanDirs: array[0..1] of string;
  D: Integer;
  SR: TSearchRec;
  AppName, TargetDir, SrcFile, DestFile: string;
begin
  Result := 0;
  if Trim(ABaseDataDir) <> '' then
    BaseDir := IncludeTrailingPathDelimiter(ABaseDataDir)
  else
    BaseDir := IncludeTrailingPathDelimiter(GetGOverlayDataDir());

  LogsRoot := BaseDir + 'logs' + PathDelim;
  ScanDirs[0] := BaseDir;
  ScanDirs[1] := LogsRoot;

  for D := Low(ScanDirs) to High(ScanDirs) do
  begin
    if not DirectoryExists(ScanDirs[D]) then
      Continue;
    if FindFirst(ScanDirs[D] + '*.csv', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) <> 0 then
            Continue;
          AppName := ExtractAppFromMangoHudCsvName(SR.Name);
          if AppName = '' then
            Continue;
          TargetDir := LogsRoot + SanitizeLogDirName(AppName) + PathDelim;
          if not DirectoryExists(TargetDir) then
            ForceDirectories(TargetDir);
          SrcFile := ScanDirs[D] + SR.Name;
          DestFile := TargetDir + SR.Name;
          if MoveFileSafe(SrcFile, DestFile) then
            Inc(Result);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;
end;

procedure SplitCsvLine(const ALine: string; var AFields: array of string; out ACount: Integer);
var
  I, StartIdx, MaxFields: Integer;
begin
  ACount := 0;
  MaxFields := Length(AFields);
  if MaxFields = 0 then Exit;
  StartIdx := 1;
  for I := 1 to Length(ALine) do
  begin
    if ALine[I] = ',' then
    begin
      if ACount < MaxFields then
      begin
        AFields[ACount] := Trim(Copy(ALine, StartIdx, I - StartIdx));
        Inc(ACount);
      end;
      StartIdx := I + 1;
    end;
  end;
  if ACount < MaxFields then
  begin
    AFields[ACount] := Trim(Copy(ALine, StartIdx, Length(ALine) - StartIdx + 1));
    Inc(ACount);
  end;
end;

procedure QuickSortDouble(var AValues: array of Double; L, R: Integer);
var
  I, J: Integer;
  Pivot, Tmp: Double;
begin
  I := L;
  J := R;
  Pivot := AValues[(L + R) div 2];
  repeat
    while AValues[I] < Pivot do Inc(I);
    while AValues[J] > Pivot do Dec(J);
    if I <= J then
    begin
      Tmp := AValues[I];
      AValues[I] := AValues[J];
      AValues[J] := Tmp;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSortDouble(AValues, L, J);
  if I < R then QuickSortDouble(AValues, I, R);
end;

function ParseMangoHudCsvFile(const AFilePath: string; out ARun: TGplotRunData): Boolean;
var
  Lines: TStringList;
  Fields: array[0..31] of string;
  FieldCount: Integer;
  HeaderLineIdx, DataStartIdx, I, ColIdx: Integer;
  ColFps, ColFrametime, ColCpuLoad, ColCpuPower, ColGpuLoad: Integer;
  ColCpuTemp, ColGpuTemp, ColGpuCoreClock, ColGpuMemClock: Integer;
  ColGpuVram, ColGpuPower, ColRamUsed, ColCpuMhz, ColElapsed: Integer;
  FS: TFormatSettings;
  RawElapsedValues: array of Double;
  SampleIdx: Integer;
  S: TGplotSample;
  RawElapsed, FirstElapsed, LastElapsed, ElapsedSpan, ElapsedScale, AccumSec: Double;
  SortedFps: array of Double;
  SumFps, SumFt, SumGpuLoad, SumCpuLoad, SumGpuPower, SumCpuPower: Double;
  Low1Count, Low01Count: Integer;
  LowSum: Double;

  function GetDoubleField(AIdx: Integer): Double;
  begin
    if (AIdx >= 0) and (AIdx < FieldCount) and (Fields[AIdx] <> '') then
      Result := StrToFloatDef(Fields[AIdx], 0.0, FS)
    else
      Result := 0.0;
  end;

begin
  Result := False;
  ARun := Default(TGplotRunData);
  if (AFilePath = '') or not FileExists(AFilePath) or IsMangoHudSummaryCsv(AFilePath) then
    Exit;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(AFilePath);
    except
      Exit;
    end;

    if Lines.Count < 2 then
      Exit;

    ARun.FilePath := AFilePath;
    ARun.FileName := ExtractFileName(AFilePath);
    ARun.GameName := ExtractAppFromMangoHudCsvName(ARun.FileName);
    if ARun.GameName = '' then
      ARun.GameName := ExtractFileName(ExcludeTrailingPathDelimiter(ExtractFilePath(AFilePath)));
    ARun.DisplayName := FormatRunTimestampFromFileName(ARun.FileName);

    HeaderLineIdx := -1;
    // Detect standard MangoHud format: Line 0 = os,cpu,gpu..., Line 1 = specs, Line 2 = fps,frametime...
    if StartsText('os,', Trim(Lines[0])) and (Lines.Count >= 3) then
    begin
      SplitCsvLine(Lines[1], Fields, FieldCount);
      if FieldCount > 0 then ARun.Specs.OS := Fields[0];
      if FieldCount > 1 then ARun.Specs.CPU := Fields[1];
      if FieldCount > 2 then ARun.Specs.GPU := Fields[2];
      if FieldCount > 3 then ARun.Specs.RAM := Fields[3];
      if FieldCount > 4 then ARun.Specs.Kernel := Fields[4];
      if FieldCount > 5 then ARun.Specs.Driver := Fields[5];
      if FieldCount > 6 then ARun.Specs.CpuScheduler := Fields[6];
      HeaderLineIdx := 2;
    end
    else
    begin
      for I := 0 to Min(5, Lines.Count - 1) do
        if StartsText('fps,', Trim(Lines[I])) or (Pos(',frametime', LowerCase(Lines[I])) > 0) then
        begin
          HeaderLineIdx := I;
          Break;
        end;
    end;

    if (HeaderLineIdx < 0) or (HeaderLineIdx >= Lines.Count - 1) then
      Exit;

    ColFps := -1; ColFrametime := -1; ColCpuLoad := -1; ColCpuPower := -1;
    ColGpuLoad := -1; ColCpuTemp := -1; ColGpuTemp := -1; ColGpuCoreClock := -1;
    ColGpuMemClock := -1; ColGpuVram := -1; ColGpuPower := -1; ColRamUsed := -1;
    ColCpuMhz := -1; ColElapsed := -1;

    SplitCsvLine(LowerCase(Lines[HeaderLineIdx]), Fields, FieldCount);
    for ColIdx := 0 to FieldCount - 1 do
    begin
      if Fields[ColIdx] = 'fps' then ColFps := ColIdx
      else if Fields[ColIdx] = 'frametime' then ColFrametime := ColIdx
      else if Fields[ColIdx] = 'cpu_load' then ColCpuLoad := ColIdx
      else if Fields[ColIdx] = 'cpu_power' then ColCpuPower := ColIdx
      else if Fields[ColIdx] = 'gpu_load' then ColGpuLoad := ColIdx
      else if Fields[ColIdx] = 'cpu_temp' then ColCpuTemp := ColIdx
      else if Fields[ColIdx] = 'gpu_temp' then ColGpuTemp := ColIdx
      else if Fields[ColIdx] = 'gpu_core_clock' then ColGpuCoreClock := ColIdx
      else if Fields[ColIdx] = 'gpu_mem_clock' then ColGpuMemClock := ColIdx
      else if Fields[ColIdx] = 'gpu_vram_used' then ColGpuVram := ColIdx
      else if Fields[ColIdx] = 'gpu_power' then ColGpuPower := ColIdx
      else if Fields[ColIdx] = 'ram_used' then ColRamUsed := ColIdx
      else if Fields[ColIdx] = 'cpu_mhz' then ColCpuMhz := ColIdx
      else if Fields[ColIdx] = 'elapsed' then ColElapsed := ColIdx;
    end;

    if ColFps < 0 then
      Exit;

    DataStartIdx := HeaderLineIdx + 1;
    SetLength(ARun.Samples, Lines.Count - DataStartIdx);
    SetLength(RawElapsedValues, Lines.Count - DataStartIdx);
    SampleIdx := 0;

    for I := DataStartIdx to Lines.Count - 1 do
    begin
      if Trim(Lines[I]) = '' then Continue;
      SplitCsvLine(Lines[I], Fields, FieldCount);
      if FieldCount <= ColFps then Continue;

      S := Default(TGplotSample);
      S.Fps := GetDoubleField(ColFps);
      S.FrametimeMs := GetDoubleField(ColFrametime);
      if (S.Fps <= 0) and (S.FrametimeMs <= 0) then Continue;
      if (S.FrametimeMs <= 0) and (S.Fps > 0) then
        S.FrametimeMs := 1000.0 / S.Fps;

      S.CpuLoad := GetDoubleField(ColCpuLoad);
      S.CpuPower := GetDoubleField(ColCpuPower);
      S.GpuLoad := GetDoubleField(ColGpuLoad);
      S.CpuTemp := GetDoubleField(ColCpuTemp);
      S.GpuTemp := GetDoubleField(ColGpuTemp);
      S.GpuCoreClock := GetDoubleField(ColGpuCoreClock);
      S.GpuMemClock := GetDoubleField(ColGpuMemClock);
      S.GpuVramUsed := GetDoubleField(ColGpuVram);
      S.GpuPower := GetDoubleField(ColGpuPower);
      S.RamUsed := GetDoubleField(ColRamUsed);
      S.CpuMhz := GetDoubleField(ColCpuMhz);
      RawElapsed := GetDoubleField(ColElapsed);

      ARun.Samples[SampleIdx] := S;
      RawElapsedValues[SampleIdx] := RawElapsed;
      Inc(SampleIdx);
    end;

    SetLength(ARun.Samples, SampleIdx);
    ARun.SampleCount := SampleIdx;
    if SampleIdx = 0 then
      Exit;

    // Normalize elapsed time to seconds
    FirstElapsed := RawElapsedValues[0];
    LastElapsed := RawElapsedValues[SampleIdx - 1];
    ElapsedSpan := LastElapsed - FirstElapsed;

    if (ColElapsed >= 0) and (ElapsedSpan > 0) then
    begin
      // MangoHud writes elapsed in nanoseconds (~1e9 per second)
      if ElapsedSpan > 10000000.0 then
        ElapsedScale := 1.0 / 1000000000.0
      else if ElapsedSpan > 10000.0 then
        ElapsedScale := 1.0 / 1000000.0
      else
        ElapsedScale := 1.0;

      for I := 0 to SampleIdx - 1 do
        ARun.Samples[I].ElapsedSec := Max(0.0, (RawElapsedValues[I] - FirstElapsed) * ElapsedScale);
    end
    else
    begin
      AccumSec := 0.0;
      for I := 0 to SampleIdx - 1 do
      begin
        ARun.Samples[I].ElapsedSec := AccumSec;
        AccumSec := AccumSec + (ARun.Samples[I].FrametimeMs / 1000.0);
      end;
    end;

    ARun.DurationSec := ARun.Samples[SampleIdx - 1].ElapsedSec;
    if (ARun.DurationSec <= 0) and (SampleIdx > 1) then
      ARun.DurationSec := SampleIdx * 0.1;

    // Compute summary statistics and percentiles
    SetLength(SortedFps, SampleIdx);
    SumFps := 0; SumFt := 0; SumGpuLoad := 0; SumCpuLoad := 0;
    SumGpuPower := 0; SumCpuPower := 0;
    ARun.MinFps := ARun.Samples[0].Fps;
    ARun.MaxFps := ARun.Samples[0].Fps;

    for I := 0 to SampleIdx - 1 do
    begin
      S := ARun.Samples[I];
      SortedFps[I] := S.Fps;
      SumFps := SumFps + S.Fps;
      SumFt := SumFt + S.FrametimeMs;
      SumGpuLoad := SumGpuLoad + S.GpuLoad;
      SumCpuLoad := SumCpuLoad + S.CpuLoad;
      SumGpuPower := SumGpuPower + S.GpuPower;
      SumCpuPower := SumCpuPower + S.CpuPower;

      if S.Fps < ARun.MinFps then ARun.MinFps := S.Fps;
      if S.Fps > ARun.MaxFps then ARun.MaxFps := S.Fps;
      if S.GpuTemp > ARun.MaxGpuTemp then ARun.MaxGpuTemp := S.GpuTemp;
      if S.CpuTemp > ARun.MaxCpuTemp then ARun.MaxCpuTemp := S.CpuTemp;
      if S.GpuVramUsed > ARun.MaxVramUsed then ARun.MaxVramUsed := S.GpuVramUsed;
      if S.RamUsed > ARun.MaxRamUsed then ARun.MaxRamUsed := S.RamUsed;
    end;

    ARun.AvgFps := SumFps / SampleIdx;
    ARun.AvgFrametimeMs := SumFt / SampleIdx;
    ARun.AvgGpuLoad := SumGpuLoad / SampleIdx;
    ARun.AvgCpuLoad := SumCpuLoad / SampleIdx;
    ARun.AvgGpuPower := SumGpuPower / SampleIdx;
    ARun.AvgCpuPower := SumCpuPower / SampleIdx;

    QuickSortDouble(SortedFps, 0, SampleIdx - 1);

    // 1% Low FPS (average of the lowest 1% of samples, at least 1 sample)
    Low1Count := Max(1, Round(SampleIdx * 0.01));
    LowSum := 0;
    for I := 0 to Low1Count - 1 do
      LowSum := LowSum + SortedFps[I];
    ARun.Fps1Low := LowSum / Low1Count;

    // 0.1% Low FPS (average of the lowest 0.1% of samples, at least 1 sample)
    Low01Count := Max(1, Round(SampleIdx * 0.001));
    LowSum := 0;
    for I := 0 to Low01Count - 1 do
      LowSum := LowSum + SortedFps[I];
    ARun.Fps01Low := LowSum / Low01Count;

    Result := True;
  finally
    Lines.Free;
  end;
end;

procedure ShowPasPlotDialog(AOwner: TComponent; const AInitialGame: string; const ABaseDataDir: string);
var
  Dlg: TgplotForm;
begin
  Dlg := TgplotForm.Create(AOwner, AInitialGame, ABaseDataDir);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure ShowGplotDialog(AOwner: TComponent; const AInitialGame: string; const ABaseDataDir: string);
begin
  ShowPasPlotDialog(AOwner, AInitialGame, ABaseDataDir);
end;

{ TgplotForm }

constructor TgplotForm.Create(AOwner: TComponent; const AInitialGame: string; const ABaseDataDir: string);
begin
  inherited CreateNew(AOwner, 1);
  if Trim(ABaseDataDir) <> '' then
    FBaseDataDir := IncludeTrailingPathDelimiter(ABaseDataDir)
  else
    FBaseDataDir := IncludeTrailingPathDelimiter(GetGOverlayDataDir());
  FInitialGame := Trim(AInitialGame);
  FViewMode := gvmTimeline;
  FHoverActive := False;
  FDiscoveredFiles := TStringList.Create;

  Caption := 'PasPlot - MangoHud Benchmark Analyzer';
  Width := 1080;
  Height := 720;
  Constraints.MinWidth := 860;
  Constraints.MinHeight := 560;
  Position := poScreenCenter;

  BuildUI;
  ApplyThemeStyling;
  RefreshGamesAndRuns(FInitialGame);
end;

destructor TgplotForm.Destroy;
begin
  FreeAndNil(FDiscoveredFiles);
  inherited Destroy;
end;

procedure TgplotForm.BuildUI;
begin
  // Top Toolbar
  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 52;
  FTopPanel.BevelOuter := bvNone;

  FTitleLabel := TLabel.Create(FTopPanel);
  FTitleLabel.Parent := FTopPanel;
  FTitleLabel.Left := 14;
  FTitleLabel.Top := 15;
  FTitleLabel.Caption := 'PasPlot';
  FTitleLabel.Font.Size := 13;
  FTitleLabel.Font.Style := [fsBold];

  FGameLabel := TLabel.Create(FTopPanel);
  FGameLabel.Parent := FTopPanel;
  FGameLabel.Left := 95;
  FGameLabel.Top := 17;
  FGameLabel.Caption := 'Game:';
  FGameLabel.Font.Style := [fsBold];

  FGameComboBox := TComboBox.Create(FTopPanel);
  FGameComboBox.Parent := FTopPanel;
  FGameComboBox.Left := 150;
  FGameComboBox.Top := 12;
  FGameComboBox.Width := 260;
  FGameComboBox.Style := csDropDownList;
  FGameComboBox.OnChange := @GameComboChange;

  FRefreshBtn := TBitBtn.Create(FTopPanel);
  FRefreshBtn.Parent := FTopPanel;
  FRefreshBtn.SetBounds(422, 11, 100, 30);
  FRefreshBtn.Caption := 'Refresh';
  FRefreshBtn.Cursor := crHandPoint;
  FRefreshBtn.OnClick := @RefreshClick;

  FOpenFolderBtn := TBitBtn.Create(FTopPanel);
  FOpenFolderBtn.Parent := FTopPanel;
  FOpenFolderBtn.SetBounds(530, 11, 120, 30);
  FOpenFolderBtn.Caption := 'Open Folder';
  FOpenFolderBtn.Cursor := crHandPoint;
  FOpenFolderBtn.OnClick := @OpenFolderClick;

  FDeleteRunBtn := TBitBtn.Create(FTopPanel);
  FDeleteRunBtn.Parent := FTopPanel;
  FDeleteRunBtn.SetBounds(658, 11, 130, 30);
  FDeleteRunBtn.Caption := 'Delete Run';
  FDeleteRunBtn.Cursor := crHandPoint;
  FDeleteRunBtn.OnClick := @DeleteRunClick;

  FExportPngBtn := TBitBtn.Create(FTopPanel);
  FExportPngBtn.Parent := FTopPanel;
  FExportPngBtn.SetBounds(796, 11, 120, 30);
  FExportPngBtn.Caption := 'Export PNG';
  FExportPngBtn.Cursor := crHandPoint;
  FExportPngBtn.OnClick := @ExportPngClick;

  // Bottom Status Bar (System Specs)
  FBottomBar := TPanel.Create(Self);
  FBottomBar.Parent := Self;
  FBottomBar.Align := alBottom;
  FBottomBar.Height := 30;
  FBottomBar.BevelOuter := bvNone;

  FSpecsLabel := TLabel.Create(FBottomBar);
  FSpecsLabel.Parent := FBottomBar;
  FSpecsLabel.Left := 12;
  FSpecsLabel.Top := 7;
  FSpecsLabel.Caption := 'System Specs: Select a benchmark run to inspect telemetry.';

  // Main Body
  FBodyPanel := TPanel.Create(Self);
  FBodyPanel.Parent := Self;
  FBodyPanel.Align := alClient;
  FBodyPanel.BevelOuter := bvNone;

  // Left Panel (Run Selector)
  FLeftPanel := TPanel.Create(FBodyPanel);
  FLeftPanel.Parent := FBodyPanel;
  FLeftPanel.Align := alLeft;
  FLeftPanel.Width := 285;
  FLeftPanel.BevelOuter := bvNone;
  FLeftPanel.BorderSpacing.Around := 6;

  FRunsHeaderPanel := TPanel.Create(FLeftPanel);
  FRunsHeaderPanel.Parent := FLeftPanel;
  FRunsHeaderPanel.Align := alTop;
  FRunsHeaderPanel.Height := 62;
  FRunsHeaderPanel.BevelOuter := bvNone;

  FRunsTitleLabel := TLabel.Create(FRunsHeaderPanel);
  FRunsTitleLabel.Parent := FRunsHeaderPanel;
  FRunsTitleLabel.Left := 8;
  FRunsTitleLabel.Top := 6;
  FRunsTitleLabel.Caption := 'Benchmark Runs (check to compare)';
  FRunsTitleLabel.Font.Style := [fsBold];

  FSelectAllBtn := TBitBtn.Create(FRunsHeaderPanel);
  FSelectAllBtn.Parent := FRunsHeaderPanel;
  FSelectAllBtn.SetBounds(8, 28, 125, 26);
  FSelectAllBtn.Caption := 'Select All';
  FSelectAllBtn.Cursor := crHandPoint;
  FSelectAllBtn.OnClick := @SelectAllClick;

  FClearSelBtn := TBitBtn.Create(FRunsHeaderPanel);
  FClearSelBtn.Parent := FRunsHeaderPanel;
  FClearSelBtn.SetBounds(142, 28, 125, 26);
  FClearSelBtn.Caption := 'Clear';
  FClearSelBtn.Cursor := crHandPoint;
  FClearSelBtn.OnClick := @ClearSelClick;

  FRunCheckListBox := TCheckListBox.Create(FLeftPanel);
  FRunCheckListBox.Parent := FLeftPanel;
  FRunCheckListBox.Align := alClient;
  FRunCheckListBox.BorderSpacing.Around := 4;
  FRunCheckListBox.OnClickCheck := @RunCheckListClickCheck;

  // Right Area (Charts + Comparative Table)
  FRightPanel := TPanel.Create(FBodyPanel);
  FRightPanel.Parent := FBodyPanel;
  FRightPanel.Align := alClient;
  FRightPanel.BevelOuter := bvNone;
  FRightPanel.BorderSpacing.Around := 6;

  FViewTabsPanel := TPanel.Create(FRightPanel);
  FViewTabsPanel.Parent := FRightPanel;
  FViewTabsPanel.Align := alTop;
  FViewTabsPanel.Height := 38;
  FViewTabsPanel.BevelOuter := bvNone;

  FTimelineTabBtn := TBitBtn.Create(FViewTabsPanel);
  FTimelineTabBtn.Parent := FViewTabsPanel;
  FTimelineTabBtn.SetBounds(4, 4, 210, 30);
  FTimelineTabBtn.Caption := 'FPS && Frametime Timeline';
  FTimelineTabBtn.Tag := Ord(gvmTimeline);
  FTimelineTabBtn.Cursor := crHandPoint;
  FTimelineTabBtn.OnClick := @ViewTabBtnClick;

  FSummaryTabBtn := TBitBtn.Create(FViewTabsPanel);
  FSummaryTabBtn.Parent := FViewTabsPanel;
  FSummaryTabBtn.SetBounds(222, 4, 190, 30);
  FSummaryTabBtn.Caption := 'Summary Comparison';
  FSummaryTabBtn.Tag := Ord(gvmSummary);
  FSummaryTabBtn.Cursor := crHandPoint;
  FSummaryTabBtn.OnClick := @ViewTabBtnClick;

  FHardwareTabBtn := TBitBtn.Create(FViewTabsPanel);
  FHardwareTabBtn.Parent := FViewTabsPanel;
  FHardwareTabBtn.SetBounds(420, 4, 190, 30);
  FHardwareTabBtn.Caption := 'Hardware Telemetry';
  FHardwareTabBtn.Tag := Ord(gvmHardware);
  FHardwareTabBtn.Cursor := crHandPoint;
  FHardwareTabBtn.OnClick := @ViewTabBtnClick;

  // Bottom Comparative Statistics Table
  FStatsPanel := TPanel.Create(FRightPanel);
  FStatsPanel.Parent := FRightPanel;
  FStatsPanel.Align := alBottom;
  FStatsPanel.Height := 165;
  FStatsPanel.BevelOuter := bvNone;

  FStatsTitleLabel := TLabel.Create(FStatsPanel);
  FStatsTitleLabel.Parent := FStatsPanel;
  FStatsTitleLabel.Align := alTop;
  FStatsTitleLabel.BorderSpacing.Around := 4;
  FStatsTitleLabel.Caption := 'Comparative Statistics';
  FStatsTitleLabel.Font.Style := [fsBold];

  FStatsGrid := TStringGrid.Create(FStatsPanel);
  FStatsGrid.Parent := FStatsPanel;
  FStatsGrid.Align := alClient;
  FStatsGrid.ColCount := 9;
  FStatsGrid.RowCount := 2;
  FStatsGrid.FixedCols := 0;
  FStatsGrid.FixedRows := 1;
  FStatsGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goColSizing];
  FStatsGrid.Cells[0, 0] := 'Run Timestamp';
  FStatsGrid.Cells[1, 0] := 'Duration';
  FStatsGrid.Cells[2, 0] := 'Avg FPS';
  FStatsGrid.Cells[3, 0] := '1% Low';
  FStatsGrid.Cells[4, 0] := '0.1% Low';
  FStatsGrid.Cells[5, 0] := 'Min / Max FPS';
  FStatsGrid.Cells[6, 0] := 'Avg Frame';
  FStatsGrid.Cells[7, 0] := 'Δ Avg FPS';
  FStatsGrid.Cells[8, 0] := 'GPU Temp / Power';
  FStatsGrid.ColWidths[0] := 145;
  FStatsGrid.ColWidths[1] := 65;
  FStatsGrid.ColWidths[2] := 75;
  FStatsGrid.ColWidths[3] := 75;
  FStatsGrid.ColWidths[4] := 75;
  FStatsGrid.ColWidths[5] := 115;
  FStatsGrid.ColWidths[6] := 80;
  FStatsGrid.ColWidths[7] := 80;
  FStatsGrid.ColWidths[8] := 125;

  // Interactive Chart Canvas
  FChartContainerPanel := TPanel.Create(FRightPanel);
  FChartContainerPanel.Parent := FRightPanel;
  FChartContainerPanel.Align := alClient;
  FChartContainerPanel.BevelOuter := bvNone;
  FChartContainerPanel.BorderSpacing.Around := 4;

  FChartPaintBox := TPaintBox.Create(FChartContainerPanel);
  FChartPaintBox.Parent := FChartContainerPanel;
  FChartPaintBox.Align := alClient;
  FChartPaintBox.OnPaint := @ChartPaintBoxPaint;
  FChartPaintBox.OnMouseMove := @ChartPaintBoxMouseMove;
  FChartPaintBox.OnMouseLeave := @ChartPaintBoxMouseLeave;
end;

procedure TgplotForm.ApplyThemeStyling;
var
  IsDark: Boolean;
  BgColor, CardColor, TextColor, AccentColor: TColor;
begin
  IsDark := (CurrentTheme <> tmLight);
  if IsDark then
  begin
    BgColor := RGBToColor(22, 26, 40);
    CardColor := RGBToColor(30, 36, 54);
    TextColor := RGBToColor(235, 240, 248);
    AccentColor := RGBToColor(48, 190, 240);
  end
  else
  begin
    BgColor := RGBToColor(242, 244, 248);
    CardColor := RGBToColor(255, 255, 255);
    TextColor := RGBToColor(25, 30, 40);
    AccentColor := RGBToColor(25, 118, 210);
  end;

  Color := BgColor;
  Font.Color := TextColor;

  FTopPanel.Color := CardColor;
  FBodyPanel.Color := BgColor;
  FLeftPanel.Color := CardColor;
  FRunsHeaderPanel.Color := CardColor;
  FRightPanel.Color := BgColor;
  FViewTabsPanel.Color := CardColor;
  FChartContainerPanel.Color := CardColor;
  FStatsPanel.Color := CardColor;
  FBottomBar.Color := CardColor;

  FTitleLabel.Font.Color := AccentColor;
  FGameLabel.Font.Color := TextColor;
  FRunsTitleLabel.Font.Color := TextColor;
  FStatsTitleLabel.Font.Color := TextColor;
  FSpecsLabel.Font.Color := TextColor;

  FGameComboBox.Color := BgColor;
  FGameComboBox.Font.Color := TextColor;
  FRunCheckListBox.Color := BgColor;
  FRunCheckListBox.Font.Color := TextColor;

  FStatsGrid.Color := BgColor;
  FStatsGrid.FixedColor := CardColor;
  FStatsGrid.Font.Color := TextColor;

  UpdateViewTabButtons;
end;

procedure TgplotForm.SetViewMode(AValue: TGplotViewMode);
begin
  if FViewMode = AValue then Exit;
  FViewMode := AValue;
  UpdateViewTabButtons;
  FChartPaintBox.Invalidate;
end;

procedure TgplotForm.UpdateViewTabButtons;
begin
  if Assigned(FTimelineTabBtn) then
  begin
    if FViewMode = gvmTimeline then
      FTimelineTabBtn.Font.Style := [fsBold]
    else
      FTimelineTabBtn.Font.Style := [];
  end;
  if Assigned(FSummaryTabBtn) then
  begin
    if FViewMode = gvmSummary then
      FSummaryTabBtn.Font.Style := [fsBold]
    else
      FSummaryTabBtn.Font.Style := [];
  end;
  if Assigned(FHardwareTabBtn) then
  begin
    if FViewMode = gvmHardware then
      FHardwareTabBtn.Font.Style := [fsBold]
    else
      FHardwareTabBtn.Font.Style := [];
  end;
end;

procedure TgplotForm.RefreshGamesAndRuns(const APreferredGame: string);
var
  LogsRoot: string;
  SR, FileSR: TSearchRec;
  GamesList: TStringList;
  I, TargetIdx: Integer;
  HasCsv: Boolean;
  SubDir: string;
begin
  OrganizeMangoHudCsvLogs(FBaseDataDir);

  LogsRoot := IncludeTrailingPathDelimiter(FBaseDataDir) + 'logs' + PathDelim;
  GamesList := TStringList.Create;
  try
    GamesList.Sorted := True;
    GamesList.Duplicates := dupIgnore;

    if DirectoryExists(LogsRoot) then
    begin
      if FindFirst(LogsRoot + '*', faDirectory, SR) = 0 then
      begin
        try
          repeat
            if ((SR.Attr and faDirectory) <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
            begin
              SubDir := LogsRoot + SR.Name + PathDelim;
              HasCsv := False;
              if FindFirst(SubDir + '*.csv', faAnyFile, FileSR) = 0 then
              begin
                try
                  repeat
                    if ((FileSR.Attr and faDirectory) = 0) and not IsMangoHudSummaryCsv(FileSR.Name) then
                    begin
                      HasCsv := True;
                      Break;
                    end;
                  until FindNext(FileSR) <> 0;
                finally
                  FindClose(FileSR);
                end;
              end;
              if HasCsv then
                GamesList.Add(SR.Name);
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      end;
    end;

    FGameComboBox.Items.BeginUpdate;
    try
      FGameComboBox.Items.Clear;
      for I := 0 to GamesList.Count - 1 do
        FGameComboBox.Items.Add(GamesList[I]);
    finally
      FGameComboBox.Items.EndUpdate;
    end;

    TargetIdx := -1;
    if Trim(APreferredGame) <> '' then
    begin
      for I := 0 to FGameComboBox.Items.Count - 1 do
        if SameText(FGameComboBox.Items[I], SanitizeLogDirName(APreferredGame)) or
           SameText(FGameComboBox.Items[I], APreferredGame) then
        begin
          TargetIdx := I;
          Break;
        end;
    end;

    if (TargetIdx < 0) and (FGameComboBox.Items.Count > 0) then
      TargetIdx := 0;

    FGameComboBox.ItemIndex := TargetIdx;
    LoadRunsForSelectedGame;
  finally
    GamesList.Free;
  end;
end;

function TgplotForm.GetActiveGameLogFolder: string;
var
  LogsRoot: string;
begin
  LogsRoot := IncludeTrailingPathDelimiter(FBaseDataDir) + 'logs' + PathDelim;
  if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
    Result := LogsRoot + FGameComboBox.Items[FGameComboBox.ItemIndex] + PathDelim
  else
    Result := LogsRoot;
end;

procedure TgplotForm.LoadRunsForSelectedGame;
var
  GameLogDir: string;
  SR: TSearchRec;
  FileList: TStringList;
  I: Integer;
  RunData: TGplotRunData;
  ItemCaption: string;
begin
  FDiscoveredFiles.Clear;
  FRunCheckListBox.Items.Clear;
  SetLength(FLoadedRuns, 0);

  if (FGameComboBox.ItemIndex < 0) or (FGameComboBox.ItemIndex >= FGameComboBox.Items.Count) then
  begin
    UpdateStatsGridAndSpecs;
    FChartPaintBox.Invalidate;
    Exit;
  end;

  GameLogDir := GetActiveGameLogFolder;
  FileList := TStringList.Create;
  try
    if DirectoryExists(GameLogDir) and (FindFirst(GameLogDir + '*.csv', faAnyFile, SR) = 0) then
    begin
      try
        repeat
          if ((SR.Attr and faDirectory) = 0) and not IsMangoHudSummaryCsv(SR.Name) then
            FileList.Add(GameLogDir + SR.Name);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;

    FileList.Sort;
    // Reverse order so newest timestamp is at index 0
    for I := FileList.Count - 1 downto 0 do
    begin
      if ParseMangoHudCsvFile(FileList[I], RunData) then
      begin
        FDiscoveredFiles.Add(FileList[I]);
        ItemCaption := Format('%s  (%.0fs • %.0f FPS)', [
          RunData.DisplayName,
          RunData.DurationSec,
          RunData.AvgFps
        ]);
        FRunCheckListBox.Items.Add(ItemCaption);
      end;
    end;

    if FRunCheckListBox.Items.Count > 0 then
    begin
      FRunCheckListBox.Checked[0] := True;
      FRunCheckListBox.ItemIndex := 0;
    end;
  finally
    FileList.Free;
  end;

  ReloadCheckedRunsData;
end;

procedure TgplotForm.ReloadCheckedRunsData;
var
  I, Count: Integer;
  RunData: TGplotRunData;
begin
  SetLength(FLoadedRuns, 0);
  Count := 0;
  for I := 0 to Min(FRunCheckListBox.Items.Count, FDiscoveredFiles.Count) - 1 do
  begin
    if FRunCheckListBox.Checked[I] then
    begin
      if ParseMangoHudCsvFile(FDiscoveredFiles[I], RunData) then
      begin
        SetLength(FLoadedRuns, Count + 1);
        FLoadedRuns[Count] := RunData;
        Inc(Count);
      end;
    end;
  end;

  UpdateStatsGridAndSpecs;
  FChartPaintBox.Invalidate;
end;

procedure TgplotForm.UpdateStatsGridAndSpecs;
var
  I: Integer;
  BaselineFps, DeltaPct: Double;
  DeltaStr: string;
  R: TGplotRunData;
begin
  if Length(FLoadedRuns) = 0 then
  begin
    FStatsGrid.RowCount := 2;
    for I := 0 to FStatsGrid.ColCount - 1 do
      FStatsGrid.Cells[I, 1] := '-';
    FSpecsLabel.Caption := 'System Specs: No benchmark run selected.';
    Exit;
  end;

  FStatsGrid.RowCount := Length(FLoadedRuns) + 1;
  BaselineFps := FLoadedRuns[0].AvgFps;

  for I := 0 to High(FLoadedRuns) do
  begin
    R := FLoadedRuns[I];
    if I = 0 then
      DeltaStr := 'Baseline'
    else if BaselineFps > 0 then
    begin
      DeltaPct := ((R.AvgFps - BaselineFps) / BaselineFps) * 100.0;
      if DeltaPct >= 0 then
        DeltaStr := Format('+%.1f%%', [DeltaPct])
      else
        DeltaStr := Format('%.1f%%', [DeltaPct]);
    end
    else
      DeltaStr := 'N/A';

    FStatsGrid.Cells[0, I + 1] := R.DisplayName;
    FStatsGrid.Cells[1, I + 1] := Format('%.1fs', [R.DurationSec]);
    FStatsGrid.Cells[2, I + 1] := Format('%.1f', [R.AvgFps]);
    FStatsGrid.Cells[3, I + 1] := Format('%.1f', [R.Fps1Low]);
    FStatsGrid.Cells[4, I + 1] := Format('%.1f', [R.Fps01Low]);
    FStatsGrid.Cells[5, I + 1] := Format('%.0f / %.0f', [R.MinFps, R.MaxFps]);
    FStatsGrid.Cells[6, I + 1] := Format('%.2f ms', [R.AvgFrametimeMs]);
    FStatsGrid.Cells[7, I + 1] := DeltaStr;
    FStatsGrid.Cells[8, I + 1] := Format('%.0f°C / %.0fW', [R.MaxGpuTemp, R.AvgGpuPower]);
  end;

  R := FLoadedRuns[0];
  FSpecsLabel.Caption := Format('Specs: %s | %s | OS: %s | Kernel: %s | Scheduler: %s', [
    IfThen(R.Specs.CPU <> '', R.Specs.CPU, 'Unknown CPU'),
    IfThen(R.Specs.GPU <> '', R.Specs.GPU, 'Unknown GPU'),
    IfThen(R.Specs.OS <> '', R.Specs.OS, 'Linux'),
    IfThen(R.Specs.Kernel <> '', R.Specs.Kernel, 'N/A'),
    IfThen(R.Specs.CpuScheduler <> '', R.Specs.CpuScheduler, 'N/A')
  ]);
end;

function TgplotForm.SelectedRunCount: Integer;
begin
  Result := Length(FLoadedRuns);
end;

procedure TgplotForm.GameComboChange(Sender: TObject);
begin
  LoadRunsForSelectedGame;
end;

procedure TgplotForm.RunCheckListClickCheck(Sender: TObject);
begin
  ReloadCheckedRunsData;
end;

procedure TgplotForm.SelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FRunCheckListBox.Items.Count - 1 do
    FRunCheckListBox.Checked[I] := True;
  ReloadCheckedRunsData;
end;

procedure TgplotForm.ClearSelClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FRunCheckListBox.Items.Count - 1 do
    FRunCheckListBox.Checked[I] := False;
  ReloadCheckedRunsData;
end;

procedure TgplotForm.RefreshClick(Sender: TObject);
var
  CurrGame: string;
begin
  CurrGame := '';
  if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
    CurrGame := FGameComboBox.Items[FGameComboBox.ItemIndex];
  RefreshGamesAndRuns(CurrGame);
end;

procedure TgplotForm.OpenFolderClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := GetActiveGameLogFolder;
  if not DirectoryExists(Folder) then
    ForceDirectories(Folder);
  OpenDocument(Folder);
end;

procedure TgplotForm.DeleteRunClick(Sender: TObject);
var
  I: Integer;
  FilePath, SummaryPath, CurrGame: string;
  DeletedAny: Boolean;
begin
  DeletedAny := False;
  for I := 0 to Min(FRunCheckListBox.Items.Count, FDiscoveredFiles.Count) - 1 do
  begin
    if FRunCheckListBox.Checked[I] then
    begin
      FilePath := FDiscoveredFiles[I];
      SummaryPath := ChangeFileExt(FilePath, '') + '_summary.csv';
      if FileExists(FilePath) then
      begin
        DeleteFile(FilePath);
        DeletedAny := True;
      end;
      if FileExists(SummaryPath) then
        DeleteFile(SummaryPath);
    end;
  end;

  if DeletedAny then
  begin
    CurrGame := '';
    if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
      CurrGame := FGameComboBox.Items[FGameComboBox.ItemIndex];
    RefreshGamesAndRuns(CurrGame);
  end;
end;

procedure TgplotForm.ExportPngClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  GameStr: string;
begin
  SaveDlg := TSaveDialog.Create(Self);
  try
    SaveDlg.Title := 'Export PasPlot Benchmark Chart as PNG';
    SaveDlg.Filter := 'PNG Image (*.png)|*.png';
    SaveDlg.DefaultExt := 'png';
    if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
      GameStr := FGameComboBox.Items[FGameComboBox.ItemIndex]
    else
      GameStr := 'benchmark';
    SaveDlg.FileName := GameStr + '_pasplot.png';
    if SaveDlg.Execute then
      ExportToPngFile(SaveDlg.FileName);
  finally
    SaveDlg.Free;
  end;
end;

procedure TgplotForm.ViewTabBtnClick(Sender: TObject);
begin
  if Sender is TControl then
    SetViewMode(TGplotViewMode(TControl(Sender).Tag));
end;

procedure TgplotForm.ChartPaintBoxPaint(Sender: TObject);
begin
  RenderChartToCanvas(FChartPaintBox.Canvas, FChartPaintBox.Width, FChartPaintBox.Height);
end;

procedure TgplotForm.ChartPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FHoverX := X;
  FHoverY := Y;
  FHoverActive := True;
  FChartPaintBox.Invalidate;
end;

procedure TgplotForm.ChartPaintBoxMouseLeave(Sender: TObject);
begin
  FHoverActive := False;
  FChartPaintBox.Invalidate;
end;

procedure TgplotForm.RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
var
  IsDark: Boolean;
  BgColor, TextColor, MutedColor: TColor;
  PlotRect: TRect;
  I, LegendX, LegendY: Integer;
  SeriesColor: TColor;
  LegendText: string;
begin
  if (AWidth <= 10) or (AHeight <= 10) then Exit;
  IsDark := (CurrentTheme <> tmLight);
  if IsDark then
  begin
    BgColor := RGBToColor(24, 29, 44);
    TextColor := RGBToColor(235, 240, 248);
    MutedColor := RGBToColor(145, 155, 175);
  end
  else
  begin
    BgColor := RGBToColor(250, 251, 254);
    TextColor := RGBToColor(25, 30, 40);
    MutedColor := RGBToColor(100, 110, 130);
  end;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := BgColor;
  ACanvas.FillRect(0, 0, AWidth, AHeight);

  if Length(FLoadedRuns) = 0 then
  begin
    ACanvas.Font.Color := MutedColor;
    ACanvas.Font.Size := 11;
    ACanvas.Brush.Style := bsClear;
    ACanvas.TextOut(Max(20, (AWidth - 340) div 2), AHeight div 2 - 10,
      'No benchmark runs selected. Record a log with MangoHud or check a run on the left.');
    Exit;
  end;

  // Draw top legend bar for checked runs
  LegendX := 16;
  LegendY := 10;
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [fsBold];
  for I := 0 to High(FLoadedRuns) do
  begin
    SeriesColor := SERIES_COLORS[I mod Length(SERIES_COLORS)];
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := SeriesColor;
    ACanvas.Pen.Color := SeriesColor;
    ACanvas.Rectangle(LegendX, LegendY + 3, LegendX + 12, LegendY + 15);
    Inc(LegendX, 16);

    LegendText := Format('%s (Avg %.0f FPS)', [FLoadedRuns[I].DisplayName, FLoadedRuns[I].AvgFps]);
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Color := TextColor;
    ACanvas.TextOut(LegendX, LegendY, LegendText);
    Inc(LegendX, ACanvas.TextWidth(LegendText) + 20);
    if LegendX > AWidth - 180 then Break;
  end;

  PlotRect := Rect(64, 36, AWidth - 20, AHeight - 28);
  case FViewMode of
    gvmTimeline: DrawTimelineView(ACanvas, PlotRect, IsDark);
    gvmSummary:  DrawSummaryView(ACanvas, PlotRect, IsDark);
    gvmHardware: DrawHardwareView(ACanvas, PlotRect, IsDark);
  end;
end;

procedure TgplotForm.DrawTimelineView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
var
  TopRect, BotRect: TRect;
  MidY, RIdx, SIdx, Step, X, Y, PrevX, PrevY: Integer;
  MaxDuration, MaxFpsVal, MaxFtVal: Double;
  GridColor, AxisColor, TextColor: TColor;
  SeriesColor: TColor;
  Run: TGplotRunData;
  HoverSec: Double;
  BestIdx: Integer;
  BestDist, Dist: Double;
  TipStr: string;
begin
  if (ARect.Right <= ARect.Left + 40) or (ARect.Bottom <= ARect.Top + 60) then Exit;

  GridColor := IfThen(AIsDark, RGBToColor(45, 54, 78), RGBToColor(220, 225, 235));
  AxisColor := IfThen(AIsDark, RGBToColor(90, 105, 140), RGBToColor(160, 170, 190));
  TextColor := IfThen(AIsDark, RGBToColor(210, 220, 235), RGBToColor(40, 50, 65));

  MidY := (ARect.Top + ARect.Bottom) div 2;
  TopRect := Rect(ARect.Left, ARect.Top + 14, ARect.Right, MidY - 14);
  BotRect := Rect(ARect.Left, MidY + 22, ARect.Right, ARect.Bottom - 8);

  MaxDuration := 1.0;
  MaxFpsVal := 60.0;
  MaxFtVal := 16.7;
  for RIdx := 0 to High(FLoadedRuns) do
  begin
    if FLoadedRuns[RIdx].DurationSec > MaxDuration then
      MaxDuration := FLoadedRuns[RIdx].DurationSec;
    if FLoadedRuns[RIdx].MaxFps * 1.1 > MaxFpsVal then
      MaxFpsVal := FLoadedRuns[RIdx].MaxFps * 1.1;
    for SIdx := 0 to FLoadedRuns[RIdx].SampleCount - 1 do
      if FLoadedRuns[RIdx].Samples[SIdx].FrametimeMs * 1.15 > MaxFtVal then
        MaxFtVal := FLoadedRuns[RIdx].Samples[SIdx].FrametimeMs * 1.15;
  end;

  // Titles & Frames
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Color := TextColor;
  ACanvas.Font.Style := [fsBold];
  ACanvas.TextOut(TopRect.Left, TopRect.Top - 16, 'FPS Over Time');
  ACanvas.TextOut(BotRect.Left, BotRect.Top - 16, 'Frametime (ms) Over Time');

  ACanvas.Font.Style := [];
  ACanvas.Pen.Color := GridColor;
  for SIdx := 0 to 4 do
  begin
    Y := TopRect.Top + Round((TopRect.Bottom - TopRect.Top) * (SIdx / 4.0));
    ACanvas.Line(TopRect.Left, Y, TopRect.Right, Y);
    ACanvas.TextOut(4, Y - 7, Format('%.0f', [MaxFpsVal * (1.0 - SIdx / 4.0)]));

    Y := BotRect.Top + Round((BotRect.Bottom - BotRect.Top) * (SIdx / 4.0));
    ACanvas.Line(BotRect.Left, Y, BotRect.Right, Y);
    ACanvas.TextOut(4, Y - 7, Format('%.1fms', [MaxFtVal * (1.0 - SIdx / 4.0)]));
  end;

  // Time X-Axis Labels
  for SIdx := 0 to 4 do
  begin
    X := TopRect.Left + Round((TopRect.Right - TopRect.Left) * (SIdx / 4.0));
    ACanvas.Line(X, TopRect.Top, X, TopRect.Bottom);
    ACanvas.Line(X, BotRect.Top, X, BotRect.Bottom);
    ACanvas.TextOut(X - 12, BotRect.Bottom + 4, Format('%.0fs', [MaxDuration * (SIdx / 4.0)]));
  end;

  ACanvas.Pen.Color := AxisColor;
  ACanvas.Frame(TopRect);
  ACanvas.Frame(BotRect);

  // Plot FPS and Frametime polylines for each run
  for RIdx := 0 to High(FLoadedRuns) do
  begin
    Run := FLoadedRuns[RIdx];
    if Run.SampleCount = 0 then Continue;
    SeriesColor := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
    ACanvas.Pen.Color := SeriesColor;
    ACanvas.Pen.Width := 2;

    Step := Max(1, Run.SampleCount div Max(200, TopRect.Right - TopRect.Left));
    PrevX := -1;
    PrevY := -1;
    SIdx := 0;
    while SIdx < Run.SampleCount do
    begin
      X := TopRect.Left + Round((Run.Samples[SIdx].ElapsedSec / MaxDuration) * (TopRect.Right - TopRect.Left));
      Y := TopRect.Bottom - Round(EnsureRange(Run.Samples[SIdx].Fps / MaxFpsVal, 0.0, 1.0) * (TopRect.Bottom - TopRect.Top));
      if PrevX >= 0 then
        ACanvas.Line(PrevX, PrevY, X, Y);
      PrevX := X;
      PrevY := Y;
      Inc(SIdx, Step);
    end;

    PrevX := -1;
    PrevY := -1;
    SIdx := 0;
    while SIdx < Run.SampleCount do
    begin
      X := BotRect.Left + Round((Run.Samples[SIdx].ElapsedSec / MaxDuration) * (BotRect.Right - BotRect.Left));
      Y := BotRect.Bottom - Round(EnsureRange(Run.Samples[SIdx].FrametimeMs / MaxFtVal, 0.0, 1.0) * (BotRect.Bottom - BotRect.Top));
      if PrevX >= 0 then
        ACanvas.Line(PrevX, PrevY, X, Y);
      PrevX := X;
      PrevY := Y;
      Inc(SIdx, Step);
    end;
  end;
  ACanvas.Pen.Width := 1;

  // Hover crosshair and readout
  if FHoverActive and (FHoverX >= TopRect.Left) and (FHoverX <= TopRect.Right) then
  begin
    HoverSec := ((FHoverX - TopRect.Left) / Max(1, TopRect.Right - TopRect.Left)) * MaxDuration;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := TextColor;
    ACanvas.Line(FHoverX, TopRect.Top, FHoverX, BotRect.Bottom);
    ACanvas.Pen.Style := psSolid;

    Run := FLoadedRuns[0];
    BestIdx := 0;
    BestDist := 1e18;
    for SIdx := 0 to Run.SampleCount - 1 do
    begin
      Dist := Abs(Run.Samples[SIdx].ElapsedSec - HoverSec);
      if Dist < BestDist then
      begin
        BestDist := Dist;
        BestIdx := SIdx;
      end;
    end;
    if (Run.SampleCount > 0) and (BestIdx >= 0) then
    begin
      TipStr := Format('t=%.1fs | %.1f FPS | %.2f ms', [
        Run.Samples[BestIdx].ElapsedSec,
        Run.Samples[BestIdx].Fps,
        Run.Samples[BestIdx].FrametimeMs
      ]);
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := IfThen(AIsDark, RGBToColor(15, 18, 28), RGBToColor(235, 240, 250));
      X := Min(TopRect.Right - ACanvas.TextWidth(TipStr) - 12, FHoverX + 8);
      ACanvas.Rectangle(X, TopRect.Top + 4, X + ACanvas.TextWidth(TipStr) + 10, TopRect.Top + 24);
      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Color := TextColor;
      ACanvas.TextOut(X + 5, TopRect.Top + 6, TipStr);
    end;
  end;
end;

procedure TgplotForm.DrawSummaryView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
const
  METRIC_NAMES: array[0..3] of string = ('Average FPS', '1% Low FPS', '0.1% Low FPS', 'Peak (Max) FPS');
var
  MIdx, RIdx, GroupTop, GroupH, BarH, BarTop, BarRight, MaxBarW: Integer;
  MaxVal, Val: Double;
  TextColor, GridColor: TColor;
  ValText: string;
begin
  if (ARect.Right <= ARect.Left + 80) or (ARect.Bottom <= ARect.Top + 60) then Exit;

  TextColor := IfThen(AIsDark, RGBToColor(230, 236, 245), RGBToColor(30, 35, 45));
  GridColor := IfThen(AIsDark, RGBToColor(45, 54, 78), RGBToColor(220, 225, 235));

  MaxVal := 60.0;
  for RIdx := 0 to High(FLoadedRuns) do
    if FLoadedRuns[RIdx].MaxFps * 1.15 > MaxVal then
      MaxVal := FLoadedRuns[RIdx].MaxFps * 1.15;

  GroupH := (ARect.Bottom - ARect.Top) div 4;
  MaxBarW := Max(100, (ARect.Right - ARect.Left) - 160);

  for MIdx := 0 to 3 do
  begin
    GroupTop := ARect.Top + MIdx * GroupH;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Color := TextColor;
    ACanvas.Font.Style := [fsBold];
    ACanvas.TextOut(ARect.Left, GroupTop + 4, METRIC_NAMES[MIdx]);

    BarH := Max(10, Min(22, (GroupH - 28) div Max(1, Length(FLoadedRuns))));
    for RIdx := 0 to High(FLoadedRuns) do
    begin
      case MIdx of
        0: Val := FLoadedRuns[RIdx].AvgFps;
        1: Val := FLoadedRuns[RIdx].Fps1Low;
        2: Val := FLoadedRuns[RIdx].Fps01Low;
        else Val := FLoadedRuns[RIdx].MaxFps;
      end;

      BarTop := GroupTop + 24 + RIdx * (BarH + 3);
      BarRight := ARect.Left + 10 + Round(EnsureRange(Val / MaxVal, 0.0, 1.0) * MaxBarW);

      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.Rectangle(ARect.Left + 10, BarTop, Max(ARect.Left + 14, BarRight), BarTop + BarH);

      ValText := Format('%.1f FPS (%s)', [Val, FLoadedRuns[RIdx].DisplayName]);
      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Style := [];
      ACanvas.Font.Color := TextColor;
      ACanvas.TextOut(Max(ARect.Left + 18, BarRight + 8), BarTop + Max(0, (BarH - 14) div 2), ValText);
    end;

    ACanvas.Pen.Color := GridColor;
    ACanvas.Line(ARect.Left, GroupTop + GroupH - 2, ARect.Right, GroupTop + GroupH - 2);
  end;
end;

procedure TgplotForm.DrawHardwareView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
const
  HW_METRICS: array[0..3] of string = (
    'Avg GPU Load (%)',
    'Avg CPU Load (%)',
    'Max GPU Temp (°C)',
    'Avg GPU Power (W)'
  );
var
  MIdx, RIdx, GroupTop, GroupH, BarH, BarTop, BarRight, MaxBarW: Integer;
  MaxVal, Val: Double;
  TextColor, GridColor: TColor;
  UnitStr, ValText: string;
begin
  if (ARect.Right <= ARect.Left + 80) or (ARect.Bottom <= ARect.Top + 60) then Exit;

  TextColor := IfThen(AIsDark, RGBToColor(230, 236, 245), RGBToColor(30, 35, 45));
  GridColor := IfThen(AIsDark, RGBToColor(45, 54, 78), RGBToColor(220, 225, 235));

  GroupH := (ARect.Bottom - ARect.Top) div 4;
  MaxBarW := Max(100, (ARect.Right - ARect.Left) - 180);

  for MIdx := 0 to 3 do
  begin
    GroupTop := ARect.Top + MIdx * GroupH;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Color := TextColor;
    ACanvas.Font.Style := [fsBold];
    ACanvas.TextOut(ARect.Left, GroupTop + 4, HW_METRICS[MIdx]);

    MaxVal := 100.0;
    if MIdx = 3 then
    begin
      MaxVal := 150.0;
      for RIdx := 0 to High(FLoadedRuns) do
        if FLoadedRuns[RIdx].AvgGpuPower * 1.2 > MaxVal then
          MaxVal := FLoadedRuns[RIdx].AvgGpuPower * 1.2;
    end;

    BarH := Max(10, Min(22, (GroupH - 28) div Max(1, Length(FLoadedRuns))));
    for RIdx := 0 to High(FLoadedRuns) do
    begin
      case MIdx of
        0: begin Val := FLoadedRuns[RIdx].AvgGpuLoad; UnitStr := '%'; end;
        1: begin Val := FLoadedRuns[RIdx].AvgCpuLoad; UnitStr := '%'; end;
        2: begin Val := FLoadedRuns[RIdx].MaxGpuTemp; UnitStr := '°C'; end;
        else begin Val := FLoadedRuns[RIdx].AvgGpuPower; UnitStr := 'W'; end;
      end;

      BarTop := GroupTop + 24 + RIdx * (BarH + 3);
      BarRight := ARect.Left + 10 + Round(EnsureRange(Val / MaxVal, 0.0, 1.0) * MaxBarW);

      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.Rectangle(ARect.Left + 10, BarTop, Max(ARect.Left + 14, BarRight), BarTop + BarH);

      ValText := Format('%.1f %s | Peak VRAM: %.2f GB (%s)', [
        Val, UnitStr, FLoadedRuns[RIdx].MaxVramUsed, FLoadedRuns[RIdx].DisplayName
      ]);
      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Style := [];
      ACanvas.Font.Color := TextColor;
      ACanvas.TextOut(Max(ARect.Left + 18, BarRight + 8), BarTop + Max(0, (BarH - 14) div 2), ValText);
    end;

    ACanvas.Pen.Color := GridColor;
    ACanvas.Line(ARect.Left, GroupTop + GroupH - 2, ARect.Right, GroupTop + GroupH - 2);
  end;
end;

function TgplotForm.ExportToPngFile(const AFilePath: string): Boolean;
var
  Png: TPortableNetworkGraphic;
  Bmp: TBitmap;
  W, H: Integer;
  TargetDir: string;
begin
  Result := False;
  if Trim(AFilePath) = '' then Exit;
  TargetDir := ExtractFilePath(AFilePath);
  if (TargetDir <> '') and not DirectoryExists(TargetDir) then
    ForceDirectories(TargetDir);

  W := Max(900, FChartPaintBox.Width);
  H := Max(520, FChartPaintBox.Height);

  Bmp := TBitmap.Create;
  Png := TPortableNetworkGraphic.Create;
  try
    Bmp.SetSize(W, H);
    RenderChartToCanvas(Bmp.Canvas, W, H);
    Png.Assign(Bmp);
    Png.SaveToFile(AFilePath);
    Result := FileExists(AFilePath);
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

end.
