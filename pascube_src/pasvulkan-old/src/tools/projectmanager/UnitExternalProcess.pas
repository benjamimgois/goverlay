unit UnitExternalProcess;
{$i ..\..\PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses {$if defined(Win32) or defined(Win64) or defined(Windows)}
      Windows,ShellApi,
     {$ifend}
     {$ifdef fpc}
      process,
     {$endif}
     SysUtils,Classes,UnitVersion,UnitGlobals;

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:array of UnicodeString):boolean; overload;
function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:TStrings):boolean; overload;

implementation

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:array of UnicodeString):boolean;
{$if (defined(Win32) or defined(Win64) or defined(Windows))} // and not defined(fpc)}
var SecurityAttributes:TSecurityAttributes;
    StartupInfo:Windows.TStartupInfoW;
    ProcessInformation:TProcessInformation;
    Index:Int32;
    CommandLine,CurrentDirectory:WideString;
    Parameter:UnicodeString;
    ExitCode:DWORD;
begin
 result:=false;
 SecurityAttributes.nLength:=SizeOf(TSecurityAttributes);
 SecurityAttributes.bInheritHandle:=true;
 SecurityAttributes.lpSecurityDescriptor:=nil;
 FillChar(StartupInfo,SizeOf(TStartupInfoW),#0);
 StartupInfo.cb:=SizeOf(TStartupInfoW);
 StartupInfo.dwFlags:=STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow:=SW_NORMAL;
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
   WaitForSingleObject(ProcessInformation.hProcess,INFINITE);
   if GetExitCodeProcess(ProcessInformation.hProcess,DWORD(ExitCode)) then begin
    result:=ExitCode=0;
   end;
  finally
   CloseHandle(ProcessInformation.hProcess);
   CloseHandle(ProcessInformation.hThread);
  end;
 end;
end;
{$else}
var ChildProcess:TProcess;
    Index,Count:Int32;
    TempString:UTF8String;
begin
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
  while ChildProcess.Running do begin
   Count:=ChildProcess.Output.NumBytesAvailable;
   if Count>0 then begin
    SetLength(TempString,Count);
    ChildProcess.Output.ReadBuffer(TempString[1],Count);
    Write(TempString);
   end;
  end;
  ChildProcess.WaitOnExit;
  result:=ChildProcess.ExitCode=0;
 finally
  ChildProcess.Free;
 end;
end;
{$ifend}

function ExecuteCommand(const aDirectory,aExecutable:UnicodeString;const aParameters:TStrings):boolean;
var Index:Int32;
    Parameters:array of UnicodeString;
begin
 Parameters:=nil;
 try
  SetLength(Parameters,aParameters.Count);
  for Index:=0 to aParameters.Count-1 do begin
   Parameters[Index]:=UnicodeString(aParameters.Strings[Index]);
  end;
  result:=ExecuteCommand(aDirectory,aExecutable,Parameters);
 finally
  Parameters:=nil;
 end;
end;

end.

