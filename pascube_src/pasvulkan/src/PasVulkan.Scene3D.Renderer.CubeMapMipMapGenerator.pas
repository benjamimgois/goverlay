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
unit PasVulkan.Scene3D.Renderer.CubeMapMipMapGenerator;
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
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.MipmapImageCubeMap;

type { TpvScene3DRendererCubeMapMipMapGenerator }
     TpvScene3DRendererCubeMapMipMapGenerator=class
      private
       fScene3D:TpvScene3D;
       fVulkanDevice:TpvVulkanDevice;
       fCubeMap:TpvScene3DRendererMipmapImageCubeMap;
       fReductionComputeShaderModule:TpvVulkanShaderModule;
       fVulkanImageView:TpvVulkanImageView;
       fReductionVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fReductionVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fReductionVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fReductionVulkanDescriptorSets:array[0..7] of TpvVulkanDescriptorSet;
       fReductionPipelineLayout:TpvVulkanPipelineLayout;
       fReductionPipeline:TpvVulkanComputePipeline;
       fCountMipMapLevelSets:TpvSizeInt;
      public
       constructor Create(const aScene3D:TpvScene3D;
                          const aCubeMap:TpvScene3DRendererMipmapImageCubeMap); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources;
       procedure ReleasePersistentResources;
       procedure AcquireVolatileResources;
       procedure ReleaseVolatileResources;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
     end;

implementation

{ TpvScene3DRendererCubeMapMipMapGenerator }

constructor TpvScene3DRendererCubeMapMipMapGenerator.Create(const aScene3D:TpvScene3D;
                                                            const aCubeMap:TpvScene3DRendererMipmapImageCubeMap);
begin
 inherited Create;

 fScene3D:=aScene3D;

 fVulkanDevice:=fScene3D.VulkanDevice;

 fCubeMap:=aCubeMap;

end;

destructor TpvScene3DRendererCubeMapMipMapGenerator.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererCubeMapMipMapGenerator.AcquirePersistentResources;
var Stream:TStream;
    Format:string;
begin

 case fCubeMap.Format of
  VK_FORMAT_B10G11R11_UFLOAT_PACK32:begin
   Format:='r11g11b10f';
  end;
  VK_FORMAT_R16G16B16A16_SFLOAT:begin
   Format:='rgba16f';
  end;
  VK_FORMAT_R32G32B32A32_SFLOAT:begin
   Format:='rgba32f';
  end;
  VK_FORMAT_E5B9G9R9_UFLOAT_PACK32:begin
   Format:='rgb9e5';
  end;
  VK_FORMAT_R8G8B8A8_UNORM,
  VK_FORMAT_B8G8R8A8_UNORM:begin
   Format:='rgba8';
  end;
  else begin
   Assert(false);
   Format:='';
  end;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_cubemap_'+Format+'_comp.spv');
 try
  fReductionComputeShaderModule:=TpvVulkanShaderModule.Create(fVulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fVulkanDevice.DebugUtils.SetObjectName(fReductionComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionComputeShaderModule');

 fReductionVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fReductionComputeShaderModule,'main');

end;

procedure TpvScene3DRendererCubeMapMipMapGenerator.ReleasePersistentResources;
begin
 FreeAndNil(fReductionVulkanPipelineShaderStageCompute);
 FreeAndNil(fReductionComputeShaderModule);
end;

procedure TpvScene3DRendererCubeMapMipMapGenerator.AcquireVolatileResources;
var MipMapLevelSetIndex:TpvInt32;
    ImageViewType:TVkImageViewType;
    //Sampler:TpvVulkanSampler;
begin

 ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE);

 fVulkanImageView:=TpvVulkanImageView.Create(fVulkanDevice,
                                             fCubeMap.VulkanImage,
                                             ImageViewType,
                                             fCubeMap.Format,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                             0,
                                             1,
                                             0,
                                             6
                                            );
 fVulkanDevice.DebugUtils.SetObjectName(fVulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererCubeMapMipMapGenerator.fVulkanImageView');

 /////

 fReductionVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fVulkanDevice,
                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                4);
 fReductionVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,(4*4)+1);
 fReductionVulkanDescriptorPool.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionVulkanDescriptorPool');

 fReductionVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fVulkanDevice);
 fReductionVulkanDescriptorSetLayout.AddBinding(0,
                                                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fReductionVulkanDescriptorSetLayout.AddBinding(1,
                                                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                4,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fReductionVulkanDescriptorSetLayout.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionVulkanDescriptorSetLayout');

 fReductionPipelineLayout:=TpvVulkanPipelineLayout.Create(fVulkanDevice);
 fReductionPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvInt32));
 fReductionPipelineLayout.AddDescriptorSetLayout(fReductionVulkanDescriptorSetLayout);
 fReductionPipelineLayout.Initialize;
 fVulkanDevice.DebugUtils.SetObjectName(fReductionPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionPipelineLayout');

 fReductionPipeline:=TpvVulkanComputePipeline.Create(fVulkanDevice,
                                                     fScene3D.VulkanPipelineCache,
                                                     0,
                                                     fReductionVulkanPipelineShaderStageCompute,
                                                     fReductionPipelineLayout,
                                                     nil,
                                                     0);
 fVulkanDevice.DebugUtils.SetObjectName(fReductionPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionPipeline');

 fCountMipMapLevelSets:=Min(((fCubeMap.MipMapLevels-1)+3) shr 2,8);

 for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin
  fReductionVulkanDescriptorSets[MipMapLevelSetIndex]:=TpvVulkanDescriptorSet.Create(fReductionVulkanDescriptorPool,
                                                                                     fReductionVulkanDescriptorSetLayout);

  fReductionVulkanDescriptorSets[MipMapLevelSetIndex].WriteToDescriptorSet(0,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                           [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCubeMap.VulkanImageViews[Min(MipMapLevelSetIndex shl 2,fCubeMap.MipMapLevels-1)].Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL)],
                                                                           [],
                                                                           [],
                                                                           false
                                                                          );
  fReductionVulkanDescriptorSets[MipMapLevelSetIndex].WriteToDescriptorSet(1,
                                                                           0,
                                                                           4,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                           [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCubeMap.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+1),fCubeMap.MipMapLevels-1)].Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL),
                                                                            TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCubeMap.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+2),fCubeMap.MipMapLevels-1)].Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL),
                                                                            TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCubeMap.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+3),fCubeMap.MipMapLevels-1)].Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL),
                                                                            TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCubeMap.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+4),fCubeMap.MipMapLevels-1)].Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL)],                                                                                                                        [],
                                                                           [],
                                                                           false
                                                                          );
  fReductionVulkanDescriptorSets[MipMapLevelSetIndex].Flush;
  fVulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSets[MipMapLevelSetIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererCubeMapMipMapGenerator.fReductionVulkanDescriptorSets['+IntToStr(MipMapLevelSetIndex)+']');
 end;

end;

procedure TpvScene3DRendererCubeMapMipMapGenerator.ReleaseVolatileResources;
var MipMapLevelSetIndex:TpvInt32;
begin
 FreeAndNil(fReductionPipeline);
 FreeAndNil(fReductionPipelineLayout);
 for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin
  FreeAndNil(fReductionVulkanDescriptorSets[MipMapLevelSetIndex]);
 end;
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fReductionVulkanDescriptorSetLayout);
 FreeAndNil(fReductionVulkanDescriptorPool);
end;

procedure TpvScene3DRendererCubeMapMipMapGenerator.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
var MipMapLevelIndex,MipMapLevelSetIndex:TpvSizeInt;
    CountMipMaps:TpvInt32;
    ImageMemoryBarriers:array[0..1] of TVkImageMemoryBarrier;
begin

 //////////////////////////

 begin

  FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarriers[0].pNext:=nil;
  ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].image:=fCubeMap.VulkanImage.Handle;
  ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
  ImageMemoryBarriers[0].subresourceRange.levelCount:=1;
  ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarriers[0].subresourceRange.layerCount:=6;

  FillChar(ImageMemoryBarriers[1],SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarriers[1].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarriers[1].pNext:=nil;
  ImageMemoryBarriers[1].srcAccessMask:=0;
  ImageMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarriers[1].oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
  ImageMemoryBarriers[1].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarriers[1].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[1].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[1].image:=fCubeMap.VulkanImage.Handle;
  ImageMemoryBarriers[1].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarriers[1].subresourceRange.baseMipLevel:=1;
  ImageMemoryBarriers[1].subresourceRange.levelCount:=fCubeMap.MipMapLevels-1;
  ImageMemoryBarriers[1].subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarriers[1].subresourceRange.layerCount:=6;

  aCommandBuffer.CmdPipelineBarrier(fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    2,@ImageMemoryBarriers[0]);

 end;

 //////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fReductionPipeline.Handle);

  for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin

   MipMapLevelIndex:=(MipMapLevelSetIndex shl 2) or 1;

   CountMipMaps:=Min(4,fCubeMap.MipMapLevels-MipMapLevelIndex);

   if CountMipMaps<=0 then begin
    break;
   end;

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        fReductionPipelineLayout.Handle,
                                        0,
                                        1,
                                        @fReductionVulkanDescriptorSets[MipMapLevelSetIndex].Handle,
                                        0,
                                        nil);

   aCommandBuffer.CmdPushConstants(fReductionPipelineLayout.Handle,
                                   TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(TpvInt32),
                                   @CountMipMaps);

   aCommandBuffer.CmdDispatch(Max(1,(fCubeMap.Width+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              Max(1,(fCubeMap.Height+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              6);

   FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
   ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
   ImageMemoryBarriers[0].pNext:=nil;
   ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
   ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
   ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
   ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarriers[0].image:=fCubeMap.VulkanImage.Handle;
   ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
   ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=MipMapLevelIndex;
   ImageMemoryBarriers[0].subresourceRange.levelCount:=CountMipMaps;
   ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
   ImageMemoryBarriers[0].subresourceRange.layerCount:=6;
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarriers[0]);

  end;

 end;

 //////////////////////////

 begin

  FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarriers[0].pNext:=nil;
  ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].image:=fCubeMap.VulkanImage.Handle;
  ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
  ImageMemoryBarriers[0].subresourceRange.levelCount:=fCubeMap.MipMapLevels;
  ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarriers[0].subresourceRange.layerCount:=6;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

 end;

end;

end.
