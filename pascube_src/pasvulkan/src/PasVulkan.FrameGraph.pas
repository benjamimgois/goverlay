(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.FrameFrame.pas                 *
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
unit PasVulkan.FrameGraph;
{$i PasVulkan.inc}
{$ifdef fpc}
 {$packset fixed}
{$else}
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
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Utils,
     PasVulkan.HighResolutionTimer,
     PasVulkan.TimerQuery,
     PasVulkan.NVIDIA.AfterMath;

// Inspired from:
//   https://www.ea.com/frostbite/news/framegraph-extensible-rendering-architecture-in-frostbite
//   https://www.gdcvault.com/play/1024612/FrameGraph-Extensible-Rendering-Architecture-in
//   https://www.slideshare.net/DICEStudio/framegraph-extensible-rendering-architecture-in-frostbite
//   http://themaister.net/blog/2017/08/15/render-graphs-and-vulkan-a-deep-dive/

// Attention: It is still work in progress

type EpvFrameGraph=class(Exception);

     EpvFrameGraphEmptyName=class(EpvFrameGraph);

     EpvFrameGraphDuplicateName=class(EpvFrameGraph);

     EpvFrameGraphMissingExplicitPassDependency=class(EpvFrameGraph);

     EpvFrameGraphMissingQueue=class(EpvFrameGraph);

     EpvFrameGraphMismatchImageSize=class(EpvFrameGraph);

     EpvFrameGraphMismatchImageLayout=class(EpvFrameGraph);

     EpvFrameGraphMissedGeneratorPassForResource=class(EpvFrameGraph);

     EpvFrameGraphResourceUsedAsInputAndOutputInTheSamePassAtTheSameTime=class(EpvFrameGraph);

     EpvFrameGraphRecursion=class(EpvFrameGraph);

     TpvFrameGraph=class
      public
       const UsedAsImageDepthInputAttachmentFlag=1 shl 0;
             UsedAsImageDepthInputNonAttachmentFlag=1 shl 1;
             ForbiddenUsedImageDepthInputFlagCombination=UsedAsImageDepthInputAttachmentFlag or UsedAsImageDepthInputNonAttachmentFlag;
       type PpvVulkanSemaphore=^TpvVulkanSemaphore;
            TpvVulkanSemaphorePointers=TpvDynamicArray<PpvVulkanSemaphore>;
            TpvVkSemaphorePointers=TpvDynamicArray<PVkSemaphore>;
            TVulkanSemaphores=TpvDynamicArray<TpvVulkanSemaphore>;
            TVulkanSemaphoreHandles=TpvDynamicArray<TVkSemaphore>;
            TVkPipelineStageFlagsDynamicArray=TpvDynamicArray<TVkPipelineStageFlags>;
            TBufferSubresourceRange=record
             public
              Offset:TVkDeviceSize;
              Range:TVkDeviceSize;
              constructor Create(const aOffset,aRange:TVkDeviceSize);
            end;
            PBufferSubresourceRange=^TBufferSubresourceRange;
            TResourceInstanceType=
             (
              Default,
              SingleInstance,
              InstancePerInFlightFrame
             );
            TLoadOp=record
             public
              type TLoadOpKind=
                    (
                     Load,
                     Clear,
                     DontCare
                    );
                    TKind=TLoadOpKind;
              const Values:array[TLoadOpKind] of TVkAttachmentLoadOp=
                     (
                      VK_ATTACHMENT_LOAD_OP_LOAD,
                      VK_ATTACHMENT_LOAD_OP_CLEAR,
                      VK_ATTACHMENT_LOAD_OP_DONT_CARE
                     );
             public
              Kind:TKind;
              ClearColor:TpvVector4;
              constructor Create(const aKind:TKind); overload;
              constructor Create(const aKind:TKind;
                                 const aClearColor:TpvVector4); overload;
            end;
            PLoadOp=^TLoadOp;
            TStoreOp=record
             public
              type TStoreOpKind=
                    (
                     Store,
                     DontCare
                    );
                   TKind=TStoreOpKind;
              const Values:array[TKind] of TVkAttachmentStoreOp=
                     (
                      VK_ATTACHMENT_STORE_OP_STORE,
                      VK_ATTACHMENT_STORE_OP_DONT_CARE
                     );
             public
              Kind:TKind;
              constructor Create(const aKind:TKind);
            end;
            PStoreOp=^TStoreOp;
            TImageType=
             (
              Undefined,
              Surface,
              Color,
              Depth,
              DepthStencil,
              Stencil
             );
            TImageTypeHelper=record helper for TImageType
             public
              class function From(const aFormat:TVkFormat):TImageType; static;
              function GetAspectMask:TVkImageAspectFlags;
            end;
            PImageType=^TImageType;
            TImageSize=packed record
             public
              type TImageSizeKind=
                    (
                     Undefined,
                     Absolute,
                     SurfaceDependent,
                     SurfaceDependentPreviousPowerOfTwo,
                     SurfaceDependentNextPowerOfTwo,
                     SurfaceDependentNearestPowerOfTwo
                    );
                   PImageSizeKind=^TImageSizeKind;
                   TKind=TImageSizeKind;
                   PKind=^TKind;
             public
              Kind:TKind;
              Size:TpvVector4;
              class function CreateEmpty:TImageSize; static;
              constructor Create(const aKind:TImageSize.TKind;
                                 const aWidth:tpvFloat=1.0;
                                 const aHeight:TpvFloat=1.0;
                                 const aDepth:TpvFloat=1.0;
                                 const aLayers:TpvFloat=0.0); overload;
              constructor Create(const aKind:TImageSize.TKind;
                                 const aSize:TpvVector2;
                                 const aDepth:TpvFloat=1.0;
                                 const aLayers:TpvFloat=0.0); overload;
              constructor Create(const aKind:TImageSize.TKind;
                                 const aSize:TpvVector3;
                                 const aLayers:TpvFloat=0.0); overload;
              constructor Create(const aKind:TImageSize.TKind;
                                 const aSize:TpvVector4); overload;
              class operator Equal(const aLeft,aRight:TImageSize):boolean;
              class operator NotEqual(const aLeft,aRight:TImageSize):boolean;
            end;
            PImageSize=^TImageSize;
            TQueue=class;
            TPhysicalPass=class;
            TPhysicalPasses=TpvObjectGenericList<TPhysicalPass>;
            TPhysicalPassCrossEvent=class
             private
              fFrameGraph:TpvFrameGraph;
              fQueue:TQueue;
              fFromPhysicalPass:TPhysicalPass;
              fToPhysicalPass:TPhysicalPass;
              fStageMask:TVkPipelineStageFlags;
              fEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aQueue:TQueue;
                                 const aFromPhysicalPass:TPhysicalPass;
                                 const aToPhysicalPass:TPhysicalPass;
                                 const aStageMask:TVkPipelineStageFlags); reintroduce;
              destructor Destroy; override;
              procedure AcquireVolatileResources;
              procedure ReleaseVolatileResources;
            end;
            TPhysicalPassCrossEvents=TpvObjectGenericList<TPhysicalPassCrossEvent>;
            TInFlightFrameSemaphores=array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
            TExternalWaitingOnSemaphore=class
             private 
              fFrameGraph:TpvFrameGraph;
              fInFlightFrameSemaphores:TInFlightFrameSemaphores;
              function GetInFlightFrameSemaphore(const aIndex:TpvSizeInt):TpvVulkanSemaphore;
              procedure SetInFlightFrameSemaphore(const aIndex:TpvSizeInt;const aInFlightFrameSemaphore:TpvVulkanSemaphore); 
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); reintroduce;
              destructor Destroy; override;
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
             public   
              property InFlightFrameSemaphores[const aIndex:TpvSizeInt]:TpvVulkanSemaphore read GetInFlightFrameSemaphore write SetInFlightFrameSemaphore;
            end;
            TExternalWaitingOnSemaphores=TpvObjectGenericList<TExternalWaitingOnSemaphore>;
            TExternalWaitingOnSemaphoreReference=class
             private
              fFrameGraph:TpvFrameGraph;
              fExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;
              fStageMask:TVkPipelineStageFlags;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;
                                 const aStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT)); reintroduce;
              destructor Destroy; override;
             published
              property ExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore read fExternalWaitingOnSemaphore write fExternalWaitingOnSemaphore;
              property StageMask:TVkPipelineStageFlags read fStageMask write fStageMask;
            end;
            TExternalWaitingOnSemaphoreReferences=TpvObjectGenericList<TExternalWaitingOnSemaphoreReference>;
            TQueue=class
             public
              type TVkSubmitInfos=array of TVkSubmitInfo;
                   TCommandBuffer=class
                    public
                     type TWaitingSemaphore=record
                           ExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;
                           SignallingCommandBuffer:TCommandBuffer;
                           DstStageMask:TVkPipelineStageFlags;
                          end;
                          PWaitingSemaphore=^TWaitingSemaphore;
                          TWaitingSemaphores=TpvDynamicArray<TWaitingSemaphore>;
                          TWaitingSemaphoreDstStageMasks=TpvDynamicArray<TVkPipelineStageFlags>;
                    private
                     fQueue:TQueue;
                     fPhysicalPasses:TPhysicalPasses;
                     fCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
                     fSignallingSemaphores:array[0..MaxInFlightFrames-1] of TVulkanSemaphores;
                     fSignallingSemaphoreHandles:array[0..MaxInFlightFrames-1] of TVulkanSemaphoreHandles;
                     fWaitingSemaphores:TWaitingSemaphores;
                     fWaitingSemaphoreHandles:TVulkanSemaphoreHandles;
                     fWaitingSemaphoreDstStageMasks:TWaitingSemaphoreDstStageMasks;
                     fSubmitInfos:array[0..MaxInFlightFrames-1] of TVkSubmitInfo;
                     fSubmitInfoIndex:TpvSizeInt;
                     fMustResetEvents:Boolean;
                    public
                     constructor Create(const aQueue:TQueue); reintroduce;
                     destructor Destroy; override;
                     procedure AcquirePersistentResources;
                     procedure ReleasePersistentResources;
                     procedure AcquireVolatileResources;
                     procedure ReleaseVolatileResources;
                   end;
                   TCommandBuffers=TpvObjectGenericList<TCommandBuffer>;                   
             private
              fFrameGraph:TpvFrameGraph;
              fPhysicalQueue:TpvVulkanQueue;
              fPhysicalPasses:TPhysicalPasses;
              fCommandPool:TpvVulkanCommandPool;
              fCommandBufferCommandPool:TpvVulkanCommandPool;
              fCommandBuffers:TCommandBuffers;
              fResetBuffer:TCommandBuffer;
              fSubmitInfos:TVkSubmitInfos;
              fCountSubmitInfos:TPasMPInt32;
              fPhysicalPassCrossEvents:TPhysicalPassCrossEvents;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aPhysicalQueue:TpvVulkanQueue); reintroduce;
              destructor Destroy; override;
              procedure AcquirePersistentResources;
              procedure ReleasePersistentResources;
              procedure AcquireVolatileResources;
              procedure ReleaseVolatileResources;
              procedure ResetEvents(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
              property PhysicalQueue:TpvVulkanQueue read fPhysicalQueue;
              property CommandPool:TpvVulkanCommandPool read fCommandPool;
            end;
            TQueues=TpvObjectGenericList<TQueue>;
            TQueueFamilyIndices=TpvDynamicArray<TVkUInt32>;
            TExternalData=class
             private
              fFrameGraph:TpvFrameGraph;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); reintroduce; virtual;
              destructor Destroy; override;
            end;
            TExternalDataList=TpvObjectGenericList<TExternalData>;
            TExternalImageData=class(TExternalData)
             public
              type TVulkanImages=TpvObjectGenericList<TpvVulkanImage>;
             private
              fVulkanImages:TVulkanImages;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); override;
              destructor Destroy; override;
             published
              property VulkanImages:TVulkanImages read fVulkanImages;
            end;
            TExternalBufferData=class(TExternalData)
             public
              type TVulkanBuffers=TpvObjectGenericList<TpvVulkanBuffer>;
             private
              fVulkanBuffers:TVulkanBuffers;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); override;
              destructor Destroy; override;
             published
              property VulkanBuffers:TVulkanBuffers read fVulkanBuffers;
            end;
            TResourceType=class
             private
              fFrameGraph:TpvFrameGraph;
              fName:TpvRawByteString;
              fPersistent:boolean;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aPersistent:boolean); reintroduce; virtual;
              destructor Destroy; override;
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
              property Name:TpvRawByteString read fName;
              property Persistent:boolean read fPersistent write fPersistent;
            end;
            TImageResourceType=class(TResourceType)
             private
              fFormat:TVkFormat;
              fSamples:TVkSampleCountFlagBits;
              fImageType:TImageType;
              fImageSize:TImageSize;
              fImageUsage:TVkImageUsageFlags;
              fCountMipMapLevels:TVkUInt32;
              fComponents:TVkComponentMapping;
              fInitialLayout:TVkImageLayout;
              fFinalLayout:TVkImageLayout;
              fAdditionalFormat:TVkFormat;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aPersistent:boolean;
                                 const aFormat:TVkFormat;
                                 const aSamples:TVkSampleCountFlagBits;
                                 const aImageType:TImageType;
                                 const aImageSize:TImageSize;
                                 const aImageUsage:TVkImageUsageFlags;
                                 const aCountMipMapLevels:TVkUInt32;
                                 const aComponents:TVkComponentMapping;
                                 const aInitialLayout:TVkImageLayout;
                                 const aFinalLayout:TVkImageLayout;
                                 const aAdditionalFormat:TVkFormat); reintroduce; overload;
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aPersistent:boolean;
                                 const aFormat:TVkFormat;
                                 const aSamples:TVkSampleCountFlagBits;
                                 const aImageType:TImageType;
                                 const aImageSize:TImageSize;
                                 const aImageUsage:TVkImageUsageFlags;
                                 const aCountMipMapLevels:TVkUInt32;
                                 const aInitialLayout:TVkImageLayout;
                                 const aFinalLayout:TVkImageLayout;
                                 const aAdditionalFormat:TVkFormat); reintroduce; overload;
              destructor Destroy; override;
             public
              property ImageType:TImageType read fImageType;
              property ImageSize:TImageSize read fImageSize;
              property Components:TVkComponentMapping read fComponents;
             published
              property Format:TVkFormat read fFormat write fFormat;
              property Samples:TVkSampleCountFlagBits read fSamples;
              property ImageUsage:TVkImageUsageFlags read fImageUsage;
              property CountMipMapLevels:TVkUInt32 read fCountMipMapLevels;
              property InitialLayout:TVkImageLayout read fInitialLayout;
              property FinalLayout:TVkImageLayout read fFinalLayout;
              property AdditionalFormat:TVkFormat read fAdditionalFormat;
            end;
            TBufferResourceType=class(TResourceType)
             private
              fSize:TVkDeviceSize;
              fUsage:TVkBufferUsageFlags;
              fMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryRequiredHeapFlags:TVkMemoryHeapFlags;
              fMemoryPreferredHeapFlags:TVkMemoryHeapFlags;
              fMemoryAvoidHeapFlags:TVkMemoryHeapFlags;
              fMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
              fBufferFlags:TpvVulkanBufferFlags;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aPersistent:boolean;
                                 const aSize:TVkDeviceSize;
                                 const aUsage:TVkBufferUsageFlags;
                                 const aMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
                                 const aMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
                                 const aMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags=0;
                                 const aMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags=0;
                                 const aMemoryRequiredHeapFlags:TVkMemoryHeapFlags=0;
                                 const aMemoryPreferredHeapFlags:TVkMemoryHeapFlags=0;
                                 const aMemoryAvoidHeapFlags:TVkMemoryHeapFlags=0;
                                 const aMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags=0;
                                 const aBufferFlags:TpvVulkanBufferFlags=[]); reintroduce; overload;
              destructor Destroy; override;
             published
              property Size:TVkDeviceSize read fSize;
              property Usage:TVkBufferUsageFlags read fUsage;
              property MemoryRequiredPropertyFlags:TVkMemoryPropertyFlags read fMemoryRequiredPropertyFlags;
              property MemoryPreferredPropertyFlags:TVkMemoryPropertyFlags read fMemoryPreferredPropertyFlags;
              property MemoryAvoidPropertyFlags:TVkMemoryPropertyFlags read fMemoryAvoidPropertyFlags;
              property MemoryRequiredHeapFlags:TVkMemoryHeapFlags read fMemoryRequiredHeapFlags;
              property MemoryPreferredHeapFlags:TVkMemoryHeapFlags read fMemoryPreferredHeapFlags;
              property MemoryAvoidHeapFlags:TVkMemoryHeapFlags read fMemoryAvoidHeapFlags;
              property BufferFlags:TpvVulkanBufferFlags read fBufferFlags;
            end;
            TResource=class;
            TResourceList=TpvObjectGenericList<TResource>;
            TResourceDynamicArray=TpvDynamicArray<TResource>;
            TResourceHashMap=TpvHashMap<TResource,TpvPtrInt>;
            TResourceNameHashMap=TpvStringHashMap<TResource>;
            TResourceTypeList=TpvObjectGenericList<TResourceType>;
            TResourceTypeNameHashMap=TpvStringHashMap<TResourceType>;
            TResourceTransition=class;
            { TResourceTransitionList }
            TResourceTransitionList=class(TpvObjectGenericList<TResourceTransition>)
             public
              function HasPhysicalPassesIntersectionWith(const aWith:TResourceTransitionList):boolean;
              function MergeCompatibleWith(const aWith:TResourceTransitionList):boolean;
            end;
            TResourcePhysicalData=class
             private
              fFrameGraph:TpvFrameGraph;
              fResourceType:TResourceType;
              fResourceInstanceType:TResourceInstanceType;
              fExternalData:TExternalData;
              function GetActiveResourceInstanceType:TResourceInstanceType;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); reintroduce; virtual;
              destructor Destroy; override;
              procedure AcquirePersistentResources; virtual;
              procedure ReleasePersistentResources; virtual;
              procedure AcquireVolatileResources; virtual;
              procedure ReleaseVolatileResources; virtual;
             published
              property ActiveResourceInstanceType:TResourceInstanceType read GetActiveResourceInstanceType;
            end;
            TResourcePhysicalImageData=class(TResourcePhysicalData)
             private
              fIsSurface:boolean;
              fImageUsageFlags:TVkImageUsageFlags;
              fRequestedFormat:TVkFormat;
              fFormat:TVkFormat;
              fAdditionalFormat:TVkFormat;
              fExtent:TVkExtent3D;
              fCountMipMaps:TpvSizeInt;
              fCountArrayLayers:TpvSizeInt;
              fTextureArray:boolean;
              fSamples:TVkSampleCountFlagBits;
              fTiling:TVkImageTiling;
              fInitialLayout:TVkImageLayout;
              fFirstInitialLayout:TVkImageLayout;
              fImageCreateFlags:TVkImageCreateFlags;
              fImageType:TVkImageType;
              fSharingMode:TVkSharingMode;
              fImageSubresourceRange:TVkImageSubresourceRange;
              fImageViewType:TVkImageViewType;
              fComponents:TVkComponentMapping;
              fVulkanImages:array[0..MaxInFlightFrames-1] of TpvVulkanImage;
              fVulkanImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
              fVulkanAdditionalFormatImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
              fVulkanMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
              fVulkanSurfaceImages:array of TpvVulkanImage;
              fVulkanSurfaceImageViews:array of TpvVulkanImageView;
              function GetVulkanImage(const aIndex:TpvSizeInt):TpvVulkanImage; inline;
              function GetVulkanImageView(const aIndex:TpvSizeInt):TpvVulkanImageView; inline;
              function GetVulkanAdditionalFormatImageView(const aIndex:TpvSizeInt):TpvVulkanImageView; inline;
              function GetVulkanMemoryBlock(const aIndex:TpvSizeInt):TpvVulkanDeviceMemoryBlock; inline;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); override;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
             public
              property VulkanImages[const aIndex:TpvSizeInt]:TpvVulkanImage read GetVulkanImage;
              property VulkanImageViews[const aIndex:TpvSizeInt]:TpvVulkanImageView read GetVulkanImageView;
              property VulkanAdditionalFormatImageViews[const aIndex:TpvSizeInt]:TpvVulkanImageView read GetVulkanAdditionalFormatImageView;
              property VulkanMemoryBlocks[const aIndex:TpvSizeInt]:TpvVulkanDeviceMemoryBlock read GetVulkanMemoryBlock;
             published
            end;
            TResourcePhysicalBufferData=class(TResourcePhysicalData)
             private
              fSize:TVkDeviceSize;
              fUsage:TVkBufferUsageFlags;
              fMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
              fMemoryRequiredHeapFlags:TVkMemoryHeapFlags;
              fMemoryPreferredHeapFlags:TVkMemoryHeapFlags;
              fMemoryAvoidHeapFlags:TVkMemoryHeapFlags;
              fMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
              fBufferFlags:TpvVulkanBufferFlags;
              fVulkanBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
              function GetVulkanBuffer(const aIndex:TpvSizeInt):TpvVulkanBuffer; inline;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); override;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
             public
              property VulkanBuffers[const aIndex:TpvSizeInt]:TpvVulkanBuffer read GetVulkanBuffer;
            end;
            TResourceAliasGroup=class
             private
              fFrameGraph:TpvFrameGraph;
              fResourceType:TResourceType;
              fResourceInstanceType:TResourceInstanceType;
              fResources:TResourceList;
              fResourcePhysicalData:TResourcePhysicalData;
              fExternalData:TExternalData;
              fUsedFlags:TpvUInt32;
              fTransient:boolean;
              fMinimumPhysicalPassStepIndex:TpvSizeInt;
              fMaximumPhysicalPassStepIndex:TpvSizeInt;
              fLastTransition:TResourceTransition;
              fLayout:TVkImageLayout;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); reintroduce;
              destructor Destroy; override;
              procedure AcquirePersistentResources; virtual;
              procedure ReleasePersistentResources; virtual;
              procedure AcquireVolatileResources; virtual;
              procedure ReleaseVolatileResources; virtual;
            end;
            TResourceAliasGroupList=TpvObjectGenericList<TResourceAliasGroup>;
            TResource=class
             public
              type TLayoutHistory=TpvInt64SkipList<TVkImageLayout>;
             private
              fFrameGraph:TpvFrameGraph;
              fName:TpvRawByteString;
              fResourceType:TResourceType;
              fResourceInstanceType:TResourceInstanceType;
              fResourceTransitions:TResourceTransitionList;
              fMinimumTopologicalSortPassIndex:TpvSizeInt;
              fMaximumTopologicalSortPassIndex:TpvSizeInt;
              fMinimumPhysicalPassStepIndex:TpvSizeInt;
              fMaximumPhysicalPassStepIndex:TpvSizeInt;
              fResourceAliasGroup:TResourceAliasGroup;
              fLayoutHistory:TLayoutHistory;
              fExternalData:TExternalData;
              fUsedFlags:TpvUInt32;
              fTransient:boolean;
              fUsed:boolean;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aResourceType:TResourceType=nil;
                                 const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default); reintroduce; overload;
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aName:TpvRawByteString;
                                 const aResourceTypeName:TpvRawByteString;
                                 const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default); reintroduce; overload;
              destructor Destroy; override;
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
              property Name:TpvRawByteString read fName;
              property ResourceType:TResourceType read fResourceType;
              property ResourceAliasGroup:TResourceAliasGroup read fResourceAliasGroup;
              property ExternalData:TExternalData read fExternalData write fExternalData;
              property UsedFlags:TpvUInt32 read fUsedFlags;
              property Transient:boolean read fTransient;
              property Used:boolean read fUsed;
            end;
            TPass=class;
            TResourceTransition=class
             public
              type TResourceTransitionKind=
                    (
                     ImageInput,
                     ImageOutput,
                     ImageResolveOutput,
                     ImageDepthOutput,
                     ImageDepthInput,
                     BufferInput,
                     BufferOutput
                    );
                   TKind=TResourceTransitionKind;
                   PKind=^TKind;
                   TKinds=set of TKind;
                   PKinds=^TKinds;
                   TResourceTransitionFlag=
                    (
                     Attachment,
                     ExplicitInputAttachment,
                     ExplicitOutputAttachment,
                     PreviousFrameInput,
                     NextFrameOutput
                    );
                   TFlag=TResourceTransitionFlag;
                   PFlag=^TFlag;
                   TFlags=set of TFlag;
                   PFlags=^TFlags;
                const AllImages=
                       [
                        TKind.ImageInput,
                        TKind.ImageOutput,
                        TKind.ImageResolveOutput,
                        TKind.ImageDepthOutput,
                        TKind.ImageDepthInput
                       ];
                      AllImageInputs=
                       [
                        TKind.ImageInput,
                        TKind.ImageDepthInput
                       ];
                      AllImageOutputs=
                       [
                        TKind.ImageOutput,
                        TKind.ImageResolveOutput,
                        TKind.ImageDepthOutput
                       ];
                      AllInputs=
                       [
                        TKind.ImageInput,
                        TKind.ImageDepthInput,
                        TKind.BufferInput
                       ];
                      AllOutputs=
                       [
                        TKind.ImageOutput,
                        TKind.ImageResolveOutput,
                        TKind.ImageDepthOutput,
                        TKind.BufferOutput
                       ];
                      AllInputsOutputs=AllInputs+AllOutputs;
                      AllDepths=[
                       TKind.ImageDepthOutput,
                       TKind.ImageDepthInput
                      ];
                      AllBuffers=[
                       TKind.BufferInput,
                       TKind.BufferOutput
                      ];
             private
              fFrameGraph:TpvFrameGraph;
              fPass:TPass;
              fResource:TResource;
              fKind:TKind;
              fFlags:TFlags;
              fLayout:TVkImageLayout;
              fLoadOp:TLoadOp;
              fResolveSourceResource:TResource;
              fPipelineStage:TVkPipelineStageFlags;
              fAccessFlags:TVkAccessFlags;
              fBufferSubresourceRange:TBufferSubresourceRange;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aPass:TPass;
                                 const aResource:TResource;
                                 const aKind:TKind;
                                 const aFlags:TFlags); reintroduce; overload;
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aPass:TPass;
                                 const aResource:TResource;
                                 const aKind:TKind;
                                 const aFlags:TFlags;
                                 const aLayout:TVkImageLayout;
                                 const aLoadOp:TLoadOp); reintroduce; overload;
              constructor Create(const aFrameGraph:TpvFrameGraph;
                                 const aPass:TPass;
                                 const aResource:TResource;
                                 const aKind:TKind;
                                 const aFlags:TFlags;
                                 const aPipelineStage:TVkPipelineStageFlags;
                                 const aAccessFlags:TVkAccessFlags;
                                 const aBufferSubresourceRange:TBufferSubresourceRange); reintroduce; overload;
              destructor Destroy; override;
             public
              property Load:TLoadOp read fLoadOp write fLoadOp;
              property BufferSubresourceRange:TBufferSubresourceRange read fBufferSubresourceRange write fBufferSubresourceRange;
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
              property Pass:TPass read fPass;
              property Resource:TResource read fResource;
              property Kind:TKind read fKind;
              property Flags:TFlags read fFlags;
              property Layout:TVkImageLayout read fLayout write fLayout;
              property ResolveSourceResource:TResource read fResolveSourceResource;
              property PipelineStage:TVkPipelineStageFlags read fPipelineStage write fPipelineStage;
              property AccessFlags:TVkAccessFlags read fAccessFlags write fAccessFlags;
            end;
            TPassList=TpvObjectGenericList<TPass>;
            TPassNameHashMap=TpvStringHashMap<TPass>;
            TPassNameList=TpvGenericList<TpvRawByteString>;
            TComputePass=class;
            TTransferPass=class;
            TCustomPass=class;
            TRenderPass=class;
            TPhysicalPass=class
             public
              type TPipelineBarrierGroup=class
                    public
                     type TVkMemoryBarrierDynamicArray=TpvDynamicArray<TVkMemoryBarrier>;
                          TVkBufferMemoryBarrierDynamicArray=TpvDynamicArray<TVkBufferMemoryBarrier>;
                          TVkImageMemoryBarrierDynamicArray=TpvDynamicArray<TVkImageMemoryBarrier>;
                          TBarrierMapItemKind=
                           (
                            Memory,
                            Buffer,
                            Image
                           );
                          TBarrierMapItem=record
                           Kind:TBarrierMapItemKind;
                           BarrierIndex:TpvSizeInt;
                           ImageIndexOffset:TpvSizeInt;
                           ResourcePhysicalData:TResourcePhysicalData;
                          end;
                          PBarrierMapItem=^TBarrierMapItem;
                          TBarrierMapItemDynamicArray=TpvDynamicArray<TBarrierMapItem>;
                          TVkEventDynamicArray=TpvDynamicArray<TVkEvent>;
                          TPassEvent=record
                           Event:TpvVulkanEvent;
                           StageMask:TVkPipelineStageFlags;
                          end;
                          PPassEvent=^TPassEvent;
                          TPassEventDynamicArray=TpvDynamicArray<TPassEvent>;
                    private
                     fFrameGraph:TpvFrameGraph;
                     fSrcStageMask:TVkPipelineStageFlags;
                     fDstStageMask:TVkPipelineStageFlags;
                     fDependencyFlags:TVkDependencyFlags;
                     fBarrierMapItemDynamicArray:TBarrierMapItemDynamicArray;
                     fMemoryBarrierDynamicArray:TVkMemoryBarrierDynamicArray;
                     fBufferMemoryBarrierDynamicArray:TVkBufferMemoryBarrierDynamicArray;
                     fImageMemoryBarrierDynamicArray:TVkImageMemoryBarrierDynamicArray;
                     fWorkMemoryBarrierDynamicArray:array[0..MaxInFlightFrames-1] of TVkMemoryBarrierDynamicArray;
                     fWorkBufferMemoryBarrierDynamicArray:array[0..MaxInFlightFrames-1] of TVkBufferMemoryBarrierDynamicArray;
                     fWorkImageMemoryBarrierDynamicArray:array[0..MaxInFlightFrames-1] of TVkImageMemoryBarrierDynamicArray;
                     fPhysicalPassCrossEvents:TPhysicalPassCrossEvents;
                     fWorkFromPhysicalPassesEventHandles:array[0..MaxInFlightFrames-1] of TVkEventDynamicArray;
                    public
                     constructor Create(const aFrameGraph:TpvFrameGraph;
                                        const aSrcStageMask:TVkPipelineStageFlags;
                                        const aDstStageMask:TVkPipelineStageFlags;
                                        const aDependencyFlags:TVkDependencyFlags);
                     destructor Destroy; override;
                     procedure AcquirePersistentResources;
                     procedure ReleasePersistentResources;
                     procedure AcquireVolatileResources;
                     procedure ReleaseVolatileResources;
                     procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
                    published
                     property SrcStageMask:TVkPipelineStageFlags read fSrcStageMask write fSrcStageMask;
                     property DstStageMask:TVkPipelineStageFlags read fDstStageMask write fDstStageMask;
                     property DependencyFlags:TVkDependencyFlags read fDependencyFlags write fDependencyFlags;
                   end;
                   TPipelineBarrierGroups=class(TpvObjectGenericList<TPipelineBarrierGroup>)
                    public
                     procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
                   end;
             private
              fFrameGraph:TpvFrameGraph;
              fIndex:TpvSizeInt;
              fProcessed:boolean;
              fSeparateCommandBuffer:boolean;
              fHasSecondaryBuffers:boolean;
              fQueue:TQueue;
              fExternalWaitingOnSemaphoreReferences:TExternalWaitingOnSemaphoreReferences;
              fInputDependencies:TPhysicalPasses;
              fOutputDependencies:TPhysicalPasses;
              fQueueCommandBuffer:TQueue.TCommandBuffer;
              fEventPipelineBarrierGroups:TPipelineBarrierGroups;
              fBeforePipelineBarrierGroups:TPipelineBarrierGroups;
              fAfterPipelineBarrierGroups:TPipelineBarrierGroups;
              fIncomingEvents:TPhysicalPassCrossEvents;
              fOutgoingEvents:TPhysicalPassCrossEvents;
              procedure SetEvents(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aQueue:TQueue); reintroduce; virtual;
              destructor Destroy; override;
              procedure AcquirePersistentResources; virtual;
              procedure ReleasePersistentResources; virtual;
              procedure AcquireVolatileResources; virtual;
              procedure ReleaseVolatileResources; virtual;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); virtual;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer); virtual;
            end;
            TPhysicalComputePass=class(TPhysicalPass)
             private
              fComputePass:TComputePass;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aComputePass:TComputePass); reintroduce;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer); override;
            end;
            TPhysicalTransferPass=class(TPhysicalPass)
             private
              fTransferPass:TTransferPass;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aTransferPass:TTransferPass); reintroduce;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer); override;
            end;
            TPhysicalCustomPass=class(TPhysicalPass)
             private
              fCustomPass:TCustomPass;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aCustomPass:TCustomPass); reintroduce;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer); override;
            end;
            TPhysicalRenderPass=class(TPhysicalPass)
             public
              type TAttachment=record
                    Resource:TResource;
                    Persistent:boolean;
                    ImageType:TImageType;
                    Format:TVkFormat;
                    Samples:TVkSampleCountFlagBits;
                    LoadOp:TVkAttachmentLoadOp;
                    StoreOp:TVkAttachmentStoreOp;
                    StencilLoadOp:TVkAttachmentLoadOp;
                    StencilStoreOp:TVkAttachmentStoreOp;
                    InitialLayout:TVkImageLayout;
                    FinalLayout:TVkImageLayout;
                    ImageUsageFlags:TVkImageUsageFlags;
                    ClearValueInitialized:boolean;
                    ClearValue:TVkClearValue;
                    HasInitialLayout:boolean;
                   end;
                   PAttachment=^TAttachment;
                   TAttachments=TpvDynamicArray<TAttachment>;
                   TAttachmentReferences=TpvDynamicArray<TVkAttachmentReference>;
                   TInt32AttachmentLists=TpvDynamicArray<TpvInt32>;
                   TUInt32AttachmentLists=TpvDynamicArray<TpvUInt32>;
                   TResourcelLayoutHashMap=TpvHashMap<TResource,TVkImageLayout>;
                   TSubpass=class;
                   TSubpasses=TpvObjectGenericList<TSubpass>;
                   TSubpassDependency=record
                    SrcSubpass:TSubpass;
                    DstSubpass:TSubpass;
                    SrcStageMask:TVkPipelineStageFlags;
                    DstStageMask:TVkPipelineStageFlags;
                    SrcAccessMask:TVkAccessFlags;
                    DstAccessMask:TVkAccessFlags;
                    DependencyFlags:TVkDependencyFlags;
                   end;
                   PSubpassDependency=^TSubpassDependency;
                   TSubpassDependencies=TpvDynamicArray<TSubpassDependency>;
                   TSubpass=class
                    private
                     fPhysicalRenderPass:TPhysicalRenderPass;
                     fIndex:TpvSizeInt;
                     fRenderPass:TRenderPass;
                     fInputAttachments:TInt32AttachmentLists;
                     fColorAttachments:TInt32AttachmentLists;
                     fResolveAttachments:TInt32AttachmentLists;
                     fPreserveAttachments:TUInt32AttachmentLists;
                     fDepthStencilAttachment:TpvInt64;
                     fMultiviewMask:TVkUInt32;
                    public
                     constructor Create(const aPhysicalRenderPass:TPhysicalRenderPass;
                                        const aRenderPass:TRenderPass); reintroduce;
                     destructor Destroy; override;
                     procedure AcquirePersistentResources; virtual;
                     procedure ReleasePersistentResources; virtual;
                     procedure AcquireVolatileResources; virtual;
                     procedure ReleaseVolatileResources; virtual;
                    published
                     property Index:TpvSizeInt read fIndex;
                     property MultiviewMask:TVkUInt32 read fMultiviewMask;
                   end;
             private
              fSubpasses:TSubpasses;
              fSubpassDependencies:TSubpassDependencies;
              fMultiview:boolean;
              fHasSurfaceSubpassDependencies:boolean;
              fHasVulkanSurfaceFrameBuffers:boolean;
              fAttachments:TAttachments;
              fAttachmentReferences:TAttachmentReferences;
              fFinalLayouts:TResourcelLayoutHashMap;
              fVulkanRenderPass:TpvVulkanRenderPass;
              fVulkanSurfaceFrameBuffers:array[0..MaxInFlightFrames-1] of array of TpvVulkanFrameBuffer;
              fVulkanFrameBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanFrameBuffer;
              fSize:TImageSize;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aQueue:TQueue); override;
              destructor Destroy; override;
              procedure AcquirePersistentResources; override;
              procedure ReleasePersistentResources; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer); override;
             public
              property Size:TImageSize read fSize write fSize;
             published
              property VulkanRenderPass:TpvVulkanRenderPass read fVulkanRenderPass;
            end;
            TExplicitPassDependency=class
             private
              fPass:TPass;
              fDstStageMask:TVkPipelineStageFlags;
            end;
            TExplicitPassDependencyList=TpvObjectGenericList<TExplicitPassDependency>;
            TExplicitPassNameDependency=class
             private
              fPassName:TpvRawByteString;
              fDstStageMask:TVkPipelineStageFlags;
            end;
            TExplicitPassNameDependencyList=TpvObjectGenericList<TExplicitPassNameDependency>;
            { TPass }
            TPass=class
             public
              type TFlag=
                    (
                     SeparatePhysicalPass,
                     SeparateCommandBuffer,
                     Toggleable,
                     Enabled,
                     Used,
                     PermanentlyMarked,
                     TemporaryMarked,
                     Subpass,
                     HasSecondaryBuffers
                    );
                   PFlag=^TFlag;
                   TFlags=set of TFlag;
                   TUsedResource=class
                    private
                     fFrameGraph:TpvFrameGraph;
                     fPass:TPass;
                     fResourceTransition:TResourceTransition;
                     fResource:TResource;
                     fResourceType:TResourceType;
                     fResourcePhysicalData:TResourcePhysicalData;
                     function AdjustInFlightFrameIndex(const aInFlightFrameIndex:TpvSizeInt):TpvSizeInt; inline;
                    public
                     constructor Create(const aPass:TPass;
                                        const aResourceTransition:TResourceTransition); reintroduce; virtual;
                     destructor Destroy; override;
                     procedure Finish;
                    published
                     property Pass:TPass read fPass;
                     property ResourceTransition:TResourceTransition read fResourceTransition;
                     property Resource:TResource read fResource;
                     property ResourceType:TResourceType read fResourceType;
                   end;
                   TUsedResources=TpvObjectGenericList<TUsedResource>;
                   TUsedImageResource=class(TUsedResource)
                    private
                     function GetVulkanImage(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImage;
                     function GetVulkanImageView(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImageView;
                     function GetVulkanAdditionalFormatImageView(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImageView;
                     function GetVulkanMemoryBlock(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanDeviceMemoryBlock;
                     function GetWidth:TpvSizeInt;
                     function GetHeight:TpvSizeInt;
                     function GetDepth:TpvSizeInt;
                     function GetCountMipMapLevels:TpvSizeInt;
                     function GetCountArrayLayers:TpvSizeInt;
                    public
                     property VulkanImages[const aInFlightFrameIndex:TpvSizeInt]:TpvVulkanImage read GetVulkanImage;
                     property VulkanImageViews[const aInFlightFrameIndex:TpvSizeInt]:TpvVulkanImageView read GetVulkanImageView;
                     property VulkanAdditionalFormatImageViews[const aInFlightFrameIndex:TpvSizeInt]:TpvVulkanImageView read GetVulkanAdditionalFormatImageView;
                     property VulkanMemoryBlocks[const aInFlightFrameIndex:TpvSizeInt]:TpvVulkanDeviceMemoryBlock read GetVulkanMemoryBlock;
                     property Width:TpvSizeInt read GetWidth;
                     property Height:TpvSizeInt read GetHeight;
                     property Depth:TpvSizeInt read GetDepth;
                     property CountMipMapLevels:TpvSizeInt read GetCountMipMapLevels;
                     property CountArrayLayers:TpvSizeInt read GetCountArrayLayers;
                   end;
                   TUsedBufferResource=class(TUsedResource)
                    private
                     function GetVulkanBuffer(const aSwapChainBufferIndex:TpvSizeInt):TpvVulkanBuffer;
                    public
                     property VulkanBuffers[const aSwapChainBufferIndex:TpvSizeInt]:TpvVulkanBuffer read GetVulkanBuffer;
                   end;
                   TTimerQueryIndices=array[0..MaxInFlightFrames-1] of TpvSizeInt;
                   TCPUTimeValues=array[0..MaxInFlightFrames-1] of TpvHighResolutionTime;
             private
              fFrameGraph:TpvFrameGraph;
              fName:TpvRawByteString;
              fFlags:TFlags;
              fQueue:TQueue;
              fResources:TResourceList;
              fResourceTransitions:TResourceTransitionList;
              fUsedResources:TUsedResources;
              fExplicitPassDependencies:TExplicitPassDependencyList;
              fExplicitPassNameDependencies:TExplicitPassNameDependencyList;
              fPreviousPasses:TPassList;
              fNextPasses:TPassList;
              fIndex:TpvSizeInt;
              fTag:TpvSizeInt;
              fPhysicalPass:TPhysicalPass;
              fTopologicalSortIndex:TpvSizeInt;
              fTimerQueryIndices:TTimerQueryIndices;
              fCPUTimeValues:TCPUTimeValues;
              fDoubleBufferedEnabledState:array[0..1] of longbool;
              fExternalWaitingOnSemaphoreReferences:TExternalWaitingOnSemaphoreReferences;
              function GetSeparatePhysicalPass:boolean; inline;
              procedure SetSeparatePhysicalPass(const aSeparatePhysicalPass:boolean);
              function GetSeparateCommandBuffer:boolean; inline;
              procedure SetSeparateCommandBuffer(const aSeparateCommandBuffer:boolean);
              function GetToggleable:boolean; inline;
              procedure SetToggleable(const aToggleable:boolean);
              function GetEnabled:boolean; inline;
              procedure SetEnabled(const aEnabled:boolean);
              function GetHasSecondaryBuffers:boolean; inline;
              procedure SetHasSecondaryBuffers(const aHasSecondaryBuffers:boolean);
              procedure SetName(const aName:TpvRawByteString);
              procedure ResolveExplicitPassDependencies;
              function AddImageResource(const aResourceTypeName:TpvRawByteString;
                                        const aResourceName:TpvRawByteString;
                                        const aKind:TResourceTransition.TKind;
                                        const aFlags:TResourceTransition.TFlags;
                                        const aLayout:TVkImageLayout;
                                        const aLoadOp:TLoadOp;
                                        const aResourceInstanceType:TResourceInstanceType;
                                        const aExternalImageData:TExternalImageData):TResourceTransition; overload;
              function AddBufferResource(const aResourceTypeName:TpvRawByteString;
                                         const aResourceName:TpvRawByteString;
                                         const aKind:TResourceTransition.TKind;
                                         const aFlags:TResourceTransition.TFlags;
                                         const aPipelineStage:TVkPipelineStageFlags;
                                         const aAccessFlags:TVkAccessFlags;
                                         const aBufferSubresourceRange:TBufferSubresourceRange;
                                         const aResourceInstanceType:TResourceInstanceType;
                                         const aExternalBufferData:TExternalBufferData):TResourceTransition; overload;
              procedure AddStartMarker(const aQueue:TpvFrameGraph.TQueue;const aCommandBuffer:TpvVulkanCommandBuffer);
              procedure AddEndMarker(const aQueue:TpvFrameGraph.TQueue;const aCommandBuffer:TpvVulkanCommandBuffer);
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); reintroduce; virtual;
              destructor Destroy; override;              
              procedure AddExternalWaitingOnSemaphore(const aExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;const aStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT));
              procedure AddExplicitPassDependency(const aPass:TPass;const aDstStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT)); overload;
              procedure AddExplicitPassDependency(const aPassName:TpvRawByteString;const aDstStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT)); overload;
              function AddImageInput(const aResourceTypeName:TpvRawByteString;
                                     const aResourceName:TpvRawByteString;
                                     const aLayout:TVkImageLayout;
                                     const aFlags:TResourceTransition.TFlags=[];
                                     const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                     const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
              function AddImageOutput(const aResourceTypeName:TpvRawByteString;
                                      const aResourceName:TpvRawByteString;
                                      const aLayout:TVkImageLayout;
                                      const aLoadOp:TLoadOp;
                                      const aFlags:TResourceTransition.TFlags=[];
                                      const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                      const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
              function AddImageResolveOutput(const aResourceTypeName:TpvRawByteString;
                                             const aResourceName:TpvRawByteString;
                                             const aResolveSourceResourceName:TpvRawByteString;
                                             const aLayout:TVkImageLayout;
                                             const aLoadOp:TLoadOp;
                                             const aFlags:TResourceTransition.TFlags=[];
                                             const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                             const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
              function AddImageDepthInput(const aResourceTypeName:TpvRawByteString;
                                          const aResourceName:TpvRawByteString;
                                          const aLayout:TVkImageLayout;
                                          const aFlags:TResourceTransition.TFlags=[];
                                          const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                          const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
              function AddImageDepthOutput(const aResourceTypeName:TpvRawByteString;
                                           const aResourceName:TpvRawByteString;
                                           const aLayout:TVkImageLayout;
                                           const aLoadOp:TLoadOp;
                                           const aFlags:TResourceTransition.TFlags=[];
                                           const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                           const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
              function AddBufferInput(const aResourceTypeName:TpvRawByteString;
                                      const aResourceName:TpvRawByteString;
                                      const aPipelineStage:TVkPipelineStageFlags;
                                      const aAccessFlags:TVkAccessFlags;
                                      const aBufferSubresourceRange:TBufferSubresourceRange;
                                      const aFlags:TResourceTransition.TFlags=[];
                                      const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                      const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource; overload;
              function AddBufferInput(const aResourceTypeName:TpvRawByteString;
                                      const aResourceName:TpvRawByteString;
                                      const aPipelineStage:TVkPipelineStageFlags;
                                      const aAccessFlags:TVkAccessFlags;
                                      const aFlags:TResourceTransition.TFlags=[];
                                      const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                      const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource; overload;
              function AddBufferOutput(const aResourceTypeName:TpvRawByteString;
                                       const aResourceName:TpvRawByteString;
                                       const aPipelineStage:TVkPipelineStageFlags;
                                       const aAccessFlags:TVkAccessFlags;
                                       const aBufferSubresourceRange:TBufferSubresourceRange;
                                       const aFlags:TResourceTransition.TFlags=[];
                                       const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                       const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource; overload;
              function AddBufferOutput(const aResourceTypeName:TpvRawByteString;
                                       const aResourceName:TpvRawByteString;
                                       const aPipelineStage:TVkPipelineStageFlags;
                                       const aAccessFlags:TVkAccessFlags;
                                       const aFlags:TResourceTransition.TFlags=[];
                                       const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                       const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource; overload;
             public
              procedure AcquirePersistentResources; virtual;
              procedure ReleasePersistentResources; virtual;
              procedure AcquireVolatileResources; virtual;
              procedure ReleaseVolatileResources; virtual;
              procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); virtual;
              procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); virtual;
             public
              property TimerQueryIndices:TTimerQueryIndices read fTimerQueryIndices;
              property CPUTimeValues:TCPUTimeValues read fCPUTimeValues;
             published
              property FrameGraph:TpvFrameGraph read fFrameGraph;
              property Name:TpvRawByteString read fName write SetName;
              property Queue:TQueue read fQueue write fQueue;
              property SeparatePhysicalPass:boolean read GetSeparatePhysicalPass write SetSeparatePhysicalPass;
              property SeparateCommandBuffer:boolean read GetSeparateCommandBuffer write SetSeparateCommandBuffer;
              property Toggleable:boolean read GetToggleable write SetToggleable;
              property Enabled:boolean read GetEnabled write SetEnabled;
              property HasSecondaryBuffers:boolean read GetHasSecondaryBuffers write SetHasSecondaryBuffers;
              property PhysicalPass:TPhysicalPass read fPhysicalPass;
            end;
            TComputePass=class(TPass)
             private
             public
             published
            end;
            TTransferPass=class(TPass)
             private
             public
             published
            end;
            TCustomPass=class(TPass)
             private
             public
             published
            end;
            TRenderPass=class(TPass)
             private
              fMultiviewMask:TpvUInt32;
              fSize:TImageSize;
              fPhysicalRenderPassSubpass:TPhysicalRenderPass.TSubpass;
              function GetPhysicalRenderPass:TPhysicalRenderPass; inline;
              function GetVulkanRenderPass:TpvVulkanRenderPass; inline;
              function GetVulkanRenderPassSubpassIndex:TpvSizeInt; inline;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph); override;
              destructor Destroy; override;
             public
              property Size:TImageSize read fSize write fSize;
             published
              property MultiviewMask:TpvUInt32 read fMultiviewMask write fMultiviewMask;
              property PhysicalRenderPass:TPhysicalRenderPass read GetPhysicalRenderPass;
              property PhysicalRenderPassSubpass:TPhysicalRenderPass.TSubpass read fPhysicalRenderPassSubpass;
              property VulkanRenderPass:TpvVulkanRenderPass read GetVulkanRenderPass;
              property VulkanRenderPassSubpassIndex:TpvSizeInt read GetVulkanRenderPassSubpassIndex;
            end;
            TRenderPassClass=class of TRenderPass;
            TPassCPUTimeValues=array of TpvHighResolutionTime;
      private
       fVulkanDevice:TpvVulkanDevice;
       fMultiviewEnabled:boolean;
       fSurfaceIsSwapchain:boolean;
       fSurfaceWidth:TpvSizeInt;
       fSurfaceHeight:TpvSizeInt;
       fSurfaceColorFormat:TVkFormat;
       fSurfaceColorSpace:TVkColorSpaceKHR;
       fSurfaceDepthFormat:TVkFormat;
       fSurfaceImages:array of TpvVulkanImage;
       fCountInFlightFrames:TpvSizeInt;
       fCountSurfaceImages:TpvSizeInt;
       fDefaultResourceInstanceType:TResourceInstanceType;
       fQueues:TQueues;
       fAllQueueCommandBuffers:TQueue.TCommandBuffers;
       fQueueFamilyIndices:TQueueFamilyIndices;
       fUniversalQueue:TQueue;
       fGraphicsQueue:TQueue;
       fComputeQueue:TQueue;
       fTransferQueue:TQueue;
       fPresentQueue:TQueue;
       fResourceTypes:TResourceTypeList;
       fResourceTypeNameHashMap:TResourceTypeNameHashMap;
       fResources:TResourceList;
       fResourceNameHashMap:TResourceNameHashMap;
       fResourceTransitions:TResourceTransitionList;
       fResourceAliasGroups:TResourceAliasGroupList;
       fExternalDataList:TExternalDataList;
       fPasses:TPassList;
       fPassNameHashMap:TPassNameHashMap;
       fTopologicalSortedPasses:TPassList;
       fRootPass:TPass;
       fMaximumOverallPhysicalPassIndex:TpvSizeInt;
       fValid:boolean;
       fCanDoParallelProcessing:boolean;
       fDoWaitOnSemaphore:boolean;
       fDoSignalSemaphore:boolean;
       fTryToMergeSubpasses:boolean;
       fPhysicalPasses:TPhysicalPasses;
       fRootPhysicalPass:TPhysicalPass;
       fPhysicalPassCrossEvents:TPhysicalPassCrossEvents;
       fDrawToWaitOnSemaphores:array[0..MaxInFlightFrames-1] of TVulkanSemaphores;
       fDrawToWaitOnSemaphoreHandles:array[0..MaxInFlightFrames-1] of TVulkanSemaphoreHandles;
       fDrawToSignalSemaphoreHandles:array[0..MaxInFlightFrames-1] of TVulkanSemaphoreHandles;
       fDrawToSignalSemaphoreDstStageMasks:array[0..MaxInFlightFrames-1] of TVkPipelineStageFlagsDynamicArray;
       fDrawToWaitOnSemaphoreExternalHandles:array[0..MaxInFlightFrames-1] of TVkSemaphore;
       fDrawToWaitOnSemaphoreExternalDstStageMask:TVkPipelineStageFlags;
       fDrawToSignalSemaphoreExternalHandles:array[0..MaxInFlightFrames-1] of TVkSemaphore;
       fDrawToWaitSubmitInfos:array[0..MaxInFlightFrames-1] of TVkSubmitInfo;
       fDrawToSignalSubmitInfos:array[0..MaxInFlightFrames-1] of TVkSubmitInfo;
       fVulkanUniversalQueueCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanUniversalQueueCommandBufferFence:TpvVulkanFence;
       fDrawSwapChainImageIndex:TpvSizeInt;
       fDrawPreviousInFlightFrameIndex:TpvSizeInt;
       fDrawInFlightFrameIndex:TpvSizeInt;
       fDrawFrameIndex:TpvSizeInt;
       fDrawWaitFence:TpvVulkanFence;
       fTimerQueries:TpvTimerQueries;
       fLastTimerQueryResults:TpvTimerQuery.TResults;
       fCPUTimeValues:TPassCPUTimeValues;
       fLastCPUTimeValues:TPassCPUTimeValues;
      public
       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aCountInFlightFrames:TpvSizeInt=MaxInFlightFrames);
       destructor Destroy; override;
      public
       function ConvertRelativeToAbsoluteInFlightFrameIndex(const aCurrentInFlightFrameIndex,aRelativeInFlightFrameIndex:TpvSizeInt):TpvSizeInt;
       procedure SetSwapChain(const aSwapChain:TpvVulkanSwapChain;
                              const aSurfaceDepthFormat:TVkFormat);
       function AddQueue(const aPhysicalQueue:TpvVulkanQueue):TQueue;
       function AddImageResourceType(const aName:TpvRawByteString;
                                     const aPersistent:boolean;
                                     const aFormat:TVkFormat;
                                     const aSamples:TVkSampleCountFlagBits;
                                     const aImageType:TImageType;
                                     const aImageSize:TImageSize;
                                     const aImageUsage:TVkImageUsageFlags;
                                     const aCountMipMapLevels:TVkUInt32;
                                     const aComponents:TVkComponentMapping;
                                     const aInitialLayout:TVkImageLayout=VK_IMAGE_LAYOUT_UNDEFINED;
                                     const aFinalLayout:TVkImageLayout=VK_IMAGE_LAYOUT_UNDEFINED;
                                     const aAdditionalFormat:TVkFormat=VK_FORMAT_UNDEFINED):TResourceType; overload;
       function AddImageResourceType(const aName:TpvRawByteString;
                                     const aPersistent:boolean;
                                     const aFormat:TVkFormat;
                                     const aSamples:TVkSampleCountFlagBits;
                                     const aImageType:TImageType;
                                     const aImageSize:TImageSize;
                                     const aImageUsage:TVkImageUsageFlags;
                                     const aCountMipMapLevels:TVkUInt32;
                                     const aInitialLayout:TVkImageLayout=VK_IMAGE_LAYOUT_UNDEFINED;
                                     const aFinalLayout:TVkImageLayout=VK_IMAGE_LAYOUT_UNDEFINED;
                                     const aAdditionalFormat:TVkFormat=VK_FORMAT_UNDEFINED):TResourceType; overload;
       function AddBufferResourceType(const aName:TpvRawByteString;
                                      const aPersistent:boolean;
                                      const aSize:TVkDeviceSize;
                                      const aUsage:TVkBufferUsageFlags;
                                      const aMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
                                      const aMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
                                      const aMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags=0;
                                      const aMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags=0;
                                      const aMemoryRequiredHeapFlags:TVkMemoryHeapFlags=0;
                                      const aMemoryPreferredHeapFlags:TVkMemoryHeapFlags=0;
                                      const aMemoryAvoidHeapFlags:TVkMemoryHeapFlags=0;
                                      const aMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags=0;
                                      const aBufferFlags:TpvVulkanBufferFlags=[]):TResourceType; overload;
      public
       procedure AcquirePersistentResources; virtual;
       procedure ReleasePersistentResources; virtual;
       procedure AcquireVolatileResources; virtual;
       procedure ReleaseVolatileResources; virtual;
       procedure Setup; virtual;
       procedure Compile; virtual;
      private
       procedure ExecuteQueueCommandBufferParallelForJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure ExecuteQueue(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aQueue:TQueue);
       procedure ExecuteQueueParallelForJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
      public
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); virtual;
       procedure Draw(const aDrawSwapChainImageIndex:TpvSizeInt;
                      const aDrawInFlightFrameIndex:TpvSizeInt;
                      const aDrawFrameIndex:TpvSizeInt;
                      const aToWaitOnSemaphore:TpvVulkanSemaphore=nil;
                      const aToSignalSemaphore:TpvVulkanSemaphore=nil;
                      const aWaitFence:TpvVulkanFence=nil); virtual;
       procedure Dump;
      public
       property QueueFamilyIndices:TQueueFamilyIndices read fQueueFamilyIndices;
      published
       property CanDoParallelProcessing:boolean read fCanDoParallelProcessing write fCanDoParallelProcessing;
       property DoWaitOnSemaphore:boolean read fDoWaitOnSemaphore write fDoWaitOnSemaphore;
       property DoSignalSemaphore:boolean read fDoSignalSemaphore write fDoSignalSemaphore;
       property TryToMergeSubpasses:boolean read fTryToMergeSubpasses write fTryToMergeSubpasses;
       property VulkanDevice:TpvVulkanDevice read fVulkanDevice;
       property SurfaceIsSwapchain:boolean read fSurfaceIsSwapchain write fSurfaceIsSwapchain;
       property SurfaceWidth:TpvSizeInt read fSurfaceWidth write fSurfaceWidth;
       property SurfaceHeight:TpvSizeInt read fSurfaceHeight write fSurfaceHeight;
       property SurfaceColorFormat:TVkFormat read fSurfaceColorFormat write fSurfaceColorFormat;
       property SurfaceColorSpace:TVkColorSpaceKHR read fSurfaceColorSpace write fSurfaceColorSpace;
       property SurfaceDepthFormat:TVkFormat read fSurfaceDepthFormat write fSurfaceDepthFormat;
       property CountInFlightFrames:TpvSizeInt read fCountInFlightFrames;
       property CountSurfaceImages:TpvSizeInt read fCountSurfaceImages write fCountSurfaceImages;
       property DefaultResourceInstanceType:TResourceInstanceType read fDefaultResourceInstanceType write fDefaultResourceInstanceType;
       property Queues:TQueues read fQueues;
       property UniversalQueue:TQueue read fUniversalQueue;
       property GraphicsQueue:TQueue read fGraphicsQueue;
       property ComputeQueue:TQueue read fComputeQueue;
       property TransferQueue:TQueue read fTransferQueue;
       property PresentQueue:TQueue read fPresentQueue;
       property ResourceTypes:TResourceTypeList read fResourceTypes;
       property ResourceTypeByName:TResourceTypeNameHashMap read fResourceTypeNameHashMap;
       property Resources:TResourceList read fResources;
       property ResourceByName:TResourceNameHashMap read fResourceNameHashMap;
       property Passes:TPassList read fPasses;
       property PassByName:TPassNameHashMap read fPassNameHashMap;
       property RootPass:TPass read fRootPass write fRootPass;
       property RootPhysicalPass:TPhysicalPass read fRootPhysicalPass;
       property DrawSwapChainImageIndex:TpvSizeInt read fDrawSwapChainImageIndex;
       property DrawPreviousInFlightFrameIndex:TpvSizeInt read fDrawPreviousInFlightFrameIndex;
       property DrawInFlightFrameIndex:TpvSizeInt read fDrawInFlightFrameIndex;
       property DrawFrameIndex:TpvSizeInt read fDrawFrameIndex;
       property TimerQueries:TpvTimerQueries read fTimerQueries;
       property LastTimerQueryResults:TpvTimerQuery.TResults read fLastTimerQueryResults;
       property CPUTimeValues:TPassCPUTimeValues read fCPUTimeValues;
       property LastCPUTimeValues:TPassCPUTimeValues read fLastCPUTimeValues;
     end;

implementation

function ComparePhysicalRenderPassSubpassDependencies(const a,b:TpvFrameGraph.TPhysicalRenderPass.TSubpassDependency):TpvInt32;
 function GetSrcSubpassIndex(const aSubpassDependency:TpvFrameGraph.TPhysicalRenderPass.TSubpassDependency):TpvInt64;
 begin
  if assigned(aSubpassDependency.SrcSubpass) then begin
   result:=aSubpassDependency.SrcSubpass.fIndex;
  end else begin
   result:=-1;
  end;
 end;
 function GetDstSubpassIndex(const aSubpassDependency:TpvFrameGraph.TPhysicalRenderPass.TSubpassDependency):TpvInt64;
 begin
  if assigned(aSubpassDependency.DstSubpass) then begin
   result:=aSubpassDependency.DstSubpass.fIndex;
  end else begin
   result:=TpvInt64(High(TpvUInt32))+1;
  end;
 end;
begin
 result:=TpvInt64(Sign(TpvInt64(GetSrcSubpassIndex(a)-GetSrcSubpassIndex(b))));
 if result=0 then begin
  result:=TpvInt64(Sign(TpvInt64(GetDstSubpassIndex(a)-GetDstSubpassIndex(b))));
 end;
end;

{ TpvFrameGraph.TBufferSubresourceRange }

constructor TpvFrameGraph.TBufferSubresourceRange.Create(const aOffset,aRange:TVkDeviceSize);
begin
 Offset:=aOffset;
 Range:=aRange;
end;

{ TpvFrameGraph.TLoadOp }

constructor TpvFrameGraph.TLoadOp.Create(const aKind:TKind);
begin
 Kind:=aKind;
 ClearColor:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
end;

constructor TpvFrameGraph.TLoadOp.Create(const aKind:TKind;const aClearColor:TpvVector4);
begin
 Kind:=aKind;
 ClearColor:=aClearColor;
end;

{ TpvFrameGraph.TStoreOp }

constructor TpvFrameGraph.TStoreOp.Create(const aKind:TKind);
begin
 Kind:=aKind;
end;

{ TpvFrameGraph.TImageTypeHelper }

class function TpvFrameGraph.TImageTypeHelper.From(const aFormat:TVkFormat):TImageType;
begin
 case aFormat of
  VK_FORMAT_UNDEFINED:begin
   result:=TImageType.Undefined;
  end;
  VK_FORMAT_D16_UNORM,
  VK_FORMAT_X8_D24_UNORM_PACK32,
  VK_FORMAT_D32_SFLOAT:begin
   result:=TImageType.Depth;
  end;
  VK_FORMAT_S8_UINT:begin
   result:=TImageType.Stencil;
  end;
  VK_FORMAT_D16_UNORM_S8_UINT,
  VK_FORMAT_D24_UNORM_S8_UINT,
  VK_FORMAT_D32_SFLOAT_S8_UINT:begin
   result:=TImageType.DepthStencil;
  end;
  else begin
   result:=TImageType.Color;
  end;
 end;
end;

function TpvFrameGraph.TImageTypeHelper.GetAspectMask:TVkImageAspectFlags;
begin
 case self of
  TpvFrameGraph.TImageType.Surface:begin
   result:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  end;
  TpvFrameGraph.TImageType.Color:begin
   result:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  end;
  TpvFrameGraph.TImageType.Depth:begin
   result:=TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  end;
  TpvFrameGraph.TImageType.DepthStencil:begin
   result:=TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT) or TVkImageAspectFlags(VK_IMAGE_ASPECT_STENCIL_BIT);
  end;
  TpvFrameGraph.TImageType.Stencil:begin
   result:=TVkImageAspectFlags(VK_IMAGE_ASPECT_STENCIL_BIT);
  end;
  else {TpvFrameGraph.TImageType.Undefined:}begin
   result:=TVkImageAspectFlags(0);
  end;
 end;
end;

{ TpvFrameGraph.TImageSize }

class function TpvFrameGraph.TImageSize.CreateEmpty:TImageSize;
begin
 result.Kind:=TpvFrameGraph.TImageSize.TKind.Undefined;
 result.Size:=TpvVector4.Null;
end;

constructor TpvFrameGraph.TImageSize.Create(const aKind:TImageSize.TKind;
                                            const aWidth:TpvFloat=1.0;
                                            const aHeight:TpvFloat=1.0;
                                            const aDepth:TpvFloat=1.0;
                                            const aLayers:TpvFloat=0.0);
begin
 Kind:=aKind;
 Size:=TpvVector4.InlineableCreate(aWidth,aHeight,aDepth,aLayers);
end;

constructor TpvFrameGraph.TImageSize.Create(const aKind:TImageSize.TKind;
                                            const aSize:TpvVector2;
                                            const aDepth:TpvFloat=1.0;
                                            const aLayers:TpvFloat=0.0);
begin
 Kind:=aKind;
 Size:=TpvVector4.InlineableCreate(aSize.x,aSize.y,aDepth,aLayers);
end;

constructor TpvFrameGraph.TImageSize.Create(const aKind:TImageSize.TKind;
                                            const aSize:TpvVector3;
                                            const aLayers:TpvFloat=0.0);
begin
 Kind:=aKind;
 Size:=TpvVector4.InlineableCreate(aSize,aLayers);
end;

constructor TpvFrameGraph.TImageSize.Create(const aKind:TImageSize.TKind;
                                            const aSize:TpvVector4);
begin
 Kind:=aKind;
 Size:=aSize;
end;

class operator TpvFrameGraph.TImageSize.Equal(const aLeft,aRight:TImageSize):boolean;
begin
 result:=(aLeft.Kind=aRight.Kind) and
         (aLeft.Size=aRight.Size);
end;

class operator TpvFrameGraph.TImageSize.NotEqual(const aLeft,aRight:TImageSize):boolean;
begin
 result:=(aLeft.Kind<>aRight.Kind) or
         (aLeft.Size<>aRight.Size);
end;

{ TpvFrameGraph.TQueue.TCommandBuffer }

constructor TpvFrameGraph.TQueue.TCommandBuffer.Create(const aQueue:TQueue);
var InFlightFrameIndex:TpvSizeInt;
begin
 inherited Create;

 fQueue:=aQueue;

 fPhysicalPasses:=TPhysicalPasses.Create;

 fPhysicalPasses.OwnsObjects:=false;

 for InFlightFrameIndex:=0 to fQueue.fFrameGraph.fCountInFlightFrames-1 do begin
  fCommandBuffers[InFlightFrameIndex]:=nil;
  fSignallingSemaphores[InFlightFrameIndex].Initialize;
  fSignallingSemaphoreHandles[InFlightFrameIndex].Initialize;
 end;

 fWaitingSemaphores.Initialize;

 fWaitingSemaphoreHandles.Initialize;

 fWaitingSemaphoreDstStageMasks.Initialize;

 fMustResetEvents:=false;

end;

destructor TpvFrameGraph.TQueue.TCommandBuffer.Destroy;
var InFlightFrameIndex,Index:TpvSizeInt;
begin

 fWaitingSemaphores.Finalize;

 fWaitingSemaphoreHandles.Finalize;

 fWaitingSemaphoreDstStageMasks.Finalize;

 FreeAndNil(fPhysicalPasses);

 for InFlightFrameIndex:=0 to fQueue.fFrameGraph.fCountInFlightFrames-1 do begin
  for Index:=0 to fSignallingSemaphores[InFlightFrameIndex].Count-1 do begin
   FreeAndNil(fSignallingSemaphores[InFlightFrameIndex].Items[Index]);
  end;
  fSignallingSemaphores[InFlightFrameIndex].Finalize;
  fSignallingSemaphoreHandles[InFlightFrameIndex].Finalize;
  FreeAndNil(fCommandBuffers[InFlightFrameIndex]);
 end;

 inherited Destroy;
end;

procedure TpvFrameGraph.TQueue.TCommandBuffer.AcquirePersistentResources;
begin
end;

procedure TpvFrameGraph.TQueue.TCommandBuffer.ReleasePersistentResources;
begin
end;

procedure TpvFrameGraph.TQueue.TCommandBuffer.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to fQueue.fFrameGraph.fCountInFlightFrames-1 do begin
  fCommandBuffers[InFlightFrameIndex]:=TpvVulkanCommandBuffer.Create(fQueue.fCommandBufferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  fQueue.fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fCommandBuffers[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_COMMAND_BUFFER,'FrameGraph.Queue.CommandBuffers['+IntToStr(InFlightFrameIndex)+']');
  fSignallingSemaphores[InFlightFrameIndex].Clear;
 end;
end;

procedure TpvFrameGraph.TQueue.TCommandBuffer.ReleaseVolatileResources;
var InFlightFrameIndex,Index:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to fQueue.fFrameGraph.fCountInFlightFrames-1 do begin
  FreeAndNil(fCommandBuffers[InFlightFrameIndex]);
  for Index:=0 to fSignallingSemaphores[InFlightFrameIndex].Count-1 do begin
   FreeAndNil(fSignallingSemaphores[InFlightFrameIndex].Items[Index]);
  end;
 end;
end;

{ TpvFrameGraph.TPhysicalPassCrossEvent }

constructor TpvFrameGraph.TPhysicalPassCrossEvent.Create(const aFrameGraph:TpvFrameGraph;
                                                         const aQueue:TQueue;
                                                         const aFromPhysicalPass:TPhysicalPass;
                                                         const aToPhysicalPass:TPhysicalPass;
                                                         const aStageMask:TVkPipelineStageFlags);
var Index:TpvSizeInt;
begin

 inherited Create;

 fFrameGraph:=aFrameGraph;
 fQueue:=aQueue;
 fFromPhysicalPass:=aFromPhysicalPass;
 fToPhysicalPass:=aToPhysicalPass;
 fStageMask:=aStageMask;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fEvents[Index]:=nil;
 end;

end;

destructor TpvFrameGraph.TPhysicalPassCrossEvent.Destroy;
var Index:TpvSizeInt;
begin
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fEvents[Index]);
 end;
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalPassCrossEvent.AcquireVolatileResources;
var Index:TpvSizeInt;
begin
 for Index:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  fEvents[Index]:=TpvVulkanEvent.Create(fFrameGraph.fVulkanDevice);
 end;
end;

procedure TpvFrameGraph.TPhysicalPassCrossEvent.ReleaseVolatileResources;
var Index:TpvSizeInt;
begin
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fEvents[Index]);
 end;
end;

{ TpvFrameGraph.TExternalWaitingOnSemaphore }

constructor TpvFrameGraph.TExternalWaitingOnSemaphore.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create; 
 fFrameGraph:=aFrameGraph;
 FillChar(fInFlightFrameSemaphores,SizeOf(TInFlightFrameSemaphores),#0); 
end;

destructor TpvFrameGraph.TExternalWaitingOnSemaphore.Destroy;
begin
 inherited Destroy;
end;

function TpvFrameGraph.TExternalWaitingOnSemaphore.GetInFlightFrameSemaphore(const aIndex:TpvSizeInt):TpvVulkanSemaphore;
begin
 result:=fInFlightFrameSemaphores[aIndex];
end;

procedure TpvFrameGraph.TExternalWaitingOnSemaphore.SetInFlightFrameSemaphore(const aIndex:TpvSizeInt;const aInFlightFrameSemaphore:TpvVulkanSemaphore);
begin
 fInFlightFrameSemaphores[aIndex]:=aInFlightFrameSemaphore;
end;

{ TpvFrameGraph.TExternalWaitingOnSemaphoreReference }

constructor TpvFrameGraph.TExternalWaitingOnSemaphoreReference.Create(const aFrameGraph:TpvFrameGraph;
                                                                      const aExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;
                                                                      const aStageMask:TVkPipelineStageFlags);
begin
 inherited Create;
 fFrameGraph:=aFrameGraph;
 fExternalWaitingOnSemaphore:=aExternalWaitingOnSemaphore;
 fStageMask:=aStageMask;
end;

destructor TpvFrameGraph.TExternalWaitingOnSemaphoreReference.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TQueue }

constructor TpvFrameGraph.TQueue.Create(const aFrameGraph:TpvFrameGraph;
                                        const aPhysicalQueue:TpvVulkanQueue);
begin

 inherited Create;

 fFrameGraph:=aFrameGraph;

 fPhysicalQueue:=aPhysicalQueue;

 fPhysicalPasses:=TPhysicalPasses.Create;
 fPhysicalPasses.OwnsObjects:=false;

 fCommandPool:=TpvVulkanCommandPool.Create(fFrameGraph.fVulkanDevice,
                                           fPhysicalQueue.QueueFamilyIndex,
                                           TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fCommandPool.Handle,TVkObjectType.VK_OBJECT_TYPE_COMMAND_POOL,'FrameGraph.Queue.CommandPool');

 fCommandBufferCommandPool:=nil;

 fCommandBuffers:=TCommandBuffers.Create;
 fCommandBuffers.OwnsObjects:=true;

 fResetBuffer:=nil;

 fPhysicalPassCrossEvents:=TPhysicalPassCrossEvents.Create(false);

end;

destructor TpvFrameGraph.TQueue.Destroy;
begin

 FreeAndNil(fCommandBuffers);

 FreeAndNil(fPhysicalPasses);

 FreeAndNil(fCommandBufferCommandPool);

 FreeAndNil(fCommandPool);

 FreeAndNil(fPhysicalPassCrossEvents);

 inherited Destroy;

end;

procedure TpvFrameGraph.TQueue.AcquirePersistentResources;
var CommandBuffer:TCommandBuffer;
begin
 for CommandBuffer in fCommandBuffers do begin
  CommandBuffer.AcquirePersistentResources;
 end;
end;

procedure TpvFrameGraph.TQueue.ReleasePersistentResources;
var CommandBuffer:TCommandBuffer;
begin
 for CommandBuffer in fCommandBuffers do begin
  CommandBuffer.ReleasePersistentResources;
 end;
end;

procedure TpvFrameGraph.TQueue.AcquireVolatileResources;
var CommandBuffer:TCommandBuffer;
begin
 fCommandBufferCommandPool:=TpvVulkanCommandPool.Create(fFrameGraph.fVulkanDevice,
                                                        fPhysicalQueue.QueueFamilyIndex,
                                                        TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fCommandBufferCommandPool.Handle,TVkObjectType.VK_OBJECT_TYPE_COMMAND_POOL,'FrameGraph.Queue.CommandBufferCommandPool');
 for CommandBuffer in fCommandBuffers do begin
  CommandBuffer.AcquireVolatileResources;
 end;
end;

procedure TpvFrameGraph.TQueue.ReleaseVolatileResources;
var CommandBuffer:TCommandBuffer;
begin
 for CommandBuffer in fCommandBuffers do begin
  CommandBuffer.ReleaseVolatileResources;
 end;
 FreeAndNil(fCommandBufferCommandPool);
end;

procedure TpvFrameGraph.TQueue.ResetEvents(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
var PhysicalPassCrossEvent:TPhysicalPassCrossEvent;
begin
 for PhysicalPassCrossEvent in fPhysicalPassCrossEvents do begin
  aCommandBuffer.CmdResetEvent(PhysicalPassCrossEvent.fEvents[aInFlightFrameIndex].Handle,PhysicalPassCrossEvent.fStageMask);
 end;
end;

{ TpvFrameGraph.TExternalData }

constructor TpvFrameGraph.TExternalData.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create;
 fFrameGraph:=aFrameGraph;
 if fFrameGraph.fExternalDataList.IndexOf(self)<0 then begin
  fFrameGraph.fExternalDataList.Add(self);
 end;
end;

destructor TpvFrameGraph.TExternalData.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TExternalImageData }

constructor TpvFrameGraph.TExternalImageData.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create(aFrameGraph);
 fVulkanImages:=TVulkanImages.Create;
 fVulkanImages.OwnsObjects:=false;
end;

destructor TpvFrameGraph.TExternalImageData.Destroy;
begin
 FreeAndNil(fVulkanImages);
 inherited Destroy;
end;

{ TpvFrameGraph.TExternalBufferData }

constructor TpvFrameGraph.TExternalBufferData.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create(aFrameGraph);
 fVulkanBuffers:=TVulkanBuffers.Create;
 fVulkanBuffers.OwnsObjects:=false;
end;

destructor TpvFrameGraph.TExternalBufferData.Destroy;
begin
 FreeAndNil(fVulkanBuffers);
 inherited Destroy;
end;

{ TpvFrameGraph.TResourceType }

constructor TpvFrameGraph.TResourceType.Create(const aFrameGraph:TpvFrameGraph;
                                               const aName:TpvRawByteString;
                                               const aPersistent:boolean);
begin
 inherited Create;
 if length(trim(String(aName)))=0 then begin
  raise EpvFrameGraphEmptyName.Create('Empty name');
 end;
 if aFrameGraph.fResourceTypeNameHashMap.ExistKey(aName) then begin
  raise EpvFrameGraphDuplicateName.Create('Duplicate name');
 end;
 fFrameGraph:=aFrameGraph;
 fName:=aName;
 fFrameGraph.fResourceTypes.Add(self);
 fFrameGraph.fResourceTypeNameHashMap.Add(fName,self);
 fPersistent:=aPersistent;
end;

destructor TpvFrameGraph.TResourceType.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TImageResourceType }

constructor TpvFrameGraph.TImageResourceType.Create(const aFrameGraph:TpvFrameGraph;
                                                    const aName:TpvRawByteString;
                                                    const aPersistent:boolean;
                                                    const aFormat:TVkFormat;
                                                    const aSamples:TVkSampleCountFlagBits;
                                                    const aImageType:TImageType;
                                                    const aImageSize:TImageSize;
                                                    const aImageUsage:TVkImageUsageFlags;
                                                    const aCountMipMapLevels:TVkUInt32;
                                                    const aComponents:TVkComponentMapping;
                                                    const aInitialLayout:TVkImageLayout;
                                                    const aFinalLayout:TVkImageLayout;
                                                    const aAdditionalFormat:TVkFormat);
begin
 Create(aFrameGraph,
        aName,
        aPersistent);
 fFormat:=aFormat;
 fSamples:=aSamples;
 fImageType:=aImageType;
 fImageSize:=aImageSize;
 fImageUsage:=aImageUsage;
 fCountMipMapLevels:=aCountMipMapLevels;
 fComponents:=aComponents;
 fInitialLayout:=aInitialLayout;
 fFinalLayout:=aFinalLayout;
 fAdditionalFormat:=aAdditionalFormat;
end;

constructor TpvFrameGraph.TImageResourceType.Create(const aFrameGraph:TpvFrameGraph;
                                                    const aName:TpvRawByteString;
                                                    const aPersistent:boolean;
                                                    const aFormat:TVkFormat;
                                                    const aSamples:TVkSampleCountFlagBits;
                                                    const aImageType:TImageType;
                                                    const aImageSize:TImageSize;
                                                    const aImageUsage:TVkImageUsageFlags;
                                                    const aCountMipMapLevels:TVkUInt32;
                                                    const aInitialLayout:TVkImageLayout;
                                                    const aFinalLayout:TVkImageLayout;
                                                    const aAdditionalFormat:TVkFormat);
begin
 Create(aFrameGraph,
        aName,
        aPersistent,
        aFormat,
        aSamples,
        aImageType,
        aImageSize,
        aImageUsage,
        aCountMipMapLevels,
        TVkComponentMapping.Create(VK_COMPONENT_SWIZZLE_R,
                                   VK_COMPONENT_SWIZZLE_G,
                                   VK_COMPONENT_SWIZZLE_B,
                                   VK_COMPONENT_SWIZZLE_A),
        aInitialLayout,
        aFinalLayout,
        aAdditionalFormat);
end;


destructor TpvFrameGraph.TImageResourceType.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TBufferResourceType }

constructor TpvFrameGraph.TBufferResourceType.Create(const aFrameGraph:TpvFrameGraph;
                                                     const aName:TpvRawByteString;
                                                     const aPersistent:boolean;
                                                     const aSize:TVkDeviceSize;
                                                     const aUsage:TVkBufferUsageFlags;
                                                     const aMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
                                                     const aMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
                                                     const aMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
                                                     const aMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
                                                     const aMemoryRequiredHeapFlags:TVkMemoryHeapFlags;
                                                     const aMemoryPreferredHeapFlags:TVkMemoryHeapFlags;
                                                     const aMemoryAvoidHeapFlags:TVkMemoryHeapFlags;
                                                     const aMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
                                                     const aBufferFlags:TpvVulkanBufferFlags);
begin
 inherited Create(aFrameGraph,aName,aPersistent);
 fSize:=aSize;
 fUsage:=fUsage;
 fMemoryRequiredPropertyFlags:=aMemoryRequiredPropertyFlags;
 fMemoryPreferredPropertyFlags:=aMemoryPreferredPropertyFlags;
 fMemoryAvoidPropertyFlags:=aMemoryAvoidPropertyFlags;
 fMemoryPreferredNotPropertyFlags:=aMemoryPreferredNotPropertyFlags;
 fMemoryRequiredHeapFlags:=aMemoryRequiredHeapFlags;
 fMemoryPreferredHeapFlags:=aMemoryPreferredHeapFlags;
 fMemoryAvoidHeapFlags:=aMemoryAvoidHeapFlags;
 fMemoryPreferredNotHeapFlags:=aMemoryPreferredNotHeapFlags;
 fBufferFlags:=aBufferFlags;
end;

destructor TpvFrameGraph.TBufferResourceType.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TResourcePhysicalData }

constructor TpvFrameGraph.TResourcePhysicalData.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create;
 fFrameGraph:=aFrameGraph;
 fResourceInstanceType:=TResourceInstanceType.Default;
 fExternalData:=nil;
end;

destructor TpvFrameGraph.TResourcePhysicalData.Destroy;
begin
 inherited Destroy;
end;

function TpvFrameGraph.TResourcePhysicalData.GetActiveResourceInstanceType:TResourceInstanceType;
begin
 result:=fResourceInstanceType;
 if result=TResourceInstanceType.Default then begin
  result:=fFrameGraph.fDefaultResourceInstanceType;
 end;
end;

procedure TpvFrameGraph.TResourcePhysicalData.AcquirePersistentResources;
begin
end;

procedure TpvFrameGraph.TResourcePhysicalData.ReleasePersistentResources;
begin
end;

procedure TpvFrameGraph.TResourcePhysicalData.AcquireVolatileResources;
begin
end;

procedure TpvFrameGraph.TResourcePhysicalData.ReleaseVolatileResources;
begin
end;

{ TpvFrameGraph.TResourcePhysicalImageData }

constructor TpvFrameGraph.TResourcePhysicalImageData.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create(aFrameGraph);
 fIsSurface:=false;
 fImageUsageFlags:=TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT);
 fRequestedFormat:=VK_FORMAT_B8G8R8A8_UNORM;
 fFormat:=VK_FORMAT_B8G8R8A8_UNORM;
 fExtent:=TVkExtent3D.Create(1,1,1);
 fCountMipMaps:=1;
 fCountArrayLayers:=1;
 fTextureArray:=false;
 fSamples:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);
 fTiling:=VK_IMAGE_TILING_OPTIMAL;
 fInitialLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
 fImageCreateFlags:=TVkImageCreateFlags(0);
 fImageType:=VK_IMAGE_TYPE_2D;
 fSharingMode:=VK_SHARING_MODE_EXCLUSIVE;
end;

destructor TpvFrameGraph.TResourcePhysicalImageData.Destroy;
var InFlightFrameIndex,SwapChainImageIndex:TpvSizeInt;
begin
 if assigned(fExternalData) or fIsSurface then begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if fVulkanImageViews[InFlightFrameIndex]<>fVulkanAdditionalFormatImageViews[InFlightFrameIndex] then begin
    FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
    FreeAndNil(fVulkanAdditionalFormatImageViews[InFlightFrameIndex]);
   end else begin
    FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
    fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
   end;
   fVulkanImages[InFlightFrameIndex]:=nil;
   fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
  end;
  if fIsSurface then begin
   for SwapChainImageIndex:=0 to length(fVulkanSurfaceImages)-1 do begin
    FreeAndNil(fVulkanSurfaceImageViews[SwapChainImageIndex]);
    fVulkanSurfaceImages[SwapChainImageIndex]:=nil;
   end;
  end;
 end else begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin
    fVulkanImages[InFlightFrameIndex]:=nil;
    fVulkanImageViews[InFlightFrameIndex]:=nil;
    fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
    fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   end else begin
    if fVulkanImageViews[InFlightFrameIndex]<>fVulkanAdditionalFormatImageViews[InFlightFrameIndex] then begin
     FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
     FreeAndNil(fVulkanAdditionalFormatImageViews[InFlightFrameIndex]);
    end else begin
     FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
     fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
    end;
    FreeAndNil(fVulkanImages[InFlightFrameIndex]);
    fFrameGraph.fVulkanDevice.MemoryManager.FreeMemoryBlock(fVulkanMemoryBlocks[InFlightFrameIndex]);
    fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   end;
  end;
 end;
 fVulkanSurfaceImageViews:=nil;
 fVulkanSurfaceImages:=nil;
 inherited Destroy;
end;

function TpvFrameGraph.TResourcePhysicalImageData.GetVulkanImage(const aIndex:TpvSizeInt):TpvVulkanImage;
begin
 result:=fVulkanImages[aIndex];
end;

function TpvFrameGraph.TResourcePhysicalImageData.GetVulkanImageView(const aIndex:TpvSizeInt):TpvVulkanImageView;
begin
 result:=fVulkanImageViews[aIndex];
end;

function TpvFrameGraph.TResourcePhysicalImageData.GetVulkanAdditionalFormatImageView(const aIndex:TpvSizeInt):TpvVulkanImageView;
begin
 result:=fVulkanAdditionalFormatImageViews[aIndex];
end;

function TpvFrameGraph.TResourcePhysicalImageData.GetVulkanMemoryBlock(const aIndex:TpvSizeInt):TpvVulkanDeviceMemoryBlock;
begin
 result:=fVulkanMemoryBlocks[aIndex];
end;

procedure TpvFrameGraph.TResourcePhysicalImageData.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
end;

procedure TpvFrameGraph.TResourcePhysicalImageData.ReleasePersistentResources;
begin
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TResourcePhysicalImageData.AcquireVolatileResources;
var InFlightFrameIndex,SwapChainImageIndex:TpvSizeInt;
    ImageResourceType:TImageResourceType;
    MemoryRequirements:TVkMemoryRequirements;
    MemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    MemoryAllocationType:TpvVulkanDeviceMemoryAllocationType;
    AllocationGroupID:TpvUInt64;
begin

 inherited AcquireVolatileResources;

 Assert(fResourceType is TImageResourceType);

 ImageResourceType:=TImageResourceType(fResourceType);

 case ImageResourceType.fImageSize.Kind of
  TpvFrameGraph.TImageSize.TKind.Absolute:begin
   fExtent.width:=Max(1,round(ImageResourceType.fImageSize.Size.x));
   fExtent.height:=Max(1,round(ImageResourceType.fImageSize.Size.y));
   fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
   AllocationGroupID:=pvAllocationGroupIDFrameGraphImage;
  end;
  TpvFrameGraph.TImageSize.TKind.SurfaceDependent:begin
   fExtent.width:=Max(1,round(ImageResourceType.fImageSize.Size.x*fFrameGraph.fSurfaceWidth));
   fExtent.height:=Max(1,round(ImageResourceType.fImageSize.Size.y*fFrameGraph.fSurfaceHeight));
   fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
   AllocationGroupID:=pvAllocationGroupIDFrameGraphSurfaceImage;
  end;
  TpvFrameGraph.TImageSize.TKind.SurfaceDependentPreviousPowerOfTwo:begin
   fExtent.width:=Max(1,RoundDownToPowerOfTwo(round(ImageResourceType.fImageSize.Size.x*fFrameGraph.fSurfaceWidth)));
   fExtent.height:=Max(1,RoundDownToPowerOfTwo(round(ImageResourceType.fImageSize.Size.y*fFrameGraph.fSurfaceHeight)));
   fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
   AllocationGroupID:=pvAllocationGroupIDFrameGraphSurfaceImage;
  end;
  TpvFrameGraph.TImageSize.TKind.SurfaceDependentNextPowerOfTwo:begin
   fExtent.width:=Max(1,RoundUpToPowerOfTwo(round(ImageResourceType.fImageSize.Size.x*fFrameGraph.fSurfaceWidth)));
   fExtent.height:=Max(1,RoundUpToPowerOfTwo(round(ImageResourceType.fImageSize.Size.y*fFrameGraph.fSurfaceHeight)));
   fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
   AllocationGroupID:=pvAllocationGroupIDFrameGraphSurfaceImage;
  end;
  TpvFrameGraph.TImageSize.TKind.SurfaceDependentNearestPowerOfTwo:begin
   fExtent.width:=Max(1,RoundNearestToPowerOfTwo(round(ImageResourceType.fImageSize.Size.x*fFrameGraph.fSurfaceWidth)));
   fExtent.height:=Max(1,RoundNearestToPowerOfTwo(round(ImageResourceType.fImageSize.Size.y*fFrameGraph.fSurfaceHeight)));
   fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
   AllocationGroupID:=pvAllocationGroupIDFrameGraphSurfaceImage;
  end;
  else {TpvFrameGraph.TImageSize.TKind.Undefined:}begin
   AllocationGroupID:=pvAllocationGroupIDFrameGraphImage;
  end;
 end;

 if assigned(fExternalData) then begin

  fFormat:=fRequestedFormat;

  if fFormat=VK_FORMAT_UNDEFINED then begin
   case (fResourceType as TImageResourceType).fImageType of
    TImageType.Color:begin
     fFormat:=fFrameGraph.fSurfaceColorFormat;
    end;
    TImageType.Depth,
    TImageType.DepthStencil,
    TImageType.Stencil:begin
     fFormat:=fFrameGraph.fSurfaceDepthFormat;
    end;
   end;
  end;

  for InFlightFrameIndex:=0 to Min(Max(fFrameGraph.fCountInFlightFrames,1),MaxInFlightFrames)-1 do begin
   fVulkanImages[InFlightFrameIndex]:=TExternalImageData(fExternalData).fVulkanImages[InFlightFrameIndex mod TExternalImageData(fExternalData).fVulkanImages.Count];
   fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fFrameGraph.fVulkanDevice,
                                                                    fVulkanImages[InFlightFrameIndex],
                                                                    fImageViewType,
                                                                    fFormat,
                                                                    fComponents.r,
                                                                    fComponents.g,
                                                                    fComponents.b,
                                                                    fComponents.a,
                                                                    fImageSubresourceRange.aspectMask,
                                                                    0,
                                                                    fCountMipMaps,
                                                                    0,
                                                                    fCountArrayLayers);
   fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanImageViews[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_IMAGE_VIEW,fResourceType.Name+'['+IntToStr(InFlightFrameIndex)+']');
   fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=fVulkanImageViews[InFlightFrameIndex];
  end;

 end else if fIsSurface then begin

  fFormat:=fFrameGraph.fSurfaceColorFormat;

  SetLength(fVulkanSurfaceImageViews,Max(fFrameGraph.fCountSurfaceImages,1));
  SetLength(fVulkanSurfaceImages,Max(fFrameGraph.fCountSurfaceImages,1));

  for SwapChainImageIndex:=0 to Max(fFrameGraph.fCountSurfaceImages,1)-1 do begin
   fVulkanSurfaceImages[SwapChainImageIndex]:=fFrameGraph.fSurfaceImages[SwapChainImageIndex];
   fVulkanSurfaceImageViews[SwapChainImageIndex]:=TpvVulkanImageView.Create(fFrameGraph.fVulkanDevice,
                                                                            fVulkanSurfaceImages[SwapChainImageIndex],
                                                                            fImageViewType,
                                                                            fFormat,
                                                                            fComponents.r,
                                                                            fComponents.g,
                                                                            fComponents.b,
                                                                            fComponents.a,
                                                                            fImageSubresourceRange.aspectMask,
                                                                            0,
                                                                            fCountMipMaps,
                                                                            0,
                                                                            fCountArrayLayers);
   fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanSurfaceImageViews[SwapChainImageIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_IMAGE_VIEW,fResourceType.Name+'['+IntToStr(SwapChainImageIndex)+']');
  end;

  for InFlightFrameIndex:=0 to Min(Max(fFrameGraph.fCountInFlightFrames,1),MaxInFlightFrames)-1 do begin
   fVulkanImages[InFlightFrameIndex]:=nil;
   fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   fVulkanImageViews[InFlightFrameIndex]:=nil;
   fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
  end;

 end else begin

  fFormat:=fRequestedFormat;

  if fFormat=VK_FORMAT_UNDEFINED then begin
   case (fResourceType as TImageResourceType).fImageType of
    TImageType.Color:begin
     fFormat:=fFrameGraph.fSurfaceColorFormat;
    end;
    TImageType.Depth,
    TImageType.DepthStencil,
    TImageType.Stencil:begin
     fFormat:=fFrameGraph.fSurfaceDepthFormat;
    end;
   end;
  end;

  for InFlightFrameIndex:=0 to Min(Max(fFrameGraph.fCountInFlightFrames,1),MaxInFlightFrames)-1 do begin

   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin

    fVulkanImages[InFlightFrameIndex]:=fVulkanImages[0];
    fVulkanImageViews[InFlightFrameIndex]:=fVulkanImageViews[0];
    fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=fVulkanImageViews[0];
    fVulkanMemoryBlocks[InFlightFrameIndex]:=fVulkanMemoryBlocks[0];

   end else begin

    fVulkanImages[InFlightFrameIndex]:=TpvVulkanImage.Create(fFrameGraph.fVulkanDevice,
                                                             TVkImageCreateFlags(TpvInt32(IfThen((fAdditionalFormat<>VK_FORMAT_UNDEFINED) and (fAdditionalFormat<>fFormat),TpvInt32(VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT),TpvInt32(0)))) or
                                                             TVkImageCreateFlags(TpvInt32(IfThen((fExtent.depth<=1) and (fCountArrayLayers=6),TpvInt32(VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT),TpvInt32(0)))),
                                                             fImageType,
                                                             fFormat,
                                                             fExtent.width,
                                                             fExtent.height,
                                                             fExtent.depth,
                                                             fCountMipMaps,
                                                             fCountArrayLayers,
                                                             fSamples,
                                                             fTiling,
                                                             fImageUsageFlags, // or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT),
                                                             fSharingMode,
                                                             fFrameGraph.fQueueFamilyIndices.Count,
                                                             @fFrameGraph.fQueueFamilyIndices.Items[0],
                                                             VK_IMAGE_LAYOUT_UNDEFINED,
                                                             fAdditionalFormat);
    fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanImages[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_IMAGE,fResourceType.Name+'['+IntToStr(InFlightFrameIndex)+']');

    MemoryRequirements:=fFrameGraph.fVulkanDevice.MemoryManager.GetImageMemoryRequirements(fVulkanImages[InFlightFrameIndex].Handle,
                                                                                           RequiresDedicatedAllocation,
                                                                                           PrefersDedicatedAllocation);

    MemoryBlockFlags:=[];

    if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
     Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
    end;

    if fTiling=VK_IMAGE_TILING_OPTIMAL then begin
     MemoryAllocationType:=TpvVulkanDeviceMemoryAllocationType.ImageOptimal;
    end else begin
     MemoryAllocationType:=TpvVulkanDeviceMemoryAllocationType.ImageLinear;
    end;

    MemoryPreferredPropertyFlags:=0;//TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);

    if (fImageUsageFlags and TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT))<>0 then begin
     MemoryPreferredPropertyFlags:=MemoryPreferredPropertyFlags or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT);
    end;

    fVulkanMemoryBlocks[InFlightFrameIndex]:=fFrameGraph.fVulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                                                                         MemoryRequirements.size,
                                                                                                         MemoryRequirements.alignment,
                                                                                                         MemoryRequirements.memoryTypeBits,
                                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                         MemoryPreferredPropertyFlags,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         MemoryAllocationType,
                                                                                                         @fVulkanImages[InFlightFrameIndex].Handle,
                                                                                                         AllocationGroupID,
                                                                                                         'TpvFrameGraph.TResourcePhysicalImageData["'+fResourceType.fName+'"]');
    if not assigned(fVulkanMemoryBlocks[InFlightFrameIndex]) then begin
     raise EpvVulkanMemoryAllocationException.Create('Memory for image resource couldn''t be allocated!');
    end;

    VulkanCheckResult(fFrameGraph.fVulkanDevice.Commands.BindImageMemory(fVulkanImages[InFlightFrameIndex].Device.Handle,
                                                                         fVulkanImages[InFlightFrameIndex].Handle,
                                                                         fVulkanMemoryBlocks[InFlightFrameIndex].MemoryChunk.Handle,
                                                                         fVulkanMemoryBlocks[InFlightFrameIndex].Offset));

    fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fFrameGraph.fVulkanDevice,
                                                                      fVulkanImages[InFlightFrameIndex],
                                                                      fImageViewType,
                                                                      fFormat,
                                                                      fComponents.r,
                                                                      fComponents.g,
                                                                      fComponents.b,
                                                                      fComponents.a,
                                                                      fImageSubresourceRange.aspectMask,
                                                                      0,
                                                                      fCountMipMaps,
                                                                      0,
                                                                      fCountArrayLayers);
    fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanImageViews[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_IMAGE_VIEW,fResourceType.Name+'['+IntToStr(InFlightFrameIndex)+']');

    if (fAdditionalFormat<>VK_FORMAT_UNDEFINED) and (fAdditionalFormat<>fFormat) then begin
     fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fFrameGraph.fVulkanDevice,
                                                                                      fVulkanImages[InFlightFrameIndex],
                                                                                      fImageViewType,
                                                                                      fAdditionalFormat,
                                                                                      fComponents.r,
                                                                                      fComponents.g,
                                                                                      fComponents.b,
                                                                                      fComponents.a,
                                                                                      fImageSubresourceRange.aspectMask,
                                                                                      0,
                                                                                      fCountMipMaps,
                                                                                      0,
                                                                                      fCountArrayLayers);
    end else begin
     fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=fVulkanImageViews[InFlightFrameIndex];
    end;

    if fFirstInitialLayout=VK_IMAGE_LAYOUT_UNDEFINED then begin
{    fVulkanImages[InFlightFrameIndex].SetLayout(fImageSubresourceRange.aspectMask,
                                                  VK_IMAGE_LAYOUT_UNDEFINED,
                                                  VK_IMAGE_LAYOUT_GENERAL,
                                                  TVkAccessFlags(0),
                                                  TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
                                                  TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                  fFrameGraph.fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits or
                                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                                  nil,
                                                  fFrameGraph.fVulkanUniversalQueueCommandBuffer,
                                                  fFrameGraph.fUniversalQueue.fPhysicalQueue,
                                                  fFrameGraph.fVulkanUniversalQueueCommandBufferFence,
                                                  true);}
    end else begin
     if (fImageUsageFlags and TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT))<>0 then begin
      fVulkanImages[InFlightFrameIndex].SetLayout(fImageSubresourceRange.aspectMask,
                                                   VK_IMAGE_LAYOUT_UNDEFINED,
                                                   fFirstInitialLayout,
                                                   TVkAccessFlags(0),
                                                   TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                                                   TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT),
                                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                   fFrameGraph.fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                                   nil,
                                                   fFrameGraph.fVulkanUniversalQueueCommandBuffer,
                                                   fFrameGraph.fUniversalQueue.fPhysicalQueue,
                                                   fFrameGraph.fVulkanUniversalQueueCommandBufferFence,
                                                   true);
     end else begin
      case fFirstInitialLayout of
       VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:begin
        fVulkanImages[InFlightFrameIndex].SetLayout(fImageSubresourceRange.aspectMask,
                                                     VK_IMAGE_LAYOUT_UNDEFINED,
                                                     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                                     TVkAccessFlags(0),
                                                     TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                     nil,
                                                     fFrameGraph.fVulkanUniversalQueueCommandBuffer,
                                                     fFrameGraph.fUniversalQueue.fPhysicalQueue,
                                                     fFrameGraph.fVulkanUniversalQueueCommandBufferFence,
                                                     true);
       end;
       VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:begin
        fVulkanImages[InFlightFrameIndex].SetLayout(fImageSubresourceRange.aspectMask,
                                                     VK_IMAGE_LAYOUT_UNDEFINED,
                                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                                     TVkAccessFlags(0),
                                                     TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                                     nil,
                                                     fFrameGraph.fVulkanUniversalQueueCommandBuffer,
                                                     fFrameGraph.fUniversalQueue.fPhysicalQueue,
                                                     fFrameGraph.fVulkanUniversalQueueCommandBufferFence,
                                                     true);
       end;
       else begin
        raise EpvVulkanException.Create('Invalid frame buffer attachment');
       end;
      end;
     end;
    end;

   end;

  end;

 end;

end;

procedure TpvFrameGraph.TResourcePhysicalImageData.ReleaseVolatileResources;
var InFlightFrameIndex,SwapChainImageIndex:TpvSizeInt;
begin
 if assigned(fExternalData) or fIsSurface then begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if fVulkanImageViews[InFlightFrameIndex]<>fVulkanAdditionalFormatImageViews[InFlightFrameIndex] then begin
    FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
    FreeAndNil(fVulkanAdditionalFormatImageViews[InFlightFrameIndex]);
   end else begin
    FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
    fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
   end;
   fVulkanImages[InFlightFrameIndex]:=nil;
   fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
  end;
  if fIsSurface then begin
   for SwapChainImageIndex:=0 to length(fVulkanSurfaceImageViews)-1 do begin
    FreeAndNil(fVulkanSurfaceImageViews[SwapChainImageIndex]);
    fVulkanSurfaceImages[SwapChainImageIndex]:=nil;
   end;
  end;
 end else begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin
    fVulkanImages[InFlightFrameIndex]:=nil;
    fVulkanImageViews[InFlightFrameIndex]:=nil;
    fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
    fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   end else begin
    if fVulkanImageViews[InFlightFrameIndex]<>fVulkanAdditionalFormatImageViews[InFlightFrameIndex] then begin
     FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
     FreeAndNil(fVulkanAdditionalFormatImageViews[InFlightFrameIndex]);
    end else begin
     FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
     fVulkanAdditionalFormatImageViews[InFlightFrameIndex]:=nil;
    end;
    FreeAndNil(fVulkanImages[InFlightFrameIndex]);
    fFrameGraph.fVulkanDevice.MemoryManager.FreeMemoryBlock(fVulkanMemoryBlocks[InFlightFrameIndex]);
    fVulkanMemoryBlocks[InFlightFrameIndex]:=nil;
   end;
  end;
 end;
 fVulkanSurfaceImageViews:=nil;
 fVulkanSurfaceImages:=nil;
 inherited ReleaseVolatileResources;
end;

{ TpvFrameGraph.TResourcePhysicalBufferData }

constructor TpvFrameGraph.TResourcePhysicalBufferData.Create(const aFrameGraph:TpvFrameGraph);
var InFlightFrameIndex:TpvSizeInt;
begin
 inherited Create(aFrameGraph);
 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  fVulkanBuffers[InFlightFrameIndex]:=nil;
 end;
end;

destructor TpvFrameGraph.TResourcePhysicalBufferData.Destroy;
var InFlightFrameIndex:TpvSizeInt;
begin
 if assigned(fExternalData) then begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   fVulkanBuffers[InFlightFrameIndex]:=nil;
  end;
 end else begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin
    fVulkanBuffers[InFlightFrameIndex]:=nil;
   end else begin
    FreeAndNil(fVulkanBuffers[InFlightFrameIndex]);
   end;
  end;
 end;
 inherited Destroy;
end;

function TpvFrameGraph.TResourcePhysicalBufferData.GetVulkanBuffer(const aIndex:TpvSizeInt):TpvVulkanBuffer;
begin
 result:=fVulkanBuffers[aIndex];
end;

procedure TpvFrameGraph.TResourcePhysicalBufferData.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
end;

procedure TpvFrameGraph.TResourcePhysicalBufferData.ReleasePersistentResources;
begin
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TResourcePhysicalBufferData.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 inherited AcquireVolatileResources;
 if assigned(fExternalData) then begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   fVulkanBuffers[InFlightFrameIndex]:=TExternalBufferData(fExternalData).fVulkanBuffers[InFlightFrameIndex mod TExternalBufferData(fExternalData).fVulkanBuffers.Count];
  end;
 end else begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin
    fVulkanBuffers[InFlightFrameIndex]:=fVulkanBuffers[0];
   end else begin
    fVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fFrameGraph.fVulkanDevice,
                                                               fSize,
                                                               fUsage,
                                                               VK_SHARING_MODE_EXCLUSIVE,
                                                               fFrameGraph.fQueueFamilyIndices.Items,
                                                               fMemoryRequiredPropertyFlags,
                                                               fMemoryPreferredPropertyFlags,
                                                               fMemoryAvoidPropertyFlags,
                                                               fMemoryPreferredNotPropertyFlags,
                                                               fMemoryRequiredHeapFlags,
                                                               fMemoryPreferredHeapFlags,
                                                               fMemoryAvoidHeapFlags,
                                                               fMemoryPreferredNotHeapFlags,
                                                               fBufferFlags,
                                                               0,
                                                               pvAllocationGroupIDFrameGraphBuffer,
                                                               'TpvFrameGraph["'+fResourceType.Name+'"]['+IntToStr(InFlightFrameIndex)+']');
    fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanBuffers[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_BUFFER,fResourceType.Name+'['+IntToStr(InFlightFrameIndex)+']');
   end;
  end;
 end;
end;

procedure TpvFrameGraph.TResourcePhysicalBufferData.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 if assigned(fExternalData) then begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   fVulkanBuffers[InFlightFrameIndex]:=nil;
  end;
 end else begin
  for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
   if (GetActiveResourceInstanceType=TResourceInstanceType.SingleInstance) and
      (InFlightFrameIndex>0) then begin
    fVulkanBuffers[InFlightFrameIndex]:=nil;
   end else begin
    FreeAndNil(fVulkanBuffers[InFlightFrameIndex]);
   end;
  end;
 end;
 inherited ReleaseVolatileResources;
end;

{ TpvFrameGraph.TResourceAliasGroup }

constructor TpvFrameGraph.TResourceAliasGroup.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create;
 fFrameGraph:=aFrameGraph;
 fFrameGraph.fResourceAliasGroups.Add(self);
 fResourceType:=nil;
 fResources:=TResourceList.Create;
 fResources.OwnsObjects:=false;
 fResourcePhysicalData:=nil;
end;

destructor TpvFrameGraph.TResourceAliasGroup.Destroy;
begin
 FreeAndNil(fResources);
 FreeAndNil(fResourcePhysicalData);
 inherited Destroy;
end;

procedure TpvFrameGraph.TResourceAliasGroup.AcquirePersistentResources;
begin
 if assigned(fResourcePhysicalData) then begin
  fResourcePhysicalData.AcquirePersistentResources;
 end;
end;

procedure TpvFrameGraph.TResourceAliasGroup.ReleasePersistentResources;
begin
 if assigned(fResourcePhysicalData) then begin
  fResourcePhysicalData.ReleasePersistentResources;
 end;
end;

procedure TpvFrameGraph.TResourceAliasGroup.AcquireVolatileResources;
begin
 if assigned(fResourcePhysicalData) then begin
  fResourcePhysicalData.AcquireVolatileResources;
 end;
end;

procedure TpvFrameGraph.TResourceAliasGroup.ReleaseVolatileResources;
begin
 if assigned(fResourcePhysicalData) then begin
  fResourcePhysicalData.ReleaseVolatileResources;
 end;
end;

{ TpvFrameGraph.TResource }

constructor TpvFrameGraph.TResource.Create(const aFrameGraph:TpvFrameGraph;
                                           const aName:TpvRawByteString;
                                           const aResourceType:TResourceType=nil;
                                           const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default);
begin

 inherited Create;

 if length(trim(String(aName)))=0 then begin
  raise EpvFrameGraphEmptyName.Create('Empty name');
 end;

 if aFrameGraph.fResourceNameHashMap.ExistKey(aName) then begin
  raise EpvFrameGraphDuplicateName.Create('Duplicate name');
 end;

 fFrameGraph:=aFrameGraph;

 fName:=aName;

 fResourceType:=aResourceType;

 fResourceInstanceType:=aResourceInstanceType;

 fResourceTransitions:=TResourceTransitionList.Create;
 fResourceTransitions.OwnsObjects:=false;

 fMinimumTopologicalSortPassIndex:=High(TpvSizeInt);
 fMaximumTopologicalSortPassIndex:=Low(TpvSizeInt);

 fMinimumPhysicalPassStepIndex:=High(TpvSizeInt);
 fMaximumPhysicalPassStepIndex:=Low(TpvSizeInt);

//fLayout:=VK_IMAGE_LAYOUT_UNDEFINED;

 fLayoutHistory:=TLayoutHistory.Create(VK_IMAGE_LAYOUT_UNDEFINED);

 fUsed:=false;

 fFrameGraph.fResources.Add(self);

 fFrameGraph.fResourceNameHashMap.Add(fName,self);

end;

constructor TpvFrameGraph.TResource.Create(const aFrameGraph:TpvFrameGraph;
                                           const aName:TpvRawByteString;
                                           const aResourceTypeName:TpvRawByteString;
                                           const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default);
begin
 Create(aFrameGraph,
        aName,
        aFrameGraph.ResourceTypeByName[aResourceTypeName],
        aResourceInstanceType);
end;

destructor TpvFrameGraph.TResource.Destroy;
begin
 FreeAndNil(fResourceTransitions);
 FreeAndNil(fLayoutHistory);
 inherited Destroy;
end;

{ TpvFrameGraph.TResourceTransitionList }

function TpvFrameGraph.TResourceTransitionList.HasPhysicalPassesIntersectionWith(const aWith:TpvFrameGraph.TResourceTransitionList):boolean;
var Index,OtherIndex:TpvSizeInt;
    ResourceTransitions:array[0..1] of TpvFrameGraph.TResourceTransition;
begin
 for Index:=0 to Count-1 do begin
  ResourceTransitions[0]:=Items[Index];
  for OtherIndex:=0 to aWith.Count-1 do begin
   ResourceTransitions[1]:=aWith.Items[OtherIndex];
   if (ResourceTransitions[0]=ResourceTransitions[1]) or
      (ResourceTransitions[0].fPass=ResourceTransitions[1].fPass) or
      (ResourceTransitions[0].fPass.fPhysicalPass=ResourceTransitions[1].fPass.fPhysicalPass) then begin
    result:=true;
    exit;
   end;
  end;
 end;
 result:=false;
end;

function TpvFrameGraph.TResourceTransitionList.MergeCompatibleWith(const aWith:TpvFrameGraph.TResourceTransitionList):boolean;
var Index,OtherIndex:TpvSizeInt;
    ResourceTransitions:array[0..1] of TpvFrameGraph.TResourceTransition;
begin
 for Index:=0 to Count-1 do begin
  ResourceTransitions[0]:=Items[Index];
  for OtherIndex:=0 to aWith.Count-1 do begin
   ResourceTransitions[1]:=aWith.Items[OtherIndex];
   if ((ResourceTransitions[0].fKind in TpvFrameGraph.TResourceTransition.AllImages)<>(ResourceTransitions[1].Kind in TpvFrameGraph.TResourceTransition.AllImages)) or
      ((ResourceTransitions[0].fKind in TpvFrameGraph.TResourceTransition.AllBuffers)<>(ResourceTransitions[1].Kind in TpvFrameGraph.TResourceTransition.AllBuffers)) then begin
    result:=false;
    exit;
   end else begin
    if (ResourceTransitions[0].fKind in TpvFrameGraph.TResourceTransition.AllImages) and
       (ResourceTransitions[1].fKind in TpvFrameGraph.TResourceTransition.AllImages) then begin
     if (TpvFrameGraph.TResourceTransition.TFlag.Attachment in ResourceTransitions[0].fFlags)<>(TpvFrameGraph.TResourceTransition.TFlag.Attachment in ResourceTransitions[1].fFlags) then begin
      result:=false;
      exit;
     end;
    end;
   end;
  end;
 end;
 result:=true;
end;

{ TpvFrameGraph.TResourceTransition }

constructor TpvFrameGraph.TResourceTransition.Create(const aFrameGraph:TpvFrameGraph;
                                                     const aPass:TPass;
                                                     const aResource:TResource;
                                                     const aKind:TKind;
                                                     const aFlags:TFlags);
var UsedFlags:TpvUInt32;
begin

 inherited Create;

 fFrameGraph:=aFrameGraph;

 fFrameGraph.fResourceTransitions.Add(self);

 fPass:=aPass;

 fResource:=aResource;

 fKind:=aKind;

 fFlags:=aFlags;

 fResource.fResourceTransitions.Add(self);

 fPass.fResourceTransitions.Add(self);

 UsedFlags:=0;
 if fKind in TpvFrameGraph.TResourceTransition.AllImageInputs then begin
  if TpvFrameGraph.TResourceTransition.TFlag.Attachment in fFlags then begin
   UsedFlags:=UsedFlags or TpvFrameGraph.UsedAsImageDepthInputAttachmentFlag;
  end else begin
   UsedFlags:=UsedFlags or TpvFrameGraph.UsedAsImageDepthInputNonAttachmentFlag;
  end;
 end;
 fResource.fUsedFlags:=fResource.fUsedFlags or UsedFlags;

end;

constructor TpvFrameGraph.TResourceTransition.Create(const aFrameGraph:TpvFrameGraph;
                                                     const aPass:TPass;
                                                     const aResource:TResource;
                                                     const aKind:TKind;
                                                     const aFlags:TFlags;
                                                     const aLayout:TVkImageLayout;
                                                     const aLoadOp:TLoadOp);
begin
 Create(aFrameGraph,aPass,aResource,aKind,aFlags);
 fLayout:=aLayout;
 fLoadOp:=aLoadOp;
end;

constructor TpvFrameGraph.TResourceTransition.Create(const aFrameGraph:TpvFrameGraph;
                                                     const aPass:TPass;
                                                     const aResource:TResource;
                                                     const aKind:TKind;
                                                     const aFlags:TFlags;
                                                     const aPipelineStage:TVkPipelineStageFlags;
                                                     const aAccessFlags:TVkAccessFlags;
                                                     const aBufferSubresourceRange:TBufferSubresourceRange);
begin
 Create(aFrameGraph,aPass,aResource,aKind,aFlags);
 fPipelineStage:=aPipelineStage;
 fAccessFlags:=aAccessFlags;
 fBufferSubresourceRange:=aBufferSubresourceRange;
end;

destructor TpvFrameGraph.TResourceTransition.Destroy;
begin
 inherited Destroy;
end;

{ TpvFrameGraph.TPass.TUsedResource }

constructor TpvFrameGraph.TPass.TUsedResource.Create(const aPass:TPass;
                                                     const aResourceTransition:TResourceTransition);
begin
 inherited Create;
 fFrameGraph:=aPass.fFrameGraph;
 fPass:=aPass;
 fResourceTransition:=aResourceTransition;
 fResource:=fResourceTransition.fResource;
 fResourceType:=fResource.fResourceType;
 fResourcePhysicalData:=nil;
end;

destructor TpvFrameGraph.TPass.TUsedResource.Destroy;
begin
 inherited Destroy;
end;

procedure TpvFrameGraph.TPass.TUsedResource.Finish;
begin
 if assigned(fResource.fResourceAliasGroup) then begin
  fResourcePhysicalData:=fResource.fResourceAliasGroup.fResourcePhysicalData;
 end;
end;

function TpvFrameGraph.TPass.TUsedResource.AdjustInFlightFrameIndex(const aInFlightFrameIndex:TpvSizeInt):TpvSizeInt;
var Offset:TpvSizeInt;
begin
 Offset:=(ord(TpvFrameGraph.TResourceTransition.TFlag.NextFrameOutput in fResourceTransition.fFlags) and 1)-
         (ord(TpvFrameGraph.TResourceTransition.TFlag.PreviousFrameInput in fResourceTransition.fFlags) and 1);
 result:=fFrameGraph.ConvertRelativeToAbsoluteInFlightFrameIndex(aInFlightFrameIndex,Offset);
end;

{ TpvFrameGraph.TPass.TUsedImageResource }

function TpvFrameGraph.TPass.TUsedImageResource.GetVulkanImage(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImage;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fVulkanImages[AdjustInFlightFrameIndex(aInFlightFrameIndex)];
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetVulkanImageView(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImageView;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fVulkanImageViews[AdjustInFlightFrameIndex(aInFlightFrameIndex)];
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetVulkanAdditionalFormatImageView(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanImageView;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fVulkanAdditionalFormatImageViews[AdjustInFlightFrameIndex(aInFlightFrameIndex)];
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetVulkanMemoryBlock(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanDeviceMemoryBlock;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fVulkanMemoryBlocks[AdjustInFlightFrameIndex(aInFlightFrameIndex)];
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetWidth:TpvSizeInt;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fExtent.Width;
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetHeight:TpvSizeInt;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fExtent.Height;
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetDepth:TpvSizeInt;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fExtent.Depth;
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetCountMipMapLevels:TpvSizeInt;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fCountMipMaps;
end;

function TpvFrameGraph.TPass.TUsedImageResource.GetCountArrayLayers:TpvSizeInt;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalImageData));
 result:=TResourcePhysicalImageData(fResourcePhysicalData).fCountArrayLayers;
end;

{ TpvFrameGraph.TPass.TUsedBufferResource }

function TpvFrameGraph.TPass.TUsedBufferResource.GetVulkanBuffer(const aSwapChainBufferIndex:TpvSizeInt):TpvVulkanBuffer;
begin
 Assert(assigned(fResourcePhysicalData) and (fResourcePhysicalData is TResourcePhysicalBufferData));
 result:=TResourcePhysicalBufferData(fResourcePhysicalData).fVulkanBuffers[AdjustInFlightFrameIndex(aSwapChainBufferIndex)];
end;

{ TpvFrameGraph.TPass }

constructor TpvFrameGraph.TPass.Create(const aFrameGraph:TpvFrameGraph);
var Index:TpvSizeInt;
begin

 inherited Create;

 fFrameGraph:=aFrameGraph;
 fName:='';

 fFrameGraph.fPasses.Add(self);

 fQueue:=fFrameGraph.fUniversalQueue;

 fResources:=TResourceList.Create;
 fResources.OwnsObjects:=false;

 fResourceTransitions:=TResourceTransitionList.Create;
 fResourceTransitions.OwnsObjects:=false;

 fUsedResources:=TUsedResources.Create;
 fUsedResources.OwnsObjects:=true;

 fExplicitPassDependencies:=TExplicitPassDependencyList.Create;
 fExplicitPassDependencies.OwnsObjects:=true;

 fExplicitPassNameDependencies:=TExplicitPassNameDependencyList.Create;
 fExplicitPassNameDependencies.OwnsObjects:=true;

 fPreviousPasses:=TPassList.Create;
 fPreviousPasses.OwnsObjects:=false;

 fNextPasses:=TPassList.Create;
 fNextPasses.OwnsObjects:=false;

 fExternalWaitingOnSemaphoreReferences:=TExternalWaitingOnSemaphoreReferences.Create(true);
 
 fFlags:=[TFlag.Enabled];

 fPhysicalPass:=nil;

 for Index:=0 to length(fTimerQueryIndices)-1 do begin
  fTimerQueryIndices[Index]:=-1;
 end;

 for Index:=0 to length(fCPUTimeValues)-1 do begin
  fCPUTimeValues[Index]:=0;
 end;

end;

destructor TpvFrameGraph.TPass.Destroy;
begin

 FreeAndNil(fResources);

 FreeAndNil(fResourceTransitions);

 FreeAndNil(fUsedResources);

 FreeAndNil(fPreviousPasses);

 FreeAndNil(fNextPasses);

 FreeAndNil(fExplicitPassNameDependencies);

 FreeAndNil(fExplicitPassDependencies);

 FreeAndNil(fExternalWaitingOnSemaphoreReferences);

 inherited Destroy;

end;

procedure TpvFrameGraph.TPass.AddExternalWaitingOnSemaphore(const aExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;const aStageMask:TVkPipelineStageFlags); 
var ExternalWaitingOnSemaphoreReference:TExternalWaitingOnSemaphoreReference;
begin
 fExternalWaitingOnSemaphoreReferences.Add(TExternalWaitingOnSemaphoreReference.Create(fFrameGraph,aExternalWaitingOnSemaphore,aStageMask));
end;

function TpvFrameGraph.TPass.GetSeparatePhysicalPass:boolean;
begin
 result:=TFlag.SeparatePhysicalPass in fFlags;
end;

procedure TpvFrameGraph.TPass.SetSeparatePhysicalPass(const aSeparatePhysicalPass:boolean);
begin
 if aSeparatePhysicalPass<>(TFlag.SeparatePhysicalPass in fFlags) then begin
  if aSeparatePhysicalPass then begin
   Include(fFlags,TFlag.SeparatePhysicalPass);
  end else begin
   Exclude(fFlags,TFlag.SeparatePhysicalPass);
  end;
 end;
end;

function TpvFrameGraph.TPass.GetSeparateCommandBuffer:boolean;
begin
 result:=TFlag.SeparateCommandBuffer in fFlags;
end;

procedure TpvFrameGraph.TPass.SetSeparateCommandBuffer(const aSeparateCommandBuffer:boolean);
begin
 if aSeparateCommandBuffer<>(TFlag.SeparateCommandBuffer in fFlags) then begin
  if aSeparateCommandBuffer then begin
   Include(fFlags,TFlag.SeparateCommandBuffer);
  end else begin
   Exclude(fFlags,TFlag.SeparateCommandBuffer);
  end;
 end;
end;

function TpvFrameGraph.TPass.GetToggleable:boolean;
begin
 result:=TFlag.Toggleable in fFlags;
end;

procedure TpvFrameGraph.TPass.SetToggleable(const aToggleable:boolean);
begin
 if aToggleable<>(TFlag.Toggleable in fFlags) then begin
  if aToggleable then begin
   Include(fFlags,TFlag.Toggleable);
  end else begin
   Exclude(fFlags,TFlag.Toggleable);
  end;
 end;
end;

function TpvFrameGraph.TPass.GetEnabled:boolean;
begin
 result:=TFlag.Enabled in fFlags;
end;

procedure TpvFrameGraph.TPass.SetEnabled(const aEnabled:boolean);
begin
 if aEnabled<>(TFlag.Enabled in fFlags) then begin
  if aEnabled then begin
   Include(fFlags,TFlag.Enabled);
  end else begin
   Exclude(fFlags,TFlag.Enabled);
  end;
 end;
end;

function TpvFrameGraph.TPass.GetHasSecondaryBuffers:boolean;
begin
 result:=TFlag.HasSecondaryBuffers in fFlags;
end;

procedure TpvFrameGraph.TPass.SetHasSecondaryBuffers(const aHasSecondaryBuffers:boolean);
begin
 if aHasSecondaryBuffers<>(TFlag.HasSecondaryBuffers in fFlags) then begin
  if aHasSecondaryBuffers then begin
   Include(fFlags,TFlag.HasSecondaryBuffers);
  end else begin
   Exclude(fFlags,TFlag.HasSecondaryBuffers);
  end;
 end;
end;

procedure TpvFrameGraph.TPass.SetName(const aName:TpvRawByteString);
begin
 if fName<>aName then begin
  if length(fName)>0 then begin
   fFrameGraph.fPassNameHashMap.Delete(fName);
  end;
  fName:=aName;
  if length(fName)>0 then begin
   if fFrameGraph.fPassNameHashMap.ExistKey(fName) then begin
    raise EpvFrameGraphDuplicateName.Create('Duplicate name');
   end;
   fFrameGraph.fPassNameHashMap.Add(fName,self);
  end;
 end;
end;

procedure TpvFrameGraph.TPass.AddExplicitPassDependency(const aPass:TPass;const aDstStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT));
var ExplicitPassDependency:TExplicitPassDependency;
begin
 for ExplicitPassDependency in fExplicitPassDependencies do begin
  if ExplicitPassDependency.fPass=aPass then begin
   ExplicitPassDependency.fDstStageMask:=ExplicitPassDependency.fDstStageMask or aDstStageMask;
   exit;
  end;
 end;
 ExplicitPassDependency:=TExplicitPassDependency.Create;
 fExplicitPassDependencies.Add(ExplicitPassDependency);
 ExplicitPassDependency.fPass:=aPass;
 ExplicitPassDependency.fDstStageMask:=aDstStageMask;
end;

procedure TpvFrameGraph.TPass.AddExplicitPassDependency(const aPassName:TpvRawByteString;const aDstStageMask:TVkPipelineStageFlags=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT));
var ExplicitPassNameDependency:TExplicitPassNameDependency;
    Pass:TPass;
begin
 Pass:=fFrameGraph.fPassNameHashMap[aPassName];
 if assigned(Pass) then begin
  AddExplicitPassDependency(Pass,aDstStageMask);
 end else begin
  for ExplicitPassNameDependency in fExplicitPassNameDependencies do begin
   if ExplicitPassNameDependency.fPassName=aPassName then begin
    ExplicitPassNameDependency.fDstStageMask:=ExplicitPassNameDependency.fDstStageMask or aDstStageMask;
    exit;
   end;
  end;
  ExplicitPassNameDependency:=TExplicitPassNameDependency.Create;
  fExplicitPassNameDependencies.Add(ExplicitPassNameDependency);
  ExplicitPassNameDependency.fPassName:=aPassName;
  ExplicitPassNameDependency.fDstStageMask:=aDstStageMask;
 end;
end;

procedure TpvFrameGraph.TPass.ResolveExplicitPassDependencies;
var ExplicitPassNameDependency:TExplicitPassNameDependency;
    Pass:TPass;
begin
 for ExplicitPassNameDependency in fExplicitPassNameDependencies do begin
  Pass:=fFrameGraph.fPassNameHashMap[ExplicitPassNameDependency.fPassName];
  if assigned(Pass) then begin
   AddExplicitPassDependency(Pass,ExplicitPassNameDependency.fDstStageMask);
  end else begin
   raise EpvFrameGraphMissingExplicitPassDependency.Create('Missing explicit pass dependency "'+ExplicitPassNameDependency.fPassName+'"');
  end;
 end;
 fExplicitPassNameDependencies.Clear;
end;

function TpvFrameGraph.TPass.AddImageResource(const aResourceTypeName:TpvRawByteString;
                                              const aResourceName:TpvRawByteString;
                                              const aKind:TResourceTransition.TKind;
                                              const aFlags:TResourceTransition.TFlags;
                                              const aLayout:TVkImageLayout;
                                              const aLoadOp:TLoadOp;
                                              const aResourceInstanceType:TResourceInstanceType;
                                              const aExternalImageData:TExternalImageData):TResourceTransition;
var ResourceType:TResourceType;
    Resource:TResource;
begin
 ResourceType:=fFrameGraph.fResourceTypeNameHashMap[aResourceTypeName];
 if not assigned(ResourceType) then begin
  raise EpvFrameGraph.Create('Invalid resource type');
 end;
 Resource:=fFrameGraph.fResourceNameHashMap[aResourceName];
 if assigned(Resource) then begin
  if Resource.fResourceType<>ResourceType then begin
   raise EpvFrameGraph.Create('Resource type mismatch');
  end;
  if Resource.fResourceInstanceType<>aResourceInstanceType then begin
   raise EpvFrameGraph.Create('Resource instance type mismatch');
  end;
 end else begin
  Resource:=TResource.Create(fFrameGraph,
                             aResourceName,
                             ResourceType,
                             aResourceInstanceType);
 end;
 if not (ResourceType is TImageResourceType) then begin
  raise EpvFrameGraph.Create('Resource meta type mismatch');
 end;
 if assigned(aExternalImageData) and not assigned(Resource.fExternalData) then begin
  Resource.fExternalData:=aExternalImageData;
 end else if (assigned(aExternalImageData) and assigned(Resource.fExternalData)) and
             (aExternalImageData<>Resource.fExternalData) then begin
  raise EpvFrameGraph.Create('Resource external data mismatch');
 end;
 result:=TResourceTransition.Create(fFrameGraph,
                                    self,
                                    Resource,
                                    aKind,
                                    aFlags,
                                    aLayout,
                                    aLoadOp);
 fFrameGraph.fValid:=false;
end;

function TpvFrameGraph.TPass.AddBufferResource(const aResourceTypeName:TpvRawByteString;
                                               const aResourceName:TpvRawByteString;
                                               const aKind:TResourceTransition.TKind;
                                               const aFlags:TResourceTransition.TFlags;
                                               const aPipelineStage:TVkPipelineStageFlags;
                                               const aAccessFlags:TVkAccessFlags;
                                               const aBufferSubresourceRange:TBufferSubresourceRange;
                                               const aResourceInstanceType:TResourceInstanceType;
                                               const aExternalBufferData:TExternalBufferData):TResourceTransition;
var ResourceType:TResourceType;
    Resource:TResource;
begin
 ResourceType:=fFrameGraph.fResourceTypeNameHashMap[aResourceTypeName];
 if not assigned(ResourceType) then begin
  raise EpvFrameGraph.Create('Invalid resource type');
 end;
 Resource:=fFrameGraph.fResourceNameHashMap[aResourceName];
 if assigned(Resource) then begin
  if Resource.fResourceType<>ResourceType then begin
   raise EpvFrameGraph.Create('Resource type mismatch');
  end;
  if Resource.fResourceInstanceType<>aResourceInstanceType then begin
   raise EpvFrameGraph.Create('Resource instance type mismatch');
  end;
 end else begin
  Resource:=TResource.Create(fFrameGraph,
                             aResourceName,
                             ResourceType,
                             aResourceInstanceType);
 end;
 if not (ResourceType is TBufferResourceType) then begin
  raise EpvFrameGraph.Create('Resource meta type mismatch');
 end;
 if assigned(aExternalBufferData) and not assigned(Resource.fExternalData) then begin
  Resource.fExternalData:=aExternalBufferData;
 end else if (assigned(aExternalBufferData) and assigned(Resource.fExternalData)) and
             (aExternalBufferData<>Resource.fExternalData) then begin
  raise EpvFrameGraph.Create('Resource external data mismatch');
 end;
 result:=TResourceTransition.Create(fFrameGraph,
                                    self,
                                    Resource,
                                    aKind,
                                    aFlags,
                                    aPipelineStage,
                                    aAccessFlags,
                                    aBufferSubresourceRange);
 fFrameGraph.fValid:=false;
end;

procedure TpvFrameGraph.TPass.AddStartMarker(const aQueue:TpvFrameGraph.TQueue;const aCommandBuffer:TpvVulkanCommandBuffer);
const LabelInfoColors:array[0..15,0..3] of TVkFloat=
       (
        (1.0,0.8,0.5,1.0),
        (1.0,0.2,0.2,1.0),
        (0.2,1.0,0.2,1.0),
        (0.2,0.2,1.0,1.0),
        (1.0,0.2,1.0,1.0),
        (1.0,0.8,0.5,1.0),
        (1.0,1.0,0.2,1.0),
        (0.2,1.0,1.0,1.0),
        (0.5,0.8,0.5,1.0),
        (0.8,0.5,1.0,1.0),
        (0.5,1.0,0.5,1.0),
        (0.5,0.5,1.0,1.0),
        (1.0,0.5,1.0,1.0),
        (0.8,0.8,1.0,1.0),
        (1.0,1.0,0.5,1.0),
        (0.5,1.0,1.0,1.0)
       );
var LabelInfo:TVkDebugUtilsLabelEXT;
begin
 fCPUTimeValues[fFrameGraph.fDrawInFlightFrameIndex]:=pvApplication.HighResolutionTimer.GetTime;
 if fFrameGraph.fVulkanDevice.Instance.ExtDebugUtilsEnabled and
    assigned(aCommandBuffer.Device.Commands.Commands.CmdBeginDebugUtilsLabelEXT) and
    assigned(aCommandBuffer.Device.Commands.Commands.CmdEndDebugUtilsLabelEXT) then begin
  FillChar(LabelInfo,SizeOf(TVkDebugUtilsLabelEXT),#0);
  LabelInfo.sType:=VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT;
  LabelInfo.pNext:=nil;
  LabelInfo.pLabelName:=PAnsiChar(fName);
  LabelInfo.color[0]:=LabelInfoColors[fIndex and $f,0];
  LabelInfo.color[1]:=LabelInfoColors[fIndex and $f,1];
  LabelInfo.color[2]:=LabelInfoColors[fIndex and $f,2];
  LabelInfo.color[3]:=LabelInfoColors[fIndex and $f,3];
  aCommandBuffer.Device.Commands.CmdBeginDebugUtilsLabelEXT(aCommandBuffer.Handle,@LabelInfo);
 end;
 if assigned(fFrameGraph.fTimerQueries) and assigned(fFrameGraph.fTimerQueries[fFrameGraph.fDrawInFlightFrameIndex]) then begin
  fTimerQueryIndices[fFrameGraph.fDrawInFlightFrameIndex]:=fFrameGraph.fTimerQueries[fFrameGraph.fDrawInFlightFrameIndex].Start(aQueue.fPhysicalQueue,aCommandBuffer,fName);
 end else begin
  fTimerQueryIndices[fFrameGraph.fDrawInFlightFrameIndex]:=-1;
 end;
end;

procedure TpvFrameGraph.TPass.AddEndMarker(const aQueue:TpvFrameGraph.TQueue;const aCommandBuffer:TpvVulkanCommandBuffer);
begin
 if assigned(fFrameGraph.fTimerQueries) and assigned(fFrameGraph.fTimerQueries[fFrameGraph.fDrawInFlightFrameIndex]) then begin
  fFrameGraph.fTimerQueries[fFrameGraph.fDrawInFlightFrameIndex].Stop(aQueue.fPhysicalQueue,aCommandBuffer);
 end;
 if fFrameGraph.fVulkanDevice.Instance.ExtDebugUtilsEnabled and
    assigned(aCommandBuffer.Device.Commands.Commands.CmdBeginDebugUtilsLabelEXT) and
    assigned(aCommandBuffer.Device.Commands.Commands.CmdEndDebugUtilsLabelEXT) then begin
  aCommandBuffer.Device.Commands.CmdEndDebugUtilsLabelEXT(aCommandBuffer.Handle);
 end;
 fCPUTimeValues[fFrameGraph.fDrawInFlightFrameIndex]:=pvApplication.HighResolutionTimer.GetTime-fCPUTimeValues[fFrameGraph.fDrawInFlightFrameIndex];
end;

function TpvFrameGraph.TPass.AddImageInput(const aResourceTypeName:TpvRawByteString;
                                           const aResourceName:TpvRawByteString;
                                           const aLayout:TVkImageLayout;
                                           const aFlags:TResourceTransition.TFlags=[];
                                           const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                           const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
begin
 result:=TUsedImageResource.Create(self,
                                   AddImageResource(aResourceTypeName,
                                                    aResourceName,
                                                    TResourceTransition.TKind.ImageInput,
                                                    aFlags,
                                                    aLayout,
                                                    TLoadOp.Create(TLoadOp.TKind.Load),
                                                    aResourceInstanceType,
                                                    aExternalImageData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddImageOutput(const aResourceTypeName:TpvRawByteString;
                                            const aResourceName:TpvRawByteString;
                                            const aLayout:TVkImageLayout;
                                            const aLoadOp:TLoadOp;
                                            const aFlags:TResourceTransition.TFlags=[];
                                            const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                            const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
begin
 result:=TUsedImageResource.Create(self,
                                   AddImageResource(aResourceTypeName,
                                                    aResourceName,
                                                    TResourceTransition.TKind.ImageOutput,
                                                    aFlags,
                                                    aLayout,
                                                    aLoadOp,
                                                    aResourceInstanceType,
                                                    aExternalImageData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddImageResolveOutput(const aResourceTypeName:TpvRawByteString;
                                                   const aResourceName:TpvRawByteString;
                                                   const aResolveSourceResourceName:TpvRawByteString;
                                                   const aLayout:TVkImageLayout;
                                                   const aLoadOp:TLoadOp;
                                                   const aFlags:TResourceTransition.TFlags=[];
                                                   const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                                   const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
var ResolveSourceResource:TResource;
begin
 ResolveSourceResource:=fFrameGraph.fResourceNameHashMap[aResolveSourceResourceName];
 if not assigned(ResolveSourceResource) then begin
  raise EpvFrameGraph.Create('Invalid resolve resource');
 end;
 result:=TUsedImageResource.Create(self,
                                   AddImageResource(aResourceTypeName,
                                                    aResourceName,
                                                    TResourceTransition.TKind.ImageResolveOutput,
                                                    aFlags,
                                                    aLayout,
                                                    aLoadOp,
                                                    aResourceInstanceType,
                                                    aExternalImageData));
 fUsedResources.Add(result);
 result.fResourceTransition.fResolveSourceResource:=ResolveSourceResource;
end;

function TpvFrameGraph.TPass.AddImageDepthInput(const aResourceTypeName:TpvRawByteString;
                                                const aResourceName:TpvRawByteString;
                                                const aLayout:TVkImageLayout;
                                                const aFlags:TResourceTransition.TFlags=[];
                                                const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                                const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
begin
 result:=TUsedImageResource.Create(self,
                                   AddImageResource(aResourceTypeName,
                                                    aResourceName,
                                                    TResourceTransition.TKind.ImageDepthInput,
                                                    aFlags,
                                                    aLayout,
                                                    TLoadOp.Create(TLoadOp.TKind.Load),
                                                    aResourceInstanceType,
                                                    aExternalImageData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddImageDepthOutput(const aResourceTypeName:TpvRawByteString;
                                                 const aResourceName:TpvRawByteString;
                                                 const aLayout:TVkImageLayout;
                                                 const aLoadOp:TLoadOp;
                                                 const aFlags:TResourceTransition.TFlags=[];
                                                 const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                                 const aExternalImageData:TExternalImageData=nil):TUsedImageResource;
begin
 result:=TUsedImageResource.Create(self,
                                   AddImageResource(aResourceTypeName,
                                                    aResourceName,
                                                    TResourceTransition.TKind.ImageDepthOutput,
                                                    aFlags,
                                                    aLayout,
                                                    aLoadOp,
                                                    aResourceInstanceType,
                                                    aExternalImageData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddBufferInput(const aResourceTypeName:TpvRawByteString;
                                            const aResourceName:TpvRawByteString;
                                            const aPipelineStage:TVkPipelineStageFlags;
                                            const aAccessFlags:TVkAccessFlags;
                                            const aBufferSubresourceRange:TBufferSubresourceRange;
                                            const aFlags:TResourceTransition.TFlags=[];
                                            const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                            const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource;
begin
 result:=TUsedBufferResource.Create(self,
                                    AddBufferResource(aResourceTypeName,
                                                      aResourceName,
                                                      TResourceTransition.TKind.BufferInput,
                                                      aFlags,
                                                      aPipelineStage,
                                                      aAccessFlags,
                                                      aBufferSubresourceRange,
                                                      aResourceInstanceType,
                                                      aExternalBufferData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddBufferInput(const aResourceTypeName:TpvRawByteString;
                                            const aResourceName:TpvRawByteString;
                                            const aPipelineStage:TVkPipelineStageFlags;
                                            const aAccessFlags:TVkAccessFlags;
                                            const aFlags:TResourceTransition.TFlags=[];
                                            const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                            const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource;
begin
 result:=AddBufferInput(aResourceTypeName,
                        aResourceName,
                        aPipelineStage,
                        aAccessFlags,
                        TBufferSubresourceRange.Create(0,VK_WHOLE_SIZE),
                        aFlags,
                        aResourceInstanceType,
                        aExternalBufferData);
end;

function TpvFrameGraph.TPass.AddBufferOutput(const aResourceTypeName:TpvRawByteString;
                                             const aResourceName:TpvRawByteString;
                                             const aPipelineStage:TVkPipelineStageFlags;
                                             const aAccessFlags:TVkAccessFlags;
                                             const aBufferSubresourceRange:TBufferSubresourceRange;
                                             const aFlags:TResourceTransition.TFlags=[];
                                             const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                             const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource;
begin
 result:=TUsedBufferResource.Create(self,
                                    AddBufferResource(aResourceTypeName,
                                                      aResourceName,
                                                      TResourceTransition.TKind.BufferOutput,
                                                      aFlags,
                                                      aPipelineStage,
                                                      aAccessFlags,
                                                      aBufferSubresourceRange,
                                                      aResourceInstanceType,
                                                      aExternalBufferData));
 fUsedResources.Add(result);
end;

function TpvFrameGraph.TPass.AddBufferOutput(const aResourceTypeName:TpvRawByteString;
                                             const aResourceName:TpvRawByteString;
                                             const aPipelineStage:TVkPipelineStageFlags;
                                             const aAccessFlags:TVkAccessFlags;
                                             const aFlags:TResourceTransition.TFlags=[];
                                             const aResourceInstanceType:TResourceInstanceType=TResourceInstanceType.Default;
                                             const aExternalBufferData:TExternalBufferData=nil):TUsedBufferResource;
begin
 result:=AddBufferOutput(aResourceTypeName,
                         aResourceName,
                         aPipelineStage,
                         aAccessFlags,
                         TBufferSubresourceRange.Create(0,VK_WHOLE_SIZE),
                         aFlags,
                         aResourceInstanceType,
                         aExternalBufferData);
end;

procedure TpvFrameGraph.TPass.AcquirePersistentResources;
begin
end;

procedure TpvFrameGraph.TPass.ReleasePersistentResources;
begin
end;

procedure TpvFrameGraph.TPass.AcquireVolatileResources;
begin
end;

procedure TpvFrameGraph.TPass.ReleaseVolatileResources;
begin
end;

procedure TpvFrameGraph.TPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
end;

procedure TpvFrameGraph.TPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
begin
end;

{ TpvFrameGraph.TRenderPass }

constructor TpvFrameGraph.TRenderPass.Create(const aFrameGraph:TpvFrameGraph);
begin
 inherited Create(aFrameGraph);
 fPhysicalRenderPassSubpass:=nil;
end;

destructor TpvFrameGraph.TRenderPass.Destroy;
begin
 inherited Destroy;
end;

function TpvFrameGraph.TRenderPass.GetPhysicalRenderPass:TPhysicalRenderPass;
begin
 result:=TPhysicalRenderPass(fPhysicalPass);
end;

function TpvFrameGraph.TRenderPass.GetVulkanRenderPass:TpvVulkanRenderPass;
begin
 if assigned(fPhysicalPass) then begin
  result:=TPhysicalRenderPass(fPhysicalPass).fVulkanRenderPass;
 end else begin
  result:=nil;
 end;
end;

function TpvFrameGraph.TRenderPass.GetVulkanRenderPassSubpassIndex:TpvSizeInt;
begin
 if assigned(fPhysicalRenderPassSubpass) then begin
  result:=fPhysicalRenderPassSubpass.fIndex;
 end else begin
  result:=-1;
 end;
end;

{ TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup }

constructor TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.Create(const aFrameGraph:TpvFrameGraph;
                                                                     const aSrcStageMask:TVkPipelineStageFlags;
                                                                     const aDstStageMask:TVkPipelineStageFlags;
                                                                     const aDependencyFlags:TVkDependencyFlags);
var Index:TpvSizeInt;
begin
 inherited Create;
 fFrameGraph:=aFrameGraph;
 fSrcStageMask:=aSrcStageMask;
 fDstStageMask:=aDstStageMask;
 fDependencyFlags:=aDependencyFlags;
 fBarrierMapItemDynamicArray.Initialize;
 fMemoryBarrierDynamicArray.Initialize;
 fBufferMemoryBarrierDynamicArray.Initialize;
 fImageMemoryBarrierDynamicArray.Initialize;
 for Index:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  fWorkMemoryBarrierDynamicArray[Index].Initialize;
  fWorkBufferMemoryBarrierDynamicArray[Index].Initialize;
  fWorkImageMemoryBarrierDynamicArray[Index].Initialize;
  fWorkFromPhysicalPassesEventHandles[Index].Initialize;
 end;
 fPhysicalPassCrossEvents:=TPhysicalPassCrossEvents.Create(false);
end;

destructor TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.Destroy;
var InFlightFrameIndex:TpvSizeInt;
begin
 FreeAndNil(fPhysicalPassCrossEvents);
 fBarrierMapItemDynamicArray.Finalize;
 fMemoryBarrierDynamicArray.Finalize;
 fBufferMemoryBarrierDynamicArray.Finalize;
 fImageMemoryBarrierDynamicArray.Finalize;
 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  fWorkFromPhysicalPassesEventHandles[InFlightFrameIndex].Finalize;
  fWorkMemoryBarrierDynamicArray[InFlightFrameIndex].Finalize;
  fWorkBufferMemoryBarrierDynamicArray[InFlightFrameIndex].Finalize;
  fWorkImageMemoryBarrierDynamicArray[InFlightFrameIndex].Finalize;
 end;
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.AcquirePersistentResources;
begin
end;

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.ReleasePersistentResources;
begin
end;

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.AcquireVolatileResources;
var InFlightFrameIndex,
    BarrierMapItemIndex:TpvSizeInt;
    PhysicalPass:TPhysicalPass;
    BarrierMapItem:PBarrierMapItem;
    MemoryBarrier:PVkMemoryBarrier;
    BufferMemoryBarrier:PVkBufferMemoryBarrier;
    ImageMemoryBarrier:PVkImageMemoryBarrier;
    PassEvent:PPassEvent;
    PhysicalPassCrossEvent:TPhysicalPassCrossEvent;
    WaitEventsSrcStageMask:TVkPipelineStageFlags;
begin

 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin

  fWorkMemoryBarrierDynamicArray[InFlightFrameIndex].Assign(fMemoryBarrierDynamicArray);

  fWorkBufferMemoryBarrierDynamicArray[InFlightFrameIndex].Assign(fBufferMemoryBarrierDynamicArray);

  fWorkImageMemoryBarrierDynamicArray[InFlightFrameIndex].Assign(fImageMemoryBarrierDynamicArray);

  for BarrierMapItemIndex:=0 to fBarrierMapItemDynamicArray.Count-1 do begin

   BarrierMapItem:=@fBarrierMapItemDynamicArray.Items[BarrierMapItemIndex];

   case BarrierMapItem^.Kind of

    TBarrierMapItemKind.Memory:begin
     Assert((BarrierMapItem^.BarrierIndex>=0) and (BarrierMapItem^.BarrierIndex<fMemoryBarrierDynamicArray.Count));
     MemoryBarrier:=@fWorkMemoryBarrierDynamicArray[InFlightFrameIndex].Items[BarrierMapItem^.BarrierIndex];
     if assigned(MemoryBarrier) then begin
      // Nothing needed to do
     end;
    end;

    TBarrierMapItemKind.Buffer:begin
     Assert((BarrierMapItem^.BarrierIndex>=0) and (BarrierMapItem^.BarrierIndex<fBufferMemoryBarrierDynamicArray.Count));
     BufferMemoryBarrier:=@fWorkBufferMemoryBarrierDynamicArray[InFlightFrameIndex].Items[BarrierMapItem^.BarrierIndex];
     Assert(assigned(BarrierMapItem^.ResourcePhysicalData));
     if BarrierMapItem^.ResourcePhysicalData is TResourcePhysicalBufferData then begin
      BufferMemoryBarrier^.buffer:=TResourcePhysicalBufferData(BarrierMapItem^.ResourcePhysicalData).fVulkanBuffers[fFrameGraph.ConvertRelativeToAbsoluteInFlightFrameIndex(InFlightFrameIndex,BarrierMapItem^.ImageIndexOffset)].Handle;
     end else begin
      Assert(false);
     end;
    end;

    TBarrierMapItemKind.Image:begin
     Assert((BarrierMapItem^.BarrierIndex>=0) and (BarrierMapItem^.BarrierIndex<fImageMemoryBarrierDynamicArray.Count));
     ImageMemoryBarrier:=@fWorkImageMemoryBarrierDynamicArray[InFlightFrameIndex].Items[BarrierMapItem^.BarrierIndex];
     Assert(assigned(BarrierMapItem^.ResourcePhysicalData));
     if BarrierMapItem^.ResourcePhysicalData is TResourcePhysicalImageData then begin
      ImageMemoryBarrier^.image:=TResourcePhysicalImageData(BarrierMapItem^.ResourcePhysicalData).fVulkanImages[fFrameGraph.ConvertRelativeToAbsoluteInFlightFrameIndex(InFlightFrameIndex,BarrierMapItem^.ImageIndexOffset)].Handle;
     end else begin
      Assert(false);
     end;
    end;

    else begin
     Assert(false);
    end;

   end;

  end;

  begin

  end;

  if fPhysicalPassCrossEvents.Count>0 then begin

   WaitEventsSrcStageMask:=0;

   fWorkFromPhysicalPassesEventHandles[InFlightFrameIndex].Clear;

   for PhysicalPassCrossEvent in fPhysicalPassCrossEvents do begin
    fWorkFromPhysicalPassesEventHandles[InFlightFrameIndex].Add(PhysicalPassCrossEvent.fEvents[InFlightFrameIndex].Handle);
    WaitEventsSrcStageMask:=WaitEventsSrcStageMask or PhysicalPassCrossEvent.fStageMask;
   end;

   if fSrcStageMask<>WaitEventsSrcStageMask then begin
    raise EpvFrameGraph.Create('Src stage mask mismatch');
   end;

   fWorkFromPhysicalPassesEventHandles[InFlightFrameIndex].Finish;

  end;

 end;

end;

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  fWorkMemoryBarrierDynamicArray[InFlightFrameIndex].Clear;
  fWorkBufferMemoryBarrierDynamicArray[InFlightFrameIndex].Clear;
  fWorkImageMemoryBarrierDynamicArray[InFlightFrameIndex].Clear;
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroup.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
var MemoryBarriers,
    BufferMemoryBarriers,
    ImageMemoryBarriers:pointer;
begin
 if fWorkMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count>0 then begin
  MemoryBarriers:=@fWorkMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Items[0];
 end else begin
  MemoryBarriers:=nil;
 end;
 if fWorkBufferMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count>0 then begin
  BufferMemoryBarriers:=@fWorkBufferMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Items[0];
 end else begin
  BufferMemoryBarriers:=nil;
 end;
 if fWorkImageMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count>0 then begin
  ImageMemoryBarriers:=@fWorkImageMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Items[0];
 end else begin
  ImageMemoryBarriers:=nil;
 end;
 if fWorkFromPhysicalPassesEventHandles[fFrameGraph.fDrawInFlightFrameIndex].Count>0 then begin
  aCommandBuffer.CmdWaitEvents(fWorkFromPhysicalPassesEventHandles[fFrameGraph.fDrawInFlightFrameIndex].Count,
                               @fWorkFromPhysicalPassesEventHandles[fFrameGraph.fDrawInFlightFrameIndex].Items[0],
                               fSrcStageMask,
                               fDstStageMask,
                               fWorkMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                               MemoryBarriers,
                               fWorkBufferMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                               BufferMemoryBarriers,
                               fWorkImageMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                               ImageMemoryBarriers
                              );
 end else begin
  aCommandBuffer.CmdPipelineBarrier(fSrcStageMask,
                                    fDstStageMask,
                                    fDependencyFlags,
                                    fWorkMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                                    MemoryBarriers,
                                    fWorkBufferMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                                    BufferMemoryBarriers,
                                    fWorkImageMemoryBarrierDynamicArray[fFrameGraph.fDrawInFlightFrameIndex].Count,
                                    ImageMemoryBarriers
                                   );
 end;
end;

{ TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroups }

procedure TpvFrameGraph.TPhysicalPass.TPipelineBarrierGroups.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
var Index:TpvSizeInt;
begin
 for Index:=0 to Count-1 do begin
  Items[Index].Execute(aCommandBuffer);
 end;
end;

{ TpvFrameGraph.TPhysicalPass }

constructor TpvFrameGraph.TPhysicalPass.Create(const aFrameGraph:TpvFrameGraph;const aQueue:TQueue);
var InFlightFrameIndex:TpvSizeInt;
begin

 inherited Create;

 fFrameGraph:=aFrameGraph;

 fSeparateCommandBuffer:=false;

 fHasSecondaryBuffers:=false;

 fQueue:=aQueue;

 fExternalWaitingOnSemaphoreReferences:=TExternalWaitingOnSemaphoreReferences.Create(false);

 fInputDependencies:=TPhysicalPasses.Create;
 fInputDependencies.OwnsObjects:=false;

 fOutputDependencies:=TPhysicalPasses.Create;
 fOutputDependencies.OwnsObjects:=false;

 fQueueCommandBuffer:=nil;

 fEventPipelineBarrierGroups:=TPipelineBarrierGroups.Create;
 fEventPipelineBarrierGroups.OwnsObjects:=true;

 fBeforePipelineBarrierGroups:=TPipelineBarrierGroups.Create;
 fBeforePipelineBarrierGroups.OwnsObjects:=true;

 fAfterPipelineBarrierGroups:=TPipelineBarrierGroups.Create;
 fAfterPipelineBarrierGroups.OwnsObjects:=true;

 fIncomingEvents:=TPhysicalPassCrossEvents.Create(false);

 fOutgoingEvents:=TPhysicalPassCrossEvents.Create(false);

end;

destructor TpvFrameGraph.TPhysicalPass.Destroy;
begin
 FreeAndNil(fEventPipelineBarrierGroups);
 FreeAndNil(fBeforePipelineBarrierGroups);
 FreeAndNil(fAfterPipelineBarrierGroups);
 FreeAndNil(fExternalWaitingOnSemaphoreReferences);
 FreeAndNil(fInputDependencies);
 FreeAndNil(fOutputDependencies);
 FreeAndNil(fIncomingEvents);
 FreeAndNil(fOutgoingEvents);
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalPass.SetEvents(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
var PhysicalPassCrossEvent:TPhysicalPassCrossEvent;
begin
 for PhysicalPassCrossEvent in fOutgoingEvents do begin
  aCommandBuffer.CmdSetEvent(PhysicalPassCrossEvent.fEvents[aInFlightFrameIndex].Handle,PhysicalPassCrossEvent.fStageMask);
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.AcquirePersistentResources;
var PipelineBarrierGroup:TPipelineBarrierGroup;
begin
 for PipelineBarrierGroup in fEventPipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquirePersistentResources;
 end;
 for PipelineBarrierGroup in fBeforePipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquirePersistentResources;
 end;
 for PipelineBarrierGroup in fAfterPipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquirePersistentResources;
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.ReleasePersistentResources;
var PipelineBarrierGroup:TPipelineBarrierGroup;
begin
 for PipelineBarrierGroup in fEventPipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleasePersistentResources;
 end;
 for PipelineBarrierGroup in fBeforePipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleasePersistentResources;
 end;
 for PipelineBarrierGroup in fAfterPipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleasePersistentResources;
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.AcquireVolatileResources;
var PipelineBarrierGroup:TPipelineBarrierGroup;
begin
 for PipelineBarrierGroup in fEventPipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquireVolatileResources;
 end;
 for PipelineBarrierGroup in fBeforePipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquireVolatileResources;
 end;
 for PipelineBarrierGroup in fAfterPipelineBarrierGroups do begin
  PipelineBarrierGroup.AcquireVolatileResources;
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.ReleaseVolatileResources;
var InFlightFrameIndex,Index:TpvSizeInt;
    PipelineBarrierGroup:TPipelineBarrierGroup;
begin
 for PipelineBarrierGroup in fEventPipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleaseVolatileResources;
 end;
 for PipelineBarrierGroup in fBeforePipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleaseVolatileResources;
 end;
 for PipelineBarrierGroup in fAfterPipelineBarrierGroups do begin
  PipelineBarrierGroup.ReleaseVolatileResources;
 end;
end;

procedure TpvFrameGraph.TPhysicalPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
end;

procedure TpvFrameGraph.TPhysicalPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
begin

end;

{ TpvFrameGraph.TPhysicalComputePass }

constructor TpvFrameGraph.TPhysicalComputePass.Create(const aFrameGraph:TpvFrameGraph;
                                                      const aComputePass:TComputePass);
begin
 inherited Create(aFrameGraph,aComputePass.fQueue);
 fComputePass:=aComputePass;
end;

destructor TpvFrameGraph.TPhysicalComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalComputePass.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
 fComputePass.AcquirePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalComputePass.ReleasePersistentResources;
begin
 fComputePass.ReleasePersistentResources;
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalComputePass.AcquireVolatileResources;
begin
 inherited AcquireVolatileResources;
 fComputePass.AcquireVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalComputePass.ReleaseVolatileResources;
begin
 fComputePass.ReleaseVolatileResources;
 inherited ReleaseVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 if TPass.TFlag.Enabled in fComputePass.fFlags then begin
  fComputePass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 end;
end;

procedure TpvFrameGraph.TPhysicalComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
begin
 inherited Execute(aCommandBuffer);
 fComputePass.AddStartMarker(fQueue,aCommandBuffer);
 fEventPipelineBarrierGroups.Execute(aCommandBuffer);
 fBeforePipelineBarrierGroups.Execute(aCommandBuffer);
//ResetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 if fComputePass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1] then begin
  fComputePass.Execute(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawFrameIndex);
 end;
 fAfterPipelineBarrierGroups.Execute(aCommandBuffer);
 SetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 fComputePass.AddEndMarker(fQueue,aCommandBuffer);
end;

{ TpvFrameGraph.TPhysicalTransferPass }

constructor TpvFrameGraph.TPhysicalTransferPass.Create(const aFrameGraph:TpvFrameGraph;
                                                      const aTransferPass:TTransferPass);
begin
 inherited Create(aFrameGraph,aTransferPass.fQueue);
 fTransferPass:=aTransferPass;
end;

destructor TpvFrameGraph.TPhysicalTransferPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
 fTransferPass.AcquirePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.ReleasePersistentResources;
begin
 fTransferPass.ReleasePersistentResources;
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.AcquireVolatileResources;
begin
 inherited AcquireVolatileResources;
 fTransferPass.AcquireVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.ReleaseVolatileResources;
begin
 fTransferPass.ReleaseVolatileResources;
 inherited ReleaseVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 if TPass.TFlag.Enabled in fTransferPass.fFlags then begin
  fTransferPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 end;
end;

procedure TpvFrameGraph.TPhysicalTransferPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
begin
 inherited Execute(aCommandBuffer);
 fTransferPass.AddStartMarker(fQueue,aCommandBuffer);
 fEventPipelineBarrierGroups.Execute(aCommandBuffer);
 fBeforePipelineBarrierGroups.Execute(aCommandBuffer);
//ResetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 if fTransferPass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1] then begin
  fTransferPass.Execute(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawFrameIndex);
 end;
 fAfterPipelineBarrierGroups.Execute(aCommandBuffer);
 SetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 fTransferPass.AddEndMarker(fQueue,aCommandBuffer);
end;

{ TpvFrameGraph.TPhysicalCustomPass }

constructor TpvFrameGraph.TPhysicalCustomPass.Create(const aFrameGraph:TpvFrameGraph;
                                                     const aCustomPass:TCustomPass);
begin
 inherited Create(aFrameGraph,aCustomPass.fQueue);
 fCustomPass:=aCustomPass;
end;

destructor TpvFrameGraph.TPhysicalCustomPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
 fCustomPass.AcquirePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.ReleasePersistentResources;
begin
 fCustomPass.ReleasePersistentResources;
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.AcquireVolatileResources;
begin
 inherited AcquireVolatileResources;
 fCustomPass.AcquireVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.ReleaseVolatileResources;
begin
 fCustomPass.ReleaseVolatileResources;
 inherited ReleaseVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 if TPass.TFlag.Enabled in fCustomPass.fFlags then begin
  fCustomPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 end;
end;

procedure TpvFrameGraph.TPhysicalCustomPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
begin
 inherited Execute(aCommandBuffer);
 fCustomPass.AddStartMarker(fQueue,aCommandBuffer);
 fEventPipelineBarrierGroups.Execute(aCommandBuffer);
 fBeforePipelineBarrierGroups.Execute(aCommandBuffer);
//ResetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 if fCustomPass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1] then begin
  fCustomPass.Execute(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawFrameIndex);
 end;
 fAfterPipelineBarrierGroups.Execute(aCommandBuffer);
 SetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 fCustomPass.AddEndMarker(fQueue,aCommandBuffer);
end;

{ TpvFrameGraph.TPhysicalRenderPass.TSubpass }

constructor TpvFrameGraph.TPhysicalRenderPass.TSubpass.Create(const aPhysicalRenderPass:TPhysicalRenderPass;
                                                              const aRenderPass:TRenderPass);
begin
 inherited Create;
 fPhysicalRenderPass:=aPhysicalRenderPass;
 fRenderPass:=aRenderPass;
 fInputAttachments.Initialize;
 fColorAttachments.Initialize;
 fResolveAttachments.Initialize;
 fPreserveAttachments.Initialize;
 fDepthStencilAttachment:=-1;
 fMultiviewMask:=fRenderPass.fMultiviewMask;
end;

destructor TpvFrameGraph.TPhysicalRenderPass.TSubpass.Destroy;
begin
 fInputAttachments.Finalize;
 fColorAttachments.Finalize;
 fResolveAttachments.Finalize;
 fPreserveAttachments.Finalize;
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.TSubpass.AcquirePersistentResources;
begin
 fRenderPass.AcquirePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.TSubpass.ReleasePersistentResources;
begin
 fRenderPass.ReleasePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.TSubpass.AcquireVolatileResources;
begin
 fRenderPass.AcquireVolatileResources;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.TSubpass.ReleaseVolatileResources;
begin
 fRenderPass.ReleaseVolatileResources;
end;

{ TpvFrameGraph.TVulkanRenderPass }

constructor TpvFrameGraph.TPhysicalRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aQueue:TQueue);
var InFlightFrameIndex,SurfaceIndex:TpvSizeInt;
begin
 inherited Create(aFrameGraph,aQueue);
 fSubpasses:=TSubpasses.Create;
 fSubpasses.OwnsObjects:=true;
 fSubpassDependencies.Initialize;
 fMultiview:=false;
 fHasSurfaceSubpassDependencies:=false;
 fHasVulkanSurfaceFrameBuffers:=false;
 fAttachments.Initialize;
 fAttachmentReferences.Initialize;
 fFinalLayouts:=TResourcelLayoutHashMap.Create(VK_IMAGE_LAYOUT_UNDEFINED);
 fVulkanRenderPass:=nil;
 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  for SurfaceIndex:=0 to length(fVulkanSurfaceFrameBuffers[InFlightFrameIndex])-1 do begin
   fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex]:=nil;
  end;
  fVulkanSurfaceFrameBuffers[InFlightFrameIndex]:=nil;
  fVulkanFrameBuffers[InFlightFrameIndex]:=nil;
 end;
end;

destructor TpvFrameGraph.TPhysicalRenderPass.Destroy;
var InFlightFrameIndex,SurfaceIndex:TpvSizeInt;
begin
 FreeAndNil(fFinalLayouts);
 fSubpassDependencies.Finalize;
 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  if fHasVulkanSurfaceFrameBuffers then begin
   for SurfaceIndex:=0 to length(fVulkanSurfaceFrameBuffers[InFlightFrameIndex])-1 do begin
    FreeAndNil(fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex]);
   end;
  end;
  fVulkanSurfaceFrameBuffers[InFlightFrameIndex]:=nil;
  FreeAndNil(fVulkanFrameBuffers[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanRenderPass);
 fAttachments.Finalize;
 fAttachmentReferences.Finalize;
 FreeAndNil(fSubpasses);
 inherited Destroy;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.AcquirePersistentResources;
var Subpass:TSubpass;
begin
 inherited AcquirePersistentResources;
 for Subpass in fSubpasses do begin
  Subpass.AcquirePersistentResources;
 end;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.ReleasePersistentResources;
var Subpass:TSubpass;
begin
 for Subpass in fSubpasses do begin
  Subpass.ReleasePersistentResources;
 end;
 inherited ReleasePersistentResources;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.AcquireVolatileResources;
var AttachmentIndex,
    AttachmentReferenceIndex,
    SubpassIndex,
    SubpassDependencyIndex,
    InFlightFrameIndex,
    SurfaceIndex,
    Width,
    Height,
    Layers:TpvSizeInt;
    SrcSubpassIndex,
    DstSubpassIndex:TVkUInt32;
    Attachment:PAttachment;
    AttachmentReference:PVkAttachmentReference;
    Subpass:TSubpass;
    SubpassDependency:PSubpassDependency;
    RenderPass,a,b:TRenderPass;
    ResourcePhysicalImageData:TResourcePhysicalImageData;
    AttachmentDescriptionFlags:TVkAttachmentDescriptionFlags;
begin
 inherited AcquireVolatileResources;

 Width:=1;
 Height:=1;
 Layers:=1;

 for Subpass in fSubpasses do begin
  RenderPass:=Subpass.fRenderPass;
  case RenderPass.fSize.Kind of
   TpvFrameGraph.TImageSize.TKind.Absolute:begin
    Width:=Max(1,round(RenderPass.fSize.Size.x));
    Height:=Max(1,round(RenderPass.fSize.Size.y));
    if fMultiview then begin
     Layers:=1;
    end else begin
     Layers:=Max(1,round(RenderPass.fSize.Size.w));
    end;
   end;
   TpvFrameGraph.TImageSize.TKind.SurfaceDependent:begin
    Width:=Max(1,round(RenderPass.fSize.Size.x*fFrameGraph.fSurfaceWidth));
    Height:=Max(1,round(RenderPass.fSize.Size.y*fFrameGraph.fSurfaceHeight));
    if fMultiview then begin
     Layers:=1;
    end else begin
     Layers:=Max(1,round(RenderPass.fSize.Size.w));
    end;
   end;
   TpvFrameGraph.TImageSize.TKind.SurfaceDependentPreviousPowerOfTwo:begin
    Width:=Max(1,RoundDownToPowerOfTwo(round(RenderPass.fSize.Size.x*fFrameGraph.fSurfaceWidth)));
    Height:=Max(1,RoundDownToPowerOfTwo(round(RenderPass.fSize.Size.y*fFrameGraph.fSurfaceHeight)));
    if fMultiview then begin
     Layers:=1;
    end else begin
     Layers:=Max(1,round(RenderPass.fSize.Size.w));
    end;
   end;
   TpvFrameGraph.TImageSize.TKind.SurfaceDependentNextPowerOfTwo:begin
    Width:=Max(1,RoundUpToPowerOfTwo(round(RenderPass.fSize.Size.x*fFrameGraph.fSurfaceWidth)));
    Height:=Max(1,RoundUpToPowerOfTwo(round(RenderPass.fSize.Size.y*fFrameGraph.fSurfaceHeight)));
    if fMultiview then begin
     Layers:=1;
    end else begin
     Layers:=Max(1,round(RenderPass.fSize.Size.w));
    end;
   end;
   TpvFrameGraph.TImageSize.TKind.SurfaceDependentNearestPowerOfTwo:begin
    Width:=Max(1,RoundNearestToPowerOfTwo(round(RenderPass.fSize.Size.x*fFrameGraph.fSurfaceWidth)));
    Height:=Max(1,RoundNearestToPowerOfTwo(round(RenderPass.fSize.Size.y*fFrameGraph.fSurfaceHeight)));
    if fMultiview then begin
     Layers:=1;
    end else begin
     Layers:=Max(1,round(RenderPass.fSize.Size.w));
    end;
   end;
   else {TpvFrameGraph.TImageSize.TKind.Undefined:}begin
   end;
  end;
  break;
 end;

 fSize.Kind:=TpvFrameGraph.TImageSize.TKind.Absolute;
 fSize.Size:=TpvVector4.InlineableCreate(Width,Height,RenderPass.fSize.Size.z,Layers);

 fVulkanRenderPass:=TpvVulkanRenderPass.Create(fFrameGraph.fVulkanDevice);

 for AttachmentIndex:=0 to fAttachments.Count-1 do begin
  Attachment:=@fAttachments.Items[AttachmentIndex];
  ResourcePhysicalImageData:=Attachment^.Resource.fResourceAliasGroup.fResourcePhysicalData as TResourcePhysicalImageData;
  Attachment^.Format:=ResourcePhysicalImageData.fFormat;
  AttachmentDescriptionFlags:=0;
  if Attachment^.Resource.fResourceAliasGroup.fResources.Count>1 then begin
   AttachmentDescriptionFlags:=AttachmentDescriptionFlags or TVkAttachmentDescriptionFlags(VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT);
  end;
  fVulkanRenderPass.AddAttachmentDescription(AttachmentDescriptionFlags,
                                             Attachment^.Format,
                                             Attachment^.Samples,
                                             Attachment^.LoadOp,
                                             Attachment^.StoreOp,
                                             Attachment^.StencilLoadOp,
                                             Attachment^.StencilStoreOp,
                                             Attachment^.InitialLayout,
                                             Attachment^.FinalLayout
                                            );
 end;

 for AttachmentReferenceIndex:=0 to fAttachmentReferences.Count-1 do begin
  AttachmentReference:=@fAttachmentReferences.Items[AttachmentReferenceIndex];
  fVulkanRenderPass.AddAttachmentReference(AttachmentReference^.Attachment,
                                           AttachmentReference^.Layout);
 end;

 for SubpassIndex:=0 to fSubpasses.Count-1 do begin
  Subpass:=fSubpasses[SubpassIndex];
  fVulkanRenderPass.AddSubpassDescription(0,
                                          VK_PIPELINE_BIND_POINT_GRAPHICS,
                                          Subpass.fInputAttachments.Items,
                                          Subpass.fColorAttachments.Items,
                                          Subpass.fResolveAttachments.Items,
                                          Subpass.fDepthStencilAttachment,
                                          Subpass.fPreserveAttachments.Items
                                         );
  if fMultiview and fFrameGraph.fMultiviewEnabled then begin
   fVulkanRenderPass.AddMultiviewMask(Subpass.fMultiviewMask);
// fVulkanRenderPass.AddCorrelationMask(Subpass.fMultiviewMask);
  end;
 end;

 for SubpassDependencyIndex:=0 to fSubpassDependencies.Count-1 do begin
  SubpassDependency:=@fSubpassDependencies.Items[SubpassDependencyIndex];
  if assigned(SubpassDependency^.SrcSubpass) then begin
   SrcSubpassIndex:=SubpassDependency^.SrcSubpass.fIndex;
  end else begin
   SrcSubpassIndex:=VK_SUBPASS_EXTERNAL;
  end;
  if assigned(SubpassDependency.DstSubpass) then begin
   DstSubpassIndex:=SubpassDependency^.DstSubpass.fIndex;
  end else begin
   DstSubpassIndex:=VK_SUBPASS_EXTERNAL;
  end;
  fVulkanRenderPass.AddSubpassDependency(SrcSubpassIndex,
                                         DstSubpassIndex,
                                         SubpassDependency^.SrcStageMask,
                                         SubpassDependency^.DstStageMask,
                                         SubpassDependency^.SrcAccessMask,
                                         SubpassDependency^.DstAccessMask,
                                         SubpassDependency^.DependencyFlags);
 end;

 fVulkanRenderPass.Initialize;

//fFrameGraph.fVulkanDevice.DebugMarker.SetObjectName(fVulkanRenderPass.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_RENDER_PASS_EXT,fSubpasses[0].fRenderPass.Name);

 if fSubpasses.Count>0 then begin
  fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanRenderPass.Handle,TVkObjectType.VK_OBJECT_TYPE_RENDER_PASS,fSubpasses[0].fRenderPass.Name);
 end;

 for AttachmentIndex:=0 to fAttachments.Count-1 do begin
  Attachment:=@fAttachments.Items[AttachmentIndex];
  fVulkanRenderPass.ClearValues[AttachmentIndex]^:=Attachment^.ClearValue;
 end;

 fHasVulkanSurfaceFrameBuffers:=false;
 for AttachmentIndex:=0 to fAttachments.Count-1 do begin
  Attachment:=@fAttachments.Items[AttachmentIndex];
  ResourcePhysicalImageData:=TResourcePhysicalImageData(Attachment^.Resource.fResourceAliasGroup.fResourcePhysicalData);
  if ResourcePhysicalImageData.fIsSurface then begin
   fHasVulkanSurfaceFrameBuffers:=true;
   break;
  end;
 end;

 if fHasVulkanSurfaceFrameBuffers then begin

  for InFlightFrameIndex:=0 to fFrameGraph.fCountInFlightFrames-1 do begin
   SetLength(fVulkanSurfaceFrameBuffers[InFlightFrameIndex],Max(1,fFrameGraph.fCountSurfaceImages));
   for SurfaceIndex:=0 to fFrameGraph.fCountSurfaceImages-1 do begin
    fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex]:=TpvVulkanFrameBuffer.Create(fFrameGraph.fVulkanDevice,
                                                                                             fVulkanRenderPass,
                                                                                             Width,
                                                                                             Height,
                                                                                             Layers);
    for AttachmentIndex:=0 to fAttachments.Count-1 do begin
     Attachment:=@fAttachments.Items[AttachmentIndex];
     ResourcePhysicalImageData:=TResourcePhysicalImageData(Attachment^.Resource.fResourceAliasGroup.fResourcePhysicalData);
     if ResourcePhysicalImageData.fIsSurface then begin
      fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex].AddAttachment(TpvVulkanFrameBufferAttachment.Create(fFrameGraph.fVulkanDevice,
                                                                                                                      ResourcePhysicalImageData.fVulkanSurfaceImages[SurfaceIndex],
                                                                                                                      ResourcePhysicalImageData.fVulkanSurfaceImageViews[SurfaceIndex],
                                                                                                                      ResourcePhysicalImageData.fExtent.width,
                                                                                                                      ResourcePhysicalImageData.fExtent.height,
                                                                                                                      Attachment^.Format,
                                                                                                                      false));
     end else begin
      fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex].AddAttachment(TpvVulkanFrameBufferAttachment.Create(fFrameGraph.fVulkanDevice,
                                                                                                                      ResourcePhysicalImageData.fVulkanImages[InFlightFrameIndex],
                                                                                                                      ResourcePhysicalImageData.fVulkanImageViews[InFlightFrameIndex],
                                                                                                                      ResourcePhysicalImageData.fExtent.width,
                                                                                                                      ResourcePhysicalImageData.fExtent.height,
                                                                                                                      Attachment^.Format,
                                                                                                                      false));
     end;
    end;
    fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex].Initialize;
    if fSubpasses.Count>0 then begin
     fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_FRAMEBUFFER,fSubpasses[0].fRenderPass.Name+'.SurfaceFrameBuffer['+IntToStr(InFlightFrameIndex)+','+IntToStr(SurfaceIndex)+']');
    end;
   end;
  end;

 end else begin

  for InFlightFrameIndex:=0 to fFrameGraph.fCountInFlightFrames-1 do begin
   fVulkanFrameBuffers[InFlightFrameIndex]:=TpvVulkanFrameBuffer.Create(fFrameGraph.fVulkanDevice,
                                                                        fVulkanRenderPass,
                                                                        Width,
                                                                        Height,
                                                                        Layers);
   for AttachmentIndex:=0 to fAttachments.Count-1 do begin
    Attachment:=@fAttachments.Items[AttachmentIndex];
    ResourcePhysicalImageData:=TResourcePhysicalImageData(Attachment^.Resource.fResourceAliasGroup.fResourcePhysicalData);
    fVulkanFrameBuffers[InFlightFrameIndex].AddAttachment(TpvVulkanFrameBufferAttachment.Create(fFrameGraph.fVulkanDevice,
                                                                                                ResourcePhysicalImageData.fVulkanImages[InFlightFrameIndex],
                                                                                                ResourcePhysicalImageData.fVulkanImageViews[InFlightFrameIndex],
                                                                                                ResourcePhysicalImageData.fExtent.width,
                                                                                                ResourcePhysicalImageData.fExtent.height,
                                                                                                Attachment^.Format,
                                                                                                false));
   end;
   fVulkanFrameBuffers[InFlightFrameIndex].Initialize;
   if fSubpasses.Count>0 then begin
    fFrameGraph.fVulkanDevice.DebugUtils.SetObjectName(fVulkanFrameBuffers[InFlightFrameIndex].Handle,TVkObjectType.VK_OBJECT_TYPE_FRAMEBUFFER,fSubpasses[0].fRenderPass.Name+'.FrameBuffer['+IntToStr(InFlightFrameIndex)+']');
   end;
  end;

 end;

 for Subpass in fSubpasses do begin
//write('Compiling render pass ', Subpass.fRenderPass.Name,' . . .');
  Subpass.AcquireVolatileResources;
//writeln(' OK!');
 end;

end;

procedure TpvFrameGraph.TPhysicalRenderPass.ReleaseVolatileResources;
var InFlightFrameIndex,SurfaceIndex:TpvSizeInt;
    Subpass:TSubpass;
begin

 for Subpass in fSubpasses do begin
  Subpass.ReleaseVolatileResources;
 end;

 for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
  if fHasVulkanSurfaceFrameBuffers then begin
   for SurfaceIndex:=0 to length(fVulkanSurfaceFrameBuffers[InFlightFrameIndex])-1 do begin
    FreeAndNil(fVulkanSurfaceFrameBuffers[InFlightFrameIndex,SurfaceIndex]);
   end;
  end;
  fVulkanSurfaceFrameBuffers[InFlightFrameIndex]:=nil;
  FreeAndNil(fVulkanFrameBuffers[InFlightFrameIndex]);
 end;

 FreeAndNil(fVulkanRenderPass);

 fHasVulkanSurfaceFrameBuffers:=false;

 inherited ReleaseVolatileResources;

end;

procedure TpvFrameGraph.TPhysicalRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
var SubpassIndex:TpvSizeInt;
    Subpass:TSubpass;
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
 for SubpassIndex:=0 to fSubpasses.Count-1 do begin
  Subpass:=fSubpasses[SubpassIndex];
  if TPass.TFlag.Enabled in Subpass.fRenderPass.fFlags then begin
   Subpass.fRenderPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
  end;
 end;
end;

procedure TpvFrameGraph.TPhysicalRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
var SubpassIndex:TpvSizeInt;
    Subpass:TSubpass;
    SubpassContents:TVkSubpassContents;
    SingleSubpassDebug:boolean;
begin
 inherited Execute(aCommandBuffer);
 if fHasSecondaryBuffers then begin
  SubpassContents:=VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS;
 end else begin
  SubpassContents:=VK_SUBPASS_CONTENTS_INLINE;
 end;
 SingleSubpassDebug:=(fSubpasses.Count=1) and (fSubpasses[0].fRenderPass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1]);
 if SingleSubpassDebug then begin
  fSubpasses[0].fRenderPass.AddStartMarker(fQueue,aCommandBuffer);
 end;
 fEventPipelineBarrierGroups.Execute(aCommandBuffer);
 fBeforePipelineBarrierGroups.Execute(aCommandBuffer);
//ResetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 if (fSubpasses.Count>1) or
    ((fSubpasses.Count=1) and (fSubpasses[0].fRenderPass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1])) then begin
  if fHasVulkanSurfaceFrameBuffers then begin
   fVulkanRenderPass.BeginRenderPass(aCommandBuffer,
                                    fVulkanSurfaceFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawSwapChainImageIndex],
                                    SubpassContents,
                                    0,
                                    0,
                                    fVulkanSurfaceFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawSwapChainImageIndex].Width,
                                    fVulkanSurfaceFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawSwapChainImageIndex].Height);
  end else begin
   fVulkanRenderPass.BeginRenderPass(aCommandBuffer,
                                     fVulkanFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex],
                                     SubpassContents,
                                     0,
                                     0,
                                     fVulkanFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex].Width,
                                     fVulkanFrameBuffers[fFrameGraph.fDrawInFlightFrameIndex].Height);
  end;
  for SubpassIndex:=0 to fSubpasses.Count-1 do begin
   Subpass:=fSubpasses[SubpassIndex];
   if Subpass.fRenderPass.fDoubleBufferedEnabledState[fFrameGraph.fDrawFrameIndex and 1] then begin
    if not SingleSubpassDebug then begin
     Subpass.fRenderPass.AddStartMarker(fQueue,aCommandBuffer);
    end;
    Subpass.fRenderPass.Execute(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex,fFrameGraph.fDrawFrameIndex);
    if not SingleSubpassDebug then begin
     Subpass.fRenderPass.AddEndMarker(fQueue,aCommandBuffer);
    end;
   end;
   if (SubpassIndex+1)<fSubpasses.Count then begin
    aCommandBuffer.CmdNextSubpass(SubpassContents);
   end;
  end;
  fVulkanRenderPass.EndRenderPass(aCommandBuffer);
 end;
 fAfterPipelineBarrierGroups.Execute(aCommandBuffer);
 SetEvents(aCommandBuffer,fFrameGraph.fDrawInFlightFrameIndex);
 if SingleSubpassDebug then begin
  fSubpasses[0].fRenderPass.AddEndMarker(fQueue,aCommandBuffer);
 end;
end;

{ TpvFrameGraph }

constructor TpvFrameGraph.Create(const aVulkanDevice:TpvVulkanDevice;const aCountInFlightFrames:TpvSizeInt);
var InFlightFrameIndex:TpvSizeInt;
begin

 inherited Create;

 fVulkanDevice:=aVulkanDevice;

 fSurfaceImages:=nil;

 fMultiviewEnabled:=(((fVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)=VK_API_VERSION_1_0) and
                     (fVulkanDevice.EnabledExtensionNames.IndexOf(VK_KHR_MULTIVIEW_EXTENSION_NAME)>0)) or
                    ((fVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)>=VK_API_VERSION_1_1);

 fSurfaceIsSwapchain:=false;

 fSurfaceWidth:=1;
 fSurfaceHeight:=1;

 fSurfaceColorFormat:=VK_FORMAT_R8G8B8A8_SRGB;

 fSurfaceColorSpace:=VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;

 fSurfaceDepthFormat:=VK_FORMAT_D32_SFLOAT;

 fCountInFlightFrames:=Min(Max(aCountInFlightFrames,1),MaxInFlightFrames);

 fCountSurfaceImages:=MaxSwapChainImages;

 fCanDoParallelProcessing:=false;

 fDoWaitOnSemaphore:=false;

 fDoSignalSemaphore:=false;

{$if defined(Android) or defined(iOS)}
 fTryToMergeSubpasses:=true;
{$else}
 fTryToMergeSubpasses:=false;
{$ifend}

 fDefaultResourceInstanceType:=TResourceInstanceType.InstancePerInFlightFrame;

 fQueues:=TQueues.Create;
 fQueues.OwnsObjects:=true;

 fAllQueueCommandBuffers:=TQueue.TCommandBuffers.Create;
 fAllQueueCommandBuffers.OwnsObjects:=false;

 fQueueFamilyIndices.Initialize;

 fResourceTypes:=TResourceTypeList.Create;
 fResourceTypes.OwnsObjects:=true;

 fResourceTypeNameHashMap:=TResourceTypeNameHashMap.Create(nil);

 fResources:=TResourceList.Create;
 fResources.OwnsObjects:=true;

 fResourceNameHashMap:=TResourceNameHashMap.Create(nil);

 fResourceTransitions:=TResourceTransitionList.Create;
 fResourceTransitions.OwnsObjects:=true;

 fResourceAliasGroups:=TResourceAliasGroupList.Create;
 fResourceAliasGroups.OwnsObjects:=true;

 fExternalDataList:=TExternalDataList.Create;
 fExternalDataList.OwnsObjects:=true;

 fPasses:=TPassList.Create;
 fPasses.OwnsObjects:=true;

 fPassNameHashMap:=TPassNameHashMap.Create(nil);

 fTopologicalSortedPasses:=TPassList.Create;
 fTopologicalSortedPasses.OwnsObjects:=false;

 fPhysicalPasses:=TPhysicalPasses.Create;
 fPhysicalPasses.OwnsObjects:=true;

 fUniversalQueue:=AddQueue(fVulkanDevice.UniversalQueue);

 fGraphicsQueue:=AddQueue(fVulkanDevice.GraphicsQueue);

 fComputeQueue:=AddQueue(fVulkanDevice.ComputeQueue);

 fTransferQueue:=AddQueue(fVulkanDevice.TransferQueue);

 fPresentQueue:=AddQueue(fVulkanDevice.PresentQueue);

 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  fDrawToWaitOnSemaphores[InFlightFrameIndex].Initialize;
  fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Initialize;
  fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Initialize;
  fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Initialize;
 end;

 fVulkanUniversalQueueCommandBuffer:=TpvVulkanCommandBuffer.Create(fUniversalQueue.fCommandPool,
                                                                   VK_COMMAND_BUFFER_LEVEL_PRIMARY);
 fVulkanDevice.DebugUtils.SetObjectName(fVulkanUniversalQueueCommandBuffer.Handle,TVkObjectType.VK_OBJECT_TYPE_COMMAND_BUFFER,'FrameGraph.VulkanUniversalQueueCommandBuffer');

 fVulkanUniversalQueueCommandBufferFence:=TpvVulkanFence.Create(fVulkanDevice);
 fVulkanDevice.DebugUtils.SetObjectName(fVulkanUniversalQueueCommandBufferFence.Handle,TVkObjectType.VK_OBJECT_TYPE_FENCE,'FrameGraph.VulkanUniversalQueueCommandBufferFence');

 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  begin
   FillChar(fDrawToWaitSubmitInfos[InFlightFrameIndex],SizeOf(TVkSubmitInfo),#0);
   fDrawToWaitSubmitInfos[InFlightFrameIndex].sType:=VK_STRUCTURE_TYPE_SUBMIT_INFO;
  end;
  begin
   FillChar(fDrawToSignalSubmitInfos[InFlightFrameIndex],SizeOf(TVkSubmitInfo),#0);
   fDrawToSignalSubmitInfos[InFlightFrameIndex].sType:=VK_STRUCTURE_TYPE_SUBMIT_INFO;
  end;
 end;

 fDrawToWaitOnSemaphoreExternalDstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT{VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT});

 fTimerQueries:=nil;

 fCPUTimeValues:=nil;

 fLastCPUTimeValues:=nil;

 fPhysicalPassCrossEvents:=TPhysicalPassCrossEvents.Create(true);

end;

destructor TpvFrameGraph.Destroy;
var InFlightFrameIndex,Index:TpvSizeInt;
begin

 fCPUTimeValues:=nil;

 fLastCPUTimeValues:=nil;

 FreeAndNil(fTimerQueries);

 FreeAndNil(fPhysicalPasses);

 FreeAndNil(fResourceTypes);

 FreeAndNil(fResourceTypeNameHashMap);

 FreeAndNil(fResources);

 FreeAndNil(fResourceNameHashMap);

 FreeAndNil(fResourceTransitions);

 FreeAndNil(fResourceAliasGroups);

 FreeAndNil(fTopologicalSortedPasses);

 FreeAndNil(fExternalDataList);

 FreeAndNil(fPasses);

 FreeAndNil(fPassNameHashMap);

 FreeAndNil(fVulkanUniversalQueueCommandBufferFence);

 FreeAndNil(fVulkanUniversalQueueCommandBuffer);

 FreeAndNil(fAllQueueCommandBuffers);

 FreeAndNil(fPhysicalPassCrossEvents);

 FreeAndNil(fQueues);

 fQueueFamilyIndices.Finalize;

 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  for Index:=0 to fDrawToWaitOnSemaphores[InFlightFrameIndex].Count-1 do begin
   FreeAndNil(fDrawToWaitOnSemaphores[InFlightFrameIndex].Items[Index]);
  end;
  fDrawToWaitOnSemaphores[InFlightFrameIndex].Finalize;
  fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Finalize;
  fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Finalize;
  fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Finalize;
 end;

 fSurfaceImages:=nil;

 inherited Destroy;

end;

function TpvFrameGraph.ConvertRelativeToAbsoluteInFlightFrameIndex(const aCurrentInFlightFrameIndex,aRelativeInFlightFrameIndex:TpvSizeInt):TpvSizeInt;
begin
 result:=((((aCurrentInFlightFrameIndex+aRelativeInFlightFrameIndex)+fCountInFlightFrames) mod fCountInFlightFrames)+fCountInFlightFrames) mod fCountInFlightFrames;
end;

procedure TpvFrameGraph.SetSwapChain(const aSwapChain:TpvVulkanSwapChain;
                                     const aSurfaceDepthFormat:TVkFormat);
var InFlightFrameIndex:TpvSizeInt;
begin
 fSurfaceIsSwapchain:=true;
 fSurfaceWidth:=aSwapChain.Width;
 fSurfaceHeight:=aSwapChain.Height;
 fCountSurfaceImages:=aSwapChain.CountImages;
 fSurfaceColorFormat:=aSwapChain.ImageFormat;
 fSurfaceColorSpace:=aSwapChain.ImageColorSpace;
 fSurfaceDepthFormat:=aSurfaceDepthFormat;
 if fCountSurfaceImages>0 then begin
  SetLength(fSurfaceImages,fCountSurfaceImages);
  for InFlightFrameIndex:=0 to fCountSurfaceImages-1 do begin
   fSurfaceImages[InFlightFrameIndex]:=aSwapChain.Images[InFlightFrameIndex];
  end;
 end else begin
  fSurfaceImages:=nil;
 end;
end;

function TpvFrameGraph.AddQueue(const aPhysicalQueue:TpvVulkanQueue):TQueue;
var Index:TpvSizeInt;
    Found:boolean;
    Queue:TQueue;
begin
 result:=nil;
 for Queue in fQueues do begin
  if Queue.fPhysicalQueue=aPhysicalQueue then begin
   result:=Queue;
   break;
  end;
 end;
 if not assigned(result) then begin
  Found:=false;
  for Index:=0 to fQueueFamilyIndices.Count-1 do begin
   if fQueueFamilyIndices.Items[Index]=aPhysicalQueue.QueueFamilyIndex then begin
    Found:=true;
    break;
   end;
  end;
  if not Found then begin
   fQueueFamilyIndices.Add(aPhysicalQueue.QueueFamilyIndex);
  end;
  result:=TQueue.Create(self,aPhysicalQueue);
  fQueues.Add(result);
 end;
end;

function TpvFrameGraph.AddImageResourceType(const aName:TpvRawByteString;
                                            const aPersistent:boolean;
                                            const aFormat:TVkFormat;
                                            const aSamples:TVkSampleCountFlagBits;
                                            const aImageType:TImageType;
                                            const aImageSize:TImageSize;
                                            const aImageUsage:TVkImageUsageFlags;
                                            const aCountMipMapLevels:TVkUInt32;
                                            const aComponents:TVkComponentMapping;
                                            const aInitialLayout:TVkImageLayout;
                                            const aFinalLayout:TVkImageLayout;
                                            const aAdditionalFormat:TVkFormat):TResourceType;
begin
 result:=TImageResourceType.Create(self,
                                   aName,
                                   aPersistent,
                                   aFormat,
                                   aSamples,
                                   aImageType,
                                   aImageSize,
                                   aImageUsage,
                                   aCountMipMapLevels,
                                   aComponents,
                                   aInitialLayout,
                                   aFinalLayout,
                                   aAdditionalFormat);
end;

function TpvFrameGraph.AddImageResourceType(const aName:TpvRawByteString;
                                            const aPersistent:boolean;
                                            const aFormat:TVkFormat;
                                            const aSamples:TVkSampleCountFlagBits;
                                            const aImageType:TImageType;
                                            const aImageSize:TImageSize;
                                            const aImageUsage:TVkImageUsageFlags;
                                            const aCountMipMapLevels:TVkUInt32;
                                            const aInitialLayout:TVkImageLayout;
                                            const aFinalLayout:TVkImageLayout;
                                            const aAdditionalFormat:TVkFormat):TResourceType;
begin
 result:=TImageResourceType.Create(self,
                                   aName,
                                   aPersistent,
                                   aFormat,
                                   aSamples,
                                   aImageType,
                                   aImageSize,
                                   aImageUsage,
                                   aCountMipMapLevels,
                                   aInitialLayout,
                                   aFinalLayout,
                                   aAdditionalFormat);
end;

function TpvFrameGraph.AddBufferResourceType(const aName:TpvRawByteString;
                                             const aPersistent:boolean;
                                             const aSize:TVkDeviceSize;
                                             const aUsage:TVkBufferUsageFlags;
                                             const aMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
                                             const aMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
                                             const aMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags=0;
                                             const aMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags=0;
                                             const aMemoryRequiredHeapFlags:TVkMemoryHeapFlags=0;
                                             const aMemoryPreferredHeapFlags:TVkMemoryHeapFlags=0;
                                             const aMemoryAvoidHeapFlags:TVkMemoryHeapFlags=0;
                                             const aMemoryPreferredNotHeapFlags:TVkMemoryHeapFlags=0;
                                             const aBufferFlags:TpvVulkanBufferFlags=[]):TResourceType;
begin
 result:=TBufferResourceType.Create(self,
                                    aName,
                                    aPersistent,
                                    aSize,
                                    aUsage,
                                    aMemoryRequiredPropertyFlags,
                                    aMemoryPreferredPropertyFlags,
                                    aMemoryAvoidPropertyFlags,
                                    aMemoryPreferredNotPropertyFlags,
                                    aMemoryRequiredHeapFlags,
                                    aMemoryPreferredHeapFlags,
                                    aMemoryAvoidHeapFlags,
                                    aMemoryPreferredNotHeapFlags,
                                    aBufferFlags);
end;

procedure TpvFrameGraph.Setup;
begin

end;

procedure TpvFrameGraph.Compile;
type TEventBeforeAfter=(Event,Before,After);
     TDirection=(Input,Output);
     TDirections=set of TDirection;
 function GetDirections(const aResourceTransition:TResourceTransition):TDirections;
 begin
  result:=[];
  if assigned(aResourceTransition) then begin
   if aResourceTransition.fKind in TResourceTransition.AllInputs then begin
    Include(result,TDirection.Input);
   end;
   if aResourceTransition.fKind in TResourceTransition.AllOutputs then begin
    Include(result,TDirection.Output);
   end;
  end;
 end;
 function GetPipelineStageMask(const aResourceTransition:TResourceTransition):TVkPipelineStageFlags;
 begin
  case aResourceTransition.fKind of
   TpvFrameGraph.TResourceTransition.TKind.ImageInput,
   TpvFrameGraph.TResourceTransition.TKind.ImageDepthInput,
   TpvFrameGraph.TResourceTransition.TKind.ImageOutput,
   TpvFrameGraph.TResourceTransition.TKind.ImageResolveOutput,
   TpvFrameGraph.TResourceTransition.TKind.ImageDepthOutput:begin
    case aResourceTransition.fLayout of
     VK_IMAGE_LAYOUT_UNDEFINED:begin
      result:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
     end;
     VK_IMAGE_LAYOUT_GENERAL,
     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
      result:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
     end;
     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:begin
      result:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL:begin
      result:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
              TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT);
     end;
     VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:begin
      result:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);
     end;
     else {VK_IMAGE_LAYOUT_UNDEFINED:}begin
      result:=0;
     end;
    end;
   end;
   TpvFrameGraph.TResourceTransition.TKind.BufferInput,
   TpvFrameGraph.TResourceTransition.TKind.BufferOutput:begin
    result:=aResourceTransition.PipelineStage;
   end;
   else begin
    result:=0;
   end;
  end;
  if assigned(aResourceTransition.fPass) then begin
   if aResourceTransition.fPass is TRenderPass then begin
    result:=result and (TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                        ((TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT) or
                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT) or
                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT) or
                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT)) and
                         fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV));
   end else if aResourceTransition.fPass is TComputePass then begin
    result:=result and (TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV));
   end else if aResourceTransition.fPass is TTransferPass then begin
    result:=result and (TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT));
   end;
  end;
 end;
 function GetAccessMask(const aResourceTransition:TResourceTransition;const aDirections:TDirections):TVkAccessFlags;
 begin
  case aResourceTransition.fKind of
   TpvFrameGraph.TResourceTransition.TKind.ImageInput,
   TpvFrameGraph.TResourceTransition.TKind.ImageDepthInput:begin
    case aResourceTransition.fLayout of
     VK_IMAGE_LAYOUT_UNDEFINED:begin
      result:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_GENERAL:begin
      result:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
     end;
     else {VK_IMAGE_LAYOUT_UNDEFINED:}begin
      result:=0;
     end;
    end;
   end;
   TpvFrameGraph.TResourceTransition.TKind.ImageOutput,
   TpvFrameGraph.TResourceTransition.TKind.ImageResolveOutput,
   TpvFrameGraph.TResourceTransition.TKind.ImageDepthOutput:begin
    case aResourceTransition.fLayout of
     VK_IMAGE_LAYOUT_UNDEFINED:begin
      result:=TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_GENERAL:begin
      result:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL,
     VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
              TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
     end;
     VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
     end;
     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:begin
      result:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
     end;
     else {VK_IMAGE_LAYOUT_UNDEFINED:}begin
      result:=0;
     end;
    end;
   end;
   TpvFrameGraph.TResourceTransition.TKind.BufferInput,
   TpvFrameGraph.TResourceTransition.TKind.BufferOutput:begin
    result:=aResourceTransition.fAccessFlags;
   end;
   else begin
    result:=0;
   end;
  end;
 end;
 procedure IndexingPasses;
 var Index:TpvSizeInt;
 begin
  // Indexing passes
  for Index:=0 to fPasses.Count-1 do begin
   fPasses[Index].fIndex:=Index;
  end;
 end;
 procedure ResolveExplicitPassDependencies;
 var Index:TpvSizeInt;
 begin
  for Index:=0 to fPasses.Count-1 do begin
   fPasses[Index].ResolveExplicitPassDependencies;
  end;
 end;
 procedure ValidateAttachmentImages;
 var Pass:TPass;
     RenderPass:TRenderPass;
     ResourceTransition:TResourceTransition;
 begin
  // Validate that all input attachment images, output attachment images have the same size as defined
  // in the render pass and that all passes have a assigned queue
  for Pass in fPasses do begin
   if not assigned(Pass.fQueue) then begin
    raise EpvFrameGraphMissingQueue.Create('Pass "'+String(Pass.fName)+'" is without assigned queue');
   end;
   if Pass is TRenderPass then begin
    RenderPass:=Pass as TRenderPass;
    for ResourceTransition in RenderPass.fResourceTransitions do begin
     if (ResourceTransition.fKind in TResourceTransition.AllImages) and
        (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) and
        (ResourceTransition.fResource.fResourceType is TImageResourceType) and
        (TImageResourceType(ResourceTransition.fResource.fResourceType).fImageSize<>RenderPass.fSize) then begin
      raise EpvFrameGraphMismatchImageSize.Create('Mismatch attachment image size between pass "'+String(Pass.fName)+'" and resource "'+String(ResourceTransition.fResource.fName)+'"');
     end;
    end;
   end;
  end;
 end;
 procedure ValidateResources;
 type TResourceDynamicArray=TpvDynamicArray<TResource>;
 var Pass:TPass;
     Resource:TResource;
     ResourceTransition:TResourceTransition;
     ResourceDynamicArray:TResourceDynamicArray;
     OK:boolean;
 begin

  // Validate that all resources have at least one pass, which outputs this one resource
  for Resource in fResources do begin
   OK:=false;
   for ResourceTransition in Resource.fResourceTransitions do begin
    if ResourceTransition.fKind in TResourceTransition.AllOutputs then begin
     OK:=true;
     break;
    end;
   end;
   if not OK then begin
    raise EpvFrameGraphMissedGeneratorPassForResource.Create('Missed generator pass for resource "'+String(Resource.fName)+'"');
   end;
  end;

  // Validate that all resources do not have input and output transitions at a same pass at the same time
  ResourceDynamicArray.Initialize;
  try
   for Pass in fPasses do begin
    ResourceDynamicArray.Clear;
    for ResourceTransition in Pass.fResourceTransitions do begin
     if ResourceTransition.fKind in TResourceTransition.AllInputs then begin
      ResourceDynamicArray.Add(ResourceTransition.fResource);
     end;
    end;
    for ResourceTransition in Pass.fResourceTransitions do begin
     if ResourceTransition.fKind in TResourceTransition.AllOutputs then begin
      for Resource in ResourceDynamicArray.Items do begin
       if Resource=ResourceTransition.fResource then begin
        raise EpvFrameGraphResourceUsedAsInputAndOutputInTheSamePassAtTheSameTime.Create('Resource "'+String(Resource.Name)+'" is used as input and output in pass "'+String(Pass.fName)+'" at the same time');
       end;
      end;
     end;
    end;
   end;
  finally
   ResourceDynamicArray.Finalize;
  end;

 end;
 procedure FindRootPass;
 var Pass:TPass;
     RenderPass:TRenderPass;
     Resource:TResource;
     ResourceTransition:TResourceTransition;
     Temporary:TpvSizeUInt;
 begin
  // Find root pass (a render pass, which have only a single attachment image output to a surface/swapchain)
  if not assigned(fRootPass) then begin
   for Pass in fPasses do begin
    if Pass is TRenderPass then begin
     RenderPass:=Pass as TRenderPass;
     Temporary:=0;
     for ResourceTransition in RenderPass.fResourceTransitions do begin
      if (ResourceTransition.fKind in TResourceTransition.AllImageOutputs) and
         (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
       Resource:=ResourceTransition.fResource;
       if (Resource.fResourceType is TImageResourceType) and
          (TImageResourceType(Resource.fResourceType).fImageType=TImageType.Surface) then begin
        Temporary:=Temporary or 1;
       end else if not ((Resource.fResourceType is TImageResourceType) and
                        (TImageResourceType(Resource.fResourceType).fImageType=TImageType.Depth)) then begin
        Temporary:=Temporary or 2;
        break;
       end;
      end;
     end;
     if Temporary=1 then begin
      fRootPass:=Pass;
      break;
     end;
    end;
   end;
   if not assigned(fRootPass) then begin
    raise EpvFrameGraph.Create('No root pass found');
   end;
  end;
 end;
 procedure CreateDirectedAcyclicGraphOfGraphPasses;
 type TAction=
       (
        Process,
        RemoveTemporaryMarkFlag,
        Add
       );
      TStackItem=record
       Action:TAction;
       Pass:TPass;
      end;
      PStackItem=^TStackItem;
      TStack=TpvDynamicStack<TStackItem>;
  function NewStackItem(const aAction:TAction;const aPass:TPass):TStackItem;
  begin
   result.Action:=aAction;
   result.Pass:=aPass;
  end;
 var Index,
     Count,
     Weight:TpvSizeInt;
     Stack:TStack;
     StackItem:TStackItem;
     Pass,
     OtherPass:TPass;
     ExplicitPassDependency:TExplicitPassDependency;
     ResourceTransition,
     OtherResourceTransition:TResourceTransition;
     Resource:TResource;
     WorkPasses:array[0..1] of TPass;
 begin
  // Construct the directed acyclic graph by doing a modified-DFS-based topological sort at the same time
  Stack.Initialize;
  try
   fTopologicalSortedPasses.Clear;
   for Pass in fPasses do begin
    Pass.fPhysicalPass:=nil;
    if Pass is TRenderPass then begin
     TRenderPass(Pass).fPhysicalRenderPassSubpass:=nil;
    end;
    Pass.fFlags:=Pass.fFlags-[TPass.TFlag.Used,TPass.TFlag.PermanentlyMarked,TPass.TFlag.TemporaryMarked];
    Pass.fPreviousPasses.Clear;
    Pass.fNextPasses.Clear;
   end;
   Stack.Push(NewStackItem(TAction.Process,fRootPass));
   while Stack.Pop(StackItem) do begin
    Pass:=StackItem.Pass;
    case StackItem.Action of
     TAction.Process:begin
      if TPass.TFlag.TemporaryMarked in Pass.fFlags then begin
       raise EpvFrameGraphRecursion.Create('Recursion detected');
      end;
      Include(Pass.fFlags,TPass.TFlag.TemporaryMarked);
      if not (TPass.TFlag.PermanentlyMarked in Pass.fFlags) then begin
       Pass.fFlags:=Pass.fFlags+[TPass.TFlag.Used,TPass.TFlag.PermanentlyMarked];
       for ExplicitPassDependency in Pass.fExplicitPassDependencies do begin
        OtherPass:=ExplicitPassDependency.fPass;
        if Pass<>OtherPass then begin
         if Pass.fPreviousPasses.IndexOf(OtherPass)<0 then begin
          Pass.fPreviousPasses.Add(OtherPass);
         end;
         if OtherPass.fNextPasses.IndexOf(Pass)<0 then begin
          OtherPass.fNextPasses.Add(Pass);
         end;
        end;
       end;
       for ResourceTransition in Pass.fResourceTransitions do begin
        if (ResourceTransition.fKind in TResourceTransition.AllInputs) and
           not (TResourceTransition.TFlag.PreviousFrameInput in ResourceTransition.Flags) then begin
         Resource:=ResourceTransition.fResource;
         for OtherResourceTransition in Resource.fResourceTransitions do begin
          if (ResourceTransition<>OtherResourceTransition) and
             (Pass<>OtherResourceTransition.fPass) and
             (OtherResourceTransition.fKind in TResourceTransition.AllOutputs) then begin
           if Pass.fPreviousPasses.IndexOf(OtherResourceTransition.fPass)<0 then begin
            Pass.fPreviousPasses.Add(OtherResourceTransition.fPass);
           end;
           if OtherResourceTransition.fPass.fNextPasses.IndexOf(Pass)<0 then begin
            OtherResourceTransition.fPass.fNextPasses.Add(Pass);
           end;
          end;
         end;
        end;
       end;
       if Pass is TRenderPass then begin
        // Pre-sort for better Subpass grouping at a later point
        Index:=0;
        Count:=Pass.fPreviousPasses.Count;
        while (Index+1)<Count do begin
         WorkPasses[0]:=Pass.fPreviousPasses[Index];
         WorkPasses[1]:=Pass.fPreviousPasses[Index+1];
         if WorkPasses[0].fQueue<>WorkPasses[1].fQueue then begin
          Weight:=(ord(WorkPasses[0].fQueue=Pass.fQueue) and 1)-(ord(WorkPasses[1].fQueue=Pass.fQueue) and 1);
          if Weight=0 then begin
           if TpvPtrUInt(WorkPasses[0].fQueue)<TpvPtrUInt(WorkPasses[1].fQueue) then begin
            Weight:=-1;
           end else begin
            Weight:=1;
           end;
          end;
         end else begin
          Weight:=(ord(WorkPasses[0] is TRenderPass) and 1)-(ord(WorkPasses[1] is TRenderPass) and 1);
          if Weight=0 then begin
           Weight:=(ord(TRenderPass(WorkPasses[0]).fSize=TRenderPass(Pass).fSize) and 1)-
                   (ord(TRenderPass(WorkPasses[1]).fSize=TRenderPass(Pass).fSize) and 1);
          end;
         end;
         if Weight<0 then begin
          Pass.fPreviousPasses.Exchange(Index,Index+1);
          if Index>0 then begin
           dec(Index);
          end else begin
           inc(Index);
          end;
         end else begin
          inc(Index);
         end;
        end;
       end;
       Stack.Push(NewStackItem(TAction.Add,Pass));
      end;
      Stack.Push(NewStackItem(TAction.RemoveTemporaryMarkFlag,Pass));
      for OtherPass in Pass.fPreviousPasses do begin
       Stack.Push(NewStackItem(TAction.Process,OtherPass));
      end;
     end;
     TAction.RemoveTemporaryMarkFlag:begin
      Exclude(Pass.fFlags,TPass.TFlag.TemporaryMarked);
     end;
     TAction.Add:begin
      Pass.fTopologicalSortIndex:=fTopologicalSortedPasses.Add(Pass);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
 procedure CreatePhysicalPasses;
 type TOutputAttachmentImagesResources=TpvHashMap<TResource,boolean>;
 var Index,
     Count,
     CountFoundCrossSubpassAttachmentPairs:TpvSizeInt;
     Pass,
     OtherPass:TPass;
     PhysicalRenderPass:TPhysicalRenderPass;
     ResourceTransition:TResourceTransition;
     Compatible:boolean;
     OutputAttachmentImagesResources:TOutputAttachmentImagesResources;
     ExternalWaitingOnSemaphoreReference:TExternalWaitingOnSemaphoreReference;
 begin
  // Create physical passes together with merging render passes to sub passes of a real
  // physical render pass
  OutputAttachmentImagesResources:=TOutputAttachmentImagesResources.Create(false);
  try
   fPhysicalPasses.Clear;
   fMaximumOverallPhysicalPassIndex:=0;
   Index:=0;
   Count:=fTopologicalSortedPasses.Count;
   while Index<Count do begin
    Pass:=fTopologicalSortedPasses[Index];
    if Pass is TComputePass then begin
     Pass.fPhysicalPass:=TPhysicalComputePass.Create(self,TComputePass(Pass));
     Pass.fPhysicalPass.fIndex:=fPhysicalPasses.Add(Pass.fPhysicalPass);
     for ExternalWaitingOnSemaphoreReference in Pass.fExternalWaitingOnSemaphoreReferences do begin
      Pass.fPhysicalPass.fExternalWaitingOnSemaphoreReferences.Add(ExternalWaitingOnSemaphoreReference);
     end;
     Pass.fPhysicalPass.fSeparateCommandBuffer:=Pass.GetSeparateCommandBuffer;
     Pass.fPhysicalPass.fHasSecondaryBuffers:=Pass.GetHasSecondaryBuffers;
     inc(Index);
    end else if Pass is TTransferPass then begin
     Pass.fPhysicalPass:=TPhysicalTransferPass.Create(self,TTransferPass(Pass));
     Pass.fPhysicalPass.fIndex:=fPhysicalPasses.Add(Pass.fPhysicalPass);
     for ExternalWaitingOnSemaphoreReference in Pass.fExternalWaitingOnSemaphoreReferences do begin
      Pass.fPhysicalPass.fExternalWaitingOnSemaphoreReferences.Add(ExternalWaitingOnSemaphoreReference);
     end;
     Pass.fPhysicalPass.fSeparateCommandBuffer:=Pass.GetSeparateCommandBuffer;
     Pass.fPhysicalPass.fHasSecondaryBuffers:=Pass.GetHasSecondaryBuffers;
     inc(Index);
    end else if Pass is TCustomPass then begin
     Pass.fPhysicalPass:=TPhysicalCustomPass.Create(self,TCustomPass(Pass));
     Pass.fPhysicalPass.fIndex:=fPhysicalPasses.Add(Pass.fPhysicalPass);
     for ExternalWaitingOnSemaphoreReference in Pass.fExternalWaitingOnSemaphoreReferences do begin
      Pass.fPhysicalPass.fExternalWaitingOnSemaphoreReferences.Add(ExternalWaitingOnSemaphoreReference);
     end;
     Pass.fPhysicalPass.fSeparateCommandBuffer:=Pass.GetSeparateCommandBuffer;
     Pass.fPhysicalPass.fHasSecondaryBuffers:=Pass.GetHasSecondaryBuffers;
     inc(Index);
    end else if Pass is TRenderPass then begin
     OutputAttachmentImagesResources.Clear;
     for ResourceTransition in Pass.fResourceTransitions do begin
      if (ResourceTransition.Kind in TResourceTransition.AllImageOutputs) and
         (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
       OutputAttachmentImagesResources[ResourceTransition.fResource]:=true;
      end;
     end;
     PhysicalRenderPass:=TPhysicalRenderPass.Create(self,Pass.fQueue);
     Pass.fPhysicalPass:=PhysicalRenderPass;
     Pass.fPhysicalPass.fIndex:=fPhysicalPasses.Add(Pass.fPhysicalPass);
     for ExternalWaitingOnSemaphoreReference in Pass.fExternalWaitingOnSemaphoreReferences do begin
      Pass.fPhysicalPass.fExternalWaitingOnSemaphoreReferences.Add(ExternalWaitingOnSemaphoreReference);
     end;
     Pass.fPhysicalPass.fSeparateCommandBuffer:=Pass.GetSeparateCommandBuffer;
     Pass.fPhysicalPass.fHasSecondaryBuffers:=Pass.GetHasSecondaryBuffers;
     TRenderPass(Pass).fPhysicalRenderPassSubpass:=TPhysicalRenderPass.TSubpass.Create(PhysicalRenderPass,TRenderPass(Pass));
     TRenderPass(Pass).fPhysicalRenderPassSubpass.fIndex:=PhysicalRenderPass.fSubpasses.Add(TRenderPass(Pass).fPhysicalRenderPassSubpass);
     PhysicalRenderPass.fMultiview:=TRenderPass(Pass).fMultiviewMask<>0;
     inc(Index);
     if fTryToMergeSubpasses and
        (Pass.fExternalWaitingOnSemaphoreReferences.Count=0) and
        ((Pass.fFlags*[TPass.TFlag.SeparatePhysicalPass,
                       TPass.TFlag.SeparateCommandBuffer,
                       TPass.TFlag.Toggleable])=[]) then begin
      while Index<Count do begin
       OtherPass:=fTopologicalSortedPasses[Index];
       if (OtherPass.fExternalWaitingOnSemaphoreReferences.Count=0) and
          ((OtherPass.fFlags*[TPass.TFlag.SeparatePhysicalPass,
                              TPass.TFlag.SeparateCommandBuffer,
                              TPass.TFlag.Toggleable])=[]) and
          (OtherPass is TRenderPass) and
          (TRenderPass(OtherPass).fQueue=TRenderPass(Pass).fQueue) and
          (TRenderPass(OtherPass).fSize=TRenderPass(Pass).fSize) and
          (TRenderPass(OtherPass).fMultiviewMask=TRenderPass(Pass).fMultiviewMask) then begin
        CountFoundCrossSubpassAttachmentPairs:=0;
        Compatible:=true;
        for ResourceTransition in OtherPass.fResourceTransitions do begin
         if ResourceTransition.Kind in TResourceTransition.AllImageInputs then begin
          if TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags then begin
           if OutputAttachmentImagesResources.ExistKey(ResourceTransition.Resource) then begin
            inc(CountFoundCrossSubpassAttachmentPairs);
           end else begin
            Compatible:=false;
            break;
           end;
          end else begin
           if OutputAttachmentImagesResources.ExistKey(ResourceTransition.Resource) then begin
            Compatible:=false;
            break;
           end;
          end;
         end;
        end;
        if (CountFoundCrossSubpassAttachmentPairs=0) or // In this case it's compatible but not useful, so no merge in order to avoid
                                                        // unnecessarily exhausting the attachment count limits per physical render pass
           (not Compatible) then begin                  // And when it's not compatible, then we don't merge the subpasses anyway
         break;
        end;
       end else begin
        break;
       end;
       for ResourceTransition in OtherPass.fResourceTransitions do begin
        if (ResourceTransition.Kind in TResourceTransition.AllImageOutputs) and
           (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
         OutputAttachmentImagesResources[ResourceTransition.fResource]:=true;
        end;
       end;
       OtherPass.fPhysicalPass:=Pass.fPhysicalPass;
       TRenderPass(OtherPass).fPhysicalRenderPassSubpass:=TPhysicalRenderPass.TSubpass.Create(PhysicalRenderPass,TRenderPass(OtherPass));
       TRenderPass(OtherPass).fPhysicalRenderPassSubpass.fIndex:=PhysicalRenderPass.fSubpasses.Add(TRenderPass(OtherPass).fPhysicalRenderPassSubpass);
       Pass.fPhysicalPass.fSeparateCommandBuffer:=Pass.fPhysicalPass.fSeparateCommandBuffer or Pass.GetSeparateCommandBuffer;
       Pass.fPhysicalPass.fHasSecondaryBuffers:=Pass.fPhysicalPass.fHasSecondaryBuffers or Pass.GetHasSecondaryBuffers;
       PhysicalRenderPass.fMultiview:=PhysicalRenderPass.fMultiview or (TRenderPass(OtherPass).fMultiviewMask<>0);
       fMaximumOverallPhysicalPassIndex:=Max(fMaximumOverallPhysicalPassIndex,OtherPass.fPhysicalPass.fIndex);
       inc(Index);
      end;
     end;
    end else begin
     inc(Index);
    end;
    fMaximumOverallPhysicalPassIndex:=Max(fMaximumOverallPhysicalPassIndex,Pass.fPhysicalPass.fIndex);
   end;
  finally
   FreeAndNil(OutputAttachmentImagesResources);
  end;
 end;
 procedure FindRootPhysicalPass;
 var Pass:TPass;
 begin
  fRootPhysicalPass:=nil;
  for Pass in fPasses do begin
   if (TPass.TFlag.Used in Pass.fFlags) and
      assigned(Pass.fPhysicalPass) and
      (Pass=fRootPass) then begin
    fRootPhysicalPass:=Pass.fPhysicalPass;
    break;
   end;
  end;
  if not assigned(fRootPhysicalPass) then begin
   raise EpvFrameGraph.Create('No root physical pass found');
  end;
 end;
 procedure TransferDependenciesFromGraphPassesToPhysicalPasses;
 var Pass,
     OtherPass:TPass;
     ResourceTransition,
     OtherResourceTransition:TResourceTransition;
     Resource:TResource;
 begin
  // Transfer the dependency informations from the graph passes to the physical passes
  for Pass in fPasses do begin
   if (TPass.TFlag.Used in Pass.fFlags) and
      assigned(Pass.fPhysicalPass) then begin
    for ResourceTransition in Pass.fResourceTransitions do begin
     Resource:=ResourceTransition.fResource;
     for OtherResourceTransition in Resource.fResourceTransitions do begin
      if (ResourceTransition<>OtherResourceTransition) and
         (ResourceTransition.fPass<>OtherResourceTransition.fPass) and
         (ResourceTransition.fPass.fPhysicalPass<>OtherResourceTransition.fPass.fPhysicalPass) and
         (TPass.TFlag.Used in OtherResourceTransition.fPass.fFlags) and
         assigned(OtherResourceTransition.fPass.fPhysicalPass) then begin
       OtherPass:=OtherResourceTransition.fPass;
       if (ResourceTransition.fKind in TResourceTransition.AllInputs) and
          (OtherResourceTransition.fKind in TResourceTransition.AllOutputs) and
          (Pass.fPhysicalPass.fInputDependencies.IndexOf(OtherPass.fPhysicalPass)<0) then begin
        Pass.fPhysicalPass.fInputDependencies.Add(OtherPass.fPhysicalPass);
       end;
       if (ResourceTransition.fKind in TResourceTransition.AllOutputs) and
          (OtherResourceTransition.fKind in TResourceTransition.AllInputs) and
          (Pass.fPhysicalPass.fOutputDependencies.IndexOf(OtherPass.fPhysicalPass)<0) then begin
        Pass.fPhysicalPass.fOutputDependencies.Add(OtherPass.fPhysicalPass);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure CalculateResourceLifetimes;
 var Pass:TPass;
     Resource:TResource;
     ResourceTransition:TResourceTransition;
 begin
  // Calculate resource lifetimes (from minimum physical pass step index to maximum
  // physical pass step index) for calculating aliasing and reusing of resources at a later point
  for Resource in fResources do begin
   Resource.fMinimumTopologicalSortPassIndex:=High(TpvSizeInt);
   Resource.fMaximumTopologicalSortPassIndex:=Low(TpvSizeInt);
   Resource.fMinimumPhysicalPassStepIndex:=High(TpvSizeInt);
   Resource.fMaximumPhysicalPassStepIndex:=Low(TpvSizeInt);
   for ResourceTransition in Resource.fResourceTransitions do begin
    Pass:=ResourceTransition.fPass;
    if assigned(Pass.fPhysicalPass) then begin
     if ((ResourceTransition.fFlags*[TResourceTransition.TFlag.PreviousFrameInput,
                                     TResourceTransition.TFlag.NextFrameOutput])<>[]) or
        ((ResourceTransition.fResource.fResourceType is TImageResourceType) and
         (TImageResourceType(ResourceTransition.fResource.fResourceType).fImageType=TImageType.Surface)) then begin
      // In this cases, this one resource must life from the begin to the end of the whole
      // directed acyclic graph for the simplicity of safety, because it can be still optimized
      // in a better way later
      if not Resource.fUsed then begin
       Resource.fUsed:=true;
       Resource.fMinimumTopologicalSortPassIndex:=0;
       Resource.fMaximumTopologicalSortPassIndex:=fTopologicalSortedPasses.Count-1;
       Resource.fMinimumPhysicalPassStepIndex:=0;
       Resource.fMaximumPhysicalPassStepIndex:=fMaximumOverallPhysicalPassIndex;
      end;
     end else begin
      if Resource.fUsed then begin
       Resource.fMinimumTopologicalSortPassIndex:=Min(Resource.fMinimumTopologicalSortPassIndex,Pass.fTopologicalSortIndex);
       Resource.fMaximumTopologicalSortPassIndex:=Max(Resource.fMinimumTopologicalSortPassIndex,Pass.fTopologicalSortIndex);
       Resource.fMinimumPhysicalPassStepIndex:=Min(Resource.fMinimumPhysicalPassStepIndex,Pass.fPhysicalPass.fIndex);
       Resource.fMaximumPhysicalPassStepIndex:=Max(Resource.fMaximumPhysicalPassStepIndex,Pass.fPhysicalPass.fIndex);
      end else begin
       Resource.fUsed:=true;
       Resource.fMinimumTopologicalSortPassIndex:=Pass.fTopologicalSortIndex;
       Resource.fMaximumTopologicalSortPassIndex:=Pass.fTopologicalSortIndex;
       Resource.fMinimumPhysicalPassStepIndex:=Pass.fPhysicalPass.fIndex;
       Resource.fMaximumPhysicalPassStepIndex:=Pass.fPhysicalPass.fIndex;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure FindTransientResources;
 var Resource:TResource;
     ResourceTransition:TResourceTransition;
     Transient:boolean;
 begin
  if fVulkanDevice.MemoryManager.LazilyAllocationSupport then begin
   for Resource in fResources do begin
    Transient:=false;
    if assigned(Resource.fResourceType) and
       (Resource.fResourceType is TImageResourceType) and
       ((TImageResourceType(Resource.fResourceType).fImageUsage and not
         (TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or
          TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or
          TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or
          TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT) or
          TVkImageUsageFlags(VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR)))=0) and
       ((Resource.fMaximumPhysicalPassStepIndex-Resource.fMinimumPhysicalPassStepIndex)<1) then begin
     Transient:=true;
     for ResourceTransition in Resource.fResourceTransitions do begin
      if not ((ResourceTransition.fKind in TResourceTransition.AllImages) and
              (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags)) then begin
       Transient:=false;
       break;
      end;
     end;
     if Transient then begin
      if Resource.fMinimumPhysicalPassStepIndex=Resource.fMaximumPhysicalPassStepIndex then begin
       // Alright! Transient can stay true here in this case.
      end else begin
       Transient:=false;
       // TODO: Add inter-subpass checking
      end;
     end;
    end;
    Resource.fTransient:=Transient;
   end;
  end else begin
   for Resource in fResources do begin
    Resource.fTransient:=false;
   end;
  end;
 end;
 procedure CreateResourceAliasGroups;
  function CanResourceReused(const aResource:TResource):boolean;
  begin
   result:=(not aResource.fResourceType.fPersistent) and
           (not assigned(aResource.fExternalData)) and
           (not ((aResource.fResourceType is TImageResourceType) and
                 (TImageResourceType(aResource.fResourceType).fImageType=TImageType.Surface))) and
           (not aResource.fTransient);
  end;
 var Index,
     OtherIndex:TpvSizeInt;
     Resource,
     OtherResource:TResource;
     ResourceTransition:TResourceTransition;
     ResourceAliasGroup:TResourceAliasGroup;
 begin
  // Construct resource alias groups, depending on the non-intersecting resource lifetime span
  // segments and resource types
  for Resource in fResources do begin
   Resource.fResourceAliasGroup:=nil;
  end;
  fResourceAliasGroups.Clear;
  for Index:=0 to fResources.Count-1 do begin
   Resource:=fResources.Items[Index];
   if not assigned(Resource.fResourceAliasGroup) then begin
    ResourceAliasGroup:=TResourceAliasGroup.Create(self);
    try
     ResourceAliasGroup.fResourceType:=Resource.fResourceType;
     ResourceAliasGroup.fResourceInstanceType:=Resource.fResourceInstanceType;
     ResourceAliasGroup.fExternalData:=Resource.fExternalData;
     ResourceAliasGroup.fTransient:=Resource.fTransient;
     ResourceAliasGroup.fMinimumPhysicalPassStepIndex:=Resource.fMinimumPhysicalPassStepIndex;
     ResourceAliasGroup.fMaximumPhysicalPassStepIndex:=Resource.fMaximumPhysicalPassStepIndex;
     ResourceAliasGroup.fResources.Add(Resource);
    finally
     Resource.fResourceAliasGroup:=ResourceAliasGroup;
    end;
    if CanResourceReused(Resource) then begin
     for OtherIndex:=Index+1 to fResources.Count-1 do begin
      OtherResource:=fResources.Items[OtherIndex];
      if (not assigned(OtherResource.fResourceAliasGroup)) and
         (Resource.fResourceType=OtherResource.fResourceType) and
         (Resource.fResourceInstanceType=OtherResource.fResourceInstanceType) and
         (Resource.fExternalData=OtherResource.fExternalData) and
         CanResourceReused(OtherResource) then begin
       if (not ((ResourceAliasGroup.fMinimumPhysicalPassStepIndex<=OtherResource.fMaximumPhysicalPassStepIndex) and
               (OtherResource.fMinimumPhysicalPassStepIndex<=ResourceAliasGroup.fMaximumPhysicalPassStepIndex))) and
          //Resource.fResourceTransitions.MergeCompatibleWith(OtherResource.fResourceTransitions) and
          (((Resource.fUsedFlags or OtherResource.fUsedFlags) and TpvFrameGraph.ForbiddenUsedImageDepthInputFlagCombination)<>TpvFrameGraph.ForbiddenUsedImageDepthInputFlagCombination) and
          not Resource.fResourceTransitions.HasPhysicalPassesIntersectionWith(OtherResource.fResourceTransitions) then begin
        ResourceAliasGroup.fMinimumPhysicalPassStepIndex:=Min(ResourceAliasGroup.fMinimumPhysicalPassStepIndex,OtherResource.fMinimumPhysicalPassStepIndex);
        ResourceAliasGroup.fMaximumPhysicalPassStepIndex:=Max(ResourceAliasGroup.fMaximumPhysicalPassStepIndex,OtherResource.fMaximumPhysicalPassStepIndex);
        ResourceAliasGroup.fResources.Add(OtherResource);
        OtherResource.fResourceAliasGroup:=Resource.fResourceAliasGroup;
        //writeln(Resource.fName,' ',OtherResource.fName);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure CreatePhysicalPassQueueSequences;
 var PhysicalPass:TPhysicalPass;
 begin
  // PhysicalPasses is already toplogically sorted, so it's easy here
  for PhysicalPass in fPhysicalPasses do begin
   PhysicalPass.fQueue.fPhysicalPasses.Add(PhysicalPass);
  end;
 end;
 procedure CreatePhysicalPassQueueCommandBuffers;
 var PhysicalPass,
     OtherPhysicalPass:TPhysicalPass;
     Queue:TQueue;
     CommandBuffer:TQueue.TCommandBuffer;
     PhysicalPassWithCrossQueueDependencies:boolean;
     ResourceTransition:TResourceTransition;
 begin

  for Queue in fQueues do begin

   CommandBuffer:=nil;

   for PhysicalPass in Queue.fPhysicalPasses do begin

    PhysicalPassWithCrossQueueDependencies:=false;

    for OtherPhysicalPass in PhysicalPass.fInputDependencies do begin
     if Queue<>OtherPhysicalPass.fQueue then begin
      PhysicalPassWithCrossQueueDependencies:=true;
      break;
     end;
    end;

    if not PhysicalPassWithCrossQueueDependencies then begin
     for OtherPhysicalPass in PhysicalPass.fOutputDependencies do begin
      if Queue<>OtherPhysicalPass.fQueue then begin
       PhysicalPassWithCrossQueueDependencies:=true;
       break;
      end;
     end;
    end;

    if (not assigned(CommandBuffer)) or
       (PhysicalPass.fSeparateCommandBuffer or
        PhysicalPassWithCrossQueueDependencies) or
       (PhysicalPass.fExternalWaitingOnSemaphoreReferences.Count>0) then begin
     CommandBuffer:=TQueue.TCommandBuffer.Create(Queue);
     Queue.fCommandBuffers.Add(CommandBuffer);
     fAllQueueCommandBuffers.Add(CommandBuffer);
    end;

    CommandBuffer.fPhysicalPasses.Add(PhysicalPass);

    PhysicalPass.fQueueCommandBuffer:=CommandBuffer;

    if PhysicalPass.fSeparateCommandBuffer or
       PhysicalPassWithCrossQueueDependencies or
       (PhysicalPass.fExternalWaitingOnSemaphoreReferences.Count>0) then begin
     CommandBuffer:=nil;
    end;

   end;

  end;

 end;
 procedure CreateResourceAliasGroupData;
 var MinimumTopologicalSortIndex:TpvSizeInt;
     ResourceAliasGroup:TResourceAliasGroup;
     ResourceType:TResourceType;
     ImageResourceType:TImageResourceType;
     BufferResourceType:TBufferResourceType;
     ResourcePhysicalImageData:TResourcePhysicalImageData;
     ResourcePhysicalBufferData:TResourcePhysicalBufferData;
     Resource:TResource;
     ResourceTransition:TResourceTransition;
 begin
  // Create data for the resource alias groups
  for ResourceAliasGroup in fResourceAliasGroups do begin
   if not assigned(ResourceAliasGroup.fResourcePhysicalData) then begin
    ResourceType:=ResourceAliasGroup.fResourceType;
    if ResourceType is TImageResourceType then begin
     Assert((not assigned(ResourceAliasGroup.fExternalData)) or (ResourceAliasGroup.fExternalData is TExternalImageData));
     ImageResourceType:=TImageResourceType(ResourceType);
     ResourceAliasGroup.fResourcePhysicalData:=TResourcePhysicalImageData.Create(self);
     ResourcePhysicalImageData:=TResourcePhysicalImageData(ResourceAliasGroup.fResourcePhysicalData);
     ResourcePhysicalImageData.fResourceType:=ResourceType;
     ResourcePhysicalImageData.fResourceInstanceType:=ResourceAliasGroup.fResourceInstanceType;
     ResourcePhysicalImageData.fExternalData:=ResourceAliasGroup.fExternalData;
     ResourcePhysicalImageData.fIsSurface:=ImageResourceType.fImageType=TImageType.Surface;
     ResourcePhysicalImageData.fImageUsageFlags:=TVkImageUsageFlags(ImageResourceType.fImageUsage);
     if ResourceAliasGroup.fTransient then begin
      ResourcePhysicalImageData.fImageUsageFlags:=ResourcePhysicalImageData.fImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT);
     end;
     ResourcePhysicalImageData.fRequestedFormat:=ImageResourceType.fFormat;
     ResourcePhysicalImageData.fFormat:=ImageResourceType.fFormat;
     ResourcePhysicalImageData.fAdditionalFormat:=ImageResourceType.fAdditionalFormat;
     ResourcePhysicalImageData.fExtent.width:=Max(1,round(ImageResourceType.fImageSize.Size.x));
     ResourcePhysicalImageData.fExtent.height:=Max(1,round(ImageResourceType.fImageSize.Size.y));
     ResourcePhysicalImageData.fExtent.depth:=Max(1,round(ImageResourceType.fImageSize.Size.z));
     ResourcePhysicalImageData.fCountMipMaps:=1;
     ResourcePhysicalImageData.fCountArrayLayers:=round(ImageResourceType.fImageSize.Size.w);
     ResourcePhysicalImageData.fTextureArray:=ResourcePhysicalImageData.fCountArrayLayers>0;
     ResourcePhysicalImageData.fCountArrayLayers:=Max(1,ResourcePhysicalImageData.fCountArrayLayers);
     ResourcePhysicalImageData.fSamples:=ImageResourceType.fSamples;
     ResourcePhysicalImageData.fTiling:=VK_IMAGE_TILING_OPTIMAL;
     ResourcePhysicalImageData.fInitialLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
     ResourcePhysicalImageData.fFirstInitialLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
     MinimumTopologicalSortIndex:=High(TpvSizeInt);
     for Resource in ResourceAliasGroup.fResources do begin
      for ResourceTransition in Resource.fResourceTransitions do begin
       if ResourceTransition.fPass.fTopologicalSortIndex<MinimumTopologicalSortIndex then begin
        MinimumTopologicalSortIndex:=ResourceTransition.fPass.fTopologicalSortIndex;
        ResourcePhysicalImageData.fFirstInitialLayout:=ResourceTransition.fLayout;
       end;
      end;
     end;
     ResourcePhysicalImageData.fImageCreateFlags:=0;
     if ResourcePhysicalImageData.fExtent.depth>1 then begin
      ResourcePhysicalImageData.fImageType:=VK_IMAGE_TYPE_3D;
     end else begin
      ResourcePhysicalImageData.fImageType:=VK_IMAGE_TYPE_2D;
     end;
     ResourcePhysicalImageData.fSharingMode:=VK_SHARING_MODE_EXCLUSIVE;
     ResourcePhysicalImageData.fImageSubresourceRange.aspectMask:=ImageResourceType.fImageType.GetAspectMask;
     ResourcePhysicalImageData.fImageSubresourceRange.baseMipLevel:=0;
     ResourcePhysicalImageData.fImageSubresourceRange.levelCount:=ImageResourceType.fCountMipMapLevels;
     ResourcePhysicalImageData.fImageSubresourceRange.baseArrayLayer:=0;
     ResourcePhysicalImageData.fImageSubresourceRange.layerCount:=ResourcePhysicalImageData.fCountArrayLayers;
     if ResourcePhysicalImageData.fExtent.depth>1 then begin
      if ResourcePhysicalImageData.fTextureArray then begin
       raise EpvFrameGraph.Create('3D array image not supported');
      end else begin
       ResourcePhysicalImageData.fImageViewType:=VK_IMAGE_VIEW_TYPE_3D;
      end;
     end else begin
      if ResourcePhysicalImageData.fTextureArray then begin
       ResourcePhysicalImageData.fImageViewType:=VK_IMAGE_VIEW_TYPE_2D_ARRAY;
      end else begin
       ResourcePhysicalImageData.fImageViewType:=VK_IMAGE_VIEW_TYPE_2D;
      end;
     end;
     ResourcePhysicalImageData.fComponents:=ImageResourceType.fComponents;
    end else if ResourceType is TBufferResourceType then begin
     Assert((not assigned(ResourceAliasGroup.fExternalData)) or (ResourceAliasGroup.fExternalData is TExternalBufferData));
     BufferResourceType:=TBufferResourceType(ResourceType);
     ResourceAliasGroup.fResourcePhysicalData:=TResourcePhysicalBufferData.Create(self);
     ResourcePhysicalBufferData:=TResourcePhysicalBufferData(ResourceAliasGroup.fResourcePhysicalData);
     ResourcePhysicalBufferData.fResourceType:=ResourceType;
     ResourcePhysicalBufferData.fResourceInstanceType:=ResourceAliasGroup.fResourceInstanceType;
     ResourcePhysicalBufferData.fExternalData:=ResourceAliasGroup.fExternalData;
     ResourcePhysicalBufferData.fSize:=BufferResourceType.fSize;
     ResourcePhysicalBufferData.fUsage:=BufferResourceType.fUsage;
     ResourcePhysicalBufferData.fMemoryRequiredPropertyFlags:=BufferResourceType.fMemoryRequiredPropertyFlags;
     ResourcePhysicalBufferData.fMemoryPreferredPropertyFlags:=BufferResourceType.fMemoryPreferredPropertyFlags;
     ResourcePhysicalBufferData.fMemoryAvoidPropertyFlags:=BufferResourceType.fMemoryAvoidPropertyFlags;
     ResourcePhysicalBufferData.fMemoryPreferredNotPropertyFlags:=BufferResourceType.fMemoryPreferredNotPropertyFlags;
     ResourcePhysicalBufferData.fMemoryRequiredHeapFlags:=BufferResourceType.fMemoryRequiredHeapFlags;
     ResourcePhysicalBufferData.fMemoryPreferredHeapFlags:=BufferResourceType.fMemoryPreferredHeapFlags;
     ResourcePhysicalBufferData.fMemoryAvoidHeapFlags:=BufferResourceType.fMemoryAvoidHeapFlags;
     ResourcePhysicalBufferData.fMemoryPreferredNotHeapFlags:=BufferResourceType.fMemoryPreferredNotHeapFlags;
     ResourcePhysicalBufferData.fBufferFlags:=BufferResourceType.fBufferFlags;
    end else begin
     raise EpvFrameGraph.Create('Invalid resource type');
    end;
   end;
  end;
 end;
 procedure ConstructResourceLayoutTransitionHistory;
 var Pass:TPass;
     Resource:TResource;
     ResourceTransition:TResourceTransition;
 begin
  for Resource in fResources do begin
   if Resource.fResourceType is TImageResourceType then begin
    Resource.fLayoutHistory[Low(TResource.TLayoutHistory.TKey)]:=VK_IMAGE_LAYOUT_UNDEFINED;
    if TImageResourceType(Resource.fResourceType).fImageType=TImageType.Surface then begin
     Resource.fLayoutHistory[High(TResource.TLayoutHistory.TKey)]:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
    end;
   end;
  end;
  for Pass in fTopologicalSortedPasses do begin
   for ResourceTransition in Pass.fResourceTransitions do begin
    if ResourceTransition.Kind in TResourceTransition.AllImages then begin
     Resource:=ResourceTransition.fResource;
     if Resource.fResourceType is TImageResourceType then begin
      Resource.fLayoutHistory[Pass.fTopologicalSortIndex]:=ResourceTransition.fLayout;
     end;
    end;
   end;
  end;
 end;
 procedure CreatePhysicalPassPipelineBarriersAndPhysicalRenderPassSubpassDependenciesAndExplicitPassDependencies;
  procedure AddSubpassDependency(var aSubpassDependencies:TPhysicalRenderPass.TSubpassDependencies;
                                 const aSubpassDependency:TPhysicalRenderPass.TSubpassDependency);
  var Index:TpvSizeInt;
      SubpassDependency:TPhysicalRenderPass.PSubpassDependency;
  begin
   SubpassDependency:=nil;
   for Index:=0 to aSubpassDependencies.Count-1 do begin
    if (aSubpassDependencies.Items[Index].SrcSubpass=aSubpassDependency.SrcSubpass) and
       (aSubpassDependencies.Items[Index].DstSubpass=aSubpassDependency.DstSubpass) then begin
     SubpassDependency:=@aSubpassDependencies.Items[Index];
    end;
   end;
   if assigned(SubpassDependency) then begin
    SubpassDependency^.SrcStageMask:=SubpassDependency^.SrcStageMask or aSubpassDependency.SrcStageMask;
    SubpassDependency^.DstStageMask:=SubpassDependency^.DstStageMask or aSubpassDependency.DstStageMask;
    SubpassDependency^.SrcAccessMask:=SubpassDependency^.SrcAccessMask or aSubpassDependency.SrcAccessMask;
    SubpassDependency^.DstAccessMask:=SubpassDependency^.DstAccessMask or aSubpassDependency.DstAccessMask;
    SubpassDependency^.DependencyFlags:=SubpassDependency^.DependencyFlags or aSubpassDependency.DependencyFlags;
   end else begin
    aSubpassDependencies.Add(aSubpassDependency);
   end;
  end;
  procedure AddSemaphoreSignalWait(const aSignallingCommandBuffer:TQueue.TCommandBuffer;
                                   const aWaitingCommandBuffer:TQueue.TCommandBuffer;
                                   const aDstStageMask:TVkPipelineStageFlags);
  var WaitingSemaphoreIndex:TpvSizeInt;
      WaitingSemaphore:TQueue.TCommandBuffer.PWaitingSemaphore;
  begin
   WaitingSemaphore:=nil;
   for WaitingSemaphoreIndex:=0 to aWaitingCommandBuffer.fWaitingSemaphores.Count-1 do begin
    if aWaitingCommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex].SignallingCommandBuffer=aSignallingCommandBuffer then begin
     WaitingSemaphore:=@aWaitingCommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
     break;
    end;
   end;
   if not assigned(WaitingSemaphore) then begin
    WaitingSemaphoreIndex:=aWaitingCommandBuffer.fWaitingSemaphores.AddNewIndex;
    WaitingSemaphore:=@aWaitingCommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
    WaitingSemaphore^.ExternalWaitingOnSemaphore:=nil;
    WaitingSemaphore^.SignallingCommandBuffer:=aSignallingCommandBuffer;
    WaitingSemaphore^.DstStageMask:=0;
   end;
   WaitingSemaphore^.DstStageMask:=WaitingSemaphore^.DstStageMask or aDstStageMask;
  end;
  procedure AddPipelineBarrier(const aBeforeAfter:TEventBeforeAfter;
                               const aFromPhysicalPass:TPhysicalPass;
                               const aToPhysicalPass:TPhysicalPass;
                               const aResourcePhysicalData:TResourcePhysicalData;
                               const aFromResourceTransition:TResourceTransition;
                               const aToResourceTransition:TResourceTransition;
                               const aSrcQueueFamilyIndex:TVkUInt32;
                               const aDstQueueFamilyIndex:TVkUInt32;
                               const aSrcStageMask:TVkPipelineStageFlags;
                               const aDstStageMask:TVkPipelineStageFlags;
                               const aSrcAccessMask:TVkAccessFlags;
                               const aDstAccessMask:TVkAccessFlags;
                               const aDependencyFlags:TVkDependencyFlags);
  var PipelineBarrierGroupIndex:TpvSizeInt;
      PipelineBarrierGroups:TPhysicalPass.TPipelineBarrierGroups;
      PipelineBarrierGroup,
      FoundPipelineBarrierGroup:TPhysicalPass.TPipelineBarrierGroup;
      BarrierMapItem:TPhysicalPass.TPipelineBarrierGroup.TBarrierMapItem;
      BufferMemoryBarrier:TVkBufferMemoryBarrier;
      ImageMemoryBarrier:TVkImageMemoryBarrier;
      PhysicalPassCrossEvent,CurrentPhysicalPassCrossEvent:TPhysicalPassCrossEvent;
  begin
   case aBeforeAfter of
    TEventBeforeAfter.Event:begin
     PipelineBarrierGroups:=aToPhysicalPass.fEventPipelineBarrierGroups;
    end;
    TEventBeforeAfter.Before:begin
     PipelineBarrierGroups:=aToPhysicalPass.fBeforePipelineBarrierGroups;
    end;
    TEventBeforeAfter.After:begin
     PipelineBarrierGroups:=aToPhysicalPass.fAfterPipelineBarrierGroups;
    end;
    else begin
     PipelineBarrierGroups:=nil;
    end;
   end;
   if not assigned(PipelineBarrierGroups) then begin
    raise EpvFrameGraph.Create('Invalid error 2018-10-06-23-37-0000');
   end;
   FoundPipelineBarrierGroup:=nil;
   for PipelineBarrierGroupIndex:=0 to PipelineBarrierGroups.Count-1 do begin
    PipelineBarrierGroup:=PipelineBarrierGroups[PipelineBarrierGroupIndex];
    if (PipelineBarrierGroup.fSrcStageMask=aSrcStageMask) and
       (PipelineBarrierGroup.fDstStageMask=aDstStageMask) and
       (PipelineBarrierGroup.fDependencyFlags=aDependencyFlags) then begin
     FoundPipelineBarrierGroup:=PipelineBarrierGroup;
     break;
    end;
   end;
   if assigned(FoundPipelineBarrierGroup) then begin
    PipelineBarrierGroup:=FoundPipelineBarrierGroup;
   end else begin
    PipelineBarrierGroup:=TPhysicalPass.TPipelineBarrierGroup.Create(self,
                                                                     aSrcStageMask,
                                                                     aDstStageMask,
                                                                     aDependencyFlags);
    PipelineBarrierGroups.Add(PipelineBarrierGroup);
   end;
   if aBeforeAfter=TEventBeforeAfter.Event then begin
    if assigned(aFromPhysicalPass) and assigned(aToPhysicalPass) then begin
     PhysicalPassCrossEvent:=nil;
     for CurrentPhysicalPassCrossEvent in PipelineBarrierGroup.fPhysicalPassCrossEvents do begin
      if (CurrentPhysicalPassCrossEvent.fFromPhysicalPass=aFromPhysicalPass) and
         (CurrentPhysicalPassCrossEvent.fToPhysicalPass=aToPhysicalPass) then begin
       PhysicalPassCrossEvent:=CurrentPhysicalPassCrossEvent;
       break;
      end;
     end;
     if assigned(PhysicalPassCrossEvent) then begin
      PhysicalPassCrossEvent.fStageMask:=PhysicalPassCrossEvent.fStageMask or aSrcStageMask;
     end else begin
      PhysicalPassCrossEvent:=TPhysicalPassCrossEvent.Create(Self,
                                                             aFromPhysicalPass.fQueue,
                                                             aFromPhysicalPass,
                                                             aToPhysicalPass,
                                                             aSrcStageMask);
      try
       aFromPhysicalPass.fQueue.fPhysicalPassCrossEvents.Add(PhysicalPassCrossEvent);
       aFromPhysicalPass.fOutgoingEvents.Add(PhysicalPassCrossEvent);
       aFromPhysicalPass.fIncomingEvents.Add(PhysicalPassCrossEvent);
       PipelineBarrierGroup.fPhysicalPassCrossEvents.Add(PhysicalPassCrossEvent);
      finally
       fPhysicalPassCrossEvents.Add(PhysicalPassCrossEvent);
      end;
     end;
    end;
   end;
   if aResourcePhysicalData is TResourcePhysicalImageData then begin
    FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
    ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    ImageMemoryBarrier.srcAccessMask:=aSrcAccessMask;
    ImageMemoryBarrier.dstAccessMask:=aDstAccessMask;
    ImageMemoryBarrier.oldLayout:=aFromResourceTransition.fLayout;
    ImageMemoryBarrier.newLayout:=aToResourceTransition.fLayout;
    ImageMemoryBarrier.srcQueueFamilyIndex:=aSrcQueueFamilyIndex;
    ImageMemoryBarrier.dstQueueFamilyIndex:=aDstQueueFamilyIndex;
    ImageMemoryBarrier.image:=0;
    ImageMemoryBarrier.subresourceRange:=TResourcePhysicalImageData(aResourcePhysicalData).fImageSubresourceRange;
    BarrierMapItem.Kind:=TPhysicalPass.TPipelineBarrierGroup.TBarrierMapItemKind.Image;
    BarrierMapItem.BarrierIndex:=PipelineBarrierGroup.fImageMemoryBarrierDynamicArray.Add(ImageMemoryBarrier);
    BarrierMapItem.ImageIndexOffset:=0;
    BarrierMapItem.ResourcePhysicalData:=aResourcePhysicalData;
    PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    if TResourceTransition.TFlag.PreviousFrameInput in (aFromResourceTransition.fFlags+aToResourceTransition.fFlags) then begin
     BarrierMapItem.ImageIndexOffset:=-1;
     //PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    end;
    if TResourceTransition.TFlag.NextFrameOutput in (aFromResourceTransition.fFlags+aToResourceTransition.fFlags) then begin
     BarrierMapItem.ImageIndexOffset:=1;
     //PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    end;
   end else if aResourcePhysicalData is TResourcePhysicalBufferData then begin
    FillChar(BufferMemoryBarrier,SizeOf(TVkBufferMemoryBarrier),#0);
    BufferMemoryBarrier.sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
    BufferMemoryBarrier.srcAccessMask:=aSrcAccessMask;
    BufferMemoryBarrier.dstAccessMask:=aDstAccessMask;
    BufferMemoryBarrier.srcQueueFamilyIndex:=aSrcQueueFamilyIndex;
    BufferMemoryBarrier.dstQueueFamilyIndex:=aDstQueueFamilyIndex;
    BufferMemoryBarrier.buffer:=0;
    case aBeforeAfter of
     TEventBeforeAfter.Event,
     TEventBeforeAfter.Before:begin
      BufferMemoryBarrier.offset:=aFromResourceTransition.fBufferSubresourceRange.Offset;
      BufferMemoryBarrier.size:=aFromResourceTransition.fBufferSubresourceRange.Range;
     end;
     TEventBeforeAfter.After:begin
      BufferMemoryBarrier.offset:=aToResourceTransition.fBufferSubresourceRange.Offset;
      BufferMemoryBarrier.size:=aToResourceTransition.fBufferSubresourceRange.Range;
     end;
    end;
    BarrierMapItem.Kind:=TPhysicalPass.TPipelineBarrierGroup.TBarrierMapItemKind.Buffer;
    BarrierMapItem.BarrierIndex:=PipelineBarrierGroup.fBufferMemoryBarrierDynamicArray.Add(BufferMemoryBarrier);
    BarrierMapItem.ImageIndexOffset:=0;
    BarrierMapItem.ResourcePhysicalData:=aResourcePhysicalData;
    PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    if TResourceTransition.TFlag.PreviousFrameInput in (aFromResourceTransition.fFlags+aToResourceTransition.fFlags) then begin
     BarrierMapItem.ImageIndexOffset:=-1;
     //PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    end;
    if TResourceTransition.TFlag.NextFrameOutput in (aFromResourceTransition.fFlags+aToResourceTransition.fFlags) then begin
     BarrierMapItem.ImageIndexOffset:=1;
     //PipelineBarrierGroup.fBarrierMapItemDynamicArray.Add(BarrierMapItem);
    end;
   end else begin
    Assert(false);
   end;
  end;
 var ResourceTransitionIndex,
     Index:TpvSizeInt;
     ExplicitPassDependency:TExplicitPassDependency;
     Pass,
     OtherPass:TPass;
     ResourceAliasGroup:TResourceAliasGroup;
     Resource:TResource;
     ResourceTransition,
     FromResourceTransition,
     ToResourceTransition:TResourceTransition;
     FromDirections,ToDirections:TDirections;
     SubpassDependency:TPhysicalRenderPass.TSubpassDependency;
     SrcQueueFamilyIndex,
     DstQueueFamilyIndex:TVkUInt32;
     PhyiscalPass:TPhysicalPass;
     RealTransition,
     NeedBarriers,
     NeedSemaphore:boolean;
     Queue:TQueue;
 begin

  for ResourceAliasGroup in fResourceAliasGroups do begin
   ResourceAliasGroup.fLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
   ResourceAliasGroup.fLastTransition:=nil;
  end;

  for Pass in fTopologicalSortedPasses do begin

   if (TPass.TFlag.Used in Pass.fFlags) and
      assigned(Pass.fPhysicalPass) then begin

    // First to try add the external Subpass dependencies
    if Pass.fPhysicalPass is TPhysicalRenderPass then begin
     for ResourceTransitionIndex:=0 to Pass.fResourceTransitions.Count-1 do begin
      ResourceTransition:=Pass.fResourceTransitions[ResourceTransitionIndex];
      Assert(ResourceTransition.Pass=Pass);
      Resource:=ResourceTransition.Resource;
      if (ResourceTransition.fKind in TResourceTransition.AllImages) and
         (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) and
         ((assigned(ResourceTransition.fResource.fResourceType) and
           (ResourceTransition.fResource.fResourceType is TImageResourceType) and
           (TImageResourceType(ResourceTransition.fResource.fResourceType).fImageType=TImageType.Surface)) or
          (assigned(ResourceTransition.fResolveSourceResource) and
           (assigned(ResourceTransition.fResolveSourceResource.fResourceType) and
            (ResourceTransition.fResolveSourceResource.fResourceType is TImageResourceType) and
            (TImageResourceType(ResourceTransition.fResolveSourceResource.fResourceType).fImageType=TImageType.Surface)))) and
          (TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpasses.Count>0) and
         (not TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fHasSurfaceSubpassDependencies) then begin
       TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fHasSurfaceSubpassDependencies:=true;
       begin
        SubpassDependency.SrcSubpass:=nil;
        SubpassDependency.DstSubpass:=TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpasses[0];
        SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
        SubpassDependency.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
        SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
        SubpassDependency.DstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
        SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);
        AddSubpassDependency(TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,SubpassDependency);
       end;
       begin
        SubpassDependency.SrcSubpass:=TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpasses[TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpasses.Count-1];
        SubpassDependency.DstSubpass:=nil;
        SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
        SubpassDependency.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
        SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
        SubpassDependency.DstAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
        SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);
        AddSubpassDependency(TPhysicalRenderPass(ResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,SubpassDependency);
       end;
      end;
     end;
    end;

    // Then add the remaining Subpass dependencies
    for ResourceTransitionIndex:=0 to Pass.fResourceTransitions.Count-1 do begin

     ResourceTransition:=Pass.fResourceTransitions[ResourceTransitionIndex];

     Assert(ResourceTransition.Pass=Pass);

     Resource:=ResourceTransition.Resource;

     FromResourceTransition:=Resource.ResourceAliasGroup.fLastTransition;

     ToResourceTransition:=ResourceTransition;

     if assigned(FromResourceTransition) and
        assigned(ToResourceTransition) and
        (FromResourceTransition<>ToResourceTransition) and
        (FromResourceTransition.fKind in TResourceTransition.AllInputsOutputs) and
        (ToResourceTransition.fKind in TResourceTransition.AllInputsOutputs) and
        (TPass.TFlag.Used in FromResourceTransition.fPass.fFlags) and
        (TPass.TFlag.Used in ToResourceTransition.fPass.fFlags) and
        assigned(FromResourceTransition.fPass.fPhysicalPass) and
        assigned(ToResourceTransition.fPass.fPhysicalPass) then begin

      if ToResourceTransition.fPass.fName='DepthOfFieldResolveRenderPass' then begin
       FromDirections:=GetDirections(FromResourceTransition);
      end;

      FromDirections:=GetDirections(FromResourceTransition);

      ToDirections:=GetDirections(ToResourceTransition);

      SubpassDependency.DependencyFlags:=0;

      SubpassDependency.SrcStageMask:=GetPipelineStageMask(FromResourceTransition);
      SubpassDependency.SrcAccessMask:=GetAccessMask(FromResourceTransition,FromDirections);

      SubpassDependency.DstStageMask:=GetPipelineStageMask(ToResourceTransition);
      SubpassDependency.DstAccessMask:=GetAccessMask(ToResourceTransition,ToDirections);

      if FromResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex<>ToResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex then begin
       SrcQueueFamilyIndex:=FromResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex;
       DstQueueFamilyIndex:=ToResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex;
      end else begin
       SrcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
       DstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
      end;

      RealTransition:=(SrcQueueFamilyIndex<>DstQueueFamilyIndex) or
                      (SubpassDependency.SrcAccessMask<>SubpassDependency.DstAccessMask) or
                      (SubpassDependency.SrcStageMask<>SubpassDependency.DstStageMask) or
                      (FromResourceTransition.Layout<>ToResourceTransition.Layout);

      if (

          // Output => Input
          ((FromResourceTransition.fKind in TResourceTransition.AllOutputs) and
           (ToResourceTransition.fKind in TResourceTransition.AllInputs)) or

          // Input => Input
          ((FromResourceTransition.fKind in TResourceTransition.AllInputs) and
           (ToResourceTransition.fKind in TResourceTransition.AllInputs)) or

          // Input => Output
          ((FromResourceTransition.fKind in TResourceTransition.AllInputs) and
           (ToResourceTransition.fKind in TResourceTransition.AllOutputs)) or

          // Output => Output
          ((FromResourceTransition.fKind in TResourceTransition.AllOutputs) and
           (ToResourceTransition.fKind in TResourceTransition.AllOutputs))

         ) and not
         (
          ((TResourceTransition.TFlag.PreviousFrameInput in FromResourceTransition.Flags) and not
           (TResourceTransition.TFlag.PreviousFrameInput in ToResourceTransition.Flags))
         ) then begin

       if (FromResourceTransition.fPass is TRenderPass) and
          (ToResourceTransition.fPass is TRenderPass) and
          (FromResourceTransition.fPass.fPhysicalPass is TPhysicalRenderPass) and
          (ToResourceTransition.fPass.fPhysicalPass is TPhysicalRenderPass) and
          (FromResourceTransition.fKind in TResourceTransition.AllImages) and
          (ToResourceTransition.fKind in TResourceTransition.AllImages) and
          (TResourceTransition.TFlag.Attachment in FromResourceTransition.fFlags) and
          (TResourceTransition.TFlag.Attachment in ToResourceTransition.fFlags) then begin

        // Both passes are render passes and both resource transitions are for image attachments

        SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);

        if FromResourceTransition.fPass.fPhysicalPass=ToResourceTransition.fPass.fPhysicalPass then begin

         // Same physical render pass

         SubpassDependency.SrcSubpass:=TRenderPass(FromResourceTransition.fPass).fPhysicalRenderPassSubpass;
         SubpassDependency.DstSubpass:=TRenderPass(ToResourceTransition.fPass).fPhysicalRenderPassSubpass;
         AddSubpassDependency(TPhysicalRenderPass(FromResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,
                              SubpassDependency);

         NeedBarriers:=false;

        end else begin

         // Different physical render passes

         SubpassDependency.SrcSubpass:=TRenderPass(FromResourceTransition.fPass).fPhysicalRenderPassSubpass;
         SubpassDependency.DstSubpass:=nil;
         AddSubpassDependency(TPhysicalRenderPass(FromResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,
                              SubpassDependency);

         SubpassDependency.SrcSubpass:=nil;
         SubpassDependency.DstSubpass:=TRenderPass(ToResourceTransition.fPass).fPhysicalRenderPassSubpass;
         AddSubpassDependency(TPhysicalRenderPass(ToResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,
                              SubpassDependency);

         NeedBarriers:=true;

        end;

       end else begin

        // Whether not both passes or none of the both passes are render passes, or any of the both resource
        // transitions are not for a image attachment

        if (FromResourceTransition.fPass is TRenderPass) and
           (FromResourceTransition.fPass.fPhysicalPass is TPhysicalRenderPass) and
           (FromResourceTransition.fKind in TResourceTransition.AllImageOutputs) and
           (TResourceTransition.TFlag.Attachment in FromResourceTransition.fFlags) then begin
         SubpassDependency.SrcSubpass:=TRenderPass(FromResourceTransition.fPass).fPhysicalRenderPassSubpass;
         SubpassDependency.DstSubpass:=nil;
         SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);
         AddSubpassDependency(TPhysicalRenderPass(FromResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,
                              SubpassDependency);
        end;

        if (ToResourceTransition.fPass is TRenderPass) and
           (ToResourceTransition.fPass.fPhysicalPass is TPhysicalRenderPass) and
           (ToResourceTransition.fKind in TResourceTransition.AllImageInputs) and
           (TResourceTransition.TFlag.Attachment in ToResourceTransition.fFlags) then begin
         SubpassDependency.SrcSubpass:=nil;
         SubpassDependency.DstSubpass:=TRenderPass(ToResourceTransition.fPass).fPhysicalRenderPassSubpass;
         SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);
         AddSubpassDependency(TPhysicalRenderPass(ToResourceTransition.fPass.fPhysicalPass).fSubpassDependencies,
                              SubpassDependency);
        end;

        SubpassDependency.DependencyFlags:=0;

        NeedBarriers:=true;

       end;

       if NeedBarriers then begin

        if FromResourceTransition.fPass.fPhysicalPass.fQueueCommandBuffer=ToResourceTransition.fPass.fPhysicalPass.fQueueCommandBuffer then begin

         // Same command buffer (which also means: same queue and same queue family)

         AddPipelineBarrier(TEventBeforeAfter.Before,
                            nil,
                            ToResourceTransition.fPass.fPhysicalPass,
                            Resource.fResourceAliasGroup.fResourcePhysicalData,
                            FromResourceTransition,
                            ToResourceTransition,
                            SrcQueueFamilyIndex,
                            DstQueueFamilyIndex,
                            SubpassDependency.SrcStageMask,
                            SubpassDependency.DstStageMask,
                            SubpassDependency.SrcAccessMask,
                            SubpassDependency.DstAccessMask,
                            SubpassDependency.DependencyFlags
                           );

         // No semaphores and no events are needed in this case, because we are in the same command buffer

        end else begin

         // Different command buffers

         if FromResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex=ToResourceTransition.fPass.fQueue.fPhysicalQueue.QueueFamilyIndex then begin

          // Same queue family

          if FromResourceTransition.fPass.fQueue.fPhysicalQueue=ToResourceTransition.fPass.fQueue.fPhysicalQueue then begin

           // Same queue => Use events

           AddPipelineBarrier(TEventBeforeAfter.Event,
                              FromResourceTransition.fPass.fPhysicalPass,
                              ToResourceTransition.fPass.fPhysicalPass,
                              Resource.fResourceAliasGroup.fResourcePhysicalData,
                              FromResourceTransition,
                              ToResourceTransition,
                              SrcQueueFamilyIndex,
                              DstQueueFamilyIndex,
                              SubpassDependency.SrcStageMask,
                              SubpassDependency.DstStageMask,
                              SubpassDependency.SrcAccessMask,
                              SubpassDependency.DstAccessMask,
                              SubpassDependency.DependencyFlags
                             );

           NeedSemaphore:=false;

          end else begin

           // Different queues

           AddPipelineBarrier(TEventBeforeAfter.Before,
                              nil,
                              ToResourceTransition.fPass.fPhysicalPass,
                              Resource.fResourceAliasGroup.fResourcePhysicalData,
                              FromResourceTransition,
                              ToResourceTransition,
                              SrcQueueFamilyIndex,
                              DstQueueFamilyIndex,
                              SubpassDependency.SrcStageMask,
                              SubpassDependency.DstStageMask,
                              SubpassDependency.SrcAccessMask,
                              SubpassDependency.DstAccessMask,
                              SubpassDependency.DependencyFlags
                             );

           NeedSemaphore:=true;

          end;

         end else begin

          // Different queue families (and different queues, of course)

          // Release
          AddPipelineBarrier(TEventBeforeAfter.After,
                             nil,
                             FromResourceTransition.fPass.fPhysicalPass,
                             Resource.fResourceAliasGroup.fResourcePhysicalData,
                             FromResourceTransition,
                             ToResourceTransition,
                             SrcQueueFamilyIndex,
                             DstQueueFamilyIndex,
                             SubpassDependency.SrcStageMask,
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                             SubpassDependency.SrcAccessMask,
                             0,
                             SubpassDependency.DependencyFlags
                            );

          // Acquire
          AddPipelineBarrier(TEventBeforeAfter.Before,
                             nil,
                             ToResourceTransition.fPass.fPhysicalPass,
                             Resource.fResourceAliasGroup.fResourcePhysicalData,
                             FromResourceTransition,
                             ToResourceTransition,
                             SrcQueueFamilyIndex,
                             DstQueueFamilyIndex,
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                             SubpassDependency.DstStageMask,
                             0,
                             SubpassDependency.DstAccessMask,
                             SubpassDependency.DependencyFlags
                            );

          NeedSemaphore:=true;

         end;

         if NeedSemaphore then begin

          // Add a semaphore
          AddSemaphoreSignalWait(FromResourceTransition.fPass.fPhysicalPass.fQueueCommandBuffer, // Signalling / After
                                 ToResourceTransition.fPass.fPhysicalPass.fQueueCommandBuffer, // Waiting / Before
                                 SubpassDependency.DstStageMask
                                );

         end;

        end;

       end;

      end;

     end else begin

      if assigned(FromResourceTransition) then begin
       raise EpvFrameGraph.Create('Internal error 2021-11-04-10-55-0000');
      end else begin

       if (Resource.ResourceAliasGroup.fLayout=VK_IMAGE_LAYOUT_UNDEFINED) and
          (ToResourceTransition.Kind in TResourceTransition.AllImages) then begin

        if (Pass.fPhysicalPass is TPhysicalRenderPass) and
           (TPhysicalRenderPass(Pass.fPhysicalPass).fSubpasses.Count>0) then begin

         // To avoid Write-After-Write hazards on first usages of resources, we
         // require memory dependencices, because the previously image contents are
         // explicitly not preserved by nature of transitioning from UNDEFINED, so
         // we still need a memory dependency to ensure writes to the image are not
         // reordered.

         SubpassDependency.SrcSubpass:=nil; // EXTERNAL

         SubpassDependency.DstSubpass:=TPhysicalRenderPass(Pass.fPhysicalPass).fSubpasses[TRenderPass(Pass).GetVulkanRenderPassSubpassIndex];

         // Complete all graphics stages before making the memory barrier, but don't block any other previous
         // stuff from running, so set srcStageMask to VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, and
         // VK_ACCESS_MEMORY_READ_BIT as access mask, since the presentation engine uses this access mask.
         SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
         SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);

         SubpassDependency.DstStageMask:=GetPipelineStageMask(ToResourceTransition);
         SubpassDependency.DstAccessMask:=GetAccessMask(ToResourceTransition,[TDirection.Input,TDirection.Output]);

         SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);

         AddSubpassDependency(TPhysicalRenderPass(Pass.fPhysicalPass).fSubpassDependencies,SubpassDependency);

        end;

       end;

      end;

     end;

     Resource.ResourceAliasGroup.fLastTransition:=ResourceTransition;
     Resource.ResourceAliasGroup.fLayout:=ResourceTransition.Layout;

    end;

    // Then add the explicit pass dependencies
    for ExplicitPassDependency in Pass.fExplicitPassDependencies do begin

     OtherPass:=ExplicitPassDependency.fPass;

     if (Pass<>OtherPass) and
        (TPass.TFlag.Used in Pass.fFlags) and
        (TPass.TFlag.Used in OtherPass.fFlags) then begin

      if Pass.fPhysicalPass=OtherPass.fPhysicalPass then begin

       PhyiscalPass:=Pass.fPhysicalPass;

       if (Pass is TRenderPass) and
          (OtherPass is TRenderPass) and
          (PhyiscalPass is TPhysicalRenderPass) and
          (TPhysicalRenderPass(PhyiscalPass).fSubpasses.Count>0) then begin

        if TRenderPass(Pass).VulkanRenderPassSubpassIndex<TRenderPass(OtherPass).VulkanRenderPassSubpassIndex then begin
         SubpassDependency.SrcSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[TRenderPass(Pass).VulkanRenderPassSubpassIndex];
         SubpassDependency.DstSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[TRenderPass(OtherPass).VulkanRenderPassSubpassIndex];
        end else begin
         SubpassDependency.SrcSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[TRenderPass(OtherPass).VulkanRenderPassSubpassIndex];
         SubpassDependency.DstSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[TRenderPass(Pass).VulkanRenderPassSubpassIndex];
        end;

        SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

        SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                         TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

        SubpassDependency.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
        SubpassDependency.DstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                         TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

        SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);

        AddSubpassDependency(TPhysicalRenderPass(PhyiscalPass).fSubpassDependencies,SubpassDependency);

       end;

      end else begin

       for Index:=0 to 1 do begin

        if Index=0 then begin
         PhyiscalPass:=OtherPass.fPhysicalPass;
        end else begin
         PhyiscalPass:=Pass.fPhysicalPass;
        end;

        if (PhyiscalPass is TPhysicalRenderPass) and
           (TPhysicalRenderPass(PhyiscalPass).fSubpasses.Count>0) then begin
         begin

          SubpassDependency.SrcSubpass:=nil;

          SubpassDependency.DstSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[0];

          SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

          SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                           TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

          SubpassDependency.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

          SubpassDependency.DstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                           TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

          SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);

          AddSubpassDependency(TPhysicalRenderPass(PhyiscalPass).fSubpassDependencies,SubpassDependency);

         end;

         begin

          SubpassDependency.SrcSubpass:=TPhysicalRenderPass(PhyiscalPass).fSubpasses[TPhysicalRenderPass(PhyiscalPass).fSubpasses.Count-1];

          SubpassDependency.DstSubpass:=nil;

          SubpassDependency.SrcStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

          SubpassDependency.SrcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                           TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

          SubpassDependency.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

          SubpassDependency.DstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                           TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);

          SubpassDependency.DependencyFlags:=TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);

          AddSubpassDependency(TPhysicalRenderPass(PhyiscalPass).fSubpassDependencies,SubpassDependency);

         end;

        end;

       end;

      end;

      if Pass.fPhysicalPass.fQueueCommandBuffer=OtherPass.fPhysicalPass.fQueueCommandBuffer then begin
       // TODO: Pipeline barriers and so on?
      end else begin
       // Add a semaphore
       AddSemaphoreSignalWait(OtherPass.fPhysicalPass.fQueueCommandBuffer, // Signalling / After
                              Pass.fPhysicalPass.fQueueCommandBuffer, // Waiting / Before
                              ExplicitPassDependency.fDstStageMask
                             );
      end;

     end;

    end;

   end;

  end;

 end;
 procedure SortPhysicalRenderPassSubpassDependencies;
 var PhysicalPass:TPhysicalPass;
     PhysicalRenderPass:TPhysicalRenderPass;
 begin
  for PhysicalPass in fPhysicalPasses do begin
   if PhysicalPass is TPhysicalRenderPass then begin
    PhysicalRenderPass:=TPhysicalRenderPass(PhysicalPass);
    if PhysicalRenderPass.fSubpassDependencies.Count>1 then begin
     TpvTypedSort<TPhysicalRenderPass.TSubpassDependency>.IntroSort(@PhysicalRenderPass.fSubpassDependencies.Items[0],
                                                                    0,
                                                                    PhysicalRenderPass.fSubpassDependencies.Count-1,
                                                                    ComparePhysicalRenderPassSubpassDependencies);
    end;
   end;
  end;
 end;
 procedure CreatePhysicalRenderPasses;
  function AddAttachmentReference(const aPhysicalRenderPass:TPhysicalRenderPass;
                                  const aAttachmentIndex:TVkUInt32;
                                  const aLayout:TVkImageLayout):TVkUInt32;
  begin
   result:=aPhysicalRenderPass.fAttachmentReferences.Add(TVkAttachmentReference.Create(aAttachmentIndex,aLayout));
  end;
 var AttachmentIndex,
     OtherAttachmentIndex,
     SubpassIndex,
     PassIndex:TpvSizeInt;
     PhysicalPass:TPhysicalPass;
     PhysicalRenderPass:TPhysicalRenderPass;
     Subpass:TPhysicalRenderPass.TSubpass;
     OtherPass:TPass;
     RenderPass:TRenderPass;
     ResourceTransition,
     OtherResourceTransition:TResourceTransition;
     ResourceType:TResourceType;
     ImageResourceType:TImageResourceType;
     Resource:TResource;
     Attachment:TPhysicalRenderPass.PAttachment;
     Found,
     HasResolveOutputs,
     UsedNow,
     UsedBefore,
     UsedAfter,
     IsSurfaceOrPersistent:boolean;
 begin
  for PhysicalPass in fPhysicalPasses do begin

   if PhysicalPass is TPhysicalRenderPass then begin

    PhysicalRenderPass:=TPhysicalRenderPass(PhysicalPass);

    PhysicalRenderPass.fAttachments.Clear;
    PhysicalRenderPass.fAttachmentReferences.Clear;
    try

     for Subpass in PhysicalRenderPass.fSubpasses do begin
      RenderPass:=Subpass.fRenderPass;
      for ResourceTransition in RenderPass.fResourceTransitions do begin
       ResourceType:=ResourceTransition.fResource.fResourceType;
       if (ResourceTransition.Kind in TResourceTransition.AllImages) and
          (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
        Assert(ResourceType is TImageResourceType);
        Found:=false;
        for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
         Attachment:=@PhysicalRenderPass.fAttachments.Items[AttachmentIndex];
         if Attachment^.Resource=ResourceTransition.fResource then begin
          Found:=true;
          break;
         end;
        end;
        if not Found then begin
         ImageResourceType:=ResourceType as TImageResourceType;
         AttachmentIndex:=PhysicalRenderPass.fAttachments.AddNewIndex;
         Attachment:=@PhysicalRenderPass.fAttachments.Items[AttachmentIndex];
         Attachment^.Resource:=ResourceTransition.fResource;
         Attachment^.Persistent:=ImageResourceType.fPersistent;
         Attachment^.ImageType:=ImageResourceType.fImageType;
         Attachment^.Format:=ImageResourceType.fFormat;
         Attachment^.Samples:=ImageResourceType.fSamples;
         Attachment^.LoadOp:=VK_ATTACHMENT_LOAD_OP_DONT_CARE;
         Attachment^.StoreOp:=VK_ATTACHMENT_STORE_OP_DONT_CARE;
         Attachment^.StencilLoadOp:=VK_ATTACHMENT_LOAD_OP_DONT_CARE;
         Attachment^.StencilStoreOp:=VK_ATTACHMENT_STORE_OP_DONT_CARE;
         if ImageResourceType.fInitialLayout<>VK_IMAGE_LAYOUT_UNDEFINED then begin
          Attachment^.InitialLayout:=ImageResourceType.fInitialLayout;
         end else begin
          Attachment^.InitialLayout:=ResourceTransition.fLayout;
         end;
         if ImageResourceType.fFinalLayout<>VK_IMAGE_LAYOUT_UNDEFINED then begin
          Attachment^.FinalLayout:=ImageResourceType.fFinalLayout;
         end else begin
          Attachment^.FinalLayout:=ResourceTransition.fLayout;
         end;
         Attachment^.ImageUsageFlags:=0;
         Attachment^.ClearValueInitialized:=false;
         Attachment^.HasInitialLayout:=false;
        end;
       end;
      end;
     end;

     for Subpass in PhysicalRenderPass.fSubpasses do begin
      RenderPass:=Subpass.fRenderPass;
      for ResourceTransition in RenderPass.fResourceTransitions do begin
       if TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags then begin
        for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
         Attachment:=@PhysicalRenderPass.fAttachments.Items[AttachmentIndex];
         if Attachment^.Resource=ResourceTransition.fResource then begin
          case ResourceTransition.fLayout of
           VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT);
           end;
           VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT);
           end;
           VK_IMAGE_LAYOUT_PRESENT_SRC_KHR:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_SHADING_RATE_OPTIMAL_NV:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
           VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL:begin
            Attachment^.ImageUsageFlags:=Attachment^.ImageUsageFlags or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
           end;
          end;
          if not Attachment^.HasInitialLayout then begin
           if (Attachment^.LoadOp=VK_ATTACHMENT_LOAD_OP_DONT_CARE) and
              (Attachment^.ImageType in [TImageType.Surface,
                                         TImageType.Color,
                                         TImageType.Depth,
                                         TImageType.DepthStencil]) then begin
            Attachment^.LoadOp:=TLoadOp.Values[ResourceTransition.fLoadOp.Kind];
           end;
           if (Attachment^.StencilLoadOp=VK_ATTACHMENT_LOAD_OP_DONT_CARE) and
              (Attachment^.ImageType in [TImageType.DepthStencil,
                                         TImageType.Stencil]) then begin
            Attachment^.StencilLoadOp:=TLoadOp.Values[ResourceTransition.fLoadOp.Kind];
           end;
           if ResourceTransition.fKind in TResourceTransition.AllOutputs then begin
            if (RenderPass.fTopologicalSortIndex=Attachment^.Resource.fMinimumTopologicalSortPassIndex) or
               (((Attachment^.ImageType in [TImageType.Surface,
                                            TImageType.Color,
                                            TImageType.Depth]) and
                 (Attachment^.LoadOp in [VK_ATTACHMENT_LOAD_OP_CLEAR,
                                         VK_ATTACHMENT_LOAD_OP_DONT_CARE])) or
                ((Attachment^.ImageType in [TImageType.DepthStencil,
                                            TImageType.Stencil]) and
                 ((Attachment^.ImageType=TImageType.Stencil) or
                  (Attachment^.LoadOp in [VK_ATTACHMENT_LOAD_OP_CLEAR,
                                          VK_ATTACHMENT_LOAD_OP_DONT_CARE])) and
                 (Attachment^.StencilLoadOp in [VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                VK_ATTACHMENT_LOAD_OP_DONT_CARE]))) then begin
             Attachment^.HasInitialLayout:=true;
             Attachment^.InitialLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
            end else if Attachment^.InitialLayout=VK_IMAGE_LAYOUT_UNDEFINED then begin
             Attachment^.HasInitialLayout:=true;
             if assigned(Attachment^.Resource.ResourceType) and
                (Attachment^.Resource.ResourceType is TImageResourceType) and
                (TImageResourceType(Attachment^.Resource.ResourceType).fInitialLayout<>VK_IMAGE_LAYOUT_UNDEFINED) then begin
              Attachment^.InitialLayout:=TImageResourceType(Attachment^.Resource.ResourceType).fInitialLayout;
             end else begin
              Attachment^.InitialLayout:=ResourceTransition.fLayout;
             end;
            end;
           end;
          end;
          if (ResourceTransition.fKind in TResourceTransition.AllOutputs) and
             (Attachment^.ImageType in [TImageType.Surface]) and
             fSurfaceIsSwapchain{and
             ((RenderPass.fTopologicalSortIndex=Attachment^.Resource.fMaximumTopologicalSortPassIndex) or
              (fRootPass=RenderPass))} then begin
           Attachment^.FinalLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
          end else begin
           if assigned(Attachment^.Resource.ResourceType) and
              (Attachment^.Resource.ResourceType is TImageResourceType) and
              (TImageResourceType(Attachment^.Resource.ResourceType).fFinalLayout<>VK_IMAGE_LAYOUT_UNDEFINED) then begin
            Attachment^.FinalLayout:=TImageResourceType(Attachment^.Resource.ResourceType).fFinalLayout;
           end else begin
            Attachment^.FinalLayout:=ResourceTransition.fLayout;
           end;
          end;
          if not Attachment^.ClearValueInitialized then begin
           Attachment^.ClearValueInitialized:=true;
           if Attachment^.ImageType in [TImageType.DepthStencil,TImageType.Stencil,TImageType.Depth] then begin
            Attachment^.ClearValue.depthStencil.depth:=ResourceTransition.fLoadOp.ClearColor[0];
            Attachment^.ClearValue.depthStencil.stencil:=trunc(ResourceTransition.fLoadOp.ClearColor[1]);
           end else begin
            Attachment^.ClearValue.color.float32[0]:=ResourceTransition.fLoadOp.ClearColor[0];
            Attachment^.ClearValue.color.float32[1]:=ResourceTransition.fLoadOp.ClearColor[1];
            Attachment^.ClearValue.color.float32[2]:=ResourceTransition.fLoadOp.ClearColor[2];
            Attachment^.ClearValue.color.float32[3]:=ResourceTransition.fLoadOp.ClearColor[3];
           end;
          end;
          break;
         end;
        end;
       end;
      end;
     end;

     for SubpassIndex:=0 to PhysicalRenderPass.fSubpasses.Count-1 do begin

      Subpass:=PhysicalRenderPass.fSubpasses[SubpassIndex];

      RenderPass:=Subpass.fRenderPass;

      Subpass.fInputAttachments.Clear;
      Subpass.fColorAttachments.Clear;
      Subpass.fResolveAttachments.Clear;
      Subpass.fPreserveAttachments.Clear;
      Subpass.fDepthStencilAttachment:=-1;

      HasResolveOutputs:=false;
      for ResourceTransition in RenderPass.fResourceTransitions do begin
       if (ResourceTransition.fKind=TResourceTransition.TKind.ImageResolveOutput) and
          (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
        HasResolveOutputs:=true;
        break;
       end;
      end;

      for ResourceTransition in RenderPass.fResourceTransitions do begin
       if TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags then begin
        case ResourceTransition.fKind of
         TResourceTransition.TKind.ImageInput:begin
          for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
           if PhysicalRenderPass.fAttachments.Items[AttachmentIndex].Resource=ResourceTransition.fResource then begin
            case ResourceTransition.Layout of
             VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
             VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
             VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL,
             VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL,
             VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL:begin
              if TResourceTransition.TFlag.ExplicitOutputAttachment in ResourceTransition.fFlags then begin
               Subpass.fColorAttachments.Add(AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout));
               for OtherResourceTransition in RenderPass.fResourceTransitions do begin
                if (ResourceTransition<>OtherResourceTransition) and
                   (OtherResourceTransition.fResolveSourceResource=ResourceTransition.fResource) then begin
                 Found:=false;
                 for OtherAttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
                  if PhysicalRenderPass.fAttachments.Items[OtherAttachmentIndex].Resource=OtherResourceTransition.fResource then begin
                   Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,OtherAttachmentIndex,OtherResourceTransition.fLayout));
                   Found:=true;
                   break;
                  end;
                 end;
                 if not Found then begin
                  Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,VK_ATTACHMENT_UNUSED,VK_IMAGE_LAYOUT_UNDEFINED));
                 end;
                 break;
                end;
               end;
               break;
              end else begin
               Subpass.fInputAttachments.Add(AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout));
              end;
             end;
             else begin
              if TResourceTransition.TFlag.ExplicitInputAttachment in ResourceTransition.fFlags then begin
               Subpass.fInputAttachments.Add(AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout));
              end else begin
               Subpass.fColorAttachments.Add(AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout));
               for OtherResourceTransition in RenderPass.fResourceTransitions do begin
                if (ResourceTransition<>OtherResourceTransition) and
                   (OtherResourceTransition.fResolveSourceResource=ResourceTransition.fResource) then begin
                 Found:=false;
                 for OtherAttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
                  if PhysicalRenderPass.fAttachments.Items[OtherAttachmentIndex].Resource=OtherResourceTransition.fResource then begin
                   Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,OtherAttachmentIndex,OtherResourceTransition.fLayout));
                   Found:=true;
                   break;
                  end;
                 end;
                 if not Found then begin
                  Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,VK_ATTACHMENT_UNUSED,VK_IMAGE_LAYOUT_UNDEFINED));
                 end;
                 break;
                end;
               end;
               break;
              end;
             end;
            end;
            break;
           end;
          end;
         end;
         TResourceTransition.TKind.ImageOutput:begin
          for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
           if PhysicalRenderPass.fAttachments.Items[AttachmentIndex].Resource=ResourceTransition.fResource then begin
            Subpass.fColorAttachments.Add(AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout));
            for OtherResourceTransition in RenderPass.fResourceTransitions do begin
             if (ResourceTransition<>OtherResourceTransition) and
                (OtherResourceTransition.fResolveSourceResource=ResourceTransition.fResource) then begin
              Found:=false;
              for OtherAttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
               if PhysicalRenderPass.fAttachments.Items[OtherAttachmentIndex].Resource=OtherResourceTransition.fResource then begin
                Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,OtherAttachmentIndex,OtherResourceTransition.fLayout));
                Found:=true;
                break;
               end;
              end;
              if not Found then begin
               Subpass.fResolveAttachments.Add(AddAttachmentReference(PhysicalRenderPass,VK_ATTACHMENT_UNUSED,VK_IMAGE_LAYOUT_UNDEFINED));
              end;
              break;
             end;
            end;
            break;
           end;
          end;
         end;
         TResourceTransition.TKind.ImageDepthInput:begin
          if Subpass.fDepthStencilAttachment<0 then begin
           for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
            if PhysicalRenderPass.fAttachments.Items[AttachmentIndex].Resource=ResourceTransition.fResource then begin
             Subpass.fDepthStencilAttachment:=AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout);
             case ResourceTransition.Layout of
              VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
              VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
              VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL,
              VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL,
              VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL:begin
               if not (TResourceTransition.TFlag.ExplicitOutputAttachment in ResourceTransition.fFlags) then begin
                Subpass.fInputAttachments.Add(Subpass.fDepthStencilAttachment);
               end;
              end;
              else begin
               if TResourceTransition.TFlag.ExplicitInputAttachment in ResourceTransition.fFlags then begin
                Subpass.fInputAttachments.Add(Subpass.fDepthStencilAttachment);
               end;
              end;
             end;
             break;
            end;
           end;
          end;
         end;
         TResourceTransition.TKind.ImageDepthOutput:begin
          if Subpass.fDepthStencilAttachment<0 then begin
           for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
            if PhysicalRenderPass.fAttachments.Items[AttachmentIndex].Resource=ResourceTransition.fResource then begin
             Subpass.fDepthStencilAttachment:=AddAttachmentReference(PhysicalRenderPass,AttachmentIndex,ResourceTransition.fLayout);
             break;
            end;
           end;
          end;
         end;
         else begin
         end;
        end;
       end;
      end;

      for AttachmentIndex:=0 to PhysicalRenderPass.fAttachments.Count-1 do begin
       Attachment:=@PhysicalRenderPass.fAttachments.Items[AttachmentIndex];
       Resource:=Attachment^.Resource;
       if PhysicalRenderPass.fFinalLayouts.ExistKey(Resource) then begin
        Attachment^.FinalLayout:=PhysicalRenderPass.fFinalLayouts[Resource];
       end;
       UsedNow:=false;
       for ResourceTransition in Subpass.fRenderPass.fResourceTransitions do begin
        if (ResourceTransition.Resource=Resource) and
           (TResourceTransition.TFlag.Attachment in ResourceTransition.fFlags) then begin
         UsedNow:=true;
         break;
        end;
       end;
       UsedBefore:=Resource.fMinimumTopologicalSortPassIndex<Subpass.fRenderPass.fTopologicalSortIndex;
       UsedAfter:=Subpass.fRenderPass.fTopologicalSortIndex<Resource.fMaximumTopologicalSortPassIndex;
       IsSurfaceOrPersistent:=(Attachment^.ImageType=TImageType.Surface) or Attachment^.Persistent;
       if UsedBefore and (not UsedNow) and (UsedAfter or IsSurfaceOrPersistent) then begin
        Subpass.fPreserveAttachments.Add(AttachmentIndex);
       end;
       if (SubpassIndex>=0) and (UsedAfter or isSurfaceOrPersistent) then begin
        case Attachment^.ImageType of
         TImageType.Surface,TImageType.Color,TImageType.Depth:begin
          Attachment^.StoreOp:=VK_ATTACHMENT_STORE_OP_STORE;
         end;
         TImageType.DepthStencil:begin
          Attachment^.StoreOp:=VK_ATTACHMENT_STORE_OP_STORE;
          Attachment^.StencilStoreOp:=VK_ATTACHMENT_STORE_OP_STORE;
         end;
         TImageType.Stencil:begin
          Attachment^.StencilStoreOp:=VK_ATTACHMENT_STORE_OP_STORE;
         end;
        end;
       end;
      end;

      Subpass.fInputAttachments.Finish;
      Subpass.fColorAttachments.Finish;
      Subpass.fResolveAttachments.Finish;
      Subpass.fPreserveAttachments.Finish;

      if Subpass.fDepthStencilAttachment<0 then begin
       Subpass.fDepthStencilAttachment:=VK_ATTACHMENT_UNUSED;
      end;

     end;

    finally
     PhysicalRenderPass.fAttachments.Finish;
     PhysicalRenderPass.fAttachmentReferences.Finish;
    end;

   end;

  end;

 end;
 procedure HandleExternalWaitingSemaphores;
 var PhysicalPass:TPhysicalPass;
     ExternalWaitingOnSemaphoreReference:TExternalWaitingOnSemaphoreReference;
     ExternalWaitingOnSemaphore:TExternalWaitingOnSemaphore;
     WaitingSemaphoreIndex:TpvSizeInt;
     WaitingSemaphore:TQueue.TCommandBuffer.PWaitingSemaphore;
 begin
  for PhysicalPass in fPhysicalPasses do begin
   for ExternalWaitingOnSemaphoreReference in PhysicalPass.fExternalWaitingOnSemaphoreReferences do begin
    WaitingSemaphoreIndex:=PhysicalPass.fQueueCommandBuffer.fWaitingSemaphores.AddNewIndex;
    WaitingSemaphore:=@PhysicalPass.fQueueCommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
    WaitingSemaphore^.ExternalWaitingOnSemaphore:=ExternalWaitingOnSemaphoreReference.fExternalWaitingOnSemaphore;
    WaitingSemaphore^.SignallingCommandBuffer:=nil;
    WaitingSemaphore^.DstStageMask:=ExternalWaitingOnSemaphoreReference.fStageMask;
   end;
  end;
 end;
 procedure CreateQueueResetCommandBuffers;
 var Queue:TQueue;
     CommandBuffer:TQueue.TCommandBuffer;
     WaitingSemaphoreIndex:TpvSizeInt;
     WaitingSemaphore:TQueue.TCommandBuffer.PWaitingSemaphore;
 begin
  for Queue in fQueues do begin
   if Queue.fPhysicalPassCrossEvents.Count>0 then begin
    CommandBuffer:=TQueue.TCommandBuffer.Create(Queue);
    try
     CommandBuffer.fMustResetEvents:=true;
     Queue.fCommandBuffers.Add(CommandBuffer);
     fAllQueueCommandBuffers.Add(CommandBuffer);
    finally
     Queue.fResetBuffer:=CommandBuffer;
    end;
    for CommandBuffer in Queue.fCommandBuffers do begin
     if CommandBuffer<>Queue.fResetBuffer then begin
      WaitingSemaphoreIndex:=Queue.fResetBuffer.fWaitingSemaphores.AddNewIndex;
      WaitingSemaphore:=@Queue.fResetBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
      WaitingSemaphore^.ExternalWaitingOnSemaphore:=nil;
      WaitingSemaphore^.SignallingCommandBuffer:=CommandBuffer;
      WaitingSemaphore^.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
     end;
    end;
   end;
  end;
 end;
 procedure CreateQueueCommandBuffersExternalSemaphoreDependencies;
 var Queue:TQueue;
     CommandBuffer:TQueue.TCommandBuffer;
     WaitingSemaphoreIndex:TpvSizeInt;
     WaitingSemaphore:TQueue.TCommandBuffer.PWaitingSemaphore;
 begin
  if fDoWaitOnSemaphore then begin
   for Queue in fQueues do begin
    for CommandBuffer in Queue.fCommandBuffers do begin
     if CommandBuffer.fWaitingSemaphores.Count=0 then begin
      WaitingSemaphoreIndex:=CommandBuffer.fWaitingSemaphores.AddNewIndex;
      WaitingSemaphore:=@CommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
      WaitingSemaphore^.ExternalWaitingOnSemaphore:=nil;
      WaitingSemaphore^.SignallingCommandBuffer:=nil;
      WaitingSemaphore^.DstStageMask:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
     end;
    end;
   end;
  end;
 end;
 procedure FinishQueueCommandBufferSemaphores;
 var Queue:TQueue;
     CommandBuffer:TQueue.TCommandBuffer;
 begin
  for Queue in fQueues do begin
   for CommandBuffer in Queue.fCommandBuffers do begin
    CommandBuffer.fWaitingSemaphores.Finish;
   end;
  end;
 end;
 procedure PrepareQueues;
 var Additional,SubmitInfoIndex:TpvSizeInt;
     Queue:TQueue;
     CommandBuffer:TQueue.TCommandBuffer;
 begin
  for Queue in fQueues do begin
   if Queue=fUniversalQueue then begin
    Additional:=2;
    SubmitInfoIndex:=1;
   end else begin
    Additional:=0;
    SubmitInfoIndex:=0;
   end;
   Queue.fCountSubmitInfos:=Queue.fCommandBuffers.Count+Additional;
   SetLength(Queue.fSubmitInfos,Queue.fCountSubmitInfos);
   for CommandBuffer in Queue.fCommandBuffers do begin
    CommandBuffer.fSubmitInfoIndex:=SubmitInfoIndex;
    inc(SubmitInfoIndex);
   end;
  end;
 end;
 procedure FinishPassUsedResources;
 var Pass:TPass;
     UsedResource:TPass.TUsedResource;
 begin
  for Pass in fPasses do begin
   for UsedResource in Pass.fUsedResources do begin
    UsedResource.Finish;
   end;
  end;
 end;
 procedure CreateTimerQuery;
 var Index:TpvSizeInt;
 begin
  FreeAndNil(fTimerQueries);
  fTimerQueries:=TpvTimerQueries.Create;
  fTimerQueries.OwnsObjects:=true;
  for Index:=0 to fCountInFlightFrames-1 do begin
   fTimerQueries.Add(TpvTimerQuery.Create(fVulkanDevice,Passes.Count));
  end;
 end;
 procedure CreateCPUTimeValues;
 var Index:TpvSizeInt;
 begin
  SetLength(fCPUTimeValues,fPasses.Count+2);
  SetLength(fLastCPUTimeValues,fPasses.Count+2);
  for Index:=0 to fPasses.Count-1 do begin
   fCPUTimeValues[Index]:=0;
   fLastCPUTimeValues[Index]:=0;
  end;
 end;
begin

 fQueueFamilyIndices.Finish;

 fPhysicalPasses.Clear;

 fPhysicalPassCrossEvents.Clear;

 IndexingPasses;

 ResolveExplicitPassDependencies;

 ValidateAttachmentImages;

 ValidateResources;

 FindRootPass;

 CreateDirectedAcyclicGraphOfGraphPasses;

 CreatePhysicalPasses;

 FindRootPhysicalPass;

 TransferDependenciesFromGraphPassesToPhysicalPasses;

 CalculateResourceLifetimes;

 FindTransientResources;

 CreateResourceAliasGroups;

 CreatePhysicalPassQueueSequences;

 CreatePhysicalPassQueueCommandBuffers;

 CreateResourceAliasGroupData;

 ConstructResourceLayoutTransitionHistory;

 CreatePhysicalPassPipelineBarriersAndPhysicalRenderPassSubpassDependenciesAndExplicitPassDependencies;

 SortPhysicalRenderPassSubpassDependencies;

 CreatePhysicalRenderPasses;

 HandleExternalWaitingSemaphores;

 CreateQueueResetCommandBuffers;

 CreateQueueCommandBuffersExternalSemaphoreDependencies;

 FinishQueueCommandBufferSemaphores;

 PrepareQueues;

 FinishPassUsedResources;

 CreateTimerQuery;

 CreateCPUTimeValues;

end;

procedure TpvFrameGraph.AcquirePersistentResources;
var ResourceAliasGroup:TResourceAliasGroup;
    PhysicalPass:TPhysicalPass;
    Queue:TQueue;
begin
 for ResourceAliasGroup in fResourceAliasGroups do begin
  ResourceAliasGroup.AcquirePersistentResources;
 end;
 for PhysicalPass in fPhysicalPasses do begin
  PhysicalPass.AcquirePersistentResources;
 end;
 for Queue in fQueues do begin
  Queue.AcquirePersistentResources;
 end;
end;

procedure TpvFrameGraph.ReleasePersistentResources;
var ResourceAliasGroup:TResourceAliasGroup;
    PhysicalPass:TPhysicalPass;
    Queue:TQueue;
begin
 for Queue in fQueues do begin
  Queue.ReleasePersistentResources;
 end;
 for PhysicalPass in fPhysicalPasses do begin
  PhysicalPass.ReleasePersistentResources;
 end;
 for ResourceAliasGroup in fResourceAliasGroups do begin
  ResourceAliasGroup.ReleasePersistentResources;
 end;
end;

procedure TpvFrameGraph.AcquireVolatileResources;
var InFlightFrameIndex,
    Index,
    WaitingSemaphoreIndex,
    AbsoluteWaitingSemaphoreIndex:TpvSizeInt;
    ResourceAliasGroup:TResourceAliasGroup;
    PhysicalPass:TPhysicalPass;
    CommandBuffer:TQueue.TCommandBuffer;
    SubmitInfo:PVkSubmitInfo;
    WaitingSemaphore:TQueue.TCommandBuffer.PWaitingSemaphore;
    Semaphore:TpvVulkanSemaphore;
    PhysicalPassCrossEvent:TPhysicalPassCrossEvent;
    Queue:TQueue;
begin
 for ResourceAliasGroup in fResourceAliasGroups do begin
  ResourceAliasGroup.AcquireVolatileResources;
 end;
 for PhysicalPassCrossEvent in fPhysicalPassCrossEvents do begin
  PhysicalPassCrossEvent.AcquireVolatileResources;
 end;
 for PhysicalPass in fPhysicalPasses do begin
  PhysicalPass.AcquireVolatileResources;
 end;
 for Queue in fQueues do begin
  Queue.AcquireVolatileResources;
 end;
 for CommandBuffer in fAllQueueCommandBuffers do begin
  CommandBuffer.fWaitingSemaphoreHandles.Clear;
  for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
   CommandBuffer.fSignallingSemaphores[InFlightFrameIndex].Clear;
   CommandBuffer.fSignallingSemaphoreHandles[InFlightFrameIndex].Clear;
  end;
 end;
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  for Index:=0 to fDrawToWaitOnSemaphores[InFlightFrameIndex].Count-1 do begin
   FreeAndNil(fDrawToWaitOnSemaphores[InFlightFrameIndex].Items[Index]);
  end;
  fDrawToWaitOnSemaphores[InFlightFrameIndex].Clear;
  fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Clear;
  fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Clear;
  fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Clear;
 end;
 for CommandBuffer in fAllQueueCommandBuffers do begin
  for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
   for WaitingSemaphoreIndex:=0 to CommandBuffer.fWaitingSemaphores.Count-1 do begin
    WaitingSemaphore:=@CommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
    if assigned(WaitingSemaphore^.ExternalWaitingOnSemaphore) then begin
     Semaphore:=WaitingSemaphore^.ExternalWaitingOnSemaphore.fInFlightFrameSemaphores[InFlightFrameIndex];
    end else begin
     Semaphore:=TpvVulkanSemaphore.Create(fVulkanDevice);
     fVulkanDevice.DebugUtils.SetObjectName(Semaphore.Handle,TVkObjectType.VK_OBJECT_TYPE_SEMAPHORE,'FrameGraphSemaphore');
     if assigned(WaitingSemaphore^.SignallingCommandBuffer) then begin
      WaitingSemaphore^.SignallingCommandBuffer.fSignallingSemaphores[InFlightFrameIndex].Add(Semaphore);
      WaitingSemaphore^.SignallingCommandBuffer.fSignallingSemaphoreHandles[InFlightFrameIndex].Add(Semaphore.Handle);
     end else begin
      fDrawToWaitOnSemaphores[InFlightFrameIndex].Add(Semaphore);
      fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Add(Semaphore.Handle);
     end;
    end;
    CommandBuffer.fWaitingSemaphoreHandles.Add(Semaphore.Handle);
   end;
  end;
  CommandBuffer.fWaitingSemaphoreHandles.Finish;
 end;
 for CommandBuffer in fAllQueueCommandBuffers do begin
  CommandBuffer.fWaitingSemaphoreDstStageMasks.Clear;
  for WaitingSemaphoreIndex:=0 to CommandBuffer.fWaitingSemaphores.Count-1 do begin
   WaitingSemaphore:=@CommandBuffer.fWaitingSemaphores.Items[WaitingSemaphoreIndex];
   CommandBuffer.fWaitingSemaphoreDstStageMasks.Add(WaitingSemaphore^.DstStageMask);
  end;
  CommandBuffer.fWaitingSemaphoreDstStageMasks.Finish;
 end;
 for CommandBuffer in fAllQueueCommandBuffers do begin
  for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
   SubmitInfo:=@CommandBuffer.fSubmitInfos[InFlightFrameIndex];
   FillChar(SubmitInfo^,SizeOf(TVkSubmitInfo),#0);
   SubmitInfo^.sType:=VK_STRUCTURE_TYPE_SUBMIT_INFO;
   SubmitInfo^.pNext:=nil;
   SubmitInfo^.waitSemaphoreCount:=CommandBuffer.fWaitingSemaphores.Count;
   if SubmitInfo^.waitSemaphoreCount>0 then begin
    SubmitInfo^.pWaitSemaphores:=@CommandBuffer.fWaitingSemaphoreHandles.Items[CommandBuffer.fWaitingSemaphores.Count*InFlightFrameIndex];
    SubmitInfo^.pWaitDstStageMask:=@CommandBuffer.fWaitingSemaphoreDstStageMasks.Items[0];
   end;
   SubmitInfo^.commandBufferCount:=1;
   SubmitInfo^.pCommandBuffers:=@CommandBuffer.fCommandBuffers[InFlightFrameIndex].Handle;
   if fDoSignalSemaphore and
      (CommandBuffer=CommandBuffer.fQueue.fCommandBuffers[CommandBuffer.fQueue.fCommandBuffers.Count-1]) then begin
    Semaphore:=TpvVulkanSemaphore.Create(fVulkanDevice);
    fVulkanDevice.DebugUtils.SetObjectName(Semaphore.Handle,TVkObjectType.VK_OBJECT_TYPE_SEMAPHORE,'FrameGraphSemaphore');
    CommandBuffer.fSignallingSemaphores[InFlightFrameIndex].Add(Semaphore);
    CommandBuffer.fSignallingSemaphoreHandles[InFlightFrameIndex].Add(Semaphore.Handle);
    fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Add(Semaphore.Handle);
    fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Add(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT{VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT}));
   end;
   SubmitInfo^.signalSemaphoreCount:=CommandBuffer.fSignallingSemaphoreHandles[InFlightFrameIndex].Count;
   if SubmitInfo^.signalSemaphoreCount>0 then begin
    SubmitInfo^.pSignalSemaphores:=@CommandBuffer.fSignallingSemaphoreHandles[InFlightFrameIndex].Items[0];
   end;
  end;
 end;
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  fDrawToWaitOnSemaphores[InFlightFrameIndex].Finish;
  fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Finish;
  fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Finish;
  fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Finish;
 end;
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  fDrawToWaitSubmitInfos[InFlightFrameIndex].signalSemaphoreCount:=fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Count;
  if fDrawToWaitSubmitInfos[InFlightFrameIndex].signalSemaphoreCount>0 then begin
   fDrawToWaitSubmitInfos[InFlightFrameIndex].pSignalSemaphores:=@fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Items[0];
  end else begin
   fDrawToWaitSubmitInfos[InFlightFrameIndex].pSignalSemaphores:=nil;
  end;
 end;
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  fDrawToSignalSubmitInfos[InFlightFrameIndex].waitSemaphoreCount:=fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Count;
  if fDrawToSignalSubmitInfos[InFlightFrameIndex].waitSemaphoreCount>0 then begin
   fDrawToSignalSubmitInfos[InFlightFrameIndex].pWaitSemaphores:=@fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Items[0];
   fDrawToSignalSubmitInfos[InFlightFrameIndex].pWaitDstStageMask:=@fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Items[0];
  end else begin
   fDrawToSignalSubmitInfos[InFlightFrameIndex].pWaitSemaphores:=nil;
   fDrawToSignalSubmitInfos[InFlightFrameIndex].pWaitDstStageMask:=nil;
  end;
 end;
end;

procedure TpvFrameGraph.ReleaseVolatileResources;
var InFlightFrameIndex,
    Index:TpvSizeInt;
    ResourceAliasGroup:TResourceAliasGroup;
    PhysicalPass:TPhysicalPass;
    Queue:TQueue;
    PhysicalPassCrossEvent:TPhysicalPassCrossEvent;
begin
 for Queue in fQueues do begin
  Queue.ReleaseVolatileResources;
 end;
 for PhysicalPass in fPhysicalPasses do begin
  PhysicalPass.ReleaseVolatileResources;
 end;
 for PhysicalPassCrossEvent in fPhysicalPassCrossEvents do begin
  PhysicalPassCrossEvent.ReleaseVolatileResources;
 end;
 for ResourceAliasGroup in fResourceAliasGroups do begin
  ResourceAliasGroup.ReleaseVolatileResources;
 end;
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  for Index:=0 to fDrawToWaitOnSemaphores[InFlightFrameIndex].Count-1 do begin
   FreeAndNil(fDrawToWaitOnSemaphores[InFlightFrameIndex].Items[Index]);
  end;
  fDrawToWaitOnSemaphores[InFlightFrameIndex].Clear;
  fDrawToWaitOnSemaphoreHandles[InFlightFrameIndex].Clear;
  fDrawToSignalSemaphoreHandles[InFlightFrameIndex].Clear;
  fDrawToSignalSemaphoreDstStageMasks[InFlightFrameIndex].Clear;
 end;
end;

procedure TpvFrameGraph.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
var QueueIndex,Index,SubpassIndex:TpvSizeInt;
    Queue:TQueue;
    PhysicalPass:TPhysicalPass;
    PhysicalComputePass:TPhysicalComputePass;
    PhysicalTransferPass:TPhysicalTransferPass;
    PhysicalCustomPass:TPhysicalCustomPass;
    PhysicalRenderPass:TPhysicalRenderPass;
    PhysicalRenderPassSubpass:TPhysicalRenderPass.TSubpass;
begin
 for QueueIndex:=0 to fQueues.Count-1 do begin
  Queue:=fQueues[QueueIndex];
  for Index:=0 to Queue.fPhysicalPasses.Count-1 do begin
   PhysicalPass:=Queue.fPhysicalPasses[Index];
   if assigned(PhysicalPass) then begin
    if PhysicalPass is TPhysicalComputePass then begin
     PhysicalComputePass:=TPhysicalComputePass(PhysicalPass);
     PhysicalComputePass.fComputePass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
     PhysicalComputePass.fComputePass.fDoubleBufferedEnabledState[aUpdateFrameIndex and 1]:=TPass.TFlag.Enabled in PhysicalComputePass.fComputePass.fFlags;
    end else if PhysicalPass is TPhysicalTransferPass then begin
     PhysicalTransferPass:=TPhysicalTransferPass(PhysicalPass);
     PhysicalTransferPass.fTransferPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
     PhysicalTransferPass.fTransferPass.fDoubleBufferedEnabledState[aUpdateFrameIndex and 1]:=TPass.TFlag.Enabled in PhysicalTransferPass.fTransferPass.fFlags;
    end else if PhysicalPass is TPhysicalCustomPass then begin
     PhysicalCustomPass:=TPhysicalCustomPass(PhysicalPass);
     PhysicalCustomPass.fCustomPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
     PhysicalCustomPass.fCustomPass.fDoubleBufferedEnabledState[aUpdateFrameIndex and 1]:=TPass.TFlag.Enabled in PhysicalCustomPass.fCustomPass.fFlags;
    end else if PhysicalPass is TPhysicalRenderPass then begin
     PhysicalRenderPass:=TPhysicalRenderPass(PhysicalPass);
     for SubpassIndex:=0 to PhysicalRenderPass.fSubpasses.Count-1 do begin
      PhysicalRenderPassSubpass:=PhysicalRenderPass.fSubpasses[SubpassIndex];
      PhysicalRenderPassSubpass.fRenderPass.Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
      PhysicalRenderPassSubpass.fRenderPass.fDoubleBufferedEnabledState[aUpdateFrameIndex and 1]:=TPass.TFlag.Enabled in PhysicalRenderPassSubpass.fRenderPass.fFlags;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvFrameGraph.ExecuteQueueCommandBufferParallelForJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var CommandBufferIndex,
    PhysicalPassIndex,
    SubpassIndex:TpvSizeInt;
    Queue:TQueue;
    CommandBuffer:TQueue.TCommandBuffer;
    VulkanCommandBuffer:TpvVulkanCommandBuffer;
    PhysicalPass:TPhysicalPass;
    PhysicalComputePass:TPhysicalComputePass;
    PhysicalTransferPass:TPhysicalTransferPass;
    PhysicalCustomPass:TPhysicalCustomPass;
    PhysicalRenderPass:TPhysicalRenderPass;
    PhysicalRenderPassSubpass:TPhysicalRenderPass.TSubpass;
    Used:boolean;
    PhysicalPassClassName:RawByteString;
begin
 Queue:=aData;
 for CommandBufferIndex:=aFromIndex to aToIndex do begin
  CommandBuffer:=Queue.fCommandBuffers[CommandBufferIndex];
  VulkanCommandBuffer:=CommandBuffer.fCommandBuffers[fDrawInFlightFrameIndex];
  VulkanCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
  if CommandBuffer.fMustResetEvents then begin
   Queue.ResetEvents(VulkanCommandBuffer,fDrawInFlightFrameIndex);
  end;
  for PhysicalPassIndex:=0 to CommandBuffer.fPhysicalPasses.Count-1 do begin
   PhysicalPass:=CommandBuffer.fPhysicalPasses[PhysicalPassIndex];
   if assigned(PhysicalPass) then begin
    if fVulkanDevice.UseNVIDIADeviceDiagnostics and assigned(fVulkanDevice.Commands.Commands.CmdSetCheckpointNV) then begin
     PhysicalPassClassName:=RawByteString(PhysicalPass.ClassName);
     if length(PhysicalPassClassName)>0 then begin
      fVulkanDevice.Commands.CmdSetCheckpointNV(VulkanCommandBuffer.Handle,PAnsiChar(PhysicalPassClassName));
     end;
    end;
    if PhysicalPass is TPhysicalComputePass then begin
     PhysicalComputePass:=TPhysicalComputePass(PhysicalPass);
     if PhysicalComputePass.fComputePass.fDoubleBufferedEnabledState[fDrawFrameIndex and 1] then begin
      PhysicalComputePass.Execute(VulkanCommandBuffer);
     end;
    end else if PhysicalPass is TPhysicalTransferPass then begin
     PhysicalTransferPass:=TPhysicalTransferPass(PhysicalPass);
     if PhysicalTransferPass.fTransferPass.fDoubleBufferedEnabledState[fDrawFrameIndex and 1] then begin
      PhysicalTransferPass.Execute(VulkanCommandBuffer);
     end;
    end else if PhysicalPass is TPhysicalCustomPass then begin
     PhysicalCustomPass:=TPhysicalCustomPass(PhysicalPass);
     if PhysicalCustomPass.fCustomPass.fDoubleBufferedEnabledState[fDrawFrameIndex and 1] then begin
      PhysicalCustomPass.Execute(VulkanCommandBuffer);
     end;
    end else if PhysicalPass is TPhysicalRenderPass then begin
     PhysicalRenderPass:=TPhysicalRenderPass(PhysicalPass);
     Used:=false;
     for SubpassIndex:=0 to PhysicalRenderPass.fSubpasses.Count-1 do begin
      PhysicalRenderPassSubpass:=PhysicalRenderPass.fSubpasses[SubpassIndex];
      if PhysicalRenderPassSubpass.fRenderPass.fDoubleBufferedEnabledState[fDrawFrameIndex and 1] then begin
       Used:=true;
       break;
      end;
     end;
     if Used then begin
      PhysicalRenderPass.Execute(VulkanCommandBuffer);
     end;
    end;
   end;
  end;
  VulkanCommandBuffer.EndRecording;
  Queue.fSubmitInfos[CommandBuffer.fSubmitInfoIndex]:=CommandBuffer.fSubmitInfos[fDrawInFlightFrameIndex];
 end;
end;

procedure TpvFrameGraph.ExecuteQueue(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aQueue:TQueue);
var Index:TpvSizeInt;
begin
 if (aQueue=fUniversalQueue) and
    (fDrawToWaitOnSemaphoreHandles[fDrawInFlightFrameIndex].Count>0) then begin
  fUniversalQueue.fSubmitInfos[0]:=fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex];
 end;
 if aQueue.fCommandBuffers.Count>0 then begin
  if fCanDoParallelProcessing and assigned(pvApplication) and (aQueue.fCommandBuffers.Count>1) then begin
   pvApplication.PasMPInstance.Invoke(pvApplication.PasMPInstance.ParallelFor(aQueue,0,aQueue.fCommandBuffers.Count-1,ExecuteQueueCommandBufferParallelForJobMethod,1,16,aJob,0));
  end else begin
   ExecuteQueueCommandBufferParallelForJobMethod(nil,0,aQueue,0,aQueue.fCommandBuffers.Count-1);
  end;
 end;
 if (aQueue=fUniversalQueue) and
    (fDrawToSignalSemaphoreHandles[fDrawInFlightFrameIndex].Count>0) then begin
  fUniversalQueue.fSubmitInfos[fUniversalQueue.fCountSubmitInfos-1]:=fDrawToSignalSubmitInfos[fDrawInFlightFrameIndex];
 end;
 if aQueue.fCountSubmitInfos>0 then begin
  if fRootPhysicalPass.fQueue=aQueue then begin
   aQueue.fPhysicalQueue.Submit(aQueue.fCountSubmitInfos,@aQueue.fSubmitInfos[0],fDrawWaitFence);
  end else begin
   aQueue.fPhysicalQueue.Submit(aQueue.fCountSubmitInfos,@aQueue.fSubmitInfos[0]);
  end;
 end;
end;

procedure TpvFrameGraph.ExecuteQueueParallelForJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Index:TPasMPNativeInt;
begin
 for Index:=aFromIndex to aToIndex do begin
  ExecuteQueue(aJob,aThreadIndex,fQueues[Index]);
 end;
end;

procedure TpvFrameGraph.Draw(const aDrawSwapChainImageIndex:TpvSizeInt;
                             const aDrawInFlightFrameIndex:TpvSizeInt;
                             const aDrawFrameIndex:TpvSizeInt;
                             const aToWaitOnSemaphore:TpvVulkanSemaphore=nil;
                             const aToSignalSemaphore:TpvVulkanSemaphore=nil;
                             const aWaitFence:TpvVulkanFence=nil);
var SemaphoreIndex,PassIndex:TpvSizeInt;
    SubmitInfo:TVkSubmitInfo;
begin
 fDrawSwapChainImageIndex:=aDrawSwapChainImageIndex;
 fDrawPreviousInFlightFrameIndex:=aDrawInFlightFrameIndex-1;
 if fDrawPreviousInFlightFrameIndex<0 then begin
  inc(fDrawPreviousInFlightFrameIndex,fCountInFlightFrames);
 end;
 fDrawInFlightFrameIndex:=aDrawInFlightFrameIndex;
 fDrawFrameIndex:=aDrawFrameIndex;
 fDrawWaitFence:=aWaitFence;
 if assigned(aToWaitOnSemaphore) then begin
  Assert(fDrawToWaitOnSemaphoreHandles[fDrawInFlightFrameIndex].Count>0);
  fDrawToWaitOnSemaphoreExternalHandles[fDrawInFlightFrameIndex]:=aToWaitOnSemaphore.Handle;
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].waitSemaphoreCount:=1;
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].pWaitSemaphores:=@fDrawToWaitOnSemaphoreExternalHandles[fDrawInFlightFrameIndex];
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].pWaitDstStageMask:=@fDrawToWaitOnSemaphoreExternalDstStageMask;
 end else begin
  Assert(fDrawToWaitOnSemaphoreHandles[fDrawInFlightFrameIndex].Count=0);
  fDrawToWaitOnSemaphoreExternalHandles[fDrawInFlightFrameIndex]:=VK_NULL_HANDLE;
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].waitSemaphoreCount:=0;
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].pWaitSemaphores:=nil;
  fDrawToWaitSubmitInfos[fDrawInFlightFrameIndex].pWaitDstStageMask:=nil;
 end;
 if assigned(aToSignalSemaphore) then begin
  Assert(fDrawToSignalSemaphoreHandles[fDrawInFlightFrameIndex].Count>0);
  fDrawToSignalSemaphoreExternalHandles[fDrawInFlightFrameIndex]:=aToSignalSemaphore.Handle;
  fDrawToSignalSubmitInfos[fDrawInFlightFrameIndex].signalSemaphoreCount:=1;
  fDrawToSignalSubmitInfos[fDrawInFlightFrameIndex].pSignalSemaphores:=@fDrawToSignalSemaphoreExternalHandles[fDrawInFlightFrameIndex];
 end else begin
  Assert(fDrawToSignalSemaphoreHandles[fDrawInFlightFrameIndex].Count=0);
  fDrawToSignalSemaphoreExternalHandles[fDrawInFlightFrameIndex]:=VK_NULL_HANDLE;
  fDrawToSignalSubmitInfos[fDrawInFlightFrameIndex].signalSemaphoreCount:=0;
  fDrawToSignalSubmitInfos[fDrawInFlightFrameIndex].pSignalSemaphores:=nil;
 end;
 if assigned(fTimerQueries[fDrawInFlightFrameIndex]) then begin
  if fTimerQueries[fDrawInFlightFrameIndex].Update then begin
   fLastTimerQueryResults:=fTimerQueries[fDrawInFlightFrameIndex].Results;
  end;
  fTimerQueries[fDrawInFlightFrameIndex].Reset;
 end;
 if length(fLastCPUTimeValues)=length(fCPUTimeValues) then begin
  if length(fCPUTimeValues)>0 then begin
   Move(fCPUTimeValues[0],fLastCPUTimeValues[0],length(fCPUTimeValues)*SizeOf(TpvHighResolutionTime));
  end;
 end else begin
  fLastCPUTimeValues:=copy(fCPUTimeValues);
 end;
 if length(fCPUTimeValues)>=2 then begin
  fCPUTimeValues[length(fCPUTimeValues)-1]:=pvApplication.HighResolutionTimer.GetTime;
 end;
 if fCanDoParallelProcessing and assigned(pvApplication) and (fQueues.Count>1) then begin
  pvApplication.PasMPInstance.Invoke(pvApplication.PasMPInstance.ParallelFor(nil,0,fQueues.Count-1,ExecuteQueueParallelForJobMethod,1,16,nil,0));
 end else begin
  ExecuteQueueParallelForJobMethod(nil,0,nil,0,fQueues.Count-1);
 end;
 if length(fCPUTimeValues)>=2 then begin
  fCPUTimeValues[length(fCPUTimeValues)-1]:=pvApplication.HighResolutionTimer.GetTime-fCPUTimeValues[length(fCPUTimeValues)-1];
  fCPUTimeValues[length(fCPUTimeValues)-2]:=0;
  for PassIndex:=0 to Min(fPasses.Count,length(fCPUTimeValues)-2)-1 do begin
   fCPUTimeValues[PassIndex]:=fPasses[PassIndex].fCPUTimeValues[aDrawInFlightFrameIndex];
   fCPUTimeValues[length(fCPUTimeValues)-2]:=fCPUTimeValues[length(fCPUTimeValues)-2]+fCPUTimeValues[PassIndex];
  end;
 end;
end;

procedure TpvFrameGraph.Dump;
var Pass:TpvFrameGraph.TPass;
begin
 writeln;
 for Pass in fTopologicalSortedPasses do begin
  writeln('Pass ',Pass.Name,':');
  writeln;
 end;
 writeln;
end;

end.
