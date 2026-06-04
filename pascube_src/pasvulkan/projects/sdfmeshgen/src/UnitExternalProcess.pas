unit UnitExternalProcess;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

interface

uses {$if defined(Win32) or defined(Win64) or defined(Windows)}
      Windows,ShellApi,
     {$ifend}
     {$ifdef fpc}
      process,
     {$endif}
     SysUtils,Classes;

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:array of UnicodeString;out aOutput:UnicodeString):Int32; overload;
function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:TStrings;out aOutput:UnicodeString):Int32; overload;

implementation

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:array of UnicodeString;out aOutput:UnicodeString):Int32;
{$if (defined(Win32) or defined(Win64) or defined(Windows))} // and not defined(fpc)}
{$define UseANSI}
const BufferSize=4096;
type TBuffer=array[0..BufferSize*2] of AnsiChar; // Size+1 for as additional small headroom
     PBuffer=^TBuffer;
{$ifndef UseANSI}
     TBufferW=array[0..(BufferSize*8)] of WideChar;
     PBufferW=^TBufferW;
{$endif}
var SecurityAttributes:TSecurityAttributes;
    StartupInfo:Windows.TStartupInfoW;
    ProcessInformation:TProcessInformation;
    ReadableEndOfPipe,WriteableEndOfPipe:THandle;
    DummyReadableEndOfPipe,DummyWriteableEndOfPipe:THandle;
    Index:Int32;
    CommandLine,CurrentDirectory:WideString;
    Parameter:UnicodeString;
    Running,CountAvailable,CountRead,ExitCode:DWORD;
    RawBuffer:PBuffer;
    FinalBuffer:{$ifdef UseANSI}PBuffer{$else}PBufferW{$endif};
begin
 result:=-1;
 aOutput:='';
 SecurityAttributes.nLength:=SizeOf(TSecurityAttributes);
 SecurityAttributes.bInheritHandle:=true;
 SecurityAttributes.lpSecurityDescriptor:=nil;
 if CreatePipe(ReadableEndOfPipe,WriteableEndOfPipe,@SecurityAttributes,0) then begin
  try
   if CreatePipe(DummyReadableEndOfPipe,DummyWriteableEndOfPipe,@SecurityAttributes,0) then begin
    try
     FillChar(StartupInfo,SizeOf(TStartupInfoW),#0);
     StartupInfo.cb:=SizeOf(TStartupInfoW);
     StartupInfo.dwFlags:=STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
     StartupInfo.wShowWindow:=SW_HIDE;
     StartupInfo.hStdInput:=DummyReadableEndOfPipe;
     StartupInfo.hStdOutput:=WriteableEndOfPipe;
     StartupInfo.hStdError:=WriteableEndOfPipe;
     CommandLine:='';
     for Index:=-1 to length(aParameters)-1 do begin
      if Index<0 then begin
       Parameter:=aExecutable;
      end else begin
       Parameter:=aParameters[Index];
      end;
      if (pos(' ',Parameter)>0) and (pos('"',Parameter)=0) then begin
       Parameter:='"'+Parameter+'"';
      end;
      if length(CommandLine)>0 then begin
       CommandLine:=CommandLine+' ';
      end;
      CommandLine:=CommandLine+WideString(Parameter);
     end;
     CurrentDirectory:=aDirectory;
     if CreateProcessW(nil,
                       PWideChar(CommandLine),
                       @SecurityAttributes,
                       @SecurityAttributes,
                       true,
                       NORMAL_PRIORITY_CLASS,
                       nil,
                       PWideChar(CurrentDirectory),
                       StartupInfo,
                       ProcessInformation) then begin
      try
       GetMem(RawBuffer,SizeOf(TBuffer));
       try
        GetMem(FinalBuffer,SizeOf({$ifdef UseANSI}TBuffer{$else}TBufferW{$endif}));
        try
         repeat
          Running:=WaitForSingleObject(ProcessInformation.hProcess,10);
          PeekNamedPipe(ReadableEndOfPipe,nil,0,nil,@CountAvailable,nil);
          if CountAvailable>0 then begin
           repeat
            CountRead:=0;
            ReadFile(ReadableEndOfPipe,RawBuffer^[0],BufferSize,CountRead,nil);
            RawBuffer^[CountRead]:=AnsiChar(#0);
{$ifdef UseANSI}
            FillChar(FinalBuffer^,SizeOf(TBuffer),#0);
            OemToAnsi(@RawBuffer[0],@FinalBuffer[0]);
            aOutput:=aOutput+UnicodeString(AnsiString(PAnsiChar(@FinalBuffer[0])));
{$else}
            FillChar(FinalBuffer^,SizeOf(TBufferW),#0);
            OemToCharW(@RawBuffer[0],@FinalBuffer[0]);
            aOutput:=aOutput+UnicodeString(WideString(PWideChar(@FinalBuffer[0])));
{$endif}
           until CountRead<BufferSize;
          end;
         until Running<>WAIT_TIMEOUT;
         if GetExitCodeProcess(ProcessInformation.hProcess,DWORD(ExitCode)) then begin
          result:=ExitCode;
         end;
        finally
         FreeMem(FinalBuffer);
        end;
       finally
        FreeMem(RawBuffer);
       end;
      finally
       CloseHandle(ProcessInformation.hProcess);
       CloseHandle(ProcessInformation.hThread);
      end;
     end;
    finally
     CloseHandle(DummyReadableEndOfPipe);
     CloseHandle(DummyWriteableEndOfPipe);
    end;
   end;
  finally
   CloseHandle(ReadableEndOfPipe);
   CloseHandle(WriteableEndOfPipe);
  end;
 end;
end;
{$else}
var ChildProcess:TProcess;
    Index,Count:Int32;
    TempString:UTF8String;
begin
 aOutput:='';
 try
  ChildProcess:=TProcess.Create(nil);
  try
   ChildProcess.Options:=[poUsePipes,poStderrToOutput];
   ChildProcess.ShowWindow:=swoHide;
   ChildProcess.CurrentDirectory:=String(aDirectory);
   ChildProcess.Executable:=String(aExecutable);
   for Index:=0 to length(aParameters)-1 do begin
    ChildProcess.Parameters.Add(String(aParameters[Index]));
   end;
   ChildProcess.Execute;
{  while ChildProcess.Running do begin
    Count:=ChildProcess.Output.NumBytesAvailable;
    if Count>0 then begin
     SetLength(TempString,Count);
     ChildProcess.Output.ReadBuffer(TempString[1],Count);
     aOutput:=aOutput+UnicodeString(TempString);
    end;
   end;}
   ChildProcess.WaitOnExit;
   result:=ChildProcess.ExitCode;
  finally
   ChildProcess.Free;
  end;
 finally
 end;
end;
{$ifend}

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:TStrings;out aOutput:UnicodeString):Int32;
var Index:Int32;
    Parameters:array of UnicodeString;
begin
 Parameters:=nil;
 try
  SetLength(Parameters,aParameters.Count);
  for Index:=0 to aParameters.Count-1 do begin
   Parameters[Index]:=UnicodeString(aParameters.Strings[Index]);
  end;
  result:=ExecuteCommand(aDirectory,aExecutable,Parameters,aOutput);
 finally
  Parameters:=nil;
 end;
end;

end.

