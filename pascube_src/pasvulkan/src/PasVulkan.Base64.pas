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
unit PasVulkan.Base64;
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
     PasVulkan.Types;

type TpvBase64=class
      public
       const EncodingLookUpTable:array[0..63] of TpvRawByteChar=
              (
               'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
               'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
               'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
               'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
              );
             DecodingLookUpTable:array[TpvRawByteChar] of TpvInt8=
              (
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,
               52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,
               -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,
               15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,
               -1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
               41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
               -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
              );
      public
       class function Encode(const aData;const aDataLength:TpvSizeInt):TpvRawByteString; overload; static;
       class function Encode(const aData:array of TpvUInt8):TpvRawByteString; overload; static;
       class function Encode(const aData:TpvRawByteString):TpvRawByteString; overload; static;
       class function Encode(const aData:TStream):TpvRawByteString; overload; static;
       class function Decode(const aInput:TpvRawByteString;const aOutput:TStream):boolean; overload; static;
     end;

implementation

{ TpvBase64 }

class function TpvBase64.Encode(const aData;const aDataLength:TpvSizeInt):TpvRawByteString;
var Index,BitCount,OutputIndex:TpvSizeInt;
    Value:TpvUInt32;
begin
 result:='';
 if aDataLength>0 then begin
  SetLength(result,(((aDataLength*4) div 3)+3) and not 3);
  OutputIndex:=0;
  Value:=0;
  BitCount:=-6;
  for Index:=0 to aDataLength-1 do begin
   Value:=(Value shl 8) or PpvUInt8Array(@aData)^[Index];
   inc(BitCount,8);
   while BitCount>=0 do begin
    result[Low(result)+OutputIndex]:=EncodingLookUpTable[(Value shr BitCount) and 63];
    inc(OutputIndex);
    dec(BitCount,6);
   end;
  end;
  if BitCount>-6 then begin
   result[Low(result)+OutputIndex]:=EncodingLookUpTable[((Value shl 8) shr (BitCount+8)) and 63];
   inc(OutputIndex);
  end;
  while (OutputIndex and 3)<>0 do begin
   result[Low(result)+OutputIndex]:='=';
   inc(OutputIndex);
  end;
  SetLength(result,OutputIndex);
 end;
end;

class function TpvBase64.Encode(const aData:array of TpvUInt8):TpvRawByteString;
begin
 result:=Encode(aData[0],length(aData));
end;

class function TpvBase64.Encode(const aData:TpvRawByteString):TpvRawByteString;
begin
 result:=Encode(aData[Low(aData)],length(aData));
end;

class function TpvBase64.Encode(const aData:TStream):TpvRawByteString;
var Bytes:TpvUInt8DynamicArray;
begin
 Bytes:=nil;
 try
  SetLength(Bytes,aData.Size);
  aData.Seek(0,soBeginning);
  aData.ReadBuffer(Bytes[0],aData.Size);
  result:=Encode(Bytes[0],length(Bytes));
 finally
  Bytes:=nil;
 end;
end;

class function TpvBase64.Decode(const aInput:TpvRawByteString;const aOutput:TStream):boolean;
var Index,Size,BitCount,OutputIndex,
    LookUpTableValue,Remaining:TpvSizeInt;
    Value:TpvUInt32;
    Buffer:TpvUInt8DynamicArray;
begin
 result:=false;
 Buffer:=nil;
 try
  Size:=length(aInput);
  if Size>0 then begin
   if (Size and 3)=0 then begin
    result:=true;
    SetLength(Buffer,(Size*3) shr 2);
    Value:=0;
    BitCount:=-8;
    OutputIndex:=0;
    try
     for Index:=1 to Size do begin
      LookUpTableValue:=DecodingLookUpTable[aInput[Index]];
      if LookUpTableValue>=0 then begin
       Value:=(Value shl 6) or LookUpTableValue;
       inc(BitCount,6);
       while BitCount>=0 do begin
        Buffer[OutputIndex]:=(Value shr BitCount) and $ff;
        inc(OutputIndex);
        dec(BitCount,8);
       end;
      end else begin
       case aInput[Index] of
        '=':begin
         Remaining:=Size-Index;
         if (Remaining>1) or ((Remaining=1) and (aInput[Index+1]<>'=')) then begin
          result:=false;
         end;
        end;
        else begin
         result:=false;
        end;
       end;
       break;
      end;
     end;
    finally
     SetLength(Buffer,OutputIndex);
    end;
    if result then begin
     aOutput.WriteBuffer(Buffer[0],OutputIndex);
    end;
   end;
  end else begin
   result:=true;
  end;
 finally
  Buffer:=nil;
 end;
end;

end.

