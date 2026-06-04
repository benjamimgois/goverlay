unit UnitFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PasMP, ExtCtrls, PasMPProfilerHistoryView, AppEvnts, StdCtrls;

type
  TFormMain = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    CheckBoxSuppressGaps: TCheckBox;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    PasMPInstance:TPasMP;
    ProfilerHistoryView:TPasMPProfilerHistoryView;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

const N=1 shl 28;

procedure ParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:longint;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Index:longint;
begin
 for Index:=FromIndex to ToIndex do begin
  if Index<>0 then begin
  end;
 end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 PasMPInstance:=TPasMP.Create(-1,0,false,true,false,true);
 ProfilerHistoryView:=TPasMPProfilerHistoryView.Create(self);
 ProfilerHistoryView.Parent:=self;
 ProfilerHistoryView.Align:=alClient;
 ProfilerHistoryView.PasMPInstance:=PasMPInstance;
 ProfilerHistoryView.VisibleTimePeriod:=PasMPInstance.Profiler.HighResolutionTimer.QuarterSecondInterval;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
 ProfilerHistoryView.Free;
 PasMPInstance.Free;
end;

procedure TFormMain.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
var Jobs:array[0..3] of PPasMPJob;
begin
 PasMPInstance.Profiler.Start(CheckBoxSuppressGaps.Checked);
 try
  Jobs[0]:=PasMPInstance.ParallelFor(nil,1,N,ParallelForJobFunction,65536,8,nil,TPasMP.EncodeJobTagToJobFlags(1) or PasMPJobPriorityHigh);
  Jobs[1]:=PasMPInstance.ParallelFor(nil,1,N,ParallelForJobFunction,65536,8,nil,TPasMP.EncodeJobTagToJobFlags(2) or PasMPJobPriorityNormal);
  Jobs[2]:=PasMPInstance.ParallelFor(nil,1,N,ParallelForJobFunction,65536,8,nil,TPasMP.EncodeJobTagToJobFlags(3) or PasMPJobPriorityNormal);
  Jobs[3]:=PasMPInstance.ParallelFor(nil,1,N,ParallelForJobFunction,65536,8,nil,TPasMP.EncodeJobTagToJobFlags(4) or PasMPJobPriorityLow);
  PasMPInstance.Invoke(Jobs);
 finally
  PasMPInstance.Profiler.Stop(ProfilerHistoryView.VisibleTimePeriod);
  ProfilerHistoryView.TransferData;
 end;
 ProfilerHistoryView.Invalidate;
 Done:=false;
end;

end.
