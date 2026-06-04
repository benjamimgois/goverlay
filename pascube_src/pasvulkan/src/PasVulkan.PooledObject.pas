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
unit PasVulkan.PooledObject;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

{$if defined(Windows)}
 {$undef UseHashMaps}
{$else}
 {$define UseHashMaps}
{$ifend}

interface

uses {$if defined(Windows)}
      Windows,
     {$elseif defined(fpc) and not defined(UseHashMaps)}
      dl,
      BaseUnix,
      Unix,
      UnixType,
     {$ifend}
     SysUtils,
     Classes,
     PasMP,
     PasVulkan.Types;

const PooledObjectPoolBucketSize=1024;

      PooledObjectPoolAlignment=16;

type EpvPooledObjectException=class(Exception);

     TpvPooledObjectPool=class;

     TpvPooledObjectPoolBucket=class;

     PpvPooledObjectPoolBucketItem=^TpvPooledObjectPoolBucketItem;
     TpvPooledObjectPoolBucketItem=record // must be 16-byte aligned for the combined Parent and Color storage
      PoolBucket:TpvPooledObjectPoolBucket;
      Next:PpvPooledObjectPoolBucketItem;
     end;

     PpvPooledObjectPoolBucketItems=^TpvPooledObjectPoolBucketItems;
     TpvPooledObjectPoolBucketItems=array[0..65535] of TpvPooledObjectPoolBucketItem;

     TpvPooledObjectPoolBucket=class(TObject)
      private
       fPool:TpvPooledObjectPool;
       fPoolBucketMemoryUnaligned:pointer;
       fPoolBucketPrevious:TpvPooledObjectPoolBucket;
       fPoolBucketNext:TpvPooledObjectPoolBucket;
       fPoolBucketFreePrevious:TpvPooledObjectPoolBucket;
       fPoolBucketFreeNext:TpvPooledObjectPoolBucket;
       fPoolBucketItems:PpvPooledObjectPoolBucketItems;
       fPoolBucketMemory:pointer;
       fPoolCountAllocatedItems:TpvSizeInt;
       fPoolBucketItemFreeRoot:PpvPooledObjectPoolBucketItem;
       fIsOnFreeList:longbool;
      protected
       procedure AddToFreeList;
       procedure RemoveFromFreeList;
       procedure AddFreeBucketItem(const ABucketItem:PpvPooledObjectPoolBucketItem);
       function GetFreeBucketItem:PpvPooledObjectPoolBucketItem;
      public
       constructor Create(const APool:TpvPooledObjectPool);
       destructor Destroy; override;
       property Memory:pointer read fPoolBucketMemory;
      published
       property Pool:TpvPooledObjectPool read fPool;
     end;

     TpvPooledObjectPool=class(TObject)
      private
       fPoolLock:TPasMPSlimReaderWriterLock;
       fPoolClassType:TClass;
       fPoolClassInstanceSize:TpvSizeInt;
       fPoolBucketSize:TpvSizeInt;
       fPoolAlignment:TpvSizeInt;
       fPoolAlignmentMask:TpvSizeInt;
       fPoolAlignedClassInstanceSize:TpvSizeInt;
       fPoolBucketFirst:TpvPooledObjectPoolBucket;
       fPoolBucketLast:TpvPooledObjectPoolBucket;
       fPoolBucketFreeFirst:TpvPooledObjectPoolBucket;
       fPoolBucketFreeLast:TpvPooledObjectPoolBucket;
      public
       constructor Create(const aPoolClassType:TClass;const aPoolBucketSize:TpvSizeInt=PooledObjectPoolBucketSize;const aPoolAlignment:TpvSizeInt=PooledObjectPoolAlignment);
       destructor Destroy; override;
       function AllocateObject:pointer;
       procedure FreeObject(const aInstance:pointer);
      published
       property PoolClassType:TClass read fPoolClassType;
       property PoolClassInstanceSize:TpvSizeInt read fPoolClassInstanceSize;
       property PoolBucketSize:TpvSizeInt read fPoolBucketSize;
       property PoolAlignment:TpvSizeInt read fPoolAlignment;
       property PoolAlignmentMask:TpvSizeInt read fPoolAlignmentMask;
       property PoolAlignedClassInstanceSize:TpvSizeInt read fPoolAlignedClassInstanceSize;
     end;

     PPpvPooledObjectClassMetaInfo=^PpvPooledObjectClassMetaInfo;
     PpvPooledObjectClassMetaInfo=^TpvPooledObjectClassMetaInfo;
     TpvPooledObjectClassMetaInfo=record
      Pool:TpvPooledObjectPool;
      ID:TpvPtrInt;
     end;

     TpvPooledObjectPoolManager=class(TObject)
      private
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fObjectPoolList:TList;
       fObjectClassMetaInfoList:TList;
      public
       constructor Create;
       destructor Destroy; override;
       procedure AllocateObjectClassMetaInfo(const AClassType:TClass);
       function AllocateObject(const AClassType:TClass):pointer;
       procedure FreeObject(const aInstance:TObject);
     end;

     TpvPooledObject=class(TpvObject)
      public
       class function GetClassMetaInfo:pointer; //inline;
       class procedure InitializeObjectClassMetaInfo;
       class function NewInstance:TObject; override;
       procedure FreeInstance; override;
     end;

     TpvPooledObjectClass=class of TpvPooledObject;

implementation

{$ifdef UseHashMaps}
const PooledObjectClassMetaInfoHashBits=16;
      PooledObjectClassMetaInfoHashSize=1 shl PooledObjectClassMetaInfoHashBits;
      PooledObjectClassMetaInfoHashMask=PooledObjectClassMetaInfoHashSize-1;

type PpvPooledObjectClassMetaInfoHashItem=^TpvPooledObjectClassMetaInfoHashItem;
     TpvPooledObjectClassMetaInfoHashItem=record
      HashItemNext:PpvPooledObjectClassMetaInfoHashItem;
      AllocatedNext:PpvPooledObjectClassMetaInfoHashItem;
      PooledObjectClass:TpvPooledObjectClass;
      PooledObjectClassMetaInfo:TpvPooledObjectClassMetaInfo;
     end;

     PPpvPooledObjectClassMetaInfoHashItems=^TPpvPooledObjectClassMetaInfoHashItems;
     TPpvPooledObjectClassMetaInfoHashItems=array[0..PooledObjectClassMetaInfoHashSize-1] of PpvPooledObjectClassMetaInfoHashItem;

var PooledObjectClassMetaInfoHashItems:TPpvPooledObjectClassMetaInfoHashItems;
    AllocatedPooledObjectClassMetaInfoHashItems:PpvPooledObjectClassMetaInfoHashItem=nil;

function HashPointer(const Key:pointer):TpvUInt32;
{$ifdef cpu64}
var p:TpvUInt64;
{$endif}
begin
{$ifdef cpu64}
 // 64-bit big => use 64-bit integer-rehashing
 p:=TpvUInt64(pointer(@Key)^);
 p:=(not p)+(p shl 18); // p:=((p shl 18)-p-)1;
 p:=p xor (p shr 31);
 p:=p*21; // p:=(p+(p shl 2))+(p shl 4);
 p:=p xor (p shr 11);
 p:=p+(p shl 6);
 result:=TpvUInt32(TpvPtrUInt(p xor (p shr 22)));
{$else}
 // 32-bit big => use 32-bit integer-rehashing
 result:=TpvUInt32(pointer(@Key)^);
 dec(result,result shl 6);
 result:=result xor (result shr 17);
 dec(result,result shl 9);
 result:=result xor (result shl 4);
 dec(result,result shl 3);
 result:=result xor (result shl 10);
 result:=result xor (result shr 15);
{$endif}
end;
{$endif}

var PooledObjectPoolManager:TpvPooledObjectPoolManager=nil;

{$ifndef UseHashMaps}
{$ifdef unix}
    fpmprotect:function(__addr:pointer;__len:cardinal;__prot:TpvInt32):TpvInt32; cdecl;// external 'c' name 'mprotect';
{$endif}
{$endif}

function RoundUpToPowerOfTwo(Value:TpvPtrUInt):TpvPtrUInt;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
{$ifdef CPU64}
 Value:=Value or (Value shr 32);
{$endif}
 result:=Value+1;
end;

constructor TpvPooledObjectPoolBucket.Create(const APool:TpvPooledObjectPool);
var Index:TpvSizeInt;
    PoolBucketItem:PpvPooledObjectPoolBucketItem;
    ItemsSize,MemorySize,Size:TpvPtrUInt;
begin

 inherited Create;

 fPool:=APool;

 ItemsSize:=(fPool.fPoolBucketSize*SizeOf(TpvPooledObjectPoolBucketItem))+32;
 MemorySize:=(fPool.fPoolAlignedClassInstanceSize*fPool.fPoolBucketSize)+(fPool.fPoolAlignment*2);

 Size:=ItemsSize+MemorySize;
 GetMem(fPoolBucketMemoryUnaligned,Size);
 FillChar(fPoolBucketMemoryUnaligned^,Size,#0);

 fPoolBucketItems:=pointer(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(fPoolBucketMemoryUnaligned)))+TpvPtrUInt(15)) and not TpvPtrUInt(15)));
 fPoolBucketMemory:=pointer(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(fPoolBucketMemoryUnaligned)+ItemsSize))+TpvPtrUInt(fPool.fPoolAlignmentMask)) and not TpvPtrUInt(fPool.fPoolAlignmentMask)));

 fPoolCountAllocatedItems:=0;

 fIsOnFreeList:=false;

 fPoolBucketItemFreeRoot:=nil;
 for Index:=fPool.fPoolBucketSize-1 downto 0 do begin
  PoolBucketItem:=@fPoolBucketItems^[Index];
  PoolBucketItem^.PoolBucket:=self;
  AddFreeBucketItem(PoolBucketItem);
 end;
 if assigned(fPool.fPoolBucketLast) then begin
  fPool.fPoolBucketLast.fPoolBucketNext:=self;
  fPoolBucketPrevious:=self;
 end else begin
  fPool.fPoolBucketFirst:=self;
  fPoolBucketPrevious:=nil;
 end;
 fPool.fPoolBucketLast:=self;

 fPoolBucketNext:=nil;
 AddToFreeList;

end;

destructor TpvPooledObjectPoolBucket.Destroy;
begin

 RemoveFromFreeList;

 FreeMem(fPoolBucketMemoryUnaligned);

 if assigned(fPoolBucketPrevious) then begin
  fPoolBucketPrevious.fPoolBucketNext:=fPoolBucketNext;
 end else if fPool.fPoolBucketFirst=self then begin
  fPool.fPoolBucketFirst:=fPoolBucketNext;
 end;
 if assigned(fPoolBucketNext) then begin
  fPoolBucketNext.fPoolBucketPrevious:=fPoolBucketPrevious;
 end else if fPool.fPoolBucketLast=self then begin
  fPool.fPoolBucketLast:=fPoolBucketPrevious;
 end;

 inherited Destroy;

end;

procedure TpvPooledObjectPoolBucket.AddToFreeList;
begin
 if not fIsOnFreeList then begin
  fIsOnFreeList:=true;
  if assigned(fPool.fPoolBucketFreeLast) then begin
   fPool.fPoolBucketFreeLast.fPoolBucketFreeNext:=self;
   fPoolBucketFreePrevious:=self;
  end else begin
   fPool.fPoolBucketFreeFirst:=self;
   fPoolBucketFreePrevious:=nil;
  end;
  fPool.fPoolBucketFreeLast:=self;
  fPoolBucketFreeNext:=nil;
 end;
end;

procedure TpvPooledObjectPoolBucket.RemoveFromFreeList;
begin
 if fIsOnFreeList then begin
  fIsOnFreeList:=false;
  if assigned(fPoolBucketFreePrevious) then begin
   fPoolBucketFreePrevious.fPoolBucketFreeNext:=fPoolBucketFreeNext;
  end else if fPool.fPoolBucketFreeFirst=self then begin
   fPool.fPoolBucketFreeFirst:=fPoolBucketFreeNext;
  end;
  if assigned(fPoolBucketFreeNext) then begin
   fPoolBucketFreeNext.fPoolBucketFreePrevious:=fPoolBucketFreePrevious;
  end else if fPool.fPoolBucketFreeLast=self then begin
   fPool.fPoolBucketFreeLast:=fPoolBucketFreePrevious;
  end;
 end;
end;

procedure TpvPooledObjectPoolBucket.AddFreeBucketItem(const ABucketItem:PpvPooledObjectPoolBucketItem);
begin
 ABucketItem^.Next:=fPoolBucketItemFreeRoot;
 fPoolBucketItemFreeRoot:=ABucketItem;
 if not fIsOnFreeList then begin
  AddToFreeList;
 end;
end;

function TpvPooledObjectPoolBucket.GetFreeBucketItem:PpvPooledObjectPoolBucketItem;
begin
 result:=fPoolBucketItemFreeRoot;
 if assigned(result) then begin
  fPoolBucketItemFreeRoot:=result^.Next;
 end;
 if fIsOnFreeList and not assigned(fPoolBucketItemFreeRoot) then begin
  RemoveFromFreeList;
 end;
end;

constructor TpvPooledObjectPool.Create(const aPoolClassType:TClass;const aPoolBucketSize:TpvSizeInt=PooledObjectPoolBucketSize;const aPoolAlignment:TpvSizeInt=PooledObjectPoolAlignment);
begin
 inherited Create;
 fPoolLock:=TPasMPSlimReaderWriterLock.Create;
 fPoolClassType:=aPoolClassType;
 fPoolClassInstanceSize:=fPoolClassType.InstanceSize;
 fPoolBucketSize:=aPoolBucketSize;
 fPoolAlignment:=RoundUpToPowerOfTwo(aPoolAlignment);
 fPoolAlignmentMask:=fPoolAlignment-1;
 fPoolAlignedClassInstanceSize:=TpvPtrInt(TpvPtrInt(fPoolClassInstanceSize)+SizeOf(PpvPooledObjectPoolBucketItem)+TpvPtrInt(fPoolAlignmentMask)) and not TpvPtrInt(fPoolAlignmentMask);
 fPoolBucketFirst:=nil;
 fPoolBucketLast:=nil;
 fPoolBucketFreeFirst:=nil;
 fPoolBucketFreeLast:=nil;
end;

destructor TpvPooledObjectPool.Destroy;
//var Index:TpvSizeInt;
begin
 while assigned(fPoolBucketLast) do begin
  fPoolBucketLast.Free;
 end;
 fPoolLock.Free;
 inherited Destroy;
end;

function TpvPooledObjectPool.AllocateObject:pointer;
var PoolBucketItem:PpvPooledObjectPoolBucketItem;
    PoolBucket:TpvPooledObjectPoolBucket;
    PoolBucketItemIndex:TpvPtrUInt;
begin
 fPoolLock.Acquire;
 try
  if not assigned(fPoolBucketFreeLast) then begin
   TpvPooledObjectPoolBucket.Create(self);
   Assert(assigned(fPoolBucketFreeLast));
  end;
  PoolBucket:=fPoolBucketFreeLast;
  PoolBucketItem:=PoolBucket.GetFreeBucketItem;
  Assert(assigned(PoolBucketItem));
  PoolBucketItemIndex:=TpvPtrUInt(TpvPtrUInt(PoolBucketItem)-TpvPtrUInt(PoolBucket.fPoolBucketItems)) div TpvPtrUInt(SizeOf(TpvPooledObjectPoolBucketItem));
  result:=pointer(TpvPtrUInt(TpvPtrUInt(PoolBucket.fPoolBucketMemory)+(PoolBucketItemIndex*TpvPtrUInt(fPoolAlignedClassInstanceSize))));
  PpvPooledObjectPoolBucketItem(pointer(TpvPtrUInt(TpvPtrUInt(result)-TpvPtrUInt(SizeOf(PpvPooledObjectPoolBucketItem))))^):=PoolBucketItem;
  inc(PoolBucket.fPoolCountAllocatedItems);
 finally
  fPoolLock.Release;
 end;
end;

procedure TpvPooledObjectPool.FreeObject(const aInstance:pointer);
var PoolBucketItem:PpvPooledObjectPoolBucketItem;
    PoolBucket:TpvPooledObjectPoolBucket;
begin
 PoolBucketItem:=PpvPooledObjectPoolBucketItem(pointer(TpvPtrUInt(TpvPtrUInt(aInstance)-TpvPtrUInt(SizeOf(PpvPooledObjectPoolBucketItem))))^);
 fPoolLock.Acquire;
 try
  PoolBucket:=PoolBucketItem^.PoolBucket;
  dec(PoolBucket.fPoolCountAllocatedItems);
  if PoolBucket.fPoolCountAllocatedItems=0 then begin
   PoolBucket.Free;
  end else begin
   PoolBucket.AddFreeBucketItem(PoolBucketItem);
  end;
 finally
  fPoolLock.Release;
 end;
end;

constructor TpvPooledObjectPoolManager.Create;
begin
 inherited Create;
 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fObjectPoolList:=TList.Create;
 fObjectClassMetaInfoList:=TList.Create;
end;

destructor TpvPooledObjectPoolManager.Destroy;
var Index:TpvSizeInt;
begin
 for Index:=0 to fObjectPoolList.Count-1 do begin
  TObject(fObjectPoolList.Items[Index]).Free;
 end;
 fObjectPoolList.Free;
 for Index:=0 to fObjectClassMetaInfoList.Count-1 do begin
  FreeMem(fObjectClassMetaInfoList.Items[Index]);
 end;
 fObjectClassMetaInfoList.Free;
 fMultipleReaderSingleWriterLock.Free;
 inherited Destroy;
end;

procedure TpvPooledObjectPoolManager.AllocateObjectClassMetaInfo(const AClassType:TClass);
{$ifdef UseHashMaps}
var PooledObjectClass:TpvPooledObjectClass;
    PooledObjectClassMetaInfoHashItem:PpvPooledObjectClassMetaInfoHashItem;
    HashBucket:TpvUInt32;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  PooledObjectClass:=TpvPooledObjectClass(pointer(AClassType));
  HashBucket:=HashPointer(PooledObjectClass) and PooledObjectClassMetaInfoHashMask;
  PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItems[HashBucket];
  while assigned(PooledObjectClassMetaInfoHashItem) and (PooledObjectClassMetaInfoHashItem^.PooledObjectClass<>PooledObjectClass) do begin
   PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItem^.HashItemNext;
  end;
  if not assigned(PooledObjectClassMetaInfoHashItem) then begin
   fMultipleReaderSingleWriterLock.ReadToWrite;
   try
    GetMem(PooledObjectClassMetaInfoHashItem,SizeOf(TpvPooledObjectClassMetaInfoHashItem));
    FillChar(PooledObjectClassMetaInfoHashItem^,SizeOf(TpvPooledObjectClassMetaInfoHashItem),#0);
    PooledObjectClassMetaInfoHashItem^.HashItemNext:=PooledObjectClassMetaInfoHashItems[HashBucket];
    PooledObjectClassMetaInfoHashItems[HashBucket]:=PooledObjectClassMetaInfoHashItem;
    PooledObjectClassMetaInfoHashItem^.AllocatedNext:=AllocatedPooledObjectClassMetaInfoHashItems;
    AllocatedPooledObjectClassMetaInfoHashItems:=PooledObjectClassMetaInfoHashItem;
    PooledObjectClassMetaInfoHashItem^.PooledObjectClass:=PooledObjectClass;
    PooledObjectClassMetaInfoHashItem^.PooledObjectClassMetaInfo.Pool:=TpvPooledObjectPool.Create(AClassType);
   finally
    fMultipleReaderSingleWriterLock.WriteToRead;
   end;
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$else}
var ObjectClassMetaInfo:PpvPooledObjectClassMetaInfo;
{$ifdef Windows}
    OldProtect:TpvUInt32;
{$endif}
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  ObjectClassMetaInfo:={%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^);
  if not assigned(ObjectClassMetaInfo) then begin
   fMultipleReaderSingleWriterLock.ReadToWrite;
   try
    ObjectClassMetaInfo:={%H-}pointer(pointer(TpvPtrUInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^);
    if not assigned(ObjectClassMetaInfo) then begin
     GetMem(ObjectClassMetaInfo,SizeOf(TpvPooledObjectClassMetaInfo));
     FillChar(ObjectClassMetaInfo^,SizeOf(TpvPooledObjectClassMetaInfo),#0);
     fObjectClassMetaInfoList.Add(ObjectClassMetaInfo);
     ObjectClassMetaInfo^.Pool:=TpvPooledObjectPool.Create(AClassType);
{$ifdef Windows}
     OldProtect:=0;
     if VirtualProtect({%H-}pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable))),SizeOf(pointer),PAGE_EXECUTE_READWRITE,OldProtect) then begin
      {%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^):=ObjectClassMetaInfo;
      FlushInstructionCache(GetCurrentProcess,{%H-}pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable))),SizeOf(pointer));
      VirtualProtect({%H-}pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable))),SizeOf(pointer),OldProtect,@OldProtect);
     end else begin
      raise EpvPooledObjectException.Create('Object pool fatal error');
     end;
{$else}
{$ifdef Unix}
     if fpmprotect({%H-}pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable))),SizeOf(pointer),PROT_READ or PROT_WRITE or PROT_EXEC)=0 then begin
      {%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^):=ObjectClassMetaInfo;
      fpmprotect({%H-}pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable))),SizeOf(pointer),PROT_READ or PROT_EXEC);
     end else begin
      raise EpvPooledObjectException.Create('Object pool fatal error');
     end;
{$else}
 {$error Unsupported system}
{$endif}
{$endif}
    end;
   finally
    fMultipleReaderSingleWriterLock.WriteToRead;
   end;
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$endif}

function TpvPooledObjectPoolManager.AllocateObject(const AClassType:TClass):pointer;
{$ifdef UseHashMaps}
var PooledObjectClass:TpvPooledObjectClass;
    PooledObjectClassMetaInfoHashItem:PpvPooledObjectClassMetaInfoHashItem;
    HashBucket:TpvUInt32;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  PooledObjectClass:=TpvPooledObjectClass(pointer(AClassType));
  HashBucket:=HashPointer(PooledObjectClass) and PooledObjectClassMetaInfoHashMask;
  PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItems[HashBucket];
  while assigned(PooledObjectClassMetaInfoHashItem) and (PooledObjectClassMetaInfoHashItem^.PooledObjectClass<>PooledObjectClass) do begin
   PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItem^.HashItemNext;
  end;
  if not assigned(PooledObjectClassMetaInfoHashItem) then begin
   fMultipleReaderSingleWriterLock.ReleaseRead;
   try
    AllocateObjectClassMetaInfo(AClassType);
   finally
    fMultipleReaderSingleWriterLock.AcquireRead;
   end;
   PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItems[HashBucket];
   while assigned(PooledObjectClassMetaInfoHashItem) and (PooledObjectClassMetaInfoHashItem^.PooledObjectClass<>PooledObjectClass) do begin
    PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItem^.HashItemNext;
   end;
  end;
  result:=PooledObjectClassMetaInfoHashItem^.PooledObjectClassMetaInfo.Pool.AllocateObject;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$else}
var ObjectClassMetaInfo:PpvPooledObjectClassMetaInfo;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  ObjectClassMetaInfo:={%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^);
  if not assigned(ObjectClassMetaInfo) then begin
   fMultipleReaderSingleWriterLock.ReleaseRead;
   try
    AllocateObjectClassMetaInfo(AClassType);
   finally
    fMultipleReaderSingleWriterLock.AcquireRead;
   end;
   ObjectClassMetaInfo:={%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(AClassType))+TpvPtrInt(vmtAutoTable)))^);
  end;
  result:=ObjectClassMetaInfo^.Pool.AllocateObject;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$endif}

procedure TpvPooledObjectPoolManager.FreeObject(const aInstance:TObject);
{$ifdef UseHashMaps}
var PooledObjectClass:TpvPooledObjectClass;
    PooledObjectClassMetaInfoHashItem:PpvPooledObjectClassMetaInfoHashItem;
    HashBucket:TpvUInt32;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  PooledObjectClass:=TpvPooledObjectClass(pointer(aInstance.ClassType));
  HashBucket:=HashPointer(PooledObjectClass) and PooledObjectClassMetaInfoHashMask;
  PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItems[HashBucket];
  while assigned(PooledObjectClassMetaInfoHashItem) and (PooledObjectClassMetaInfoHashItem^.PooledObjectClass<>PooledObjectClass) do begin
   PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItem^.HashItemNext;
  end;
  if assigned(PooledObjectClassMetaInfoHashItem) then begin
   PooledObjectClassMetaInfoHashItem^.PooledObjectClassMetaInfo.Pool.FreeObject(aInstance);
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$else}
var ObjectClassMetaInfo:PpvPooledObjectClassMetaInfo;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  ObjectClassMetaInfo:={%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(aInstance.ClassType))+TpvPtrInt(vmtAutoTable)))^);
  ObjectClassMetaInfo^.Pool.FreeObject(aInstance);
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$endif}

class function TpvPooledObject.GetClassMetaInfo:pointer;
{$ifdef UseHashMaps}
var PooledObjectClass:TpvPooledObjectClass;
    PooledObjectClassMetaInfoHashItem:PpvPooledObjectClassMetaInfoHashItem;
    HashBucket:TpvUInt32;
begin
 PooledObjectPoolManager.fMultipleReaderSingleWriterLock.AcquireRead;
 try
  PooledObjectClass:=TpvPooledObjectClass(pointer(self));
  HashBucket:=HashPointer(PooledObjectClass) and PooledObjectClassMetaInfoHashMask;
  PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItems[HashBucket];
  while assigned(PooledObjectClassMetaInfoHashItem) and (PooledObjectClassMetaInfoHashItem^.PooledObjectClass<>PooledObjectClass) do begin
   PooledObjectClassMetaInfoHashItem:=PooledObjectClassMetaInfoHashItem^.HashItemNext;
  end;
  if assigned(PooledObjectClassMetaInfoHashItem) then begin
   result:=@PooledObjectClassMetaInfoHashItem^.PooledObjectClassMetaInfo;
  end else begin
   result:=nil;
  end;
 finally
  PooledObjectPoolManager.fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;
{$else}
begin
 result:={%H-}pointer(pointer(TpvPtrInt(TpvPtrInt(pointer(self))+TpvPtrInt(vmtAutoTable)))^);
end;
{$endif}

class procedure TpvPooledObject.InitializeObjectClassMetaInfo;
begin
 PooledObjectPoolManager.AllocateObjectClassMetaInfo(pointer(self));
end;

class function TpvPooledObject.NewInstance:TObject;
begin
 result:=InitInstance(pointer(PooledObjectPoolManager.AllocateObject(pointer(self))));
end;

procedure TpvPooledObject.FreeInstance;
begin
 CleanupInstance;
 PooledObjectPoolManager.FreeObject(self);
end;

initialization
{$ifdef UseHashMaps}
 FillChar(PooledObjectClassMetaInfoHashItems,SizeOf(TPpvPooledObjectClassMetaInfoHashItems),#0);
{$else}
{$ifdef unix}
{$ifdef darwin}
 fpmprotect:=dlsym(dlopen('libc.dylib',RTLD_NOW),'mprotect');
{$else}
 fpmprotect:=dlsym(dlopen('libc.so',RTLD_NOW),'mprotect');
{$endif}
 if not assigned(fpmprotect) then begin
  raise Exception.Create('Importing of mprotect from libc.so failed!');
 end;
{$endif}
{$endif}
 PooledObjectPoolManager:=TpvPooledObjectPoolManager.Create;
finalization
 FreeAndNil(PooledObjectPoolManager);
end.
