unit UnitPasCubeScreen;
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
     DateUtils,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     UnitBenchmarkPhysics,
     fpjson,
     jsonparser;

const CountTextures=1;
      MAX_BENCHMARK_HISTORY = 10;
      BENCHMARK_VERSION = '1.0';

type
  TBenchmarkPhase = (
   bpIdleMenu,
   bpWarmup,
   bpPhase1_CPU_Light,
   bpPhase2_CPU_Med,
   bpPhase3_CPU_Heavy,
   bpPhase4_GPU_Lights,
   bpPhase5_GPU_Particles,
   bpPhase6_Combined,
   bpResults
  );

  TResolutionOption = (
   ro720p,
   ro1080p,
   roNative
  );

  TBenchmarkPhaseResult = record
   PhaseName: String;
   Score: Integer;
   FPSAvg: Double;
   FPSMin: Double;
   FPSMax: Double;
   FrameTimeMs: Double;
   ObjectsRendered: Integer;
   ParticlesActive: Integer;
   LightsActive: Integer;
   PhysicsBodies: Integer;
  end;

  TBenchmarkResult = record
   Timestamp: String;
   Resolution: String;
   TotalScore: Integer;
   PhaseResults: array[0..6] of TBenchmarkPhaseResult;
   DeviceName: String;
   VulkanAPI: String;
  end;

  PScreenExampleCubeUniformBuffer=^TScreenExampleCubeUniformBuffer;
     TScreenExampleCubeUniformBuffer=record
      ModelViewProjectionMatrix:TpvMatrix4x4;
      ModelViewMatrix:TpvMatrix4x4;
      ModelViewNormalMatrix:TpvMatrix4x4;
     end;

     PScreenExampleCubeState=^TScreenExampleCubeState;
     TScreenExampleCubeState=record
      Time:TpvDouble;
      AnglePhases:array[0..1] of TpvFloat;
     end;

     PScreenExampleCubeStates=^TScreenExampleCubeStates;
     TScreenExampleCubeStates=array[0..MaxInFlightFrames-1] of TScreenExampleCubeState;

     TPasCubeScreen=class(TpvApplicationScreen)
      private
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fCubeVertexShaderModule:TpvVulkanShaderModule;
       fCubeFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCubeVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageCubeFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fMouseLeftButtonDown:boolean;
       fLastMousePosition:TpvVector2;
       fAutoRotation:boolean;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanVertexBuffer:TpvVulkanBuffer;
       fVulkanIndexBuffer:TpvVulkanBuffer;
       fVulkanUniformBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
        fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
        fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanCommandPool:TpvVulkanCommandPool;
       fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of array of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fUniformBuffer:TScreenExampleCubeUniformBuffer;
        fBoxAlbedoTexture:TpvVulkanTexture;
        fSkyVertexShaderModule:TpvVulkanShaderModule;
        fSkyFragmentShaderModule:TpvVulkanShaderModule;
        fSkyPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
        fSkyPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
        fSkyGraphicsPipeline:TpvVulkanGraphicsPipeline;
        fSkyPipelineLayout:TpvVulkanPipelineLayout;
        fSkyVertexBuffer:TpvVulkanBuffer;
        fReady:boolean;
       fState:TScreenExampleCubeState;
       fStates:TScreenExampleCubeStates;

       // Benchmark
       fBenchmarkPhase: TBenchmarkPhase;
       fBenchmarkTimer: TpvDouble;
       fPhaseTimer: TpvDouble;
       fPhysicsWorld: TPhysicsWorld;
       fCurrentResult: TBenchmarkResult;
       fPhaseResultIndex: Integer;
       fResolutionOption: TResolutionOption;
       fSelectedResolution: Integer;
       fHistory: array[0..MAX_BENCHMARK_HISTORY-1] of TBenchmarkResult;
       fHistoryCount: Integer;
       fBestScore: Integer;
       fLastScore: Integer;
       fShowSkybox: Boolean;

       // Metrics
       fFrameAccumulator: TpvDouble;
       fFrameCount: Integer;
       fPhaseFPSMin: TpvDouble;
       fPhaseFPSMax: TpvDouble;
       fPhaseFrameTimeSum: TpvDouble;

       // Lights
       fLightPositions: array[0..7] of TpvVector3;

       // Particles
       fParticlePositions: array[0..1999] of TpvVector3;
       fParticleColors: array[0..1999] of TpvVector3;
       fParticleCount: Integer;

       // Debug
       fDebugLog: TStringList;
       fLastDebugSave: TpvDouble;

       // Persistent Mapped Uniform Buffer Pointers
       fVulkanUniformBufferPointers: array[0..MaxInFlightFrames-1] of pointer;

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

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;

       function CanBeParallelProcessed:boolean; override;

       procedure Update(const aDeltaTime:TpvDouble); override;

        procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;

        procedure StartBenchmark;
        procedure NextPhase;
        procedure ResetCounters;
        procedure FinishBenchmark;
        procedure SaveResultsJSON;
        procedure LoadResultsJSON;
        procedure CalculateScore;
        procedure SpawnPhaseCubes;
        procedure UpdatePhysics(const aDeltaTime: TpvDouble);
        procedure UpdateLights(const aDeltaTime: TpvDouble);
        procedure InitParticles;
        procedure UpdateParticles(const aDeltaTime: TpvDouble);
        procedure DrawMenuOverlay;
        procedure DrawBenchmarkOverlay;
        procedure DrawResultsOverlay;
        function GetPhaseDuration: TpvDouble;
        function GetPhaseName: String;
        function GetPhaseObjectCount: Integer;
        function FormatScoreValue(const aScore: Integer): String;
        procedure DebugLog(const aMsg: String);
        procedure SaveDebugLog;

      end;

implementation

uses UnitPasCubeApplication, UnitTextOverlay;

 type PVertex=^TVertex;
      TVertex=record
       Position:TpvVector3;
       Tangent:TpvVector3;
       Bitangent:TpvVector3;
       Normal:TpvVector3;
       TexCoord:TpvVector2;
      end;

      PSkyVertex=^TSkyVertex;
      TSkyVertex=record
       Position:TpvVector2;
       TexCoord:TpvVector2;
      end;

const CubeVertices:array[0..23] of TVertex=
       (// Left
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x:-1;y: 1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y:-1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:0)),

        // Right
        (Position:(x: 1;y:-1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:0)),

        // Bottom
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:0)),

        // Top
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:0)),

        // Back
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:1)),
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:0)),

        // Front
        (Position:(x:-1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:0))

       );

       CubeIndices:array[0..35] of TpvInt32=
        ( // Left
          0, 1, 2,
          0, 2, 3,

          // Right
          4, 5, 6,
          4, 6, 7,

          // Bottom
          8, 9, 10,
          8, 10, 11,

          // Top
          12, 13, 14,
          12, 14, 15,

          // Back
          16, 17, 18,
          16, 18, 19,

          // Front
          20, 21, 22,
          20, 22, 23);

      SkyVertices:array[0..2] of TSkyVertex=
       (
        (Position:(x:-1.0;y:-1.0);TexCoord:(x:0.0;y:0.0)),
        (Position:(x: 3.0;y:-1.0);TexCoord:(x:2.0;y:0.0)),
        (Position:(x:-1.0;y: 3.0);TexCoord:(x:0.0;y:2.0))
       );

      Offsets:array[0..0] of TVkDeviceSize=(0);

constructor TPasCubeScreen.Create;
begin
 inherited Create;
 fMouseLeftButtonDown:=false;
 fLastMousePosition:=TpvVector2.Create(0.0,0.0);
 fAutoRotation:=true;
 FillChar(fState,SizeOf(TScreenExampleCubeState),#0);
 FillChar(fStates,SizeOf(TScreenExampleCubeStates),#0);
 fReady:=false;
 fBenchmarkPhase := bpIdleMenu;
 fBenchmarkTimer := 0.0;
 fPhaseTimer := 0.0;
 fPhysicsWorld := TPhysicsWorld.Create;
 fResolutionOption := ro720p;
 fSelectedResolution := 0;
 fBestScore := 0;
 fLastScore := 0;
 fHistoryCount := 0;
 fShowSkybox := true;
 fPhaseResultIndex := -1;
 FillChar(fCurrentResult,SizeOf(fCurrentResult),#0);
 FillChar(fHistory,SizeOf(fHistory),#0);
 fDebugLog := TStringList.Create;
 fLastDebugSave := 0.0;
 LoadResultsJSON;
end;

destructor TPasCubeScreen.Destroy;
begin
 SaveDebugLog;
 FreeAndNil(fDebugLog);
 FreeAndNil(fPhysicsWorld);
 inherited Destroy;
end;

procedure TPasCubeScreen.Show;
var Stream:TStream;
    Index,SwapChainImageIndex:TpvInt32;
begin
 inherited Show;

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
  SetLength(fVulkanRenderCommandBuffers[Index],pvApplication.CountSwapChainImages);
  for SwapChainImageIndex:=0 to pvApplication.CountSwapChainImages-1 do begin
   fVulkanRenderCommandBuffers[Index,SwapChainImageIndex]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  end;
  fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 Stream:=pvApplication.Assets.GetAssetStream('shaders/cube/cube_vert.spv');
 try
  fCubeVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

  Stream:=pvApplication.Assets.GetAssetStream('shaders/cube/cube_frag.spv');
  try
   fCubeFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  Stream:=pvApplication.Assets.GetAssetStream('textures/metal.png');
  try
   fBoxAlbedoTexture:=TpvVulkanTexture.CreateFromImage(pvApplication.VulkanDevice,
                                                       pvApplication.VulkanDevice.GraphicsQueue,
                                                       fVulkanGraphicsCommandBuffer,
                                                       fVulkanGraphicsCommandBufferFence,
                                                       pvApplication.VulkanDevice.TransferQueue,
                                                       fVulkanTransferCommandBuffer,
                                                       fVulkanTransferCommandBufferFence,
                                                       Stream,
                                                       true,
                                                       true);
  finally
   Stream.Free;
  end;
  fBoxAlbedoTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToEdge;
  fBoxAlbedoTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToEdge;
  fBoxAlbedoTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
  fBoxAlbedoTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
  fBoxAlbedoTexture.UpdateSampler;

   fVulkanPipelineShaderStageCubeVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fCubeVertexShaderModule,'main');

  fVulkanPipelineShaderStageCubeFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCubeFragmentShaderModule,'main');

  Stream:=pvApplication.Assets.GetAssetStream('shaders/sky/sky_vert.spv');
  try
   fSkyVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  Stream:=pvApplication.Assets.GetAssetStream('shaders/sky/sky_frag.spv');
  try
   fSkyFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fSkyPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fSkyVertexShaderModule,'main');
  fSkyPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fSkyFragmentShaderModule,'main');

  fSkyVertexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                           SizeOf(SkyVertices),
                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                           [],
                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT));
  fSkyVertexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                              fVulkanTransferCommandBuffer,
                              fVulkanTransferCommandBufferFence,
                              SkyVertices,
                              0,
                              SizeOf(SkyVertices),
                              TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

  fSkyPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
  fSkyPipelineLayout.Initialize;

  fVulkanGraphicsPipeline:=nil;
  fSkyGraphicsPipeline:=nil;

 fVulkanRenderPass:=nil;

 fVulkanVertexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                             SizeOf(CubeVertices),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
 fVulkanVertexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                fVulkanTransferCommandBuffer,
                                fVulkanTransferCommandBufferFence,
                                CubeVertices,
                                0,
                                SizeOf(CubeVertices),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 fVulkanIndexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                            SizeOf(CubeIndices),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                           );
 fVulkanIndexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence,
                               CubeIndices,
                               0,
                               SizeOf(CubeIndices),
                               TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanUniformBuffers[Index]:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                                       SizeOf(TScreenExampleCubeUniformBuffer),
                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                       [],
                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       [TpvVulkanBufferFlag.PersistentMapped]
                                                      );
  fVulkanUniformBuffers[Index].UploadData(pvApplication.VulkanDevice.TransferQueue,
                                          fVulkanTransferCommandBuffer,
                                          fVulkanTransferCommandBufferFence,
                                          fUniformBuffer,
                                          0,
                                          SizeOf(TScreenExampleCubeUniformBuffer),
                                          TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);
  fVulkanUniformBufferPointers[Index]:=fVulkanUniformBuffers[Index].Memory.MapMemory(0,SizeOf(TScreenExampleCubeUniformBuffer));
 end;

  fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                        TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                        MaxInFlightFrames);
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,MaxInFlightFrames);
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,MaxInFlightFrames);
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

  for Index:=0 to MaxInFlightFrames-1 do begin
   fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                               fVulkanDescriptorSetLayout);
   fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                     [],
                                                     [fVulkanUniformBuffers[Index].DescriptorBufferInfo],
                                                     [],
                                                     false
                                                    );
   fVulkanDescriptorSets[Index].WriteToDescriptorSet(1,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                     [fBoxAlbedoTexture.DescriptorImageInfo],
                                                     [],
                                                     [],
                                                     false
                                                    );
   fVulkanDescriptorSets[Index].Flush;
  end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 // Push constant range should cover both vectors (2 * SizeOf(TpvVector4) = 32 bytes)
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvVector4)*2);
 fVulkanPipelineLayout.Initialize;

end;

procedure TPasCubeScreen.Hide;
var Index,SwapChainImageIndex:TpvInt32;
begin
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 for Index:=0 to MaxInFlightFrames-1 do begin
  if Assigned(fVulkanUniformBuffers[Index]) then begin
   fVulkanUniformBuffers[Index].Memory.UnmapMemory;
   FreeAndNil(fVulkanUniformBuffers[Index]);
  end;
  fVulkanUniformBufferPointers[Index]:=nil;
 end;
 FreeAndNil(fVulkanIndexBuffer);
 FreeAndNil(fVulkanVertexBuffer);
  FreeAndNil(fVulkanRenderPass);
  FreeAndNil(fVulkanGraphicsPipeline);
  FreeAndNil(fVulkanPipelineShaderStageCubeVertex);
 FreeAndNil(fVulkanPipelineShaderStageCubeFragment);
  FreeAndNil(fCubeFragmentShaderModule);
  FreeAndNil(fCubeVertexShaderModule);
  FreeAndNil(fBoxAlbedoTexture);
  FreeAndNil(fSkyGraphicsPipeline);
  FreeAndNil(fSkyPipelineShaderStageFragment);
  FreeAndNil(fSkyPipelineShaderStageVertex);
  FreeAndNil(fSkyFragmentShaderModule);
  FreeAndNil(fSkyVertexShaderModule);
  FreeAndNil(fSkyPipelineLayout);
  FreeAndNil(fSkyVertexBuffer);
  for Index:=0 to MaxInFlightFrames-1 do begin
  for SwapChainImageIndex:=0 to length(fVulkanRenderCommandBuffers[Index])-1 do begin
   FreeAndNil(fVulkanRenderCommandBuffers[Index,SwapChainImageIndex]);
  end;
  fVulkanRenderCommandBuffers[Index]:=nil;
  FreeAndNil(fVulkanRenderSemaphores[Index]);
 end;
 FreeAndNil(fVulkanCommandPool);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 FreeAndNil(fVulkanTransferCommandPool);
 FreeAndNil(fVulkanGraphicsCommandBufferFence);
 FreeAndNil(fVulkanGraphicsCommandBuffer);
 FreeAndNil(fVulkanGraphicsCommandPool);
 inherited Hide;
end;

procedure TPasCubeScreen.Resume;
begin
 inherited Resume;
end;

procedure TPasCubeScreen.Pause;
begin
 inherited Pause;
end;

procedure TPasCubeScreen.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
end;

procedure TPasCubeScreen.AfterCreateSwapChain;
var Index,SwapChainImageIndex:TpvInt32;
    VulkanCommandBuffer:TpvVulkanCommandBuffer;
begin
 inherited AfterCreateSwapChain;

  FreeAndNil(fVulkanRenderPass);
  FreeAndNil(fVulkanGraphicsPipeline);
  FreeAndNil(fSkyGraphicsPipeline);

  fVulkanRenderPass:=TpvVulkanRenderPass.Create(pvApplication.VulkanDevice);

 fVulkanRenderPass.AddSubpassDescription(0,
                                         VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         [],
                                         [fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                              pvApplication.VulkanSwapChain.ImageFormat,
                                                                                                                              VK_SAMPLE_COUNT_1_BIT,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                                              VK_ATTACHMENT_STORE_OP_STORE,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                              VK_IMAGE_LAYOUT_UNDEFINED,
                                                                                                                              VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
                                                                                                                             ),
                                                                             VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                            )],
                                         [],
                                         fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                             pvApplication.VulkanDepthImageFormat,
                                                                                                                             VK_SAMPLE_COUNT_1_BIT,
                                                                                                                             VK_ATTACHMENT_LOAD_OP_CLEAR,
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

 fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.15;
 fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.15;
 fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.15;
 fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                           pvApplication.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanPipelineLayout,
                                                           fVulkanRenderPass,
                                                           0,
                                                           nil,
                                                           0);

 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageCubeVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageCubeFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TVertex),VK_VERTEX_INPUT_RATE_VERTEX);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Position)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Tangent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Bitangent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Normal)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(4,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.TexCoord)));

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
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
                                                                      VK_BLEND_FACTOR_ONE,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true; // Glass usually disables DepthWrite but here we want it for simplicity
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

   fVulkanGraphicsPipeline.Initialize;

   fVulkanGraphicsPipeline.FreeMemory;

   fSkyGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                          pvApplication.VulkanPipelineCache,
                                                          0,
                                                          [],
                                                          fSkyPipelineLayout,
                                                          fVulkanRenderPass,
                                                          0,
                                                          nil,
                                                          0);

   fSkyGraphicsPipeline.AddStage(fSkyPipelineShaderStageVertex);
   fSkyGraphicsPipeline.AddStage(fSkyPipelineShaderStageFragment);

   fSkyGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
   fSkyGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

   fSkyGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TSkyVertex),VK_VERTEX_INPUT_RATE_VERTEX);
   fSkyGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSkyVertex(nil)^.Position)));
   fSkyGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSkyVertex(nil)^.TexCoord)));

   fSkyGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
   fSkyGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);

   fSkyGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
   fSkyGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
   fSkyGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
   fSkyGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
   fSkyGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
   fSkyGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
   fSkyGraphicsPipeline.RasterizationState.LineWidth:=1.0;

   fSkyGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
   fSkyGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;

   fSkyGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
   fSkyGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                     VK_BLEND_FACTOR_ONE,
                                                                     VK_BLEND_FACTOR_ZERO,
                                                                     VK_BLEND_OP_ADD,
                                                                     VK_BLEND_FACTOR_ONE,
                                                                     VK_BLEND_FACTOR_ZERO,
                                                                     VK_BLEND_OP_ADD,
                                                                     TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                     TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                     TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                     TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

   fSkyGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
   fSkyGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
   fSkyGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
   fSkyGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
   fSkyGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

   fSkyGraphicsPipeline.Initialize;
   fSkyGraphicsPipeline.FreeMemory;

   for Index:=0 to pvApplication.CountInFlightFrames-1 do begin

  for SwapChainImageIndex:=0 to length(fVulkanRenderCommandBuffers[Index])-1 do begin
   FreeAndNil(fVulkanRenderCommandBuffers[Index,SwapChainImageIndex]);
  end;

  SetLength(fVulkanRenderCommandBuffers[Index],pvApplication.CountSwapChainImages);

  for SwapChainImageIndex:=0 to pvApplication.CountSwapChainImages-1 do begin

   fVulkanRenderCommandBuffers[Index,SwapChainImageIndex]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  end;

 end;

end;



procedure TPasCubeScreen.BeforeDestroySwapChain;
begin
 FreeAndNil(fVulkanRenderPass);
 FreeAndNil(fVulkanGraphicsPipeline);
 FreeAndNil(fSkyGraphicsPipeline);
 inherited BeforeDestroySwapChain;
end;

function TPasCubeScreen.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) then begin
  case aKeyEvent.KeyCode of
   KEYCODE_ESCAPE:begin
    pvApplication.Terminate;
   end;
   KEYCODE_RETURN,KEYCODE_SPACE:begin
    if fBenchmarkPhase = bpIdleMenu then begin
     StartBenchmark;
    end else if fBenchmarkPhase = bpResults then begin
     fBenchmarkPhase := bpIdleMenu;
     fShowSkybox := true;
    end;
   end;
   KEYCODE_UP:begin
    if fBenchmarkPhase = bpIdleMenu then begin
     if fSelectedResolution > 0 then Dec(fSelectedResolution);
    end;
   end;
   KEYCODE_DOWN:begin
    if fBenchmarkPhase = bpIdleMenu then begin
     if fSelectedResolution < 2 then Inc(fSelectedResolution);
    end;
   end;
  end;
 end;
end;

function TPasCubeScreen.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Delta:TpvVector2;
begin
 result:=inherited PointerEvent(aPointerEvent);
 case aPointerEvent.PointerEventType of
  TpvApplicationInputPointerEventType.Down:begin
   if aPointerEvent.Button=TpvApplicationInputPointerButton.Left then begin
    fMouseLeftButtonDown:=true;
    fLastMousePosition:=aPointerEvent.Position;
    fAutoRotation:=false;
   end;
  end;
  TpvApplicationInputPointerEventType.Up:begin
   if aPointerEvent.Button=TpvApplicationInputPointerButton.Left then begin
    fMouseLeftButtonDown:=false;
    fAutoRotation:=true;
   end;
  end;
  TpvApplicationInputPointerEventType.Motion:begin
   if fMouseLeftButtonDown then begin
    Delta:=aPointerEvent.Position-fLastMousePosition;
    fLastMousePosition:=aPointerEvent.Position;
    fState.AnglePhases[1]:=fState.AnglePhases[1]+(Delta.x*0.005);
    fState.AnglePhases[0]:=fState.AnglePhases[0]+(Delta.y*0.005);
   end;
  end;
 end;
end;

function TPasCubeScreen.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TPasCubeScreen.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TPasCubeScreen.Update(const aDeltaTime:TpvDouble);
const f0=2.5/(2.0*pi);  // 2.5x rotation speed
      f1=1.25/(2.0*pi); // 2.5x rotation speed
      MaxFPS=120.0; // Maximum FPS for full rotation speed
var SpeedMultiplier:TpvDouble;
    fps: TpvDouble;
begin
 inherited Update(aDeltaTime);

 // Update metrics
 fps := pvApplication.FramesPerSecond;
 if fFrameCount = 0 then begin
  fPhaseFPSMin := fps;
  fPhaseFPSMax := fps;
 end else begin
  if fps < fPhaseFPSMin then fPhaseFPSMin := fps;
  if fps > fPhaseFPSMax then fPhaseFPSMax := fps;
 end;
 fPhaseFrameTimeSum := fPhaseFrameTimeSum + aDeltaTime;
 Inc(fFrameCount);

 // Benchmark state machine
 if fBenchmarkPhase > bpIdleMenu then begin
  fBenchmarkTimer := fBenchmarkTimer + aDeltaTime;
  fPhaseTimer := fPhaseTimer + aDeltaTime;

  if fBenchmarkPhase = bpPhase3_CPU_Heavy then begin
   if (fPhysicsWorld.BodyCount < 200) and (Frac(fBenchmarkTimer * 2.0) < aDeltaTime * 2.0) then begin
    fPhysicsWorld.SpawnBody(
     TpvVector3.Create((Random-0.5)*4.0, 5.0+Random*3.0, (Random-0.5)*4.0),
     0.5 + Random * 1.0,
     TpvVector3.Create(0.3 + Random*0.7, 0.5 + Random*0.5, 0.8 + Random*0.2)
    );
   end;
  end;

  if fPhaseTimer >= GetPhaseDuration then begin
   NextPhase;
  end;
 end;

 // Update physics if in CPU phases
 if (fBenchmarkPhase >= bpPhase1_CPU_Light) and (fBenchmarkPhase <= bpPhase3_CPU_Heavy) then begin
  UpdatePhysics(aDeltaTime);
 end;

 // Update lights if in GPU/combined phases
 if (fBenchmarkPhase = bpPhase4_GPU_Lights) or (fBenchmarkPhase = bpPhase6_Combined) then begin
  UpdateLights(aDeltaTime);
 end;

 // Update particles if in GPU particle/combined phases
 if (fBenchmarkPhase = bpPhase5_GPU_Particles) or (fBenchmarkPhase = bpPhase6_Combined) then begin
  UpdateParticles(aDeltaTime);
 end;

 // Original cube rotation (for idle/demo)
 if fAutoRotation and (fBenchmarkPhase = bpIdleMenu) then begin
  SpeedMultiplier:=pvApplication.FramesPerSecond/MaxFPS;
  if SpeedMultiplier>1.0 then SpeedMultiplier:=1.0;
  if SpeedMultiplier<0.0 then SpeedMultiplier:=0.0;
  fState.Time:=fState.Time+aDeltaTime;
  fState.AnglePhases[0]:=frac(fState.AnglePhases[0]+(aDeltaTime*f0*SpeedMultiplier));
  fState.AnglePhases[1]:=frac(fState.AnglePhases[1]+(aDeltaTime*f1*SpeedMultiplier));
 end;
 fStates[pvApplication.UpdateInFlightFrameIndex]:=fState;
 fReady:=true;

 // Add overlay text during update
 case fBenchmarkPhase of
  bpIdleMenu: DrawMenuOverlay;
  bpResults: DrawResultsOverlay;
  else DrawBenchmarkOverlay;
 end;
end;

procedure TPasCubeScreen.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const TwoPI=2.0*pi;
var p:pointer;
    ModelMatrix, ViewMatrix, ProjectionMatrix: TpvMatrix4x4;
    State:PScreenExampleCubeState;
    PushConstants:record
                   Vector:TpvVector4;
                   Params:TpvVector4;
                  end;
    body: PCubeBody;
    i: Integer;
    isBenchmark: Boolean;
    gpuStressValue: TpvFloat;
begin
 inherited Draw(aSwapChainImageIndex,aWaitSemaphore,nil);
 if assigned(fVulkanGraphicsPipeline) then begin

  isBenchmark := fBenchmarkPhase > bpIdleMenu;

  // Debug log every ~2 seconds during benchmark
  if isBenchmark and (fBenchmarkTimer - fLastDebugSave > 2.0) then begin
   fLastDebugSave := fBenchmarkTimer;
   DebugLog(Format('DRAW phase=%s bodies=%d particles=%d timer=%.1f',
    [GetPhaseName, fPhysicsWorld.BodyCount, fParticleCount, fBenchmarkTimer]));
   if fPhysicsWorld.BodyCount > 0 then
    DebugLog(Format('  Body0 pos=(%.2f,%.2f,%.2f) active=%s',
     [fPhysicsWorld.GetBody(0)^.Position.x, fPhysicsWorld.GetBody(0)^.Position.y,
      fPhysicsWorld.GetBody(0)^.Position.z, BoolToStr(fPhysicsWorld.GetBody(0)^.Active, 'yes', 'no')]));
   if fParticleCount > 0 then
    DebugLog(Format('  Part0 pos=(%.2f,%.2f,%.2f)',
     [fParticlePositions[0].x, fParticlePositions[0].y, fParticlePositions[0].z]));
  end;

  State:=@fStates[pvApplication.DrawInFlightFrameIndex];

  ViewMatrix:=TpvMatrix4x4.CreateTranslation(0.0,0.0,-8.0);
  ProjectionMatrix:=TpvMatrix4x4.CreatePerspective(45.0,pvApplication.Width/pvApplication.Height,1.0,128.0);

  fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
  fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

  if isBenchmark and (fBenchmarkPhase < bpResults) then begin
   fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.0;
   fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.0;
   fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.0;
   fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;
  end else begin
   fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.15;
   fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.15;
   fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.15;
   fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;
  end;

  fVulkanRenderPass.BeginRenderPass(fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex],
                                    pvApplication.VulkanFrameBuffers[aSwapChainImageIndex],
                                    VK_SUBPASS_CONTENTS_INLINE,
                                    0,
                                    0,
                                    pvApplication.VulkanSwapChain.Width,
                                    pvApplication.VulkanSwapChain.Height);

   if fShowSkybox then begin
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fSkyGraphicsPipeline.Handle);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindVertexBuffers(0,1,@fSkyVertexBuffer.Handle,@Offsets);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDraw(3,1,0,0);
   end;

   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindVertexBuffers(0,1,@fVulkanVertexBuffer.Handle,@Offsets);
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindIndexBuffer(fVulkanIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                                                                                               fVulkanPipelineLayout.Handle,
                                                                                                               0,
                                                                                                               1,
                                                                                                               @fVulkanDescriptorSets[pvApplication.DrawInFlightFrameIndex].Handle,
                                                                                                               0,
                                                                                                               nil);

   if (fBenchmarkPhase = bpPhase4_GPU_Lights) or
      (fBenchmarkPhase = bpPhase5_GPU_Particles) or
      (fBenchmarkPhase = bpPhase6_Combined) then
    gpuStressValue := fBenchmarkTimer
   else
    gpuStressValue := 0.0;

   // Render physics bodies (CPU phases + combined)
   if isBenchmark and (fPhysicsWorld.BodyCount > 0) and
      ((fBenchmarkPhase <= bpPhase3_CPU_Heavy) or (fBenchmarkPhase = bpPhase6_Combined)) then begin
    for i := 0 to fPhysicsWorld.BodyCount - 1 do begin
     body := fPhysicsWorld.GetBody(i);
     if not Assigned(body) or not body^.Active then Continue;
     ModelMatrix := TpvMatrix4x4.CreateScale(body^.Scale, body^.Scale, body^.Scale) *
                    TpvMatrix4x4.CreateRotate(body^.Rotation.x, TpvVector3.Create(1,0,0)) *
                    TpvMatrix4x4.CreateRotate(body^.Rotation.y, TpvVector3.Create(0,1,0)) *
                    TpvMatrix4x4.CreateRotate(body^.Rotation.z, TpvVector3.Create(0,0,1)) *
                    TpvMatrix4x4.CreateTranslation(body^.Position.x, body^.Position.y, body^.Position.z);
     fUniformBuffer.ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
     fUniformBuffer.ModelViewMatrix := ModelMatrix * ViewMatrix;
     fUniformBuffer.ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);
     p := fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
     if assigned(p) then begin
      Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
     end;
     PushConstants.Vector := TpvVector4.Create(body^.Color.x, body^.Color.y, body^.Color.z, 1.0);
     PushConstants.Params := TpvVector4.Create(1.4, 0.7, 24.0, gpuStressValue);
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
      fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
      0, SizeOf(TpvVector4)*2, @PushConstants);
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(36,1,0,0,0);
    end;
   end;

   // Render particles (GPU particle phase + combined)
   if isBenchmark and (fParticleCount > 0) and
      ((fBenchmarkPhase = bpPhase5_GPU_Particles) or (fBenchmarkPhase = bpPhase6_Combined)) then begin
    for i := 0 to fParticleCount - 1 do begin
     ModelMatrix := TpvMatrix4x4.CreateScale(0.15, 0.15, 0.15) *
                    TpvMatrix4x4.CreateTranslation(
                     fParticlePositions[i].x,
                     fParticlePositions[i].y,
                     fParticlePositions[i].z);
     fUniformBuffer.ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
     fUniformBuffer.ModelViewMatrix := ModelMatrix * ViewMatrix;
     fUniformBuffer.ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);
     p := fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
     if assigned(p) then begin
      Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
     end;
     PushConstants.Vector := TpvVector4.Create(
      fParticleColors[i].x, fParticleColors[i].y, fParticleColors[i].z, 0.85);
     PushConstants.Params := TpvVector4.Create(1.2, 0.5, 16.0, gpuStressValue);
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
      fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
      0, SizeOf(TpvVector4)*2, @PushConstants);
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(36,1,0,0,0);
    end;
   end;

   // Default cube (idle menu / warmup / GPU light phase)
   if (not isBenchmark) or (fBenchmarkPhase = bpWarmup) or (fBenchmarkPhase = bpPhase4_GPU_Lights) then begin
    ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
                 TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));
    fUniformBuffer.ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
    fUniformBuffer.ModelViewMatrix:=ModelMatrix*ViewMatrix;
    fUniformBuffer.ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);
    p:=fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
    if assigned(p) then begin
     Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
    end;
    PushConstants.Vector:=TpvVector4.Create(0.92, 0.93, 0.98, 1.0);
    PushConstants.Params:=TpvVector4.Create(0.85, 0.7, 24.0, gpuStressValue);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
     fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
     0, SizeOf(TpvVector4)*2, @PushConstants);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(36,1,0,0,0);
   end;

  fVulkanRenderPass.EndRenderPass(fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex]);

  fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].EndRecording;

  fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].Execute(pvApplication.VulkanDevice.GraphicsQueue,
                                                                                                 TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                                 aWaitSemaphore,
                                                                                                 fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex],
                                                                                                 aWaitFence,
                                                                                                 false);

  aWaitSemaphore:=fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex];

 end;
end;

function TPasCubeScreen.FormatScoreValue(const aScore: Integer): String;
begin
 Result := FormatFloat('#,##0', aScore);
end;

procedure TPasCubeScreen.DebugLog(const aMsg: String);
begin
 if Assigned(fDebugLog) then
  fDebugLog.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' | ' + aMsg);
end;

procedure TPasCubeScreen.SaveDebugLog;
var path: String;
begin
 if Assigned(fDebugLog) and (fDebugLog.Count > 0) then begin
  path := ExtractFilePath(ParamStr(0)) + 'pascube_debug.log';
  try
   fDebugLog.SaveToFile(path);
  except
   // ignore
  end;
 end;
end;

function TPasCubeScreen.GetPhaseDuration: TpvDouble;
begin
 case fBenchmarkPhase of
  bpWarmup: Result := 3.0;
  bpPhase1_CPU_Light: Result := 10.0;
  bpPhase2_CPU_Med: Result := 15.0;
  bpPhase3_CPU_Heavy: Result := 20.0;
  bpPhase4_GPU_Lights: Result := 15.0;
  bpPhase5_GPU_Particles: Result := 15.0;
  bpPhase6_Combined: Result := 20.0;
  else Result := 0.0;
 end;
end;

function TPasCubeScreen.GetPhaseName: String;
begin
 case fBenchmarkPhase of
  bpIdleMenu: Result := 'Menu';
  bpWarmup: Result := 'Warmup';
  bpPhase1_CPU_Light: Result := 'CPU Light';
  bpPhase2_CPU_Med: Result := 'CPU Medium';
  bpPhase3_CPU_Heavy: Result := 'CPU Heavy';
  bpPhase4_GPU_Lights: Result := 'GPU Lights';
  bpPhase5_GPU_Particles: Result := 'GPU Particles';
  bpPhase6_Combined: Result := 'Combined';
  bpResults: Result := 'Results';
  else Result := 'Unknown';
 end;
end;

function TPasCubeScreen.GetPhaseObjectCount: Integer;
begin
 case fBenchmarkPhase of
  bpPhase1_CPU_Light: Result := 10;
  bpPhase2_CPU_Med: Result := 50;
  bpPhase3_CPU_Heavy: Result := 200;
  bpPhase4_GPU_Lights: Result := 1;
  bpPhase5_GPU_Particles: Result := 1;
  bpPhase6_Combined: Result := 100;
  else Result := 1;
 end;
end;

procedure TPasCubeScreen.StartBenchmark;
begin
 if Assigned(fDebugLog) then fDebugLog.Clear;
 DebugLog('=== START BENCHMARK ===');
 DebugLog(Format('Resolution=%d Device=%s', [Ord(fResolutionOption), pvApplication.VulkanDevice.PhysicalDevice.DeviceName]));
 fBenchmarkPhase := bpWarmup;
 fBenchmarkTimer := 0.0;
 fPhaseTimer := 0.0;
 fPhaseResultIndex := -1;
 fShowSkybox := false;
 fPhysicsWorld.Clear;
 FillChar(fCurrentResult,SizeOf(fCurrentResult),#0);
 fCurrentResult.Timestamp := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now);
 case fResolutionOption of
  ro720p: fCurrentResult.Resolution := '1280x720';
  ro1080p: fCurrentResult.Resolution := '1920x1080';
  roNative: fCurrentResult.Resolution := 'Native';
 end;
 fCurrentResult.DeviceName := pvApplication.VulkanDevice.PhysicalDevice.DeviceName;
 fCurrentResult.VulkanAPI := Format('%d.%d.%d', [
  pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 22,
  (pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 12) and $3ff,
  pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion and $fff
 ]);
 InitParticles;
 ResetCounters;
end;

procedure TPasCubeScreen.ResetCounters;
begin
 fFrameAccumulator := 0.0;
 fFrameCount := 0;
 fPhaseFPSMin := 9999.0;
 fPhaseFPSMax := 0.0;
 fPhaseFrameTimeSum := 0.0;
 fPhysicsWorld.ResetCounters;
end;

procedure TPasCubeScreen.NextPhase;
var fpsAvg, ftAvg: TpvDouble;
    objCount, lightCount, partCount: Integer;
begin
 if (fBenchmarkPhase > bpWarmup) and (fPhaseResultIndex >= 0) and (fPhaseResultIndex <= 6) then begin
  if (fFrameCount > 0) and (fPhaseFrameTimeSum > 0.0) then begin
   fpsAvg := fFrameCount / fPhaseFrameTimeSum;
   ftAvg := (fPhaseFrameTimeSum / fFrameCount) * 1000.0;
  end else begin
   fpsAvg := 0.0;
   ftAvg := 0.0;
  end;
  objCount := GetPhaseObjectCount;
  lightCount := 0;
  partCount := 0;
  if fBenchmarkPhase = bpPhase4_GPU_Lights then lightCount := 8;
  if fBenchmarkPhase = bpPhase5_GPU_Particles then partCount := 2000;
  if fBenchmarkPhase = bpPhase6_Combined then begin
   objCount := 100;
   lightCount := 8;
   partCount := 1000;
  end;
  fCurrentResult.PhaseResults[fPhaseResultIndex].PhaseName := GetPhaseName;
  fCurrentResult.PhaseResults[fPhaseResultIndex].FPSAvg := fpsAvg;
  fCurrentResult.PhaseResults[fPhaseResultIndex].FPSMin := fPhaseFPSMin;
  fCurrentResult.PhaseResults[fPhaseResultIndex].FPSMax := fPhaseFPSMax;
  fCurrentResult.PhaseResults[fPhaseResultIndex].FrameTimeMs := ftAvg;
  fCurrentResult.PhaseResults[fPhaseResultIndex].ObjectsRendered := objCount;
  fCurrentResult.PhaseResults[fPhaseResultIndex].LightsActive := lightCount;
  fCurrentResult.PhaseResults[fPhaseResultIndex].ParticlesActive := partCount;
  fCurrentResult.PhaseResults[fPhaseResultIndex].PhysicsBodies := fPhysicsWorld.BodyCount;
 end;
 case fBenchmarkPhase of
  bpWarmup: begin
   fBenchmarkPhase := bpPhase1_CPU_Light;
   fPhaseResultIndex := 0;
   SpawnPhaseCubes;
  end;
  bpPhase1_CPU_Light: begin
   fBenchmarkPhase := bpPhase2_CPU_Med;
   fPhaseResultIndex := 1;
   SpawnPhaseCubes;
  end;
  bpPhase2_CPU_Med: begin
   fBenchmarkPhase := bpPhase3_CPU_Heavy;
   fPhaseResultIndex := 2;
   SpawnPhaseCubes;
  end;
  bpPhase3_CPU_Heavy: begin
   fBenchmarkPhase := bpPhase4_GPU_Lights;
   fPhaseResultIndex := 3;
   fPhysicsWorld.Clear;
  end;
  bpPhase4_GPU_Lights: begin
   fBenchmarkPhase := bpPhase5_GPU_Particles;
   fPhaseResultIndex := 4;
   InitParticles;
  end;
  bpPhase5_GPU_Particles: begin
   fBenchmarkPhase := bpPhase6_Combined;
   fPhaseResultIndex := 5;
   fParticleCount := 1000;
   SpawnPhaseCubes;
  end;
  bpPhase6_Combined: begin
   fBenchmarkPhase := bpResults;
   fPhaseResultIndex := 6;
   CalculateScore;
   FinishBenchmark;
   Exit;
  end;
  else begin
   fBenchmarkPhase := bpIdleMenu;
   fShowSkybox := true;
   Exit;
  end;
 end;
 fPhaseTimer := 0.0;
 ResetCounters;
end;

procedure TPasCubeScreen.SpawnPhaseCubes;
var i, count: Integer;
    x, y, z, s: TpvFloat;
    color: TpvVector3;
begin
 fPhysicsWorld.Clear;
 count := GetPhaseObjectCount;
 DebugLog(Format('SpawnPhaseCubes: phase=%s count=%d', [GetPhaseName, count]));
 for i := 0 to count - 1 do begin
  x := (Random - 0.5) * 6.0;
  y := (Random - 0.5) * 4.0;
  z := (Random - 0.5) * 4.0;
  s := 0.4 + Random * 0.8;
  color := TpvVector3.Create(0.3 + Random*0.7, 0.5 + Random*0.5, 0.8 + Random*0.2);
  fPhysicsWorld.SpawnBody(TpvVector3.Create(x,y,z), s, color);
 end;
 DebugLog(Format('  -> Spawned %d bodies. First body pos=(%.2f,%.2f,%.2f) scale=%.2f',
  [fPhysicsWorld.BodyCount, fPhysicsWorld.GetBody(0)^.Position.x,
   fPhysicsWorld.GetBody(0)^.Position.y, fPhysicsWorld.GetBody(0)^.Position.z,
   fPhysicsWorld.GetBody(0)^.Scale]));
end;

procedure TPasCubeScreen.CalculateScore;
var i: Integer;
    phaseScore: Integer;
    Multiplier: TpvDouble;
    fpsAvg: TpvDouble;
    total: Integer;
begin
 total := 0;
 for i := 0 to 6 do begin
  fpsAvg := fCurrentResult.PhaseResults[i].FPSAvg;
  case i of
   0: Multiplier := 100.0;
   1: Multiplier := 150.0;
   2: Multiplier := 200.0;
   3: Multiplier := 120.0;
   4: Multiplier := 300.0;
   5: Multiplier := 250.0;
   6: Multiplier := 250.0;
   else Multiplier := 100.0;
  end;
  phaseScore := Round(fpsAvg * Multiplier);
  if phaseScore < 1 then phaseScore := 1;
  fCurrentResult.PhaseResults[i].Score := phaseScore;
  total := total + phaseScore;
 end;
 fCurrentResult.TotalScore := total;
end;

procedure TPasCubeScreen.FinishBenchmark;
var i: Integer;
begin
 DebugLog(Format('FinishBenchmark: totalScore=%d', [fCurrentResult.TotalScore]));
 if fCurrentResult.TotalScore > fBestScore then fBestScore := fCurrentResult.TotalScore;
 fLastScore := fCurrentResult.TotalScore;
 for i := MAX_BENCHMARK_HISTORY-1 downto 1 do
  fHistory[i] := fHistory[i-1];
 fHistory[0] := fCurrentResult;
 if fHistoryCount < MAX_BENCHMARK_HISTORY then Inc(fHistoryCount);
 SaveResultsJSON;
 SaveDebugLog;
end;

procedure TPasCubeScreen.SaveResultsJSON;
var SL: TStringList;
    i, j: Integer;
    json: String;
begin
 SL := TStringList.Create;
 try
  SL.Add('{');
  SL.Add('  "version": "' + BENCHMARK_VERSION + '",');
  SL.Add('  "history": [');
  for i := 0 to fHistoryCount - 1 do begin
   json := '    {';
   json := json + ' "timestamp": "' + fHistory[i].Timestamp + '",';
   json := json + ' "resolution": "' + fHistory[i].Resolution + '",';
   json := json + ' "device": "' + StringReplace(fHistory[i].DeviceName, '"', '\"', [rfReplaceAll]) + '",';
   json := json + ' "vulkan_api": "' + fHistory[i].VulkanAPI + '",';
   json := json + ' "total_score": ' + IntToStr(fHistory[i].TotalScore) + ',';
   json := json + ' "phases": [';
   for j := 0 to 6 do begin
    json := json + '{';
    json := json + '"name":"' + fHistory[i].PhaseResults[j].PhaseName + '",';
    json := json + '"score":' + IntToStr(fHistory[i].PhaseResults[j].Score) + ',';
    json := json + '"fps_avg":' + FormatFloat('0.00', fHistory[i].PhaseResults[j].FPSAvg) + ',';
    json := json + '"fps_min":' + FormatFloat('0.00', fHistory[i].PhaseResults[j].FPSMin) + ',';
    json := json + '"fps_max":' + FormatFloat('0.00', fHistory[i].PhaseResults[j].FPSMax) + ',';
    json := json + '"frame_time_ms":' + FormatFloat('0.00', fHistory[i].PhaseResults[j].FrameTimeMs) + ',';
    json := json + '"objects":' + IntToStr(fHistory[i].PhaseResults[j].ObjectsRendered) + ',';
    json := json + '"particles":' + IntToStr(fHistory[i].PhaseResults[j].ParticlesActive) + ',';
    json := json + '"lights":' + IntToStr(fHistory[i].PhaseResults[j].LightsActive) + ',';
    json := json + '"bodies":' + IntToStr(fHistory[i].PhaseResults[j].PhysicsBodies);
    json := json + '}';
    if j < 6 then json := json + ',';
   end;
   json := json + ']}';
   if i < fHistoryCount - 1 then json := json + ',';
   SL.Add(json);
  end;
  SL.Add('  ]');
  SL.Add('}');
  try
   SL.SaveToFile(ExtractFilePath(ParamStr(0)) + 'benchmark_results.json');
  except
   // ignore
  end;
 finally
  SL.Free;
 end;
end;

procedure TPasCubeScreen.LoadResultsJSON;
var SL: TStringList;
    filePath: String;
    JSONData: TJSONData;
    JSONObj: TJSONObject;
    HistoryArr: TJSONArray;
    HistoryObj: TJSONObject;
    PhasesArr: TJSONArray;
    PhaseObj: TJSONObject;
    i, j: Integer;
begin
 fHistoryCount := 0;
 fBestScore := 0;
 fLastScore := 0;
 FillChar(fHistory, SizeOf(fHistory), #0);

 filePath := ExtractFilePath(ParamStr(0)) + 'benchmark_results.json';
 if not FileExists(filePath) then Exit;
 SL := TStringList.Create;
 try
  try
   SL.LoadFromFile(filePath);
   if SL.Text <> '' then begin
    JSONData := GetJSON(SL.Text);
    try
     if Assigned(JSONData) and (JSONData is TJSONObject) then begin
      JSONObj := TJSONObject(JSONData);
      HistoryArr := TJSONArray(JSONObj.FindPath('history'));
      if Assigned(HistoryArr) then begin
       for i := 0 to Min(HistoryArr.Count, MAX_BENCHMARK_HISTORY) - 1 do begin
        HistoryObj := HistoryArr.Objects[i];
        if Assigned(HistoryObj) then begin
         fHistory[i].Timestamp := HistoryObj.Get('timestamp', '');
         fHistory[i].Resolution := HistoryObj.Get('resolution', '');
         fHistory[i].DeviceName := HistoryObj.Get('device', '');
         fHistory[i].VulkanAPI := HistoryObj.Get('vulkan_api', '');
         fHistory[i].TotalScore := HistoryObj.Get('total_score', 0);
         
         PhasesArr := TJSONArray(HistoryObj.FindPath('phases'));
         if Assigned(PhasesArr) then begin
          for j := 0 to Min(PhasesArr.Count, 7) - 1 do begin
           PhaseObj := PhasesArr.Objects[j];
           if Assigned(PhaseObj) then begin
            fHistory[i].PhaseResults[j].PhaseName := PhaseObj.Get('name', '');
            fHistory[i].PhaseResults[j].Score := PhaseObj.Get('score', 0);
            fHistory[i].PhaseResults[j].FPSAvg := PhaseObj.Get('fps_avg', 0.0);
            fHistory[i].PhaseResults[j].FPSMin := PhaseObj.Get('fps_min', 0.0);
            fHistory[i].PhaseResults[j].FPSMax := PhaseObj.Get('fps_max', 0.0);
            fHistory[i].PhaseResults[j].FrameTimeMs := PhaseObj.Get('frame_time_ms', 0.0);
            fHistory[i].PhaseResults[j].ObjectsRendered := PhaseObj.Get('objects', 0);
            fHistory[i].PhaseResults[j].ParticlesActive := PhaseObj.Get('particles', 0);
            fHistory[i].PhaseResults[j].LightsActive := PhaseObj.Get('lights', 0);
            fHistory[i].PhaseResults[j].PhysicsBodies := PhaseObj.Get('bodies', 0);
           end;
          end;
         end;
         Inc(fHistoryCount);
         if fHistory[i].TotalScore > fBestScore then
          fBestScore := fHistory[i].TotalScore;
        end;
       end;
       if fHistoryCount > 0 then
        fLastScore := fHistory[0].TotalScore;
      end;
     end;
    finally
     JSONData.Free;
    end;
   end;
  except
   // ignore error and start with empty results
  end;
 finally
  SL.Free;
 end;
end;

procedure TPasCubeScreen.UpdatePhysics(const aDeltaTime: TpvDouble);
begin
 if fPhysicsWorld.BodyCount > 0 then
  fPhysicsWorld.Step(aDeltaTime);
end;

procedure TPasCubeScreen.UpdateLights(const aDeltaTime: TpvDouble);
var i: Integer;
begin
 for i := 0 to 7 do begin
  fLightPositions[i].x := Sin(fBenchmarkTimer * (0.5 + i * 0.1) + i) * 5.0;
  fLightPositions[i].y := Cos(fBenchmarkTimer * (0.3 + i * 0.15) + i * 1.3) * 3.0 + 1.0;
  fLightPositions[i].z := Sin(fBenchmarkTimer * (0.4 + i * 0.07) + i * 2.1) * 4.0;
 end;
end;

procedure TPasCubeScreen.InitParticles;
var i: Integer;
    theta, phi, radius: TpvFloat;
begin
 fParticleCount := 2000;
 for i := 0 to fParticleCount - 1 do begin
  theta := Random * 2.0 * Pi;
  phi := ArcCos(2.0 * Random - 1.0);
  radius := 0.5 + Random * 5.0;
  fParticlePositions[i].x := radius * Sin(phi) * Cos(theta);
  fParticlePositions[i].y := radius * Sin(phi) * Sin(theta);
  fParticlePositions[i].z := radius * Cos(phi);
  fParticleColors[i].x := 0.5 + Random * 0.5;
  fParticleColors[i].y := 0.7 + Random * 0.3;
  fParticleColors[i].z := 1.0;
 end;
 DebugLog(Format('InitParticles: count=%d firstPos=(%.2f,%.2f,%.2f)', [
  fParticleCount, fParticlePositions[0].x, fParticlePositions[0].y, fParticlePositions[0].z]));
end;

procedure TPasCubeScreen.UpdateParticles(const aDeltaTime: TpvDouble);
var i: Integer;
    speed: TpvFloat;
    orbitX, orbitY, orbitZ: TpvFloat;
    distSq: TpvFloat;
begin
 for i := 0 to fParticleCount - 1 do begin
  speed := fBenchmarkTimer * (0.5 + (i mod 16) * 0.15);
  orbitX := Cos(speed + i * 0.7) * (0.3 + (i mod 7) * 0.15);
  orbitY := Sin(speed + i * 1.1) * (0.3 + (i mod 5) * 0.15);
  orbitZ := Cos(speed + i * 1.9) * (0.2 + (i mod 3) * 0.1);
  fParticlePositions[i].x := fParticlePositions[i].x + orbitX * aDeltaTime;
  fParticlePositions[i].y := fParticlePositions[i].y + orbitY * aDeltaTime;
  fParticlePositions[i].z := fParticlePositions[i].z + orbitZ * aDeltaTime;
  distSq := fParticlePositions[i].x * fParticlePositions[i].x +
            fParticlePositions[i].y * fParticlePositions[i].y +
            fParticlePositions[i].z * fParticlePositions[i].z;
  if distSq > 64.0 then begin
   fParticlePositions[i].x := (Random - 0.5) * 1.0;
   fParticlePositions[i].y := (Random - 0.5) * 1.0;
   fParticlePositions[i].z := (Random - 0.5) * 1.0;
  end;
 end;
end;

procedure TPasCubeScreen.DrawMenuOverlay;
var app: TPasCubeApplication;
    cy: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;
 cy := pvApplication.Height * 0.35;
 app.TextOverlay.AddText(pvApplication.Width*0.5, cy - 80, 2.5, toaCenter, 'PasCube Benchmark');
 app.TextOverlay.AddText(pvApplication.Width*0.5, cy - 20, 1.5, toaCenter, Format('Resolution: %s', [fCurrentResult.Resolution]));
 if fLastScore > 0 then
  app.TextOverlay.AddText(pvApplication.Width*0.5, cy + 20, 1.3, toaCenter, Format('Last Score: %s', [FormatScoreValue(fLastScore)]));
 if fBestScore > 0 then
  app.TextOverlay.AddText(pvApplication.Width*0.5, cy + 50, 1.3, toaCenter, Format('Best Score: %s', [FormatScoreValue(fBestScore)]));
 app.TextOverlay.AddText(pvApplication.Width*0.5, cy + 100, 1.2, toaCenter, 'Press ENTER to start');
end;

procedure TPasCubeScreen.DrawBenchmarkOverlay;
var app: TPasCubeApplication;
    phaseStr, infoStr: String;
    duration, progress: TpvDouble;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;
 phaseStr := GetPhaseName;
 duration := GetPhaseDuration;
 if duration > 0 then
  progress := fPhaseTimer / duration
 else
  progress := 0.0;
 app.TextOverlay.AddText(pvApplication.Width*0.5, 20, 2.0, toaCenter,
  Format('%s  (%.0f%%)', [phaseStr, progress * 100.0]));
 app.TextOverlay.AddText(10, 60, 1.5, toaLeft,
  Format('FPS: %.1f', [pvApplication.FramesPerSecond]));
 infoStr := '';
 case fBenchmarkPhase of
  bpPhase1_CPU_Light: infoStr := 'Stress: CPU (10 bodies)';
  bpPhase2_CPU_Med: infoStr := 'Stress: CPU (50 bodies + collision)';
  bpPhase3_CPU_Heavy: infoStr := 'Stress: CPU (200 bodies + spawn)';
  bpPhase4_GPU_Lights: infoStr := 'Stress: GPU (8 dynamic lights)';
  bpPhase5_GPU_Particles: infoStr := 'Stress: GPU (2000 particles)';
  bpPhase6_Combined: infoStr := 'Stress: Combined (100 bodies + 1000 particles + lights)';
 end;
 if infoStr <> '' then
  app.TextOverlay.AddText(10, 85, 1.2, toaLeft, infoStr);
 if fPhysicsWorld.BodyCount > 0 then begin
  app.TextOverlay.AddText(10, 108, 1.2, toaLeft,
   Format('Bodies: %d', [fPhysicsWorld.BodyCount]));
  if fPhysicsWorld.BodyCount > 0 then
   app.TextOverlay.AddText(10, 131, 1.0, toaLeft,
    Format('B0: %.1f,%.1f,%.1f s=%.2f a=%s',
     [fPhysicsWorld.GetBody(0)^.Position.x, fPhysicsWorld.GetBody(0)^.Position.y,
      fPhysicsWorld.GetBody(0)^.Position.z, fPhysicsWorld.GetBody(0)^.Scale,
      BoolToStr(fPhysicsWorld.GetBody(0)^.Active, 'Y', 'N')]));
 end;
 if (fBenchmarkPhase = bpPhase5_GPU_Particles) or (fBenchmarkPhase = bpPhase6_Combined) then begin
  app.TextOverlay.AddText(10, 154, 1.2, toaLeft,
   Format('Particles: %d', [fParticleCount]));
  if fParticleCount > 0 then
   app.TextOverlay.AddText(10, 177, 1.0, toaLeft,
    Format('P0: %.1f,%.1f,%.1f', [fParticlePositions[0].x, fParticlePositions[0].y, fParticlePositions[0].z]));
 end;
end;

procedure TPasCubeScreen.DrawResultsOverlay;
var app: TPasCubeApplication;
    cy, x1, x2, x3, x4, y: TpvFloat;
    i: Integer;
    lineStr, phaseType: String;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;
 cy := pvApplication.Height * 0.15;
 app.TextOverlay.AddText(pvApplication.Width*0.5, cy, 3.0, toaCenter, 'Benchmark Complete!');
 app.TextOverlay.AddText(pvApplication.Width*0.5, cy + 60, 4.0, toaCenter,
  FormatScoreValue(fCurrentResult.TotalScore));
 y := cy + 130;
 x1 := pvApplication.Width * 0.10;
 x2 := pvApplication.Width * 0.35;
 x3 := pvApplication.Width * 0.60;
 x4 := pvApplication.Width * 0.80;
 app.TextOverlay.AddText(x1, y, 1.5, toaLeft, 'Phase');
 app.TextOverlay.AddText(x2, y, 1.5, toaLeft, 'Type');
 app.TextOverlay.AddText(x3, y, 1.5, toaRight, 'Score');
 app.TextOverlay.AddText(x4, y, 1.5, toaRight, 'FPS');
 y := y + 25;
 app.TextOverlay.AddText(x1, y, 1.2, toaLeft, '--------------------------------------------------');
 for i := 0 to 6 do begin
  y := y + 25;
  case i of
   0..2: phaseType := 'CPU';
   3..4: phaseType := 'GPU';
   5: phaseType := 'Both';
   else phaseType := '';
  end;
  app.TextOverlay.AddText(x1, y, 1.3, toaLeft, fCurrentResult.PhaseResults[i].PhaseName);
  app.TextOverlay.AddText(x2, y, 1.3, toaLeft, phaseType);
  app.TextOverlay.AddText(x3, y, 1.3, toaRight, FormatScoreValue(fCurrentResult.PhaseResults[i].Score));
  app.TextOverlay.AddText(x4, y, 1.3, toaRight,
   Format('%.1f', [fCurrentResult.PhaseResults[i].FPSAvg]));
 end;
 y := y + 40;
 app.TextOverlay.AddText(pvApplication.Width*0.5, y, 1.5, toaCenter, 'History (Last 5 runs)');
 for i := 0 to Min(fHistoryCount, 5) - 1 do begin
  y := y + 22;
  lineStr := Format('#%d: %s  (%s)', [i+1, FormatScoreValue(fHistory[i].TotalScore), fHistory[i].Timestamp]);
  app.TextOverlay.AddText(pvApplication.Width*0.5, y, 1.2, toaCenter, lineStr);
 end;
end;

end.
