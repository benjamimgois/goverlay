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
unit PasVulkan.DataStructures.LinkedList;
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

type PpvLinkedListHead=^TpvLinkedListHead;
     TpvLinkedListHead=record
      Next:PpvLinkedListHead;
      Previous:PpvLinkedListHead;
     end;

procedure LinkedListInitialize(const List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListInsertBefore(ListCurrent,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListInsertAfter(ListCurrent,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListPushFront(ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListPushBack(const ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
function LinkedListPopFront(const ListHead:PpvLinkedListHead):pointer; overload; {$ifdef caninline}inline;{$endif}
function LinkedListPopFront(const ListHead:PpvLinkedListHead;out aListOut):boolean; overload; {$ifdef caninline}inline;{$endif}
function LinkedListPopBack(const ListHead:PpvLinkedListHead):pointer; overload; {$ifdef caninline}inline;{$endif}
function LinkedListPopBack(const ListHead:PpvLinkedListHead;out aListOut):boolean; overload; {$ifdef caninline}inline;{$endif}
procedure LinkedListRemove(const ListEntry:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListReplace(const ListOld,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
function LinkedListEmpty(const ListHead:PpvLinkedListHead):boolean; {$ifdef caninline}inline;{$endif}
function LinkedListHead(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
function LinkedListTail(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
function LinkedListPrevious(const ListHead,ListCurrent:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
function LinkedListNext(const ListHead,ListCurrent:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
procedure LinkedListSortedInsert(const ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListSplice(const ListPrevious,ListNext,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListSpliceHead(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListSpliceTail(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListSpliceHeadInitialize(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
procedure LinkedListSpliceTailInitialize(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}

implementation

uses PasVulkan.Types;

procedure LinkedListInitialize(const List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 List^.Previous:=List;
 List^.Next:=List;
end;

procedure LinkedListInsertBefore(ListCurrent,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListCurrent^.Previous^.Next:=ListNew;
 ListNew^.Previous:=ListCurrent^.Previous;
 ListCurrent^.Previous:=ListNew;
 ListNew^.Next:=ListCurrent;
end;

procedure LinkedListInsertAfter(ListCurrent,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListCurrent^.Next^.Previous:=ListNew;
 ListNew^.Next:=ListCurrent^.Next;
 ListCurrent^.Next:=ListNew;
 ListNew^.Previous:=ListCurrent;
end;

procedure LinkedListPushFront(ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListNew^.Previous:=ListHead;
 ListNew^.Next:=ListHead^.Next;
 ListHead^.Next^.Previous:=ListNew;
 ListHead^.Next:=ListNew;
end;

procedure LinkedListPushBack(const ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListNew^.Previous:=ListHead^.Previous;
 ListNew^.Next:=ListHead;
 ListHead^.Previous^.Next:=ListNew;
 ListHead^.Previous:=ListNew;
end;

function LinkedListPopFront(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
var ListNext,ListPrevious:PpvLinkedListHead;
begin
 if ListHead^.Next<>ListHead then begin
  result:=ListHead^.Next;
  ListNext:=PpvLinkedListHead(result)^.Next;
  ListPrevious:=PpvLinkedListHead(result)^.Previous;
  ListNext^.Previous:=ListPrevious;
  ListPrevious^.Next:=ListNext;
  PpvLinkedListHead(result)^.Next:=result;
  PpvLinkedListHead(result)^.Previous:=result;
 end else begin
  result:=nil;
 end;
end;

function LinkedListPopFront(const ListHead:PpvLinkedListHead;out aListOut):boolean; overload; {$ifdef caninline}inline;{$endif}
var ListNext,ListPrevious:PpvLinkedListHead;
begin
 result:=ListHead^.Next<>ListHead;
 if result then begin
  PpvLinkedListHead(aListOut):=ListHead^.Next;
  ListNext:=PpvLinkedListHead(aListOut)^.Next;
  ListPrevious:=PpvLinkedListHead(aListOut)^.Previous;
  ListNext^.Previous:=ListPrevious;
  ListPrevious^.Next:=ListNext;
  PpvLinkedListHead(aListOut)^.Next:=PpvLinkedListHead(aListOut);
  PpvLinkedListHead(aListOut)^.Previous:=PpvLinkedListHead(aListOut);
 end;
end;

function LinkedListPopBack(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
var ListNext,ListPrevious:PpvLinkedListHead;
begin
 if ListHead^.Previous<>ListHead then begin
  result:=ListHead^.Previous;
  ListNext:=PpvLinkedListHead(result)^.Next;
  ListPrevious:=PpvLinkedListHead(result)^.Previous;
  ListNext^.Previous:=ListPrevious;
  ListPrevious^.Next:=ListNext;
  PpvLinkedListHead(result)^.Next:=result;
  PpvLinkedListHead(result)^.Previous:=result;
 end else begin
  result:=nil;
 end;
end;

function LinkedListPopBack(const ListHead:PpvLinkedListHead;out aListOut):boolean; overload; {$ifdef caninline}inline;{$endif}
var ListNext,ListPrevious:PpvLinkedListHead;
begin
 result:=ListHead^.Previous<>ListHead;
 if result then begin
  PpvLinkedListHead(aListOut):=ListHead^.Previous;
  ListNext:=PpvLinkedListHead(aListOut)^.Next;
  ListPrevious:=PpvLinkedListHead(aListOut)^.Previous;
  ListNext^.Previous:=ListPrevious;
  ListPrevious^.Next:=ListNext;
  PpvLinkedListHead(aListOut)^.Next:=PpvLinkedListHead(aListOut);
  PpvLinkedListHead(aListOut)^.Previous:=PpvLinkedListHead(aListOut);
 end;
end;

procedure LinkedListRemove(const ListEntry:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListEntry^.Previous^.Next:=ListEntry^.Next;
 ListEntry^.Next^.Previous:=ListEntry^.Previous;
 ListEntry^.Previous:=ListEntry;
 ListEntry^.Next:=ListEntry;
end;

procedure LinkedListReplace(const ListOld,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 ListNew^.Next:=ListOld^.Next;
 ListNew^.Next^.Previous:=ListNew;
 ListNew^.Previous:=ListOld^.Previous;
 ListOld^.Previous^.Next:=ListNew;
end;

function LinkedListEmpty(const ListHead:PpvLinkedListHead):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=ListHead^.Next=ListHead;
end;

function LinkedListHead(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
begin
 result:=ListHead^.Next;
end;

function LinkedListTail(const ListHead:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
begin
 result:=ListHead^.Previous;
end;

function LinkedListPrevious(const ListHead,ListCurrent:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
begin
 if ListCurrent^.Previous<>ListHead then begin
  result:=ListCurrent^.Previous;
 end else begin
  result:=nil;
 end;
end;

function LinkedListNext(const ListHead,ListCurrent:PpvLinkedListHead):pointer; {$ifdef caninline}inline;{$endif}
begin
 if ListCurrent^.Next<>ListHead then begin
  result:=ListCurrent^.Next;
 end else begin
  result:=nil;
 end;
end;

procedure LinkedListSortedInsert(const ListHead,ListNew:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
var ListCurrent:PpvLinkedListHead;
begin
 ListCurrent:=ListHead^.Next;
 if (ListCurrent=ListHead) or
    (TpvPtrUInt(pointer(ListNew))>TpvPtrUInt(pointer(ListHead^.Previous))) then begin
  ListNew^.Previous:=ListHead^.Previous;
  ListNew^.Next:=ListHead;
  ListHead^.Previous^.Next:=ListNew;
  ListHead^.Previous:=ListNew;
 end else begin
  while (ListCurrent<>ListHead) and
        (TpvPtrUInt(pointer(ListCurrent))<TpvPtrUInt(pointer(ListNew))) do begin
   ListCurrent:=ListCurrent^.Next;
  end;
  ListCurrent^.Previous^.Next:=ListNew;
  ListNew^.Previous:=ListCurrent^.Previous;
  ListCurrent^.Previous:=ListNew;
  ListNew^.Next:=ListCurrent;
 end;
end;

procedure LinkedListSplice(const ListPrevious,ListNext,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
var First,Last:PpvLinkedListHead;
begin
 First:=List^.Next;
 Last:=List^.Previous;
 First^.Previous:=ListPrevious;
 ListPrevious^.Next:=First;
 Last^.Next:=ListNext;
 ListNext^.Previous:=Last;
end;

procedure LinkedListSpliceHead(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 if List^.Next<>List then begin
  LinkedListSplice(ListHead,ListHead^.Next,List);
 end;
end;

procedure LinkedListSpliceTail(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 if List^.Next<>List then begin
  LinkedListSplice(ListHead^.Previous,ListHead,List);
 end;
end;

procedure LinkedListSpliceHeadInitialize(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 if List^.Next<>List then begin
  LinkedListSplice(ListHead,ListHead^.Next,List);
  LinkedListInitialize(List);
 end;
end;

procedure LinkedListSpliceTailInitialize(const ListHead,List:PpvLinkedListHead); {$ifdef caninline}inline;{$endif}
begin
 if List^.Next<>List then begin
  LinkedListSplice(ListHead^.Previous,ListHead,List);
  LinkedListInitialize(List);
 end;
end;

initialization
end.

