unit UnitScreenExampleCanvas;
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
     UnitRegisteredExamplesList,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont;

type TScreenExampleCanvas=class(TpvApplicationScreen)
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
       fTextureTreeLeafs:TpvVulkanTexture;
       fVulkanSpriteAtlas:TpvSpriteAtlas;
       fVulkanFontSpriteAtlas:TpvSpriteAtlas;
       fVulkanCanvas:TpvCanvas;
       fVulkanFont:TpvFont;
       fVulkanSpriteTest:TpvSprite;
       fVulkanSpriteSmiley0:TpvSprite;
       fVulkanSpriteAppIcon:TpvSprite;
       fVulkanSpriteDancer0:TpvSprite;
       fShapeCircleInsideRoundedRectangle:TpvCanvasShape;
       fReady:boolean;
       fSelectedIndex:TpvInt32;
       fStartY:TpvFloat;
       fTime:TpvDouble;
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

     end;

implementation

uses UnitApplication,UnitTextOverlay,UnitScreenMainMenu;

const SpritesVertices:array[0..2,0..1,0..2] of TpvFloat=
       (((0.5,0.5,0.0),(1.0,0.0,0.0)),
        ((-0.5,0.5,0.0),(0.0,1.0,0.0)),
        ((0.0,-0.5,0.0),(0.0,0.0,1.0)));

      SpritesIndices:array[0..2] of TpvInt32=(0,1,2);

      UniformBuffer:array[0..2,0..3,0..3] of TpvFloat=
       (((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)),  // Projection matrix
        ((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)),  // Model matrix
        ((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0))); // View matrix

      Offsets:array[0..0] of TVkDeviceSize=(0);

      FontSize=3.0;

constructor TScreenExampleCanvas.Create;
begin
 inherited Create;
 fSelectedIndex:=-1;
 fReady:=false;
 fTime:=0.48;
 fShapeCircleInsideRoundedRectangle:=nil;
end;

destructor TScreenExampleCanvas.Destroy;
begin
 FreeAndNil(fShapeCircleInsideRoundedRectangle);
 inherited Destroy;
end;

procedure TScreenExampleCanvas.Show;
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

  CacheStorageFile:=CacheStoragePath+'example_canvas_cache_version.dat';

  if FileExists(CacheStorageFile) and
     FileExists(CacheStoragePath+'example_canvas_font_spriteatlas.zip') and
     FileExists(CacheStoragePath+'example_canvas_font.dat') and
     FileExists(CacheStoragePath+'example_canvas_spriteatlas.zip') then begin

   FileStream:=TFileStream.Create(CacheStorageFile,fmOpenRead or fmShareDenyWrite);
   try
    FileStream.Read(CacheStorageCacheVersionGUID,SizeOf(TGUID));
   finally
    FileStream.Free;
   end;

   if CompareMem(@CacheStorageCacheVersionGUID,@CacheVersionGUID,SizeOf(TGUID)) then begin

    RecreateCacheFiles:=false;

   end;

  end;

 end else begin

  CacheStoragePath:='';

 end;

 if RecreateCacheFiles then begin

  //Stream:=pvApplication.Assets.GetAssetStream('fonts/linbiolinum_r.otf');
  //Stream:=pvApplication.Assets.GetAssetStream('fonts/notosans.ttf');
  Stream:=pvApplication.Assets.GetAssetStream('fonts/vera.ttf');
  try
   TrueTypeFont:=TpvTrueTypeFont.Create(Stream,72);
   try
    TrueTypeFont.Size:=-64;
    TrueTypeFont.Hinting:=false;
    fVulkanFont:=TpvFont.CreateFromTrueTypeFont(fVulkanFontSpriteAtlas,
                                                TrueTypeFont,
                                                [TpvFontCodePointRange.Create(0,255)],
                                                true,
                                                2,
                                                1);
    if length(CacheStoragePath)>0 then begin
     fVulkanFont.SaveToFile(CacheStoragePath+'example_canvas_font.dat');
    end;
   finally
    TrueTypeFont.Free;
   end;
  finally
   Stream.Free;
  end;

  GetMem(RawSprite,256*256*4);
  try
   FillChar(RawSprite^,256*256*4,#$ff);
   Index:=0;
   for y:=0 to 255 do begin
    for x:=0 to 255 do begin
     if (x in [0,255]) or (y in [0,255]) then begin
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+0]):=0;
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+1]):=0;
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+2]):=0;
     end else begin
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+0]):=x;
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+1]):=y;
      TVKUInt8(PpvVulkanRawByteChar(RawSprite)[Index+2]):=(x*y) shr 8;
     end;
     inc(Index,4);
    end;
   end;
   fVulkanSpriteTest:=fVulkanSpriteAtlas.LoadRawSprite('test',RawSprite,256,256,true,2,1);
  finally
   FreeMem(RawSprite);
  end;

  Stream:=pvApplication.Assets.GetAssetStream('sprites/smiley0.png');
  try
   fVulkanSpriteSmiley0:=fVulkanSpriteAtlas.LoadSprite('smiley0',Stream,true,2,1);
  finally
   Stream.Free;
  end;

  Stream:=pvApplication.Assets.GetAssetStream('sprites/appicon.png');
  try
   fVulkanSpriteAppIcon:=fVulkanSpriteAtlas.LoadSprite('appicon',Stream,true,2,1);
  finally
   Stream.Free;
  end;

  Stream:=pvApplication.Assets.GetAssetStream('sprites/dancer0.png');
  try
   fVulkanSpriteDancer0:=fVulkanSpriteAtlas.LoadSprite('dancer0',Stream,true,2,1);
  finally
   Stream.Free;
  end;

  if length(CacheStoragePath)>0 then begin

   fVulkanFontSpriteAtlas.SaveToFile(CacheStoragePath+'example_canvas_font_spriteatlas.zip',true);

   fVulkanSpriteAtlas.SaveToFile(CacheStoragePath+'example_canvas_spriteatlas.zip',true);

   FileStream:=TFileStream.Create(CacheStoragePath+'example_canvas_cache_version.dat',fmCreate);
   try
    FileStream.Write(CacheVersionGUID,SizeOf(TGUID));
   finally
    FileStream.Free;
   end;

  end;

 end else begin

  fVulkanFontSpriteAtlas.LoadFromFile(CacheStoragePath+'example_canvas_font_spriteatlas.zip');

  fVulkanFont:=TpvFont.CreateFromFile(fVulkanFontSpriteAtlas,CacheStoragePath+'example_canvas_font.dat');

  fVulkanSpriteAtlas.LoadFromFile(CacheStoragePath+'example_canvas_spriteatlas.zip');

  fVulkanSpriteTest:=fVulkanSpriteAtlas.Sprites['test'];
  fVulkanSpriteSmiley0:=fVulkanSpriteAtlas.Sprites['smiley0'];
  fVulkanSpriteAppIcon:=fVulkanSpriteAtlas.Sprites['appicon'];
  fVulkanSpriteDancer0:=fVulkanSpriteAtlas.Sprites['dancer0'];

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
                           fVulkanTransferCommandBufferFence);

 Stream:=pvApplication.Assets.GetAssetStream('textures/treeleafs.jpg');
 try
  fTextureTreeLeafs:=TpvVulkanTexture.CreateFromJPEG(pvApplication.VulkanDevice,
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

 fTextureTreeLeafs.WrapModeU:=TpvVulkanTextureWrapMode.MirroredRepeat;
 fTextureTreeLeafs.WrapModeV:=TpvVulkanTextureWrapMode.MirroredRepeat;
 fTextureTreeLeafs.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
 fTextureTreeLeafs.BorderColor:=VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
 fTextureTreeLeafs.UpdateSampler;

 FreeAndNil(fShapeCircleInsideRoundedRectangle);

end;

procedure TScreenExampleCanvas.Hide;
var Index:TpvInt32;
begin
 FreeAndNil(fVulkanFont);
 FreeAndNil(fVulkanFontSpriteAtlas);
 FreeAndNil(fVulkanSpriteAtlas);
 FreeAndNil(fTextureTreeLeafs);
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

procedure TScreenExampleCanvas.Resume;
begin
 inherited Resume;
end;

procedure TScreenExampleCanvas.Pause;
begin
 inherited Pause;
end;

procedure TScreenExampleCanvas.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
end;

procedure TScreenExampleCanvas.AfterCreateSwapChain;
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
 fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;

 fVulkanCanvas.VulkanRenderPass:=fVulkanRenderPass;
 fVulkanCanvas.CountBuffers:=pvApplication.CountInFlightFrames;
 if pvApplication.Width<pvApplication.Height then begin
  fVulkanCanvas.Width:=(720*pvApplication.Width) div pvApplication.Height;
  fVulkanCanvas.Height:=720;
 end else begin
  fVulkanCanvas.Width:=1280;
  fVulkanCanvas.Height:=(1280*pvApplication.Height) div pvApplication.Width;
 end;
 fVulkanCanvas.Viewport.x:=0;
 fVulkanCanvas.Viewport.y:=0;
 fVulkanCanvas.Viewport.width:=pvApplication.Width;
 fVulkanCanvas.Viewport.height:=pvApplication.Height;

 for Index:=0 to length(fVulkanRenderCommandBuffers)-1 do begin
  FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
 end;

 FreeAndNil(fShapeCircleInsideRoundedRectangle);

end;

procedure TScreenExampleCanvas.BeforeDestroySwapChain;
begin
 fVulkanCanvas.VulkanRenderPass:=nil;
 FreeAndNil(fVulkanRenderPass);
 inherited BeforeDestroySwapChain;
end;

function TScreenExampleCanvas.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) then begin
  case aKeyEvent.KeyCode of
   KEYCODE_AC_BACK,KEYCODE_ESCAPE:begin
    pvApplication.NextScreen:=TScreenMainMenu.Create;
   end;
   KEYCODE_UP:begin
    if fSelectedIndex<=0 then begin
     fSelectedIndex:=0;
    end else begin
     dec(fSelectedIndex);
    end;
   end;
   KEYCODE_DOWN:begin
    if fSelectedIndex>=0 then begin
     fSelectedIndex:=0;
    end else begin
     inc(fSelectedIndex);
    end;
   end;
   KEYCODE_PAGEUP:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=0;
    end;
   end;
   KEYCODE_PAGEDOWN:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=0;
    end;
   end;
   KEYCODE_HOME:begin
    fSelectedIndex:=0;
   end;
   KEYCODE_END:begin
    fSelectedIndex:=0
   end;
   KEYCODE_RETURN,KEYCODE_SPACE:begin
    if fSelectedIndex=0 then begin
     pvApplication.NextScreen:=TScreenMainMenu.Create;
    end;
   end;
  end;
 end;
end;

function TScreenExampleCanvas.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Index:TpvInt32;
    cy:TpvFloat;
begin
 result:=false;
 if fReady then begin
  case aPointerEvent.PointerEventType of
   TpvApplicationInputPointerEventType.Down:begin
    fSelectedIndex:=-1;
    cy:=fStartY;
    for Index:=0 to 0 do begin
     if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
      fSelectedIndex:=Index;
      if fSelectedIndex=0 then begin
       pvApplication.NextScreen:=TScreenMainMenu.Create;
      end;
     end;
     cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
    end;
   end;
   TpvApplicationInputPointerEventType.Up:begin
   end;
   TpvApplicationInputPointerEventType.Motion:begin
    fSelectedIndex:=-1;
    cy:=fStartY;
    for Index:=0 to 0 do begin
     if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
      fSelectedIndex:=Index;
     end;
     cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
    end;
   end;
   TpvApplicationInputPointerEventType.Drag:begin
   end;
  end;
 end;
end;

function TScreenExampleCanvas.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TScreenExampleCanvas.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenExampleCanvas.Update(const aDeltaTime:TpvDouble);
const BoolToInt:array[boolean] of TpvInt32=(0,1);
      Options:array[0..0] of string=('Back');
var Index,SubIndex:TpvInt32;
    cy:TpvFloat;
    rbs:TpvUTF8String;
    s:string;
    IsSelected:boolean;
    SrcRect:TpvRect;
    DstRect:TpvRect;
begin
 inherited Update(aDeltaTime);

 fVulkanCanvas.Start(pvApplication.UpdateInFlightFrameIndex);

 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.Identity;

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 fVulkanCanvas.Push;

 fVulkanCanvas.ModelMatrix:=TpvMatrix4x4.Identity;
 fVulkanCanvas.Texture:=fTextureTreeLeafs;
 fVulkanCanvas.FillStyle:=TpvCanvasFillStyle.Image;
 fVulkanCanvas.FillMatrix:=TpvMatrix4x4.CreateTranslation(-fVulkanCanvas.Width*0.125,
                                                          -fVulkanCanvas.Height*0.5)*
                           TpvMatrix4x4.CreateScale(Mix(4,32,(((cos(fTime*pi*1.0)*0.5)+0.5)))/fVulkanCanvas.Width,
                                                    (Mix(4,32,(((cos(fTime*pi*1.0)*0.5)+0.5)))/fVulkanCanvas.Height)*(fVulkanCanvas.Height/fVulkanCanvas.Width))*
                           TpvMatrix4x4.CreateTranslation(cos(fTime*0.5)*0.25,
                                                          sin(fTime*2.0)*0.25)*
                           TpvMatrix4x4.CreateRotateZ(cos(fTime*pi*0.0625)*TwoPI);
 fVulkanCanvas.DrawFilledCircle(fVulkanCanvas.Width*0.125,
                                fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125),
                                fVulkanCanvas.Width*0.1);

 fVulkanCanvas.Texture:=nil;

 if not assigned(fShapeCircleInsideRoundedRectangle) then begin
  fVulkanCanvas.Push;
  fVulkanCanvas.LineWidth:=10.0;
  fVulkanCanvas.LineCap:=TpvCanvasLineCap.Butt;
  fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Bevel;
  fVulkanCanvas.BeginPath;
  fVulkanCanvas.RoundedRectangle(fVulkanCanvas.Width*0.125,fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125),fVulkanCanvas.Width*0.1,fVulkanCanvas.Width*0.1,fVulkanCanvas.Width*0.02);
  fVulkanCanvas.Circle(fVulkanCanvas.Width*0.125,fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125),fVulkanCanvas.Width*0.1);
  fShapeCircleInsideRoundedRectangle:=fVulkanCanvas.GetStrokeShape;
  fVulkanCanvas.EndPath;
  fVulkanCanvas.Pop;
 end;
 fVulkanCanvas.FillStyle:=TpvCanvasFillStyle.RadialGradient;
 fVulkanCanvas.FillWrapMode:=TpvCanvasFillWrapMode.MirroredRepeat;
 fVulkanCanvas.StartColor:=ConvertSRGBToLinear(TpvVector4.Create((sin((fTime*0.84)*pi*2.0)*0.5)+0.5,
                                                                 (cos((fTime*0.98)*pi*2.0)*0.5)+0.5,
                                                                 (sin((fTime*0.43)*pi*2.0)*0.5)+0.5,
                                                                 1.0));
 fVulkanCanvas.StopColor:=ConvertSRGBToLinear(TpvVector4.Create((cos((fTime*0.57)*pi*2.0)*0.5)+0.5,
                                                                (sin((fTime*1.04)*pi*2.0)*0.5)+0.5,
                                                                (cos((fTime*0.79)*pi*2.0)*0.5)+0.5,
                                                                1.0));
 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,1.0);
 fVulkanCanvas.FillMatrix:=TpvMatrix4x4.CreateTranslation(-(fVulkanCanvas.Width*0.125)+(fVulkanCanvas.Width*(cos(fTime*0.5)*0.08)),
                                                          -(fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125))+(fVulkanCanvas.Height*(sin(fTime*2.0)*0.08)))*
                           TpvMatrix4x4.CreateScale(128.0/fVulkanCanvas.Width,
                                                    (128.0/fVulkanCanvas.Height)*(fVulkanCanvas.Height/fVulkanCanvas.Width));
 fVulkanCanvas.DrawShape(fShapeCircleInsideRoundedRectangle);

 if frac(fTime*0.5)<0.5 then begin
  fVulkanCanvas.FillStyle:=TpvCanvasFillStyle.RadialGradient;
 end else begin
  fVulkanCanvas.FillStyle:=TpvCanvasFillStyle.LinearGradient;
 end;
 fVulkanCanvas.FillWrapMode:=TpvCanvasFillWrapMode.MirroredRepeat;
 fVulkanCanvas.StartColor:=ConvertSRGBToLinear(TpvVector4.Create((sin((fTime*0.78)*pi*2.0)*0.5)+0.5,
                                                                 (cos((fTime*0.65)*pi*2.0)*0.5)+0.5,
                                                                 (sin((fTime*0.91)*pi*2.0)*0.5)+0.5,
                                                                 1.0));
 fVulkanCanvas.StopColor:=ConvertSRGBToLinear(TpvVector4.Create((cos((fTime*0.78)*pi*2.0)*0.5)+0.5,
                                                                (sin((fTime*0.65)*pi*2.0)*0.5)+0.5,
                                                                (cos((fTime*0.91)*pi*2.0)*0.5)+0.5,
                                                                1.0));
 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,1.0);
 fVulkanCanvas.FillMatrix:=TpvMatrix4x4.CreateTranslation(-(fVulkanCanvas.Width*0.875)+(fVulkanCanvas.Width*(cos(fTime*0.5)*0.025)),
                                                          -(fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125))+(fVulkanCanvas.Height*(sin(fTime*2.0)*0.025)))*
                           TpvMatrix4x4.CreateScale(Mix(16,64,(sin(fTime*pi*0.125)*0.5)+0.5)/fVulkanCanvas.Width,
                                                    (Mix(16,64,(sin(fTime*pi*0.125)*0.5)+0.5)/fVulkanCanvas.Height)*(fVulkanCanvas.Height/fVulkanCanvas.Width));
 fVulkanCanvas.DrawFilledCircle(fVulkanCanvas.Width*0.875,fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125),fVulkanCanvas.Width*Mix(0.05,0.1,(sin(fTime*pi*4.0)*0.5)+0.5));

 fVulkanCanvas.Pop;

 fVulkanCanvas.DrawTexturedRectangle(fTextureTreeLeafs,fVulkanCanvas.Width*0.5+(fVulkanCanvas.Width*0.25*cos(fTime*pi*0.73)),fVulkanCanvas.Height-(fVulkanCanvas.Width*0.125),fVulkanCanvas.Width*0.05,fVulkanCanvas.Width*0.05,fTime*pi*2.0);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.None;

 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,1.0);

 SrcRect:=TpvRect.CreateAbsolute(0,0,fVulkanSpriteTest.Width,fVulkanSpriteTest.Height);
 DstRect.Left:=((fVulkanCanvas.Width-fVulkanSpriteTest.Width)*0.5)+(cos(fTime*pi*2.0*0.1)*128.0);
 DstRect.Top:=((fVulkanCanvas.Height-fVulkanSpriteTest.Height)*0.5)+(sin(fTime*pi*3.0*0.1)*128.0);
 DstRect.Right:=DstRect.Left+fVulkanSpriteTest.Width;
 DstRect.Bottom:=DstRect.Top+fVulkanSpriteTest.Height;
 fVulkanCanvas.DrawSprite(fVulkanSpriteTest,SrcRect,DstRect,TpvVector2.Create(fVulkanSpriteTest.Width*0.5,fVulkanSpriteTest.Height*0.5),sin(fTime*pi*1.3*0.1)*pi*2.0);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 SrcRect:=TpvRect.CreateAbsolute(0,0,fVulkanSpriteAppIcon.Width,fVulkanSpriteAppIcon.Height);
 DstRect.Left:=((fVulkanCanvas.Width-fVulkanSpriteAppIcon.Width)*0.5)+(sin(fTime*pi*2.0*0.1)*128.0);
 DstRect.Top:=((fVulkanCanvas.Height-fVulkanSpriteAppIcon.Height)*0.5)+(cos(fTime*pi*3.0*0.1)*128.0);
 DstRect.Right:=DstRect.Left+fVulkanSpriteAppIcon.Width;
 DstRect.Bottom:=DstRect.Top+fVulkanSpriteAppIcon.Height;
 fVulkanCanvas.DrawSprite(fVulkanSpriteAppIcon,SrcRect,DstRect,TpvVector2.Create(fVulkanSpriteAppIcon.Width*0.5,fVulkanSpriteAppIcon.Height*0.5),cos(fTime*pi*1.7*0.1)*pi*2.0);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AdditiveBlending;

 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,0.5);

 SrcRect:=TpvRect.CreateAbsolute(0,0,fVulkanSpriteDancer0.Width,fVulkanSpriteDancer0.Height);
 DstRect.Left:=((fVulkanCanvas.Width-fVulkanSpriteDancer0.Width)*0.5)+(cos(fTime*pi*1.7*0.1)*128.0);
 DstRect.Top:=((fVulkanCanvas.Height-fVulkanSpriteDancer0.Height)*0.5)+(sin(fTime*pi*2.3*0.1)*128.0);
 DstRect.Right:=DstRect.Left+fVulkanSpriteDancer0.Width;
 DstRect.Bottom:=DstRect.Top+fVulkanSpriteDancer0.Height;
 fVulkanCanvas.DrawSprite(fVulkanSpriteDancer0,SrcRect,DstRect,TpvVector2.Create(fVulkanSpriteDancer0.Width*0.5,fVulkanSpriteDancer0.Height*0.5),cos(fTime*pi*1.5*0.1)*pi*2.0);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,1.0);

 SrcRect:=TpvRect.CreateAbsolute(0,0,fVulkanSpriteSmiley0.Width,fVulkanSpriteSmiley0.Height);
 DstRect.Left:=((fVulkanCanvas.Width-fVulkanSpriteSmiley0.Width)*0.5)+(sin(fTime*pi*1.7*0.1)*128.0);
 DstRect.Top:=((fVulkanCanvas.Height-fVulkanSpriteSmiley0.Height)*0.5)+(cos(fTime*pi*2.3*0.1)*128.0);
 DstRect.Right:=DstRect.Left+fVulkanSpriteSmiley0.Width;
 DstRect.Bottom:=DstRect.Top+fVulkanSpriteSmiley0.Height;
 fVulkanCanvas.DrawSprite(fVulkanSpriteSmiley0,SrcRect,DstRect,TpvVector2.Create(fVulkanSpriteSmiley0.Width*0.5,fVulkanSpriteSmiley0.Height*0.5),sin(fTime*pi*2.1*0.1)*pi*2.0);

 fVulkanCanvas.Push;

 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateTranslation(-(fVulkanCanvas.Width*0.5),-(fVulkanCanvas.Height*0.5),0.0)*
                           TpvMatrix4x4.CreateRotateZ(sin(fTime*pi*2.0*0.75)*(30.0*DEG2RAD))*
                           TpvMatrix4x4.CreateTranslation(fVulkanCanvas.Width*0.5,fVulkanCanvas.Height*0.5,0.0);

 fVulkanCanvas.ProjectionMatrix:=TpvMatrix4x4.CreateTranslation(-(fVulkanCanvas.Width*0.5),-(fVulkanCanvas.Height*0.5),0.0)*
                                 TpvMatrix4x4.CreateScale(1.0/fVulkanCanvas.Height,1.0/fVulkanCanvas.Height,1.0/fVulkanCanvas.Height)*
                                 TpvMatrix4x4.CreateTranslation(0.0,0.0,-1.0)*
                                 TpvMatrix4x4.CreatePerspective(53.13,fVulkanCanvas.Width/fVulkanCanvas.Height,0.01,128.0);

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

 rbs:='This is an example text';

 fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create((sin((fTime*0.43)*pi*2.0)*0.5)+0.5,
                                                            (cos((fTime*0.29)*pi*2.0)*0.5)+0.5,
                                                            (sin((fTime*0.23)*pi*2.0)*0.5)+0.5,
                                                            (cos((fTime*0.17)*pi*2.0)*0.25)+0.75));

 fVulkanCanvas.Font:=fVulkanFont;

 fVulkanCanvas.FontSize:=(-56.0)+(sin((fTime*0.1)*pi*2.0)*48.0);

 fVulkanCanvas.DrawText(rbs,
                        ((fVulkanCanvas.Width-fVulkanCanvas.TextWidth(rbs))*0.5)+0.0,
                        ((fVulkanCanvas.Height-fVulkanCanvas.TextHeight(rbs))*0.5)+(sin(fTime*pi*0.07)*(fVulkanCanvas.Height*0.3275)));

 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateTranslation(-(fVulkanCanvas.Width*0.5),-(fVulkanCanvas.Height*0.5),0.0)*
                           TpvMatrix4x4.CreateRotateY(sin(fTime*pi*2.0*0.5)*(45.0*DEG2RAD))*
                           TpvMatrix4x4.CreateRotateZ(cos(fTime*pi*2.0*0.9)*(45.0*DEG2RAD))*
                           TpvMatrix4x4.CreateTranslation(fVulkanCanvas.Width*0.5,fVulkanCanvas.Height*0.5,0.0);

 fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create((cos((fTime*0.43)*pi*2.0)*0.5)+0.5,
                                                            (sin((fTime*0.29)*pi*2.0)*0.5)+0.5,
                                                            (cos((fTime*0.23)*pi*2.0)*0.5)+0.5,
                                                            (sin((fTime*0.17)*pi*2.0)*0.25)+0.75));

 fVulkanCanvas.DrawText(rbs,
                        ((fVulkanCanvas.Width-fVulkanCanvas.TextWidth(rbs))*0.5)+0.0,
                        ((fVulkanCanvas.Height-fVulkanCanvas.TextHeight(rbs))*0.5)+(cos(fTime*pi*0.05)*(fVulkanCanvas.Height*0.3275)));

 fVulkanCanvas.Pop;

 fVulkanCanvas.Push;
 fVulkanCanvas.LineWidth:=10.0+(sin((fTime*0.13)*pi*2.0)*6.0);
 fVulkanCanvas.StrokePattern:=TpvCanvasStrokePattern.Create([1.0,-1.0,1.0,-1.0,
                                                             2.0,-2.0,2.0,-2.0,
                                                             4.0,-4.0,4.0,-4.0,
                                                             8.0,-8.0,8.0,-8.0],fVulkanCanvas.LineWidth,0.0);
 // or also: fVulkanCanvas.StrokePattern:=TpvCanvasStrokePattern.Create('- - --  --  ----    ----    --------        --------        ',fVulkanCanvas.LineWidth,0.0);
 // or also: fVulkanCanvas.StrokePattern:='- - --  --  ----    ----    --------        --------        '
 fVulkanCanvas.BeginPath;
 fVulkanCanvas.MoveTo(fVulkanCanvas.Width*(0.5+(sin(fTime*0.5)*0.375)),fVulkanCanvas.Height*(0.5+(cos(fTime*2.0)*0.375)));
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.5)*0.375)),fVulkanCanvas.Height*(0.5+(sin(fTime*2.0)*0.375)));
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.75)*0.375)),fVulkanCanvas.Height*(0.5+(sin(fTime*0.25)*0.375)));
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.3)*0.375)),fVulkanCanvas.Height*(0.5+(cos(fTime*3.0)*0.375)));
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(sin(fTime*1.3)*0.375)),fVulkanCanvas.Height*(0.5+(cos(fTime*0.7)*0.375)));
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(sin(fTime*0.78)*0.375)),fVulkanCanvas.Height*(0.5+(sin(fTime*1.3)*0.375)));
 fVulkanCanvas.ClosePath;
 fVulkanCanvas.Stroke;
 fVulkanCanvas.EndPath;
 fVulkanCanvas.StrokePattern:=TpvCanvasStrokePattern.Empty;
 // or also: fVulkanCanvas.StrokePattern:='';
 fVulkanCanvas.Pop;

 fVulkanCanvas.Push;
 for SubIndex:=0 to 1 do begin
  case SubIndex of
   0:begin
    fVulkanCanvas.LineWidth:=fVulkanCanvas.Height*0.05;
   end;
   else begin
    fVulkanCanvas.LineWidth:=fVulkanCanvas.Height*0.025;
   end;
  end;
  for Index:=0 to 2 do begin
   case SubIndex of
    0:begin
     case Index of
      0:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(1.0,0.25,0.25,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Round;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Round;
      end;
      1:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(0.25,1.0,0.25,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Miter;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Butt;
      end;
      2:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(0.25,0.25,1.0,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Bevel;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Square;
      end;
     end;
    end;
    else begin
     case Index of
      0:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(0.25,1.0,0.25,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Round;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Round;
      end;
      1:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(0.25,0.25,1.0,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Miter;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Butt;
      end;
      2:begin
       fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(1.0,0.25,0.25,1.0));
       fVulkanCanvas.LineJoin:=TpvCanvasLineJoin.Bevel;
       fVulkanCanvas.LineCap:=TpvCanvasLineCap.Square;
      end;
     end;
    end;
   end;
   fVulkanCanvas.ModelMatrix:=TpvMatrix4x4.CreateTranslation(fVulkanCanvas.Width*(0.125+(0.175*(Index+1))),fVulkanCanvas.Height*0.7);
   fVulkanCanvas.BeginPath;
   fVulkanCanvas.MoveTo(0.0,0.0);
   fVulkanCanvas.LineTo(0.0,fVulkanCanvas.Height*0.125);
   fVulkanCanvas.LineTo(fVulkanCanvas.Width*0.125,fVulkanCanvas.Height*(0.125*(0.5+(sin(fTime*1.0)*0.5))));
   fVulkanCanvas.Stroke;
   fVulkanCanvas.EndPath;
  end;
 end;
 fVulkanCanvas.Pop;

 fVulkanCanvas.Push;
 fVulkanCanvas.ModelMatrix:=TpvMatrix4x4.CreateTranslation(fVulkanCanvas.Width*0.75,fVulkanCanvas.Height*0.0);
 fVulkanCanvas.Texture:=fTextureTreeLeafs;
 fVulkanCanvas.FillStyle:=TpvCanvasFillStyle.Image;
 fVulkanCanvas.FillMatrix:=TpvMatrix4x4.CreateScale(4.0/fVulkanCanvas.Width,
                                                    (4.0/fVulkanCanvas.Height)*(fVulkanCanvas.Height/fVulkanCanvas.Width))*
                           TpvMatrix4x4.CreateTranslation(cos(fTime*0.5)*0.25,
                                                          sin(fTime*2.0)*0.25);
 fVulkanCanvas.BeginPath;
{fVulkanCanvas.MoveTo(fVulkanCanvas.Width*0.125,fVulkanCanvas.Height*0.125);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*0.25,fVulkanCanvas.Height*0.125);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*0.25,fVulkanCanvas.Height*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*0.5,fVulkanCanvas.Height*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*0.5,fVulkanCanvas.Height*0.5);}
 fVulkanCanvas.MoveTo(fVulkanCanvas.Width*(0.5+(sin(fTime*0.5)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(cos(fTime*2.0)*0.375))*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.5)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(sin(fTime*2.0)*0.375))*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.75)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(sin(fTime*0.25)*0.375))*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(cos(fTime*0.3)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(cos(fTime*3.0)*0.375))*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(sin(fTime*1.3)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(cos(fTime*0.7)*0.375))*0.25);
 fVulkanCanvas.LineTo(fVulkanCanvas.Width*(0.5+(sin(fTime*0.78)*0.375))*0.25,fVulkanCanvas.Height*(0.5+(sin(fTime*1.3)*0.375))*0.25);
 fVulkanCanvas.ClosePath;
 fVulkanCanvas.Fill;
 fVulkanCanvas.EndPath;
 fVulkanCanvas.Pop;

 fVulkanCanvas.Stop;

 Application.TextOverlay.AddText(pvApplication.Width*0.5,Application.TextOverlay.FontCharHeight*1.0,2.0,toaCenter,'Canvas');

 Str(fTime*1.0:1:3,s);
 Application.TextOverlay.AddText(0.0,Application.TextOverlay.FontCharHeight*4.0,1.0,toaLeft,TpvApplicationRawByteString('Time: '+String(s)+' ms'));

 Application.TextOverlay.AddText(pvApplication.Width*0.5,Application.TextOverlay.FontCharHeight*1.0,2.0,toaCenter,'Canvas');
 fStartY:=pvApplication.Height-((((Application.TextOverlay.FontCharHeight+4)*FontSize)*1.25)-(4*FontSize));
 cy:=fStartY;
 for Index:=0 to 0 do begin
  IsSelected:=fSelectedIndex=Index;
  s:=' '+Options[Index]+' ';
  if IsSelected then begin
   s:='>'+s+'<';
  end;
  Application.TextOverlay.AddText(pvApplication.Width*0.5,cy,FontSize,toaCenter,TpvRawByteString(s),MenuColors[IsSelected,0,0],MenuColors[IsSelected,0,1],MenuColors[IsSelected,0,2],MenuColors[IsSelected,0,3],MenuColors[IsSelected,1,0],MenuColors[IsSelected,1,1],MenuColors[IsSelected,1,2],MenuColors[IsSelected,1,3]);
  cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
 end;

 fTime:=fTime+aDeltaTime;

 fReady:=true;
end;

procedure TScreenExampleCanvas.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var VulkanCommandBuffer:TpvVulkanCommandBuffer;
    VulkanSwapChain:TpvVulkanSwapChain;
begin

 begin

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
 end;

end;

initialization
 RegisterExample('Canvas',TScreenExampleCanvas);
end.
