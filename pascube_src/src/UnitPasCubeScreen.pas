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
   bpGPU_1080p,    // GPU Vulkan stress at 1080p
   bpResults
  );

  TResolutionOption = (
   ro1080p
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
    PhaseResults: array[0..8] of TBenchmarkPhaseResult;
    DeviceName: String;
    VulkanAPI: String;
    KernelVersion: String;
    DriverVersion: String;
    BenchmarkDuration: Double;
    DisplayServer: String;
    DisplayResolution: String;
    RefreshRate: String;
    DesktopEnvironment: String;
    StorageType: String;
    VulkanDriver: String;
    CPUTempStart: Double;
    CPUTempMax: Double;
    CPUTempDelta: Double;
    GPUTempStart: Double;
    GPUTempMax: Double;
    GPUTempDelta: Double;
    CPUMaxFreq: Integer;
    GPUMaxFreq: Integer;
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
      ParticlePositions: array[0..7] of TpvVector4;
      ParticleColors: array[0..7] of TpvVector4;
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
       FLogBuffer: TStringList;
       function GetIsFinished: Boolean;
       procedure ThreadLog(const Msg: string);
       procedure WriteLogBufferToFile;
     protected
       procedure Execute; override;
     public
       constructor Create(const aCommand, aArguments: string);
       destructor Destroy; override;
       property Score: Integer read FScore;
       property IsFinished: Boolean read GetIsFinished;
       property Progress: Single read FProgress;
     end;

     TSubmitThread = class(TThread)
      private
        FUrl: string;
        FPayload: string;
        FSuccess: Boolean;
        FErrorMsg: string;
        FLogBuffer: TStringList;
        function GetIsFinished: Boolean;
        procedure ThreadLog(const Msg: string);
        procedure WriteLogBufferToFile;
      protected
        procedure Execute; override;
      public
        constructor Create(const aUrl, aPayload: string);
        destructor Destroy; override;
        property Success: Boolean read FSuccess;
        property ErrorMsg: string read FErrorMsg;
        property IsFinished: Boolean read GetIsFinished;
      end;

     TPasCubeScreen=class(TpvApplicationScreen)
      private
       fSubmitStatus: Integer; // 0=Idle, 1=Submitting, 2=Success, 3=Error, 4=Disabled
       fSubmitThread: TSubmitThread;
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
          fExpandedHardwareIdx: Integer;
          fHoveredHardwareIdx: Integer;
          fHoveredHistoryIdx: Integer;
          fHWExpandProgress: array[0..11] of TpvFloat;
            fClearConfirmPending: Boolean;
            fClearConfirmHovered: Integer; // 0=none, 1=yes, 2=no
            fSubmitConfirmPending: Boolean;
            fSubmitConfirmHovered: Integer; // 0=none, 1=yes, 2=no
           fShowMethodology: Boolean;
           fGPUIteration: Integer;
           fGPURuns: array[0..2] of TBenchmarkPhaseResult;

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
        fOffscreenColorAttachments: array of TpvVulkanFrameBufferAttachment;
        fOffscreenDepthAttachments: array of TpvVulkanFrameBufferAttachment;
        fOffscreenFrameBuffers: array of TpvVulkanFrameBuffer;
        fRenderWidth: Integer;
        fRenderHeight: Integer;
        fGPU360pFallback: Boolean;

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
        function IsViewResultsButtonHovered(const aPos: TpvVector2): Boolean;
          function IsReturnButtonHovered(const aPos: TpvVector2): Boolean;
          function IsSubmitButtonHovered(const aPos: TpvVector2): Boolean;
          function IsClearButtonHovered(const aPos: TpvVector2): Boolean;
          function GetSubmitURL: String;
          function GetBenchmarkResultsFilePath: String;
          procedure InitializeSubmitStatus;
          procedure SubmitBenchmarkResults;
           function IsClearConfirmButtonHovered(const aPos: TpvVector2; out aButton: Integer): Boolean;
           function IsSubmitConfirmButtonHovered(const aPos: TpvVector2; out aButton: Integer): Boolean;
          function IsHardwareItemHovered(const aPos: TpvVector2; out aIndex: Integer): Boolean;
          function IsMethodologyButtonHovered(const aPos: TpvVector2): Boolean;
          procedure DrawBenchmarkOverlay;
         procedure ClearBenchmarkResults;
          function GetCPUName: String;
          function GetCPUArchitecture: String;
          function GetPackageType: String;
         function GetRAMSize: String;
         function GetOSName: String;
          function CleanGPUName(const aName: String): String;
          function GetKernelVersion: String;
           function GetDriverVersion: String;
           function GetVRAMSize: String;
           function GetDisplayServer: String;
           procedure GetDisplayResolutionAndRefresh(out ARes, ARefresh: String);
           function GetDesktopEnvironment: String;
           function GetStorageType: String;
           function GetVulkanDriver: String;
           function GetCPUTemperature: Double;
           function GetGPUTemperature: Double;
           function GetCPUMaxFreq: Integer;
           function GetGPUMaxFreq: Integer;
           procedure DrawResultsOverlay;
           procedure DrawMethodologyOverlay;
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

function FloatToJsonStr(const AVal: Double): String;
begin
  Result := StringReplace(FormatFloat('0.0', AVal), ',', '.', [rfReplaceAll]);
end;

function GetLogDir: string;
begin
  Result := GetEnvironmentVariable('HOME') + '/.local/share/goverlay/logs';
  if Result = '/.local/share/goverlay/logs' then
    Result := '/tmp/goverlay/logs';
end;

function GetLogFilePath(const AFileName: string): string;
var
  Dir: string;
begin
  Dir := GetLogDir;
  if not DirectoryExists(Dir) then
    ForceDirectories(Dir);
  Result := Dir + '/' + AFileName;
end;

function T7ZipThread.GetIsFinished: Boolean;
begin
  Result := Finished;
end;

procedure T7ZipThread.ThreadLog(const Msg: string);
begin
  if Assigned(FLogBuffer) then
    FLogBuffer.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' | ' + Msg);
end;

procedure T7ZipThread.WriteLogBufferToFile;
var
  F: TextFile;
  Path: string;
  i: Integer;
begin
  if not Assigned(FLogBuffer) or (FLogBuffer.Count = 0) then Exit;
  Path := GetLogFilePath('pascube_thread.log');
  try
    AssignFile(F, Path);
    if FileExists(Path) then
      Append(F)
    else
      Rewrite(F);
    for i := 0 to FLogBuffer.Count - 1 do
      WriteLn(F, FLogBuffer[i]);
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
  FLogBuffer := TStringList.Create;
  inherited Create(False);
end;

destructor T7ZipThread.Destroy;
begin
  WriteLogBufferToFile;
  FreeAndNil(FLogBuffer);
  inherited Destroy;
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
              'if command -v ' + FCommand + ' >/dev/null 2>&1; then cmd="' + FCommand + '"; elif command -v 7zz >/dev/null 2>&1; then cmd="7zz"; else cmd="7za"; fi; ' +
              'if command -v stdbuf >/dev/null 2>&1; then ' +
              'exec stdbuf -oL "$cmd" b';
    if FArguments <> '' then
      ValStr := ValStr + ' ' + FArguments;
    ValStr := ValStr + ' 3; else exec "$cmd" b';
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

function TSubmitThread.GetIsFinished: Boolean;
begin
  Result := Finished;
end;

procedure TSubmitThread.ThreadLog(const Msg: string);
begin
  if Assigned(FLogBuffer) then
    FLogBuffer.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' | ' + Msg);
end;

procedure TSubmitThread.WriteLogBufferToFile;
var
  F: TextFile;
  Path: string;
  i: Integer;
begin
  if not Assigned(FLogBuffer) or (FLogBuffer.Count = 0) then Exit;
  Path := GetLogFilePath('pascube_submit.log');
  try
    AssignFile(F, Path);
    if FileExists(Path) then
      Append(F)
    else
      Rewrite(F);
    for i := 0 to FLogBuffer.Count - 1 do
      WriteLn(F, FLogBuffer[i]);
    CloseFile(F);
  except
    // ignore
  end;
end;

constructor TSubmitThread.Create(const aUrl, aPayload: string);
begin
  FUrl := aUrl;
  FPayload := aPayload;
  FSuccess := False;
  FErrorMsg := '';
  FLogBuffer := TStringList.Create;
  inherited Create(False);
end;

destructor TSubmitThread.Destroy;
begin
  WriteLogBufferToFile;
  FreeAndNil(FLogBuffer);
  inherited Destroy;
end;

procedure TSubmitThread.Execute;
var
  AProcess: TProcess;
  Buffer: array[0..2047] of Char;
  BytesRead: LongInt;
  ResponseText: string;
  AvailableBytes: Integer;
  i: Integer;
  EnvVar: string;
begin
  ThreadLog('TSubmitThread.Execute: Thread started. URL: ' + FUrl);
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

    AProcess.Executable := 'curl';
    AProcess.Parameters.Add('-s');
    AProcess.Parameters.Add('-L');
    AProcess.Parameters.Add('--connect-timeout');
    AProcess.Parameters.Add('10');
    AProcess.Parameters.Add('--max-time');
    AProcess.Parameters.Add('30');
    AProcess.Parameters.Add('-H');
    AProcess.Parameters.Add('Content-Type: application/json');
    AProcess.Parameters.Add('-d');
    AProcess.Parameters.Add(FPayload);
    AProcess.Parameters.Add(FUrl);
    AProcess.Options := [poUsePipes, poNoConsole, poStderrToOutPut];

    ThreadLog('TSubmitThread.Execute: Spawning curl...');
    try
      AProcess.Execute;
      AProcess.CloseInput;
      ThreadLog('TSubmitThread.Execute: curl spawned.');
    except
      on E: Exception do begin
        FSuccess := False;
        FErrorMsg := E.Message;
        ThreadLog('TSubmitThread.Execute: FAILED to execute curl. Exception: ' + E.Message);
        Exit;
      end;
    end;

    ResponseText := '';
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

      AvailableBytes := AProcess.Output.NumBytesAvailable;
      if AvailableBytes > 0 then begin
        if AvailableBytes > SizeOf(Buffer) - 1 then
          AvailableBytes := SizeOf(Buffer) - 1;
        BytesRead := AProcess.Output.Read(Buffer[0], AvailableBytes);
        if BytesRead > 0 then begin
          Buffer[BytesRead] := #0;
          ResponseText := ResponseText + StrPas(Buffer);
        end;
      end;
      Sleep(10);
    end;

    try
      AProcess.WaitOnExit;
    except
      // ignore
    end;

    ThreadLog('TSubmitThread.Execute: Curl exit status: ' + IntToStr(AProcess.ExitStatus));
    ThreadLog('TSubmitThread.Execute: Curl response: ' + ResponseText);

    if (AProcess.ExitStatus = 0) or (Pos('"status":"success"', ResponseText) > 0) or (Pos('"result":"success"', ResponseText) > 0) then begin
      FSuccess := True;
      // Google Apps Script redirect or permission errors might return page with error message
      if (Pos('"error"', ResponseText) > 0) or (Pos('errorMessage', ResponseText) > 0) or (Pos('Você precisa ter acesso', ResponseText) > 0) or (Pos('Você precisa de permissão', ResponseText) > 0) then begin
        FSuccess := False;
        if (Pos('Você precisa ter acesso', ResponseText) > 0) or (Pos('Você precisa de permissão', ResponseText) > 0) then
          FErrorMsg := 'Access Denied (Google Script permission error)'
        else
          FErrorMsg := 'Server returned error';
      end;
    end else begin
      FSuccess := False;
      FErrorMsg := 'Exit code ' + IntToStr(AProcess.ExitStatus);
    end;

  finally
    AProcess.Free;
  end;
  ThreadLog('TSubmitThread.Execute: Thread completed. Success = ' + BoolToStr(FSuccess, True));
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
  fResolutionOption := ro1080p;
 fSelectedResolution := 0;
 fHoveredButtonIndex := -1;
 fCubeIndexCount := 36;
 fBestScore := 0;
 fLastScore := 0;
 fHistoryCount := 0;
   fShowSkybox := true;
   fExpandedHardwareIdx := -1;
   fHoveredHardwareIdx := -1;
   fHoveredHistoryIdx := -1;
     fClearConfirmPending := false;
     fClearConfirmHovered := 0;
     fSubmitConfirmPending := false;
     fSubmitConfirmHovered := 0;
     fShowMethodology := false;
     FillChar(fHWExpandProgress, SizeOf(fHWExpandProgress), #0);
   fPhaseResultIndex := -1;
 FillChar(fCurrentResult,SizeOf(fCurrentResult),#0);
 FillChar(fHistory,SizeOf(fHistory),#0);
 fDebugLog := TStringList.Create;
 fLastDebugSave := 0.0;
  LoadResultsJSON;
  GetSubmitURL;
  fSubmitStatus := 0;
  fSubmitThread := nil;
  fRenderWidth := 1920;
  fRenderHeight := 1080;
  fGPU360pFallback := false;
end;

destructor TPasCubeScreen.Destroy;
begin
  if Assigned(f7ZipThread) then begin
   f7ZipThread.Terminate;
   f7ZipThread.WaitFor;
   FreeAndNil(f7ZipThread);
  end;
  if Assigned(fSubmitThread) then begin
   fSubmitThread.Terminate;
   fSubmitThread.WaitFor;
   FreeAndNil(fSubmitThread);
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

  for Index := 0 to Length(fOffscreenFrameBuffers) - 1 do begin
    FreeAndNil(fOffscreenFrameBuffers[Index]);
  end;
  fOffscreenFrameBuffers := nil;

  for Index := 0 to Length(fOffscreenColorAttachments) - 1 do begin
    FreeAndNil(fOffscreenColorAttachments[Index]);
  end;
  fOffscreenColorAttachments := nil;

  for Index := 0 to Length(fOffscreenDepthAttachments) - 1 do begin
    FreeAndNil(fOffscreenDepthAttachments[Index]);
  end;
  fOffscreenDepthAttachments := nil;

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

  fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0, 0.0, 1920.0, 1080.0, 0.0, 1.0);
  fVulkanGraphicsPipeline.ViewPortState.AddScissor(0, 0, 1920, 1080);
  fVulkanGraphicsPipeline.DynamicState.AddDynamicStates([VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]);

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

  fSkyGraphicsPipeline.ViewPortState.AddViewPort(0.0, 0.0, 1920.0, 1080.0, 0.0, 1.0);
  fSkyGraphicsPipeline.ViewPortState.AddScissor(0, 0, 1920, 1080);
  fSkyGraphicsPipeline.DynamicState.AddDynamicStates([VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]);

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

  SetLength(fOffscreenColorAttachments, pvApplication.CountSwapChainImages);
  SetLength(fOffscreenDepthAttachments, pvApplication.CountSwapChainImages);
  SetLength(fOffscreenFrameBuffers, pvApplication.CountSwapChainImages);

  for Index := 0 to pvApplication.CountSwapChainImages - 1 do begin
    fOffscreenColorAttachments[Index] := TpvVulkanFrameBufferAttachment.Create(
      pvApplication.VulkanDevice,
      pvApplication.VulkanDevice.GraphicsQueue,
      fVulkanGraphicsCommandBuffer,
      fVulkanGraphicsCommandBufferFence,
      1920,
      1080,
      pvApplication.VulkanSwapChain.ImageFormat,
      TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT)
    );
    fOffscreenDepthAttachments[Index] := TpvVulkanFrameBufferAttachment.Create(
      pvApplication.VulkanDevice,
      pvApplication.VulkanDevice.GraphicsQueue,
      fVulkanGraphicsCommandBuffer,
      fVulkanGraphicsCommandBufferFence,
      1920,
      1080,
      pvApplication.VulkanDepthImageFormat,
      TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT)
    );
    fOffscreenFrameBuffers[Index] := TpvVulkanFrameBuffer.Create(
      pvApplication.VulkanDevice,
      fVulkanRenderPass,
      1920,
      1080,
      1,
      [fOffscreenColorAttachments[Index], fOffscreenDepthAttachments[Index]],
      false,
      'fOffscreenFrameBuffers[' + IntToStr(Index) + ']'
    );
    fOffscreenFrameBuffers[Index].Initialize;
  end;

end;



procedure TPasCubeScreen.BeforeDestroySwapChain;
var Index: TpvInt32;
begin
  for Index := 0 to Length(fOffscreenFrameBuffers) - 1 do begin
    FreeAndNil(fOffscreenFrameBuffers[Index]);
  end;
  fOffscreenFrameBuffers := nil;

  for Index := 0 to Length(fOffscreenColorAttachments) - 1 do begin
    FreeAndNil(fOffscreenColorAttachments[Index]);
  end;
  fOffscreenColorAttachments := nil;

  for Index := 0 to Length(fOffscreenDepthAttachments) - 1 do begin
    FreeAndNil(fOffscreenDepthAttachments[Index]);
  end;
  fOffscreenDepthAttachments := nil;

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
       if fBenchmarkPhase in [bpWarmup, bpCPU_Single, bpCPU_Multi, bpGPU_1080p] then begin
       fBenchmarkPhase := bpIdleMenu;
       fShowSkybox := true;
      result:=true;
     end else if (fBenchmarkPhase = bpResults) and fShowMethodology then begin
       fShowMethodology := false;
       result:=true;
     end else begin
      pvApplication.Terminate;
     end;
    end;
   KEYCODE_RETURN,KEYCODE_SPACE:begin
    if fBenchmarkPhase = bpIdleMenu then begin
     StartBenchmark;
     result:=true;
     end else if fBenchmarkPhase = bpResults then begin
      fBenchmarkPhase := bpIdleMenu;
      fShowSkybox := true;
     result:=true;
    end;
   end;
   KEYCODE_UP:begin
   end;
   KEYCODE_DOWN:begin
   end;
  end;
 end;
end;

function TPasCubeScreen.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Delta:TpvVector2;
    idx:Integer;
    app: TPasCubeApplication;
    charWidth, charHeight, leftColX1, leftColWidth: TpvFloat;
    histCardY, histGraphY, histGraphH, histGraphW, barSlotW: TpvFloat;
    ScaledPos: TpvVector2;
begin
 result := false;
 ScaledPos := TpvVector2.Create((aPointerEvent.Position.x / Max(1.0, pvApplication.Width)) * 1920.0,
                                (aPointerEvent.Position.y / Max(1.0, pvApplication.Height)) * 1080.0);
 case aPointerEvent.PointerEventType of
  TpvApplicationInputPointerEventType.Down:begin
   if aPointerEvent.Button=TpvApplicationInputPointerButton.Left then begin
    fMouseLeftButtonDown:=true;
    fLastMousePosition:=ScaledPos;
     if (fBenchmarkPhase = bpIdleMenu) and (IsStartButtonHovered(ScaledPos) or IsViewResultsButtonHovered(ScaledPos)) then begin
      fAutoRotation:=false;
      fDraggingCube:=false;
      result:=true;
      end else if (fBenchmarkPhase = bpResults) and fClearConfirmPending and IsClearConfirmButtonHovered(ScaledPos, idx) then begin
       fAutoRotation:=false;
       fDraggingCube:=false;
       result:=true;
       end else if (fBenchmarkPhase = bpResults) and fSubmitConfirmPending and IsSubmitConfirmButtonHovered(ScaledPos, idx) then begin
        fAutoRotation:=false;
        fDraggingCube:=false;
        result:=true;
        end else if (fBenchmarkPhase = bpResults) and IsReturnButtonHovered(ScaledPos) then begin
        fAutoRotation:=false;
        fDraggingCube:=false;
        result:=true;
       end else if (fBenchmarkPhase = bpResults) and IsSubmitButtonHovered(ScaledPos) then begin
        fAutoRotation:=false;
        fDraggingCube:=false;
        result:=true;
       end else if (fBenchmarkPhase = bpResults) and IsClearButtonHovered(ScaledPos) then begin
        fAutoRotation:=false;
        fDraggingCube:=false;
        result:=true;
        end else if (fBenchmarkPhase = bpResults) and IsHardwareItemHovered(ScaledPos, idx) then begin
        fAutoRotation:=false;
        fDraggingCube:=false;
        result:=true;
        end else if (fBenchmarkPhase = bpResults) and fShowMethodology then begin
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
    end else if (fBenchmarkPhase = bpIdleMenu) and IsStartButtonHovered(ScaledPos) then begin
     StartBenchmark;
     result:=true;
    end else if (fBenchmarkPhase = bpIdleMenu) and IsViewResultsButtonHovered(ScaledPos) then begin
     if fHistoryCount > 0 then begin
      fCurrentResult := fHistory[0];
      fBenchmarkPhase := bpResults;
      InitializeSubmitStatus;
      fShowSkybox := true;
      result:=true;
     end;
     end else if (fBenchmarkPhase = bpResults) and fClearConfirmPending and IsClearConfirmButtonHovered(ScaledPos, idx) then begin
      if idx = 1 then begin
       ClearBenchmarkResults;
      end else begin
       fClearConfirmPending := false;
       fClearConfirmHovered := 0;
      end;
      result:=true;
     end else if (fBenchmarkPhase = bpResults) and fSubmitConfirmPending and IsSubmitConfirmButtonHovered(ScaledPos, idx) then begin
      if idx = 1 then begin
       fSubmitConfirmPending := false;
       fSubmitConfirmHovered := 0;
       SubmitBenchmarkResults;
      end else begin
       fSubmitConfirmPending := false;
       fSubmitConfirmHovered := 0;
      end;
      result:=true;
     end else if (fBenchmarkPhase = bpResults) and IsReturnButtonHovered(ScaledPos) then begin
      if fClearConfirmPending then begin
       fClearConfirmPending := false;
       fClearConfirmHovered := 0;
       result:=true;
      end else if fSubmitConfirmPending then begin
       fSubmitConfirmPending := false;
       fSubmitConfirmHovered := 0;
       result:=true;
       end else begin
        fBenchmarkPhase := bpIdleMenu;
        fShowSkybox := true;
       result:=true;
      end;
     end else if (fBenchmarkPhase = bpResults) and IsSubmitButtonHovered(ScaledPos) then begin
      if (fSubmitStatus = 0) or (fSubmitStatus = 3) then begin
       fSubmitConfirmPending := true;
       fSubmitConfirmHovered := 0;
      end;
      result:=true;
     end else if (fBenchmarkPhase = bpResults) and IsClearButtonHovered(ScaledPos) then begin
      fClearConfirmPending := true;
      fClearConfirmHovered := 0;
      result:=true;
       end else if (fBenchmarkPhase = bpResults) and IsHardwareItemHovered(ScaledPos, idx) then begin
        fExpandedHardwareIdx := idx;
        result:=true;
        end;
   end;
  end;
  TpvApplicationInputPointerEventType.Motion:begin
   Delta:=ScaledPos-fLastMousePosition;
   if fMouseLeftButtonDown and fDraggingCube then begin
    fState.AnglePhases[1]:=fState.AnglePhases[1]+(Delta.x*0.005);
    fState.AnglePhases[0]:=fState.AnglePhases[0]+(Delta.y*0.005);
   end;
     fLastMousePosition:=ScaledPos;
     if fBenchmarkPhase = bpResults then begin
      if fClearConfirmPending then begin
       if IsClearConfirmButtonHovered(ScaledPos, idx) then
        fClearConfirmHovered := idx
       else
        fClearConfirmHovered := 0;
      end else if fSubmitConfirmPending then begin
       if IsSubmitConfirmButtonHovered(ScaledPos, idx) then
        fSubmitConfirmHovered := idx
       else
        fSubmitConfirmHovered := 0;
        end else begin
         fShowMethodology := IsMethodologyButtonHovered(ScaledPos);
         if IsHardwareItemHovered(ScaledPos, idx) then
          fHoveredHardwareIdx := idx
         else
          fHoveredHardwareIdx := -1;
        end;

      // Check hover on Score Trend history bars
      fHoveredHistoryIdx := -1;
      if (not fClearConfirmPending) and (not fSubmitConfirmPending) and (fHistoryCount > 0) then begin
      app := UnitPasCubeApplication.Application;
      if Assigned(app) then begin
       charWidth := app.TextOverlay.FontCharWidth;
       charHeight := app.TextOverlay.FontCharHeight;
       leftColX1 := 1920.0 * 0.05;
       leftColWidth := 1920.0 * 0.43;
       histCardY := 1.0 * charHeight + 6.5 * charHeight + 0.5 * charHeight + 5.0 * charHeight + 0.5 * charHeight + 5.0 * charHeight + 0.5 * charHeight + 5.0 * charHeight + 0.5 * charHeight;
       histGraphY := histCardY;
       histGraphH := (1.0 * charHeight + (1080.0 - 55.0 - 1.0 * charHeight - 55.0)) - histGraphY;
       if histGraphH < 6.0 * charHeight then histGraphH := 6.0 * charHeight;
       histGraphW := leftColWidth;
       if (ScaledPos.x >= leftColX1) and (ScaledPos.x <= leftColX1 + histGraphW) and
          (ScaledPos.y >= histGraphY) and (ScaledPos.y <= histGraphY + histGraphH) then begin
         barSlotW := (histGraphW - 4.0 * charWidth) / fHistoryCount;
         fHoveredHistoryIdx := Trunc((ScaledPos.x - (leftColX1 + 2.0 * charWidth)) / barSlotW);
         if fHoveredHistoryIdx < 0 then fHoveredHistoryIdx := 0;
         if fHoveredHistoryIdx >= fHistoryCount then fHoveredHistoryIdx := fHistoryCount - 1;
         // Map visual index (oldest at left) to array index (newest at 0)
         fHoveredHistoryIdx := fHistoryCount - 1 - fHoveredHistoryIdx;
        end;
      end;
     end;
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
     i: Integer;
     AProcess: TProcess;
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
    if fBenchmarkPhase in [bpWarmup, bpCPU_Single, bpCPU_Multi, bpGPU_1080p] then begin
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
     bpGPU_1080p: begin
      if fPhaseTimer >= 10.0 then NextPhase;
     end;
   end;
  end;
 
   // Limit FPS to 60 on idle menu and results screens to save GPU power
   if fBenchmarkPhase in [bpIdleMenu, bpResults] then begin
    pvApplication.MaximumFramesPerSecond := 60.0;
   end else begin
    pvApplication.MaximumFramesPerSecond := 0.0;
   end;

   // Update lights & particles if in GPU stress phase
    if fBenchmarkPhase in [bpGPU_1080p] then begin
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

    // Animate hardware comparison accordion
    if fBenchmarkPhase = bpResults then begin
      for i := 0 to 11 do begin
       if i = fExpandedHardwareIdx then begin
        if fHWExpandProgress[i] < 1.0 then
         fHWExpandProgress[i] := fHWExpandProgress[i] + (1.0 - fHWExpandProgress[i]) * Min(aDeltaTime * 12.0, 1.0);
       end else begin
        if fHWExpandProgress[i] > 0.0 then
         fHWExpandProgress[i] := fHWExpandProgress[i] - fHWExpandProgress[i] * Min(aDeltaTime * 12.0, 1.0);
       end;
      end;
      if (fSubmitStatus = 1) and Assigned(fSubmitThread) then begin
       if fSubmitThread.IsFinished then begin
        if fSubmitThread.Success then begin
         fSubmitStatus := 2;
         try
           AProcess := TProcess.Create(nil);
           try
             AProcess.Executable := 'xdg-open';
             AProcess.Parameters.Add('https://benjamimgois.github.io/PascubeDB/');
             AProcess.Options := [];
             AProcess.Execute;
           finally
             AProcess.Free;
           end;
         except
           // ignore any error opening browser
         end;
        end else begin
         fSubmitStatus := 3;
         DebugLog('Submit results failed: ' + fSubmitThread.ErrorMsg);
        end;
        FreeAndNil(fSubmitThread);
       end;
      end;
     end;

   fReady:=true;
  

   // Add overlay text during update
    case fBenchmarkPhase of
     bpIdleMenu: DrawMenuOverlay;
     bpResults: begin
       DrawResultsOverlay;
       if fShowMethodology then
         DrawMethodologyOverlay;
     end;
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
    curGPU: Double;
    gpuStressValue: TpvFloat;
    SkyParams: array[0..1] of TpvFloat;
    scaleFactor, scaleX, scaleY, scaleZ: TpvFloat;
    N, Cols, Rows, colIdx, rowIdx, ActiveCount: Integer;
    SpacingX, SpacingY, CubeScale, PosX, PosY: TpvFloat;
    CubeScaleX, CubeScaleY, CubeScaleZ, rotX, rotY: TpvFloat;
    Viewport: TVkViewport;
    Scissor: TVkRect2D;
begin
 Viewport.x := 0.0;
 Viewport.y := 0.0;
 Viewport.width := fRenderWidth;
 Viewport.height := fRenderHeight;
 Viewport.minDepth := 0.0;
 Viewport.maxDepth := 1.0;

 Scissor.offset.x := 0;
 Scissor.offset.y := 0;
 Scissor.extent.width := fRenderWidth;
 Scissor.extent.height := fRenderHeight;

 inherited Draw(aSwapChainImageIndex,aWaitSemaphore,nil);
 if assigned(fVulkanGraphicsPipeline) then begin

    isBenchmark := fBenchmarkPhase in [bpWarmup, bpCPU_Single, bpCPU_Multi, bpGPU_1080p];
    if isBenchmark then begin
      curGPU := GetGPUTemperature;
      if (curGPU > 0) and (curGPU > fCurrentResult.GPUTempMax) then fCurrentResult.GPUTempMax := curGPU;
    end;

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
   ProjectionMatrix:=TpvMatrix4x4.CreatePerspective(45.0,1920.0/1080.0,1.0,128.0);

   if isBenchmark and (fBenchmarkPhase in [bpGPU_1080p]) then begin
   // Main Cube (Instance 0)
   ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
                TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));
   ModelMatrix:=ModelMatrix*TpvMatrix4x4.CreateTranslation(Sin(fBenchmarkTimer * 1.5) * 0.8, Cos(fBenchmarkTimer * 1.0) * 0.5, 0.0);
   fUniformBuffer.Instances[0].ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
   fUniformBuffer.Instances[0].ModelViewMatrix:=ModelMatrix*ViewMatrix;
   fUniformBuffer.Instances[0].ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);

   // Orbiting Particles (Instances 1..250)
   for i:=0 to fParticleCount - 1 do begin
    ModelMatrix:=TpvMatrix4x4.CreateScale(0.18,0.18,0.18)*
                 TpvMatrix4x4.CreateTranslation(fParticlePositions[i].x,fParticlePositions[i].y,fParticlePositions[i].z);
    fUniformBuffer.Instances[i+1].ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
    fUniformBuffer.Instances[i+1].ModelViewMatrix:=ModelMatrix*ViewMatrix;
    fUniformBuffer.Instances[i+1].ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);
   end;

   // View-space positions and colors for shaders
   for i:=0 to 7 do begin
    fUniformBuffer.ParticlePositions[i]:=ViewMatrix*TpvVector4.Create(fParticlePositions[i],1.0);
    fUniformBuffer.ParticleColors[i]:=TpvVector4.Create(fParticleColors[i],1.0);
   end;

   p:=fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
   if assigned(p) then begin
    Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
   end;
  end else if isBenchmark and (fBenchmarkPhase = bpCPU_Multi) then begin
   // Handled in its own instanced drawing loop
  end else begin
   // Non-instanced single cube phases
   ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
                TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));
   if isBenchmark and (fBenchmarkPhase = bpCPU_Single) then begin
    scaleFactor:=1.0+Sin(fPhaseTimer*10.0)*0.12;
    ModelMatrix:=TpvMatrix4x4.CreateScale(scaleFactor,scaleFactor,scaleFactor)*ModelMatrix;
   end;
   fUniformBuffer.Instances[0].ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
   fUniformBuffer.Instances[0].ModelViewMatrix:=ModelMatrix*ViewMatrix;
   fUniformBuffer.Instances[0].ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);

   p:=fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
   if assigned(p) then begin
    Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
   end;
  end;

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
                                    fOffscreenFrameBuffers[aSwapChainImageIndex],
                                    VK_SUBPASS_CONTENTS_INLINE,
                                    0,
                                    0,
                                    1920,
                                    1080);

   if fShowSkybox then begin
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fSkyGraphicsPipeline.Handle);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdSetViewport(0,1,@Viewport);
    fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdSetScissor(0,1,@Scissor);
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
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdSetViewport(0,1,@Viewport);
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdSetScissor(0,1,@Scissor);
   fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                                                                                               fVulkanPipelineLayout.Handle,
                                                                                                               0,
                                                                                                               1,
                                                                                                               @fVulkanDescriptorSets[pvApplication.DrawInFlightFrameIndex].Handle,
                                                                                                               0,
                                                                                                               nil);

     if fBenchmarkPhase in [bpGPU_1080p] then
     gpuStressValue := fBenchmarkTimer
    else
     gpuStressValue := 0.0;

    // Render physics bodies instanced
    if isBenchmark and (fPhysicsWorld.BodyCount > 0) then begin
     ActiveCount := 0;
     for i := 0 to fPhysicsWorld.BodyCount - 1 do begin
      body := fPhysicsWorld.GetBody(i);
      if not Assigned(body) or not body^.Active then Continue;

      // Clamp to fit UBO Instances array limit
      if ActiveCount >= 256 then Break;

      ModelMatrix := TpvMatrix4x4.CreateScale(body^.Scale, body^.Scale, body^.Scale) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.x, TpvVector3.Create(1,0,0)) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.y, TpvVector3.Create(0,1,0)) *
                     TpvMatrix4x4.CreateRotate(body^.Rotation.z, TpvVector3.Create(0,0,1)) *
                     TpvMatrix4x4.CreateTranslation(body^.Position.x, body^.Position.y, body^.Position.z);

      fUniformBuffer.Instances[ActiveCount].ModelViewProjectionMatrix := (ModelMatrix * ViewMatrix) * ProjectionMatrix;
      fUniformBuffer.Instances[ActiveCount].ModelViewMatrix := ModelMatrix * ViewMatrix;
      fUniformBuffer.Instances[ActiveCount].ModelViewNormalMatrix := TpvMatrix4x4.Create((ModelMatrix * ViewMatrix).ToMatrix3x3.Inverse.Transpose);

      // Save color of first instance as the representative color (UBO color is uniform)
      if ActiveCount = 0 then begin
       PushConstants.Vector := TpvVector4.Create(body^.Color.x, body^.Color.y, body^.Color.z, 1.0);
      end;
      Inc(ActiveCount);
     end;

     if ActiveCount > 0 then begin
      p := fVulkanUniformBufferPointers[pvApplication.DrawInFlightFrameIndex];
      if assigned(p) then begin
       Move(fUniformBuffer, p^, SizeOf(TScreenExampleCubeUniformBuffer));
      end;

      PushConstants.Params := TpvVector4.Create(1.4, 0.7, 24.0, gpuStressValue);
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
       fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
       0, SizeOf(TpvVector4)*2, @PushConstants);
      fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount, ActiveCount, 0, 0, 0);
     end;
    end;

      // Render particles (GPU particle phase)
       if isBenchmark and (fParticleCount > 0) and (fBenchmarkPhase in [bpGPU_1080p]) then begin
       // 8 Orbiting lights
       for i := 0 to 7 do begin
        PushConstants.Vector := TpvVector4.Create(fParticleColors[i].x, fParticleColors[i].y, fParticleColors[i].z, 0.85);
         PushConstants.Params := TpvVector4.Create(1.2, 0.5, 16.0, gpuStressValue);
        fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
         fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
         0, SizeOf(TpvVector4)*2, @PushConstants);
        fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount, 1, 0, 0, i + 1);
       end;
       
       // Standard background particles
       if fParticleCount > 8 then begin
        PushConstants.Vector := TpvVector4.Create(0.0, 0.7, 0.9, 0.45);
         PushConstants.Params := TpvVector4.Create(1.0, 0.3, 12.0, gpuStressValue);
        fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdPushConstants(
         fVulkanPipelineLayout.Handle, TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
         0, SizeOf(TpvVector4)*2, @PushConstants);
        fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex].CmdDrawIndexed(fCubeIndexCount, fParticleCount - 8, 0, 0, 9);
       end;
      end;

     // Default cube (idle menu / warmup / CPU single / GPU stress phases)
      if (not isBenchmark) or (fBenchmarkPhase in [bpWarmup, bpCPU_Single, bpGPU_1080p]) then begin
      if isBenchmark then begin
        if fBenchmarkPhase = bpCPU_Single then begin
          PushConstants.Vector := TpvVector4.Create(1.0, 0.45 + 0.1 * Sin(fPhaseTimer * 8.0), 0.0, 1.0);
          PushConstants.Params := TpvVector4.Create(0.85, 0.7, 24.0, 0.0);
         end else if fBenchmarkPhase in [bpGPU_1080p] then begin
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
   path := GetLogFilePath('pascube_debug.log');
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
   bpGPU_1080p: Result := 10.0;
   else Result := 0.0;
 end;
end;

function TPasCubeScreen.GetPhaseName: String;
begin
 case fBenchmarkPhase of
  bpIdleMenu: Result := 'Menu';
  bpWarmup: Result := 'Warmup';
  bpCPU_Single: Result := 'CPU Single-Thread';
  bpCPU_Multi: Result := 'CPU Multi-Thread (' + IntToStr(pvApplication.CountCPUThreads) + ')';
   bpGPU_1080p: Result := 'GPU Stress at 1080p (Run ' + IntToStr(fGPUIteration + 1) + '/3)';
  bpResults: Result := 'Results';
  else Result := 'Unknown';
 end;
end;

function TPasCubeScreen.GetPhaseObjectCount: Integer;
begin
 Result := 1;
end;

function GetGoverlayConfigFilePath: string;
var
  HomeDir, ConfigPath: string;
begin
  HomeDir := GetEnvironmentVariable('HOME');
  if HomeDir = '' then HomeDir := '/tmp';
  ConfigPath := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigPath = '' then
    ConfigPath := HomeDir + '/.config';
  Result := IncludeTrailingPathDelimiter(ConfigPath + '/goverlay') + 'goverlay.conf';
end;

function ReadPasCubeNickname(out APrompted: Boolean): string;
var
  ConfigPath: string;
  SL: TStringList;
  i, p: Integer;
  Line, Key, Val: string;
  InUser: Boolean;
begin
  Result := '';
  APrompted := False;
  ConfigPath := GetGoverlayConfigFilePath;
  if FileExists(ConfigPath) then begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(ConfigPath);
      InUser := False;
      for i := 0 to SL.Count - 1 do begin
        Line := Trim(SL[i]);
        if (Line <> '') and (Line[1] = '[') then begin
          if InUser then Break;
          InUser := SameText(Line, '[User]');
        end else if InUser then begin
          p := Pos('=', Line);
          if p > 0 then begin
            Key := Trim(Copy(Line, 1, p - 1));
            Val := Trim(Copy(Line, p + 1, MaxInt));
            if SameText(Key, 'Nickname') then Result := Val;
            if SameText(Key, 'NicknamePrompted') then APrompted := (Val = '1') or SameText(Val, 'True');
          end;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure SavePasCubeNickname(const ANickname: string; APrompted: Boolean);
var
  ConfigPath, Dir: string;
  SL: TStringList;
  i, p, UserSectionIdx: Integer;
  Line, Key: string;
  InUser, FoundNick, FoundPrompted: Boolean;
begin
  ConfigPath := GetGoverlayConfigFilePath;
  Dir := ExtractFilePath(ConfigPath);
  if not DirectoryExists(Dir) then ForceDirectories(Dir);
  SL := TStringList.Create;
  try
    if FileExists(ConfigPath) then SL.LoadFromFile(ConfigPath);
    InUser := False;
    FoundNick := False;
    FoundPrompted := False;
    UserSectionIdx := -1;
    i := 0;
    while i < SL.Count do begin
      Line := Trim(SL[i]);
      if (Line <> '') and (Line[1] = '[') then begin
        if InUser then Break;
        InUser := SameText(Line, '[User]');
        if InUser then UserSectionIdx := i;
      end else if InUser then begin
        p := Pos('=', Line);
        if p > 0 then begin
          Key := Trim(Copy(Line, 1, p - 1));
          if SameText(Key, 'Nickname') then begin
            SL[i] := 'Nickname=' + ANickname;
            FoundNick := True;
          end else if SameText(Key, 'NicknamePrompted') then begin
            if APrompted then SL[i] := 'NicknamePrompted=1' else SL[i] := 'NicknamePrompted=0';
            FoundPrompted := True;
          end;
        end;
      end;
      Inc(i);
    end;

    if UserSectionIdx = -1 then begin
      SL.Add('[User]');
      SL.Add('Nickname=' + ANickname);
      if APrompted then SL.Add('NicknamePrompted=1') else SL.Add('NicknamePrompted=0');
    end else begin
      if not FoundNick then SL.Insert(UserSectionIdx + 1, 'Nickname=' + ANickname);
      if not FoundPrompted then SL.Insert(UserSectionIdx + 2, 'NicknamePrompted=1');
    end;
    SL.SaveToFile(ConfigPath);
  finally
    SL.Free;
  end;
end;

procedure EnsurePasCubeNicknamePrompted;
var
  Prompted: Boolean;
  CurrentNick, TmpFile: string;
  Proc: TProcess;
  SL: TStringList;
begin
  CurrentNick := ReadPasCubeNickname(Prompted);
  if not Prompted then begin
    TmpFile := GetTempDir + 'pascube_nick_' + IntToStr(GetProcessID) + '.txt';
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'sh';
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('if command -v zenity >/dev/null 2>&1; then ' +
        'zenity --entry --title="Leaderboard Nickname (Optional)" --text="Enter an optional display nickname for benchmark uploads.\nLeaving this field blank keeps your submission anonymous." --entry-text="' + CurrentNick + '" > ' + TmpFile + ' 2>/dev/null; ' +
        'elif command -v kdialog >/dev/null 2>&1; then ' +
        'kdialog --title "Leaderboard Nickname (Optional)" --inputbox "Enter an optional display nickname for benchmark uploads.\nLeaving this field blank keeps your submission anonymous." "' + CurrentNick + '" > ' + TmpFile + ' 2>/dev/null; ' +
        'fi');
      Proc.Options := [poWaitOnExit];
      try Proc.Execute; except end;
    finally
      Proc.Free;
    end;

    if FileExists(TmpFile) then begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile(TmpFile);
        if SL.Count > 0 then CurrentNick := Trim(SL[0]);
      finally
        SL.Free;
        DeleteFile(TmpFile);
      end;
    end;
    SavePasCubeNickname(CurrentNick, True);
  end;
end;

procedure TPasCubeScreen.StartBenchmark;
begin
  EnsurePasCubeNicknamePrompted;
  if Assigned(fDebugLog) then fDebugLog.Clear;
  DebugLog('=== START BENCHMARK ===');
  DebugLog(Format('Resolution=Multi Device=%s', [pvApplication.VulkanDevice.PhysicalDevice.DeviceName]));
  fBenchmarkPhase := bpWarmup;
  fBenchmarkTimer := 0.0;
  fPhaseTimer := 0.0;
  fPhaseResultIndex := -1;
  fGPUIteration := 0;
  fShowSkybox := false;
  if Assigned(f7ZipThread) then begin
    f7ZipThread.Free;
    f7ZipThread := nil;
  end;
  fPhysicsWorld.Clear;
  FillChar(fCurrentResult,SizeOf(fCurrentResult),#0);
  fCurrentResult.Timestamp := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now);
  fCurrentResult.Resolution := 'Multi';
  fCurrentResult.DeviceName := pvApplication.VulkanDevice.PhysicalDevice.DeviceName;
   fCurrentResult.VulkanAPI := Format('%d.%d.%d', [
    pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 22,
    (pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion shr 12) and $3ff,
    pvApplication.VulkanDevice.PhysicalDevice.Properties.apiVersion and $fff
   ]);
   fCurrentResult.KernelVersion := GetKernelVersion;
   fCurrentResult.DriverVersion := GetDriverVersion;
   fCurrentResult.DisplayServer := GetDisplayServer;
   GetDisplayResolutionAndRefresh(fCurrentResult.DisplayResolution, fCurrentResult.RefreshRate);
   fCurrentResult.DesktopEnvironment := GetDesktopEnvironment;
   fCurrentResult.StorageType := GetStorageType;
   fCurrentResult.VulkanDriver := GetVulkanDriver;
   fCurrentResult.CPUTempStart := GetCPUTemperature;
   fCurrentResult.GPUTempStart := GetGPUTemperature;
   fCurrentResult.CPUTempMax := fCurrentResult.CPUTempStart;
   fCurrentResult.GPUTempMax := fCurrentResult.GPUTempStart;
   fCurrentResult.CPUMaxFreq := GetCPUMaxFreq;
   fCurrentResult.GPUMaxFreq := GetGPUMaxFreq;
   InitParticles;
   fRenderWidth := 1920;
   fRenderHeight := 1080;
   fGPU360pFallback := false;
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
  if fBenchmarkPhase = bpGPU_1080p then begin
   if (fFrameCount > 0) and (fPhaseFrameTimeSum > 0.0) then begin
    fpsAvg := fFrameCount / fPhaseFrameTimeSum;
    ftAvg := (fPhaseFrameTimeSum / fFrameCount) * 1000.0;
   end else begin
    fpsAvg := 0.0;
    ftAvg := 0.0;
   end;

   // Store iteration results
   fGPURuns[fGPUIteration].FPSAvg := fpsAvg;
   fGPURuns[fGPUIteration].FPSMin := fPhaseFPSMin;
   fGPURuns[fGPUIteration].FPSMax := fPhaseFPSMax;
   fGPURuns[fGPUIteration].FrameTimeMs := ftAvg;

   if (fGPUIteration = 0) and (not fGPU360pFallback) and (fpsAvg < 5.0) then begin
     fGPU360pFallback := true;
     fRenderWidth := 640;
     fRenderHeight := 360;
     fPhaseTimer := 0.0;
     ResetCounters;
     DebugLog(Format('NextPhase: Low GPU FPS detected (%.2f). Fallback to 360p.', [fpsAvg]));
     Exit;
   end;

   if fGPUIteration < 2 then begin
     Inc(fGPUIteration);
     DebugLog('NextPhase: bpGPU_1080p iteration ' + IntToStr(fGPUIteration + 1) + ' of 3.');
     fPhaseTimer := 0.0;
     ResetCounters;
     Exit;
   end;

   // 3 iterations completed, compute average
   fpsAvg := (fGPURuns[0].FPSAvg + fGPURuns[1].FPSAvg + fGPURuns[2].FPSAvg) / 3.0;
   ftAvg := (fGPURuns[0].FrameTimeMs + fGPURuns[1].FrameTimeMs + fGPURuns[2].FrameTimeMs) / 3.0;
   fPhaseFPSMin := (fGPURuns[0].FPSMin + fGPURuns[1].FPSMin + fGPURuns[2].FPSMin) / 3.0;
   fPhaseFPSMax := (fGPURuns[0].FPSMax + fGPURuns[1].FPSMax + fGPURuns[2].FPSMax) / 3.0;
  end;

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
    end else if fBenchmarkPhase in [bpGPU_1080p] then begin
      fCurrentResult.PhaseResults[fPhaseResultIndex].Score := Round(fpsAvg * 25.0);
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
      DebugLog('NextPhase: bpCPU_Multi -> bpGPU_1080p. Initializing particles.');
      fBenchmarkPhase := bpGPU_1080p;
      fPhaseResultIndex := 3;
      fResolutionOption := ro1080p;
      fGPUIteration := 0;
      InitParticles;
     end;
      bpGPU_1080p: begin
       DebugLog('NextPhase: bpGPU_1080p -> bpResults. Completing benchmark.');
       if fGPU360pFallback then
       begin
         fRenderWidth := 1920;
         fRenderHeight := 1080;
         DebugLog('Restored render resolution from 360p to 1080p for results screen.');
       end;
       fBenchmarkPhase := bpResults;
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
var cpuSTPoints, cpuMTPoints: Integer;
    gpu1080Points, gpuAvgPoints: Integer;
    gpuAvgFPS: TpvDouble;
begin
  if fGPU360pFallback then begin
    fCurrentResult.PhaseResults[3].Score := Round(fCurrentResult.PhaseResults[3].Score / 5.0);
    fCurrentResult.PhaseResults[3].FPSAvg := fCurrentResult.PhaseResults[3].FPSAvg / 5.0;
    fCurrentResult.PhaseResults[3].FPSMin := fCurrentResult.PhaseResults[3].FPSMin / 5.0;
    fCurrentResult.PhaseResults[3].FPSMax := fCurrentResult.PhaseResults[3].FPSMax / 5.0;
    fCurrentResult.PhaseResults[3].FrameTimeMs := fCurrentResult.PhaseResults[3].FrameTimeMs * 5.0;
  end;

  cpuSTPoints := Round(fCurrentResult.PhaseResults[1].Score / 3.0);
  cpuMTPoints := Round(fCurrentResult.PhaseResults[2].Score / 20.0);

  gpu1080Points := fCurrentResult.PhaseResults[3].Score;

  if cpuSTPoints < 1 then cpuSTPoints := 1;
  if cpuMTPoints < 1 then cpuMTPoints := 1;
  if gpu1080Points < 1 then gpu1080Points := 1;

  // Save normalized points in Score for display in the grid
  fCurrentResult.PhaseResults[1].Score := cpuSTPoints;
  fCurrentResult.PhaseResults[2].Score := cpuMTPoints;
  fCurrentResult.PhaseResults[3].Score := gpu1080Points;

  gpuAvgPoints := gpu1080Points;
  if gpuAvgPoints < 1 then gpuAvgPoints := 1;

  gpuAvgFPS := fCurrentResult.PhaseResults[3].FPSAvg;

  // Populate PhaseResults[7] as the main GPU Vulkan Render phase for GOverlay compatibility
  fCurrentResult.PhaseResults[7].PhaseName := 'GPU Vulkan Render';
  fCurrentResult.PhaseResults[7].Score := gpuAvgPoints;
  fCurrentResult.PhaseResults[7].FPSAvg := gpuAvgFPS;
  fCurrentResult.PhaseResults[7].FPSMin := fCurrentResult.PhaseResults[3].FPSMin;
  fCurrentResult.PhaseResults[7].FPSMax := fCurrentResult.PhaseResults[3].FPSMax;
  fCurrentResult.PhaseResults[7].FrameTimeMs := fCurrentResult.PhaseResults[3].FrameTimeMs;
  fCurrentResult.PhaseResults[7].ObjectsRendered := 1;
  fCurrentResult.PhaseResults[7].LightsActive := 8;
  fCurrentResult.PhaseResults[7].ParticlesActive := fParticleCount;
  fCurrentResult.PhaseResults[7].PhysicsBodies := 0;

  // Calculate weighted global gaming score: 35% CPU ST + 15% CPU MT + 50% GPU average
   fCurrentResult.TotalScore := Round((0.35 * cpuSTPoints) + (0.15 * cpuMTPoints) + (0.50 * gpuAvgPoints));
  if fCurrentResult.TotalScore < 1 then fCurrentResult.TotalScore := 1;
end;

procedure TPasCubeScreen.FinishBenchmark;
var i: Integer;
begin
 fCurrentResult.BenchmarkDuration := fBenchmarkTimer;
 if (fCurrentResult.CPUTempStart > 0) and (fCurrentResult.CPUTempMax >= fCurrentResult.CPUTempStart) then
   fCurrentResult.CPUTempDelta := fCurrentResult.CPUTempMax - fCurrentResult.CPUTempStart
 else
   fCurrentResult.CPUTempDelta := -1.0;
 if (fCurrentResult.GPUTempStart > 0) and (fCurrentResult.GPUTempMax >= fCurrentResult.GPUTempStart) then
   fCurrentResult.GPUTempDelta := fCurrentResult.GPUTempMax - fCurrentResult.GPUTempStart
 else
   fCurrentResult.GPUTempDelta := -1.0;
 DebugLog(Format('FinishBenchmark: totalScore=%d', [fCurrentResult.TotalScore]));
 if fCurrentResult.TotalScore > fBestScore then fBestScore := fCurrentResult.TotalScore;
 fLastScore := fCurrentResult.TotalScore;
 for i := MAX_BENCHMARK_HISTORY-1 downto 1 do
  fHistory[i] := fHistory[i-1];
 fHistory[0] := fCurrentResult;
 if fHistoryCount < MAX_BENCHMARK_HISTORY then Inc(fHistoryCount);
 SaveResultsJSON;
 SaveDebugLog;
 InitializeSubmitStatus;
 fBenchmarkPhase := bpResults;
 fShowSkybox := true;
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
    json := json + ' "kernel": "' + fHistory[i].KernelVersion + '",';
    json := json + ' "driver": "' + fHistory[i].DriverVersion + '",';
    json := json + ' "display_server": "' + fHistory[i].DisplayServer + '",';
    json := json + ' "display_resolution": "' + fHistory[i].DisplayResolution + '",';
    json := json + ' "refresh_rate": "' + fHistory[i].RefreshRate + '",';
    json := json + ' "desktop": "' + fHistory[i].DesktopEnvironment + '",';
    json := json + ' "desktop_environment": "' + fHistory[i].DesktopEnvironment + '",';
    json := json + ' "storage_type": "' + fHistory[i].StorageType + '",';
    json := json + ' "vulkan_driver": "' + fHistory[i].VulkanDriver + '",';
    json := json + ' "cpu_temp_start": ' + FloatToJsonStr(fHistory[i].CPUTempStart) + ',';
    json := json + ' "cpu_temp_max": ' + FloatToJsonStr(fHistory[i].CPUTempMax) + ',';
    json := json + ' "cpu_temp_delta": ' + FloatToJsonStr(fHistory[i].CPUTempDelta) + ',';
    json := json + ' "gpu_temp_start": ' + FloatToJsonStr(fHistory[i].GPUTempStart) + ',';
    json := json + ' "gpu_temp_max": ' + FloatToJsonStr(fHistory[i].GPUTempMax) + ',';
    json := json + ' "gpu_temp_delta": ' + FloatToJsonStr(fHistory[i].GPUTempDelta) + ',';
    json := json + ' "cpu_max_freq": ' + IntToStr(fHistory[i].CPUMaxFreq) + ',';
    json := json + ' "gpu_max_freq": ' + IntToStr(fHistory[i].GPUMaxFreq) + ',';
    json := json + ' "total_score": ' + IntToStr(fHistory[i].TotalScore) + ',';
    json := json + ' "duration": ' + FormatFloat('0.0', fHistory[i].BenchmarkDuration) + ',';
   json := json + ' "phases": [';
   for j := 0 to 8 do begin
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
    if j < 8 then json := json + ',';
   end;
   json := json + ']}';
   if i < fHistoryCount - 1 then json := json + ',';
   SL.Add(json);
  end;
  SL.Add('  ]');
  SL.Add('}');
  try
   SL.SaveToFile(GetBenchmarkResultsFilePath);
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

 filePath := GetBenchmarkResultsFilePath;
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
          fHistory[i].KernelVersion := HistoryObj.Get('kernel', '');
          fHistory[i].DriverVersion := HistoryObj.Get('driver', '');
          fHistory[i].DisplayServer := HistoryObj.Get('display_server', 'N/D');
          fHistory[i].DisplayResolution := HistoryObj.Get('display_resolution', 'N/D');
          fHistory[i].RefreshRate := HistoryObj.Get('refresh_rate', 'N/D');
          fHistory[i].DesktopEnvironment := HistoryObj.Get('desktop_environment', 'N/D');
          fHistory[i].StorageType := HistoryObj.Get('storage_type', 'N/D');
          fHistory[i].VulkanDriver := HistoryObj.Get('vulkan_driver', 'N/D');
          fHistory[i].CPUTempStart := HistoryObj.Get('cpu_temp_start', -1.0);
          fHistory[i].CPUTempMax := HistoryObj.Get('cpu_temp_max', -1.0);
          fHistory[i].CPUTempDelta := HistoryObj.Get('cpu_temp_delta', -1.0);
          fHistory[i].GPUTempStart := HistoryObj.Get('gpu_temp_start', -1.0);
          fHistory[i].GPUTempMax := HistoryObj.Get('gpu_temp_max', -1.0);
          fHistory[i].GPUTempDelta := HistoryObj.Get('gpu_temp_delta', -1.0);
          fHistory[i].CPUMaxFreq := HistoryObj.Get('cpu_max_freq', 0);
          fHistory[i].GPUMaxFreq := HistoryObj.Get('gpu_max_freq', 0);
          fHistory[i].TotalScore := HistoryObj.Get('total_score', 0);
          fHistory[i].BenchmarkDuration := HistoryObj.Get('duration', 0.0);
         
         PhasesArr := TJSONArray(HistoryObj.FindPath('phases'));
         if Assigned(PhasesArr) then begin
          for j := 0 to Min(PhasesArr.Count, 9) - 1 do begin
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
begin
 fParticleCount := 8;
 fParticleColors[0] := TpvVector3.Create(1.0, 0.05, 0.05); // Red
 fParticleColors[1] := TpvVector3.Create(0.05, 1.0, 0.05); // Green
 fParticleColors[2] := TpvVector3.Create(0.1, 0.3, 1.0);   // Blue
 fParticleColors[3] := TpvVector3.Create(1.0, 0.9, 0.05);  // Yellow
 fParticleColors[4] := TpvVector3.Create(1.0, 0.05, 1.0);  // Magenta
 fParticleColors[5] := TpvVector3.Create(1.0, 0.5, 0.05);  // Orange
 fParticleColors[6] := TpvVector3.Create(0.5, 0.05, 1.0);  // Purple
 fParticleColors[7] := TpvVector3.Create(1.0, 1.0, 1.0);   // White
 
 // Initialize positions for the first 8 orbiting particles
 for i := 0 to 7 do begin
  fParticlePositions[i] := TpvVector3.Create(1.5 + i * 0.25, 0.0, 0.0);
 end;
 
 UpdateParticles(0.0);
 DebugLog('InitParticles: Initialized 8 orbiting particles');
end;

procedure TPasCubeScreen.UpdateParticles(const aDeltaTime: TpvDouble);
var i: Integer;
    angle, radius, speed: TpvFloat;
begin
 for i := 0 to 7 do begin
  radius := 1.5 + i * 0.25;
  speed := 0.8 + i * 0.15;
  angle := fBenchmarkTimer * speed + (i * (TwoPI / 8.0));
  
  if (i mod 3) = 0 then begin
    fParticlePositions[i].x := radius * Cos(angle);
    fParticlePositions[i].y := radius * Sin(angle);
    fParticlePositions[i].z := radius * Sin(angle * 0.5) * 0.3;
  end else if (i mod 3) = 1 then begin
    fParticlePositions[i].x := radius * Cos(angle);
    fParticlePositions[i].y := radius * Sin(angle * 0.5) * 0.3;
    fParticlePositions[i].z := radius * Sin(angle);
  end else begin
    fParticlePositions[i].x := radius * Cos(angle * 0.5) * 0.3;
    fParticlePositions[i].y := radius * Cos(angle);
    fParticlePositions[i].z := radius * Sin(angle);
  end;
 end;
end;

procedure TPasCubeScreen.DrawMenuOverlay;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, paddingX, paddingY: TpvFloat;
    isStartHovered, isViewHovered: Boolean;
    bgR, bgG, bgB, bgA: TpvFloat;
    fgR, fgG, fgB, fgA: TpvFloat;
    textR, textG, textB, textA: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 cx := 1920.0 * 0.5;
 yText := 1080.0 - 110.0;

 charWidth := app.TextOverlay.FontCharWidth;
 charHeight := app.TextOverlay.FontCharHeight;

 paddingX := charWidth * 1.5;
 paddingY := charHeight * 0.4;

 btnWidth := (15.0 * charWidth * 1.8) + (2.0 * paddingX);
 btnHeight := (charHeight * 1.8) + (2.0 * paddingY);

 // Centered Title (Increased font size to 3.0, using default font)
 app.TextOverlay.AddText(cx, 80.0, 3.0, toaCenter, 'PasCube Benchmark');

 // 1. Start benchmark button
 isStartHovered := IsStartButtonHovered(fLastMousePosition);
 if isStartHovered then begin
  bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
  fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
  textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
 end else begin
  bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
  fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
  textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
 end;

 if fHistoryCount > 0 then
  btnX := cx - btnWidth - 15.0
 else
  btnX := cx - (btnWidth * 0.5);

 app.TextOverlay.AddBox(btnX, yText - paddingY, btnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
 
 if fHistoryCount > 0 then
  app.TextOverlay.AddText(cx - (btnWidth * 0.5) - 15.0, yText, 1.8, toaCenter, 'Start benchmark', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA)
 else
  app.TextOverlay.AddText(cx, yText, 1.8, toaCenter, 'Start benchmark', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

 // 2. View results button (only if history exists)
 if fHistoryCount > 0 then begin
  isViewHovered := IsViewResultsButtonHovered(fLastMousePosition);
  if isViewHovered then begin
   bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
   fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
   textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
  end else begin
   bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
   fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
   textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
  end;

  btnX := cx + 15.0;
  app.TextOverlay.AddBox(btnX, yText - paddingY, btnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
  app.TextOverlay.AddText(cx + (btnWidth * 0.5) + 15.0, yText, 1.8, toaCenter, 'View results', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
 end;
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

  cx := 1920.0 * 0.5;
  yText := 1080.0 - 110.0;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;

  btnWidth := (15.0 * charWidth * 1.8) + (2.0 * paddingX);
  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
  
  if fHistoryCount > 0 then
    btnX := cx - btnWidth - 15.0
  else
    btnX := cx - (btnWidth * 0.5);
    
  btnY := yText - paddingY;

  Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
            (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

function TPasCubeScreen.IsViewResultsButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
begin
  Result := false;
  if fBenchmarkPhase <> bpIdleMenu then Exit;
  if fHistoryCount = 0 then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  cx := 1920.0 * 0.5;
  yText := 1080.0 - 110.0;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;

  btnWidth := (15.0 * charWidth * 1.8) + (2.0 * paddingX);
  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
  
  btnX := cx + 15.0;
  btnY := yText - paddingY;

  Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
            (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

function TPasCubeScreen.IsReturnButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
    submitBtnWidth, clearBtnWidth, gap, groupWidth, groupX: TpvFloat;
begin
 Result := false;
 if fBenchmarkPhase <> bpResults then Exit;
 if fClearConfirmPending or fSubmitConfirmPending then Exit;
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 cx := 1920.0 * 0.5;
 yText := 1080.0 - 55.0;
 charWidth := app.TextOverlay.FontCharWidth;
 charHeight := app.TextOverlay.FontCharHeight;
 paddingX := charWidth * 1.5;
 paddingY := charHeight * 0.4;
 btnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
 clearBtnWidth := (14.0 * charWidth * 1.6) + (2.0 * paddingX);
 gap := 4.0 * charWidth;
 
 if fSubmitStatus = 4 then begin
  groupWidth := btnWidth + gap + clearBtnWidth;
 end else begin
  submitBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
  groupWidth := btnWidth + gap + submitBtnWidth + gap + clearBtnWidth;
 end;
 
 groupX := cx - (groupWidth * 0.5);
 btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
 btnX := groupX;
 btnY := yText - paddingY;
 Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
           (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

function TPasCubeScreen.IsHardwareItemHovered(const aPos: TpvVector2; out aIndex: Integer): Boolean;
var app: TPasCubeApplication;
    cx, rightColX1, rightColWidth, cardY: TpvFloat;
    charWidth, charHeight: TpvFloat;
    i, j: Integer;
    itemY, itemH: TpvFloat;
    HWRefs: array[0..11] of THardwareRef;
    TempHW: THardwareRef;
begin
  Result := false;
  aIndex := -1;
  if fBenchmarkPhase <> bpResults then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;
  cx := 1920.0 * 0.5;
  rightColX1 := 1920.0 * 0.52;
  rightColWidth := 1920.0 * 0.43;
   cardY := 1.0 * charHeight;  // Must match hwCardY in DrawResultsOverlay

   // Reconstruct and sort hardware references (same as DrawResultsOverlay)
   HWRefs[0].Name := 'Raspberry Pi 5'; HWRefs[0].Score := 400; HWRefs[0].IsCurrent := false;
   HWRefs[0].Specs := 'CPU: BCM2712 4C | RAM: 8GB LPDDR4X | GPU: VideoCore VII | OS: Raspberry Pi OS';
    HWRefs[1].Name := 'Steam Machine'; HWRefs[1].Score := 1700; HWRefs[1].IsCurrent := false;
    HWRefs[1].Specs := 'CPU: AMD Zen 4 6C/12T 4.8GHz | RAM: 16GB DDR5 | GPU: AMD RDNA3 28CU 8GB GDDR6 2.45GHz | OS: SteamOS';
   HWRefs[2].Name := 'Nintendo Switch 2'; HWRefs[2].Score := 750; HWRefs[2].IsCurrent := false;
   HWRefs[2].Specs := 'CPU: Cortex-A78C 8C | RAM: 12GB LPDDR5X | GPU: Ampere 768 | OS: Horizon';
   HWRefs[3].Name := 'Steam Deck'; HWRefs[3].Score := 808; HWRefs[3].IsCurrent := false;
   HWRefs[3].Specs := 'CPU: Zen 2 4C/8T | RAM: 16GB LPDDR5 | GPU: RDNA2 8CU | OS: SteamOS';
   HWRefs[4].Name := 'ROG Ally X'; HWRefs[4].Score := 1300; HWRefs[4].IsCurrent := false;
   HWRefs[4].Specs := 'CPU: Z1 Extreme | RAM: 24GB LPDDR5X | GPU: RDNA3 12CU | OS: Win11';
   HWRefs[5].Name := 'Entry Gamer PC'; HWRefs[5].Score := 1500; HWRefs[5].IsCurrent := false;
   HWRefs[5].Specs := 'CPU: i3 12100F | RAM: 16GB DDR4 | GPU: RX 6600 8GB | OS: Win11';
   HWRefs[6].Name := 'PlayStation 5';     HWRefs[6].Score := 1800; HWRefs[6].IsCurrent := false;
   HWRefs[6].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 36CU | OS: Custom OS';
   HWRefs[7].Name := 'XBOX Series X';     HWRefs[7].Score := 2000; HWRefs[7].IsCurrent := false;
   HWRefs[7].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 52CU | OS: Custom OS';
   HWRefs[8].Name := 'PlayStation 5 Pro';     HWRefs[8].Score := 2700; HWRefs[8].IsCurrent := false;
   HWRefs[8].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA3 60CU | OS: Custom OS';
   HWRefs[9].Name := 'Mid-Range Gamer PC';     HWRefs[9].Score := 3000; HWRefs[9].IsCurrent := false;
   HWRefs[9].Specs := 'CPU: R5 7600 | RAM: 32GB DDR5 | GPU: RTX 4060 Ti | OS: Win11';
   HWRefs[10].Name := 'High-End Gamer PC';     HWRefs[10].Score := 8062; HWRefs[10].IsCurrent := false;
   HWRefs[10].Specs := 'CPU: R9 9950X3D | RAM: 48GB DDR5 | GPU: RTX 5090 | OS: CachyOS';
   HWRefs[11].Name := 'Current System'; HWRefs[11].Score := fCurrentResult.TotalScore; HWRefs[11].IsCurrent := true;
   HWRefs[11].Specs := 'CPU: ' + GetCPUName + ' | RAM: ' + GetRAMSize + ' | GPU: ' + CleanGPUName(fCurrentResult.DeviceName) + ' | OS: ' + GetOSName;

   for i := 0 to 10 do begin
    for j := i + 1 to 11 do begin
     if HWRefs[i].Score < HWRefs[j].Score then begin
      TempHW := HWRefs[i];
      HWRefs[i] := HWRefs[j];
      HWRefs[j] := TempHW;
     end;
    end;
   end;

    // Determine which item is hovered using animated Y layout
    itemY := cardY + 2.8 * charHeight;
    for i := 0 to 11 do begin
     itemH := 2.6 * charHeight + 1.6 * charHeight * fHWExpandProgress[i];

     if (aPos.x >= rightColX1) and (aPos.x <= rightColX1 + rightColWidth) and
        (aPos.y >= itemY) and (aPos.y <= itemY + itemH) then begin
      aIndex := i;
      Result := true;
      Exit;
     end;
     itemY := itemY + itemH;
    end;
  end;

function TPasCubeScreen.IsClearButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
    returnBtnWidth, submitBtnWidth, gap, groupWidth, groupX: TpvFloat;
begin
  Result := false;
  if fBenchmarkPhase <> bpResults then Exit;
  if fClearConfirmPending or fSubmitConfirmPending then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  cx := 1920.0 * 0.5;
  yText := 1080.0 - 55.0;
  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;
  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;

  returnBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
  btnWidth := (14.0 * charWidth * 1.6) + (2.0 * paddingX);
  gap := 4.0 * charWidth;

  if fSubmitStatus = 4 then begin
    groupWidth := returnBtnWidth + gap + btnWidth;
    groupX := cx - (groupWidth * 0.5);
    btnX := groupX + returnBtnWidth + gap;
  end else begin
    submitBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
    groupWidth := returnBtnWidth + gap + submitBtnWidth + gap + btnWidth;
    groupX := cx - (groupWidth * 0.5);
    btnX := groupX + returnBtnWidth + gap + submitBtnWidth + gap;
  end;

  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
  btnY := yText - paddingY;

  Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
            (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

function TPasCubeScreen.IsSubmitButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    cx, yText, charWidth, charHeight: TpvFloat;
    btnWidth, btnHeight, btnX, btnY, paddingX, paddingY: TpvFloat;
    returnBtnWidth, clearBtnWidth, gap, groupWidth, groupX: TpvFloat;
begin
 Result := false;
 if fBenchmarkPhase <> bpResults then Exit;
 if fSubmitStatus = 4 then Exit;
 if fClearConfirmPending or fSubmitConfirmPending then Exit;
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

 cx := 1920.0 * 0.5;
 yText := 1080.0 - 55.0;
 charWidth := app.TextOverlay.FontCharWidth;
 charHeight := app.TextOverlay.FontCharHeight;
 paddingX := charWidth * 1.5;
 paddingY := charHeight * 0.4;
 returnBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
 btnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
 clearBtnWidth := (14.0 * charWidth * 1.6) + (2.0 * paddingX);
 gap := 4.0 * charWidth;
 groupWidth := returnBtnWidth + gap + btnWidth + gap + clearBtnWidth;
 groupX := cx - (groupWidth * 0.5);
 btnHeight := (charHeight * 1.8) + (2.0 * paddingY);
 btnX := groupX + returnBtnWidth + gap;
 btnY := yText - paddingY;
 Result := (aPos.x >= btnX) and (aPos.x <= btnX + btnWidth) and
           (aPos.y >= btnY) and (aPos.y <= btnY + btnHeight);
end;

function TPasCubeScreen.GetSubmitURL: string;
var HomeDir: string;
    ConfigPath: string;
    SL: TStringList;
    CurrentDefaultURL: string;
    ExistingURL: string;
begin
  Result := GetEnvironmentVariable('PASCUBE_SUBMIT_URL');
  if Result <> '' then Exit;
  
  HomeDir := GetEnvironmentVariable('HOME');
  if HomeDir = '' then HomeDir := '/tmp';
  ConfigPath := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigPath = '' then
    ConfigPath := HomeDir + '/.config';
  
  ConfigPath := ConfigPath + '/goverlay/pascube_submit_url';
  CurrentDefaultURL := 'https://script.google.com/macros/s/AKfycby-RLks53RC_zdQmOTx8OOaFATZRhAQy3a30vg03gbcpBCJG_rmAC4U9wlzAIk07XA04w/exec';

  ExistingURL := '';
  if FileExists(ConfigPath) then begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(ConfigPath);
      if SL.Count > 0 then
        ExistingURL := Trim(SL[0]);
    finally
      SL.Free;
    end;
  end;

  if ExistingURL <> CurrentDefaultURL then begin
    ForceDirectories(ExtractFilePath(ConfigPath));
    SL := TStringList.Create;
    try
      SL.Add(CurrentDefaultURL);
      SL.SaveToFile(ConfigPath);
    finally
      SL.Free;
    end;
    Result := CurrentDefaultURL;
  end else begin
    Result := ExistingURL;
  end;
end;

function TPasCubeScreen.GetBenchmarkResultsFilePath: string;
var
  HomeDir, ConfigPath: string;
begin
  HomeDir := GetEnvironmentVariable('HOME');
  if HomeDir = '' then HomeDir := '/tmp';
  ConfigPath := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigPath = '' then
    ConfigPath := HomeDir + '/.config';
  ConfigPath := ConfigPath + '/goverlay';
  if not DirectoryExists(ConfigPath) then
    ForceDirectories(ConfigPath);
  Result := ConfigPath + '/benchmark_results.json';
end;

procedure TPasCubeScreen.InitializeSubmitStatus;
begin
  if GetSubmitURL = '' then
    fSubmitStatus := 4
  else
    fSubmitStatus := 0;
end;

procedure CleanProcessEnvironment(AProcess: TProcess);
var
  i: Integer;
  EnvVar: string;
begin
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
end;

function GetSHA256Hash(const AInput: string): string;
var
  AProcess: TProcess;
  Buffer: array[0..255] of Char;
  BytesRead: LongInt;
  OutputStr: string;
  LoopCount: Integer;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'sha256sum';
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      if Length(AInput) > 0 then
        AProcess.Input.Write(AInput[1], Length(AInput));
      AProcess.CloseInput;
      
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 200 then begin // 1 second timeout
          try
            AProcess.Terminate(1);
          except
          end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      
      OutputStr := Trim(OutputStr);
      if Length(OutputStr) >= 64 then
        Result := Copy(OutputStr, 1, 64);
    except
      // ignore
    end;
  finally
    AProcess.Free;
  end;
end;

function GetNvidiaUUID: string;
var
  AProcess: TProcess;
  Buffer: array[0..255] of Char;
  BytesRead: LongInt;
  OutputStr: string;
  LoopCount: Integer;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'nvidia-smi';
    AProcess.Parameters.Add('--query-gpu=uuid');
    AProcess.Parameters.Add('--format=csv,noheader');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 200 then begin // 1 second timeout
          try
            AProcess.Terminate(1);
          except
          end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      Result := Trim(OutputStr);
    except
      // ignore
    end;
  finally
    AProcess.Free;
  end;
end;

function GetAmdUniqueID: string;
var
  SL: TStringList;
  FilePath: string;
  i: Integer;
begin
  Result := '';
  for i := 0 to 8 do begin
    FilePath := '/sys/class/drm/card' + IntToStr(i) + '/device/unique_id';
    if FileExists(FilePath) then begin
      SL := TStringList.Create;
      try
        try
          SL.LoadFromFile(FilePath);
          if SL.Count > 0 then
            Result := Trim(SL[0]);
        except
          // ignore
        end;
      finally
        SL.Free;
      end;
      if Result <> '' then Exit;
    end;
  end;
end;

function GetPersistentUUID: string;
var
  HomeDir, ConfigDir, FilePath: string;
  SL: TStringList;
  Guid: TGUID;
  GuidStr: string;
begin
  Result := '';
  HomeDir := GetEnvironmentVariable('HOME');
  if HomeDir = '' then HomeDir := '/tmp';
  ConfigDir := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigDir = '' then
    ConfigDir := HomeDir + '/.config';
  ConfigDir := ConfigDir + '/goverlay';
  FilePath := IncludeTrailingPathDelimiter(ConfigDir) + 'client-id';
  
  // Try reading existing file
  if FileExists(FilePath) then begin
    SL := TStringList.Create;
    try
      try
        SL.LoadFromFile(FilePath);
        if SL.Count > 0 then
          Result := Trim(SL[0]);
      except
        // ignore
      end;
    finally
      SL.Free;
    end;
  end;
  
  // If empty or not found, generate new one
  if Result = '' then begin
    if CreateGUID(Guid) = 0 then begin
      GuidStr := GUIDToString(Guid);
      // Strip out '{' and '}'
      if (Length(GuidStr) >= 2) and (GuidStr[1] = '{') and (GuidStr[Length(GuidStr)] = '}') then
        GuidStr := Copy(GuidStr, 2, Length(GuidStr) - 2);
      Result := LowerCase(GuidStr);
      
      // Save to file
      try
        ForceDirectories(ConfigDir);
        SL := TStringList.Create;
        try
          SL.Add(Result);
          SL.SaveToFile(FilePath);
        finally
          SL.Free;
        end;
      except
        // ignore
      end;
    end;
  end;
end;

function GetGPUHardwareSignature: string;
begin
  // Try NVIDIA
  Result := GetNvidiaUUID;
  if Result <> '' then Exit;
  
  // Try AMD
  Result := GetAmdUniqueID;
  if Result <> '' then Exit;
  
  // Fallback to persistent UUID
  Result := GetPersistentUUID;
end;

procedure TPasCubeScreen.SubmitBenchmarkResults;
var URL, UserNick: string;
    JSONObj: TJSONObject;
    Payload: string;
    Prompted: Boolean;
begin
  URL := GetSubmitURL;
  if URL = '' then begin
    fSubmitStatus := 4;
    Exit;
  end;

  UserNick := ReadPasCubeNickname(Prompted);
  if UserNick = '' then UserNick := 'Anonymous';

  JSONObj := TJSONObject.Create;
  try
    JSONObj.Add('username', UserNick);
    JSONObj.Add('cpu', GetCPUName);
    JSONObj.Add('gpu', CleanGPUName(fCurrentResult.DeviceName));
    JSONObj.Add('vram', GetVRAMSize);
    JSONObj.Add('ram', GetRAMSize);
    JSONObj.Add('driver', GetDriverVersion);
    JSONObj.Add('os', GetOSName);
    JSONObj.Add('kernel', GetKernelVersion);
    JSONObj.Add('main_score', fCurrentResult.TotalScore);
    JSONObj.Add('cpu_single', fCurrentResult.PhaseResults[1].Score);
    JSONObj.Add('cpu_multi', fCurrentResult.PhaseResults[2].Score);
    JSONObj.Add('gpu_score', fCurrentResult.PhaseResults[3].Score);
    JSONObj.Add('machine_hash', GetSHA256Hash(GetGPUHardwareSignature));
    JSONObj.Add('client_id', GetSHA256Hash(GetGPUHardwareSignature));
    JSONObj.Add('architecture', GetCPUArchitecture);
    JSONObj.Add('package', GetPackageType);
    JSONObj.Add('timer', Round(fCurrentResult.BenchmarkDuration));
    JSONObj.Add('display_server', fCurrentResult.DisplayServer);
    JSONObj.Add('resolution', fCurrentResult.DisplayResolution);
    JSONObj.Add('refresh_rate', fCurrentResult.RefreshRate);
    JSONObj.Add('desktop', fCurrentResult.DesktopEnvironment);
    JSONObj.Add('desktop_environment', fCurrentResult.DesktopEnvironment);
    JSONObj.Add('storage_type', fCurrentResult.StorageType);
    JSONObj.Add('vulkan_driver', fCurrentResult.VulkanDriver);
    JSONObj.Add('cpumaxfreq', fCurrentResult.CPUMaxFreq);
    JSONObj.Add('gpumaxfreq', fCurrentResult.GPUMaxFreq);

    if fCurrentResult.GPUTempStart > 0 then begin
      JSONObj.Add('gpu_temp_start', FloatToJsonStr(fCurrentResult.GPUTempStart));
      JSONObj.Add('gpu_start_temp', FloatToJsonStr(fCurrentResult.GPUTempStart));
    end else begin
      JSONObj.Add('gpu_temp_start', 'N/D');
      JSONObj.Add('gpu_start_temp', 'N/D');
    end;

    if fCurrentResult.GPUTempMax > 0 then begin
      JSONObj.Add('gpu_temp_max', FloatToJsonStr(fCurrentResult.GPUTempMax));
      JSONObj.Add('gpu_max_temp', FloatToJsonStr(fCurrentResult.GPUTempMax));
      JSONObj.Add('gpu_temp', FloatToJsonStr(fCurrentResult.GPUTempMax));
    end else begin
      JSONObj.Add('gpu_temp_max', 'N/D');
      JSONObj.Add('gpu_max_temp', 'N/D');
      JSONObj.Add('gpu_temp', 'N/D');
    end;

    if fCurrentResult.GPUTempDelta >= 0 then begin
      JSONObj.Add('gpu_temp_delta', FloatToJsonStr(fCurrentResult.GPUTempDelta));
      JSONObj.Add('gpu_delta_temp', FloatToJsonStr(fCurrentResult.GPUTempDelta));
    end else begin
      JSONObj.Add('gpu_temp_delta', 'N/D');
      JSONObj.Add('gpu_delta_temp', 'N/D');
    end;
    Payload := JSONObj.AsJSON;
  finally
    JSONObj.Free;
  end;

  fSubmitStatus := 1; // Submitting
  fSubmitThread := TSubmitThread.Create(URL, Payload);
end;

function TPasCubeScreen.IsClearConfirmButtonHovered(const aPos: TpvVector2; out aButton: Integer): Boolean;
var app: TPasCubeApplication;
    cx, cy, charWidth, charHeight: TpvFloat;
    boxW, boxH, boxX, boxY: TpvFloat;
    btnW, btnH, yesX, noX, btnY: TpvFloat;
    gap: TpvFloat;
begin
  Result := false;
  aButton := 0;
  if fBenchmarkPhase <> bpResults then Exit;
  if not fClearConfirmPending then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  cx := 1920.0 * 0.5;
  cy := 1080.0 * 0.5;
  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  boxW := 32.0 * charWidth;
  boxH := 7.0 * charHeight;
  boxX := cx - boxW * 0.5;
  boxY := cy - boxH * 0.5;

  if (aPos.x < boxX) or (aPos.x > boxX + boxW) or
     (aPos.y < boxY) or (aPos.y > boxY + boxH) then Exit;

  // Yes / No buttons inside the box
  gap := 3.0 * charWidth;
  btnW := 10.0 * charWidth;
  btnH := 2.2 * charHeight;
  yesX := cx - gap * 0.5 - btnW;
  noX := cx + gap * 0.5;
  btnY := boxY + boxH - btnH - 1.2 * charHeight;

  if (aPos.x >= yesX) and (aPos.x <= yesX + btnW) and
     (aPos.y >= btnY) and (aPos.y <= btnY + btnH) then
  begin
    aButton := 1;
    Result := true;
    Exit;
  end;

end;

function TPasCubeScreen.IsSubmitConfirmButtonHovered(const aPos: TpvVector2; out aButton: Integer): Boolean;
var app: TPasCubeApplication;
    cx, cy, charWidth, charHeight: TpvFloat;
    boxW, boxH, boxX, boxY: TpvFloat;
    btnW, btnH, yesX, noX, btnY: TpvFloat;
    gap: TpvFloat;
begin
  Result := false;
  aButton := 0;
  if fBenchmarkPhase <> bpResults then Exit;
  if not fSubmitConfirmPending then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  cx := 1920.0 * 0.5;
  cy := 1080.0 * 0.5;
  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  boxW := 66.0 * charWidth;
  boxH := 36.0 * charHeight;
  boxX := cx - boxW * 0.5;
  boxY := cy - boxH * 0.5;

  if (aPos.x < boxX) or (aPos.x > boxX + boxW) or
     (aPos.y < boxY) or (aPos.y > boxY + boxH) then Exit;

  // Yes / No buttons inside the box
  gap := 5.0 * charWidth;
  btnW := 15.0 * charWidth;
  btnH := 2.5 * charHeight;
  yesX := cx - gap * 0.5 - btnW;
  noX := cx + gap * 0.5;
  btnY := boxY + boxH - btnH - 1.2 * charHeight;

  if (aPos.x >= yesX) and (aPos.x <= yesX + btnW) and
     (aPos.y >= btnY) and (aPos.y <= btnY + btnH) then
  begin
    aButton := 1;
    Result := true;
    Exit;
  end;

  if (aPos.x >= noX) and (aPos.x <= noX + btnW) and
     (aPos.y >= btnY) and (aPos.y <= btnY + btnH) then
  begin
    aButton := 2;
    Result := true;
    Exit;
  end;
end;

function TPasCubeScreen.IsMethodologyButtonHovered(const aPos: TpvVector2): Boolean;
var app: TPasCubeApplication;
    charWidth, charHeight, leftColX1, leftColWidth: TpvFloat;
    cardY, btnSize: TpvFloat;
begin
  Result := false;
  if fBenchmarkPhase <> bpResults then Exit;
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;
  leftColX1 := 1920.0 * 0.05;
  leftColWidth := 1920.0 * 0.43;
  cardY := 1.0 * charHeight;

  Result := (aPos.x >= leftColX1 + leftColWidth - 3.0 * charWidth) and
            (aPos.x <= leftColX1 + leftColWidth - 0.5 * charWidth) and
            (aPos.y >= cardY + 0.2 * charHeight) and
            (aPos.y <= cardY + 1.8 * charHeight);
end;

procedure TPasCubeScreen.DrawMethodologyOverlay;
var app: TPasCubeApplication;
    cx, cy, charWidth, charHeight: TpvFloat;
    boxW, boxH, boxX, boxY: TpvFloat;
    lineY, lineH: TpvFloat;
    textScale: TpvFloat;
begin
  app := UnitPasCubeApplication.Application;
  if not Assigned(app) then Exit;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;
  cx := 1920.0 * 0.5;
  cy := 1080.0 * 0.5;

  // Dim background
  app.TextOverlay.AddBox(0, 0, 1920.0, 1080.0,
                         0.0, 0.0, 0.0, 0.6,
                         0.0, 0.0, 0.0, 0.0, 255.0);

  // Dialog box
  boxW := 66.0 * charWidth;
  boxH := 22.0 * charHeight;
  boxX := cx - boxW * 0.5;
  boxY := cy - boxH * 0.5;
  app.TextOverlay.AddBox(boxX, boxY, boxW, boxH,
                         22.0/255.0, 25.0/255.0, 37.0/255.0, 0.95,
                         48.0/255.0, 190.0/255.0, 240.0/255.0, 0.6,
                         255.0);

  // Title
  app.TextOverlay.AddText(cx, boxY + 1.0 * charHeight, 1.1, toaCenter,
                          'Benchmark Methodology',
                          0.0, 0.0, 0.0, 0.0,
                          1.0, 1.0, 1.0, 1.0);

  textScale := 0.9;
  lineH := 1.1 * charHeight;
  lineY := boxY + 2.8 * charHeight;

  // Section 1: Tests
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, 1.0, toaLeft, 'Tests',
                          0.0, 0.0, 0.0, 0.0,
                          48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);
  lineY := lineY + 1.4 * charHeight;

  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          '1. CPU Single-Thread: 7-zip benchmark (1 thread)',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          '2. CPU Multi-Thread: 7-zip benchmark (all threads)',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          '3. GPU: Vulkan instanced multi-cube stress (1080p, 10s)',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + 2.0 * charHeight;

  // Section 2: Results
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, 1.0, toaLeft, 'Results',
                          0.0, 0.0, 0.0, 0.0,
                          48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);
  lineY := lineY + 1.4 * charHeight;

  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'CPU Single-Thread Score = raw 7-zip single-thread score',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'CPU Multi-Thread Score = raw 7-zip multi-thread score',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'GPU Score = (avg FPS * 60) + (min FPS * 40), recalibrated to 1080p',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + 2.0 * charHeight;

  // Section 3: Formula
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, 1.0, toaLeft, 'Formula',
                          0.0, 0.0, 0.0, 0.0,
                          48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);
  lineY := lineY + 1.4 * charHeight;

  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'Main Score = (CPU ST * 0.35) + (CPU MT * 0.15) + (GPU * 0.5)',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'Weights: CPU 50% (35% single-thread + 15% multi-thread), GPU 50%',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + lineH;
  app.TextOverlay.AddText(boxX + 2.0 * charWidth, lineY, textScale, toaLeft,
                          'Recalibrated against Steam Machine reference (1700 pts)',
                          0.0, 0.0, 0.0, 0.0,
                          179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);
  lineY := lineY + 1.0 * charHeight;
end;

procedure TPasCubeScreen.ClearBenchmarkResults;
var
  filePath: String;
begin
  fHistoryCount := 0;
  fBestScore := 0;
  fLastScore := 0;
  FillChar(fHistory, SizeOf(fHistory), #0);
  filePath := GetBenchmarkResultsFilePath;
  if FileExists(filePath) then
    DeleteFile(filePath);
   // Return to menu since there are no results to display
   fBenchmarkPhase := bpIdleMenu;
   fShowSkybox := true;
  fClearConfirmPending := false;
  fClearConfirmHovered := 0;
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
  app.TextOverlay.AddText(1920.0 * 0.5, 40.0, 2.2, toaCenter, phaseStr);

  // Render FPS right below the main cube
  app.TextOverlay.AddText(1920.0 * 0.5, 1080.0 * 0.72, 1.5, toaCenter, Format('FPS: %.1f', [pvApplication.FramesPerSecond]));

  infoStr := '';
  case fBenchmarkPhase of
   bpWarmup: infoStr := 'Calibrating render engine and caches...';
   bpCPU_Single: infoStr := 'Running 7-Zip Single-Thread benchmark (MIPS)...';
   bpCPU_Multi: infoStr := 'Running 7-Zip Multi-Thread benchmark (MIPS)...';
    bpGPU_1080p: infoStr := 'Testing GPU at 1080p (1920x1080)...';
  end;

  pbWidth := 1920.0 * 0.6;
  pbHeight := 24.0;
  pbX := (1920.0 - pbWidth) * 0.5;
  pbY := 1080.0 - 120.0;

   // Draw stage description (shifted up to avoid overlapping with progress bar)
   if infoStr <> '' then
    app.TextOverlay.AddText(1920.0 * 0.5, pbY - 45.0, 1.2, toaCenter, infoStr);

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

   // Draw progress percentage text centered inside the progress bar
   app.TextOverlay.AddText(1920.0 * 0.5,
                          pbY + (pbHeight - app.TextOverlay.FontCharHeight * 0.8) * 0.5,
                          0.8,
                          toaCenter,
                          Format('%.0f%%', [progress * 100.0]));
end;

function TPasCubeScreen.GetCPUName: String;
var SL: TStringList;
    i: Integer;
    line, val: String;
    valInt: Integer;
    AProcess: TProcess;
begin
 Result := 'Unknown CPU';
 SL := TStringList.Create;
 try
  if FileExists('/proc/cpuinfo') then begin
   SL.LoadFromFile('/proc/cpuinfo');
   for i := 0 to SL.Count - 1 do begin
    line := Trim(SL[i]);
    if Pos('model name', LowerCase(line)) = 1 then begin
     Result := Trim(Copy(line, Pos(':', line) + 1, Length(line)));
     break;
    end;
   end;
   if Result = 'Unknown CPU' then begin
    for i := 0 to SL.Count - 1 do begin
     line := Trim(SL[i]);
     if Pos('processor', LowerCase(line)) = 1 then begin
      val := Trim(Copy(line, Pos(':', line) + 1, Length(line)));
      if not TryStrToInt(val, valInt) then begin
       Result := val;
       break;
      end;
     end;
    end;
   end;
  end;

  if Result = 'Unknown CPU' then begin
    AProcess := TProcess.Create(nil);
    try
      CleanProcessEnvironment(AProcess);
      AProcess.Executable := 'env';
      AProcess.Parameters.Add('LC_ALL=C');
      AProcess.Parameters.Add('lscpu');
      AProcess.Options := [poUsePipes, poNoConsole];
      try
        AProcess.Execute;
        AProcess.CloseInput;
        SL.Clear;
        SL.LoadFromStream(AProcess.Output);
        for i := 0 to SL.Count - 1 do begin
          line := Trim(SL[i]);
          if Pos('model name:', LowerCase(line)) = 1 then begin
            Result := Trim(Copy(line, Pos(':', line) + 1, Length(line)));
            break;
          end;
        end;
      except
        // ignore
      end;
    finally
      AProcess.Free;
    end;
  end;

  // Remove common vendor noise to keep it concise
  Result := StringReplace(Result, 'Intel(R) Core(TM) ', '', [rfReplaceAll]);
  Result := StringReplace(Result, 'AMD ', '', [rfReplaceAll]);
  Result := StringReplace(Result, ' CPU', '', [rfReplaceAll]);
  Result := StringReplace(Result, ' Processor', '', [rfReplaceAll]);
 finally
  SL.Free;
 end;
end;

function TPasCubeScreen.GetCPUArchitecture: String;
var
  AProcess: TProcess;
  Buffer: array[0..255] of Char;
  BytesRead: LongInt;
  OutputStr: string;
  LoopCount: Integer;
begin
  Result := 'Unknown';
  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'uname';
    AProcess.Parameters.Add('-m');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 200 then begin // 1 second timeout
          try
            AProcess.Terminate(1);
          except
          end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      if Trim(OutputStr) <> '' then
        Result := Trim(OutputStr);
    except
      // ignore
    end;
  finally
    AProcess.Free;
  end;
end;

function TPasCubeScreen.GetDisplayServer: String;
var
  Sess: String;
begin
  Sess := LowerCase(Trim(GetEnvironmentVariable('XDG_SESSION_TYPE')));
  if (Sess = 'wayland') or (Sess = 'x11') or (Sess = 'tty') then
    Result := Sess
  else if Sess <> '' then
    Result := Sess
  else
    Result := 'N/D';
end;

procedure TPasCubeScreen.GetDisplayResolutionAndRefresh(out ARes, ARefresh: String);
var
  AProcess: TProcess;
  Buffer: array[0..511] of Char;
  BytesRead: LongInt;
  OutputStr, Line, Token, ModeRes: String;
  SL: TStringList;
  i, pStar, pSpace, pX, LoopCount: Integer;
  Found: Boolean;
  FilePath: String;
  HzVal: Double;
begin
  ARes := 'N/D';
  ARefresh := 'N/D';
  Found := False;

  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'xrandr';
    AProcess.Parameters.Add('--current');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 40 then begin // 200ms timeout max
          try AProcess.Terminate(1); except end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      
      if OutputStr <> '' then begin
        SL := TStringList.Create;
        try
          SL.Text := OutputStr;
          for i := 0 to SL.Count - 1 do begin
            Line := SL[i];
            pStar := Pos('*', Line);
            if pStar > 0 then begin
              Token := Trim(Copy(Line, 1, pStar - 1));
              pSpace := LastDelimiter(' '#9, Token);
              if pSpace > 0 then begin
                Token := Trim(Copy(Token, pSpace + 1, Length(Token)));
              end;
              if TryStrToFloat(StringReplace(Token, '.', DecimalSeparator, [rfReplaceAll]), HzVal) then
                ARefresh := IntToStr(Round(HzVal))
              else
                ARefresh := Token;
                
              Line := Trim(SL[i]);
              pX := Pos('x', Line);
              if pX > 1 then begin
                pSpace := pX - 1;
                while (pSpace >= 1) and (Line[pSpace] in ['0'..'9']) do Dec(pSpace);
                ModeRes := Copy(Line, pSpace + 1, Length(Line));
                pSpace := Pos(' ', ModeRes);
                if pSpace > 0 then ModeRes := Copy(ModeRes, 1, pSpace - 1);
                if Pos('x', ModeRes) > 0 then begin
                  ARes := ModeRes;
                  Found := True;
                  Break;
                end;
              end;
            end;
          end;
        finally
          SL.Free;
        end;
      end;
    except
    end;
  finally
    AProcess.Free;
  end;

  if Found then Exit;

  for i := 0 to 8 do begin
    FilePath := '/sys/class/drm/card' + IntToStr(i) + '-DP-1/modes';
    if not FileExists(FilePath) then FilePath := '/sys/class/drm/card' + IntToStr(i) + '-HDMI-A-1/modes';
    if not FileExists(FilePath) then FilePath := '/sys/class/drm/card' + IntToStr(i) + '-eDP-1/modes';
    if FileExists(FilePath) then begin
      SL := TStringList.Create;
      try
        try
          SL.LoadFromFile(FilePath);
          if (SL.Count > 0) and (Pos('x', SL[0]) > 0) then begin
            ARes := Trim(SL[0]);
            Exit;
          end;
        except
        end;
      finally
        SL.Free;
      end;
    end;
  end;
end;

function TPasCubeScreen.GetDesktopEnvironment: String;
var
  De: String;
begin
  De := GetEnvironmentVariable('XDG_CURRENT_DESKTOP');
  if De = '' then De := GetEnvironmentVariable('DESKTOP_SESSION');
  De := Trim(De);
  if De = '' then begin
    Result := 'N/D';
    Exit;
  end;

  if Pos('KDE', UpperCase(De)) > 0 then Result := 'KDE Plasma'
  else if Pos('GNOME', UpperCase(De)) > 0 then Result := 'GNOME'
  else if Pos('HYPRLAND', UpperCase(De)) > 0 then Result := 'Hyprland'
  else if Pos('XFCE', UpperCase(De)) > 0 then Result := 'XFCE'
  else if Pos('SWAY', UpperCase(De)) > 0 then Result := 'Sway'
  else if Pos('CINNAMON', UpperCase(De)) > 0 then Result := 'Cinnamon'
  else if Pos('MATE', UpperCase(De)) > 0 then Result := 'MATE'
  else if Pos('LXQT', UpperCase(De)) > 0 then Result := 'LXQt'
  else Result := De;
end;

function TPasCubeScreen.GetStorageType: String;
var
  AProcess: TProcess;
  Buffer: array[0..511] of Char;
  BytesRead: LongInt;
  OutputStr, Line, DevName, RotaStr, TranStr: String;
  SL: TStringList;
  i, p1, p2, LoopCount: Integer;
  FilePath: String;
begin
  Result := 'N/D';
  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'lsblk';
    AProcess.Parameters.Add('-d');
    AProcess.Parameters.Add('-o');
    AProcess.Parameters.Add('NAME,ROTA,TRAN');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 40 then begin // 200ms timeout max
          try AProcess.Terminate(1); except end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;

      if OutputStr <> '' then begin
        SL := TStringList.Create;
        try
          SL.Text := OutputStr;
          for i := 1 to SL.Count - 1 do begin
            Line := Trim(SL[i]);
            if Line = '' then Continue;
            p1 := Pos(' ', Line);
            if p1 > 0 then begin
              DevName := Copy(Line, 1, p1 - 1);
              Line := Trim(Copy(Line, p1 + 1, Length(Line)));
              p2 := Pos(' ', Line);
              if p2 > 0 then begin
                RotaStr := Copy(Line, 1, p2 - 1);
                TranStr := LowerCase(Trim(Copy(Line, p2 + 1, Length(Line))));
              end else begin
                RotaStr := Line;
                TranStr := '';
              end;

              if (Pos('loop', DevName) = 1) or (Pos('zram', DevName) = 1) or (Pos('ram', DevName) = 1) then Continue;

              if (RotaStr = '0') and ((TranStr = 'nvme') or (Pos('nvme', DevName) = 1)) then begin
                Result := 'NVMe SSD';
                Exit;
              end else if (RotaStr = '0') then begin
                Result := 'SATA SSD';
              end else if (RotaStr = '1') and (Result = 'N/D') then begin
                Result := 'HDD';
              end;
            end;
          end;
        finally
          SL.Free;
        end;
      end;
    except
    end;
  finally
    AProcess.Free;
  end;

  if Result <> 'N/D' then Exit;

  if DirectoryExists('/sys/block/nvme0n1') or DirectoryExists('/sys/block/nvme0') then begin
    Result := 'NVMe SSD';
    Exit;
  end;
  for i := 0 to 3 do begin
    FilePath := '/sys/block/sd' + Chr(Ord('a') + i) + '/queue/rotational';
    if FileExists(FilePath) then begin
      SL := TStringList.Create;
      try
        try
          SL.LoadFromFile(FilePath);
          if (SL.Count > 0) then begin
            if Trim(SL[0]) = '0' then Result := 'SATA SSD'
            else if Trim(SL[0]) = '1' then Result := 'HDD';
            Exit;
          end;
        except
        end;
      finally
        SL.Free;
      end;
    end;
  end;
end;

function TPasCubeScreen.GetVulkanDriver: String;
var
  DevName, DrvVer: String;
  VendorID: TVkUInt32;
begin
  Result := 'N/D';
  if not Assigned(pvApplication) or not Assigned(pvApplication.VulkanDevice) or not Assigned(pvApplication.VulkanDevice.PhysicalDevice) then Exit;
  DevName := UpperCase(pvApplication.VulkanDevice.PhysicalDevice.DeviceName);
  DrvVer := UpperCase(GetDriverVersion);
  VendorID := pvApplication.VulkanDevice.PhysicalDevice.Properties.vendorID;

  if (Pos('RADV', DevName) > 0) or (Pos('RADV', DrvVer) > 0) then Result := 'RADV'
  else if (Pos('ANV', DevName) > 0) or (Pos('ANV', DrvVer) > 0) then Result := 'ANV'
  else if (Pos('NVK', DevName) > 0) or (Pos('NVK', DrvVer) > 0) then Result := 'NVK'
  else if (Pos('AMDVLK', DevName) > 0) or (Pos('AMDVLK', DrvVer) > 0) then Result := 'AMDVLK'
  else if (VendorID = $10DE) or (Pos('NVIDIA', DevName) > 0) then Result := 'NVIDIA Proprietary'
  else if (VendorID = $1002) or (Pos('AMD', DevName) > 0) or (Pos('RADEON', DevName) > 0) then Result := 'RADV'
  else if (VendorID = $8086) or (Pos('INTEL', DevName) > 0) then Result := 'ANV';
end;

function ExtractMaxFreqFromPPDPM(const Content: string): Integer;
var
  SL: TStringList;
  Line: string;
  p, j, Val: Integer;
  NumStr: string;
begin
  Result := 0;
  SL := TStringList.Create;
  try
    SL.Text := Content;
    for Line in SL do begin
      p := Pos('mhz', LowerCase(Line));
      if p > 0 then begin
        NumStr := '';
        // Scan backwards for digits
        j := p - 1;
        while (j > 0) and (Line[j] in ['0'..'9']) do begin
          NumStr := Line[j] + NumStr;
          Dec(j);
        end;
        if (NumStr <> '') and TryStrToInt(NumStr, Val) then begin
          if Val > Result then
            Result := Val;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function TPasCubeScreen.GetCPUMaxFreq: Integer;
var
  SL: TStringList;
  FilePath: string;
  ValInt: Integer;
  i: Integer;
begin
  Result := 0;
  SL := TStringList.Create;
  try
    for i := 0 to 127 do begin
      FilePath := '/sys/devices/system/cpu/cpu' + IntToStr(i) + '/cpufreq/cpuinfo_max_freq';
      if not FileExists(FilePath) then
        FilePath := '/sys/devices/system/cpu/cpu' + IntToStr(i) + '/cpufreq/scaling_max_freq';
      if FileExists(FilePath) then begin
        try
          SL.LoadFromFile(FilePath);
          if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
            Result := ValInt div 1000; // convert kHz to MHz
            Exit;
          end;
        except
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function TPasCubeScreen.GetGPUMaxFreq: Integer;
var
  cardIdx: Integer;
  ppPath, intelPath, OutputStr: string;
  SL: TStringList;
  ValInt: Integer;
  AProcess: TProcess;
  Buffer: array[0..255] of Char;
  BytesRead: LongInt;
  LoopCount: Integer;
begin
  Result := 0;
  SL := TStringList.Create;
  try
    // 1. Try Intel paths
    for cardIdx := 0 to 8 do begin
      intelPath := '/sys/class/drm/card' + IntToStr(cardIdx) + '/device/gt_max_freq_mhz';
      if FileExists(intelPath) then begin
        try
          SL.LoadFromFile(intelPath);
          if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
            Result := ValInt;
            Exit;
          end;
        except
        end;
      end;
      
      intelPath := '/sys/class/drm/card' + IntToStr(cardIdx) + '/device/gt/gt0/max_freq_mhz';
      if FileExists(intelPath) then begin
        try
          SL.LoadFromFile(intelPath);
          if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
            Result := ValInt;
            Exit;
          end;
        except
        end;
      end;
    end;

    // 2. Try AMD pp_dpm_sclk paths
    for cardIdx := 0 to 8 do begin
      ppPath := '/sys/class/drm/card' + IntToStr(cardIdx) + '/device/pp_dpm_sclk';
      if FileExists(ppPath) then begin
        try
          SL.LoadFromFile(ppPath);
          ValInt := ExtractMaxFreqFromPPDPM(SL.Text);
          if ValInt > 0 then begin
            Result := ValInt;
            Exit;
          end;
        except
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  // 3. Try NVIDIA nvidia-smi
  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'nvidia-smi';
    AProcess.Parameters.Add('--query-gpu=clocks.max.gr');
    AProcess.Parameters.Add('--format=csv,noheader,nounits');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 40 then begin
          try AProcess.Terminate(1); except end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      if TryStrToInt(Trim(OutputStr), ValInt) then
        Result := ValInt;
    except
    end;
  finally
    AProcess.Free;
  end;
end;

function TPasCubeScreen.GetCPUTemperature: Double;
var
  i, j: Integer;
  HwmonPath, NamePath, TempPath, NameStr: String;
  SL: TStringList;
  ValInt: LongInt;
begin
  Result := -1.0;
  SL := TStringList.Create;
  try
    for i := 0 to 15 do begin
      HwmonPath := '/sys/class/hwmon/hwmon' + IntToStr(i);
      if not DirectoryExists(HwmonPath) then Continue;
      NamePath := HwmonPath + '/name';
      NameStr := '';
      if FileExists(NamePath) then begin
        try
          SL.LoadFromFile(NamePath);
          if SL.Count > 0 then NameStr := LowerCase(Trim(SL[0]));
        except
        end;
      end;

      if (Pos('k10temp', NameStr) > 0) or (Pos('coretemp', NameStr) > 0) or
         (Pos('zenpower', NameStr) > 0) or (Pos('cpu', NameStr) > 0) or
         (Pos('acpitz', NameStr) > 0) or (Pos('package', NameStr) > 0) or (NameStr = '') then begin
        for j := 1 to 8 do begin
          TempPath := HwmonPath + '/temp' + IntToStr(j) + '_input';
          if FileExists(TempPath) then begin
            try
              SL.LoadFromFile(TempPath);
              if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
                if ValInt > 150 then Result := ValInt / 1000.0 else Result := ValInt;
                if (Result > 0) and (Result < 150) then Exit;
              end;
            except
            end;
          end;
        end;
      end;
    end;

    for i := 0 to 8 do begin
      TempPath := '/sys/class/thermal/thermal_zone' + IntToStr(i) + '/temp';
      if FileExists(TempPath) then begin
        try
          SL.LoadFromFile(TempPath);
          if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
            if ValInt > 150 then Result := ValInt / 1000.0 else Result := ValInt;
            if (Result > 0) and (Result < 150) then Exit;
          end;
        except
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function TPasCubeScreen.GetGPUTemperature: Double;
var
  i, j, LoopCount: Integer;
  HwmonPath, NamePath, TempPath, NameStr: String;
  SL: TStringList;
  ValInt: LongInt;
  AProcess: TProcess;
  Buffer: array[0..255] of Char;
  BytesRead: LongInt;
  OutputStr: String;
begin
  Result := -1.0;
  SL := TStringList.Create;
  try
    for i := 0 to 15 do begin
      HwmonPath := '/sys/class/hwmon/hwmon' + IntToStr(i);
      if not DirectoryExists(HwmonPath) then Continue;
      NamePath := HwmonPath + '/name';
      NameStr := '';
      if FileExists(NamePath) then begin
        try
          SL.LoadFromFile(NamePath);
          if SL.Count > 0 then NameStr := LowerCase(Trim(SL[0]));
        except
        end;
      end;

      if (Pos('amdgpu', NameStr) > 0) or (Pos('nvidia', NameStr) > 0) or
         (Pos('nouveau', NameStr) > 0) or (Pos('i915', NameStr) > 0) or (Pos('xe', NameStr) > 0) then begin
        for j := 1 to 8 do begin
          TempPath := HwmonPath + '/temp' + IntToStr(j) + '_input';
          if FileExists(TempPath) then begin
            try
              SL.LoadFromFile(TempPath);
              if (SL.Count > 0) and TryStrToInt(Trim(SL[0]), ValInt) then begin
                if ValInt > 150 then Result := ValInt / 1000.0 else Result := ValInt;
                if (Result > 0) and (Result < 150) then Exit;
              end;
            except
            end;
          end;
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  if Result > 0 then Exit;

  AProcess := TProcess.Create(nil);
  try
    CleanProcessEnvironment(AProcess);
    AProcess.Executable := 'nvidia-smi';
    AProcess.Parameters.Add('--query-gpu=temperature.gpu');
    AProcess.Parameters.Add('--format=csv,noheader');
    AProcess.Options := [poUsePipes, poNoConsole];
    try
      AProcess.Execute;
      AProcess.CloseInput;
      OutputStr := '';
      LoopCount := 0;
      while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do begin
        Inc(LoopCount);
        if LoopCount > 40 then begin
          try AProcess.Terminate(1); except end;
          Break;
        end;
        if AProcess.Output.NumBytesAvailable > 0 then begin
          BytesRead := AProcess.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then begin
            Buffer[BytesRead] := #0;
            OutputStr := OutputStr + StrPas(Buffer);
          end;
        end;
        Sleep(5);
      end;
      if TryStrToInt(Trim(OutputStr), ValInt) then
        Result := ValInt;
    except
    end;
  finally
    AProcess.Free;
  end;
end;

function TPasCubeScreen.GetPackageType: String;
begin
  Result := GetEnvironmentVariable('GOVERLAY_PACKAGE_TYPE');
  if Result = '' then begin
    if GetEnvironmentVariable('FLATPAK_ID') <> '' then
      Result := 'flatpak'
    else if GetEnvironmentVariable('APPIMAGE') <> '' then
      Result := 'appimage'
    else
      Result := 'native';
  end;
end;

function TPasCubeScreen.GetRAMSize: String;
var SL: TStringList;
    i: Integer;
    line: String;
    kb: Int64;
begin
 Result := 'Unknown RAM';
 SL := TStringList.Create;
 try
  if FileExists('/proc/meminfo') then begin
   SL.LoadFromFile('/proc/meminfo');
   for i := 0 to SL.Count - 1 do begin
    line := SL[i];
    if Pos('MemTotal:', line) = 1 then begin
     line := Trim(Copy(line, 10, Length(line)));
     line := StringReplace(line, ' kB', '', [rfReplaceAll]);
     kb := StrToInt64Def(line, 0);
     if kb > 0 then begin
      Result := Format('%.0fGB', [kb / 1048576.0]);
     end;
     break;
    end;
   end;
  end;
 finally
  SL.Free;
 end;
end;

function TPasCubeScreen.GetOSName: String;
var SL: TStringList;
    i: Integer;
    line: String;
    osReleasePath: String;
begin
 Result := 'Linux';
 osReleasePath := '';
 if FileExists('/run/host/os-release') then
   osReleasePath := '/run/host/os-release'
 else if FileExists('/run/host/etc/os-release') then
   osReleasePath := '/run/host/etc/os-release'
 else if FileExists('/run/host/usr/lib/os-release') then
   osReleasePath := '/run/host/usr/lib/os-release'
 else if FileExists('/etc/os-release') then
   osReleasePath := '/etc/os-release';

 if osReleasePath <> '' then begin
   SL := TStringList.Create;
   try
     SL.LoadFromFile(osReleasePath);
     for i := 0 to SL.Count - 1 do begin
      line := SL[i];
      if Pos('PRETTY_NAME=', line) = 1 then begin
       Result := Copy(line, 13, Length(line) - 13);
       Result := StringReplace(Result, '"', '', [rfReplaceAll]);
       break;
      end;
     end;
   finally
     SL.Free;
   end;
 end;
end;

function TPasCubeScreen.CleanGPUName(const aName: String): String;
begin
 Result := aName;
 Result := StringReplace(Result, 'NVIDIA GeForce ', '', [rfReplaceAll]);
 Result := StringReplace(Result, 'AMD Radeon ', '', [rfReplaceAll]);
 Result := StringReplace(Result, ' (TM)', '', [rfReplaceAll]);
end;

function TPasCubeScreen.GetKernelVersion: String;
var SL: TStringList;
    verStr: String;
    p: Integer;
begin
 Result := 'Unknown';
 if FileExists('/proc/version') then begin
  SL := TStringList.Create;
  try
   SL.LoadFromFile('/proc/version');
   if SL.Count > 0 then begin
    verStr := SL[0];
    // Parse "Linux version X.Y.Z-..." → extract "X.Y.Z-..."
    p := Pos('Linux version ', verStr);
    if p > 0 then begin
     verStr := Copy(verStr, p + 14, Length(verStr));
     p := Pos(' ', verStr);
     if p > 0 then
      Result := Copy(verStr, 1, p - 1)
     else
      Result := verStr;
    end;
   end;
  finally
   SL.Free;
  end;
 end;
end;

function TPasCubeScreen.GetDriverVersion: String;
var SL: TStringList;
    path: String;
    i: Integer;
    VendorID: TVkUInt32;
    DriverVersion: TVkUInt32;
    Major, Minor, Patch: TVkUInt32;
begin
 Result := 'Unknown';

 // Try NVIDIA proprietary driver
 if FileExists('/proc/driver/nvidia/version') then begin
  SL := TStringList.Create;
  try
   SL.LoadFromFile('/proc/driver/nvidia/version');
   if SL.Count > 0 then
    Result := Trim(SL[0]);
  finally
   SL.Free;
  end;
  Exit;
 end;

 // Try DRM kernel module version for any card (Mesa / AMD / Intel)
 for i := 0 to 3 do begin
  path := Format('/sys/class/drm/card%d/device/driver/module/version', [i]);
  if FileExists(path) then begin
   SL := TStringList.Create;
   try
    SL.LoadFromFile(path);
    if SL.Count > 0 then begin
     Result := Trim(SL[0]);
     Exit;
    end;
   finally
    SL.Free;
   end;
  end;
 end;

 // Fallback: decode Vulkan driverVersion from physical device properties
 if Assigned(pvApplication.VulkanDevice) then begin
  VendorID := pvApplication.VulkanDevice.PhysicalDevice.Properties.vendorID;
  DriverVersion := pvApplication.VulkanDevice.PhysicalDevice.Properties.driverVersion;
  if VendorID = $10DE then begin
   // NVIDIA encoding: major*1000 + minor*10 + patch
   Major := DriverVersion div 1000;
   Minor := (DriverVersion - (Major * 1000)) div 10;
   Patch := DriverVersion - (Major * 1000) - (Minor * 10);
   Result := Format('NVIDIA %d.%d.%d', [Major, Minor, Patch]);
  end else begin
   // Mesa / Intel / AMD standard encoding: major<<22 | minor<<12 | patch
   Major := DriverVersion shr 22;
   Minor := (DriverVersion shr 12) and $3FF;
   Patch := DriverVersion and $FFF;
   Result := Format('Mesa %d.%d.%d', [Major, Minor, Patch]);
  end;
 end;
end;

function TPasCubeScreen.GetVRAMSize: String;
var SizeBytes: TVkDeviceSize;
begin
  Result := 'Unknown VRAM';
  if Assigned(pvApplication) and Assigned(pvApplication.VulkanDevice) and Assigned(pvApplication.VulkanDevice.MemoryManager) then begin
    SizeBytes := pvApplication.VulkanDevice.MemoryManager.VideoRAMSize;
    if SizeBytes > 0 then begin
      Result := Format('%.1fGB', [SizeBytes / 1073741824.0]);
      if Pos('.0GB', Result) > 0 then
        Result := StringReplace(Result, '.0GB', 'GB', []);
    end;
  end;
end;

 procedure TPasCubeScreen.DrawResultsOverlay;
var app: TPasCubeApplication;
    cx, cy: TpvFloat;
    i, j: Integer;
    lineStr, resultStr, descStr, nickname: String;
    leftColX1, leftColWidth, rightColX1, rightColWidth: TpvFloat;
     HWRefs: array[0..11] of THardwareRef;
     TempHW: THardwareRef;
     MaxScore: Integer;
      barStartX, maxBarWidth, barWidth, barHeight, barY: TpvFloat;
      bgR, bgG, bgB, bgA: TpvFloat;
      isExpanded, isHovered: Boolean;
      itemH: TpvFloat;
      nameR, nameG, nameB, scoreR, scoreG, scoreB, barR, barG, barB, barA: TpvFloat;
      hwScoreStr, kernelStr, driverStr: String;
    charWidth, charHeight: TpvFloat;
    textScaleSmall: TpvFloat;
    scaleFactor: TpvDouble;
    cardY, cardHeight, availableH, fixedH, itemY, topBoxX, topBoxY, topBoxW, topBoxH: TpvFloat;
    halfWidth, gap, hwCardY, hwTotalH: TpvFloat;
     btnWidth, btnHeight, btnX, btnY, paddingX, paddingY, yText: TpvFloat;
     clearBtnWidth, clearBtnHeight, clearBtnX, clearBtnY: TpvFloat;
     returnBtnWidth, returnBtnX, groupX, groupWidth: TpvFloat;
     submitBtnWidth, submitBtnX: TpvFloat;
     isReturnHovered, isClearHovered, isSubmitHovered, prompted: Boolean;
     submitStr: String;
     fgR, fgG, fgB, fgA: TpvFloat;
    textR, textG, textB, textA: TpvFloat;
      // Graph variables
       graphY, graphH, graphW, pointX, pointY, prevX, prevY, barW, scoreRange: TpvFloat;
        graphMaxScore, graphMinScore: Integer;
        graphIdx, historyIdx: Integer;
       baseY, plotTop, plotH, barX, barTopH: TpvFloat;
       paddedMinScore, paddedRange: TpvFloat;
      popupX, popupY, popupW, popupH: TpvFloat;
      detailStr: String;
      // Clear confirmation dialog variables
      boxW, boxH, boxX, boxY, btnW, btnH, yesX, noX: TpvFloat;
begin
 app := UnitPasCubeApplication.Application;
 if not Assigned(app) then Exit;

  charWidth := app.TextOverlay.FontCharWidth;
  charHeight := app.TextOverlay.FontCharHeight;

  textScaleSmall := 0.65;
  cx := 1920.0 * 0.5;
  cy := 1080.0 * 0.5;

  leftColX1 := 1920.0 * 0.05;
  leftColWidth := 1920.0 * 0.43;
  rightColX1 := 1920.0 * 0.52;
  rightColWidth := 1920.0 * 0.43;

    // --- COLUNA DIREITA: Hardware Comparison ---
    hwCardY := 1.0 * charHeight;
    // Leave comfortable margin above Return button (55px)
    hwTotalH := 1080.0 - 55.0 - hwCardY - 55.0;

    // Draw right card background first (so text draws on top)
     app.TextOverlay.AddBox(rightColX1, hwCardY, rightColWidth, hwTotalH,
                            33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.95,
                            48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 0.6,
                            255.0);

    // --- COLUNA ESQUERDA: Final Results + CPU + GPU + History ---
   halfWidth := (leftColWidth - charWidth) / 2;
   gap := charWidth;
    // Dynamic card height: distribute available vertical space between the 3 cards and Score Trend
    availableH := (hwCardY + hwTotalH) - (1.0 * charHeight);
     // Fixed: Main Score (6.5) + 4 gaps (0.5 each) + Score Trend minimum (10.0)
     fixedH := (6.5 + 0.5*4 + 10.0) * charHeight;
     cardHeight := (availableH - fixedH) / 3.0;
     if cardHeight < 5.0 * charHeight then cardHeight := 5.0 * charHeight;
     if cardHeight > 10.0 * charHeight then cardHeight := 10.0 * charHeight;

    // --- Card 0: Main Score (spans both CPU card widths) ---
    cardY := 1.0 * charHeight;
    // Taller to fit the large score text
     app.TextOverlay.AddBox(leftColX1, cardY, leftColWidth, 6.5 * charHeight,
                            33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.92,
                            48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 0.6,
                            255.0);
     app.TextOverlay.AddText(leftColX1 + leftColWidth * 0.5, cardY + 0.5 * charHeight, 1.0, toaCenter, 'Main Score', 1.0, 1.0, 1.0, 0.0, 96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0, 1.0);
      app.TextOverlay.AddText(leftColX1 + leftColWidth * 0.5, cardY + 2.2 * charHeight, 3.2, toaCenter, FormatScoreValue(fCurrentResult.TotalScore), 1.0, 1.0, 1.0, 0.0, 48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 1.0);

       // --- Methodology hint (?) aligned right of Main Score title ---
       if fShowMethodology then begin
         fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
       end else begin
         fgR := 150.0 / 255.0; fgG := 160.0 / 255.0; fgB := 180.0 / 255.0; fgA := 0.9;
       end;
        app.TextOverlay.AddText(leftColX1 + leftColWidth - 1.0 * charWidth, cardY + 0.5 * charHeight, 1.4, toaRight, '?',
                                0.0, 0.0, 0.0, 0.0, fgR, fgG, fgB, fgA);

   // --- Row 1: CPU Single-Thread | CPU Multi-Thread ---
   cardY := cardY + 6.5 * charHeight + 0.5 * charHeight;

   // CPU Single-Thread (left)
   app.TextOverlay.AddBox(leftColX1, cardY, halfWidth, cardHeight,
                          33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.92,
                          50.0 / 255.0, 60.0 / 255.0, 85.0 / 255.0, 0.5,
                          255.0);
   app.TextOverlay.AddText(leftColX1 + 1.0 * charWidth, cardY + 0.5 * charHeight, 0.85, toaLeft, 'CPU Single-Thread', 1.0, 1.0, 1.0, 0.0, 96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0, 1.0);
    app.TextOverlay.AddText(leftColX1 + halfWidth * 0.5, cardY + cardHeight * 0.5, 2.2, toaCenter, FormatScoreValue(fCurrentResult.PhaseResults[1].Score), 1.0, 1.0, 1.0, 0.0, 48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 1.0);

   // CPU Multi-Thread (right)
   app.TextOverlay.AddBox(leftColX1 + halfWidth + gap, cardY, halfWidth, cardHeight,
                          33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.92,
                          50.0 / 255.0, 60.0 / 255.0, 85.0 / 255.0, 0.5,
                          255.0);
   app.TextOverlay.AddText(leftColX1 + halfWidth + gap + 1.0 * charWidth, cardY + 0.5 * charHeight, 0.85, toaLeft, 'CPU Multi-Thread', 1.0, 1.0, 1.0, 0.0, 96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0, 1.0);
    app.TextOverlay.AddText(leftColX1 + halfWidth + gap + halfWidth * 0.5, cardY + cardHeight * 0.5, 2.2, toaCenter, FormatScoreValue(fCurrentResult.PhaseResults[2].Score), 1.0, 1.0, 1.0, 0.0, 48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 1.0);

   // --- Card: Unified GPU Score ---
   cardY := cardY + cardHeight + 0.5 * charHeight;
   app.TextOverlay.AddBox(leftColX1, cardY, leftColWidth, cardHeight,
                          33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.92,
                          50.0 / 255.0, 60.0 / 255.0, 85.0 / 255.0, 0.5,
                          255.0);
   app.TextOverlay.AddText(leftColX1 + 1.0 * charWidth, cardY + 0.5 * charHeight, 0.85, toaLeft, 'GPU Score', 1.0, 1.0, 1.0, 0.0, 96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0, 1.0);
    app.TextOverlay.AddText(leftColX1 + leftColWidth * 0.5, cardY + cardHeight * 0.5, 2.2, toaCenter, FormatScoreValue(fCurrentResult.PhaseResults[7].Score), 1.0, 1.0, 1.0, 0.0, 48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 1.0);

    // --- SCORE TREND GRAPH (expanded, replaces former History / Benchmark Details space) ---
    if fHistoryCount > 0 then begin
     graphY := cardY + cardHeight + 0.5 * charHeight;
     // Align bottom with Hardware Comparison card bottom
     graphH := (hwCardY + hwTotalH) - graphY;
     if graphH < 10.0 * charHeight then graphH := 10.0 * charHeight;
     graphW := leftColWidth;

     // Graph background card
     app.TextOverlay.AddBox(leftColX1, graphY, graphW, graphH,
                            33.0 / 255.0, 38.0 / 255.0, 56.0 / 255.0, 0.92,
                            50.0 / 255.0, 60.0 / 255.0, 85.0 / 255.0, 0.5,
                            255.0);
     app.TextOverlay.AddText(leftColX1 + 2.0 * charWidth, graphY + 0.5 * charHeight, 0.9, toaLeft, 'Score Trend', 1.0, 1.0, 1.0, 0.0, 96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0, 1.0);

      // Find min/max for scaling
      graphMaxScore := fHistory[0].TotalScore;
      graphMinScore := fHistory[0].TotalScore;
      for graphIdx := 1 to fHistoryCount - 1 do begin
       if fHistory[graphIdx].TotalScore > graphMaxScore then graphMaxScore := fHistory[graphIdx].TotalScore;
       if fHistory[graphIdx].TotalScore < graphMinScore then graphMinScore := fHistory[graphIdx].TotalScore;
      end;
      if graphMaxScore = graphMinScore then scoreRange := 1.0 else scoreRange := graphMaxScore - graphMinScore;

      // Auto-scale Y axis: 5% top padding, 5% bottom padding, never clamp to zero
      paddedMinScore := graphMinScore - scoreRange * 0.05;
      if paddedMinScore < 0 then paddedMinScore := 0;
      paddedRange := graphMaxScore - paddedMinScore;
      // Enforce a minimum range (~5% of max) so tiny score diffs don't exaggerate bar heights
      if paddedRange < graphMaxScore * 0.05 then begin
        paddedRange := graphMaxScore * 0.05;
        paddedMinScore := graphMaxScore - paddedRange;
      end;
      if paddedRange < 1.0 then paddedRange := 1.0;

      // Baseline Y (bottom of bars)
      baseY := graphY + graphH - 1.8 * charHeight;
      plotTop := graphY + 1.8 * charHeight;
      plotH := baseY - plotTop;

    // Draw horizontal axis line
    app.TextOverlay.AddBox(leftColX1 + 2.0 * charWidth, baseY, graphW - 4.0 * charWidth, 0.06 * charHeight,
                           70.0/255.0, 80.0/255.0, 100.0/255.0, 0.4,
                           70.0/255.0, 80.0/255.0, 100.0/255.0, 0.4, 255.0);

    // Optional: horizontal grid line at mid-range
    app.TextOverlay.AddBox(leftColX1 + 2.0 * charWidth, plotTop + plotH * 0.5, graphW - 4.0 * charWidth, 0.03 * charHeight,
                           70.0/255.0, 80.0/255.0, 100.0/255.0, 0.2,
                           70.0/255.0, 80.0/255.0, 100.0/255.0, 0.2, 255.0);

      // Draw vertical bars for each history entry
      barW := (graphW - 4.0 * charWidth) / fHistoryCount * 0.6;
      for graphIdx := 0 to fHistoryCount - 1 do begin
       historyIdx := fHistoryCount - 1 - graphIdx; // oldest first, newest last
       barX := leftColX1 + 2.0 * charWidth + (graphIdx + 0.5) * ((graphW - 4.0 * charWidth) / fHistoryCount) - barW * 0.5;
       barTopH := ((fHistory[historyIdx].TotalScore - paddedMinScore) / paddedRange) * plotH;
       if barTopH < 2.0 then barTopH := 2.0;

       // Bar fill (cyan for latest = rightmost, muted for older)
       if historyIdx = 0 then
        app.TextOverlay.AddBox(barX, baseY - barTopH, barW, barTopH,
                               48.0/255.0, 190.0/255.0, 240.0/255.0, 0.85,
                               48.0/255.0, 190.0/255.0, 240.0/255.0, 0.85, 255.0)
       else
        app.TextOverlay.AddBox(barX, baseY - barTopH, barW, barTopH,
                               70.0/255.0, 80.0/255.0, 100.0/255.0, 0.6,
                               70.0/255.0, 80.0/255.0, 100.0/255.0, 0.6, 255.0);

       // Test label below bar: "Test N" instead of just "N"
       app.TextOverlay.AddText(barX + barW * 0.5, baseY + 0.3 * charHeight, 0.65, toaCenter, 'Test ' + IntToStr(graphIdx + 1),
                               1.0, 1.0, 1.0, 0.0, 179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);

       // Score label on top of bar
       // Always show for the latest test (historyIdx = 0); for older tests only if enough height
       if (historyIdx = 0) or (barTopH > 1.5 * charHeight) then begin
        // Place label above bar top to avoid overlapping axis label when bar is tiny
        if barTopH > 1.5 * charHeight then
         app.TextOverlay.AddText(barX + barW * 0.5, baseY - barTopH + 0.4 * charHeight, 0.55, toaCenter, FormatScoreValue(fHistory[historyIdx].TotalScore),
                                 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        else
         app.TextOverlay.AddText(barX + barW * 0.5, baseY - barTopH - 0.4 * charHeight, 0.55, toaCenter, FormatScoreValue(fHistory[historyIdx].TotalScore),
                                 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0);
       end;
      end;

    // Hover detail popup for Score Trend
     if fHoveredHistoryIdx >= 0 then begin
      popupW := 28.0 * charWidth;
      popupH := 5.0 * charHeight;
      popupX := cx - popupW * 0.5;
      popupY := graphY + graphH * 0.5 - popupH * 0.5;
      if popupY < graphY + 0.5 * charHeight then popupY := graphY + 0.5 * charHeight;

     // Popup background
     app.TextOverlay.AddBox(popupX, popupY, popupW, popupH,
                            22.0/255.0, 25.0/255.0, 37.0/255.0, 0.95,
                            48.0/255.0, 190.0/255.0, 240.0/255.0, 0.6,
                            255.0);

     // Title
     app.TextOverlay.AddText(popupX + popupW * 0.5, popupY + 0.4 * charHeight, 0.8, toaCenter,
                              'Run #' + IntToStr(fHistoryCount - fHoveredHistoryIdx) + ' Details',
                             1.0, 1.0, 1.0, 0.0, 48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);

     // Details
      detailStr := 'Total: ' + FormatScoreValue(fHistory[fHoveredHistoryIdx].TotalScore);
     app.TextOverlay.AddText(popupX + 1.5 * charWidth, popupY + 1.4 * charHeight, 0.7, toaLeft, detailStr,
                             1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0);

     detailStr := 'CPU ST: ' + FormatScoreValue(fHistory[fHoveredHistoryIdx].PhaseResults[1].Score) +
                  '  MT: ' + FormatScoreValue(fHistory[fHoveredHistoryIdx].PhaseResults[2].Score);
     app.TextOverlay.AddText(popupX + 1.5 * charWidth, popupY + 2.2 * charHeight, 0.65, toaLeft, detailStr,
                             1.0, 1.0, 1.0, 0.0, 179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);

      detailStr := 'GPU 1080p: ' + FormatScoreValue(fHistory[fHoveredHistoryIdx].PhaseResults[3].Score);
      app.TextOverlay.AddText(popupX + 1.5 * charWidth, popupY + 2.9 * charHeight, 0.65, toaLeft, detailStr,
                              1.0, 1.0, 1.0, 0.0, 179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);

      detailStr := 'Kernel: ' + fHistory[fHoveredHistoryIdx].KernelVersion;
      app.TextOverlay.AddText(popupX + 1.5 * charWidth, popupY + 3.6 * charHeight, 0.6, toaLeft, detailStr,
                              1.0, 1.0, 1.0, 0.0, 150.0/255.0, 155.0/255.0, 170.0/255.0, 1.0);

      detailStr := 'Driver: ' + fHistory[fHoveredHistoryIdx].DriverVersion;
      app.TextOverlay.AddText(popupX + 1.5 * charWidth, popupY + 4.2 * charHeight, 0.6, toaLeft, detailStr,
                              1.0, 1.0, 1.0, 0.0, 150.0/255.0, 155.0/255.0, 170.0/255.0, 1.0);
    end;
   end;

   // --- Hardware Comparison title (right column) ---
   app.TextOverlay.AddText(rightColX1 + 2.5 * charWidth, hwCardY + 0.94 * charHeight, 1.2, toaLeft, 'Hardware Comparison', 1.0, 1.0, 1.0, 0.0, 48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 1.0);

    HWRefs[0].Name := 'Raspberry Pi 5'; HWRefs[0].Score := 400; HWRefs[0].IsCurrent := false;
    HWRefs[0].Specs := 'CPU: BCM2712 4C | RAM: 8GB LPDDR4X | GPU: VideoCore VII | OS: Raspberry Pi OS';
    HWRefs[1].Name := 'Steam Machine'; HWRefs[1].Score := 2087; HWRefs[1].IsCurrent := false;
    HWRefs[1].Specs := 'CPU: AMD Zen 4 6C/12T 4.8GHz | RAM: 16GB DDR5 | GPU: AMD RDNA3 28CU 8GB GDDR6 2.45GHz | OS: SteamOS';
    HWRefs[2].Name := 'Nintendo Switch 2'; HWRefs[2].Score := 750; HWRefs[2].IsCurrent := false;
    HWRefs[2].Specs := 'CPU: Cortex-A78C 8C | RAM: 12GB LPDDR5X | GPU: Ampere 768 | OS: Horizon';
    HWRefs[3].Name := 'Steam Deck'; HWRefs[3].Score := 818; HWRefs[3].IsCurrent := false;
    HWRefs[3].Specs := 'CPU: Zen 2 4C/8T | RAM: 16GB LPDDR5 | GPU: RDNA2 8CU | OS: SteamOS';
    HWRefs[4].Name := 'ROG Ally X'; HWRefs[4].Score := 1212; HWRefs[4].IsCurrent := false;
    HWRefs[4].Specs := 'CPU: Z1 Extreme | RAM: 24GB LPDDR5X | GPU: RDNA3 12CU | OS: Win11';
    HWRefs[5].Name := 'Entry Gamer PC'; HWRefs[5].Score := 1580; HWRefs[5].IsCurrent := false;
    HWRefs[5].Specs := 'CPU: i3 12100F | RAM: 16GB DDR4 | GPU: RX 6600 8GB | OS: Win11';
    HWRefs[6].Name := 'PlayStation 5';     HWRefs[6].Score := 1800; HWRefs[6].IsCurrent := false;
    HWRefs[6].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 36CU | OS: Custom OS';
    HWRefs[7].Name := 'XBOX Series X';     HWRefs[7].Score := 2000; HWRefs[7].IsCurrent := false;
    HWRefs[7].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA2 52CU | OS: Custom OS';
    HWRefs[8].Name := 'PlayStation 5 Pro';     HWRefs[8].Score := 2700; HWRefs[8].IsCurrent := false;
    HWRefs[8].Specs := 'CPU: Zen 2 8C/16T | RAM: 16GB GDDR6 | GPU: RDNA3 60CU | OS: Custom OS';
    HWRefs[9].Name := 'Mid-Range Gamer PC';     HWRefs[9].Score := 2898; HWRefs[9].IsCurrent := false;
    HWRefs[9].Specs := 'CPU: R5 7600 | RAM: 32GB DDR5 | GPU: RTX 4060 Ti | OS: Win11';
    HWRefs[10].Name := 'High-End Gamer PC';     HWRefs[10].Score := 8062; HWRefs[10].IsCurrent := false;
    HWRefs[10].Specs := 'CPU: R9 9950X3D | RAM: 48GB DDR5 | GPU: RTX 5090 | OS: CachyOS';
    HWRefs[11].Name := 'Current System'; HWRefs[11].Score := fCurrentResult.TotalScore; HWRefs[11].IsCurrent := true;
    HWRefs[11].Specs := 'CPU: ' + GetCPUName + ' | RAM: ' + GetRAMSize + ' | GPU: ' + CleanGPUName(fCurrentResult.DeviceName) + ' | OS: ' + GetOSName;

    scaleFactor := 1.0;

    // Ordenar decrescente por pontuacao
    for i := 0 to 10 do begin
     for j := i + 1 to 11 do begin
      if HWRefs[i].Score < HWRefs[j].Score then begin
       TempHW := HWRefs[i];
       HWRefs[i] := HWRefs[j];
       HWRefs[j] := TempHW;
      end;
     end;
    end;

    MaxScore := HWRefs[0].Score;
    if MaxScore = 0 then MaxScore := 1;

    // Find Current System index and always keep it expanded
    for i := 0 to 11 do begin
     if HWRefs[i].IsCurrent then begin
      fHWExpandProgress[i] := 1.0;
      Break;
     end;
    end;

     itemY := hwCardY + 3.5 * charHeight;

    for i := 0 to 11 do begin
     isHovered := (fHoveredHardwareIdx = i);
     itemH := 2.6 * charHeight + 1.6 * charHeight * fHWExpandProgress[i];

     // Hover background highlight (subtle cyan glow)
     if isHovered then begin
      app.TextOverlay.AddBox(rightColX1 + 1.0 * charWidth,
                              itemY - 0.1 * charHeight,
                              rightColWidth - 2.0 * charWidth,
                              itemH,
                              48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 0.07,
                              48.0 / 255.0, 190.0 / 255.0, 240.0 / 255.0, 0.07,
                              255.0);
     end;

     // Determine colors: Current > Selected (expanded) > Hover > Normal
     if HWRefs[i].IsCurrent then begin
      nameR := 48.0 / 255.0;  nameG := 190.0 / 255.0; nameB := 240.0 / 255.0;
      scoreR := 48.0 / 255.0; scoreG := 190.0 / 255.0; scoreB := 240.0 / 255.0;
      barR := 48.0 / 255.0;   barG := 190.0 / 255.0;  barB := 240.0 / 255.0;  barA := 1.0;
     end else if (fExpandedHardwareIdx = i) then begin
      // Selected / expanded item: slightly brighter for comparison
      nameR := 210.0 / 255.0;  nameG := 215.0 / 255.0; nameB := 225.0 / 255.0;
      scoreR := 210.0 / 255.0; scoreG := 215.0 / 255.0; scoreB := 225.0 / 255.0;
      barR := 130.0 / 255.0;   barG := 145.0 / 255.0;  barB := 165.0 / 255.0; barA := 0.95;
     end else if isHovered then begin
      nameR := 1.0;  nameG := 1.0;  nameB := 1.0;
      scoreR := 1.0; scoreG := 1.0; scoreB := 1.0;
      barR := 120.0 / 255.0; barG := 135.0 / 255.0; barB := 155.0 / 255.0; barA := 0.95;
     end else begin
      nameR := 180.0 / 255.0;  nameG := 185.0 / 255.0; nameB := 200.0 / 255.0;
      scoreR := 180.0 / 255.0; scoreG := 185.0 / 255.0; scoreB := 200.0 / 255.0;
      barR := 75.0 / 255.0;    barG := 85.0 / 255.0;  barB := 105.0 / 255.0; barA := 0.75;
     end;

     // --- Linha 1: Nome (esquerda) + Pontuacao (direita) ---
     app.TextOverlay.AddText(rightColX1 + 2.5 * charWidth, itemY, 1.0, toaLeft, HWRefs[i].Name, 1.0, 1.0, 1.0, 0.0, nameR, nameG, nameB, 1.0);

    hwScoreStr := FormatScoreValue(HWRefs[i].Score) + ' points';
    app.TextOverlay.AddText(rightColX1 + rightColWidth - 2.5 * charWidth, itemY, 1.0, toaRight, hwScoreStr, 1.0, 1.0, 1.0, 0.0, scoreR, scoreG, scoreB, 1.0);

    // --- Linha 2: Barra fina moderna ---
    barStartX := rightColX1 + 2.5 * charWidth;
    maxBarWidth := rightColWidth - 5.0 * charWidth;
    barWidth := (HWRefs[i].Score / MaxScore) * maxBarWidth;
    if barWidth < 2.0 then barWidth := 2.0;

    barHeight := 0.18 * charHeight;
    barY := itemY + 1.1 * charHeight;

    // Background track
    app.TextOverlay.AddBox(barStartX, barY, maxBarWidth, barHeight,
                           22.0 / 255.0, 25.0 / 255.0, 37.0 / 255.0, 0.8,
                           50.0 / 255.0, 60.0 / 255.0, 85.0 / 255.0, 0.6,
                           255.0);
    // Fill
    app.TextOverlay.AddBox(barStartX, barY, barWidth, barHeight, barR, barG, barB, barA, barR, barG, barB, barA, 255.0);

    // --- Linha 3: Especificacoes (accordion com fade) ---
    if fHWExpandProgress[i] > 0.01 then begin
     app.TextOverlay.AddText(rightColX1 + 2.5 * charWidth,
                             itemY + 1.65 * charHeight,
                             0.6,
                             toaLeft,
                             HWRefs[i].Specs,
                             1.0, 1.0, 1.0, 0.0,
                             179.0 / 255.0, 179.0 / 255.0, 179.0 / 255.0, fHWExpandProgress[i]
                            );
    end;

    itemY := itemY + itemH;
   end;

  // --- BOTTOM BUTTON BAR ---
  yText := 1080.0 - 55.0;
  paddingX := charWidth * 1.5;
  paddingY := charHeight * 0.4;
  btnHeight := (charHeight * 1.8) + (2.0 * paddingY);

  returnBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
  clearBtnWidth := (14.0 * charWidth * 1.6) + (2.0 * paddingX);
  gap := 4.0 * charWidth;
  btnY := yText - paddingY;

  if fSubmitStatus = 4 then begin
    // 2-button layout: Return to Menu and Clear results
    groupWidth := returnBtnWidth + gap + clearBtnWidth;
    groupX := cx - (groupWidth * 0.5);

    // --- RETURN TO MENU BUTTON ---
    isReturnHovered := IsReturnButtonHovered(fLastMousePosition);
    if isReturnHovered then begin
      bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
      fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
      fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
      textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
    end;

    returnBtnX := groupX;
    app.TextOverlay.AddBox(returnBtnX, btnY, returnBtnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(returnBtnX + returnBtnWidth * 0.5, yText, 1.8, toaCenter, 'Return to Menu', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

    // --- CLEAR RESULTS BUTTON ---
    isClearHovered := IsClearButtonHovered(fLastMousePosition);
    if isClearHovered then begin
      bgR := 160.0 / 255.0; bgG := 60.0 / 255.0; bgB := 60.0 / 255.0; bgA := 1.0;
      fgR := 200.0 / 255.0; fgG := 90.0 / 255.0; fgB := 90.0 / 255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 120.0 / 255.0; bgG := 40.0 / 255.0; bgB := 40.0 / 255.0; bgA := 1.0;
      fgR := 160.0 / 255.0; fgG := 60.0 / 255.0; fgB := 60.0 / 255.0; fgA := 1.0;
      textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
    end;

    clearBtnX := groupX + returnBtnWidth + gap;
    app.TextOverlay.AddBox(clearBtnX, btnY, clearBtnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(clearBtnX + clearBtnWidth * 0.5, yText, 1.8, toaCenter, 'Clear results', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
  end else begin
    // 3-button layout: Return to Menu, Submit results (with status), and Clear results
    submitBtnWidth := (14.0 * charWidth * 1.8) + (2.0 * paddingX);
    groupWidth := returnBtnWidth + gap + submitBtnWidth + gap + clearBtnWidth;
    groupX := cx - (groupWidth * 0.5);

    // --- RETURN TO MENU BUTTON ---
    isReturnHovered := IsReturnButtonHovered(fLastMousePosition);
    if isReturnHovered then begin
      bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
      fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
      fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
      textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
    end;

    returnBtnX := groupX;
    app.TextOverlay.AddBox(returnBtnX, btnY, returnBtnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(returnBtnX + returnBtnWidth * 0.5, yText, 1.8, toaCenter, 'Return to Menu', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

    // --- SUBMIT RESULTS BUTTON ---
    submitBtnX := groupX + returnBtnWidth + gap;
    isSubmitHovered := IsSubmitButtonHovered(fLastMousePosition);

    case fSubmitStatus of
      0: begin
        submitStr := 'Submit results';
        if isSubmitHovered then begin
          bgR := 33.0 / 255.0; bgG := 38.0 / 255.0; bgB := 56.0 / 255.0; bgA := 1.0;
          fgR := 48.0 / 255.0; fgG := 190.0 / 255.0; fgB := 240.0 / 255.0; fgA := 1.0;
          textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
        end else begin
          bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
          fgR := 50.0 / 255.0; fgG := 60.0 / 255.0; fgB := 85.0 / 255.0; fgA := 1.0;
          textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
        end;
      end;
      1: begin
        submitStr := 'Submitting...';
        bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
        fgR := 200.0 / 255.0; fgG := 150.0 / 255.0; fgB := 30.0 / 255.0; fgA := 1.0;
        textR := 200.0 / 255.0; textG := 150.0 / 255.0; textB := 30.0 / 255.0; textA := 1.0;
      end;
      2: begin
        submitStr := 'Submitted!';
        bgR := 20.0 / 255.0; bgG := 60.0 / 255.0; bgB := 30.0 / 255.0; bgA := 1.0;
        fgR := 48.0 / 255.0; fgG := 200.0 / 255.0; fgB := 100.0 / 255.0; fgA := 1.0;
        textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
      end;
      3: begin
        submitStr := 'Error! Retry?';
        if isSubmitHovered then begin
          bgR := 160.0 / 255.0; bgG := 60.0 / 255.0; bgB := 60.0 / 255.0; bgA := 1.0;
          fgR := 200.0 / 255.0; fgG := 90.0 / 255.0; fgB := 90.0 / 255.0; fgA := 1.0;
          textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
        end else begin
          bgR := 22.0 / 255.0; bgG := 25.0 / 255.0; bgB := 37.0 / 255.0; bgA := 1.0;
          fgR := 160.0 / 255.0; fgG := 60.0 / 255.0; fgB := 60.0 / 255.0; fgA := 1.0;
          textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
        end;
      end;
    end;

    app.TextOverlay.AddBox(submitBtnX, btnY, submitBtnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(submitBtnX + submitBtnWidth * 0.5, yText, 1.8, toaCenter, submitStr, 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

    // --- CLEAR RESULTS BUTTON ---
    isClearHovered := IsClearButtonHovered(fLastMousePosition);
    if isClearHovered then begin
      bgR := 160.0 / 255.0; bgG := 60.0 / 255.0; bgB := 60.0 / 255.0; bgA := 1.0;
      fgR := 200.0 / 255.0; fgG := 90.0 / 255.0; fgB := 90.0 / 255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 120.0 / 255.0; bgG := 40.0 / 255.0; bgB := 40.0 / 255.0; bgA := 1.0;
      fgR := 160.0 / 255.0; fgG := 60.0 / 255.0; fgB := 60.0 / 255.0; fgA := 1.0;
      textR := 221.0 / 255.0; textG := 221.0 / 255.0; textB := 221.0 / 255.0; textA := 1.0;
    end;

    clearBtnX := groupX + returnBtnWidth + gap + submitBtnWidth + gap;
    app.TextOverlay.AddBox(clearBtnX, btnY, clearBtnWidth, btnHeight, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(clearBtnX + clearBtnWidth * 0.5, yText, 1.8, toaCenter, 'Clear results', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
  end;

  // --- CLEAR CONFIRMATION DIALOG ---
  if fClearConfirmPending then begin
    // Dim background
    app.TextOverlay.AddBox(0, 0, 1920.0, 1080.0,
                           0.0, 0.0, 0.0, 0.6,
                           0.0, 0.0, 0.0, 0.0, 255.0);

    // Dialog box
    boxW := 32.0 * charWidth;
    boxH := 7.0 * charHeight;
    boxX := cx - boxW * 0.5;
    boxY := cy - boxH * 0.5;
    app.TextOverlay.AddBox(boxX, boxY, boxW, boxH,
                           22.0/255.0, 25.0/255.0, 37.0/255.0, 0.95,
                           48.0/255.0, 190.0/255.0, 240.0/255.0, 0.6,
                           255.0);

    // Title
    app.TextOverlay.AddText(cx, boxY + 1.0 * charHeight, 1.0, toaCenter,
                            'Clear benchmark history',
                            0.0, 0.0, 0.0, 0.0,
                            1.0, 1.0, 1.0, 1.0);

    // Message
    app.TextOverlay.AddText(cx, boxY + 2.4 * charHeight, 0.75, toaCenter,
                            'This will permanently delete all results.',
                            0.0, 0.0, 0.0, 0.0,
                            179.0/255.0, 179.0/255.0, 179.0/255.0, 1.0);

    // Yes / No buttons
    gap := 3.0 * charWidth;
    btnW := 10.0 * charWidth;
    btnH := 2.2 * charHeight;
    yesX := cx - gap * 0.5 - btnW;
    noX := cx + gap * 0.5;
    btnY := boxY + boxH - btnH - 1.2 * charHeight;

    // Yes button
    if fClearConfirmHovered = 1 then begin
      bgR := 56.0/255.0; bgG := 33.0/255.0; bgB := 33.0/255.0; bgA := 1.0;
      fgR := 240.0/255.0; fgG := 80.0/255.0; fgB := 80.0/255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0/255.0; bgG := 25.0/255.0; bgB := 37.0/255.0; bgA := 1.0;
      fgR := 85.0/255.0; fgG := 50.0/255.0; fgB := 50.0/255.0; fgA := 1.0;
      textR := 221.0/255.0; textG := 221.0/255.0; textB := 221.0/255.0; textA := 1.0;
    end;
    app.TextOverlay.AddBox(yesX, btnY, btnW, btnH, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(yesX + btnW * 0.5, btnY + btnH * 0.5, 1.0, toaCenter,
                            'Yes', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

    // No button
    if fClearConfirmHovered = 2 then begin
      bgR := 33.0/255.0; bgG := 38.0/255.0; bgB := 56.0/255.0; bgA := 1.0;
      fgR := 48.0/255.0; fgG := 190.0/255.0; fgB := 240.0/255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0/255.0; bgG := 25.0/255.0; bgB := 37.0/255.0; bgA := 1.0;
      fgR := 50.0/255.0; fgG := 60.0/255.0; fgB := 85.0/255.0; fgA := 1.0;
      textR := 221.0/255.0; textG := 221.0/255.0; textB := 221.0/255.0; textA := 1.0;
    end;
    app.TextOverlay.AddBox(noX, btnY, btnW, btnH, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(noX + btnW * 0.5, btnY + btnH * 0.5, 1.0, toaCenter,
                            'No', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
  end;

  // --- SUBMIT CONFIRMATION DIALOG ---
  if fSubmitConfirmPending then begin
    nickname := ReadPasCubeNickname(prompted);
    if nickname = '' then nickname := 'Anonymous';
    // Dim background
    app.TextOverlay.AddBox(0, 0, 1920.0, 1080.0,
                           0.0, 0.0, 0.0, 0.6,
                           0.0, 0.0, 0.0, 0.0, 255.0);

    // Dialog box
    boxW := 66.0 * charWidth;
    boxH := 36.0 * charHeight;
    boxX := cx - boxW * 0.5;
    boxY := cy - boxH * 0.5;
    app.TextOverlay.AddBox(boxX, boxY, boxW, boxH,
                           22.0/255.0, 25.0/255.0, 37.0/255.0, 0.95,
                           48.0/255.0, 190.0/255.0, 240.0/255.0, 0.6,
                           255.0);

    // Title
    app.TextOverlay.AddText(cx, boxY + 1.0 * charHeight, 1.4, toaCenter,
                            'Submit benchmark results',
                            0.0, 0.0, 0.0, 0.0,
                            48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);

    // Prompt
    app.TextOverlay.AddText(cx, boxY + 2.2 * charHeight, 0.9, toaCenter,
                            'Do you want to submit the following anonymous data?',
                            0.0, 0.0, 0.0, 0.0,
                            221.0/255.0, 221.0/255.0, 221.0/255.0, 1.0);

    // System Information
    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 3.4 * charHeight, 0.9, toaLeft, 'CPU:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 3.4 * charHeight, 0.9, toaLeft, GetCPUName, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 4.6 * charHeight, 0.9, toaLeft, 'GPU:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 4.6 * charHeight, 0.9, toaLeft, CleanGPUName(fCurrentResult.DeviceName), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 5.8 * charHeight, 0.9, toaLeft, 'VRAM:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 5.8 * charHeight, 0.9, toaLeft, GetVRAMSize, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 7.0 * charHeight, 0.9, toaLeft, 'RAM:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 7.0 * charHeight, 0.9, toaLeft, GetRAMSize, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 8.2 * charHeight, 0.9, toaLeft, 'Video Driver:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 8.2 * charHeight, 0.9, toaLeft, GetDriverVersion, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 9.4 * charHeight, 0.9, toaLeft, 'OS:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 9.4 * charHeight, 0.9, toaLeft, GetOSName, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 10.6 * charHeight, 0.9, toaLeft, 'Kernel:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 10.6 * charHeight, 0.9, toaLeft, GetKernelVersion, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 11.8 * charHeight, 0.9, toaLeft, 'Main Score:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 11.8 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.TotalScore) + ' points', 0.0, 0.0, 0.0, 0.0, 48.0/255.0, 190.0/255.0, 240.0/255.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 13.0 * charHeight, 0.9, toaLeft, 'CPU Single:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 13.0 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.PhaseResults[1].Score), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 14.2 * charHeight, 0.9, toaLeft, 'CPU Multi:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 14.2 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.PhaseResults[2].Score), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 15.4 * charHeight, 0.9, toaLeft, 'GPU Score:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 15.4 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.PhaseResults[3].Score), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 16.6 * charHeight, 0.9, toaLeft, 'Contributor:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 16.6 * charHeight, 0.9, toaLeft, nickname, 0.0, 0.0, 0.0, 0.0, 48.0/255.0, 200.0/255.0, 100.0/255.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 17.8 * charHeight, 0.9, toaLeft, 'Client ID:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 17.8 * charHeight, 0.9, toaLeft, Copy(GetPersistentUUID, 1, 8), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 19.0 * charHeight, 0.9, toaLeft, 'Architecture:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 19.0 * charHeight, 0.9, toaLeft, GetCPUArchitecture, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 20.2 * charHeight, 0.9, toaLeft, 'Package:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 20.2 * charHeight, 0.9, toaLeft, GetPackageType, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 21.4 * charHeight, 0.9, toaLeft, 'Timer:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 21.4 * charHeight, 0.9, toaLeft, IntToStr(Round(fCurrentResult.BenchmarkDuration)) + ' seconds', 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 22.6 * charHeight, 0.9, toaLeft, 'Display Server:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 22.6 * charHeight, 0.9, toaLeft, fCurrentResult.DisplayServer, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 23.8 * charHeight, 0.9, toaLeft, 'Resolution/Rate:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 23.8 * charHeight, 0.9, toaLeft, fCurrentResult.DisplayResolution + ' @ ' + fCurrentResult.RefreshRate, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 25.0 * charHeight, 0.9, toaLeft, 'Desktop Env:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 25.0 * charHeight, 0.9, toaLeft, fCurrentResult.DesktopEnvironment, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 26.2 * charHeight, 0.9, toaLeft, 'Storage Type:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 26.2 * charHeight, 0.9, toaLeft, fCurrentResult.StorageType, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 27.4 * charHeight, 0.9, toaLeft, 'Vulkan Driver:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 27.4 * charHeight, 0.9, toaLeft, fCurrentResult.VulkanDriver, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 28.6 * charHeight, 0.9, toaLeft, 'CPU Max Freq:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 28.6 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.CPUMaxFreq) + ' MHz', 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    app.TextOverlay.AddText(boxX + 3.5 * charWidth, boxY + 29.8 * charHeight, 0.9, toaLeft, 'GPU Max Freq:', 0.0, 0.0, 0.0, 0.0, 150.0/255.0, 150.0/255.0, 170.0/255.0, 1.0);
    app.TextOverlay.AddText(boxX + 22.0 * charWidth, boxY + 29.8 * charHeight, 0.9, toaLeft, IntToStr(fCurrentResult.GPUMaxFreq) + ' MHz', 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

    // Buttons
    gap := 5.0 * charWidth;
    btnW := 15.0 * charWidth;
    btnH := 2.5 * charHeight;
    yesX := cx - gap * 0.5 - btnW;
    noX := cx + gap * 0.5;
    btnY := boxY + boxH - btnH - 1.2 * charHeight;

    // Yes button
    if fSubmitConfirmHovered = 1 then begin
      bgR := 33.0/255.0; bgG := 38.0/255.0; bgB := 56.0/255.0; bgA := 1.0;
      fgR := 48.0/255.0; fgG := 190.0/255.0; fgB := 240.0/255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0/255.0; bgG := 25.0/255.0; bgB := 37.0/255.0; bgA := 1.0;
      fgR := 50.0/255.0; fgG := 60.0/255.0; fgB := 85.0/255.0; fgA := 1.0;
      textR := 221.0/255.0; textG := 221.0/255.0; textB := 221.0/255.0; textA := 1.0;
    end;
    app.TextOverlay.AddBox(yesX, btnY, btnW, btnH, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(yesX + btnW * 0.5, btnY + btnH * 0.5, 1.1, toaCenter,
                            'Yes', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);

    // No button
    if fSubmitConfirmHovered = 2 then begin
      bgR := 33.0/255.0; bgG := 38.0/255.0; bgB := 56.0/255.0; bgA := 1.0;
      fgR := 48.0/255.0; fgG := 190.0/255.0; fgB := 240.0/255.0; fgA := 1.0;
      textR := 1.0; textG := 1.0; textB := 1.0; textA := 1.0;
    end else begin
      bgR := 22.0/255.0; bgG := 25.0/255.0; bgB := 37.0/255.0; bgA := 1.0;
      fgR := 50.0/255.0; fgG := 60.0/255.0; fgB := 85.0/255.0; fgA := 1.0;
      textR := 221.0/255.0; textG := 221.0/255.0; textB := 221.0/255.0; textA := 1.0;
    end;
    app.TextOverlay.AddBox(noX, btnY, btnW, btnH, bgR, bgG, bgB, bgA, fgR, fgG, fgB, fgA, 255.0);
    app.TextOverlay.AddText(noX + btnW * 0.5, btnY + btnH * 0.5, 1.1, toaCenter,
                            'No', 0.0, 0.0, 0.0, 0.0, textR, textG, textB, textA);
  end;
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
