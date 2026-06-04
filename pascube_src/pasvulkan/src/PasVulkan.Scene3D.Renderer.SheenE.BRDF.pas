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
unit PasVulkan.Scene3D.Renderer.SheenE.BRDF;
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
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D.Renderer.Globals;

type { TpvScene3DRendererSheenEBRDF }
     TpvScene3DRendererSheenEBRDF=class
      public
       const Width=1024;
             Height=1024;
             ImageFormat=TVkFormat(VK_FORMAT_R32_SFLOAT);
      private
       fVertexShaderModule:TpvVulkanShaderModule;
       fFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanImage:TpvVulkanImage;
       fVulkanSampler:TpvVulkanSampler;
       fVulkanImageView:TpvVulkanImageView;
       fMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fDescriptorImageInfo:TVkDescriptorImageInfo;
      public

       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aSampler:TpvVulkanSampler);

       destructor Destroy; override;

      published

       property VulkanImage:TpvVulkanImage read fVulkanImage;

       property VulkanSampler:TpvVulkanSampler read fVulkanSampler;

       property VulkanImageView:TpvVulkanImageView read fVulkanImageView;

      public

       property DescriptorImageInfo:TVkDescriptorImageInfo read fDescriptorImageInfo;

     end;

implementation

{ TpvScene3DRendererSheenEBRDF }

constructor TpvScene3DRendererSheenEBRDF.Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aSampler:TpvVulkanSampler);
var Index:TpvSizeInt;
    Stream:TStream;
    MemoryRequirements:TVkMemoryRequirements;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    ImageSubresourceRange:TVkImageSubresourceRange;
    Queue:TpvVulkanQueue;
    CommandPool:TpvVulkanCommandPool;
    CommandBuffer:TpvVulkanCommandBuffer;
    Fence:TpvVulkanFence;
    ImageView:TpvVulkanImageView;
    FrameBuffer:TpvVulkanFrameBuffer;
    RenderPass:TpvVulkanRenderPass;
    FrameBufferColorAttachment:TpvVulkanFrameBufferAttachment;
    PipelineLayout:TpvVulkanPipelineLayout;
    Pipeline:TpvVulkanGraphicsPipeline;
begin
 inherited Create;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('fullscreen_vert.spv');
 try
  fVertexShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
 finally
  Stream.Free;
 end;

case TpvVulkanVendorID(aVulkanDevice.PhysicalDevice.Properties.vendorID) of
  TpvVulkanVendorID.AMD,
  TpvVulkanVendorID.NVIDIA:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('brdf_sheen_e_frag.spv');
  end;
  else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('brdf_sheen_e_fast_frag.spv');
  end;
 end;
 try
  fFragmentShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVertexShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fFragmentShaderModule,'main');

 fVulkanImage:=TpvVulkanImage.Create(aVulkanDevice,
                                     0,
                                     VK_IMAGE_TYPE_2D,
                                     ImageFormat,
                                     Width,
                                     Height,
                                     1,
                                     1,
                                     1,
                                     VK_SAMPLE_COUNT_1_BIT,
                                     VK_IMAGE_TILING_OPTIMAL,
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                     VK_SHARING_MODE_EXCLUSIVE,
                                     0,
                                     nil,
                                     VK_IMAGE_LAYOUT_UNDEFINED
                                    );

 aVulkanDevice.DebugUtils.SetObjectName(fVulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererSheenEBRDF.Image');

 MemoryRequirements:=aVulkanDevice.MemoryManager.GetImageMemoryRequirements(fVulkanImage.Handle,
                                                                            RequiresDedicatedAllocation,
                                                                            PrefersDedicatedAllocation);

 MemoryBlockFlags:=[];

 if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
  Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
 end;

 fMemoryBlock:=aVulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                               MemoryRequirements.size,
                                                               MemoryRequirements.alignment,
                                                               MemoryRequirements.memoryTypeBits,
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                               0,
                                                               0,
                                                               0,
                                                               0,
                                                               0,
                                                               0,
                                                               0,
                                                               TpvVulkanDeviceMemoryAllocationType.ImageOptimal,
                                                               @fVulkanImage.Handle,
                                                               pvAllocationGroupIDScene3DTexture,
                                                               'TpvScene3DRendererSheenEBRDF.MemoryBlock');
 if not assigned(fMemoryBlock) then begin
  raise EpvVulkanMemoryAllocationException.Create('Memory for texture couldn''t be allocated!');
 end;

 fMemoryBlock.AssociatedObject:=self;

 VulkanCheckResult(aVulkanDevice.Commands.BindImageMemory(aVulkanDevice.Handle,
                                                          fVulkanImage.Handle,
                                                          fMemoryBlock.MemoryChunk.Handle,
                                                          fMemoryBlock.Offset));

 Queue:=aVulkanDevice.GraphicsQueue;

 CommandPool:=TpvVulkanCommandPool.Create(aVulkanDevice,
                                          aVulkanDevice.GraphicsQueueFamilyIndex,
                                          TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  CommandBuffer:=TpvVulkanCommandBuffer.Create(CommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   Fence:=TpvVulkanFence.Create(aVulkanDevice);
   try

    FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
    ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    ImageSubresourceRange.baseMipLevel:=0;
    ImageSubresourceRange.levelCount:=1;
    ImageSubresourceRange.baseArrayLayer:=0;
    ImageSubresourceRange.layerCount:=1;
    fVulkanImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                           TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED),
                           TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                           @ImageSubresourceRange,
                           CommandBuffer,
                           Queue,
                           Fence,
                           true);

    fVulkanSampler:=aSampler;

    fVulkanImageView:=TpvVulkanImageView.Create(aVulkanDevice,
                                                fVulkanImage,
                                                TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D),
                                                ImageFormat,
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                0,
                                                1,
                                                0,
                                                1);

    aVulkanDevice.DebugUtils.SetObjectName(fVulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererSheenEBRDF.ImageView');

    fDescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                        fVulkanImageView.Handle,
                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

    ImageView:=TpvVulkanImageView.Create(aVulkanDevice,
                                         fVulkanImage,
                                         TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D),
                                         ImageFormat,
                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                         TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                         0,
                                         1,
                                         0,
                                         1);
    try

     aVulkanDevice.DebugUtils.SetObjectName(ImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererSheenEBRDF.ImageView');
     
     RenderPass:=TpvVulkanRenderPass.Create(aVulkanDevice);
     try

       RenderPass.AddSubpassDescription(0,
                                       VK_PIPELINE_BIND_POINT_GRAPHICS,
                                       [],
                                       [RenderPass.AddAttachmentReference(RenderPass.AddAttachmentDescription(0,
                                                                                                              ImageFormat,
                                                                                                              VK_SAMPLE_COUNT_1_BIT,
                                                                                                              VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                              VK_ATTACHMENT_STORE_OP_STORE,
                                                                                                              VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                              VK_IMAGE_LAYOUT_UNDEFINED,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                                                                                                             ),
                                                                           VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                          )],
                                       [],
                                       TpvInt32(VK_ATTACHMENT_UNUSED),
                                       []
                                      );
      RenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                      0,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                      TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                      TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                      TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
      RenderPass.AddSubpassDependency(0,
                                      VK_SUBPASS_EXTERNAL,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                      TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                      TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                      TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
      RenderPass.Initialize;

      RenderPass.ClearValues[0].color.float32[0]:=0.0;
      RenderPass.ClearValues[0].color.float32[1]:=0.0;
      RenderPass.ClearValues[0].color.float32[2]:=0.0;
      RenderPass.ClearValues[0].color.float32[3]:=0.0;

      FrameBufferColorAttachment:=TpvVulkanFrameBufferAttachment.Create(aVulkanDevice,
                                                                        fVulkanImage,
                                                                        ImageView,
                                                                        Width,
                                                                        Height,
                                                                        ImageFormat,
                                                                        false);
      try

       FrameBuffer:=TpvVulkanFrameBuffer.Create(aVulkanDevice,
                                                RenderPass,
                                                Width,
                                                Height,
                                                1,
                                                [FrameBufferColorAttachment],
                                                false);
       try

        PipelineLayout:=TpvVulkanPipelineLayout.Create(aVulkanDevice);
        try
         PipelineLayout.Initialize;

         Pipeline:=TpvVulkanGraphicsPipeline.Create(aVulkanDevice,
                                                    aVulkanPipelineCache,
                                                    0,
                                                    [],
                                                    PipelineLayout,
                                                    RenderPass,
                                                    0,
                                                    nil,
                                                    0);
         try

          Pipeline.AddStage(fVulkanPipelineShaderStageVertex);
          Pipeline.AddStage(fVulkanPipelineShaderStageFragment);

          Pipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
          Pipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

          Pipeline.ViewPortState.AddViewPort(0.0,0.0,Width,Height,0.0,1.0);
          Pipeline.ViewPortState.AddScissor(0,0,Width,Height);

          Pipeline.RasterizationState.DepthClampEnable:=false;
          Pipeline.RasterizationState.RasterizerDiscardEnable:=false;
          Pipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
          Pipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
          Pipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
          Pipeline.RasterizationState.DepthBiasEnable:=false;
          Pipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
          Pipeline.RasterizationState.DepthBiasClamp:=0.0;
          Pipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
          Pipeline.RasterizationState.LineWidth:=1.0;

          Pipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
          Pipeline.MultisampleState.SampleShadingEnable:=false;
          Pipeline.MultisampleState.MinSampleShading:=0.0;
          Pipeline.MultisampleState.CountSampleMasks:=0;
          Pipeline.MultisampleState.AlphaToCoverageEnable:=false;
          Pipeline.MultisampleState.AlphaToOneEnable:=false;

          Pipeline.ColorBlendState.LogicOpEnable:=false;
          Pipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
          Pipeline.ColorBlendState.BlendConstants[0]:=0.0;
          Pipeline.ColorBlendState.BlendConstants[1]:=0.0;
          Pipeline.ColorBlendState.BlendConstants[2]:=0.0;
          Pipeline.ColorBlendState.BlendConstants[3]:=0.0;
          Pipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                VK_BLEND_FACTOR_ZERO,
                                                                VK_BLEND_FACTOR_ZERO,
                                                                VK_BLEND_OP_ADD,
                                                                VK_BLEND_FACTOR_ZERO,
                                                                VK_BLEND_FACTOR_ZERO,
                                                                VK_BLEND_OP_ADD,
                                                                TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

          Pipeline.DepthStencilState.DepthTestEnable:=false;
          Pipeline.DepthStencilState.DepthWriteEnable:=false;
          Pipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
          Pipeline.DepthStencilState.DepthBoundsTestEnable:=false;
          Pipeline.DepthStencilState.StencilTestEnable:=false;

          Pipeline.Initialize;

          Pipeline.FreeMemory;

          CommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

          CommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

          RenderPass.BeginRenderPass(CommandBuffer,FrameBuffer,VK_SUBPASS_CONTENTS_INLINE,0,0,Width,Height);

          CommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,Pipeline.Handle);

          CommandBuffer.CmdDraw(3,1,0,0);

          RenderPass.EndRenderPass(CommandBuffer);

          CommandBuffer.EndRecording;

          CommandBuffer.Execute(Queue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),nil,nil,Fence,true);

         finally
          FreeAndNil(Pipeline);
         end;

        finally
         FreeAndNil(PipelineLayout);
        end;

       finally
        FreeAndNil(FrameBuffer);
       end;

      finally
       FreeAndNil(FrameBufferColorAttachment);
      end;

     finally
      FreeAndNil(RenderPass);
     end;

    finally
     FreeAndNil(ImageView);
    end;

   finally
    FreeAndNil(Fence);
   end;

  finally
   FreeAndNil(CommandBuffer);
  end;

 finally
  FreeAndNil(CommandPool);
 end;

end;

destructor TpvScene3DRendererSheenEBRDF.Destroy;
begin
 FreeAndNil(fMemoryBlock);
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fVulkanImage);
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVertexShaderModule);
 FreeAndNil(fFragmentShaderModule);
 inherited Destroy;
end;

end.
