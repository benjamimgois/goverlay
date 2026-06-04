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
unit PasVulkan.CircularDoublyLinkedList;
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

type TpvCircularDoublyLinkedListNode<T>=class
      public
       type TValueEnumerator=record
             private
              fCircularDoublyLinkedList:TpvCircularDoublyLinkedListNode<T>;
              fNode:TpvCircularDoublyLinkedListNode<T>;
              function GetCurrent:T; inline;
             public
              constructor Create(const aCircularDoublyLinkedList:TpvCircularDoublyLinkedListNode<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fNext:TpvCircularDoublyLinkedListNode<T>;
       fPrevious:TpvCircularDoublyLinkedListNode<T>;
       fValue:T;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear; inline;
       function Head:TpvCircularDoublyLinkedListNode<T>; inline;
       function Tail:TpvCircularDoublyLinkedListNode<T>; inline;
       function IsEmpty:boolean; inline;
       function Front:TpvCircularDoublyLinkedListNode<T>; inline;
       function Back:TpvCircularDoublyLinkedListNode<T>; inline;
       function Insert(const aData:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>; inline;
       function Add(const aData:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>; inline;
       function Remove:TpvCircularDoublyLinkedListNode<T>; // inline;
       function MoveFrom(const aDataFirst,aDataLast:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>; inline;
       function PopFromFront(out aData):boolean; inline;
       function PopFromBack(out aData):boolean; inline;
       function ListSize:TpvSizeUInt;
       function GetEnumerator:TValueEnumerator;
      published
       property Next:TpvCircularDoublyLinkedListNode<T> read fNext write fNext;
       property Previous:TpvCircularDoublyLinkedListNode<T> read fPrevious write fPrevious;
      public
       property Value:T read fValue write fValue;
     end;

implementation

constructor TpvCircularDoublyLinkedListNode<T>.TValueEnumerator.Create(const aCircularDoublyLinkedList:TpvCircularDoublyLinkedListNode<T>);
begin
 fCircularDoublyLinkedList:=aCircularDoublyLinkedList;
 fNode:=aCircularDoublyLinkedList;
end;

function TpvCircularDoublyLinkedListNode<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fNode.fValue;
end;

function TpvCircularDoublyLinkedListNode<T>.TValueEnumerator.MoveNext:boolean;
begin
 result:=fCircularDoublyLinkedList.fNext<>fCircularDoublyLinkedList;
 if result then begin
  fNode:=fNode.fNext;
  result:=assigned(fNode) and (fNode<>fCircularDoublyLinkedList);
 end;
end;

constructor TpvCircularDoublyLinkedListNode<T>.Create;
begin
 inherited Create;
 fNext:=self;
 fPrevious:=self;
 Initialize(fValue);
end;

destructor TpvCircularDoublyLinkedListNode<T>.Destroy;
begin
 Finalize(fValue);
 if fNext<>self then begin
  Remove;
 end;
 inherited Destroy;
end;

procedure TpvCircularDoublyLinkedListNode<T>.Clear;
begin
 fNext:=self;
 fPrevious:=self;
 Finalize(fValue);
 Initialize(fValue);
end;

function TpvCircularDoublyLinkedListNode<T>.Head:TpvCircularDoublyLinkedListNode<T>;
begin
 result:=fNext;
end;

function TpvCircularDoublyLinkedListNode<T>.Tail:TpvCircularDoublyLinkedListNode<T>;
begin
 result:=self;
end;

function TpvCircularDoublyLinkedListNode<T>.IsEmpty:boolean;
begin
 result:=fNext=self;
end;

function TpvCircularDoublyLinkedListNode<T>.Front:TpvCircularDoublyLinkedListNode<T>;
begin
 result:=fNext;
end;

function TpvCircularDoublyLinkedListNode<T>.Back:TpvCircularDoublyLinkedListNode<T>;
begin
 result:=fPrevious;
end;

function TpvCircularDoublyLinkedListNode<T>.Insert(const aData:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>;
var Position:TpvCircularDoublyLinkedListNode<T>;
begin
 Position:=self;
 result:=aData;
 result.fPrevious:=Position.fPrevious;
 result.fNext:=Position;
 result.fPrevious.fNext:=result;
 Position.fPrevious:=result;
end;

function TpvCircularDoublyLinkedListNode<T>.Add(const aData:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>;
var Position:TpvCircularDoublyLinkedListNode<T>;
begin
 Position:=Previous;
 result:=aData;
 result.fPrevious:=Position.fPrevious;
 result.fNext:=Position;
 result.fPrevious.fNext:=result;
 Position.fPrevious:=result;
end;

function TpvCircularDoublyLinkedListNode<T>.Remove:TpvCircularDoublyLinkedListNode<T>;
begin
 fPrevious.fNext:=fNext;
 fNext.fPrevious:=fPrevious;
 fPrevious:=self;
 fNext:=self;
 result:=self;
end;

function TpvCircularDoublyLinkedListNode<T>.MoveFrom(const aDataFirst,aDataLast:TpvCircularDoublyLinkedListNode<T>):TpvCircularDoublyLinkedListNode<T>;
var First,Last:TpvCircularDoublyLinkedListNode<T>;
begin
 First:=aDataFirst;
 Last:=aDataLast;
 First.fPrevious.fNext:=Last.fNext;
 Last.fNext.fPrevious:=First.fPrevious;
 First.fPrevious:=fPrevious;
 Last.fNext:=self;
 First.fPrevious.fNext:=First;
 fPrevious:=Last;
 result:=First;
end;

function TpvCircularDoublyLinkedListNode<T>.PopFromFront(out aData):boolean;
begin
 result:=fNext<>self;
 if result then begin
  TpvCircularDoublyLinkedListNode<T>(aData):=fNext;
  fNext.Remove;
 end;
end;

function TpvCircularDoublyLinkedListNode<T>.PopFromBack(out aData):boolean;
begin
 result:=fNext<>self;
 if result then begin
  TpvCircularDoublyLinkedListNode<T>(aData):=fPrevious;
  fPrevious.Remove;
 end;
end;

function TpvCircularDoublyLinkedListNode<T>.ListSize:TpvSizeUInt;
var Position:TpvCircularDoublyLinkedListNode<T>;
begin
 result:=0;
 if assigned(self) then begin
  Position:=Next;
  while Position<>self do begin
   inc(result);
   Position:=Position.fNext;
  end;
 end;
end;

function TpvCircularDoublyLinkedListNode<T>.GetEnumerator:TpvCircularDoublyLinkedListNode<T>.TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

end.
