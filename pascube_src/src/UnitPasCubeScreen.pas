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
   bpCPU_Single,   // CPU Single-Threaded 7-Zip test
   bpCPU_Multi,    // CPU Multi-Threaded 7-Zip test
   bpGPU_Stress,   // GPU Vulkan particle rendering stress test
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

  THardwareRef = record
    Name: String;
    Score: Integer;
    IsCurrent: Boolean;
    Specs: String;
   end;

  TModelMatrixInfo=record
   ModelViewProjectionMatrix:TpvMatrix4x4;
   ModelViewMatrix:TpvMatrix4x4;
   ModelViewNormalMatrix:TpvMatrix4x4;
  end;

  PScreenExampleCubeUniformBuffer=^TScreenExampleCubeUniformBuffer;
     TScreenExampleCubeUniformBuffer=record
      Instances: array[0..255] of TModelMatrixInfo;
     end;

     PScreenExampleCubeState=^TScreenExampleCubeState;
     TScreenExampleCubeState=record
      Time:TpvDouble;
      AnglePhases:array[0..1] of TpvFloat;
     end;

     PScreenExampleCubeStates=^TScreenExampleCubeStates;
     TScreenExampleCubeStates=array[0..MaxInFlightFrames-1] of TScreenExampleCubeState;

     T7ZipThread = class(TThread)
     private
       FCommand: string;
       FArguments: string;
       FScore: Integer;
       FProgress: Single;
       function GetIsFinished: Boolean;
     protected
       procedure Execute; override;
     public
       constructor Create(const aCommand, aArguments: string);
       property Score: Integer read FScore;
       property IsFinished: Boolean read GetIsFinished;
       property Progress: Single read FProgress;
     end;

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
       fDraggingCube:boolean;
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
        f7ZipThread: T7ZipThread;
        fBenchmarkTimer: TpvDouble;
       fPhaseTimer: TpvDouble;
       fPhysicsWorld: TPhysicsWorld;
       fCurrentResult: TBenchmarkResult;
       fPhaseResultIndex: Integer;
       fResolutionOption: TResolutionOption;
       fSelectedResolution: Integer;
       fHoveredButtonIndex: Integer;
       fCubeIndexCount: TpvInt32;
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
        function IsStartButtonHovered(const aPos: TpvVector2): Boolean;
        procedure DrawBenchmarkOverlay;
        procedure DrawResultsOverlay;
        procedure GenerateBeveledCube;
        function GetPhaseDuration: TpvDouble;
        function GetPhaseName: String;
        function GetPhaseObjectCount: Integer;
        function FormatScoreValue(const aScore: Integer): String;
        procedure DebugLog(const aMsg: String);
        procedure SaveDebugLog;

      end;

implementation

uses UnitPasCubeApplication, UnitTextOverlay, process;

function T7ZipThread.GetIsFinished: Boolean;
begin
  Result := Finished;
end;

procedure ThreadLog(const Msg: string);
var
  F: TextFile;
  Path: string;
begin
  Path := ExtractFilePath(ParamStr(0)) + 'pascube_thread.log';
  try
    AssignFile(F, Path);
    if FileExists(Path) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('hh:nn:ss.zzz', Now) + ' | ' + Msg);
    CloseFile(F);
  except
    // ignore
  end;
end;

constructor T7ZipThread.Create(const aCommand, aArguments: string);
begin
  FCommand := aCommand;
  FArguments := aArguments;
  FProgress := 0.0;
  FScore := 0;
  inherited Create(False);
end;

procedure T7ZipThread.Execute;
var
  AProcess: TProcess;
  Buffer: array[0..2047] of Char;
  BytesRead: LongInt;
  TextBuf: string;
  Line: string;
  LineEnd: Integer;
  StepCount: Integer;
  totPos: Integer;
  i: Integer;
  ValStr: string;
  AvailableBytes: Integer;
  LoopCounter: Integer;
  EnvVar: string;
begin
  ThreadLog('T7ZipThread.Execute: Thread started. Cmd: ' + FCommand + ' Args: ' + FArguments);
  StepCount := 0;
  TextBuf := '';
  LoopCounter := 0;
  AProcess := TProcess.Create(nil);
  try
    // Build environment block without preload/overlay variables to prevent deadlocks
    i := 1;
    while GetEnvironmentString(i) <> '' do begin
      EnvVar := GetEnvironmentString(i);
      if (Pos('LD_PRELOAD=', EnvVar) <> 1) and
         (Pos('MANGOHUD=', EnvVar) <> 1) and
         (Pos('MANGOHUD_CONFIGFILE=', EnvVar) <> 1) and
         (Pos('ENABLE_VKBASALT=', EnvVar) <> 1) and
         (Pos('VKBASALT_CONFIG_FILE=', EnvVar) <> 1) and
         (Pos('ENABLE_VKSUMI=', EnvVar) <> 1) and
         (Pos('VKSUMI_CONFIG_FILE=', EnvVar) <> 1) then begin
        AProcess.Environment.Add(EnvVar);
      end;
      Inc(i);
    end;

    // Execute 7z via /bin/sh to close inherited Vulkan/Wayland file descriptors dynamically
    AProcess.Executable := '/bin/sh';
    AProcess.Parameters.Add('-c');

    ValStr := 'for fd in /proc/self/fd/*; do fd_num="${fd##*/}"; [ "$fd_num" = "*" ] && continue; ' +
              'if [ "$fd_num" -gt 2 ]; then eval "exec $fd_num>&-" 2>/dev/null; fi; done; ' +
              'if command -v stdbuf >/dev/null 2>&1; then ' +
              'exec stdbuf -oL ' + FCommand + ' b';
    if FArguments <> '' then
      ValStr := ValStr + ' ' + FArguments;
    ValStr := ValStr + ' 3; else exec ' + FCommand + ' b';
    if FArguments <> '' then
      ValStr := ValStr + ' ' + FArguments;
    ValStr := ValStr + ' 3; fi';

    AProcess.Parameters.Add(ValStr);
    AProcess.Options := [poUsePipes, poNoConsole, poStderrToOutPut];

    ThreadLog('T7ZipThread.Execute: Spawning process... Executable = ' + AProcess.Executable);
    for i := 0 to AProcess.Parameters.Count - 1 do begin
      ThreadLog('T7ZipThread.Execute: Param[' + IntToStr(i) + '] = ' + AProcess.Parameters[i]);
    end;

    ThreadLog('--- Environment Variables ---');
    i := 1;
    while GetEnvironmentString(i) <> '' do begin
      ThreadLog('Env: ' + GetEnvironmentString(i));
      Inc(i);
    end;
    ThreadLog('-----------------------------');

    ThreadLog('--- Child Environment Variables ---');
    for i := 0 to AProcess.Environment.Count - 1 do begin
      ThreadLog('Child Env: ' + AProcess.Environment[i]);
    end;
    ThreadLog('-----------------------------------');

    try
      AProcess.Execute;
      ThreadLog('T7ZipThread.Execute: Process spawned successfully.');
    except
      on E: Exception do begin
        ThreadLog('T7ZipThread.Execute: FAILED to execute process. Exception: ' + E.Message);
        Exit;
      end;
    end;

    while not Terminated do begin
      {$ifdef linux}
      if not (AProcess.Running and DirectoryExists('/proc/' + IntToStr(AProcess.ProcessID))) then
      {$else}
      if not AProcess.Running then
      {$endif}
      begin
        if AProcess.Output.NumBytesAvailable = 0 then
          Break;
      end;
      Inc(LoopCounter);
      if LoopCounter mod 20 = 0 then begin
        ThreadLog('T7ZipThread.Execute loop: Running = ' + BoolToStr(AProcess.Running, True) +
                  ' NumBytesAvailable = ' + IntToStr(AProcess.Output.NumBytesAvailable));
      end;
      AvailableBytes := AProcess.Output.NumBytesAvailable;
      if AvailableBytes > 0 then begin
        if AvailableBytes > SizeOf(Buffer) - 1 then
          AvailableBytes := SizeOf(Buffer) - 1;
        BytesRead := AProcess.Output.Read(Buffer[0], AvailableBytes);
        if BytesRead > 0 then begin
          Buffer[BytesRead] := #0;
          TextBuf := TextBuf + PChar(@Buffer[0]);
          while True do begin
            LineEnd := Pos(#10, TextBuf);
            if LineEnd = 0 then LineEnd := Pos(#13, TextBuf);
            if LineEnd > 0 then begin
              Line := Copy(TextBuf, 1, LineEnd - 1);
              Delete(TextBuf, 1, LineEnd);
              Line := Trim(Line);
              if Line <> '' then begin
                ThreadLog('T7ZipThread: Read line: ' + Line);
                if (Pos('22:', Line) = 1) or (Pos('23:', Line) = 1) or (Pos('24:', Line) = 1) or (Pos('25:', Line) = 1) then begin
                  Inc(StepCount);
                  if StepCount > 12 then StepCount := 12;
                  FProgress := StepCount / 12.0;
                  ThreadLog('T7ZipThread: Matched step: ' + IntToStr(StepCount) + ' progress: ' + FloatToStr(FProgress));
                end;
                if Pos('Tot:', Line) = 1 then begin
                  totPos := Length(Line);
                  while (totPos > 0) and (Line[totPos] = ' ') do Dec(totPos);
                  i := totPos;
                  while (i > 0) and (Line[i] <> ' ') do Dec(i);
                  ValStr := Copy(Line, i + 1, totPos - i);
                  FScore := StrToIntDef(ValStr, 0);
                  ThreadLog('T7ZipThread: Matched Tot. Score: ' + IntToStr(FScore));
                end;
              end;
            end else
              Break;
          end;
        end;
      end;
      Sleep(50);
    end;
    if AProcess.Running then begin
      AProcess.Terminate(0);
    end;
    ThreadLog('T7ZipThread.Execute: Process loop ended. ExitStatus = ' + IntToStr(AProcess.ExitStatus));
  finally
    AProcess.Free;
  end;
  FProgress := 1.0;
  ThreadLog('T7ZipThread.Execute: Thread completed. Score = ' + IntToStr(FScore));
end;


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

const SkyVertices:array[0..2] of TSkyVertex=
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
 fDraggingCube:=false;
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
 fHoveredButtonIndex := -1;
 fCubeIndexCount := 36;
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
 if Assigned(f7ZipThread) then begin
  f7ZipThread.Terminate;
  f7ZipThread.WaitFor;
  FreeAndNil(f7ZipThread);
 end;
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
   fSkyPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvFloat)*2);
   fSkyPipelineLayout.Initialize;

  fVulkanGraphicsPipeline:=nil;
  fSkyGraphicsPipeline:=nil;

 fVulkanRenderPass:=nil;

  GenerateBeveledCube;

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
     case fSelectedResolution of
      0: fResolutionOption := ro720p;
      1: fResolutionOption := ro1080p;
      2: fResolutionOption := roNative;
     end;
    end;
   end;
   KEYCODE_DOWN:begin
    if fBenchmarkPhase = bpIdleMenu then begin
     if fSelectedResolution < 2 then Inc(fSelectedResolution);
     case fSelectedResolution of
      0: fResolutionOption := ro720p;
      1: fResolutionOption := ro1080p;
      2: fResolutionOption := roNative;
     end;
    end;
   end;
  end;
 end;
end;

function TPasCubeScreen.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Delta:TpvVector2;
begin
 result := false;
 case aPointerEvent.PointerEventType of
  TpvApplicationInputPointerEventType.Down:begin
   if aPointerEvent.Button=TpvApplicationInputPointerButton.Left then begin
    fMouseLeftButtonDown:=true;
    fLastMousePosition:=aPointerEvent.Position;
    if IsStartButtonHovered(aPointerEvent.Position) then begin
     fAutoRotation:=false;
     fDraggingCube:=false;
     result:=true;
    end else begin
     fAutoRotation:=false;
     fDraggingCube:=true;
    end;
   end;
  end;
  TpvApplicationInputPointerEventType.Up:begin
   if aPointerEvent.Button=TpvApplicationInputPointerButton.Left then begin
    fMouseLeftButtonDown:=false;
    fAutoRotation:=true;
    if fDraggingCube then begin
     fDraggingCube:=false;
    end else if IsStartButtonHovered(aPointerEvent.Position) then begin
     StartBenchmark;
     result:=true;
    end;
   end;
  end;
  TpvApplicationInputPointerEventType.Motion:begin
   Delta:=aPointerEvent.Position-fLastMousePosition;
   if fMouseLeftButtonDown and fDraggingCube then begin
    fState.AnglePhases[1]:=fState.AnglePhases[1]+(Delta.x*0.005);
    fState.AnglePhases[0]:=fState.AnglePhases[0]+(Delta.y*0.005);
   end;
   fLastMousePosition:=aPointerEvent.Position;
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

  case fBenchmarkPhase of
   bpWarmup: begin
    if fPhaseTimer >= 3.0 then NextPhase;
   end;
    bpCPU_Single, bpCPU_Multi: begin
     if Assigned(f7ZipThread) then begin
       if Frac(fPhaseTimer * 2.0) < aDeltaTime * 2.0 then begin
         DebugLog('Update: Phase=' + GetPhaseName + ' ThreadFinished=' + BoolToStr(f7ZipThread.IsFinished, True) + ' Progress=' + FloatToStrF(f7ZipThread.Progress, ffFixed, 1, 3) + ' Score=' + IntToStr(f7ZipThread.Score));
         WriteLn('Update: Phase=', GetPhaseName, ' ThreadFinished=', f7ZipThread.IsFinished, ' Progress=', f7ZipThread.Progress, ' Score=', f7ZipThread.Score);
       end;
       if f7ZipThread.IsFinished then begin
         DebugLog('Update: Phase=' + GetPhaseName + ' thread finished. Moving to next phase.');
         NextPhase;
       end;
     end else begin
       DebugLog('Update: Phase=' + GetPhaseName + ' thread is nil! Moving to next phase.');
       WriteLn('Update: Phase=', GetPhaseName, ' Thread is nil!');
       NextPhase;
     end;
    end;
   bpGPU_Stress: begin
    if fPhaseTimer >= 10.0 then NextPhase;
   end;
  end;
 end;

 // Update lights & particles if in GPU stress phase
 if fBenchmarkPhase = bpGPU_Stress then begin
  UpdateLights(aDeltaTime);
  UpdateParticles(aDeltaTime);
 end;

 // Original cube rotation (for idle/demo or benchmark)
 SpeedMultiplier := pvApplication.FramesPerSecond / MaxFPS;
 if SpeedMultiplier > 1.0 then SpeedMultiplier := 1.0;
 if SpeedMultiplier < 0.0 then SpeedMultiplier := 0.0;
 
 if fBenchmarkPhase = bpCPU_Single then
   SpeedMultiplier := SpeedMultiplier * 4.0
 else if fBenchmarkPhase = bpCPU_Multi then
   SpeedMultiplier := SpeedMultiplier * 10.0;

 if fAutoRotation or (fBenchmarkPhase > bpIdleMenu) then begin
  fState.Time := fState.Time + aDeltaTime;
  fState.AnglePhases[0] := frac(fState.AnglePhases[0] + (aDeltaTime * f0 * SpeedMultiplier));
  fState.AnglePhases[1] := frac(fState.AnglePhases[1] + (aDeltaTime * f1 * SpeedMultiplier));
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
    SkyParams: array[0..1] of TpvFloat;
    scaleFactor, scaleX, scaleY, scaleZ: TpvFloat;
    N, Cols, Rows, colIdx, rowIdx: Integer;
    SpacingX, SpacingY, CubeScale, PosX, PosY: TpvFloat;
    CubeScaleX, CubeScaleY, CubeScaleZ, rotX, rotY: TpvFloat;
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
    SkyParams[0] := State^.AnglePhases[1];
    SkyParams[1] := State^.AnglePhases[0];
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
     fSkyPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
     0, SizeOf(TpvFloat)*2, @SkyParams[0]);
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

    if fBenchmarkPhase = bpGPU_Stress then
     gpuStressValue := fBenchmarkTimer
    else
     gpuStressValue := 0.0;

    // Render physics bodies (Not used anymore as we cleared the physics world)
    if isBenchmark and (fPhysicsWorld.BodyCount > 0) then begin
     for i := 0 to fPhysicsWorld.BodyCount - 1 do begin
      body := fPhysicsWorld.GetBody(i);
      if not Assigned(body) or not body^.Active then Continue;
      ModelMatrix := TpvMatrix4x4.CreateScale(body^.Scale, body^.Scale, body^.Scale) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.x, TpvVector3.Create(1,0,0)) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.y, TpvVector3.Create(0,1,0)) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.z, TpvVector3.Create(0,0,1)) *
                     TpvMatrix4x4.CreateTranslation(body^.Position.x, body^.Position.y, body^.Position.z);
      fUniformBuffer.Instances[0].ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
      fUniformBuffer.Instances[0].ModelViewMatrix := ModelMatrix * ViewMatrix;
      fUniformBuffer.Instances[0].ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);
      p := fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
      if assigned(p) then begin
       Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
      end;
      PushConstants.Vector := TpvVector4.Create(body^.Color.x, body^.Color.y, body^.Color.z, 1.0);
      PushConstants.Params := TpvVector4.Create(1.4, 0.7, 24.0, gpuStressValue);
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
       fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
       0, SizeOf(TpvVector4)*2, @PushConstants);
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount,1,0,0,0);
     end;
    end;

    // Render particles (GPU particle phase)
    if isBenchmark and (fParticleCount > 0) and (fBenchmarkPhase = bpGPU_Stress) then begin
     for i := 0 to fParticleCount - 1 do begin
      ModelMatrix := TpvMatrix4x4.CreateScale(0.15, 0.15, 0.15) *
                     TpvMatrix4x4.CreateTranslation(
                      fParticlePositions[i].x,
                      fParticlePositions[i].y,
                      fParticlePositions[i].z);
      fUniformBuffer.Instances[0].ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
      fUniformBuffer.Instances[0].ModelViewMatrix := ModelMatrix * ViewMatrix;
      fUniformBuffer.Instances[0].ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);
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
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount,1,0,0,0);
     end;
    end;

    // Default cube (idle menu / warmup / CPU single / GPU stress phases)
    if (not isBenchmark) or (fBenchmarkPhase in [bpWarmup, bpCPU_Single, bpGPU_Stress]) then begin
     ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
                  TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));

     if isBenchmark then begin
       if fBenchmarkPhase = bpCPU_Single then begin
         scaleFactor := 1.0 + Sin(fPhaseTimer * 10.0) * 0.12;
         ModelMatrix := TpvMatrix4x4.CreateScale(scaleFactor, scaleFactor, scaleFactor) * ModelMatrix;
         PushConstants.Vector := TpvVector4.Create(1.0, 0.45 + 0.1 * Sin(fPhaseTimer * 8.0), 0.0, 1.0);
         PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, 0.0);
       end else if fBenchmarkPhase = bpGPU_Stress then begin
         PushConstants.Vector := TpvVector4.Create(0.0, 0.8 + 0.2 * Sin(fPhaseTimer * 8.0), 1.0, 1.0);
         PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, gpuStressValue);
       end else begin
         PushConstants.Vector := TpvVector4.Create(0.92, 0.93, 0.98, 1.0);
         PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, 0.0);
       end;
     end else begin
       PushConstants.Vector := TpvVector4.Create(0.92, 0.93, 0.98, 1.0);
       PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, 0.0);
     end;

     fUniformBuffer.Instances[0].ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
     fUniformBuffer.Instances[0].ModelViewMatrix:=ModelMatrix*ViewMatrix;
     fUniformBuffer.Instances[0].ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);
     p:=fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
     if assigned(p) then begin
      Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
     end;
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
      fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
      0, SizeOf(TpvVector4)*2, @PushConstants);
     fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount,1,0,0,0);
    end else if isBenchmark and (fBenchmarkPhase = bpCPU_Multi) then begin
      // CPU Multi-Threaded phase: Render a grid of cubes corresponding to logical core/thread count
      N := pvApplication.CountCPUThreads;
      if N < 1 then N := 1;
      if N > 256 then N := 256;

      Cols := Trunc(Sqrt(N));
      if Sqrt(N) - Cols > 0.0 then Inc(Cols);
      Rows := N div Cols;
      if N mod Cols <> 0 then Inc(Rows);

      SpacingX := 4.2 / Max(1, Cols);
      SpacingY := 3.0 / Max(1, Rows);
      CubeScale := Min(1.0 / Cols, 1.0 / Rows) * 0.95;

      for i := 0 to N - 1 do begin
        colIdx := i mod Cols;
        rowIdx := i div Cols;
        PosX := (colIdx - (Cols - 1) * 0.5) * SpacingX;
        PosY := ((Rows - 1 - rowIdx) - (Rows - 1) * 0.5) * SpacingY;

        scaleX := 1.0 + Sin(fPhaseTimer * 15.0 + i) * 0.15;
        scaleY := 1.0 + Cos(fPhaseTimer * 12.0 + i) * 0.15;
        scaleZ := 1.0 + Sin(fPhaseTimer * 9.0 + i) * 0.15;

        CubeScaleX := CubeScale * scaleX;
        CubeScaleY := CubeScale * scaleY;
        CubeScaleZ := CubeScale * scaleZ;

        rotX := State^.AnglePhases[0] + (i * 0.17);
        rotY := State^.AnglePhases[1] + (i * 0.13);

        ModelMatrix := TpvMatrix4x4.CreateScale(CubeScaleX, CubeScaleY, CubeScaleZ) *
                       TpvMatrix4x4.CreateRotate(rotX * TwoPI, TpvVector3.Create(0.0,0.0,1.0)) *
                       TpvMatrix4x4.CreateRotate(rotY * TwoPI, TpvVector3.Create(0.0,1.0,0.0)) *
                       TpvMatrix4x4.CreateTranslation(PosX, PosY, 0.0);

        fUniformBuffer.Instances[i].ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
        fUniformBuffer.Instances[i].ModelViewMatrix := ModelMatrix * ViewMatrix;
        fUniformBuffer.Instances[i].ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);
      end;

      p := fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
      if assigned(p) then begin
       Move(fUniformBuffer, p^, SizeOf(TScreenExampleCubeUniformBuffer));
      end;

      PushConstants.Vector := TpvVector4.Create(1.0, 0.05 + 0.05 * Sin(fPhaseTimer * 8.0), 0.0, 1.0);
      PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, 0.0);

      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
       fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
       0, SizeOf(TpvVector4)*2, @PushConstants);
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount, N, 0, 0, 0);
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
 if Assigned(fDebugLog) then begin
  fDebugLog.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' | ' + aMsg);
  SaveDebugLog;
 end;
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
  bpCPU_Single: Result := 0.0;
  bpCPU_Multi: Result := 0.0;
  bpGPU_Stress: Result := 10.0;
  else Result := 0.0;
 end;
end;

function TPasCubeScreen.GetPhaseName: String;
begin
 case fBenchmarkPhase of
  bpIdleMenu: Result := 'Menu';
  bpWarmup: Result := 'Warmup';
  bpCPU_Single: Result := 'CPU Single-Thread';
  bpCPU_Multi: Result := 'CPU Multi-Thread';
  bpGPU_Stress: Result := 'GPU Vulkan Render';
  bpResults: Result := 'Results';
  else Result := 'Unknown';
 end;
end;

function TPasCubeScreen.GetPhaseObjectCount: Integer;
begin
 Result := 1;
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
  if Assigned(f7ZipThread) then begin
    f7ZipThread.Free;
    f7ZipThread := nil;
  end;
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
begin
  if (fBenchmarkPhase > bpWarmup) and (fPhaseResultIndex >= 0) and (fPhaseResultIndex <= 6) then begin
   if (fFrameCount > 0) and (fPhaseFrameTimeSum > 0.0) then begin
    fpsAvg := fFrameCount / fPhaseFrameTimeSum;
    ftAvg := (fPhaseFrameTimeSum / fFrameCount) * 1000.0;
   end else begin
    fpsAvg := 0.0;
    ftAvg := 0.0;
   end;

   fCurrentResult.PhaseResults[fPhaseResultIndex].PhaseName := GetPhaseName;
   fCurrentResult.PhaseResults[fPhaseResultIndex].FPSAvg := fpsAvg;
   fCurrentResult.PhaseResults[fPhaseResultIndex].FPSMin := fPhaseFPSMin;
   fCurrentResult.PhaseResults[fPhaseResultIndex].FPSMax := fPhaseFPSMax;
   fCurrentResult.PhaseResults[fPhaseResultIndex].FrameTimeMs := ftAvg;

   if fBenchmarkPhase = bpCPU_Single then begin
     if Assigned(f7ZipThread) then begin
       fCurrentResult.PhaseResults[fPhaseResultIndex].Score := f7ZipThread.Score;
       fCurrentResult.PhaseResults[fPhaseResultIndex].FPSAvg := f7ZipThread.Score;
     end;
     fCurrentResult.PhaseResults[fPhaseResultIndex].ObjectsRendered := 1;
     fCurrentResult.PhaseResults[fPhaseResultIndex].LightsActive := 0;
     fCurrentResult.PhaseResults[fPhaseResultIndex].ParticlesActive := 0;
     fCurrentResult.PhaseResults[fPhaseResultIndex].PhysicsBodies := 0;
   end else if fBenchmarkPhase = bpCPU_Multi then begin
     if Assigned(f7ZipThread) then begin
       fCurrentResult.PhaseResults[fPhaseResultIndex].Score := f7ZipThread.Score;
       fCurrentResult.PhaseResults[fPhaseResultIndex].FPSAvg := f7ZipThread.Score;
     end;
     fCurrentResult.PhaseResults[fPhaseResultIndex].ObjectsRendered := 1;
     fCurrentResult.PhaseResults[fPhaseResultIndex].LightsActive := 0;
     fCurrentResult.PhaseResults[fPhaseResultIndex].ParticlesActive := 0;
     fCurrentResult.PhaseResults[fPhaseResultIndex].PhysicsBodies := 0;
   end else if fBenchmarkPhase = bpGPU_Stress then begin
     fCurrentResult.PhaseResults[fPhaseResultIndex].Score := Round(fpsAvg * 35.0);
     fCurrentResult.PhaseResults[fPhaseResultIndex].ObjectsRendered := 1;
     fCurrentResult.PhaseResults[fPhaseResultIndex].LightsActive := 8;
     fCurrentResult.PhaseResults[fPhaseResultIndex].ParticlesActive := fParticleCount;
     fCurrentResult.PhaseResults[fPhaseResultIndex].PhysicsBodies := 0;
   end;
  end;

  if Assigned(f7ZipThread) then begin
    f7ZipThread.Free;
    f7ZipThread := nil;
  end;

  case fBenchmarkPhase of
   bpWarmup: begin
    DebugLog('NextPhase: bpWarmup -> bpCPU_Single. Spawning 7-Zip single-thread.');
    fBenchmarkPhase := bpCPU_Single;
    fPhaseResultIndex := 1;
    f7ZipThread := T7ZipThread.Create('7z', '-mmt1');
   end;
   bpCPU_Single: begin
    DebugLog('NextPhase: bpCPU_Single -> bpCPU_Multi. Spawning 7-Zip multi-thread.');
    fBenchmarkPhase := bpCPU_Multi;
    fPhaseResultIndex := 2;
    f7ZipThread := T7ZipThread.Create('7z', '');
   end;
   bpCPU_Multi: begin
    DebugLog('NextPhase: bpCPU_Multi -> bpGPU_Stress. Initializing particles.');
    fBenchmarkPhase := bpGPU_Stress;
    fPhaseResultIndex := 3;
    InitParticles;
    fParticleCount := 2000;
   end;
   bpGPU_Stress: begin
    DebugLog('NextPhase: bpGPU_Stress -> bpResults. Completing benchmark.');
    fBenchmarkPhase := bpResults;
    fPhaseResultIndex := 4;
    CalculateScore;
    FinishBenchmark;
    Exit;
   end;
   else begin
    DebugLog('NextPhase: Unknown or bpResults -> bpIdleMenu.');
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
var cpuSTPoints, cpuMTPoints, gpuPoints: Integer;
begin
  // Calculate normalized points:
  // CPU ST: raw MIPS / 3
  // CPU MT: raw MIPS / 20
  // GPU: already set to fpsAvg * 35 in NextPhase
  cpuSTPoints := Round(fCurrentResult.PhaseResults[1].Score / 3.0);
  cpuMTPoints := Round(fCurrentResult.PhaseResults[2].Score / 20.0);
  gpuPoints := fCurrentResult.PhaseResults[3].Score;

  if cpuSTPoints < 1 then cpuSTPoints := 1;
  if cpuMTPoints < 1 then cpuMTPoints := 1;
  if gpuPoints < 1 then gpuPoints := 1;

  // Save normalized points in Score for display in the grid
  fCurrentResult.PhaseResults[1].Score := cpuSTPoints;
  fCurrentResult.PhaseResults[2].Score := cpuMTPoints;
  fCurrentResult.PhaseResults[3].Score := gpuPoints;

  // Calculate weighted global gaming score: 35% CPU ST + 15% CPU MT + 50% GPU
  fCurrentResult.TotalScore := Round((0.35 * cpuSTPoints) + (0.15 * cpuMTPoints) + (0.50 * gpuPoints));
  if fCurrentResult.TotalScore < 1 then fCurrentResult.TotalScore := 1;
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
 pvApplication.Terminate;
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
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
    isHovered: Boolean;
    bgR, bgG, bgB, bgA: TpvFloat;
    fgR, fgG, fgB, fgA: TpvFloat;
    textR, textG, textB, textA: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 cx := pvApplication.Width * 0.5;
 yText := pvApplication.Height - 110.0;

 isHovered := IsStartButtonHovered(fLastMousePosition);

  // Configure colors based on hover state (GOverlay Blue Theme)
  if isHovered then begin
   // Lighter blue-grey fill, cyan outline, white text
   bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
   fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
   textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
  end else begin
   // GOverlay dark blue-grey background, subtle blue-grey outline, silver-white text
   bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
   fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
   textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
  end;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;

  btnWidth := (15.0 * charWidth * 1.8) + (2.0 * paddingX);
  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
  btnX := cx - (btnWidth * 0.5);
  btnY := yText - paddingY;

  // Centered Title (Increased font size to 3.0, using default font)
  app.TextOverlay.AddText(cx, 80.0, 3.0, toaCenter, 'PasCube Benchmark');

  // Draw the button background box
  app.TextOverlay.AddBox(btnX, btnY, btnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);

  // Draw the button text (Increased font size to 1.8, using default font)
  app.TextOverlay.AddText(cx, yText, 1.8, toaCenter, 'Start benchmark', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
end;

function TPasCubeScreen.IsStartButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
begin
  Result := false;
  if fBenchmarkPhase <> bpIdleMenu then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  cx := pvApplication.Width * 0.5;
  yText := pvApplication.Height - 110.0;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;

  btnWidth := (15.0 * charWidth * 1.8) + (2.0 * paddingX);
  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
  btnX := cx - (btnWidth * 0.5);
  btnY := yText - paddingY;

  Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
            (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

procedure TPasCubeScreen.DrawBenchmarkOverlay;
var app: TPasCubeApplication;
    phaseStr, infoStr: String;
    duration, progress: TpvDouble;
    pbWidth, pbHeight, pbX, pbY: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 phaseStr := GetPhaseName;
 duration := GetPhaseDuration;

 if (fBenchmarkPhase = bpCPU_Single) or (fBenchmarkPhase = bpCPU_Multi) then begin
   if Assigned(f7ZipThread) then
     progress := f7ZipThread.Progress
   else
     progress := 0.0;
 end else begin
   if duration > 0 then
     progress := fPhaseTimer / duration
   else
     progress := 0.0;
 end;

 if progress > 1.0 then progress := 1.0;
 if progress < 0.0 then progress := 0.0;

 // Render header centered
 app.TextOverlay.AddText(pvApplication.Width * 0.5, 40.0, 2.2, toaCenter, phaseStr);

 // Render FPS on the top left
 app.TextOverlay.AddText(20, 40, 1.5, toaLeft, Format('FPS: %.1f', [pvApplication.FramesPerSecond]));

 infoStr := '';
 case fBenchmarkPhase of
  bpWarmup: infoStr := 'Calibrating render engine and caches...';
  bpCPU_Single: infoStr := 'Running 7-Zip Single-Thread benchmark (MIPS)...';
  bpCPU_Multi: infoStr := 'Running 7-Zip Multi-Thread benchmark (MIPS)...';
  bpGPU_Stress: infoStr := 'Running Vulkan GPU Stress (2,000 particles + 8 lights)...';
 end;

 pbWidth := pvApplication.Width * 0.6;
 pbHeight := 24.0;
 pbX := (pvApplication.Width - pbWidth) * 0.5;
 pbY := pvApplication.Height - 120.0;

 // Draw stage description and progress percentage
 if infoStr <> '' then
  app.TextOverlay.AddText(pvApplication.Width * 0.5, pbY - 25.0, 1.2, toaCenter, infoStr);
  
 app.TextOverlay.AddText(pvApplication.Width * 0.5, pbY - 55.0, 1.5, toaCenter, Format('Progress: %.0f%%', [progress * 100.0]));

 // Draw progress bar track (background box, GOverlay dark blue-grey, blue-grey outline)
 app.TextOverlay.AddBox(pbX, pbY, pbWidth, pbHeight,
                        22.0/255.0, 25.0/255.0, 37.0/255.0, 0.8,
                        50.0/255.0, 60.0/255.0, 85.0/255.0, 1.0,
                        255.0);

 // Draw progress bar fill (cyan)
 if progress > 0.01 then begin
  app.TextOverlay.AddBox(pbX + 2.0, pbY + 2.0, (pbWidth - 4.0) * progress, pbHeight - 4.0,
                         48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0,
                         48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0,
                         255.0);
 end;
end;

procedure TPasCubeScreen.DrawResultsOverlay;
var app: TPasCubeApplication;
    cy, cx, y: TpvFloat;
    i, j: Integer;
    lineStr, resultStr, descStr: String;
    leftColX1, leftColWidth, rightColX1, rightColWidth: TpvFloat;
    ry: TpvFloat;
    HWRefs: array[0..8] of THardwareRef;
    TempHW: THardwareRef;
    MaxScore: Integer;
    barStartX, maxBarWidth, barWidth, barHeight, barY: TpvFloat;
    bgR, bgG, bgB, bgA: TpvFloat;
    hwScoreStr: String;
    charWidth, charHeight: TpvFloat;
    textScaleTitle, textScaleValue, textScaleHeader, textScaleNormal, textScaleSmall: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 charWidth := app.TextOverlay.FontCharWidth;
 charHeight := app.TextOverlay.FontCharHeight;

 textScaleTitle := 2.2;
 textScaleValue := 3.2;
 textScaleHeader := 1.4;
 textScaleNormal := 1.15;
 textScaleSmall := 0.85;

 cx := pvApplication.Width * 0.5;
 cy := pvApplication.Height * 0.06;

 app.TextOverlay.AddText(cx, cy, textScaleTitle, toaCenter, 'Benchmark Complete!');
 app.TextOverlay.AddText(cx, cy + charHeight * textScaleTitle * 1.3, textScaleValue, toaCenter, FormatScoreValue(fCurrentResult.TotalScore));

 leftColX1 := pvApplication.Width * 0.06;
 leftColWidth := pvApplication.Width * 0.42;
 rightColX1 := pvApplication.Width * 0.52;
 rightColWidth := pvApplication.Width * 0.42;

 y := cy + charHeight * 7.5;

 // --- COLUNA ESQUERDA: Detalhes do Benchmark ---
 app.TextOverlay.AddText(leftColX1, y, textScaleHeader, toaLeft, 'Detalhes do Benchmark');
 y := y + charHeight * textScaleHeader * 1.2;
 app.TextOverlay.AddText(leftColX1, y, textScaleNormal, toaLeft, '---------------------------------------------------------');

 for i := 1 to 3 do begin
  y := y + charHeight * textScaleNormal * 1.4;
  case i of
   1: begin
     resultStr := Format('%s MIPS', [FormatScoreValue(Round(fCurrentResult.PhaseResults[i].FPSAvg))]);
     descStr := 'Importante para fisica basica, logica do jogo e taxa de FPS minima.';
   end;
   2: begin
     resultStr := Format('%s MIPS', [FormatScoreValue(Round(fCurrentResult.PhaseResults[i].FPSAvg))]);
     descStr := 'Importante para streaming de assets, fisica avancada e IA complexa.';
   end;
   3: begin
     resultStr := Format('%.1f FPS', [fCurrentResult.PhaseResults[i].FPSAvg]);
     descStr := 'Determina a taxa maxima de quadros (FPS) e a fidelidade visual.';
   end;
   else begin
     resultStr := '';
     descStr := '';
   end;
  end;

  app.TextOverlay.AddText(leftColX1, y, textScaleNormal, toaLeft, fCurrentResult.PhaseResults[i].PhaseName);
  app.TextOverlay.AddText(leftColX1 + leftColWidth, y, textScaleNormal, toaRight, Format('%s  (%s pts)', [resultStr, FormatScoreValue(fCurrentResult.PhaseResults[i].Score)]));

  y := y + charHeight * textScaleNormal * 1.0;
  app.TextOverlay.AddText(leftColX1 + 10.0, y, textScaleSmall, toaLeft, descStr);
 end;

 y := y + charHeight * textScaleNormal * 2.2;
 app.TextOverlay.AddText(leftColX1, y, textScaleHeader, toaLeft, 'Historico (Ultimos 5 testes)');
 y := y + charHeight * textScaleHeader * 1.2;
 app.TextOverlay.AddText(leftColX1, y, textScaleNormal, toaLeft, '---------------------------------------------------------');

 for i := 0 to Min(fHistoryCount, 5) - 1 do begin
  y := y + charHeight * textScaleNormal * 1.3;
  lineStr := Format('#%d: %s pts  (%s)', [i+1, FormatScoreValue(fHistory[i].TotalScore), StringReplace(fHistory[i].Timestamp, 'T', ' ', [rfReplaceAll])]);
  app.TextOverlay.AddText(leftColX1, y, textScaleNormal, toaLeft, lineStr);
 end;

 // --- COLUNA DIREITA: Comparativo de Hardware ---
 ry := cy + charHeight * 7.5;
 app.TextOverlay.AddText(rightColX1, ry, textScaleHeader, toaLeft, 'Comparativo de Hardware');
 ry := ry + charHeight * textScaleHeader * 1.2;
 app.TextOverlay.AddText(rightColX1, ry, textScaleNormal, toaLeft, '---------------------------------------------------------');

 HWRefs[0].Name := 'Nintendo Switch'; HWRefs[0].Score := 400; HWRefs[0].IsCurrent := false;
 HWRefs[0].Specs := 'CPU: Tegra X1 4C | RAM: 4GB LPDDR4 | GPU: Maxwell 256 | OS: Horizon';
 HWRefs[1].Name := 'Steam Deck'; HWRefs[1].Score := 1300; HWRefs[1].IsCurrent := false;
 HWRefs[1].Specs := 'CPU: Zen 2 4C/8T | RAM: 16GB LPDDR5 | GPU: RDNA2 8CU | OS: SteamOS';
 HWRefs[2].Name := 'ROG Ally X'; HWRefs[2].Score := 2100; HWRefs[2].IsCurrent := false;
 HWRefs[2].Specs := 'CPU: Z1 Extreme | RAM: 24GB LPDDR5X | GPU: RDNA3 12CU | OS: Win11';
 HWRefs[3].Name := 'PC Gamer Basico'; HWRefs[3].Score := 2800; HWRefs[3].IsCurrent := false;
 HWRefs[3].Specs := 'CPU: i3 12100F | RAM: 16GB DDR4 | GPU: RX 6600 8GB | OS: Win11';
 HWRefs[4].Name := 'Xbox Series'; HWRefs[4].Score := 3200; HWRefs[4].IsCurrent := false;
 HWRefs[4].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 52CU | OS: Custom OS';
 HWRefs[5].Name := 'PlayStation 5'; HWRefs[5].Score := 4500; HWRefs[5].IsCurrent := false;
 HWRefs[5].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 36CU | OS: Custom OS';
 HWRefs[6].Name := 'PC Gamer Medio'; HWRefs[6].Score := 6500; HWRefs[6].IsCurrent := false;
 HWRefs[6].Specs := 'CPU: R5 7600 | RAM: 32GB DDR5 | GPU: RTX 4060 Ti | OS: Win11';
 HWRefs[7].Name := 'PC Gamer Avancado'; HWRefs[7].Score := 12500; HWRefs[7].IsCurrent := false;
 HWRefs[7].Specs := 'CPU: R7 7800X3D | RAM: 32GB DDR5 | GPU: RTX 4080 Super | OS: Win11';
 HWRefs[8].Name := 'Sistema Atual'; HWRefs[8].Score := fCurrentResult.TotalScore; HWRefs[8].IsCurrent := true;
 HWRefs[8].Specs := 'CPU: ' + IntToStr(pvApplication.CountCPUThreads) + 'T | GPU: ' + fCurrentResult.DeviceName;

 // Ordenar decrescente por pontuacao
 for i := 0 to 7 do begin
  for j := i + 1 to 8 do begin
   if HWRefs[i].Score < HWRefs[j].Score then begin
    TempHW := HWRefs[i];
    HWRefs[i] := HWRefs[j];
    HWRefs[j] := TempHW;
   end;
  end;
 end;

 MaxScore := HWRefs[0].Score;
 if MaxScore = 0 then MaxScore := 1;

 for i := 0 to 8 do begin
  ry := ry + charHeight * textScaleNormal * 2.2;
  // Left: Name
  app.TextOverlay.AddText(rightColX1, ry, textScaleNormal, toaLeft, HWRefs[i].Name);
  
  // Right: Score
  hwScoreStr := FormatScoreValue(HWRefs[i].Score);
  app.TextOverlay.AddText(rightColX1 + rightColWidth, ry, textScaleNormal, toaRight, hwScoreStr);
  
  // Draw horizontal bar dynamically
  barStartX := rightColX1 + (20.0 * charWidth * textScaleNormal);
  maxBarWidth := rightColWidth - (20.0 * charWidth * textScaleNormal) - (10.0 * charWidth * textScaleNormal);
  barWidth := (HWRefs[i].Score / MaxScore) * maxBarWidth;
  if barWidth < 2.0 then barWidth := 2.0;
  
  if HWRefs[i].IsCurrent then begin
   bgR := 48.0 / 255.0;
   bgG := 190.0 / 255.0;
   bgB := 240.0 / 255.0;
   bgA := 1.0;
  end else begin
   bgR := 70.0 / 255.0;
   bgG := 80.0 / 255.0;
   bgB := 100.0 / 255.0;
   bgA := 0.8;
  end;

  barHeight := charHeight * textScaleNormal * 0.7;
  barY := ry + (charHeight * textScaleNormal - barHeight) * 0.5;

  app.TextOverlay.AddBox(barStartX, barY, barWidth, barHeight, bgR, bgG, bgB, bgA, bgR, bgG, bgB, bgA, 255.0);

  // Draw Specs
  app.TextOverlay.AddText(rightColX1 + (2.0 * charWidth * textScaleSmall),
                          ry + charHeight * textScaleNormal * 1.0,
                          textScaleSmall,
                          toaLeft,
                          HWRefs[i].Specs,
                          1.0, 1.0, 1.0, 0.0,
                          0.65, 0.70, 0.80, 1.0
                         );
 end;

 // Instrucoes
 app.TextOverlay.AddText(cx, pvApplication.Height - 80.0, textScaleNormal, toaCenter, 'Press ENTER/SPACE for Menu');
end;

procedure TPasCubeScreen.GenerateBeveledCube;
const Subdivisions = 16;
      R = 0.15;
      InnerLimit = 0.85; // 1.0 - R
var Face, ix, iy: Integer;
    fx, fy, len: TpvFloat;
    P, C, D, N: TpvVector3;
    U, V, W: TpvVector3;
    Vertices: array of TVertex;
    Indices: array of TpvInt32;
    VertexCount, IndexCount: Integer;
    v00, v10, v01, v11: Integer;
    FaceOffset: Integer;
    function Clamp(const Value, MinValue, MaxValue: TpvFloat): TpvFloat; inline;
    begin
     if Value < MinValue then
      result := MinValue
     else if Value > MaxValue then
      result := MaxValue
     else
      result := Value;
    end;
begin
 SetLength(Vertices, 6 * (Subdivisions + 1) * (Subdivisions + 1));
 SetLength(Indices, 6 * Subdivisions * Subdivisions * 6);
 VertexCount := 0;
 IndexCount := 0;

 for Face := 0 to 5 do begin
  // Define U, V (tangents) and W (normal) for each face
  case Face of
   0: begin // Left (-X)
    W := TpvVector3.Create(-1.0, 0.0, 0.0);
    U := TpvVector3.Create(0.0, 0.0, 1.0);
    V := TpvVector3.Create(0.0, 1.0, 0.0);
   end;
   1: begin // Right (+X)
    W := TpvVector3.Create(1.0, 0.0, 0.0);
    U := TpvVector3.Create(0.0, 0.0, -1.0);
    V := TpvVector3.Create(0.0, 1.0, 0.0);
   end;
   2: begin // Bottom (-Y)
    W := TpvVector3.Create(0.0, -1.0, 0.0);
    U := TpvVector3.Create(1.0, 0.0, 0.0);
    V := TpvVector3.Create(0.0, 0.0, 1.0);
   end;
   3: begin // Top (+Y)
    W := TpvVector3.Create(0.0, 1.0, 0.0);
    U := TpvVector3.Create(1.0, 0.0, 0.0);
    V := TpvVector3.Create(0.0, 0.0, -1.0);
   end;
   4: begin // Back (-Z)
    W := TpvVector3.Create(0.0, 0.0, -1.0);
    U := TpvVector3.Create(-1.0, 0.0, 0.0);
    V := TpvVector3.Create(0.0, 1.0, 0.0);
   end;
   5: begin // Front (+Z)
    W := TpvVector3.Create(0.0, 0.0, 1.0);
    U := TpvVector3.Create(1.0, 0.0, 0.0);
    V := TpvVector3.Create(0.0, 1.0, 0.0);
   end;
  end;

  FaceOffset := VertexCount;

  for iy := 0 to Subdivisions do begin
   fy := (iy / Subdivisions) * 2.0 - 1.0;
   for ix := 0 to Subdivisions do begin
    fx := (ix / Subdivisions) * 2.0 - 1.0;

    // Point on the unit cube face
    P := W + U * fx + V * fy;

    // Closest point on the inner box
    C.x := Clamp(P.x, -InnerLimit, InnerLimit);
    C.y := Clamp(P.y, -InnerLimit, InnerLimit);
    C.z := Clamp(P.z, -InnerLimit, InnerLimit);

    // Vector from inner box closest point to face point
    D := P - C;
    len := sqrt(sqr(D.x) + sqr(D.y) + sqr(D.z));

    if len > 0.0 then begin
     N := D * (1.0 / len);
     Vertices[VertexCount].Position := C + N * R;
     Vertices[VertexCount].Normal := N;
    end else begin
     Vertices[VertexCount].Position := P;
     Vertices[VertexCount].Normal := W;
    end;

    Vertices[VertexCount].Tangent := U;
    Vertices[VertexCount].Bitangent := V;
    Vertices[VertexCount].TexCoord.u := ix / Subdivisions;
    Vertices[VertexCount].TexCoord.v := iy / Subdivisions;

    Inc(VertexCount);
   end;
  end;

  // Indices
  for iy := 0 to Subdivisions - 1 do begin
   for ix := 0 to Subdivisions - 1 do begin
    v00 := FaceOffset + iy * (Subdivisions + 1) + ix;
    v10 := v00 + 1;
    v01 := v00 + (Subdivisions + 1);
    v11 := v01 + 1;

    Indices[IndexCount + 0] := v00;
    Indices[IndexCount + 1] := v01;
    Indices[IndexCount + 2] := v11;
    Indices[IndexCount + 3] := v00;
    Indices[IndexCount + 4] := v11;
    Indices[IndexCount + 5] := v10;
    Inc(IndexCount, 6);
   end;
  end;
 end;

 // Create and upload buffers
 fVulkanVertexBuffer := TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                             VertexCount * SizeOf(TVertex),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
 fVulkanVertexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                fVulkanTransferCommandBuffer,
                                fVulkanTransferCommandBufferFence,
                                Vertices[0],
                                0,
                                VertexCount * SizeOf(TVertex),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 fVulkanIndexBuffer := TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                            IndexCount * SizeOf(TpvInt32),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                           );
 fVulkanIndexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence,
                               Indices[0],
                               0,
                               IndexCount * SizeOf(TpvInt32),
                               TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 fCubeIndexCount := IndexCount;
end;

end.
