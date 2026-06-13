(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
unit PasVulkan.Scene3D.Renderer.MeshCullReset;
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

uses SysUtils,
     Classes,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D.Globals;

type { TpvScene3DRendererMeshCullReset }
     TpvScene3DRendererMeshCullReset=class
      public
       type TPushConstants=packed record
             CountRanges:TpvUInt32;
             MaxMultiIndirectDrawCalls:TpvUInt32;
             BatchRangeOffset:TpvUInt32;
             PrefixSumOffset:TpvUInt32;
             CullDispatchIndex:TpvUInt32;
            end;
            PPushConstants=^TPushConstants;
      private
       fVulkanDevice:TpvVulkanDevice;
       fVulkanPipelineCache:TpvVulkanPipelineCache;
       fCountInFlightFrames:TpvSizeInt;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
       function GetVulkanDescriptorSet(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanDescriptorSet;
      public
       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aCountInFlightFrames:TpvSizeInt);
       destructor Destroy; override;
       procedure AcquireResources(const aBatchRangeBuffers:TpvVulkanInFlightFrameBuffers;const aCounterBuffers:TpvVulkanInFlightFrameBuffers;const aPrefixSumBuffers:TpvVulkanInFlightFrameBuffers;const aIndirectDispatchBuffers:TpvVulkanInFlightFrameBuffers);
       procedure ReleaseResources;
       property Pipeline:TpvVulkanComputePipeline read fPipeline;
       property PipelineLayout:TpvVulkanPipelineLayout read fPipelineLayout;
       property VulkanDescriptorSets[const aInFlightFrameIndex:TpvSizeInt]:TpvVulkanDescriptorSet read GetVulkanDescriptorSet;
      end;

implementation

uses PasVulkan.Scene3D.Renderer.Globals;

{ TpvScene3DRendererMeshCullReset }

constructor TpvScene3DRendererMeshCullReset.Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aCountInFlightFrames:TpvSizeInt);
begin
 inherited Create;
 fVulkanDevice:=aVulkanDevice;
 fVulkanPipelineCache:=aVulkanPipelineCache;
 fCountInFlightFrames:=aCountInFlightFrames;
 fComputeShaderModule:=nil;
 fVulkanPipelineShaderStageCompute:=nil;
 fVulkanDescriptorSetLayout:=nil;
 fVulkanDescriptorPool:=nil;
 fPipelineLayout:=nil;
 fPipeline:=nil;
end;

destructor TpvScene3DRendererMeshCullReset.Destroy;
begin
 ReleaseResources;
 inherited Destroy;
end;

function TpvScene3DRendererMeshCullReset.GetVulkanDescriptorSet(const aInFlightFrameIndex:TpvSizeInt):TpvVulkanDescriptorSet;
begin
 result:=fVulkanDescriptorSets[aInFlightFrameIndex];
end;

procedure TpvScene3DRendererMeshCullReset.AcquireResources(const aBatchRangeBuffers:TpvVulkanInFlightFrameBuffers;const aCounterBuffers:TpvVulkanInFlightFrameBuffers;const aPrefixSumBuffers:TpvVulkanInFlightFrameBuffers;const aIndirectDispatchBuffers:TpvVulkanInFlightFrameBuffers);
var Stream:TStream;
    InFlightFrameIndex:TpvSizeInt;
begin

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_cull_reset_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fVulkanDevice,Stream);
  fVulkanDevice.DebugUtils.SetObjectName(fComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererMeshCullReset.fComputeShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fVulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(3,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererMeshCullReset.fVulkanDescriptorSetLayout');

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fVulkanDevice,
                                                        TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                        fCountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fCountInFlightFrames*4);
 fVulkanDescriptorPool.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererMeshCullReset.fVulkanDescriptorPool');

 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [aBatchRangeBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [aCounterBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [aPrefixSumBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [aIndirectDispatchBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
  fVulkanDevice.DebugUtils.SetObjectName(fVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererMeshCullReset.fVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');
 end;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fVulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererMeshCullReset.fPipelineLayout');

 fPipeline:=TpvVulkanComputePipeline.Create(fVulkanDevice,
                                            fVulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);
 fVulkanDevice.DebugUtils.SetObjectName(fPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererMeshCullReset.fPipeline');

end;

procedure TpvScene3DRendererMeshCullReset.ReleaseResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 FreeAndNil(fVulkanDescriptorPool);
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
end;

end.
