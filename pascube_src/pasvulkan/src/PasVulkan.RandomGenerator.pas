(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2024, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.RandomGenerator;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses {$ifdef windows}Windows,MMSystem,{$endif}
     {$ifdef unix}dl,BaseUnix,Unix,UnixType,{$endif}
     SysUtils,Classes,Math,SyncObjs,
     PasVulkan.Types;

type PpvRandomGeneratorPCG32=^TpvRandomGeneratorPCG32;
     TpvRandomGeneratorPCG32=record
      State:TpvUInt64;
      Increment:TpvUInt64;
     end;

     PpvRandomGeneratorSplitMix64=^TpvRandomGeneratorSplitMix64;
     TpvRandomGeneratorSplitMix64=TpvUInt64;

     PpvRandomGeneratorLCG64=^TpvRandomGeneratorLCG64;
     TpvRandomGeneratorLCG64=TpvUInt64;

     PpvRandomGeneratorMWC=^TpvRandomGeneratorMWC;
     TpvRandomGeneratorMWC=record
      x:TpvUInt32;
      y:TpvUInt32;
      c:TpvUInt32;
     end;

     PpvRandomGeneratorXorShift128=^TpvRandomGeneratorXorShift128;
     TpvRandomGeneratorXorShift128=record
      x,y,z,w:TpvUInt32;
     end;

     PpvRandomGeneratorXorShift128Plus=^TpvRandomGeneratorXorShift128Plus;
     TpvRandomGeneratorXorShift128Plus=record
      s:array[0..1] of TpvUInt64;
     end;

     PpvRandomGeneratorXorShift1024=^TpvRandomGeneratorXorShift1024;
     TpvRandomGeneratorXorShift1024=record
      s:array[0..15] of TpvUInt64;
      p:TpvInt32;
     end;

     PpvRandomGeneratorCMWC4096=^TpvRandomGeneratorCMWC4096;
     TpvRandomGeneratorCMWC4096=record
      Q:array[0..4095] of TpvUInt64;
      QC:TpvUInt64;
      QJ:TpvUInt64;
     end;

     PpvRandomGeneratorState=^TpvRandomGeneratorState;
     TpvRandomGeneratorState=record
      LCG64:TpvRandomGeneratorLCG64;
      XorShift1024:TpvRandomGeneratorXorShift1024;
      CMWC4096:TpvRandomGeneratorCMWC4096;
     end;

     TpvRandomGenerator=class
      private
       fState:TpvRandomGeneratorState;
       fGaussianFloatUseLast:boolean;
       fGaussianFloatLast:TpvFloat;
       fGaussianDoubleUseLast:boolean;
       fGaussianDoubleLast:TpvDouble;
       fCriticalSection:TCriticalSection;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Reinitialize(FixedSeed:TpvUInt64=TpvUInt64($ffffffffffffffff));
       function Get32:TpvUInt32;
       function Get64:TpvUInt64;
       function Get(Limit:TpvUInt32):TpvUInt32;
       function GetFloat:TpvFloat; // -1.0.0 .. 1.0
       function GetFloatAbs:TpvFloat; // 0.0 .. 1.0
       function GetDouble:TpvDouble; // -1.0.0 .. 1.0
       function GetDoubleAbs:TpvDouble; // 0.0 .. 1.0
       function GetGaussianFloat:TpvFloat; // -1.0 .. 1.0
       function GetGaussianFloatAbs:TpvFloat; // 0.0 .. 1.0
       function GetGaussianDouble:TpvDouble; // -1.0 .. 1.0
       function GetGaussianDoubleAbs:TpvDouble; // 0.0 .. 1.0
       function GetGaussian(Limit:TpvUInt32):TpvUInt32;
       function GetUInt32Range(const aMin,aMax:TpvUInt32):TpvUInt32; // aMin .. aMax 
       function GetFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax 
       function GetDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
       function GetGaussianFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
       function GetGaussianDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
     end;

     TpvRandomUnique32BitSequence=class
      private
       fIndex:TpvUInt32;
       fIntermediateOffset:TpvUInt32;
       function PermuteQPR(x:TpvUInt32):TpvUInt32;
      public
       constructor Create(const Seed1:TpvUInt32=$b46f23c7;const Seed2:TpvUInt32=$a54c2364);
       destructor Destroy; override;
       function Next:TpvUInt32;
     end;

     { TpvPCG32 }

     TpvPCG32=record
      private
       const DefaultState=TpvUInt64($853c49e6748fea9b);
             DefaultStream=TpvUInt64($da3e39cb94b95bdb);
             Mult=TpvUInt64($5851f42d4c957f2d);
      private
       fState:TpvUInt64;
       fIncrement:TpvUInt64;
       fGaussianFloatUseLast:boolean;
       fGaussianFloatLast:TpvFloat;
       fGaussianDoubleUseLast:boolean;
       fGaussianDoubleLast:TpvDouble;
      public
       procedure Init(const aSeed:TpvUInt64=0);
       function Get32:TpvUInt32; {$ifdef caninline}inline;{$endif}
       function Get64:TpvUInt64; {$ifdef caninline}inline;{$endif}
       function GetBiasedBounded32Bit(const aRange:TpvUInt32):TpvUInt32; {$ifdef caninline}inline;{$endif}
       function GetUnbiasedBounded32Bit(const aRange:TpvUInt32):TpvUInt32;
       function Get(Limit:TpvUInt32):TpvUInt32;
       function GetFloat:TpvFloat; // -1.0 .. 1.0
       function GetFloatAbs:TpvFloat; // 0.0 .. 1.0
       function GetDouble:TpvDouble; // -1.0 .. 1.0
       function GetDoubleAbs:TpvDouble; // 0.0 .. 1.0
       function GetGaussianFloat:TpvFloat; // -1.0 .. 1.0
       function GetGaussianFloatAbs:TpvFloat; // 0.0 .. 1.0
       function GetGaussianDouble:TpvDouble; // -1.0 .. 1.0
       function GetGaussianDoubleAbs:TpvDouble; // 0.0 .. 1.0
       function GetGaussian(Limit:TpvUInt32):TpvUInt32;
       function GetUInt32Range(const aMin,aMax:TpvUInt32):TpvUInt32; // aMin .. aMax 
       function GetFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax 
       function GetDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
       function GetGaussianFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
       function GetGaussianDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
     end;
     PpvPCG32=^TpvPCG32;

var pvPCG32:TpvPCG32; // Default global PCG32 random generator instance

function PCG32Next(var State:TpvRandomGeneratorPCG32):TpvUInt64; {$ifdef caninline}inline;{$endif}

function SplitMix64Next(var State:TpvRandomGeneratorSplitMix64):TpvUInt64; {$ifdef caninline}inline;{$endif}

function LCG64Next(var State:TpvRandomGeneratorLCG64):TpvUInt64; {$ifdef caninline}inline;{$endif}

function XorShift128Next(var State:TpvRandomGeneratorXorShift128):TpvUInt32; {$ifdef caninline}inline;{$endif}

function XorShift128PlusNext(var State:TpvRandomGeneratorXorShift128Plus):TpvUInt64; {$ifdef caninline}inline;{$endif}
procedure XorShift128PlusJump(var State:TpvRandomGeneratorXorShift128Plus);

function XorShift1024Next(var State:TpvRandomGeneratorXorShift1024):TpvUInt64; {$ifdef caninline}inline;{$endif}
procedure XorShift1024Jump(var State:TpvRandomGeneratorXorShift1024);

function CMWC4096Next(var State:TpvRandomGeneratorCMWC4096):TpvUInt64; {$ifdef caninline}inline;{$endif}

implementation

{$if defined(fpc) and declared(BSRDWord)}
function CLZDWord(Value:TpvUInt32):TpvUInt32;
begin
 if Value=0 then begin
  result:=0;
 end else begin
  result:=31-BSRDWord(Value);
 end;
end;
{$elseif defined(cpu386)}
function CLZDWord(Value:TpvUInt32):TpvUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr edx,eax
 jnz @Done
 xor edx,edx
 not edx
@Done:
 mov eax,31
 sub eax,edx
end;
{$elseif defined(cpux64) or defined(cpuamd64)}
function CLZDWord(Value:TpvUInt32):TpvUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr ecx,ecx
 jnz @Done
 xor ecx,ecx
 not ecx
@Done:
 mov eax,31
 sub eax,ecx
{$else}
 bsr edi,edi
 jnz @Done
 xor edi,edi
 not edi
@Done:
 mov eax,31
 sub eax,edi
{$endif}
end;
{$else}
function CLZDWord(Value:TpvUInt32):TPasMPInt32;
const CLZDebruijn32Multiplicator=TpvUInt32($07c4acdd);
      CLZDebruijn32Shift=27;
      CLZDebruijn32Mask=31;
      CLZDebruijn32Table:array[0..31] of TpvInt32=(31,22,30,21,18,10,29,2,20,17,15,13,9,6,28,1,23,19,11,3,16,14,7,24,12,4,8,25,5,26,27,0);
begin
 if Value=0 then begin
  result:=32;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  result:=CLZDebruijn32Table[((TpvUInt32(Value)*CLZDebruijn32Multiplicator) shr CLZDebruijn32Shift) and CLZDebruijn32Mask];
 end;
end;
{$ifend}

function PCG32Next(var State:TpvRandomGeneratorPCG32):TpvUInt64; {$ifdef caninline}inline;{$endif}
var OldState:TpvUInt64;
    XorShifted,Rot:TpvUInt32;
begin
 OldState:=State.State;
 State.State:=(OldState*TpvUInt64(6364136223846793005))+(State.Increment or 1);
 XorShifted:=TpvUInt64((OldState shr 18) xor OldState) shr 27;
 Rot:=OldState shr 59;
 result:=(XorShifted shr rot) or (TpvUInt64(XorShifted) shl ((-Rot) and 31));
end;

function SplitMix64Next(var State:TpvRandomGeneratorSplitMix64):TpvUInt64; {$ifdef caninline}inline;{$endif}
var z:TpvUInt64;
begin
 State:=State+{$ifndef fpc}TpvUInt64{$endif}($9e3779b97f4a7c15);
 z:=State;
 z:=(z xor (z shr 30))*{$ifndef fpc}TpvUInt64{$endif}($bf58476d1ce4e5b9);
 z:=(z xor (z shr 27))*{$ifndef fpc}TpvUInt64{$endif}($94d049bb133111eb);
 result:=z xor (z shr 31);
end;

function LCG64Next(var State:TpvRandomGeneratorLCG64):TpvUInt64; {$ifdef caninline}inline;{$endif}
begin
 State:=(State*TpvUInt64(2862933555777941757))+TpvUInt64(3037000493);
 result:=State;
end;

function XorShift128Next(var State:TpvRandomGeneratorXorShift128):TpvUInt32; {$ifdef caninline}inline;{$endif}
var t:TpvUInt32;
begin
 t:=State.x xor (State.x shl 11);
 State.x:=State.y;
 State.y:=State.z;
 State.z:=State.w;
 State.w:=(State.w xor (State.w shr 19)) xor (t xor (t shr 8));
 result:=State.w;
end;

function XorShift128PlusNext(var State:TpvRandomGeneratorXorShift128Plus):TpvUInt64; {$ifdef caninline}inline;{$endif}
var s0,s1:TpvUInt64;
begin
 s1:=State.s[0];
 s0:=State.s[1];
 State.s[0]:=s0;
 s1:=s1 xor (s1 shl 23);
 State.s[1]:=((s1 xor s0) xor (s1 shr 18)) xor (s0 shr 5);
 result:=State.s[1]+s0;
end;

procedure XorShift128PlusJump(var State:TpvRandomGeneratorXorShift128Plus);
const Jump:array[0..1] of TpvUInt64=
       (TpvUInt64($8a5cd789635d2dff),
     		TpvUInt64($121fd2155c472f96));
var i,b:TpvInt32;
    s0,s1:TpvUInt64;
begin
 s0:=0;
 s1:=0;
 for i:=0 to 1 do begin
  for b:=0 to 63 do begin
	 if (Jump[i] and TpvUInt64(TpvUInt64(1) shl b))<>0 then begin
		s0:=s0 xor State.s[0];
		s1:=s1 xor State.s[1];
	 end;
   XorShift128PlusNext(State);
  end;
 end;
 State.s[0]:=s0;
 State.s[1]:=s1;
end;

function XorShift1024Next(var State:TpvRandomGeneratorXorShift1024):TpvUInt64; {$ifdef caninline}inline;{$endif}
var s0,s1:TpvUInt64;
begin
 s0:=State.s[State.p and 15];
 State.p:=(State.p+1) and 15;
 s1:=State.s[State.p];
 s1:=s1 xor (s1 shl 31);
 State.s[State.p]:=((s1 xor s0) xor (s1 shr 11)) xor (s0 shr 30);
 result:=State.s[State.p]*TpvUInt64(1181783497276652981);
end;

procedure XorShift1024Jump(var State:TpvRandomGeneratorXorShift1024);
const Jump:array[0..15] of TpvUInt64=
       (TpvUInt64($84242f96eca9c41d),
     		TpvUInt64($a3c65b8776f96855),
        TpvUInt64($5b34a39f070b5837),
        TpvUInt64($4489affce4f31a1e),
        TpvUInt64($2ffeeb0a48316f40),
        TpvUInt64($dc2d9891fe68c022),
        TpvUInt64($3659132bb12fea70),
        TpvUInt64($aac17d8efa43cab8),
        TpvUInt64($c4cb815590989b13),
        TpvUInt64($5ee975283d71c93b),
        TpvUInt64($691548c86c1bd540),
        TpvUInt64($7910c41d10a1e6a5),
        TpvUInt64($0b5fc64563b3e2a8),
        TpvUInt64($047f7684e9fc949d),
        TpvUInt64($b99181f2d8f685ca),
        TpvUInt64($284600e3f30e38c3));
var i,b,j:TpvInt32;
    t:array[0..15] of TpvUInt64;
begin
 for i:=0 to 15 do begin
  t[i]:=0;
 end;
 for i:=0 to 15 do begin
  for b:=0 to 63 do begin
	 if (Jump[i] and TpvUInt64(TpvUInt64(1) shl b))<>0 then begin
    for j:=0 to 15 do begin
   	 t[j]:=t[j] xor State.s[(j+State.p) and 15];
    end;
   end;
   XorShift1024Next(State);
  end;
 end;
 for i:=0 to 15 do begin
	State.s[(i+State.p) and 15]:=t[i];
 end;
end;

function CMWC4096Next(var State:TpvRandomGeneratorCMWC4096):TpvUInt64; {$ifdef caninline}inline;{$endif}
var x,t:TpvUInt64;
begin
 State.QJ:=(State.QJ+1) and high(State.Q);
 x:=State.Q[State.QJ];
 t:=(x shl 58)+State.QC;
 State.QC:=x shr 6;
 inc(t,x);
 if x<t then begin
  inc(State.QC);
 end;
 State.Q[State.QJ]:=t;
 result:=t;
end;

constructor TpvRandomGenerator.Create;
begin
 inherited Create;
 fCriticalSection:=TCriticalSection.Create;
 Reinitialize;
end;

destructor TpvRandomGenerator.Destroy;
begin
 fCriticalSection.Free;
 inherited Destroy;
end;

{$ifdef win32}
type HCRYPTPROV=TpvUInt32;

const PROV_RSA_FULL=1;
      CRYPT_VERIFYCONTEXT=$f0000000;
      CRYPT_SILENT=$00000040;
      CRYPT_NEWKEYSET=$00000008;

function CryptAcquireContext(var phProv:HCRYPTPROV;pszContainer:PAnsiChar;pszProvider:PAnsiChar;dwProvType:TpvUInt32;dwFlags:TpvUInt32):LONGBOOL; stdcall; external advapi32 name 'CryptAcquireContextA';
function CryptReleaseContext(hProv:HCRYPTPROV;dwFlags:DWORD):BOOL; stdcall; external advapi32 name 'CryptReleaseContext';
function CryptGenRandom(hProv:HCRYPTPROV;dwLen:DWORD;pbBuffer:Pointer):BOOL; stdcall; external advapi32 name 'CryptGenRandom';

function CoCreateGuid(var guid:TGUID):HResult; stdcall; external 'ole32.dll';
{$endif}

{$ifdef fpc}
{$notes off}
{$endif}
procedure TpvRandomGenerator.Reinitialize(FixedSeed:TpvUInt64=TpvUInt64($ffffffffffffffff));
const N=25;
      CountStateQWords=(SizeOf(TpvRandomGeneratorState) div SizeOf(TpvUInt64));
type PStateQWords=^TStateQWords;
     TStateQWords=array[0..CountStateQWords-1] of TpvUInt64;
var i,j:TpvInt32;
    UnixTimeInMilliSeconds:TpvInt64;
    HashState:TpvUInt64;
    LCG64:TpvRandomGeneratorLCG64;
    PCG32:TpvRandomGeneratorPCG32;
    SplitMix64:TpvRandomGeneratorSplitMix64;
{$ifdef unix}
    f:file of TpvUInt32;
    ura,urb:TpvUInt32;
    OLdFileMode:TpvInt32;
{$else}
{$ifdef win32}
    lpc,lpf:TpvInt64;
    pp,p:pwidechar;
    st:ansistring;
{$endif}
{$endif}
{$ifdef win32}
 function GenerateRandomBytes(var Buffer;Bytes:Cardinal):boolean;
 var CryptProv:HCRYPTPROV;
 begin
  try
   if not CryptAcquireContext(CryptProv,nil,nil,PROV_RSA_FULL,CRYPT_VERIFYCONTEXT{ or CRYPT_SILENT}) then begin
    if not CryptAcquireContext(CryptProv,nil,nil,PROV_RSA_FULL,CRYPT_NEWKEYSET) then begin
     result:=false;
     exit;
    end;
   end;
   FillChar(Buffer,Bytes,#0);
   result:=CryptGenRandom(CryptProv,Bytes,@Buffer);
   CryptReleaseContext(CryptProv,0);
  except
   result:=false;
  end;
 end;
 function GetRandomGUIDGarbage:ansistring;
 var g:TGUID;
 begin
  CoCreateGUID(g);
  SetLength(result,sizeof(TGUID));
  Move(g,result[1],sizeof(TGUID));
 end;
{$endif}
begin
 fCriticalSection.Enter;
 try
  if FixedSeed=TpvUInt64($ffffffffffffffff) then begin
   UnixTimeInMilliSeconds:=round((SysUtils.Now-25569.0)*86400000.0);
{$ifdef nunix}
   ura:=0;
   urb:=0;
   OldFileMode:=FileMode;
   FileMode:=0;
   AssignFile(f,'/dev/urandom');
   {$i-}System.Reset(f,1);{$i+}
   if IOResult=0 then begin
    System.Read(f,ura);
    System.Read(f,urb);
    for i:=0 to CountStateDWords-1 do begin
     System.Read(f,PStateDWords(pointer(@fState))^[i]);
    end;
    CloseFile(f);
   end else begin
    AssignFile(f,'/dev/random');
    {$i-}System.Reset(f,1);{$i+}
    if IOResult=0 then begin
     System.Read(f,ura);
     System.Read(f,urb);
     for i:=0 to CountStateDWords-1 do begin
      System.Read(f,PStateDWords(pointer(@fState))^[i]);
     end;
     CloseFile(f);
    end else begin
     LCG64:=((TpvUInt64(UnixTimeInMilliSeconds) shl 31) or (TpvUInt64(UnixTimeInMilliSeconds) shr 33)) xor TpvUInt64($4c2a9d217a5cde81);
     for i:=0 to CountStateQWords-1 do begin
      PStateQWords(pointer(@fState))^[i]:=LCG64Next(LCG64);
     end;
    end;
   end;
   FileMode:=OldFileMode;
   SplitMix64:=TpvUInt64(UnixTimeInMilliSeconds) xor TpvUInt64($7a5cde814c2a9d21);
   for i:=0 to CountStateQWords-1 do begin
    PStateQWords(pointer(@fState))^[i]:=PStateQWords(pointer(@fState))^[i] xor SplitMix64Next(SplitMix64);
   end;
{$else}
{$ifdef win32}
   if not GenerateRandomBytes(fState,SizeOf(TpvRandomGeneratorState)) then begin
{$ifdef fpc}
    LCG64:=GetTickCount64;
{$else}
    LCG64:=GetTickCount;
{$endif}
    LCG64:=LCG64 xor (((TpvUInt64(UnixTimeInMilliSeconds) shl 31) or (TpvUInt64(UnixTimeInMilliSeconds) shr 33)) xor TpvUInt64($4c2a9d217a5cde81));
    for i:=0 to CountStateQWords-1 do begin
     PStateQWords(pointer(@fState))^[i]:=LCG64Next(LCG64);
    end;
   end;
   begin
    QueryPerformanceCounter(lpc);
    QueryPerformanceFrequency(lpf);
    PCG32.State:=lpc;
    PCG32.Increment:=lpf;
    SplitMix64:=(TpvUInt64(GetCurrentProcessId) shl 32) or GetCurrentThreadId;
    for i:=0 to CountStateQWords-1 do begin
     PStateQWords(pointer(@fState))^[i]:=PStateQWords(pointer(@fState))^[i] xor (PCG32Next(PCG32)+SplitMix64Next(SplitMix64));
    end;
   end;
   i:=0;
   HashState:=TpvUInt64(4695981039346656037);
   pp:=GetEnvironmentStringsW;
   if assigned(pp) then begin
    p:=pp;
    while assigned(p) and (p^<>#0) do begin
     while assigned(p) and (p^<>#0) do begin
      HashState:=(HashState xor word(p^))*TpvUInt64(1099511628211);
      PStateQWords(pointer(@fState))^[i]:=PStateQWords(pointer(@fState))^[i] xor HashState;
      inc(i);
      if i>=CountStateQWords then begin
       i:=0;
      end;
      inc(p);
     end;
     inc(p);
    end;
    FreeEnvironmentStringsW(pointer(p));
   end;
   pp:=pointer(GetCommandLineW);
   if assigned(pp) then begin
    p:=pp;
    while assigned(p) and (p^<>#0) do begin
     HashState:=(HashState xor word(p^))*TpvUInt64(1099511628211);
     PStateQWords(pointer(@fState))^[i]:=PStateQWords(pointer(@fState))^[i] xor HashState;
     inc(i);
     if i>=CountStateQWords then begin
      i:=0;
     end;
     inc(p);
    end;
   end;
   st:=GetRandomGUIDGarbage;
   for j:=1 to length(st) do begin
    HashState:=(HashState xor byte(st[j]))*TpvUInt64(1099511628211);
    PStateQWords(pointer(@fState))^[i]:=PStateQWords(pointer(@fState))^[i] xor HashState;
    inc(i);
    if i>=CountStateQWords then begin
     i:=0;
    end;
   end;
   SetLength(st,0);
{$else}
   SplitMix64:=TpvUInt64(UnixTimeInMilliSeconds) xor TpvUInt64($7a5cde814c2a9d21);
   for i:=0 to CountStateQWords-1 do begin
    PStateQWords(pointer(@fState))^[i]:=SplitMix64Next(SplitMix64);
   end;
{$endif}
{$endif}
  end else begin
   SplitMix64:=TpvUInt64(FixedSeed) xor TpvUInt64($7a5cde814c2a9d21);
   for i:=0 to CountStateQWords-1 do begin
    PStateQWords(pointer(@fState))^[i]:=SplitMix64Next(SplitMix64);
   end;
  end;
  XorShift1024Jump(fState.XorShift1024);
  fGaussianFloatUseLast:=false;
  fGaussianFloatLast:=0.0;
  fGaussianDoubleUseLast:=false;
  fGaussianDoubleLast:=0.0;
 finally
  fCriticalSection.Leave;
 end;
end;
{$ifdef fpc}
{$notes on}
{$endif}

function TpvRandomGenerator.Get32:TpvUInt32;
begin
 result:=Get64 shr 32;
end;

function TpvRandomGenerator.Get64:TpvUInt64;
begin
 fCriticalSection.Enter;
 try
  result:=LCG64Next(fState.LCG64)+
          XorShift1024Next(fState.XorShift1024)+
          CMWC4096Next(fState.CMWC4096);
 finally
  fCriticalSection.Leave;
 end;
end;

function TpvRandomGenerator.Get(Limit:TpvUInt32):TpvUInt32;
begin
 if (Limit and $ffff0000)=0 then begin
  result:=((Get32 shr 16)*Limit) shr 16;
 end else begin
  result:=(TpvUInt64(Get32)*Limit) shr 32;
 end;    
end;

function TpvRandomGenerator.GetFloat:TpvFloat; // -1.0 .. 1.0
var t:TpvUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $40000000;
 result:=TpvFloat(pointer(@t)^)-3.0;
end;

function TpvRandomGenerator.GetFloatAbs:TpvFloat; // 0.0 .. 1.0
var t:TpvUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $3f800000;
 result:=TpvFloat(pointer(@t)^)-1.0;
end;

function TpvRandomGenerator.GetDouble:TpvDouble; // -1.0 .. 1.0
var t:TpvUInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $fffffffffffff)+((t shr 11) and 1)) or $4000000000000000;
 result:=TpvDouble(pointer(@t)^)-3.0;
end;

function TpvRandomGenerator.GetDoubleAbs:TpvDouble; // 0.0 .. 1.0
var t:TpvInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $7ffffffffffff)+((t shr 11) and 1)) or $3ff0000000000000;
 result:=TpvDouble(pointer(@t)^)-1.0;
end;

function TpvRandomGenerator.GetGaussianFloat:TpvFloat; // -1.0 .. 1.0
var x1,x2,w:TpvFloat;
    i:TpvUInt32;
begin
 if fGaussianFloatUseLast then begin
  fGaussianFloatUseLast:=false;
  result:=fGaussianFloatLast;
 end else begin
  i:=0;
  repeat
   x1:=GetFloat;
   x2:=GetFloat;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGaussianFloatLast:=x2;
   fGaussianFloatUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGaussianFloatLast:=x2*w;
   fGaussianFloatUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvRandomGenerator.GetGaussianFloatAbs:TpvFloat; // 0.0 .. 1.0
begin
 result:=(GetGaussianFloat+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvRandomGenerator.GetGaussianDouble:TpvDouble; // -1.0 .. 1.0
var x1,x2,w:TpvDouble;
    i:TpvUInt32;
begin
 if fGaussianDoubleUseLast then begin
  fGaussianDoubleUseLast:=false;
  result:=fGaussianDoubleLast;
 end else begin
  i:=0;
  repeat
   x1:=GetDouble;
   x2:=GetDouble;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGaussianDoubleLast:=x2;
   fGaussianDoubleUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGaussianDoubleLast:=x2*w;
   fGaussianDoubleUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvRandomGenerator.GetGaussianDoubleAbs:TpvDouble; // 0.0 .. 1.0
begin
 result:=(GetGaussianDouble+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvRandomGenerator.GetGaussian(Limit:TpvUInt32):TpvUInt32;
begin
 result:=round(GetGaussianDoubleAbs*((Limit-1)+0.25));
end;

function TpvRandomGenerator.GetUInt32Range(const aMin,aMax:TpvUInt32):TpvUInt32; // aMin .. aMax
var Value:TpvUInt64;
begin
 result:=aMin+Get(aMax-aMin);
end;

function TpvRandomGenerator.GetFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
begin
 result:=aMin+(GetFloatAbs*(aMax-aMin));
end;

function TpvRandomGenerator.GetDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
begin
  result:=aMin+(GetDoubleAbs*(aMax-aMin));
end;

function TpvRandomGenerator.GetGaussianFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
begin
 result:=aMin+(GetGaussianFloatAbs*(aMax-aMin));
end;

function TpvRandomGenerator.GetGaussianDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
begin
 result:=aMin+(GetGaussianDoubleAbs*(aMax-aMin));
end;

constructor TpvRandomUnique32BitSequence.Create(const Seed1:TpvUInt32=$b46f23c7;const Seed2:TpvUInt32=$a54c2364);
begin
 inherited Create;
 fIndex:=PermuteQPR(PermuteQPR(Seed1)+$682f0161);
 fIntermediateOffset:=PermuteQPR(PermuteQPR(Seed2)+$46790905);
end;

destructor TpvRandomUnique32BitSequence.Destroy;
begin
 inherited Destroy;
end;

function TpvRandomUnique32BitSequence.PermuteQPR(x:TpvUInt32):TpvUInt32;
const Prime=TpvUInt32(4294967291);
begin
 if x>=Prime then begin
  result:=x;
 end else begin
  result:={$ifdef fpc}qword{$else}uint64{$endif}(x*x) mod Prime;
  if x>(Prime shr 1) then begin
   result:=Prime-result;
  end;
 end;
end;

function TpvRandomUnique32BitSequence.Next:TpvUInt32;
begin
 result:=PermuteQPR((PermuteQPR(fIndex)+fIntermediateOffset) xor $5bf03635);
 inc(fIndex);
end;

{ TpvPCG32 }

procedure TpvPCG32.Init(const aSeed:TpvUInt64);
begin
 if aSeed=0 then begin
  fState:=DefaultState;
  fIncrement:=DefaultStream;
 end else begin
  fState:=DefaultState xor (aSeed*362436069);
  if fState=0 then begin
   fState:=DefaultState;
  end;
  fIncrement:=DefaultStream xor (aSeed*1566083941);
  inc(fIncrement,1-(fIncrement and 1));
 end;
 fGaussianFloatUseLast:=false;
 fGaussianFloatLast:=0.0;
 fGaussianDoubleUseLast:=false;
 fGaussianDoubleLast:=0.0;
end;

function TpvPCG32.Get32:TpvUInt32;
var OldState:TpvUInt64;
{$ifndef fpc}
    XorShifted,Rotation:TpvUInt32;
{$endif}
begin
 OldState:=fState;
 fState:=(OldState*TpvPCG32.Mult)+fIncrement;
{$ifdef fpc}
 result:=RORDWord(((OldState shr 18) xor OldState) shr 27,OldState shr 59);
{$else}
 XorShifted:=((OldState shr 18) xor OldState) shr 27;
 Rotation:=OldState shr 59;
 result:=(XorShifted shr Rotation) or (XorShifted shl ((-Rotation) and 31));
{$endif}
end;

function TpvPCG32.Get64:TpvUInt64;
begin
 result:=Get32;
 result:=(result shl 32) or Get32;
end;

function TpvPCG32.GetBiasedBounded32Bit(const aRange:TpvUInt32):TpvUInt32;
var Temporary:TpvUInt64;
begin
 // For avoid compiler code generation bugs, when a compiler is optimizing the 64-bit casting away wrongly, thus,
 // we use a temporary 64-bit variable for the multiplication and shift operations, so it is sure that the multiplication
 // and shift operations are done on 64-bit values and not on 32-bit values.
 Temporary:=TpvUInt64(Get32);
 Temporary:=Temporary*aRange;
 result:=Temporary shr 32;
end;

function TpvPCG32.GetUnbiasedBounded32Bit(const aRange:TpvUInt32):TpvUInt32;
var x,l,t:TpvUInt32;
    m:TpvUInt64;
begin
 if aRange<=1 then begin
  // For ranges of 0 or 1, just output always zero, but do a dummy Get32 call with discarding its result
  Get32;
  result:=0;
 end else if (aRange and (aRange-1))<>0 then begin
  // For non-power-of-two ranges: Debiased Integer Multiplication — Lemire's Method
  x:=Get32;
  m:=TpvUInt64(x);
  m:=m*TpvUInt64(aRange);
  l:=TpvUInt32(m and $ffffffff);
  if l<aRange then begin
   t:=-aRange;
   if t>=aRange then begin
    dec(t,aRange);
    if t>=aRange then begin
     t:=t mod aRange;
    end;
   end;
   while l<t do begin
    x:=Get32;
    m:=TpvUInt64(x);
    m:=m*TpvUInt64(aRange);
    l:=TpvUInt32(m and $ffffffff);
   end;
  end;
  result:=m shr 32;
 end else begin
  // For power-of-two ranges: Bitmask with Rejection (Unbiased) — Apple's Method
  m:=TpvUInt32($ffffffff);
  t:=aRange-1;
{$if defined(fpc) and declared(BSRDWord)}
  m:=m shr (31-BSRDWord(t or 1));
{$else}
  m:=m shr CLZDWord(t or 1);
{$ifend}
  repeat
   result:=Get32 and m;
  until result<=t;
 end;
end;

function TpvPCG32.Get(Limit:TpvUInt32):TpvUInt32;
begin
 if (Limit and $ffff0000)=0 then begin
  result:=((Get32 shr 16)*Limit) shr 16;
 end else begin
  result:=(TpvUInt64(Get32)*Limit) shr 32;
 end;    
end;

function TpvPCG32.GetFloat:TpvFloat; // -1.0 .. 1.0
var t:TpvUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $40000000;
 result:=TpvFloat(pointer(@t)^)-3.0;
end;

function TpvPCG32.GetFloatAbs:TpvFloat; // 0.0 .. 1.0
var t:TpvUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $3f800000;
 result:=TpvFloat(pointer(@t)^)-1.0;
end;

function TpvPCG32.GetDouble:TpvDouble; // -1.0 .. 1.0
var t:TpvUInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $fffffffffffff)+((t shr 11) and 1)) or $4000000000000000;
 result:=TpvDouble(pointer(@t)^)-3.0;
end;

function TpvPCG32.GetDoubleAbs:TpvDouble; // 0.0 .. 1.0
var t:TpvInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $7ffffffffffff)+((t shr 11) and 1)) or $3ff0000000000000;
 result:=TpvDouble(pointer(@t)^)-1.0;
end;

function TpvPCG32.GetGaussianFloat:TpvFloat; // -1.0 .. 1.0
var x1,x2,w:TpvFloat;
    i:TpvUInt32;
begin
 if fGaussianFloatUseLast then begin
  fGaussianFloatUseLast:=false;
  result:=fGaussianFloatLast;
 end else begin
  i:=0;
  repeat
   x1:=GetFloat;
   x2:=GetFloat;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGaussianFloatLast:=x2;
   fGaussianFloatUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGaussianFloatLast:=x2*w;
   fGaussianFloatUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvPCG32.GetGaussianFloatAbs:TpvFloat; // 0.0 .. 1.0
begin
 result:=(GetGaussianFloat+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvPCG32.GetGaussianDouble:TpvDouble; // -1.0 .. 1.0
var x1,x2,w:TpvDouble;
    i:TpvUInt32;
begin
 if fGaussianDoubleUseLast then begin
  fGaussianDoubleUseLast:=false;
  result:=fGaussianDoubleLast;
 end else begin
  i:=0;
  repeat
   x1:=GetDouble;
   x2:=GetDouble;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGaussianDoubleLast:=x2;
   fGaussianDoubleUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGaussianDoubleLast:=x2*w;
   fGaussianDoubleUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvPCG32.GetGaussianDoubleAbs:TpvDouble; // 0.0 .. 1.0
begin
 result:=(GetGaussianDouble+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TpvPCG32.GetGaussian(Limit:TpvUInt32):TpvUInt32;
begin
 result:=round(GetGaussianDoubleAbs*((Limit-1)+0.25));
end;  

function TpvPCG32.GetUInt32Range(const aMin,aMax:TpvUInt32):TpvUInt32; // aMin .. aMax
begin
 result:=aMin+GetUnbiasedBounded32Bit(aMax-aMin);
end;

function TpvPCG32.GetFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
begin
 result:=aMin+(GetFloatAbs*(aMax-aMin));
end;

function TpvPCG32.GetDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
begin
 result:=aMin+(GetDoubleAbs*(aMax-aMin));
end;

function TpvPCG32.GetGaussianFloatRange(const aMin,aMax:TpvFloat):TpvFloat; // aMin .. aMax
begin
 result:=aMin+(GetGaussianFloatAbs*(aMax-aMin));
end;

function TpvPCG32.GetGaussianDoubleRange(const aMin,aMax:TpvDouble):TpvDouble; // aMin .. aMax
begin
 result:=aMin+(GetGaussianDoubleAbs*(aMax-aMin));
end;

initialization
 pvPCG32.Init(GetTickCount64 xor TpvUInt64($4c2a9d217a5cde81));
end.