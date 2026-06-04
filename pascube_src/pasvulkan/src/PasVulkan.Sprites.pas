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
unit PasVulkan.Sprites;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PUCU,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Framework,
     PasVulkan.XML,
     PasVulkan.VectorPath,
     PasVulkan.Streams,
     PasVulkan.SignedDistanceField2D,
     PasVulkan.Image.BMP,
     PasVulkan.Image.JPEG,
     PasVulkan.Image.PNG,
     PasVulkan.Image.QOI,
     PasVulkan.Image.TGA;

type EpvSpriteAtlas=class(Exception);

     TpvSpriteTexture=class
      private
       fTexture:TpvVulkanTexture;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fUploaded:boolean;
       fDirty:boolean;
       fSRGB:boolean;
       fDepth16Bit:boolean;
       fPixels:TpvPointer;
      public
       constructor Create(const aPixels:TpvPointer;const aWidth,aHeight:TpvInt32;const aSRGB:boolean=false;const aDepth16Bit:boolean=false); reintroduce;
       destructor Destroy; override;
       procedure Upload(const aDevice:TpvVulkanDevice;
                        const aGraphicsQueue:TpvVulkanQueue;
                        const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                        const aGraphicsFence:TpvVulkanFence;
                        const aTransferQueue:TpvVulkanQueue;
                        const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                        const aTransferFence:TpvVulkanFence;
                        const aMipMaps:boolean);
       procedure Unload;
      published
       property Texture:TpvVulkanTexture read fTexture;
       property Width:TpvInt32 read fWidth;
       property Height:TpvInt32 read fHeight;
       property Uploaded:boolean read fUploaded;
       property Dirty:boolean read fDirty write fDirty;
       property Depth16Bit:boolean read fDepth16Bit;
     end;

     TpvSpriteAtlasArrayTextureTexels=array of byte;

     TpvSpriteAtlasArrayTexture=class;

     PpvSpriteAtlasArrayTextureLayerRectNode=^TpvSpriteAtlasArrayTextureLayerRectNode;
     TpvSpriteAtlasArrayTextureLayerRectNode=record
      Left:PpvSpriteAtlasArrayTextureLayerRectNode;
      Right:PpvSpriteAtlasArrayTextureLayerRectNode;
      x:TpvInt32;
      y:TpvInt32;
      Width:TpvInt32;
      Height:TpvInt32;
      FreeArea:TpvInt32;
      ContentWidth:TpvInt32;
      ContentHeight:TpvInt32;
     end;

     TPVulkanSpriteAtlasArrayTextureLayerRectNodes=array of PpvSpriteAtlasArrayTextureLayerRectNode;

     PpvSpriteAtlasArrayTextureLayer=^TpvSpriteAtlasArrayTextureLayer;
     TpvSpriteAtlasArrayTextureLayer=record
      Next:PpvSpriteAtlasArrayTextureLayer;
      ArrayTexture:TpvSpriteAtlasArrayTexture;
      RootNode:PpvSpriteAtlasArrayTextureLayerRectNode;
     end;

     TpvSpriteAtlasArrayTexture=class
      private
       fTexels:TpvSpriteAtlasArrayTextureTexels;
       fTexture:TpvVulkanTexture;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fLayers:TpvInt32;
       fCountTexels:TpvInt64;
       fDepth16Bit:boolean;
       fSRGB:boolean;
       fUploaded:boolean;
       fDirty:boolean;
       fSpecialSizedArrayTexture:boolean;
       fBytesPerPixel:TpvInt32;
       fLayerRootNodes:TPVulkanSpriteAtlasArrayTextureLayerRectNodes;
       fInverseSize:TpvVector2;
      public
       constructor Create(const aSRGB,aDepth16Bit:boolean); reintroduce;
       destructor Destroy; override;
       procedure Resize(const aWidth,aHeight,aLayers:TpvInt32);
       procedure CopyIn(const aData;const aSrcWidth,aSrcHeight,aDestX,aDestY,aDestLayer:TpvInt32);
       function GetTexelPointer(const aX,aY,aLayer:TpvInt32):TpvPointer;
       procedure Upload(const aDevice:TpvVulkanDevice;
                        const aGraphicsQueue:TpvVulkanQueue;
                        const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                        const aGraphicsFence:TpvVulkanFence;
                        const aTransferQueue:TpvVulkanQueue;
                        const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                        const aTransferFence:TpvVulkanFence;
                        const aMipMaps:boolean);
       procedure Unload;
       property InverseSize:TpvVector2 read fInverseSize;
      published
       property Texture:TpvVulkanTexture read fTexture;
       property Width:TpvInt32 read fWidth;
       property Height:TpvInt32 read fHeight;
       property Layers:TpvInt32 read fLayers;
       property CountTexels:TpvInt64 read fCountTexels;
       property Uploaded:boolean read fUploaded;
       property Dirty:boolean read fDirty write fDirty;
     end;

     TpvSpriteAtlasArrayTextures=array of TpvSpriteAtlasArrayTexture;

     PpvSpriteFlag=^TpvSpriteFlag;
     TpvSpriteFlag=
      (
       SignedDistanceField,
       Rotated
      );

     PpvSpriteFlags=^TpvSpriteFlags;
     TpvSpriteFlags=set of TpvSpriteFlag;

     PpvSpriteTrimmedHullVectors=^TpvSpriteTrimmedHullVectors;
     TpvSpriteTrimmedHullVectors=TpvVector2DynamicArray;

     TpvSpriteTrimmedHullVectorsArray=array of TpvSpriteTrimmedHullVectors;

     TpvSprite=class
      private
       fName:TpvRawByteString;
       fFlags:TpvSpriteFlags;
       fArrayTexture:TpvSpriteAtlasArrayTexture;
       fX:TpvInt32;
       fY:TpvInt32;
       fLayer:TpvInt32;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fTrimmedX:TpvInt32;
       fTrimmedY:TpvInt32;
       fTrimmedWidth:TpvInt32;
       fTrimmedHeight:TpvInt32;
       fOffsetX:TpvFloat;
       fOffsetY:TpvFloat;
       fScaleX:TpvFloat;
       fScaleY:TpvFloat;
       fTrimmedHullVectors:TpvSpriteTrimmedHullVectors;
       fTrimmedOffset:TpvVector2;
       fTrimmedSize:TpvVector2;
       fTrimmedRect:TpvRect;
       fOffset:TpvVector2;
       fSize:TpvVector2;
       fSignedDistanceFieldVariant:TpvSignedDistanceField2DVariant;
       function GetSignedDistanceField:boolean; inline;
       procedure SetSignedDistanceField(const aSignedDistanceField:boolean); inline;
       function GetRotated:boolean; inline;
       procedure SetRotated(const aRotated:boolean); inline;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Update;
       property TrimmedHullVectors:TpvSpriteTrimmedHullVectors read fTrimmedHullVectors write fTrimmedHullVectors;
       property TrimmedOffset:TpvVector2 read fTrimmedOffset;
       property TrimmedSize:TpvVector2 read fTrimmedSize;
       property TrimmedRect:TpvRect read fTrimmedRect;
       property Offset:TpvVector2 read fOffset;
       property Size:TpvVector2 read fSize;
      published
       property Name:TpvRawByteString read fName write fName;
       property ArrayTexture:TpvSpriteAtlasArrayTexture read fArrayTexture write fArrayTexture;
       property x:TpvInt32 read fX write fX;
       property y:TpvInt32 read fY write fY;
       property Layer:TpvInt32 read fLayer write fLayer;
       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;
       property TrimmedX:TpvInt32 read fTrimmedX write fTrimmedX;
       property TrimmedY:TpvInt32 read fTrimmedY write fTrimmedY;
       property TrimmedWidth:TpvInt32 read fTrimmedWidth write fTrimmedWidth;
       property TrimmedHeight:TpvInt32 read fTrimmedHeight write fTrimmedHeight;
       property OffsetX:TpvFloat read fOffsetX write fOffsetX;
       property OffsetY:TpvFloat read fOffsetY write fOffsetY;
       property ScaleX:TpvFloat read fScaleX write fScaleX;
       property ScaleY:TpvFloat read fScaleY write fScaleY;
       property SignedDistanceField:boolean read GetSignedDistanceField write SetSignedDistanceField;
       property SignedDistanceFieldVariant:TpvSignedDistanceField2DVariant read fSignedDistanceFieldVariant write fSignedDistanceFieldVariant;
       property Rotated:boolean read GetRotated write SetRotated;
     end;

     TpvSprites=array of TpvSprite;

     TpvSpriteAtlasSpriteStringHashMap=class(TpvStringHashMap<TpvSprite>);

     PpvSpriteNinePatchRegionMode=^TpvSpriteNinePatchRegionMode;
     TpvSpriteNinePatchRegionMode=
      (
       Stretch,
       Tile,
       StretchXTileY,
       TileXStretchY
      );

     PpvSpriteNinePatchRegion=^TpvSpriteNinePatchRegion;
     TpvSpriteNinePatchRegion=record
      public
       Mode:TpvSpriteNinePatchRegionMode;
       Left:TpvInt32;
       Top:TpvInt32;
       Width:TpvInt32;
       Height:TpvInt32;
       constructor Create(const aMode:TpvSpriteNinePatchRegionMode;const aLeft,aTop,aWidth,aHeight:TpvInt32);
     end;

     PpvSpriteNinePatchRegions=^TpvSpriteNinePatchRegions;
     TpvSpriteNinePatchRegions=array[0..2,0..2] of TpvSpriteNinePatchRegion;

     PpvSpriteNinePatch=^TpvSpriteNinePatch;
     TpvSpriteNinePatch=record
      Regions:TpvSpriteNinePatchRegions;
     end;

     TpvSpriteAtlas=class
      private
       const FileFormatGUID:TGUID='{DBF9E645-5C92-451B-94F7-134C891D484F}';
      private
       fDevice:TpvVulkanDevice;
       fArrayTextures:TpvSpriteAtlasArrayTextures;
       fCountArrayTextures:TpvInt32;
       fList:TList;
       fHashMap:TpvSpriteAtlasSpriteStringHashMap;
       fDepth16Bit:boolean;
       fSRGB:boolean;
       fIsUploaded:boolean;
       fMipMaps:boolean;
       fUseConvexHullTrimming:boolean;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fMaximumCountArrayLayers:TpvInt32;
       function GetCount:TpvInt32;
       function GetItem(Index:TpvInt32):TpvSprite;
       procedure SetItem(Index:TpvInt32;Item:TpvSprite);
       function GetSprite(const aName:TpvRawByteString):TpvSprite;
       procedure AddSprite(const aSprite:TpvSprite);
       function LoadImage(const aDataPointer:TpvPointer;
                          const aDataSize:TVkSizeInt;
                          var aImageData:TpvPointer;
                          var aImageWidth,aImageHeight:TpvInt32):boolean;
      public
       constructor Create(const aDevice:TpvVulkanDevice;const aSRGB:boolean=false;const aDepth16Bit:boolean=false); reintroduce;
       destructor Destroy; override;
       procedure Upload(const aGraphicsQueue:TpvVulkanQueue;
                        const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                        const aGraphicsFence:TpvVulkanFence;
                        const aTransferQueue:TpvVulkanQueue;
                        const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                        const aTransferFence:TpvVulkanFence); virtual;
       procedure Unload; virtual;
       function Uploaded:boolean; virtual;
       procedure ClearAll; virtual;
       function LoadXML(const aTextureStream:TStream;const aStream:TStream):boolean;
       function LoadRawSprite(const aName:TpvRawByteString;aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvInt32;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1;const aDepth16Bit:boolean=false;const aTrimmedHullVectors:PpvSpriteTrimmedHullVectors=nil):TpvSprite;
       function LoadSignedDistanceFieldSprite(const aName:TpvRawByteString;const aVectorPath:TpvVectorPath;const aImageWidth,aImageHeight:TpvInt32;const aScale:TpvDouble=1.0;const aOffsetX:TpvDouble=0.0;const aOffsetY:TpvDouble=0.0;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1;const aSDFVariant:TpvSignedDistanceField2DVariant=TpvSignedDistanceField2DVariant.Default;const aProtectBorder:boolean=false):TpvSprite; overload;
       function LoadSignedDistanceFieldSprite(const aName,aSVGPath:TpvRawByteString;const aImageWidth,aImageHeight:TpvInt32;const aScale:TpvDouble=1.0;const aOffsetX:TpvDouble=0.0;const aOffsetY:TpvDouble=0.0;const aVectorPathFillRule:TpvVectorPathFillRule=TpvVectorPathFillRule.NonZero;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1;const aSDFVariant:TpvSignedDistanceField2DVariant=TpvSignedDistanceField2DVariant.Default;const aProtectBorder:boolean=false):TpvSprite; overload;
       function LoadSprite(const aName:TpvRawByteString;aStream:TStream;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1):TpvSprite;
       function LoadSprites(const aName:TpvRawByteString;aStream:TStream;aSpriteWidth:TpvInt32=64;aSpriteHeight:TpvInt32=64;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1):TpvSprites;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream;const aFast:boolean=false);
       procedure SaveToFile(const aFileName:string;const aFast:boolean=false);
       property Device:TpvVulkanDevice read fDevice;
       property Count:TpvInt32 read GetCount;
       property Items[Index:TpvInt32]:TpvSprite read GetItem write SetItem;
       property Sprites[const Name:TpvRawByteString]:TpvSprite read GetSprite; default;
      published
       property MipMaps:boolean read fMipMaps write fMipMaps;
       property UseConvexHullTrimming:boolean read fUseConvexHullTrimming write fUseConvexHullTrimming;
       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;
       property MaximumCountArrayLayers:TpvInt32 read fMaximumCountArrayLayers write fMaximumCountArrayLayers;
     end;

implementation

uses PasDblStrUtils,
     PasVulkan.Archive.ZIP,
     PasVulkan.ConvexHullGenerator2D;

const MipMapLevels:array[boolean] of TpvInt32=(1,-1);

function NewTextureRectNode:PpvSpriteAtlasArrayTextureLayerRectNode;
begin
 GetMem(result,SizeOf(TpvSpriteAtlasArrayTextureLayerRectNode));
 FillChar(result^,SizeOf(TpvSpriteAtlasArrayTextureLayerRectNode),AnsiChar(#0));
end;

procedure FreeTextureRectNode(const Node:PpvSpriteAtlasArrayTextureLayerRectNode);
begin
 if assigned(Node) then begin
  FreeTextureRectNode(Node^.Left);
  FreeTextureRectNode(Node^.Right);
  Node^.Left:=nil;
  Node^.Right:=nil;
  FreeMem(Node);
 end;
end;

function InsertTextureRectNode(const Node:PpvSpriteAtlasArrayTextureLayerRectNode;const Width,Height,Area:TpvInt32):PpvSpriteAtlasArrayTextureLayerRectNode;
var RemainWidth,RemainHeight:TpvInt32;
begin
 result:=nil;
 if (Width<=Node^.Width) and (Height<=Node^.Height) and (Area<=Node^.FreeArea) then begin
  if assigned(Node^.Left) or assigned(Node^.Right) then begin
   // This node has children nodes, so this node has content already, so the subnodes will be processing
   if assigned(Node^.Left) then begin
    result:=InsertTextureRectNode(Node^.Left,Width,Height,Area);
    if assigned(result) then begin
     dec(Node^.FreeArea,Area);
     exit;
    end;
   end;
   if assigned(Node^.Right) then begin
    result:=InsertTextureRectNode(Node^.Right,Width,Height,Area);
    if assigned(result) then begin
     dec(Node^.FreeArea,Area);
     exit;
    end;
   end;
  end else begin
   // No children nodes, so allocate a rect here and subdivide the remained space into two subnodes
   RemainWidth:=Node^.Width-Width;
   RemainHeight:=Node^.Height-Height;
   Node^.Left:=NewTextureRectNode;
   Node^.Right:=NewTextureRectNode;
   if RemainWidth<=RemainHeight then begin
    Node^.Left^.x:=Node^.x+Width;
    Node^.Left^.y:=Node^.y;
    Node^.Left^.Width:=RemainWidth;
    Node^.Left^.Height:=Height;
    Node^.Left^.FreeArea:=Node^.Left^.Width*Node^.Left^.Height;
    Node^.Right^.x:=Node^.x;
    Node^.Right^.y:=Node^.y+Height;
    Node^.Right^.Width:=Node^.Width;
    Node^.Right^.Height:=RemainHeight;
    Node^.Right^.FreeArea:=Node^.Right^.Width*Node^.Right^.Height;
   end else begin
    Node^.Left^.x:=Node^.x;
    Node^.Left^.y:=Node^.y+Height;
    Node^.Left^.Width:=Width;
    Node^.Left^.Height:=RemainHeight;
    Node^.Left^.FreeArea:=Node^.Left^.Width*Node^.Left^.Height;
    Node^.Right^.x:=Node^.x+Width;
    Node^.Right^.y:=Node^.y;
    Node^.Right^.Width:=RemainWidth;
    Node^.Right^.Height:=Node^.Height;
    Node^.Right^.FreeArea:=Node^.Right^.Width*Node^.Right^.Height;
   end;
   Node^.Left^.ContentWidth:=0;
   Node^.Left^.ContentHeight:=0;
   Node^.Right^.ContentWidth:=0;
   Node^.Right^.ContentHeight:=0;
   Node^.ContentWidth:=Width;
   Node^.ContentHeight:=Height;
   dec(Node^.FreeArea,Area);
   result:=Node;
  end;
 end;
end;

constructor TpvSpriteTexture.Create(const aPixels:pointer;const aWidth,aHeight:TpvInt32;const aSRGB:boolean=false;const aDepth16Bit:boolean=false);
begin
 inherited Create;

 fTexture:=nil;

 fPixels:=aPixels;

 fWidth:=aWidth;
 fHeight:=aHeight;

 fSRGB:=aSRGB;

 fDepth16Bit:=aDepth16Bit;

 fUploaded:=false;
 fDirty:=true;

end;

destructor TpvSpriteTexture.Destroy;
begin

 Unload;

 FreeAndNil(fTexture);

 fPixels:=nil;

 inherited Destroy;
end;

procedure TpvSpriteTexture.Upload(const aDevice:TpvVulkanDevice;
                                  const aGraphicsQueue:TpvVulkanQueue;
                                  const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                                  const aGraphicsFence:TpvVulkanFence;
                                  const aTransferQueue:TpvVulkanQueue;
                                  const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                                  const aTransferFence:TpvVulkanFence;
                                  const aMipMaps:boolean);
type PPixel16Bit=^TPixel16Bit;
     TPixel16Bit=packed record
      r,g,b,a:TpvUInt16;
     end;
const Div16Bit=1.0/65536.0;
var BytesPerPixel,Index:TpvInt32;
    Format:TVkFormat;
    UploadPixels:pointer;
    s16,d16:PPixel16Bit;
    c:TpvVector4;
begin

 if not fUploaded then begin

  FreeAndNil(fTexture);

  UploadPixels:=fPixels;
  try

   if fDepth16Bit then begin
    BytesPerPixel:=16;
    if fSRGB then begin
     Format:=VK_FORMAT_R16G16B16A16_UNORM;
     GetMem(UploadPixels,fWidth*fHeight*BytesPerPixel);
     s16:=fPixels;
     d16:=UploadPixels;
     for Index:=1 to fWidth*fHeight do begin
      c:=ConvertSRGBToLinear(TpvVector4.InlineableCreate(s16^.r,s16^.g,s16^.g,s16^.b)*Div16Bit);
      d16^.r:=Min(Max(round(Clamp(c.r,0.0,1.0)*65536.0),0),65535);
      d16^.g:=Min(Max(round(Clamp(c.g,0.0,1.0)*65536.0),0),65535);
      d16^.b:=Min(Max(round(Clamp(c.b,0.0,1.0)*65536.0),0),65535);
      d16^.a:=Min(Max(round(Clamp(c.a,0.0,1.0)*65536.0),0),65535);
      inc(s16);
      inc(d16);
     end;
    end else begin
     Format:=VK_FORMAT_R16G16B16A16_UNORM;
    end;
   end else begin
    BytesPerPixel:=8;
    if fSRGB then begin
     Format:=VK_FORMAT_R8G8B8A8_SRGB;
    end else begin
     Format:=VK_FORMAT_R8G8B8A8_UNORM;
    end;
   end;

   fTexture:=TpvVulkanTexture.CreateFromMemory(aDevice,
                                               aGraphicsQueue,
                                               aGraphicsCommandBuffer,
                                               aGraphicsFence,
                                               aTransferQueue,
                                               aTransferCommandBuffer,
                                               aTransferFence,
                                               Format,
                                               VK_SAMPLE_COUNT_1_BIT,
                                               Max(1,fWidth),
                                               Max(1,fHeight),
                                               0,
                                               0,
                                               1,
                                               MipMapLevels[aMipMaps],
                                               [TpvVulkanTextureUsageFlag.TransferDst,TpvVulkanTextureUsageFlag.Sampled],
                                               UploadPixels,
                                               fWidth*fHeight*BytesPerPixel,
                                               false,
                                               false,
                                               1,
                                               true,
                                               false,
                                               false,
                                               pvAllocationGroupIDSpriteAtlas);
   fTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
   fTexture.UpdateSampler;

  finally
   if UploadPixels<>fPixels then begin
    FreeMem(UploadPixels);
   end;
  end;

  fUploaded:=true;

 end;

end;

procedure TpvSpriteTexture.Unload;
begin

 if fUploaded then begin

  FreeAndNil(fTexture);

  fUploaded:=false;

 end;

end;

constructor TpvSpriteAtlasArrayTexture.Create(const aSRGB,aDepth16Bit:boolean);
begin
 inherited Create;
 fTexels:=nil;
 fTexture:=nil;
 fLayerRootNodes:=nil;
 fWidth:=0;
 fHeight:=0;
 fLayers:=0;
 fCountTexels:=0;
 fDepth16Bit:=aDepth16Bit;
 fSRGB:=aSRGB;
 fUploaded:=false;
 fDirty:=true;
 fSpecialSizedArrayTexture:=false;
 if fDepth16Bit then begin
  fBytesPerPixel:=8;
 end else begin
  fBytesPerPixel:=4;
 end;
end;

destructor TpvSpriteAtlasArrayTexture.Destroy;
var LayerIndex:TpvInt32;
begin
 Unload;
 FreeAndNil(fTexture);
 for LayerIndex:=0 to fLayers-1 do begin
  if assigned(fLayerRootNodes[LayerIndex]) then begin
   FreeTextureRectNode(fLayerRootNodes[LayerIndex]);
   fLayerRootNodes[LayerIndex]:=nil;
  end;
 end;
 fLayerRootNodes:=nil;
 fTexels:=nil;
 inherited Destroy;
end;

procedure TpvSpriteAtlasArrayTexture.Resize(const aWidth,aHeight,aLayers:TpvInt32);
var y,LayerIndex,OldWidth,OldHeight,OldLayers:TpvInt32;
    OldTexels:TpvSpriteAtlasArrayTextureTexels;
begin
 if (fWidth<>aWidth) or
    (fHeight<>aHeight) or
    (fLayers<>aLayers) then begin
  OldWidth:=fWidth;
  OldHeight:=fHeight;
  OldLayers:=fLayers;
  OldTexels:=fTexels;
  try
   fTexels:=nil;
   fWidth:=aWidth;
   fHeight:=aHeight;
   fLayers:=aLayers;
   fCountTexels:=TpvInt64(fWidth)*TpvInt64(fHeight)*TpvInt64(fLayers);
   if fCountTexels>0 then begin
    SetLength(fTexels,fCountTexels*fBytesPerPixel);
    FillChar(fTexels[0],fCountTexels*fBytesPerPixel,#0);
    for LayerIndex:=0 to Min(fLayers,OldLayers)-1 do begin
     for y:=0 to Min(fHeight,OldHeight)-1 do begin
      Move(OldTexels[(((TpvInt64(LayerIndex)*OldHeight)+y)*OldWidth)*fBytesPerPixel],
           fTexels[(((TpvInt64(LayerIndex)*fHeight)+y)*fWidth)*fBytesPerPixel],
           Min(fWidth,OldWidth)*fBytesPerPixel);
     end;
    end;
   end;
   for LayerIndex:=fLayers to Min(OldLayers,length(fLayerRootNodes))-1 do begin
    if assigned(fLayerRootNodes[LayerIndex]) then begin
     FreeTextureRectNode(fLayerRootNodes[LayerIndex]);
     fLayerRootNodes[LayerIndex]:=nil;
    end;
   end;
   SetLength(fLayerRootNodes,fLayers);
   for LayerIndex:=OldLayers to fLayers-1 do begin
    fLayerRootNodes[LayerIndex]:=NewTextureRectNode;
    fLayerRootNodes[LayerIndex]^.x:=0;
    fLayerRootNodes[LayerIndex]^.y:=0;
    fLayerRootNodes[LayerIndex]^.Width:=fWidth;
    fLayerRootNodes[LayerIndex]^.Height:=fHeight;
    fLayerRootNodes[LayerIndex]^.FreeArea:=fWidth*fHeight;
   end;
   fInverseSize:=TpvVector2.InlineableCreate(1.0/fWidth,1.0/fHeight);
  finally
   OldTexels:=nil;
  end;
 end;
end;

procedure TpvSpriteAtlasArrayTexture.CopyIn(const aData;const aSrcWidth,aSrcHeight,aDestX,aDestY,aDestLayer:TpvInt32);
var dy,sx,dw:TpvInt32;
begin
 sx:=Min(0,-aDestX);
 dw:=Min(Max(aSrcWidth-sx,0),fWidth-aDestX);
 if dw>0 then begin
  for dy:=Min(Max(aDestY,0),fHeight-1) to Min(Max(aDestY+(aSrcHeight-1),0),fHeight-1) do begin
   Move(PpvUInt8Array(TpvPointer(@aData))^[(((dy-aDestY)*aSrcWidth)+sx)*fBytesPerPixel],
        fTexels[((((TpvInt64(aDestLayer)*fHeight)+dy)*fWidth)+aDestX)*fBytesPerPixel],
        dw*fBytesPerPixel);
  end;
 end;
end;

function TpvSpriteAtlasArrayTexture.GetTexelPointer(const aX,aY,aLayer:TpvInt32):TpvPointer;
begin
 result:=@fTexels[((((TpvInt64(aLayer)*fHeight)+aY)*fWidth)+aX)*fBytesPerPixel];
end;

procedure TpvSpriteAtlasArrayTexture.Upload(const aDevice:TpvVulkanDevice;
                                            const aGraphicsQueue:TpvVulkanQueue;
                                            const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                                            const aGraphicsFence:TpvVulkanFence;
                                            const aTransferQueue:TpvVulkanQueue;
                                            const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                                            const aTransferFence:TpvVulkanFence;
                                            const aMipMaps:boolean);
type PPixel16Bit=^TPixel16Bit;
     TPixel16Bit=packed record
      r,g,b,a:TpvUInt16;
     end;
const Div16Bit=1.0/65536.0;
var BytesPerPixel,Index:TpvInt32;
    Format:TVkFormat;
    UploadPixels:pointer;
    s16,d16:PPixel16Bit;
    c:TpvVector4;
begin

 if not fUploaded then begin

  FreeAndNil(fTexture);

  UploadPixels:=@fTexels[0];
  try

   if fDepth16Bit then begin
    if fSRGB then begin
     Format:=VK_FORMAT_R16G16B16A16_UNORM;
     GetMem(UploadPixels,fCountTexels*fBytesPerPixel);
     s16:=@fTexels[0];
     d16:=UploadPixels;
     for Index:=1 to fCountTexels do begin
      c:=ConvertSRGBToLinear(TpvVector4.InlineableCreate(s16^.r,s16^.g,s16^.g,s16^.b)*Div16Bit);
      d16^.r:=Min(Max(round(Clamp(c.r,0.0,1.0)*65536.0),0),65535);
      d16^.g:=Min(Max(round(Clamp(c.g,0.0,1.0)*65536.0),0),65535);
      d16^.b:=Min(Max(round(Clamp(c.b,0.0,1.0)*65536.0),0),65535);
      d16^.a:=Min(Max(round(Clamp(c.a,0.0,1.0)*65536.0),0),65535);
      inc(s16);
      inc(d16);
     end;
    end else begin
     Format:=VK_FORMAT_R16G16B16A16_UNORM;
    end;
    BytesPerPixel:=16;
   end else begin
    if fSRGB then begin
     Format:=VK_FORMAT_R8G8B8A8_SRGB;
    end else begin
     Format:=VK_FORMAT_R8G8B8A8_UNORM;
    end;
    BytesPerPixel:=8;
   end;

   fTexture:=TpvVulkanTexture.CreateFromMemory(aDevice,
                                               aGraphicsQueue,
                                               aGraphicsCommandBuffer,
                                               aGraphicsFence,
                                               aTransferQueue,
                                               aTransferCommandBuffer,
                                               aTransferFence,
                                               Format,
                                               VK_SAMPLE_COUNT_1_BIT,
                                               Max(1,fWidth),
                                               Max(1,fHeight),
                                               0,
                                               Max(1,fLayers),
                                               1,
                                               MipMapLevels[aMipMaps],
                                               [TpvVulkanTextureUsageFlag.TransferDst,TpvVulkanTextureUsageFlag.Sampled],
                                               UploadPixels,
                                               fCountTexels*fBytesPerPixel,
                                               false,
                                               false,
                                               1,
                                               true,
                                               false,
                                               false,
                                               pvAllocationGroupIDSpriteAtlas,
                                               'TpvSpriteAtlasArrayTexture');

   fTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToBorder;
   fTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
   fTexture.UpdateSampler;

  finally
   if UploadPixels<>@fTexels[0] then begin
    FreeMem(UploadPixels);
   end;
  end;

  fUploaded:=true;

 end;
end;

procedure TpvSpriteAtlasArrayTexture.Unload;
begin
 if fUploaded then begin
  FreeAndNil(fTexture);
  fUploaded:=false;
 end;
end;

constructor TpvSprite.Create;
begin
 inherited Create;
 Name:='';
 OffsetX:=0.0;
 OffsetY:=0.0;
 ScaleX:=1.0;
 ScaleY:=1.0;
 fTrimmedHullVectors:=nil;
end;

destructor TpvSprite.Destroy;
begin
 fTrimmedHullVectors:=nil;
 Name:='';
 inherited Destroy;
end;

procedure TpvSprite.Update;
begin
 fTrimmedOffset:=TpvVector2.InlineableCreate(fTrimmedX,fTrimmedY);
 if Rotated then begin
  fTrimmedSize:=TpvVector2.InlineableCreate(fTrimmedHeight,fTrimmedWidth);
 end else begin
  fTrimmedSize:=TpvVector2.InlineableCreate(fTrimmedWidth,fTrimmedHeight);
 end;
 fTrimmedRect:=TpvRect.CreateRelative(fTrimmedOffset,fTrimmedSize);
 fOffset:=TpvVector2.InlineableCreate(x,y);
 fSize:=TpvVector2.InlineableCreate(fWidth,fHeight);
end;

function TpvSprite.GetSignedDistanceField:boolean;
begin
 result:=TpvSpriteFlag.SignedDistanceField in fFlags;
end;

procedure TpvSprite.SetSignedDistanceField(const aSignedDistanceField:boolean);
begin
 if aSignedDistanceField then begin
  Include(fFlags,TpvSpriteFlag.SignedDistanceField);
 end else begin
  Exclude(fFlags,TpvSpriteFlag.SignedDistanceField);
 end;
end;

function TpvSprite.GetRotated:boolean;
begin
 result:=TpvSpriteFlag.Rotated in fFlags;
end;

procedure TpvSprite.SetRotated(const aRotated:boolean);
begin
 if aRotated then begin
  Include(fFlags,TpvSpriteFlag.Rotated);
 end else begin
  Exclude(fFlags,TpvSpriteFlag.Rotated);
 end;
end;

constructor TpvSpriteNinePatchRegion.Create(const aMode:TpvSpriteNinePatchRegionMode;const aLeft,aTop,aWidth,aHeight:TpvInt32);
begin
 Mode:=aMode;
 Left:=aLeft;
 Top:=aTop;
 Width:=aWidth;
 Height:=aHeight;
end;

constructor TpvSpriteAtlas.Create(const aDevice:TpvVulkanDevice;const aSRGB:boolean=false;const aDepth16Bit:boolean=false);
begin
 fDevice:=aDevice;
 fArrayTextures:=nil;
 fCountArrayTextures:=0;
 fList:=TList.Create;
 fHashMap:=TpvSpriteAtlasSpriteStringHashMap.Create(nil);
 fDepth16Bit:=aDepth16Bit;
 fSRGB:=aSRGB;
 fIsUploaded:=false;
 fMipMaps:=true;
 fUseConvexHullTrimming:=false;
 fWidth:=Min(VULKAN_SPRITEATLASTEXTURE_WIDTH,fDevice.PhysicalDevice.Properties.limits.maxImageDimension2D);
 fHeight:=Min(VULKAN_SPRITEATLASTEXTURE_HEIGHT,fDevice.PhysicalDevice.Properties.limits.maxImageDimension2D);
 fMaximumCountArrayLayers:=fDevice.PhysicalDevice.Properties.limits.maxImageArrayLayers;
 inherited Create;
end;

destructor TpvSpriteAtlas.Destroy;
var Index:TpvInt32;
begin
 Unload;
 for Index:=0 to fCountArrayTextures-1 do begin
  FreeAndNil(fArrayTextures[Index]);
 end;
 fArrayTextures:=nil;
 ClearAll;
 fHashMap.Free;
 fList.Free;
 inherited Destroy;
end;

procedure TpvSpriteAtlas.ClearAll;
var Index:TpvInt32;
begin
 for Index:=0 to fList.Count-1 do begin
  TpvSprite(Items[Index]).Free;
  Items[Index]:=nil;
 end;
 fList.Clear;
 fHashMap.Clear;
end;

procedure TpvSpriteAtlas.Upload(const aGraphicsQueue:TpvVulkanQueue;
                                    const aGraphicsCommandBuffer:TpvVulkanCommandBuffer;
                                    const aGraphicsFence:TpvVulkanFence;
                                    const aTransferQueue:TpvVulkanQueue;
                                    const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                                    const aTransferFence:TpvVulkanFence);
var Index:TpvInt32;
    ArrayTexture:TpvSpriteAtlasArrayTexture;
begin
 if not fIsUploaded then begin
  for Index:=0 to fCountArrayTextures-1 do begin
   ArrayTexture:=fArrayTextures[Index];
   if not ArrayTexture.Uploaded then begin
    ArrayTexture.Upload(fDevice,
                        aGraphicsQueue,
                        aGraphicsCommandBuffer,
                        aGraphicsFence,
                        aTransferQueue,
                        aTransferCommandBuffer,
                        aTransferFence,
                        fMipMaps);
    ArrayTexture.Dirty:=false;
   end;
  end;
  fIsUploaded:=true;
 end;
end;

procedure TpvSpriteAtlas.Unload;
var Index:TpvInt32;
    ArrayTexture:TpvSpriteAtlasArrayTexture;
begin
 if fIsUploaded then begin
  for Index:=0 to fCountArrayTextures-1 do begin
   ArrayTexture:=fArrayTextures[Index];
   if ArrayTexture.Uploaded then begin
    ArrayTexture.Unload;
   end;
  end;
  fIsUploaded:=false;
 end;
end;

function TpvSpriteAtlas.Uploaded:boolean;
begin
 result:=fIsUploaded;
end;

function TpvSpriteAtlas.GetCount:TpvInt32;
begin
 result:=fList.Count;
end;

function TpvSpriteAtlas.GetItem(Index:TpvInt32):TpvSprite;
begin
 result:=TpvSprite(fList.Items[Index]);
end;

procedure TpvSpriteAtlas.SetItem(Index:TpvInt32;Item:TpvSprite);
begin
 fList.Items[Index]:=TpvPointer(Item);
end;

function TpvSpriteAtlas.GetSprite(const aName:TpvRawByteString):TpvSprite;
begin
 result:=fHashMap[aName];
end;

procedure TpvSpriteAtlas.AddSprite(const aSprite:TpvSprite);
begin
 fHashMap.Add(aSprite.Name,aSprite);
 fList.Add(aSprite);
end;

function TpvSpriteAtlas.LoadImage(const aDataPointer:TpvPointer;
                                  const aDataSize:TVkSizeInt;
                                  var aImageData:TpvPointer;
                                  var aImageWidth,aImageHeight:TpvInt32):boolean;
type PFirstBytes=^TFirstBytes;
     TFirstBytes=array[0..63] of TpvUInt8;
     PDDSHeader=^TDDSHeader;
     TDDSHeader=packed record
      dwMagic:TpvUInt32;
      dwSize:TpvUInt32;
      dwFlags:TpvUInt32;
      dwHeight:TpvUInt32;
      dwWidth:TpvUInt32;
      dwPitchOrLinearSize:TpvUInt32;
      dwDepth:TpvUInt32;
      dwMipMapCount:TpvUInt32;
     end;
var Index,x,y:TpvInt32;
    p8:PpvUInt8;
    p16:PpvUInt16;
    PNGPixelFormat:TpvPNGPixelFormat;
    NewImageData:TpvPointer;
    SRGB:boolean;
    v:TpvFloat;
begin
 result:=false;
 if (aDataSize>7) and (PFirstBytes(aDataPointer)^[0]=$89) and (PFirstBytes(aDataPointer)^[1]=$50) and (PFirstBytes(aDataPointer)^[2]=$4e) and (PFirstBytes(aDataPointer)^[3]=$47) and (PFirstBytes(aDataPointer)^[4]=$0d) and (PFirstBytes(aDataPointer)^[5]=$0a) and (PFirstBytes(aDataPointer)^[6]=$1a) and (PFirstBytes(aDataPointer)^[7]=$0a) then begin
  PNGPixelFormat:=TpvPNGPixelFormat.Unknown;
  if LoadPNGImage(aDataPointer,aDataSize,aImageData,aImageWidth,aImageHeight,false,PNGPixelFormat) then begin
   result:=true;
   if fDepth16Bit then begin
    if PNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8 then begin
     // Convert to R16G1B16A16
     GetMem(NewImageData,aImageWidth*aImageHeight*8);
     try
      p8:=aImageData;
      p16:=NewImageData;
      for Index:=1 to aImageWidth*aImageHeight*4 do begin
       p16^:=p8^ or (TpvUInt16(p8^) shl 8);
       inc(p8);
       inc(p16);
      end;
     finally
      FreeMem(aImageData);
      aImageData:=NewImageData;
     end;
    end;
   end else begin
    if PNGPixelFormat=TpvPNGPixelFormat.R16G16B16A16 then begin
     // Convert to R8G8B8A8 in-place
     p8:=aImageData;
     p16:=aImageData;
     for Index:=1 to aImageWidth*aImageHeight*4 do begin
      p8^:=p16^ shr 8;
      inc(p8);
      inc(p16);
     end;
    end;
   end;
  end;
 end else begin
  if (aDataSize>4) and (PFirstBytes(aDataPointer)^[0]=TpvUInt8(AnsiChar('q'))) and (PFirstBytes(aDataPointer)^[1]=TpvUInt8(AnsiChar('o'))) and (PFirstBytes(aDataPointer)^[2]=TpvUInt8(AnsiChar('i'))) and (PFirstBytes(aDataPointer)^[3]=TpvUInt8(AnsiChar('f'))) then begin
   result:=LoadQOIImage(aDataPointer,aDataSize,aImageData,aImageWidth,aImageHeight,false,SRGB);
   if result and not SRGB then begin
    if fDepth16Bit then begin
     GetMem(NewImageData,aImageWidth*aImageHeight*8);
     try
      p8:=aImageData;
      p16:=NewImageData;
      Index:=0;
      for y:=1 to aImageHeight do begin
       for x:=1 to aImageWidth do begin
        if (Index and 3)<>3 then begin
         // Only convert the RGB color channels, but not the alpha channel
         v:=p8^/255.0;
         if v<0.0031308 then begin
          v:=v*12.92;
         end else begin
          v:=(Power(v,1.0/2.4)*1.055)-0.055;
         end;
         p16^:=Min(Max(Round(v*65535.0),0),65535);
        end;
        inc(p8);
        inc(p16);
        inc(Index);
       end;
      end;
     finally
      FreeMem(aImageData);
      aImageData:=NewImageData;
     end;
     exit;
    end else begin
     p8:=aImageData;
     Index:=0;
     for y:=1 to aImageHeight do begin
      for x:=1 to aImageWidth do begin
       if (Index and 3)<>3 then begin
        // Only convert the RGB color channels, but not the alpha channel
        v:=p8^/255.0;
        if v<0.0031308 then begin
         v:=v*12.92;
        end else begin
         v:=(Power(v,1.0/2.4)*1.055)-0.055;
        end;
        p8^:=Min(Max(Round(v*255.0),0),255);
       end;
       inc(p8);
       inc(Index);
      end;
     end;
    end;
   end;
  end else if (aDataSize>2) and (PFirstBytes(aDataPointer)^[0]=TpvUInt8(AnsiChar('B'))) and (PFirstBytes(aDataPointer)^[1]=TpvUInt8(AnsiChar('M'))) then begin
   result:=LoadBMPImage(aDataPointer,aDataSize,aImageData,aImageWidth,aImageHeight,false);
  end else if (aDataSize>2) and (((PFirstBytes(aDataPointer)^[0] xor $ff) or (PFirstBytes(aDataPointer)^[1] xor $d8))=0) then begin
   result:=LoadJPEGImage(aDataPointer,aDataSize,aImageData,aImageWidth,aImageHeight,false);
  end else begin
   result:=LoadTGAImage(aDataPointer,aDataSize,aImageData,aImageWidth,aImageHeight,false);
  end;
  if result and fDepth16Bit then begin
   // Convert to R16G1B16A16
   GetMem(NewImageData,aImageWidth*aImageHeight*8);
   try
    p8:=aImageData;
    p16:=NewImageData;
    for Index:=1 to aImageWidth*aImageHeight*4 do begin
     p16^:=p8^ or (TpvUInt16(p8^) shl 8);
     inc(p8);
     inc(p16);
    end;
   finally
    FreeMem(aImageData);
    aImageData:=NewImageData;
   end;
  end;
 end;
end;

function TpvSpriteAtlas.LoadXML(const aTextureStream:TStream;const aStream:TStream):boolean;
var XML:TpvXML;
    MemoryStream:TMemoryStream;
    i,j:TpvInt32;
    XMLItem,XMLChildrenItem:TpvXMLItem;
    XMLTag,XMLChildrenTag:TpvXMLTag;
    SpriteName:TpvRawByteString;
    Sprite:TpvSprite;
    SpriteAtlasArrayTexture:TpvSpriteAtlasArrayTexture;
    ImageData:TpvPointer;
    ImageWidth,ImageHeight:TpvInt32;
begin
 result:=false;
 if assigned(aTextureStream) and assigned(aStream) then begin
  SpriteAtlasArrayTexture:=nil;
  MemoryStream:=TMemoryStream.Create;
  try
   aStream.Seek(0,soBeginning);
   MemoryStream.CopyFrom(aTextureStream,aTextureStream.Size);
   MemoryStream.Seek(0,soBeginning);
   ImageData:=nil;
   try
    if LoadImage(MemoryStream.Memory,MemoryStream.Size,ImageData,ImageWidth,ImageHeight) then begin
     SpriteAtlasArrayTexture:=TpvSpriteAtlasArrayTexture.Create(fSRGB,fDepth16Bit);
     SpriteAtlasArrayTexture.Resize(ImageWidth,ImageHeight,1);
     if length(fArrayTextures)<(fCountArrayTextures+1) then begin
      SetLength(fArrayTextures,(fCountArrayTextures+1)*2);
     end;
     fArrayTextures[fCountArrayTextures]:=SpriteAtlasArrayTexture;
     inc(fCountArrayTextures);
     SpriteAtlasArrayTexture.fSpecialSizedArrayTexture:=true;
     SpriteAtlasArrayTexture.Dirty:=true;
     SpriteAtlasArrayTexture.fLayerRootNodes[0].FreeArea:=0;
     SpriteAtlasArrayTexture.fLayerRootNodes[0].ContentWidth:=ImageWidth;
     SpriteAtlasArrayTexture.fLayerRootNodes[0].ContentHeight:=ImageHeight;
     SpriteAtlasArrayTexture.CopyIn(ImageData^,ImageWidth,ImageHeight,0,0,0);
    end;
   finally
    if assigned(ImageData) then begin
     FreeMem(ImageData);
    end;
   end;
  finally
   MemoryStream.Free;
  end;
  if assigned(SpriteAtlasArrayTexture) then begin
   MemoryStream:=TMemoryStream.Create;
   try
    aStream.Seek(0,soBeginning);
    MemoryStream.CopyFrom(aStream,aStream.Size);
    MemoryStream.Seek(0,soBeginning);
    XML:=TpvXML.Create;
    try
     if XML.Parse(MemoryStream) then begin
      for i:=0 to XML.Root.Items.Count-1 do begin
       XMLItem:=XML.Root.Items[i];
       if assigned(XMLItem) and (XMLItem is TpvXMLTag) then begin
        XMLTag:=TpvXMLTag(XMLItem);
        if XMLTag.Name='TextureAtlas' then begin
         for j:=0 to XMLTag.Items.Count-1 do begin
          XMLChildrenItem:=XMLTag.Items[j];
          if assigned(XMLChildrenItem) and (XMLChildrenItem is TpvXMLTag) then begin
           XMLChildrenTag:=TpvXMLTag(XMLChildrenItem);
           if XMLChildrenTag.Name='sprite' then begin
            SpriteName:=XMLChildrenTag.GetParameter('n','');
            if length(SpriteName)>0 then begin
             Sprite:=TpvSprite.Create;
             Sprite.ArrayTexture:=SpriteAtlasArrayTexture;
             Sprite.Name:=SpriteName;
             Sprite.x:=StrToIntDef(String(XMLChildrenTag.GetParameter('x','0')),0);
             Sprite.y:=StrToIntDef(String(XMLChildrenTag.GetParameter('y','0')),0);
             Sprite.Layer:=0;
             Sprite.Width:=StrToIntDef(String(XMLChildrenTag.GetParameter('oW',XMLChildrenTag.GetParameter('w','0'))),0);
             Sprite.Height:=StrToIntDef(String(XMLChildrenTag.GetParameter('oH',XMLChildrenTag.GetParameter('h','0'))),0);
             Sprite.TrimmedX:=StrToIntDef(String(XMLChildrenTag.GetParameter('oX','0')),0);
             Sprite.TrimmedY:=StrToIntDef(String(XMLChildrenTag.GetParameter('oY','0')),0);
             Sprite.TrimmedWidth:=StrToIntDef(String(XMLChildrenTag.GetParameter('w','0')),0);
             Sprite.TrimmedHeight:=StrToIntDef(String(XMLChildrenTag.GetParameter('h','0')),0);
             Sprite.Rotated:=XMLChildrenTag.GetParameter('r','n')='y';
             Sprite.Update;
             AddSprite(Sprite);
            end;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    finally
     XML.Free;
    end;
   finally
    MemoryStream.Free;
   end;
   result:=true;
  end;
 end;
end;

function TpvSpriteAtlas.LoadRawSprite(const aName:TpvRawByteString;aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvInt32;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1;const aDepth16Bit:boolean=false;const aTrimmedHullVectors:PpvSpriteTrimmedHullVectors=nil):TpvSprite;
var x,y,x0,y0,x1,y1,TextureIndex,LayerIndex,Layer,TotalPadding,PaddingIndex,Index:TpvInt32;
    ArrayTexture,TemporaryArrayTexture:TpvSpriteAtlasArrayTexture;
    Node:PpvSpriteAtlasArrayTextureLayerRectNode;
    Sprite:TpvSprite;
    sp,dp:PpvUInt32;
    sp16,dp16:PpvUInt64;
    p8:PpvUInt8;
    p16:PpvUInt16;
    OK,SpecialSizedArrayTexture:boolean;
    WorkImageData,TrimmedImageData:TpvPointer;
    TrimmedImageWidth:TpvInt32;
    TrimmedImageHeight:TpvInt32;
    ConvexHull2DPixels:TpvConvexHull2DPixels;
    TrimmedHullVectors:TpvSpriteTrimmedHullVectors;
    CenterX,CenterY,CenterRadius:TpvFloat;
begin

 result:=nil;

 TrimmedHullVectors:=nil;

 TrimmedImageData:=nil;

 try

  TotalPadding:=aPadding shl 1;

  ArrayTexture:=nil;

  Node:=nil;

  Layer:=-1;

  if assigned(aImageData) and (aImageWidth>0) and (aImageHeight>0) then begin

   WorkImageData:=aImageData;
   try

    if aDepth16Bit and not fDepth16Bit then begin
     // Convert to R8G8B8A8
     GetMem(WorkImageData,aImageWidth*aImageHeight*4);
     p8:=WorkImageData;
     p16:=aImageData;
     for Index:=1 to aImageWidth*aImageHeight*4 do begin
      p8^:=p16^ shr 8;
      inc(p8);
      inc(p16);
     end;
    end else if fDepth16Bit and not aDepth16Bit then begin
     // Convert to R16G1B16A16
     GetMem(WorkImageData,aImageWidth*aImageHeight*8);
     p8:=aImageData;
     p16:=WorkImageData;
     for Index:=1 to aImageWidth*aImageHeight*4 do begin
      p16^:=p8^ or (TpvUInt16(p8^) shl 8);
      inc(p8);
      inc(p16);
     end;
    end;

    x0:=0;
    y0:=0;
    x1:=aImageWidth;
    y1:=aImageHeight;

    if aAutomaticTrim then begin

     // Trim input
     if fDepth16Bit then begin

      for x:=0 to aImageWidth-1 do begin
       OK:=true;
       for y:=0 to aImageHeight-1 do begin
        sp16:=WorkImageData;
        inc(sp16,(y*aImageWidth)+x);
        if ((sp16^ shr 56) and $ff)<>0 then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        x0:=x;
       end else begin
        break;
       end;
      end;

      sp16:=WorkImageData;
      for y:=0 to aImageHeight-1 do begin
       OK:=true;
       for x:=0 to aImageWidth-1 do begin
        if ((sp16^ shr 56) and $ff)<>0 then begin
         OK:=false;
         break;
        end;
        inc(sp16);
       end;
       if OK then begin
        y0:=y;
       end else begin
        break;
       end;
      end;

      for x:=aImageWidth-1 downto 0 do begin
       OK:=true;
       for y:=0 to aImageHeight-1 do begin
        sp16:=WorkImageData;
        inc(sp16,(y*aImageWidth)+x);
        if ((sp16^ shr 56) and $ff)<>0 then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        x1:=x+1;
       end else begin
        break;
       end;
      end;

      for y:=aImageHeight-1 downto 0 do begin
       OK:=true;
       sp16:=WorkImageData;
       inc(sp16,y*aImageWidth);
       for x:=0 to aImageWidth-1 do begin
        if ((sp16^ shr 56) and $ff)<>0 then begin
         OK:=false;
         break;
        end;
        inc(sp16);
       end;
       if OK then begin
        y1:=y+1;
       end else begin
        break;
       end;
      end;

     end else begin

      for x:=0 to aImageWidth-1 do begin
       OK:=true;
       for y:=0 to aImageHeight-1 do begin
        sp:=WorkImageData;
        inc(sp,(y*aImageWidth)+x);
        if (sp^ and $ff000000)<>0 then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        x0:=x;
       end else begin
        break;
       end;
      end;

      sp:=WorkImageData;
      for y:=0 to aImageHeight-1 do begin
       OK:=true;
       for x:=0 to aImageWidth-1 do begin
        if (sp^ and $ff000000)<>0 then begin
         OK:=false;
         break;
        end;
        inc(sp);
       end;
       if OK then begin
        y0:=y;
       end else begin
        break;
       end;
      end;

      for x:=aImageWidth-1 downto 0 do begin
       OK:=true;
       for y:=0 to aImageHeight-1 do begin
        sp:=WorkImageData;
        inc(sp,(y*aImageWidth)+x);
        if (sp^ and $ff000000)<>0 then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        x1:=x+1;
       end else begin
        break;
       end;
      end;

      for y:=aImageHeight-1 downto 0 do begin
       OK:=true;
       sp:=WorkImageData;
       inc(sp,y*aImageWidth);
       for x:=0 to aImageWidth-1 do begin
        if (sp^ and $ff000000)<>0 then begin
         OK:=false;
         break;
        end;
        inc(sp);
       end;
       if OK then begin
        y1:=y+1;
       end else begin
        break;
       end;
      end;

     end;

    end;

    TrimmedImageData:=nil;

    try

     if (x0<x1) and (y0<y1) and not ((x0=0) and (y0=0) and (x1=aImageWidth) and (y1=aImageHeight)) then begin
      if aTrimPadding>0 then begin
       x0:=Max(0,x0-aTrimPadding);
       y0:=Max(0,y0-aTrimPadding);
       x1:=Min(aImageWidth,x1+aTrimPadding);
       y1:=Min(aImageHeight,y1+aTrimPadding);
      end;
      TrimmedImageWidth:=x1-x0;
      TrimmedImageHeight:=y1-y0;
      if fDepth16Bit then begin
       GetMem(TrimmedImageData,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt64));
       dp16:=TrimmedImageData;
       for y:=y0 to y1-1 do begin
        sp16:=WorkImageData;
        inc(sp16,(y*aImageWidth)+x0);
        for x:=x0 to x1-1 do begin
         dp16^:=sp16^;
         inc(sp16);
         inc(dp16);
        end;
       end;
      end else begin
       GetMem(TrimmedImageData,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt32));
       dp:=TrimmedImageData;
       for y:=y0 to y1-1 do begin
        sp:=WorkImageData;
        inc(sp,(y*aImageWidth)+x0);
        for x:=x0 to x1-1 do begin
         dp^:=sp^;
         inc(sp);
         inc(dp);
        end;
       end;
      end;
     end else begin
      TrimmedImageWidth:=aImageWidth;
      TrimmedImageHeight:=aImageHeight;
      if fDepth16Bit then begin
       GetMem(TrimmedImageData,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt64));
       Move(WorkImageData^,TrimmedImageData^,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt64));
      end else begin
       GetMem(TrimmedImageData,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt32));
       Move(WorkImageData^,TrimmedImageData^,TrimmedImageWidth*TrimmedImageHeight*SizeOf(TpvUInt32));
      end;
      x0:=0;
      y0:=0;
     end;

    finally
     if WorkImageData<>aImageData then begin
      FreeMem(WorkImageData);
     end;
    end;

    if fUseConvexHullTrimming and ((TrimmedImageWidth*TrimmedImageHeight)>0) then begin
     if assigned(aTrimmedHullVectors) then begin
      TrimmedHullVectors:=copy(aTrimmedHullVectors^);
      for x:=0 to length(TrimmedHullVectors)-1 do begin
       TrimmedHullVectors[x].xy:=TrimmedHullVectors[x].xy-TpvVector2.InlineableCreate(x0,y0);
      end;
     end else if aAutomaticTrim then begin
      ConvexHull2DPixels:=nil;
      try
       SetLength(ConvexHull2DPixels,TrimmedImageWidth*TrimmedImageHeight);
       if fDepth16Bit then begin
        for y:=0 to TrimmedImageHeight-1 do begin
         for x:=0 to TrimmedImageWidth-1 do begin
          sp16:=TrimmedImageData;
          inc(sp16,(y*TrimmedImageWidth)+x);
          ConvexHull2DPixels[(y*TrimmedImageWidth)+x]:=((sp16^ shr 56) and $ff)<>0;
         end;
        end;
       end else begin
        for y:=0 to TrimmedImageHeight-1 do begin
         for x:=0 to TrimmedImageWidth-1 do begin
          sp:=TrimmedImageData;
          inc(sp,(y*TrimmedImageWidth)+x);
          ConvexHull2DPixels[(y*TrimmedImageWidth)+x]:=(sp^ and $ff000000)<>0;
         end;
        end;
       end;
       GetConvexHull2D(ConvexHull2DPixels,
                       TrimmedImageWidth,
                       TrimmedImageHeight,
                       TrimmedHullVectors,
                       8,
                       CenterX,
                       CenterY,
                       CenterRadius,
                       1.0,//Max(1.0,aPadding*0.5),
                       1.0,//Max(1.0,aPadding*0.5),
                       2);
      finally
       ConvexHull2DPixels:=nil;
      end;
     end;
    end;

    ArrayTexture:=nil;

    // Get free texture area
    for TextureIndex:=0 to fCountArrayTextures-1 do begin
     TemporaryArrayTexture:=fArrayTextures[TextureIndex];
     if not TemporaryArrayTexture.fSpecialSizedArrayTexture then begin
      for LayerIndex:=0 to TemporaryArrayTexture.fLayers-1 do begin
       if assigned(TemporaryArrayTexture.fLayerRootNodes[LayerIndex]) then begin
        // Including 2px texel bilinear interpolation protection border pixels
        Node:=InsertTextureRectNode(TemporaryArrayTexture.fLayerRootNodes[LayerIndex],
                                    TrimmedImageWidth+TotalPadding,
                                    TrimmedImageHeight+TotalPadding,
                                    (TrimmedImageWidth+TotalPadding)*(TrimmedImageHeight+TotalPadding));
        if assigned(TemporaryArrayTexture) and assigned(Node) then begin
         ArrayTexture:=TemporaryArrayTexture;
         Layer:=LayerIndex;
         break;
        end;
       end;
       if (Layer>=0) and (assigned(ArrayTexture) and assigned(Node)) then begin
        break;
       end;
      end;
     end;
    end;

    SpecialSizedArrayTexture:=false;

    // First try to resize a already existent atlas array texture by an one new layer, but not on
    // special sized atlas array textures for big sprites, which are larger than a normal atlas
    // array texture in width and height, or for external imported sprite atlases
    if (Layer<0) or not (assigned(ArrayTexture) and assigned(Node)) then begin
     for TextureIndex:=0 to fCountArrayTextures-1 do begin
      TemporaryArrayTexture:=fArrayTextures[TextureIndex];
      if ((TrimmedImageWidth+TotalPadding)<=TemporaryArrayTexture.fWidth) and
         ((TrimmedImageHeight+TotalPadding)<=TemporaryArrayTexture.fHeight) and
         (TemporaryArrayTexture.fLayers<fMaximumCountArrayLayers) and
         not TemporaryArrayTexture.fSpecialSizedArrayTexture then begin
       LayerIndex:=TemporaryArrayTexture.fLayers;
       TemporaryArrayTexture.Resize(TemporaryArrayTexture.fWidth,TemporaryArrayTexture.fHeight,LayerIndex+1);
       Node:=InsertTextureRectNode(TemporaryArrayTexture.fLayerRootNodes[LayerIndex],
                                   TrimmedImageWidth+TotalPadding,
                                   TrimmedImageHeight+TotalPadding,
                                   (TrimmedImageWidth+TotalPadding)*(TrimmedImageHeight+TotalPadding));
       if assigned(Node) then begin
        ArrayTexture:=TemporaryArrayTexture;
        Layer:=LayerIndex;
        break;
       end else begin
        // Undo for saving vRAM space
        TemporaryArrayTexture.Resize(TemporaryArrayTexture.fWidth,TemporaryArrayTexture.fHeight,TemporaryArrayTexture.fLayers-1);
       end;
      end;
     end;
    end;

    // Otherwise allocate a fresh new atlas array texture
    if (Layer<0) or not (assigned(ArrayTexture) and assigned(Node)) then begin
     Layer:=0;
     SpecialSizedArrayTexture:=(fWidth<=TrimmedImageWidth) or (fHeight<=TrimmedImageHeight);
     ArrayTexture:=TpvSpriteAtlasArrayTexture.Create(fSRGB,fDepth16Bit);
     ArrayTexture.fSpecialSizedArrayTexture:=SpecialSizedArrayTexture;
     ArrayTexture.Resize(Max(fWidth,TrimmedImageWidth),Max(fHeight,TrimmedImageHeight),1);
     if length(fArrayTextures)<(fCountArrayTextures+1) then begin
      SetLength(fArrayTextures,(fCountArrayTextures+1)*2);
     end;
     fArrayTextures[fCountArrayTextures]:=ArrayTexture;
     inc(fCountArrayTextures);
     ArrayTexture.Dirty:=true;
     if SpecialSizedArrayTexture then begin
      Node:=InsertTextureRectNode(ArrayTexture.fLayerRootNodes[Layer],
                                  TrimmedImageWidth,
                                  TrimmedImageHeight,
                                  TrimmedImageWidth*TrimmedImageHeight);
     end else begin
      Node:=InsertTextureRectNode(ArrayTexture.fLayerRootNodes[Layer],
                                  TrimmedImageWidth+TotalPadding,
                                  TrimmedImageHeight+TotalPadding,
                                  (TrimmedImageWidth+TotalPadding)*(TrimmedImageHeight+TotalPadding));
     end;
    end;

    Assert((Layer>=0) and (assigned(ArrayTexture) and (Layer<ArrayTexture.fLayers) and assigned(Node)));

    if not ((Layer>=0) and (assigned(ArrayTexture) and (Layer<ArrayTexture.fLayers) and assigned(Node))) then begin
     raise EpvSpriteAtlas.Create('Can''t load raw sprite');
    end;

    begin
     Sprite:=TpvSprite.Create;
     Sprite.ArrayTexture:=ArrayTexture;
     Sprite.Layer:=Layer;
     Sprite.Name:=aName;
     if SpecialSizedArrayTexture then begin
      Sprite.fX:=Node^.x;
      Sprite.fY:=Node^.y;
      Sprite.fWidth:=aImageWidth;
      Sprite.fHeight:=aImageHeight;
      Sprite.fTrimmedX:=x0;
      Sprite.fTrimmedY:=y0;
      Sprite.fTrimmedWidth:=TrimmedImageWidth;
      Sprite.fTrimmedHeight:=TrimmedImageHeight;
      Sprite.fTrimmedHullVectors:=TrimmedHullVectors;
      Sprite.Rotated:=false;
      AddSprite(Sprite);
      if fDepth16Bit then begin
       for y:=0 to TrimmedImageHeight-1 do begin
        sp16:=TrimmedImageData;
        inc(sp16,y*TrimmedImageWidth);
        dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        Move(sp16^,dp16^,TrimmedImageWidth*SizeOf(TpvUInt64));
       end;
      end else begin
       for y:=0 to TrimmedImageHeight-1 do begin
        sp:=TrimmedImageData;
        inc(sp,y*TrimmedImageWidth);
        dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        Move(sp^,dp^,TrimmedImageWidth*SizeOf(TpvUInt32));
       end;
      end;
     end else begin
      Sprite.fX:=Node^.x+aPadding;
      Sprite.fY:=Node^.y+aPadding;
      Sprite.fWidth:=aImageWidth;
      Sprite.fHeight:=aImageHeight;
      Sprite.fTrimmedX:=x0;
      Sprite.fTrimmedY:=y0;
      Sprite.fTrimmedWidth:=TrimmedImageWidth;
      Sprite.fTrimmedHeight:=TrimmedImageHeight;
      Sprite.fTrimmedHullVectors:=TrimmedHullVectors;
      Sprite.Rotated:=false;
      AddSprite(Sprite);
      if fDepth16Bit then begin
       for y:=0 to TrimmedImageHeight-1 do begin
        sp16:=TrimmedImageData;
        inc(sp16,y*TrimmedImageWidth);
        dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        Move(sp16^,dp16^,TrimmedImageWidth*SizeOf(TpvUInt64));
       end;
       begin
        sp16:=TrimmedImageData;
        for PaddingIndex:=-1 downto -aPadding do begin
         dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+PaddingIndex,Layer));
         Move(sp16^,dp16^,TrimmedImageWidth*SizeOf(TpvUInt64));
        end;
        sp16:=TrimmedImageData;
        inc(sp16,(TrimmedImageHeight-1)*TrimmedImageWidth);
        for PaddingIndex:=0 to aPadding-1 do begin
         dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+TrimmedImageHeight+PaddingIndex,Layer));
         Move(sp16^,dp16^,TrimmedImageWidth*SizeOf(TpvUInt64));
        end;
       end;
       for y:=-1 to TrimmedImageHeight do begin
        sp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        for PaddingIndex:=-1 downto -aPadding do begin
         dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+PaddingIndex,Sprite.y+y,Layer));
         dp16^:=sp16^;
        end;
        sp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+(TrimmedImageWidth-1),Sprite.y+y,Layer));
        for PaddingIndex:=0 to aPadding-1 do begin
         dp16:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+TrimmedImageWidth+PaddingIndex,Sprite.y+y,Layer));
         dp16^:=sp16^;
        end;
       end;
      end else begin
       for y:=0 to TrimmedImageHeight-1 do begin
        sp:=TrimmedImageData;
        inc(sp,y*TrimmedImageWidth);
        dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        Move(sp^,dp^,TrimmedImageWidth*SizeOf(TpvUInt32));
       end;
       begin
        sp:=TrimmedImageData;
        for PaddingIndex:=-1 downto -aPadding do begin
         dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+PaddingIndex,Layer));
         Move(sp^,dp^,TrimmedImageWidth*SizeOf(TpvUInt32));
        end;
        sp:=TrimmedImageData;
        inc(sp,(TrimmedImageHeight-1)*TrimmedImageWidth);
        for PaddingIndex:=0 to aPadding-1 do begin
         dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+TrimmedImageHeight+PaddingIndex,Layer));
         Move(sp^,dp^,TrimmedImageWidth*SizeOf(TpvUInt32));
        end;
       end;
       for y:=-1 to TrimmedImageHeight do begin
        sp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x,Sprite.y+y,Layer));
        for PaddingIndex:=-1 downto -aPadding do begin
         dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+PaddingIndex,Sprite.y+y,Layer));
         dp^:=sp^;
        end;
        sp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+(TrimmedImageWidth-1),Sprite.y+y,Layer));
        for PaddingIndex:=0 to aPadding-1 do begin
         dp:=TpvPointer(ArrayTexture.GetTexelPointer(Sprite.x+TrimmedImageWidth+PaddingIndex,Sprite.y+y,Layer));
         dp^:=sp^;
        end;
       end;
      end;
     end;
     ArrayTexture.Dirty:=true;
    end;

   finally

    if assigned(TrimmedImageData) then begin
     FreeMem(TrimmedImageData);
    end;

   end;

   Sprite.Update;

   result:=Sprite;

  end else begin

   raise EpvSpriteAtlas.Create('Can''t load sprite');

  end;

 finally

  TrimmedHullVectors:=nil;

 end;

end;

function TpvSpriteAtlas.LoadSignedDistanceFieldSprite(const aName:TpvRawByteString;const aVectorPath:TpvVectorPath;const aImageWidth,aImageHeight:TpvInt32;const aScale:TpvDouble;const aOffsetX:TpvDouble;const aOffsetY:TpvDouble;const aAutomaticTrim:boolean;const aPadding:TpvInt32;const aTrimPadding:TpvInt32;const aSDFVariant:TpvSignedDistanceField2DVariant;const aProtectBorder:boolean):TpvSprite;
var SignedDistanceField:TpvSignedDistanceField2D;
    VectorPathShape:TpvVectorPathShape;
begin
 SignedDistanceField.Pixels:=nil;
 try
  SignedDistanceField.Width:=aImageWidth;
  SignedDistanceField.Height:=aImageHeight;
  SetLength(SignedDistanceField.Pixels,aImageWidth*aImageHeight);
  VectorPathShape:=TpvVectorPathShape.Create(aVectorPath);
  try
   TpvSignedDistanceField2DGenerator.Generate(SignedDistanceField,VectorPathShape,aScale,aOffsetX,aOffsetY,aSDFVariant,aProtectBorder);
  finally
   FreeAndNil(VectorPathShape);
  end;
  result:=LoadRawSprite(aName,@SignedDistanceField.Pixels[0],aImageWidth,aImageHeight,aAutomaticTrim,aPadding,aTrimPadding);
  result.SignedDistanceField:=true;
  result.SignedDistanceFieldVariant:=aSDFVariant;
 finally
  SignedDistanceField.Pixels:=nil;
 end;
end;

function TpvSpriteAtlas.LoadSignedDistanceFieldSprite(const aName,aSVGPath:TpvRawByteString;const aImageWidth,aImageHeight:TpvInt32;const aScale:TpvDouble;const aOffsetX:TpvDouble;const aOffsetY:TpvDouble;const aVectorPathFillRule:TpvVectorPathFillRule;const aAutomaticTrim:boolean;const aPadding:TpvInt32;const aTrimPadding:TpvInt32;const aSDFVariant:TpvSignedDistanceField2DVariant;const aProtectBorder:boolean):TpvSprite;
var VectorPath:TpvVectorPath;
begin
 VectorPath:=TpvVectorPath.CreateFromSVGPath(aSVGPath);
 try
  VectorPath.FillRule:=aVectorPathFillRule;
  result:=LoadSignedDistanceFieldSprite(aName,VectorPath,aImageWidth,aImageHeight,aScale,aOffsetX,aOffsetY,aAutomaticTrim,aPadding,aTrimPadding,aSDFVariant,aProtectBorder);
 finally
  VectorPath.Free;
 end;
end;

function TpvSpriteAtlas.LoadSprite(const aName:TpvRawByteString;aStream:TStream;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1):TpvSprite;
var InputImageData,ImageData:TpvPointer;
    InputImageDataSize,ImageWidth,ImageHeight:TpvInt32;
begin

 result:=nil;

 if assigned(aStream) then begin

  try

   InputImageDataSize:=aStream.Size;
   GetMem(InputImageData,InputImageDataSize);
   try

    aStream.Seek(0,soBeginning);
    aStream.Read(InputImageData^,InputImageDataSize);
    ImageData:=nil;
    try

     if LoadImage(InputImageData,InputImageDataSize,ImageData,ImageWidth,ImageHeight) then begin

      result:=LoadRawSprite(aName,ImageData,ImageWidth,ImageHeight,aAutomaticTrim,aPadding,aTrimPadding);

     end else begin
      raise EpvSpriteAtlas.Create('Can''t load image');
     end;

    finally

     if assigned(ImageData) then begin
      FreeMem(ImageData);
     end;

    end;

   finally

    if assigned(InputImageData) then begin
     FreeMem(InputImageData);
    end;

   end;

  finally

  end;

 end else begin

  raise EpvSpriteAtlas.Create('Can''t load sprite');

 end;

end;

function TpvSpriteAtlas.LoadSprites(const aName:TpvRawByteString;aStream:TStream;aSpriteWidth:TpvInt32=64;aSpriteHeight:TpvInt32=64;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1):TpvSprites;
var InputImageData,ImageData,SpriteData:TpvPointer;
    InputImageDataSize,ImageWidth,ImageHeight,Count,x,y,sy,sw,sh:TpvInt32;
    sp,dp:PpvUInt32;
begin
 result:=nil;

 if assigned(aStream) and (aSpriteWidth>0) and (aSpriteHeight>0) then begin

  try

   InputImageDataSize:=aStream.Size;
   GetMem(InputImageData,InputImageDataSize);
   try

    aStream.Seek(0,soBeginning);
    aStream.Read(InputImageData^,InputImageDataSize);
    ImageData:=nil;
    try

     if LoadImage(InputImageData,InputImageDataSize,ImageData,ImageWidth,ImageHeight) then begin

      GetMem(SpriteData,(aSpriteWidth*aSpriteHeight)*SizeOf(TpvUInt32));
      try

       Count:=((ImageWidth+(aSpriteWidth-1)) div aSpriteWidth)*((ImageHeight+(aSpriteHeight-1)) div aSpriteHeight);
       SetLength(result,Count);

       Count:=0;

       y:=0;
       while y<ImageHeight do begin

        sh:=ImageHeight-y;
        if sh<0 then begin
         sh:=0;
        end else if sh>aSpriteHeight then begin
         sh:=aSpriteHeight;
        end;

        if sh>0 then begin

         x:=0;
         while x<ImageWidth do begin

          FillChar(SpriteData^,(aSpriteWidth*aSpriteHeight)*SizeOf(TpvUInt32),AnsiChar(#0));

          sw:=ImageWidth-x;
          if sw<0 then begin
           sw:=0;
          end else if sw>aSpriteWidth then begin
           sw:=aSpriteWidth;
          end;

          if sw>0 then begin

           sp:=ImageData;
           inc(sp,(ImageWidth*y)+x);

           dp:=SpriteData;

           for sy:=0 to sh-1 do begin
            Move(sp^,dp^,sw*SizeOf(TpvUInt32));
            inc(sp,ImageWidth);
            inc(dp,aSpriteWidth);
           end;

           result[Count]:=LoadRawSprite(aName+TpvRawByteString(IntToStr(Count)),SpriteData,aSpriteWidth,aSpriteHeight,aAutomaticTrim,aPadding,aTrimPadding);

           inc(Count);

          end else begin

           break;

          end;

          inc(x,aSpriteWidth);
         end;

        end else begin

         break;

        end;

        inc(y,aSpriteHeight);
       end;

       SetLength(result,Count);

      finally

       FreeMem(SpriteData);

      end;

     end else begin

      raise EpvSpriteAtlas.Create('Can''t load image');

     end;

    finally

     if assigned(ImageData) then begin
      FreeMem(ImageData);
     end;

    end;

   finally

    if assigned(InputImageData) then begin
     FreeMem(InputImageData);
    end;

   end;

  finally

  end;

 end else begin

  raise EpvSpriteAtlas.Create('Can''t load sprites');

 end;

end;

procedure TpvSpriteAtlas.LoadFromStream(const aStream:TStream);
var Archive:TpvArchiveZIP;
    Stream:TMemoryStream;
    Entry:TpvArchiveZIPEntry;
    Index,SubIndex,SubSubIndex:TpvSizeInt;
    ArrayTexture:TpvSpriteAtlasArrayTexture;
    Sprite:TpvSprite;
    ImageData:TpvPointer;
    ImageWidth,ImageHeight:TpvInt32;
    PNGPixelFormat:TpvPNGPixelFormat;
    p8:PpvUInt8;
    p16:PpvUInt16;
    BufferedStream:TpvSimpleBufferedStream;
 function ReadUInt8:TpvUInt8;
 begin
  BufferedStream.ReadBuffer(result,SizeOf(TpvUInt8));
 end;
 function ReadUInt16:TpvUInt16;
 begin
  result:=ReadUInt8;
  result:=result or (TpvUInt16(ReadUInt8) shl 8);
 end;
 function ReadUInt32:TpvUInt32;
 begin
  result:=ReadUInt8;
  result:=result or (TpvUInt32(ReadUInt8) shl 8);
  result:=result or (TpvUInt32(ReadUInt8) shl 16);
  result:=result or (TpvUInt32(ReadUInt8) shl 24);
 end;
 function ReadInt32:TpvInt32;
 begin
  result:=ReadUInt32;
 end;
 function ReadUInt64:TpvUInt64;
 begin
  result:=ReadUInt8;
  result:=result or (TpvUInt64(ReadUInt8) shl 8);
  result:=result or (TpvUInt64(ReadUInt8) shl 16);
  result:=result or (TpvUInt64(ReadUInt8) shl 24);
  result:=result or (TpvUInt64(ReadUInt8) shl 32);
  result:=result or (TpvUInt64(ReadUInt8) shl 40);
  result:=result or (TpvUInt64(ReadUInt8) shl 48);
  result:=result or (TpvUInt64(ReadUInt8) shl 56);
 end;
 function ReadInt64:TpvInt64;
 begin
  result:=ReadUInt64;
 end;
 function ReadFloat:TpvFloat;
 begin
  PpvUInt32(TpvPointer(@result))^:=ReadUInt32;
 end;
 function ReadDouble:TpvDouble;
 begin
  PpvUInt64(TpvPointer(@result))^:=ReadUInt64;
 end;
 function ReadString:TpvRawByteString;
 begin
  result:='';
  SetLength(result,ReadInt32);
  if length(result)>0 then begin
   BufferedStream.ReadBuffer(result[1],length(result));
  end;
 end;
var FileGUID:TGUID;
    ui8:TpvUInt8;
    NewImageData:TpvPointer;
    WidthValue,HeightValue,LayersValue,CountSprites,CountTrimmedHullVectors:TpvInt32;
    IsQOI,SRGBQOI,OK:Boolean;
begin

 Unload;

 for Index:=0 to fCountArrayTextures-1 do begin
  FreeAndNil(fArrayTextures[Index]);
 end;

 fArrayTextures:=nil;

 ClearAll;

 Archive:=TpvArchiveZIP.Create;
 try

  Archive.LoadFromStream(aStream);

  Entry:=Archive.Entries.Find('sprites.dat');

  if not assigned(Entry) then begin
   raise EpvSpriteAtlas.Create('Missing sprites.dat');
  end;

  Stream:=TMemoryStream.Create;
  try
   Entry.SaveToStream(Stream);

   BufferedStream:=TpvSimpleBufferedStream.Create(Stream,false,4096);
   try

    FileGUID.D1:=ReadUInt32;
    FileGUID.D2:=ReadUInt16;
    FileGUID.D3:=ReadUInt16;
    FileGUID.D4[0]:=ReadUInt8;
    FileGUID.D4[1]:=ReadUInt8;
    FileGUID.D4[2]:=ReadUInt8;
    FileGUID.D4[3]:=ReadUInt8;
    FileGUID.D4[4]:=ReadUInt8;
    FileGUID.D4[5]:=ReadUInt8;
    FileGUID.D4[6]:=ReadUInt8;
    FileGUID.D4[7]:=ReadUInt8;

    if not CompareMem(@TpvSpriteAtlas.FileFormatGUID,@FileGUID,SizeOf(TGUID)) then begin
     raise EpvSpriteAtlas.Create('Mismatch file format GUID');
    end;

    fWidth:=ReadInt32;
    fHeight:=ReadInt32;
    fMaximumCountArrayLayers:=ReadInt32;
    ui8:=ReadUInt8;
    fMipMaps:=(ui8 and 1)<>0;
    fSRGB:=(ui8 and 2)<>0;
    fUseConvexHullTrimming:=(ui8 and 4)<>0;
    fDepth16Bit:=(ui8 and 8)<>0;
    fCountArrayTextures:=ReadInt32;
    CountSprites:=ReadInt32;

    SetLength(fArrayTextures,fCountArrayTextures);

    for Index:=0 to fCountArrayTextures-1 do begin
     fArrayTextures[Index]:=TpvSpriteAtlasArrayTexture.Create(fSRGB,fDepth16Bit);
    end;

    for Index:=0 to fCountArrayTextures-1 do begin
     ArrayTexture:=fArrayTextures[Index];
     WidthValue:=ReadInt32;
     HeightValue:=ReadInt32;
     LayersValue:=ReadInt32;
     ArrayTexture.Resize(WidthValue,HeightValue,LayersValue);
     ui8:=ReadUInt8;
     ArrayTexture.fSpecialSizedArrayTexture:=true;
     ArrayTexture.fDirty:=true;
    end;

    for Index:=0 to CountSprites-1 do begin
     Sprite:=TpvSprite.Create;
     try
      Sprite.fName:=ReadString;
      SubIndex:=ReadInt32;
      if (SubIndex<0) or (SubIndex>=fCountArrayTextures) then begin
       raise EpvSpriteAtlas.Create('Sprite array texture index out of range');
      end;
      Sprite.fArrayTexture:=fArrayTextures[SubIndex];
      ui8:=ReadUInt8;
      Sprite.fFlags:=[];
      if (ui8 and 1)<>0 then begin
       Include(Sprite.fFlags,TpvSpriteFlag.SignedDistanceField);
      end;
      if (ui8 and 2)<>0 then begin
       Include(Sprite.fFlags,TpvSpriteFlag.Rotated);
      end;
      Sprite.fX:=ReadInt32;
      Sprite.fY:=ReadInt32;
      Sprite.fLayer:=ReadInt32;
      Sprite.fWidth:=ReadInt32;
      Sprite.fHeight:=ReadInt32;
      Sprite.fTrimmedX:=ReadInt32;
      Sprite.fTrimmedY:=ReadInt32;
      Sprite.fTrimmedWidth:=ReadInt32;
      Sprite.fTrimmedHeight:=ReadInt32;
      Sprite.fOffsetX:=ReadFloat;
      Sprite.fOffsetY:=ReadFloat;
      Sprite.fScaleX:=ReadFloat;
      Sprite.fScaleY:=ReadFloat;
      if TpvSpriteFlag.SignedDistanceField in Sprite.fFlags then begin
       Sprite.fSignedDistanceFieldVariant:=TpvSignedDistanceField2DVariant(TpvUInt8(ReadUInt8));
      end;
      Sprite.fTrimmedHullVectors:=nil;
      if (ui8 and 4)<>0 then begin
       CountTrimmedHullVectors:=ReadInt32;
       if CountTrimmedHullVectors>0 then begin
        SetLength(Sprite.fTrimmedHullVectors,CountTrimmedHullVectors);
        for SubIndex:=0 to CountTrimmedHullVectors-1 do begin
         Sprite.fTrimmedHullVectors[SubIndex].x:=ReadFloat;
         Sprite.fTrimmedHullVectors[SubIndex].y:=ReadFloat;
        end;
       end;
      end;
      Sprite.Update;
     finally
      AddSprite(Sprite);
     end;
    end;

   finally
    BufferedStream.Free;
   end;

  finally
   Stream.Free;
  end;

  for Index:=0 to fCountArrayTextures-1 do begin
   ArrayTexture:=fArrayTextures[Index];
   if assigned(ArrayTexture) then begin
    for SubIndex:=0 to ArrayTexture.fLayers-1 do begin
     IsQOI:=false;
     Entry:=Archive.Entries.Find(TpvRawByteString(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.png'));
     if not assigned(Entry) then begin
      Entry:=Archive.Entries.Find(TpvRawByteString(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.qoi'));
      if assigned(Entry) then begin
       IsQOI:=true;
      end else begin
       raise EpvSpriteAtlas.Create('Missing '+IntToStr(Index)+'_'+IntToStr(SubIndex)+'.[png|qoi]');
      end;
     end;
     Stream:=TMemoryStream.Create;
     try
      Entry.SaveToStream(Stream);
      ImageData:=nil;
      try
       OK:=false;
       if IsQOI then begin
        if LoadQOIImage(TMemoryStream(Stream).Memory,
                        TMemoryStream(Stream).Size,
                        ImageData,
                        ImageWidth,
                        ImageHeight,
                        false,
                        SRGBQOI) then begin
         OK:=true;
         PNGPixelFormat:=TpvPNGPixelFormat.R8G8B8A8;
        end;
       end else begin
        if LoadPNGImage(TMemoryStream(Stream).Memory,
                        TMemoryStream(Stream).Size,
                        ImageData,
                        ImageWidth,
                        ImageHeight,
                        false,
                        PNGPixelFormat) then begin
         OK:=true;
        end;
       end;
       if OK then begin
        if (ImageWidth=ArrayTexture.fWidth) and
           (ImageHeight=ArrayTexture.fHeight) then begin
         if fDepth16Bit then begin
          if PNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8 then begin
           // Convert to R16G1B16A16
           GetMem(NewImageData,ImageWidth*ImageHeight*8);
           try
            p8:=ImageData;
            p16:=NewImageData;
            for SubSubIndex:=1 to ImageWidth*ImageHeight*4 do begin
             p16^:=p8^ or (TpvUInt16(p8^) shl 8);
             inc(p8);
             inc(p16);
            end;
           finally
            FreeMem(ImageData);
            ImageData:=NewImageData;
           end;
          end;
         end else begin
          if PNGPixelFormat=TpvPNGPixelFormat.R16G16B16A16 then begin
           // Convert to R8G8B8A8 in-place
           p8:=ImageData;
           p16:=ImageData;
           for SubSubIndex:=1 to ImageWidth*ImageHeight*4 do begin
            p8^:=p16^ shr 8;
            inc(p8);
            inc(p16);
           end;
          end;
         end;
         ArrayTexture.fLayerRootNodes[SubIndex].FreeArea:=0;
         ArrayTexture.fLayerRootNodes[SubIndex].ContentWidth:=ImageWidth;
         ArrayTexture.fLayerRootNodes[SubIndex].ContentHeight:=ImageHeight;
         ArrayTexture.CopyIn(ImageData^,ImageWidth,ImageHeight,0,0,SubIndex);
        end else begin
         if IsQOI then begin
          raise EpvSpriteAtlas.Create(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.qoi has wrong size');
         end else begin
          raise EpvSpriteAtlas.Create(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.png has wrong size');
         end;
        end;
       end else begin
        if IsQOI then begin
         raise EpvSpriteAtlas.Create('Corrupt '+IntToStr(Index)+'_'+IntToStr(SubIndex)+'.qoi');
        end else begin
         raise EpvSpriteAtlas.Create('Corrupt '+IntToStr(Index)+'_'+IntToStr(SubIndex)+'.png');
        end;
       end;
      finally
       if assigned(ImageData) then begin
        FreeMem(ImageData);
       end;
      end;
     finally
      Stream.Free;
     end;
    end;
   end;
  end;

 finally
  Archive.Free;
 end;

end;

procedure TpvSpriteAtlas.LoadFromFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvSpriteAtlas.SaveToStream(const aStream:TStream;const aFast:boolean=false);
var Archive:TpvArchiveZIP;
    Entry:TpvArchiveZIPEntry;
    Index,SubIndex,SubSubIndex:TpvSizeInt;
    ArrayTexture:TpvSpriteAtlasArrayTexture;
    Sprite:TpvSprite;
    BufferedStream:TpvSimpleBufferedStream;
 procedure WriteUInt8(const aValue:TpvUInt8);
 begin
  BufferedStream.WriteBuffer(aValue,SizeOf(TpvUInt8));
 end;
 procedure WriteUInt16(const aValue:TpvUInt16);
 begin
  WriteUInt8(TpVUInt8(aValue shr 0));
  WriteUInt8(TpVUInt8(aValue shr 8));
 end;
 procedure WriteUInt32(const aValue:TpvUInt32);
 begin
  WriteUInt8(TpVUInt8(aValue shr 0));
  WriteUInt8(TpVUInt8(aValue shr 8));
  WriteUInt8(TpVUInt8(aValue shr 16));
  WriteUInt8(TpVUInt8(aValue shr 24));
 end;
 procedure WriteInt32(const aValue:TpvInt32);
 begin
  WriteUInt32(aValue);
 end;
 procedure WriteUInt64(const aValue:TpvUInt64);
 begin
  WriteUInt8(TpVUInt8(aValue shr 0));
  WriteUInt8(TpVUInt8(aValue shr 8));
  WriteUInt8(TpVUInt8(aValue shr 16));
  WriteUInt8(TpVUInt8(aValue shr 24));
  WriteUInt8(TpVUInt8(aValue shr 32));
  WriteUInt8(TpVUInt8(aValue shr 40));
  WriteUInt8(TpVUInt8(aValue shr 48));
  WriteUInt8(TpVUInt8(aValue shr 56));
 end;
 procedure WriteInt64(const aValue:TpvInt64);
 begin
  WriteUInt64(aValue);
 end;
 procedure WriteFloat(const aValue:TpvFloat);
 begin
  WriteUInt32(PpvUInt32(TpvPointer(@aValue))^);
 end;
 procedure WriteDouble(const aValue:TpvDouble);
 begin
  WriteUInt64(PpvUInt64(TpvPointer(@aValue))^);
 end;
 procedure WriteString(const aValue:TpvRawByteString);
 begin
  WriteInt32(length(aValue));
  if length(aValue)>0 then begin
   BufferedStream.WriteBuffer(aValue[1],length(aValue));
  end;
 end;
begin

 Archive:=TpvArchiveZIP.Create;
 try

  Entry:=Archive.Entries.Add('sprites.dat');
  try

   Entry.Stream:=TMemoryStream.Create;
   try

    BufferedStream:=TpvSimpleBufferedStream.Create(Entry.Stream,false,4096);
    try

     WriteUInt32(TpvSpriteAtlas.FileFormatGUID.D1);
     WriteUInt16(TpvSpriteAtlas.FileFormatGUID.D2);
     WriteUInt16(TpvSpriteAtlas.FileFormatGUID.D3);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[0]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[1]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[2]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[3]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[4]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[5]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[6]);
     WriteUInt8(TpvSpriteAtlas.FileFormatGUID.D4[7]);

     WriteInt32(fWidth);
     WriteInt32(fHeight);
     WriteInt32(fMaximumCountArrayLayers);
     WriteUInt8((TpvUInt8(ord(fMipMaps) and 1) shl 0) or
                (TpvUInt8(ord(fsRGB) and 1) shl 1) or
                (TpvUInt8(ord(fUseConvexHullTrimming) and 1) shl 2) or
                (TpvUInt8(ord(fDepth16Bit) and 1) shl 3));
     WriteInt32(fCountArrayTextures);
     WriteInt32(fList.Count);

     for Index:=0 to fCountArrayTextures-1 do begin
      ArrayTexture:=fArrayTextures[Index];
      WriteInt32(ArrayTexture.fWidth);
      WriteInt32(ArrayTexture.fHeight);
      WriteInt32(ArrayTexture.fLayers);
      WriteUInt8(0);
     end;

     for Index:=0 to fList.Count-1 do begin
      Sprite:=fList[Index];
      if assigned(Sprite) then begin
       WriteString(Sprite.fName);
       SubSubIndex:=0;
       for SubIndex:=0 to fCountArrayTextures-1 do begin
        if Sprite.fArrayTexture=fArrayTextures[SubIndex] then begin
         SubSubIndex:=SubIndex;
         break;
        end;
       end;
       WriteInt32(SubSubIndex);
       WriteUInt8((TpvUInt8(ord(TpvSpriteFlag.SignedDistanceField in Sprite.fFlags) and 1) shl 0) or
                  (TpvUInt8(ord(TpvSpriteFlag.Rotated in Sprite.fFlags) and 1) shl 1) or
                  (TpvUInt8(ord(length(Sprite.fTrimmedHullVectors)>0) and 1) shl 2));
       WriteInt32(Sprite.fX);
       WriteInt32(Sprite.fY);
       WriteInt32(Sprite.fLayer);
       WriteInt32(Sprite.fWidth);
       WriteInt32(Sprite.fHeight);
       WriteInt32(Sprite.fTrimmedX);
       WriteInt32(Sprite.fTrimmedY);
       WriteInt32(Sprite.fTrimmedWidth);
       WriteInt32(Sprite.fTrimmedHeight);
       WriteFloat(Sprite.fOffsetX);
       WriteFloat(Sprite.fOffsetY);
       WriteFloat(Sprite.fScaleX);
       WriteFloat(Sprite.fScaleY);
       if TpvSpriteFlag.SignedDistanceField in Sprite.fFlags then begin
        WriteUInt8(TpvUInt8(Sprite.fSignedDistanceFieldVariant));
       end;
       if length(Sprite.fTrimmedHullVectors)>0 then begin
        WriteInt32(length(Sprite.fTrimmedHullVectors));
        for SubIndex:=0 to length(Sprite.fTrimmedHullVectors)-1 do begin
         WriteFloat(Sprite.fTrimmedHullVectors[SubIndex].x);
         WriteFloat(Sprite.fTrimmedHullVectors[SubIndex].y);
        end;
       end;
      end;
     end;

    finally
     BufferedStream.Free;
    end;

   finally
    if aFast then begin
     Entry.CompressionLevel:=2;
    end else begin
     Entry.CompressionLevel:=4;
    end;
   end;

  finally
  end;

  for Index:=0 to fCountArrayTextures-1 do begin
   ArrayTexture:=fArrayTextures[Index];
   if assigned(ArrayTexture) then begin
    for SubIndex:=0 to ArrayTexture.fLayers-1 do begin
     if fDepth16Bit then begin
      Entry:=Archive.Entries.Add(TpvRawByteString(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.png'));
     end else begin
      Entry:=Archive.Entries.Add(TpvRawByteString(IntToStr(Index)+'_'+IntToStr(SubIndex)+'.png'));
     end;
     try
      Entry.Stream:=TMemoryStream.Create;
      if fDepth16Bit then begin
       SavePNGImageAsStream(ArrayTexture.GetTexelPointer(0,0,SubIndex),
                            ArrayTexture.fWidth,
                            ArrayTexture.fHeight,
                            Entry.Stream,
                            TpvPNGPixelFormat.R16G16B16A16,
                            aFast);
      end else begin
       SavePNGImageAsStream(ArrayTexture.GetTexelPointer(0,0,SubIndex),
                            ArrayTexture.fWidth,
                            ArrayTexture.fHeight,
                            Entry.Stream,
                            TpvPNGPixelFormat.R8G8B8A8,
                            aFast);
{      SaveQOIImageAsStream(ArrayTexture.GetTexelPointer(0,0,SubIndex),
                            ArrayTexture.fWidth,
                            ArrayTexture.fHeight,
                            Entry.Stream,
                            true);}
      end;
     finally
      Entry.CompressionLevel:=0;
     end;
    end;
   end;
  end;

  Archive.SaveToStream(aStream);

 finally
  Archive.Free;
 end;

end;

procedure TpvSpriteAtlas.SaveToFile(const aFileName:string;const aFast:boolean=false);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream,aFast);
 finally
  Stream.Free;
 end;
end;

end.
