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
unit PasVulkan.Collections;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$legacyifend on}
{$endif}

{$define ExtraStringHashMap}

interface

uses SysUtils,
     Classes,
     SyncObjs,
     TypInfo,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Utils,
     Generics.Collections;

type { TpvDynamicArray }
     TpvDynamicArray<T>=record
      public
       type PT=^T;
            TItemArray=array of T;
      private
       function GetItem(const aIndex:TpvSizeInt):T; inline;
       procedure SetItem(const aIndex:TpvSizeInt;const aItem:T); inline;
      public
       Items:TItemArray;
       Count:TpvSizeInt;
       procedure Initialize;
       procedure Finalize;
       procedure Clear;
       procedure ClearNoFree;
       procedure Resize(const aCount:TpvSizeInt);
       procedure SetCount(const aCount:TpvSizeInt);
       procedure Finish;
       procedure Assign(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>); overload;
       procedure Assign(const aItems:array of T); overload;
       function AddNew:PT; overload;
       function AddNewIndex:TpvSizeInt; overload;
       function Insert(const aIndex:TpvSizeInt;const aItem:T):TpvSizeInt; overload;
       function Add(const aItem:T):TpvSizeInt; overload;
       function Add(const aItems:array of T):TpvSizeInt; overload;
       function Add(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>):TpvSizeInt; overload;
       function AddRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
       function AssignRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
       procedure Exchange(const aIndexA,aIndexB:TpvSizeInt); inline;
       procedure Delete(const aIndex:TpvSizeInt);
      public
       property DefaultItems[const aIndex:TpvSizeInt]:T read GetItem write SetItem; default;
       property ItemArray:TItemArray read Items;
     end;

     { TpvDynamicStack }

     TpvDynamicStack<T>=record
      public
       Items:array of T;
       Count:TpvSizeInt;
       procedure Initialize;
       procedure Finalize;
       procedure Clear;
       procedure Push(const aItem:T);
       function Pop(out aItem:T):boolean;
     end;

     { TpvDynamicFastStack }

     TpvDynamicFastStack<T>=record
      public
       const LocalSize=32;
       type PT=^T;
      private
       fLocalItems:array[0..LocalSize-1] of T;
       fItems:array of T;
       fCount:TpvSizeInt;
      public
       procedure Initialize;
       procedure Finalize;
       procedure Clear;
       procedure Push(const aItem:T);
       function PushIndirect:PT;
       function Pop(out aItem:T):boolean;
       function PopIndirect(out aItem:PT):boolean;
     end;

     TpvDynamicQueue<T>=record
      public
       type TQueueItems=array of T;
      public
       Items:TQueueItems;
       Head:TpvSizeInt;
       Tail:TpvSizeInt;
       Count:TpvSizeInt;
       Size:TpvSizeInt;
       procedure Initialize;
       procedure Finalize;
       procedure GrowResize(const aSize:TpvSizeInt);
       procedure Clear;
       function IsEmpty:boolean;
       procedure EnqueueAtFront(const aItem:T);
       procedure Enqueue(const aItem:T);
       function Dequeue(out aItem:T):boolean; overload;
       function Dequeue:boolean; overload;
       function Peek(out aItem:T):boolean;
     end;

     { TpvDynamicArrayList }

     TpvDynamicArrayList<T>=class
      public
       type PT=^T;
            TItemArray=array of T;
      private
       type TValueEnumerator=record
             private
              fDynamicArray:TpvDynamicArrayList<T>;
              fIndex:TpvSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aDynamicArray:TpvDynamicArrayList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:TItemArray;
       fCount:TpvSizeInt;
       fAllocated:TpvSizeInt;
       fCanShrink:Boolean;
       procedure SetCount(const aNewCount:TpvSizeInt);
       function GetItem(const aIndex:TpvSizeInt):T; inline;
       procedure SetItem(const aIndex:TpvSizeInt;const aItem:T); inline;
      protected
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure Resize(const aCount:TpvSizeInt);
       procedure Reserve(const aCount:TpvSizeInt);
       procedure Finish;
       procedure FastAssign(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>); overload;
       procedure Assign(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>); overload;
       procedure Assign(const aItems:array of T); overload;
       function AddNew:PT;
       function AddNewIndex:TpvSizeInt;
       function Add(const aItem:T):TpvSizeInt; overload;
       function Add(const pItems:TpvDynamicArrayList<T>):TpvSizeInt; overload;
       function Add(const pItems:array of T):TpvSizeInt; overload;
       function AddRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
       function AssignRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
       procedure Insert(const aIndex:TpvSizeInt;const aItem:T);
       procedure Delete(const aIndex:TpvSizeInt);
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt); inline;
       function GetEnumerator:TValueEnumerator;
       function Memory:TpvPointer; inline;
       property Count:TpvSizeInt read fCount write SetCount;
       property Allocated:TpvSizeInt read fAllocated;
       property Items[const aIndex:TpvSizeInt]:T read GetItem write SetItem; default;
       property ItemArray:TItemArray read fItems;
       property CanShrink:Boolean read fCanShrink write fCanShrink;
     end;

     TpvBaseList=class
      private
       procedure SetCount(const aNewCount:TpvSizeInt);
       function GetItem(const aIndex:TpvSizeInt):TpvPointer;
      protected
       fItemSize:TpvSizeInt;
       fCount:TpvSizeInt;
       fAllocated:TpvSizeInt;
       fMemory:TpvPointer;
       fSorted:boolean;
       procedure InitializeItem(var aItem); virtual;
       procedure FinalizeItem(var aItem); virtual;
       procedure CopyItem(const pSource;var pDestination); virtual;
       procedure ExchangeItem(var pSource,pDestination); virtual;
       function CompareItem(const pSource,pDestination):TpvInt32; virtual;
      public
       constructor Create(const aItemSize:TpvSizeInt);
       destructor Destroy; override;
       procedure Clear; virtual;
       procedure FillWith(const pSourceData;const pSourceCount:TpvSizeInt); virtual;
       function IndexOf(const aItem):TpvSizeInt; virtual;
       function Add(const aItem):TpvSizeInt; virtual;
       procedure Insert(const aIndex:TpvSizeInt;const aItem); virtual;
       procedure Delete(const aIndex:TpvSizeInt); virtual;
       procedure Remove(const aItem); virtual;
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt); virtual;
       procedure Sort; virtual;
       property Count:TpvSizeInt read fCount write SetCount;
       property Allocated:TpvSizeInt read fAllocated;
       property Memory:TpvPointer read fMemory;
       property ItemPointers[const aIndex:TpvSizeInt]:TpvPointer read GetItem; default;
       property Sorted:boolean read fSorted;
     end;

     { TpvObjectGenericList }

     TpvObjectGenericList<T:class>=class
      public
       type TItemArray=array of T;
            TValueEnumerator=record
             private
              fObjectList:TpvObjectGenericList<T>;
              fIndex:TpvSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aObjectList:TpvObjectGenericList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:TItemArray;
       fCount:TpvSizeInt;
       fAllocated:TpvSizeInt;
       fOwnsObjects:boolean;
       fGeneration:TpvUInt64;
       procedure SetCount(const aNewCount:TpvSizeInt);
       function GetItem(const aIndex:TpvSizeInt):T;
       procedure SetItem(const aIndex:TpvSizeInt;const aItem:T);
       function GetPointerToItems:pointer;
      public
       constructor Create(const aOwnsObjects:boolean=true); reintroduce;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       function Contains(const aItem:T):Boolean;
       function IndexOf(const aItem:T):TpvSizeInt;
       function Add(const aItem:T):TpvSizeInt;
       procedure Insert(const aIndex:TpvSizeInt;const aItem:T);
       procedure Delete(const aIndex:TpvSizeInt);
       function Extract(const aIndex:TpvSizeInt):T;
       function ExtractIndex(const aIndex:TpvSizeInt):T;
       procedure Remove(const aItem:T);
       procedure RemoveWithoutFree(const aItem:T);
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt);
       procedure Sort(const aCompareFunction:TpvTypedSort<T>.TpvTypedSortCompareFunction); overload;
       function GetEnumerator:TValueEnumerator;
       property Count:TpvSizeInt read fCount write SetCount;
       property Allocated:TpvSizeInt read fAllocated;
       property Items[const aIndex:TpvSizeInt]:T read GetItem write SetItem; default;
       property OwnsObjects:boolean read fOwnsObjects write fOwnsObjects;
       property PointerToItems:pointer read GetPointerToItems;
       property Generation:TpvUInt64 read fGeneration;
       property RawItems:TItemArray read fItems;
     end;

     TpvObjectList=TpvObjectGenericList<TObject>;

     { TpvGenericList }

     TpvGenericList<T>=class
      private
       type PT=^T;
            TValueEnumerator=record
             private
              fGenericList:TpvGenericList<T>;
              fIndex:TpvSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aGenericList:TpvGenericList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:array of T;
       fCount:TpvSizeInt;
       fAllocated:TpvSizeInt;
       fSorted:boolean;
       function GetData:pointer;
       procedure SetCount(const aNewCount:TpvSizeInt);
       function GetItemPointer(const aIndex:TpvSizeInt):PT;
       function GetItem(const aIndex:TpvSizeInt):T;
       procedure SetItem(const aIndex:TpvSizeInt;const aItem:T);
      protected
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; virtual;
       procedure ClearNoFree; virtual;
       procedure Assign(const aFrom:TpvGenericList<T>);
       function Contains(const aItem:T):Boolean;
       function IndexOf(const aItem:T):TpvSizeInt;
       function Add(const aItem:T):TpvSizeInt;
       procedure Insert(const aIndex:TpvSizeInt;const aItem:T);
       procedure Delete(const aIndex:TpvSizeInt);
       procedure Remove(const aItem:T);
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt);
       function GetEnumerator:TValueEnumerator;
       procedure Sort; overload;
       procedure Sort(const aCompareFunction:TpvTypedSort<T>.TpvTypedSortCompareFunction); overload;
       property Count:TpvSizeInt read fCount write SetCount;
       property Allocated:TpvSizeInt read fAllocated;
       property Items[const aIndex:TpvSizeInt]:T read GetItem write SetItem; default;
       property ItemPointers[const aIndex:TpvSizeInt]:PT read GetItemPointer;
       property Sorted:boolean read fSorted;
       property Data:pointer read GetData;
     end;

{$ifdef fpc}
     { TpvNativeComparableGenericList<T> }
     TpvNativeComparableGenericList<T>=class
      private
       type PT=^T;
            TValueEnumerator=record
             private
              fGenericList:TpvNativeComparableGenericList<T>;
              fIndex:TpvSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aGenericList:TpvNativeComparableGenericList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:array of T;
       fCount:TpvSizeInt;
       fAllocated:TpvSizeInt;
       fSorted:boolean;
       function GetData:pointer;
       procedure SetCount(const aNewCount:TpvSizeInt);
       function GetItemPointer(const aIndex:TpvSizeInt):PT;
       function GetItem(const aIndex:TpvSizeInt):T;
       procedure SetItem(const aIndex:TpvSizeInt;const aItem:T);
      protected
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure Assign(const aFrom:TpvGenericList<T>);
       function Contains(const aItem:T):Boolean;
       function IndexOf(const aItem:T):TpvSizeInt;
       function Add(const aItem:T):TpvSizeInt;
       procedure Insert(const aIndex:TpvSizeInt;const aItem:T);
       procedure Delete(const aIndex:TpvSizeInt);
       procedure Remove(const aItem:T);
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt);
       function GetEnumerator:TValueEnumerator;
       procedure Sort; overload;
       procedure Sort(const aCompareFunction:TpvNativeComparableTypedSort<T>.TpvNativeComparableTypedSortCompareFunction); overload;
       property Count:TpvSizeInt read fCount write SetCount;
       property Allocated:TpvSizeInt read fAllocated;
       property Items[const aIndex:TpvSizeInt]:T read GetItem write SetItem; default;
       property ItemPointers[const aIndex:TpvSizeInt]:PT read GetItemPointer;
       property Sorted:boolean read fSorted write fSorted;
       property Data:pointer read GetData;
     end;
{$endif}

     { EpvLinkedListObjectListError }
     EpvLinkedListObjectListError=class(Exception);

     TpvLinkedListObjectList=class;

     { TpvLinkedListObject } 
     TpvLinkedListObject=class
      private
       fOwnerList:TpvLinkedListObjectList;
       fPrevious:TpvLinkedListObject;
       fNext:TpvLinkedListObject;
      public
       constructor Create; virtual;
       destructor Destroy; override;
      public 
       property OwnerList:TpvLinkedListObjectList read fOwnerList write fOwnerList;
       property Previous:TpvLinkedListObject read fPrevious write fPrevious;
       property Next:TpvLinkedListObject read fNext write fNext;
     end;

     TpvLinkedListObjectClass=class of TpvLinkedListObject;

     { TpvLinkedListObjectList }

     TpvLinkedListObjectList=class
      private
       type TEnumerator=record
             private
              fLinkedListObjectList:TpvLinkedListObjectList;
              fCurrent:TpvLinkedListObject;
             private 
              function GetCurrent:TpvLinkedListObject; inline;
             public
              constructor Create(const aLinkedListObjectList:TpvLinkedListObjectList);
              function MoveNext:boolean; inline;
              property Current:TpvLinkedListObject read GetCurrent;
            end;
      private
       fHead:TpvLinkedListObject;
       fTail:TpvLinkedListObject;
       fCount:TpvSizeInt;
       fOwnsObjects:boolean;
      public
       constructor Create(const aOwnsObjects:boolean=true); reintroduce;
       destructor Destroy; override;
       procedure Clear;
       procedure AddToHead(const aObject:TpvLinkedListObject);
       procedure AddToTail(const aObject:TpvLinkedListObject);
       procedure Add(const aObject:TpvLinkedListObject);
       procedure Push(const aObject:TpvLinkedListObject);
       procedure MoveToHead(const aObject:TpvLinkedListObject);
       procedure MoveToTail(const aObject:TpvLinkedListObject);
       procedure InsertBefore(const aObject,aBeforeObject:TpvLinkedListObject);
       procedure InsertAfter(const aObject,aAfterObject:TpvLinkedListObject);
       function ExtractHead:TpvLinkedListObject;
       function ExtractTail:TpvLinkedListObject;
       function PopHead:TpvLinkedListObject;
       function PopTail:TpvLinkedListObject;
       function Pop:TpvLinkedListObject;
       function PeekHead:TpvLinkedListObject;
       function PeekTail:TpvLinkedListObject; 
       function Peek:TpvLinkedListObject;
       function Contains(const aObject:TpvLinkedListObject):boolean;
       procedure Remove(const aObject:TpvLinkedListObject);
       procedure Delete(const aObject:TpvLinkedListObject);
       procedure Extract(const aObject:TpvLinkedListObject);
       function GetEnumerator:TEnumerator;
      public 
       property Head:TpvLinkedListObject read fHead;
       property Tail:TpvLinkedListObject read fTail;
       property Count:TpvSizeInt read fCount;
       property OwnsObjects:boolean read fOwnsObjects write fOwnsObjects;
     end;

     { EpvHandleMap }

     EpvHandleMap=class(Exception);

     { TpvCustomHandleMap }
     TpvCustomHandleMap=class
      public
       type TpvUInt8Array=array of TpvUInt8;
            TpvUInt32Array=array of TpvUInt32;
      private
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fDataSize:TpvSizeUInt;
       fSize:TpvSizeUInt;
       fIndexCounter:TpvUInt32;
       fDenseIndex:TpvUInt32;
       fFreeIndex:TpvUInt32;
       fFreeArray:TpvUInt32Array;
{$ifdef Debug}
       fGenerationArray:TpvUInt32Array;
{$endif}
       fSparseToDenseArray:TpvUInt32Array;
       fDenseToSparseArray:TpvUInt32Array;
       fDataArray:TpvUInt8Array;
      protected
       procedure InitializeHandleData(var pData); virtual;
       procedure FinalizeHandleData(var pData); virtual;
       procedure CopyHandleData(const pSource;out pDestination); virtual;
      public
       constructor Create(const pDataSize:TpvSizeUInt); reintroduce;
       destructor Destroy; override;
       procedure Lock; inline;
       procedure Unlock; inline;
       procedure Clear;
       procedure Defragment;
       function AllocateHandle:TpvHandle;
       procedure FreeHandle(const ppvHandle:TpvHandle);
       procedure GetHandleData(const ppvHandle:TpvHandle;out pData);
       procedure SetHandleData(const ppvHandle:TpvHandle;const pData);
       function GetHandleDataPointer(const ppvHandle:TpvHandle):TpvPointer; inline;
       property DataSize:TpvSizeUInt read fDataSize;
       property Size:TpvSizeUInt read fSize;
       property IndexCounter:TpvUInt32 read fIndexCounter;
     end;

     TpvHashMapEntityIndices=array of TpvInt32;

     TpvHashMapUInt128=array[0..1] of TpvUInt64;

     { TpvHashMap<TpvHashMapKey,TpvHashMapValue> }
     TpvHashMap<TpvHashMapKey,TpvHashMapValue>=class
      public
       type TEntity=record
             public
              const Empty=0;
                    Deleted=1;
                    Used=2;
             public
              State:TpvUInt32;
              Key:TpvHashMapKey;
              Value:TpvHashMapValue;
            end;
            PEntity=^TEntity;
            TEntities=array of TEntity;
      private
       type TEntityEnumerator=record
             private
              fHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TEntity; inline;
             public
              constructor Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TEntity read GetCurrent;
            end;
            TKeyEnumerator=record
             private
              fHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TpvHashMapKey; inline;
             public
              constructor Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TpvHashMapKey read GetCurrent;
            end;
            TpvHashMapValueEnumerator=record
             private
              fHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TpvHashMapValue; inline;
             public
              constructor Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TpvHashMapValue read GetCurrent;
            end;
            TEntitiesObject=class
             private
              fOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
             public
              constructor Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function GetEnumerator:TEntityEnumerator;
            end;
            TKeysObject=class
             private
              fOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
             public
              constructor Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function GetEnumerator:TKeyEnumerator;
            end;
            TValuesObject=class
             private
              fOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>;
              function GetValue(const aKey:TpvHashMapKey):TpvHashMapValue; inline;
              procedure SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue); inline;
             public
              constructor Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
              function GetEnumerator:TpvHashMapValueEnumerator;
              property Values[const Key:TpvHashMapKey]:TpvHashMapValue read GetValue write SetValue; default;
            end;
      private
       fSize:TpvSizeUInt;
       fLogSize:TpvSizeUInt;
       fCountNonEmptyEntites:TpvSizeUInt;
       fCountDeletedEntites:TpvSizeUInt;
       fEntities:TEntities;
       fDefaultValue:TpvHashMapValue;
       fCanShrink:boolean;
       fEntitiesObject:TEntitiesObject;
       fKeysObject:TKeysObject;
       fValuesObject:TValuesObject;
       function HashData(const aData:TpvPointer;const aDataLength:TpvUInt32):TpvUInt32;
       function HashKey(const aKey:TpvHashMapKey):TpvUInt32;
       function CompareKey(const aKeyA,aKeyB:TpvHashMapKey):boolean;
       function FindEntity(const aKey:TpvHashMapKey):PEntity;
       function FindEntityForAdd(const aKey:TpvHashMapKey):PEntity;
       procedure Resize;
      protected
       function GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
       procedure SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
      public
       constructor Create(const aDefaultValue:TpvHashMapValue);
       destructor Destroy; override;
       procedure Clear(const aCanFree:Boolean=true);
       function Add(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue):PEntity;
       function Get(const aKey:TpvHashMapKey;const aCreateIfNotExist:boolean=false):PEntity;
       function TryGet(const aKey:TpvHashMapKey;out aValue:TpvHashMapValue):boolean;
       function ExistKey(const aKey:TpvHashMapKey):boolean;
       function Delete(const aKey:TpvHashMapKey):boolean;
       property EntityValues[const Key:TpvHashMapKey]:TpvHashMapValue read GetValue write SetValue; default;
       property Entities:TEntitiesObject read fEntitiesObject;
       property Keys:TKeysObject read fKeysObject;
       property Values:TValuesObject read fValuesObject;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;

{$ifdef ExtraStringHashMap}
     { TpvStringHashMap<TpvHashMapValue> }
     TpvStringHashMap<TpvHashMapValue>=class
      private
       type TpvHashMapKey=RawByteString;
            TEntity=record
             public
              const Empty=0;
                    Deleted=1;
                    Used=2;
             public
              State:TpvUInt32;
              Key:TpvHashMapKey;
              Value:TpvHashMapValue;
            end;
            PEntity=^TEntity;
            TEntities=array of TEntity;
      private
       type TEntityEnumerator=record
             private
              fHashMap:TpvStringHashMap<TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TEntity; inline;
             public
              constructor Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TEntity read GetCurrent;
            end;
            TKeyEnumerator=record
             private
              fHashMap:TpvStringHashMap<TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TpvHashMapKey; inline;
             public
              constructor Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TpvHashMapKey read GetCurrent;
            end;
            TpvHashMapValueEnumerator=record
             private
              fHashMap:TpvStringHashMap<TpvHashMapValue>;
              fIndex:TpvSizeInt;
              function GetCurrent:TpvHashMapValue; inline;
             public
              constructor Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TpvHashMapValue read GetCurrent;
            end;
            TEntitiesObject=class
             private
              fOwner:TpvStringHashMap<TpvHashMapValue>;
             public
              constructor Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
              function GetEnumerator:TEntityEnumerator;
            end;
            TKeysObject=class
             private
              fOwner:TpvStringHashMap<TpvHashMapValue>;
             public
              constructor Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
              function GetEnumerator:TKeyEnumerator;
            end;
            TValuesObject=class
             private
              fOwner:TpvStringHashMap<TpvHashMapValue>;
              function GetValue(const aKey:TpvHashMapKey):TpvHashMapValue; inline;
              procedure SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue); inline;
             public
              constructor Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
              function GetEnumerator:TpvHashMapValueEnumerator;
              property Values[const Key:TpvHashMapKey]:TpvHashMapValue read GetValue write SetValue; default;
            end;
      private
       fSize:TpvSizeUInt;
       fLogSize:TpvSizeUInt;
       fCountNonEmptyEntites:TpvSizeUInt;
       fCountDeletedEntites:TpvSizeUInt;
       fEntities:TEntities;
       fDefaultValue:TpvHashMapValue;
       fCanShrink:boolean;
       fEntitiesObject:TEntitiesObject;
       fKeysObject:TKeysObject;
       fValuesObject:TValuesObject;
       function HashKey(const aKey:TpvHashMapKey):TpvUInt32;
       function FindEntity(const aKey:TpvHashMapKey):PEntity;
       function FindEntityForAdd(const aKey:TpvHashMapKey):PEntity;
       procedure Resize;
      protected
       function GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
       procedure SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
      public
       constructor Create(const aDefaultValue:TpvHashMapValue);
       destructor Destroy; override;
       procedure Clear(const aCanFree:Boolean=true);
       function Add(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue):PEntity;
       function Get(const aKey:TpvHashMapKey;const aCreateIfNotExist:boolean=false):PEntity;
       function TryGet(const aKey:TpvHashMapKey;out aValue:TpvHashMapValue):boolean;
       function ExistKey(const aKey:TpvHashMapKey):boolean;
       function Delete(const aKey:TpvHashMapKey):boolean;
       property EntityValues[const Key:TpvHashMapKey]:TpvHashMapValue read GetValue write SetValue; default;
       property Entities:TEntitiesObject read fEntitiesObject;
       property Keys:TKeysObject read fKeysObject;
       property Values:TValuesObject read fValuesObject;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;
{$else}
     TpvStringHashMap<TpvHashMapValue>=class(TpvHashMap<RawByteString,TpvHashMapValue>);
{$endif}

     { TpvGenericSkipList<TKey,TValue> }
     TpvGenericSkipList<TKey,TValue>=class
      public
       type TPair=class
             private
              fSkipList:TpvGenericSkipList<TKey,TValue>;
              fPrevious:TPair;
              fNext:TPair;
              fKey:TKey;
              fValue:TValue;
              function GetPrevious:TPair;
              function GetNext:TPair;
             public
              constructor Create(const aSkipList:TpvGenericSkipList<TKey,TValue>;const aKey:TKey;const aValue:TValue); reintroduce;
              constructor CreateEmpty(const aSkipList:TpvGenericSkipList<TKey,TValue>); reintroduce;
              destructor Destroy; override;
              property Previous:TPair read GetPrevious;
              property Next:TPair read GetNext;
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
            end;
            TNode=class
             private
              fPrevious:TNode;
              fNext:TNode;
              fChildren:TNode;
              fPair:TPair;
             public
              constructor Create(const aPrevious:TNode=nil;
                                 const aNext:TNode=nil;
                                 const aChildren:TNode=nil;
                                 const aPair:TPair=nil); reintroduce;
              destructor Destroy; override;
             published
              property Previous:TNode read fPrevious write fPrevious;
              property Next:TNode read fNext write fNext;
              property Children:TNode read fChildren write fChildren;
              property Pair:TPair read fPair write fPair;
            end;
            TNodeArray=array of TNode;
            TRandomGeneratorState=record
             State:TpvUInt64;
             Increment:TpvUInt64;
            end;
      private
       type TValueEnumerator=record
             private
              fSkipList:TpvGenericSkipList<TKey,TValue>;
              fPair:TPair;
              function GetCurrent:TValue; inline;
             public
              constructor Create(const aSkipList:TpvGenericSkipList<TKey,TValue>);
              function MoveNext:boolean; inline;
              property Current:TValue read GetCurrent;
            end;
      private
       fRandomGeneratorState:TRandomGeneratorState;
       fDefaultValue:TValue;
       fHead:TNode;
       fPairs:TPair;
       function GetRandomValue:TpvUInt32;
       function GetFirstPair:TPair;
       function GetLastPair:TPair;
       function FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
      public
       constructor Create(const aDefaultValue:TValue); reintroduce;
       destructor Destroy; override;
       function GetNearestPair(const aKey:TKey):TPair;
       function GetNearestKey(const aKey:TKey):TKey;
       function GetNearestValue(const aKey:TKey):TValue;
       function Get(const aKey:TKey;out aValue:TValue):boolean;
       function GetPair(const aKey:TKey):TPair;
       function GetValue(const aKey:TKey):TValue;
       procedure SetValue(const aKey:TKey;const aValue:TValue);
       procedure Delete(const aKey:TKey);
       function GetEnumerator:TValueEnumerator;
       property FirstPair:TPair read GetFirstPair;
       property LastPair:TPair read GetLastPair;
       property Values[const aKey:TKey]:TValue read GetValue write SetValue; default;
     end;

     { TpvInt64SkipList<TValue> }
     TpvInt64SkipList<TValue>=class
      public
       type TKey=TpvInt64;
            TPair=class
             private
              fSkipList:TpvInt64SkipList<TValue>;
              fPrevious:TPair;
              fNext:TPair;
              fKey:TKey;
              fValue:TValue;
              function GetPrevious:TPair;
              function GetNext:TPair;
             public
              constructor Create(const aSkipList:TpvInt64SkipList<TValue>;const aKey:TKey;const aValue:TValue); reintroduce;
              constructor CreateEmpty(const aSkipList:TpvInt64SkipList<TValue>); reintroduce;
              destructor Destroy; override;
              property Previous:TPair read GetPrevious;
              property Next:TPair read GetNext;
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
            end;
            TNode=class
             private
              fPrevious:TNode;
              fNext:TNode;
              fChildren:TNode;
              fPair:TPair;
             public
              constructor Create(const aPrevious:TNode=nil;
                                 const aNext:TNode=nil;
                                 const aChildren:TNode=nil;
                                 const aPair:TPair=nil); reintroduce;
              destructor Destroy; override;
             published
              property Previous:TNode read fPrevious write fPrevious;
              property Next:TNode read fNext write fNext;
              property Children:TNode read fChildren write fChildren;
              property Pair:TPair read fPair write fPair;
            end;
            TNodeArray=array of TNode;
            TRandomGeneratorState=record
             State:TpvUInt64;
             Increment:TpvUInt64;
            end;
      private
       type TValueEnumerator=record
             private
              fSkipList:TpvInt64SkipList<TValue>;
              fPair:TPair;
              function GetCurrent:TValue; inline;
             public
              constructor Create(const aSkipList:TpvInt64SkipList<TValue>);
              function MoveNext:boolean; inline;
              property Current:TValue read GetCurrent;
            end;
      private
       fRandomGeneratorState:TRandomGeneratorState;
       fDefaultValue:TValue;
       fHead:TNode;
       fPairs:TPair;
       function GetRandomValue:TpvUInt32;
       function GetFirstPair:TPair;
       function GetLastPair:TPair;
       function FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
      public
       constructor Create(const aDefaultValue:TValue); reintroduce;
       destructor Destroy; override;
       function GetNearestPair(const aKey:TKey):TPair;
       function GetNearestKey(const aKey:TKey):TKey;
       function GetNearestValue(const aKey:TKey):TValue;
       function Get(const aKey:TKey;out aValue:TValue):boolean;
       function GetPair(const aKey:TKey):TPair;
       function GetValue(const aKey:TKey):TValue;
       procedure SetValue(const aKey:TKey;const aValue:TValue);
       procedure Delete(const aKey:TKey);
       function GetEnumerator:TValueEnumerator;
       property FirstPair:TPair read GetFirstPair;
       property LastPair:TPair read GetLastPair;
       property Values[const aKey:TKey]:TValue read GetValue write SetValue; default;
     end;

     { TpvUInt64SkipList<TValue> }
     TpvUInt64SkipList<TValue>=class
      public
       type TKey=TpvInt64;
            TPair=class
             private
              fSkipList:TpvUInt64SkipList<TValue>;
              fPrevious:TPair;
              fNext:TPair;
              fKey:TKey;
              fValue:TValue;
              function GetPrevious:TPair;
              function GetNext:TPair;
             public
              constructor Create(const aSkipList:TpvUInt64SkipList<TValue>;const aKey:TKey;const aValue:TValue); reintroduce;
              constructor CreateEmpty(const aSkipList:TpvUInt64SkipList<TValue>); reintroduce;
              destructor Destroy; override;
              property Previous:TPair read GetPrevious;
              property Next:TPair read GetNext;
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
            end;
            TNode=class
             private
              fPrevious:TNode;
              fNext:TNode;
              fChildren:TNode;
              fPair:TPair;
             public
              constructor Create(const aPrevious:TNode=nil;
                                 const aNext:TNode=nil;
                                 const aChildren:TNode=nil;
                                 const aPair:TPair=nil); reintroduce;
              destructor Destroy; override;
             published
              property Previous:TNode read fPrevious write fPrevious;
              property Next:TNode read fNext write fNext;
              property Children:TNode read fChildren write fChildren;
              property Pair:TPair read fPair write fPair;
            end;
            TNodeArray=array of TNode;
            TRandomGeneratorState=record
             State:TpvUInt64;
             Increment:TpvUInt64;
            end;
      private
       type TValueEnumerator=record
             private
              fSkipList:TpvUInt64SkipList<TValue>;
              fPair:TPair;
              function GetCurrent:TValue; inline;
             public
              constructor Create(const aSkipList:TpvUInt64SkipList<TValue>);
              function MoveNext:boolean; inline;
              property Current:TValue read GetCurrent;
            end;
      private
       fRandomGeneratorState:TRandomGeneratorState;
       fDefaultValue:TValue;
       fHead:TNode;
       fPairs:TPair;
       function GetRandomValue:TpvUInt32;
       function GetFirstPair:TPair;
       function GetLastPair:TPair;
       function FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
      public
       constructor Create(const aDefaultValue:TValue); reintroduce;
       destructor Destroy; override;
       function GetNearestPair(const aKey:TKey):TPair;
       function GetNearestKey(const aKey:TKey):TKey;
       function GetNearestValue(const aKey:TKey):TValue;
       function Get(const aKey:TKey;out aValue:TValue):boolean;
       function GetPair(const aKey:TKey):TPair;
       function GetValue(const aKey:TKey):TValue;
       procedure SetValue(const aKey:TKey;const aValue:TValue);
       procedure Delete(const aKey:TKey);
       function GetEnumerator:TValueEnumerator;
       property FirstPair:TPair read GetFirstPair;
       property LastPair:TPair read GetLastPair;
       property Values[const aKey:TKey]:TValue read GetValue write SetValue; default;
     end;

     { TpvGenericRedBlackTree<TKey,TValue> }
     TpvGenericRedBlackTree<TKey,TValue>=class
      public
       type PKey=^TKey;
            PValue=^TValue;
            { TNode }
            TNode=class
             private
              fKey:TKey;
              fValue:TValue;
              fLeft:TNode;
              fRight:TNode;
              fParent:TNode;
              fColor:boolean;
             public
              constructor Create(const aKey:TKey;
                                 const aValue:TValue;
                                 const aLeft:TNode=nil;
                                 const aRight:TNode=nil;
                                 const aParent:TNode=nil;
                                 const aColor:boolean=false);
              destructor Destroy; override;
              procedure Clear;
              function Minimum:TNode;
              function Maximum:TNode;
              function Predecessor:TNode;
              function Successor:TNode;
             public
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
              property Left:TNode read fLeft write fLeft;
              property Right:TNode read fRight write fRight;
              property Parent:TNode read fParent write fParent;
              property Color:boolean read fColor write fColor;
            end;
      private
       fRoot:TNode;
      protected
       procedure RotateLeft(x:TNode);
       procedure RotateRight(x:TNode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Find(const aKey:TKey):TNode;
       function Insert(const aKey:TKey;const aValue:TValue):TNode;
       procedure Remove(const aNode:TNode);
       procedure Delete(const aKey:TKey);
      published
       function LeftMost:TNode;
       function RightMost:TNode;
       property Root:TNode read fRoot;
     end;

     { TpvInt64RedBlackTree<TValue> }
     TpvInt64RedBlackTree<TValue>=class
      public
       type TKey=TpvInt64;
            PKey=^TKey;
            PValue=^TValue;
            { TNode }
            TNode=class
             private
              fKey:TKey;
              fValue:TValue;
              fLeft:TNode;
              fRight:TNode;
              fParent:TNode;
              fColor:boolean;
             public
              constructor Create(const aKey:TKey;
                                 const aValue:TValue;
                                 const aLeft:TNode=nil;
                                 const aRight:TNode=nil;
                                 const aParent:TNode=nil;
                                 const aColor:boolean=false);
              destructor Destroy; override;
              procedure Clear;
              function Minimum:TNode;
              function Maximum:TNode;
              function Predecessor:TNode;
              function Successor:TNode;
             public
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
              property Left:TNode read fLeft write fLeft;
              property Right:TNode read fRight write fRight;
              property Parent:TNode read fParent write fParent;
              property Color:boolean read fColor write fColor;
            end;
      private
       fRoot:TNode;
      protected
       procedure RotateLeft(x:TNode);
       procedure RotateRight(x:TNode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Find(const aKey:TKey):TNode;
       function Insert(const aKey:TKey;const aValue:TValue):TNode;
       procedure Remove(const aNode:TNode);
       procedure Delete(const aKey:TKey);
      published
       function LeftMost:TNode;
       function RightMost:TNode;
       property Root:TNode read fRoot;
     end;

     { TpvUInt64RedBlackTree<TValue> }
     TpvUInt64RedBlackTree<TValue>=class
      public
       type TKey=TpvUInt64;
            PKey=^TKey;
            PValue=^TValue;
            { TNode }
            TNode=class
             private
              fKey:TKey;
              fValue:TValue;
              fLeft:TNode;
              fRight:TNode;
              fParent:TNode;
              fColor:boolean;
             public
              constructor Create(const aKey:TKey;
                                 const aValue:TValue;
                                 const aLeft:TNode=nil;
                                 const aRight:TNode=nil;
                                 const aParent:TNode=nil;
                                 const aColor:boolean=false);
              destructor Destroy; override;
              procedure Clear;
              function Minimum:TNode;
              function Maximum:TNode;
              function Predecessor:TNode;
              function Successor:TNode;
             public
              property Key:TKey read fKey write fKey;
              property Value:TValue read fValue write fValue;
              property Left:TNode read fLeft write fLeft;
              property Right:TNode read fRight write fRight;
              property Parent:TNode read fParent write fParent;
              property Color:boolean read fColor write fColor;
            end;
      private
       fRoot:TNode;
      protected
       procedure RotateLeft(x:TNode);
       procedure RotateRight(x:TNode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Find(const aKey:TKey):TNode;
       function Insert(const aKey:TKey;const aValue:TValue):TNode;
       procedure Remove(const aNode:TNode);
       procedure Delete(const aKey:TKey);
      published
       function LeftMost:TNode;
       function RightMost:TNode;
       property Root:TNode read fRoot;
     end;

implementation

uses Generics.Defaults;

{ TpvDynamicArray<T> }

procedure TpvDynamicArray<T>.Initialize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvDynamicArray<T>.Finalize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvDynamicArray<T>.Clear;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvDynamicArray<T>.ClearNoFree;
begin
 Count:=0;
end;

procedure TpvDynamicArray<T>.Resize(const aCount:TpvSizeInt);
begin
 if Count<>aCount then begin
  Count:=aCount;
  SetLength(Items,Count);
 end;
end;

procedure TpvDynamicArray<T>.SetCount(const aCount:TpvSizeInt);
begin
 if length(Items)<aCount then begin
  SetLength(Items,aCount+((aCount+1) shr 1));
 end;
 Count:=aCount;
end;

procedure TpvDynamicArray<T>.Finish;
begin
 SetLength(Items,Count);
end;

function TpvDynamicArray<T>.GetItem(const aIndex:TpvSizeInt):T;
begin
 result:=Items[aIndex];
end;

procedure TpvDynamicArray<T>.SetItem(const aIndex:TpvSizeInt;const aItem:T);
begin
 Items[aIndex]:=aItem;
end;

procedure TpvDynamicArray<T>.Assign(const aFrom:TpvDynamicArray<T>);
begin
 Items:=copy(aFrom.Items);
 Count:=aFrom.Count;
end;

procedure TpvDynamicArray<T>.Assign(const aItems:array of T);
var Index:TpvSizeInt;
begin
 Count:=length(aItems);
 SetLength(Items,Count);
 for Index:=0 to Count-1 do begin
  Items[Index]:=aItems[Index];
 end;
end;

function TpvDynamicArray<T>.Insert(const aIndex:TpvSizeInt;const aItem:T):TpvSizeInt;
begin
 result:=aIndex;
 if aIndex>=0 then begin
  if aIndex<Count then begin
   inc(Count);
   if length(Items)<Count then begin
    SetLength(Items,Count*2);
   end;
   Move(Items[aIndex],Items[aIndex+1],(Count-(aIndex+1))*SizeOf(T));
   FillChar(Items[aIndex],SizeOf(T),#0);
  end else begin
   Count:=aIndex+1;
   if length(Items)<Count then begin
    SetLength(Items,Count*2);
   end;
  end;
  Items[aIndex]:=aItem;
 end;
end;

function TpvDynamicArray<T>.AddNew:PT;
begin
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 System.Initialize(Items[Count]);
 result:=@Items[Count];
 inc(Count);
end;

function TpvDynamicArray<T>.AddNewIndex:TpvSizeInt;
begin
 result:=Count;
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 System.Initialize(Items[Count]);
 inc(Count);
end;

function TpvDynamicArray<T>.Add(const aItem:T):TpvSizeInt;
begin
 result:=Count;
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 Items[Count]:=aItem;
 inc(Count);
end;

function TpvDynamicArray<T>.Add(const aItems:array of T):TpvSizeInt;
var Index,FromCount:TpvSizeInt;
begin
 result:=Count;
 FromCount:=length(aItems);
 if FromCount>0 then begin
  if length(Items)<(Count+FromCount) then begin
   SetLength(Items,(Count+FromCount)+((Count+FromCount) shr 1));
  end;
  for Index:=0 to FromCount-1 do begin
   Items[Count]:=aItems[Index];
   inc(Count);
  end;
 end;
end;

function TpvDynamicArray<T>.Add(const aFrom:TpvDynamicArray<T>):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=Count;
 if aFrom.Count>0 then begin
  if length(Items)<(Count+aFrom.Count) then begin
   SetLength(Items,(Count+aFrom.Count)+((Count+aFrom.Count) shr 1));
  end;
  for Index:=0 to aFrom.Count-1 do begin
   Items[Count]:=aFrom.Items[Index];
   inc(Count);
  end;
 end;
end;

function TpvDynamicArray<T>.AddRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=Count;
 if aCount>0 then begin
  if length(Items)<(Count+aCount) then begin
   SetLength(Items,(Count+aCount)+((Count+aCount) shr 1));
  end;
  for Index:=0 to aCount-1 do begin
   Items[Count]:=aFrom.Items[aStartIndex+Index];
   inc(Count);
  end;
 end;
end;

function TpvDynamicArray<T>.AssignRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
begin
 Clear;
 result:=AddRangeFrom(aFrom,aStartIndex,aCount);
end;

procedure TpvDynamicArray<T>.Exchange(const aIndexA,aIndexB:TpvSizeInt);
var Temp:T;
begin
 Temp:=Items[aIndexA];
 Items[aIndexA]:=Items[aIndexB];
 Items[aIndexB]:=Temp;
end;

procedure TpvDynamicArray<T>.Delete(const aIndex:TpvSizeInt);
begin
 if (Count>0) and (aIndex<Count) then begin
  dec(Count);
  System.Finalize(Items[aIndex]);
  Move(Items[aIndex+1],Items[aIndex],SizeOf(T)*(Count-aIndex));
  FillChar(Items[Count],SizeOf(T),#0);
 end;
end;

{ TpvDynamicStack<T> }

procedure TpvDynamicStack<T>.Initialize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvDynamicStack<T>.Finalize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvDynamicStack<T>.Clear;
begin
 Count:=0;
end;

procedure TpvDynamicStack<T>.Push(const aItem:T);
begin
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 Items[Count]:=aItem;
 inc(Count);
end;

function TpvDynamicStack<T>.Pop(out aItem:T):boolean;
begin
 result:=Count>0;
 if result then begin
  dec(Count);
  aItem:=Items[Count];
 end;
end;

{ TpvDynamicFastStack<T> }

procedure TpvDynamicFastStack<T>.Initialize;
begin
 System.Initialize(fLocalItems);
 fItems:=nil;
 fCount:=0;
end;

procedure TpvDynamicFastStack<T>.Finalize;
begin
 System.Finalize(fLocalItems);
 fItems:=nil;
 fCount:=0;
end;

procedure TpvDynamicFastStack<T>.Clear;
begin
 fCount:=0;
end;

procedure TpvDynamicFastStack<T>.Push(const aItem:T);
var Index,ThresholdedCount:TpvSizeInt;
begin
 Index:=fCount;
 inc(fCount);
 if Index<=High(fLocalItems) then begin
  fLocalItems[Index]:=aItem;
 end else begin
  ThresholdedCount:=fCount-Length(fLocalItems);
  if length(fItems)<ThresholdedCount then begin
   SetLength(fItems,ThresholdedCount+((ThresholdedCount+1) shr 1));
  end;
  fItems[Index-Length(fLocalItems)]:=aItem;
 end;
end;

function TpvDynamicFastStack<T>.PushIndirect:PT;
var Index,ThresholdedCount:TpvSizeInt;
begin
 Index:=fCount;
 inc(fCount);
 if Index<=High(fLocalItems) then begin
  result:=@fLocalItems[Index];
 end else begin
  ThresholdedCount:=fCount-Length(fLocalItems);
  if length(fItems)<ThresholdedCount then begin
   SetLength(fItems,ThresholdedCount+((ThresholdedCount+1) shr 1));
  end;
  result:=@fItems[Index-Length(fLocalItems)];
 end;
end;

function TpvDynamicFastStack<T>.Pop(out aItem:T):boolean;
begin
 result:=fCount>0;
 if result then begin
  dec(fCount);
  if fCount<=High(fLocalItems) then begin
   aItem:=fLocalItems[fCount];
  end else begin
   aItem:=fItems[fCount-Length(fLocalItems)];
  end;
 end;
end;

function TpvDynamicFastStack<T>.PopIndirect(out aItem:PT):boolean;
begin
 result:=fCount>0;
 if result then begin
  dec(fCount);
  if fCount<=High(fLocalItems) then begin
   aItem:=@fLocalItems[fCount];
  end else begin
   aItem:=@fItems[fCount-Length(fLocalItems)];
  end;
 end else begin
  aItem:=nil;
 end;
end;

{ TpvDynamicQueue<T> }

procedure TpvDynamicQueue<T>.Initialize;
begin
 Items:=nil;
 Head:=0;
 Tail:=0;
 Count:=0;
 Size:=0;
end;

procedure TpvDynamicQueue<T>.Finalize;
begin
 Clear;
end;

procedure TpvDynamicQueue<T>.GrowResize(const aSize:TpvSizeInt);
var Index,OtherIndex:TpvSizeInt;
    NewItems:TQueueItems;
begin
 SetLength(NewItems,aSize);
 OtherIndex:=Head;
 for Index:=0 to Count-1 do begin
  NewItems[Index]:=Items[OtherIndex];
  inc(OtherIndex);
  if OtherIndex>=Size then begin
   OtherIndex:=0;
  end;
 end;
 Items:=NewItems;
 Head:=0;
 Tail:=Count;
 Size:=aSize;
end;

procedure TpvDynamicQueue<T>.Clear;
begin
 while Count>0 do begin
  dec(Count);
  System.Finalize(Items[Head]);
  inc(Head);
  if Head>=Size then begin
   Head:=0;
  end;
 end;
 Items:=nil;
 Head:=0;
 Tail:=0;
 Count:=0;
 Size:=0;
end;

function TpvDynamicQueue<T>.IsEmpty:boolean;
begin
 result:=Count=0;
end;

procedure TpvDynamicQueue<T>.EnqueueAtFront(const aItem:T);
var Index:TpvSizeInt;
begin
 if Size<=Count then begin
  GrowResize(Count+1);
 end;
 dec(Head);
 if Head<0 then begin
  inc(Head,Size);
 end;
 Index:=Head;
 Items[Index]:=aItem;
 inc(Count);
end;

procedure TpvDynamicQueue<T>.Enqueue(const aItem:T);
var Index:TpvSizeInt;
begin
 if Size<=Count then begin
  GrowResize(Count+1);
 end;
 Index:=Tail;
 inc(Tail);
 if Tail>=Size then begin
  Tail:=0;
 end;
 Items[Index]:=aItem;
 inc(Count);
end;

function TpvDynamicQueue<T>.Dequeue(out aItem:T):boolean;
begin
 result:=Count>0;
 if result then begin
  dec(Count);
  aItem:=Items[Head];
  System.Finalize(Items[Head]);
  FillChar(Items[Head],SizeOf(T),#0);
  if Count=0 then begin
   Head:=0;
   Tail:=0;
  end else begin
   inc(Head);
   if Head>=Size then begin
    Head:=0;
   end;
  end;
 end;
end;

function TpvDynamicQueue<T>.Dequeue:boolean;
begin
 result:=Count>0;
 if result then begin
  dec(Count);
  System.Finalize(Items[Head]);
  FillChar(Items[Head],SizeOf(T),#0);
  if Count=0 then begin
   Head:=0;
   Tail:=0;
  end else begin
   inc(Head);
   if Head>=Size then begin
    Head:=0;
   end;
  end;
 end;
end;

function TpvDynamicQueue<T>.Peek(out aItem:T):boolean;
begin
 result:=Count>0;
 if result then begin
  aItem:=Items[Head];
 end;
end;

constructor TpvDynamicArrayList<T>.TValueEnumerator.Create(const aDynamicArray:TpvDynamicArrayList<T>);
begin
 fDynamicArray:=aDynamicArray;
 fIndex:=-1;
end;

function TpvDynamicArrayList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fDynamicArray.fCount;
end;

function TpvDynamicArrayList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fDynamicArray.fItems[fIndex];
end;

constructor TpvDynamicArrayList<T>.Create;
begin
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fCanShrink:=true;
 inherited Create;
end;

destructor TpvDynamicArrayList<T>.Destroy;
begin
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
 inherited Destroy;
end;

procedure TpvDynamicArrayList<T>.Clear;
begin
 if fCanShrink then begin
  SetLength(fItems,0);
  fAllocated:=0;
 end;
 fCount:=0;
end;

procedure TpvDynamicArrayList<T>.ClearNoFree;
begin
 fCount:=0;
end;

procedure TpvDynamicArrayList<T>.SetCount(const aNewCount:TpvSizeInt);
begin
 if aNewCount<=0 then begin
  if fCanShrink then begin
   SetLength(fItems,0);
   fAllocated:=0;
  end;
  fCount:=0;
 end else begin
  if aNewCount<fCount then begin
   fCount:=aNewCount;
   if fCanShrink and ((fCount+fCount)<fAllocated) then begin
    fAllocated:=fCount+fCount;
    SetLength(fItems,fAllocated);
   end;
  end else begin
   fCount:=aNewCount;
   if fAllocated<fCount then begin
    fAllocated:=fCount+fCount;
    SetLength(fItems,fAllocated);
   end;
  end;
 end;
end;

procedure TpvDynamicArrayList<T>.Resize(const aCount:TpvSizeInt);
begin
 SetCount(aCount);
end;

procedure TpvDynamicArrayList<T>.Reserve(const aCount:TpvSizeInt);
var NewAllocated:TpvSizeInt;
begin
 NewAllocated:=RoundUpToPowerOfTwoSizeUInt(aCount);
 if fAllocated<NewAllocated then begin
  fAllocated:=NewAllocated;
  SetLength(fItems,fAllocated);
 end;
end;

procedure TpvDynamicArrayList<T>.Finish;
begin
 fAllocated:=fCount;
 if length(fItems)<>fAllocated then begin
  SetLength(fItems,fAllocated);
 end;
end;

function TpvDynamicArrayList<T>.GetItem(const aIndex:TpvSizeInt):T;
begin
 result:=fItems[aIndex];
end;

procedure TpvDynamicArrayList<T>.SetItem(const aIndex:TpvSizeInt;const aItem:T);
begin
 fItems[aIndex]:=aItem;
end;

procedure TpvDynamicArrayList<T>.FastAssign(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>);
var Index:TpvSizeInt;
begin
 fCount:=aFrom.fCount;
 if fAllocated<fCount then begin
  fAllocated:=fCount;
  SetLength(fItems,fCount);
 end;
 if fCount>0 then begin
  Move(aFrom.fItems[0],fItems[0],fCount*SizeOf(T));
 end;
end;

procedure TpvDynamicArrayList<T>.Assign(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>);
var Index:TpvSizeInt;
begin
 fCount:=aFrom.fCount;
 if fAllocated<fCount then begin
  fAllocated:=fCount;
  SetLength(fItems,fCount);
 end;
 for Index:=0 to fCount-1 do begin
  fItems[Index]:=aFrom.fItems[Index];
 end;
end;

procedure TpvDynamicArrayList<T>.Assign(const aItems:array of T);
var Index:TpvSizeInt;
begin
 fCount:=length(aItems);
 fAllocated:=fCount;
 SetLength(fItems,fCount);
 for Index:=0 to fCount-1 do begin
  fItems[Index]:=aItems[Index];
 end;
end;

function TpvDynamicArrayList<T>.AddNew:PT;
begin
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
 result:=@fItems[fCount-1];
end;

function TpvDynamicArrayList<T>.AddNewIndex:TpvSizeInt;
begin
 result:=fCount;
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
end;

function TpvDynamicArrayList<T>.Add(const aItem:T):TpvSizeInt;
begin
 result:=fCount;
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
 fItems[result]:=aItem;
end;

function TpvDynamicArrayList<T>.Add(const pItems:TpvDynamicArrayList<T>):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=fCount;
 if pItems.Count>0 then begin
  inc(fCount,pItems.Count);
  if fAllocated<fCount then begin
   fAllocated:=fCount+fCount;
   SetLength(fItems,fAllocated);
  end;
  for Index:=0 to pItems.Count-1 do begin
   fItems[result+Index]:=pItems.fItems[Index];
  end;
 end;
end;

function TpvDynamicArrayList<T>.Add(const pItems:array of T):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=fCount;
 if length(pItems)>0 then begin
  inc(fCount,length(pItems));
  if fAllocated<fCount then begin
   fAllocated:=fCount+fCount;
   SetLength(fItems,fAllocated);
  end;
  for Index:=0 to length(pItems)-1 do begin
   fItems[result+Index]:=pItems[Index];
  end;
 end;
end;

function TpvDynamicArrayList<T>.AddRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=fCount;
 if aCount>0 then begin
  SetCount(fCount+aCount);
  for Index:=0 to aCount-1 do begin
   fItems[result+Index]:=aFrom.fItems[aStartIndex+Index];
  end;
 end;
end;

function TpvDynamicArrayList<T>.AssignRangeFrom(const aFrom:{$ifdef fpc}{$endif}TpvDynamicArrayList<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
begin
 Clear;
 result:=AddRangeFrom(aFrom,aStartIndex,aCount);
end;

procedure TpvDynamicArrayList<T>.Insert(const aIndex:TpvSizeInt;const aItem:T);
begin
 if aIndex>=0 then begin
  if aIndex<fCount then begin
   inc(fCount);
   if fCount<fAllocated then begin
    fAllocated:=fCount shl 1;
    SetLength(fItems,fAllocated);
   end;
   Move(fItems[aIndex],fItems[aIndex+1],(fCount-aIndex)*SizeOf(T));
   FillChar(fItems[aIndex],SizeOf(T),#0);
  end else begin
   fCount:=aIndex+1;
   if fCount<fAllocated then begin
    fAllocated:=fCount shl 1;
    SetLength(fItems,fAllocated);
   end;
  end;
  fItems[aIndex]:=aItem;
 end;
end;

procedure TpvDynamicArrayList<T>.Delete(const aIndex:TpvSizeInt);
begin
 Finalize(fItems[aIndex]);
 Move(fItems[aIndex+1],fItems[aIndex],(fCount-aIndex)*SizeOf(T));
 dec(fCount);
 FillChar(fItems[fCount],SizeOf(T),#0);
 if fCanShrink and (fCount<(fAllocated shr 1)) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
end;

procedure TpvDynamicArrayList<T>.Exchange(const aIndex,aWithIndex:TpvSizeInt);
var Temporary:T;
begin
 Temporary:=fItems[aIndex];
 fItems[aIndex]:=fItems[aWithIndex];
 fItems[aWithIndex]:=Temporary;
end;

function TpvDynamicArrayList<T>.Memory:TpvPointer;
begin
 result:=@fItems[0];
end;

function TpvDynamicArrayList<T>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

constructor TpvBaseList.Create(const aItemSize:TpvSizeInt);
begin
 inherited Create;
 fItemSize:=aItemSize;
 fCount:=0;
 fAllocated:=0;
 fMemory:=nil;
 fSorted:=false;
end;

destructor TpvBaseList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvBaseList.SetCount(const aNewCount:TpvSizeInt);
var Index,NewAllocated:TpvSizeInt;
    Item:TpvPointer;
begin
 if fCount<aNewCount then begin
  NewAllocated:=RoundUpToPowerOfTwoSizeUInt(aNewCount);
  if fAllocated<NewAllocated then begin
   if assigned(fMemory) then begin
    ReallocMem(fMemory,NewAllocated*fItemSize);
   end else begin
    GetMem(fMemory,NewAllocated*fItemSize);
   end;
   FillChar(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(fAllocated)*TpvPtrUInt(fItemSize))))^,(NewAllocated-fAllocated)*fItemSize,#0);
   fAllocated:=NewAllocated;
  end;
  Item:=fMemory;
  Index:=fCount;
  inc(TpvPtrUInt(Item),Index*fItemSize);
  while Index<aNewCount do begin
   FillChar(Item^,fItemSize,#0);
   InitializeItem(Item^);
   inc(TpvPtrUInt(Item),fItemSize);
   inc(Index);
  end;
  fCount:=aNewCount;
 end else if fCount>aNewCount then begin
  Item:=fMemory;
  Index:=aNewCount;
  inc(TpvPtrUInt(Item),Index*fItemSize);
  while Index<fCount do begin
   FinalizeItem(Item^);
   FillChar(Item^,fItemSize,#0);
   inc(TpvPtrUInt(Item),fItemSize);
   inc(Index);
  end;
  fCount:=aNewCount;
  if aNewCount<(fAllocated shr 2) then begin
   if aNewCount=0 then begin
    if assigned(fMemory) then begin
     FreeMem(fMemory);
     fMemory:=nil;
    end;
    fAllocated:=0;
   end else begin
    NewAllocated:=fAllocated shr 1;
    if assigned(fMemory) then begin
     ReallocMem(fMemory,NewAllocated*fItemSize);
    end else begin
     GetMem(fMemory,NewAllocated*fItemSize);
    end;
    fAllocated:=NewAllocated;
   end;
  end;
 end;
 fSorted:=false;
end;

function TpvBaseList.GetItem(const aIndex:TpvSizeInt):TpvPointer;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))));
 end else begin
  result:=nil;
 end;
end;

procedure TpvBaseList.InitializeItem(var aItem);
begin
end;

procedure TpvBaseList.FinalizeItem(var aItem);
begin
end;

procedure TpvBaseList.CopyItem(const pSource;var pDestination);
begin
 Move(pSource,pDestination,fItemSize);
end;

procedure TpvBaseList.ExchangeItem(var pSource,pDestination);
var a,b:PpvUInt8;
    c8:TpvUInt8;
    c32:TpvUInt32;
    Index:TpvInt32;
begin
 a:=@pSource;
 b:=@pDestination;
 for Index:=1 to fItemSize shr 2 do begin
  c32:=PpvUInt32(a)^;
  PpvUInt32(a)^:=PpvUInt32(b)^;
  PpvUInt32(b)^:=c32;
  inc(PpvUInt32(a));
  inc(PpvUInt32(b));
 end;
 for Index:=1 to fItemSize and 3 do begin
  c8:=a^;
  a^:=b^;
  b^:=c8;
  inc(a);
  inc(b);
 end;
end;

function TpvBaseList.CompareItem(const pSource,pDestination):TpvInt32;
var a,b:PpvUInt8;
    Index:TpvInt32;
begin
 result:=0;
 a:=@pSource;
 b:=@pDestination;
 for Index:=1 to fItemSize do begin
  result:=a^-b^;
  if result<>0 then begin
   exit;
  end;
  inc(a);
  inc(b);
 end;
end;

procedure TpvBaseList.Clear;
var Index:TpvSizeInt;
    Item:TpvPointer;
begin
 Item:=fMemory;
 Index:=0;
 while Index<fCount do begin
  FinalizeItem(Item^);
  inc(TpvPtrInt(Item),fItemSize);
  inc(Index);
 end;
 if assigned(fMemory) then begin
  FreeMem(fMemory);
  fMemory:=nil;
 end;
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
end;

procedure TpvBaseList.FillWith(const pSourceData;const pSourceCount:TpvSizeInt);
var Index:TpvSizeInt;
    SourceItem,Item:TpvPointer;
begin
 SourceItem:=@pSourceData;
 if assigned(SourceItem) and (pSourceCount>0) then begin
  SetCount(pSourceCount);
  Item:=fMemory;
  Index:=0;
  while Index<fCount do begin
   CopyItem(SourceItem^,Item^);
   inc(TpvPtrInt(SourceItem),fItemSize);
   inc(TpvPtrInt(Item),fItemSize);
   inc(Index);
  end;
 end else begin
  SetCount(0);
 end;
 fSorted:=false;
end;

function TpvBaseList.IndexOf(const aItem):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
begin
 result:=-1;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   Difference:=CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Index)*TpvPtrUInt(fItemSize))))^,aItem);
   if Difference=0 then begin
    result:=Index;
    exit;
   end else if Difference<0 then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  Index:=0;
  while Index<fCount do begin
   if CompareItem(aItem,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Index)*TpvPtrUInt(fItemSize))))^)=0 then begin
    result:=Index;
    break;
   end;
   inc(Index);
  end;
 end;
end;

function TpvBaseList.Add(const aItem):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
begin
 if fSorted and (fCount>0) then begin
  if CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(fCount-1)*TpvPtrUInt(fItemSize))))^,aItem)<0 then begin
   result:=fCount;
  end else if CompareItem(aItem,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(0)*TpvPtrUInt(fItemSize))))^)<0 then begin
   result:=0;
  end else begin
   LowerIndexBound:=0;
   UpperIndexBound:=fCount-1;
   while LowerIndexBound<=UpperIndexBound do begin
    Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
    Difference:=CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Index)*TpvPtrUInt(fItemSize))))^,aItem);
    if Difference=0 then begin
     LowerIndexBound:=Index;
     break;
    end else if Difference<0 then begin
     LowerIndexBound:=Index+1;
    end else begin
     UpperIndexBound:=Index-1;
    end;
   end;
   result:=LowerIndexBound;
  end;
  if result>=0 then begin
   Insert(result,aItem);
   fSorted:=true;
  end;
 end else begin
  result:=fCount;
  SetCount(result+1);
  CopyItem(aItem,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(result)*TpvPtrUInt(fItemSize))))^);
  fSorted:=false;
 end;
end;

procedure TpvBaseList.Insert(const aIndex:TpvSizeInt;const aItem);
begin
 if aIndex>=0 then begin
  if aIndex<fCount then begin
   SetCount(fCount+1);
   Move(TpvPointer(TpvPtrInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex+1)*TpvPtrUInt(fItemSize))))^,(fCount-(aIndex+1))*fItemSize);
   FillChar(TpvPointer(TpvPtrInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^,fItemSize,#0);
  end else begin
   SetCount(aIndex+1);
  end;
  CopyItem(aItem,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^);
 end;
 fSorted:=false;
end;

procedure TpvBaseList.Delete(const aIndex:TpvSizeInt);
var OldSorted:boolean;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  OldSorted:=fSorted;
  FinalizeItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^);
  Move(TpvPointer(TpvPtrUInt(TpvPtruInt(fMemory)+(TpvPtrUInt(aIndex+1)*TpvPtrUInt(fItemSize))))^,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^,(fCount-aIndex)*fItemSize);
  FillChar(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(fCount-1)*TpvPtrUInt(fItemSize))))^,fItemSize,#0);
  SetCount(fCount-1);
  fSorted:=OldSorted;
 end;
end;

procedure TpvBaseList.Remove(const aItem);
var Index:TpvSizeInt;
begin
 repeat
  Index:=IndexOf(aItem);
  if Index>=0 then begin
   Delete(Index);
  end else begin
   break;
  end;
 until false;
end;

procedure TpvBaseList.Exchange(const aIndex,aWithIndex:TpvSizeInt);
begin
 if (aIndex>=0) and (aIndex<fCount) and (aWithIndex>=0) and (aWithIndex<fCount) then begin
  ExchangeItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aIndex)*TpvPtrUInt(fItemSize))))^,TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(aWithIndex)*TpvPtrUInt(fItemSize))))^);
  fSorted:=false;
 end;
end;

procedure TpvBaseList.Sort;
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TpvUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if not fSorted then begin
  if fCount>1 then begin
   StackItem:=@Stack[0];
   StackItem^.Left:=0;
   StackItem^.Right:=fCount-1;
   StackItem^.Depth:=IntLog2(fCount) shl 1;
   inc(StackItem);
   while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
    dec(StackItem);
    Left:=StackItem^.Left;
    Right:=StackItem^.Right;
    Depth:=StackItem^.Depth;
    Size:=(Right-Left)+1;
    if Size<16 then begin
     // Insertion sort
     iA:=Left;
     iB:=iA+1;
     while iB<=Right do begin
      iC:=iB;
      while (iA>=Left) and
            (iC>=Left) and
            (CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(iA)*TpvPtrUInt(fItemSize))))^,
                         TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(iC)*TpvPtrUInt(fItemSize))))^)>0) do begin
       Exchange(iA,iC);
       dec(iA);
       dec(iC);
      end;
      iA:=iB;
      inc(iB);
     end;
    end else begin
     if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
      // Heap sort
      i:=Size div 2;
      repeat
       if i>0 then begin
        dec(i);
       end else begin
        dec(Size);
        if Size>0 then begin
         Exchange(Left+Size,Left);
        end else begin
         break;
        end;
       end;
       Parent:=i;
       repeat
        Child:=(Parent*2)+1;
        if Child<Size then begin
         if (Child<(Size-1)) and (CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left+Child)*TpvPtrUInt(fItemSize))))^,
                                              TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left+Child+1)*TpvPtrUInt(fItemSize))))^)<0) then begin
          inc(Child);
         end;
         if CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left+Parent)*TpvPtrUInt(fItemSize))))^,
                        TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left+Child)*TpvPtrUInt(fItemSize))))^)<0 then begin
          Exchange(Left+Parent,Left+Child);
          Parent:=Child;
          continue;
         end;
        end;
        break;
       until false;
      until false;
     end else begin
      // Quick sort width median-of-three optimization
      Middle:=Left+((Right-Left) shr 1);
      if (Right-Left)>3 then begin
       if CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left)*TpvPtrUInt(fItemSize))))^,
                      TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Middle)*TpvPtrUInt(fItemSize))))^)>0 then begin
        Exchange(Left,Middle);
       end;
       if CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Left)*TpvPtrUInt(fItemSize))))^,
                      TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Right)*TpvPtrUInt(fItemSize))))^)>0 then begin
        Exchange(Left,Right);
       end;
       if CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Middle)*TpvPtrUInt(fItemSize))))^,
                      TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Right)*TpvPtrUInt(fItemSize))))^)>0 then begin
        Exchange(Middle,Right);
       end;
      end;
      Pivot:=Middle;
      i:=Left;
      j:=Right;
      repeat
       while (i<Right) and (CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(i)*TpvPtrUInt(fItemSize))))^,
                                        TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Pivot)*TpvPtrUInt(fItemSize))))^)<0) do begin
        inc(i);
       end;
       while (j>=i) and (CompareItem(TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(j)*TpvPtrUInt(fItemSize))))^,
                                     TpvPointer(TpvPtrUInt(TpvPtrUInt(fMemory)+(TpvPtrUInt(Pivot)*TpvPtrUInt(fItemSize))))^)>0) do begin
        dec(j);
       end;
       if i>j then begin
        break;
       end else begin
        if i<>j then begin
         Exchange(i,j);
         if Pivot=i then begin
          Pivot:=j;
         end else if Pivot=j then begin
          Pivot:=i;
         end;
        end;
        inc(i);
        dec(j);
       end;
      until false;
      if i<Right then begin
       StackItem^.Left:=i;
       StackItem^.Right:=Right;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
      if Left<j then begin
       StackItem^.Left:=Left;
       StackItem^.Right:=j;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
     end;
    end;
   end;
  end;
  fSorted:=true;
 end;
end;

constructor TpvObjectGenericList<T>.TValueEnumerator.Create(const aObjectList:TpvObjectGenericList<T>);
begin
 fObjectList:=aObjectList;
 fIndex:=-1;
end;

function TpvObjectGenericList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fObjectList.fCount;
end;

function TpvObjectGenericList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fObjectList.fItems[fIndex];
end;

constructor TpvObjectGenericList<T>.Create(const aOwnsObjects:boolean);
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fOwnsObjects:=aOwnsObjects;
 fGeneration:=0;
end;

destructor TpvObjectGenericList<T>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvObjectGenericList<T>.Clear;
var Index:TpvSizeInt;
begin
 if fOwnsObjects then begin
  for Index:=fCount-1 downto 0 do begin
   FreeAndNil(fItems[Index]);
  end;
 end;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 inc(fGeneration);
end;

procedure TpvObjectGenericList<T>.ClearNoFree;
var Index:TpvSizeInt;
begin
 if fOwnsObjects then begin
  for Index:=fCount-1 downto 0 do begin
   FreeAndNil(fItems[Index]);
  end;
 end;
 fCount:=0;
 inc(fGeneration);
end;

procedure TpvObjectGenericList<T>.SetCount(const aNewCount:TpvSizeInt);
var Index,NewAllocated:TpvSizeInt;
    Item:TpvPointer;
begin
 if fCount<aNewCount then begin
  NewAllocated:=RoundUpToPowerOfTwoSizeUInt(aNewCount);
  if fAllocated<NewAllocated then begin
   SetLength(fItems,NewAllocated);
   FillChar(fItems[fAllocated],(NewAllocated-fAllocated)*SizeOf(T),#0);
   fAllocated:=NewAllocated;
  end;
  FillChar(fItems[fCount],(aNewCount-fCount)*SizeOf(T),#0);
  fCount:=aNewCount;
  inc(fGeneration);
 end else if fCount>aNewCount then begin
  if fOwnsObjects then begin
   for Index:=fCount-1 downto aNewCount do begin
    FreeAndNil(fItems[Index]);
   end;
  end;
  fCount:=aNewCount;
  if aNewCount<(fAllocated shr 2) then begin
   if aNewCount=0 then begin
    fItems:=nil;
    fAllocated:=0;
   end else begin
    NewAllocated:=fAllocated shr 1;
    SetLength(fItems,NewAllocated);
    fAllocated:=NewAllocated;
   end;
  end;
  inc(fGeneration);
 end;
end;

function TpvObjectGenericList<T>.GetItem(const aIndex:TpvSizeInt):T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=fItems[aIndex];
end;

procedure TpvObjectGenericList<T>.SetItem(const aIndex:TpvSizeInt;const aItem:T);
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 fItems[aIndex]:=aItem;
 inc(fGeneration);
end;

function TpvObjectGenericList<T>.GetPointerToItems:pointer;
begin
 result:=@fItems[0];
end;

function TpvObjectGenericList<T>.Contains(const aItem:T):Boolean;
var Index:TpvInt32;
begin
 for Index:=0 to fCount-1 do begin
  if fItems[Index]=aItem then begin
   result:=true;
   exit;
  end;
 end;
 result:=false;
end;

function TpvObjectGenericList<T>.IndexOf(const aItem:T):TpvSizeInt;
var Index:TpvInt32;
begin
 for Index:=0 to fCount-1 do begin
  if fItems[Index]=aItem then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TpvObjectGenericList<T>.Add(const aItem:T):TpvSizeInt;
begin
 result:=fCount;
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
 fItems[result]:=aItem;
 inc(fGeneration);
end;

procedure TpvObjectGenericList<T>.Insert(const aIndex:TpvSizeInt;const aItem:T);
var OldCount:TpvSizeInt;
begin
 if aIndex>=0 then begin
  OldCount:=fCount;
  if fCount<aIndex then begin
   fCount:=aIndex+1;
  end else begin
   inc(fCount);
  end;
  if fAllocated<fCount then begin
   fAllocated:=fCount shl 1;
   SetLength(fItems,fAllocated);
  end;
  if OldCount<fCount then begin
   FillChar(fItems[OldCount],(fCount-OldCount)*SizeOf(T),#0);
  end;
  if aIndex<OldCount then begin
   System.Move(Pointer(@fItems[aIndex])^,Pointer(@fItems[aIndex+1])^,(OldCount-aIndex)*SizeOf(T));
   FillChar(fItems[aIndex],SizeOf(T),#0);
  end;
  fItems[aIndex]:=aItem;
  inc(fGeneration);
 end;
end;

procedure TpvObjectGenericList<T>.Delete(const aIndex:TpvSizeInt);
var Old:T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Old:=fItems[aIndex];
 dec(fCount);
 FillChar(fItems[aIndex],SizeOf(T),#0);
 if aIndex<>fCount then begin
  System.Move(Pointer(@fItems[aIndex+1])^,Pointer(@fItems[aIndex])^,(fCount-aIndex)*SizeOf(T));
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
 if fOwnsObjects then begin
  FreeAndNil(Old);
 end;
 inc(fGeneration);
end;

function TpvObjectGenericList<T>.Extract(const aIndex:TpvSizeInt):T;
var Old:T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Old:=fItems[aIndex];
 dec(fCount);
 FillChar(fItems[aIndex],SizeOf(T),#0);
 if aIndex<>fCount then begin
  System.Move(Pointer(@fItems[aIndex+1])^,Pointer(@fItems[aIndex])^,(fCount-aIndex)*SizeOf(T));
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
 inc(fGeneration);
 result:=Old;
end;

function TpvObjectGenericList<T>.ExtractIndex(const aIndex:TpvSizeInt):T;
var Old:T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Old:=fItems[aIndex];
 dec(fCount);
 FillChar(fItems[aIndex],SizeOf(T),#0);
 if aIndex<>fCount then begin
  System.Move(Pointer(@fItems[aIndex+1])^,Pointer(@fItems[aIndex])^,(fCount-aIndex)*SizeOf(T));
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
 inc(fGeneration);
 result:=Old;
end;

procedure TpvObjectGenericList<T>.Remove(const aItem:T);
var Index:TpvSizeInt;
begin
 Index:=IndexOf(aItem);
 if Index>=0 then begin
  Delete(Index);
 end;
end;

procedure TpvObjectGenericList<T>.RemoveWithoutFree(const aItem:T);
var Index:TpvSizeInt;
begin
 Index:=IndexOf(aItem);
 if Index>=0 then begin
  ExtractIndex(Index);
 end;
end;

procedure TpvObjectGenericList<T>.Exchange(const aIndex,aWithIndex:TpvSizeInt);
var Temporary:T;
begin
 if ((aIndex<0) or (aIndex>=fCount)) or ((aWithIndex<0) or (aWithIndex>=fCount)) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Temporary:=fItems[aIndex];
 fItems[aIndex]:=fItems[aWithIndex];
 fItems[aWithIndex]:=Temporary;
 inc(fGeneration);
end;

function TpvObjectGenericList<T>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

procedure TpvObjectGenericList<T>.Sort(const aCompareFunction:TpvTypedSort<T>.TpvTypedSortCompareFunction);
begin
 if fCount>1 then begin
  TpvTypedSort<T>.IntroSort(@fItems[0],0,fCount-1,aCompareFunction);
 end;
end;

constructor TpvGenericList<T>.TValueEnumerator.Create(const aGenericList:TpvGenericList<T>);
begin
 fGenericList:=aGenericList;
 fIndex:=-1;
end;

function TpvGenericList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fGenericList.fCount;
end;

function TpvGenericList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fGenericList.fItems[fIndex];
end;

constructor TpvGenericList<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
end;

destructor TpvGenericList<T>.Destroy;
begin
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
 inherited Destroy;
end;

procedure TpvGenericList<T>.Clear;
begin
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
end;

procedure TpvGenericList<T>.ClearNoFree;
begin
 fCount:=0;
 fSorted:=false;
end;

function TpvGenericList<T>.GetData:pointer;
begin
 result:=@fItems[0];
end;

procedure TpvGenericList<T>.SetCount(const aNewCount:TpvSizeInt);
var Index,NewAllocated:TpvSizeInt;
    Item:TpvPointer;
begin
 if fCount<aNewCount then begin
  NewAllocated:=RoundUpToPowerOfTwoSizeUInt(aNewCount);
  if fAllocated<NewAllocated then begin
   SetLength(fItems,NewAllocated);
   FillChar(fItems[fAllocated],(NewAllocated-fAllocated)*SizeOf(T),#0);
   fAllocated:=NewAllocated;
  end;
  for Index:=fCount to aNewCount-1 do begin
   FillChar(fItems[Index],SizeOf(T),#0);
   Initialize(fItems[Index]);
  end;
  fCount:=aNewCount;
 end else if fCount>aNewCount then begin
  for Index:=aNewCount to fCount-1 do begin
   Finalize(fItems[Index]);
   FillChar(fItems[Index],SizeOf(T),#0);
  end;
  fCount:=aNewCount;
  if aNewCount<(fAllocated shr 2) then begin
   if aNewCount=0 then begin
    fItems:=nil;
    fAllocated:=0;
   end else begin
    NewAllocated:=fAllocated shr 1;
    SetLength(fItems,NewAllocated);
    fAllocated:=NewAllocated;
   end;
  end;
 end;
 fSorted:=false;
end;

function TpvGenericList<T>.GetItemPointer(const aIndex:TpvSizeInt):PT;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=@fItems[aIndex];
end;

function TpvGenericList<T>.GetItem(const aIndex:TpvSizeInt):T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=fItems[aIndex];
end;

procedure TpvGenericList<T>.SetItem(const aIndex:TpvSizeInt;const aItem:T);
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 fItems[aIndex]:=aItem;
end;

procedure TpvGenericList<T>.Assign(const aFrom:TpvGenericList<T>);
begin
 fItems:=aFrom.fItems;
 fCount:=aFrom.Count;
 fAllocated:=aFrom.fAllocated;
 fSorted:=aFrom.fSorted;
end;

function TpvGenericList<T>.Contains(const aItem:T):Boolean;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
    Comparer:IComparer<T>;
begin
 Comparer:=TComparer<T>.Default;
 result:=false;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   Difference:=Comparer.Compare(fItems[Index],aItem);
   if Difference=0 then begin
    result:=true;
    exit;
   end else if Difference<0 then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if Comparer.Compare(fItems[Index],aItem)=0 then begin
    result:=true;
    exit;
   end;
  end;
 end;
end;

function TpvGenericList<T>.IndexOf(const aItem:T):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
    Comparer:IComparer<T>;
begin
 Comparer:=TComparer<T>.Default;
 result:=-1;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   Difference:=Comparer.Compare(fItems[Index],aItem);
   if Difference=0 then begin
    result:=Index;
    exit;
   end else if Difference<0 then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if Comparer.Compare(fItems[Index],aItem)=0 then begin
    result:=Index;
    exit;
   end;
  end;
 end;
end;

function TpvGenericList<T>.Add(const aItem:T):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
    Comparer:IComparer<T>;
begin
 Comparer:=TComparer<T>.Default;
 if fSorted and (fCount>0) then begin
  if Comparer.Compare(fItems[fCount-1],aItem)<0 then begin
   result:=fCount;
  end else if Comparer.Compare(aItem,fItems[0])<0 then begin
   result:=0;
  end else begin
   LowerIndexBound:=0;
   UpperIndexBound:=fCount-1;
   while LowerIndexBound<=UpperIndexBound do begin
    Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
    Difference:=Comparer.Compare(fItems[Index],aItem);
    if Difference=0 then begin
     LowerIndexBound:=Index;
     break;
    end else if Difference<0 then begin
     LowerIndexBound:=Index+1;
    end else begin
     UpperIndexBound:=Index-1;
    end;
   end;
   result:=LowerIndexBound;
  end;
  if result>=0 then begin
   if result<fCount then begin
    inc(fCount);
    if length(fItems)<fCount then begin
     SetLength(fItems,fCount*2);
    end;
    Move(fItems[result],fItems[result+1],(fCount-(result+1))*SizeOf(T));
    FillChar(fItems[result],SizeOf(T),#0);
   end else begin
    fCount:=result+1;
    if length(fItems)<fCount then begin
     SetLength(fItems,fCount*2);
    end;
   end;
   fItems[result]:=aItem;
  end;
 end else begin
  result:=fCount;
  inc(fCount);
  if fAllocated<fCount then begin
   fAllocated:=fCount+fCount;
   SetLength(fItems,fAllocated);
  end;
  fItems[result]:=aItem;
 end;
end;

procedure TpvGenericList<T>.Insert(const aIndex:TpvSizeInt;const aItem:T);
var OldCount:TpvSizeInt;
begin
 if aIndex>=0 then begin
  OldCount:=fCount;
  if fCount<aIndex then begin
   fCount:=aIndex+1;
  end else begin
   inc(fCount);
  end;
  if fAllocated<fCount then begin
   fAllocated:=fCount shl 1;
   SetLength(fItems,fAllocated);
  end;
  if OldCount<fCount then begin
   FillChar(fItems[OldCount],(fCount-OldCount)*SizeOf(T),#0);
  end;
  if aIndex<OldCount then begin
   System.Move(Pointer(@fItems[aIndex])^,Pointer(@fItems[aIndex+1])^,(OldCount-aIndex)*SizeOf(T));
   FillChar(fItems[aIndex],SizeOf(T),#0);
  end;
  fItems[aIndex]:=aItem;
 end;
 fSorted:=false;
end;

procedure TpvGenericList<T>.Delete(const aIndex:TpvSizeInt);
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Finalize(fItems[aIndex]);
 dec(fCount);
 FillChar(fItems[aIndex],SizeOf(T),#0);
 if aIndex<>fCount then begin
  System.Move(Pointer(@fItems[aIndex+1])^,Pointer(@fItems[aIndex])^,(fCount-aIndex)*SizeOf(T));
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
end;

procedure TpvGenericList<T>.Remove(const aItem:T);
var Index:TpvSizeInt;
begin
 Index:=IndexOf(aItem);
 if Index>=0 then begin
  Delete(Index);
 end;
end;

procedure TpvGenericList<T>.Exchange(const aIndex,aWithIndex:TpvSizeInt);
var Temporary:T;
begin
 if ((aIndex<0) or (aIndex>=fCount)) or ((aWithIndex<0) or (aWithIndex>=fCount)) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Temporary:=fItems[aIndex];
 fItems[aIndex]:=fItems[aWithIndex];
 fItems[aWithIndex]:=Temporary;
 fSorted:=false;
end;

function TpvGenericList<T>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

procedure TpvGenericList<T>.Sort;
begin
 if not fSorted then begin
  if fCount>1 then begin
   TpvTypedSort<T>.IntroSort(@fItems[0],0,fCount-1);
  end;
  fSorted:=true;
 end;
end;

procedure TpvGenericList<T>.Sort(const aCompareFunction:TpvTypedSort<T>.TpvTypedSortCompareFunction);
begin
 if not fSorted then begin
  if fCount>1 then begin
   TpvTypedSort<T>.IntroSort(@fItems[0],0,fCount-1,aCompareFunction);
  end;
  fSorted:=true;
 end;
end;

{$ifdef fpc}
constructor TpvNativeComparableGenericList<T>.TValueEnumerator.Create(const aGenericList:TpvNativeComparableGenericList<T>);
begin
 fGenericList:=aGenericList;
 fIndex:=-1;
end;

function TpvNativeComparableGenericList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fGenericList.fItems[fIndex];
end;

function TpvNativeComparableGenericList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fGenericList.fCount;
end;

constructor TpvNativeComparableGenericList<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
end;

destructor TpvNativeComparableGenericList<T>.Destroy;
begin
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
 inherited Destroy;
end;

procedure TpvNativeComparableGenericList<T>.Clear;
begin
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
 fSorted:=false;
end;

procedure TpvNativeComparableGenericList<T>.ClearNoFree;
begin
 fCount:=0;
 fSorted:=false;
end;

function TpvNativeComparableGenericList<T>.GetData:pointer;
begin
 result:=@fItems[0];
end;

procedure TpvNativeComparableGenericList<T>.SetCount(const aNewCount:TpvSizeInt);
var Index,NewAllocated:TpvSizeInt;
    Item:TpvPointer;
begin
 if fCount<aNewCount then begin
  NewAllocated:=RoundUpToPowerOfTwoSizeUInt(aNewCount);
  if fAllocated<NewAllocated then begin
   SetLength(fItems,NewAllocated);
   FillChar(fItems[fAllocated],(NewAllocated-fAllocated)*SizeOf(T),#0);
   fAllocated:=NewAllocated;
  end;
  for Index:=fCount to aNewCount-1 do begin
   FillChar(fItems[Index],SizeOf(T),#0);
   Initialize(fItems[Index]);
  end;
  fCount:=aNewCount;
 end else if fCount>aNewCount then begin
  for Index:=aNewCount to fCount-1 do begin
   Finalize(fItems[Index]);
   FillChar(fItems[Index],SizeOf(T),#0);
  end;
  fCount:=aNewCount;
  if aNewCount<(fAllocated shr 2) then begin
   if aNewCount=0 then begin
    fItems:=nil;
    fAllocated:=0;
   end else begin
    NewAllocated:=fAllocated shr 1;
    SetLength(fItems,NewAllocated);
    fAllocated:=NewAllocated;
   end;
  end;
 end;
 fSorted:=false;
end;

function TpvNativeComparableGenericList<T>.GetItemPointer(const aIndex:TpvSizeInt):TpvNativeComparableGenericList<T>.PT;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=@fItems[aIndex];
end;

function TpvNativeComparableGenericList<T>.GetItem(const aIndex:TpvSizeInt):T;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=fItems[aIndex];
end;

procedure TpvNativeComparableGenericList<T>.SetItem(const aIndex:TpvSizeInt;const aItem:T);
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 fItems[aIndex]:=aItem;
end;

procedure TpvNativeComparableGenericList<T>.Assign(const aFrom:TpvGenericList<T>);
begin
 fItems:=aFrom.fItems;
 fCount:=aFrom.Count;
 fAllocated:=aFrom.fAllocated;
 fSorted:=aFrom.fSorted;
end;

function TpvNativeComparableGenericList<T>.Contains(const aItem:T):Boolean;
var Index,LowerIndexBound,UpperIndexBound:TpvInt32;
begin
 result:=false;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   if fItems[Index]=aItem then begin
    result:=true;
    exit;
   end else if fItems[Index]<aItem then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if fItems[Index]=aItem then begin
    result:=true;
    exit;
   end;
  end;
 end;
end;

function TpvNativeComparableGenericList<T>.IndexOf(const aItem:T):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound:TpvInt32;
begin
 result:=-1;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   if fItems[Index]=aItem then begin
    result:=Index;
    exit;
   end else if fItems[Index]<aItem then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if fItems[Index]=aItem then begin
    result:=Index;
    exit;
   end;
  end;
 end;
end;

function TpvNativeComparableGenericList<T>.Add(const aItem:T):TpvSizeInt;
var Index,LowerIndexBound,UpperIndexBound:TpvInt32;
begin
 if fSorted and (fCount>0) then begin
  if fItems[fCount-1]<aItem then begin
   result:=fCount;
  end else if aItem<fItems[0] then begin
   result:=0;
  end else begin
   LowerIndexBound:=0;
   UpperIndexBound:=fCount-1;
   while LowerIndexBound<=UpperIndexBound do begin
    Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
    if fItems[Index]=aItem then begin
     LowerIndexBound:=Index;
     break;
    end else if fItems[Index]<aItem then begin
     LowerIndexBound:=Index+1;
    end else begin
     UpperIndexBound:=Index-1;
    end;
   end;
   result:=LowerIndexBound;
  end;
  if result>=0 then begin
   if result<fCount then begin
    inc(fCount);
    if length(fItems)<fCount then begin
     SetLength(fItems,fCount*2);
    end;
    Move(fItems[result],fItems[result+1],(fCount-(result+1))*SizeOf(T));
    FillChar(fItems[result],SizeOf(T),#0);
   end else begin
    fCount:=result+1;
    if length(fItems)<fCount then begin
     SetLength(fItems,fCount*2);
    end;
   end;
   fItems[result]:=aItem;
  end;
 end else begin
  result:=fCount;
  inc(fCount);
  if fAllocated<fCount then begin
   fAllocated:=fCount+fCount;
   SetLength(fItems,fAllocated);
  end;
  fItems[result]:=aItem;
 end;
end;

procedure TpvNativeComparableGenericList<T>.Insert(const aIndex:TpvSizeInt;const aItem:T);
var OldCount:TpvSizeInt;
begin
 if aIndex>=0 then begin
  OldCount:=fCount;
  if fCount<aIndex then begin
   fCount:=aIndex+1;
  end else begin
   inc(fCount);
  end;
  if fAllocated<fCount then begin
   fAllocated:=fCount shl 1;
   SetLength(fItems,fAllocated);
  end;
  if OldCount<fCount then begin
   FillChar(fItems[OldCount],(fCount-OldCount)*SizeOf(T),#0);
  end;
  if aIndex<OldCount then begin
   System.Move(Pointer(@fItems[aIndex])^,Pointer(@fItems[aIndex+1])^,(OldCount-aIndex)*SizeOf(T));
   FillChar(fItems[aIndex],SizeOf(T),#0);
  end;
  fItems[aIndex]:=aItem;
 end;
 fSorted:=false;
end;

procedure TpvNativeComparableGenericList<T>.Delete(const aIndex:TpvSizeInt);
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Finalize(fItems[aIndex]);
 dec(fCount);
 FillChar(fItems[aIndex],SizeOf(T),#0);
 if aIndex<>fCount then begin
  System.Move(Pointer(@fItems[aIndex+1])^,Pointer(@fItems[aIndex])^,(fCount-aIndex)*SizeOf(T));
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
end;

procedure TpvNativeComparableGenericList<T>.Remove(const aItem:T);
var Index:TpvSizeInt;
begin
 Index:=IndexOf(aItem);
 if Index>=0 then begin
  Delete(Index);
 end;
end;

procedure TpvNativeComparableGenericList<T>.Exchange(const aIndex,aWithIndex:TpvSizeInt);
var Temporary:T;
begin
 if ((aIndex<0) or (aIndex>=fCount)) or ((aWithIndex<0) or (aWithIndex>=fCount)) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Temporary:=fItems[aIndex];
 fItems[aIndex]:=fItems[aWithIndex];
 fItems[aWithIndex]:=Temporary;
 fSorted:=false;
end;

function TpvNativeComparableGenericList<T>.GetEnumerator:TpvNativeComparableGenericList<T>.TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

procedure TpvNativeComparableGenericList<T>.Sort;
begin
 if not fSorted then begin
  if fCount>1 then begin
   TpvNativeComparableTypedSort<T>.IntroSort(@fItems[0],0,fCount-1);
  end;
  fSorted:=true;
 end;
end;

procedure TpvNativeComparableGenericList<T>.Sort(const aCompareFunction:TpvNativeComparableTypedSort<T>.TpvNativeComparableTypedSortCompareFunction);
begin
 if not fSorted then begin
  if fCount>1 then begin
   TpvNativeComparableTypedSort<T>.IntroSort(@fItems[0],0,fCount-1,aCompareFunction);
  end;
  fSorted:=true;
 end;
end;
{$endif}

{ TpvLinkedListObject }

constructor TpvLinkedListObject.Create;
begin
 inherited Create;
 fOwnerList:=nil;
 fPrevious:=nil;
 fNext:=nil;
end;

destructor TpvLinkedListObject.Destroy;
begin
 if assigned(fOwnerList) then begin
  try
   fOwnerList.Extract(self);
  finally
   fOwnerList:=nil;
  end; 
 end;
 inherited Destroy;
end;

{ TpvLinkedListObjectList.TEnumerator }

constructor TpvLinkedListObjectList.TEnumerator.Create(const aLinkedListObjectList:TpvLinkedListObjectList);
begin
 fLinkedListObjectList:=aLinkedListObjectList;
 fCurrent:=nil;
end;

function TpvLinkedListObjectList.TEnumerator.GetCurrent:TpvLinkedListObject;
begin
 result:=fCurrent;
end;

function TpvLinkedListObjectList.TEnumerator.MoveNext:boolean;
begin
 if not assigned(fCurrent) then begin
  fCurrent:=fLinkedListObjectList.fHead;
 end else begin
  fCurrent:=fCurrent.fNext;
 end;
 result:=assigned(fCurrent);
end;

{ TpvLinkedListObjectList }

constructor TpvLinkedListObjectList.Create(const aOwnsObjects:boolean);
begin
 inherited Create;
 fHead:=nil;
 fTail:=nil;
 fCount:=0;
 fOwnsObjects:=aOwnsObjects;
end;

destructor TpvLinkedListObjectList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvLinkedListObjectList.Clear;
var Current,Next:TpvLinkedListObject;
begin
 Current:=fHead;
 while assigned(Current) do begin
  Next:=Current.fNext;
  Current.fOwnerList:=nil; // Set to nil to avoid recursive calls to Extract in destructor
  if fOwnsObjects then begin
   Current.Free;
  end;
  Current:=Next;
 end;
 fHead:=nil;
 fTail:=nil;
 fCount:=0;
end;

procedure TpvLinkedListObjectList.AddToHead(const aObject:TpvLinkedListObject);
begin
 if assigned(aObject.fOwnerList) then begin
  raise EpvLinkedListObjectListError.Create('Object already belongs to a linked list');
 end else begin
  aObject.fOwnerList:=self;
  aObject.fPrevious:=nil;
  aObject.fNext:=fHead;
  if assigned(fHead) then begin
   fHead.fPrevious:=aObject;
  end;
  fHead:=aObject;
  if not assigned(fTail) then begin
   fTail:=aObject;
  end;
  inc(fCount);
 end; 
end;

procedure TpvLinkedListObjectList.AddToTail(const aObject:TpvLinkedListObject);
begin
 if assigned(aObject.fOwnerList) then begin
  raise EpvLinkedListObjectListError.Create('Object already belongs to a linked list');
 end else begin
  aObject.fOwnerList:=self;
  aObject.fNext:=nil;
  aObject.fPrevious:=fTail;
  if assigned(fTail) then begin
   fTail.fNext:=aObject;
  end;
  fTail:=aObject;
  if not assigned(fHead) then begin
   fHead:=aObject;
  end;
  inc(fCount);
 end; 
end;

procedure TpvLinkedListObjectList.Add(const aObject:TpvLinkedListObject);
begin
 AddToTail(aObject);
end;

procedure TpvLinkedListObjectList.Push(const aObject:TpvLinkedListObject);
begin
 AddToTail(aObject);
end;

procedure TpvLinkedListObjectList.MoveToHead(const aObject:TpvLinkedListObject);
begin
 if aObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Object does not belong to this linked list');
 end else if aObject<>fHead then begin
  // Remove from current position
  if assigned(aObject.fPrevious) then begin
   aObject.fPrevious.fNext:=aObject.fNext;
  end;
  if assigned(aObject.fNext) then begin
   aObject.fNext.fPrevious:=aObject.fPrevious;
  end;
  if aObject=fTail then begin
   fTail:=aObject.fPrevious;
  end;
  // Insert at head
  aObject.fPrevious:=nil;
  aObject.fNext:=fHead;
  if assigned(fHead) then begin
   fHead.fPrevious:=aObject;
  end;
  fHead:=aObject;
  if not assigned(fTail) then begin
   fTail:=aObject;
  end;
 end;
end;

procedure TpvLinkedListObjectList.MoveToTail(const aObject:TpvLinkedListObject);
begin
 if aObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Object does not belong to this linked list');
 end else if aObject<>fTail then begin
  // Remove from current position
  if assigned(aObject.fPrevious) then begin
   aObject.fPrevious.fNext:=aObject.fNext;
  end;
  if assigned(aObject.fNext) then begin
   aObject.fNext.fPrevious:=aObject.fPrevious;
  end;
  if aObject=fHead then begin
   fHead:=aObject.fNext;
  end;
  // Insert at tail
  aObject.fNext:=nil;
  aObject.fPrevious:=fTail;
  if assigned(fTail) then begin
   fTail.fNext:=aObject;
  end;
  fTail:=aObject;
  if not assigned(fHead) then begin
   fHead:=aObject;
  end;
 end;
end; 

procedure TpvLinkedListObjectList.InsertBefore(const aObject,aBeforeObject:TpvLinkedListObject);
begin
 if assigned(aObject.fOwnerList) then begin
  raise EpvLinkedListObjectListError.Create('Object already belongs to a linked list');
 end else if aBeforeObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Before object does not belong to this linked list');
 end else begin
  aObject.fOwnerList:=self;
  aObject.fNext:=aBeforeObject;
  aObject.fPrevious:=aBeforeObject.fPrevious;
  if assigned(aBeforeObject.fPrevious) then begin
   aBeforeObject.fPrevious.fNext:=aObject;
  end else begin
   fHead:=aObject;
  end;
  aBeforeObject.fPrevious:=aObject;
  inc(fCount);
 end; 
end;

procedure TpvLinkedListObjectList.InsertAfter(const aObject,aAfterObject:TpvLinkedListObject);
begin
 if assigned(aObject.fOwnerList) then begin
  raise EpvLinkedListObjectListError.Create('Object already belongs to a linked list');
 end else if aAfterObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('After object does not belong to this linked list');
 end else begin
  aObject.fOwnerList:=self;
  aObject.fPrevious:=aAfterObject;
  aObject.fNext:=aAfterObject.fNext;
  if assigned(aAfterObject.fNext) then begin
   aAfterObject.fNext.fPrevious:=aObject;
  end else begin
   fTail:=aObject;
  end;
  aAfterObject.fNext:=aObject;
  inc(fCount);
 end; 
end;

function TpvLinkedListObjectList.ExtractHead:TpvLinkedListObject;
begin
 result:=fHead;
 if assigned(result) then begin
  result.fOwnerList:=nil;
  fHead:=result.fNext;
  if assigned(fHead) then begin
   fHead.fPrevious:=nil;
  end else begin
   fTail:=nil;
  end;
  result.fPrevious:=nil;
  result.fNext:=nil;
  dec(fCount);
 end;
end;

function TpvLinkedListObjectList.ExtractTail:TpvLinkedListObject;
begin
 result:=fTail;
 if assigned(result) then begin
  result.fOwnerList:=nil;
  fTail:=result.fPrevious;
  if assigned(fTail) then begin
   fTail.fNext:=nil;
  end else begin
   fHead:=nil;
  end;
  result.fPrevious:=nil;
  result.fNext:=nil;
  dec(fCount);
 end;
end;

function TpvLinkedListObjectList.PopHead:TpvLinkedListObject;
begin
 result:=ExtractHead;
end;

function TpvLinkedListObjectList.PopTail:TpvLinkedListObject;
begin
 result:=ExtractTail;
end;

function TpvLinkedListObjectList.Pop:TpvLinkedListObject;
begin
 result:=ExtractTail;
end;

function TpvLinkedListObjectList.PeekHead:TpvLinkedListObject;
begin
 result:=fHead;
end;

function TpvLinkedListObjectList.PeekTail:TpvLinkedListObject;
begin
 result:=fTail;
end;

function TpvLinkedListObjectList.Peek:TpvLinkedListObject;
begin
 result:=fTail;
end;

function TpvLinkedListObjectList.Contains(const aObject:TpvLinkedListObject):boolean;
begin
 result:=assigned(aObject.fOwnerList) and (aObject.fOwnerList=self); // Faster than traversing the list
end;

procedure TpvLinkedListObjectList.Remove(const aObject:TpvLinkedListObject);
begin
 if aObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Object does not belong to this linked list');
 end else begin
  // Remove from current position
  if assigned(aObject.fPrevious) then begin
   aObject.fPrevious.fNext:=aObject.fNext;
  end else begin
   fHead:=aObject.fNext;
  end;
  if assigned(aObject.fNext) then begin
   aObject.fNext.fPrevious:=aObject.fPrevious;
  end else begin
   fTail:=aObject.fPrevious;
  end;
  aObject.fOwnerList:=nil;
  aObject.fPrevious:=nil;
  aObject.fNext:=nil;
  dec(fCount);
  if fOwnsObjects then begin
   aObject.Free;
  end;
 end; 
end;

procedure TpvLinkedListObjectList.Delete(const aObject:TpvLinkedListObject);
begin
 if aObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Object does not belong to this linked list');
 end else begin
  // Remove from current position
  if assigned(aObject.fPrevious) then begin
   aObject.fPrevious.fNext:=aObject.fNext;
  end else begin
   fHead:=aObject.fNext;
  end;
  if assigned(aObject.fNext) then begin
   aObject.fNext.fPrevious:=aObject.fPrevious;
  end else begin
   fTail:=aObject.fPrevious;
  end;
  aObject.fOwnerList:=nil;
  aObject.fPrevious:=nil;
  aObject.fNext:=nil;
  dec(fCount);
  if fOwnsObjects then begin
   aObject.Free;
  end;
 end; 
end;

procedure TpvLinkedListObjectList.Extract(const aObject:TpvLinkedListObject);
begin
 if aObject.fOwnerList<>self then begin
  raise EpvLinkedListObjectListError.Create('Object does not belong to this linked list');
 end else begin
  // Remove from current position
  if assigned(aObject.fPrevious) then begin
   aObject.fPrevious.fNext:=aObject.fNext;
  end else begin
   fHead:=aObject.fNext;
  end;
  if assigned(aObject.fNext) then begin
   aObject.fNext.fPrevious:=aObject.fPrevious;
  end else begin
   fTail:=aObject.fPrevious;
  end;
  aObject.fOwnerList:=nil;
  aObject.fPrevious:=nil;
  aObject.fNext:=nil;
  dec(fCount);
 end; 
end;

function TpvLinkedListObjectList.GetEnumerator:TpvLinkedListObjectList.TEnumerator;
begin
 result:=TEnumerator.Create(self);
end;

{ TpvCustomHandleMap }
constructor TpvCustomHandleMap.Create(const pDataSize:TpvSizeUInt);
begin
 inherited Create;
 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fDataSize:=pDataSize;
 fSize:=0;
 fIndexCounter:=0;
 fDenseIndex:=0;
 fFreeIndex:=0;
 fFreeArray:=nil;
{$ifdef Debug}
 fGenerationArray:=nil;
{$endif}
 fSparseToDenseArray:=nil;
 fDenseToSparseArray:=nil;
 fDataArray:=nil;
end;

destructor TpvCustomHandleMap.Destroy;
begin
 Clear;
 fMultipleReaderSingleWriterLock.Free;
 inherited Destroy;
end;

procedure TpvCustomHandleMap.Lock;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
end;

procedure TpvCustomHandleMap.Unlock;
begin
 fMultipleReaderSingleWriterLock.ReleaseWrite;
end;

procedure TpvCustomHandleMap.Clear;
var Index:TpvSizeUInt;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  Index:=0;
  while Index<fSize do begin
   FinalizeHandleData(TpvPointer(@fDataArray[Index*TpvSizeUInt(fDataSize)])^);
   inc(Index);
  end;
  fSize:=0;
  fIndexCounter:=0;
  fDenseIndex:=0;
  fFreeIndex:=0;
  fFreeArray:=nil;
{$ifdef Debug}
  fGenerationArray:=nil;
{$endif}
  fSparseToDenseArray:=nil;
  fDenseToSparseArray:=nil;
  fDataArray:=nil;
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

procedure TpvCustomHandleMap.InitializeHandleData(var pData);
begin
end;

procedure TpvCustomHandleMap.FinalizeHandleData(var pData);
begin
 FillChar(pData,fDataSize,#$00);
end;

procedure TpvCustomHandleMap.CopyHandleData(const pSource;out pDestination);
begin
 Move(pSource,pDestination,fDataSize);
end;

procedure TpvCustomHandleMap.Defragment;
begin

end;

function TpvCustomHandleMap.AllocateHandle:TpvHandle;
var OldSize,NewSize:TpvSizeUInt;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  if fFreeIndex>0 then begin
   dec(fFreeIndex);
   result.Index:=fFreeArray[fFreeIndex];
{$ifdef Debug}
   result.Generation:=fGenerationArray[result.Index] and $7fffffff;
{$endif}
  end else begin
   result.Index:=TPasMPInterlocked.Increment(fIndexCounter);
   result.Generation:=0;
   NewSize:=TpvSizeUInt(result.Index)+1;
{$ifdef Debug}
   begin
    OldSize:=length(fGenerationArray);
    if OldSize<NewSize then begin
     SetLength(fGenerationArray,NewSize*2);
     FillChar(fGenerationArray[OldSize],TpvSizeUInt(NewSize-OldSize)*TpvSizeUInt(SizeOf(TpvUInt32)),#$ff);
    end;
   end;
{$endif}
   begin
    OldSize:=fSize;
    if OldSize<NewSize then begin
     fSize:=NewSize*2;
     SetLength(fSparseToDenseArray,fSize);
     SetLength(fDenseToSparseArray,fSize);
     SetLength(fDataArray,fSize*fDataSize);
     FillChar(fSparseToDenseArray[OldSize],TpvSizeUInt(NewSize-OldSize)*TpvSizeUInt(SizeOf(TpvUInt32)),#$ff);
     FillChar(fDenseToSparseArray[OldSize],TpvSizeUInt(NewSize-OldSize)*TpvSizeUInt(SizeOf(TpvUInt32)),#$ff);
     FillChar(fDataArray[OldSize*fDataSize],TpvSizeUInt(NewSize-OldSize)*TpvSizeUInt(fDataSize),#$00);
    end;
   end;
  end;
{$ifdef Debug}
  fGenerationArray[result.Index]:=result.Generation;
{$endif}
  fSparseToDenseArray[result.Index]:=fDenseIndex;
  fDenseToSparseArray[fDenseIndex]:=result.Index;
  InitializeHandleData(TpvPointer(@fDataArray[fDenseIndex*TpvSizeUInt(fDataSize)])^);
  inc(fDenseIndex);
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

procedure TpvCustomHandleMap.FreeHandle(const ppvHandle:TpvHandle);
var DenseIndex:TpvUInt32;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
{$ifdef Debug}
  if (ppvHandle.Index<TpvInt64(length(fGenerationArray))) and
     (ppvHandle.Generation=fGenerationArray[ppvHandle.Index]) then begin
   fGenerationArray[ppvHandle.Index]:=(fGenerationArray[ppvHandle.Index]+1) or $80000000;
{$endif}
   if TpvSizeUInt(length(fFreeArray))<=TpvSizeUInt(fFreeIndex) then begin
    SetLength(fFreeArray,(TpvSizeUInt(fFreeIndex)+1)*2);
   end;
   fFreeArray[fFreeIndex]:=ppvHandle.Index;
   inc(fFreeIndex);
   dec(fDenseIndex);
   DenseIndex:=fSparseToDenseArray[ppvHandle.Index];
   if fDenseIndex<>DenseIndex then begin
    Move(fDataArray[fDenseIndex*TpvSizeUInt(fDataSize)],fDataArray[DenseIndex*TpvSizeUInt(fDataSize)],fDataSize);
   end;
   FinalizeHandleData(TpvPointer(@fDataArray[fDenseIndex*TpvSizeUInt(fDataSize)])^);
   fSparseToDenseArray[fDenseToSparseArray[DenseIndex]]:=DenseIndex;
{$ifdef Debug}
  end else begin
   raise EpvHandleMap.Create('Freeing non-used or already-freed handle');
  end;
{$endif}
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

procedure TpvCustomHandleMap.GetHandleData(const ppvHandle:TpvHandle;out pData);
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
{$ifdef Debug}
  if (ppvHandle.Index<TpvInt64(length(fGenerationArray))) and
     (ppvHandle.Generation=fGenerationArray[ppvHandle.Index]) then begin
{$endif}
   CopyHandleData(fDataArray[fSparseToDenseArray[ppvHandle.Index]*TpvSizeUInt(fDataSize)],pData);
{$ifdef Debug}
  end else begin
   raise EpvHandleMap.Create('Accessing non-used or already-freed handle');
  end;
{$endif}
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

procedure TpvCustomHandleMap.SetHandleData(const ppvHandle:TpvHandle;const pData);
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
{$ifdef Debug}
  if (ppvHandle.Index<TpvInt64(length(fGenerationArray))) and
     (ppvHandle.Generation=fGenerationArray[ppvHandle.Index]) then begin
{$endif}
   CopyHandleData(pData,fDataArray[fSparseToDenseArray[ppvHandle.Index]*TpvSizeUInt(fDataSize)]);
{$ifdef Debug}
  end else begin
   raise EpvHandleMap.Create('Accessing non-used or already-freed handle');
  end;
{$endif}
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

function TpvCustomHandleMap.GetHandleDataPointer(const ppvHandle:TpvHandle):TpvPointer;
begin
{$ifdef Debug}
 if (ppvHandle.Index<TpvInt64(length(fGenerationArray))) and
    (ppvHandle.Generation=fGenerationArray[ppvHandle.Index]) then begin
{$endif}
  result:=@fDataArray[fSparseToDenseArray[ppvHandle.Index]*TpvSizeUInt(fDataSize)];
{$ifdef Debug}
 end else begin
  result:=nil;
  raise EpvHandleMap.Create('Accessing non-used or already-freed handle');
 end;
{$endif}
end;

{$warnings off}
{$hints off}

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TEntityEnumerator.Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TEntityEnumerator.GetCurrent:TEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TEntityEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TKeyEnumerator.Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TKeyEnumerator.GetCurrent:TpvHashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TKeyEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TpvHashMapValueEnumerator.Create(const aHashMap:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TpvHashMapValueEnumerator.GetCurrent:TpvHashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TpvHashMapValueEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TEntitiesObject.Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TEntitiesObject.GetEnumerator:TEntityEnumerator;
begin
 result:=TEntityEnumerator.Create(fOwner);
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TKeysObject.Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TKeysObject.GetEnumerator:TKeyEnumerator;
begin
 result:=TKeyEnumerator.Create(fOwner);
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TValuesObject.Create(const aOwner:TpvHashMap<TpvHashMapKey,TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TValuesObject.GetEnumerator:TpvHashMapValueEnumerator;
begin
 result:=TpvHashMapValueEnumerator.Create(fOwner);
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TValuesObject.GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TValuesObject.SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;

constructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Create(const aDefaultValue:TpvHashMapValue);
begin
 inherited Create;
 fSize:=0;
 fLogSize:=0;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 fEntities:=nil;
 fDefaultValue:=aDefaultValue;
 fCanShrink:=true;
 fEntitiesObject:=TEntitiesObject.Create(self);
 fKeysObject:=TKeysObject.Create(self);
 fValuesObject:=TValuesObject.Create(self);
 Resize;
end;

destructor TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Destroy;
var Index:TpvSizeInt;
begin
 Clear;
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fEntities:=nil;
 FreeAndNil(fEntitiesObject);
 FreeAndNil(fKeysObject);
 FreeAndNil(fValuesObject);
 inherited Destroy;
end;

procedure TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Clear(const aCanFree:Boolean);
var Index:TpvSizeInt;
begin
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 if fCanShrink and aCanFree then begin
  fSize:=0;
  fLogSize:=0;
  fEntities:=nil;
  Resize;
 end else begin
  for Index:=0 to length(fEntities)-1 do begin
   fEntities[Index].State:=TEntity.Empty;
  end;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.HashData(const aData:TpvPointer;const aDataLength:TpvUInt32):TpvUInt32;
// xxHash32
const PRIME32_1=TpvUInt32(2654435761);
      PRIME32_2=TpvUInt32(2246822519);
      PRIME32_3=TpvUInt32(3266489917);
      PRIME32_4=TpvUInt32(668265263);
      PRIME32_5=TpvUInt32(374761393);
      Seed=TpvUInt32($1337c0d3);
      v1Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_1)+TpvUInt64(PRIME32_2)));
      v2Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_2)));
      v3Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(0)));
      v4Initialization=TpvUInt32(TpvUInt64(TpvInt64(TpvInt64(Seed)-TpvInt64(PRIME32_1))));
      HashInitialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_5)));
var v1,v2,v3,v4:TpvUInt32;
    p,e,Limit:PpvUInt8;
begin
 p:=aData;
 if aDataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PpvUInt8Array(aData)^[aDataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v1,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v2,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v3,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v4,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
  until {%H-}TpvPtrUInt(p)>{%H-}TpvPtrUInt(e);
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(v1,1)+ROLDWord(v2,7)+ROLDWord(v3,12)+ROLDWord(v4,18);
{$else}
  result:=((v1 shl 1) or (v1 shr 31))+
          ((v2 shl 7) or (v2 shr 25))+
          ((v3 shl 12) or (v3 shr 20))+
          ((v4 shl 18) or (v4 shr 14));
{$ifend}
 end else begin
  result:=HashInitialization;
 end;
 inc(result,aDataLength);
 e:=@PpvUInt8Array(aData)^[aDataLength];
 while ({%H-}TpvPtrUInt(p)+SizeOf(TpvUInt32))<={%H-}TpvPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_3)),17)*TpvUInt32(PRIME32_4);
{$else}
  inc(result,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*TpvUInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(TpvUInt32));
 end;
 while {%H-}TpvPtrUInt(p)<{%H-}TpvPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TpvUInt8(TpvPointer(p)^)*TpvUInt32(PRIME32_5)),11)*TpvUInt32(PRIME32_1);
{$else}
  inc(result,TpvUInt8(TpvPointer(p)^)*TpvUInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*TpvUInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(TpvUInt8));
 end;
 result:=(result xor (result shr 15))*TpvUInt32(PRIME32_2);
 result:=(result xor (result shr 13))*TpvUInt32(PRIME32_3);
 result:=result xor (result shr 16);
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.HashKey(const aKey:TpvHashMapKey):TpvUInt32;
var p:TpvUInt64;
begin
 // We're hoping here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
{$ifndef ExtraStringHashMap}
 if (SizeOf(TpvHashMapKey)=SizeOf(AnsiString)) and
    (TypeInfo(TpvHashMapKey)=TypeInfo(AnsiString)) then begin
  result:=HashData(PpvUInt8(@AnsiString(TpvPointer(@aKey)^)[1]),length(AnsiString(TpvPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TpvHashMapKey)=SizeOf(UTF8String)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(UTF8String)) then begin
  result:=HashData(PpvUInt8(@UTF8String(TpvPointer(@aKey)^)[1]),length(UTF8String(TpvPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TpvHashMapKey)=SizeOf(RawByteString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(RawByteString)) then begin
  result:=HashData(PpvUInt8(@RawByteString(TpvPointer(@aKey)^)[1]),length(RawByteString(TpvPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TpvHashMapKey)=SizeOf(WideString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(WideString)) then begin
  result:=HashData(PpvUInt8(@WideString(TpvPointer(@aKey)^)[1]),length(WideString(TpvPointer(@aKey)^))*SizeOf(WideChar));
 end else if (SizeOf(TpvHashMapKey)=SizeOf(UnicodeString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(UnicodeString)) then begin
  result:=HashData(PpvUInt8(@UnicodeString(TpvPointer(@aKey)^)[1]),length(UnicodeString(TpvPointer(@aKey)^))*SizeOf(UnicodeChar));
 end else if (SizeOf(TpvHashMapKey)=SizeOf(String)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(String)) then begin
  result:=HashData(PpvUInt8(@String(TpvPointer(@aKey)^)[1]),length(String(TpvPointer(@aKey)^))*SizeOf(Char));
 end else if TypeInfo(TpvHashMapKey)=TypeInfo(TpvUUID) then begin
  result:=(TpvUUID(TpvPointer(@aKey)^).UInt32s[0]*73856093) xor
          (TpvUUID(TpvPointer(@aKey)^).UInt32s[1]*19349669) xor
          (TpvUUID(TpvPointer(@aKey)^).UInt32s[2]*83492791) xor
          (TpvUUID(TpvPointer(@aKey)^).UInt32s[3]*50331653);
 end else{$endif}begin
  case SizeOf(TpvHashMapKey) of
   SizeOf(UInt16):begin
    // 16-bit big => use 16-bit integer-rehashing
    result:=TpvUInt16(TpvPointer(@aKey)^);
    result:=(result or (((not result) and $ffff) shl 16));
    dec(result,result shl 6);
    result:=result xor (result shr 17);
    dec(result,result shl 9);
    result:=result xor (result shl 4);
    dec(result,result shl 3);
    result:=result xor (result shl 10);
    result:=result xor (result shr 15);
   end;
   SizeOf(TpvUInt32):begin
    // 32-bit big => use 32-bit integer-rehashing
    result:=TpvUInt32(TpvPointer(@aKey)^);
    dec(result,result shl 6);
    result:=result xor (result shr 17);
    dec(result,result shl 9);
    result:=result xor (result shl 4);
    dec(result,result shl 3);
    result:=result xor (result shl 10);
    result:=result xor (result shr 15);
   end;
   SizeOf(TpvUInt64):begin
    // 64-bit big => use 64-bit to 32-bit integer-rehashing
    p:=TpvUInt64(TpvPointer(@aKey)^);
    p:=(not p)+(p shl 18); // p:=((p shl 18)-p-)1;
    p:=p xor (p shr 31);
    p:=p*21; // p:=(p+(p shl 2))+(p shl 4);
    p:=p xor (p shr 11);
    p:=p+(p shl 6);
    result:=TpvUInt32(TpvPtrUInt(p xor (p shr 22)));
   end;
   SizeOf(TpvHashMapUInt128):begin
    // 128-bit
   result:=(TpvUUID(TpvPointer(@aKey)^).UInt32s[0]*73856093) xor
           (TpvUUID(TpvPointer(@aKey)^).UInt32s[1]*19349669) xor
           (TpvUUID(TpvPointer(@aKey)^).UInt32s[2]*83492791) xor
           (TpvUUID(TpvPointer(@aKey)^).UInt32s[3]*50331653);
   end;
   else begin
    result:=HashData(PpvUInt8(TpvPointer(@aKey)),SizeOf(TpvHashMapKey));
   end;
  end;
 end;
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-TpvUInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.CompareKey(const aKeyA,aKeyB:TpvHashMapKey):boolean;
var Index:TpvInt32;
    pA,pB:PpvUInt8Array;
begin
 // We're hoping also here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
{$ifndef ExtraStringHashMap}
 if (SizeOf(TpvHashMapKey)=SizeOf(AnsiString)) and
    (TypeInfo(TpvHashMapKey)=TypeInfo(AnsiString)) then begin
  result:=AnsiString(TpvPointer(@aKeyA)^)=AnsiString(TpvPointer(@aKeyB)^);
 end else if (SizeOf(TpvHashMapKey)=SizeOf(UTF8String)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(UTF8String)) then begin
  result:=UTF8String(TpvPointer(@aKeyA)^)=UTF8String(TpvPointer(@aKeyB)^);
 end else if (SizeOf(TpvHashMapKey)=SizeOf(RawByteString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(RawByteString)) then begin
  result:=RawByteString(TpvPointer(@aKeyA)^)=RawByteString(TpvPointer(@aKeyB)^);
 end else if (SizeOf(TpvHashMapKey)=SizeOf(WideString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(WideString)) then begin
  result:=WideString(TpvPointer(@aKeyA)^)=WideString(TpvPointer(@aKeyB)^);
 end else if (SizeOf(TpvHashMapKey)=SizeOf(UnicodeString)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(UnicodeString)) then begin
  result:=UnicodeString(TpvPointer(@aKeyA)^)=UnicodeString(TpvPointer(@aKeyB)^);
 end else if (SizeOf(TpvHashMapKey)=SizeOf(String)) and
             (TypeInfo(TpvHashMapKey)=TypeInfo(String)) then begin
  result:=String(TpvPointer(@aKeyA)^)=String(TpvPointer(@aKeyB)^);
 end else{$endif}begin
  case SizeOf(TpvHashMapKey) of
   SizeOf(TpvUInt8):begin
    result:=UInt8(TpvPointer(@aKeyA)^)=UInt8(TpvPointer(@aKeyB)^);
   end;
   SizeOf(TpvUInt16):begin
    result:=UInt16(TpvPointer(@aKeyA)^)=UInt16(TpvPointer(@aKeyB)^);
   end;
   SizeOf(TpvUInt32):begin
    result:=TpvUInt32(TpvPointer(@aKeyA)^)=TpvUInt32(TpvPointer(@aKeyB)^);
   end;
   SizeOf(TpvUInt64):begin
    result:=TpvUInt64(TpvPointer(@aKeyA)^)=TpvUInt64(TpvPointer(@aKeyB)^);
   end;
{$ifdef fpc}
   SizeOf(TpvHashMapUInt128):begin
    result:=(TpvHashMapUInt128(TpvPointer(@aKeyA)^)[0]=TpvHashMapUInt128(TpvPointer(@aKeyB)^)[0]) and
            (TpvHashMapUInt128(TpvPointer(@aKeyA)^)[1]=TpvHashMapUInt128(TpvPointer(@aKeyB)^)[1]);
   end;
{$endif}
   else begin
    Index:=0;
    pA:=@aKeyA;
    pB:=@aKeyB;
    while (Index+SizeOf(TpvUInt32))<SizeOf(TpvHashMapKey) do begin
     if TpvUInt32(TpvPointer(@pA^[Index])^)<>TpvUInt32(TpvPointer(@pB^[Index])^) then begin
      result:=false;
      exit;
     end;
     inc(Index,SizeOf(TpvUInt32));
    end;
    while (Index+SizeOf(UInt8))<SizeOf(TpvHashMapKey) do begin
     if UInt8(TpvPointer(@pA^[Index])^)<>UInt8(TpvPointer(@pB^[Index])^) then begin
      result:=false;
      exit;
     end;
     inc(Index,SizeOf(UInt8));
    end;
    result:=true;
   end;
  end;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.FindEntity(const aKey:TpvHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TpvSizeUInt;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  if (result^.State=TEntity.Empty) or ((result^.State=TEntity.Used) and CompareKey(result^.Key,aKey)) then begin
   exit;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=nil;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.FindEntityForAdd(const aKey:TpvHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TpvSizeUInt;
    DeletedEntity:PEntity;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 DeletedEntity:=nil;
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  case result^.State of
   TEntity.Empty:begin
    if assigned(DeletedEntity) then begin
     result:=DeletedEntity;
    end;
    exit;
   end;
   TEntity.Deleted:begin
    if not assigned(DeletedEntity) then begin
     DeletedEntity:=result;
    end;
   end;
   else {TEntity.Used:}begin
    if CompareKey(result^.Key,aKey) then begin
     exit;
    end;
   end;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=DeletedEntity;
end;

procedure TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Resize;
var Index:TpvSizeInt;
    OldEntities:TEntities;
    OldEntity:PEntity;
begin

 fLogSize:={$ifdef cpu64}IntLog264{$else}IntLog2{$endif}(fCountNonEmptyEntites)+1;

 fSize:=2 shl fLogSize;

 fCountNonEmptyEntites:=0;

 fCountDeletedEntites:=0;

 OldEntities:=fEntities;

 fEntities:=nil;
 SetLength(fEntities,fSize);

 for Index:=0 to length(fEntities)-1 do begin
  fEntities[Index].State:=TEntity.Empty;
 end;

 if length(OldEntities)>0 then begin
  try
   for Index:=0 to length(OldEntities)-1 do begin
    OldEntity:=@OldEntities[Index];
    if OldEntity^.State=TEntity.Used then begin
     Add(OldEntity^.Key,OldEntity^.Value);
    end;
{   Finalize(OldEntity^.Key);
    Finalize(OldEntity^.Value);}
   end;
  finally
   OldEntities:=nil;
  end;
 end;

end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Add(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue):PEntity;
begin
 repeat
  while fCountNonEmptyEntites>=(1 shl fLogSize) do begin
   Resize;
  end;
  result:=FindEntityForAdd(aKey);
  if assigned(result) then begin
   case result^.State of
    TEntity.Empty:begin
     inc(fCountNonEmptyEntites);
    end;
    TEntity.Deleted:begin
     dec(fCountDeletedEntites);
    end;
    else begin
    end;
   end;
   result^.State:=TEntity.Used;
   result^.Key:=aKey;
   result^.Value:=aValue;
   break;
  end else begin
   Resize;
  end;
 until false;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Get(const aKey:TpvHashMapKey;const aCreateIfNotExist:boolean):PEntity;
var Value:TpvHashMapValue;
begin
 result:=FindEntity(aKey);
 if assigned(result) then begin
  case result^.State of
   TEntity.Used:begin
   end;
   else {TEntity.Empty,TEntity.Deleted:}begin
    if aCreateIfNotExist then begin
     Initialize(Value);
     result:=Add(aKey,Value);
    end else begin
     result:=nil;
    end;
   end;
  end;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.TryGet(const aKey:TpvHashMapKey;out aValue:TpvHashMapValue):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
  if result then begin
   aValue:=Entity^.Value;
  end else begin
   Initialize(aValue);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.ExistKey(const aKey:TpvHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
 end else begin
  result:=false;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.Delete(const aKey:TpvHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 result:=Entity^.State=TEntity.Used;
 if result then begin
  Entity^.State:=TEntity.Deleted;
  Finalize(Entity^.Key);
  Finalize(Entity^.Value);
  inc(fCountDeletedEntites);
  if fCanShrink and (fSize>=8) and (fCountDeletedEntites>=((fSize+3) shr 2)) then begin
   dec(fCountNonEmptyEntites,fCountDeletedEntites);
   Resize;
  end;
 end;
end;

function TpvHashMap<TpvHashMapKey,TpvHashMapValue>.GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) and (Entity^.State=TEntity.Used) then begin
  result:=Entity^.Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TpvHashMap<TpvHashMapKey,TpvHashMapValue>.SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
begin
 Add(aKey,aValue);
end;

{$ifdef ExtraStringHashMap}
constructor TpvStringHashMap<TpvHashMapValue>.TEntityEnumerator.Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvStringHashMap<TpvHashMapValue>.TEntityEnumerator.GetCurrent:TEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TpvStringHashMap<TpvHashMapValue>.TEntityEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvStringHashMap<TpvHashMapValue>.TKeyEnumerator.Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvStringHashMap<TpvHashMapValue>.TKeyEnumerator.GetCurrent:TpvHashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TpvStringHashMap<TpvHashMapValue>.TKeyEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvStringHashMap<TpvHashMapValue>.TpvHashMapValueEnumerator.Create(const aHashMap:TpvStringHashMap<TpvHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvStringHashMap<TpvHashMapValue>.TpvHashMapValueEnumerator.GetCurrent:TpvHashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TpvStringHashMap<TpvHashMapValue>.TpvHashMapValueEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvStringHashMap<TpvHashMapValue>.TEntitiesObject.Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvStringHashMap<TpvHashMapValue>.TEntitiesObject.GetEnumerator:TEntityEnumerator;
begin
 result:=TEntityEnumerator.Create(fOwner);
end;

constructor TpvStringHashMap<TpvHashMapValue>.TKeysObject.Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvStringHashMap<TpvHashMapValue>.TKeysObject.GetEnumerator:TKeyEnumerator;
begin
 result:=TKeyEnumerator.Create(fOwner);
end;

constructor TpvStringHashMap<TpvHashMapValue>.TValuesObject.Create(const aOwner:TpvStringHashMap<TpvHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvStringHashMap<TpvHashMapValue>.TValuesObject.GetEnumerator:TpvHashMapValueEnumerator;
begin
 result:=TpvHashMapValueEnumerator.Create(fOwner);
end;

function TpvStringHashMap<TpvHashMapValue>.TValuesObject.GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TpvStringHashMap<TpvHashMapValue>.TValuesObject.SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;

constructor TpvStringHashMap<TpvHashMapValue>.Create(const aDefaultValue:TpvHashMapValue);
begin
 inherited Create;
 fSize:=0;
 fLogSize:=0;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 fEntities:=nil;
 fDefaultValue:=aDefaultValue;
 fCanShrink:=true;
 fEntitiesObject:=TEntitiesObject.Create(self);
 fKeysObject:=TKeysObject.Create(self);
 fValuesObject:=TValuesObject.Create(self);
 Resize;
end;

destructor TpvStringHashMap<TpvHashMapValue>.Destroy;
var Index:TpvSizeInt;
begin
 Clear;
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fEntities:=nil;
 FreeAndNil(fEntitiesObject);
 FreeAndNil(fKeysObject);
 FreeAndNil(fValuesObject);
 inherited Destroy;
end;

procedure TpvStringHashMap<TpvHashMapValue>.Clear(const aCanFree:Boolean);
var Index:TpvSizeInt;
begin
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 if fCanShrink and aCanFree then begin
  fSize:=0;
  fLogSize:=0;
  fEntities:=nil;
  Resize;
 end else begin
  for Index:=0 to length(fEntities)-1 do begin
   fEntities[Index].State:=TEntity.Empty;
  end;
 end;
end;

function TpvStringHashMap<TpvHashMapValue>.HashKey(const aKey:TpvHashMapKey):TpvUInt32;
// xxHash32
const PRIME32_1=TpvUInt32(2654435761);
      PRIME32_2=TpvUInt32(2246822519);
      PRIME32_3=TpvUInt32(3266489917);
      PRIME32_4=TpvUInt32(668265263);
      PRIME32_5=TpvUInt32(374761393);
      Seed=TpvUInt32($1337c0d3);
      v1Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_1)+TpvUInt64(PRIME32_2)));
      v2Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_2)));
      v3Initialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(0)));
      v4Initialization=TpvUInt32(TpvUInt64(TpvInt64(TpvInt64(Seed)-TpvInt64(PRIME32_1))));
      HashInitialization=TpvUInt32(TpvUInt64(TpvUInt64(Seed)+TpvUInt64(PRIME32_5)));
var v1,v2,v3,v4,DataLength:TpvUInt32;
    p,e,Limit:PpvUInt8;
begin
 p:=TpvPointer(@aKey[1]);
 DataLength:=length(aKey)*SizeOf(aKey[1]);
 if DataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PpvUInt8Array(TpvPointer(@aKey[1]))^[DataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v1,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v2,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v3,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2)),13)*TpvUInt32(PRIME32_1);
{$else}
   inc(v4,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*TpvUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TpvUInt32));
  until {%H-}TpvPtrUInt(p)>{%H-}TpvPtrUInt(e);
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(v1,1)+ROLDWord(v2,7)+ROLDWord(v3,12)+ROLDWord(v4,18);
{$else}
  result:=((v1 shl 1) or (v1 shr 31))+
          ((v2 shl 7) or (v2 shr 25))+
          ((v3 shl 12) or (v3 shr 20))+
          ((v4 shl 18) or (v4 shr 14));
{$ifend}
 end else begin
  result:=HashInitialization;
 end;
 inc(result,DataLength);
 e:=@PpvUInt8Array(TpvPointer(@aKey[1]))^[DataLength];
 while ({%H-}TpvPtrUInt(p)+SizeOf(TpvUInt32))<={%H-}TpvPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_3)),17)*TpvUInt32(PRIME32_4);
{$else}
  inc(result,TpvUInt32(TpvPointer(p)^)*TpvUInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*TpvUInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(TpvUInt32));
 end;
 while {%H-}TpvPtrUInt(p)<{%H-}TpvPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TpvUInt8(TpvPointer(p)^)*TpvUInt32(PRIME32_5)),11)*TpvUInt32(PRIME32_1);
{$else}
  inc(result,TpvUInt8(TpvPointer(p)^)*TpvUInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*TpvUInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(TpvUInt8));
 end;
 result:=(result xor (result shr 15))*TpvUInt32(PRIME32_2);
 result:=(result xor (result shr 13))*TpvUInt32(PRIME32_3);
 result:=result xor (result shr 16);
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-TpvUInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TpvStringHashMap<TpvHashMapValue>.FindEntity(const aKey:TpvHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TpvSizeUInt;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  if (result^.State=TEntity.Empty) or ((result^.State=TEntity.Used) and (result^.Key=aKey)) then begin
   exit;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=nil;
end;

function TpvStringHashMap<TpvHashMapValue>.FindEntityForAdd(const aKey:TpvHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TpvSizeUInt;
    DeletedEntity:PEntity;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 DeletedEntity:=nil;
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  case result^.State of
   TEntity.Empty:begin
    if assigned(DeletedEntity) then begin
     result:=DeletedEntity;
    end;
    exit;
   end;
   TEntity.Deleted:begin
    if not assigned(DeletedEntity) then begin
     DeletedEntity:=result;
    end;
   end;
   else {TEntity.Used:}begin
    if result^.Key=aKey then begin
     exit;
    end;
   end;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=DeletedEntity;
end;

procedure TpvStringHashMap<TpvHashMapValue>.Resize;
var Index:TpvSizeInt;
    OldEntities:TEntities;
    OldEntity:PEntity;
begin

 fLogSize:={$ifdef cpu64}IntLog264{$else}IntLog2{$endif}(fCountNonEmptyEntites)+1;

 fSize:=2 shl fLogSize;

 fCountNonEmptyEntites:=0;

 fCountDeletedEntites:=0;

 OldEntities:=fEntities;

 fEntities:=nil;
 SetLength(fEntities,fSize);

 for Index:=0 to length(fEntities)-1 do begin
  fEntities[Index].State:=TEntity.Empty;
 end;

 if length(OldEntities)>0 then begin
  try
   for Index:=0 to length(OldEntities)-1 do begin
    OldEntity:=@OldEntities[Index];
    if OldEntity^.State=TEntity.Used then begin
     Add(OldEntity^.Key,OldEntity^.Value);
    end;
{   Finalize(OldEntity^.Key);
    Finalize(OldEntity^.Value);}
   end;
  finally
   OldEntities:=nil;
  end;
 end;

end;

function TpvStringHashMap<TpvHashMapValue>.Add(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue):PEntity;
begin
 repeat
  while fCountNonEmptyEntites>=(1 shl fLogSize) do begin
   Resize;
  end;
  result:=FindEntityForAdd(aKey);
  if assigned(result) then begin
   case result^.State of
    TEntity.Empty:begin
     inc(fCountNonEmptyEntites);
    end;
    TEntity.Deleted:begin
     dec(fCountDeletedEntites);
    end;
    else begin
    end;
   end;
   result^.State:=TEntity.Used;
   result^.Key:=aKey;
   result^.Value:=aValue;
   break;
  end else begin
   Resize;
  end;
 until false;
end;

function TpvStringHashMap<TpvHashMapValue>.Get(const aKey:TpvHashMapKey;const aCreateIfNotExist:boolean):PEntity;
var Value:TpvHashMapValue;
begin
 result:=FindEntity(aKey);
 if assigned(result) then begin
  case result^.State of
   TEntity.Used:begin
   end;
   else {TEntity.Empty,TEntity.Deleted:}begin
    if aCreateIfNotExist then begin
     Initialize(Value);
     result:=Add(aKey,Value);
    end else begin
     result:=nil;
    end;
   end;
  end;
 end else begin
  result:=nil;
 end;
end;

function TpvStringHashMap<TpvHashMapValue>.TryGet(const aKey:TpvHashMapKey;out aValue:TpvHashMapValue):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
  if result then begin
   aValue:=Entity^.Value;
  end else begin
   Initialize(aValue);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvStringHashMap<TpvHashMapValue>.ExistKey(const aKey:TpvHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
 end else begin
  result:=false;
 end;
end;

function TpvStringHashMap<TpvHashMapValue>.Delete(const aKey:TpvHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
  if result then begin
   Entity^.State:=TEntity.Deleted;
   Finalize(Entity^.Key);
   Finalize(Entity^.Value);
   inc(fCountDeletedEntites);
   if fCanShrink and (fSize>=8) and (fCountDeletedEntites>=((fSize+3) shr 2)) then begin
    dec(fCountNonEmptyEntites,fCountDeletedEntites);
    Resize;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

function TpvStringHashMap<TpvHashMapValue>.GetValue(const aKey:TpvHashMapKey):TpvHashMapValue;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) and (Entity^.State=TEntity.Used) then begin
  result:=Entity^.Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TpvStringHashMap<TpvHashMapValue>.SetValue(const aKey:TpvHashMapKey;const aValue:TpvHashMapValue);
begin
 Add(aKey,aValue);
end;
{$endif}

constructor TpvGenericSkipList<TKey,TValue>.TValueEnumerator.Create(const aSkipList:TpvGenericSkipList<TKey,TValue>);
begin
 fSkipList:=aSkipList;
 fPair:=fSkipList.fPairs;
end;

function TpvGenericSkipList<TKey,TValue>.TValueEnumerator.GetCurrent:TValue;
begin
 result:=fPair.fValue;
end;

function TpvGenericSkipList<TKey,TValue>.TValueEnumerator.MoveNext:boolean;
begin
 fPair:=fPair.fNext;
 result:=fPair<>fSkipList.fPairs;
end;

constructor TpvGenericSkipList<TKey,TValue>.TPair.Create(const aSkipList:TpvGenericSkipList<TKey,TValue>;const aKey:TKey;const aValue:TValue);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 fKey:=aKey;
 fValue:=aValue;
end;

constructor TpvGenericSkipList<TKey,TValue>.TPair.CreateEmpty(const aSkipList:TpvGenericSkipList<TKey,TValue>);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 Initialize(fKey);
 Initialize(fValue);
end;

destructor TpvGenericSkipList<TKey,TValue>.TPair.Destroy;
begin
 fPrevious.fNext:=fNext;
 fNext.fPrevious:=fPrevious;
 fPrevious:=self;
 fNext:=self;
 Finalize(fKey);
 Finalize(fValue);
 inherited Destroy;
end;

function TpvGenericSkipList<TKey,TValue>.TPair.GetPrevious:TPair;
begin
 if fPrevious<>fSkipList.fPairs then begin
  result:=fPrevious;
 end else begin
  result:=nil;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.TPair.GetNext:TPair;
begin
 if fNext<>fSkipList.fPairs then begin
  result:=fNext;
 end else begin
  result:=nil;
 end;
end;

constructor TpvGenericSkipList<TKey,TValue>.TNode.Create(const aPrevious:TNode=nil;
                                                         const aNext:TNode=nil;
                                                         const aChildren:TNode=nil;
                                                         const aPair:TPair=nil);
begin
 inherited Create;
 fPrevious:=aPrevious;
 fNext:=aNext;
 fChildren:=aChildren;
 fPair:=aPair;
end;

destructor TpvGenericSkipList<TKey,TValue>.TNode.Destroy;
begin
 if assigned(fPair) and not assigned(fChildren) then begin
  fPair.Free;
 end;
 inherited Destroy;
end;

constructor TpvGenericSkipList<TKey,TValue>.Create(const aDefaultValue:TValue);
begin
 inherited Create;
 fRandomGeneratorState.State:=0;
 fRandomGeneratorState.Increment:=(TpvPtrUInt(TpvPointer(self)) shl 1) or 1;
 GetRandomValue;
 inc(fRandomGeneratorState.State,(TpvPtrUInt(TpvPointer(self)) shr 19) or (TpvPtrUInt(Pointer(self)) shl 13));
 GetRandomValue;
 fDefaultValue:=aDefaultValue;
 fHead:=TNode.Create;
 fPairs:=TPair.CreateEmpty(self);
end;

destructor TpvGenericSkipList<TKey,TValue>.Destroy;
var Node,TemporaryHead,CurrentNode,NextNode:TNode;
begin
 Node:=fHead;
 while assigned(Node) do begin
  TemporaryHead:=Node;
  Node:=Node.fChildren;
  CurrentNode:=TemporaryHead;
  while assigned(CurrentNode) do begin
   NextNode:=CurrentNode.fNext;
   CurrentNode.Free;
   CurrentNode:=NextNode;
  end;
 end;
 while fPairs.fNext<>fPairs do begin
  fPairs.fNext.Free;
 end;
 fPairs.Free;
 inherited Destroy;
end;

function TpvGenericSkipList<TKey,TValue>.GetRandomValue:TpvUInt32;
var RandomGeneratorState:TpvUInt64;
{$ifndef fpc}
    RandomGeneratorXorShifted,RandomGeneratorRotation:TpvUInt32;
{$endif}
begin
 RandomGeneratorState:=fRandomGeneratorState.State;
 fRandomGeneratorState.State:=(RandomGeneratorState*TpvUInt64(6364136223846793005))+fRandomGeneratorState.Increment;
{$ifdef fpc}
 result:=RORDWord(TpvUInt32(((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27),RandomGeneratorState shr 59);
{$else}
 RandomGeneratorXorShifted:=((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27;
 RandomGeneratorRotation:=RandomGeneratorState shr 59;
 result:=(RandomGeneratorXorShifted shr RandomGeneratorRotation) or (RandomGeneratorXorShifted shl (32-RandomGeneratorRotation));
{$endif}
end;

function TpvGenericSkipList<TKey,TValue>.GetFirstPair:TPair;
begin
 result:=fPairs.fNext;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.GetLastPair:TPair;
begin
 result:=fPairs.fPrevious;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
var NextNode:TNode;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 result:=aNode;
 while assigned(result) do begin
  NextNode:=result.fNext;
  if assigned(NextNode) and (Comparer.Compare(NextNode.fPair.fKey,aKey)<=0) then begin
   result:=NextNode;
  end else begin
   break;
  end;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.GetNearestPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair,BestPair:TPair;
begin
 BestPair:=fPairs.Next;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) then begin
   BestPair:=Pair;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 if assigned(BestPair) and (BestPair<>fPairs) then begin
  result:=BestPair;
 end else begin
  result:=nil;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.GetNearestKey(const aKey:TKey):TKey;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fKey;
 end else begin
  result:=aKey;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.GetNearestValue(const aKey:TKey):TValue;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fValue;
 end else begin
  result:=fDefaultValue;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.Get(const aKey:TKey;out aValue:TValue):boolean;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Comparer.Compare(Pair.fKey,aKey)=0) then begin
   aValue:=Pair.fValue;
   result:=true;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=false;
end;

function TpvGenericSkipList<TKey,TValue>.GetPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Comparer.Compare(Pair.fKey,aKey)=0) then begin
   result:=Pair;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=nil;
end;

function TpvGenericSkipList<TKey,TValue>.GetValue(const aKey:TKey):TValue;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Comparer.Compare(Pair.fKey,aKey)=0) then begin
   result:=Pair.fValue;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=fDefaultValue;
end;

procedure TpvGenericSkipList<TKey,TValue>.SetValue(const aKey:TKey;const aValue:TValue);
var AllocatedPreviousNodes,CountPreviousNodes:TpvInt32;
    RandomGeneratorValue:TpvUInt32;
    CurrentNode,PreviousNode,NewNode:TNode;
    Pair,OtherPair:TPair;
    PreviousNodes:TNodeArray;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 PreviousNodes:=nil;
 try
  CurrentNode:=fHead;
  AllocatedPreviousNodes:=0;
  CountPreviousNodes:=0;
  while assigned(CurrentNode) do begin
   PreviousNode:=FindPreviousNode(CurrentNode,aKey);
   if AllocatedPreviousNodes<=CountPreviousNodes then begin
    AllocatedPreviousNodes:=(CountPreviousNodes+1) shl 1;
    SetLength(PreviousNodes,AllocatedPreviousNodes);
   end;
   PreviousNodes[CountPreviousNodes]:=PreviousNode;
   inc(CountPreviousNodes);
   CurrentNode:=PreviousNode.fChildren;
  end;
  dec(CountPreviousNodes);
  PreviousNode:=PreviousNodes[CountPreviousNodes];
  if assigned(PreviousNode.fPair) and (Comparer.Compare(PreviousNode.fPair.fKey,aKey)=0) then begin
   PreviousNode.fPair.fValue:=aValue;
  end else begin
   if assigned(PreviousNode.fPair) and (PreviousNode.fPair.fNext<>fPairs) then begin
    OtherPair:=PreviousNode.fPair.fNext;
   end else begin
    if Comparer.Compare(fPairs.fPrevious.fKey,aKey)<0 then begin
     OtherPair:=fPairs;
    end else begin
     OtherPair:=fPairs.fNext;
    end;
   end;
   Pair:=TPair.Create(self,aKey,aValue);
   Pair.fPrevious:=OtherPair.fPrevious;
   Pair.fNext:=OtherPair;
   Pair.fPrevious.fNext:=Pair;
   OtherPair.fPrevious:=Pair;
   NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,nil,Pair);
   if assigned(PreviousNode.fNext) then begin
    PreviousNode.fNext.fPrevious:=NewNode;
   end;
   PreviousNode.fNext:=NewNode;
   RandomGeneratorValue:=0;
   repeat
    if RandomGeneratorValue=0 then begin
     RandomGeneratorValue:=GetRandomValue;
    end;
    if (RandomGeneratorValue and 1)=0 then begin
     break;
    end else begin
     RandomGeneratorValue:=RandomGeneratorValue shr 1;
     if CountPreviousNodes>0 then begin
      dec(CountPreviousNodes);
      PreviousNode:=PreviousNodes[CountPreviousNodes];
     end else begin
      fHead:=TNode.Create(nil,nil,fHead);
      PreviousNode:=fHead;
     end;
     NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,NewNode,Pair);
     if assigned(PreviousNode.fNext) then begin
      PreviousNode.fNext.fPrevious:=NewNode;
     end;
     PreviousNode.fNext:=NewNode;
    end;
   until false;
  end;
 finally
  PreviousNodes:=nil;
 end;
end;

procedure TpvGenericSkipList<TKey,TValue>.Delete(const aKey:TKey);
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  if assigned(PreviousNode) then begin
   Pair:=PreviousNode.fPair;
   if assigned(Pair) and (Comparer.Compare(Pair.fKey,aKey)=0) then begin
    CurrentNode:=PreviousNode;
    repeat
     CurrentNode.fPrevious.fNext:=CurrentNode.fNext;
     if assigned(CurrentNode.fNext) then begin
      CurrentNode.fNext.fPrevious:=CurrentNode.fPrevious;
     end;
     PreviousNode:=CurrentNode;
     CurrentNode:=CurrentNode.fChildren;
     PreviousNode.Free;
    until not assigned(CurrentNode);
    break;
   end;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
end;

function TpvGenericSkipList<TKey,TValue>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

{ TpvInt64SkipList<TValue>.TValueEnumerator }

constructor TpvInt64SkipList<TValue>.TValueEnumerator.Create(const aSkipList:TpvInt64SkipList<TValue>);
begin
 fSkipList:=aSkipList;
 fPair:=fSkipList.fPairs;
end;

function TpvInt64SkipList<TValue>.TValueEnumerator.GetCurrent:TValue;
begin
 result:=fPair.fValue;
end;

function TpvInt64SkipList<TValue>.TValueEnumerator.MoveNext:boolean;
begin
 fPair:=fPair.fNext;
 result:=fPair<>fSkipList.fPairs;
end;

{ TpvInt64SkipList<TValue>.TPair }

constructor TpvInt64SkipList<TValue>.TPair.Create(const aSkipList:TpvInt64SkipList<TValue>;const aKey:TKey;const aValue:TValue);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 fKey:=aKey;
 fValue:=aValue;
end;

constructor TpvInt64SkipList<TValue>.TPair.CreateEmpty(const aSkipList:TpvInt64SkipList<TValue>);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 Initialize(fKey);
 Initialize(fValue);
end;

destructor TpvInt64SkipList<TValue>.TPair.Destroy;
begin
 fPrevious.fNext:=fNext;
 fNext.fPrevious:=fPrevious;
 fPrevious:=self;
 fNext:=self;
 Finalize(fKey);
 Finalize(fValue);
 inherited Destroy;
end;

function TpvInt64SkipList<TValue>.TPair.GetPrevious:TPair;
begin
 if fPrevious<>fSkipList.fPairs then begin
  result:=fPrevious;
 end else begin
  result:=nil;
 end;
end;

function TpvInt64SkipList<TValue>.TPair.GetNext:TPair;
begin
 if fNext<>fSkipList.fPairs then begin
  result:=fNext;
 end else begin
  result:=nil;
 end;
end;

{ TpvInt64SkipList<TValue>.TNode }

constructor TpvInt64SkipList<TValue>.TNode.Create(const aPrevious:TNode=nil;
                                                  const aNext:TNode=nil;
                                                  const aChildren:TNode=nil;
                                                  const aPair:TPair=nil);
begin
 inherited Create;
 fPrevious:=aPrevious;
 fNext:=aNext;
 fChildren:=aChildren;
 fPair:=aPair;
end;

destructor TpvInt64SkipList<TValue>.TNode.Destroy;
begin
 if assigned(fPair) and not assigned(fChildren) then begin
  fPair.Free;
 end;
 inherited Destroy;
end;

{ TpvInt64SkipList<TValue> }

constructor TpvInt64SkipList<TValue>.Create(const aDefaultValue:TValue);
begin
 inherited Create;
 fRandomGeneratorState.State:=0;
 fRandomGeneratorState.Increment:=(TpvPtrUInt(TpvPointer(self)) shl 1) or 1;
 GetRandomValue;
 inc(fRandomGeneratorState.State,(TpvPtrUInt(TpvPointer(self)) shr 19) or (TpvPtrUInt(Pointer(self)) shl 13));
 GetRandomValue;
 fDefaultValue:=aDefaultValue;
 fHead:=TNode.Create;
 fPairs:=TPair.CreateEmpty(self);
end;

destructor TpvInt64SkipList<TValue>.Destroy;
var Node,TemporaryHead,CurrentNode,NextNode:TNode;
begin
 Node:=fHead;
 while assigned(Node) do begin
  TemporaryHead:=Node;
  Node:=Node.fChildren;
  CurrentNode:=TemporaryHead;
  while assigned(CurrentNode) do begin
   NextNode:=CurrentNode.fNext;
   CurrentNode.Free;
   CurrentNode:=NextNode;
  end;
 end;
 while fPairs.fNext<>fPairs do begin
  fPairs.fNext.Free;
 end;
 fPairs.Free;
 inherited Destroy;
end;

function TpvInt64SkipList<TValue>.GetRandomValue:TpvUInt32;
var RandomGeneratorState:TpvUInt64;
{$ifndef fpc}
    RandomGeneratorXorShifted,RandomGeneratorRotation:TpvUInt32;
{$endif}
begin
 RandomGeneratorState:=fRandomGeneratorState.State;
 fRandomGeneratorState.State:=(RandomGeneratorState*TpvUInt64(6364136223846793005))+fRandomGeneratorState.Increment;
{$ifdef fpc}
 result:=RORDWord(TpvUInt32(((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27),RandomGeneratorState shr 59);
{$else}
 RandomGeneratorXorShifted:=((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27;
 RandomGeneratorRotation:=RandomGeneratorState shr 59;
 result:=(RandomGeneratorXorShifted shr RandomGeneratorRotation) or (RandomGeneratorXorShifted shl (32-RandomGeneratorRotation));
{$endif}
end;

function TpvInt64SkipList<TValue>.GetFirstPair:TPair;
begin
 result:=fPairs.fNext;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvInt64SkipList<TValue>.GetLastPair:TPair;
begin
 result:=fPairs.fPrevious;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvInt64SkipList<TValue>.FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
var NextNode:TNode;
begin
 result:=aNode;
 while assigned(result) do begin
  NextNode:=result.fNext;
  if assigned(NextNode) and (NextNode.fPair.fKey<=aKey) then begin
   result:=NextNode;
  end else begin
   break;
  end;
 end;
end;

function TpvInt64SkipList<TValue>.GetNearestPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair,BestPair:TPair;
begin
 BestPair:=fPairs.Next;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) then begin
   BestPair:=Pair;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 if assigned(BestPair) and (BestPair<>fPairs) then begin
  result:=BestPair;
 end else begin
  result:=nil;
 end;
end;

function TpvInt64SkipList<TValue>.GetNearestKey(const aKey:TKey):TKey;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fKey;
 end else begin
  result:=aKey;
 end;
end;

function TpvInt64SkipList<TValue>.GetNearestValue(const aKey:TKey):TValue;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fValue;
 end else begin
  result:=fDefaultValue;
 end;
end;

function TpvInt64SkipList<TValue>.Get(const aKey:TKey;out aValue:TValue):boolean;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   aValue:=Pair.fValue;
   result:=true;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=false;
end;

function TpvInt64SkipList<TValue>.GetPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   result:=Pair;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=nil;
end;

function TpvInt64SkipList<TValue>.GetValue(const aKey:TKey):TValue;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   result:=Pair.fValue;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=fDefaultValue;
end;

procedure TpvInt64SkipList<TValue>.SetValue(const aKey:TKey;const aValue:TValue);
var AllocatedPreviousNodes,CountPreviousNodes:TpvInt32;
    RandomGeneratorValue:TpvUInt32;
    CurrentNode,PreviousNode,NewNode:TNode;
    Pair,OtherPair:TPair;
    PreviousNodes:TNodeArray;
begin
 PreviousNodes:=nil;
 try
  CurrentNode:=fHead;
  AllocatedPreviousNodes:=0;
  CountPreviousNodes:=0;
  while assigned(CurrentNode) do begin
   PreviousNode:=FindPreviousNode(CurrentNode,aKey);
   if AllocatedPreviousNodes<=CountPreviousNodes then begin
    AllocatedPreviousNodes:=(CountPreviousNodes+1) shl 1;
    SetLength(PreviousNodes,AllocatedPreviousNodes);
   end;
   PreviousNodes[CountPreviousNodes]:=PreviousNode;
   inc(CountPreviousNodes);
   CurrentNode:=PreviousNode.fChildren;
  end;
  dec(CountPreviousNodes);
  PreviousNode:=PreviousNodes[CountPreviousNodes];
  if assigned(PreviousNode.fPair) and (PreviousNode.fPair.fKey=aKey) then begin
   PreviousNode.fPair.fValue:=aValue;
  end else begin
   if assigned(PreviousNode.fPair) and (PreviousNode.fPair.fNext<>fPairs) then begin
    OtherPair:=PreviousNode.fPair.fNext;
   end else begin
    if fPairs.fPrevious.fKey<aKey then begin
     OtherPair:=fPairs;
    end else begin
     OtherPair:=fPairs.fNext;
    end;
   end;
   Pair:=TPair.Create(self,aKey,aValue);
   Pair.fPrevious:=OtherPair.fPrevious;
   Pair.fNext:=OtherPair;
   Pair.fPrevious.fNext:=Pair;
   OtherPair.fPrevious:=Pair;
   NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,nil,Pair);
   if assigned(PreviousNode.fNext) then begin
    PreviousNode.fNext.fPrevious:=NewNode;
   end;
   PreviousNode.fNext:=NewNode;
   RandomGeneratorValue:=0;
   repeat
    if RandomGeneratorValue=0 then begin
     RandomGeneratorValue:=GetRandomValue;
    end;
    if (RandomGeneratorValue and 1)=0 then begin
     break;
    end else begin
     RandomGeneratorValue:=RandomGeneratorValue shr 1;
     if CountPreviousNodes>0 then begin
      dec(CountPreviousNodes);
      PreviousNode:=PreviousNodes[CountPreviousNodes];
     end else begin
      fHead:=TNode.Create(nil,nil,fHead);
      PreviousNode:=fHead;
     end;
     NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,NewNode,Pair);
     if assigned(PreviousNode.fNext) then begin
      PreviousNode.fNext.fPrevious:=NewNode;
     end;
     PreviousNode.fNext:=NewNode;
    end;
   until false;
  end;
 finally
  PreviousNodes:=nil;
 end;
end;

procedure TpvInt64SkipList<TValue>.Delete(const aKey:TKey);
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  if assigned(PreviousNode) then begin
   Pair:=PreviousNode.fPair;
   if assigned(Pair) and (Pair.fKey=aKey) then begin
    CurrentNode:=PreviousNode;
    repeat
     CurrentNode.fPrevious.fNext:=CurrentNode.fNext;
     if assigned(CurrentNode.fNext) then begin
      CurrentNode.fNext.fPrevious:=CurrentNode.fPrevious;
     end;
     PreviousNode:=CurrentNode;
     CurrentNode:=CurrentNode.fChildren;
     PreviousNode.Free;
    until not assigned(CurrentNode);
    break;
   end;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
end;

function TpvInt64SkipList<TValue>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

{ TpvUInt64SkipList<TValue>.TValueEnumerator }

constructor TpvUInt64SkipList<TValue>.TValueEnumerator.Create(const aSkipList:TpvUInt64SkipList<TValue>);
begin
 fSkipList:=aSkipList;
 fPair:=fSkipList.fPairs;
end;

function TpvUInt64SkipList<TValue>.TValueEnumerator.GetCurrent:TValue;
begin
 result:=fPair.fValue;
end;

function TpvUInt64SkipList<TValue>.TValueEnumerator.MoveNext:boolean;
begin
 fPair:=fPair.fNext;
 result:=fPair<>fSkipList.fPairs;
end;

{ TpvUInt64SkipList<TValue>.TPair }

constructor TpvUInt64SkipList<TValue>.TPair.Create(const aSkipList:TpvUInt64SkipList<TValue>;const aKey:TKey;const aValue:TValue);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 fKey:=aKey;
 fValue:=aValue;
end;

constructor TpvUInt64SkipList<TValue>.TPair.CreateEmpty(const aSkipList:TpvUInt64SkipList<TValue>);
begin
 inherited Create;
 fSkipList:=aSkipList;
 fPrevious:=self;
 fNext:=self;
 Initialize(fKey);
 Initialize(fValue);
end;

destructor TpvUInt64SkipList<TValue>.TPair.Destroy;
begin
 fPrevious.fNext:=fNext;
 fNext.fPrevious:=fPrevious;
 fPrevious:=self;
 fNext:=self;
 Finalize(fKey);
 Finalize(fValue);
 inherited Destroy;
end;

function TpvUInt64SkipList<TValue>.TPair.GetPrevious:TPair;
begin
 if fPrevious<>fSkipList.fPairs then begin
  result:=fPrevious;
 end else begin
  result:=nil;
 end;
end;

function TpvUInt64SkipList<TValue>.TPair.GetNext:TPair;
begin
 if fNext<>fSkipList.fPairs then begin
  result:=fNext;
 end else begin
  result:=nil;
 end;
end;

{ TpvUInt64SkipList<TValue>.TNode }

constructor TpvUInt64SkipList<TValue>.TNode.Create(const aPrevious:TNode=nil;
                                                   const aNext:TNode=nil;
                                                   const aChildren:TNode=nil;
                                                   const aPair:TPair=nil);
begin
 inherited Create;
 fPrevious:=aPrevious;
 fNext:=aNext;
 fChildren:=aChildren;
 fPair:=aPair;
end;

destructor TpvUInt64SkipList<TValue>.TNode.Destroy;
begin
 if assigned(fPair) and not assigned(fChildren) then begin
  fPair.Free;
 end;
 inherited Destroy;
end;

{ TpvUInt64SkipList<TValue> }

constructor TpvUInt64SkipList<TValue>.Create(const aDefaultValue:TValue);
begin
 inherited Create;
 fRandomGeneratorState.State:=0;
 fRandomGeneratorState.Increment:=(TpvPtrUInt(TpvPointer(self)) shl 1) or 1;
 GetRandomValue;
 inc(fRandomGeneratorState.State,(TpvPtrUInt(TpvPointer(self)) shr 19) or (TpvPtrUInt(Pointer(self)) shl 13));
 GetRandomValue;
 fDefaultValue:=aDefaultValue;
 fHead:=TNode.Create;
 fPairs:=TPair.CreateEmpty(self);
end;

destructor TpvUInt64SkipList<TValue>.Destroy;
var Node,TemporaryHead,CurrentNode,NextNode:TNode;
begin
 Node:=fHead;
 while assigned(Node) do begin
  TemporaryHead:=Node;
  Node:=Node.fChildren;
  CurrentNode:=TemporaryHead;
  while assigned(CurrentNode) do begin
   NextNode:=CurrentNode.fNext;
   CurrentNode.Free;
   CurrentNode:=NextNode;
  end;
 end;
 while fPairs.fNext<>fPairs do begin
  fPairs.fNext.Free;
 end;
 fPairs.Free;
 inherited Destroy;
end;

function TpvUInt64SkipList<TValue>.GetRandomValue:TpvUInt32;
var RandomGeneratorState:TpvUInt64;
{$ifndef fpc}
    RandomGeneratorXorShifted,RandomGeneratorRotation:TpvUInt32;
{$endif}
begin
 RandomGeneratorState:=fRandomGeneratorState.State;
 fRandomGeneratorState.State:=(RandomGeneratorState*TpvUInt64(6364136223846793005))+fRandomGeneratorState.Increment;
{$ifdef fpc}
 result:=RORDWord(TpvUInt32(((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27),RandomGeneratorState shr 59);
{$else}
 RandomGeneratorXorShifted:=((RandomGeneratorState shr 18) xor RandomGeneratorState) shr 27;
 RandomGeneratorRotation:=RandomGeneratorState shr 59;
 result:=(RandomGeneratorXorShifted shr RandomGeneratorRotation) or (RandomGeneratorXorShifted shl (32-RandomGeneratorRotation));
{$endif}
end;

function TpvUInt64SkipList<TValue>.GetFirstPair:TPair;
begin
 result:=fPairs.fNext;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvUInt64SkipList<TValue>.GetLastPair:TPair;
begin
 result:=fPairs.fPrevious;
 if result=fPairs then begin
  result:=nil;
 end;
end;

function TpvUInt64SkipList<TValue>.FindPreviousNode(const aNode:TNode;const aKey:TKey):TNode;
var NextNode:TNode;
begin
 result:=aNode;
 while assigned(result) do begin
  NextNode:=result.fNext;
  if assigned(NextNode) and (NextNode.fPair.fKey<=aKey) then begin
   result:=NextNode;
  end else begin
   break;
  end;
 end;
end;

function TpvUInt64SkipList<TValue>.GetNearestPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair,BestPair:TPair;
begin
 BestPair:=fPairs.Next;
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) then begin
   BestPair:=Pair;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 if assigned(BestPair) and (BestPair<>fPairs) then begin
  result:=BestPair;
 end else begin
  result:=nil;
 end;
end;

function TpvUInt64SkipList<TValue>.GetNearestKey(const aKey:TKey):TKey;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fKey;
 end else begin
  result:=aKey;
 end;
end;

function TpvUInt64SkipList<TValue>.GetNearestValue(const aKey:TKey):TValue;
var Pair:TPair;
begin
 Pair:=GetNearestPair(aKey);
 if assigned(Pair) then begin
  result:=Pair.fValue;
 end else begin
  result:=fDefaultValue;
 end;
end;

function TpvUInt64SkipList<TValue>.Get(const aKey:TKey;out aValue:TValue):boolean;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   aValue:=Pair.fValue;
   result:=true;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=false;
end;

function TpvUInt64SkipList<TValue>.GetPair(const aKey:TKey):TPair;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   result:=Pair;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=nil;
end;

function TpvUInt64SkipList<TValue>.GetValue(const aKey:TKey):TValue;
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  Pair:=PreviousNode.fPair;
  if assigned(Pair) and (Pair.fKey=aKey) then begin
   result:=Pair.fValue;
   exit;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
 result:=fDefaultValue;
end;

procedure TpvUInt64SkipList<TValue>.SetValue(const aKey:TKey;const aValue:TValue);
var AllocatedPreviousNodes,CountPreviousNodes:TpvInt32;
    RandomGeneratorValue:TpvUInt32;
    CurrentNode,PreviousNode,NewNode:TNode;
    Pair,OtherPair:TPair;
    PreviousNodes:TNodeArray;
begin
 PreviousNodes:=nil;
 try
  CurrentNode:=fHead;
  AllocatedPreviousNodes:=0;
  CountPreviousNodes:=0;
  while assigned(CurrentNode) do begin
   PreviousNode:=FindPreviousNode(CurrentNode,aKey);
   if AllocatedPreviousNodes<=CountPreviousNodes then begin
    AllocatedPreviousNodes:=(CountPreviousNodes+1) shl 1;
    SetLength(PreviousNodes,AllocatedPreviousNodes);
   end;
   PreviousNodes[CountPreviousNodes]:=PreviousNode;
   inc(CountPreviousNodes);
   CurrentNode:=PreviousNode.fChildren;
  end;
  dec(CountPreviousNodes);
  PreviousNode:=PreviousNodes[CountPreviousNodes];
  if assigned(PreviousNode.fPair) and (PreviousNode.fPair.fKey=aKey) then begin
   PreviousNode.fPair.fValue:=aValue;
  end else begin
   if assigned(PreviousNode.fPair) and (PreviousNode.fPair.fNext<>fPairs) then begin
    OtherPair:=PreviousNode.fPair.fNext;
   end else begin
    if fPairs.fPrevious.fKey<aKey then begin
     OtherPair:=fPairs;
    end else begin
     OtherPair:=fPairs.fNext;
    end;
   end;
   Pair:=TPair.Create(self,aKey,aValue);
   Pair.fPrevious:=OtherPair.fPrevious;
   Pair.fNext:=OtherPair;
   Pair.fPrevious.fNext:=Pair;
   OtherPair.fPrevious:=Pair;
   NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,nil,Pair);
   if assigned(PreviousNode.fNext) then begin
    PreviousNode.fNext.fPrevious:=NewNode;
   end;
   PreviousNode.fNext:=NewNode;
   RandomGeneratorValue:=0;
   repeat
    if RandomGeneratorValue=0 then begin
     RandomGeneratorValue:=GetRandomValue;
    end;
    if (RandomGeneratorValue and 1)=0 then begin
     break;
    end else begin
     RandomGeneratorValue:=RandomGeneratorValue shr 1;
     if CountPreviousNodes>0 then begin
      dec(CountPreviousNodes);
      PreviousNode:=PreviousNodes[CountPreviousNodes];
     end else begin
      fHead:=TNode.Create(nil,nil,fHead);
      PreviousNode:=fHead;
     end;
     NewNode:=TNode.Create(PreviousNode,PreviousNode.fNext,NewNode,Pair);
     if assigned(PreviousNode.fNext) then begin
      PreviousNode.fNext.fPrevious:=NewNode;
     end;
     PreviousNode.fNext:=NewNode;
    end;
   until false;
  end;
 finally
  PreviousNodes:=nil;
 end;
end;

procedure TpvUInt64SkipList<TValue>.Delete(const aKey:TKey);
var CurrentNode,PreviousNode:TNode;
    Pair:TPair;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  PreviousNode:=FindPreviousNode(CurrentNode,aKey);
  if assigned(PreviousNode) then begin
   Pair:=PreviousNode.fPair;
   if assigned(Pair) and (Pair.fKey=aKey) then begin
    CurrentNode:=PreviousNode;
    repeat
     CurrentNode.fPrevious.fNext:=CurrentNode.fNext;
     if assigned(CurrentNode.fNext) then begin
      CurrentNode.fNext.fPrevious:=CurrentNode.fPrevious;
     end;
     PreviousNode:=CurrentNode;
     CurrentNode:=CurrentNode.fChildren;
     PreviousNode.Free;
    until not assigned(CurrentNode);
    break;
   end;
  end;
  CurrentNode:=PreviousNode.fChildren;
 end;
end;

function TpvUInt64SkipList<TValue>.GetEnumerator:TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

{ TpvGenericRedBlackTree<TKey,TValue>.TNode }

constructor TpvGenericRedBlackTree<TKey,TValue>.TNode.Create(const aKey:TKey;
                                                      const aValue:TValue;
                                                      const aLeft:TpvGenericRedBlackTree<TKey,TValue>.TNode;
                                                      const aRight:TpvGenericRedBlackTree<TKey,TValue>.TNode;
                                                      const aParent:TpvGenericRedBlackTree<TKey,TValue>.TNode;
                                                      const aColor:boolean);
begin
 inherited Create;
 fKey:=aKey;
 fValue:=aValue;
 fLeft:=aLeft;
 fRight:=aRight;
 fParent:=aParent;
 fColor:=aColor;
end;

destructor TpvGenericRedBlackTree<TKey,TValue>.TNode.Destroy;
begin
 FreeAndNil(fLeft);
 FreeAndNil(fRight);
 inherited Destroy;
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.TNode.Clear;
begin
 FillChar(fKey,SizeOf(TKey),#0);
 fLeft:=nil;
 fRight:=nil;
 fParent:=nil;
 fColor:=false;
end;

function TpvGenericRedBlackTree<TKey,TValue>.TNode.Minimum:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 result:=self;
 while assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvGenericRedBlackTree<TKey,TValue>.TNode.Maximum:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 result:=self;
 while assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

function TpvGenericRedBlackTree<TKey,TValue>.TNode.Predecessor:TpvGenericRedBlackTree<TKey,TValue>.TNode;
var Last:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 if assigned(fLeft) then begin
  result:=fLeft;
  while assigned(result) and assigned(result.fRight) do begin
   result:=result.fRight;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fLeft=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

function TpvGenericRedBlackTree<TKey,TValue>.TNode.Successor:TpvGenericRedBlackTree<TKey,TValue>.TNode;
var Last:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 if assigned(fRight) then begin
  result:=fRight;
  while assigned(result) and assigned(result.fLeft) do begin
   result:=result.fLeft;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fRight=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

{ TpvGenericRedBlackTree<TKey,TValue> }

constructor TpvGenericRedBlackTree<TKey,TValue>.Create;
begin
 inherited Create;
 fRoot:=nil;
end;

destructor TpvGenericRedBlackTree<TKey,TValue>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.Clear;
begin
 FreeAndNil(fRoot);
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.RotateLeft(x:TpvGenericRedBlackTree<TKey,TValue>.TNode);
var y:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 y:=x.fRight;
 x.fRight:=y.fLeft;
 if assigned(y.fLeft) then begin
  y.fLeft.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fLeft then begin
  x.fparent.fLeft:=y;
 end else begin
  x.fParent.fRight:=y;
 end;
 y.fLeft:=x;
 x.fParent:=y;
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.RotateRight(x:TpvGenericRedBlackTree<TKey,TValue>.TNode);
var y:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 y:=x.fLeft;
 x.fLeft:=y.fRight;
 if assigned(y.fRight) then begin
  y.fRight.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fRight then begin
  x.fParent.fRight:=y;
 end else begin
  x.fParent.fLeft:=y;
 end;
 y.fRight:=x;
 x.fParent:=y;
end;

function TpvGenericRedBlackTree<TKey,TValue>.Find(const aKey:TKey):TpvGenericRedBlackTree<TKey,TValue>.TNode;
var Value:TpvInt32;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 result:=fRoot;
 while assigned(result) do begin
  Value:=Comparer.Compare(aKey,result.fKey);
  if Value<0 then begin
   result:=result.fLeft;
  end else if Value>0 then begin
   result:=result.fRight;
  end else begin
   exit;
  end;
 end;
 result:=nil;
end;

function TpvGenericRedBlackTree<TKey,TValue>.Insert(const aKey:TKey;const aValue:TValue):TpvGenericRedBlackTree<TKey,TValue>.TNode;
var x,y,xParentParent:TpvGenericRedBlackTree<TKey,TValue>.TNode;
    Comparer:IComparer<TKey>;
begin
 Comparer:=TComparer<TKey>.Default;
 x:=fRoot;
 y:=nil;
 while assigned(x) do begin
  y:=x;
  if Comparer.Compare(aKey,x.fKey)<0 then begin
   x:=x.fLeft;
  end else begin
   x:=x.fRight;
  end;
 end;
 result:=TpvGenericRedBlackTree<TKey,TValue>.TNode.Create(aKey,aValue,nil,nil,y,true);
 if assigned(y) then begin
  if Comparer.Compare(aKey,y.fKey)<0 then begin
   y.Left:=result;
  end else begin
   y.Right:=result;
  end;
 end else begin
  fRoot:=result;
 end;
 x:=result;
 while (x<>fRoot) and assigned(x.fParent) and assigned(x.fParent.fParent) and x.fParent.fColor do begin
  xParentParent:=x.fParent.fParent;
  if x.fParent=xParentParent.fLeft then begin
   y:=xParentParent.fRight;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    xParentParent.fColor:=true;
    x:=xParentParent;
   end else begin
    if x=x.fParent.fRight then begin
     x:=x.fParent;
     RotateLeft(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateRight(xParentParent);
   end;
  end else begin
   y:=xParentParent.fLeft;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    x.fParent.fParent.fColor:=true;
    x:=x.fParent.fParent;
   end else begin
    if x=x.fParent.fLeft then begin
     x:=x.fParent;
     RotateRight(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateLeft(xParentParent);
   end;
  end;
 end;
 fRoot.fColor:=false;
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.Remove(const aNode:TpvGenericRedBlackTree<TKey,TValue>.TNode);
var w,x,y,z,xParent:TpvGenericRedBlackTree<TKey,TValue>.TNode;
    TemporaryColor:boolean;
begin
 z:=aNode;
 y:=z;
 x:=nil;
 xParent:=nil;
 if assigned(x) and assigned(xParent) then begin
  // For to suppress "Value assigned to '*' never used" hints
 end;
 if assigned(y.fLeft) then begin
  if assigned(y.fRight) then begin
   y:=y.fRight;
   while assigned(y.fLeft) do begin
    y:=y.fLeft;
   end;
   x:=y.fRight;
  end else begin
   x:=y.fLeft;
  end;
 end else begin
  x:=y.fRight;
 end;
 if y<>z then begin
  z.fLeft.fParent:=y;
  y.fLeft:=z.fLeft;
  if y<>z.fRight then begin
   xParent:=y.fParent;
   if assigned(x) then begin
    x.fParent:=y.fParent;
   end;
   y.fParent.fLeft:=x;
   y.fRight:=z.fRight;
   z.fRight.fParent:=y;
  end else begin
   xParent:=y;
  end;
  if fRoot=z then begin
   fRoot:=y;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=y;
  end else begin
   z.fParent.fRight:=y;
  end;
  y.fParent:=z.fParent;
  TemporaryColor:=y.fColor;
  y.fColor:=z.fColor;
  z.fColor:=TemporaryColor;
  y:=z;
 end else begin
  xParent:=y.fParent;
  if assigned(x) then begin
   x.fParent:=y.fParent;
  end;
  if fRoot=z then begin
   fRoot:=x;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=x;
  end else begin
   z.fParent.fRight:=x;
  end;
 end;
 if assigned(y) then begin
  if not y.fColor then begin
   while (x<>fRoot) and not (assigned(x) and x.fColor) do begin
    if x=xParent.fLeft then begin
     w:=xParent.fRight;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateLeft(xParent);
      w:=xParent.fRight;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fRight) and w.fRight.fColor) then begin
       w.fLeft.fColor:=false;
       w.fColor:=true;
       RotateRight(w);
       w:=xParent.fRight;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fRight) then begin
       w.fRight.fColor:=false;
      end;
      RotateLeft(xParent);
      x:=fRoot;
     end;
    end else begin
     w:=xParent.fLeft;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateRight(xParent);
      w:=xParent.fLeft;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fLeft) and w.fLeft.fColor) then begin
       w.fRight.fColor:=false;
       w.fColor:=true;
       RotateLeft(w);
       w:=xParent.fLeft;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fLeft) then begin
       w.fLeft.fColor:=false;
      end;
      RotateRight(xParent);
      x:=fRoot;
     end;
    end;
   end;
   if assigned(x) then begin
    x.fColor:=false;
   end;
  end;
  y.Clear;
  y.Free;
 end;
end;

procedure TpvGenericRedBlackTree<TKey,TValue>.Delete(const aKey:TKey);
var Node:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 Node:=Find(aKey);
 if assigned(Node) then begin
  Remove(Node);
 end;
end;

function TpvGenericRedBlackTree<TKey,TValue>.LeftMost:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvGenericRedBlackTree<TKey,TValue>.RightMost:TpvGenericRedBlackTree<TKey,TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

{ TpvInt64RedBlackTree<TValue>.TNode }

constructor TpvInt64RedBlackTree<TValue>.TNode.Create(const aKey:TKey;
                                                      const aValue:TValue;
                                                      const aLeft:TpvInt64RedBlackTree<TValue>.TNode;
                                                      const aRight:TpvInt64RedBlackTree<TValue>.TNode;
                                                      const aParent:TpvInt64RedBlackTree<TValue>.TNode;
                                                      const aColor:boolean);
begin
 inherited Create;
 fKey:=aKey;
 fValue:=aValue;
 fLeft:=aLeft;
 fRight:=aRight;
 fParent:=aParent;
 fColor:=aColor;
end;

destructor TpvInt64RedBlackTree<TValue>.TNode.Destroy;
begin
 FreeAndNil(fLeft);
 FreeAndNil(fRight);
 inherited Destroy;
end;

procedure TpvInt64RedBlackTree<TValue>.TNode.Clear;
begin
 fKey:=0;
 fLeft:=nil;
 fRight:=nil;
 fParent:=nil;
 fColor:=false;
end;

function TpvInt64RedBlackTree<TValue>.TNode.Minimum:TpvInt64RedBlackTree<TValue>.TNode;
begin
 result:=self;
 while assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvInt64RedBlackTree<TValue>.TNode.Maximum:TpvInt64RedBlackTree<TValue>.TNode;
begin
 result:=self;
 while assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

function TpvInt64RedBlackTree<TValue>.TNode.Predecessor:TpvInt64RedBlackTree<TValue>.TNode;
var Last:TpvInt64RedBlackTree<TValue>.TNode;
begin
 if assigned(fLeft) then begin
  result:=fLeft;
  while assigned(result) and assigned(result.fRight) do begin
   result:=result.fRight;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fLeft=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

function TpvInt64RedBlackTree<TValue>.TNode.Successor:TpvInt64RedBlackTree<TValue>.TNode;
var Last:TpvInt64RedBlackTree<TValue>.TNode;
begin
 if assigned(fRight) then begin
  result:=fRight;
  while assigned(result) and assigned(result.fLeft) do begin
   result:=result.fLeft;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fRight=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

{ TpvInt64RedBlackTree<TValue> }

constructor TpvInt64RedBlackTree<TValue>.Create;
begin
 inherited Create;
 fRoot:=nil;
end;

destructor TpvInt64RedBlackTree<TValue>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvInt64RedBlackTree<TValue>.Clear;
begin
 FreeAndNil(fRoot);
end;

procedure TpvInt64RedBlackTree<TValue>.RotateLeft(x:TpvInt64RedBlackTree<TValue>.TNode);
var y:TpvInt64RedBlackTree<TValue>.TNode;
begin
 y:=x.fRight;
 x.fRight:=y.fLeft;
 if assigned(y.fLeft) then begin
  y.fLeft.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fLeft then begin
  x.fparent.fLeft:=y;
 end else begin
  x.fParent.fRight:=y;
 end;
 y.fLeft:=x;
 x.fParent:=y;
end;

procedure TpvInt64RedBlackTree<TValue>.RotateRight(x:TpvInt64RedBlackTree<TValue>.TNode);
var y:TpvInt64RedBlackTree<TValue>.TNode;
begin
 y:=x.fLeft;
 x.fLeft:=y.fRight;
 if assigned(y.fRight) then begin
  y.fRight.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fRight then begin
  x.fParent.fRight:=y;
 end else begin
  x.fParent.fLeft:=y;
 end;
 y.fRight:=x;
 x.fParent:=y;
end;

function TpvInt64RedBlackTree<TValue>.Find(const aKey:TKey):TpvInt64RedBlackTree<TValue>.TNode;
var Value:TpvInt32;
begin
 result:=fRoot;
 while assigned(result) do begin
  if aKey<result.fKey then begin
   result:=result.fLeft;
  end else if aKey>result.fKey then begin
   result:=result.fRight;
  end else begin
   exit;
  end;
 end;
 result:=nil;
end;

function TpvInt64RedBlackTree<TValue>.Insert(const aKey:TKey;const aValue:TValue):TpvInt64RedBlackTree<TValue>.TNode;
var x,y,xParentParent:TpvInt64RedBlackTree<TValue>.TNode;
begin
 x:=fRoot;
 y:=nil;
 while assigned(x) do begin
  y:=x;
  if aKey<x.fKey then begin
   x:=x.fLeft;
  end else begin
   x:=x.fRight;
  end;
 end;
 result:=TpvInt64RedBlackTree<TValue>.TNode.Create(aKey,aValue,nil,nil,y,true);
 if assigned(y) then begin
  if aKey<y.fKey then begin
   y.Left:=result;
  end else begin
   y.Right:=result;
  end;
 end else begin
  fRoot:=result;
 end;
 x:=result;
 while (x<>fRoot) and assigned(x.fParent) and assigned(x.fParent.fParent) and x.fParent.fColor do begin
  xParentParent:=x.fParent.fParent;
  if x.fParent=xParentParent.fLeft then begin
   y:=xParentParent.fRight;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    xParentParent.fColor:=true;
    x:=xParentParent;
   end else begin
    if x=x.fParent.fRight then begin
     x:=x.fParent;
     RotateLeft(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateRight(xParentParent);
   end;
  end else begin
   y:=xParentParent.fLeft;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    x.fParent.fParent.fColor:=true;
    x:=x.fParent.fParent;
   end else begin
    if x=x.fParent.fLeft then begin
     x:=x.fParent;
     RotateRight(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateLeft(xParentParent);
   end;
  end;
 end;
 fRoot.fColor:=false;
end;

procedure TpvInt64RedBlackTree<TValue>.Remove(const aNode:TpvInt64RedBlackTree<TValue>.TNode);
var w,x,y,z,xParent:TpvInt64RedBlackTree<TValue>.TNode;
    TemporaryColor:boolean;
begin
 z:=aNode;
 y:=z;
 x:=nil;
 xParent:=nil;
 if assigned(x) and assigned(xParent) then begin
  // For to suppress "Value assigned to '*' never used" hints
 end;
 if assigned(y.fLeft) then begin
  if assigned(y.fRight) then begin
   y:=y.fRight;
   while assigned(y.fLeft) do begin
    y:=y.fLeft;
   end;
   x:=y.fRight;
  end else begin
   x:=y.fLeft;
  end;
 end else begin
  x:=y.fRight;
 end;
 if y<>z then begin
  z.fLeft.fParent:=y;
  y.fLeft:=z.fLeft;
  if y<>z.fRight then begin
   xParent:=y.fParent;
   if assigned(x) then begin
    x.fParent:=y.fParent;
   end;
   y.fParent.fLeft:=x;
   y.fRight:=z.fRight;
   z.fRight.fParent:=y;
  end else begin
   xParent:=y;
  end;
  if fRoot=z then begin
   fRoot:=y;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=y;
  end else begin
   z.fParent.fRight:=y;
  end;
  y.fParent:=z.fParent;
  TemporaryColor:=y.fColor;
  y.fColor:=z.fColor;
  z.fColor:=TemporaryColor;
  y:=z;
 end else begin
  xParent:=y.fParent;
  if assigned(x) then begin
   x.fParent:=y.fParent;
  end;
  if fRoot=z then begin
   fRoot:=x;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=x;
  end else begin
   z.fParent.fRight:=x;
  end;
 end;
 if assigned(y) then begin
  if not y.fColor then begin
   while (x<>fRoot) and not (assigned(x) and x.fColor) do begin
    if x=xParent.fLeft then begin
     w:=xParent.fRight;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateLeft(xParent);
      w:=xParent.fRight;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fRight) and w.fRight.fColor) then begin
       w.fLeft.fColor:=false;
       w.fColor:=true;
       RotateRight(w);
       w:=xParent.fRight;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fRight) then begin
       w.fRight.fColor:=false;
      end;
      RotateLeft(xParent);
      x:=fRoot;
     end;
    end else begin
     w:=xParent.fLeft;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateRight(xParent);
      w:=xParent.fLeft;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fLeft) and w.fLeft.fColor) then begin
       w.fRight.fColor:=false;
       w.fColor:=true;
       RotateLeft(w);
       w:=xParent.fLeft;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fLeft) then begin
       w.fLeft.fColor:=false;
      end;
      RotateRight(xParent);
      x:=fRoot;
     end;
    end;
   end;
   if assigned(x) then begin
    x.fColor:=false;
   end;
  end;
  y.Clear;
  y.Free;
 end;
end;

procedure TpvInt64RedBlackTree<TValue>.Delete(const aKey:TKey);
var Node:TpvInt64RedBlackTree<TValue>.TNode;
begin
 Node:=Find(aKey);
 if assigned(Node) then begin
  Remove(Node);
 end;
end;

function TpvInt64RedBlackTree<TValue>.LeftMost:TpvInt64RedBlackTree<TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvInt64RedBlackTree<TValue>.RightMost:TpvInt64RedBlackTree<TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

{ TpvUInt64RedBlackTree<TValue>.TNode }

constructor TpvUInt64RedBlackTree<TValue>.TNode.Create(const aKey:TKey;
                                                       const aValue:TValue;
                                                       const aLeft:TpvUInt64RedBlackTree<TValue>.TNode;
                                                       const aRight:TpvUInt64RedBlackTree<TValue>.TNode;
                                                       const aParent:TpvUInt64RedBlackTree<TValue>.TNode;
                                                       const aColor:boolean);
begin
 inherited Create;
 fKey:=aKey;
 fValue:=aValue;
 fLeft:=aLeft;
 fRight:=aRight;
 fParent:=aParent;
 fColor:=aColor;
end;

destructor TpvUInt64RedBlackTree<TValue>.TNode.Destroy;
begin
 FreeAndNil(fLeft);
 FreeAndNil(fRight);
 inherited Destroy;
end;

procedure TpvUInt64RedBlackTree<TValue>.TNode.Clear;
begin
 fKey:=0;
 fLeft:=nil;
 fRight:=nil;
 fParent:=nil;
 fColor:=false;
end;

function TpvUInt64RedBlackTree<TValue>.TNode.Minimum:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 result:=self;
 while assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvUInt64RedBlackTree<TValue>.TNode.Maximum:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 result:=self;
 while assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

function TpvUInt64RedBlackTree<TValue>.TNode.Predecessor:TpvUInt64RedBlackTree<TValue>.TNode;
var Last:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 if assigned(fLeft) then begin
  result:=fLeft;
  while assigned(result) and assigned(result.fRight) do begin
   result:=result.fRight;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fLeft=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

function TpvUInt64RedBlackTree<TValue>.TNode.Successor:TpvUInt64RedBlackTree<TValue>.TNode;
var Last:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 if assigned(fRight) then begin
  result:=fRight;
  while assigned(result) and assigned(result.fLeft) do begin
   result:=result.fLeft;
  end;
 end else begin
  Last:=self;
  result:=Parent;
  while assigned(result) and (result.fRight=Last) do begin
   Last:=result;
   result:=result.Parent;
  end;
 end;
end;

{ TpvUInt64RedBlackTree<TValue> }

constructor TpvUInt64RedBlackTree<TValue>.Create;
begin
 inherited Create;
 fRoot:=nil;
end;

destructor TpvUInt64RedBlackTree<TValue>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvUInt64RedBlackTree<TValue>.Clear;
begin
 FreeAndNil(fRoot);
end;

procedure TpvUInt64RedBlackTree<TValue>.RotateLeft(x:TpvUInt64RedBlackTree<TValue>.TNode);
var y:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 y:=x.fRight;
 x.fRight:=y.fLeft;
 if assigned(y.fLeft) then begin
  y.fLeft.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fLeft then begin
  x.fparent.fLeft:=y;
 end else begin
  x.fParent.fRight:=y;
 end;
 y.fLeft:=x;
 x.fParent:=y;
end;

procedure TpvUInt64RedBlackTree<TValue>.RotateRight(x:TpvUInt64RedBlackTree<TValue>.TNode);
var y:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 y:=x.fLeft;
 x.fLeft:=y.fRight;
 if assigned(y.fRight) then begin
  y.fRight.fParent:=x;
 end;
 y.fParent:=x.fParent;
 if x=fRoot then begin
  fRoot:=y;
 end else if x=x.fParent.fRight then begin
  x.fParent.fRight:=y;
 end else begin
  x.fParent.fLeft:=y;
 end;
 y.fRight:=x;
 x.fParent:=y;
end;

function TpvUInt64RedBlackTree<TValue>.Find(const aKey:TKey):TpvUInt64RedBlackTree<TValue>.TNode;
var Value:TpvInt32;
begin
 result:=fRoot;
 while assigned(result) do begin
  if aKey<result.fKey then begin
   result:=result.fLeft;
  end else if aKey>result.fKey then begin
   result:=result.fRight;
  end else begin
   exit;
  end;
 end;
 result:=nil;
end;

function TpvUInt64RedBlackTree<TValue>.Insert(const aKey:TKey;const aValue:TValue):TpvUInt64RedBlackTree<TValue>.TNode;
var x,y,xParentParent:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 x:=fRoot;
 y:=nil;
 while assigned(x) do begin
  y:=x;
  if aKey<x.fKey then begin
   x:=x.fLeft;
  end else begin
   x:=x.fRight;
  end;
 end;
 result:=TpvUInt64RedBlackTree<TValue>.TNode.Create(aKey,aValue,nil,nil,y,true);
 if assigned(y) then begin
  if aKey<y.fKey then begin
   y.Left:=result;
  end else begin
   y.Right:=result;
  end;
 end else begin
  fRoot:=result;
 end;
 x:=result;
 while (x<>fRoot) and assigned(x.fParent) and assigned(x.fParent.fParent) and x.fParent.fColor do begin
  xParentParent:=x.fParent.fParent;
  if x.fParent=xParentParent.fLeft then begin
   y:=xParentParent.fRight;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    xParentParent.fColor:=true;
    x:=xParentParent;
   end else begin
    if x=x.fParent.fRight then begin
     x:=x.fParent;
     RotateLeft(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateRight(xParentParent);
   end;
  end else begin
   y:=xParentParent.fLeft;
   if assigned(y) and y.fColor then begin
    x.fParent.fColor:=false;
    y.fColor:=false;
    x.fParent.fParent.fColor:=true;
    x:=x.fParent.fParent;
   end else begin
    if x=x.fParent.fLeft then begin
     x:=x.fParent;
     RotateRight(x);
    end;
    x.fParent.fColor:=false;
    xParentParent.fColor:=true;
    RotateLeft(xParentParent);
   end;
  end;
 end;
 fRoot.fColor:=false;
end;

procedure TpvUInt64RedBlackTree<TValue>.Remove(const aNode:TpvUInt64RedBlackTree<TValue>.TNode);
var w,x,y,z,xParent:TpvUInt64RedBlackTree<TValue>.TNode;
    TemporaryColor:boolean;
begin
 z:=aNode;
 y:=z;
 x:=nil;
 xParent:=nil;
 if assigned(x) and assigned(xParent) then begin
  // For to suppress "Value assigned to '*' never used" hints
 end;
 if assigned(y.fLeft) then begin
  if assigned(y.fRight) then begin
   y:=y.fRight;
   while assigned(y.fLeft) do begin
    y:=y.fLeft;
   end;
   x:=y.fRight;
  end else begin
   x:=y.fLeft;
  end;
 end else begin
  x:=y.fRight;
 end;
 if y<>z then begin
  z.fLeft.fParent:=y;
  y.fLeft:=z.fLeft;
  if y<>z.fRight then begin
   xParent:=y.fParent;
   if assigned(x) then begin
    x.fParent:=y.fParent;
   end;
   y.fParent.fLeft:=x;
   y.fRight:=z.fRight;
   z.fRight.fParent:=y;
  end else begin
   xParent:=y;
  end;
  if fRoot=z then begin
   fRoot:=y;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=y;
  end else begin
   z.fParent.fRight:=y;
  end;
  y.fParent:=z.fParent;
  TemporaryColor:=y.fColor;
  y.fColor:=z.fColor;
  z.fColor:=TemporaryColor;
  y:=z;
 end else begin
  xParent:=y.fParent;
  if assigned(x) then begin
   x.fParent:=y.fParent;
  end;
  if fRoot=z then begin
   fRoot:=x;
  end else if z.fParent.fLeft=z then begin
   z.fParent.fLeft:=x;
  end else begin
   z.fParent.fRight:=x;
  end;
 end;
 if assigned(y) then begin
  if not y.fColor then begin
   while (x<>fRoot) and not (assigned(x) and x.fColor) do begin
    if x=xParent.fLeft then begin
     w:=xParent.fRight;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateLeft(xParent);
      w:=xParent.fRight;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fRight) and w.fRight.fColor) then begin
       w.fLeft.fColor:=false;
       w.fColor:=true;
       RotateRight(w);
       w:=xParent.fRight;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fRight) then begin
       w.fRight.fColor:=false;
      end;
      RotateLeft(xParent);
      x:=fRoot;
     end;
    end else begin
     w:=xParent.fLeft;
     if w.fColor then begin
      w.fColor:=false;
      xParent.fColor:=true;
      RotateRight(xParent);
      w:=xParent.fLeft;
     end;
     if not ((assigned(w.fLeft) and w.fLeft.fColor) or (assigned(w.fRight) and w.fRight.fColor)) then begin
      w.fColor:=true;
      x:=xParent;
      xParent:=xParent.fParent;
     end else begin
      if not (assigned(w.fLeft) and w.fLeft.fColor) then begin
       w.fRight.fColor:=false;
       w.fColor:=true;
       RotateLeft(w);
       w:=xParent.fLeft;
      end;
      w.fColor:=xParent.fColor;
      xParent.fColor:=false;
      if assigned(w.fLeft) then begin
       w.fLeft.fColor:=false;
      end;
      RotateRight(xParent);
      x:=fRoot;
     end;
    end;
   end;
   if assigned(x) then begin
    x.fColor:=false;
   end;
  end;
  y.Clear;
  y.Free;
 end;
end;

procedure TpvUInt64RedBlackTree<TValue>.Delete(const aKey:TKey);
var Node:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 Node:=Find(aKey);
 if assigned(Node) then begin
  Remove(Node);
 end;
end;

function TpvUInt64RedBlackTree<TValue>.LeftMost:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fLeft) do begin
  result:=result.fLeft;
 end;
end;

function TpvUInt64RedBlackTree<TValue>.RightMost:TpvUInt64RedBlackTree<TValue>.TNode;
begin
 result:=fRoot;
 while assigned(result) and assigned(result.fRight) do begin
  result:=result.fRight;
 end;
end;

end.

