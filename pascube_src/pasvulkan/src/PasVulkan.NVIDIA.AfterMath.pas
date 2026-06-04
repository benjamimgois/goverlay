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
unit PasVulkan.NVIDIA.AfterMath;
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

uses {$if defined(Windows)}
      Windows,
     {$elseif defined(Unix)}
      BaseUnix,UnixType,dl,
     {$ifend}
     Math,
     SysUtils,
     Classes,
     PasMP,
     PasVulkan.Types;

const GFSDK_Aftermath_Version_API=$0000217;  // Version 2.23

      // Default setting
      GFSDK_Aftermath_GpuCrashDumpWatchedApiFlags_None=$0;

      // Enable GPU crash dump tracking for the DX API
      GFSDK_Aftermath_GpuCrashDumpWatchedApiFlags_DX=$1;

      // Enable GPU crash dump tracking for the Vulkan API
      GFSDK_Aftermath_GpuCrashDumpWatchedApiFlags_Vulkan=$2;

      // Default settings
      GFSDK_Aftermath_GpuCrashDumpFeatureFlags_Default=$0;

      // Defer shader debug information callbacks until an actual GPU crash
      // dump is generated and also provide shader debug information
      // for the shaders related to the crash dump only.
      // Note: using this option will increase the memory footprint of the
      // application.
      GFSDK_Aftermath_GpuCrashDumpFeatureFlags_DeferDebugInfoCallbacks=$1;

      // Predefined key for application name
      GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationName=$1;

      // Predefined key for application version
      GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationVersion=$2;

      // Base key for creating user-defined key-value pairs.
      // Any value >= GFSDK_Aftermath_GpuCrashDumpDescriptionKey_UserDefined
      // will create a user-defined key-value pair.
      GFSDK_Aftermath_GpuCrashDumpDescriptionKey_UserDefined=$10000;

      // No GPU crash has been detected by Aftermath, so far.
      GFSDK_Aftermath_CrashDump_Status_NotStarted=0;

      // A GPU crash happened, Aftermath started to collect crash dump data.
      GFSDK_Aftermath_CrashDump_Status_CollectingData=1;

      // Aftermath failed to collect crash dump data. No further callback will be invoked.
      GFSDK_Aftermath_CrashDump_Status_CollectingDataFailed=2;

      // Aftermath is invoking the gpuCrashDumpCb callback after collecting the crash dump data successfully.
      GFSDK_Aftermath_CrashDump_Status_InvokingCallback=3;

      // gpuCrashDumpCb callback returned and Aftermath finished processing the GPU crash.
      GFSDK_Aftermath_CrashDump_Status_Finished=4;

      // Unknown problem - likely using an older driver
      //  incompatible with this Aftermath feature.
      GFSDK_Aftermath_CrashDump_Status_Unknown=5;

      GFSDK_Aftermath_Result_Success=$1;

      GFSDK_Aftermath_Result_NotAvailable=$2;

      GFSDK_Aftermath_Result_Fail=$BAD00000;

      // The callee tries to use a library version
      //  which does not match the built binary.
      GFSDK_Aftermath_Result_FAIL_VersionMismatch=GFSDK_Aftermath_Result_Fail or 1;

      // The library hasn't been initialized, see;
      //  'GFSDK_Aftermath_Initialize'.
      GFSDK_Aftermath_Result_FAIL_NotInitialized=GFSDK_Aftermath_Result_Fail or 2;

      // The callee tries to use the library with
      //  a non-supported GPU. Currently, only
      //  NVIDIA GPUs are supported.
      GFSDK_Aftermath_Result_FAIL_InvalidAdapter=GFSDK_Aftermath_Result_Fail or 3;

      // The callee passed an invalid parameter to the
      //  library, likely a null pointer or bad handle.
      GFSDK_Aftermath_Result_FAIL_InvalidParameter=GFSDK_Aftermath_Result_Fail or 4;

      // Something weird happened that caused the
      //  library to fail for some reason.
      GFSDK_Aftermath_Result_FAIL_Unknown=GFSDK_Aftermath_Result_Fail or 5;

      // Got a fail error code from the graphics API.
      GFSDK_Aftermath_Result_FAIL_ApiError=GFSDK_Aftermath_Result_Fail or 6;

      // Make sure that the NvAPI DLL is up to date.
      GFSDK_Aftermath_Result_FAIL_NvApiIncompatible=GFSDK_Aftermath_Result_Fail or 7;

      // It would appear as though a call has been
      //  made to fetch the Aftermath data for a
      //  context that hasn't been used with
      //  the EventMarker API yet.
      GFSDK_Aftermath_Result_FAIL_GettingContextDataWithNewCommandList=GFSDK_Aftermath_Result_Fail or 8;

      // Looks like the library has already been initialized.
      GFSDK_Aftermath_Result_FAIL_AlreadyInitialized=GFSDK_Aftermath_Result_Fail or 9;

      // Debug layer not compatible with Aftermath.
      GFSDK_Aftermath_Result_FAIL_D3DDebugLayerNotCompatible=GFSDK_Aftermath_Result_Fail or 10;

      // Aftermath failed to initialize in the driver.
      GFSDK_Aftermath_Result_FAIL_DriverInitFailed=GFSDK_Aftermath_Result_Fail or 11;

      // Aftermath v2.x requires driver version 387.xx and beyond
      GFSDK_Aftermath_Result_FAIL_DriverVersionNotSupported=GFSDK_Aftermath_Result_Fail or 12;

      // The system ran out of memory for allocations
      GFSDK_Aftermath_Result_FAIL_OutOfMemory=GFSDK_Aftermath_Result_Fail or 13;

      // No need to get data on bundles, as markers
      //  execute on the command list.
      GFSDK_Aftermath_Result_FAIL_GetDataOnBundle=GFSDK_Aftermath_Result_Fail or 14;

      // No need to get data on deferred contexts, as markers
      //  execute on the immediate context.
      GFSDK_Aftermath_Result_FAIL_GetDataOnDeferredContext=GFSDK_Aftermath_Result_Fail or 15;

      // This feature hasn't been enabled at initialization - see GFSDK_Aftermath_FeatureFlags.
      GFSDK_Aftermath_Result_FAIL_FeatureNotEnabled=GFSDK_Aftermath_Result_Fail or 16;

      // No resources have ever been registered.
      GFSDK_Aftermath_Result_FAIL_NoResourcesRegistered=GFSDK_Aftermath_Result_Fail or 17;

      // This resource has never been registered.
      GFSDK_Aftermath_Result_FAIL_ThisResourceNeverRegistered=GFSDK_Aftermath_Result_Fail or 18;

      // The functionality is not supported for UWP applications
      GFSDK_Aftermath_Result_FAIL_NotSupportedInUWP=GFSDK_Aftermath_Result_Fail or 19;

      // D3D DLL not compatible with Aftermath.
      GFSDK_Aftermath_Result_FAIL_D3dDllNotSupported=GFSDK_Aftermath_Result_Fail or 20;

      // D3D DLL interception is not compatible with Aftermath.
      GFSDK_Aftermath_Result_FAIL_D3dDllInterceptionNotSupported=GFSDK_Aftermath_Result_Fail or 21;

      // Aftermath is disabled on the system by the current user.
      //  On Windows, this is controlled by a Windows registry key:
      //    KeyPath   : HKEY_CURRENT_USER\Software\NVIDIA Corporation\Nsight Aftermath
      //    KeyValue  : ForceOff
      //    ValueType : REG_DWORD
      //    ValueData : Any value != 0 will force the functionality of the Aftermath
      //                SDK off on the system.
      //
      //  On Linux, this is controlled by an environment variable:
      //    Name: NV_AFTERMATH_FORCE_OFF
      //    Value: Any value != '0' will force the functionality of the Aftermath
      //                SDK off.
      //
      GFSDK_Aftermath_Result_FAIL_Disabled=GFSDK_Aftermath_Result_Fail or 22;

      // Markers cannot be set on queue or device contexts.
      GFSDK_Aftermath_Result_FAIL_NotSupportedOnContext=GFSDK_Aftermath_Result_Fail or 23;

      GFSDK_Aftermath_Context_Status_NotStarted=0;

      // This command list has begun execution on the GPU.
      GFSDK_Aftermath_Context_Status_Executing=1;

      // This command list has finished execution on the GPU.
      GFSDK_Aftermath_Context_Status_Finished=2;

      // This context has an invalid state, which could be caused by an error.
      GFSDK_Aftermath_Context_Status_Invalid=3;

      // The GPU is still active, and hasn't gone down.
      GFSDK_Aftermath_Device_Status_Active=0;

      // A long running shader/operation has caused a
      //  GPU timeout. Reconfiguring the timeout length
      //  might help tease out the problem.
      GFSDK_Aftermath_Device_Status_Timeout=1;

      // Run out of memory to complete operations.
      GFSDK_Aftermath_Device_Status_OutOfMemory=2;

      // An invalid VA access has caused a fault.
      GFSDK_Aftermath_Device_Status_PageFault=3;

      // The GPU has stopped executing
      GFSDK_Aftermath_Device_Status_Stopped=4;

      // The device has been reset
      GFSDK_Aftermath_Device_Status_Reset=5;

      // Unknown problem - likely using an older driver incompatible with this Aftermath feature.
      GFSDK_Aftermath_Device_Status_Unknown=6;

      // An invalid rendering call has percolated through the driver
      GFSDK_Aftermath_Device_Status_DmaFault=7;

      // The device was removed but no GPU fault was detected
      GFSDK_Aftermath_Device_Status_DeviceRemovedNoGpuFault=8;

      GFSDK_Aftermath_MAX_STRING_LENGTH=127;

      GFSDK_Aftermath_GraphicsApi_Unknown=0;
      GFSDK_Aftermath_GraphicsApi_D3D_10_0=1;
      GFSDK_Aftermath_GraphicsApi_D3D_10_1=2;
      GFSDK_Aftermath_GraphicsApi_D3D_11_0=3;
      GFSDK_Aftermath_GraphicsApi_D3D_11_1=4;
      GFSDK_Aftermath_GraphicsApi_D3D_11_2=5;
      GFSDK_Aftermath_GraphicsApi_D3D_12_0=6;
      GFSDK_Aftermath_GraphicsApi_Vulkan=7;

      GFSDK_Aftermath_ShaderType_Unknown=0;
      GFSDK_Aftermath_ShaderType_Vertex=1;
      GFSDK_Aftermath_ShaderType_Tessellation_Control=2;
      GFSDK_Aftermath_ShaderType_Hull=GFSDK_Aftermath_ShaderType_Tessellation_Control;
      GFSDK_Aftermath_ShaderType_Tessellation_Evaluation=3;
      GFSDK_Aftermath_ShaderType_Domain=GFSDK_Aftermath_ShaderType_Tessellation_Evaluation;
      GFSDK_Aftermath_ShaderType_Geometry=4;
      GFSDK_Aftermath_ShaderType_Fragment=5;
      GFSDK_Aftermath_ShaderType_Pixel=GFSDK_Aftermath_ShaderType_Fragment;
      GFSDK_Aftermath_ShaderType_Compute=6;
      GFSDK_Aftermath_ShaderType_RayTracing_RayGeneration=7;
      GFSDK_Aftermath_ShaderType_RayTracing_Miss=8;
      GFSDK_Aftermath_ShaderType_RayTracing_Intersection=9;
      GFSDK_Aftermath_ShaderType_RayTracing_AnyHit=10;
      GFSDK_Aftermath_ShaderType_RayTracing_ClosestHit=11;
      GFSDK_Aftermath_ShaderType_RayTracing_Callable=12;
      GFSDK_Aftermath_ShaderType_RayTracing_Internal=13;
      GFSDK_Aftermath_ShaderType_Mesh=14;
      GFSDK_Aftermath_ShaderType_Task=15;

      GFSDK_Aftermath_Context_Type_Invalid=0;
      GFSDK_Aftermath_Context_Type_Immediate=1;
      GFSDK_Aftermath_Context_Type_CommandList=2;
      GFSDK_Aftermath_Context_Type_Bundle=3;
      GFSDK_Aftermath_Context_Type_CommandQueue=4;

      GFSDK_Aftermath_EventMarkerDataOwnership_User=0;
      GFSDK_Aftermath_EventMarkerDataOwnership_Decoder=1;

      // Include basic information about the GPU crash dump.
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_BASE_INFO=$1;

      // Include information about the device state
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_DEVICE_INFO=$2;

      // Include information about the OS
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_OS_INFO=$4;

      // Include information about the display driver
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_DISPLAY_DRIVER_INFO=$8;

      // Include information about the GPU
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_GPU_INFO=$10;

      // Include information about page faults (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_PAGE_FAULT_INFO=$20;

      // Include information about shaders (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_SHADER_INFO=$40;

      // Include information about active warps (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_WARP_STATE_INFO=$80;

      // Try to map shader addresses to source or intermediate assembly lines
      // using additional information provided through shaderDebugInfoLookupCb
      // and shaderLookupCb, if provided.
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_SHADER_MAPPING_INFO=$100;

      // Include Aftermath event marker data (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_EVENT_MARKER_INFO=$200;

      // Include automatic event marker call stack data (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_CALL_STACK_INFO=$400;

      // Include user provided GPU crash dump description values (if available)
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_DESCRIPTION_INFO=$800;

      // Include information about faulted warps (if available).
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_FAULTED_WARP_INFO=$1000;

      // Include information about the fingerprint of the GPU crash dump (if available).
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_FINGERPRINT_INFO=$2000;

      // Include all available information.
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_ALL_INFO=$3fff;

      // No special formatting
      GFSDK_Aftermath_GpuCrashDumpFormatterFlags_NONE=$0;

      // Remove all unnecessary whitespace from formatted string
      GFSDK_Aftermath_GpuCrashDumpFormatterFlags_CONDENSED_OUTPUT=$1;

      // Use UTF8 encoding
      GFSDK_Aftermath_GpuCrashDumpFormatterFlags_UTF8_OUTPUT=$2;

      GFSDK_Aftermath_FaultType_Unknown=0;
      GFSDK_Aftermath_FaultType_AddressTranslationError=1;
      GFSDK_Aftermath_FaultType_IllegalAccessError=2;

      GFSDK_Aftermath_AccessType_Unknown=0;
      GFSDK_Aftermath_AccessType_Read=1;
      GFSDK_Aftermath_AccessType_Write=2;
      GFSDK_Aftermath_AccessType_Atomic=3;

      GFSDK_Aftermath_Engine_Unknown=0;
      GFSDK_Aftermath_Engine_Graphics=1;
      GFSDK_Aftermath_Engine_GraphicsCompute=2;
      GFSDK_Aftermath_Engine_Display=3;
      GFSDK_Aftermath_Engine_CopyEngine=4;
      GFSDK_Aftermath_Engine_VideoDecoder=5;
      GFSDK_Aftermath_Engine_VideoEncoder=6;
      GFSDK_Aftermath_Engine_Other=7;

      GFSDK_Aftermath_Client_Unknown=0;
      GFSDK_Aftermath_Client_HostInterface=1;
      GFSDK_Aftermath_Client_FrontEnd=2;
      GFSDK_Aftermath_Client_PrimitiveDistributor=3;
      GFSDK_Aftermath_Client_GraphicsProcessingCluster=4;
      GFSDK_Aftermath_Client_PolymorphEngine=5;
      GFSDK_Aftermath_Client_RasterEngine=6;
      GFSDK_Aftermath_Client_Rasterizer2D=7;
      GFSDK_Aftermath_Client_RenderOutputUnit=8;
      GFSDK_Aftermath_Client_TextureProcessingCluster=9;
      GFSDK_Aftermath_Client_CopyEngine=10;
      GFSDK_Aftermath_Client_VideoDecoder=11;
      GFSDK_Aftermath_Client_VideoEncoder=12;
      GFSDK_Aftermath_Client_Other=13;

type EGFSDK_Aftermath=class(Exception);

     TGFSDK_Aftermath_Version=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDumpWatchedApiFlags=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDumpFeatureFlags=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDumpDescriptionKey=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDump_Status=TpvUInt32;

     TGFSDK_Aftermath_CrashDump_Status=TpvUInt32;

     PGFSDK_Aftermath_CrashDump_Status=^TGFSDK_Aftermath_CrashDump_Status;

     TGFSDK_Aftermath_Result=TpvUInt32;

     TGFSDK_Aftermath_Context_Status=TpvUInt32;

     TGFSDK_Aftermath_Device_Status=TpvUInt32;

     TGFSDK_Aftermath_GraphicsApi=TpvUInt32;

     TGFSDK_Aftermath_ShaderDebugInfoIdentifier=record
      ID:array[0..1] of TpvUInt64;
     end;

     PGFSDK_Aftermath_ShaderDebugInfoIdentifier=^TGFSDK_Aftermath_ShaderDebugInfoIdentifier;

     TGFSDK_Aftermath_ShaderBinaryHash=record
      Hash:TpvUInt64;
     end;

     PGFSDK_Aftermath_ShaderBinaryHash=^TGFSDK_Aftermath_ShaderBinaryHash;

     TGFSDK_Aftermath_ShaderInstructionsHash=record
      Hash:UInt64;
     end;

     PGFSDK_Aftermath_ShaderInstructionsHash=^TGFSDK_Aftermath_ShaderInstructionsHash;

     TGFSDK_Aftermath_ShaderDebugName=record
      Name:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
     end;

     PGFSDK_Aftermath_ShaderDebugName=^TGFSDK_Aftermath_ShaderDebugName;

     TGFSDK_Aftermath_Pointer=record
      case boolean of
       false:(
        UI64:UInt64;
       );
       true:(
        Ptr:Pointer;
       );
     end;

     PGFSDK_Aftermath_Pointer=^TGFSDK_Aftermath_Pointer;

     TGFSDK_Aftermath_SpirvCode=record
      pData:TGFSDK_Aftermath_Pointer;
      Size:TpvUInt32;
     end;

     PGFSDK_Aftermath_SpirvCode=^TGFSDK_Aftermath_SpirvCode;

     TGFSDK_Aftermath_GpuCrashDump_BaseInfo=record
      ApplicationName:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      CreationDate:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      creationTickCount:TpvUInt32;
      PID:TpvUInt32;
      GraphicsApi:TGFSDK_Aftermath_GraphicsApi;
     end;

     PGFSDK_Aftermath_GpuCrashDump_BaseInfo=^TGFSDK_Aftermath_GpuCrashDump_BaseInfo;

     TGFSDK_Aftermath_GpuCrashDump_DeviceInfo=record
      status:TGFSDK_Aftermath_Device_Status;
      adapterReset:TpvUInt32;
      engineReset:TpvUInt32;
     end;

     PGFSDK_Aftermath_GpuCrashDump_DeviceInfo=^TGFSDK_Aftermath_GpuCrashDump_DeviceInfo;

     TGFSDK_Aftermath_GpuCrashDump_SystemInfo=record
      osVersion:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      displayDriver:record
       major:TpvUInt32;
       minor:TpvUInt32;
      end;
     end;

     PGFSDK_Aftermath_GpuCrashDump_SystemInfo=^TGFSDK_Aftermath_GpuCrashDump_SystemInfo;

     TGFSDK_Aftermath_GpuCrashDump_GpuInfo=record
      adapterName:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      generationName:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      adapterLUID:TpvUInt64;
     end;

     PGFSDK_Aftermath_GpuCrashDump_GpuInfo=^TGFSDK_Aftermath_GpuCrashDump_GpuInfo;

     TGFSDK_Aftermath_Engine=TpvUInt32;

     TGFSDK_Aftermath_Client=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDump_PageFaultInfo=record
      engine:TGFSDK_Aftermath_Engine;
      client:TGFSDK_Aftermath_Client;
      resourceInfoCount:TpvUInt32;
     end;

     PGFSDK_Aftermath_GpuCrashDump_PageFaultInfo=^TGFSDK_Aftermath_GpuCrashDump_PageFaultInfo;

     TGFSDK_Aftermath_GpuCrashDump_ResourceInfo=record
      gpuVa:TpvUInt64;
      size:TpvUInt64;
      width:TpvUInt32;
      height:TpvUInt32;
      depth:TpvUInt32;
      mipLevels:TpvUInt32;
      format:TpvUInt32; // DXGI_Format for DX, VkFormat for Vulkan
      apiResource:TpvUInt64;
      debugName:array[0..GFSDK_Aftermath_MAX_STRING_LENGTH] of AnsiChar;
      bIsBufferHeap:TpvUInt32;
      bIsStaticTextureHeap:TpvUInt32;
      bIsRenderTargetOrDepthStencilViewHeap:TpvUInt32;
      bPlacedResource:TpvUInt32;
      bWasDestroyed:TpvUInt32;
      createDestroyTickCount:TpvUInt32;
     end;

     PGFSDK_Aftermath_GpuCrashDump_ResourceInfo=^TGFSDK_Aftermath_GpuCrashDump_ResourceInfo;

     TGFSDK_Aftermath_ShaderType=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDump_ShaderInfo=record
      shaderHash:TpvUInt64;
      shaderInstance:TpvUInt64;
      bIsInternal:TpvUInt32;
      shaderType:TGFSDK_Aftermath_ShaderType;
     end;

     PGFSDK_Aftermath_GpuCrashDump_ShaderInfo=^TGFSDK_Aftermath_GpuCrashDump_ShaderInfo;

     TGFSDK_Aftermath_Context_Type=TpvUInt32;

     TGFSDK_Aftermath_EventMarkerDataOwnership=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDump_EventMarkerInfo=record
      contextId:TpvUInt64;
      contextStatus:TGFSDK_Aftermath_Context_Status;
      contextType:TGFSDK_Aftermath_Context_Type;
      markerData:TGFSDK_Aftermath_Pointer;
      markerDataOwnership:TGFSDK_Aftermath_EventMarkerDataOwnership;
      markerDataSize:TpvUInt32;
     end;

     PGFSDK_Aftermath_GpuCrashDump_EventMarkerInfo=^TGFSDK_Aftermath_GpuCrashDump_EventMarkerInfo;

     TGFSDK_Aftermath_GpuCrashDumpDecoderFlags=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDumpFormatterFlags=TpvUInt32;

     TGFSDK_Aftermath_GpuCrashDump_Decoder__=record
      ID:TpvUInt32;
     end;

     TGFSDK_Aftermath_GpuCrashDump_Decoder=^TGFSDK_Aftermath_GpuCrashDump_Decoder__;

     PGFSDK_Aftermath_GpuCrashDump_Decoder=^TGFSDK_Aftermath_GpuCrashDump_Decoder;

     TPFN_GFSDK_Aftermath_AddGpuCrashDumpDescription=procedure(Key:TpvUInt32;Value:PAnsiChar); cdecl;

     TPFN_GFSDK_Aftermath_GpuCrashDumpCb=procedure(pGpuCrashDump:Pointer;gpuCrashDumpSize:TpvUInt32;pUserData:Pointer); cdecl;

     TPFN_GFSDK_Aftermath_ShaderDebugInfoCb=procedure(pShaderDebugInfo:Pointer;shaderDebugInfoSize:TpvUInt32;pUserData:Pointer); cdecl;

     TPFN_GFSDK_Aftermath_GpuCrashDumpDescriptionCb=procedure(addValue:TPFN_GFSDK_Aftermath_AddGpuCrashDumpDescription;pUserData:Pointer); cdecl;

     TPFN_GFSDK_Aftermath_ResolveMarkerCb=procedure(pMarkerData:Pointer;markerDataSize:PpvUInt32;pUserData:Pointer;resolvedMarkerData:PPpvPointer;pResolvedMarkerDataSize:PpvPointer); cdecl;

     TGFSDK_Aftermath_EnableGpuCrashDumps=function(apiVersion:TGFSDK_Aftermath_Version;
                                                   watchedApis:TpvUInt32;
                                                   flags:TpvUInt32;
                                                   gpuCrashDumpCb:TPFN_GFSDK_Aftermath_GpuCrashDumpCb;
                                                   shaderDebugInfoCb:TPFN_GFSDK_Aftermath_ShaderDebugInfoCb;
                                                   descriptionCb:TPFN_GFSDK_Aftermath_GpuCrashDumpDescriptionCb;
                                                   resolveMarkerCb:TPFN_GFSDK_Aftermath_ResolveMarkerCb;
                                                   pUserData:pointer):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_DisableGpuCrashDumps=function:TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_CrashDump_Status_Func=function(Status:TGFSDK_Aftermath_CrashDump_Status):TGFSDK_Aftermath_Result; cdecl;

     TPFN_GFSDK_Aftermath_SetData=procedure(pData:Pointer;Size:TpvInt32); cdecl;

     TPFN_GFSDK_Aftermath_ShaderDebugInfoLookupCb=procedure(pIdentifier:PGFSDK_Aftermath_ShaderDebugInfoIdentifier;setShaderDebugInfo:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;

     TPFN_GFSDK_Aftermath_ShaderLookupCb=procedure(pShaderBinaryHash:PGFSDK_Aftermath_ShaderBinaryHash;setShaderBinary:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;

     TPFN_GFSDK_Aftermath_ShaderSourceDebugInfoLookupCb=procedure(pShaderDebugName:PGFSDK_Aftermath_ShaderDebugName;setShaderBinary:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;

     TGFSDK_Aftermath_GpuCrashDump_CreateDecoder=function(apiVersion:TGFSDK_Aftermath_Version;
                                                          pGpuCrashDump:Pointer;
                                                          gpuCrashDumpSize:TpvUInt32;
                                                          pDecoder:PGFSDK_Aftermath_GpuCrashDump_Decoder):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_DestroyDecoder=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetBaseInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pBaseInfo:PGFSDK_Aftermath_GpuCrashDump_BaseInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetDescriptionSize=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;key:TpvUInt32;pValueSize:PpvUInt32):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetDescription=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;key:TpvUInt32;valueBufferSize:TpvUInt32;pValue:Pointer):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetDeviceInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pDeviceInfo:PGFSDK_Aftermath_GpuCrashDump_DeviceInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetSystemInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pSystemInfo:PGFSDK_Aftermath_GpuCrashDump_SystemInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetGpuInfoCount=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pGpuCount:PpvUInt32):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetGpuInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;gpuInfoBufferCount:TpvUInt32;pGpuInfo:PGFSDK_Aftermath_GpuCrashDump_GpuInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetPageFaultInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pPageFaultInfo:PGFSDK_Aftermath_GpuCrashDump_PageFaultInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetPageFaultResourceInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;resourceInfoCount:TpvUInt32;pResourceInfo:PGFSDK_Aftermath_GpuCrashDump_ResourceInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfoCount=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pShaderCount:PpvUInt32):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;shaderInfoBufferCount:TpvUInt32;pShaderInfo:PGFSDK_Aftermath_GpuCrashDump_ShaderInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfoCount=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;markerInfoBufferCount:PpvUInt32):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;markerInfoBufferCount:TpvUInt32;pMarkerInfo:PGFSDK_Aftermath_GpuCrashDump_EventMarkerInfo):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GenerateJSON=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;decoderFlags:TpvUInt32;formatFlags:TpvUInt32;shaderDebugInfoLookupCb:TPFN_GFSDK_Aftermath_ShaderDebugInfoLookupCb;shaderLookupCb:TPFN_GFSDK_Aftermath_ShaderLookupCb;shaderSourceDebugInfoLookupCb:TPFN_GFSDK_Aftermath_ShaderSourceDebugInfoLookupCb;pUserData:Pointer;pJsonSize:PpvUInt32):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GpuCrashDump_GetJSON=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;jsonBufferSize:TpvUInt32;pJson:PAnsiChar):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GetShaderDebugInfoIdentifier=function(apiVersion:TGFSDK_Aftermath_Version;pShaderDebugInfo:Pointer;shaderDebugInfoSize:TpvUInt32;pIdentifier:PGFSDK_Aftermath_ShaderDebugInfoIdentifier):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GetShaderHashSpirv=function(apiVersion:TGFSDK_Aftermath_Version;pShader:PGFSDK_Aftermath_SpirvCode;pShaderBinaryHash:PGFSDK_Aftermath_ShaderBinaryHash):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GetShaderDebugNameSpirv=function(apiVersion:TGFSDK_Aftermath_Version;pShader:PGFSDK_Aftermath_SpirvCode;pStrippedShader:PGFSDK_Aftermath_SpirvCode;pShaderDebugName:PGFSDK_Aftermath_ShaderDebugName):TGFSDK_Aftermath_Result; cdecl;

     TGFSDK_Aftermath_GetShaderHashForShaderInfo=function(Decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;pShaderInfo:PGFSDK_Aftermath_GpuCrashDump_ShaderInfo;pShaderHash:PGFSDK_Aftermath_ShaderBinaryHash):TGFSDK_Aftermath_Result; cdecl;

var GFSDK_Aftermath_EnableGpuCrashDumps:TGFSDK_Aftermath_EnableGpuCrashDumps=nil;

    GFSDK_Aftermath_DisableGpuCrashDumps:TGFSDK_Aftermath_DisableGpuCrashDumps=nil;

    GFSDK_Aftermath_CrashDump_Status:TGFSDK_Aftermath_CrashDump_Status_Func=nil;

    GFSDK_Aftermath_GpuCrashDump_CreateDecoder:TGFSDK_Aftermath_GpuCrashDump_CreateDecoder=nil;

    GFSDK_Aftermath_GpuCrashDump_DestroyDecoder:TGFSDK_Aftermath_GpuCrashDump_DestroyDecoder=nil;

    GFSDK_Aftermath_GpuCrashDump_GetBaseInfo:TGFSDK_Aftermath_GpuCrashDump_GetBaseInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetDescriptionSize:TGFSDK_Aftermath_GpuCrashDump_GetDescriptionSize=nil;

    GFSDK_Aftermath_GpuCrashDump_GetDescription:TGFSDK_Aftermath_GpuCrashDump_GetDescription=nil;

    GFSDK_Aftermath_GpuCrashDump_GetDeviceInfo:TGFSDK_Aftermath_GpuCrashDump_GetDeviceInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetSystemInfo:TGFSDK_Aftermath_GpuCrashDump_GetSystemInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetGpuInfoCount:TGFSDK_Aftermath_GpuCrashDump_GetGpuInfoCount=nil;

    GFSDK_Aftermath_GpuCrashDump_GetGpuInfo:TGFSDK_Aftermath_GpuCrashDump_GetGpuInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetPageFaultInfo:TGFSDK_Aftermath_GpuCrashDump_GetPageFaultInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetPageFaultResourceInfo:TGFSDK_Aftermath_GpuCrashDump_GetPageFaultResourceInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfoCount:TGFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfoCount=nil;

    GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfo:TGFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfoCount:TGFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfoCount=nil;

    GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfo:TGFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfo=nil;

    GFSDK_Aftermath_GpuCrashDump_GenerateJSON:TGFSDK_Aftermath_GpuCrashDump_GenerateJSON=nil;

    GFSDK_Aftermath_GpuCrashDump_GetJSON:TGFSDK_Aftermath_GpuCrashDump_GetJSON=nil;

    GFSDK_Aftermath_GetShaderDebugInfoIdentifier:TGFSDK_Aftermath_GetShaderDebugInfoIdentifier=nil;

    GFSDK_Aftermath_GetShaderHashSpirv:TGFSDK_Aftermath_GetShaderHashSpirv=nil;

    GFSDK_Aftermath_GetShaderDebugNameSpirv:TGFSDK_Aftermath_GetShaderDebugNameSpirv=nil;

    GFSDK_Aftermath_GetShaderHashForShaderInfo:TGFSDK_Aftermath_GetShaderHashForShaderInfo=nil;

    GFSDK_Aftermath_LibHandle:Pointer=nil;

    GFSDK_Aftermath_Active:boolean=false;

    GFSDK_Aftermath_CriticalSection:TPasMPCriticalSection=nil;

procedure AFTERMATH_CHECK_ERROR(const aResult:TGFSDK_Aftermath_Result);

procedure LoadNVIDIAAfterMath;
procedure FreeNVIDIAAfterMath;

procedure InitializeNVIDIAAfterMath;
procedure FinalizeNVIDIAAfterMath;

implementation

uses PasVulkan.Application,
     PasVulkan.Collections;

type TShaderDebugInfoHashMap=TpvHashMap<TGFSDK_Aftermath_ShaderDebugInfoIdentifier,TBytes>;

     TShaderDatabase=TpvHashMap<TGFSDK_Aftermath_ShaderBinaryHash,TBytes>;

     TShaderSourceDatabase=TpvHashMap<TGFSDK_Aftermath_ShaderDebugName,TBytes>;

     TSafeString=array[0..255] of AnsiChar;
     PSafeString=^TSafeString;

var ShaderDebugInfoHashMap:TShaderDebugInfoHashMap=nil;

    ShaderDatabase:TShaderDatabase=nil;

    ShaderSourceDatabase:TShaderSourceDatabase=nil;

procedure SafeStringClear(out aSafeString:TSafeString);
begin
 FillChar(aSafeString,SizeOf(TSafeString),#0);
end;

procedure SafeStringClean(var aSafeString:TSafeString); // Clean non-ascii characters to spaces
var Index:TpvSizeInt;
begin

 // Trim the string
 for Index:=Min(TpvUInt8(aSafeString[0]),SizeOf(TSafeString)-2) downto 1 do begin
  case aSafeString[Index] of
   #0..#31,#127..#255:begin
    aSafeString[Index]:=#0;
    TpvUInt8(aSafeString[0]):=Index-1;
   end else begin
    break;
   end;
  end;
 end;

 // Replace remaining non-ascii characters with spaces
 for Index:=1 to Min(TpvUInt8(aSafeString[0]),SizeOf(TSafeString)-2) do begin
  case aSafeString[Index] of
   #0..#31,#127..#255:begin
    aSafeString[Index]:=#32;
   end;
  end;
 end;

end;

procedure SafeStringSet(out aSafeString:TSafeString;const aString:ShortString);
var Len:TpvSizeInt;
begin
 SafeStringClear(aSafeString);
 Len:=Max(Min(TpvUInt8(aString[0]),SizeOf(TSafeString)-2),0);
 if Len>0 then begin
  Move(aString[1],aSafeString[1],Len); 
  aSafeString[Len+1]:=#0; // Null terminator at the end
 end;
 TpvUInt8(aSafeString[0]):=Len;
end;

procedure SafeStringSetPtr(out aSafeString:TSafeString;const aString:PAnsiChar);
var Len:TpvSizeInt;
begin
 SafeStringClear(aSafeString);
 if assigned(aString) then begin
  Len:=Length(aString);
  if Len>(SizeOf(TSafeString)-2) then begin
   Len:=SizeOf(TSafeString)-2; // -2 because of the length byte at the beginning and the null terminator at the end
  end;
  Move(aString^,aSafeString[1],Len);
  aSafeString[Len+1]:=#0;
  TpvUInt8(aSafeString[0]):=Len;
 end;
end;

procedure SafeStringAppend(var aSafeString:TSafeString;const aString:ShortString); 
var Len,NewLen,ToCopy:TpvSizeInt;
begin
 Len:=TpvUInt8(aSafeString[0]);
 NewLen:=Len+TpvUInt8(aString[0]);
 if Len<>NewLen then begin
  if NewLen>(SizeOf(TSafeString)-2) then begin
   NewLen:=SizeOf(TSafeString)-2; // -2 because of the length byte at the beginning and the null terminator at the end
  end;
  ToCopy:=NewLen-Len;
  Move(aString[1],aSafeString[Len+1],ToCopy);
  aSafeString[NewLen+1]:=#0;
  TpvUInt8(aSafeString[0]):=NewLen;
 end; 
end;

procedure SafeStringAppendChar(var aSafeString:TSafeString;const aChar:AnsiChar);
var Len,NewLen:TpvSizeInt;
begin
 Len:=TpvUInt8(aSafeString[0]);
 NewLen:=Len+1;
 if Len<>NewLen then begin
  if NewLen>(SizeOf(TSafeString)-2) then begin
   NewLen:=SizeOf(TSafeString)-2; // -2 because of the length byte at the beginning and the null terminator at the end
  end;
  aSafeString[Len+1]:=aChar;
  aSafeString[NewLen+1]:=#0;
  TpvUInt8(aSafeString[0]):=NewLen;
 end;
end;

procedure SafeStringAppendPtr(var aSafeString:TSafeString;const aString:PAnsiChar);
var Len,NewLen,ToCopy:TpvSizeInt;
begin
 Len:=TpvUInt8(aSafeString[0]);
 NewLen:=Len+Length(aString);
 if Len<>NewLen then begin
  if NewLen>(SizeOf(TSafeString)-2) then begin
   NewLen:=SizeOf(TSafeString)-2; // -2 because of the length byte at the beginning and the null terminator at the end
  end;
  ToCopy:=NewLen-Len;
  Move(aString^,aSafeString[Len+1],ToCopy);
  aSafeString[NewLen+1]:=#0;
  TpvUInt8(aSafeString[0]):=NewLen;
 end;
end;

procedure SafeStringAppendInt64(var aSafeString:TSafeString;const aValue:TpvInt64);
var Index,Digits:TpvSizeInt;
    Value,Digit:TpvInt64;
    DigitBuffer:array[0..31] of AnsiChar;
begin
 
 // Calculate the number of digits 
 Value:=aValue;
 Digits:=0;
 if Value<0 then begin
  inc(Digits);
  Value:=-Value;
 end;
 if Value=0 then begin
  inc(Digits);
 end else begin
  while Value<>0 do begin
   inc(Digits);
   Value:=Value div 10;
  end;
 end;

 // Fill the digit buffer
 FillChar(DigitBuffer,SizeOf(DigitBuffer),#0);
 Index:=Digits;
 Value:=aValue;
 if Value<0 then begin
  DigitBuffer[0]:='-';
  Value:=-Value;
 end;
 if Value=0 then begin
  dec(Index);
  DigitBuffer[Index]:='0';
 end else begin
  while (Value<>0) and (Index>0) do begin
   Digit:=Value mod 10;
   dec(Index);
   DigitBuffer[Index]:=AnsiChar(Digit+Ord('0'));
   Value:=Value div 10;
  end;
 end;

 // Append the digit buffer to the safe string
 SafeStringAppendPtr(aSafeString,@DigitBuffer[0]);
 
end;

procedure SafeStringAppendUInt64(var aSafeString:TSafeString;const aValue:TpvUInt64);
var Index,Digits:TpvSizeInt;
    Value,Digit:TpvUInt64;
    DigitBuffer:array[0..31] of AnsiChar;
begin

 // Calculate the number of digits
 Value:=aValue; 
 Digits:=0;
 if Value=0 then begin
  inc(Digits);
 end else begin
  while Value<>0 do begin
   inc(Digits);
   Value:=Value div 10;
  end;
 end;

 // Fill the digit buffer
 FillChar(DigitBuffer,SizeOf(DigitBuffer),#0);
 Index:=Digits;
 Value:=aValue;
 if Value=0 then begin
  dec(Index);
  DigitBuffer[Index]:='0';
 end else begin
  while (Value<>0) and (Index>0) do begin
   Digit:=Value mod 10;
   dec(Index);
   DigitBuffer[Index]:=AnsiChar(Digit+Ord('0'));
   Value:=Value div 10;
  end;
 end;

 // Append the digit buffer to the safe string
 SafeStringAppendPtr(aSafeString,@DigitBuffer[0]);
 
end;

function SafeStringToString(const aSafeString:TSafeString):string; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=PAnsiChar(@aSafeString[1]);
end;

function SafeStringToAnsiString(const aSafeString:TSafeString):AnsiString; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=AnsiString(PAnsiChar(@aSafeString[1]));
end;

function SafeStringToPAnsiChar(const aSafeString:TSafeString):PAnsiChar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=PAnsiChar(@aSafeString[1]);
end;

procedure AFTERMATH_CHECK_ERROR(const aResult:TGFSDK_Aftermath_Result);
begin
 if (aResult and TpvUInt32($fff00000))=GFSDK_Aftermath_Result_Fail then begin
  case aResult of
   GFSDK_Aftermath_Result_FAIL_VersionMismatch:begin
    raise EGFSDK_Aftermath.Create('Version match');
   end;
   GFSDK_Aftermath_Result_FAIL_NotInitialized:begin
    raise EGFSDK_Aftermath.Create('Not initialized');
   end;
   GFSDK_Aftermath_Result_FAIL_InvalidAdapter:begin
    raise EGFSDK_Aftermath.Create('Invalid adapter');
   end;
   GFSDK_Aftermath_Result_FAIL_InvalidParameter:begin
    raise EGFSDK_Aftermath.Create('Invalid parameter');
   end;
   GFSDK_Aftermath_Result_FAIL_Unknown:begin
    raise EGFSDK_Aftermath.Create('Unknown');
   end;
   GFSDK_Aftermath_Result_FAIL_ApiError:begin
    raise EGFSDK_Aftermath.Create('API error');
   end;
   GFSDK_Aftermath_Result_FAIL_NvApiIncompatible:begin
    raise EGFSDK_Aftermath.Create('NvAPI incompstible');
   end;
   GFSDK_Aftermath_Result_FAIL_GettingContextDataWithNewCommandList:begin
    raise EGFSDK_Aftermath.Create('Getting context data with new command list');
   end;
   GFSDK_Aftermath_Result_FAIL_AlreadyInitialized:begin
    raise EGFSDK_Aftermath.Create('Already initialized');
   end;
   GFSDK_Aftermath_Result_FAIL_D3DDebugLayerNotCompatible:begin
    raise EGFSDK_Aftermath.Create('D3D debug layer not compatible');
   end;
   GFSDK_Aftermath_Result_FAIL_DriverInitFailed:begin
    raise EGFSDK_Aftermath.Create('Driver init failed');
   end;
   GFSDK_Aftermath_Result_FAIL_DriverVersionNotSupported:begin
    raise EGFSDK_Aftermath.Create('Driver version not supported');
   end;
   GFSDK_Aftermath_Result_FAIL_OutOfMemory:begin
    raise EGFSDK_Aftermath.Create('Out of memory');
   end;
   GFSDK_Aftermath_Result_FAIL_GetDataOnBundle:begin
    raise EGFSDK_Aftermath.Create('Get data on bundle');
   end;
   GFSDK_Aftermath_Result_FAIL_GetDataOnDeferredContext:begin
    raise EGFSDK_Aftermath.Create('Get data on deferred context');
   end;
   GFSDK_Aftermath_Result_FAIL_FeatureNotEnabled:begin
    raise EGFSDK_Aftermath.Create('Feature not enabled');
   end;
   GFSDK_Aftermath_Result_FAIL_NoResourcesRegistered:begin
    raise EGFSDK_Aftermath.Create('No resources registered');
   end;
   GFSDK_Aftermath_Result_FAIL_ThisResourceNeverRegistered:begin
    raise EGFSDK_Aftermath.Create('This resource never registered');
   end;
   GFSDK_Aftermath_Result_FAIL_NotSupportedInUWP:begin
    raise EGFSDK_Aftermath.Create('Not supported in UWP');
   end;
   GFSDK_Aftermath_Result_FAIL_D3dDllNotSupported:begin
    raise EGFSDK_Aftermath.Create('D3D DLL not supported');
   end;
   GFSDK_Aftermath_Result_FAIL_D3dDllInterceptionNotSupported:begin
    raise EGFSDK_Aftermath.Create('D3D DLL interception not supported');
   end;
   GFSDK_Aftermath_Result_FAIL_Disabled:begin
    raise EGFSDK_Aftermath.Create('Disabled');
   end;
  end;
 end;
end;

function _LoadLibrary(const LibraryName:string):pointer; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef Windows}
 result:={%H-}pointer(LoadLibrary(PChar(LibraryName)));
{$else}
{$ifdef Unix}
 result:=dlopen(PChar(LibraryName),RTLD_NOW or RTLD_LAZY);
{$else}
 result:=nil;
{$endif}
{$endif}
end;

function _FreeLibrary(LibraryHandle:pointer):boolean; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=assigned(LibraryHandle);
 if result then begin
{$ifdef Windows}
  result:=FreeLibrary({%H-}HMODULE(LibraryHandle));
{$else}
{$ifdef Unix}
  result:=dlclose(LibraryHandle)=0;
{$else}
  result:=false;
{$endif}
{$endif}
 end;
end;

function _GetProcAddress(LibraryHandle:pointer;const ProcName:string):pointer; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef Windows}
 result:=GetProcAddress({%H-}HMODULE(LibraryHandle),PChar(ProcName));
{$else}
{$ifdef Unix}
 result:=dlsym(LibraryHandle,PChar(ProcName));
{$else}
 result:=nil;
{$endif}
{$endif}
end;

type TPFN_VoidFunction=procedure(); cdecl;

function _VoidFunctionToPointer(const VoidFunction:TPFN_VoidFunction):pointer; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=addr(VoidFunction);
end;

procedure LoadNVIDIAAfterMath;
begin
 if not assigned(GFSDK_Aftermath_LibHandle) then begin
  GFSDK_Aftermath_LibHandle:=_LoadLibrary(
{$if defined(Windows) and (defined(cpuamd64) or defined(cpux64) or defined(cpux86_64))}
                              'GFSDK_Aftermath_Lib.x64.dll'
{$elseif defined(Windows) and defined(cpux86)}
                              'GFSDK_Aftermath_Lib.x86.dll'
{$else}
                              'libGFSDK_Aftermath.so'
{$ifend}
                             );
  if assigned(GFSDK_Aftermath_LibHandle) then begin
   @GFSDK_Aftermath_EnableGpuCrashDumps:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_EnableGpuCrashDumps');
   @GFSDK_Aftermath_DisableGpuCrashDumps:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_DisableGpuCrashDumps');
   @GFSDK_Aftermath_CrashDump_Status:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_CrashDump_Status');
   @GFSDK_Aftermath_GpuCrashDump_CreateDecoder:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_CreateDecoder');
   @GFSDK_Aftermath_GpuCrashDump_DestroyDecoder:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_DestroyDecoder');
   @GFSDK_Aftermath_GpuCrashDump_GetBaseInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetBaseInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetDescriptionSize:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetDescriptionSize');
   @GFSDK_Aftermath_GpuCrashDump_GetDescription:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetDescription');
   @GFSDK_Aftermath_GpuCrashDump_GetDeviceInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetDeviceInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetSystemInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetSystemInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetGpuInfoCount:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetGpuInfoCount');
   @GFSDK_Aftermath_GpuCrashDump_GetGpuInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetGpuInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetPageFaultInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetPageFaultInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetPageFaultResourceInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetPageFaultResourceInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfoCount:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfoCount');
   @GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetActiveShadersInfo');
   @GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfoCount:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfoCount');
   @GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetEventMarkersInfo');
   @GFSDK_Aftermath_GpuCrashDump_GenerateJSON:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GenerateJSON');
   @GFSDK_Aftermath_GpuCrashDump_GetJSON:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GpuCrashDump_GetJSON');
   @GFSDK_Aftermath_GetShaderDebugInfoIdentifier:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GetShaderDebugInfoIdentifier');
   @GFSDK_Aftermath_GetShaderHashSpirv:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GetShaderHashSpirv');
   @GFSDK_Aftermath_GetShaderDebugNameSpirv:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GetShaderDebugNameSpirv');
   @GFSDK_Aftermath_GetShaderHashForShaderInfo:=_GetProcAddress(GFSDK_Aftermath_LibHandle,'GFSDK_Aftermath_GetShaderHashForShaderInfo');
  end;
 end;
end;

procedure FreeNVIDIAAfterMath;
begin
 if assigned(GFSDK_Aftermath_LibHandle) then begin
  try
   _FreeLibrary(GFSDK_Aftermath_LibHandle);
  finally
   GFSDK_Aftermath_LibHandle:=nil;
  end;
 end;
end;

procedure ShaderDebugInfoLookupCallback(pIdentifier:PGFSDK_Aftermath_ShaderDebugInfoIdentifier;setShaderDebugInfo:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;
var Data:TBytes;
begin
 Data:=ShaderDebugInfoHashMap[pIdentifier^];
 if length(Data)>0 then begin
  setShaderDebugInfo(@Data[0],length(Data));
 end;
end;

procedure ShaderLookupCallback(pShaderBinaryHash:PGFSDK_Aftermath_ShaderBinaryHash;setShaderBinary:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;
var Data:TBytes;
begin
 Data:=ShaderDatabase[pShaderBinaryHash^];
 if length(Data)>0 then begin
  setShaderBinary(@Data[0],length(Data));
 end;
end;

procedure ShaderSourceDebugInfoLookupCallback(pShaderDebugName:PGFSDK_Aftermath_ShaderDebugName;setShaderBinary:TPFN_GFSDK_Aftermath_SetData;pUserData:Pointer); cdecl;
var Data:TBytes;
begin
 Data:=ShaderSourceDatabase[pShaderDebugName^];
 if length(Data)>0 then begin
  setShaderBinary(@Data[0],length(Data));
 end;
end;

var GPUCrashDumpCallbackCounter:TpvInt32=0;

procedure GPUCrashDumpCallback(pGpuCrashDump:Pointer;gpuCrashDumpSize:TpvUInt32;pUserData:Pointer); cdecl;
var decoder:TGFSDK_Aftermath_GpuCrashDump_Decoder;
    baseInfo:TGFSDK_Aftermath_GpuCrashDump_BaseInfo;
    applicationNameLength:TpvUInt32;
    applicationName:TSafeString;
    baseFileName:TSafeString;
    crashDumpFileName:TSafeString;
{$ifdef Windows}
    dummy:DWORD;
    dumpFileHandle:THandle;
{$else}    
    dumpFile:TFileStream;
{$endif}
    jsonSize:TpvUInt32;
    json:Pointer;    
    jsonDumpFileName:TSafeString;
{$ifdef Windows}
    jsonFileHandle:THandle;
{$else}    
    jsonFile:TFileStream;
{$endif}
begin

//applicationName:='';

//try
 begin

  GFSDK_Aftermath_CriticalSection.Acquire;
  try

   // Create a GPU crash dump decoder object for the GPU crash dump.
   FillChar(decoder,SizeOf(TGFSDK_Aftermath_GpuCrashDump_Decoder),#0);
   AFTERMATH_CHECK_ERROR(
    GFSDK_Aftermath_GpuCrashDump_CreateDecoder(
     GFSDK_Aftermath_Version_API,
     pGpuCrashDump,
     gpuCrashDumpSize,
     @decoder
    )
   );

   try

    // Use the decoder object to read basic information, like application
    // name, PID, etc. from the GPU crash dump.
    FillChar(baseInfo,SizeOf(TGFSDK_Aftermath_GpuCrashDump_BaseInfo),#0);
    AFTERMATH_CHECK_ERROR(GFSDK_Aftermath_GpuCrashDump_GetBaseInfo(decoder,@baseInfo));

    // Use the decoder object to query the application name that was set
    // in the GPU crash dump description.
    applicationNameLength:=0;
    AFTERMATH_CHECK_ERROR(
     GFSDK_Aftermath_GpuCrashDump_GetDescriptionSize(
      decoder,
      GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationName,
      @applicationNameLength
     )
    );

    SafeStringClear(applicationName);
    TpvUInt8(applicationName[0]):=Min(applicationNameLength,SizeOf(TSafeString)-2);
//  SetLength(applicationName,applicationNameLength+1);

    AFTERMATH_CHECK_ERROR(
     GFSDK_Aftermath_GpuCrashDump_GetDescription(
      decoder,
      GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationName,
      TpvUInt8(applicationName[0]),
      //length(applicationName)-1,
      @applicationName[1]
     )
    );

    //applicationName:=Trim(applicationName);
    SafeStringClean(applicationName); // Clean non-ascii characters to spaces for to avoid problems with file names
    
    // Limit the application name to 32 characters for have space for the thread id, the counter and possible file extensions
    if TpvUInt8(applicationName[0])>32 then begin
     TpvUInt8(applicationName[0]):=32;
    end;

    // Place a null terminator at the end of the application name, just in case.
    applicationName[TpvUInt8(applicationName[0])+1]:=#0; // Null terminator at the end

    // Create a unique file name for writing the crash dump data to a file.
    // Note: due to an Nsight Aftermath bug (will be fixed in an upcoming
    // driver release) we may see redundant crash dumps. As a workaround,
    // attach a unique count to each generated file name.
    baseFileName:=applicationName;
    SafeStringAppendChar(baseFileName,'-');
    SafeStringAppendInt64(baseFileName,TpvInt64(UInt64(MainThreadID)));
    SafeStringAppendChar(baseFileName,'-');
    SafeStringAppendInt64(baseFileName,TpvInt64(GPUCrashDumpCallbackCounter));
//  baseFileName:=applicationName+'-'+IntToStr(UInt64(MainThreadID))+'-'+IntToStr(GPUCrashDumpCallbackCounter);
    inc(GPUCrashDumpCallbackCounter);

    // Write the the crash dumShaderSourceDebugInfoLookupCallbackp data to a file using the .nv-gpudmp extension
    // registered with Nsight Graphics.
    if gpuCrashDumpSize>0 then begin
     crashDumpFileName:=baseFileName;
     SafeStringAppend(crashDumpFileName,'.nv-gpudmp');
     //crashDumpFileName:=baseFileName+'.nv-gpudmp';
{$ifdef Windows}
     dumpFileHandle:=CreateFileA(SafeStringToPAnsiChar(crashDumpFileName),GENERIC_WRITE,0,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
     if dumpFileHandle<>INVALID_HANDLE_VALUE then begin
      try
       WriteFile(dumpFileHandle,pGpuCrashDump^,gpuCrashDumpSize,dummy,nil);
      finally
       CloseHandle(dumpFileHandle);
      end;
     end;
{$else}
     dumpFile:=TFileStream.Create(SafeStringToString(crashDumpFileName),fmCreate or fmShareDenyWrite);
     try
      dumpFile.Write(pGpuCrashDump^,gpuCrashDumpSize);
     finally
      FreeAndNil(dumpFile);
     end;
{$endif}
    end; 

    // Decode the crash dump to a JSON string.
    // Step 1: Generate the JSON and get the size.
    jsonSize:=0;
    AFTERMATH_CHECK_ERROR(
     GFSDK_Aftermath_GpuCrashDump_GenerateJSON(
      decoder,
      GFSDK_Aftermath_GpuCrashDumpDecoderFlags_ALL_INFO,
      GFSDK_Aftermath_GpuCrashDumpFormatterFlags_NONE,
      ShaderDebugInfoLookupCallback,
      ShaderLookupCallback,
      ShaderSourceDebugInfoLookupCallback,
      nil,
      @jsonSize
     )
    );

    // Step 2: Allocate a buffer and fetch the generated JSON.
    if jsonSize>0 then begin
     json:=nil;
     try
      GetMem(json,jsonSize+1);
      AFTERMATH_CHECK_ERROR(
       GFSDK_Aftermath_GpuCrashDump_GetJSON(
        decoder,
        jsonSize,
        json
       )
      );
      // Write the the crash dump data as JSON to a file.
      jsonDumpFileName:=crashDumpFileName;
      SafeStringAppend(jsonDumpFileName,'.json');
      //jsonDumpFileName:=crashDumpFileName+'.json';
{$ifdef Windows}
      jsonFileHandle:=CreateFileA(SafeStringToPAnsiChar(jsonDumpFileName),GENERIC_WRITE,0,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
      if jsonFileHandle<>INVALID_HANDLE_VALUE then begin
       try
        WriteFile(jsonFileHandle,json^,jsonSize,dummy,nil);
       finally
        CloseHandle(jsonFileHandle);
       end;
      end;
{$else}      
      jsonFile:=TFileStream.Create(SafeStringToString(jsonDumpFileName),fmCreate or fmShareDenyWrite);
      try
       jsonFile.Write(json^,jsonSize);
      finally
       FreeAndNil(jsonFile);
      end;
{$endif}
     finally
      if assigned(json) then begin
       try
        FreeMem(json);
       finally 
        json:=nil;
       end; 
      end;
     end;
    end;

   finally

    // Destroy the GPU crash dump decoder object.
    AFTERMATH_CHECK_ERROR(GFSDK_Aftermath_GpuCrashDump_DestroyDecoder(decoder));

   end;

  finally
   GFSDK_Aftermath_CriticalSection.Release;
  end;

{finally
  //applicationName:='';}
 end;

end;

procedure ShaderDebugInfoCallback(pShaderDebugInfo:Pointer;shaderDebugInfoSize:TpvUInt32;pUserData:Pointer); cdecl;
{$ifdef Windows}
const HexChars:array[0..15] of AnsiChar=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'); 
{$endif}
var identifier:TGFSDK_Aftermath_ShaderDebugInfoIdentifier;
    Bytes:TBytes;
{$ifdef Windows}
    FileName:array[0..256] of AnsiChar;
    FileCharIndex,Index:TpvSizeInt;
    FileHandle:THandle;
    Value:TpvUInt64;
    Written:DWORD;
{$else}
    FileStream:TFileStream;
{$endif}
begin
 GFSDK_Aftermath_CriticalSection.Acquire;
 try
  FillChar(identifier,SizeOf(TGFSDK_Aftermath_ShaderDebugInfoIdentifier),#0);
  AFTERMATH_CHECK_ERROR(
   GFSDK_Aftermath_GetShaderDebugInfoIdentifier(
    GFSDK_Aftermath_Version_API,
     pShaderDebugInfo,
     shaderDebugInfoSize,
     @identifier
    )
   );
  if shaderDebugInfoSize>0 then begin
   Bytes:=nil;
   try
    SetLength(Bytes,shaderDebugInfoSize);
    Move(pShaderDebugInfo^,Bytes[0],shaderDebugInfoSize);
    ShaderDebugInfoHashMap[identifier]:=Bytes;
{$ifdef Windows}
    FileName[0]:='s';
    FileName[1]:='h';
    FileName[2]:='a';
    FileName[3]:='d';
    FileName[4]:='e';
    FileName[5]:='r';
    FileName[6]:='-';
    Value:=identifier.ID[0];
    FileCharIndex:=7;
    for Index:=0 to 15 do begin
     FileName[FileCharIndex]:=HexChars[(Value shr (Index shl 2)) and $f];
     inc(FileCharIndex);
    end;
    FileName[FileCharIndex]:='-';
    inc(FileCharIndex);
    Value:=identifier.ID[1];
    for Index:=0 to 15 do begin
     FileName[FileCharIndex]:=HexChars[(Value shr (Index shl 2)) and $f];
     inc(FileCharIndex);
    end;
    FileName[FileCharIndex]:='.';
    FileName[FileCharIndex+1]:='n';
    FileName[FileCharIndex+2]:='v';
    FileName[FileCharIndex+3]:='d';
    FileName[FileCharIndex+4]:='b';
    FileName[FileCharIndex+5]:='g';
    FileName[FileCharIndex+6]:=#0;
    FileHandle:=CreateFileA(Pointer(@FileName[0]),GENERIC_WRITE,0,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    if FileHandle<>INVALID_HANDLE_VALUE then begin
     try
      WriteFile(FileHandle,Bytes[0],shaderDebugInfoSize,Written,nil);
     finally
      CloseHandle(FileHandle);
     end;
    end;
{$else}
    FileStream:=FileStream.Create('shader-'+IntToStr(identifier.ID[0])+IntToStr(identifier.ID[1])+'.nvdbg',fmCreate or fmShareDenyWrite);
    try
     FileStream.Write(Bytes[0],shaderDebugInfoSize);
    finally
     FreeAndNil(FileStream);
    end;
{$endif}   
   finally
    Bytes:=nil;
   end;
  end;
 finally
  GFSDK_Aftermath_CriticalSection.Release;
 end;
end;

procedure CrashDumpDescriptionCallback(addValue:TPFN_GFSDK_Aftermath_AddGpuCrashDumpDescription;pUserData:Pointer); cdecl;
begin
 if assigned(addValue) then begin
  addValue(GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationName,pAnsiChar(pvApplication.Title));
  addValue(GFSDK_Aftermath_GpuCrashDumpDescriptionKey_ApplicationVersion,'1.0');
  addValue(GFSDK_Aftermath_GpuCrashDumpDescriptionKey_UserDefined,'GPU crash dump');
 end;
end;

procedure InitializeNVIDIAAfterMath;
begin
 if not GFSDK_Aftermath_Active then begin
  GFSDK_Aftermath_CriticalSection:=TPasMPCriticalSection.Create;
  ShaderDebugInfoHashMap:=TShaderDebugInfoHashMap.Create(nil);
  ShaderDatabase:=TShaderDatabase.Create(nil);
  ShaderSourceDatabase:=TShaderSourceDatabase.Create(nil);
  LoadNVIDIAAfterMath;
  if assigned(@GFSDK_Aftermath_EnableGpuCrashDumps) then begin
   AFTERMATH_CHECK_ERROR(
    GFSDK_Aftermath_EnableGpuCrashDumps(
     GFSDK_Aftermath_Version_API,
     GFSDK_Aftermath_GpuCrashDumpWatchedApiFlags_Vulkan,
     GFSDK_Aftermath_GpuCrashDumpFeatureFlags_DeferDebugInfoCallbacks, // Let the Nsight Aftermath library cache shader debug information.
     GPUCrashDumpCallback,                                             // Register callback for GPU crash dumps.
     ShaderDebugInfoCallback,                                          // Register callback for shader debug information.
     CrashDumpDescriptionCallback,                                     // Register callback for GPU crash dump description.
     nil,
     nil
    )
   );
   GFSDK_Aftermath_Active:=true;
  end;
 end;
end;

procedure FinalizeNVIDIAAfterMath;
begin
 if GFSDK_Aftermath_Active and assigned(@GFSDK_Aftermath_DisableGpuCrashDumps) then begin
  AFTERMATH_CHECK_ERROR(GFSDK_Aftermath_DisableGpuCrashDumps);
  FreeAndNil(ShaderSourceDatabase);
  FreeAndNil(ShaderDatabase);
  FreeAndNil(ShaderDebugInfoHashMap);
  FreeAndNil(GFSDK_Aftermath_CriticalSection);
  GFSDK_Aftermath_Active:=false;
 end;
end;

procedure SafeStringUnitTests;
var SafeString,OtherSafeString:TSafeString;
begin

 SafeStringClear(SafeString);
 SafeStringSet(SafeString,'Hello, World!');
 SafeStringAppend(SafeString,' This is a test');
 SafeStringAppendChar(SafeString,'!');
 SafeStringAppendPtr(SafeString,' This is a test.');
 SafeStringAppendInt64(SafeString,1234567890);
 SafeStringAppendUInt64(SafeString,1234567890);
 SafeStringAppendInt64(SafeString,-1234567890);
 WriteLn(SafeStringToString(SafeString));

 SafeStringClear(OtherSafeString);
 SafeStringSet(OtherSafeString,'Hello, World!');
 SafeStringAppend(OtherSafeString,' This is a test');
 SafeStringAppendChar(OtherSafeString,'!');
 SafeStringAppendPtr(OtherSafeString,' This is a test.');
 SafeStringAppendInt64(OtherSafeString,1234567890);
 SafeStringAppendUInt64(OtherSafeString,1234567890);
 SafeStringAppendInt64(OtherSafeString,-1234567890);
 WriteLn(SafeStringToString(OtherSafeString));

end; 
 
initialization
//SafeStringUnitTests;
finalization
 FinalizeNVIDIAAfterMath;
 FreeNVIDIAAfterMath;
end.

