unit UnitTextOverlay;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}
{$m+}

interface

uses SysUtils,
     Classes,
     UnitRegisteredExamplesList,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Streams,
     PasVulkan.TrueTypeFont,
     PasVulkan.Font;

const TextOverlayBufferCharSize=65536;

type PTextOverlayBufferCharVertex=^TTextOverlayBufferCharVertex;
     TTextOverlayBufferCharVertex=packed record
      x,y:TpvFloat;
      u,v,w:TpvFloat;
      br,bg,bb,ba:TpvFloat;
      fr,fg,fb,fa:TpvFloat;
     end;

     PTextOverlayBufferCharVertices=^TTextOverlayBufferCharVertices;
     TTextOverlayBufferCharVertices=array[0..3] of TTextOverlayBufferCharVertex;

     PTextOverlayBufferChar=^TTextOverlayBufferChar;
     TTextOverlayBufferChar=packed record
      Vertices:TTextOverlayBufferCharVertices;
     end;

     PTextOverlayBufferChars=^TTextOverlayBufferChars;
     TTextOverlayBufferChars=array[0..TextOverlayBufferCharSize-1] of TTextOverlayBufferChar;

     PTextOverlayBufferCharsBuffers=^TTextOverlayBufferCharsBuffers;
     TTextOverlayBufferCharsBuffers=array[0..MaxInFlightFrames-1] of TTextOverlayBufferChars;

     PTextOverlayIndices=^TTextOverlayIndices;
     TTextOverlayIndices=array[0..(TextOverlayBufferCharSize*6)-1] of TpvInt32;

     TTextOverlayAlignment=
      (
       toaLeft,
       toaCenter,
       toaRight
      );

     PTextOverlayUniformBuffer=^TTextOverlayUniformBuffer;
     TTextOverlayUniformBuffer=record
      uThreshold:TpvFloat;
     end;

     TTextOverlay=class
      private
       fLoaded:boolean;
       fUpdateBufferIndex:TpvInt32;
       fBufferChars:PTextOverlayBufferChars;
       fBufferCharsBuffers:TTextOverlayBufferCharsBuffers;
       fCountBufferChars:TpvInt32;
       fCountBufferCharsBuffers:array[0..MaxInFlightFrames-1] of TpvInt32;
       fIndices:TTextOverlayIndices;
       fTextOverlayVertexShaderModule:TpvVulkanShaderModule;
       fTextOverlayFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageTriangleVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageTriangleFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanVertexBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fVulkanIndexBuffer:TpvVulkanBuffer;
       fVulkanUniformBuffer:TpvVulkanBuffer;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSet:TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanCommandPool:TpvVulkanCommandPool;
       fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fUniformBuffer:TTextOverlayUniformBuffer;
       fFontTexture:TpvVulkanTexture;
       fFontCharWidth:TpvFloat;
       fFontCharHeight:TpvFloat;
       fInvWidth:TpvFloat;
       fInvHeight:TpvFloat;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Load;
       procedure Unload;
       procedure AfterCreateSwapChain;
       procedure BeforeDestroySwapChain;
       procedure Reset;
       procedure AddText(const pX,pY,aSize:TpvFloat;const aAlignment:TTextOverlayAlignment;const aText:TpvApplicationRawByteString;const pBR:TpvFloat=1.0;const pBG:TpvFloat=1.0;const pBB:TpvFloat=1.0;const pBA:TpvFloat=0.0;const pFR:TpvFloat=1.0;const pFG:TpvFloat=1.0;const pFB:TpvFloat=1.0;const pFA:TpvFloat=1.0);
       procedure PreUpdate(const aDeltaTime:double);
       procedure PostUpdate(const aDeltaTime:double);
       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
      published
       property FontCharWidth:TpvFloat read fFontCharWidth;
       property FontCharHeight:TpvFloat read fFontCharHeight;
     end;

implementation

uses PasVulkan.Assets;

constructor TTextOverlay.Create;
var Index:TpvInt32;
begin
 inherited Create;

 fLoaded:=false;

 for Index:=0 to TextOverlayBufferCharSize-1 do begin
  fIndices[(Index*6)+0]:=(Index*4)+0;
  fIndices[(Index*6)+1]:=(Index*4)+1;
  fIndices[(Index*6)+2]:=(Index*4)+2;
  fIndices[(Index*6)+3]:=(Index*4)+1;
  fIndices[(Index*6)+4]:=(Index*4)+3;
  fIndices[(Index*6)+5]:=(Index*4)+2;
 end;

 fCountBufferChars:=0;

 for Index:=low(fCountBufferCharsBuffers) to high(fCountBufferCharsBuffers) do begin
  fCountBufferCharsBuffers[Index]:=0;
 end;

end;

destructor TTextOverlay.Destroy;
begin
 inherited Destroy;
end;

procedure TTextOverlay.Load;
const SDFFontWidth=32;
      SDFFontHeight=64;
      SDFFontDepth=256;
type TSDFFontData=array of TpvUInt8;
var Stream:TStream;
    Index:TpvInt32;
    TrueTypeFont:TpvTrueTypeFont;
    SDFFontData:TSDFFontData;
begin

 if not fLoaded then begin

  fLoaded:=true;

  fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                          pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                          TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fVulkanGraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  fVulkanGraphicsCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

  fVulkanTransferCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                          pvApplication.VulkanDevice.TransferQueueFamilyIndex,
                                                          TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanTransferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

  fVulkanCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                  pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
  for Index:=0 to MaxInFlightFrames-1 do begin
   fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
  end;

  Stream:=pvApplication.Assets.GetAssetStream('shaders/textoverlay/textoverlay_vert.spv');
  try
   fTextOverlayVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  Stream:=pvApplication.Assets.GetAssetStream('shaders/textoverlay/textoverlay_frag.spv');
  try
   fTextOverlayFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fVulkanPipelineShaderStageTriangleVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fTextOverlayVertexShaderModule,'main');

  fVulkanPipelineShaderStageTriangleFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fTextOverlayFragmentShaderModule,'main');

  fVulkanGraphicsPipeline:=nil;

  fVulkanRenderPass:=nil;

  SDFFontData:=nil;
  try

   SetLength(SDFFontData,SDFFontWidth*SDFFontHeight*SDFFontDepth);

   Stream:=TpvDataStream.Create(@GUIStandardTrueTypeFontMonoFontData,GUIStandardTrueTypeFontMonoFontDataSize);
   try
    TrueTypeFont:=TpvTrueTypeFont.Create(Stream);
    try
     TrueTypeFont.GenerateSimpleLinearSignedDistanceFieldTextureArray(@SDFFontData[0],
                                                                      SDFFontWidth,
                                                                      SDFFontHeight,
                                                                      SDFFontDepth);
    finally
     TrueTypeFont.Free;
    end;
   finally
    Stream.Free;
   end;

   fFontTexture:=TpvVulkanTexture.CreateFromMemory(pvApplication.VulkanDevice,
                                                   pvApplication.VulkanDevice.GraphicsQueue,
                                                   fVulkanGraphicsCommandBuffer,
                                                   fVulkanGraphicsCommandBufferFence,
                                                   pvApplication.VulkanDevice.TransferQueue,
                                                   fVulkanTransferCommandBuffer,
                                                   fVulkanTransferCommandBufferFence,
                                                   VK_FORMAT_R8_UNORM,
                                                   VK_SAMPLE_COUNT_1_BIT,
                                                   SDFFontWidth,
                                                   SDFFontHeight,
                                                   0,
                                                   SDFFontDepth,
                                                   1,
                                                   1,
                                                   [TpvVulkanTextureUsageFlag.TransferDst,TpvVulkanTextureUsageFlag.Sampled],
                                                   @SDFFontData[0],
                                                   length(SDFFontData),
                                                   false,
                                                   false,
                                                   0,
                                                   false);
   fFontTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToBorder;
   fFontTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToBorder;
   fFontTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToBorder;
   fFontTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
   fFontTexture.UpdateSampler;

  finally
   SDFFontData:=nil;
  end;

  for Index:=0 to MaxInFlightFrames-1 do begin
   fVulkanVertexBuffers[Index]:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                                       SizeOf(TTextOverlayBufferChars),
                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                       [],
                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) {or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)},
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       [TpvVulkanBufferFlag.PersistentMapped]
                                                      );
   fVulkanVertexBuffers[Index].UploadData(pvApplication.VulkanDevice.TransferQueue,
                                          fVulkanTransferCommandBuffer,
                                          fVulkanTransferCommandBufferFence,
                                          fBufferCharsBuffers[0],
                                          0,
                                          SizeOf(TTextOverlayBufferChars),
                                          TpvVulkanBufferUseTemporaryStagingBufferMode.No);
  end;
  
  fVulkanIndexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                             SizeOf(TTextOverlayIndices),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
  fVulkanIndexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                fVulkanTransferCommandBuffer,
                                fVulkanTransferCommandBufferFence,
                                fIndices,
                                0,
                                SizeOf(TTextOverlayIndices),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

  fVulkanUniformBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                               SizeOf(TTextOverlayUniformBuffer),
                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                               [],
                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
                                              );
  fVulkanUniformBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                  fVulkanTransferCommandBuffer,
                                  fVulkanTransferCommandBufferFence,
                                  fUniformBuffer,
                                  0,
                                  SizeOf(TTextOverlayUniformBuffer),
                                  TpvVulkanBufferUseTemporaryStagingBufferMode.No);

  fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                        TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                        2);
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1);
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1);
  fVulkanDescriptorPool.Initialize;

  fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
  fVulkanDescriptorSetLayout.AddBinding(0,
                                        VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                        1,
                                        TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                        []);
  fVulkanDescriptorSetLayout.AddBinding(1,
                                        VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                        1,
                                        TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                        []);
  fVulkanDescriptorSetLayout.Initialize;

  fVulkanDescriptorSet:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                      fVulkanDescriptorSetLayout);
  fVulkanDescriptorSet.WriteToDescriptorSet(0,
                                            0,
                                            1,
                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                            [],
                                            [fVulkanUniformBuffer.DescriptorBufferInfo],
                                            [],
                                            false
                                           );
  fVulkanDescriptorSet.WriteToDescriptorSet(1,
                                            0,
                                            1,
                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                            [fFontTexture.DescriptorImageInfo],
                                            [],
                                            [],
                                            false
                                           );
  fVulkanDescriptorSet.Flush;

  fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
  fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
  fVulkanPipelineLayout.Initialize;

 end;

end;

procedure TTextOverlay.Unload;
var Index:TpvInt32;
begin

 if fLoaded then begin

  fLoaded:=false;

  FreeAndNil(fVulkanRenderPass);
  FreeAndNil(fVulkanGraphicsPipeline);
  FreeAndNil(fVulkanPipelineLayout);
  FreeAndNil(fVulkanDescriptorSet);
  FreeAndNil(fVulkanDescriptorSetLayout);
  FreeAndNil(fVulkanDescriptorPool);
  FreeAndNil(fVulkanUniformBuffer);
  FreeAndNil(fVulkanIndexBuffer);
  for Index:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fVulkanVertexBuffers[Index]);
  end;
  FreeAndNil(fVulkanPipelineShaderStageTriangleVertex);
  FreeAndNil(fVulkanPipelineShaderStageTriangleFragment);
  FreeAndNil(fTextOverlayFragmentShaderModule);
  FreeAndNil(fTextOverlayVertexShaderModule);
  FreeAndNil(fFontTexture);

  for Index:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fVulkanRenderCommandBuffers[Index]);
   FreeAndNil(fVulkanRenderSemaphores[Index]);
  end;
  FreeAndNil(fVulkanCommandPool);

  FreeAndNil(fVulkanTransferCommandBufferFence);
  FreeAndNil(fVulkanTransferCommandBuffer);
  FreeAndNil(fVulkanTransferCommandPool);

  FreeAndNil(fVulkanGraphicsCommandBufferFence);
  FreeAndNil(fVulkanGraphicsCommandBuffer);
  FreeAndNil(fVulkanGraphicsCommandPool);

 end;
end;

procedure TTextOverlay.AfterCreateSwapChain;
begin

 FreeAndNil(fVulkanRenderPass);
 FreeAndNil(fVulkanGraphicsPipeline);

 fVulkanRenderPass:=TpvVulkanRenderPass.Create(pvApplication.VulkanDevice);

 fVulkanRenderPass.AddSubpassDescription(0,
                                         VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         [],
                                         [fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                              pvApplication.VulkanSwapChain.ImageFormat,
                                                                                                                              VK_SAMPLE_COUNT_1_BIT,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_LOAD,
                                                                                                                              VK_ATTACHMENT_STORE_OP_STORE,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                              VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, //VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, //VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                                                                                                              VK_IMAGE_LAYOUT_PRESENT_SRC_KHR //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL //VK_IMAGE_LAYOUT_PRESENT_SRC_KHR  // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                                                                             ),
                                                                             VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                            )],
                                         [],
                                         fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                             pvApplication.VulkanDepthImageFormat,
                                                                                                                             VK_SAMPLE_COUNT_1_BIT,
                                                                                                                             VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                             VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                             VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                             VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                             VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, // VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                                                                                                             VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                                                            ),
                                                                                  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                 ),
                                         []);
 fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                        0,
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                        TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                        TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                        TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
 fVulkanRenderPass.AddSubpassDependency(0,
                                        VK_SUBPASS_EXTERNAL,
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                        TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                        TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                        TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
 fVulkanRenderPass.Initialize;

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                           pvApplication.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanPipelineLayout,
                                                           fVulkanRenderPass,
                                                           0,
                                                           nil,
                                                           0);

 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageTriangleVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageTriangleFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TVkFloat)*(2+3+4+4),VK_VERTEX_INPUT_RATE_VERTEX);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32_SFLOAT,SizeOf(TVkFloat)*0);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32B32_SFLOAT,SizeOf(TVkFloat)*2);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32A32_SFLOAT,SizeOf(TVkFloat)*(2+3));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32G32B32A32_SFLOAT,SizeOf(TVkFloat)*(2+3+4));

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
 fVulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
 fVulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

 fVulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
 fVulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                      VK_BLEND_FACTOR_SRC_ALPHA,
                                                                      VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_SRC_ALPHA,
                                                                      VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.Initialize;

 fVulkanGraphicsPipeline.FreeMemory;

 fFontCharWidth:=pvApplication.Width/160.0;
 fFontCharHeight:=fFontCharWidth*2.0;

 fInvWidth:=1.0/pvApplication.Width;
 fInvHeight:=1.0/pvApplication.Height;

 if assigned(fVulkanUniformBuffer) then begin
  fUniformBuffer.uThreshold:=1.0;//(SDFFontSpreadScale/sqrt(sqr(fFontCharWidth)+sqr(fFontCharHeight)))*1.0;
  fVulkanUniformBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                  fVulkanTransferCommandBuffer,
                                  fVulkanTransferCommandBufferFence,
                                  fUniformBuffer,
                                  0,
                                  SizeOf(TTextOverlayUniformBuffer),
                                  TpvVulkanBufferUseTemporaryStagingBufferMode.No);

 end;

end;

procedure TTextOverlay.BeforeDestroySwapChain;
begin
 FreeAndNil(fVulkanRenderPass);
 FreeAndNil(fVulkanGraphicsPipeline);
end;

procedure TTextOverlay.Reset;
begin
 fCountBufferChars:=0;
end;

procedure TTextOverlay.AddText(const pX,pY,aSize:TpvFloat;const aAlignment:TTextOverlayAlignment;const aText:TpvApplicationRawByteString;const pBR:TpvFloat=1.0;const pBG:TpvFloat=1.0;const pBB:TpvFloat=1.0;const pBA:TpvFloat=0.0;const pFR:TpvFloat=1.0;const pFG:TpvFloat=1.0;const pFB:TpvFloat=1.0;const pFA:TpvFloat=1.0);
var Index,EdgeIndex:TpvInt32;
    BufferChar:PTextOverlayBufferChar;
    CurrentChar:TpvUInt8;
    cX:TpvFloat;
begin
 if (pBA>0.0) or (pFA>0.0) then begin
  case aAlignment of
   toaLeft:begin
    cX:=pX;
   end;
   toaCenter:begin
    cX:=pX-((length(aText)*fFontCharWidth*aSize)*0.5);
   end;
   else {toaRight:}begin
    cX:=pX-(length(aText)*fFontCharWidth*aSize);
   end;
  end;
  for Index:=1 to length(aText) do begin
   CurrentChar:=TpvUInt8(AnsiChar(aText[Index]));
   if (CurrentChar<>32) or (pBA>0.0) then begin
    if fCountBufferChars<TextOverlayBufferCharSize then begin
     BufferChar:=@fBufferChars^[fCountBufferChars];
     inc(fCountBufferChars);
     for EdgeIndex:=0 to 3 do begin
      BufferChar^.Vertices[EdgeIndex].x:=(((cX+((EdgeIndex and 1)*fFontCharWidth*aSize))*fInvWidth)*2.0)-1.0;
      BufferChar^.Vertices[EdgeIndex].y:=(((pY+((EdgeIndex shr 1)*fFontCharHeight*aSize))*fInvHeight)*2.0)-1.0;
      BufferChar^.Vertices[EdgeIndex].u:=EdgeIndex and 1;
      BufferChar^.Vertices[EdgeIndex].v:=EdgeIndex shr 1;
      BufferChar^.Vertices[EdgeIndex].w:=CurrentChar;
      BufferChar^.Vertices[EdgeIndex].br:=pBR;
      BufferChar^.Vertices[EdgeIndex].bg:=pBG;
      BufferChar^.Vertices[EdgeIndex].bb:=pBB;
      BufferChar^.Vertices[EdgeIndex].ba:=pBA;
      BufferChar^.Vertices[EdgeIndex].fr:=pFR;
      BufferChar^.Vertices[EdgeIndex].fg:=pFG;
      BufferChar^.Vertices[EdgeIndex].fb:=pFB;
      BufferChar^.Vertices[EdgeIndex].fa:=pFA;
     end;
    end;
   end;
   cX:=cX+(fFontCharWidth*aSize);
  end;
 end;
end;

procedure TTextOverlay.PreUpdate(const aDeltaTime:double);
var FPS,ms:shortstring;
begin
 fUpdateBufferIndex:=pvApplication.UpdateInFlightFrameIndex;
 fBufferChars:=@fBufferCharsBuffers[fUpdateBufferIndex];
 begin
  Reset;
  AddText(0.0,fFontCharHeight*0.0,1.0,toaLeft,TpvApplicationRawByteString('Device: '+pvApplication.VulkanDevice.PhysicalDevice.DeviceName{$ifdef Android}+' ('+TpvApplicationRawByteString(AndroidDeviceName)+')'{$endif}));
  AddText(0.0,fFontCharHeight*1.0,1.0,toaLeft,TpvApplicationRawByteString('Vulkan API version: '+IntToStr(pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 22)+'.'+IntToStr((pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 12) and $3ff)+'.'+IntToStr((pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 0) and $fff)));
  Str(pvApplication.FramesPerSecond:1:1,FPS);
  Str(pvApplication.DeltaTime*1000.0:1:2,ms);
  AddText(0.0,fFontCharHeight*2.0,1.0,toaLeft,TpvApplicationRawByteString('Frame rate: '+String(FPS)+' FPS'));
  AddText(0.0,fFontCharHeight*3.0,1.0,toaLeft,TpvApplicationRawByteString('Frame time: '+String(MS)+' ms'));
 end;
end;

procedure TTextOverlay.PostUpdate(const aDeltaTime:double);
begin
 fCountBufferCharsBuffers[fUpdateBufferIndex]:=fCountBufferChars;
end;

procedure TTextOverlay.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var BufferIndex,Size:TpvInt32;
    VulkanVertexBuffer:TpvVulkanBuffer;
    VulkanCommandBuffer:TpvVulkanCommandBuffer;
    VulkanSwapChain:TpvVulkanSwapChain;
    p:TpvPointer;
begin

 BufferIndex:=pvApplication.DrawInFlightFrameIndex;
 if fCountBufferCharsBuffers[BufferIndex]=0 then begin
  fCountBufferCharsBuffers[BufferIndex]:=1;
  FillChar(fBufferCharsBuffers[BufferIndex],SizeOf(TTextOverlayBufferChar),#0);
 end;

 begin

  VulkanVertexBuffer:=fVulkanVertexBuffers[pvApplication.DrawInFlightFrameIndex];

  Size:=SizeOf(TTextOverlayBufferChar)*fCountBufferCharsBuffers[BufferIndex];
  p:=VulkanVertexBuffer.Memory.MapMemory(0,Size);
  if assigned(p) then begin
   try
    Move(fBufferCharsBuffers[BufferIndex],p^,Size);
    VulkanVertexBuffer.Memory.FlushMappedMemoryRange(p,Size);
   finally
    VulkanVertexBuffer.Memory.UnmapMemory;
   end;
  end;

  if assigned(fVulkanGraphicsPipeline) then begin

   VulkanCommandBuffer:=fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex];
   VulkanSwapChain:=pvApplication.VulkanSwapChain;

   VulkanCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

   VulkanCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

  {VulkanCommandBuffer.MetaCmdMemoryBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                            TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT),
                                            TVkAccessFlags(VK_ACCESS_UNIFORM_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT));}

   fVulkanRenderPass.BeginRenderPass(VulkanCommandBuffer,
                                     pvApplication.VulkanFrameBuffers[aSwapChainImageIndex],
                                     VK_SUBPASS_CONTENTS_INLINE,
                                     0,
                                     0,
                                     VulkanSwapChain.Width,
                                     VulkanSwapChain.Height);

   VulkanCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,1,@fVulkanDescriptorSet.Handle,0,nil);
   VulkanCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
   VulkanCommandBuffer.CmdBindVertexBuffers(0,1,@VulkanVertexBuffer.Handle,@Offsets);
   VulkanCommandBuffer.CmdBindIndexBuffer(fVulkanIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);
   VulkanCommandBuffer.CmdDrawIndexed(fCountBufferCharsBuffers[BufferIndex]*6,1,0,0,0);

   fVulkanRenderPass.EndRenderPass(VulkanCommandBuffer);

   VulkanCommandBuffer.EndRecording;

   VulkanCommandBuffer.Execute(pvApplication.VulkanDevice.GraphicsQueue,
                               TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                               aWaitSemaphore,
                               fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex],
                               aWaitFence,
                               false);

   aWaitSemaphore:=fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex];

  end;
 end;
end;

end.
