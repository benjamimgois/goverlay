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
unit PasVulkan.BVH.DynamicAABBTree;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$ifdef Delphi2009AndUp}
 {$warn DUPLICATE_CTOR_DTOR off}
{$endif}

{$undef UseDouble}
{$ifdef UseDouble}
 {$define NonSIMD}
{$endif}

{-$define NonSIMD}

{$ifdef NonSIMD}
 {$undef SIMD}
{$else}
 {$ifdef cpu386}
  {$if not (defined(Darwin) or defined(CompileForWithPIC))}
   {$define SIMD}
  {$ifend}
 {$endif}
 {$ifdef cpux64}
  {$define SIMD}
 {$endif}
{$endif}

{$define NonRecursive}

{$ifndef fpc}
 {$scopedenums on}
{$endif}

{$warnings off}

interface

uses SysUtils,
     Classes,
     Math,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections;

type EpvBVHDynamicAABBTree=class(Exception);

     { TpvBVHDynamicAABBTree }
     TpvBVHDynamicAABBTree=class
      public
       const NULLNODE=-1;
             AABBMULTIPLIER=2.0;
             daabbtnfMODIFIED=TpvUInt32(1) shl 0;
             daabbtnfENLARGED=TpvUInt32(1) shl 1;
             ThresholdAABBVector:TpvVector3=(x:AABBEPSILON;y:AABBEPSILON;z:AABBEPSILON);
       type TTreeNode=record
             public
              AABB:TpvAABB;
              UserData:TpvPtrInt;
              Children:array[0..1] of TpvSizeInt;
              Height:TpvSizeInt;
              CategoryBits:TpvUInt32;
              Flags:TpvUInt32;
              case boolean of
               false:(
                Parent:TpvSizeInt;
               );
               true:(
                Next:TpvSizeInt;
               );
            end;
            PTreeNode=^TTreeNode;
            TTreeNodes=array of TTreeNode;
            TTreeNodeList=TpvDynamicArrayList<PTreeNode>;
            TState=record
             TreeNodes:TTreeNodes;
             Root:TpvSizeInt;
             Generation:TpvUInt64;
            end;
            PState=^TState;
            TUserDataArray=array of TpvPtrInt;
            TSizeIntArray=array[0..65535] of TpvSizeInt;
            PSizeIntArray=^TSizeIntArray;
            TSkipListNode=packed record // <= GPU-compatible with 32 bytes per node
             public
              // (u)vec4 aabbMinSkipCount
              AABBMin:TpvVector3;
              SkipCount:TpvUInt32;
              // (u)vec4 aabbMaxUserData
              AABBMax:TpvVector3;
              UserData:TpvUInt32;
            end;
            PSkipListNode=^TSkipListNode;
            TSkipListNodes=array of TSkipListNode;
            TSkipListNodeArray=TpvDynamicArray<TSkipListNode>;
            PSkipListNodeArray=^TSkipListNodeArray;
            TSkipListNodeMap=array of TpvSizeUInt;
            TSkipListNodeStackItem=record
             Pass:TpvSizeInt;
             Node:TpvSizeInt;
            end;
            PSkipListNodeStackItem=^TSkipListNodeStackItem;
            TSkipListNodeStack=TpvDynamicStack<TSkipListNodeStackItem>;
            TGetUserDataIndex=function(const aUserData:TpvPtrInt):TpvUInt32 of object;
            TRayCastUserData=function(const aUserData:TpvPtrInt;const aRayOrigin,aRayDirection:TpvVector3;out aTime:TpvFloat;out aStop:boolean):boolean of object;
            { TSkipList }
            TSkipList=class
             private
              type TFileSignature=array[0..3] of ansichar;
                   TFileHeader=packed record
                    Signature:TFileSignature;
                    Version:TpvUInt32;
                    NodeCount:TpvUInt32;
                   end;
                   PFileHeader=^TFileHeader;
              const FileSignature:TFileSignature=('B','V','H','L');
                    FileFormatVersion:TpvUInt32=0; 
             private
              fNodeArray:TSkipListNodeArray;
             public
              constructor Create(const aFrom:TpvBVHDynamicAABBTree=nil;const aGetUserDataIndex:TpvBVHDynamicAABBTree.TGetUserDataIndex=nil); reintroduce;
              destructor Destroy; override;
              function IntersectionQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray;
              function ContainQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray; overload;
              function ContainQuery(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.TUserDataArray; overload;
              function RayCast(const aRayOrigin,aRayDirection:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
              function RayCastLine(const aFrom,aTo:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
              procedure LoadFromStream(const aStream:TStream);
              procedure LoadFromFile(const aFileName:string);
              procedure SaveToStream(const aStream:TStream);
              procedure SaveToFile(const aFileName:string);
             public
              property NodeArray:TSkipListNodeArray read fNodeArray;
            end;
            TGetDistance=function(const aTreeNode:PTreeNode;const aPoint:TpvVector3):TpvFloat of object;
      private
       fSkipListNodeLock:TPasMPSpinLock;
       fSkipListNodeMap:TSkipListNodeMap;
       fSkipListNodeStack:TSkipListNodeStack;
       function GetDistance(const aTreeNode:PTreeNode;const aPoint:TpvVector3):TpvFloat;
      private
       fRoot:TpvSizeInt;
       fNodes:TTreeNodes;
       fNodeCount:TpvSizeInt;
       fNodeCapacity:TpvSizeInt;
       fFreeList:TpvSizeInt;
       fPath:TpvSizeUInt;
       fInsertionCount:TpvSizeInt;
       fProxyCount:TpvSizeInt;
       fLeafNodes:TpvSizeIntDynamicArray;
       fNodeCenters:TpvVector3DynamicArray;
       fNodeBinIndices:array[0..2] of TpvSizeIntDynamicArray;
       fRebuildDirty:TPasMPBool32;
       fDirty:TPasMPBool32;
       fGeneration:TpvUInt64;
       fMultipleReaderSingleWriterLockState:TPasMPInt32;
       fThreadSafe:Boolean;
      public
       constructor Create(const aThreadSafe:boolean=false);
       destructor Destroy; override;
       procedure Clear;
       function AllocateNode:TpvSizeInt;
       procedure FreeNode(const aNodeID:TpvSizeInt);
       function FindBestSibling(const aAABB:TpvAABB):TpvSizeInt;
       procedure RotateNodes(const aIndex:TpvSizeInt);
       function Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
       procedure InsertLeaf(const aLeaf,aKind:TpvSizeInt);
       procedure RemoveLeaf(const aLeaf:TpvSizeInt);
       function CreateProxy(const aAABB:TpvAABB;const aUserData:TpvPtrInt;const aCategoryBits:TpvUInt32=0):TpvSizeInt;
       procedure DestroyProxy(const aNodeID:TpvSizeInt);
       function MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB;const aDisplacement,aMargin:TpvVector3;const aShouldRotate:boolean=true):boolean; overload;
       function MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB;const aDisplacement:TpvVector3;const aShouldRotate:boolean=true):boolean; overload;
       procedure EnlargeProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB);
       procedure Rebalance(const aIterations:TpvSizeInt);
       procedure RebuildBottomUp(const aLock:Boolean=true);
       procedure RebuildTopDown(const aFull:Boolean=false;const aLock:Boolean=true);
       procedure ForceRebuild;
       procedure Rebuild(const aFull:Boolean=false;const aForce:Boolean=false);
       function UpdateGeneration:TpvUInt64;
       function ComputeHeight:TpvSizeInt;
       function GetHeight:TpvSizeInt;
       function GetAreaRatio:TpvDouble;
       function GetMaxBalance:TpvSizeInt;
       function ValidateStructure:boolean;
       function ValidateMetrics:boolean;
       function Validate:boolean;
       function IntersectionQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray; overload;
       function IntersectionQuery(const aAABB:TpvAABB;const aTreeNodeList:TTreeNodeList):boolean; overload;
       function ContainQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray; overload;
       function ContainQuery(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.TUserDataArray; overload;
       function ContainQuery(const aPoint:TpvVector3;const aTreeNodeList:TTreeNodeList):boolean; overload;
       function FindClosest(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.PTreeNode;
       function LookupClosest(const aPoint:TpvVector3;const aTreeNodeList:TTreeNodeList;aGetDistance:TGetDistance=nil;const aMaxCount:TpvSizeInt=1;aMaxDistance:TpvFloat=-1.0):boolean;
       function RayCast(const aRayOrigin,aRayDirection:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
       function RayCastLine(const aFrom,aTo:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
       procedure GetSkipListNodes(var aSkipListNodeArray:TSkipListNodeArray;const aGetUserDataIndex:TpvBVHDynamicAABBTree.TGetUserDataIndex);
      public
       property Root:TpvSizeInt read fRoot;
       property Nodes:TTreeNodes read fNodes;
       property NodeCount:TpvSizeInt read fNodeCount;
       property Generation:TpvUInt64 read fGeneration;
     end;

implementation

{ TpvBVHDynamicAABBTree.TSkipList }

constructor TpvBVHDynamicAABBTree.TSkipList.Create(const aFrom:TpvBVHDynamicAABBTree;const aGetUserDataIndex:TpvBVHDynamicAABBTree.TGetUserDataIndex);
begin
 fNodeArray.Initialize;
 if assigned(aFrom) then begin
  aFrom.GetSkipListNodes(fNodeArray,aGetUserDataIndex);
 end; 
end;

destructor TpvBVHDynamicAABBTree.TSkipList.Destroy;
begin
 fNodeArray.Finalize;
 inherited Destroy;
end;

function TpvBVHDynamicAABBTree.TSkipList.IntersectionQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvAABB.Intersect(Node^.AABBMin,Node^.AABBMax,aAABB) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvBVHDynamicAABBTree.TSkipList.ContainQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvAABB.Contains(Node^.AABBMin,Node^.AABBMax,aAABB) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvBVHDynamicAABBTree.TSkipList.ContainQuery(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvAABB.Contains(Node^.AABBMin,Node^.AABBMax,aPoint) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvBVHDynamicAABBTree.TSkipList.RayCast(const aRayOrigin,aRayDirection:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
var Index,Count:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PSkipListNode;
    RayEnd:TpvVector3;
    Time:TpvFloat;
    Stop:boolean;
begin
 result:=false;
 Count:=fNodeArray.Count;
 if assigned(aRayCastUserData) and (Count>0) then begin
  aTime:=Infinity;
  RayEnd:=aRayOrigin;
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if ((not result) and
       (TpvAABB.Contains(Node^.AABBMin,Node^.AABBMax,aRayOrigin) or
        TpvAABB.FastRayIntersection(Node^.AABBMin,Node^.AABBMax,aRayOrigin,aRayDirection))) or
      (result and TpvAABB.LineIntersection(Node^.AABBMin,Node^.AABBMax,aRayOrigin,RayEnd)) then begin
    if (Node^.UserData<>High(TpvUInt32)) and aRayCastUserData(Node^.UserData,aRayOrigin,aRayDirection,Time,Stop) then begin
     if (not result) or (Time<aTime) then begin
      aTime:=Time;
      aUserData:=Node^.UserData;
      result:=true;
      if aStopAtFirstHit or Stop then begin
       break;
      end else begin
       RayEnd:=aRayOrigin+(aRayDirection*Time);
      end;
     end;
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvBVHDynamicAABBTree.TSkipList.RayCastLine(const aFrom,aTo:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
var Index,Count:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PSkipListNode;
    Time,RayLength:TpvFloat;
    RayOrigin,RayDirection,RayEnd:TpvVector3;
    Stop:boolean;
begin
 result:=false;
 Count:=fNodeArray.Count;
 if assigned(aRayCastUserData) and (Count>0) then begin
  aTime:=Infinity;
  RayOrigin:=aFrom;
  RayEnd:=aTo;
  RayDirection:=(RayEnd-RayOrigin).Normalize;
  RayLength:=(RayEnd-RayOrigin).Length;
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvAABB.LineIntersection(Node^.AABBMin,Node^.AABBMax,RayOrigin,RayEnd) then begin
    if (Node^.UserData<>High(TpvUInt32)) and aRayCastUserData(Node^.UserData,RayOrigin,RayDirection,Time,Stop) then begin
     if ((Time>=0.0) and (Time<=RayLength)) and ((not result) or (Time<aTime)) then begin
      aTime:=Time;
      aUserData:=Node^.UserData;
      result:=true;
      if aStopAtFirstHit or Stop then begin
       break;
      end else begin
       RayEnd:=RayOrigin+(RayDirection*Time);
       RayLength:=Time;
      end;
     end;
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

procedure TpvBVHDynamicAABBTree.TSkipList.LoadFromStream(const aStream:TStream);
var FileHeader:TFileHeader;
begin

 aStream.ReadBuffer(FileHeader,SizeOf(TFileHeader));
 if (FileHeader.Signature<>FileSignature) or (FileHeader.Version<>FileFormatVersion) then begin
  raise EpvBVHDynamicAABBTree.Create('Invalid file format');
 end;

 fNodeArray.Clear;
 fNodeArray.Resize(FileHeader.NodeCount);
 if FileHeader.NodeCount>0 then begin
  aStream.ReadBuffer(fNodeArray.Items[0],FileHeader.NodeCount*SizeOf(TSkipListNode));
 end;
 
end;

procedure TpvBVHDynamicAABBTree.TSkipList.LoadFromFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead); // or fmShareDenyWrite);
 try
  LoadFromStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TpvBVHDynamicAABBTree.TSkipList.SaveToStream(const aStream:TStream);
var FileHeader:TFileHeader;
begin
 
 FileHeader.Signature:=FileSignature;
 FileHeader.Version:=FileFormatVersion;
 FileHeader.NodeCount:=fNodeArray.Count;
 aStream.WriteBuffer(FileHeader,SizeOf(TFileHeader));
 
 if FileHeader.NodeCount>0 then begin
  aStream.WriteBuffer(fNodeArray.Items[0],FileHeader.NodeCount*SizeOf(TSkipListNode));
 end;

end;

procedure TpvBVHDynamicAABBTree.TSkipList.SaveToFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

{ TpvBVHDynamicAABBTree }

constructor TpvBVHDynamicAABBTree.Create(const aThreadSafe:boolean);
var i:TpvSizeInt;
begin
 inherited Create;

 fRoot:=NULLNODE;

 fNodes:=nil;
 fNodeCount:=0;
 fNodeCapacity:=16;

 SetLength(fNodes,fNodeCapacity);
 FillChar(fNodes[0],fNodeCapacity*SizeOf(TTreeNode),#0);
 for i:=0 to fNodeCapacity-2 do begin
  fNodes[i].Next:=i+1;
  fNodes[i].Height:=-1;
 end;
 fNodes[fNodeCapacity-1].Next:=NULLNODE;
 fNodes[fNodeCapacity-1].Height:=-1;

 fFreeList:=0;

 fPath:=0;

 fInsertionCount:=0;

 fProxyCount:=0;

 fDirty:=false;

 fGeneration:=0;

 fSkipListNodeLock:=TPasMPSpinLock.Create;
 fSkipListNodeMap:=nil;
 fSkipListNodeStack.Initialize;

 fLeafNodes:=nil;
 fNodeCenters:=nil;
 fNodeBinIndices[0]:=nil;
 fNodeBinIndices[1]:=nil;
 fNodeBinIndices[2]:=nil;

 fRebuildDirty:=false;

 fThreadSafe:=aThreadSafe;

 fMultipleReaderSingleWriterLockState:=0;

end;

destructor TpvBVHDynamicAABBTree.Destroy;
begin
 fSkipListNodeStack.Finalize;
 fSkipListNodeMap:=nil;
 FreeAndNil(fSkipListNodeLock);
 fNodes:=nil;
 fLeafNodes:=nil;
 fNodeCenters:=nil;
 fNodeBinIndices[0]:=nil;
 fNodeBinIndices[1]:=nil;
 fNodeBinIndices[2]:=nil;
 inherited Destroy;
end;

procedure TpvBVHDynamicAABBTree.Clear;
var i:TpvSizeInt;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;
 fSkipListNodeStack.Count:=0;
 fSkipListNodeMap:=nil;
 fRoot:=NULLNODE;
 fNodes:=nil;
 fNodeCount:=0;
 fNodeCapacity:=16;
 SetLength(fNodes,fNodeCapacity);
 FillChar(fNodes[0],fNodeCapacity*SizeOf(TTreeNode),#0);
 for i:=0 to fNodeCapacity-2 do begin
  fNodes[i].Next:=i+1;
  fNodes[i].Height:=-1;
 end;
 fNodes[fNodeCapacity-1].Next:=NULLNODE;
 fNodes[fNodeCapacity-1].Height:=-1;
 fFreeList:=0;
 fPath:=0;
 fInsertionCount:=0;
 fProxyCount:=0;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.AllocateNode:TpvSizeInt;
var Node:PTreeNode;
    i:TpvSizeInt;
begin
 if fFreeList=NULLNODE then begin
  inc(fNodeCapacity,(fNodeCapacity+1) shr 1); // *1.5
  SetLength(fNodes,fNodeCapacity);
  FillChar(fNodes[fNodeCount],(fNodeCapacity-fNodeCount)*SizeOf(TTreeNode),#0);
  for i:=fNodeCount to fNodeCapacity-2 do begin
   fNodes[i].Next:=i+1;
   fNodes[i].Height:=-1;
  end;
  fNodes[fNodeCapacity-1].Next:=NULLNODE;
  fNodes[fNodeCapacity-1].Height:=-1;
  fFreeList:=fNodeCount;
 end;
 result:=fFreeList;
 fFreeList:=fNodes[result].Next;
 Node:=@fNodes[result];
 Node^.Parent:=NULLNODE;
 Node^.Children[0]:=NULLNODE;
 Node^.Children[1]:=NULLNODE;
 Node^.Height:=0;
 Node^.UserData:=0;
 Node^.CategoryBits:=0;
 Node^.Flags:=0;
 inc(fNodeCount);
 fDirty:=true;
end;

procedure TpvBVHDynamicAABBTree.FreeNode(const aNodeID:TpvSizeInt);
var Node:PTreeNode;
begin
 Node:=@fNodes[aNodeID];
 Node^.Next:=fFreeList;
 Node^.Height:=-1;
 fFreeList:=aNodeID;
 dec(fNodeCount);
 fDirty:=true;
end;

function TpvBVHDynamicAABBTree.FindBestSibling(const aAABB:TpvAABB):TpvSizeInt;
var Center:TpvVector3;
    aAABBCost,RootAABBCost,Cost,DirectCost,InheritedCost,BestCost,LowerCost1,LowerCost2,Cost1,Cost2,
    DirectCost1,DirectCost2:TpvScalar;
    RootIndex,Index,Child1,Child2:TpvSizeInt;
    RootAABB,AABB1,AABB2:TpvAABB;
    Leaf1,Leaf2:boolean;
begin

 Center:=(aAABB.Min+aAABB.Max)*0.5;
 aAABBCost:=aAABB.Cost;

 RootIndex:=fRoot;

 RootAABB:=fNodes[RootIndex].AABB;

 RootAABBCost:=RootAABB.Cost;

 DirectCost:=RootAABB.Combine(aAABB).Cost;
 InheritedCost:=0.0;

 result:=RootIndex;
 BestCost:=DirectCost;

 Index:=RootIndex;
 while fNodes[Index].Height>0 do begin

  Child1:=fNodes[Index].Children[0];
  Child2:=fNodes[Index].Children[1];

  Cost:=DirectCost+InheritedCost;

  if Cost<BestCost then begin
   result:=Index;
   BestCost:=Cost;
  end;

  InheritedCost:=InheritedCost+(DirectCost-RootAABBCost);

  Leaf1:=fNodes[Child1].Height=0;
  Leaf2:=fNodes[Child2].Height=0;

  LowerCost1:=Infinity;
  AABB1:=fNodes[Child1].AABB;
  DirectCost1:=AABB1.Combine(aAABB).Cost;
  Cost1:=0.0;
  if Leaf1 then begin
   Cost:=DirectCost1+InheritedCost;
   if Cost<BestCost then begin
    result:=Child1;
    BestCost:=Cost;
   end;
  end else begin
   Cost1:=AABB1.Cost;
   LowerCost1:=InheritedCost+DirectCost1+Min(0.0,aAABBCost-Cost1);
  end;

  LowerCost2:=Infinity;
  AABB2:=fNodes[Child2].AABB;
  DirectCost2:=AABB2.Combine(aAABB).Cost;
  Cost2:=0.0;
  if Leaf2 then begin
   Cost:=DirectCost2+InheritedCost;
   if Cost<BestCost then begin
    result:=Child2;
    BestCost:=Cost;
   end;
  end else begin
   Cost2:=AABB2.Cost;
   LowerCost2:=InheritedCost+DirectCost2+Min(0.0,aAABBCost-Cost2);
  end;

  if Leaf1 and Leaf2 then begin
   break;
  end;

  if (BestCost<=LowerCost1) and (BestCost<=LowerCost2) then begin
   break;
  end;

  if (LowerCost1=LowerCost2) and not Leaf1 then begin
   if (LowerCost1<Infinity) and (LowerCost2<Infinity) then begin
    LowerCost1:=(((AABB1.Min+AABB1.Max)*0.5)-Center).SquaredLength;
    LowerCost2:=(((AABB2.Min+AABB2.Max)*0.5)-Center).SquaredLength;
   end;
  end;

  if (LowerCost1<LowerCost2) and not Leaf1 then begin
   Index:=Child1;
   RootAABBCost:=Cost1;
   DirectCost:=DirectCost1;
  end else begin
   Index:=Child2;
   RootAABBCost:=Cost2;
   DirectCost:=DirectCost2;
  end;

 end;

end;

procedure TpvBVHDynamicAABBTree.RotateNodes(const aIndex:TpvSizeInt);
const RotateNone=0;
      RotateBF=1;
      RotateBG=2;
      RotateCD=3;
      RotateCE=4;
var IndexA,IndexB,IndexC,IndexD,IndexE,IndexF,IndexG,BestRotation:TpvSizeInt;
    NodeA,NodeB,NodeC,NodeD,NodeE,NodeF,NodeG:PTreeNode;
    AABBBG,AABBBF,AABBCE,AABBCD:TpvAABB;
    CostBase,BestCost,CostBF,CostBG,CostCD,CostCE,AreaB,AreaC:TpvScalar;
begin

 IndexA:=aIndex;
 NodeA:=@fNodes[IndexA];
 if NodeA^.Height<2 then begin
  exit;
 end;

 IndexB:=NodeA^.Children[0];
 IndexC:=NodeA^.Children[1];
 if (IndexB<0) or (IndexB>=fNodeCapacity) or (IndexC<0) or (IndexC>=fNodeCapacity) then begin
  exit;
 end;

 NodeB:=@fNodes[IndexB];
 NodeC:=@fNodes[IndexC];

 if NodeB^.Height=0 then begin

  // B is a leaf and C is internal

  Assert(NodeC^.Height>0);

  IndexF:=NodeC^.Children[0];
  IndexG:=NodeC^.Children[1];

  if (IndexF<0) or (IndexF>=fNodeCapacity) or (IndexG<0) or (IndexG>=fNodeCapacity) then begin
   exit;
  end;

  NodeF:=@fNodes[IndexF];
  NodeG:=@fNodes[IndexG];

  CostBase:=NodeC^.AABB.Cost;

  // Cost of swapping B and F
  AABBBG:=NodeB^.AABB.Combine(NodeG^.AABB);
  CostBF:=AABBBG.Cost;

  // Cost of swapping B and G
  AABBBF:=NodeB^.AABB.Combine(NodeF^.AABB);
  CostBG:=AABBBF.Cost;

  if (CostBase<CostBF) and (CostBase<CostBG) then begin
   exit;
  end;

  if CostBF<CostBG then begin

   // Swap B and F

   NodeA^.Children[0]:=IndexF;
   NodeC^.Children[0]:=IndexB;

   NodeB^.Parent:=IndexC;
   NodeF^.Parent:=IndexA;

   NodeC^.AABB:=AABBBG;

   NodeC^.Height:=Max(NodeB^.Height,NodeG^.Height)+1;
   NodeA^.Height:=Max(NodeC^.Height,NodeF^.Height)+1;

   NodeC^.CategoryBits:=NodeB^.CategoryBits or NodeG^.CategoryBits;
   NodeA^.CategoryBits:=NodeC^.CategoryBits or NodeF^.CategoryBits;

   NodeC^.Flags:=NodeB^.Flags or NodeG^.Flags;
   NodeA^.Flags:=NodeC^.Flags or NodeF^.Flags;

  end else begin

   // Swap B and G

   NodeA^.Children[0]:=IndexG;
   NodeC^.Children[1]:=IndexB;

   NodeB^.Parent:=IndexC;
   NodeG^.Parent:=IndexA;

   NodeC^.AABB:=AABBBF;

   NodeC^.Height:=Max(NodeB^.Height,NodeF^.Height)+1;
   NodeA^.Height:=Max(NodeC^.Height,NodeG^.Height)+1;

   NodeC^.CategoryBits:=NodeB^.CategoryBits or NodeF^.CategoryBits;
   NodeA^.CategoryBits:=NodeC^.CategoryBits or NodeG^.CategoryBits;

   NodeC^.Flags:=NodeB^.Flags or NodeF^.Flags;
   NodeA^.Flags:=NodeC^.Flags or NodeG^.Flags;

  end;

 end else if NodeC^.Height=0 then begin

  // C is a leaf and B is internal

  Assert(NodeB^.Height>0);

  IndexD:=NodeB^.Children[0];
  IndexE:=NodeB^.Children[1];

  if (IndexD<0) or (IndexD>=fNodeCapacity) or (IndexE<0) or (IndexE>=fNodeCapacity) then begin
   exit;
  end;

  NodeD:=@fNodes[IndexD];
  NodeE:=@fNodes[IndexE];

  CostBase:=NodeB^.AABB.Cost;

  // Cost of swapping C and D
  AABBCE:=NodeC^.AABB.Combine(NodeE^.AABB);
  CostCD:=AABBCE.Cost;

  // Cost of swapping C and E
  AABBCD:=NodeC^.AABB.Combine(NodeD^.AABB);
  CostCE:=AABBCD.Cost;

  if (CostBase<CostCD) and (CostBase<CostCE) then begin
   exit;
  end;

  if CostCD<CostCE then begin

   // Swap C and D

   NodeA^.Children[1]:=IndexD;
   NodeB^.Children[0]:=IndexC;

   NodeC^.Parent:=IndexB;
   NodeD^.Parent:=IndexA;

   NodeB^.AABB:=AABBCE;

   NodeB^.Height:=Max(NodeC^.Height,NodeE^.Height)+1;
   NodeA^.Height:=Max(NodeB^.Height,NodeD^.Height)+1;

   NodeB^.CategoryBits:=NodeC^.CategoryBits or NodeE^.CategoryBits;
   NodeA^.CategoryBits:=NodeB^.CategoryBits or NodeD^.CategoryBits;

   NodeB^.Flags:=NodeC^.Flags or NodeE^.Flags;
   NodeA^.Flags:=NodeB^.Flags or NodeD^.Flags;

  end else begin

   // Swap C and E

   NodeA^.Children[1]:=IndexE;
   NodeB^.Children[1]:=IndexC;

   NodeC^.Parent:=IndexB;
   NodeE^.Parent:=IndexA;

   NodeB^.AABB:=AABBCD;

   NodeB^.Height:=Max(NodeC^.Height,NodeD^.Height)+1;
   NodeA^.Height:=Max(NodeB^.Height,NodeE^.Height)+1;

   NodeB^.CategoryBits:=NodeC^.CategoryBits or NodeD^.CategoryBits;
   NodeA^.CategoryBits:=NodeB^.CategoryBits or NodeE^.CategoryBits;

   NodeB^.Flags:=NodeC^.Flags or NodeD^.Flags;
   NodeA^.Flags:=NodeB^.Flags or NodeE^.Flags;

  end;

 end else begin

  IndexD:=NodeB^.Children[0];
  IndexE:=NodeB^.Children[1];
  IndexF:=NodeC^.Children[0];
  IndexG:=NodeC^.Children[1];

  if (IndexD<0) or (IndexD>=fNodeCapacity) or (IndexE<0) or (IndexE>=fNodeCapacity) or
     (IndexF<0) or (IndexF>=fNodeCapacity) or (IndexG<0) or (IndexG>=fNodeCapacity) then begin
   exit;
  end;

  NodeD:=@fNodes[IndexD];
  NodeE:=@fNodes[IndexE];
  NodeF:=@fNodes[IndexF];
  NodeG:=@fNodes[IndexG];

  CostBase:=NodeB^.AABB.Cost+NodeC^.AABB.Cost;

  // Base cost
  AreaB:=NodeB^.AABB.Cost;
  AreaC:=NodeC^.AABB.Cost;
  CostBase:=AreaB+AreaC;
  BestRotation:=RotateNone;
  BestCost:=CostBase;

  // Cost of swapping B and F
  AABBBG:=NodeB^.AABB.Combine(NodeG^.AABB);
  CostBF:=AreaB+AABBBG.Cost;
  if CostBF<BestCost then begin
   BestRotation:=RotateBF;
   BestCost:=CostBF;
  end;

  // Cost of swapping B and G
  AABBBF:=NodeB^.AABB.Combine(NodeF^.AABB);
  CostBG:=AreaB+AABBBF.Cost;
  if CostBG<BestCost then begin
   BestRotation:=RotateBG;
   BestCost:=CostBG;
  end;

  // Cost of swapping C and D
  AABBCE:=NodeC^.AABB.Combine(NodeE^.AABB);
  CostCD:=AreaC+AABBCE.Cost;
  if CostCD<BestCost then begin
   BestRotation:=RotateCD;
   BestCost:=CostCD;
  end;

  // Cost of swapping C and E
  AABBCD:=NodeC^.AABB.Combine(NodeD^.AABB);
  CostCE:=AreaC+AABBCD.Cost;
  if CostCE<BestCost then begin
   BestRotation:=RotateCE;
 //BestCost:=CostCE;
  end;

  case BestRotation of

   RotateNone:begin
   end;

   RotateBF:begin

    NodeA^.Children[0]:=IndexF;
    NodeC^.Children[0]:=IndexB;

    NodeB^.Parent:=IndexC;
    NodeF^.Parent:=IndexA;

    NodeC^.AABB:=AABBBG;

    NodeC^.Height:=Max(NodeB^.Height,NodeG^.Height)+1;
    NodeA^.Height:=Max(NodeC^.Height,NodeF^.Height)+1;

    NodeC^.CategoryBits:=NodeB^.CategoryBits or NodeG^.CategoryBits;
    NodeA^.CategoryBits:=NodeC^.CategoryBits or NodeF^.CategoryBits;

    NodeC^.Flags:=NodeB^.Flags or NodeG^.Flags;
    NodeA^.Flags:=NodeC^.Flags or NodeF^.Flags;

   end;

   RotateBG:begin

    NodeA^.Children[0]:=IndexG;
    NodeC^.Children[1]:=IndexB;

    NodeB^.Parent:=IndexC;
    NodeG^.Parent:=IndexA;

    NodeC^.AABB:=AABBBF;

    NodeC^.Height:=Max(NodeB^.Height,NodeF^.Height)+1;
    NodeA^.Height:=Max(NodeC^.Height,NodeG^.Height)+1;

    NodeC^.CategoryBits:=NodeB^.CategoryBits or NodeF^.CategoryBits;
    NodeA^.CategoryBits:=NodeC^.CategoryBits or NodeG^.CategoryBits;

    NodeC^.Flags:=NodeB^.Flags or NodeF^.Flags;
    NodeA^.Flags:=NodeC^.Flags or NodeG^.Flags;

   end;

   RotateCD:begin

    NodeA^.Children[1]:=IndexD;
    NodeB^.Children[0]:=IndexC;

    NodeC^.Parent:=IndexB;
    NodeD^.Parent:=IndexA;

    NodeB^.AABB:=AABBCE;

    NodeB^.Height:=Max(NodeC^.Height,NodeE^.Height)+1;
    NodeA^.Height:=Max(NodeB^.Height,NodeD^.Height)+1;

    NodeB^.CategoryBits:=NodeC^.CategoryBits or NodeE^.CategoryBits;
    NodeA^.CategoryBits:=NodeB^.CategoryBits or NodeD^.CategoryBits;

    NodeB^.Flags:=NodeC^.Flags or NodeE^.Flags;
    NodeA^.Flags:=NodeB^.Flags or NodeD^.Flags;

   end;

   RotateCE:begin

    NodeA^.Children[1]:=IndexE;
    NodeB^.Children[1]:=IndexC;

    NodeC^.Parent:=IndexB;
    NodeE^.Parent:=IndexA;

    NodeB^.AABB:=AABBCD;

    NodeB^.Height:=Max(NodeC^.Height,NodeD^.Height)+1;
    NodeA^.Height:=Max(NodeB^.Height,NodeE^.Height)+1;

    NodeB^.CategoryBits:=NodeC^.CategoryBits or NodeD^.CategoryBits;
    NodeA^.CategoryBits:=NodeB^.CategoryBits or NodeE^.CategoryBits;

    NodeB^.Flags:=NodeC^.Flags or NodeD^.Flags;
    NodeA^.Flags:=NodeB^.Flags or NodeE^.Flags;

   end;

   else begin
    Assert(false);
   end;

  end;

 end;

end;

function TpvBVHDynamicAABBTree.Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
var NodeA,NodeB,NodeC,NodeD,NodeE,NodeF,NodeG:PTreeNode;
    NodeBID,NodeCID,NodeDID,NodeEID,NodeFID,NodeGID,NodeBalance:TpvSizeInt;
begin
 NodeA:=@fNodes[aNodeID];
 if (NodeA.Children[0]<0) or (NodeA^.Height<2) then begin
  result:=aNodeID;
 end else begin
  NodeBID:=NodeA^.Children[0];
  NodeCID:=NodeA^.Children[1];
  NodeB:=@fNodes[NodeBID];
  NodeC:=@fNodes[NodeCID];
  NodeBalance:=NodeC^.Height-NodeB^.Height;
  if NodeBalance>1 then begin
   NodeFID:=NodeC^.Children[0];
   NodeGID:=NodeC^.Children[1];
   NodeF:=@fNodes[NodeFID];
   NodeG:=@fNodes[NodeGID];
   NodeC^.Children[0]:=aNodeID;
   NodeC^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeCID;
   if NodeC^.Parent>=0 then begin
    if fNodes[NodeC^.Parent].Children[0]=aNodeID then begin
     fNodes[NodeC^.Parent].Children[0]:=NodeCID;
    end else begin
     fNodes[NodeC^.Parent].Children[1]:=NodeCID;
    end;
   end else begin
    fRoot:=NodeCID;
   end;
   if NodeF^.Height>NodeG^.Height then begin
    NodeC^.Children[1]:=NodeFID;
    NodeA^.Children[1]:=NodeGID;
    NodeG^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeG^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeF^.AABB);
    NodeA^.Height:=Max(NodeB^.Height,NodeG^.Height)+1;
    NodeC^.Height:=Max(NodeA^.Height,NodeF^.Height)+1;
   end else begin
    NodeC^.Children[1]:=NodeGID;
    NodeA^.Children[1]:=NodeFID;
    NodeF^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeF^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeG^.AABB);
    NodeA^.Height:=Max(NodeB^.Height,NodeF^.Height)+1;
    NodeC^.Height:=Max(NodeA^.Height,NodeG^.Height)+1;
   end;
   result:=NodeCID;
  end else if NodeBalance<-1 then begin
   NodeDID:=NodeB^.Children[0];
   NodeEID:=NodeB^.Children[1];
   NodeD:=@fNodes[NodeDID];
   NodeE:=@fNodes[NodeEID];
   NodeB^.Children[0]:=aNodeID;
   NodeB^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeBID;
   if NodeB^.Parent>=0 then begin
    if fNodes[NodeB^.Parent].Children[0]=aNodeID then begin
     fNodes[NodeB^.Parent].Children[0]:=NodeBID;
    end else begin
     fNodes[NodeB^.Parent].Children[1]:=NodeBID;
    end;
   end else begin
    fRoot:=NodeBID;
   end;
   if NodeD^.Height>NodeE^.Height then begin
    NodeB^.Children[1]:=NodeDID;
    NodeA^.Children[0]:=NodeEID;
    NodeE^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeE^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeD^.AABB);
    NodeA^.Height:=Max(NodeC^.Height,NodeE^.Height)+1;
    NodeB^.Height:=Max(NodeA^.Height,NodeD^.Height)+1;
   end else begin
    NodeB^.Children[1]:=NodeEID;
    NodeA^.Children[0]:=NodeDID;
    NodeD^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeD^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeE^.AABB);
    NodeA^.Height:=Max(NodeC^.Height,NodeD^.Height)+1;
    NodeB^.Height:=Max(NodeA^.Height,NodeE^.Height)+1;
   end;
   result:=NodeBID;
  end else begin
   result:=aNodeID;
  end;
 end;
end;

procedure TpvBVHDynamicAABBTree.InsertLeaf(const aLeaf,aKind:TpvSizeInt);
var NewParentNode,TemporaryNode,NodeA,NodeB:PTreeNode;
    CombinedAABB,LeafAABB,AABB:TpvAABB;
    Index,Sibling,OldParent,NewParent,ChildA,ChildB:TpvSizeInt;
    Cost,CombinedCost,InheritanceCost,CostA,CostB:TpvScalar;
begin

 inc(fInsertionCount);

 if fRoot<0 then begin
  fRoot:=aLeaf;
  fNodes[aLeaf].Parent:=NULLNODE;
  exit;
 end;

 if aKind<0 then begin

  LeafAABB:=fNodes[aLeaf].AABB;
  Index:=fRoot;
  while fNodes[Index].Children[0]>=0 do begin

   ChildA:=fNodes[Index].Children[0];
   ChildB:=fNodes[Index].Children[1];

   CombinedAABB:=fNodes[Index].AABB.Combine(LeafAABB);
   CombinedCost:=CombinedAABB.Cost;
   Cost:=CombinedCost*2.0;
   InheritanceCost:=2.0*(CombinedCost-fNodes[Index].AABB.Cost);

   AABB:=LeafAABB.Combine(fNodes[ChildA].AABB);
   if fNodes[ChildA].Children[0]<0 then begin
    CostA:=AABB.Cost+InheritanceCost;
   end else begin
    CostA:=(AABB.Cost-fNodes[ChildA].AABB.Cost)+InheritanceCost;
   end;

   AABB:=LeafAABB.Combine(fNodes[ChildA].AABB);
   if fNodes[ChildB].Children[1]<0 then begin
    CostB:=AABB.Cost+InheritanceCost;
   end else begin
    CostB:=(AABB.Cost-fNodes[ChildA].AABB.Cost)+InheritanceCost;
   end;

   if (Cost<CostA) and (Cost<CostB) then begin
    break;
   end else begin

    if CostA<CostB then begin
     Index:=ChildA;
    end else begin
     Index:=ChildB;
    end;
   end;

  end;

  Sibling:=Index;

  OldParent:=fNodes[Sibling].Parent;
  NewParent:=AllocateNode;
  fNodes[NewParent].Parent:=OldParent;
  fNodes[NewParent].UserData:=0;
  fNodes[NewParent].AABB:=LeafAABB.Combine(fNodes[Sibling].AABB);
  fNodes[NewParent].Height:=fNodes[Sibling].Height+1;

  if OldParent>=0 then begin
   if fNodes[OldParent].Children[0]=Sibling then begin
    fNodes[OldParent].Children[0]:=NewParent;
   end else begin
    fNodes[OldParent].Children[1]:=NewParent;
   end;
   fNodes[NewParent].Children[0]:=Sibling;
   fNodes[NewParent].Children[1]:=aLeaf;
   fNodes[Sibling].Parent:=NewParent;
   fNodes[aLeaf].Parent:=NewParent;
  end else begin
   fNodes[NewParent].Children[0]:=Sibling;
   fNodes[NewParent].Children[1]:=aLeaf;
   fNodes[Sibling].Parent:=NewParent;
   fNodes[aLeaf].Parent:=NewParent;
   fRoot:=NewParent;
  end;

  // Walk back up the tree fixing heights, AABBs and modified counters
  Index:=fNodes[aLeaf].Parent;
  while Index>=0 do begin
   Index:=Balance(Index);
   ChildA:=fNodes[Index].Children[0];
   ChildB:=fNodes[Index].Children[1];
   Assert(ChildA>=0);
   Assert(ChildB>=0);
   NodeA:=@fNodes[ChildA];
   NodeB:=@fNodes[ChildB];
   TemporaryNode:=@fNodes[Index];
   TemporaryNode^.AABB:=NodeA.AABB.Combine(NodeB^.AABB);
   TemporaryNode^.CategoryBits:=NodeA^.CategoryBits or NodeB^.CategoryBits;
   TemporaryNode^.Height:=Max(NodeA^.Height,NodeB^.Height)+1;
   TemporaryNode^.Flags:=NodeA^.Flags or NodeB^.Flags;
   Index:=TemporaryNode^.Parent;
  end;

 end else begin

  // Find the best sibling for this node
  LeafAABB:=fNodes[aLeaf].AABB;
  Sibling:=FindBestSibling(LeafAABB);

  // Create a new parent for the leaf and sibling
  OldParent:=fNodes[Sibling].Parent;
  NewParent:=AllocateNode;

  NewParentNode:=@fNodes[NewParent];
  NewParentNode^.Parent:=OldParent;
  NewParentNode^.UserData:=0;
  NewParentNode^.AABB:=LeafAABB.Combine(fNodes[Sibling].AABB);
  NewParentNode^.CategoryBits:=fNodes[aLeaf].CategoryBits or fNodes[Sibling].CategoryBits;
//NewParentNode^.Modified:=fNodes[aLeaf].Modified or fNodes[Sibling].Modified;
  NewParentNode^.Height:=fNodes[Sibling].Height+1;

  if OldParent>=0 then begin

   // The sibling was not the root

   if fNodes[OldParent].Children[0]=Sibling then begin
    fNodes[OldParent].Children[0]:=NewParent;
   end else begin
    fNodes[OldParent].Children[1]:=NewParent;
   end;

   NewParentNode^.Children[0]:=Sibling;
   NewParentNode^.Children[1]:=aLeaf;

   fNodes[Sibling].Parent:=NewParent;
   fNodes[aLeaf].Parent:=NewParent;

  end else begin

   // The sibling was the root

   NewParentNode^.Children[0]:=Sibling;
   NewParentNode^.Children[1]:=aLeaf;

   fNodes[Sibling].Parent:=NewParent;
   fNodes[aLeaf].Parent:=NewParent;

   fRoot:=NewParent;

  end;

  // Walk back up the tree fixing heights, AABBs and modified counters
  Index:=fNodes[aLeaf].Parent;
  while Index>=0 do begin
   ChildA:=fNodes[Index].Children[0];
   ChildB:=fNodes[Index].Children[1];
   Assert(ChildA>=0);
   Assert(ChildB>=0);
   NodeA:=@fNodes[ChildA];
   NodeB:=@fNodes[ChildB];
   TemporaryNode:=@fNodes[Index];
   TemporaryNode^.AABB:=NodeA^.AABB.Combine(NodeB^.AABB);
   TemporaryNode^.CategoryBits:=NodeA^.CategoryBits or NodeB^.CategoryBits;
   TemporaryNode^.Height:=Max(NodeA^.Height,NodeB^.Height)+1;
   TemporaryNode^.Flags:=NodeA^.Flags or NodeB^.Flags;
   if aKind>0 then begin
    RotateNodes(Index);
   end;
   Index:=TemporaryNode^.Parent;
  end;

 end;

 fDirty:=true;

end;

procedure TpvBVHDynamicAABBTree.RemoveLeaf(const aLeaf:TpvSizeInt);
var NodeParent,NodeA,NodeB:PTreeNode;
    Parent,GrandParent,Sibling,Index:TpvSizeInt;
begin

 if aLeaf=fRoot then begin
  fRoot:=NULLNODE;
  exit;
 end;

 Parent:=fNodes[aLeaf].Parent;
 GrandParent:=fNodes[Parent].Parent;
 if fNodes[Parent].Children[0]=aLeaf then begin
  Sibling:=fNodes[Parent].Children[1];
 end else begin
  Sibling:=fNodes[Parent].Children[0];
 end;

 if GrandParent>=0 then begin

  // Destroy parent and connect sibling to grand parent

  if fNodes[GrandParent].Children[0]=Parent then begin
   fNodes[GrandParent].Children[0]:=Sibling;
  end else begin
   fNodes[GrandParent].Children[1]:=Sibling;
  end;

  fNodes[Sibling].Parent:=GrandParent;
  FreeNode(Parent);

  // Adjust ancestor bounds

  Index:=GrandParent;
  while Index>=0 do begin
   NodeParent:=@fNodes[Index];
   NodeA:=@fNodes[NodeParent^.Children[0]];
   NodeB:=@fNodes[NodeParent^.Children[1]];
   NodeParent^.AABB:=NodeA^.AABB.Combine(NodeB^.AABB);
   NodeParent^.CategoryBits:=NodeA^.CategoryBits or NodeB^.CategoryBits;
   NodeParent^.Height:=Max(NodeA^.Height,NodeB^.Height)+1;
   Index:=NodeParent^.Parent;
  end;

 end else begin

  fRoot:=Sibling;
  fNodes[Sibling].Parent:=NULLNODE;
  FreeNode(Parent);

 end;

 fDirty:=true;

end;

function TpvBVHDynamicAABBTree.CreateProxy(const aAABB:TpvAABB;const aUserData:TpvPtrInt;const aCategoryBits:TpvUInt32):TpvSizeInt;
var Node,ParentNode:PTreeNode;
    ParentIndex:TpvSizeInt;
begin

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;

 result:=AllocateNode;

 Node:=@fNodes[result];
 Node^.AABB.Min:=aAABB.Min-ThresholdAABBVector;
 Node^.AABB.Max:=aAABB.Max+ThresholdAABBVector;
 Node^.UserData:=aUserData;
 Node^.CategoryBits:=aCategoryBits;
 Node^.Flags:=Node^.Flags or daabbtnfMODIFIED;
 Node^.Height:=0;

 InsertLeaf(result,1);

 Node:=@fNodes[result];
 ParentIndex:=Node^.Parent;
 if ParentIndex>=0 then begin
  ParentNode:=@fNodes[ParentIndex];
  ParentNode^.Flags:=ParentNode^.Flags or daabbtnfMODIFIED;
  ParentIndex:=ParentNode^.Parent;
  while (ParentIndex>=0) and ((fNodes[ParentIndex].Flags and daabbtnfMODIFIED)=0) do begin
   ParentNode:=@fNodes[ParentIndex];
   ParentNode^.Flags:=ParentNode^.Flags or daabbtnfMODIFIED;
   ParentIndex:=ParentNode^.Parent;
  end;
 end;

 inc(fProxyCount);

 fDirty:=true;

 fRebuildDirty:=true;

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;

end;

procedure TpvBVHDynamicAABBTree.DestroyProxy(const aNodeID:TpvSizeInt);
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;
 dec(fProxyCount);
 RemoveLeaf(aNodeID);
 FreeNode(aNodeID);
 fRebuildDirty:=true;
 fDirty:=true;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB;const aDisplacement,aMargin:TpvVector3;const aShouldRotate:boolean):boolean;
var Node,ParentNode:PTreeNode;
    ParentIndex:TpvSizeInt;
    b:TpvAABB;
    d:TpvVector3;
begin

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;

 Node:=@fNodes[aNodeID];

 result:=not Node^.AABB.Contains(aAABB);

 if result then begin

  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(fMultipleReaderSingleWriterLockState);
  end;

  RemoveLeaf(aNodeID);

  d:=ThresholdAABBVector+aMargin;
  b.Min:=aAABB.Min-d;
  b.Max:=aAABB.Max+d;
  d:=aDisplacement*AABBMULTIPLIER;
  if d.x<0.0 then begin
   b.Min.x:=b.Min.x+d.x;
  end else if d.x>0.0 then begin
   b.Max.x:=b.Max.x+d.x;
  end;
  if d.y<0.0 then begin
   b.Min.y:=b.Min.y+d.y;
  end else if d.y>0.0 then begin
   b.Max.y:=b.Max.y+d.y;
  end;
  if d.z<0.0 then begin
   b.Min.z:=b.Min.z+d.z;
  end else if d.z>0.0 then begin
   b.Max.z:=b.Max.z+d.z;
  end;
  Node^.AABB:=b;

  Node^.Flags:=Node^.Flags or daabbtnfMODIFIED;

  InsertLeaf(aNodeID,ord(aShouldRotate) and 1);

  if not aShouldRotate then begin
   ParentIndex:=Node^.Parent;
   if ParentIndex>=0 then begin
    ParentNode:=@fNodes[ParentIndex];
    ParentNode^.Flags:=ParentNode^.Flags or daabbtnfMODIFIED;
    ParentIndex:=ParentNode^.Parent;
    while (ParentIndex>=0) and ((fNodes[ParentIndex].Flags and daabbtnfMODIFIED)=0) do begin
     ParentNode:=@fNodes[ParentIndex];
     ParentNode^.Flags:=ParentNode^.Flags or daabbtnfMODIFIED;
     ParentIndex:=ParentNode^.Parent;
    end;
   end;
  end;

  fRebuildDirty:=true;

  fDirty:=true;

  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
  end;

 end else begin

  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
  end;

 end;

end;

function TpvBVHDynamicAABBTree.MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB;const aDisplacement:TpvVector3;const aShouldRotate:boolean):boolean;
begin
 result:=MoveProxy(aNodeID,aAABB,aDisplacement,TpvVector3.Null,aShouldRotate);
end;

procedure TpvBVHDynamicAABBTree.EnlargeProxy(const aNodeID:TpvSizeInt;const aAABB:TpvAABB);
var Node,ParentNode:PTreeNode;
    ParentIndex:TpvSizeInt;
    Changed:boolean;
begin

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;

 if (aNodeID>=0) and (aNodeID<fNodeCapacity) then begin

  Node:=@fNodes[aNodeID];

  if Node^.Height=0 then begin

   Node^.AABB:=aAABB;

   ParentIndex:=Node^.Parent;

   while ParentIndex>=0 do begin
    ParentNode:=@fNodes[ParentIndex];
    Changed:=ParentNode^.AABB.Enlarge(aAABB);
    ParentNode^.Flags:=ParentNode^.Flags or daabbtnfENLARGED;
    ParentIndex:=ParentNode^.Parent;
    if not Changed then begin
     break;
    end;
   end;

   while (ParentIndex>=0) and ((fNodes[ParentIndex].Flags and daabbtnfENLARGED)=0) do begin
    ParentNode:=@fNodes[ParentIndex];
    ParentNode^.Flags:=ParentNode^.Flags or daabbtnfENLARGED;
    ParentIndex:=ParentNode^.Parent;
   end;

  end;

 end;

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;

end;

procedure TpvBVHDynamicAABBTree.Rebalance(const aIterations:TpvSizeInt);
var Counter,Node:TpvSizeInt;
    Bit:TpvSizeUInt;
//  Children:PSizeIntArray;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;
 if (fRoot>=0) and (fRoot<fNodeCount) then begin
  for Counter:=1 to aIterations do begin
   Bit:=0;
   Node:=fRoot;
   while fNodes[Node].Children[0]>=0 do begin
    Node:=fNodes[Node].Children[(fPath shr Bit) and 1];
    Bit:=(Bit+1) and 31;
   end;
   inc(fPath);
   if ((Node>=0) and (Node<fNodeCount)) and (fNodes[Node].Children[0]<0) then begin
    RemoveLeaf(Node);
    InsertLeaf(Node,-1);
   end else begin
    break;
   end;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;
end;

procedure TpvBVHDynamicAABBTree.RebuildBottomUp(const aLock:Boolean);
var Count,IndexA,IndexB,IndexAMin,IndexBMin,Index1,Index2,ParentIndex:TpvSizeint;
    NewNodes:array of TpvSizeInt;
    Children:array[0..1] of TpvBVHDynamicAABBTree.PTreeNode;
    Parent:TpvBVHDynamicAABBTree.PTreeNode;
    MinCost,Cost:TpvFloat;
    AABBa,AABBb:PpvAABB;
    AABB:TpvAABB;
    First:boolean;
begin
 if fThreadSafe and aLock then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;
 if fNodeCount>0 then begin
  NewNodes:=nil;
  try
   SetLength(NewNodes,fNodeCount);
   FillChar(NewNodes[0],fNodeCount*SizeOf(TpvSizeint),#0);
   Count:=0;
   for IndexA:=0 to fNodeCapacity-1 do begin
    if fNodes[IndexA].Height>=0 then begin
     if fNodes[IndexA].Children[0]<0 then begin
      fNodes[IndexA].Parent:=TpvBVHDynamicAABBTree.NULLNODE;
      NewNodes[Count]:=IndexA;
      inc(Count);
     end else begin
      FreeNode(IndexA);
     end;
    end;
   end;
   while Count>1 do begin
    First:=true;
    MinCost:=MAX_SCALAR;
    IndexAMin:=-1;
    IndexBMin:=-1;
  {}/////////////////TOOPTIMIZE///////////////////
  {}for IndexA:=0 to Count-1 do begin           //
  {} AABBa:=@fNodes[NewNodes[IndexA]].AABB;     //
  {} for IndexB:=IndexA+1 to Count-1 do begin   //
  {}  AABBb:=@fNodes[NewNodes[IndexB]].AABB;    //
  {}  AABB:=AABBa^.Combine(AABBb^);             //
  {}  Cost:=AABB.Cost;                          //
  {}  if First or (Cost<MinCost) then begin     //
  {}   First:=false;                            //
  {}   MinCost:=Cost;                           //
  {}   IndexAMin:=IndexA;                       //
  {}   IndexBMin:=IndexB;                       //
  {}  end;                                      //
  {} end;                                       //
  {}end;                                        //
  {}/////////////////TOOPTIMIZE///////////////////
    Index1:=NewNodes[IndexAMin];
    Index2:=NewNodes[IndexBMin];
    Children[0]:=@fNodes[Index1];
    Children[1]:=@fNodes[Index2];
    ParentIndex:=AllocateNode;
    Parent:=@fNodes[ParentIndex];
    Parent^.Children[0]:=Index1;
    Parent^.Children[1]:=Index2;
    Parent^.Height:=1+Max(Children[0]^.Height,Children[1]^.Height);
    Parent^.AABB:=Children[0]^.AABB.Combine(Children[1]^.AABB);
    Parent^.Parent:=TpvBVHDynamicAABBTree.NULLNODE;
    Parent^.CategoryBits:=Children[0]^.CategoryBits or Children[1]^.CategoryBits;
    Parent^.Flags:=Children[0]^.Flags or Children[1]^.Flags;
    Children[0]^.Parent:=ParentIndex;
    Children[1]^.Parent:=ParentIndex;
    NewNodes[IndexBMin]:=NewNodes[Count-1];
    NewNodes[IndexAMin]:=ParentIndex;
    dec(Count);
   end;
   fRoot:=NewNodes[0];
  finally
   NewNodes:=nil;
  end;
 end;
 fDirty:=true;
 if fThreadSafe and aLock then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;
end;

procedure TpvBVHDynamicAABBTree.RebuildTopDown(const aFull:Boolean;const aLock:Boolean);
{$define DynamicAABBTreeRebuildTopDownSAH}
{$define DynamicAABBTreeRebuildTopDownQuickSortStylePartitioning}
{$ifdef DynamicAABBTreeRebuildTopDownSAH}
const CountBins=8;
      CountPlanes=CountBins-1;
{$endif}
type TFillStackItem=record
      Parent:TpvSizeInt;
      Which:TpvSizeInt;
      FirstLeafNode:TpvSizeInt;
      CountLeafNodes:TpvSizeInt;
     end;
     TFillStack=TpvDynamicFastStack<TFillStackItem>;
     THeightStackItem=record
      Node:TpvSizeInt;
      Pass:TpvSizeInt;
     end;
     THeightStack=TpvDynamicFastStack<THeightStackItem>;
     TNodeStackItem=TpvSizeInt;
     TNodeStack=TpvDynamicFastStack<TNodeStackItem>;
{$ifdef DynamicAABBTreeRebuildTopDownSAH}
     TBin=record
      AABB:TpvAABB;
      Count:TpvSizeInt;
     end;
     PBin=^TBin;
     TBins=array[0..CountBins-1] of TBin;
     TPlane=record
      LeftAABB:TpvAABB;
      RightAABB:TpvAABB;
      LeftCount:TpvSizeInt;
      RightCount:TpvSizeInt;
     end;
     PPlane=^TPlane;
     TPlanes=array[0..CountPlanes-1] of TPlane;
{$endif}
var Count,Index,ParentIndex,NodeIndex,TempIndex,
    LeftIndex,RightIndex,LeftCount,RightCount:TpvSizeInt;
{$ifdef DynamicAABBTreeRebuildTopDownSAH}
    AxisIndex,BinIndex,BestPlaneIndex,BestAxisIndex:TpvSizeInt;
    InvAxisLength,MinCenterValue,BestCost,Cost:TpvScalar;
    Bins:TBins;
    Bin:PBin;
    Planes:TPlanes;
    Plane,PreviousPlane:PPlane;
    CentroidAABB:TpvAABB;
    AxisLengths:TpvVector3;
{$else}
    SplitAxis,MinPerSubTree:TpvSizeInt;
    SplitValue:TpvScalar;
    VarianceX,VarianceY,VarianceZ,MeanX,MeanY,MeanZ:TpvDouble;
{$endif}
    AABB:TpvAABB;
    Center:PpvVector3;
    FillStack:TFillStack;
    FillStackItem,NewFillStackItem:TFillStackItem;
    HeightStack:THeightStack;
    HeightStackItem,NewHeightStackItem:THeightStackItem;
    NodeStack:TNodeStack;
    NodeStackItem:TNodeStackItem;
    Node:PTreeNode;
begin

 if fThreadSafe and aLock then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;

 if (NodeCount>0) and (fRoot>=0) then begin

  if length(fLeafNodes)<=fNodeCapacity then begin
   SetLength(fLeafNodes,(fNodeCapacity+1)+((fNodeCapacity+1) shr 1));
  end;

  if length(fNodeCenters)<=fNodeCapacity then begin
   SetLength(fNodeCenters,(fNodeCapacity+1)+((fNodeCapacity+1) shr 1));
  end;

  for Index:=0 to 2 do begin
   if length(fNodeBinIndices[Index])<=fNodeCapacity then begin
    SetLength(fNodeBinIndices[Index],(fNodeCapacity+1)+((fNodeCapacity+1) shr 1));
   end;
  end;

  FillChar(fLeafNodes[0],fNodeCapacity*SizeOf(TpvSizeInt),#0);

  Count:=0;

  NodeStack.Initialize;
  try

   NodeStack.Push(fRoot);
   while NodeStack.Pop(NodeStackItem) do begin

    Index:=NodeStackItem;

    Node:=@fNodes[Index];

    if (Node^.Height=0) or ((Node^.Height>0) and ((not aFull) and ((Node^.Flags and (daabbtnfMODIFIED or daabbtnfENLARGED))=0))) then begin

     // Get node center
     fNodeCenters[Index]:=(Node^.AABB.Min+Node^.AABB.Max)*0.5;

     // Add
     fLeafNodes[Count]:=Index;
     inc(Count);

     // Detach
     Node^.Parent:=NULLNODE;

     // Reset flags
     Node^.Flags:=Node^.Flags and not TpvUInt32(daabbtnfMODIFIED or daabbtnfENLARGED);

    end else if Node^.Height>0 then begin

     NodeStack.Push(Node^.Children[1]);
     NodeStack.Push(Node^.Children[0]);

     FreeNode(Index);

    end;

   end;

  finally
   NodeStack.Finalize;
  end;//}

{ Count:=0;
  for Index:=0 to fNodeCapacity-1 do begin
   if fNodes[Index].Height>=0 then begin
    fNodeCenters[Index]:=(fNodes^[Index].AABB.Min+fNodes^[Index].AABB.Max)*0.5;
    if fNodes[Index].Children[0]<0 then begin
     fNodes[Index].Parent:=NULLNODE;
     fLeafNodes[Count]:=Index;
     inc(Count);
    end else begin
     FreeNode(Index);
    end;
   end;
  end;//}

  fRoot:=NULLNODE;

  if Count>0 then begin

   FillStack.Initialize;
   try

    NewFillStackItem.Parent:=NULLNODE;
    NewFillStackItem.Which:=-1;
    NewFillStackItem.FirstLeafNode:=0;
    NewFillStackItem.CountLeafNodes:=Count;
    FillStack.Push(NewFillStackItem);

    while FillStack.Pop(FillStackItem) do begin

     case FillStackItem.CountLeafNodes of

      0:begin
      end;

      1:begin
       NodeIndex:=fLeafNodes[FillStackItem.FirstLeafNode];
       ParentIndex:=FillStackItem.Parent;
       fNodes[NodeIndex].Parent:=ParentIndex;
       if (FillStackItem.Which>=0) and (ParentIndex>=0) then begin
        fNodes[ParentIndex].Children[FillStackItem.Which]:=NodeIndex;
       end else begin
        fRoot:=NodeIndex;
       end;
      end;

      else begin

       NodeIndex:=AllocateNode;

       ParentIndex:=FillStackItem.Parent;

       fNodes[NodeIndex].Parent:=ParentIndex;

       if (FillStackItem.Which>=0) and (ParentIndex>=0) then begin
        fNodes[ParentIndex].Children[FillStackItem.Which]:=NodeIndex;
       end else begin
        fRoot:=NodeIndex;
       end;

       AABB:=fNodes[fLeafNodes[FillStackItem.FirstLeafNode]].AABB;
       for Index:=1 to FillStackItem.CountLeafNodes-1 do begin
        AABB.DirectCombine(fNodes[fLeafNodes[FillStackItem.FirstLeafNode+Index]].AABB);
       end;

       fNodes[NodeIndex].AABB:=AABB;

{$ifdef DynamicAABBTreeRebuildTopDownSAH}
       begin

        // SAH

        Center:=@fNodeCenters[fLeafNodes[FillStackItem.FirstLeafNode]];
        CentroidAABB.Min:=Center^;
        CentroidAABB.Max:=Center^;
        for Index:=1 to FillStackItem.CountLeafNodes-1 do begin
         Center:=@fNodeCenters[fLeafNodes[FillStackItem.FirstLeafNode+Index]];
         CentroidAABB.DirectCombineVector3(Center^);
        end;

{       AxisLengths:=CentroidAABB.Max-CentroidAABB.Min;
        if AxisLengths.x<AxisLengths.y then begin
         if AxisLengths.y<AxisLengths.z then begin
          AxisIndex:=2;
         end else begin
          AxisIndex:=1;
         end;
        end else begin
         if AxisLengths.x<AxisLengths.z then begin
          AxisIndex:=2;
         end else begin
          AxisIndex:=0;
         end;
        end;}

        BestCost:=Infinity;
        BestPlaneIndex:=-1;
        BestAxisIndex:=0;

        for AxisIndex:=0 to 2 do begin

         for Index:=0 to CountBins-1 do begin
          Bin:=@Bins[Index];
          Bin^.AABB.Min.x:=Infinity;
          Bin^.AABB.Min.y:=Infinity;
          Bin^.AABB.Min.z:=Infinity;
          Bin^.AABB.Max.x:=-Infinity;
          Bin^.AABB.Max.y:=-Infinity;
          Bin^.AABB.Max.z:=-Infinity;
          Bin^.Count:=0;
         end;

         if AxisLengths.xyz[AxisIndex]>0.0 then begin
          InvAxisLength:=1.0/AxisLengths.xyz[AxisIndex];
         end else begin
          InvAxisLength:=0.0;
         end;

         MinCenterValue:=CentroidAABB.Min.xyz[AxisIndex];
         for Index:=0 to FillStackItem.CountLeafNodes-1 do begin
          Center:=@fNodeCenters[fLeafNodes[FillStackItem.FirstLeafNode+Index]];
          BinIndex:=Min(Max(trunc(Min(Max((Center^.xyz[AxisIndex]-MinCenterValue)*InvAxisLength,0.0),1.0)*CountBins),0),CountBins-1);
          fNodeBinIndices[AxisIndex,fLeafNodes[FillStackItem.FirstLeafNode+Index]]:=BinIndex;
          Bin:=@Bins[BinIndex];
          if Bin^.Count=0 then begin
           Bin^.AABB:=fNodes[fLeafNodes[FillStackItem.FirstLeafNode+Index]].AABB;
          end else begin
           Bin^.AABB.DirectCombine(fNodes[fLeafNodes[FillStackItem.FirstLeafNode+Index]].AABB);
          end;
          inc(Bin^.Count);
         end;

         Plane:=@Planes[0];
         Bin:=@Bins[0];
         Plane^.LeftAABB:=Bin^.AABB;
         Plane^.LeftCount:=Bin^.Count;
         for Index:=1 to CountPlanes-1 do begin
          PreviousPlane:=Plane;
          Plane:=@Planes[Index];
          Bin:=@Bins[Index];
          Plane^.LeftAABB:=PreviousPlane^.LeftAABB.Combine(Bin^.AABB);
          Plane^.LeftCount:=PreviousPlane^.LeftCount+Bin^.Count;
         end;

         Plane:=@Planes[CountPlanes-1];
         Bin:=@Bins[CountPlanes];
         Plane^.RightAABB:=Bin^.AABB;
         Plane^.RightCount:=Bin^.Count;
         for Index:=CountPlanes-2 downto 0 do begin
          PreviousPlane:=Plane;
          Plane:=@Planes[Index];
          Bin:=@Bins[Index+1];
          Plane^.RightAABB:=PreviousPlane^.RightAABB.Combine(Bin^.AABB);
          Plane^.RightCount:=PreviousPlane^.RightCount+Bin^.Count;
         end;

         for Index:=0 to CountPlanes-1 do begin
          Plane:=@Planes[Index];
          Cost:=(Plane^.LeftAABB.Cost*Plane^.LeftCount)+(Plane^.RightAABB.Cost*Plane^.RightCount);
          if (BestPlaneIndex<0) or (BestCost>Cost) then begin
           BestCost:=Cost;
           BestPlaneIndex:=Index;
           BestAxisIndex:=AxisIndex;
          end;
         end;

        end;

        if BestPlaneIndex<0 then begin
         BestPlaneIndex:=0;
        end;

{$ifdef DynamicAABBTreeRebuildTopDownQuickSortStylePartitioning}
        // Quick-Sort style paritioning with Hoare partition scheme
        LeftIndex:=FillStackItem.FirstLeafNode;
        RightIndex:=FillStackItem.FirstLeafNode+FillStackItem.CountLeafNodes;
        while LeftIndex<RightIndex do begin
         while (LeftIndex<RightIndex) and (fNodeBinIndices[BestAxisIndex,fLeafNodes[LeftIndex]]<=BestPlaneIndex) do begin
          inc(LeftIndex);
         end;
         while (LeftIndex<RightIndex) and (fNodeBinIndices[BestAxisIndex,fLeafNodes[RightIndex-1]]>BestPlaneIndex) do begin
          dec(RightIndex);
         end;
         if LeftIndex<RightIndex then begin
          dec(RightIndex);
          TempIndex:=fLeafNodes[LeftIndex];
          fLeafNodes[LeftIndex]:=fLeafNodes[RightIndex];
          fLeafNodes[RightIndex]:=TempIndex;
          inc(LeftIndex);
         end;
        end;
        LeftCount:=LeftIndex-FillStackItem.FirstLeafNode;
        RightCount:=FillStackItem.CountLeafNodes-LeftCount;
{$else}
        // Bubble-Sort style paritioning?
        LeftIndex:=FillStackItem.FirstLeafNode;
        RightIndex:=FillStackItem.FirstLeafNode+FillStackItem.CountLeafNodes;
        LeftCount:=0;
        RightCount:=0;
        while LeftIndex<RightIndex do begin
         if fNodeBinIndices[BestAxisIndex,fLeafNodes[LeftIndex]]<=BestPlaneIndex then begin
          inc(LeftIndex);
          inc(LeftCount);
         end else begin
          dec(RightIndex);
          inc(RightCount);
          TempIndex:=fLeafNodes[LeftIndex];
          fLeafNodes[LeftIndex]:=fLeafNodes[RightIndex];
          fLeafNodes[RightIndex]:=TempIndex;
         end;
        end;
{$endif}

        if (LeftCount=0) or (RightCount=0) then begin
         LeftCount:=(FillStackItem.CountLeafNodes+1) shr 1;
         RightCount:=FillStackItem.CountLeafNodes-LeftCount;
        end;

       end;
{$else}
       begin

        // Mean Variance

        MeanX:=0.0;
        MeanY:=0.0;
        MeanZ:=0.0;
        for Index:=0 to FillStackItem.CountLeafNodes-1 do begin
         Center:=@fNodeCenters[fLeafNodes[FillStackItem.FirstLeafNode+Index]];
         MeanX:=MeanX+Center^.x;
         MeanY:=MeanY+Center^.y;
         MeanZ:=MeanZ+Center^.z;
        end;
        MeanX:=MeanX/FillStackItem.CountLeafNodes;
        MeanY:=MeanY/FillStackItem.CountLeafNodes;
        MeanZ:=MeanZ/FillStackItem.CountLeafNodes;

        VarianceX:=0.0;
        VarianceY:=0.0;
        VarianceZ:=0.0;
        for Index:=0 to FillStackItem.CountLeafNodes-1 do begin
         Center:=@fNodeCenters[fLeafNodes[FillStackItem.FirstLeafNode+Index]];
         VarianceX:=VarianceX+sqr(Center^.x-MeanX);
         VarianceY:=VarianceY+sqr(Center^.y-MeanY);
         VarianceZ:=VarianceZ+sqr(Center^.z-MeanZ);
        end;
        VarianceX:=VarianceX/FillStackItem.CountLeafNodes;
        VarianceY:=VarianceY/FillStackItem.CountLeafNodes;
        VarianceZ:=VarianceZ/FillStackItem.CountLeafNodes;

        if VarianceX<VarianceY then begin
         if VarianceY<VarianceZ then begin
          SplitAxis:=2;
          SplitValue:=MeanZ;
         end else begin
          SplitAxis:=1;
          SplitValue:=MeanY;
         end;
        end else begin
         if VarianceX<VarianceZ then begin
          SplitAxis:=2;
          SplitValue:=MeanZ;
         end else begin
          SplitAxis:=0;
          SplitValue:=MeanX;
         end;
        end;

{$ifdef DynamicAABBTreeRebuildTopDownQuickSortStylePartitioning}
        // Quick-Sort style paritioning with Hoare partition scheme
        LeftIndex:=FillStackItem.FirstLeafNode;
        RightIndex:=FillStackItem.FirstLeafNode+FillStackItem.CountLeafNodes;
        while LeftIndex<RightIndex do begin
         while (LeftIndex<RightIndex) and (fNodeCenters[fLeafNodes[LeftIndex]].xyz[SplitAxis]<=SplitValue) do begin
          inc(LeftIndex);
         end;
         while (LeftIndex<RightIndex) and (fNodeCenters[fLeafNodes[RightIndex-1]].xyz[SplitAxis]>SplitValue) do begin
          dec(RightIndex);
         end;
         if LeftIndex<RightIndex then begin
          dec(RightIndex);
          TempIndex:=fLeafNodes[LeftIndex];
          fLeafNodes[LeftIndex]:=fLeafNodes[RightIndex];
          fLeafNodes[RightIndex]:=TempIndex;
          inc(LeftIndex);
         end;
        end;
        LeftCount:=LeftIndex-FillStackItem.FirstLeafNode;
        RightCount:=FillStackItem.CountLeafNodes-LeftCount;
{$else}
        // Bubble-Sort style paritioning?
        LeftIndex:=FillStackItem.FirstLeafNode;
        RightIndex:=FillStackItem.FirstLeafNode+FillStackItem.CountLeafNodes;
        LeftCount:=0;
        RightCount:=0;
        while LeftIndex<RightIndex do begin
         Center:=@fNodeCenters[fLeafNodes[LeftIndex]];
         if Center.xyz[SplitAxis]<=SplitValue then begin
          inc(LeftIndex);
          inc(LeftCount);
         end else begin
          dec(RightIndex);
          inc(RightCount);
          TempIndex:=fLeafNodes[LeftIndex];
          fLeafNodes[LeftIndex]:=fLeafNodes[RightIndex];
          fLeafNodes[RightIndex]:=TempIndex;
         end;
        end;
{$endif}

        MinPerSubTree:=(TpvInt64(FillStackItem.CountLeafNodes+1)*341) shr 10;
        if (LeftCount=0) or
           (RightCount=0) or
           (LeftCount<=MinPerSubTree) or
           (RightCount<=MinPerSubTree) then begin
         LeftCount:=(FillStackItem.CountLeafNodes+1) shr 1;
         RightCount:=FillStackItem.CountLeafNodes-LeftCount;
        end;

       end;
{$endif}

       if (LeftCount>0) and (LeftCount<FillStackItem.CountLeafNodes) then begin

        NewFillStackItem.Parent:=NodeIndex;
        NewFillStackItem.Which:=1;
        NewFillStackItem.FirstLeafNode:=FillStackItem.FirstLeafNode+LeftCount;
        NewFillStackItem.CountLeafNodes:=FillStackItem.CountLeafNodes-LeftCount;
        FillStack.Push(NewFillStackItem);

        NewFillStackItem.Parent:=NodeIndex;
        NewFillStackItem.Which:=0;
        NewFillStackItem.FirstLeafNode:=FillStackItem.FirstLeafNode;
        NewFillStackItem.CountLeafNodes:=LeftCount;
        FillStack.Push(NewFillStackItem);

       end;

      end;

     end;

    end;

   finally
    FillStack.Finalize;
   end;

   if fRoot>=0 then begin

    HeightStack.Initialize;
    try

     NewHeightStackItem.Node:=fRoot;
     NewHeightStackItem.Pass:=0;
     HeightStack.Push(NewHeightStackItem);

     while HeightStack.Pop(HeightStackItem) do begin
      case HeightStackItem.Pass of
       0:begin
        NewHeightStackItem.Node:=HeightStackItem.Node;
        NewHeightStackItem.Pass:=1;
        HeightStack.Push(NewHeightStackItem);
        if fNodes[HeightStackItem.Node].Children[1]>=0 then begin
         NewHeightStackItem.Node:=fNodes[HeightStackItem.Node].Children[1];
         NewHeightStackItem.Pass:=0;
         HeightStack.Push(NewHeightStackItem);
        end;
        if fNodes[HeightStackItem.Node].Children[0]>=0 then begin
         NewHeightStackItem.Node:=fNodes[HeightStackItem.Node].Children[0];
         NewHeightStackItem.Pass:=0;
         HeightStack.Push(NewHeightStackItem);
        end;
       end;
       1:begin
        if (fNodes[HeightStackItem.Node].Children[0]<0) and (fNodes[HeightStackItem.Node].Children[1]<0) then begin
         fNodes[HeightStackItem.Node].Height:=0;
        end else begin
         fNodes[HeightStackItem.Node].Height:=Max(fNodes[fNodes[HeightStackItem.Node].Children[0]].Height,fNodes[fNodes[HeightStackItem.Node].Children[1]].Height)+1;
        end;
       end;
      end;
     end;

    finally
     HeightStack.Finalize;
    end;

   end;

  end;

 end;

 fDirty:=true;

 if fThreadSafe and aLock then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;

end;

procedure TpvBVHDynamicAABBTree.ForceRebuild;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fMultipleReaderSingleWriterLockState);
 end;
 if fNodeCount<128 then begin
  RebuildBottomUp(false);
 end else begin
  RebuildTopDown(true,false);
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
 end;
end;

procedure TpvBVHDynamicAABBTree.Rebuild(const aFull:Boolean=false;const aForce:Boolean=false);
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 if fRebuildDirty or aForce then begin
  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(fMultipleReaderSingleWriterLockState);
  end;
  fRebuildDirty:=false;
  if fProxyCount>0 then begin
   RebuildTopDown(aFull,false);
 //Assert(Validate);
  end;
  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fMultipleReaderSingleWriterLockState);
  end;
  if fThreadSafe then begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
  end;
 end;
end;

function TpvBVHDynamicAABBTree.UpdateGeneration:TpvUInt64;
begin
 if TPasMPInterlocked.CompareExchange(fDirty,TPasMPBool32(false),TPasMPBool32(true)) then begin
  inc(fGeneration);
 end;
 result:=fGeneration;
end;

function TpvBVHDynamicAABBTree.ComputeHeight:TpvSizeInt;
type TStackItem=record
      NodeID:TpvSizeInt;
      Height:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem:TStackItem;
    NewStackItem:PStackItem;
    Node:PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=0;
 if fRoot>=0 then begin
  Stack.Initialize;
  try
   NewStackItem:=pointer(Stack.PushIndirect);
   NewStackItem^.NodeID:=fRoot;
   NewStackItem^.Height:=1;
   while Stack.Pop(StackItem) do begin
    if (StackItem.NodeID>=0) and (StackItem.NodeID<fNodeCapacity) then begin
     Node:=@fNodes[StackItem.NodeID];
     if Node^.Height<>0 then begin
      if result<StackItem.Height then begin
       result:=StackItem.Height;
      end;
      NewStackItem:=pointer(Stack.PushIndirect);
      NewStackItem^.NodeID:=Node^.Children[1];
      NewStackItem^.Height:=StackItem.Height+1;
      NewStackItem:=pointer(Stack.PushIndirect);
      NewStackItem^.NodeID:=Node^.Children[0];
      NewStackItem^.Height:=StackItem.Height+1;
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.GetHeight:TpvSizeInt;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 if fRoot>=0 then begin
  result:=fNodes[fRoot].Height;
 end else begin
  result:=0;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.GetAreaRatio:TpvDouble;
var NodeID:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=0.0;
 if fRoot>=0 then begin
  for NodeID:=0 to fNodeCount-1 do begin
   Node:=@fNodes[NodeID];
   if Node^.Height>=0 then begin
    result:=result+Node^.AABB.Cost;
   end;
  end;
  result:=result/fNodes[fRoot].AABB.Cost;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.GetMaxBalance:TpvSizeInt;
var NodeID,Balance:TpvSizeInt;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=0;
 if fRoot>=0 then begin
  for NodeID:=0 to fNodeCount-1 do begin
   Node:=@fNodes[NodeID];
   if (Node^.Height>1) and (Node^.Children[0]>=0) and (Node^.Children[1]>=0) then begin
    Balance:=abs(fNodes[Node^.Children[0]].Height-fNodes[Node^.Children[1]].Height);
    if result<Balance then begin
     result:=Balance;
    end;
   end;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.ValidateStructure:boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
      Parent:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem:TStackItem;
    NewStackItem:PStackItem;
    Node:PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=true;
 if fRoot>=0 then begin
  Stack.Initialize;
  try
   NewStackItem:=pointer(Stack.PushIndirect);
   NewStackItem^.NodeID:=fRoot;
   NewStackItem^.Parent:=NULLNODE;
   while Stack.Pop(StackItem) do begin
    if (StackItem.NodeID>=0) and (StackItem.NodeID<fNodeCapacity) then begin
     Node:=@fNodes[StackItem.NodeID];
     if Node^.Parent<>StackItem.Parent then begin
      result:=false;
      break;
     end;
     if Node^.Children[0]<0 then begin
      if (Node^.Children[1]>=0) or (Node^.Height<>0) then begin
       result:=false;
       break;
      end;
     end else begin
      NewStackItem:=pointer(Stack.PushIndirect);
      NewStackItem.NodeID:=Node^.Children[1];
      NewStackItem.Parent:=StackItem.NodeID;
      NewStackItem:=pointer(Stack.PushIndirect);
      NewStackItem.NodeID:=Node^.Children[0];
      NewStackItem.Parent:=StackItem.NodeID;
     end;
    end else begin
     result:=false;
     break;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.ValidateMetrics:boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem:TStackItem;
    NewStackItem:PStackItem;
    Node:PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=true;
 if fRoot>=0 then begin
  Stack.Initialize;
  try
   NewStackItem:=pointer(Stack.PushIndirect);
   NewStackItem^.NodeID:=fRoot;
   while Stack.Pop(StackItem) do begin
    if (StackItem.NodeID>=0) and (StackItem.NodeID<fNodeCapacity) then begin
     Node:=@fNodes[StackItem.NodeID];
     if Node^.Height<>0 then begin
      if (Node^.Children[0]>=0) and (Node^.Children[0]<fNodeCapacity) and
         (Node^.Children[1]>=0) and (Node^.Children[1]<fNodeCapacity) then begin
       if Node^.Height<>(Max(fNodes[Node^.Children[0]].Height,fNodes[Node^.Children[1]].Height)+1) then begin
        result:=false;
        break;
       end else begin
        NewStackItem:=pointer(Stack.PushIndirect);
        NewStackItem^.NodeID:=Node^.Children[1];
        NewStackItem:=pointer(Stack.PushIndirect);
        NewStackItem^.NodeID:=Node^.Children[0];
       end;
      end else begin
       result:=false;
       break;
      end;
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.Validate:boolean;
var NodeID,FreeCount:TpvSizeInt;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=ValidateStructure;
 if result then begin
  result:=ValidateMetrics;
  if result then begin
   result:=ComputeHeight=GetHeight;
   if result then begin
    NodeID:=fFreeList;
    FreeCount:=0;
    while NodeID>=0 do begin
     NodeID:=fNodes[NodeID].Next;
     inc(FreeCount);
    end;
    result:=(fNodeCount+FreeCount)=fNodeCapacity;
   end;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.IntersectionQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=nil;
 if (fNodeCount>0) and (fRoot>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.Intersect(aAABB) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.IntersectionQuery(const aAABB:TpvAABB;const aTreeNodeList:TTreeNodeList):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=false;
 if (fNodeCount>0) and (fRoot>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.Intersect(aAABB) then begin
     if Node^.UserData<>0 then begin
      aTreeNodeList.Add(Node);
      result:=true;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.ContainQuery(const aAABB:TpvAABB):TpvBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=nil;
 if (fNodeCount>0) and (fRoot>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.Contains(aAABB) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.ContainQuery(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=nil;
 if (fNodeCount>0) and (fRoot>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.Contains(aPoint) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.ContainQuery(const aPoint:TpvVector3;const aTreeNodeList:TTreeNodeList):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=false;
 if (fNodeCount>0) and (fRoot>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.Contains(aPoint) then begin
     if Node^.UserData<>0 then begin
      aTreeNodeList.Add(Node);
      result:=true;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.FindClosest(const aPoint:TpvVector3):TpvBVHDynamicAABBTree.PTreeNode;
type TStack=TpvDynamicFastStack<TpvSizeInt>;
var Stack:TStack;
    NodeIndex:TpvSizeInt;
    BestDistance,Distance:TpvFloat;
    TreeNode:TpvBVHDynamicAABBTree.PTreeNode;
    ChildDistances:array[0..1] of TpvFloat;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=nil;
 if fRoot>=0 then begin
  BestDistance:=Infinity;
  Stack.Initialize;
  try
   Stack.Push(fRoot);
   while Stack.Pop(NodeIndex) do begin
    TreeNode:=@fNodes[NodeIndex];
    if TreeNode.UserData>0 then begin
     if assigned(Pointer(TreeNode^.UserData)) then begin
      Distance:=ClosestPointToAABB(TreeNode^.AABB,aPoint,PpvVector3(nil));
      if (not assigned(result)) or (BestDistance>Distance) then begin
       BestDistance:=Distance;
       result:=TreeNode;
       if IsZero(BestDistance) then begin
        Stack.Clear;
        break;
       end;
      end;
     end;
    end;
    if (TreeNode.Children[0]>=0) and
       (TreeNode.Children[1]>=0) then begin
     ChildDistances[0]:=ClosestPointToAABB(fNodes[TreeNode.Children[0]].AABB,aPoint);
     ChildDistances[1]:=ClosestPointToAABB(fNodes[TreeNode.Children[1]].AABB,aPoint);
     if ChildDistances[0]<ChildDistances[1] then begin
      if ChildDistances[0]<=BestDistance then begin
       if ChildDistances[1]<=BestDistance then begin
        Stack.Push(TreeNode.Children[1]);
       end;
       Stack.Push(TreeNode.Children[0]);
      end;
     end else begin
      if ChildDistances[1]<=BestDistance then begin
       if ChildDistances[0]<=BestDistance then begin
        Stack.Push(TreeNode.Children[0]);
       end;
       Stack.Push(TreeNode.Children[1]);
      end;
     end;
    end else begin
     if TreeNode.Children[0]>=0 then begin
      if ClosestPointToAABB(fNodes[TreeNode.Children[0]].AABB,aPoint)<=BestDistance then begin
       Stack.Push(TreeNode.Children[0]);
      end;
     end;
     if TreeNode.Children[1]>=0 then begin
      if ClosestPointToAABB(fNodes[TreeNode.Children[1]].AABB,aPoint)<=BestDistance then begin
       Stack.Push(TreeNode.Children[1]);
      end;
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.GetDistance(const aTreeNode:PTreeNode;const aPoint:TpvVector3):TpvFloat;
begin
 result:=ClosestPointToAABB(aTreeNode^.AABB,aPoint);
end;

function TpvBVHDynamicAABBTree.LookupClosest(const aPoint:TpvVector3;const aTreeNodeList:TTreeNodeList;aGetDistance:TGetDistance;const aMaxCount:TpvSizeInt;aMaxDistance:TpvFloat):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
      Distance:TpvFloat;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
     TResultItem=record
      Node:TpvBVHDynamicAABBTree.PTreeNode;
      Distance:TpvFloat;
     end;
     PResultItem=^TResultItem;
     TResultItemArray=TpvDynamicArray<TResultItem>;
var Stack:TStack;
    NewStackItem:PStackItem;
    StackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
    Index,LowIndex,MidIndex,HighIndex:TpvSizeInt;
    ResultItemArray:TResultItemArray;
    ResultItem:TResultItem;
    DistanceA,DistanceB:TpvFloat;
begin

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;

 // If aMaxDistance is less than or equal to zero, then set it to infinity as default
 if aMaxDistance<=0.0 then begin
  aMaxDistance:=Infinity;
 end;
 
 // If the GetDistance function is not assigned, then assign the default one 
 if not assigned(aGetDistance) then begin
  aGetDistance:=GetDistance;
 end;

 result:=false;

 Stack.Initialize;
 try

  ResultItemArray.Initialize;
  try

   NewStackItem:=Pointer(Stack.PushIndirect);
   NewStackItem^.NodeID:=fRoot;
   NewStackItem^.Distance:=ClosestPointToAABB(fNodes[fRoot].AABB,aPoint);

   while Stack.Pop(StackItem) do begin

    // If this subtree is further away than we care about, or if we've already found enough locations, and the furthest one is closer
    // than this subtree possibly could be, then skip it.
    if (StackItem.Distance<=aMaxDistance) and
       (not ((ResultItemArray.Count=aMaxCount) and (ResultItemArray.Items[ResultItemArray.Count-1].Distance<StackItem.Distance))) then begin

     Node:=@fNodes[StackItem.NodeID];
     if Node^.UserData<>0 then begin

      // Add the node to the result list in a sorted way
      ResultItem.Node:=Node;
      ResultItem.Distance:=aGetDistance(Node,aPoint);
      if (ResultItem.Distance>=0.0) and (ResultItem.Distance<=aMaxDistance) then begin

       if ResultItemArray.Count>0 then begin

        // Binary insertion into the sorted list
        LowIndex:=0;
        HighIndex:=ResultItemArray.Count-1;
        while LowIndex<=HighIndex do begin
         MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1);
         if ResultItemArray.Items[MidIndex].Distance<ResultItem.Distance then begin
          LowIndex:=MidIndex+1;
         end else begin
          HighIndex:=MidIndex-1;
         end;
        end;
        if (LowIndex>=0) and (LowIndex<ResultItemArray.Count) then begin
         ResultItemArray.Insert(LowIndex,ResultItem);
        end else begin
         ResultItemArray.Add(ResultItem);
        end;

       end else begin

        // Add the node to the result list directly if the list is empty
        ResultItemArray.Add(ResultItem);

       end;

 {     // Sort the list so that the closest is first for just to be sure. It should just a linear search check, when the binary search based
       // insertion is working correctly
       Index:=0;
       while (Index+1)<ResultItemArray.Count do begin
        if ResultItemArray.Items[Index].Distance>ResultItemArray.Items[Index+1].Distance then begin
         ResultItemArray.Exchange(Index,Index+1);
         if Index>0 then begin
          dec(Index);
         end else begin
          inc(Index);
         end;
        end else begin
         inc(Index);
        end;
       end;//}

       // Maintain the sorted list within the max count
       while ResultItemArray.Count>aMaxCount do begin
        ResultItemArray.Delete(ResultItemArray.Count-1);
       end;

       result:=true;

      end;

     end;

     // Add the children to the stack in the order of the closest one first
     if Node^.Children[0]>=0 then begin
      DistanceA:=ClosestPointToAABB(fNodes[Node^.Children[0]].AABB,aPoint);
      if Node^.Children[1]>=0 then begin
       DistanceB:=ClosestPointToAABB(fNodes[Node^.Children[1]].AABB,aPoint);
       if DistanceA<DistanceB then begin
        if DistanceB<=aMaxDistance then begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.NodeID:=Node^.Children[1];
         NewStackItem^.Distance:=DistanceB;
        end;
        if DistanceA<=aMaxDistance then begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.NodeID:=Node^.Children[0];
         NewStackItem^.Distance:=DistanceA;
        end;
       end else begin
        if DistanceA<=aMaxDistance then begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.NodeID:=Node^.Children[0];
         NewStackItem^.Distance:=DistanceA;
        end;
        if DistanceB<=aMaxDistance then begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.NodeID:=Node^.Children[1];
         NewStackItem^.Distance:=DistanceB;
        end;
       end;
      end else begin
       if DistanceA<=aMaxDistance then begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.NodeID:=Node^.Children[0];
        NewStackItem^.Distance:=DistanceA;
       end;
      end;
     end else if Node^.Children[1]>=0 then begin
      DistanceB:=ClosestPointToAABB(fNodes[Node^.Children[1]].AABB,aPoint);
      if DistanceB<=aMaxDistance then begin
       NewStackItem:=Pointer(Stack.PushIndirect);
       NewStackItem^.NodeID:=Node^.Children[1];
       NewStackItem^.Distance:=DistanceB;
      end;
     end;

    end;

   end;

   // Copy the result items to the output list
   aTreeNodeList.Clear;
   for Index:=0 to ResultItemArray.Count-1 do begin
    aTreeNodeList.Add(ResultItemArray.Items[Index].Node);
   end;

  finally
   ResultItemArray.Finalize;
  end;

 finally
  Stack.Finalize;
 end;

 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;

end;

function TpvBVHDynamicAABBTree.RayCast(const aRayOrigin,aRayDirection:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
    RayEnd:TpvVector3;
    Time:TpvFloat;
    Stop:boolean;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=false;
 if assigned(aRayCastUserData) and (fNodeCount>0) and (fRoot>=0) then begin
  aTime:=Infinity;
  RayEnd:=aRayOrigin;
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if ((not result) and
        (Node^.AABB.Contains(aRayOrigin) or Node^.AABB.FastRayIntersection(aRayOrigin,aRayDirection))) or
       (result and Node^.AABB.LineIntersection(aRayOrigin,RayEnd)) then begin
     if (Node^.UserData<>0) and aRayCastUserData(Node^.UserData,aRayOrigin,aRayDirection,Time,Stop) then begin
      if (not result) or (Time<aTime) then begin
       aTime:=Time;
       aUserData:=Node^.UserData;
       result:=true;
       if aStopAtFirstHit or Stop then begin
        break;
       end else begin
        RayEnd:=aRayOrigin+(aRayDirection*Time);
       end;
      end;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

function TpvBVHDynamicAABBTree.RayCastLine(const aFrom,aTo:TpvVector3;out aTime:TpvFloat;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvBVHDynamicAABBTree.TRayCastUserData):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicFastStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvBVHDynamicAABBTree.PTreeNode;
    Time,RayLength:TpvFloat;
    RayOrigin,RayDirection,RayEnd:TpvVector3;
    Stop:boolean;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 result:=false;
 if assigned(aRayCastUserData) and (fNodeCount>0) and (fRoot>=0) then begin
  aTime:=Infinity;
  RayOrigin:=aFrom;
  RayEnd:=aTo;
  RayDirection:=(RayEnd-RayOrigin).Normalize;
  RayLength:=(RayEnd-RayOrigin).Length;
  Stack.Initialize;
  try
   NewStackItem.NodeID:=fRoot;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@fNodes[StackItem.NodeID];
    if Node^.AABB.LineIntersection(RayOrigin,RayEnd) then begin
     if (Node^.UserData<>0) and aRayCastUserData(Node^.UserData,RayOrigin,RayDirection,Time,Stop) then begin
      if ((Time>=0.0) and (Time<=RayLength)) and ((not result) or (Time<aTime)) then begin
       aTime:=Time;
       aUserData:=Node^.UserData;
       result:=true;
       if aStopAtFirstHit or Stop then begin
        break;
       end else begin
        RayEnd:=RayOrigin+(RayDirection*Time);
        RayLength:=Time;
       end;
      end;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

procedure TpvBVHDynamicAABBTree.GetSkipListNodes(var aSkipListNodeArray:TSkipListNodeArray;const aGetUserDataIndex:TpvBVHDynamicAABBTree.TGetUserDataIndex);
//const ThresholdVector:TpvVector3=(x:1e-7;y:1e-7;z:1e-7);
var StackItem,NewStackItem:TSkipListNodeStackItem;
    Node:PTreeNode;
    SkipListNode:TSkipListNode;
    SkipListNodeIndex:TpvSizeInt;
begin
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fMultipleReaderSingleWriterLockState);
 end;
 fSkipListNodeLock.Acquire;
 try
  if fRoot>=0 then begin
   if length(fSkipListNodeMap)<length(fNodes) then begin
    SetLength(fSkipListNodeMap,length(fNodes)+((length(fNodes)+1) shr 1));
   end;
   aSkipListNodeArray.Count:=0;
   NewStackItem.Pass:=0;
   NewStackItem.Node:=fRoot;
   fSkipListNodeStack.Push(NewStackItem);
   while fSkipListNodeStack.Pop(StackItem) do begin
    case StackItem.Pass of
     0:begin
      if StackItem.Node>=0 then begin
       Node:=@fNodes[StackItem.Node];
       SkipListNode.AABBMin:=Node^.AABB.Min;
       SkipListNode.AABBMax:=Node^.AABB.Max;
       SkipListNode.SkipCount:=0;
       if Node^.UserData<>0 then begin
        if assigned(aGetUserDataIndex) then begin
         SkipListNode.UserData:=aGetUserDataIndex(Node^.UserData);
        end else begin
         SkipListNode.UserData:=Node^.UserData;
        end;
       end else begin
        SkipListNode.UserData:=High(TpvUInt32);
       end;
       SkipListNodeIndex:=aSkipListNodeArray.Add(SkipListNode);
       fSkipListNodeMap[StackItem.Node]:=SkipListNodeIndex;
       NewStackItem.Pass:=1;
       NewStackItem.Node:=StackItem.Node;
       fSkipListNodeStack.Push(NewStackItem);
       if Node^.Children[1]>=0 then begin
        NewStackItem.Pass:=0;
        NewStackItem.Node:=Node^.Children[1];
        fSkipListNodeStack.Push(NewStackItem);
       end;
       if Node^.Children[0]>=0 then begin
        NewStackItem.Pass:=0;
        NewStackItem.Node:=Node^.Children[0];
        fSkipListNodeStack.Push(NewStackItem);
       end;
      end;
     end;
     1:begin
      if StackItem.Node>=0 then begin
       SkipListNodeIndex:=fSkipListNodeMap[StackItem.Node];
       aSkipListNodeArray.Items[SkipListNodeIndex].SkipCount:=aSkipListNodeArray.Count-SkipListNodeIndex;
      end;
     end;
    end;
   end;
  end;
 finally
  fSkipListNodeLock.Release;
 end;
 if fThreadSafe then begin
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fMultipleReaderSingleWriterLockState);
 end;
end;

end.

