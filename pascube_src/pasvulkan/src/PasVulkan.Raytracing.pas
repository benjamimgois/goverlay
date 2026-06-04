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
unit PasVulkan.Raytracing;
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
     PasMP,
     PasVulkan.Types,
     PasVulkan.Utils,
     PasVulkan.Math,
     PasVulkan.Application,
     PasVulkan.Collections,
     PasVulkan.HighResolutionTimer,
     PasVulkan.Framework,
     PasVulkan.BufferRangeAllocator;

type EpvRaytracing=class(Exception);

     TpvRaytracingCullMask=class
      public
       const Shadows=$01;     // All objects that should cast shadows should have this cull mask set
             CameraView=$02;  // All objects that should be visible in the camera view should have this cull mask set, so for example the player in first person view should not have this cull mask set, but still CULLMASK_REFLECTION for reflections and so on
             Reflection=$04;  // All objects that should be visible in reflections should have this cull mask set
             Occlusion=$08;   // All objects that should be considered for ambient occlusion as occluders should have this cull mask set
             All=$ff;         // Just everything
     end;

     TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration=TPasMPUInt64;

     TpvRaytracingAccelerationStructure=class;

     TpvRaytracingAccelerationStructureList=TpvObjectGenericList<TpvRaytracingAccelerationStructure>;

     TpvRaytracingAccelerationStructureInstanceArrayList=TpvDynamicArrayList<TVkAccelerationStructureInstanceKHR>;

     TpvRaytracingAccelerationStructureInstanceArrayGenerationList=TpvDynamicArrayList<TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration>;

     { TpvRaytracingCompactedSizeQueryPool }
     TpvRaytracingCompactedSizeQueryPool=class
      public
       type TCompactedSizes=TpvDynamicArrayList<TVkDeviceSize>;
            TAccelerationStructureList=TpvDynamicArrayList<TVkAccelerationStructureKHR>;
            TAccelerationStructureIndexHashMap=TpvHashMap<TVkAccelerationStructureKHR,TpvSizeInt>;
      private
       fDevice:TpvVulkanDevice;
       fQueryPool:TVkQueryPool;
       fQueryPoolCreateInfo:TVkQueryPoolCreateInfo;
       fCount:TVkUInt32;
       fAccelerationStructures:TpvRaytracingAccelerationStructureList;
       fAccelerationStructureList:TAccelerationStructureList;
       fAccelerationStructureIndexHashMap:TAccelerationStructureIndexHashMap;
       fResultAccelerationStructureIndexHashMap:TAccelerationStructureIndexHashMap;
       fCompactedSizes:TCompactedSizes;
      public
       constructor Create(const aDevice:TpvVulkanDevice);
       destructor Destroy; override;
       function Empty:boolean;
       function Ready:boolean;
       procedure Reset;
       procedure AddAccelerationStructure(const aAccelerationStructure:TpvRaytracingAccelerationStructure);
       procedure Query(const aCommandBuffer:TpvVulkanCommandBuffer);
       procedure GetResults;
       function GetCompactedSizeByIndex(const aIndex:TpvSizeInt):TVkDeviceSize;
       function GetCompactedSizeByAccelerationStructure(const aAccelerationStructure:TpvRaytracingAccelerationStructure):TVkDeviceSize;
      published
       property Device:TpvVulkanDevice read fDevice;
       property QueryPool:TVkQueryPool read fQueryPool;
       property Count:TVkUInt32 read fCount;
       property CompactedSizes:TCompactedSizes read fCompactedSizes;
       property AccelerationStructures:TpvRaytracingAccelerationStructureList read fAccelerationStructures;
     end;

     { TpvRaytracingBLASGeometryInfoBufferItem } 
     TpvRaytracingBLASGeometryInfoBufferItem=packed record // per gl_InstanceCustomIndexEXT or gl_InstanceID wise, depending on the usage
      public
       const TypeNone=TVkUInt32($ffffffff);
             TypeMesh=0;
             TypeParticle=1;
             TypePlanet=2;
      private

       // uvec4 start
       fType_:TVkUInt32; // Type of object, 0 = mesh, 1 = particle, 2 = planet, and so on
       fObjectIndex:TVkUInt32; // Index of object, especially for planet objects important, because it's the index of the planet in the planet list, and not for the mesh objects, since mesh objects uses the same unique vertex and index buffers.
       fMaterialIndex:TVkUInt32; // Index of material
       fIndexOffset:TVkUInt32; // Offset inside index buffer
       // uvec4 end

      public 
       constructor Create(const aType_:TVkUInt32;
                          const aObjectIndex:TVkUInt32;
                          const aMaterialIndex:TVkUInt32;
                          const aIndexOffset:TVkUInt32);
      public
       property Type_:TVkUInt32 read fType_ write fType_;
       property ObjectIndex:TVkUInt32 read fObjectIndex write fObjectIndex;
       property MaterialIndex:TVkUInt32 read fMaterialIndex write fMaterialIndex;
       property IndexOffset:TVkUInt32 read fIndexOffset write fIndexOffset;
     end;
     PpvRaytracingBLASGeometryInfoBufferItem=^TpvRaytracingBLASGeometryInfoBufferItem;

     TpvRaytracingBLASGeometryInfoBufferItems=array of TpvRaytracingBLASGeometryInfoBufferItem;

     TpvRaytracingBLASGeometryInfoBufferItemList=TpvDynamicArrayList<TpvRaytracingBLASGeometryInfoBufferItem>;

     TpvRaytracingBLASGeometryInfoOffsetBufferItem=TVkUInt32; // Instance offset index for first geometry buffer item per BLAS instance
     PpvRaytracingBLASGeometryInfoOffsetBufferItem=^TpvRaytracingBLASGeometryInfoOffsetBufferItem;

     TpvRaytracingBLASGeometryInfoOffsetBufferItems=array of TpvRaytracingBLASGeometryInfoOffsetBufferItem;

     TpvRaytracingBLASGeometryInfoOffsetBufferItemList=TpvDynamicArrayList<TpvRaytracingBLASGeometryInfoOffsetBufferItem>;

     { TpvRaytracingInstanceShaderBindingTableRecordOffsets }
     TpvRaytracingInstanceShaderBindingTableRecordOffsets=class
      public
       const Mesh=0;
             Planet=1;
     end;

     { TpvRaytracingInstanceCustomIndexManager }
     TpvRaytracingInstanceCustomIndexManager=class
      public
       type TItem=record
             Index:TpvInt32;
             Data:TpvPtrUInt;
            end;
            PItem=^TItem;
            TItemList=TpvDynamicArrayList<TItem>;
            TItemHashMap=TpvHashMap<TpvPtrUInt,TpvInt32>;
            TFreeList=TpvDynamicStack<TpvInt32>;
      private
       fItems:TItemList;
       fItemHashMap:TItemHashMap;
       fFreeList:TFreeList;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function Add(const aData:TpvPtrUInt):TpvInt32;
       function RemoveData(const aData:TpvPtrUInt):boolean;
       function RemoveIndex(const aIndex:TpvInt32):boolean;
       function GetData(const aIndex:TpvInt32):TpvPtrUInt;
       function GetIndex(const aData:TpvPtrUInt):TpvInt32;
     end;

     { TpvRaytracingAccelerationStructureBuildQueue }
     TpvRaytracingAccelerationStructureBuildQueue=class
      public
       type TBuildGeometryInfos=TpvDynamicArrayList<TVkAccelerationStructureBuildGeometryInfoKHR>;
            TBuildOffsetInfoPtrs=TpvDynamicArrayList<PVkAccelerationStructureBuildRangeInfoKHR>;
      private 
       fDevice:TpvVulkanDevice;
       fBuildGeometryInfos:TBuildGeometryInfos;
       fBuildOffsetInfoPtrs:TBuildOffsetInfoPtrs;
      public
       constructor Create(const aDevice:TpvVulkanDevice); reintroduce;
       destructor Destroy; override;
       procedure Clear;
       function Empty:Boolean;
       procedure Enqueue(const aBuildGeometryInfo:TVkAccelerationStructureBuildGeometryInfoKHR;
                         const aBuildOffsetInfoPtr:PVkAccelerationStructureBuildRangeInfoKHR); 
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
      published
       property Device:TpvVulkanDevice read fDevice;
     end;

     { TpvRaytracingAccelerationStructure }
     TpvRaytracingAccelerationStructure=class
      private
       fDevice:TpvVulkanDevice;
       fAccelerationStructure:TVkAccelerationStructureKHR;
       fAccelerationStructureType:TVkAccelerationStructureTypeKHR;
       fBuildGeometryInfo:TVkAccelerationStructureBuildGeometryInfoKHR;
       fBuildSizesInfo:TVkAccelerationStructureBuildSizesInfoKHR;
       fBuildOffsetInfoPtr:PVkAccelerationStructureBuildRangeInfoKHR;
       fGeneration:TpvUInt64;
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aAccelerationStructureType:TVkAccelerationStructureTypeKHR=TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_GENERIC_KHR)); reintroduce; 
       destructor Destroy; override;
       class function Reduce(const aStructures:TpvRaytracingAccelerationStructureList):TVkAccelerationStructureBuildSizesInfoKHR; static;
       function GetMemorySizes(const aCounts:PVkUInt32):TVkAccelerationStructureBuildSizesInfoKHR;
       procedure Initialize(const aResultBuffer:TpvVulkanBuffer;const aResultOffset:TVkDeviceSize);
       procedure Finalize;
       procedure Build(const aCommandBuffer:TpvVulkanCommandBuffer;
                       const aScratchBuffer:TpvVulkanBuffer;
                       const aScratchBufferOffset:TVkDeviceSize;
                       const aUpdate:Boolean=false;   
                       const aSourceAccelerationStructure:TpvRaytracingAccelerationStructure=nil;
                       const aQueue:TpvRaytracingAccelerationStructureBuildQueue=nil);
       procedure CopyFrom(const aCommandBuffer:TpvVulkanCommandBuffer;
                          const aSourceAccelerationStructure:TpvRaytracingAccelerationStructure;
                          const aCompact:Boolean=false);
       class procedure MemoryBarrier(const aCommandBuffer:TpvVulkanCommandBuffer); static;
      published
       property Device:TpvVulkanDevice read fDevice;
       property AccelerationStructure:TVkAccelerationStructureKHR read fAccelerationStructure;
       property AccelerationStructureType:TVkAccelerationStructureTypeKHR read fAccelerationStructureType;
       property Generation:TpvUInt64 read fGeneration;
      public
       property BuildGeometryInfo:TVkAccelerationStructureBuildGeometryInfoKHR read fBuildGeometryInfo;
       property BuildSizesInfo:TVkAccelerationStructureBuildSizesInfoKHR read fBuildSizesInfo;
       property AccelerationStructureSize:TVkDeviceSize read fBuildSizesInfo.accelerationStructureSize;
       property UpdateScratchSize:TVkDeviceSize read fBuildSizesInfo.updateScratchSize;
       property BuildScratchSize:TVkDeviceSize read fBuildSizesInfo.buildScratchSize;
     end;

     { TpvRaytracingBottomLevelAccelerationStructureGeometry }
     TpvRaytracingBottomLevelAccelerationStructureGeometry=class
      public
       type TGeometries=TpvDynamicArrayList<TVkAccelerationStructureGeometryKHR>;
            TBuildOffsets=TpvDynamicArrayList<TVkAccelerationStructureBuildRangeInfoKHR>;
      private
       fDevice:TpvVulkanDevice;
       fGeometries:TGeometries;
       fBuildOffsets:TBuildOffsets;
      public
       constructor Create(const aDevice:TpvVulkanDevice); reintroduce;
       destructor Destroy; override;       
       procedure AddTriangles(const aVertexBuffer:TpvVulkanBuffer;
                              const aVertexOffset:TVkUInt32;
                              const aVertexCount:TVkUInt32;
                              const aVertexStride:TVkDeviceSize;
                              const aIndexBuffer:TpvVulkanBuffer;
                              const aIndexOffset:TVkUInt32;
                              const aIndexCount:TVkUInt32;
                              const aOpaque:Boolean;
                              const aTransformBuffer:TpvVulkanBuffer=nil;
                              const aTransformOffset:TVkDeviceSize=0);
       procedure AddAABBs(const aAABBBuffer:TpvVulkanBuffer;
                          const aOffset:TVkDeviceSize;
                          const aCount:TVkUInt32;
                          const aOpaque:Boolean;
                          const aStride:TVkDeviceSize=SizeOf(TVkAabbPositionsKHR));
      published
       property Geometries:TGeometries read fGeometries;
       property BuildOffsets:TBuildOffsets read fBuildOffsets;
     end;
     
     { TpvRaytracingBottomLevelAccelerationStructure }
     TpvRaytracingBottomLevelAccelerationStructure=class(TpvRaytracingAccelerationStructure)
      private
       fGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry;
       fDynamicGeometry:Boolean;
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry=nil;
                          const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                          const aDynamicGeometry:Boolean=false;
                          const aAccelerationStructureSize:TVkDeviceSize=0); reintroduce;
       destructor Destroy; override;
       procedure Update(const aGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry;
                        const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                        const aDynamicGeometry:Boolean=false); reintroduce;
      published
       property Geometry:TpvRaytracingBottomLevelAccelerationStructureGeometry read fGeometry;
       property DynamicGeometry:Boolean read fDynamicGeometry;
     end;

     { TpvRaytracingBottomLevelAccelerationStructureInstance }
     TpvRaytracingBottomLevelAccelerationStructureInstance=class
      private
       fDevice:TpvVulkanDevice;
       fAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
       fAccelerationStructureInstance:TVkAccelerationStructureInstanceKHR;
       fAccelerationStructureInstancePointer:PVkAccelerationStructureInstanceKHR;
       fTag:TpvPtrInt;
       function GetTransform:TpvMatrix4x4;
       procedure SetTransform(const aTransform:TpvMatrix4x4);
       function GetInstanceCustomIndex:TpvUInt32;
       procedure SetInstanceCustomIndex(const aInstanceCustomIndex:TpvUInt32);
       function GetMask:TpvUInt32;
       procedure SetMask(const aMask:TpvUInt32);
       function GetInstanceShaderBindingTableRecordOffset:TpvUInt32;
       procedure SetInstanceShaderBindingTableRecordOffset(const aInstanceShaderBindingTableRecordOffset:TpvUInt32);
       function GetFlags:TVkGeometryInstanceFlagsKHR;
       procedure SetFlags(const aFlags:TVkGeometryInstanceFlagsKHR);
       function GetAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
       procedure SetAccelerationStructure(const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure);
       procedure ForceSetAccelerationStructure(const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure);
       function GetAccelerationStructureDeviceAddress:TVkDeviceAddress;
       procedure SetAccelerationStructureDeviceAddress(const aAccelerationStructureDeviceAddress:TVkDeviceAddress); 
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aTransform:TpvMatrix4x4;
                          const aInstanceCustomIndex:TVkUInt32;
                          const aMask:TVkUInt32;
                          const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                          const aFlags:TVkGeometryInstanceFlagsKHR;
                          const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
                          const aAccelerationStructureInstancePointer:PVkAccelerationStructureInstanceKHR=nil); reintroduce;
       destructor Destroy; override;
       function CompareTransform(const aTransform:TpvMatrix4x4):Boolean;
      public
       property Transform:TpvMatrix4x4 read GetTransform write SetTransform;
      published
       property Device:TpvVulkanDevice read fDevice;
       property InstanceCustomIndex:TVkUInt32 read GetInstanceCustomIndex write SetInstanceCustomIndex;
       property Mask:TVkUInt32 read GetMask write SetMask;
       property InstanceShaderBindingTableRecordOffset:TVkUInt32 read GetInstanceShaderBindingTableRecordOffset write SetInstanceShaderBindingTableRecordOffset;
       property Flags:TVkGeometryInstanceFlagsKHR read GetFlags write SetFlags;
       property AccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure read GetAccelerationStructure write SetAccelerationStructure;
       property AccelerationStructureDeviceAddress:TVkDeviceAddress read GetAccelerationStructureDeviceAddress write SetAccelerationStructureDeviceAddress;
       property Tag:TpvPtrInt read fTag write fTag;
      public
       property AccelerationStructureInstance:PVkAccelerationStructureInstanceKHR read fAccelerationStructureInstancePointer write fAccelerationStructureInstancePointer;
     end;

     TpvRaytracingBottomLevelAccelerationStructureInstanceList=TpvObjectGenericList<TpvRaytracingBottomLevelAccelerationStructureInstance>;

     { TpvRaytracingTopLevelAccelerationStructure }
     TpvRaytracingTopLevelAccelerationStructure=class(TpvRaytracingAccelerationStructure)
      private
       fInstances:TVkAccelerationStructureGeometryInstancesDataKHR;
       fCountInstances:TVkUInt32;
       fBuildOffsetInfo:TVkAccelerationStructureBuildRangeInfoKHR;
       fGeometry:TVkAccelerationStructureGeometryKHR;
       fDynamicGeometry:Boolean;
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aInstanceAddress:TVkDeviceAddress=0;
                          const aInstanceCount:TVkUInt32=0;
                          const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                          const aDynamicGeometry:Boolean=false); reintroduce;
       destructor Destroy; override;
       procedure Update(const aInstanceAddress:TVkDeviceAddress;
                        const aInstanceCount:TVkUInt32;
                        const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                        const aDynamicGeometry:Boolean=false);
       procedure UpdateInstanceAddress(const aInstanceAddress:TVkDeviceAddress);
      public
       property Instances:TVkAccelerationStructureGeometryInstancesDataKHR read fInstances;
       property CountInstances:TVkUInt32 read fCountInstances;
      published
     end;

     { TpvRaytracingGeometryInfoManager }
     TpvRaytracingGeometryInfoManager=class
      public
       type TOnDefragmentMove=procedure(const aSender:TpvRaytracingGeometryInfoManager;const aObject:TObject;const aOldOffset,aNewOffset,aSize:TpvInt64) of object;
            TObjectList=TpvDynamicArrayList<TObject>;
      private
       fLock:TPasMPCriticalSection;
       fObjectList:TObjectList;
       fGeometryInfoList:TpvRaytracingBLASGeometryInfoBufferItemList;
       fBufferRangeAllocator:TpvBufferRangeAllocator;
       fSizeDirty:TPasMPBool32;
       fDirty:TPasMPBool32;
       fOnDefragmentMove:TOnDefragmentMove;
       procedure BufferRangeAllocatorOnResize(const aSender:TpvBufferRangeAllocator;const aNewCapacity:TpvInt64);
       procedure BufferRangeAllocatorOnDefragmentMove(const aSender:TpvBufferRangeAllocator;const aOldOffset,aNewOffset,aSize:TpvInt64);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function AllocateGeometryInfoRange(const aObject:TObject;const aCount:TpvSizeInt):TpvSizeInt;
       procedure FreeGeometryInfoRange(const aOffset:TpvSizeInt);
       function GetGeometryInfo(const aIndex:TpvSizeInt):PpvRaytracingBLASGeometryInfoBufferItem;
       procedure Defragment;
      published
       property ObjectList:TObjectList read fObjectList;
       property GeometryInfoList:TpvRaytracingBLASGeometryInfoBufferItemList read fGeometryInfoList;       
       property BufferRangeAllocator:TpvBufferRangeAllocator read fBufferRangeAllocator; 
       property OnDefragmentMove:TOnDefragmentMove read fOnDefragmentMove write fOnDefragmentMove;
      public
       property SizeDirty:TPasMPBool32 read fSizeDirty write fSizeDirty; 
       property Dirty:TPasMPBool32 read fDirty write fDirty;
     end;  
     
     { TpvRaytracing }
     TpvRaytracing=class
      public 
       type TCompactIterationState=
             (
              Query,
              Querying,
              Compact
             );
            { TDelayedFreeListItem }
            TDelayedFreeItem=record
             Object_:TObject;
             Delay:TpvSizeInt; // Delay in iterations
            end;
            PDelayedFreeItem=^TDelayedFreeItem;
            TDelayedFreeItemQueue=TpvDynamicQueue<TDelayedFreeItem>;
            PDelayedFreeItemQueue=^TDelayedFreeItemQueue;
            { TDelayedFreeAccelerationStructureItem }
            TDelayedFreeAccelerationStructureItem=record
             AccelerationStructure:TVkAccelerationStructureKHR;
             Delay:TpvSizeInt; // Delay in iterations
            end;
            PDelayedFreeAccelerationStructureItem=^TDelayedFreeAccelerationStructureItem;
            TDelayedFreeAccelerationStructureItemQueue=TpvDynamicQueue<TDelayedFreeAccelerationStructureItem>;
            PDelayedFreeAccelerationStructureItemQueue=^TDelayedFreeAccelerationStructureItemQueue;            
            { TBottomLevelAccelerationStructure }
            TBottomLevelAccelerationStructure=class
             public
              type TEnqueueState=
                    (
                     None,
                     Build,
                     Update
                    );
                   TCompactState=
                    (
                     None,
                     Query,
                     Querying,
                     Compact,
                     Compacting,
                     Compacted
                    );
                   { TInstance }
                   TInstance=class
                    private
                     fRaytracing:TpvRaytracing;
                     fBottomLevelAccelerationStructure:TBottomLevelAccelerationStructure;
                     fInRaytracingIndex:TpvSizeInt;
                     fInBottomLevelAccelerationStructureIndex:TpvSizeInt;
                     fAccelerationStructureInstance:TpvRaytracingBottomLevelAccelerationStructureInstance;
                     fGeneration:TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration;
                     fLastGeneration:TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration;
                     fTrackedObjectInstance:TObject;
                     fLastSyncedGeneration:TpvUInt64;
                     function GetInstanceCustomIndex:TVkInt32;
                     procedure SetInstanceCustomIndex(const aInstanceCustomIndex:TVkInt32);
                     procedure SetInstanceCustomIndexEx(const aInstanceCustomIndex:TVkInt32);
                    public
                     constructor Create(const aBottomLevelAccelerationStructure:TBottomLevelAccelerationStructure;
                                        const aTransform:TpvMatrix4x4;
                                        const aInstanceCustomIndex:TVkInt32;
                                        const aMask:TVkUInt32;
                                        const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                                        const aFlags:TVkGeometryInstanceFlagsKHR); reintroduce;
                     destructor Destroy; override;
                     procedure AfterConstruction; override;
                     procedure BeforeDestruction; override;
                     procedure NewGeneration;
                    public
                     property Raytracing:TpvRaytracing read fRaytracing;
                     property BottomLevelAccelerationStructure:TBottomLevelAccelerationStructure read fBottomLevelAccelerationStructure;
                     property InstanceCustomIndex:TVkInt32 read GetInstanceCustomIndex write SetInstanceCustomIndex;
                     property InstanceCustomIndexEx:TVkInt32 read GetInstanceCustomIndex write SetInstanceCustomIndexEx;
                     property InRaytracingIndex:TpvSizeInt read fInRaytracingIndex;
                     property InBottomLevelAccelerationStructureIndex:TpvSizeInt read fInBottomLevelAccelerationStructureIndex;
                     property AccelerationStructureInstance:TpvRaytracingBottomLevelAccelerationStructureInstance read fAccelerationStructureInstance;
                     property Generation:TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration read fGeneration;
                     property LastGeneration:TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration read fLastGeneration;
                     property TrackedObjectInstance:TObject read fTrackedObjectInstance write fTrackedObjectInstance;
                     property LastSyncedGeneration:TpvUInt64 read fLastSyncedGeneration write fLastSyncedGeneration;
                   end;
                   TBottomLevelAccelerationStructureInstanceList=TpvObjectGenericList<TInstance>;
             private
              fRaytracing:TpvRaytracing;
              fInRaytracingIndex:TpvSizeInt;
              fName:TpvUTF8String;
              fAllocationGroupID:TpvUInt64;
              fFlags:TVkBuildAccelerationStructureFlagsKHR;
              fDynamicGeometry:Boolean;
              fCompactable:Boolean;
              fAccelerationStructureGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry;
              fAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
              fAccelerationStructureSize:TVkDeviceSize;
              fCompactedAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
              fCompactedAccelerationStructureSize:TVkDeviceSize;
              fBuildScratchSize:TVkDeviceSize;
              fUpdateScratchSize:TVkDeviceSize;
              fScratchSize:TVkDeviceSize;
              fAccelerationStructureScratchSize:TVkDeviceSize;
              fAccelerationStructureBuffer:TpvVulkanBuffer;
              fCompactedAccelerationStructureBuffer:TpvVulkanBuffer;
              fScratchOffset:TVkDeviceSize;
              fScratchPass:TpvUInt64;
              fGeometryInfoBaseIndex:TpvSizeInt;
              fCountGeometries:TpvSizeInt;
              fGeometryInfoBufferItemList:TpvRaytracingBLASGeometryInfoBufferItemList;
              fBottomLevelAccelerationStructureInstanceList:TBottomLevelAccelerationStructureInstanceList;
              fEnqueueState:TEnqueueState;
              fCompactState:TCompactState;
              fInRaytracingCompactIndex:TpvSizeInt;
              procedure UpdateBuffer;
             public
              constructor Create(const aBLASManager:TpvRaytracing;
                                 const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                                 const aDynamicGeometry:Boolean=false;
                                 const aCompactable:Boolean=false;
                                 const aAllocationGroupID:TpvUInt64=0;
                                 const aName:TpvUTF8String=''); reintroduce;
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure RemoveFromCompactList(const aLocking:Boolean=true);
              procedure Initialize;
              procedure Update;
              function GetGeometryInfo(const aIndex:TpvSizeInt):PpvRaytracingBLASGeometryInfoBufferItem;
              function AcquireInstance(const aTransform:TpvMatrix4x4;
                                       const aInstanceCustomIndex:TVkInt32;
                                       const aMask:TVkUInt32;
                                       const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                                       const aFlags:TVkGeometryInstanceFlagsKHR):TInstance;
              procedure ReleaseInstance(const aInstance:TInstance);
              procedure Enqueue(const aUpdate:Boolean=false); // Enqueue for building or updating acceleration structure
              procedure EnqueueForCompacting;
             public
              property Raytracing:TpvRaytracing read fRaytracing;
              property InRaytracingIndex:TpvSizeInt read fInRaytracingIndex;
              property Flags:TVkBuildAccelerationStructureFlagsKHR read fFlags write fFlags;
              property DynamicGeometry:Boolean read fDynamicGeometry write fDynamicGeometry;
              property Compactable:Boolean read fCompactable write fCompactable;
              property AccelerationStructureGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry read fAccelerationStructureGeometry;
              property AccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure read fAccelerationStructure write fAccelerationStructure;
              property AccelerationStructureSize:TVkDeviceSize read fAccelerationStructureSize write fAccelerationStructureSize;
              property BuildScratchSize:TVkDeviceSize read fBuildScratchSize write fBuildScratchSize;
              property UpdateScratchSize:TVkDeviceSize read fUpdateScratchSize write fUpdateScratchSize;
              property ScratchSize:TVkDeviceSize read fScratchSize write fScratchSize;
              property AccelerationStructureScratchSize:TVkDeviceSize read fAccelerationStructureScratchSize write fAccelerationStructureScratchSize;
              property AccelerationStructureBuffer:TpvVulkanBuffer read fAccelerationStructureBuffer write fAccelerationStructureBuffer;
              property BottomLevelAccelerationStructureInstanceList:TBottomLevelAccelerationStructureInstanceList read fBottomLevelAccelerationStructureInstanceList;
              property ScratchOffset:TVkDeviceSize read fScratchOffset write fScratchOffset;
              property ScratchPass:TpvUInt64 read fScratchPass write fScratchPass;
              property GeometryInfoBaseIndex:TpvSizeInt read fGeometryInfoBaseIndex write fGeometryInfoBaseIndex;
              property CountGeometries:TpvSizeInt read fCountGeometries write fCountGeometries;
              property GeometryInfoBufferItemList:TpvRaytracingBLASGeometryInfoBufferItemList read fGeometryInfoBufferItemList;
            end;
            TBottomLevelAccelerationStructureList=TpvObjectGenericList<TBottomLevelAccelerationStructure>;
            { TBottomLevelAccelerationStructureQueue }
            TBottomLevelAccelerationStructureQueue=class
             private
              fRaytracing:TpvRaytracing;
              fItems:array of TBottomLevelAccelerationStructure;
              fCapacity:TPasMPInt32;
              fCount:TPasMPInt32;
              fLock:TPasMPMultipleReaderSingleWriterLock;
              function GetItem(const aIndex:TPasMPInt32):TBottomLevelAccelerationStructure;
              procedure SetItem(const aIndex:TPasMPInt32;const aValue:TBottomLevelAccelerationStructure);
             public
              constructor Create(const aRaytracing:TpvRaytracing); reintroduce;
              destructor Destroy; override;
              procedure Clear;
              procedure Enqueue(const aBottomLevelAccelerationStructure:TBottomLevelAccelerationStructure);
             published
              property Raytracing:TpvRaytracing read fRaytracing;
              property Capacity:TPasMPInt32 read fCapacity;
              property Count:TPasMPInt32 read fCount;
             public
              property Items[const aIndex:TPasMPInt32]:TBottomLevelAccelerationStructure read GetItem write SetItem; default;
            end;
            TGeometryOffsetArrayList=TpvDynamicArrayList<TVkUInt32>; // Instance offset index for first geometry buffer item per BLAS instance, when >= 24 bits are needed, since instance custom index is only 24 bits
            TVulkanBufferCopyArray=TpvDynamicArrayList<TVkBufferCopy>;
            TDoubleBufferedTopLevelAccelerationStructures=array[0..1] of TpvRaytracingTopLevelAccelerationStructure;
            TTopLevelAccelerationStructures=array[-1..MaxInFlightFrames-1] of TVkAccelerationStructureKHR;
            TDoubleBufferedVulkanBuffer=array[0..1] of TpvVulkanBuffer;
            TOnMustWaitForPreviousFrame=function(const aSender:TObject):Boolean of object;
            TOnUpdate=procedure(const aSender:TObject) of object;
      private     
       procedure ReassignBottomLevelAccelerationStructureInstancePointers;
      private 
       fDevice:TpvVulkanDevice;
       fCountInFlightFrames:TpvSizeInt;
       fSafeRelease:TPasMPBool32;
       fUseCompacting:TPasMPBool32;
       fLock:TPasMPCriticalSection;
       fDataLock:TPasMPMultipleReaderSingleWriterLock;
       fDelayedFreeItemQueues:array[0..1] of TDelayedFreeItemQueue;
       fDelayedFreeItemQueueIndex:TpvSizeInt;
       fDelayedFreeAccelerationStructureItemQueues:array[0..1] of TDelayedFreeAccelerationStructureItemQueue;
       fDelayedFreeAccelerationStructureItemQueueIndex:TpvSizeInt;
       fDelayedFreeLock:TPasMPMultipleReaderSingleWriterLock;
       fBottomLevelAccelerationStructureList:TBottomLevelAccelerationStructureList;
       fBottomLevelAccelerationStructureCompactList:TBottomLevelAccelerationStructureList;
       fBottomLevelAccelerationStructureCompactListLock:TPasMPMultipleReaderSingleWriterLock;
       fBottomLevelAccelerationStructureInstanceList:TBottomLevelAccelerationStructure.TBottomLevelAccelerationStructureInstanceList;
       fBottomLevelAccelerationStructureQueue:TBottomLevelAccelerationStructureQueue; // Queue for building or updating acceleration structures
       fBottomLevelAccelerationStructureQueueLock:TPasMPMultipleReaderSingleWriterLock;
       fBottomLevelAccelerationStructureInstanceGenerationCounter:TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration;
       fBottomLevelAccelerationStructureInstanceKHRArrayList:TpvRaytracingAccelerationStructureInstanceArrayList;
       fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList:TpvRaytracingAccelerationStructureInstanceArrayGenerationList;
       fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists:array[0..MaxInFlightFrames-1] of TpvRaytracingAccelerationStructureInstanceArrayGenerationList;
       fBottomLevelAccelerationStructureInstanceKHRArrayListLock:TPasMPMultipleReaderSingleWriterLock;
       fGeometryInfoManager:TpvRaytracingGeometryInfoManager;
       fGeometryOffsetArrayList:TGeometryOffsetArrayList; // As buffer on the GPU, contains the geometry info offset per BLAS instance, when >= 24 bits are needed, since the instance custom index is only 24 bits, we need to store the offset of the first geometry buffer item per BLAS instance, when >= 24 bits are needed
       fDirty:TPasMPBool32;
       fUpdateRaytracingFrameDoneMask:TPasMPUInt32;
       fBottomLevelAccelerationStructureListChanged:TPasMPBool32;
       fMustUpdateTopLevelAccelerationStructure:TPasMPBool32;
       fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers:TDoubleBufferedVulkanBuffer;
       fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers:TDoubleBufferedVulkanBuffer;
       fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex:TpvInt32;
       fAccelerationStructureBuildQueue:TpvRaytracingAccelerationStructureBuildQueue;
       fEmptyInitialized:Boolean;
       fEmptyVertexBuffer:TpvVulkanBuffer;
       fEmptyIndexBuffer:TpvVulkanBuffer;
       fEmptyBottomLevelAccelerationStructure:TpvRaytracing.TBottomLevelAccelerationStructure;
       fEmptyBottomLevelAccelerationStructureInstance:TpvRaytracing.TBottomLevelAccelerationStructure.TInstance;
       fEmptyBottomLevelAccelerationStructureScratchBuffer:TpvVulkanBuffer;
       fBottomLevelAccelerationStructureScratchBuffer:TpvVulkanBuffer;
       fTopLevelAccelerationStructureScratchBuffer:TpvVulkanBuffer;
       fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer:TpvVulkanBuffer;
       fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers:array[-1..MaxInFlightFrames] of TpvVulkanBuffer;
       fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize:TVkDeviceSize;
       fTopLevelAccelerationStructureBuffer:TpvVulkanBuffer;
       fTopLevelAccelerationStructure:TpvRaytracingTopLevelAccelerationStructure;
       fTopLevelAccelerationStructures:TTopLevelAccelerationStructures;
       fTopLevelAccelerationStructureGenerations:array[-1..MaxInFlightFrames-1] of TpvUInt64;
       fCompactedSizeQueryPool:TpvRaytracingCompactedSizeQueryPool;
       fCompactIterationState:TCompactIterationState;
      private
       fStagingQueue:TpvVulkanQueue;
       fStagingCommandBuffer:TpvVulkanCommandBuffer;
       fStagingFence:TpvVulkanFence;
       fCommandBuffer:TpvVulkanCommandBuffer;
       fInFlightFrameIndex:TpvSizeInt;
       fMustTopLevelAccelerationStructureUpdate:Boolean;
      private
       fVulkanBufferCopyArray:TVulkanBufferCopyArray;
      private
       fScratchSize:TVkDeviceSize;
       fScratchPassSize:TVkDeviceSize;
       fScratchPass:TpvUInt64;
      private
       fOnMustWaitForPreviousFrame:TOnMustWaitForPreviousFrame;
       fOnUpdate:TOnUpdate;
      private
       function GetTopLevelAccelerationStructure(const aIndex:TpvSizeInt):TVkAccelerationStructureKHR;
       procedure SetTopLevelAccelerationStructure(const aIndex:TpvSizeInt;const aValue:TVkAccelerationStructureKHR);
      private
       function GetTopLevelAccelerationStructureGeneration(const aIndex:TpvSizeInt):TpvUInt64;
       procedure SetTopLevelAccelerationStructureGeneration(const aIndex:TpvSizeInt;const aValue:TpvUInt64);
      private
       procedure GeometryInfoManagerOnDefragmentMove(const aSender:TpvRaytracingGeometryInfoManager;const aObject:TObject;const aOldOffset,aNewOffset,aSize:TpvInt64);
      private
       procedure ProcessDelayedFreeQueues;
       procedure HostMemoryBarrier;
       procedure WaitForPreviousFrame;
       procedure HandleEmptyBottomLevelAccelerationStructure;
       procedure ProcessCompacting;
       procedure ProcessContentUpdate;
       procedure BuildOrUpdateBottomLevelAccelerationStructureMetaData;
       procedure CollectAndCalculateSizesForAccelerationStructures;
       procedure AllocateOrGrowOrShrinkScratchBuffer;
       procedure BuildOrUpdateAccelerationStructures;
       procedure UpdateBottomLevelAccelerationStructureInstancesForTopLevelAccelerationStructure;
       procedure CreateOrUpdateTopLevelAccelerationStructure;
       procedure AllocateOrGrowTopLevelAccelerationStructureBuffer;
       procedure AllocateOrGrowTopLevelAccelerationStructureScratchBuffer;
       procedure BuildOrUpdateTopLevelAccelerationStructure;
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aCountInFlightFrames:TpvSizeInt); reintroduce;
       destructor Destroy; override;
       function AcquireBottomLevelAccelerationStructure(const aFlags:TVkBuildAccelerationStructureFlagsKHR=0;
                                                        const aDynamicGeometry:Boolean=false;
                                                        const aCompactable:Boolean=false;
                                                        const aAllocationGroupID:TpvUInt64=0;
                                                        const aName:TpvUTF8String=''):TBottomLevelAccelerationStructure;
       procedure ReleaseBottomLevelAccelerationStructure(const aBLAS:TBottomLevelAccelerationStructure);
       procedure Initialize;
       procedure DelayedFreeObject(const aObject:TObject;const aDelay:TpvSizeInt=-1); // -1 = count of in-flight frames
       procedure DelayedFreeAccelerationStructure(const aAccelerationStructure:TVkAccelerationStructureKHR;const aDelay:TpvSizeInt=-1); // -1 = count of in-flight frames
       procedure FreeAccelerationStructureConditionallyWithBuffer(var aAccelerationStructure;var aBuffer:TpvVulkanBuffer;const aSize:TVkDeviceSize);
       procedure FreeObject(var aObject);
       procedure Reset(const aInFlightFrameIndex:TpvSizeInt);
       procedure MarkBottomLevelAccelerationStructureListAsChanged;
       procedure MarkTopLevelAccelerationStructureAsDirty;
       function VerifyStructures:Boolean;
       procedure RefillStructures;  
       procedure Update(const aStagingQueue:TpvVulkanQueue;
                        const aStagingCommandBuffer:TpvVulkanCommandBuffer;
                        const aStagingFence:TpvVulkanFence;
                        const aCommandBuffer:TpvVulkanCommandBuffer;
                        const aInFlightFrameIndex:TpvSizeInt;
                        const aLabels:Boolean);
      public
       property Device:TpvVulkanDevice read fDevice;
      public
       property SafeRelease:TPasMPBool32 read fSafeRelease write fSafeRelease;
      public
       property UseCompacting:TPasMPBool32 read fUseCompacting write fUseCompacting;
      public
       property BottomLevelAccelerationStructureList:TBottomLevelAccelerationStructureList read fBottomLevelAccelerationStructureList;
       property BottomLevelAccelerationStructureInstanceList:TBottomLevelAccelerationStructure.TBottomLevelAccelerationStructureInstanceList read fBottomLevelAccelerationStructureInstanceList;
       property BottomLevelAccelerationStructureInstanceKHRArrayList:TpvRaytracingAccelerationStructureInstanceArrayList read fBottomLevelAccelerationStructureInstanceKHRArrayList;
       property BottomLevelAccelerationStructureInstanceKHRArrayListLock:TPasMPMultipleReaderSingleWriterLock read fBottomLevelAccelerationStructureInstanceKHRArrayListLock;
      public
       property GeometryInfoManager:TpvRaytracingGeometryInfoManager read fGeometryInfoManager;
       property GeometryOffsetArrayList:TGeometryOffsetArrayList read fGeometryOffsetArrayList;
      public
       property Dirty:TPasMPBool32 read fDirty write fDirty;
      public
       property DataLock:TPasMPMultipleReaderSingleWriterLock read fDataLock;
      public
       property OnMustWaitForPreviousFrame:TOnMustWaitForPreviousFrame read fOnMustWaitForPreviousFrame write fOnMustWaitForPreviousFrame;
       property OnUpdate:TOnUpdate read fOnUpdate write fOnUpdate;
      public
       property InFlightFrameIndex:TpvSizeInt read fInFlightFrameIndex;
      public
       property TopLevelAccelerationStructure:TpvRaytracingTopLevelAccelerationStructure read fTopLevelAccelerationStructure;
       property TopLevelAccelerationStructures[const aIndex:TpvSizeInt]:TVkAccelerationStructureKHR read GetTopLevelAccelerationStructure write SetTopLevelAccelerationStructure;
       property TopLevelAccelerationStructureGenerations[const aIndex:TpvSizeInt]:TpvUInt64 read GetTopLevelAccelerationStructureGeneration write SetTopLevelAccelerationStructureGeneration;
      public
       property BottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers:TDoubleBufferedVulkanBuffer read fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers;
       property BottomLevelAccelerationStructureGeometryInfoBufferItemBuffers:TDoubleBufferedVulkanBuffer read fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers;
       property BottomLevelAccelerationStructureGeometryInfoBufferRingIndex:TpvInt32 read fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex;
     end;

implementation

{ TpvRaytracingCompactedSizeQueryPool }

constructor TpvRaytracingCompactedSizeQueryPool.Create(const aDevice:TpvVulkanDevice);
begin

 inherited Create;

 fDevice:=aDevice;

 FillChar(fQueryPoolCreateInfo,SizeOf(TVkQueryPoolCreateInfo),#0);
 fQueryPoolCreateInfo.sType:=VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO;
 fQueryPoolCreateInfo.pNext:=nil;
 fQueryPoolCreateInfo.flags:=0;
 fQueryPoolCreateInfo.queryType:=VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR;
 fQueryPoolCreateInfo.queryCount:=0;

 fQueryPool:=VK_NULL_HANDLE; // Not created yet

 fCount:=0;

 fAccelerationStructures:=TpvRaytracingAccelerationStructureList.Create(false);

 fAccelerationStructureList:=TAccelerationStructureList.Create;

 fAccelerationStructureIndexHashMap:=TAccelerationStructureIndexHashMap.Create(-1);

 fResultAccelerationStructureIndexHashMap:=TAccelerationStructureIndexHashMap.Create(-1);

 fCompactedSizes:=TCompactedSizes.Create;

end;

destructor TpvRaytracingCompactedSizeQueryPool.Destroy;
begin

 FreeAndNil(fCompactedSizes);

 FreeAndNil(fAccelerationStructureIndexHashMap);

 FreeAndNil(fResultAccelerationStructureIndexHashMap);

 FreeAndNil(fAccelerationStructureList);

 FreeAndNil(fAccelerationStructures);

 if fQueryPool<>VK_NULL_HANDLE then begin
  try
   fDevice.Commands.DestroyQueryPool(fDevice.Handle,fQueryPool,nil);
  finally 
   fQueryPool:=VK_NULL_HANDLE;
  end; 
 end;

 inherited Destroy;

end;

function TpvRaytracingCompactedSizeQueryPool.Empty:boolean;
begin
 result:=fCount=0;
end;

function TpvRaytracingCompactedSizeQueryPool.Ready:boolean;
begin
 result:=(fCount>0) and (fCount=fAccelerationStructures.Count);
end;

procedure TpvRaytracingCompactedSizeQueryPool.Reset;
begin
 
 fCount:=0;

 fAccelerationStructures.ClearNoFree;

 fAccelerationStructureList.ClearNoFree;

 fAccelerationStructureIndexHashMap.Clear;

 fCompactedSizes.ClearNoFree;

end;

procedure TpvRaytracingCompactedSizeQueryPool.AddAccelerationStructure(const aAccelerationStructure:TpvRaytracingAccelerationStructure);
begin
 if not fAccelerationStructureIndexHashMap.ExistKey(aAccelerationStructure.AccelerationStructure) then begin
  fAccelerationStructures.Add(aAccelerationStructure);
  fAccelerationStructureList.Add(aAccelerationStructure.fAccelerationStructure);
  fAccelerationStructureIndexHashMap[aAccelerationStructure.fAccelerationStructure]:=fCount;
  inc(fCount);
 end; 
end;

procedure TpvRaytracingCompactedSizeQueryPool.Query(const aCommandBuffer:TpvVulkanCommandBuffer);
var MemoryBarrier:TVkMemoryBarrier;
begin
 
 if fCount>0 then begin 

  // Create acceleration structure compacted size query pool, if it's not created yet or recreate if the count of acceleration 
  // structures has changed, because we need to query the compacted size of each acceleration structure
  if (fQueryPool=VK_NULL_HANDLE) or (fCount>fQueryPoolCreateInfo.queryCount) then begin

   fQueryPoolCreateInfo.queryCount:=fCount;

   // If query pool is already created, destroy it first, in the case that there are more acceleration structures than before 
   if fQueryPool<>VK_NULL_HANDLE then begin
    try
     fDevice.Commands.DestroyQueryPool(fDevice.Handle,fQueryPool,nil);
    finally
     fQueryPool:=VK_NULL_HANDLE;
    end;
   end;

   // Create or re-create query pool
   VulkanCheckResult(fDevice.Commands.CreateQueryPool(fDevice.Handle,@fQueryPoolCreateInfo,nil,@fQueryPool));
    
  end;

  // Memory barrier for acceleration structure compacted size query for to be sure that the acceleration structure is in a valid state beforehand
  FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
  MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
  MemoryBarrier.pNext:=nil;
  MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
  MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
  fDevice.Commands.CmdPipelineBarrier(aCommandBuffer.Handle,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),
                                      0,
                                      1,@MemoryBarrier,
                                      0,nil,
                                      0,nil);

  // Reset query pool
  fDevice.Commands.CmdResetQueryPool(aCommandBuffer.Handle,fQueryPool,0,fCount);

  // Write acceleration structure compacted size queries 
  fDevice.Commands.CmdWriteAccelerationStructuresPropertiesKHR(aCommandBuffer.Handle,
                                                               fCount,
                                                               @fAccelerationStructureList.ItemArray[0],
                                                               VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR,
                                                               fQueryPool,
                                                               0);

 end;

end;

procedure TpvRaytracingCompactedSizeQueryPool.GetResults;
var TemporaryAccelerationStructureIndexHashMap:TAccelerationStructureIndexHashMap;
begin
 
 // Get results of acceleration structure compacted size queries
 if fCount>0 then begin

  try 
 
   fCompactedSizes.ClearNoFree;
 
   fCompactedSizes.Resize(fCount);
 
   VulkanCheckResult(fDevice.Commands.GetQueryPoolResults(fDevice.Handle,
                                                          fQueryPool,
                                                          0,
                                                          fCount,
                                                          fCount*SizeOf(TVkDeviceSize),
                                                          @fCompactedSizes.ItemArray[0],
                                                          SizeOf(TVkDeviceSize),
                                                          TVkQueryResultFlags(VK_QUERY_RESULT_64_BIT) or TVkQueryResultFlags(VK_QUERY_RESULT_WAIT_BIT)));

   // Swap acceleration structure index hash maps
   TemporaryAccelerationStructureIndexHashMap:=fAccelerationStructureIndexHashMap;
   fAccelerationStructureIndexHashMap:=fResultAccelerationStructureIndexHashMap;
   fResultAccelerationStructureIndexHashMap:=TemporaryAccelerationStructureIndexHashMap;

   // Clear acceleration structure index hash map
   fAccelerationStructureIndexHashMap.Clear(false);

   // Clear acceleration structures
   fAccelerationStructures.ClearNoFree;
   fAccelerationStructureList.ClearNoFree;

  finally   
   fCount:=0; // Reset count, but don't clear the result list, since these will queried later after this function call
  end;                                                         

 end;

end;

function TpvRaytracingCompactedSizeQueryPool.GetCompactedSizeByIndex(const aIndex:TpvSizeInt):TVkDeviceSize;
begin
 if (aIndex>=0) and (aIndex<fCompactedSizes.Count) then begin
  result:=fCompactedSizes[aIndex];
 end else begin
  result:=0;
 end;
end;

function TpvRaytracingCompactedSizeQueryPool.GetCompactedSizeByAccelerationStructure(const aAccelerationStructure:TpvRaytracingAccelerationStructure):TVkDeviceSize;
var Index:TpvSizeInt;
begin
 Index:=fResultAccelerationStructureIndexHashMap[aAccelerationStructure.fAccelerationStructure];
 if (Index>=0) and (Index<fCompactedSizes.Count) then begin
  result:=fCompactedSizes[Index];
 end else begin
  result:=0;
 end;
end;

{ TpvRaytracingBLASGeometryInfoBufferItem }

constructor TpvRaytracingBLASGeometryInfoBufferItem.Create(const aType_:TVkUInt32;
                                                           const aObjectIndex:TVkUInt32;
                                                           const aMaterialIndex:TVkUInt32;
                                                           const aIndexOffset:TVkUInt32);
begin
 fType_:=aType_;
 fObjectIndex:=aObjectIndex;
 fMaterialIndex:=aMaterialIndex;
 fIndexOffset:=aIndexOffset;
end;

{ TpvRaytracingInstanceCustomIndexManager }

constructor TpvRaytracingInstanceCustomIndexManager.Create;
begin
 
 inherited Create;
 
 fItems:=TItemList.Create;

 fItemHashMap:=TItemHashMap.Create(-1);
 
 fFreeList.Initialize;
  
end;

destructor TpvRaytracingInstanceCustomIndexManager.Destroy;
begin

 FreeAndNil(fItems);

 FreeAndNil(fItemHashMap);

 fFreeList.Finalize;

 inherited Destroy;

end;

function TpvRaytracingInstanceCustomIndexManager.Add(const aData:TpvPtrUInt):TpvInt32;
var Index:TpvSizeInt;
    Item:PItem;
begin

 if aData>0 then begin

  if not fFreeList.Pop(result) then begin
   result:=fItems.AddNewIndex;
  end;

  if result>=(1 shl 24) then begin
   raise EpvRaytracing.Create('Instance custom index overflow, Vulkan raytracing instance custom index is limited to 24 bits');
  end;

  Item:=@fItems.ItemArray[result];
  Item^.Index:=result;
  Item^.Data:=aData;  
  
  fItemHashMap.Add(aData,result);

 end else begin
   
  result:=-1;

 end;

end;

function TpvRaytracingInstanceCustomIndexManager.RemoveData(const aData:TpvPtrUInt):boolean;
var Index:TpvSizeInt;
    Item:PItem;
begin

 result:=false;

 if aData>0 then begin

  Index:=fItemHashMap[aData];
  if Index>=0 then begin
   
   Item:=@fItems.ItemArray[Index];
   if Item^.Data=aData then begin
   
    Item^.Data:=0;
    fItemHashMap.Delete(aData);
    fFreeList.Push(Index);
    result:=true;

   end;

  end;

 end;

end;

function TpvRaytracingInstanceCustomIndexManager.RemoveIndex(const aIndex:TpvInt32):boolean;
var Item:PItem;
begin

 result:=false;

 if (aIndex>=0) and (aIndex<fItems.Count) then begin

  Item:=@fItems.ItemArray[aIndex];
  if Item^.Data>0 then begin

   fItemHashMap.Delete(Item^.Data);
   Item^.Data:=0;
   fFreeList.Push(aIndex);
   result:=true;

  end;

 end;

end;

function TpvRaytracingInstanceCustomIndexManager.GetData(const aIndex:TpvInt32):TpvPtrUInt;
begin
 if (aIndex>=0) and (aIndex<fItems.Count) then begin
  result:=fItems.ItemArray[aIndex].Data;
 end else begin
  result:=0;
 end;
end;

function TpvRaytracingInstanceCustomIndexManager.GetIndex(const aData:TpvPtrUInt):TpvInt32;
begin
 result:=fItemHashMap[aData];
end;

{ TpvRaytracingAccelerationStructureBuildQueue }

constructor TpvRaytracingAccelerationStructureBuildQueue.Create(const aDevice:TpvVulkanDevice);
begin
 inherited Create;
 fDevice:=aDevice;
 fBuildGeometryInfos:=TBuildGeometryInfos.Create;
 fBuildOffsetInfoPtrs:=TBuildOffsetInfoPtrs.Create;
end;

destructor TpvRaytracingAccelerationStructureBuildQueue.Destroy;
begin
 FreeAndNil(fBuildGeometryInfos);
 FreeAndNil(fBuildOffsetInfoPtrs);
 inherited Destroy;
end;

procedure TpvRaytracingAccelerationStructureBuildQueue.Clear;
begin
 fBuildGeometryInfos.ClearNoFree;
 fBuildOffsetInfoPtrs.ClearNoFree;
end;

function TpvRaytracingAccelerationStructureBuildQueue.Empty:Boolean;
begin
 result:=fBuildGeometryInfos.Count=0;
end;

procedure TpvRaytracingAccelerationStructureBuildQueue.Enqueue(const aBuildGeometryInfo:TVkAccelerationStructureBuildGeometryInfoKHR;
                                                               const aBuildOffsetInfoPtr:PVkAccelerationStructureBuildRangeInfoKHR);
begin
 fBuildGeometryInfos.Add(aBuildGeometryInfo);
 fBuildOffsetInfoPtrs.Add(aBuildOffsetInfoPtr);
end;

procedure TpvRaytracingAccelerationStructureBuildQueue.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
var Index:TpvSizeInt;
begin
 Assert(assigned(aCommandBuffer));
 Assert(fDevice=aCommandBuffer.Device);
 if fBuildGeometryInfos.Count>0 then begin
  Assert(fBuildGeometryInfos.Count=fBuildOffsetInfoPtrs.Count);
  try
   if assigned(pvApplication) and pvApplication.VulkanDebugging then begin
    // This is the workaround for newer vulkan validation layer versions > 1.x.275
    for Index:=0 to fBuildGeometryInfos.Count-1 do begin
     fDevice.Commands.Commands.CmdBuildAccelerationStructuresKHR(aCommandBuffer.Handle,
                                                                 1,
                                                                 @fBuildGeometryInfos.ItemArray[Index],
                                                                 @fBuildOffsetInfoPtrs.ItemArray[Index]);
    end;
   end else begin
    // This crashes newer vulkan validation layer versions > 1.x.275
    fDevice.Commands.Commands.CmdBuildAccelerationStructuresKHR(aCommandBuffer.Handle,
                                                                fBuildGeometryInfos.Count,
                                                                @fBuildGeometryInfos.ItemArray[0],
                                                                @fBuildOffsetInfoPtrs.ItemArray[0]);
   end;
  finally
   Clear;
  end; 
 end;
end;

{ TpvRaytracingAccelerationStructure }

constructor TpvRaytracingAccelerationStructure.Create(const aDevice:TpvVulkanDevice;const aAccelerationStructureType:TVkAccelerationStructureTypeKHR=TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_GENERIC_KHR));
begin

 inherited Create;

 fDevice:=aDevice;

 fAccelerationStructure:=VK_NULL_HANDLE;

 fAccelerationStructureType:=aAccelerationStructureType;

 FillChar(fBuildGeometryInfo,SizeOf(TVkAccelerationStructureBuildGeometryInfoKHR),#0);
 fBuildGeometryInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
 fBuildGeometryInfo.pNext:=nil;
 fBuildGeometryInfo.type_:=fAccelerationStructureType;
 fBuildGeometryInfo.flags:=0;
 fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
 fBuildGeometryInfo.srcAccelerationStructure:=VK_NULL_HANDLE;
 fBuildGeometryInfo.dstAccelerationStructure:=VK_NULL_HANDLE;
 fBuildGeometryInfo.geometryCount:=0;
 fBuildGeometryInfo.pGeometries:=nil;
 fBuildGeometryInfo.ppGeometries:=nil;
 fBuildGeometryInfo.scratchData.deviceAddress:=0;
 fBuildGeometryInfo.scratchData.hostAddress:=nil;

 FillChar(fBuildSizesInfo,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
 fBuildSizesInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
 fBuildSizesInfo.pNext:=nil;
 fBuildSizesInfo.accelerationStructureSize:=0;
 fBuildSizesInfo.updateScratchSize:=0;
 fBuildSizesInfo.buildScratchSize:=0;

 fGeneration:=0;

end;

destructor TpvRaytracingAccelerationStructure.Destroy;
begin
 Finalize;
 inherited Destroy;
end;

class function TpvRaytracingAccelerationStructure.Reduce(const aStructures:TpvRaytracingAccelerationStructureList):TVkAccelerationStructureBuildSizesInfoKHR;
var Index:TpvSizeInt;
    Current:TpvRaytracingAccelerationStructure;
begin
 
 FillChar(result,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
 result.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
 result.pNext:=nil;
 result.accelerationStructureSize:=0;
 result.updateScratchSize:=0;
 result.buildScratchSize:=0;

 for Index:=0 to aStructures.Count-1 do begin
  Current:=aStructures[Index];
  if assigned(Current) then begin
   result.accelerationStructureSize:=result.accelerationStructureSize+Current.fBuildSizesInfo.accelerationStructureSize;
   result.updateScratchSize:=result.updateScratchSize+Current.fBuildSizesInfo.updateScratchSize;
   result.buildScratchSize:=result.buildScratchSize+Current.fBuildSizesInfo.buildScratchSize;
  end;
 end;

end;

function TpvRaytracingAccelerationStructure.GetMemorySizes(const aCounts:PVkUInt32):TVkAccelerationStructureBuildSizesInfoKHR;
begin

 FillChar(result,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
 result.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
 result.pNext:=nil;
 result.accelerationStructureSize:=0;
 result.updateScratchSize:=0;
 result.buildScratchSize:=0;

 fDevice.Commands.Commands.GetAccelerationStructureBuildSizesKHR(fDevice.Handle,
                                                                 VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
                                                                 @fBuildGeometryInfo,
                                                                 aCounts,
                                                                 @result);

 result.accelerationStructureSize:=RoundUp64(result.accelerationStructureSize,256);                                                                
 result.updateScratchSize:=RoundUp64(result.updateScratchSize,TVkDeviceSize(fDevice.PhysicalDevice.AccelerationStructurePropertiesKHR.minAccelerationStructureScratchOffsetAlignment));
 result.buildScratchSize:=RoundUp64(result.buildScratchSize,TVkDeviceSize(fDevice.PhysicalDevice.AccelerationStructurePropertiesKHR.minAccelerationStructureScratchOffsetAlignment));

end;

procedure TpvRaytracingAccelerationStructure.Initialize(const aResultBuffer:TpvVulkanBuffer;const aResultOffset:TVkDeviceSize);
var CreateInfo:TVkAccelerationStructureCreateInfoKHR;
begin

 if fAccelerationStructure=VK_NULL_HANDLE then begin

  FillChar(CreateInfo,SizeOf(TVkAccelerationStructureCreateInfoKHR),#0);
  CreateInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR;
  CreateInfo.pNext:=nil;
  CreateInfo.type_:=fBuildGeometryInfo.type_;
  CreateInfo.size:=fBuildSizesInfo.accelerationStructureSize;
  CreateInfo.buffer:=aResultBuffer.Handle;
  CreateInfo.offset:=aResultOffset;

  VulkanCheckResult(fDevice.Commands.Commands.CreateAccelerationStructureKHR(fDevice.Handle,@CreateInfo,nil,@fAccelerationStructure));

  inc(fGeneration);

 end;

end;

procedure TpvRaytracingAccelerationStructure.Finalize;
begin
 if fAccelerationStructure<>VK_NULL_HANDLE then begin
  try
   fDevice.Commands.Commands.DestroyAccelerationStructureKHR(fDevice.Handle,fAccelerationStructure,nil);
  finally
   fAccelerationStructure:=VK_NULL_HANDLE;
  end;
 end;
end;

procedure TpvRaytracingAccelerationStructure.Build(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                   const aScratchBuffer:TpvVulkanBuffer;
                                                   const aScratchBufferOffset:TVkDeviceSize;
                                                   const aUpdate:Boolean;   
                                                   const aSourceAccelerationStructure:TpvRaytracingAccelerationStructure;
                                                   const aQueue:TpvRaytracingAccelerationStructureBuildQueue);
begin

 Assert(assigned(aCommandBuffer));
 Assert(fDevice=aCommandBuffer.Device);
 Assert(fAccelerationStructure<>VK_NULL_HANDLE);
 Assert(aScratchBuffer.Handle<>VK_NULL_HANDLE);
 Assert((not assigned(aSourceAccelerationStructure)) or (aSourceAccelerationStructure.fDevice=aCommandBuffer.Device));
 Assert((not assigned(aSourceAccelerationStructure)) or (aSourceAccelerationStructure.fAccelerationStructure<>VK_NULL_HANDLE));
 
 if aUpdate then begin

  // Update acceleration structure, either in-place or from another acceleration structure as source

  fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR);
 
  if assigned(aSourceAccelerationStructure) then begin
   fBuildGeometryInfo.srcAccelerationStructure:=aSourceAccelerationStructure.fAccelerationStructure; // Update from another acceleration structure as source
  end else begin
   fBuildGeometryInfo.srcAccelerationStructure:=fAccelerationStructure; // In-place update
  end;

 end else begin

  // Build new acceleration structure
  
  fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
  
  fBuildGeometryInfo.srcAccelerationStructure:=VK_NULL_HANDLE; // No source acceleration structure for new build

 end;

 fBuildGeometryInfo.dstAccelerationStructure:=fAccelerationStructure;
 
 fBuildGeometryInfo.scratchData.deviceAddress:=aScratchBuffer.DeviceAddress+aScratchBufferOffset;

 if assigned(aQueue) then begin

  // Enqueue build acceleration structure command to queue for parallel building

  aQueue.Enqueue(fBuildGeometryInfo,
                 fBuildOffsetInfoPtr);

 end else begin

  // Build acceleration structure directly as single command

  fDevice.Commands.Commands.CmdBuildAccelerationStructuresKHR(aCommandBuffer.Handle,
                                                              1,@fBuildGeometryInfo,                                                             
                                                              @fBuildOffsetInfoPtr);

 end;

end;

procedure TpvRaytracingAccelerationStructure.CopyFrom(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                      const aSourceAccelerationStructure:TpvRaytracingAccelerationStructure;
                                                      const aCompact:Boolean);
var CopyAccelerationStructureInfo:TVkCopyAccelerationStructureInfoKHR;
begin

 Assert(assigned(aCommandBuffer));
 Assert(assigned(aSourceAccelerationStructure));
 Assert(aSourceAccelerationStructure.fDevice=aCommandBuffer.Device);
 Assert(fDevice=aCommandBuffer.Device);
 Assert(aSourceAccelerationStructure.fAccelerationStructure<>VK_NULL_HANDLE);
 Assert(fAccelerationStructure<>VK_NULL_HANDLE);

 FillChar(CopyAccelerationStructureInfo,SizeOf(TVkCopyAccelerationStructureInfoKHR),#0);
 CopyAccelerationStructureInfo.sType:=VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR;
 CopyAccelerationStructureInfo.pNext:=nil;
 CopyAccelerationStructureInfo.src:=aSourceAccelerationStructure.AccelerationStructure;
 CopyAccelerationStructureInfo.dst:=fAccelerationStructure;
 if aCompact then begin
  CopyAccelerationStructureInfo.mode:=VK_COPY_ACCELERATION_STRUCTURE_MODE_COMPACT_KHR;
 end else begin
  CopyAccelerationStructureInfo.mode:=VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_KHR;
 end; 

 fDevice.Commands.Commands.CmdCopyAccelerationStructureKHR(aCommandBuffer.Handle,@CopyAccelerationStructureInfo);

end;

class procedure TpvRaytracingAccelerationStructure.MemoryBarrier(const aCommandBuffer:TpvVulkanCommandBuffer);
var MemoryBarrier:TVkMemoryBarrier;
begin
 
 FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
 MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
 MemoryBarrier.pNext:=nil;
 MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
 MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
 
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),
                                   0,
                                   1,@MemoryBarrier,
                                   0,nil,
                                   0,nil);

end;

{ TpvRaytracingBottomLevelAccelerationStructureGeometry }

constructor TpvRaytracingBottomLevelAccelerationStructureGeometry.Create(const aDevice:TpvVulkanDevice);
begin
 inherited Create;
 fDevice:=aDevice;
 fGeometries:=TGeometries.Create;
 fBuildOffsets:=TBuildOffsets.Create;
end;

destructor TpvRaytracingBottomLevelAccelerationStructureGeometry.Destroy;
begin
 FreeAndNil(fGeometries);
 FreeAndNil(fBuildOffsets);
 inherited Destroy;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureGeometry.AddTriangles(const aVertexBuffer:TpvVulkanBuffer;
                                                                             const aVertexOffset:TVkUInt32;
                                                                             const aVertexCount:TVkUInt32;
                                                                             const aVertexStride:TVkDeviceSize;
                                                                             const aIndexBuffer:TpvVulkanBuffer;
                                                                             const aIndexOffset:TVkUInt32;
                                                                             const aIndexCount:TVkUInt32;
                                                                             const aOpaque:Boolean;
                                                                             const aTransformBuffer:TpvVulkanBuffer;
                                                                             const aTransformOffset:TVkDeviceSize);
var Geometry:TVkAccelerationStructureGeometryKHR;
    BuildOffsetInfo:TVkAccelerationStructureBuildRangeInfoKHR;
begin

 FillChar(Geometry,SizeOf(TVkAccelerationStructureGeometryKHR),#0);
 Geometry.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
 Geometry.pNext:=nil;
 Geometry.geometryType:=TVkGeometryTypeKHR(VK_GEOMETRY_TYPE_TRIANGLES_KHR);
 Geometry.geometry.triangles.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR;
 Geometry.geometry.triangles.pNext:=nil;
 Geometry.geometry.triangles.vertexData.deviceAddress:=aVertexBuffer.DeviceAddress;
 Geometry.geometry.triangles.vertexStride:=aVertexStride;
 Geometry.geometry.triangles.maxVertex:=aVertexCount;
 Geometry.geometry.triangles.vertexFormat:=VK_FORMAT_R32G32B32_SFLOAT;
 Geometry.geometry.triangles.indexData.deviceAddress:=aIndexBuffer.DeviceAddress;
 Geometry.geometry.triangles.indexType:=TVkIndexType(VK_INDEX_TYPE_UINT32);
 if assigned(aTransformBuffer) then begin
  Geometry.geometry.triangles.transformData.deviceAddress:=aTransformBuffer.DeviceAddress;
 end else begin
  Geometry.geometry.triangles.transformData.deviceAddress:=0;
 end;
 Geometry.flags:=TVkGeometryFlagsKHR(0);
 if aOpaque then begin
  Geometry.flags:=Geometry.flags or TVkGeometryFlagsKHR(VK_GEOMETRY_OPAQUE_BIT_KHR);
 end;

 FillChar(BuildOffsetInfo,SizeOf(TVkAccelerationStructureBuildRangeInfoKHR),#0);
 BuildOffsetInfo.firstVertex:=aVertexOffset;
 BuildOffsetInfo.primitiveOffset:=aIndexOffset;
 BuildOffsetInfo.primitiveCount:=aIndexCount div 3;
 if assigned(aTransformBuffer) then begin
  BuildOffsetInfo.transformOffset:=aTransformOffset;
 end else begin
  BuildOffsetInfo.transformOffset:=0;
 end;

 fGeometries.Add(Geometry);
 fBuildOffsets.Add(BuildOffsetInfo);

end;

procedure TpvRaytracingBottomLevelAccelerationStructureGeometry.AddAABBs(const aAABBBuffer:TpvVulkanBuffer;
                                                                         const aOffset:TVkDeviceSize;
                                                                         const aCount:TVkUInt32;
                                                                         const aOpaque:Boolean;
                                                                         const aStride:TVkDeviceSize);
var Geometry:TVkAccelerationStructureGeometryKHR;
    BuildOffsetInfo:TVkAccelerationStructureBuildRangeInfoKHR;
begin

 FillChar(Geometry,SizeOf(TVkAccelerationStructureGeometryKHR),#0);
 Geometry.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
 Geometry.pNext:=nil;
 Geometry.geometryType:=TVkGeometryTypeKHR(VK_GEOMETRY_TYPE_AABBS_KHR);
 Geometry.geometry.aabbs.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR;
 Geometry.geometry.aabbs.pNext:=nil;
 Geometry.geometry.aabbs.data.deviceAddress:=aAABBBuffer.DeviceAddress;
 Geometry.geometry.aabbs.stride:=aStride;
 Geometry.flags:=TVkGeometryFlagsKHR(0);
 if aOpaque then begin
  Geometry.flags:=Geometry.flags or TVkGeometryFlagsKHR(VK_GEOMETRY_OPAQUE_BIT_KHR);
 end;

 FillChar(BuildOffsetInfo,SizeOf(TVkAccelerationStructureBuildRangeInfoKHR),#0);
 BuildOffsetInfo.firstVertex:=0;
 BuildOffsetInfo.primitiveOffset:=aOffset;
 BuildOffsetInfo.primitiveCount:=aCount;
 BuildOffsetInfo.transformOffset:=0;

 fGeometries.Add(Geometry);
 fBuildOffsets.Add(BuildOffsetInfo);

end;

{ TpvRaytracingBottomLevelAccelerationStructure }

constructor TpvRaytracingBottomLevelAccelerationStructure.Create(const aDevice:TpvVulkanDevice;
                                                                 const aGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry;
                                                                 const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                                 const aDynamicGeometry:Boolean;
                                                                 const aAccelerationStructureSize:TVkDeviceSize);
var Index:TpvSizeInt;
    MaxPrimCount:TpvUInt32DynamicArray;
begin

 inherited Create(aDevice,TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR));

 fGeometry:=aGeometry;

 fDynamicGeometry:=aDynamicGeometry;

 FillChar(fBuildGeometryInfo,SizeOf(TVkAccelerationStructureBuildGeometryInfoKHR),#0);
 fBuildGeometryInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
 fBuildGeometryInfo.pNext:=nil;
 fBuildGeometryInfo.flags:=aFlags;
 if assigned(fGeometry) then begin
  fBuildGeometryInfo.geometryCount:=fGeometry.fGeometries.Count;
  fBuildGeometryInfo.pGeometries:=@fGeometry.fGeometries.ItemArray[0];
 end; 
 fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
 fBuildGeometryInfo.type_:=TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR);
 fBuildGeometryInfo.srcAccelerationStructure:=VK_NULL_HANDLE; 

 if assigned(fGeometry) then begin

  MaxPrimCount:=nil;
  try
   
   SetLength(MaxPrimCount,fGeometry.fBuildOffsets.Count);

   for Index:=0 to fGeometry.fBuildOffsets.Count-1 do begin
    MaxPrimCount[Index]:=fGeometry.fBuildOffsets.Items[Index].primitiveCount;
   end;

   fBuildSizesInfo:=GetMemorySizes(@MaxPrimCount[0]);

  finally
   MaxPrimCount:=nil;  
  end;

  fBuildOffsetInfoPtr:=@fGeometry.fBuildOffsets.ItemArray[0];

 end else begin

  FillChar(fBuildSizesInfo,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
  fBuildSizesInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
  fBuildSizesInfo.pNext:=nil;
  fBuildSizesInfo.accelerationStructureSize:=aAccelerationStructureSize;
  fBuildSizesInfo.updateScratchSize:=0;
  fBuildSizesInfo.buildScratchSize:=0;

  fBuildOffsetInfoPtr:=nil;

 end; 

end;

destructor TpvRaytracingBottomLevelAccelerationStructure.Destroy;
begin
 inherited Destroy;
end;

procedure TpvRaytracingBottomLevelAccelerationStructure.Update(const aGeometry:TpvRaytracingBottomLevelAccelerationStructureGeometry;
                                                               const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                               const aDynamicGeometry:Boolean);
var Index:TpvSizeInt;
    MaxPrimCount:TpvUInt32DynamicArray;
begin

 fGeometry:=aGeometry;

 fDynamicGeometry:=aDynamicGeometry;

 FillChar(fBuildGeometryInfo,SizeOf(TVkAccelerationStructureBuildGeometryInfoKHR),#0);
 fBuildGeometryInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
 fBuildGeometryInfo.pNext:=nil;
 fBuildGeometryInfo.flags:=aFlags;
 if assigned(fGeometry) then begin
  fBuildGeometryInfo.geometryCount:=fGeometry.fGeometries.Count;
  fBuildGeometryInfo.pGeometries:=@fGeometry.fGeometries.ItemArray[0];
 end;
 fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
 fBuildGeometryInfo.type_:=TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR);
 fBuildGeometryInfo.srcAccelerationStructure:=VK_NULL_HANDLE;

 if assigned(fGeometry) then begin

  MaxPrimCount:=nil;
  try
   
   SetLength(MaxPrimCount,fGeometry.fBuildOffsets.Count);

   for Index:=0 to fGeometry.fBuildOffsets.Count-1 do begin
    MaxPrimCount[Index]:=fGeometry.fBuildOffsets.Items[Index].primitiveCount;
   end;

   fBuildSizesInfo:=GetMemorySizes(@MaxPrimCount[0]);

  finally
   MaxPrimCount:=nil;  
  end;

  fBuildOffsetInfoPtr:=@fGeometry.fBuildOffsets.ItemArray[0];

 end else begin

  FillChar(fBuildSizesInfo,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
  fBuildSizesInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
  fBuildSizesInfo.pNext:=nil;
  fBuildSizesInfo.accelerationStructureSize:=0;
  fBuildSizesInfo.updateScratchSize:=0;
  fBuildSizesInfo.buildScratchSize:=0;

  fBuildOffsetInfoPtr:=nil;

 end;

end;

{ TpvRaytracingBottomLevelAccelerationStructureInstance }

constructor TpvRaytracingBottomLevelAccelerationStructureInstance.Create(const aDevice:TpvVulkanDevice;
                                                                         const aTransform:TpvMatrix4x4;
                                                                         const aInstanceCustomIndex:TVkUInt32;
                                                                         const aMask:TVkUInt32;
                                                                         const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                                                                         const aFlags:TVkGeometryInstanceFlagsKHR;
                                                                         const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
                                                                         const aAccelerationStructureInstancePointer:PVkAccelerationStructureInstanceKHR);
begin

 inherited Create;

 fDevice:=aDevice;

 if assigned(aAccelerationStructureInstancePointer) then begin
  fAccelerationStructureInstancePointer:=aAccelerationStructureInstancePointer;
 end else begin
  fAccelerationStructureInstancePointer:=@fAccelerationStructureInstance;
 end;

 FillChar(fAccelerationStructureInstancePointer^,SizeOf(TVkAccelerationStructureInstanceKHR),#0);

 SetTransform(aTransform);

 fAccelerationStructureInstancePointer^.instanceCustomIndex:=aInstanceCustomIndex;
 fAccelerationStructureInstancePointer^.mask:=aMask;
 fAccelerationStructureInstancePointer^.instanceShaderBindingTableRecordOffset:=aInstanceShaderBindingTableRecordOffset;
 fAccelerationStructureInstancePointer^.flags:=aFlags;
 fAccelerationStructureInstancePointer^.accelerationStructureReference:=0;

 fAccelerationStructure:=nil;
 
 SetAccelerationStructure(aAccelerationStructure);

 fTag:=0;

end;

destructor TpvRaytracingBottomLevelAccelerationStructureInstance.Destroy;
begin
 inherited Destroy;
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetTransform:TpvMatrix4x4;
begin
{PVkTransformMatrixKHR(Pointer(@result))^:=fAccelerationStructureInstancePointer^.transform;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;}
 // Row-order => Column-order
 result.RawComponents[0,0]:=fAccelerationStructureInstancePointer^.transform.matrix[0,0];
 result.RawComponents[0,1]:=fAccelerationStructureInstancePointer^.transform.matrix[1,0];
 result.RawComponents[0,2]:=fAccelerationStructureInstancePointer^.transform.matrix[2,0];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=fAccelerationStructureInstancePointer^.transform.matrix[0,1];
 result.RawComponents[1,1]:=fAccelerationStructureInstancePointer^.transform.matrix[1,1];
 result.RawComponents[1,2]:=fAccelerationStructureInstancePointer^.transform.matrix[2,1];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=fAccelerationStructureInstancePointer^.transform.matrix[0,2];
 result.RawComponents[2,1]:=fAccelerationStructureInstancePointer^.transform.matrix[1,2];
 result.RawComponents[2,2]:=fAccelerationStructureInstancePointer^.transform.matrix[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=fAccelerationStructureInstancePointer^.transform.matrix[0,3];
 result.RawComponents[3,1]:=fAccelerationStructureInstancePointer^.transform.matrix[1,3];
 result.RawComponents[3,2]:=fAccelerationStructureInstancePointer^.transform.matrix[2,3];
 result.RawComponents[3,3]:=1.0;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetTransform(const aTransform:TpvMatrix4x4);
begin
//fAccelerationStructureInstancePointer^.transform:=PVkTransformMatrixKHR(Pointer(@aTransform))^;
 // Column-order => Row-order
 fAccelerationStructureInstancePointer^.transform.matrix[0,0]:=aTransform.RawComponents[0,0];
 fAccelerationStructureInstancePointer^.transform.matrix[0,1]:=aTransform.RawComponents[1,0];
 fAccelerationStructureInstancePointer^.transform.matrix[0,2]:=aTransform.RawComponents[2,0];
 fAccelerationStructureInstancePointer^.transform.matrix[0,3]:=aTransform.RawComponents[3,0];
 fAccelerationStructureInstancePointer^.transform.matrix[1,0]:=aTransform.RawComponents[0,1];
 fAccelerationStructureInstancePointer^.transform.matrix[1,1]:=aTransform.RawComponents[1,1];
 fAccelerationStructureInstancePointer^.transform.matrix[1,2]:=aTransform.RawComponents[2,1];
 fAccelerationStructureInstancePointer^.transform.matrix[1,3]:=aTransform.RawComponents[3,1];
 fAccelerationStructureInstancePointer^.transform.matrix[2,0]:=aTransform.RawComponents[0,2];
 fAccelerationStructureInstancePointer^.transform.matrix[2,1]:=aTransform.RawComponents[1,2];
 fAccelerationStructureInstancePointer^.transform.matrix[2,2]:=aTransform.RawComponents[2,2];
 fAccelerationStructureInstancePointer^.transform.matrix[2,3]:=aTransform.RawComponents[3,2];
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.CompareTransform(const aTransform:TpvMatrix4x4):Boolean;
begin
 result:=(fAccelerationStructureInstancePointer^.transform.matrix[0,0]=aTransform.RawComponents[0,0]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[0,1]=aTransform.RawComponents[1,0]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[0,2]=aTransform.RawComponents[2,0]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[0,3]=aTransform.RawComponents[3,0]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[1,0]=aTransform.RawComponents[0,1]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[1,1]=aTransform.RawComponents[1,1]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[1,2]=aTransform.RawComponents[2,1]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[1,3]=aTransform.RawComponents[3,1]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[2,0]=aTransform.RawComponents[0,2]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[2,1]=aTransform.RawComponents[1,2]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[2,2]=aTransform.RawComponents[2,2]) and
         (fAccelerationStructureInstancePointer^.transform.matrix[2,3]=aTransform.RawComponents[3,2]);
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetInstanceCustomIndex:TVkUInt32;
begin
 result:=fAccelerationStructureInstancePointer^.instanceCustomIndex;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetInstanceCustomIndex(const aInstanceCustomIndex:TVkUInt32);
begin
 fAccelerationStructureInstancePointer^.instanceCustomIndex:=aInstanceCustomIndex;
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetMask:TVkUInt32;
begin
 result:=fAccelerationStructureInstancePointer^.mask;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetMask(const aMask:TVkUInt32);
begin
 fAccelerationStructureInstancePointer^.mask:=aMask;
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetInstanceShaderBindingTableRecordOffset:TVkUInt32;
begin
 result:=fAccelerationStructureInstancePointer^.instanceShaderBindingTableRecordOffset;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetInstanceShaderBindingTableRecordOffset(const aInstanceShaderBindingTableRecordOffset:TVkUInt32);
begin
 fAccelerationStructureInstancePointer^.instanceShaderBindingTableRecordOffset:=aInstanceShaderBindingTableRecordOffset;
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetFlags:TVkGeometryInstanceFlagsKHR;
begin
 result:=fAccelerationStructureInstancePointer^.flags;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetFlags(const aFlags:TVkGeometryInstanceFlagsKHR);
begin
 fAccelerationStructureInstancePointer^.flags:=aFlags;
end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure;
begin
 result:=fAccelerationStructure;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetAccelerationStructure(const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure);
var AddressInfo:TVkAccelerationStructureDeviceAddressInfoKHR;
begin

 if (fAccelerationStructure<>aAccelerationStructure) then begin

  fAccelerationStructure:=aAccelerationStructure;

  if assigned(fAccelerationStructure) then begin

   FillChar(AddressInfo,SizeOf(TVkAccelerationStructureDeviceAddressInfoKHR),#0);
   AddressInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR;
   AddressInfo.pNext:=nil;
   AddressInfo.accelerationStructure:=fAccelerationStructure.AccelerationStructure;

   fAccelerationStructureInstancePointer^.accelerationStructureReference:=fDevice.Commands.Commands.GetAccelerationStructureDeviceAddressKHR(fDevice.Handle,@AddressInfo);

  end else begin

   fAccelerationStructureInstancePointer^.accelerationStructureReference:=0;

  end;

 end;

end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.ForceSetAccelerationStructure(const aAccelerationStructure:TpvRaytracingBottomLevelAccelerationStructure);
var AddressInfo:TVkAccelerationStructureDeviceAddressInfoKHR;
begin

 fAccelerationStructure:=aAccelerationStructure;

 if assigned(fAccelerationStructure) then begin

  FillChar(AddressInfo,SizeOf(TVkAccelerationStructureDeviceAddressInfoKHR),#0);
  AddressInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR;
  AddressInfo.pNext:=nil;
  AddressInfo.accelerationStructure:=fAccelerationStructure.AccelerationStructure;

  fAccelerationStructureInstancePointer^.accelerationStructureReference:=fDevice.Commands.Commands.GetAccelerationStructureDeviceAddressKHR(fDevice.Handle,@AddressInfo);

 end else begin

  fAccelerationStructureInstancePointer^.accelerationStructureReference:=0;

 end;

end;

function TpvRaytracingBottomLevelAccelerationStructureInstance.GetAccelerationStructureDeviceAddress:TVkDeviceAddress;
begin
 result:=fAccelerationStructureInstancePointer^.accelerationStructureReference;
end;

procedure TpvRaytracingBottomLevelAccelerationStructureInstance.SetAccelerationStructureDeviceAddress(const aAccelerationStructureDeviceAddress:TVkDeviceAddress);
begin
 fAccelerationStructureInstancePointer^.accelerationStructureReference:=aAccelerationStructureDeviceAddress;
end;

{ TpvRaytracingTopLevelAccelerationStructure }

constructor TpvRaytracingTopLevelAccelerationStructure.Create(const aDevice:TpvVulkanDevice;
                                                              const aInstanceAddress:TVkDeviceAddress;
                                                              const aInstanceCount:TVkUInt32;
                                                              const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                              const aDynamicGeometry:Boolean);
begin

 inherited Create(aDevice,TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR));

 fDynamicGeometry:=aDynamicGeometry;

 FillChar(fInstances,SizeOf(TVkAccelerationStructureGeometryInstancesDataKHR),#0);
 fInstances.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR; 
 fInstances.pNext:=nil;
 fInstances.arrayOfPointers:=VK_FALSE;
 fInstances.Data.deviceAddress:=aInstanceAddress;

 FillChar(fBuildOffsetInfo,SizeOf(TVkAccelerationStructureBuildRangeInfoKHR),#0);
 fBuildOffsetInfo.firstVertex:=0;
 fBuildOffsetInfo.primitiveOffset:=0;
 fBuildOffsetInfo.primitiveCount:=aInstanceCount;
 
 fBuildOffsetInfoPtr:=@fBuildOffsetInfo;

 FillChar(fGeometry,SizeOf(TVkAccelerationStructureGeometryKHR),#0);
 fGeometry.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
 fGeometry.pNext:=nil;
 fGeometry.geometryType:=TVkGeometryTypeKHR(VK_GEOMETRY_TYPE_INSTANCES_KHR);
 fGeometry.geometry.instances:=fInstances;

 fBuildGeometryInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
 fBuildGeometryInfo.pNext:=nil;
 fBuildGeometryInfo.flags:=aFlags;
 fBuildGeometryInfo.geometryCount:=1;
 fBuildGeometryInfo.pGeometries:=@fGeometry;
 fBuildGeometryInfo.mode:=TVkBuildAccelerationStructureModeKHR(VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
 fBuildGeometryInfo.type_:=TVkAccelerationStructureTypeKHR(VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR);
 fBuildGeometryInfo.srcAccelerationStructure:=VK_NULL_HANDLE;

 fCountInstances:=aInstanceCount;

 if fCountInstances>0 then begin

  fBuildSizesInfo:=GetMemorySizes(@fCountInstances);

 end else begin
  
  FillChar(fBuildSizesInfo,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
  fBuildSizesInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
  fBuildSizesInfo.pNext:=nil;
  fBuildSizesInfo.accelerationStructureSize:=0;
  fBuildSizesInfo.updateScratchSize:=0;
  fBuildSizesInfo.buildScratchSize:=0;
  
 end; 

end;

destructor TpvRaytracingTopLevelAccelerationStructure.Destroy;
begin
 inherited Destroy;
end;

procedure TpvRaytracingTopLevelAccelerationStructure.Update(const aInstanceAddress:TVkDeviceAddress;
                                                            const aInstanceCount:TVkUInt32;
                                                            const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                            const aDynamicGeometry:Boolean);
begin

 fDynamicGeometry:=aDynamicGeometry;

 FillChar(fInstances,SizeOf(TVkAccelerationStructureGeometryInstancesDataKHR),#0);
 fInstances.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR;
 fInstances.pNext:=nil;
 fInstances.arrayOfPointers:=VK_FALSE;
 fInstances.Data.deviceAddress:=aInstanceAddress;

 FillChar(fBuildOffsetInfo,SizeOf(TVkAccelerationStructureBuildRangeInfoKHR),#0);
 fBuildOffsetInfo.firstVertex:=0;
 fBuildOffsetInfo.primitiveOffset:=0;
 fBuildOffsetInfo.primitiveCount:=aInstanceCount;

 fBuildOffsetInfoPtr:=@fBuildOffsetInfo;

 FillChar(fGeometry,SizeOf(TVkAccelerationStructureGeometryKHR),#0);
 fGeometry.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
 fGeometry.pNext:=nil;
 fGeometry.geometryType:=TVkGeometryTypeKHR(VK_GEOMETRY_TYPE_INSTANCES_KHR);
 fGeometry.geometry.instances:=fInstances;

 fBuildGeometryInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
 fBuildGeometryInfo.pNext:=nil;
 fBuildGeometryInfo.flags:=aFlags;
 fBuildGeometryInfo.geometryCount:=1;

 fCountInstances:=aInstanceCount;

 if fCountInstances>0 then begin

  fBuildSizesInfo:=GetMemorySizes(@fCountInstances);

 end else begin
  
  FillChar(fBuildSizesInfo,SizeOf(TVkAccelerationStructureBuildSizesInfoKHR),#0);
  fBuildSizesInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
  fBuildSizesInfo.pNext:=nil;
  fBuildSizesInfo.accelerationStructureSize:=0;
  fBuildSizesInfo.updateScratchSize:=0;
  fBuildSizesInfo.buildScratchSize:=0;
  
 end; 

end;

procedure TpvRaytracingTopLevelAccelerationStructure.UpdateInstanceAddress(const aInstanceAddress:TVkDeviceAddress);
begin
 fInstances.Data.deviceAddress:=aInstanceAddress;
end;

{ TpvRaytracingGeometryInfoManager }

constructor TpvRaytracingGeometryInfoManager.Create;
begin
 inherited Create;
 fLock:=TPasMPCriticalSection.Create;
 fObjectList:=TObjectList.Create;
 fGeometryInfoList:=TpvRaytracingBLASGeometryInfoBufferItemList.Create;
 fGeometryInfoList.Reserve(1048576);
 fBufferRangeAllocator:=TpvBufferRangeAllocator.Create;
 fBufferRangeAllocator.OnResize:=BufferRangeAllocatorOnResize;
 fSizeDirty:=false;
 fDirty:=false;
 fOnDefragmentMove:=nil;
end;

destructor TpvRaytracingGeometryInfoManager.Destroy;
begin
 FreeAndNil(fBufferRangeAllocator);
 FreeAndNil(fGeometryInfoList);
 FreeAndNil(fObjectList);
 FreeAndNil(fLock);
 inherited Destroy;
end;

procedure TpvRaytracingGeometryInfoManager.BufferRangeAllocatorOnResize(const aSender:TpvBufferRangeAllocator;const aNewCapacity:TpvInt64);
begin
 fObjectList.Resize(aNewCapacity);
 fGeometryInfoList.Resize(aNewCapacity);
 fSizeDirty:=true;
end;

procedure TpvRaytracingGeometryInfoManager.BufferRangeAllocatorOnDefragmentMove(const aSender:TpvBufferRangeAllocator;const aOldOffset,aNewOffset,aSize:TpvInt64);
var Index:TpvSizeInt;
    Object_:TObject;
begin

 Object_:=fObjectList.Items[aOldOffset];

 // Check for overlapping moves
 if (aOldOffset<aNewOffset) and ((aOldOffset+aSize)>aNewOffset) then begin
  // Copy from front to back or back to front, depending on it is safe for overlapping moves
  if (aOldOffset+aSize)<aNewOffset then begin
   for Index:=0 to aSize-1 do begin
    fObjectList.Items[aOldOffset+Index]:=fObjectList.Items[aNewOffset+Index];
    fGeometryInfoList.Items[aOldOffset+Index]:=fGeometryInfoList.Items[aNewOffset+Index];
   end;
  end else begin
   for Index:=aSize-1 downto 0 do begin
    fObjectList.Items[aOldOffset+Index]:=fObjectList.Items[aNewOffset+Index];
    fGeometryInfoList.Items[aOldOffset+Index]:=fGeometryInfoList.Items[aNewOffset+Index];
   end;
  end;
 end else begin
  for Index:=0 to aSize-1 do begin
   fObjectList.Items[aOldOffset+Index]:=fObjectList.Items[aNewOffset+Index];
   fGeometryInfoList.Items[aOldOffset+Index]:=fGeometryInfoList.Items[aNewOffset+Index];
  end;
 end; 

 if assigned(fOnDefragmentMove) then begin
  fOnDefragmentMove(self,Object_,aOldOffset,aNewOffset,aSize);
 end;

end;

function TpvRaytracingGeometryInfoManager.AllocateGeometryInfoRange(const aObject:TObject;const aCount:TpvSizeInt):TpvSizeInt;
begin
 fLock.Acquire;
 try
  result:=fBufferRangeAllocator.Allocate(aCount);
  if result>=0 then begin
   fObjectList.Items[result]:=aObject;
   fDirty:=true;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvRaytracingGeometryInfoManager.FreeGeometryInfoRange(const aOffset:TpvSizeInt);
begin
 fLock.Acquire;
 try
  if (aOffset>=0) and (aOffset<fGeometryInfoList.Count) then begin
   fBufferRangeAllocator.Release(aOffset);
   fObjectList.Items[aOffset]:=nil;
   fDirty:=true;
  end;  
 finally
  fLock.Release;
 end;
end;

function TpvRaytracingGeometryInfoManager.GetGeometryInfo(const aIndex:TpvSizeInt):PpvRaytracingBLASGeometryInfoBufferItem;
begin
 if (aIndex>=0) and (aIndex<fGeometryInfoList.Count) then begin
  result:=@fGeometryInfoList.ItemArray[aIndex];
 end else begin
  result:=nil;
 end;
end;

procedure TpvRaytracingGeometryInfoManager.Defragment;
begin
 fLock.Acquire;
 try
  fBufferRangeAllocator.Defragment(BufferRangeAllocatorOnDefragmentMove);
  fDirty:=true;
 finally
  fLock.Release;
 end;
end;

{ TpvRaytracing.TBottomLevelAccelerationStructure.TInstance }

constructor TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.Create(const aBottomLevelAccelerationStructure:TBottomLevelAccelerationStructure;
                                                                             const aTransform:TpvMatrix4x4;
                                                                             const aInstanceCustomIndex:TVkInt32;
                                                                             const aMask:TVkUInt32;
                                                                             const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                                                                             const aFlags:TVkGeometryInstanceFlagsKHR);
var InstanceCustomIndex:TVkInt32;
begin

 inherited Create;

 fRaytracing:=aBottomLevelAccelerationStructure.fRaytracing;

 fBottomLevelAccelerationStructure:=aBottomLevelAccelerationStructure;

 fInRaytracingIndex:=-1;

 fInBottomLevelAccelerationStructureIndex:=-1;

 if aInstanceCustomIndex>=0 then begin
  InstanceCustomIndex:=aInstanceCustomIndex;
 end else begin
  InstanceCustomIndex:=fBottomLevelAccelerationStructure.fGeometryInfoBaseIndex;
  if InstanceCustomIndex>=$00800000 then begin
   InstanceCustomIndex:=$00800000;
  end;
 end;

 fAccelerationStructureInstance:=TpvRaytracingBottomLevelAccelerationStructureInstance.Create(fRaytracing.fDevice,
                                                                                              aTransform,
                                                                                              InstanceCustomIndex,
                                                                                              aMask,
                                                                                              aInstanceShaderBindingTableRecordOffset,
                                                                                              aFlags,
                                                                                              fBottomLevelAccelerationStructure.fAccelerationStructure,
                                                                                              nil);      

 repeat
  fGeneration:=TPasMPInterlocked.Increment(fRaytracing.fBottomLevelAccelerationStructureInstanceGenerationCounter);
 until fGeneration<>0;

 fLastGeneration:=0;

 fTrackedObjectInstance:=nil;
 
 fLastSyncedGeneration:=0;

end;

destructor TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.Destroy;
begin
 FreeAndNil(fAccelerationStructureInstance);
 inherited Destroy;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.AfterConstruction;
var OldPointer,NewPointer:PVkAccelerationStructureInstanceKHR;    
begin
 
 inherited AfterConstruction;

 if assigned(fRaytracing) then begin
  fRaytracing.fDataLock.AcquireWrite;
 end;
 try

  // Add to BottomLevelAccelerationStructure-own BottomLevelAccelerationStructure instance list
  if assigned(fBottomLevelAccelerationStructure) then begin
   fInBottomLevelAccelerationStructureIndex:=fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Add(self);
  end;

  // Add to global BottomLevelAccelerationStructure instance list
  if assigned(fRaytracing) then begin

   TPasMPInterlocked.Write(fRaytracing.fDirty,TPasMPBool32(true));

   fInRaytracingIndex:=fRaytracing.fBottomLevelAccelerationStructureInstanceList.Add(self);

   if fInRaytracingIndex>=0 then begin

    if fRaytracing.fGeometryOffsetArrayList.Count<=fInRaytracingIndex then begin
     fRaytracing.fGeometryOffsetArrayList.Resize(fInRaytracingIndex+1);
    end;

    fRaytracing.fGeometryOffsetArrayList[InRaytracingIndex]:=fBottomLevelAccelerationStructure.fGeometryInfoBaseIndex;

    fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.AcquireRead;
    try

     // Ensure that the acceleration structure instance list has enough space for the new acceleration structure instance
     if (fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Count<=fInRaytracingIndex) or
        (fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Count<=fInRaytracingIndex) then begin

      fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReadToWrite;
      try

       // Save old pointer to the first item of the acceleration structure instance array list
       if fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Count>0 then begin
        OldPointer:=@fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[0];
       end else begin
        OldPointer:=nil;
       end;

       fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Resize(fInRaytracingIndex+1);

       fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Resize(fInRaytracingIndex+1);

       if assigned(OldPointer) then begin

        // Get new pointer to the first item of the acceleration structure instance array list
        NewPointer:=@fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[0];

        if OldPointer<>NewPointer then begin

         // Full reassign needed, because the list has been resized with possible new memory address and the pointers to the
         // internal structures can be invalid
         fRaytracing.ReassignBottomLevelAccelerationStructureInstancePointers;

        end;

       end;

      finally
       fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.WriteToRead;
      end;

     end;

     // Copy the TpvRaytracingBottomLevelAccelerationStructureInstance own VKAccelerationStructureInstanceKHR content into
     // the global VKAccelerationStructureInstanceKHR array list
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[fInRaytracingIndex]:=fAccelerationStructureInstance.fAccelerationStructureInstance;

     // Set the acceleration structure instance pointer to the global VKAccelerationStructureInstanceKHR array list, so that
     // so that the TpvRaytracingBottomLevelAccelerationStructureInstance own VKAccelerationStructureInstanceKHR instance isn't used anymore
     // from now on. This is needed, because the global VKAccelerationStructureInstanceKHR array list is used as direct memory data source
     // for the GPU-side geometry info buffer.
     fAccelerationStructureInstance.fAccelerationStructureInstancePointer:=@fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[fInRaytracingIndex];

     // Set generation
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.ItemArray[fInRaytracingIndex]:=fGeneration;

    finally
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReleaseRead;
    end;

   end;

  end;

 finally
  if assigned(fRaytracing) then begin
   fRaytracing.fDataLock.ReleaseWrite;
  end;
 end;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.BeforeDestruction;
var OtherBLASInstance:TInstance;
begin

 if assigned(fRaytracing) then begin
  fRaytracing.fDataLock.AcquireWrite;
 end;
 try

  if assigned(fAccelerationStructureInstance) then begin

   // Copy the global VKAccelerationStructureInstanceKHR array list content back into the TpvRaytracingBottomLevelAccelerationStructureInstance
   // own VKAccelerationStructureInstanceKHR instance, for the case that the instance is destroyed and the acceleration structure instance
   // is still used by the BottomLevelAccelerationStructure instance.
   if assigned(fRaytracing) and (fInRaytracingIndex>=0) then begin
    fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.AcquireRead;
    try
     fAccelerationStructureInstance.fAccelerationStructureInstance:=fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[fInRaytracingIndex];
    finally
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReleaseRead;
    end;
   end;

   // Set the acceleration structure instance pointer back to the own VKAccelerationStructureInstanceKHR instance, so that the
   // TpvRaytracingBottomLevelAccelerationStructureInstance own VKAccelerationStructureInstanceKHR instance is used again, to avoid
   // dangling pointers.
   fAccelerationStructureInstance.fAccelerationStructureInstancePointer:=@fAccelerationStructureInstance.fAccelerationStructureInstance;

  end;

  // Remove from global BottomLevelAccelerationStructure instance list
  if assigned(fRaytracing) and (fInRaytracingIndex>=0) then begin

   TPasMPInterlocked.Write(fRaytracing.fDirty,TPasMPBool32(true));
   if (fInRaytracingIndex+1)<fRaytracing.fBottomLevelAccelerationStructureInstanceList.Count then begin

    OtherBLASInstance:=fRaytracing.fBottomLevelAccelerationStructureInstanceList.Items[fRaytracing.fBottomLevelAccelerationStructureInstanceList.Count-1];

    OtherBLASInstance.fInRaytracingIndex:=fInRaytracingIndex;

    fInRaytracingIndex:=fRaytracing.fBottomLevelAccelerationStructureInstanceList.Count-1;

    fRaytracing.fBottomLevelAccelerationStructureInstanceList.Exchange(fInRaytracingIndex,OtherBLASInstance.fInRaytracingIndex);

    fRaytracing.fGeometryOffsetArrayList.Exchange(fInRaytracingIndex,OtherBLASInstance.fInRaytracingIndex);

    fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.AcquireWrite;
    try
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Exchange(fInRaytracingIndex,OtherBLASInstance.fInRaytracingIndex);
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Exchange(fInRaytracingIndex,OtherBLASInstance.fInRaytracingIndex);
     OtherBLASInstance.fAccelerationStructureInstance.fAccelerationStructureInstancePointer:=@fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[OtherBLASInstance.fInRaytracingIndex];
     fAccelerationStructureInstance.fAccelerationStructureInstancePointer:=@fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[fInRaytracingIndex];
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Delete(fInRaytracingIndex);
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Delete(fInRaytracingIndex);
    finally
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReleaseWrite;
    end;

   end else begin

    fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.AcquireWrite;
    try
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayList.Delete(fInRaytracingIndex);
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Delete(fInRaytracingIndex);
    finally
     fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReleaseWrite;
    end;

   end;

   fRaytracing.fBottomLevelAccelerationStructureInstanceList.ExtractIndex(fInRaytracingIndex);

   fRaytracing.fGeometryOffsetArrayList.Delete(fInRaytracingIndex);

   fInRaytracingIndex:=-1;

  end;

  // Remove from BottomLevelAccelerationStructure-own BottomLevelAccelerationStructure instance list
  if assigned(fBottomLevelAccelerationStructure) and (fInBottomLevelAccelerationStructureIndex>=0) then begin
   if (fInBottomLevelAccelerationStructureIndex+1)<fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Count then begin
    OtherBLASInstance:=fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Items[fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Count-1];
    fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Exchange(fInBottomLevelAccelerationStructureIndex,OtherBLASInstance.fInBottomLevelAccelerationStructureIndex);
    OtherBLASInstance.fInBottomLevelAccelerationStructureIndex:=fInBottomLevelAccelerationStructureIndex;
    fInBottomLevelAccelerationStructureIndex:=fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Count-1;
   end;
   fBottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.ExtractIndex(fInBottomLevelAccelerationStructureIndex);
   fInBottomLevelAccelerationStructureIndex:=-1;
  end;

 finally
  if assigned(fRaytracing) then begin
   fRaytracing.fDataLock.ReleaseWrite;
  end;
 end; 

 inherited BeforeDestruction;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.NewGeneration;
begin
 if assigned(fRaytracing) then begin
  repeat
   fGeneration:=TPasMPInterlocked.Increment(fRaytracing.fBottomLevelAccelerationStructureInstanceGenerationCounter);
  until fGeneration<>0;
  if fInRaytracingIndex>=0 then begin
   fRaytracing.fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.ItemArray[fInRaytracingIndex]:=fGeneration;
  end;
 end;
end;

function TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.GetInstanceCustomIndex:TVkInt32;
var Temporary:TVkUInt32;
begin
 Temporary:=fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex;
 if (Temporary and TVkUInt32($00800000))<>0 then begin
  result:=TVkInt32(TVkUInt32(Temporary and TVkUInt32($007fffff)));
 end else begin
  result:=-1;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.SetInstanceCustomIndex(const aInstanceCustomIndex:TVkInt32);
var NewInstanceCustomIndex:TpvInt32;
begin
 NewInstanceCustomIndex:=fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex;
 if aInstanceCustomIndex>=0 then begin
  NewInstanceCustomIndex:=(TVkUInt32(aInstanceCustomIndex) and TVkUInt32($007fffff)) or TVkUInt32($00800000);
 end else{if (fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TVkUInt32($00800000))<>0 then}begin
  NewInstanceCustomIndex:=fBottomLevelAccelerationStructure.fGeometryInfoBaseIndex;
 end;
 if fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex<>NewInstanceCustomIndex then begin
  fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex:=NewInstanceCustomIndex;
  NewGeneration;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.TInstance.SetInstanceCustomIndexEx(const aInstanceCustomIndex:TVkInt32);
begin
 if aInstanceCustomIndex>=0 then begin
  fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex:=(TVkUInt32(aInstanceCustomIndex) and TVkUInt32($007fffff)) or TVkUInt32($00800000);
 end else{if (fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TVkUInt32($00800000))<>0 then}begin
  fAccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex:=fBottomLevelAccelerationStructure.fGeometryInfoBaseIndex;
 end;
end;

 { TpvRaytracing.TBottomLevelAccelerationStructure }

constructor TpvRaytracing.TBottomLevelAccelerationStructure.Create(const aBLASManager:TpvRaytracing;
                                                                   const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                                   const aDynamicGeometry:Boolean;
                                                                   const aCompactable:Boolean;
                                                                   const aAllocationGroupID:TpvUInt64;
                                                                   const aName:TpvUTF8String);
begin
 inherited Create;

 fRaytracing:=aBLASManager;
 
 fInRaytracingIndex:=-1;

 fName:=aName;

 fAllocationGroupId:=aAllocationGroupID;

 fFlags:=aFlags;

 fDynamicGeometry:=aDynamicGeometry;

 fCompactable:=aCompactable;

 fAccelerationStructureGeometry:=TpvRaytracingBottomLevelAccelerationStructureGeometry.Create(fRaytracing.fDevice);
 
 fAccelerationStructure:=nil;

 fAccelerationStructureSize:=0;

 fCompactedAccelerationStructure:=nil;

 fCompactedAccelerationStructureSize:=0;

 fBuildScratchSize:=0;

 fUpdateScratchSize:=0;

 fScratchSize:=0;

 fAccelerationStructureScratchSize:=0;
 
 fAccelerationStructureBuffer:=nil;

 fCompactedAccelerationStructureBuffer:=nil;

 fScratchOffset:=0;
 
 fScratchPass:=0;

 fGeometryInfoBaseIndex:=-1;

 fCountGeometries:=0;
 
 fBottomLevelAccelerationStructureInstanceList:=TBottomLevelAccelerationStructureInstanceList.Create(false);

 fEnqueueState:=TEnqueueState.None;

 fCompactState:=TCompactState.None;

 fInRaytracingCompactIndex:=-1;

 fGeometryInfoBufferItemList:=TpvRaytracingBLASGeometryInfoBufferItemList.Create;

end;

destructor TpvRaytracing.TBottomLevelAccelerationStructure.Destroy;
begin

 if assigned(fRaytracing) then begin

  fRaytracing.FreeAccelerationStructureConditionallyWithBuffer(fAccelerationStructure,fAccelerationStructureBuffer,VK_WHOLE_SIZE);
  if assigned(fAccelerationStructure) then begin
   fAccelerationStructure.fAccelerationStructure:=VK_NULL_HANDLE;
  end;
  fAccelerationStructureBuffer:=nil;

  fRaytracing.FreeAccelerationStructureConditionallyWithBuffer(fCompactedAccelerationStructure,fCompactedAccelerationStructureBuffer,VK_WHOLE_SIZE);
  if assigned(fCompactedAccelerationStructure) then begin
   fCompactedAccelerationStructure.fAccelerationStructure:=VK_NULL_HANDLE;
  end;
  fCompactedAccelerationStructureBuffer:=nil;

 end else begin

  if assigned(fAccelerationStructure) then begin
   fAccelerationStructure.Finalize;
  end;

  if assigned(fCompactedAccelerationStructure) then begin
   fCompactedAccelerationStructure.Finalize;
  end;

 end;

 while fBottomLevelAccelerationStructureInstanceList.Count>0 do begin
  fBottomLevelAccelerationStructureInstanceList[fBottomLevelAccelerationStructureInstanceList.Count-1].Free;
 end;

 if fGeometryInfoBaseIndex>=0 then begin
  fRaytracing.fGeometryInfoManager.FreeGeometryInfoRange(fGeometryInfoBaseIndex);
 end;

 FreeAndNil(fAccelerationStructureGeometry);

 FreeAndNil(fAccelerationStructure);

 FreeAndNil(fAccelerationStructureBuffer);

 FreeAndNil(fCompactedAccelerationStructure);

 FreeAndNil(fCompactedAccelerationStructureBuffer);

 FreeAndNil(fBottomLevelAccelerationStructureInstanceList);

 FreeAndNil(fGeometryInfoBufferItemList);

 inherited Destroy;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fRaytracing) then begin
  TPasMPInterlocked.Write(fRaytracing.fDirty,TPasMPBool32(true));
  fRaytracing.fDataLock.AcquireWrite;
  try
   fInRaytracingIndex:=fRaytracing.fBottomLevelAccelerationStructureList.Add(self);
  finally
   fRaytracing.fDataLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.BeforeDestruction;
var OtherBLAS:TBottomLevelAccelerationStructure;
begin
 if assigned(fRaytracing) and ((fInRaytracingIndex>=0) or (fInRaytracingCompactIndex>=0)) then begin

  fRaytracing.fDataLock.AcquireWrite;
  try

   if fInRaytracingIndex>=0 then begin
    TPasMPInterlocked.Write(fRaytracing.fDirty,TPasMPBool32(true));
    if (fInRaytracingIndex+1)<fRaytracing.fBottomLevelAccelerationStructureList.Count then begin
     OtherBLAS:=fRaytracing.fBottomLevelAccelerationStructureList.Items[fRaytracing.fBottomLevelAccelerationStructureList.Count-1];
     fRaytracing.fBottomLevelAccelerationStructureList.Exchange(fInRaytracingIndex,OtherBLAS.fInRaytracingIndex);
     OtherBLAS.fInRaytracingIndex:=fInRaytracingIndex;
     fInRaytracingIndex:=fRaytracing.fBottomLevelAccelerationStructureList.Count-1;
    end;
    fRaytracing.fBottomLevelAccelerationStructureList.ExtractIndex(fInRaytracingIndex);
    fInRaytracingIndex:=-1;
   end;

   if fInRaytracingCompactIndex>=0 then begin
    TPasMPInterlocked.Write(fRaytracing.fDirty,TPasMPBool32(true));
    fRaytracing.fBottomLevelAccelerationStructureCompactListLock.AcquireWrite;
    try
     if (fInRaytracingCompactIndex+1)<fRaytracing.fBottomLevelAccelerationStructureCompactList.Count then begin
      OtherBLAS:=fRaytracing.fBottomLevelAccelerationStructureCompactList.Items[fRaytracing.fBottomLevelAccelerationStructureCompactList.Count-1];
      fRaytracing.fBottomLevelAccelerationStructureCompactList.Exchange(fInRaytracingCompactIndex,OtherBLAS.fInRaytracingCompactIndex);
      OtherBLAS.fInRaytracingCompactIndex:=fInRaytracingCompactIndex;
      fInRaytracingCompactIndex:=fRaytracing.fBottomLevelAccelerationStructureCompactList.Count-1;
     end;
     fRaytracing.fBottomLevelAccelerationStructureCompactList.ExtractIndex(fInRaytracingCompactIndex);
     fInRaytracingCompactIndex:=-1;
    finally
     fRaytracing.fBottomLevelAccelerationStructureCompactListLock.ReleaseWrite;
    end;
   end;

  finally
   fRaytracing.fDataLock.ReleaseWrite;
  end;

 end;

 inherited BeforeDestruction;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.RemoveFromCompactList(const aLocking:Boolean);
var OtherBLAS:TBottomLevelAccelerationStructure;
begin

 if assigned(fRaytracing) and (fInRaytracingCompactIndex>=0) then begin

  if aLocking then begin
   fRaytracing.fBottomLevelAccelerationStructureCompactListLock.AcquireWrite;
  end;
  try

   if fInRaytracingCompactIndex>=0 then begin
    if (fInRaytracingCompactIndex+1)<fRaytracing.fBottomLevelAccelerationStructureCompactList.Count then begin
     OtherBLAS:=fRaytracing.fBottomLevelAccelerationStructureCompactList.Items[fRaytracing.fBottomLevelAccelerationStructureCompactList.Count-1];
     fRaytracing.fBottomLevelAccelerationStructureCompactList.Exchange(fInRaytracingCompactIndex,OtherBLAS.fInRaytracingCompactIndex);
     OtherBLAS.fInRaytracingCompactIndex:=fInRaytracingCompactIndex;
     fInRaytracingCompactIndex:=fRaytracing.fBottomLevelAccelerationStructureCompactList.Count-1;
    end;
    fRaytracing.fBottomLevelAccelerationStructureCompactList.ExtractIndex(fInRaytracingCompactIndex);
    fInRaytracingCompactIndex:=-1;
   end;

  finally
   if aLocking then begin
    fRaytracing.fBottomLevelAccelerationStructureCompactListLock.ReleaseWrite;
   end;
  end;

 end;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.Initialize;
begin

 if fAccelerationStructureGeometry.Geometries.Count>0 then begin

  if fGeometryInfoBaseIndex<0 then begin

   fCountGeometries:=fAccelerationStructureGeometry.Geometries.Count;

   fGeometryInfoBaseIndex:=fRaytracing.fGeometryInfoManager.AllocateGeometryInfoRange(self,fCountGeometries);

  end;

  if not assigned(fAccelerationStructure) then begin

   fAccelerationStructure:=TpvRaytracingBottomLevelAccelerationStructure.Create(fRaytracing.fDevice,
                                                                                fAccelerationStructureGeometry,
                                                                                fFlags,
                                                                                fDynamicGeometry);

   fAccelerationStructureSize:=fAccelerationStructure.BuildSizesInfo.accelerationStructureSize;

   fBuildScratchSize:=fAccelerationStructure.BuildSizesInfo.buildScratchSize;

   fUpdateScratchSize:=fAccelerationStructure.BuildSizesInfo.updateScratchSize;

   fScratchSize:=Max(fBuildScratchSize,fUpdateScratchSize);

   UpdateBuffer;

  end;

 end else begin

  if assigned(fAccelerationStructure) then begin
   fRaytracing.FreeObject(fAccelerationStructure);
  end;

  if assigned(fAccelerationStructureBuffer) then begin
   fRaytracing.FreeObject(fAccelerationStructureBuffer);
  end;

  if assigned(fCompactedAccelerationStructureBuffer) then begin
   fRaytracing.FreeObject(fCompactedAccelerationStructureBuffer);
  end;

 end;

end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.Update;
begin
 if assigned(fAccelerationStructure) then begin
  fAccelerationStructure.Update(fAccelerationStructureGeometry,
                                fFlags,
                                fDynamicGeometry);
  fAccelerationStructureSize:=fAccelerationStructure.BuildSizesInfo.accelerationStructureSize;
  fBuildScratchSize:=fAccelerationStructure.BuildSizesInfo.buildScratchSize;
  fUpdateScratchSize:=fAccelerationStructure.BuildSizesInfo.updateScratchSize;
  fScratchSize:=Max(fBuildScratchSize,fUpdateScratchSize);
  UpdateBuffer;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.UpdateBuffer;
begin

 if ((not assigned(fAccelerationStructureBuffer)) or
     (fAccelerationStructureBuffer.Size<fAccelerationStructureSize)) and
    (fAccelerationStructureSize>0) then begin

  if assigned(fAccelerationStructureBuffer) or (fAccelerationStructure.AccelerationStructure<>VK_NULL_HANDLE) then begin
   fRaytracing.FreeAccelerationStructureConditionallyWithBuffer(fAccelerationStructure,fAccelerationStructureBuffer,fAccelerationStructureSize);
  end;

  if not assigned(fAccelerationStructureBuffer) then begin
   fAccelerationStructureBuffer:=TpvVulkanBuffer.Create(fRaytracing.fDevice,
                                                        fAccelerationStructureSize,
                                                        TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                        TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                        [],
                                                        0,
                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                        0,
                                                        0,
                                                        0,
                                                        0,
                                                        0,
                                                        0,
                                                        [],
                                                        256,
                                                        fAllocationGroupID,
                                                        fName+'.BLASBuffer'
                                                       );
   fRaytracing.fDevice.DebugUtils.SetObjectName(fAccelerationStructureBuffer.Handle,VK_OBJECT_TYPE_BUFFER,fName+'.BLASBuffer');
  end;

  fAccelerationStructure.Initialize(fAccelerationStructureBuffer,0);
  fRaytracing.fDevice.DebugUtils.SetObjectName(fAccelerationStructure.fAccelerationStructure,VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR,fName+'.BLAS');

 end;

end;

function TpvRaytracing.TBottomLevelAccelerationStructure.GetGeometryInfo(const aIndex:TpvSizeInt):PpvRaytracingBLASGeometryInfoBufferItem;
begin
 if fGeometryInfoBaseIndex>=0 then begin
  result:=fRaytracing.fGeometryInfoManager.GetGeometryInfo(fGeometryInfoBaseIndex+aIndex);
 end else begin
  result:=nil;
 end; 
end;

function TpvRaytracing.TBottomLevelAccelerationStructure.AcquireInstance(const aTransform:TpvMatrix4x4;
                                                                         const aInstanceCustomIndex:TVkInt32;
                                                                         const aMask:TVkUInt32;
                                                                         const aInstanceShaderBindingTableRecordOffset:TVkUInt32;
                                                                         const aFlags:TVkGeometryInstanceFlagsKHR):TInstance;
begin
 result:=TInstance.Create(self,
                          aTransform,
                          aInstanceCustomIndex,
                          aMask,
                          aInstanceShaderBindingTableRecordOffset,
                          aFlags);
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.ReleaseInstance(const aInstance:TInstance);
begin
 aInstance.Free;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructure.Enqueue(const aUpdate:Boolean);
begin
 if fEnqueueState=TEnqueueState.None then begin
  if aUpdate then begin
   fEnqueueState:=TEnqueueState.Update;
  end else begin
   fEnqueueState:=TEnqueueState.Build;
  end;
  fRaytracing.fBottomLevelAccelerationStructureQueue.Enqueue(self);
 end;
end;    

procedure TpvRaytracing.TBottomLevelAccelerationStructure.EnqueueForCompacting;
begin
 if fRaytracing.fUseCompacting and fCompactable and (fCompactState=TCompactState.None) and (fInRaytracingCompactIndex<0) then begin
  fCompactState:=TCompactState.Query;
  fRaytracing.fBottomLevelAccelerationStructureCompactListLock.AcquireWrite;
  try
   fInRaytracingCompactIndex:=fRaytracing.fBottomLevelAccelerationStructureCompactList.Add(self);
  finally
   fRaytracing.fBottomLevelAccelerationStructureCompactListLock.ReleaseWrite;
  end;
 end;
end;

{ TpvRaytracing.TBottomLevelAccelerationStructureQueue }

constructor TpvRaytracing.TBottomLevelAccelerationStructureQueue.Create(const aRaytracing:TpvRaytracing);
begin
 inherited Create;

 fRaytracing:=aRaytracing;

 fItems:=nil;

 fCapacity:=0;
 
 fCount:=0;
 
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;

end;

destructor TpvRaytracing.TBottomLevelAccelerationStructureQueue.Destroy;
begin

 FreeAndNil(fLock);

 fItems:=nil;

 inherited Destroy;

end;

function TpvRaytracing.TBottomLevelAccelerationStructureQueue.GetItem(const aIndex:TPasMPInt32):TBottomLevelAccelerationStructure;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructureQueue.SetItem(const aIndex:TPasMPInt32;const aValue:TBottomLevelAccelerationStructure);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  fItems[aIndex]:=aValue;
 end;
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructureQueue.Clear;
begin
 TPasMPInterlocked.Write(fCount,0); 
end;

procedure TpvRaytracing.TBottomLevelAccelerationStructureQueue.Enqueue(const aBottomLevelAccelerationStructure:TBottomLevelAccelerationStructure);
var Index:TPasMPInt32;
    IsWrite:Boolean;
begin

 IsWrite:=false;

 fLock.AcquireRead;
 try

  // Atomically reserve an index for the new item.
  Index:=TPasMPInterlocked.Add(fCount,1);

  // If the index is beyond the current capacity, resize.
  if fCapacity<=Index then begin

   fLock.ReadToWrite;
   IsWrite:=true;

   // Check again, since another thread may have resized the array in the meantime.
   if fCapacity<=Index then begin

    // Calculate new capacity and ensure that it is at least as large as the index with 1.5 times the size as growth factor with rounding up.
    fCapacity:=(Index+1)+((Index+2) shr 1);

    // Resize the array.
    SetLength(fItems,fCapacity);

   end;

  end;

  // Now it is safe to store the new item.
  fItems[Index]:=aBottomLevelAccelerationStructure;

 finally
  if IsWrite then begin
   fLock.ReleaseWrite;
  end else begin
   fLock.ReleaseRead;
  end;
 end;

end;

{ TpvRaytracing }

constructor TpvRaytracing.Create(const aDevice:TpvVulkanDevice;const aCountInFlightFrames:TpvSizeInt);
var Index:TpvSizeInt;
begin

 inherited Create;

 fDevice:=aDevice;

 fCountInFlightFrames:=aCountInFlightFrames;

 fSafeRelease:=false;

 fUseCompacting:=false;

 fLock:=TPasMPCriticalSection.Create;

 fDataLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fDelayedFreeLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 
 fBottomLevelAccelerationStructureList:=TBottomLevelAccelerationStructureList.Create(false);

 fBottomLevelAccelerationStructureCompactList:=TBottomLevelAccelerationStructureList.Create(false);

 fBottomLevelAccelerationStructureCompactListLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fBottomLevelAccelerationStructureInstanceList:=TBottomLevelAccelerationStructure.TBottomLevelAccelerationStructureInstanceList.Create(false);

 fBottomLevelAccelerationStructureQueue:=TBottomLevelAccelerationStructureQueue.Create(self);

 fBottomLevelAccelerationStructureQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fBottomLevelAccelerationStructureInstanceGenerationCounter:=0;

 fBottomLevelAccelerationStructureInstanceKHRArrayList:=TpvRaytracingAccelerationStructureInstanceArrayList.Create;
 fBottomLevelAccelerationStructureInstanceKHRArrayList.CanShrink:=false;
 fBottomLevelAccelerationStructureInstanceKHRArrayList.Reserve(1048576);
//fBottomLevelAccelerationStructureInstanceKHRArrayList.Resize(1048576);

 fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList:=TpvRaytracingAccelerationStructureInstanceArrayGenerationList.Create;
 fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.CanShrink:=false;
 fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Reserve(1048576);

 for Index:=0 to fCountInFlightFrames-1 do begin
  fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists[Index]:=TpvRaytracingAccelerationStructureInstanceArrayGenerationList.Create;
  fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists[Index].Reserve(1048576);
 end;

 fBottomLevelAccelerationStructureInstanceKHRArrayListLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fGeometryInfoManager:=TpvRaytracingGeometryInfoManager.Create;
 fGeometryInfoManager.OnDefragmentMove:=GeometryInfoManagerOnDefragmentMove;

 fGeometryOffsetArrayList:=TGeometryOffsetArrayList.Create;
 fGeometryOffsetArrayList.CanShrink:=false;
 fGeometryOffsetArrayList.Reserve(1048576);

 fVulkanBufferCopyArray:=TVulkanBufferCopyArray.Create;

 fDirty:=false;

 for Index:=0 to 1 do begin
  fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[Index]:=nil;
  fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[Index]:=nil;
 end;

 fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex:=0;

 if assigned(fDevice) then begin
  fAccelerationStructureBuildQueue:=TpvRaytracingAccelerationStructureBuildQueue.Create(fDevice);
 end else begin
  fAccelerationStructureBuildQueue:=nil;
 end;

 fOnMustWaitForPreviousFrame:=nil;

 fOnUpdate:=nil;

 fUpdateRaytracingFrameDoneMask:=0;

 fEmptyInitialized:=false;

 fEmptyVertexBuffer:=nil;

 fEmptyIndexBuffer:=nil;

 fEmptyBottomLevelAccelerationStructure:=nil;

 fEmptyBottomLevelAccelerationStructureInstance:=nil;

 fEmptyBottomLevelAccelerationStructureScratchBuffer:=nil;

 fBottomLevelAccelerationStructureScratchBuffer:=nil;

 fTopLevelAccelerationStructureScratchBuffer:=nil;

 fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer:=nil;

 for Index:=Low(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers) to High(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers) do begin
  fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[Index]:=nil;
 end;

 fTopLevelAccelerationStructureBuffer:=nil;

 fTopLevelAccelerationStructure:=nil;

 for Index:=Low(fTopLevelAccelerationStructures) to High(fTopLevelAccelerationStructures) do begin
  fTopLevelAccelerationStructures[Index]:=VK_NULL_HANDLE;
 end;

 for Index:=Low(fTopLevelAccelerationStructureGenerations) to High(fTopLevelAccelerationStructureGenerations) do begin
  fTopLevelAccelerationStructureGenerations[Index]:=High(TpvUInt64);
 end;

 for Index:=0 to 1 do begin
  fDelayedFreeItemQueues[Index].Initialize;
 end; 

 fDelayedFreeItemQueueIndex:=0;

 for Index:=0 to 1 do begin
  fDelayedFreeAccelerationStructureItemQueues[Index].Initialize;
 end;

 fDelayedFreeAccelerationStructureItemQueueIndex:=0;

 fCompactedSizeQueryPool:=TpvRaytracingCompactedSizeQueryPool.Create(fDevice);

 fCompactIterationState:=TCompactIterationState.Query;

end;

destructor TpvRaytracing.Destroy;
var Index:TpvSizeInt;
    DelayedFreeItem:TDelayedFreeItem;
    DelayedFreeAccelerationStructureItem:TDelayedFreeAccelerationStructureItem;
begin

 FreeAndNil(fCompactedSizeQueryPool);

 FreeAndNil(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer);

 FreeAndNil(fTopLevelAccelerationStructureBuffer);

 FreeAndNil(fBottomLevelAccelerationStructureScratchBuffer);

 FreeAndNil(fEmptyBottomLevelAccelerationStructureInstance);

 FreeAndNil(fEmptyBottomLevelAccelerationStructure);

 FreeAndNil(fEmptyBottomLevelAccelerationStructureScratchBuffer);

 FreeAndNil(fEmptyVertexBuffer);

 FreeAndNil(fEmptyIndexBuffer);

 while fBottomLevelAccelerationStructureInstanceList.Count>0 do begin
  fBottomLevelAccelerationStructureInstanceList[fBottomLevelAccelerationStructureInstanceList.Count-1].Free;
 end;

 while fBottomLevelAccelerationStructureList.Count>0 do begin
  fBottomLevelAccelerationStructureList[fBottomLevelAccelerationStructureList.Count-1].Free;
 end;

 for Index:=0 to 1 do begin
  while fDelayedFreeAccelerationStructureItemQueues[Index].Dequeue(DelayedFreeAccelerationStructureItem) do begin
   if DelayedFreeAccelerationStructureItem.AccelerationStructure<>VK_NULL_HANDLE then begin
    fDevice.Commands.Commands.DestroyAccelerationStructureKHR(fDevice.Handle,DelayedFreeAccelerationStructureItem.AccelerationStructure,nil);
   end;
  end;
  fDelayedFreeAccelerationStructureItemQueues[Index].Finalize;
 end;

 for Index:=0 to 1 do begin
  while fDelayedFreeItemQueues[Index].Dequeue(DelayedFreeItem) do begin
   FreeAndNil(DelayedFreeItem.Object_);
  end;
  fDelayedFreeItemQueues[Index].Finalize;
 end;

 FreeAndNil(fGeometryOffsetArrayList);
 
 FreeAndNil(fGeometryInfoManager);

 FreeAndNil(fBottomLevelAccelerationStructureInstanceKHRArrayListLock);

 for Index:=0 to fCountInFlightFrames-1 do begin
  FreeAndNil(fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists[Index]);
 end;

 FreeAndNil(fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList);

 FreeAndNil(fBottomLevelAccelerationStructureInstanceKHRArrayList);

 FreeAndNil(fBottomLevelAccelerationStructureQueueLock);

 FreeAndNil(fBottomLevelAccelerationStructureQueue);

 FreeAndNil(fBottomLevelAccelerationStructureCompactListLock);

 FreeAndNil(fBottomLevelAccelerationStructureCompactList);

 FreeAndNil(fBottomLevelAccelerationStructureInstanceList);
 
 FreeAndNil(fBottomLevelAccelerationStructureList);

 FreeAndNil(fTopLevelAccelerationStructure);

 FreeAndNil(fTopLevelAccelerationStructureScratchBuffer);

 for Index:=Low(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers) to High(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers) do begin
  FreeAndNil(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[Index]);
 end;

 FreeAndNil(fAccelerationStructureBuildQueue);

 for Index:=0 to 1 do begin
  FreeAndNil(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[Index]);
  FreeAndNil(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[Index]);
 end;

 FreeAndNil(fVulkanBufferCopyArray);

 FreeAndNil(fDelayedFreeLock);

 FreeAndNil(fDataLock);

 FreeAndNil(fLock);

 inherited Destroy;
end;

function TpvRaytracing.GetTopLevelAccelerationStructure(const aIndex:TpvSizeInt):TVkAccelerationStructureKHR;
begin
 result:=fTopLevelAccelerationStructures[aIndex];
end;

procedure TpvRaytracing.SetTopLevelAccelerationStructure(const aIndex:TpvSizeInt;const aValue:TVkAccelerationStructureKHR);
begin
 fTopLevelAccelerationStructures[aIndex]:=aValue;
end;

function TpvRaytracing.GetTopLevelAccelerationStructureGeneration(const aIndex:TpvSizeInt):TpvUInt64;
begin
 result:=fTopLevelAccelerationStructureGenerations[aIndex];
end;

procedure TpvRaytracing.SetTopLevelAccelerationStructureGeneration(const aIndex:TpvSizeInt;const aValue:TpvUInt64);
begin
 fTopLevelAccelerationStructureGenerations[aIndex]:=aValue;
end;

procedure TpvRaytracing.GeometryInfoManagerOnDefragmentMove(const aSender:TpvRaytracingGeometryInfoManager;const aObject:TObject;const aOldOffset,aNewOffset,aSize:TpvInt64);
var Index,InstanceCustomIndex:TpvSizeInt;
    BLAS:TBottomLevelAccelerationStructure;
    BLASInstance:TBottomLevelAccelerationStructure.TInstance;
begin

 TPasMPInterlocked.Write(fDirty,TPasMPBool32(true));

 for Index:=0 to fBottomLevelAccelerationStructureList.Count-1 do begin
  BLAS:=fBottomLevelAccelerationStructureList.Items[Index];
  if (BLAS.fGeometryInfoBaseIndex>=0) and (BLAS.fGeometryInfoBaseIndex>=aOldOffset) and (BLAS.fGeometryInfoBaseIndex<(aOldOffset+aSize)) then begin
   BLAS.fGeometryInfoBaseIndex:=aNewOffset+(BLAS.fGeometryInfoBaseIndex-aOldOffset);
  end;
 end;

 for Index:=0 to fBottomLevelAccelerationStructureInstanceList.Count-1 do begin
  BLASInstance:=fBottomLevelAccelerationStructureInstanceList.Items[Index];
  InstanceCustomIndex:=BLASInstance.AccelerationStructureInstance.InstanceCustomIndex;
  if (InstanceCustomIndex>=0) and (InstanceCustomIndex<$00800000) and (InstanceCustomIndex>=aOldOffset) and (InstanceCustomIndex<(aOldOffset+aSize)) then begin
   InstanceCustomIndex:=aNewOffset+(InstanceCustomIndex-aOldOffset);
   if InstanceCustomIndex>=$00800000 then begin
    InstanceCustomIndex:=$00800000;
   end;
   BLASInstance.AccelerationStructureInstance.InstanceCustomIndex:=InstanceCustomIndex;
  end;
  if (fGeometryOffsetArrayList[BLASInstance.fInRaytracingIndex]>=0) and (fGeometryOffsetArrayList[BLASInstance.fInRaytracingIndex]>=aOldOffset) and (fGeometryOffsetArrayList[BLASInstance.fInRaytracingIndex]<(aOldOffset+aSize)) then begin
   fGeometryOffsetArrayList[BLASInstance.fInRaytracingIndex]:=aNewOffset+(fGeometryOffsetArrayList[BLASInstance.fInRaytracingIndex]-aOldOffset);
  end;
 end;

end;

function TpvRaytracing.AcquireBottomLevelAccelerationStructure(const aFlags:TVkBuildAccelerationStructureFlagsKHR;
                                                               const aDynamicGeometry:Boolean;
                                                               const aCompactable:Boolean;
                                                               const aAllocationGroupID:TpvUInt64;
                                                               const aName:TpvUTF8String):TBottomLevelAccelerationStructure;
begin
 result:=TBottomLevelAccelerationStructure.Create(self,
                                                  aFlags,
                                                  aDynamicGeometry,
                                                  aCompactable,
                                                  aAllocationGroupID,
                                                  aName);
end;

procedure TpvRaytracing.ReleaseBottomLevelAccelerationStructure(const aBLAS:TBottomLevelAccelerationStructure);
begin
 aBLAS.Free;
end;

procedure TpvRaytracing.Initialize;
var Index:TpvSizeInt;
begin
 if assigned(fTopLevelAccelerationStructure) then begin
  for Index:=Low(fTopLevelAccelerationStructures) to High(fTopLevelAccelerationStructures) do begin
   fTopLevelAccelerationStructures[Index]:=fTopLevelAccelerationStructure.AccelerationStructure;
  end;
  for Index:=Low(fTopLevelAccelerationStructureGenerations) to High(fTopLevelAccelerationStructureGenerations) do begin
   fTopLevelAccelerationStructureGenerations[Index]:=fTopLevelAccelerationStructure.Generation;
  end;
 end;
end;

procedure TpvRaytracing.ReassignBottomLevelAccelerationStructureInstancePointers;
var Index:TpvSizeInt;
begin
 if fBottomLevelAccelerationStructureInstanceKHRArrayList.Count>0 then begin
  Assert(fBottomLevelAccelerationStructureInstanceKHRArrayList.Count=fBottomLevelAccelerationStructureInstanceList.Count,'Different count of acceleration structure instances and BLAS instances');
  for Index:=0 to fBottomLevelAccelerationStructureInstanceKHRArrayList.Count-1 do begin
   fBottomLevelAccelerationStructureInstanceList.RawItems[Index].AccelerationStructureInstance.AccelerationStructureInstance:=@fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[Index];
  end;
 end; 
end; 

// Processes the delayed free queue, ensuring objects are only freed when their 
// delay counter reaches zero. Objects with remaining delay are re-enqueued 
// into the next queue for processing in future iterations. This mechanism 
// allows deferred destruction of objects while avoiding immediate deallocation.
// The function alternates between two queues to manage the lifecycle of delayed 
// free items efficiently.
procedure TpvRaytracing.ProcessDelayedFreeQueues;
var SourceDelayedFreeQueue,DestinationDelayedFreeQueue:PDelayedFreeItemQueue;
    DelayedFreeItem:TDelayedFreeItem;
    SourceDelayedFreeAccelerationStructureItemQueue,DestinationDelayedFreeAccelerationStructureItemQueue:PDelayedFreeAccelerationStructureItemQueue;
    DelayedFreeAccelerationStructureItem:TDelayedFreeAccelerationStructureItem;
begin

 fDelayedFreeLock.AcquireWrite;
 try

  // First do the same for the delayed free queue for objects
  begin

   // Get the current queue to process items from
   SourceDelayedFreeQueue:=@fDelayedFreeItemQueues[fDelayedFreeItemQueueIndex];

   // Get the destination queue for items that still have a delay remaining
   DestinationDelayedFreeQueue:=@fDelayedFreeItemQueues[(fDelayedFreeItemQueueIndex+1) and 1];

   // Switch to the next queue for the next iteration, by swapping the indices of the queues (0 -> 1 and 1 -> 0)
   fDelayedFreeItemQueueIndex:=(fDelayedFreeItemQueueIndex+1) and 1;

   // Process all items in the source queue
   while SourceDelayedFreeQueue^.Dequeue(DelayedFreeItem) do begin

    // If the delay counter is greater than zero, decrement and re-enqueue with keeping the order of the items, 
    // otherwise free the associated object  
    if DelayedFreeItem.Delay>0 then begin   
     dec(DelayedFreeItem.Delay);
     DestinationDelayedFreeQueue^.Enqueue(DelayedFreeItem);
    end else begin  
     FreeAndNil(DelayedFreeItem.Object_);
    end;

   end;

  end;

  // Now do the same for the delayed free queue for acceleration structures 
  begin

   // Get the current queue to process items from
   SourceDelayedFreeAccelerationStructureItemQueue:=@fDelayedFreeAccelerationStructureItemQueues[fDelayedFreeAccelerationStructureItemQueueIndex];

   // Get the destination queue for items that still have a delay remaining
   DestinationDelayedFreeAccelerationStructureItemQueue:=@fDelayedFreeAccelerationStructureItemQueues[(fDelayedFreeAccelerationStructureItemQueueIndex+1) and 1];

   // Switch to the next queue for the next iteration, by swapping the indices of the queues (0 -> 1 and 1 -> 0)
   fDelayedFreeAccelerationStructureItemQueueIndex:=(fDelayedFreeAccelerationStructureItemQueueIndex+1) and 1;

   // Process all items in the source queue
   while SourceDelayedFreeAccelerationStructureItemQueue^.Dequeue(DelayedFreeAccelerationStructureItem) do begin
    // If the delay counter is greater than zero, decrement and re-enqueue with keeping the order of the items,
    // otherwise free the associated object
    if DelayedFreeAccelerationStructureItem.Delay>0 then begin
     dec(DelayedFreeAccelerationStructureItem.Delay);
     DestinationDelayedFreeAccelerationStructureItemQueue^.Enqueue(DelayedFreeAccelerationStructureItem);
    end else begin
     if DelayedFreeAccelerationStructureItem.AccelerationStructure<>VK_NULL_HANDLE then begin
      fDevice.Commands.Commands.DestroyAccelerationStructureKHR(fDevice.Handle,DelayedFreeAccelerationStructureItem.AccelerationStructure,nil);
     end;
    end;
   end;

  end; 

 finally
  fDelayedFreeLock.ReleaseWrite;
 end;
  
end;

procedure TpvRaytracing.HostMemoryBarrier;
var MemoryBarrier:TVkMemoryBarrier;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Host memory barrier                                                     //
 /////////////////////////////////////////////////////////////////////////////

 FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
 MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
 MemoryBarrier.pNext:=nil;
 MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT);
 MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);

 fCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),
                                   0,
                                   1,
                                   @MemoryBarrier,
                                   0,
                                   nil,
                                   0,
                                   nil);

end;

procedure TpvRaytracing.WaitForPreviousFrame;
var MustWaitForPreviousFrame:Boolean;
begin

 if fSafeRelease then begin

  /////////////////////////////////////////////////////////////////////////////
  // Wait for previous frame, when there are changes in the BLAS list, since //
  // it is necessary at Vulkan, that buffers are not in use, when they are   //
  // destroyed. Therefore we should wait for the previous frame for to be    //
  // sure, that the buffers are not in use anymore.                          //
  /////////////////////////////////////////////////////////////////////////////

  MustWaitForPreviousFrame:=assigned(fOnMustWaitForPreviousFrame) and fOnMustWaitForPreviousFrame(self);

  if not fEmptyInitialized then begin
   MustWaitForPreviousFrame:=true;
  end;

  if MustWaitForPreviousFrame and assigned(pvApplication) then begin
   // Wait for previous frame, when there are changes in the BLAS list, since it is necessary at Vulkan, that buffers are not in use,
   // when they are destroyed. Therefore we should wait for the previous frame for to be sure, that the buffers are not in use anymore.
   pvApplication.WaitForPreviousFrame(true);
  end;

 end;

end;

procedure TpvRaytracing.HandleEmptyBottomLevelAccelerationStructure;
const EmptyVertex:array[0..3] of TpvUInt32=($7fc00000,$7fc00000,$7fc00000,$7fc00000); // 4x NaNs
      EmptyIndices:array[0..2] of TpvUInt32=(0,0,0); // Simple as that, only one NaN triangle with three vertices with the same NaN vertex
begin

 //////////////////////////////////////////////////////////////////////////////
 // Create empty blas with invalid geometry for empty tlas, when there are   //
 // no RaytracingActive group instance nodes.                                //
 //////////////////////////////////////////////////////////////////////////////

 if not fEmptyInitialized then begin

  fEmptyVertexBuffer:=TpvVulkanBuffer.Create(fDevice,
                                             SizeOf(EmptyVertex),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             0,
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             [],
                                             0,
                                             pvAllocationGroupIDScene3DRaytracing,
                                             'TpvRaytracing.EmptyVertexBuffer'
                                            );
  fDevice.DebugUtils.SetObjectName(fEmptyVertexBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.EmptyVertexBuffer');

  fDevice.MemoryStaging.Upload(fStagingQueue,
                               fStagingCommandBuffer,
                               fStagingFence,
                               EmptyVertex,
                               fEmptyVertexBuffer,
                               0,
                               SizeOf(EmptyVertex));

  fEmptyIndexBuffer:=TpvVulkanBuffer.Create(fDevice,
                                            SizeOf(EmptyIndices),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            0,
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                            0,
                                            0,
                                            0,
                                            0,
                                            0,
                                            0,
                                            [],
                                            0,
                                            pvAllocationGroupIDScene3DRaytracing,
                                            'TpvRaytracing.EmptyIndexBuffer'
                                           );
  fDevice.DebugUtils.SetObjectName(fEmptyIndexBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.EmptyIndexBuffer');

  fDevice.MemoryStaging.Upload(fStagingQueue,
                               fStagingCommandBuffer,
                               fStagingFence,
                               EmptyIndices,
                               fEmptyIndexBuffer,
                               0,
                               SizeOf(EmptyIndices));

  fEmptyBottomLevelAccelerationStructure:=AcquireBottomLevelAccelerationStructure(TVkBuildAccelerationStructureFlagsKHR(VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR),
                                                                                  false,
                                                                                  false,
                                                                                  pvAllocationGroupIDScene3DRaytracing,
                                                                                  'Empty');

  fEmptyBottomLevelAccelerationStructure.AccelerationStructureGeometry.AddTriangles(fEmptyVertexBuffer,
                                                                                    0,
                                                                                    3,
                                                                                    SizeOf(TpvVector4),
                                                                                    fEmptyIndexBuffer,
                                                                                    0,
                                                                                    3,
                                                                                    true,
                                                                                    nil,
                                                                                    0);

  fEmptyBottomLevelAccelerationStructure.Initialize;

  FreeAndNil(fEmptyBottomLevelAccelerationStructureScratchBuffer);

  fEmptyBottomLevelAccelerationStructureScratchBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                              Max(1,Max(fEmptyBottomLevelAccelerationStructure.BuildScratchSize,fEmptyBottomLevelAccelerationStructure.UpdateScratchSize)),
                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                              [],
                                                                              0,
                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              [],
                                                                              fDevice.PhysicalDevice.AccelerationStructurePropertiesKHR.minAccelerationStructureScratchOffsetAlignment,
                                                                              pvAllocationGroupIDScene3DRaytracing,
                                                                              'TpvRaytracing.EmptyBLASScratchBuffer');

  fDevice.DebugUtils.SetObjectName(fEmptyBottomLevelAccelerationStructureScratchBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.EmptyBLASScratchBuffer');

  fEmptyBottomLevelAccelerationStructure.AccelerationStructure.Build(fCommandBuffer,
                                                                     fEmptyBottomLevelAccelerationStructureScratchBuffer,
                                                                     0,
                                                                     false,
                                                                     nil);

  TpvRaytracingAccelerationStructure.MemoryBarrier(fCommandBuffer);

  fEmptyBottomLevelAccelerationStructureInstance:=fEmptyBottomLevelAccelerationStructure.AcquireInstance(TpvMatrix4x4.Identity,
                                                                                                         -1,
                                                                                                         $ff,
                                                                                                         0,
                                                                                                         0);

  fBottomLevelAccelerationStructureListChanged:=true;

  fEmptyInitialized:=true;

 end;

end;

procedure TpvRaytracing.ProcessCompacting;
var Index,InstanceIndex:TpvSizeInt;
    BottomLevelAccelerationStructure:TBottomLevelAccelerationStructure;
    BottomLevelAccelerationStructureInstance:TpvRaytracing.TBottomLevelAccelerationStructure.TInstance;
    First:Boolean;
    Size:TVkDeviceSize;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Compact acceleration structures                                         //
 /////////////////////////////////////////////////////////////////////////////

 if fUseCompacting then begin

  repeat

   // Compact state machine of three states for compacting acceleration structures

   case fCompactIterationState of

    // Pass #1: Query the size of the compacted acceleration structures
    TCompactIterationState.Query:begin

     fBottomLevelAccelerationStructureCompactListLock.AcquireRead;
     try

      if fBottomLevelAccelerationStructureCompactList.Count>0 then begin
       First:=true;
       for Index:=0 to fBottomLevelAccelerationStructureCompactList.Count-1 do begin
        BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureCompactList.RawItems[Index];
        if assigned(BottomLevelAccelerationStructure) and
           assigned(BottomLevelAccelerationStructure.fAccelerationStructure) and
           assigned(BottomLevelAccelerationStructure.fAccelerationStructureBuffer) and
           (not (assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructure) or
                 assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer))) and
           (BottomLevelAccelerationStructure.fCompactState=TBottomLevelAccelerationStructure.TCompactState.Query) then begin
         BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Querying;
         if First then begin
          First:=false;
          fCompactedSizeQueryPool.Reset;
         end;
         fCompactedSizeQueryPool.AddAccelerationStructure(BottomLevelAccelerationStructure.fAccelerationStructure);
        end;
       end;
       if not First then begin
        fCompactedSizeQueryPool.Query(fCommandBuffer);
        fCompactIterationState:=TCompactIterationState.Querying;
       end;
      end;

     finally
      fBottomLevelAccelerationStructureCompactListLock.ReleaseRead;
     end;

    end;

    // Pass #2: Get the results of the compacted acceleration structures and execute the compaction
    TCompactIterationState.Querying:begin

     fCompactedSizeQueryPool.GetResults;

     fBottomLevelAccelerationStructureCompactListLock.AcquireRead;
     try

      // Must traverse the list in reverse order, because we may remove items from the list
      for Index:=fBottomLevelAccelerationStructureCompactList.Count-1 downto 0 do begin

       BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureCompactList.RawItems[Index];

       if assigned(BottomLevelAccelerationStructure) and
          assigned(BottomLevelAccelerationStructure.fAccelerationStructure) and
          assigned(BottomLevelAccelerationStructure.fAccelerationStructureBuffer) and
          (not (assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructure) or
                assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer))) and
          (BottomLevelAccelerationStructure.fCompactState=TBottomLevelAccelerationStructure.TCompactState.Querying) then begin

        Size:=fCompactedSizeQueryPool.GetCompactedSizeByAccelerationStructure(BottomLevelAccelerationStructure.fAccelerationStructure);

        if Size>0 then begin

         if Size<BottomLevelAccelerationStructure.fAccelerationStructureBuffer.Size then begin

          FreeObject(BottomLevelAccelerationStructure.fCompactedAccelerationStructure);
          FreeObject(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer);

          BottomLevelAccelerationStructure.fCompactedAccelerationStructureSize:=Size;
          BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Compact;

          BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                                                         BottomLevelAccelerationStructure.fCompactedAccelerationStructureSize,
                                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                         [],
                                                                                                         0,
                                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         [],
                                                                                                         256,
                                                                                                         BottomLevelAccelerationStructure.fAllocationGroupID,
                                                                                                         BottomLevelAccelerationStructure.fName+'.BLASCompactedBuffer'
                                                                                                        );
          fDevice.DebugUtils.SetObjectName(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer.Handle,VK_OBJECT_TYPE_BUFFER,BottomLevelAccelerationStructure.fName+'.BLASCompactedBuffer');

          BottomLevelAccelerationStructure.fCompactedAccelerationStructure:=TpvRaytracingBottomLevelAccelerationStructure.Create(fDevice,
                                                                                                                                 nil,
                                                                                                                                 BottomLevelAccelerationStructure.fFlags,
                                                                                                                                 BottomLevelAccelerationStructure.fDynamicGeometry,
                                                                                                                                 BottomLevelAccelerationStructure.fCompactedAccelerationStructureSize);

          BottomLevelAccelerationStructure.fCompactedAccelerationStructure.Initialize(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer,0);

          BottomLevelAccelerationStructure.fCompactedAccelerationStructure.CopyFrom(fCommandBuffer,
                                                                                    BottomLevelAccelerationStructure.fAccelerationStructure,
                                                                                    true);

         end else begin
          fBottomLevelAccelerationStructureCompactListLock.ReadToWrite;
          try
           BottomLevelAccelerationStructure.RemoveFromCompactList(false);
          finally
           fBottomLevelAccelerationStructureCompactListLock.WriteToRead;
          end;
          BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Compacted;
         end;
        end else begin
         fBottomLevelAccelerationStructureCompactListLock.ReadToWrite;
         try
          BottomLevelAccelerationStructure.RemoveFromCompactList(false);
         finally
          fBottomLevelAccelerationStructureCompactListLock.WriteToRead;
         end;
         BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Compacted;
        end;
       end;
      end;

     finally
      fBottomLevelAccelerationStructureCompactListLock.ReleaseRead;
     end;

     TpvRaytracingAccelerationStructure.MemoryBarrier(fCommandBuffer);

     fCompactIterationState:=TCompactIterationState.Compact;

    end;

    // Pass #3: Take the compacted acceleration structures into use and free the old ones
    TCompactIterationState.Compact:begin

     fBottomLevelAccelerationStructureCompactListLock.AcquireRead;
     try

      // Must traverse the list in reverse order, because we may remove items from the list
      for Index:=fBottomLevelAccelerationStructureCompactList.Count-1 downto 0 do begin

       BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureCompactList.RawItems[Index];

       if assigned(BottomLevelAccelerationStructure) and
          assigned(BottomLevelAccelerationStructure.fAccelerationStructure) and
          assigned(BottomLevelAccelerationStructure.fAccelerationStructureBuffer) and
          assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructure) and
          assigned(BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer) and
          (BottomLevelAccelerationStructure.fCompactState=TBottomLevelAccelerationStructure.TCompactState.Compact) then begin

        fBottomLevelAccelerationStructureCompactListLock.ReadToWrite;
        try
         BottomLevelAccelerationStructure.RemoveFromCompactList(false);
        finally
         fBottomLevelAccelerationStructureCompactListLock.WriteToRead;
        end;

        BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Compacted;

        FreeAccelerationStructureConditionallyWithBuffer(BottomLevelAccelerationStructure.fAccelerationStructure,BottomLevelAccelerationStructure.fAccelerationStructureBuffer,VK_WHOLE_SIZE);

        BottomLevelAccelerationStructure.fAccelerationStructure.fAccelerationStructure:=BottomLevelAccelerationStructure.fCompactedAccelerationStructure.fAccelerationStructure;
        BottomLevelAccelerationStructure.fCompactedAccelerationStructure.fAccelerationStructure:=VK_NULL_HANDLE;
        FreeObject(BottomLevelAccelerationStructure.fCompactedAccelerationStructure);

        BottomLevelAccelerationStructure.fAccelerationStructureBuffer:=BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer;
        BottomLevelAccelerationStructure.fCompactedAccelerationStructureBuffer:=nil;

        for InstanceIndex:=0 to BottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.Count-1 do begin
         BottomLevelAccelerationStructureInstance:=BottomLevelAccelerationStructure.fBottomLevelAccelerationStructureInstanceList.RawItems[InstanceIndex];
         BottomLevelAccelerationStructureInstance.fAccelerationStructureInstance.ForceSetAccelerationStructure(BottomLevelAccelerationStructure.fAccelerationStructure);
         BottomLevelAccelerationStructureInstance.NewGeneration;
        end;

        fBottomLevelAccelerationStructureListChanged:=true;

       end;

      end;

     finally
      fBottomLevelAccelerationStructureCompactListLock.ReleaseRead;
     end;

    end;

    else begin

    end;

   end;

   break;

  until false;

 end else begin

  fBottomLevelAccelerationStructureCompactListLock.AcquireRead;
  try

   if fBottomLevelAccelerationStructureCompactList.Count>0 then begin

    // Must traverse the list in reverse order, because we may remove items from the list
    for Index:=fBottomLevelAccelerationStructureCompactList.Count-1 downto 0 do begin
     BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureCompactList.RawItems[Index];
     fBottomLevelAccelerationStructureCompactListLock.ReadToWrite;
     try
      BottomLevelAccelerationStructure.RemoveFromCompactList(false);
     finally
      fBottomLevelAccelerationStructureCompactListLock.WriteToRead;
     end;
     BottomLevelAccelerationStructure.fCompactState:=TBottomLevelAccelerationStructure.TCompactState.Compacted;
    end;

   end;

  finally
   fBottomLevelAccelerationStructureCompactListLock.ReleaseRead;
  end;

 end;

end;

procedure TpvRaytracing.ProcessContentUpdate;
begin

 //////////////////////////////////////////////////////////////////////////////
 // Call OnUpdate hook                                                       //
 //////////////////////////////////////////////////////////////////////////////

 if assigned(fOnUpdate) then begin
  fOnUpdate(self);
 end;

end;

procedure TpvRaytracing.BuildOrUpdateBottomLevelAccelerationStructureMetaData;
begin

 //////////////////////////////////////////////////////////////////////////////
 // At BLAS list changed, we have to rebuild the BLAS instances and the      //
 // BLAS geometry info buffer items and the BLAS geometry info offset buffer //
 // items.                                                                   //
 //////////////////////////////////////////////////////////////////////////////

 if (not assigned(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1])) or
    (not assigned(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1])) or
    (not assigned(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[(fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex+1) and 1])) or
    (not assigned(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[(fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex+1) and 1])) then begin
  fBottomLevelAccelerationStructureListChanged:=true;
 end;

 if fBottomLevelAccelerationStructureListChanged then begin

//RefillStructures;

  fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex:=(fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex+1) and 1;

  if (not assigned(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1])) or
     (fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1].Size<(Max(1,fGeometryOffsetArrayList.Count)*SizeOf(TVkUInt32))) then begin
   FreeObject(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1]);
   fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1]:=TpvVulkanBuffer.Create(fDevice,
                                                                                                                                                                    RoundUpToPowerOfTwo64(Max(1,fGeometryOffsetArrayList.Count)*SizeOf(TVkUInt32)*2),
                                                                                                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                                                                                    TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                                                                    [],
                                                                                                                                                                    0,
                                                                                                                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                                                                                    0,
                                                                                                                                                                    0,
                                                                                                                                                                    0,
                                                                                                                                                                    0,
                                                                                                                                                                    0,
                                                                                                                                                                    0,
                                                                                                                                                                    [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                                                                                                    0,
                                                                                                                                                                    pvAllocationGroupIDScene3DRaytracing,
                                                                                                                                                                    'TpvRaytracing.BLASGeometryInfoOffsetBufferItemBuffer'
                                                                                                                                                                   );
   fDevice.DebugUtils.SetObjectName(fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1].Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.BLASGeometryInfoOffsetBufferItemBuffer');
  end;
  if fGeometryOffsetArrayList.Count>0 then begin
   fDevice.MemoryStaging.Upload(fStagingQueue,
                                fStagingCommandBuffer,
                                fStagingFence,
                                fGeometryOffsetArrayList.ItemArray[0],
                                fBottomLevelAccelerationStructureGeometryInfoOffsetBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1],
                                0,
                                fGeometryOffsetArrayList.Count*SizeOf(TVkUInt32));
  end;

  if (not assigned(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1])) or
     (fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1].Size<(Max(1,fGeometryInfoManager.fGeometryInfoList.Count)*SizeOf(TpvRaytracingBLASGeometryInfoBufferItem))) then begin
   FreeObject(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1]);
   fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1]:=TpvVulkanBuffer.Create(fDevice,
                                                                                                                                                              RoundUpToPowerOfTwo64(Max(1,fGeometryInfoManager.fGeometryInfoList.Count)*SizeOf(TpvRaytracingBLASGeometryInfoBufferItem)*2),
                                                                                                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                                                              [],
                                                                                                                                                              0,
                                                                                                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                                                                              0,
                                                                                                                                                              0,
                                                                                                                                                              0,
                                                                                                                                                              0,
                                                                                                                                                              0,
                                                                                                                                                              0,
                                                                                                                                                              [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                                                                                              0,
                                                                                                                                                              pvAllocationGroupIDScene3DRaytracing,
                                                                                                                                                              'TpvRaytracing.BLASGeometryInfoBufferItemBuffer'
                                                                                                                                                             );
   fDevice.DebugUtils.SetObjectName(fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1].Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.BLASGeometryInfoBufferItemBuffer');
  end;
  if fGeometryInfoManager.fGeometryInfoList.Count>0 then begin
   fDevice.MemoryStaging.Upload(fStagingQueue,
                                fStagingCommandBuffer,
                                fStagingFence,
                                fGeometryInfoManager.fGeometryInfoList.ItemArray[0],
                                fBottomLevelAccelerationStructureGeometryInfoBufferItemBuffers[fBottomLevelAccelerationStructureGeometryInfoBufferRingIndex and 1],
                                0,
                                fGeometryInfoManager.fGeometryInfoList.Count*SizeOf(TpvRaytracingBLASGeometryInfoBufferItem));
  end;

 end;

end;

procedure TpvRaytracing.CollectAndCalculateSizesForAccelerationStructures;
var BLASQueueIndex:TpvSizeInt;
    BLAS:TBottomLevelAccelerationStructure;
begin

 //////////////////////////////////////////////////////////////////////////////
 // Collect and calculate sizes for acceleration structures                  //
 //////////////////////////////////////////////////////////////////////////////

 fScratchSize:=TpvUInt64(64) shl 20;

 fScratchPassSize:=0;

 fScratchPass:=0;

 for BLASQueueIndex:=0 to fBottomLevelAccelerationStructureQueue.Count-1 do begin

  BLAS:=fBottomLevelAccelerationStructureQueue.fItems[BLASQueueIndex];

  if assigned(BLAS) and (BLAS.CountGeometries>0) then begin

   BLAS.ScratchOffset:=fScratchPassSize;
   BLAS.ScratchPass:=fScratchPass;
   if BLAS.BuildScratchSize<BLAS.UpdateScratchSize then begin
    inc(fScratchPassSize,BLAS.UpdateScratchSize); // Update scratch size is bigger than build scratch size
   end else begin
    inc(fScratchPassSize,BLAS.BuildScratchSize); // Build scratch size is bigger than update scratch size
   end;
   if fScratchSize<fScratchPassSize then begin
    fScratchSize:=fScratchPassSize;
   end;
   if fScratchPassSize>=(TpvUInt64(64) shl 20) then begin
    fScratchPassSize:=0;
    inc(fScratchPass);
   end;

  end;

 end;

end;

procedure TpvRaytracing.AllocateOrGrowOrShrinkScratchBuffer;
begin

 //////////////////////////////////////////////////////////////////////////////
 // Allocate or grow or shrink scratch buffer                                //
 //////////////////////////////////////////////////////////////////////////////

 if (not assigned(fBottomLevelAccelerationStructureScratchBuffer)) or // Allocate when there is no allocated scratch buffer then
    (fBottomLevelAccelerationStructureScratchBuffer.Size<fScratchSize) or // Grow when it would be needed
    ((fScratchSize>0) and (fScratchSize<(fBottomLevelAccelerationStructureScratchBuffer.Size shr 1))) then begin // Shrink when it would be useful (when it could be smaller by at least than the half)

  FreeObject(fBottomLevelAccelerationStructureScratchBuffer);

  fBottomLevelAccelerationStructureScratchBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                         RoundUpToPowerOfTwo64(fScratchSize),
                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                         [],
                                                                         0,
                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                         0,
                                                                         0,
                                                                         0,
                                                                         0,
                                                                         0,
                                                                         0,
                                                                         [],
                                                                         fDevice.PhysicalDevice.AccelerationStructurePropertiesKHR.minAccelerationStructureScratchOffsetAlignment,
                                                                         pvAllocationGroupIDScene3DRaytracingScratch,
                                                                         'TpvRaytracing.BLASScratchBuffer'
                                                                        );
  fDevice.DebugUtils.SetObjectName(fBottomLevelAccelerationStructureScratchBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.BLASScratchBuffer');

 end;

end;

procedure TpvRaytracing.BuildOrUpdateAccelerationStructures;
var BLASQueueIndex,InstanceIndex:TpvSizeInt;
    BLAS:TBottomLevelAccelerationStructure;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Enqueue build acceleration structure commands and execute them in       //
 // batches, so that we can build the acceleration structures in parallel   //
 // but also in a way, that we can avoid that the scratch buffer may be     //
 // too large. Therefore this process is divided into multiple pass splits. //
 /////////////////////////////////////////////////////////////////////////////

 fAccelerationStructureBuildQueue.Clear;

 fScratchPass:=0;

 for BLASQueueIndex:=0 to fBottomLevelAccelerationStructureQueue.Count-1 do begin

  BLAS:=fBottomLevelAccelerationStructureQueue.fItems[BLASQueueIndex];

  if assigned(BLAS) then begin

   if BLAS.CountGeometries>0 then begin

    if fScratchPass<>BLAS.ScratchPass then begin
     if not fAccelerationStructureBuildQueue.Empty then begin
      fAccelerationStructureBuildQueue.Execute(fCommandBuffer);
      TpvRaytracingAccelerationStructure.MemoryBarrier(fCommandBuffer);
      fAccelerationStructureBuildQueue.Clear;
     end;
     fScratchPass:=BLAS.ScratchPass;
    end;
    BLAS.AccelerationStructure.Build(fCommandBuffer,
                                     fBottomLevelAccelerationStructureScratchBuffer,
                                     BLAS.ScratchOffset,
                                     BLAS.fEnqueueState=TBottomLevelAccelerationStructure.TEnqueueState.Update,
                                     nil,
                                     fAccelerationStructureBuildQueue);

    if fUseCompacting and BLAS.fCompactable and (BLAS.fEnqueueState=TBottomLevelAccelerationStructure.TEnqueueState.Build) and not BLAS.fDynamicGeometry then begin
     BLAS.EnqueueForCompacting;
    end;

    for InstanceIndex:=0 to BLAS.BottomLevelAccelerationStructureInstanceList.Count-1 do begin
     BLAS.BottomLevelAccelerationStructureInstanceList.RawItems[InstanceIndex].NewGeneration;
    end;

   end;

   BLAS.fEnqueueState:=TBottomLevelAccelerationStructure.TEnqueueState.None;

  end;

 end;

 if not fAccelerationStructureBuildQueue.Empty then begin
  fAccelerationStructureBuildQueue.Execute(fCommandBuffer);
  TpvRaytracingAccelerationStructure.MemoryBarrier(fCommandBuffer);
  fAccelerationStructureBuildQueue.Clear;
 end;

end;

procedure TpvRaytracing.UpdateBottomLevelAccelerationStructureInstancesForTopLevelAccelerationStructure;
var Index,Count,FirstIndex,LastIndex,StartIndex,CountBatchItems:TpvSizeInt;
    BufferMemoryBarriers:array[0..1] of TVkBufferMemoryBarrier;
    DestinationBuffer:TpvVulkanBuffer;
    Destination:Pointer;
    DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList:TpvRaytracingAccelerationStructureInstanceArrayGenerationList;
    DestinationBottomLevelAccelerationStructureInstanceGenerations:TpvRaytracingAccelerationStructureInstanceArrayGenerationList.TItemArray;
    SourceBottomLevelAccelerationStructureInstanceGenerations:TpvRaytracingAccelerationStructureInstanceArrayGenerationList.TItemArray;
    DestinationAccelerationStructureInstance,SourceAccelerationStructureInstance:PVkAccelerationStructureInstanceKHR;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Update BLAS instances for top level acceleration structure              //
 /////////////////////////////////////////////////////////////////////////////

 fBottomLevelAccelerationStructureInstanceKHRArrayListLock.AcquireRead;
 try

  fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize:=RoundUpToPowerOfTwo64(Max(1,fBottomLevelAccelerationStructureInstanceKHRArrayList.Count)*SizeOf(TVkAccelerationStructureInstanceKHR));

  if (not assigned(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer)) or
     (fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Size<fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize) then begin

   FreeObject(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer);

   fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                                                         fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize,
                                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                         [],
                                                                                                         0,
                                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                                         0,
                                                                                                         pvAllocationGroupIDScene3DRaytracingScratch,
                                                                                                         'TpvRaytracing.TLASBLASInstancesBuffer'
                                                                                                        );
   fDevice.DebugUtils.SetObjectName(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.TLASBLASInstancesBuffer');

   fMustUpdateTopLevelAccelerationStructure:=true;

  end;

  if (not assigned(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex])) or
     (fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Size<fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize) then begin

   FreeObject(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex]);

   fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex]:=TpvVulkanBuffer.Create(fDevice,
                                                                                                                               fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBufferSize,
                                                                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT),
                                                                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                               [],
                                                                                                                               0,
                                                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                                               0,
                                                                                                                               0,
                                                                                                                               0,
                                                                                                                               0,
                                                                                                                               0,
                                                                                                                               0,
                                                                                                                               [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                                                               0,
                                                                                                                               pvAllocationGroupIDScene3DRaytracingScratch,
                                                                                                                               'TpvRaytracing.TLASBLASInstancesBuffers['+IntToStr(fInFlightFrameIndex)+']'
                                                                                                                              );
   fDevice.DebugUtils.SetObjectName(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.TLASBLASInstancesBuffers['+IntToStr(fInFlightFrameIndex)+']');

   DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList:=fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists[fInFlightFrameIndex];
   if DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.Count>0 then begin
    FillChar(DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.ItemArray[0],DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.Count*SizeOf(TpvRaytracingBottomLevelAccelerationStructureInstanceGeneration),#0);
   end;

   fMustUpdateTopLevelAccelerationStructure:=true;

  end;

  if fBottomLevelAccelerationStructureInstanceKHRArrayList.Count>0 then begin

   fVulkanBufferCopyArray.ClearNoFree;

   DestinationBuffer:=fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex];

   if //false and
      (TpvVulkanBufferFlag.PersistentMapped in DestinationBuffer.BufferFlags) and
      ((DestinationBuffer.MemoryPropertyFlags and TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT))<>0) then begin

    Destination:=DestinationBuffer.Memory.MapMemory;
    if assigned(Destination) then begin

     try

      DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList:=fPerFlightFrameBottomLevelAccelerationStructureInstanceKHRArrayGenerationLists[fInFlightFrameIndex];

      while DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.Count<fBottomLevelAccelerationStructureInstanceKHRArrayList.Count do begin
       DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.Add(0);
      end;

      DestinationBottomLevelAccelerationStructureInstanceGenerations:=DestinationBottomLevelAccelerationStructureInstanceArrayGenerationList.ItemArray;

      SourceBottomLevelAccelerationStructureInstanceGenerations:=fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.ItemArray;

      begin

       Index:=0;
       Count:=fBottomLevelAccelerationStructureInstanceKHRArrayList.Count;
       FirstIndex:=High(TpvSizeInt);
       LastIndex:=Low(TpvSizeInt);
       StartIndex:=0;
       CountBatchItems:=0;
       while Index<Count do begin

        if DestinationBottomLevelAccelerationStructureInstanceGenerations[Index]<>SourceBottomLevelAccelerationStructureInstanceGenerations[Index] then begin

         DestinationBottomLevelAccelerationStructureInstanceGenerations[Index]:=SourceBottomLevelAccelerationStructureInstanceGenerations[Index];

         if CountBatchItems=0 then begin
          StartIndex:=Index;
         end;

         inc(CountBatchItems);

        end else begin

         if CountBatchItems>0 then begin
          if FirstIndex>StartIndex then begin
           FirstIndex:=StartIndex;
          end;
          if LastIndex<(StartIndex+(CountBatchItems-1)) then begin
           LastIndex:=StartIndex+(CountBatchItems-1);
          end;
          Move(fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[StartIndex],
               Pointer(TpvPtrUInt(TpvPtrUInt(Destination)+TpvPtrUInt(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR))))^,
               CountBatchItems*SizeOf(TVkAccelerationStructureInstanceKHR));
          fVulkanBufferCopyArray.Add(TVkBufferCopy.Create(TVkDeviceSize(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR)),
                                                          TVkDeviceSize(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR)),
                                                          CountBatchItems*SizeOf(TVkAccelerationStructureInstanceKHR)));
          CountBatchItems:=0;
         end;

        end;

        inc(Index);

       end;

      end;

      if CountBatchItems>0 then begin
       if FirstIndex>StartIndex then begin
        FirstIndex:=StartIndex;
       end;
       if LastIndex<(StartIndex+(CountBatchItems-1)) then begin
        LastIndex:=StartIndex+(CountBatchItems-1);
       end;
       Move(fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[StartIndex],
            Pointer(TpvPtrUInt(TpvPtrUInt(Destination)+TpvPtrUInt(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR))))^,
            CountBatchItems*SizeOf(TVkAccelerationStructureInstanceKHR));
       fVulkanBufferCopyArray.Add(TVkBufferCopy.Create(TVkDeviceSize(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR)),
                                                       TVkDeviceSize(StartIndex*SizeOf(TVkAccelerationStructureInstanceKHR)),
                                                       CountBatchItems*SizeOf(TVkAccelerationStructureInstanceKHR)));
       CountBatchItems:=0;
      end;

      if FirstIndex<=LastIndex then begin
       DestinationBuffer.Flush(Destination,
                               FirstIndex*SizeOf(TVkAccelerationStructureInstanceKHR),
                               ((LastIndex-FirstIndex)+1)*SizeOf(TVkAccelerationStructureInstanceKHR));
      end;

     finally
      DestinationBuffer.Memory.UnmapMemory;
     end;

    end else begin
     raise EpvVulkanException.Create('Vulkan buffer memory block map failed');
    end;

   end else begin

    fDevice.MemoryStaging.Upload(fStagingQueue,
                                 fStagingCommandBuffer,
                                 fStagingFence,
                                 fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[0],
                                 fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex],
                                 0,
                                 fBottomLevelAccelerationStructureInstanceKHRArrayList.Count*SizeOf(TVkAccelerationStructureInstanceKHR));

    fVulkanBufferCopyArray.Add(TVkBufferCopy.Create(TVkDeviceSize(0),
                                                    TVkDeviceSize(0),
                                                    fBottomLevelAccelerationStructureInstanceKHRArrayList.Count*SizeOf(TVkAccelerationStructureInstanceKHR)));

   end;

   if fVulkanBufferCopyArray.Count>0 then begin

    // Copy in-flight-frame-wise fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers to the single GPU-side fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer

    // This code ensures synchronization between the CPU and GPU by copying data from the CPU-side buffer to DestinationAccelerationStructureInstance temporary GPU-side
    // buffer, and then to the final GPU-side buffer. This avoids performance issues caused by waiting for the GPU to finish its
    // work before using the CPU-changed buffer on the GPU.

    BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or
                                                           TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                           TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT),
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Handle,
                                                           0,
                                                           fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Size);

    BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or
                                                           TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR) or
                                                           TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                                                           TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                           TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Handle,
                                                           0,
                                                           fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Size);

     fCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR),
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                       0,
                                       0,nil,
                                       2,@BufferMemoryBarriers[0],
                                       0,nil);

     if fVulkanBufferCopyArray.Count>0 then begin
      fCommandBuffer.CmdCopyBuffer(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Handle,
                                   fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Handle,
                                   fVulkanBufferCopyArray.Count,@fVulkanBufferCopyArray.ItemArray[0]);
     end;

     BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                            TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or
                                                            TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR) or
                                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                                                            TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Handle,
                                                            0,
                                                            fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.Size);

     BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT),
                                                            TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or
                                                            TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Handle,
                                                            0,
                                                            fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffers[fInFlightFrameIndex].Size);

     fCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR),
                                       0,
                                       0,nil,
                                       2,@BufferMemoryBarriers[0],
                                       0,nil);

   end;

  end;

 finally
  fBottomLevelAccelerationStructureInstanceKHRArrayListLock.ReleaseRead;
 end;

end;

procedure TpvRaytracing.CreateOrUpdateTopLevelAccelerationStructure;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Create or update top level acceleration structure                       //
 /////////////////////////////////////////////////////////////////////////////

 fMustTopLevelAccelerationStructureUpdate:=false;

 if assigned(fTopLevelAccelerationStructure) then begin

  if fBottomLevelAccelerationStructureListChanged or
     (fTopLevelAccelerationStructure.Instances.data.deviceAddress<>fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.DeviceAddress) or
     (fTopLevelAccelerationStructure.CountInstances<>fBottomLevelAccelerationStructureInstanceKHRArrayList.Count) then begin

   if (fTopLevelAccelerationStructure.Instances.data.deviceAddress<>fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.DeviceAddress) or
      (fTopLevelAccelerationStructure.CountInstances<>fBottomLevelAccelerationStructureInstanceKHRArrayList.Count) then begin
    fMustTopLevelAccelerationStructureUpdate:=true;
   end;

   fTopLevelAccelerationStructure.Update(fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.DeviceAddress,
                                         fBottomLevelAccelerationStructureInstanceKHRArrayList.Count,
                                         TVkBuildAccelerationStructureFlagsKHR(VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR),
                                         false);

  end;

 end else begin

  fTopLevelAccelerationStructure:=TpvRaytracingTopLevelAccelerationStructure.Create(fDevice,
                                                                                    fTopLevelAccelerationStructureBottomLevelAccelerationStructureInstancesBuffer.DeviceAddress,
                                                                                    fBottomLevelAccelerationStructureInstanceKHRArrayList.Count,
                                                                                    TVkBuildAccelerationStructureFlagsKHR(VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR),
                                                                                    false);

 end;

end;

procedure TpvRaytracing.AllocateOrGrowTopLevelAccelerationStructureBuffer;
var Size:TVkDeviceSize;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Allocate or grow top level acceleration structure buffer                //
 /////////////////////////////////////////////////////////////////////////////

 Size:=Max(1,fTopLevelAccelerationStructure.BuildSizesInfo.accelerationStructureSize);

 if (not assigned(fTopLevelAccelerationStructureBuffer)) or
    (fTopLevelAccelerationStructureBuffer.Size<Size) or
    fMustTopLevelAccelerationStructureUpdate then begin

  FreeAccelerationStructureConditionallyWithBuffer(fTopLevelAccelerationStructure,fTopLevelAccelerationStructureBuffer,Size);

  if not assigned(fTopLevelAccelerationStructureBuffer) then begin
   fTopLevelAccelerationStructureBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                RoundUpToPowerOfTwo64(Max(1,fTopLevelAccelerationStructure.BuildSizesInfo.accelerationStructureSize)),
                                                                TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                [],
                                                                0,
                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                [],
                                                                256,
                                                                pvAllocationGroupIDScene3DRaytracingTLAS,
                                                                'TpvRaytracing.TLASBuffer'
                                                               );
   fDevice.DebugUtils.SetObjectName(fTopLevelAccelerationStructureBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.TLASBuffer');
  end;

  fTopLevelAccelerationStructure.Initialize(fTopLevelAccelerationStructureBuffer,0);
  fDevice.DebugUtils.SetObjectName(fTopLevelAccelerationStructure.AccelerationStructure,VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR,'TpvRaytracing.TLAS');

 end;

end;

procedure TpvRaytracing.AllocateOrGrowTopLevelAccelerationStructureScratchBuffer;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Allocate or grow top level acceleration structure scratch buffer        //
 /////////////////////////////////////////////////////////////////////////////

 if (not assigned(fTopLevelAccelerationStructureScratchBuffer)) or
    (fTopLevelAccelerationStructureScratchBuffer.Size<Max(1,Max(fTopLevelAccelerationStructure.BuildSizesInfo.buildScratchSize,fTopLevelAccelerationStructure.BuildSizesInfo.updateScratchSize))) then begin

  FreeObject(fTopLevelAccelerationStructureScratchBuffer);

  fTopLevelAccelerationStructureScratchBuffer:=TpvVulkanBuffer.Create(fDevice,
                                                                      RoundUpToPowerOfTwo64(Max(1,Max(fTopLevelAccelerationStructure.BuildSizesInfo.buildScratchSize,fTopLevelAccelerationStructure.BuildSizesInfo.updateScratchSize))),
                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                      [],
                                                                      0,
                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      [],
                                                                      fDevice.PhysicalDevice.AccelerationStructurePropertiesKHR.minAccelerationStructureScratchOffsetAlignment,
                                                                      pvAllocationGroupIDScene3DRaytracingScratch,
                                                                      'TpvRaytracing.TLASScratchBuffer'
                                                                     );
  fDevice.DebugUtils.SetObjectName(fTopLevelAccelerationStructureScratchBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvRaytracing.TLASScratchBuffer');

 end;

end;

procedure TpvRaytracing.BuildOrUpdateTopLevelAccelerationStructure;
begin

 /////////////////////////////////////////////////////////////////////////////
 // Build or update top level acceleration structure                        //
 /////////////////////////////////////////////////////////////////////////////

 if fMustUpdateTopLevelAccelerationStructure or fBottomLevelAccelerationStructureListChanged then begin

  fTopLevelAccelerationStructure.Build(fCommandBuffer,
                                       fTopLevelAccelerationStructureScratchBuffer,
                                       0,
                                       false,
                                       nil);

  TpvRaytracingAccelerationStructure.MemoryBarrier(fCommandBuffer);

 end;

end;

procedure TpvRaytracing.DelayedFreeObject(const aObject:TObject;const aDelay:TpvSizeInt);
var DelayedFreeItem:TDelayedFreeItem;
begin
 if assigned(aObject) then begin
  fDelayedFreeLock.AcquireWrite;
  try
   DelayedFreeItem.Object_:=aObject;
   if aDelay<0 then begin
    DelayedFreeItem.Delay:=fCountInFlightFrames;
   end else begin 
    DelayedFreeItem.Delay:=aDelay;
   end; 
   fDelayedFreeItemQueues[fDelayedFreeItemQueueIndex and 1].Enqueue(DelayedFreeItem);
  finally
   fDelayedFreeLock.ReleaseWrite;
  end;
 end;
end;
 
procedure TpvRaytracing.DelayedFreeAccelerationStructure(const aAccelerationStructure:TVkAccelerationStructureKHR;const aDelay:TpvSizeInt);
var DelayedFreeAccelerationStructureItem:TDelayedFreeAccelerationStructureItem;
begin
 if aAccelerationStructure<>VK_NULL_HANDLE then begin
  fDelayedFreeLock.AcquireWrite;
  try
   DelayedFreeAccelerationStructureItem.AccelerationStructure:=aAccelerationStructure;
   if aDelay<0 then begin
    DelayedFreeAccelerationStructureItem.Delay:=fCountInFlightFrames;
   end else begin 
    DelayedFreeAccelerationStructureItem.Delay:=aDelay;
   end; 
   fDelayedFreeAccelerationStructureItemQueues[fDelayedFreeAccelerationStructureItemQueueIndex and 1].Enqueue(DelayedFreeAccelerationStructureItem);
  finally
   fDelayedFreeLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvRaytracing.FreeAccelerationStructureConditionallyWithBuffer(var aAccelerationStructure;var aBuffer:TpvVulkanBuffer;const aSize:TVkDeviceSize);
begin

 if assigned(TObject(aAccelerationStructure)) or (assigned(aBuffer) and ((aSize=VK_WHOLE_SIZE) or (aBuffer.Size<aSize))) then begin

  if fSafeRelease then begin

   if assigned(pvApplication) then begin
    pvApplication.WaitForPreviousFrame(true); // wait on previous frame to avoid destroy still-in-usage buffers.
   end;

   if assigned(TObject(aAccelerationStructure)) then begin
    TpvRaytracingAccelerationStructure(aAccelerationStructure).Finalize;
   end;

   if assigned(aBuffer) and ((aSize=VK_WHOLE_SIZE) or (aBuffer.Size<aSize)) then begin
    try
     aBuffer.Free;
    finally
     aBuffer:=nil;
    end;
   end;

  end else begin

   if assigned(aBuffer) and ((aSize=VK_WHOLE_SIZE) or (aBuffer.Size<aSize)) then begin
    try
     DelayedFreeObject(aBuffer,2);
    finally
     aBuffer:=nil;
    end;
   end;

   if assigned(TObject(aAccelerationStructure)) and (TpvRaytracingAccelerationStructure(aAccelerationStructure).fAccelerationStructure<>VK_NULL_HANDLE) then begin
    try
     DelayedFreeAccelerationStructure(TpvRaytracingAccelerationStructure(aAccelerationStructure).fAccelerationStructure,1);
    finally
     TpvRaytracingAccelerationStructure(aAccelerationStructure).fAccelerationStructure:=VK_NULL_HANDLE;
    end;
   end;

  end;

 end;

end;

procedure TpvRaytracing.FreeObject(var aObject);
begin

 if assigned(TObject(aObject)) then begin

  if fSafeRelease then begin

   if assigned(pvApplication) then begin
    pvApplication.WaitForPreviousFrame(true); // wait on previous frame to avoid destroy still-in-usage buffers.
   end;

   FreeAndNil(TObject(aObject));

  end else begin

   try
    DelayedFreeObject(TObject(aObject));
   finally
    TObject(aObject):=nil;
   end;

  end;

 end;

end;

procedure TpvRaytracing.Reset(const aInFlightFrameIndex:TpvSizeInt);
begin
 TPasMPInterlocked.BitwiseAnd(fUpdateRaytracingFrameDoneMask,TpvUInt32(not TpvUInt32(TpvUInt32(1) shl aInFlightFrameIndex)));
end;

procedure TpvRaytracing.MarkBottomLevelAccelerationStructureListAsChanged;
begin
 TPasMPInterlocked.Write(fBottomLevelAccelerationStructureListChanged,true);
end;

procedure TpvRaytracing.MarkTopLevelAccelerationStructureAsDirty;
begin
 TPasMPInterlocked.Write(fMustUpdateTopLevelAccelerationStructure,true);
end;

function TpvRaytracing.VerifyStructures:Boolean;
var BottomLevelAccelerationStructureIndex,GeometryIndex,InstanceIndex,
    GeometryBaseIndex,GeometryItemIndex:TpvSizeInt;
    CountBottomLevelAccelerationStructures,CountGeometryInfos,CountInstances:TpvSizeInt;
    BottomLevelAccelerationStructure:TpvRaytracing.TBottomLevelAccelerationStructure;
    BottomLevelAccelerationStructureInstance:TpvRaytracing.TBottomLevelAccelerationStructure.TInstance;
    GlobalBLASGeometryInfoBufferItem:PpvRaytracingBLASGeometryInfoBufferItem;
    LocalBLASGeometryInfoBufferItem:PpvRaytracingBLASGeometryInfoBufferItem;
    Offset:TVkUInt32;
    AddrInfo:TVkAccelerationStructureDeviceAddressInfoKHR;
    ExpectedAddr:TVkDeviceAddress;
begin  
 
 // Step 1: Verify BottomLevelAccelerationStructure list indices
 CountBottomLevelAccelerationStructures:=fBottomLevelAccelerationStructureList.Count;
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin
  if fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex].InRaytracingIndex<>BottomLevelAccelerationStructureIndex then begin
   result:=false;
   exit;
  end;
 end;

 // Step 2: Verify geometry-info ranges
 CountGeometryInfos:=fGeometryInfoManager.GeometryInfoList.Count;
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin
  BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex];
  if BottomLevelAccelerationStructure.CountGeometries>0 then begin
   if (BottomLevelAccelerationStructure.GeometryInfoBaseIndex<0) or ((BottomLevelAccelerationStructure.GeometryInfoBaseIndex+BottomLevelAccelerationStructure.CountGeometries)>CountGeometryInfos) then begin
    result:=false;
    exit;
   end;
  end else begin
   if BottomLevelAccelerationStructure.GeometryInfoBaseIndex<>-1 then begin
    result:=false;
    exit;
   end;
  end;
 end;

 // Step 3: Verify instance arrays
 CountInstances:=fBottomLevelAccelerationStructureInstanceList.Count;
 if (CountInstances<>fBottomLevelAccelerationStructureInstanceKHRArrayList.Count) or
    (CountInstances<>fBottomLevelAccelerationStructureInstanceKHRArrayGenerationList.Count) or
    (CountInstances<>fGeometryOffsetArrayList.Count) then begin
  result:=false;
  exit;
 end;

 for InstanceIndex:=0 to CountInstances-1 do begin

  BottomLevelAccelerationStructureInstance:=fBottomLevelAccelerationStructureInstanceList.Items[InstanceIndex];

  if BottomLevelAccelerationStructureInstance.fBottomLevelAccelerationStructure=fEmptyBottomLevelAccelerationStructure then begin
   // Skip the empty one
   continue;
  end;

  // a) Instance index matches
  if BottomLevelAccelerationStructureInstance.InRaytracingIndex<>InstanceIndex then begin
   result:=false;
   exit;
  end;

  // b) Geometry-offset matches BottomLevelAccelerationStructure base index
  Offset:=fGeometryOffsetArrayList[InstanceIndex];
  if Offset<>BottomLevelAccelerationStructureInstance.BottomLevelAccelerationStructure.GeometryInfoBaseIndex then begin
   result:=false;
   exit;
  end;

  // c) Pointer into the global KHR array matches
  if BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer<>@fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[InstanceIndex] then begin
   result:=false;
   exit;
  end;

  // d) Custom‑index <=> offset consistency
  if ((BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TpvUInt32($00800000))=0) and
     (BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.InstanceCustomIndex<>Offset) then begin
   result:=false;
   exit;
  end;

  // e) Make sure each instance really “sees” the same geometry‐info items
  begin
  
   // Get the base index of the geometry info item in the global list, either from the instance or from the offset, depending on if the 24th bit is
   // not set in the custom index, because when it is set, the instance custom index is used as the advanced meta data index, and the offset
   // is used as the geometry info base index.
   if (BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TpvUInt32($00800000))=0 then begin
    GeometryBaseIndex:=BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TpvUInt32($007fffff);
   end else begin
    GeometryBaseIndex:=Offset;
   end;

   for GeometryIndex:=0 to BottomLevelAccelerationStructureInstance.BottomLevelAccelerationStructure.CountGeometries-1 do begin

    // Get the index of the geometry info item in the global list
    GeometryItemIndex:=GeometryBaseIndex+GeometryIndex;
    if GeometryItemIndex>=CountGeometryInfos then begin
     result:=false;
     exit;
    end;

    // Fetch global and local item pointers
    GlobalBLASGeometryInfoBufferItem:=@fGeometryInfoManager.GeometryInfoList.ItemArray[GeometryItemIndex];
    LocalBLASGeometryInfoBufferItem:=@BottomLevelAccelerationStructureInstance.BottomLevelAccelerationStructure.GeometryInfoBufferItemList.ItemArray[GeometryIndex];

    // Compare fields
    if (GlobalBLASGeometryInfoBufferItem^.Type_<>LocalBLASGeometryInfoBufferItem^.Type_) or
       (GlobalBLASGeometryInfoBufferItem^.ObjectIndex<>LocalBLASGeometryInfoBufferItem^.ObjectIndex) or
       (GlobalBLASGeometryInfoBufferItem^.MaterialIndex<>LocalBLASGeometryInfoBufferItem^.MaterialIndex) or
       (GlobalBLASGeometryInfoBufferItem^.IndexOffset<>LocalBLASGeometryInfoBufferItem^.IndexOffset) then begin
     result:=false;
     exit;
    end;

   end;

  end;

 end;

 // Step 4: Verify geometry-info data equality
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin

  BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex];

  if BottomLevelAccelerationStructure=fEmptyBottomLevelAccelerationStructure then begin
   // Skip the empty one
   continue;
  end;

  // Local list length must equal CountGeometries
  if BottomLevelAccelerationStructure.CountGeometries<>BottomLevelAccelerationStructure.GeometryInfoBufferItemList.Count then begin
   result:=false;
   exit;
  end;

  for GeometryIndex:=0 to BottomLevelAccelerationStructure.CountGeometries-1 do begin
   
   // Fetch global item
   GlobalBLASGeometryInfoBufferItem:=fGeometryInfoManager.GetGeometryInfo(BottomLevelAccelerationStructure.GeometryInfoBaseIndex+GeometryIndex);
   
   // Fetch local item
   LocalBLASGeometryInfoBufferItem:=@BottomLevelAccelerationStructure.GeometryInfoBufferItemList.ItemArray[GeometryIndex];

   // Compare fields
   if (GlobalBLASGeometryInfoBufferItem^.Type_<>LocalBLASGeometryInfoBufferItem^.Type_) or
      (GlobalBLASGeometryInfoBufferItem^.ObjectIndex<>LocalBLASGeometryInfoBufferItem^.ObjectIndex) or
      (GlobalBLASGeometryInfoBufferItem^.MaterialIndex<>LocalBLASGeometryInfoBufferItem^.MaterialIndex) or
      (GlobalBLASGeometryInfoBufferItem^.IndexOffset<>LocalBLASGeometryInfoBufferItem^.IndexOffset) then begin
    result:=false;
    exit;
   end;

  end;

 end; 

 // Step 5: Make sure every BLAS with geometry is actually built (non‑null Vulkan handle)
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin

  BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex];

  if BottomLevelAccelerationStructure=fEmptyBottomLevelAccelerationStructure then begin
   // Skip the empty one
   continue;
  end;

  if BottomLevelAccelerationStructure.CountGeometries>0 then begin
   // If you’ve called Initialize(), Handle should be valid:
   if BottomLevelAccelerationStructure.AccelerationStructure.AccelerationStructure=VK_NULL_HANDLE then begin
    result:=false;
    exit;
   end;
  end else begin
   // Empty BLAS should either use your “empty” dummy or be VK_NULL_HANDLE
   if (BottomLevelAccelerationStructure.AccelerationStructure.AccelerationStructure<>VK_NULL_HANDLE) and
      (BottomLevelAccelerationStructure.AccelerationStructure.AccelerationStructure<>fEmptyBottomLevelAccelerationStructure.AccelerationStructure.AccelerationStructure) then begin
    result:=false;
    exit;
   end;
  end;
 end; 

 // Step 6: Verify each instance’s device‐address matches its BLAS’s device‐address
 for InstanceIndex:=0 to CountInstances-1 do begin
  BottomLevelAccelerationStructureInstance:=fBottomLevelAccelerationStructureInstanceList.Items[InstanceIndex];
  // Query the BLAS’s address:
  FillChar(AddrInfo,SizeOf(AddrInfo),#0);
  AddrInfo.sType:=VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR;
  AddrInfo.accelerationStructure:=BottomLevelAccelerationStructureInstance.BottomLevelAccelerationStructure.AccelerationStructure.AccelerationStructure;
  ExpectedAddr:=fDevice.Commands.Commands.GetAccelerationStructureDeviceAddressKHR(fDevice.Handle,@AddrInfo);
  if BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.AccelerationStructureInstance.accelerationStructureReference<>ExpectedAddr then begin
   result:=false;
   exit;
  end;
 end;

 // All checks passed
 result:=true;   

end;

// Refill structures with geometry info and instance data
procedure TpvRaytracing.RefillStructures;  
var BottomLevelAccelerationStructureIndex,GeometryIndex,InstanceIndex:TpvSizeInt;
    CountBottomLevelAccelerationStructures,CountGeometryInfos,CountInstances:TpvSizeInt;
    BottomLevelAccelerationStructure:TpvRaytracing.TBottomLevelAccelerationStructure;
    BottomLevelAccelerationStructureInstance:TpvRaytracing.TBottomLevelAccelerationStructure.TInstance;
    GlobalBLASGeometryInfoBufferItem:PpvRaytracingBLASGeometryInfoBufferItem;
    LocalBLASGeometryInfoBufferItem:PpvRaytracingBLASGeometryInfoBufferItem;
    Offset:TVkUInt32;
begin

 // Step 1: Refill BottomLevelAccelerationStructure list indices
 CountBottomLevelAccelerationStructures:=fBottomLevelAccelerationStructureList.Count;
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin
  fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex].fInRaytracingIndex:=BottomLevelAccelerationStructureIndex;
 end;

 // Step 2: Refill geometry-info ranges
 CountGeometryInfos:=fGeometryInfoManager.GeometryInfoList.Count;
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin
  BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex];
{ if BottomLevelAccelerationStructure.CountGeometries>0 then begin
   BottomLevelAccelerationStructure.GeometryInfoBaseIndex:=fGeometryInfoManager.GeometryInfoList.Items[BottomLevelAccelerationStructure.GeometryInfoBaseIndex].GeometryInfoBaseIndex;
  end else begin
   BottomLevelAccelerationStructure.GeometryInfoBaseIndex:=-1;
  end;}
 end;

 // Step 3: Refill instance arrays
 CountInstances:=fBottomLevelAccelerationStructureInstanceList.Count;
 for InstanceIndex:=0 to CountInstances-1 do begin

  BottomLevelAccelerationStructureInstance:=fBottomLevelAccelerationStructureInstanceList.Items[InstanceIndex];

  if BottomLevelAccelerationStructureInstance.fBottomLevelAccelerationStructure=fEmptyBottomLevelAccelerationStructure then begin
   // Skip the empty one
   continue;
  end;

  // a) Instance index matches
  BottomLevelAccelerationStructureInstance.fInRaytracingIndex:=InstanceIndex;

  // b) Geometry-offset matches BottomLevelAccelerationStructure base index
  Offset:=fGeometryOffsetArrayList[InstanceIndex];
  BottomLevelAccelerationStructureInstance.BottomLevelAccelerationStructure.GeometryInfoBaseIndex:=Offset;

  // c) Pointer into the global KHR array matches
  BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer:=@fBottomLevelAccelerationStructureInstanceKHRArrayList.ItemArray[InstanceIndex];

  // d) Custom‑index <=> offset consistency
  if (BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex and TpvUInt32($00800000))=0 then begin
   BottomLevelAccelerationStructureInstance.AccelerationStructureInstance.fAccelerationStructureInstancePointer^.instanceCustomIndex:=Offset;
  end;

 end; 

 // Step 4: Refill geometry-info data equality
 for BottomLevelAccelerationStructureIndex:=0 to CountBottomLevelAccelerationStructures-1 do begin

  BottomLevelAccelerationStructure:=fBottomLevelAccelerationStructureList.Items[BottomLevelAccelerationStructureIndex];

  if BottomLevelAccelerationStructure=fEmptyBottomLevelAccelerationStructure then begin
   // Skip the empty one
   continue;
  end;

  // Local list length must equal CountGeometries
  if BottomLevelAccelerationStructure.CountGeometries<>BottomLevelAccelerationStructure.GeometryInfoBufferItemList.Count then begin
   continue;
  end;

  for GeometryIndex:=0 to BottomLevelAccelerationStructure.CountGeometries-1 do begin
   
   // Fetch global item
   GlobalBLASGeometryInfoBufferItem:=fGeometryInfoManager.GetGeometryInfo(BottomLevelAccelerationStructure.GeometryInfoBaseIndex+GeometryIndex);
   
   // Fetch local item
   LocalBLASGeometryInfoBufferItem:=@BottomLevelAccelerationStructure.GeometryInfoBufferItemList.ItemArray[GeometryIndex];

   // Refill fields
   GlobalBLASGeometryInfoBufferItem^.Type_:=LocalBLASGeometryInfoBufferItem^.Type_;
   GlobalBLASGeometryInfoBufferItem^.ObjectIndex:=LocalBLASGeometryInfoBufferItem^.ObjectIndex;
   GlobalBLASGeometryInfoBufferItem^.MaterialIndex:=LocalBLASGeometryInfoBufferItem^.MaterialIndex;
   GlobalBLASGeometryInfoBufferItem^.IndexOffset:=LocalBLASGeometryInfoBufferItem^.IndexOffset;

  end;

 end;

end;

procedure TpvRaytracing.Update(const aStagingQueue:TpvVulkanQueue;
                               const aStagingCommandBuffer:TpvVulkanCommandBuffer;
                               const aStagingFence:TpvVulkanFence;
                               const aCommandBuffer:TpvVulkanCommandBuffer;
                               const aInFlightFrameIndex:TpvSizeInt;
                               const aLabels:Boolean);
var FrameDoneMask:TpvUInt32;
begin

 fStagingQueue:=aStagingQueue;

 fStagingCommandBuffer:=aStagingCommandBuffer;

 fStagingFence:=aStagingFence;

 fCommandBuffer:=aCommandBuffer;

 fInFlightFrameIndex:=aInFlightFrameIndex;

 FrameDoneMask:=TpvUInt32(1) shl aInFlightFrameIndex;

 if (TPasMPInterlocked.ExchangeBitwiseOr(fUpdateRaytracingFrameDoneMask,FrameDoneMask) and FrameDoneMask)=0 then begin

  fLock.Acquire;
  try

   fBottomLevelAccelerationStructureQueue.Clear;

   if aLabels then begin
    fDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvRaytracing.Update',[1.0,0.5,0.25,1.0]);
   end;

   fBottomLevelAccelerationStructureListChanged:=false; // Assume, that the BLAS list has not changed yet

   fMustUpdateTopLevelAccelerationStructure:=false;

   ProcessDelayedFreeQueues;

   HostMemoryBarrier;

   WaitForPreviousFrame;

   HandleEmptyBottomLevelAccelerationStructure;

   ProcessCompacting;

   ProcessContentUpdate;

   fDataLock.AcquireRead;
   try

    BuildOrUpdateBottomLevelAccelerationStructureMetaData;

    CollectAndCalculateSizesForAccelerationStructures;

    AllocateOrGrowOrShrinkScratchBuffer;

    BuildOrUpdateAccelerationStructures;

    UpdateBottomLevelAccelerationStructureInstancesForTopLevelAccelerationStructure;

    CreateOrUpdateTopLevelAccelerationStructure;

    AllocateOrGrowTopLevelAccelerationStructureBuffer;

    AllocateOrGrowTopLevelAccelerationStructureScratchBuffer;

    BuildOrUpdateTopLevelAccelerationStructure;

{   if fBottomLevelAccelerationStructureListChanged then begin
     VerifyStructures;
    end;//}

   finally
    fDataLock.ReleaseRead;
   end;

   if aLabels then begin
    fDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);
   end;

  finally
   fLock.Release;
  end;

 end;

end;

end.
