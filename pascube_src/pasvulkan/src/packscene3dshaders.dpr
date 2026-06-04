program packscene3dshaders;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {-$pic off}
 {$define CAN_INLINE}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef WinCE}
 {$define Windows}
{$endif}
{$ifdef Windows}
 {$define Win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define CAN_INLINE}
{$else}
 {$undef CAN_INLINE}
 {$ifdef ver180}
  {$define CAN_INLINE}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define CAN_INLINE}
   {$ifend}
  {$endif}
 {$endif}
{$endif}
{$ifdef windows}
 {$apptype console}
{$endif}
{$undef UNICODE}

uses {$ifdef Unix}cthreads,{$endif}
     SysUtils,
     Classes,
     Math,
     PasMP in '../externals/pasmp/src/PasMP.pas',
     PUCU in '../externals/pucu/src/PUCU.pas',
     PasDblStrUtils in '../externals/pasdblstrutils/src/PasDblStrUtils.pas',
     PasJSON in '../externals/pasjson/src/PasJSON.pas',
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Compression.LZMA,
     PasVulkan.Compression,
     PasVulkan.Archive.SPK;

var OutputFileName,InputFileListFileName,FileName:String;
    InputFileList:TStringList;
    FileIndex:TpvSizeInt;
    Archive:TpvArchiveSPK;
    Stream:TMemoryStream;
    TemporaryUncompressedStream,TemporaryCompressedStream:TMemoryStream;
    PasMPInstance:TPasMP;
begin
 
 PasMPInstance:=TPasMP.GetGlobalInstance;

 OutputFileName:=ParamStr(1);
 InputFileListFileName:=ParamStr(2);

 InputFileList:=TStringList.Create;
 try

  InputFileList.LoadFromFile(InputFileListFileName);

  Archive:=TpvArchiveSPK.Create;
  try

   for FileIndex:=0 to InputFileList.Count-1 do begin
    FileName:=InputFileList[FileIndex];
    WriteLn('Adding "',FileName,'" . . .');
    Stream:=TMemoryStream.Create;
    try
     Stream.LoadFromFile(FileName);
    finally 
     Archive.AddFile(LowerCase(FileName),Stream);
    end; 
   end;

   TemporaryUncompressedStream:=TMemoryStream.Create;
   try
    
    WriteLn('Saving . . .');
    Archive.SaveToStream(TemporaryUncompressedStream);

    TemporaryCompressedStream:=TMemoryStream.Create;
    try
     
     WriteLn('Compressing . . .');
     //LZMACompressStream(TemporaryUncompressedStream,TemporaryCompressedStream,9);
     pvCompressionPasMPInstance:=PasMPInstance;
     TemporaryUncompressedStream.Seek(0,soBeginning);
     if (ParamCount>=3) and (ParamStr(3)='lzma') then begin
      // Slower and with 1 thread but much better compression
      CompressStream(TemporaryUncompressedStream,TemporaryCompressedStream,TpvCompressionMethod.LZMA,9,1);//Min(Max(PasMPInstance.CountJobWorkerThreads,4),8));
     end else begin
      // Faster and with 8 threads but worse compression
      CompressStream(TemporaryUncompressedStream,TemporaryCompressedStream,TpvCompressionMethod.LZBRRC,7,8);//Min(Max(PasMPInstance.CountJobWorkerThreads,4),8));
     end;

     WriteLn('Saving to "',OutputFileName,'" . . .');
     TemporaryCompressedStream.SaveToFile(OutputFileName);

     //TemporaryUncompressedStream.SaveToFile(ChangeFileExt(OutputFileName,'')+'.uncompressed'+ExtractFileExt(OutputFileName));

    finally
     FreeAndNil(TemporaryCompressedStream);
    end;

   finally
    FreeAndNil(TemporaryUncompressedStream);
   end; 

  finally
   FreeAndNil(Archive);
  end;  
  
 finally
  InputFileList.Free;
 end;

 WriteLn('Done.');

end.     
     