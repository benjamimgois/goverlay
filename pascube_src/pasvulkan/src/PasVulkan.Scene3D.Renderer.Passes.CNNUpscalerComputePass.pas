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
unit PasVulkan.Scene3D.Renderer.Passes.CNNUpscalerComputePass;
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
     PasVulkan.Scene3D.Renderer.Instance;

type { TpvScene3DRendererPassesCNNUpscalerComputePass }
     TpvScene3DRendererPassesCNNUpscalerComputePass=class(TpvFrameGraph.TComputePass)
      private
       const MODEL_MAGIC=TpvUInt32($554e4e43); // 'CNNU' little-endian
             MODEL_VERSION=TpvUInt32(1);
             MAX_CNN_LAYERS=8;
       type TPushConstants=packed record
             p0:TpvInt32;
             p1:TpvInt32;
             p2:TpvInt32;
             p3:TpvInt32;
             p4:TpvInt32;
             p5:TpvInt32;
             p6:TpvInt32;
             p7:TpvInt32;
            end;
            TCNNLayerInfo=packed record
             InputChannels:TpvInt32;
             OutputChannels:TpvInt32;
             KernelSize:TpvInt32;
             Padding:TpvInt32;
             UseReLU:TpvInt32;
             WeightCount:TpvInt32;
             BiasCount:TpvInt32;
             WeightOffset:TpvSizeInt;
             BiasOffset:TpvSizeInt;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceInput:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceOutput:TpvFrameGraph.TPass.TUsedImageResource;
      private
       // Model data
       fModelLoaded:Boolean;
       fScaleFactor:TpvInt32;
       fInChannels:TpvInt32;
       fOutChannels:TpvInt32;
       fNumLayers:TpvInt32;
       fLayers:array[0..MAX_CNN_LAYERS-1] of TCNNLayerInfo;
      private
       // Shader modules
       fImageToBufferShaderModule:TpvVulkanShaderModule;
       fConvForwardShaderModule:TpvVulkanShaderModule;
       fPixelShuffleShaderModule:TpvVulkanShaderModule;
       fBufferToImageShaderModule:TpvVulkanShaderModule;
       // Pipeline shader stages
       fImageToBufferShaderStage:TpvVulkanPipelineShaderStage;
       fConvForwardShaderStage:TpvVulkanPipelineShaderStage;
       fPixelShuffleShaderStage:TpvVulkanPipelineShaderStage;
       fBufferToImageShaderStage:TpvVulkanPipelineShaderStage;
      private
       // Transfer resources for weight upload
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       // Weight and bias GPU buffers (persistent, uploaded once)
       fWeightBuffer:TpvVulkanBuffer;
       fBiasBuffer:TpvVulkanBuffer;
       fTotalWeightBytes:TpvSizeInt;
       fTotalBiasBytes:TpvSizeInt;
      private
       // Descriptor set layouts
       fImageToBufferDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fConvForwardDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fBufferToImageDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       // Pipeline layouts
       fImageToBufferPipelineLayout:TpvVulkanPipelineLayout;
       fConvForwardPipelineLayout:TpvVulkanPipelineLayout;
       fBufferToImagePipelineLayout:TpvVulkanPipelineLayout;
       // Compute pipelines
       fImageToBufferPipeline:TpvVulkanComputePipeline;
       fConvForwardPipeline:TpvVulkanComputePipeline;
       fPixelShufflePipeline:TpvVulkanComputePipeline;
       fBufferToImagePipeline:TpvVulkanComputePipeline;
      private
       // Activation buffers (GPU-only, resolution-dependent)
       fActivationBuffers:array[0..MAX_CNN_LAYERS] of TpvVulkanBuffer;
       fPixelShuffleOutputBuffer:TpvVulkanBuffer;
       // Descriptor pool and sets
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fImageToBufferDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fConvForwardDescriptorSets:array[0..MAX_CNN_LAYERS-1] of TpvVulkanDescriptorSet;
       fPixelShuffleDescriptorSet:TpvVulkanDescriptorSet;
       fBufferToImageDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       // Image views
       fInputImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fOutputImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
     end;

implementation

{ TpvScene3DRendererPassesCNNUpscalerComputePass }

constructor TpvScene3DRendererPassesCNNUpscalerComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='CNNUpscalerComputePass';

 fModelLoaded:=false;

 fResourceInput:=AddImageInput(fInstance.LastOutputResource.ResourceType.Name,
                               fInstance.LastOutputResource.Resource.Name,
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []
                              );

 fResourceOutput:=AddImageOutput('resourcetype_color_fullres_optimized_non_alpha',
                                 'resource_upsampled_color',
                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare),
                                 []
                                );

 fInstance.LastOutputResource:=fResourceOutput;

end;

destructor TpvScene3DRendererPassesCNNUpscalerComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.AcquirePersistentResources;
var Stream:TStream;
    Magic,Version:TpvUInt32;
    Colorspace,LayerIndex:TpvInt32;
    WeightData,BiasData:TpvFloatDynamicArray;
    TotalWeightFloats,TotalBiasFloats:TpvSizeInt;
    CurrentWeightOffset,CurrentBiasOffset:TpvSizeInt;
    ModelFileName:TpvRawByteString;
begin

 inherited AcquirePersistentResources;

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(FrameGraph.TransferQueue.CommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(fInstance.Renderer.VulkanDevice);

 // Load shader modules

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cnn_image_to_buffer_comp.spv');
 try
  fImageToBufferShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fImageToBufferShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'CNNUpscaler.ImageToBufferShader');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cnn_conv_forward_comp.spv');
 try
  fConvForwardShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fConvForwardShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'CNNUpscaler.ConvForwardShader');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cnn_pixel_shuffle_comp.spv');
 try
  fPixelShuffleShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPixelShuffleShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'CNNUpscaler.PixelShuffleShader');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cnn_buffer_to_image_comp.spv');
 try
  fBufferToImageShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fBufferToImageShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'CNNUpscaler.BufferToImageShader');

 fImageToBufferShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fImageToBufferShaderModule,'main');
 fConvForwardShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fConvForwardShaderModule,'main');
 fPixelShuffleShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fPixelShuffleShaderModule,'main');
 fBufferToImageShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fBufferToImageShaderModule,'main');

 // Determine model file name based on renderer settings

 case fInstance.Renderer.AIUpscaleMode of
  TpvScene3DRendererAIUpscaleMode.Factor2X:begin
   ModelFileName:='model_2x_srgb_';
  end;
  TpvScene3DRendererAIUpscaleMode.Factor4X:begin
   ModelFileName:='model_4x_srgb_';
  end;
  else begin
   ModelFileName:='model_2x_srgb_';
  end;
 end;

 case fInstance.Renderer.AIUpscaleQuality of
  TpvScene3DRendererAIUpscaleQuality.Low:begin
   ModelFileName:=ModelFileName+'low.bin';
  end;
  TpvScene3DRendererAIUpscaleQuality.Mid:begin
   ModelFileName:=ModelFileName+'mid.bin';
  end;
  TpvScene3DRendererAIUpscaleQuality.High:begin
   ModelFileName:=ModelFileName+'high.bin';
  end;
  else begin
   ModelFileName:=ModelFileName+'low.bin';
  end;
 end;

 // Load and parse model binary

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile(String(ModelFileName));
 try

  repeat

   Stream.ReadBuffer(Magic,SizeOf(TpvUInt32));
   Stream.ReadBuffer(Version,SizeOf(TpvUInt32));

   if (Magic<>MODEL_MAGIC) or (Version<>MODEL_VERSION) then begin
    fModelLoaded:=false;
    break;
   end;

   Stream.ReadBuffer(fScaleFactor,SizeOf(TpvInt32));
   Stream.ReadBuffer(fInChannels,SizeOf(TpvInt32));
   Stream.ReadBuffer(fOutChannels,SizeOf(TpvInt32));
   Stream.ReadBuffer(Colorspace,SizeOf(TpvInt32));
   Stream.ReadBuffer(fNumLayers,SizeOf(TpvInt32));

   if (fNumLayers<1) or (fNumLayers>MAX_CNN_LAYERS) then begin
    fModelLoaded:=false;
    break;
   end;

   // First pass: read layer configs and calculate total weight/bias sizes
   TotalWeightFloats:=0;
   TotalBiasFloats:=0;

   for LayerIndex:=0 to fNumLayers-1 do begin
    Stream.ReadBuffer(fLayers[LayerIndex].InputChannels,SizeOf(TpvInt32));
    Stream.ReadBuffer(fLayers[LayerIndex].OutputChannels,SizeOf(TpvInt32));
    Stream.ReadBuffer(fLayers[LayerIndex].KernelSize,SizeOf(TpvInt32));
    Stream.ReadBuffer(fLayers[LayerIndex].UseReLU,SizeOf(TpvInt32));
    fLayers[LayerIndex].Padding:=fLayers[LayerIndex].KernelSize div 2;
    fLayers[LayerIndex].WeightCount:=fLayers[LayerIndex].OutputChannels*fLayers[LayerIndex].InputChannels*fLayers[LayerIndex].KernelSize*fLayers[LayerIndex].KernelSize;
    fLayers[LayerIndex].BiasCount:=fLayers[LayerIndex].OutputChannels;
    fLayers[LayerIndex].WeightOffset:=TotalWeightFloats*SizeOf(TpvFloat);
    fLayers[LayerIndex].BiasOffset:=TotalBiasFloats*SizeOf(TpvFloat);
    inc(TotalWeightFloats,fLayers[LayerIndex].WeightCount);
    inc(TotalBiasFloats,fLayers[LayerIndex].BiasCount);
    // Skip past the weight and bias data for now (we'll re-read below)
    Stream.Seek(TpvInt64(fLayers[LayerIndex].WeightCount+fLayers[LayerIndex].BiasCount)*SizeOf(TpvFloat),soCurrent);
   end;

   fTotalWeightBytes:=TotalWeightFloats*SizeOf(TpvFloat);
   fTotalBiasBytes:=TotalBiasFloats*SizeOf(TpvFloat);

   // Second pass: read weights and biases into arrays
   WeightData:=nil;
   SetLength(WeightData,TotalWeightFloats);
   try

    BiasData:=nil;
    SetLength(BiasData,TotalBiasFloats);
    try

     // Seek back to start of layer data (after header)
     Stream.Position:=7*SizeOf(TpvInt32); // header: magic + version + scale + in_ch + out_ch + colorspace + num_layers

     CurrentWeightOffset:=0;
     CurrentBiasOffset:=0;

     for LayerIndex:=0 to fNumLayers-1 do begin
      // Skip layer header (4 ints already read)
      Stream.Seek(4*SizeOf(TpvInt32),soCurrent);
      // Read weights
      Stream.ReadBuffer(WeightData[CurrentWeightOffset],fLayers[LayerIndex].WeightCount*SizeOf(TpvFloat));
      inc(CurrentWeightOffset,fLayers[LayerIndex].WeightCount);
      // Read biases
      Stream.ReadBuffer(BiasData[CurrentBiasOffset],fLayers[LayerIndex].BiasCount*SizeOf(TpvFloat));
      inc(CurrentBiasOffset,fLayers[LayerIndex].BiasCount);
     end;

     // Create weight buffer and upload data
     fWeightBuffer:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                           Max(fTotalWeightBytes,4),
                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                           [],
                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           [],
                                           0,
                                           pvAllocationGroupIDScene3DStatic,
                                           'CNNUpscaler.WeightBuffer'
                                          );
     fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fWeightBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'CNNUpscaler.WeightBuffer');

     fWeightBuffer.UploadData(fInstance.Renderer.VulkanDevice.TransferQueue,
                              fVulkanTransferCommandBuffer,
                              fVulkanTransferCommandBufferFence,
                              WeightData[0],
                              0,
                              fTotalWeightBytes);

     // Create bias buffer and upload data
     fBiasBuffer:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                         Max(fTotalBiasBytes,4),
                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                         [],
                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                         0,
                                         0,
                                         0,
                                         0,
                                         0,
                                         0,
                                         0,
                                         [],
                                         0,
                                         pvAllocationGroupIDScene3DStatic,
                                         'CNNUpscaler.BiasBuffer'
                                        );
     fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fBiasBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'CNNUpscaler.BiasBuffer');

     fBiasBuffer.UploadData(fInstance.Renderer.VulkanDevice.TransferQueue,
                            fVulkanTransferCommandBuffer,
                            fVulkanTransferCommandBufferFence,
                            BiasData[0],
                            0,
                            fTotalBiasBytes);

    finally
     BiasData:=nil;
    end;

   finally
    WeightData:=nil;
   end;

   fModelLoaded:=true;

   break;

  until true;

 finally
  Stream.Free;
 end;

end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fBiasBuffer);
 FreeAndNil(fWeightBuffer);
 FreeAndNil(fBufferToImageShaderStage);
 FreeAndNil(fPixelShuffleShaderStage);
 FreeAndNil(fConvForwardShaderStage);
 FreeAndNil(fImageToBufferShaderStage);
 FreeAndNil(fBufferToImageShaderModule);
 FreeAndNil(fPixelShuffleShaderModule);
 FreeAndNil(fConvForwardShaderModule);
 FreeAndNil(fImageToBufferShaderModule);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.AcquireVolatileResources;
var InFlightFrameIndex,LayerIndex:TpvInt32;
    ScaledWidth,ScaledHeight:TpvInt32;
    FullWidth,FullHeight:TpvInt32;
    CountViews:TpvInt32;
    ActivationChannels:TpvInt32;
    BufferSize:TVkDeviceSize;
    TotalDescriptorSets:TpvInt32;
    TotalStorageBufferDescriptors:TpvInt32;
begin

 inherited AcquireVolatileResources;

 if not fModelLoaded then begin
  exit;
 end;

 ScaledWidth:=fInstance.ScaledWidth;
 ScaledHeight:=fInstance.ScaledHeight;
 FullWidth:=fInstance.Width;
 FullHeight:=fInstance.Height;
 CountViews:=fInstance.CountSurfaceViews;

 ////////////////////////////
 // Descriptor set layouts //
 ////////////////////////////

 // ImageToBuffer: binding 0 = sampler2DArray, binding 1 = SSBO
 fImageToBufferDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fImageToBufferDescriptorSetLayout.AddBinding(0,
                                              VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                              []);
 fImageToBufferDescriptorSetLayout.AddBinding(1,
                                              VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                              []);
 fImageToBufferDescriptorSetLayout.Initialize;

 // ConvForward / PixelShuffle: binding 0-3 = SSBO
 fConvForwardDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fConvForwardDescriptorSetLayout.AddBinding(0,
                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                            []);
 fConvForwardDescriptorSetLayout.AddBinding(1,
                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                            []);
 fConvForwardDescriptorSetLayout.AddBinding(2,
                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                            []);
 fConvForwardDescriptorSetLayout.AddBinding(3,
                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                            []);
 fConvForwardDescriptorSetLayout.Initialize;

 // BufferToImage: binding 0 = SSBO, binding 1 = storage image
 fBufferToImageDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fBufferToImageDescriptorSetLayout.AddBinding(0,
                                              VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                              []);
 fBufferToImageDescriptorSetLayout.AddBinding(1,
                                              VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                              []);
 fBufferToImageDescriptorSetLayout.Initialize;

 //////////////////////
 // Pipeline layouts //
 //////////////////////

 fImageToBufferPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fImageToBufferPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fImageToBufferPipelineLayout.AddDescriptorSetLayout(fImageToBufferDescriptorSetLayout);
 fImageToBufferPipelineLayout.Initialize;

 fConvForwardPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fConvForwardPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fConvForwardPipelineLayout.AddDescriptorSetLayout(fConvForwardDescriptorSetLayout);
 fConvForwardPipelineLayout.Initialize;

 fBufferToImagePipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fBufferToImagePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fBufferToImagePipelineLayout.AddDescriptorSetLayout(fBufferToImageDescriptorSetLayout);
 fBufferToImagePipelineLayout.Initialize;

 ///////////////////////
 // Compute pipelines //
 ///////////////////////

 fImageToBufferPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                         fInstance.Renderer.VulkanPipelineCache,
                                                         0,
                                                         fImageToBufferShaderStage,
                                                         fImageToBufferPipelineLayout,
                                                         nil,
                                                         0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fImageToBufferPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'CNNUpscaler.ImageToBufferPipeline');

 fConvForwardPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                       fInstance.Renderer.VulkanPipelineCache,
                                                       0,
                                                       fConvForwardShaderStage,
                                                       fConvForwardPipelineLayout,
                                                       nil,
                                                       0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fConvForwardPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'CNNUpscaler.ConvForwardPipeline');

 fPixelShufflePipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                        fInstance.Renderer.VulkanPipelineCache,
                                                        0,
                                                        fPixelShuffleShaderStage,
                                                        fConvForwardPipelineLayout, // Same layout as ConvForward (4x SSBO)
                                                        nil,
                                                        0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPixelShufflePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'CNNUpscaler.PixelShufflePipeline');

 fBufferToImagePipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                         fInstance.Renderer.VulkanPipelineCache,
                                                         0,
                                                         fBufferToImageShaderStage,
                                                         fBufferToImagePipelineLayout,
                                                         nil,
                                                         0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fBufferToImagePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'CNNUpscaler.BufferToImagePipeline');

 ////////////////////////
 // Activation buffers //
 ////////////////////////

 // act[0]: input (inChannels * H * W * views)
 BufferSize:=TpvInt64(CountViews)*fInChannels*ScaledHeight*ScaledWidth*SizeOf(TpvFloat);
 fActivationBuffers[0]:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                               Max(BufferSize,4),
                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                               [],
                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                               0,
                                               0,
                                               0,
                                               0,
                                               0,
                                               0,
                                               0,
                                               [],
                                               0,
                                               pvAllocationGroupIDScene3DDynamic,
                                               'CNNUpscaler.Activation[0]'
                                              );

 // act[1..numLayers]: intermediate and final conv outputs
 for LayerIndex:=0 to fNumLayers-1 do begin
  ActivationChannels:=fLayers[LayerIndex].OutputChannels;
  BufferSize:=TpvInt64(CountViews)*ActivationChannels*ScaledHeight*ScaledWidth*SizeOf(TpvFloat);
  fActivationBuffers[LayerIndex+1]:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                                           Max(BufferSize,4),
                                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                           [],
                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                           0,
                                                           0,
                                                           0,
                                                           0,
                                                           0,
                                                           0,
                                                           0,
                                                           [],
                                                           0,
                                                           pvAllocationGroupIDScene3DDynamic,
                                                           'CNNUpscaler.Activation['+IntToStr(LayerIndex+1)+']'
                                                          );
 end;

 // Pixel shuffle output (HR resolution)
 BufferSize:=TpvInt64(CountViews)*fOutChannels*FullHeight*FullWidth*SizeOf(TpvFloat);
 fPixelShuffleOutputBuffer:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                                   Max(BufferSize,4),
                                                   TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                   TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                   [],
                                                   TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                   0,
                                                   0,
                                                   0,
                                                   0,
                                                   0,
                                                   0,
                                                   0,
                                                   [],
                                                   0,
                                                   pvAllocationGroupIDScene3DDynamic,
                                                   'CNNUpscaler.PixelShuffleOutput'
                                                  );

 /////////////////////
 // Descriptor pool //
 /////////////////////

 TotalDescriptorSets:=((FrameGraph.CountInFlightFrames*2)+fNumLayers)+1;
 TotalStorageBufferDescriptors:=((FrameGraph.CountInFlightFrames*2)+(fNumLayers*4))+4;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       TotalDescriptorSets);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,FrameGraph.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TotalStorageBufferDescriptors);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,FrameGraph.CountInFlightFrames);
 fVulkanDescriptorPool.Initialize;

 //////////////////////
 // Descriptor sets  //
 //////////////////////

 // ImageToBuffer descriptor sets (per-frame, different input images)
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

  fInputImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                  fResourceInput.VulkanImages[InFlightFrameIndex],
                                                                  VK_IMAGE_VIEW_TYPE_2D_ARRAY,
                                                                  TpvFrameGraph.TImageResourceType(fResourceInput.ResourceType).Format,
                                                                  VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                  VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                  VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                  VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                  TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                  0,
                                                                  1,
                                                                  0,
                                                                  CountViews
                                                                 );

  fImageToBufferDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                                  fImageToBufferDescriptorSetLayout);
  fImageToBufferDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                       [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                      fInputImageViews[InFlightFrameIndex].Handle,
                                                                                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                       [],
                                                                       [],
                                                                       false
                                                                      );
  fImageToBufferDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                       [],
                                                                       [fActivationBuffers[0].DescriptorBufferInfo],
                                                                       [],
                                                                       false
                                                                      );
  fImageToBufferDescriptorSets[InFlightFrameIndex].Flush;
 end;

 // ConvForward descriptor sets (shared, per-layer)
 for LayerIndex:=0 to fNumLayers-1 do begin
  fConvForwardDescriptorSets[LayerIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                       fConvForwardDescriptorSetLayout);
  // binding 0: weights (sub-range for this layer)
  fConvForwardDescriptorSets[LayerIndex].WriteToDescriptorSet(0,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                              [],
                                                              [TVkDescriptorBufferInfo.Create(fWeightBuffer.Handle,
                                                                                             fLayers[LayerIndex].WeightOffset,
                                                                                             fLayers[LayerIndex].WeightCount*SizeOf(TpvFloat))],
                                                              [],
                                                              false
                                                             );
  // binding 1: biases (sub-range for this layer)
  fConvForwardDescriptorSets[LayerIndex].WriteToDescriptorSet(1,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                              [],
                                                              [TVkDescriptorBufferInfo.Create(fBiasBuffer.Handle,
                                                                                             fLayers[LayerIndex].BiasOffset,
                                                                                             fLayers[LayerIndex].BiasCount*SizeOf(TpvFloat))],
                                                              [],
                                                              false
                                                             );
  // binding 2: input activation
  fConvForwardDescriptorSets[LayerIndex].WriteToDescriptorSet(2,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                              [],
                                                              [fActivationBuffers[LayerIndex].DescriptorBufferInfo],
                                                              [],
                                                              false
                                                             );
  // binding 3: output activation
  fConvForwardDescriptorSets[LayerIndex].WriteToDescriptorSet(3,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                              [],
                                                              [fActivationBuffers[LayerIndex+1].DescriptorBufferInfo],
                                                              [],
                                                              false
                                                             );
  fConvForwardDescriptorSets[LayerIndex].Flush;
 end;

 // PixelShuffle descriptor set (shared)
 fPixelShuffleDescriptorSet:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                           fConvForwardDescriptorSetLayout);
 // binding 0: input (last conv output)
 fPixelShuffleDescriptorSet.WriteToDescriptorSet(0,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                 [],
                                                 [fActivationBuffers[fNumLayers].DescriptorBufferInfo],
                                                 [],
                                                 false
                                                );
 // binding 1: output (HR resolution)
 fPixelShuffleDescriptorSet.WriteToDescriptorSet(1,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                 [],
                                                 [fPixelShuffleOutputBuffer.DescriptorBufferInfo],
                                                 [],
                                                 false
                                                );
 // binding 2,3: dummy (reuse weight buffer)
 fPixelShuffleDescriptorSet.WriteToDescriptorSet(2,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                 [],
                                                 [fWeightBuffer.DescriptorBufferInfo],
                                                 [],
                                                 false
                                                );
 fPixelShuffleDescriptorSet.WriteToDescriptorSet(3,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                 [],
                                                 [fWeightBuffer.DescriptorBufferInfo],
                                                 [],
                                                 false
                                                );
 fPixelShuffleDescriptorSet.Flush;

 // BufferToImage descriptor sets (per-frame, different output images)
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

  fOutputImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                   fResourceOutput.VulkanImages[InFlightFrameIndex],
                                                                   VK_IMAGE_VIEW_TYPE_2D_ARRAY,
                                                                   TpvFrameGraph.TImageResourceType(fResourceOutput.ResourceType).Format,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                   0,
                                                                   1,
                                                                   0,
                                                                   CountViews
                                                                  );

  fBufferToImageDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                                  fBufferToImageDescriptorSetLayout);
  // binding 0: input SSBO (pixel shuffle output)
  fBufferToImageDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                        0,
                                                                        1,
                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                        [],
                                                                        [fPixelShuffleOutputBuffer.DescriptorBufferInfo],
                                                                        [],
                                                                        false
                                                                       );
  // binding 1: output storage image
  fBufferToImageDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                        0,
                                                                        1,
                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                        [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                       fOutputImageViews[InFlightFrameIndex].Handle,
                                                                                                       VK_IMAGE_LAYOUT_GENERAL)],
                                                                        [],
                                                                        [],
                                                                        false
                                                                       );
  fBufferToImageDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,LayerIndex:TpvInt32;
begin

 FreeAndNil(fBufferToImagePipeline);
 FreeAndNil(fPixelShufflePipeline);
 FreeAndNil(fConvForwardPipeline);
 FreeAndNil(fImageToBufferPipeline);

 FreeAndNil(fBufferToImagePipelineLayout);
 FreeAndNil(fConvForwardPipelineLayout);
 FreeAndNil(fImageToBufferPipelineLayout);

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fBufferToImageDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fOutputImageViews[InFlightFrameIndex]);
  FreeAndNil(fImageToBufferDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fInputImageViews[InFlightFrameIndex]);
 end;

 FreeAndNil(fPixelShuffleDescriptorSet);

 for LayerIndex:=0 to fNumLayers-1 do begin
  FreeAndNil(fConvForwardDescriptorSets[LayerIndex]);
 end;

 FreeAndNil(fBufferToImageDescriptorSetLayout);
 FreeAndNil(fConvForwardDescriptorSetLayout);
 FreeAndNil(fImageToBufferDescriptorSetLayout);

 FreeAndNil(fVulkanDescriptorPool);

 FreeAndNil(fPixelShuffleOutputBuffer);
 for LayerIndex:=fNumLayers downto 0 do begin
  FreeAndNil(fActivationBuffers[LayerIndex]);
 end;

 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesCNNUpscalerComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var LayerIndex:TpvInt32;
    ScaledWidth,ScaledHeight:TpvInt32;
    FullWidth,FullHeight:TpvInt32;
    CountViews:TpvInt32;
    PushConstants:TPushConstants;
    MemoryBarrier:TVkMemoryBarrier;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 if not fModelLoaded then begin
  exit;
 end;

 ScaledWidth:=fInstance.ScaledWidth;
 ScaledHeight:=fInstance.ScaledHeight;
 FullWidth:=fInstance.Width;
 FullHeight:=fInstance.Height;
 CountViews:=fInstance.CountSurfaceViews;

 // Prepare memory barrier for compute-to-compute synchronization
 FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
 MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
 MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);

 //////////////////////////////////////
 // Step 1: Image -> Buffer (sRGB)   //
 //////////////////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fImageToBufferPipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fImageToBufferPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fImageToBufferDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  FillChar(PushConstants,SizeOf(TPushConstants),#0);
  PushConstants.p0:=ScaledHeight;
  PushConstants.p1:=ScaledWidth;

  aCommandBuffer.CmdPushConstants(fImageToBufferPipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'CNNUpscaler.ImageToBuffer');
  end;
  aCommandBuffer.CmdDispatch(Max(1,(ScaledWidth+15) shr 4),
                             Max(1,(ScaledHeight+15) shr 4),
                             CountViews);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

  // Barrier: imageToBuffer write -> conv read
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    1,@MemoryBarrier,
                                    0,nil,
                                    0,nil);

 end;

 //////////////////////////////////////////
 // Step 2: Conv forward (N layers)      //
 //////////////////////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fConvForwardPipeline.Handle);

  for LayerIndex:=0 to fNumLayers-1 do begin

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        fConvForwardPipelineLayout.Handle,
                                        0,
                                        1,
                                        @fConvForwardDescriptorSets[LayerIndex].Handle,
                                        0,
                                        nil);

   FillChar(PushConstants,SizeOf(TPushConstants),#0);
   PushConstants.p0:=fLayers[LayerIndex].InputChannels;
   PushConstants.p1:=fLayers[LayerIndex].OutputChannels;
   PushConstants.p2:=fLayers[LayerIndex].KernelSize;
   PushConstants.p3:=fLayers[LayerIndex].Padding;
   PushConstants.p4:=ScaledHeight;
   PushConstants.p5:=ScaledWidth; 
   PushConstants.p6:=CountViews; // batch = views
   PushConstants.p7:=fLayers[LayerIndex].UseReLU;

   aCommandBuffer.CmdPushConstants(fConvForwardPipelineLayout.Handle,
                                   TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(TPushConstants),
                                   @PushConstants);

   if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
    fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'CNNUpscaler.Conv['+IntToStr(LayerIndex)+']');
   end;
   aCommandBuffer.CmdDispatch(Max(1,(ScaledWidth+15) shr 4),
                              Max(1,(ScaledHeight+15) shr 4),
                              CountViews*fLayers[LayerIndex].OutputChannels);
   if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
    fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
   end;

   // Barrier between conv layers
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     1,@MemoryBarrier,
                                     0,nil,
                                     0,nil);

  end;

 end;

 /////////////////////////////
 // Step 3: Pixel shuffle   //
 /////////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPixelShufflePipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fConvForwardPipelineLayout.Handle, // Same layout
                                       0,
                                       1,
                                       @fPixelShuffleDescriptorSet.Handle,
                                       0,
                                       nil);

  FillChar(PushConstants,SizeOf(TPushConstants),#0);
  PushConstants.p0:=fScaleFactor;
  PushConstants.p1:=fOutChannels; // 3 for RGB
  PushConstants.p4:=ScaledHeight; // LR height
  PushConstants.p5:=ScaledWidth;  // LR width
  PushConstants.p6:=CountViews;   // batch = views

  aCommandBuffer.CmdPushConstants(fConvForwardPipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'CNNUpscaler.PixelShuffle');
  end;
  aCommandBuffer.CmdDispatch(Max(1,(FullWidth+15) shr 4),
                             Max(1,(FullHeight+15) shr 4),
                             CountViews*fOutChannels);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

  // Barrier: pixel shuffle write -> bufferToImage read
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    1,@MemoryBarrier,
                                    0,nil,
                                    0,nil);

 end;

 /////////////////////////////////////////
 // Step 4: Buffer -> Image (linear)    //
 /////////////////////////////////////////

 begin

  // Transition output image from SHADER_READ_ONLY_OPTIMAL to GENERAL for storage image write
  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=0;
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fResourceOutput.VulkanImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fBufferToImagePipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fBufferToImagePipelineLayout.Handle,
                                       0,
                                       1,
                                       @fBufferToImageDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  FillChar(PushConstants,SizeOf(TPushConstants),#0);
  PushConstants.p0:=FullHeight;
  PushConstants.p1:=FullWidth;

  aCommandBuffer.CmdPushConstants(fBufferToImagePipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'CNNUpscaler.BufferToImage');
  end;
  aCommandBuffer.CmdDispatch(Max(1,(FullWidth+15) shr 4),
                             Max(1,(FullHeight+15) shr 4),
                             CountViews);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

  // Transition output image back from GENERAL to SHADER_READ_ONLY_OPTIMAL
  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fResourceOutput.VulkanImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

end;

end.
