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
unit PasVulkan.Font;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses SysUtils,
     Classes,
     Math,
     PUCU,
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Framework,
     PasVulkan.VectorPath,
     PasVulkan.SignedDistanceField2D,
     PasVulkan.TrueTypeFont,
     PasVulkan.Sprites,
     PasVulkan.Streams;

type EpvFont=class(Exception);

     EpvFontInvalidFormat=class(EpvFont);

     TpvFontCodePointBitmap=array of TpvUInt32;

     PpvFontCharacterRange=^TpvFontCharacterRange;
     TpvFontCharacterRange=set of AnsiChar;

     PpvFontCodePointRange=^TpvFontCodePointRange;
     TpvFontCodePointRange=record
      public
       FromCodePoint:TpvUInt32;
       ToCodePoint:TpvUInt32;
       constructor Create(const aFromCodePoint,aToCodePoint:TpvUInt32); overload;
       constructor Create(const aFromCodePoint,aToCodePoint:WideChar); overload;
       constructor Create(const aCharacterRange:TpvFontCharacterRange); overload;
     end;

     TpvFontCodePointRanges=array of TpvFontCodePointRange;

     PpvFontGlyphSideBearings=^TpvFontGlyphSideBearings;
     TpvFontGlyphSideBearings=packed record
      case TpvInt32 of
       0:(
        Left:TpvFloat;
        Top:TpvFloat;
        Right:TpvFloat;
        Bottom:TpvFloat;
       );
       1:(
        LeftTop:TpvVector2;
        RightBottom:TpvVector2;
       );
       2:(
        Rect:TpvRect;
       );
     end;

     PpvFontGlyph=^TpvFontGlyph;
     TpvFontGlyph=record
      Advance:TpvVector2;
      Bounds:TpvRect;
      SideBearings:TpvFontGlyphSideBearings;
      Rect:TpvRect;
      Offset:TpvVector2;
      Size:TpvVector2;
      Width:TpvInt32;
      Height:TpvInt32;
      Sprite:TpvSprite;
     end;

     TPpvFontGlyphs=array of PpvFontGlyph;

     TpvFontGlyphs=array of TpvFontGlyph;

     PpvFontCodePointGlyphPair=^TpvFontCodePointGlyphPair;
     TpvFontCodePointGlyphPair=record
      CodePoint:TpvUInt32;
      Glyph:TpvInt32;
     end;

     TpvFontCodePointGlyphPairs=array of TpvFontCodePointGlyphPair;

     PpvFontKerningPair=^TpvFontKerningPair;
     TpvFontKerningPair=record
      Left:TpvUInt32;
      Right:TpvUInt32;
      Horizontal:TpvInt32;
      Vertical:TpvInt32;
     end;

     TpvFontKerningPairs=array of TpvFontKerningPair;

     TpvFontKerningPairVectors=array of TpvVector2;

     PpvFontSignedDistanceFieldJob=^TpvFontSignedDistanceFieldJob;
     TpvFontSignedDistanceFieldJob=record
      DistanceField:PpvSignedDistanceField2D;
      TrimmedHullVectors:PpvSpriteTrimmedHullVectors;
      OffsetX:TpvDouble;
      OffsetY:TpvDouble;
      MultiChannel:boolean;
      PolygonBuffer:TpvTrueTypeFontPolygonBuffer;
     end;

     TpvFontSignedDistanceFieldJobs=array of TpvFontSignedDistanceFieldJob;

     TpvFontInt64HashMap=class(TpvHashMap<TpvInt64,TpvInt64>);

     PpvFontCodePointToGlyphSubMap=^TpvFontCodePointToGlyphSubMap;
     TpvFontCodePointToGlyphSubMap=array[0..1023] of TpvInt32; // 4kb

     PpvFontCodePointToGlyphMap=^TpvFontCodePointToGlyphMap;
     TpvFontCodePointToGlyphMap=array[0..16383] of PpvFontCodePointToGlyphSubMap; // 64kb on 32-bit targets and 128kb on 64-bit targets

     TpvFontDrawSprite=procedure(const aSprite:TpvSprite;const aSrcRect,aDestRect:TpvRect) of object;

     PpvFontTextGlyphInfo=^TpvFontTextGlyphInfo;
     TpvFontTextGlyphInfo=record
      TextIndex:TpvInt32;
      CodePoint:TpvInt32;
      LastGlyph:TpvInt32;
      Glyph:TpvInt32;
      Kerning:TpvVector2;
      Advance:TpvVector2;
      Offset:TpvVector2;
      Position:TpvVector2;
      Size:TpvVector2;
     end;

     TpvFontTextGlyphInfoArray=array of TpvFontTextGlyphInfo;

     TpvFont=class
      private
       const FileFormatGUID:TGUID='{2405B44F-8747-4A17-AD91-83DAD9E48941}';
      private
       fSpriteAtlas:TpvSpriteAtlas;
       fTargetPPI:TpvInt32;
       fUnitsPerEm:TpvInt32;
       fHorizontalAscender:TpvInt32;
       fHorizontalDescender:TpvInt32;
       fHorizontalLineGap:TpvInt32;
       fVerticalAscender:TpvInt32;
       fVerticalDescender:TpvInt32;
       fVerticalLineGap:TpvInt32;
       fAdvanceWidthMax:TpvInt32;
       fAdvanceHeightMax:TpvInt32;
       fBaseScaleFactor:TpvFloat;
       fInverseBaseScaleFactor:TpvFloat;
       fBaseSize:TpvFloat;
       fInverseBaseSize:TpvFloat;
       fMinX:TpvFloat;
       fMinY:TpvFloat;
       fMaxX:TpvFloat;
       fMaxY:TpvFloat;
       fMinimumCodePoint:TpvUInt32;
       fMaximumCodePoint:TpvUInt32;
       fCodePointBitmap:TpvFontCodePointBitmap;
       fGlyphs:TpvFontGlyphs;
       fCodePointGlyphPairs:TpvFontCodePointGlyphPairs;
       fKerningPairs:TpvFontKerningPairs;
       fKerningPairVectors:TpvFontKerningPairVectors;
       fCodePointToGlyphMap:TpvFontCodePointToGlyphMap;
       fKerningPairHashMap:TpvFontInt64HashMap;
       fSignedDistanceFieldJobs:TpvFontSignedDistanceFieldJobs;
       fSignedDistanceFieldVariant:TpvSignedDistanceField2DVariant;
       fMonospaceSize:TpvVector2;
       fHasMonospaceSize:boolean;
       procedure CalculateMonospaceSize;
       procedure GenerateSignedDistanceField(var aSignedDistanceField:TpvSignedDistanceField2D;const aTrimmedHullVectors:PpvSpriteTrimmedHullVectors;const aOffsetX,aOffsetY:TpvDouble;const aMultiChannel:boolean;const aPolygonBuffer:TpvTrueTypeFontPolygonBuffer;const aFillRule:TpvInt32;const aSDFVariant:TpvSignedDistanceField2DVariant);
       procedure GenerateSignedDistanceFieldParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TVkPointer;const FromIndex,ToIndex:TPasMPNativeInt);
      public
       constructor Create(const aSpriteAtlas:TpvSpriteAtlas;const aTargetPPI:TpvInt32=72;const aBaseSize:TpvFloat=12.0); reintroduce;
       constructor CreateFromTrueTypeFont(const aSpriteAtlas:TpvSpriteAtlas;const aTrueTypeFont:TpvTrueTypeFont;const aCodePointRanges:array of TpvFontCodePointRange;const aAutomaticTrim:boolean=true;const aPadding:TpvInt32=2;const aTrimPadding:TpvInt32=1;const aConvexHullTrimming:boolean=false;const aSignedDistanceFieldVariant:TpvSignedDistanceField2DVariant=TpvSignedDistanceField2DVariant.Default);
       constructor CreateFromStream(const aSpriteAtlas:TpvSpriteAtlas;const aStream:TStream);
       constructor CreateFromFile(const aSpriteAtlas:TpvSpriteAtlas;const aFileName:string);
       destructor Destroy; override;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
       function GetScaleFactor(const aSize:TpvFloat):TpvFloat;
       function TextWidth(const aText:TpvUTF8String;const aSize:TpvFloat):TpvFloat;
       function TextHeight(const aText:TpvUTF8String;const aSize:TpvFloat):TpvFloat;
       function TextSize(const aText:TpvUTF8String;const aSize:TpvFloat):TpvVector2;
       function CodePointWidth(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvFloat;
       function CodePointHeight(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvFloat;
       function CodePointSize(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvVector2;
       function MonospaceSize(const aSize:TpvFloat):TpvVector2;
       function RowHeight(const aPercent:TpvFloat;const aSize:TpvFloat):TpvFloat;
       function LineSpace(const aPercent:TpvFloat;const aSize:TpvFloat):TpvFloat;
       procedure GetTextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat;var aRects:TpvRectArray;out aCountRects:TpvInt32);
       procedure GetTextGlyphInfos(const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat;var aTextGlyphInfos:TpvFontTextGlyphInfoArray;out aCountTextGlyphInfos:TpvInt32);
       procedure Draw(const aDrawSprite:TpvFontDrawSprite;const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat); overload;
       procedure Draw(const aCanvas:TObject;const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat); overload;
       procedure DrawCodePoint(const aDrawSprite:TpvFontDrawSprite;const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2;const aSize:TpvFloat); overload;
       procedure DrawCodePoint(const aCanvas:TObject;const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2;const aSize:TpvFloat); overload;
      published
       property HorizontalAscender:TpvInt32 read fHorizontalAscender;
       property HorizontalDescender:TpvInt32 read fHorizontalDescender;
       property HorizontalLineGap:TpvInt32 read fHorizontalLineGap;
       property VerticalAscender:TpvInt32 read fVerticalAscender;
       property VerticalDescender:TpvInt32 read fVerticalDescender;
       property VerticalLineGap:TpvInt32 read fVerticalLineGap;
       property AdvanceWidthMax:TpvInt32 read fAdvanceWidthMax;
       property AdvanceHeightMax:TpvInt32 read fAdvanceHeightMax;
       property BaseSize:TpvFloat read fBaseSize;
       property MinX:TpvFloat read fMinX;
       property MinY:TpvFloat read fMinY;
       property MaxX:TpvFloat read fMaxX;
       property MaxY:TpvFloat read fMaxY;
     end;

implementation

uses PasDblStrUtils,
     PasVulkan.XML,
     PasVulkan.Utils,
     PasVulkan.Canvas,
     PasVulkan.ConvexHullGenerator2D;

constructor TpvFontCodePointRange.Create(const aFromCodePoint,aToCodePoint:TpvUInt32);
begin
 FromCodePoint:=Min(aFromCodePoint,aToCodePoint);
 ToCodePoint:=Max(aFromCodePoint,aToCodePoint);
end;

constructor TpvFontCodePointRange.Create(const aFromCodePoint,aToCodePoint:WideChar);
begin
 FromCodePoint:=Min(TpvUInt16(WideChar(aFromCodePoint)),TpvUInt16(WideChar(aToCodePoint)));
 ToCodePoint:=Max(TpvUInt16(WideChar(aFromCodePoint)),TpvUInt16(WideChar(aToCodePoint)));
end;

constructor TpvFontCodePointRange.Create(const aCharacterRange:TpvFontCharacterRange);
var Index:AnsiChar;
begin
 FromCodePoint:=High(TpvUInt32);
 ToCodePoint:=Low(TpvUInt32);
 for Index:=Low(AnsiChar) to High(AnsiChar) do begin
  if Index in aCharacterRange then begin
   FromCodePoint:=TpvUInt8(AnsiChar(Index));
   break;
  end;
 end;
 for Index:=High(AnsiChar) downto Low(AnsiChar) do begin
  if Index in aCharacterRange then begin
   ToCodePoint:=TpvUInt8(AnsiChar(Index));
   break;
  end;
 end;
end;

function CompareVulkanFontGlyphsByArea(const a,b:TpvPointer):TpvInt32;
begin
 result:=(PpvFontGlyph(b)^.Width*PpvFontGlyph(b)^.Height)-(PpvFontGlyph(a)^.Width*PpvFontGlyph(a)^.Height);
end;

function CompareVulkanFontKerningPairs(const a,b:TpvPointer):TpvInt32;
begin
 result:=TpvInt64(PpvFontKerningPair(a)^.Left)-TpvInt64(PpvFontKerningPair(b)^.Left);
 if result=0 then begin
  result:=TpvInt64(PpvFontKerningPair(a)^.Right)-TpvInt64(PpvFontKerningPair(b)^.Right);
 end;
end;

constructor TpvFont.Create(const aSpriteAtlas:TpvSpriteAtlas;const aTargetPPI:TpvInt32=72;const aBaseSize:TpvFloat=12.0);
begin

 inherited Create;

 fSpriteAtlas:=aSpriteAtlas;

 fTargetPPI:=aTargetPPI;

 fUnitsPerEm:=72;

 fHorizontalAscender:=0;

 fHorizontalDescender:=0;

 fHorizontalLineGap:=0;

 fVerticalAscender:=0;

 fVerticalDescender:=0;

 fVerticalLineGap:=0;

 fAdvanceWidthMax:=0;

 fAdvanceHeightMax:=0;

 fBaseScaleFactor:=1.0;

 fInverseBaseScaleFactor:=1.0;

 fBaseSize:=aBaseSize;

 fInverseBaseSize:=1.0/fBaseSize;

 fMinX:=0.0;
 fMinY:=0.0;
 fMaxX:=0.0;
 fMaxY:=0.0;

 fMinimumCodePoint:=High(TpvUInt32);
 fMaximumCodePoint:=Low(TpvUInt32);

 fCodePointBitmap:=nil;

 fGlyphs:=nil;

 fCodePointGlyphPairs:=nil;

 fKerningPairs:=nil;

 fKerningPairVectors:=nil;

 FillChar(fCodePointToGlyphMap,SizeOf(TpvFontCodePointToGlyphMap),#0);

 fKerningPairHashMap:=TpvFontInt64HashMap.Create(-1);

 fSignedDistanceFieldJobs:=nil;

 fHasMonospaceSize:=false;

end;

constructor TpvFont.CreateFromTrueTypeFont(const aSpriteAtlas:TpvSpriteAtlas;const aTrueTypeFont:TpvTrueTypeFont;const aCodePointRanges:array of TpvFontCodePointRange;const aAutomaticTrim:boolean;const aPadding:TpvInt32;const aTrimPadding:TpvInt32;const aConvexHullTrimming:boolean;const aSignedDistanceFieldVariant:TpvSignedDistanceField2DVariant);
const GlyphMetaDataScaleFactor=1.0;
      GlyphRasterizationScaleFactor=1.0/256.0;
      GlyphRasterizationToMetaScaleFactor=1.0/4.0;
var Index,TTFGlyphIndex,GlyphIndex,OtherGlyphIndex,CountGlyphs,
    CodePointGlyphPairIndex,CountCodePointGlyphPairs,
    TrueTypeFontKerningIndex,TrueTypeFontKerningPairIndex,
    KerningPairIndex,CountKerningPairs,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    CountCodePointRanges:TpvSizeInt;
    x0,y0,x1,y1:TpvDouble;
    KerningPairDoubleIndex:TpvUInt64;
    Int64Value:TpvInt64;
    CodePointRange:PpvFontCodePointRange;
    CodePointIndex,BitmapCodePointIndex,
    OtherCodePointIndex:TpvUInt32;
    CodePointBitmap,NewCodePointBitmap:TpvFontCodePointBitmap;
    CodePointToTTFGlyphHashMap:TpvFontInt64HashMap;
    TTFGlyphToGlyphHashMap:TpvFontInt64HashMap;
    GlyphToTTFGlyphHashMap:TpvFontInt64HashMap;
    KerningPairHashMap:TpvFontInt64HashMap;
    Glyph:PpvFontGlyph;
    GlyphBuffer:TpvTrueTypeFontGlyphBuffer;
    PolygonBuffers:TpvTrueTypeFontPolygonBuffers;
    SortedGlyphs:TPpvFontGlyphs;
    DistanceField:TpvSignedDistanceField2D;
    TrueTypeFontKerningTable:PpvTrueTypeFontKerningTable;
    TrueTypeFontKerningPair:PpvTrueTypeFontKerningPair;
    CodePointGlyphPair:PpvFontCodePointGlyphPair;
    KerningPair:PpvFontKerningPair;
    GlyphDistanceField:PpvSignedDistanceField2D;
    GlyphDistanceFields:TpvSignedDistanceField2DArray;
    GlyphTrimmedHullVectors:TpvSpriteTrimmedHullVectorsArray;
    PasMPInstance:TPasMP;
    GlyphDistanceFieldJob:PpvFontSignedDistanceFieldJob;
    UniqueID:string;
    GUID:TGUID;
    CodePointRanges:array of TpvFontCodePointRange;
begin

 Create(aSpriteAtlas,aTrueTypeFont.TargetPPI,aTrueTypeFont.Size);

 PasMPInstance:=TPasMP.GetGlobalInstance;

 fUnitsPerEm:=aTrueTypeFont.GetUnitsPerEm;

 fHorizontalAscender:=aTrueTypeFont.HorizontalDescender;

 fHorizontalDescender:=aTrueTypeFont.HorizontalDescender;

 fHorizontalLineGap:=aTrueTypeFont.HorizontalLineGap;

 fSignedDistanceFieldVariant:=aSignedDistanceFieldVariant;

 if (aTrueTypeFont.VerticalAscender<>0) or
    (aTrueTypeFont.VerticalDescender<>0) or
    (aTrueTypeFont.VerticalLineGap<>0) then begin

  fVerticalAscender:=aTrueTypeFont.VerticalAscender;

  fVerticalDescender:=aTrueTypeFont.VerticalDescender;

  fVerticalLineGap:=aTrueTypeFont.VerticalLineGap;

 end else begin

  fVerticalAscender:=aTrueTypeFont.OS2Ascender;

  fVerticalDescender:=aTrueTypeFont.OS2Descender;

  fVerticalLineGap:=aTrueTypeFont.OS2LineGap;

 end;

 fAdvanceWidthMax:=aTrueTypeFont.AdvanceWidthMax;

 fAdvanceHeightMax:=aTrueTypeFont.AdvanceHeightMax;

 fBaseScaleFactor:=aTrueTypeFont.GetScaleFactor;

 fInverseBaseScaleFactor:=1.0/fBaseScaleFactor;

 fMinX:=aTrueTypeFont.MinX;
 fMinY:=aTrueTypeFont.MinY;
 fMaxX:=aTrueTypeFont.MaxX;
 fMaxY:=aTrueTypeFont.MaxY;

 SetLength(CodePointRanges,length(aCodePointRanges));
 if length(CodePointRanges)>0 then begin
  Move(aCodePointRanges[0],CodePointRanges[0],length(CodePointRanges)*SizeOf(TpvFontCodePointRange));
 end;

 if length(CodePointRanges)=0 then begin
  CodePointRange:=nil;
  CountCodePointRanges:=0;
  try
   for CodePointIndex:=$000000 to $10ffff do begin
    GlyphIndex:=aTrueTypeFont.GetGlyphIndex(CodePointIndex);
    if (GlyphIndex>0) or (GlyphIndex<aTrueTypeFont.CountGlyphs) then begin
     if assigned(CodePointRange) and
        ((CodePointRange^.ToCodePoint+1)=CodePointIndex) then begin
      inc(CodePointRange^.ToCodePoint);
     end else begin
      inc(CountCodePointRanges);
      if length(CodePointRanges)<CountCodePointRanges then begin
       SetLength(CodePointRanges,CountCodePointRanges*2);
      end;
      CodePointRange:=@CodePointRanges[CountCodePointRanges-1];
      CodePointRange^.FromCodePoint:=CodePointIndex;
      CodePointRange^.ToCodePoint:=CodePointIndex;
     end;
    end;
   end;
  finally
   SetLength(CodePointRanges,CountCodePointRanges);
  end;
 end;

 for Index:=low(CodePointRanges) to high(CodePointRanges) do begin
  CodePointRange:=@CodePointRanges[Index];
  fMinimumCodePoint:=Min(fMinimumCodePoint,Min(CodePointRange^.FromCodePoint,CodePointRange^.ToCodePoint));
  fMaximumCodePoint:=Max(fMaximumCodePoint,Max(CodePointRange^.FromCodePoint,CodePointRange^.ToCodePoint));
 end;

 if fMinimumCodePoint<=fMaximumCodePoint then begin

  SetLength(CodePointBitmap,((fMaximumCodePoint-fMinimumCodePoint)+32) shr 5);

  FillChar(CodePointBitmap[0],length(CodePointBitmap)*SizeOf(TpvUInt32),#0);

  for Index:=low(CodePointRanges) to high(CodePointRanges) do begin
   CodePointRange:=@CodePointRanges[Index];
   for CodePointIndex:=Min(CodePointRange^.FromCodePoint,CodePointRange^.ToCodePoint) to Max(CodePointRange^.FromCodePoint,CodePointRange^.ToCodePoint) do begin
    BitmapCodePointIndex:=CodePointIndex-fMinimumCodePoint;
    CodePointBitmap[BitmapCodePointIndex shr 5]:=CodePointBitmap[BitmapCodePointIndex shr 5] or (TpvUInt32(1) shl (BitmapCodePointIndex and 31));
   end;
  end;

  TTFGlyphToGlyphHashMap:=TpvFontInt64HashMap.Create(-1);
  try

   GlyphToTTFGlyphHashMap:=TpvFontInt64HashMap.Create(-1);
   try

    // Collect used glyphs
    CodePointToTTFGlyphHashMap:=TpvFontInt64HashMap.Create(-1);
    try
     CountGlyphs:=0;
     CountCodePointGlyphPairs:=0;
     try
      for CodePointIndex:=fMinimumCodePoint to fMaximumCodePoint do begin
       BitmapCodePointIndex:=CodePointIndex-fMinimumCodePoint;
       if (CodePointBitmap[BitmapCodePointIndex shr 5] and (TpvUInt32(1) shl (BitmapCodePointIndex and 31)))<>0 then begin
        TTFGlyphIndex:=aTrueTypeFont.GetGlyphIndex(CodePointIndex);
        if (TTFGlyphIndex>0) and (TTFGlyphIndex<aTrueTypeFont.CountGlyphs) then begin
         if not CodePointToTTFGlyphHashMap.ExistKey(CodePointIndex) then begin
          CodePointToTTFGlyphHashMap.Add(CodePointIndex,TTFGlyphIndex);
          if TTFGlyphToGlyphHashMap.TryGet(TTFGlyphIndex,Int64Value) then begin
           GlyphIndex:=Int64Value;
          end else begin
           GlyphIndex:=CountGlyphs;
           inc(CountGlyphs);
           TTFGlyphToGlyphHashMap.Add(TTFGlyphIndex,GlyphIndex);
           GlyphToTTFGlyphHashMap.Add(GlyphIndex,TTFGlyphIndex);
          end;
          CodePointMapMainIndex:=CodePointIndex shr 10;
          CodePointMapSubIndex:=CodePointIndex and $3ff;
          if CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap) then begin
           if not assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
            GetMem(fCodePointToGlyphMap[CodePointMapMainIndex],SizeOf(TpvFontCodePointToGlyphSubMap));
            FillChar(fCodePointToGlyphMap[CodePointMapMainIndex]^,SizeOf(TpvFontCodePointToGlyphSubMap),$ff);
           end;
           fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex]:=GlyphIndex;
          end;
          CodePointGlyphPairIndex:=CountCodePointGlyphPairs;
          inc(CountCodePointGlyphPairs);
          if length(fCodePointGlyphPairs)<CountCodePointGlyphPairs then begin
           SetLength(fCodePointGlyphPairs,CountCodePointGlyphPairs*2);
          end;
          CodePointGlyphPair:=@fCodePointGlyphPairs[CodePointGlyphPairIndex];
          CodePointGlyphPair^.CodePoint:=CodePointIndex;
          CodePointGlyphPair^.Glyph:=GlyphIndex;
         end;
        end;
       end else begin
        CodePointBitmap[BitmapCodePointIndex shr 5]:=CodePointBitmap[BitmapCodePointIndex shr 5] and not (TpvUInt32(1) shl (BitmapCodePointIndex and 31));
       end;
      end;
     finally
      SetLength(fGlyphs,CountGlyphs);
      SetLength(fCodePointGlyphPairs,CountCodePointGlyphPairs);
     end;
    finally
     CodePointToTTFGlyphHashMap.Free;
    end;

    for CodePointIndex:=fMinimumCodePoint to fMaximumCodePoint do begin
     BitmapCodePointIndex:=CodePointIndex-fMinimumCodePoint;
     if (CodePointBitmap[BitmapCodePointIndex shr 5] and (TpvUInt32(1) shl (BitmapCodePointIndex and 31)))<>0 then begin
      if fMinimumCodePoint<>CodePointIndex then begin
       SetLength(NewCodePointBitmap,((fMaximumCodePoint-CodePointIndex)+32) shr 5);
       FillChar(NewCodePointBitmap[0],length(NewCodePointBitmap)*SizeOf(TpvUInt32),#0);
       for OtherCodePointIndex:=CodePointIndex to fMaximumCodePoint do begin
        BitmapCodePointIndex:=OtherCodePointIndex-fMinimumCodePoint;
        if (CodePointBitmap[BitmapCodePointIndex shr 5] and (TpvUInt32(1) shl (BitmapCodePointIndex and 31)))<>0 then begin
         BitmapCodePointIndex:=OtherCodePointIndex-CodePointIndex;
         CodePointBitmap[BitmapCodePointIndex shr 5]:=CodePointBitmap[BitmapCodePointIndex shr 5] or (TpvUInt32(1) shl (BitmapCodePointIndex and 31));
        end;
       end;
       fMinimumCodePoint:=CodePointIndex;
       CodePointBitmap:=NewCodePointBitmap;
       NewCodePointBitmap:=nil;
      end;
      break;
     end;
    end;

    for CodePointIndex:=fMaximumCodePoint downto fMinimumCodePoint do begin
     BitmapCodePointIndex:=CodePointIndex-fMinimumCodePoint;
     if (CodePointBitmap[BitmapCodePointIndex shr 5] and (TpvUInt32(1) shl (BitmapCodePointIndex and 31)))<>0 then begin
      if fMaximumCodePoint<>CodePointIndex then begin
       fMaximumCodePoint:=CodePointIndex;
       SetLength(CodePointBitmap,((fMaximumCodePoint-fMinimumCodePoint)+32) shr 5);
      end;
      break;
     end;
    end;

    // Convert glyph data and get polygon data
    PolygonBuffers:=nil;
    try

     SetLength(PolygonBuffers,CountGlyphs);

     for GlyphIndex:=0 to CountGlyphs-1 do begin

      Glyph:=@fGlyphs[GlyphIndex];

      FillChar(Glyph^,SizeOf(TpvFontGlyph),#0);

      if GlyphToTTFGlyphHashMap.TryGet(GlyphIndex,Int64Value) then begin

       TTFGlyphIndex:=Int64Value;

       Glyph^.Advance.x:=aTrueTypeFont.GetGlyphAdvanceWidth(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.Advance.y:=aTrueTypeFont.GetGlyphAdvanceHeight(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.SideBearings.Left:=aTrueTypeFont.GetGlyphLeftSideBearing(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.SideBearings.Top:=aTrueTypeFont.GetGlyphTopSideBearing(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.SideBearings.Right:=aTrueTypeFont.GetGlyphRightSideBearing(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.SideBearings.Bottom:=aTrueTypeFont.GetGlyphBottomSideBearing(TTFGlyphIndex)*GlyphMetaDataScaleFactor;
       Glyph^.Bounds.Left:=aTrueTypeFont.Glyphs[TTFGlyphIndex].Bounds.XMin*GlyphMetaDataScaleFactor;
       Glyph^.Bounds.Top:=aTrueTypeFont.Glyphs[TTFGlyphIndex].Bounds.YMin*GlyphMetaDataScaleFactor;
       Glyph^.Bounds.Right:=aTrueTypeFont.Glyphs[TTFGlyphIndex].Bounds.XMax*GlyphMetaDataScaleFactor;
       Glyph^.Bounds.Bottom:=aTrueTypeFont.Glyphs[TTFGlyphIndex].Bounds.YMax*GlyphMetaDataScaleFactor;

       GlyphBuffer.Points:=nil;
       PolygonBuffers[GlyphIndex].Commands:=nil;
       try

        if aTrueTypeFont.IsPostScriptGlyph(TTFGlyphIndex) then begin

         aTrueTypeFont.ResetPolygonBuffer(PolygonBuffers[GlyphIndex]);
         aTrueTypeFont.FillPostScriptPolygonBuffer(PolygonBuffers[GlyphIndex],TTFGlyphIndex);

        end else begin

         aTrueTypeFont.ResetGlyphBuffer(GlyphBuffer);
         aTrueTypeFont.FillGlyphBuffer(GlyphBuffer,TTFGlyphIndex);

         aTrueTypeFont.ResetPolygonBuffer(PolygonBuffers[GlyphIndex]);
         aTrueTypeFont.FillPolygonBuffer(PolygonBuffers[GlyphIndex],GlyphBuffer);

        end;

        aTrueTypeFont.GetPolygonBufferBounds(PolygonBuffers[GlyphIndex],x0,y0,x1,y1);

        Glyph^.Rect.Left:=x0*GlyphRasterizationToMetaScaleFactor;
        Glyph^.Rect.Top:=y0*GlyphRasterizationToMetaScaleFactor;
        Glyph^.Rect.Right:=x1*GlyphRasterizationToMetaScaleFactor;
        Glyph^.Rect.Bottom:=y1*GlyphRasterizationToMetaScaleFactor;

        Glyph^.Offset.x:=(x0*GlyphRasterizationScaleFactor)-(VulkanDistanceField2DSpreadValue*2.0);
        Glyph^.Offset.y:=(y0*GlyphRasterizationScaleFactor)-(VulkanDistanceField2DSpreadValue*2.0);

        Glyph^.Width:=Max(1,ceil(((x1-x0)*GlyphRasterizationScaleFactor)+(VulkanDistanceField2DSpreadValue*4.0)));
        Glyph^.Height:=Max(1,ceil(((y1-y0)*GlyphRasterizationScaleFactor)+(VulkanDistanceField2DSpreadValue*4.0)));

        Glyph^.Size:=TpvVector2.Create(Glyph^.Width,Glyph^.Height);

       finally
        GlyphBuffer.Points:=nil;
       end;

      end;
     end;

     GlyphDistanceFields:=nil;
     try

      SetLength(GlyphDistanceFields,CountGlyphs);

      GlyphTrimmedHullVectors:=nil;
      try
       SetLength(GlyphTrimmedHullVectors,CountGlyphs);

       fSignedDistanceFieldJobs:=nil;
       try

        SetLength(fSignedDistanceFieldJobs,CountGlyphs);

        // Rasterize glyph signed distance field sprites
        for GlyphIndex:=0 to CountGlyphs-1 do begin
         GlyphTrimmedHullVectors[GlyphIndex]:=nil;
         Glyph:=@fGlyphs[GlyphIndex];
         GlyphDistanceField:=@GlyphDistanceFields[GlyphIndex];
         GlyphDistanceField^.Width:=Max(1,Glyph^.Width);
         GlyphDistanceField^.Height:=Max(1,Glyph^.Height);
         GlyphDistanceField^.Pixels:=nil;
         SetLength(GlyphDistanceField^.Pixels,GlyphDistanceField^.Width*GlyphDistanceField^.Height);
         GlyphDistanceFieldJob:=@fSignedDistanceFieldJobs[GlyphIndex];
         GlyphDistanceFieldJob^.DistanceField:=GlyphDistanceField;
         if aAutomaticTrim and aConvexHullTrimming then begin
          GlyphDistanceFieldJob^.TrimmedHullVectors:=@GlyphTrimmedHullVectors[GlyphIndex];
         end else begin
          GlyphDistanceFieldJob^.TrimmedHullVectors:=nil;
         end;
         GlyphDistanceFieldJob^.OffsetX:=-Glyph^.Offset.x;
         GlyphDistanceFieldJob^.OffsetY:=-Glyph^.Offset.y;
         GlyphDistanceFieldJob^.MultiChannel:=false;
         GlyphDistanceFieldJob^.PolygonBuffer:=PolygonBuffers[GlyphIndex];
        end;

        if CountGlyphs>0 then begin
         PasMPInstance.Invoke(PasMPInstance.ParallelFor(@fSignedDistanceFieldJobs[0],0,CountGlyphs-1,GenerateSignedDistanceFieldParallelForJobFunction,1,10,nil,0));
//       GenerateSignedDistanceFieldParallelForJobFunction(nil,0,nil,0,CountGlyphs-1);
        end;

       finally
        fSignedDistanceFieldJobs:=nil;
       end;

       // Insert glyph signed distance field sprites by sorted area size order
       SortedGlyphs:=nil;
       try

        SetLength(SortedGlyphs,length(fGlyphs));

        for GlyphIndex:=0 to length(fGlyphs)-1 do begin
         SortedGlyphs[GlyphIndex]:=@fGlyphs[GlyphIndex];
        end;

        if length(SortedGlyphs)>1 then begin
         IndirectIntroSort(@SortedGlyphs[0],0,length(SortedGlyphs)-1,CompareVulkanFontGlyphsByArea);
        end;

        CreateGUID(GUID);

        UniqueID:=StringReplace(String(aTrueTypeFont.FullName),' ','_',[rfReplaceAll])+'_'+
                  StringReplace(Copy(GUIDToString(GUID),2,36),'-','',[rfReplaceAll])+
                  IntToHex(TPvUInt64(TpvPtrUInt(self)),SizeOf(TpvPtrUInt) shl 1);

        for GlyphIndex:=0 to length(SortedGlyphs)-1 do begin
         Glyph:=SortedGlyphs[GlyphIndex];
         if (Glyph^.Width>0) and (Glyph^.Height>0) then begin
          OtherGlyphIndex:={%H-}((TpvPtrUInt(TpvPointer(Glyph))-TpvPtrUInt(TpvPointer(@fGlyphs[0])))) div SizeOf(TpvFontGlyph);
          Glyph^.Sprite:=aSpriteAtlas.LoadRawSprite(TpvRawByteString(String(UniqueID+IntToHex(TPvUInt64(TpvPtrUInt(Glyph)),SizeOf(TpvPtrUInt) shl 1)+'_glyph'+IntToStr(OtherGlyphIndex))),
                                                    @GlyphDistanceFields[OtherGlyphIndex].Pixels[0],
                                                    Glyph^.Width,
                                                    Glyph^.Height,
                                                    aAutomaticTrim,
                                                    aPadding,
                                                    aTrimPadding,
                                                    false,
                                                    @GlyphTrimmedHullVectors[OtherGlyphIndex]);
          Glyph^.Sprite.SignedDistanceField:=true;
          Glyph^.Sprite.SignedDistanceFieldVariant:=fSignedDistanceFieldVariant;
         end;
        end;

       finally
        SortedGlyphs:=nil;
       end;

      finally
       GlyphTrimmedHullVectors:=nil;
      end;

     finally
      GlyphDistanceFields:=nil;
     end;

    finally
     PolygonBuffers:=nil;
    end;

   finally
    GlyphToTTFGlyphHashMap.Free;
   end;

   // Convert kerning pair lookup data
   fKerningPairs:=nil;
   fKerningPairVectors:=nil;
   CountKerningPairs:=0;
   try
    KerningPairHashMap:=TpvFontInt64HashMap.Create(-1);
    try
     for TrueTypeFontKerningIndex:=0 to length(aTrueTypeFont.KerningTables)-1 do begin
      TrueTypeFontKerningTable:=@aTrueTypeFont.KerningTables[TrueTypeFontKerningIndex];
      for TrueTypeFontKerningPairIndex:=0 to length(TrueTypeFontKerningTable^.KerningPairs)-1 do begin
       TrueTypeFontKerningPair:=@TrueTypeFontKerningTable^.KerningPairs[TrueTypeFontKerningPairIndex];
       if TTFGlyphToGlyphHashMap.TryGet(TrueTypeFontKerningPair^.Left,Int64Value) then begin
        GlyphIndex:=Int64Value;
        if TTFGlyphToGlyphHashMap.TryGet(TrueTypeFontKerningPair^.Right,Int64Value) then begin
         OtherGlyphIndex:=Int64Value;
         KerningPairDoubleIndex:=CombineTwoUInt32IntoOneUInt64(GlyphIndex,OtherGlyphIndex);
         if not KerningPairHashMap.ExistKey(KerningPairDoubleIndex) then begin
          KerningPairIndex:=CountKerningPairs;
          inc(CountKerningPairs);
          if length(fKerningPairs)<CountKerningPairs then begin
           SetLength(fKerningPairs,CountKerningPairs*2);
          end;
          KerningPairHashMap.Add(KerningPairDoubleIndex,KerningPairIndex);
          KerningPair:=@fKerningPairs[KerningPairIndex];
          KerningPair^.Left:=TrueTypeFontKerningPair^.Left;
          KerningPair^.Right:=TrueTypeFontKerningPair^.Right;
          KerningPair^.Horizontal:=aTrueTypeFont.GetKerning(KerningPair^.Left,KerningPair^.Right,true);
          KerningPair^.Vertical:=aTrueTypeFont.GetKerning(KerningPair^.Left,KerningPair^.Right,false);
         end;
        end;
       end;
      end;
     end;
    finally
     KerningPairHashMap.Free;
    end;
   finally
    SetLength(fKerningPairs,CountKerningPairs);
    if length(fKerningPairs)>1 then begin
     UntypedDirectIntroSort(@fKerningPairs[0],0,length(fKerningPairs)-1,SizeOf(TpvFontKerningPair),CompareVulkanFontKerningPairs);
    end;
    SetLength(fKerningPairVectors,CountKerningPairs);
    for KerningPairIndex:=0 to length(fKerningPairs)-1 do begin
     KerningPair:=@fKerningPairs[KerningPairIndex];
     fKerningPairVectors[KerningPairIndex]:=TpvVector2.Create(KerningPair^.Horizontal,KerningPair^.Vertical);
     KerningPairDoubleIndex:=CombineTwoUInt32IntoOneUInt64(KerningPair^.Left,KerningPair^.Right);
     fKerningPairHashMap.Add(KerningPairDoubleIndex,KerningPairIndex);
    end;
   end;

  finally
   TTFGlyphToGlyphHashMap.Free;
  end;

  fCodePointBitmap:=CodePointBitmap;

 end;

end;

constructor TpvFont.CreateFromStream(const aSpriteAtlas:TpvSpriteAtlas;const aStream:TStream);
begin
 Create(aSpriteAtlas);
 LoadFromStream(aStream);
end;

constructor TpvFont.CreateFromFile(const aSpriteAtlas:TpvSpriteAtlas;const aFileName:string);
begin
 Create(aSpriteAtlas);
 LoadFromFile(aFileName);
end;

destructor TpvFont.Destroy;
var Index:TpvInt32;
begin

 fCodePointBitmap:=nil;

 fGlyphs:=nil;

 fCodePointGlyphPairs:=nil;

 fKerningPairs:=nil;

 fKerningPairVectors:=nil;

 for Index:=Low(TpvFontCodePointToGlyphMap) to High(TpvFontCodePointToGlyphMap) do begin
  if assigned(fCodePointToGlyphMap[Index]) then begin
   FreeMem(fCodePointToGlyphMap[Index]);
   fCodePointToGlyphMap[Index]:=nil;
  end;
 end;

 fKerningPairHashMap.Free;

 fSignedDistanceFieldJobs:=nil;

 inherited Destroy;
end;

procedure TpvFont.LoadFromStream(const aStream:TStream);
var CodePointIndex,BitmapCodePointIndex:TpvUInt32;
    GlyphIndex,CodePointGlyphPairIndex,CountCodePointGlyphPairs,KerningPairIndex,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvSizeInt;
    Glyph:PpvFontGlyph;
    CodePointGlyphPair:PpvFontCodePointGlyphPair;
    KerningPair:PpvFontKerningPair;
    KerningPairDoubleIndex:TpvUInt64;
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
begin

 BufferedStream:=TpvSimpleBufferedStream.Create(aStream,false,4096);
 try

  BufferedStream.Seek(0,soBeginning);

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

  if not CompareMem(@TpvFont.FileFormatGUID,@FileGUID,SizeOf(TGUID)) then begin
   raise EpvFontInvalidFormat.Create('Mismatch file format GUID');
  end;

  fTargetPPI:=ReadInt32;
  fUnitsPerEm:=ReadInt32;
  fHorizontalAscender:=ReadInt32;
  fHorizontalDescender:=ReadInt32;
  fHorizontalLineGap:=ReadInt32;
  fVerticalAscender:=ReadInt32;
  fVerticalDescender:=ReadInt32;
  fVerticalLineGap:=ReadInt32;
  fAdvanceWidthMax:=ReadInt32;
  fAdvanceHeightMax:=ReadInt32;
  fBaseScaleFactor:=ReadFloat;
  fInverseBaseScaleFactor:=ReadFloat;
  fBaseSize:=ReadFloat;
  fInverseBaseSize:=ReadFloat;
  fMinX:=ReadFloat;
  fMinY:=ReadFloat;
  fMaxX:=ReadFloat;
  fMaxY:=ReadFloat;
  fMinimumCodePoint:=ReadUInt32;
  fMaximumCodePoint:=ReadUInt32;
  SetLength(fGlyphs,ReadInt32);
  SetLength(fCodePointGlyphPairs,ReadInt32);
  SetLength(fKerningPairs,ReadInt32);
  SetLength(fKerningPairVectors,length(fKerningPairs));

  SetLength(fCodePointBitmap,((fMaximumCodePoint-fMinimumCodePoint)+32) shr 5);

  FillChar(fCodePointBitmap[0],length(fCodePointBitmap)*SizeOf(TpvUInt32),#0);

  FillChar(fGlyphs[0],length(fGlyphs)*SizeOf(TpvFontGlyph),#0);

  FillChar(fCodePointGlyphPairs[0],length(fCodePointGlyphPairs)*SizeOf(TpvFontCodePointGlyphPair),#0);

  FillChar(fKerningPairs[0],length(fKerningPairs)*SizeOf(TpvFontKerningPair),#0);

  FillChar(fKerningPairVectors[0],length(fKerningPairVectors)*SizeOf(TpvVector2),#0);

  for GlyphIndex:=0 to length(fGlyphs)-1 do begin
   Glyph:=@fGlyphs[GlyphIndex];
   Glyph^.Advance.x:=ReadFloat;
   Glyph^.Advance.y:=ReadFloat;
   Glyph^.Bounds.Left:=ReadFloat;
   Glyph^.Bounds.Top:=ReadFloat;
   Glyph^.Bounds.Right:=ReadFloat;
   Glyph^.Bounds.Bottom:=ReadFloat;
   Glyph^.SideBearings.Left:=ReadFloat;
   Glyph^.SideBearings.Top:=ReadFloat;
   Glyph^.SideBearings.Right:=ReadFloat;
   Glyph^.SideBearings.Bottom:=ReadFloat;
   Glyph^.Rect.Left:=ReadFloat;
   Glyph^.Rect.Top:=ReadFloat;
   Glyph^.Rect.Right:=ReadFloat;
   Glyph^.Rect.Bottom:=ReadFloat;
   Glyph^.Offset.x:=ReadFloat;
   Glyph^.Offset.y:=ReadFloat;
   Glyph^.Size.x:=ReadFloat;
   Glyph^.Size.y:=ReadFloat;
   Glyph^.Width:=ReadInt32;
   Glyph^.Height:=ReadInt32;
   Glyph^.Sprite:=fSpriteAtlas.Sprites[ReadString];
   if not assigned(Glyph^.Sprite) then begin
    raise EpvFont.Create('Missing glyph sprite');
   end;
  end;

  for CodePointGlyphPairIndex:=0 to length(fCodePointGlyphPairs)-1 do begin
   CodePointIndex:=ReadInt32;
   if (CodePointIndex<fMinimumCodePoint) or (CodePointIndex>fMaximumCodePoint) then begin
    raise EpvFont.Create('Code point index out of range');
   end;
   BitmapCodePointIndex:=CodePointIndex-fMinimumCodePoint;
   if (fCodePointBitmap[BitmapCodePointIndex shr 5] and (TpvUInt32(1) shl (BitmapCodePointIndex and 31)))<>0 then begin
    raise EpvFont.Create('Duplicate code point');
   end;
   fCodePointBitmap[BitmapCodePointIndex shr 5]:=fCodePointBitmap[BitmapCodePointIndex shr 5] or (TpvUInt32(1) shl (BitmapCodePointIndex and 31));
   GlyphIndex:=ReadInt32;
   if (GlyphIndex<0) or (GlyphIndex>=length(fGlyphs)) then begin
    raise EpvFont.Create('Glyph index out of range');
   end;
   CodePointMapMainIndex:=CodePointIndex shr 10;
   CodePointMapSubIndex:=CodePointIndex and $3ff;
   if CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap) then begin
    if not assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
     GetMem(fCodePointToGlyphMap[CodePointMapMainIndex],SizeOf(TpvFontCodePointToGlyphSubMap));
     FillChar(fCodePointToGlyphMap[CodePointMapMainIndex]^,SizeOf(TpvFontCodePointToGlyphSubMap),$ff);
    end;
    fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex]:=GlyphIndex;
   end;
   CodePointGlyphPair:=@fCodePointGlyphPairs[CodePointGlyphPairIndex];
   CodePointGlyphPair^.CodePoint:=CodePointIndex;
   CodePointGlyphPair^.Glyph:=GlyphIndex;
  end;

  for KerningPairIndex:=0 to length(fKerningPairVectors)-1 do begin
   KerningPair:=@fKerningPairs[KerningPairIndex];
   KerningPair^.Left:=ReadInt32;
   KerningPair^.Right:=ReadInt32;
   KerningPair^.Horizontal:=ReadInt32;
   KerningPair^.Vertical:=ReadInt32;
   fKerningPairVectors[KerningPairIndex]:=TpvVector2.Create(KerningPair^.Horizontal,KerningPair^.Vertical);
   KerningPairDoubleIndex:=CombineTwoUInt32IntoOneUInt64(KerningPair^.Left,KerningPair^.Right);
   if fKerningPairHashMap.ExistKey(KerningPairDoubleIndex) then begin
    raise EpvFont.Create('Duplicate kerning pair');
   end;
   fKerningPairHashMap.Add(KerningPairDoubleIndex,KerningPairIndex);
  end;

 finally
  BufferedStream.Free;
 end;

end;

procedure TpvFont.LoadFromFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvFont.SaveToStream(const aStream:TStream);
var GlyphIndex,CodePointGlyphPairIndex,KerningPairIndex:TpvSizeInt;
    Glyph:PpvFontGlyph;
    KerningPair:PpvFontKerningPair;
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

 BufferedStream:=TpvSimpleBufferedStream.Create(aStream,false,4096);
 try

  WriteUInt32(TpvFont.FileFormatGUID.D1);
  WriteUInt16(TpvFont.FileFormatGUID.D2);
  WriteUInt16(TpvFont.FileFormatGUID.D3);
  WriteUInt8(TpvFont.FileFormatGUID.D4[0]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[1]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[2]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[3]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[4]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[5]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[6]);
  WriteUInt8(TpvFont.FileFormatGUID.D4[7]);

  WriteInt32(fTargetPPI);
  WriteInt32(fUnitsPerEm);
  WriteInt32(fHorizontalAscender);
  WriteInt32(fHorizontalDescender);
  WriteInt32(fHorizontalLineGap);
  WriteInt32(fVerticalAscender);
  WriteInt32(fVerticalDescender);
  WriteInt32(fVerticalLineGap);
  WriteInt32(fAdvanceWidthMax);
  WriteInt32(fAdvanceHeightMax);
  WriteFloat(fBaseScaleFactor);
  WriteFloat(fInverseBaseScaleFactor);
  WriteFloat(fBaseSize);
  WriteFloat(fInverseBaseSize);
  WriteFloat(fMinX);
  WriteFloat(fMinY);
  WriteFloat(fMaxX);
  WriteFloat(fMaxY);
  WriteUInt32(fMinimumCodePoint);
  WriteUInt32(fMaximumCodePoint);
  WriteInt32(length(fGlyphs));
  WriteInt32(length(fCodePointGlyphPairs));
  WriteInt32(length(fKerningPairs));

  for GlyphIndex:=0 to length(fGlyphs)-1 do begin
   Glyph:=@fGlyphs[GlyphIndex];
   WriteFloat(Glyph^.Advance.x);
   WriteFloat(Glyph^.Advance.y);
   WriteFloat(Glyph^.Bounds.Left);
   WriteFloat(Glyph^.Bounds.Top);
   WriteFloat(Glyph^.Bounds.Right);
   WriteFloat(Glyph^.Bounds.Bottom);
   WriteFloat(Glyph^.SideBearings.Left);
   WriteFloat(Glyph^.SideBearings.Top);
   WriteFloat(Glyph^.SideBearings.Right);
   WriteFloat(Glyph^.SideBearings.Bottom);
   WriteFloat(Glyph^.Rect.Left);
   WriteFloat(Glyph^.Rect.Top);
   WriteFloat(Glyph^.Rect.Right);
   WriteFloat(Glyph^.Rect.Bottom);
   WriteFloat(Glyph^.Offset.x);
   WriteFloat(Glyph^.Offset.y);
   WriteFloat(Glyph^.Size.x);
   WriteFloat(Glyph^.Size.y);
   WriteInt32(Glyph^.Width);
   WriteInt32(Glyph^.Height);
   if assigned(Glyph^.Sprite) then begin
    WriteString(TpvRawByteString(Glyph^.Sprite.Name));
   end else begin
    WriteString('');
   end;
  end;

  for CodePointGlyphPairIndex:=0 to length(fCodePointGlyphPairs)-1 do begin
   WriteUInt32(fCodePointGlyphPairs[CodePointGlyphPairIndex].CodePoint);
   WriteUInt32(fCodePointGlyphPairs[CodePointGlyphPairIndex].Glyph);
  end;

  for KerningPairIndex:=0 to length(fKerningPairs)-1 do begin
   KerningPair:=@fKerningPairs[KerningPairIndex];
   WriteInt32(KerningPair^.Left);
   WriteInt32(KerningPair^.Right);
   WriteInt32(KerningPair^.Horizontal);
   WriteInt32(KerningPair^.Vertical);
  end;

 finally

  BufferedStream.Free;

 end;

end;

procedure TpvFont.SaveToFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvFont.CalculateMonospaceSize;
var CurrentCodePoint:TpvUInt32;
    CurrentGlyph,CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    Glyph:PpvFontGlyph;
begin
 fMonospaceSize:=TpvVector2.Null;
 for CurrentCodePoint:=$20 to $7e do begin
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    Glyph:=@fGlyphs[CurrentGlyph];
    fMonospaceSize:=Maximum(fMonospaceSize,Maximum(Glyph^.Bounds.RightBottom,Glyph^.Advance));
   end;
  end;
 end;
 if IsZero(fMonospaceSize.x) then begin
  fMonospaceSize.x:=fMaxX-fMinX;
 end;
 if IsZero(fMonospaceSize.y) then begin
  fMonospaceSize.y:=fMaxY-fMinY;
 end;
 if fAdvanceWidthMax<fAdvanceHeightMax then begin
  fMonospaceSize:=Maximum(fMonospaceSize,
                          TpvVector2.InlineableCreate(Maximum(Maximum(fUnitsPerEm,
                                                                      fMaxX-fMinX
                                                                     ),
                                                              Maximum((fHorizontalAscender-fHorizontalDescender)+fHorizontalLineGap,
                                                                      fAdvanceWidthMax
                                                                     )
                                                             ),
                                                      Maximum((fVerticalAscender-fVerticalDescender)+fVerticalLineGap,
                                                              fAdvanceHeightMax
                                                             )
                                                     )
                         );
 end else begin
  fMonospaceSize:=Maximum(fMonospaceSize,
                          TpvVector2.InlineableCreate(Maximum((fHorizontalAscender-fHorizontalDescender)+fHorizontalLineGap,
                                                              fAdvanceWidthMax
                                                             ),
                                                      Maximum(Maximum(fUnitsPerEm,
                                                                      fMaxY-fMinY
                                                                     ),
                                                              Maximum((fVerticalAscender-fVerticalDescender)+fVerticalLineGap,
                                                                      fAdvanceHeightMax
                                                                     )
                                                             )
                                                     )
                         );
 end;
end;

function TpvFont.GetScaleFactor(const aSize:TpvFloat):TpvFloat;
begin
 if aSize<0.0 then begin
  result:=(-aSize)/fUnitsPerEm;
 end else begin
  result:=(aSize*fTargetPPI)/(fUnitsPerEm*72);
 end;
end;

procedure TpvFont.GenerateSignedDistanceField(var aSignedDistanceField:TpvSignedDistanceField2D;const aTrimmedHullVectors:PpvSpriteTrimmedHullVectors;const aOffsetX,aOffsetY:TpvDouble;const aMultiChannel:boolean;const aPolygonBuffer:TpvTrueTypeFontPolygonBuffer;const aFillRule:TpvInt32;const aSDFVariant:TpvSignedDistanceField2DVariant);
const Scale=1.0/256.0;
var CommandIndex,x,y:TpvInt32;
    Command:PpvTrueTypeFontPolygonCommand;
    VectorPath:TpvVectorPath;
    VectorPathShape:TpvVectorPathShape;
    ConvexHull2DPixels:TpvConvexHull2DPixels;
    CenterX,CenterY,CenterRadius:TpvFloat;
begin
 VectorPath:=TpvVectorPath.Create;
 try
  if aFillRule=pvTTF_PolygonWindingRule_NONZERO then begin
   VectorPath.FillRule:=TpvVectorPathFillRule.NonZero;
  end else begin
   VectorPath.FillRule:=TpvVectorPathFillRule.EvenOdd;
  end;
  for CommandIndex:=0 to aPolygonBuffer.CountCommands-1 do begin
   Command:=@aPolygonBuffer.Commands[CommandIndex];
   case Command^.CommandType of
    TpvTrueTypeFontPolygonCommandType.MoveTo:begin
     VectorPath.MoveTo(Command^.Points[0].x,
                       Command^.Points[0].y);
    end;
    TpvTrueTypeFontPolygonCommandType.LineTo:begin
     VectorPath.LineTo(Command^.Points[0].x,
                       Command^.Points[0].y);
    end;
    TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo:begin
     VectorPath.QuadraticCurveTo(Command^.Points[0].x,
                                 Command^.Points[0].y,
                                 Command^.Points[1].x,
                                 Command^.Points[1].y);
    end;
    TpvTrueTypeFontPolygonCommandType.CubicCurveTo:begin
     VectorPath.CubicCurveTo(Command^.Points[0].x,
                             Command^.Points[0].y,
                             Command^.Points[1].x,
                             Command^.Points[1].y,
                             Command^.Points[2].x,
                             Command^.Points[2].y);
    end;
    TpvTrueTypeFontPolygonCommandType.Close:begin
     VectorPath.Close;
    end;
   end;
  end;
  VectorPathShape:=TpvVectorPathShape.Create(VectorPath);
  try
   TpvSignedDistanceField2DGenerator.Generate(aSignedDistanceField,VectorPathShape,Scale,aOffsetX,aOffsetY,aSDFVariant);
  finally
   FreeAndNil(VectorPathShape);
  end;
  if assigned(aTrimmedHullVectors) then begin
   ConvexHull2DPixels:=nil;
   try
    SetLength(ConvexHull2DPixels,aSignedDistanceField.Width*aSignedDistanceField.Height);
    for y:=0 to aSignedDistanceField.Height-1 do begin
     for x:=0 to aSignedDistanceField.Width-1 do begin
      ConvexHull2DPixels[(y*aSignedDistanceField.Width)+x]:=aSignedDistanceField.Pixels[(y*aSignedDistanceField.Width)+x].a<>0;
     end;
    end;
    GetConvexHull2D(ConvexHull2DPixels,
                    aSignedDistanceField.Width,
                    aSignedDistanceField.Height,
                    aTrimmedHullVectors^,
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
 finally
  FreeAndNil(VectorPath);
 end;
end;

procedure TpvFont.GenerateSignedDistanceFieldParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Index:TPasMPNativeInt;
    JobData:PpvFontSignedDistanceFieldJob;
begin
 Index:=FromIndex;
 while Index<=ToIndex do begin
  JobData:=@fSignedDistanceFieldJobs[Index];
  GenerateSignedDistanceField(JobData^.DistanceField^,
                              JobData^.TrimmedHullVectors,
                              JobData^.OffsetX,
                              JobData^.OffsetY,
                              JobData^.MultiChannel,
                              JobData^.PolygonBuffer,
                              pvTTF_PolygonWindingRule_NONZERO,
                              fSignedDistanceFieldVariant);
  inc(Index);
 end;
end;

function TpvFont.TextWidth(const aText:TpvUTF8String;const aSize:TpvFloat):TpvFloat;
var TextIndex,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    CurrentCodePoint:TpvUInt32;
    Width:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
begin
 result:=0.0;
 Width:=0.0;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     result:=result+fKerningPairs[Int64Value].Horizontal;
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    Width:=Maximum(Width,result+Glyph^.Bounds.Right);
    result:=result+Glyph^.Advance.x;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if length(aText)>0 then begin
  if IsZero(result) then begin
   result:=fMaxX-fMinX;
  end;
  if result<Width then begin
   result:=Width;
  end;
 end;
 result:=result*GetScaleFactor(aSize);
end;

function TpvFont.TextHeight(const aText:TpvUTF8String;const aSize:TpvFloat):TpvFloat;
var TextIndex,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    CurrentCodePoint:TpvUInt32;
    Height:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
begin
 result:=0.0;
 Height:=0.0;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     result:=result+fKerningPairs[Int64Value].Vertical;
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    Height:=Maximum(Height,result+Glyph^.Bounds.Bottom);
    result:=result+Glyph^.Advance.y;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if length(aText)>0 then begin
  if IsZero(result) then begin
   result:=fMaxY-fMinY;
  end;
  if result<Height then begin
   result:=Height;
  end;
 end;
 result:=result*GetScaleFactor(aSize);
end;

function TpvFont.TextSize(const aText:TpvUTF8String;const aSize:TpvFloat):TpvVector2;
var TextIndex,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    CurrentCodePoint:TpvUInt32;
    Size:TpvVector2;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
begin
 result:=TpvVector2.Null;
 Size:=TpvVector2.Null;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     result:=result+fKerningPairVectors[Int64Value];
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    Size:=Maximum(Size,result+Glyph^.Bounds.RightBottom);
    result:=result+Glyph^.Advance;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if length(aText)>0 then begin
  if IsZero(result.x) then begin
   result.x:=fMaxX-fMinX;
  end;
  if IsZero(result.y) then begin
   result.y:=fMaxY-fMinY;
  end;
 end;
 result:=Maximum(result,Size)*GetScaleFactor(aSize);
end;

function TpvFont.CodePointWidth(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvFloat;
var CurrentGlyph,CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    Width:TpvFloat;
    Glyph:PpvFontGlyph;
begin
 result:=0.0;
 Width:=0.0;
 CodePointMapMainIndex:=aTextCodePoint shr 10;
 CodePointMapSubIndex:=aTextCodePoint and $3ff;
 if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
    (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
    assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
  CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
  if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
   Glyph:=@fGlyphs[CurrentGlyph];
   Width:=Glyph^.Bounds.Right;
   result:=Glyph^.Advance.x;
  end;
 end;
 if IsZero(result) then begin
  result:=fMaxX-fMinX;
 end;
 if result<Width then begin
  result:=Width;
 end;
 result:=result*GetScaleFactor(aSize);
end;

function TpvFont.CodePointHeight(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvFloat;
var CurrentGlyph,CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    Height:TpvFloat;
    Glyph:PpvFontGlyph;
begin
 result:=0.0;
 Height:=0.0;
 CodePointMapMainIndex:=aTextCodePoint shr 10;
 CodePointMapSubIndex:=aTextCodePoint and $3ff;
 if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
    (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
    assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
  CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
  if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
   Glyph:=@fGlyphs[CurrentGlyph];
   Height:=Glyph^.Bounds.Bottom;
   result:=Glyph^.Advance.y;
  end;
 end;
 if IsZero(result) then begin
  result:=fMaxY-fMinY;
 end;
 if result<Height then begin
  result:=Height;
 end;
 result:=result*GetScaleFactor(aSize);
end;

function TpvFont.CodePointSize(const aTextCodePoint:TpvUInt32;const aSize:TpvFloat):TpvVector2;
var CurrentGlyph,CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    Size:TpvVector2;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
begin
 result:=TpvVector2.Null;
 Size:=TpvVector2.Null;
 CodePointMapMainIndex:=aTextCodePoint shr 10;
 CodePointMapSubIndex:=aTextCodePoint and $3ff;
 if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
    (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
    assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
  CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
  if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
   Glyph:=@fGlyphs[CurrentGlyph];
   Size:=Maximum(Size,result+Glyph^.Bounds.RightBottom);
   result:=result+Glyph^.Advance;
  end;
 end;
 if IsZero(result.x) then begin
  result.x:=fMaxX-fMinX;
 end;
 if IsZero(result.y) then begin
  result.y:=fMaxY-fMinY;
 end;
 result:=Maximum(result,Size)*GetScaleFactor(aSize);
end;

function TpvFont.MonospaceSize(const aSize:TpvFloat):TpvVector2;
begin
 if not fHasMonospaceSize then begin
  fHasMonospaceSize:=true;
  CalculateMonospaceSize;
 end;
 result:=fMonospaceSize*GetScaleFactor(aSize);
end;

function TpvFont.RowHeight(const aPercent:TpvFloat;const aSize:TpvFloat):TpvFloat;
begin
 result:=fUnitsPerEm*(aPercent*0.01);
 if not IsZero(aSize) then begin
  result:=result*GetScaleFactor(aSize);
 end;
end;

function TpvFont.LineSpace(const aPercent:TpvFloat;const aSize:TpvFloat):TpvFloat;
begin
 result:=((fVerticalAscender-fVerticalDescender)+fVerticalLineGap)*(aPercent*0.01);
 if not IsZero(aSize) then begin
  result:=result*GetScaleFactor(aSize);
 end;
end;

procedure TpvFont.GetTextGlyphRects(const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat;var aRects:TpvRectArray;out aCountRects:TpvInt32);
var TextIndex,CurrentCodePoint,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    ScaleFactor,RescaleFactor:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
    Position:TpvVector2;
begin
 aCountRects:=0;
 Position:=TpvVector2.Null;
 ScaleFactor:=GetScaleFactor(aSize);
 RescaleFactor:=ScaleFactor*fInverseBaseScaleFactor;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     Position:=Position+fKerningPairVectors[Int64Value];
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    if length(aRects)<=aCountRects then begin
     SetLength(aRects,(aCountRects+1)*2);
    end;
    aRects[aCountRects]:=TpvRect.CreateRelative(aPosition+(Position*ScaleFactor)+(Glyph^.Offset*RescaleFactor),
                                                Glyph^.Size*RescaleFactor);
    inc(aCountRects);
    Position:=Position+Glyph^.Advance;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  LastGlyph:=CurrentGlyph;
 end;
end;

procedure TpvFont.GetTextGlyphInfos(const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat;var aTextGlyphInfos:TpvFontTextGlyphInfoArray;out aCountTextGlyphInfos:TpvInt32);
var LastTextIndex,TextIndex,CurrentCodePoint,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    ScaleFactor,RescaleFactor:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
    Position:TpvVector2;
    TextGlyphInfo:PpvFontTextGlyphInfo;
    ValidGlyph:boolean;
begin
 aCountTextGlyphInfos:=0;
 Position:=TpvVector2.Null;
 ScaleFactor:=GetScaleFactor(aSize);
 RescaleFactor:=ScaleFactor*fInverseBaseScaleFactor;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  LastTextIndex:=TextIndex;
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  ValidGlyph:=false;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if length(aTextGlyphInfos)<=aCountTextGlyphInfos then begin
     SetLength(aTextGlyphInfos,(aCountTextGlyphInfos+1)*2);
    end;
    TextGlyphInfo:=@aTextGlyphInfos[aCountTextGlyphInfos];
    inc(aCountTextGlyphInfos);
    TextGlyphInfo^.TextIndex:=LastTextIndex;
    TextGlyphInfo^.CodePoint:=CurrentCodePoint;
    TextGlyphInfo^.LastGlyph:=LastGlyph;
    TextGlyphInfo^.Glyph:=CurrentGlyph;
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     Position:=Position+fKerningPairVectors[Int64Value];
     TextGlyphInfo^.Kerning:=fKerningPairVectors[Int64Value]*ScaleFactor;
    end else begin
     TextGlyphInfo^.Kerning:=TpvVector2.Null;
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    TextGlyphInfo^.Advance:=Glyph^.Advance*ScaleFactor;
    TextGlyphInfo^.Offset:=Glyph^.Offset*RescaleFactor;
    TextGlyphInfo^.Position:=aPosition+(Position*ScaleFactor)+(Glyph^.Offset*RescaleFactor);
    TextGlyphInfo^.Size:=Glyph^.Size*RescaleFactor;
    Position:=Position+Glyph^.Advance;
    ValidGlyph:=true;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  if not ValidGlyph then begin
   if length(aTextGlyphInfos)<=aCountTextGlyphInfos then begin
    SetLength(aTextGlyphInfos,(aCountTextGlyphInfos+1)*2);
   end;
   TextGlyphInfo:=@aTextGlyphInfos[aCountTextGlyphInfos];
   inc(aCountTextGlyphInfos);
   TextGlyphInfo^.TextIndex:=LastTextIndex;
   TextGlyphInfo^.CodePoint:=CurrentCodePoint;
   TextGlyphInfo^.LastGlyph:=LastGlyph;
   TextGlyphInfo^.Glyph:=CurrentGlyph;
   TextGlyphInfo^.Kerning:=TpvVector2.Null;
   TextGlyphInfo^.Advance:=TpvVector2.Null;
   TextGlyphInfo^.Offset:=TpvVector2.Null;
   TextGlyphInfo^.Position:=aPosition+(Position*ScaleFactor);
   TextGlyphInfo^.Size:=TpvVector2.Null;
  end;
  LastGlyph:=CurrentGlyph;
 end;
end;

procedure TpvFont.Draw(const aDrawSprite:TpvFontDrawSprite;const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat);
var TextIndex,CurrentCodePoint,CurrentGlyph,LastGlyph,
    CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    ScaleFactor,RescaleFactor:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
    Position:TpvVector2;
begin
 Position:=TpvVector2.Null;
 ScaleFactor:=GetScaleFactor(aSize);
 RescaleFactor:=ScaleFactor*fInverseBaseScaleFactor;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentCodePoint:=PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex);
  CodePointMapMainIndex:=CurrentCodePoint shr 10;
  CodePointMapSubIndex:=CurrentCodePoint and $3ff;
  if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
     (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
     assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
   CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
   if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
    if ((LastGlyph>=0) and (LastGlyph<length(fGlyphs))) and
       (length(fKerningPairs)>0) and
       fKerningPairHashMap.TryGet(CombineTwoUInt32IntoOneUInt64(LastGlyph,CurrentGlyph),Int64Value) then begin
     Position:=Position+fKerningPairVectors[Int64Value];
    end;
    Glyph:=@fGlyphs[CurrentGlyph];
    if assigned(Glyph^.Sprite) then begin
     aDrawSprite(Glyph^.Sprite,
                 TpvRect.CreateRelative(TpvVector2.Null,
                                        Glyph^.Size),
                 TpvRect.CreateRelative(aPosition+(Position*ScaleFactor)+(Glyph^.Offset*RescaleFactor),
                                        Glyph^.Size*RescaleFactor));
     Position:=Position+Glyph^.Advance;
    end;
   end;
  end else begin
   CurrentGlyph:=0;
  end;
  LastGlyph:=CurrentGlyph;
 end;
end;

procedure TpvFont.Draw(const aCanvas:TObject;const aText:TpvUTF8String;const aPosition:TpvVector2;const aSize:TpvFloat);
begin
 Draw(TpvCanvas(aCanvas).DrawSpriteProc,aText,aPosition,aSize);
end;

procedure TpvFont.DrawCodePoint(const aDrawSprite:TpvFontDrawSprite;const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2;const aSize:TpvFloat);
var CurrentCodePoint,CurrentGlyph,CodePointMapMainIndex,CodePointMapSubIndex:TpvInt32;
    ScaleFactor,RescaleFactor:TpvFloat;
    Int64Value:TpvInt64;
    Glyph:PpvFontGlyph;
    Position:TpvVector2;
begin
 Position:=TpvVector2.Null;
 ScaleFactor:=GetScaleFactor(aSize);
 RescaleFactor:=ScaleFactor*fInverseBaseScaleFactor;
 CurrentCodePoint:=aTextCodePoint;
 CodePointMapMainIndex:=CurrentCodePoint shr 10;
 CodePointMapSubIndex:=CurrentCodePoint and $3ff;
 if (CodePointMapMainIndex>=Low(TpvFontCodePointToGlyphMap)) and
    (CodePointMapMainIndex<=High(TpvFontCodePointToGlyphMap)) and
    assigned(fCodePointToGlyphMap[CodePointMapMainIndex]) then begin
  CurrentGlyph:=fCodePointToGlyphMap[CodePointMapMainIndex]^[CodePointMapSubIndex];
  if (CurrentGlyph>=0) and (CurrentGlyph<length(fGlyphs)) then begin
   Glyph:=@fGlyphs[CurrentGlyph];
   if assigned(Glyph^.Sprite) then begin
    aDrawSprite(Glyph^.Sprite,
                TpvRect.CreateRelative(TpvVector2.Null,
                                       Glyph^.Size),
                TpvRect.CreateRelative(aPosition+(Position*ScaleFactor)+(Glyph^.Offset*RescaleFactor),
                                       Glyph^.Size*RescaleFactor));
   end;
  end;
 end;
end;

procedure TpvFont.DrawCodePoint(const aCanvas:TObject;const aTextCodePoint:TpvUInt32;const aPosition:TpvVector2;const aSize:TpvFloat);
begin
 DrawCodePoint(TpvCanvas(aCanvas).DrawSpriteProc,aTextCodePoint,aPosition,aSize);
end;

end.
