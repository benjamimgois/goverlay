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
unit PasVulkan.Scene3D.Renderer.ImageBasedLighting.SphericalHarmonics;
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
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D.Renderer.Globals;

type { TpvScene3DRendererImageBasedLightingSphericalHarmonics }
     TpvScene3DRendererImageBasedLightingSphericalHarmonics=class
      public
       type TSphericalHarmonicsMetaDataBufferData=record
             DominantLightDirection:TpvVector4;
             DominantLightColor:TpvVector4;
             AmbientLightColor:TpvVector4;
            end;
            PSphericalHarmonicsMetaDataBufferData=^TSphericalHarmonicsMetaDataBufferData;
      private
       fAccumulationComputeShaderModule:TpvVulkanShaderModule;
       fNormalizationComputeShaderModule:TpvVulkanShaderModule;
       fExtractMetaDataComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageAccumulationCompute:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageNormalizationCompute:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageExtractMetaDataCompute:TpvVulkanPipelineShaderStage;
       fSphericalHarmonicsBuffer:TpvVulkanBuffer;
       fSphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer;
       fSphericalHarmonicsMetaDataBufferData:TSphericalHarmonicsMetaDataBufferData;
      public

       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aDescriptorImageInfo:TVkDescriptorImageInfo;const aSphericalHarmonicsBuffer,aSphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer;const aWidth,aHeight:TVkInt32;const aCompleteAccumulation:boolean=true);

       destructor Destroy; override;

      published

       property SphericalHarmonicsBuffer:TpvVulkanBuffer read fSphericalHarmonicsBuffer;

       property SphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer read fSphericalHarmonicsMetaDataBuffer;

      public

       property SphericalHarmonicsMetaDataBufferData:TSphericalHarmonicsMetaDataBufferData read fSphericalHarmonicsMetaDataBufferData;

     end;

implementation

{ TpvScene3DRendererImageBasedLightingSphericalHarmonics }

constructor TpvScene3DRendererImageBasedLightingSphericalHarmonics.Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aDescriptorImageInfo:TVkDescriptorImageInfo;const aSphericalHarmonicsBuffer,aSphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer;const aWidth,aHeight:TVkInt32;const aCompleteAccumulation:boolean=true);
var Stream:TStream;
    UniversalQueue:TpvVulkanQueue;
    UniversalCommandPool:TpvVulkanCommandPool;
    UniversalCommandBuffer:TpvVulkanCommandBuffer;
    UniversalFence:TpvVulkanFence;
    VulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    VulkanDescriptorPool:TpvVulkanDescriptorPool;
    VulkanDescriptorSet:TpvVulkanDescriptorSet;
    AccumulationPipelineLayout:TpvVulkanPipelineLayout;
    AccumulationPipeline:TpvVulkanComputePipeline;
    NormalizationPipelineLayout:TpvVulkanPipelineLayout;
    NormalizationPipeline:TpvVulkanComputePipeline;
    ExtractMetaDataPipelineLayout:TpvVulkanPipelineLayout;
    ExtractMetaDataPipeline:TpvVulkanComputePipeline;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    LODLevel:TVkUInt32;
begin
 inherited Create;

 fSphericalHarmonicsBuffer:=aSphericalHarmonicsBuffer;

 fSphericalHarmonicsMetaDataBuffer:=aSphericalHarmonicsMetaDataBuffer;

 if aCompleteAccumulation then begin

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sphericalharmonics_accumulation_comp.spv');
  try
   fAccumulationComputeShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fVulkanPipelineShaderStageAccumulationCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fAccumulationComputeShaderModule,'main');

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sphericalharmonics_normalization_comp.spv');
  try
   fNormalizationComputeShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fVulkanPipelineShaderStageNormalizationCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fNormalizationComputeShaderModule,'main');

 end else begin

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sphericalharmonics_comp.spv');
  try
   fAccumulationComputeShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fVulkanPipelineShaderStageAccumulationCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fAccumulationComputeShaderModule,'main');

  fNormalizationComputeShaderModule:=nil;

  fVulkanPipelineShaderStageNormalizationCompute:=nil;

 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sphericalharmonics_extract_metadata_comp.spv');
 try
  fExtractMetaDataComputeShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageExtractMetaDataCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fExtractMetaDataComputeShaderModule,'main');

 UniversalQueue:=aVulkanDevice.UniversalQueue;

 UniversalCommandPool:=TpvVulkanCommandPool.Create(aVulkanDevice,
                                                   aVulkanDevice.UniversalQueueFamilyIndex,
                                                   TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  UniversalCommandBuffer:=TpvVulkanCommandBuffer.Create(UniversalCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   UniversalFence:=TpvVulkanFence.Create(aVulkanDevice);
   try

    VulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(aVulkanDevice);
    try
     VulkanDescriptorSetLayout.AddBinding(0,
                                          VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                          1,
                                          TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                          []);
     VulkanDescriptorSetLayout.AddBinding(1,
                                          VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                          1,
                                          TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                          []);
     VulkanDescriptorSetLayout.AddBinding(2,
                                          VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                          1,
                                          TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                          []);
     VulkanDescriptorSetLayout.Initialize;

     VulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(aVulkanDevice,
                                                          TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                          1);
     try

      VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,2);
      VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1);
      VulkanDescriptorPool.Initialize;

      VulkanDescriptorSet:=TpvVulkanDescriptorSet.Create(VulkanDescriptorPool,
                                                         VulkanDescriptorSetLayout);

      VulkanDescriptorSet.WriteToDescriptorSet(0,
                                               0,
                                               1,
                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                               [],
                                               [aSphericalHarmonicsBuffer.DescriptorBufferInfo],
                                               [],
                                               false);
      VulkanDescriptorSet.WriteToDescriptorSet(1,
                                               0,
                                               1,
                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                               [aDescriptorImageInfo],
                                               [],
                                               [],
                                               false);
      VulkanDescriptorSet.WriteToDescriptorSet(2,
                                               0,
                                               1,
                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                               [],
                                               [aSphericalHarmonicsMetaDataBuffer.DescriptorBufferInfo],
                                               [],
                                               false);
      VulkanDescriptorSet.Flush;

      try

       AccumulationPipelineLayout:=TpvVulkanPipelineLayout.Create(aVulkanDevice);
       try

        AccumulationPipelineLayout.AddDescriptorSetLayout(VulkanDescriptorSetLayout);
        if aCompleteAccumulation then begin
         AccumulationPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TVkUInt32));
        end;
        AccumulationPipelineLayout.Initialize;

        AccumulationPipeline:=TpvVulkanComputePipeline.Create(aVulkanDevice,
                                                              aVulkanPipelineCache,
                                                              0,
                                                              fVulkanPipelineShaderStageAccumulationCompute,
                                                              AccumulationPipelineLayout,
                                                              nil,
                                                              0);
        try

         if aCompleteAccumulation then begin

          NormalizationPipelineLayout:=TpvVulkanPipelineLayout.Create(aVulkanDevice);
          NormalizationPipelineLayout.AddDescriptorSetLayout(VulkanDescriptorSetLayout);
          NormalizationPipelineLayout.Initialize;

          NormalizationPipeline:=TpvVulkanComputePipeline.Create(aVulkanDevice,
                                                                 aVulkanPipelineCache,
                                                                 0,
                                                                 fVulkanPipelineShaderStageNormalizationCompute,
                                                                 NormalizationPipelineLayout,
                                                                 nil,
                                                                 0);
         end else begin

          NormalizationPipelineLayout:=nil;

          NormalizationPipeline:=nil;

         end;

         try

          ExtractMetaDataPipelineLayout:=TpvVulkanPipelineLayout.Create(aVulkanDevice);
          ExtractMetaDataPipelineLayout.AddDescriptorSetLayout(VulkanDescriptorSetLayout);
          ExtractMetaDataPipelineLayout.Initialize;

          ExtractMetaDataPipeline:=TpvVulkanComputePipeline.Create(aVulkanDevice,
                                                                   aVulkanPipelineCache,
                                                                   0,
                                                                   fVulkanPipelineShaderStageExtractMetaDataCompute,
                                                                   ExtractMetaDataPipelineLayout,
                                                                   nil,
                                                                   0);
          try

           UniversalCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

           UniversalCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

           UniversalCommandBuffer.CmdFillBuffer(aSphericalHarmonicsBuffer.Handle,0,aSphericalHarmonicsBuffer.Size,0);

           BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                              TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                              VK_QUEUE_FAMILY_IGNORED,
                                                              VK_QUEUE_FAMILY_IGNORED,
                                                              fSphericalHarmonicsBuffer.Handle,
                                                              0,
                                                              VK_WHOLE_SIZE);

           UniversalCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                     TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                                     0,
                                                     nil,
                                                     1,
                                                     @BufferMemoryBarrier,
                                                     0,
                                                     nil);

           UniversalCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AccumulationPipeline.Handle);

           UniversalCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                        AccumulationPipelineLayout.Handle,
                                                        0,
                                                        1,
                                                        @VulkanDescriptorSet.Handle,
                                                        0,
                                                        nil);

           if aCompleteAccumulation then begin

            LODLevel:=0;
            UniversalCommandBuffer.CmdPushConstants(AccumulationPipelineLayout.Handle,
                                                    TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                    0,
                                                    SizeOf(TVkUInt32),
                                                    @LODLevel);

            UniversalCommandBuffer.CmdDispatch((aWidth+7) shr 3,
                                               (aHeight+7) shr 3,
                                               6);

           end else begin

            UniversalCommandBuffer.CmdDispatch(1,
                                               1,
                                               1);

           end;

           if aCompleteAccumulation then begin

            BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                               TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               fSphericalHarmonicsBuffer.Handle,
                                                               0,
                                                               VK_WHOLE_SIZE);

            UniversalCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                                      0,
                                                      nil,
                                                      1,
                                                      @BufferMemoryBarrier,
                                                      0,
                                                      nil);

            UniversalCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,NormalizationPipeline.Handle);

            UniversalCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                         NormalizationPipelineLayout.Handle,
                                                         0,
                                                         1,
                                                         @VulkanDescriptorSet.Handle,
                                                         0,
                                                         nil);

            UniversalCommandBuffer.CmdDispatch(1,
                                               1,
                                               1);

           end;

           BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                              TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                              VK_QUEUE_FAMILY_IGNORED,
                                                              VK_QUEUE_FAMILY_IGNORED,
                                                              fSphericalHarmonicsBuffer.Handle,
                                                              0,
                                                              VK_WHOLE_SIZE);

           UniversalCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                                     TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                                     0,
                                                     nil,
                                                     1,
                                                     @BufferMemoryBarrier,
                                                     0,
                                                     nil);

           begin

            BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                               TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               fSphericalHarmonicsMetaDataBuffer.Handle,
                                                               0,
                                                               VK_WHOLE_SIZE);

            UniversalCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                                      0,
                                                      nil,
                                                      1,
                                                      @BufferMemoryBarrier,
                                                      0,
                                                      nil);

            UniversalCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,ExtractMetaDataPipeline.Handle);

            UniversalCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                         ExtractMetaDataPipelineLayout.Handle,
                                                         0,
                                                         1,
                                                         @VulkanDescriptorSet.Handle,
                                                         0,
                                                         nil);

            UniversalCommandBuffer.CmdDispatch(1,
                                               1,
                                               1);


            BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                               TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or TVkAccessFlags(VK_ACCESS_HOST_READ_BIT),
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               VK_QUEUE_FAMILY_IGNORED,
                                                               fSphericalHarmonicsMetaDataBuffer.Handle,
                                                               0,
                                                               VK_WHOLE_SIZE);

            UniversalCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                                      TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                                      0,
                                                      nil,
                                                      1,
                                                      @BufferMemoryBarrier,
                                                      0,
                                                      nil);

           end;

           UniversalCommandBuffer.EndRecording;

           UniversalCommandBuffer.Execute(UniversalQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,UniversalFence,true);

          finally
           FreeAndNil(ExtractMetaDataPipeline);
           FreeAndNil(ExtractMetaDataPipelineLayout);
          end;

         finally
          FreeAndNil(NormalizationPipeline);
          FreeAndNil(NormalizationPipelineLayout);
         end;

        finally
         FreeAndNil(AccumulationPipeline);
        end;

       finally
        FreeAndNil(AccumulationPipelineLayout);
       end;

      finally
       FreeAndNil(VulkanDescriptorSet);
      end;

     finally
      FreeAndNil(VulkanDescriptorPool);
     end;

    finally
     FreeAndNil(VulkanDescriptorSetLayout);
    end;

    aVulkanDevice.MemoryStaging.Download(UniversalQueue,
                                         UniversalCommandBuffer,
                                         UniversalFence,
                                         fSphericalHarmonicsMetaDataBuffer,
                                         0,
                                         fSphericalHarmonicsMetaDataBufferData,
                                         SizeOf(TSphericalHarmonicsMetaDataBufferData));

   finally
    FreeAndNil(UniversalFence);
   end;

  finally
   FreeAndNil(UniversalCommandBuffer);
  end;

 finally
  FreeAndNil(UniversalCommandPool);
 end;

end;

destructor TpvScene3DRendererImageBasedLightingSphericalHarmonics.Destroy;
begin
 FreeAndNil(fVulkanPipelineShaderStageAccumulationCompute);
 FreeAndNil(fAccumulationComputeShaderModule);
 FreeAndNil(fVulkanPipelineShaderStageNormalizationCompute);
 FreeAndNil(fNormalizationComputeShaderModule);
 FreeAndNil(fExtractMetaDataComputeShaderModule);
 FreeAndNil(fVulkanPipelineShaderStageExtractMetaDataCompute);
 inherited Destroy;
end;

end.
