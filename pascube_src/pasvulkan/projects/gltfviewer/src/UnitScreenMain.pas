unit UnitScreenMain;
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

{$scopedenums on}

{$define UseMomentBasedOrderIndependentTransparency}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Resources,
     PasVulkan.FrameGraph,
     PasVulkan.TimerQuery,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.EnvironmentCubeMap,
     UnitVelocityCamera;

type { TScreenMain }
     TScreenMain=class(TpvApplicationScreen)
      public
       type TCameraMode=(
             Orbit,
             FirstPerson,
             VelocityCamera
            );
            PCameraMode=^TCameraMode;
            { TInFlightFrameState }
            TInFlightFrameState=record
             Ready:TPasMPBool32;
             UseView:TPasMPBool32;
             CameraViewMatrix:TpvMatrix4x4;
             View:TpvScene3D.TView;
            end;
            PInFlightFrameState=^TInFlightFrameState;
            TInFlightFrameStates=array[0..MaxInFlightFrames+1] of TInFlightFrameState;
            PInFlightFrameStates=^TInFlightFrameStates;
      private
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fCountInFlightFrames:TpvSizeInt;
       fInFlightFrameStates:TInFlightFrameStates;
       fScene3D:TpvScene3D;
       fRenderer:TpvScene3DRenderer;
       fRendererInstance:TpvScene3DRendererInstance;
       fPrimaryDirectionalLight:TpvScene3D.TLight;
       fGroup:TpvScene3D.TGroup;
       fGroupInstance:TpvScene3D.TGroup.TInstance;
       fTime:Double;
       fCameraMode:TCameraMode;
       fCameraRotationX:TpvScalar;
       fCameraRotationY:TpvScalar;
       fZoom:TpvScalar;
       fCameraIndex:TpvSizeInt;
       fCameraMatrix:TpvMatrix4x4;
       fCameraSpeed:TpvScalar;
       fUpdateLock:TPasMPCriticalSection;
       fAnimationIndex:TpvInt32;
       fKeyLeft:boolean;
       fKeyRight:boolean;
       fKeyForwards:boolean;
       fKeyBackwards:boolean;
       fKeyUp:boolean;
       fKeyDown:boolean;
       fKeyPitchInc:boolean;
       fKeyPitchDec:boolean;
       fKeyYawInc:boolean;
       fKeyYawDec:boolean;
       fKeyRollInc:boolean;
       fKeyRollDec:boolean;
       fOldFPS:TpvInt32;
       fFPSTimeAccumulator:TpvDouble;
       fFrameTimeString:string;
       fLoadedFileName:string;
       fLoadDelay:TpvInt32;
       fResetCameraOnLoad:Boolean;
       fVelocityCamera:TVelocityCamera;
      public

       constructor Create; override;

       destructor Destroy; override;

       procedure Show; override;

       procedure Hide; override;

       procedure Resume; override;

       procedure Pause; override;

       procedure Resize(const aWidth,aHeight:TpvInt32); override;

       procedure AfterCreateSwapChain; override;

       procedure BeforeDestroySwapChain; override;

       function CanBeParallelProcessed:boolean; override;

       procedure Check(const aDeltaTime:TpvDouble); override;

       procedure Update(const aDeltaTime:TpvDouble); override;

       function IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean; override;

       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;

       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; override;

       procedure OnFinish(const aResource:TpvResource;const aSuccess:boolean);

       procedure LoadGLTF(const aFileName:TpvUTF8String);

     end;

implementation

uses PasGLTF,
     UnitApplication,
     PasVulkan.Frustum;

{ TScreenMain }

constructor TScreenMain.Create;
var Center,Bounds:TpvVector3;
    CameraRotationX,CameraRotationY:TpvScalar;
    Stream:TStream;
begin
 inherited Create;

///writeln(SizeOf(TpvScene3D.TMaterial.TShaderData));

 fCountInFlightFrames:=pvApplication.CountInFlightFrames;

 fOldFPS:=-1;

 fFPSTimeAccumulator:=0;

 fAnimationIndex:=-2;

 fLoadedFileName:='';

 fLoadDelay:=0;

 fResetCameraOnLoad:=false;

 fCameraMode:=TCameraMode.Orbit;

 fVelocityCamera:=TVelocityCamera.Create;

 fKeyLeft:=false;
 fKeyRight:=false;
 fKeyForwards:=false;
 fKeyBackwards:=false;
 fKeyUp:=false;
 fKeyDown:=false;
 fKeyPitchInc:=false;
 fKeyPitchDec:=false;
 fKeyYawInc:=false;
 fKeyYawDec:=false;
 fKeyRollInc:=false;
 fKeyRollDec:=false;

 fUpdateLock:=TPasMPCriticalSection.Create;

 fScene3D:=TpvScene3D.Create(pvApplication.ResourceManager,nil,nil,pvApplication.VulkanDevice,TpvScene3DRenderer.CheckBufferDeviceAddress(pvApplication.VulkanDevice),fCountInFlightFrames,nil,UnitApplication.Application.VirtualReality);

 fScene3D.PasMPInstance:=pvApplication.PasMPInstance;

 fScene3D.InitialCountVertices:=65536;
 fScene3D.InitialCountIndices:=65536;
 fScene3D.InitialCountMorphTargetVertices:=65536;
 fScene3D.InitialCountJointBlocks:=65536;

 fScene3D.Initialize;

 fScene3D.EnvironmentMode:=TpvScene3DEnvironmentMode.Texture;

 if pvApplication.Assets.ExistAsset('envmap.hdr') then begin
  fScene3D.EnvironmentTextureImage:=TpvScene3D.TImage.Create(pvApplication.ResourceManager,fScene3D);
  fScene3D.EnvironmentIntensityFactor:=1.0;
  fScene3D.SkyBoxIntensityFactor:=1.0;
  Stream:=pvApplication.Assets.GetAssetStream('envmap.hdr');
  if assigned(Stream) then begin
   try
    fScene3D.EnvironmentTextureImage.AssignFromStream('$envmap$',Stream);
   finally
    FreeAndNil(Stream);
   end;
  end else begin
   fScene3D.EnvironmentTextureImage.AssignFromWhiteTexture;
  end;
  fScene3D.EnvironmentTextureImage.IncRef;
  fScene3D.EnvironmentTextureImage.Upload;

  fScene3D.SkyBoxMode:=TpvScene3DEnvironmentMode.Texture;

  if pvApplication.Assets.ExistAsset('skybox.hdr') then begin
   fScene3D.SkyBoxTextureImage:=TpvScene3D.TImage.Create(pvApplication.ResourceManager,fScene3D);
   fScene3D.SkyBoxIntensityFactor:=1.0;
   Stream:=pvApplication.Assets.GetAssetStream('skybox.hdr');
   if assigned(Stream) then begin
    try
     fScene3D.SkyBoxTextureImage.AssignFromStream('$skybox$',Stream);
    finally
     FreeAndNil(Stream);
    end;
   end else begin
    fScene3D.SkyBoxTextureImage.AssignFromWhiteTexture;
   end;
   fScene3D.SkyBoxTextureImage.IncRef;
   fScene3D.SkyBoxTextureImage.Upload;
  end;

 end;

 fPrimaryDirectionalLight:=TpvScene3D.TLight.Create(fScene3D);
 fPrimaryDirectionalLight.Type_:=TpvScene3D.TLightData.TType.PrimaryDirectional;
 fPrimaryDirectionalLight.Color:=TpvVector3.InlineableCreate(1.7,1.15,0.70);
 fPrimaryDirectionalLight.Matrix:=TpvMatrix4x4.CreateConstructZ(-fScene3D.PrimaryLightDirection);
 fPrimaryDirectionalLight.Intensity:=10000.0*fScene3D.EnvironmentIntensityFactor;
 fPrimaryDirectionalLight.Range:=0.0;
 fPrimaryDirectionalLight.CastShadows:=true;
 fPrimaryDirectionalLight.DataPointer^.Visible:=true;
 fPrimaryDirectionalLight.Visible:=true;
 fPrimaryDirectionalLight.Update;

 fScene3D.Upload;

 fRenderer:=TpvScene3DRenderer.Create(fScene3D,pvApplication.VulkanDevice,pvApplication.VulkanPipelineCache,fCountInFlightFrames);
 fRenderer.AntialiasingMode:=UnitApplication.Application.AntialiasingMode;
 fRenderer.ShadowMode:=UnitApplication.Application.ShadowMode;
 fRenderer.TransparencyMode:=UnitApplication.Application.TransparencyMode;
 fRenderer.DepthOfFieldMode:=UnitApplication.Application.DepthOfFieldMode;
 fRenderer.MaxMSAA:=UnitApplication.Application.MaxMSAA;
 fRenderer.MaxShadowMSAA:=UnitApplication.Application.MaxShadowMSAA;
 fRenderer.ShadowMapSize:=UnitApplication.Application.ShadowMapSize;
 fRenderer.GlobalIlluminationCaching:=false;
 fRenderer.ToneMappingMode:=TpvScene3DRendererToneMappingMode.AGXRec2020Punchy; //.KhronosPBRNeutral;
 fRenderer.Prepare;

 fRenderer.AcquirePersistentResources;

 fRendererInstance:=TpvScene3DRendererInstance.Create(fRenderer,UnitApplication.Application.VirtualReality);

 fRendererInstance.PixelAmountFactor:=1.0;

 fRendererInstance.UseDebugBlit:=false;

 fRendererInstance.LuminanceExponent:=1.0;
 fRendererInstance.LuminanceFactor:=4.0;

 fRendererInstance.CameraPreset.MinLogLuminance:=-3.5;
 fRendererInstance.CameraPreset.MaxLogLuminance:=8.0;

 fRendererInstance.Prepare;

 fRendererInstance.AcquirePersistentResources;

 Center:=TpvVector3.InlineableCreate(0.0,0.0,0.0);

 Bounds:=TpvVector3.InlineableCreate(10.0,10.0,10.0);

 fCameraSpeed:=1.0;

 CameraRotationX:=0.0;
 CameraRotationY:=0.0;

 fCameraIndex:=-1;

 fCameraMatrix:=TpvMatrix4x4.CreateLookAt(Center+(TpvVector3.Create(sin(CameraRotationX*PI*2.0)*cos(-CameraRotationY*PI*2.0),
                                                                    sin(-CameraRotationY*PI*2.0),
                                                                    cos(CameraRotationX*PI*2.0)*cos(-CameraRotationY*PI*2.0)).Normalize*
                                                           (Max(Max(Bounds[0],Bounds[1]),Bounds[2])*2.0*1.0)),
                                           Center,
                                           TpvVector3.Create(0.0,1.0,0.0)).SimpleInverse;

 if {(fFrameGraph.DrawFrameIndex>=fFrameGraph.CountInFlightFrames) and} (length(GLTFFileName)>0) then begin
  try
   LoadGLTF(GLTFFileName);
  finally
   GLTFFileName:='';
  end;
 end;

 FillChar(fInFlightFrameStates,SizeOf(TInFlightFrameStates),#0);

end;

destructor TScreenMain.Destroy;
var Index:TpvSizeInt;
begin
 fRendererInstance.ReleasePersistentResources;
 FreeAndNil(fRendererInstance);
 fRenderer.ReleasePersistentResources;
 FreeAndNil(fRenderer);
 fScene3D.Unload;
 FreeAndNil(fGroupInstance);
 FreeAndNil(fGroup);
 FreeAndNil(fPrimaryDirectionalLight);
 FreeAndNil(fScene3D);
 FreeAndNil(fUpdateLock);
 FreeAndNil(fVelocityCamera);
 inherited Destroy;
end;

procedure TScreenMain.Show;
var Index:TpvSizeInt;
    Stream:TStream;
    GraphicsQueue:TpvVulkanQueue;
    GraphicsCommandPool:TpvVulkanCommandPool;
    GraphicsCommandBuffer:TpvVulkanCommandBuffer;
    GraphicsFence:TpvVulkanFence;
begin

 inherited Show;

 fTime:=0.0;

 fCameraRotationX:=0.0;//frac(fTime*0.03125);

 fCameraRotationY:=0.0;

 fZoom:=1.0;

 pvApplication.SkipNextDrawFrame:=true;

 FillChar(fInFlightFrameStates,SizeOf(TInFlightFrameStates),#0);

end;

procedure TScreenMain.Hide;
begin
 inherited Hide;
end;

procedure TScreenMain.Resume;
begin
 inherited Resume;
 pvApplication.SkipNextDrawFrame:=true;
end;

procedure TScreenMain.Pause;
begin
 inherited Pause;
end;

procedure TScreenMain.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
 pvApplication.SkipNextDrawFrame:=true;
end;

procedure TScreenMain.AfterCreateSwapChain;
var Index:TpvSizeInt;
begin

 inherited AfterCreateSwapChain;

 if assigned(UnitApplication.Application.VirtualReality) then begin

  fWidth:=UnitApplication.Application.VirtualReality.Width;

  fHeight:=UnitApplication.Application.VirtualReality.Height;

 end else begin

  fWidth:=pvApplication.VulkanSwapChain.Width;

  fHeight:=pvApplication.VulkanSwapChain.Height;

 end;

 fRendererInstance.Width:=fWidth;
 fRendererInstance.Height:=fHeight;

 fRendererInstance.AcquireVolatileResources;

 fScene3D.ResetSurface;

end;

procedure TScreenMain.BeforeDestroySwapChain;
var Index:TpvSizeInt;
begin
 fRendererInstance.ReleaseVolatileResources;
 inherited BeforeDestroySwapChain;
end;

function TScreenMain.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenMain.Check(const aDeltaTime:TpvDouble);
begin
 inherited Check(aDeltaTime);
 if fLoadDelay>0 then begin
  dec(fLoadDelay);
  if fLoadDelay=0 then begin
// pvApplication.ResourceManager.BackgroundLoadResource(TpvScene3D.TGroup,fLoadedFileName,OnFinish,fScene3D);
  end;
 end;
 fScene3D.Check(pvApplication.UpdateInFlightFrameIndex);
end;

procedure TScreenMain.Update(const aDeltaTime:TpvDouble);
const Directions:array[boolean,boolean] of TpvScalar=
       (
        (0,1),
        (-1,0)
       );
var InFlightFrameIndex,Index:TpvSizeInt;
    InFlightFrameState:PInFlightFrameState;
    RotationSpeed,MovementSpeed:TpvDouble;
    FPS:TpvInt32;
    FPSString:string;
    FrameTime:TpvDouble;
    ModelMatrix,CameraMatrix,ViewMatrix,ProjectionMatrix:TpvMatrix4x4;
    Center,Bounds:TpvVector3;
    t0,t1:Double;
    View:TpvScene3D.TView;
    BlendFactor,Factor:single;
begin

 InFlightFrameIndex:=pvApplication.UpdateInFlightFrameIndex;

 InFlightFrameState:=@fInFlightFrameStates[InFlightFrameIndex];

 RotationSpeed:=aDeltaTime*1.0;
 MovementSpeed:=aDeltaTime*1.0*fCameraSpeed;

 case fCameraMode of
  TCameraMode.VelocityCamera:begin
   fVelocityCamera.KeyLeft:=fKeyLeft;
   fVelocityCamera.KeyRight:=fKeyRight;
   fVelocityCamera.KeyUp:=fKeyUp;
   fVelocityCamera.KeyDown:=fKeyDown;
   fVelocityCamera.KeyForward:=fKeyForwards;
   fVelocityCamera.KeyBackward:=fKeyBackwards;
   fVelocityCamera.KeyPitchUp:=fKeyPitchInc;
   fVelocityCamera.KeyPitchDown:=fKeyPitchDec;
   fVelocityCamera.KeyYawLeft:=fKeyYawInc;
   fVelocityCamera.KeyYawRight:=fKeyYawDec;
   fVelocityCamera.KeyRollLeft:=fKeyRollInc;
   fVelocityCamera.KeyRollRight:=fKeyRollDec;
   fVelocityCamera.Update(aDeltaTime);
  end;
  else begin
   if fKeyPitchInc or fKeyPitchDec or fKeyYawInc or fKeyYawDec or fKeyRollInc or fKeyRollDec then begin
    fCameraMatrix:=(TpvMatrix4x4.CreateFromQuaternion(TpvQuaternion.CreateFromEuler(TpvVector3.Create(Directions[fKeyPitchInc,fKeyPitchDec],
                                                                                                      Directions[fKeyYawDec,fKeyYawInc],
                                                                                                      Directions[fKeyRollInc,fKeyRollDec])*-RotationSpeed).Normalize)*fCameraMatrix).OrthoNormalize;
   end;
   if fKeyLeft or fKeyRight or fKeyForwards or fKeyBackwards or fKeyUp or fKeyDown then begin
    fCameraMatrix:=fCameraMatrix*
                   TpvMatrix4x4.CreateTranslation((fCameraMatrix.ToMatrix3x3*
                                                   TpvVector3.InlineableCreate(Directions[fKeyLeft,fKeyRight],
                                                                               Directions[fKeyDown,fKeyUp],
                                                                               Directions[fKeyForwards,fKeyBackwards]))*MovementSpeed);
   end;
  end;
 end;


 fRendererInstance.Update(InFlightFrameIndex,pvApplication.UpdateFrameCounter);

 FPS:=round(pvApplication.FramesPerSecond*100.0);
 fFPSTimeAccumulator:=fFPSTimeAccumulator+aDeltaTime;
 if (fFPSTimeAccumulator>=0.25) or (length(fFrameTimeString)=0) then begin
  fFPSTimeAccumulator:=frac(fFPSTimeAccumulator*4)*0.25;
  fOldFPS:=Low(Int32);
  if assigned(fRendererInstance.FrameGraph.LastTimerQueryResults) then begin
   FrameTime:=fRendererInstance.FrameGraph.LastTimerQueryResults[fRendererInstance.FrameGraph.LastTimerQueryResults.Count-1].Duration;
  end else begin
   FrameTime:=0.0;
  end;
  Str(FrameTime*1000.0:1:5,fFrameTimeString);
 end;

 if abs(fOldFPS-FPS)>=100 then begin
  fOldFPS:=FPS;
  str((FPS*0.01):4:2,FPSString);
  pvApplication.WindowTitle:=pvApplication.Title+' ['+FPSString+' FPS] ['+fFrameTimeString+' ms frame time]';
 end;

 fUpdateLock.Acquire;
 try

  ModelMatrix:=TpvMatrix4x4.Identity; // TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));

  if assigned(fGroupInstance) then begin

   fGroupInstance.ModelMatrix:=ModelMatrix;

   BlendFactor:=1.0-exp(-(pvApplication.DeltaTime*4.0));

   if fAnimationIndex=-2 then begin
    if fGroupInstance.Group.Animations.Count>0 then begin
     fGroupInstance.Animations[-1].Time:=0;
     fGroupInstance.Animations[-1].ShadowTime:=-0;
     fGroupInstance.Animations[-1].Complete:=false;
     Factor:=fGroupInstance.Animations[-1].Factor;
     if Factor>0.0 then begin
      Factor:=Factor*(1.0-BlendFactor);
      if Factor<1e-5 then begin
       Factor:=-1.0;
      end;
     end;
     fGroupInstance.Animations[-1].Factor:=0.0;
     for Index:=0 to fGroupInstance.Group.Animations.Count-1 do begin
      t0:=fGroupInstance.Group.Animations[Index].GetAnimationBeginTime;
      t1:=fGroupInstance.Group.Animations[Index].GetAnimationEndTime;
      fGroupInstance.Animations[Index].Time:=fGroupInstance.Animations[Index].ShadowTime+t0;
      fGroupInstance.Animations[Index].ShadowTime:=ModuloPos(fGroupInstance.Animations[Index].ShadowTime+(pvApplication.DeltaTime*1.0),t1-t0);
      fGroupInstance.Animations[Index].Complete:=false;
      Factor:=fGroupInstance.Animations[Index].Factor;
      if Factor<0.0 then begin
       Factor:=0.0;
       fGroupInstance.Animations[Index].ShadowTime:=0.0;
      end;
      Factor:=(Factor*(1.0-BlendFactor))+(1.0*BlendFactor);
      fGroupInstance.Animations[Index].Factor:=Factor;
     end;
    end else begin
     fGroupInstance.Animations[-1].Time:=0;
     fGroupInstance.Animations[-1].ShadowTime:=-0;
     fGroupInstance.Animations[-1].Complete:=true;
     fGroupInstance.Animations[-1].Factor:=0.0;
    end;
   end else begin
    for Index:=-1 to fGroupInstance.Group.Animations.Count-1 do begin
     Factor:=fGroupInstance.Animations[Index].Factor;
     if Index=fAnimationIndex then begin
      if Factor<0.0 then begin
       Factor:=0.0;
       fGroupInstance.Animations[Index].ShadowTime:=0.0;
      end;
      Factor:=(Factor*(1.0-BlendFactor))+(1.0*BlendFactor);
     end else if Factor>0.0 then begin
      Factor:=Factor*(1.0-BlendFactor);
      if Factor<1e-5 then begin
       Factor:=-1.0;
      end;
     end;
     if Factor>0.0 then begin
      if Index>=0 then begin
       t0:=fGroupInstance.Group.Animations[Index].GetAnimationBeginTime;
       t1:=fGroupInstance.Group.Animations[Index].GetAnimationEndTime;
       fGroupInstance.Animations[Index].Time:=fGroupInstance.Animations[Index].ShadowTime+t0;
       fGroupInstance.Animations[Index].ShadowTime:=ModuloPos(fGroupInstance.Animations[Index].ShadowTime+pvApplication.DeltaTime,t1-t0);
       fGroupInstance.Animations[Index].Complete:=true;
      end else begin
       fGroupInstance.Animations[Index].Time:=0.0;
       fGroupInstance.Animations[Index].Complete:=false;
      end;
     end else begin
      fGroupInstance.Animations[Index].Time:=0.0;
     end;
     fGroupInstance.Animations[Index].Factor:=Factor;
    end;
   end;//}

  end;

  fScene3D.SceneTimes[InFlightFrameIndex]:=fTime;

  fScene3D.Update(InFlightFrameIndex);

  Center:=(fScene3D.BoundingBox.Min+fScene3D.BoundingBox.Max)*0.5;

  Bounds:=(fScene3D.BoundingBox.Max-fScene3D.BoundingBox.Min)*0.5;

  case fCameraMode of
   TCameraMode.VelocityCamera:begin
    ViewMatrix:=fVelocityCamera.Matrix.SimpleInverse;//TpvMatrix4x4.CreateTranslation(-fCameraPosition)*TpvMatrix4x4.CreateFromQuaternion(fCameraOrientation);
    fCameraMatrix:=ViewMatrix.SimpleInverse;
   end;
   TCameraMode.FirstPerson:begin
    ViewMatrix:=fCameraMatrix.SimpleInverse;//TpvMatrix4x4.CreateTranslation(-fCameraPosition)*TpvMatrix4x4.CreateFromQuaternion(fCameraOrientation);
   end;
   else begin
    ViewMatrix:=TpvMatrix4x4.CreateLookAt(Center+(TpvVector3.Create(sin(fCameraRotationX*PI*2.0)*cos(-fCameraRotationY*PI*2.0),
                                                                    sin(-fCameraRotationY*PI*2.0),
                                                                    cos(fCameraRotationX*PI*2.0)*cos(-fCameraRotationY*PI*2.0)).Normalize*
                                                          (Max(Max(Bounds[0],Bounds[1]),Bounds[2])*2.0*fZoom)),
                                          Center,
                                          TpvVector3.Create(0.0,1.0,0.0));//*TpvMatrix4x4.FlipYClipSpace;
    fCameraMatrix:=ViewMatrix.SimpleInverse;
   end;
  end;

  InFlightFrameState^.UseView:=false;

  if assigned(fGroup) and
     assigned(fGroupInstance) and
     (fGroup.CameraNodeIndices.Count>0) and
     (fCameraIndex>=0) and
     (fCameraIndex<fGroup.CameraNodeIndices.Count) then begin
   if fGroupInstance.GetCamera(fGroup.CameraNodeIndices[fCameraIndex],
                               CameraMatrix,
                               ViewMatrix,
                               ProjectionMatrix,
                               true,
                               true,
                               nil,
                               nil,
                               -(fRendererInstance.Width/fRendererInstance.Height)) then begin
    InFlightFrameState^.CameraViewMatrix:=CameraMatrix.SimpleInverse;
    if not assigned(UnitApplication.Application.VirtualReality) then begin
     View.ViewMatrix:=ViewMatrix;
     View.ProjectionMatrix:=ProjectionMatrix;
     View.InverseViewMatrix:=ViewMatrix.Inverse;
     View.InverseProjectionMatrix:=ProjectionMatrix.Inverse;
     InFlightFrameState^.UseView:=true;
     InFlightFrameState^.View:=View;
    end;
   end else begin
    InFlightFrameState^.CameraViewMatrix:=fCameraMatrix.SimpleInverse;
   end;
  end else begin
   InFlightFrameState^.CameraViewMatrix:=fCameraMatrix.SimpleInverse;
  end;

  fTime:=fTime+pvApplication.DeltaTime;

 finally
  fUpdateLock.Release;
 end;

 fScene3D.ResetFrame(InFlightFrameIndex);

 fScene3D.PrepareFrame(InFlightFrameIndex);

 fRendererInstance.ResetFrame(InFlightFrameIndex);

 fRendererInstance.CameraViewMatrices[InFlightFrameIndex]:=InFlightFrameState^.CameraViewMatrix;

 if InFlightFrameState^.UseView then begin
  fRendererInstance.AddView(InFlightFrameIndex,InFlightFrameState^.View);
 end;

 fRendererInstance.PrepareFrame(InFlightFrameIndex,pvApplication.DrawFrameCounter);

 TPasMPInterlocked.Write(InFlightFrameState^.Ready,true);

 inherited Update(aDeltaTime);

end;

function TScreenMain.IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean;
begin
 result:=TPasMPInterlocked.Read(fInFlightFrameStates[aInFlightFrameIndex].Ready);
end;

procedure TScreenMain.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
var InFlightFrameState:TScreenMain.PInFlightFrameState;
    InFlightFrameIndex:Int32;
begin

 inherited Draw(aSwapChainImageIndex,aWaitSemaphore,nil);

 InFlightFrameIndex:=pvApplication.DrawInFlightFrameIndex;

 InFlightFrameState:=@fInFlightFrameStates[InFlightFrameIndex];

 fScene3D.BeginFrame(InFlightFrameIndex,aWaitSemaphore,nil);

 fRendererInstance.UploadFrame(InFlightFrameIndex);

 fScene3D.UploadFrame(InFlightFrameIndex);

 fScene3D.ProcessFrame(InFlightFrameIndex,aWaitSemaphore,nil);

 fRendererInstance.DrawFrame(pvApplication.SwapChainImageIndex,
                             pvApplication.DrawInFlightFrameIndex,
                             pvApplication.DrawFrameCounter,
                             aWaitSemaphore,
                             nil);

 fScene3D.EndFrame(InFlightFrameIndex,aWaitSemaphore,aWaitFence);

 TPasMPInterlocked.Write(InFlightFrameState^.Ready,false);

end;

function TScreenMain.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
var Index:TpvSizeInt;
    StringList:TStringList;
begin
 result:=inherited KeyEvent(aKeyEvent);
 if aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Typed then begin
  case aKeyEvent.KeyCode of
   KEYCODE_F5:begin
    if length(fLoadedFileName)>0 then begin
     fResetCameraOnLoad:=not (TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers);
     LoadGLTF(fLoadedFileName);
    end;
   end;
  end;
 end else if aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down then begin
  case aKeyEvent.KeyCode of
   KEYCODE_ESCAPE:begin
    pvApplication.Terminate;
   end;
   KEYCODE_F8:begin
    if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.SHIFT])=[TpvApplicationInputKeyModifier.CTRL] then begin
     pvApplication.DumpVulkanMemoryManager;
     StringList:=TStringList.Create;
     try
      pvApplication.VulkanDevice.MemoryManager.DumpJSON(StringList);
      StringList.SaveToFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'vulkanmemory.json');
     finally
      FreeAndNil(StringList);
     end;
     result:=true;
    end else if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.SHIFT])=[TpvApplicationInputKeyModifier.SHIFT] then begin
     if assigned(fScene3D) then begin
      StringList:=TStringList.Create;
      try
       fScene3D.DumpMemoryUsage(StringList);
       StringList.SaveToFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'scene3dmemoryusage.log');
       for Index:=0 to StringList.Count-1 do begin
        pvApplication.Log(LOG_VERBOSE,'TpvScene3D',StringList.Strings[Index]);
       end;
      finally
       FreeAndNil(StringList);
      end;
     end;
    end else if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.SHIFT])=[] then begin
     if assigned(fScene3D) then begin
      fScene3D.DumpProfiler;
     end;
    end;
   end;
   KEYCODE_U:begin
    fCameraSpeed:=fCameraSpeed*0.5;
   end;
   KEYCODE_I:begin
    fCameraSpeed:=fCameraSpeed*2.0;
   end;
   KEYCODE_O:begin
    fCameraMode:=TCameraMode.Orbit;
   end;
   KEYCODE_P:begin
    fCameraMode:=TCameraMode.FirstPerson;
   end;
   KEYCODE_Z:begin
    fCameraMode:=TCameraMode.VelocityCamera;
    fVelocityCamera.SetPositionAndOrientation(fCameraMatrix.Translation.xyz,fCameraMatrix.ToQuaternion);
   end;
   KEYCODE_L:begin
    pvApplication.CatchMouse:=not pvApplication.CatchMouse;
    pvApplication.VisibleMouseCursor:=not pvApplication.CatchMouse;
    pvApplication.RelativeMouse:=pvApplication.CatchMouse;
   end;
   KEYCODE_B:begin
    if assigned(fGroupInstance) then begin
     if fAnimationIndex<-1 then begin
      fAnimationIndex:=fGroupInstance.Group.Animations.Count-1;
     end else begin
      dec(fAnimationIndex);
     end;
    end;
   end;
   KEYCODE_N:begin
    if assigned(fGroupInstance) then begin
     inc(fAnimationIndex);
     if fAnimationIndex>=fGroupInstance.Group.Animations.Count then begin
      fAnimationIndex:=-2;
     end;
    end;
   end;
   KEYCODE_0..KEYCODE_9:begin
    if assigned(fGroupInstance) then begin
     if ((aKeyEvent.KeyCode-(KEYCODE_0+1))>=-1) and ((aKeyEvent.KeyCode-(KEYCODE_0+1))<fGroupInstance.Group.Animations.Count) then begin
      fAnimationIndex:=aKeyEvent.KeyCode-(KEYCODE_0+1);
     end;
    end;
   end;
   KEYCODE_M:begin
    if assigned(fGroupInstance) then begin
     fAnimationIndex:=-2;
    end;
   end;
   KEYCODE_BACKSPACE:begin
    if abs(PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.y*PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.y)<0.5 then begin
     PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.x:=0.0;
     PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.y:=1.0;
     PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.z:=0.0;
    end else begin
     PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^).Normalize;
    end;
    PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^).Normalize;
    PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^).Normalize;
    PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^).Normalize;
    fCameraMatrix:=fCameraMatrix.RobustOrthoNormalize;
   end;
  end;
 end;
 if aKeyEvent.KeyEventType in [TpvApplicationInputKeyEventType.Down,TpvApplicationInputKeyEventType.Up] then begin
  case aKeyEvent.KeyCode of
   KEYCODE_LEFT,KEYCODE_A:begin
    fKeyLeft:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_RIGHT,KEYCODE_D:begin
    fKeyRight:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_UP,KEYCODE_W:begin
    fKeyForwards:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_DOWN,KEYCODE_S:begin
    fKeyBackwards:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_PAGEUP,KEYCODE_R:begin
    fKeyUp:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_PAGEDOWN,KEYCODE_F:begin
    fKeyDown:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_T:begin
    fKeyPitchInc:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_G:begin
    fKeyPitchDec:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_E:begin
    fKeyYawInc:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_Q:begin
    fKeyYawDec:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_X:begin
    fKeyRollInc:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_C:begin
    fKeyRollDec:=aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down;
   end;
   KEYCODE_HOME:begin
    if (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) and assigned(fGroup) then begin
     inc(fCameraIndex);
     if fCameraIndex>=fGroup.CameraNodeIndices.Count then begin
      fCameraIndex:=-1;
     end;
    end;
   end;
   KEYCODE_END:begin
    if (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) and assigned(fGroup) then begin
     dec(fCameraIndex);
     if fCameraIndex<=-2 then begin
      fCameraIndex:=fGroup.CameraNodeIndices.Count-1;
     end;
    end;
   end;
  end;
 end;
end;

function TScreenMain.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 result:=inherited PointerEvent(aPointerEvent);
 if not result then begin
  if (aPointerEvent.PointerEventType=TpvApplicationInputPointerEventType.Motion) and
     (pvApplication.CatchMouse or (TpvApplicationInputPointerButton.Left in aPointerEvent.Buttons)) then begin
   fUpdateLock.Acquire;
   try
    case fCameraMode of
     TCameraMode.VelocityCamera:begin
     end;
     TCameraMode.FirstPerson:begin
      fCameraMatrix:=TpvMatrix4x4.CreateFromQuaternion(TpvQuaternion.CreateFromEuler(TpvVector3.InlineableCreate(aPointerEvent.RelativePosition.y,aPointerEvent.RelativePosition.x,0.0)*0.002)).Transpose*fCameraMatrix;
      if abs(PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.y*PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.y)<0.5 then begin
       PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.x:=0.0;
       PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.y:=1.0;
       PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.z:=0.0;
      end else begin
       PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^).Normalize;
      end;
      PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^).Normalize;
      PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^).Normalize;
      PpvVector3(pointer(@fCameraMatrix.RawComponents[2,0]))^:=PpvVector3(pointer(@fCameraMatrix.RawComponents[0,0]))^.Cross(PpvVector3(pointer(@fCameraMatrix.RawComponents[1,0]))^).Normalize;
      fCameraMatrix:=fCameraMatrix.RobustOrthoNormalize;
     end;
     else begin
      fCameraRotationX:=frac(fCameraRotationX+(1.0-(aPointerEvent.RelativePosition.x*(1.0/pvApplication.VulkanSwapChain.Width))));
      fCameraRotationY:=frac(fCameraRotationY+(1.0-(aPointerEvent.RelativePosition.y*(1.0/pvApplication.VulkanSwapChain.Height))));
     end;
    end;
   finally
    fUpdateLock.Release;
   end;
   result:=true;
  end;
 end;
end;

function TScreenMain.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=inherited Scrolled(aRelativeAmount);
 if not result then begin
  fUpdateLock.Acquire;
  try
   case fCameraMode of
    TCameraMode.VelocityCamera:begin
    end;
    TCameraMode.FirstPerson:begin
     fCameraMatrix:=fCameraMatrix*TpvMatrix4x4.CreateTranslation((fCameraMatrix.ToMatrix3x3*TpvVector3.ZAxis).Normalize*(aRelativeAmount.x+aRelativeAmount.y)*fCameraSpeed);
    end;
    else begin
     fZoom:=Max(1e-4,fZoom+((aRelativeAmount.x+aRelativeAmount.y)*0.1));
    end;
   end;
  finally
   fUpdateLock.Release;
  end;
  result:=true;
 end;
end;

function TScreenMain.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
begin
 LoadGLTF(aFileName);
 result:=true;
end;

procedure TScreenMain.OnFinish(const aResource:TpvResource;const aSuccess:boolean);
var Center,Bounds:TpvVector3;
    CameraRotationX,CameraRotationY:TpvScalar;
    BakedMesh:TpvScene3D.TBakedMesh;
    FileStream:TFileStream;
begin

 if assigned(aResource) and (aResource is TpvScene3D.TGroup) then begin

  if assigned(fGroupInstance) then begin
   fGroupInstance.DeferredFree;
   fGroupInstance:=nil;
  end;

  if assigned(fGroup) then begin
   fGroup.DeferredFree;
   fGroup:=nil;
  end;

  fGroup:=TpvScene3D.TGroup(aResource);
//fGroup.DynamicAABBTreeCulling:=true;

  fGroupInstance:=fGroup.CreateInstance;

{ fGroupInstance.Update(-1);
  BakedMesh:=fGroupInstance.GetBakedMesh(false,false,-1,[TpvScene3D.TMaterial.TAlphaMode.Opaque]);
  if assigned(BakedMesh) then begin
   try
    fScene3D.PotentiallyVisibleSet.Build(BakedMesh);
    FileStream:=TFileStream.Create(ChangeFileExt(aResource.FileName,'.pvs'),fmCreate);
    try
     fScene3D.PotentiallyVisibleSet.Save(FileStream);
    finally
     FreeAndNil(FileStream);
    end;
   finally
    FreeAndNil(BakedMesh);
   end;
  end;//}

  if not fResetCameraOnLoad then begin

   fCameraIndex:=-1;

   if assigned(fGroup) then begin

    Center:=(fGroup.BoundingBox.Min+fGroup.BoundingBox.Max)*0.5;

    Bounds:=(fGroup.BoundingBox.Max-fGroup.BoundingBox.Min)*0.5;

    fCameraSpeed:=Max(1.0,fGroup.BoundingBox.Radius)*0.1;

   end else begin

    Center:=TpvVector3.InlineableCreate(0.0,0.0,0.0);

    Bounds:=TpvVector3.InlineableCreate(10.0,10.0,10.0);

    fCameraSpeed:=1.0;

   end;

   CameraRotationX:=0.0;
   CameraRotationY:=0.0;

   fZoom:=1.0;

   fCameraMatrix:=TpvMatrix4x4.CreateLookAt(Center+(TpvVector3.Create(sin(CameraRotationX*PI*2.0)*cos(-CameraRotationY*PI*2.0),
                                                                       sin(-CameraRotationY*PI*2.0),
                                                                       cos(CameraRotationX*PI*2.0)*cos(-CameraRotationY*PI*2.0)).Normalize*
                                                             (Max(Max(Bounds[0],Bounds[1]),Bounds[2])*2.0*1.0)),
                                             Center,
                                             TpvVector3.Create(0.0,1.0,0.0)).SimpleInverse;

   fCameraRotationX:=0.0;
   fCameraRotationY:=0.0;

  end;

 end;

 fResetCameraOnLoad:=false;

{if fGroupInstance.Group.Animations.Count>=1 then begin
  fAnimationIndex:=1;
 end;}

end;

procedure TScreenMain.LoadGLTF(const aFileName:TpvUTF8String);
begin

 if assigned(fGroupInstance) then begin
  fGroupInstance.DeferredFree;
  fGroupInstance:=nil;
 end;

 if assigned(fGroup) then begin
  fGroup.DeferredFree;
  fGroup:=nil;
 end;

 fLoadedFileName:=aFileName;
 fLoadDelay:=(pvApplication.CountInFlightFrames*2)+1;

 pvApplication.ResourceManager.BackgroundLoadResource(TpvScene3D.TGroup,fLoadedFileName,OnFinish,fScene3D);

 pvApplication.SetFocus;

end;

end.
