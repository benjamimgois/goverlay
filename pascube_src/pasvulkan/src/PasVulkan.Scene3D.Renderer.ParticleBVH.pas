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
unit PasVulkan.Scene3D.Renderer.ParticleBVH;
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
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer;

type { TpvScene3DRendererParticleBVH }
     // Self-contained, GI-technique-NEUTRAL particle BVH subsystem: owns the per-frame GPU buffers for a per-frame-built LBVH
     // over the particle emitters (particles are not in the hardware ray-tracing BLAS). Any consumer software-traces it
     // (the DDGI trace now; a pure-path-tracing path later) via particle_bvh_trace.glsl using the emitter + node buffer device
     // addresses — there is no shared descriptor contract. The build pipeline (extract -> AABB -> Morton -> radix sort ->
     // Karras hierarchy -> AABB refit) is the separate ParticleBVHComputePass; layouts are in particle_bvh.glsl. Kept entirely
     // out of the DDGI (and any other technique's) code so it can be reused without coupling.
     TpvScene3DRendererParticleBVH=class
      public
       type TBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
      private
       fRenderer:TpvScene3DRenderer;
       fActive:boolean;
       fEmitterBuffers:TBuffers;        // ParticleEmitter[CAPACITY] (positionRadius + emissionType); BDA
       fMortonABuffers:TBuffers;        // uvec2[CAPACITY] (key, emitter index) — sorted result lands here
       fMortonBBuffers:TBuffers;        // uvec2[CAPACITY] radix ping-pong scratch
       fRadixHistogramBuffers:TBuffers; // uint[RADIX_BINS*NUM_GROUPS] radix histogram / scanned offsets
       fNodeBuffers:TBuffers;           // ParticleBVHNode[2*CAPACITY] (read by consumers); BDA
       fParentBuffers:TBuffers;         // uint[2*CAPACITY] parent pointers
       fRefitCounterBuffers:TBuffers;   // uint[CAPACITY] per-internal-node atomic refit counters
       fBoundsBuffers:TBuffers;         // uint[6] world bounds (ordered-uint flipped)
      public
       constructor Create(const aRenderer:TpvScene3DRenderer); reintroduce;
       destructor Destroy; override;
       class function MustBeCreated(const aRenderer:TpvScene3DRenderer):boolean; static;
       procedure AcquireVolatileResources; // (re)allocate the per-frame buffers when active
       procedure ReleaseVolatileResources; // free them
       // True when a consumer of the particle BVH is active. THE single OR-point — add future consumers (e.g. a pure
       // path-tracing path) to this predicate; gates allocation, the build-pass registration and the per-consumer injection.
       property Active:boolean read fActive;
       property EmitterBuffers:TBuffers read fEmitterBuffers;
       property MortonABuffers:TBuffers read fMortonABuffers;
       property MortonBBuffers:TBuffers read fMortonBBuffers;
       property RadixHistogramBuffers:TBuffers read fRadixHistogramBuffers;
       property NodeBuffers:TBuffers read fNodeBuffers;
       property ParentBuffers:TBuffers read fParentBuffers;
       property RefitCounterBuffers:TBuffers read fRefitCounterBuffers;
       property BoundsBuffers:TBuffers read fBoundsBuffers;
     end;

implementation

constructor TpvScene3DRendererParticleBVH.Create(const aRenderer:TpvScene3DRenderer);
begin

 inherited Create;

 fRenderer:=aRenderer;

 // Consumers of the particle BVH. Currently only the DDGI trace software-injects particles; OR future consumers here.
 fActive:=MustBeCreated(fRenderer);

 FillChar(fEmitterBuffers,SizeOf(TBuffers),#0);
 FillChar(fMortonABuffers,SizeOf(TBuffers),#0);
 FillChar(fMortonBBuffers,SizeOf(TBuffers),#0);
 FillChar(fRadixHistogramBuffers,SizeOf(TBuffers),#0);
 FillChar(fNodeBuffers,SizeOf(TBuffers),#0);
 FillChar(fParentBuffers,SizeOf(TBuffers),#0);
 FillChar(fRefitCounterBuffers,SizeOf(TBuffers),#0);
 FillChar(fBoundsBuffers,SizeOf(TBuffers),#0);

end;

destructor TpvScene3DRendererParticleBVH.Destroy;
begin
 ReleaseVolatileResources;
 inherited Destroy;
end;

class function TpvScene3DRendererParticleBVH.MustBeCreated(const aRenderer:TpvScene3DRenderer):boolean;
begin
 result:=aRenderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination;
end;

procedure TpvScene3DRendererParticleBVH.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 ReleaseVolatileResources; // idempotent: tolerate a re-prepare without leaking

 if fActive then begin

  for InFlightFrameIndex:=0 to fRenderer.CountInFlightFrames-1 do begin

   // Emitter + node buffers are BDA (consumers read them by device address). The rest are build-internal SSBOs. All sized for
   // the fixed CAPACITY = TpvScene3D.MaxParticles (a power of two); see particle_bvh.glsl for the matching layouts.

   fEmitterBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                               TpvSizeInt(TpvScene3D.MaxParticles)*SizeOf(TpvVector4)*2, // ParticleEmitter = 2*vec4
                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                               0,0,0,0,0,0,0,
                                                               [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                               0,pvAllocationGroupIDScene3DStatic,
                                                               'TpvScene3DRendererParticleBVH.fEmitterBuffers['+IntToStr(InFlightFrameIndex)+']');

   fMortonABuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                               TpvSizeInt(TpvScene3D.MaxParticles)*SizeOf(TpvUInt32)*2, // uvec2 (key, index)
                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                               0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                               'TpvScene3DRendererParticleBVH.fMortonABuffers['+IntToStr(InFlightFrameIndex)+']');

   fMortonBBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                               TpvSizeInt(TpvScene3D.MaxParticles)*SizeOf(TpvUInt32)*2,
                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                               0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                               'TpvScene3DRendererParticleBVH.fMortonBBuffers['+IntToStr(InFlightFrameIndex)+']');

   fRadixHistogramBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                                      TpvSizeInt(256)*TpvSizeInt(256)*SizeOf(TpvUInt32), // RADIX_BINS * NUM_GROUPS
                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                      0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                                      'TpvScene3DRendererParticleBVH.fRadixHistogramBuffers['+IntToStr(InFlightFrameIndex)+']');

   fNodeBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                            TpvSizeInt(TpvScene3D.MaxParticles)*2*SizeOf(TpvVector4)*2, // 2*CAPACITY nodes, ParticleBVHNode = 2*vec4
                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                            0,0,0,0,0,0,0,
                                                            [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                            0,pvAllocationGroupIDScene3DStatic,
                                                            'TpvScene3DRendererParticleBVH.fNodeBuffers['+IntToStr(InFlightFrameIndex)+']');

   fParentBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                              TpvSizeInt(TpvScene3D.MaxParticles)*2*SizeOf(TpvUInt32), // 2*CAPACITY parents
                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                              0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                              'TpvScene3DRendererParticleBVH.fParentBuffers['+IntToStr(InFlightFrameIndex)+']');

   fRefitCounterBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                                    TpvSizeInt(TpvScene3D.MaxParticles)*SizeOf(TpvUInt32), // one per internal node (< CAPACITY)
                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                    TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                    0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                                    'TpvScene3DRendererParticleBVH.fRefitCounterBuffers['+IntToStr(InFlightFrameIndex)+']');

   fBoundsBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fRenderer.VulkanDevice,
                                                              16*SizeOf(TpvUInt32), // 6 used (min xyz / max xyz), padded
                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                              0,0,0,0,0,0,0,[],0,pvAllocationGroupIDScene3DStatic,
                                                              'TpvScene3DRendererParticleBVH.fBoundsBuffers['+IntToStr(InFlightFrameIndex)+']');

  end;

 end;

end;

procedure TpvScene3DRendererParticleBVH.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fEmitterBuffers[InFlightFrameIndex]);
  FreeAndNil(fMortonABuffers[InFlightFrameIndex]);
  FreeAndNil(fMortonBBuffers[InFlightFrameIndex]);
  FreeAndNil(fRadixHistogramBuffers[InFlightFrameIndex]);
  FreeAndNil(fNodeBuffers[InFlightFrameIndex]);
  FreeAndNil(fParentBuffers[InFlightFrameIndex]);
  FreeAndNil(fRefitCounterBuffers[InFlightFrameIndex]);
  FreeAndNil(fBoundsBuffers[InFlightFrameIndex]);
 end;
end;

end.
