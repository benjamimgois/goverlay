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
unit PasVulkan.VirtualReality;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$scopedenums on}
{$m+}

{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

{$if defined(Windows) or defined(Linux) or defined(Darwin)}
 {$define TargetWithOpenVRSupport}
{$else}
 {$undef TargetWithOpenVRSupport}
{$ifend}

// Attention: It is still work in progress

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     {$ifdef TargetWithOpenVRSupport}
      PasVulkan.VirtualReality.OpenVR,
     {$endif}
     PasVulkan.Types,
     PasVulkan.Assets,
     PasVulkan.Streams,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Collections,
     PasVulkan.NVIDIA.AfterMath;

type EpvVirtualReality=class(Exception);

     TpvVirtualReality=class
      public
       const FakedFOV=120.0;
             FocalLength=0.5;
             EyeSeparation=0.08;
             BooleanToSign:array[boolean] of TpvInt32=(1,-1);
{$ifdef TargetWithOpenVRSupport}
             OpenVREyes:array[0..1] of TpvInt32=(PasVulkan.VirtualReality.OpenVR.Eye_Left,PasVulkan.VirtualReality.OpenVR.Eye_Right);
{$endif}
       type TMode=
             (
              Disabled,
              OpenVR,
              Faked
             );
            TTrackingMode=
             (
              Seated,
              Standing,
              Raw
             );
            TTrackedDeviceClass=
             (
              Invalid,
              HMD,
              Controller,
              GenericTracker,
              TrackingReference,
              DisplayRedirect
             );
            TTrackedControllerRole=
             (
              Invalid,
              LeftHand,
              RightHand,
              OptOut
             );
            TProjectionMatrixMode=
             (
              Normal,
              ReversedZ,
              InfiniteFarPlaneReversedZ
             );
            TVulkanMemoryBlocks=TpvObjectGenericList<TpvVulkanDeviceMemoryBlock>;
            TVulkanImages=TpvObjectGenericList<TpvVulkanImage>;
            TVulkanImageViews=TpvObjectGenericList<TpvVulkanImageView>;
            TVulkanCommandBuffers=TpvObjectGenericList<TpvVulkanCommandBuffer>;
{$ifdef TargetWithOpenVRSupport}
            TOpenVRMatrix=record
             case TpvSizeInt of
              0:(
               m34:THmdMatrix34_t;
              );
              1:(
               m44:THmdMatrix44_t;
              );
              2:(
               Matrix:TpvMatrix4x4;
              );
            end;
{$endif}
            TTrackedDevice=class
             public
              type TAxes=array[0..4] of TpvVector2;
             private
              fParent:TpvVirtualReality;
              fTrackedDeviceID:TpvUInt64;
              fTrackedDeviceClass:TTrackedDeviceClass;
              fTrackedControllerRole:TTrackedControllerRole;
              fMatrix:TpvMatrix4x4;
              fVelocity:TpvVector3;
              fAngularVelocity:TpvVector3;
              fPoseIsValid:boolean;
              fButtonPressed:TpvUInt64;
              fButtonTouched:TpvUInt64;
              fAxes:TAxes;
             public
              constructor Create(const aParent:TpvVirtualReality); reintroduce;
              destructor Destroy; override;
             public
              property Matrix:TpvMatrix4x4 read fMatrix;
              property Velocity:TpvVector3 read fVelocity;
              property AngularVelocity:TpvVector3 read fAngularVelocity;
              property ButtonPressed:TpvUInt64 read fButtonPressed;
              property ButtonTouched:TpvUInt64 read fButtonTouched;
              property Axes:TAxes read fAxes;
             published
              property TrackedDeviceID:TpvUInt64 read fTrackedDeviceID;
              property TrackedDeviceClass:TTrackedDeviceClass read fTrackedDeviceClass;
              property TrackedControllerRole:TTrackedControllerRole read fTrackedControllerRole;
              property PoseIsValid:boolean read fPoseIsValid;
            end;
            TTrackedDevices=TpvObjectGenericList<TTrackedDevice>;
            TTrackedDeviceIDHashMap=TpvHashMap<TpvUInt64,TTrackedDevice>;
      private
       fMode:TMode;
       fTrackingMode:TTrackingMode;
       fProjectionMatrixMode:TProjectionMatrixMode;
       fFOV:TpvScalar;
       fZNear:TpvScalar;
       fZFar:TpvScalar;
       fImageFormat:TVkFormat;
       fWidth:TpvSizeInt;
       fHeight:TpvSizeInt;
       fPixelCountLimit:TpvInt64;
       fMultiviewMask:TpvUInt32;
       fCountImages:TpvSizeInt;
       fCountImagesInt32:TpvInt32;
       fCountSwapChainImages:TpvSizeInt;
       fCountInFlightFrames:TpvSizeInt;
       fInputAttachment:TpvSizeInt;
       fOutputAttachment:TpvSizeInt;
       fVulkanMemoryBlocks:TVulkanMemoryBlocks;
       fVulkanImages:TVulkanImages;
       fVulkanImageViews:TVulkanImageViews;
       fVulkanSingleImages:TVulkanImages;
       fVulkanSingleImageViews:TVulkanImageViews;
       fVulkanSampler:TpvVulkanSampler;
       fVulkanUniversalQueueCommandPool:TpvVulkanCommandPool;
       fVulkanCommandBuffers:TVulkanCommandBuffers;
       fVulkanSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanVertexShaderModule:TpvVulkanShaderModule;
       fVulkanFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanVulkanUniversalQueueCommandPool:TpvVulkanCommandPool;
       fVulkanUniversalQueueCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanUniversalQueueCommandBufferFence:TpvVulkanFence;
       fRequiredVulkanInstanceExtensions:TStringList;
       fRequiredVulkanDeviceExtensions:TStringList;
       fTrackedDevices:TTrackedDevices;
       fTrackedDeviceIDHashMap:TTrackedDeviceIDHashMap;
{$ifdef TargetWithOpenVRSupport}
       fOpenVR_HMD:PasVulkan.VirtualReality.OpenVR.TpovrIntPtr;
       fOpenVR_VR_IVRSystem_FnTable:PasVulkan.VirtualReality.OpenVR.PVR_IVRSystem_FnTable;
       fOpenVR_VR_IVRCompositor_FnTable:PasVulkan.VirtualReality.OpenVR.PVR_IVRCompositor_FnTable;
       fOpenVR_VR_IVRInput_FnTable:PasVulkan.VirtualReality.OpenVR.PVR_IVRInput_FnTable;
       fOpenVR_TrackedDevices:array[0..k_unMaxTrackedDeviceCount-1] of TTrackedDevice;
       fOpenVR_TrackedDevicePoses:array[0..k_unMaxTrackedDeviceCount-1] of PasVulkan.VirtualReality.OpenVR.TTrackedDevicePose_t;
       fOpenVR_ProjectionMatrices:array[0..1] of TpvMatrix4x4;
       fOpenVR_EyeToHeadTransformMatrices:array[0..1] of TpvMatrix4x4;
       fOpenVR_HMDMatrixOriginal:TpvMatrix4x4;
       fOpenVR_HMDMatrix:TpvMatrix4x4;
       fOpenVR_BaseInverseHMDMatrix:TpvMatrix4x4;
{$endif}
      public
       constructor Create(const aMode:TMode); reintroduce;
       destructor Destroy; override;
       procedure CheckVulkanInstanceExtensions(const aInstance:TpvVulkanInstance);
       procedure ChooseVulkanPhysicalDevice(const aInstance:TpvVulkanInstance;var aPhysicalDevice:TVkPhysicalDevice);
       procedure CheckVulkanDeviceExtensions(const aPhysicalDevice:TVkPhysicalDevice);
       procedure UpdateMatrices;
       procedure Load;
       procedure Unload;
       procedure AfterCreateSwapChain;
       procedure BeforeDestroySwapChain;
       function GetProjectionMatrix(const aIndex:TpvSizeInt):TpvMatrix4x4;
       function GetPositionMatrix(const aIndex:TpvSizeInt):TpvMatrix4x4;
       procedure Check(const aDeltaTime:TpvDouble);
       procedure Update(const aDeltaTime:TpvDouble);
       procedure BeginFrame(const aDeltaTime:TpvDouble);
       procedure Draw(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
       procedure FinishFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
       procedure PostPresent(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32);
       procedure ResetOrientation;
      public
       property PixelCountLimit:TpvInt64 read fPixelCountLimit write fPixelCountLimit;
      published
       property Mode:TMode read fMode write fMode default TMode.Disabled;
       property TrackingMode:TTrackingMode read fTrackingMode write fTrackingMode default TTrackingMode.Seated;
       property ProjectionMatrixMode:TProjectionMatrixMode read fProjectionMatrixMode write fProjectionMatrixMode default TProjectionMatrixMode.Normal;
       property FOV:TpvScalar read fFOV write fFOV;
       property ZNear:TpvScalar read fZNear write fZNear;
       property ZFar:TpvScalar read fZFar write fZFar;
       property ImageFormat:TVkFormat read fImageFormat write fImageFormat;
       property Width:TpvSizeInt read fWidth write fWidth default 1280;
       property Height:TpvSizeInt read fHeight write fHeight default 720;
       property MultiviewMask:TpvUInt32 read fMultiviewMask;
       property CountImages:TpvSizeInt read fCountImages write fCountImages default 1;
       property VulkanImages:TVulkanImages read fVulkanImages;
       property VulkanImageViews:TVulkanImageViews read fVulkanImageViews;
       property VulkanSingleImages:TVulkanImages read fVulkanSingleImages;
       property VulkanSingleImageViews:TVulkanImageViews read fVulkanSingleImageViews;
       property RequiredVulkanInstanceExtensions:TStringList read fRequiredVulkanInstanceExtensions;
       property RequiredVulkanDeviceExtensions:TStringList read fRequiredVulkanDeviceExtensions;
       property TrackedDevices:TTrackedDevices read fTrackedDevices;
     end;

implementation

{ TpvVirtualReality.TTrackedDevice }

constructor TpvVirtualReality.TTrackedDevice.Create(const aParent:TpvVirtualReality);
begin
 inherited Create;
 fParent:=aParent;
end;

destructor TpvVirtualReality.TTrackedDevice.Destroy;
begin
 inherited Destroy;
end;

{ TpvVirtualReality }

constructor TpvVirtualReality.Create(const aMode:TMode);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var eError:TEVRInitError;
     StrBuf:array of AnsiChar;
     StrBufLen:TpovrIntPtr;
     StrDriver,StrDisplay,StrError,StrExtensions:AnsiString;
     OpenVRWidth,
     OpenVRHeight:TpovrUInt32;
 begin

  pvApplication.VulkanNoUniqueObjectsValidation:=true;

  PasVulkan.VirtualReality.OpenVR.LoadOpenVR;

  if not VR_IsRuntimeInstalled then begin
   raise EpvVirtualReality.Create('OpenVR runtime not detected on the system');
  end;

  if not VR_IsHmdPresent then begin
   raise EpvVirtualReality.Create('HMD not detected on the system');
  end;

  eError:=VRInitError_None;
  fOpenVR_HMD:=VR_InitInternal(@eError,VRApplication_Scene);
  if (fOpenVR_HMD=0) or (eError<>VRInitError_None) then begin
   StrError:=VR_GetVRInitErrorAsEnglishDescription(eError);
   raise EpvVirtualReality.Create(String(StrError));
  end;

  eError:=VRInitError_None;
  fOpenVR_VR_IVRSystem_FnTable:=PVR_IVRSystem_FnTable(TpovrIntPtr(VR_GetGenericInterface(C_API_FNTABLE_PREFIX+IVRSystem_Version,@eError)));
  if eError<>VRInitError_None then begin
   StrError:=VR_GetVRInitErrorAsEnglishDescription(eError);
   raise EpvVirtualReality.Create(String(StrError));
  end;

  eError:=VRInitError_None;
  fOpenVR_VR_IVRCompositor_FnTable:=PVR_IVRCompositor_FnTable(TpovrIntPtr(VR_GetGenericInterface(C_API_FNTABLE_PREFIX+IVRCompositor_Version,@eError)));
  if eError<>VRInitError_None then begin
   StrError:=VR_GetVRInitErrorAsEnglishDescription(eError);
   raise EpvVirtualReality.Create(String(StrError));
  end;

  eError:=VRInitError_None;
  fOpenVR_VR_IVRInput_FnTable:=PVR_IVRInput_FnTable(TpovrIntPtr(VR_GetGenericInterface(C_API_FNTABLE_PREFIX+IVRInput_Version,@eError)));
  if eError<>VRInitError_None then begin
   StrError:=VR_GetVRInitErrorAsEnglishDescription(eError);
   raise EpvVirtualReality.Create(String(StrError));
  end;

  fOpenVR_VR_IVRSystem_FnTable^.GetRecommendedRenderTargetSize(@OpenVRWidth,@OpenVRHeight);

  fWidth:=OpenVRWidth;
  fHeight:=OpenVRHeight;

  StrBufLen:=fOpenVR_VR_IVRSystem_FnTable^.GetStringTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_TrackingSystemName_String,nil,0,@eError);
  if StrBufLen>0 then begin
   StrBuf:=nil;
   SetLength(StrBuf,StrBufLen+1);
   FillChar(StrBuf[0],StrBufLen+1,#0);
   StrBufLen:=fOpenVR_VR_IVRSystem_FnTable^.GetStringTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_TrackingSystemName_String,@StrBuf[0],StrBufLen,@eError);
   if StrBufLen>0 then begin
    StrDriver:=PAnsiChar(@StrBuf[0]);
   end else begin
    StrDriver:='No driver';
   end;
  end else begin
   StrDriver:='No driver';
  end;

  StrBufLen:=fOpenVR_VR_IVRSystem_FnTable^.GetStringTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_SerialNumber_String,nil,0,@eError);
  if StrBufLen>0 then begin
   StrBuf:=nil;
   SetLength(StrBuf,StrBufLen+1);
   FillChar(StrBuf[0],StrBufLen+1,#0);
   StrBufLen:=fOpenVR_VR_IVRSystem_FnTable^.GetStringTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_SerialNumber_String,@StrBuf[0],StrBufLen,@eError);
   if StrBufLen>0 then begin
    StrDisplay:=PAnsiChar(@StrBuf[0]);
   end else begin
    StrDisplay:='No display';
   end;
  end else begin
   StrDisplay:='No display';
  end;

  fOpenVR_VR_IVRCompositor_FnTable^.SetExplicitTimingMode(VRCompositorTimingMode_Explicit_ApplicationPerformsPostPresentHandoff);

  pvApplication.Log(LOG_INFO,'OpenVR','Driver: '+String(StrDriver));
  pvApplication.Log(LOG_INFO,'OpenVR','Display: '+String(StrDisplay));

  fOpenVR_HMDMatrixOriginal:=TpvMatrix4x4.Identity;

  fOpenVR_HMDMatrix:=TpvMatrix4x4.Identity;

  fOpenVR_BaseInverseHMDMatrix:=TpvMatrix4x4.Identity;

  FillChar(fOpenVR_TrackedDevices,SizeOf(fOpenVR_TrackedDevices),#0);

 end;
{$endif}
begin

 inherited Create;

 fMode:=aMode;

 fTrackingMode:=TTrackingMode.Seated;

 fProjectionMatrixMode:=TProjectionMatrixMode.Normal;

 fFOV:=53.13010235415598;

 fZNear:=1.0;

 fZFar:=1024.0;

 fImageFormat:=VK_FORMAT_R8G8B8A8_SRGB;

 fWidth:=1280;

 fHeight:=720;

 fPixelCountLimit:=0;

 fCountImages:=1;

 fCountSwapChainImages:=1;

 fCountInFlightFrames:=1;

 fMultiviewMask:=1 shl 0;

 fVulkanMemoryBlocks:=TVulkanMemoryBlocks.Create;
 fVulkanMemoryBlocks.OwnsObjects:=false;

 fVulkanImages:=TVulkanImages.Create;
 fVulkanImages.OwnsObjects:=true;

 fVulkanImageViews:=TVulkanImageViews.Create;
 fVulkanImageViews.OwnsObjects:=true;

 fVulkanSingleImages:=TVulkanImages.Create;
 fVulkanSingleImages.OwnsObjects:=true;

 fVulkanSingleImageViews:=TVulkanImageViews.Create;
 fVulkanSingleImageViews.OwnsObjects:=true;

 fVulkanCommandBuffers:=TVulkanCommandBuffers.Create;
 fVulkanCommandBuffers.Clear;

 fRequiredVulkanInstanceExtensions:=TStringList.Create;

 fRequiredVulkanDeviceExtensions:=TStringList.Create;

 fTrackedDevices:=TTrackedDevices.Create;
 fTrackedDevices.OwnsObjects:=true;

 fTrackedDeviceIDHashMap:=TTrackedDeviceIDHashMap.Create(nil);

 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$else}
   raise EpvVirtualReality.Create('No OpenVR support for this target');
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;

end;

destructor TpvVirtualReality.Destroy;
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 begin
  //VR_ShutdownInternal; // <= if it is uncommented, then it raises access violation exceptions inside the vrclient-*.dll
 end;
{$endif}
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
 FreeAndNil(fTrackedDeviceIDHashMap);
 FreeAndNil(fTrackedDevices);
 FreeAndNil(fRequiredVulkanInstanceExtensions);
 FreeAndNil(fRequiredVulkanDeviceExtensions);
 FreeAndNil(fVulkanCommandBuffers);
 FreeAndNil(fVulkanSingleImageViews);
 FreeAndNil(fVulkanSingleImages);
 FreeAndNil(fVulkanImageViews);
 FreeAndNil(fVulkanImages);
 FreeAndNil(fVulkanMemoryBlocks);
 inherited Destroy;
end;

procedure TpvVirtualReality.CheckVulkanInstanceExtensions(const aInstance:TpvVulkanInstance);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var StrBuf:array of AnsiChar;
     StrBufLen:TpovrIntPtr;
     StrExtensions:AnsiString;
 begin
  StrBufLen:=fOpenVR_VR_IVRCompositor_FnTable^.GetVulkanInstanceExtensionsRequired(nil,0);
  if StrBufLen>0 then begin
   StrBuf:=nil;
   SetLength(StrBuf,StrBufLen+1);
   FillChar(StrBuf[0],StrBufLen+1,#0);
   StrBufLen:=fOpenVR_VR_IVRCompositor_FnTable^.GetVulkanInstanceExtensionsRequired(@StrBuf[0],StrBufLen);
   if StrBufLen>0 then begin
    StrExtensions:=PAnsiChar(@StrBuf[0]);
    fRequiredVulkanInstanceExtensions.Delimiter:=#32;
    fRequiredVulkanInstanceExtensions.StrictDelimiter:=true;
    fRequiredVulkanInstanceExtensions.DelimitedText:=String(StrExtensions);
   end;
  end;
 end;
{$endif}
begin
 case fMode of
  TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
 end;
end;

procedure TpvVirtualReality.ChooseVulkanPhysicalDevice(const aInstance:TpvVulkanInstance;var aPhysicalDevice:TVkPhysicalDevice);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var PhysicalDeviceIDPropertiesKHR:TVkPhysicalDeviceIDPropertiesKHR;
     PhysicalDeviceProperties2KHR:TVkPhysicalDeviceProperties2KHR;
     PhysicalDevice:TpvVulkanPhysicalDevice;
     LUID:TVKUInt64;
     Error:TETrackedPropertyError;
 begin

  fOpenVR_VR_IVRSystem_FnTable^.GetOutputDevice(@aPhysicalDevice,TextureType_Vulkan,aInstance.Handle);

  if (aPhysicalDevice=VK_NULL_HANDLE) and
     (aInstance.EnabledExtensionNames.IndexOf(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)>=0) then begin

   LUID:=fOpenVR_VR_IVRSystem_FnTable^.GetUint64TrackedDeviceProperty(0,Prop_GraphicsAdapterLuid_Uint64,@Error);

   for PhysicalDevice in aInstance.PhysicalDevices do begin

    FillChar(PhysicalDeviceIDPropertiesKHR,SizeOf(TVkPhysicalDeviceIDPropertiesKHR),#0);
    PhysicalDeviceIDPropertiesKHR.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES_KHR;

    FillChar(PhysicalDeviceProperties2KHR,SizeOf(TVkPhysicalDeviceProperties2KHR),#0);
    PhysicalDeviceProperties2KHR.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2_KHR;
    PhysicalDeviceProperties2KHR.pNext:=@PhysicalDeviceIDPropertiesKHR;

    aInstance.Commands.GetPhysicalDeviceProperties2KHR(PhysicalDevice.Handle,@PhysicalDeviceProperties2KHR);

    if (PhysicalDeviceIDPropertiesKHR.deviceLUIDValid<>0) and
       CompareMem(@PhysicalDeviceIDPropertiesKHR.deviceLUID,
                  @LUID,
                  VK_LUID_SIZE_KHR) then begin
     aPhysicalDevice:=PhysicalDevice.Handle;
     break;
    end;

   end;

  end;

 end;
{$endif}
begin
 case fMode of
  TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
 end;
end;

procedure TpvVirtualReality.CheckVulkanDeviceExtensions(const aPhysicalDevice:TVkPhysicalDevice);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var StrBuf:array of AnsiChar;
     StrBufLen:TpovrIntPtr;
     StrExtensions:AnsiString;
 begin
  StrBufLen:=fOpenVR_VR_IVRCompositor_FnTable^.GetVulkanDeviceExtensionsRequired(aPhysicalDevice,nil,0);
  if StrBufLen>0 then begin
   StrBuf:=nil;
   SetLength(StrBuf,StrBufLen+1);
   FillChar(StrBuf[0],StrBufLen+1,#0);
   StrBufLen:=fOpenVR_VR_IVRCompositor_FnTable^.GetVulkanDeviceExtensionsRequired(aPhysicalDevice,@StrBuf[0],StrBufLen);
   if StrBufLen>0 then begin
    StrExtensions:=PAnsiChar(@StrBuf[0]);
    fRequiredVulkanDeviceExtensions.Delimiter:=#32;
    fRequiredVulkanDeviceExtensions.StrictDelimiter:=true;
    fRequiredVulkanDeviceExtensions.DelimitedText:=String(StrExtensions);
   end;
  end;
 end;
{$endif}
begin
 case fMode of
  TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
 end;
end;

procedure TpvVirtualReality.UpdateMatrices;
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var EyeIndex:TpvSizeInt;
     OpenVRMatrix:TOpenVRMatrix;
 begin

  for EyeIndex:=0 to 1 do begin

   OpenVRMatrix.m44:=fOpenVR_VR_IVRSystem_FnTable^.GetProjectionMatrix(OpenVREyes[EyeIndex],abs(fZNear),IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
   fOpenVR_ProjectionMatrices[EyeIndex]:=OpenVRMatrix.Matrix.Transpose;
   if fZFar<0.0 then begin
    if IsInfinite(fZFar) then begin
     // Convert to reversed infinite Z
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,2]:=0.0;
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,3]:=-1.0;
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[3,2]:=abs(fZNear);
    end else begin
     // Convert to reversed non-infinite Z
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,3]:=-1.0;
     fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
    end;
   end else begin
    fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
    fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[2,3]:=-1.0;
    fOpenVR_ProjectionMatrices[EyeIndex].RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
   end;
   fOpenVR_ProjectionMatrices[EyeIndex]:=fOpenVR_ProjectionMatrices[EyeIndex]*TpvMatrix4x4.FlipYClipSpace;

   OpenVRMatrix.m44.m[3,0]:=0.0;
   OpenVRMatrix.m44.m[3,1]:=0.0;
   OpenVRMatrix.m44.m[3,2]:=0.0;
   OpenVRMatrix.m44.m[3,3]:=1.0;
   OpenVRMatrix.m34:=fOpenVR_VR_IVRSystem_FnTable^.GetEyeToHeadTransform(OpenVREyes[EyeIndex]);
   fOpenVR_EyeToHeadTransformMatrices[EyeIndex]:=OpenVRMatrix.Matrix.Transpose.Inverse;

  end;

 end;
{$endif}
begin
 case fMode of
  TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TMode.Faked:begin
  end;
  else {TMode.Disabled:}begin
  end;
 end;
end;

procedure TpvVirtualReality.Load;
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var OpenVRWidth,
     OpenVRHeight:TpovrUInt32;
 begin

  fOpenVR_VR_IVRSystem_FnTable^.GetRecommendedRenderTargetSize(@OpenVRWidth,@OpenVRHeight);

  fWidth:=OpenVRWidth;
  fHeight:=OpenVRHeight;

  if fPixelCountLimit>0 then begin
   while (TpvInt64(fWidth)*fHeight)>fPixelCountLimit do begin
    fWidth:=(fWidth+1) div 2;
    fHeight:=(fHeight+1) div 2;
   end;
  end;

  fCountImages:=2;

  fMultiviewMask:=(1 shl 0) or (1 shl 1);

  fOpenVR_HMDMatrixOriginal:=TpvMatrix4x4.Identity;

  fOpenVR_HMDMatrix:=TpvMatrix4x4.Identity;

  fOpenVR_BaseInverseHMDMatrix:=TpvMatrix4x4.Identity;

 end;
{$endif}
var Index:TpvSizeInt;
    Stream:TStream;
begin

 if not pvApplication.VulkanMultiviewSupportEnabled then begin
  raise EpvVulkanException.Create('Missing Vulkan multi-view support');
 end;

 case fMode of
  TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TMode.Faked:begin
   fWidth:=640;
   fHeight:=720;
   fCountImages:=2;
   fMultiviewMask:=(1 shl 0) or (1 shl 1);
  end;
  else {TMode.Disabled:}begin
   fCountImages:=1;
   fMultiviewMask:=1 shl 0;
// fMultiviewMask:=0;
  end;
 end;

 fCountImagesInt32:=fCountImages;

 if fCountImages>1 then begin
  Stream:=TpvDataStream.Create(@PasVulkan.Assets.VREnabledToScreenBlitVertSPIRVData[0],PasVulkan.Assets.VREnabledToScreenBlitVertSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@PasVulkan.Assets.VRDisabledToScreenBlitVertSPIRVData[0],PasVulkan.Assets.VRDisabledToScreenBlitVertSPIRVDataSize);
 end;
 try
  fVulkanVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fCountImages>1 then begin
  Stream:=TpvDataStream.Create(@PasVulkan.Assets.VREnabledToScreenBlitFragSPIRVData[0],PasVulkan.Assets.VREnabledToScreenBlitFragSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@PasVulkan.Assets.VRDisabledToScreenBlitFragSPIRVData[0],PasVulkan.Assets.VRDisabledToScreenBlitFragSPIRVDataSize);
 end;
 try
  fVulkanFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVulkanVertexShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fVulkanFragmentShaderModule,'main');

 fVulkanSampler:=TpvVulkanSampler.Create(pvApplication.VulkanDevice,
                                         VK_FILTER_LINEAR,
                                         VK_FILTER_LINEAR,
                                         VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                         VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                         VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                         VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                         0.0,
                                         false,
                                         0.0,
                                         false,
                                         VK_COMPARE_OP_ALWAYS,
                                         0.0,
                                         1.0,
                                         VK_BORDER_COLOR_INT_OPAQUE_BLACK,
                                         false);

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 fVulkanVulkanUniversalQueueCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                               pvApplication.VulkanDevice.UniversalQueueFamilyIndex,
                                                               TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanUniversalQueueCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanVulkanUniversalQueueCommandPool,
                                                                   VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanUniversalQueueCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 UpdateMatrices;

end;

procedure TpvVirtualReality.Unload;
var Index:TpvSizeInt;
begin

 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanSemaphores[Index]);
 end;

 FreeAndNil(fVulkanUniversalQueueCommandPool);

 FreeAndNil(fVulkanSampler);

 FreeAndNil(fVulkanPipelineShaderStageVertex);

 FreeAndNil(fVulkanPipelineShaderStageFragment);

 FreeAndNil(fVulkanVertexShaderModule);

 FreeAndNil(fVulkanFragmentShaderModule);

 FreeAndNil(fVulkanUniversalQueueCommandBuffer);

 FreeAndNil(fVulkanUniversalQueueCommandBufferFence);

 FreeAndNil(fVulkanVulkanUniversalQueueCommandPool);

end;

procedure TpvVirtualReality.AfterCreateSwapChain;
const NVCheckpoint:RawByteString='TpvVirtualReality';
var Index,
    InFlightFrameIndex,
    SwapChainImageIndex:TpvSizeInt;
    Image:TpvVulkanImage;
    ImageView:TpvVulkanImageView;
    CommandBuffer:TpvVulkanCommandBuffer;
    Region:TVkImageBlit;
    ImageMemoryBarriers:TVkImageMemoryBarrierArray;
    ImageMemoryBarrier:PVkImageMemoryBarrier;
    ImageSubresourceRange:TVkImageSubresourceRange;
    InputAttachments:array of TVkInt32;
 procedure AllocateImageMemory;
 var MemoryRequirements:TVkMemoryRequirements;
     RequiresDedicatedAllocation,
     PrefersDedicatedAllocation:boolean;
     MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
     MemoryAllocationType:TpvVulkanDeviceMemoryAllocationType;
     MemoryBlock:TpvVulkanDeviceMemoryBlock;
 begin

  MemoryRequirements:=pvApplication.VulkanDevice.MemoryManager.GetImageMemoryRequirements(Image.Handle,
                                                                                          RequiresDedicatedAllocation,
                                                                                          PrefersDedicatedAllocation);

  MemoryBlockFlags:=[];

  if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
   Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
  end;

  MemoryAllocationType:=TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

  MemoryBlock:=pvApplication.VulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
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
                                                                            MemoryAllocationType,
                                                                            @Image.Handle);
  if not assigned(MemoryBlock) then begin
   raise EpvVulkanMemoryAllocationException.Create('Memory for image resource couldn''t be allocated!');
  end;

  fVulkanMemoryBlocks.Add(MemoryBlock);

  VulkanCheckResult(pvApplication.VulkanDevice.Commands.BindImageMemory(Image.Device.Handle,
                                                                        Image.Handle,
                                                                        MemoryBlock.MemoryChunk.Handle,
                                                                        MemoryBlock.Offset));

 end;
begin

 begin

  BeforeDestroySwapChain;

  case fMode of
   TMode.OpenVR:begin
   end;
   TMode.Faked:begin
    fWidth:=pvApplication.VulkanSwapChain.Width div 2;
    fHeight:=pvApplication.VulkanSwapChain.Height;
   end;
   else {TMode.Disabled:}begin
    fWidth:=pvApplication.VulkanSwapChain.Width;
    fHeight:=pvApplication.VulkanSwapChain.Height;
   end;
  end;

  fVulkanUniversalQueueCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                                pvApplication.VulkanDevice.UniversalQueueFamilyIndex,
                                                                TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fCountSwapChainImages:=pvApplication.CountSwapChainImages;

  fCountInFlightFrames:=pvApplication.CountInFlightFrames;

  fVulkanMemoryBlocks.Clear;

  begin

   fVulkanImages.Clear;

   for Index:=0 to fCountInFlightFrames-1 do begin

    Image:=TpvVulkanImage.Create(pvApplication.VulkanDevice,
                                 0,
                                 VK_IMAGE_TYPE_2D,
                                 fImageFormat,
                                 fWidth,
                                 fHeight,
                                 1,
                                 1,
                                 fCountImages,
                                 VK_SAMPLE_COUNT_1_BIT,
                                 VK_IMAGE_TILING_OPTIMAL,
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT),
                                 VK_SHARING_MODE_EXCLUSIVE,
                                 pvApplication.VulkanDevice.QueueFamilyIndices.ItemArray,
                                 VK_IMAGE_LAYOUT_UNDEFINED);

//  pvApplication.VulkanDevice.DebugMarker.SetObjectName(Image.Handle,VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT,'LayeredImage'+IntToStr(Index));

    fVulkanImages.Add(Image);

    AllocateImageMemory;

    ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    ImageSubresourceRange.baseMipLevel:=0;
    ImageSubresourceRange.levelCount:=1;
    ImageSubresourceRange.baseArrayLayer:=0;
    ImageSubresourceRange.layerCount:=fCountImages;

    Image.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                    TVkAccessFlags(0),
                    TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                    TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT),
                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                    pvApplication.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                    @ImageSubresourceRange,
                    fVulkanUniversalQueueCommandBuffer,
                    pvApplication.VulkanDevice.UniversalQueue,
                    fVulkanUniversalQueueCommandBufferFence,
                    true);

    if fCountImages>1 then begin
     ImageView:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                          Image,
                                          VK_IMAGE_VIEW_TYPE_2D_ARRAY,
                                          fImageFormat,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                          0,
                                          1,
                                          0,
                                          fCountImages);
    end else begin
     ImageView:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                          Image,
                                          VK_IMAGE_VIEW_TYPE_2D,
                                          fImageFormat,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          VK_COMPONENT_SWIZZLE_IDENTITY,
                                          TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                          0,
                                          1,
                                          0,
                                          fCountImages);
    end;

    fVulkanImageViews.Add(ImageView);

   end;

  end;

  fVulkanSingleImageViews.Clear;

  fVulkanSingleImages.Clear;

  if fMode in [TMode.OpenVR{,TMode.Faked}] then begin

   for Index:=0 to (fCountImages*fCountInFlightFrames)-1 do begin

    Image:=TpvVulkanImage.Create(pvApplication.VulkanDevice,
                                 0,
                                 VK_IMAGE_TYPE_2D,
                                 fImageFormat,
                                 fWidth,
                                 fHeight,
                                 1,
                                 1,
                                 1,
                                 VK_SAMPLE_COUNT_1_BIT,
                                 VK_IMAGE_TILING_OPTIMAL,
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or
                                 TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT),
                                 VK_SHARING_MODE_EXCLUSIVE,
                                 pvApplication.VulkanDevice.QueueFamilyIndices.ItemArray,
                                 VK_IMAGE_LAYOUT_UNDEFINED);

//  pvApplication.VulkanDevice.DebugMarker.SetObjectName(Image.Handle,VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT,'SingleImage'+IntToStr(Index));

    fVulkanSingleImages.Add(Image);

    AllocateImageMemory;

    Image.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                    TVkAccessFlags(0),
                    TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or
                    TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT) or
                    TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                    TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT),
                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                    pvApplication.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits or
                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                    nil,
                    fVulkanUniversalQueueCommandBuffer,
                    pvApplication.VulkanDevice.UniversalQueue,
                    fVulkanUniversalQueueCommandBufferFence,
                    true);

    ImageView:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                         Image,
                                         VK_IMAGE_VIEW_TYPE_2D,
                                         fImageFormat,
                                         VK_COMPONENT_SWIZZLE_IDENTITY,
                                         VK_COMPONENT_SWIZZLE_IDENTITY,
                                         VK_COMPONENT_SWIZZLE_IDENTITY,
                                         VK_COMPONENT_SWIZZLE_IDENTITY,
                                         TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                         0,
                                         1,
                                         0,
                                         1);

    fVulkanSingleImageViews.Add(ImageView);

   end;

  end;

  begin

   fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                         TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                         fCountInFlightFrames);
   fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fCountInFlightFrames);
   fVulkanDescriptorPool.Initialize;

   fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
   fVulkanDescriptorSetLayout.AddBinding(0,
                                         VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                         1,
                                         TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                         []);
   fVulkanDescriptorSetLayout.Initialize;

   for Index:=0 to fCountInFlightFrames-1 do begin
    fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                fVulkanDescriptorSetLayout);
    fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                      0,
                                                      1,
                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                      [TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                     fVulkanImageViews[Index].Handle,
                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                      [],
                                                      [],
                                                      false
                                                     );
    fVulkanDescriptorSets[Index].Flush;
   end;

   fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
   fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
   if fCountImages>1 then begin
    fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                               TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                               0,
                                               SizeOf(TpvInt32));
   end;
   fVulkanPipelineLayout.Initialize;

  end;

  begin

   fVulkanRenderPass:=TpvVulkanRenderPass.Create(pvApplication.VulkanDevice);

   if fCountImages>0 then begin
    InputAttachments:=nil;
    fInputAttachment:=-1;
   end else begin
    fInputAttachment:=fVulkanRenderPass.AddAttachmentDescription(0,
                                                                 fImageFormat,
                                                                 VK_SAMPLE_COUNT_1_BIT,
                                                                 VK_ATTACHMENT_LOAD_OP_LOAD,
                                                                 VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                 VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                 VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                                                                );
    InputAttachments:=[fVulkanRenderPass.AddAttachmentReference(fInputAttachment,
                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)];
   end;

   fOutputAttachment:=fVulkanRenderPass.AddAttachmentDescription(0,
                                                                 pvApplication.VulkanSwapChain.ImageFormat,
                                                                 VK_SAMPLE_COUNT_1_BIT,
                                                                 VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                 VK_ATTACHMENT_STORE_OP_STORE,
                                                                 VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                 VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                 VK_IMAGE_LAYOUT_UNDEFINED,
                                                                 VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
                                                                );

   fVulkanRenderPass.AddSubpassDescription(0,
                                           VK_PIPELINE_BIND_POINT_GRAPHICS,
                                           InputAttachments,
                                           [fVulkanRenderPass.AddAttachmentReference(fOutputAttachment,
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
                                                                                                                               VK_IMAGE_LAYOUT_UNDEFINED,
                                                                                                                               VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                                                              ),
                                                                                    VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                   ),
                                           []);
   fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                          0,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
   fVulkanRenderPass.AddSubpassDependency(0,
                                          VK_SUBPASS_EXTERNAL,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
{   fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                          0,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
   fVulkanRenderPass.AddSubpassDependency(0,
                                          VK_SUBPASS_EXTERNAL,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));}
(*   fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                          0,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                          TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
   fVulkanRenderPass.AddSubpassDependency(0,
                                          VK_SUBPASS_EXTERNAL,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                          TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
*)
{  fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                          0,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                          TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
   fVulkanRenderPass.AddSubpassDependency(0,
                                          VK_SUBPASS_EXTERNAL,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                          TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                          TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                          TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                          TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));}
   fVulkanRenderPass.Initialize;

// pvApplication.VulkanDevice.DebugMarker.SetObjectName(fVulkanRenderPass.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_RENDER_PASS_EXT,'VR_Blit_RenderPass');

  end;

  begin

   fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                             pvApplication.VulkanPipelineCache,
                                                             0,
                                                             [],
                                                             fVulkanPipelineLayout,
                                                             fVulkanRenderPass,
                                                             0,
                                                             nil,
                                                             0);

   fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageVertex);
   fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageFragment);

   fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
   fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

   fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
   fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);

   fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
   fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
   fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
   fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
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
   fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
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

  end;

  begin

   fVulkanCommandBuffers.Clear;

   ImageMemoryBarriers:=nil;
   try

    SetLength(ImageMemoryBarriers,Max(2,fCountImages+1));

    for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin

     for SwapChainImageIndex:=0 to fCountSwapChainImages-1 do begin

      CommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanUniversalQueueCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

      try

       CommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));

       if pvApplication.VulkanDevice.UseNVIDIADeviceDiagnostics and assigned(pvApplication.VulkanDevice.Commands.Commands.CmdSetCheckpointNV) then begin
        pvApplication.VulkanDevice.Commands.CmdSetCheckpointNV(CommandBuffer.Handle,PAnsiChar(NVCheckpoint));
       end;

       if fVulkanSingleImages.Count>0 then begin

        // If the corresponding VR-API requires it (for example, if it have no multiview-image-support), then blit
        // layered multiview image to individual single images for the to-VR-API submission

        begin

         for Index:=0 to fCountImages-1 do begin
          ImageMemoryBarrier:=@ImageMemoryBarriers[Index];
          FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
          ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
          ImageMemoryBarrier^.pNext:=nil;
          ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
          ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
          ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
          ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
          ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.image:=fVulkanSingleImages[(InFlightFrameIndex*fCountImages)+Index].Handle;
          ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
          ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
          ImageMemoryBarrier^.subresourceRange.levelCount:=1;
          ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
          ImageMemoryBarrier^.subresourceRange.layerCount:=1;
         end;

         begin
          ImageMemoryBarrier:=@ImageMemoryBarriers[fCountImages];
          FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
          ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
          ImageMemoryBarrier^.pNext:=nil;
          ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                             TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
          ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
          ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
          ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
          ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.image:=fVulkanImages[InFlightFrameIndex].Handle;
          ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
          ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
          ImageMemoryBarrier^.subresourceRange.levelCount:=1;
          ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
          ImageMemoryBarrier^.subresourceRange.layerCount:=fCountImages;
         end;

         CommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                          0,
                                          0,
                                          nil,
                                          0,
                                          nil,
                                          fCountImages+1,
                                          @ImageMemoryBarriers[0]);

        end;

        for Index:=0 to fCountImages-1 do begin
         Region.srcSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
         Region.srcSubresource.mipLevel:=0;
         Region.srcSubresource.baseArrayLayer:=Index;
         Region.srcSubresource.layerCount:=1;
         Region.srcOffsets[0].x:=0;
         Region.srcOffsets[0].y:=0;
         Region.srcOffsets[0].z:=0;
         Region.srcOffsets[1].x:=fWidth;
         Region.srcOffsets[1].y:=fHeight;
         Region.srcOffsets[1].z:=1;
         Region.dstSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
         Region.dstSubresource.mipLevel:=0;
         Region.dstSubresource.baseArrayLayer:=0;
         Region.dstSubresource.layerCount:=1;
         Region.dstOffsets[0].x:=0;
         Region.dstOffsets[0].y:=0;
         Region.dstOffsets[0].z:=0;
         Region.dstOffsets[1].x:=fWidth;
         Region.dstOffsets[1].y:=fHeight;
         Region.dstOffsets[1].z:=1;
         CommandBuffer.CmdBlitImage(fVulkanImages[InFlightFrameIndex].Handle,
                                    VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                                    fVulkanSingleImages[(InFlightFrameIndex*fCountImages)+Index].Handle,
                                    VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                    1,
                                    @Region,
                                    VK_FILTER_NEAREST);
        end;

        begin

         for Index:=0 to fCountImages-1 do begin
          ImageMemoryBarrier:=@ImageMemoryBarriers[Index];
          FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
          ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
          ImageMemoryBarrier^.pNext:=nil;
          ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
          ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
          ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
          ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
          ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.image:=fVulkanSingleImages[(InFlightFrameIndex*fCountImages)+Index].Handle;
          ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
          ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
          ImageMemoryBarrier^.subresourceRange.levelCount:=1;
          ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
          ImageMemoryBarrier^.subresourceRange.layerCount:=1;
         end;

         begin
          ImageMemoryBarrier:=@ImageMemoryBarriers[fCountImages];
          FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
          ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
          ImageMemoryBarrier^.pNext:=nil;
          ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
          ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                             TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                             TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT) or
                                             TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
          ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
          ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
          ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarrier^.image:=fVulkanImages[InFlightFrameIndex].Handle;
          ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
          ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
          ImageMemoryBarrier^.subresourceRange.levelCount:=1;
          ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
          ImageMemoryBarrier^.subresourceRange.layerCount:=fCountImages;
         end;

 //      pvApplication.VulkanDevice.DebugMarker.BeginRegion(CommandBuffer,'VR_vkCmdPipeline_0_0',[1.0,1.0,1.0,1.0]);

         CommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                          0,
                                          0,
                                          nil,
                                          0,
                                          nil,
                                          fCountImages+1,
                                          @ImageMemoryBarriers[0]);

 //     pvApplication.VulkanDevice.DebugMarker.EndRegion(CommandBuffer);

        end;

       end else if fInputAttachment<0 then begin

        begin
         ImageMemoryBarrier:=@ImageMemoryBarriers[0];
         FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
         ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
         ImageMemoryBarrier^.pNext:=nil;
         ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                            TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
         ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                            TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                            TVkAccessFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT) or
                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
         ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
         ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
         ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
         ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
         ImageMemoryBarrier^.image:=fVulkanImages[InFlightFrameIndex].Handle;
         ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
         ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
         ImageMemoryBarrier^.subresourceRange.levelCount:=1;
         ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
         ImageMemoryBarrier^.subresourceRange.layerCount:=fCountImages;
        end;

 //     pvApplication.VulkanDevice.DebugMarker.BeginRegion(CommandBuffer,'VR_vkCmdPipeline_0_0',[1.0,1.0,1.0,1.0]);

        CommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                         0,
                                         0,
                                         nil,
                                         0,
                                         nil,
                                         1,
                                         @ImageMemoryBarriers[0]);

 //    pvApplication.VulkanDevice.DebugMarker.EndRegion(CommandBuffer);

       end;

       begin

        // Blit layered multiview image to screen

        fVulkanRenderPass.BeginRenderPass(CommandBuffer,
                                          pvApplication.VulkanFrameBuffers[SwapChainImageIndex],
                                          VK_SUBPASS_CONTENTS_INLINE,
                                          0,
                                          0,
                                          pvApplication.VulkanSwapChain.Width,
                                          pvApplication.VulkanSwapChain.Height);

        if fCountImages>1 then begin
         CommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                        TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                        0,
                                        SizeOf(TpvInt32),
                                        @fCountImagesInt32);
        end;
        CommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,1,@fVulkanDescriptorSets[InFlightFrameIndex].Handle,0,nil);
        CommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
        CommandBuffer.CmdDraw(3,1,0,0);

        fVulkanRenderPass.EndRenderPass(CommandBuffer);

       end;

       if fInputAttachment<0 then begin

        begin
         ImageMemoryBarrier:=@ImageMemoryBarriers[0];
         FillChar(ImageMemoryBarrier^,SizeOf(TVkImageMemoryBarrier),#0);
         ImageMemoryBarrier^.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
         ImageMemoryBarrier^.pNext:=nil;
         ImageMemoryBarrier^.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
         ImageMemoryBarrier^.dstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                            TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
         ImageMemoryBarrier^.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
         ImageMemoryBarrier^.newLayout:=VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
         ImageMemoryBarrier^.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
         ImageMemoryBarrier^.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
         ImageMemoryBarrier^.image:=fVulkanImages[InFlightFrameIndex].Handle;
         ImageMemoryBarrier^.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
         ImageMemoryBarrier^.subresourceRange.baseMipLevel:=0;
         ImageMemoryBarrier^.subresourceRange.levelCount:=1;
         ImageMemoryBarrier^.subresourceRange.baseArrayLayer:=0;
         ImageMemoryBarrier^.subresourceRange.layerCount:=fCountImages;
        end;

 //     pvApplication.VulkanDevice.DebugMarker.BeginRegion(CommandBuffer,'VR_vkCmdPipeline_0_1',[1.0,1.0,1.0,1.0]);

        CommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                         0,
                                         0,
                                         nil,
                                         0,
                                         nil,
                                         1,
                                         @ImageMemoryBarriers[0]);

 //     pvApplication.VulkanDevice.DebugMarker.EndRegion(CommandBuffer);

       end;

       CommandBuffer.EndRecording;

      finally

       fVulkanCommandBuffers.Add(CommandBuffer);

      end;

     end;

    end;

   finally
    ImageMemoryBarriers:=nil;
   end;

  end;

 end;

end;

procedure TpvVirtualReality.BeforeDestroySwapChain;
var Index:TpvSizeInt;
begin

 case fMode of
  TMode.OpenVR,
  TMode.Faked:begin
  end;
  else {TMode.Disabled:}begin
  end;
 end;

 begin

  for Index:=0 to fCountInFlightFrames-1 do begin
   FreeAndNil(fVulkanDescriptorSets[Index]);
  end;

  FreeAndNil(fVulkanDescriptorSetLayout);

  FreeAndNil(fVulkanDescriptorPool);

  FreeAndNil(fVulkanRenderPass);

  FreeAndNil(fVulkanGraphicsPipeline);

  FreeAndNil(fVulkanPipelineLayout);

  fVulkanImageViews.Clear;

  fVulkanImages.Clear;

  fVulkanSingleImageViews.Clear;

  fVulkanSingleImages.Clear;

  for Index:=0 to fVulkanMemoryBlocks.Count-1 do begin
   pvApplication.VulkanDevice.MemoryManager.FreeMemoryBlock(fVulkanMemoryBlocks[Index]);
   fVulkanMemoryBlocks[Index]:=nil;
  end;

  fVulkanMemoryBlocks.Clear;

  fVulkanCommandBuffers.Clear;

  FreeAndNil(fVulkanUniversalQueueCommandPool);

 end;

end;

function TpvVirtualReality.GetProjectionMatrix(const aIndex:TpvSizeInt):TpvMatrix4x4;
var AspectRatio,WidthRatio,ZNearOverFocalLength,EyeOffset,Left,Right,Bottom,Top:TpvFloat;
 begin
 case fMode of
{$ifdef TargetWithOpenVRSupport}
  TMode.OpenVR:begin
   result:=fOpenVR_ProjectionMatrices[aIndex];
  end;
{$endif}
  TMode.Faked:begin
   AspectRatio:=(fWidth*0.5)/fHeight;
   WidthRatio:=abs(fZNear)*tan(DEG2RAD*FakedFOV*0.5);
   ZNearOverFocalLength:=abs(fZNear)/FocalLength;
   EyeOffset:=(EyeSeparation*0.5*ZNearOverFocalLength)*BooleanToSign[aIndex>0];
   Left:=((-WidthRatio)*AspectRatio)+EyeOffset;
   Right:=(WidthRatio*AspectRatio)+EyeOffset;
   Top:=WidthRatio;
   Bottom:=-WidthRatio;
   if fZFar>0.0 then begin
    result:=TpvMatrix4x4.CreateFrustumRightHandedZeroToOne(Left,
                                                           Right,
                                                           Bottom,
                                                           Top,
                                                           abs(fZNear),
                                                           IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
   end else begin
    result:=TpvMatrix4x4.CreateFrustumRightHandedOneToZero(Left,
                                                           Right,
                                                           Bottom,
                                                           Top,
                                                           abs(fZNear),
                                                           IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
   end;
   if fZFar<0.0 then begin
    if IsInfinite(fZFar) then begin
     // Convert to reversed infinite Z
     result.RawComponents[2,2]:=0.0;
     result.RawComponents[2,3]:=-1.0;
     result.RawComponents[3,2]:=abs(fZNear);
    end else begin
     // Convert to reversed non-infinite Z
     result.RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
     result.RawComponents[2,3]:=-1.0;
     result.RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
    end;
   end;
   result:=result*TpvMatrix4x4.FlipYClipSpace;
  end;
  else {TMode.Disabled:}begin
   if fZFar>0.0 then begin
    result:=TpvMatrix4x4.CreatePerspectiveRightHandedZeroToOne(fFOV,
                                                               fWidth/fHeight,
                                                               abs(fZNear),
                                                               IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
   end else begin
    result:=TpvMatrix4x4.CreatePerspectiveRightHandedOneToZero(fFOV,
                                                               fWidth/fHeight,
                                                               abs(fZNear),
                                                               IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
   end;
   if fZFar<0.0 then begin
    if IsInfinite(fZFar) then begin
     // Convert to reversed infinite Z
     result.RawComponents[2,2]:=0.0;
     result.RawComponents[2,3]:=-1.0;
     result.RawComponents[3,2]:=abs(fZNear);
    end else begin
     // Convert to reversed non-infinite Z
     result.RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
     result.RawComponents[2,3]:=-1.0;
     result.RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
    end;
   end;
   result:=result*TpvMatrix4x4.FlipYClipSpace;
  end;
 end;
 case fProjectionMatrixMode of
  TProjectionMatrixMode.ReversedZ:begin
   result.RawComponents[2,0]:=0.0;
   result.RawComponents[2,1]:=0.0;
   result.RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
   result.RawComponents[2,3]:=-1.0;
   result.RawComponents[3,0]:=0.0;
   result.RawComponents[3,1]:=0.0;
   result.RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
   result.RawComponents[3,3]:=0.0;
  end;
  TProjectionMatrixMode.InfiniteFarPlaneReversedZ:begin
   result.RawComponents[2,0]:=0.0;
   result.RawComponents[2,1]:=0.0;
   result.RawComponents[2,2]:=0.0;
   result.RawComponents[2,3]:=-1.0;
   result.RawComponents[3,0]:=0.0;
   result.RawComponents[3,1]:=0.0;
   result.RawComponents[3,2]:=abs(fZNear);
   result.RawComponents[3,3]:=0.0;
  end;
  else {TProjectionMatrixMode.Normal:}begin
  end;
 end;
end;

function TpvVirtualReality.GetPositionMatrix(const aIndex:TpvSizeInt):TpvMatrix4x4;
begin
 case fMode of
{$ifdef TargetWithOpenVRSupport}
  TMode.OpenVR:begin
   result:=fOpenVR_EyeToHeadTransformMatrices[aIndex]*(fOpenVR_BaseInverseHMDMatrix*fOpenVR_HMDMatrix);
  end;
{$endif}
  TMode.Faked:begin
   result:=TpvMatrix4x4.CreateTranslation(EyeSeparation*0.5*BooleanToSign[aIndex>0],0.0,0.0);
  end;
  else {TMode.Disabled:}begin
   result:=TpvMatrix4x4.Identity;
  end;
 end;
end;

procedure TpvVirtualReality.Check(const aDeltaTime:TpvDouble);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 const TrackingUniverseModes:array[TTrackingMode] of TpovrInt32=
        (
         TrackingUniverseSeated,
         TrackingUniverseStanding,
         TrackingUniverseOrigin_TrackingUniverseRawAndUncalibrated
        );
  procedure AddTrackedDevice(const aIndex:TpvSizeInt);
  var TrackedDevice:TTrackedDevice;
  begin
   if (aIndex>=0) and (aIndex<=High(fOpenVR_TrackedDevices)) then begin

    TrackedDevice:=TTrackedDevice.Create(self);
    fOpenVR_TrackedDevices[aIndex]:=TrackedDevice;
    fTrackedDevices.Add(TrackedDevice);
    fTrackedDeviceIDHashMap.Add(aIndex,TrackedDevice);

    TrackedDevice.fTrackedDeviceID:=aIndex;

    case fOpenVR_VR_IVRSystem_FnTable^.GetTrackedDeviceClass(aIndex) of
     TrackedDeviceClass_HMD:begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.HMD;
     end;
     TrackedDeviceClass_Controller:begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.Controller;
      case fOpenVR_VR_IVRSystem_FnTable^.GetControllerRoleForTrackedDeviceIndex(aIndex) of
       TrackedControllerRole_LeftHand:begin
        TrackedDevice.fTrackedControllerRole:=TTrackedControllerRole.LeftHand;
       end;
       TrackedControllerRole_RightHand:begin
        TrackedDevice.fTrackedControllerRole:=TTrackedControllerRole.RightHand;
       end;
       TrackedControllerRole_OptOut:begin
        TrackedDevice.fTrackedControllerRole:=TTrackedControllerRole.OptOut;
       end;
       else begin
        TrackedDevice.fTrackedControllerRole:=TTrackedControllerRole.Invalid;
       end;
      end;
     end;
     TrackedDeviceClass_GenericTracker:begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.GenericTracker;
     end;
     TrackedDeviceClass_TrackingReference:begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.TrackingReference;
     end;
     TrackedDeviceClass_DisplayRedirect:begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.DisplayRedirect;
     end;
     else begin
      TrackedDevice.fTrackedDeviceClass:=TTrackedDeviceClass.Invalid;
     end;
    end;

    TrackedDevice.fPoseIsValid:=false;

   end;

  end;
  procedure RemoveTrackedDevice(const aIndex:TpvSizeInt);
  var TrackedDevice:TTrackedDevice;
  begin
   if (aIndex>=0) and (aIndex<=High(fOpenVR_TrackedDevices)) then begin
    TrackedDevice:=fOpenVR_TrackedDevices[aIndex];
    if assigned(TrackedDevice) then begin
     fTrackedDeviceIDHashMap.Delete(aIndex);
     fTrackedDevices.Remove(TrackedDevice); // <= includes Free of the TrackedDevice object class instance
     fOpenVR_TrackedDevices[aIndex]:=nil;
    end;
   end;
  end;
 var Index:TpvSizeInt;
     OpenVRMatrix:TOpenVRMatrix;
     SecondsSinceLastVSync,
     DisplayFrequency,
     FrameDuration,
     VSyncToPhotons,
     PredictedSecondsFromNow:TpvFloat;
     Error:TETrackedPropertyError;
     TrackedDevice:TTrackedDevice;
     Event:PasVulkan.VirtualReality.OpenVR.TVREvent_t;
     VRControllerState:PasVulkan.VirtualReality.OpenVR.TVRControllerState_t;
     TrackedDevicePose:PasVulkan.VirtualReality.OpenVR.TTrackedDevicePose_t;
 begin

  while fOpenVR_VR_IVRSystem_FnTable^.PollNextEventWithPose(TrackingUniverseModes[fTrackingMode],
                                                            @Event,
                                                            SizeOf(PasVulkan.VirtualReality.OpenVR.TVREvent_t),
                                                            @TrackedDevicePose) do begin
   case Event.eventType of
    VREvent_TrackedDeviceActivated:begin
     AddTrackedDevice(Event.trackedDeviceIndex);
    end;
    VREvent_TrackedDeviceDeactivated:begin
     RemoveTrackedDevice(Event.trackedDeviceIndex);
    end;
    VREvent_TrackedDeviceUpdated:begin
     RemoveTrackedDevice(Event.trackedDeviceIndex);
     AddTrackedDevice(Event.trackedDeviceIndex);
    end;
   end;
  end;

  fOpenVR_VR_IVRSystem_FnTable^.GetTimeSinceLastVsync(@SecondsSinceLastVSync,nil);
  DisplayFrequency:=fOpenVR_VR_IVRSystem_FnTable^.GetFloatTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_DisplayFrequency_Float,@Error);
  if not IsZero(DisplayFrequency) then begin
   FrameDuration:=1.0/DisplayFrequency;
   VSyncToPhotons:=fOpenVR_VR_IVRSystem_FnTable^.GetFloatTrackedDeviceProperty(k_unTrackedDeviceIndex_Hmd,Prop_SecondsFromVSyncToPhotons_Float,@Error);
   PredictedSecondsFromNow:=(FrameDuration-SecondsSinceLastVsync)+VSyncToPhotons;
  end else begin
   PredictedSecondsFromNow:=0.0;
  end;

  FillChar(fOpenVR_TrackedDevicePoses[0],SizeOf(fOpenVR_TrackedDevicePoses),#0);

  fOpenVR_VR_IVRCompositor_FnTable^.WaitGetPoses(nil,0,nil,0);

  fOpenVR_VR_IVRSystem_FnTable^.GetDeviceToAbsoluteTrackingPose(TrackingUniverseModes[fTrackingMode],PredictedSecondsFromNow,@fOpenVR_TrackedDevicePoses,Length(fOpenVR_TrackedDevicePoses));

  for Index:=Low(fOpenVR_TrackedDevicePoses) to High(fOpenVR_TrackedDevicePoses) do begin

   if fOpenVR_TrackedDevicePoses[Index].bDeviceIsConnected then begin

    TrackedDevice:=fOpenVR_TrackedDevices[Index];

    if not assigned(TrackedDevice) then begin
     AddTrackedDevice(Index);
     TrackedDevice:=fOpenVR_TrackedDevices[Index];
    end;

    TrackedDevice.fPoseIsValid:=fOpenVR_TrackedDevicePoses[Index].bPoseIsValid;

    OpenVRMatrix.m34:=fOpenVR_TrackedDevicePoses[Index].mDeviceToAbsoluteTracking;
    OpenVRMatrix.m44.m[3,0]:=0.0;
    OpenVRMatrix.m44.m[3,1]:=0.0;
    OpenVRMatrix.m44.m[3,2]:=0.0;
    OpenVRMatrix.m44.m[3,3]:=1.0;
    OpenVRMatrix.Matrix:=OpenVRMatrix.Matrix.Transpose;

    TrackedDevice.fMatrix:=OpenVRMatrix.Matrix;

    TrackedDevice.fVelocity:=PpvVector3(pointer(@fOpenVR_TrackedDevicePoses[Index].vVelocity.v[0]))^;

    TrackedDevice.fAngularVelocity:=PpvVector3(pointer(@fOpenVR_TrackedDevicePoses[Index].vAngularVelocity.v[0]))^;

    if fOpenVR_TrackedDevicePoses[Index].bPoseIsValid then begin
     case fOpenVR_VR_IVRSystem_FnTable^.GetTrackedDeviceClass(Index) of
      TrackedDeviceClass_HMD:begin
       fOpenVR_HMDMatrixOriginal:=OpenVRMatrix.Matrix;
       fOpenVR_HMDMatrix:=fOpenVR_HMDMatrixOriginal.Inverse;
      end;
     end;
    end;

    if fOpenVR_VR_IVRSystem_FnTable^.GetControllerState(Index,
                                                        @VRControllerState,
                                                        SizeOf(PasVulkan.VirtualReality.OpenVR.TVRControllerState_t)) then begin
     TrackedDevice.fButtonPressed:=VRControllerState.ulButtonPressed;
     TrackedDevice.fButtonTouched:=VRControllerState.ulButtonTouched;
     TrackedDevice.fAxes[0]:=PpvVector2(pointer(@VRControllerState.rAxis[0]))^;
     TrackedDevice.fAxes[1]:=PpvVector2(pointer(@VRControllerState.rAxis[1]))^;
     TrackedDevice.fAxes[2]:=PpvVector2(pointer(@VRControllerState.rAxis[2]))^;
     TrackedDevice.fAxes[3]:=PpvVector2(pointer(@VRControllerState.rAxis[3]))^;
     TrackedDevice.fAxes[4]:=PpvVector2(pointer(@VRControllerState.rAxis[4]))^;
    end;

   end else begin

    TrackedDevice:=fOpenVR_TrackedDevices[Index];

    if assigned(TrackedDevice) then begin
     RemoveTrackedDevice(Index);
    end;

   end;

  end;

 end;
{$endif}
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
end;

procedure TpvVirtualReality.Update(const aDeltaTime:TpvDouble);
begin
end;

procedure TpvVirtualReality.BeginFrame(const aDeltaTime:TpvDouble);
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   fOpenVR_VR_IVRCompositor_FnTable^.SubmitExplicitTimingData;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
end;

procedure TpvVirtualReality.Draw(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
 fVulkanCommandBuffers[(aInFlightFrameIndex*fCountSwapChainImages)+aSwapChainImageIndex].Execute(pvApplication.VulkanDevice.UniversalQueue,
                                                                                                 TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                                                                                 aWaitSemaphore,
                                                                                                 fVulkanSemaphores[aInFlightFrameIndex],
                                                                                                 aWaitFence,
                                                                                                 false);
 aWaitSemaphore:=fVulkanSemaphores[aInFlightFrameIndex];
end;

procedure TpvVirtualReality.FinishFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 var Index:TpvSizeInt;
     VulkanTextureData:PasVulkan.VirtualReality.OpenVR.TVRVulkanTextureData_t;
     VulkanTexture:PasVulkan.VirtualReality.OpenVR.TTexture_t;
     VulkanTextureBounds:PasVulkan.VirtualReality.OpenVR.TVRTextureBounds_t;
     CompositorError:TEVRCompositorError;
 begin

  VulkanTextureData.m_pDevice:=pvApplication.VulkanDevice.Handle;
  VulkanTextureData.m_pPhysicalDevice:=pvApplication.VulkanDevice.PhysicalDevice.Handle;
  VulkanTextureData.m_pInstance:=pvApplication.VulkanInstance.Handle;
  VulkanTextureData.m_pQueue:=pvApplication.VulkanDevice.UniversalQueue.Handle;
  VulkanTextureData.m_nQueueFamilyIndex:=pvApplication.VulkanDevice.UniversalQueueFamilyIndex;
  VulkanTextureData.m_nWidth:=fWidth;
  VulkanTextureData.m_nHeight:=fHeight;
  VulkanTextureData.m_nFormat:=TpovrUInt32(fImageFormat);
  VulkanTextureData.m_nSampleCount:=TpovrUInt32(VK_SAMPLE_COUNT_1_BIT);

  VulkanTexture.eType:=TextureType_Vulkan;
  VulkanTexture.eColorSpace:=ColorSpace_Auto;
  VulkanTexture.handle:=@VulkanTextureData;

  VulkanTextureBounds.uMin:=0.0;
  VulkanTextureBounds.uMax:=1.0;
  VulkanTextureBounds.vMin:=0.0;
  VulkanTextureBounds.vMax:=1.0;

  for Index:=0 to 1 do begin
   VulkanTextureData.m_nImage:=fVulkanSingleImages[(aInFlightFrameIndex*fCountImages)+Index].Handle;
   CompositorError:=fOpenVR_VR_IVRCompositor_FnTable^.Submit(OpenVREyes[Index],@VulkanTexture,@VulkanTextureBounds,Submit_Default);
   if CompositorError<>VRCompositorError_None then begin

   end;
  end;

 end;
{$endif}
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
end;

procedure TpvVirtualReality.PostPresent(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32);
{$ifdef TargetWithOpenVRSupport}
 procedure DoOpenVR;
 begin
  fOpenVR_VR_IVRCompositor_FnTable^.PostPresentHandoff;
  pvApplication.VulkanDevice.UniversalQueue.WaitIdle;
 end;
{$endif}
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   DoOpenVR;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
end;

procedure TpvVirtualReality.ResetOrientation;
begin
 case fMode of
  TpvVirtualReality.TMode.OpenVR:begin
{$ifdef TargetWithOpenVRSupport}
   if fTrackingMode=TTrackingMode.Seated then begin
    fOpenVR_VR_IVRSystem_FnTable^.ResetSeatedZeroPose;
   end else begin
    fOpenVR_BaseInverseHMDMatrix:=fOpenVR_HMDMatrixOriginal;
   end;
{$endif}
  end;
  TpvVirtualReality.TMode.Faked:begin
  end;
  else {TVirtualReality.TMode.Disabled:}begin
  end;
 end;
end;

end.
