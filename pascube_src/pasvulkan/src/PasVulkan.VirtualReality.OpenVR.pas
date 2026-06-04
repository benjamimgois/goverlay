{=======Copyright (c) Valve Corporation, All rights reserved. ===============    }
{                                                                                }
{ Purpose: Header for flatted SteamAPI. Use this for binding to other languages. }
{ This file is auto-generated, do not edit it.                                   }
{                                                                                }
{ =============================================================================  }
unit PasVulkan.VirtualReality.OpenVR; // 1.0.17
{$ifdef fpc}
 {$mode delphi}
 {$packrecords c}
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

{$if defined(Windows) or defined(Linux) or defined(Darwin)}
 {$define TargetWithOpenVRSupport}
{$else}
 {$undef TargetWithOpenVRSupport}
{$ifend}

interface

{$ifdef TargetWithOpenVRSupport}

{$define PasOpenVRPasVulkan}

uses SysUtils{$ifdef Windows},Windows{$else},DynLibs{$endif}{$ifdef PasOpenVRPasVulkan},Vulkan{$endif};

const OpenVRLibraryName={$if defined(Windows)}
                         {$if defined(cpu64) or defined(Win64) or defined(cpux64) or defined(cpux86_64)}
                          'openvr_api_64.dll'
                         {$else}
                          'openvr_api_32.dll'
                         {$ifend}
                        {$else}
                         'openvr_api'
                        {$ifend};
               
type PpovrInt8=^TpovrInt8;
     TpovrInt8={$if declared(Int8)}Int8{$else}ShortInt{$ifend};

     PpovrUInt8=^TpovrUInt8;
     TpovrUInt8={$if declared(UInt8)}Int8{$else}Byte{$ifend};

     PpovrInt16=^TpovrInt16;
     TpovrInt16={$if declared(Int16)}Int16{$else}SmallInt{$ifend};

     PpovrUInt16=^TpovrUInt16;
     TpovrUInt16={$if declared(UInt16)}UInt16{$else}Word{$ifend};

     PpovrInt32=^TpovrInt32;
     TpovrInt32={$if declared(Int32)}Int32{$else}LongInt{$ifend};

     PpovrUInt32=^TpovrUInt32;
     TpovrUInt32={$if declared(UInt32)}UInt32{$else}LongWord{$ifend};

     PpovrInt64=^TpovrInt64;
     TpovrInt64=Int64;

     PpovrUInt64=^TpovrUInt64;
     TpovrUInt64=UInt64;

     PpovrIntPtr=^TpovrIntPtr;
     TpovrIntPtr={$if declared(PtrInt)}PtrInt{$elseif declared(NativeInt)}NativeInt{$else}TpovrInt32{$ifend};

     PpovrInt=PpovrInt32;
     TpovrInt=TpovrInt32;

     Pbool=^Tbool;
     Tbool=bytebool;

     PPropertyContainerHandle_t=^TPropertyContainerHandle_t;
     TPropertyContainerHandle_t=TpovrUInt64;

     PPropertyTypeTag_t=^TPropertyTypeTag_t;
     TPropertyTypeTag_t=TpovrUInt32;

     PVRActionHandle_t=^TVRActionHandle_t;
     TVRActionHandle_t=TpovrUInt64;

     PVRActionSetHandle_t=^TVRActionSetHandle_t;
     TVRActionSetHandle_t=TpovrUInt64;

     PVRInputValueHandle_t=^TVRInputValueHandle_t;
     TVRInputValueHandle_t=TpovrUInt64;

{ OpenVR Constants }
const k_nDriverNone=TpovrUInt32(4294967295);
      k_unMaxDriverDebugResponseSize=32768;
      k_unTrackedDeviceIndex_Hmd=0;
      k_unMaxTrackedDeviceCount=64;
      k_unTrackedDeviceIndexOther=TpovrUInt32(4294967294);
      k_unTrackedDeviceIndexInvalid=TpovrUInt32(4294967295);
      k_ulInvalidPropertyContainer=0;
      k_unInvalidPropertyTag=0;
      k_ulInvalidDriverHandle=0;
      k_unFloatPropertyTag=1;
      k_unInt32PropertyTag=2;
      k_unUint64PropertyTag=3;
      k_unBoolPropertyTag=4;
      k_unStringPropertyTag=5;
      k_unHmdMatrix34PropertyTag=20;
      k_unHmdMatrix44PropertyTag=21;
      k_unHmdVector3PropertyTag=22;
      k_unHmdVector4PropertyTag=23;
      k_unHiddenAreaPropertyTag=30;
      k_unPathHandleInfoTag=31;
      k_unActionPropertyTag=32;
      k_unInputValuePropertyTag=33;
      k_unWildcardPropertyTag=34;
      k_unHapticVibrationPropertyTag=35;
      k_unSkeletonPropertyTag=36;
      k_unSpatialAnchorPosePropertyTag=40;
      k_unJsonPropertyTag=41;
      k_unOpenVRInternalReserved_Start=1000;
      k_unOpenVRInternalReserved_End=10000;
      k_unMaxPropertyStringSize=32768;
      k_ulInvalidActionHandle=0;
      k_ulInvalidActionSetHandle=0;
      k_ulInvalidInputValueHandle=0;
      k_unControllerStateAxisCount=5;
      k_ulOverlayHandleInvalid=0;
      k_unScreenshotHandleInvalid=0;
      IVRSystem_Version='IVRSystem_019';
      IVRExtendedDisplay_Version='IVRExtendedDisplay_001';
      IVRTrackedCamera_Version='IVRTrackedCamera_004';
      k_unMaxApplicationKeyLength=128;
      k_pch_MimeType_HomeApp='vr/home';
      k_pch_MimeType_GameTheater='vr/game_theater';
      IVRApplications_Version='IVRApplications_006';
      IVRChaperone_Version='IVRChaperone_003';
      IVRChaperoneSetup_Version='IVRChaperoneSetup_005';
      IVRCompositor_Version='IVRCompositor_022';
      k_unVROverlayMaxKeyLength=128;
      k_unVROverlayMaxNameLength=128;
      k_unMaxOverlayCount=64;
      k_unMaxOverlayIntersectionMaskPrimitivesCount=32;
      IVROverlay_Version='IVROverlay_018';
      k_pch_Controller_Component_GDC2015='gdc2015';
      k_pch_Controller_Component_Base='base';
      k_pch_Controller_Component_Tip='tip';
      k_pch_Controller_Component_HandGrip='handgrip';
      k_pch_Controller_Component_Status='status';
      IVRRenderModels_Version='IVRRenderModels_006';
      k_unNotificationTextMaxSize=256;
      IVRNotifications_Version='IVRNotifications_002';
      k_unMaxSettingsKeyLength=128;
      IVRSettings_Version='IVRSettings_002';
      k_pch_SteamVR_Section='steamvr';
      k_pch_SteamVR_RequireHmd_String='requireHmd';
      k_pch_SteamVR_ForcedDriverKey_String='forcedDriver';
      k_pch_SteamVR_ForcedHmdKey_String='forcedHmd';
      k_pch_SteamVR_DisplayDebug_Bool='displayDebug';
      k_pch_SteamVR_DebugProcessPipe_String='debugProcessPipe';
      k_pch_SteamVR_DisplayDebugX_Int32='displayDebugX';
      k_pch_SteamVR_DisplayDebugY_Int32='displayDebugY';
      k_pch_SteamVR_SendSystemButtonToAllApps_Bool='sendSystemButtonToAllApps';
      k_pch_SteamVR_LogLevel_Int32='loglevel';
      k_pch_SteamVR_IPD_Float='ipd';
      k_pch_SteamVR_Background_String='background';
      k_pch_SteamVR_BackgroundUseDomeProjection_Bool='backgroundUseDomeProjection';
      k_pch_SteamVR_BackgroundCameraHeight_Float='backgroundCameraHeight';
      k_pch_SteamVR_BackgroundDomeRadius_Float='backgroundDomeRadius';
      k_pch_SteamVR_GridColor_String='gridColor';
      k_pch_SteamVR_PlayAreaColor_String='playAreaColor';
      k_pch_SteamVR_ShowStage_Bool='showStage';
      k_pch_SteamVR_ActivateMultipleDrivers_Bool='activateMultipleDrivers';
      k_pch_SteamVR_DirectMode_Bool='directMode';
      k_pch_SteamVR_DirectModeEdidVid_Int32='directModeEdidVid';
      k_pch_SteamVR_DirectModeEdidPid_Int32='directModeEdidPid';
      k_pch_SteamVR_UsingSpeakers_Bool='usingSpeakers';
      k_pch_SteamVR_SpeakersForwardYawOffsetDegrees_Float='speakersForwardYawOffsetDegrees';
      k_pch_SteamVR_BaseStationPowerManagement_Bool='basestationPowerManagement';
      k_pch_SteamVR_NeverKillProcesses_Bool='neverKillProcesses';
      k_pch_SteamVR_SupersampleScale_Float='supersampleScale';
      k_pch_SteamVR_MaxRecommendedResolution_Int32='maxRecommendedResolution';
      k_pch_SteamVR_AllowAsyncReprojection_Bool='allowAsyncReprojection';
      k_pch_SteamVR_AllowReprojection_Bool='allowInterleavedReprojection';
      k_pch_SteamVR_ForceReprojection_Bool='forceReprojection';
      k_pch_SteamVR_ForceFadeOnBadTracking_Bool='forceFadeOnBadTracking';
      k_pch_SteamVR_DefaultMirrorView_Int32='mirrorView';
      k_pch_SteamVR_ShowMirrorView_Bool='showMirrorView';
      k_pch_SteamVR_MirrorViewGeometry_String='mirrorViewGeometry';
      k_pch_SteamVR_MirrorViewGeometryMaximized_String='mirrorViewGeometryMaximized';
      k_pch_SteamVR_StartMonitorFromAppLaunch='startMonitorFromAppLaunch';
      k_pch_SteamVR_StartCompositorFromAppLaunch_Bool='startCompositorFromAppLaunch';
      k_pch_SteamVR_StartDashboardFromAppLaunch_Bool='startDashboardFromAppLaunch';
      k_pch_SteamVR_StartOverlayAppsFromDashboard_Bool='startOverlayAppsFromDashboard';
      k_pch_SteamVR_EnableHomeApp='enableHomeApp';
      k_pch_SteamVR_CycleBackgroundImageTimeSec_Int32='CycleBackgroundImageTimeSec';
      k_pch_SteamVR_RetailDemo_Bool='retailDemo';
      k_pch_SteamVR_IpdOffset_Float='ipdOffset';
      k_pch_SteamVR_AllowSupersampleFiltering_Bool='allowSupersampleFiltering';
      k_pch_SteamVR_SupersampleManualOverride_Bool='supersampleManualOverride';
      k_pch_SteamVR_EnableLinuxVulkanAsync_Bool='enableLinuxVulkanAsync';
      k_pch_SteamVR_AllowDisplayLockedMode_Bool='allowDisplayLockedMode';
      k_pch_SteamVR_HaveStartedTutorialForNativeChaperoneDriver_Bool='haveStartedTutorialForNativeChaperoneDriver';
      k_pch_SteamVR_ForceWindows32bitVRMonitor='forceWindows32BitVRMonitor';
      k_pch_SteamVR_DebugInput='debugInput';
      k_pch_SteamVR_LegacyInputRebinding='legacyInputRebinding';
      k_pch_SteamVR_DebugInputBinding='debugInputBinding';
      k_pch_SteamVR_InputBindingUIBlock='inputBindingUI';
      k_pch_SteamVR_RenderCameraMode='renderCameraMode';
      k_pch_Lighthouse_Section='driver_lighthouse';
      k_pch_Lighthouse_DisableIMU_Bool='disableimu';
      k_pch_Lighthouse_DisableIMUExceptHMD_Bool='disableimuexcepthmd';
      k_pch_Lighthouse_UseDisambiguation_String='usedisambiguation';
      k_pch_Lighthouse_DisambiguationDebug_Int32='disambiguationdebug';
      k_pch_Lighthouse_PrimaryBasestation_Int32='primarybasestation';
      k_pch_Lighthouse_DBHistory_Bool='dbhistory';
      k_pch_Lighthouse_EnableBluetooth_Bool='enableBluetooth';
      k_pch_Lighthouse_PowerManagedBaseStations_String='PowerManagedBaseStations';
      k_pch_Lighthouse_EnableImuFallback_Bool='enableImuFallback';
      k_pch_Null_Section='driver_null';
      k_pch_Null_SerialNumber_String='serialNumber';
      k_pch_Null_ModelNumber_String='modelNumber';
      k_pch_Null_WindowX_Int32='windowX';
      k_pch_Null_WindowY_Int32='windowY';
      k_pch_Null_WindowWidth_Int32='windowWidth';
      k_pch_Null_WindowHeight_Int32='windowHeight';
      k_pch_Null_RenderWidth_Int32='renderWidth';
      k_pch_Null_RenderHeight_Int32='renderHeight';
      k_pch_Null_SecondsFromVsyncToPhotons_Float='secondsFromVsyncToPhotons';
      k_pch_Null_DisplayFrequency_Float='displayFrequency';
      k_pch_UserInterface_Section='userinterface';
      k_pch_UserInterface_StatusAlwaysOnTop_Bool='StatusAlwaysOnTop';
      k_pch_UserInterface_MinimizeToTray_Bool='MinimizeToTray';
      k_pch_UserInterface_HidePopupsWhenStatusMinimized_Bool='HidePopupsWhenStatusMinimized';
      k_pch_UserInterface_Screenshots_Bool='screenshots';
      k_pch_UserInterface_ScreenshotType_Int='screenshotType';
      k_pch_Notifications_Section='notifications';
      k_pch_Notifications_DoNotDisturb_Bool='DoNotDisturb';
      k_pch_Keyboard_Section='keyboard';
      k_pch_Keyboard_TutorialCompletions='TutorialCompletions';
      k_pch_Keyboard_ScaleX='ScaleX';
      k_pch_Keyboard_ScaleY='ScaleY';
      k_pch_Keyboard_OffsetLeftX='OffsetLeftX';
      k_pch_Keyboard_OffsetRightX='OffsetRightX';
      k_pch_Keyboard_OffsetY='OffsetY';
      k_pch_Keyboard_Smoothing='Smoothing';
      k_pch_Perf_Section='perfcheck';
      k_pch_Perf_PerfGraphInHMD_Bool='perfGraphInHMD';
{     k_pch_Perf_HeuristicActive_Bool='heuristicActive';
      k_pch_Perf_NotifyInHMD_Bool='warnInHMD';
      k_pch_Perf_NotifyOnlyOnce_Bool='warnOnlyOnce';}
      k_pch_Perf_AllowTimingStore_Bool='allowTimingStore';
      k_pch_Perf_SaveTimingsOnExit_Bool='saveTimingsOnExit';
      k_pch_Perf_TestData_Float='perfTestData';
      k_pch_Perf_LinuxGPUProfiling_Bool='linuxGPUProfiling';
      k_pch_CollisionBounds_Section='collisionBounds';
      k_pch_CollisionBounds_Style_Int32='CollisionBoundsStyle';
      k_pch_CollisionBounds_GroundPerimeterOn_Bool='CollisionBoundsGroundPerimeterOn';
      k_pch_CollisionBounds_CenterMarkerOn_Bool='CollisionBoundsCenterMarkerOn';
      k_pch_CollisionBounds_PlaySpaceOn_Bool='CollisionBoundsPlaySpaceOn';
      k_pch_CollisionBounds_FadeDistance_Float='CollisionBoundsFadeDistance';
      k_pch_CollisionBounds_ColorGammaR_Int32='CollisionBoundsColorGammaR';
      k_pch_CollisionBounds_ColorGammaG_Int32='CollisionBoundsColorGammaG';
      k_pch_CollisionBounds_ColorGammaB_Int32='CollisionBoundsColorGammaB';
      k_pch_CollisionBounds_ColorGammaA_Int32='CollisionBoundsColorGammaA';
      k_pch_Camera_Section='camera';
      k_pch_Camera_EnableCamera_Bool='enableCamera';
      k_pch_Camera_EnableCameraInDashboard_Bool='enableCameraInDashboard';
      k_pch_Camera_EnableCameraForCollisionBounds_Bool='enableCameraForCollisionBounds';
      k_pch_Camera_EnableCameraForRoomView_Bool='enableCameraForRoomView';
      k_pch_Camera_BoundsColorGammaR_Int32='cameraBoundsColorGammaR';
      k_pch_Camera_BoundsColorGammaG_Int32='cameraBoundsColorGammaG';
      k_pch_Camera_BoundsColorGammaB_Int32='cameraBoundsColorGammaB';
      k_pch_Camera_BoundsColorGammaA_Int32='cameraBoundsColorGammaA';
      k_pch_Camera_BoundsStrength_Int32='cameraBoundsStrength';
      k_pch_Camera_RoomViewMode_Int32='cameraRoomViewMode';
      k_pch_audio_Section='audio';
      k_pch_audio_OnPlaybackDevice_String='onPlaybackDevice';
      k_pch_audio_OnRecordDevice_String='onRecordDevice';
      k_pch_audio_OnPlaybackMirrorDevice_String='onPlaybackMirrorDevice';
      k_pch_audio_OffPlaybackDevice_String='offPlaybackDevice';
      k_pch_audio_OffRecordDevice_String='offRecordDevice';
      k_pch_audio_VIVEHDMIGain='viveHDMIGain';
      k_pch_Power_Section='power';
      k_pch_Power_PowerOffOnExit_Bool='powerOffOnExit';
      k_pch_Power_TurnOffScreensTimeout_Float='turnOffScreensTimeout';
      k_pch_Power_TurnOffControllersTimeout_Float='turnOffControllersTimeout';
      k_pch_Power_ReturnToWatchdogTimeout_Float='returnToWatchdogTimeout';
      k_pch_Power_AutoLaunchSteamVROnButtonPress='autoLaunchSteamVROnButtonPress';
      k_pch_Power_PauseCompositorOnStandby_Bool='pauseCompositorOnStandby';
      k_pch_Dashboard_Section='dashboard';
      k_pch_Dashboard_EnableDashboard_Bool='enableDashboard';
      k_pch_Dashboard_ArcadeMode_Bool='arcadeMode';
      k_pch_Dashboard_EnableWebUI='webUI';
      k_pch_Dashboard_EnableWebUIDevTools='webUIDevTools';
      k_pch_Dashboard_EnableWebUIDashboardReplacement='webUIDashboard';
      k_pch_modelskin_Section='modelskins';
      k_pch_Driver_Enable_Bool='enable';
      k_pch_WebInterface_Section='WebInterface';
      k_pch_WebInterface_WebEnable_Bool='WebEnable';
      k_pch_WebInterface_WebPort_String='WebPort';
      k_pch_VRWebHelper_Section='VRWebHelper';
      k_pch_VRWebHelper_DebuggerEnabled_Bool='DebuggerEnabled';
      k_pch_VRWebHelper_DebuggerPort_Int32='DebuggerPort';
      k_pch_TrackingOverride_Section='TrackingOverrides';
      k_pch_App_BindingAutosaveURLSuffix_String='AutosaveURL';
      k_pch_App_BindingCurrentURLSuffix_String='CurrentURL';
      k_pch_App_NeedToUpdateAutosaveSuffix_Bool='NeedToUpdateAutosave';
      k_pch_App_ActionManifestURL_String='ActionManifestURL';
      k_pch_Trackers_Section='trackers';
      IVRScreenshots_Version='IVRScreenshots_001';
      IVRResources_Version='IVRResources_001';
      IVRDriverManager_Version='IVRDriverManager_001';
      k_unMaxActionNameLength=64;
      k_unMaxActionSetNameLength=64;
      k_unMaxActionOriginCount=16;
      IVRInput_Version='IVRInput_004';
      k_ulInvalidIOBufferHandle=0;
      IVRIOBuffer_Version='IVRIOBuffer_001';
      k_ulInvalidSpatialAnchorHandle=0;
      IVRSpatialAnchors_Version='IVRSpatialAnchors_001';

      C_API_FNTABLE_PREFIX='FnTable:';

{ OpenVR Enums }

      Eye_Left=0;
      Eye_Right=1;

      TextureType_Invalid=-1;
      TextureType_DirectX=0;
      TextureType_OpenGL=1;
      TextureType_Vulkan=2;
      TextureType_IOSurface=3;
      TextureType_DirectX12=4;
      TextureType_DXGISharedHandle=5;
      TextureType_Metal=6;

      ColorSpace_Auto=0;
      ColorSpace_Gamma=1;
      ColorSpace_Linear=2;

      TrackingResult_Uninitialized=1;
      TrackingResult_Calibrating_InProgress=100;
      TrackingResult_Calibrating_OutOfRange=101;
      TrackingResult_Running_OK=200;
      TrackingResult_Running_OutOfRange=201;
      TrackingResult_Fallback_RotationOnly=300;

      TrackedDeviceClass_Invalid=0;
      TrackedDeviceClass_HMD=1;
      TrackedDeviceClass_Controller=2;
      TrackedDeviceClass_GenericTracker=3;
      TrackedDeviceClass_TrackingReference=4;
      TrackedDeviceClass_DisplayRedirect=5;
      TrackedDeviceClass_Max=6;

      TrackedControllerRole_Invalid=0;
      TrackedControllerRole_LeftHand=1;
      TrackedControllerRole_RightHand=2;
      TrackedControllerRole_OptOut=3;
      TrackedControllerRole_Max=4;

      TrackingUniverseSeated=0;
      TrackingUniverseStanding=1;
      TrackingUniverseOrigin_TrackingUniverseRawAndUncalibrated=2;

      Prop_Invalid=0;
      Prop_TrackingSystemName_String=1000;
      Prop_ModelNumber_String=1001;
      Prop_SerialNumber_String=1002;
      Prop_RenderModelName_String=1003;
      Prop_WillDriftInYaw_Bool=1004;
      Prop_ManufacturerName_String=1005;
      Prop_TrackingFirmwareVersion_String=1006;
      Prop_HardwareRevision_String=1007;
      Prop_AllWirelessDongleDescriptions_String=1008;
      Prop_ConnectedWirelessDongle_String=1009;
      Prop_DeviceIsWireless_Bool=1010;
      Prop_DeviceIsCharging_Bool=1011;
      Prop_DeviceBatteryPercentage_Float=1012;
      Prop_StatusDisplayTransform_Matrix34=1013;
      Prop_Firmware_UpdateAvailable_Bool=1014;
      Prop_Firmware_ManualUpdate_Bool=1015;
      Prop_Firmware_ManualUpdateURL_String=1016;
      Prop_HardwareRevision_Uint64=1017;
      Prop_FirmwareVersion_Uint64=1018;
      Prop_FPGAVersion_Uint64=1019;
      Prop_VRCVersion_Uint64=1020;
      Prop_RadioVersion_Uint64=1021;
      Prop_DongleVersion_Uint64=1022;
      Prop_BlockServerShutdown_Bool=1023;
      Prop_CanUnifyCoordinateSystemWithHmd_Bool=1024;
      Prop_ContainsProximitySensor_Bool=1025;
      Prop_DeviceProvidesBatteryStatus_Bool=1026;
      Prop_DeviceCanPowerOff_Bool=1027;
      Prop_Firmware_ProgrammingTarget_String=1028;
      Prop_DeviceClass_Int32=1029;
      Prop_HasCamera_Bool=1030;
      Prop_DriverVersion_String=1031;
      Prop_Firmware_ForceUpdateRequired_Bool=1032;
      Prop_ViveSystemButtonFixRequired_Bool=1033;
      Prop_ParentDriver_Uint64=1034;
      Prop_ResourceRoot_String=1035;
      Prop_RegisteredDeviceType_String=1036;
      Prop_InputProfilePath_String=1037;
      Prop_NeverTracked_Bool=1038;
      Prop_NumCameras_Int32=1039;
      Prop_CameraFrameLayout_Int32=1040;
      Prop_CameraStreamFormat_Int32=1041;
      Prop_ReportsTimeSinceVSync_Bool=2000;
      Prop_SecondsFromVsyncToPhotons_Float=2001;
      Prop_DisplayFrequency_Float=2002;
      Prop_UserIpdMeters_Float=2003;
      Prop_CurrentUniverseId_Uint64=2004;
      Prop_PreviousUniverseId_Uint64=2005;
      Prop_DisplayFirmwareVersion_Uint64=2006;
      Prop_IsOnDesktop_Bool=2007;
      Prop_DisplayMCType_Int32=2008;
      Prop_DisplayMCOffset_Float=2009;
      Prop_DisplayMCScale_Float=2010;
      Prop_EdidVendorID_Int32=2011;
      Prop_DisplayMCImageLeft_String=2012;
      Prop_DisplayMCImageRight_String=2013;
      Prop_DisplayGCBlackClamp_Float=2014;
      Prop_EdidProductID_Int32=2015;
      Prop_CameraToHeadTransform_Matrix34=2016;
      Prop_DisplayGCType_Int32=2017;
      Prop_DisplayGCOffset_Float=2018;
      Prop_DisplayGCScale_Float=2019;
      Prop_DisplayGCPrescale_Float=2020;
      Prop_DisplayGCImage_String=2021;
      Prop_LensCenterLeftU_Float=2022;
      Prop_LensCenterLeftV_Float=2023;
      Prop_LensCenterRightU_Float=2024;
      Prop_LensCenterRightV_Float=2025;
      Prop_UserHeadToEyeDepthMeters_Float=2026;
      Prop_CameraFirmwareVersion_Uint64=2027;
      Prop_CameraFirmwareDescription_String=2028;
      Prop_DisplayFPGAVersion_Uint64=2029;
      Prop_DisplayBootloaderVersion_Uint64=2030;
      Prop_DisplayHardwareVersion_Uint64=2031;
      Prop_AudioFirmwareVersion_Uint64=2032;
      Prop_CameraCompatibilityMode_Int32=2033;
      Prop_ScreenshotHorizontalFieldOfViewDegrees_Float=2034;
      Prop_ScreenshotVerticalFieldOfViewDegrees_Float=2035;
      Prop_DisplaySuppressed_Bool=2036;
      Prop_DisplayAllowNightMode_Bool=2037;
      Prop_DisplayMCImageWidth_Int32=2038;
      Prop_DisplayMCImageHeight_Int32=2039;
      Prop_DisplayMCImageNumChannels_Int32=2040;
      Prop_DisplayMCImageData_Binary=2041;
      Prop_SecondsFromPhotonsToVblank_Float=2042;
      Prop_DriverDirectModeSendsVsyncEvents_Bool=2043;
      Prop_DisplayDebugMode_Bool=2044;
      Prop_GraphicsAdapterLuid_Uint64=2045;
      Prop_DriverProvidedChaperonePath_String=2048;
      Prop_ExpectedTrackingReferenceCount_Int32=2049;
      Prop_ExpectedControllerCount_Int32=2050;
      Prop_NamedIconPathControllerLeftDeviceOff_String=2051;
      Prop_NamedIconPathControllerRightDeviceOff_String=2052;
      Prop_NamedIconPathTrackingReferenceDeviceOff_String=2053;
      Prop_DoNotApplyPrediction_Bool=2054;
      Prop_CameraToHeadTransforms_Matrix34_Array=2055;
      Prop_DistortionMeshResolution_Int32=2056;
      Prop_DriverIsDrawingControllers_Bool=2057;
      Prop_DriverRequestsApplicationPause_Bool=2058;
      Prop_DriverRequestsReducedRendering_Bool=2059;
      Prop_MinimumIpdStepMeters_Float=2060;
      Prop_AudioBridgeFirmwareVersion_Uint64=2061;
      Prop_ImageBridgeFirmwareVersion_Uint64=2062;
      Prop_ImuToHeadTransform_Matrix34=2063;
      Prop_ImuFactoryGyroBias_Vector3=2064;
      Prop_ImuFactoryGyroScale_Vector3=2065;
      Prop_ImuFactoryAccelerometerBias_Vector3=2066;
      Prop_ImuFactoryAccelerometerScale_Vector3=2067;
      Prop_ConfigurationIncludesLighthouse20Features_Bool=2069;
      Prop_DriverRequestedMuraCorrectionMode_Int32=2200;
      Prop_DriverRequestedMuraFeather_InnerLeft_Int32=2201;
      Prop_DriverRequestedMuraFeather_InnerRight_Int32=2202;
      Prop_DriverRequestedMuraFeather_InnerTop_Int32=2203;
      Prop_DriverRequestedMuraFeather_InnerBottom_Int32=2204;
      Prop_DriverRequestedMuraFeather_OuterLeft_Int32=2205;
      Prop_DriverRequestedMuraFeather_OuterRight_Int32=2206;
      Prop_DriverRequestedMuraFeather_OuterTop_Int32=2207;
      Prop_DriverRequestedMuraFeather_OuterBottom_Int32=2208;
      Prop_AttachedDeviceId_String=3000;
      Prop_SupportedButtons_Uint64=3001;
      Prop_Axis0Type_Int32=3002;
      Prop_Axis1Type_Int32=3003;
      Prop_Axis2Type_Int32=3004;
      Prop_Axis3Type_Int32=3005;
      Prop_Axis4Type_Int32=3006;
      Prop_ControllerRoleHint_Int32=3007;
      Prop_FieldOfViewLeftDegrees_Float=4000;
      Prop_FieldOfViewRightDegrees_Float=4001;
      Prop_FieldOfViewTopDegrees_Float=4002;
      Prop_FieldOfViewBottomDegrees_Float=4003;
      Prop_TrackingRangeMinimumMeters_Float=4004;
      Prop_TrackingRangeMaximumMeters_Float=4005;
      Prop_ModeLabel_String=4006;
      Prop_IconPathName_String=5000;
      Prop_NamedIconPathDeviceOff_String=5001;
      Prop_NamedIconPathDeviceSearching_String=5002;
      Prop_NamedIconPathDeviceSearchingAlert_String=5003;
      Prop_NamedIconPathDeviceReady_String=5004;
      Prop_NamedIconPathDeviceReadyAlert_String=5005;
      Prop_NamedIconPathDeviceNotReady_String=5006;
      Prop_NamedIconPathDeviceStandby_String=5007;
      Prop_NamedIconPathDeviceAlertLow_String=5008;
      Prop_DisplayHiddenArea_Binary_Start=5100;
      Prop_DisplayHiddenArea_Binary_End=5150;
      Prop_ParentContainer=5151;
      Prop_UserConfigPath_String=6000;
      Prop_InstallPath_String=6001;
      Prop_HasDisplayComponent_Bool=6002;
      Prop_HasControllerComponent_Bool=6003;
      Prop_HasCameraComponent_Bool=6004;
      Prop_HasDriverDirectModeComponent_Bool=6005;
      Prop_HasVirtualDisplayComponent_Bool=6006;
      Prop_HasSpatialAnchorsSupport_Bool=6007;
      Prop_ControllerType_String=7000;
      Prop_LegacyInputProfile_String=7001;
      Prop_ControllerHandSelectionPriority_Int32=7002;
      Prop_VendorSpecific_Reserved_Start=10000;
      Prop_VendorSpecific_Reserved_End=10999;
      Prop_TrackedDeviceProperty_Max=1000000;

      TrackedProp_Success=0;
      TrackedProp_WrongDataType=1;
      TrackedProp_WrongDeviceClass=2;
      TrackedProp_BufferTooSmall=3;
      TrackedProp_UnknownProperty=4;
      TrackedProp_InvalidDevice=5;
      TrackedProp_CouldNotContactServer=6;
      TrackedProp_ValueNotProvidedByDevice=7;
      TrackedProp_StringExceedsMaximumLength=8;
      TrackedProp_NotYetAvailable=9;
      TrackedProp_PermissionDenied=10;
      TrackedProp_InvalidOperation=11;
      TrackedProp_CannotWriteToWildcards=12;
      TrackedProp_IPCReadFailure=13;

      Submit_Default=0;
      Submit_LensDistortionAlreadyApplied=1;
      Submit_GlRenderBuffer=2;
      Submit_Reserved=4;
      Submit_TextureWithPose=8;
      Submit_TextureWithDepth=16;

      VRState_Undefined=-1;
      VRState_Off=0;
      VRState_Searching=1;
      VRState_Searching_Alert=2;
      VRState_Ready=3;
      VRState_Ready_Alert=4;
      VRState_NotReady=5;
      VRState_Standby=6;
      VRState_Ready_Alert_Low=7;

      VREvent_None=0;
      VREvent_TrackedDeviceActivated=100;
      VREvent_TrackedDeviceDeactivated=101;
      VREvent_TrackedDeviceUpdated=102;
      VREvent_TrackedDeviceUserInteractionStarted=103;
      VREvent_TrackedDeviceUserInteractionEnded=104;
      VREvent_IpdChanged=105;
      VREvent_EnterStandbyMode=106;
      VREvent_LeaveStandbyMode=107;
      VREvent_TrackedDeviceRoleChanged=108;
      VREvent_WatchdogWakeUpRequested=109;
      VREvent_LensDistortionChanged=110;
      VREvent_PropertyChanged=111;
      VREvent_WirelessDisconnect=112;
      VREvent_WirelessReconnect=113;
      VREvent_ButtonPress=200;
      VREvent_ButtonUnpress=201;
      VREvent_ButtonTouch=202;
      VREvent_ButtonUntouch=203;
      VREvent_DualAnalog_Press=250;
      VREvent_DualAnalog_Unpress=251;
      VREvent_DualAnalog_Touch=252;
      VREvent_DualAnalog_Untouch=253;
      VREvent_DualAnalog_Move=254;
      VREvent_DualAnalog_ModeSwitch1=255;
      VREvent_DualAnalog_ModeSwitch2=256;
      VREvent_DualAnalog_Cancel=257;
      VREvent_MouseMove=300;
      VREvent_MouseButtonDown=301;
      VREvent_MouseButtonUp=302;
      VREvent_FocusEnter=303;
      VREvent_FocusLeave=304;
      VREvent_Scroll=305;
      VREvent_TouchPadMove=306;
      VREvent_OverlayFocusChanged=307;
      VREvent_InputFocusCaptured=400;
      VREvent_InputFocusReleased=401;
      VREvent_SceneFocusLost=402;
      VREvent_SceneFocusGained=403;
      VREvent_SceneApplicationChanged=404;
      VREvent_SceneFocusChanged=405;
      VREvent_InputFocusChanged=406;
      VREvent_SceneApplicationSecondaryRenderingStarted=407;
      VREvent_SceneApplicationUsingWrongGraphicsAdapter=408;
      VREvent_ActionBindingReloaded=409;
      VREvent_HideRenderModels=410;
      VREvent_ShowRenderModels=411;
      VREvent_ConsoleOpened=420;
      VREvent_ConsoleClosed=421;
      VREvent_OverlayShown=500;
      VREvent_OverlayHidden=501;
      VREvent_DashboardActivated=502;
      VREvent_DashboardDeactivated=503;
      VREvent_DashboardThumbSelected=504;
      VREvent_DashboardRequested=505;
      VREvent_ResetDashboard=506;
      VREvent_RenderToast=507;
      VREvent_ImageLoaded=508;
      VREvent_ShowKeyboard=509;
      VREvent_HideKeyboard=510;
      VREvent_OverlayGamepadFocusGained=511;
      VREvent_OverlayGamepadFocusLost=512;
      VREvent_OverlaySharedTextureChanged=513;
      VREvent_ScreenshotTriggered=516;
      VREvent_ImageFailed=517;
      VREvent_DashboardOverlayCreated=518;
      VREvent_SwitchGamepadFocus=519;
      VREvent_RequestScreenshot=520;
      VREvent_ScreenshotTaken=521;
      VREvent_ScreenshotFailed=522;
      VREvent_SubmitScreenshotToDashboard=523;
      VREvent_ScreenshotProgressToDashboard=524;
      VREvent_PrimaryDashboardDeviceChanged=525;
      VREvent_RoomViewShown=526;
      VREvent_RoomViewHidden=527;
      VREvent_Notification_Shown=600;
      VREvent_Notification_Hidden=601;
      VREvent_Notification_BeginInteraction=602;
      VREvent_Notification_Destroyed=603;
      VREvent_Quit=700;
      VREvent_ProcessQuit=701;
      VREvent_QuitAborted_UserPrompt=702;
      VREvent_QuitAcknowledged=703;
      VREvent_DriverRequestedQuit=704;
      VREvent_ChaperoneDataHasChanged=800;
      VREvent_ChaperoneUniverseHasChanged=801;
      VREvent_ChaperoneTempDataHasChanged=802;
      VREvent_ChaperoneSettingsHaveChanged=803;
      VREvent_SeatedZeroPoseReset=804;
      VREvent_AudioSettingsHaveChanged=820;
      VREvent_BackgroundSettingHasChanged=850;
      VREvent_CameraSettingsHaveChanged=851;
      VREvent_ReprojectionSettingHasChanged=852;
      VREvent_ModelSkinSettingsHaveChanged=853;
      VREvent_EnvironmentSettingsHaveChanged=854;
      VREvent_PowerSettingsHaveChanged=855;
      VREvent_EnableHomeAppSettingsHaveChanged=856;
      VREvent_SteamVRSectionSettingChanged=857;
      VREvent_LighthouseSectionSettingChanged=858;
      VREvent_NullSectionSettingChanged=859;
      VREvent_UserInterfaceSectionSettingChanged=860;
      VREvent_NotificationsSectionSettingChanged=861;
      VREvent_KeyboardSectionSettingChanged=862;
      VREvent_PerfSectionSettingChanged=863;
      VREvent_DashboardSectionSettingChanged=864;
      VREvent_WebInterfaceSectionSettingChanged=865;
      VREvent_TrackersSectionSettingChanged=866;
      VREvent_StatusUpdate=900;
      VREvent_WebInterface_InstallDriverCompleted=950;
      VREvent_MCImageUpdated=1000;
      VREvent_FirmwareUpdateStarted=1100;
      VREvent_FirmwareUpdateFinished=1101;
      VREvent_KeyboardClosed=1200;
      VREvent_KeyboardCharInput=1201;
      VREvent_KeyboardDone=1202;
      VREvent_ApplicationTransitionStarted=1300;
      VREvent_ApplicationTransitionAborted=1301;
      VREvent_ApplicationTransitionNewAppStarted=1302;
      VREvent_ApplicationListUpdated=1303;
      VREvent_ApplicationMimeTypeLoad=1304;
      VREvent_ApplicationTransitionNewAppLaunchComplete=1305;
      VREvent_ProcessConnected=1306;
      VREvent_ProcessDisconnected=1307;
      VREvent_Compositor_MirrorWindowShown=1400;
      VREvent_Compositor_MirrorWindowHidden=1401;
      VREvent_Compositor_ChaperoneBoundsShown=1410;
      VREvent_Compositor_ChaperoneBoundsHidden=1411;
      VREvent_TrackedCamera_StartVideoStream=1500;
      VREvent_TrackedCamera_StopVideoStream=1501;
      VREvent_TrackedCamera_PauseVideoStream=1502;
      VREvent_TrackedCamera_ResumeVideoStream=1503;
      VREvent_TrackedCamera_EditingSurface=1550;
      VREvent_PerformanceTest_EnableCapture=1600;
      VREvent_PerformanceTest_DisableCapture=1601;
      VREvent_PerformanceTest_FidelityLevel=1602;
      VREvent_MessageOverlay_Closed=1650;
      VREvent_MessageOverlayCloseRequested=1651;
      VREvent_Input_HapticVibration=1700;
      VREvent_Input_BindingLoadFailed=1701;
      VREvent_Input_BindingLoadSuccessful=1702;
      VREvent_Input_ActionManifestReloaded=1703;
      VREvent_Input_ActionManifestLoadFailed=1704;
      VREvent_Input_TrackerActivated=1706;
      VREvent_SpatialAnchors_PoseUpdated=1800;
      VREvent_SpatialAnchors_DescriptorUpdated=1801;
      VREvent_SpatialAnchors_RequestPoseUpdate=1802;
      VREvent_SpatialAnchors_RequestDescriptorUpdate=1803;
      VREvent_VendorSpecific_Reserved_Start=10000;
      VREvent_VendorSpecific_Reserved_End=19999;

      k_EDeviceActivityLevel_Unknown=-1;
      k_EDeviceActivityLevel_Idle=0;
      k_EDeviceActivityLevel_UserInteraction=1;
      k_EDeviceActivityLevel_UserInteraction_Timeout=2;
      k_EDeviceActivityLevel_Standby=3;

      k_EButton_System=0;
      k_EButton_ApplicationMenu=1;
      k_EButton_Grip=2;
      k_EButton_DPad_Left=3;
      k_EButton_DPad_Up=4;
      k_EButton_DPad_Right=5;
      k_EButton_DPad_Down=6;
      k_EButton_A=7;
      k_EButton_ProximitySensor=31;
      k_EButton_Axis0=32;
      k_EButton_Axis1=33;
      k_EButton_Axis2=34;
      k_EButton_Axis3=35;
      k_EButton_Axis4=36;
      k_EButton_SteamVR_Touchpad=32;
      k_EButton_SteamVR_Trigger=33;
      k_EButton_Dashboard_Back=2;
      k_EButton_Knuckles_A=2;
      k_EButton_Knuckles_B=1;
      k_EButton_Knuckles_JoyStick=35;
      k_EButton_Max=64;

      VRMouseButton_Left=1;
      VRMouseButton_Right=2;
      VRMouseButton_Middle=4;

      k_EDualAnalog_Left=0;
      k_EDualAnalog_Right=1;

      VRInputError_None=0;
      VRInputError_NameNotFound=1;
      VRInputError_WrongType=2;
      VRInputError_InvalidHandle=3;
      VRInputError_InvalidParam=4;
      VRInputError_NoSteam=5;
      VRInputError_MaxCapacityReached=6;
      VRInputError_IPCError=7;
      VRInputError_NoActiveActionSet=8;
      VRInputError_InvalidDevice=9;
      VRInputError_InvalidSkeleton=10;
      VRInputError_InvalidBoneCount=11;
      VRInputError_InvalidCompressedData=12;
      VRInputError_NoData=13;
      VRInputError_BufferTooSmall=14;
      VRInputError_MismatchedActionManifest=15;
      VRInputError_MissingSkeletonData=16;

      VRSpatialAnchorError_Success=0;
      VRSpatialAnchorError_Internal=1;
      VRSpatialAnchorError_UnknownHandle=2;
      VRSpatialAnchorError_ArrayTooSmall=3;
      VRSpatialAnchorError_InvalidDescriptorChar=4;
      VRSpatialAnchorError_NotYetAvailable=5;
      VRSpatialAnchorError_NotAvailableInThisUniverse=6;
      VRSpatialAnchorError_PermanentlyUnavailable=7;
      VRSpatialAnchorError_WrongDriver=8;
      VRSpatialAnchorError_DescriptorTooLong=9;
      VRSpatialAnchorError_Unknown=10;
      VRSpatialAnchorError_NoRoomCalibration=11;
      VRSpatialAnchorError_InvalidArgument=12;
      VRSpatialAnchorError_UnknownDriver=13;

      k_eHiddenAreaMesh_Standard=0;
      k_eHiddenAreaMesh_Inverse=1;
      k_eHiddenAreaMesh_LineLoop=2;
      k_eHiddenAreaMesh_Max=3;

      k_eControllerAxis_None=0;
      k_eControllerAxis_TrackPad=1;
      k_eControllerAxis_Joystick=2;
      k_eControllerAxis_Trigger=3;

      ControllerEventOutput_OSEvents=0;
      ControllerEventOutput_VREvents=1;

      COLLISION_BOUNDS_STYLE_BEGINNER=0;
      COLLISION_BOUNDS_STYLE_INTERMEDIATE=1;
      COLLISION_BOUNDS_STYLE_SQUARES=2;
      COLLISION_BOUNDS_STYLE_ADVANCED=3;
      COLLISION_BOUNDS_STYLE_NONE=4;
      COLLISION_BOUNDS_STYLE_COUNT=5;

      VROverlayError_None=0;
      VROverlayError_UnknownOverlay=10;
      VROverlayError_InvalidHandle=11;
      VROverlayError_PermissionDenied=12;
      VROverlayError_OverlayLimitExceeded=13;
      VROverlayError_WrongVisibilityType=14;
      VROverlayError_KeyTooLong=15;
      VROverlayError_NameTooLong=16;
      VROverlayError_KeyInUse=17;
      VROverlayError_WrongTransformType=18;
      VROverlayError_InvalidTrackedDevice=19;
      VROverlayError_InvalidParameter=20;
      VROverlayError_ThumbnailCantBeDestroyed=21;
      VROverlayError_ArrayTooSmall=22;
      VROverlayError_RequestFailed=23;
      VROverlayError_InvalidTexture=24;
      VROverlayError_UnableToLoadFile=25;
      VROverlayError_KeyboardAlreadyInUse=26;
      VROverlayError_NoNeighbor=27;
      VROverlayError_TooManyMaskPrimitives=29;
      VROverlayError_BadMaskPrimitive=30;
      VROverlayError_TextureAlreadyLocked=31;
      VROverlayError_TextureLockCapacityReached=32;
      VROverlayError_TextureNotLocked=33;

      VRApplication_Other=0;
      VRApplication_Scene=1;
      VRApplication_Overlay=2;
      VRApplication_Background=3;
      VRApplication_Utility=4;
      VRApplication_VRMonitor=5;
      VRApplication_SteamWatchdog=6;
      VRApplication_Bootstrapper=7;
      VRApplication_Max=8;

      VRFirmwareError_None=0;
      VRFirmwareError_Success=1;
      VRFirmwareError_Fail=2;

      VRNotificationError_OK=0;
      VRNotificationError_InvalidNotificationId=100;
      VRNotificationError_NotificationQueueFull=101;
      VRNotificationError_InvalidOverlayHandle=102;
      VRNotificationError_SystemWithUserValueAlreadyExists=103;

      VRSkeletalMotionRange_WithController=0;
      VRSkeletalMotionRange_WithoutController=1;

      VRInitError_None=0;
      VRInitError_Unknown=1;
      VRInitError_Init_InstallationNotFound=100;
      VRInitError_Init_InstallationCorrupt=101;
      VRInitError_Init_VRClientDLLNotFound=102;
      VRInitError_Init_FileNotFound=103;
      VRInitError_Init_FactoryNotFound=104;
      VRInitError_Init_InterfaceNotFound=105;
      VRInitError_Init_InvalidInterface=106;
      VRInitError_Init_UserConfigDirectoryInvalid=107;
      VRInitError_Init_HmdNotFound=108;
      VRInitError_Init_NotInitialized=109;
      VRInitError_Init_PathRegistryNotFound=110;
      VRInitError_Init_NoConfigPath=111;
      VRInitError_Init_NoLogPath=112;
      VRInitError_Init_PathRegistryNotWritable=113;
      VRInitError_Init_AppInfoInitFailed=114;
      VRInitError_Init_Retry=115;
      VRInitError_Init_InitCanceledByUser=116;
      VRInitError_Init_AnotherAppLaunching=117;
      VRInitError_Init_SettingsInitFailed=118;
      VRInitError_Init_ShuttingDown=119;
      VRInitError_Init_TooManyObjects=120;
      VRInitError_Init_NoServerForBackgroundApp=121;
      VRInitError_Init_NotSupportedWithCompositor=122;
      VRInitError_Init_NotAvailableToUtilityApps=123;
      VRInitError_Init_Internal=124;
      VRInitError_Init_HmdDriverIdIsNone=125;
      VRInitError_Init_HmdNotFoundPresenceFailed=126;
      VRInitError_Init_VRMonitorNotFound=127;
      VRInitError_Init_VRMonitorStartupFailed=128;
      VRInitError_Init_LowPowerWatchdogNotSupported=129;
      VRInitError_Init_InvalidApplicationType=130;
      VRInitError_Init_NotAvailableToWatchdogApps=131;
      VRInitError_Init_WatchdogDisabledInSettings=132;
      VRInitError_Init_VRDashboardNotFound=133;
      VRInitError_Init_VRDashboardStartupFailed=134;
      VRInitError_Init_VRHomeNotFound=135;
      VRInitError_Init_VRHomeStartupFailed=136;
      VRInitError_Init_RebootingBusy=137;
      VRInitError_Init_FirmwareUpdateBusy=138;
      VRInitError_Init_FirmwareRecoveryBusy=139;
      VRInitError_Init_USBServiceBusy=140;
      VRInitError_Init_VRWebHelperStartupFailed=141;
      VRInitError_Init_TrackerManagerInitFailed=142;
      VRInitError_Driver_Failed=200;
      VRInitError_Driver_Unknown=201;
      VRInitError_Driver_HmdUnknown=202;
      VRInitError_Driver_NotLoaded=203;
      VRInitError_Driver_RuntimeOutOfDate=204;
      VRInitError_Driver_HmdInUse=205;
      VRInitError_Driver_NotCalibrated=206;
      VRInitError_Driver_CalibrationInvalid=207;
      VRInitError_Driver_HmdDisplayNotFound=208;
      VRInitError_Driver_TrackedDeviceInterfaceUnknown=209;
      VRInitError_Driver_HmdDriverIdOutOfBounds=211;
      VRInitError_Driver_HmdDisplayMirrored=212;
      VRInitError_IPC_ServerInitFailed=300;
      VRInitError_IPC_ConnectFailed=301;
      VRInitError_IPC_SharedStateInitFailed=302;
      VRInitError_IPC_CompositorInitFailed=303;
      VRInitError_IPC_MutexInitFailed=304;
      VRInitError_IPC_Failed=305;
      VRInitError_IPC_CompositorConnectFailed=306;
      VRInitError_IPC_CompositorInvalidConnectResponse=307;
      VRInitError_IPC_ConnectFailedAfterMultipleAttempts=308;
      VRInitError_Compositor_Failed=400;
      VRInitError_Compositor_D3D11HardwareRequired=401;
      VRInitError_Compositor_FirmwareRequiresUpdate=402;
      VRInitError_Compositor_OverlayInitFailed=403;
      VRInitError_Compositor_ScreenshotsInitFailed=404;
      VRInitError_Compositor_UnableToCreateDevice=405;
      VRInitError_VendorSpecific_UnableToConnectToOculusRuntime=1000;
      VRInitError_VendorSpecific_WindowsNotInDevMode=1001;
      VRInitError_VendorSpecific_HmdFound_CantOpenDevice=1101;
      VRInitError_VendorSpecific_HmdFound_UnableToRequestConfigStart=1102;
      VRInitError_VendorSpecific_HmdFound_NoStoredConfig=1103;
      VRInitError_VendorSpecific_HmdFound_ConfigTooBig=1104;
      VRInitError_VendorSpecific_HmdFound_ConfigTooSmall=1105;
      VRInitError_VendorSpecific_HmdFound_UnableToInitZLib=1106;
      VRInitError_VendorSpecific_HmdFound_CantReadFirmwareVersion=1107;
      VRInitError_VendorSpecific_HmdFound_UnableToSendUserDataStart=1108;
      VRInitError_VendorSpecific_HmdFound_UnableToGetUserDataStart=1109;
      VRInitError_VendorSpecific_HmdFound_UnableToGetUserDataNext=1110;
      VRInitError_VendorSpecific_HmdFound_UserDataAddressRange=1111;
      VRInitError_VendorSpecific_HmdFound_UserDataError=1112;
      VRInitError_VendorSpecific_HmdFound_ConfigFailedSanityCheck=1113;
      VRInitError_Steam_SteamInstallationNotFound=2000;

      VRScreenshotType_None=0;
      VRScreenshotType_Mono=1;
      VRScreenshotType_Stereo=2;
      VRScreenshotType_Cubemap=3;
      VRScreenshotType_MonoPanorama=4;
      VRScreenshotType_StereoPanorama=5;

      VRScreenshotPropertyFilenames_Preview=0;
      VRScreenshotPropertyFilenames_VR=1;

      VRTrackedCameraError_None=0;
      VRTrackedCameraError_OperationFailed=100;
      VRTrackedCameraError_InvalidHandle=101;
      VRTrackedCameraError_InvalidFrameHeaderVersion=102;
      VRTrackedCameraError_OutOfHandles=103;
      VRTrackedCameraError_IPCFailure=104;
      VRTrackedCameraError_NotSupportedForThisDevice=105;
      VRTrackedCameraError_SharedMemoryFailure=106;
      VRTrackedCameraError_FrameBufferingFailure=107;
      VRTrackedCameraError_StreamSetupFailure=108;
      VRTrackedCameraError_InvalidGLTextureId=109;
      VRTrackedCameraError_InvalidSharedTextureHandle=110;
      VRTrackedCameraError_FailedToGetGLTextureId=111;
      VRTrackedCameraError_SharedTextureFailure=112;
      VRTrackedCameraError_NoFrameAvailable=113;
      VRTrackedCameraError_InvalidArgument=114;
      VRTrackedCameraError_InvalidFrameBufferSize=115;

      Mono=1;
      Stereo=2;
      VerticalLayout=16;
      HorizontalLayout=32;

      VRTrackedCameraFrameType_Distorted=0;
      VRTrackedCameraFrameType_Undistorted=1;
      VRTrackedCameraFrameType_MaximumUndistorted=2;
      MAX_CAMERA_FRAME_TYPES=3;

      VSync_None=0;
      VSync_WaitRender=1;
      VSync_NoWaitRender=2;

      EVRMuraCorrectionMode_Default=0;
      EVRMuraCorrectionMode_NoCorrection=1;

      OffScale_AccelX=1;
      OffScale_AccelY=2;
      OffScale_AccelZ=4;
      OffScale_GyroX=8;
      OffScale_GyroY=16;
      OffScale_GyroZ=32;

      VRApplicationError_None=0;
      VRApplicationError_AppKeyAlreadyExists=100;
      VRApplicationError_NoManifest=101;
      VRApplicationError_NoApplication=102;
      VRApplicationError_InvalidIndex=103;
      VRApplicationError_UnknownApplication=104;
      VRApplicationError_IPCFailed=105;
      VRApplicationError_ApplicationAlreadyRunning=106;
      VRApplicationError_InvalidManifest=107;
      VRApplicationError_InvalidApplication=108;
      VRApplicationError_LaunchFailed=109;
      VRApplicationError_ApplicationAlreadyStarting=110;
      VRApplicationError_LaunchInProgress=111;
      VRApplicationError_OldApplicationQuitting=112;
      VRApplicationError_TransitionAborted=113;
      VRApplicationError_IsTemplate=114;
      VRApplicationError_SteamVRIsExiting=115;
      VRApplicationError_BufferTooSmall=200;
      VRApplicationError_PropertyNotSet=201;
      VRApplicationError_UnknownProperty=202;
      VRApplicationError_InvalidParameter=203;

      VRApplicationProperty_Name_String=0;
      VRApplicationProperty_LaunchType_String=11;
      VRApplicationProperty_WorkingDirectory_String=12;
      VRApplicationProperty_BinaryPath_String=13;
      VRApplicationProperty_Arguments_String=14;
      VRApplicationProperty_URL_String=15;
      VRApplicationProperty_Description_String=50;
      VRApplicationProperty_NewsURL_String=51;
      VRApplicationProperty_ImagePath_String=52;
      VRApplicationProperty_Source_String=53;
      VRApplicationProperty_ActionManifestURL_String=54;
      VRApplicationProperty_IsDashboardOverlay_Bool=60;
      VRApplicationProperty_IsTemplate_Bool=61;
      VRApplicationProperty_IsInstanced_Bool=62;
      VRApplicationProperty_IsInternal_Bool=63;
      VRApplicationProperty_WantsCompositorPauseInStandby_Bool=64;
      VRApplicationProperty_LastLaunchTime_Uint64=70;

      VRApplicationTransition_None=0;
      VRApplicationTransition_OldAppQuitSent=10;
      VRApplicationTransition_WaitingForExternalLaunch=11;
      VRApplicationTransition_NewAppLaunched=20;

      ChaperoneCalibrationState_OK=1;
      ChaperoneCalibrationState_Warning=100;
      ChaperoneCalibrationState_Warning_BaseStationMayHaveMoved=101;
      ChaperoneCalibrationState_Warning_BaseStationRemoved=102;
      ChaperoneCalibrationState_Warning_SeatedBoundsInvalid=103;
      ChaperoneCalibrationState_Error=200;
      ChaperoneCalibrationState_Error_BaseStationUninitialized=201;
      ChaperoneCalibrationState_Error_BaseStationConflict=202;
      ChaperoneCalibrationState_Error_PlayAreaInvalid=203;
      ChaperoneCalibrationState_Error_CollisionBoundsInvalid=204;

      Live=1;
      Temp=2;

      EChaperoneImport_BoundsOnly=1;

      VRCompositorError_None=0;
      VRCompositorError_RequestFailed=1;
      VRCompositorError_IncompatibleVersion=100;
      VRCompositorError_DoNotHaveFocus=101;
      VRCompositorError_InvalidTexture=102;
      VRCompositorError_IsNotSceneApplication=103;
      VRCompositorError_TextureIsOnWrongDevice=104;
      VRCompositorError_TextureUsesUnsupportedFormat=105;
      VRCompositorError_SharedTexturesNotSupported=106;
      VRCompositorError_IndexOutOfRange=107;
      VRCompositorError_AlreadySubmitted=108;
      VRCompositorError_InvalidBounds=109;

      VRCompositorTimingMode_Implicit=0;
      VRCompositorTimingMode_Explicit_RuntimePerformsPostPresentHandoff=1;
      VRCompositorTimingMode_Explicit_ApplicationPerformsPostPresentHandoff=2;

      VROverlayInputMethod_None=0;
      VROverlayInputMethod_Mouse=1;
      VROverlayInputMethod_DualAnalog=2;

      VROverlayTransform_Absolute=0;
      VROverlayTransform_TrackedDeviceRelative=1;
      VROverlayTransform_SystemOverlay=2;
      VROverlayTransform_TrackedComponent=3;

      VROverlayFlags_None=0;
      VROverlayFlags_Curved=1;
      VROverlayFlags_RGSS4X=2;
      VROverlayFlags_NoDashboardTab=3;
      VROverlayFlags_AcceptsGamepadEvents=4;
      VROverlayFlags_ShowGamepadFocus=5;
      VROverlayFlags_SendVRScrollEvents=6;
      VROverlayFlags_SendVRTouchpadEvents=7;
      VROverlayFlags_ShowTouchPadScrollWheel=8;
      VROverlayFlags_TransferOwnershipToInternalProcess=9;
      VROverlayFlags_SideBySide_Parallel=10;
      VROverlayFlags_SideBySide_Crossed=11;
      VROverlayFlags_Panorama=12;
      VROverlayFlags_StereoPanorama=13;
      VROverlayFlags_SortWithNonSceneOverlays=14;
      VROverlayFlags_VisibleInDashboard=15;

      VRMessageOverlayResponse_ButtonPress_0=0;
      VRMessageOverlayResponse_ButtonPress_1=1;
      VRMessageOverlayResponse_ButtonPress_2=2;
      VRMessageOverlayResponse_ButtonPress_3=3;
      VRMessageOverlayResponse_CouldntFindSystemOverlay=4;
      VRMessageOverlayResponse_CouldntFindOrCreateClientOverlay=5;
      VRMessageOverlayResponse_ApplicationQuit=6;

      k_EGamepadTextInputModeNormal=0;
      k_EGamepadTextInputModePassword=1;
      k_EGamepadTextInputModeSubmit=2;

      k_EGamepadTextInputLineModeSingleLine=0;
      k_EGamepadTextInputLineModeMultipleLines=1;

      OverlayDirection_Up=0;
      OverlayDirection_Down=1;
      OverlayDirection_Left=2;
      OverlayDirection_Right=3;
      OverlayDirection_Count=4;

      OverlayIntersectionPrimitiveType_Rectangle=0;
      OverlayIntersectionPrimitiveType_Circle=1;

      VRRenderModelError_None=0;
      VRRenderModelError_Loading=100;
      VRRenderModelError_NotSupported=200;
      VRRenderModelError_InvalidArg=300;
      VRRenderModelError_InvalidModel=301;
      VRRenderModelError_NoShapes=302;
      VRRenderModelError_MultipleShapes=303;
      VRRenderModelError_TooManyVertices=304;
      VRRenderModelError_MultipleTextures=305;
      VRRenderModelError_BufferTooSmall=306;
      VRRenderModelError_NotEnoughNormals=307;
      VRRenderModelError_NotEnoughTexCoords=308;
      VRRenderModelError_InvalidTexture=400;

      VRComponentProperty_IsStatic=1;
      VRComponentProperty_IsVisible=2;
      VRComponentProperty_IsTouched=4;
      VRComponentProperty_IsPressed=8;
      VRComponentProperty_IsScrolled=16;

      EVRNotificationType_Transient=0;
      EVRNotificationType_Persistent=1;
      EVRNotificationType_Transient_SystemWithUserValue=2;

      EVRNotificationStyle_None=0;
      EVRNotificationStyle_Application=100;
      EVRNotificationStyle_Contact_Disabled=200;
      EVRNotificationStyle_Contact_Enabled=201;
      EVRNotificationStyle_Contact_Active=202;

      VRSettingsError_None=0;
      VRSettingsError_IPCFailed=1;
      VRSettingsError_WriteFailed=2;
      VRSettingsError_ReadFailed=3;
      VRSettingsError_JsonParseFailed=4;
      VRSettingsError_UnsetSettingHasNoDefault=5;

      VRScreenshotError_None=0;
      VRScreenshotError_RequestFailed=1;
      VRScreenshotError_IncompatibleVersion=100;
      VRScreenshotError_NotFound=101;
      VRScreenshotError_BufferTooSmall=102;
      VRScreenshotError_ScreenshotAlreadyInProgress=108;

      VRSkeletalTransformSpace_Model=0;
      VRSkeletalTransformSpace_Parent=1;
      VRSkeletalTransformSpace_Additive=2;

      IOBuffer_Success=0;
      IOBuffer_OperationFailed=100;
      IOBuffer_InvalidHandle=101;
      IOBuffer_InvalidArgument=102;
      IOBuffer_PathExists=103;
      IOBuffer_PathDoesNotExist=104;
      IOBuffer_Permission=105;

      VRInputFilterCancel_Timers=0;
      VRInputFilterCancel_Momentum=1;

      IOBufferMode_Read=1;
      IOBufferMode_Write=2;
      IOBufferMode_Create=512;

type PEVREye=^TEVREye;
     TEVREye=TpovrInt;

     PETextureType=^TETextureType;
     TETextureType=TpovrInt;

     PEColorSpace=^TEColorSpace;
     TEColorSpace=TpovrInt;

     PETrackingResult=^TETrackingResult;
     TETrackingResult=TpovrInt;

     PETrackedDeviceClass=^TETrackedDeviceClass;
     TETrackedDeviceClass=TpovrInt;

     PETrackedControllerRole=^TETrackedControllerRole;
     TETrackedControllerRole=TpovrInt;

     PETrackingUniverseOrigin=^TETrackingUniverseOrigin;
     TETrackingUniverseOrigin=TpovrInt;

     PETrackedDeviceProperty=^TETrackedDeviceProperty;
     TETrackedDeviceProperty=TpovrInt;

     PETrackedPropertyError=^TETrackedPropertyError;
     TETrackedPropertyError=TpovrInt;

     PEVRSubmitFlags=^TEVRSubmitFlags;
     TEVRSubmitFlags=TpovrInt;

     PEVRState=^TEVRState;
     TEVRState=TpovrInt;

     PEVREventType=^TEVREventType;
     TEVREventType=TpovrInt;

     PEDeviceActivityLevel=^TEDeviceActivityLevel;
     TEDeviceActivityLevel=TpovrInt;

     PEVRButtonId=^TEVRButtonId;
     TEVRButtonId=TpovrInt;

     PEVRMouseButton=^TEVRMouseButton;
     TEVRMouseButton=TpovrInt;

     PEDualAnalogWhich=^TEDualAnalogWhich;
     TEDualAnalogWhich=TpovrInt;

     PEVRInputError=^TEVRInputError;
     TEVRInputError=TpovrInt;

     PEVRSpatialAnchorError=^TEVRSpatialAnchorError;
     TEVRSpatialAnchorError=TpovrInt;

     PEHiddenAreaMeshType=^TEHiddenAreaMeshType;
     TEHiddenAreaMeshType=TpovrInt;

     PEVRControllerAxisType=^TEVRControllerAxisType;
     TEVRControllerAxisType=TpovrInt;

     PEVRControllerEventOutputType=^TEVRControllerEventOutputType;
     TEVRControllerEventOutputType=TpovrInt;

     PECollisionBoundsStyle=^TECollisionBoundsStyle;
     TECollisionBoundsStyle=TpovrInt;

     PEVROverlayError=^TEVROverlayError;
     TEVROverlayError=TpovrInt;

     PEVRApplicationType=^TEVRApplicationType;
     TEVRApplicationType=TpovrInt;

     PEVRFirmwareError=^TEVRFirmwareError;
     TEVRFirmwareError=TpovrInt;

     PEVRNotificationError=^TEVRNotificationError;
     TEVRNotificationError=TpovrInt;

     PEVRSkeletalMotionRange=^TEVRSkeletalMotionRange;
     TEVRSkeletalMotionRange=TpovrInt;

     PEVRInitError=^TEVRInitError;
     TEVRInitError=TpovrInt;

     PEVRScreenshotType=^TEVRScreenshotType;
     TEVRScreenshotType=TpovrInt;

     PEVRScreenshotPropertyFilenames=^TEVRScreenshotPropertyFilenames;
     TEVRScreenshotPropertyFilenames=TpovrInt;

     PEVRTrackedCameraError=^TEVRTrackedCameraError;
     TEVRTrackedCameraError=TpovrInt;

     PEVRTrackedCameraFrameLayout=^TEVRTrackedCameraFrameLayout;
     TEVRTrackedCameraFrameLayout=TpovrInt;

     PEVRTrackedCameraFrameType=^TEVRTrackedCameraFrameType;
     TEVRTrackedCameraFrameType=TpovrInt;

     PEVSync=^TEVSync;
     TEVSync=TpovrInt;

     PEVRMuraCorrectionMode=^TEVRMuraCorrectionMode;
     TEVRMuraCorrectionMode=TpovrInt;

     PImu_OffScaleFlags=^TImu_OffScaleFlags;
     TImu_OffScaleFlags=TpovrInt;

     PEVRApplicationError=^TEVRApplicationError;
     TEVRApplicationError=TpovrInt;

     PEVRApplicationProperty=^TEVRApplicationProperty;
     TEVRApplicationProperty=TpovrInt;

     PEVRApplicationTransitionState=^TEVRApplicationTransitionState;
     TEVRApplicationTransitionState=TpovrInt;

     PChaperoneCalibrationState=^TChaperoneCalibrationState;
     TChaperoneCalibrationState=TpovrInt;

     PEChaperoneConfigFile=^TEChaperoneConfigFile;
     TEChaperoneConfigFile=TpovrInt;

     PEChaperoneImportFlags=^TEChaperoneImportFlags;
     TEChaperoneImportFlags=TpovrInt;

     PEVRCompositorError=^TEVRCompositorError;
     TEVRCompositorError=TpovrInt;

     PEVRCompositorTimingMode=^TEVRCompositorTimingMode;
     TEVRCompositorTimingMode=TpovrInt;

     PVROverlayInputMethod=^TVROverlayInputMethod;
     TVROverlayInputMethod=TpovrInt;

     PVROverlayTransformType=^TVROverlayTransformType;
     TVROverlayTransformType=TpovrInt;

     PVROverlayFlags=^TVROverlayFlags;
     TVROverlayFlags=TpovrInt;

     PVRMessageOverlayResponse=^TVRMessageOverlayResponse;
     TVRMessageOverlayResponse=TpovrInt;

     PEGamepadTextInputMode=^TEGamepadTextInputMode;
     TEGamepadTextInputMode=TpovrInt;

     PEGamepadTextInputLineMode=^TEGamepadTextInputLineMode;
     TEGamepadTextInputLineMode=TpovrInt;

     PEOverlayDirection=^TEOverlayDirection;
     TEOverlayDirection=TpovrInt;

     PEVROverlayIntersectionMaskPrimitiveType=^TEVROverlayIntersectionMaskPrimitiveType;
     TEVROverlayIntersectionMaskPrimitiveType=TpovrInt;

     PEVRRenderModelError=^TEVRRenderModelError;
     TEVRRenderModelError=TpovrInt;

     PEVRComponentProperty=^TEVRComponentProperty;
     TEVRComponentProperty=TpovrInt;

     PEVRNotificationType=^TEVRNotificationType;
     TEVRNotificationType=TpovrInt;

     PEVRNotificationStyle=^TEVRNotificationStyle;
     TEVRNotificationStyle=TpovrInt;

     PEVRSettingsError=^TEVRSettingsError;
     TEVRSettingsError=TpovrInt;

     PEVRScreenshotError=^TEVRScreenshotError;
     TEVRScreenshotError=TpovrInt;

     PEVRSkeletalTransformSpace=^TEVRSkeletalTransformSpace;
     TEVRSkeletalTransformSpace=TpovrInt;

     PEVRInputFilterCancelType=^TEVRInputFilterCancelType;
     TEVRInputFilterCancelType=TpovrInt;

     PEIOBufferError=^TEIOBufferError;
     TEIOBufferError=TpovrInt;

     PEIOBufferMode=^TEIOBufferMode;
     TEIOBufferMode=TpovrInt;

     PTrackedDeviceIndex_t=^TTrackedDeviceIndex_t;
     TTrackedDeviceIndex_t=TpovrUInt32;

     PVRNotificationId=^TVRNotificationId;
     TVRNotificationId=TpovrUInt32;

     PVROverlayHandle_t=^TVROverlayHandle_t;
     TVROverlayHandle_t=TpovrUInt64;

     PSpatialAnchorHandle_t=^TSpatialAnchorHandle_t;
     TSpatialAnchorHandle_t=TpovrUInt32;

     PglSharedTextureHandle_t=^TglSharedTextureHandle_t;
     TglSharedTextureHandle_t=pointer;

     PglInt_t=^TglInt_t;
     TglInt_t=TpovrInt32;

     PglUInt_t=^TglUInt_t;
     TglUInt_t=TpovrUInt32;

     PSharedTextureHandle_t=^TSharedTextureHandle_t;
     TSharedTextureHandle_t=TpovrUInt64;

     PDriverId_t=^TDriverId_t;
     TDriverId_t=TpovrUInt32;

     PWebConsoleHandle_t=^TWebConsoleHandle_t;
     TWebConsoleHandle_t=TpovrUInt64;

     PDriverHandle_t=^TDriverHandle_t;
     TDriverHandle_t=TPropertyContainerHandle_t;

     PTrackedCameraHandle_t=^TTrackedCameraHandle_t;
     TTrackedCameraHandle_t=TpovrUInt64;

     PScreenshotHandle_t=^TScreenshotHandle_t;
     TScreenshotHandle_t=TpovrUInt32;

     PVRComponentProperties=^TVRComponentProperties;
     TVRComponentProperties=TpovrUInt32;

     PTextureID_t=^TTextureID_t;
     TTextureID_t=TpovrInt32;

     PIOBufferHandle_t=^TIOBufferHandle_t;
     TIOBufferHandle_t=TpovrUInt64;

     PHmdError=^THmdError;
     THmdError=TEVRInitError;

     PHmd_Eye=^THmd_Eye;
     THmd_Eye=TEVREye;

     PColorSpace=^TColorSpace;
     TColorSpace=TEColorSpace;

     PHmdTrackingResult=^THmdTrackingResult;
     THmdTrackingResult=TETrackingResult;

     PTrackedDeviceClass=^TTrackedDeviceClass;
     TTrackedDeviceClass=TETrackedDeviceClass;

     PTrackingUniverseOrigin=^TTrackingUniverseOrigin;
     TTrackingUniverseOrigin=TETrackingUniverseOrigin;

     PTrackedDeviceProperty=^TTrackedDeviceProperty;
     TTrackedDeviceProperty=TETrackedDeviceProperty;

     PTrackedPropertyError=^TTrackedPropertyError;
     TTrackedPropertyError=TETrackedPropertyError;

     PVRSubmitFlags_t=^TVRSubmitFlags_t;
     TVRSubmitFlags_t=TEVRSubmitFlags;

     PVRState_t=^TVRState_t;
     TVRState_t=TEVRState;

     PCollisionBoundsStyle_t=^TCollisionBoundsStyle_t;
     TCollisionBoundsStyle_t=TECollisionBoundsStyle;

     PVROverlayError=^TVROverlayError;
     TVROverlayError=TEVROverlayError;

     PVRFirmwareError=^TVRFirmwareError;
     TVRFirmwareError=TEVRFirmwareError;

     PVRCompositorError=^TVRCompositorError;
     TVRCompositorError=TEVRCompositorError;

     PVRScreenshotsError=^TVRScreenshotsError;
     TVRScreenshotsError=TEVRScreenshotError;

     PHmdMatrix34_t=^THmdMatrix34_t;
     THmdMatrix34_t=record
      m:array[0..2] of array[0..3] of single;
     end;

     PHmdMatrix33_t=^THmdMatrix33_t;
     THmdMatrix33_t=record
      m:array[0..2] of array[0..2] of single;
     end;

     PHmdMatrix44_t=^THmdMatrix44_t;
     THmdMatrix44_t=record
      m:array[0..3] of array[0..3] of single;
     end;

     PHmdVector3_t=^THmdVector3_t;
     THmdVector3_t=record
      v:array[0..2] of single;
     end;

     PHmdVector4_t=^THmdVector4_t;
     THmdVector4_t=record
      v:array[0..3] of single;
     end;

     PHmdVector3d_t=^THmdVector3d_t;
     THmdVector3d_t=record
      v:array[0..2] of double;
     end;

     PHmdVector2_t=^THmdVector2_t;
     THmdVector2_t=record
      v:array[0..1] of single;
     end;

     PHmdQuaternion_t=^THmdQuaternion_t;
     THmdQuaternion_t=record
      w:double;
      x:double;
      y:double;
      z:double;
     end;

     PHmdQuaternionf_t=^THmdQuaternionf_t;
     THmdQuaternionf_t=record
      w:single;
      x:single;
      y:single;
      z:single;
     end;

     PHmdColor_t=^THmdColor_t;
     THmdColor_t=record
      r:single;
      g:single;
      b:single;
      a:single;
     end;

     PHmdQuad_t=^THmdQuad_t;
     THmdQuad_t=record
      vCorners:array[0..3] of THmdVector3_t;
     end;

     PHmdRect2_t=^THmdRect2_t;
     THmdRect2_t=record
      vTopLeft:THmdVector2_t;
      vBottomRight:THmdVector2_t;
     end;

     PDistortionCoordinates_t=^TDistortionCoordinates_t;
     TDistortionCoordinates_t=record
      rfRed:array[0..1] of single;
      rfGreen:array[0..1] of single;
      rfBlue:array[0..1] of single;
     end;

     PTexture_t=^TTexture_t;
     TTexture_t=record
      handle:pointer;
      eType:TETextureType;
      eColorSpace:TEColorSpace;
     end;

     PTrackedDevicePose_t=^TTrackedDevicePose_t;
     TTrackedDevicePose_t=record
      mDeviceToAbsoluteTracking:THmdMatrix34_t;
      vVelocity:THmdVector3_t;
      vAngularVelocity:THmdVector3_t;
      eTrackingResult:TETrackingResult;
      bPoseIsValid:Tbool;
      bDeviceIsConnected:Tbool;
     end;

     PVRTextureBounds_t=^TVRTextureBounds_t;
     TVRTextureBounds_t=record
      uMin:single;
      vMin:single;
      uMax:single;
      vMax:single;
     end;

     PVRTextureWithPose_t=^TVRTextureWithPose_t;
     TVRTextureWithPose_t=record
      mDeviceToAbsoluteTracking:THmdMatrix34_t;
    end;

     PVRTextureDepthInfo_t=^TVRTextureDepthInfo_t;
     TVRTextureDepthInfo_t=record
      handle:pointer;
      mProjection:THmdMatrix44_t;
      vRange:THmdVector2_t;
     end;

     PVRTextureWithDepth_t=^TVRTextureWithDepth_t;
     TVRTextureWithDepth_t=record
      depth:TVRTextureDepthInfo_t;
     end;

     PVRTextureWithPoseAndDepth_t=^TVRTextureWithPoseAndDepth_t;
     TVRTextureWithPoseAndDepth_t=record
      depth:TVRTextureDepthInfo_t;
     end;

     PVRVulkanTextureData_t=^TVRVulkanTextureData_t;
     TVRVulkanTextureData_t=record
      m_nImage:TpovrUInt64;
      m_pDevice:{$ifdef PasOpenVRPasVulkan}TVkDevice{$else}pointer{$endif};
      m_pPhysicalDevice:{$ifdef PasOpenVRPasVulkan}TVkPhysicalDevice{$else}pointer{$endif};
      m_pInstance:{$ifdef PasOpenVRPasVulkan}TVkInstance{$else}pointer{$endif};
      m_pQueue:{$ifdef PasOpenVRPasVulkan}TVkQueue{$else}pointer{$endif};
      m_nQueueFamilyIndex:TpovrUInt32;
      m_nWidth:TpovrUInt32;
      m_nHeight:TpovrUInt32;
      m_nFormat:TpovrUInt32;
      m_nSampleCount:TpovrUInt32;
     end;

     PD3D12TextureData_t=^TD3D12TextureData_t;
     TD3D12TextureData_t=record
      m_pResource:{$ifdef PasOpenGLPasDirectX12}PID3D12Resource{$else}pointer{$endif};
      m_pCommandQueue:{$ifdef PasOpenGLPasDirectX12}PID3D12CommandQueue{$else}pointer{$endif};
      m_nNodeMask:TpovrUInt32;
     end;

     PVREvent_Controller_t=^TVREvent_Controller_t;
     TVREvent_Controller_t=record
      button:TpovrUInt32;
     end;

     PVREvent_Mouse_t=^TVREvent_Mouse_t;
     TVREvent_Mouse_t=record
      x:single;
      y:single;
      button:TpovrUInt32;
     end;

     PVREvent_Scroll_t=^TVREvent_Scroll_t;
     TVREvent_Scroll_t=record
      xdelta:single;
      ydelta:single;
      repeatCount:TpovrUInt32;
     end;

     PVREvent_TouchPadMove_t=^TVREvent_TouchPadMove_t;
     TVREvent_TouchPadMove_t=record
      bFingerDown:Tbool;
      flSecondsFingerDown:single;
      fValueXFirst:single;
      fValueYFirst:single;
      fValueXRaw:single;
      fValueYRaw:single;
     end;

     PVREvent_Notification_t=^TVREvent_Notification_t;
     TVREvent_Notification_t=record
      ulUserValue:TpovrUInt64;
      notificationId:TpovrUInt32;
     end;

     PVREvent_Process_t=^TVREvent_Process_t;
     TVREvent_Process_t=record
      pid:TpovrUInt32;
      oldPid:TpovrUInt32;
      bForced:Tbool;
     end;

     PVREvent_Overlay_t=^TVREvent_Overlay_t;
     TVREvent_Overlay_t=record
      overlayHandle:TpovrUInt64;
      devicePath:TpovrUInt64;
     end;

     PVREvent_Status_t=^TVREvent_Status_t;
     TVREvent_Status_t=record
      statusState:TpovrUInt32;
     end;

     PVREvent_Keyboard_t=^TVREvent_Keyboard_t;
     TVREvent_Keyboard_t=record
      cNewInput:array[0..7] of AnsiChar;
      uUserValue:TpovrUInt64;
     end;

     PVREvent_Ipd_t=^TVREvent_Ipd_t;
     TVREvent_Ipd_t=record
      ipdMeters:single;
     end;

     PVREvent_Chaperone_t=^TVREvent_Chaperone_t;
     TVREvent_Chaperone_t=record
      m_nPreviousUniverse:TpovrUInt64;
      m_nCurrentUniverse:TpovrUInt64;
     end;

     PVREvent_Reserved_t=^TVREvent_Reserved_t;
     TVREvent_Reserved_t=record
      reserved0:TpovrUInt64;
      reserved1:TpovrUInt64;
      reserved2:TpovrUInt64;
      reserved3:TpovrUInt64;
     end;

     PVREvent_PerformanceTest_t=^TVREvent_PerformanceTest_t;
     TVREvent_PerformanceTest_t=record
      m_nFidelityLevel:TpovrUInt32;
     end;

     PVREvent_SeatedZeroPoseReset_t=^TVREvent_SeatedZeroPoseReset_t;
     TVREvent_SeatedZeroPoseReset_t=record
      bResetBySystemMenu:Tbool;
     end;

     PVREvent_Screenshot_t=^TVREvent_Screenshot_t;
     TVREvent_Screenshot_t=record
      handle:TpovrUInt32;
      _type:TpovrUInt32;
     end;

     PVREvent_ScreenshotProgress_t=^TVREvent_ScreenshotProgress_t;
     TVREvent_ScreenshotProgress_t=record
      progress:single;
     end;

     PVREvent_ApplicationLaunch_t=^TVREvent_ApplicationLaunch_t;
     TVREvent_ApplicationLaunch_t=record
      pid:TpovrUInt32;
      unArgsHandle:TpovrUInt32;
     end;

     PVREvent_EditingCameraSurface_t=^TVREvent_EditingCameraSurface_t;
     TVREvent_EditingCameraSurface_t=record
      overlayHandle:TpovrUInt64;
      nVisualMode:TpovrUInt32;
     end;

     PVREvent_MessageOverlay_t=^TVREvent_MessageOverlay_t;
     TVREvent_MessageOverlay_t=record
      unVRMessageOverlayResponse:TpovrUInt32;
     end;

     PVREvent_Property_t=^TVREvent_Property_t;
     TVREvent_Property_t=record
      container:TPropertyContainerHandle_t;
      prop:TETrackedDeviceProperty;
     end;

     PVREvent_DualAnalog_t=^TVREvent_DualAnalog_t;
     TVREvent_DualAnalog_t=record
      x:single;
      y:single;
      transformedX:single;
      transformedY:single;
      which:TEDualAnalogWhich;
     end;

     PVREvent_HapticVibration_t=^TVREvent_HapticVibration_t;
     TVREvent_HapticVibration_t=record
      containerHandle:TpovrUInt64;
      componentHandle:TpovrUInt64;
      fDurationSeconds:single;
      fFrequency:single;
      fAmplitude:single;
     end;

     PVREvent_WebConsole_t=^TVREvent_WebConsole_t;
     TVREvent_WebConsole_t=record
      webConsoleHandle:TWebConsoleHandle_t;
     end;

     PVREvent_InputBindingLoad_t=^TVREvent_InputBindingLoad_t;
     TVREvent_InputBindingLoad_t=record
      ulAppContainer:TPropertyContainerHandle_t;
      pathMessage:TpovrUInt64;
      pathUrl:TpovrUInt64;
      pathControllerType:TpovrUInt64;
     end;

     PVREvent_InputActionManifestLoad_t=^TVREvent_InputActionManifestLoad_t;
     TVREvent_InputActionManifestLoad_t=record
      pathAppKey:TpovrUInt64;
      pathMessage:TpovrUInt64;
      pathMessageParam:TpovrUInt64;
      pathManifestPath:TpovrUInt64;
     end;

     PVREvent_SpatialAnchor_t=^TVREvent_SpatialAnchor_t;
     TVREvent_SpatialAnchor_t=record
      unHandle:TSpatialAnchorHandle_t;
     end;

     PHiddenAreaMesh_t=^THiddenAreaMesh_t;
     THiddenAreaMesh_t=record
      pVertexData:PHmdVector2_t;
      unTriangleCount:TpovrUInt32;
     end;

     PVRControllerAxis_t=^TVRControllerAxis_t;
     TVRControllerAxis_t=record
      x:single;
      y:single;
     end;

     PVRControllerState_t=^TVRControllerState_t;
     TVRControllerState_t=record
      unPacketNum:TpovrUInt32;
      ulButtonPressed:TpovrUInt64;
      ulButtonTouched:TpovrUInt64;
      rAxis:array[0..4] of TVRControllerAxis_t;
     end;

     PCompositor_OverlaySettings=^TCompositor_OverlaySettings;
     TCompositor_OverlaySettings=record
      size:TpovrUInt32;
      curved:Tbool;
      antialias:Tbool;
      scale:single;
      distance:single;
      alpha:single;
      uOffset:single;
      vOffset:single;
      uScale:single;
      vScale:single;
      gridDivs:single;
      gridWidth:single;
      gridScale:single;
      transform:THmdMatrix44_t;
     end;

     PVRBoneTransform_t=^TVRBoneTransform_t;
     TVRBoneTransform_t=record
      position:THmdVector4_t;
      orientation:THmdQuaternionf_t;
     end;

     PCameraVideoStreamFrameHeader_t=^TCameraVideoStreamFrameHeader_t;
     TCameraVideoStreamFrameHeader_t=record
      eFrameType:TEVRTrackedCameraFrameType;
      nWidth:TpovrUInt32;
      nHeight:TpovrUInt32;
      nBytesPerPixel:TpovrUInt32;
      nFrameSequence:TpovrUInt32;
      standingTrackedDevicePose:TTrackedDevicePose_t;
      ulFrameExposureTime:TpovrUInt64;
     end;

     PDriverDirectMode_FrameTiming=^TDriverDirectMode_FrameTiming;
     TDriverDirectMode_FrameTiming=record
      m_nSize:TpovrUInt32;
      m_nNumFramePresents:TpovrUInt32;
      m_nNumMisPresented:TpovrUInt32;
      m_nNumDroppedFrames:TpovrUInt32;
      m_nReprojectionFlags:TpovrUInt32;
     end;

     PImuSample_t=^TImuSample_t;
     TImuSample_t=record
      fSampleTime:double;
      vAccel:THmdVector3d_t;
      vGyro:THmdVector3d_t;
      unOffScaleFlags:TpovrUInt32;
     end;

     PAppOverrideKeys_t=^TAppOverrideKeys_t;
     TAppOverrideKeys_t=record
      pchKey:PAnsiChar;
      pchValue:PAnsiChar;
     end;

     PCompositor_FrameTiming=^TCompositor_FrameTiming;
     TCompositor_FrameTiming=record
      m_nSize:TpovrUInt32;
      m_nFrameIndex:TpovrUInt32;
      m_nNumFramePresents:TpovrUInt32;
      m_nNumMisPresented:TpovrUInt32;
      m_nNumDroppedFrames:TpovrUInt32;
      m_nReprojectionFlags:TpovrUInt32;
      m_flSystemTimeInSeconds:double;
      m_flPreSubmitGpuMs:single;
      m_flPostSubmitGpuMs:single;
      m_flTotalRenderGpuMs:single;
      m_flCompositorRenderGpuMs:single;
      m_flCompositorRenderCpuMs:single;
      m_flCompositorIdleCpuMs:single;
      m_flClientFrameIntervalMs:single;
      m_flPresentCallCpuMs:single;
      m_flWaitForPresentCpuMs:single;
      m_flSubmitFrameMs:single;
      m_flWaitGetPosesCalledMs:single;
      m_flNewPosesReadyMs:single;
      m_flNewFrameReadyMs:single;
      m_flCompositorUpdateStartMs:single;
      m_flCompositorUpdateEndMs:single;
      m_flCompositorRenderStartMs:single;
      m_HmdPose:TTrackedDevicePose_t;
      m_nNumVSyncsReadyForUse:TpovrUInt32;
	    m_nNumVSyncsToFirstView:TpovrUInt32;
     end;

     PCompositor_CumulativeStats=^TCompositor_CumulativeStats;
     TCompositor_CumulativeStats=record
      m_nPid:TpovrUInt32;
      m_nNumFramePresents:TpovrUInt32;
      m_nNumDroppedFrames:TpovrUInt32;
      m_nNumReprojectedFrames:TpovrUInt32;
      m_nNumFramePresentsOnStartup:TpovrUInt32;
      m_nNumDroppedFramesOnStartup:TpovrUInt32;
      m_nNumReprojectedFramesOnStartup:TpovrUInt32;
      m_nNumLoading:TpovrUInt32;
      m_nNumFramePresentsLoading:TpovrUInt32;
      m_nNumDroppedFramesLoading:TpovrUInt32;
      m_nNumReprojectedFramesLoading:TpovrUInt32;
      m_nNumTimedOut:TpovrUInt32;
      m_nNumFramePresentsTimedOut:TpovrUInt32;
      m_nNumDroppedFramesTimedOut:TpovrUInt32;
      m_nNumReprojectedFramesTimedOut:TpovrUInt32;
     end;

     PVROverlayIntersectionParams_t=^TVROverlayIntersectionParams_t;
     TVROverlayIntersectionParams_t=record
      vSource:THmdVector3_t;
      vDirection:THmdVector3_t;
      eOrigin:TETrackingUniverseOrigin;
     end;

     PVROverlayIntersectionResults_t=^TVROverlayIntersectionResults_t;
     TVROverlayIntersectionResults_t=record
      vPoint:THmdVector3_t;
      vNormal:THmdVector3_t;
      vUVs:THmdVector2_t;
      fDistance:single;
     end;

     PIntersectionMaskRectangle_t=^TIntersectionMaskRectangle_t;
     TIntersectionMaskRectangle_t=record
      m_flTopLeftX:single;
      m_flTopLeftY:single;
      m_flWidth:single;
      m_flHeight:single;
     end;

     PIntersectionMaskCircle_t=^TIntersectionMaskCircle_t;
     TIntersectionMaskCircle_t=record
      m_flCenterX:single;
      m_flCenterY:single;
      m_flRadius:single;
     end;

     PRenderModel_ComponentState_t=^TRenderModel_ComponentState_t;
     TRenderModel_ComponentState_t=record
      mTrackingToComponentRenderModel:THmdMatrix34_t;
      mTrackingToComponentLocal:THmdMatrix34_t;
      uProperties:TVRComponentProperties;
     end;

     PRenderModel_Vertex_t=^TRenderModel_Vertex_t;
     TRenderModel_Vertex_t=record
      vPosition:THmdVector3_t;
      vNormal:THmdVector3_t;
      rfTextureCoord:array[0..1] of single;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$packrecords 4}{$else}{$align 4}{$ifend}
     PRenderModel_TextureMap_t=^TRenderModel_TextureMap_t;
     TRenderModel_TextureMap_t=record
      unWidth:TpovrUInt16;
      unHeight:TpovrUInt16;
      rubTextureMapData:PpovrUInt8;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$else}{$align 8}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$packrecords 4}{$else}{$align 4}{$ifend}
     PRenderModel_t=^TRenderModel_t;
     TRenderModel_t=record
      rVertexData:PRenderModel_Vertex_t;
      unVertexCount:TpovrUInt32;
      rIndexData:PpovrUInt16;
      unTriangleCount:TpovrUInt32;
      diffuseTextureId:TTextureID_t;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$else}{$align 8}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$packrecords c}{$else}{$align on}{$ifend}

     PRenderModel_ControllerMode_State_t=^TRenderModel_ControllerMode_State_t;
     TRenderModel_ControllerMode_State_t=record
      bScrollWheelVisible:Tbool;
     end;

     PNotificationBitmap_t=^TNotificationBitmap_t;
     TNotificationBitmap_t=record
      m_pImageData:pointer;
      m_nWidth:TpovrInt32;
      m_nHeight:TpovrInt32;
      m_nBytesPerPixel:TpovrInt32;
     end;

     PCVRSettingHelper=^TCVRSettingHelper;
     TCVRSettingHelper=record
      m_pSettings:TpovrIntPtr;
     end;

     PInputAnalogActionData_t=^TInputAnalogActionData_t;
     TInputAnalogActionData_t=record
      bActive:Tbool;
      activeOrigin:TVRInputValueHandle_t;
      x:single;
      y:single;
      z:single;
      deltaX:single;
      deltaY:single;
      deltaZ:single;
      fUpdateTime:single;
     end;

     PInputDigitalActionData_t=^TInputDigitalActionData_t;
     TInputDigitalActionData_t=record
      bActive:Tbool;
      activeOrigin:TVRInputValueHandle_t;
      bState:Tbool;
      bChanged:Tbool;
      fUpdateTime:single;
     end;

     PInputPoseActionData_t=^TInputPoseActionData_t;
     TInputPoseActionData_t=record
      bActive:Tbool;
      activeOrigin:TVRInputValueHandle_t;
      pose:TTrackedDevicePose_t;
     end;

     PInputSkeletalActionData_t=^TInputSkeletalActionData_t;
     TInputSkeletalActionData_t=record
      bActive:Tbool;
      activeOrigin:TVRInputValueHandle_t;
      boneCount:TpovrUInt32;
     end;

     PInputOriginInfo_t=^TInputOriginInfo_t;
     TInputOriginInfo_t=record
      devicePath:TVRInputValueHandle_t;
      trackedDeviceIndex:TTrackedDeviceIndex_t;
      rchRenderModelComponentName:array[0..127] of AnsiChar;
     end;

     PVRActiveActionSet_t=^TVRActiveActionSet_t;
     TVRActiveActionSet_t=record
      ulActionSet:TVRActionSetHandle_t;
      ulRestrictedToDevice:TVRInputValueHandle_t;
      ulSecondaryActionSet:TVRActionSetHandle_t;
      unPadding:TpovrUInt32;
      nPriority:TpovrInt32;
     end;

     PSpatialAnchorPose_t=^TSpatialAnchorPose_t;
     TSpatialAnchorPose_t=record
      mAnchorToAbsoluteTracking:THmdMatrix34_t;
     end;

     PCOpenVRContext=^TCOpenVRContext;
     TCOpenVRContext=record
      m_pVRSystem:TpovrIntPtr;
      m_pVRChaperone:TpovrIntPtr;
      m_pVRChaperoneSetup:TpovrIntPtr;
      m_pVRCompositor:TpovrIntPtr;
      m_pVROverlay:TpovrIntPtr;
      m_pVRResources:TpovrIntPtr;
      m_pVRRenderModels:TpovrIntPtr;
      m_pVRExtendedDisplay:TpovrIntPtr;
      m_pVRSettings:TpovrIntPtr;
      m_pVRApplications:TpovrIntPtr;
      m_pVRTrackedCamera:TpovrIntPtr;
      m_pVRScreenshots:TpovrIntPtr;
      m_pVRDriverManager:TpovrIntPtr;
      m_pVRInput:TpovrIntPtr;
      m_pVRIOBuffer:TpovrIntPtr;
      m_pVRSpatialAnchors:TpovrIntPtr;
     end;

     PVREvent_Data_t=^TVREvent_Data_t;
     TVREvent_Data_t=record
      case TpovrInt of
       0:(reserved:TVREvent_Reserved_t);
       1:(controller:TVREvent_Controller_t);
       2:(mouse:TVREvent_Mouse_t);
       3:(scroll:TVREvent_Scroll_t);
       4:(process:TVREvent_Process_t);
       5:(notification:TVREvent_Notification_t);
       6:(overlay:TVREvent_Overlay_t);
       7:(status:TVREvent_Status_t);
       8:(keyboard:TVREvent_Keyboard_t);
       9:(ipd:TVREvent_Ipd_t);
       10:(chaperone:TVREvent_Chaperone_t);
       11:(performanceTest:TVREvent_PerformanceTest_t);
       12:(touchPadMove:TVREvent_TouchPadMove_t);
       13:(seatedZeroPoseReset:TVREvent_SeatedZeroPoseReset_t);
       14:(screenshot:TVREvent_Screenshot_t);
       15:(screenshotProgress:TVREvent_ScreenshotProgress_t);
       16:(applicationLaunch:TVREvent_ApplicationLaunch_t);
       17:(cameraSurface:TVREvent_EditingCameraSurface_t);
       18:(messageOverlay:TVREvent_MessageOverlay_t);
       19:(property_:TVREvent_Property_t);
       20:(dualAnalog:TVREvent_DualAnalog_t);
       21:(hapticVibration:TVREvent_HapticVibration_t);
       22:(webConsole:TVREvent_WebConsole_t);
       23:(inputBinding:TVREvent_InputBindingLoad_t);
       24:(actionManifest:TVREvent_InputActionManifestLoad_t);
       25:(spatialAnchor:TVREvent_SpatialAnchor_t);
     end;

{$ifdef Linux}{$if defined(fpc) and (fpc_version>=3)}{$push}{$packrecords 4}{$else}{$align 4}{$ifend}{$endif}
     // This structure was originally defined mis-packed on Linux, preserved for compatibility.
     PVREvent_t=^TVREvent_t;
     TVREvent_t=record
      eventType:TpovrUInt32;
      trackedDeviceIndex:TTrackedDeviceIndex_t;
      eventAgeSeconds:single;
      data:TVREvent_Data_t;
     end;
{$ifdef Linux}{$if defined(fpc) and (fpc_version>=3)}{$pop}{$else}{$align 8}{$ifend}{$endif}

     PVROverlayIntersectionMaskPrimitive_Data_t=^TVROverlayIntersectionMaskPrimitive_Data_t;
     TVROverlayIntersectionMaskPrimitive_Data_t=record
      case TpovrInt of
       0:(m_Rectangle:TIntersectionMaskRectangle_t);
       1:(m_Circle:TIntersectionMaskCircle_t);
     end;

     PVROverlayIntersectionMaskPrimitive_t=^TVROverlayIntersectionMaskPrimitive_t;
     TVROverlayIntersectionMaskPrimitive_t=record
      m_nPrimitiveType:TEVROverlayIntersectionMaskPrimitiveType;
      m_Primitive:TVROverlayIntersectionMaskPrimitive_Data_t;
     end;

{ OpenVR Function Pointer Tables }
     PVR_IVRSystem_FnTable=^TVR_IVRSystem_FnTable;
     TVR_IVRSystem_FnTable=record
      GetRecommendedRenderTargetSize:procedure(pnWidth:PpovrUInt32;pnHeight:PpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetProjectionMatrix:function(eEye:TEVREye;fNearZ:single;fFarZ:single):THmdMatrix44_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetProjectionRaw:procedure(eEye:TEVREye;pfLeft:Psingle;pfRight:Psingle;pfTop:Psingle;pfBottom:Psingle); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ComputeDistortion:function(eEye:TEVREye;fU:single;fV:single;pDistortionCoordinates:PDistortionCoordinates_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetEyeToHeadTransform:function(eEye:TEVREye):THmdMatrix34_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTimeSinceLastVsync:function(pfSecondsSinceLastVsync:Psingle;pulFrameCounter:PpovrUInt64):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetD3D9AdapterIndex:function:TpovrInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDXGIOutputInfo:procedure(pnAdapterIndex:PpovrInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOutputDevice:procedure(pnDevice:PpovrUInt64;textureType:TETextureType;pInstance:{$ifdef PasOpenVRPasVulkan}TVkInstance{$else}pointer{$endif}); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsDisplayOnDesktop:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetDisplayVisibility:function(bIsVisibleOnDesktop:Tbool):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDeviceToAbsoluteTrackingPose:procedure(eOrigin:TETrackingUniverseOrigin;fPredictedSecondsToPhotonsFromNow:single;pTrackedDevicePoseArray:PTrackedDevicePose_t;unTrackedDevicePoseArrayCount:TpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ResetSeatedZeroPose:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSeatedZeroPoseToStandingAbsoluteTrackingPose:function:THmdMatrix34_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRawZeroPoseToStandingAbsoluteTrackingPose:function:THmdMatrix34_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSortedTrackedDeviceIndicesOfClass:function(eTrackedDeviceClass:TETrackedDeviceClass;punTrackedDeviceIndexArray:PTrackedDeviceIndex_t;unTrackedDeviceIndexArrayCount:TpovrUInt32;unRelativeToTrackedDeviceIndex:TTrackedDeviceIndex_t):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTrackedDeviceActivityLevel:function(unDeviceId:TTrackedDeviceIndex_t):TEDeviceActivityLevel; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ApplyTransform:procedure(pOutputPose:PTrackedDevicePose_t;pTrackedDevicePose:PTrackedDevicePose_t;pTransform:PHmdMatrix34_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTrackedDeviceIndexForControllerRole:function(unDeviceType:TETrackedControllerRole):TTrackedDeviceIndex_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetControllerRoleForTrackedDeviceIndex:function(unDeviceIndex:TTrackedDeviceIndex_t):TETrackedControllerRole; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTrackedDeviceClass:function(unDeviceIndex:TTrackedDeviceIndex_t):TETrackedDeviceClass; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsTrackedDeviceConnected:function(unDeviceIndex:TTrackedDeviceIndex_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetBoolTrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pError:PETrackedPropertyError):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetFloatTrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pError:PETrackedPropertyError):single; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetInt32TrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pError:PETrackedPropertyError):TpovrInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetUint64TrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pError:PETrackedPropertyError):TpovrUInt64; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetMatrix34TrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pError:PETrackedPropertyError):THmdMatrix34_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetArrayTrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;propType:TPropertyTypeTag_t;pBuffer:pointer;unBufferSize:TpovrUInt32;pError:PETrackedPropertyError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetStringTrackedDeviceProperty:function(unDeviceIndex:TTrackedDeviceIndex_t;prop:TETrackedDeviceProperty;pchValue:PAnsiChar;unBufferSize:TpovrUInt32;pError:PETrackedPropertyError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetPropErrorNameFromEnum:function(error:TETrackedPropertyError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PollNextEvent:function(pEvent:PVREvent_t;uncbVREvent:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PollNextEventWithPose:function(eOrigin:TETrackingUniverseOrigin;pEvent:PVREvent_t;uncbVREvent:TpovrUInt32;pTrackedDevicePose:PTrackedDevicePose_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetEventTypeNameFromEnum:function(eType:TEVREventType):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetHiddenAreaMesh:function(eEye:TEVREye;_type:TEHiddenAreaMeshType):THiddenAreaMesh_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetControllerState:function(unControllerDeviceIndex:TTrackedDeviceIndex_t;pControllerState:PVRControllerState_t;unControllerStateSize:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetControllerStateWithPose:function(eOrigin:TETrackingUniverseOrigin;unControllerDeviceIndex:TTrackedDeviceIndex_t;pControllerState:PVRControllerState_t;unControllerStateSize:TpovrUInt32;pTrackedDevicePose:PTrackedDevicePose_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      TriggerHapticPulse:procedure(unControllerDeviceIndex:TTrackedDeviceIndex_t;unAxisId:TpovrUInt32;usDurationMicroSec:word); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetButtonIdNameFromEnum:function(eButtonId:TEVRButtonId):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetControllerAxisTypeNameFromEnum:function(eAxisType:TEVRControllerAxisType):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsInputAvailable:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsSteamVRDrawingControllers:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShouldApplicationPause:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShouldApplicationReduceRenderingWork:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      DriverDebugRequest:function(unDeviceIndex:TTrackedDeviceIndex_t;pchRequest:PAnsiChar;pchResponseBuffer:PAnsiChar;unResponseBufferSize:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PerformFirmwareUpdate:function(unDeviceIndex:TTrackedDeviceIndex_t):TEVRFirmwareError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      AcknowledgeQuit_Exiting:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      AcknowledgeQuit_UserPrompt:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRExtendedDisplay_FnTable=^TVR_IVRExtendedDisplay_FnTable;
     TVR_IVRExtendedDisplay_FnTable=record
      GetWindowBounds:procedure(pnX:PpovrInt32;pnY:PpovrInt32;pnWidth:PpovrUInt32;pnHeight:PpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetEyeOutputViewport:procedure(eEye:TEVREye;pnX:PpovrUInt32;pnY:PpovrUInt32;pnWidth:PpovrUInt32;pnHeight:PpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDXGIOutputInfo:procedure(pnAdapterIndex:PpovrInt32;pnAdapterOutputIndex:PpovrInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRTrackedCamera_FnTable=^TVR_IVRTrackedCamera_FnTable;
     TVR_IVRTrackedCamera_FnTable=record
      GetCameraErrorNameFromEnum:function(eCameraError:TEVRTrackedCameraError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      HasCamera:function(nDeviceIndex:TTrackedDeviceIndex_t;pHasCamera:Pbool):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCameraFrameSize:function(nDeviceIndex:TTrackedDeviceIndex_t;eFrameType:TEVRTrackedCameraFrameType;pnWidth:PpovrUInt32;pnHeight:PpovrUInt32;pnFrameBufferSize:PpovrUInt32):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCameraIntrinsics:function(nDeviceIndex:TTrackedDeviceIndex_t;eFrameType:TEVRTrackedCameraFrameType;pFocalLength:PHmdVector2_t;pCenter:PHmdVector2_t):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCameraProjection:function(nDeviceIndex:TTrackedDeviceIndex_t;eFrameType:TEVRTrackedCameraFrameType;flZNear:single;flZFar:single;pProjection:PHmdMatrix44_t):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      AcquireVideoStreamingService:function(nDeviceIndex:TTrackedDeviceIndex_t;pHandle:PTrackedCameraHandle_t):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReleaseVideoStreamingService:function(hTrackedCamera:TTrackedCameraHandle_t):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVideoStreamFrameBuffer:function(hTrackedCamera:TTrackedCameraHandle_t;eFrameType:TEVRTrackedCameraFrameType;pFrameBuffer:pointer;nFrameBufferSize:TpovrUInt32;pFrameHeader:PCameraVideoStreamFrameHeader_t;nFrameHeaderSize:TpovrUInt32):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVideoStreamTextureSize:function(nDeviceIndex:TTrackedDeviceIndex_t;eFrameType:TEVRTrackedCameraFrameType;pTextureBounds:PVRTextureBounds_t;pnWidth:PpovrUInt32;pnHeight:PpovrUInt32):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVideoStreamTextureD3D11:function(hTrackedCamera:TTrackedCameraHandle_t;eFrameType:TEVRTrackedCameraFrameType;pD3D11DeviceOrResource:pointer;ppD3D11ShaderResourceView:Ppointer;pFrameHeader:PCameraVideoStreamFrameHeader_t;nFrameHeaderSize:TpovrUInt32):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVideoStreamTextureGL:function(hTrackedCamera:TTrackedCameraHandle_t;eFrameType:TEVRTrackedCameraFrameType;pglTextureId:PglUInt_t;pFrameHeader:PCameraVideoStreamFrameHeader_t;nFrameHeaderSize:TpovrUInt32):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReleaseVideoStreamTextureGL:function(hTrackedCamera:TTrackedCameraHandle_t;glTextureId:TglUInt_t):TEVRTrackedCameraError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRApplications_FnTable=^TVR_IVRApplications_FnTable;
     TVR_IVRApplications_FnTable=record
      AddApplicationManifest:function(pchApplicationManifestFullPath:PAnsiChar;bTemporary:Tbool):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RemoveApplicationManifest:function(pchApplicationManifestFullPath:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsApplicationInstalled:function(pchAppKey:PAnsiChar):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationCount:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationKeyByIndex:function(unApplicationIndex:TpovrUInt32;pchAppKeyBuffer:PAnsiChar;unAppKeyBufferLen:TpovrUInt32):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationKeyByProcessId:function(unProcessId:TpovrUInt32;pchAppKeyBuffer:PAnsiChar;unAppKeyBufferLen:TpovrUInt32):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LaunchApplication:function(pchAppKey:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LaunchTemplateApplication:function(pchTemplateAppKey:PAnsiChar;pchNewAppKey:PAnsiChar;pKeys:PAppOverrideKeys_t;unKeys:TpovrUInt32):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LaunchApplicationFromMimeType:function(pchMimeType:PAnsiChar;pchArgs:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LaunchDashboardOverlay:function(pchAppKey:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CancelApplicationLaunch:function(pchAppKey:PAnsiChar):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IdentifyApplication:function(unProcessId:TpovrUInt32;pchAppKey:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationProcessId:function(pchAppKey:PAnsiChar):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationsErrorNameFromEnum:function(error:TEVRApplicationError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationPropertyString:function(pchAppKey:PAnsiChar;eProperty:TEVRApplicationProperty;pchPropertyValueBuffer:PAnsiChar;unPropertyValueBufferLen:TpovrUInt32;peError:PEVRApplicationError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationPropertyBool:function(pchAppKey:PAnsiChar;eProperty:TEVRApplicationProperty;peError:PEVRApplicationError):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationPropertyUint64:function(pchAppKey:PAnsiChar;eProperty:TEVRApplicationProperty;peError:PEVRApplicationError):TpovrUInt64; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetApplicationAutoLaunch:function(pchAppKey:PAnsiChar;bAutoLaunch:Tbool):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationAutoLaunch:function(pchAppKey:PAnsiChar):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetDefaultApplicationForMimeType:function(pchAppKey:PAnsiChar;pchMimeType:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDefaultApplicationForMimeType:function(pchMimeType:PAnsiChar;pchAppKeyBuffer:PAnsiChar;unAppKeyBufferLen:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationSupportedMimeTypes:function(pchAppKey:PAnsiChar;pchMimeTypesBuffer:PAnsiChar;unMimeTypesBuffer:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationsThatSupportMimeType:function(pchMimeType:PAnsiChar;pchAppKeysThatSupportBuffer:PAnsiChar;unAppKeysThatSupportBuffer:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationLaunchArguments:function(unHandle:TpovrUInt32;pchArgs:PAnsiChar;unArgs:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetStartingApplication:function(pchAppKeyBuffer:PAnsiChar;unAppKeyBufferLen:TpovrUInt32):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTransitionState:function:TEVRApplicationTransitionState; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PerformApplicationPrelaunchCheck:function(pchAppKey:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetApplicationsTransitionStateNameFromEnum:function(state:TEVRApplicationTransitionState):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsQuitUserPromptRequested:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LaunchInternalProcess:function(pchBinaryPath:PAnsiChar;pchArguments:PAnsiChar;pchWorkingDirectory:PAnsiChar):TEVRApplicationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCurrentSceneProcessId:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRChaperone_FnTable=^TVR_IVRChaperone_FnTable;
     TVR_IVRChaperone_FnTable=record
      GetCalibrationState:function:TChaperoneCalibrationState; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetPlayAreaSize:function(var pSizeX:single;var pSizeZ:single):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetPlayAreaRect:function(rect:PHmdQuad_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReloadInfo:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetSceneColor:procedure(color:THmdColor_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetBoundsColor:procedure(pOutputColorArray:PHmdColor_t;nNumOutputColors:TpovrInt;flCollisionBoundsFadeDistance:single;pOutputCameraColor:PHmdColor_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      AreBoundsVisible:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ForceBoundsVisible:procedure(bForce:Tbool); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRChaperoneSetup_FnTable=^TVR_IVRChaperoneSetup_FnTable;
     TVR_IVRChaperoneSetup_FnTable=record
      CommitWorkingCopy:function(configFile:TEChaperoneConfigFile):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RevertWorkingCopy:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetWorkingPlayAreaSize:function(var pSizeX:single;var pSizeZ:single):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetWorkingPlayAreaRect:function(rect:PHmdQuad_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetWorkingCollisionBoundsInfo:function(pQuadsBuffer:PHmdQuad_t;punQuadsCount:PpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLiveCollisionBoundsInfo:function(pQuadsBuffer:PHmdQuad_t;punQuadsCount:PpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetWorkingSeatedZeroPoseToRawTrackingPose:function(pmatSeatedZeroPoseToRawTrackingPose:PHmdMatrix34_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetWorkingStandingZeroPoseToRawTrackingPose:function(pmatStandingZeroPoseToRawTrackingPose:PHmdMatrix34_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingPlayAreaSize:procedure(sizeX:single;sizeZ:single); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingCollisionBoundsInfo:procedure(pQuadsBuffer:PHmdQuad_t;unQuadsCount:TpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingSeatedZeroPoseToRawTrackingPose:procedure(pMatSeatedZeroPoseToRawTrackingPose:PHmdMatrix34_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingStandingZeroPoseToRawTrackingPose:procedure(pMatStandingZeroPoseToRawTrackingPose:PHmdMatrix34_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReloadFromDisk:procedure(configFile:TEChaperoneConfigFile); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLiveSeatedZeroPoseToRawTrackingPose:function(pmatSeatedZeroPoseToRawTrackingPose:PHmdMatrix34_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingCollisionBoundsTagsInfo:procedure(pTagsBuffer:PpovrUInt8;unTagCount:TpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLiveCollisionBoundsTagsInfo:function(pTagsBuffer:PpovrUInt8;punTagCount:PpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetWorkingPhysicalBoundsInfo:function(pQuadsBuffer:PHmdQuad_t;unQuadsCount:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLivePhysicalBoundsInfo:function(pQuadsBuffer:PHmdQuad_t;punQuadsCount:PpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ExportLiveToBuffer:function(pBuffer:PAnsiChar;pnBufferLength:PpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ImportFromBufferToWorking:function(pBuffer:PAnsiChar;nImportFlags:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRCompositor_FnTable=^TVR_IVRCompositor_FnTable;
     TVR_IVRCompositor_FnTable=record
      SetTrackingSpace:procedure(eOrigin:TETrackingUniverseOrigin); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTrackingSpace:function:TETrackingUniverseOrigin; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      WaitGetPoses:function(pRenderPoseArray:PTrackedDevicePose_t;unRenderPoseArrayCount:TpovrUInt32;pGamePoseArray:PTrackedDevicePose_t;unGamePoseArrayCount:TpovrUInt32):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLastPoses:function(pRenderPoseArray:PTrackedDevicePose_t;unRenderPoseArrayCount:TpovrUInt32;pGamePoseArray:PTrackedDevicePose_t;unGamePoseArrayCount:TpovrUInt32):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLastPoseForTrackedDeviceIndex:function(unDeviceIndex:TTrackedDeviceIndex_t;pOutputPose:PTrackedDevicePose_t;pOutputGamePose:PTrackedDevicePose_t):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      Submit:function(eEye:TEVREye;pTexture:PTexture_t;pBounds:PVRTextureBounds_t;nSubmitFlags:TEVRSubmitFlags):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ClearLastSubmittedFrame:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PostPresentHandoff:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetFrameTiming:function(pTiming:PCompositor_FrameTiming;unFramesAgo:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetFrameTimings:function(pTiming:PCompositor_FrameTiming;nFrames:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetFrameTimeRemaining:function:single; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCumulativeStats:procedure(pStats:PCompositor_CumulativeStats;nStatsSizeInBytes:TpovrUInt32); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      FadeToColor:procedure(fSeconds:single;fRed:single;fGreen:single;fBlue:single;fAlpha:single;bBackground:Tbool); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCurrentFadeColor:function(bBackground:Tbool):THmdColor_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      FadeGrid:procedure(fSeconds:single;bFadeIn:Tbool); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCurrentGridAlpha:function:single; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetSkyboxOverride:function(pTextures:PTexture_t;unTextureCount:TpovrUInt32):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ClearSkyboxOverride:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CompositorBringToFront:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CompositorGoToBack:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CompositorQuit:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsFullscreen:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetCurrentSceneFocusProcess:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetLastFrameRenderer:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CanRenderScene:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowMirrorWindow:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      HideMirrorWindow:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsMirrorWindowVisible:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CompositorDumpImages:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShouldAppRenderWithLowResources:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ForceInterleavedReprojectionOn:procedure(bOverride:Tbool); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ForceReconnectProcess:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SuspendRendering:procedure(bSuspend:Tbool); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetMirrorTextureD3D11:function(eEye:TEVREye;pD3D11DeviceOrResource:pointer;ppD3D11ShaderResourceView:Ppointer):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReleaseMirrorTextureD3D11:procedure(pD3D11ShaderResourceView:pointer); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetMirrorTextureGL:function(eEye:TEVREye;pglTextureId:PglUInt_t;pglSharedTextureHandle:PglSharedTextureHandle_t):TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReleaseSharedGLTexture:function(glTextureId:TglUInt_t;glSharedTextureHandle:TglSharedTextureHandle_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LockGLSharedTextureForAccess:procedure(glSharedTextureHandle:TglSharedTextureHandle_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      UnlockGLSharedTextureForAccess:procedure(glSharedTextureHandle:TglSharedTextureHandle_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVulkanInstanceExtensionsRequired:function(pchValue:PAnsiChar;unBufferSize:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetVulkanDeviceExtensionsRequired:function(pPhysicalDevice:{$ifdef PasOpenVRPasVulkan}TVkPhysicalDevice{$else}pointer{$endif};pchValue:PAnsiChar;unBufferSize:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetExplicitTimingMode:procedure(eTimingMode:TEVRCompositorTimingMode); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SubmitExplicitTimingData:function:TEVRCompositorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVROverlay_FnTable=^TVR_IVROverlay_FnTable;
     TVR_IVROverlay_FnTable=record
      FindOverlay:function(pchOverlayKey:PAnsiChar;pOverlayHandle:PVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CreateOverlay:function(pchOverlayKey:PAnsiChar;pchOverlayName:PAnsiChar;pOverlayHandle:PVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      DestroyOverlay:function(ulOverlayHandle:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetHighQualityOverlay:function(ulOverlayHandle:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetHighQualityOverlay:function:TVROverlayHandle_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayKey:function(ulOverlayHandle:TVROverlayHandle_t;pchValue:PAnsiChar;unBufferSize:TpovrUInt32;pError:PEVROverlayError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayName:function(ulOverlayHandle:TVROverlayHandle_t;pchValue:PAnsiChar;unBufferSize:TpovrUInt32;pError:PEVROverlayError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayName:function(ulOverlayHandle:TVROverlayHandle_t;pchName:PAnsiChar):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayImageData:function(ulOverlayHandle:TVROverlayHandle_t;pvBuffer:pointer;unBufferSize:TpovrUInt32;punWidth:PpovrUInt32;punHeight:PpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayErrorNameFromEnum:function(error:TEVROverlayError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayRenderingPid:function(ulOverlayHandle:TVROverlayHandle_t;unPID:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayRenderingPid:function(ulOverlayHandle:TVROverlayHandle_t):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayFlag:function(ulOverlayHandle:TVROverlayHandle_t;eOverlayFlag:TVROverlayFlags;bEnabled:Tbool):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayFlag:function(ulOverlayHandle:TVROverlayHandle_t;eOverlayFlag:TVROverlayFlags;pbEnabled:Pbool):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayColor:function(ulOverlayHandle:TVROverlayHandle_t;fRed:single;fGreen:single;fBlue:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayColor:function(ulOverlayHandle:TVROverlayHandle_t;var pfRed:single;var pfGreen:single;var pfBlue:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayAlpha:function(ulOverlayHandle:TVROverlayHandle_t;fAlpha:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayAlpha:function(ulOverlayHandle:TVROverlayHandle_t;var pfAlpha:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTexelAspect:function(ulOverlayHandle:TVROverlayHandle_t;fTexelAspect:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTexelAspect:function(ulOverlayHandle:TVROverlayHandle_t;var pfTexelAspect:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlaySortOrder:function(ulOverlayHandle:TVROverlayHandle_t;unSortOrder:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlaySortOrder:function(ulOverlayHandle:TVROverlayHandle_t;punSortOrder:PpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayWidthInMeters:function(ulOverlayHandle:TVROverlayHandle_t;fWidthInMeters:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayWidthInMeters:function(ulOverlayHandle:TVROverlayHandle_t;var pfWidthInMeters:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayAutoCurveDistanceRangeInMeters:function(ulOverlayHandle:TVROverlayHandle_t;fMinDistanceInMeters:single;fMaxDistanceInMeters:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayAutoCurveDistanceRangeInMeters:function(ulOverlayHandle:TVROverlayHandle_t;var pfMinDistanceInMeters:single;var pfMaxDistanceInMeters:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTextureColorSpace:function(ulOverlayHandle:TVROverlayHandle_t;eTextureColorSpace:TEColorSpace):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTextureColorSpace:function(ulOverlayHandle:TVROverlayHandle_t;peTextureColorSpace:PEColorSpace):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTextureBounds:function(ulOverlayHandle:TVROverlayHandle_t;pOverlayTextureBounds:PVRTextureBounds_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTextureBounds:function(ulOverlayHandle:TVROverlayHandle_t;pOverlayTextureBounds:PVRTextureBounds_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayRenderModel:function(ulOverlayHandle:TVROverlayHandle_t;pchValue:PAnsiChar;unBufferSize:TpovrUInt32;pColor:PHmdColor_t;pError:PEVROverlayError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayRenderModel:function(ulOverlayHandle:TVROverlayHandle_t;pchRenderModel:PAnsiChar;pColor:PHmdColor_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTransformType:function(ulOverlayHandle:TVROverlayHandle_t;peTransformType:PVROverlayTransformType):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTransformAbsolute:function(ulOverlayHandle:TVROverlayHandle_t;eTrackingOrigin:TETrackingUniverseOrigin;pmatTrackingOriginToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTransformAbsolute:function(ulOverlayHandle:TVROverlayHandle_t;peTrackingOrigin:PETrackingUniverseOrigin;pmatTrackingOriginToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTransformTrackedDeviceRelative:function(ulOverlayHandle:TVROverlayHandle_t;unTrackedDevice:TTrackedDeviceIndex_t;pmatTrackedDeviceToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTransformTrackedDeviceRelative:function(ulOverlayHandle:TVROverlayHandle_t;punTrackedDevice:PTrackedDeviceIndex_t;pmatTrackedDeviceToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTransformTrackedDeviceComponent:function(ulOverlayHandle:TVROverlayHandle_t;unDeviceIndex:TTrackedDeviceIndex_t;pchComponentName:PAnsiChar):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTransformTrackedDeviceComponent:function(ulOverlayHandle:TVROverlayHandle_t;punDeviceIndex:PTrackedDeviceIndex_t;pchComponentName:PAnsiChar;unComponentNameSize:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTransformOverlayRelative:function(ulOverlayHandle:TVROverlayHandle_t;ulOverlayHandleParent:PVROverlayHandle_t;pmatParentOverlayToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTransformOverlayRelative:function(ulOverlayHandle:TVROverlayHandle_t;ulOverlayHandleParent:TVROverlayHandle_t;pmatParentOverlayToOverlayTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowOverlay:function(ulOverlayHandle:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      HideOverlay:function(ulOverlayHandle:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsOverlayVisible:function(ulOverlayHandle:TVROverlayHandle_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetTransformForOverlayCoordinates:function(ulOverlayHandle:TVROverlayHandle_t;eTrackingOrigin:TETrackingUniverseOrigin;coordinatesInOverlay:THmdVector2_t;pmatTransform:PHmdMatrix34_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PollNextOverlayEvent:function(ulOverlayHandle:TVROverlayHandle_t;pEvent:PVREvent_t;uncbVREvent:TpovrUInt32):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayInputMethod:function(ulOverlayHandle:TVROverlayHandle_t;peInputMethod:PVROverlayInputMethod):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayInputMethod:function(ulOverlayHandle:TVROverlayHandle_t;eInputMethod:TVROverlayInputMethod):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayMouseScale:function(ulOverlayHandle:TVROverlayHandle_t;pvecMouseScale:PHmdVector2_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayMouseScale:function(ulOverlayHandle:TVROverlayHandle_t;pvecMouseScale:PHmdVector2_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ComputeOverlayIntersection:function(ulOverlayHandle:TVROverlayHandle_t;pParams:PVROverlayIntersectionParams_t;pResults:PVROverlayIntersectionResults_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsHoverTargetOverlay:function(ulOverlayHandle:TVROverlayHandle_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetGamepadFocusOverlay:function:TVROverlayHandle_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetGamepadFocusOverlay:function(ulNewFocusOverlay:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayNeighbor:function(eDirection:TEOverlayDirection;ulFrom:TVROverlayHandle_t;ulTo:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      MoveGamepadFocusToNeighbor:function(eDirection:TEOverlayDirection;ulFrom:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayDualAnalogTransform:function(ulOverlay:TVROverlayHandle_t;eWhich:TEDualAnalogWhich;vCenter:PHmdVector2_t;fRadius:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayDualAnalogTransform:function(ulOverlay:TVROverlayHandle_t;eWhich:TEDualAnalogWhich;pvCenter:PHmdVector2_t;var pfRadius:single):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayTexture:function(ulOverlayHandle:TVROverlayHandle_t;pTexture:PTexture_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ClearOverlayTexture:function(ulOverlayHandle:TVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayRaw:function(ulOverlayHandle:TVROverlayHandle_t;pvBuffer:pointer;unWidth:TpovrUInt32;unHeight:TpovrUInt32;unDepth:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayFromFile:function(ulOverlayHandle:TVROverlayHandle_t;pchFilePath:PAnsiChar):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTexture:function(ulOverlayHandle:TVROverlayHandle_t;pNativeTextureHandle:Ppointer;pNativeTextureRef:pointer;pWidth:PpovrUInt32;pHeight:PpovrUInt32;pNativeFormat:PpovrUInt32;pAPIType:PETextureType;pColorSpace:PEColorSpace;pTextureBounds:PVRTextureBounds_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ReleaseNativeOverlayHandle:function(ulOverlayHandle:TVROverlayHandle_t;pNativeTextureHandle:pointer):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayTextureSize:function(ulOverlayHandle:TVROverlayHandle_t;pWidth:PpovrUInt32;pHeight:PpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CreateDashboardOverlay:function(pchOverlayKey:PAnsiChar;pchOverlayFriendlyName:PAnsiChar;pMainHandle:PVROverlayHandle_t;pThumbnailHandle:PVROverlayHandle_t):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsDashboardVisible:function:Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      IsActiveDashboardOverlay:function(ulOverlayHandle:TVROverlayHandle_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetDashboardOverlaySceneProcess:function(ulOverlayHandle:TVROverlayHandle_t;unProcessId:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDashboardOverlaySceneProcess:function(ulOverlayHandle:TVROverlayHandle_t;punProcessId:PpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowDashboard:procedure(pchOverlayToShow:PAnsiChar); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetPrimaryDashboardDevice:function:TTrackedDeviceIndex_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowKeyboard:function(eInputMode:TEGamepadTextInputMode;eLineInputMode:TEGamepadTextInputLineMode;pchDescription:PAnsiChar;unCharMax:TpovrUInt32;pchExistingText:PAnsiChar;bUseMinimalMode:Tbool;uUserValue:TpovrUInt64):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowKeyboardForOverlay:function(ulOverlayHandle:TVROverlayHandle_t;eInputMode:TEGamepadTextInputMode;eLineInputMode:TEGamepadTextInputLineMode;pchDescription:PAnsiChar;unCharMax:TpovrUInt32;pchExistingText:PAnsiChar;bUseMinimalMode:Tbool;uUserValue:TpovrUInt64):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetKeyboardText:function(pchText:PAnsiChar;cchText:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      HideKeyboard:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetKeyboardTransformAbsolute:procedure(eTrackingOrigin:TETrackingUniverseOrigin;pmatTrackingOriginToKeyboardTransform:PHmdMatrix34_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetKeyboardPositionForOverlay:procedure(ulOverlayHandle:TVROverlayHandle_t;avoidRect:THmdRect2_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetOverlayIntersectionMask:function(ulOverlayHandle:TVROverlayHandle_t;pMaskPrimitives:PVROverlayIntersectionMaskPrimitive_t;unNumMaskPrimitives:TpovrUInt32;unPrimitiveSize:TpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOverlayFlags:function(ulOverlayHandle:TVROverlayHandle_t;pFlags:PpovrUInt32):TEVROverlayError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowMessageOverlay:function(pchText:PAnsiChar;pchCaption:PAnsiChar;pchButton0Text:PAnsiChar;pchButton1Text:PAnsiChar;pchButton2Text:PAnsiChar;pchButton3Text:PAnsiChar):TVRMessageOverlayResponse; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CloseMessageOverlay:procedure; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRRenderModels_FnTable=^TVR_IVRRenderModels_FnTable;
     TVR_IVRRenderModels_FnTable=record
      LoadRenderModel_Async:function(pchRenderModelName:PAnsiChar;var ppRenderModel:PRenderModel_t):TEVRRenderModelError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      FreeRenderModel:procedure(pRenderModel:PRenderModel_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LoadTexture_Async:function(textureId:TTextureID_t;var ppTexture:PRenderModel_TextureMap_t):TEVRRenderModelError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      FreeTexture:procedure(pTexture:PRenderModel_TextureMap_t); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LoadTextureD3D11_Async:function(textureId:TTextureID_t;pD3D11Device:pointer;ppD3D11Texture2D:Ppointer):TEVRRenderModelError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      LoadIntoTextureD3D11_Async:function(textureId:TTextureID_t;pDstTexture:pointer):TEVRRenderModelError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      FreeTextureD3D11:procedure(pD3D11Texture2D:pointer); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRenderModelName:function(unRenderModelIndex:TpovrUInt32;pchRenderModelName:PAnsiChar;unRenderModelNameLen:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRenderModelCount:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentCount:function(pchRenderModelName:PAnsiChar):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentName:function(pchRenderModelName:PAnsiChar;unComponentIndex:TpovrUInt32;pchComponentName:PAnsiChar;unComponentNameLen:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentButtonMask:function(pchRenderModelName:PAnsiChar;pchComponentName:PAnsiChar):TpovrUInt64; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentRenderModelName:function(pchRenderModelName:PAnsiChar;pchComponentName:PAnsiChar;pchComponentRenderModelName:PAnsiChar;unComponentRenderModelNameLen:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentStateForDevicePath:function(pchRenderModelName:PAnsiChar;pchComponentName:PAnsiChar;devicePath:TVRInputValueHandle_t;pState:PRenderModel_ControllerMode_State_t;pComponentState:PRenderModel_ComponentState_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetComponentState:function(pchRenderModelName:PAnsiChar;pchComponentName:PAnsiChar;pControllerState:PVRControllerState_t;pState:PRenderModel_ControllerMode_State_t;pComponentState:PRenderModel_ComponentState_t):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RenderModelHasComponent:function(pchRenderModelName:PAnsiChar;pchComponentName:PAnsiChar):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRenderModelThumbnailURL:function(pchRenderModelName:PAnsiChar;pchThumbnailURL:PAnsiChar;unThumbnailURLLen:TpovrUInt32;peError:PEVRRenderModelError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRenderModelOriginalPath:function(pchRenderModelName:PAnsiChar;pchOriginalPath:PAnsiChar;unOriginalPathLen:TpovrUInt32;peError:PEVRRenderModelError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetRenderModelErrorNameFromEnum:function(error:TEVRRenderModelError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRNotifications_FnTable=^TVR_IVRNotifications_FnTable;
     TVR_IVRNotifications_FnTable=record
      CreateNotification:function(ulOverlayHandle:TVROverlayHandle_t;ulUserValue:TpovrUInt64;_type:TEVRNotificationType;pchText:PAnsiChar;style:TEVRNotificationStyle;pImage:PNotificationBitmap_t;pNotificationId:PVRNotificationId):TEVRNotificationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RemoveNotification:function(notificationId:TVRNotificationId):TEVRNotificationError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRSettings_FnTable=^TVR_IVRSettings_FnTable;
     TVR_IVRSettings_FnTable=record
      GetSettingsErrorNameFromEnum:function(eError:TEVRSettingsError):PAnsiChar; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      Sync:function(bForce:Tbool;peError:PEVRSettingsError):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetBool:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;bValue:Tbool;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetInt32:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;nValue:TpovrInt32;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetFloat:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;flValue:single;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SetString:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;pchValue:PAnsiChar;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetBool:function(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;peError:PEVRSettingsError):Tbool; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetInt32:function(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;peError:PEVRSettingsError):TpovrInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetFloat:function(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;peError:PEVRSettingsError):single; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetString:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;pchValue:PAnsiChar;unValueLen:TpovrUInt32;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RemoveSection:procedure(pchSection:PAnsiChar;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      RemoveKeyInSection:procedure(pchSection:PAnsiChar;pchSettingsKey:PAnsiChar;peError:PEVRSettingsError); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRScreenshots_FnTable=^TVR_IVRScreenshots_FnTable;
     TVR_IVRScreenshots_FnTable=record
      RequestScreenshot:function(pOutScreenshotHandle:PScreenshotHandle_t;_type:TEVRScreenshotType;pchPreviewFilename:PAnsiChar;pchVRFilename:PAnsiChar):TEVRScreenshotError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      HookScreenshot:function(pSupportedTypes:PEVRScreenshotType;numTypes:TpovrInt):TEVRScreenshotError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetScreenshotPropertyType:function(screenshotHandle:TScreenshotHandle_t;pError:PEVRScreenshotError):TEVRScreenshotType; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetScreenshotPropertyFilename:function(screenshotHandle:TScreenshotHandle_t;filenameType:TEVRScreenshotPropertyFilenames;pchFilename:PAnsiChar;cchFilename:TpovrUInt32;pError:PEVRScreenshotError):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      UpdateScreenshotProgress:function(screenshotHandle:TScreenshotHandle_t;flProgress:single):TEVRScreenshotError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      TakeStereoScreenshot:function(pOutScreenshotHandle:PScreenshotHandle_t;pchPreviewFilename:PAnsiChar;pchVRFilename:PAnsiChar):TEVRScreenshotError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      SubmitScreenshot:function(screenshotHandle:TScreenshotHandle_t;_type:TEVRScreenshotType;pchSourcePreviewFilename:PAnsiChar;pchSourceVRFilename:PAnsiChar):TEVRScreenshotError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRResources_FnTable=^TVR_IVRResources_FnTable;
     TVR_IVRResources_FnTable=record
      LoadSharedResource:function(pchResourceName:PAnsiChar;pchBuffer:PAnsiChar;unBufferLen:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetResourceFullPath:function(pchResourceName:PAnsiChar;pchResourceTypeDirectory:PAnsiChar;pchPathBuffer:PAnsiChar;unBufferLen:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRDriverManager_FnTable=^TVR_IVRDriverManager_FnTable;
     TVR_IVRDriverManager_FnTable=record
      GetDriverCount:function:TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDriverName:function(nDriver:TDriverId_t;pchValue:PAnsiChar;unBufferSize:TpovrUInt32):TpovrUInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDriverHandle:function(pchDriverName:PAnsiChar):TDriverHandle_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRInput_FnTable=^TVR_IVRInput_FnTable;
     TVR_IVRInput_FnTable=record
      SetActionManifestPath:function(pchActionManifestPath:PAnsiChar):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetActionSetHandle:function(pchActionSetName:PAnsiChar;pHandle:PVRActionSetHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetActionHandle:function(pchActionName:PAnsiChar;pHandle:PVRActionHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetInputSourceHandle:function(pchInputSourcePath:PAnsiChar;pHandle:PVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      UpdateActionState:function(pSets:PVRActiveActionSet_t;unSizeOfVRSelectedActionSet_t:TpovrUInt32;unSetCount:TpovrUInt32):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetDigitalActionData:function(action:TVRActionHandle_t;pActionData:PInputDigitalActionData_t;unActionDataSize:TpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetAnalogActionData:function(action:TVRActionHandle_t;pActionData:PInputAnalogActionData_t;unActionDataSize:TpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetPoseActionData:function(action:TVRActionHandle_t;eOrigin:TETrackingUniverseOrigin;fPredictedSecondsFromNow:single;pActionData:PInputPoseActionData_t;unActionDataSize:TpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSkeletalActionData:function(action:TVRActionHandle_t;pActionData:PInputSkeletalActionData_t;unActionDataSize:TpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSkeletalBoneData:function(action:TVRActionHandle_t;eTransformSpace:TEVRSkeletalTransformSpace;eMotionRange:TEVRSkeletalMotionRange;pTransformArray:PVRBoneTransform_t;unTransformArrayCount:TpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSkeletalBoneDataCompressed:function(action:TVRActionHandle_t;eTransformSpace:TEVRSkeletalTransformSpace;eMotionRange:TEVRSkeletalMotionRange;pvCompressedData:pointer;unCompressedSize:TpovrUInt32;punRequiredCompressedSize:PpovrUInt32;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      DecompressSkeletalBoneData:function(pvCompressedBuffer:pointer;unCompressedBufferSize:TpovrUInt32;peTransformSpace:PEVRSkeletalTransformSpace;pTransformArray:PVRBoneTransform_t;unTransformArrayCount:TpovrUInt32):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      TriggerHapticVibrationAction:function(action:TVRActionHandle_t;fStartSecondsFromNow:single;fDurationSeconds:single;fFrequency:single;fAmplitude:single;ulRestrictToDevice:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetActionOrigins:function(actionSetHandle:TVRActionSetHandle_t;digitalActionHandle:TVRActionHandle_t;originsOut:PVRInputValueHandle_t;originOutCount:TpovrUInt32):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOriginLocalizedName:function(origin:TVRInputValueHandle_t;pchNameArray:PAnsiChar;unNameArraySize:TpovrUInt32):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetOriginTrackedDeviceInfo:function(origin:TVRInputValueHandle_t;pOriginInfo:PInputOriginInfo_t;unOriginInfoSize:TpovrUInt32):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowActionOrigins:function(actionSetHandle:TVRActionSetHandle_t;ulActionHandle:TVRActionHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      ShowBindingsForActionSet:function(pSets:PVRActiveActionSet_t;unSizeOfVRSelectedActionSet_t:TpovrUInt32;unSetCount:TpovrUInt32;originToHighlight:TVRInputValueHandle_t):TEVRInputError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRIOBuffer_FnTable=^TVR_IVRIOBuffer_FnTable;
     TVR_IVRIOBuffer_FnTable=record
      Open:function(pchPath:PAnsiChar;mode:TEIOBufferMode;unElementSize:TpovrUInt32;unElements:TpovrUInt32;pulBuffer:PIOBufferHandle_t):TEIOBufferError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      Close:function(ulBuffer:TIOBufferHandle_t):TEIOBufferError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      Read:function(ulBuffer:TIOBufferHandle_t;pDst:pointer;unBytes:TpovrUInt32;punRead:PpovrUInt32):TEIOBufferError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      Write:function(ulBuffer:TIOBufferHandle_t;pSrc:pointer;unBytes:TpovrUInt32):TEIOBufferError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      PropertyContainer:function(ulBuffer:TIOBufferHandle_t):TPropertyContainerHandle_t; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     PVR_IVRSpatialAnchors_FnTable=^TVR_IVRSpatialAnchors_FnTable;
     TVR_IVRSpatialAnchors_FnTable=record
      CreateSpatialAnchorFromDescriptor:function(pchDescriptor:PAnsiChar;pHandleOut:PSpatialAnchorHandle_t):TEVRSpatialAnchorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      CreateSpatialAnchorFromPose:function(unDeviceIndex:TTrackedDeviceIndex_t;eOrigin:TETrackingUniverseOrigin;pPose:PSpatialAnchorPose_t;pHandleOut:PSpatialAnchorHandle_t):TEVRSpatialAnchorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSpatialAnchorPose:function(unHandle:TSpatialAnchorHandle_t;eOrigin:TETrackingUniverseOrigin;pPoseOut:PSpatialAnchorPose_t):TEVRSpatialAnchorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
      GetSpatialAnchorDescriptor:function(unHandle:TSpatialAnchorHandle_t;pchDescriptorOut:PAnsiChar;punDescriptorBufferLenInOut:TpovrUInt32):TEVRSpatialAnchorError; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     end;

     TVR_InitInternal=function(peError:PEVRInitError;eType:TEVRApplicationType):TpovrIntPtr; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_ShutdownInternal=procedure; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_IsHmdPresent=function:Tbool; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_GetGenericInterface=function(pchInterfaceVersion:PAnsiChar;peError:PEVRInitError):TpovrIntPtr; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_IsRuntimeInstalled=function:Tbool; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_GetVRInitErrorAsSymbol=function(error:TEVRInitError):PAnsiChar; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TVR_GetVRInitErrorAsEnglishDescription=function(error:TEVRInitError):PAnsiChar; cdecl; //{$ifdef Windows}stdcall;{$else}cdecl;{$endif}

var VR_InitInternal:TVR_InitInternal=nil;
    VR_ShutdownInternal:TVR_ShutdownInternal=nil;
    VR_IsHmdPresent:TVR_IsHmdPresent=nil;
    VR_GetGenericInterface:TVR_GetGenericInterface=nil;
    VR_IsRuntimeInstalled:TVR_IsRuntimeInstalled=nil;
    VR_GetVRInitErrorAsSymbol:TVR_GetVRInitErrorAsSymbol=nil;
    VR_GetVRInitErrorAsEnglishDescription:TVR_GetVRInitErrorAsEnglishDescription=nil;

procedure LoadOpenVR(const aLibName:PChar); overload;
procedure LoadOpenVR; overload;
procedure FreeOpenVR;

{$endif}

implementation

{$ifdef TargetWithOpenVRSupport}
{$ifdef Windows}
type TLibHandle=HMODULE;
{$endif}

var OpenVRLibraryHandle:TLibHandle=0;

procedure LoadOpenVR(const aLibName:PChar);
begin
 FreeOpenVR;
 OpenVRLibraryHandle:=LoadLibrary(aLibName);
 if OpenVRLibraryHandle=0 then begin
  raise Exception.Create(Format('Could not load library: %s',[aLibName]));
 end else begin
  @VR_InitInternal:=GetProcAddress(OpenVRLibraryHandle,'VR_InitInternal');
  @VR_ShutdownInternal:=GetProcAddress(OpenVRLibraryHandle,'VR_ShutdownInternal');
  @VR_IsHmdPresent:=GetProcAddress(OpenVRLibraryHandle,'VR_IsHmdPresent');
  @VR_GetGenericInterface:=GetProcAddress(OpenVRLibraryHandle,'VR_GetGenericInterface');
  @VR_IsRuntimeInstalled:=GetProcAddress(OpenVRLibraryHandle,'VR_IsRuntimeInstalled');
  @VR_GetVRInitErrorAsSymbol:=GetProcAddress(OpenVRLibraryHandle,'VR_GetVRInitErrorAsSymbol');
  @VR_GetVRInitErrorAsEnglishDescription:=GetProcAddress(OpenVRLibraryHandle,'VR_GetVRInitErrorAsEnglishDescription');
 end;
end;

procedure LoadOpenVR;
begin
 LoadOpenVR(OpenVRLibraryName);
end;

procedure FreeOpenVR;
begin
 if OpenVRLibraryHandle<>0 then begin
  FreeLibrary(OpenVRLibraryHandle);
  OpenVRLibraryHandle:=0;
 end;
 VR_InitInternal:=nil;
 VR_ShutdownInternal:=nil;
 VR_IsHmdPresent:=nil;
 VR_GetGenericInterface:=nil;
 VR_IsRuntimeInstalled:=nil;
 VR_GetVRInitErrorAsSymbol:=nil;
 VR_GetVRInitErrorAsEnglishDescription:=nil;
end;
{$endif}

end.

