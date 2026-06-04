program rootandchildren;
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

const N=32;

var FakeAtomicOperationMutex:TPasMPMutex;
    Sum:longint;

procedure RootJobFunction(const Job:PPasMPJob;const ThreadIndex:longint);
begin
 // Dunmy empty job function
end;

procedure ChildJobFunction(const Job:PPasMPJob;const ThreadIndex:longint);
begin
 FakeAtomicOperationMutex.Acquire;
 try
  writeln(Sum,' from thread #',ThreadIndex);
  inc(Sum);
 finally
  FakeAtomicOperationMutex.Release;
 end;
 Sleep(100); // simulate some workload
end;

var RootJob:PPasMPJob;
    i:longint;
begin

 TPasMP.CreateGlobalInstance;

 Sum:=0;

 FakeAtomicOperationMutex:=TPasMPMutex.Create;
 try
  RootJob:=GlobalPasMP.Acquire(RootJobFunction);
  for i:=1 to N do begin
   GlobalPasMP.Run(GlobalPasMP.Acquire(ChildJobFunction,nil,RootJob,PasMPJobFlagReleaseOnFinish));
  end;
  GlobalPasMP.Run(RootJob);
  GlobalPasMP.Wait(RootJob);
  // if you don't use the PasMPJobFlagFreeOnRelease flag in this case, then you must do also:
  // GlobalPasMP.Reset; // <= Release all aquired jobs
 finally
  FakeAtomicOperationMutex.Free;
 end;

 writeln(Sum,' should be ',N);

 readln;

end.
