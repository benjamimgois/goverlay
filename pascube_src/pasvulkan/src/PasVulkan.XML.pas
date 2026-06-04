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
unit PasVulkan.XML;
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
     PUCU,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Streams;

const XMLMaxListSize=2147483647 div SizeOf(TpvPointer);

type EpvXML=class(Exception);

     TpvXMLClass=class
      public
       Previous,Next:TpvXMLClass;
       Core:TpvPointer;
       constructor Create; overload; virtual;
       destructor Destroy; override;
     end;

     PpvXMLClasses=^TpvXMLClasses;
     TpvXMLClasses=array[0..XMLMaxListSize-1] of TpvXMLClass;

     TpvXMLClassList=class(TpvXMLClass)
      private
       InternalList:PpvXMLClasses;
       InternalCount,InternalCapacity:TpvInt32;
       function GetItem(Index:TpvInt32):TpvXMLClass;
       procedure SetItem(Index:TpvInt32;Value:TpvXMLClass);
       function GetItemPointer(Index:TpvInt32):TpvXMLClass;
      public
       ClearWithContentDestroying:boolean;
       CapacityMinimium:TpvInt32;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure ClearWithFree;
       function Add(Item:TpvXMLClass):TpvInt32;
       function Append(Item:TpvXMLClass):TpvInt32;
       function AddList(List:TpvXMLClassList):TpvInt32;
       function AppendList(List:TpvXMLClassList):TpvInt32;
       function NewClass:TpvXMLClass;
       procedure Insert(Index:TpvInt32;Item:TpvXMLClass);
       procedure Delete(Index:TpvInt32);
       procedure DeleteClass(Index:TpvInt32);
       function Remove(Item:TpvXMLClass):TpvInt32;
       function RemoveClass(Item:TpvXMLClass):TpvInt32;
       function Find(Item:TpvXMLClass):TpvInt32;
       function IndexOf(Item:TpvXMLClass):TpvInt32;
       procedure Exchange(Index1,Index2:TpvInt32);
       procedure SetCapacity(NewCapacity:TpvInt32);
       procedure SetOptimalCapacity(TargetCapacity:TpvInt32);
       procedure SetCount(NewCount:TpvInt32);
       function Push(Item:TpvXMLClass):TpvInt32;
       function Pop(var Item:TpvXMLClass):boolean; overload;
       function Pop:TpvXMLClass; overload;
       function Last:TpvXMLClass;
       property Count:TpvInt32 read InternalCount;
       property Capacity:TpvInt32 read InternalCapacity write SetCapacity;
       property Item[Index:TpvInt32]:TpvXMLClass read GetItem write SetItem; default;
       property Items[Index:TpvInt32]:TpvXMLClass read GetItem write SetItem;
       property PItems[Index:TpvInt32]:TpvXMLClass read GetItemPointer;
     end;

     TpvXMLClassLinkedList=class(TpvXMLClass)
      public
       ClearWithContentDestroying:boolean;
       First,Last:TpvXMLClass;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure ClearWithFree;
       procedure Add(Item:TpvXMLClass);
       procedure Append(Item:TpvXMLClass);
       procedure AddLinkedList(List:TpvXMLClassLinkedList);
       procedure AppendLinkedList(List:TpvXMLClassLinkedList);
       procedure Remove(Item:TpvXMLClass);
       procedure RemoveClass(Item:TpvXMLClass);
       procedure Push(Item:TpvXMLClass);
       function Pop(var Item:TpvXMLClass):boolean; overload;
       function Pop:TpvXMLClass; overload;
       function Count:TpvInt32;
     end;

     TpvXMLString={$ifdef XMLUnicode}{$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend}{$else}TpvRawByteString{$endif};
     TpvXMLChar={$ifdef XMLUnicode}WideChar{$else}TpvRawByteChar{$endif};

     TpvXMLParameter=class(TpvXMLClass)
      public
       Name:TpvRawByteString;
       Value:TpvXMLString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLParameter); virtual;
     end;

     TpvXMLItemList=class;

     TpvXMLTag=class;

     TpvXMLTags=array of TpvXMLTag;

     TpvXMLItem=class(TpvXMLClass)
      public
       Items:TpvXMLItemList;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear; virtual;
       procedure Add(Item:TpvXMLItem);
       procedure Assign(From:TpvXMLItem); virtual;
       function FindTag(const TagName:TpvRawByteString):TpvXMLTag;
       function FindTags(const TagName:TpvRawByteString):TpvXMLTags;
     end;

     TpvXMLItemList=class(TpvXMLClassList)
      private
       function GetItem(Index:TpvInt32):TpvXMLItem;
       procedure SetItem(Index:TpvInt32;Value:TpvXMLItem);
      public
       constructor Create; override;
       destructor Destroy; override;
       function NewClass:TpvXMLItem;
       function FindTag(const TagName:TpvRawByteString):TpvXMLTag;
       function FindTags(const TagName:TpvRawByteString):TpvXMLTags;
       property Item[Index:TpvInt32]:TpvXMLItem read GetItem write SetItem; default;
       property Items[Index:TpvInt32]:TpvXMLItem read GetItem write SetItem;
     end;

     TpvXMLText=class(TpvXMLItem)
      public
       Text:TpvXMLString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXMLCommentTag=class(TpvXMLItem)
      public
       Text:TpvRawByteString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXMLTagParameterHashMap=TpvStringHashMap<TpvXMLParameter>;

     TpvXMLTag=class(TpvXMLItem)
      public
       Name:TpvRawByteString;
       Parameter:array of TpvXMLParameter;
       ParameterHashMap:TpvXMLTagParameterHashMap;
       IsAloneTag:boolean;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear; override;
       procedure Assign(From:TpvXMLItem); override;
       function FindParameter(ParameterName:TpvRawByteString):TpvXMLParameter;
       function GetParameter(ParameterName:TpvRawByteString;default:TpvRawByteString=''):TpvRawByteString;
       function AddParameter(AParameter:TpvXMLParameter):boolean; overload;
       function AddParameter(Name:TpvRawByteString;Value:TpvXMLString):boolean; overload;
       function RemoveParameter(AParameter:TpvXMLParameter):boolean; overload;
       function RemoveParameter(ParameterName:TpvRawByteString):boolean; overload;
     end;

     TpvXMLProcessTag=class(TpvXMLTag)
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
     end;

     TpvXMLScriptTag=class(TpvXMLItem)
      public
       Text:TpvRawByteString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXMLCDataTag=class(TpvXMLItem)
      public
       Text:TpvRawByteString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXMLDOCTYPETag=class(TpvXMLItem)
      public
       Text:TpvRawByteString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXMLExtraTag=class(TpvXMLItem)
      public
       Text:TpvRawByteString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXMLItem); override;
       procedure SetText(AText:TpvRawByteString);
     end;

     TpvXML=class(TpvXMLClass)
      private
       function ReadXMLText:TpvRawByteString;
       procedure WriteXMLText(Text:TpvRawByteString);
    function Read(Stream: TStream): boolean;
      public
       Root:TpvXMLItem;
       AutomaticAloneTagDetection:boolean;
       FormatIndent:boolean;
       FormatIndentText:boolean;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TpvXML);
       function Parse(Stream:TStream):boolean;
       function Write(Stream:TStream;IdentSize:TpvInt32=2):boolean;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
       property Text:TpvRawByteString read ReadXMLText write WriteXMLText;
     end;

implementation

constructor TpvXMLClass.Create;
begin
 inherited Create;
 Previous:=nil;
 Next:=nil;
 Core:=nil;
end;

destructor TpvXMLClass.Destroy;
begin
 inherited Destroy;
end;

constructor TpvXMLClassList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=false;
 InternalCount:=0;
 InternalCapacity:=0;
 InternalList:=nil;
 CapacityMinimium:=0;
 Clear;
end;

destructor TpvXMLClassList.Destroy;
begin
 Clear;
 if assigned(InternalList) and (InternalCapacity<>0) then begin
  FreeMem(InternalList);
 end;
 inherited Destroy;
end;

procedure TpvXMLClassList.Clear;
begin
 if ClearWithContentDestroying then begin
  ClearWithFree;
 end else begin
  ClearNoFree;
 end;
end;

procedure TpvXMLClassList.ClearNoFree;
begin
 SetCount(0);
end;

procedure TpvXMLClassList.ClearWithFree;
var Counter:TpvInt32;
begin
 for Counter:=0 to InternalCount-1 do begin
  FreeAndNil(InternalList^[Counter]);
 end;
 SetCount(0);
end;

procedure TpvXMLClassList.SetCapacity(NewCapacity:TpvInt32);
begin
 if (InternalCapacity<>NewCapacity) and
    ((NewCapacity>=0) and (NewCapacity<XMLMaxListSize)) then begin
  ReallocMem(InternalList,NewCapacity*SizeOf(TpvXMLClass));
  if InternalCapacity<NewCapacity then begin
   FillChar(InternalList^[InternalCapacity],(NewCapacity-InternalCapacity)*SizeOf(TpvXMLClass),#0);
  end;
  InternalCapacity:=NewCapacity;
 end;
end;

procedure TpvXMLClassList.SetOptimalCapacity(TargetCapacity:TpvInt32);
var CapacityMask:TpvInt32;
begin
 if (TargetCapacity>=0) and (TargetCapacity<XMLMaxListSize) then begin
  if TargetCapacity<256 then begin
   CapacityMask:=15;
  end else if TargetCapacity<1024 then begin
   CapacityMask:=255;
  end else if TargetCapacity<4096 then begin
   CapacityMask:=1023;
  end else if TargetCapacity<16384 then begin
   CapacityMask:=4095;
  end else if TargetCapacity<65536 then begin
   CapacityMask:=16383;
  end else begin
   CapacityMask:=65535;
  end;
  SetCapacity((TargetCapacity+CapacityMask+CapacityMinimium) and not CapacityMask);
 end;
end;

procedure TpvXMLClassList.SetCount(NewCount:TpvInt32);
begin
 if (NewCount>=0) and (NewCount<XMLMaxListSize) then begin
  SetOptimalCapacity(NewCount);
  if InternalCount<NewCount then begin
   FillChar(InternalList^[InternalCount],(NewCount-InternalCount)*SizeOf(TpvXMLClass),#0);
  end;
  InternalCount:=NewCount;
 end;
end;

function TpvXMLClassList.Add(Item:TpvXMLClass):TpvInt32;
begin
 result:=InternalCount;
 SetCount(result+1);
 InternalList^[result]:=Item;
end;

function TpvXMLClassList.Append(Item:TpvXMLClass):TpvInt32;
begin
 result:=Add(Item);
end;

function TpvXMLClassList.AddList(List:TpvXMLClassList):TpvInt32;
var Counter,Index:TpvInt32;
begin
 result:=-1;
 for Counter:=0 to List.Count-1 do begin
  Index:=Add(List[Counter]);
  if Counter=0 then begin
   result:=Index;
  end;
 end;
end;

function TpvXMLClassList.AppendList(List:TpvXMLClassList):TpvInt32;
begin
 result:=AddList(List);
end;

function TpvXMLClassList.NewClass:TpvXMLClass;
var Item:TpvXMLClass;
begin
 Item:=TpvXMLClass.Create;
 Add(Item);
 result:=Item;
end;

procedure TpvXMLClassList.Insert(Index:TpvInt32;Item:TpvXMLClass);
var Counter:TpvInt32;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  SetCount(InternalCount+1);
  for Counter:=InternalCount-1 downto Index do begin
   InternalList^[Counter+1]:=InternalList^[Counter];
  end;
  InternalList^[Index]:=Item;
 end else if Index=InternalCount then begin
  Add(Item);
 end else if Index>InternalCount then begin
  SetCount(Index);
  Add(Item);
 end;
end;

procedure TpvXMLClassList.Delete(Index:TpvInt32);
var i,j:TpvInt32;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  j:=InternalCount-1;
  i:=Index;
  Move(InternalList^[i+1],InternalList^[i],(j-i)*SizeOf(TpvXMLClass));
  SetCount(j);
 end;
end;

procedure TpvXMLClassList.DeleteClass(Index:TpvInt32);
var i,j:TpvInt32;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  j:=InternalCount-1;
  i:=Index;
  if assigned(InternalList^[i]) then begin
   InternalList^[i].Free;
   InternalList^[i]:=nil;
  end;
  Move(InternalList^[i+1],InternalList^[i],(j-i)*SizeOf(TpvXMLClass));
  SetCount(j);
 end;
end;

function TpvXMLClassList.Remove(Item:TpvXMLClass):TpvInt32;
var i,j,k:TpvInt32;
begin
 result:=-1;
 k:=InternalCount;
 j:=-1;
 for i:=0 to k-1 do begin
  if InternalList^[i]=Item then begin
   j:=i;
   break;
  end;
 end;
 if j>=0 then begin
  dec(k);
  Move(InternalList^[j+1],InternalList^[j],(k-j)*SizeOf(TpvXMLClass));
  SetCount(k);
  result:=j;
 end;
end;

function TpvXMLClassList.RemoveClass(Item:TpvXMLClass):TpvInt32;
var i,j,k:TpvInt32;
begin
 result:=-1;
 k:=InternalCount;
 j:=-1;
 for i:=0 to k-1 do begin
  if InternalList^[i]=Item then begin
   j:=i;
   break;
  end;
 end;
 if j>=0 then begin
  dec(k);
  Move(InternalList^[j+1],InternalList^[j],(k-j)*SizeOf(TpvXMLClass));
  SetCount(k);
  Item.Free;
  result:=j;
 end;
end;

function TpvXMLClassList.Find(Item:TpvXMLClass):TpvInt32;
var i:TpvInt32;
begin
 result:=-1;
 for i:=0 to InternalCount-1 do begin
  if InternalList^[i]=Item then begin
   result:=i;
   exit;
  end;
 end;
end;

function TpvXMLClassList.IndexOf(Item:TpvXMLClass):TpvInt32;
var i:TpvInt32;
begin
 result:=-1;
 for i:=0 to InternalCount-1 do begin
  if InternalList^[i]=Item then begin
   result:=i;
   exit;
  end;
 end;
end;

procedure TpvXMLClassList.Exchange(Index1,Index2:TpvInt32);
var TempPointer:TpvXMLClass;
begin
 if (Index1>=0) and (Index1<InternalCount) and (Index2>=0) and (Index2<InternalCount) then begin
  TempPointer:=InternalList^[Index1];
  InternalList^[Index1]:=InternalList^[Index2];
  InternalList^[Index2]:=TempPointer;
 end;
end;

function TpvXMLClassList.Push(Item:TpvXMLClass):TpvInt32;
begin
 result:=Add(Item);
end;

function TpvXMLClassList.Pop(var Item:TpvXMLClass):boolean;
begin
 result:=InternalCount>0;
 if result then begin
  Item:=InternalList^[InternalCount-1];
  Delete(InternalCount-1);
 end;
end;

function TpvXMLClassList.Pop:TpvXMLClass;
begin
 if InternalCount>0 then begin
  result:=InternalList^[InternalCount-1];
  Delete(InternalCount-1);
 end else begin
  result:=nil;
 end;
end;

function TpvXMLClassList.Last:TpvXMLClass;
begin
 if InternalCount>0 then begin
  result:=InternalList^[InternalCount-1];
 end else begin
  result:=nil;
 end;
end;

function TpvXMLClassList.GetItem(Index:TpvInt32):TpvXMLClass;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  result:=InternalList^[Index];
 end else begin
  result:=nil;
 end;
end;

procedure TpvXMLClassList.SetItem(Index:TpvInt32;Value:TpvXMLClass);
begin
 if (Index>=0) and (Index<InternalCount) then begin
  InternalList^[Index]:=Value;
 end;
end;

function TpvXMLClassList.GetItemPointer(Index:TpvInt32):TpvXMLClass;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  result:=@InternalList^[Index];
 end else begin
  result:=nil;
 end;
end;

constructor TpvXMLClassLinkedList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=false;
 ClearNoFree;
end;

destructor TpvXMLClassLinkedList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvXMLClassLinkedList.Clear;
begin
 if ClearWithContentDestroying then begin
  ClearWithFree;
 end else begin
  ClearNoFree;
 end;
end;

procedure TpvXMLClassLinkedList.ClearNoFree;
var Current,Next:TpvXMLClass;
begin
 Current:=First;
 while assigned(Current) do begin
  Next:=Current.Next;
  Remove(Current);
  Current:=Next;
 end;
 First:=nil;
 Last:=nil;
end;

procedure TpvXMLClassLinkedList.ClearWithFree;
var Current,Next:TpvXMLClass;
begin
 Current:=First;
 while assigned(Current) do begin
  Next:=Current.Next;
  RemoveClass(Current);
  Current:=Next;
 end;
 First:=nil;
 Last:=nil;
end;

procedure TpvXMLClassLinkedList.Add(Item:TpvXMLClass);
begin
 Item.Next:=nil;
 if assigned(Last) then begin
  Last.Next:=Item;
  Item.Previous:=Last;
 end else begin
  Item.Previous:=nil;
  First:=Item;
 end;
 Last:=Item;
end;

procedure TpvXMLClassLinkedList.Append(Item:TpvXMLClass);
begin
 Add(Item);
end;

procedure TpvXMLClassLinkedList.AddLinkedList(List:TpvXMLClassLinkedList);
begin
 Last.Next:=List.First;
 if assigned(List.First) then begin
  List.First.Previous:=Last;
 end;
 Last:=List.Last;
 List.First:=nil;
 List.Last:=nil;
end;

procedure TpvXMLClassLinkedList.AppendLinkedList(List:TpvXMLClassLinkedList);
begin
 AddLinkedList(List);
end;

procedure TpvXMLClassLinkedList.Remove(Item:TpvXMLClass);
begin
 if assigned(Item) then begin
  if assigned(Item.Next) then begin
   Item.Next.Previous:=Item.Previous;
  end else if Last=Item then begin
   Last:=Item.Previous;
  end;
  if assigned(Item.Previous) then begin
   Item.Previous.Next:=Item.Next;
  end else if First=Item then begin
   First:=Item.Next;
  end;
  Item.Previous:=nil;
  Item.Next:=nil;
 end;
end;

procedure TpvXMLClassLinkedList.RemoveClass(Item:TpvXMLClass);
begin
 if assigned(Item) then begin
  Remove(Item);
  Item.Free;
 end;
end;

procedure TpvXMLClassLinkedList.Push(Item:TpvXMLClass);
begin
 Add(Item);
end;

function TpvXMLClassLinkedList.Pop(var Item:TpvXMLClass):boolean;
begin
 result:=assigned(Last);
 if result then begin
  Item:=Last;
  Remove(Last);
 end;
end;

function TpvXMLClassLinkedList.Pop:TpvXMLClass;
begin
 result:=Last;
 if assigned(Last) then begin
  Remove(Last);
 end;
end;

function TpvXMLClassLinkedList.Count:TpvInt32;
var Current:TpvXMLClass;
begin
 result:=0;
 Current:=First;
 while assigned(Current) do begin
  inc(result);
  Current:=Current.Next;
 end;
end;

constructor TpvXMLItem.Create;
begin
 inherited Create;
 Items:=TpvXMLItemList.Create;
end;

destructor TpvXMLItem.Destroy;
begin
 Items.Free;
 inherited Destroy;
end;

procedure TpvXMLItem.Clear;
begin
 Items.Clear;
end;

procedure TpvXMLItem.Add(Item:TpvXMLItem);
begin
 Items.Add(Item);
end;

procedure TpvXMLItem.Assign(From:TpvXMLItem);
var i:TpvInt32;
    NewItem:TpvXMLItem;
begin
 Items.ClearWithFree;
 NewItem:=nil;
 for i:=0 to Items.Count-1 do begin
  if Items[i] is TpvXMLTag then begin
   NewItem:=TpvXMLTag.Create;
  end else if Items[i] is TpvXMLCommentTag then begin
   NewItem:=TpvXMLCommentTag.Create;
  end else if Items[i] is TpvXMLScriptTag then begin
   NewItem:=TpvXMLScriptTag.Create;
  end else if Items[i] is TpvXMLProcessTag then begin
   NewItem:=TpvXMLProcessTag.Create;
  end else if Items[i] is TpvXMLCDATATag then begin
   NewItem:=TpvXMLCDATATag.Create;
  end else if Items[i] is TpvXMLDOCTYPETag then begin
   NewItem:=TpvXMLDOCTYPETag.Create;
  end else if Items[i] is TpvXMLExtraTag then begin
   NewItem:=TpvXMLExtraTag.Create;
  end else if Items[i] is TpvXMLText then begin
   NewItem:=TpvXMLText.Create;
  end else if Items[i] is TpvXMLItem then begin
   NewItem:=Items[i].Create;
  end else begin
   continue;
  end;
  NewItem.Assign(Items[i]);
  Items.Add(NewItem);
 end;
end;

function TpvXMLItem.FindTag(const TagName:TpvRawByteString):TpvXMLTag;
begin
 result:=Items.FindTag(TagName);
end;

function TpvXMLItem.FindTags(const TagName:TpvRawByteString):TpvXMLTags;
begin
 result:=Items.FindTags(TagName);
end;

constructor TpvXMLItemList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=true;
//CapacityMask:=$f;
 CapacityMinimium:=0;
end;

destructor TpvXMLItemList.Destroy;
begin
 ClearWithFree;
 inherited Destroy;
end;

function TpvXMLItemList.NewClass:TpvXMLItem;
begin
 result:=TpvXMLItem.Create;
 Add(result);
end;

function TpvXMLItemList.GetItem(Index:TpvInt32):TpvXMLItem;
begin
 result:=TpvXMLItem(inherited Items[Index]);
end;

procedure TpvXMLItemList.SetItem(Index:TpvInt32;Value:TpvXMLItem);
begin
 inherited Items[Index]:=Value;
end;

function TpvXMLItemList.FindTag(const TagName:TpvRawByteString):TpvXMLTag;
var i:TpvInt32;
    Item:TpvXMLItem;
begin
 result:=nil;
 for i:=0 to Count-1 do begin
  Item:=TpvXMLItem(inherited Items[i]);
  if (assigned(Item) and (Item is TpvXMLTag)) and (TpvXMLTag(Item).Name=TagName) then begin
   result:=TpvXMLTag(Item);
   break;
  end;
 end;
end;

function TpvXMLItemList.FindTags(const TagName:TpvRawByteString):TpvXMLTags;
var i,j:TpvInt32;
    Item:TpvXMLItem;
begin
 result:=nil;
 j:=0;
 try
  for i:=0 to Count-1 do begin
   Item:=TpvXMLItem(inherited Items[i]);
   if (assigned(Item) and (Item is TpvXMLTag)) and (TpvXMLTag(Item).Name=TagName) then begin
    if length(result)<(j+1) then begin
     SetLength(result,(j+1)*2);
    end;
    result[j]:=Item as TpvXMLTag;
    inc(j);
   end;
  end;
 finally
  SetLength(result,j);
 end;
end;

constructor TpvXMLParameter.Create;
begin
 inherited Create;
 Name:='';
 Value:='';
end;

destructor TpvXMLParameter.Destroy;
begin
 Name:='';
 Value:='';
 inherited Destroy;
end;

procedure TpvXMLParameter.Assign(From:TpvXMLParameter);
begin
 Name:=From.Name;
 Value:=From.Value;
end;

constructor TpvXMLText.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLText.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLText.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLText then begin
  Text:=TpvXMLText(From).Text;
 end;
end;

procedure TpvXMLText.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

constructor TpvXMLCommentTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLCommentTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLCommentTag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLCommentTag then begin
  Text:=TpvXMLCommentTag(From).Text;
 end;
end;

procedure TpvXMLCommentTag.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

constructor TpvXMLTag.Create;
begin
 inherited Create;
 Name:='';
 Parameter:=nil;
 ParameterHashMap:=TpvXMLTagParameterHashMap.Create(nil);
end;

destructor TpvXMLTag.Destroy;
begin
 Clear;
 FreeAndNil(ParameterHashMap);
 inherited Destroy;
end;

procedure TpvXMLTag.Clear;
var Counter:TpvInt32;
begin
 inherited Clear;
 ParameterHashMap.Clear;
 for Counter:=0 to length(Parameter)-1 do begin
  Parameter[Counter].Free;
 end;
 SetLength(Parameter,0);
 Name:='';
end;

procedure TpvXMLTag.Assign(From:TpvXMLItem);
var Counter:TpvInt32;
begin
 inherited Assign(From);
 if From is TpvXMLTag then begin
  for Counter:=0 to length(Parameter)-1 do begin
   Parameter[Counter].Free;
  end;
  SetLength(Parameter,0);
  Name:=TpvXMLTag(From).Name;
  for Counter:=0 to length(TpvXMLTag(From).Parameter)-1 do begin
   AddParameter(TpvXMLTag(From).Parameter[Counter].Name,TpvXMLTag(From).Parameter[Counter].Value);
  end;
 end;
end;

function TpvXMLTag.FindParameter(ParameterName:TpvRawByteString):TpvXMLParameter;
begin
 result:=ParameterHashMap[ParameterName];
end;

function TpvXMLTag.GetParameter(ParameterName:TpvRawByteString;default:TpvRawByteString=''):TpvRawByteString;
var Parameter:TpvXMLParameter;
begin
 Parameter:=FindParameter(ParameterName);
 if assigned(Parameter) then begin
  result:=Parameter.Value;
 end else begin
  result:=Default;
 end;
end;

function TpvXMLTag.AddParameter(AParameter:TpvXMLParameter):boolean;
var Index:TpvInt32;
begin
 try
  Index:=length(Parameter);
  SetLength(Parameter,Index+1);
  Parameter[Index]:=AParameter;
  ParameterHashMap.Add(AParameter.Name,AParameter);
  result:=true;
 except
  result:=false;
 end;
end;

function TpvXMLTag.AddParameter(Name:TpvRawByteString;Value:TpvXMLString):boolean;
var AParameter:TpvXMLParameter;
begin
 AParameter:=TpvXMLParameter.Create;
 AParameter.Name:=Name;
 AParameter.Value:=Value;
 result:=AddParameter(AParameter);
end;

function TpvXMLTag.RemoveParameter(AParameter:TpvXMLParameter):boolean;
var Found,Counter:TpvInt32;
begin
 result:=false;
 Found:=-1;
 for Counter:=0 to length(Parameter)-1 do begin
  if Parameter[Counter]=AParameter then begin
   Found:=Counter;
   break;
  end;
 end;
 if Found>=0 then begin
  for Counter:=Found to length(Parameter)-2 do begin
   Parameter[Counter]:=Parameter[Counter+1];
  end;
  SetLength(Parameter,length(Parameter)-1);
  ParameterHashMap.Delete(AParameter.Name);
  AParameter.Free;
  result:=true;
 end;
end;

function TpvXMLTag.RemoveParameter(ParameterName:TpvRawByteString):boolean;
begin
 result:=RemoveParameter(FindParameter(ParameterName));
end;

constructor TpvXMLProcessTag.Create;
begin
 inherited Create;
end;

destructor TpvXMLProcessTag.Destroy;
begin
 inherited Destroy;
end;

procedure TpvXMLProcessTag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
end;

constructor TpvXMLScriptTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLScriptTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLScriptTag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLScriptTag then begin
  Text:=TpvXMLScriptTag(From).Text;
 end;
end;

procedure TpvXMLScriptTag.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

constructor TpvXMLCDataTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLCDataTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLCDataTag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLCDataTag then begin
  Text:=TpvXMLCDataTag(From).Text;
 end;
end;

procedure TpvXMLCDataTag.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

constructor TpvXMLDOCTYPETag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLDOCTYPETag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLDOCTYPETag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLDOCTYPETag then begin
  Text:=TpvXMLDOCTYPETag(From).Text;
 end;
end;

procedure TpvXMLDOCTYPETag.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

constructor TpvXMLExtraTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TpvXMLExtraTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TpvXMLExtraTag.Assign(From:TpvXMLItem);
begin
 inherited Assign(From);
 if From is TpvXMLExtraTag then begin
  Text:=TpvXMLExtraTag(From).Text;
 end;
end;

procedure TpvXMLExtraTag.SetText(AText:TpvRawByteString);
begin
 Text:=AText;
end;

const EntityChars:array[1..102,1..2] of TpvXMLString=(('&quot;',#34),('&amp;',#38),('&apos;',''''),
                                                    ('&lt;',#60),('&gt;',#62),('&euro;',#128),('&nbsp;',#160),('&iexcl;',#161),
                                                    ('&cent;',#162),('&pound;',#163),('&curren;',#164),('&yen;',#165),
                                                    ('&brvbar;',#166),('&sect;',#167),('&uml;',#168),('&copy;',#169),
                                                    ('&ordf;',#170),('&laquo;',#171),('&not;',#172),('&shy;',#173),
                                                    ('&reg;',#174),('&macr;',#175),('&deg;',#176),('&plusmn;',#177),
                                                    ('&sup2;',#178),('&sup3;',#179),('&acute;',#180),('&micro;',#181),
                                                    ('&para;',#182),('&middot;',#183),('&cedil;',#184),('&sup1;',#185),
                                                    ('&ordm;',#186),('&raquo;',#187),('&frac14;',#188),('&frac12;',#189),
                                                    ('&frac34;',#190),('&iquest;',#191),('&Agrave;',#192),('&Aacute;',#193),
                                                    ('&Acirc;',#194),('&Atilde;',#195),('&Auml;',#196),('&Aring;',#197),
                                                    ('&AElig;',#198),('&Ccedil;',#199),('&Egrave;',#200),('&Eacute;',#201),
                                                    ('&Ecirc;',#202),('&Euml;',#203),('&Igrave;',#204),('&Iacute;',#205),
                                                    ('&Icirc;',#206),('&Iuml;',#207),('&ETH;',#208),('&Ntilde;',#209),
                                                    ('&Ograve;',#210),('&Oacute;',#211),('&Ocirc;',#212),('&Otilde;',#213),
                                                    ('&Ouml;',#214),('&times;',#215),('&Oslash;',#216),('&Ugrave;',#217),
                                                    ('&Uacute;',#218),('&Ucirc;',#219),('&Uuml;',#220),('&Yacute;',#221),
                                                    ('&THORN;',#222),('&szlig;',#223),('&agrave;',#224),('&aacute;',#225),
                                                    ('&acirc;',#226),('&atilde;',#227),('&auml;',#228),('&aring;',#229),
                                                    ('&aelig;',#230),('&ccedil;',#231),('&egrave;',#232),('&eacute;',#233),
                                                    ('&ecirc;',#234),('&euml;',#235),('&igrave;',#236),('&iacute;',#237),
                                                    ('&icirc;',#238),('&iuml;',#239),('&eth;',#240),('&ntilde;',#241),
                                                    ('&ograve;',#242),('&oacute;',#243),('&ocirc;',#244),('&otilde;',#245),
                                                    ('&ouml;',#246),('&divide;',#247),('&oslash;',#248),('&ugrave;',#249),
                                                    ('&uacute;',#250),('&ucirc;',#251),('&uuml;',#252),('&yacute;',#253),
                                                    ('&thorn;',#254),('&yuml;',#255));

type TEntitiesCharLookUpItem=record
      IsEntity:boolean;
      Entity:TpvRawByteString;
     end;

     TEntitiesCharLookUpTable=array[0..{$ifdef XMLUnicode}65535{$else}255{$endif}] of TEntitiesCharLookUpItem;

     TEntityStringHashMap=class(TpvStringHashMap<TpvInt32>);

var EntitiesCharLookUp:TEntitiesCharLookUpTable;
    EntityStringHashMap:TEntityStringHashMap;

const EntityInitialized:boolean=false;

procedure InitializeEntites;
var EntityCounter:TpvInt32;
begin
 if not EntityInitialized then begin
  EntityInitialized:=true;
  EntityStringHashMap:=TEntityStringHashMap.Create(-1);
  FillChar(EntitiesCharLookUp,SizeOf(TEntitiesCharLookUpTable),#0);
  for EntityCounter:=low(EntityChars) to high(EntityChars) do begin
   EntityStringHashMap.Add(EntityChars[EntityCounter,1],EntityCounter);
   with EntitiesCharLookUp[ord(EntityChars[EntityCounter,2][1])] do begin
    IsEntity:=true;
    Entity:=EntityChars[EntityCounter,1];
   end;
  end;
 end;
end;

procedure FinalizeEntites;
begin
 FreeAndNil(EntityStringHashMap);
 EntityInitialized:=false;
end;

function ConvertToEntities(AString:TpvXMLString;IdentLevel:TpvInt32=0):TpvRawByteString;
var Counter,IdentCounter:TpvInt32;
    c:TpvXMLChar;
begin
 result:='';
 for Counter:=1 to length(AString) do begin
  c:=AString[Counter];
  if c=#13 then begin
   if ((Counter+1)<=length(AString)) and (AString[Counter+1]=#10) then begin
    continue;
   end;
   c:=#10;
  end;
  if EntitiesCharLookUp[ord(c)].IsEntity then begin
   result:=result+EntitiesCharLookUp[ord(c)].Entity;
  end else if (c=#9) or (c=#10) or (c=#13) or ((c>=#32) and (c<=#127)) then begin
   result:=result+c;
   if c=#10 then begin
    for IdentCounter:=1 to IdentLevel do begin
     result:=result+' ';
    end;
   end;
  end else begin
{$ifdef XMLUnicode}
   if c<#255 then begin
    result:=result+'&#'+TpvRawByteString(IntToStr(ord(c)))+';';
   end else begin
    result:=result+'&#x'+TpvRawByteString(IntToHex(ord(c),4))+';';
   end;
{$else}
   result:=result+'&#'+TpvRawByteString(IntToStr(TpvUInt8(c)))+';';
{$endif}
  end;
 end;
end;

constructor TpvXML.Create;
begin
 inherited Create;
 InitializeEntites;
 Root:=TpvXMLItem.Create;
 AutomaticAloneTagDetection:=true;
 FormatIndent:=true;
 FormatIndentText:=false;
end;

destructor TpvXML.Destroy;
begin
 Root.Free;
 inherited Destroy;
end;

procedure TpvXML.Assign(From:TpvXML);
begin
 Root.Assign(From.Root);
 AutomaticAloneTagDetection:=From.AutomaticAloneTagDetection;
 FormatIndent:=From.FormatIndent;
 FormatIndentText:=From.FormatIndentText;
end;

function TpvXML.Parse(Stream:TStream):boolean;
const NameCanBeginWithCharSet:set of TpvRawByteChar=['A'..'Z','a'..'z','_'];
      NameCanContainCharSet:set of TpvRawByteChar=['A'..'Z','a'..'z','0'..'9','.',':','_','-'];
      BlankCharSet:set of TpvRawByteChar=[#0..#$20];//[#$9,#$A,#$D,#$20];
type TEncoding=(ASCII,UTF8,UTF16);
var Errors:boolean;
    CurrentChar:TpvRawByteChar;
    StreamEOF:boolean;
    Encoding:TEncoding;

 function IsEOF:boolean;
 begin
  result:=StreamEOF or (Stream.Position>Stream.Size);
 end;

 function IsEOFOrErrors:boolean;
 begin
  result:=IsEOF or Errors;
 end;

 function NextChar:TpvRawByteChar;
 begin
  if Stream.Read(CurrentChar,SizeOf(TpvRawByteChar))<>SizeOf(TpvRawByteChar) then begin
   StreamEOF:=true;
   CurrentChar:=#0;
  end;
  result:=CurrentChar;
//system.Write(result);
 end;

 procedure SkipBlank;
 begin
  while (CurrentChar in BlankCharSet) and not IsEOFOrErrors do begin
   NextChar;
  end;
 end;

 function GetName:TpvRawByteString;
 var i:TpvInt32;
 begin
  result:='';
  i:=0;
  if (CurrentChar in NameCanBeginWithCharSet) and not IsEOFOrErrors then begin
   while (CurrentChar in NameCanContainCharSet) and not IsEOFOrErrors do begin
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,RoundUpToPowerOfTwo(i+1));
    end;
    result[i]:=CurrentChar;
    NextChar;
   end;
  end;
  SetLength(result,i);
 end;

 function ExpectToken(const s:TpvRawByteString):boolean; overload;
 var i:TpvInt32;
 begin
  result:=true;
  for i:=1 to length(s) do begin
   if s[i]<>CurrentChar then begin
    result:=false;
    break;
   end;
   NextChar;
  end;
 end;

 function ExpectToken(const c:TpvRawByteChar):boolean; overload;
 begin
  result:=false;
  if c=CurrentChar then begin
   result:=true;
   NextChar;
  end;
 end;

 function GetUntil(var Content:TpvRawByteString;const TerminateToken:TpvRawByteString):boolean;
 var i,j,OldPosition:TpvInt32;
     OldEOF:boolean;
     OldChar:TpvRawByteChar;
 begin
  result:=false;
  j:=0;
  Content:='';
  while not IsEOFOrErrors do begin
   if (length(TerminateToken)>0) and (TerminateToken[1]=CurrentChar) and (((Stream.Size-Stream.Position)+1)>=length(TerminateToken)) then begin
    OldPosition:=Stream.Position;
    OldEOF:=StreamEOF;
    OldChar:=CurrentChar;
    for i:=1 to length(TerminateToken) do begin
     if TerminateToken[i]=CurrentChar then begin
      if i=length(TerminateToken) then begin
       NextChar;
       SetLength(Content,j);
       result:=true;
       exit;
      end;
     end else begin
      break;
     end;
     NextChar;
    end;
    Stream.Seek(OldPosition,soFromBeginning);
    StreamEOF:=OldEOF;
    CurrentChar:=OldChar;
   end;
   inc(j);
   if (j+1)>length(Content) then begin
    SetLength(Content,RoundUpToPowerOfTwo(j+1));
   end;
   Content[j]:=CurrentChar;
   NextChar;
  end;
  SetLength(Content,j);
 end;

 function GetDecimalValue:TpvInt32;
 var Negitive:boolean;
 begin
  Negitive:=CurrentChar='-';
  if Negitive then begin
   NextChar;
  end else if CurrentChar='+' then begin
   NextChar;
  end;
  result:=0;
  while (CurrentChar in ['0'..'9']) and not IsEOFOrErrors do begin
   result:=(result*10)+(ord(CurrentChar)-ord('0'));
   NextChar;
  end;
  if Negitive then begin
   result:=-result;
  end;
 end;

 function GetHeximalValue:TpvInt32;
 var Negitive:boolean;
     Value:TpvInt32;
 begin
  Negitive:=CurrentChar='-';
  if Negitive then begin
   NextChar;
  end else if CurrentChar='+' then begin
   NextChar;
  end;
  result:=0;
  Value:=0;
  while not IsEOFOrErrors do begin
   case CurrentChar of
    '0'..'9':begin
     Value:=TpvUInt8(CurrentChar)-ord('0');
    end;
    'A'..'F':begin
     Value:=(TpvUInt8(CurrentChar)-ord('A'))+$a;
    end;
    'a'..'f':begin
     Value:=(TpvUInt8(CurrentChar)-ord('a'))+$a;
    end;
    else begin
     break;
    end;
   end;
   result:=(result shl 4) or Value;
   NextChar;
  end;
  if Negitive then begin
   result:=-result;
  end;
 end;

 function GetEntity:TpvXMLString;
 var Value:TpvInt32;
     Entity:TpvRawByteString;
     c:TpvXMLChar;
 begin
  result:='';
  if CurrentChar='&' then begin
   NextChar;
   if not IsEOF then begin
    if CurrentChar='#' then begin
     NextChar;
     if IsEOF then begin
      Errors:=true;
     end else begin
      if CurrentChar='x' then begin
       NextChar;
       Value:=GetHeximalValue;
      end else begin
       Value:=GetDecimalValue;
      end;
      if CurrentChar=';' then begin
       NextChar;
{$ifdef XMLUnicode}
       c:=WideChar(TpvUInt16(Value));
{$else}
       c:=TpvRawByteChar(TpvUInt8(Value));
{$endif}
       result:=c;
      end else begin
       Errors:=true;
      end;
     end;
    end else begin
     Entity:='&';
     while (CurrentChar in ['a'..'z','A'..'Z','0'..'9','_']) and not IsEOFOrErrors do begin
      Entity:=Entity+CurrentChar;
      NextChar;
     end;
     if CurrentChar=';' then begin
      Entity:=Entity+CurrentChar;
      NextChar;
      if EntityStringHashMap.TryGet(Entity,Value) then begin
       result:=EntityChars[Value,2];
      end else begin
       result:=Entity;
      end;
     end else begin
      Errors:=true;
     end;
    end;
   end;
  end;
 end;

 function ParseTagParameterValue(TerminateChar:TpvRawByteChar):TpvXMLString;
 var i,wc,c:TpvInt32;
 begin
  result:='';
  SkipBlank;
  i:=0;
  while (CurrentChar<>TerminateChar) and not IsEOFOrErrors do begin
   if (Encoding=TEncoding.UTF8) and (ord(CurrentChar)>=$80) then begin
    wc:=ord(CurrentChar) and $3f;
    if (wc and $20)<>0 then begin
     NextChar;
     c:=ord(CurrentChar);
     if (c and $c0)<>$80 then begin
      break;
     end;
     wc:=(wc shl 6) or (c and $3f);
    end;
    NextChar;
    c:=ord(CurrentChar);
    if (c and $c0)<>$80 then begin
     break;
    end;
    wc:=(wc shl 6) or (c and $3f);
    NextChar;
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,RoundUpToPowerOfTwo(i+1));
    end;
{$ifdef XMLUnicode}
    result[i]:=WideChar(wc);
{$else}
    result[i]:=TpvRawByteChar(wc);
{$endif}
   end else if CurrentChar='&' then begin
    SetLength(result,i);
    result:=result+GetEntity;
    i:=length(result);
   end else begin
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,RoundUpToPowerOfTwo(i+1));
    end;
{$ifdef XMLUnicode}
    result[i]:=WideChar(TpvUInt16(TpvUInt8(CurrentChar)+0));
{$else}
    result[i]:=CurrentChar;
{$endif}
    NextChar;
   end;
  end;
  SetLength(result,i);
  NextChar;
 end;

 procedure ParseTagParameter(XMLTag:TpvXMLTag);
 var ParameterName,ParameterValue:TpvRawByteString;
     TerminateChar:TpvRawByteChar;
 begin
  SkipBlank;
  while (CurrentChar in NameCanBeginWithCharSet) and not IsEOFOrErrors do begin
   ParameterName:=GetName;
   SkipBlank;
   if CurrentChar='=' then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     break;
    end;
   end else begin
    Errors:=true;
    break;
   end;
   SkipBlank;
   if CurrentChar in ['''','"'] then begin
    TerminateChar:=CurrentChar;
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     break;
    end;
    ParameterValue:=ParseTagParameterValue(TerminateChar);
    if Errors then begin
     break;
    end else begin
     XMLTag.AddParameter(ParameterName,ParameterValue);
     SkipBlank;
    end;
   end else begin
    Errors:=true;
    break;
   end;
  end;
 end;

 procedure Process(ParentItem:TpvXMLItem;Closed:boolean);
 var FinishLevel:boolean;

  procedure ParseText;
  var Text:TpvXMLString;
      XMLText:TpvXMLText;
      i,wc,c:TpvInt32;
{$ifndef XMLUnicode}
      w:TpvRawByteString;
{$endif}
  begin
   SkipBlank;
   if CurrentChar='<' then begin
    exit;
   end;
   i:=0;
   Text:='';
   SetLength(Text,16);
   while (CurrentChar<>'<') and not IsEOFOrErrors do begin
    if (Encoding=TEncoding.UTF8) and (ord(CurrentChar)>=$80) then begin
     wc:=ord(CurrentChar) and $3f;
     if (wc and $20)<>0 then begin
      NextChar;
      c:=ord(CurrentChar);
      if (c and $c0)<>$80 then begin
       break;
      end;
      wc:=(wc shl 6) or (c and $3f);
     end;
     NextChar;
     c:=ord(CurrentChar);
     if (c and $c0)<>$80 then begin
      break;
     end;
     wc:=(wc shl 6) or (c and $3f);
     NextChar;
{$ifdef XMLUnicode}
     if wc<=$d7ff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=WideChar(TpvUInt16(wc));
     end else if wc<=$dfff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end else if wc<=$fffd then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=WideChar(TpvUInt16(wc));
     end else if wc<=$ffff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end else if wc<=$10ffff then begin
      dec(wc,$10000);
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=WideChar(TpvUInt16((wc shr 10) or $d800));
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=WideChar(TpvUInt16((wc and $3ff) or $dc00));
     end else begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end;
{$else}
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,RoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=TpvRawByteChar(TpvUInt8(wc));
     end else begin
      w:=PUCUUTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,RoundUpToPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
    end else if CurrentChar='&' then begin
     SetLength(Text,i);
     Text:=Text+GetEntity;
     i:=length(Text);
    end else if CurrentChar in BlankCharSet then begin
{$ifdef XMLUnicode}
     inc(i);
     if (i+1)>length(Text) then begin
      SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
     end;
     Text[i]:=WideChar(TpvUInt16(TpvUInt8(CurrentChar)+0));
{$else}
     wc:=ord(CurrentChar);
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,RoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=TpvRawByteChar(TpvUInt8(wc));
     end else begin
      w:=PUCUUTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,RoundUpToPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
     SkipBlank;
    end else begin
{$ifdef XMLUnicode}
     inc(i);
     if (i+1)>length(Text) then begin
      SetLength(Text,VulkanRoundUpToPowerOfTwo(i+1));
     end;
     Text[i]:=WideChar(TpvUInt16(TpvUInt8(CurrentChar)+0));
{$else}
     wc:=ord(CurrentChar);
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,RoundUpToPowerOfTwo(i+1));
      end;
      Text[i]:=TpvRawByteChar(TpvUInt8(wc));
     end else begin
      w:=PUCUUTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,RoundUpToPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
     NextChar;
    end;
   end;
   SetLength(Text,i);
   if length(Text)<>0 then begin
    XMLText:=TpvXMLText.Create;
    XMLText.Text:=Text;
    ParentItem.Add(XMLText);
   end;
  end;

  procedure ParseProcessTag;
  var TagName,EncodingName:TpvRawByteString;
      XMLProcessTag:TpvXMLProcessTag;
  begin
   if not ExpectToken('?') then begin
    Errors:=true;
    exit;
   end;
   TagName:=GetName;
   if IsEOF or Errors then begin
    Errors:=true;
    exit;
   end;
   XMLProcessTag:=TpvXMLProcessTag.Create;
   XMLProcessTag.Name:=TagName;
   ParentItem.Add(XMLProcessTag);
   ParseTagParameter(XMLProcessTag);
   if not ExpectToken('?>') then begin
    Errors:=true;
    exit;
   end;
   if XMLProcessTag.Name='xml' then begin
    EncodingName:=TpvRawByteString(UpperCase(String(XMLProcessTag.GetParameter('encoding','ascii'))));
    if EncodingName='UTF-8' then begin
     Encoding:=TEncoding.UTF8;
    end else if EncodingName='UTF-16' then begin
     Encoding:=TEncoding.UTF16;
    end else begin
     Encoding:=TEncoding.ASCII;
    end;
   end;
  end;

  procedure ParseScriptTag;
  var XMLScriptTag:TpvXMLScriptTag;
  begin
   if not ExpectToken('%') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLScriptTag:=TpvXMLScriptTag.Create;
   ParentItem.Add(XMLScriptTag);
   if not GetUntil(XMLScriptTag.Text,'%>') then begin
    Errors:=true;
   end;
  end;

  procedure ParseCommentTag;
  var XMLCommentTag:TpvXMLCommentTag;
  begin
   if not ExpectToken('--') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLCommentTag:=TpvXMLCommentTag.Create;
   ParentItem.Add(XMLCommentTag);
   if not GetUntil(XMLCommentTag.Text,'-->') then begin
    Errors:=true;
   end;
  end;

  procedure ParseCDATATag;
  var XMLCDataTag:TpvXMLCDataTag;
  begin
   if not ExpectToken('[CDATA[') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLCDataTag:=TpvXMLCDataTag.Create;
   ParentItem.Add(XMLCDataTag);
   if not GetUntil(XMLCDataTag.Text,']]>') then begin
    Errors:=true;
   end;
  end;

  procedure ParseDOCTYPEOrExtraTag;
  var Content:TpvRawByteString;
      XMLDOCTYPETag:TpvXMLDOCTYPETag;
      XMLExtraTag:TpvXMLExtraTag;
  begin
   Content:='';
   if not GetUntil(Content,'>') then begin
    Errors:=true;
    exit;
   end;
   if pos('DOCTYPE',String(Content))=1 then begin
    XMLDOCTYPETag:=TpvXMLDOCTYPETag.Create;
    ParentItem.Add(XMLDOCTYPETag);
    XMLDOCTYPETag.Text:=TpvRawByteString(TrimLeft(Copy(String(Content),8,length(String(Content))-7)));
   end else begin
    XMLExtraTag:=TpvXMLExtraTag.Create;
    ParentItem.Add(XMLExtraTag);
    XMLExtraTag.Text:=Content;
   end;
  end;

  procedure ParseTag;
  var TagName:TpvRawByteString;
      XMLTag:TpvXMLTag;
      IsAloneTag:boolean;
  begin
   if CurrentChar='/' then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     exit;
    end;
    TagName:='/'+GetName;
   end else begin
    TagName:=GetName;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;

   XMLTag:=TpvXMLTag.Create;
   XMLTag.Name:=TagName;
   ParseTagParameter(XMLTag);

   IsAloneTag:=CurrentChar='/';
   if IsAloneTag then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     exit;
    end;
   end;

   if CurrentChar<>'>' then begin
    Errors:=true;
    exit;
   end;
   NextChar;

   if (ParentItem<>Root) and (ParentItem is TpvXMLTag) and (XMLTag.Name='/'+TpvXMLTag(ParentItem).Name) then begin
    XMLTag.Free;
    FinishLevel:=true;
    Closed:=true;
   end else begin
    ParentItem.Add(XMLTag);
    if not IsAloneTag then begin
     Process(XMLTag,false);
    end;
   end;
// IsAloneTag:=false;
  end;

 begin
  FinishLevel:=false;
  while not (IsEOFOrErrors or FinishLevel) do begin
   ParseText;
   if CurrentChar='<' then begin
    NextChar;
    if not IsEOFOrErrors then begin
     if CurrentChar='/' then begin
      ParseTag;
     end else if CurrentChar='?' then begin
      ParseProcessTag;
     end else if CurrentChar='%' then begin
      ParseScriptTag;
     end else if CurrentChar='!' then begin
      NextChar;
      if not IsEOFOrErrors then begin
       if CurrentChar='-' then begin
        ParseCommentTag;
       end else if CurrentChar='[' then begin
        ParseCDATATag;
       end else begin
        ParseDOCTYPEOrExtraTag;
       end;
      end;
     end else begin
      ParseTag;
     end;
    end;
   end;
  end;
  if not Closed then begin
   Errors:=true;
  end;
 end;
begin
 Encoding:=TEncoding.ASCII;
 Errors:=false;
 CurrentChar:=#0;
 Root.Clear;
 StreamEOF:=false;
 Stream.Seek(0,soFromBeginning);
 NextChar;
 Process(Root,true);
 if Errors then begin
  Root.Clear;
 end;
 result:=not Errors;
end;

function TpvXML.Read(Stream:TStream):boolean;
var BufferedStream:TStream;
begin
 BufferedStream:=TpvSimpleBufferedStream.Create(Stream,false,4096);
 try
  result:=Parse(BufferedStream);
 finally
  BufferedStream.Free;
 end;
end;

function TpvXML.Write(Stream:TStream;IdentSize:TpvInt32=2):boolean;
var IdentLevel:TpvInt32;
    Errors:boolean;
    BufferedStream:TStream;
 procedure Process(Item:TpvXMLItem;DoIndent:boolean);
 var Line:TpvRawByteString;
     Counter:TpvInt32;
     TagWithSingleLineText,ItemsText:boolean;
  procedure WriteLineEx(Line:TpvRawByteString);
  begin
   if length(Line)>0 then begin
    if BufferedStream.Write(Line[1],length(Line))<>length(Line) then begin
     Errors:=true;
    end;
   end;
  end;
  procedure WriteLine(Line:TpvRawByteString);
  begin
   if FormatIndent and DoIndent then begin
    Line:=Line+#10;
   end;
   if length(Line)>0 then begin
    if BufferedStream.Write(Line[1],length(Line))<>length(Line) then begin
     Errors:=true;
    end;
   end;
  end;
 begin
  if not Errors then begin
   if assigned(Item) then begin
    inc(IdentLevel,IdentSize);
    Line:='';
    if FormatIndent and DoIndent then begin
     for Counter:=1 to IdentLevel do begin
      Line:=Line+' ';
     end;
    end;
    if Item is TpvXMLText then begin
     if FormatIndentText then begin
      Line:=Line+ConvertToEntities(TpvXMLText(Item).Text,IdentLevel);
     end else begin
      Line:=ConvertToEntities(TpvXMLText(Item).Text);
     end;
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLCommentTag then begin
     Line:=Line+'<!--'+TpvXMLCommentTag(Item).Text+'-->';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLProcessTag then begin
     Line:=Line+'<?'+TpvXMLProcessTag(Item).Name;
     for Counter:=0 to length(TpvXMLProcessTag(Item).Parameter)-1 do begin
      if assigned(TpvXMLProcessTag(Item).Parameter[Counter]) then begin
       Line:=Line+' '+TpvXMLProcessTag(Item).Parameter[Counter].Name+'="'+ConvertToEntities(TpvXMLProcessTag(Item).Parameter[Counter].Value)+'"';
      end;
     end;
     Line:=Line+'?>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLScriptTag then begin
     Line:=Line+'<%'+TpvXMLScriptTag(Item).Text+'%>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLCDataTag then begin
     Line:=Line+'<![CDATA['+TpvXMLCDataTag(Item).Text+']]>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLDOCTYPETag then begin
     Line:=Line+'<!DOCTYPE '+TpvXMLDOCTYPETag(Item).Text+'>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLExtraTag then begin
     Line:=Line+'<!'+TpvXMLExtraTag(Item).Text+'>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TpvXMLTag then begin
     if AutomaticAloneTagDetection then begin
      TpvXMLTag(Item).IsAloneTag:=TpvXMLTag(Item).Items.Count=0;
     end;
     Line:=Line+'<'+TpvXMLTag(Item).Name;
     for Counter:=0 to length(TpvXMLTag(Item).Parameter)-1 do begin
      if assigned(TpvXMLTag(Item).Parameter[Counter]) then begin
       Line:=Line+' '+TpvXMLTag(Item).Parameter[Counter].Name+'="'+ConvertToEntities(TpvXMLTag(Item).Parameter[Counter].Value)+'"';
      end;
     end;
     if TpvXMLTag(Item).IsAloneTag then begin
      Line:=Line+' />';
      WriteLine(Line);
     end else begin
      TagWithSingleLineText:=false;
      if Item.Items.Count=1 then begin
       if assigned(Item.Items[0]) then begin
        if Item.Items[0] is TpvXMLText then begin
         if ((Pos(#13,String(TpvXMLText(Item.Items[0]).Text))=0) and
             (Pos(#10,String(TpvXMLText(Item.Items[0]).Text))=0)) or not FormatIndentText then begin
          TagWithSingleLineText:=true;
         end;
        end;
       end;
      end;
      ItemsText:=false;
      for Counter:=0 to Item.Items.Count-1 do begin
       if assigned(Item.Items[Counter]) then begin
        if Item.Items[Counter] is TpvXMLText then begin
         ItemsText:=true;
        end;
       end;
      end;
      if TagWithSingleLineText then begin
       Line:=Line+'>'+ConvertToEntities(TpvXMLText(Item.Items[0]).Text)+'</'+TpvXMLTag(Item).Name+'>';
       WriteLine(Line);
      end else if Item.Items.Count<>0 then begin
       Line:=Line+'>';
       if assigned(Item.Items[0]) and (Item.Items[0] is TpvXMLText) and not FormatIndentText then begin
        WriteLineEx(Line);
       end else begin
        WriteLine(Line);
       end;
       for Counter:=0 to Item.Items.Count-1 do begin
        Process(Item.Items[Counter],DoIndent and ((not ItemsText) or (FormatIndent and FormatIndentText)));
       end;
       Line:='';
       if DoIndent and ((not ItemsText) or (FormatIndent and FormatIndentText)) then begin
        for Counter:=1 to IdentLevel do begin
         Line:=Line+' ';
        end;
       end;
       Line:=Line+'</'+TpvXMLTag(Item).Name+'>';
       WriteLine(Line);
      end else begin
       Line:=Line+'></'+TpvXMLTag(Item).Name+'>';
       WriteLine(Line);
      end;
     end;
    end else begin
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end;
    dec(IdentLevel,IdentSize);
   end;
  end;
 end;
begin
 IdentLevel:=-(2*IdentSize);
 if Stream is TMemoryStream then begin
  TMemoryStream(Stream).Clear;
 end;
 Errors:=false;
 BufferedStream:=TpvSimpleBufferedStream.Create(Stream,false,4096);
 try
  Process(Root,FormatIndent);
 finally
  BufferedStream.Free;
 end;
 result:=not Errors;
end;

function TpvXML.ReadXMLText:TpvRawByteString;
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Write(Stream);
  if Stream.Size>0 then begin
   SetLength(result,Stream.Size);
   Stream.Seek(0,soFromBeginning);
   Stream.Read(result[1],Stream.Size);
  end else begin
   result:='';
  end;
 finally
  Stream.Free;
 end;
end;

procedure TpvXML.WriteXMLText(Text:TpvRawByteString);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  if length(Text)>0 then begin
   Stream.Write(Text[1],length(Text));
   Stream.Seek(0,soFromBeginning);
  end;
  Parse(Stream);
 finally
  Stream.Free;
 end;
end;


procedure TpvXML.LoadFromStream(const aStream:TStream);
begin
 if not Parse(aStream) then begin
  raise EpvXML.Create('XML parsing error');
 end;
end;

procedure TpvXML.LoadFromFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvXML.SaveToStream(const aStream:TStream);
begin
 if not Write(aStream) then begin
  raise EpvXML.Create('XML writing error');
 end;
end;

procedure TpvXML.SaveToFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

initialization
 InitializeEntites;
finalization
 FinalizeEntites;
end.
