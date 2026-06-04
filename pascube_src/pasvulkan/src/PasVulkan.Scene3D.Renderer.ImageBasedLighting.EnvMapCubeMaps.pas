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
unit PasVulkan.Scene3D.Renderer.ImageBasedLighting.EnvMapCubeMaps;
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

type { TpvScene3DRendererImageBasedLightingEnvMapCubeMaps }
     TpvScene3DRendererImageBasedLightingEnvMapCubeMaps=class
      public
       const Width=512;
             Height=512;
             Samples=1024;
      private
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanGGXImage:TpvVulkanImage;
       fVulkanCharlieImage:TpvVulkanImage;
       fVulkanLambertianImage:TpvVulkanImage;
       fVulkanSampler:TpvVulkanSampler;
       fVulkanGGXImageView:TpvVulkanImageView;
       fVulkanCharlieImageView:TpvVulkanImageView;
       fVulkanLambertianImageView:TpvVulkanImageView;
       fGGXMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fCharlieMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fLambertianMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fGGXDescriptorImageInfo:TVkDescriptorImageInfo;
       fCharlieDescriptorImageInfo:TVkDescriptorImageInfo;
       fLambertianDescriptorImageInfo:TVkDescriptorImageInfo;
      public

       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aVulkanSampler:TpvVulkanSampler;const aDescriptorImageInfo:TVkDescriptorImageInfo;const aImageFormat:TVkFormat=TVkFormat(VK_FORMAT_R16G16B16A16_SFLOAT));

       destructor Destroy; override;

      published

       property VulkanGGXImage:TpvVulkanImage read fVulkanGGXImage;

       property VulkanCharlieImage:TpvVulkanImage read fVulkanCharlieImage;

       property VulkanLambertianImage:TpvVulkanImage read fVulkanLambertianImage;

       property VulkanSampler:TpvVulkanSampler read fVulkanSampler;

       property VulkanGGXImageView:TpvVulkanImageView read fVulkanGGXImageView;

       property VulkanCharlieImageView:TpvVulkanImageView read fVulkanCharlieImageView;

       property VulkanLambertianImageView:TpvVulkanImageView read fVulkanLambertianImageView;

      public

       property GGXDescriptorImageInfo:TVkDescriptorImageInfo read fGGXDescriptorImageInfo;

       property CharlieDescriptorImageInfo:TVkDescriptorImageInfo read fCharlieDescriptorImageInfo;

       property LambertianDescriptorImageInfo:TVkDescriptorImageInfo read fLambertianDescriptorImageInfo;

     end;

implementation

function Hammersley(Index,NumSamples:TpvInt32):TpvVector2;
const OneOver32Bit=1.0/4294967296.0;
var ReversedIndex:TpvUInt32;
begin
 ReversedIndex:=TpvUInt32(Index);
 ReversedIndex:=(ReversedIndex shl 16) or (ReversedIndex shr 16);
 ReversedIndex:=((ReversedIndex and $00ff00ff) shl 8) or ((ReversedIndex and $ff00ff00) shr 8);
 ReversedIndex:=((ReversedIndex and $0f0f0f0f) shl 4) or ((ReversedIndex and $f0f0f0f0) shr 4);
 ReversedIndex:=((ReversedIndex and $33333333) shl 2) or ((ReversedIndex and $cccccccc) shr 2);
 ReversedIndex:=((ReversedIndex and $55555555) shl 1) or ((ReversedIndex and $aaaaaaaa) shr 1);
 result.x:=frac(TpvFloat(Index)/TpvFloat(NumSamples));
 result.y:=ReversedIndex*OneOver32Bit;
end;

function GenerateTBN(const Normal:TpvVector3):TpvMatrix3x3;
var Bitangent,Tangent:TpvVector3;
begin
 if (1.0-abs(Normal.y))<=1e-6 then begin
  if Normal.y>0.0 then begin
   Bitangent:=TpvVector3.InlineableCreate(0.0,0.0,1.0);
  end else begin
   Bitangent:=TpvVector3.InlineableCreate(0.0,0.0,-1.0);
  end;
 end else begin
  Bitangent:=TpvVector3.InlineableCreate(0.0,1.0,0.0);
 end;
 Tangent:=Bitangent.Cross(Normal).Normalize;
 result:=TpvMatrix3x3.Create(Tangent,Normal.Cross(Tangent).Normalize,Normal);
end;

function D_GGX(const NdotH,Roughness:TpvScalar):TpvScalar;
begin
 result:=sqr(Roughness/((1.0-sqr(NdotH))+sqr(NdotH*Roughness)))*OneOverPI;
end;

function GGX(const xi:TpvVector2;const Roughness:TpvScalar):TpvVector4;
var Alpha:TpvScalar;
begin
 Alpha:=sqr(Roughness);
 result.x:=Clamp(sqrt((1.0-xi.y)/(1.0+((sqr(Alpha)-1.0)*xi.y))),0.0,1.0);
 result.y:=sqrt(1.0-sqr(result.x));
 result.z:=TwoPI*xi.x;
 result.w:=D_GGX(result.x,Alpha)*0.25;
end;

function D_Charlie(const SheenRoughness,NdotH:TpvScalar):TpvScalar;
var InvR,Cos2H,Sin2H:TpvScalar;
begin
 InvR:=1.0/Clamp(SheenRoughness,1e-6,1.0);
 Cos2H:=sqr(NdotH);
 Sin2H:=1.0-Cos2H;
 result:=(2.0+InvR)*power(Sin2H,InvR*0.5)*OneOverTwoPI;
end;

function Charlie(const xi:TpvVector2;const Roughness:TpvScalar):TpvVector4;
var Alpha:TpvScalar;
begin
 Alpha:=sqr(Roughness);
 result.y:=Power(xi.y,Alpha/((2.0*Alpha)+1.0));
 result.x:=sqrt(1.0-sqr(result.y));
 result.z:=TwoPI*xi.x;
 result.w:=D_Charlie(Alpha,result.x)*0.25;
end;

function Lambertian(const xi:TpvVector2;const Roughness:TpvScalar):TpvVector4;
begin
 result.x:=sqrt(1.0-xi.y);
 result.y:=sqrt(xi.y);
 result.z:=TwoPI*xi.x;
 result.w:=result.x*OneOverPI;
end;

type TImportanceSampleFunction=function(const xi:TpvVector2;const Roughness:TpvScalar):TpvVector4;

     TImportanceSamples=array of TpvVector4;

procedure GetImportanceSamples(out aSamples:TImportanceSamples;const aCount:TpvSizeInt;const aRoughness:TpvScalar;const aImportanceSampleFunction:TImportanceSampleFunction;const aLambertian:boolean);
var SampleIndex,TryIteration:TpvSizeInt;
    t:TpvVector4;
    x32,v:TpvUInt32;
begin
 aSamples:=nil;
 SetLength(aSamples,aCount);
 if aLambertian then begin
  for SampleIndex:=0 to aCount-1 do begin
   t:=aImportanceSampleFunction(Hammersley(SampleIndex,aCount),aRoughness);
   aSamples[SampleIndex]:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(TpvVector2.InlineableCreate(cos(t.z),sin(t.z))*t.y,t.x).Normalize,t.w);
  end;
 end else begin
  x32:=$3c7a92e1;
  for SampleIndex:=0 to aCount-1 do begin
   t.xy:=Hammersley(SampleIndex,aCount);
   for TryIteration:=1 to 256 do begin
    t:=aImportanceSampleFunction(t.xy,aRoughness);
    t.xyz:=TpvVector3.InlineableCreate(TpvVector2.InlineableCreate(cos(t.z),sin(t.z))*t.y,t.x).Normalize;
    if t.z<1e-4 then begin
     x32:=x32 xor (x32 shl 13);
     x32:=x32 xor (x32 shr 17);
     x32:=x32 xor (x32 shl 5);
     v:=x32;
     v:=(((v shr 10) and $3fffff)+((v shr 9) and 1)) or $40000000;
     t.x:=TpvFloat(pointer(@v)^)-2.0;
     x32:=x32 xor (x32 shl 13);
     x32:=x32 xor (x32 shr 17);
     x32:=x32 xor (x32 shl 5);
     v:=x32;
     v:=(((v shr 10) and $3fffff)+((v shr 9) and 1)) or $40000000;
     t.y:=TpvFloat(pointer(@v)^)-2.0;
    end else begin
     break;
    end;
   end;
   aSamples[SampleIndex]:=t;
  end;
 end;
end;

{ TpvScene3DRendererImageBasedLightingEnvMapCubeMaps }

constructor TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aVulkanSampler:TpvVulkanSampler;const aDescriptorImageInfo:TVkDescriptorImageInfo;const aImageFormat:TVkFormat);
type TPushConstants=record
      MipMapLevel:TpvInt32;
      MaxMipMapLevel:TpvInt32;
      NumSamples:TpvInt32;
      Which:TpvInt32;
     end;
     PpvVulkanImage=^TpvVulkanImage;
     PpvVulkanDeviceMemoryBlock=^TpvVulkanDeviceMemoryBlock;
var ImageIndex,Index,MipMaps:TpvSizeInt;
    Stream:TStream;
    MemoryRequirements:TVkMemoryRequirements;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    ImageSubresourceRange:TVkImageSubresourceRange;
    GraphicsQueue:TpvVulkanQueue;
    GraphicsCommandPool:TpvVulkanCommandPool;
    GraphicsCommandBuffer:TpvVulkanCommandBuffer;
    GraphicsFence:TpvVulkanFence;
    ComputeQueue:TpvVulkanQueue;
    ComputeCommandPool:TpvVulkanCommandPool;
    ComputeCommandBuffer:TpvVulkanCommandBuffer;
    ComputeFence:TpvVulkanFence;
    ImageViews:array[0..2] of array of TpvVulkanImageView;
    VulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    VulkanDescriptorPool:TpvVulkanDescriptorPool;
    VulkanDescriptorSets:array[0..2] of array of TpvVulkanDescriptorSet;
    DescriptorImageInfos:array[0..2] of array of TVkDescriptorImageInfo;
    PipelineLayout:TpvVulkanPipelineLayout;
    Pipeline:TpvVulkanComputePipeline;
    PushConstants:TPushConstants;
//ImageMemoryBarrier:TVkImageMemoryBarrier;
    Images:array[0..2] of PpvVulkanImage;
    MemoryBlocks:array[0..2] of PpvVulkanDeviceMemoryBlock;
    AdditionalImageFormat:TVkFormat;
    FormatVariant,Name:String;
//  ImportanceSamples:TImportanceSamples;
begin
 inherited Create;

//GetImportanceSamples(ImportanceSamples,1024,0.1,Charlie);

 if aImageFormat=VK_FORMAT_E5B9G9R9_UFLOAT_PACK32 then begin
  AdditionalImageFormat:=VK_FORMAT_R32_UINT;
  FormatVariant:='rgb9e5_';
 end else begin
  AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  FormatVariant:='';
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_filter_'+FormatVariant+'comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(aVulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 MipMaps:=IntLog2(Max(Width,Height))+1;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

 Images[0]:=@fVulkanGGXImage;
 Images[1]:=@fVulkanCharlieImage;
 Images[2]:=@fVulkanLambertianImage;

 MemoryBlocks[0]:=@fGGXMemoryBlock;
 MemoryBlocks[1]:=@fCharlieMemoryBlock;
 MemoryBlocks[2]:=@fLambertianMemoryBlock;

 for ImageIndex:=0 to 2 do begin

  Images[ImageIndex]^:=TpvVulkanImage.Create(aVulkanDevice,
                                             TVkImageCreateFlags(VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT) or
                                             TVkImageCreateFlags(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkUInt32(VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT) or TVkUInt32(VK_IMAGE_CREATE_EXTENDED_USAGE_BIT),0)),
                                             VK_IMAGE_TYPE_2D,
                                             aImageFormat,
                                             Width,
                                             Height,
                                             1,
                                             MipMaps,
                                             6,
                                             VK_SAMPLE_COUNT_1_BIT,
                                             VK_IMAGE_TILING_OPTIMAL,
                                             TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or
                                             TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                             VK_SHARING_MODE_EXCLUSIVE,
                                             0,
                                             nil,
                                             VK_IMAGE_LAYOUT_UNDEFINED,
                                             AdditionalImageFormat
                                            );

  MemoryRequirements:=aVulkanDevice.MemoryManager.GetImageMemoryRequirements(Images[ImageIndex]^.Handle,
                                                                             RequiresDedicatedAllocation,
                                                                             PrefersDedicatedAllocation);

  MemoryBlockFlags:=[];

  if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
   Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
  end;

  case ImageIndex of
   0:begin
    Name:='TpScene3DRendererImageBasedLightingEnvMapCubeMaps.GGX.MemoryBlock';
   end;
   1:begin
    Name:='TpScene3DRendererImageBasedLightingEnvMapCubeMaps.Charlie.MemoryBlock';
   end;
   else begin
    Name:='TpScene3DRendererImageBasedLightingEnvMapCubeMaps.Lambertian.MemoryBlock';
   end;
  end;

  MemoryBlocks[ImageIndex]^:=aVulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
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
                                                                             @Images[ImageIndex]^.Handle,
                                                                             pvAllocationGroupIDScene3DTexture,
                                                                             Name);
  if not assigned(MemoryBlocks[ImageIndex]^) then begin
   raise EpvVulkanMemoryAllocationException.Create('Memory for texture couldn''t be allocated!');
  end;

  MemoryBlocks[ImageIndex]^.AssociatedObject:=self;

  VulkanCheckResult(aVulkanDevice.Commands.BindImageMemory(aVulkanDevice.Handle,
                                                           Images[ImageIndex]^.Handle,
                                                           MemoryBlocks[ImageIndex]^.MemoryChunk.Handle,
                                                           MemoryBlocks[ImageIndex]^.Offset));

 end;

 aVulkanDevice.DebugUtils.SetObjectName(fVulkanGGXImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanGGXImage');
 aVulkanDevice.DebugUtils.SetObjectName(fVulkanCharlieImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanCharlieImage');
 aVulkanDevice.DebugUtils.SetObjectName(fVulkanLambertianImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanLambertianImage');

 GraphicsQueue:=aVulkanDevice.GraphicsQueue;

 ComputeQueue:=aVulkanDevice.ComputeQueue;

 GraphicsCommandPool:=TpvVulkanCommandPool.Create(aVulkanDevice,
                                                  aVulkanDevice.GraphicsQueueFamilyIndex,
                                                  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  GraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(GraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   GraphicsFence:=TpvVulkanFence.Create(aVulkanDevice);
   try

    ComputeCommandPool:=TpvVulkanCommandPool.Create(aVulkanDevice,
                                                    aVulkanDevice.ComputeQueueFamilyIndex,
                                                    TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
    try

     ComputeCommandBuffer:=TpvVulkanCommandBuffer.Create(ComputeCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     try

      ComputeFence:=TpvVulkanFence.Create(aVulkanDevice);
      try

       FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
       ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
       ImageSubresourceRange.baseMipLevel:=0;
       ImageSubresourceRange.levelCount:=MipMaps;
       ImageSubresourceRange.baseArrayLayer:=0;
       ImageSubresourceRange.layerCount:=6;

       for ImageIndex:=0 to 2 do begin
        Images[ImageIndex]^.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                      TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED),
                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                      @ImageSubresourceRange,
                                      GraphicsCommandBuffer,
                                      GraphicsQueue,
                                      GraphicsFence,
                                      true);
       end;

{      fVulkanSampler:=TpvVulkanSampler.Create(aVulkanDevice,
                                               TVkFilter(VK_FILTER_LINEAR),
                                               TVkFilter(VK_FILTER_LINEAR),
                                               TVkSamplerMipmapMode(VK_SAMPLER_MIPMAP_MODE_LINEAR),
                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                               0.0,
                                               false,
                                               1.0,
                                               false,
                                               TVkCompareOp(VK_COMPARE_OP_NEVER),
                                               0.0,
                                               MipMaps,
                                               TVkBorderColor(VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK),
                                               false);
       aVulkanDevice.DebugUtils.SetObjectName(fVulkanSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanSampler');}
       fVulkanSampler:=aVulkanSampler;

       fVulkanGGXImageView:=TpvVulkanImageView.Create(aVulkanDevice,
                                                      fVulkanGGXImage,
                                                      TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                      aImageFormat,
                                                      TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                      TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                      TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                      TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                      TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                      0,
                                                      MipMaps,
                                                      0,
                                                      6,
                                                      true,
                                                      TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT));
       aVulkanDevice.DebugUtils.SetObjectName(fVulkanGGXImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanGGXImageView');

       fVulkanCharlieImageView:=TpvVulkanImageView.Create(aVulkanDevice,
                                                          fVulkanCharlieImage,
                                                          TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                          aImageFormat,
                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                          TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                          0,
                                                          MipMaps,
                                                          0,
                                                          6,
                                                          true,
                                                          TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT));
       aVulkanDevice.DebugUtils.SetObjectName(fVulkanCharlieImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanCharlieImageView');

       fVulkanLambertianImageView:=TpvVulkanImageView.Create(aVulkanDevice,
                                                             fVulkanLambertianImage,
                                                             TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                             aImageFormat,
                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                             TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                             0,
                                                             MipMaps,
                                                             0,
                                                             6,
                                                             true,
                                                             TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT));
       aVulkanDevice.DebugUtils.SetObjectName(fVulkanLambertianImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.fVulkanLambertianImageView');

       fGGXDescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                              fVulkanGGXImageView.Handle,
                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

       fCharlieDescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                  fVulkanCharlieImageView.Handle,
                                                                  VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

       fLambertianDescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                     fVulkanLambertianImageView.Handle,
                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

       for ImageIndex:=0 to 2 do begin
        ImageViews[ImageIndex]:=nil;
        DescriptorImageInfos[ImageIndex]:=nil;
       end;

       try

        for ImageIndex:=0 to 2 do begin
         SetLength(ImageViews[ImageIndex],MipMaps);
         SetLength(DescriptorImageInfos[ImageIndex],MipMaps);
        end;

        for ImageIndex:=0 to 2 do begin

         for Index:=0 to MipMaps-1 do begin

          ImageViews[ImageIndex,Index]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                  Images[ImageIndex]^,
                                                                  TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                  TVkFormat(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkInt32(AdditionalImageFormat),TVkInt32(aImageFormat))),
                                                                  TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                  TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                  TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                  TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                  TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                  Index,
                                                                  1,
                                                                  0,
                                                                  6);
          aVulkanDevice.DebugUtils.SetObjectName(ImageViews[ImageIndex,Index].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.ImageViews['+IntToStr(ImageIndex)+','+IntToStr(Index)+']');

          DescriptorImageInfos[ImageIndex,Index]:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                ImageViews[ImageIndex,Index].Handle,
                                                                                VK_IMAGE_LAYOUT_GENERAL);

         end;

        end;

        try

         VulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(aVulkanDevice);
         try
          VulkanDescriptorSetLayout.AddBinding(0,
                                               VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                               1,
                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                               []);
          VulkanDescriptorSetLayout.AddBinding(1,
                                               VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                               1,
                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                               []);
          VulkanDescriptorSetLayout.Initialize;

          VulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(aVulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                               3*MipMaps);
          try
           VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,3*MipMaps);
           VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,3*MipMaps);
           VulkanDescriptorPool.Initialize;

           for ImageIndex:=0 to 2 do begin
            VulkanDescriptorSets[ImageIndex]:=nil;
           end;
           try
            for ImageIndex:=0 to 2 do begin
             SetLength(VulkanDescriptorSets[ImageIndex],MipMaps);
             for Index:=0 to MipMaps-1 do begin
              VulkanDescriptorSets[ImageIndex,Index]:=TpvVulkanDescriptorSet.Create(VulkanDescriptorPool,
                                                                                    VulkanDescriptorSetLayout);

              VulkanDescriptorSets[ImageIndex,Index].WriteToDescriptorSet(0,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [aDescriptorImageInfo],
                                                                          [],
                                                                          [],
                                                                          false);
              VulkanDescriptorSets[ImageIndex,Index].WriteToDescriptorSet(1,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                          [DescriptorImageInfos[ImageIndex,Index]],
                                                                          [],
                                                                          [],
                                                                          false);
              VulkanDescriptorSets[ImageIndex,Index].Flush;
             end;
            end;
            try

             PipelineLayout:=TpvVulkanPipelineLayout.Create(aVulkanDevice);
             try
              PipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
              PipelineLayout.AddDescriptorSetLayout(VulkanDescriptorSetLayout);
              PipelineLayout.Initialize;

              Pipeline:=TpvVulkanComputePipeline.Create(aVulkanDevice,
                                                        aVulkanPipelineCache,
                                                        0,
                                                        fVulkanPipelineShaderStageCompute,
                                                        PipelineLayout,
                                                        nil,
                                                        0);
              try

               for ImageIndex:=0 to 2 do begin
                Images[ImageIndex]^.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                              TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                              TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                              @ImageSubresourceRange,
                                              GraphicsCommandBuffer,
                                              GraphicsQueue,
                                              GraphicsFence,
                                              true);
               end;

               ComputeCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

               ComputeCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

  {            FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
               ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
               ImageMemoryBarrier.pNext:=nil;
               ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
               ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
               ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
               ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
               ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
               ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
               ImageMemoryBarrier.image:=fVulkanImage.Handle;
               ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
               ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
               ImageMemoryBarrier.subresourceRange.levelCount:=MipMaps;
               ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
               ImageMemoryBarrier.subresourceRange.layerCount:=1;
               ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                       0,
                                                       0,nil,
                                                       0,nil,
                                                       1,@ImageMemoryBarrier);
  }
               ComputeCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,Pipeline.Handle);

               for ImageIndex:=0 to 2 do begin

                for Index:=0 to MipMaps-1 do begin

                 ComputeCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                            PipelineLayout.Handle,
                                                            0,
                                                            1,
                                                            @VulkanDescriptorSets[ImageIndex,Index].Handle,
                                                            0,
                                                            nil);

                 PushConstants.MipMapLevel:=Index;
                 PushConstants.MaxMipMapLevel:=MipMaps-1;
                 if (ImageIndex=0) and (Index=0) then begin
                  PushConstants.NumSamples:=1;
                 end else begin
                  PushConstants.NumSamples:=Min(128 shl Index,Samples);
                 end;
                 PushConstants.Which:=ImageIndex;

                 ComputeCommandBuffer.CmdPushConstants(PipelineLayout.Handle,
                                                       TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                                       0,
                                                       SizeOf(TPushConstants),
                                                       @PushConstants);

                 ComputeCommandBuffer.CmdDispatch(Max(1,(Width+((1 shl (4+Index))-1)) shr (4+Index)),
                                                  Max(1,(Height+((1 shl (4+Index))-1)) shr (4+Index)),
                                                  6);

                end;

               end;

  {            FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
               ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
               ImageMemoryBarrier.pNext:=nil;
               ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
               ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
               ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
               ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
               ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
               ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
               ImageMemoryBarrier.image:=fVulkanImage.Handle;
               ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
               ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
               ImageMemoryBarrier.subresourceRange.levelCount:=MipMaps;
               ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
               ImageMemoryBarrier.subresourceRange.layerCount:=1;
               ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                       TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                       0,
                                                       0,nil,
                                                       0,nil,
                                                       1,@ImageMemoryBarrier); }

               ComputeCommandBuffer.EndRecording;

               ComputeCommandBuffer.Execute(ComputeQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,ComputeFence,true);

               for ImageIndex:=0 to 2 do begin
                Images[ImageIndex]^.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                              TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                              TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                              @ImageSubresourceRange,
                                              GraphicsCommandBuffer,
                                              GraphicsQueue,
                                              GraphicsFence,
                                              true);
               end;

              finally
               FreeAndNil(Pipeline);
              end;

             finally
              FreeAndNil(PipelineLayout);
             end;

            finally
             for ImageIndex:=0 to 2 do begin
              for Index:=0 to MipMaps-1 do begin
               FreeAndNil(VulkanDescriptorSets[ImageIndex,Index]);
              end;
             end;
            end;

           finally
            for ImageIndex:=0 to 2 do begin
             VulkanDescriptorSets[ImageIndex]:=nil;
            end;
           end;

          finally
           FreeAndNil(VulkanDescriptorPool);
          end;

         finally
          FreeAndNil(VulkanDescriptorSetLayout);
         end;

        finally
         for ImageIndex:=0 to 2 do begin
          for Index:=0 to MipMaps-1 do begin
           FreeAndNil(ImageViews[ImageIndex,Index]);
          end;
         end;
        end;

       finally
        for ImageIndex:=0 to 2 do begin
         ImageViews[ImageIndex]:=nil;
         DescriptorImageInfos[ImageIndex]:=nil;
        end;
       end;

      finally
       FreeAndNil(ComputeFence);
      end;

     finally
      FreeAndNil(ComputeCommandBuffer);
     end;

    finally
     FreeAndNil(ComputeCommandPool);
    end;

   finally
    FreeAndNil(GraphicsFence);
   end;

  finally
   FreeAndNil(GraphicsCommandBuffer);
  end;

 finally
  FreeAndNil(GraphicsCommandPool);
 end;

end;

destructor TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.Destroy;
begin
 FreeAndNil(fGGXMemoryBlock);
 FreeAndNil(fCharlieMemoryBlock);
 FreeAndNil(fLambertianMemoryBlock);
 FreeAndNil(fVulkanGGXImageView);
 FreeAndNil(fVulkanCharlieImageView);
 FreeAndNil(fVulkanLambertianImageView);
//FreeAndNil(fVulkanSampler);
 FreeAndNil(fVulkanGGXImage);
 FreeAndNil(fVulkanCharlieImage);
 FreeAndNil(fVulkanLambertianImage);
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited Destroy;
end;

end.
