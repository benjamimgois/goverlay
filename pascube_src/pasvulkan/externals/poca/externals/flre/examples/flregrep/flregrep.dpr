program flregrep;
{$ifdef fpc}
 {$mode delphi}
 {$warnings off}
 {$hints off}
 {$define caninline}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
  {$define cpux64}
 {$else}
  {$ifdef cpux86_64}
   {$define cpuamd64}
   {$define cpux64}
  {$endif}
 {$endif}
 {$ifdef cpu386}
  {$define cpu386}
  {$asmmode intel}
  {$define canx86simd}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
{$else}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$safedivide off}
 {$optimization on}
 {$undef caninline}
 {$undef canx86simd}
 {$ifdef ver180}
  {$define caninline}
  {$ifdef cpu386}
   {$define canx86simd}
  {$endif}
  {$finitefloat off}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$extendedsyntax on}
{$writeableconst on}
{$varstringchecks on}
{$typedaddress off}
{$overflowchecks off}
{$rangechecks off}
{$ifndef fpc}
{$realcompatibility off}
{$endif}
{$openstrings on}
{$longstrings on}
{$booleval off}
{$apptype console}

uses
{$ifdef windows}
  Windows,
  MMSystem,
{$endif}
  SysUtils,
  Classes,
  FLRE in '..\..\src\FLRE.pas',
  PUCU in '..\..\src\PUCU.pas',
  BeRoFileMappedStream in '..\common\BeRoFileMappedStream.pas',
  BeRoHighResolutionTimer in '..\common\BeRoHighResolutionTimer.pas';

const mNORMAL=0;
      mCOUNT=1;
      mBENCHMARK=2;

function PtrCopy(const Src:PAnsiChar;From,Len:longint):ansistring;
begin
 SetLength(result,Len);
 if Len>0 then begin
  Move(Src[From],result[1],Len);
 end;
end;

function GetFileList(const Filter:string):TStringList;
var SearchRec:TSearchRec;
    r:longint;
    Flags:longword;
begin
 result:=TStringList.Create;
 try
  Flags:=faAnyFile and not (faDirectory or faVolumeID);
  r:=FindFirst(Filter,Flags,SearchRec);
  while r=0 do begin
   result.Add(AnsiString(SearchRec.Name));
   R:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
 except
  FreeAndNil(result);
 end;
end;

{$ifdef windows}
function IsDebuggerPresent:boolean; stdcall; external 'kernel32.dll' name 'IsDebuggerPresent';
{$endif}

var FLREInstance:TFLRE;
    FileMappedStream:TBeRoFileMappedStream;
    MemoryViewSize,ToDo,SlidingOffset:int64;
    Memory:pointer;
    MultiCaptures:TFLREMultiCaptures;
    FileNameIndex,Count,Index,SubIndex,FirstNewLine,Mode,LastLineOffset,LastEndLineOffset,LineEndOffset,LineOffset,MaximumCount:longint;
    Parameter,Argument,RegularExpression,Directory,FileName:string;
    MemoryString:TFLRERawByteString;
    HasRegularExpression,HasFileName,SuppressErrorMessages,Quiet,LineBuffered,ByteOffset,OnlyMatching,PrintFileName,IsStdIn:boolean;
    RegularExpressionFlags:TFLREFlags;
    SplitCharacter,BufferChar:ansichar;
    HighResolutionTimer:THighResolutionTimer;
    StartTime,EndTime:int64;
    FileNameList,StringList:TStringList;
begin
 RegularExpression:='';
 FileName:='';
 HasRegularExpression:=false;
 HasFileName:=false;
 SuppressErrorMessages:=false;
 Quiet:=false;
 LineBuffered:=false;
 ByteOffset:=false;
 OnlyMatching:=false;
 RegularExpressionFlags:=[];
 SplitCharacter:=#10;
 Mode:=mNORMAL;
 FileNameList:=TStringList.Create;
 try
  Index:=1;
  MaximumCount:=-1;
  while Index<=ParamCount do begin
   Parameter:=ParamStr(Index);
   inc(Index);
   if (length(Parameter)>1) and (Parameter[1]='-') then begin
    SubIndex:=pos('=',Parameter);
    if SubIndex>0 then begin
     Argument:=copy(Parameter,SubIndex+1,length(Parameter)-SubIndex);
     Parameter:=copy(Parameter,1,SubIndex-1);
    end else begin
     Argument:='';
    end;
    if (Parameter='-e') or (Parameter='--regexp') then begin
     if Index<=ParamCount then begin
      RegularExpression:=ParamStr(Index);
      inc(Index);
      HasRegularExpression:=true;
     end else begin
      RegularExpression:=Argument;
      HasRegularExpression:=true;
     end;
    end else if (Parameter='-f') or (Parameter='--file') then begin
     if Index<=ParamCount then begin
      FileName:=ParamStr(Index);
      inc(Index);
     end else begin
      FileName:=Argument;
     end;
     StringList:=TStringList.Create;
     try
      StringList.LoadFromFile(FileName);
      RegularExpression:=StringList.Text;
     finally
      StringList.Free;
     end;
     HasRegularExpression:=true;
    end else if (Parameter='-i') or (Parameter='--ignore-case') then begin
     Include(RegularExpressionFlags,rfIGNORECASE);
    end else if (Parameter='-u') or (Parameter='--utf8') or (Parameter='--utf-8') then begin
     Include(RegularExpressionFlags,rfUTF8);
    end else if (Parameter='-s') or (Parameter='--no-messages') then begin
     SuppressErrorMessages:=true;
    end else if (Parameter='-z') or (Parameter='--null-data') then begin
     SplitCharacter:=#0;
    end else if (Parameter='-c') or (Parameter='--count') then begin
     Mode:=mCOUNT;
    end else if (Parameter='-t') or (Parameter='--timing') or (Parameter='--benchmark') then begin
     Mode:=mBENCHMARK;
    end else if (Parameter='-q') or (Parameter='--quiet') or (Parameter='--silent') then begin
     Quiet:=true;
    end else if (Parameter='--line-buffered') then begin
     LineBuffered:=true;
    end else if (Parameter='-b') or (Parameter='--byte-offset') then begin
     ByteOffset:=true;
    end else if (Parameter='-o') or (Parameter='--only-matching') then begin
     OnlyMatching:=true;
    end else if (Parameter='-m') or (Parameter='--max-count') then begin
     if Index<=ParamCount then begin
      MaximumCount:=StrToIntDef(ParamStr(Index),-1);
      inc(Index);
     end else begin
      MaximumCount:=StrToIntDef(Argument,-1);
     end;
    end else if (Parameter='-h') or (Parameter='--help') then begin
     writeln('Usage: flregrep [OPTION]... PATTERN [FILE]...');
     writeln('Search for PATTERN in each FILE or standard input.');
     writeln('PATTERN is a regular expression');
     writeln('Example: flregrep -i ''hello world'' menu.c menu.h');
     writeln;
     writeln('Regexp selection and interpretation:');
     writeln('  -e, --regexp=PATTERN      use PATTERN for matching');
     writeln('  -f, --file=FILE           obtain PATTERN from FILE');
     writeln('  -i, --ignore-case         ignore case distinctions');
     writeln('  -z, --null-data           a data line ends in 0 byte, not newline');
     writeln;
     writeln('Miscellaneous:');
     writeln('  -s, --no-messages         suppress error messages');
     writeln('      --help                display this help and exit');
     writeln;
     writeln('Output control:');
     writeln('  -u, --utf8, --utf-8       search inside unicode UTF-8 encoding instead latin1');
     writeln('  -m, --max-count=NUM       stop after NUM matches');
     writeln('  -b, --byte-offset         print the byte offset with output lines');
     writeln('      --line-buffered       flush output on every line');
     writeln('  -o, --only-matching       show only the part of a line matching PATTERN');
     writeln('  -q, --quiet, --silent     suppress all normal output');
     writeln('  -c, --count               print only a count of all found matches');
     writeln('  -t, --timing, --benchmark timing benchmark');
     writeln;
     halt(0);
    end;
   end else if length(Parameter)>0 then begin
    if not HasRegularExpression then begin
     RegularExpression:=Parameter;
     HasRegularExpression:=true;
    end else begin
     if Parameter='-' then begin
      FileNameList.Add('-');
      HasFileName:=true;
     end else begin
      if (pos('*',Parameter)>0) or (pos('?',Parameter)>0) then begin
       Directory:=ExcludeTrailingPathDelimiter(ExtractFilePath(Parameter));
       if length(Directory)<>0 then begin
        Directory:=IncludeTrailingPathDelimiter(ExpandFileName(Directory));
      {end else begin
        Directory:=ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
        Directory:=IncludeTrailingPathDelimiter(ExpandFileName(Directory));
      {}end;
       StringList:=GetFileList(Directory+ExtractFileName(Parameter));
       try
        if assigned(StringList) and (StringList.Count>0) then begin
         for FileNameIndex:=0 to StringList.Count-1 do begin
          FileNameList.Add(Directory+StringList[FileNameIndex]);
         end;
         HasFileName:=true;
        end;
       finally
        StringList.Free;
       end;
      end else begin
       FileNameList.Add(Parameter);
       HasFileName:=true;
      end;
     end;
    end;
   end;
  end;
  if not (HasRegularExpression or HasFileName) then begin
   if not Quiet then begin
    writeln('Usage: flregrep [OPTION]... PATTERN [FILE]');
    writeln('Try ''flregrep --help'' for more information.');
   end;
   halt(2);
  end;
  if not HasFileName then begin
   FileNameList.Add('-');
   HasFileName:=true;
  end;
  if not HasRegularExpression then begin
   if not (Quiet or SuppressErrorMessages) then begin
    writeln('flregrep: missing regular expression');
   end;
   halt(2);
  end;
  if not HasFileName then begin
   if not (Quiet or SuppressErrorMessages) then begin
    writeln('flregrep: missing file name');
   end;
   halt(2);
  end;
  try
   FLREInstance:=TFLRE.Create(RegularExpression,RegularExpressionFlags);
   FLREInstance.MaximalDFAStates:=65536;
   try
    PrintFileName:=FileNameList.Count>1;
    for FileNameIndex:=0 to FileNameList.Count-1 do begin
     FileName:=FileNameList[FileNameIndex];
     if FileName='-' then begin
      IsStdIn:=true;
      FileMappedStream:=nil;
     end else begin
      IsStdIn:=false;
      FileMappedStream:=TBeRoFileMappedStream.Create(FileName,fmOpenRead);
     end;
     try
      HighResolutionTimer:=THighResolutionTimer.Create;
      try
       Count:=0;
       SlidingOffset:=0;
       StartTime:=HighResolutionTimer.GetTime;
       while (assigned(FileMappedStream) and (FileMappedStream.Position<FileMappedStream.Size)) or (IsStdIn and not eof(Input)) do begin
        if assigned(FileMappedStream) then begin
         SlidingOffset:=FileMappedStream.Position;
         ToDo:=FileMappedStream.Size-SlidingOffset;
         Memory:=FileMappedStream.Memory;
         MemoryViewSize:=FileMappedStream.MemoryViewSize;
         if ToDo>MemoryViewSize then begin
          ToDo:=MemoryViewSize;
         end;
         if ToDo=0 then begin
          break;
         end;
        end else begin
         MemoryString:='';
         while not eof(Input) do begin
          Read(Input,BufferChar);
          MemoryString:=MemoryString+BufferChar;
          if BufferChar=SplitCharacter then begin
           break;
          end;
         end;
         MemoryViewSize:=length(MemoryString);
         ToDo:=MemoryViewSize;
         if ToDo=0 then begin
          break;
         end;
         Memory:=@MemoryString[1];
        end;
        LastLineOffset:=-1;
        LastEndLineOffset:=-1;
        FirstNewLine:=-1;
        for Index:=0 to ToDo-1 do begin
         if PAnsiChar(Memory)[Index]=SplitCharacter then begin
          // First new line detected
          FirstNewLine:=Index;
          break;
         end;
        end;
        if FirstNewLine>=0 then begin
         for Index:=ToDo-1 downto FirstNewLine do begin
          if PAnsiChar(Memory)[Index]=SplitCharacter then begin
           // New line detected, trimming todo-count to it
           if ToDo>Index then begin
            ToDo:=Index;
           end;
           break;
          end;
         end;
        end;
        if FLREInstance.PtrMatchAll(Memory,ToDo,MultiCaptures,0,MaximumCount) then begin

         case Mode of
          mNORMAL:begin
           if Quiet then begin
            halt(1);
           end else begin
            if OnlyMatching then begin
             for Index:=0 to length(MultiCaptures)-1 do begin
              if ByteOffset then begin
               if PrintFileName then begin
                write(Output,FileName);
               end;
               write(Output,'[',MultiCaptures[Index,0].Start+SlidingOffset,',',MultiCaptures[Index,0].Length,']: ');
              end else begin
               if PrintFileName then begin
                write(Output,FileName,': ');
               end;
              end;
              write(Output,PtrCopy(PAnsiChar(Memory),MultiCaptures[Index,0].Start,MultiCaptures[Index,0].Length));
              writeln(Output);
              if LineBuffered then begin
               Flush(Output);
              end;
             end;
            end else begin
             for Index:=0 to length(MultiCaptures)-1 do begin
              if LastEndLineOffset<MultiCaptures[Index,0].Start then begin
               LineOffset:=0;
               for SubIndex:=MultiCaptures[Index,0].Start downto 0 do begin
                if PAnsiChar(Memory)[SubIndex]=SplitCharacter then begin
                 LineOffset:=SubIndex+1;
                 break;
                end;
               end;
               if LastLineOffset<>LineOffset then begin
                LastLineOffset:=LineOffset;
                LineEndOffset:=ToDo-1;
                for SubIndex:=LineOffset to ToDo-1 do begin
                 if PAnsiChar(Memory)[SubIndex]=SplitCharacter then begin
                  LineEndOffset:=SubIndex-1;
                  LastEndLineOffset:=LineEndOffset;
                  break;
                 end;
                end;
                if ByteOffset then begin
                 if PrintFileName then begin
                  write(Output,FileName);
                 end;
                 write(Output,'[',LineOffset+SlidingOffset,']: ');
                end else begin
                 if PrintFileName then begin
                  write(Output,FileName,': ');
                 end;
                end;
                writeln(Output,PtrCopy(PAnsiChar(Memory),LineOffset,(LineEndOffset-LineOffset)+1));
                if LineBuffered then begin
                 Flush(Output);
                end;
               end;
              end;
             end;
            end;
           end;
          end;
         end;

  {      // Adjust start offsets
         for Index:=0 to length(MultiCaptures)-1 do begin
          for SubIndex:=0 to length(MultiCaptures[Index])-1 do begin
           inc(MultiCaptures[Index,SubIndex].Start,SlidingOffset);
          end;
         end;}

         inc(Count,length(MultiCaptures));

         if MaximumCount>=0 then begin
          if Count>MaximumCount then begin
           dec(Count,MaximumCount);
          end else begin
           break;
          end;
         end;

        end;
        if assigned(FileMappedStream) then begin
         FileMappedStream.Seek(ToDo,soCurrent);
        end;
        if IsStdIn then begin
         inc(SlidingOffset,length(MemoryString));
        end;
       end;
       EndTime:=HighResolutionTimer.GetTime;
       case Mode of
        mCOUNT:begin
         if Quiet then begin
          halt(Count);
         end else begin
          if PrintFileName then begin
           write(Output,FileName,': ');
          end;
          writeln(Count);
         end;
        end;
        mBENCHMARK:begin
         if Quiet then begin
          halt(HighResolutionTimer.ToMilliseconds(EndTime-StartTime));
         end else begin
          if PrintFileName then begin
           write(Output,FileName,': ');
          end;
          writeln(Count,' founds in ',HighResolutionTimer.ToMicroseconds(EndTime-StartTime)/1000.0:1:4,' milliseconds');
         end;
        end;
       end;
      finally
       HighResolutionTimer.Free;
      end;
     finally
      FileMappedStream.Free;
     end;
    end;
   finally
    FLREInstance.Free;
   end;
  except
   on e:Exception do begin
    if not (Quiet or SuppressErrorMessages) then begin
     writeln('flregrep[',e.ClassName,']: ',e.Message);
    end;
    halt(2);
   end;
  end;
 finally
  FileNameList.Free;
 end;
{$ifdef fpc}
 if IsDebuggerPresent then begin
  readln;
 end;
{$else}
 if DebugHook<>0 then begin
  readln;
 end;
{$endif}
 halt(0);
end.
