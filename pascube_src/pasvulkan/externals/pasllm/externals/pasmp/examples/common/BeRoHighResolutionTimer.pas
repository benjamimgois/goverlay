(******************************************************************************
 *                            BeRoHighResolutionTimer                         *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (c) 2015, Benjamin Rosseaux (benjamin@rosseaux.de)               *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 2.6 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that.                     *
 * 4. Don't use Delphi VCL, FreePascal FCL or Lazarus LCL libraries/units.    *
 * 5. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able                                                       *
 * 6. Try to use const when possible.                                         *
 * 7. Make sure to comment out writeln, used while debugging                  *
 * 8. Make sure the code compiles on 32-bit and 64-bit platforms              *
 *                                                                            *
 ******************************************************************************)
unit BeRoHighResolutionTimer;
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

interface

uses {$ifdef windows}
      Windows,
      MMSystem,
     {$else}
      {$ifdef unix}
       BaseUnix,
       Unix,
       UnixType,
       {$ifdef linux}
        linux,
       {$endif}
      {$else}
       SDL,
      {$endif}
     {$endif}
     SysUtils,
     Classes,
     SyncObjs,
     Math;

type THighResolutionTimer=class
      public
       Frequency:int64;
       FrequencyShift:longint;
       FrameInterval:int64;
       MillisecondInterval:int64;
       TwoMillisecondsInterval:int64;
       FourMillisecondsInterval:int64;
       QuarterSecondInterval:int64;
       HourInterval:int64;
       constructor Create(FrameRate:longint=60);
       destructor Destroy; override;
       procedure SetFrameRate(FrameRate:longint);
       function GetTime:int64;
       function GetEventTime:int64;
       procedure Sleep(Delay:int64);
       function ToFixedPointSeconds(Time:int64):int64;
       function ToFixedPointFrames(Time:int64):int64;
       function ToFloatSeconds(Time:int64):double;
       function FromFloatSeconds(Time:double):int64;
       function ToMilliseconds(Time:int64):int64;
       function FromMilliseconds(Time:int64):int64;
       function ToMicroseconds(Time:int64):int64;
       function FromMicroseconds(Time:int64):int64;
       function ToNanoseconds(Time:int64):int64;
       function FromNanoseconds(Time:int64):int64;
       property SecondInterval:int64 read Frequency;
     end;

implementation

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=int64;
{$ifdef cpu64}
     ptruint=qword;
     ptrint=int64;
{$else}
     ptruint=longword;
     ptrint=longint;
{$endif}
{$endif}

type TUInt128=packed record
{$ifdef BIG_ENDIAN}
      case byte of
       0:(
        Hi,Lo:qword;
       );
       1:(
        Q3,Q2,Q1,Q0:longword;
       );
{$else}
      case byte of
       0:(
        Lo,Hi:qword;
       );
       1:(
        Q0,Q1,Q2,Q3:longword;
       );
{$endif}
     end;

function AddWithCarry(const a,b:longword;var Carry:longword):longword; {$ifdef caninline}inline;{$endif}
var r:qword;
begin
 r:=qword(a)+qword(b)+qword(Carry);
 Carry:=(r shr 32) and 1;
 result:=r and $ffffffff;
end;

function MultiplyWithCarry(const a,b:longword;var Carry:longword):longword; {$ifdef caninline}inline;{$endif}
var r:qword;
begin
 r:=(qword(a)*qword(b))+qword(Carry);
 Carry:=r shr 32;
 result:=r and $ffffffff;
end;

function DivideWithRemainder(const a,b:longword;var Remainder:longword):longword; {$ifdef caninline}inline;{$endif}
var r:qword;
begin
 r:=(qword(Remainder) shl 32) or a;
 Remainder:=r mod b;
 result:=r div b;
end;

procedure UInt64ToUInt128(var Dest:TUInt128;const x:qword); {$ifdef caninline}inline;{$endif}
begin
 Dest.Hi:=0;
 Dest.Lo:=x;
end;

procedure UInt128Add(var Dest:TUInt128;const x,y:TUInt128); {$ifdef caninline}inline;{$endif}
var a,b,c,d:qword;
begin
 a:=x.Hi shr 32;
 b:=x.Hi and $ffffffff;
 c:=x.Lo shr 32;
 d:=x.Lo and $ffffffff;
 inc(d,y.Lo and $ffffffff);
 inc(c,(y.Lo shr 32)+(d shr 32));
 inc(b,(y.Hi and $ffffffff)+(c shr 32));
 inc(a,(y.Hi shr 32)+(b shr 32));
 Dest.Hi:=((a and $ffffffff) shl 32) or (b and $ffffffff);
 Dest.Lo:=((c and $ffffffff) shl 32) or (d and $ffffffff);
end;

procedure UInt128Mul(var Dest:TUInt128;const x,y:TUInt128); {$ifdef caninline}inline;{$endif}
var c,xw,yw,dw:array[0..15] of longword;
    i,j,k:longint;
    v:longword;
begin
 for i:=0 to 15 do begin
  c[i]:=0;
 end;
 xw[7]:=(x.Lo shr 0) and $ffff;
 xw[6]:=(x.Lo shr 16) and $ffff;
 xw[5]:=(x.Lo shr 32) and $ffff;
 xw[4]:=(x.Lo shr 48) and $ffff;
 xw[3]:=(x.Hi shr 0) and $ffff;
 xw[2]:=(x.Hi shr 16) and $ffff;
 xw[1]:=(x.Hi shr 32) and $ffff;
 xw[0]:=(x.Hi shr 48) and $ffff;
 yw[7]:=(y.Lo shr 0) and $ffff;
 yw[6]:=(y.Lo shr 16) and $ffff;
 yw[5]:=(y.Lo shr 32) and $ffff;
 yw[4]:=(y.Lo shr 48) and $ffff;
 yw[3]:=(y.Hi shr 0) and $ffff;
 yw[2]:=(y.Hi shr 16) and $ffff;
 yw[1]:=(y.Hi shr 32) and $ffff;
 yw[0]:=(y.Hi shr 48) and $ffff;
 for i:=0 to 7 do begin
  for j:=0 to 7 do begin
   v:=xw[i]*yw[j];
   k:=i+j;
   inc(c[k],v shr 16);
   inc(c[k+1],v and $ffff);
  end;
 end;
 for i:=15 downto 1 do begin
  inc(c[i-1],c[i] shr 16);
  c[i]:=c[i] and $ffff;
 end;
 for i:=0 to 7 do begin
  dw[i]:=c[8+i];
 end;
 Dest.Hi:=(qword(dw[0] and $ffff) shl 48) or (qword(dw[1] and $ffff) shl 32) or (qword(dw[2] and $ffff) shl 16) or (qword(dw[3] and $ffff) shl 0);
 Dest.Lo:=(qword(dw[4] and $ffff) shl 48) or (qword(dw[5] and $ffff) shl 32) or (qword(dw[6] and $ffff) shl 16) or (qword(dw[7] and $ffff) shl 0);
end;

procedure UInt128Div64(var Dest:TUInt128;const Dividend:TUInt128;Divisor:qword); {$ifdef caninline}inline;{$endif}
var Quotient:TUInt128;
    Remainder:qword;
    Bit:longint;
begin
 Quotient:=Dividend;
 Remainder:=0;
 for Bit:=1 to 128 do begin
  Remainder:=(Remainder shl 1) or (ord((Quotient.Hi and $8000000000000000)<>0) and 1);
  Quotient.Hi:=(Quotient.Hi shl 1) or (Quotient.Lo shr 63);
  Quotient.Lo:=Quotient.Lo shl 1;
  if (longword(Remainder shr 32)>longword(Divisor shr 32)) or
     ((longword(Remainder shr 32)=longword(Divisor shr 32)) and (longword(Remainder and $ffffffff)>=longword(Divisor and $ffffffff))) then begin
   dec(Remainder,Divisor);
   Quotient.Lo:=Quotient.Lo or 1;
  end;
 end;
 Dest:=Quotient;
end;

procedure UInt128Mul64(var Dest:TUInt128;u,v:qword); {$ifdef caninline}inline;{$endif}
var u0,u1,v0,v1,k,t,w0,w1,w2:qword;
begin
 u1:=u shr 32;
 u0:=u and qword($ffffffff);
 v1:=v shr 32;
 v0:=v and qword($ffffffff);
 t:=u0*v0;
 w0:=t and qword($ffffffff);
 k:=t shr 32;
 t:=(u1*v0)+k;
 w1:=t and qword($ffffffff);
 w2:=t shr 32;
 t:=(u0*v1)+w1;
 k:=t shr 32;
 Dest.Lo:=(t shl 32)+w0;
 Dest.Hi:=((u1*v1)+w2)+k;
end;

constructor THighResolutionTimer.Create(FrameRate:longint=60);
begin
 inherited Create;
 FrequencyShift:=0;
{$ifdef windows}
 if QueryPerformanceFrequency(Frequency) then begin
  while (Frequency and $ffffffffe0000000)<>0 do begin
   Frequency:=Frequency shr 1;
   inc(FrequencyShift);
  end;
 end else begin
  Frequency:=1000;
 end;
{$else}
{$ifdef linux}
  Frequency:=1000000000;
{$else}
{$ifdef unix}
  Frequency:=1000000;
{$else}
  Frequency:=1000;
{$endif}
{$endif}
{$endif}
 FrameInterval:=(Frequency+((abs(FrameRate)+1) shr 1)) div abs(FrameRate);
 MillisecondInterval:=(Frequency+500) div 1000;
 TwoMillisecondsInterval:=(Frequency+250) div 500;
 FourMillisecondsInterval:=(Frequency+125) div 250;
 QuarterSecondInterval:=(Frequency+2) div 4;
 HourInterval:=Frequency*3600;
end;

destructor THighResolutionTimer.Destroy;
begin
 inherited Destroy;
end;

procedure THighResolutionTimer.SetFrameRate(FrameRate:longint);
begin
 FrameInterval:=(Frequency+((abs(FrameRate)+1) shr 1)) div abs(FrameRate);
end;

function THighResolutionTimer.GetTime:int64;
{$ifdef linux}
var NowTimeSpec:TimeSpec;
    ia,ib:int64;
{$else}
{$ifdef unix}
var tv:timeval;
    tz:timezone;
    ia,ib:int64;
{$endif}
{$endif}
begin
{$ifdef windows}
 if not QueryPerformanceCounter(result) then begin
  result:=timeGetTime;
 end;
{$else}
{$ifdef linux}
 clock_gettime(CLOCK_MONOTONIC,@NowTimeSpec);
 ia:=int64(NowTimeSpec.tv_sec)*int64(1000000000);
 ib:=NowTimeSpec.tv_nsec;
 result:=ia+ib;
{$else}
{$ifdef unix}
  tz.tz_minuteswest:=0;
  tz.tz_dsttime:=0;
  fpgettimeofday(@tv,@tz);
  ia:=int64(tv.tv_sec)*int64(1000000);
  ib:=tv.tv_usec;
  result:=ia+ib;
{$else}
 result:=SDL_GetTicks;
{$endif}
{$endif}
{$endif}
 result:=result shr FrequencyShift;
end;

function THighResolutionTimer.GetEventTime:int64;
begin
 result:=ToNanoseconds(GetTime);
end;

procedure THighResolutionTimer.Sleep(Delay:int64);
var EndTime,NowTime{$ifdef unix},SleepTime{$endif}:int64;
{$ifdef unix}
    req,rem:timespec;
{$endif}
begin
 if Delay>0 then begin
{$ifdef windows}
  NowTime:=GetTime;
  EndTime:=NowTime+Delay;
  while (NowTime+TwoMillisecondsInterval)<EndTime do begin
   Sleep(1);
   NowTime:=GetTime;
  end;
  while (NowTime+MillisecondInterval)<EndTime do begin
   Sleep(0);
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$else}
{$ifdef linux}
  NowTime:=GetTime;
  EndTime:=NowTime+Delay;
  while true do begin
   SleepTime:=abs(EndTime-NowTime);
   if SleepTime>=FourMillisecondsInterval then begin
    SleepTime:=(SleepTime+2) shr 2;
    if SleepTime>0 then begin
     req.tv_sec:=SleepTime div 1000000000;
     req.tv_nsec:=SleepTime mod 10000000000;
     fpNanoSleep(@req,@rem);
     NowTime:=GetTime;
     continue;
    end;
   end;
   break;
  end;
  while (NowTime+TwoMillisecondsInterval)<EndTime do begin
   ThreadSwitch;
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$else}
{$ifdef unix}
  NowTime:=GetTime;
  EndTime:=NowTime+Delay;
  while true do begin
   SleepTime:=abs(EndTime-NowTime);
   if SleepTime>=FourMillisecondsInterval then begin
    SleepTime:=(SleepTime+2) shr 2;
    if SleepTime>0 then begin
     req.tv_sec:=SleepTime div 1000000;
     req.tv_nsec:=(SleepTime mod 1000000)*1000;
     fpNanoSleep(@req,@rem);
     NowTime:=GetTime;
     continue;
    end;
   end;
   break;
  end;
  while (NowTime+TwoMillisecondsInterval)<EndTime do begin
   ThreadSwitch;
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$else}
  NowTime:=GetTime;
  EndTime:=NowTime+Delay;
  while (NowTime+4)<EndTime then begin
   SDL_Delay(1);
   NowTime:=GetTime;
  end;
  while (NowTime+2)<EndTime do begin
   SDL_Delay(0);
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$endif}
{$endif}
{$endif}
 end;
end;

function THighResolutionTimer.ToFixedPointSeconds(Time:int64):int64;
var a,b:TUInt128;
begin
 if Frequency<>0 then begin
  if ((Frequency or Time) and int64($ffffffff00000000))=0 then begin
   result:=int64(qword(qword(Time)*qword($100000000)) div qword(Frequency));
  end else begin
   UInt128Mul64(a,Time,qword($100000000));
   UInt128Div64(b,a,Frequency);
   result:=b.Lo;
  end;
 end else begin
  result:=0;
 end;
end;

function THighResolutionTimer.ToFixedPointFrames(Time:int64):int64;
var a,b:TUInt128;
begin
 if FrameInterval<>0 then begin
  if ((FrameInterval or Time) and int64($ffffffff00000000))=0 then begin
   result:=int64(qword(qword(Time)*qword($100000000)) div qword(FrameInterval));
  end else begin
   UInt128Mul64(a,Time,qword($100000000));
   UInt128Div64(b,a,FrameInterval);
   result:=b.Lo;
  end;
 end else begin
  result:=0;
 end;
end;

function THighResolutionTimer.ToFloatSeconds(Time:int64):double;
begin
 if Frequency<>0 then begin
  result:=Time/Frequency;
 end else begin
  result:=0;
 end;
end;

function THighResolutionTimer.FromFloatSeconds(Time:double):int64;
begin
 if Frequency<>0 then begin
  result:=trunc(Time*Frequency);
 end else begin
  result:=0;
 end;
end;

function THighResolutionTimer.ToMilliseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000 then begin
  result:=((Time*1000)+((Frequency+1) shr 1)) div Frequency;
 end;
end;

function THighResolutionTimer.FromMilliseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000 then begin
  result:=((Time*Frequency)+500) div 1000;
 end;
end;

function THighResolutionTimer.ToMicroseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000000 then begin
  result:=((Time*1000000)+((Frequency+1) shr 1)) div Frequency;
 end;
end;

function THighResolutionTimer.FromMicroseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000000 then begin
  result:=((Time*Frequency)+500000) div 1000000;
 end;
end;

function THighResolutionTimer.ToNanoseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000000000 then begin
  result:=((Time*1000000000)+((Frequency+1) shr 1)) div Frequency;
 end;
end;

function THighResolutionTimer.FromNanoseconds(Time:int64):int64;
begin
 result:=Time;
 if Frequency<>1000000000 then begin
  result:=((Time*Frequency)+500000000) div 1000000000;
 end;
end;

initialization
{$ifdef windows}
 timeBeginPeriod(1);
{$endif}
finalization
{$ifdef windows}
 timeEndPeriod(1);
{$endif}
end.
 