program selfmadeparallelforjobtask;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$APPTYPE CONSOLE}

uses
{$ifdef unix}
  cthreads,
{$endif}
  SysUtils,
  PasMP in '..\..\src\PasMP.pas';

{$if defined(win32) or defined(win64) or defined(windows)}
procedure Sleep(ms:longword); stdcall; external 'kernel32.dll' name 'Sleep';
{$ifend}

const N=65536;

type PCells=^TCells;
     TCells=array[1..N] of boolean;

var FakeAtomicOperationMutex:TPasMPMutex;
    Index,Sum:longint;
    Cells:TCells;

type TParallelForJobTask=class(TPasMPJobTask)
      private
       fFromIndex:longint;
       fToIndex:longint;
       fGranularity:longint;
       fRemainDepth:longint;
       fSpreaded:boolean;
       fSpreadedJobs:array of PPasMPJob;
      public
       constructor Create(const FromIndex,ToIndex,Granularity,RemainDepth:longint;const Spreaded:boolean=false);
       destructor Destroy; override;
       procedure Run; override; // run our task
       function Split:TPasMPJobTask; override; // keep half the work and put the other half in a new task
       function PartialPop:TPasMPJobTask; override; // pop a sub part of the task
       function Spread:boolean; override; // (pre-)spread work uniformly into multiple job tasks, the destructor must wait and release the spreaded jobs then.
     end;

constructor TParallelForJobTask.Create(const FromIndex,ToIndex,Granularity,RemainDepth:longint;const Spreaded:boolean=false);
begin
 inherited Create;
 FreeOnRelease:=true;
 fFromIndex:=FromIndex;
 fToIndex:=ToIndex;
 if Granularity<4 then begin
  fGranularity:=4;
 end else begin
  fGranularity:=Granularity;
 end;
 fSpreaded:=Spreaded;
 fRemainDepth:=RemainDepth;
 fSpreadedJobs:=nil;
end;

destructor TParallelForJobTask.Destroy;
begin
 if length(fSpreadedJobs)>0 then begin
  GlobalPasMP.WaitRelease(fSpreadedJobs); // WaitRelease combines Wait and Release into a single call
  SetLength(fSpreadedJobs,0);
 end;
 inherited Destroy;
end;

procedure TParallelForJobTask.Run;
var Index:longint;
begin
 FakeAtomicOperationMutex.Acquire;
 try
  writeln(fFromIndex,'..',fToIndex,' from thread #',ThreadIndex);
  inc(Sum,(fToIndex-fFromIndex)+1);
 finally
  FakeAtomicOperationMutex.Release;
 end;
 for Index:=fFromIndex to fToIndex do begin
  Cells[Index]:=true;
 end;
 Sleep(100); // simulate some extra work load
end;

function TParallelForJobTask.Split:TPasMPJobTask;
var SplitIndex:longint;
begin
 if (fRemainDepth>0) and (fFromIndex<=fToIndex) and (((fToIndex-fFromIndex)+1)>fGranularity) then begin
  SplitIndex:=fFromIndex+(((fToIndex-fFromIndex)+1) div 2);
  result:=TParallelForJobTask.Create(SplitIndex,fToIndex,fGranularity,fRemainDepth-1,true);
  fToIndex:=SplitIndex-1;
  dec(fRemainDepth);
  fSpreaded:=true;
 end else begin
  result:=nil;
 end;
end;

function TParallelForJobTask.PartialPop:TPasMPJobTask;
var SplitIndex:longint;
begin
 if (fRemainDepth>0) and (fFromIndex<=fToIndex) and ((fFromIndex+fGranularity)<fToIndex) then begin
  SplitIndex:=fFromIndex+fGranularity;
  result:=TParallelForJobTask.Create(SplitIndex,fToIndex,fGranularity,fRemainDepth-1,true);
  fToIndex:=SplitIndex-1;
  dec(fRemainDepth);
  fSpreaded:=true;
 end else begin
  result:=nil;
 end;
end;

function TParallelForJobTask.Spread:boolean;
var Count,CountJobs,PartSize,Rest,JobIndex,Size:longint;
begin
 Count:=((fToIndex-fFromIndex)+1);
 if (fRemainDepth>0) and (fFromIndex<=fToIndex) and (Count>fGranularity) and not fSpreaded then begin
  CountJobs:=Count div fGranularity;
  if CountJobs<1 then begin
   CountJobs:=1;
  end else if CountJobs>32 then begin
   CountJobs:=32;
  end;
  PartSize:=Count div CountJobs;
  Rest:=Count-(CountJobs*PartSize);
  SetLength(fSpreadedJobs,CountJobs-1);
  Index:=fFromIndex; 
  for JobIndex:=0 to CountJobs-1 do begin
   Size:=PartSize;
   if Rest>JobIndex then begin
    inc(Size);
   end;
   if JobIndex<(CountJobs-1) then begin
    fSpreadedJobs[JobIndex]:=GlobalPasMP.Acquire(TParallelForJobTask.Create(Index,(Index+Size)-1,fGranularity,fRemainDepth-1,true));
    GlobalPasMP.Run(fSpreadedJobs[JobIndex]);
   end else begin
    // The last part is for us self
    fFromIndex:=Index;
    fToIndex:=(Index+Size)-1;
    dec(fRemainDepth);
    fSpreaded:=true;
   end;
   inc(Index,Size);
  end;
  result:=true;
 end else begin
  result:=false;
 end;
end;

begin

 TPasMP.CreateGlobalInstance;

 FillChar(Cells,SizeOf(TCells),#0);

 Sum:=0;

 FakeAtomicOperationMutex:=TPasMPMutex.Create;
 try
  GlobalPasMP.Invoke(TParallelForJobTask.Create(1,N,16,8)); // <= Invoke = Run+Wait+Release into a single call
 finally
  FakeAtomicOperationMutex.Free;
 end;

 writeln(Sum,' should be ',N);

 Sum:=0;
 for Index:=1 to N do begin
  if Cells[Index] then begin
   inc(Sum);
  end;
 end;
 writeln(Sum,' should be also ',N);

 readln;

end.
