unit pasplot_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, StrUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, CheckLst, Grids, LCLIntf, LCLType, Types,
  Process, IniFiles, Menus, themeunit, overlay_utils, configmanager
  {$IFDEF LCLqt6}, qt6, qtwidgets{$ENDIF}
  {$IFDEF LCLqt5}, qt5, qtwidgets{$ENDIF};

type
  TGplotViewMode = (gvmResume, gvmTimeline, gvmSummary, gvmHardware, gvmTable);

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
    CustomName: string;
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

  { TPasPlotPanel }
  TPasPlotPanel = class(TPanel)
  private
    FBaseDataDir: string;
    FInitialGame: string;
    FViewMode: TGplotViewMode;
    FDiscoveredFiles: TStringList;
    FDiscoveredRuns: array of TGplotRunData;
    FLoadedRuns: array of TGplotRunData;
    FHoverX: Integer;
    FHoverY: Integer;
    FHoverActive: Boolean;
    FInReflow: Boolean;

    // Top toolbar
    FTopPanel: TPanel;
    FTitleLabel: TLabel;
    FGameLabel: TLabel;
    FGameComboBox: TComboBox;
    FRefreshBtn: TBitBtn;
    FOpenFolderBtn: TBitBtn;
    FRenameRunBtn: TBitBtn;
    FDeleteRunBtn: TBitBtn;
    FExportPngBtn: TBitBtn;

    FRunPopupMenu: TPopupMenu;
    FPopupRenameItem: TMenuItem;
    FPopupDeleteItem: TMenuItem;

    // Horizontal Run Chips Strip (Option C)
    FRunsStripPanel: TPanel;
    FRunsChipScroll: TScrollBox;
    FRunsActionsPanel: TPanel;
    FRunChipBtns: array of TBitBtn;
    FRunChipEditBtns: array of TBitBtn;
    FRunChipDelBtns: array of TBitBtn;

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
    FResumeTabBtn: TBitBtn;
    FTimelineTabBtn: TBitBtn;
    FSummaryTabBtn: TBitBtn;
    FHardwareTabBtn: TBitBtn;
    FTableTabBtn: TBitBtn;

    // Quick KPI Hero Cards
    FKpiContainerPanel: TPanel;
    FKpiCardAvgFps: TPanel;
    FKpiCardLows: TPanel;
    FKpiCardFrametime: TPanel;
    FKpiCardPower: TPanel;

    FKpiTitleAvgFps: TLabel;
    FKpiValAvgFps: TLabel;
    FKpiSubAvgFps: TLabel;

    FKpiTitleLows: TLabel;
    FKpiValLows: TLabel;
    FKpiSubLows: TLabel;

    FKpiTitleFrametime: TLabel;
    FKpiValFrametime: TLabel;
    FKpiSubFrametime: TLabel;

    FKpiTitlePower: TLabel;
    FKpiValPower: TLabel;
    FKpiSubPower: TLabel;

    FChartContainerPanel: TPanel;
    FChartPaintBox: TPaintBox;

    // Comparative table & specs footer
    FStatsPanel: TPanel;
    FStatsTitleLabel: TLabel;
    FStatsGrid: TStringGrid;
    FBottomBar: TPanel;
    FSpecsLabel: TLabel;

    procedure BuildUI;
    procedure SetViewMode(AValue: TGplotViewMode);
    procedure UpdateViewTabButtons;
    procedure UpdateKpiHeroCards;
    procedure KpiContainerResize(Sender: TObject);

    procedure GameComboChange(Sender: TObject);
    procedure RunCheckListClickCheck(Sender: TObject);
    procedure RunCheckListDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure RunCheckListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RunCheckListDblClick(Sender: TObject);
    procedure RunCheckListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SelectAllClick(Sender: TObject);
    procedure ClearSelClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure RenameRunClick(Sender: TObject);
    procedure PopupRenameClick(Sender: TObject);
    procedure PopupDeleteClick(Sender: TObject);
    procedure DeleteRunClick(Sender: TObject);
    procedure ExportPngClick(Sender: TObject);
    procedure ViewTabBtnClick(Sender: TObject);
    procedure PromptRenameBenchmark(AIndex: Integer);
    procedure RebuildRunChips;
    procedure UpdateRunChipStyles;
    procedure RunChipClick(Sender: TObject);
    procedure RunChipMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RunChipRenameClick(Sender: TObject);
    procedure RunChipDeleteClick(Sender: TObject);

    procedure ChartPaintBoxPaint(Sender: TObject);
    procedure ChartPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChartPaintBoxMouseLeave(Sender: TObject);

    procedure LoadRunsForSelectedGame;
    procedure ReloadCheckedRunsData;
    procedure UpdateStatsGridAndSpecs;

    procedure DrawResumeView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
    procedure DrawTimelineView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
    procedure DrawSummaryView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
    procedure DrawHardwareView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent; const AInitialGame: string = ''; const ABaseDataDir: string = ''); reintroduce;
    destructor Destroy; override;

    procedure ApplyThemeStyling;
    procedure ReflowLayout(AContentW: Integer);
    procedure RefreshGamesAndRuns(const APreferredGame: string = '');
    procedure RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
    function ExportToPngFile(const AFilePath: string): Boolean;
    function SelectedRunCount: Integer;
    function GetActiveGameLogFolder: string;

    property GameComboBox: TComboBox read FGameComboBox;
    property RunCheckListBox: TCheckListBox read FRunCheckListBox;
    property ResumeTabBtn: TBitBtn read FResumeTabBtn;
    property TimelineTabBtn: TBitBtn read FTimelineTabBtn;
    property SummaryTabBtn: TBitBtn read FSummaryTabBtn;
    property HardwareTabBtn: TBitBtn read FHardwareTabBtn;
    property TableTabBtn: TBitBtn read FTableTabBtn;
    property RunsStripPanel: TPanel read FRunsStripPanel;
    property RunsChipScroll: TScrollBox read FRunsChipScroll;
    property RefreshBtn: TBitBtn read FRefreshBtn;
    property OpenFolderBtn: TBitBtn read FOpenFolderBtn;
    property RenameRunBtn: TBitBtn read FRenameRunBtn;
    property DeleteRunBtn: TBitBtn read FDeleteRunBtn;
    property ExportPngBtn: TBitBtn read FExportPngBtn;
    property LeftPanel: TPanel read FLeftPanel;
    property TopPanel: TPanel read FTopPanel;
    property ChartPaintBox: TPaintBox read FChartPaintBox;
    property StatsGrid: TStringGrid read FStatsGrid;
    property SpecsLabel: TLabel read FSpecsLabel;
    property ViewMode: TGplotViewMode read FViewMode write SetViewMode;
  end;

  { TgplotForm }
  TgplotForm = class(TForm)
  private
    FPlotPanel: TPasPlotPanel;
    function GetGameComboBox: TComboBox;
    function GetRunCheckListBox: TCheckListBox;
    function GetResumeTabBtn: TBitBtn;
    function GetTimelineTabBtn: TBitBtn;
    function GetSummaryTabBtn: TBitBtn;
    function GetHardwareTabBtn: TBitBtn;
    function GetRefreshBtn: TBitBtn;
    function GetOpenFolderBtn: TBitBtn;
    function GetRenameRunBtn: TBitBtn;
    function GetDeleteRunBtn: TBitBtn;
    function GetExportPngBtn: TBitBtn;
    function GetChartPaintBox: TPaintBox;
    function GetStatsGrid: TStringGrid;
    function GetSpecsLabel: TLabel;
    function GetViewMode: TGplotViewMode;
    procedure SetViewMode(AValue: TGplotViewMode);
  public
    constructor Create(AOwner: TComponent; const AInitialGame: string = ''; const ABaseDataDir: string = ''); reintroduce;
    destructor Destroy; override;

    procedure RefreshGamesAndRuns(const APreferredGame: string = '');
    procedure RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
    function ExportToPngFile(const AFilePath: string): Boolean;
    function SelectedRunCount: Integer;
    function GetActiveGameLogFolder: string;

    property PlotPanel: TPasPlotPanel read FPlotPanel;
    property GameComboBox: TComboBox read GetGameComboBox;
    property RunCheckListBox: TCheckListBox read GetRunCheckListBox;
    property ResumeTabBtn: TBitBtn read GetResumeTabBtn;
    property TimelineTabBtn: TBitBtn read GetTimelineTabBtn;
    property SummaryTabBtn: TBitBtn read GetSummaryTabBtn;
    property HardwareTabBtn: TBitBtn read GetHardwareTabBtn;
    property RefreshBtn: TBitBtn read GetRefreshBtn;
    property OpenFolderBtn: TBitBtn read GetOpenFolderBtn;
    property RenameRunBtn: TBitBtn read GetRenameRunBtn;
    property DeleteRunBtn: TBitBtn read GetDeleteRunBtn;
    property ExportPngBtn: TBitBtn read GetExportPngBtn;
    property ChartPaintBox: TPaintBox read GetChartPaintBox;
    property StatsGrid: TStringGrid read GetStatsGrid;
    property SpecsLabel: TLabel read GetSpecsLabel;
    property ViewMode: TGplotViewMode read GetViewMode write SetViewMode;
  end;

  TpasplotForm = TgplotForm;

function IsMangoHudSummaryCsv(const AFileName: string): Boolean;
function ExtractAppFromMangoHudCsvName(const AFileName: string): string;
function OrganizeMangoHudCsvLogs(const ABaseDataDir: string = ''): Integer;
function ParseMangoHudCsvFile(const AFilePath: string; out ARun: TGplotRunData): Boolean;
function GetGameBenchmarksIniPath(const AGameDir: string): string;
function ReadBenchmarkCustomName(const AGameDir, AFileName: string): string;
procedure WriteBenchmarkCustomName(const AGameDir, AFileName, ACustomName: string);
procedure DeleteBenchmarkCustomName(const AGameDir, AFileName: string);
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

function GetGameBenchmarksIniPath(const AGameDir: string): string;
begin
  if Trim(AGameDir) = '' then
    Result := IncludeTrailingPathDelimiter(GetGOverlayDataDir()) + 'logs' + PathDelim + 'benchmarks.ini'
  else
    Result := IncludeTrailingPathDelimiter(AGameDir) + 'benchmarks.ini';
end;

function ReadBenchmarkCustomName(const AGameDir, AFileName: string): string;
var
  Ini: TIniFile;
  IniPath: string;
begin
  Result := '';
  if Trim(AFileName) = '' then Exit;
  IniPath := GetGameBenchmarksIniPath(AGameDir);
  if not FileExists(IniPath) then Exit;
  Ini := TIniFile.Create(IniPath);
  try
    Result := Ini.ReadString('Names', AFileName, '');
  finally
    Ini.Free;
  end;
end;

procedure WriteBenchmarkCustomName(const AGameDir, AFileName, ACustomName: string);
var
  Ini: TIniFile;
  IniPath, IniDir: string;
begin
  if Trim(AFileName) = '' then Exit;
  IniPath := GetGameBenchmarksIniPath(AGameDir);
  IniDir := ExtractFilePath(IniPath);
  if (IniDir <> '') and not DirectoryExists(IniDir) then
    ForceDirectories(IniDir);
  Ini := TIniFile.Create(IniPath);
  try
    if Trim(ACustomName) = '' then
      Ini.DeleteKey('Names', AFileName)
    else
      Ini.WriteString('Names', AFileName, Trim(ACustomName));
  finally
    Ini.Free;
  end;
end;

procedure DeleteBenchmarkCustomName(const AGameDir, AFileName: string);
var
  Ini: TIniFile;
  IniPath: string;
begin
  if Trim(AFileName) = '' then Exit;
  IniPath := GetGameBenchmarksIniPath(AGameDir);
  if not FileExists(IniPath) then Exit;
  Ini := TIniFile.Create(IniPath);
  try
    Ini.DeleteKey('Names', AFileName);
  finally
    Ini.Free;
  end;
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
  Caption := 'PasPlot - MangoHud Benchmark Analyzer';
  Width := 1080;
  Height := 720;
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 540;
  Position := poScreenCenter;

  FPlotPanel := TPasPlotPanel.Create(Self, AInitialGame, ABaseDataDir);
  FPlotPanel.Parent := Self;
  FPlotPanel.Align := alClient;
end;

destructor TgplotForm.Destroy;
begin
  inherited Destroy;
end;

function TgplotForm.GetGameComboBox: TComboBox; begin Result := FPlotPanel.GameComboBox; end;
function TgplotForm.GetRunCheckListBox: TCheckListBox; begin Result := FPlotPanel.RunCheckListBox; end;
function TgplotForm.GetResumeTabBtn: TBitBtn; begin Result := FPlotPanel.ResumeTabBtn; end;
function TgplotForm.GetTimelineTabBtn: TBitBtn; begin Result := FPlotPanel.TimelineTabBtn; end;
function TgplotForm.GetSummaryTabBtn: TBitBtn; begin Result := FPlotPanel.SummaryTabBtn; end;
function TgplotForm.GetHardwareTabBtn: TBitBtn; begin Result := FPlotPanel.HardwareTabBtn; end;
function TgplotForm.GetRefreshBtn: TBitBtn; begin Result := FPlotPanel.RefreshBtn; end;
function TgplotForm.GetOpenFolderBtn: TBitBtn; begin Result := FPlotPanel.OpenFolderBtn; end;
function TgplotForm.GetRenameRunBtn: TBitBtn; begin Result := FPlotPanel.RenameRunBtn; end;
function TgplotForm.GetDeleteRunBtn: TBitBtn; begin Result := FPlotPanel.DeleteRunBtn; end;
function TgplotForm.GetExportPngBtn: TBitBtn; begin Result := FPlotPanel.ExportPngBtn; end;
function TgplotForm.GetChartPaintBox: TPaintBox; begin Result := FPlotPanel.ChartPaintBox; end;
function TgplotForm.GetStatsGrid: TStringGrid; begin Result := FPlotPanel.StatsGrid; end;
function TgplotForm.GetSpecsLabel: TLabel; begin Result := FPlotPanel.SpecsLabel; end;
function TgplotForm.GetViewMode: TGplotViewMode; begin Result := FPlotPanel.ViewMode; end;
procedure TgplotForm.SetViewMode(AValue: TGplotViewMode); begin FPlotPanel.ViewMode := AValue; end;

procedure TgplotForm.RefreshGamesAndRuns(const APreferredGame: string);
begin
  FPlotPanel.RefreshGamesAndRuns(APreferredGame);
end;

procedure TgplotForm.RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
begin
  FPlotPanel.RenderChartToCanvas(ACanvas, AWidth, AHeight);
end;

function TgplotForm.ExportToPngFile(const AFilePath: string): Boolean;
begin
  Result := FPlotPanel.ExportToPngFile(AFilePath);
end;

function TgplotForm.SelectedRunCount: Integer;
begin
  Result := FPlotPanel.SelectedRunCount;
end;

function TgplotForm.GetActiveGameLogFolder: string;
begin
  Result := FPlotPanel.GetActiveGameLogFolder;
end;

{ TPasPlotPanel }

constructor TPasPlotPanel.Create(AOwner: TComponent; const AInitialGame: string; const ABaseDataDir: string);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  if Trim(ABaseDataDir) <> '' then
    FBaseDataDir := IncludeTrailingPathDelimiter(ABaseDataDir)
  else
    FBaseDataDir := IncludeTrailingPathDelimiter(GetGOverlayDataDir());
  FInitialGame := Trim(AInitialGame);
  FViewMode := gvmResume;
  FHoverActive := False;
  FDiscoveredFiles := TStringList.Create;

  BuildUI;
  ApplyThemeStyling;
  ReflowLayout(IfThen(Width > 0, Width, 1080));
  RefreshGamesAndRuns(FInitialGame);
end;

destructor TPasPlotPanel.Destroy;
begin
  FreeAndNil(FDiscoveredFiles);
  inherited Destroy;
end;

procedure TPasPlotPanel.Resize;
begin
  inherited Resize;
  if ClientWidth > 0 then
    ReflowLayout(ClientWidth);
  UpdateViewTabButtons;
  UpdateRunChipStyles;
end;

procedure TPasPlotPanel.ReflowLayout(AContentW: Integer);
const
  RightPad = 10;
  Gap = 6;
var
  IsCompact: Boolean;
  X, W, ComboLeft, ComboW, AvailTabW, TabBtnW, KpiFontSize: Integer;
begin
  if FInReflow or (AContentW <= 0) or not Assigned(FTopPanel) then Exit;
  FInReflow := True;
  try
  IsCompact := AContentW < 920;

  // Layout B: single-row top toolbar (Game + Refresh, Open Folder, Export PNG)
  X := AContentW - RightPad;

  W := IfThen(IsCompact, 96, 112);
  FExportPngBtn.SetBounds(X - W, 11, W, 30);
  X := X - W - Gap;

  W := IfThen(IsCompact, 94, 110);
  FOpenFolderBtn.Caption := IfThen(IsCompact, 'Open Folder', 'Open Folder');
  FOpenFolderBtn.SetBounds(X - W, 11, W, 30);
  X := X - W - Gap;

  W := IfThen(IsCompact, 78, 96);
  FRefreshBtn.SetBounds(X - W, 11, W, 30);
  X := X - W - Gap;

  if IsCompact then
  begin
    FTitleLabel.Visible := False;
    FGameLabel.Left := 10;
    FGameLabel.Top := 17;
    ComboLeft := 58;
  end
  else
  begin
    FTitleLabel.Visible := True;
    FTitleLabel.Left := 14;
    FTitleLabel.Top := 15;
    FGameLabel.Left := 95;
    FGameLabel.Top := 17;
    ComboLeft := 150;
  end;

  ComboW := Max(120, Min(320, X - ComboLeft - 6));
  FGameComboBox.Left := ComboLeft;
  FGameComboBox.Top := 12;
  FGameComboBox.Width := ComboW;

  // Option C: hide permanent left sidebar; runs live in FRunsStripPanel
  FLeftPanel.Visible := False;

  // View switcher pills (5 tabs: Resume, Timeline, Comparison, Telemetry, Table)
  AvailTabW := Max(400, AContentW - 24);
  TabBtnW := Min(160, (AvailTabW - 28) div 5);
  FResumeTabBtn.SetBounds(4, 4, TabBtnW, 32);
  FTimelineTabBtn.SetBounds(4 + TabBtnW + 6, 4, TabBtnW, 32);
  FSummaryTabBtn.SetBounds(4 + (TabBtnW + 6) * 2, 4, TabBtnW, 32);
  FHardwareTabBtn.SetBounds(4 + (TabBtnW + 6) * 3, 4, TabBtnW, 32);
  if Assigned(FTableTabBtn) then
    FTableTabBtn.SetBounds(4 + (TabBtnW + 6) * 4, 4, TabBtnW, 32);

  // Full width (~814px) gives all 4 KPI cards plenty of room
  KpiFontSize := 15;
  if Assigned(FKpiValAvgFps) then
  begin
    FKpiValAvgFps.Font.Size := KpiFontSize;
    FKpiValLows.Font.Size := KpiFontSize;
    FKpiValFrametime.Font.Size := KpiFontSize;
    FKpiValPower.Font.Size := KpiFontSize;
  end;
  KpiContainerResize(nil);
  finally
    FInReflow := False;
  end;
end;

procedure TPasPlotPanel.BuildUI;
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
  FOpenFolderBtn.SetBounds(530, 11, 115, 30);
  FOpenFolderBtn.Caption := 'Open Folder';
  FOpenFolderBtn.Cursor := crHandPoint;
  FOpenFolderBtn.OnClick := @OpenFolderClick;

  FExportPngBtn := TBitBtn.Create(FTopPanel);
  FExportPngBtn.Parent := FTopPanel;
  FExportPngBtn.SetBounds(904, 11, 120, 30);
  FExportPngBtn.Caption := 'Export PNG';
  FExportPngBtn.Cursor := crHandPoint;
  FExportPngBtn.OnClick := @ExportPngClick;

  // Horizontal Run Chips Strip (Option C)
  FRunsStripPanel := TPanel.Create(Self);
  FRunsStripPanel.Parent := Self;
  FRunsStripPanel.Align := alTop;
  FRunsStripPanel.Top := FTopPanel.Height;
  FRunsStripPanel.Height := 44;
  FRunsStripPanel.BevelOuter := bvNone;

  FRunsActionsPanel := TPanel.Create(FRunsStripPanel);
  FRunsActionsPanel.Parent := FRunsStripPanel;
  FRunsActionsPanel.Align := alRight;
  FRunsActionsPanel.Width := 0;
  FRunsActionsPanel.Visible := False;
  FRunsActionsPanel.BevelOuter := bvNone;

  FSelectAllBtn := TBitBtn.Create(FRunsActionsPanel);
  FSelectAllBtn.Parent := FRunsActionsPanel;
  FSelectAllBtn.SetBounds(4, 8, 42, 28);
  FSelectAllBtn.Caption := 'All';
  FSelectAllBtn.Hint := 'Select all benchmark runs';
  FSelectAllBtn.ShowHint := True;
  FSelectAllBtn.Cursor := crHandPoint;
  FSelectAllBtn.OnClick := @SelectAllClick;

  FClearSelBtn := TBitBtn.Create(FRunsActionsPanel);
  FClearSelBtn.Parent := FRunsActionsPanel;
  FClearSelBtn.SetBounds(50, 8, 46, 28);
  FClearSelBtn.Caption := 'None';
  FClearSelBtn.Hint := 'Clear run selection';
  FClearSelBtn.ShowHint := True;
  FClearSelBtn.Cursor := crHandPoint;
  FClearSelBtn.OnClick := @ClearSelClick;

  FRenameRunBtn := TBitBtn.Create(FRunsActionsPanel);
  FRenameRunBtn.Parent := FRunsActionsPanel;
  FRenameRunBtn.SetBounds(100, 8, 62, 28);
  FRenameRunBtn.Caption := 'Rename';
  FRenameRunBtn.Hint := 'Rename selected benchmark run (F2)';
  FRenameRunBtn.ShowHint := True;
  FRenameRunBtn.Cursor := crHandPoint;
  FRenameRunBtn.OnClick := @RenameRunClick;

  FDeleteRunBtn := TBitBtn.Create(FRunsActionsPanel);
  FDeleteRunBtn.Parent := FRunsActionsPanel;
  FDeleteRunBtn.SetBounds(166, 8, 60, 28);
  FDeleteRunBtn.Caption := 'Delete';
  FDeleteRunBtn.Hint := 'Delete selected benchmark run';
  FDeleteRunBtn.ShowHint := True;
  FDeleteRunBtn.Cursor := crHandPoint;
  FDeleteRunBtn.OnClick := @DeleteRunClick;

  FRunsChipScroll := TScrollBox.Create(FRunsStripPanel);
  FRunsChipScroll.Parent := FRunsStripPanel;
  FRunsChipScroll.Align := alClient;
  FRunsChipScroll.BorderStyle := bsNone;
  FRunsChipScroll.VertScrollBar.Visible := False;
  FRunsChipScroll.HorzScrollBar.Tracking := True;
  FRunsChipScroll.AutoScroll := True;

  // Bottom Status Bar (hidden to maximize chart area)
  FBottomBar := TPanel.Create(Self);
  FBottomBar.Parent := Self;
  FBottomBar.Align := alBottom;
  FBottomBar.Height := 0;
  FBottomBar.Visible := False;
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

  // Hidden underlying Run CheckListBox (keeps API/test compatibility & popup menu)
  FLeftPanel := TPanel.Create(FBodyPanel);
  FLeftPanel.Parent := FBodyPanel;
  FLeftPanel.Align := alLeft;
  FLeftPanel.Width := 236;
  FLeftPanel.Visible := False;
  FLeftPanel.BevelOuter := bvNone;

  FRunsHeaderPanel := TPanel.Create(FLeftPanel);
  FRunsHeaderPanel.Parent := FLeftPanel;
  FRunsHeaderPanel.Align := alTop;
  FRunsHeaderPanel.Height := 32;
  FRunsHeaderPanel.BevelOuter := bvNone;

  FRunsTitleLabel := TLabel.Create(FRunsHeaderPanel);
  FRunsTitleLabel.Parent := FRunsHeaderPanel;
  FRunsTitleLabel.Left := 8;
  FRunsTitleLabel.Top := 6;
  FRunsTitleLabel.Caption := 'Benchmark Runs';
  FRunsTitleLabel.Font.Style := [fsBold];

  FRunCheckListBox := TCheckListBox.Create(FLeftPanel);
  FRunCheckListBox.Parent := FLeftPanel;
  FRunCheckListBox.Align := alClient;
  FRunCheckListBox.Style := lbOwnerDrawFixed;
  FRunCheckListBox.ItemHeight := 52;
  FRunCheckListBox.OnDrawItem := @RunCheckListDrawItem;
  FRunCheckListBox.OnClickCheck := @RunCheckListClickCheck;

  FRunPopupMenu := TPopupMenu.Create(Self);
  FPopupRenameItem := TMenuItem.Create(FRunPopupMenu);
  FPopupRenameItem.Caption := 'Rename Benchmark... (F2)';
  FPopupRenameItem.OnClick := @PopupRenameClick;
  FRunPopupMenu.Items.Add(FPopupRenameItem);
  FPopupDeleteItem := TMenuItem.Create(FRunPopupMenu);
  FPopupDeleteItem.Caption := 'Delete Benchmark';
  FPopupDeleteItem.OnClick := @PopupDeleteClick;
  FRunPopupMenu.Items.Add(FPopupDeleteItem);

  FRunCheckListBox.Cursor := crHandPoint;
  FRunCheckListBox.PopupMenu := FRunPopupMenu;
  FRunCheckListBox.OnMouseDown := @RunCheckListMouseDown;
  FRunCheckListBox.OnDblClick := @RunCheckListDblClick;
  FRunCheckListBox.OnKeyDown := @RunCheckListKeyDown;

  // Right Area (Charts + Comparative Table)
  FRightPanel := TPanel.Create(FBodyPanel);
  FRightPanel.Parent := FBodyPanel;
  FRightPanel.Align := alClient;
  FRightPanel.BevelOuter := bvNone;
  FRightPanel.BorderSpacing.Around := 6;

  // Segmented Pill View Switcher
  FViewTabsPanel := TPanel.Create(FRightPanel);
  FViewTabsPanel.Parent := FRightPanel;
  FViewTabsPanel.Align := alTop;
  FViewTabsPanel.Height := 40;
  FViewTabsPanel.BevelOuter := bvNone;

  FResumeTabBtn := TBitBtn.Create(FViewTabsPanel);
  FResumeTabBtn.Parent := FViewTabsPanel;
  FResumeTabBtn.SetBounds(4, 4, 140, 32);
  FResumeTabBtn.Caption := '📋 Resume';
  FResumeTabBtn.Tag := Ord(gvmResume);
  FResumeTabBtn.Cursor := crHandPoint;
  FResumeTabBtn.OnClick := @ViewTabBtnClick;

  FTimelineTabBtn := TBitBtn.Create(FViewTabsPanel);
  FTimelineTabBtn.Parent := FViewTabsPanel;
  FTimelineTabBtn.SetBounds(150, 4, 140, 32);
  FTimelineTabBtn.Caption := '📈 Timeline';
  FTimelineTabBtn.Tag := Ord(gvmTimeline);
  FTimelineTabBtn.Cursor := crHandPoint;
  FTimelineTabBtn.OnClick := @ViewTabBtnClick;

  FSummaryTabBtn := TBitBtn.Create(FViewTabsPanel);
  FSummaryTabBtn.Parent := FViewTabsPanel;
  FSummaryTabBtn.SetBounds(190, 4, 180, 32);
  FSummaryTabBtn.Caption := '📊 Comparison';
  FSummaryTabBtn.Tag := Ord(gvmSummary);
  FSummaryTabBtn.Cursor := crHandPoint;
  FSummaryTabBtn.OnClick := @ViewTabBtnClick;

  FHardwareTabBtn := TBitBtn.Create(FViewTabsPanel);
  FHardwareTabBtn.Parent := FViewTabsPanel;
  FHardwareTabBtn.SetBounds(376, 4, 140, 32);
  FHardwareTabBtn.Caption := '🌡 Telemetry';
  FHardwareTabBtn.Tag := Ord(gvmHardware);
  FHardwareTabBtn.Cursor := crHandPoint;
  FHardwareTabBtn.OnClick := @ViewTabBtnClick;

  FTableTabBtn := TBitBtn.Create(FViewTabsPanel);
  FTableTabBtn.Parent := FViewTabsPanel;
  FTableTabBtn.SetBounds(522, 4, 140, 32);
  FTableTabBtn.Caption := '📑 Table';
  FTableTabBtn.Tag := Ord(gvmTable);
  FTableTabBtn.Cursor := crHandPoint;
  FTableTabBtn.OnClick := @ViewTabBtnClick;

  // Quick KPI Hero Cards Container
  FKpiContainerPanel := TPanel.Create(FRightPanel);
  FKpiContainerPanel.Parent := FRightPanel;
  FKpiContainerPanel.Align := alTop;
  FKpiContainerPanel.Height := 72;
  FKpiContainerPanel.BevelOuter := bvNone;
  FKpiContainerPanel.BorderSpacing.Top := 4;
  FKpiContainerPanel.BorderSpacing.Bottom := 6;
  FKpiContainerPanel.OnResize := @KpiContainerResize;

  // Card 1: Avg FPS
  FKpiCardAvgFps := TPanel.Create(FKpiContainerPanel);
  FKpiCardAvgFps.Parent := FKpiContainerPanel;
  FKpiCardAvgFps.BevelOuter := bvNone;

  FKpiTitleAvgFps := TLabel.Create(FKpiCardAvgFps);
  FKpiTitleAvgFps.Parent := FKpiCardAvgFps;
  FKpiTitleAvgFps.Left := 12;
  FKpiTitleAvgFps.Top := 6;
  FKpiTitleAvgFps.Caption := 'AVG FPS';
  FKpiTitleAvgFps.Font.Size := 8;
  FKpiTitleAvgFps.Font.Style := [fsBold];

  FKpiValAvgFps := TLabel.Create(FKpiCardAvgFps);
  FKpiValAvgFps.Parent := FKpiCardAvgFps;
  FKpiValAvgFps.Left := 12;
  FKpiValAvgFps.Top := 22;
  FKpiValAvgFps.Caption := '-';
  FKpiValAvgFps.Font.Size := 16;
  FKpiValAvgFps.Font.Style := [fsBold];

  FKpiSubAvgFps := TLabel.Create(FKpiCardAvgFps);
  FKpiSubAvgFps.Parent := FKpiCardAvgFps;
  FKpiSubAvgFps.Left := 12;
  FKpiSubAvgFps.Top := 48;
  FKpiSubAvgFps.Caption := 'No run selected';
  FKpiSubAvgFps.Font.Size := 8;

  // Card 2: 1% & 0.1% Low
  FKpiCardLows := TPanel.Create(FKpiContainerPanel);
  FKpiCardLows.Parent := FKpiContainerPanel;
  FKpiCardLows.BevelOuter := bvNone;

  FKpiTitleLows := TLabel.Create(FKpiCardLows);
  FKpiTitleLows.Parent := FKpiCardLows;
  FKpiTitleLows.Left := 12;
  FKpiTitleLows.Top := 6;
  FKpiTitleLows.Caption := '1% / 0.1% LOW';
  FKpiTitleLows.Font.Size := 8;
  FKpiTitleLows.Font.Style := [fsBold];

  FKpiValLows := TLabel.Create(FKpiCardLows);
  FKpiValLows.Parent := FKpiCardLows;
  FKpiValLows.Left := 12;
  FKpiValLows.Top := 22;
  FKpiValLows.Caption := '-';
  FKpiValLows.Font.Size := 16;
  FKpiValLows.Font.Style := [fsBold];

  FKpiSubLows := TLabel.Create(FKpiCardLows);
  FKpiSubLows.Parent := FKpiCardLows;
  FKpiSubLows.Left := 12;
  FKpiSubLows.Top := 48;
  FKpiSubLows.Caption := 'Stability metrics';
  FKpiSubLows.Font.Size := 8;

  // Card 3: Frametime & Pacing
  FKpiCardFrametime := TPanel.Create(FKpiContainerPanel);
  FKpiCardFrametime.Parent := FKpiContainerPanel;
  FKpiCardFrametime.BevelOuter := bvNone;

  FKpiTitleFrametime := TLabel.Create(FKpiCardFrametime);
  FKpiTitleFrametime.Parent := FKpiCardFrametime;
  FKpiTitleFrametime.Left := 12;
  FKpiTitleFrametime.Top := 6;
  FKpiTitleFrametime.Caption := 'FRAMETIME';
  FKpiTitleFrametime.Font.Size := 8;
  FKpiTitleFrametime.Font.Style := [fsBold];

  FKpiValFrametime := TLabel.Create(FKpiCardFrametime);
  FKpiValFrametime.Parent := FKpiCardFrametime;
  FKpiValFrametime.Left := 12;
  FKpiValFrametime.Top := 22;
  FKpiValFrametime.Caption := '-';
  FKpiValFrametime.Font.Size := 16;
  FKpiValFrametime.Font.Style := [fsBold];

  FKpiSubFrametime := TLabel.Create(FKpiCardFrametime);
  FKpiSubFrametime.Parent := FKpiCardFrametime;
  FKpiSubFrametime.Left := 12;
  FKpiSubFrametime.Top := 48;
  FKpiSubFrametime.Caption := 'Target pacing';
  FKpiSubFrametime.Font.Size := 8;

  // Card 4: Power & Temperature
  FKpiCardPower := TPanel.Create(FKpiContainerPanel);
  FKpiCardPower.Parent := FKpiContainerPanel;
  FKpiCardPower.BevelOuter := bvNone;

  FKpiTitlePower := TLabel.Create(FKpiCardPower);
  FKpiTitlePower.Parent := FKpiCardPower;
  FKpiTitlePower.Left := 12;
  FKpiTitlePower.Top := 6;
  FKpiTitlePower.Caption := 'POWER & TEMP';
  FKpiTitlePower.Font.Size := 8;
  FKpiTitlePower.Font.Style := [fsBold];

  FKpiValPower := TLabel.Create(FKpiCardPower);
  FKpiValPower.Parent := FKpiCardPower;
  FKpiValPower.Left := 12;
  FKpiValPower.Top := 22;
  FKpiValPower.Caption := '-';
  FKpiValPower.Font.Size := 16;
  FKpiValPower.Font.Style := [fsBold];

  FKpiSubPower := TLabel.Create(FKpiCardPower);
  FKpiSubPower.Parent := FKpiCardPower;
  FKpiSubPower.Left := 12;
  FKpiSubPower.Top := 48;
  FKpiSubPower.Caption := 'GPU Power & Temp';
  FKpiSubPower.Font.Size := 8;

  // Comparative Statistics Table (shown in dedicated Table view tab)
  FStatsPanel := TPanel.Create(FRightPanel);
  FStatsPanel.Parent := FRightPanel;
  FStatsPanel.Align := alClient;
  FStatsPanel.Visible := False;
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
  FStatsGrid.ColWidths[0] := 140;
  FStatsGrid.ColWidths[1] := 62;
  FStatsGrid.ColWidths[2] := 68;
  FStatsGrid.ColWidths[3] := 68;
  FStatsGrid.ColWidths[4] := 68;
  FStatsGrid.ColWidths[5] := 100;
  FStatsGrid.ColWidths[6] := 76;
  FStatsGrid.ColWidths[7] := 76;
  FStatsGrid.ColWidths[8] := 120;

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

procedure TPasPlotPanel.ApplyThemeStyling;
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
  if Assigned(FRunsStripPanel) then FRunsStripPanel.Color := BgColor;
  if Assigned(FRunsChipScroll) then FRunsChipScroll.Color := BgColor;
  if Assigned(FRunsActionsPanel) then FRunsActionsPanel.Color := BgColor;
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

  if Assigned(FRenameRunBtn) then
  begin
    FRefreshBtn.Color := CardColor;
    FRefreshBtn.Font.Color := TextColor;
    FOpenFolderBtn.Color := CardColor;
    FOpenFolderBtn.Font.Color := TextColor;
    FRenameRunBtn.Color := CardColor;
    FRenameRunBtn.Font.Color := TextColor;
    FDeleteRunBtn.Color := CardColor;
    FDeleteRunBtn.Font.Color := TextColor;
    FExportPngBtn.Color := CardColor;
    FExportPngBtn.Font.Color := TextColor;
  end;

  FStatsGrid.Color := BgColor;
  FStatsGrid.FixedColor := CardColor;
  FStatsGrid.Font.Color := TextColor;

  if Assigned(FKpiContainerPanel) then
  begin
    FKpiContainerPanel.Color := BgColor;
    FKpiCardAvgFps.Color := CardColor;
    FKpiCardLows.Color := CardColor;
    FKpiCardFrametime.Color := CardColor;
    FKpiCardPower.Color := CardColor;

    FKpiTitleAvgFps.Font.Color := IfThen(IsDark, RGBToColor(160, 175, 200), RGBToColor(100, 110, 130));
    FKpiTitleLows.Font.Color := FKpiTitleAvgFps.Font.Color;
    FKpiTitleFrametime.Font.Color := FKpiTitleAvgFps.Font.Color;
    FKpiTitlePower.Font.Color := FKpiTitleAvgFps.Font.Color;

    FKpiValAvgFps.Font.Color := AccentColor;
    FKpiValLows.Font.Color := TextColor;
    FKpiValFrametime.Font.Color := TextColor;
    FKpiValPower.Font.Color := TextColor;
  end;

  UpdateViewTabButtons;
  UpdateRunChipStyles;
  UpdateKpiHeroCards;
end;

procedure TPasPlotPanel.KpiContainerResize(Sender: TObject);
var
  W, H, Gap, TotalW: Integer;
begin
  if not Assigned(FKpiContainerPanel) or not Assigned(FKpiCardAvgFps) then Exit;
  Gap := 8;
  TotalW := FKpiContainerPanel.ClientWidth - (Gap * 3);
  if TotalW <= 0 then Exit;
  W := TotalW div 4;
  H := FKpiContainerPanel.ClientHeight;
  FKpiCardAvgFps.SetBounds(0, 0, W, H);
  FKpiCardLows.SetBounds(W + Gap, 0, W, H);
  FKpiCardFrametime.SetBounds((W + Gap) * 2, 0, W, H);
  FKpiCardPower.SetBounds((W + Gap) * 3, 0, FKpiContainerPanel.ClientWidth - ((W + Gap) * 3), H);
end;

procedure TPasPlotPanel.UpdateKpiHeroCards;
var
  RunCount: Integer;
  R, Base: TGplotRunData;
  DeltaPct, LowDeltaPct: Double;
  DeltaSign: string;
  IsDark: Boolean;
  AccentColor, SuccessColor, MutedColor, HighColor: TColor;
begin
  if not Assigned(FKpiCardAvgFps) then Exit;
  RunCount := Length(FLoadedRuns);
  IsDark := (CurrentTheme <> tmLight);
  AccentColor := IfThen(IsDark, RGBToColor(48, 190, 240), RGBToColor(25, 118, 210));
  SuccessColor := IfThen(IsDark, RGBToColor(100, 215, 110), RGBToColor(40, 160, 50));
  MutedColor := IfThen(IsDark, RGBToColor(150, 162, 185), RGBToColor(110, 120, 138));
  HighColor := IfThen(IsDark, RGBToColor(245, 200, 80), RGBToColor(200, 140, 20));

  if RunCount = 0 then
  begin
    FKpiValAvgFps.Caption := '-';
    FKpiValAvgFps.Font.Color := MutedColor;
    FKpiSubAvgFps.Caption := 'No run selected';
    FKpiSubAvgFps.Font.Color := MutedColor;

    FKpiValLows.Caption := '-';
    FKpiValLows.Font.Color := MutedColor;
    FKpiSubLows.Caption := 'Stability metrics';
    FKpiSubLows.Font.Color := MutedColor;

    FKpiValFrametime.Caption := '-';
    FKpiValFrametime.Font.Color := MutedColor;
    FKpiSubFrametime.Caption := 'Target pacing';
    FKpiSubFrametime.Font.Color := MutedColor;

    FKpiValPower.Caption := '-';
    FKpiValPower.Font.Color := MutedColor;
    FKpiSubPower.Caption := 'GPU Power & Temp';
    FKpiSubPower.Font.Color := MutedColor;
    Exit;
  end;

  if RunCount = 1 then
  begin
    R := FLoadedRuns[0];
    FKpiValAvgFps.Caption := Format('%.1f FPS', [R.AvgFps]);
    FKpiValAvgFps.Font.Color := AccentColor;
    FKpiSubAvgFps.Caption := 'Single run baseline';
    FKpiSubAvgFps.Font.Color := MutedColor;

    FKpiValLows.Caption := Format('%.1f / %.1f', [R.Fps1Low, R.Fps01Low]);
    FKpiValLows.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    if (R.AvgFps > 0) and (R.Fps1Low / R.AvgFps >= 0.70) then
    begin
      FKpiSubLows.Caption := 'Smooth frame pacing';
      FKpiSubLows.Font.Color := SuccessColor;
    end
    else
    begin
      FKpiSubLows.Caption := 'Noticeable stutter variance';
      FKpiSubLows.Font.Color := HighColor;
    end;

    FKpiValFrametime.Caption := Format('%.2f ms', [R.AvgFrametimeMs]);
    FKpiValFrametime.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    if R.AvgFrametimeMs <= 7.0 then
      FKpiSubFrametime.Caption := '144Hz Pacing (~6.9ms)'
    else if R.AvgFrametimeMs <= 8.5 then
      FKpiSubFrametime.Caption := '120Hz Pacing (~8.3ms)'
    else if R.AvgFrametimeMs <= 16.8 then
      FKpiSubFrametime.Caption := '60Hz Pacing (~16.6ms)'
    else
      FKpiSubFrametime.Caption := 'Frametime variance';
    FKpiSubFrametime.Font.Color := MutedColor;

    FKpiValPower.Caption := Format('%.0fW • %.0f°C', [R.AvgGpuPower, R.MaxGpuTemp]);
    FKpiValPower.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    FKpiSubPower.Caption := 'Avg GPU Power & Peak Temp';
    FKpiSubPower.Font.Color := MutedColor;
  end
  else
  begin
    Base := FLoadedRuns[0];
    R := FLoadedRuns[High(FLoadedRuns)];

    FKpiValAvgFps.Caption := Format('%.1f FPS', [R.AvgFps]);
    FKpiValAvgFps.Font.Color := AccentColor;
    if Base.AvgFps > 0 then
    begin
      DeltaPct := ((R.AvgFps - Base.AvgFps) / Base.AvgFps) * 100.0;
      if DeltaPct >= 0 then
      begin
        DeltaSign := '+';
        FKpiSubAvgFps.Font.Color := SuccessColor;
      end
      else
      begin
        DeltaSign := '';
        FKpiSubAvgFps.Font.Color := RGBToColor(230, 80, 80);
      end;
      FKpiSubAvgFps.Caption := Format('%s%.1f%% vs Baseline (%s)', [DeltaSign, DeltaPct, Base.DisplayName]);
    end
    else
    begin
      FKpiSubAvgFps.Caption := 'Compared to baseline';
      FKpiSubAvgFps.Font.Color := MutedColor;
    end;

    FKpiValLows.Caption := Format('%.1f / %.1f', [R.Fps1Low, R.Fps01Low]);
    FKpiValLows.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    if Base.Fps1Low > 0 then
    begin
      LowDeltaPct := ((R.Fps1Low - Base.Fps1Low) / Base.Fps1Low) * 100.0;
      if LowDeltaPct >= 0 then
        DeltaSign := '+'
      else
        DeltaSign := '';
      FKpiSubLows.Caption := Format('1%% Low: %s%.1f%% vs Base', [DeltaSign, LowDeltaPct]);
    end
    else
      FKpiSubLows.Caption := '1% & 0.1% Low FPS';
    FKpiSubLows.Font.Color := MutedColor;

    FKpiValFrametime.Caption := Format('%.2f ms', [R.AvgFrametimeMs]);
    FKpiValFrametime.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    FKpiSubFrametime.Caption := Format('Baseline: %.2f ms', [Base.AvgFrametimeMs]);
    FKpiSubFrametime.Font.Color := MutedColor;

    FKpiValPower.Caption := Format('%.0fW • %.0f°C', [R.AvgGpuPower, R.MaxGpuTemp]);
    FKpiValPower.Font.Color := IfThen(IsDark, RGBToColor(235, 240, 248), RGBToColor(25, 30, 40));
    FKpiSubPower.Caption := Format('Base: %.0fW • %.0f°C', [Base.AvgGpuPower, Base.MaxGpuTemp]);
    FKpiSubPower.Font.Color := MutedColor;
  end;
end;

procedure TPasPlotPanel.RunCheckListDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Box: TCheckListBox;
  ACanvas: TCanvas;
  IsDark, IsChecked, IsSelected: Boolean;
  BgColor, CardBorder, TextColor, MutedColor, SeriesColor: TColor;
  CheckedCount, CheckedRank, I: Integer;
  BadgeLeft, TextLeft, DotY: Integer;
  RunData: TGplotRunData;
  TitleStr, SubStr: string;
begin
  Box := TCheckListBox(Control);
  ACanvas := Box.Canvas;
  IsDark := (CurrentTheme <> tmLight);
  IsSelected := (odSelected in State);
  IsChecked := (Index >= 0) and (Index < Box.Items.Count) and Box.Checked[Index];

  if IsDark then
  begin
    if IsSelected then
      BgColor := RGBToColor(42, 52, 78)
    else
      BgColor := RGBToColor(28, 34, 50);
    CardBorder := RGBToColor(38, 46, 68);
    TextColor := RGBToColor(235, 240, 248);
    MutedColor := RGBToColor(150, 162, 185);
  end
  else
  begin
    if IsSelected then
      BgColor := RGBToColor(220, 230, 245)
    else
      BgColor := RGBToColor(255, 255, 255);
    CardBorder := RGBToColor(225, 230, 240);
    TextColor := RGBToColor(25, 30, 40);
    MutedColor := RGBToColor(110, 120, 138);
  end;

  // Background
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := BgColor;
  ACanvas.FillRect(ARect);

  // Bottom separator line
  ACanvas.Pen.Color := CardBorder;
  ACanvas.Line(ARect.Left, ARect.Bottom - 1, ARect.Right, ARect.Bottom - 1);

  if (Index < 0) or (Index >= Box.Items.Count) then Exit;

  // Determine series color based on checked rank
  CheckedCount := 0;
  CheckedRank := -1;
  for I := 0 to Box.Items.Count - 1 do
  begin
    if Box.Checked[I] then
    begin
      if I = Index then CheckedRank := CheckedCount;
      Inc(CheckedCount);
    end;
  end;

  if CheckedRank >= 0 then
    SeriesColor := SERIES_COLORS[CheckedRank mod Length(SERIES_COLORS)]
  else
    SeriesColor := MutedColor;

  // Offset allowing space for checkbox
  BadgeLeft := ARect.Left + 24;
  DotY := ARect.Top + 10;

  // Draw series indicator circle
  ACanvas.Brush.Color := SeriesColor;
  ACanvas.Pen.Color := SeriesColor;
  if IsChecked then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Ellipse(BadgeLeft, DotY, BadgeLeft + 10, DotY + 10);
  end
  else
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Ellipse(BadgeLeft, DotY, BadgeLeft + 10, DotY + 10);
  end;

  TextLeft := BadgeLeft + 16;
  if (Index >= 0) and (Index < Length(FDiscoveredRuns)) then
    RunData := FDiscoveredRuns[Index]
  else
    RunData := Default(TGplotRunData);

  TitleStr := RunData.DisplayName;
  if TitleStr = '' then TitleStr := Box.Items[Index];

  // Title: Date / Timestamp
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := TextColor;
  ACanvas.TextOut(TextLeft, ARect.Top + 6, TitleStr);

  // Baseline badge if checked rank is 0
  if CheckedRank = 0 then
  begin
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := IfThen(IsDark, RGBToColor(48, 190, 240), RGBToColor(25, 118, 210));
    ACanvas.TextOut(TextLeft + ACanvas.TextWidth(TitleStr) + 8, ARect.Top + 7, '[Baseline]');
  end;

  // Subtitle chips: timestamp (when renamed), Duration, Avg FPS, Power in Watts
  if RunData.CustomName <> '' then
    SubStr := Format('%s • %.0fs • %.0f FPS', [
      FormatRunTimestampFromFileName(RunData.FileName),
      RunData.DurationSec,
      RunData.AvgFps
    ])
  else
    SubStr := Format('%.0fs • %.0f FPS', [RunData.DurationSec, RunData.AvgFps]);
  if RunData.AvgGpuPower > 0 then
    SubStr := SubStr + Format(' • %.0fW', [RunData.AvgGpuPower]);

  ACanvas.Font.Size := 8;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := MutedColor;
  ACanvas.TextOut(TextLeft, ARect.Top + 28, SubStr);
end;

procedure TPasPlotPanel.SetViewMode(AValue: TGplotViewMode);
begin
  if FViewMode = AValue then Exit;
  FViewMode := AValue;
  if Assigned(FStatsPanel) and Assigned(FChartContainerPanel) then
  begin
    if FViewMode = gvmTable then
    begin
      FChartContainerPanel.Visible := False;
      FStatsPanel.Visible := True;
      FStatsPanel.Align := alClient;
    end
    else
    begin
      FStatsPanel.Visible := False;
      FChartContainerPanel.Visible := True;
      FChartContainerPanel.Align := alClient;
    end;
  end;
  UpdateViewTabButtons;
  FChartPaintBox.Invalidate;
end;

procedure TPasPlotPanel.UpdateViewTabButtons;
var
  IsDark: Boolean;
  ActiveBg, InactiveBg, ActiveText, InactiveText: TColor;

  procedure ApplyPillStyle(ABtn: TBitBtn; AActive: Boolean);
  {$IFDEF LCLqt6}
  var
    SS: WideString;
  {$ENDIF}
  {$IFDEF LCLqt5}
  var
    SS: WideString;
  {$ENDIF}
  begin
    if not Assigned(ABtn) then Exit;
    if AActive then
    begin
      ABtn.Font.Style := [fsBold];
      ABtn.Color := ActiveBg;
      ABtn.Font.Color := ActiveText;
    end
    else
    begin
      ABtn.Font.Style := [];
      ABtn.Color := InactiveBg;
      ABtn.Font.Color := InactiveText;
    end;
    {$IFDEF LCLqt6}
    if ABtn.HandleAllocated then
    begin
      if AActive then
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(48,190,240); color: rgb(20,24,36); border: 1px solid rgb(48,190,240); border-radius: 6px; padding: 2px 10px; font-weight: bold; }'
        else
          SS := 'QPushButton { background-color: rgb(25,118,210); color: rgb(255,255,255); border: 1px solid rgb(25,118,210); border-radius: 6px; padding: 2px 10px; font-weight: bold; }';
      end
      else
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(36,44,66); color: rgb(200,210,230); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px 10px; } QPushButton:hover { background-color: rgb(48,58,88); color: rgb(255,255,255); }'
        else
          SS := 'QPushButton { background-color: rgb(230,235,245); color: rgb(50,60,75); border: 1px solid rgb(200,210,225); border-radius: 6px; padding: 2px 10px; } QPushButton:hover { background-color: rgb(215,222,236); }';
      end;
      QWidget_setStyleSheet(TQtWidget(ABtn.Handle).Widget, @SS);
    end;
    {$ENDIF}
    {$IFDEF LCLqt5}
    if ABtn.HandleAllocated then
    begin
      if AActive then
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(48,190,240); color: rgb(20,24,36); border: 1px solid rgb(48,190,240); border-radius: 6px; padding: 2px 10px; font-weight: bold; }'
        else
          SS := 'QPushButton { background-color: rgb(25,118,210); color: rgb(255,255,255); border: 1px solid rgb(25,118,210); border-radius: 6px; padding: 2px 10px; font-weight: bold; }';
      end
      else
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(36,44,66); color: rgb(200,210,230); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px 10px; } QPushButton:hover { background-color: rgb(48,58,88); color: rgb(255,255,255); }'
        else
          SS := 'QPushButton { background-color: rgb(230,235,245); color: rgb(50,60,75); border: 1px solid rgb(200,210,225); border-radius: 6px; padding: 2px 10px; } QPushButton:hover { background-color: rgb(215,222,236); }';
      end;
      QWidget_setStyleSheet(TQtWidget(ABtn.Handle).Widget, @SS);
    end;
    {$ENDIF}
  end;

begin
  IsDark := (CurrentTheme <> tmLight);
  if IsDark then
  begin
    ActiveBg := RGBToColor(48, 190, 240);
    ActiveText := RGBToColor(20, 24, 36);
    InactiveBg := RGBToColor(36, 44, 66);
    InactiveText := RGBToColor(200, 210, 230);
  end
  else
  begin
    ActiveBg := RGBToColor(25, 118, 210);
    ActiveText := clWhite;
    InactiveBg := RGBToColor(230, 235, 245);
    InactiveText := RGBToColor(50, 60, 75);
  end;

  ApplyPillStyle(FResumeTabBtn, FViewMode = gvmResume);
  ApplyPillStyle(FTimelineTabBtn, FViewMode = gvmTimeline);
  ApplyPillStyle(FSummaryTabBtn, FViewMode = gvmSummary);
  ApplyPillStyle(FHardwareTabBtn, FViewMode = gvmHardware);
  ApplyPillStyle(FTableTabBtn, FViewMode = gvmTable);
end;

procedure TPasPlotPanel.RefreshGamesAndRuns(const APreferredGame: string);
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

function TPasPlotPanel.GetActiveGameLogFolder: string;
var
  LogsRoot: string;
begin
  LogsRoot := IncludeTrailingPathDelimiter(FBaseDataDir) + 'logs' + PathDelim;
  if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
    Result := LogsRoot + FGameComboBox.Items[FGameComboBox.ItemIndex] + PathDelim
  else
    Result := LogsRoot;
end;

procedure TPasPlotPanel.LoadRunsForSelectedGame;
var
  GameLogDir: string;
  SR: TSearchRec;
  FileList: TStringList;
  I: Integer;
  RunData: TGplotRunData;
  ItemCaption: string;
begin
  FDiscoveredFiles.Clear;
  SetLength(FDiscoveredRuns, 0);
  FRunCheckListBox.Items.Clear;
  SetLength(FLoadedRuns, 0);

  if (FGameComboBox.ItemIndex < 0) or (FGameComboBox.ItemIndex >= FGameComboBox.Items.Count) then
  begin
    UpdateStatsGridAndSpecs;
    UpdateKpiHeroCards;
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
        RunData.CustomName := ReadBenchmarkCustomName(GameLogDir, RunData.FileName);
        if Trim(RunData.CustomName) <> '' then
          RunData.DisplayName := Trim(RunData.CustomName)
        else
          RunData.DisplayName := FormatRunTimestampFromFileName(RunData.FileName);
        FDiscoveredFiles.Add(FileList[I]);
        SetLength(FDiscoveredRuns, Length(FDiscoveredRuns) + 1);
        FDiscoveredRuns[High(FDiscoveredRuns)] := RunData;
        ItemCaption := Format('%s  (%.0fs • %.0f FPS)', [
          RunData.DisplayName,
          RunData.DurationSec,
          RunData.AvgFps
        ]);
        FRunCheckListBox.Items.Add(ItemCaption);
      end;
    end;

    for I := 0 to FRunCheckListBox.Items.Count - 1 do
      FRunCheckListBox.Checked[I] := True;
    if FRunCheckListBox.Items.Count > 0 then
      FRunCheckListBox.ItemIndex := 0;
  finally
    FileList.Free;
  end;

  RebuildRunChips;
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.RebuildRunChips;
var
  I, X, TextW, ChipW: Integer;
  Pill, EditBtn, DelBtn: TBitBtn;
  CapStr: string;
  MeasureBmp: TBitmap;
begin
  if not Assigned(FRunsChipScroll) then Exit;
  for I := 0 to High(FRunChipBtns) do
    if Assigned(FRunChipBtns[I]) then
    begin
      FRunChipBtns[I].Visible := False;
      Application.ReleaseComponent(FRunChipBtns[I]);
      FRunChipBtns[I] := nil;
    end;
  for I := 0 to High(FRunChipEditBtns) do
    if Assigned(FRunChipEditBtns[I]) then
    begin
      FRunChipEditBtns[I].Visible := False;
      Application.ReleaseComponent(FRunChipEditBtns[I]);
      FRunChipEditBtns[I] := nil;
    end;
  for I := 0 to High(FRunChipDelBtns) do
    if Assigned(FRunChipDelBtns[I]) then
    begin
      FRunChipDelBtns[I].Visible := False;
      Application.ReleaseComponent(FRunChipDelBtns[I]);
      FRunChipDelBtns[I] := nil;
    end;
  SetLength(FRunChipBtns, FRunCheckListBox.Items.Count);
  SetLength(FRunChipEditBtns, FRunCheckListBox.Items.Count);
  SetLength(FRunChipDelBtns, FRunCheckListBox.Items.Count);

  MeasureBmp := TBitmap.Create;
  try
    MeasureBmp.SetSize(1, 1);
    MeasureBmp.Canvas.Font.Assign(FRunsChipScroll.Font);
    MeasureBmp.Canvas.Font.Size := 8;
    MeasureBmp.Canvas.Font.Style := [fsBold];

    X := 8;
    for I := 0 to FRunCheckListBox.Items.Count - 1 do
    begin
      if (I >= 0) and (I < Length(FDiscoveredRuns)) then
        CapStr := Format('%s (%.0f FPS)', [FDiscoveredRuns[I].DisplayName, FDiscoveredRuns[I].AvgFps])
      else
        CapStr := FRunCheckListBox.Items[I];

      TextW := MeasureBmp.Canvas.TextWidth(CapStr);
      ChipW := Max(115, 10 + TextW + 48);

      Pill := TBitBtn.Create(FRunsChipScroll);
      Pill.Parent := FRunsChipScroll;
      Pill.Tag := I;
      Pill.Caption := CapStr;
      Pill.Font.Size := 8;
      Pill.SetBounds(X, 7, ChipW, 28);
      Pill.Cursor := crHandPoint;
      Pill.PopupMenu := FRunPopupMenu;
      Pill.OnClick := @RunChipClick;
      Pill.OnMouseDown := @RunChipMouseDown;

      EditBtn := TBitBtn.Create(FRunsChipScroll);
      EditBtn.Parent := FRunsChipScroll;
      EditBtn.Tag := I;
      EditBtn.SetBounds(X + ChipW - 44, 10, 20, 22);
      EditBtn.Caption := '✎';
      EditBtn.Font.Size := 9;
      EditBtn.Hint := 'Rename benchmark';
      EditBtn.ShowHint := True;
      EditBtn.Cursor := crHandPoint;
      EditBtn.OnClick := @RunChipRenameClick;
      EditBtn.BringToFront;

      DelBtn := TBitBtn.Create(FRunsChipScroll);
      DelBtn.Parent := FRunsChipScroll;
      DelBtn.Tag := I;
      DelBtn.SetBounds(X + ChipW - 23, 10, 20, 22);
      DelBtn.Caption := '✕';
      DelBtn.Font.Size := 8;
      DelBtn.Hint := 'Delete benchmark';
      DelBtn.ShowHint := True;
      DelBtn.Cursor := crHandPoint;
      DelBtn.OnClick := @RunChipDeleteClick;
      DelBtn.BringToFront;

      FRunChipBtns[I] := Pill;
      FRunChipEditBtns[I] := EditBtn;
      FRunChipDelBtns[I] := DelBtn;
      Inc(X, ChipW + 6);
    end;
  finally
    MeasureBmp.Free;
  end;
  UpdateRunChipStyles;
end;

procedure TPasPlotPanel.UpdateRunChipStyles;
var
  I, CheckedRank: Integer;
  IsDark, IsChecked, IsFocused: Boolean;
  SeriesColor: TColor;
  RVal, GVal, BVal: Byte;
  {$IFDEF LCLqt6}
  SS, BtnSS, DelSS: WideString;
  {$ENDIF}
  {$IFDEF LCLqt5}
  SS, BtnSS, DelSS: WideString;
  {$ENDIF}
begin
  IsDark := (CurrentTheme <> tmLight);
  CheckedRank := 0;
  for I := 0 to High(FRunChipBtns) do
  begin
    if not Assigned(FRunChipBtns[I]) then Continue;
    IsChecked := (I < FRunCheckListBox.Items.Count) and FRunCheckListBox.Checked[I];
    IsFocused := (I = FRunCheckListBox.ItemIndex);
    if IsChecked then
    begin
      SeriesColor := SERIES_COLORS[CheckedRank mod Length(SERIES_COLORS)];
      Inc(CheckedRank);
    end
    else
      SeriesColor := IfThen(IsDark, RGBToColor(90, 100, 125), RGBToColor(150, 160, 175));

    RVal := Red(SeriesColor);
    GVal := Green(SeriesColor);
    BVal := Blue(SeriesColor);

    if IsChecked then
      FRunChipBtns[I].Font.Style := [fsBold]
    else
      FRunChipBtns[I].Font.Style := [];

    {$IFDEF LCLqt6}
    if FRunChipBtns[I].HandleAllocated then
    begin
      if IsChecked then
      begin
        if IsDark then
          SS := Format('QPushButton { background-color: rgb(32,40,62); color: rgb(235,240,248); border: %dpx solid rgb(%d,%d,%d); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; font-weight: bold; }',
            [IfThen(IsFocused, 2, 1), RVal, GVal, BVal])
        else
          SS := Format('QPushButton { background-color: rgb(255,255,255); color: rgb(25,30,40); border: %dpx solid rgb(%d,%d,%d); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; font-weight: bold; }',
            [IfThen(IsFocused, 2, 1), RVal, GVal, BVal]);
      end
      else
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(24,29,44); color: rgb(140,150,170); border: 1px solid rgb(45,54,78); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; }'
        else
          SS := 'QPushButton { background-color: rgb(235,238,245); color: rgb(110,120,135); border: 1px solid rgb(205,212,224); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; }';
      end;
      QWidget_setStyleSheet(TQtWidget(FRunChipBtns[I].Handle).Widget, @SS);

      if IsDark then
      begin
        BtnSS := 'QPushButton { background-color: transparent; color: rgb(180,192,215); border: none; border-radius: 11px; padding: 0px; } QPushButton:hover { background-color: rgb(52,65,98); color: rgb(255,255,255); }';
        DelSS := 'QPushButton { background-color: transparent; color: rgb(180,192,215); border: none; border-radius: 11px; padding: 0px; } QPushButton:hover { background-color: rgb(170,55,65); color: rgb(255,255,255); }';
      end
      else
      begin
        BtnSS := 'QPushButton { background-color: transparent; color: rgb(90,100,120); border: none; border-radius: 11px; padding: 0px; } QPushButton:hover { background-color: rgb(220,226,238); color: rgb(20,25,35); }';
        DelSS := 'QPushButton { background-color: transparent; color: rgb(90,100,120); border: none; border-radius: 11px; padding: 0px; } QPushButton:hover { background-color: rgb(210,60,70); color: rgb(255,255,255); }';
      end;
      if (I <= High(FRunChipEditBtns)) and Assigned(FRunChipEditBtns[I]) and FRunChipEditBtns[I].HandleAllocated then
        QWidget_setStyleSheet(TQtWidget(FRunChipEditBtns[I].Handle).Widget, @BtnSS);
      if (I <= High(FRunChipDelBtns)) and Assigned(FRunChipDelBtns[I]) and FRunChipDelBtns[I].HandleAllocated then
        QWidget_setStyleSheet(TQtWidget(FRunChipDelBtns[I].Handle).Widget, @DelSS);
    end;
    {$ENDIF}
    {$IFDEF LCLqt5}
    if FRunChipBtns[I].HandleAllocated then
    begin
      if IsChecked then
      begin
        if IsDark then
          SS := Format('QPushButton { background-color: rgb(32,40,62); color: rgb(235,240,248); border: %dpx solid rgb(%d,%d,%d); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; font-weight: bold; }',
            [IfThen(IsFocused, 2, 1), RVal, GVal, BVal])
        else
          SS := Format('QPushButton { background-color: rgb(255,255,255); color: rgb(25,30,40); border: %dpx solid rgb(%d,%d,%d); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; font-weight: bold; }',
            [IfThen(IsFocused, 2, 1), RVal, GVal, BVal]);
      end
      else
      begin
        if IsDark then
          SS := 'QPushButton { background-color: rgb(24,29,44); color: rgb(140,150,170); border: 1px solid rgb(45,54,78); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; }'
        else
          SS := 'QPushButton { background-color: rgb(235,238,245); color: rgb(110,120,135); border: 1px solid rgb(205,212,224); border-radius: 14px; padding: 2px 46px 2px 10px; text-align: left; }';
      end;
      QWidget_setStyleSheet(TQtWidget(FRunChipBtns[I].Handle).Widget, @SS);
    end;
    {$ENDIF}
  end;
end;

procedure TPasPlotPanel.RunChipClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx < 0) or (Idx >= FRunCheckListBox.Items.Count) then Exit;
  FRunCheckListBox.ItemIndex := Idx;
  FRunCheckListBox.Checked[Idx] := not FRunCheckListBox.Checked[Idx];
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.RunChipMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx >= 0) and (Idx < FRunCheckListBox.Items.Count) then
  begin
    FRunCheckListBox.ItemIndex := Idx;
    UpdateRunChipStyles;
  end;
end;

procedure TPasPlotPanel.RunChipRenameClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx >= 0) and (Idx < FRunCheckListBox.Items.Count) then
  begin
    FRunCheckListBox.ItemIndex := Idx;
    PromptRenameBenchmark(Idx);
  end;
end;

procedure TPasPlotPanel.RunChipDeleteClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx >= 0) and (Idx < FRunCheckListBox.Items.Count) then
  begin
    FRunCheckListBox.ItemIndex := Idx;
    DeleteRunClick(nil);
  end;
end;

procedure TPasPlotPanel.ReloadCheckedRunsData;
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
        if (I >= 0) and (I < Length(FDiscoveredRuns)) then
        begin
          RunData.CustomName := FDiscoveredRuns[I].CustomName;
          RunData.DisplayName := FDiscoveredRuns[I].DisplayName;
        end;
        SetLength(FLoadedRuns, Count + 1);
        FLoadedRuns[Count] := RunData;
        Inc(Count);
      end;
    end;
  end;

  UpdateStatsGridAndSpecs;
  UpdateKpiHeroCards;
  UpdateRunChipStyles;
  FRunCheckListBox.Invalidate;
  FChartPaintBox.Invalidate;
end;

procedure TPasPlotPanel.UpdateStatsGridAndSpecs;
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

function TPasPlotPanel.SelectedRunCount: Integer;
begin
  Result := Length(FLoadedRuns);
end;

procedure TPasPlotPanel.GameComboChange(Sender: TObject);
begin
  LoadRunsForSelectedGame;
end;

procedure TPasPlotPanel.RunCheckListClickCheck(Sender: TObject);
begin
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.RunCheckListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  Idx := FRunCheckListBox.ItemAtPos(Point(X, Y), True);
  if (Idx < 0) and (FRunCheckListBox.ItemHeight > 0) then
    Idx := FRunCheckListBox.TopIndex + (Y div FRunCheckListBox.ItemHeight);
  if (Idx < 0) or (Idx >= FRunCheckListBox.Items.Count) then Exit;

  if Button = mbRight then
  begin
    FRunCheckListBox.ItemIndex := Idx;
    Exit;
  end;

  if Button = mbLeft then
  begin
    FRunCheckListBox.ItemIndex := Idx;
    if ssDouble in Shift then
    begin
      if X >= 20 then
      begin
        FRunCheckListBox.Checked[Idx] := not FRunCheckListBox.Checked[Idx];
        ReloadCheckedRunsData;
      end;
      Exit;
    end;

    if X >= 20 then
    begin
      FRunCheckListBox.Checked[Idx] := not FRunCheckListBox.Checked[Idx];
      ReloadCheckedRunsData;
    end;
  end;
end;

procedure TPasPlotPanel.RunCheckListDblClick(Sender: TObject);
begin
  if FRunCheckListBox.ItemIndex >= 0 then
    PromptRenameBenchmark(FRunCheckListBox.ItemIndex);
end;

procedure TPasPlotPanel.RunCheckListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F2 then
  begin
    if FRunCheckListBox.ItemIndex >= 0 then
      PromptRenameBenchmark(FRunCheckListBox.ItemIndex);
    Key := 0;
  end;
end;

procedure TPasPlotPanel.SelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FRunCheckListBox.Items.Count - 1 do
    FRunCheckListBox.Checked[I] := True;
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.ClearSelClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FRunCheckListBox.Items.Count - 1 do
    FRunCheckListBox.Checked[I] := False;
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.RefreshClick(Sender: TObject);
var
  CurrGame: string;
begin
  CurrGame := '';
  if (FGameComboBox.ItemIndex >= 0) and (FGameComboBox.ItemIndex < FGameComboBox.Items.Count) then
    CurrGame := FGameComboBox.Items[FGameComboBox.ItemIndex];
  RefreshGamesAndRuns(CurrGame);
end;

procedure TPasPlotPanel.OpenFolderClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := GetActiveGameLogFolder;
  if not DirectoryExists(Folder) then
    ForceDirectories(Folder);
  OpenDocument(Folder);
end;

procedure TPasPlotPanel.RenameRunClick(Sender: TObject);
begin
  if FRunCheckListBox.ItemIndex >= 0 then
    PromptRenameBenchmark(FRunCheckListBox.ItemIndex);
end;

procedure TPasPlotPanel.PopupRenameClick(Sender: TObject);
begin
  RenameRunClick(Sender);
end;

procedure TPasPlotPanel.PopupDeleteClick(Sender: TObject);
begin
  DeleteRunClick(Sender);
end;

procedure TPasPlotPanel.PromptRenameBenchmark(AIndex: Integer);
var
  NewName: string;
begin
  if (AIndex < 0) or (AIndex >= Length(FDiscoveredRuns)) then Exit;

  NewName := FDiscoveredRuns[AIndex].DisplayName;
  if not InputQuery('Rename Benchmark',
    'Enter benchmark label (leave empty to restore timestamp):', NewName) then
    Exit;

  WriteBenchmarkCustomName(GetActiveGameLogFolder,
    FDiscoveredRuns[AIndex].FileName, NewName);

  if Trim(NewName) = '' then
  begin
    FDiscoveredRuns[AIndex].CustomName := '';
    FDiscoveredRuns[AIndex].DisplayName :=
      FormatRunTimestampFromFileName(FDiscoveredRuns[AIndex].FileName);
  end
  else
  begin
    FDiscoveredRuns[AIndex].CustomName := Trim(NewName);
    FDiscoveredRuns[AIndex].DisplayName := Trim(NewName);
  end;

  if AIndex < FRunCheckListBox.Items.Count then
    FRunCheckListBox.Items[AIndex] := Format('%s  (%.0fs • %.0f FPS)', [
      FDiscoveredRuns[AIndex].DisplayName,
      FDiscoveredRuns[AIndex].DurationSec,
      FDiscoveredRuns[AIndex].AvgFps
    ]);

  RebuildRunChips;
  ReloadCheckedRunsData;
end;

procedure TPasPlotPanel.DeleteRunClick(Sender: TObject);
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
      DeleteBenchmarkCustomName(GetActiveGameLogFolder, ExtractFileName(FilePath));
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

procedure TPasPlotPanel.ExportPngClick(Sender: TObject);
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

procedure TPasPlotPanel.ViewTabBtnClick(Sender: TObject);
begin
  if Sender is TControl then
    SetViewMode(TGplotViewMode(TControl(Sender).Tag));
end;

procedure TPasPlotPanel.ChartPaintBoxPaint(Sender: TObject);
begin
  RenderChartToCanvas(FChartPaintBox.Canvas, FChartPaintBox.Width, FChartPaintBox.Height);
end;

procedure TPasPlotPanel.ChartPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FHoverX := X;
  FHoverY := Y;
  FHoverActive := True;
  FChartPaintBox.Invalidate;
end;

procedure TPasPlotPanel.ChartPaintBoxMouseLeave(Sender: TObject);
begin
  FHoverActive := False;
  FChartPaintBox.Invalidate;
end;

procedure TPasPlotPanel.RenderChartToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer);
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

    if (Length(FLoadedRuns) > 1) and (I = 0) then
      LegendText := Format('%s (Avg %.0f FPS) [Baseline]', [FLoadedRuns[I].DisplayName, FLoadedRuns[I].AvgFps])
    else
      LegendText := Format('%s (Avg %.0f FPS)', [FLoadedRuns[I].DisplayName, FLoadedRuns[I].AvgFps]);
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Color := TextColor;
    ACanvas.TextOut(LegendX, LegendY, LegendText);
    Inc(LegendX, ACanvas.TextWidth(LegendText) + 20);
    if LegendX > AWidth - 180 then Break;
  end;

  PlotRect := Rect(64, 36, AWidth - 20, AHeight - 28);
  case FViewMode of
    gvmResume:   DrawResumeView(ACanvas, Rect(14, 34, AWidth - 14, AHeight - 12), IsDark);
    gvmTimeline: DrawTimelineView(ACanvas, PlotRect, IsDark);
    gvmSummary:  DrawSummaryView(ACanvas, PlotRect, IsDark);
    gvmHardware: DrawHardwareView(ACanvas, PlotRect, IsDark);
  end;
end;

procedure TPasPlotPanel.DrawResumeView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
var
  Gap, LeftW, MidY: Integer;
  LeftCard, TopRightCard, BotRightCard, InnerTimeline: TRect;
  CardBg, CardBorder, TextColor, MutedColor: TColor;
  MaxFpsVal, Val, BaseVal, Delta, MaxPwr: Double;
  RIdx, MIdx, Y, BarTop, BarH, BarLeft, MaxBarW, BarRight: Integer;
  LabelStr, ValStr: string;
begin
  if (ARect.Right <= ARect.Left + 180) or (ARect.Bottom <= ARect.Top + 120) then Exit;

  CardBg := IfThen(AIsDark, RGBToColor(30, 36, 54), RGBToColor(255, 255, 255));
  CardBorder := IfThen(AIsDark, RGBToColor(48, 58, 86), RGBToColor(215, 222, 234));
  TextColor := IfThen(AIsDark, RGBToColor(230, 236, 245), RGBToColor(30, 35, 45));
  MutedColor := IfThen(AIsDark, RGBToColor(150, 162, 185), RGBToColor(100, 110, 130));

  Gap := 10;
  LeftW := Round((ARect.Right - ARect.Left - Gap) * 0.56);
  MidY := ARect.Top + ((ARect.Bottom - ARect.Top - Gap) div 2);

  LeftCard := Rect(ARect.Left, ARect.Top, ARect.Left + LeftW, ARect.Bottom);
  TopRightCard := Rect(LeftCard.Right + Gap, ARect.Top, ARect.Right, MidY);
  BotRightCard := Rect(LeftCard.Right + Gap, MidY + Gap, ARect.Right, ARect.Bottom);

  // Draw 3 segmented card frames
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := CardBg;
  ACanvas.Pen.Color := CardBorder;
  ACanvas.RoundRect(LeftCard.Left, LeftCard.Top, LeftCard.Right, LeftCard.Bottom, 8, 8);
  ACanvas.RoundRect(TopRightCard.Left, TopRightCard.Top, TopRightCard.Right, TopRightCard.Bottom, 8, 8);
  ACanvas.RoundRect(BotRightCard.Left, BotRightCard.Top, BotRightCard.Right, BotRightCard.Bottom, 8, 8);

  // 1. Left Segment: Timeline (FPS & Frametime)
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := TextColor;
  ACanvas.TextOut(LeftCard.Left + 10, LeftCard.Top + 7, 'Timeline (FPS & Frametime)');

  InnerTimeline := Rect(LeftCard.Left + 50, LeftCard.Top + 26, LeftCard.Right - 10, LeftCard.Bottom - 22);
  DrawTimelineView(ACanvas, InnerTimeline, AIsDark);

  // 2. Top-Right Segment: Comparison (Avg FPS & 1% Low)
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := TextColor;
  ACanvas.TextOut(TopRightCard.Left + 10, TopRightCard.Top + 7, 'Comparison (Avg / 1% Low)');

  MaxFpsVal := 60.0;
  for RIdx := 0 to High(FLoadedRuns) do
    if FLoadedRuns[RIdx].AvgFps * 1.2 > MaxFpsVal then
      MaxFpsVal := FLoadedRuns[RIdx].AvgFps * 1.2;

  BarLeft := TopRightCard.Left + 10;
  MaxBarW := Max(60, (TopRightCard.Right - TopRightCard.Left) - 125);
  Y := TopRightCard.Top + 26;
  BarH := Max(8, Min(14, ((TopRightCard.Bottom - Y - 10) div 2 - 18) div Max(1, Length(FLoadedRuns))));

  for MIdx := 0 to 1 do
  begin
    if MIdx = 0 then LabelStr := 'Avg FPS' else LabelStr := '1% Low';
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := MutedColor;
    ACanvas.Brush.Style := bsClear;
    ACanvas.TextOut(BarLeft, Y, LabelStr);
    Inc(Y, 15);

    for RIdx := 0 to High(FLoadedRuns) do
    begin
      if Y + BarH > TopRightCard.Bottom - 4 then Break;
      if MIdx = 0 then
      begin
        Val := FLoadedRuns[RIdx].AvgFps;
        BaseVal := FLoadedRuns[0].AvgFps;
      end
      else
      begin
        Val := FLoadedRuns[RIdx].Fps1Low;
        BaseVal := FLoadedRuns[0].Fps1Low;
      end;

      BarRight := BarLeft + Round(EnsureRange(Val / MaxFpsVal, 0.0, 1.0) * MaxBarW);
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.RoundRect(BarLeft, Y, Max(BarLeft + 4, BarRight), Y + BarH, 4, 4);

      if (Length(FLoadedRuns) > 1) and (RIdx > 0) and (BaseVal > 0) then
      begin
        Delta := ((Val - BaseVal) / BaseVal) * 100.0;
        if Delta >= 0 then
          ValStr := Format('%.1f (+%.0f%%)', [Val, Delta])
        else
          ValStr := Format('%.1f (%.0f%%)', [Val, Delta]);
      end
      else if (Length(FLoadedRuns) > 1) and (RIdx = 0) then
        ValStr := Format('%.1f [Baseline]', [Val])
      else
        ValStr := Format('%.1f FPS', [Val]);

      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Size := 8;
      ACanvas.Font.Style := [];
      ACanvas.Font.Color := TextColor;
      ACanvas.TextOut(Max(BarLeft + 8, BarRight + 6), Y - 1, ValStr);
      Inc(Y, BarH + 3);
    end;
    Inc(Y, 4);
  end;

  // 3. Bottom-Right Segment: Hardware Telemetry (GPU / CPU / Temp / Power)
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := TextColor;
  ACanvas.TextOut(BotRightCard.Left + 10, BotRightCard.Top + 7, 'Telemetry (GPU / CPU)');

  MaxPwr := 150.0;
  for RIdx := 0 to High(FLoadedRuns) do
    if FLoadedRuns[RIdx].AvgGpuPower * 1.2 > MaxPwr then
      MaxPwr := FLoadedRuns[RIdx].AvgGpuPower * 1.2;

  Y := BotRightCard.Top + 28;
  for RIdx := 0 to High(FLoadedRuns) do
  begin
    if Y + 26 > BotRightCard.Bottom - 4 then Break;
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.Ellipse(BotRightCard.Left + 10, Y + 3, BotRightCard.Left + 18, Y + 11);

    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := TextColor;
    if (Length(FLoadedRuns) > 1) and (RIdx = 0) then
      ACanvas.TextOut(BotRightCard.Left + 24, Y, FLoadedRuns[RIdx].DisplayName + ' [Baseline]')
    else
      ACanvas.TextOut(BotRightCard.Left + 24, Y, FLoadedRuns[RIdx].DisplayName);

    ACanvas.Font.Style := [];
    ACanvas.Font.Color := MutedColor;
    ValStr := Format('GPU %.0f%% • %.0f°C • %.0fW | CPU %.0f%%', [
      FLoadedRuns[RIdx].AvgGpuLoad,
      FLoadedRuns[RIdx].MaxGpuTemp,
      FLoadedRuns[RIdx].AvgGpuPower,
      FLoadedRuns[RIdx].AvgCpuLoad
    ]);
    ACanvas.TextOut(BotRightCard.Left + 24, Y + 13, ValStr);

    // Compact GPU load bar
    BarTop := Y + 27;
    MaxBarW := Max(60, (BotRightCard.Right - BotRightCard.Left) - 34);
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := IfThen(AIsDark, RGBToColor(42, 50, 74), RGBToColor(228, 234, 244));
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.RoundRect(BotRightCard.Left + 24, BarTop, BotRightCard.Left + 24 + MaxBarW, BarTop + 5, 3, 3);

    BarRight := BotRightCard.Left + 24 + Round(EnsureRange(FLoadedRuns[RIdx].AvgGpuLoad / 100.0, 0.0, 1.0) * MaxBarW);
    ACanvas.Brush.Color := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.RoundRect(BotRightCard.Left + 24, BarTop, Max(BotRightCard.Left + 27, BarRight), BarTop + 5, 3, 3);

    Inc(Y, 38);
  end;
end;

procedure TPasPlotPanel.DrawTimelineView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
var
  TopRect, BotRect: TRect;
  MidY, RIdx, SIdx, Step, X, Y, PrevX, PrevY: Integer;
  MaxDuration, MaxFpsVal, MaxFtVal: Double;
  GridColor, AxisColor, TextColor, FillColor: TColor;
  SeriesColor: TColor;
  Run: TGplotRunData;
  HoverSec: Double;
  BestIdx: Integer;
  BestDist, Dist: Double;
  TipStr: string;
  CardW, CardH, CardLeft, CardTop, RowY: Integer;
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

  // Refresh rate guide lines (60, 120, 144 FPS)
  ACanvas.Pen.Style := psDot;
  ACanvas.Font.Size := 7;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := IfThen(AIsDark, RGBToColor(110, 130, 170), RGBToColor(140, 150, 175));

  if (MaxFpsVal >= 60.0) and (60.0 < MaxFpsVal * 0.95) then
  begin
    Y := TopRect.Bottom - Round((60.0 / MaxFpsVal) * (TopRect.Bottom - TopRect.Top));
    if (Y >= TopRect.Top + 8) and (Y <= TopRect.Bottom - 8) then
    begin
      ACanvas.Pen.Color := IfThen(AIsDark, RGBToColor(60, 75, 105), RGBToColor(190, 200, 215));
      ACanvas.Line(TopRect.Left, Y, TopRect.Right, Y);
      ACanvas.TextOut(TopRect.Right - 42, Y - 9, '60 FPS');
    end;
  end;
  if (MaxFpsVal >= 120.0) and (120.0 < MaxFpsVal * 0.95) then
  begin
    Y := TopRect.Bottom - Round((120.0 / MaxFpsVal) * (TopRect.Bottom - TopRect.Top));
    if (Y >= TopRect.Top + 8) and (Y <= TopRect.Bottom - 8) then
    begin
      ACanvas.Pen.Color := IfThen(AIsDark, RGBToColor(60, 75, 105), RGBToColor(190, 200, 215));
      ACanvas.Line(TopRect.Left, Y, TopRect.Right, Y);
      ACanvas.TextOut(TopRect.Right - 48, Y - 9, '120 FPS');
    end;
  end;
  if (MaxFpsVal >= 144.0) and (144.0 < MaxFpsVal * 0.95) then
  begin
    Y := TopRect.Bottom - Round((144.0 / MaxFpsVal) * (TopRect.Bottom - TopRect.Top));
    if (Y >= TopRect.Top + 8) and (Y <= TopRect.Bottom - 8) then
    begin
      ACanvas.Pen.Color := IfThen(AIsDark, RGBToColor(60, 75, 105), RGBToColor(190, 200, 215));
      ACanvas.Line(TopRect.Left, Y, TopRect.Right, Y);
      ACanvas.TextOut(TopRect.Right - 48, Y - 9, '144 FPS');
    end;
  end;
  ACanvas.Pen.Style := psSolid;

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

  // Soft shaded area under the baseline/primary curve
  if Length(FLoadedRuns) > 0 then
  begin
    Run := FLoadedRuns[0];
    if Run.SampleCount > 1 then
    begin
      FillColor := IfThen(AIsDark, RGBToColor(28, 42, 60), RGBToColor(225, 235, 248));
      ACanvas.Pen.Color := FillColor;
      Step := Max(1, Run.SampleCount div Max(200, TopRect.Right - TopRect.Left));
      SIdx := 0;
      while SIdx < Run.SampleCount do
      begin
        X := TopRect.Left + Round((Run.Samples[SIdx].ElapsedSec / MaxDuration) * (TopRect.Right - TopRect.Left));
        Y := TopRect.Bottom - Round(EnsureRange(Run.Samples[SIdx].Fps / MaxFpsVal, 0.0, 1.0) * (TopRect.Bottom - TopRect.Top));
        if (X >= TopRect.Left) and (X <= TopRect.Right) and (Y < TopRect.Bottom - 1) then
          ACanvas.Line(X, Y + 1, X, TopRect.Bottom - 1);
        Inc(SIdx, Step);
      end;
    end;
  end;

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

  // Hover crosshair and floating rounded card tooltip
  if FHoverActive and (FHoverX >= TopRect.Left) and (FHoverX <= TopRect.Right) then
  begin
    HoverSec := ((FHoverX - TopRect.Left) / Max(1, TopRect.Right - TopRect.Left)) * MaxDuration;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := IfThen(AIsDark, RGBToColor(120, 140, 180), RGBToColor(100, 110, 130));
    ACanvas.Line(FHoverX, TopRect.Top, FHoverX, BotRect.Bottom);
    ACanvas.Pen.Style := psSolid;

    CardW := 230;
    CardH := 24 + (Length(FLoadedRuns) * 18);
    if FHoverX + 15 + CardW > ARect.Right then
      CardLeft := FHoverX - CardW - 15
    else
      CardLeft := FHoverX + 15;
    CardTop := Max(TopRect.Top + 6, Min(FHoverY - 20, BotRect.Bottom - CardH - 6));

    // Card background & border
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := IfThen(AIsDark, RGBToColor(18, 22, 34), RGBToColor(255, 255, 255));
    ACanvas.Pen.Color := IfThen(AIsDark, RGBToColor(65, 80, 115), RGBToColor(190, 200, 215));
    ACanvas.RoundRect(CardLeft, CardTop, CardLeft + CardW, CardTop + CardH, 8, 8);

    // Header: Elapsed Time
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := IfThen(AIsDark, RGBToColor(48, 190, 240), RGBToColor(25, 118, 210));
    ACanvas.TextOut(CardLeft + 10, CardTop + 5, Format('⏱ Elapsed: %.2fs', [HoverSec]));

    // Multi-series rows
    for RIdx := 0 to High(FLoadedRuns) do
    begin
      Run := FLoadedRuns[RIdx];
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

      RowY := CardTop + 22 + (RIdx * 18);
      SeriesColor := SERIES_COLORS[RIdx mod Length(SERIES_COLORS)];
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := SeriesColor;
      ACanvas.Pen.Color := SeriesColor;
      ACanvas.Ellipse(CardLeft + 10, RowY + 3, CardLeft + 18, RowY + 11);

      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Size := 8;
      ACanvas.Font.Style := [];
      ACanvas.Font.Color := TextColor;
      if (Run.SampleCount > 0) and (BestIdx >= 0) then
        TipStr := Format('%.1f FPS • %.2f ms', [Run.Samples[BestIdx].Fps, Run.Samples[BestIdx].FrametimeMs])
      else
        TipStr := 'N/A';
      ACanvas.TextOut(CardLeft + 24, RowY, TipStr);
    end;
  end;
end;

procedure TPasPlotPanel.DrawSummaryView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
const
  METRIC_NAMES: array[0..3] of string = ('Average FPS', '1% Low FPS', '0.1% Low FPS', 'Peak (Max) FPS');
var
  MIdx, RIdx, GroupTop, GroupH, BarH, BarTop, BarRight, MaxBarW: Integer;
  MaxVal, Val, BaseVal, Delta: Double;
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
      ACanvas.RoundRect(ARect.Left + 10, BarTop, Max(ARect.Left + 14, BarRight), BarTop + BarH, 6, 6);

      if Length(FLoadedRuns) > 1 then
      begin
        case MIdx of
          0: BaseVal := FLoadedRuns[0].AvgFps;
          1: BaseVal := FLoadedRuns[0].Fps1Low;
          2: BaseVal := FLoadedRuns[0].Fps01Low;
          else BaseVal := FLoadedRuns[0].MaxFps;
        end;
        if RIdx = 0 then
          ValText := Format('%.1f FPS  [Baseline] (%s)', [Val, FLoadedRuns[RIdx].DisplayName])
        else if BaseVal > 0 then
        begin
          Delta := ((Val - BaseVal) / BaseVal) * 100.0;
          if Delta >= 0 then
            ValText := Format('%.1f FPS  (+%.1f%%) (%s)', [Val, Delta, FLoadedRuns[RIdx].DisplayName])
          else
            ValText := Format('%.1f FPS  (%.1f%%) (%s)', [Val, Delta, FLoadedRuns[RIdx].DisplayName]);
        end
        else
          ValText := Format('%.1f FPS (%s)', [Val, FLoadedRuns[RIdx].DisplayName]);
      end
      else
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

procedure TPasPlotPanel.DrawHardwareView(ACanvas: TCanvas; const ARect: TRect; AIsDark: Boolean);
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
      ACanvas.RoundRect(ARect.Left + 10, BarTop, Max(ARect.Left + 14, BarRight), BarTop + BarH, 6, 6);

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

function TPasPlotPanel.ExportToPngFile(const AFilePath: string): Boolean;
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
