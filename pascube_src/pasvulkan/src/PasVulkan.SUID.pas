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
unit PasVulkan.SUID;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     DateUtils,
     Math,
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math;

type TpvSUID=type TpvUInt64;
     PpvSUID=^TpvSUID;

     { TpvSUIDHelper }

     TpvSUIDHelper=record helper for TpvSUID
      public
       const Null:TpvSUID=(0);
      public
       class function Create:TpvSUID; static;
       class function CreateFromString(const aString:string):TpvSUID; static;
       function ToString:string;
(*     class operator Equal(const a,b:TpvSUID):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvSUID):boolean; {$ifdef CAN_INLINE}inline;{$endif}*)
     end;

var SUIDNodeID:TpvUInt16=0;
    SUIDCounter:TpvUInt32=0;
    SUIDTimestampMilliseconds:TpvUInt64=0;
    SUIDLock:TPasMPInt32=0;

implementation
                             
{ TpvSUIDHelper }

class function TpvSUIDHelper.Create:TpvSUID;
 function GetTime:TpvUInt64;
 const UnixStartDate:TDateTime=25569.0;
       MillisecondsPerDay=86400000.0;
       BaseEpoch:TpvUInt64=1559347200000;
 begin
  result:=trunc(({$if defined(fpc)}LocalTimeToUniversal(Now){$else}TTimeZone.Local.ToUniversalTime(Now){$ifend}-UnixStartDate)*MillisecondsPerDay)-BaseEpoch;
 end;
var Tries:TpvInt32;
    TimestampMilliseconds:TpvUInt64;
begin
 while TPasMPInterlocked.CompareExchange(SUIDLock,-1,0)<>0 do begin
  TPasMP.Yield;
 end;
 try
  TimestampMilliseconds:=GetTime;
  if SUIDTimestampMilliseconds=TimestampMilliseconds then begin
   SUIDCounter:=(SUIDCounter+1) and $fff;
   if (SUIDCounter=0) and (SUIDTimestampMilliseconds=TimestampMilliseconds) then begin
    for Tries:=1 to 3 do begin
     Sleep(1);
     TimestampMilliseconds:=GetTime;
     if SUIDTimestampMilliseconds<>TimestampMilliseconds then begin
      SUIDTimestampMilliseconds:=TimestampMilliseconds;
      break;
     end;
    end;
   end;
  end else begin
   SUIDCounter:=0;
   SUIDTimestampMilliseconds:=TimestampMilliseconds;
  end;
  result:=((TpvUInt64(TimestampMilliseconds) and TpvUInt64($3ffffffffff)) shl 22) or
          (TpvUInt64(SUIDNodeID and $3ff) shl 12) or
          (TpvUInt64(SUIDCounter and $fff) shl 0);
 finally
  TPasMPInterlocked.Write(SUIDLock,0);
 end;
end;

class function TpvSUIDHelper.CreateFromString(const aString:string):TpvSUID;
begin
 result:=StrToUInt64Def(aString,0);
end;

function TpvSUIDHelper.ToString:string;
begin
 result:=UIntToStr(self);
end;

{class operator TpvSUIDHelper.Equal(const a,b:TpvSUID):boolean;
begin
 result:=a=b;
end;

class operator TpvSUIDHelper.NotEqual(const a,b:TpvSUID):boolean;
begin
 result:=a<>b;
end;}

end.
