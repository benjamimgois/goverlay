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
unit PasVulkan.CSG.BSP;
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

uses SysUtils,Classes,Math,
     PasVulkan.Types,
     PasVulkan.Math;

type TpvCSGBSP=class
      public
       const Epsilon=1e-5;
             SquaredEpsilon=Epsilon*Epsilon;
             OneMinusEpsilon=1.0-Epsilon;
             OnePlusEpsilon=1.0+Epsilon;
             TJunctionEpsilon=1e-4;
             TJunctionOneMinusEpsilon=1.0-TJunctionEpsilon;
             TJunctionOnePlusEpsilon=1.0+TJunctionEpsilon;
             NearPositionEpsilon=1e-5;
             SquaredNearPositionEpsilon=NearPositionEpsilon*NearPositionEpsilon;
             CSGOptimizationBoundEpsilon=1e-1;
             daabbtNULLNODE=-1;
             AABBMULTIPLIER=2.0;
       type TFloat=TpvDouble;
            PFloat=^TFloat;
            TDynamicArray<T>=record
             public
              Items:array of T;
              Count:TpvSizeInt;
              procedure Initialize;
              procedure Finalize;
              procedure Clear;
              procedure Finish;
              procedure Assign(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>); overload;
              procedure Assign(const aItems:array of T); overload;
              function AddNew:TpvSizeInt; overload;
              function Insert(const aIndex:TpvSizeInt;const aItem:T):TpvSizeInt; overload;
              function Add(const aItem:T):TpvSizeInt; overload;
              function Add(const aItems:array of T):TpvSizeInt; overload;
              function Add(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>):TpvSizeInt; overload;
              function AddRangeFrom(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
              function AssignRangeFrom(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt; overload;
              procedure Exchange(const aIndexA,aIndexB:TpvSizeInt); inline;
              procedure Delete(const aIndex:TpvSizeInt);
            end;
            TDynamicStack<T>=record
             public
              Items:array of T;
              Count:TpvSizeInt;
              procedure Initialize;
              procedure Finalize;
              procedure Push(const aItem:T);
              function Pop(out aItem:T):boolean;
            end;
            TDynamicQueue<T>=record
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
            THashMap<THashMapKey,THashMapValue>=class
             public
              const CELL_EMPTY=-1;
                    CELL_DELETED=-2;
                    ENT_EMPTY=-1;
                    ENT_DELETED=-2;
              type PHashMapEntity=^THashMapEntity;
                   THashMapEntity=record
                    Key:THashMapKey;
                    Value:THashMapValue;
                   end;
                   THashMapEntities=array of THashMapEntity;
                   THashMapEntityIndices=array of TpvSizeInt;
             private
{$ifndef fpc}
              type THashMapEntityEnumerator=record
                    private
                     fHashMap:THashMap<THashMapKey,THashMapValue>;
                     fIndex:TpvSizeInt;
                     function GetCurrent:THashMapEntity; inline;
                    public
                     constructor Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
                     function MoveNext:boolean; inline;
                     property Current:THashMapEntity read GetCurrent;
                   end;
                   THashMapKeyEnumerator=record
                    private
                     fHashMap:THashMap<THashMapKey,THashMapValue>;
                     fIndex:TpvSizeInt;
                     function GetCurrent:THashMapKey; inline;
                    public
                     constructor Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
                     function MoveNext:boolean; inline;
                     property Current:THashMapKey read GetCurrent;
                   end;
                   THashMapValueEnumerator=record
                    private
                     fHashMap:THashMap<THashMapKey,THashMapValue>;
                     fIndex:TpvSizeInt;
                     function GetCurrent:THashMapValue; inline;
                    public
                     constructor Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
                     function MoveNext:boolean; inline;
                     property Current:THashMapValue read GetCurrent;
                   end;
                   THashMapEntitiesObject=class
                    private
                     fOwner:THashMap<THashMapKey,THashMapValue>;
                    public
                     constructor Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
                     function GetEnumerator:THashMapEntityEnumerator;
                   end;
                   THashMapKeysObject=class
                    private
                     fOwner:THashMap<THashMapKey,THashMapValue>;
                    public
                     constructor Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
                     function GetEnumerator:THashMapKeyEnumerator;
                   end;
                   THashMapValuesObject=class
                    private
                     fOwner:THashMap<THashMapKey,THashMapValue>;
                     function GetValue(const aKey:THashMapKey):THashMapValue; inline;
                     procedure SetValue(const aKey:THashMapKey;const aValue:THashMapValue); inline;
                    public
                     constructor Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
                     function GetEnumerator:THashMapValueEnumerator;
                     property Values[const Key:THashMapKey]:THashMapValue read GetValue write SetValue; default;
                   end;
{$endif}
             private
              fRealSize:TpvSizeInt;
              fLogSize:TpvSizeInt;
              fSize:TpvSizeInt;
              fEntities:THashMapEntities;
              fEntityToCellIndex:THashMapEntityIndices;
              fCellToEntityIndex:THashMapEntityIndices;
              fDefaultValue:THashMapValue;
              fCanShrink:boolean;
{$ifndef fpc}
              fEntitiesObject:THashMapEntitiesObject;
              fKeysObject:THashMapKeysObject;
              fValuesObject:THashMapValuesObject;
{$endif}
              function HashData(const aData:TpvPointer;const aDataLength:TpvUInt32):TpvUInt32;
              function FindCell(const aKey:THashMapKey):TpvUInt32;
              procedure Resize;
             protected
              function HashKey(const aKey:THashMapKey):TpvUInt32; virtual;
              function CompareKey(const aKeyA,aKeyB:THashMapKey):boolean; virtual;
              function GetValue(const aKey:THashMapKey):THashMapValue;
              procedure SetValue(const aKey:THashMapKey;const aValue:THashMapValue);
             public
              constructor Create(const aDefaultValue:THashMapValue);
              destructor Destroy; override;
              procedure Clear;
              function Add(const aKey:THashMapKey;const aValue:THashMapValue):PHashMapEntity;
              function Get(const aKey:THashMapKey;const aCreateIfNotExist:boolean=false):PHashMapEntity;
              function TryGet(const aKey:THashMapKey;out aValue:THashMapValue):boolean;
              function ExistKey(const aKey:THashMapKey):boolean;
              function Delete(const aKey:THashMapKey):boolean;
              property EntityValues[const Key:THashMapKey]:THashMapValue read GetValue write SetValue; default;
{$ifndef fpc}
              property Entities:THashMapEntitiesObject read fEntitiesObject;
              property Keys:THashMapKeysObject read fKeysObject;
              property Values:THashMapValuesObject read fValuesObject;
{$endif}
              property CanShrink:boolean read fCanShrink write fCanShrink;
            end;
            TFloatHashMap<TFloatHashMapValue>=class(THashMap<TFloat,TFloatHashMapValue>)
             protected
              function HashKey(const aKey:TFloat):TpvUInt32; override;
              function CompareKey(const aKeyA,aKeyB:TFloat):boolean; override;
            end;
            TSizeIntSparseSet=class
             public
              type TSizeIntArray=array of TpvSizeInt;
             private
              fSize:TpvSizeInt;
              fMaximumSize:TpvSizeInt;
              fSparseToDense:TSizeIntArray;
              fDense:TSizeIntArray;
              function GetValue(const aIndex:TpvSizeInt):TpvSizeInt; inline;
              procedure SetValue(const aIndex:TpvSizeInt;const aValue:TpvSizeInt); inline;
             public
              constructor Create(const aMaximumSize:TpvSizeInt=0);
              destructor Destroy; override;
              procedure Clear;
              procedure Resize(const aNewMaximumSize:TpvSizeInt);
              function Contains(const aValue:TpvSizeInt):boolean;
              procedure Add(const aValue:TpvSizeInt);
              procedure AddNew(const aValue:TpvSizeInt);
              procedure Remove(const aValue:TpvSizeInt);
              property Size:TpvSizeInt read fSize;
              property SparseToDense:TSizeIntArray read fSparseToDense;
              property Dense:TSizeIntArray read fDense;
            end;
            TVector2=record
             public
              x,y:TFloat;
              constructor Create(const aFrom:TpvVector2); overload;
              constructor Create(const aX,aY:TFloat); overload;
              class operator Equal(const aLeft,aRight:TVector2):boolean;
              class operator NotEqual(const aLeft,aRight:TVector2):boolean;
              class operator Add(const aLeft,aRight:TVector2):TVector2;
              class operator Subtract(const aLeft,aRight:TVector2):TVector2;
              class operator Multiply(const aLeft:TVector2;const aRight:TFloat):TVector2;
              class operator Divide(const aLeft:TVector2;const aRight:TFloat):TVector2;
              class operator Negative(const aVector:TVector2):TVector2;
              function Length:TFloat;
              function SquaredLength:TFloat;
              function Lerp(const aWith:TVector2;const aTime:TFloat):TVector2;
              function ToVector:TpvVector2;
            end;
            PVector2=^TVector2;
            TVector3=record
             public
              x,y,z:TFloat;
              constructor Create(const aFrom:TpvVector3); overload;
              constructor Create(const aX,aY,aZ:TFloat); overload;
              class operator Equal(const aLeft,aRight:TVector3):boolean;
              class operator NotEqual(const aLeft,aRight:TVector3):boolean;
              class operator Add(const aLeft,aRight:TVector3):TVector3;
              class operator Subtract(const aLeft,aRight:TVector3):TVector3;
              class operator Multiply(const aLeft:TVector3;const aRight:TFloat):TVector3;
              class operator Divide(const aLeft:TVector3;const aRight:TFloat):TVector3;
              class operator Negative(const aVector:TVector3):TVector3;
              function Cross(const aWith:TVector3):TVector3;
              function Spacing(const aWith:TVector3):TFloat;
              function Dot(const aWith:TVector3):TFloat;
              function Length:TFloat;
              function SquaredLength:TFloat;
              function Lerp(const aWith:TVector3;const aTime:TFloat):TVector3;
              function Normalize:TVector3;
              function Perpendicular:TVector3;
              function ToVector:TpvVector3;
            end;
            PVector3=^TVector3;
            TVector4=record
             public
              x,y,z,w:TFloat;
              constructor Create(const aFrom:TpvVector4); overload;
              constructor Create(const aX,aY,aZ,aW:TFloat); overload;
              class operator Equal(const aLeft,aRight:TVector4):boolean;
              class operator NotEqual(const aLeft,aRight:TVector4):boolean;
              class operator Add(const aLeft,aRight:TVector4):TVector4;
              class operator Subtract(const aLeft,aRight:TVector4):TVector4;
              class operator Multiply(const aLeft:TVector4;const aRight:TFloat):TVector4;
              class operator Divide(const aLeft:TVector4;const aRight:TFloat):TVector4;
              class operator Negative(const aVector:TVector4):TVector4;
              function Length:TFloat;
              function SquaredLength:TFloat;
              function Lerp(const aWith:TVector4;const aTime:TFloat):TVector4;
              function ToVector:TpvVector4;
            end;
            PVector4=^TVector4;
            TVertex=record
             public
              Position:TVector3;
              Normal:TVector3;
              TexCoord:TVector4;
              Color:TVector4;
              class operator Equal(const aLeft,aRight:TVertex):boolean;
              class operator NotEqual(const aLeft,aRight:TVertex):boolean;
              class operator Add(const aLeft,aRight:TVertex):TVertex;
              class operator Subtract(const aLeft,aRight:TVertex):TVertex;
              class operator Multiply(const aLeft:TVertex;const aRight:TFloat):TVertex;
              class operator Divide(const aLeft:TVertex;const aRight:TFloat):TVertex;
              class operator Negative(const aLeft:TVertex):TVertex;
              function Lerp(const aWith:TVertex;const aTime:TFloat):TVertex;
              procedure Flip;
              function CloneFlip:TVertex;
              function Normalize:TVertex;
            end;
            TAABB=packed record
             public
              function Cost:TFloat;
              function Combine(const aAABB:TAABB):TAABB; overload;
              function Combine(const aVector:TVector3):TAABB; overload;
              function Contains(const aAABB:TAABB;const aThreshold:TFloat=0.0):boolean;
              function Intersects(const aAABB:TAABB;const aThreshold:TFloat=Epsilon):boolean;
              function Intersection(const aAABB:TAABB;const aThreshold:TFloat=0.0):TAABB;
             public
              case boolean of
               false:(
                Min:TVector3;
                Max:TVector3;
               );
               true:(
                MinMax:array[0..1] of TVector3;
               );
            end;
            PAABB=^TAABB;
            PVertex=^TVertex;
            TVertexList=TDynamicArray<TVertex>;
            PVertexList=^TVertexList;
            TIndex=TpvSizeInt;
            PIndex=^TIndex;
            TIndexList=TDynamicArray<TIndex>;
            PIndexList=^TIndexList;
            TPlane=record
             public
              Normal:TVector3;
              Distance:TFloat;
              constructor Create(const aV0,aV1,aV2:TVector3); overload;
              constructor Create(const aNormal:TVector3;const aDistance:TFloat); overload;
              class function CreateEmpty:TPlane; static;
              function DistanceTo(const aWith:TVector3):TFloat;
              function IntersectWithPointToPoint(const aPointA,aPointB:TVector3;const aIntersectionPoint:PVector3=nil):boolean; overload;
              function IntersectWithPointToPoint(const aPointA,aPointB:TVertex;const aIntersectionPoint:PVertex=nil):boolean; overload;
              function OK:boolean;
              function Flip:TPlane;
              procedure SplitTriangles(var aVertices:TVertexList;
                                       const aIndices:TIndexList;
                                       const aCoplanarBackList:PIndexList;
                                       const aCoplanarFrontList:PIndexList;
                                       const aBackList:PIndexList;
                                       const aFrontList:PIndexList);
              procedure SplitPolygons(var aVertices:TVertexList;
                                      const aIndices:TIndexList;
                                      const aCoplanarBackList:PIndexList;
                                      const aCoplanarFrontList:PIndexList;
                                      const aBackList:PIndexList;
                                      const aFrontList:PIndexList);
            end;
            PPlane=^TPlane;
            PDynamicAABBTreeNode=^TDynamicAABBTreeNode;
            TDynamicAABBTreeNode=record
             AABB:TAABB;
             UserData:TpvPtrInt;
             Children:array[0..1] of TpvSizeInt;
             Height:TpvSizeInt;
             case boolean of
              false:(
               Parent:TpvSizeInt;
              );
              true:(
               Next:TpvSizeInt;
              );
            end;
            PDynamicAABBTreeNodes=^TDynamicAABBTreeNodes;
            TDynamicAABBTreeNodes=array[0..0] of TDynamicAABBTreeNode;
            PDynamicAABBTreeSizeIntArray=^TDynamicAABBTreeSizeIntArray;
            TDynamicAABBTreeSizeIntArray=array[0..65535] of TpvSizeInt;
            TDynamicAABBFrozenTreeNode=record
             Left:TpvSizeInt;
             Right:TpvSizeInt;
             AABB:TAABB;
             UserData:pointer;
            end;
            TDynamicAABBTree=class
             public
              Root:TpvSizeInt;
              Nodes:PDynamicAABBTreeNodes;
              NodeCount:TpvSizeInt;
              NodeCapacity:TpvSizeInt;
              FreeList:TpvSizeInt;
              Path:TpvSizeUInt;
              InsertionCount:TpvSizeInt;
              Stack:PDynamicAABBTreeSizeIntArray;
              StackCapacity:TpvSizeInt;
              constructor Create;
              destructor Destroy; override;
              function AllocateNode:TpvSizeInt;
              procedure FreeNode(const aNodeID:TpvSizeInt);
              function Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
              procedure InsertLeaf(const aLeaf:TpvSizeInt);
              procedure RemoveLeaf(const aLeaf:TpvSizeInt);
              function CreateProxy(const aAABB:TAABB;const aUserData:TpvPtrInt):TpvSizeInt;
              procedure DestroyProxy(const aNodeID:TpvSizeInt);
              function MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TAABB;const aDisplacement:TVector3):boolean;
              procedure Rebalance(const aIterations:TpvSizeInt);
            end;
            TSplitSettings=record
             SearchBestFactor:TFloat;
             PolygonSplitCost:TFloat;
             PolygonImbalanceCost:TFloat;
            end;
            PSplitSettings=^TSplitSettings;
            TVector3HashMap<TVector3HashMapValue>=class(TpvCSGBSP.THashMap<TpvCSGBSP.TVector3,TVector3HashMapValue>)
             protected
              function HashKey(const aKey:TpvCSGBSP.TVector3):TpvUInt32; override;
              function CompareKey(const aKeyA,aKeyB:TpvCSGBSP.TVector3):boolean; override;
            end;
            TSingleTreeNode=class;
            TDualTree=class;
            TMesh=class
             public
              type TCSGOperation=
                    (
                     Union,
                     Subtraction,
                     Intersection
                    );
                   PCSGOperation=^TCSGOperation;
                   TCSGMode=(
                    SingleTree,
                    DualTree,
                    Triangles
                   );
                   PCSGMode=^TCSGMode;
                   TCSGOptimization=(
                    None,
                    CSG,
                    Polygons
                   );
                   PCSGOptimization=^TCSGOptimization;
                   TMode=
                    (
                     Triangles,
                     Polygons
                    );
                   PMode=^TMode;
             private
              fMode:TMode;
              fVertices:TVertexList;
              fIndices:TIndexList;
              fPointerToVertices:PVertexList;
              fPointerToIndices:PIndexList;
              procedure SetMode(const aMode:TMode);
              procedure SetVertices(const aVertices:TVertexList);
              procedure SetIndices(const aIndices:TIndexList);
              procedure TriangleCSGOperation(const aLeftNode:TSingleTreeNode;
                                             const aRightNode:TSingleTreeNode;
                                             const aVertices:TVertexList;
                                             const aInside:boolean;
                                             const aKeepEdge:boolean;
                                             const aInvert:boolean);
              procedure FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(const aOuterLeftMesh:TMesh;
                                                                                 const aInnerLeftMesh:TMesh;
                                                                                 const aInsideRangeAABB:TAABB);
              procedure DoUnion(const aLeftMesh:TMesh;
                                const aRightMesh:TMesh;
                                const aCSGMode:TCSGMode;
                                const aSplitSettings:PSplitSettings=nil);
              procedure DoSubtraction(const aLeftMesh:TMesh;
                                      const aRightMesh:TMesh;
                                      const aCSGMode:TCSGMode;
                                      const aSplitSettings:PSplitSettings=nil);
              procedure DoIntersection(const aLeftMesh:TMesh;
                                       const aRightMesh:TMesh;
                                       const aCSGMode:TCSGMode;
                                       const aSplitSettings:PSplitSettings=nil);
             public
              constructor Create(const aMode:TMode=TMode.Polygons); reintroduce; overload;
              constructor Create(const aFrom:TMesh); reintroduce; overload;
              constructor Create(const aFrom:TSingleTreeNode); reintroduce; overload;
              constructor Create(const aFrom:TDualTree); reintroduce; overload;
              constructor Create(const aFrom:TAABB;const aMode:TMode=TMode.Polygons;const aAdditionalBounds:TFloat=0.0); reintroduce; overload;
              constructor CreateCube(const aCX,aCY,aCZ,aRX,aRY,aRZ:TFloat;const aMode:TMode=TMode.Polygons);
              constructor CreateSphere(const aCX,aCY,aCZ,aRadius:TFloat;const aSlices:TpvSizeInt=16;const aStacks:TpvSizeInt=8;const aMode:TMode=TMode.Polygons);
              constructor CreateFromCSGOperation(const aLeftMesh:TMesh;
                                                 const aRightMesh:TMesh;
                                                 const aCSGOperation:TCSGOperation;
                                                 const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                                 const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                                 const aSplitSettings:PSplitSettings=nil);
              constructor CreateUnion(const aLeftMesh:TMesh;
                                      const aRightMesh:TMesh;
                                      const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                      const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                      const aSplitSettings:PSplitSettings=nil);
              constructor CreateSubtraction(const aLeftMesh:TMesh;
                                            const aRightMesh:TMesh;
                                            const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                            const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                            const aSplitSettings:PSplitSettings=nil);
              constructor CreateIntersection(const aLeftMesh:TMesh;
                                             const aRightMesh:TMesh;
                                             const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                             const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                             const aSplitSettings:PSplitSettings=nil);
              constructor CreateSymmetricDifference(const aLeftMesh:TMesh;
                                                    const aRightMesh:TMesh;
                                                    const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                                    const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                                    const aSplitSettings:PSplitSettings=nil);
              destructor Destroy; override;
              procedure SaveOBJToStream(const aStream:TStream);
              procedure SaveOBJToFile(const aFileName:string);
              procedure Clear;
              procedure Assign(const aFrom:TMesh); overload;
              procedure Assign(const aFrom:TSingleTreeNode); overload;
              procedure Assign(const aFrom:TDualTree); overload;
              procedure Append(const aFrom:TMesh); overload;
              procedure Append(const aFrom:TSingleTreeNode); overload;
              procedure Append(const aFrom:TDualTree); overload;
              function AddVertex(const aVertex:TVertex):TIndex;
              function AddVertices(const aVertices:array of TVertex):TIndex; overload;
              function AddVertices(const aVertices:TVertexList):TIndex; overload;
              function AddIndex(const aIndex:TIndex):TpvSizeInt;
              function AddIndices(const aIndices:array of TIndex):TpvSizeInt; overload;
              function AddIndices(const aIndices:TIndexList):TpvSizeInt; overload;
              function GetAxisAlignedBoundingBox:TAABB;
              procedure Invert;
              procedure ConvertToPolygons;
              procedure ConvertToTriangles;
              procedure RemoveNearDuplicateIndices(var aIndices:TIndexList);
              procedure Union(const aLeftMesh:TMesh;
                              const aRightMesh:TMesh;
                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                              const aSplitSettings:PSplitSettings=nil); overload;
              procedure Union(const aWithMesh:TMesh;
                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                              const aSplitSettings:PSplitSettings=nil); overload;
              procedure UnionOf(const aMeshs:array of TMesh;
                                const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                const aSplitSettings:PSplitSettings=nil);
              procedure Subtraction(const aLeftMesh:TMesh;
                                    const aRightMesh:TMesh;
                                    const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                    const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                    const aSplitSettings:PSplitSettings=nil); overload;
              procedure Subtraction(const aWithMesh:TMesh;
                                    const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                    const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                    const aSplitSettings:PSplitSettings=nil); overload;
              procedure SubtractionOf(const aMeshs:array of TMesh;
                                      const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                      const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                      const aSplitSettings:PSplitSettings=nil);
              procedure Intersection(const aLeftMesh:TMesh;
                                     const aRightMesh:TMesh;
                                     const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                     const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                     const aSplitSettings:PSplitSettings=nil); overload;
              procedure Intersection(const aWithMesh:TMesh;
                                     const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                     const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                     const aSplitSettings:PSplitSettings=nil); overload;
              procedure IntersectionOf(const aMeshs:array of TMesh;
                                       const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                       const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                       const aSplitSettings:PSplitSettings=nil);
              procedure SymmetricDifference(const aLeftMesh:TMesh;
                                            const aRightMesh:TMesh;
                                            const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                            const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                            const aSplitSettings:PSplitSettings=nil); overload;
              procedure SymmetricDifference(const aWithMesh:TMesh;
                                            const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                            const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                            const aSplitSettings:PSplitSettings=nil); overload;
              procedure SymmetricDifferenceOf(const aMeshs:array of TMesh;
                                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                              const aSplitSettings:PSplitSettings=nil);
              procedure Canonicalize;
              procedure CalculateNormals(const aCreasedNormalAngleThreshold:TFloat=90.0;
                                         const aSoftNormals:boolean=true;
                                         const aAreaWeighting:boolean=true;
                                         const aAngleWeighting:boolean=true;
                                         const aCreasedNormalAngleWeighting:boolean=true;
                                         const aCheckForCreasedNormals:boolean=true);
              procedure RemoveDuplicateAndUnusedVertices;
              procedure FixTJunctions(const aConsistentInputVertices:boolean=false);
              procedure MergeCoplanarConvexPolygons;
              procedure Optimize;
              function ToSingleTreeNode(const aSplitSettings:PSplitSettings=nil):TSingleTreeNode;
              function ToDualTree(const aSplitSettings:PSplitSettings=nil):TDualTree;
             public
              property Vertices:TVertexList read fVertices write SetVertices;
              property Indices:TIndexList read fIndices write SetIndices;
              property PointerToVertices:PVertexList read fPointerToVertices;
              property PointerToIndices:PIndexList read fPointerToIndices;
             published
              property Mode:TMode read fMode write SetMode;
            end;
            TSingleTreeNode=class
             private
              fIndices:TIndexList;
              fPointerToIndices:PIndexList;
              fMesh:TMesh;
              fBack:TSingleTreeNode;
              fFront:TSingleTreeNode;
              fPlane:TPlane;
              procedure SetIndices(const aIndices:TIndexList);
             public
              constructor Create(const aMesh:TMesh); reintroduce;
              destructor Destroy; override;
              procedure Invert;
              procedure EvaluateSplitPlane(const aPlane:TPlane;
                                           out aCountPolygonsSplits:TpvSizeInt;
                                           out aCountBackPolygons:TpvSizeInt;
                                           out aCountFrontPolygons:TpvSizeInt);
              function FindSplitPlane(const aIndices:TIndexList;
                                      const aSplitSettings:PSplitSettings):TPlane;
              function ClipPolygons(var aVertices:TVertexList;const aIndices:TIndexList):TIndexList;
              procedure ClipTo(const aNode:TSingleTreeNode);
              procedure Merge(const aNode:TSingleTreeNode;
                              const aSplitSettings:PSplitSettings=nil);
              procedure Build(const aIndices:TIndexList;
                              const aSplitSettings:PSplitSettings=nil);
              function ToMesh:TMesh;
             public
              property Plane:TPlane read fPlane write fPlane;
              property Indices:TIndexList read fIndices write SetIndices;
              property PointerToIndices:PIndexList read fPointerToIndices;
             published
              property Mesh:TMesh read fMesh write fMesh;
              property Back:TSingleTreeNode read fBack write fBack;
              property Front:TSingleTreeNode read fFront write fFront;
            end;
            TDualTree=class
             public
              type TPolygon=record
                    public
                     Indices:TIndexList;
                     procedure Invert;
                   end;
                   PPolygon=^TPolygon;
                   TPolygonList=TDynamicArray<TPolygon>;
                   PPolygonList=^TPolygonList;
                   TPolygonNode=class;
                   TPolygonNodeList=TDynamicArray<TPolygonNode>;
                   PPolygonNodeList=^TPolygonNodeList;
                   TPolygonNode=class
                    private
                     fTree:TDualTree;
                     fParent:TDualTree.TPolygonNode;
                     fParentPrevious:TDualTree.TPolygonNode;
                     fParentNext:TDualTree.TPolygonNode;
                     fAllPrevious:TDualTree.TPolygonNode;
                     fAllNext:TDualTree.TPolygonNode;
                     fFirstChild:TDualTree.TPolygonNode;
                     fLastChild:TDualTree.TPolygonNode;
                     fRemoved:boolean;
                     fPolygon:TPolygon;
                    public
                     constructor Create(const aTree:TDualTree;const aParent:TDualTree.TPolygonNode); reintroduce;
                     destructor Destroy; override;
                     procedure RemoveFromParent;
                     function AddPolygon(const aPolygon:TPolygon):TDualTree.TPolygonNode;
                     function AddPolygonIndices(const aIndices:TIndexList):TDualTree.TPolygonNode;
                     procedure Remove;
                     procedure Invert;
                     procedure DrySplitByPlane(const aPlane:TPlane;var aCountSplits,aCoplanarBackList,aCoplanarFrontList,aBackList,aFrontList:TpvSizeInt);
                     procedure SplitByPlane(const aPlane:TPlane;var aCoplanarBackList,aCoplanarFrontList,aBackList,aFrontList:TPolygonNodeList);
                    published
                     property Tree:TDualTree read fTree write fTree;
                     property Parent:TDualTree.TPolygonNode read fParent;
                     property Removed:boolean read fRemoved;
                   end;
                   TNode=class
                    private
                     fTree:TDualTree;
                     fBack:TDualTree.TNode;
                     fFront:TDualTree.TNode;
                     fPlane:TPlane;
                     fPolygonNodes:TPolygonNodeList;
                     fIndices:TIndexList;
                    public
                     constructor Create(const aTree:TDualTree); reintroduce;
                     destructor Destroy; override;
                     procedure Invert;
                     procedure ClipPolygons(const aPolygonNodes:TPolygonNodeList;const aAlsoRemoveCoplanarFront:boolean=false);
                     procedure ClipTo(const aTree:TDualTree;const aAlsoRemoveCoplanarFront:boolean=false);
                     function FindSplitPlane(const aPolygonNodes:TPolygonNodeList):TPlane;
                     procedure AddPolygonNodes(const aPolygonNodes:TPolygonNodeList);
                     procedure AddIndices(const aIndices:TIndexList);
                    public
                     property Plane:TPlane read fPlane write fPlane;
                    published
                     property Tree:TDualTree read fTree write fTree;
                     property Back:TDualTree.TNode read fBack write fBack;
                     property Front:TDualTree.TNode read fFront write fFront;
                   end;
             private
              fMesh:TMesh;
              fSplitSettings:TSplitSettings;
              fFirstPolygonNode:TDualTree.TPolygonNode;
              fLastPolygonNode:TDualTree.TPolygonNode;
              fPolygonRootNode:TDualTree.TPolygonNode;
              fRootNode:TDualTree.TNode;
             public
              constructor Create(const aMesh:TMesh;const aSplitSettings:PSplitSettings=nil); reintroduce;
              destructor Destroy; override;
              procedure Invert;
              procedure ClipTo(const aWithTree:TDualTree;const aAlsoRemoveCoplanarFront:boolean=false);
              procedure AddPolygons(const aPolygons:TPolygonList);
              procedure AddIndices(const aIndices:TIndexList);
              procedure GetPolygons(var aPolygons:TPolygonList);
              procedure GetIndices(var aIndices:TIndexList);
              procedure Merge(const aTree:TDualTree);
              function ToMesh:TMesh;
            end;
      public
       const DefaultSplitSettings:TSplitSettings=
              (
               SearchBestFactor:0.0;
               PolygonSplitCost:1.0;
               PolygonImbalanceCost:0.25;
              );
             ThresholdAABBVector:TVector3=(x:AABBEPSILON;y:AABBEPSILON;z:AABBEPSILON);
      public
       class function EpsilonSign(const aValue:TFloat):TpvSizeInt; static;
     end;


implementation

{ TpvCSGBSP }

class function TpvCSGBSP.EpsilonSign(const aValue:TFloat):TpvSizeInt;
begin
 if aValue<-Epsilon then begin
  result:=-1;
 end else if aValue>Epsilon then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

{ TpvCSGBSP.TDynamicArray<T> }

procedure TpvCSGBSP.TDynamicArray<T>.Initialize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvCSGBSP.TDynamicArray<T>.Finalize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvCSGBSP.TDynamicArray<T>.Clear;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvCSGBSP.TDynamicArray<T>.Finish;
begin
 SetLength(Items,Count);
end;

procedure TpvCSGBSP.TDynamicArray<T>.Assign(const aFrom:TpvCSGBSP.TDynamicArray<T>);
begin
 Items:=copy(aFrom.Items);
 Count:=aFrom.Count;
end;

procedure TpvCSGBSP.TDynamicArray<T>.Assign(const aItems:array of T);
var Index:TpvSizeInt;
begin
 Count:=length(aItems);
 SetLength(Items,Count);
 for Index:=0 to Count-1 do begin
  Items[Index]:=aItems[Index];
 end;
end;

function TpvCSGBSP.TDynamicArray<T>.Insert(const aIndex:TpvSizeInt;const aItem:T):TpvSizeInt;
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

function TpvCSGBSP.TDynamicArray<T>.AddNew:TpvSizeInt;
begin
 result:=Count;
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 System.Initialize(Items[Count]);
 inc(Count);
end;

function TpvCSGBSP.TDynamicArray<T>.Add(const aItem:T):TpvSizeInt;
begin
 result:=Count;
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 Items[Count]:=aItem;
 inc(Count);
end;

function TpvCSGBSP.TDynamicArray<T>.Add(const aItems:array of T):TpvSizeInt;
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

function TpvCSGBSP.TDynamicArray<T>.Add(const aFrom:TpvCSGBSP.TDynamicArray<T>):TpvSizeInt;
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

function TpvCSGBSP.TDynamicArray<T>.AddRangeFrom(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
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

function TpvCSGBSP.TDynamicArray<T>.AssignRangeFrom(const aFrom:{$ifdef fpc}TpvCSGBSP.{$endif}TDynamicArray<T>;const aStartIndex,aCount:TpvSizeInt):TpvSizeInt;
begin
 Clear;
 result:=AddRangeFrom(aFrom,aStartIndex,aCount);
end;

procedure TpvCSGBSP.TDynamicArray<T>.Exchange(const aIndexA,aIndexB:TpvSizeInt);
var Temp:T;
begin
 Temp:=Items[aIndexA];
 Items[aIndexA]:=Items[aIndexB];
 Items[aIndexB]:=Temp;
end;

procedure TpvCSGBSP.TDynamicArray<T>.Delete(const aIndex:TpvSizeInt);
begin
 if (Count>0) and (aIndex<Count) then begin
  dec(Count);
  System.Finalize(Items[aIndex]);
  Move(Items[aIndex+1],Items[aIndex],SizeOf(T)*(Count-aIndex));
  FillChar(Items[Count],SizeOf(T),#0);
 end;
end;

{ TpvCSGBSP.TDynamicStack<T> }

procedure TpvCSGBSP.TDynamicStack<T>.Initialize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvCSGBSP.TDynamicStack<T>.Finalize;
begin
 Items:=nil;
 Count:=0;
end;

procedure TpvCSGBSP.TDynamicStack<T>.Push(const aItem:T);
begin
 if length(Items)<(Count+1) then begin
  SetLength(Items,(Count+1)+((Count+1) shr 1));
 end;
 Items[Count]:=aItem;
 inc(Count);
end;

function TpvCSGBSP.TDynamicStack<T>.Pop(out aItem:T):boolean;
begin
 result:=Count>0;
 if result then begin
  dec(Count);
  aItem:=Items[Count];
 end;
end;

{ TpvCSGBSP.TDynamicQueue<T> }

procedure TpvCSGBSP.TDynamicQueue<T>.Initialize;
begin
 Items:=nil;
 Head:=0;
 Tail:=0;
 Count:=0;
 Size:=0;
end;

procedure TpvCSGBSP.TDynamicQueue<T>.Finalize;
begin
 Clear;
end;

procedure TpvCSGBSP.TDynamicQueue<T>.GrowResize(const aSize:TpvSizeInt);
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

procedure TpvCSGBSP.TDynamicQueue<T>.Clear;
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

function TpvCSGBSP.TDynamicQueue<T>.IsEmpty:boolean;
begin
 result:=Count=0;
end;

procedure TpvCSGBSP.TDynamicQueue<T>.EnqueueAtFront(const aItem:T);
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

procedure TpvCSGBSP.TDynamicQueue<T>.Enqueue(const aItem:T);
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

function TpvCSGBSP.TDynamicQueue<T>.Dequeue(out aItem:T):boolean;
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

function TpvCSGBSP.TDynamicQueue<T>.Dequeue:boolean;
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

function TpvCSGBSP.TDynamicQueue<T>.Peek(out aItem:T):boolean;
begin
 result:=Count>0;
 if result then begin
  aItem:=Items[Head];
 end;
end;

{ TpvCSGBSP.THashMap }

{$warnings off}
{$hints off}

{$ifndef fpc}
constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapEntityEnumerator.Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapEntityEnumerator.GetCurrent:THashMapEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapEntityEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntityToCellIndex[fIndex]<>CELL_EMPTY then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapKeyEnumerator.Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapKeyEnumerator.GetCurrent:THashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapKeyEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntityToCellIndex[fIndex]<>CELL_EMPTY then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValueEnumerator.Create(const aHashMap:THashMap<THashMapKey,THashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValueEnumerator.GetCurrent:THashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValueEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntityToCellIndex[fIndex]<>CELL_EMPTY then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapEntitiesObject.Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapEntitiesObject.GetEnumerator:THashMapEntityEnumerator;
begin
 result:=THashMapEntityEnumerator.Create(fOwner);
end;

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapKeysObject.Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapKeysObject.GetEnumerator:THashMapKeyEnumerator;
begin
 result:=THashMapKeyEnumerator.Create(fOwner);
end;

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValuesObject.Create(const aOwner:THashMap<THashMapKey,THashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValuesObject.GetEnumerator:THashMapValueEnumerator;
begin
 result:=THashMapValueEnumerator.Create(fOwner);
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValuesObject.GetValue(const aKey:THashMapKey):THashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.THashMapValuesObject.SetValue(const aKey:THashMapKey;const aValue:THashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;
{$endif}

constructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Create(const aDefaultValue:THashMapValue);
begin
 inherited Create;
 fRealSize:=0;
 fLogSize:=0;
 fSize:=0;
 fEntities:=nil;
 fEntityToCellIndex:=nil;
 fCellToEntityIndex:=nil;
 fDefaultValue:=aDefaultValue;
 fCanShrink:=true;
{$ifndef fpc}
 fEntitiesObject:=THashMapEntitiesObject.Create(self);
 fKeysObject:=THashMapKeysObject.Create(self);
 fValuesObject:=THashMapValuesObject.Create(self);
{$endif}
 Resize;
end;

destructor TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Destroy;
var Counter:TpvInt32;
begin
 Clear;
 for Counter:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Counter].Key);
  Finalize(fEntities[Counter].Value);
 end;
 SetLength(fEntities,0);
 SetLength(fEntityToCellIndex,0);
 SetLength(fCellToEntityIndex,0);
{$ifndef fpc}
 FreeAndNil(fEntitiesObject);
 FreeAndNil(fKeysObject);
 FreeAndNil(fValuesObject);
{$endif}
 inherited Destroy;
end;

procedure TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Clear;
var Counter:TpvInt32;
begin
 for Counter:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Counter].Key);
  Finalize(fEntities[Counter].Value);
 end;
 if fCanShrink then begin
  fRealSize:=0;
  fLogSize:=0;
  fSize:=0;
  SetLength(fEntities,0);
  SetLength(fEntityToCellIndex,0);
  SetLength(fCellToEntityIndex,0);
  Resize;
 end else begin
  for Counter:=0 to length(fCellToEntityIndex)-1 do begin
   fCellToEntityIndex[Counter]:=ENT_EMPTY;
  end;
  for Counter:=0 to length(fEntityToCellIndex)-1 do begin
   fEntityToCellIndex[Counter]:=CELL_EMPTY;
  end;
 end;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.HashData(const aData:TpvPointer;const aDataLength:TpvUInt32):TpvUInt32;
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

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.HashKey(const aKey:THashMapKey):TpvUInt32;
var p:TpvUInt64;
begin
 // We're hoping here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
 case SizeOf(THashMapKey) of
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
  else begin
   result:=HashData(PpvUInt8(TpvPointer(@aKey)),SizeOf(THashMapKey));
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

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.CompareKey(const aKeyA,aKeyB:THashMapKey):boolean;
var Index:TpvInt32;
    pA,pB:PpvUInt8Array;
begin
 // We're hoping also here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
 case SizeOf(THashMapKey) of
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
  else begin
   Index:=0;
   pA:=@aKeyA;
   pB:=@aKeyB;
   while (Index+SizeOf(TpvUInt32))<SizeOf(THashMapKey) do begin
    if TpvUInt32(TpvPointer(@pA^[Index])^)<>TpvUInt32(TpvPointer(@pB^[Index])^) then begin
     result:=false;
     exit;
    end;
    inc(Index,SizeOf(TpvUInt32));
   end;
   while (Index+SizeOf(UInt8))<SizeOf(THashMapKey) do begin
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

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.FindCell(const aKey:THashMapKey):TpvUInt32;
var HashCode,Mask,Step:TpvUInt32;
    Entity:TpvInt32;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if fLogSize<>0 then begin
  result:=HashCode shr (32-fLogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=fCellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and CompareKey(fEntities[Entity].Key,aKey)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TpvInt32;
    OldEntities:THashMapEntities;
    OldCellToEntityIndex:THashMapEntityIndices;
    OldEntityToCellIndex:THashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=fRealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 fSize:=0;
 fRealSize:=0;
 fLogSize:=NewLogSize;
 OldEntities:=fEntities;
 OldCellToEntityIndex:=fCellToEntityIndex;
 OldEntityToCellIndex:=fEntityToCellIndex;
 fEntities:=nil;
 fCellToEntityIndex:=nil;
 fEntityToCellIndex:=nil;
 SetLength(fEntities,2 shl fLogSize);
 SetLength(fCellToEntityIndex,2 shl fLogSize);
 SetLength(fEntityToCellIndex,2 shl fLogSize);
 for Counter:=0 to length(fCellToEntityIndex)-1 do begin
  fCellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(fEntityToCellIndex)-1 do begin
  fEntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 for Counter:=0 to length(OldEntities)-1 do begin
  Finalize(OldEntities[Counter].Key);
  Finalize(OldEntities[Counter].Value);
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Add(const aKey:THashMapKey;const aValue:THashMapValue):PHashMapEntity;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 result:=nil;
 while fRealSize>=(1 shl fLogSize) do begin
  Resize;
 end;
 Cell:=FindCell(aKey);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@fEntities[Entity];
  result^.Key:=aKey;
  result^.Value:=aValue;
  exit;
 end;
 Entity:=fSize;
 inc(fSize);
 if Entity<(2 shl fLogSize) then begin
  fCellToEntityIndex[Cell]:=Entity;
  fEntityToCellIndex[Entity]:=Cell;
  inc(fRealSize);
  result:=@fEntities[Entity];
  result^.Key:=aKey;
  result^.Value:=aValue;
 end;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Get(const aKey:THashMapKey;const aCreateIfNotExist:boolean=false):PHashMapEntity;
var Entity:TpvInt32;
    Cell:TpvUInt32;
    Value:THashMapValue;
begin
 result:=nil;
 Cell:=FindCell(aKey);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@fEntities[Entity];
 end else if aCreateIfNotExist then begin
  Initialize(Value);
  result:=Add(aKey,Value);
 end;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.TryGet(const aKey:THashMapKey;out aValue:THashMapValue):boolean;
var Entity:TpvInt32;
begin
 Entity:=fCellToEntityIndex[FindCell(aKey)];
 result:=Entity>=0;
 if result then begin
  aValue:=fEntities[Entity].Value;
 end else begin
  Initialize(aValue);
 end;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.ExistKey(const aKey:THashMapKey):boolean;
begin
 result:=fCellToEntityIndex[FindCell(aKey)]>=0;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.Delete(const aKey:THashMapKey):boolean;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 result:=false;
 Cell:=FindCell(aKey);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  Finalize(fEntities[Entity].Key);
  Finalize(fEntities[Entity].Value);
  fEntityToCellIndex[Entity]:=CELL_DELETED;
  fCellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.GetValue(const aKey:THashMapKey):THashMapValue;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 Cell:=FindCell(aKey);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=fEntities[Entity].Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TpvCSGBSP.THashMap<THashMapKey,THashMapValue>.SetValue(const aKey:THashMapKey;const aValue:THashMapValue);
begin
 Add(aKey,aValue);
end;

{ TpvCSGBSP.TFloatHashMap }

function TpvCSGBSP.TFloatHashMap<TFloatHashMapValue>.HashKey(const aKey:TFloat):TpvUInt32;
begin
 result:=trunc(aKey*4096)*73856093;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function TpvCSGBSP.TFloatHashMap<TFloatHashMapValue>.CompareKey(const aKeyA,aKeyB:TFloat):boolean;
begin
 result:=SameValue(aKeyA,aKeyB);
end;

{ TpvCSGBSP.TVector3HashMap }

function TpvCSGBSP.TVector3HashMap<TVector3HashMapValue>.HashKey(const aKey:TVector3):TpvUInt32;
begin
 result:=(trunc(aKey.x*4096)*73856093) xor
         (trunc(aKey.y*4096)*19349653) xor
         (trunc(aKey.z*4096)*83492791);
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function TpvCSGBSP.TVector3HashMap<TVector3HashMapValue>.CompareKey(const aKeyA,aKeyB:TVector3):boolean;
begin
 result:=SameValue(aKeyA.x,aKeyB.x) and
         SameValue(aKeyA.y,aKeyB.y) and
         SameValue(aKeyA.z,aKeyB.z);
end;

{$warnings on}
{$hints on}

{ TpvCSGBSP.TSizeIntSparseSet }

constructor TpvCSGBSP.TSizeIntSparseSet.Create(const aMaximumSize:TpvSizeInt=0);
begin
 inherited Create;
 fSize:=0;
 fMaximumSize:=aMaximumSize;
 fSparseToDense:=nil;
 fDense:=nil;
 SetLength(fSparseToDense,fMaximumSize);
 SetLength(fDense,fMaximumSize);
 FillChar(fSparseToDense[0],fMaximumSize*SizeOf(longint),#$ff);
 FillChar(fDense[0],fMaximumSize*SizeOf(TpvSizeInt),#$00);
end;

destructor TpvCSGBSP.TSizeIntSparseSet.Destroy;
begin
 SetLength(fSparseToDense,0);
 SetLength(fDense,0);
 inherited Destroy;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.Clear;
begin
 fSize:=0;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.Resize(const aNewMaximumSize:TpvSizeInt);
begin
 SetLength(fSparseToDense,aNewMaximumSize);
 SetLength(fDense,aNewMaximumSize);
 if fMaximumSize<aNewMaximumSize then begin
  FillChar(fSparseToDense[fMaximumSize],(fMaximumSize-aNewMaximumSize)*SizeOf(longint),#$ff);
  FillChar(fDense[fMaximumSize],(fMaximumSize-aNewMaximumSize)*SizeOf(TpvSizeInt),#$00);
 end;
 fMaximumSize:=aNewMaximumSize;
end;

function TpvCSGBSP.TSizeIntSparseSet.Contains(const aValue:TpvSizeInt):boolean;
begin
 result:=((aValue>=0) and (aValue<fMaximumSize) and
         (fSparseToDense[aValue]<fSize)) and
         (fDense[fSparseToDense[aValue]]=aValue);
end;

function TpvCSGBSP.TSizeIntSparseSet.GetValue(const aIndex:TpvSizeInt):TpvSizeInt;
begin
 if (aIndex>=0) and (aIndex<fSize) then begin
  result:=fDense[aIndex];
 end;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.SetValue(const aIndex:TpvSizeInt;const aValue:TpvSizeInt);
begin
 if (aIndex>=0) and (aIndex<fSize) then begin
  fDense[aIndex]:=aValue;
 end;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.Add(const aValue:TpvSizeInt);
begin
 if (aValue>=0) and (aValue<fMaximumSize) then begin
  fSparseToDense[aValue]:=fSize;
  fDense[fSize]:=aValue;
  inc(fSize);
 end;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.AddNew(const aValue:TpvSizeInt);
begin
 if not Contains(aValue) then begin
  Add(aValue);
 end;
end;

procedure TpvCSGBSP.TSizeIntSparseSet.Remove(const aValue:TpvSizeInt);
var OldIndex:TpvSizeInt;
    NewValue:TpvSizeInt;
begin
 if Contains(aValue) then begin
  OldIndex:=fSparseToDense[aValue];
  fSparseToDense[aValue]:=-1;
  dec(fSize);
  if fSize>=0 then begin
   NewValue:=fDense[fSize];
   fSparseToDense[NewValue]:=OldIndex;
   fDense[OldIndex]:=NewValue;
  end else begin
   fDense[OldIndex]:=0;
  end;
 end;
end;

{ TpvCSGBSP.TVector2 }

constructor TpvCSGBSP.TVector2.Create(const aFrom:TpvVector2);
begin
 x:=aFrom.x;
 y:=aFrom.y;
end;

constructor TpvCSGBSP.TVector2.Create(const aX,aY:TFloat);
begin
 x:=aX;
 y:=aY;
end;

class operator TpvCSGBSP.TVector2.Equal(const aLeft,aRight:TVector2):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y);
end;

class operator TpvCSGBSP.TVector2.NotEqual(const aLeft,aRight:TVector2):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y));
end;

class operator TpvCSGBSP.TVector2.Add(const aLeft,aRight:TVector2):TVector2;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
end;

class operator TpvCSGBSP.TVector2.Subtract(const aLeft,aRight:TVector2):TVector2;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
end;

class operator TpvCSGBSP.TVector2.Multiply(const aLeft:TVector2;const aRight:TFloat):TVector2;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
end;

class operator TpvCSGBSP.TVector2.Divide(const aLeft:TVector2;const aRight:TFloat):TVector2;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
end;

class operator TpvCSGBSP.TVector2.Negative(const aVector:TVector2):TVector2;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
end;

function TpvCSGBSP.TVector2.Length:TFloat;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

function TpvCSGBSP.TVector2.SquaredLength:TFloat;
begin
 result:=sqr(x)+sqr(y);
end;

function TpvCSGBSP.TVector2.Lerp(const aWith:TVector2;const aTime:TFloat):TVector2;
var InverseTime:TFloat;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.x:=(x*InverseTime)+(aWith.x*aTime);
  result.y:=(y*InverseTime)+(aWith.y*aTime);
 end;
end;

function TpvCSGBSP.TVector2.ToVector:TpvVector2;
begin
 result.x:=x;
 result.y:=y;
end;

{ TpvCSGBSP.TVector3 }

constructor TpvCSGBSP.TVector3.Create(const aFrom:TpvVector3);
begin
 x:=aFrom.x;
 y:=aFrom.y;
 z:=aFrom.z;
end;

constructor TpvCSGBSP.TVector3.Create(const aX,aY,aZ:TFloat);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
end;

class operator TpvCSGBSP.TVector3.Equal(const aLeft,aRight:TVector3):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y) and
         SameValue(aLeft.z,aRight.z);
end;

class operator TpvCSGBSP.TVector3.NotEqual(const aLeft,aRight:TVector3):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y) and
              SameValue(aLeft.z,aRight.z));
end;

class operator TpvCSGBSP.TVector3.Add(const aLeft,aRight:TVector3):TVector3;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
 result.z:=aLeft.z+aRight.z;
end;

class operator TpvCSGBSP.TVector3.Subtract(const aLeft,aRight:TVector3):TVector3;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
 result.z:=aLeft.z-aRight.z;
end;

class operator TpvCSGBSP.TVector3.Multiply(const aLeft:TVector3;const aRight:TFloat):TVector3;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
 result.z:=aLeft.z*aRight;
end;

class operator TpvCSGBSP.TVector3.Divide(const aLeft:TVector3;const aRight:TFloat):TVector3;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
 result.z:=aLeft.z/aRight;
end;

class operator TpvCSGBSP.TVector3.Negative(const aVector:TVector3):TVector3;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
 result.z:=-aVector.z;
end;

function TpvCSGBSP.TVector3.Cross(const aWith:TVector3):TVector3;
begin
 result.x:=(y*aWith.z)-(z*aWith.y);
 result.y:=(z*aWith.x)-(x*aWith.z);
 result.z:=(x*aWith.y)-(y*aWith.x);
end;

function TpvCSGBSP.TVector3.Spacing(const aWith:TVector3):TFloat;
begin
 result:=abs(x-aWith.x)+abs(y-aWith.y)+abs(z-aWith.z);
end;

function TpvCSGBSP.TVector3.Dot(const aWith:TVector3):TFloat;
begin
 result:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z);
end;

function TpvCSGBSP.TVector3.Length:TFloat;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z));
end;

function TpvCSGBSP.TVector3.SquaredLength:TFloat;
begin
 result:=sqr(x)+sqr(y)+sqr(z);
end;

function TpvCSGBSP.TVector3.Lerp(const aWith:TVector3;const aTime:TFloat):TVector3;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result:=(self*(1.0-aTime))+(aWith*aTime);
 end;
end;

function TpvCSGBSP.TVector3.Normalize:TVector3;
begin
 result:=self/Length;
end;

function TpvCSGBSP.TVector3.Perpendicular:TVector3;
var v,p:TVector3;
begin
 v:=self.Normalize;
 p.x:=System.abs(v.x);
 p.y:=System.abs(v.y);
 p.z:=System.abs(v.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  p.x:=1.0;
  p.y:=0.0;
  p.z:=0.0;
 end else if (p.y<=p.x) and (p.y<=p.z) then begin
  p.x:=0.0;
  p.y:=1.0;
  p.z:=0.0;
 end else begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=1.0;
 end;
 result:=p-(v*v.Dot(p));
end;

function TpvCSGBSP.TVector3.ToVector:TpvVector3;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;

{ TpvCSGBSP.TVector4 }

constructor TpvCSGBSP.TVector4.Create(const aFrom:TpvVector4);
begin
 x:=aFrom.x;
 y:=aFrom.y;
 z:=aFrom.z;
 w:=aFrom.w;
end;

constructor TpvCSGBSP.TVector4.Create(const aX,aY,aZ,aW:TFloat);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
 w:=aW;
end;

class operator TpvCSGBSP.TVector4.Equal(const aLeft,aRight:TVector4):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y) and
         SameValue(aLeft.z,aRight.z) and
         SameValue(aLeft.w,aRight.w);
end;

class operator TpvCSGBSP.TVector4.NotEqual(const aLeft,aRight:TVector4):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y) and
              SameValue(aLeft.z,aRight.z) and
              SameValue(aLeft.w,aRight.w));
end;

class operator TpvCSGBSP.TVector4.Add(const aLeft,aRight:TVector4):TVector4;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
 result.z:=aLeft.z+aRight.z;
 result.w:=aLeft.w+aRight.w;
end;

class operator TpvCSGBSP.TVector4.Subtract(const aLeft,aRight:TVector4):TVector4;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
 result.z:=aLeft.z-aRight.z;
 result.w:=aLeft.w-aRight.w;
end;

class operator TpvCSGBSP.TVector4.Multiply(const aLeft:TVector4;const aRight:TFloat):TVector4;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
 result.z:=aLeft.z*aRight;
 result.w:=aLeft.w*aRight;
end;

class operator TpvCSGBSP.TVector4.Divide(const aLeft:TVector4;const aRight:TFloat):TVector4;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
 result.z:=aLeft.z/aRight;
 result.w:=aLeft.w/aRight;
end;

class operator TpvCSGBSP.TVector4.Negative(const aVector:TVector4):TVector4;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
 result.z:=-aVector.z;
 result.w:=-aVector.w;
end;

function TpvCSGBSP.TVector4.Length:TFloat;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;

function TpvCSGBSP.TVector4.SquaredLength:TFloat;
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;

function TpvCSGBSP.TVector4.Lerp(const aWith:TVector4;const aTime:TFloat):TVector4;
var InverseTime:TFloat;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.x:=(x*InverseTime)+(aWith.x*aTime);
  result.y:=(y*InverseTime)+(aWith.y*aTime);
  result.z:=(z*InverseTime)+(aWith.z*aTime);
  result.w:=(w*InverseTime)+(aWith.w*aTime);
 end;
end;

function TpvCSGBSP.TVector4.ToVector:TpvVector4;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=w;
end;

{ TpvCSGBSP.TVertex }

class operator TpvCSGBSP.TVertex.Equal(const aLeft,aRight:TVertex):boolean;
begin
 result:=(aLeft.Position=aRight.Position) and
         (aLeft.Normal=aRight.Normal) and
         (aLeft.TexCoord=aRight.TexCoord) and
         (aLeft.Color=aRight.Color);
end;

class operator TpvCSGBSP.TVertex.NotEqual(const aLeft,aRight:TVertex):boolean;
begin
 result:=(aLeft.Position<>aRight.Position) or
         (aLeft.Normal<>aRight.Normal) or
         (aLeft.TexCoord<>aRight.TexCoord) or
         (aLeft.Color<>aRight.Color);
end;

class operator TpvCSGBSP.TVertex.Add(const aLeft,aRight:TVertex):TVertex;
begin
 result.Position:=aLeft.Position+aRight.Position;
 result.Normal:=aLeft.Normal+aRight.Normal;
 result.TexCoord:=aLeft.TexCoord+aRight.TexCoord;
 result.Color:=aLeft.Color+aRight.Color;
end;

class operator TpvCSGBSP.TVertex.Subtract(const aLeft,aRight:TVertex):TVertex;
begin
 result.Position:=aLeft.Position-aRight.Position;
 result.Normal:=aLeft.Normal-aRight.Normal;
 result.TexCoord:=aLeft.TexCoord-aRight.TexCoord;
 result.Color:=aLeft.Color-aRight.Color;
end;

class operator TpvCSGBSP.TVertex.Multiply(const aLeft:TVertex;const aRight:TFloat):TVertex;
begin
 result.Position:=aLeft.Position*aRight;
 result.Normal:=aLeft.Normal*aRight;
 result.TexCoord:=aLeft.TexCoord*aRight;
 result.Color:=aLeft.Color*aRight;
end;

class operator TpvCSGBSP.TVertex.Divide(const aLeft:TVertex;const aRight:TFloat):TVertex;
begin
 result.Position:=aLeft.Position/aRight;
 result.Normal:=aLeft.Normal/aRight;
 result.TexCoord:=aLeft.TexCoord/aRight;
 result.Color:=aLeft.Color/aRight;
end;

class operator TpvCSGBSP.TVertex.Negative(const aLeft:TVertex):TVertex;
begin
 result.Position:=-aLeft.Position;
 result.Normal:=-aLeft.Normal;
 result.TexCoord:=-aLeft.TexCoord;
 result.Color:=-aLeft.Color;
end;

function TpvCSGBSP.TVertex.Lerp(const aWith:TVertex;const aTime:TFloat):TVertex;
begin
 result.Position:=Position.Lerp(aWith.Position,aTime);
 result.Normal:=Normal.Lerp(aWith.Normal,aTime);
 result.TexCoord:=TexCoord.Lerp(aWith.TexCoord,aTime);
 result.Color:=Color.Lerp(aWith.Color,aTime);
end;

procedure TpvCSGBSP.TVertex.Flip;
begin
 Normal:=-Normal;
end;

function TpvCSGBSP.TVertex.CloneFlip:TVertex;
begin
 result.Position:=Position;
 result.Normal:=-Normal;
 result.TexCoord:=TexCoord;
 result.Color:=Color;
end;

function TpvCSGBSP.TVertex.Normalize:TVertex;
begin
 result.Position:=Position;
 result.Normal:=Normal.Normalize;
 result.TexCoord:=TexCoord;
 result.Color:=Color;
end;

{ TpvCSGBSP.TPlane }

constructor TpvCSGBSP.TPlane.Create(const aV0,aV1,aV2:TVector3);
begin
 Normal:=((aV1-aV0).Cross(aV2-aV0)).Normalize;
 Distance:=-Normal.Dot(aV0);
end;

constructor TpvCSGBSP.TPlane.Create(const aNormal:TVector3;const aDistance:TFloat);
begin
 Normal:=aNormal;
 Distance:=aDistance;
end;

class function TpvCSGBSP.TPlane.CreateEmpty;
begin
 result.Normal.x:=0.0;
 result.Normal.y:=0.0;
 result.Normal.z:=0.0;
 result.Distance:=0.0;
end;

function TpvCSGBSP.TPlane.DistanceTo(const aWith:TVector3):TFloat;
begin
 result:=Normal.Dot(aWith)+Distance;
end;

function TpvCSGBSP.TPlane.IntersectWithPointToPoint(const aPointA,aPointB:TVector3;const aIntersectionPoint:PVector3=nil):boolean;
var NormalDotDirection,Time:TFloat;
    Direction:TVector3;
begin
 result:=false;
 Direction:=aPointB-aPointA;
 NormalDotDirection:=Normal.Dot(Direction);
 if not IsZero(NormalDotDirection) then begin
  Time:=-(DistanceTo(aPointA)/NormalDotDirection);
  result:=(Time>=Epsilon) and (Time<=OneMinusEpsilon);
  if result and assigned(aIntersectionPoint) then begin
   aIntersectionPoint^:=aPointA.Lerp(aPointB,Time);
   if (aIntersectionPoint^=aPointA) or
      (aIntersectionPoint^=aPointB) then begin
    result:=false;
   end;
  end;
 end;
end;

function TpvCSGBSP.TPlane.IntersectWithPointToPoint(const aPointA,aPointB:TVertex;const aIntersectionPoint:PVertex=nil):boolean;
var NormalDotDirection,Time:TFloat;
    Direction:TVector3;
begin
 result:=false;
 Direction:=aPointB.Position-aPointA.Position;
 NormalDotDirection:=Normal.Dot(Direction);
 if not IsZero(NormalDotDirection) then begin
  Time:=-(DistanceTo(aPointA.Position)/NormalDotDirection);
  result:=(Time>=Epsilon) and (Time<=OneMinusEpsilon);
  if result and assigned(aIntersectionPoint) then begin
   aIntersectionPoint^:=aPointA.Lerp(aPointB,Time);
   if (aIntersectionPoint^.Position=aPointA.Position) or
      (aIntersectionPoint^.Position=aPointB.Position) then begin
    result:=false;
   end;
  end;
 end;
end;

function TpvCSGBSP.TPlane.OK:boolean;
begin
 result:=Normal.Length>0.0;
end;

function TpvCSGBSP.TPlane.Flip:TPlane;
begin
 result.Normal:=-Normal;
 result.Distance:=-Distance;
end;

procedure TpvCSGBSP.TPlane.SplitTriangles(var aVertices:TVertexList;
                                          const aIndices:TIndexList;
                                          const aCoplanarBackList:PIndexList;
                                          const aCoplanarFrontList:PIndexList;
                                          const aBackList:PIndexList;
                                          const aFrontList:PIndexList);
var Index,Count,DummyIndex:TpvSizeInt;
    Sides:array[0..2] of TpvSizeInt;
    VertexIndices,PointIndices:array[0..2] of TIndex;
    PlaneDistances:array[0..2] of TFloat;
begin

 Index:=0;
 Count:=aIndices.Count;

 while (Index+2)<Count do begin

  VertexIndices[0]:=aIndices.Items[Index+0];
  VertexIndices[1]:=aIndices.Items[Index+1];
  VertexIndices[2]:=aIndices.Items[Index+2];

  PlaneDistances[0]:=DistanceTo(aVertices.Items[VertexIndices[0]].Position);
  PlaneDistances[1]:=DistanceTo(aVertices.Items[VertexIndices[1]].Position);
  PlaneDistances[2]:=DistanceTo(aVertices.Items[VertexIndices[2]].Position);

  Sides[0]:=TpvCSGBSP.EpsilonSign(PlaneDistances[0]);
  Sides[1]:=TpvCSGBSP.EpsilonSign(PlaneDistances[1]);
  Sides[2]:=TpvCSGBSP.EpsilonSign(PlaneDistances[2]);

  PlaneDistances[0]:=PlaneDistances[0]*abs(Sides[0]);
  PlaneDistances[1]:=PlaneDistances[1]*abs(Sides[1]);
  PlaneDistances[2]:=PlaneDistances[2]*abs(Sides[2]);

  if (Sides[0]*Sides[1])<0 then begin
   PointIndices[0]:=aVertices.Add(aVertices.Items[VertexIndices[0]].Lerp(aVertices.Items[VertexIndices[1]],abs(PlaneDistances[0])/(abs(PlaneDistances[0])+abs(PlaneDistances[1]))));
  end;
  if (Sides[1]*Sides[2])<0 then begin
   PointIndices[1]:=aVertices.Add(aVertices.Items[VertexIndices[1]].Lerp(aVertices.Items[VertexIndices[2]],abs(PlaneDistances[1])/(abs(PlaneDistances[1])+abs(PlaneDistances[2]))));
  end;
  if (Sides[2]*Sides[0])<0 then begin
   PointIndices[2]:=aVertices.Add(aVertices.Items[VertexIndices[2]].Lerp(aVertices.Items[VertexIndices[0]],abs(PlaneDistances[2])/(abs(PlaneDistances[2])+abs(PlaneDistances[0]))));
  end;

  case ((Sides[0]+1) shl 0) or
       ((Sides[1]+1) shl 2) or
       ((Sides[2]+1) shl 4) of

   // All points are on one side of the plane (or on the plane)
   // in this case we simply add the complete triangle to the proper halve of the subtree
   (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4),
   (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4),
   (((-1)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4),
   (((-1)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4),
   (((0)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4),
   (((0)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4),
   (((0)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[0],VertexIndices[1],VertexIndices[2]]);
    end;
   end;

   (((0)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4),
   (((0)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4),
   (((0)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4),
   (((1)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4),
   (((1)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4),
   (((1)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4),
   (((1)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],VertexIndices[1],VertexIndices[2]]);
    end;
   end;

   // Triangle on the dividing plane
   (((0)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4):begin
    if aCoplanarFrontList<>aCoplanarBackList then begin
     if Normal.Dot(TPlane.Create(aVertices.Items[VertexIndices[0]].Position,
                                 aVertices.Items[VertexIndices[1]].Position,
                                 aVertices.Items[VertexIndices[2]].Position).Normal)>0.0 then begin
      if assigned(aCoplanarFrontList) then begin
       aCoplanarFrontList^.Add([VertexIndices[0],VertexIndices[1],VertexIndices[2]]);
      end;
     end else begin
      if assigned(aCoplanarBackList) then begin
       aCoplanarBackList^.Add([VertexIndices[0],VertexIndices[1],VertexIndices[2]]);
      end;
     end;
    end else if assigned(aCoplanarFrontList) then begin
     aCoplanarFrontList^.Add([VertexIndices[0],VertexIndices[1],VertexIndices[2]]);
    end;
   end;

   // And now all the ways that the triangle can be cut by the plane

   (((1)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[0]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[0]]);
    end;
   end;

   (((-1)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[2]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[2]]);
    end;
   end;

   (((0)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[1]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[1]]);
    end;
   end;

   (((-1)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[0]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[0]]);
    end;
   end;

   (((1)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[2]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[2]]);
    end;
   end;

   (((0)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[1]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[1]]);
    end;
   end;

   (((1)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],PointIndices[0],PointIndices[2]]);
    end;
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[1],PointIndices[2],PointIndices[0]]);
     aBackList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[2]]);
    end;
   end;

   (((-1)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[1],PointIndices[1],PointIndices[0]]);
    end;
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[2],PointIndices[0],PointIndices[1]]);
     aBackList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[0]]);
    end;
   end;

   (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[2],PointIndices[2],PointIndices[1]]);
    end;
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[0],PointIndices[1],PointIndices[2]]);
     aBackList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[1]]);
    end;
   end;

   (((-1)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[0],PointIndices[0],PointIndices[2]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[1],PointIndices[2],PointIndices[0]]);
     aFrontList^.Add([VertexIndices[1],VertexIndices[2],PointIndices[2]]);
    end;
   end;

   (((1)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[1],PointIndices[1],PointIndices[0]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],PointIndices[0],PointIndices[1]]);
     aFrontList^.Add([VertexIndices[2],VertexIndices[0],PointIndices[1]]);
    end;
   end;

   (((1)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
    if assigned(aBackList) then begin
     aBackList^.Add([VertexIndices[2],PointIndices[2],PointIndices[1]]);
    end;
    if assigned(aFrontList) then begin
     aFrontList^.Add([VertexIndices[0],PointIndices[1],PointIndices[2]]);
     aFrontList^.Add([VertexIndices[0],VertexIndices[1],PointIndices[1]]);
    end;
   end;

   // Otherwise it is a error
   else begin
    Assert(false);
   end;

  end;

  inc(Index,3);

 end;

end;

procedure TpvCSGBSP.TPlane.SplitPolygons(var aVertices:TVertexList;
                                         const aIndices:TIndexList;
                                         const aCoplanarBackList:PIndexList;
                                         const aCoplanarFrontList:PIndexList;
                                         const aBackList:PIndexList;
                                         const aFrontList:PIndexList);
const Coplanar=0;
      Front=1;
      Back=2;
      Spanning=3;
      EpsilonSignToOrientation:array[0..3] of TpvInt32=(Back,Coplanar,Front,Spanning);
var Index,OtherIndex,Count,CountPolygonVertices,
    IndexA,IndexB,
    PolygonOrientation,
    VertexOrientation,
    VertexOrientationA,
    VertexOrientationB:TpvSizeInt;
    VertexOrientations:array of TpvSizeInt;
    VectorDistance:TpvDouble;
    BackVertexIndices,FrontVertexIndices:TIndexList;
    VertexIndex:TIndex;
    VertexA,VertexB:PVertex;
begin

 VertexOrientations:=nil;
 try

  BackVertexIndices.Initialize;
  try

   FrontVertexIndices.Initialize;
   try

    Index:=0;

    Count:=aIndices.Count;

    while Index<Count do begin

     CountPolygonVertices:=aIndices.Items[Index];
     inc(Index);

     if (CountPolygonVertices>0) and
        ((Index+(CountPolygonVertices-1))<Count) then begin

      if CountPolygonVertices>2 then begin

       PolygonOrientation:=0;

       if length(VertexOrientations)<CountPolygonVertices then begin
        SetLength(VertexOrientations,(CountPolygonVertices*3) shr 1);
       end;

       for IndexA:=0 to CountPolygonVertices-1 do begin
        VertexIndex:=aIndices.Items[Index+IndexA];
        VertexOrientation:=EpsilonSignToOrientation[(TpvCSGBSP.EpsilonSign(DistanceTo(aVertices.Items[VertexIndex].Position))+1) and 3];
        PolygonOrientation:=PolygonOrientation or VertexOrientation;
        VertexOrientations[IndexA]:=VertexOrientation;
       end;

       case PolygonOrientation of

        Coplanar:begin
         if assigned(aCoplanarFrontList) or assigned(aCoplanarBackList) then begin
          if Normal.Dot(TPlane.Create(aVertices.Items[aIndices.Items[Index+0]].Position,
                                      aVertices.Items[aIndices.Items[Index+1]].Position,
                                      aVertices.Items[aIndices.Items[Index+2]].Position).Normal)>0.0 then begin
           if assigned(aCoplanarFrontList) then begin
            aCoplanarFrontList^.Add(CountPolygonVertices);
            aCoplanarFrontList^.AddRangeFrom(aIndices,Index,CountPolygonVertices);
           end;
          end else begin
           if assigned(aCoplanarBackList) then begin
            aCoplanarBackList^.Add(CountPolygonVertices);
            aCoplanarBackList^.AddRangeFrom(aIndices,Index,CountPolygonVertices);
           end;
          end;
         end;
        end;

        Front:begin
         if assigned(aFrontList) then begin
          aFrontList^.Add(CountPolygonVertices);
          aFrontList^.AddRangeFrom(aIndices,Index,CountPolygonVertices);
         end;
        end;

        Back:begin
         if assigned(aBackList) then begin
          aBackList^.Add(CountPolygonVertices);
          aBackList^.AddRangeFrom(aIndices,Index,CountPolygonVertices);
         end;
        end;

        else {Spanning:}begin

         BackVertexIndices.Count:=0;

         FrontVertexIndices.Count:=0;

         for IndexA:=0 to CountPolygonVertices-1 do begin

          IndexB:=IndexA+1;
          if IndexB>=CountPolygonVertices then begin
           IndexB:=0;
          end;

          VertexIndex:=aIndices.Items[Index+IndexA];

          VertexA:=@aVertices.Items[VertexIndex];

          VertexOrientationA:=VertexOrientations[IndexA];
          VertexOrientationB:=VertexOrientations[IndexB];

          if VertexOrientationA<>Front then begin
           BackVertexIndices.Add(VertexIndex);
          end;

          if VertexOrientationA<>Back then begin
           FrontVertexIndices.Add(VertexIndex);
          end;

          if (VertexOrientationA or VertexOrientationB)=Spanning then begin
           VertexB:=@aVertices.Items[aIndices.Items[Index+IndexB]];
           VertexIndex:=aVertices.Add(VertexA^.Lerp(VertexB^,-(DistanceTo(VertexA^.Position)/Normal.Dot(VertexB^.Position-VertexA^.Position))));
           BackVertexIndices.Add(VertexIndex);
           FrontVertexIndices.Add(VertexIndex);
          end;

         end;

         if assigned(aBackList) and (BackVertexIndices.Count>2) then begin
          aBackList^.Add(BackVertexIndices.Count);
          aBackList^.Add(BackVertexIndices);
         end;

         if assigned(aFrontList) and (FrontVertexIndices.Count>2) then begin
          aFrontList^.Add(FrontVertexIndices.Count);
          aFrontList^.Add(FrontVertexIndices);
         end;

        end;

       end;

      end;

     end else begin
      Assert(false);
     end;

     inc(Index,CountPolygonVertices);

    end;

   finally
    FrontVertexIndices.Finalize;
   end;

  finally
   BackVertexIndices.Finalize;
  end;

 finally
  VertexOrientations:=nil;
 end;

end;

{ TpvCSGBSP.TAABB }

function TpvCSGBSP.TAABB.Cost:TFloat;
begin
// result:=(self.Max.x-self.Min.x)+(self.Max.y-self.Min.y)+(self.Max.z-self.Min.z); // Manhattan distance
 result:=(self.Max.x-self.Min.x)*(self.Max.y-self.Min.y)*(self.Max.z-self.Min.z); // Volume
end;

function TpvCSGBSP.TAABB.Combine(const aAABB:TAABB):TAABB;
begin
 result.Min.x:=Math.Min(self.Min.x,aaABB.Min.x);
 result.Min.y:=Math.Min(self.Min.y,aAABB.Min.y);
 result.Min.z:=Math.Min(self.Min.z,aAABB.Min.z);
 result.Max.x:=Math.Max(self.Max.x,aAABB.Max.x);
 result.Max.y:=Math.Max(self.Max.y,aAABB.Max.y);
 result.Max.z:=Math.Max(self.Max.z,aAABB.Max.z);
end;

function TpvCSGBSP.TAABB.Combine(const aVector:TVector3):TAABB;
begin
 result.Min.x:=Math.Min(self.Min.x,aVector.x);
 result.Min.y:=Math.Min(self.Min.y,aVector.y);
 result.Min.z:=Math.Min(self.Min.z,aVector.z);
 result.Max.x:=Math.Max(self.Max.x,aVector.x);
 result.Max.y:=Math.Max(self.Max.y,aVector.y);
 result.Max.z:=Math.Max(self.Max.z,aVector.z);
end;

function TpvCSGBSP.TAABB.Contains(const aAABB:TAABB;const aThreshold:TFloat=0.0):boolean;
begin
 result:=((self.Min.x-aThreshold)<=(aAABB.Min.x+aThreshold)) and ((self.Min.y-aThreshold)<=(aAABB.Min.y+aThreshold)) and ((self.Min.z-aThreshold)<=(aAABB.Min.z+aThreshold)) and
         ((self.Max.x+aThreshold)>=(aAABB.Min.x+aThreshold)) and ((self.Max.y+aThreshold)>=(aAABB.Min.y+aThreshold)) and ((self.Max.z+aThreshold)>=(aAABB.Min.z+aThreshold)) and
         ((self.Min.x-aThreshold)<=(aAABB.Max.x-aThreshold)) and ((self.Min.y-aThreshold)<=(aAABB.Max.y-aThreshold)) and ((self.Min.z-aThreshold)<=(aAABB.Max.z-aThreshold)) and
         ((self.Max.x+aThreshold)>=(aAABB.Max.x-aThreshold)) and ((self.Max.y+aThreshold)>=(aAABB.Max.y-aThreshold)) and ((self.Max.z+aThreshold)>=(aAABB.Max.z-aThreshold));
end;

function TpvCSGBSP.TAABB.Intersects(const aAABB:TAABB;const aThreshold:TFloat=Epsilon):boolean;
begin
 result:=(((self.Max.x+aThreshold)>=(aAABB.Min.x-aThreshold)) and ((self.Min.x-aThreshold)<=(aAABB.Max.x+aThreshold))) and
         (((self.Max.y+aThreshold)>=(aAABB.Min.y-aThreshold)) and ((self.Min.y-aThreshold)<=(aAABB.Max.y+aThreshold))) and
         (((self.Max.z+aThreshold)>=(aAABB.Min.z-aThreshold)) and ((self.Min.z-aThreshold)<=(aAABB.Max.z+aThreshold)));
end;

function TpvCSGBSP.TAABB.Intersection(const aAABB:TAABB;const aThreshold:TFloat=0.0):TAABB;
begin
 result.Min.x:=Math.Max(Min.x,aAABB.Min.x)-aThreshold;
 result.Min.y:=Math.Max(Min.y,aAABB.Min.y)-aThreshold;
 result.Min.z:=Math.Max(Min.z,aAABB.Min.z)-aThreshold;
 result.Max.x:=Math.Min(Max.x,aAABB.Max.x)+aThreshold;
 result.Max.y:=Math.Min(Max.y,aAABB.Max.y)+aThreshold;
 result.Max.z:=Math.Min(Max.z,aAABB.Max.z)+aThreshold;
end;

{ TpvCSGBSP.TDynamicAABBTree }

constructor TpvCSGBSP.TDynamicAABBTree.Create;
var i:TpvSizeInt;
begin
 inherited Create;
 Root:=daabbtNULLNODE;
 NodeCount:=0;
 NodeCapacity:=16;
 GetMem(Nodes,NodeCapacity*SizeOf(TDynamicAABBTreeNode));
 FillChar(Nodes^,NodeCapacity*SizeOf(TDynamicAABBTreeNode),#0);
 for i:=0 to NodeCapacity-2 do begin
  Nodes^[i].Next:=i+1;
  Nodes^[i].Height:=-1;
 end;
 Nodes^[NodeCapacity-1].Next:=daabbtNULLNODE;
 Nodes^[NodeCapacity-1].Height:=-1;
 FreeList:=0;
 Path:=0;
 InsertionCount:=0;
 StackCapacity:=16;
 GetMem(Stack,StackCapacity*SizeOf(TpvSizeInt));
end;

destructor TpvCSGBSP.TDynamicAABBTree.Destroy;
begin
 FreeMem(Nodes);
 FreeMem(Stack);
 inherited Destroy;
end;

function TpvCSGBSP.TDynamicAABBTree.AllocateNode:TpvSizeInt;
var Node:PDynamicAABBTreeNode;
    i:TpvSizeInt;
begin
 if FreeList=daabbtNULLNODE then begin
  inc(NodeCapacity,NodeCapacity);
  ReallocMem(Nodes,NodeCapacity*SizeOf(TDynamicAABBTreeNode));
  FillChar(Nodes^[NodeCount],(NodeCapacity-NodeCount)*SizeOf(TDynamicAABBTreeNode),#0);
  for i:=NodeCount to NodeCapacity-2 do begin
   Nodes^[i].Next:=i+1;
   Nodes^[i].Height:=-1;
  end;
  Nodes^[NodeCapacity-1].Next:=daabbtNULLNODE;
  Nodes^[NodeCapacity-1].Height:=-1;
  FreeList:=NodeCount;
 end;
 result:=FreeList;
 FreeList:=Nodes^[result].Next;
 Node:=@Nodes^[result];
 Node^.Parent:=daabbtNULLNODE;
 Node^.Children[0]:=daabbtNULLNODE;
 Node^.Children[1]:=daabbtNULLNODE;
 Node^.Height:=0;
 Node^.UserData:=0;
 inc(NodeCount);
end;

procedure TpvCSGBSP.TDynamicAABBTree.FreeNode(const aNodeID:TpvSizeInt);
var Node:PDynamicAABBTreeNode;
begin
 Node:=@Nodes^[aNodeID];
 Node^.Next:=FreeList;
 Node^.Height:=-1;
 FreeList:=aNodeID;
 dec(NodeCount);
end;

function TpvCSGBSP.TDynamicAABBTree.Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
var NodeA,NodeB,NodeC,NodeD,NodeE,NodeF,NodeG:PDynamicAABBTreeNode;
    NodeBID,NodeCID,NodeDID,NodeEID,NodeFID,NodeGID,NodeBalance:TpvSizeInt;
begin
 NodeA:=@Nodes^[aNodeID];
 if (NodeA.Children[0]<0) or (NodeA^.Height<2) then begin
  result:=aNodeID;
 end else begin
  NodeBID:=NodeA^.Children[0];
  NodeCID:=NodeA^.Children[1];
  NodeB:=@Nodes^[NodeBID];
  NodeC:=@Nodes^[NodeCID];
  NodeBalance:=NodeC^.Height-NodeB^.Height;
  if NodeBalance>1 then begin
   NodeFID:=NodeC^.Children[0];
   NodeGID:=NodeC^.Children[1];
   NodeF:=@Nodes^[NodeFID];
   NodeG:=@Nodes^[NodeGID];
   NodeC^.Children[0]:=aNodeID;
   NodeC^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeCID;
   if NodeC^.Parent>=0 then begin
    if Nodes^[NodeC^.Parent].Children[0]=aNodeID then begin
     Nodes^[NodeC^.Parent].Children[0]:=NodeCID;
    end else begin
     Nodes^[NodeC^.Parent].Children[1]:=NodeCID;
    end;
   end else begin
    Root:=NodeCID;
   end;
   if NodeF^.Height>NodeG^.Height then begin
    NodeC^.Children[1]:=NodeFID;
    NodeA^.Children[1]:=NodeGID;
    NodeG^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeG^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeF^.AABB);
    NodeA^.Height:=1+Max(NodeB^.Height,NodeG^.Height);
    NodeC^.Height:=1+Max(NodeA^.Height,NodeF^.Height);
   end else begin
    NodeC^.Children[1]:=NodeGID;
    NodeA^.Children[1]:=NodeFID;
    NodeF^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeF^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeG^.AABB);
    NodeA^.Height:=1+Max(NodeB^.Height,NodeF^.Height);
    NodeC^.Height:=1+Max(NodeA^.Height,NodeG^.Height);
   end;
   result:=NodeCID;
  end else if NodeBalance<-1 then begin
   NodeDID:=NodeB^.Children[0];
   NodeEID:=NodeB^.Children[1];
   NodeD:=@Nodes^[NodeDID];
   NodeE:=@Nodes^[NodeEID];
   NodeB^.Children[0]:=aNodeID;
   NodeB^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeBID;
   if NodeB^.Parent>=0 then begin
    if Nodes^[NodeB^.Parent].Children[0]=aNodeID then begin
     Nodes^[NodeB^.Parent].Children[0]:=NodeBID;
    end else begin
     Nodes^[NodeB^.Parent].Children[1]:=NodeBID;
    end;
   end else begin
    Root:=NodeBID;
   end;
   if NodeD^.Height>NodeE^.Height then begin
    NodeB^.Children[1]:=NodeDID;
    NodeA^.Children[0]:=NodeEID;
    NodeE^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeE^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeD^.AABB);
    NodeA^.Height:=1+Max(NodeC^.Height,NodeE^.Height);
    NodeB^.Height:=1+Max(NodeA^.Height,NodeD^.Height);
   end else begin
    NodeB^.Children[1]:=NodeEID;
    NodeA^.Children[0]:=NodeDID;
    NodeD^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeD^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeE^.AABB);
    NodeA^.Height:=1+Max(NodeC^.Height,NodeD^.Height);
    NodeB^.Height:=1+Max(NodeA^.Height,NodeE^.Height);
   end;
   result:=NodeBID;
  end else begin
   result:=aNodeID;
  end;
 end;
end;

procedure TpvCSGBSP.TDynamicAABBTree.InsertLeaf(const aLeaf:TpvSizeInt);
var Node:PDynamicAABBTreeNode;
    LeafAABB,CombinedAABB,AABB:TAABB;
    Index,Sibling,OldParent,NewParent:TpvSizeInt;
    Children:array[0..1] of TpvSizeInt;
    CombinedCost,Cost,InheritanceCost:TFloat;
    Costs:array[0..1] of TFloat;
begin
 inc(InsertionCount);
 if Root<0 then begin
  Root:=aLeaf;
  Nodes^[aLeaf].Parent:=daabbtNULLNODE;
 end else begin
  LeafAABB:=Nodes^[aLeaf].AABB;
  Index:=Root;
  while Nodes^[Index].Children[0]>=0 do begin
   Children[0]:=Nodes^[Index].Children[0];
   Children[1]:=Nodes^[Index].Children[1];

   CombinedAABB:=Nodes^[Index].AABB.Combine(LeafAABB);
   CombinedCost:=CombinedAABB.Cost;
   Cost:=CombinedCost*2.0;
   InheritanceCost:=2.0*(CombinedCost-Nodes^[Index].AABB.Cost);

   AABB:=LeafAABB.Combine(Nodes^[Children[0]].AABB);
   if Nodes^[Children[0]].Children[0]<0 then begin
    Costs[0]:=AABB.Cost+InheritanceCost;
   end else begin
    Costs[0]:=(AABB.Cost-Nodes^[Children[0]].AABB.Cost)+InheritanceCost;
   end;

   AABB:=LeafAABB.Combine(Nodes^[Children[1]].AABB);
   if Nodes^[Children[1]].Children[1]<0 then begin
    Costs[1]:=AABB.Cost+InheritanceCost;
   end else begin
    Costs[1]:=(AABB.Cost-Nodes^[Children[1]].AABB.Cost)+InheritanceCost;
   end;

   if (Cost<Costs[0]) and (Cost<Costs[1]) then begin
    break;
   end else begin
    if Costs[0]<Costs[1] then begin
     Index:=Children[0];
    end else begin
     Index:=Children[1];
    end;
   end;

  end;

  Sibling:=Index;

  OldParent:=Nodes^[Sibling].Parent;
  NewParent:=AllocateNode;
  Nodes^[NewParent].Parent:=OldParent;
  Nodes^[NewParent].UserData:=0;
  Nodes^[NewParent].AABB:=LeafAABB.Combine(Nodes^[Sibling].AABB);
  Nodes^[NewParent].Height:=Nodes^[Sibling].Height+1;

  if OldParent>=0 then begin
   if Nodes^[OldParent].Children[0]=Sibling then begin
    Nodes^[OldParent].Children[0]:=NewParent;
   end else begin
    Nodes^[OldParent].Children[1]:=NewParent;
   end;
   Nodes^[NewParent].Children[0]:=Sibling;
   Nodes^[NewParent].Children[1]:=aLeaf;
   Nodes^[Sibling].Parent:=NewParent;
   Nodes^[aLeaf].Parent:=NewParent;
  end else begin
   Nodes^[NewParent].Children[0]:=Sibling;
   Nodes^[NewParent].Children[1]:=aLeaf;
   Nodes^[Sibling].Parent:=NewParent;
   Nodes^[aLeaf].Parent:=NewParent;
   Root:=NewParent;
  end;

  Index:=Nodes^[aLeaf].Parent;
  while Index>=0 do begin
   Index:=Balance(Index);
   Node:=@Nodes^[Index];
   Node^.AABB:=Nodes^[Node^.Children[0]].AABB.Combine(Nodes^[Node^.Children[1]].AABB);
   Node^.Height:=1+Max(Nodes^[Node^.Children[0]].Height,Nodes^[Node^.Children[1]].Height);
   Index:=Node^.Parent;
  end;

 end;
end;

procedure TpvCSGBSP.TDynamicAABBTree.RemoveLeaf(const aLeaf:TpvSizeInt);
var Node:PDynamicAABBTreeNode;
    Parent,GrandParent,Sibling,Index:TpvSizeInt;
begin
 if Root=aLeaf then begin
  Root:=daabbtNULLNODE;
 end else begin
  Parent:=Nodes^[aLeaf].Parent;
  GrandParent:=Nodes^[Parent].Parent;
  if Nodes^[Parent].Children[0]=aLeaf then begin
   Sibling:=Nodes^[Parent].Children[1];
  end else begin
   Sibling:=Nodes^[Parent].Children[0];
  end;
  if GrandParent>=0 then begin
   if Nodes^[GrandParent].Children[0]=Parent then begin
    Nodes^[GrandParent].Children[0]:=Sibling;
   end else begin
    Nodes^[GrandParent].Children[1]:=Sibling;
   end;
   Nodes^[Sibling].Parent:=GrandParent;
   FreeNode(Parent);
   Index:=GrandParent;
   while Index>=0 do begin
    Index:=Balance(Index);
    Node:=@Nodes^[Index];
    Node^.AABB:=Nodes^[Node^.Children[0]].AABB.Combine(Nodes^[Node^.Children[1]].AABB);
    Node^.Height:=1+Max(Nodes^[Node^.Children[0]].Height,Nodes^[Node^.Children[1]].Height);
    Index:=Node^.Parent;
   end;
  end else begin
   Root:=Sibling;
   Nodes^[Sibling].Parent:=daabbtNULLNODE;
   FreeNode(Parent);
  end;
 end;
end;

function TpvCSGBSP.TDynamicAABBTree.CreateProxy(const aAABB:TAABB;const aUserData:TpvPtrInt):TpvSizeInt;
var Node:PDynamicAABBTreeNode;
begin
 result:=AllocateNode;
 Node:=@Nodes^[result];
 Node^.AABB.Min:=aAABB.Min-ThresholdAABBVector;
 Node^.AABB.Max:=aAABB.Max+ThresholdAABBVector;
 Node^.UserData:=aUserData;
 Node^.Height:=0;
 InsertLeaf(result);
end;

procedure TpvCSGBSP.TDynamicAABBTree.DestroyProxy(const aNodeID:TpvSizeInt);
begin
 RemoveLeaf(aNodeID);
 FreeNode(aNodeID);
end;

function TpvCSGBSP.TDynamicAABBTree.MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TAABB;const aDisplacement:TVector3):boolean;
var Node:PDynamicAABBTreeNode;
    b:TAABB;
    d:TVector3;
begin
 Node:=@Nodes^[aNodeID];
 result:=not Node^.AABB.Contains(aAABB);
 if result then begin
  RemoveLeaf(aNodeID);
  b.Min:=aAABB.Min-ThresholdAABBVector;
  b.Max:=aAABB.Max+ThresholdAABBVector;
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
  InsertLeaf(aNodeID);
 end;
end;

procedure TpvCSGBSP.TDynamicAABBTree.Rebalance(const aIterations:TpvSizeInt);
var Counter,Node:TpvSizeInt;
    Bit:TpvSizeUInt;
//  Children:PDynamicAABBTreeSizeIntArray;
begin
 if (Root>=0) and (Root<NodeCount) then begin
  for Counter:=1 to aIterations do begin
   Bit:=0;
   Node:=Root;
   while Nodes[Node].Children[0]>=0 do begin
    Node:=Nodes[Node].Children[(Path shr Bit) and 1];
    Bit:=(Bit+1) and 31;
   end;
   inc(Path);
   if ((Node>=0) and (Node<NodeCount)) and (Nodes[Node].Children[0]<0) then begin
    RemoveLeaf(Node);
    InsertLeaf(Node);
   end else begin
    break;
   end;
  end;
 end;
end;

{ TpvCSGBSP.TMesh }

constructor TpvCSGBSP.TMesh.Create(const aMode:TMode=TMode.Polygons);
begin
 inherited Create;
 fMode:=aMode;
 fVertices.Initialize;
 fIndices.Initialize;
 fPointerToVertices:=@fVertices;
 fPointerToIndices:=@fIndices;
end;

constructor TpvCSGBSP.TMesh.Create(const aFrom:TMesh);
begin
 Create(aFrom.fMode);
 if assigned(aFrom) then begin
  SetVertices(aFrom.fVertices);
  SetIndices(aFrom.fIndices);
 end;
end;

constructor TpvCSGBSP.TMesh.Create(const aFrom:TSingleTreeNode);
var Mesh:TMesh;
begin
 Mesh:=aFrom.ToMesh;
 try
  Create(Mesh.fMode);
  fVertices.Assign(Mesh.fVertices);
  fIndices.Assign(Mesh.fIndices);
  Mesh.fVertices.Clear;
  Mesh.fIndices.Clear;
 finally
  FreeAndNil(Mesh);
 end;
end;

constructor TpvCSGBSP.TMesh.Create(const aFrom:TDualTree);
var Mesh:TMesh;
begin
 Mesh:=aFrom.ToMesh;
 try
  Create(Mesh.fMode);
  fVertices.Assign(Mesh.fVertices);
  fIndices.Assign(Mesh.fIndices);
  Mesh.fVertices.Clear;
  Mesh.fIndices.Clear;
 finally
  FreeAndNil(Mesh);
 end;
end;

constructor TpvCSGBSP.TMesh.Create(const aFrom:TAABB;const aMode:TMode=TMode.Polygons;const aAdditionalBounds:TFloat=0.0);
const SideVertexIndices:array[0..5,0..3] of TpvUInt8=
       (
        (0,4,6,2), // Left
        (1,3,7,5), // Right
        (0,1,5,4), // Bottom
        (2,6,7,3), // Top
        (0,2,3,1), // Back
        (4,5,7,6)  // Front
       );
      SideNormals:array[0..5] of TVector3=
       (
        (x:-1.0;y:0.0;z:0.0),
        (x:1.0;y:0.0;z:0.0),
        (x:0.0;y:-1.0;z:0.0),
        (x:0.0;y:1.0;z:0.0),
        (x:0.0;y:0.0;z:-1.0),
        (x:0.0;y:0.0;z:1.0)
       );
var SideIndex,SideVertexIndex,VertexIndex,BaseVertexIndex:TpvSizeInt;
    Vertex:TVertex;
begin
 Create(aMode);
 for SideIndex:=0 to 5 do begin
  BaseVertexIndex:=fVertices.Count;
  for SideVertexIndex:=0 to 3 do begin
   VertexIndex:=SideVertexIndices[SideIndex,SideVertexIndex];
   Vertex.Position.x:=aFrom.MinMax[(VertexIndex shr 0) and 1].x+(((((VertexIndex shr 0) and 1) shl 1)-1)*aAdditionalBounds);
   Vertex.Position.y:=aFrom.MinMax[(VertexIndex shr 1) and 1].y+(((((VertexIndex shr 1) and 1) shl 1)-1)*aAdditionalBounds);
   Vertex.Position.z:=aFrom.MinMax[(VertexIndex shr 2) and 1].z+(((((VertexIndex shr 2) and 1) shl 1)-1)*aAdditionalBounds);
   Vertex.Normal:=SideNormals[SideIndex];
   Vertex.TexCoord.x:=SideVertexIndex and 1;
   Vertex.TexCoord.y:=((SideVertexIndex shr 1) and 1) xor (SideVertexIndex and 1);
   Vertex.Color.x:=1.0;
   Vertex.Color.y:=1.0;
   Vertex.Color.z:=1.0;
   Vertex.Color.w:=1.0;
   fVertices.Add(Vertex);
  end;
  case fMode of
   TMode.Triangles:begin
    fIndices.Add([BaseVertexIndex+0,BaseVertexIndex+1,BaseVertexIndex+2,
                  BaseVertexIndex+0,BaseVertexIndex+2,BaseVertexIndex+3]);
   end;
   else {TMode.Polygons:}begin
    fIndices.Add([4,BaseVertexIndex+0,BaseVertexIndex+1,BaseVertexIndex+2,BaseVertexIndex+3]);
   end;
  end;
 end;
 RemoveDuplicateAndUnusedVertices;
end;

constructor TpvCSGBSP.TMesh.CreateCube(const aCX,aCY,aCZ,aRX,aRY,aRZ:TFloat;const aMode:TMode=TMode.Polygons);
const SideVertexIndices:array[0..5,0..3] of TpvUInt8=
       (
        (0,4,6,2), // Left
        (1,3,7,5), // Right
        (0,1,5,4), // Bottom
        (2,6,7,3), // Top
        (0,2,3,1), // Back
        (4,5,7,6)  // Front
       );
      SideNormals:array[0..5] of TVector3=
       (
        (x:-1.0;y:0.0;z:0.0),
        (x:1.0;y:0.0;z:0.0),
        (x:0.0;y:-1.0;z:0.0),
        (x:0.0;y:1.0;z:0.0),
        (x:0.0;y:0.0;z:-1.0),
        (x:0.0;y:0.0;z:1.0)
       );
var SideIndex,SideVertexIndex,VertexIndex,BaseVertexIndex:TpvSizeInt;
    Vertex:TVertex;
begin
 Create(aMode);
 for SideIndex:=0 to 5 do begin
  BaseVertexIndex:=fVertices.Count;
  for SideVertexIndex:=0 to 3 do begin
   VertexIndex:=SideVertexIndices[SideIndex,SideVertexIndex];
   Vertex.Position.x:=aCX+(((((VertexIndex shr 0) and 1) shl 1)-1)*aRX);
   Vertex.Position.y:=aCY+(((((VertexIndex shr 1) and 1) shl 1)-1)*aRY);
   Vertex.Position.z:=aCZ+(((((VertexIndex shr 2) and 1) shl 1)-1)*aRZ);
   Vertex.Normal:=SideNormals[SideIndex];
   Vertex.TexCoord.x:=SideVertexIndex and 1;
   Vertex.TexCoord.y:=((SideVertexIndex shr 1) and 1) xor (SideVertexIndex and 1);
   Vertex.Color.x:=1.0;
   Vertex.Color.y:=1.0;
   Vertex.Color.z:=1.0;
   Vertex.Color.w:=1.0;
   fVertices.Add(Vertex);
  end;
  case fMode of
   TMode.Triangles:begin
    fIndices.Add([BaseVertexIndex+0,BaseVertexIndex+1,BaseVertexIndex+2,
                  BaseVertexIndex+0,BaseVertexIndex+2,BaseVertexIndex+3]);
   end;
   else {TMode.Polygons:}begin
    fIndices.Add([4,BaseVertexIndex+0,BaseVertexIndex+1,BaseVertexIndex+2,BaseVertexIndex+3]);
   end;
  end;
 end;
 RemoveDuplicateAndUnusedVertices;
end;

constructor TpvCSGBSP.TMesh.CreateSphere(const aCX,aCY,aCZ,aRadius:TFloat;const aSlices:TpvSizeInt=16;const aStacks:TpvSizeInt=8;const aMode:TMode=TMode.Polygons);
 function AddVertex(const aTheta,aPhi:TpvDouble):TIndex;
 var Theta,Phi,dx,dy,dz:TFloat;
     Vertex:TVertex;
 begin
  Theta:=aTheta*TwoPI;
  Phi:=aPhi*PI;
  dx:=cos(Theta)*sin(Phi);
  dy:=cos(Phi);
  dz:=sin(Theta)*sin(Phi);
  Vertex.Position.x:=aCX+(dx*aRadius);
  Vertex.Position.y:=aCY+(dy*aRadius);
  Vertex.Position.z:=aCZ+(dz*aRadius);
  Vertex.Normal.x:=dx;
  Vertex.Normal.y:=dy;
  Vertex.Normal.z:=dz;
  Vertex.TexCoord.x:=aTheta;
  Vertex.TexCoord.y:=aPhi;
  Vertex.Color.x:=1.0;
  Vertex.Color.y:=1.0;
  Vertex.Color.z:=1.0;
  Vertex.Color.w:=1.0;
  result:=fVertices.Add(Vertex);
 end;
var SliceIndex,StackIndex:TpvSizeInt;
    PolygonIndices:TIndexList;
begin
 Create(aMode);
 PolygonIndices.Initialize;
 try
  for SliceIndex:=0 to aSlices-1 do begin
   for StackIndex:=0 to aStacks-1 do begin
    PolygonIndices.Clear;
    PolygonIndices.Add(AddVertex(SliceIndex/aSlices,StackIndex/aStacks));
    if StackIndex>0 then begin
     PolygonIndices.Add(AddVertex((SliceIndex+1)/aSlices,StackIndex/aStacks));
    end;
    if StackIndex<(aStacks-1) then begin
     PolygonIndices.Add(AddVertex((SliceIndex+1)/aSlices,(StackIndex+1)/aStacks));
    end;
    PolygonIndices.Add(AddVertex(SliceIndex/aSlices,(StackIndex+1)/aStacks));
    case fMode of
     TMode.Triangles:begin
      case PolygonIndices.Count of
       3:begin
        fIndices.Add(PolygonIndices);
       end;
       4:begin
        fIndices.Add([PolygonIndices.Items[0],PolygonIndices.Items[1],PolygonIndices.Items[2],
                      PolygonIndices.Items[0],PolygonIndices.Items[2],PolygonIndices.Items[3]]);
       end;
       else begin
        Assert(false);
       end;
      end;
     end;
     else {TMode.Polygons:}begin
      fIndices.Add(PolygonIndices.Count);
      fIndices.Add(PolygonIndices);
     end;
    end;
   end;
  end;
 finally
  PolygonIndices.Finalize;
 end;
 RemoveDuplicateAndUnusedVertices;
end;

constructor TpvCSGBSP.TMesh.CreateFromCSGOperation(const aLeftMesh:TMesh;
                                                   const aRightMesh:TMesh;
                                                   const aCSGOperation:TCSGOperation;
                                                   const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                                   const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                                   const aSplitSettings:PSplitSettings=nil);
begin
 Create;
 case aCSGOperation of
  TCSGOperation.Union:begin
   Union(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  end;
  TCSGOperation.Subtraction:begin
   Subtraction(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  end;
  TCSGOperation.Intersection:begin
   Intersection(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  end;
  else begin
   Assert(false);
  end;
 end;
end;

constructor TpvCSGBSP.TMesh.CreateUnion(const aLeftMesh:TMesh;
                                        const aRightMesh:TMesh;
                                        const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                        const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                        const aSplitSettings:PSplitSettings=nil);
begin
 Create;
 Union(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
end;

constructor TpvCSGBSP.TMesh.CreateSubtraction(const aLeftMesh:TMesh;
                                              const aRightMesh:TMesh;
                                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                              const aSplitSettings:PSplitSettings=nil);
begin
 Create;
 Subtraction(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
end;

constructor TpvCSGBSP.TMesh.CreateIntersection(const aLeftMesh:TMesh;
                                               const aRightMesh:TMesh;
                                               const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                               const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                               const aSplitSettings:PSplitSettings=nil);
begin
 Create;
 Intersection(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
end;

constructor TpvCSGBSP.TMesh.CreateSymmetricDifference(const aLeftMesh:TMesh;
                                                      const aRightMesh:TMesh;
                                                      const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                                      const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                                      const aSplitSettings:PSplitSettings=nil);
begin
 Create;
 SymmetricDifference(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
end;

destructor TpvCSGBSP.TMesh.Destroy;
begin
 fVertices.Finalize;
 fIndices.Finalize;
 fPointerToVertices:=nil;
 fPointerToIndices:=nil;
 inherited Destroy;
end;

procedure TpvCSGBSP.TMesh.SaveOBJToStream(const aStream:TStream);
 function FloatStr(const aValue:TpvDouble):TpvRawByteString;
 var Index:TpvSizeInt;
 begin
  Str(aValue:1:10,result);
  if pos('.',result)>0 then begin
   Index:=length(result);
   while (Index>3) and (result[Index]='0') and (result[Index-2]<>'.') do begin
    dec(Index);
   end;
   SetLength(result,Index);
  end;
 end;
 procedure WriteOut(const aValue:TpvRawByteString);
 begin
  if length(aValue)>0 then begin
   aStream.Write(aValue[1],length(aValue));
  end;
 end;
const NewLine={$ifdef Unix}#10{$else}#13#10{$endif};
var Index,Count,CountPolygonVertices,i:TpvSizeInt;
    v:PVertex;
begin
 for Index:=0 to fVertices.Count-1 do begin
  v:=@fVertices.Items[Index];
  WriteOut('v '+FloatStr(v^.Position.x)+' '+FloatStr(v^.Position.y)+' '+FloatStr(v^.Position.z)+NewLine);
  WriteOut('vn '+FloatStr(v^.Normal.x)+' '+FloatStr(v^.Normal.y)+' '+FloatStr(v^.Normal.z)+NewLine);
  WriteOut('vt '+FloatStr(v^.TexCoord.x)+' '+FloatStr(v^.TexCoord.y)+NewLine);
 end;
 Index:=0;
 Count:=fIndices.Count;
 while Index<Count do begin
  CountPolygonVertices:=fIndices.Items[Index];
  inc(Index);
  WriteOut('f');
  while (CountPolygonVertices>0) and (Index<Count) do begin
   i:=fIndices.Items[Index]+1;
   WriteOut(' '+IntToStr(i)+'/'+IntToStr(i)+'/'+IntToStr(i));
   inc(Index);
   dec(CountPolygonVertices);
  end;
  WriteOut(NewLine);
 end;
end;

procedure TpvCSGBSP.TMesh.SaveOBJToFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveOBJToStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TpvCSGBSP.TMesh.SetMode(const aMode:TMode);
var Index,Count,CountPolygonVertices,PolygonVertexIndex:TpvSizeInt;
    NewIndices:TIndexList;
begin
 if fMode<>aMode then begin
  NewIndices.Initialize;
  try
   if (fMode=TMode.Triangles) and (aMode=TMode.Polygons) then begin
    Index:=0;
    Count:=fIndices.Count;
    while (Index+2)<Count do begin
     NewIndices.Add([3,fIndices.Items[Index+0],fIndices.Items[Index+1],fIndices.Items[Index+2]]);
     inc(Index,3);
    end;
    //Assert(Index=Count);
   end else if (fMode=TMode.Polygons) and (aMode=TMode.Triangles) then begin
    Index:=0;
    Count:=fIndices.Count;
    while Index<Count do begin
     CountPolygonVertices:=fIndices.Items[Index];
     inc(Index);
     if (CountPolygonVertices>0) and
        ((Index+(CountPolygonVertices-1))<Count) then begin
      if CountPolygonVertices>2 then begin
       for PolygonVertexIndex:=2 to CountPolygonVertices-1 do begin
        NewIndices.Add([fIndices.Items[Index+0],
                        fIndices.Items[Index+(PolygonVertexIndex-1)],
                        fIndices.Items[Index+PolygonVertexIndex]]);
       end;
      end;
      inc(Index,CountPolygonVertices);
     end else begin
      Assert(false);
     end;
    end;
    Assert(Index=Count);
   end else begin
    Assert(false);
   end;
   SetIndices(NewIndices);
  finally
   NewIndices.Finalize;
  end;
  fMode:=aMode;
 end;
end;

procedure TpvCSGBSP.TMesh.SetVertices(const aVertices:TVertexList);
begin
 fVertices.Assign(aVertices);
end;

procedure TpvCSGBSP.TMesh.SetIndices(const aIndices:TIndexList);
begin
 fIndices.Assign(aIndices);
end;

procedure TpvCSGBSP.TMesh.Clear;
begin
 fVertices.Clear;
 fIndices.Clear;
end;

procedure TpvCSGBSP.TMesh.Assign(const aFrom:TMesh);
begin
 fMode:=aFrom.fMode;
 SetVertices(aFrom.fVertices);
 SetIndices(aFrom.fIndices);
end;

procedure TpvCSGBSP.TMesh.Assign(const aFrom:TSingleTreeNode);
var Mesh:TMesh;
begin
 Mesh:=aFrom.ToMesh;
 try
  fMode:=Mesh.fMode;
  SetVertices(Mesh.fVertices);
  SetIndices(Mesh.fIndices);
 finally
  FreeAndNil(Mesh);
 end;
end;

procedure TpvCSGBSP.TMesh.Assign(const aFrom:TDualTree);
var Mesh:TMesh;
begin
 Mesh:=aFrom.fMesh;
 fMode:=Mesh.fMode;
 fVertices.Assign(Mesh.fVertices);
 fIndices.Clear;
 aFrom.GetIndices(fIndices);
end;

procedure TpvCSGBSP.TMesh.Append(const aFrom:TMesh);
var Index,Count,CountPolygonVertices,Offset:TpvSizeInt;
    Mesh:TMesh;
begin
 Mesh:=TMesh.Create(aFrom);
 try
  Mesh.SetMode(fMode);
  Offset:=fVertices.Count;
  fVertices.Add(Mesh.fVertices);
  Index:=0;
  Count:=Mesh.fIndices.Count;
  while Index<Count do begin
   case fMode of
    TMesh.TMode.Triangles:begin
     CountPolygonVertices:=3;
    end;
    else {TMesh.TMode.Polygons:}begin
     CountPolygonVertices:=Mesh.fIndices.Items[Index];
     inc(Index);
     AddIndex(CountPolygonVertices);
    end;
   end;
   while (Index<Count) and (CountPolygonVertices>0) do begin
    AddIndex(Mesh.fIndices.Items[Index]+Offset);
    dec(CountPolygonVertices);
    inc(Index);
   end;
  end;
 finally
  FreeAndNil(Mesh);
 end;
end;

procedure TpvCSGBSP.TMesh.Append(const aFrom:TSingleTreeNode);
var Mesh:TMesh;
begin
 Mesh:=aFrom.ToMesh;
 try
  Append(Mesh);
 finally
  FreeAndNil(Mesh);
 end;
end;

procedure TpvCSGBSP.TMesh.Append(const aFrom:TDualTree);
var Mesh:TMesh;
begin
 Mesh:=aFrom.ToMesh;
 try
  Append(Mesh);
 finally
  FreeAndNil(Mesh);
 end;
end;

function TpvCSGBSP.TMesh.AddVertex(const aVertex:TVertex):TIndex;
begin
 result:=fVertices.Add(aVertex);
end;

function TpvCSGBSP.TMesh.AddVertices(const aVertices:array of TVertex):TIndex;
begin
 result:=fVertices.Add(aVertices);
end;

function TpvCSGBSP.TMesh.AddVertices(const aVertices:TVertexList):TIndex;
begin
 result:=fVertices.Add(aVertices);
end;

function TpvCSGBSP.TMesh.AddIndex(const aIndex:TIndex):TpvSizeInt;
begin
 result:=fIndices.Add(aIndex);
end;

function TpvCSGBSP.TMesh.AddIndices(const aIndices:array of TIndex):TpvSizeInt;
begin
 result:=fIndices.Add(aIndices);
end;

function TpvCSGBSP.TMesh.AddIndices(const aIndices:TIndexList):TpvSizeInt;
begin
 result:=fIndices.Add(aIndices);
end;

function TpvCSGBSP.TMesh.GetAxisAlignedBoundingBox:TAABB;
var Index:TpvSizeInt;
begin
 if fVertices.Count>0 then begin
  result.Min:=fVertices.Items[0].Position;
  result.Max:=fVertices.Items[0].Position;
  for Index:=1 to fVertices.Count-1 do begin
   result:=result.Combine(fVertices.Items[Index].Position);
  end;
 end else begin
  result.Min:=TVector3.Create(Infinity,Infinity,Infinity);
  result.Max:=TVector3.Create(-Infinity,-Infinity,-Infinity);
 end;
end;

procedure TpvCSGBSP.TMesh.Invert;
var Index,Count,CountPolygonVertices,PolygonVertexIndex,IndexA,IndexB:TpvSizeInt;
begin
 for Index:=0 To fVertices.Count-1 do begin
  fVertices.Items[Index].Flip;
 end;
 case fMode of
  TMode.Triangles:begin
   Index:=0;
   Count:=fIndices.Count;
   while (Index+2)<Count do begin
    fIndices.Exchange(Index+0,Index+2);
    inc(Index,3);
   end;
  end;
  else {TMode.Polygons:}begin
   Index:=0;
   Count:=fIndices.Count;
   while Index<Count do begin
    CountPolygonVertices:=fIndices.Items[Index];
    inc(Index);
    if CountPolygonVertices>0 then begin
     if (Index+(CountPolygonVertices-1))<Count then begin
      for PolygonVertexIndex:=0 to (CountPolygonVertices shr 1)-1 do begin
       IndexA:=Index+PolygonVertexIndex;
       IndexB:=Index+(CountPolygonVertices-(PolygonVertexIndex+1));
       if IndexA<>IndexB then begin
        fIndices.Exchange(IndexA,IndexB);
       end;
      end;
      inc(Index,CountPolygonVertices);
     end else begin
      Assert(false);
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvCSGBSP.TMesh.ConvertToPolygons;
begin
 SetMode(TMode.Polygons);
end;

procedure TpvCSGBSP.TMesh.ConvertToTriangles;
begin
 SetMode(TMode.Triangles);
end;

procedure TpvCSGBSP.TMesh.TriangleCSGOperation(const aLeftNode:TSingleTreeNode;
                                               const aRightNode:TSingleTreeNode;
                                               const aVertices:TVertexList;
                                               const aInside:boolean;
                                               const aKeepEdge:boolean;
                                               const aInvert:boolean);
 function ProcessTriangle(const aNode:TSingleTreeNode;
                          const aVertex0:TVertex;
                          const aVertex1:TVertex;
                          const aVertex2:TVertex;
                          const aInside:boolean;
                          const aKeepEdge:boolean;
                          const aKeepNow:boolean;
                          const aInvert:boolean):boolean;
 type TWorkData=record
       Node:TSingleTreeNode;
       Vertex0:TVertex;
       Vertex1:TVertex;
       Vertex2:TVertex;
       Inside:boolean;
       KeepEdge:boolean;
       KeepNow:boolean;
       Invert:boolean;
       Completed:boolean;
       Clipped:boolean;
       PreviousWorkData:TpvSizeInt;
       OldCountVertices:TpvSizeInt;
       OldCountIndices:TpvSizeInt;
      end;
      PWorkData=^TWorkData;
      TJobStackItem=record
       WorkData:TpvSizeInt;
       Step:TpvSizeInt;
      end;
      TWorkDataArray=TDynamicArray<TWorkData>;
      TJobStack=TDynamicStack<TJobStackItem>;
 var WorkDataArray:TWorkDataArray;
     JobStack:TJobStack;
  function NewWorkData(const aNode:TSingleTreeNode;
                       const aVertex0:TVertex;
                       const aVertex1:TVertex;
                       const aVertex2:TVertex;
                       const aInside:boolean;
                       const aKeepEdge:boolean;
                       const aKeepNow:boolean;
                       const aInvert:boolean;
                       const aPreviousWorkData:TpvSizeInt):TpvSizeInt;
  var WorkData:TWorkData;
  begin
   WorkData.Node:=aNode;
   WorkData.Vertex0:=aVertex0;
   WorkData.Vertex1:=aVertex1;
   WorkData.Vertex2:=aVertex2;
   WorkData.Inside:=aInside;
   WorkData.KeepEdge:=aKeepEdge;
   WorkData.KeepNow:=aKeepEdge;
   WorkData.Invert:=aInvert;
   WorkData.PreviousWorkData:=aPreviousWorkData;
   WorkData.Completed:=true;
   WorkData.Clipped:=true;
   result:=WorkDataArray.Add(WorkData);
  end;
  procedure NewJobStackItem(const aWorkData:TpvSizeInt;
                            const aStep:TpvSizeInt);
  var JobStackItem:TJobStackItem;
  begin
   JobStackItem.WorkData:=aWorkData;
   JobStackItem.Step:=aStep;
   JobStack.Push(JobStackItem);
  end;
 var WorkDataIndex:TpvSizeInt;
     JobStackItem:TJobStackItem;
     WorkData,OtherWorkData:PWorkData;
     FunctionResult:boolean;
  procedure Append(const aVertex0,aVertex1,aVertex2:TVertex);
  begin
   fIndices.Add(fVertices.Add(aVertex0));
   fIndices.Add(fVertices.Add(aVertex1));
   fIndices.Add(fVertices.Add(aVertex2));
  end;
  procedure NextTriangle(const aNode:TSingleTreeNode;
                         const aVertex0:TVertex;
                         const aVertex1:TVertex;
                         const aVertex2:TVertex;
                         const aInside:boolean;
                         const aKeepEdge:boolean;
                         const aKeepNow:boolean;
                         const aInvert:boolean);
  var Completed:boolean;
  begin
    if assigned(aNode) then begin
     NewJobStackItem(NewWorkData(aNode,
                                 aVertex0,
                                 aVertex1,
                                 aVertex2,
                                 aInside,
                                 aKeepEdge,
                                 aKeepNow,
                                 aInvert,
                                 WorkDataIndex),
                     0);
    WorkData:=@WorkDataArray.Items[JobStackItem.WorkData];
   end else begin
    if aKeepNow then begin
     if aInvert then begin
      Append(aVertex2.CloneFlip,aVertex1.CloneFlip,aVertex0.CloneFlip);
     end else begin
      Append(aVertex0,aVertex1,aVertex2);
     end;
    end;
    Completed:=aKeepNow;
    if assigned(WorkData) then begin
     WorkData^.Completed:=WorkData^.Completed and Completed;
    end else begin
     FunctionResult:=Completed;
    end;
   end;
  end;
 var Sides:array[0..2] of TpvSizeInt;
     Points:array[0..2] of TVertex;
     PlaneDistances:array[0..2] of TFloat;
 begin

  FunctionResult:=true;
  try

   WorkDataArray.Initialize;
   try

    JobStack.Initialize;
    try

     WorkDataIndex:=-1;

     WorkData:=nil;

     NextTriangle(aNode,
                  aVertex0,
                  aVertex1,
                  aVertex2,
                  aInside,
                  aKeepEdge,
                  aKeepNow,
                  aInvert);

     while JobStack.Pop(JobStackItem) do begin

      WorkDataIndex:=JobStackItem.WorkData;

      WorkData:=@WorkDataArray.Items[WorkDataIndex];

      case JobStackItem.Step of

       0:begin

        PlaneDistances[0]:=WorkData^.Node.fPlane.DistanceTo(WorkData^.Vertex0.Position);
        PlaneDistances[1]:=WorkData^.Node.fPlane.DistanceTo(WorkData^.Vertex1.Position);
        PlaneDistances[2]:=WorkData^.Node.fPlane.DistanceTo(WorkData^.Vertex2.Position);

        Sides[0]:=TpvCSGBSP.EpsilonSign(PlaneDistances[0]);
        Sides[1]:=TpvCSGBSP.EpsilonSign(PlaneDistances[1]);
        Sides[2]:=TpvCSGBSP.EpsilonSign(PlaneDistances[2]);

        PlaneDistances[0]:=PlaneDistances[0]*abs(Sides[0]);
        PlaneDistances[1]:=PlaneDistances[1]*abs(Sides[1]);
        PlaneDistances[2]:=PlaneDistances[2]*abs(Sides[2]);

        if (Sides[0]*Sides[1])<0 then begin
         Points[0]:=WorkData^.Vertex0.Lerp(WorkData^.Vertex1,abs(PlaneDistances[0])/(abs(PlaneDistances[0])+abs(PlaneDistances[1])));
        end;
        if (Sides[1]*Sides[2])<0 then begin
         Points[1]:=WorkData^.Vertex1.Lerp(WorkData^.Vertex2,abs(PlaneDistances[1])/(abs(PlaneDistances[1])+abs(PlaneDistances[2])));
        end;
        if (Sides[2]*Sides[0])<0 then begin
         Points[2]:=WorkData^.Vertex2.Lerp(WorkData^.Vertex0,abs(PlaneDistances[2])/(abs(PlaneDistances[2])+abs(PlaneDistances[0])));
        end;

        WorkData^.OldCountVertices:=fVertices.Count;
        WorkData^.OldCountIndices:=fIndices.Count;

        WorkData^.Completed:=true;

        WorkData^.Clipped:=true;

        NewJobStackItem(JobStackItem.WorkData,1);

        case ((Sides[0]+1) shl 0) or
             ((Sides[1]+1) shl 2) or
             ((Sides[2]+1) shl 4) of

         // All points are on one side of the plane (or on the plane)
         // in this case we simply add the complete triangle to the proper halve of the subtree
         (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4),
         (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4),
         (((-1)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4),
         (((-1)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4),
         (((0)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4),
         (((0)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4),
         (((0)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,WorkData^.Vertex1,WorkData^.Vertex2,WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          WorkData^.Clipped:=false;
         end;

         (((0)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4),
         (((0)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4),
         (((0)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4),
         (((1)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4),
         (((1)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4),
         (((1)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4),
         (((1)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,WorkData^.Vertex1,WorkData^.Vertex2,WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          WorkData^.Clipped:=false;
         end;

         // Triangle on the dividing plane
         (((0)+1) shl 0) or (((0)+1) shl 2) or (((0)+1) shl 4):begin
          if WorkData^.KeepEdge then begin
           Append(WorkData^.Vertex0,WorkData^.Vertex1,WorkData^.Vertex2);
           WorkData^.Clipped:=false;
          end;
         end;

         // And now all the ways that the triangle can be cut by the plane

         (((1)+1) shl 0) or (((-1)+1) shl 2) or (((0)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex1,WorkData^.Vertex2,Points[0],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex2,WorkData^.Vertex1,Points[0],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((-1)+1) shl 0) or (((0)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,WorkData^.Vertex1,Points[2],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex1,WorkData^.Vertex2,Points[2],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((0)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex2,WorkData^.Vertex0,Points[1],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,WorkData^.Vertex1,Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((-1)+1) shl 0) or (((1)+1) shl 2) or (((0)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex2,WorkData^.Vertex0,Points[0],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex1,WorkData^.Vertex2,Points[0],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((1)+1) shl 0) or (((0)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex1,WorkData^.Vertex2,Points[2],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,WorkData^.Vertex1,Points[2],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((0)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,WorkData^.Vertex1,Points[1],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex2,WorkData^.Vertex0,Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((1)+1) shl 0) or (((-1)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,Points[0],Points[2],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex1,Points[2],Points[0],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex1,WorkData^.Vertex2,Points[2],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
         end;

         (((-1)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex1,Points[1],Points[0],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex2,Points[0],Points[1],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex2,WorkData^.Vertex0,Points[0],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
         end;

         (((-1)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex2,Points[2],Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,Points[1],Points[2],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,WorkData^.Vertex1,Points[1],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
         end;

         (((-1)+1) shl 0) or (((1)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex0,Points[0],Points[2],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex1,Points[2],Points[0],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex1,WorkData^.Vertex2,Points[2],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((1)+1) shl 0) or (((-1)+1) shl 2) or (((1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex1,Points[1],Points[0],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,Points[0],Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex2,WorkData^.Vertex0,Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         (((1)+1) shl 0) or (((1)+1) shl 2) or (((-1)+1) shl 4):begin
          NextTriangle(WorkData^.Node.fBack,WorkData^.Vertex2,Points[2],Points[1],WorkData^.Inside,WorkData^.KeepEdge,WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,Points[1],Points[2],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
          NextTriangle(WorkData^.Node.fFront,WorkData^.Vertex0,WorkData^.Vertex1,Points[1],WorkData^.Inside,WorkData^.KeepEdge,not WorkData^.Inside,WorkData^.Invert);
         end;

         // Otherwise it is a error
         else begin
          WorkData^.Completed:=false;
         end;

        end;

       end;

       1:begin

        if WorkData^.Completed and WorkData^.Clipped then begin
         fVertices.Count:=WorkData^.OldCountVertices;
         fIndices.Count:=WorkData^.OldCountIndices;
         if WorkData^.Invert then begin
          Append(WorkData^.Vertex2.CloneFlip,WorkData^.Vertex1.CloneFlip,WorkData^.Vertex0.CloneFlip);
         end else begin
          Append(WorkData^.Vertex0,WorkData^.Vertex1,WorkData^.Vertex2);
         end;
        end;

        if WorkData^.PreviousWorkData>=0 then begin
         OtherWorkData:=@WorkDataArray.Items[WorkData^.PreviousWorkData];
         OtherWorkData^.Completed:=OtherWorkData^.Completed and WorkData^.Completed;
        end else begin
         FunctionResult:=WorkData^.Completed;
        end;
        dec(WorkDataArray.Count);

       end;

      end;

     end;

    finally
     JobStack.Finalize;
    end;

   finally
    WorkDataArray.Finalize;
   end;

  finally
   result:=FunctionResult;
  end;

 end;
type TJobStack=TDynamicStack<TSingleTreeNode>;
var JobStack:TJobStack;
    Node:TSingleTreeNode;
    Index,Count:TpvSizeInt;
begin
 if assigned(aLeftNode) and assigned(aRightNode) then begin
  JobStack.Initialize;
  try
   JobStack.Push(aRightNode);
   while JobStack.Pop(Node) do begin
    if assigned(Node) then begin
     Index:=0;
     Count:=Node.fIndices.Count;
     while (Index+2)<Count do begin
      ProcessTriangle(aLeftNode,
                       aVertices.Items[Node.fIndices.Items[Index+0]],
                       aVertices.Items[Node.fIndices.Items[Index+1]],
                       aVertices.Items[Node.fIndices.Items[Index+2]],
                       aInside,
                       aKeepEdge,
                       false,
                       aInvert);
      inc(Index,3);
     end;
     if assigned(Node.fFront) then begin
      JobStack.Push(Node.fFront);
     end;
     if assigned(Node.fBack) then begin
      JobStack.Push(Node.fBack);
     end;
    end;
   end;
  finally
   JobStack.Finalize;
  end;
 end;
end;

procedure TpvCSGBSP.TMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(const aOuterLeftMesh:TMesh;
                                                                                   const aInnerLeftMesh:TMesh;
                                                                                   const aInsideRangeAABB:TAABB);
var Index,Count,CountPolygonVertices,
    OtherIndex:TpvSizeInt;
    PolygonAABB:TAABB;
begin
 aOuterLeftMesh.fMode:=fMode;
 aInnerLeftMesh.fMode:=fMode;
 aOuterLeftMesh.SetVertices(fVertices);
 aInnerLeftMesh.SetVertices(fVertices);
 aOuterLeftMesh.fIndices.Clear;
 aInnerLeftMesh.fIndices.Clear;
 Index:=0;
 Count:=fIndices.Count;
 while Index<Count do begin
  case fMode of
   TMode.Triangles:begin
    CountPolygonVertices:=3;
   end;
   else {TMode.Polygons:}begin
    CountPolygonVertices:=fIndices.Items[Index];
    inc(Index);
   end;
  end;
  if CountPolygonVertices>2 then begin
   if (Index+(CountPolygonVertices-1))<Count then begin
    PolygonAABB.Min:=fVertices.Items[fIndices.Items[Index]].Position;
    PolygonAABB.Max:=fVertices.Items[fIndices.Items[Index]].Position;
    for OtherIndex:=Index+1 to Index+(CountPolygonVertices-1) do begin
     PolygonAABB:=PolygonAABB.Combine(fVertices.Items[fIndices.Items[OtherIndex]].Position);
    end;
    if aInsideRangeAABB.Intersects(PolygonAABB) then begin
     if fMode=TMode.Polygons then begin
      aInnerLeftMesh.fIndices.Add(CountPolygonVertices);
     end;
     aInnerLeftMesh.fIndices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
    end else begin
     if fMode=TMode.Polygons then begin
      aOuterLeftMesh.fIndices.Add(CountPolygonVertices);
     end;
     aOuterLeftMesh.fIndices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
    end;
   end;
  end;
  inc(Index,CountPolygonVertices);
 end;
end;


procedure TpvCSGBSP.TMesh.RemoveNearDuplicateIndices(var aIndices:TIndexList);
var Index:TpvSizeInt;
    VertexIndices:array[0..1] of TIndex;
begin
 Index:=0;
 while (Index<aIndices.Count) and
       (aIndices.Count>3) do begin
  VertexIndices[0]:=aIndices.Items[Index];
  if (Index+1)<aIndices.Count then begin
   VertexIndices[1]:=aIndices.Items[Index+1];
  end else begin
   VertexIndices[1]:=aIndices.Items[0];
  end;
  if ((fVertices.Items[VertexIndices[0]].Position-fVertices.Items[VertexIndices[1]].Position).SquaredLength<SquaredNearPositionEpsilon) and
     ((fVertices.Items[VertexIndices[0]].Normal-fVertices.Items[VertexIndices[1]].Normal).SquaredLength<SquaredNearPositionEpsilon) and
     ((fVertices.Items[VertexIndices[0]].TexCoord-fVertices.Items[VertexIndices[1]].TexCoord).SquaredLength<SquaredNearPositionEpsilon) and
     ((fVertices.Items[VertexIndices[0]].Color-fVertices.Items[VertexIndices[1]].Color).SquaredLength<SquaredNearPositionEpsilon) then begin
   aIndices.Delete(Index);
  end else begin
   inc(Index);
  end;
 end;
end;

procedure TpvCSGBSP.TMesh.DoUnion(const aLeftMesh:TMesh;
                                  const aRightMesh:TMesh;
                                  const aCSGMode:TCSGMode;
                                  const aSplitSettings:PSplitSettings=nil);
var LeftMesh,RightMesh:TMesh;
    LeftSingleTreeNode,RightSingleTreeNode:TSingleTreeNode;
    LeftDualTree,RightDualTree:TDualTree;
begin
 case aCSGMode of
  TCSGMode.SingleTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       LeftSingleTreeNode.ClipTo(RightSingleTreeNode);
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       RightSingleTreeNode.Invert;
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       RightSingleTreeNode.Invert;
       LeftSingleTreeNode.Merge(RightSingleTreeNode,aSplitSettings);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     Assign(LeftSingleTreeNode);
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.DualTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftDualTree:=LeftMesh.ToDualTree(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightDualTree:=RightMesh.ToDualTree(aSplitSettings);
      try
       LeftDualTree.ClipTo(RightDualTree,false);
       RightDualTree.ClipTo(LeftDualTree,false);
       RightDualTree.Invert;
       RightDualTree.ClipTo(LeftDualTree,false);
       RightDualTree.Invert;
       LeftDualTree.Merge(RightDualTree);
      finally
       FreeAndNil(RightDualTree);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     Assign(LeftDualTree);
    finally
     FreeAndNil(LeftDualTree);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.Triangles:begin
   SetMode(TMode.Triangles);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Triangles);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Triangles);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       TriangleCSGOperation(RightSingleTreeNode,LeftSingleTreeNode,LeftMesh.fVertices,false,false,false);
       TriangleCSGOperation(LeftSingleTreeNode,RightSingleTreeNode,RightMesh.fVertices,false,true,false);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  else begin
   Assert(false);
  end;
 end;
 RemoveDuplicateAndUnusedVertices;
 if (aLeftMesh.fMode=TMode.Triangles) and (aRightMesh.fMode=TMode.Triangles) then begin
  SetMode(TMode.Triangles);
 end else if (aLeftMesh.fMode=TMode.Polygons) and (aRightMesh.fMode=TMode.Polygons) then begin
  SetMode(TMode.Polygons);
 end;
end;

procedure TpvCSGBSP.TMesh.Union(const aLeftMesh:TMesh;
                                const aRightMesh:TMesh;
                                const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                const aSplitSettings:PSplitSettings=nil);
var AABBLeft,AABBRight,AABBIntersection:TAABB;
    AABBIntersectionMesh,
    OuterLeftMesh,InnerLeftMesh,
    OuterRightMesh,InnerRightMesh:TMesh;
begin
 AABBLeft:=aLeftMesh.GetAxisAlignedBoundingBox;
 AABBRight:=aRightMesh.GetAxisAlignedBoundingBox;
 if AABBLeft.Intersects(AABBRight) then begin
  case aCSGOptimization of
   TMesh.TCSGOptimization.CSG:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    AABBIntersectionMesh:=TMesh.Create(AABBIntersection,TMesh.TMode.Polygons,CSGOptimizationBoundEpsilon);
    try
     OuterLeftMesh:=TMesh.CreateSubtraction(aLeftMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
     try
      InnerLeftMesh:=TMesh.CreateIntersection(aLeftMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
      try
       OuterRightMesh:=TMesh.CreateSubtraction(aRightMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
       try
        InnerRightMesh:=TMesh.CreateIntersection(aRightMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
        try
         DoUnion(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
        finally
         FreeAndNil(InnerRightMesh);
        end;
        Union(OuterRightMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
       finally
        FreeAndNil(OuterRightMesh);
       end;
       Union(OuterLeftMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
      finally
       FreeAndNil(InnerLeftMesh);
      end;
     finally
      FreeAndNil(OuterLeftMesh);
     end;
    finally
     FreeAndNil(AABBIntersectionMesh);
    end;
   end;
   TMesh.TCSGOptimization.Polygons:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    OuterLeftMesh:=TMesh.Create;
    try
     InnerLeftMesh:=TMesh.Create;
     try
      aLeftMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterLeftMesh,InnerLeftMesh,AABBIntersection);
      OuterRightMesh:=TMesh.Create;
      try
       InnerRightMesh:=TMesh.Create;
       try
        aRightMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterRightMesh,InnerRightMesh,AABBIntersection);
        DoUnion(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
       finally
        FreeAndNil(InnerRightMesh);
       end;
       Append(OuterRightMesh);
      finally
       FreeAndNil(OuterRightMesh);
      end;
     finally
      FreeAndNil(InnerLeftMesh);
     end;
     Append(OuterLeftMesh);
    finally
     FreeAndNil(OuterLeftMesh);
    end;
   end;
   else begin
    DoUnion(aLeftMesh,aRightMesh,aCSGMode,aSplitSettings);
   end;
  end;
 end else begin
  Assign(aLeftMesh);
  Append(aRightMesh);
  RemoveDuplicateAndUnusedVertices;
 end;
end;

procedure TpvCSGBSP.TMesh.Union(const aWithMesh:TMesh;
                                const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                const aSplitSettings:PSplitSettings=nil);
var TemporaryMesh:TMesh;
begin
 TemporaryMesh:=TMesh.Create(fMode);
 try
  TemporaryMesh.Union(self,aWithMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  Assign(TemporaryMesh);
 finally
  FreeAndNil(TemporaryMesh);
 end;
end;

procedure TpvCSGBSP.TMesh.UnionOf(const aMeshs:array of TMesh;
                                  const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                  const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                  const aSplitSettings:PSplitSettings=nil);
var Index:TpvSizeInt;
begin
 if length(aMeshs)>0 then begin
  Assign(aMeshs[0]);
  for Index:=1 to length(aMeshs)-1 do begin
   Union(aMeshs[Index],aCSGMode,aCSGOptimization,aSplitSettings);
  end;
 end else begin
  Clear;
 end;
end;

procedure TpvCSGBSP.TMesh.DoSubtraction(const aLeftMesh:TMesh;
                                        const aRightMesh:TMesh;
                                        const aCSGMode:TCSGMode;
                                        const aSplitSettings:PSplitSettings=nil);
var LeftMesh,RightMesh:TMesh;
    LeftSingleTreeNode,RightSingleTreeNode:TSingleTreeNode;
    LeftDualTree,RightDualTree:TDualTree;
begin
 case aCSGMode of
  TCSGMode.SingleTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       LeftSingleTreeNode.Invert;
       LeftSingleTreeNode.ClipTo(RightSingleTreeNode);
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       RightSingleTreeNode.Invert;
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       RightSingleTreeNode.Invert;
       LeftSingleTreeNode.Merge(RightSingleTreeNode,aSplitSettings);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     LeftSingleTreeNode.Invert;
     Assign(LeftSingleTreeNode);
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.DualTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftDualTree:=LeftMesh.ToDualTree(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightDualTree:=RightMesh.ToDualTree(aSplitSettings);
      try
       LeftDualTree.Invert;
       LeftDualTree.ClipTo(RightDualTree,false);
  {$undef UseReferenceBSPOperations}
  {$ifdef UseReferenceBSPOperations}
       RightDualTree.ClipTo(LeftDualTree,false);
       RightDualTree.Invert;
       RightDualTree.ClipTo(LeftDualTree,false);
       RightDualTree.Invert;
  {$else}
       RightDualTree.ClipTo(LeftDualTree,true);
  {$endif}
       LeftDualTree.Merge(RightDualTree);
       LeftDualTree.Invert;
      finally
       FreeAndNil(RightDualTree);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     Assign(LeftDualTree);
    finally
     FreeAndNil(LeftDualTree);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.Triangles:begin
   SetMode(TMode.Triangles);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Triangles);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Triangles);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       TriangleCSGOperation(RightSingleTreeNode,LeftSingleTreeNode,LeftMesh.fVertices,false,false,false);
       TriangleCSGOperation(LeftSingleTreeNode,RightSingleTreeNode,RightMesh.fVertices,true,true,true);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  else begin
   Assert(false);
  end;
 end;
 RemoveDuplicateAndUnusedVertices;
 if (aLeftMesh.fMode=TMode.Triangles) and (aRightMesh.fMode=TMode.Triangles) then begin
  SetMode(TMode.Triangles);
 end else if (aLeftMesh.fMode=TMode.Polygons) and (aRightMesh.fMode=TMode.Polygons) then begin
  SetMode(TMode.Polygons);
 end;
end;

procedure TpvCSGBSP.TMesh.Subtraction(const aLeftMesh:TMesh;
                                      const aRightMesh:TMesh;
                                      const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                      const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                      const aSplitSettings:PSplitSettings=nil);
var AABBLeft,AABBRight,AABBIntersection:TAABB;
    AABBIntersectionMesh,
    OuterLeftMesh,InnerLeftMesh,
    OuterRightMesh,InnerRightMesh:TMesh;
begin
 AABBLeft:=aLeftMesh.GetAxisAlignedBoundingBox;
 AABBRight:=aRightMesh.GetAxisAlignedBoundingBox;
 if AABBLeft.Intersects(AABBRight) then begin
  case aCSGOptimization of
   TMesh.TCSGOptimization.CSG:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    AABBIntersectionMesh:=TMesh.Create(AABBIntersection,TMesh.TMode.Polygons,CSGOptimizationBoundEpsilon);
    try
     OuterLeftMesh:=TMesh.CreateSubtraction(aLeftMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
     try
      InnerLeftMesh:=TMesh.CreateIntersection(aLeftMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
      try
       InnerRightMesh:=TMesh.CreateIntersection(aRightMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
       try
        DoSubtraction(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
       finally
        FreeAndNil(InnerRightMesh);
       end;
       Union(OuterLeftMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
      finally
       FreeAndNil(InnerLeftMesh);
      end;
     finally
      FreeAndNil(OuterLeftMesh);
     end;
    finally
     FreeAndNil(AABBIntersectionMesh);
    end;
   end;
   TMesh.TCSGOptimization.Polygons:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    OuterLeftMesh:=TMesh.Create;
    try
     InnerLeftMesh:=TMesh.Create;
     try
      aLeftMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterLeftMesh,InnerLeftMesh,AABBIntersection);
      OuterRightMesh:=TMesh.Create;
      try
       InnerRightMesh:=TMesh.Create;
       try
        aRightMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterRightMesh,InnerRightMesh,AABBIntersection);
        DoSubtraction(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
       finally
        FreeAndNil(InnerRightMesh);
       end;
      finally
       FreeAndNil(OuterRightMesh);
      end;
     finally
      FreeAndNil(InnerLeftMesh);
     end;
     Append(OuterLeftMesh);
    finally
     FreeAndNil(OuterLeftMesh);
    end;
   end;
   else begin
    DoSubtraction(aLeftMesh,aRightMesh,aCSGMode,aSplitSettings);
   end;
  end;
 end else begin
  Assign(aLeftMesh);
  RemoveDuplicateAndUnusedVertices;
 end;
end;

procedure TpvCSGBSP.TMesh.Subtraction(const aWithMesh:TMesh;
                                      const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                      const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                      const aSplitSettings:PSplitSettings=nil);
var TemporaryMesh:TMesh;
begin
 TemporaryMesh:=TMesh.Create(fMode);
 try
  TemporaryMesh.Subtraction(self,aWithMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  Assign(TemporaryMesh);
 finally
  FreeAndNil(TemporaryMesh);
 end;
end;

procedure TpvCSGBSP.TMesh.SubtractionOf(const aMeshs:array of TMesh;
                                        const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                        const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                        const aSplitSettings:PSplitSettings=nil);
var Index:TpvSizeInt;
begin
 if length(aMeshs)>0 then begin
  Assign(aMeshs[0]);
  for Index:=1 to length(aMeshs)-1 do begin
   Subtraction(aMeshs[Index],aCSGMode,aCSGOptimization,aSplitSettings);
  end;
 end else begin
  Clear;
 end;
end;

procedure TpvCSGBSP.TMesh.DoIntersection(const aLeftMesh:TMesh;
                                         const aRightMesh:TMesh;
                                         const aCSGMode:TCSGMode;
                                         const aSplitSettings:PSplitSettings=nil);
var LeftMesh,RightMesh:TMesh;
    LeftSingleTreeNode,RightSingleTreeNode:TSingleTreeNode;
    LeftDualTree,RightDualTree:TDualTree;
begin
 case aCSGMode of
  TCSGMode.SingleTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       LeftSingleTreeNode.Invert;
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       RightSingleTreeNode.Invert;
       LeftSingleTreeNode.ClipTo(RightSingleTreeNode);
       RightSingleTreeNode.ClipTo(LeftSingleTreeNode);
       LeftSingleTreeNode.Merge(RightSingleTreeNode,aSplitSettings);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     LeftSingleTreeNode.Invert;
     Assign(LeftSingleTreeNode);
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.DualTree:begin
   SetMode(TMode.Polygons);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Polygons);
    LeftDualTree:=LeftMesh.ToDualTree(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Polygons);
      RightDualTree:=RightMesh.ToDualTree(aSplitSettings);
      try
       LeftDualTree.Invert;
       RightDualTree.ClipTo(LeftDualTree,false);
       RightDualTree.Invert;
       LeftDualTree.ClipTo(RightDualTree,false);
       RightDualTree.ClipTo(LeftDualTree,false);
       LeftDualTree.Merge(RightDualTree);
       LeftDualTree.Invert;
      finally
       FreeAndNil(RightDualTree);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
     Assign(LeftDualTree);
    finally
     FreeAndNil(LeftDualTree);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  TCSGMode.Triangles:begin
   SetMode(TMode.Triangles);
   LeftMesh:=TMesh.Create(aLeftMesh);
   try
    LeftMesh.SetMode(TMode.Triangles);
    LeftSingleTreeNode:=LeftMesh.ToSingleTreeNode(aSplitSettings);
    try
     RightMesh:=TMesh.Create(aRightMesh);
     try
      RightMesh.SetMode(TMode.Triangles);
      RightSingleTreeNode:=RightMesh.ToSingleTreeNode(aSplitSettings);
      try
       TriangleCSGOperation(RightSingleTreeNode,LeftSingleTreeNode,LeftMesh.fVertices,true,false,false);
       TriangleCSGOperation(LeftSingleTreeNode,RightSingleTreeNode,RightMesh.fVertices,true,true,false);
      finally
       FreeAndNil(RightSingleTreeNode);
      end;
     finally
      FreeAndNil(RightMesh);
     end;
    finally
     FreeAndNil(LeftSingleTreeNode);
    end;
   finally
    FreeAndNil(LeftMesh);
   end;
  end;
  else begin
   Assert(false);
  end;
 end;
 RemoveDuplicateAndUnusedVertices;
 if (aLeftMesh.fMode=TMode.Triangles) and (aRightMesh.fMode=TMode.Triangles) then begin
  SetMode(TMode.Triangles);
 end else if (aLeftMesh.fMode=TMode.Polygons) and (aRightMesh.fMode=TMode.Polygons) then begin
  SetMode(TMode.Polygons);
 end;
end;

procedure TpvCSGBSP.TMesh.Intersection(const aLeftMesh:TMesh;
                                       const aRightMesh:TMesh;
                                       const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                       const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                       const aSplitSettings:PSplitSettings=nil);
var AABBLeft,AABBRight,AABBIntersection:TAABB;
    AABBIntersectionMesh,
    OuterLeftMesh,InnerLeftMesh,
    OuterRightMesh,InnerRightMesh:TMesh;
begin
 AABBLeft:=aLeftMesh.GetAxisAlignedBoundingBox;
 AABBRight:=aRightMesh.GetAxisAlignedBoundingBox;
 if AABBLeft.Intersects(AABBRight) then begin
  case aCSGOptimization of
   TMesh.TCSGOptimization.CSG:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    AABBIntersectionMesh:=TMesh.Create(AABBIntersection,TMesh.TMode.Polygons,CSGOptimizationBoundEpsilon);
    try
     InnerLeftMesh:=TMesh.CreateIntersection(aLeftMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
     try
      InnerRightMesh:=TMesh.CreateIntersection(aRightMesh,AABBIntersectionMesh,aCSGMode,TMesh.TCSGOptimization.None,aSplitSettings);
      try
       DoIntersection(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
      finally
       FreeAndNil(InnerRightMesh);
      end;
     finally
      FreeAndNil(InnerLeftMesh);
     end;
    finally
     FreeAndNil(AABBIntersectionMesh);
    end;
   end;
   TMesh.TCSGOptimization.Polygons:begin
    AABBIntersection:=AABBLeft.Intersection(AABBRight);
    OuterLeftMesh:=TMesh.Create;
    try
     InnerLeftMesh:=TMesh.Create;
     try
      aLeftMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterLeftMesh,InnerLeftMesh,AABBIntersection);
      OuterRightMesh:=TMesh.Create;
      try
       InnerRightMesh:=TMesh.Create;
       try
        aRightMesh.FastSplitPolygonsIntoOuterAndInnerMeshsByInsideRangeAABB(OuterRightMesh,InnerRightMesh,AABBIntersection);
        DoIntersection(InnerLeftMesh,InnerRightMesh,aCSGMode,aSplitSettings);
       finally
        FreeAndNil(InnerRightMesh);
       end;
      finally
       FreeAndNil(OuterRightMesh);
      end;
     finally
      FreeAndNil(InnerLeftMesh);
     end;
    finally
     FreeAndNil(OuterLeftMesh);
    end;
   end;
   else begin
    DoIntersection(aLeftMesh,aRightMesh,aCSGMode,aSplitSettings);
   end;
  end;
 end else begin
  Clear;
 end;
end;

procedure TpvCSGBSP.TMesh.Intersection(const aWithMesh:TMesh;
                                       const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                       const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                       const aSplitSettings:PSplitSettings=nil);
var TemporaryMesh:TMesh;
begin
 TemporaryMesh:=TMesh.Create(fMode);
 try
  TemporaryMesh.Intersection(self,aWithMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  Assign(TemporaryMesh);
 finally
  FreeAndNil(TemporaryMesh);
 end;
end;

procedure TpvCSGBSP.TMesh.IntersectionOf(const aMeshs:array of TMesh;
                                         const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                         const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                         const aSplitSettings:PSplitSettings=nil);
var Index:TpvSizeInt;
begin
 if length(aMeshs)>0 then begin
  Assign(aMeshs[0]);
  for Index:=1 to length(aMeshs)-1 do begin
   Intersection(aMeshs[Index],aCSGMode,aCSGOptimization,aSplitSettings);
  end;
 end else begin
  Clear;
 end;
end;

procedure TpvCSGBSP.TMesh.SymmetricDifference(const aLeftMesh:TMesh;
                                              const aRightMesh:TMesh;
                                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                              const aSplitSettings:PSplitSettings=nil);
var a,b:TMesh;
begin
 // Possible symmertic difference (boolean XOR) implementations:
 // Intersection(Union(A,B),Inverse(Intersection(A,B)))
 // Intersection(Union(A,B),Union(Inverse(A),Inverse(B)))
 // Union(Subtraction(A,B),Subtraction(B,A)) <= used here, because it seems the most robust mnethod in this BSP-based triangle-based CSG implementation!
 // Subtraction(Union(A,B),Intersection(A,B))
 a:=TMesh.CreateSubtraction(aLeftMesh,aRightMesh,aCSGMode,aCSGOptimization,aSplitSettings);
 try
  b:=TMesh.CreateSubtraction(aRightMesh,aLeftMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  try
   Union(a,b,aCSGMode,aCSGOptimization,aSplitSettings);
  finally
   FreeAndNil(b);
  end;
 finally
  FreeAndNil(a);
 end;
end;

procedure TpvCSGBSP.TMesh.SymmetricDifference(const aWithMesh:TMesh;
                                              const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                              const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                              const aSplitSettings:PSplitSettings=nil);
var TemporaryMesh:TMesh;
begin
 TemporaryMesh:=TMesh.Create(fMode);
 try
  TemporaryMesh.SymmetricDifference(self,aWithMesh,aCSGMode,aCSGOptimization,aSplitSettings);
  Assign(TemporaryMesh);
 finally
  FreeAndNil(TemporaryMesh);
 end;
end;

procedure TpvCSGBSP.TMesh.SymmetricDifferenceOf(const aMeshs:array of TMesh;
                                                const aCSGMode:TCSGMode=TCSGMode.DualTree;
                                                const aCSGOptimization:TCSGOptimization=TCSGOptimization.None;
                                                const aSplitSettings:PSplitSettings=nil);
var Index:TpvSizeInt;
begin
 if length(aMeshs)>0 then begin
  Assign(aMeshs[0]);
  for Index:=1 to length(aMeshs)-1 do begin
   SymmetricDifference(aMeshs[Index],aCSGMode,aCSGOptimization,aSplitSettings);
  end;
 end else begin
  Clear;
 end;
end;

procedure TpvCSGBSP.TMesh.Canonicalize;
var Index,Count,CountPolygonVertices:TpvSizeInt;
    NewIndices,WorkIndices:TIndexList;
begin
 NewIndices.Initialize;
 try
  WorkIndices.Initialize;
  try
   Index:=0;
   Count:=fIndices.Count;
   while Index<Count do begin
    case fMode of
     TMode.Triangles:begin
      CountPolygonVertices:=3;
     end;
     else {TMode.Polygons:}begin
      CountPolygonVertices:=fIndices.Items[Index];
      inc(Index);
     end;
    end;
    if CountPolygonVertices>2 then begin
     if (Index+(CountPolygonVertices-1))<Count then begin
      WorkIndices.Count:=0;
      WorkIndices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
      RemoveNearDuplicateIndices(WorkIndices);
      if WorkIndices.Count>2 then begin
       case fMode of
        TMode.Triangles:begin
        end;
        else {TMode.Polygons:}begin
         NewIndices.Add(WorkIndices.Count);
        end;
       end;
       NewIndices.Add(WorkIndices);
      end;
     end;
    end;
    inc(Index,CountPolygonVertices);
   end;
  finally
   WorkIndices.Finalize;
  end;
  SetIndices(NewIndices);
 finally
  NewIndices.Finalize;
 end;
 RemoveDuplicateAndUnusedVertices;
end;

procedure TpvCSGBSP.TMesh.CalculateNormals(const aCreasedNormalAngleThreshold:TFloat=90.0;
                                           const aSoftNormals:boolean=true;
                                           const aAreaWeighting:boolean=true;
                                           const aAngleWeighting:boolean=true;
                                           const aCreasedNormalAngleWeighting:boolean=true;
                                           const aCheckForCreasedNormals:boolean=true);
const DegreesToRadians=pi/180.0;
type TNormalItem=record
      PolygonNormal:TVector3;
      VertexNormal:TVector3;
     end;
     PNormalItem=^TNormalItem;
     TNormalList=TDynamicArray<TNormalItem>;
     PNormalList=^TNormalList;
     TPositionUniqueVerticesHashMap=TVector3HashMap<TIndex>;
     TPositionUniqueVerticesBuckets=TDynamicArray<TIndexList>;
     TPositionUniqueVerticesReverseIndex=array of TpvSizeInt;
     TPositionUniqueVerticesPositions=TDynamicArray<TVector3>;
var Index,Count,CountPolygonVertices,OtherIndex,NormalItemIndex:TpvSizeInt;
    Position0,Position1,Position2:PVector3;
    Index0,Index1,Index2:TIndex;
    Vertex:TVertex;
    PointerToVertex:PVertex;
    CurrentNormal,PolygonNormal:TVector3;
    NormalLists:array of TNormalList;
    NormalList:PNormalList;
    NormalListItem:PNormalItem;
    d01,d12,d20,s,r,Angle,AngleThreshold:TFloat;
    PositionUniqueVerticesHashMap:TPositionUniqueVerticesHashMap;
    PositionUniqueVerticesBuckets:TPositionUniqueVerticesBuckets;
    PositionUniqueVerticesReverseIndex:TPositionUniqueVerticesReverseIndex;
    PositionUniqueVerticesPositions:TPositionUniqueVerticesPositions;
begin

 // Clear all normals on the input vertices
 for Index:=0 to fVertices.Count-1 do begin
  fVertices.Items[Index].Normal:=TVector3.Create(0.0,0.0,0.0);
 end;

 // Remove duplicate input vertices after all normals were cleared
 RemoveDuplicateAndUnusedVertices;

 if aSoftNormals then begin

  AngleThreshold:=Min(Max(cos(aCreasedNormalAngleThreshold*DegreesToRadians),-OneMinusEpsilon),OneMinusEpsilon);
  if IsZero(AngleThreshold) or IsNaN(AngleThreshold) then begin
   AngleThreshold:=0.0;
  end;

  PositionUniqueVerticesHashMap:=TPositionUniqueVerticesHashMap.Create(-1);
  try

   PositionUniqueVerticesBuckets.Initialize;
   try

    SetLength(PositionUniqueVerticesReverseIndex,fVertices.Count);
    try

     PositionUniqueVerticesPositions.Initialize;
     try

      // Gather all vertices with near-equal positions together
      for Index:=0 to fVertices.Count-1 do begin
       PointerToVertex:=@fVertices.Items[Index];
       Index0:=PositionUniqueVerticesHashMap[PointerToVertex^.Position];
       if Index0<0 then begin
        Index0:=PositionUniqueVerticesBuckets.AddNew;
        PositionUniqueVerticesBuckets.Items[Index0].Initialize;
        PositionUniqueVerticesHashMap[PointerToVertex^.Position]:=Index0;
        PositionUniqueVerticesPositions.Add(PointerToVertex^.Position);
       end;
       PositionUniqueVerticesBuckets.Items[Index0].Add(Index);
       PositionUniqueVerticesReverseIndex[Index]:=Index0;
      end;

      Assert(PositionUniqueVerticesBuckets.Count=PositionUniqueVerticesPositions.Count);

      NormalLists:=nil;
      try

       // Initialize
       SetLength(NormalLists,PositionUniqueVerticesPositions.Count);
       for Index:=0 to length(NormalLists)-1 do begin
        NormalLists[Index].Initialize;
        NormalLists[Index].Clear;
       end;

       // Pass 1 - Gathering
       begin

        Index:=0;

        Count:=fIndices.Count;

        while Index<Count do begin

         case fMode of
          TMode.Triangles:begin
           CountPolygonVertices:=3;
          end;
          else {TMode.Polygons:}begin
           CountPolygonVertices:=fIndices.Items[Index];
           inc(Index);
          end;
         end;

         if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin

          // Calculate and find valid whole-polygon normal (where degenerated convex
          // tessellated triangles will be ignored here)
          PolygonNormal:=TVector3.Create(0.0,0.0,0.0);
          Index0:=fIndices.Items[Index+0];
          Index1:=fIndices.Items[Index+1];
          Position0:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index0]];
          Position1:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index1]];
          for OtherIndex:=2 to CountPolygonVertices-1 do begin
           Index2:=fIndices.Items[Index+OtherIndex];
           Position2:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index2]];
           PolygonNormal:=(Position1^-Position0^).Cross(Position2^-Position0^);
           if PolygonNormal.SquaredLength>SquaredEpsilon then begin
            PolygonNormal:=PolygonNormal.Normalize;
            break;
           end else begin
            Index1:=Index2;
            Position1:=Position2;
           end;
          end;

          // Gathering smooth normal information data
          Index0:=fIndices.Items[Index+0];
          Index1:=fIndices.Items[Index+1];

          Position0:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index0]];
          Position1:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index1]];

          for OtherIndex:=2 to CountPolygonVertices-1 do begin

           Index2:=fIndices.Items[Index+OtherIndex];
           Position2:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index2]];

           CurrentNormal:=(Position1^-Position0^).Cross(Position2^-Position0^);

           if not aAreaWeighting then begin
            CurrentNormal:=CurrentNormal.Normalize;
           end;

           d01:=(Position0^-Position1^).Length;
           d12:=(Position1^-Position2^).Length;
           d20:=(Position2^-Position0^).Length;

           if aAngleWeighting and (d01>=Epsilon) and (d12>=Epsilon) and (d20>=Epsilon) then begin

            s:=(d01+d12+d20)*0.5;
            r:=sqrt(((s-d01)*(s-d12)*(s-d20))/s);

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index0]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal*ArcTan2(r,s-d12);
            end;

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index1]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal*ArcTan2(r,s-d20);
            end;

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index2]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal*ArcTan2(r,s-d01);
            end;

           end else begin

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index0]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal;
            end;

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index1]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal;
            end;

            begin
             NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index2]];
             NormalItemIndex:=NormalList^.AddNew;
             NormalListItem:=@NormalList^.Items[NormalItemIndex];
             NormalListItem^.PolygonNormal:=PolygonNormal;
             NormalListItem^.VertexNormal:=CurrentNormal;
            end;

           end;

           Index1:=Index2;
           Position1:=Position2;

          end;

         end;

         inc(Index,CountPolygonVertices);

        end;

       end;

       // Pass 2 - Applying
       begin

        Index:=0;

        Count:=fIndices.Count;

        while Index<Count do begin

         case fMode of
          TMode.Triangles:begin
           CountPolygonVertices:=3;
          end;
          else {TMode.Polygons:}begin
           CountPolygonVertices:=fIndices.Items[Index];
           inc(Index);
          end;
         end;

         if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin

          // Calculate and find valid whole-polygon normal (where degenerated convex
          // tessellated triangles will be ignored here)
          PolygonNormal:=TVector3.Create(0.0,0.0,0.0);
          Index0:=fIndices.Items[Index+0];
          Index1:=fIndices.Items[Index+1];
          Position0:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index0]];
          Position1:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index1]];
          for OtherIndex:=2 to CountPolygonVertices-1 do begin
           Index2:=fIndices.Items[Index+OtherIndex];
           Position2:=@PositionUniqueVerticesPositions.Items[PositionUniqueVerticesReverseIndex[Index2]];
           PolygonNormal:=(Position1^-Position0^).Cross(Position2^-Position0^);
           if PolygonNormal.SquaredLength>SquaredEpsilon then begin
            PolygonNormal:=PolygonNormal.Normalize;
            break;
           end else begin
            Index1:=Index2;
            Position1:=Position2;
           end;
          end;

          // Apply new ormals to all then-cloned vertices (they will be cloned for to be
          // unique per polygon, the then old unused vertices will be removed later anyway)
          for OtherIndex:=0 to CountPolygonVertices-1 do begin
           Index0:=fIndices.Items[Index+OtherIndex];
           CurrentNormal:=TVector3.Create(0.0,0.0,0.0);
           NormalList:=@NormalLists[PositionUniqueVerticesReverseIndex[Index0]];
           for NormalItemIndex:=0 to NormalList^.Count-1 do begin
            NormalListItem:=@NormalList^.Items[NormalItemIndex];
            Angle:=PolygonNormal.Dot(NormalListItem^.PolygonNormal);
            if (not aCheckForCreasedNormals) or
               (Angle>=AngleThreshold) then begin
             if aCreasedNormalAngleWeighting then begin
              if Angle<0.0 then begin
               Angle:=0.0;
              end;
             end else begin
              Angle:=1.0;
             end;
             CurrentNormal:=CurrentNormal+(NormalListItem^.VertexNormal*Angle);
            end;
           end;
           Vertex:=fVertices.Items[Index0];
           Vertex.Normal:=CurrentNormal.Normalize;
           fIndices.Items[Index+OtherIndex]:=fVertices.Add(Vertex);
          end;

         end;

         inc(Index,CountPolygonVertices);

        end;

       end;

       // Clean up
       for Index:=0 to length(NormalLists)-1 do begin
        NormalLists[Index].Finalize;
       end;

      finally
       SetLength(NormalLists,0);
      end;

     finally
      PositionUniqueVerticesPositions.Finalize;
     end;

    finally
     PositionUniqueVerticesReverseIndex:=nil;
    end;

   finally
    PositionUniqueVerticesBuckets.Finalize;
   end;

  finally
   FreeAndNil(PositionUniqueVerticesHashMap);
  end;

 end else begin

  // Go through all indices polygon-wise

  Index:=0;
  Count:=fIndices.Count;

  while Index<Count do begin

   case fMode of
    TMode.Triangles:begin
     CountPolygonVertices:=3;
    end;
    else {TMode.Polygons:}begin
     CountPolygonVertices:=fIndices.Items[Index];
     inc(Index);
    end;
   end;

   if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin

    // Calculate and find valid whole-polygon normal (where degenerated convex
    // tessellated triangles will be ignored here)
    PolygonNormal:=TVector3.Create(0.0,0.0,0.0);
    Index0:=fIndices.Items[Index+0];
    Index1:=fIndices.Items[Index+1];
    Position0:=@fVertices.Items[Index0].Position;
    Position1:=@fVertices.Items[Index1].Position;
    for OtherIndex:=2 to CountPolygonVertices-1 do begin
     Index2:=fIndices.Items[Index+OtherIndex];
     Position2:=@fVertices.Items[Index2].Position;
     PolygonNormal:=(Position1^-Position0^).Cross(Position2^-Position0^);
     if PolygonNormal.SquaredLength>SquaredEpsilon then begin
      PolygonNormal:=PolygonNormal.Normalize;
      break;
     end else begin
      Index1:=Index2;
      Position1:=Position2;
     end;
    end;

    // Apply this normal to all then-cloned vertices (they will be cloned for to be
    // unique per polygon, the then old unused vertices will be removed later anyway)
    while (CountPolygonVertices>0) and (Index<Count) do begin
     Vertex:=fVertices.Items[fIndices.Items[Index]];
     Vertex.Normal:=PolygonNormal;
     fIndices.Items[Index]:=fVertices.Add(Vertex);
     inc(Index);
     dec(CountPolygonVertices);
    end;

   end;

   inc(Index,CountPolygonVertices);

  end;

 end;

 // Remove old unused input vertices
 RemoveDuplicateAndUnusedVertices;

end;

procedure TpvCSGBSP.TMesh.RemoveDuplicateAndUnusedVertices;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type THashTableItem=record
      Next:TpvSizeInt;
      Hash:TpvUInt32;
      VertexIndex:TIndex;
     end;
     PHashTableItem=^THashTableItem;
     THashTableItems=array of THashTableItem;
     THashTable=array of TpvSizeInt;
var Index,Count,CountPolygonVertices,
    HashIndex,CountHashTableItems:TpvSizeInt;
    Vertex,OtherVertex:PVertex;
    VertexIndex:TIndex;
    NewVertices:TVertexList;
    NewIndices:TIndexList;
    HashTable:THashTable;
    HashTableItems:THashTableItems;
    Hash:TpvUInt32;
    HashTableItem:PHashTableItem;
begin
 NewVertices.Initialize;
 try
  NewIndices.Initialize;
  try
   HashTable:=nil;
   try
    SetLength(HashTable,HashSize);
    for Index:=0 to HashSize-1 do begin
     HashTable[Index]:=-1;
    end;
    HashTableItems:=nil;
    CountHashTableItems:=0;
    try
     Index:=0;
     Count:=fIndices.Count;
     while Index<Count do begin
      case fMode of
       TMode.Triangles:begin
        CountPolygonVertices:=3;
       end;
       else {TMode.Polygons:}begin
        CountPolygonVertices:=fIndices.Items[Index];
        NewIndices.Add(CountPolygonVertices);
        inc(Index);
       end;
      end;
      while (CountPolygonVertices>0) and (Index<Count) do begin
       dec(CountPolygonVertices);
       Vertex:=@fVertices.Items[fIndices.Items[Index]];
       VertexIndex:=-1;
       Hash:=(round(Vertex.Position.x*4096)*73856093) xor
             (round(Vertex.Position.y*4096)*19349653) xor
             (round(Vertex.Position.z*4096)*83492791);
       HashIndex:=HashTable[Hash and HashMask];
       while HashIndex>=0 do begin
        HashTableItem:=@HashTableItems[HashIndex];
        if HashTableItem^.Hash=Hash then begin
         OtherVertex:=@NewVertices.Items[HashTableItem^.VertexIndex];
         if Vertex^=OtherVertex^ then begin
          VertexIndex:=HashTableItem^.VertexIndex;
          break;
         end;
        end;
        HashIndex:=HashTableItem^.Next;
       end;
       if VertexIndex<0 then begin
        VertexIndex:=NewVertices.Add(Vertex^);
        HashIndex:=CountHashTableItems;
        inc(CountHashTableItems);
        if CountHashTableItems>length(HashTableItems) then begin
         SetLength(HashTableItems,CountHashTableItems*2);
        end;
        HashTableItem:=@HashTableItems[HashIndex];
        HashTableItem^.Next:=HashTable[Hash and HashMask];
        HashTable[Hash and HashMask]:=HashIndex;
        HashTableItem^.Hash:=Hash;
        HashTableItem^.VertexIndex:=VertexIndex;
       end;
       NewIndices.Add(VertexIndex);
       inc(Index);
      end;
     end;
     SetVertices(NewVertices);
     SetIndices(NewIndices);
    finally
     HashTableItems:=nil;
    end;
   finally
    HashTable:=nil;
   end;
  finally
   NewIndices.Finalize;
  end;
 finally
  NewVertices.Finalize;
 end;
end;

procedure TpvCSGBSP.TMesh.FixTJunctions(const aConsistentInputVertices:boolean=false);
 function Wrap(const aIndex,aCount:TpvSizeInt):TpvSizeInt;
 begin
  result:=aIndex;
  if aCount>0 then begin
   while result<0 do begin
    inc(result,aCount);
   end;
   while result>=aCount do begin
    dec(result,aCount);
   end;
  end;
 end;
 procedure FixTJunctionsWithConsistentInputVertices;
 type TPolygon=record
       Indices:TIndexList;
      end;
      PPolygon=^TPolygon;
      TPolygons=TDynamicArray<TPolygon>;
      TEdgeVertexIndices=array[0..1] of TIndex;
      PEdgeVertexIndices=^TEdgeVertexIndices;
      TEdgeHashMap=THashMap<TEdgeVertexIndices,TpvSizeInt>;
      TEdge=record
       VertexIndices:TEdgeVertexIndices;
       PolygonIndex:TpvSizeInT;
      end;
      PEdge=^TEdge;
      TEdges=TDynamicArray<TEdge>;
      PEdges=^TEdges;
      TEdgesList=TDynamicArray<TEdges>;
      TEdgeIndexList=TDynamicArray<TpvSizeInt>;
      PEdgeIndexList=^TEdgeIndexList;
      TEdgeVertexIndicesList=TDynamicArray<TEdgeVertexIndices>;
      TVertexIndexToEdgeStartEndList=TDynamicArray<TEdgeVertexIndicesList>;
      TVertexIndexToEdgeStartEndHashMap=THashMap<TIndex,TpvSizeInt>;
      TEdgesToCheckHashMap=THashMap<TEdgeVertexIndices,boolean>;
 var Index,Count,CountPolygonVertices,
     PolygonIndex:TpvSizeInt;
     Polygons:TPolygons;
     Polygon:PPolygon;
     NewIndices:TIndexList;
     EdgeHashMap:TEdgeHashMap;
     EdgesList:TEdgesList;
     VertexIndexToEdgeStartList:TVertexIndexToEdgeStartEndList;
     VertexIndexToEdgeEndList:TVertexIndexToEdgeStartEndList;
     VertexIndexToEdgeStartHashMap:TVertexIndexToEdgeStartEndHashMap;
     VertexIndexToEdgeEndHashMap:TVertexIndexToEdgeStartEndHashMap;
     EdgeMapIsEmpty:boolean;
     EdgesToCheck:TEdgesToCheckHashMap;
     OldMode:TMode;
  procedure ScanEdges;
  var PolygonIndex,PolygonIndicesIndex,EdgesIndex:TpvSizeInt;
      VertexIndex,NextVertexIndex:TIndex;
      Polygon:PPolygon;
      EdgeVertexIndices,
      ReversedEdgeVertexIndices:TEdgeVertexIndices;
      Edges:PEdges;
      Edge:TEdge;
  begin
   for PolygonIndex:=0 to Polygons.Count-1 do begin
    Polygon:=@Polygons.Items[PolygonIndex];
    if Polygon^.Indices.Count>2 then begin
     for PolygonIndicesIndex:=0 to Polygon^.Indices.Count-1 do begin
      VertexIndex:=Polygon^.Indices.Items[PolygonIndicesIndex];
      NextVertexIndex:=Polygon^.Indices.Items[Wrap(PolygonIndicesIndex+1,Polygon^.Indices.Count)];
      EdgeVertexIndices[0]:=VertexIndex;
      EdgeVertexIndices[1]:=NextVertexIndex;
      ReversedEdgeVertexIndices[1]:=VertexIndex;
      ReversedEdgeVertexIndices[0]:=NextVertexIndex;
      if EdgeHashMap.TryGet(ReversedEdgeVertexIndices,EdgesIndex) then begin
       Edges:=@EdgesList.Items[EdgesIndex];
       if Edges^.Count>0 then begin
        Edges^.Delete(Edges^.Count-1);
        if Edges^.Count=0 then begin
         EdgeHashMap.Delete(ReversedEdgeVertexIndices);
        end;
       end;
      end else begin
       if not EdgeHashMap.TryGet(EdgeVertexIndices,EdgesIndex) then begin
        EdgesIndex:=EdgesList.AddNew;
        Edges:=@EdgesList.Items[EdgesIndex];
        Edges^.Initialize;
        EdgeHashMap.Add(EdgeVertexIndices,EdgesIndex);
       end;
       Edges:=@EdgesList.Items[EdgesIndex];
       Edge.VertexIndices:=EdgeVertexIndices;
       Edge.PolygonIndex:=PolygonIndex;
       Edges^.Add(Edge);
      end;
     end;
    end;
   end;
  end;
  procedure ScanVertices;
  var EdgeHashMapKeyIndex,EdgesIndex,
      VertexIndexToEdgeStartEndIndex:TpvSizeInt;
      EdgeVertexIndices:PEdgeVertexIndices;
      Entity:TEdgeHashMap.PHashMapEntity;
      Edges:PEdges;
      Edge:PEdge;
  begin
   EdgeMapIsEmpty:=true;
   for EdgeHashMapKeyIndex:=0 to EdgeHashMap.fSize-1 do begin
    if EdgeHashMap.fEntityToCellIndex[EdgeHashMapKeyIndex]>=0 then begin
     EdgeMapIsEmpty:=false;
     Entity:=@EdgeHashMap.fEntities[EdgeHashMapKeyIndex];
     EdgesToCheck.Add(Entity^.Key,true);
     Edges:=@EdgesList.Items[Entity^.Value];
     for EdgesIndex:=0 to Edges^.Count-1 do begin
      Edge:=@Edges^.Items[EdgesIndex];
      begin
       if not VertexIndexToEdgeStartHashMap.TryGet(Edge^.VertexIndices[0],VertexIndexToEdgeStartEndIndex) then begin
        VertexIndexToEdgeStartEndIndex:=VertexIndexToEdgeStartList.AddNew;
        VertexIndexToEdgeStartHashMap.Add(Edge^.VertexIndices[0],VertexIndexToEdgeStartEndIndex);
        VertexIndexToEdgeStartList.Items[VertexIndexToEdgeStartEndIndex].Initialize;
       end;
       VertexIndexToEdgeStartList.Items[VertexIndexToEdgeStartEndIndex].Add(Entity^.Key);
      end;
      begin
       if not VertexIndexToEdgeEndHashMap.TryGet(Edge^.VertexIndices[1],VertexIndexToEdgeStartEndIndex) then begin
        VertexIndexToEdgeStartEndIndex:=VertexIndexToEdgeEndList.AddNew;
        VertexIndexToEdgeEndHashMap.Add(Edge^.VertexIndices[1],VertexIndexToEdgeStartEndIndex);
        VertexIndexToEdgeEndList.Items[VertexIndexToEdgeStartEndIndex].Initialize;
       end;
       VertexIndexToEdgeEndList.Items[VertexIndexToEdgeStartEndIndex].Add(Entity^.Key);
      end;
     end;
    end;
   end;
  end;
  procedure Process;
  var EdgeHashMapKeyIndex,EdgesIndex,EdgeIndex,
      VertexIndexToEdgeStartEndIndex,
      EdgesToCheckIndex,
      DirectionIndex,
      MatchingEdgesListIndex,
      PolygonIndicesIndex,
      InsertionPolygonIndicesIndex:TpvSizeInt;
      Entity:TEdgeHashMap.PHashMapEntity;
      Edges:PEdges;
      Edge,MatchingEdge:TEdge;
      Done,DoneWithEdge:boolean;
      EdgeVertexIndices,
      NewEdgeVertexIndices0,
      NewEdgeVertexIndices1:TEdgeVertexIndices;
      StartVertexIndex,EndVertexIndex,
      MatchingEdgeStartVertexIndex,
      MatchingEdgeEndVertexIndex,
      OtherIndex:TIndex;
      MatchingEdgesList:TEdgeVertexIndicesList;
      MatchingEdgeVertexIndices:TEdgeVertexIndices;
      StartPosition,EndPosition,CheckPosition,
      Direction,ClosestPoint:TVector3;
      Time:TFloat;
      Polygon:PPolygon;
      NewPolygon:TPolygon;
   procedure DeleteEdge(const aVertexIndex0,aVertexIndex1:TIndex;const aPolygonIndex:TpvSizeInt);
   var Index,FoundIndex,EdgesIndex,OtherIndex:TpvSizeInt;
       EdgeVertexIndices:TEdgeVertexIndices;
       Edges:PEdges;
       Edge:PEdge;
   begin

    EdgeVertexIndices[0]:=aVertexIndex0;
    EdgeVertexIndices[1]:=aVertexIndex1;

    EdgesIndex:=EdgeHashMap[EdgeVertexIndices];
    Assert(EdgesIndex>=0);

    Edges:=@EdgesList.Items[EdgesIndex];

    FoundIndex:=-1;

    for Index:=0 to Edges^.Count-1 do begin
     Edge:=@Edges^.Items[Index];
     if (Edge^.VertexIndices[0]<>aVertexIndex0) or
        (Edge^.VertexIndices[1]<>aVertexIndex1) or
        ((aPolygonIndex>=0) and
         (Edge^.PolygonIndex<>aPolygonIndex)) then begin
      continue;
     end;
     FoundIndex:=Index;
     break;
    end;
    Assert(FoundIndex>=0);

    Edges^.Delete(FoundIndex);

    if Edges^.Count=0 then begin
     EdgeHashMap.Delete(EdgeVertexIndices);
    end;

    Index:=VertexIndexToEdgeStartHashMap[aVertexIndex0];
    Assert(Index>=0);
    FoundIndex:=-1;
    for OtherIndex:=0 to VertexIndexToEdgeStartList.Items[Index].Count-1 do begin
     if (VertexIndexToEdgeStartList.Items[Index].Items[OtherIndex][0]=EdgeVertexIndices[0]) and
        (VertexIndexToEdgeStartList.Items[Index].Items[OtherIndex][1]=EdgeVertexIndices[1]) then begin
      FoundIndex:=OtherIndex;
      break;
     end;
    end;
    Assert(FoundIndex>=0);
    VertexIndexToEdgeStartList.Items[Index].Delete(FoundIndex);
    if VertexIndexToEdgeStartList.Items[Index].Count=0 then begin
     VertexIndexToEdgeStartHashMap.Delete(aVertexIndex0);
    end;

    Index:=VertexIndexToEdgeEndHashMap[aVertexIndex1];
    Assert(Index>=0);
    FoundIndex:=-1;
    for OtherIndex:=0 to VertexIndexToEdgeEndList.Items[Index].Count-1 do begin
     if (VertexIndexToEdgeEndList.Items[Index].Items[OtherIndex][0]=EdgeVertexIndices[0]) and
        (VertexIndexToEdgeEndList.Items[Index].Items[OtherIndex][1]=EdgeVertexIndices[1]) then begin
      FoundIndex:=OtherIndex;
      break;
     end;
    end;
    Assert(FoundIndex>=0);
    VertexIndexToEdgeEndList.Items[Index].Delete(FoundIndex);
    if VertexIndexToEdgeEndList.Items[Index].Count=0 then begin
     VertexIndexToEdgeEndHashMap.Delete(aVertexIndex1);
    end;

   end;
   function AddEdge(const aVertexIndex0,aVertexIndex1:TIndex;const aPolygonIndex:TpvSizeInt):TEdgeVertexIndices;
   var EdgesIndex,
       VertexIndexToEdgeStartEndIndex:TpvSizeInt;
       EdgeVertexIndices,
       ReversedEdgeVertexIndices:TEdgeVertexIndices;
       Edges:PEdges;
       Edge:TEdge;
   begin

    result[0]:=-1;

    Assert(aVertexIndex0<>aVertexIndex1);

    EdgeVertexIndices[0]:=aVertexIndex0;
    EdgeVertexIndices[1]:=aVertexIndex1;

    if EdgeHashMap.ExistKey(ReversedEdgeVertexIndices) then begin
     DeleteEdge(aVertexIndex1,aVertexIndex0,-1);
     exit;
    end;

    if not EdgeHashMap.TryGet(EdgeVertexIndices,EdgesIndex) then begin
     EdgesIndex:=EdgesList.AddNew;
     Edges:=@EdgesList.Items[EdgesIndex];
     Edges^.Initialize;
     EdgeHashMap.Add(EdgeVertexIndices,EdgesIndex);
    end;
    Edges:=@EdgesList.Items[EdgesIndex];
    Edge.VertexIndices:=EdgeVertexIndices;
    Edge.PolygonIndex:=aPolygonIndex;
    Edges^.Add(Edge);

    begin
     if not VertexIndexToEdgeStartHashMap.TryGet(Edge.VertexIndices[0],VertexIndexToEdgeStartEndIndex) then begin
      VertexIndexToEdgeStartEndIndex:=VertexIndexToEdgeStartList.AddNew;
      VertexIndexToEdgeStartHashMap.Add(Edge.VertexIndices[0],VertexIndexToEdgeStartEndIndex);
      VertexIndexToEdgeStartList.Items[VertexIndexToEdgeStartEndIndex].Initialize;
     end;
     VertexIndexToEdgeStartList.Items[VertexIndexToEdgeStartEndIndex].Add(EdgeVertexIndices);
    end;

    begin
     if not VertexIndexToEdgeEndHashMap.TryGet(Edge.VertexIndices[1],VertexIndexToEdgeStartEndIndex) then begin
      VertexIndexToEdgeStartEndIndex:=VertexIndexToEdgeEndList.AddNew;
      VertexIndexToEdgeEndHashMap.Add(Edge.VertexIndices[1],VertexIndexToEdgeStartEndIndex);
      VertexIndexToEdgeEndList.Items[VertexIndexToEdgeStartEndIndex].Initialize;
     end;
     VertexIndexToEdgeEndList.Items[VertexIndexToEdgeStartEndIndex].Add(EdgeVertexIndices);
    end;

   end;
  begin

   repeat

    EdgeMapIsEmpty:=true;
    for EdgeHashMapKeyIndex:=0 to EdgeHashMap.fSize-1 do begin
     if EdgeHashMap.fEntityToCellIndex[EdgeHashMapKeyIndex]>=0 then begin
      EdgeMapIsEmpty:=false;
      Entity:=@EdgeHashMap.fEntities[EdgeHashMapKeyIndex];
      EdgesToCheck.Add(Entity^.Key,true);
     end;
    end;
    if EdgeMapIsEmpty then begin
     break;
    end;

    Done:=false;

    repeat

     EdgeVertexIndices[0]:=-1;
     EdgeVertexIndices[1]:=-1;
     for EdgesToCheckIndex:=0 to EdgesToCheck.fSize-1 do begin
      if EdgesToCheck.fEntityToCellIndex[EdgesToCheckIndex]>=0 then begin
       EdgeVertexIndices:=EdgesToCheck.fEntities[EdgesToCheckIndex].Key;
       break;
      end;
     end;
     if EdgeVertexIndices[0]<0 then begin
      break;
     end;

     DoneWithEdge:=true;

     if EdgeHashMap.TryGet(EdgeVertexIndices,EdgesIndex) then begin

      Edges:=@EdgesList.Items[EdgesIndex];
      Assert(Edges^.Count>0);

      Edge:=Edges^.Items[0];

      for DirectionIndex:=0 to 1 do begin

       if DirectionIndex=0 then begin
        StartVertexIndex:=Edge.VertexIndices[0];
        EndVertexIndex:=Edge.VertexIndices[1];
       end else begin
        StartVertexIndex:=Edge.VertexIndices[1];
        EndVertexIndex:=Edge.VertexIndices[0];
       end;

       MatchingEdgesList.Initialize;

       if DirectionIndex=0 then begin
        if VertexIndexToEdgeEndHashMap.TryGet(StartVertexIndex,VertexIndexToEdgeStartEndIndex) then begin
         MatchingEdgesList.Assign(VertexIndexToEdgeEndList.Items[VertexIndexToEdgeStartEndIndex]);
        end;
       end else begin
        if VertexIndexToEdgeStartHashMap.TryGet(StartVertexIndex,VertexIndexToEdgeStartEndIndex) then begin
         MatchingEdgesList.Assign(VertexIndexToEdgeStartList.Items[VertexIndexToEdgeStartEndIndex]);
        end;
       end;

       for MatchingEdgesListIndex:=0 to MatchingEdgesList.Count-1 do begin

        MatchingEdgeVertexIndices:=MatchingEdgesList.Items[MatchingEdgesListIndex];

        EdgesIndex:=EdgeHashMap[MatchingEdgeVertexIndices];

        Assert(EdgesIndex>=0);

        Edges:=@EdgesList.Items[EdgesIndex];

        Assert(Edges^.Count>0);

        MatchingEdge:=Edges^.Items[0];

        if DirectionIndex=0 then begin
         MatchingEdgeStartVertexIndex:=MatchingEdge.VertexIndices[0];
         MatchingEdgeEndVertexIndex:=MatchingEdge.VertexIndices[1];
        end else begin
         MatchingEdgeStartVertexIndex:=MatchingEdge.VertexIndices[1];
         MatchingEdgeEndVertexIndex:=MatchingEdge.VertexIndices[0];
        end;

        Assert(MatchingEdgeEndVertexIndex=StartVertexIndex);

        if MatchingEdgeStartVertexIndex=EndVertexIndex then begin

         DeleteEdge(StartVertexIndex,EndVertexIndex,-1);

         DeleteEdge(EndVertexIndex,StartVertexIndex,-1);

         DoneWithEdge:=false;

         Done:=true;

         break;

        end else begin

         StartPosition:=fVertices.Items[StartVertexIndex].Position;

         EndPosition:=fVertices.Items[EndVertexIndex].Position;

         CheckPosition:=fVertices.Items[MatchingEdgeStartVertexIndex].Position;

         Direction:=CheckPosition-StartPosition;

         Time:=(EndPosition-StartPosition).Dot(Direction)/Direction.Dot(Direction);

         if (Time>0.0) and (Time<1.0) then begin

          ClosestPoint:=StartPosition.Lerp(CheckPosition,Time);

          if (ClosestPoint-EndPosition).SquaredLength<1e-10 then begin

           PolygonIndex:=MatchingEdge.PolygonIndex;

           Polygon:=@Polygons.Items[PolygonIndex];

           InsertionPolygonIndicesIndex:=-1;
           for PolygonIndicesIndex:=0 to Polygon^.Indices.Count-1 do begin
            if Polygon^.Indices.Items[PolygonIndicesIndex]=MatchingEdge.VertexIndices[1] then begin
             InsertionPolygonIndicesIndex:=PolygonIndicesIndex;
             break;
            end;
           end;
           Assert(InsertionPolygonIndicesIndex>=0);

           Polygons.Items[PolygonIndex].Indices.Insert(InsertionPolygonIndicesIndex,EndVertexIndex);

           DeleteEdge(MatchingEdge.VertexIndices[0],MatchingEdge.VertexIndices[1],PolygonIndex);

           NewEdgeVertexIndices0:=AddEdge(MatchingEdge.VertexIndices[0],EndVertexIndex,PolygonIndex);

           NewEdgeVertexIndices1:=AddEdge(EndVertexIndex,MatchingEdge.VertexIndices[1],PolygonIndex);

           if NewEdgeVertexIndices0[0]>=0 then begin
            EdgesToCheck[NewEdgeVertexIndices0]:=true;
           end;

           if NewEdgeVertexIndices1[0]>=0 then begin
            EdgesToCheck[NewEdgeVertexIndices1]:=true;
           end;

           DoneWithEdge:=false;

           Done:=true;

           break;

          end;

         end;

        end;

       end;

       if Done then begin
        break;
       end;

      end;

     end;

     if DoneWithEdge then begin
      EdgesToCheck.Delete(EdgeVertexIndices);
     end;

    until false;

   until Done;

  end;
 begin

  OldMode:=fMode;
  try

   SetMode(TMode.Polygons);

   try

    Polygons.Initialize;
    try

     Index:=0;
     Count:=fIndices.Count;
     while Index<Count do begin
      CountPolygonVertices:=fIndices.Items[Index];
      inc(Index);
      if (CountPolygonVertices>0) and
         ((Index+(CountPolygonVertices-1))<Count) then begin
       if CountPolygonVertices>2 then begin
        PolygonIndex:=Polygons.AddNew;
        Polygon:=@Polygons.Items[PolygonIndex];
        Polygon^.Indices.Initialize;
        Polygon^.Indices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
       end;
      end;
      inc(Index,CountPolygonVertices);
     end;

     EdgeHashMap:=TEdgeHashMap.Create(-1);
     try

      EdgesList.Initialize;
      try

       ScanEdges;

       VertexIndexToEdgeStartList.Initialize;
       try

        VertexIndexToEdgeEndList.Initialize;
        try

         VertexIndexToEdgeStartHashMap:=TVertexIndexToEdgeStartEndHashMap.Create(-1);
         try

          VertexIndexToEdgeEndHashMap:=TVertexIndexToEdgeStartEndHashMap.Create(-1);
          try

           EdgesToCheck:=TEdgesToCheckHashMap.Create(false);
           try

            ScanVertices;

            if not EdgeMapIsEmpty then begin
             Process;
            end;

           finally
            FreeAndNil(EdgesToCheck);
           end;

          finally
           FreeAndNil(VertexIndexToEdgeEndHashMap);
          end;

         finally
          FreeAndNil(VertexIndexToEdgeStartHashMap);
         end;

        finally
         VertexIndexToEdgeEndList.Finalize;
        end;

       finally
        VertexIndexToEdgeStartList.Finalize;
       end;

      finally
       EdgesList.Finalize;
      end;

     finally
      FreeAndNil(EdgeHashMap);
     end;

     NewIndices.Initialize;
     try
      for PolygonIndex:=0 to Polygons.Count-1 do begin
       Polygon:=@Polygons.Items[PolygonIndex];
       NewIndices.Add(Polygon^.Indices.Count);
       NewIndices.Add(Polygon^.Indices);
      end;
      SetIndices(NewIndices);
     finally
      NewIndices.Finalize;
     end;

    finally
     Polygons.Finalize;
    end;

   finally
    SetMode(OldMode);
   end;

  finally
   RemoveDuplicateAndUnusedVertices;
  end;

 end;
 procedure FixTJunctionsWithNonConsistentInputVertices;
 type TPolygon=record
       Indices:TIndexList;
       Plane:TPlane;
       AABB:TAABB;
      end;
      PPolygon=^TPolygon;
      TPolygons=TDynamicArray<TPolygon>;
      TPolygonAABBTreeStack=TDynamicStack<TpvSizeInt>;
 var Index,Count,CountPolygonVertices,
     PolygonIndex,
     PolygonIndicesIndex,
     PolygonAABBTreeNodeID,
     OtherPolygonIndex,
     OtherPolygonIndicesIndex,
     PolygonVertexIndexA,
     PolygonVertexIndexB,
     OtherPolygonVertexIndex:TpvSizeInt;
     Polygons:TPolygons;
     Polygon,
     OtherPolygon:PPolygon;
     PolygonAABBTree:TDynamicAABBTree;
     PolygonAABBTreeNode:PDynamicAABBTreeNode;
     PolygonAABBTreeStack:TPolygonAABBTreeStack;
     NewIndices:TIndexList;
     OldMode:TMode;
     DoTryAgain:boolean;
     PolygonVertexA,
     PolygonVertexB,
     OtherPolygonVertex:PVertex;
     Direction,
     NormalizedDirection,
     FromPolygonVertexAToOtherPolygonVertex:TVector3;
     Time:TFloat;
 begin

  OldMode:=fMode;
  try

   SetMode(TMode.Polygons);

   try

    Polygons.Initialize;
    try

     PolygonAABBTree:=TDynamicAABBTree.Create;
     try

      Index:=0;
      Count:=fIndices.Count;
      while Index<Count do begin
       CountPolygonVertices:=fIndices.Items[Index];
       inc(Index);
       if (CountPolygonVertices>0) and
          ((Index+(CountPolygonVertices-1))<Count) then begin
        if CountPolygonVertices>2 then begin
         PolygonIndex:=Polygons.AddNew;
         Polygon:=@Polygons.Items[PolygonIndex];
         Polygon^.Indices.Initialize;
         Polygon^.Indices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
         Polygon^.Plane:=TpvCSGBSP.TPlane.Create(fVertices.Items[Polygon^.Indices.Items[0]].Position,
                                                 fVertices.Items[Polygon^.Indices.Items[1]].Position,
                                                 fVertices.Items[Polygon^.Indices.Items[2]].Position);
         Polygon^.AABB.Min.x:=Infinity;
         Polygon^.AABB.Min.y:=Infinity;
         Polygon^.AABB.Min.z:=Infinity;
         Polygon^.AABB.Max.x:=-Infinity;
         Polygon^.AABB.Max.y:=-Infinity;
         Polygon^.AABB.Max.z:=-Infinity;
         for PolygonIndicesIndex:=0 to Polygon^.Indices.Count-1 do begin
          Polygon^.AABB:=Polygon^.AABB.Combine(fVertices.Items[Polygon^.Indices.Items[PolygonIndicesIndex]].Position);
         end;
         PolygonAABBTree.CreateProxy(Polygon^.AABB,PolygonIndex);
        end;
       end;
       inc(Index,CountPolygonVertices);
      end;

      PolygonAABBTreeStack.Initialize;
      try
       repeat
        DoTryAgain:=false;
        for PolygonIndex:=0 to Polygons.Count-1 do begin
         Polygon:=@Polygons.Items[PolygonIndex];
         if PolygonAABBTree.Root>=0 then begin
          PolygonAABBTreeStack.Count:=0;
          PolygonAABBTreeStack.Push(PolygonAABBTree.Root);
          while PolygonAABBTreeStack.Pop(PolygonAABBTreeNodeID) and not DoTryAgain do begin
           PolygonAABBTreeNode:=@PolygonAABBTree.Nodes[PolygonAABBTreeNodeID];
           if PolygonAABBTreeNode^.AABB.Intersects(Polygon^.AABB) then begin
            if PolygonAABBTreeNode^.Children[0]<0 then begin
             OtherPolygonIndex:=PolygonAABBTreeNode^.UserData;
             if PolygonIndex<>OtherPolygonIndex then begin
              OtherPolygon:=@Polygons.Items[OtherPolygonIndex];
              PolygonIndicesIndex:=0;
              while PolygonIndicesIndex<Polygon^.Indices.Count do begin
               PolygonVertexIndexA:=Polygon^.Indices.Items[PolygonIndicesIndex];
               PolygonVertexIndexB:=Polygon^.Indices.Items[Wrap(PolygonIndicesIndex+1,Polygon^.Indices.Count)];
               PolygonVertexA:=@fVertices.Items[PolygonVertexIndexA];
               PolygonVertexB:=@fVertices.Items[PolygonVertexIndexB];
               Direction:=PolygonVertexB^.Position-PolygonVertexA^.Position;
               NormalizedDirection:=Direction.Normalize;
               OtherPolygonIndicesIndex:=0;
               while OtherPolygonIndicesIndex<OtherPolygon^.Indices.Count do begin
                OtherPolygonVertexIndex:=OtherPolygon^.Indices.Items[OtherPolygonIndicesIndex];
                OtherPolygonVertex:=@fVertices.Items[OtherPolygonVertexIndex];
                if (PolygonVertexIndexA<>OtherPolygonVertexIndex) and
                   (PolygonVertexIndexB<>OtherPolygonVertexIndex) and
                   (PolygonVertexA^.Position<>OtherPolygonVertex^.Position) and
                   (PolygonVertexB^.Position<>OtherPolygonVertex^.Position) then begin
                 FromPolygonVertexAToOtherPolygonVertex:=OtherPolygonVertex^.Position-PolygonVertexA^.Position;
                 if (NormalizedDirection.Dot(FromPolygonVertexAToOtherPolygonVertex.Normalize)>=TJunctionOneMinusEpsilon) and
                    (NormalizedDirection.Dot((PolygonVertexB^.Position-OtherPolygonVertex^.Position).Normalize)>=TJunctionOneMinusEpsilon) then begin
                  Time:=FromPolygonVertexAToOtherPolygonVertex.Dot(Direction)/Direction.Dot(Direction);
                  if ((Time>=TJunctionEpsilon) and (Time<=TJunctionOneMinusEpsilon)) and
                     (((Direction*Time)-FromPolygonVertexAToOtherPolygonVertex).SquaredLength<TJunctionEpsilon) then begin
                   Polygon^.Indices.Insert(PolygonIndicesIndex+1,fVertices.Add(PolygonVertexA^.Lerp(PolygonVertexB^,Time)));
                   begin
                    // Reload polygon vertex pointers, because the old ones could be invalid here now
                    PolygonVertexA:=@fVertices.Items[PolygonVertexIndexA];
                    PolygonVertexB:=@fVertices.Items[PolygonVertexIndexB];
                   end;
                   // And we do not need update the AABB of the polygon, because the new inserted
                   // vertex is coplanar between two end points of a old edge of the polygon
                   DoTryAgain:=true;
                  end;
                 end;
                end;
                inc(OtherPolygonIndicesIndex);
               end;
               inc(PolygonIndicesIndex);
              end;
             end;
            end else begin
             if PolygonAABBTreeNode^.Children[1]>=0 then begin
              PolygonAABBTreeStack.Push(PolygonAABBTreeNode^.Children[1]);
             end;
             if PolygonAABBTreeNode^.Children[0]>=0 then begin
              PolygonAABBTreeStack.Push(PolygonAABBTreeNode^.Children[0]);
             end;
            end;
           end;
          end;
         end;
        end;
       until not DoTryAgain;
      finally
       PolygonAABBTreeStack.Finalize;
      end;

      NewIndices.Initialize;
      try
       for PolygonIndex:=0 to Polygons.Count-1 do begin
        Polygon:=@Polygons.Items[PolygonIndex];
        NewIndices.Add(Polygon^.Indices.Count);
        NewIndices.Add(Polygon^.Indices);
       end;
       SetIndices(NewIndices);
      finally
       NewIndices.Finalize;
      end;

     finally
      FreeAndNil(PolygonAABBTree);
     end;

    finally
     Polygons.Finalize;
    end;

   finally
    SetMode(OldMode);
   end;

  finally
   RemoveDuplicateAndUnusedVertices;
  end;

 end;
begin
 if aConsistentInputVertices then begin
  FixTJunctionsWithConsistentInputVertices;
 end else begin
  FixTJunctionsWithNonConsistentInputVertices;
 end;
end;

procedure TpvCSGBSP.TMesh.MergeCoplanarConvexPolygons;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type TPolygon=record
      Indices:TIndexList;
      Plane:TPlane;
     end;
     PPolygon=^TPolygon;
     TPolygons=TDynamicArray<TPolygon>;
     TPolygonIndices=TDynamicArray<TpvSizeInt>;
     TPolygonPlane=record
      Plane:TPlane;
      PolygonIndices:TPolygonIndices;
     end;
     PPolygonPlane=^TPolygonPlane;
     TPolygonPlanes=TDynamicArray<TPolygonPlane>;
     THashTableItem=record
      Next:TpvSizeInt;
      Hash:TpvUInt32;
      PolygonPlaneIndex:TpvSizeInt;
     end;
     PHashTableItem=^THashTableItem;
     THashTableItems=array of THashTableItem;
     THashTable=array of TpvSizeInt;
var Index,Count,CountPolygonVertices,
    HashIndex,CountHashTableItems,
    InputPolygonIndex,
    PolygonPlaneIndex,
    PolygonIndex,
    IndexA,
    IndexB,
    Pass:TpvSizeInt;
    InputPolygons,OutputPolygons,
    TemporaryPolygons:TPolygons;
    InputPolygon,OutputPolygon:PPolygon;
    TemporaryOutputPolygon:TPolygon;
    PolygonPlanes:TPolygonPlanes;
    PolygonPlane:PPolygonPlane;
    NewIndices:TIndexList;
    HashTable:THashTable;
    HashTableItems:THashTableItems;
    Hash:TpvUInt32;
    HashTableItem:PHashTableItem;
    DoTryAgain:boolean;
 function Wrap(const aIndex,aCount:TpvSizeInt):TpvSizeInt;
 begin
  result:=aIndex;
  if aCount>0 then begin
   while result<0 do begin
    inc(result,aCount);
   end;
   while result>=aCount do begin
    dec(result,aCount);
   end;
  end;
 end;
 function IsPolygonConvex(const aPolygon:TPolygon):boolean;
 var Index:TpvSizeInt;
     n,p,q:TVector3;
     a,k:TFloat;
     Sign:boolean;
     va,vb,vc:PVector3;
     pa,pb,pc,pba,pcb:TVector2;
 begin

  result:=aPolygon.Indices.Count>2;

  if result then begin

   n:=aPolygon.Plane.Normal.Normalize;

   if abs(n.z)>0.70710678118 then begin
    a:=sqr(n.y)+sqr(n.z);
    k:=1.0/sqrt(a);
    p.x:=0.0;
    p.y:=-(n.z*k);
    p.z:=n.y*k;
    q.x:=a*k;
    q.y:=-(n.x*p.z);
    q.z:=n.x*p.y;
   end else begin
    a:=sqr(n.x)+sqr(n.y);
    k:=1.0/sqrt(a);
    p.x:=-(n.y*k);
    p.y:=n.x*k;
    p.z:=0.0;
    q.x:=-(n.z*p.y);
    q.y:=n.z*p.x;
    q.z:=a*k;
   end;

   p:=p.Normalize;
   q:=q.Normalize;

   Sign:=false;

   for Index:=0 to aPolygon.Indices.Count-1 do begin
    va:=@fVertices.Items[aPolygon.Indices.Items[Wrap(Index-1,aPolygon.Indices.Count)]].Position;
    vb:=@fVertices.Items[aPolygon.Indices.Items[Index]].Position;
    vc:=@fVertices.Items[aPolygon.Indices.Items[Wrap(Index+1,aPolygon.Indices.Count)]].Position;
    pa.x:=p.Dot(va^);
    pa.y:=q.Dot(va^);
    pb.x:=p.Dot(vb^);
    pb.y:=q.Dot(vb^);
    pc.x:=p.Dot(vc^);
    pc.y:=q.Dot(vc^);
    pba:=pb-pa;
    pcb:=pc-pb;
    a:=(pba.x*pcb.y)-(pba.y*pcb.x);
    if Index=0 then begin
     Sign:=a>EPSILON;
    end else if Sign<>(a>EPSILON) then begin
     result:=false;
     break;
    end;
   end;

  end;

 end;
 procedure RemoveCoplanarEdges(var aPolygon:TPolygon);
 type TSideCrossPlaneNormals=TDynamicArray<TVector3>;
 var Index:TpvSizeInt;
     LastVertexIndex,VertexIndex,NextVertexIndex:TIndex;
     v0,v1,v2:PVector3;
     Normal,v10,SideCrossPlaneNormal:TVector3;
     SideCrossPlaneNormals:TSideCrossPlaneNormals;
 begin
  // Remove coplanar edges
  SideCrossPlaneNormals.Initialize;
  try
   Normal:=aPolygon.Plane.Normal.Normalize;
   Index:=0;
   while (aPolygon.Indices.Count>3) and
         (Index<aPolygon.Indices.Count) do begin
    LastVertexIndex:=aPolygon.Indices.Items[Wrap(Index-1,aPolygon.Indices.Count)];
    VertexIndex:=aPolygon.Indices.Items[Index];
    NextVertexIndex:=aPolygon.Indices.Items[Wrap(Index+1,aPolygon.Indices.Count)];
    v0:=@fVertices.Items[LastVertexIndex].Position;
    v1:=@fVertices.Items[VertexIndex].Position;
    v2:=@fVertices.Items[NextVertexIndex].Position;
    v10:=v1^-v0^;
    SideCrossPlaneNormal:=v10.Cross(Normal);
    if Index<SideCrossPlaneNormals.Count then begin
     SideCrossPlaneNormals.Items[Index]:=SideCrossPlaneNormal;
    end else begin
     SideCrossPlaneNormals.Add(SideCrossPlaneNormal);
    end;
    if (abs((v2^-v0^).Normalize.Dot(v10.Normalize))>OneMinusEpsilon) or
       (abs(SideCrossPlaneNormal.Length)<Epsilon) then begin
     aPolygon.Indices.Delete(Index);
     if Index>0 then begin
      dec(Index);
     end;
    end else begin
     inc(Index);
    end;
   end;
   for Index:=0 to SideCrossPlaneNormals.Count-1 do begin
    SideCrossPlaneNormals.Items[Index]:=SideCrossPlaneNormals.Items[Index].Normalize;
   end;
   Index:=0;
   while (aPolygon.Indices.Count>3) and
         (Index<aPolygon.Indices.Count) do begin
    if SideCrossPlaneNormals.Items[Index].Dot(SideCrossPlaneNormals.Items[Wrap(Index+1,aPolygon.Indices.Count)])>OneMinusEpsilon then begin
     aPolygon.Indices.Delete(Index);
     SideCrossPlaneNormals.Delete(Index);
     if Index>0 then begin
      dec(Index);
     end;
    end else begin
     inc(Index);
    end;
   end;
  finally
   SideCrossPlaneNormals.Finalize;
  end;
 end;
 function MergeTwoPolygons(const aPolygonA,aPolygonB:TPolygon;out aOutputPolygon:TPolygon):boolean;
 var Index,OtherIndex,CurrentIndex,IndexA,IndexB:TpvSizeInt;
     i0,i1,i2,i3,LastVertexIndex,VertexIndex:TIndex;
     Found,KeepA,KeepB:boolean;
 begin

  result:=false;

  if IsPolygonConvex(aPolygonA) and
     IsPolygonConvex(aPolygonB) then begin

   // Find shared edge
   Found:=false;
   i0:=0;
   i1:=1;
   IndexA:=0;
   IndexB:=0;
   for Index:=0 to aPolygonA.Indices.Count-1 do begin
    i0:=aPolygonA.Indices.Items[Index];
    i1:=aPolygonA.Indices.Items[Wrap(Index+1,aPolygonA.Indices.Count)];
    for OtherIndex:=0 to aPolygonB.Indices.Count-1 do begin
     i2:=aPolygonB.Indices.Items[OtherIndex];
     i3:=aPolygonB.Indices.Items[Wrap(OtherIndex+1,aPolygonB.Indices.Count)];
     if (i0=i3) and (i1=i2) then begin
      IndexA:=Index;
      IndexB:=OtherIndex;
      Found:=true;
      break;
     end;
    end;
    if Found then begin
     break;
    end;
   end;
   if not Found then begin
    exit;
   end;

   aOutputPolygon.Indices.Initialize;

   aOutputPolygon.Plane:=aPolygonA.Plane;

   // Check for coplanar edges near shared edges

   KeepA:=abs((fVertices.Items[aPolygonB.Indices.Items[Wrap(IndexB+2,aPolygonB.Indices.Count)]].Position-
               fVertices.Items[i0].Position).Dot(aPolygonA.Plane.Normal.Cross(fVertices.Items[i0].Position-fVertices.Items[aPolygonA.Indices.Items[Wrap(IndexA-1,aPolygonA.Indices.Count)]].Position).Normalize))>EPSILON;

   KeepB:=abs((fVertices.Items[aPolygonB.Indices.Items[Wrap(IndexB-1,aPolygonB.Indices.Count)]].Position-
               fVertices.Items[i1].Position).Dot(aPolygonA.Plane.Normal.Cross(fVertices.Items[aPolygonA.Indices.Items[Wrap(IndexA+2,aPolygonA.Indices.Count)]].Position-fVertices.Items[i1].Position).Normalize))>EPSILON;

   // Construct hopefully then convex polygons

   LastVertexIndex:=-1;
   for CurrentIndex:=1+(ord(not KeepB) and 1) to aPolygonA.Indices.Count-1 do begin
    Index:=Wrap(CurrentIndex+IndexA,aPolygonA.Indices.Count);
    VertexIndex:=aPolygonA.Indices.Items[Index];
    if not (((LastVertexIndex=i0) and (VertexIndex=i1)) or
            ((LastVertexIndex=i1) and (VertexIndex=i0))) then begin
     aOutputPolygon.Indices.Add(VertexIndex);
     LastVertexIndex:=VertexIndex;
    end;
   end;
   for CurrentIndex:=1+(ord(not KeepA) and 1) to aPolygonB.Indices.Count-1 do begin
    Index:=Wrap(CurrentIndex+IndexB,aPolygonB.Indices.Count);
    VertexIndex:=aPolygonB.Indices.Items[Index];
    if not (((LastVertexIndex=i0) and (VertexIndex=i1)) or
            ((LastVertexIndex=i1) and (VertexIndex=i0))) then begin
     aOutputPolygon.Indices.Add(VertexIndex);
     LastVertexIndex:=VertexIndex;
    end;
   end;
   if (aOutputPolygon.Indices.Count>1) and
      (((aOutputPolygon.Indices.Items[0]=i0) and (aOutputPolygon.Indices.Items[aOutputPolygon.Indices.Count-1]=i1)) or
       ((aOutputPolygon.Indices.Items[0]=i1) and (aOutputPolygon.Indices.Items[aOutputPolygon.Indices.Count-1]=i0))) then begin
    aOutputPolygon.Indices.Delete(aOutputPolygon.Indices.Count-1);
   end;

   result:=IsPolygonConvex(aOutputPolygon);

  end;

 end;
 procedure MergePolygons(var aPolygons:TPolygons);
 begin

 end;
 function HashPolygonPlane(const aPlane:TPlane):TpvSizeInt;
 var HashIndex:TpvSizeInt;
     Hash:TpvUInt32;
     HashTableItem:PHashTableItem;
     PolygonPlane:PPolygonPlane;
 begin
  Hash:=(trunc(aPlane.Normal.x*4096)*73856093) xor
        (trunc(aPlane.Normal.y*4096)*19349653) xor
        (trunc(aPlane.Normal.z*4096)*83492791) xor
        (trunc(aPlane.Distance*4096)*41728657);
  HashIndex:=HashTable[Hash and HashMask];
  while HashIndex>=0 do begin
   HashTableItem:=@HashTableItems[HashIndex];
   if HashTableItem^.Hash=Hash then begin
    PolygonPlane:=@PolygonPlanes.Items[HashTableItem^.PolygonPlaneIndex];
    if (aPlane.Normal=PolygonPlane^.Plane.Normal) and
       SameValue(aPlane.Distance,PolygonPlane^.Plane.Distance) then begin
     result:=HashTableItem^.PolygonPlaneIndex;
     exit;
    end;
   end;
   HashIndex:=HashTableItem^.Next;
  end;
  result:=PolygonPlanes.AddNew;
  PolygonPlane:=@PolygonPlanes.Items[result];
  PolygonPlane^.Plane:=aPlane;
  PolygonPlane^.PolygonIndices.Initialize;
  HashIndex:=CountHashTableItems;
  inc(CountHashTableItems);
  if CountHashTableItems>length(HashTableItems) then begin
   SetLength(HashTableItems,CountHashTableItems*2);
  end;
  HashTableItem:=@HashTableItems[HashIndex];
  HashTableItem^.Next:=HashTable[Hash and HashMask];
  HashTable[Hash and HashMask]:=HashIndex;
  HashTableItem^.Hash:=Hash;
  HashTableItem^.PolygonPlaneIndex:=result;
 end;
begin

 RemoveDuplicateAndUnusedVertices;

 SetMode(TMode.Polygons);

 try

  InputPolygons.Initialize;
  try

   PolygonPlanes.Initialize;
   try

    HashTable:=nil;
    try

     SetLength(HashTable,HashSize);

     for Index:=0 to HashSize-1 do begin
      HashTable[Index]:=-1;
     end;

     HashTableItems:=nil;
     CountHashTableItems:=0;

     try

      Index:=0;
      Count:=fIndices.Count;
      while Index<Count do begin
       CountPolygonVertices:=fIndices.Items[Index];
       inc(Index);
       if (CountPolygonVertices>0) and
          ((Index+(CountPolygonVertices-1))<Count) then begin
        if CountPolygonVertices>2 then begin
         InputPolygonIndex:=InputPolygons.AddNew;
         InputPolygon:=@InputPolygons.Items[InputPolygonIndex];
         InputPolygon^.Indices.Initialize;
         InputPolygon^.Indices.AddRangeFrom(fIndices,Index,CountPolygonVertices);
         InputPolygon^.Plane:=TpvCSGBSP.TPlane.Create(fVertices.Items[InputPolygon^.Indices.Items[0]].Position,
                                                      fVertices.Items[InputPolygon^.Indices.Items[1]].Position,
                                                      fVertices.Items[InputPolygon^.Indices.Items[2]].Position);
         PolygonPlaneIndex:=HashPolygonPlane(InputPolygon^.Plane);
         PolygonPlane:=@PolygonPlanes.Items[PolygonPlaneIndex];
         PolygonPlane^.PolygonIndices.Add(InputPolygonIndex);
        end;
       end;
       inc(Index,CountPolygonVertices);
      end;

     finally
      HashTableItems:=nil;
     end;

    finally
     HashTable:=nil;
    end;

    OutputPolygons.Initialize;
    try

     for PolygonPlaneIndex:=0 to PolygonPlanes.Count-1 do begin
      PolygonPlane:=@PolygonPlanes.Items[PolygonPlaneIndex];
    { if not (SameValue(PolygonPlane^.Plane.Normal.x,1.0) and
              SameValue(PolygonPlane^.Plane.Normal.y,0.0) and
              SameValue(PolygonPlane^.Plane.Normal.z,0.0)) then begin
       continue;
      end;{}
      if PolygonPlane^.PolygonIndices.Count>0 then begin
       if PolygonPlane^.PolygonIndices.Count<2 then begin
        for PolygonIndex:=0 to PolygonPlane^.PolygonIndices.Count-1 do begin
         OutputPolygons.Add(InputPolygons.Items[PolygonPlane^.PolygonIndices.Items[PolygonIndex]]);
        end;
       end else begin
        TemporaryPolygons.Initialize;
        try
         for PolygonIndex:=0 to PolygonPlane^.PolygonIndices.Count-1 do begin
          TemporaryPolygons.Add(InputPolygons.Items[PolygonPlane^.PolygonIndices.Items[PolygonIndex]]);
         end;
         for Pass:=0 to 1 do begin
          repeat
           DoTryAgain:=false;
           Count:=TemporaryPolygons.Count;
           IndexA:=0;
           while IndexA<Count do begin
            IndexB:=IndexA+1;
            while IndexB<Count do begin
             TemporaryOutputPolygon.Indices.Initialize;
             if MergeTwoPolygons(TemporaryPolygons.Items[IndexA],
                                 TemporaryPolygons.Items[IndexB],
                                 TemporaryOutputPolygon) then begin
              TemporaryPolygons.Items[IndexA]:=TemporaryOutputPolygon;
              TemporaryPolygons.Delete(IndexB);
              Count:=TemporaryPolygons.Count;
              DoTryAgain:=true;
             end;
             inc(IndexB);
            end;
            inc(IndexA);
           end;
          until not DoTryAgain;
          MergePolygons(TemporaryPolygons);
          break;
{         for PolygonIndex:=0 to TemporaryPolygons.Count-1 do begin
           RemoveCoplanarEdges(TemporaryPolygons.Items[PolygonIndex]);
          end;}
         end;
         OutputPolygons.Add(TemporaryPolygons);
        finally
         TemporaryPolygons.Finalize;
        end;
       end;
      end;
     end;

     NewIndices.Initialize;
     try

      for PolygonIndex:=0 to OutputPolygons.Count-1 do begin
       OutputPolygon:=@OutputPolygons.Items[PolygonIndex];
       NewIndices.Add(OutputPolygon^.Indices.Count);
       NewIndices.Add(OutputPolygon^.Indices);
      end;

      SetIndices(NewIndices);

     finally
      NewIndices.Finalize;
     end;

    finally
     OutputPolygons.Finalize;
    end;

   finally
    PolygonPlanes.Finalize;
   end;

  finally
   InputPolygons.Finalize;
  end;

 finally
  RemoveDuplicateAndUnusedVertices;
 end;

end;

procedure TpvCSGBSP.TMesh.Optimize;
begin
 Canonicalize;
 MergeCoplanarConvexPolygons;
end;

function TpvCSGBSP.TMesh.ToSingleTreeNode(const aSplitSettings:PSplitSettings=nil):TSingleTreeNode;
begin
 result:=TSingleTreeNode.Create(self);
 result.Build(fIndices,aSplitSettings);
end;

function TpvCSGBSP.TMesh.ToDualTree(const aSplitSettings:PSplitSettings=nil):TDualTree;
begin
 result:=TDualTree.Create(self,aSplitSettings);
 result.AddIndices(fIndices);
end;

{ TpvCSGBSP.TNode }

constructor TpvCSGBSP.TSingleTreeNode.Create(const aMesh:TMesh);
begin
 inherited Create;
 fMesh:=aMesh;
 fIndices.Initialize;
 fPointerToIndices:=@fIndices;
 fBack:=nil;
 fFront:=nil;
end;

destructor TpvCSGBSP.TSingleTreeNode.Destroy;
type TJobStack=TDynamicStack<TSingleTreeNode>;
var JobStack:TJobStack;
    Node:TSingleTreeNode;
begin
 fIndices.Finalize;
 if assigned(fFront) or assigned(fBack) then begin
  JobStack.Initialize;
  try
   JobStack.Push(self);
   while JobStack.Pop(Node) do begin
    if assigned(Node.fFront) then begin
     JobStack.Push(Node.fFront);
     Node.fFront:=nil;
    end;
    if assigned(Node.fBack) then begin
     JobStack.Push(Node.fBack);
     Node.fBack:=nil;
    end;
    if Node<>self then begin
     FreeAndNil(Node);
    end;
   end;
  finally
   JobStack.Finalize;
  end;
 end;
 fPointerToIndices:=nil;
 inherited Destroy;
end;

procedure TpvCSGBSP.TSingleTreeNode.SetIndices(const aIndices:TIndexList);
begin
 fIndices.Assign(aIndices);
end;

procedure TpvCSGBSP.TSingleTreeNode.Invert;
type TJobStack=TDynamicStack<TSingleTreeNode>;
var JobStack:TJobStack;
    Node,TempNode:TSingleTreeNode;
    Index,Count,
    CountPolygonVertices,PolygonVertexIndex,
    IndexA,IndexB:TpvSizeInt;
begin
 fMesh.Invert;
 JobStack.Initialize;
 try
  JobStack.Push(self);
  while JobStack.Pop(Node) do begin
   case fMesh.fMode of
    TMesh.TMode.Triangles:begin
     Index:=0;
     Count:=Node.fIndices.Count;
     while (Index+2)<Count do begin
      Node.fIndices.Exchange(Index+0,Index+2);
      inc(Index,3);
     end;
    end;
    else {TMesh.TMode.Polygons:}begin
     Index:=0;
     Count:=Node.fIndices.Count;
     while Index<Count do begin
      CountPolygonVertices:=Node.fIndices.Items[Index];
      inc(Index);
      if CountPolygonVertices>0 then begin
       if (Index+(CountPolygonVertices-1))<Count then begin
        for PolygonVertexIndex:=0 to (CountPolygonVertices shr 1)-1 do begin
         IndexA:=Index+PolygonVertexIndex;
         IndexB:=Index+(CountPolygonVertices-(PolygonVertexIndex+1));
         if IndexA<>IndexB then begin
          Node.fIndices.Exchange(IndexA,IndexB);
         end;
        end;
       end else begin
        Assert(false);
       end;
       inc(Index,CountPolygonVertices);
      end;
     end;
    end;
   end;
   Node.fPlane:=Node.fPlane.Flip;
   TempNode:=Node.fBack;
   Node.fBack:=Node.fFront;
   Node.fFront:=TempNode;
   if assigned(Node.fFront) then begin
    JobStack.Push(Node.fFront);
   end;
   if assigned(Node.fBack) then begin
    JobStack.Push(Node.fBack);
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

procedure TpvCSGBSP.TSingleTreeNode.EvaluateSplitPlane(const aPlane:TPlane;
                                                       out aCountPolygonsSplits:TpvSizeInt;
                                                       out aCountBackPolygons:TpvSizeInt;
                                                       out aCountFrontPolygons:TpvSizeInt);
const TriangleSplitMask=(0 shl 0) or (1 shl 2) or (1 shl 2) or (1 shl 3) or (1 shl 4) or (1 shl 5) or (1 shl 6) or (0 shl 7);
      BackTriangleMask=(1 shl 0) or (2 shl 2) or (2 shl 4) or (1 shl (3 shl 1)) or (2 shl (4 shl 1)) or (1 shl (5 shl 1)) or (1 shl (6 shl 1)) or (0 shl (7 shl 1));
      FrontTriangleMask=(0 shl 0) or (1 shl 2) or (1 shl 4) or (2 shl (3 shl 1)) or (1 shl (4 shl 1)) or (2 shl (5 shl 1)) or (2 shl (6 shl 1)) or (1 shl (7 shl 1));
var Index,Count,CountPolygonVertices,Code:TpvSizeInt;
    Vertices:TVertexList;
begin
 aCountPolygonsSplits:=0;
 aCountBackPolygons:=0;
 aCountFrontPolygons:=0;
 Count:=fIndices.Count;
 if Count>0 then begin
  Vertices:=fMesh.fVertices;
  Index:=0;
  while Index<Count do begin
   case fMesh.fMode of
    TMesh.TMode.Triangles:begin
     CountPolygonVertices:=3;
    end;
    else {TMesh.TMode.Polygons:}begin
     CountPolygonVertices:=fIndices.Items[Index];
     inc(Index);
    end;
   end;
   if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin
    Code:=((ord(aPlane.DistanceTo(Vertices.Items[fIndices.Items[Index+0]].Position)>0.0) and 1) shl 2) or
          ((ord(aPlane.DistanceTo(Vertices.Items[fIndices.Items[Index+1]].Position)>0.0) and 1) shl 1) or
          ((ord(aPlane.DistanceTo(Vertices.Items[fIndices.Items[Index+2]].Position)>0.0) and 1) shl 0);
    inc(aCountPolygonsSplits,(TriangleSplitMask shr Code) and 1);
    inc(aCountBackPolygons,(BackTriangleMask shr (Code shl 1)) and 3);
    inc(aCountFrontPolygons,(FrontTriangleMask shr (Code shl 1)) and 3);
   end;
   inc(Index,CountPolygonVertices);
  end;
 end;
end;

function TpvCSGBSP.TSingleTreeNode.FindSplitPlane(const aIndices:TIndexList;
                                                  const aSplitSettings:PSplitSettings):TPlane;
var Index,Count,TriangleCount,VertexBaseIndex,
    CountPolygonsSplits,CountBackPolygons,CountFrontPolygons,
    CountPolygonVertices,LoopCount:TpvSizeInt;
    Plane:TPlane;
    Score,BestScore:TFloat;
    Vertices:TVertexList;
    SplitSettings:PSplitSettings;
    DoRandomPicking:boolean;
begin
 if assigned(aSplitSettings) then begin
  SplitSettings:=aSplitSettings;
 end else begin
  SplitSettings:=@DefaultSplitSettings;
 end;
 if IsZero(SplitSettings^.SearchBestFactor) or (SplitSettings^.SearchBestFactor<=0.0) then begin
  if aIndices.Count>2 then begin
{  if SplitSettings^.SearchBestFactor<0.0 then begin
    Index:=Random(aPolygonNodes.Count);
    if Index>=aPolygonNodes.Count then begin
     Index:=0;
    end;
   end else begin
    Index:=0;
   end;}
   Index:=0;
   case fMesh.fMode of
    TMesh.TMode.Triangles:begin
     CountPolygonVertices:=3;
    end;
    else {TMesh.TMode.Polygons:}begin
     CountPolygonVertices:=aIndices.Items[Index];
     inc(Index);
    end;
   end;
   Count:=aIndices.Count;
   if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin
    result:=TPlane.Create(fMesh.fVertices.Items[aIndices.Items[Index+0]].Position,
                          fMesh.fVertices.Items[aIndices.Items[Index+1]].Position,
                          fMesh.fVertices.Items[aIndices.Items[Index+2]].Position);
   end;
  end else begin
   result:=TPlane.CreateEmpty;
  end;
 end else begin
  result:=TPlane.CreateEmpty;
  case fMesh.fMode of
   TMesh.TMode.Triangles:begin
    Count:=aIndices.Count;
    TriangleCount:=Count div 3;
    Vertices:=fMesh.fVertices;
    BestScore:=Infinity;
    if SameValue(SplitSettings^.SearchBestFactor,1.0) or (SplitSettings^.SearchBestFactor>=1.0) then begin
     LoopCount:=TriangleCount;
     DoRandomPicking:=false;
    end else begin
     LoopCount:=Min(Max(round(TriangleCount*SplitSettings^.SearchBestFactor),1),TriangleCount);
     DoRandomPicking:=true;
    end;
    for Index:=0 to LoopCount-1 do begin
     if DoRandomPicking then begin
      VertexBaseIndex:=Random(TriangleCount)*3;
     end else begin
      VertexBaseIndex:=(Index mod TriangleCount)*3;
     end;
     Plane:=TPlane.Create(Vertices.Items[aIndices.Items[VertexBaseIndex+0]].Position,
                          Vertices.Items[aIndices.Items[VertexBaseIndex+1]].Position,
                          Vertices.Items[aIndices.Items[VertexBaseIndex+2]].Position);
     EvaluateSplitPlane(Plane,CountPolygonsSplits,CountBackPolygons,CountFrontPolygons);
     Score:=(CountPolygonsSplits*SplitSettings^.PolygonSplitCost)+
            (abs(CountBackPolygons-CountFrontPolygons)*SplitSettings^.PolygonImbalanceCost);
     if (Index=0) or (BestScore>Score) then begin
      BestScore:=Score;
      result:=Plane;
     end;
    end;
   end;
   else {TMesh.TMode.Polygons:}begin
    Count:=aIndices.Count;
    Vertices:=fMesh.fVertices;
    BestScore:=Infinity;
    Index:=0;
    while Index<Count do begin
     case fMesh.fMode of
      TMesh.TMode.Triangles:begin
       CountPolygonVertices:=3;
      end;
      else {TMesh.TMode.Polygons:}begin
       CountPolygonVertices:=aIndices.Items[Index];
       inc(Index);
      end;
     end;
     if (CountPolygonVertices>2) and ((Index+(CountPolygonVertices-1))<Count) then begin
      VertexBaseIndex:=Index;
      Plane:=TPlane.Create(Vertices.Items[aIndices.Items[VertexBaseIndex+0]].Position,
                           Vertices.Items[aIndices.Items[VertexBaseIndex+1]].Position,
                           Vertices.Items[aIndices.Items[VertexBaseIndex+2]].Position);
      EvaluateSplitPlane(Plane,CountPolygonsSplits,CountBackPolygons,CountFrontPolygons);
      Score:=(CountPolygonsSplits*SplitSettings^.PolygonSplitCost)+
             (abs(CountBackPolygons-CountFrontPolygons)*SplitSettings^.PolygonImbalanceCost);
      if (Index=0) or (BestScore>Score) then begin
       BestScore:=Score;
       result:=Plane;
      end;
     end;
     inc(Index,CountPolygonVertices);
    end;
   end;
  end;
 end;
end;

procedure TpvCSGBSP.TSingleTreeNode.Build(const aIndices:TIndexList;
                                          const aSplitSettings:PSplitSettings=nil);
type TJobStackItem=record
      Node:TSingleTreeNode;
      Indices:TIndexList;
     end;
     TJobStack=TDynamicStack<TJobStackItem>;
var JobStack:TJobStack;
    JobStackItem,NewJobStackItem,FrontJobStackItem,BackJobStackItem:TJobStackItem;
    Index,CountVertexIndices:TpvSizeInt;
begin
 JobStack.Initialize;
 try
  NewJobStackItem.Node:=self;
  NewJobStackItem.Indices:=aIndices;
  JobStack.Push(NewJobStackItem);
  while JobStack.Pop(JobStackItem) do begin
   try
    CountVertexIndices:=JobStackItem.Indices.Count;
    if ((fMesh.fMode=TMesh.TMode.Triangles) and (CountVertexIndices>2)) or
       ((fMesh.fMode in [TMesh.TMode.Polygons]) and (CountVertexIndices>1)) then begin
     FrontJobStackItem.Indices.Initialize;
     BackJobStackItem.Indices.Initialize;
     if not JobStackItem.Node.fPlane.OK then begin
      JobStackItem.Node.fPlane:=FindSplitPlane(JobStackItem.Indices,aSplitSettings);
     end;
     case fMesh.fMode of
      TMesh.TMode.Triangles:begin
       JobStackItem.Node.fPlane.SplitTriangles(fMesh.fVertices,
                                               JobStackItem.Indices,
                                               @JobStackItem.Node.fIndices,
                                               @JobStackItem.Node.fIndices,
                                               @BackJobStackItem.Indices,
                                               @FrontJobStackItem.Indices);
      end;
      else {TMesh.TMode.Polygons:}begin
       JobStackItem.Node.fPlane.SplitPolygons(fMesh.fVertices,
                                              JobStackItem.Indices,
                                              @JobStackItem.Node.fIndices,
                                              @JobStackItem.Node.fIndices,
                                              @BackJobStackItem.Indices,
                                              @FrontJobStackItem.Indices);
      end;
     end;
     if BackJobStackItem.Indices.Count>0 then begin
      if not assigned(JobStackItem.Node.fBack) then begin
       JobStackItem.Node.fBack:=TSingleTreeNode.Create(fMesh);
      end;
      BackJobStackItem.Node:=JobStackItem.Node.fBack;
      JobStack.Push(BackJobStackItem);
     end;
     if FrontJobStackItem.Indices.Count>0 then begin
      if not assigned(JobStackItem.Node.fFront) then begin
       JobStackItem.Node.fFront:=TSingleTreeNode.Create(fMesh);
      end;
      FrontJobStackItem.Node:=JobStackItem.Node.fFront;
      JobStack.Push(FrontJobStackItem);
     end;
    end;
   finally
    JobStackItem.Indices.Finalize;
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

function TpvCSGBSP.TSingleTreeNode.ClipPolygons(var aVertices:TVertexList;const aIndices:TIndexList):TIndexList;
type TJobStackItem=record
      Node:TSingleTreeNode;
      Indices:TIndexList;
     end;
     TJobStack=TDynamicStack<TJobStackItem>;
var JobStack:TJobStack;
    JobStackItem,NewJobStackItem,FrontJobStackItem,BackJobStackItem:TJobStackItem;
    Index,Count:TpvSizeInt;
    BackIndices:PIndexList;
begin
 result.Initialize;
 try
  JobStack.Initialize;
  try
   NewJobStackItem.Node:=self;
   NewJobStackItem.Indices.Assign(aIndices);
   JobStack.Push(NewJobStackItem);
   while JobStack.Pop(JobStackItem) do begin
    try
     if JobStackItem.Node.fPlane.OK then begin
      FrontJobStackItem.Indices.Initialize;
      try
       if assigned(JobStackItem.Node.fBack) then begin
        BackJobStackItem.Indices.Initialize;
        BackIndices:=@BackJobStackItem.Indices;
       end else begin
        BackIndices:=nil;
       end;
       try
        case fMesh.fMode of
         TMesh.TMode.Triangles:begin
          JobStackItem.Node.fPlane.SplitTriangles(aVertices,
                                                  JobStackItem.Indices,
                                                  BackIndices,
                                                  @FrontJobStackItem.Indices,
                                                  BackIndices,
                                                  @FrontJobStackItem.Indices);
         end;
         else {TMesh.TMode.Polygons:}begin
          JobStackItem.Node.fPlane.SplitPolygons(aVertices,
                                                 JobStackItem.Indices,
                                                 BackIndices,
                                                 @FrontJobStackItem.Indices,
                                                 BackIndices,
                                                 @FrontJobStackItem.Indices);
         end;
        end;
        if assigned(JobStackItem.Node.fBack) then begin
         BackJobStackItem.Node:=JobStackItem.Node.fBack;
         JobStack.Push(BackJobStackItem);
        end;
        if assigned(JobStackItem.Node.fFront) then begin
         FrontJobStackItem.Node:=JobStackItem.Node.fFront;
         JobStack.Push(FrontJobStackItem);
        end else if FrontJobStackItem.Indices.Count>0 then begin
         result.Add(FrontJobStackItem.Indices);
        end;
       finally
        BackJobStackItem.Indices.Finalize;
       end;
      finally
       FrontJobStackItem.Indices.Finalize;
      end;
     end else if JobStackItem.Indices.Count>0 then begin
      result.Add(JobStackItem.Indices);
     end;
    finally
     JobStackItem.Indices.Finalize;
    end;
   end;
  finally
   JobStack.Finalize;
  end;
 except
  result.Finalize;
  raise;
 end;
end;

procedure TpvCSGBSP.TSingleTreeNode.ClipTo(const aNode:TSingleTreeNode);
type TJobStack=TDynamicStack<TSingleTreeNode>;
var JobStack:TJobStack;
    Node:TSingleTreeNode;
begin
 JobStack.Initialize;
 try
  JobStack.Push(self);
  while JobStack.Pop(Node) do begin
   Node.SetIndices(aNode.ClipPolygons(Node.fMesh.fVertices,Node.fIndices));
   if assigned(Node.fFront) then begin
    JobStack.Push(Node.fFront);
   end;
   if assigned(Node.fBack) then begin
    JobStack.Push(Node.fBack);
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

procedure TpvCSGBSP.TSingleTreeNode.Merge(const aNode:TSingleTreeNode;
                                          const aSplitSettings:PSplitSettings=nil);
var Index,Offset,Count,CountPolygonVertices:TpvSizeInt;
    OtherMesh:TMesh;
begin
 Offset:=fMesh.fVertices.Count;
 OtherMesh:=aNode.ToMesh;
 try
  OtherMesh.SetMode(fMesh.fMode);
  fMesh.fVertices.Add(OtherMesh.fVertices);
  case fMesh.fMode of
   TMesh.TMode.Triangles:begin
    for Index:=0 to OtherMesh.fIndices.Count-1 do begin
     OtherMesh.fIndices.Items[Index]:=OtherMesh.fIndices.Items[Index]+Offset;
    end;
   end;
   else {TMesh.TMode.Polygons:}begin
    Index:=0;
    Count:=OtherMesh.fIndices.Count;
    while Index<Count do begin
     CountPolygonVertices:=OtherMesh.fIndices.Items[Index];
     inc(Index);
     while (CountPolygonVertices>0) and (Index<Count) do begin
      OtherMesh.fIndices.Items[Index]:=OtherMesh.fIndices.Items[Index]+Offset;
      inc(Index);
      dec(CountPolygonVertices);
     end;
    end;
   end;
  end;
  Build(OtherMesh.fIndices,aSplitSettings);
 finally
  FreeAndNil(OtherMesh);
 end;
end;

function TpvCSGBSP.TSingleTreeNode.ToMesh:TMesh;
type TJobStack=TDynamicStack<TSingleTreeNode>;
var JobStack:TJobStack;
    Node:TSingleTreeNode;
begin
 result:=TMesh.Create(fMesh.fMode);
 try
  result.SetVertices(fMesh.fVertices);
  JobStack.Initialize;
  try
   JobStack.Push(self);
   while JobStack.Pop(Node) do begin
    result.fIndices.Add(Node.fIndices);
    if assigned(Node.fFront) then begin
     JobStack.Push(Node.fFront);
    end;
    if assigned(Node.fBack) then begin
     JobStack.Push(Node.fBack);
    end;
   end;
  finally
   JobStack.Finalize;
  end;
 finally
  result.RemoveDuplicateAndUnusedVertices;
 end;
end;

{ TpvCSGBSP.TTree.TPolygon }

procedure TpvCSGBSP.TDualTree.TPolygon.Invert;
var IndexA,IndexB:TpvSizeInt;
begin
 if Indices.Count>0 then begin
  for IndexA:=0 to (Indices.Count shr 1)-1 do begin
   IndexB:=(Indices.Count-(IndexA+1));
   if IndexA<>IndexB then begin
    Indices.Exchange(IndexA,IndexB);
   end;
  end;
 end;
end;

{ TpvCSGBSP.TTree.TPolygonNode }

constructor TpvCSGBSP.TDualTree.TPolygonNode.Create(const aTree:TDualTree;const aParent:TPolygonNode);
begin
 inherited Create;
 fTree:=aTree;
 if assigned(fTree.fLastPolygonNode) then begin
  fAllPrevious:=fTree.fLastPolygonNode;
  fAllPrevious.fAllNext:=self;
 end else begin
  fTree.fFirstPolygonNode:=self;
  fAllPrevious:=nil;
 end;
 fTree.fLastPolygonNode:=self;
 fAllNext:=nil;
 fParent:=aParent;
 if assigned(fParent) then begin
  if assigned(fParent.fLastChild) then begin
   fParentPrevious:=fParent.fLastChild;
   fParentPrevious.fParentNext:=self;
  end else begin
   fParent.fFirstChild:=self;
   fParentPrevious:=nil;
  end;
  fParent.fLastChild:=self;
 end;
 fRemoved:=false;
 fPolygon.Indices.Initialize;
end;

destructor TpvCSGBSP.TDualTree.TPolygonNode.Destroy;
begin
 fPolygon.Indices.Finalize;
 RemoveFromParent;
 if assigned(fAllPrevious) then begin
  fAllPrevious.fAllNext:=fAllNext;
 end else if fTree.fFirstPolygonNode=self then begin
  fTree.fFirstPolygonNode:=fAllNext;
 end;
 if assigned(fAllNext) then begin
  fAllNext.fAllPrevious:=fAllPrevious;
 end else if fTree.fLastPolygonNode=self then begin
  fTree.fLastPolygonNode:=fAllPrevious;
 end;
 fAllPrevious:=nil;
 fAllNext:=nil;
 inherited Destroy;
end;

procedure TpvCSGBSP.TDualTree.TPolygonNode.RemoveFromParent;
begin
 if assigned(fParent) then begin
  if assigned(fParentPrevious) then begin
   fParentPrevious.fParentNext:=fParentNext;
  end else if fParent.fFirstChild=self then begin
   fParent.fFirstChild:=fParentNext;
  end;
  if assigned(fParentNext) then begin
   fParentNext.fParentPrevious:=fParentPrevious;
  end else if fParent.fLastChild=self then begin
   fParent.fLastChild:=fParentPrevious;
  end;
  fParent:=nil;
 end;
 fParentPrevious:=nil;
 fParentNext:=nil;
end;

function TpvCSGBSP.TDualTree.TPolygonNode.AddPolygon(const aPolygon:TPolygon):TPolygonNode;
begin
 result:=TPolygonNode.Create(fTree,self);
 result.fPolygon:=aPolygon;
end;

function TpvCSGBSP.TDualTree.TPolygonNode.AddPolygonIndices(const aIndices:TIndexList):TDualTree.TPolygonNode;
begin
 result:=TPolygonNode.Create(fTree,self);
 result.fPolygon.Indices.Assign(aIndices);
end;

procedure TpvCSGBSP.TDualTree.TPolygonNode.Remove;
var Index:TpvSizeInt;
    PolygonNode:TPolygonNode;
begin
 if not fRemoved then begin
  fRemoved:=true;
  PolygonNode:=self;
  while assigned(PolygonNode) and
        (PolygonNode.fPolygon.Indices.Count>0) do begin
   PolygonNode.fPolygon.Indices.Clear;
   PolygonNode:=PolygonNode.fParent;
  end;
  RemoveFromParent;
 end;
end;

procedure TpvCSGBSP.TDualTree.TPolygonNode.Invert;
type TJobQueue=TDynamicQueue<TPolygonNode>;
var Index:TpvSizeInt;
    JobQueue:TJobQueue;
    PolygonNode:TPolygonNode;
begin
 JobQueue.Initialize;
 try
  JobQueue.Enqueue(self);
  while JobQueue.Dequeue(PolygonNode) do begin
   if not PolygonNode.fRemoved then begin
    PolygonNode.fPolygon.Invert;
    PolygonNode:=PolygonNode.fFirstChild;
    while assigned(PolygonNode) do begin
     if not PolygonNode.fRemoved then begin
      JobQueue.Enqueue(PolygonNode);
     end;
     PolygonNode:=PolygonNode.fParentNext;
    end;
   end;
  end;
 finally
  JobQueue.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.TPolygonNode.DrySplitByPlane(const aPlane:TPlane;var aCountSplits,aCoplanarBackList,aCoplanarFrontList,aBackList,aFrontList:TpvSizeInt);
const Coplanar=0;
      Front=1;
      Back=2;
      Spanning=3;
      EpsilonSignToOrientation:array[0..3] of TpvInt32=(Back,Coplanar,Front,Spanning);
type TJobQueue=TDynamicQueue<TPolygonNode>;
var Index,OtherIndex,Count,CountPolygonVertices,
    IndexA,IndexB,
    PolygonOrientation,
    VertexOrientation,
    VertexOrientationA,
    VertexOrientationB:TpvSizeInt;
    JobQueue:TJobQueue;
    PolygonNode:TPolygonNode;
    Polygon:PPolygon;
    VertexOrientations:array of TpvSizeInt;
    VectorDistance:TpvDouble;
    BackVertexIndices,FrontVertexIndices:TIndexList;
    VertexIndex:TIndex;
    VertexA,VertexB:PVertex;
    Vertices:PVertexList;
    PolygonAABB:TAABB;
    PolygonSphereRadius,
    PolygonSphereDistance:TFloat;
begin
 VertexOrientations:=nil;
 try
  BackVertexIndices.Initialize;
  try
   FrontVertexIndices.Initialize;
   try
    Vertices:=@fTree.fMesh.fVertices;
    JobQueue.Initialize;
    try
     JobQueue.Enqueue(self);
     while JobQueue.Dequeue(PolygonNode) do begin
      if not PolygonNode.fRemoved then begin
       if assigned(PolygonNode.fFirstChild) then begin
        PolygonNode:=PolygonNode.fFirstChild;
        while assigned(PolygonNode) do begin
         if not PolygonNode.fRemoved then begin
          JobQueue.Enqueue(PolygonNode);
         end;
         PolygonNode:=PolygonNode.fParentNext;
        end;
       end else begin
        Polygon:=@PolygonNode.fPolygon;
        CountPolygonVertices:=Polygon^.Indices.Count;
        if CountPolygonVertices>2 then begin
         VertexA:=@Vertices^.Items[Polygon^.Indices.Items[0]];
         PolygonAABB.Min:=VertexA^.Position;
         PolygonAABB.Max:=VertexA^.Position;
         for IndexA:=1 to CountPolygonVertices-1 do begin
          PolygonAABB:=PolygonAABB.Combine(Vertices^.Items[Polygon^.Indices.Items[IndexA]].Position);
         end;
         PolygonSphereRadius:=((PolygonAABB.Max-PolygonAABB.Min)*0.5).Length+Epsilon;
         PolygonSphereDistance:=aPlane.DistanceTo((PolygonAABB.Min+PolygonAABB.Max)*0.5);
         if PolygonSphereDistance<-PolygonSphereRadius then begin
          inc(aBackList);
         end else if PolygonSphereDistance>PolygonSphereRadius then begin
          inc(aFrontList);
         end else begin
          PolygonOrientation:=0;
          if length(VertexOrientations)<CountPolygonVertices then begin
           SetLength(VertexOrientations,(CountPolygonVertices*3) shr 1);
          end;
          for IndexA:=0 to CountPolygonVertices-1 do begin
           VertexOrientation:=EpsilonSignToOrientation[(TpvCSGBSP.EpsilonSign(aPlane.DistanceTo(Vertices^.Items[Polygon^.Indices.Items[IndexA]].Position))+1) and 3];
           PolygonOrientation:=PolygonOrientation or VertexOrientation;
           VertexOrientations[IndexA]:=VertexOrientation;
          end;
          case PolygonOrientation of
           Coplanar:begin
            if aPlane.Normal.Dot(TPlane.Create(Vertices^.Items[Polygon^.Indices.Items[0]].Position,
                                               Vertices^.Items[Polygon^.Indices.Items[1]].Position,
                                               Vertices^.Items[Polygon^.Indices.Items[2]].Position).Normal)<0.0 then begin
             inc(aCoplanarBackList);
            end else begin
             inc(aCoplanarFrontList);
            end;
           end;
           Front:begin
            inc(aFrontList);
           end;
           Back:begin
            inc(aBackList);
           end;
           else {Spanning:}begin
            inc(aCountSplits);
            BackVertexIndices.Count:=0;
            FrontVertexIndices.Count:=0;
            for IndexA:=0 to CountPolygonVertices-1 do begin
             IndexB:=IndexA+1;
             if IndexB>=CountPolygonVertices then begin
              IndexB:=0;
             end;
             VertexIndex:=Polygon^.Indices.Items[IndexA];
             VertexA:=@Vertices^.Items[VertexIndex];
             VertexOrientationA:=VertexOrientations[IndexA];
             VertexOrientationB:=VertexOrientations[IndexB];
             if VertexOrientationA<>Front then begin
              BackVertexIndices.Add(VertexIndex);
             end;
             if VertexOrientationA<>Back then begin
              FrontVertexIndices.Add(VertexIndex);
             end;
             if (VertexOrientationA or VertexOrientationB)=Spanning then begin
              VertexB:=@Vertices^.Items[Polygon^.Indices.Items[IndexB]];
              VertexIndex:=Vertices^.Add(VertexA^.Lerp(VertexB^,-(aPlane.DistanceTo(VertexA^.Position)/aPlane.Normal.Dot(VertexB^.Position-VertexA^.Position))));
              BackVertexIndices.Add(VertexIndex);
              FrontVertexIndices.Add(VertexIndex);
             end;
            end;
            if BackVertexIndices.Count>2 then begin
             fTree.fMesh.RemoveNearDuplicateIndices(BackVertexIndices);
             if BackVertexIndices.Count>2 then begin
              inc(aBackList);
             end;
            end;
            if FrontVertexIndices.Count>2 then begin
             fTree.fMesh.RemoveNearDuplicateIndices(FrontVertexIndices);
             if FrontVertexIndices.Count>2 then begin
              inc(aFrontList);
             end;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    finally
     JobQueue.Finalize;
    end;
   finally
    FrontVertexIndices.Finalize;
   end;
  finally
   BackVertexIndices.Finalize;
  end;
 finally
  VertexOrientations:=nil;
 end;
end;

procedure TpvCSGBSP.TDualTree.TPolygonNode.SplitByPlane(const aPlane:TPlane;var aCoplanarBackList,aCoplanarFrontList,aBackList,aFrontList:TPolygonNodeList);
const Coplanar=0;
      Front=1;
      Back=2;
      Spanning=3;
      EpsilonSignToOrientation:array[0..3] of TpvInt32=(Back,Coplanar,Front,Spanning);
type TJobQueue=TDynamicQueue<TPolygonNode>;
var Index,OtherIndex,Count,CountPolygonVertices,
    IndexA,IndexB,
    PolygonOrientation,
    VertexOrientation,
    VertexOrientationA,
    VertexOrientationB:TpvSizeInt;
    JobQueue:TJobQueue;
    PolygonNode:TPolygonNode;
    Polygon:PPolygon;
    VertexOrientations:array of TpvSizeInt;
    VectorDistance:TpvDouble;
    BackVertexIndices,FrontVertexIndices:TIndexList;
    VertexIndex:TIndex;
    VertexA,VertexB:PVertex;
    Vertices:PVertexList;
    PolygonAABB:TAABB;
    PolygonSphereRadius,
    PolygonSphereDistance:TFloat;
begin
 VertexOrientations:=nil;
 try
  BackVertexIndices.Initialize;
  try
   FrontVertexIndices.Initialize;
   try
    Vertices:=@fTree.fMesh.fVertices;
    JobQueue.Initialize;
    try
     JobQueue.Enqueue(self);
     while JobQueue.Dequeue(PolygonNode) do begin
      if not PolygonNode.fRemoved then begin
       if assigned(PolygonNode.fFirstChild) then begin
        PolygonNode:=PolygonNode.fFirstChild;
        while assigned(PolygonNode) do begin
         if not PolygonNode.fRemoved then begin
          JobQueue.Enqueue(PolygonNode);
         end;
         PolygonNode:=PolygonNode.fParentNext;
        end;
       end else begin
        Polygon:=@PolygonNode.fPolygon;
        CountPolygonVertices:=Polygon^.Indices.Count;
        if CountPolygonVertices>2 then begin
         VertexA:=@Vertices^.Items[Polygon^.Indices.Items[0]];
         PolygonAABB.Min:=VertexA^.Position;
         PolygonAABB.Max:=VertexA^.Position;
         for IndexA:=1 to CountPolygonVertices-1 do begin
          PolygonAABB:=PolygonAABB.Combine(Vertices^.Items[Polygon^.Indices.Items[IndexA]].Position);
         end;
         PolygonSphereRadius:=((PolygonAABB.Max-PolygonAABB.Min)*0.5).Length+Epsilon;
         PolygonSphereDistance:=aPlane.DistanceTo((PolygonAABB.Min+PolygonAABB.Max)*0.5);
         if PolygonSphereDistance<-PolygonSphereRadius then begin
          aBackList.Add(PolygonNode);
         end else if PolygonSphereDistance>PolygonSphereRadius then begin
          aFrontList.Add(PolygonNode);
         end else begin
          PolygonOrientation:=0;
          if length(VertexOrientations)<CountPolygonVertices then begin
           SetLength(VertexOrientations,(CountPolygonVertices*3) shr 1);
          end;
          for IndexA:=0 to CountPolygonVertices-1 do begin
           VertexOrientation:=EpsilonSignToOrientation[(TpvCSGBSP.EpsilonSign(aPlane.DistanceTo(Vertices^.Items[Polygon^.Indices.Items[IndexA]].Position))+1) and 3];
           PolygonOrientation:=PolygonOrientation or VertexOrientation;
           VertexOrientations[IndexA]:=VertexOrientation;
          end;
          case PolygonOrientation of
           Coplanar:begin
            if aPlane.Normal.Dot(TPlane.Create(Vertices^.Items[Polygon^.Indices.Items[0]].Position,
                                               Vertices^.Items[Polygon^.Indices.Items[1]].Position,
                                               Vertices^.Items[Polygon^.Indices.Items[2]].Position).Normal)<0.0 then begin
             aCoplanarBackList.Add(PolygonNode);
            end else begin
             aCoplanarFrontList.Add(PolygonNode);
            end;
           end;
           Front:begin
            aFrontList.Add(PolygonNode);
           end;
           Back:begin
            aBackList.Add(PolygonNode);
           end;
           else {Spanning:}begin
            BackVertexIndices.Count:=0;
            FrontVertexIndices.Count:=0;
            for IndexA:=0 to CountPolygonVertices-1 do begin
             IndexB:=IndexA+1;
             if IndexB>=CountPolygonVertices then begin
              IndexB:=0;
             end;
             VertexIndex:=Polygon^.Indices.Items[IndexA];
             VertexA:=@Vertices^.Items[VertexIndex];
             VertexOrientationA:=VertexOrientations[IndexA];
             VertexOrientationB:=VertexOrientations[IndexB];
             if VertexOrientationA<>Front then begin
              BackVertexIndices.Add(VertexIndex);
             end;
             if VertexOrientationA<>Back then begin
              FrontVertexIndices.Add(VertexIndex);
             end;
             if (VertexOrientationA or VertexOrientationB)=Spanning then begin
              VertexB:=@Vertices^.Items[Polygon^.Indices.Items[IndexB]];
              VertexIndex:=Vertices^.Add(VertexA^.Lerp(VertexB^,-(aPlane.DistanceTo(VertexA^.Position)/aPlane.Normal.Dot(VertexB^.Position-VertexA^.Position))));
              BackVertexIndices.Add(VertexIndex);
              FrontVertexIndices.Add(VertexIndex);
             end;
            end;
            if BackVertexIndices.Count>2 then begin
             fTree.fMesh.RemoveNearDuplicateIndices(BackVertexIndices);
             if BackVertexIndices.Count>2 then begin
              aBackList.Add(PolygonNode.AddPolygonIndices(BackVertexIndices));
             end;
            end;
            if FrontVertexIndices.Count>2 then begin
             fTree.fMesh.RemoveNearDuplicateIndices(FrontVertexIndices);
             if FrontVertexIndices.Count>2 then begin
              aFrontList.Add(PolygonNode.AddPolygonIndices(FrontVertexIndices));
             end;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    finally
     JobQueue.Finalize;
    end;
   finally
    FrontVertexIndices.Finalize;
   end;
  finally
   BackVertexIndices.Finalize;
  end;
 finally
  VertexOrientations:=nil;
 end;
end;

{ TpvCSGBSP.TTree.TNode }

constructor TpvCSGBSP.TDualTree.TNode.Create(const aTree:TDualTree);
begin
 inherited Create;
 fTree:=aTree;
 fPolygonNodes.Initialize;
 fBack:=nil;
 fFront:=nil;
end;

destructor TpvCSGBSP.TDualTree.TNode.Destroy;
type TJobStack=TDynamicStack<TDualTree.TNode>;
var JobStack:TJobStack;
    Node:TDualTree.TNode;
begin
 fPolygonNodes.Finalize;
 if assigned(fFront) or assigned(fBack) then begin
  JobStack.Initialize;
  try
   JobStack.Push(self);
   while JobStack.Pop(Node) do begin
    if assigned(Node.fFront) then begin
     JobStack.Push(Node.fFront);
     Node.fFront:=nil;
    end;
    if assigned(Node.fBack) then begin
     JobStack.Push(Node.fBack);
     Node.fBack:=nil;
    end;
    if Node<>self then begin
     FreeAndNil(Node);
    end;
   end;
  finally
   JobStack.Finalize;
  end;
 end;
 inherited Destroy;
end;

procedure TpvCSGBSP.TDualTree.TNode.Invert;
type TJobStack=TDynamicStack<TDualTree.TNode>;
var JobStack:TJobStack;
    Node,TempNode:TDualTree.TNode;
begin
 JobStack.Initialize;
 try
  JobStack.Push(self);
  while JobStack.Pop(Node) do begin
   Node.fPlane:=Node.fPlane.Flip;
   TempNode:=Node.fBack;
   Node.fBack:=Node.fFront;
   Node.fFront:=TempNode;
   if assigned(Node.fFront) then begin
    JobStack.Push(Node.fFront);
   end;
   if assigned(Node.fBack) then begin
    JobStack.Push(Node.fBack);
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.TNode.ClipPolygons(const aPolygonNodes:TPolygonNodeList;const aAlsoRemoveCoplanarFront:boolean=false);
type TJobStackItem=record
      Node:TDualTree.TNode;
      PolygonNodes:TPolygonNodeList;
     end;
     TJobStack=TDynamicStack<TJobStackItem>;
var JobStack:TJobStack;
    JobStackItem,NewJobStackItem,FrontJobStackItem,BackJobStackItem:TJobStackItem;
    Index,Count:TpvSizeInt;
    CoplanarFrontNodes:PPolygonNodeList;
    PolygonNode:TPolygonNode;
    BackIndices:PIndexList;
begin
 JobStack.Initialize;
 try
  NewJobStackItem.Node:=self;
  NewJobStackItem.PolygonNodes:=aPolygonNodes;
  JobStack.Push(NewJobStackItem);
  while JobStack.Pop(JobStackItem) do begin
   try
    if JobStackItem.Node.fPlane.OK then begin
     BackJobStackItem.PolygonNodes.Initialize;
     try
      FrontJobStackItem.PolygonNodes.Initialize;
      try
       if aAlsoRemoveCoplanarFront then begin
        CoplanarFrontNodes:=@BackJobStackItem.PolygonNodes;
       end else begin
        CoplanarFrontNodes:=@FrontJobStackItem.PolygonNodes;
       end;
       for Index:=0 to JobStackItem.PolygonNodes.Count-1 do begin
        PolygonNode:=JobStackItem.PolygonNodes.Items[Index];
        if not PolygonNode.fRemoved then begin
         PolygonNode.SplitByPlane(JobStackItem.Node.Plane,
                                  BackJobStackItem.PolygonNodes,
                                  CoplanarFrontNodes^,
                                  BackJobStackItem.PolygonNodes,
                                  FrontJobStackItem.PolygonNodes);
        end;
       end;
       if assigned(JobStackItem.Node.fBack) and (BackJobStackItem.PolygonNodes.Count>0) then begin
        BackJobStackItem.Node:=JobStackItem.Node.fBack;
        JobStack.Push(BackJobStackItem);
       end else begin
        for Index:=0 to BackJobStackItem.PolygonNodes.Count-1 do begin
         BackJobStackItem.PolygonNodes.Items[Index].Remove;
        end;
       end;
       if assigned(JobStackItem.Node.fFront) and (FrontJobStackItem.PolygonNodes.Count>0) then begin
        FrontJobStackItem.Node:=JobStackItem.Node.fFront;
        JobStack.Push(FrontJobStackItem);
       end;
      finally
       FrontJobStackItem.PolygonNodes.Finalize;
      end;
     finally
      BackJobStackItem.PolygonNodes.Finalize;
     end;
    end;
   finally
    JobStackItem.PolygonNodes.Finalize;
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.TNode.ClipTo(const aTree:TDualTree;const aAlsoRemoveCoplanarFront:boolean=false);
type TJobStack=TDynamicStack<TDualTree.TNode>;
var JobStack:TJobStack;
    Node:TDualTree.TNode;
begin
 JobStack.Initialize;
 try
  JobStack.Push(self);
  while JobStack.Pop(Node) do begin
   aTree.fRootNode.ClipPolygons(Node.fPolygonNodes,aAlsoRemoveCoplanarFront);
   if assigned(Node.fFront) then begin
    JobStack.Push(Node.fFront);
   end;
   if assigned(Node.fBack) then begin
    JobStack.Push(Node.fBack);
   end;
  end;
 finally
  JobStack.Finalize;
 end;
end;

function TpvCSGBSP.TDualTree.TNode.FindSplitPlane(const aPolygonNodes:TPolygonNodeList):TPlane;
var Index,OtherIndex,Count,
    CountPolygonsSplits,
    CountBackPolygons,CountFrontPolygons,CountSum,
    BestCountBackPolygons,BestCountFrontPolygons,BestCountSum:TpvSizeInt;
    Polygon:PPolygon;
    Score,BestScore:TFloat;
    Plane:TPlane;
    SplitSettings:PSplitSettings;
    NoScoring,DoRandomPicking:boolean;
    Vertices:PVertexList;
begin
 SplitSettings:=@fTree.fSplitSettings;
 Vertices:=@fTree.fMesh.fVertices;
 if IsZero(SplitSettings^.SearchBestFactor) or (SplitSettings^.SearchBestFactor<=0.0) then begin
  if aPolygonNodes.Count>0 then begin
   if SplitSettings^.SearchBestFactor<0.0 then begin
    Index:=Random(aPolygonNodes.Count);
    if Index>=aPolygonNodes.Count then begin
     Index:=0;
    end;
   end else begin
    Index:=0;
   end;
   Polygon:=@aPolygonNodes.Items[Index].fPolygon;
   result:=TPlane.Create(Vertices^.Items[Polygon^.Indices.Items[0]].Position,
                         Vertices^.Items[Polygon^.Indices.Items[1]].Position,
                         Vertices^.Items[Polygon^.Indices.Items[2]].Position);
  end else begin
   result:=TPlane.CreateEmpty;
  end;
  exit;
{ Count:=1;
  DoRandomPicking:=false;}
 end else if SameValue(SplitSettings^.SearchBestFactor,1.0) or (SplitSettings^.SearchBestFactor>=1.0) then begin
  Count:=aPolygonNodes.Count;
  DoRandomPicking:=false;
 end else begin
  Count:=Min(Max(round(aPolygonNodes.Count*SplitSettings^.SearchBestFactor),1),aPolygonNodes.Count);
  DoRandomPicking:=true;
 end;
 result:=TPlane.CreateEmpty;
 BestScore:=Infinity;
 BestCountBackPolygons:=High(TpvSizeInt);
 BestCountFrontPolygons:=High(TpvSizeInt);
 BestCountSum:=High(TpvSizeInt);
 NoScoring:=IsZero(SplitSettings^.PolygonSplitCost) and IsZero(SplitSettings^.PolygonImbalanceCost);
 for Index:=0 to Count-1 do begin
  if DoRandomPicking then begin
   OtherIndex:=Random(aPolygonNodes.Count);
   if OtherIndex>=aPolygonNodes.Count then begin
    OtherIndex:=0;
   end;
  end else begin
   OtherIndex:=Index;
  end;
  Polygon:=@aPolygonNodes.Items[OtherIndex].fPolygon;
  Plane:=TPlane.Create(Vertices^.Items[Polygon^.Indices.Items[0]].Position,
                       Vertices^.Items[Polygon^.Indices.Items[1]].Position,
                       Vertices^.Items[Polygon^.Indices.Items[2]].Position);
  CountPolygonsSplits:=0;
  CountBackPolygons:=0;
  CountFrontPolygons:=0;
  for OtherIndex:=0 to aPolygonNodes.Count-1 do begin
   aPolygonNodes.Items[OtherIndex].DrySplitByPlane(Plane,CountPolygonsSplits,CountBackPolygons,CountFrontPolygons,CountBackPolygons,CountFrontPolygons);
  end;
  if NoScoring then begin
   CountSum:=CountBackPolygons+CountFrontPolygons;
   if (Index=0) or
      ((BestCountSum>CountSum) or
       ((BestCountSum=CountSum) and
        (abs(BestCountBackPolygons-BestCountFrontPolygons)>abs(CountBackPolygons-CountFrontPolygons)))) then begin
    BestCountBackPolygons:=CountBackPolygons;
    BestCountFrontPolygons:=CountFrontPolygons;
    BestCountSum:=CountSum;
    result:=Plane;
   end;
  end else begin
   Score:=(CountPolygonsSplits*SplitSettings^.PolygonSplitCost)+
          (abs(CountBackPolygons-CountFrontPolygons)*SplitSettings^.PolygonImbalanceCost);
   if (Index=0) or (BestScore>Score) then begin
    BestScore:=Score;
    result:=Plane;
   end;
  end;
 end;
end;

procedure TpvCSGBSP.TDualTree.TNode.AddPolygonNodes(const aPolygonNodes:TPolygonNodeList);
type TJobStackItem=record
      Node:TDualTree.TNode;
      PolygonNodes:TPolygonNodeList;
     end;
     TJobStack=TDynamicStack<TJobStackItem>;
var Index:TpvSizeInt;
    JobStack:TJobStack;
    JobStackItem,NewJobStackItem,BackJobStackItem,FrontJobStackItem:TJobStackItem;
begin
 JobStack.Initialize;
 try
  BackJobStackItem.PolygonNodes.Initialize;
  try
   FrontJobStackItem.PolygonNodes.Initialize;
   try
    NewJobStackItem.Node:=self;
    NewJobStackItem.PolygonNodes:=aPolygonNodes;
    JobStack.Push(NewJobStackItem);
    while JobStack.Pop(JobStackItem) do begin
     if JobStackItem.PolygonNodes.Count>0 then begin
      //write(#13,JobStackItem.PolygonNodes.Count:10);
      if not JobStackItem.Node.fPlane.OK then begin
       JobStackItem.Node.fPlane:=FindSplitPlane(JobStackItem.PolygonNodes);
      end;
      BackJobStackItem.PolygonNodes.Count:=0;
      FrontJobStackItem.PolygonNodes.Count:=0;
      for Index:=0 to JobStackItem.PolygonNodes.Count-1 do begin
       JobStackItem.PolygonNodes.Items[Index].SplitByPlane(JobStackItem.Node.Plane,
                                                           BackJobStackItem.PolygonNodes,
                                                           JobStackItem.Node.fPolygonNodes,
                                                           BackJobStackItem.PolygonNodes,
                                                           FrontJobStackItem.PolygonNodes);
      end;
      if FrontJobStackItem.PolygonNodes.Count>0 then begin
       if not assigned(JobStackItem.Node.fFront) then begin
        JobStackItem.Node.fFront:=TDualTree.TNode.Create(fTree);
       end;
       FrontJobStackItem.Node:=JobStackItem.Node.fFront;
       JobStack.Push(FrontJobStackItem);
      end;
      if BackJobStackItem.PolygonNodes.Count>0 then begin
       if not assigned(JobStackItem.Node.fBack) then begin
        JobStackItem.Node.fBack:=TDualTree.TNode.Create(fTree);
       end;
       BackJobStackItem.Node:=JobStackItem.Node.fBack;
       JobStack.Push(BackJobStackItem);
      end;
     end;
    end;
   finally
    FrontJobStackItem.PolygonNodes.Finalize;
   end;
  finally
   BackJobStackItem.PolygonNodes.Finalize;
  end;
 finally
  JobStack.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.TNode.AddIndices(const aIndices:TIndexList);
begin

end;

{ TpvCSGBSP.TTree }

constructor TpvCSGBSP.TDualTree.Create(const aMesh:TMesh;const aSplitSettings:PSplitSettings=nil);
begin
 inherited Create;
 fMesh:=aMesh;
 if assigned(aSplitSettings) then begin
  fSplitSettings:=aSplitSettings^;
 end else begin
  fSplitSettings:=DefaultSplitSettings;
 end;
 fFirstPolygonNode:=nil;
 fLastPolygonNode:=nil;
 fPolygonRootNode:=TDualTree.TPolygonNode.Create(self,nil);
 fRootNode:=TDualTree.TNode.Create(self);
end;

destructor TpvCSGBSP.TDualTree.Destroy;
begin
 while assigned(fLastPolygonNode) do begin
  fLastPolygonNode.Free;
 end;
 fPolygonRootNode:=nil;
 FreeAndNil(fRootNode);
 inherited Destroy;
end;

procedure TpvCSGBSP.TDualTree.Invert;
begin
 fMesh.Invert;
 fPolygonRootNode.Invert;
 fRootNode.Invert;
end;

procedure TpvCSGBSP.TDualTree.ClipTo(const aWithTree:TDualTree;const aAlsoRemoveCoplanarFront:boolean=false);
begin
 fRootNode.ClipTo(aWithTree,aAlsoRemoveCoplanarFront);
end;

procedure TpvCSGBSP.TDualTree.AddPolygons(const aPolygons:TPolygonList);
var Index:TpvSizeInt;
    PolygonNodes:TPolygonNodeList;
begin
 PolygonNodes.Initialize;
 try
  for Index:=0 to aPolygons.Count-1 do begin
   PolygonNodes.Add(fPolygonRootNode.AddPolygon(aPolygons.Items[Index]));
  end;
  fRootNode.AddPolygonNodes(PolygonNodes);
 finally
  PolygonNodes.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.AddIndices(const aIndices:TIndexList);
var Index,Count,CountPolygonVertices:TpvSizeInt;
    Polygon:TPolygon;
    Polygons:TPolygonList;
begin
 Polygons.Initialize;
 try
  Index:=0;
  Count:=aIndices.Count;
  while Index<Count do begin
   case fMesh.fMode of
    TMesh.TMode.Triangles:begin
     CountPolygonVertices:=3;
    end;
    else {TMesh.TMode.Polygons:}begin
     CountPolygonVertices:=aIndices.Items[Index];
     inc(Index);
    end;
   end;
   if CountPolygonVertices>2 then begin
    if (Index+(CountPolygonVertices-1))<Count then begin
     Polygon.Indices.Initialize;
     Polygon.Indices.AddRangeFrom(aIndices,Index,CountPolygonVertices);
     Polygons.Add(Polygon);
    end;
   end;
   inc(Index,CountPolygonVertices);
  end;
  AddPolygons(Polygons);
 finally
  Polygons.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.GetPolygons(var aPolygons:TPolygonList);
type TJobQueue=TDynamicQueue<TPolygonNode>;
var Index:TpvSizeInt;
    JobQueue:TJobQueue;
    PolygonNode:TPolygonNode;
begin
 JobQueue.Initialize;
 try
  JobQueue.Enqueue(fPolygonRootNode);
  while JobQueue.Dequeue(PolygonNode) do begin
   if not PolygonNode.fRemoved then begin
    if PolygonNode.fPolygon.Indices.Count>0 then begin
     aPolygons.Add(PolygonNode.fPolygon);
    end else begin
     PolygonNode:=PolygonNode.fFirstChild;
     while assigned(PolygonNode) do begin
      if not PolygonNode.fRemoved then begin
       JobQueue.Enqueue(PolygonNode);
      end;
      PolygonNode:=PolygonNode.fParentNext;
     end;
    end;
   end;
  end;
 finally
  JobQueue.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.GetIndices(var aIndices:TIndexList);
var PolygonIndex,IndicesIndex:TpvSizeInt;
    Polygons:TPolygonList;
    Polygon:PPolygon;
begin
 Polygons.Initialize;
 try
  GetPolygons(Polygons);
  case fMesh.fMode of
   TMesh.TMode.Triangles:begin
    for PolygonIndex:=0 to Polygons.Count-1 do begin
     Polygon:=@Polygons.Items[PolygonIndex];
     if Polygon^.Indices.Count>2 then begin
      for IndicesIndex:=2 to Polygon^.Indices.Count-1 do begin
       aIndices.Add([Polygon^.Indices.Items[0],
                     Polygon^.Indices.Items[IndicesIndex-1],
                     Polygon^.Indices.Items[IndicesIndex]]);
      end;
     end;
    end;
   end;
   else {TMesh.TMode.Polygons:}begin
    for PolygonIndex:=0 to Polygons.Count-1 do begin
     Polygon:=@Polygons.Items[PolygonIndex];
     if Polygon^.Indices.Count>2 then begin
      aIndices.Add(Polygon^.Indices.Count);
      aIndices.Add(Polygon^.Indices);
     end;
    end;
   end;
  end;
 finally
  Polygons.Finalize;
 end;
end;

procedure TpvCSGBSP.TDualTree.Merge(const aTree:TDualTree);
var Index,OtherIndex,Offset,Count,CountPolygonVertices:TpvSizeInt;
    Polygons:TPolygonList;
    Polygon:PPolygon;
    PolygonNodes:TPolygonNodeList;
begin
 Offset:=fMesh.fVertices.Count;
 fMesh.fVertices.Add(aTree.fMesh.fVertices);
 Polygons.Initialize;
 try
  aTree.GetPolygons(Polygons);
  for Index:=0 to Polygons.Count-1 do begin
   Polygon:=@Polygons.Items[Index];
   for OtherIndex:=0 to Polygon^.Indices.Count-1 do begin
    inc(Polygon^.Indices.Items[OtherIndex],Offset);
   end;
  end;
  AddPolygons(Polygons);
 finally
  Polygons.Finalize;
 end;
end;

function TpvCSGBSP.TDualTree.ToMesh:TMesh;
begin
 result:=TMesh.Create(fMesh.fMode);
 try
  result.SetVertices(fMesh.fVertices);
  GetIndices(result.fIndices);
 finally
  result.RemoveDuplicateAndUnusedVertices;
 end;
end;

end.
