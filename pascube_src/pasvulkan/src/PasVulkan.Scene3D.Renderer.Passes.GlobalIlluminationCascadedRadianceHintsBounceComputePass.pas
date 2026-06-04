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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsBounceComputePass;
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
     Math,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.FrameGraph,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.SkyBox;

type { TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass }
     TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass=class(TpvFrameGraph.TComputePass)
      public
{      type TPushConstants=record
             MaximumSamplingDistance:TpvFloat;
            end;
            PPushConstants=^TPushConstants;//}
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
       //fFirst:Boolean;
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
      published
     end;

implementation

{ TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass }

constructor TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='GlobalIlluminationCascadedRadianceHintsBounceComputePass';

 //fFirst:=true;

{fResourceInput:=AddImageInput(fInstance.LastOutputResource.ResourceType.Name,
                               fInstance.LastOutputResource.Resource.Name,
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                              );

 fInputFormat:=TpvFrameGraph.TImageResourceType(fInstance.LastOutputResource.ResourceType).Format;}

end;

destructor TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.AcquirePersistentResources;
var Stream:TStream;
    Format:string;
begin

 inherited AcquirePersistentResources;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('gi_cascaded_radiance_hints_bounce_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.AcquireVolatileResources;
var InFlightFrameIndex,PreviousInFlightFrameIndex,Index,CascadeIndex,SHTextureIndex:TpvInt32;
    ImageSHDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
    ImageMetaInfoDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
    TexLastSHDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
    TexLastMetaInfoDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
    TexSHDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
    TexMetaInfoDescriptorImageInfoArray:TVkDescriptorImageInfoArray;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages*2);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2,
                                       VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(3,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(4,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(5,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(6,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
{fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                      0,
                                      SizeOf(TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.TPushConstants));}
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                            fInstance.Renderer.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);

 ImageSHDescriptorImageInfoArray:=nil;
 ImageMetaInfoDescriptorImageInfoArray:=nil;
 TexLastSHDescriptorImageInfoArray:=nil;
 TexLastMetaInfoDescriptorImageInfoArray:=nil;
 TexSHDescriptorImageInfoArray:=nil;
 TexMetaInfoDescriptorImageInfoArray:=nil;

 try

  for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

   if InFlightFrameIndex=0 then begin
    PreviousInFlightFrameIndex:=FrameGraph.CountInFlightFrames-1;
   end else begin
    PreviousInFlightFrameIndex:=InFlightFrameIndex-1;
   end;

   SetLength(ImageSHDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages);
   SetLength(ImageMetaInfoDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades);
   SetLength(TexLastSHDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages);
   SetLength(TexLastMetaInfoDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades);
   SetLength(TexSHDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages);
   SetLength(TexMetaInfoDescriptorImageInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades);

   Index:=0;
   for CascadeIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades-1 do begin
    for SHTextureIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages-1 do begin
     ImageSHDescriptorImageInfoArray[Index]:=TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                           fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[InFlightFrameIndex,CascadeIndex,SHTextureIndex].VulkanImageView.Handle,
                                                                           VK_IMAGE_LAYOUT_GENERAL);
     TexLastSHDescriptorImageInfoArray[Index]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                             fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[PreviousInFlightFrameIndex,CascadeIndex,SHTextureIndex].VulkanImageView.Handle,
                                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
     TexSHDescriptorImageInfoArray[Index]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                         fInstance.InFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,SHTextureIndex].VulkanImageView.Handle,
                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
     inc(Index);
    end;
    ImageMetaInfoDescriptorImageInfoArray[CascadeIndex]:=TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                       fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[InFlightFrameIndex,CascadeIndex,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages].VulkanImageView.Handle,
                                                                                       VK_IMAGE_LAYOUT_GENERAL);
    TexLastMetaInfoDescriptorImageInfoArray[CascadeIndex]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                         fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[PreviousInFlightFrameIndex,CascadeIndex,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages].VulkanImageView.Handle,
                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
    TexMetaInfoDescriptorImageInfoArray[CascadeIndex]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                     fInstance.InFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages].VulkanImageView.Handle,
                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
   end;

   fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                            fVulkanDescriptorSetLayout);
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                  0,
                                                                  1,
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                  [],
                                                                  [fInstance.GlobalIlluminationRadianceHintsUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                  0,
                                                                  length(ImageSHDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  ImageSHDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                  0,
                                                                  length(ImageMetaInfoDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  ImageMetaInfoDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                  0,
                                                                  length(TexLastSHDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                  TexLastSHDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                  0,
                                                                  length(TexLastMetaInfoDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                  TexLastMetaInfoDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                  0,
                                                                  length(TexSHDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                  TexSHDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                  0,
                                                                  length(TexMetaInfoDescriptorImageInfoArray),
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                  TexMetaInfoDescriptorImageInfoArray,
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].Flush;

   ImageSHDescriptorImageInfoArray:=nil;
   ImageMetaInfoDescriptorImageInfoArray:=nil;
   TexLastSHDescriptorImageInfoArray:=nil;
   TexLastMetaInfoDescriptorImageInfoArray:=nil;
   TexSHDescriptorImageInfoArray:=nil;
   TexMetaInfoDescriptorImageInfoArray:=nil;

  end;

 finally
  ImageSHDescriptorImageInfoArray:=nil;
  ImageMetaInfoDescriptorImageInfoArray:=nil;
  TexLastSHDescriptorImageInfoArray:=nil;
  TexLastMetaInfoDescriptorImageInfoArray:=nil;
  TexSHDescriptorImageInfoArray:=nil;
  TexMetaInfoDescriptorImageInfoArray:=nil;
 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex,Index,CascadeIndex,VolumeIndex:TpvInt32;
    ImageMemoryBarriers:array[0..(TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages)-1] of TVkImageMemoryBarrier;
//  PushConstants:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.TPushConstants;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

 Index:=0;
 for CascadeIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades-1 do begin
  for VolumeIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages-1 do begin
   ImageMemoryBarriers[Index]:=TVkImageMemoryBarrier.Create(0,//TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                            TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            VK_IMAGE_LAYOUT_UNDEFINED,//VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                            VK_IMAGE_LAYOUT_GENERAL,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[InFlightFrameIndex,CascadeIndex,VolumeIndex].VulkanImage.Handle,
                                                            TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                            0,
                                                                                            1,
                                                                                            0,
                                                                                            1));
   inc(Index);
  end;
 end;
 aCommandBuffer.CmdPipelineBarrier(FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   length(ImageMemoryBarriers),@ImageMemoryBarriers[0]);

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                      fPipelineLayout.Handle,
                                      0,
                                      1,
                                      @fVulkanDescriptorSets[InFlightFrameIndex].Handle,
                                      0,
                                      nil);

{PushConstants.MaximumSamplingDistance:=fInstance.Renderer.GlobalIlluminationRadianceHintsMaximumSamplingDistance;
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                 TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                 0,
                                 SizeOf(TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.TPushConstants),
                                 @PushConstants);}

 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationRadiantHintVolumeSize+7) shr 3,
                            (TpvScene3DRendererInstance.GlobalIlluminationRadiantHintVolumeSize+7) shr 3,
                            ((TpvScene3DRendererInstance.GlobalIlluminationRadiantHintVolumeSize*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades)+7) shr 3);

 Index:=0;
 for CascadeIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades-1 do begin
  for VolumeIndex:=0 to TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages-1 do begin
   ImageMemoryBarriers[Index]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                            VK_IMAGE_LAYOUT_GENERAL,
                                                            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fInstance.InFlightFrameCascadedRadianceHintSecondBounceVolumeImages[InFlightFrameIndex,CascadeIndex,VolumeIndex].VulkanImage.Handle,
                                                            TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                            0,
                                                                                            1,
                                                                                            0,
                                                                                            1));
   inc(Index);
  end;
 end;
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   0,
                                   0,nil,
                                   0,nil,
                                   length(ImageMemoryBarriers),@ImageMemoryBarriers[0]);

end;

end.
