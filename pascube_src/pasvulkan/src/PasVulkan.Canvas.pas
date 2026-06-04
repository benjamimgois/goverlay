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
unit PasVulkan.Canvas;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(fpc) and (defined(cpux86_64) or defined(cpuamd64))}
 {$optimization off,level1}
{$ifend}

interface

uses SysUtils,
     Classes,
     Math,
     PUCU,
     PasMP,
     Vulkan,
     Generics.Collections,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Utils,
     PasVulkan.Collections,
     PasVulkan.CircularDoublyLinkedList,
     PasVulkan.Framework,
     PasVulkan.Sprites,
     PasVulkan.SignedDistanceField2D,
     PasVulkan.Font;

const pvcvsRenderingModeShift=0;
      pvcvsObjectModeShift=2;
      pvcvsFillStyleShift=10;
      pvcvsFillWrapModeShift=12;
      pvcvsSignedDistanceFieldVariantShift=14;

type PpvCanvasRenderingMode=^TpvCanvasRenderingMode;
     TpvCanvasRenderingMode=
      (
       Normal=0,
       SignedDistanceField=1
      );

     PpvCanvasBlendingMode=^TpvCanvasBlendingMode;
     TpvCanvasBlendingMode=
      (
       None=0,
       NoDiscard=1,
       AlphaBlending=2,
       AdditiveBlending=3,
       OnlyDepth=4
      );

     PpvCanvasLineJoin=^TpvCanvasLineJoin;
     TpvCanvasLineJoin=
      (
       Bevel=0,
       Miter=1,
       Round=2
      );

     PpvCanvasLineCap=^TpvCanvasLineCap;
     TpvCanvasLineCap=
      (
       Butt=0,
       Square=1,
       Round=2
      );

     PpvCanvasFillRule=^TpvCanvasFillRule;
     TpvCanvasFillRule=
      (
       DoNotMatter=0, // for pure raw speed, where is no guarantee winding fill rule correctness of triangulation
       NonZero=1,
       EvenOdd=2
      );

     PpvCanvasFillStyle=^TpvCanvasFillStyle;
     TpvCanvasFillStyle=
      (
       Color=0,
       Image=1,
       LinearGradient=2,
       RadialGradient=3
      );

     PpvCanvasFillWrapMode=^TpvCanvasFillWrapMode;
     TpvCanvasFillWrapMode=
      (
       None=0,
       WrappedRepeat=1,
       MirroredRepeat=2
      );

     PpvCanvasTextHorizontalAlignment=^TpvCanvasTextHorizontalAlignment;
     TpvCanvasTextHorizontalAlignment=
      (
       Leading=0,
       Center=1,
       Tailing=2
      );

     ppvCanvasTextVerticalAlignment=^TpvCanvasTextVerticalAlignment;
     TpvCanvasTextVerticalAlignment=
      (
       Leading=0,
       Middle=1,
       Tailing=2
      );

     PpvCanvasPathCommandType=^TpvCanvasPathCommandType;
     TpvCanvasPathCommandType=
      (
       MoveTo=0,
       LineTo=1,
       QuadraticCurveTo=2,
       CubicCurveTo=3,
       ArcTo=4,
       Close=5
      );

     PpvCanvasPathCommandPoints=^TpvCanvasPathCommandPoints;
     TpvCanvasPathCommandPoints=array[0..2] of TpvVector2;

     PpvCanvasPathCommand=^TpvCanvasPathCommand;
     TpvCanvasPathCommand=record
      CommandType:TpvCanvasPathCommandType;
      Points:TpvCanvasPathCommandPoints;
     end;

     TpvCanvasPathCommands=array of TpvCanvasPathCommand;

     TpvCanvas=class;

     TpvCanvasStrokePatternDashes=array of TpvDouble;

     PpvCanvasStrokePattern=^TpvCanvasStrokePattern;
     TpvCanvasStrokePattern=record
      private
       fDashes:TpvCanvasStrokePatternDashes;
       fDashSize:TpvDouble;
       fStart:TpvDouble;
      public
       constructor Create(const aPattern:string;const aDashSize,aStart:TpvDouble); overload;
       constructor Create(const aPattern:string;const aDashSize:TpvDouble); overload;
       constructor Create(const aPattern:string); overload;
       constructor Create(const aDashes:array of TpvDouble;const aDashSize,aStart:TpvDouble); overload;
       constructor Create(const aDashes:array of TpvDouble;const aDashSize:TpvDouble); overload;
       constructor Create(const aDashes:array of TpvDouble); overload;
       class operator Implicit(const aPattern:string):TpvCanvasStrokePattern; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const aPattern:string):TpvCanvasStrokePattern; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Implicit(const aDashes:TpvCanvasStrokePatternDashes):TpvCanvasStrokePattern; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const aDashes:TpvCanvasStrokePatternDashes):TpvCanvasStrokePattern; {$ifdef CAN_INLINE}inline;{$endif}
       class function Empty:TpvCanvasStrokePattern; static; {$ifdef CAN_INLINE}inline;{$endif}
       property Steps:TpvCanvasStrokePatternDashes read fDashes write fDashes;
       property DashSize:TpvDouble read fDashSize write fDashSize;
       property Start:TpvDouble read fStart write fStart;
     end;

     TpvCanvasPath=class(TPersistent)
      private
       fCommands:TpvCanvasPathCommands;
       fCountCommands:TpvInt32;
       fStartPointSeen:Boolean;
       function NewCommand:PpvCanvasPathCommand;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Assign(aSource:TPersistent); override;
       function BeginPath:TpvCanvasPath;
       function EndPath:TpvCanvasPath;
       function ClosePath:TpvCanvasPath;
       function MoveTo(const aP0:TpvVector2):TpvCanvasPath;
       function LineTo(const aP0:TpvVector2):TpvCanvasPath;
       function QuadraticCurveTo(const aC0,aA0:TpvVector2):TpvCanvasPath;
       function CubicCurveTo(const aC0,aC1,aA0:TpvVector2):TpvCanvasPath;
       function ArcTo(const aP0,aP1:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath;
       function ArcToBezier(const aOrigin,aRadius:TpvVector2;const aStartAngle,aEndAngle:TpvFloat;const aCounterClockwise:boolean;const aRotation:TpvFloat):TpvCanvasPath;
       function Arc(const aCenter:TpvVector2;const aRadius,aStartAngle,aEndAngle:TpvFloat;const aCounterClockwise:boolean=false):TpvCanvasPath;
       function Ellipse(const aCenter,aRadius:TpvVector2):TpvCanvasPath;
       function Circle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath;
       function Rectangle(const aCenter,aBounds:TpvVector2):TpvCanvasPath;
       function RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvasPath; overload;
       function RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath; overload;
     end;

     { TpvCanvasState }

     TpvCanvasState=class(TPersistent)
      private
       fBlendingMode:TpvCanvasBlendingMode;
       fZPosition:TpvFloat;
       fLineWidth:TpvFloat;
       fMiterLimit:TpvFloat;
       fLineJoin:TpvCanvasLineJoin;
       fLineCap:TpvCanvasLineCap;
       fFillRule:TpvCanvasFillRule;
       fFillStyle:TpvCanvasFillStyle;
       fFillWrapMode:TpvCanvasFillWrapMode;
       fColor:TpvVector4;
       fClipRect:TpvRect;
       fClipSpaceClipRect:TpvRect;
       fScissor:TVkRect2D;
       fProjectionMatrix:TpvMatrix4x4;
       fViewMatrix:TpvMatrix4x4;
       fModelMatrix:TpvMatrix4x4;
       fFillMatrix:TpvMatrix4x4;
       fMaskMatrix:TpvMatrix4x4;
       fFont:TpvFont;
       fFontSize:TpvFloat;
       fTextHorizontalAlignment:TpvCanvasTextHorizontalAlignment;
       fTextVerticalAlignment:TpvCanvasTextVerticalAlignment;
       fPath:TpvCanvasPath;
       fTexture:TObject;
       fAtlasTexture:TObject;
       fMaskTexture:TObject;
       fGUIElementMode:boolean;
       fStrokePattern:TpvCanvasStrokePattern;
       procedure UpdateClipSpaceClipRect(const aCanvas:TpvCanvas);
       function GetColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetStartColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetStartColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetStopColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetStopColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFillMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFillMatrix(const aMatrix:TpvMatrix4x4); {$ifdef CAN_INLINE}inline;{$endif}
       procedure Reset;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Assign(aSource:TPersistent); override;
      public
       property Color:TpvVector4 read GetColor write SetColor;
       property StartColor:TpvVector4 read GetStartColor write SetStartColor;
       property StopColor:TpvVector4 read GetStopColor write SetStopColor;
       property ClipRect:TpvRect read fClipRect write fClipRect;
       property Scissor:TVkRect2D read fScissor write fScissor;
       property ProjectionMatrix:TpvMatrix4x4 read fProjectionMatrix write fProjectionMatrix;
       property ViewMatrix:TpvMatrix4x4 read fViewMatrix write fViewMatrix;
       property ModelMatrix:TpvMatrix4x4 read fModelMatrix write fModelMatrix;
       property FillMatrix:TpvMatrix4x4 read GetFillMatrix write SetFillMatrix;
       property MaskMatrix:TpvMatrix4x4 read fMaskMatrix write fMaskMatrix;
       property StrokePattern:TpvCanvasStrokePattern read fStrokePattern write fStrokePattern;
      published
       property BlendingMode:TpvCanvasBlendingMode read fBlendingMode write fBlendingMode;
       property ZPosition:TpvFloat read fZPosition write fZPosition;
       property LineWidth:TpvFloat read fLineWidth write fLineWidth;
       property MiterLimit:TpvFloat read fMiterLimit write fMiterLimit;
       property LineJoin:TpvCanvasLineJoin read fLineJoin write fLineJoin;
       property LineCap:TpvCanvasLineCap read fLineCap write fLineCap;
       property FillRule:TpvCanvasFillRule read fFillRule write fFillRule;
       property FillStyle:TpvCanvasFillStyle read fFillStyle write fFillStyle;
       property FillWrapMode:TpvCanvasFillWrapMode read fFillWrapMode write fFillWrapMode;
       property Font:TpvFont read fFont write fFont;
       property FontSize:TpvFloat read fFontSize write fFontSize;
       property TextHorizontalAlignment:TpvCanvasTextHorizontalAlignment read fTextHorizontalAlignment write fTextHorizontalAlignment;
       property TextVerticalAlignment:TpvCanvasTextVerticalAlignment read fTextVerticalAlignment write fTextVerticalAlignment;
       property Path:TpvCanvasPath read fPath write fPath;
       property Texture:TObject read fTexture write fTexture;
       property MaskTexture:TObject read fMaskTexture write fMaskTexture;
     end;

     TpvCanvasStateStack=class(TObjectStack<TpvCanvasState>);

     PpvCanvasShapeCacheVertex=^TpvCanvasShapeCacheVertex;
     TpvCanvasShapeCacheVertex=record
      ObjectMode:TVkUInt32;
      Position:TpvVector2;
      MetaInfo:TpvVector4;
      MetaInfo2:TpvVector4;
      Offset:TpvVector2;
     end;

     PpvCanvasShapeCacheLinePoint=^TpvCanvasShapeCacheLinePoint;
     TpvCanvasShapeCacheLinePoint=record
      Position:TpvVector2;
      case boolean of
       false:(
        Middle:TpvVector2;
       );
       true:(
        Last:TpvInt32;
       );
     end;

     TpvCanvasShapeCacheLinePoints=array of TpvCanvasShapeCacheLinePoint;

     PpvCanvasShapeCacheSegmentScalar=^TpvCanvasShapeCacheSegmentScalar;
     TpvCanvasShapeCacheSegmentScalar=TpvDouble;

     PpvCanvasShapeCacheSegmentPoint=^TpvCanvasShapeCacheSegmentPoint;
     TpvCanvasShapeCacheSegmentPoint=record
      x:TpvCanvasShapeCacheSegmentScalar;
      y:TpvCanvasShapeCacheSegmentScalar;
     end;

     PpvCanvasShapeCacheSegmentTwoPoints=^TpvCanvasShapeCacheSegmentTwoPoints;
     TpvCanvasShapeCacheSegmentTwoPoints=array[0..1] of TpvInt32;

     PpvCanvasShapeCacheSegment=^TpvCanvasShapeCacheSegment;
     TpvCanvasShapeCacheSegment=record
      Previous:TpvInt32;
      Next:TpvInt32;
      Points:TpvCanvasShapeCacheSegmentTwoPoints;
      AABBMin:TpvCanvasShapeCacheSegmentPoint;
      AABBMax:TpvCanvasShapeCacheSegmentPoint;
     end;

     TpvCanvasShapeCacheSegments=array of TpvCanvasShapeCacheSegment;

     PpvCanvasShapeCacheSegmentUniquePoint=^TpvCanvasShapeCacheSegmentUniquePoint;
     TpvCanvasShapeCacheSegmentUniquePoint=record
      HashNext:TpvInt32;
      Hash:TpvUInt32;
      Point:TpvCanvasShapeCacheSegmentPoint;
     end;

     TpvCanvasShapeCacheSegmentUniquePoints=array of TpvCanvasShapeCacheSegmentUniquePoint;

     TpvCanvasShapeCacheSegmentUniquePointIndices=array of TpvInt32;

     PpvCanvasShapeCacheVertices=^TpvCanvasShapeCacheVertices;
     TpvCanvasShapeCacheVertices=array of TpvCanvasShapeCacheVertex;

     TpvCanvasShapeCacheIndices=array of TpvInt32;

     PpvCanvasShapeCachePart=^TpvCanvasShapeCachePart;
     TpvCanvasShapeCachePart=record
      BaseVertexIndex:TpvInt32;
      BaseIndexIndex:TpvInt32;
      CountVertices:TpvInt32;
      CountIndices:TpvInt32;
     end;

     TpvCanvasShapeCacheParts=array of TpvCanvasShapeCachePart;

     TpvCanvasShapeCacheYCoordinates=array of TpvCanvasShapeCacheSegmentScalar;

     EpvCanvasShape=class(Exception);

     TpvCanvasShape=class
      private
       const pvCanvasShapeCacheSegmentUniquePointHashSize=1 shl 12;
             pvCanvasShapeCacheSegmentUniquePointHashMask=pvCanvasShapeCacheSegmentUniquePointHashSize-1;
       type TpvCanvasShapeCacheSegmentUniquePointHashTable=array of TpvInt32;
      private
       fCacheTemporaryLinePoints:TpvCanvasShapeCacheLinePoints;
       fCacheLinePoints:TpvCanvasShapeCacheLinePoints;
       fCacheSegments:TpvCanvasShapeCacheSegments;
       fCacheSegmentUniquePoints:TpvCanvasShapeCacheSegmentUniquePoints;
       fCacheSegmentUniquePointHashTable:TpvCanvasShapeCacheSegmentUniquePointHashTable;
       fCacheVertices:TpvCanvasShapeCacheVertices;
       fCacheIndices:TpvCanvasShapeCacheIndices;
       fCacheParts:TpvCanvasShapeCacheParts;
       fCacheYCoordinates:TpvCanvasShapeCacheYCoordinates;
       fCacheTemporaryYCoordinates:TpvCanvasShapeCacheYCoordinates;
       fCountCacheTemporaryLinePoints:TpvInt32;
       fCountCacheLinePoints:TpvInt32;
       fCountCacheSegments:TpvInt32;
       fCountCacheSegmentUniquePoints:TpvInt32;
       fCountCacheVertices:TpvInt32;
       fCountCacheIndices:TpvInt32;
       fCountCacheParts:TpvInt32;
       fCountCacheYCoordinates:TpvInt32;
       fCacheFirstSegment:TpvInt32;
       fCacheLastSegment:TpvInt32;
       fForcedCurveTessellationTolerance:TpvDouble;
       fCurveTessellationTolerance:TpvDouble;
       fCurveTessellationToleranceSquared:TpvDouble;
       procedure InitializeCurveTessellationTolerance(const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
       procedure BeginPart(const aCountVertices:TpvInt32=0;const aCountIndices:TpvInt32=0);
       procedure EndPart;
       function AddVertex(const Position:TpvVector2;const ObjectMode:TpvUInt8;const MetaInfo,MetaInfo2:TpvVector4;const Offset:TpvVector2):TpvInt32;
       function AddIndex(const VertexIndex:TpvInt32):TpvInt32;
       function GetWindingNumberAtPointInPolygon(const Point:TpvVector2):TpvInt32;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Reset;
       procedure StrokeFromPath(const aPath:TpvCanvasPath;const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
       procedure FillFromPath(const aPath:TpvCanvasPath;const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
       property ForcedCurveTessellationTolerance:TpvDouble read fForcedCurveTessellationTolerance write fForcedCurveTessellationTolerance;
     end;

     PpvCanvasVertex=^TpvCanvasVertex;
     TpvCanvasVertex=packed record               //   Size                                    Offset
      OriginalPosition:TpvVector2;               //    8 bytes (2x 32-bit floats)           =
      Position:TpvVector3;                       // + 12 bytes (3x 32-bit floats)           =
      Color:TpvHalfFloatVector4;                 // +  8 bytes (4x 16-bit half-floats)      =
      TextureCoord:TpvVector3;                   // + 12 bytes (3x 32-bit floats)           =
      State:TpvUInt32;                           // +  4 bytes (1x 32-bit unsigned integer) =
      ClipRect:TpvRect;                          // + 16 bytes (4x 32-bit floats)           =
      MetaInfo:TpvVector4;                       // + 16 bytes (4x 32-bit floats)           =
      MetaInfo2:TpvVector4;                      // + 16 bytes (4x 32-bit floats)           =
     end;                                        // = 92 bytes per vertex

     TpvCanvasVertices=array of TpvCanvasVertex;

     TpvCanvasVulkanBuffers=array of TpvVulkanBuffer;

     PpvCanvasVertexBuffer=^TpvCanvasVertexBuffer;
     TpvCanvasVertexBuffer=array[0..(32768*4)-1] of TpvCanvasVertex;

     TpvCanvasVertexBuffers=array of TpvCanvasVertexBuffer;

     TpvCanvasVertexBufferSizes=array of TVkSizeInt;

     PpvCanvasIndexBuffer=^TpvCanvasIndexBuffer;
     TpvCanvasIndexBuffer=array[0..((SizeOf(TpvCanvasVertexBuffer) div (SizeOf(TpvCanvasVertex)*4))*6)-1] of TpvUInt32;

     TpvCanvasIndexBuffers=array of TpvCanvasIndexBuffer;

     TpvCanvasIndexBufferSizes=array of TVkSizeInt;

     TpvCanvasHook=procedure(const aData:TpvPointer;const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32) of object;

     TpvCanvasQueueItemKind=
      (
       None,
       Normal,
       Hook
      );

     PpvCanvasPushConstants=^TpvCanvasPushConstants;
     TpvCanvasPushConstants=record
      Data:array[0..7] of TpvVector4;
     end;

     TpvCanvasVulkanDescriptor=class;

     TpvCanvasVulkanDescriptorLinkedListNode=TpvCircularDoublyLinkedListNode<TpvCanvasVulkanDescriptor>;

     TpvCanvasVulkanDescriptor=class(TpvCanvasVulkanDescriptorLinkedListNode)
      private
       fCanvas:TpvCanvas;
       fDescriptorPool:TpvVulkanDescriptorPool;
       fDescriptorSet:TpvVulkanDescriptorSet;
       fDescriptorTexture:TObject;
       fDescriptorMaskTexture:TObject;
       fLastUsedFrameNumber:TpvNativeUInt;
      public
       constructor Create(const aCanvas:TpvCanvas); reintroduce;
       destructor Destroy; override;
      published
       property Canvas:TpvCanvas read fCanvas;
       property DescriptorPool:TpvVulkanDescriptorPool read fDescriptorPool write fDescriptorPool;
       property DescriptorSet:TpvVulkanDescriptorSet read fDescriptorSet write fDescriptorSet;
       property DescriptorTexture:TObject read fDescriptorTexture write fDescriptorTexture;
       property DescriptorMaskTexture:TObject read fDescriptorMaskTexture write fDescriptorMaskTexture;
       property LastUsedFrameNumber:TpvNativeUInt read fLastUsedFrameNumber write fLastUsedFrameNumber;
     end;

     TpvCanvasTextureDescriptorSetHashMapKey=record
      Texture:TObject;
      MaskTexture:TObject;
     end;
     PpvCanvasTextureDescriptorSetHashMapKey=^TpvCanvasTextureDescriptorSetHashMapKey;

     TpvCanvasTextureDescriptorSetHashMap=class(TpvHashMap<TpvCanvasTextureDescriptorSetHashMapKey,TpvCanvasVulkanDescriptor>);

     PpvCanvasQueueItem=^TpvCanvasQueueItem;
     TpvCanvasQueueItem=record
      Kind:TpvCanvasQueueItemKind;
      BufferIndex:TpvInt32;
      Descriptor:TpvCanvasVulkanDescriptor;
      MaskingMode:Boolean;
      BlendingMode:TpvCanvasBlendingMode;
      TextureMode:TpvInt32;
      StartVertexIndex:TpvInt32;
      StartIndexIndex:TpvInt32;
      CountVertices:TpvInt32;
      CountIndices:TpvInt32;
      Scissor:TVkRect2D;
      PushConstants:TpvCanvasPushConstants;
      TransformMatrix:TpvMatrix4x4;
      FillMatrix:TpvMatrix4x4;
      MaskMatrix:TpvMatrix4x4;
      Hook:TpvCanvasHook;
      HookData:TVkPointer;
     end;

     TpvCanvasQueueItems=array of TpvCanvasQueueItem;

     PpvCanvasTextGlyphRect=^TpvCanvasTextGlyphRect;
     TpvCanvasTextGlyphRect=TpvRect;

     TpvCanvasTextGlyphRects=TpvRectArray;

     PpvCanvasBuffer=^TpvCanvasBuffer;
     TpvCanvasBuffer=record
      fSpinLock:TpvInt32;
      fVulkanVertexBuffers:TpvCanvasVulkanBuffers;
      fVulkanIndexBuffers:TpvCanvasVulkanBuffers;
      fVertexBuffers:TpvCanvasVertexBuffers;
      fVertexBufferSizes:TpvCanvasVertexBufferSizes;
      fIndexBuffers:TpvCanvasIndexBuffers;
      fIndexBufferSizes:TpvCanvasIndexBufferSizes;
      fCountAllocatedBuffers:TpvInt32;
      fCountUsedBuffers:TpvInt32;
      fQueueItems:TpvCanvasQueueItems;
      fCountQueueItems:TpvInt32;
     end;

     TpvCanvasBuffers=array of TpvCanvasBuffer;

     TpvCanvasCommon=class
      private
       class var fLock:TPasMPInt32;
      private
       fDevice:TpvVulkanDevice;
       fReferenceCounter:TpvInt32;
       fDummyTexture:TpvVulkanTexture;
       fCanvasVertexShaderModule:TpvVulkanShaderModule;
       fCanvasVertexNoTextureShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentGUINoTextureShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentNoTextureShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentTextureShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentAtlasTextureShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentVectorPathShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentGUINoTextureNoBlendingShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentNoTextureNoBlendingShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentTextureNoBlendingShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentAtlasTextureNoBlendingShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentVectorPathNoBlendingShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentGUINoTextureNoBlendingNoDiscardShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentNoTextureNoBlendingNoDiscardShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentTextureNoBlendingNoDiscardShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentAtlasTextureNoBlendingNoDiscardShaderModule:TpvVulkanShaderModule;
       fCanvasFragmentVectorPathNoBlendingNoDiscardShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineCanvasShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageVertexNoTexture:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentGUINoTexture:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentNoTexture:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentTexture:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentAtlasTexture:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentVectorPath:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlending:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlending:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentTextureNoBlending:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlending:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlending:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlendingNoDiscard:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlendingNoDiscard:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentTextureNoBlendingNoDiscard:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlendingNoDiscard:TpvVulkanPipelineShaderStage;
       fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlendingNoDiscard:TpvVulkanPipelineShaderStage;
      public
       constructor Create(const aDevice:TpvVulkanDevice); reintroduce;
       destructor Destroy; override;
       class function Acquire(const aDevice:TpvVulkanDevice):TpvCanvasCommon;
       class procedure Release(const aDevice:TpvVulkanDevice);
     end;

     TpvCanvasVulkanPipelineLayouts=array[TpvCanvasBlendingMode,0..3] of TpvVulkanPipelineLayout;

     TpvCanvasVulkanGraphicsPipelines=array[TpvCanvasBlendingMode,0..3] of TpvVulkanGraphicsPipeline;

     { TpvCanvasFont }
     TpvCanvasFont=class
      private
       fVulkanFontSpriteAtlas:TpvSpriteAtlas;
       fVulkanFont:TpvFont;
      public
       constructor Create; reintroduce;
       constructor CreateFromTTF(const aFileName:String;const aDPI,aAtlasSize:TpvInt32;const aFirstCodePoint,aLastCodePoint:TpvUInt32);
       destructor Destroy; override;
      published
       property VulkanFontSpriteAtlas:TpvSpriteAtlas read fVulkanFontSpriteAtlas write fVulkanFontSpriteAtlas;
       property VulkanFont:TpvFont read fVulkanFont write fVulkanFont;
     end;

     TpvCanvas=class
      private
       fDevice:TpvVulkanDevice;
       fCanvasCommon:TpvCanvasCommon;
       fPipelineCache:TpvVulkanPipelineCache;
       fVulkanDescriptors:TpvCanvasVulkanDescriptorLinkedListNode;
       fVulkanDescriptorSetTextureLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSetVectorPathLayout:TpvVulkanDescriptorSetLayout;
       fCountVulkanDescriptors:TpvInt32;
       fVulkanTextureDescriptorSetHashMap:TpvCanvasTextureDescriptorSetHashMap;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanPipelineLayouts:TpvCanvasVulkanPipelineLayouts;
       fVulkanGraphicsPipelines:TpvCanvasVulkanGraphicsPipelines;
       fVulkanCanvasBuffers:TpvCanvasBuffers;
       fCountBuffers:TpvInt32;
       fCurrentFillBuffer:PpvCanvasBuffer;
       fCountProcessingBuffers:TpvInt32;
       fCurrentFrameNumber:TpvNativeUInt;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fViewPort:TVkViewport;
       fPointerToViewport:PVkViewport;
       fCurrentVulkanBufferIndex:TpvInt32;
       fCurrentVulkanVertexBufferOffset:TpvInt32;
       fCurrentVulkanIndexBufferOffset:TpvInt32;
       fCurrentCountVertices:TVkSizeInt;
       fCurrentCountIndices:TVkSizeInt;
       fCurrentDestinationVertexBufferPointer:PpvCanvasVertexBuffer;
       fCurrentDestinationIndexBufferPointer:PpvCanvasIndexBuffer;
       fInternalRenderingMode:TpvCanvasRenderingMode;
       fSignedDistanceFieldVariant:TpvSignedDistanceField2DVariant;
       fShape:TpvCanvasShape;
       fState:TpvCanvasState;
       fStateStack:TpvCanvasStateStack;
       procedure SetVulkanRenderPass(const aVulkanRenderPass:TpvVulkanRenderPass);
       procedure SetCountBuffers(const aCountBuffers:TpvInt32);
       function GetTexture:TObject; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetTexture(const aTexture:TObject);
       function GetAtlasTexture:TObject; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetAtlasTexture(const aTexture:TObject);
       function GetMaskTexture:TObject; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetMaskTexture(const aTexture:TObject);
       function GetGUIElementMode:boolean; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetGUIElementMode(const aGUIElementMode:boolean);
       function GetBlendingMode:TpvCanvasBlendingMode; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetBlendingMode(const aBlendingMode:TpvCanvasBlendingMode);
       function GetZPosition:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetZPosition(const aZPosition:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetLineWidth:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetLineWidth(const aLineWidth:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetMiterLimit:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetMiterLimit(const aMiterLimit:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetLineJoin:TpvCanvasLineJoin; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetLineJoin(const aLineJoin:TpvCanvasLineJoin); {$ifdef CAN_INLINE}inline;{$endif}
       function GetLineCap:TpvCanvasLineCap; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetLineCap(const aLineCap:TpvCanvasLineCap); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFillRule:TpvCanvasFillRule; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFillRule(const aFillRule:TpvCanvasFillRule); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFillStyle:TpvCanvasFillStyle; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFillStyle(const aFillStyle:TpvCanvasFillStyle); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFillWrapMode:TpvCanvasFillWrapMode; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFillWrapMode(const aFillWrapMode:TpvCanvasFillWrapMode); {$ifdef CAN_INLINE}inline;{$endif}
       function GetColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetStartColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetStartColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetStopColor:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetStopColor(const aColor:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetProjectionMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetProjectionMatrix(const aProjectionMatrix:TpvMatrix4x4);
       function GetViewMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetViewMatrix(const aViewMatrix:TpvMatrix4x4);
       function GetModelMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetModelMatrix(const aModelMatrix:TpvMatrix4x4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFillMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFillMatrix(const aMatrix:TpvMatrix4x4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetMaskMatrix:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetMaskMatrix(const aMatrix:TpvMatrix4x4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetStrokePattern:TpvCanvasStrokePattern; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetStrokePattern(const aStrokePattern:TpvCanvasStrokePattern); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFont:TpvFont; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFont(const aFont:TpvFont); {$ifdef CAN_INLINE}inline;{$endif}
       function GetFontSize:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetFontSize(const aFontSize:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetTextHorizontalAlignment:TpvCanvasTextHorizontalAlignment; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetTextHorizontalAlignment(aTextHorizontalAlignment:TpvCanvasTextHorizontalAlignment); {$ifdef CAN_INLINE}inline;{$endif}
       function GetTextVerticalAlignment:TpvCanvasTextVerticalAlignment; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetTextVerticalAlignment(aTextVerticalAlignment:TpvCanvasTextVerticalAlignment); {$ifdef CAN_INLINE}inline;{$endif}
       procedure GetNextDestinationVertexBuffer;
       function ClipCheck(const aX0,aY0,aX1,aY1:TpvFloat):boolean;
       function GetVertexState:TpvUInt32; {$ifdef CAN_INLINE}inline;{$endif}
       procedure GarbageCollectDescriptors;
      public
       constructor Create(const aDevice:TpvVulkanDevice;
                          const aPipelineCache:TpvVulkanPipelineCache;
                          const aCountProcessingBuffers:TpvInt32=4); reintroduce;
       destructor Destroy; override;
       procedure Start(const aBufferIndex:TpvInt32);
       procedure Stop;
       procedure DeleteFromCachedDescriptors(const aKey:TpvCanvasTextureDescriptorSetHashMapKey);
       procedure Flush;
       procedure SetScissor(const aScissor:TVkRect2D); overload;
       procedure SetScissor(const aLeft,aTop,aWidth,aHeight:TpvInt32); overload;
       function GetClipRect:TpvRect;
       procedure SetClipRect(const aClipRect:TVkRect2D); overload;
       procedure SetClipRect(const aClipRect:TpvRect); overload;
       procedure SetClipRect(const aLeft,aTop,aWidth,aHeight:TpvInt32); overload;
      public
       procedure EnsureSufficientReserveUsableSpace(const aCountVertices,aCountIndices:TpvInt32);
       function AddVertex(const aPosition:TpvVector2;const aTexCoord:TpvVector3;const aColor:TpvVector4):TpvInt32;
       function AddIndex(const aVertexIndex:TpvInt32):TpvInt32; {$ifdef CAN_INLINE}inline;{$endif}
      public
       procedure ExecuteUpload(const aVulkanTransferQueue:TpvVulkanQueue;const aVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;const aVulkanTransferCommandBufferFence:TpvVulkanFence;const aBufferIndex:TpvInt32);
       procedure ExecuteDraw(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32);
      public
       function Push:TpvCanvas;
       function Pop:TpvCanvas;
      public
       function Hook(const aHook:TpvCanvasHook;const aData:TpvPointer):TpvCanvas; overload;
      public
       function DrawSprite(const aSprite:TpvSprite;const aSrc,aDest:TpvRect):TpvCanvas; overload;
       function DrawSprite(const aSprite:TpvSprite;const aSrc,aDest:TpvRect;const aOrigin:TpvVector2;const aRotationAngle:TpvFloat):TpvCanvas; overload;
       function DrawSprite(const aSprite:TpvSprite;const aPosition:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawSprite(const aSprite:TpvSprite):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
      public
       procedure DrawSpriteProc(const aSprite:TpvSprite;const aSrc,aDest:TpvRect); inline;
      public
       function DrawNinePatchSprite(const aSprite:TpvSprite;const aNinePatch:TpvSpriteNinePatch;const aPosition,aSize:TpvVector2):TpvCanvas; overload;
      public
       function TextWidth(const aText:TpvUTF8String):TpvFloat;
       function TextHeight(const aText:TpvUTF8String):TpvFloat;
       function TextSize(const aText:TpvUTF8String):TpvVector2;
       function TextRowHeight(const aPercent:TpvFloat):TpvFloat;
       procedure TextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32); overload;
       procedure TextGlyphRects(const aText:TpvUTF8String;const aX,aY:TpvFloat;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32); overload;
       procedure TextGlyphRects(const aText:TpvUTF8String;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32); overload;
       function TextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2):TpvCanvasTextGlyphRects; overload;
       function TextGlyphRects(const aText:TpvUTF8String;const aX,aY:TpvFloat):TpvCanvasTextGlyphRects; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function TextGlyphRects(const aText:TpvUTF8String):TpvCanvasTextGlyphRects; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawTextCodePoint(const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2):TpvCanvas; overload;
       function DrawTextCodePoint(const aTextCodePoint:TpvUInt32;const aX,aY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawTextCodePoint(const aTextCodePoint:TpvUInt32):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawText(const aText:TpvUTF8String;const aPosition:TpvVector2):TpvCanvas; overload;
       function DrawText(const aText:TpvUTF8String;const aX,aY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawText(const aText:TpvUTF8String):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
      public
       function DrawFilledEllipse(const aCenter,aRadius:TpvVector2):TpvCanvas; overload;
       function DrawFilledEllipse(const aCenterX,aCenterY,aRadiusX,aRadiusY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawFilledCircle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvas; overload;
       function DrawFilledCircle(const aCenterX,aCenterY,aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawFilledRectangle(const aCenter,aBounds:TpvVector2):TpvCanvas; overload;
       function DrawFilledRectangle(const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawFilledRectangle(const aRect:TpvRect):TpvCanvas; overload;
       function DrawFilledRoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvas; overload;
       function DrawFilledRoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawFilledRoundedRectangle(const aRect:TpvRect;const aRadius:TpvFloat):TpvCanvas; overload;
       function DrawFilledCircleArcRingSegment(const aCenter:TpvVector2;const aInnerRadius,aOuterRadius,aStartAngle,aEndAngle,aGapThickness:TpvFloat):TpvCanvas; overload;
       function DrawFilledCircleArcRingSegment(const aCenterX,aCenterY,aInnerRadius,aOuterRadius,aStartAngle,aEndAngle,aGapThickness:TpvFloat):TpvCanvas; overload;
      public
       function DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aCenter,aBounds:TpvVector2;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas; overload;
       function DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aRect:TpvRect;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas; overload;
      public
       function DrawGUIElement(const aGUIElement:TVkInt32;const aFocused:boolean;const aMin,aMax,aMetaMin,aMetaMax:TpvVector2;const aMeta:TpvFloat=0.0;const aTransparent:Boolean=false):TpvCanvas; overload;
       function DrawGUIElement(const aGUIElement:TVkInt32;const aFocused:boolean;const aMinX,aMinY,aMaxX,aMaxY,aMetaMinX,aMetaMinY,aMetaMaxX,aMetaMaxY:TpvFloat;const aMeta:TpvFloat=0.0;const aTransparent:Boolean=false):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
      public
       function DrawShape(const aShape:TpvCanvasShape):TpvCanvas;
      public
       function BeginPath:TpvCanvas; {$ifdef CAN_INLINE}inline;{$endif}
       function EndPath:TpvCanvas; {$ifdef CAN_INLINE}inline;{$endif}
       function ClosePath:TpvCanvas; {$ifdef CAN_INLINE}inline;{$endif}
      public
       function MoveTo(const aP0:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MoveTo(const aX,aY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function LineTo(const aP0:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function LineTo(const aX,aY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function QuadraticCurveTo(const aC0,aA0:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function QuadraticCurveTo(const aCX,aCY,aAX,aAY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function CubicCurveTo(const aC0,aC1,aA0:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function CubicCurveTo(const aC0X,aC0Y,aC1X,aC1Y,aAX,aAY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function ArcTo(const aP0,aP1:TpvVector2;const aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function ArcTo(const aP0X,aP0Y,aP1X,aP1Y,aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Arc(const aCenter:TpvVector2;const aRadius,aAngle0,aAngle1:TpvFloat;const aCounterClockwise:boolean):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Arc(const aCenterX,aCenterY,aRadius,aAngle0,aAngle1:TpvFloat;const aCounterClockwise:boolean):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Ellipse(const aCenter,aRadius:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Ellipse(const aCenterX,aCenterY,aRadiusX,aRadiusY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Circle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Circle(const aCenterX,aCenterY,aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Rectangle(const aCenter,aBounds:TpvVector2):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Rectangle(const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Rectangle(const aRect:TpvRect):TpvCanvas; overload;
       function RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function RoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function RoundedRectangle(const aRect:TpvRect;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas; overload;
       function RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function RoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadius:TpvFloat):TpvCanvas; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function RoundedRectangle(const aRect:TpvRect;const aRadius:TpvFloat):TpvCanvas; overload;
      public
       function Stroke:TpvCanvas;
       function Fill:TpvCanvas;
      public
       function GetStrokeShape:TpvCanvasShape;
       function GetFillShape:TpvCanvasShape;
      public
       property Viewport:PVkViewport read fPointerToViewport;
       property ClipRect:TpvRect read GetClipRect write SetClipRect;
       property Color:TpvVector4 read GetColor write SetColor;
       property StartColor:TpvVector4 read GetStartColor write SetStartColor;
       property StopColor:TpvVector4 read GetStopColor write SetStopColor;
       property ProjectionMatrix:TpvMatrix4x4 read GetProjectionMatrix write SetProjectionMatrix;
       property ViewMatrix:TpvMatrix4x4 read GetViewMatrix write SetViewMatrix;
       property ModelMatrix:TpvMatrix4x4 read GetModelMatrix write SetModelMatrix;
       property FillMatrix:TpvMatrix4x4 read GetFillMatrix write SetFillMatrix;
       property MaskMatrix:TpvMatrix4x4 read GetMaskMatrix write SetMaskMatrix;
       property StrokePattern:TpvCanvasStrokePattern read GetStrokePattern write SetStrokePattern;
       property Font:TpvFont read GetFont write SetFont;
       property FontSize:TpvFloat read GetFontSize write SetFontSize;
       property TextHorizontalAlignment:TpvCanvasTextHorizontalAlignment read GetTextHorizontalAlignment write SetTextHorizontalAlignment;
       property TextVerticalAlignment:TpvCanvasTextVerticalAlignment read GetTextVerticalAlignment write SetTextVerticalAlignment;
      published
       property Device:TpvVulkanDevice read fDevice;
       property VulkanRenderPass:TpvVulkanRenderPass read fVulkanRenderPass write SetVulkanRenderPass;
       property CountBuffers:TpvInt32 read fCountBuffers write SetCountBuffers;
       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;
       property BlendingMode:TpvCanvasBlendingMode read GetBlendingMode write SetBlendingMode;
       property ZPosition:TpvFloat read GetZPosition write SetZPosition;
       property LineWidth:TpvFloat read GetLineWidth write SetLineWidth;
       property MiterLimit:TpvFloat read GetMiterLimit write SetMiterLimit;
       property LineJoin:TpvCanvasLineJoin read GetLineJoin write SetLineJoin;
       property LineCap:TpvCanvasLineCap read GetLineCap write SetLineCap;
       property FillRule:TpvCanvasFillRule read GetFillRule write SetFillRule;
       property FillStyle:TpvCanvasFillStyle read GetFillStyle write SetFillStyle;
       property FillWrapMode:TpvCanvasFillWrapMode read GetFillWrapMode write SetFillWrapMode;
       property Texture:TObject read GetTexture write SetTexture;
       property MaskTexture:TObject read GetMaskTexture write SetMaskTexture;
       property State:TpvCanvasState read fState;
     end;

implementation

uses PasVulkan.Application,
     PasVulkan.Assets,
     PasVulkan.Streams,
     PasVulkan.TrueTypeFont,
     PasDblStrUtils;

const pcvvaomSolid=0;
      pcvvaomLineEdge=1;
      pcvvaomRoundLineCapCircle=2;
      pcvvaomRoundLine=3;
      pcvvaomCircle=4;
      pcvvaomEllipse=5;
      pcvvaomRectangle=6;
      pcvvaomRoundedRectangle=7;
      pcvvaomCircleArcRingSegment=8;

      CurveRecursionLimit=16;

{$if defined(fpc) and (defined(cpu386) or defined(cpux64) or defined(cpuamd64))}
// For to avoid "Fatal: Internal error 200604201" at the FreePascal compiler, when >= -O2 is used
function Sign(const aValue:TpvDouble):TpvInt32;
begin
 if aValue<0.0 then begin
  result:=-1;
 end else if aValue>0.0 then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;
{$ifend}

constructor TpvCanvasStrokePattern.Create(const aPattern:string;const aDashSize,aStart:TpvDouble);
var CountSteps,Position,Len,StartPosition,Count,Index:TpvInt32;
    Value:TpvDouble;
    OK:TPasDblStrUtilsBoolean;
    c:AnsiChar;
begin
 fDashSize:=aDashSize;
 fStart:=aStart;
 fDashes:=nil;
 CountSteps:=0;
 try
  Len:=length(aPattern);
  if Len>0 then begin
   Position:=1;
   if AnsiChar(aPattern[Position]) in ['0'..'9','x','X','o','O','a'..'f','A'..'F'] then begin
    while Position<=Len do begin
     if AnsiChar(aPattern[Position]) in ['0'..'9','x','X','o','O','-','+','a'..'f','A'..'F'] then begin
      StartPosition:=Position;
      repeat
       inc(Position);
      until (Position>Len) or not (AnsiChar(aPattern[Position]) in ['0'..'9','x','X','o','O','-','+','a'..'f','A'..'F']);
      OK:=false;
      Value:=ConvertStringToDouble(TPasDblStrUtilsRawByteString(Copy(aPattern,StartPosition,Position-StartPosition)),rmNearest,@OK,-1);
      if OK and not SameValue(Value,0) then begin
       if length(fDashes)<(CountSteps+1) then begin
        SetLength(fDashes,(CountSteps+1)*2);
       end;
       fDashes[CountSteps]:=Value;
       inc(CountSteps);
      end;
     end else begin
      break;
     end;
     if (Position<=Len) and (AnsiChar(aPattern[Position]) in [#0..#32,',']) then begin
      repeat
       inc(Position);
      until (Position>Len) or not (AnsiChar(aPattern[Position]) in [#0..#32,',']);
     end else begin
      break;
     end;
    end;
   end else begin
    while Position<=Len do begin
     c:=AnsiChar(AnsiChar(aPattern[Position]));
     Count:=0;
     repeat
      inc(Count);
      inc(Position);
     until (Position>Len) or (AnsiChar(aPattern[Position])<>c);
     if Count>0 then begin
      if length(fDashes)<(CountSteps+1) then begin
       SetLength(fDashes,(CountSteps+1)*2);
      end;
      if c in [#0..#32] then begin
       fDashes[CountSteps]:=-Count;
      end else begin
       fDashes[CountSteps]:=Count;
      end;
      inc(CountSteps);
     end;
    end;
   end;
   if CountSteps>0 then begin
    if (CountSteps and 1)=1 then begin
     SetLength(fDashes,CountSteps*2);
     for Index:=0 to CountSteps-1 do begin
      fDashes[CountSteps+Index]:=fDashes[Index]*(-Sign(fDashes[(CountSteps+Index)-1]));
     end;
     inc(CountSteps,CountSteps);
    end;
   end;
  end;
 finally
  SetLength(fDashes,CountSteps);
 end;
end;

constructor TpvCanvasStrokePattern.Create(const aPattern:string;const aDashSize:TpvDouble);
begin
 self:=TpvCanvasStrokePattern.Create(aPattern,aDashSize,0.0);
end;

constructor TpvCanvasStrokePattern.Create(const aPattern:string);
begin
 self:=TpvCanvasStrokePattern.Create(aPattern,1.0,0.0);
end;

constructor TpvCanvasStrokePattern.Create(const aDashes:array of TpvDouble;const aDashSize,aStart:TpvDouble);
begin
 SetLength(fDashes,length(aDashes));
 if length(aDashes)>0 then begin
  Move(aDashes[0],fDashes[0],length(aDashes)*SizeOf(TpvDouble));
 end;
 fDashSize:=aDashSize;
 fStart:=aStart;
end;

constructor TpvCanvasStrokePattern.Create(const aDashes:array of TpvDouble;const aDashSize:TpvDouble);
begin
 self:=TpvCanvasStrokePattern.Create(aDashes,aDashSize,0.0);
end;

constructor TpvCanvasStrokePattern.Create(const aDashes:array of TpvDouble);
begin
 self:=TpvCanvasStrokePattern.Create(aDashes,1.0,0.0);
end;

class operator TpvCanvasStrokePattern.Implicit(const aPattern:string):TpvCanvasStrokePattern;
begin
 result:=TpvCanvasStrokePattern.Create(aPattern,1.0,0.0);
end;

class operator TpvCanvasStrokePattern.Explicit(const aPattern:string):TpvCanvasStrokePattern;
begin
 result:=TpvCanvasStrokePattern.Create(aPattern,1.0,0.0);
end;

class operator TpvCanvasStrokePattern.Implicit(const aDashes:TpvCanvasStrokePatternDashes):TpvCanvasStrokePattern;
begin
 result:=TpvCanvasStrokePattern.Create(aDashes,1.0,0.0);
end;

class operator TpvCanvasStrokePattern.Explicit(const aDashes:TpvCanvasStrokePatternDashes):TpvCanvasStrokePattern;
begin
 result:=TpvCanvasStrokePattern.Create(aDashes,1.0,0.0);
end;

class function TpvCanvasStrokePattern.Empty:TpvCanvasStrokePattern;
begin
 result.fDashes:=nil;
 result.fDashSize:=1.0;
 result.fStart:=0.0;
end;

constructor TpvCanvasPath.Create;
begin
 inherited Create;
 fCommands:=nil;
 fCountCommands:=0;
 fStartPointSeen:=false;
end;

destructor TpvCanvasPath.Destroy;
begin
 fCommands:=nil;
 inherited Destroy;
end;

procedure TpvCanvasPath.Assign(aSource:TPersistent);
begin
 if assigned(aSource) and (aSource is TpvCanvasPath) then begin
  fCountCommands:=TpvCanvasPath(aSource).fCountCommands;
  fStartPointSeen:=TpvCanvasPath(aSource).fStartPointSeen;
  if length(fCommands)<fCountCommands then begin
   SetLength(fCommands,fCountCommands*2);
  end;
  if fCountCommands>0 then begin
   Move(TpvCanvasPath(aSource).fCommands[0],fCommands[0],fCountCommands*SizeOf(TpvCanvasPathCommand));
  end;
 end;
end;

function TpvCanvasPath.NewCommand:PpvCanvasPathCommand;
var Index:TpvInt32;
begin
 Index:=fCountCommands;
 inc(fCountCommands);
 if length(fCommands)<fCountCommands then begin
  SetLength(fCommands,fCountCommands*2);
 end;
 result:=@fCommands[Index];
end;

function TpvCanvasPath.BeginPath:TpvCanvasPath;
begin
 fCountCommands:=0;
 result:=self;
 fStartPointSeen:=false;
end;

function TpvCanvasPath.EndPath:TpvCanvasPath;
begin
 fCountCommands:=0;
 result:=self;
 fStartPointSeen:=false;
end;

function TpvCanvasPath.ClosePath:TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.Close;
 result:=self;
 fStartPointSeen:=false;
end;

function TpvCanvasPath.MoveTo(const aP0:TpvVector2):TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.MoveTo;
 Command^.Points[0]:=aP0;
 fStartPointSeen:=true;
 result:=self;
end;

function TpvCanvasPath.LineTo(const aP0:TpvVector2):TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.LineTo;
 Command^.Points[0]:=aP0;
 fStartPointSeen:=true;
 result:=self;
end;

function TpvCanvasPath.QuadraticCurveTo(const aC0,aA0:TpvVector2):TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.QuadraticCurveTo;
 Command^.Points[0]:=aC0;
 Command^.Points[1]:=aA0;
 fStartPointSeen:=true;
 result:=self;
end;

function TpvCanvasPath.CubicCurveTo(const aC0,aC1,aA0:TpvVector2):TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.CubicCurveTo;
 Command^.Points[0]:=aC0;
 Command^.Points[1]:=aC1;
 Command^.Points[2]:=aA0;
 fStartPointSeen:=true;
 result:=self;
end;

function TpvCanvasPath.ArcTo(const aP0,aP1:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath;
var Command:PpvCanvasPathCommand;
begin
 Command:=NewCommand;
 Command^.CommandType:=TpvCanvasPathCommandType.ArcTo;
 Command^.Points[0]:=aP0;
 Command^.Points[1]:=aP1;
 Command^.Points[2]:=TpvVector2.InlineableCreate(aRadius,aRadius);
 fStartPointSeen:=true;
 result:=self;
end;

function TpvCanvasPath.ArcToBezier(const aOrigin,aRadius:TpvVector2;const aStartAngle,aEndAngle:TpvFloat;const aCounterClockwise:boolean;const aRotation:TpvFloat):TpvCanvasPath;
type TMatrix=array[0..5] of TpvFloat;
var SweepDirection:TpvInt32;    
    ArcSweepLeft,StartAngle,CurrentStartAngle,CurrentEndAngle:TpvFloat;
    CurrentStartOffset,CurrentEndOffset,cp0,cp1,RotationSinCos:TpvVector2;
    KappaFactor:TpvFloat;
    Matrix:TMatrix;
begin
 
 // Calculate the sweep direction
 if aCounterClockwise then begin
  SweepDirection:=-1;
 end else begin
  SweepDirection:=1;
 end;

 // Calculate the total arc we're going to sweep
 ArcSweepLeft:=(aEndAngle-aStartAngle)*SweepDirection;

 // Ensure the sweep is positive, and normalize it
 if ArcSweepLeft<0.0 then begin
  ArcSweepLeft:=TwoPI+(ArcSweepLeft-(Floor(ArcSweepLeft/TwoPI)*TwoPI));
  StartAngle:=aEndAngle-(ArcSweepLeft*SweepDirection);
 end else if ArcSweepLeft>TwoPI then begin
  ArcSweepLeft:=TwoPI;
  StartAngle:=aStartAngle;
 end else begin
  StartAngle:=aStartAngle;
 end;

 // Create transformation matrix from scratch at once
 SinCos(aRotation,RotationSinCos.x,RotationSinCos.y);

 Matrix[0]:=aRadius.x*RotationSinCos.y;
 Matrix[1]:=aRadius.y*RotationSinCos.x;
 Matrix[2]:=-aRadius.x*RotationSinCos.x;
 Matrix[3]:=aRadius.y*RotationSinCos.y;
 Matrix[4]:=aOrigin.x;
 Matrix[5]:=aOrigin.y;

 // Current start angle and offset (unit circle)
 CurrentStartAngle:=StartAngle;
 SinCos(StartAngle,CurrentStartOffset.y,CurrentStartOffset.x);

 // Move to the start point (transformed) 
 if fStartPointSeen then begin
  LineTo(TpvVector2.InlineableCreate((CurrentStartOffset.x*Matrix[0])+(CurrentStartOffset.y*Matrix[2])+Matrix[4],
                                     (CurrentStartOffset.x*Matrix[1])+(CurrentStartOffset.y*Matrix[3])+Matrix[5]));
 end else begin
  MoveTo(TpvVector2.InlineableCreate((CurrentStartOffset.x*Matrix[0])+(CurrentStartOffset.y*Matrix[2])+Matrix[4],
                                     (CurrentStartOffset.x*Matrix[1])+(CurrentStartOffset.y*Matrix[3])+Matrix[5]));
 end;

 while ArcSweepLeft>0.0 do begin

  // Calculate the end angle and offset (unit circle)
  CurrentEndAngle:=CurrentStartAngle+(Min(ArcSweepLeft,HalfPI)*SweepDirection);
  SinCos(CurrentEndAngle,CurrentEndOffset.y,CurrentEndOffset.x);

  // Calculate the kappa factor
  KappaFactor:=(4.0/3.0)*tan((CurrentEndAngle-CurrentStartAngle)*0.25);

  // Calculate the control points
  cp0:=TpvVector2.InlineableCreate(CurrentStartOffset.x-(CurrentStartOffset.y*KappaFactor),
                                   CurrentStartOffset.y+(CurrentStartOffset.x*KappaFactor));
  cp1:=TpvVector2.InlineableCreate(CurrentEndOffset.x+(CurrentEndOffset.y*KappaFactor),
                                   CurrentEndOffset.y-(CurrentEndOffset.x*KappaFactor));

  // Draw the current arc segment as a Bezier curve (using baked coordinates)
  CubicCurveTo(TpvVector2.InlineableCreate((cp0.x*Matrix[0])+(cp0.y*Matrix[2])+Matrix[4],
                                           (cp0.x*Matrix[1])+(cp0.y*Matrix[3])+Matrix[5]),
               TpvVector2.InlineableCreate((cp1.x*Matrix[0])+(cp1.y*Matrix[2])+Matrix[4],
                                           (cp1.x*Matrix[1])+(cp1.y*Matrix[3])+Matrix[5]),
               TpvVector2.InlineableCreate((CurrentEndOffset.x*Matrix[0])+(CurrentEndOffset.y*Matrix[2])+Matrix[4],
                                           (CurrentEndOffset.x*Matrix[1])+(CurrentEndOffset.y*Matrix[3])+Matrix[5]));

  // Move to the next segment 
  ArcSweepLeft:=ArcSweepLeft-HalfPI;
  CurrentStartAngle:=CurrentEndAngle;
  CurrentStartOffset:=CurrentEndOffset;

 end;

 result:=self;

end;

function TpvCanvasPath.Arc(const aCenter:TpvVector2;const aRadius,aStartAngle,aEndAngle:TpvFloat;const aCounterClockwise:boolean):TpvCanvasPath;
{$undef UseArcToBezier}
{$ifdef UseArcToBezier}
begin
 ArcToBezier(aCenter,TpvVector2.InlineableCreate(aRadius,aRadius),aStartAngle,aEndAngle,aCounterClockwise,0.0);
 result:=self;
end;
{$else}
var SegmentIndex,CountSegments:TpvInt32;
    SweepAngle,AngleStep,Angle,KappaAlpha:TpvFloat;
    CurrentPoint,NextPoint,Normal,CurrentTangent,NextTangent:TpvVector2;
begin

 // Calculate the sweep direction
 SweepAngle:=aEndAngle-aStartAngle;

 // Normalize the angles for clockwise or counterclockwise direction
 if aCounterClockwise then begin
  if abs(SweepAngle)>=TwoPI then begin
   SweepAngle:=-TwoPI;
  end else if SweepAngle>0.0 then begin
   SweepAngle:=SweepAngle-TwoPI;
  end;
 end else begin
  if abs(SweepAngle)>=TwoPI then begin
   SweepAngle:=TwoPI;
  end else if SweepAngle<0.0 then begin
   SweepAngle:=SweepAngle+TwoPI;
  end;
 end;

 // Split into smaller segments
 CountSegments:=ceil(abs(SweepAngle)/HalfPI);

 // If there are no segments, then just move to the end point for to avoid division by zero
 if CountSegments=0 then begin

  SinCos(aEndAngle,Normal.x,Normal.y);

  CurrentPoint:=TpvVector2.InlineableCreate(aCenter.x+(Normal.y*aRadius),aCenter.y+(Normal.x*aRadius));

  if fStartPointSeen then begin
   LineTo(CurrentPoint);
  end else begin
   MoveTo(CurrentPoint);
  end;

 end else begin

  // Calculate the angle step
  Angle:=aStartAngle;
  AngleStep:=SweepAngle/CountSegments;

  // Calculate kappa alpha factor
  KappaAlpha:=(4.0/3.0)*tan(AngleStep*0.25);

  SinCos(Angle,Normal.x,Normal.y);

  NextTangent:=TpvVector2.InlineableCreate(Normal.x,-Normal.y)*aRadius*KappaAlpha;

  NextPoint.x:=aCenter.x+(Normal.y*aRadius);
  NextPoint.y:=aCenter.y+(Normal.x*aRadius);

  // Iterate over all segments
  for SegmentIndex:=0 to CountSegments-1 do begin

   // Calculate the next angle
   Angle:=Angle+AngleStep;

   // Calculate rotation
   SinCos(Angle,Normal.x,Normal.y);

   // Calculate the start and end points
   CurrentPoint:=NextPoint;
   NextPoint.x:=aCenter.x+(Normal.y*aRadius);
   NextPoint.y:=aCenter.y+(Normal.x*aRadius);

   // Calculate tangents
   CurrentTangent:=NextTangent;
   NextTangent:=TpvVector2.InlineableCreate(Normal.x,-Normal.y)*aRadius*KappaAlpha;

   // If it is the first segment, then move to the start point
   if SegmentIndex=0 then begin
    if fStartPointSeen then begin
     LineTo(CurrentPoint);
    end else begin
     MoveTo(CurrentPoint);
    end;
   end;

   // Draw the cubic Bezier curve to approximate the arc segment
   CubicCurveTo(CurrentPoint-CurrentTangent,NextPoint+NextTangent,NextPoint);

  end;

 end;

 result:=self;

end;
{$endif}

function TpvCanvasPath.Ellipse(const aCenter,aRadius:TpvVector2):TpvCanvasPath;
const ARC_MAGIC=0.5522847498; // 4/3 * (1-cos 45�)/sin 45� = 4/3 * (sqrt(2) - 1)
begin
 MoveTo(TpvVector2.InlineableCreate(aCenter.x+aRadius.x,aCenter.y));
 CubicCurveTo(TpvVector2.InlineableCreate(aCenter.x+aRadius.x,aCenter.y-(aRadius.y*ARC_MAGIC)),
              TpvVector2.InlineableCreate(aCenter.x+(aRadius.x*ARC_MAGIC),aCenter.y-aRadius.y),
              TpvVector2.InlineableCreate(aCenter.x,aCenter.y-aRadius.y));
 CubicCurveTo(TpvVector2.InlineableCreate(aCenter.x-(aRadius.x*ARC_MAGIC),aCenter.y-aRadius.y),
              TpvVector2.InlineableCreate(aCenter.x-aRadius.x,aCenter.y-(aRadius.y*ARC_MAGIC)),
              TpvVector2.InlineableCreate(aCenter.x-aRadius.x,aCenter.y));
 CubicCurveTo(TpvVector2.InlineableCreate(aCenter.x-aRadius.x,aCenter.y+(aRadius.y*ARC_MAGIC)),
              TpvVector2.InlineableCreate(aCenter.x-(aRadius.x*ARC_MAGIC),aCenter.y+aRadius.y),
              TpvVector2.InlineableCreate(aCenter.x,aCenter.y+aRadius.y));
 CubicCurveTo(TpvVector2.InlineableCreate(aCenter.x+(aRadius.x*ARC_MAGIC),aCenter.y+aRadius.y),
              TpvVector2.InlineableCreate(aCenter.x+aRadius.x,aCenter.y+(aRadius.y*ARC_MAGIC)),
              TpvVector2.InlineableCreate(aCenter.x+aRadius.x,aCenter.y));
 ClosePath;
 result:=self;
end;

function TpvCanvasPath.Circle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath;
begin
 result:=Ellipse(aCenter,TpvVector2.InlineableCreate(aRadius,aRadius));
end;

function TpvCanvasPath.Rectangle(const aCenter,aBounds:TpvVector2):TpvCanvasPath;
begin
 MoveTo(TpvVector2.InlineableCreate(aCenter.x-aBounds.x,aCenter.y-aBounds.y));
 LineTo(TpvVector2.InlineableCreate(aCenter.x+aBounds.x,aCenter.y-aBounds.y));
 LineTo(TpvVector2.InlineableCreate(aCenter.x+aBounds.x,aCenter.y+aBounds.y));
 LineTo(TpvVector2.InlineableCreate(aCenter.x-aBounds.x,aCenter.y+aBounds.y));
 ClosePath;
 result:=self;
end;

function TpvCanvasPath.RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvasPath;
const ARC_MAGIC=0.5522847498; // 4/3 * (1-cos 45�)/sin 45� = 4/3 * (sqrt(2) - 1)
var Offset,Size,TopLeft,TopRight,BottomLeft,BottomRight:TpvVector2;
begin
 if IsZero(aRadiusTopLeft) and
    IsZero(aRadiusTopRight) and
    IsZero(aRadiusBottomLeft) and
    IsZero(aRadiusBottomRight) then begin
  MoveTo(TpvVector2.InlineableCreate(aCenter.x-aBounds.x,aCenter.y-aBounds.y));
  LineTo(TpvVector2.InlineableCreate(aCenter.x+aBounds.x,aCenter.y-aBounds.y));
  LineTo(TpvVector2.InlineableCreate(aCenter.x+aBounds.x,aCenter.y+aBounds.y));
  LineTo(TpvVector2.InlineableCreate(aCenter.x-aBounds.x,aCenter.y+aBounds.y));
  ClosePath;
 end else begin
  Offset:=aCenter-aBounds;
  Size:=aBounds*2.0;
  TopLeft:=TpvVector2.InlineableCreate(Min(ABounds.x,aRadiusTopLeft)*Sign(Size.x),
                                       Min(ABounds.y,aRadiusTopLeft)*Sign(Size.y));
  TopRight:=TpvVector2.InlineableCreate(Min(ABounds.x,aRadiusTopRight)*Sign(Size.x),
                                        Min(ABounds.y,aRadiusTopRight)*Sign(Size.y));
  BottomLeft:=TpvVector2.InlineableCreate(Min(ABounds.x,aRadiusBottomLeft)*Sign(Size.x),
                                          Min(ABounds.y,aRadiusBottomLeft)*Sign(Size.y));
  BottomRight:=TpvVector2.InlineableCreate(Min(ABounds.x,aRadiusBottomRight)*Sign(Size.x),
                                           Min(ABounds.y,aRadiusBottomRight)*Sign(Size.y));
  MoveTo(Offset+TpvVector2.InlineableCreate(0.0,TopLeft.y));
  LineTo(Offset+TpvVector2.InlineableCreate(0.0,Size.y-BottomLeft.y));
  CubicCurveTo(Offset+TpvVector2.InlineableCreate(0.0,Size.y-(BottomLeft.y*(1.0-ARC_MAGIC))),
               Offset+TpvVector2.InlineableCreate(BottomLeft.x*(1.0-ARC_MAGIC),Size.y),
               Offset+TpvVector2.InlineableCreate(BottomLeft.x,Size.y));
  LineTo(Offset+TpvVector2.InlineableCreate(Size.x-BottomRight.x,Size.y));
  CubicCurveTo(Offset+TpvVector2.InlineableCreate(Size.x-(BottomRight.x*(1.0-ARC_MAGIC)),Size.y),
               Offset+TpvVector2.InlineableCreate(Size.x,Size.y-(BottomRight.y*(1.0-ARC_MAGIC))),
               Offset+TpvVector2.InlineableCreate(Size.x,Size.y-BottomRight.y));
  LineTo(Offset+TpvVector2.InlineableCreate(Size.x,TopRight.y));
  CubicCurveTo(Offset+TpvVector2.InlineableCreate(Size.x,TopRight.y*(1.0-ARC_MAGIC)),
               Offset+TpvVector2.InlineableCreate(Size.x-(TopRight.x*(1.0-ARC_MAGIC)),0.0),
               Offset+TpvVector2.InlineableCreate(Size.x-TopRight.x,0.0));
  LineTo(Offset+TpvVector2.InlineableCreate(TopLeft.y,0.0));
  CubicCurveTo(Offset+TpvVector2.InlineableCreate(TopLeft.x*(1.0-ARC_MAGIC),0.0),
               Offset+TpvVector2.InlineableCreate(0.0,TopLeft.y*(1.0-ARC_MAGIC)),
               Offset+TpvVector2.InlineableCreate(0.0,TopLeft.y));
  ClosePath;
 end;
 result:=self;
end;

function TpvCanvasPath.RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvasPath;
begin
 result:=RoundedRectangle(aCenter,aBounds,aRadius,aRadius,aRadius,aRadius);
end;

constructor TpvCanvasState.Create;
begin
 inherited Create;
 fClipRect:=TpvRect.CreateAbsolute(-MaxSingle,-MaxSingle,MaxSingle,MaxSingle);
 fClipSpaceClipRect:=TpvRect.CreateAbsolute(-MaxSingle,-MaxSingle,MaxSingle,MaxSingle);
 fScissor:=TVkRect2D.Create(TVkOffset2D.Create(0,0),TVkExtent2D.Create($7fffffff,$7fffffff));
 fProjectionMatrix:=TpvMatrix4x4.Identity;
 fPath:=TpvCanvasPath.Create;
 Reset;
end;

destructor TpvCanvasState.Destroy;
begin
 FreeAndNil(fPath);
 inherited Destroy;
end;

procedure TpvCanvasState.UpdateClipSpaceClipRect(const aCanvas:TpvCanvas);
const Add:TpvVector2=(x:-1.0;y:-1.0);
var Mul:TpvVector2;
begin
 Mul:=TpvVector2.InlineableCreate(2.0/aCanvas.fWidth,2.0/aCanvas.fHeight);
 fClipSpaceClipRect.Min:=(fClipRect.Min*Mul)+Add;
 fClipSpaceClipRect.Max:=(fClipRect.Max*Mul)+Add;
end;

function TpvCanvasState.GetColor:TpvVector4;
begin
 result:=fColor;
end;

procedure TpvCanvasState.SetColor(const aColor:TpvVector4);
begin
 fColor:=aColor;
end;

function TpvCanvasState.GetStartColor:TpvVector4;
begin
 result.x:=fFillMatrix.RawComponents[2,0];
 result.y:=fFillMatrix.RawComponents[2,1];
 result.z:=fFillMatrix.RawComponents[2,2];
 result.w:=fFillMatrix.RawComponents[2,3];
end;

procedure TpvCanvasState.SetStartColor(const aColor:TpvVector4);
begin
 fFillMatrix.RawComponents[2,0]:=aColor.x;
 fFillMatrix.RawComponents[2,1]:=aColor.y;
 fFillMatrix.RawComponents[2,2]:=aColor.z;
 fFillMatrix.RawComponents[2,3]:=aColor.w;
end;

function TpvCanvasState.GetStopColor:TpvVector4;
begin
 result.x:=fFillMatrix.RawComponents[3,0];
 result.y:=fFillMatrix.RawComponents[3,1];
 result.z:=fFillMatrix.RawComponents[3,2];
 result.w:=fFillMatrix.RawComponents[3,3];
end;

procedure TpvCanvasState.SetStopColor(const aColor:TpvVector4);
begin
 fFillMatrix.RawComponents[3,0]:=aColor.x;
 fFillMatrix.RawComponents[3,1]:=aColor.y;
 fFillMatrix.RawComponents[3,2]:=aColor.z;
 fFillMatrix.RawComponents[3,3]:=aColor.w;
end;

function TpvCanvasState.GetFillMatrix:TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=fFillMatrix.RawComponents[0,0];
 result.RawComponents[0,1]:=fFillMatrix.RawComponents[0,1];
 result.RawComponents[0,2]:=0.0;
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=fFillMatrix.RawComponents[1,0];
 result.RawComponents[1,1]:=fFillMatrix.RawComponents[1,1];
 result.RawComponents[1,2]:=0.0;
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=0.0;
 result.RawComponents[2,1]:=0.0;
 result.RawComponents[2,2]:=1.0;
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=fFillMatrix.RawComponents[0,2];
 result.RawComponents[3,1]:=fFillMatrix.RawComponents[1,2];
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

procedure TpvCanvasState.SetFillMatrix(const aMatrix:TpvMatrix4x4);
begin
 fFillMatrix.RawComponents[0,0]:=aMatrix.RawComponents[0,0];
 fFillMatrix.RawComponents[0,1]:=aMatrix.RawComponents[0,1];
 fFillMatrix.RawComponents[1,0]:=aMatrix.RawComponents[1,0];
 fFillMatrix.RawComponents[1,1]:=aMatrix.RawComponents[1,1];
 fFillMatrix.RawComponents[0,2]:=aMatrix.RawComponents[3,0];
 fFillMatrix.RawComponents[1,2]:=aMatrix.RawComponents[3,1];
end;

procedure TpvCanvasState.Reset;
begin
 fBlendingMode:=TpvCanvasBlendingMode.AlphaBlending;
 fZPosition:=0.0;
 fLineWidth:=1.0;
 fMiterLimit:=3.0;
 fLineJoin:=TpvCanvasLineJoin.Round;
 fLineCap:=TpvCanvasLineCap.Round;
 fFillRule:=TpvCanvasFillRule.EvenOdd;
 fFillStyle:=TpvCanvasFillStyle.Color;
 fFillWrapMode:=TpvCanvasFillWrapMode.None;
 fColor:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
 fFont:=nil;
 fFontSize:=-12;
 fTextHorizontalAlignment:=TpvCanvasTextHorizontalAlignment.Leading;
 fTextVerticalAlignment:=TpvCanvasTextVerticalAlignment.Leading;
 fViewMatrix:=TpvMatrix4x4.Identity;
 fModelMatrix:=TpvMatrix4x4.Identity;
 fFillMatrix:=TpvMatrix4x4.Identity;
 fFillMatrix.Columns[2]:=fColor;
 fFillMatrix.Columns[3]:=fColor;
 fMaskMatrix:=TpvMatrix4x4.Identity;
 fPath.fCountCommands:=0;
 fTexture:=nil;
 fAtlasTexture:=nil;
 fMaskTexture:=nil;
 fGUIElementMode:=false;
 fStrokePattern:=TpvCanvasStrokePattern.Empty;
end;

procedure TpvCanvasState.Assign(aSource:TPersistent);
begin
 if assigned(aSource) and (aSource is TpvCanvasState) then begin
  fBlendingMode:=TpvCanvasState(aSource).fBlendingMode;
  fZPosition:=TpvCanvasState(aSource).fZPosition;
  fLineWidth:=TpvCanvasState(aSource).fLineWidth;
  fMiterLimit:=TpvCanvasState(aSource).fMiterLimit;
  fLineJoin:=TpvCanvasState(aSource).fLineJoin;
  fLineCap:=TpvCanvasState(aSource).fLineCap;
  fFillRule:=TpvCanvasState(aSource).fFillRule;
  fFillStyle:=TpvCanvasState(aSource).fFillStyle;
  fColor:=TpvCanvasState(aSource).fColor;
  fClipRect:=TpvCanvasState(aSource).fClipRect;
  fClipSpaceClipRect:=TpvCanvasState(aSource).fClipSpaceClipRect;
  fScissor:=TpvCanvasState(aSource).fScissor;
  fProjectionMatrix:=TpvCanvasState(aSource).fProjectionMatrix;
  fViewMatrix:=TpvCanvasState(aSource).fViewMatrix;
  fModelMatrix:=TpvCanvasState(aSource).fModelMatrix;
  fFillMatrix:=TpvCanvasState(aSource).fFillMatrix;
  fMaskMatrix:=TpvCanvasState(aSource).fMaskMatrix;
  fFont:=TpvCanvasState(aSource).fFont;
  fFontSize:=TpvCanvasState(aSource).fFontSize;
  fTextHorizontalAlignment:=TpvCanvasState(aSource).fTextHorizontalAlignment;
  fTextVerticalAlignment:=TpvCanvasState(aSource).fTextVerticalAlignment;
  fPath.Assign(TpvCanvasState(aSource).fPath);
  fTexture:=TpvCanvasState(aSource).fTexture;
  fAtlasTexture:=TpvCanvasState(aSource).fAtlasTexture;
  fMaskTexture:=TpvCanvasState(aSource).fMaskTexture;
  fGUIElementMode:=TpvCanvasState(aSource).fGUIElementMode;
  fStrokePattern:=TpvCanvasState(aSource).fStrokePattern;
 end;
end;

constructor TpvCanvasShape.Create;
begin
 inherited Create;

 fCacheTemporaryLinePoints:=nil;
 fCacheLinePoints:=nil;
 fCacheSegments:=nil;
 fCacheSegmentUniquePoints:=nil;
 fCacheSegmentUniquePointHashTable:=nil;
 fCacheVertices:=nil;
 fCacheIndices:=nil;
 fCacheParts:=nil;
 fCacheYCoordinates:=nil;
 fCacheTemporaryYCoordinates:=nil;

 fCountCacheTemporaryLinePoints:=0;
 fCountCacheLinePoints:=0;
 fCountCacheSegments:=0;
 fCountCacheSegmentUniquePoints:=0;
 fCountCacheVertices:=0;
 fCountCacheIndices:=0;
 fCountCacheParts:=0;
 fCountCacheYCoordinates:=0;

 fForcedCurveTessellationTolerance:=-1.0;

end;

destructor TpvCanvasShape.Destroy;
begin

 fCacheTemporaryLinePoints:=nil;
 fCacheLinePoints:=nil;
 fCacheSegments:=nil;
 fCacheSegmentUniquePoints:=nil;
 fCacheSegmentUniquePointHashTable:=nil;
 fCacheVertices:=nil;
 fCacheIndices:=nil;
 fCacheParts:=nil;
 fCacheYCoordinates:=nil;
 fCacheTemporaryYCoordinates:=nil;

 inherited Destroy;
end;

procedure TpvCanvasShape.BeginPart(const aCountVertices:TpvInt32=0;const aCountIndices:TpvInt32=0);
var CachePart:PpvCanvasShapeCachePart;
begin
 inc(fCountCacheParts);
 if length(fCacheParts)<fCountCacheParts then begin
  SetLength(fCacheParts,fCountCacheParts*2);
 end;
 CachePart:=@fCacheParts[fCountCacheParts-1];
 CachePart^.BaseVertexIndex:=fCountCacheVertices;
 CachePart^.BaseIndexIndex:=fCountCacheIndices;
 CachePart^.CountVertices:=aCountVertices;
 CachePart^.CountIndices:=aCountIndices;
end;

procedure TpvCanvasShape.EndPart;
var CachePart:PpvCanvasShapeCachePart;
begin
 if fCountCacheParts>0 then begin
  CachePart:=@fCacheParts[fCountCacheParts-1];
  CachePart^.CountVertices:=Max(0,fCountCacheVertices-CachePart^.BaseVertexIndex);
  CachePart^.CountIndices:=Max(0,fCountCacheIndices-CachePart^.BaseIndexIndex);
  if (CachePart^.CountVertices=0) and (CachePart^.CountIndices=0) then begin
   dec(fCountCacheParts);
  end;
 end;
end;

function TpvCanvasShape.AddVertex(const Position:TpvVector2;const ObjectMode:TpvUInt8;const MetaInfo,MetaInfo2:TpvVector4;const Offset:TpvVector2):TpvInt32;
var CacheVertex:PpvCanvasShapeCacheVertex;
begin
 result:=fCountCacheVertices;
 inc(fCountCacheVertices);
 if length(fCacheVertices)<fCountCacheVertices then begin
  SetLength(fCacheVertices,fCountCacheVertices*2);
 end;
 CacheVertex:=@fCacheVertices[result];
 CacheVertex^.Position:=Position;
 CacheVertex^.ObjectMode:=ObjectMode;
 CacheVertex^.MetaInfo:=MetaInfo;
 CacheVertex^.MetaInfo2:=MetaInfo2;
 CacheVertex^.Offset:=Offset;
end;

function TpvCanvasShape.AddIndex(const VertexIndex:TpvInt32):TpvInt32;
begin
 result:=fCountCacheIndices;
 inc(fCountCacheIndices);
 if length(fCacheIndices)<fCountCacheIndices then begin
  SetLength(fCacheIndices,fCountCacheIndices*2);
 end;
 fCacheIndices[result]:=VertexIndex;
end;

function TpvCanvasShape.GetWindingNumberAtPointInPolygon(const Point:TpvVector2):TpvInt32;
var Index,CaseIndex:TpvInt32;
    ShapeCacheSegment:PpvCanvasShapeCacheSegment;
    x0,y0,x1,y1:TpvFloat;
begin
 result:=0;
 for Index:=0 to fCountCacheSegments-1 do begin
  ShapeCacheSegment:=@fCacheSegments[Index];
  y0:=fCacheSegmentUniquePoints[ShapeCacheSegment^.Points[0]].Point.y-Point.y;
  y1:=fCacheSegmentUniquePoints[ShapeCacheSegment^.Points[1]].Point.y-Point.y;
  if y0<0.0 then begin
   CaseIndex:=0;
  end else if y0>0.0 then begin
   CaseIndex:=2;
  end else begin
   CaseIndex:=1;
  end;
  if y1<0.0 then begin
   inc(CaseIndex,0);
  end else if y1>0.0 then begin
   inc(CaseIndex,6);
  end else begin
   inc(CaseIndex,3);
  end;
  if CaseIndex in [1,2,3,6] then begin
   x0:=fCacheSegmentUniquePoints[ShapeCacheSegment^.Points[0]].Point.x-Point.x;
   x1:=fCacheSegmentUniquePoints[ShapeCacheSegment^.Points[1]].Point.x-Point.x;
   if not (((x0>0.0) and (x1>0.0)) or ((not ((x0<=0.0) and (x1<=0.0))) and ((x0-(y0*((x1-x0)/(y1-y0))))>0.0))) then begin
    if CaseIndex in [1,2] then begin
     inc(result);
    end else begin
     dec(result);
    end;
   end;
  end;
 end;
end;

procedure TpvCanvasShape.InitializeCurveTessellationTolerance(const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
var Scale,PixelRatio:TpvFloat;
begin
 if fForcedCurveTessellationTolerance>0.0 then begin
  fCurveTessellationTolerance:=fForcedCurveTessellationTolerance;
 end else begin
  Scale:=((sqrt(sqr(aState.fModelMatrix.RawComponents[0,0])+sqr(aState.fModelMatrix.RawComponents[0,1]))+
           sqrt(sqr(aState.fModelMatrix.RawComponents[1,0])+sqr(aState.fModelMatrix.RawComponents[1,1])))*0.5)*
         ((aState.fViewMatrix.Right.xyz.Length+aState.fViewMatrix.Up.xyz.Length)*0.5);
  if assigned(aCanvas) then begin
   Scale:=Scale*
          (((aState.fProjectionMatrix.Right.xyz.Length+aState.fProjectionMatrix.Up.xyz.Length)*0.5)/
           ((1.0/aCanvas.fWidth)+(1.0/aCanvas.fHeight)));
   PixelRatio:=aCanvas.fWidth/aCanvas.fHeight;
  end else begin
   PixelRatio:=1.0;
  end;
  fCurveTessellationTolerance:=(0.5*Scale)/PixelRatio;
 end;
 fCurveTessellationToleranceSquared:=sqr(fCurveTessellationTolerance);
end;

procedure TpvCanvasShape.Reset;
begin

 fCountCacheTemporaryLinePoints:=0;
 fCountCacheLinePoints:=0;
 fCountCacheSegments:=0;
 fCountCacheSegmentUniquePoints:=0;
 fCountCacheVertices:=0;
 fCountCacheIndices:=0;
 fCountCacheParts:=0;
 fCountCacheYCoordinates:=0;

end;

procedure TpvCanvasShape.StrokeFromPath(const aPath:TpvCanvasPath;const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
var StartPoint,LastPoint:TpvVector2;
 procedure StrokeAddPoint(const aP0:TpvVector2);
 var Index:TpvInt32;
     ShapeCacheLinePoint:PpvCanvasShapeCacheLinePoint;
 begin
  if (fCountCacheLinePoints=0) or
     (fCacheLinePoints[fCountCacheLinePoints-1].Position<>aP0) then begin
   Index:=fCountCacheLinePoints;
   inc(fCountCacheLinePoints);
   if length(fCacheLinePoints)<fCountCacheLinePoints then begin
    SetLength(fCacheLinePoints,fCountCacheLinePoints*2);
   end;
   ShapeCacheLinePoint:=@fCacheLinePoints[Index];
   ShapeCacheLinePoint^.Position:=aP0;
  end;
 end;
 procedure ConvertStroke(var aLinePoints:TpvCanvasShapeCacheLinePoints;var aCountLinePoints:TpvInt32);
 var Closed:boolean;
     Width:TpvFloat;
     v0,v1,v2,v3:TpvVector2;
     First:boolean;
  procedure TriangulateSegment(const p0,p1,p2:TpvVector2;const LineJoin:TpvCanvasLineJoin;MiterLimit:TpvFloat;const IsFirst,IsLast:boolean);
   function LineIntersection(out p:TpvVector2;const v0,v1,v2,v3:TpvVector2):boolean;
   const EPSILON=1e-8;
   var a0,a1,b0,b1,c0,c1,Determinant:TpvFloat;
   begin
    a0:=v1.y-v0.y;
    b0:=v0.x-v1.x;
    a1:=v3.y-v2.y;
    b1:=v2.x-v3.x;
    Determinant:=(a0*b1)-(a1*b0);
    result:=abs(Determinant)>EPSILON;
    if result then begin
     c0:=(a0*v0.x)+(b0*v0.y);
     c1:=(a1*v2.x)+(b1*v2.y);
     p.x:=((b1*c0)-(b0*c1))/Determinant;
     p.y:=((a0*c1)-(a1*c0))/Determinant;
    end;
   end;
   function SignedArea(const v1,v2,v3:TpvVector2):TpvFloat;
   begin
    result:=((v2.x-v1.x)*(v3.y-v1.y))-((v3.x-v1.x)*(v2.y-v1.y));
   end;
   procedure AddRoundJoin(const Center,p0,p1,NextPointInLine:TpvVector2);
   var iP0,iP1,iCenter,iP0Normal,iP1Normal:TPvInt32;
       Radius:TpvFloat;
       MetaInfo,MetaInfo2:TpvVector4;
       Normal:TpvVector2;
   begin
    // An arc inside three triangles
    Radius:=p0.DistanceTo(Center);
    MetaInfo:=TpvVector4.InlineableCreate(Center.x,Center.y,Radius,-1.0);
    MetaInfo2:=TpvVector4.Null;
    Radius:=Radius+1.0; // Add some headroom to the radius
    Normal:=(Center-NextPointInLine).Normalize*Radius;
    BeginPart(5,9);
    iP0:=AddVertex(p0,pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null);
    iP1:=AddVertex(p1,pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null);
    iP0Normal:=AddVertex(p0+Normal,pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null);
    iP1Normal:=AddVertex(p1+Normal,pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null);
    iCenter:=AddVertex(Center,pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null);
    AddIndex(iP0Normal);
    AddIndex(iP0);
    AddIndex(iCenter);
    AddIndex(iCenter);
    AddIndex(iP1);
    AddIndex(iP1Normal);
    AddIndex(iP0Normal);
    AddIndex(iCenter);
    AddIndex(iP1Normal);
    EndPart;
   end;
  var CountVerticesToAdd,CountIndicesToAdd,LineJoinCase,
      ip0at0,ip0st0,ip1sAnchor,ip1at0,ip1st0,ip2at2,ip1st2,ip1at2,ip2st2,ip1,iIntersectionPoint,iCenter:TpvInt32;
      t0,t2,IntersectionPoint,Anchor,p0p1,p1p2:TpvVector2;
      AnchorLength,dd,p0p1Length,p1p2Length,l0,l2,s0,s2:TpvFloat;
      DoIntersect:boolean;
  begin
   t0:=(p1-p0).Perpendicular.Normalize*Width;
   t2:=(p2-p1).Perpendicular.Normalize*Width;
   if SignedArea(p0,p1,p2)>0.0 then begin
    t0:=-t0;
    t2:=-t2;
   end;
   DoIntersect:=LineIntersection(IntersectionPoint,p0+t0,p1+t0,p2+t2,p1+t2);
   if DoIntersect and not (IsFirst and IsLast) then begin
    Anchor:=IntersectionPoint-p1;
    AnchorLength:=Anchor.Length;
    dd:=AnchorLength/Width;
   end else begin
    Anchor:=TpvVector2.Null;
    AnchorLength:=3.4e+28;
    dd:=0.0;
   end;
   p0p1:=p0-p1;
   p1p2:=p1-p2;
   p0p1Length:=p0p1.Length;
   p1p2Length:=p1p2.Length;
   if First then begin
    v0:=p0+t0;
    v1:=p0-t0;
   end;
   v2:=p2-t2;
   v3:=p2+t2;
   if Closed or (aState.fLineCap<>TpvCanvasLineCap.Butt) then begin
    l0:=0.0;
    l2:=0.0;
    s0:=Width;
    s2:=Width;
   end else begin
    if IsFirst then begin
     l0:=p0.DistanceTo(p1);
     s0:=l0;
    end else begin
     l0:=0.0;
     s0:=Width;
    end;
    if IsLast then begin
     l2:=p1.DistanceTo(p2);
     s2:=l2;
    end else begin
     l2:=0.0;
     s2:=Width;
    end;
   end;
   if (AnchorLength>p0p1Length) or (AnchorLength>p1p2Length) then begin
    // The cross point exceeds any of the segments dimension.
    // Do not use cross point as reference.
    // This case deserves more attention to avoid redraw, currently works by overdrawing large parts.
    CountVerticesToAdd:=8;
    CountIndicesToAdd:=12;
    if LineJoin=TpvCanvasLineJoin.Round then begin
     LineJoinCase:=0;
    end else if (LineJoin=TpvCanvasLineJoin.Bevel) or ((LineJoin=TpvCanvasLineJoin.Miter) and (dd>=MiterLimit)) then begin
     LineJoinCase:=1;
     inc(CountVerticesToAdd,3);
     inc(CountIndicesToAdd,3);
    end else if (LineJoin=TpvCanvasLineJoin.Miter) and (dd<MiterLimit) and DoIntersect then begin
     LineJoinCase:=2;
     inc(CountVerticesToAdd,4);
     inc(CountIndicesToAdd,6);
    end else begin
     LineJoinCase:=3;
    end;
    BeginPart(CountVerticesToAdd,CountIndicesToAdd);
    begin
     ip0at0:=AddVertex(p0+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,l0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip0st0:=AddVertex(p0-t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,l0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip1st0:=AddVertex(p1-t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     AddIndex(ip0at0);
     AddIndex(ip0st0);
     AddIndex(ip1at0);
     AddIndex(ip0st0);
     AddIndex(ip1at0);
     AddIndex(ip1st0);
     ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip2at2:=AddVertex(p2+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,l2,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip1st2:=AddVertex(p1-t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip2st2:=AddVertex(p2-t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,l2,Width,s2),TpvVector4.Null,TpvVector2.Null);
     AddIndex(ip2at2);
     AddIndex(ip1st2);
     AddIndex(ip1at2);
     AddIndex(ip2at2);
     AddIndex(ip1st2);
     AddIndex(ip2st2);
     case LineJoinCase of
      0:begin
       // Round join
      end;
      1:begin
       // Bevel join
       ip1:=AddVertex(p1,pcvvaomLineEdge,TpvVector4.InlineableCreate(0.0,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
       AddIndex(ip1);
       AddIndex(ip1at0);
       AddIndex(ip1at2);
      end;
      2:begin
       // Miter join
       ip1:=AddVertex(p1,pcvvaomLineEdge,TpvVector4.InlineableCreate(0.0,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       iIntersectionPoint:=AddVertex(IntersectionPoint,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       AddIndex(ip1at0);
       AddIndex(ip1);
       AddIndex(iIntersectionPoint);
       AddIndex(ip1at2);
       AddIndex(ip1);
       AddIndex(iIntersectionPoint);
      end;
      else begin
       // Nothing
      end;
     end;
    end;
    EndPart;
    if LineJoinCase=0 then begin
     // Round join
     AddRoundJoin(p1,p1+t0,p1+t2,p2);
    end;
   end else begin
    CountVerticesToAdd:=8;
    CountIndicesToAdd:=12;
    if LineJoin=TpvCanvasLineJoin.Round then begin
     LineJoinCase:=0;
     inc(CountVerticesToAdd,4);
     inc(CountIndicesToAdd,6);
    end else if (LineJoin=TpvCanvasLineJoin.Bevel) or ((LineJoin=TpvCanvasLineJoin.Miter) and (dd>=MiterLimit)) then begin
     LineJoinCase:=1;
     inc(CountVerticesToAdd,3);
     inc(CountIndicesToAdd,3);
    end else if (LineJoin=TpvCanvasLineJoin.Miter) and (dd<MiterLimit) and DoIntersect then begin
     LineJoinCase:=2;
     inc(CountVerticesToAdd,4);
     inc(CountIndicesToAdd,6);
    end else begin
     LineJoinCase:=3;
    end;
    BeginPart(CountVerticesToAdd,CountIndicesToAdd);
    begin
     ip0at0:=AddVertex(p0+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,l0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip0st0:=AddVertex(p0-t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,l0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip1sAnchor:=AddVertex(p1-Anchor,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,s0),TpvVector4.Null,TpvVector2.Null);
     AddIndex(ip0at0);
     AddIndex(ip0st0);
     AddIndex(ip1sAnchor);
     AddIndex(ip0at0);
     AddIndex(ip1sAnchor);
     AddIndex(ip1at0);
     ip1sAnchor:=AddVertex(p1-Anchor,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip2at2:=AddVertex(p2+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,l2,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,s2),TpvVector4.Null,TpvVector2.Null);
     ip2st2:=AddVertex(p2-t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,l2,Width,s2),TpvVector4.Null,TpvVector2.Null);
     AddIndex(ip2at2);
     AddIndex(ip1sAnchor);
     AddIndex(ip1at2);
     AddIndex(ip2at2);
     AddIndex(ip1sAnchor);
     AddIndex(ip2st2);
     case LineJoinCase of
      0:begin
       // Round join
       ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1:=AddVertex(p1,pcvvaomLineEdge,TpvVector4.InlineableCreate(0.0,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1sAnchor:=AddVertex(p1-Anchor,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       AddIndex(ip1at0);
       AddIndex(ip1);
       AddIndex(ip1sAnchor);
       AddIndex(ip1);
       AddIndex(ip1at2);
       AddIndex(ip1sAnchor);
      end;
      1:begin
       // Bevel join
       ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1sAnchor:=AddVertex(p1-Anchor,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       AddIndex(ip1at0);
       AddIndex(ip1at2);
       AddIndex(ip1sAnchor);
      end;
      2:begin
       // Miter join
       ip1at0:=AddVertex(p1+t0,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       ip1at2:=AddVertex(p1+t2,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       iCenter:=AddVertex(p1-Anchor,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       iIntersectionPoint:=AddVertex(IntersectionPoint,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
       AddIndex(ip1at0);
       AddIndex(iCenter);
       AddIndex(iIntersectionPoint);
       AddIndex(iCenter);
       AddIndex(ip1at2);
       AddIndex(iIntersectionPoint);
      end;
     end;
    end;
    EndPart;
    if LineJoinCase=0 then begin
     // Round join
     AddRoundJoin(p1,p1+t0,p1+t2,p1-Anchor);
    end;
   end;
   First:=false;
  end;
  procedure AddSquareCap(const p0,p1,d:TpvVector2);
  var ip0,ip0d,ip1d,ip1:TpvInt32;
  begin
   BeginPart(4,6);
   ip0:=AddVertex(p0,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
   ip0d:=AddVertex(p0+d,pcvvaomLineEdge,TpvVector4.InlineableCreate(-Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
   ip1d:=AddVertex(p1+d,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,Width,Width,Width),TpvVector4.Null,TpvVector2.Null);
   ip1:=AddVertex(p1,pcvvaomLineEdge,TpvVector4.InlineableCreate(Width,0.0,Width,Width),TpvVector4.Null,TpvVector2.Null);
   AddIndex(ip0);
   AddIndex(ip0d);
   AddIndex(ip1d);
   AddIndex(ip1);
   AddIndex(ip1d);
   AddIndex(ip0);
   EndPart;
  end;
  procedure AddRoundCap(const Center,p0,p1,NextPointInLine:TpvVector2);
  const Sqrt2=1.414213562373095;
  var Radius:TpvFloat;
      MetaInfo,MetaInfo2:TpvVector4;
  begin
   // An "inhalfcircle" inside an one single triangle
   Radius:=p0.DistanceTo(Center);
   MetaInfo:=TpvVector4.InlineableCreate(Center.x,Center.y,Radius,-1.0);
   MetaInfo2:=TpvVector4.Null;
   Radius:=Radius+1.0; // Add some headroom to the radius
   BeginPart(3,3);
   AddIndex(AddVertex(Center+((p0-Center).Normalize*Radius*Sqrt2),pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null));
   AddIndex(AddVertex(Center+((p1-Center).Normalize*Radius*Sqrt2),pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null));
   AddIndex(AddVertex(Center+((Center-NextPointInLine).Normalize*Radius*Sqrt2),pcvvaomRoundLineCapCircle,MetaInfo,MetaInfo2,TpvVector2.Null));
   EndPart;
  end;
 var i:TpvInt32;
 begin
  if aCountLinePoints>1 then begin
   for i:=aCountLinePoints-2 downto 0 do begin
    if aLinePoints[i].Position=aLinePoints[i+1].Position then begin
     dec(aCountLinePoints);
     Move(aLinePoints[i-1],aLinePoints[i],aCountLinePoints*SizeOf(TpvCanvasShapeCacheLinePoint));
    end;
   end;
   if aCountLinePoints>1 then begin
    Width:=abs(aState.fLineWidth)*0.5;
    First:=true;
    if aCountLinePoints=2 then begin
     Closed:=false;
     TriangulateSegment(aLinePoints[0].Position,
                        aLinePoints[0].Position.Lerp(aLinePoints[1].Position,0.5),
                        aLinePoints[1].Position,
                        TpvCanvasLineJoin.Bevel,
                        aState.fMiterLimit,
                        true,
                        true);
    end else if aCountLinePoints>2 then begin
     Closed:=aLinePoints[0].Position.DistanceTo(aLinePoints[aCountLinePoints-1].Position)<EPSILON;
     if Closed then begin
      aLinePoints[0].Position:=(aLinePoints[0].Position+aLinePoints[1].Position)*0.5;
      inc(aCountLinePoints);
      if aCountLinePoints>length(aLinePoints) then begin
       SetLength(aLinePoints,aCountLinePoints*2);
      end;
      aLinePoints[aCountLinePoints-1]:=aLinePoints[0];
     end;
     aLinePoints[0].Middle:=aLinePoints[0].Position;
     for i:=1 to aCountLinePoints-3 do begin
      aLinePoints[i].Middle:=(aLinePoints[i].Position+aLinePoints[i+1].Position)*0.5;
     end;
     aLinePoints[aCountLinePoints-2].Middle:=aLinePoints[aCountLinePoints-1].Position;
     for i:=1 to aCountLinePoints-2 do begin
      TriangulateSegment(aLinePoints[i-1].Middle,
                         aLinePoints[i].Position,
                         aLinePoints[i].Middle,
                         aState.fLineJoin,
                         aState.fMiterLimit,
                         i=1,
                         i=(aCountLinePoints-2));
     end;
    end;
    if not Closed then begin
     case aState.fLineCap of
      TpvCanvasLineCap.Round:begin
       AddRoundCap(aLinePoints[0].Position,v0,v1,aLinePoints[1].Position);
       AddRoundCap(aLinePoints[aCountLinePoints-1].Position,v2,v3,aLinePoints[aCountLinePoints-2].Position);
      end;
      TpvCanvasLineCap.Square:begin
       AddSquareCap(v0,
                    v1,
                    (aLinePoints[0].Position-aLinePoints[1].Position).Normalize*aLinePoints[0].Position.DistanceTo(v0));
       AddSquareCap(v2,
                    v3,
                    (aLinePoints[aCountLinePoints-1].Position-aLinePoints[aCountLinePoints-2].Position).Normalize*aLinePoints[aCountLinePoints-1].Position.DistanceTo(v3));
      end;
     end;
    end;
   end;
  end;
  aCountLinePoints:=0;
 end;
 procedure StrokeFlush;
  procedure ConvertStrokeWithPattern;
   procedure AddLinePoint(const aP0:TpvVector2);
   var Index:TpvInt32;
       ShapeCacheTemporaryLinePoint:PpvCanvasShapeCacheLinePoint;
   begin
    if (fCountCacheTemporaryLinePoints=0) or
       (fCacheTemporaryLinePoints[fCountCacheTemporaryLinePoints-1].Position<>aP0) then begin
     Index:=fCountCacheTemporaryLinePoints;
     inc(fCountCacheTemporaryLinePoints);
     if length(fCacheTemporaryLinePoints)<fCountCacheTemporaryLinePoints then begin
      SetLength(fCacheTemporaryLinePoints,fCountCacheTemporaryLinePoints*2);
     end;
     ShapeCacheTemporaryLinePoint:=@fCacheTemporaryLinePoints[Index];
     ShapeCacheTemporaryLinePoint^.Position:=aP0;
    end;
   end;
  var DashIndex,PointIndex:TpvInt32;
      IsInLine:boolean;
      LineRemain,LineLen,DashRemain,StartRemain,StepLength,Distance:TpvDouble;
      p0,p1,CurrentPosition:TpvVector2;
  begin
   IsInLine:=false;
   fCountCacheTemporaryLinePoints:=0;
   LineRemain:=0;
   LineLen:=0;
   p0:=TpvVector2.Null;
   p1:=TpvVector2.Null;
   DashIndex:=0;
   DashRemain:=abs(aState.fStrokePattern.fDashes[DashIndex]*aState.fStrokePattern.fDashSize);
   StartRemain:=aState.fStrokePattern.fStart;
   while StartRemain>0.0 do begin
    StepLength:=Min(DashRemain,StartRemain);
    if IsZero(StepLength) then begin
     break;
    end else begin
     StartRemain:=StartRemain-StepLength;
     DashRemain:=DashRemain-StepLength;
     if DashRemain<=0 then begin
      inc(DashIndex);
      if DashIndex>=length(aState.fStrokePattern.fDashes) then begin
       DashIndex:=0;
      end;
      DashRemain:=abs(aState.fStrokePattern.fDashes[DashIndex]*aState.fStrokePattern.fDashSize);
     end;
    end;
   end;
   for PointIndex:=0 to fCountCacheLinePoints-2 do begin
    p0:=fCacheLinePoints[PointIndex].Position;
    p1:=fCacheLinePoints[PointIndex+1].Position;
    LineLen:=p0.DistanceTo(p1);
    LineRemain:=LineLen;
    while LineRemain>0 do begin
     StepLength:=Min(DashRemain,LineRemain);
     if IsZero(StepLength) then begin
      break;
     end else begin
      Distance:=(LineLen-LineRemain)/LineLen;
      CurrentPosition:=p0.Lerp(p1,Distance);
      if (aState.fStrokePattern.fDashes[DashIndex]*aState.fStrokePattern.fDashSize)>0.0 then begin
       IsInLine:=true;
       AddLinePoint(CurrentPosition);
      end else begin
       if IsInLine then begin
        IsInLine:=false;
        AddLinePoint(CurrentPosition);
        ConvertStroke(fCacheTemporaryLinePoints,fCountCacheTemporaryLinePoints);
        fCountCacheTemporaryLinePoints:=0;
       end;
      end;
      LineRemain:=LineRemain-StepLength;
      DashRemain:=DashRemain-StepLength;
      if DashRemain<=0 then begin
       inc(DashIndex);
       if DashIndex>=length(aState.fStrokePattern.fDashes) then begin
        DashIndex:=0;
       end;
       DashRemain:=abs(aState.fStrokePattern.fDashes[DashIndex]*aState.fStrokePattern.fDashSize);
      end;
     end;
    end;
   end;
   if IsInLine and not IsZero(LineLen) then begin
    AddLinePoint(p0.Lerp(p1,(LineLen-LineRemain)/LineLen));
    ConvertStroke(fCacheTemporaryLinePoints,fCountCacheTemporaryLinePoints);
    fCountCacheTemporaryLinePoints:=0;
   end;
  end;
 begin
  if fCountCacheLinePoints>0 then begin
   if (length(aState.fStrokePattern.fDashes)>0) and
      (aState.fStrokePattern.fDashSize>0.0) then begin
    ConvertStrokeWithPattern;
   end else begin
    ConvertStroke(fCacheLinePoints,fCountCacheLinePoints);
   end;
  end;
  fCountCacheLinePoints:=0;
 end;
 procedure StrokeMoveTo(const aP0:TpvVector2);
 begin
  StrokeFlush;
  StrokeAddPoint(aP0);
  StartPoint:=aP0;
  LastPoint:=aP0;
 end;
 procedure StrokeLineTo(const aP0:TpvVector2);
 begin
  StrokeAddPoint(aP0);
  LastPoint:=aP0;
 end;
 procedure StrokeQuadraticCurveTo(const aC0,aA0:TpvVector2);
  procedure Recursive(const x1,y1,x2,y2,x3,y3:TpvFloat;const Level:TpvInt32);
  var x12,y12,x23,y23,x123,y123,dx,dy:TpvFloat;
      Point:TpvVector2;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   dx:=x3-x1;
   dy:=y3-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(((x2-x3)*dy)-((y2-y3)*dx))<((sqr(dx)+sqr(dy))*fCurveTessellationToleranceSquared))) then begin
    Point.x:=x3;
    Point.y:=y3;
    StrokeLineTo(Point);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,level+1);
    Recursive(x123,y123,x23,y23,x3,y3,level+1);
   end;
  end;
 begin
  Recursive(LastPoint.x,LastPoint.y,aC0.x,aC0.y,aA0.x,aA0.y,0);
  StrokeLineTo(aA0);
 end;
 procedure StrokeCubicCurveTo(const aC0,aC1,aA0:TpvVector2);
  procedure Recursive(const x1,y1,x2,y2,x3,y3,x4,y4:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234,dx,dy:TpvDouble;
      Point:TpvVector2;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x34:=(x3+x4)*0.5;
   y34:=(y3+y4)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   x234:=(x23+x34)*0.5;
   y234:=(y23+y34)*0.5;
   x1234:=(x123+x234)*0.5;
   y1234:=(y123+y234)*0.5;
   dx:=x4-x1;
   dy:=y4-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(abs(((x2-x4)*dy)-((y2-y4)*dx))+
            abs(((x3-x4)*dy)-((y3-y4)*dx)))<((sqr(dx)+sqr(dy))*fCurveTessellationToleranceSquared))) then begin
    Point.x:=x4;
    Point.y:=y4;
    StrokeLineTo(Point);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,x1234,y1234,Level+1);
    Recursive(x1234,y1234,x234,y234,x34,y34,x4,y4,Level+1);
   end;
  end;
 begin
  Recursive(LastPoint.x,LastPoint.y,aC0.x,aC0.y,aC1.x,aC1.y,aA0.x,aA0.y,0);
  StrokeLineTo(aA0);
 end;
 procedure StrokeArcTo(const aP1,aP2:TpvVector2;const aRadius:TpvFloat);
 const CCW=0;
       CW=1;
 var Direction,CountSubdivisions,SubdivisionIndex:TpvInt32;
     p0,d01,d21,Center,Normal,Tangent,Current,Previous,PreviousTangent:TpvVector2;
     d,Angle0,Angle1,AngleDifference,PartAngleDifference,Kappa:TpvFloat;
 begin
  if (aP1=aP2) or IsZero(aRadius) then begin
   StrokeLineTo(aP1);
  end else begin
   p0:=LastPoint;
   d01:=(p0-aP1).Normalize;
   d21:=(aP2-aP1).Normalize;
   d:=aRadius/tan(ArcCos(d01.Dot(d21))*0.5);
   if d>1e+4 then begin
    StrokeLineTo(aP1);
   end else begin
    if ((d01.y*d21.x)-(d01.x*d21.y))>0.0 then begin
     Center:=aP1+TpvVector2.InlineableCreate((d01.x*d)+(d01.y*aRadius),(d01.y*d)-(d01.x*aRadius));
     Angle0:=ArcTan2(d01.x,-d01.y);
     Angle1:=ArcTan2(-d21.x,d21.y);
     Direction:=CW;
    end else begin
     Center:=aP1+TpvVector2.InlineableCreate((d01.x*d)-(d01.y*aRadius),(d01.y*d)+(d01.x*aRadius));
     Angle0:=ArcTan2(-d01.x,d01.y);
     Angle1:=ArcTan2(d21.x,-d21.y);
     Direction:=CCW;
    end;
    AngleDifference:=Angle1-Angle0;
    if Direction=CW then begin
     if abs(AngleDifference)>=TwoPI then begin
      AngleDifference:=TwoPI;
     end else begin
      while AngleDifference<0.0 do begin
       AngleDifference:=AngleDifference+TwoPI;
      end;
     end;
    end else begin
     if abs(AngleDifference)>=TwoPI then begin
      AngleDifference:=-TwoPI;
     end else begin
      while AngleDifference>0.0 do begin
       AngleDifference:=AngleDifference-TwoPI;
      end;
     end;
    end;
    CountSubdivisions:=Min(Max(round(abs(AngleDifference)/HalfPI),1),5);
    PartAngleDifference:=AngleDifference/CountSubdivisions;
    Kappa:=abs((4.0/3.0)*(1.0-cos(PartAngleDifference))/sin(PartAngleDifference))*IfThen(Direction=CCW,-1,1);
    Previous:=TpvVector2.Null;
    PreviousTangent:=TpvVector2.Null;
    for SubdivisionIndex:=0 to CountSubdivisions-1 do begin
     SinCos(Mix(Angle0,Angle1,SubdivisionIndex/CountSubdivisions),Normal.y,Normal.x);
     Current:=Center+(Normal*aRadius);
     Tangent:=TpvVector2.InlineableCreate(-Normal.y,Normal.x)*aRadius*Kappa;
     if SubdivisionIndex=0 then begin
      StrokeLineTo(Current);
     end else begin
      StrokeCubicCurveTo(Previous+PreviousTangent,Current-Tangent,Current);
     end;
     Previous:=Current;
     PreviousTangent:=Tangent;
    end;
   end;
  end;
 end;
 procedure StrokeClose;
 begin
  if fCountCacheLinePoints>0 then begin
   StrokeLineTo(StartPoint);
   StrokeFlush;
  end;
 end;
var CommandIndex:TpvInt32;
    Command:PpvCanvasPathCommand;
begin
 Reset;
 InitializeCurveTessellationTolerance(aState,aCanvas);
 for CommandIndex:=0 to aPath.fCountCommands-1 do begin
  Command:=@aPath.fCommands[CommandIndex];
  case Command^.CommandType of
   TpvCanvasPathCommandType.MoveTo:begin
    StrokeMoveTo(Command.Points[0]);
   end;
   TpvCanvasPathCommandType.LineTo:begin
    StrokeLineTo(Command.Points[0]);
   end;
   TpvCanvasPathCommandType.QuadraticCurveTo:begin
    StrokeQuadraticCurveTo(Command.Points[0],Command.Points[1]);
   end;
   TpvCanvasPathCommandType.CubicCurveTo:begin
    StrokeCubicCurveTo(Command.Points[0],Command.Points[1],Command.Points[2]);
   end;
   TpvCanvasPathCommandType.ArcTo:begin
    StrokeArcTo(Command.Points[0],Command.Points[1],Command.Points[2].x);
   end;
   TpvCanvasPathCommandType.Close:begin
    StrokeClose;
   end;
  end;
 end;
 StrokeFlush;
end;

function TpvCanvasShapeCacheYCoordinateCompare(const a,b:TpvCanvasShapeCacheSegmentScalar):TpvInt32;
begin
 result:=Sign(a-b);
end;

procedure TpvCanvasShape.FillFromPath(const aPath:TpvCanvasPath;const aState:TpvCanvasState;const aCanvas:TpvCanvas=nil);
var CommandIndex,LastLinePoint:TpvInt32;
    Command:PpvCanvasPathCommand;
    StartPoint,LastPoint:TpvVector2;
 procedure InitializeSegmentUniquePointHashTable;
 begin
  if length(fCacheSegmentUniquePointHashTable)<pvCanvasShapeCacheSegmentUniquePointHashSize then begin
   SetLength(fCacheSegmentUniquePointHashTable,pvCanvasShapeCacheSegmentUniquePointHashSize);
  end;
  FillChar(fCacheSegmentUniquePointHashTable[0],pvCanvasShapeCacheSegmentUniquePointHashSize*SizeOf(TpvInt32),$ff);
  fCountCacheSegmentUniquePoints:=0;
 end;
 function GetSegmentPointHash(const aPoint:TpvCanvasShapeCacheSegmentPoint):TpvUInt32;
 begin
  result:=trunc(floor((aPoint.x*256)+0.5)*73856093) xor trunc(floor((aPoint.y*256)+0.5)*19349653);
 end;
 function AddSegmentPoint(const aPoint:TpvCanvasShapeCacheSegmentPoint):TpvInt32; overload;
 var Hash,HashBucket:TpvUInt32;
     UniquePoint:PpvCanvasShapeCacheSegmentUniquePoint;
 begin
  Hash:=GetSegmentPointHash(aPoint);
  HashBucket:=Hash and pvCanvasShapeCacheSegmentUniquePointHashMask;
  result:=fCacheSegmentUniquePointHashTable[HashBucket];
  while result>=0 do begin
   UniquePoint:=@fCacheSegmentUniquePoints[result];
   if (UniquePoint^.Hash=Hash) and
      SameValue(UniquePoint^.Point.x,aPoint.x) and
      SameValue(UniquePoint^.Point.y,aPoint.y) then begin
    break;
   end else begin
    result:=UniquePoint^.HashNext;
   end;
  end;
  if result<0 then begin
   result:=fCountCacheSegmentUniquePoints;
   inc(fCountCacheSegmentUniquePoints);
   if length(fCacheSegmentUniquePoints)<fCountCacheSegmentUniquePoints then begin
    SetLength(fCacheSegmentUniquePoints,fCountCacheSegmentUniquePoints*2);
   end;
   UniquePoint:=@fCacheSegmentUniquePoints[result];
   UniquePoint^.HashNext:=fCacheSegmentUniquePointHashTable[HashBucket];
   fCacheSegmentUniquePointHashTable[HashBucket]:=result;
   UniquePoint^.Hash:=Hash;
   UniquePoint^.Point:=aPoint;
  end;
 end;
 function AddSegmentPoint(const aPoint:TpvVector2):TpvInt32; overload;
 var p:TpvCanvasShapeCacheSegmentPoint;
 begin
  p.x:=aPoint.x;
  p.y:=aPoint.y;
  result:=AddSegmentPoint(p);
 end;
 procedure UpdateSegmentBoundingBox(var Segment:TpvCanvasShapeCacheSegment);
 var p0,p1:PpvCanvasShapeCacheSegmentPoint;
 begin
  p0:=@fCacheSegmentUniquePoints[Segment.Points[0]].Point;
  p1:=@fCacheSegmentUniquePoints[Segment.Points[1]].Point;
  Segment.AABBMin.x:=Min(p0^.x,p1^.x);
  Segment.AABBMin.y:=Min(p0^.y,p1^.y);
  Segment.AABBMax.x:=Max(p0^.x,p1^.x);
  Segment.AABBMax.y:=Max(p0^.y,p1^.y);
 end;
 procedure AddSegment(const aP0,aP1:TpvInt32); overload;
 var Index:TpvInt32;
     ShapeCacheSegment:PpvCanvasShapeCacheSegment;
 begin
  if aP0<>aP1 then begin
   Index:=fCountCacheSegments;
   inc(fCountCacheSegments);
   if length(fCacheSegments)<fCountCacheSegments then begin
    SetLength(fCacheSegments,fCountCacheSegments*2);
   end;
   ShapeCacheSegment:=@fCacheSegments[Index];
   ShapeCacheSegment^.Points[0]:=aP0;
   ShapeCacheSegment^.Points[1]:=aP1;
   UpdateSegmentBoundingBox(ShapeCacheSegment^);
   if fCacheFirstSegment<0 then begin
    fCacheFirstSegment:=Index;
    ShapeCacheSegment^.Previous:=-1;
   end else begin
    fCacheSegments[fCacheLastSegment].Next:=Index;
    ShapeCacheSegment^.Previous:=fCacheLastSegment;
   end;
   ShapeCacheSegment^.Next:=-1;
   fCacheLastSegment:=Index;
  end;
 end;
 procedure AddSegment(const aP0,aP1:TpvCanvasShapeCacheSegmentPoint); overload;
 begin
  if (aP0.x<>aP1.x) or (aP0.y<>aP1.y) then begin
   AddSegment(AddSegmentPoint(aP0),AddSegmentPoint(aP1));
  end;
 end;
 procedure RemoveSegment(const aSegmentIndex:TpvInt32);
 var PreviousSegmentIndex,NextSegmentIndex:TpvInt32;
 begin
  PreviousSegmentIndex:=fCacheSegments[aSegmentIndex].Previous;
  NextSegmentIndex:=fCacheSegments[aSegmentIndex].Next;
  if PreviousSegmentIndex>=0 then begin
   fCacheSegments[PreviousSegmentIndex].Next:=NextSegmentIndex;
  end else if fCacheFirstSegment=aSegmentIndex then begin
   fCacheFirstSegment:=NextSegmentIndex;
  end;
  if NextSegmentIndex>=0 then begin
   fCacheSegments[NextSegmentIndex].Previous:=PreviousSegmentIndex;
  end else if fCacheLastSegment=aSegmentIndex then begin
   fCacheLastSegment:=PreviousSegmentIndex;
  end;
  fCacheSegments[aSegmentIndex].Previous:=-1;
  fCacheSegments[aSegmentIndex].Next:=-1;
 end;
 procedure FillMoveTo(const aP0:TpvVector2);
 var Index:TpvInt32;
     LinePoint:PpvCanvasShapeCacheLinePoint;
 begin
  Index:=fCountCacheLinePoints;
  inc(fCountCacheLinePoints);
  if length(fCacheLinePoints)<fCountCacheLinePoints then begin
   SetLength(fCacheLinePoints,fCountCacheLinePoints*2);
  end;
  LinePoint:=@fCacheLinePoints[Index];
  LinePoint^.Last:=-1;
  LinePoint^.Position:=aP0;
  LastLinePoint:=Index;
  StartPoint:=aP0;
  LastPoint:=aP0;
 end;
 procedure FillLineTo(const aP0:TpvVector2);
 var Index:TpvInt32;
     LinePoint:PpvCanvasShapeCacheLinePoint;
 begin
  if LastPoint<>aP0 then begin
   Index:=fCountCacheLinePoints;
   inc(fCountCacheLinePoints);
   if length(fCacheLinePoints)<fCountCacheLinePoints then begin
    SetLength(fCacheLinePoints,fCountCacheLinePoints*2);
   end;
   LinePoint:=@fCacheLinePoints[Index];
   LinePoint^.Last:=LastLinePoint;
   LinePoint^.Position:=aP0;
   LastLinePoint:=Index;
   AddSegment(AddSegmentPoint(LastPoint),AddSegmentPoint(aP0));
  end;
  LastPoint:=aP0;
 end;
 procedure FillQuadraticCurveTo(const aC0,aA0:TpvVector2);
  procedure Recursive(const x1,y1,x2,y2,x3,y3:TpvFloat;const Level:TpvInt32);
  var x12,y12,x23,y23,x123,y123,dx,dy:TpvFloat;
      Point:TpvVector2;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   dx:=x3-x1;
   dy:=y3-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(((x2-x3)*dy)-((y2-y3)*dx))<((sqr(dx)+sqr(dy))*fCurveTessellationToleranceSquared))) then begin
    Point.x:=x123;
    Point.y:=y123;
    FillLineTo(Point);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,level+1);
    Recursive(x123,y123,x23,y23,x3,y3,level+1);
   end;
  end;
 begin
  Recursive(LastPoint.x,LastPoint.y,aC0.x,aC0.y,aA0.x,aA0.y,0);
  FillLineTo(aA0);
 end;
 procedure FillCubicCurveTo(const aC0,aC1,aA0:TpvVector2);
  procedure Recursive(const x1,y1,x2,y2,x3,y3,x4,y4:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234,dx,dy:TpvDouble;
      Point:TpvVector2;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x34:=(x3+x4)*0.5;
   y34:=(y3+y4)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   x234:=(x23+x34)*0.5;
   y234:=(y23+y34)*0.5;
   x1234:=(x123+x234)*0.5;
   y1234:=(y123+y234)*0.5;
   dx:=x4-x1;
   dy:=y4-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(abs(((x2-x4)*dy)-((y2-y4)*dx))+
            abs(((x3-x4)*dy)-((y3-y4)*dx)))<((sqr(dx)+sqr(dy))*fCurveTessellationToleranceSquared))) then begin
    Point.x:=x4;
    Point.y:=y4;
    FillLineTo(Point);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,x1234,y1234,Level+1);
    Recursive(x1234,y1234,x234,y234,x34,y34,x4,y4,Level+1);
   end;
  end;
 begin
  Recursive(LastPoint.x,LastPoint.y,aC0.x,aC0.y,aC1.x,aC1.y,aA0.x,aA0.y,0);
  FillLineTo(aA0);
 end;
 procedure FillArcTo(const aP1,aP2:TpvVector2;const aRadius:TpvFloat);
 const CCW=0;
       CW=1;
 var Direction,CountSubdivisions,SubdivisionIndex:TpvInt32;
     p0,d01,d21,Center,Normal,Tangent,Current,Previous,PreviousTangent:TpvVector2;
     d,Angle0,Angle1,AngleDifference,PartAngleDifference,Kappa:TpvFloat;
 begin
  if (aP1=aP2) or IsZero(aRadius) then begin
   FillLineTo(aP1);
  end else begin
   p0:=LastPoint;
   d01:=(p0-aP1).Normalize;
   d21:=(aP2-aP1).Normalize;
   d:=aRadius/tan(ArcCos(d01.Dot(d21))*0.5);
   if d>1e+4 then begin
    FillLineTo(aP1);
   end else begin
    if ((d01.y*d21.x)-(d01.x*d21.y))>0.0 then begin
     Center:=aP1+TpvVector2.InlineableCreate((d01.x*d)+(d01.y*aRadius),(d01.y*d)-(d01.x*aRadius));
     Angle0:=ArcTan2(d01.x,-d01.y);
     Angle1:=ArcTan2(-d21.x,d21.y);
     Direction:=CW;
    end else begin
     Center:=aP1+TpvVector2.InlineableCreate((d01.x*d)-(d01.y*aRadius),(d01.y*d)+(d01.x*aRadius));
     Angle0:=ArcTan2(-d01.x,d01.y);
     Angle1:=ArcTan2(d21.x,-d21.y);
     Direction:=CCW;
    end;
    AngleDifference:=Angle1-Angle0;
    if Direction=CW then begin
     if abs(AngleDifference)>=TwoPI then begin
      AngleDifference:=TwoPI;
     end else begin
      while AngleDifference<0.0 do begin
       AngleDifference:=AngleDifference+TwoPI;
      end;
     end;
    end else begin
     if abs(AngleDifference)>=TwoPI then begin
      AngleDifference:=-TwoPI;
     end else begin
      while AngleDifference>0.0 do begin
       AngleDifference:=AngleDifference-TwoPI;
      end;
     end;
    end;
    CountSubdivisions:=Min(Max(round(abs(AngleDifference)/HalfPI),1),5);
    PartAngleDifference:=AngleDifference/CountSubdivisions;
    Kappa:=abs((4.0/3.0)*(1.0-cos(PartAngleDifference))/sin(PartAngleDifference))*IfThen(Direction=CCW,-1,1);
    Previous:=TpvVector2.Null;
    PreviousTangent:=TpvVector2.Null;
    for SubdivisionIndex:=0 to CountSubdivisions-1 do begin
     SinCos(Mix(Angle0,Angle1,SubdivisionIndex/CountSubdivisions),Normal.y,Normal.x);
     Current:=Center+(Normal*aRadius);
     Tangent:=TpvVector2.InlineableCreate(-Normal.y,Normal.x)*aRadius*Kappa;
     if SubdivisionIndex=0 then begin
      FillLineTo(Current);
     end else begin
      FillCubicCurveTo(Previous+PreviousTangent,Current-Tangent,Current);
     end;
     Previous:=Current;
     PreviousTangent:=Tangent;
    end;
   end;
  end;
 end;
 procedure FillClose;
 begin
  if (fCountCacheLinePoints>0) or (fCountCacheSegments>0) then begin
   FillLineTo(StartPoint);
  end;
 end;
 procedure FillFlush;
  procedure SortLinkedListSegments;
   function CompareSegments(const a,b:TpvCanvasShapeCacheSegment):TpvInt32;
   begin
    result:=Sign(a.AABBMin.y-b.AABBMin.y);
    if result=0 then begin
     result:=Sign(a.AABBMin.x-b.AABBMin.x);
     if result=0 then begin
      result:=Sign(a.AABBMax.x-b.AABBMax.x);
      if result=0 then begin
       result:=Sign(a.AABBMax.y-b.AABBMax.y);
      end;
     end;
    end;
   end;
  var PartA,PartB,CurrentSegment,InSize,PartASize,PartBSize,Merges:TpvInt32;
  begin
   // Sort for from top to bottom and from left to right
   if fCacheFirstSegment>=0 then begin
    InSize:=1;
    repeat
     PartA:=fCacheFirstSegment;
     fCacheFirstSegment:=-1;
     fCacheLastSegment:=-1;
     Merges:=0;
     while PartA>=0 do begin
      inc(Merges);
      PartB:=PartA;
      PartASize:=0;
      while PartASize<InSize do begin
       inc(PartASize);
       PartB:=fCacheSegments[PartB].Next;
       if PartB<0 then begin
        break;
       end;
      end;
      PartBSize:=InSize;
      while (PartASize>0) or ((PartBSize>0) and (PartB>=0)) do begin
       if (PartASize<>0) and
          ((PartBSize=0) or
           (PartB<0) or
           (CompareSegments(fCacheSegments[PartA],fCacheSegments[PartB])<=0)) then begin
        CurrentSegment:=PartA;
        PartA:=fCacheSegments[PartA].Next;
        dec(PartASize);
       end else begin
        CurrentSegment:=PartB;
        PartB:=fCacheSegments[PartB].Next;
        dec(PartBSize);
       end;
       if fCacheLastSegment>=0 then begin
        fCacheSegments[fCacheLastSegment].Next:=CurrentSegment;
       end else begin
        fCacheFirstSegment:=CurrentSegment;
       end;
       fCacheSegments[CurrentSegment].Previous:=fCacheLastSegment;
       fCacheLastSegment:=CurrentSegment;
      end;
      PartA:=PartB;
     end;
     fCacheSegments[fCacheLastSegment].Next:=-1;
     if Merges<=1 then begin
      break;
     end;
     inc(InSize,InSize);
    until false;
   end;
  end;
  procedure SweepAndSplitSegmentsAtIntersections;
  const EPSILON=1e-8;
        InvEPSILON=1.0-EPSILON;
        Threshold=1e-4;
  var UntilIncludingSegmentIndex,SegmentAIndex,SegmentBIndex,TryIndex,Intersections,
      IntersectionPointIndex:TpvInt32;
      SegmentA,SegmentB:PpvCanvasShapeCacheSegment;
      IntersectionPoint:TpvCanvasShapeCacheSegmentPoint;
      TryAgain:boolean;
      a0,a1,b0,b1:PpvCanvasShapeCacheSegmentPoint;
      a10x,a10y,b10x,b10y,ab0x,ab0y,Determinant,ai,bi,aiInv:TpvCanvasShapeCacheSegmentScalar;
  begin
   repeat
    TryAgain:=false;
    UntilIncludingSegmentIndex:=fCacheLastSegment;
    SegmentAIndex:=fCacheFirstSegment;
    while SegmentAIndex>=0 do begin
     SegmentBIndex:=fCacheSegments[SegmentAIndex].Next;
     while SegmentBIndex>=0 do begin
      SegmentA:=@fCacheSegments[SegmentAIndex];
      SegmentB:=@fCacheSegments[SegmentBIndex];
      if SegmentB^.AABBMin.y<=SegmentA^.AABBMax.y then begin
       if (SegmentA^.AABBMin.x<=SegmentB^.AABBMax.x) and
           (SegmentB^.AABBMin.x<=SegmentA^.AABBMax.x) then begin
        Intersections:=0;
        a0:=@fCacheSegmentUniquePoints[SegmentA^.Points[0]].Point;
        a1:=@fCacheSegmentUniquePoints[SegmentA^.Points[1]].Point;
        b0:=@fCacheSegmentUniquePoints[SegmentB^.Points[0]].Point;
        b1:=@fCacheSegmentUniquePoints[SegmentB^.Points[1]].Point;
        a10x:=a1^.x-a0^.x;
        a10y:=a1^.y-a0^.y;
        b10x:=b1^.x-b0^.x;
        b10y:=b1^.y-b0^.y;
        Determinant:=(a10x*b10y)-(b10x*a10y);
        if not IsZero(Determinant) then begin
         ab0x:=a0^.x-b0^.x;
         ab0y:=a0^.y-b0^.y;
         ai:=((b10x*ab0y)-(b10y*ab0x))/Determinant;
         if (ai>=0.0) and (ai<=1.0) then begin
          bi:=((a10x*ab0y)-(a10y*ab0x))/Determinant;
          if (bi>=0.0) and (bi<=1.0) then begin
           aiInv:=1.0-ai;
           IntersectionPoint.x:=(a0^.x*aiInv)+(a1^.x*ai);
           IntersectionPoint.y:=(a0^.y*aiInv)+(a1^.y*ai);
           if ((ai>EPSILON) and (ai<InvEPSILON)) and not
              ((SameValue(ai,0.0) or SameValue(ai,1.0)) or
               (SameValue(IntersectionPoint.x,a0^.x) and SameValue(IntersectionPoint.y,a0^.y)) or
               (SameValue(IntersectionPoint.x,a1^.x) and SameValue(IntersectionPoint.y,a1^.y))) then begin
            Intersections:=Intersections or 1;
           end;
           if ((bi>EPSILON) and (bi<InvEPSILON)) and not
              ((SameValue(bi,0.0) or SameValue(bi,1.0)) or
               (SameValue(IntersectionPoint.x,b0^.x) and SameValue(IntersectionPoint.y,b0^.y)) or
               (SameValue(IntersectionPoint.x,b1^.x) and SameValue(IntersectionPoint.y,b1^.y))) then begin
            Intersections:=Intersections or 2;
           end;
          end;
         end;
        end;
        if (Intersections and (1 or 2))<>0 then begin
         IntersectionPointIndex:=AddSegmentPoint(IntersectionPoint);
         if (Intersections and 1)<>0 then begin
          AddSegment(IntersectionPointIndex,fCacheSegments[SegmentAIndex].Points[1]);
          fCacheSegments[SegmentAIndex].Points[1]:=IntersectionPointIndex;
          UpdateSegmentBoundingBox(fCacheSegments[SegmentAIndex]);
         end;
         if (Intersections and 2)<>0 then begin
          AddSegment(IntersectionPointIndex,fCacheSegments[SegmentBIndex].Points[1]);
          fCacheSegments[SegmentBIndex].Points[1]:=IntersectionPointIndex;
          UpdateSegmentBoundingBox(fCacheSegments[SegmentBIndex]);
         end;
         TryAgain:=true;
        end;
       end;
      end else begin
       break;
      end;
      if SegmentBIndex=UntilIncludingSegmentIndex then begin
       break;
      end else begin
       SegmentBIndex:=fCacheSegments[SegmentBIndex].Next;
      end;
     end;
     if SegmentAIndex=UntilIncludingSegmentIndex then begin
      break;
     end else begin
      SegmentAIndex:=fCacheSegments[SegmentAIndex].Next;
     end;
    end;
    if TryAgain then begin
     SortLinkedListSegments;
    end else begin
     break;
    end;
   until false;
  end;
  procedure CollectYCoordinates;
  var YCoordinateIndex,LocalCountCacheYCoordinates,PointIndex:TpvInt32;
      CurrentY:TpvCanvasShapeCacheSegmentScalar;
      Points:array[0..1] of PpvCanvasShapeCacheSegmentPoint;
  begin
   LocalCountCacheYCoordinates:=fCountCacheSegmentUniquePoints;
   if length(fCacheYCoordinates)<LocalCountCacheYCoordinates then begin
    SetLength(fCacheYCoordinates,LocalCountCacheYCoordinates*2);
    SetLength(fCacheTemporaryYCoordinates,LocalCountCacheYCoordinates*2);
   end;
   for PointIndex:=0 to fCountCacheSegmentUniquePoints-1 do begin
    fCacheTemporaryYCoordinates[PointIndex]:=fCacheSegmentUniquePoints[PointIndex].Point.y;
   end;
   if LocalCountCacheYCoordinates>1 then begin
    TpvTypedSort<TpvCanvasShapeCacheSegmentScalar>.IntroSort(@fCacheTemporaryYCoordinates[0],0,LocalCountCacheYCoordinates-1,TpvCanvasShapeCacheYCoordinateCompare);
   end;
   fCountCacheYCoordinates:=0;
   YCoordinateIndex:=0;
   while YCoordinateIndex<LocalCountCacheYCoordinates do begin
    CurrentY:=fCacheTemporaryYCoordinates[YCoordinateIndex];
    inc(YCoordinateIndex);
    while (YCoordinateIndex<LocalCountCacheYCoordinates) and
          SameValue(fCacheTemporaryYCoordinates[YCoordinateIndex],CurrentY) do begin
     inc(YCoordinateIndex);
    end;
    fCacheYCoordinates[fCountCacheYCoordinates]:=CurrentY;
    inc(fCountCacheYCoordinates);
   end;
  end;
  procedure SweepAndSplitSegmentsAtYCoordinates;
  var UntilIncludingSegmentIndex,CurrentSegmentIndex,NextSegmentIndex,
      StartYCoordinateIndex,CurrentYCoordinateIndex,
      TopPointIndex,BottomPointIndex,LastPointIndex,NewPointIndex:TpvInt32;
      TopPoint,BottomPoint,LastPoint,NewPoint:TpvCanvasShapeCacheSegmentPoint;
      CurrentYCoordinate,IntersectionTime:TpvCanvasShapeCacheSegmentScalar;
      Swapped,NeedSort:boolean;
      p0,p1:PpvCanvasShapeCacheSegmentPoint;
  begin
   NeedSort:=false;
   UntilIncludingSegmentIndex:=fCacheLastSegment;
   StartYCoordinateIndex:=0;
   CurrentSegmentIndex:=fCacheFirstSegment;
   while CurrentSegmentIndex>=0 do begin
    NextSegmentIndex:=fCacheSegments[CurrentSegmentIndex].Next;
    p0:=@fCacheSegmentUniquePoints[fCacheSegments[CurrentSegmentIndex].Points[0]].Point;
    p1:=@fCacheSegmentUniquePoints[fCacheSegments[CurrentSegmentIndex].Points[1]].Point;
    Swapped:=p0^.y>p1^.y;
    if Swapped then begin
     TopPoint:=p1^;
     BottomPoint:=p0^;
     TopPointIndex:=fCacheSegments[CurrentSegmentIndex].Points[1];
     BottomPointIndex:=fCacheSegments[CurrentSegmentIndex].Points[0];
    end else begin
     TopPoint:=p0^;
     BottomPoint:=p1^;
     TopPointIndex:=fCacheSegments[CurrentSegmentIndex].Points[0];
     BottomPointIndex:=fCacheSegments[CurrentSegmentIndex].Points[1];
    end;
    if TopPoint.y<BottomPoint.y then begin
     while ((StartYCoordinateIndex+1)<fCountCacheYCoordinates) and (TopPoint.y>fCacheYCoordinates[StartYCoordinateIndex]) do begin
      inc(StartYCoordinateIndex);
     end;
     LastPoint:=TopPoint;
     LastPointIndex:=TopPointIndex;
     for CurrentYCoordinateIndex:=StartYCoordinateIndex to fCountCacheYCoordinates-1 do begin
      CurrentYCoordinate:=fCacheYCoordinates[CurrentYCoordinateIndex];
      if CurrentYCoordinate<BottomPoint.y then begin
       if (TopPoint.y<CurrentYCoordinate) and not
          (SameValue(TopPoint.y,CurrentYCoordinate) or
           SameValue(BottomPoint.y,CurrentYCoordinate) or
           SameValue(LastPoint.y,CurrentYCoordinate)) then begin
        IntersectionTime:=(CurrentYCoordinate-TopPoint.y)/(BottomPoint.y-TopPoint.y);
        if (IntersectionTime>0.0) and (IntersectionTime<1.0) then begin
         NewPoint.x:=(TopPoint.x*(1.0-IntersectionTime))+(BottomPoint.x*IntersectionTime);
         NewPoint.y:=CurrentYCoordinate;
         NewPointIndex:=AddSegmentPoint(NewPoint);
         if Swapped then begin
          AddSegment(NewPointIndex,LastPointIndex);
         end else begin
          AddSegment(LastPointIndex,NewPointIndex);
         end;
         LastPoint:=NewPoint;
         LastPointIndex:=NewPointIndex;
         NeedSort:=true;
        end;
       end;
      end else begin
       break;
      end;
     end;
     if LastPoint.y<BottomPoint.y then begin
      if LastPointIndex<>TopPointIndex then begin
       if Swapped then begin
        fCacheSegments[CurrentSegmentIndex].Points[0]:=BottomPointIndex;
        fCacheSegments[CurrentSegmentIndex].Points[1]:=LastPointIndex;
       end else begin
        fCacheSegments[CurrentSegmentIndex].Points[0]:=LastPointIndex;
        fCacheSegments[CurrentSegmentIndex].Points[1]:=BottomPointIndex;
       end;
       UpdateSegmentBoundingBox(fCacheSegments[CurrentSegmentIndex]);
      end;
     end else begin
      RemoveSegment(CurrentSegmentIndex);
     end;
    end else begin
     RemoveSegment(CurrentSegmentIndex);
    end;
    if CurrentSegmentIndex=UntilIncludingSegmentIndex then begin
     break;
    end else begin
     CurrentSegmentIndex:=NextSegmentIndex;
    end;
   end;
   if NeedSort then begin
    SortLinkedListSegments;
   end;
  end;
  procedure SweepAndGenerateTriangles;
  var CurrentYSegmentIndex,LastYCoordinateIndex,CurrentYCoordinateIndex,
      CurrentSegmentIndex,LastSegmentIndex,Winding,i0,i1,i2,i3:TpvInt32;
      CurrentSegment,LastSegment:PpvCanvasShapeCacheSegment;
      Visible:boolean;
      FromY,ToY:TpvCanvasShapeCacheSegmentScalar;
      a0,a1,b0,b1:PpvCanvasShapeCacheSegmentPoint;
  begin
   CurrentYSegmentIndex:=fCacheFirstSegment;
   LastYCoordinateIndex:=-1;
   CurrentYCoordinateIndex:=0;
   while CurrentYCoordinateIndex<fCountCacheYCoordinates do begin
    if LastYCoordinateIndex>=0 then begin
     while (CurrentYSegmentIndex>=0) and
           (fCacheSegments[CurrentYSegmentIndex].AABBMin.Y<fCacheYCoordinates[LastYCoordinateIndex]) do begin
      CurrentYSegmentIndex:=fCacheSegments[CurrentYSegmentIndex].Next;
     end;
     FromY:=fCacheYCoordinates[LastYCoordinateIndex];
     ToY:=fCacheYCoordinates[CurrentYCoordinateIndex];
     CurrentSegmentIndex:=CurrentYSegmentIndex;
     Winding:=0;
     LastSegmentIndex:=-1;
     while (CurrentSegmentIndex>=0) and
           (fCacheSegments[CurrentSegmentIndex].AABBMin.Y<ToY) do begin
      if (fCacheSegments[CurrentSegmentIndex].AABBMin.y<fCacheSegments[CurrentSegmentIndex].AABBMax.y) and
         ((fCacheSegments[CurrentSegmentIndex].AABBMin.y<ToY) and
          (FromY<fCacheSegments[CurrentSegmentIndex].AABBMax.y)) then begin
       if LastSegmentIndex>=0 then begin
        a0:=@fCacheSegmentUniquePoints[fCacheSegments[LastSegmentIndex].Points[0]].Point;
        a1:=@fCacheSegmentUniquePoints[fCacheSegments[LastSegmentIndex].Points[1]].Point;
        b0:=@fCacheSegmentUniquePoints[fCacheSegments[CurrentSegmentIndex].Points[0]].Point;
        b1:=@fCacheSegmentUniquePoints[fCacheSegments[CurrentSegmentIndex].Points[1]].Point;
        if a0^.y<=a1^.y then begin
         inc(Winding);
        end else begin
         dec(Winding);
        end;
        case aState.fFillRule of
         TpvCanvasFillRule.NonZero:begin
          Visible:=Winding<>0;
         end;
         else {TpvCanvasFillRule.EvenOdd:}begin
          Visible:=(Winding and 1)<>0;
         end;
        end;
        if Visible then begin
         LastSegment:=@fCacheSegments[LastSegmentIndex];
         CurrentSegment:=@fCacheSegments[CurrentSegmentIndex];
         BeginPart(4,6);
         if a0^.y<a1^.y then begin
          i0:=AddVertex(TpvVector2.InlineableCreate(a0^.x,a0^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
          i1:=AddVertex(TpvVector2.InlineableCreate(a1^.x,a1^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
         end else begin
          i0:=AddVertex(TpvVector2.InlineableCreate(a1^.x,a1^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
          i1:=AddVertex(TpvVector2.InlineableCreate(a0^.x,a0^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
         end;
         if b0^.y<b1^.y then begin
          i2:=AddVertex(TpvVector2.InlineableCreate(b1^.x,b1^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
          i3:=AddVertex(TpvVector2.InlineableCreate(b0^.x,b0^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
         end else begin
          i2:=AddVertex(TpvVector2.InlineableCreate(b0^.x,b0^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
          i3:=AddVertex(TpvVector2.InlineableCreate(b1^.x,b1^.y),0,TpvVector4.Null,TpvVector4.Null,TpvVector2.Null);
         end;
         AddIndex(i0);
         AddIndex(i1);
         AddIndex(i2);
         AddIndex(i2);
         AddIndex(i3);
         AddIndex(i0);
         EndPart;
        end;
       end;
       LastSegmentIndex:=CurrentSegmentIndex;
      end;
      CurrentSegmentIndex:=fCacheSegments[CurrentSegmentIndex].Next;
     end;
    end;
    LastYCoordinateIndex:=CurrentYCoordinateIndex;
    inc(CurrentYCoordinateIndex);
   end;
  end;
  procedure GenerateSegmentEdgeTriangles;
  var CurrentLinePointIndex,i0,i1,i2,i3:TpvInt32;
      LinePoint:PpvCanvasShapeCacheLinePoint;
      p0,p1,p10,n10,t10:TpvVector2;
      MetaInfo,MetaInfo2:TpvVector4;
  begin
   MetaInfo2:=TpvVector4.Null;
   for CurrentLinePointIndex:=0 to fCountCacheLinePoints-1 do begin
    LinePoint:=@fCacheLinePoints[CurrentLinePointIndex];
    if LinePoint^.Last>=0 then begin
     p0:=fCacheLinePoints[LinePoint^.Last].Position;
     p1:=LinePoint^.Position;
     p10:=p1-p0;
     n10:=p10.Normalize;
     t10:=n10.Perpendicular;
     MetaInfo.xy:=p0;
     MetaInfo.zw:=p1;
     BeginPart(4,6);
     p0:=p0-n10;
     p1:=p1+n10;
     i0:=AddVertex(p0-t10,pcvvaomRoundLine,MetaInfo,MetaInfo2,(-2.0)*(n10+t10));
     i1:=AddVertex(p0+t10,pcvvaomRoundLine,MetaInfo,MetaInfo2,2.0*(t10-n10));
     i2:=AddVertex(p1+t10,pcvvaomRoundLine,MetaInfo,MetaInfo2,2.0*(n10+t10));
     i3:=AddVertex(p1-t10,pcvvaomRoundLine,MetaInfo,MetaInfo2,2.0*(n10-t10));
     AddIndex(i0);
     AddIndex(i1);
     AddIndex(i2);
     AddIndex(i2);
     AddIndex(i3);
     AddIndex(i0);
     EndPart;
    end;
   end;
  end;
 begin
  try
   SortLinkedListSegments;
   SweepAndSplitSegmentsAtIntersections;
   CollectYCoordinates;
   SweepAndSplitSegmentsAtYCoordinates;
   SweepAndGenerateTriangles;
   GenerateSegmentEdgeTriangles;
  except
   on e:EpvCanvasShape do begin
   end;
   on e:Exception do begin
    raise;
   end;
  end;
 end;
begin
 Reset;
 InitializeCurveTessellationTolerance(aState,aCanvas);
 InitializeSegmentUniquePointHashTable;
 LastLinePoint:=-1;
 fCacheFirstSegment:=-1;
 fCacheLastSegment:=-1;
 for CommandIndex:=0 to aPath.fCountCommands-1 do begin
  Command:=@aPath.fCommands[CommandIndex];
  case Command^.CommandType of
   TpvCanvasPathCommandType.MoveTo:begin
    FillMoveTo(Command.Points[0]);
   end;
   TpvCanvasPathCommandType.LineTo:begin
    FillLineTo(Command.Points[0]);
   end;
   TpvCanvasPathCommandType.QuadraticCurveTo:begin
    FillQuadraticCurveTo(Command.Points[0],Command.Points[1]);
   end;
   TpvCanvasPathCommandType.CubicCurveTo:begin
    FillCubicCurveTo(Command.Points[0],Command.Points[1],Command.Points[2]);
   end;
   TpvCanvasPathCommandType.ArcTo:begin
    FillArcTo(Command.Points[0],Command.Points[1],Command.Points[2].x);
   end;
   TpvCanvasPathCommandType.Close:begin
    FillClose;
   end;
  end;
 end;
 FillFlush;
end;

constructor TpvCanvasVulkanDescriptor.Create(const aCanvas:TpvCanvas);
begin
 inherited Create;
 Value:=self;
 fCanvas:=aCanvas;
 fDescriptorPool:=nil;
 fDescriptorSet:=nil;
 fDescriptorTexture:=nil;
 fDescriptorMaskTexture:=nil;
end;

destructor TpvCanvasVulkanDescriptor.Destroy;
begin
 FreeAndNil(fDescriptorSet);
 FreeAndNil(fDescriptorPool);
 fDescriptorTexture:=nil;
 fDescriptorMaskTexture:=nil;
 inherited Destroy;
end;

constructor TpvCanvasCommon.Create(const aDevice:TpvVulkanDevice);
var Stream:TStream;
    UniversalQueue:TpvVulkanQueue;
    UniversalCommandPool:TpvVulkanCommandPool;
    UniversalCommandBuffer:TpvVulkanCommandBuffer;
    UniversalFence:TpvVulkanFence;
begin
 inherited Create;

 fDevice:=aDevice;

 fDevice.CanvasCommon:=self;

 fReferenceCounter:=0;

 UniversalQueue:=fDevice.UniversalQueue;
 try
  UniversalCommandPool:=TpvVulkanCommandPool.Create(fDevice,
                                                    fDevice.UniversalQueueFamilyIndex,
                                                    TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
  try
   UniversalCommandBuffer:=TpvVulkanCommandBuffer.Create(UniversalCommandPool,
                                                         VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   try
    UniversalFence:=TpvVulkanFence.Create(fDevice);
    try
     fDummyTexture:=TpvVulkanTexture.CreateDefault(aDevice,
                                                   UniversalQueue,
                                                   UniversalCommandBuffer,
                                                   UniversalFence,
                                                   UniversalQueue,
                                                   UniversalCommandBuffer,
                                                   UniversalFence,
                                                   TpvVulkanTextureDefaultType.Checkerboard,
                                                   16,
                                                   16,
                                                   0,
                                                   0,
                                                   1,
                                                   true,
                                                   true,
                                                   true,
                                                   false,
                                                   0,
                                                   [],
                                                   'TpvCanvas.DummyTexture');
     fDummyTexture.UpdateSampler;
    finally
     FreeAndNil(UniversalFence);
    end; 
   finally
    FreeAndNil(UniversalCommandBuffer);
   end;
  finally
   FreeAndNil(UniversalCommandPool);
  end;
 finally
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasVertexClipDistanceSPIRVData,CanvasVertexClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasVertexSPIRVData,CanvasVertexSPIRVDataSize);
 end;
 try
  fCanvasVertexShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasNoTextureVertexClipDistanceSPIRVData,CanvasNoTextureVertexClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasNoTextureVertexSPIRVData,CanvasNoTextureVertexSPIRVDataSize);
 end;
 try
  fCanvasVertexNoTextureShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureClipDistanceSPIRVData,CanvasFragmentGUINoTextureClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureSPIRVData,CanvasFragmentGUINoTextureSPIRVDataSize);
 end;
 try
  fCanvasFragmentGUINoTextureShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureClipDistanceSPIRVData,CanvasFragmentNoTextureClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureSPIRVData,CanvasFragmentNoTextureSPIRVDataSize);
 end;
 try
  fCanvasFragmentNoTextureShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureClipDistanceSPIRVData,CanvasFragmentTextureClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureSPIRVData,CanvasFragmentTextureSPIRVDataSize);
 end;
 try
  fCanvasFragmentTextureShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureClipDistanceSPIRVData,CanvasFragmentAtlasTextureClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureSPIRVData,CanvasFragmentAtlasTextureSPIRVDataSize);
 end;
 try
  fCanvasFragmentAtlasTextureShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathClipDistanceSPIRVData,CanvasFragmentVectorPathClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathSPIRVData,CanvasFragmentVectorPathSPIRVDataSize);
 end;
 try
  fCanvasFragmentVectorPathShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureNoBlendingClipDistanceSPIRVData,CanvasFragmentGUINoTextureNoBlendingClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureNoBlendingSPIRVData,CanvasFragmentGUINoTextureNoBlendingSPIRVDataSize);
 end;
 try
  fCanvasFragmentGUINoTextureNoBlendingShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureNoBlendingClipDistanceSPIRVData,CanvasFragmentNoTextureNoBlendingClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureNoBlendingSPIRVData,CanvasFragmentNoTextureNoBlendingSPIRVDataSize);
 end;
 try
  fCanvasFragmentNoTextureNoBlendingShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureNoBlendingClipDistanceSPIRVData,CanvasFragmentTextureNoBlendingClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureNoBlendingSPIRVData,CanvasFragmentTextureNoBlendingSPIRVDataSize);
 end;
 try
  fCanvasFragmentTextureNoBlendingShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureNoBlendingClipDistanceSPIRVData,CanvasFragmentAtlasTextureNoBlendingClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureNoBlendingSPIRVData,CanvasFragmentAtlasTextureNoBlendingSPIRVDataSize);
 end;
 try
  fCanvasFragmentAtlasTextureNoBlendingShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathNoBlendingClipDistanceSPIRVData,CanvasFragmentVectorPathNoBlendingClipDistanceSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathNoBlendingSPIRVData,CanvasFragmentVectorPathNoBlendingSPIRVDataSize);
 end;
 try
  fCanvasFragmentVectorPathNoBlendingShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureNoBlendingClipDistanceNoDiscardSPIRVData,CanvasFragmentGUINoTextureNoBlendingClipDistanceNoDiscardSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentGUINoTextureNoBlendingNoDiscardSPIRVData,CanvasFragmentGUINoTextureNoBlendingNoDiscardSPIRVDataSize);
 end;
 try
  fCanvasFragmentGUINoTextureNoBlendingNoDiscardShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureNoBlendingClipDistanceNoDiscardSPIRVData,CanvasFragmentNoTextureNoBlendingClipDistanceNoDiscardSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentNoTextureNoBlendingNoDiscardSPIRVData,CanvasFragmentNoTextureNoBlendingNoDiscardSPIRVDataSize);
 end;
 try
  fCanvasFragmentNoTextureNoBlendingNoDiscardShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureNoBlendingClipDistanceNoDiscardSPIRVData,CanvasFragmentTextureNoBlendingClipDistanceNoDiscardSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentTextureNoBlendingNoDiscardSPIRVData,CanvasFragmentTextureNoBlendingNoDiscardSPIRVDataSize);
 end;
 try
  fCanvasFragmentTextureNoBlendingNoDiscardShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureNoBlendingClipDistanceNoDiscardSPIRVData,CanvasFragmentAtlasTextureNoBlendingClipDistanceNoDiscardSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentAtlasTextureNoBlendingNoDiscardSPIRVData,CanvasFragmentAtlasTextureNoBlendingNoDiscardSPIRVDataSize);
 end;
 try
  fCanvasFragmentAtlasTextureNoBlendingNoDiscardShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 if aDevice.PhysicalDevice.Features.shaderClipDistance<>0 then begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathNoBlendingClipDistanceNoDiscardSPIRVData,CanvasFragmentVectorPathNoBlendingClipDistanceNoDiscardSPIRVDataSize);
 end else begin
  Stream:=TpvDataStream.Create(@CanvasFragmentVectorPathNoBlendingNoDiscardSPIRVData,CanvasFragmentVectorPathNoBlendingNoDiscardSPIRVDataSize);
 end;
 try
  fCanvasFragmentVectorPathNoBlendingNoDiscardShaderModule:=TpvVulkanShaderModule.Create(fDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineCanvasShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fCanvasVertexShaderModule,'main');

 fVulkanPipelineCanvasShaderStageVertexNoTexture:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fCanvasVertexNoTextureShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentGUINoTexture:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentGUINoTextureShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentNoTexture:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentNoTextureShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentTexture:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentTextureShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentAtlasTexture:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentAtlasTextureShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentVectorPath:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentVectorPathShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlending:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentGUINoTextureNoBlendingShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlending:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentNoTextureNoBlendingShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentTextureNoBlending:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentTextureNoBlendingShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlending:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentAtlasTextureNoBlendingShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlending:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentVectorPathNoBlendingShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlendingNoDiscard:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentGUINoTextureNoBlendingNoDiscardShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlendingNoDiscard:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentNoTextureNoBlendingNoDiscardShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentTextureNoBlendingNoDiscard:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentTextureNoBlendingNoDiscardShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlendingNoDiscard:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentAtlasTextureNoBlendingNoDiscardShaderModule,'main');

 fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlendingNoDiscard:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCanvasFragmentVectorPathNoBlendingNoDiscardShaderModule,'main');

end;

destructor TpvCanvasCommon.Destroy;
begin
 fDevice.CanvasCommon:=nil;
 FreeAndNil(fDummyTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageVertex);
 FreeAndNil(fVulkanPipelineCanvasShaderStageVertexNoTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentGUINoTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentNoTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentAtlasTexture);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentVectorPath);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlending);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlending);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentTextureNoBlending);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlending);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlending);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlendingNoDiscard);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlendingNoDiscard);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentTextureNoBlendingNoDiscard);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlendingNoDiscard);
 FreeAndNil(fVulkanPipelineCanvasShaderStageFragmentVectorPathNoBlendingNoDiscard);
 FreeAndNil(fCanvasVertexShaderModule);
 FreeAndNil(fCanvasVertexNoTextureShaderModule);
 FreeAndNil(fCanvasFragmentGUINoTextureShaderModule);
 FreeAndNil(fCanvasFragmentNoTextureShaderModule);
 FreeAndNil(fCanvasFragmentTextureShaderModule);
 FreeAndNil(fCanvasFragmentAtlasTextureShaderModule);
 FreeAndNil(fCanvasFragmentVectorPathShaderModule);
 FreeAndNil(fCanvasFragmentGUINoTextureNoBlendingShaderModule);
 FreeAndNil(fCanvasFragmentNoTextureNoBlendingShaderModule);
 FreeAndNil(fCanvasFragmentTextureNoBlendingShaderModule);
 FreeAndNil(fCanvasFragmentAtlasTextureNoBlendingShaderModule);
 FreeAndNil(fCanvasFragmentVectorPathNoBlendingShaderModule);
 FreeAndNil(fCanvasFragmentGUINoTextureNoBlendingNoDiscardShaderModule);
 FreeAndNil(fCanvasFragmentNoTextureNoBlendingNoDiscardShaderModule);
 FreeAndNil(fCanvasFragmentTextureNoBlendingNoDiscardShaderModule);
 FreeAndNil(fCanvasFragmentAtlasTextureNoBlendingNoDiscardShaderModule);
 FreeAndNil(fCanvasFragmentVectorPathNoBlendingNoDiscardShaderModule);
 inherited Destroy;
end;

class function TpvCanvasCommon.Acquire(const aDevice:TpvVulkanDevice):TpvCanvasCommon;
begin
 while TPasMPInterlocked.CompareExchange(fLock,-1,0)<>0 do begin
  TPasMP.Yield;
 end;
 try
  result:=TpvCanvasCommon(aDevice.CanvasCommon);
  if not assigned(result) then begin
   result:=TpvCanvasCommon.Create(aDevice);
  end;
  TPasMPInterlocked.Increment(result.fReferenceCounter);
 finally
  TPasMPInterlocked.Write(fLock,0);
 end;
end;

class procedure TpvCanvasCommon.Release(const aDevice:TpvVulkanDevice);
var CanvasCommon:TpvCanvasCommon;
begin
 while TPasMPInterlocked.CompareExchange(fLock,-1,0)<>0 do begin
  TPasMP.Yield;
 end;
 try
  if assigned(aDevice) then begin
   CanvasCommon:=TpvCanvasCommon(aDevice.CanvasCommon);
   if assigned(CanvasCommon) then begin
    if TPasMPInterlocked.Decrement(CanvasCommon.fReferenceCounter)=0 then begin
     CanvasCommon.Free;
    end;
   end;
  end;
 finally
  TPasMPInterlocked.Write(fLock,0);
 end;
end;

constructor TpvCanvasFont.Create;
begin
 inherited Create;
 fVulkanFontSpriteAtlas:=nil;
 fVulkanFont:=nil;
end;

constructor TpvCanvasFont.CreateFromTTF(const aFileName:String;const aDPI,aAtlasSize:TpvInt32;const aFirstCodePoint,aLastCodePoint:TpvUInt32);
var Stream:TStream;
    TrueTypeFont:TpvTrueTypeFont;
begin

 inherited Create;

 fVulkanFontSpriteAtlas:=TpvSpriteAtlas.Create(pvApplication.VulkanDevice,false,false);
 fVulkanFontSpriteAtlas.MipMaps:=false;
 fVulkanFontSpriteAtlas.UseConvexHullTrimming:=false;

 if pvApplication.Assets.ExistAsset(aFileName) then begin
  Stream:=pvApplication.Assets.GetAssetStream(aFileName);
  try
   TrueTypeFont:=TpvTrueTypeFont.Create(Stream,aDPI);
   try
    TrueTypeFont.Size:=aAtlasSize;
    TrueTypeFont.Hinting:=false;
    fVulkanFont:=TpvFont.CreateFromTrueTypeFont(fVulkanFontSpriteAtlas,
                                                TrueTypeFont,
                                                [TpvFontCodePointRange.Create(aFirstCodePoint,aLastCodePoint)],
                                                true,
                                                2,
                                                1,
                                                false,
                                                TpvSignedDistanceField2DVariant.SDF);
   finally
    TrueTypeFont.Free;
   end;
  finally
   Stream.Free;
  end;
 end else begin
  fVulkanFont:=nil;
 end;
end;

destructor TpvCanvasFont.Destroy;
begin
 if assigned(fVulkanFontSpriteAtlas) then begin
  FreeAndNil(fVulkanFont);
  FreeAndNil(fVulkanFontSpriteAtlas);
 end;
 inherited Destroy;
end;

constructor TpvCanvas.Create(const aDevice:TpvVulkanDevice;
                             const aPipelineCache:TpvVulkanPipelineCache;
                             const aCountProcessingBuffers:TpvInt32);
var Index,TextureModeIndex:TpvInt32;
    RenderingModeIndex:TpvCanvasRenderingMode;
    BlendingModeIndex:TpvCanvasBlendingMode;
    Stream:TStream;
begin
 inherited Create;

 fDevice:=aDevice;

 fCanvasCommon:=TpvCanvasCommon.Acquire(fDevice);

 fPipelineCache:=aPipelineCache;

 fCountBuffers:=0;

 fVulkanCanvasBuffers:=nil;

 fCountProcessingBuffers:=aCountProcessingBuffers;

 fShape:=TpvCanvasShape.Create;

 fState:=TpvCanvasState.Create;

 fStateStack:=TpvCanvasStateStack.Create(true);

 fState.Reset;

 fWidth:=1280;
 fHeight:=720;

 fViewPort.x:=0.0;
 fViewPort.y:=0.0;
 fViewPort.Width:=1280.0;
 fViewPort.Height:=720.0;
 fViewPort.minDepth:=0.0;
 fViewPort.maxDepth:=1.0;

 fPointerToViewport:=@fViewport;

 fVulkanDescriptorSetTextureLayout:=TpvVulkanDescriptorSetLayout.Create(fDevice);
 fVulkanDescriptorSetTextureLayout.AddBinding(0,
                                              VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                              []);
 fVulkanDescriptorSetTextureLayout.AddBinding(1,
                                              VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                              []);
 fVulkanDescriptorSetTextureLayout.Initialize;

 fVulkanDescriptorSetVectorPathLayout:=TpvVulkanDescriptorSetLayout.Create(fDevice);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(0,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(1,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(2,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(3,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(4,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.AddBinding(5,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
 fVulkanDescriptorSetVectorPathLayout.Initialize;

 fVulkanDescriptors:=TpvCanvasVulkanDescriptorLinkedListNode.Create;

 fCountVulkanDescriptors:=0;

 fVulkanTextureDescriptorSetHashMap:=TpvCanvasTextureDescriptorSetHashMap.Create(nil);

 fVulkanRenderPass:=nil;

 for BlendingModeIndex:=Low(TpvCanvasBlendingMode) to High(TpvCanvasBlendingMode) do begin
  for TextureModeIndex:=0 to 3 do begin
   fVulkanPipelineLayouts[BlendingModeIndex,TextureModeIndex]:=nil;
   fVulkanGraphicsPipelines[BlendingModeIndex,TextureModeIndex]:=nil;
  end;
 end;

 SetCountBuffers(1);

 fCurrentFrameNumber:=0;

end;

destructor TpvCanvas.Destroy;
var Index,SubIndex:TpvInt32;
    RenderingModeIndex:TpvCanvasRenderingMode;
    BlendingModeIndex:TpvCanvasBlendingMode;
    VulkanCanvasBuffer:PpvCanvasBuffer;
begin

 FreeAndNil(fStateStack);

 FreeAndNil(fState);

 FreeAndNil(fShape);

 SetCountBuffers(0);

 SetVulkanRenderPass(nil);

 while not fVulkanDescriptors.IsEmpty do begin
  fVulkanDescriptors.Front.Free;
 end;

 FreeAndNil(fVulkanDescriptors);

 FreeAndNil(fVulkanDescriptorSetVectorPathLayout);
 FreeAndNil(fVulkanDescriptorSetTextureLayout);

 FreeAndNil(fVulkanTextureDescriptorSetHashMap);

 fCurrentDestinationVertexBufferPointer:=nil;
 fCurrentDestinationIndexBufferPointer:=nil;

 fCanvasCommon:=nil;

 TpvCanvasCommon.Release(fDevice);

 inherited Destroy;
end;

procedure TpvCanvas.SetVulkanRenderPass(const aVulkanRenderPass:TpvVulkanRenderPass);
var TextureModeIndex:TpvInt32;
    BlendingModeIndex:TpvCanvasBlendingMode;
    VulkanPipelineLayout:TpvVulkanPipelineLayout;
    VulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
begin

 if fVulkanRenderPass<>aVulkanRenderPass then begin

  for BlendingModeIndex:=Low(TpvCanvasBlendingMode) to High(TpvCanvasBlendingMode) do begin
   for TextureModeIndex:=0 to 3 do begin
    FreeAndNil(fVulkanGraphicsPipelines[BlendingModeIndex,TextureModeIndex]);
    FreeAndNil(fVulkanPipelineLayouts[BlendingModeIndex,TextureModeIndex]);
   end;
  end;

  fVulkanRenderPass:=aVulkanRenderPass;

  if assigned(fVulkanRenderPass) then begin

   for BlendingModeIndex:=Low(TpvCanvasBlendingMode) to High(TpvCanvasBlendingMode) do begin

    for TextureModeIndex:=0 to 3 do begin

     VulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fDevice);
     fVulkanPipelineLayouts[BlendingModeIndex,TextureModeIndex]:=VulkanPipelineLayout;
     VulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetTextureLayout);
//   VulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetVectorPathLayout);
     VulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                               TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                               0,
                                               SizeOf(TpvCanvasPushConstants));
     VulkanPipelineLayout.Initialize;

     VulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fDevice,
                                                              fPipelineCache,
                                                              0,
                                                              [],
                                                              VulkanPipelineLayout,
                                                              fVulkanRenderPass,
                                                              0,
                                                              nil,
                                                              0);
     fVulkanGraphicsPipelines[BlendingModeIndex,TextureModeIndex]:=VulkanGraphicsPipeline;

     case TextureModeIndex of
      0:begin
       VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageVertexNoTexture);
      end;
      else begin
       VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageVertex);
      end;
     end;

     case BlendingModeIndex of
      TpvCanvasBlendingMode.None:begin
       case TextureModeIndex of
        1:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentTextureNoBlending);
        end;
        2:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlending);
        end;
        3:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlending);
        end;
        else begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlending);
        end;
       end;
      end;
      TpvCanvasBlendingMode.NoDiscard:begin
       case TextureModeIndex of
        1:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentTextureNoBlendingNoDiscard);
        end;
        2:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentAtlasTextureNoBlendingNoDiscard);
        end;
        3:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentGUINoTextureNoBlendingNoDiscard);
        end;
        else begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentNoTextureNoBlendingNoDiscard);
        end;
       end;
      end;
      else begin
       case TextureModeIndex of
        1:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentTexture);
        end;
        2:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentAtlasTexture);
        end;
        3:begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentGUINoTexture);
        end;
        else begin
         VulkanGraphicsPipeline.AddStage(fCanvasCommon.fVulkanPipelineCanvasShaderStageFragmentNoTexture);
        end;
       end;
      end;
     end;

     VulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
     VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

     VulkanGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TpvCanvasVertex),VK_VERTEX_INPUT_RATE_VERTEX);
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.OriginalPosition)));
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32B32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.Position)));
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R16G16B16A16_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.Color)));
     if TextureModeIndex<>0 then begin
      VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32G32B32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.TextureCoord)));
     end;
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(4,0,VK_FORMAT_R32_UINT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.State)));
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(5,0,VK_FORMAT_R32G32B32A32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.ClipRect)));
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(6,0,VK_FORMAT_R32G32B32A32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.MetaInfo)));
     VulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(7,0,VK_FORMAT_R32G32B32A32_SFLOAT,TpvPtrUInt(TpvPointer(@PpvCanvasVertex(nil)^.MetaInfo2)));

     VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fWidth,fHeight,0.0,1.0);
     VulkanGraphicsPipeline.ViewPortState.DynamicViewPorts:=true;

     VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fWidth,fHeight);
     VulkanGraphicsPipeline.ViewPortState.DynamicScissors:=true;

     VulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
     VulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
     VulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
     VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
     VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
     VulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
     VulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
     VulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
     VulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
     VulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

     VulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
     VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
     VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
     VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
     VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
     VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

     VulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
     VulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
     VulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
     VulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
     VulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
     VulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
     case BlendingModeIndex of
      TpvCanvasBlendingMode.None:begin
       VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
      end;
      TpvCanvasBlendingMode.AlphaBlending:begin
       VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                           VK_BLEND_FACTOR_SRC_ALPHA,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
      end;
      TpvCanvasBlendingMode.OnlyDepth:begin
       VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           0);
      end;
      else {TpvCanvasBlendingMode.AdditiveBlending:}begin
       VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           VK_BLEND_FACTOR_ONE,
                                                                           VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                           VK_BLEND_OP_ADD,
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                           TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
      end;
     end;
     VulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
     VulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true;//BlendingModeIndex in [TpvCanvasBlendingMode.None];
     if BlendingModeIndex=TpvCanvasBlendingMode.OnlyDepth then begin
      VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
     end else begin
      VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
     end;
     VulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
     VulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

     VulkanGraphicsPipeline.DynamicState.AddDynamicStates([VK_DYNAMIC_STATE_VIEWPORT,
                                                           VK_DYNAMIC_STATE_SCISSOR]);

     VulkanGraphicsPipeline.Initialize;

     VulkanGraphicsPipeline.FreeMemory;

    end;

   end;

  end;

 end;

end;

procedure TpvCanvas.SetCountBuffers(const aCountBuffers:TpvInt32);
var Index,SubIndex:TpvInt32;
    VulkanCanvasBuffer:PpvCanvasBuffer;
begin

 if fCountBuffers<>aCountBuffers then begin

  for Index:=aCountBuffers to fCountBuffers-1 do begin
   VulkanCanvasBuffer:=@fVulkanCanvasBuffers[Index];
   for SubIndex:=0 to VulkanCanvasBuffer^.fCountAllocatedBuffers-1 do begin
    FreeAndNil(VulkanCanvasBuffer^.fVulkanVertexBuffers[SubIndex]);
    FreeAndNil(VulkanCanvasBuffer^.fVulkanIndexBuffers[SubIndex]);
   end;
   VulkanCanvasBuffer^.fVulkanVertexBuffers:=nil;
   VulkanCanvasBuffer^.fVulkanIndexBuffers:=nil;
   VulkanCanvasBuffer^.fVertexBuffers:=nil;
   VulkanCanvasBuffer^.fVertexBufferSizes:=nil;
   VulkanCanvasBuffer^.fIndexBuffers:=nil;
   VulkanCanvasBuffer^.fIndexBufferSizes:=nil;
   VulkanCanvasBuffer^.fQueueItems:=nil;
   Finalize(VulkanCanvasBuffer^);
  end;

  if length(fVulkanCanvasBuffers)<aCountBuffers then begin
   SetLength(fVulkanCanvasBuffers,aCountBuffers*2);
  end;

  for Index:=fCountBuffers to aCountBuffers-1 do begin
   VulkanCanvasBuffer:=@fVulkanCanvasBuffers[Index];
   Initialize(VulkanCanvasBuffer^);
   VulkanCanvasBuffer^.fSpinLock:=0;
   VulkanCanvasBuffer^.fVulkanVertexBuffers:=nil;
   VulkanCanvasBuffer^.fVulkanIndexBuffers:=nil;
   VulkanCanvasBuffer^.fVertexBuffers:=nil;
   VulkanCanvasBuffer^.fVertexBufferSizes:=nil;
   VulkanCanvasBuffer^.fIndexBuffers:=nil;
   VulkanCanvasBuffer^.fIndexBufferSizes:=nil;
   VulkanCanvasBuffer^.fCountAllocatedBuffers:=0;
   VulkanCanvasBuffer^.fCountUsedBuffers:=0;
   VulkanCanvasBuffer^.fQueueItems:=nil;
   VulkanCanvasBuffer^.fCountQueueItems:=0;
  end;

  fCountBuffers:=aCountBuffers;

  fCurrentVulkanBufferIndex:=0;

  fCurrentVulkanVertexBufferOffset:=0;
  fCurrentVulkanIndexBufferOffset:=0;

  fCurrentCountVertices:=0;
  fCurrentCountIndices:=0;

  fCurrentDestinationVertexBufferPointer:=nil;
  fCurrentDestinationIndexBufferPointer:=nil;

  fCurrentFillBuffer:=nil;

 end;

end;

function TpvCanvas.GetTexture:TObject;
begin
 result:=fState.fTexture;
end;

procedure TpvCanvas.SetTexture(const aTexture:TObject);
begin
 if fState.fTexture<>aTexture then begin
  Flush;
  fState.fTexture:=aTexture;
 end;
end;

function TpvCanvas.GetAtlasTexture:TObject;
begin
 result:=fState.fAtlasTexture;
end;

procedure TpvCanvas.SetAtlasTexture(const aTexture:TObject);
begin
 if fState.fAtlasTexture<>aTexture then begin
  Flush;
  fState.fAtlasTexture:=aTexture;
 end;
end;

function TpvCanvas.GetMaskTexture:TObject;
begin
 result:=fState.fMaskTexture;
end;

procedure TpvCanvas.SetMaskTexture(const aTexture:TObject);
begin
 if fState.fMaskTexture<>aTexture then begin
  Flush;
  fState.fMaskTexture:=aTexture;
 end;
end;

function TpvCanvas.GetGUIElementMode:boolean;
begin
 result:=fState.fGUIElementMode;
end;

procedure TpvCanvas.SetGUIElementMode(const aGUIElementMode:boolean);
begin
 if fState.fGUIElementMode<>aGUIElementMode then begin
  Flush;
  fState.fGUIElementMode:=aGUIElementMode;
 end;
end;

procedure TpvCanvas.SetScissor(const aScissor:TVkRect2D);
begin
 if (fState.fScissor.offset.x<>aScissor.offset.x) or
    (fState.fScissor.offset.y<>aScissor.offset.y) or
    (fState.fScissor.extent.Width<>aScissor.extent.Width) or
    (fState.fScissor.extent.Height<>aScissor.extent.Height) then begin
  Flush;
  fState.fScissor:=aScissor;
 end;
end;

procedure TpvCanvas.SetScissor(const aLeft,aTop,aWidth,aHeight:TpvInt32);
var NewScissor:TVkRect2D;
begin
 NewScissor.offset.x:=aLeft;
 NewScissor.offset.y:=aTop;
 NewScissor.extent.Width:=aWidth;
 NewScissor.extent.Height:=aHeight;
 SetScissor(NewScissor);
end;

function TpvCanvas.GetClipRect:TpvRect;
begin
 result:=fState.fClipRect;
end;

procedure TpvCanvas.SetClipRect(const aClipRect:TVkRect2D);
begin
 fState.fClipRect.LeftTop:=TpvVector2.InlineableCreate(aClipRect.offset.x,aClipRect.offset.y);
 fState.fClipRect.RightBottom:=TpvVector2.InlineableCreate(aClipRect.offset.x+(aClipRect.extent.width+0.0),aClipRect.offset.y+(aClipRect.extent.height+0.0));
 fState.UpdateClipSpaceClipRect(self);
end;

procedure TpvCanvas.SetClipRect(const aClipRect:TpvRect);
begin
 fState.fClipRect:=aClipRect;
 fState.UpdateClipSpaceClipRect(self);
end;

procedure TpvCanvas.SetClipRect(const aLeft,aTop,aWidth,aHeight:TpvInt32);
begin
 fState.fClipRect.LeftTop:=TpvVector2.InlineableCreate(aLeft,aTop);
 fState.fClipRect.RightBottom:=TpvVector2.InlineableCreate(aLeft+aWidth,aTop+aHeight);
 fState.UpdateClipSpaceClipRect(self);
end;

function TpvCanvas.GetBlendingMode:TpvCanvasBlendingMode;
begin
 result:=fState.fBlendingMode;
end;

procedure TpvCanvas.SetBlendingMode(const aBlendingMode:TpvCanvasBlendingMode);
begin
 if fState.fBlendingMode<>aBlendingMode then begin
  Flush;
  fState.fBlendingMode:=aBlendingMode;
 end;
end;

function TpvCanvas.GetZPosition:TpvFloat;
begin
 result:=fState.fZPosition;
end;

procedure TpvCanvas.SetZPosition(const aZPosition:TpvFloat);
begin
 fState.fZPosition:=aZPosition;
end;

function TpvCanvas.GetLineWidth:TpvFloat;
begin
 result:=fState.fLineWidth;
end;

procedure TpvCanvas.SetLineWidth(const aLineWidth:TpvFloat);
begin
 fState.fLineWidth:=aLineWidth;
end;

function TpvCanvas.GetMiterLimit:TpvFloat;
begin
 result:=fState.fMiterLimit;
end;

procedure TpvCanvas.SetMiterLimit(const aMiterLimit:TpvFloat);
begin
 fState.fMiterLimit:=aMiterLimit;
end;

function TpvCanvas.GetLineJoin:TpvCanvasLineJoin;
begin
 result:=fState.fLineJoin;
end;

procedure TpvCanvas.SetLineJoin(const aLineJoin:TpvCanvasLineJoin);
begin
 fState.fLineJoin:=aLineJoin;
end;

function TpvCanvas.GetLineCap:TpvCanvasLineCap;
begin
 result:=fState.fLineCap;
end;

procedure TpvCanvas.SetLineCap(const aLineCap:TpvCanvasLineCap);
begin
 fState.fLineCap:=aLineCap;
end;

function TpvCanvas.GetFillRule:TpvCanvasFillRule;
begin
 result:=fState.fFillRule;
end;

procedure TpvCanvas.SetFillRule(const aFillRule:TpvCanvasFillRule);
begin
 fState.fFillRule:=aFillRule;
end;

function TpvCanvas.GetFillStyle:TpvCanvasFillStyle;
begin
 result:=fState.fFillStyle;
end;

procedure TpvCanvas.SetFillStyle(const aFillStyle:TpvCanvasFillStyle);
begin
 if fState.fFillStyle<>aFillStyle then begin
//Flush;
  fState.fFillStyle:=aFillStyle;
 end;
end;

function TpvCanvas.GetFillWrapMode:TpvCanvasFillWrapMode;
begin
 result:=fState.fFillWrapMode;
end;

procedure TpvCanvas.SetFillWrapMode(const aFillWrapMode:TpvCanvasFillWrapMode);
begin
 if fState.fFillWrapMode<>aFillWrapMode then begin
//Flush;
  fState.fFillWrapMode:=aFillWrapMode;
 end;
end;

function TpvCanvas.GetColor:TpvVector4;
begin
 result:=fState.GetColor;
end;

procedure TpvCanvas.SetColor(const aColor:TpvVector4);
begin
 fState.SetColor(aColor);
end;

function TpvCanvas.GetStartColor:TpvVector4;
begin
 result:=fState.StartColor;
end;

procedure TpvCanvas.SetStartColor(const aColor:TpvVector4);
begin
 if fState.StartColor<>aColor then begin
  Flush;
  fState.StartColor:=aColor;
 end;
end;

function TpvCanvas.GetStopColor:TpvVector4;
begin
 result:=fState.StopColor;
end;

procedure TpvCanvas.SetStopColor(const aColor:TpvVector4);
begin
 if fState.StopColor<>aColor then begin
  Flush;
  fState.StopColor:=aColor;
 end;
end;

function TpvCanvas.GetProjectionMatrix:TpvMatrix4x4;
begin
 result:=fState.fProjectionMatrix;
end;

procedure TpvCanvas.SetProjectionMatrix(const aProjectionMatrix:TpvMatrix4x4);
begin
 if fState.fProjectionMatrix<>aProjectionMatrix then begin
  Flush;
  fState.fProjectionMatrix:=aProjectionMatrix;
 end;
end;

function TpvCanvas.GetViewMatrix:TpvMatrix4x4;
begin
 result:=fState.fViewMatrix;
end;

procedure TpvCanvas.SetViewMatrix(const aViewMatrix:TpvMatrix4x4);
begin
 if fState.fViewMatrix<>aViewMatrix then begin
  Flush;
  fState.fViewMatrix:=aViewMatrix;
 end;
end;

function TpvCanvas.GetModelMatrix:TpvMatrix4x4;
begin
 result:=fState.fModelMatrix;
end;

procedure TpvCanvas.SetModelMatrix(const aModelMatrix:TpvMatrix4x4);
begin
 fState.fModelMatrix:=aModelMatrix;
end;

function TpvCanvas.GetFillMatrix:TpvMatrix4x4;
begin
 result:=fState.FillMatrix;
end;

procedure TpvCanvas.SetFillMatrix(const aMatrix:TpvMatrix4x4);
begin
 if fState.FillMatrix<>aMatrix then begin
  Flush;
  fState.FillMatrix:=aMatrix;
 end;
end;

function TpvCanvas.GetMaskMatrix:TpvMatrix4x4;
begin
 result:=fState.MaskMatrix;
end;

procedure TpvCanvas.SetMaskMatrix(const aMatrix:TpvMatrix4x4);
begin
 if fState.MaskMatrix<>aMatrix then begin
  Flush;
  fState.MaskMatrix:=aMatrix;
 end;
end;

function TpvCanvas.GetStrokePattern:TpvCanvasStrokePattern;
begin
 result:=fState.fStrokePattern;
end;

procedure TpvCanvas.SetStrokePattern(const aStrokePattern:TpvCanvasStrokePattern);
begin
 fState.fStrokePattern:=aStrokePattern;
end;

function TpvCanvas.GetFont:TpvFont;
begin
 result:=fState.fFont;
end;

procedure TpvCanvas.SetFont(const aFont:TpvFont);
begin
 fState.fFont:=aFont;
end;

function TpvCanvas.GetFontSize:TpvFloat;
begin
 result:=fState.fFontSize;
end;

procedure TpvCanvas.SetFontSize(const aFontSize:TpvFloat);
begin
 fState.fFontSize:=aFontSize;
end;

function TpvCanvas.GetTextHorizontalAlignment:TpvCanvasTextHorizontalAlignment;
begin
 result:=fState.fTextHorizontalAlignment;
end;

procedure TpvCanvas.SetTextHorizontalAlignment(aTextHorizontalAlignment:TpvCanvasTextHorizontalAlignment);
begin
 fState.fTextHorizontalAlignment:=aTextHorizontalAlignment;
end;

function TpvCanvas.GetTextVerticalAlignment:TpvCanvasTextVerticalAlignment;
begin
 result:=fState.fTextVerticalAlignment;
end;

procedure TpvCanvas.SetTextVerticalAlignment(aTextVerticalAlignment:TpvCanvasTextVerticalAlignment);
begin
 fState.fTextVerticalAlignment:=aTextVerticalAlignment;
end;

function TpvCanvas.GetVertexState:TpvUInt32;
begin
 result:=(TpvUInt32(fInternalRenderingMode) shl pvcvsRenderingModeShift) or
         (TpvUInt32(fState.fFillStyle) shl pvcvsFillStyleShift) or
         (TpvUInt32(fState.fFillWrapMode) shl pvcvsFillWrapModeShift) or
         (TpvUInt32(fSignedDistanceFieldVariant) shl pvcvsSignedDistanceFieldVariantShift);
end;

procedure TpvCanvas.GarbageCollectDescriptors;
var DescriptorLinkedListNode,PreviousDescriptorLinkedListNode:TpvCanvasVulkanDescriptorLinkedListNode;
    Descriptor:TpvCanvasVulkanDescriptor;
    CountProcessingBuffers:TpvNativeInt;
    Key:TpvCanvasTextureDescriptorSetHashMapKey;
begin
 CountProcessingBuffers:=Max(2,fCountProcessingBuffers)+1;
 DescriptorLinkedListNode:=fVulkanDescriptors.Back;
 while DescriptorLinkedListNode<>fVulkanDescriptors do begin
  PreviousDescriptorLinkedListNode:=DescriptorLinkedListNode.Previous;
  Descriptor:=DescriptorLinkedListNode.Value;
  if assigned(Descriptor) and
     (TpvNativeInt(TpvNativeUInt(fCurrentFrameNumber-Descriptor.fLastUsedFrameNumber))>CountProcessingBuffers) then begin
   try
    Key.Texture:=Descriptor.fDescriptorTexture;
    Key.MaskTexture:=Descriptor.fDescriptorMaskTexture;
    fVulkanTextureDescriptorSetHashMap.Delete(Key);
   finally
    Descriptor.Free;
   end;
  end else begin
   break;
  end;
  DescriptorLinkedListNode:=PreviousDescriptorLinkedListNode;
 end;
end;

procedure TpvCanvas.Start(const aBufferIndex:TpvInt32);
begin

 fCurrentCountVertices:=0;
 fCurrentCountIndices:=0;

 fCurrentFillBuffer:=@fVulkanCanvasBuffers[aBufferIndex];
 fCurrentFillBuffer^.fCountQueueItems:=0;
 fCurrentFillBuffer^.fCountUsedBuffers:=0;

 fState.Reset;

 fState.fScissor.offset.x:=trunc(floor(fViewport.x));
 fState.fScissor.offset.y:=trunc(floor(fViewport.y));
 fState.fScissor.extent.Width:=trunc(ceil(fViewport.Width));
 fState.fScissor.extent.Height:=trunc(ceil(fViewport.Height));

 fState.fClipRect:=TpvRect.CreateAbsolute(0.0,0.0,fWidth,fHeight);
 fState.UpdateClipSpaceClipRect(self);

 fState.fProjectionMatrix:=TpvMatrix4x4.CreateOrtho(0.0,fWidth,0.0,fHeight,-100.0,100.0);

 fCurrentVulkanBufferIndex:=-1;
 fCurrentVulkanVertexBufferOffset:=0;
 fCurrentVulkanIndexBufferOffset:=0;

 GetNextDestinationVertexBuffer;

end;

procedure TpvCanvas.Stop;
begin

 Flush;

 fCurrentFillBuffer:=nil;

 while fStateStack.Count>0 do begin
  Pop;
 end;

 GarbageCollectDescriptors;

 inc(fCurrentFrameNumber);

end;

procedure TpvCanvas.DeleteFromCachedDescriptors(const aKey:TpvCanvasTextureDescriptorSetHashMapKey);
var Descriptor:TpvCanvasVulkanDescriptor;
begin
 if fVulkanTextureDescriptorSetHashMap.TryGet(aKey,Descriptor) then begin
  try
   Descriptor.Free;
  finally
   fVulkanTextureDescriptorSetHashMap.Delete(aKey);
  end;
 end;
end;

procedure TpvCanvas.Flush;
var CurrentVulkanBufferIndex,OldCount,NewCount,QueueItemIndex:TpvInt32;
    QueueItem:PpvCanvasQueueItem;
    Descriptor:TpvCanvasVulkanDescriptor;
    CurrentTexture,CurrentMaskTexture:TObject;
    Key:TpvCanvasTextureDescriptorSetHashMapKey;
begin
 if assigned(fCurrentFillBuffer) and (fCurrentCountVertices>0) then begin

  while TPasMPInterlocked.CompareExchange(fCurrentFillBuffer^.fSpinLock,-1,0)<>0 do begin
  end;
  try

   CurrentVulkanBufferIndex:=fCurrentVulkanBufferIndex;

   fCurrentFillBuffer^.fCountUsedBuffers:=Max(fCurrentFillBuffer^.fCountUsedBuffers,CurrentVulkanBufferIndex+1);

   OldCount:=fCurrentFillBuffer^.fCountAllocatedBuffers;
   if OldCount<=CurrentVulkanBufferIndex then begin
    NewCount:=(CurrentVulkanBufferIndex+1)*2;
    SetLength(fCurrentFillBuffer^.fVulkanVertexBuffers,NewCount);
    SetLength(fCurrentFillBuffer^.fVulkanIndexBuffers,NewCount);
    SetLength(fCurrentFillBuffer^.fVertexBuffers,NewCount);
    SetLength(fCurrentFillBuffer^.fVertexBufferSizes,NewCount);
    SetLength(fCurrentFillBuffer^.fIndexBuffers,NewCount);
    SetLength(fCurrentFillBuffer^.fIndexBufferSizes,NewCount);
    FillChar(fCurrentFillBuffer^.fVulkanVertexBuffers[OldCount],(NewCount-OldCount)*SizeOf(TpvVulkanBuffer),#0);
    FillChar(fCurrentFillBuffer^.fVulkanIndexBuffers[OldCount],(NewCount-OldCount)*SizeOf(TpvVulkanBuffer),#0);
    FillChar(fCurrentFillBuffer^.fVertexBufferSizes[OldCount],(NewCount-OldCount)*SizeOf(TVkSizeInt),#0);
    FillChar(fCurrentFillBuffer^.fIndexBufferSizes[OldCount],(NewCount-OldCount)*SizeOf(TVkSizeInt),#0);
    fCurrentFillBuffer^.fCountAllocatedBuffers:=NewCount;
   end;

   inc(fCurrentFillBuffer^.fVertexBufferSizes[CurrentVulkanBufferIndex],fCurrentCountVertices*SizeOf(TpvCanvasVertex));

   inc(fCurrentFillBuffer^.fIndexBufferSizes[CurrentVulkanBufferIndex],fCurrentCountIndices*SizeOf(TpvUInt32));

   if fState.fGUIElementMode then begin
    CurrentTexture:=nil;
   end else begin
    if assigned(fState.fAtlasTexture) then begin
     CurrentTexture:=fState.fAtlasTexture;
    end else begin
     CurrentTexture:=fState.fTexture;
    end;
   end;

   if assigned(fState.fMaskTexture) and (fState.fMaskTexture is TpvVulkanTexture) then begin
    CurrentMaskTexture:=fState.fMaskTexture;
   end else begin
    CurrentMaskTexture:=nil;
   end;

   Key.Texture:=CurrentTexture;
   Key.MaskTexture:=CurrentMaskTexture;

   if fVulkanTextureDescriptorSetHashMap.TryGet(Key,Descriptor) then begin
    // Move existent descriptor to front
    Descriptor.Remove;
    fVulkanDescriptors.Front.Insert(Descriptor);
   end else begin
    // Allocate new descriptor
    Descriptor:=TpvCanvasVulkanDescriptor.Create(self);
    try
     Descriptor.fDescriptorPool:=TpvVulkanDescriptorPool.Create(fDevice,
                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                2);
     Descriptor.fDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,2);
     Descriptor.fDescriptorPool.Initialize;
     Descriptor.fDescriptorSet:=TpvVulkanDescriptorSet.Create(Descriptor.fDescriptorPool,
                                                              fVulkanDescriptorSetTextureLayout);
     if assigned(CurrentTexture) then begin
      if CurrentTexture is TpvSpriteAtlasArrayTexture then begin
       Descriptor.fDescriptorSet.WriteToDescriptorSet(0,
                                                      0,
                                                      1,
                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                      [TpvSpriteAtlasArrayTexture(CurrentTexture).Texture.DescriptorImageInfo],
                                                      [],
                                                      [],
                                                      false
                                                     );
      end else begin
       Descriptor.fDescriptorSet.WriteToDescriptorSet(0,
                                                      0,
                                                      1,
                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                      [TpvVulkanTexture(CurrentTexture).DescriptorImageInfo],
                                                      [],
                                                      [],
                                                      false
                                                     );
      end;
     end else begin
      Descriptor.fDescriptorSet.WriteToDescriptorSet(0,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                     [TpvVulkanTexture(fCanvasCommon.fDummyTexture).DescriptorImageInfo],
                                                     [],
                                                     [],
                                                     false
                                                    );
     end;
     if assigned(CurrentMaskTexture) then begin
      Descriptor.fDescriptorSet.WriteToDescriptorSet(1,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                     [TpvVulkanTexture(CurrentMaskTexture).DescriptorImageInfo],
                                                     [],
                                                     [],
                                                     false
                                                    );
     end else begin
      Descriptor.fDescriptorSet.WriteToDescriptorSet(1,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                     [TpvVulkanTexture(fCanvasCommon.fDummyTexture).DescriptorImageInfo],
                                                     [],
                                                     [],
                                                     false
                                                    );
     end;
     Descriptor.fDescriptorSet.Flush;
    finally
     Descriptor.fDescriptorTexture:=CurrentTexture;
     Descriptor.fDescriptorMaskTexture:=CurrentMaskTexture;
     fVulkanDescriptors.Front.Insert(Descriptor);
     fVulkanTextureDescriptorSetHashMap.Add(Key,Descriptor);
    end;
   end;

   Descriptor.fLastUsedFrameNumber:=fCurrentFrameNumber;

   QueueItemIndex:=fCurrentFillBuffer^.fCountQueueItems;
   inc(fCurrentFillBuffer^.fCountQueueItems);
   if length(fCurrentFillBuffer^.fQueueItems)<fCurrentFillBuffer^.fCountQueueItems then begin
    SetLength(fCurrentFillBuffer^.fQueueItems,fCurrentFillBuffer^.fCountQueueItems*2);
   end;
   QueueItem:=@fCurrentFillBuffer^.fQueueItems[QueueItemIndex];
   QueueItem^.Kind:=TpvCanvasQueueItemKind.Normal;
   QueueItem^.BufferIndex:=CurrentVulkanBufferIndex;
   QueueItem^.Descriptor:=Descriptor;
   QueueItem^.MaskingMode:=assigned(CurrentMaskTexture);
   QueueItem^.BlendingMode:=fState.fBlendingMode;
   if fState.fGUIElementMode then begin
    QueueItem^.TextureMode:=3;
   end else begin
    if assigned(CurrentTexture) then begin
     if (CurrentTexture is TpvSpriteAtlasArrayTexture) or
        ((CurrentTexture is TpvVulkanTexture) and
         (TpvVulkanTexture(CurrentTexture).ImageViewType=VK_IMAGE_VIEW_TYPE_2D_ARRAY)) then begin
      QueueItem^.TextureMode:=2;
     end else begin
      QueueItem^.TextureMode:=1;
     end;
    end else begin
     QueueItem^.TextureMode:=0;
    end;
   end;
   QueueItem^.StartVertexIndex:=fCurrentVulkanVertexBufferOffset;
   QueueItem^.StartIndexIndex:=fCurrentVulkanIndexBufferOffset;
   QueueItem^.CountVertices:=fCurrentCountVertices;
   QueueItem^.CountIndices:=fCurrentCountIndices;
   QueueItem^.Scissor:=fState.fScissor;
   QueueItem^.TransformMatrix:=fState.fViewMatrix*fState.fProjectionMatrix;
   QueueItem^.FillMatrix:=fState.fFillMatrix;
   QueueItem^.MaskMatrix:=fState.fMaskMatrix*fState.fProjectionMatrix;
   QueueItem^.PushConstants.Data[0].x:=QueueItem^.TransformMatrix.RawComponents[0,0];
   QueueItem^.PushConstants.Data[0].y:=QueueItem^.TransformMatrix.RawComponents[0,1];
   QueueItem^.PushConstants.Data[0].z:=QueueItem^.TransformMatrix.RawComponents[0,3];
   QueueItem^.PushConstants.Data[0].w:=QueueItem^.TransformMatrix.RawComponents[1,0];
   QueueItem^.PushConstants.Data[1].x:=QueueItem^.TransformMatrix.RawComponents[1,1];
   QueueItem^.PushConstants.Data[1].y:=QueueItem^.TransformMatrix.RawComponents[1,3];
   QueueItem^.PushConstants.Data[1].z:=QueueItem^.TransformMatrix.RawComponents[3,0];
   QueueItem^.PushConstants.Data[1].w:=QueueItem^.TransformMatrix.RawComponents[3,1];
   QueueItem^.PushConstants.Data[2].x:=QueueItem^.TransformMatrix.RawComponents[3,3];
   QueueItem^.PushConstants.Data[2].y:=QueueItem^.FillMatrix.RawComponents[0,0];
   QueueItem^.PushConstants.Data[2].z:=QueueItem^.FillMatrix.RawComponents[0,1];
   QueueItem^.PushConstants.Data[2].w:=QueueItem^.FillMatrix.RawComponents[0,2];
   QueueItem^.PushConstants.Data[3].x:=QueueItem^.FillMatrix.RawComponents[1,0];
   QueueItem^.PushConstants.Data[3].y:=QueueItem^.FillMatrix.RawComponents[1,1];
   QueueItem^.PushConstants.Data[3].z:=QueueItem^.FillMatrix.RawComponents[1,2];
   QueueItem^.PushConstants.Data[3].w:=QueueItem^.FillMatrix.RawComponents[2,0];
   QueueItem^.PushConstants.Data[4].x:=QueueItem^.FillMatrix.RawComponents[2,1];
   QueueItem^.PushConstants.Data[4].y:=QueueItem^.FillMatrix.RawComponents[2,2];
   QueueItem^.PushConstants.Data[4].z:=QueueItem^.FillMatrix.RawComponents[2,3];
   QueueItem^.PushConstants.Data[4].w:=QueueItem^.FillMatrix.RawComponents[3,0];
   QueueItem^.PushConstants.Data[5].x:=QueueItem^.FillMatrix.RawComponents[3,1];
   QueueItem^.PushConstants.Data[5].y:=QueueItem^.FillMatrix.RawComponents[3,2];
   QueueItem^.PushConstants.Data[5].z:=QueueItem^.FillMatrix.RawComponents[3,3];
   QueueItem^.PushConstants.Data[5].w:=QueueItem^.MaskMatrix.RawComponents[0,0];
   QueueItem^.PushConstants.Data[6].x:=QueueItem^.MaskMatrix.RawComponents[0,1];
   QueueItem^.PushConstants.Data[6].y:=QueueItem^.MaskMatrix.RawComponents[1,0];
   QueueItem^.PushConstants.Data[6].z:=QueueItem^.MaskMatrix.RawComponents[1,1];
   QueueItem^.PushConstants.Data[6].w:=QueueItem^.MaskMatrix.RawComponents[3,0];
   QueueItem^.PushConstants.Data[7].x:=QueueItem^.MaskMatrix.RawComponents[3,1];
   QueueItem^.PushConstants.Data[7].y:=0.0;
   QueueItem^.PushConstants.Data[7].z:=0.0;
   PpvUInt32(Pointer(@QueueItem^.PushConstants.Data[7].w))^:=0;
   if QueueItem^.MaskingMode then begin
    PpvUInt32(Pointer(@QueueItem^.PushConstants.Data[7].w))^:=PpvUInt32(Pointer(@QueueItem^.PushConstants.Data[7].w))^ or (TpvUInt32(1) shl 0);
   end;
  finally
   TPasMPInterlocked.Exchange(fCurrentFillBuffer^.fSpinLock,0);
  end;

  inc(fCurrentVulkanVertexBufferOffset,fCurrentCountVertices);
  inc(fCurrentVulkanIndexBufferOffset,fCurrentCountIndices);

  fCurrentCountVertices:=0;
  fCurrentCountIndices:=0;

  fCurrentDestinationVertexBufferPointer:=@fCurrentFillBuffer^.fVertexBuffers[fCurrentVulkanBufferIndex][fCurrentVulkanVertexBufferOffset];
  fCurrentDestinationIndexBufferPointer:=@fCurrentFillBuffer^.fIndexBuffers[fCurrentVulkanBufferIndex][fCurrentVulkanIndexBufferOffset];

 end;
end;

procedure TpvCanvas.GetNextDestinationVertexBuffer;
var OldCount,NewCount:TpvInt32;
begin

 inc(fCurrentVulkanBufferIndex);

 fCurrentVulkanVertexBufferOffset:=0;
 fCurrentVulkanIndexBufferOffset:=0;

 OldCount:=fCurrentFillBuffer^.fCountAllocatedBuffers;
 if OldCount<=fCurrentVulkanBufferIndex then begin
  NewCount:=RoundUpToPowerOfTwo(fCurrentVulkanBufferIndex+1);
  SetLength(fCurrentFillBuffer^.fVulkanVertexBuffers,NewCount);
  SetLength(fCurrentFillBuffer^.fVulkanIndexBuffers,NewCount);
  SetLength(fCurrentFillBuffer^.fVertexBuffers,NewCount);
  SetLength(fCurrentFillBuffer^.fVertexBufferSizes,NewCount);
  SetLength(fCurrentFillBuffer^.fIndexBuffers,NewCount);
  SetLength(fCurrentFillBuffer^.fIndexBufferSizes,NewCount);
  FillChar(fCurrentFillBuffer^.fVulkanVertexBuffers[OldCount],(NewCount-OldCount)*SizeOf(TpvVulkanBuffer),#0);
  FillChar(fCurrentFillBuffer^.fVulkanIndexBuffers[OldCount],(NewCount-OldCount)*SizeOf(TpvVulkanBuffer),#0);
  FillChar(fCurrentFillBuffer^.fVertexBufferSizes[OldCount],(NewCount-OldCount)*SizeOf(TVkSizeInt),#0);
  FillChar(fCurrentFillBuffer^.fIndexBufferSizes[OldCount],(NewCount-OldCount)*SizeOf(TVkSizeInt),#0);
  fCurrentFillBuffer^.fCountAllocatedBuffers:=NewCount;
 end;

 fCurrentDestinationVertexBufferPointer:=@fCurrentFillBuffer^.fVertexBuffers[fCurrentVulkanBufferIndex][0];

 fCurrentDestinationIndexBufferPointer:=@fCurrentFillBuffer^.fIndexBuffers[fCurrentVulkanBufferIndex][0];

 fCurrentFillBuffer^.fVertexBufferSizes[fCurrentVulkanBufferIndex]:=0;

 fCurrentFillBuffer^.fIndexBufferSizes[fCurrentVulkanBufferIndex]:=0;

end;

procedure TpvCanvas.EnsureSufficientReserveUsableSpace(const aCountVertices,aCountIndices:TpvInt32);
const UntilCountVertices=SizeOf(TpvCanvasVertexBuffer) div SizeOf(TpvCanvasVertex);
      UntilCountIndices=SizeOf(TpvCanvasIndexBuffer) div SizeOf(TpvUInt32);
begin
 if ((fCurrentVulkanVertexBufferOffset+fCurrentCountVertices+aCountVertices)>=UntilCountVertices) or
    ((fCurrentVulkanIndexBufferOffset+fCurrentCountIndices+aCountIndices)>=UntilCountIndices) then begin
  Flush;
  GetNextDestinationVertexBuffer;
 end;
end;

function TpvCanvas.AddVertex(const aPosition:TpvVector2;const aTexCoord:TpvVector3;const aColor:TpvVector4):TpvInt32;
var Vertex:PpvCanvasVertex;
begin
 result:=fCurrentCountVertices;
 Vertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices];
 inc(fCurrentCountVertices);
 Vertex^.OriginalPosition:=aPosition;
 Vertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*aPosition,fState.fZPosition);
 Vertex^.TextureCoord:=aTexCoord;
 Vertex^.Color.r:=aColor.r;
 Vertex^.Color.g:=aColor.g;
 Vertex^.Color.b:=aColor.b;
 Vertex^.Color.a:=aColor.a;
 Vertex^.State:=GetVertexState;
 Vertex^.ClipRect:=fState.fClipRect;
end;

function TpvCanvas.AddIndex(const aVertexIndex:TpvInt32):TpvInt32;
begin
 result:=fCurrentCountIndices;
 fCurrentDestinationIndexBufferPointer^[result]:=aVertexIndex;
 inc(fCurrentCountIndices);
end;

function TpvCanvas.ClipCheck(const aX0,aY0,aX1,aY1:TpvFloat):boolean;
const Threshold=1e-6;
begin
 result:=(fState.fClipRect.LeftTop.x<=(aX1+Threshold)) and
         (aX0<=(fState.fClipRect.RightBottom.x+Threshold)) and
         (fState.fClipRect.LeftTop.y<=(aY1+Threshold)) and
         (aY0<=(fState.fClipRect.RightBottom.y+Threshold));
end;

procedure TpvCanvas.ExecuteUpload(const aVulkanTransferQueue:TpvVulkanQueue;const aVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;const aVulkanTransferCommandBufferFence:TpvVulkanFence;const aBufferIndex:TpvInt32);
var Index:TpvInt32;
    CurrentBuffer:PpvCanvasBuffer;
    VulkanBuffer:TpvVulkanBuffer;
begin
 if (aBufferIndex>=0) and (aBufferIndex<fCountBuffers) then begin
  CurrentBuffer:=@fVulkanCanvasBuffers[aBufferIndex];
  if assigned(CurrentBuffer) and (CurrentBuffer^.fCountUsedBuffers>0) then begin
   while TPasMPInterlocked.CompareExchange(CurrentBuffer^.fSpinLock,-1,0)<>0 do begin
   end;
   try
    for Index:=0 to CurrentBuffer^.fCountUsedBuffers-1 do begin
     if CurrentBuffer^.fVertexBufferSizes[Index]>0 then begin
      VulkanBuffer:=CurrentBuffer^.fVulkanVertexBuffers[Index];
      if not assigned(VulkanBuffer) then begin
       if fDevice.MemoryManager.CompleteTotalMemoryMappable then begin
        VulkanBuffer:=TpvVulkanBuffer.Create(fDevice,
                                             SizeOf(TpvCanvasVertexBuffer),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             [TpvVulkanBufferFlag.PersistentMapped],
                                             0,
                                             pvAllocationGroupIDCanvas,
                                             'TpvCanvas.VertexBuffer'
                                            );
       end else begin
        VulkanBuffer:=TpvVulkanBuffer.Create(fDevice,
                                             SizeOf(TpvCanvasVertexBuffer),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                             0,
                                             0,
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                             0,
                                             0,
                                             0,
                                             0,
                                             [],
                                             0,
                                             pvAllocationGroupIDCanvas,
                                             'TpvCanvas.VertexBuffer'
                                            );
       end;
       CurrentBuffer^.fVulkanVertexBuffers[Index]:=VulkanBuffer;
      end;
      if assigned(VulkanBuffer) then begin
       if fDevice.MemoryManager.CompleteTotalMemoryMappable then begin
        VulkanBuffer.UploadData(aVulkanTransferQueue,
                                aVulkanTransferCommandBuffer,
                                aVulkanTransferCommandBufferFence,
                                CurrentBuffer^.fVertexBuffers[Index,0],
                                0,
                                CurrentBuffer^.fVertexBufferSizes[Index],
                                TpvVulkanBufferUseTemporaryStagingBufferMode.No);
       end else begin
        fDevice.MemoryStaging.Upload(aVulkanTransferQueue,
                                     aVulkanTransferCommandBuffer,
                                     aVulkanTransferCommandBufferFence,
                                     CurrentBuffer^.fVertexBuffers[Index,0],
                                     VulkanBuffer,
                                     0,
                                     CurrentBuffer^.fVertexBufferSizes[Index]);
       end;
      end;
     end;
     if CurrentBuffer^.fIndexBufferSizes[Index]>0 then begin
      VulkanBuffer:=CurrentBuffer^.fVulkanIndexBuffers[Index];
      if not assigned(VulkanBuffer) then begin
       if fDevice.MemoryManager.CompleteTotalMemoryMappable then begin
        VulkanBuffer:=TpvVulkanBuffer.Create(fDevice,
                                             SizeOf(TpvCanvasIndexBuffer),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             [TpvVulkanBufferFlag.PersistentMapped],
                                             0,
                                             pvAllocationGroupIDCanvas,
                                             'TpvCanvas.IndexBuffer'
                                            );
       end else begin
        VulkanBuffer:=TpvVulkanBuffer.Create(fDevice,
                                             SizeOf(TpvCanvasIndexBuffer),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                             0,
                                             0,
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                             0,
                                             0,
                                             0,
                                             0,
                                             [],
                                             0,
                                             pvAllocationGroupIDCanvas,
                                             'TpvCanvas.IndexBuffer'
                                            );
       end;
       CurrentBuffer^.fVulkanIndexBuffers[Index]:=VulkanBuffer;
      end;
      if assigned(VulkanBuffer) then begin
       if fDevice.MemoryManager.CompleteTotalMemoryMappable then begin
        VulkanBuffer.UploadData(aVulkanTransferQueue,
                                aVulkanTransferCommandBuffer,
                                aVulkanTransferCommandBufferFence,
                                CurrentBuffer^.fIndexBuffers[Index,0],
                                0,
                                CurrentBuffer^.fIndexBufferSizes[Index],
                                TpvVulkanBufferUseTemporaryStagingBufferMode.No);
       end else begin
        fDevice.MemoryStaging.Upload(aVulkanTransferQueue,
                                     aVulkanTransferCommandBuffer,
                                     aVulkanTransferCommandBufferFence,
                                     CurrentBuffer^.fIndexBuffers[Index,0],
                                     VulkanBuffer,
                                     0,
                                     CurrentBuffer^.fIndexBufferSizes[Index]);
       end;
      end;
     end;
    end;
   finally
    TPasMPInterlocked.Exchange(CurrentBuffer^.fSpinLock,0);
   end;
 { aVulkanCommandBuffer.MetaCmdMemoryBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                             TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT),
                                             TVkAccessFlags(VK_ACCESS_UNIFORM_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT));//}
  end;
 end;
end;

procedure TpvCanvas.ExecuteDraw(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32);
{$undef PasVulkanCanvasDoNotTrustGPUDriverAtDynamicStates}
const Offsets:array[0..0] of TVkDeviceSize=(0);
var Index,StartVertexIndex,TextureMode:TpvInt32;
    Descriptor:TpvCanvasVulkanDescriptor;
    MaskingMode:Boolean;
    BlendingMode:TpvCanvasBlendingMode;
    QueueItem:PpvCanvasQueueItem;
    OldQueueItemKind:TpvCanvasQueueItemKind;
    CurrentBuffer:PpvCanvasBuffer;
    VulkanVertexBuffer,VulkanIndexBuffer,OldVulkanVertexBuffer,OldVulkanIndexBuffer:TpvVulkanBuffer;
    OldScissor:TVkRect2D;
    TransformMatrix,FillMatrix,MaskMatrix:TpvMatrix4x4;
    ForceUpdate,ForceUpdatePushConstants,h:boolean;
//  DynamicOffset:TVkDeviceSize;
begin

 h:=true;

 if assigned(fVulkanRenderPass) and
    ((aBufferIndex>=0) and
     (aBufferIndex<fCountBuffers)) then begin

  CurrentBuffer:=@fVulkanCanvasBuffers[aBufferIndex];
  if assigned(CurrentBuffer) and (CurrentBuffer^.fCountQueueItems>0) then begin

   OldScissor.offset.x:=-$7fffffff;
   OldScissor.offset.y:=-$7fffffff;
   OldScissor.extent.Width:=$7fffffff;
   OldScissor.extent.Height:=$7fffffff;

   Descriptor:=nil;

   TransformMatrix:=TpvMatrix4x4.Null;

   FillMatrix:=TpvMatrix4x4.Null;

   MaskMatrix:=TpvMatrix4x4.Null;

   OldQueueItemKind:=TpvCanvasQueueItemKind.None;

   ForceUpdate:=true;

   ForceUpdatePushConstants:=true;

   MaskingMode:=false;

   BlendingMode:=TpvCanvasBlendingMode.AdditiveBlending;

   TextureMode:=-1;

   OldVulkanVertexBuffer:=nil;

   OldVulkanIndexBuffer:=nil;

   for Index:=0 to CurrentBuffer^.fCountQueueItems-1 do begin

    QueueItem:=@CurrentBuffer^.fQueueItems[Index];

    if OldQueueItemKind<>QueueItem^.Kind then begin
     OldQueueItemKind:=QueueItem^.Kind;
     ForceUpdate:=true;
    end;

    case QueueItem^.Kind of

     TpvCanvasQueueItemKind.Normal:begin

      VulkanVertexBuffer:=CurrentBuffer^.fVulkanVertexBuffers[QueueItem^.BufferIndex];

      VulkanIndexBuffer:=CurrentBuffer^.fVulkanIndexBuffers[QueueItem^.BufferIndex];

      if ForceUpdate then begin
       aVulkanCommandBuffer.CmdSetViewport(0,1,fPointerToViewport);
      end;

      if ForceUpdate or
         (MaskingMode<>QueueItem^.MaskingMode) or
         (BlendingMode<>QueueItem^.BlendingMode) or
         (TextureMode<>QueueItem^.TextureMode) then begin
       MaskingMode:=QueueItem^.MaskingMode;
       BlendingMode:=QueueItem^.BlendingMode;
       TextureMode:=QueueItem^.TextureMode;
       aVulkanCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipelines[QueueItem^.BlendingMode,QueueItem^.TextureMode].Handle);
{$ifdef PasVulkanCanvasDoNotTrustGPUDriverAtDynamicStates}
       OldScissor.offset.x:=-$7fffffff;
       OldScissor.offset.y:=-$7fffffff;
       OldScissor.extent.Width:=$7fffffff;
       OldScissor.extent.Height:=$7fffffff;
{$endif}
       Descriptor:=nil;
{$ifdef PasVulkanCanvasDoNotTrustGPUDriverAtDynamicStates}
       ForceUpdatePushConstants:=true;
{$endif}
      end;

      if ForceUpdate or
         (Descriptor<>QueueItem^.Descriptor) then begin
       Descriptor:=QueueItem^.Descriptor;
       aVulkanCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayouts[QueueItem^.BlendingMode,QueueItem^.TextureMode].Handle,0,1,@Descriptor.fDescriptorSet.Handle,0,nil);
{$ifdef PasVulkanCanvasDoNotTrustGPUDriverAtDynamicStates}
       ForceUpdatePushConstants:=true;
{$endif}
      end;

      if ForceUpdate or
         ForceUpdatePushConstants or
         (TransformMatrix<>QueueItem^.TransformMatrix) or
         (FillMatrix<>QueueItem^.FillMatrix) or
         (MaskMatrix<>QueueItem^.MaskMatrix) then begin
       TransformMatrix:=QueueItem^.TransformMatrix;
       FillMatrix:=QueueItem^.FillMatrix;
       MaskMatrix:=QueueItem^.MaskMatrix;
       aVulkanCommandBuffer.CmdPushConstants(fVulkanPipelineLayouts[BlendingMode,TextureMode].Handle,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             0,
                                             SizeOf(TpvCanvasPushConstants),
                                             @QueueItem^.PushConstants);
      end;

      if ForceUpdate or
         (OldScissor.offset.x<>QueueItem^.Scissor.offset.x) or
         (OldScissor.offset.y<>QueueItem^.Scissor.offset.y) or
         (OldScissor.extent.Width<>QueueItem^.Scissor.extent.Width) or
         (OldScissor.extent.Height<>QueueItem^.Scissor.extent.Height) then begin
       OldScissor:=QueueItem^.Scissor;
       aVulkanCommandBuffer.CmdSetScissor(0,1,@QueueItem^.Scissor);
      end;

      if ForceUpdate or
         (OldVulkanVertexBuffer<>VulkanVertexBuffer) then begin
       OldVulkanVertexBuffer:=VulkanVertexBuffer;
       aVulkanCommandBuffer.CmdBindVertexBuffers(0,1,@VulkanVertexBuffer.Handle,@Offsets);
      end;

      if ForceUpdate or
         (OldVulkanIndexBuffer<>VulkanIndexBuffer) then begin
       OldVulkanIndexBuffer:=VulkanIndexBuffer;
       aVulkanCommandBuffer.CmdBindIndexBuffer(VulkanIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);
      end;

      aVulkanCommandBuffer.CmdDrawIndexed(QueueItem^.CountIndices,1,QueueItem^.StartIndexIndex,QueueItem^.StartVertexIndex,0);

{     DynamicOffset:=QueueItem^.StartVertexIndex*SizeOf(TpvCanvasVertex);
      aVulkanCommandBuffer.CmdBindVertexBuffers(0,1,@VulkanVertexBuffer.Handle,@DynamicOffset);

      aVulkanCommandBuffer.CmdBindIndexBuffer(VulkanIndexBuffer.Handle,QueueItem^.StartIndexIndex*SizeOf(TpvUInt32),VK_INDEX_TYPE_UINT32);
      aVulkanCommandBuffer.CmdDrawIndexed(QueueItem^.CountIndices,1,0,0,0);}

      ForceUpdate:=false;

      ForceUpdatePushConstants:=false;

     end;

     TpvCanvasQueueItemKind.Hook:begin
      if assigned(QueueItem^.Hook) then begin
       QueueItem^.Hook(QueueItem^.HookData,aVulkanCommandBuffer,aBufferIndex);
      end;
      ForceUpdate:=true;
     end;

     else {TpvCanvasQueueItemKind.None:}begin
      ForceUpdate:=true;
     end;

    end;

   end;

   CurrentBuffer^.fCountQueueItems:=0;
   CurrentBuffer^.fCountUsedBuffers:=0;

  end;

 end;

end;

function TpvCanvas.Push:TpvCanvas;
var NewState:TpvCanvasState;
begin
 NewState:=TpvCanvasState.Create;
 NewState.Assign(fState);
 fStateStack.Push(TpvCanvasState(TObject(TPasMPInterlocked.Exchange(TObject(fState),TObject(NewState)))));
 result:=self;
end;

function TpvCanvas.Pop:TpvCanvas;
var PeekState:TpvCanvasState;
begin
 PeekState:=fStateStack.Peek;
 if assigned(PeekState) then begin
  if (assigned(fCurrentFillBuffer) and
      (fCurrentCountVertices>0)) and
     ({(fState.fFillStyle<>PeekState.fFillStyle) or
      (fState.fFillWrapMode<>PeekState.fFillWrapMode) or}
      (fState.fBlendingMode<>PeekState.fBlendingMode) or
      (fState.fScissor.offset.x<>PeekState.fScissor.offset.x) or
      (fState.fScissor.offset.y<>PeekState.fScissor.offset.y) or
      (fState.fScissor.extent.width<>PeekState.fScissor.extent.width) or
      (fState.fScissor.extent.height<>PeekState.fScissor.extent.height) or
      (fState.fProjectionMatrix<>PeekState.fProjectionMatrix) or
      (fState.fViewMatrix<>PeekState.fViewMatrix) or
      (fState.fFillMatrix<>PeekState.fFillMatrix) or
      (fState.fMaskMatrix<>PeekState.fMaskMatrix) or
      (fState.fTexture<>PeekState.fTexture) or
      (fState.fAtlasTexture<>PeekState.fAtlasTexture) or
      (fState.fGUIElementMode<>PeekState.fGUIElementMode)) then begin
   Flush;
  end;
  TpvCanvasState(TObject(TPasMPInterlocked.Exchange(TObject(fState),TObject(fStateStack.Extract)))).Free;
 end else begin
  Assert(false);
 end;
 result:=self;
end;

function TpvCanvas.Hook(const aHook:TpvCanvasHook;const aData:TpvPointer):TpvCanvas;
var QueueItemIndex:TpvInt32;
    QueueItem:PpvCanvasQueueItem;
begin
 if assigned(aHook) then begin

  Flush;

  QueueItemIndex:=fCurrentFillBuffer^.fCountQueueItems;
  inc(fCurrentFillBuffer^.fCountQueueItems);
  if length(fCurrentFillBuffer^.fQueueItems)<fCurrentFillBuffer^.fCountQueueItems then begin
   SetLength(fCurrentFillBuffer^.fQueueItems,fCurrentFillBuffer^.fCountQueueItems*2);
  end;
  QueueItem:=@fCurrentFillBuffer^.fQueueItems[QueueItemIndex];
  QueueItem^.Kind:=TpvCanvasQueueItemKind.Hook;
  QueueItem^.Hook:=aHook;
  QueueItem^.HookData:=aData;

 end;
 result:=self;
end;

function TpvCanvas.DrawSprite(const aSprite:TpvSprite;const aSrc,aDest:TpvRect):TpvCanvas;
const MinA=1.0/65536.0;
      SrcRectPositionComponents:array[boolean,0..1,0..3] of TpvInt32=(((0,2,2,0),
                                                                       (1,1,3,3)),
                                                                      ((2,2,0,0),
                                                                       (1,3,3,1)));
      DestRectPositionComponents:array[0..1,0..3] of TpvInt32=((0,2,2,0),
                                                               (1,1,3,3));
var IntersectedRect,DestRect,SrcRect:TpvRect;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    Index:TpvInt32;
    TemporaryVector:PpvVector2;
    ScaleTemporaryVector:TpvVector2;
    Vertex:PpvCanvasVertex;
    VertexIndex:PpvUInt32;
    SpriteAtlasArrayTexture:TpvSpriteAtlasArrayTexture;
begin

 result:=self;

 if ((fState.fBlendingMode<>TpvCanvasBlendingMode.None) and
     (abs(fState.fColor.a)<MinA)) or
    (aSrc.Right<aSprite.TrimmedOffset.x) or
    (aSrc.Bottom<aSprite.TrimmedOffset.y) or
    (aSprite.TrimmedRect.Right<aSrc.Left) or
    (aSprite.TrimmedRect.Bottom<aSrc.Top) then begin
  exit;
 end;

 if aSprite.SignedDistanceField then begin
  fInternalRenderingMode:=TpvCanvasRenderingMode.SignedDistanceField;
  fSignedDistanceFieldVariant:=aSprite.SignedDistanceFieldVariant;
 end else begin
  fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
  fSignedDistanceFieldVariant:=TpvSignedDistanceField2DVariant(TpvUInt8(0));
 end;

 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;

 VertexState:=GetVertexState;

 SetGUIElementMode(false);

 SetAtlasTexture(aSprite.ArrayTexture);

 SpriteAtlasArrayTexture:=TpvSpriteAtlasArrayTexture(fState.fAtlasTexture);

 if (length(aSprite.TrimmedHullVectors)>2) and
    (not aSprite.Rotated) and
    SameValue(aSrc.Left,0.0) and
    SameValue(aSrc.Top,0.0) and
    SameValue(aSrc.Right,aSprite.Width) and
    SameValue(aSrc.Bottom,aSprite.Height) then begin

  EnsureSufficientReserveUsableSpace(length(aSprite.TrimmedHullVectors),(length(aSprite.TrimmedHullVectors)-2)*3);

  for Index:=2 to length(aSprite.TrimmedHullVectors)-1 do begin
   fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices;
   fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+(Index-1);
   fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+Index;
   inc(fCurrentCountIndices,3);
  end;

  ScaleTemporaryVector:=aDest.Size/aSrc.Size;

  for Index:=0 to length(aSprite.TrimmedHullVectors)-1 do begin
   TemporaryVector:=@aSprite.TrimmedHullVectors[Index];
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].OriginalPosition:=aDest.LeftTop+(((TemporaryVector^+aSprite.TrimmedOffset)-aSrc.LeftTop)*ScaleTemporaryVector);
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].OriginalPosition,fState.fZPosition);
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].TextureCoord:=TpvVector3.InlineableCreate((TemporaryVector^+aSprite.Offset)*SpriteAtlasArrayTexture.InverseSize,aSprite.Layer);
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].MetaInfo:=TpvVector4.Null;
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].Color:=VertexColor;
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].State:=VertexState;
   fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices].ClipRect:=fState.fClipSpaceClipRect;
   inc(fCurrentCountVertices);
  end;

  exit;
 end;

 IntersectedRect:=aSprite.TrimmedRect.GetIntersection(aSrc);

{$if true}
 DestRect.Vector4:=aDest.Vector4+((IntersectedRect.Vector4-aSrc.Vector4)*(aDest.Size/aSrc.Size).xyxy);
{$else}
 ScaleTemporaryVector:=aDest.Size/aSrc.Size;
 DestRect.LeftTop:=aDest.LeftTop+((TempRect.LeftTop-aSrc.LeftTop)*ScaleTemporaryVector);
 DestRect.RightBottom:=aDest.RightBottom+((TempRect.RightBottom-aSrc.RightBottom)*ScaleTemporaryVector);
{$ifend}

 SrcRect.LeftTop:=(IntersectedRect.LeftTop-aSprite.TrimmedOffset)+aSprite.Offset;
 SrcRect.RightBottom:=SrcRect.LeftTop+IntersectedRect.Size;

 EnsureSufficientReserveUsableSpace(4,6);

 VertexIndex:=@fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices];
 inc(fCurrentCountIndices,6);

 VertexIndex^:=fCurrentCountVertices+0;
 inc(VertexIndex);
 VertexIndex^:=fCurrentCountVertices+1;
 inc(VertexIndex);
 VertexIndex^:=fCurrentCountVertices+2;
 inc(VertexIndex);
 VertexIndex^:=fCurrentCountVertices+0;
 inc(VertexIndex);
 VertexIndex^:=fCurrentCountVertices+2;
 inc(VertexIndex);
 VertexIndex^:=fCurrentCountVertices+3;
 inc(VertexIndex);
 Vertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices];
 inc(fCurrentCountVertices,4);

 for Index:=0 to 3 do begin
  Vertex^.OriginalPosition:=TpvVector2.InlineableCreate(DestRect.Components[DestRectPositionComponents[0,Index]],
                                                        DestRect.Components[DestRectPositionComponents[1,Index]]);
  Vertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*Vertex^.OriginalPosition,
                                                fState.fZPosition);
  Vertex^.Color:=VertexColor;
  Vertex^.TextureCoord:=TpvVector3.InlineableCreate(TpvVector2.InlineableCreate(SrcRect.Components[SrcRectPositionComponents[aSprite.Rotated,0,Index]],
                                                                                SrcRect.Components[SrcRectPositionComponents[aSprite.Rotated,1,Index]])*SpriteAtlasArrayTexture.InverseSize,
                                                    aSprite.Layer);
  Vertex^.State:=VertexState;
  Vertex^.ClipRect:=fState.fClipSpaceClipRect;
{ PpvInt64(pointer(@Vertex^.MetaInfo.x))^:=0;
  PpvInt64(pointer(@Vertex^.MetaInfo.z))^:=0;}
  inc(Vertex);

 end;

end;

function TpvCanvas.DrawSprite(const aSprite:TpvSprite;const aSrc,aDest:TpvRect;const aOrigin:TpvVector2;const aRotationAngle:TpvFloat):TpvCanvas;
var OldMatrix:TpvMatrix4x4;
    AroundPoint:TpvVector2;
begin
 OldMatrix:=fState.fModelMatrix;
 try
  AroundPoint:=aDest.LeftTop+aOrigin+TpvVector2.InlineableCreate(aSprite.OffsetX,aSprite.OffsetY);
  fState.fModelMatrix:=((TpvMatrix4x4.CreateTranslation(-AroundPoint)*
                         TpvMatrix4x4.CreateRotateZ(aRotationAngle))*
                        TpvMatrix4x4.CreateTranslation(AroundPoint))*
                        fState.fModelMatrix;
  result:=DrawSprite(aSprite,aSrc,aDest);
 finally
  fState.fModelMatrix:=OldMatrix;
 end;
end;

function TpvCanvas.DrawSprite(const aSprite:TpvSprite;const aPosition:TpvVector2):TpvCanvas;
begin
 DrawSprite(aSprite,
            TpvRect.CreateAbsolute(0.0,0.0,aSprite.Width,aSprite.Height),
            TpvRect.CreateAbsolute(aPosition.x-(aSprite.OffsetX*aSprite.ScaleX),aPosition.y-(aSprite.OffsetY*aSprite.ScaleY),
                                   (aPosition.x-(aSprite.OffsetX*aSprite.ScaleX))+(aSprite.Width*aSprite.ScaleX),(aPosition.y-(aSprite.OffsetY*aSprite.ScaleY))+(aSprite.Height*aSprite.ScaleY)));
 result:=self;
end;

function TpvCanvas.DrawSprite(const aSprite:TpvSprite):TpvCanvas;
begin
 DrawSprite(aSprite,
            TpvVector2.InlineableCreate(0.0,0.0));
 result:=self;
end;

procedure TpvCanvas.DrawSpriteProc(const aSprite:TpvSprite;const aSrc,aDest:TpvRect);
begin
 DrawSprite(aSprite,aSrc,aDest);
end;

function TpvCanvas.DrawNinePatchSprite(const aSprite:TpvSprite;const aNinePatch:TpvSpriteNinePatch;const aPosition,aSize:TpvVector2):TpvCanvas;
var RowIndex,ColumnIndex:TpvInt32;
    NinePatchRegion:PpvSpriteNinePatchRegion;
    SrcRect,DestRect:TpvRect;
    x,y,StepX,StepY:TpvDouble;
begin
 for RowIndex:=0 to 2 do begin
  for ColumnIndex:=0 to 2 do begin
   NinePatchRegion:=@aNinePatch.Regions[RowIndex,ColumnIndex];
   SrcRect.Left:=NinePatchRegion^.Left;
   SrcRect.Top:=NinePatchRegion^.Top;
   SrcRect.Right:=SrcRect.Left+NinePatchRegion^.Width;
   SrcRect.Bottom:=SrcRect.Top+NinePatchRegion^.Height;
   case ColumnIndex of
    0:begin
     DestRect.Left:=aPosition.x;
     DestRect.Right:=aPosition.x+aNinePatch.Regions[RowIndex,0].Width;
    end;
    1:begin
     DestRect.Left:=aPosition.x+aNinePatch.Regions[RowIndex,0].Width;
     DestRect.Right:=(aPosition.x+aSize.x)-aNinePatch.Regions[RowIndex,2].Width;
    end;
    else begin
     DestRect.Left:=(aPosition.x+aSize.x)-aNinePatch.Regions[RowIndex,2].Width;
     DestRect.Right:=aPosition.x+aSize.x;
    end;
   end;
   case RowIndex of
    0:begin
     DestRect.Top:=aPosition.y;
     DestRect.Bottom:=aPosition.y+aNinePatch.Regions[0,ColumnIndex].Height;
    end;
    1:begin
     DestRect.Top:=aPosition.y+aNinePatch.Regions[0,ColumnIndex].Height;
     DestRect.Bottom:=(aPosition.y+aSize.y)-aNinePatch.Regions[2,ColumnIndex].Height;
    end;
    else begin
     DestRect.Top:=(aPosition.y+aSize.y)-aNinePatch.Regions[2,ColumnIndex].Height;
     DestRect.Bottom:=aPosition.y+aSize.y;
    end;
   end;
   case NinePatchRegion^.Mode of
    TpvSpriteNinePatchRegionMode.Stretch:begin
     DrawSprite(aSprite,SrcRect,DestRect);
    end;
    TpvSpriteNinePatchRegionMode.StretchXTileY:begin
     y:=DestRect.Top;
     while y<DestRect.Bottom do begin
      StepY:=Max(1e-4,Min(DestRect.Bottom-y,NinePatchRegion^.Height));
      DrawSprite(aSprite,
                 TpvRect.CreateAbsolute(SrcRect.Left,SrcRect.Top,SrcRect.Right,SrcRect.Top+StepY),
                 TpvRect.CreateAbsolute(DestRect.Left,y,DestRect.Right,y+StepY));
      y:=y+StepY;
     end;
    end;
    TpvSpriteNinePatchRegionMode.TileXStretchY:begin
     x:=DestRect.Left;
     while x<DestRect.Right do begin
      StepX:=Max(1e-4,Min(DestRect.Right-x,NinePatchRegion^.Width));
      DrawSprite(aSprite,
                 TpvRect.CreateAbsolute(SrcRect.Left,SrcRect.Top,SrcRect.Left+StepX,SrcRect.Bottom),
                 TpvRect.CreateAbsolute(x,DestRect.Top,x+StepX,DestRect.Bottom));
      x:=x+StepX;
     end;
    end;
    else {TpvSpriteNinePatchRegionMode.Tile:}begin
     y:=DestRect.Top;
     while y<DestRect.Bottom do begin
      StepY:=Max(1e-4,Min(DestRect.Bottom-y,NinePatchRegion^.Height));
      x:=DestRect.Left;
      while x<DestRect.Right do begin
       StepX:=Max(1e-4,Min(DestRect.Right-x,NinePatchRegion^.Width));
       DrawSprite(aSprite,
                  TpvRect.CreateAbsolute(SrcRect.Left,SrcRect.Top,SrcRect.Left+StepX,SrcRect.Top+StepY),
                  TpvRect.CreateAbsolute(x,y,x+StepX,y+StepY));
       x:=x+StepX;
      end;
      y:=y+StepY;
     end;
    end;
   end;
  end;
 end;
 result:=self;
end;

function TpvCanvas.TextWidth(const aText:TpvUTF8String):TpvFloat;
begin
 if assigned(fState.fFont) then begin
  result:=fState.fFont.TextWidth(aText,fState.fFontSize);
 end else begin
  result:=0.0;
 end;
end;

function TpvCanvas.TextHeight(const aText:TpvUTF8String):TpvFloat;
begin
 if assigned(fState.fFont) then begin
  result:=fState.fFont.TextHeight(aText,fState.fFontSize);
 end else begin
  result:=0.0;
 end;
end;

function TpvCanvas.TextSize(const aText:TpvUTF8String):TpvVector2;
begin
 if assigned(fState.fFont) then begin
  result:=fState.fFont.TextSize(aText,fState.fFontSize);
 end else begin
  result:=TpvVector2.InlineableCreate(0.0,0.0);
 end;
end;

function TpvCanvas.TextRowHeight(const aPercent:TpvFloat):TpvFloat;
begin
 if assigned(fState.fFont) then begin
  result:=fState.fFont.RowHeight(aPercent,fState.fFontSize);
 end else begin
  result:=0.0;
 end;
end;

procedure TpvCanvas.TextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32);
var Position,Size:TpvVector2;
begin
 if assigned(fState.fFont) then begin
  Position:=aPosition;
  if fState.fTextHorizontalAlignment<>TpvCanvasTextHorizontalAlignment.Leading then begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=TextSize(aText);
   end else begin
    Size:=TpvVector2.InlineableCreate(TextWidth(aText),0.0);
   end;
  end else begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=TpvVector2.InlineableCreate(0.0,TextHeight(aText));
   end else begin
    Size:=TpvVector2.InlineableCreate(0.0,0.0);
   end;
  end;
  case fState.fTextHorizontalAlignment of
   TpvCanvasTextHorizontalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextHorizontalAlignment.Center:begin
    Position.x:=Position.x-(Size.x*0.5);
   end;
   TpvCanvasTextHorizontalAlignment.Tailing:begin
    Position.x:=Position.x-Size.x;
   end;
  end;
  case fState.fTextVerticalAlignment of
   TpvCanvasTextVerticalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextVerticalAlignment.Middle:begin
    Position.y:=Position.y-(Size.y*0.5);
   end;
   TpvCanvasTextVerticalAlignment.Tailing:begin
    Position.y:=Position.y-Size.y;
   end;
  end;
  fState.fFont.GetTextGlyphRects(aText,Position,fState.fFontSize,aTextGlyphRects,aCountTextGlyphRects);
 end;
end;

procedure TpvCanvas.TextGlyphRects(const aText:TpvUTF8String;const aX,aY:TpvFloat;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32);
begin
 TextGlyphRects(aText,TpvVector2.InlineableCreate(aX,aY),aTextGlyphRects,aCountTextGlyphRects);
end;

procedure TpvCanvas.TextGlyphRects(const aText:TpvUTF8String;var aTextGlyphRects:TpvCanvasTextGlyphRects;out aCountTextGlyphRects:TpvInt32);
begin
 TextGlyphRects(aText,TpvVector2.Null,aTextGlyphRects,aCountTextGlyphRects);
end;

function TpvCanvas.TextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2):TpvCanvasTextGlyphRects;
var CountTextGlyphRects:TpvInt32;
begin
 result:=nil;
 CountTextGlyphRects:=0;
 try
  TextGlyphRects(aText,aPosition,result,CountTextGlyphRects);
 finally
  SetLength(result,CountTextGlyphRects);
 end;
end;

function TpvCanvas.TextGlyphRects(const aText:TpvUTF8String;const aX,aY:TpvFloat):TpvCanvasTextGlyphRects;
begin
 result:=TextGlyphRects(aText,TpvVector2.InlineableCreate(aX,aY));
end;

function TpvCanvas.TextGlyphRects(const aText:TpvUTF8String):TpvCanvasTextGlyphRects;
begin
 result:=TextGlyphRects(aText,TpvVector2.Null);
end;

function TpvCanvas.DrawTextCodePoint(const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2):TpvCanvas;
var Position,Size:TpvVector2;
begin
 if assigned(fState.fFont) then begin
  Position:=aPosition;
  if fState.fTextHorizontalAlignment<>TpvCanvasTextHorizontalAlignment.Leading then begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=fState.fFont.CodePointSize(aTextCodePoint,fState.fFontSize);
   end else begin
    Size:=TpvVector2.InlineableCreate(fState.fFont.CodePointWidth(aTextCodePoint,fState.fFontSize),0.0);
   end;
  end else begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=TpvVector2.InlineableCreate(0.0,fState.fFont.CodePointHeight(aTextCodePoint,fState.fFontSize));
   end else begin
    Size:=TpvVector2.InlineableCreate(0.0,0.0);
   end;
  end;
  case fState.fTextHorizontalAlignment of
   TpvCanvasTextHorizontalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextHorizontalAlignment.Center:begin
    Position.x:=Position.x-(Size.x*0.5);
   end;
   TpvCanvasTextHorizontalAlignment.Tailing:begin
    Position.x:=Position.x-Size.x;
   end;
  end;
  case fState.fTextVerticalAlignment of
   TpvCanvasTextVerticalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextVerticalAlignment.Middle:begin
    Position.y:=Position.y-(Size.y*0.5);
   end;
   TpvCanvasTextVerticalAlignment.Tailing:begin
    Position.y:=Position.y-Size.y;
   end;
  end;
  fState.fFont.DrawCodePoint(self,aTextCodePoint,Position,fState.fFontSize);
 end;
 result:=self;
end;

function TpvCanvas.DrawTextCodePoint(const aTextCodePoint:TpvUInt32;const aX,aY:TpvFloat):TpvCanvas;
begin
 result:=DrawTextCodePoint(aTextCodePoint,TpvVector2.InlineableCreate(aX,aY));
end;

function TpvCanvas.DrawTextCodePoint(const aTextCodePoint:TpvUInt32):TpvCanvas;
begin
 result:=DrawTextCodePoint(aTextCodePoint,TpvVector2.InlineableCreate(0.0,0.0));
end;

function TpvCanvas.DrawText(const aText:TpvUTF8String;const aPosition:TpvVector2):TpvCanvas;
var Position,Size:TpvVector2;
begin
 if assigned(fState.fFont) then begin
  Position:=aPosition;
  if fState.fTextHorizontalAlignment<>TpvCanvasTextHorizontalAlignment.Leading then begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=TextSize(aText);
   end else begin
    Size:=TpvVector2.InlineableCreate(TextWidth(aText),0.0);
   end;
  end else begin
   if fState.fTextVerticalAlignment<>TpvCanvasTextVerticalAlignment.Leading then begin
    Size:=TpvVector2.InlineableCreate(0.0,TextHeight(aText));
   end else begin
    Size:=TpvVector2.InlineableCreate(0.0,0.0);
   end;
  end;
  case fState.fTextHorizontalAlignment of
   TpvCanvasTextHorizontalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextHorizontalAlignment.Center:begin
    Position.x:=Position.x-(Size.x*0.5);
   end;
   TpvCanvasTextHorizontalAlignment.Tailing:begin
    Position.x:=Position.x-Size.x;
   end;
  end;
  case fState.fTextVerticalAlignment of
   TpvCanvasTextVerticalAlignment.Leading:begin
    // Do nothing
   end;
   TpvCanvasTextVerticalAlignment.Middle:begin
    Position.y:=Position.y-(Size.y*0.5);
   end;
   TpvCanvasTextVerticalAlignment.Tailing:begin
    Position.y:=Position.y-Size.y;
   end;
  end;
  fState.fFont.Draw(self,aText,Position,fState.fFontSize);
 end;
 result:=self;
end;

function TpvCanvas.DrawText(const aText:TpvUTF8String;const aX,aY:TpvFloat):TpvCanvas;
begin
 result:=DrawText(aText,TpvVector2.InlineableCreate(aX,aY));
end;

function TpvCanvas.DrawText(const aText:TpvUTF8String):TpvCanvas;
begin
 result:=DrawText(aText,TpvVector2.InlineableCreate(0.0,0.0));
end;

function TpvCanvas.DrawFilledEllipse(const aCenter,aRadius:TpvVector2):TpvCanvas;
var MetaInfo:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.zw:=aRadius;
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aRadius.x,-aRadius.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomEllipse and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aRadius.x,-aRadius.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomEllipse and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aRadius.x,aRadius.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomEllipse and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aRadius.x,aRadius.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomEllipse and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledEllipse(const aCenterX,aCenterY,aRadiusX,aRadiusY:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledEllipse(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aRadiusX,aRadiusY));
end;

function TpvCanvas.DrawFilledCircle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvas;
var MetaInfo:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.z:=aRadius;
 MetaInfo.w:=0.0;
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aRadius,-aRadius);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aRadius,-aRadius);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aRadius,aRadius);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aRadius,aRadius);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledCircle(const aCenterX,aCenterY,aRadius:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledCircle(TpvVector2.InlineableCreate(aCenterX,aCenterY),aRadius);
end;

function TpvCanvas.DrawFilledRectangle(const aCenter,aBounds:TpvVector2):TpvCanvas;
var MetaInfo:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.zw:=aBounds;
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledRectangle(const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledRectangle(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY));
end;

function TpvCanvas.DrawFilledRectangle(const aRect:TpvRect):TpvCanvas;
var MetaInfo:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=(aRect.LeftTop+aRect.RightBottom)*0.5;
 MetaInfo.zw:=aRect.RightBottom-aRect.LeftTop;
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(aRect.Left,aRect.Top);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(aRect.Right,aRect.Top);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(aRect.Right,aRect.Bottom);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(aRect.Left,aRect.Bottom);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledRoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvas;
var MetaInfo:TpvVector4;
    MetaInfo2:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.zw:=aBounds-TpvVector2.InlineableCreate(aRadius,aRadius);
 MetaInfo2:=TpvVector4.InlineableCreate(aRadius,0.0,0.0,0.0);
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRoundedRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRoundedRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRoundedRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomRoundedRectangle and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledRoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadius:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledRoundedRectangle(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY),aRadius);
end;

function TpvCanvas.DrawFilledRoundedRectangle(const aRect:TpvRect;const aRadius:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledRoundedRectangle(aRect.Center,aRect.Size*0.5,aRadius);
end;

function TpvCanvas.DrawFilledCircleArcRingSegment(const aCenter:TpvVector2;const aInnerRadius,aOuterRadius,aStartAngle,aEndAngle,aGapThickness:TpvFloat):TpvCanvas;
var Index,Count:TpvSizeInt;
    MetaInfo,MetaInfo2:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
    MinRadius,MaxRadius:TpvFloat;
    AABB:TpvAABB2D;
    CosSinValues:TpvVector2;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.z:=aInnerRadius;
 MetaInfo.w:=aOuterRadius;
 MetaInfo2.x:=aStartAngle;
 MetaInfo2.y:=aEndAngle;
 MetaInfo2.z:=aGapThickness;
 MinRadius:=Max(0.0,Min(Min(aInnerRadius,aOuterRadius)*0.98725,Min(aInnerRadius,aOuterRadius)-(abs(aOuterRadius-aInnerRadius)*0.125)));
 MaxRadius:=Max(Max(aInnerRadius,aOuterRadius)*1.015625,Max(aInnerRadius,aOuterRadius)+(abs(aOuterRadius-aInnerRadius)*0.125));
 begin
  if abs(aEndAngle-aStartAngle)>=pi then begin
   AABB.Min:=aCenter+TpvVector2.InlineableCreate(-MaxRadius,-MaxRadius);
   AABB.Max:=aCenter+TpvVector2.InlineableCreate(MaxRadius,MaxRadius);
  end else begin
   AABB.Min:=TpvVector2.InlineableCreate(Infinity,Infinity);
   AABB.Max:=TpvVector2.InlineableCreate(-Infinity,-Infinity);
   Count:=Min(Max(ceil(abs(aEndAngle-aStartAngle)/(pi*0.125)),8),16);
   for Index:=0 to Count do begin
    SinCos(FloatLerp(aStartAngle-(pi*0.015625),aEndAngle+(pi*0.015625),Index/Count),CosSinValues.y,CosSinValues.x);
    AABB.DirectCombine(aCenter+(CosSinValues*MinRadius));
    AABB.DirectCombine(aCenter+(CosSinValues*MaxRadius));
   end;
   AABB.Min:=AABB.Min-TpvVector2.InlineableCreate(1.0,1.0);
   AABB.Max:=AABB.Max+TpvVector2.InlineableCreate(1.0,1.0);
  end;
 end;
 VertexState:=GetVertexState;
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(AABB.Left,AABB.Top);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircleArcRingSegment and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(AABB.Right,AABB.Top);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircleArcRingSegment and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(AABB.Right,AABB.Bottom);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircleArcRingSegment and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=TpvVector2.InlineableCreate(AABB.Left,AABB.Bottom);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.Null;
 CanvasVertex^.State:=VertexState or ((pcvvaomCircleArcRingSegment and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 result:=self;
end;

function TpvCanvas.DrawFilledCircleArcRingSegment(const aCenterX,aCenterY,aInnerRadius,aOuterRadius,aStartAngle,aEndAngle,aGapThickness:TpvFloat):TpvCanvas;
begin
 result:=DrawFilledCircleArcRingSegment(TpvVector2.InlineableCreate(aCenterX,aCenterY),aInnerRadius,aOuterRadius,aStartAngle,aEndAngle,aGapThickness);
end;

function TpvCanvas.DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aCenter,aBounds:TpvVector2;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas;
var MetaInfo:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
    OldTexture:TObject;
    LocalModelMatrix:TpvMatrix4x4;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 OldTexture:=GetTexture;
 SetTexture(aTexture);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aCenter;
 MetaInfo.zw:=aBounds;
 if aRotationAngle<>0.0 then begin
  LocalModelMatrix:=((TpvMatrix4x4.CreateTranslation(-aCenter)*
                          TpvMatrix4x4.CreateRotateZ(aRotationAngle))*
                         TpvMatrix4x4.CreateTranslation(aCenter))*
                    fState.ModelMatrix;
 end else begin
  LocalModelMatrix:=fState.ModelMatrix;
 end;
 VertexState:=GetVertexState and not ($f shl pvcvsFillStyleShift);
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(LocalModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,0.0,aTextureArrayLayer);
 CanvasVertex^.State:=VertexState or ((pcvvaomSolid and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,-aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(LocalModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(1.0,0.0,aTextureArrayLayer);
 CanvasVertex^.State:=VertexState or ((pcvvaomSolid and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(LocalModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(1.0,1.0,aTextureArrayLayer);
 CanvasVertex^.State:=VertexState or ((pcvvaomSolid and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=aCenter+TpvVector2.InlineableCreate(-aBounds.x,aBounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(LocalModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,1.0,aTextureArrayLayer);
 CanvasVertex^.State:=VertexState or ((pcvvaomSolid and $ff) shl pvcvsObjectModeShift);
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=TpvVector4.Null;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 SetTexture(OldTexture);
 result:=self;
end;

function TpvCanvas.DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas;
begin
 result:=DrawTexturedRectangle(aTexture,TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY),aRotationAngle,aTextureArrayLayer);
end;

function TpvCanvas.DrawTexturedRectangle(const aTexture:TpvVulkanTexture;const aRect:TpvRect;const aRotationAngle:TpvFloat=0.0;const aTextureArrayLayer:TpvInt32=0):TpvCanvas;
begin
 result:=DrawTexturedRectangle(aTexture,aRect.LeftTop+((aRect.RightBottom-aRect.LeftTop)*0.5),(aRect.RightBottom-aRect.LeftTop)*0.5,aRotationAngle,aTextureArrayLayer);
end;

function TpvCanvas.DrawGUIElement(const aGUIElement:TVkInt32;const aFocused:boolean;const aMin,aMax,aMetaMin,aMetaMax:TpvVector2;const aMeta:TpvFloat;const aTransparent:Boolean):TpvCanvas;
var Center,Bounds:TpvVector2;
    MetaInfo,MetaInfo2:TpvVector4;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    CanvasVertex:PpvCanvasVertex;
    OldTexture:TObject;
begin
 Center:=(aMin+aMax)*0.5;
 Bounds:=(aMax-aMin)*0.5;
 SetGUIElementMode(true);
 SetAtlasTexture(nil);
 OldTexture:=GetTexture;
 SetTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 MetaInfo.xy:=aMetaMin;
 MetaInfo.zw:=aMetaMax;
 MetaInfo2.x:=ord(aTransparent) and 1;
 MetaInfo2.y:=0.0;
 MetaInfo2.z:=0.0;
 MetaInfo2.w:=0.0;
 VertexState:=(GetVertexState and not ($f shl pvcvsFillStyleShift)) or ((TpvUInt32(aGUIElement) or (TpvUInt32(ord(aFocused) and 1) shl 7)) shl pvcvsObjectModeShift);
 EnsureSufficientReserveUsableSpace(4,6);
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+0];
 CanvasVertex^.OriginalPosition:=Center+TpvVector2.InlineableCreate(-Bounds.x,-Bounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,0.0,aMeta);
 CanvasVertex^.State:=VertexState;
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+1];
 CanvasVertex^.OriginalPosition:=Center+TpvVector2.InlineableCreate(Bounds.x,-Bounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,0.0,aMeta);
 CanvasVertex^.State:=VertexState;
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+2];
 CanvasVertex^.OriginalPosition:=Center+TpvVector2.InlineableCreate(Bounds.x,Bounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,0.0,aMeta);
 CanvasVertex^.State:=VertexState;
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+3];
 CanvasVertex^.OriginalPosition:=Center+TpvVector2.InlineableCreate(-Bounds.x,Bounds.y);
 CanvasVertex^.Position:=TpvVector3.InlineableCreate(fState.fModelMatrix*CanvasVertex^.OriginalPosition,fState.fZPosition);
 CanvasVertex^.Color:=VertexColor;
 CanvasVertex^.TextureCoord:=TpvVector3.InlineableCreate(0.0,0.0,aMeta);
 CanvasVertex^.State:=VertexState;
 CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
 CanvasVertex^.MetaInfo:=MetaInfo;
 CanvasVertex^.MetaInfo2:=MetaInfo2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+0]:=fCurrentCountVertices+0;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+1]:=fCurrentCountVertices+1;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+2]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+3]:=fCurrentCountVertices+2;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+4]:=fCurrentCountVertices+3;
 fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+5]:=fCurrentCountVertices+0;
 inc(fCurrentCountVertices,4);
 inc(fCurrentCountIndices,6);
 SetTexture(OldTexture);
 result:=self;
end;

function TpvCanvas.DrawGUIElement(const aGUIElement:TVkInt32;const aFocused:boolean;const aMinX,aMinY,aMaxX,aMaxY,aMetaMinX,aMetaMinY,aMetaMaxX,aMetaMaxY:TpvFloat;const aMeta:TpvFloat;const aTransparent:Boolean):TpvCanvas;
begin
 result:=DrawGUIElement(aGUIElement,aFocused,TpvVector2.InlineableCreate(aMinX,aMinY),TpvVector2.InlineableCreate(aMaxX,aMaxY),TpvVector2.InlineableCreate(aMetaMinX,aMetaMinY),TpvVector2.InlineableCreate(aMetaMaxX,aMetaMaxY),aMeta,aTransparent);
end;

function TpvCanvas.DrawShape(const aShape:TpvCanvasShape):TpvCanvas;
var CachePartIndex,VertexIndex,IndexIndex:TpvInt32;
    CachePart:PpvCanvasShapeCachePart;
    CacheVertex:PpvCanvasShapeCacheVertex;
    CanvasVertex:PpvCanvasVertex;
    VertexColor:TpvHalfFloatVector4;
    VertexState:TpvUInt32;
    ModelMatrixIsIdentity:boolean;
    OffsetMatrix:TpvMatrix3x3;
begin
 SetGUIElementMode(false);
 SetAtlasTexture(nil);
 fInternalRenderingMode:=TpvCanvasRenderingMode.Normal;
 VertexColor.r:=fState.fColor.r;
 VertexColor.g:=fState.fColor.g;
 VertexColor.b:=fState.fColor.b;
 VertexColor.a:=fState.fColor.a;
 VertexState:=GetVertexState;
 ModelMatrixIsIdentity:=fState.fModelMatrix=TpvMatrix4x4.Identity;
 OffsetMatrix:=fState.fModelMatrix.ToMatrix3x3;
 for CachePartIndex:=0 to aShape.fCountCacheParts-1 do begin
  CachePart:=@aShape.fCacheParts[CachePartIndex];
  EnsureSufficientReserveUsableSpace(CachePart^.CountVertices,CachePart^.CountIndices);
  if ModelMatrixIsIdentity then begin
   for VertexIndex:=0 to CachePart^.CountVertices-1 do begin
    CacheVertex:=@aShape.fCacheVertices[CachePart^.BaseVertexIndex+VertexIndex];
    CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+VertexIndex];
    CanvasVertex^.OriginalPosition:=CacheVertex^.Position+CacheVertex^.Offset;
    CanvasVertex^.Position:=TpvVector3.InlineableCreate(CanvasVertex^.OriginalPosition,fState.fZPosition);
    CanvasVertex^.Color:=VertexColor;
    CanvasVertex^.TextureCoord:=TpvVector3.Null;
    CanvasVertex^.State:=VertexState or ((CacheVertex^.ObjectMode and $ff) shl pvcvsObjectModeShift);
    CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
    CanvasVertex^.MetaInfo:=CacheVertex^.MetaInfo;
    CanvasVertex^.MetaInfo2:=CacheVertex^.MetaInfo2;
   end;
  end else begin
   for VertexIndex:=0 to CachePart^.CountVertices-1 do begin
    CacheVertex:=@aShape.fCacheVertices[CachePart^.BaseVertexIndex+VertexIndex];
    CanvasVertex:=@fCurrentDestinationVertexBufferPointer^[fCurrentCountVertices+VertexIndex];
    CanvasVertex^.OriginalPosition:=CacheVertex^.Position;
    CanvasVertex^.Position:=TpvVector3.InlineableCreate((fState.fModelMatrix*CacheVertex^.Position)+
                                                        (OffsetMatrix*CacheVertex^.Offset),
                                                        fState.fZPosition);
    CanvasVertex^.Color:=VertexColor;
    CanvasVertex^.TextureCoord:=TpvVector3.Null;
    CanvasVertex^.State:=VertexState or ((CacheVertex^.ObjectMode and $ff) shl pvcvsObjectModeShift);
    CanvasVertex^.ClipRect:=fState.fClipSpaceClipRect;
    CanvasVertex^.MetaInfo:=CacheVertex^.MetaInfo;
    CanvasVertex^.MetaInfo2:=CacheVertex^.MetaInfo2;
    case CacheVertex^.ObjectMode of
     pcvvaomRoundLineCapCircle:begin
      CanvasVertex^.MetaInfo.xy:={fState.fModelMatrix*}CanvasVertex^.MetaInfo.xy;
     end;
     pcvvaomRoundLine:begin
      CanvasVertex^.MetaInfo.xy:={fState.fModelMatrix*}CanvasVertex^.MetaInfo.xy;
      CanvasVertex^.MetaInfo.zw:={fState.fModelMatrix*}CanvasVertex^.MetaInfo.zw;
     end;
    end;
   end;
  end;
  for IndexIndex:=0 to CachePart^.CountIndices-1 do begin
   fCurrentDestinationIndexBufferPointer^[fCurrentCountIndices+IndexIndex]:=(aShape.fCacheIndices[CachePart^.BaseIndexIndex+IndexIndex]-CachePart^.BaseVertexIndex)+fCurrentCountVertices;
  end;
  inc(fCurrentCountVertices,CachePart^.CountVertices);
  inc(fCurrentCountIndices,CachePart^.CountIndices);
 end;
 result:=self;
end;

function TpvCanvas.BeginPath:TpvCanvas;
begin
 fState.fPath.BeginPath;
 result:=self;
end;

function TpvCanvas.EndPath:TpvCanvas;
begin
 fState.fPath.EndPath;
 result:=self;
end;

function TpvCanvas.ClosePath:TpvCanvas;
begin
 fState.fPath.ClosePath;
 result:=self;
end;

function TpvCanvas.MoveTo(const aP0:TpvVector2):TpvCanvas;
begin
 fState.fPath.MoveTo(aP0);
 result:=self;
end;

function TpvCanvas.MoveTo(const aX,aY:TpvFloat):TpvCanvas;
begin
 fState.fPath.MoveTo(TpvVector2.InlineableCreate(aX,aY));
 result:=self;
end;

function TpvCanvas.LineTo(const aP0:TpvVector2):TpvCanvas;
begin
 fState.fPath.LineTo(aP0);
 result:=self;
end;

function TpvCanvas.LineTo(const aX,aY:TpvFloat):TpvCanvas;
begin
 fState.fPath.LineTo(TpvVector2.InlineableCreate(aX,aY));
 result:=self;
end;

function TpvCanvas.QuadraticCurveTo(const aC0,aA0:TpvVector2):TpvCanvas;
begin
 fState.fPath.QuadraticCurveTo(aC0,aA0);
 result:=self;
end;

function TpvCanvas.QuadraticCurveTo(const aCX,aCY,aAX,aAY:TpvFloat):TpvCanvas;
begin
 fState.fPath.QuadraticCurveTo(TpvVector2.InlineableCreate(aCX,aCY),TpvVector2.InlineableCreate(aAX,aAY));
 result:=self;
end;

function TpvCanvas.CubicCurveTo(const aC0,aC1,aA0:TpvVector2):TpvCanvas;
begin
 fState.fPath.CubicCurveTo(aC0,aC1,aA0);
 result:=self;
end;

function TpvCanvas.CubicCurveTo(const aC0X,aC0Y,aC1X,aC1Y,aAX,aAY:TpvFloat):TpvCanvas;
begin
 fState.fPath.CubicCurveTo(TpvVector2.InlineableCreate(aC0X,aC0Y),TpvVector2.InlineableCreate(aC1X,aC1Y),TpvVector2.InlineableCreate(aAX,aAY));
 result:=self;
end;

function TpvCanvas.ArcTo(const aP0,aP1:TpvVector2;const aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.ArcTo(aP0,aP1,aRadius);
 result:=self;
end;

function TpvCanvas.ArcTo(const aP0X,aP0Y,aP1X,aP1Y,aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.ArcTo(TpvVector2.InlineableCreate(aP0X,aP0Y),TpvVector2.InlineableCreate(aP1X,aP1Y),aRadius);
 result:=self;
end;

function TpvCanvas.Arc(const aCenter:TpvVector2;const aRadius,aAngle0,aAngle1:TpvFloat;const aCounterClockwise:boolean):TpvCanvas;
begin
 fState.fPath.Arc(aCenter,aRadius,aAngle0,aAngle1,aCounterClockwise);
 result:=self;
end;

function TpvCanvas.Arc(const aCenterX,aCenterY,aRadius,aAngle0,aAngle1:TpvFloat;const aCounterClockwise:boolean):TpvCanvas;
begin
 fState.fPath.Arc(TpvVector2.InlineableCreate(aCenterX,aCenterY),aRadius,aAngle0,aAngle1,aCounterClockwise);
 result:=self;
end;

function TpvCanvas.Ellipse(const aCenter,aRadius:TpvVector2):TpvCanvas;
begin
 fState.fPath.Ellipse(aCenter,aRadius);
 result:=self;
end;

function TpvCanvas.Ellipse(const aCenterX,aCenterY,aRadiusX,aRadiusY:TpvFloat):TpvCanvas;
begin
 fState.fPath.Ellipse(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aRadiusX,aRadiusY));
 result:=self;
end;

function TpvCanvas.Circle(const aCenter:TpvVector2;const aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.Circle(aCenter,aRadius);
 result:=self;
end;

function TpvCanvas.Circle(const aCenterX,aCenterY,aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.Circle(TpvVector2.InlineableCreate(aCenterX,aCenterY),aRadius);
 result:=self;
end;

function TpvCanvas.Rectangle(const aCenter,aBounds:TpvVector2):TpvCanvas;
begin
 fState.fPath.Rectangle(aCenter,aBounds);
 result:=self;
end;

function TpvCanvas.Rectangle(const aCenterX,aCenterY,aBoundX,aBoundY:TpvFloat):TpvCanvas;
begin
 fState.fPath.Rectangle(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY));
 result:=self;
end;

function TpvCanvas.Rectangle(const aRect:TpvRect):TpvCanvas;
begin
 fState.fPath.Rectangle(aRect.LeftTop+((aRect.RightBottom-aRect.LeftTop)*0.5),(aRect.RightBottom-aRect.LeftTop)*0.5);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(aCenter,aBounds,aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY),aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aRect:TpvRect;const aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(aRect.LeftTop+((aRect.RightBottom-aRect.LeftTop)*0.5),(aRect.RightBottom-aRect.LeftTop)*0.5,aRadiusTopLeft,aRadiusTopRight,aRadiusBottomLeft,aRadiusBottomRight);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aCenter,aBounds:TpvVector2;const aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(aCenter,aBounds,aRadius);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aCenterX,aCenterY,aBoundX,aBoundY,aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(TpvVector2.InlineableCreate(aCenterX,aCenterY),TpvVector2.InlineableCreate(aBoundX,aBoundY),aRadius);
 result:=self;
end;

function TpvCanvas.RoundedRectangle(const aRect:TpvRect;const aRadius:TpvFloat):TpvCanvas;
begin
 fState.fPath.RoundedRectangle(aRect.LeftTop+((aRect.RightBottom-aRect.LeftTop)*0.5),(aRect.RightBottom-aRect.LeftTop)*0.5,aRadius,aRadius,aRadius,aRadius);
 result:=self;
end;

function TpvCanvas.Stroke:TpvCanvas;
begin
 fShape.StrokeFromPath(fState.fPath,fState,self);
 result:=DrawShape(fShape);
end;

function TpvCanvas.Fill:TpvCanvas;
begin
 fShape.FillFromPath(fState.fPath,fState,self);
 result:=DrawShape(fShape);
end;

function TpvCanvas.GetStrokeShape:TpvCanvasShape;
begin
 result:=TpvCanvasShape.Create;
 result.StrokeFromPath(fState.fPath,fState,self);
end;

function TpvCanvas.GetFillShape:TpvCanvasShape;
begin
 result:=TpvCanvasShape.Create;
 result.FillFromPath(fState.fPath,fState,self);
end;

end.
