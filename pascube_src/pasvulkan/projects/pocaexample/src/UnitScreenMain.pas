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

{$ifdef fpc}
 {$optimization level1}
{$ifend}

{$undef WithConsole}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PUCU,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.HighResolutionTimer,
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont,
     POCA,
     PasVulkan.POCA,
     PasVulkan.Console;

type { TScreenMain }

     TScreenMain=class(TpvApplicationScreen)
      public
       const FontWidth=8;
             FontHeight=16;
             ScreenWidth=640;
             ScreenHeight=400;
             CanvasWidth=ScreenWidth*4;
             CanvasHeight=ScreenHeight*4;
             CountMemoryUsageItems=1024;
             MemoryUsageItemMask=CountMemoryUsageItems-1;
             GarbageCollectorFullInterval=10;
       type TMemoryUsageItem=record
             Time:TpvDouble;
             POCAAllocated:TpvInt64;
             POCAFreeCount:TpvInt64;
            end;
            PMemoryUsageItem=^TMemoryUsageItem;
            TMemoryUsageItems=array[0..CountMemoryUsageItems-1] of TMemoryUsageItem;
            PMemoryUsageItems=^TMemoryUsageItems;
      private
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanCommandPool:TpvVulkanCommandPool;
       fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fVulkanSpriteAtlas:TpvSpriteAtlas;
       fVulkanFontSpriteAtlas:TpvSpriteAtlas;
       fVulkanCanvas:TpvCanvas;
       fVulkanFont:TpvFont;
       fReady:boolean;
{$ifdef WithConsole}
       fConsole:TpvConsole;
{$endif}
       fPOCAInstance:PPOCAInstance;
       fPOCAContext:PPOCAContext;
       fPOCACode:PPOCACode;
       fPOCAUserIOWriteBuffer:TpvUTF8String;
       fPOCAVulkanCanvas:TPOCAValue;
       fInputEventHash:TPOCAValue;
       fLastPOCAGarbageCollectTime:TpvHighResolutionTime;
       fNextPOCAFullGarbageCollectTime:TpvHighResolutionTime;
       fLastExpectedPOCAFullCycleCounter:TPOCAUInt64;
       fLastPOCAFullCycleCounter:TPOCAUInt64;
       fMemoryUsageItems:TMemoryUsageItems;
       fMemoryUsageItemIndex:TpvSizeInt;
       fMemoryUsageItemCount:TpvSizeInt;
       fMemUsageItemTimeAccumulator:TpvDouble;
       fMemUsageItemTime:TpvDouble;
       fCriticalSection:TPasMPCriticalSection;
       fOldFPS:TpvInt32;
       fFPSTimeAccumulator:TpvDouble;
       fFrameRateTimeAccumulator:TpvDouble;
       fPercentileXthFrameRate:TpvDouble;
       fMedianFrameTime:TpvDouble;
       fFrameTimeString:string;
       procedure POCAInitialize;
       procedure POCAGarbageCollect;
       function POCAProcessInputKeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):Boolean;
       function POCAProcessInputPointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):Boolean;
       function POCAProcessInputScrollEvent(const aRelativeAmount:TpvVector2):Boolean;
       procedure POCAExecute(const aCode:TpvUTF8String;const aFileName:TpvUTF8String);
       function POCACallFunction(const aFunction:TpvUTF8String;const aArguments:array of TPOCAValue;const aResultValue:PPOCAValue):Boolean;
       procedure CansoleOnSetDrawColor(const aColor:TpvVector4);
       procedure ConsoleOnDrawRect(const aX0,aY0,aX1,aY1:TpvFloat);
       procedure ConsoleOnDrawCodePoint(const aCodePoint:TpvUInt32;const aX,aY:TpvFloat);
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

       procedure Check(const aDeltaTime:TpvDouble); override;

       procedure Update(const aDeltaTime:TpvDouble); override;

       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;

     end;

var ScreenMain:TScreenMain=nil;

implementation

uses UnitApplication;

var StartTimeUTC:TDateTime=0.0;

function POCAUserModuleFunction(const aContext:PPOCAContext;const aModuleName:TPOCAUTF8String;out aModuleCode,aModuleFileName:TPOCAUTF8String;out aModuleDateTime:TDateTime):Boolean;
var Index:longint;
    Path,FileName:TPOCAUTF8String;
    Stream:TStream;
    ScreenMain:TScreenMain;
begin

 ScreenMain:=TScreenMain(aContext^.UserData);

 Path:='poca/';

 aModuleDateTime:=0.0;

 FileName:=Path+aModuleName;
 if pvApplication.Assets.ExistAsset(FileName) then begin
  Stream:=pvApplication.Assets.GetAssetStream(FileName);
  if assigned(Stream) then begin
   try
    aModuleCode:='';
    if Stream.Size>0 then begin
     SetLength(aModuleCode,Stream.Size);
     Stream.ReadBuffer(aModuleCode[1],Stream.Size);
    end;
    aModuleFileName:=FileName;
    FileName:=IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+FileName;
    if FileExists(FileName) then begin
{$if declared(FileAgeUTC)}
     if not FileAgeUTC(FileName,aModuleDateTime) then begin
      aModuleDateTime:=StartTimeUTC;
     end;
{$else}
     aModuleDateTime:=TFile.GetLastWriteTimeUtc(FileName);
{$ifend}
    end else begin
     aModuleDateTime:=StartTimeUTC;
    end;
    result:=true;
   finally
    FreeAndNil(Stream);
   end;
   exit;
  end;
 end;

 FileName:=Path+aModuleName+'.poca';
 if pvApplication.Assets.ExistAsset(FileName) then begin
  Stream:=pvApplication.Assets.GetAssetStream(FileName);
  if assigned(Stream) then begin
   try
    aModuleCode:='';
    if Stream.Size>0 then begin
     SetLength(aModuleCode,Stream.Size);
     Stream.ReadBuffer(aModuleCode[1],Stream.Size);
    end;
    aModuleFileName:=FileName;
    FileName:=IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+FileName;
    if FileExists(FileName) then begin
{$if declared(FileAgeUTC)}
     if not FileAgeUTC(FileName,aModuleDateTime) then begin
      aModuleDateTime:=StartTimeUTC;
     end;
{$else}
     aModuleDateTime:=TFile.GetLastWriteTimeUtc(FileName);
{$ifend}
    end else begin
     aModuleDateTime:=StartTimeUTC;
    end;
    result:=true;
   finally
    FreeAndNil(Stream);
   end;
   exit;
  end;
 end;

 result:=false;

end;

procedure POCAUserIOWrite(const aContext:PPOCAContext;const aString:TPOCAUTF8String);
begin
 TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer:=TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer+aString;
end;

procedure POCAUserIOWriteLn(const aContext:PPOCAContext;const aString:TPOCAUTF8String);
begin
 TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer:=TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer+aString+#13#10;
end;

procedure POCAUserIOReadLn(const aContext:PPOCAContext;out aString:TPOCAUTF8String;out aNull:Boolean);
begin
 aString:='';
 aNull:=true;
end;

procedure POCAUserIOFlush(const aContext:PPOCAContext);
begin
 if length(TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer)>0 then begin
  TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer:=TrimRight(TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer);
  WriteLn(TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer);
  TScreenMain(aContext^.UserData).fPOCAUserIOWriteBuffer:='';
 end;
end;

function POCACanvasFunctionCREATECANVASFONTFROMGLOBAL(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var CanvasFont:TpvCanvasFont;
    Name:TpvUTF8String;
begin
 if aCountArguments>0 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  Name:='';
 end;
 CanvasFont:=TpvCanvasFont.Create;
 CanvasFont.VulkanFontSpriteAtlas:=nil; // Not needed here, because we use global assets
 if Name='vga' then begin
  CanvasFont.VulkanFont:=ScreenMain.fVulkanFont;
 end else begin
  CanvasFont.VulkanFont:=ScreenMain.fVulkanFont;
 end;
 result:=POCANewCanvasFont(aContext,CanvasFont);
end;

{ TScreenMain }

constructor TScreenMain.Create;
var Stream:TStream;
    StringData:TpvUTF8String;
begin

 inherited Create;

 ScreenMain:=self;

 fReady:=false;

 fCriticalSection:=TPasMPCriticalSection.Create;

 fNextPOCAFullGarbageCollectTime:=pvApplication.HighResolutionTimer.GetTime+(pvApplication.HighResolutionTimer.SecondInterval*GarbageCollectorFullInterval);

 fLastExpectedPOCAFullCycleCounter:=0;

 fLastPOCAFullCycleCounter:=0;

 fMemUsageItemTimeAccumulator:=1.0;

 fMemUsageItemTime:=0.0;

 fPOCAInstance:=POCAInstanceCreate;
 fPOCAInstance^.Globals.ModuleLoaderFunctions[0]:=POCAUserModuleFunction;

 fPOCAContext:=POCAContextCreate(fPOCAInstance);
 fPOCAContext^.UserData:=self;
 fPOCAContext^.UserIOWrite:=POCAUserIOWrite;
 fPOCAContext^.UserIOWriteLn:=POCAUserIOWriteLn;
 fPOCAContext^.UserIOReadLn:=POCAUserIOReadLn;
 fPOCAContext^.UserIOFlush:=POCAUserIOFlush;
 InitializeForPOCAContext(fPOCAContext);

 fInputEventHash:=POCANewInputEventHash(fPOCAContext);
 POCAHashSetString(fPOCAContext,fPOCAContext.Instance^.Globals.RootHash,'inputeventhash',fInputEventHash);

//fPOCACode:=POCACompile(fPOCAInstance,fPOCAContext,POCAGetFileContent(TPOCAUTF8String(FileName)),TPOCAUTF8String(FileName));

 fPOCAUserIOWriteBuffer:='';

 if pvApplication.Assets.ExistAsset('poca/main.poca') then begin
  Stream:=pvApplication.Assets.GetAssetStream('poca/main.poca');
  if assigned(Stream) then begin
   try
    if Stream.Size>0 then begin
     StringData:='';
     try
      SetLength(StringData,Stream.Size);
      Stream.ReadBuffer(StringData[1],Stream.Size);
      POCAExecute(StringData,'main.poca');
     finally
      StringData:='';
     end;
    end;
   finally
    FreeAndNil(Stream);
   end;
  end;
 end;

{$ifdef WithConsole}
 fConsole:=TpvConsole.Create;
 fConsole.SetChrDim(80,25);
 fConsole.WriteLine(#0#15'Console Test');
 fConsole.WriteLine('');
 fConsole.WriteLine(#0#14'This is just a test, so don''t worry! '#1);
 fConsole.WriteLine('');
 fConsole.WriteLine(#0#12'Use the '#0#14'"'#0#13'force'#0#14'"'#0#12' of this '#0#$9b'blinking-capable'#0#12' console!');
 fConsole.WriteLine('');
 fConsole.UpdateScreen;
{$endif}

 POCACallFunction('onApplicationCreate',[],nil);

end;

destructor TScreenMain.Destroy;
begin
 POCACallFunction('onApplicationDestroy',[],nil);
{$ifdef WithConsole}
 FreeAndNil(fConsole);
{$endif}
 FinalizeForPOCAContext(fPOCAContext);
 POCAContextDestroy(fPOCAContext);
 POCAInstanceDestroy(fPOCAInstance);
 FreeAndNil(fCriticalSection);
 ScreenMain:=nil;
 inherited Destroy;
end;

procedure TScreenMain.POCAInitialize;
var HostData:PPOCAHostData;
begin
 HostData:=PPOCAHostData(fPOCAContext.Instance^.Globals.HostData);
 HostData^.GraphicsQueue:=pvApplication.VulkanDevice.GraphicsQueue;
 HostData^.GraphicsCommandBuffer:=fVulkanGraphicsCommandBuffer;
 HostData^.GraphicsCommandBufferFence:=fVulkanGraphicsCommandBufferFence;
 HostData^.TransferQueue:=pvApplication.VulkanDevice.TransferQueue;
 HostData^.TransferCommandBuffer:=fVulkanTransferCommandBuffer;
 HostData^.TransferCommandBufferFence:=fVulkanTransferCommandBufferFence;
 POCAAddNativeFunction(fPOCAContext,HostData^.CanvasHash,'createCanvasFontFromGlobal',POCACanvasFunctionCREATECANVASFONTFROMGLOBAL);
end;

procedure TScreenMain.POCAGarbageCollect;
var ta,tb,t:TpvHighResolutionTime;
    MemoryUsageItem:PMemoryUsageItem;
begin

 fCriticalSection.Enter;
 try

  ta:=pvApplication.HighResolutionTimer.GetTime;

  if (fLastPOCAFullCycleCounter=fPOCAInstance.Globals.GarbageCollector.FullCycleCounter) and
     (pvApplication.HighResolutionTimer.GetTime>=fNextPOCAFullGarbageCollectTime) then begin
   POCAGarbageCollectorProcessFullCycle(fPOCAInstance);
  end else begin
   POCAGarbageCollectorProcessIncrementalCycle(fPOCAInstance);
  end;

  tb:=pvApplication.HighResolutionTimer.GetTime;

  t:=pvApplication.HighResolutionTimer.ToMilliseconds(tb-ta);
  if t>0 then begin
// Sleep(0);
  end;

  if fLastPOCAFullCycleCounter<>fPOCAInstance.Globals.GarbageCollector.FullCycleCounter then begin
   fLastPOCAFullCycleCounter:=fPOCAInstance.Globals.GarbageCollector.FullCycleCounter;
   fNextPOCAFullGarbageCollectTime:=pvApplication.HighResolutionTimer.GetTime+(pvApplication.HighResolutionTimer.SecondInterval*GarbageCollectorFullInterval);
   POCAResetTemporarySaves(fPOCAContext);
  end;

  fMemUsageItemTimeAccumulator:=fMemUsageItemTimeAccumulator+(pvApplication.DeltaTime*60.0);
  if fMemUsageItemTimeAccumulator>=1.0 then begin
   fMemUsageItemTimeAccumulator:=frac(fMemUsageItemTimeAccumulator);
   fMemoryUsageItemIndex:=(fMemoryUsageItemIndex+1) and MemoryUsageItemMask;
   MemoryUsageItem:=@fMemoryUsageItems[fMemoryUsageItemIndex and MemoryUsageItemMask];
   MemoryUsageItem^.Time:=fMemUsageItemTime;
   MemoryUsageItem^.POCAAllocated:=fPOCAInstance.Globals.GarbageCollector.Allocated;
   MemoryUsageItem^.POCAFreeCount:=fPOCAInstance.Globals.GarbageCollector.FreeCount;
  end;
  fMemUsageItemTime:=fMemUsageItemTime+pvApplication.DeltaTime;

  fLastPOCAGarbageCollectTime:=pvApplication.HighResolutionTimer.GetTime;

 finally
  fCriticalSection.Leave;
 end;

end;

procedure TScreenMain.POCAExecute(const aCode:TpvUTF8String;const aFileName:TpvUTF8String);
var Line:TpvUTF8String;
    POCACode,POCAValue:TPOCAValue;
begin
 fCriticalSection.Enter;
 try
  try
   POCACode:=POCACompile(fPOCAInstance,fPOCAContext,aCode,aFileName);
   if POCAIsValueCode(POCACode) then begin
    POCAValue:=POCACall(fPOCAContext,POCACode,nil,0,POCAValueNull,fPOCAInstance^.Globals.Namespace);
    if not POCAIsValueNull(POCAValue) then begin
     Line:=POCAStringDump(fPOCAContext,POCAValue);
     if length(Line)>0 then begin
      writeln(copy(Line,1,4096));
     end;
    end;
   end;
   POCAResetTemporarySaves(fPOCAContext);
  except
   on e:EPOCASyntaxError do begin
    Line:=#0#12+'[Exception(EPOCASyntaxError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
    writeln(Line);
   end;
   on e:EPOCARuntimeError do begin
    Line:=#0#12+'[Exception(EPOCARuntimeError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
    writeln(Line);
   end;
   on e:EPOCAScriptError do begin
    Line:=#0#12+'[Exception(EPOCAScriptError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
    writeln(Line);
   end;
   on e:Exception do begin
    Line:=#0#12+'[Exception('+e.ClassName+')]: '+e.Message;
    writeln(Line);
   end;
  end;
 finally
  fCriticalSection.Leave;
 end;
end;

function TScreenMain.POCACallFunction(const aFunction:TpvUTF8String;const aArguments:array of TPOCAValue;const aResultValue:PPOCAValue):Boolean;
var Line:TpvUTF8String;
    FunctionValue,ResultValue:TPOCAValue;
begin
 result:=false;
 try
  fCriticalSection.Enter;
  try
   FunctionValue:=POCAHashGetString(fPOCAContext,fPOCAContext^.Instance^.Globals.Namespace,aFunction);
   if POCAIsValueFunctionOrNativeCode(FunctionValue) then begin
    if length(aArguments)>0 then begin
     ResultValue:=POCACall(fPOCAContext,FunctionValue,@aArguments[0],length(aArguments),POCAValueNull,POCAValueNull);
    end else begin
     ResultValue:=POCACall(fPOCAContext,FunctionValue,nil,0,POCAValueNull,POCAValueNull);
    end;
    if assigned(aResultValue) then begin
     aResultValue^:=ResultValue;
    end;
    POCAResetTemporarySaves(fPOCAContext);
    result:=true;
   end;
  finally
   fCriticalSection.Leave;
  end;
 except
  on e:EPOCASyntaxError do begin
   Line:=#0#12+'[Exception(EPOCASyntaxError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
   writeln(Line);
  end;
  on e:EPOCARuntimeError do begin
   Line:=#0#12+'[Exception(EPOCARuntimeError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
   writeln(Line);
  end;
  on e:EPOCAScriptError do begin
   Line:=#0#12+'[Exception(EPOCAScriptError["'+fPOCAInstance^.SourceFiles[e.SourceFile]+'"):'+IntToStr(e.SourceLine)+','+IntToStr(e.SourceColumn)+']: '+e.Message;
   writeln(Line);
  end;
  on e:Exception do begin
   Line:=#0#12+'[Exception('+e.ClassName+')]: '+e.Message;
   writeln(Line);
  end;
 end;
end;

function TScreenMain.POCAProcessInputKeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):Boolean;
var ResultValue:TPOCAValue;
begin
 fCriticalSection.Enter;
 try
  POCASetInputEventHashKey(fPOCAContext,fInputEventHash,aKeyEvent);
  result:=POCACallFunction('onApplicationInputEvent',[fInputEventHash],@ResultValue);
  if result then begin
   result:=POCAGetBooleanValue(fPOCAContext,ResultValue);
  end;
 finally
  fCriticalSection.Leave;
 end;
end;

function TScreenMain.POCAProcessInputPointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):Boolean;
var ResultValue:TPOCAValue;
begin
 fCriticalSection.Enter;
 try
  POCASetInputEventHashPointer(fPOCAContext,fInputEventHash,aPointerEvent);
  result:=POCACallFunction('onApplicationInputEvent',[fInputEventHash],@ResultValue);
  if result then begin
   result:=POCAGetBooleanValue(fPOCAContext,ResultValue);
  end;
 finally
  fCriticalSection.Leave;
 end;
end;

function TScreenMain.POCAProcessInputScrollEvent(const aRelativeAmount:TpvVector2):Boolean;
var ResultValue:TPOCAValue;
begin
 fCriticalSection.Enter;
 try
  POCASetInputEventHashScroll(fPOCAContext,fInputEventHash,aRelativeAmount);
  result:=POCACallFunction('onApplicationInputEvent',[fInputEventHash],@ResultValue);
  if result then begin
   result:=POCAGetBooleanValue(fPOCAContext,ResultValue);
  end;
 finally
  fCriticalSection.Leave;
 end;
end;

procedure TScreenMain.Show;
const CacheVersionGUID:TGUID='{8591FC7C-8BC8-4724-BA68-EDF89292CF32}';
var Stream:TStream;
    Index,x,y:TpvInt32;
    RawSprite:pointer;
    TrueTypeFont:TpvTrueTypeFont;
    RecreateCacheFiles:boolean;
    CacheStoragePath,CacheStorageFile:string;
    FileStream:TFileStream;
    CacheStorageCacheVersionGUID:TGUID;
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
  fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 fVulkanRenderPass:=nil;

 fVulkanCanvas:=TpvCanvas.Create(pvApplication.VulkanDevice,
                                 pvApplication.VulkanPipelineCache,
                                 MaxInFlightFrames);

 fVulkanSpriteAtlas:=TpvSpriteAtlas.Create(pvApplication.VulkanDevice,true);
 fVulkanSpriteAtlas.UseConvexHullTrimming:=false;

 fVulkanFontSpriteAtlas:=TpvSpriteAtlas.Create(pvApplication.VulkanDevice,false);
 fVulkanFontSpriteAtlas.MipMaps:=false;
 fVulkanFontSpriteAtlas.UseConvexHullTrimming:=false;

 RecreateCacheFiles:=true;

 if pvApplication.Files.IsCacheStorageAvailable then begin

  CacheStoragePath:=IncludeTrailingPathDelimiter(pvApplication.Files.GetCacheStoragePath);

  CacheStorageFile:=CacheStoragePath+'terminal_cache_version.dat';

  if FileExists(CacheStorageFile) and
     FileExists(CacheStoragePath+'terminal_font.dat') and
     FileExists(CacheStoragePath+'terminal_spriteatlas.zip') then begin

   FileStream:=TFileStream.Create(CacheStorageFile,fmOpenRead or fmShareDenyWrite);
   try
    FileStream.Read(CacheStorageCacheVersionGUID,SizeOf(TGUID));
   finally
    FileStream.Free;
   end;

   if CompareMem(@CacheStorageCacheVersionGUID,@CacheVersionGUID,SizeOf(TGUID)) then begin

    //RecreateCacheFiles:=false;

   end;

  end;

 end else begin

  CacheStoragePath:='';

 end;

 if RecreateCacheFiles then begin

  Stream:=pvApplication.Assets.GetAssetStream('fonts/vga.ttf');
  try
   TrueTypeFont:=TpvTrueTypeFont.Create(Stream,72);
   try
    TrueTypeFont.Size:=-64;
    TrueTypeFont.Hinting:=false;
    fVulkanFont:=TpvFont.CreateFromTrueTypeFont(fVulkanFontSpriteAtlas,
                                                TrueTypeFont,
                                                [TpvFontCodePointRange.Create(0,65535)],
                                                true,
                                                2,
                                                1);
    if length(CacheStoragePath)>0 then begin
     fVulkanFont.SaveToFile(CacheStoragePath+'terminal_font.dat');
    end;
   finally
    TrueTypeFont.Free;
   end;
  finally
   Stream.Free;
  end;

  if length(CacheStoragePath)>0 then begin

   fVulkanFontSpriteAtlas.SaveToFile(CacheStoragePath+'terminal_font_spriteatlas.zip',true);

   fVulkanSpriteAtlas.SaveToFile(CacheStoragePath+'terminal_spriteatlas.zip',true);

   FileStream:=TFileStream.Create(CacheStoragePath+'terminal_cache_version.dat',fmCreate);
   try
    FileStream.Write(CacheVersionGUID,SizeOf(TGUID));
   finally
    FileStream.Free;
   end;

  end;

 end else begin

  fVulkanFontSpriteAtlas.LoadFromFile(CacheStoragePath+'terminal_font_spriteatlas.zip');

  fVulkanFont:=TpvFont.CreateFromFile(fVulkanFontSpriteAtlas,CacheStoragePath+'terminal_font.dat');

  fVulkanSpriteAtlas.LoadFromFile(CacheStoragePath+'terminal_spriteatlas.zip');

 end;

 fVulkanFontSpriteAtlas.Upload(pvApplication.VulkanDevice.GraphicsQueue,
                               fVulkanGraphicsCommandBuffer,
                               fVulkanGraphicsCommandBufferFence,
                               pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence);

 fVulkanSpriteAtlas.Upload(pvApplication.VulkanDevice.GraphicsQueue,
                           fVulkanGraphicsCommandBuffer,
                           fVulkanGraphicsCommandBufferFence,
                           pvApplication.VulkanDevice.TransferQueue,
                           fVulkanTransferCommandBuffer,
                           fVulkanTransferCommandBufferFence);    //}

 POCAInitialize;

 fPOCAVulkanCanvas:=POCANewCanvas(fPOCAContext,fVulkanCanvas);
 POCAHashSetString(fPOCAContext,fPOCAContext.Instance^.Globals.RootHash,'hudvulkancanvas',fPOCAVulkanCanvas);

 POCACallFunction('onApplicationCreateCanvas',[fPOCAVulkanCanvas],nil);

 POCACallFunction('onApplicationShow',[],nil);

end;

procedure TScreenMain.Hide;
var Index:TpvInt32;
begin

 POCACallFunction('onApplicationHide',[],nil);
 POCACallFunction('onApplicationDestroyCanvas',[fPOCAVulkanCanvas],nil);

 POCAHashDeleteString(fPOCAContext,fPOCAContext.Instance^.Globals.RootHash,'hudvulkancanvas');
 fPOCAVulkanCanvas:=POCAValueNull;

 FreeAndNil(fVulkanFont);
 FreeAndNil(fVulkanFontSpriteAtlas);
 FreeAndNil(fVulkanSpriteAtlas);
 FreeAndNil(fVulkanCanvas);
 FreeAndNil(fVulkanRenderPass);

 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanRenderCommandBuffers[Index]);
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

procedure TScreenMain.Resume;
begin
 inherited Resume;
 POCACallFunction('onApplicationResume',[],nil);
end;

procedure TScreenMain.Pause;
begin
 POCACallFunction('onApplicationPause',[],nil);
 inherited Pause;
end;

procedure TScreenMain.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
 POCACallFunction('onApplicationResize',[POCANewNumber(fPOCAContext,aWidth),POCANewNumber(fPOCAContext,aHeight)],nil);
end;

procedure TScreenMain.AfterCreateSwapChain;
var Index:TpvInt32;
begin
 inherited AfterCreateSwapChain;

 FreeAndNil(fVulkanRenderPass);

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
                                                                                                                              VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, //VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                                                                                                              VK_IMAGE_LAYOUT_PRESENT_SRC_KHR //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL //VK_IMAGE_LAYOUT_PRESENT_SRC_KHR  // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
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
                                                                                                                             VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, // VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
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
  fVulkanRenderPass.Initialize;

  fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;
{ fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
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

 fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;  }

 fVulkanCanvas.VulkanRenderPass:=fVulkanRenderPass;
 fVulkanCanvas.CountBuffers:=pvApplication.CountInFlightFrames;
{if pvApplication.Width<pvApplication.Height then begin
  fVulkanCanvas.Width:=(720*pvApplication.Width) div pvApplication.Height;
  fVulkanCanvas.Height:=720;
 end else begin
  fVulkanCanvas.Width:=1280;
  fVulkanCanvas.Height:=(1280*pvApplication.Height) div pvApplication.Width;
 end;}
{fVulkanCanvas.Width:=640;
 fVulkanCanvas.Height:=400;}
 fVulkanCanvas.Width:=pvApplication.Width;
 fVulkanCanvas.Height:=pvApplication.Height;
 fVulkanCanvas.Viewport.x:=0;
 fVulkanCanvas.Viewport.y:=0;
 fVulkanCanvas.Viewport.width:=pvApplication.Width;
 fVulkanCanvas.Viewport.height:=pvApplication.Height;

 for Index:=0 to length(fVulkanRenderCommandBuffers)-1 do begin
  FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
 end;

 POCACallFunction('onApplicationAfterCreateSwapChain',[],nil);

end;

procedure TScreenMain.BeforeDestroySwapChain;
begin
 POCACallFunction('onApplicationBeforeDestroySwapChain',[],nil);
 fVulkanCanvas.VulkanRenderPass:=nil;
 FreeAndNil(fVulkanRenderPass);
 inherited BeforeDestroySwapChain;
end;

function TScreenMain.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if POCAProcessInputKeyEvent(aKeyEvent) then begin
  result:=true;
  exit;
 end;
{$ifdef WithConsole}
 result:=fConsole.KeyEvent(aKeyEvent);
{$endif}
end;

function TScreenMain.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 result:=false;
 if POCAProcessInputPointerEvent(aPointerEvent) then begin
  result:=true;
  exit;
 end;
 if fReady then begin
  case aPointerEvent.PointerEventType of
   TpvApplicationInputPointerEventType.Down:begin
   end;
   TpvApplicationInputPointerEventType.Up:begin
   end;
   TpvApplicationInputPointerEventType.Motion:begin
   end;
   TpvApplicationInputPointerEventType.Drag:begin
   end;
  end;
 end;
end;

function TScreenMain.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
 if POCAProcessInputScrollEvent(aRelativeAmount) then begin
  result:=true;
  exit;
 end;
end;

function TScreenMain.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenMain.Check(const aDeltaTime:TpvDouble);
begin
 inherited Check(aDeltaTime);
 POCACallFunction('onApplicationCheck',[POCANewNumber(fPOCAContext,aDeltaTime)],nil);
end;

procedure TScreenMain.CansoleOnSetDrawColor(const aColor:TpvVector4);
begin
 fVulkanCanvas.Color:=ConvertSRGBToLinear(aColor);
end;

procedure TScreenMain.ConsoleOnDrawRect(const aX0,aY0,aX1,aY1:TpvFloat);
begin
 fVulkanCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX0,aY0,aX1,aY1));
end;

procedure TScreenMain.ConsoleOnDrawCodePoint(const aCodePoint:TpvUInt32;const aX,aY:TpvFloat);
begin
 fVulkanCanvas.DrawTextCodePoint(aCodePoint,aX,aY);
end;

procedure TScreenMain.Update(const aDeltaTime:TpvDouble);
var Scale:TpvFloat;
    FPS:TpvInt32;
    FPSString:string;
    RenderCPUTimeString:string;
    UpdateCPUTimeString:string;
    PercentileXthFPSString:string;
    PercentileXthFrameTimeString:string;
    MedianFPSString:string;
    MedianFrameTimeString:string;
    FrameTime,PhysicsTimeStep,RenderCPUTime,PercentileXthFPS,PercentileXthFrameRate,MedianFPS,MedianFrameTime:TpvDouble;
    UpdateTime:TpvHighResolutionTime;
begin

 inherited Update(aDeltaTime);

 UpdateTime:=pvApplication.HighResolutionTimer.GetTime;

 POCACallFunction('onApplicationUpdate',[POCANewNumber(fPOCAContext,aDeltaTime)],nil);

 POCACallFunction('onApplicationUpdateCanvas',[POCANewNumber(fPOCAContext,aDeltaTime),POCANewNumber(fPOCAContext,fVulkanCanvas.Width),POCANewNumber(fPOCAContext,fVulkanCanvas.Height),POCANewNumber(fPOCAContext,fVulkanCanvas.Viewport.width),POCANewNumber(fPOCAContext,fVulkanCanvas.Viewport.height)],nil);

{$ifdef WithConsole}
 fConsole.OnSetDrawColor:=CansoleOnSetDrawColor;
 fConsole.OnDrawRect:=ConsoleOnDrawRect;
 fConsole.OnDrawCodePoint:=ConsoleOnDrawCodePoint;
{$endif}

 fVulkanCanvas.Start(pvApplication.UpdateInFlightFrameIndex);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(1.0,1.0,1.0,1.0));

 fVulkanCanvas.Font:=fVulkanFont;

 fVulkanCanvas.FontSize:=-16;

 // Scaled to fit within the canvas while preserving its aspect ratio and centered, with possible black borders
 if (fVulkanCanvas.Width/fVulkanCanvas.Height)<(640.0/400.0) then begin
  Scale:=fVulkanCanvas.Width/640;
//fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*TpvMatrix4x4.CreateTranslation(0,(fVulkanCanvas.Height-(400*Scale))*0.5,0);
 end else begin
  Scale:=fVulkanCanvas.Height/400;
//fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*TpvMatrix4x4.CreateTranslation((fVulkanCanvas.Width-(640*Scale))*0.5,0,0);
 end;
 // More unified way to scale for also to include a possible additional scaling factor on top of the aspect ratio preserving scaling and
 // optional flipping of the axes (for example for rendering to a texture) as well as a translation to center the content.
 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateTranslation(-ScreenWidth*0.5,-ScreenHeight*0.5,0)*
                           TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*
                           TpvMatrix4x4.CreateTranslation(fVulkanCanvas.Width*0.5,fVulkanCanvas.Height*0.5,0);

{$ifdef WithConsole}
 fConsole.Draw(aDeltaTime);
{$endif}

 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.Identity;
 POCACallFunction('onApplicationDrawCanvas',[fPOCAVulkanCanvas,POCANewNumber(fPOCAContext,fVulkanCanvas.Width),POCANewNumber(fPOCAContext,fVulkanCanvas.Height),POCANewNumber(fPOCAContext,fVulkanCanvas.Viewport.width),POCANewNumber(fPOCAContext,fVulkanCanvas.Viewport.height)],nil);

 fVulkanCanvas.Stop;

 fReady:=true;

 POCAGarbageCollect;

 UpdateTime:=pvApplication.HighResolutionTimer.GetTime-UpdateTime;

 FPS:=round(pvApplication.FramesPerSecond*100.0);
 fFPSTimeAccumulator:=fFPSTimeAccumulator+aDeltaTime;
 if (fFPSTimeAccumulator>=0.1) or (length(fFrameTimeString)=0) then begin
  fFPSTimeAccumulator:=frac(fFPSTimeAccumulator*10.0)*0.1;
  fOldFPS:=Low(Int32);
 end;

 fFrameRateTimeAccumulator:=fFrameRateTimeAccumulator+aDeltaTime;
 if fFrameRateTimeAccumulator>=1.0 then begin
  fFrameRateTimeAccumulator:=frac(fFrameRateTimeAccumulator);
  fPercentileXthFrameRate:=pvApplication.GetPercentileXthFrameTime(95.0);
  fMedianFrameTime:=pvApplication.GetMedianFrameTime(1.0); // of the last second
 end;

 if abs(fOldFPS-FPS)>=100 then begin
  fOldFPS:=FPS;
  PercentileXthFrameRate:=fPercentileXthFrameRate;
  PercentileXthFPS:=1.0/Max(1e-4,PercentileXthFrameRate);
  MedianFrameTime:=fMedianFrameTime;
  MedianFPS:=1.0/Max(1e-4,MedianFrameTime);
  str((FPS*0.01):4:2,FPSString);
  //fScene3D.GetProfilerTimes(RenderCPUTime,FrameTime);
  //str(FrameTime*1000.0:4:2,fFrameTimeString);
  //str(pvApplication.HighResolutionTimer.ToFloatSeconds(fRenderCPUTime)*1000.0:4:2,RenderCPUTimeString);
  str(pvApplication.HighResolutionTimer.ToFloatSeconds(UpdateTime)*1000.0:4:2,UpdateCPUTimeString);
  str(PercentileXthFPS:4:2,PercentileXthFPSString);
  str(PercentileXthFrameRate*1000.0:4:2,PercentileXthFrameTimeString);
  str(MedianFPS:4:2,MedianFPSString);
  str(MedianFrameTime*1000.0:4:2,MedianFrameTimeString);
  pvApplication.WindowTitle:=pvApplication.Title+' ['+FPSString+' FPS] ['+UpdateCPUTimeString+' ms update CPU time] ['+PercentileXthFPSString+' FPS 95%] ['+PercentileXthFrameTimeString+' ms 95%] ['+MedianFPSString+' FPS median] ['+MedianFrameTimeString+' ms median]';
//pvApplication.WindowTitle:=pvApplication.Title+' ['+FPSString+' FPS] ['+fFrameTimeString+' ms GPU time] ['+RenderCPUTimeString+' ms render CPU time] ['+UpdateCPUTimeString+' ms update CPU time] ['+PercentileXthFPSString+' FPS 95%] ['+PercentileXthFrameTimeString+' ms 95%] ['+MedianFPSString+' FPS median] ['+MedianFrameTimeString+' ms median]';
 end;

end;

procedure TScreenMain.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var VulkanCommandBuffer:TpvVulkanCommandBuffer;
    VulkanSwapChain:TpvVulkanSwapChain;
begin

 VulkanCommandBuffer:=fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex];
 VulkanSwapChain:=pvApplication.VulkanSwapChain;

 VulkanCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

 VulkanCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

 fVulkanCanvas.ExecuteUpload(pvApplication.VulkanDevice.TransferQueue,
                             fVulkanTransferCommandBuffer,
                             fVulkanTransferCommandBufferFence,
                             pvApplication.DrawInFlightFrameIndex);

 fVulkanRenderPass.BeginRenderPass(VulkanCommandBuffer,
                                   pvApplication.VulkanFrameBuffers[aSwapChainImageIndex],
                                   VK_SUBPASS_CONTENTS_INLINE,
                                   0,
                                   0,
                                   VulkanSwapChain.Width,
                                   VulkanSwapChain.Height);

 fVulkanCanvas.ExecuteDraw(VulkanCommandBuffer,
                           pvApplication.DrawInFlightFrameIndex);

 fVulkanRenderPass.EndRenderPass(VulkanCommandBuffer);

 VulkanCommandBuffer.EndRecording;

 VulkanCommandBuffer.Execute(pvApplication.VulkanDevice.GraphicsQueue,
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                             aWaitSemaphore,
                             fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex],
                             aWaitFence,
                             false);

 aWaitSemaphore:=fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex];

end;

initialization
{$if declared(NowUTC)}
 StartTimeUTC:=NowUTC;
{$else}
 StartTimeUTC:=TDateTime.NowUTC;
{$ifend}
end.
