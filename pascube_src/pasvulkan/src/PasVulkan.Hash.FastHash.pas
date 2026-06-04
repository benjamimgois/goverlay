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
unit PasVulkan.Hash.FastHash;
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
     Math,
     Vulkan,
     PasVulkan.Types;

type TpvHashFastHash=class
      public
       const m=TpvUInt64($880355f21e6d1965);
       type TMessageDigest=TpvUInt64;
            PMessageDigest=^TMessageDigest;
      public
       class function Process(const aData:pointer;const aDataLength:TpvSizeUInt;const aSeed:TpvUInt64=0):TMessageDigest; static;
     end;

implementation

{ TpvHashFastHash }

class function TpvHashFastHash.Process(const aData:pointer;const aDataLength:TpvSizeUInt;const aSeed:TpvUInt64):TpvHashFastHash.TMessageDigest;
label l6,l5,l4,l3,l2,l1;
var CurrentData,DataEnd:Pointer;
    v:TpvUInt64;
begin
 CurrentData:=aData;
 DataEnd:=@PpvUInt8Array(aData)^[TpvPtrUInt(aDataLength) and not TpvPtrUInt(7)];
 result:=aSeed xor (aDataLength*m);
 while TpvPtrUInt(CurrentData)<TpvPtrUInt(DataEnd) do begin
  v:=PpvUInt64(CurrentData)^;
  inc(PpvUInt64(CurrentData));
  v:=(v xor (v shr 23))*TpvUInt64($127599bf4325c37);
  v:=v xor (v shr 47);
  result:=(result xor v)*m;
 end;
 v:=0;
 case aDataLength and 7 of
  7:begin
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[6]) shl 48);
   goto l6;
  end;
  6:begin
   l6:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[5]) shl 40);
   goto l5;
  end;
  5:begin
   l5:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[4]) shl 32);
   goto l4;
  end;
  4:begin
   l4:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[3]) shl 24);
   goto l3;
  end;
  3:begin
   l3:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[2]) shl 16);
   goto l2;
  end;
  2:begin
   l2:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[1]) shl 8);
   goto l1;
  end;
  1:begin
   l1:
   v:=v xor (TpvUInt64(PpvUInt8Array(CurrentData)^[0]) shl 0);
   v:=(v xor (v shr 23))*TpvUInt64($127599bf4325c37);
   v:=v xor (v shr 47);
   result:=(result xor v)*m;
  end;
 end;
 result:=(result xor (result shr 23))*TpvUInt64($127599bf4325c37);
 result:=result xor (result shr 47);
end;

end.
