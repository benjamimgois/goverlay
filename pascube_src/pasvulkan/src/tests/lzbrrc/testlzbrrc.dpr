program testlzbrrc;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$legacyifend on}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
 {$apptype console}
{$endif}

(*{$ifdef Unix}
      cthreads,
     {$endif}*)

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Compression.LZBRRC;

procedure TestLZBRRCCompress;
var InputFileStream:TFileStream;
    OutputFileStream:TFileStream;
    CompressedSize:TpvUInt64;
    UncompressedSize:TpvUInt64;
    CompressedData:Pointer;
    UncompressedData:Pointer;
begin

 Write('Compressing... ');

 InputFileStream:=TFileStream.Create('input.dat',fmOpenRead {or fmShareDenyNone});
 try
  UncompressedSize:=InputFileStream.Size;
  GetMem(UncompressedData,InputFileStream.Size);
  InputFileStream.ReadBuffer(UncompressedData^,InputFileStream.Size);
 finally
  FreeAndNil(InputFileStream);
 end;

 CompressedData:=nil;

 if LZBRRCCompress(UncompressedData,UncompressedSize,CompressedData,CompressedSize,TpvLZBRRCLevel(5)) then begin
 
  OutputFileStream:=TFileStream.Create('output.dat',fmCreate);
  try
   OutputFileStream.WriteBuffer(CompressedData^,CompressedSize);
  finally
   FreeAndNil(OutputFileStream);
  end;

  FreeMem(CompressedData);
  CompressedData:=nil;
  
 end; 

 FreeMem(UncompressedData);
 UncompressedData:=nil;

 WriteLn('done!');

end;

procedure TestLZBRRCDecompress;
var InputFileStream:TFileStream;
    OutputFileStream:TFileStream;
    CompressedSize:TpvUInt64;
    UncompressedSize:TpvUInt64;
    CompressedData:Pointer;
    UncompressedData:Pointer;
begin

 Write('Decompressing... ');
 
 InputFileStream:=TFileStream.Create('output.dat',fmOpenRead {or fmShareDenyNone});
 try
  CompressedSize:=InputFileStream.Size;
  GetMem(CompressedData,CompressedSize);
  InputFileStream.ReadBuffer(CompressedData^,CompressedSize);
 finally
  FreeAndNil(InputFileStream);
 end;

 UncompressedData:=nil;

 if
{$if declared(LZBRRCFastDecompress)}
    LZBRRCFastDecompress(CompressedData,CompressedSize,UncompressedData,UncompressedSize)
{$else}
    LZBRRCDecompress(CompressedData,CompressedSize,UncompressedData,UncompressedSize)
{$ifend}
    then begin
 
  OutputFileStream:=TFileStream.Create('output2.dat',fmCreate);
  try
   OutputFileStream.WriteBuffer(UncompressedData^,UncompressedSize);
  finally
   FreeAndNil(OutputFileStream);
  end;

  FreeMem(UncompressedData);
  UncompressedData:=nil;
  
 end; 

 FreeMem(CompressedData);
 CompressedData:=nil;

 WriteLn('done!');

end;

procedure TestCompare;
var OriginalFileStream:TFileStream;
    UncompressedFileStream:TFileStream;
    OriginalSize:TpvUInt64;
    UncompressedSize:TpvUInt64;
    Index:TpvUInt64;
    OK:boolean;
    OriginalData:Pointer;
    UncompressedData:Pointer;
begin

 Write('Comparing... ');

 OriginalFileStream:=TFileStream.Create('input.dat',fmOpenRead {or fmShareDenyNone});
 try
  OriginalSize:=OriginalFileStream.Size;
  GetMem(OriginalData,OriginalFileStream.Size);
  OriginalFileStream.ReadBuffer(OriginalData^,OriginalFileStream.Size);
 finally
  FreeAndNil(OriginalFileStream);
 end;

 UncompressedFileStream:=TFileStream.Create('output2.dat',fmOpenRead {or fmShareDenyNone});
 try
  UncompressedSize:=UncompressedFileStream.Size;
  GetMem(UncompressedData,UncompressedFileStream.Size);
  UncompressedFileStream.ReadBuffer(UncompressedData^,UncompressedFileStream.Size);
 finally
  FreeAndNil(UncompressedFileStream);
 end;

 if OriginalSize=UncompressedSize then begin
  OK:=true;
  for Index:=1 to OriginalSize do begin
   if PByte(UncompressedData)[Index-1]<>PByte(OriginalData)[Index-1] then begin
     WriteLn('Failed because of different data at byte position ',Index-1,'!');
    OK:=false;
    break;
   end;
  end;
  if OK then begin
   WriteLn('OK!');
  end;
 end else begin
  WriteLn('Failed because of different sizes!');
 end;

 FreeMem(UncompressedData);
 UncompressedData:=nil;

 FreeMem(OriginalData);
 OriginalData:=nil;
  
end;

procedure DebugBroken; // broken_original.bin broken_compressed.bin broken_decompressed.bin 
var OriginalFileStream:TFileStream;
    CompressedFileStream:TFileStream;
    UncompressedFileStream:TFileStream;
    OriginalSize:TpvUInt64;
    CompressedOriginalSize:TpvUInt64;
    CompressedSize:TpvUInt64;
    UncompressedCompressedSize:TpvUInt64;
    UncompressedSize:TpvUInt64;
    Index:TpvUInt64;
    OK:boolean;
    OriginalData:Pointer;
    CompressedOriginalData:Pointer;
    CompressedData:Pointer;
    UncompressedCompressedData:Pointer;
    UncompressedData:Pointer;
begin

 OriginalFileStream:=TFileStream.Create('broken_original.bin',fmOpenRead {or fmShareDenyNone});
 try
  OriginalSize:=OriginalFileStream.Size;
  GetMem(OriginalData,OriginalFileStream.Size);
  OriginalFileStream.ReadBuffer(OriginalData^,OriginalFileStream.Size);
 finally
  FreeAndNil(OriginalFileStream);
 end;

 CompressedFileStream:=TFileStream.Create('broken_compressed.bin',fmOpenRead {or fmShareDenyNone});
 try
  CompressedOriginalSize:=CompressedFileStream.Size;
  GetMem(CompressedData,CompressedFileStream.Size);
  CompressedFileStream.ReadBuffer(CompressedData^,CompressedFileStream.Size);
 finally
  FreeAndNil(CompressedFileStream);
 end;

 UncompressedFileStream:=TFileStream.Create('broken_decompressed.bin',fmOpenRead {or fmShareDenyNone});
 try
  UncompressedSize:=UncompressedFileStream.Size;
  GetMem(UncompressedData,UncompressedFileStream.Size);
  UncompressedFileStream.ReadBuffer(UncompressedData^,UncompressedFileStream.Size);
 finally
  FreeAndNil(UncompressedFileStream);
 end;

 CompressedOriginalData:=nil;
 UncompressedCompressedData:=nil;

 if LZBRRCCompress(OriginalData,OriginalSize,CompressedOriginalData,CompressedOriginalSize,TpvLZBRRCLevel(5),false) then begin
  UncompressedCompressedData:=nil;
  if LZBRRCDecompress(CompressedOriginalData,CompressedOriginalSize,UncompressedCompressedData,UncompressedCompressedSize,OriginalSize,false) then begin
   if OriginalSize=UncompressedCompressedSize then begin
    OK:=true;
    for Index:=1 to Min(OriginalSize,UncompressedCompressedSize) do begin
     if PpvUInt8Array(UncompressedCompressedData)^[Index-1]<>PpvUInt8Array(OriginalData)^[Index-1] then begin
      WriteLn('Failed because of different data at byte position ',Index-1,'!');
      OK:=false;
      break;
     end;
    end;
    if OK then begin
     WriteLn('OK!');
    end;
   end else begin
    WriteLn('Failed because of different sizes!');
   end;
  end else begin
   WriteLn('Failed to decompress!');
  end;
 end else begin
  WriteLn('Failed to compress!');
 end;

 if assigned(UncompressedData) then begin
  FreeMem(UncompressedData);
  UncompressedData:=nil;
 end;
 
 if assigned(UncompressedCompressedData) then begin
  FreeMem(UncompressedCompressedData);
  UncompressedCompressedData:=nil;
 end;

 if assigned(CompressedData) then begin
  FreeMem(CompressedData);
  CompressedData:=nil;
 end;

 if assigned(CompressedOriginalData) then begin
  FreeMem(CompressedOriginalData);
  CompressedOriginalData:=nil;
 end;

 if assigned(OriginalData) then begin
  FreeMem(OriginalData);
  OriginalData:=nil;
 end;

end;

begin
 
 try

  TestLZBRRCCompress;
  TestLZBRRCDecompress;
  TestCompare;//}

//DebugBroken;

 except
  on e:Exception do begin
   WriteLn('Exception: ',e.Message);
  end;
 end;

{WriteLn('Press enter to continue...');
 ReadLn;//}

end.

