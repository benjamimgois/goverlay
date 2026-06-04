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
unit PasVulkan.Scene3D.Renderer.IBLDescriptor;
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
     PasVulkan.Types,
     PasVulkan.Framework;

type { TpvScene3DRendererIBLDescriptor }     
     TpvScene3DRendererIBLDescriptor=class
      private
       fVulkanDevice:TpvVulkanDevice;
       fDescriptorSet:TpvVulkanDescriptorSet;
       fBinding:TpvSizeInt;
       fSampler:TVkSampler;
       fGGXDescriptorImageInfo:TVkDescriptorImageInfo;
       fCharlieDescriptorImageInfo:TVkDescriptorImageInfo;
       fLambertianDescriptorImageInfo:TVkDescriptorImageInfo;
       fGGX2DescriptorImageInfo:TVkDescriptorImageInfo;
       fCharlie2DescriptorImageInfo:TVkDescriptorImageInfo;
       fLambertian2DescriptorImageInfo:TVkDescriptorImageInfo;
       fPointerToGGXDescriptorImageInfo:PVkDescriptorImageInfo;
       fPointerToCharlieDescriptorImageInfo:PVkDescriptorImageInfo;
       fPointerToLambertianDescriptorImageInfo:PVkDescriptorImageInfo;
       fPointerToGGX2DescriptorImageInfo:PVkDescriptorImageInfo;
       fPointerToCharlie2DescriptorImageInfo:PVkDescriptorImageInfo;
       fPointerToLambertian2DescriptorImageInfo:PVkDescriptorImageInfo;
       fDirty:Boolean;
       procedure SetGGXImageView(const aGGXImageView:TVkImageView);
       procedure SetCharlieImageView(const aCharlieImageView:TVkImageView);
       procedure SetLambertianImageView(const aLambertianImageView:TVkImageView);
       procedure SetGGX2ImageView(const aGGX2ImageView:TVkImageView);
       procedure SetCharlie2ImageView(const aCharlie2ImageView:TVkImageView);
       procedure SetLambertian2ImageView(const aLambertian2ImageView:TVkImageView);
      public
       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aDescriptorSet:TpvVulkanDescriptorSet;const aBinding:TpvSizeInt;const aSampler:TVkSampler);
       destructor Destroy; override;
       procedure Update(const aInstant:Boolean=false);
       procedure SetFrom(const aScene3D,aRendererInstance:TObject;const aInFlightFrameIndex:TpvSizeInt);
      public
       property VulkanDevice:TpvVulkanDevice read fVulkanDevice;
       property DescriptorSet:TpvVulkanDescriptorSet read fDescriptorSet;
       property Binding:TpvSizeInt read fBinding;
       property GGXImageView:TVkImageView read fGGXDescriptorImageInfo.ImageView write SetGGXImageView;
       property CharlieImageView:TVkImageView read fCharlieDescriptorImageInfo.ImageView write SetCharlieImageView;
       property LambertianImageView:TVkImageView read fLambertianDescriptorImageInfo.ImageView write SetLambertianImageView;
       property GGX2ImageView:TVkImageView read fGGX2DescriptorImageInfo.ImageView write SetGGX2ImageView;
       property Charlie2ImageView:TVkImageView read fCharlie2DescriptorImageInfo.ImageView write SetCharlie2ImageView;
       property Lambertian2ImageView:TVkImageView read fLambertian2DescriptorImageInfo.ImageView write SetLambertian2ImageView;
       property GGXDescriptorImageInfo:PVkDescriptorImageInfo read fPointerToGGXDescriptorImageInfo;
       property CharlieDescriptorImageInfo:PVkDescriptorImageInfo read fPointerToCharlieDescriptorImageInfo;
       property LambertianDescriptorImageInfo:PVkDescriptorImageInfo read fPointerToLambertianDescriptorImageInfo;
       property GGX2DescriptorImageInfo:PVkDescriptorImageInfo read fPointerToGGX2DescriptorImageInfo;
       property Charlie2DescriptorImageInfo:PVkDescriptorImageInfo read fPointerToCharlie2DescriptorImageInfo;
       property Lambertian2DescriptorImageInfo:PVkDescriptorImageInfo read fPointerToLambertian2DescriptorImageInfo;
     end; 

implementation

uses PasVulkan.Scene3D,
     PasVulkan.Scene3D.Atmosphere,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance;

constructor TpvScene3DRendererIBLDescriptor.Create(const aVulkanDevice:TpvVulkanDevice;const aDescriptorSet:TpvVulkanDescriptorSet;const aBinding:TpvSizeInt;const aSampler:TVkSampler);
begin
 inherited Create;

 fVulkanDevice:=aVulkanDevice;
 fDescriptorSet:=aDescriptorSet;

 fBinding:=aBinding;

 fGGXDescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
 fCharlieDescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
 fLambertianDescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

 fGGX2DescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
 fCharlie2DescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
 fLambertian2DescriptorImageInfo:=TVkDescriptorImageInfo.Create(aSampler,VK_NULL_HANDLE,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

 fPointerToGGXDescriptorImageInfo:=@fGGXDescriptorImageInfo;
 fPointerToCharlieDescriptorImageInfo:=@fCharlieDescriptorImageInfo;
 fPointerToLambertianDescriptorImageInfo:=@fLambertianDescriptorImageInfo;

 fPointerToGGX2DescriptorImageInfo:=@fGGX2DescriptorImageInfo;
 fPointerToCharlie2DescriptorImageInfo:=@fCharlie2DescriptorImageInfo;
 fPointerToLambertian2DescriptorImageInfo:=@fLambertian2DescriptorImageInfo;

 fDirty:=true;

end;

destructor TpvScene3DRendererIBLDescriptor.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererIBLDescriptor.SetGGXImageView(const aGGXImageView:TVkImageView);
begin
 if fGGXDescriptorImageInfo.ImageView<>aGGXImageView then begin
  fGGXDescriptorImageInfo.ImageView:=aGGXImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetCharlieImageView(const aCharlieImageView:TVkImageView);
begin
 if fCharlieDescriptorImageInfo.ImageView<>aCharlieImageView then begin
  fCharlieDescriptorImageInfo.ImageView:=aCharlieImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetLambertianImageView(const aLambertianImageView:TVkImageView);
begin
 if fLambertianDescriptorImageInfo.ImageView<>aLambertianImageView then begin
  fLambertianDescriptorImageInfo.ImageView:=aLambertianImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetGGX2ImageView(const aGGX2ImageView:TVkImageView);
begin
 if fGGX2DescriptorImageInfo.ImageView<>aGGX2ImageView then begin
  fGGX2DescriptorImageInfo.ImageView:=aGGX2ImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetCharlie2ImageView(const aCharlie2ImageView:TVkImageView);
begin
 if fCharlie2DescriptorImageInfo.ImageView<>aCharlie2ImageView then begin
  fCharlie2DescriptorImageInfo.ImageView:=aCharlie2ImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetLambertian2ImageView(const aLambertian2ImageView:TVkImageView);
begin
 if fLambertian2DescriptorImageInfo.ImageView<>aLambertian2ImageView then begin
  fLambertian2DescriptorImageInfo.ImageView:=aLambertian2ImageView;
  fDirty:=true;
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.Update(const aInstant:Boolean=false);
begin
 if fDirty then begin
  fDirty:=false;
  fDescriptorSet.WriteToDescriptorSet(fBinding,
                                      0,
                                      6,
                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                      [fGGXDescriptorImageInfo,
                                       fCharlieDescriptorImageInfo,
                                       fLambertianDescriptorImageInfo,
                                       fGGX2DescriptorImageInfo,
                                       fCharlie2DescriptorImageInfo,
                                       fLambertian2DescriptorImageInfo],
                                      [],
                                      [],
                                      aInstant);
 end;
end;

procedure TpvScene3DRendererIBLDescriptor.SetFrom(const aScene3D,aRendererInstance:TObject;const aInFlightFrameIndex:TpvSizeInt);
var Index:TpvSizeInt;
    Atmosphere:TpvScene3DAtmosphere;
    AtmosphereRendererInstance:TpvScene3DAtmosphere.TRendererInstance;
    OK:Boolean;
begin

 if assigned(aRendererInstance) then begin

  if assigned(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps) then begin
   SetGGXImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.GGXDescriptorImageInfos[aInFlightFrameIndex].imageView);
   SetCharlieImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.CharlieDescriptorImageInfos[aInFlightFrameIndex].imageView);
   SetLambertianImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.LambertianDescriptorImageInfos[aInFlightFrameIndex].imageView);
  end else if assigned(TpvScene3DRendererInstance(aRendererInstance).Renderer) then begin
   SetGGXImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo.imageView);
   SetCharlieImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo.imageView);
   SetLambertianImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo.imageView);
  end;

  if assigned(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps) then begin
   SetGGX2ImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.GGXDescriptorImageInfos[aInFlightFrameIndex].imageView);
   SetCharlie2ImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.CharlieDescriptorImageInfos[aInFlightFrameIndex].imageView);
   SetLambertian2ImageView(TpvScene3DRendererInstance(aRendererInstance).ImageBasedLightingReflectionProbeCubeMaps.LambertianDescriptorImageInfos[aInFlightFrameIndex].imageView);
   exit;
  end;

  OK:=false;
  TpvScene3DAtmospheres(TpvScene3D(aScene3D).Atmospheres).Lock.AcquireRead;
  try
   for Index:=0 to TpvScene3DAtmospheres(TpvScene3D(aScene3D).Atmospheres).Count-1 do begin
    Atmosphere:=TpvScene3DAtmospheres(TpvScene3D(aScene3D).Atmospheres).Items[Index];
    if assigned(Atmosphere) and Atmosphere.IsInFlightFrameVisible(aInFlightFrameIndex) then begin
     AtmosphereRendererInstance:=Atmosphere.GetRenderInstance(TpvScene3DRendererInstance(aRendererInstance));
     if assigned(AtmosphereRendererInstance) then begin
      SetGGX2ImageView(AtmosphereRendererInstance.GGXCubeMapTexture.VulkanImageView.Handle);
      SetCharlie2ImageView(AtmosphereRendererInstance.CharlieCubeMapTexture.VulkanImageView.Handle);
      SetLambertian2ImageView(AtmosphereRendererInstance.LambertianCubeMapTexture.VulkanImageView.Handle);
      OK:=true;
      break;
     end;
    end;
   end;
  finally
   TpvScene3DAtmospheres(TpvScene3D(aScene3D).Atmospheres).Lock.ReleaseRead;
  end;
  if OK then begin
   exit;
  end;

  if assigned(TpvScene3DRendererInstance(aRendererInstance).Renderer) then begin
   SetGGX2ImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo.imageView);
   SetCharlie2ImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo.imageView);
   SetLambertian2ImageView(TpvScene3DRendererInstance(aRendererInstance).Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo.imageView);
   exit;
  end;

 end;

end;

end.
