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
unit PasVulkan.POCA.Scene3D;
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
     POCA,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.POCA,
     PasVulkan.Image.QOI,
     PasVulkan.Application,
     PasVulkan.Scene3D;

// Ghost type pointer vars — each points to the corresponding const ghost type record.
// Initialised in InitializePOCAScene3DContext; checked by callers to detect ghost type identity.
var POCAScene3DSceneGhostPointer:PPOCAGhostType=nil;
    POCAScene3DSceneGhostHash:TPOCAValue;        // methods on the TpvScene3D root ghost
    POCAScene3DGroupGhostPointer:PPOCAGhostType=nil;
    POCAScene3DGroupGhostHash:TPOCAValue;
    POCAScene3DMeshGhostPointer:PPOCAGhostType=nil;
    POCAScene3DMeshGhostHash:TPOCAValue;
    POCAScene3DPrimitiveGhostPointer:PPOCAGhostType=nil;
    POCAScene3DPrimitiveGhostHash:TPOCAValue;
    POCAScene3DNodeGhostPointer:PPOCAGhostType=nil;
    POCAScene3DNodeGhostHash:TPOCAValue;
    POCAScene3DGroupSceneGhostPointer:PPOCAGhostType=nil;
    POCAScene3DGroupSceneGhostHash:TPOCAValue;
    POCAScene3DInstanceGhostPointer:PPOCAGhostType=nil;
    POCAScene3DInstanceGhostHash:TPOCAValue;
    POCAScene3DRenderInstanceGhostPointer:PPOCAGhostType=nil;
    POCAScene3DRenderInstanceGhostHash:TPOCAValue;
    POCAScene3DMaterialGhostPointer:PPOCAGhostType=nil;
    POCAScene3DMaterialGhostHash:TPOCAValue;
    POCAScene3DImageGhostPointer:PPOCAGhostType=nil;
    POCAScene3DImageGhostHash:TPOCAValue;
    POCAScene3DSamplerGhostPointer:PPOCAGhostType=nil;
    POCAScene3DSamplerGhostHash:TPOCAValue;
    POCAScene3DTextureGhostPointer:PPOCAGhostType=nil;
    POCAScene3DTextureGhostHash:TPOCAValue;
    POCAScene3DLightGhostPointer:PPOCAGhostType=nil;
    POCAScene3DLightGhostHash:TPOCAValue;
    POCAScene3DGroupLightGhostPointer:PPOCAGhostType=nil;
    POCAScene3DGroupLightGhostHash:TPOCAValue;
    POCAScene3DDecalGhostPointer:PPOCAGhostType=nil;
    POCAScene3DDecalGhostHash:TPOCAValue;
    POCAScene3DBakedMeshGhostPointer:PPOCAGhostType=nil;
    POCAScene3DBakedMeshGhostHash:TPOCAValue;

// Creates a POCA ghost wrapping aScene3D. The ghost's method hash is POCAScene3DSceneGhostHash,
// so engine.scene3d.createGroup(...) etc. dispatch correctly.
// The TpvScene3D lifetime is managed externally; destroying the ghost is a no-op.
function POCANewScene3DGhost(const aContext:PPOCAContext;const aScene3D:TpvScene3D):TPOCAValue;

// Creates a POCA ghost for a TImage. The ghost owns one reference (IncRef was called by the caller).
// Ghost destroy calls DecRef.
function POCANewScene3DImageGhost(const aContext:PPOCAContext;const aImage:TpvScene3D.TImage):TPOCAValue;

// Creates a POCA ghost for a TSampler. The ghost owns one reference.
function POCANewScene3DSamplerGhost(const aContext:PPOCAContext;const aSampler:TpvScene3D.TSampler):TPOCAValue;

// Creates a POCA ghost for a TTexture. The ghost owns one reference.
function POCANewScene3DTextureGhost(const aContext:PPOCAContext;const aTexture:TpvScene3D.TTexture):TPOCAValue;

// Creates a POCA ghost for a TMaterial. The ghost owns one reference.
function POCANewScene3DMaterialGhost(const aContext:PPOCAContext;const aMaterial:TpvScene3D.TMaterial):TPOCAValue;

// Creates a POCA ghost for a TGroup.TInstance. Lifetime is managed by the caller.
function POCANewScene3DInstanceGhost(const aContext:PPOCAContext;const aInstance:TpvScene3D.TGroup.TInstance):TPOCAValue;

// Registers all Scene3D ghost types and method hashes.
// Call once per POCA context after the engine hash is created.
// Does NOT set engine.scene3d — call RegisterPOCAScene3DGhost separately when Scene3D is available.
procedure InitializePOCAScene3DContext(const aContext:PPOCAContext;const aEngineHash:TPOCAValue);

// Sets engine.scene3d on aEngineHash to a ghost wrapping aScene3D.
// Call when TGame (and its Scene3D) is created.
procedure RegisterPOCAScene3DGhost(const aContext:PPOCAContext;const aScene3D:TpvScene3D;const aEngineHash:TPOCAValue);

// Removes engine.scene3d from aEngineHash.
// Call when TGame (and its Scene3D) is destroyed.
procedure UnregisterPOCAScene3DGhost(const aContext:PPOCAContext;const aEngineHash:TPOCAValue);

implementation

// --- Shared internal types -------------------------------------------------------

// Per-animation high-level playback state for Scene3DInstance ghosts.
type TScene3DInstanceAnimState=record
      Speed:TpvDouble;
      Loop:Boolean;
     end;
     TScene3DInstanceAnimStates=array of TScene3DInstanceAnimState;

// Scene3DDecal ghost data: carries Scene3D reference and decal pointer.
// The Decal is owned by TpvScene3D; ghost destroy frees only this record.
     PScene3DDecalGhostData=^TScene3DDecalGhostData;
     TScene3DDecalGhostData=record
      Scene3D:TpvScene3D;
      Decal:TpvScene3D.TDecal;
     end;

// Wrapper carried in the Scene3DInstance ghost Ptr; owns the TInstance and per-anim state.
     TScene3DInstanceGhostData=class
      public
       Instance:TpvScene3D.TGroup.TInstance;
       AnimStates:TScene3DInstanceAnimStates;
       LastHiResTime:TpvInt64;
       constructor Create(const aInstance:TpvScene3D.TGroup.TInstance);
       destructor Destroy; override;
       procedure EnsureAnimCount(const aCount:TpvSizeInt);
      end;

constructor TScene3DInstanceGhostData.Create(const aInstance:TpvScene3D.TGroup.TInstance);
begin
 inherited Create;
 Instance:=aInstance;
 AnimStates:=nil;
 LastHiResTime:=pvApplication.HighResolutionTimer.GetTime;
end;

destructor TScene3DInstanceGhostData.Destroy;
begin
 AnimStates:=nil;
 inherited Destroy;
end;

procedure TScene3DInstanceGhostData.EnsureAnimCount(const aCount:TpvSizeInt);
var OldCount,Idx:TpvSizeInt;
begin
 OldCount:=length(AnimStates);
 if aCount>OldCount then begin
  SetLength(AnimStates,aCount);
  for Idx:=OldCount to aCount-1 do begin
   AnimStates[Idx].Speed:=1.0;
   AnimStates[Idx].Loop:=false;
  end;
 end;
end;


// --- Image -----------------------------------------------------------------------

// Ghost destroy procedures - called by POCA GC when a ghost value is collected.
procedure POCAScene3DImageGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Use img.destroy() to DecRef explicitly.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

// Ghost type const records - addresses used as type identity tokens.
// Destroy: nil for types whose lifetime is managed externally or by the scene.
const POCAScene3DImageGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DImageGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DImage'
       );

function POCANewScene3DImageGhost(const aContext:PPOCAContext;const aImage:TpvScene3D.TImage):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DImageGhost,aImage,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DImageGhostHash);
end;

// img.upload() — GPU upload (synchronous) + descriptor generation trigger (Q4: one render frame delay)
function POCAScene3DImageFunctionUpload(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Image:TpvScene3D.TImage;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)=@POCAScene3DImageGhost then begin
  Image:=TpvScene3D.TImage(POCAGhostFastGetPointer(aThis));
  if assigned(Image) then begin
   Image.Upload;
   Image.SceneInstance.NewImageDescriptorGeneration;
   result:=aThis;
  end else begin
   result:=POCAValueNull;
  end;
 end else begin
  result:=POCAValueNull;
 end;
end;

// img.isUploaded() — returns 1 if GPU upload has completed, 0 otherwise
function POCAScene3DImageFunctionIsUploaded(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Image:TpvScene3D.TImage;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)=@POCAScene3DImageGhost then begin
  Image:=TpvScene3D.TImage(POCAGhostFastGetPointer(aThis));
  if assigned(Image) then begin
   if boolean(Image.Uploaded) then begin
    result.Num:=1.0;
   end else begin
    result.Num:=0.0;
   end;
  end else begin
   result:=POCAValueNull;
  end;
 end else begin
  result:=POCAValueNull;
 end;
end;

// img.destroy() — explicit DecRef; nulls the ghost's Ptr to prevent double-free on GC
function POCAScene3DImageFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Image:TpvScene3D.TImage;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)=@POCAScene3DImageGhost then begin
  Ghost:=PPOCAGhost(POCAGetValueReferencePointer(aThis));
  if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
   Image:=TpvScene3D.TImage(Ghost^.Ptr);
   Ghost^.Ptr:=nil;
   Image.DecRef;
  end;
 end;
end;

// engine.scene3d.createImage(w, h, pixels)
// pixels: POCA array of w*h integers; each pixel = R|(G<<8)|(B<<16)|(A<<24)
// Returns image ghost (owned ref). Call img.upload() to upload to GPU.
function POCAScene3DSceneFunctionCreateImage(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Image:TpvScene3D.TImage;
    Width,Height,Index,Count:TpvInt32;
    PixelStream:TMemoryStream;
    PixelData:array of TpvUInt32;
begin
 result:=POCAValueNull;
 if (aCountArguments<3) or (POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer) then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Width:=round(POCAGetNumberValue(aContext,aArguments^[0]));
 Height:=round(POCAGetNumberValue(aContext,aArguments^[1]));
 if (Width<=0) or (Height<=0) then begin
  exit;
 end;
 Count:=Width*Height;
 SetLength(PixelData,Count);
 for Index:=0 to Count-1 do begin
  PixelData[Index]:=TpvUInt32(round(POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[2],Index))));
 end;
 PixelStream:=TMemoryStream.Create;
 try
  if SaveQOIImageAsStream(@PixelData[0],TpvUInt32(Width),TpvUInt32(Height),PixelStream,false) then begin
   Image:=TpvScene3D.TImage.Create(Scene3D.ResourceManager,Scene3D);
   Image.AssignFromStream('poca_image',PixelStream);
   Image.IncRef;
   result:=POCANewScene3DImageGhost(aContext,Image);
  end;
 finally
  FreeAndNil(PixelStream);
 end;
end;

// engine.scene3d.loadImage(path) — load image from asset by path; full synchronous upload via BeginLoad+EndLoad
function POCAScene3DSceneFunctionLoadImage(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Image:TpvScene3D.TImage;
    Path:TpvUTF8String;
    Stream:TStream;
begin
 result:=POCAValueNull;
 if (aCountArguments<1) or (POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer) then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Path:=POCAGetStringValue(aContext,aArguments^[0]);
 if not pvApplication.Assets.ExistAsset(Path) then begin
  exit;
 end;
 Stream:=pvApplication.Assets.GetAssetStream(Path);
 if not assigned(Stream) then begin
  exit;
 end;
 try
  Image:=TpvScene3D.TImage.Create(Scene3D.ResourceManager,Scene3D);
  Image.BeginLoad(Stream);
  Image.EndLoad;
  Image.IncRef;
  result:=POCANewScene3DImageGhost(aContext,Image);
 finally
 FreeAndNil(Stream);
 end;
end;

// engine.scene3d.getImageByName(name) — returns ghost (owned ref) for named image, or null
function POCAScene3DSceneFunctionGetImageByName(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Image:TpvScene3D.TImage;
begin
 result:=POCAValueNull;
 if (aCountArguments<1) or (POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer) then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Image:=Scene3D.GetImageByName(POCAGetStringValue(aContext,aArguments^[0]));
 if not assigned(Image) then begin
  exit;
 end;
 Image.IncRef; // ghost owns a reference; ghost Destroy calls DecRef
 result:=POCANewScene3DImageGhost(aContext,Image);
end;


// --- Sampler ---------------------------------------------------------------------

procedure POCAScene3DSamplerGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Use sampler.destroy() to DecRef explicitly.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DSamplerGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DSamplerGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DSampler'
       );

function POCANewScene3DSamplerGhost(const aContext:PPOCAContext;const aSampler:TpvScene3D.TSampler):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DSamplerGhost,aSampler,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DSamplerGhostHash);
end;

// sampler.destroy()
function POCAScene3DSamplerFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Sampler:TpvScene3D.TSampler;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)=@POCAScene3DSamplerGhost then begin
  Ghost:=PPOCAGhost(POCAGetValueReferencePointer(aThis));
  if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
   Sampler:=TpvScene3D.TSampler(Ghost^.Ptr);
   Ghost^.Ptr:=nil;
   Sampler.DecRef;
  end;
 end;
end;

// engine.scene3d.createSampler(type)
// type: 'default' | 'nonrepeat' | 'mipmap' | 'mipmapnonrepeat' (default: 'default')
function POCAScene3DSceneFunctionCreateSampler(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Sampler:TpvScene3D.TSampler;
    SamplerType:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 if aCountArguments>0 then begin
  SamplerType:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  SamplerType:='default';
 end;
 Sampler:=TpvScene3D.TSampler.Create(Scene3D.ResourceManager,Scene3D);
 if SamplerType='nonrepeat' then begin
  Sampler.AssignFromDefaultNonRepeat;
 end else if SamplerType='mipmap' then begin
  Sampler.AssignFromDefaultMipMap;
 end else if SamplerType='mipmapnonrepeat' then begin
  Sampler.AssignFromDefaultMipMapNonRepeat;
 end else begin
  Sampler.AssignFromDefault;
 end;
 Sampler.IncRef;
 result:=POCANewScene3DSamplerGhost(aContext,Sampler);
end;

// engine.scene3d.defaultSampler() — ghost (owned ref) for the scene's default repeat sampler
function POCAScene3DSceneFunctionDefaultSampler(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not (assigned(Scene3D) and assigned(Scene3D.DefaultSampler)) then begin
  exit;
 end;
 Scene3D.DefaultSampler.IncRef;
 result:=POCANewScene3DSamplerGhost(aContext,Scene3D.DefaultSampler);
end;

// engine.scene3d.defaultNonRepeatSampler()
function POCAScene3DSceneFunctionDefaultNonRepeatSampler(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not (assigned(Scene3D) and assigned(Scene3D.DefaultNonRepeatSampler)) then begin
  exit;
 end;
 Scene3D.DefaultNonRepeatSampler.IncRef;
 result:=POCANewScene3DSamplerGhost(aContext,Scene3D.DefaultNonRepeatSampler);
end;


// --- Texture ---------------------------------------------------------------------

procedure POCAScene3DTextureGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Use texture.destroy() to DecRef explicitly.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DTextureGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DTextureGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DTexture'
       );

function POCANewScene3DTextureGhost(const aContext:PPOCAContext;const aTexture:TpvScene3D.TTexture):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DTextureGhost,aTexture,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DTextureGhostHash);
end;

// texture.destroy()
function POCAScene3DTextureFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Texture:TpvScene3D.TTexture;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)=@POCAScene3DTextureGhost then begin
  Ghost:=PPOCAGhost(POCAGetValueReferencePointer(aThis));
  if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
   Texture:=TpvScene3D.TTexture(Ghost^.Ptr);
   Ghost^.Ptr:=nil;
   Texture.DecRef;
  end;
 end;
end;

// engine.scene3d.createTexture(image, sampler)
// image: Scene3DImage ghost; sampler: Scene3DSampler ghost (optional, defaults to scene default)
function POCAScene3DSceneFunctionCreateTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Texture:TpvScene3D.TTexture;
    Image:TpvScene3D.TImage;
    Sampler:TpvScene3D.TSampler;
begin
 result:=POCAValueNull;
 if (aCountArguments<1) or (POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DImageGhost then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Image:=TpvScene3D.TImage(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Image) then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture.Create(Scene3D.ResourceManager,Scene3D);
 // AssignForImage does Image.IncRef + DefaultSampler.IncRef for us
 Texture.AssignForImage('poca_texture',Image);
 // Swap to custom sampler if provided (undo default sampler IncRef from AssignForImage)
 if (aCountArguments>=2) and (POCAGhostGetType(aArguments^[1])=@POCAScene3DSamplerGhost) then begin
  Sampler:=TpvScene3D.TSampler(POCAGhostFastGetPointer(aArguments^[1]));
  if assigned(Sampler) and (Sampler<>Scene3D.DefaultSampler) then begin
   Scene3D.DefaultSampler.DecRef; // undo AssignForImage's DefaultSampler IncRef
   Sampler.IncRef;                // texture now owns a ref to the custom sampler
   Texture.Sampler:=Sampler;
  end;
 end;
 Texture.IncRef;
 result:=POCANewScene3DTextureGhost(aContext,Texture);
end;

// engine.scene3d.createTextureFromImage(w, h, pixels)
// Convenience: creates image from pixel array + default sampler + texture in one call.
// The image is owned by the texture; no separate image ghost is returned.
function POCAScene3DSceneFunctionCreateTextureFromImage(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Image:TpvScene3D.TImage;
    Texture:TpvScene3D.TTexture;
    Width,Height,Index,Count:TpvInt32;
    PixelStream:TMemoryStream;
    PixelData:array of TpvUInt32;
begin
 result:=POCAValueNull;
 if (aCountArguments<3) or (POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer) then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Width:=round(POCAGetNumberValue(aContext,aArguments^[0]));
 Height:=round(POCAGetNumberValue(aContext,aArguments^[1]));
 if (Width<=0) or (Height<=0) then begin
  exit;
 end;
 Count:=Width*Height;
 SetLength(PixelData,Count);
 for Index:=0 to Count-1 do begin
  PixelData[Index]:=TpvUInt32(round(POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[2],Index))));
 end;
 PixelStream:=TMemoryStream.Create;
 try
  if SaveQOIImageAsStream(@PixelData[0],TpvUInt32(Width),TpvUInt32(Height),PixelStream,false) then begin
   Image:=TpvScene3D.TImage.Create(Scene3D.ResourceManager,Scene3D);
   Image.AssignFromStream('poca_image',PixelStream);
   Texture:=TpvScene3D.TTexture.Create(Scene3D.ResourceManager,Scene3D);
   // AssignForImage takes ownership of Image (IncRef) + uses default sampler (IncRef)
   Texture.AssignForImage('poca_texture',Image);
   Texture.IncRef;
   result:=POCANewScene3DTextureGhost(aContext,Texture);
  end;
 finally
  FreeAndNil(PixelStream);
 end;
end;


// --- Material --------------------------------------------------------------------

procedure POCAScene3DMaterialGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Use material.destroy() to DecRef explicitly.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DMaterialGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DMaterialGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DMaterial'
       );

function POCANewScene3DMaterialGhost(const aContext:PPOCAContext;const aMaterial:TpvScene3D.TMaterial):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DMaterialGhost,aMaterial,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DMaterialGhostHash);
end;

// helper: apply hologram opts hash fields to a THologram record
procedure POCAScene3DApplyHologramFromHash(const aContext:PPOCAContext;const aHash:TPOCAValue;var aHologram:TpvScene3D.TMaterial.THologram);
var OutValue:TPOCAValue;
begin
 OutValue:=POCAHashGetString(aContext,aHash,'active');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.Active:=POCAGetNumberValue(aContext,OutValue)<>0;
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'flickerSpeed');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.FlickerSpeed:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'flickerMin');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.FlickerMin:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'flickerMax');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.FlickerMax:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'rimPower');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.RimPower:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'rimThreshold');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.RimThreshold:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'scanTiling');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.ScanTiling:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'scanSpeed');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.ScanSpeed:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'scanMin');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.ScanMin:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'scanMax');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.ScanMax:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'glowTiling');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.GlowTiling:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'glowSpeed');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.GlowSpeed:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'glowMin');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.GlowMin:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'glowMax');
 if POCAGetValueType(OutValue)=pvtNUMBER then begin
  aHologram.GlowMax:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'direction');
 if POCAGetValueType(OutValue)=pvtARRAY then begin
  aHologram.Direction.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
  aHologram.Direction.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
  aHologram.Direction.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'mainColor');
 if POCAGetValueType(OutValue)=pvtARRAY then begin
  aHologram.MainColorFactor.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
  aHologram.MainColorFactor.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
  aHologram.MainColorFactor.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
  aHologram.MainColorFactor.w:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,3));
 end;
 OutValue:=POCAHashGetString(aContext,aHash,'rimColor');
 if POCAGetValueType(OutValue)=pvtARRAY then begin
  aHologram.RimColorFactor.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
  aHologram.RimColorFactor.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
  aHologram.RimColorFactor.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
  aHologram.RimColorFactor.w:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,3));
 end;
end;

// helper: assign a TTexture pointer to a TTextureReference, maintaining ref-count ownership
procedure POCAScene3DAssignTextureToRef(const aTexture:TpvScene3D.TTexture;var aRef:TpvScene3D.TMaterial.TTextureReference;const aTexCoord:TpvSizeInt);
begin
 if assigned(aRef.Texture) then begin
  aRef.Texture.DecRef;
 end;
 aRef.Texture:=aTexture;
 aRef.TexCoord:=aTexCoord;
 if assigned(aRef.Texture) then begin
  aRef.Texture.IncRef;
 end;
end;

// mat.setShadingModel('pbr' | 'specularGlossiness' | 'unlit')
function POCAScene3DMaterialFunctionSetShadingModel(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Model:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Model:=POCAGetStringValue(aContext,aArguments^[0]);
 if Model='specularGlossiness' then begin
  Mat.Data^.ShadingModel:=TpvScene3D.TMaterial.TShadingModel.PBRSpecularGlossiness;
 end else if Model='unlit' then begin
  Mat.Data^.ShadingModel:=TpvScene3D.TMaterial.TShadingModel.Unlit;
 end else begin
  Mat.Data^.ShadingModel:=TpvScene3D.TMaterial.TShadingModel.PBRMetallicRoughness;
 end;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setAlphaMode('opaque' | 'mask' | 'blend')
function POCAScene3DMaterialFunctionSetAlphaMode(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Mode:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mode:=POCAGetStringValue(aContext,aArguments^[0]);
 if Mode='mask' then begin
  Mat.Data^.AlphaMode:=TpvScene3D.TMaterial.TAlphaMode.Mask;
 end else if Mode='blend' then begin
  Mat.Data^.AlphaMode:=TpvScene3D.TMaterial.TAlphaMode.Blend;
 end else begin
  Mat.Data^.AlphaMode:=TpvScene3D.TMaterial.TAlphaMode.Opaque;
 end;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setAlphaCutoff(f)
function POCAScene3DMaterialFunctionSetAlphaCutoff(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.AlphaCutOff:=POCAGetNumberValue(aContext,aArguments^[0]);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setDoubleSided(bool)
function POCAScene3DMaterialFunctionSetDoubleSided(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.DoubleSided:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setCastShadows(bool)
function POCAScene3DMaterialFunctionSetCastShadows(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.CastingShadows:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setReceiveShadows(bool)
function POCAScene3DMaterialFunctionSetReceiveShadows(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.ReceiveShadows:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setNoWetness(bool)
function POCAScene3DMaterialFunctionSetNoWetness(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.NoWetness:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setBaseColorFactor(r, g, b, a)
// or mat.setBaseColorFactor(Vector4 | array[4] | {r,g,b,a})
function POCAScene3DMaterialFunctionSetBaseColorFactor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Color:TpvVector4;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAIsVector4Value(aContext,aArguments^[0]) then begin
  Color:=POCAGetVector4Value(aContext,aArguments^[0]);
 end else begin
  if aCountArguments<4 then begin
   exit;
  end;
  Color.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  Color.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  Color.z:=POCAGetNumberValue(aContext,aArguments^[2]);
  Color.w:=POCAGetNumberValue(aContext,aArguments^[3]);
 end;
 Mat.Data^.PBRMetallicRoughness.BaseColorFactor:=Color;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setMetallicFactor(f)
function POCAScene3DMaterialFunctionSetMetallicFactor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.PBRMetallicRoughness.MetallicFactor:=POCAGetNumberValue(aContext,aArguments^[0]);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setRoughnessFactor(f)
function POCAScene3DMaterialFunctionSetRoughnessFactor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 Mat.Data^.PBRMetallicRoughness.RoughnessFactor:=POCAGetNumberValue(aContext,aArguments^[0]);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setEmissiveFactor(r, g, b)  — w (EmissiveStrength) remains unchanged
// or mat.setEmissiveFactor(Vector3 | array[3] | {r,g,b})
function POCAScene3DMaterialFunctionSetEmissiveFactor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Emissive:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAIsVector3Value(aContext,aArguments^[0]) then begin
  Emissive:=POCAGetVector3Value(aContext,aArguments^[0]);
  Mat.Data^.EmissiveFactor.x:=Emissive.x;
  Mat.Data^.EmissiveFactor.y:=Emissive.y;
  Mat.Data^.EmissiveFactor.z:=Emissive.z;
 end else begin
  if aCountArguments<3 then begin
   exit;
  end;
  Mat.Data^.EmissiveFactor.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  Mat.Data^.EmissiveFactor.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  Mat.Data^.EmissiveFactor.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 end;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setBaseColorTexture(tex [, texCoord=0])
function POCAScene3DMaterialFunctionSetBaseColorTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Texture:TpvScene3D.TTexture;
    TexCoord:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DTextureGhost then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Texture) then begin
  exit;
 end;
 if aCountArguments>=2 then begin
  TexCoord:=TpvSizeInt(round(POCAGetNumberValue(aContext,aArguments^[1])));
 end else begin
  TexCoord:=0;
 end;
 POCAScene3DAssignTextureToRef(Texture,Mat.Data^.PBRMetallicRoughness.BaseColorTexture,TexCoord);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setNormalTexture(tex [, scale=1.0 [, texCoord=0]])
function POCAScene3DMaterialFunctionSetNormalTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Texture:TpvScene3D.TTexture;
    TexCoord:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DTextureGhost then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Texture) then begin
  exit;
 end;
 if aCountArguments>=2 then begin
  Mat.Data^.NormalTextureScale:=POCAGetNumberValue(aContext,aArguments^[1]);
 end else begin
  Mat.Data^.NormalTextureScale:=1.0;
 end;
 if aCountArguments>=3 then begin
  TexCoord:=TpvSizeInt(round(POCAGetNumberValue(aContext,aArguments^[2])));
 end else begin
  TexCoord:=0;
 end;
 POCAScene3DAssignTextureToRef(Texture,Mat.Data^.NormalTexture,TexCoord);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setMetallicRoughnessTexture(tex [, texCoord=0])
function POCAScene3DMaterialFunctionSetMetallicRoughnessTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Texture:TpvScene3D.TTexture;
    TexCoord:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DTextureGhost then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Texture) then begin
  exit;
 end;
 if aCountArguments>=2 then begin
  TexCoord:=TpvSizeInt(round(POCAGetNumberValue(aContext,aArguments^[1])));
 end else begin
  TexCoord:=0;
 end;
 POCAScene3DAssignTextureToRef(Texture,Mat.Data^.PBRMetallicRoughness.MetallicRoughnessTexture,TexCoord);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setOcclusionTexture(tex [, strength=1.0 [, texCoord=0]])
function POCAScene3DMaterialFunctionSetOcclusionTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Texture:TpvScene3D.TTexture;
    TexCoord:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DTextureGhost then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Texture) then begin
  exit;
 end;
 if aCountArguments>=2 then begin
  Mat.Data^.OcclusionTextureStrength:=POCAGetNumberValue(aContext,aArguments^[1]);
 end else begin
  Mat.Data^.OcclusionTextureStrength:=1.0;
 end;
 if aCountArguments>=3 then begin
  TexCoord:=TpvSizeInt(round(POCAGetNumberValue(aContext,aArguments^[2])));
 end else begin
  TexCoord:=0;
 end;
 POCAScene3DAssignTextureToRef(Texture,Mat.Data^.OcclusionTexture,TexCoord);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setEmissiveTexture(tex [, texCoord=0])
function POCAScene3DMaterialFunctionSetEmissiveTexture(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
    Texture:TpvScene3D.TTexture;
    TexCoord:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGhostGetType(aArguments^[0])<>@POCAScene3DTextureGhost then begin
  exit;
 end;
 Texture:=TpvScene3D.TTexture(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Texture) then begin
  exit;
 end;
 if aCountArguments>=2 then begin
  TexCoord:=TpvSizeInt(round(POCAGetNumberValue(aContext,aArguments^[1])));
 end else begin
  TexCoord:=0;
 end;
 POCAScene3DAssignTextureToRef(Texture,Mat.Data^.EmissiveTexture,TexCoord);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.setHologram(opts)
function POCAScene3DMaterialFunctionSetHologram(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not (assigned(Mat) and (aCountArguments>=1)) then begin
  exit;
 end;
 if POCAGetValueType(aArguments^[0])<>pvtHASH then begin
  exit;
 end;
 POCAScene3DApplyHologramFromHash(aContext,aArguments^[0],Mat.Data^.Hologram);
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.fillShaderData() — explicit FillShaderData + GPU generation trigger (for batch updates)
function POCAScene3DMaterialFunctionFillShaderData(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aThis));
 if not assigned(Mat) then begin
  exit;
 end;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 result:=aThis;
end;

// mat.destroy() — explicit DecRef; nulls ghost Ptr to prevent double-free on GC
function POCAScene3DMaterialFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Mat:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMaterialGhost then begin
  exit;
 end;
 Ghost:=PPOCAGhost(POCAGetValueReferencePointer(aThis));
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Mat:=TpvScene3D.TMaterial(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  Mat.DecRef;
 end;
end;

// engine.scene3d.createMaterial([opts])
// opts keys: name, shadingModel, alphaMode, alphaCutoff, doubleSided, castShadows,
//   receiveShadows, noWetness, baseColor [r,g,b,a], metallic, roughness, emissive [r,g,b],
//   baseColorTexture, normalTexture, metallicRoughnessTexture, occlusionTexture,
//   emissiveTexture, hologram
function POCAScene3DSceneFunctionCreateMaterial(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Mat:TpvScene3D.TMaterial;
    OptsHash,OutValue:TPOCAValue;
    Name,Str:TpvUTF8String;
    Tex:TpvScene3D.TTexture;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Name:='poca_material';
 OptsHash:=POCAValueNull;
 if (aCountArguments>=1) and (POCAGetValueType(aArguments^[0])=pvtHASH) then begin
  OptsHash:=aArguments^[0];
  OutValue:=POCAHashGetString(aContext,OptsHash,'name');
  if POCAGetValueType(OutValue)=pvtSTRING then begin
   Name:=POCAGetStringValue(aContext,OutValue);
  end;
 end;
 Mat:=Scene3D.CreateMaterial(Name);
 if POCAGetValueType(OptsHash)=pvtHASH then begin
  OutValue:=POCAHashGetString(aContext,OptsHash,'shadingModel');
  if POCAGetValueType(OutValue)=pvtSTRING then begin
   Str:=POCAGetStringValue(aContext,OutValue);
   if Str='specularGlossiness' then begin
    Mat.Data^.ShadingModel:=TpvScene3D.TMaterial.TShadingModel.PBRSpecularGlossiness;
   end else if Str='unlit' then begin
    Mat.Data^.ShadingModel:=TpvScene3D.TMaterial.TShadingModel.Unlit;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'alphaMode');
  if POCAGetValueType(OutValue)=pvtSTRING then begin
   Str:=POCAGetStringValue(aContext,OutValue);
   if Str='mask' then begin
    Mat.Data^.AlphaMode:=TpvScene3D.TMaterial.TAlphaMode.Mask;
   end else if Str='blend' then begin
    Mat.Data^.AlphaMode:=TpvScene3D.TMaterial.TAlphaMode.Blend;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'alphaCutoff');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.AlphaCutOff:=POCAGetNumberValue(aContext,OutValue);
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'doubleSided');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.DoubleSided:=POCAGetNumberValue(aContext,OutValue)<>0;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'castShadows');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.CastingShadows:=POCAGetNumberValue(aContext,OutValue)<>0;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'receiveShadows');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.ReceiveShadows:=POCAGetNumberValue(aContext,OutValue)<>0;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'noWetness');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.NoWetness:=POCAGetNumberValue(aContext,OutValue)<>0;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'baseColor');
  if POCAGetValueType(OutValue)=pvtARRAY then begin
   Mat.Data^.PBRMetallicRoughness.BaseColorFactor.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
   Mat.Data^.PBRMetallicRoughness.BaseColorFactor.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
   Mat.Data^.PBRMetallicRoughness.BaseColorFactor.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
   Mat.Data^.PBRMetallicRoughness.BaseColorFactor.w:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,3));
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'metallic');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.PBRMetallicRoughness.MetallicFactor:=POCAGetNumberValue(aContext,OutValue);
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'roughness');
  if POCAGetValueType(OutValue)=pvtNUMBER then begin
   Mat.Data^.PBRMetallicRoughness.RoughnessFactor:=POCAGetNumberValue(aContext,OutValue);
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'emissive');
  if POCAGetValueType(OutValue)=pvtARRAY then begin
   Mat.Data^.EmissiveFactor.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
   Mat.Data^.EmissiveFactor.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
   Mat.Data^.EmissiveFactor.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'baseColorTexture');
  if POCAGetValueType(OutValue)=pvtGHOST then begin
   if POCAGhostGetType(OutValue)=@POCAScene3DTextureGhost then begin
    Tex:=TpvScene3D.TTexture(POCAGhostFastGetPointer(OutValue));
    if assigned(Tex) then begin
     POCAScene3DAssignTextureToRef(Tex,Mat.Data^.PBRMetallicRoughness.BaseColorTexture,0);
    end;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'normalTexture');
  if POCAGetValueType(OutValue)=pvtGHOST then begin
   if POCAGhostGetType(OutValue)=@POCAScene3DTextureGhost then begin
    Tex:=TpvScene3D.TTexture(POCAGhostFastGetPointer(OutValue));
    if assigned(Tex) then begin
     POCAScene3DAssignTextureToRef(Tex,Mat.Data^.NormalTexture,0);
    end;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'metallicRoughnessTexture');
  if POCAGetValueType(OutValue)=pvtGHOST then begin
   if POCAGhostGetType(OutValue)=@POCAScene3DTextureGhost then begin
    Tex:=TpvScene3D.TTexture(POCAGhostFastGetPointer(OutValue));
    if assigned(Tex) then begin
     POCAScene3DAssignTextureToRef(Tex,Mat.Data^.PBRMetallicRoughness.MetallicRoughnessTexture,0);
    end;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'occlusionTexture');
  if POCAGetValueType(OutValue)=pvtGHOST then begin
   if POCAGhostGetType(OutValue)=@POCAScene3DTextureGhost then begin
    Tex:=TpvScene3D.TTexture(POCAGhostFastGetPointer(OutValue));
    if assigned(Tex) then begin
     POCAScene3DAssignTextureToRef(Tex,Mat.Data^.OcclusionTexture,0);
    end;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'emissiveTexture');
  if POCAGetValueType(OutValue)=pvtGHOST then begin
   if POCAGhostGetType(OutValue)=@POCAScene3DTextureGhost then begin
    Tex:=TpvScene3D.TTexture(POCAGhostFastGetPointer(OutValue));
    if assigned(Tex) then begin
     POCAScene3DAssignTextureToRef(Tex,Mat.Data^.EmissiveTexture,0);
    end;
   end;
  end;
  OutValue:=POCAHashGetString(aContext,OptsHash,'hologram');
  if POCAGetValueType(OutValue)=pvtHASH then begin
   POCAScene3DApplyHologramFromHash(aContext,OutValue,Mat.Data^.Hologram);
  end;
 end;
 Mat.FillShaderData;
 Mat.SceneInstance.NewMaterialDataGeneration;
 Mat.IncRef;
 result:=POCANewScene3DMaterialGhost(aContext,Mat);
end;


// --- Primitive -------------------------------------------------------------------

const POCAScene3DPrimitiveGhost:TPOCAGhostType=
       (
        Destroy:nil;    // owned by mesh
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DPrimitive'
       );

function POCANewScene3DPrimitiveGhost(const aContext:PPOCAContext;const aPrimitive:TpvScene3D.TGroup.TMesh.TPrimitive):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DPrimitiveGhost,aPrimitive,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DPrimitiveGhostHash);
end;

// prim.setMaterial(mat) — set the material on this primitive
function POCAScene3DPrimitiveFunctionSetMaterial(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Primitive:TpvScene3D.TGroup.TMesh.TPrimitive;
    Material:TpvScene3D.TMaterial;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DPrimitiveGhost then begin
  exit;
 end;
 if (aCountArguments<1) or (POCAGhostGetType(aArguments^[0])<>@POCAScene3DMaterialGhost) then begin
  exit;
 end;
 Primitive:=TpvScene3D.TGroup.TMesh.TPrimitive(POCAGhostFastGetPointer(aThis));
 if not assigned(Primitive) then begin
  exit;
 end;
 Material:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Material) then begin
  exit;
 end;
 Primitive.Material:=Material;
 result:=aThis;
end;

// prim.addVertex(x,y,z [,nx,ny,nz] [,tx,ty,tz] [,u0,v0] [,u1,v1] [,r,g,b,a]) → vertex index
function POCAScene3DPrimitiveFunctionAddVertex(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Primitive:TpvScene3D.TGroup.TMesh.TPrimitive;
    Vertex:TpvScene3D.TVertex;
    Index:TpvSizeInt;
    Color:TpvVector4;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DPrimitiveGhost then begin
  exit;
 end;
 if aCountArguments>0 then begin
  if POCAGetValueType(aArguments^[0])=pvtHASH then begin
   Primitive:=TpvScene3D.TGroup.TMesh.TPrimitive(POCAGhostFastGetPointer(aThis));
   if assigned(Primitive) then begin
    Vertex:=TpvScene3D.TVertex.Create;
    Vertex.Position:=POCAGetVector3Value(aContext,POCAHashGetString(aContext,aArguments^[0],'position'));
    Vertex.NodeIndex:=0;
    Vertex.SetNormal(POCAGetVector3Value(aContext,POCAHashGetString(aContext,aArguments^[0],'normal')));
    Vertex.SetTangent(POCAGetVector3Value(aContext,POCAHashGetString(aContext,aArguments^[0],'tangent')));
    Vertex.TexCoord0:=POCAGetVector2Value(aContext,POCAHashGetString(aContext,aArguments^[0],'texcoord0'));
    Vertex.TexCoord1:=POCAGetVector2Value(aContext,POCAHashGetString(aContext,aArguments^[0],'texcoord1'));
    Color:=POCAGetVector4Value(aContext,POCAHashGetString(aContext,aArguments^[0],'color'));
    Vertex.Color0.x:=Color.x;
    Vertex.Color0.y:=Color.y;
    Vertex.Color0.z:=Color.z;
    Vertex.Color0.w:=Color.w;
   end;
  end else if aCountArguments>=3 then begin
   Primitive:=TpvScene3D.TGroup.TMesh.TPrimitive(POCAGhostFastGetPointer(aThis));
   if assigned(Primitive) then begin
    Vertex:=TpvScene3D.TVertex.Create;
    Vertex.Position.x:=POCAGetNumberValue(aContext,aArguments^[0]);
    Vertex.Position.y:=POCAGetNumberValue(aContext,aArguments^[1]);
    Vertex.Position.z:=POCAGetNumberValue(aContext,aArguments^[2]);
    Vertex.NodeIndex:=0;
    if aCountArguments>=6 then begin
     Vertex.SetNormal(TpvVector3.Create(POCAGetNumberValue(aContext,aArguments^[3]),
                                        POCAGetNumberValue(aContext,aArguments^[4]),
                                        POCAGetNumberValue(aContext,aArguments^[5])));
    end else begin
     Vertex.SetNormal(TpvVector3.Null);
    end;
    if aCountArguments>=9 then begin
     Vertex.SetTangent(TpvVector3.Create(POCAGetNumberValue(aContext,aArguments^[6]),
                                         POCAGetNumberValue(aContext,aArguments^[7]),
                                         POCAGetNumberValue(aContext,aArguments^[8])));
    end else begin
     Vertex.SetTangent(TpvVector3.Null);
    end;
    if aCountArguments>=11 then begin
     Vertex.TexCoord0.x:=POCAGetNumberValue(aContext,aArguments^[9]);
     Vertex.TexCoord0.y:=POCAGetNumberValue(aContext,aArguments^[10]);
    end else begin
     Vertex.TexCoord0.x:=0.0;
     Vertex.TexCoord0.y:=0.0;
    end;
    if aCountArguments>=13 then begin
     Vertex.TexCoord1.x:=POCAGetNumberValue(aContext,aArguments^[11]);
     Vertex.TexCoord1.y:=POCAGetNumberValue(aContext,aArguments^[12]);
    end else begin
     Vertex.TexCoord1.x:=0.0;
     Vertex.TexCoord1.y:=0.0;
    end;
    if aCountArguments>=17 then begin
     Vertex.Color0.r:=POCAGetNumberValue(aContext,aArguments^[13]);
     Vertex.Color0.g:=POCAGetNumberValue(aContext,aArguments^[14]);
     Vertex.Color0.b:=POCAGetNumberValue(aContext,aArguments^[15]);
     Vertex.Color0.a:=POCAGetNumberValue(aContext,aArguments^[16]);
    end else begin
     Vertex.Color0.r:=1.0;
     Vertex.Color0.g:=1.0;
     Vertex.Color0.b:=1.0;
     Vertex.Color0.a:=1.0;
    end;
    Index:=Primitive.AddVertex(Vertex);
    result:=POCANewNumber(aContext,Index);
   end;
  end;
 end;
end;

// prim.addIndex(i) — add index to index buffer
function POCAScene3DPrimitiveFunctionAddIndex(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Prim:TpvScene3D.TGroup.TMesh.TPrimitive;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DPrimitiveGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Prim:=TpvScene3D.TGroup.TMesh.TPrimitive(POCAGhostFastGetPointer(aThis));
 if not assigned(Prim) then begin
  exit;
 end;
 Prim.AddIndex(TpvUInt32(round(POCAGetNumberValue(aContext,aArguments^[0]))));
 result:=aThis;
end;

// prim.finish()
function POCAScene3DPrimitiveFunctionFinish(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Prim:TpvScene3D.TGroup.TMesh.TPrimitive;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DPrimitiveGhost then begin
  exit;
 end;
 Prim:=TpvScene3D.TGroup.TMesh.TPrimitive(POCAGhostFastGetPointer(aThis));
 if not assigned(Prim) then begin
  exit;
 end;
 Prim.Finish;
 result:=aThis;
end;

// prim.destroy() — frees the primitive; caller is responsible for not using it afterwards
function POCAScene3DPrimitiveFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Prim:TpvScene3D.TGroup.TMesh.TPrimitive;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DPrimitiveGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Prim:=TpvScene3D.TGroup.TMesh.TPrimitive(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Prim);
 end;
end;


// --- Mesh ------------------------------------------------------------------------

const POCAScene3DMeshGhost:TPOCAGhostType=
       (
        Destroy:nil;    // owned by group
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DMesh'
       );

function POCANewScene3DMeshGhost(const aContext:PPOCAContext;const aMesh:TpvScene3D.TGroup.TMesh):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DMeshGhost,aMesh,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DMeshGhostHash);
end;

// mesh.createPrimitive('triangles'|'lines'|'points') → Scene3DPrimitive
function POCAScene3DMeshFunctionCreatePrimitive(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mesh:TpvScene3D.TGroup.TMesh;
    Prim:TpvScene3D.TGroup.TMesh.TPrimitive;
    TopStr:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMeshGhost then begin
  exit;
 end;
 Mesh:=TpvScene3D.TGroup.TMesh(POCAGhostFastGetPointer(aThis));
 if not assigned(Mesh) then begin
  exit;
 end;
 Prim:=Mesh.CreatePrimitive;
 if not assigned(Prim) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  TopStr:=POCAGetStringValue(aContext,aArguments^[0]);
  if TopStr='lines' then begin
   Prim.PrimitiveTopology:=TpvScene3D.TPrimitiveTopology.Lines;
  end else if TopStr='points' then begin
   Prim.PrimitiveTopology:=TpvScene3D.TPrimitiveTopology.Points;
  end else begin
   Prim.PrimitiveTopology:=TpvScene3D.TPrimitiveTopology.Triangles;
  end;
 end else begin
  Prim.PrimitiveTopology:=TpvScene3D.TPrimitiveTopology.Triangles;
 end;
 result:=POCANewScene3DPrimitiveGhost(aContext,Prim);
end;

// mesh.calculateTangentSpace()
function POCAScene3DMeshFunctionCalculateTangentSpace(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mesh:TpvScene3D.TGroup.TMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMeshGhost then begin
  exit;
 end;
 Mesh:=TpvScene3D.TGroup.TMesh(POCAGhostFastGetPointer(aThis));
 if not assigned(Mesh) then begin
  exit;
 end;
 Mesh.CalculateTangentSpace;
 result:=aThis;
end;

// mesh.finish()
function POCAScene3DMeshFunctionFinish(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Mesh:TpvScene3D.TGroup.TMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMeshGhost then begin
  exit;
 end;
 Mesh:=TpvScene3D.TGroup.TMesh(POCAGhostFastGetPointer(aThis));
 if not assigned(Mesh) then begin
  exit;
 end;
 Mesh.Finish;
 result:=aThis;
end;

// mesh.destroy() — frees the mesh; caller is responsible for not using it afterwards
function POCAScene3DMeshFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Mesh:TpvScene3D.TGroup.TMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DMeshGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Mesh:=TpvScene3D.TGroup.TMesh(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Mesh);
 end;
end;


// --- Node ------------------------------------------------------------------------

const POCAScene3DNodeGhost:TPOCAGhostType=
       (
        Destroy:nil;    // owned by group
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DNode'
       );

function POCANewScene3DNodeGhost(const aContext:PPOCAContext;const aNode:TpvScene3D.TGroup.TNode):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DNodeGhost,aNode,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DNodeGhostHash);
end;

// node.setMesh(mesh)
function POCAScene3DNodeFunctionSetMesh(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
    Mesh:TpvScene3D.TGroup.TMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if (aCountArguments<1) or (POCAGhostGetType(aArguments^[0])<>@POCAScene3DMeshGhost) then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 Mesh:=TpvScene3D.TGroup.TMesh(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Mesh) then begin
  exit;
 end;
 Node.Mesh:=Mesh;
 result:=aThis;
end;

// node.addChild(childNode)
function POCAScene3DNodeFunctionAddChild(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
    Child:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if (aCountArguments<1) or (POCAGhostGetType(aArguments^[0])<>@POCAScene3DNodeGhost) then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 Child:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Child) then begin
  exit;
 end;
 Node.Children.Add(Child);
 result:=aThis;
end;

// node.setTranslation(x, y, z)
// or node.setTranslation(Vector3 | array[3] | {x,y,z})
function POCAScene3DNodeFunctionSetTranslation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 if POCAIsVector3Value(aContext,aArguments^[0]) then begin
  Node.Translation:=POCAGetVector3Value(aContext,aArguments^[0]);
 end else begin
  if aCountArguments<3 then begin
   exit;
  end;
  Node.Translation:=TpvVector3.Create(POCAGetNumberValue(aContext,aArguments^[0]),
                                       POCAGetNumberValue(aContext,aArguments^[1]),
                                       POCAGetNumberValue(aContext,aArguments^[2]));
 end;
 result:=aThis;
end;

// node.setRotation(qx, qy, qz, qw)
// or node.setRotation(Quaternion | array[4] | {x,y,z,w})
function POCAScene3DNodeFunctionSetRotation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 if POCAIsQuaternionValue(aContext,aArguments^[0]) then begin
  Node.Rotation:=POCAGetQuaternionValue(aContext,aArguments^[0]);
 end else begin
  if aCountArguments<4 then begin
   exit;
  end;
  Node.Rotation:=TpvQuaternion.Create(POCAGetNumberValue(aContext,aArguments^[0]),
                                       POCAGetNumberValue(aContext,aArguments^[1]),
                                       POCAGetNumberValue(aContext,aArguments^[2]),
                                       POCAGetNumberValue(aContext,aArguments^[3]));
 end;
 result:=aThis;
end;

// node.setScale(sx, sy, sz)
// or node.setScale(Vector3 | array[3] | {x,y,z})
function POCAScene3DNodeFunctionSetScale(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 if POCAIsVector3Value(aContext,aArguments^[0]) then begin
  Node.Scale:=POCAGetVector3Value(aContext,aArguments^[0]);
 end else begin
  if aCountArguments<3 then begin
   exit;
  end;
  Node.Scale:=TpvVector3.Create(POCAGetNumberValue(aContext,aArguments^[0]),
                                 POCAGetNumberValue(aContext,aArguments^[1]),
                                 POCAGetNumberValue(aContext,aArguments^[2]));
 end;
 result:=aThis;
end;

// node.setMatrix(m00,m01,...,m15) — set full 4x4 transform (row-major, 16 args)
// or node.setMatrix(Matrix4x4 | array[16] | hash)
function POCAScene3DNodeFunctionSetMatrix(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
    Mat:TpvMatrix4x4;
    I:TpvInt32;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 if POCAIsMatrix4x4Value(aContext,aArguments^[0]) then begin
  Node.Matrix:=POCAGetMatrix4x4Value(aContext,aArguments^[0]);
 end else begin
  if aCountArguments<16 then begin
   exit;
  end;
  for I:=0 to 15 do begin
   Mat.RawComponents[I shr 2,I and 3]:=POCAGetNumberValue(aContext,aArguments^[I]);
  end;
  Node.Matrix:=Mat;
 end;
 result:=aThis;
end;

// node.setVisible(bool)
function POCAScene3DNodeFunctionSetVisible(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 Node.Visible:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 result:=aThis;
end;

// node.setCastShadows(bool)
function POCAScene3DNodeFunctionSetCastShadows(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 Node.CastingShadows:=POCAGetNumberValue(aContext,aArguments^[0])<>0;
 result:=aThis;
end;

// node.finish()
function POCAScene3DNodeFunctionFinish(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aThis));
 if not assigned(Node) then begin
  exit;
 end;
 Node.Finish;
 result:=aThis;
end;

// node.destroy() — frees the node; caller is responsible for not using it afterwards
function POCAScene3DNodeFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DNodeGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Node:=TpvScene3D.TGroup.TNode(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Node);
 end;
end;


// --- GroupScene ------------------------------------------------------------------

const POCAScene3DGroupSceneGhost:TPOCAGhostType=
       (
        Destroy:nil;    // owned by group
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DGroupScene'
       );

function POCANewScene3DGroupSceneGhost(const aContext:PPOCAContext;const aScene:TpvScene3D.TGroup.TScene):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DGroupSceneGhost,aScene,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DGroupSceneGhostHash);
end;

// scene.addNode(node) — add a root node to this GroupScene
function POCAScene3DGroupSceneFunctionAddNode(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene:TpvScene3D.TGroup.TScene;
    Node:TpvScene3D.TGroup.TNode;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupSceneGhost then begin
  exit;
 end;
 if (aCountArguments<1) or (POCAGhostGetType(aArguments^[0])<>@POCAScene3DNodeGhost) then begin
  exit;
 end;
 Scene:=TpvScene3D.TGroup.TScene(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene) then begin
  exit;
 end;
 Node:=TpvScene3D.TGroup.TNode(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Node) then begin
  exit;
 end;
 Scene.Nodes.Add(Node);
 result:=aThis;
end;

// scene.destroy() — frees the scene; caller is responsible for not using it afterwards
function POCAScene3DGroupSceneFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Scene:TpvScene3D.TGroup.TScene;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupSceneGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Scene:=TpvScene3D.TGroup.TScene(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Scene);
 end;
end;


// --- BakedMesh -------------------------------------------------------------------

procedure POCAScene3DBakedMeshGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Scene3D BakedMesh lifetime is
 // managed externally. Use the explicit bakedMesh.destroy() API intentionally.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DBakedMeshGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DBakedMeshGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DBakedMesh'
       );

function POCANewScene3DBakedMeshGhost(const aContext:PPOCAContext;const aBakedMesh:TpvScene3D.TBakedMesh):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DBakedMeshGhost,aBakedMesh,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DBakedMeshGhostHash);
end;

// bm.raycast(origin, direction)
// origin, direction — POCA arrays [x,y,z]
// Returns { distance, position:{x,y,z}, u, v } or null
function POCAScene3DBakedMeshFunctionRaycast(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var BakedMesh:TpvScene3D.TBakedMesh;
    Origin:TpvVector3;
    Direction:TpvVector3;
    TriIdx:TpvSizeInt;
    HitTime,HitU,HitV:TpvScalar;
    BestTime,BestU,BestV:TpvScalar;
    HitPos:TpvVector3;
    PosHash:TPOCAValue;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DBakedMeshGhost then begin
  exit;
 end;
 BakedMesh:=TpvScene3D.TBakedMesh(POCAGhostFastGetPointer(aThis));
 if not assigned(BakedMesh) then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Origin.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],0));
 Origin.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],1));
 Origin.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],2));
 Direction.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],0));
 Direction.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],1));
 Direction.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],2));
 BestTime:=-1.0;
 BestU:=0.0;
 BestV:=0.0;
 for TriIdx:=0 to BakedMesh.Triangles.Count-1 do begin
  HitTime:=0.0;
  HitU:=0.0;
  HitV:=0.0;
  if BakedMesh.Triangles[TriIdx].RayIntersection(Origin,Direction,HitTime,HitU,HitV) then begin
   if (HitTime>0.0) and ((BestTime<0.0) or (HitTime<BestTime)) then begin
    BestTime:=HitTime;
    BestU:=HitU;
    BestV:=HitV;
   end;
  end;
 end;
 if BestTime<0.0 then begin
  exit;
 end;
 HitPos.x:=Origin.x+Direction.x*BestTime;
 HitPos.y:=Origin.y+Direction.y*BestTime;
 HitPos.z:=Origin.z+Direction.z*BestTime;
 PosHash:=POCANewHash(aContext);
 POCAHashSetString(aContext,PosHash,'x',POCANewNumber(aContext,HitPos.x));
 POCAHashSetString(aContext,PosHash,'y',POCANewNumber(aContext,HitPos.y));
 POCAHashSetString(aContext,PosHash,'z',POCANewNumber(aContext,HitPos.z));
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'distance',POCANewNumber(aContext,BestTime));
 POCAHashSetString(aContext,result,'position',PosHash);
 POCAHashSetString(aContext,result,'u',POCANewNumber(aContext,BestU));
 POCAHashSetString(aContext,result,'v',POCANewNumber(aContext,BestV));
end;

// bm.destroy() — frees the TBakedMesh; nulls ghost pointer
function POCAScene3DBakedMeshFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    BakedMesh:TpvScene3D.TBakedMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DBakedMeshGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  BakedMesh:=TpvScene3D.TBakedMesh(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(BakedMesh);
 end;
end;


// --- RenderInstance --------------------------------------------------------------

procedure POCAScene3DRenderInstanceGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Scene3D RenderInstance lifetime is
 // managed externally. Use the explicit ri.remove() API to remove it intentionally.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DRenderInstanceGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DRenderInstanceGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DRenderInstance'
       );

function POCANewScene3DRenderInstanceGhost(const aContext:PPOCAContext;const aRenderInstance:TpvScene3D.TGroup.TInstance.TRenderInstance):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DRenderInstanceGhost,aRenderInstance,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DRenderInstanceGhostHash);
end;

// RenderInstance methods

// ri.setActive(bool)
function POCAScene3DRenderInstanceFunctionSetActive(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var RI:TpvScene3D.TGroup.TInstance.TRenderInstance;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DRenderInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 RI:=TpvScene3D.TGroup.TInstance.TRenderInstance(POCAGhostFastGetPointer(aThis));
 if not assigned(RI) then begin
  exit;
 end;
 RI.Active:=POCAGetNumberValue(aContext,aArguments^[0])<>0.0;
 result:=aThis;
end;

// ri.setModelMatrix(m00,..,m15) — 16 doubles, row-major
function POCAScene3DRenderInstanceFunctionSetModelMatrix(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var RI:TpvScene3D.TGroup.TInstance.TRenderInstance;
    Mat:TpvMatrix4x4D;
    I:TpvInt32;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DRenderInstanceGhost then begin
  exit;
 end;
 if aCountArguments<16 then begin
  exit;
 end;
 RI:=TpvScene3D.TGroup.TInstance.TRenderInstance(POCAGhostFastGetPointer(aThis));
 if not assigned(RI) then begin
  exit;
 end;
 for I:=0 to 15 do begin
  Mat.RawComponents[I shr 2,I and 3]:=POCAGetNumberValue(aContext,aArguments^[I]);
 end;
 RI.ModelMatrix:=Mat;
 result:=aThis;
end;

// ri.remove() — deregisters render instance; nulls ghost pointer (do not Free, owned by instance)
function POCAScene3DRenderInstanceFunctionRemove(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    RI:TpvScene3D.TGroup.TInstance.TRenderInstance;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DRenderInstanceGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  RI:=TpvScene3D.TGroup.TInstance.TRenderInstance(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  RI.Remove;
 end;
end;


// --- GroupLight ------------------------------------------------------------------

const POCAScene3DGroupLightGhost:TPOCAGhostType=
       (
        Destroy:nil;    // owned by group
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DGroupLight'
       );


// --- Instance --------------------------------------------------------------------

procedure POCAScene3DInstanceGhostDestroy(const aGhost:PPOCAGhost);
var Data:TScene3DInstanceGhostData;
begin
 // GC ghost destroy: free only the POCA-internal wrapper, NOT the Scene3D Instance.
 // Use the explicit instance.destroy() API to free the Scene3D object intentionally.
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  Data:=TScene3DInstanceGhostData(aGhost^.Ptr);
  aGhost^.Ptr:=nil;
  FreeAndNil(Data);
 end;
end;

const POCAScene3DInstanceGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DInstanceGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DInstance'
       );

function POCANewScene3DInstanceGhost(const aContext:PPOCAContext;const aInstance:TpvScene3D.TGroup.TInstance):TPOCAValue;
var Data:TScene3DInstanceGhostData;
begin
 Data:=TScene3DInstanceGhostData.Create(aInstance);
 result:=POCANewGhost(aContext,@POCAScene3DInstanceGhost,Data,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DInstanceGhostHash);
end;

// instance.setScene(index) — selects active scene index on the instance
function POCAScene3DInstanceFunctionSetScene(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Data.Instance.Scene:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 result:=aThis;
end;

// instance.setActive(bool)
function POCAScene3DInstanceFunctionSetActive(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Data.Instance.Active:=POCAGetNumberValue(aContext,aArguments^[0])<>0.0;
 result:=aThis;
end;

// instance.isActive() → bool
function POCAScene3DInstanceFunctionIsActive(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if Data.Instance.Active then begin
  result.Num:=1.0;
 end else begin
  result.Num:=0.0;
 end;
end;

// instance.setModelMatrix(m00,..,m15) — 16 doubles, row-major
function POCAScene3DInstanceFunctionSetModelMatrix(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Mat:TpvMatrix4x4D;
    I:TpvInt32;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<16 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 for I:=0 to 15 do begin
  Mat.RawComponents[I shr 2,I and 3]:=POCAGetNumberValue(aContext,aArguments^[I]);
 end;
 Data.Instance.ModelMatrix:=Mat;
 result:=aThis;
end;

// instance.getModelMatrix() → array of 16 doubles (row-major)
function POCAScene3DInstanceFunctionGetModelMatrix(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Mat:TpvMatrix4x4D;
    I:TpvInt32;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Mat:=Data.Instance.ModelMatrix;
 result:=POCANewArray(aContext);
 for I:=0 to 15 do begin
  POCAArrayPush(result,POCANewNumber(aContext,Mat.RawComponents[I shr 2,I and 3]));
 end;
end;

// instance.setAnimation(animIndex, time [,factor [,additive]])
function POCAScene3DInstanceFunctionSetAnimation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
    Anim:TpvScene3D.TGroup.TInstance.TAnimation;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Anim:=Data.Instance.Animations[Idx];
 Anim.Time:=POCAGetNumberValue(aContext,aArguments^[1]);
 if aCountArguments>=3 then begin
  Anim.Factor:=POCAGetNumberValue(aContext,aArguments^[2]);
 end else begin
  Anim.Factor:=1.0;
 end;
 if aCountArguments>=4 then begin
  Anim.Additive:=POCAGetNumberValue(aContext,aArguments^[3])<>0.0;
 end else begin
  Anim.Additive:=false;
 end;
 result:=aThis;
end;

// instance.setAnimationState(animIndex, {time, factor, additive}) — hash-arg convenience
function POCAScene3DInstanceFunctionSetAnimationState(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
    Anim:TpvScene3D.TGroup.TInstance.TAnimation;
    H:TPOCAValue;
    V:TPOCAValue;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 H:=aArguments^[1];
 Anim:=Data.Instance.Animations[Idx];
 V:=POCAHashGetString(aContext,H,'time');
 if not POCAIsValueNull(V) then begin
  Anim.Time:=POCAGetNumberValue(aContext,V);
 end;
 V:=POCAHashGetString(aContext,H,'factor');
 if not POCAIsValueNull(V) then begin
  Anim.Factor:=POCAGetNumberValue(aContext,V);
 end;
 V:=POCAHashGetString(aContext,H,'additive');
 if not POCAIsValueNull(V) then begin
  Anim.Additive:=POCAGetNumberValue(aContext,V)<>0.0;
 end;
 result:=aThis;
end;

// instance.getAnimation(animIndex) → {factor,time,additive,complete}
function POCAScene3DInstanceFunctionGetAnimation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
    Anim:TpvScene3D.TGroup.TInstance.TAnimation;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Anim:=Data.Instance.Animations[Idx];
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'factor',POCANewNumber(aContext,Anim.Factor));
 POCAHashSetString(aContext,result,'time',POCANewNumber(aContext,Anim.Time));
 if Anim.Additive then begin
  POCAHashSetString(aContext,result,'additive',POCANumber(1.0));
 end else begin
  POCAHashSetString(aContext,result,'additive',POCANumber(0.0));
 end;
 if Anim.Complete then begin
  POCAHashSetString(aContext,result,'complete',POCANumber(1.0));
 end else begin
  POCAHashSetString(aContext,result,'complete',POCANumber(0.0));
 end;
end;

// instance.setAnimationFactor(animIndex, factor)
function POCAScene3DInstanceFunctionSetAnimationFactor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Data.Instance.Animations[Idx].Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
 result:=aThis;
end;

// instance.setAnimationTime(animIndex, time)
function POCAScene3DInstanceFunctionSetAnimationTime(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Data.Instance.Animations[Idx].Time:=POCAGetNumberValue(aContext,aArguments^[1]);
 result:=aThis;
end;

// instance.setAnimationAdditive(animIndex, bool)
function POCAScene3DInstanceFunctionSetAnimationAdditive(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Data.Instance.Animations[Idx].Additive:=POCAGetNumberValue(aContext,aArguments^[1])<>0.0;
 result:=aThis;
end;

// instance.playAnimation(name [,loop [,speed]]) — high-level: starts named animation
function POCAScene3DInstanceFunctionPlayAnimation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
    Loop:Boolean;
    Speed:TpvDouble;
begin
 result.Num:=0.0;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=Data.Instance.Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0]));
 if Idx<0 then begin
  exit;
 end;
 Loop:=false;
 if aCountArguments>=2 then begin
  Loop:=POCAGetNumberValue(aContext,aArguments^[1])<>0.0;
 end;
 Speed:=1.0;
 if aCountArguments>=3 then begin
  Speed:=POCAGetNumberValue(aContext,aArguments^[2]);
 end;
 Data.EnsureAnimCount(Idx+1);
 Data.AnimStates[Idx].Loop:=Loop;
 Data.AnimStates[Idx].Speed:=Speed;
 Data.Instance.Animations[Idx].Time:=0.0;
 Data.Instance.Animations[Idx].Factor:=Speed;
 result.Num:=1.0;
end;

// instance.stopAnimation(name)
function POCAScene3DInstanceFunctionStopAnimation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=Data.Instance.Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Data.Instance.Animations[Idx].Factor:=0.0;
 if Idx<length(Data.AnimStates) then begin
  Data.AnimStates[Idx].Speed:=0.0;
 end;
 result:=aThis;
end;

// instance.stopAllAnimations()
function POCAScene3DInstanceFunctionStopAllAnimations(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 for Idx:=0 to Data.Instance.Group.Animations.Count-1 do begin
  Data.Instance.Animations[Idx].Factor:=0.0;
 end;
 for Idx:=0 to length(Data.AnimStates)-1 do begin
  Data.AnimStates[Idx].Speed:=0.0;
 end;
 result:=aThis;
end;

// instance.isAnimationPlaying(name) → bool
function POCAScene3DInstanceFunctionIsAnimationPlaying(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result.Num:=0.0;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=Data.Instance.Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 if Data.Instance.Animations[Idx].Factor<>0.0 then begin
  result.Num:=1.0;
 end;
end;

// instance.getAnimationTime(name) → float
function POCAScene3DInstanceFunctionGetAnimationTime(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=Data.Instance.Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 result:=POCANewNumber(aContext,Data.Instance.Animations[Idx].Time);
end;

// instance.setAnimationTimeByName(name, t) — named-animation version of setAnimationTime
function POCAScene3DInstanceFunctionSetAnimationTimeByName(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 Idx:=Data.Instance.Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0]));
 if (Idx<0) or (Idx>=Data.Instance.Group.Animations.Count) then begin
  exit;
 end;
 Data.Instance.Animations[Idx].Time:=POCAGetNumberValue(aContext,aArguments^[1]);
 result:=aThis;
end;

// instance.updateAnimations() — advance all tracked animations by delta time, then call Update()
function POCAScene3DInstanceFunctionUpdateAnimations(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    CurrentTime:TpvInt64;
    Delta:TpvDouble;
    Idx:TpvSizeInt;
    Anim:TpvScene3D.TGroup.TInstance.TAnimation;
    AnimDuration:TpvDouble;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 CurrentTime:=pvApplication.HighResolutionTimer.GetTime;
 Delta:=pvApplication.HighResolutionTimer.ToFloatSeconds(CurrentTime-Data.LastHiResTime);
 Data.LastHiResTime:=CurrentTime;
 for Idx:=0 to length(Data.AnimStates)-1 do begin
  if Data.AnimStates[Idx].Speed>0.0 then begin
   Anim:=Data.Instance.Animations[Idx];
   Anim.Time:=Anim.Time+Delta*Data.AnimStates[Idx].Speed;
   if Anim.Complete then begin
    if Data.AnimStates[Idx].Loop then begin
     AnimDuration:=Data.Instance.Group.Animations[Idx].AnimationDuration;
     if AnimDuration>0.0 then begin
      Anim.Time:=Anim.Time-trunc(Anim.Time/AnimDuration)*AnimDuration;
     end else begin
      Anim.Time:=0.0;
     end;
    end else begin
     Data.AnimStates[Idx].Speed:=0.0;
     Anim.Factor:=0.0;
    end;
   end;
  end;
 end;
 Data.Instance.Update(pvApplication.UpdateInFlightFrameIndex);
 result:=aThis;
end;

// instance.getBakedMesh() → Scene3DBakedMesh ghost; caller must call bm.destroy() when done
function POCAScene3DInstanceFunctionGetBakedMesh(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    BakedMesh:TpvScene3D.TBakedMesh;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 BakedMesh:=Data.Instance.GetBakedMesh(false,false,-1);
 if not assigned(BakedMesh) then begin
  exit;
 end;
 result:=POCANewScene3DBakedMeshGhost(aContext,BakedMesh);
end;

// instance.createRenderInstance() → Scene3DRenderInstance
function POCAScene3DInstanceFunctionCreateRenderInstance(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:TScene3DInstanceGhostData;
    RI:TpvScene3D.TGroup.TInstance.TRenderInstance;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Data:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 RI:=Data.Instance.CreateRenderInstance;
 if not assigned(RI) then begin
  exit;
 end;
 result:=POCANewScene3DRenderInstanceGhost(aContext,RI);
end;

// instance.destroy() — frees instance; nulls ghost pointer
function POCAScene3DInstanceFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Data:TScene3DInstanceGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DInstanceGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Data:=TScene3DInstanceGhostData(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Data.Instance);
  FreeAndNil(Data);
 end;
end;


// --- Group -----------------------------------------------------------------------

const POCAScene3DGroupGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DGroup'
       );

// helper: wrap a TpvScene3D.TGroup in a ghost (raw ptr, no ref-count needed beyond group lifetime)
function POCANewScene3DGroupGhost(const aContext:PPOCAContext;const aGroup:TpvScene3D.TGroup):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DGroupGhost,aGroup,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DGroupGhostHash);
end;

// engine.scene3d.createGroup([name])
function POCAScene3DSceneFunctionCreateGroup(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Group:TpvScene3D.TGroup;
    Name:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  Name:='';
 end;
 Group:=Scene3D.CreateGroup(Name);
 if not assigned(Group) then begin
  exit;
 end;
 result:=POCANewScene3DGroupGhost(aContext,Group);
end;

// g.createMesh([name]) → Scene3DMesh
function POCAScene3DGroupFunctionCreateMesh(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
    Mesh:TpvScene3D.TGroup.TMesh;
    Name:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  Name:='';
 end;
 Mesh:=Group.CreateMesh(Name);
 if not assigned(Mesh) then begin
  exit;
 end;
 result:=POCANewScene3DMeshGhost(aContext,Mesh);
end;

// g.createNode([name]) → Scene3DNode
function POCAScene3DGroupFunctionCreateNode(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
    Node:TpvScene3D.TGroup.TNode;
    Name:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  Name:='';
 end;
 Node:=Group.CreateNode(Name);
 if not assigned(Node) then begin
  exit;
 end;
 result:=POCANewScene3DNodeGhost(aContext,Node);
end;

// g.createScene([name]) → Scene3DGroupScene
function POCAScene3DGroupFunctionCreateScene(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
    Scene:TpvScene3D.TGroup.TScene;
    Name:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  Name:='';
 end;
 Scene:=Group.CreateScene(Name);
 if not assigned(Scene) then begin
  exit;
 end;
 result:=POCANewScene3DGroupSceneGhost(aContext,Scene);
end;

// g.addMaterial(mat) → material index within group
function POCAScene3DGroupFunctionAddMaterial(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
    Mat:TpvScene3D.TMaterial;
    MatIndex:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 if (aCountArguments<1) or (POCAGhostGetType(aArguments^[0])<>@POCAScene3DMaterialGhost) then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 Mat:=TpvScene3D.TMaterial(POCAGhostFastGetPointer(aArguments^[0]));
 if not assigned(Mat) then begin
  exit;
 end;
 MatIndex:=Group.AddMaterial(Mat);
 result:=POCANewNumber(aContext,MatIndex);
end;

// g.finish() — finalise GPU upload; must be called before createInstance()
function POCAScene3DGroupFunctionFinish(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 Group.Finish;
 result:=aThis;
end;

// g.createInstance() → Scene3DInstance (must call g.finish() first)
function POCAScene3DGroupFunctionCreateInstance(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
    Instance:TpvScene3D.TGroup.TInstance;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 Instance:=Group.CreateInstance;
 if not assigned(Instance) then begin
  exit;
 end;
 result:=POCANewScene3DInstanceGhost(aContext,Instance);
end;

// g.getAnimationID(name) → int (-1 if not found)
function POCAScene3DGroupFunctionGetAnimationID(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Group:TpvScene3D.TGroup;
begin
 result:=POCANewNumber(aContext,-1);
 if (POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost) or (aCountArguments<1) then begin
  exit;
 end;
 Group:=TpvScene3D.TGroup(POCAGhostFastGetPointer(aThis));
 if not assigned(Group) then begin
  exit;
 end;
 result:=POCANewNumber(aContext,Group.GetAnimationID(POCAGetStringValue(aContext,aArguments^[0])));
end;

// g.destroy() — nulls ghost pointer (group is owned by scene, not ref-counted from POCA)
function POCAScene3DGroupFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Group:TpvScene3D.TGroup;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DGroupGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Group:=TpvScene3D.TGroup(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Group);
 end;
end;


// --- Light -----------------------------------------------------------------------

procedure POCAScene3DLightGhostDestroy(const aGhost:PPOCAGhost);
begin
 // GC ghost destroy: just null the pointer. Scene3D Light lifetime is managed
 // externally. Use the explicit light.destroy() API to free it intentionally.
 if assigned(aGhost) then begin
  aGhost^.Ptr:=nil;
 end;
end;

const POCAScene3DLightGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DLightGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DLight'
       );

function POCANewScene3DLightGhost(const aContext:PPOCAContext;const aLight:TpvScene3D.TLight):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAScene3DLightGhost,aLight,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DLightGhostHash);
end;

// engine.scene3d.createPointLight(x,y,z, r,g,b, intensity, range) → Scene3DLight
function POCAScene3DSceneFunctionCreatePointLight(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Light:TpvScene3D.TLight;
    Pos:TpvVector3D;
    Col:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 if aCountArguments<8 then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Pos.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Pos.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Pos.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Col.x:=POCAGetNumberValue(aContext,aArguments^[3]);
 Col.y:=POCAGetNumberValue(aContext,aArguments^[4]);
 Col.z:=POCAGetNumberValue(aContext,aArguments^[5]);
 Light:=TpvScene3D.TLight.Create(Scene3D,true);
 Light.Type_:=TpvScene3D.TLightData.TLightType.Point;
 Light.Matrix:=TpvMatrix4x4D.CreateTranslation(Pos);
 Light.Color:=Col;
 Light.Intensity:=POCAGetNumberValue(aContext,aArguments^[6]);
 Light.Range:=POCAGetNumberValue(aContext,aArguments^[7]);
 Light.Visible:=true;
 result:=POCANewScene3DLightGhost(aContext,Light);
end;

// engine.scene3d.createSpotLight(x,y,z, dx,dy,dz, r,g,b, intensity, range, innerDeg, outerDeg) → Scene3DLight
function POCAScene3DSceneFunctionCreateSpotLight(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Light:TpvScene3D.TLight;
    Pos,Dir,Up,Center:TpvVector3D;
    Col:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 if aCountArguments<13 then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Pos.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Pos.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Pos.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Dir.x:=POCAGetNumberValue(aContext,aArguments^[3]);
 Dir.y:=POCAGetNumberValue(aContext,aArguments^[4]);
 Dir.z:=POCAGetNumberValue(aContext,aArguments^[5]);
 Dir:=Dir.Normalize;
 Up.x:=0.0; Up.y:=1.0; Up.z:=0.0;
 if abs(Dir.Dot(Up))>0.99 then begin
  Up.x:=1.0; Up.y:=0.0; Up.z:=0.0;
 end;
 Center.x:=Pos.x+Dir.x; Center.y:=Pos.y+Dir.y; Center.z:=Pos.z+Dir.z;
 Col.x:=POCAGetNumberValue(aContext,aArguments^[6]);
 Col.y:=POCAGetNumberValue(aContext,aArguments^[7]);
 Col.z:=POCAGetNumberValue(aContext,aArguments^[8]);
 Light:=TpvScene3D.TLight.Create(Scene3D,true);
 Light.Type_:=TpvScene3D.TLightData.TLightType.Spot;
 Light.Matrix:=TpvMatrix4x4D.CreateInverseLookAt(Pos,Center,Up);
 Light.Color:=Col;
 Light.Intensity:=POCAGetNumberValue(aContext,aArguments^[9]);
 Light.Range:=POCAGetNumberValue(aContext,aArguments^[10]);
 Light.InnerConeAngle:=POCAGetNumberValue(aContext,aArguments^[11])*(Pi/180.0);
 Light.OuterConeAngle:=POCAGetNumberValue(aContext,aArguments^[12])*(Pi/180.0);
 Light.Visible:=true;
 result:=POCANewScene3DLightGhost(aContext,Light);
end;

// engine.scene3d.createDirectionalLight(dx,dy,dz, r,g,b, intensity) → Scene3DLight
function POCAScene3DSceneFunctionCreateDirectionalLight(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Light:TpvScene3D.TLight;
    Pos,Dir,Up,Center:TpvVector3D;
    Col:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 if aCountArguments<7 then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 Dir.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Dir.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Dir.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Dir:=Dir.Normalize;
 Up.x:=0.0; Up.y:=1.0; Up.z:=0.0;
 if abs(Dir.Dot(Up))>0.99 then begin
  Up.x:=1.0; Up.y:=0.0; Up.z:=0.0;
 end;
 Pos.x:=0.0; Pos.y:=0.0; Pos.z:=0.0;
 Center.x:=Dir.x; Center.y:=Dir.y; Center.z:=Dir.z;
 Col.x:=POCAGetNumberValue(aContext,aArguments^[3]);
 Col.y:=POCAGetNumberValue(aContext,aArguments^[4]);
 Col.z:=POCAGetNumberValue(aContext,aArguments^[5]);
 Light:=TpvScene3D.TLight.Create(Scene3D,true);
 Light.Type_:=TpvScene3D.TLightData.TLightType.Directional;
 Light.Matrix:=TpvMatrix4x4D.CreateInverseLookAt(Pos,Center,Up);
 Light.Color:=Col;
 Light.Intensity:=POCAGetNumberValue(aContext,aArguments^[6]);
 Light.Visible:=true;
 result:=POCANewScene3DLightGhost(aContext,Light);
end;

// light.setType(t) — 1=Directional, 2=Point, 3=Spot
function POCAScene3DLightFunctionSetType(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.Type_:=TpvScene3D.TLightData.TLightType(trunc(POCAGetNumberValue(aContext,aArguments^[0])));
 result:=aThis;
end;

// light.setPosition(x,y,z) — sets the translation part of the light matrix
function POCAScene3DLightFunctionSetPosition(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
    Mat:TpvMatrix4x4D;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<3 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Mat:=Light.Matrix;
 Mat.RawComponents[3,0]:=POCAGetNumberValue(aContext,aArguments^[0]);
 Mat.RawComponents[3,1]:=POCAGetNumberValue(aContext,aArguments^[1]);
 Mat.RawComponents[3,2]:=POCAGetNumberValue(aContext,aArguments^[2]);
 Light.Matrix:=Mat;
 result:=aThis;
end;

// light.setDirection(dx,dy,dz) — recomputes orientation keeping current position
function POCAScene3DLightFunctionSetDirection(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
    Mat:TpvMatrix4x4D;
    Pos,Dir,Up,Center:TpvVector3D;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<3 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Mat:=Light.Matrix;
 Pos.x:=Mat.RawComponents[3,0];
 Pos.y:=Mat.RawComponents[3,1];
 Pos.z:=Mat.RawComponents[3,2];
 Dir.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Dir.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Dir.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Dir:=Dir.Normalize;
 Up.x:=0.0; Up.y:=1.0; Up.z:=0.0;
 if abs(Dir.Dot(Up))>0.99 then begin
  Up.x:=1.0; Up.y:=0.0; Up.z:=0.0;
 end;
 Center.x:=Pos.x+Dir.x; Center.y:=Pos.y+Dir.y; Center.z:=Pos.z+Dir.z;
 Light.Matrix:=TpvMatrix4x4D.CreateInverseLookAt(Pos,Center,Up);
 result:=aThis;
end;

// light.setMatrix(m00..m15) — 16 doubles, row-major
function POCAScene3DLightFunctionSetMatrix(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
    Mat:TpvMatrix4x4D;
    I:TpvInt32;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<16 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 for I:=0 to 15 do begin
  Mat.RawComponents[I shr 2,I and 3]:=POCAGetNumberValue(aContext,aArguments^[I]);
 end;
 Light.Matrix:=Mat;
 result:=aThis;
end;

// light.setColor(r,g,b)
function POCAScene3DLightFunctionSetColor(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
    Col:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<3 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Col.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Col.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Col.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Light.Color:=Col;
 result:=aThis;
end;

// light.setIntensity(v)
function POCAScene3DLightFunctionSetIntensity(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.Intensity:=POCAGetNumberValue(aContext,aArguments^[0]);
 result:=aThis;
end;

// light.setRange(v)
function POCAScene3DLightFunctionSetRange(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.Range:=POCAGetNumberValue(aContext,aArguments^[0]);
 result:=aThis;
end;

// light.setConeAngles(innerDeg, outerDeg) — angles in degrees, converted to radians
function POCAScene3DLightFunctionSetConeAngles(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.InnerConeAngle:=POCAGetNumberValue(aContext,aArguments^[0])*(Pi/180.0);
 Light.OuterConeAngle:=POCAGetNumberValue(aContext,aArguments^[1])*(Pi/180.0);
 result:=aThis;
end;

// light.setCastShadows(bool)
function POCAScene3DLightFunctionSetCastShadows(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.CastShadows:=POCAGetNumberValue(aContext,aArguments^[0])<>0.0;
 result:=aThis;
end;

// light.setVisible(bool)
function POCAScene3DLightFunctionSetVisible(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 Light.Visible:=POCAGetNumberValue(aContext,aArguments^[0])<>0.0;
 result:=aThis;
end;

// light.update([inFlightFrameIndex]) — pushes state to GPU; default index -1
function POCAScene3DLightFunctionUpdate(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Light:TpvScene3D.TLight;
    Idx:TpvSizeInt;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 Light:=TpvScene3D.TLight(POCAGhostFastGetPointer(aThis));
 if not assigned(Light) then begin
  exit;
 end;
 if aCountArguments>=1 then begin
  Idx:=trunc(POCAGetNumberValue(aContext,aArguments^[0]));
 end else begin
  Idx:=-1;
 end;
 Light.Update(Idx);
 result:=aThis;
end;

// light.destroy() — frees the TLight; nulls ghost pointer
function POCAScene3DLightFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Light:TpvScene3D.TLight;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DLightGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Light:=TpvScene3D.TLight(Ghost^.Ptr);
  Ghost^.Ptr:=nil;
  FreeAndNil(Light);
 end;
end;


// --- Decal -----------------------------------------------------------------------

procedure POCAScene3DDecalGhostDestroy(const aGhost:PPOCAGhost);
var Data:PScene3DDecalGhostData;
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  Data:=PScene3DDecalGhostData(aGhost^.Ptr);
  aGhost^.Ptr:=nil;
  Dispose(Data);
 end;
end;

const POCAScene3DDecalGhost:TPOCAGhostType=
       (
        Destroy:POCAScene3DDecalGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DDecal'
       );

function POCANewScene3DDecalGhost(const aContext:PPOCAContext;const aScene3D:TpvScene3D;const aDecal:TpvScene3D.TDecal):TPOCAValue;
var Data:PScene3DDecalGhostData;
begin
 New(Data);
 Data^.Scene3D:=aScene3D;
 Data^.Decal:=aDecal;
 result:=POCANewGhost(aContext,@POCAScene3DDecalGhost,Data,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DDecalGhostHash);
end;

// engine.scene3d.spawnDecal(opts)
// opts: { position:[x,y,z], orientation:[x,y,z,w], rotation:f, size:[w,h],
//         albedoTexture, normalTexture, ormTexture, specularTexture, emissiveTexture,
//         blendMode:'alpha'|'multiply'|'overlay'|'additive'|'pbr'|'normalmap',
//         pbrBlendFactor, opacity, angleFade, edgeFade, lifetime, fadeOutTime,
//         passMesh, passPlanet, passGrass }
function POCAScene3DSceneFunctionSpawnDecal(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    OptsHash:TPOCAValue;
    OutValue:TPOCAValue;
    Position:TpvVector3D;
    Orientation:TpvQuaternion;
    Rotation:TpvFloat;
    Size:TpvVector2;
    AlbedoTex,NormalTex,ORMTex,SpecularTex,EmissiveTex:TpvInt32;
    BlendMode:TpvScene3D.TDecalBlendMode;
    PBRBlendFactor,Opacity,AngleFade,EdgeFade:TpvFloat;
    Lifetime,FadeOutTime:TpvDouble;
    Passes:TpvScene3D.TDecalPasses;
    BlendModeStr:TpvUTF8String;
    Decal:TpvScene3D.TDecal;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>POCAScene3DSceneGhostPointer then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 OptsHash:=aArguments^[0];
 OutValue:=POCAHashGetString(aContext,OptsHash,'position');
 if POCAIsValueNull(OutValue) then begin
  exit;
 end;
 Position.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
 Position.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
 Position.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
 Orientation:=TpvQuaternion.Identity;
 OutValue:=POCAHashGetString(aContext,OptsHash,'orientation');
 if not POCAIsValueNull(OutValue) then begin
  Orientation.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
  Orientation.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
  Orientation.z:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,2));
  Orientation.w:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,3));
 end;
 Rotation:=0.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'rotation');
 if not POCAIsValueNull(OutValue) then begin
  Rotation:=POCAGetNumberValue(aContext,OutValue);
 end;
 OutValue:=POCAHashGetString(aContext,OptsHash,'size');
 if POCAIsValueNull(OutValue) then begin
  exit;
 end;
 Size.x:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,0));
 Size.y:=POCAGetNumberValue(aContext,POCAArrayGet(OutValue,1));
 AlbedoTex:=-1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'albedoTexture');
 if not POCAIsValueNull(OutValue) then begin
  AlbedoTex:=trunc(POCAGetNumberValue(aContext,OutValue));
 end;
 NormalTex:=-1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'normalTexture');
 if not POCAIsValueNull(OutValue) then begin
  NormalTex:=trunc(POCAGetNumberValue(aContext,OutValue));
 end;
 ORMTex:=-1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'ormTexture');
 if not POCAIsValueNull(OutValue) then begin
  ORMTex:=trunc(POCAGetNumberValue(aContext,OutValue));
 end;
 SpecularTex:=-1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'specularTexture');
 if not POCAIsValueNull(OutValue) then begin
  SpecularTex:=trunc(POCAGetNumberValue(aContext,OutValue));
 end;
 EmissiveTex:=-1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'emissiveTexture');
 if not POCAIsValueNull(OutValue) then begin
  EmissiveTex:=trunc(POCAGetNumberValue(aContext,OutValue));
 end;
 BlendMode:=TpvScene3D.TDecalBlendMode.AlphaBlend;
 OutValue:=POCAHashGetString(aContext,OptsHash,'blendMode');
 if not POCAIsValueNull(OutValue) then begin
  BlendModeStr:=POCAGetStringValue(aContext,OutValue);
  if BlendModeStr='multiply' then begin
   BlendMode:=TpvScene3D.TDecalBlendMode.Multiply;
  end else if BlendModeStr='overlay' then begin
   BlendMode:=TpvScene3D.TDecalBlendMode.Overlay;
  end else if BlendModeStr='additive' then begin
   BlendMode:=TpvScene3D.TDecalBlendMode.Additive;
  end else if BlendModeStr='pbr' then begin
   BlendMode:=TpvScene3D.TDecalBlendMode.JustPBR;
  end else if BlendModeStr='normalmap' then begin
   BlendMode:=TpvScene3D.TDecalBlendMode.JustNormalMap;
  end;
 end;
 PBRBlendFactor:=1.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'pbrBlendFactor');
 if not POCAIsValueNull(OutValue) then begin
  PBRBlendFactor:=POCAGetNumberValue(aContext,OutValue);
 end;
 Opacity:=1.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'opacity');
 if not POCAIsValueNull(OutValue) then begin
  Opacity:=POCAGetNumberValue(aContext,OutValue);
 end;
 AngleFade:=1.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'angleFade');
 if not POCAIsValueNull(OutValue) then begin
  AngleFade:=POCAGetNumberValue(aContext,OutValue);
 end;
 EdgeFade:=0.1;
 OutValue:=POCAHashGetString(aContext,OptsHash,'edgeFade');
 if not POCAIsValueNull(OutValue) then begin
  EdgeFade:=POCAGetNumberValue(aContext,OutValue);
 end;
 Lifetime:=-1.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'lifetime');
 if not POCAIsValueNull(OutValue) then begin
  Lifetime:=POCAGetNumberValue(aContext,OutValue);
 end;
 FadeOutTime:=0.0;
 OutValue:=POCAHashGetString(aContext,OptsHash,'fadeOutTime');
 if not POCAIsValueNull(OutValue) then begin
  FadeOutTime:=POCAGetNumberValue(aContext,OutValue);
 end;
 Passes:=[TpvScene3D.TDecalPass.Mesh,TpvScene3D.TDecalPass.Planet,TpvScene3D.TDecalPass.Grass];
 OutValue:=POCAHashGetString(aContext,OptsHash,'passMesh');
 if not POCAIsValueNull(OutValue) then begin
  if POCAGetNumberValue(aContext,OutValue)<>0.0 then begin
   Include(Passes,TpvScene3D.TDecalPass.Mesh);
  end else begin
   Exclude(Passes,TpvScene3D.TDecalPass.Mesh);
  end;
 end;
 OutValue:=POCAHashGetString(aContext,OptsHash,'passPlanet');
 if not POCAIsValueNull(OutValue) then begin
  if POCAGetNumberValue(aContext,OutValue)<>0.0 then begin
   Include(Passes,TpvScene3D.TDecalPass.Planet);
  end else begin
   Exclude(Passes,TpvScene3D.TDecalPass.Planet);
  end;
 end;
 OutValue:=POCAHashGetString(aContext,OptsHash,'passGrass');
 if not POCAIsValueNull(OutValue) then begin
  if POCAGetNumberValue(aContext,OutValue)<>0.0 then begin
   Include(Passes,TpvScene3D.TDecalPass.Grass);
  end else begin
   Exclude(Passes,TpvScene3D.TDecalPass.Grass);
  end;
 end;
 Decal:=Scene3D.SpawnDecal(Position,Orientation,Rotation,Size,AlbedoTex,NormalTex,ORMTex,SpecularTex,EmissiveTex,BlendMode,PBRBlendFactor,Opacity,AngleFade,EdgeFade,Lifetime,FadeOutTime,Passes,nil);
 if not assigned(Decal) then begin
  exit;
 end;
 result:=POCANewScene3DDecalGhost(aContext,Scene3D,Decal);
end;

// decal.setVisible(bool)
function POCAScene3DDecalFunctionSetVisible(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data^.Decal.Visible:=POCAGetNumberValue(aContext,aArguments^[0])<>0.0;
 result:=aThis;
end;

// decal.setOpacity(f)
function POCAScene3DDecalFunctionSetOpacity(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data^.Decal.Opacity:=POCAGetNumberValue(aContext,aArguments^[0]);
 result:=aThis;
end;

// decal.setPosition(x, y, z) — TpvVector3D
function POCAScene3DDecalFunctionSetPosition(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
    Pos:TpvVector3D;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<3 then begin
  exit;
 end;
 Pos.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Pos.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Pos.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Data^.Decal.Position:=Pos;
 result:=aThis;
end;

// decal.setOrientation(qx, qy, qz, qw)
function POCAScene3DDecalFunctionSetOrientation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
    Q:TpvQuaternion;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<4 then begin
  exit;
 end;
 Q.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 Q.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 Q.z:=POCAGetNumberValue(aContext,aArguments^[2]);
 Q.w:=POCAGetNumberValue(aContext,aArguments^[3]);
 Data^.Decal.Orientation:=Q;
 result:=aThis;
end;

// decal.setRotation(f) — additional rotation about the decal normal, in radians
function POCAScene3DDecalFunctionSetRotation(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 Data^.Decal.Rotation:=POCAGetNumberValue(aContext,aArguments^[0]);
 result:=aThis;
end;

// decal.setSize(w, h) — width and height; depth defaults to 0.5 (matching SpawnDecal)
function POCAScene3DDecalFunctionSetSize(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
    S:TpvVector3;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<2 then begin
  exit;
 end;
 S.x:=POCAGetNumberValue(aContext,aArguments^[0]);
 S.y:=POCAGetNumberValue(aContext,aArguments^[1]);
 S.z:=0.5;
 Data^.Decal.Size:=S;
 result:=aThis;
end;

// decal.setBlendMode(mode) — 'alpha'|'multiply'|'overlay'|'additive'|'pbr'|'normalmap'
function POCAScene3DDecalFunctionSetBlendMode(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Data:PScene3DDecalGhostData;
    ModeStr:TpvUTF8String;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Data:=PScene3DDecalGhostData(POCAGhostFastGetPointer(aThis));
 if not assigned(Data) then begin
  exit;
 end;
 if not Data^.Scene3D.ValidDecal(Data^.Decal) then begin
  exit;
 end;
 if aCountArguments<1 then begin
  exit;
 end;
 ModeStr:=POCAGetStringValue(aContext,aArguments^[0]);
 if ModeStr='multiply' then begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.Multiply;
 end else if ModeStr='overlay' then begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.Overlay;
 end else if ModeStr='additive' then begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.Additive;
 end else if ModeStr='pbr' then begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.JustPBR;
 end else if ModeStr='normalmap' then begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.JustNormalMap;
 end else begin
  Data^.Decal.BlendMode:=TpvScene3D.TDecalBlendMode.AlphaBlend;
 end;
 result:=aThis;
end;

// decal.destroy() — marks Visible=false (if still valid), nulls pointer, frees data struct
function POCAScene3DDecalFunctionDestroy(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Ghost:PPOCAGhost;
    Data:PScene3DDecalGhostData;
begin
 result:=POCAValueNull;
 if POCAGhostGetType(aThis)<>@POCAScene3DDecalGhost then begin
  exit;
 end;
 Ghost:=POCAGhostGetPointer(aThis);
 if assigned(Ghost) and assigned(Ghost^.Ptr) then begin
  Data:=PScene3DDecalGhostData(Ghost^.Ptr);
  if Data^.Scene3D.ValidDecal(Data^.Decal) then begin
   Data^.Decal.Visible:=false;
  end;
  Ghost^.Ptr:=nil;
  Dispose(Data);
 end;
end;


// --- Scene -----------------------------------------------------------------------

const POCAScene3DSceneGhost:TPOCAGhostType=
       (
        Destroy:nil;    // TpvScene3D lifetime managed by the game, not POCA
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Scene3DScene'
       );

function POCANewScene3DGhost(const aContext:PPOCAContext;const aScene3D:TpvScene3D):TPOCAValue;
begin
 result:=POCANewGhost(aContext,POCAScene3DSceneGhostPointer,aScene3D,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAScene3DSceneGhostHash);
end;

// engine.scene3d.raycast(origin, direction, instances)
// origin, direction — POCA arrays [x,y,z]; instances — POCA array of Scene3DInstance ghosts
// Returns { instance, distance, position:{x,y,z}, u, v } or null
function POCAScene3DSceneFunctionRaycast(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Origin:TpvVector3;
    Direction:TpvVector3;
    InstArray:TPOCAValue;
    InstGhost:TPOCAValue;
    InstData:TScene3DInstanceGhostData;
    BakedMesh:TpvScene3D.TBakedMesh;
    TriIdx,InstIdx,InstCount:TpvSizeInt;
    HitTime,HitU,HitV:TpvScalar;
    BestTime,BestU,BestV:TpvScalar;
    BestInst:TPOCAValue;
    HitPos:TpvVector3;
    PosHash:TPOCAValue;
begin
 result:=POCAValueNull;
 if aCountArguments<3 then begin
  exit;
 end;
 Origin.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],0));
 Origin.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],1));
 Origin.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],2));
 Direction.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],0));
 Direction.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],1));
 Direction.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],2));
 InstArray:=aArguments^[2];
 InstCount:=POCAArraySize(InstArray);
 BestTime:=-1.0;
 BestU:=0.0;
 BestV:=0.0;
 BestInst:=POCAValueNull;
 for InstIdx:=0 to InstCount-1 do begin
  InstGhost:=POCAArrayGet(InstArray,InstIdx);
  if POCAGhostGetType(InstGhost)<>@POCAScene3DInstanceGhost then begin
   continue;
  end;
  InstData:=TScene3DInstanceGhostData(POCAGhostFastGetPointer(InstGhost));
  if not assigned(InstData) then begin
   continue;
  end;
  BakedMesh:=InstData.Instance.GetBakedMesh(false,false,-1);
  if not assigned(BakedMesh) then begin
   continue;
  end;
  for TriIdx:=0 to BakedMesh.Triangles.Count-1 do begin
   HitTime:=0.0;
   HitU:=0.0;
   HitV:=0.0;
   if BakedMesh.Triangles[TriIdx].RayIntersection(Origin,Direction,HitTime,HitU,HitV) then begin
    if (HitTime>0.0) and ((BestTime<0.0) or (HitTime<BestTime)) then begin
     BestTime:=HitTime;
     BestU:=HitU;
     BestV:=HitV;
     BestInst:=InstGhost;
    end;
   end;
  end;
  FreeAndNil(BakedMesh);
 end;
 if BestTime<0.0 then begin
  exit;
 end;
 HitPos.x:=Origin.x+Direction.x*BestTime;
 HitPos.y:=Origin.y+Direction.y*BestTime;
 HitPos.z:=Origin.z+Direction.z*BestTime;
 PosHash:=POCANewHash(aContext);
 POCAHashSetString(aContext,PosHash,'x',POCANewNumber(aContext,HitPos.x));
 POCAHashSetString(aContext,PosHash,'y',POCANewNumber(aContext,HitPos.y));
 POCAHashSetString(aContext,PosHash,'z',POCANewNumber(aContext,HitPos.z));
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'instance',BestInst);
 POCAHashSetString(aContext,result,'distance',POCANewNumber(aContext,BestTime));
 POCAHashSetString(aContext,result,'position',PosHash);
 POCAHashSetString(aContext,result,'u',POCANewNumber(aContext,BestU));
 POCAHashSetString(aContext,result,'v',POCANewNumber(aContext,BestV));
end;

// scene3d.addParticle(opts | pos, vel, grav, rotStart, rotEnd, sizeStart, sizeEnd, colStart, colEnd, lifetime, textureID, additive)
function POCAScene3DSceneFunctionAddParticle(const aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Scene3D:TpvScene3D;
    Opts:TPOCAValue;
    Position:TpvVector3;
    Velocity:TpvVector3;
    Gravity:TpvVector3;
    RotationStart:TpvFloat;
    RotationEnd:TpvFloat;
    SizeStart:TpvVector2;
    SizeEnd:TpvVector2;
    ColorStart:TpvVector4;
    ColorEnd:TpvVector4;
    LifeTime:TpvDouble;
    TextureID:TpvUInt32;
    AdditiveBlending:boolean;
    v:TPOCAValue;
    ParticleIndex:TpvSizeInt;
begin
 result:=POCAValueNull;
 if aCountArguments<1 then begin
  exit;
 end;
 Scene3D:=TpvScene3D(POCAGhostFastGetPointer(aThis));
 if not assigned(Scene3D) then begin
  exit;
 end;
 if POCAIsValueHash(aArguments^[0]) then begin
  // Hash opts mode
  Opts:=aArguments^[0];
  v:=POCAHashGetString(aContext,Opts,'position');
  if POCAIsValueNull(v) then begin
   exit;
  end;
  Position.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
  Position.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
  Position.z:=POCAGetNumberValue(aContext,POCAArrayGet(v,2));
  v:=POCAHashGetString(aContext,Opts,'velocity');
  if POCAIsValueNull(v) then begin
   Velocity.x:=0.0; Velocity.y:=0.0; Velocity.z:=0.0;
  end else begin
   Velocity.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   Velocity.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
   Velocity.z:=POCAGetNumberValue(aContext,POCAArrayGet(v,2));
  end;
  v:=POCAHashGetString(aContext,Opts,'gravity');
  if POCAIsValueNull(v) then begin
   Gravity.x:=0.0; Gravity.y:=0.0; Gravity.z:=0.0;
  end else begin
   Gravity.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   Gravity.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
   Gravity.z:=POCAGetNumberValue(aContext,POCAArrayGet(v,2));
  end;
  v:=POCAHashGetString(aContext,Opts,'rotationStart');
  if POCAIsValueNull(v) then begin
   RotationStart:=0.0;
  end else begin
   RotationStart:=POCAGetNumberValue(aContext,v);
  end;
  v:=POCAHashGetString(aContext,Opts,'rotationEnd');
  if POCAIsValueNull(v) then begin
   RotationEnd:=0.0;
  end else begin
   RotationEnd:=POCAGetNumberValue(aContext,v);
  end;
  v:=POCAHashGetString(aContext,Opts,'sizeStart');
  if POCAIsValueNull(v) then begin
   SizeStart.x:=1.0; SizeStart.y:=1.0;
  end else begin
   SizeStart.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   SizeStart.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
  end;
  v:=POCAHashGetString(aContext,Opts,'sizeEnd');
  if POCAIsValueNull(v) then begin
   SizeEnd.x:=0.0; SizeEnd.y:=0.0;
  end else begin
   SizeEnd.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   SizeEnd.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
  end;
  v:=POCAHashGetString(aContext,Opts,'colorStart');
  if POCAIsValueNull(v) then begin
   ColorStart.x:=1.0; ColorStart.y:=1.0; ColorStart.z:=1.0; ColorStart.w:=1.0;
  end else begin
   ColorStart.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   ColorStart.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
   ColorStart.z:=POCAGetNumberValue(aContext,POCAArrayGet(v,2));
   ColorStart.w:=POCAGetNumberValue(aContext,POCAArrayGet(v,3));
  end;
  v:=POCAHashGetString(aContext,Opts,'colorEnd');
  if POCAIsValueNull(v) then begin
   ColorEnd.x:=1.0; ColorEnd.y:=1.0; ColorEnd.z:=1.0; ColorEnd.w:=0.0;
  end else begin
   ColorEnd.x:=POCAGetNumberValue(aContext,POCAArrayGet(v,0));
   ColorEnd.y:=POCAGetNumberValue(aContext,POCAArrayGet(v,1));
   ColorEnd.z:=POCAGetNumberValue(aContext,POCAArrayGet(v,2));
   ColorEnd.w:=POCAGetNumberValue(aContext,POCAArrayGet(v,3));
  end;
  v:=POCAHashGetString(aContext,Opts,'lifetime');
  if POCAIsValueNull(v) then begin
   LifeTime:=1.0;
  end else begin
   LifeTime:=POCAGetNumberValue(aContext,v);
  end;
  v:=POCAHashGetString(aContext,Opts,'textureID');
  if POCAIsValueNull(v) then begin
   TextureID:=0;
  end else begin
   TextureID:=TpvUInt32(round(POCAGetNumberValue(aContext,v)));
  end;
  v:=POCAHashGetString(aContext,Opts,'additiveBlending');
  if POCAIsValueNull(v) then begin
   AdditiveBlending:=false;
  end else begin
   AdditiveBlending:=POCAGetNumberValue(aContext,v)<>0.0;
  end;
 end else begin
  // Positional args mode: pos, vel, grav, rotStart, rotEnd, sizeStart, sizeEnd, colStart, colEnd, lifetime, textureID, additive
  if aCountArguments<12 then begin
   exit;
  end;
  Position.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],0));
  Position.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],1));
  Position.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[0],2));
  Velocity.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],0));
  Velocity.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],1));
  Velocity.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[1],2));
  Gravity.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[2],0));
  Gravity.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[2],1));
  Gravity.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[2],2));
  RotationStart:=POCAGetNumberValue(aContext,aArguments^[3]);
  RotationEnd:=POCAGetNumberValue(aContext,aArguments^[4]);
  SizeStart.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[5],0));
  SizeStart.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[5],1));
  SizeEnd.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[6],0));
  SizeEnd.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[6],1));
  ColorStart.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[7],0));
  ColorStart.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[7],1));
  ColorStart.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[7],2));
  ColorStart.w:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[7],3));
  ColorEnd.x:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[8],0));
  ColorEnd.y:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[8],1));
  ColorEnd.z:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[8],2));
  ColorEnd.w:=POCAGetNumberValue(aContext,POCAArrayGet(aArguments^[8],3));
  LifeTime:=POCAGetNumberValue(aContext,aArguments^[9]);
  TextureID:=TpvUInt32(round(POCAGetNumberValue(aContext,aArguments^[10])));
  AdditiveBlending:=POCAGetNumberValue(aContext,aArguments^[11])<>0.0;
 end;
 ParticleIndex:=Scene3D.AddParticle(Position,Velocity,Gravity,RotationStart,RotationEnd,SizeStart,SizeEnd,ColorStart,ColorEnd,LifeTime,TextureID,AdditiveBlending);
 result.Num:=ParticleIndex;
end;


// --- Context registration --------------------------------------------------------

procedure InitializePOCAScene3DContext(const aContext:PPOCAContext;const aEngineHash:TPOCAValue);
begin
 // Create method hashes for each ghost type and protect them from GC.
 POCAScene3DSceneGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DSceneGhostHash);

 POCAScene3DGroupGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DGroupGhostHash);

 POCAScene3DMeshGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DMeshGhostHash);

 POCAScene3DPrimitiveGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DPrimitiveGhostHash);

 POCAScene3DNodeGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DNodeGhostHash);

 POCAScene3DGroupSceneGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DGroupSceneGhostHash);

 POCAScene3DInstanceGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DInstanceGhostHash);

 POCAScene3DRenderInstanceGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DRenderInstanceGhostHash);

 POCAScene3DMaterialGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DMaterialGhostHash);

 POCAScene3DImageGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DImageGhostHash);

 POCAScene3DSamplerGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DSamplerGhostHash);

 POCAScene3DTextureGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DTextureGhostHash);

 POCAScene3DLightGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DLightGhostHash);

 POCAScene3DGroupLightGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DGroupLightGhostHash);

 POCAScene3DDecalGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DDecalGhostHash);

 POCAScene3DBakedMeshGhostHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,POCAScene3DBakedMeshGhostHash);

 // Image methods
 POCAAddNativeFunction(aContext,POCAScene3DImageGhostHash,'upload',@POCAScene3DImageFunctionUpload,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DImageGhostHash,'isUploaded',@POCAScene3DImageFunctionIsUploaded,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DImageGhostHash,'destroy',@POCAScene3DImageFunctionDestroy,nil,nil);

 // Sampler methods
 POCAAddNativeFunction(aContext,POCAScene3DSamplerGhostHash,'destroy',@POCAScene3DSamplerFunctionDestroy,nil,nil);

 // Texture methods
 POCAAddNativeFunction(aContext,POCAScene3DTextureGhostHash,'destroy',@POCAScene3DTextureFunctionDestroy,nil,nil);

 // Scene factory functions for Image
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createImage',@POCAScene3DSceneFunctionCreateImage,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'loadImage',@POCAScene3DSceneFunctionLoadImage,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'getImageByName',@POCAScene3DSceneFunctionGetImageByName,nil,nil);

 // Scene factory functions for Sampler
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createSampler',@POCAScene3DSceneFunctionCreateSampler,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'defaultSampler',@POCAScene3DSceneFunctionDefaultSampler,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'defaultNonRepeatSampler',@POCAScene3DSceneFunctionDefaultNonRepeatSampler,nil,nil);

 // Scene factory functions for Texture
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createTexture',@POCAScene3DSceneFunctionCreateTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createTextureFromImage',@POCAScene3DSceneFunctionCreateTextureFromImage,nil,nil);

 // Material methods
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setShadingModel',@POCAScene3DMaterialFunctionSetShadingModel,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setAlphaMode',@POCAScene3DMaterialFunctionSetAlphaMode,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setAlphaCutoff',@POCAScene3DMaterialFunctionSetAlphaCutoff,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setDoubleSided',@POCAScene3DMaterialFunctionSetDoubleSided,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setCastShadows',@POCAScene3DMaterialFunctionSetCastShadows,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setReceiveShadows',@POCAScene3DMaterialFunctionSetReceiveShadows,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setNoWetness',@POCAScene3DMaterialFunctionSetNoWetness,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setBaseColorFactor',@POCAScene3DMaterialFunctionSetBaseColorFactor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setMetallicFactor',@POCAScene3DMaterialFunctionSetMetallicFactor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setRoughnessFactor',@POCAScene3DMaterialFunctionSetRoughnessFactor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setEmissiveFactor',@POCAScene3DMaterialFunctionSetEmissiveFactor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setBaseColorTexture',@POCAScene3DMaterialFunctionSetBaseColorTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setNormalTexture',@POCAScene3DMaterialFunctionSetNormalTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setMetallicRoughnessTexture',@POCAScene3DMaterialFunctionSetMetallicRoughnessTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setOcclusionTexture',@POCAScene3DMaterialFunctionSetOcclusionTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setEmissiveTexture',@POCAScene3DMaterialFunctionSetEmissiveTexture,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'setHologram',@POCAScene3DMaterialFunctionSetHologram,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'fillShaderData',@POCAScene3DMaterialFunctionFillShaderData,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMaterialGhostHash,'destroy',@POCAScene3DMaterialFunctionDestroy,nil,nil);

 // Scene factory function for Material
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createMaterial',@POCAScene3DSceneFunctionCreateMaterial,nil,nil);

 // Group methods
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'createMesh',@POCAScene3DGroupFunctionCreateMesh,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'createNode',@POCAScene3DGroupFunctionCreateNode,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'createScene',@POCAScene3DGroupFunctionCreateScene,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'addMaterial',@POCAScene3DGroupFunctionAddMaterial,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'finish',@POCAScene3DGroupFunctionFinish,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'createInstance',@POCAScene3DGroupFunctionCreateInstance,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'getAnimationID',@POCAScene3DGroupFunctionGetAnimationID,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupGhostHash,'destroy',@POCAScene3DGroupFunctionDestroy,nil,nil);

 // Mesh methods
 POCAAddNativeFunction(aContext,POCAScene3DMeshGhostHash,'createPrimitive',@POCAScene3DMeshFunctionCreatePrimitive,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMeshGhostHash,'calculateTangentSpace',@POCAScene3DMeshFunctionCalculateTangentSpace,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMeshGhostHash,'finish',@POCAScene3DMeshFunctionFinish,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DMeshGhostHash,'destroy',@POCAScene3DMeshFunctionDestroy,nil,nil);

 // Primitive methods
 POCAAddNativeFunction(aContext,POCAScene3DPrimitiveGhostHash,'setMaterial',@POCAScene3DPrimitiveFunctionSetMaterial,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DPrimitiveGhostHash,'addVertex',@POCAScene3DPrimitiveFunctionAddVertex,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DPrimitiveGhostHash,'addIndex',@POCAScene3DPrimitiveFunctionAddIndex,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DPrimitiveGhostHash,'finish',@POCAScene3DPrimitiveFunctionFinish,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DPrimitiveGhostHash,'destroy',@POCAScene3DPrimitiveFunctionDestroy,nil,nil);

 // Node methods
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setMesh',@POCAScene3DNodeFunctionSetMesh,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'addChild',@POCAScene3DNodeFunctionAddChild,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setTranslation',@POCAScene3DNodeFunctionSetTranslation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setRotation',@POCAScene3DNodeFunctionSetRotation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setScale',@POCAScene3DNodeFunctionSetScale,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setMatrix',@POCAScene3DNodeFunctionSetMatrix,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setVisible',@POCAScene3DNodeFunctionSetVisible,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'setCastShadows',@POCAScene3DNodeFunctionSetCastShadows,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'finish',@POCAScene3DNodeFunctionFinish,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DNodeGhostHash,'destroy',@POCAScene3DNodeFunctionDestroy,nil,nil);

 // GroupScene methods
 POCAAddNativeFunction(aContext,POCAScene3DGroupSceneGhostHash,'addNode',@POCAScene3DGroupSceneFunctionAddNode,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DGroupSceneGhostHash,'destroy',@POCAScene3DGroupSceneFunctionDestroy,nil,nil);

 // Scene factory function for Group
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createGroup',@POCAScene3DSceneFunctionCreateGroup,nil,nil);

 // Instance methods
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setScene',@POCAScene3DInstanceFunctionSetScene,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setActive',@POCAScene3DInstanceFunctionSetActive,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'isActive',@POCAScene3DInstanceFunctionIsActive,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setModelMatrix',@POCAScene3DInstanceFunctionSetModelMatrix,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'getModelMatrix',@POCAScene3DInstanceFunctionGetModelMatrix,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimation',@POCAScene3DInstanceFunctionSetAnimation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimationState',@POCAScene3DInstanceFunctionSetAnimationState,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'getAnimation',@POCAScene3DInstanceFunctionGetAnimation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimationFactor',@POCAScene3DInstanceFunctionSetAnimationFactor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimationTime',@POCAScene3DInstanceFunctionSetAnimationTime,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimationAdditive',@POCAScene3DInstanceFunctionSetAnimationAdditive,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'playAnimation',@POCAScene3DInstanceFunctionPlayAnimation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'stopAnimation',@POCAScene3DInstanceFunctionStopAnimation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'stopAllAnimations',@POCAScene3DInstanceFunctionStopAllAnimations,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'isAnimationPlaying',@POCAScene3DInstanceFunctionIsAnimationPlaying,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'getAnimationTime',@POCAScene3DInstanceFunctionGetAnimationTime,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'setAnimationTimeByName',@POCAScene3DInstanceFunctionSetAnimationTimeByName,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'updateAnimations',@POCAScene3DInstanceFunctionUpdateAnimations,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'getBakedMesh',@POCAScene3DInstanceFunctionGetBakedMesh,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'createRenderInstance',@POCAScene3DInstanceFunctionCreateRenderInstance,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DInstanceGhostHash,'destroy',@POCAScene3DInstanceFunctionDestroy,nil,nil);

 // RenderInstance methods
 POCAAddNativeFunction(aContext,POCAScene3DRenderInstanceGhostHash,'setActive',@POCAScene3DRenderInstanceFunctionSetActive,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DRenderInstanceGhostHash,'setModelMatrix',@POCAScene3DRenderInstanceFunctionSetModelMatrix,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DRenderInstanceGhostHash,'remove',@POCAScene3DRenderInstanceFunctionRemove,nil,nil);

 // Light factories on scene
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createPointLight',@POCAScene3DSceneFunctionCreatePointLight,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createSpotLight',@POCAScene3DSceneFunctionCreateSpotLight,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'createDirectionalLight',@POCAScene3DSceneFunctionCreateDirectionalLight,nil,nil);

 // Light methods
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setType',@POCAScene3DLightFunctionSetType,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setPosition',@POCAScene3DLightFunctionSetPosition,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setDirection',@POCAScene3DLightFunctionSetDirection,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setMatrix',@POCAScene3DLightFunctionSetMatrix,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setColor',@POCAScene3DLightFunctionSetColor,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setIntensity',@POCAScene3DLightFunctionSetIntensity,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setRange',@POCAScene3DLightFunctionSetRange,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setConeAngles',@POCAScene3DLightFunctionSetConeAngles,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setCastShadows',@POCAScene3DLightFunctionSetCastShadows,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'setVisible',@POCAScene3DLightFunctionSetVisible,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'update',@POCAScene3DLightFunctionUpdate,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DLightGhostHash,'destroy',@POCAScene3DLightFunctionDestroy,nil,nil);

 // Decal factory on scene
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'spawnDecal',@POCAScene3DSceneFunctionSpawnDecal,nil,nil);

 // Decal methods
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setVisible',@POCAScene3DDecalFunctionSetVisible,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setOpacity',@POCAScene3DDecalFunctionSetOpacity,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setPosition',@POCAScene3DDecalFunctionSetPosition,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setOrientation',@POCAScene3DDecalFunctionSetOrientation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setRotation',@POCAScene3DDecalFunctionSetRotation,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setSize',@POCAScene3DDecalFunctionSetSize,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'setBlendMode',@POCAScene3DDecalFunctionSetBlendMode,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DDecalGhostHash,'destroy',@POCAScene3DDecalFunctionDestroy,nil,nil);

 // BakedMesh methods
 POCAAddNativeFunction(aContext,POCAScene3DBakedMeshGhostHash,'raycast',@POCAScene3DBakedMeshFunctionRaycast,nil,nil);
 POCAAddNativeFunction(aContext,POCAScene3DBakedMeshGhostHash,'destroy',@POCAScene3DBakedMeshFunctionDestroy,nil,nil);

 // Scene raycast convenience helper
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'raycast',@POCAScene3DSceneFunctionRaycast,nil,nil);

 // Particle
 POCAAddNativeFunction(aContext,POCAScene3DSceneGhostHash,'addParticle',@POCAScene3DSceneFunctionAddParticle,nil,nil);

end;

procedure RegisterPOCAScene3DGhost(const aContext:PPOCAContext;const aScene3D:TpvScene3D;const aEngineHash:TPOCAValue);
begin
 POCAHashSetString(aContext,aEngineHash,'scene3d',POCANewScene3DGhost(aContext,aScene3D));
end;

procedure UnregisterPOCAScene3DGhost(const aContext:PPOCAContext;const aEngineHash:TPOCAValue);
begin
 POCAHashDeleteString(aContext,aEngineHash,'scene3d');
end;

initialization
 POCAScene3DSceneGhostPointer:=@POCAScene3DSceneGhost;
 POCAScene3DGroupGhostPointer:=@POCAScene3DGroupGhost;
 POCAScene3DMeshGhostPointer:=@POCAScene3DMeshGhost;
 POCAScene3DPrimitiveGhostPointer:=@POCAScene3DPrimitiveGhost;
 POCAScene3DNodeGhostPointer:=@POCAScene3DNodeGhost;
 POCAScene3DGroupSceneGhostPointer:=@POCAScene3DGroupSceneGhost;
 POCAScene3DInstanceGhostPointer:=@POCAScene3DInstanceGhost;
 POCAScene3DRenderInstanceGhostPointer:=@POCAScene3DRenderInstanceGhost;
 POCAScene3DMaterialGhostPointer:=@POCAScene3DMaterialGhost;
 POCAScene3DImageGhostPointer:=@POCAScene3DImageGhost;
 POCAScene3DSamplerGhostPointer:=@POCAScene3DSamplerGhost;
 POCAScene3DTextureGhostPointer:=@POCAScene3DTextureGhost;
 POCAScene3DLightGhostPointer:=@POCAScene3DLightGhost;
 POCAScene3DGroupLightGhostPointer:=@POCAScene3DGroupLightGhost;
 POCAScene3DDecalGhostPointer:=@POCAScene3DDecalGhost;
 POCAScene3DBakedMeshGhostPointer:=@POCAScene3DBakedMeshGhost;
end.
