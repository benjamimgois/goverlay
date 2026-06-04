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
unit PasVulkan.Hash.SHA3;
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

type TpvHashSHA3=class
      public
       type TState=array[0..24] of TpvUInt64;
            PState=^TState;
            TMessageDigest=array[0..63] of TpvUInt8;
            PMessageDigest=^TMessageDigest;
      private
       const KECCAKF_ROUNDS=24;
             keccakf_rndc:array[0..23] of TpvUInt64=
              (
               TpvUInt64($0000000000000001),TpvUInt64($0000000000008082),TpvUInt64($800000000000808a),
               TpvUInt64($8000000080008000),TpvUInt64($000000000000808b),TpvUInt64($0000000080000001),
               TpvUInt64($8000000080008081),TpvUInt64($8000000000008009),TpvUInt64($000000000000008a),
               TpvUInt64($0000000000000088),TpvUInt64($0000000080008009),TpvUInt64($000000008000000a),
               TpvUInt64($000000008000808b),TpvUInt64($800000000000008b),TpvUInt64($8000000000008089),
               TpvUInt64($8000000000008003),TpvUInt64($8000000000008002),TpvUInt64($8000000000000080),
               TpvUInt64($000000000000800a),TpvUInt64($800000008000000a),TpvUInt64($8000000080008081),
               TpvUInt64($8000000000008080),TpvUInt64($0000000080000001),TpvUInt64($8000000080008008)
              );
             keccakf_rotc:array[0..23] of TpvInt32=(1,3,6,10,15,21,28,36,45,55,2,14,27,41,56,8,25,43,62,18,39,61,20,44);
             keccakf_piln:array[0..23] of TpvInt32=(10,7,11,17,18,3,5,16,8,21,24,4,15,23,19,13,12,2,20,14,22,9,6,1);
      private
       fState:TState;
       fStatePosition:TpvSizeInt;
       fBlockSize:TpvSizeInt;
       fMessageDigestSize:TpvSizeInt;
{$if not declared(ROLQWord)}
       class function ROLQWord(const aValue:TpvUInt64;const aBits:TpvSizeUInt):TpvUInt64; static; inline;
{$ifend}
      public
       class procedure ProcessState(var aState:TState); static;
      public
       constructor Create(const aMessageDigestSize:TpvSizeInt); reintroduce;
       destructor Destroy; override;
       procedure Update(const aData:pointer;const aDataLength:TpvSizeInt);
       procedure Final(const aMessageDigest:pointer);
       class procedure Process(const aData:pointer;const aDataLength:TpvSizeInt;const aMessageDigest:pointer;const aMessageDigestSize:TpvSizeInt); static;
     end;

     TpvHashShake=class(TpvHashSHA3)
      public
       procedure XOF;
       procedure Out(const aOutput:pointer;const aOutputLength:TpvSizeInt);
     end;

     TpvHashShake128=class(TpvHashShake)
      public
       constructor Create; reintroduce;
     end;

     TpvHashShake256=class(TpvHashShake)
      public
       constructor Create; reintroduce;
     end;

implementation

{ TpvHashSHA3 }

{$if not declared(ROLQWord)}
class function TpvHashSHA3.ROLQWord(const aValue:TpvUInt64;const aBits:TpvSizeUInt):TpvUInt64;
begin
 result:=(aValue shl aBits) or (aValue shr (64-aBits));
end;
{$ifend}

class procedure TpvHashSHA3.Process(const aData:pointer;const aDataLength:TpvSizeInt;const aMessageDigest:pointer;const aMessageDigestSize:TpvSizeInt);
var Instance:TpvHashSHA3;
begin
 Instance:=TpvHashSHA3.Create(aMessageDigestSize);
 try
  Instance.Update(aData,aDataLength);
  Instance.Final(aMessageDigest);
 finally
  FreeAndNil(Instance);
 end;
end;

class procedure TpvHashSHA3.ProcessState(var aState:TState);
var i,j,k,r:TpvSizeInt;
    t:TpvUInt64;
    bc:array[0..4] of TpvUInt64;
{$ifdef BigEndian}
    v:PpvUInt8Array;
{$endif}
begin

{$ifdef BigEndian}
 for i:=0 to 24 do begin
  v:=pointer(@aState[i]);
  aState[i]:=(TpvUInt64(v^[0]) shl 0) or (TpvUInt64(v^[1]) shl 8) or
             (TpvUInt64(v^[2]) shl 16) or (TpvUInt64(v^[3]) shl 24) or
             (TpvUInt64(v^[4]) shl 32) or (TpvUInt64(v^[5]) shl 40) or
             (TpvUInt64(v^[6]) shl 48) or (TpvUInt64(v^[7]) shl 56);
 end;
{$endif}

 for r:=0 to KECCAKF_ROUNDS-1 do begin

  for i:=0 to 4 do begin
   bc[i]:=aState[i] xor aState[i+5] xor aState[i+10] xor aState[i+15] xor aState[i+20];
  end;

  for i:=0 to 4 do begin
   t:=bc[(i + 4) mod 5] xor ROLQWord(bc[(i+1) mod 5],1);
   j:=0;
   while j<25 do begin
    aState[i+j]:=aState[i+j] xor t;
    inc(j,5);
   end;
  end;

  t:=aState[1];
  for i:=0 to 23 do begin
   j:=keccakf_piln[i];
   bc[0]:=aState[j];
   aState[j]:=ROLQWord(t,keccakf_rotc[i]);
   t:=bc[0];
  end;

  j:=0;
  while j<25 do begin
   for i:=0 to 4 do begin
    bc[i]:=aState[i+j];
   end;
   for i:=0 to 4 do begin
    aState[i+j]:=aState[i+j] xor ((not bc[(i+1) mod 5]) and bc[(i+2) mod 5]);
   end;
   inc(j,5);
  end;

  aState[0]:=aState[0] xor keccakf_rndc[r];
 end;

{$ifdef BigEndian}
 for i:=0 to 24 do begin
  v:=pointer(@aState[i]);
  t:=aState[i];
  v^[0]:=(t shr 0) and $ff;
  v^[1]:=(t shr 8) and $ff;
  v^[2]:=(t shr 16) and $ff;
  v^[3]:=(t shr 24) and $ff;
  v^[4]:=(t shr 32) and $ff;
  v^[5]:=(t shr 40) and $ff;
  v^[6]:=(t shr 48) and $ff;
  v^[7]:=(t shr 56) and $ff;
 end;
{$endif}

end;

constructor TpvHashSHA3.Create(const aMessageDigestSize:TpvSizeInt);
begin
 inherited Create;
 FillChar(fState,SizeOf(TState),#0);
 fMessageDigestSize:=aMessageDigestSize;
 fBlockSize:=200-(fMessageDigestSize shl 1);
 fStatePosition:=0;
end;

destructor TpvHashSHA3.Destroy;
begin
 inherited Destroy;
end;

procedure TpvHashSHA3.Update(const aData:pointer;const aDataLength:TpvSizeInt);
var DataPosition,WorkStatePosition:TpvSizeInt;
    Current:PpvUInt8;
begin
 WorkStatePosition:=fStatePosition;
 for DataPosition:=0 to aDataLength-1 do begin
  Current:=@PpvUInt8Array(@fState)^[WorkStatePosition];
  Current^:=Current^ xor PpvUInt8Array(aData)^[DataPosition];
  inc(WorkStatePosition);
  if WorkStatePosition>=fBlockSize then begin
   ProcessState(fState);
   WorkStatePosition:=0;
  end;
 end;
 fStatePosition:=WorkStatePosition;
end;

procedure TpvHashSHA3.Final(const aMessageDigest:pointer);
begin
 PpvUInt8Array(@fState)^[fStatePosition]:=PpvUInt8Array(@fState)^[fStatePosition] xor $06;
 PpvUInt8Array(@fState)^[fBlockSize-1]:=PpvUInt8Array(@fState)^[fBlockSize-1] xor $80;
 ProcessState(fState);
 Move(fState,aMessageDigest^,fMessageDigestSize);
end;

{ TpvHashShake }

procedure TpvHashShake.XOF;
begin
 PpvUInt8Array(@fState)^[fStatePosition]:=PpvUInt8Array(@fState)^[fStatePosition] xor $1f;
 PpvUInt8Array(@fState)^[fBlockSize-1]:=PpvUInt8Array(@fState)^[fBlockSize-1] xor $80;
 ProcessState(fState);
 fStatePosition:=0;
end;

procedure TpvHashShake.Out(const aOutput:pointer;const aOutputLength:TpvSizeInt);
var OutputPosition,WorkStatePosition:TpvSizeInt;
begin
 WorkStatePosition:=fStatePosition;
 for OutputPosition:=0 to aOutputLength-1 do begin
  if WorkStatePosition>=fBlockSize then begin
   ProcessState(fState);
   WorkStatePosition:=0;
  end;
  PpvUInt8Array(aOutput)^[OutputPosition]:=PpvUInt8Array(@fState)^[WorkStatePosition];
  inc(WorkStatePosition);
 end;
 fStatePosition:=WorkStatePosition;
end;

{ TpvHashShake128 }

constructor TpvHashShake128.Create;
begin
 inherited Create(16);
end;

{ TpvHashShake256 }

constructor TpvHashShake256.Create;
begin
 inherited Create(32);
end;

end.
