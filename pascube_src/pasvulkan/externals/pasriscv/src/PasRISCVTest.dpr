// This file is part of the PasRISCV project, a RISC-V emulator written in Object Pascal.
// PasRISCVTest executes the riscv-tests suite and checks the results for correctness.
// It includes a quick&dirty HTIF implementation for handling HTIF communication with the test binaries.
program PasRISCVTest;
{$ifdef fpc}
 {$mode delphi}
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
{$if defined(Windows) or defined(Win32) or defined(Win64)}
 {$apptype console}
{$ifend}
{$scopedenums on}

uses {$ifdef Unix}cthreads,{$endif}
     {$if defined(Windows) and not defined(fpc)}
      Windows,
     {$ifend}
     SysUtils,Classes,Math,PasRISCV;

var Machine:TPasRISCV;

const HTIF_DEV_SHIFT=56;
      HTIF_CMD_SHIFT=48;

      HTIF_DEV_SYSTEM=0;
      HTIF_DEV_CONSOLE=1;

      HTIF_SYSTEM_CMD_SYSCALL=0;
      HTIF_CONSOLE_CMD_GETCHAR=0;
      HTIF_CONSOLE_CMD_PUTCHAR=1;

      PK_SYS_WRITE=64;

var VModeTest:Boolean=false;

    // HTIF offsets
    HTIFToHostOffset:TPasRISCVUInt64;
    HTIFFromHostOffset:TPasRISCVUInt64;

    HTIFExitCode:TPasRISCVInt64;

    TestErrorCode:TPasRISCVInt64;

    PassCode:TPasRISCVUInt64;

type { TMachineInstance }
     TMachineInstance=class
      public
       procedure Boot;
       procedure OnReboot;
       function OnCPUException(const aHART:TPasRISCV.THART;const aExceptionValue:TPasRISCV.THART.TExceptionValue;const aExceptionData:TPasRISCVUInt64;const aExceptionPC:TPasRISCVUInt64):Boolean;
     end;

{ TReboot }

procedure TMachineInstance.Boot;
begin

 Machine.Reset;

 if FileExists('disk.img') then begin
  Machine.VirtIOBlockDevice.LoadFromFile('disk.img');
 end;

end;

procedure TMachineInstance.OnReboot;
begin
 Boot;
end;

function TMachineInstance.OnCPUException(const aHART:TPasRISCV.THART;const aExceptionValue:TPasRISCV.THART.TExceptionValue;const aExceptionData:TPasRISCVUInt64;const aExceptionPC:TPasRISCVUInt64):Boolean;
begin
 case aExceptionValue of
  TPasRISCV.THART.TExceptionValue.ECallUMode,
  TPasRISCV.THART.TExceptionValue.ECallSMode,
  TPasRISCV.THART.TExceptionValue.ECallHMode,
  TPasRISCV.THART.TExceptionValue.ECallMMode:begin
   if Machine.HART.State^.Registers[TPasRISCV.TRegister.A7]=93 then begin // Exit syscall
    TestErrorCode:=Machine.HART.State^.Registers[TPasRISCV.TRegister.A0];
    result:=true;
   end else begin
    result:=false;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

procedure Run;
var Configuration:TPasRISCV.TConfiguration;
    MachineInstance:TMachineInstance;
{$if defined(Windows) and not defined(fpc)}
    ConsoleInputHandle:Windows.THandle;
    ConsoleOutputHandle:Windows.THandle;
    OldConsoleModeIn:DWORD;
    OldConsoleModeOut:DWORD;
{$ifend}
begin

{$if defined(Windows) and not defined(fpc)}
 SetConsoleCP(CP_UTF8);
 SetConsoleOutputCP(CP_UTF8);
 ConsoleInputHandle:=GetStdHandle(STD_INPUT_HANDLE);
 ConsoleOutputHandle:=GetStdHandle(STD_OUTPUT_HANDLE);
 GetConsoleMode(ConsoleInputHandle,OldConsoleModeIn);
 SetConsoleMode(ConsoleInputHandle,(ENABLE_VIRTUAL_TERMINAL_INPUT or
                                    ENABLE_WINDOW_INPUT or
                                    ENABLE_MOUSE_INPUT) and not
                                   (//ENABLE_PROCESSED_INPUT or
                                    ENABLE_WRAP_AT_EOL_OUTPUT));
 GetConsoleMode(ConsoleOutputHandle,OldConsoleModeOut);
 SetConsoleMode(ConsoleOutputHandle,OldConsoleModeOut or (ENABLE_PROCESSED_OUTPUT or
                                                          ENABLE_VIRTUAL_TERMINAL_PROCESSING));
{$ifend}

 Configuration:=TPasRISCV.TConfiguration.Create;
 try

  Configuration.CountHARTs:=4;

  Configuration.MemorySize:=TPasRISCVUInt64(2048) shl 20; // 2GB

  if ParamStr(1)='image' then begin
   // Image
   if ParamStr(2)='kernel' then begin
    // With other external kernel
    Configuration.LoadBIOSFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'fw_jump.bin');
    Configuration.LoadKernelFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'kernel.bin');
   end else begin
    // With image-embedded kernel
    Configuration.LoadBIOSFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'fw_payload.bin');
   end;
   Configuration.BootArguments:='root=/dev/vda1 rw noquiet rw earlyprintk console=$LINUXUART$ earlycon=sbi';
// Configuration.BootArguments:='root=LABEL=rootfs rw noquiet rw earlyprintk console=$LINUXUART$ earlycon=sbi';
// Configuration.BootArguments:='root=/dev/vda1 rw earlyprintk console=$LINUXUART$ earlycon=sbi';
  end else begin
   // Buildroot
   Configuration.LoadBIOSFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'fw_jump.bin');
   Configuration.LoadKernelFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'kernel.bin');
   Configuration.BootArguments:='root=/dev/mem rw earlyprintk console=$LINUXUART$ earlycon=sbi';
  end;

  MachineInstance:=TMachineInstance.Create;

  try

   Machine:=TPasRISCV.Create(Configuration);
   try

    if ParamStr(1)='image' then begin
     Machine.VirtIOBlockDevice.AttachStream(TFileStream.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'image.img',fmOpenReadWrite{or fmShareDenyNone}));
    end;

    Machine.OnReboot:=MachineInstance.OnReboot;

    MachineInstance.Boot;

    Machine.Run;

   finally
    FreeAndNil(Machine);
   end;

  finally
   FreeAndNil(MachineInstance);
  end;

 finally
  FreeAndNil(Configuration);
 end;

{$if defined(Windows) and not defined(fpc)}
 SetConsoleMode(ConsoleInputHandle,OldConsoleModeIn);
 SetConsoleMode(ConsoleOutputHandle,OldConsoleModeOut);
{$ifend}

end;

procedure GetAllBinaryFiles(const aPath:string;const aStringList:TStringList);
var SearchRec:TSearchRec;
begin
 if FindFirst(aPath+'*.bin',faAnyFile,SearchRec)=0 then begin
  try
   repeat
    if (SearchRec.Attr and faDirectory)=0 then begin
     aStringList.Add(aPath+SearchRec.Name);
    end;
   until FindNext(SearchRec)<>0;
  finally
   FindClose(SearchRec);
  end;
 end;
 if FindFirst(aPath+'*.elf',faAnyFile,SearchRec)=0 then begin
  try
   repeat
    if (SearchRec.Attr and faDirectory)=0 then begin
     aStringList.Add(aPath+SearchRec.Name);
    end;
   until FindNext(SearchRec)<>0;
  finally
   FindClose(SearchRec);
  end;
 end;
 if FindFirst(aPath+{$ifdef Unix}'*'{$else}'*.*'{$endif},faDirectory,SearchRec)=0 then begin
  try
   repeat
    if (SearchRec.Attr and faDirectory)<>0 then begin
     if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then begin
      GetAllBinaryFiles(IncludeTrailingPathDelimiter(aPath+SearchRec.Name),aStringList);
     end;
    end;
   until FindNext(SearchRec)<>0;
  finally
   FindClose(SearchRec);
  end;
 end;
end;

// Set HTIF offsets based on filename, as some tests use different offsets
procedure SetHTIFHostOffsetsFromFileName(const aFileName:string);
var FileNameWithoutPathAndExtension:string;
begin

 FileNameWithoutPathAndExtension:=LowerCase(ChangeFileExt(ExtractFileName(aFileName),''));    

 // Determine HTIF offsets based on filename, as some tests use different offsets
 if pos('rv64uc-p-rvc',FileNameWithoutPathAndExtension)>0 then begin
  HTIFToHostOffset:=$3000;
  HTIFFromHostOffset:=$3040;
 end else if (pos('rv64ud-p-move',FileNameWithoutPathAndExtension)>0) or
             (pos('rv64ui-p-ma_data',FileNameWithoutPathAndExtension)>0) then begin
  HTIFToHostOffset:=$2000;
  HTIFFromHostOffset:=$2040;
 end else begin
  HTIFToHostOffset:=$1000;
  HTIFFromHostOffset:=$1040;
 end;

 // Reset HTIF
 HTIFExitCode:=-1;

end;

// Handle HTIF communication as quick&dirty hack per memory-device instead of a proper device, since the tests are running instruction step-wise anyway,
// so we can just check the memory for HTIF communication after each instruction step and handle it here. 
procedure HandleHTIF;
var ToHostValue:TPasRISCVUInt64;
    Device:TPasRISCVUInt64;
    Cmd:TPasRISCVUInt64;
    Payload:TPasRISCVUInt64;
    Response:TPasRISCVUInt64;
    SysCall:array[0..7] of TPasRISCVUInt64;
begin
  
 // Read HTIF values from memory
 ToHostValue:=PPasRISCVUInt64(Pointer(@PPasRISCVUInt8Array(Machine.MemoryDevice.Data)^[HTIFToHostOffset]))^;

 // Handle ToHost value
 if ToHostValue<>0 then begin

  Device:=(ToHostValue shr HTIF_DEV_SHIFT) and $ff;
  Cmd:=(ToHostValue shr HTIF_CMD_SHIFT) and $ff;
  Payload:=ToHostValue and TPasRISCVUInt64($fffffffffff);

  Response:=0;

  // Currently, there is a fixed mapping of devices:
  // 0: System for riscv-tests
  // 1: Console

  // Handle HTIF communication
  case Device of
   HTIF_DEV_SYSTEM:begin
    case Cmd of
     HTIF_SYSTEM_CMD_SYSCALL:begin
      if (Payload and 1)<>0 then begin
       HTIFExitCode:=Payload shr 1;
       TestErrorCode:=Machine.HART.State^.Registers[TPasRISCV.TRegister.A0];
      end else begin
       SysCall[0]:=Machine.Bus.Load(nil,Payload+(0*SizeOf(TPasRISCVUInt64)),8);
       SysCall[1]:=Machine.Bus.Load(nil,Payload+(1*SizeOf(TPasRISCVUInt64)),8);
       SysCall[2]:=Machine.Bus.Load(nil,Payload+(2*SizeOf(TPasRISCVUInt64)),8);
       SysCall[3]:=Machine.Bus.Load(nil,Payload+(3*SizeOf(TPasRISCVUInt64)),8);
       SysCall[4]:=Machine.Bus.Load(nil,Payload+(4*SizeOf(TPasRISCVUInt64)),8);
       SysCall[5]:=Machine.Bus.Load(nil,Payload+(5*SizeOf(TPasRISCVUInt64)),8);
       SysCall[6]:=Machine.Bus.Load(nil,Payload+(6*SizeOf(TPasRISCVUInt64)),8);
       SysCall[7]:=Machine.Bus.Load(nil,Payload+(7*SizeOf(TPasRISCVUInt64)),8);
       if (SysCall[0]=PK_SYS_WRITE) and (SysCall[1]=HTIF_DEV_CONSOLE) and (SysCall[3]=HTIF_CONSOLE_CMD_PUTCHAR) then begin
        // Write character to console
        Write(AnsiChar(TPasRISCVUInt8(SysCall[2] and $ff)));
        Response:=$100 or (Payload and $ff);        
       end;
      end;
     end;
    end;
   end;
   HTIF_DEV_CONSOLE:begin
    case Cmd of
     HTIF_CONSOLE_CMD_GETCHAR:begin
      // Get character from console
      Response:=0;//TPasRISCVUInt64(Ord(ReadKey));
     end;
     HTIF_CONSOLE_CMD_PUTCHAR:begin
      // Write character to console
      Write(AnsiChar(Payload and $ff));
      Response:=$100 or (Payload and $ff);
     end;
    end;
   end;  
  end;              
  
  // Reset ToHost value in memory for indicating that the value has been read
  PPasRISCVUInt64(Pointer(@PPasRISCVUInt8Array(Machine.MemoryDevice.Data)^[HTIFToHostOffset]))^:=0;

  // Write FromHost value to memory
  PPasRISCVUInt64(Pointer(@PPasRISCVUInt8Array(Machine.MemoryDevice.Data)^[HTIFFromHostOffset]))^:=((ToHostValue shr 48) shl 48) or ((Response shl 16) shr 16);

 end;

end;

function RunTest(const aFileName:string):Boolean;
var FileNameWithoutPathAndExtension:string;
    Size:TPasRISCVUInt64;
    FailedOnException:Boolean;
    MemoryStream:TMemoryStream;
    MachineInstance:TMachineInstance;
begin

 result:=false;

 FileNameWithoutPathAndExtension:=ChangeFileExt(ExtractFileName(aFileName),'');

 TestErrorCode:=-1; // Reset error code for each test

 VModeTest:=pos('-v-',LowerCase(FileNameWithoutPathAndExtension))>0;

 // Determine fail/pass code based on filename, as some tests expect different results
 if VModeTest then begin
  PassCode:=1;
 end else begin
  PassCode:=0;
 end;

 Write('Running test "',aFileName,'" ... ');

 MachineInstance:=TMachineInstance.Create;
 try

  Machine.OnCPUException:=MachineInstance.OnCPUException;

  Machine.Reset;

  FillChar(Machine.MemoryDevice.Data^,Machine.MemoryDevice.Size,#0);

  MemoryStream:=TMemoryStream.Create;
  try
   MemoryStream.LoadFromFile(aFileName);
   MemoryStream.Seek(0,soBeginning);
   Machine.LoadBinaryIntoMemory(MemoryStream,0,Size,true,true);
  finally
   FreeAndNil(MemoryStream);
  end;

//Machine.MemoryDevice.LoadFromFile(aFileName);

  SetHTIFHostOffsetsFromFileName(aFileName);

  FailedOnException:=false;

  repeat
//   WriteLn('PC=',LowerCase(IntToHex(Machine.HART.State^.PC,16)));
{  if Machine.HART.State^.PC=TPasRISCVUInt64($FFFFFFFFFFE022C8) then begin
    Sleep(0);
   end;//}
{  if Machine.HART.State^.PC=TPasRISCVUInt64($0000000000002AA4) then begin
    Sleep(0);
   end;//}
{  if Machine.HART.State^.PC=TPasRISCVUInt64($0000000000002f1c) then begin
    Sleep(0);
   end;//}
  // Sleep(20);

   Machine.Step;

   HandleHTIF;

   if TestErrorCode>=0 then begin
    break;
   end;

   if not VModeTest then begin
    if (Machine.HART.State^.ExceptionValue<>TPasRISCV.THART.TExceptionValue.None) and
       (Machine.HART.State^.CSR.Load(TPasRISCV.THART.TCSR.TAddress.MTVEC)=0) and
       (Machine.HART.State^.CSR.Load(TPasRISCV.THART.TCSR.TAddress.STVEC)=0) then begin
     FailedOnException:=true;
     break;
    end else begin
     Machine.HART.ClearException;
    end;
   end;

  until false;

  if TestErrorCode=PassCode then begin

   WriteLn('OK!');

   result:=true;

  end else begin

   WriteLn('FAILED!');

   if FailedOnException then begin
    WriteLn('Failed on exception');
   end else begin
    WriteLn('Failed otherwise');
   end;

   WriteLn('PC=',IntToHex(Machine.HART.State^.PC,16));
   WriteLn('HTIFErrorCode=',IntToHex(TestErrorCode,16));

   WriteLn;

  end;

 finally
  FreeAndNil(MachineInstance);
 end;

end;

procedure RunTests;
var StringList:TStringList;
    Index:TPasRISCVInt32;
begin

 Machine:=TPasRISCV.Create;
 try

  StringList:=TStringList.Create;
  try

   GetAllBinaryFiles(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'../externals/pasriscv_software/riscv-tests/binaries/elf/'),StringList);

// RunTest('/home/bero/Projects/GitHub/pasriscv/externals/pasriscv_software/riscv-tests/binaries/elf/rv64mi-p-access.elf');

{} for Index:=0 to StringList.Count-1 do begin
    if false or
       //(pos('f',ChangeFileExt(ExtractFileName(StringList[Index]),''))=1) or
       //(ChangeFileExt(ExtractFileName(StringList[Index]),'')='dirty') or
       //(ChangeFileExt(ExtractFileName(StringList[Index]),'')='illegal') or
       false then begin
     continue;
    end;
    if not RunTest(StringList[Index]) then begin
     Sleep(0);
    end;
   end;//}

  finally
   FreeAndNil(StringList);
  end;

 finally
  FreeAndNil(Machine);
 end;

{$ifndef fpc}
 readln;
{$endif}

end;

begin
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
 if ParamStr(1)='tests' then begin
  RunTests;
 end else begin
  Run;
 end;
end.
