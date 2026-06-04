program BenchmarkRawByteStringVersusArrayOfByte;
{$ifdef FPC}
  {$mode delphi}
{$endif}

uses SysUtils,Classes;

const NumIterations=10000000;

type TBytes=array of Byte;
     
     TDataBuffer=record
      Data:TBytes;
      Len:UInt64;
     end;
     PDataBuffer=^TDataBuffer;

var DataBuffer:TDataBuffer;
   
procedure AddRawByteStringToDataBuffer(var aDataBuffer:TDataBuffer;const aData:RawByteString);
var Len,Position:UInt64;
begin
 Len:=Length(aData);
 if Len>0 then begin
  Position:=aDataBuffer.Len;
  inc(aDataBuffer.Len,Len);
  if length(aDataBuffer.Data)<aDataBuffer.Len then begin
   SetLength(aDataBuffer.Data,aDataBuffer.Len*2);
  end;
  Move(aData[1],aDataBuffer.Data[Position],Len);
 end; 
end;

procedure AddArrayOfByteToDataBuffer(var aDataBuffer:TDataBuffer;const aData:array of Byte);
var Len,Position:UInt64;
begin
 Len:=Length(aData);
 if Len>0 then begin
  Position:=aDataBuffer.Len;
  inc(aDataBuffer.Len,Len);
  if length(aDataBuffer.Data)<aDataBuffer.Len then begin
   SetLength(aDataBuffer.Data,aDataBuffer.Len*2);
  end;
  Move(aData[0],aDataBuffer.Data[Position],Len);
 end; 
end;

var StartTime,EndTime:Int64;
    Index:Int32;
    RBS:RawByteString;
    AOB:array of Byte;
begin
 
 RBS:=#$00#$01#$12#$34#$56#$78#$9a#$bc#$de#$f0;
 
 SetLength(AOB,Length(RBS));
 Move(RBS[1],AOB[0],Length(RBS));

 DataBuffer.Data:=nil;
 DataBuffer.Len:=0;
 StartTime:=GetTickCount64;
 for Index:=1 to NumIterations do begin
  AddRawByteStringToDataBuffer(DataBuffer,RBS);
 end;
 EndTime:=GetTickCount64;
 Writeln('RawByteString Time (ms): ',EndTime-StartTime);

 DataBuffer.Data:=nil;
 DataBuffer.Len:=0;
 StartTime:=GetTickCount64;
 for Index:=1 to NumIterations do begin
  AddRawByteStringToDataBuffer(DataBuffer,#$00#$01#$12#$34#$56#$78#$9a#$bc#$de#$f0);
 end;
 EndTime:=GetTickCount64;
 Writeln('Const RawByteString Time (ms): ',EndTime-StartTime);

 DataBuffer.Data:=nil;
 DataBuffer.Len:=0;
 StartTime:=GetTickCount64;
 for Index:=1 to NumIterations do begin
  AddArrayOfByteToDataBuffer(DataBuffer,AOB);
 end;
 EndTime:=GetTickCount64;
 Writeln('Array of Byte Time (ms): ',EndTime-StartTime);

 DataBuffer.Data:=nil;
 DataBuffer.Len:=0;
 StartTime:=GetTickCount64;
 for Index:=1 to NumIterations do begin
  AddArrayOfByteToDataBuffer(DataBuffer,[$00,$01,$12,$34,$56,$78,$9a,$bc,$de,$f0]);
 end;
 EndTime:=GetTickCount64;
 Writeln('Open Array of Byte Time (ms): ',EndTime-StartTime);

end.