program typedqueue;
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

type TProducerThread=class(TPasMPThread)
      protected
       procedure Execute; override;
     end;

     TOtherProducerThread=class(TPasMPThread)
      protected
       procedure Execute; override;
     end;

     TConsumerThread=class(TPasMPThread)
      protected
       procedure Execute; override;
     end;

     TOtherConsumerThread=class(TPasMPThread)
      protected
       procedure Execute; override;
     end;

var IntegerQueue:TPasMPBoundedQueue<longint>;

procedure TProducerThread.Execute;
var Value:longint;
begin
 Value:=0;
 while not Terminated do begin
  while not (Terminated or IntegerQueue.Enqueue(Value)) do begin
   TPasMP.Yield;
  end;
  inc(Value);
 end;
end;

procedure TOtherProducerThread.Execute;
var Value:longint;
begin
 Value:=0;
 while not Terminated do begin
  while not (Terminated or IntegerQueue.Enqueue(Value)) do begin
   TPasMP.Yield;
  end;
  dec(Value);
 end;
end;

procedure TConsumerThread.Execute;
var Value:longint;
begin
 while not Terminated do begin
  if IntegerQueue.Dequeue(Value) then begin
   write(#13,Value);
  end;
 end;
end;

procedure TOtherConsumerThread.Execute;
var Value:longint;
begin
 while not Terminated do begin
  if IntegerQueue.Dequeue(Value) then begin
   TPasMP.Yield;
  end;
 end;
end;

var ProducerThread:TProducerThread;
    OtherProducerThread:TOtherProducerThread;
    ConsumerThread:TConsumerThread;
    OtherConsumerThread:TOtherConsumerThread;
begin

 TPasMP.CreateGlobalInstance;

 IntegerQueue:=TPasMPBoundedQueue<longint>.Create(65536);
 try

  ProducerThread:=TProducerThread.Create(false);
  OtherProducerThread:=TOtherProducerThread.Create(false);
  ConsumerThread:=TConsumerThread.Create(false);
  OtherConsumerThread:=TOtherConsumerThread.Create(false);
  try

   readln;

  finally
   ProducerThread.Terminate;
   OtherProducerThread.Terminate;
   ConsumerThread.Terminate;
   OtherConsumerThread.Terminate;
   ProducerThread.WaitFor;
   OtherProducerThread.WaitFor;
   ConsumerThread.WaitFor;
   OtherConsumerThread.WaitFor;
   ProducerThread.Free;
   OtherProducerThread.Free;
   ConsumerThread.Free;
   OtherConsumerThread.Free;
  end;

 finally

  IntegerQueue.Free;

 end;

 writeln(#13,'Have a nice day!           ');

 readln;

end.
