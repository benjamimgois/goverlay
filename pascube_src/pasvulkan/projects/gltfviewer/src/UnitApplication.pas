unit UnitApplication;
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

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Resources,
     PasVulkan.VirtualReality,
     PasVulkan.Scene3D.Renderer.Globals;

const ApplicationTag='gltftest';      

type TApplication=class(TpvApplication)
      public
      private
       fVirtualReality:TpvVirtualReality;
       fForceUseValidationLayers:boolean;
       fForceNoVSync:boolean;
       fMaxMSAA:TpvInt32;
       fMaxShadowMSAA:TpvInt32;
       fShadowMapSize:TpvInt32;
       fTransparencyMode:TpvScene3DRendererTransparencyMode;
       fAntialiasingMode:TpvScene3DRendererAntialiasingMode;
       fDepthOfFieldMode:TpvScene3DRendererDepthOfFieldMode;
       fShadowMode:TpvScene3DRendererShadowMode;
       fLensMode:TpvScene3DRendererLensMode;
       fMakeScreenshotJPEG:boolean;
       fMakeScreenshotPNG:boolean;
       fMakeScreenshotQOI:boolean;
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure SetupVulkanInstance(const aVulkanInstance:TpvVulkanInstance); override;
       procedure ChooseVulkanPhysicalDevice(var aVulkanPhysicalDevice:TpvVulkanPhysicalDevice); override;
       procedure SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice); override;
       procedure Setup; override;
       procedure Start; override;
       procedure Stop; override;
       procedure Load; override;
       procedure Unload; override;
       procedure AfterCreateSwapChain; override;
       procedure BeforeDestroySwapChain; override;
       procedure Resume; override;
       procedure Pause; override;
       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;
       procedure Check(const aDeltaTime:TpvDouble); override;
       procedure Update(const aDeltaTime:TpvDouble); override;
       procedure BeginFrame(const aDeltaTime:TpvDouble); override;
       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;
       procedure FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;
       procedure PostPresent(const aSwapChainImageIndex:TpvInt32); override;
      published
       property VirtualReality:TpvVirtualReality read fVirtualReality;
       property MaxMSAA:TpvInt32 read fMaxMSAA;
       property MaxShadowMSAA:TpvInt32 read fMaxShadowMSAA;
       property ShadowMapSize:TpvInt32 read fShadowMapSize;
       property TransparencyMode:TpvScene3DRendererTransparencyMode read fTransparencyMode;
       property AntialiasingMode:TpvScene3DRendererAntialiasingMode read fAntialiasingMode;
       property DepthOfFieldMode:TpvScene3DRendererDepthOfFieldMode read fDepthOfFieldMode;
       property ShadowMode:TpvScene3DRendererShadowMode read fShadowMode;
       property LensMode:TpvScene3DRendererLensMode read fLensMode;
     end;

var Application:TApplication=nil;

    GLTFFileName:UTF8String='';

implementation

uses PasVulkan.Scene3D.Renderer,
     UnitScreenMain;

constructor TApplication.Create;
var VirtualRealityMode:TpvVirtualReality.TMode;
{$if not (defined(Android) or defined(iOS))}
    Index:TpvInt32;
    OriginalParameter,Parameter:String;
{$ifend}
begin
 inherited Create;
 Application:=self;
 PasVulkan.Resources.AllowExternalResources:=true;
 fMakeScreenshotJPEG:=false;
 fMakeScreenshotPNG:=false;
 fMakeScreenshotQOI:=false;
 ExclusiveFullScreenMode:=TpvVulkanExclusiveFullScreenMode.Allowed;
 fForceUseValidationLayers:=false;
 fForceNoVSync:=false;
 VulkanNVIDIAAfterMath:=false;
 //WaitOnPreviousFrame:=true;
 fMaxMSAA:=0;
 fMaxShadowMSAA:=1;
 fShadowMapSize:=2048;
 fTransparencyMode:=TpvScene3DRendererTransparencyMode.Auto;
 fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.Auto;
 fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.None;
 fShadowMode:=TpvScene3DRendererShadowMode.Auto;
 fLensMode:=TpvScene3DRendererLensMode.Auto;
 VirtualRealityMode:=TpvVirtualReality.TMode.Disabled;
 AcceptDragDropFiles:=true;
{$if not (defined(Android) or defined(iOS))}
 Index:=1;
 while Index<=ParamCount do begin
  OriginalParameter:=ParamStr(Index);
  Parameter:=OriginalParameter;
  inc(Index);
  if (Parameter='--openvr') or
     (Parameter='/openvr') then begin
   VirtualRealityMode:=TpvVirtualReality.TMode.OpenVR;
  end else if (Parameter='--fakedvr') or
              (Parameter='/fakedvr') then begin
   VirtualRealityMode:=TpvVirtualReality.TMode.Faked;
  end else if (Parameter='--force-use-validation-layers') or
              (Parameter='/force-use-validation-layers') then begin
   fForceUseValidationLayers:=true;
  end else if (Parameter='--force-no-vsync') or
              (Parameter='/force-no-vsync') then begin
   fForceNoVSync:=true;
  end else if (Parameter='--nvidia-aftermath') or
              (Parameter='/nvidia-aftermath') then begin
   VulkanNVIDIAAfterMath:=true;
  end else if (Parameter='--prefer-dgpus') or
              (Parameter='/prefer-dgpus') then begin
   VulkanPreferDedicatedGPUs:=true;
  end else if (Parameter='--prefer-igpus') or
              (Parameter='/prefer-igpus') then begin
   VulkanPreferDedicatedGPUs:=false;
{ end else if (Parameter='--flush-update-data') or
              (Parameter='/flush-update-data') then begin
   FlushUpdateData:=true; //}
  end else if (Parameter='--max-msaa') or
              (Parameter='/max-msaa') then begin
   if Index<=ParamCount then begin
    fMaxMSAA:=StrToIntDef(ParamStr(Index),0);
    inc(Index);
   end;
  end else if (Parameter='--max-shadow-msaa') or
              (Parameter='/max-shadow-msaa') then begin
   if Index<=ParamCount then begin
    fMaxShadowMSAA:=StrToIntDef(ParamStr(Index),0);
    inc(Index);
   end;
  end else if (Parameter='--shadow-map-size') or
              (Parameter='/shadow-map-size') then begin
   if Index<=ParamCount then begin
    fShadowMapSize:=StrToIntDef(ParamStr(Index),0);
    inc(Index);
   end;
  end else if (Parameter='--transparency-mode') or
              (Parameter='/transparency-mode') then begin
   if Index<=ParamCount then begin
    Parameter:=LowerCase(trim(ParamStr(Index)));
    inc(Index);
    if Parameter='direct' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.Direct;
    end else if Parameter='spinlockoit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.SPINLOCKOIT;
    end else if Parameter='interlockoit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.INTERLOCKOIT;
    end else if Parameter='loopoit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.LOOPOIT;
    end else if Parameter='wboit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.WBOIT;
    end else if Parameter='mboit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.MBOIT;
    end else if Parameter='spinlockdfaoit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT;
    end else if Parameter='interlockdfaoit' then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT;
    end else begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.Auto;
    end;
   end;
  end else if (Parameter='--antialiasing-mode') or
              (Parameter='/antialiasing-mode') then begin
   if Index<=ParamCount then begin
    Parameter:=LowerCase(trim(ParamStr(Index)));
    inc(Index);
    if Parameter='none' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.None;
    end else if Parameter='dsaa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.DSAA;
    end else if Parameter='fxaa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.FXAA;
    end else if Parameter='smaa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.SMAA;
    end else if Parameter='msaa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.MSAA;
    end else if Parameter='msaasmaa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.MSAASMAA;
    end else if Parameter='taa' then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.TAA;
    end else begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.Auto;
    end;
   end;
  end else if (Parameter='--shadow-mode') or
              (Parameter='/shadow-mode') then begin
   if Index<=ParamCount then begin
    Parameter:=LowerCase(trim(ParamStr(Index)));
    inc(Index);
    if Parameter='none' then begin
     fShadowMode:=TpvScene3DRendererShadowMode.None;
    end else if Parameter='pcf' then begin
     fShadowMode:=TpvScene3DRendererShadowMode.PCF;
    end else if Parameter='dpcf' then begin
     fShadowMode:=TpvScene3DRendererShadowMode.DPCF;
    end else if Parameter='pcss' then begin
     fShadowMode:=TpvScene3DRendererShadowMode.PCSS;
    end else if Parameter='msm' then begin
     fShadowMode:=TpvScene3DRendererShadowMode.MSM;
    end else begin
     fShadowMode:=TpvScene3DRendererShadowMode.Auto;
    end;
   end;
  end else if (Parameter='--depth-of-field-mode') or
              (Parameter='/depth-of-field-mode') then begin
   if Index<=ParamCount then begin
    Parameter:=LowerCase(trim(ParamStr(Index)));
    inc(Index);
    if Parameter='none' then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.None;
    end else if Parameter='halfresseparatenearfar' then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.HalfResSeparateNearFar;
    end else if Parameter='halfresbruteforce' then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.HalfResBruteforce;
    end else if Parameter='fullreshexagon' then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.FullResHexagon;
    end else if Parameter='fullresbruteforce' then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.FullResBruteforce;
    end else begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.Auto;
    end;
   end;
  end else if (Parameter='--lens-mode') or
              (Parameter='/lens-mode') then begin
   if Index<=ParamCount then begin
    Parameter:=LowerCase(trim(ParamStr(Index)));
    inc(Index);
    if Parameter='none' then begin
     fLensMode:=TpvScene3DRendererLensMode.None;
    end else if Parameter='downupsample' then begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end else begin
     fLensMode:=TpvScene3DRendererLensMode.Auto;
    end;
   end;
  end else begin
   GLTFFileName:=OriginalParameter;
  end;
 end;
{$ifend}
 if VirtualRealityMode=TpvVirtualReality.TMode.Disabled then begin
  fVirtualReality:=nil;
 end else begin
  fVirtualReality:=TpvVirtualReality.Create(VirtualRealityMode);
  fVirtualReality.ZNear:=0.1;
  fVirtualReality.ZFar:=-Infinity;
 end;
end;

destructor TApplication.Destroy;
begin
 FreeAndNil(fVirtualReality);
 Application:=nil;
 inherited Destroy;
end;

procedure TApplication.SetupVulkanInstance(const aVulkanInstance:TpvVulkanInstance);
begin
 inherited SetupVulkanInstance(aVulkanInstance);
 if assigned(fVirtualReality) then begin
  fVirtualReality.CheckVulkanInstanceExtensions(aVulkanInstance);
  aVulkanInstance.EnabledExtensionNames.Duplicates:=TDuplicates.dupIgnore;
  aVulkanInstance.EnabledExtensionNames.AddStrings(fVirtualReality.RequiredVulkanInstanceExtensions);
 end;
end;

procedure TApplication.ChooseVulkanPhysicalDevice(var aVulkanPhysicalDevice:TpvVulkanPhysicalDevice);
var PhysicalDevice:TVkPhysicalDevice;
begin
 inherited ChooseVulkanPhysicalDevice(aVulkanPhysicalDevice);
 if assigned(fVirtualReality) and not (fVirtualReality.Mode in [TpvVirtualReality.TMode.Disabled,TpvVirtualReality.TMode.Faked]) then begin
  PhysicalDevice:=VK_NULL_HANDLE;
  fVirtualReality.ChooseVulkanPhysicalDevice(VulkanInstance,PhysicalDevice);
  pvApplication.VulkanPhysicalDeviceHandle:=PhysicalDevice;
 end;
end;

procedure TApplication.SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice);
begin
 inherited SetupVulkanDevice(aVulkanDevice);
 if assigned(fVirtualReality) then begin
  fVirtualReality.CheckVulkanDeviceExtensions(pvApplication.VulkanPhysicalDeviceHandle);
  aVulkanDevice.EnabledExtensionNames.Duplicates:=TDuplicates.dupIgnore;
  aVulkanDevice.EnabledExtensionNames.AddStrings(fVirtualReality.RequiredVulkanDeviceExtensions);
 end;
 TpvScene3DRenderer.SetupVulkanDevice(aVulkanDevice);
end;

procedure TApplication.Setup;
begin
 if Debugging or fForceUseValidationLayers then begin
  VulkanDebugging:=true;
  VulkanValidation:=true;
  VulkanShaderPrintfDebugging:=true;
 end;
 Title:='PasVulkan GLTF Viewer';
 PathName:='gltftest.pasvulkan';
 StartScreen:=TScreenMain;
 VisibleMouseCursor:=true;
 CatchMouse:=false;
 HideSystemBars:=true;
 AndroidSeparateMouseAndTouch:=true;
 UseAudio:=true;
 UpdateWaitsForGPU:=true;
 UseExtraUpdateThread:=false;
 SwapChainColorSpace:=TpvApplicationSwapChainColorSpace.SRGB;
//Blocking:=false;
//DesiredCountSwapChainImages:=2;
 DesiredCountInFlightFrames:=2;
 if fForceNoVSync or (assigned(fVirtualReality) and not (fVirtualReality.Mode in [TpvVirtualReality.TMode.Disabled,TpvVirtualReality.TMode.Faked])) then begin
  DesiredCountSwapChainImages:=2;
  PresentMode:=TpvApplicationPresentMode.Mailbox;
 end else begin
  PresentMode:=TpvApplicationPresentMode.FIFO;
 end;
// VulkanAPIVersion:=VK_API_VERSION_1_0;
 VulkanAPIVersion:=0;//VK_API_VERSION_1_0;
end;

procedure TApplication.Start;
begin
 inherited Start;
end;

procedure TApplication.Stop;
begin
 inherited Stop;
end;

procedure TApplication.Load;
begin

 if not VulkanMultiviewSupportEnabled then begin
  raise EpvVulkanException.Create('Missing Vulkan multi-view support');
 end;

 inherited Load;

 if assigned(fVirtualReality) then begin
  fVirtualReality.Load;
 end;

end;

procedure TApplication.Unload;
begin

 if assigned(fVirtualReality) then begin
  fVirtualReality.Unload;
 end;

 inherited Unload;

end;

procedure TApplication.AfterCreateSwapChain;
begin

 if assigned(fVirtualReality) then begin
  fVirtualReality.AfterCreateSwapChain;
 end;

 inherited AfterCreateSwapChain;

end;

procedure TApplication.BeforeDestroySwapChain;
begin

 inherited BeforeDestroySwapChain;

 if assigned(fVirtualReality) then begin
  fVirtualReality.BeforeDestroySwapChain;
 end;

end;

procedure TApplication.Resume;
begin
 inherited Resume;
end;

procedure TApplication.Pause;
begin
 inherited Pause;
end;

function TApplication.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=inherited KeyEvent(aKeyEvent);
 if aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down then begin
  case aKeyEvent.KeyCode of
   KEYCODE_F8:begin
    if assigned(VirtualReality) then begin
     VirtualReality.ResetOrientation;
    end;
   end;
   KEYCODE_F9:begin
    fMakeScreenshotQOI:=true;
   end;
   KEYCODE_F10:begin
    fMakeScreenshotJPEG:=true;
   end;
   KEYCODE_F11:begin
    fMakeScreenshotPNG:=true;
   end;
  end;
 end;
end;

procedure TApplication.Check(const aDeltaTime:TpvDouble);
begin
 if assigned(fVirtualReality) then begin
  fVirtualReality.Check(aDeltaTime);
 end;
 inherited Check(aDeltaTime);
end;

procedure TApplication.Update(const aDeltaTime:TpvDouble);
begin
 if assigned(fVirtualReality) then begin
  fVirtualReality.Update(aDeltaTime);
 end;
 inherited Update(aDeltaTime);
end;

procedure TApplication.BeginFrame(const aDeltaTime:TpvDouble);
begin
 if assigned(fVirtualReality) then begin
  fVirtualReality.BeginFrame(aDeltaTime);
 end;
 inherited BeginFrame(aDeltaTime);
end;

procedure TApplication.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
var Stream:TMemoryStream;
begin
 if assigned(fVirtualReality) then begin
  inherited Draw(aSwapChainImageIndex,aWaitSemaphore,nil);
  fVirtualReality.Draw(aSwapChainImageIndex,DrawInFlightFrameIndex,aWaitSemaphore,aWaitFence);
 end else begin
  inherited Draw(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end;
 if fMakeScreenshotJPEG then begin
  fMakeScreenshotJPEG:=false;
  Stream:=TMemoryStream.Create;
  try
   VulkanSwapChain.SaveScreenshotAsJPEGToStream(Stream);
   try
    Stream.SaveToFile('screenshot.jpeg');
   except
   end;
  finally
   Stream.Free;
  end;
 end else if fMakeScreenshotPNG then begin
  fMakeScreenshotPNG:=false;
  Stream:=TMemoryStream.Create;
  try
   VulkanSwapChain.SaveScreenshotAsPNGToStream(Stream);
   try
    Stream.SaveToFile('screenshot.png');
   except
   end;
  finally
   Stream.Free;
  end;
 end else if fMakeScreenshotQOI then begin
  fMakeScreenshotQOI:=false;
  Stream:=TMemoryStream.Create;
  try
   VulkanSwapChain.SaveScreenshotAsQOIToStream(Stream);
   try
    Stream.SaveToFile('screenshot.qoi');
   except
   end;
  finally
   Stream.Free;
  end;
 end;
end;

procedure TApplication.FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
 if assigned(fVirtualReality) then begin
  inherited FinishFrame(aSwapChainImageIndex,aWaitSemaphore,nil);
  fVirtualReality.FinishFrame(aSwapChainImageIndex,DrawInFlightFrameIndex,aWaitSemaphore,aWaitFence);
 end else begin
  inherited FinishFrame(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end;
end;

procedure TApplication.PostPresent(const aSwapChainImageIndex:TpvInt32);
begin
 inherited PostPresent(aSwapChainImageIndex);
 if assigned(fVirtualReality) then begin
  fVirtualReality.PostPresent(aSwapChainImageIndex,DrawInFlightFrameIndex);
 end;
end;

end.
