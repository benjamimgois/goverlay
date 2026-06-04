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
unit PasVulkan.DataStructures.SparseSet;
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

uses SysUtils,Classes,PasVulkan.Types;

type TpvSparseSet<T>=class
      private
       fSize:TpvSizeInt;
       fMaximumSize:TpvSizeInt;
       fSparseToDense:array of TpvSizeInt;
       fDense:array of T;
       function GetValue(const aIndex:TpvSizeInt):T; inline;
       procedure SetValue(const aIndex:TpvSizeInt;const aValue:T); inline;
      public
       constructor Create(const aMaximumSize:TpvSizeInt=0);
       destructor Destroy; override;
       procedure Clear;
       procedure Resize(const aNewMaximumSize:TpvSizeInt);
       function Contains(const aValue:T):boolean;
       procedure Add(const aValue:T);
       procedure AddNew(const aValue:T);
       property Size:TpvSizeInt read fSize;
       property Values[const aIndex:TpvSizeInt]:T read GetValue write SetValue; default;
     end;

implementation

constructor TpvSparseSet<T>.Create(const aMaximumSize:longint=0);
begin
 inherited Create;
 fSize:=0;
 fMaximumSize:=aMaximumSize;
 fSparseToDense:=nil;
 fDense:=nil;
 SetLength(fSparseToDense,fMaximumSize);
 SetLength(fDense,fMaximumSize);
 FillChar(fSparseToDense[0],fMaximumSize*SizeOf(TpvSizeInt),#$ff);
 FillChar(fDense[0],fMaximumSize*SizeOf(T),#$00);
end;

destructor TpvSparseSet<T>.Destroy;
begin
 SetLength(fSparseToDense,0);
 SetLength(fDense,0);
 inherited Destroy;
end;

procedure TpvSparseSet<T>.Clear;
begin
 fSize:=0;
end;

procedure TpvSparseSet<T>.Resize(const aNewMaximumSize:longint);
begin
 SetLength(fSparseToDense,aNewMaximumSize);
 SetLength(fDense,aNewMaximumSize);
 if fMaximumSize<aNewMaximumSize then begin
  FillChar(fSparseToDense[fMaximumSize],(fMaximumSize-aNewMaximumSize)*SizeOf(TpvSizeInt),#$ff);
  FillChar(fDense[fMaximumSize],(fMaximumSize-aNewMaximumSize)*SizeOf(T),#$00);
 end;
 fMaximumSize:=aNewMaximumSize;
end;

function TpvSparseSet<T>.Contains(const aValue:longint):boolean;
begin
 result:=((aValue>=0) and (aValue<fMaximumSize) and
         (fSparseToDense[aValue]<fSize)) and
         (fDense[fSparseToDense[aValue]]=aValue);
end;

function TpvSparseSet<T>.GetValue(const aIndex:TpvSizeInt):T;
begin
 if (aIndex>=0) and (aIndex<fSize) then begin
  result:=fDense[aIndex];
 end;
end;

procedure TpvSparseSet<T>.SetValue(const aIndex:TpvSizeInt;const aValue:T);
begin
 if (aIndex>=0) and (aIndex<fSize) then begin
  fDense[aIndex]:=aValue;
 end;
end;

procedure TpvSparseSet<T>.Add(const aValue:T);
begin
 if (aValue>=0) and (aValue<fMaximumSize) then begin
  fSparseToDense[aValue]:=fSize;
  fDense[fSize]:=aValue;
  inc(fSize);
 end;
end;

procedure TpvSparseSet<T>.AddNew(const aValue:T);
begin
 if not Contains(aValue) then begin
  Add(aValue);
 end;
end;

end.

