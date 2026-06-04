unit UnitScreenConsole;
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
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont,
     PasVulkan.Console;

type { TScreenConsole }

     TScreenConsole=class(TpvApplicationScreen)
      public
       const FontWidth=8;
             FontHeight=16;
             ScreenWidth=640;
             ScreenHeight=400;
             CanvasWidth=ScreenWidth*4;
             CanvasHeight=ScreenHeight*4;
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
       fConsole:TpvConsole;
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

implementation

uses UnitApplication;

{ TScreenConsole }

constructor TScreenConsole.Create;
begin

 inherited Create;

 fReady:=false;

 fConsole:=TpvConsole.Create;
 fConsole.SetChrDim(80,25);
 fConsole.WriteLine(#0#15'Console Test');
 fConsole.WriteLine('');
 fConsole.WriteLine(#0#14'This is just a test, so don''t worry! '#1);
 fConsole.WriteLine('');
 fConsole.WriteLine(#0#12'Use the '#0#14'"'#0#13'force'#0#14'"'#0#12' of this '#0#$9b'blinking-capable'#0#12' console!');
 fConsole.WriteLine('');
 fConsole.UpdateScreen;

end;

destructor TScreenConsole.Destroy;
begin
 FreeAndNil(fConsole);
 inherited Destroy;
end;

procedure TScreenConsole.Show;
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

end;

procedure TScreenConsole.Hide;
var Index:TpvInt32;
begin
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

procedure TScreenConsole.Resume;
begin
 inherited Resume;
end;

procedure TScreenConsole.Pause;
begin
 inherited Pause;
end;

procedure TScreenConsole.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
end;

procedure TScreenConsole.AfterCreateSwapChain;
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

end;

procedure TScreenConsole.BeforeDestroySwapChain;
begin
 fVulkanCanvas.VulkanRenderPass:=nil;
 FreeAndNil(fVulkanRenderPass);
 inherited BeforeDestroySwapChain;
end;

function TScreenConsole.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=fConsole.KeyEvent(aKeyEvent);
end;

function TScreenConsole.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 result:=false;
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

function TScreenConsole.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TScreenConsole.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenConsole.Check(const aDeltaTime:TpvDouble);
begin
 inherited Check(aDeltaTime);
end;

procedure TScreenConsole.CansoleOnSetDrawColor(const aColor:TpvVector4);
begin
 fVulkanCanvas.Color:=ConvertSRGBToLinear(aColor);
end;

procedure TScreenConsole.ConsoleOnDrawRect(const aX0,aY0,aX1,aY1:TpvFloat);
begin
 fVulkanCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX0,aY0,aX1,aY1));
end;

procedure TScreenConsole.ConsoleOnDrawCodePoint(const aCodePoint:TpvUInt32;const aX,aY:TpvFloat);
begin
 fVulkanCanvas.DrawTextCodePoint(aCodePoint,aX,aY);
end;

procedure TScreenConsole.Update(const aDeltaTime:TpvDouble);
var Scale:TpvFloat;
begin

 inherited Update(aDeltaTime);

 fConsole.OnSetDrawColor:=CansoleOnSetDrawColor;
 fConsole.OnDrawRect:=ConsoleOnDrawRect;
 fConsole.OnDrawCodePoint:=ConsoleOnDrawCodePoint;

 fVulkanCanvas.Start(pvApplication.UpdateInFlightFrameIndex);

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

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(1.0,1.0,1.0,1.0));

 fVulkanCanvas.Font:=fVulkanFont;

 fVulkanCanvas.FontSize:=-16;

 fConsole.Draw(aDeltaTime);

 fVulkanCanvas.Stop;

 fReady:=true;

end;

procedure TScreenConsole.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
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
end.