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
unit PasVulkan.TrueTypeFont;
{$i PasVulkan.inc}
{$ifdef fpc}
 //{$optimization off,level1}
{$else}
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
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.VectorPath;

const pvTTF_PID_Apple=0;
      pvTTF_PID_Macintosh=1;
      pvTTF_PID_ISO=2;
      pvTTF_PID_Microsoft=3;

      pvTTF_SID_APPLE_DEFAULT=0;
      pvTTF_SID_APPLE_UNICODE_1_1=1;
      pvTTF_SID_APPLE_ISO_10646=2;
      pvTTF_SID_APPLE_UNICODE_2_0=3;
      pvTTF_SID_APPLE_UNICODE32=4;
      pvTTF_SID_APPLE_VARIANT_SELECTOR=5;
      pvTTF_SID_APPLE_FULL_UNICODE_COVERAGE=6;

      pvTTF_SID_MAC_Roman=0;
      pvTTF_SID_MAC_Japanese=1;
      pvTTF_SID_MAC_Chinese=2;
      pvTTF_SID_MAC_Korean=3;
      pvTTF_SID_MAC_Arabic=4;
      pvTTF_SID_MAC_Hebrew=5;
      pvTTF_SID_MAC_Greek=6;
      pvTTF_SID_MAC_Russian=7;
      pvTTF_SID_MAC_RSymbol=8;
      pvTTF_SID_MAC_Devanagari=9;
      pvTTF_SID_MAC_Gurmukhi=10;
      pvTTF_SID_MAC_Gujarati=11;
      pvTTF_SID_MAC_Oriya=12;
      pvTTF_SID_MAC_Bengali=13;
      pvTTF_SID_MAC_Tamil=14;
      pvTTF_SID_MAC_Telugu=15;
      pvTTF_SID_MAC_Kannada=16;
      pvTTF_SID_MAC_Malayalam=17;
      pvTTF_SID_MAC_Sinhalese=18;
      pvTTF_SID_MAC_Burmese=19;
      pvTTF_SID_MAC_Khmer=20;
      pvTTF_SID_MAC_Thai=21;
      pvTTF_SID_MAC_Laotian=22;
      pvTTF_SID_MAC_Georgian=23;
      pvTTF_SID_MAC_Armenian=24;
      pvTTF_SID_MAC_Maldivian=25;
      pvTTF_SID_MAC_Tibetian=26;
      pvTTF_SID_MAC_Mongolian=27;
      pvTTF_SID_MAC_Geez=28;
      pvTTF_SID_MAC_Slavic=29;
      pvTTF_SID_MAC_Vietnamese=30;
      pvTTF_SID_MAC_Sindhi=31;
      pvTTF_SID_MAC_Uninterp=32;

      pvTTF_SID_MS_SYMBOL_CS=0;
      pvTTF_SID_MS_UNICODE_CS=1;
      pvTTF_SID_MS_SJIS=2;
      pvTTF_SID_MS_GB2312=3;
      pvTTF_SID_MS_BIG_5=4;
      pvTTF_SID_MS_WANSUNG=5;
      pvTTF_SID_MS_JOHAB=6;
      pvTTF_SID_MS_UCS_4=10;

      pvTTF_SID_ISO_ASCII=0;
      pvTTF_SID_ISO_10646=1;
      pvTTF_SID_ISO_8859_1=2;

      pvTTF_LID_MS_Arabic=$0401;
      pvTTF_LID_MS_Bulgarian=$0402;
      pvTTF_LID_MS_Catalan=$0403;
      pvTTF_LID_MS_TraditionalChinese=$0404;
      pvTTF_LID_MS_SimplifiedChinese=$0804;
      pvTTF_LID_MS_Czech=$0405;
      pvTTF_LID_MS_Danish=$0406;
      pvTTF_LID_MS_German=$0407;
      pvTTF_LID_MS_SwissGerman=$0807;
      pvTTF_LID_MS_Greek=$0408;
      pvTTF_LID_MS_USEnglish=$0409;
      pvTTF_LID_MS_UKEnglish=$0809;
      pvTTF_LID_MS_CastilianSpanish=$040a;
      pvTTF_LID_MS_MexicanSpanish=$080a;
      pvTTF_LID_MS_ModernSpanish=$0c0a;
      pvTTF_LID_MS_Finnish=$040b;
      pvTTF_LID_MS_French=$040c;
      pvTTF_LID_MS_BelgianFrench=$080c;
      pvTTF_LID_MS_CanadianFrench=$0c0c;
      pvTTF_LID_MS_SwissFrench=$100c;
      pvTTF_LID_MS_Hebrew=$040d;
      pvTTF_LID_MS_Hungarian=$040e;
      pvTTF_LID_MS_Icelandic=$040f;
      pvTTF_LID_MS_Italian=$0410;
      pvTTF_LID_MS_SwissItalian=$0810;
      pvTTF_LID_MS_Japanese=$0411;
      pvTTF_LID_MS_Korean=$0412;
      pvTTF_LID_MS_Dutch=$0413;
      pvTTF_LID_MS_BelgianDutch=$0813;
      pvTTF_LID_MS_NorwegianBokmal=$0414;
      pvTTF_LID_MS_NorwegianNynorsk=$0814;
      pvTTF_LID_MS_Polish=$0415;
      pvTTF_LID_MS_BrazilianPortuguese=$0416;
      pvTTF_LID_MS_Portuguese=$0816;
      pvTTF_LID_MS_RhaetoRomanic=$0417;
      pvTTF_LID_MS_Romanian=$0418;
      pvTTF_LID_MS_Russian=$0419;
      pvTTF_LID_MS_CroatoSerbian=$041a;
      pvTTF_LID_MS_SerboCroatian=$081a;
      pvTTF_LID_MS_Slovakian=$041b;
      pvTTF_LID_MS_Albanian=$041c;
      pvTTF_LID_MS_Swedish=$041d;
      pvTTF_LID_MS_Thai=$041e;
      pvTTF_LID_MS_Turkish=$041f;
      pvTTF_LID_MS_Urdu=$0420;
      pvTTF_LID_MS_Bahasa=$0421;

      pvTTF_LID_MAC_English=0;
      pvTTF_LID_MAC_French=1;
      pvTTF_LID_MAC_German=2;
      pvTTF_LID_MAC_Italian=3;
      pvTTF_LID_MAC_Dutch=4;
      pvTTF_LID_MAC_Swedish=5;
      pvTTF_LID_MAC_Spanish=6;
      pvTTF_LID_MAC_Danish=7;
      pvTTF_LID_MAC_Portuguese=8;
      pvTTF_LID_MAC_Norwegian=9;
      pvTTF_LID_MAC_Hebrew=10;
      pvTTF_LID_MAC_Japanese=11;
      pvTTF_LID_MAC_Arabic=12;
      pvTTF_LID_MAC_Finnish=13;
      pvTTF_LID_MAC_Greek=14;
      pvTTF_LID_MAC_Icelandic=15;
      pvTTF_LID_MAC_Maltese=16;
      pvTTF_LID_MAC_Turkish=17;
      pvTTF_LID_MAC_Yugoslavian=18;
      pvTTF_LID_MAC_Chinese=19;
      pvTTF_LID_MAC_Urdu=20;
      pvTTF_LID_MAC_Hindi=21;
      pvTTF_LID_MAC_Thai=22;

      pvTTF_cfgfNONE=0;
      pvTTF_cfgfXY=1;
      pvTTF_cfgfX=2;
      pvTTF_cfgfY=3;

      pvTTF_NID_Copyright=0;
      pvTTF_NID_Family=1;
      pvTTF_NID_Subfamily=2;
      pvTTF_NID_UniqueID=3;
      pvTTF_NID_FullName=4;
      pvTTF_NID_Version=5;
      pvTTF_NID_PostscriptName=6;
      pvTTF_NID_Trademark=7;

      pvTTF_CMAP_FORMAT0=0;
      pvTTF_CMAP_FORMAT2=2;
      pvTTF_CMAP_FORMAT4=4;
      pvTTF_CMAP_FORMAT6=6;
      pvTTF_CMAP_FORMAT8=8;
      pvTTF_CMAP_FORMAT10=10;
      pvTTF_CMAP_FORMAT12=12;
      pvTTF_CMAP_FORMAT13=13;
      pvTTF_CMAP_FORMAT14=14;

      pvTTF_OFFSET_TABLE_SIZE=12;

      pvTTF_MACINTOSH=1;
      pvTTF_MICROSOFT=2;

      pvTTF_GASP_GRIDFIT=1;
      pvTTF_GASP_DOGRAY=2;
      pvTTF_GASP_SYMMETRIC_GRIDFIT=4;
      pvTTF_GASP_SYMMETRIC_SMOOTHING=8;

      pvTTF_TT_NO_POINT=0;
      pvTTF_TT_OFF_CURVE=1;
      pvTTF_TT_ON_CURVE=2;

      pvTTF_TT_ERR_NoError=0;
      pvTTF_TT_ERR_InvalidFile=1;
      pvTTF_TT_ERR_CorruptFile=2;
      pvTTF_TT_ERR_OutOfMemory=3;
      pvTTF_TT_ERR_TableNotFound=4;
      pvTTF_TT_ERR_NoCharacterMapFound=5;
      pvTTF_TT_ERR_UnknownCharacterMapFormat=6;
      pvTTF_TT_ERR_CharacterMapNotPresent=7;
      pvTTF_TT_ERR_UnableToOpenFile=8;
      pvTTF_TT_ERR_UnknownKerningFormat=9;
      pvTTF_TT_ERR_UnknownGPOSFormat=10;
      pvTTF_TT_ERR_UnknownCharsetFormat=11;
      pvTTF_TT_ERR_UnknownEncodingFormat=12;
      pvTTF_TT_ERR_OutOfBounds=13;

      pvTTF_LineCapMode_BUTT=0;
      pvTTF_LineCapMode_SQUARE=1;
      pvTTF_LineCapMode_ROUND=2;

      pvTTF_LineJoinMode_BEVEL=0;
      pvTTF_LineJoinMode_ROUND=1;
      pvTTF_LineJoinMode_MITER=2;
      pvTTF_LineJoinMode_MITERREVERT=3;
      pvTTF_LineJoinMode_MITERROUND=4;

      pvTTF_LineInnerJoinMode_BEVEL=0;
      pvTTF_LineInnerJoinMode_MITER=1;
      pvTTF_LineInnerJoinMode_JAG=2;
      pvTTF_LineInnerJoinMode_ROUND=3;

      pvTTF_PolygonWindingRule_NONZERO=0; // TTF fonts uses the non-zero winding rule only
      pvTTF_PolygonWindingRule_EVENODD=1; // <- exists here only for completeness :-)

      pvTTF_PathFlag_OnCurve=1 shl 0;
      pvTTF_PathFlag_OnXShortVector=1 shl 1;
      pvTTF_PathFlag_OnYShortVector=1 shl 2;
      pvTTF_PathFlag_Repeat=1 shl 3;
      pvTTF_PathFlag_PositiveXShortVector=1 shl 4;
      pvTTF_PathFlag_ThisXIsSame=1 shl 4;
      pvTTF_PathFlag_PositiveYShortVector=1 shl 5;
      pvTTF_PathFlag_ThisYIsSame=1 shl 5;
      pvTTF_PathFlag_TouchedX=1 shl 6;
      pvTTF_PathFlag_TouchedY=1 shl 7;

      pvTTF_Zone_Twilight=0;
      pvTTF_Zone_Glyph=1;
      pvTTF_Zone_Count=2;

      pvTTF_PointType_Current=0;
      pvTTF_PointType_Unhinted=1;
      pvTTF_PointType_InFontUnits=2;
      pvTTF_PointType_Count=3;

type EpvTrueTypeFont=class(Exception);

     TpvTrueTypeFont=class;

     TpvTrueTypeFontRasterizer=class
      protected
       fLastX:TpvInt32;
       fLastY:TpvInt32;
       function GetCanvas:TpvPointer; virtual;
       procedure SetCanvas(NewCanvas:TpvPointer); virtual;
       function GetWidth:TpvInt32; virtual;
       procedure SetWidth(NewWidth:TpvInt32); virtual;
       function GetHeight:TpvInt32; virtual;
       procedure SetHeight(NewHeight:TpvInt32); virtual;
       function GetWindingRule:TpvInt32; virtual;
       procedure SetWindingRule(NewWindingRule:TpvInt32); virtual;
      public
       constructor Create; virtual;
       destructor Destroy; override;
       procedure Clear; virtual;
       procedure Reset; virtual;
       procedure Resize(NewWidth,NewHeight:TpvInt32); virtual;
       procedure MoveTo(ToX,ToY:TpvInt32); virtual;
       procedure LineTo(ToX,ToY:TpvInt32); virtual;
       procedure QuadraticCurveTo(const ControlX,ControlY,AnchorX,AnchorY:TpvInt32;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32); virtual;
       procedure CubicCurveTo(const c1x,c1y,c2x,c2y,ax,ay:TpvInt32;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32); virtual;
       procedure Close; virtual;
       procedure Render; virtual;
       property Canvas:TpvPointer read GetCanvas write SetCanvas;
       property Width:TpvInt32 read GetWidth write SetWidth;
       property Height:TpvInt32 read GetHeight write SetHeight;
       property WindingRule:TpvInt32 read GetWindingRule write SetWindingRule;
     end;

     TpvTrueTypeFontPolygonRasterizerGammaLookUpTable=array[TpvUInt8] of TpvUInt8;

     PpvTrueTypeFontPolygonRasterizerCell=^TpvTrueTypeFontPolygonRasterizerCell;
     TpvTrueTypeFontPolygonRasterizerCell=record
      Previous:PpvTrueTypeFontPolygonRasterizerCell;
      Next:PpvTrueTypeFontPolygonRasterizerCell;
      x:TpvInt32;
      Area:TpvInt32;
      Cover:TpvInt32;
     end;

     TpvTrueTypeFontPolygonRasterizerCells=array of PpvTrueTypeFontPolygonRasterizerCell;

     TpvTrueTypeFontPolygonRasterizerScanline=record
      CellFirst:PpvTrueTypeFontPolygonRasterizerCell;
      CellLast:PpvTrueTypeFontPolygonRasterizerCell;
     end;
     TpvTrueTypeFontPolygonRasterizerScanlines=array of TpvTrueTypeFontPolygonRasterizerScanline;

     TpvTrueTypeFontPolygonRasterizer=class(TpvTrueTypeFontRasterizer)
      protected
       fCurrentWidth:TpvInt32;
       fCurrentHeight:TpvInt32;
       fCurrentGamma:TpvDouble;
       fCurrentWindingRule:TpvInt32;
       fCurrentGammaLookUpTable:TpvTrueTypeFontPolygonRasterizerGammaLookUpTable;
       fCellX:TpvInt32;
       fCellY:TpvInt32;
       fArea:TpvInt32;
       fCover:TpvInt32;
       fCells:TpvTrueTypeFontPolygonRasterizerCells;
       fNumCells:TpvInt32;
       fX:TpvInt32;
       fY:TpvInt32;
       fMoveToX:TpvInt32;
       fMoveToY:TpvInt32;
       fScanlines:TpvTrueTypeFontPolygonRasterizerScanlines;
       fRenderMinY:TpvInt32;
       fRenderMaxY:TpvInt32;
       fNeedToClose:boolean;
       fCanvas:TpvPointer;
       fAntialiasing:boolean;
       fForceNonAntialiasing:boolean;
       function GetCanvas:TpvPointer; override;
       procedure SetCanvas(NewCanvas:TpvPointer); override;
       function GetWidth:TpvInt32; override;
       procedure SetWidth(NewWidth:TpvInt32); override;
       function GetHeight:TpvInt32; override;
       procedure SetHeight(NewHeight:TpvInt32); override;
       function GetWindingRule:TpvInt32; override;
       procedure SetWindingRule(NewWindingRule:TpvInt32); override;
       function NewCell:PpvTrueTypeFontPolygonRasterizerCell;
       procedure RecordCell;
       procedure SetCell(NewX,NewY:TpvInt32;Force:boolean=false);
       procedure StartCell(NewX,NewY:TpvInt32);
       procedure RenderScanLine(NewY,x1,y1,x2,y2:TpvInt32);
       procedure RenderLine(ToX,ToY:TpvInt32);
       procedure ProcessSpan(x,y,Area,Len:TpvInt32);
       procedure MakeScanLineSpansAndRenderThese;
       procedure SetGamma(AGamma:TpvDouble);
       procedure RenderSpanCoverage(y,x,Len,Coverage:TpvInt32); virtual;
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear; override;
       procedure Reset; override;
       procedure Resize(NewWidth,NewHeight:TpvInt32); override;
       procedure MoveTo(ToX,ToY:TpvInt32); override;
       procedure LineTo(ToX,ToY:TpvInt32); override;
       procedure Close; override;
       procedure Render; override;
       property Gamma:TpvDouble read fCurrentGamma write SetGamma;
       property GammaLookUpTable:TpvTrueTypeFontPolygonRasterizerGammaLookUpTable read fCurrentGammaLookUpTable write fCurrentGammaLookUpTable;
       property Antialiasing:boolean read fAntialiasing write fAntialiasing;
     end;

     TpvTrueTypeFontStrokeRasterizerPoint=record
      x:TpvInt32;
      y:TpvInt32;
      d:TpvInt32;
     end;

     TpvTrueTypeFontStrokeRasterizerPoints=array of TpvTrueTypeFontStrokeRasterizerPoint;

     TpvTrueTypeFontStrokeRasterizer=class(TpvTrueTypeFontRasterizer)
      private
       fLinePoints:TpvTrueTypeFontStrokeRasterizerPoints;
       fNumLinePoints:TpvInt32;
       fLineWidth:TpvDouble;
       fLineCapMode:TpvInt32;
       fLineJoinMode:TpvInt32;
       fLineInnerJoinMode:TpvInt32;
       fLineStrokePattern:TpvRawByteString;
       fLineStrokePatternStepSize:TpvDouble;
       fStartLineX:TpvInt32;
       fStartLineY:TpvInt32;
       fFlushLineOnWork:boolean;
       fRasterizer:TpvTrueTypeFontRasterizer;
       procedure AddLinePoint(const x,y:TpvInt32);
       procedure ConvertLineStorkeToPolygon;
       procedure FlushLine;
      protected
       function GetCanvas:TpvPointer; override;
       procedure SetCanvas(NewCanvas:TpvPointer); override;
       function GetWidth:TpvInt32; override;
       procedure SetWidth(NewWidth:TpvInt32); override;
       function GetHeight:TpvInt32; override;
       procedure SetHeight(NewHeight:TpvInt32); override;
       function GetWindingRule:TpvInt32; override;
       procedure SetWindingRule(NewWindingRule:TpvInt32); override;
      public
       constructor Create(Rasterizer:TpvTrueTypeFontRasterizer); reintroduce;
       destructor Destroy; override;
       procedure Clear; override;
       procedure Reset; override;
       procedure Resize(NewWidth,NewHeight:TpvInt32); override;
       procedure MoveTo(ToX,ToY:TpvInt32); override;
       procedure LineTo(ToX,ToY:TpvInt32); override;
       procedure Close; override;
       procedure Render; override;
       property LineWidth:TpvDouble read fLineWidth write fLineWidth;
       property LineCapMode:TpvInt32 read fLineCapMode write fLineCapMode;
       property LineJoinMode:TpvInt32 read fLineJoinMode write fLineJoinMode;
       property LineInnerJoinMode:TpvInt32 read fLineInnerJoinMode write fLineInnerJoinMode;
       property LineStrokePattern:TpvRawByteString read fLineStrokePattern write fLineStrokePattern;
       property LineStrokePatternStepSize:TpvDouble read fLineStrokePatternStepSize write fLineStrokePatternStepSize;
     end;

     PpvTrueTypeFontKerningPair=^TpvTrueTypeFontKerningPair;
     TpvTrueTypeFontKerningPair=record
      Left:TpvUInt32;
      Right:TpvUInt32;
      Value:TpvInt32;
     end;

     TpvTrueTypeFontKerningPairs=array of TpvTrueTypeFontKerningPair;

     PpvTrueTypeFontKerningTable=^TpvTrueTypeFontKerningTable;
     TpvTrueTypeFontKerningTable=record
      Horizontal:longbool;
      Minimum:longbool;
      XStream:longbool;
      ValueOverride:longbool;
      BinarySearch:longbool;
      KerningPairs:TpvTrueTypeFontKerningPairs;
      CountKerningPairs:TpvInt32;
     end;

     TpvTrueTypeFontKerningTables=array of TpvTrueTypeFontKerningTable;

     PpvTrueTypeFontGlyphPoint=^TpvTrueTypeFontGlyphPoint;
     TpvTrueTypeFontGlyphPoint=record
      x:TpvInt32;
      y:TpvInt32;
      Flags:TpvUInt32;
     end;
     TpvTrueTypeFontGlyphPoints=array of TpvTrueTypeFontGlyphPoint;

     TpvTrueTypeFontContour=record
      Points:TpvTrueTypeFontGlyphPoints;
     end;
     TpvTrueTypeFontContours=array of TpvTrueTypeFontContour;

     PpvTrueTypeFontGlyphCompositeSubGlyph=^TpvTrueTypeFontGlyphCompositeSubGlyph;
     TpvTrueTypeFontGlyphCompositeSubGlyph=record
      Glyph:TpvUInt32;
      Flags:TpvUInt32;
      Arg1:TpvInt32;
      Arg2:TpvInt32;
      xx:TpvInt32;
      yx:TpvInt32;
      xy:TpvInt32;
      yy:TpvInt32;
     end;

     TpvTrueTypeFontGlyphCompositeSubGlyphs=array of TpvTrueTypeFontGlyphCompositeSubGlyph;

     PpvTrueTypeFontGlyphBounds=^TpvTrueTypeFontGlyphBounds;
     TpvTrueTypeFontGlyphBounds=record
      XMin:TpvInt16;
      YMin:TpvInt16;
      XMax:TpvInt16;
      YMax:TpvInt16;
     end;

     TpvTrueTypeFontGlyphEndPointIndices=array of TpvInt32;

     PpvTrueTypeFontGlyphBuffer=^TpvTrueTypeFontGlyphBuffer;
     TpvTrueTypeFontGlyphBuffer=record
      Bounds:TpvTrueTypeFontGlyphBounds;
      Points:TpvTrueTypeFontGlyphPoints;
      UnhintedPoints:TpvTrueTypeFontGlyphPoints;
      InFontUnitsPoints:TpvTrueTypeFontGlyphPoints;
      EndPointIndices:TpvTrueTypeFontGlyphEndPointIndices;
      CountPoints:TpvInt32;
      CountIndices:TpvInt32;
     end;

     PpvTrueTypeFontByteArray=^TpvTrueTypeFontByteArray;
     TpvTrueTypeFontByteArray=array[0..65535] of TpvUInt8;

     PpvTrueTypeFontByteCodeInterpreterProgramBytes=^TpvTrueTypeFontByteCodeInterpreterProgramBytes;
     TpvTrueTypeFontByteCodeInterpreterProgramBytes=record
      Data:PpvTrueTypeFontByteArray;
      Size:TpvInt32;
     end;

     PpvTrueTypeFontPolygonCommandType=^TpvTrueTypeFontPolygonCommandType;
     TpvTrueTypeFontPolygonCommandType=
      (
       MoveTo,
       LineTo,
       QuadraticCurveTo,
       CubicCurveTo,
       Close
      );

     TpvTrueTypeFontPolygonCommandPoint=packed record
      x:TpvDouble;
      y:TpvDouble;
     end;

     TpvTrueTypeFontPolygonCommandPoints=array[0..2] of TpvTrueTypeFontPolygonCommandPoint;

     PpvTrueTypeFontPolygonCommand=^TpvTrueTypeFontPolygonCommand;
     TpvTrueTypeFontPolygonCommand=record
      CommandType:TpvTrueTypeFontPolygonCommandType;
      Points:TpvTrueTypeFontPolygonCommandPoints;
     end;

     TpvTrueTypeFontPolygonCommands=array of TpvTrueTypeFontPolygonCommand;

     PpvTrueTypeFontPolygon=^TpvTrueTypeFontPolygon;
     TpvTrueTypeFontPolygon=record
      Commands:TpvTrueTypeFontPolygonCommands;
     end;

     PpvTrueTypeFontPolygonBuffer=^TpvTrueTypeFontPolygonBuffer;
     TpvTrueTypeFontPolygonBuffer=record
      Commands:TpvTrueTypeFontPolygonCommands;
      CountCommands:TpvInt32;
      procedure ConvertToVectorPath(const aVectorPath:TpvVectorPath;const aFillRule:TpvInt32=pvTTF_PolygonWindingRule_NONZERO);
     end;

     TpvTrueTypeFontPolygonBuffers=array of TpvTrueTypeFontPolygonBuffer;

     PpvTrueTypeFontGlyph=^TpvTrueTypeFontGlyph;
     TpvTrueTypeFontGlyph=record
      Bounds:TpvTrueTypeFontGlyphBounds;
      Points:TpvTrueTypeFontGlyphPoints;
      EndPointIndices:TpvTrueTypeFontGlyphEndPointIndices;
      CompositeSubGlyphs:TpvTrueTypeFontGlyphCompositeSubGlyphs;
      UseMetricsFrom:TpvInt32;
      PostScriptPolygon:TpvTrueTypeFontPolygonBuffer;
      Instructions:TpvTrueTypeFontByteCodeInterpreterProgramBytes;
      Locked:longbool;
      AdvanceWidth:TpvInt32;
      AdvanceHeight:TpvInt32;
      LeftSideBearing:TpvInt32;
      TopSideBearing:TpvInt32;
     end;

     TpvTrueTypeFontGlyphs=array of TpvTrueTypeFontGlyph;

     TpvTrueTypeFontCVTTable=array of TpvInt32;

     TpvTrueTypeFontBytes=array of TpvUInt8;

     TpvTrueTypeFontLongWords=array of TpvUInt32;

     TpvTrueTypeFontCFFCodePointToGlyphIndexTable=array of TpvInt32;

     TpvTrueTypeFontGlyphIndexSubHeaderKeys=array[0..255] of TpvUInt16;

     PpvTrueTypeFontGASPRange=^TpvTrueTypeFontGASPRange;
     TpvTrueTypeFontGASPRange=record
      LowerPPEM:TpvInt32;
      UpperPPEM:TpvInt32;
      Flags:TpvUInt32;
     end;

     TpvTrueTypeFontGASPRanges=array of TpvTrueTypeFontGASPRange;

     TpvTrueTypeFontGlyphFlagBitmap=array of TpvUInt32;

     PpvTrueTypeFont2d14=^TpvTrueTypeFontVector2d14;
     TpvTrueTypeFont2d14=TpvInt16;

     PpvTrueTypeFont26d6=^TpvTrueTypeFontVector26d6;
     TpvTrueTypeFont26d6=TpvInt32;

     PpvTrueTypeFontVector2d14=^TpvTrueTypeFontVector2d14;
     TpvTrueTypeFontVector2d14=array[0..1] of TpvTrueTypeFont2d14;

     PpvTrueTypeFontVector26d6=^TpvTrueTypeFontVector26d6;
     TpvTrueTypeFontVector26d6=array[0..1] of TpvTrueTypeFont26d6;

     PpvTrueTypeFontVectorThreeInt32=^TpvTrueTypeFontVectorThreeInt32;
     TpvTrueTypeFontVectorThreeInt32=array[0..2] of TpvInt32;

     PpvTrueTypeFontGraphicsState=^TpvTrueTypeFontGraphicsState;
     TpvTrueTypeFontGraphicsState=record
      pv:TpvTrueTypeFontVector2d14;
      fv:TpvTrueTypeFontVector2d14;
      dv:TpvTrueTypeFontVector2d14;
      rp:TpvTrueTypeFontVectorThreeInt32;
      zp:TpvTrueTypeFontVectorThreeInt32;
      ControlValueCutIn:TpvTrueTypeFont26d6;
      SingleWidthCutIn:TpvTrueTypeFont26d6;
      SingleWidth:TpvTrueTypeFont26d6;
      DeltaBase:TpvInt32;
      DeltaShift:TpvInt32;
      MinDist:TpvTrueTypeFont26d6;
      Loop:TpvInt32;
      RoundPeriod:TpvTrueTypeFont26d6;
      RoundPhase:TpvTrueTypeFont26d6;
      RoundThreshold:TpvTrueTypeFont26d6;
      RoundSuper45:boolean;
      AutoFlip:boolean;
      InstructionControl:TpvInt32;
     end;

     TpvTrueTypeFontByteCodeInterpreterInt32Array=array of TpvInt32;

     TpvTrueTypeFontByteCodeInterpreterPoints=array[0..pvTTF_Zone_Count-1,0..pvTTF_PointType_Count-1] of TpvTrueTypeFontGlyphPoints;

     PpvTrueTypeFontByteCodeInterpreterCallStackEntry=^TpvTrueTypeFontByteCodeInterpreterCallStackEntry;
     TpvTrueTypeFontByteCodeInterpreterCallStackEntry=record
       ProgramBytes:TpvTrueTypeFontByteCodeInterpreterProgramBytes;
       PC:TpvInt32;
       LoopCount:TpvInt32;
     end;

     PpvTrueTypeFontByteCodeInterpreterCallStackEntries=^TpvTrueTypeFontByteCodeInterpreterCallStackEntries;
     TpvTrueTypeFontByteCodeInterpreterCallStackEntries=array[0..31] of TpvTrueTypeFontByteCodeInterpreterCallStackEntry;

     TpvTrueTypeFontByteCodeInterpreterFunctions=array of TpvTrueTypeFontByteCodeInterpreterProgramBytes;

     PpvTrueTypeFontByteCodeInterpreterParameters=^TpvTrueTypeFontByteCodeInterpreterParameters;
     TpvTrueTypeFontByteCodeInterpreterParameters=record
      pCurrent:TpvTrueTypeFontGlyphPoints;
      pUnhinted:TpvTrueTypeFontGlyphPoints;
      pInFontUnits:TpvTrueTypeFontGlyphPoints;
      Ends:TpvTrueTypeFontGlyphEndPointIndices;
     end;

     TpvTrueTypeFontByteCodeInterpreter=class
      private
       fFont:TpvTrueTypeFont;
{$ifdef ttfdebug}
       fLastCVT:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fLastStack:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fLastStorage:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fLastGraphicsState:TpvTrueTypeFontGraphicsState;
       fLastPoints:TpvTrueTypeFontByteCodeInterpreterPoints;
{$endif}
       fCVT:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fStack:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fStorage:TpvTrueTypeFontByteCodeInterpreterInt32Array;
       fFunctions:TpvTrueTypeFontByteCodeInterpreterFunctions;
       fScale:TpvInt32;
       fForceReinitialize:longbool;
       fGraphicsState:TpvTrueTypeFontGraphicsState;
       fDefaultGraphicsState:TpvTrueTypeFontGraphicsState;
       fPoints:TpvTrueTypeFontByteCodeInterpreterPoints;
       fEnds:TpvTrueTypeFontGlyphEndPointIndices;
      public
       constructor Create(AFont:TpvTrueTypeFont);
       destructor Destroy; override;
       procedure Reinitialize;
       function SkipInstructionPayload(const ProgramBytes:TpvTrueTypeFontByteCodeInterpreterProgramBytes;var PC:TpvInt32):boolean;
       function MulDiv(a,b,c:TpvInt32;DoRound:boolean):TpvInt32;
       procedure MovePoint(var p:TpvTrueTypeFontGlyphPoint;Distance:TpvInt32;Touch:boolean);
       function DotProduct(x,y:TpvTrueTypeFont26d6;const q:TpvTrueTypeFontVector2d14):TpvTrueTypeFont26d6;
       function Div18d14(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
       function Mul18d14(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
       function Div26d6(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
       function Mul26d6(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
       function RoundValue(Value:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
       procedure IUPInterpolate(IUPY:boolean;p1,p2,ref1,ref2:TpvInt32);
       procedure IUPShift(IUPY:boolean;p1,p2,p:TpvInt32);
       function GetPoint(ZonePointer,PointType,Index:TpvInt32):PpvTrueTypeFontGlyphPoint;
       procedure Normalize(var x,y:TpvTrueTypeFont26d6);
       function GetCVT(Index:TpvInt32):TpvInt32;
       procedure SetCVT(Index,Value:TpvInt32);
       procedure ComputePointDisplacement(Flag:boolean;var Zone,Ref:TpvInt32;var dx,dy:TpvTrueTypeFont26d6);
       procedure Run(ProgramBytes:TpvTrueTypeFontByteCodeInterpreterProgramBytes;Parameters:PpvTrueTypeFontByteCodeInterpreterParameters=nil);
       property Font:TpvTrueTypeFont read fFont;
     end;

     PpvTrueTypeFontSignedDistanceFieldJob=^TpvTrueTypeFontSignedDistanceFieldJob;
     TpvTrueTypeFontSignedDistanceFieldJob=record
      PolygonBuffer:TpvTrueTypeFontPolygonBuffer;
      Destination:TpvPointer;
      Width:TpvInt32;
      Height:TpvInt32;
      BoundsX0:TpvDouble;
      BoundsY0:TpvDouble;
      BoundsX1:TpvDouble;
      BoundsY1:TpvDouble;
     end;

     TpvTrueTypeFontSignedDistanceFieldJobs=array of TpvTrueTypeFontSignedDistanceFieldJob;

     PpvTrueTypeFontSignedDistanceFieldJobArray=^TpvTrueTypeFontSignedDistanceFieldJobArray;
     TpvTrueTypeFontSignedDistanceFieldJobArray=array[0..65535] of TpvTrueTypeFontSignedDistanceFieldJob;

     TpvTrueTypeFont=class
      private
       fGlyphBuffer:TpvTrueTypeFontGlyphBuffer;
       fPolygonBuffer:TpvTrueTypeFontPolygonBuffer;
       fFontData:TpvTrueTypeFontBytes;
       fGlyphLoadedBitmap:TpvTrueTypeFontGlyphFlagBitmap;
       fGlyphs:TpvTrueTypeFontGlyphs;
       fCMaps:array[0..1] of PpvTrueTypeFontByteArray;
       fCMapLengths:array[0..1] of TpvInt32;
       fGlyphOffsetArray:TpvTrueTypeFontLongWords;
       fKerningTables:TpvTrueTypeFontKerningTables;
       fSubHeaderKeys:TpvTrueTypeFontGlyphIndexSubHeaderKeys;
       fFontDataSize:TpvInt32;
       fGlyfOffset:TpvUInt32;
       fNumfHMetrics:TpvUInt16;
       fNumfVMetrics:TpvUInt16;
       fNumTables:TpvUInt16;
       fCMapFormat:TpvUInt16;
       fLastError:TpvUInt16;
       fPostScriptFlavored:boolean;
       fIndexToLocationFormat:TpvInt16;
       fStringCopyright:TpvRawByteString;
       fStringFamily:TpvRawByteString;
       fStringSubFamily:TpvRawByteString;
       fStringFullName:TpvRawByteString;
       fStringUniqueID:TpvRawByteString;
       fStringVersion:TpvRawByteString;
       fStringPostScript:TpvRawByteString;
       fStringTrademark:TpvRawByteString;
       fMinX:TpvInt16;
       fMinY:TpvInt16;
       fMaxX:TpvInt16;
       fMaxY:TpvInt16;
       fUnitsPerEm:TpvUInt16;
       fUnitsPerPixel:TpvUInt16;
       fThinBoldStrength:TpvInt32;
       fOS2Ascender:TpvInt16;
       fOS2Descender:TpvInt16;
       fOS2LineGap:TpvInt16;
       fHorizontalAscender:TpvInt16;
       fHorizontalDescender:TpvInt16;
       fHorizontalLineGap:TpvInt16;
       fVerticalAscender:TpvInt16;
       fVerticalDescender:TpvInt16;
       fVerticalLineGap:TpvInt16;
       fAdvanceWidthMax:TpvUInt16;
       fAdvanceHeightMax:TpvUInt16;
       fPlatformID:TpvUInt16;
       fSpecificID:TpvUInt16;
       fLanguageID:TpvUInt16;
       fSize:TpvInt32;
       fLetterSpacingX:TpvInt32;
       fLetterSpacingY:TpvInt32;
       fStyleIndex:TpvInt32;
       fTargetPPI:TpvInt32;
       fHinting:boolean;
       fForceSelector:boolean;
       fCountGlyphs:TpvInt32;
       fMaxTwilightPoints:TpvInt32;
       fMaxStorage:TpvInt32;
       fMaxFunctionDefs:TpvInt32;
       fMaxStackElements:TpvInt32;
       fCVT:TpvTrueTypeFontCVTTable;
       fFPGM:TpvTrueTypeFontByteCodeInterpreterProgramBytes;
       fPREP:TpvTrueTypeFontByteCodeInterpreterProgramBytes;
       fByteCodeInterpreter:TpvTrueTypeFontByteCodeInterpreter;
       fByteCodeInterpreterParameters:TpvTrueTypeFontByteCodeInterpreterParameters;
       fIgnoreByteCodeInterpreter:boolean;
       fGASPRanges:TpvTrueTypeFontGASPRanges;
       fCFFCodePointToGlyphIndexTable:TpvTrueTypeFontCFFCodePointToGlyphIndexTable;
       function ReadFontData(Stream:TStream;CollectionIndex:TpvInt32):TpvInt32;
       function GetTableDirEntry(Tag:TpvUInt32;var CheckSum,Offset,Size:TpvUInt32):TpvInt32;
       function LoadOS2:TpvInt32;
       function LoadHEAD:TpvInt32;
       function LoadMAXP:TpvInt32;
       function LoadNAME:TpvInt32;
       function LoadCFF:TpvInt32;
       function LoadLOCA:TpvInt32;
       function LoadGLYF:TpvInt32;
       function LoadHHEA:TpvInt32;
       function LoadHMTX:TpvInt32;
       function LoadVHEA:TpvInt32;
       function LoadVMTX:TpvInt32;
       function LoadGPOS:TpvInt32;
       function LoadKERN:TpvInt32;
       function LoadCMAP:TpvInt32;
       function LoadCVT:TpvInt32;
       function LoadFPGM:TpvInt32;
       function LoadPREP:TpvInt32;
       function LoadGASP:TpvInt32;
       function LoadGlyphData(GlyphIndex:TpvInt32):TpvInt32;
       procedure SetSize(NewSize:TpvInt32);
       procedure GenerateSimpleLinearSignedDistanceFieldTextureArrayParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
      public
       constructor Create(const Stream:TStream;const TargetPPI:TpvInt32=96;const ForceSelector:boolean=false;const PlatformID:TpvUInt16=pvTTF_PID_Microsoft;const SpecificID:TpvUInt16=pvTTF_SID_MS_UNICODE_CS;const LanguageID:TpvUInt16=pvTTF_LID_MS_USEnglish;const CollectionIndex:TpvInt32=0);
       destructor Destroy; override;
       function GetGASPRange:PpvTrueTypeFontGASPRange;
       function GetGlyphIndex(CodePointCode:TpvUInt32;CMapIndex:TpvInt32=0):TpvUInt32;
       function GetGlyphAdvanceWidth(GlyphIndex:TpvInt32):TpvInt32;
       function GetGlyphAdvanceHeight(GlyphIndex:TpvInt32):TpvInt32;
       function GetGlyphLeftSideBearing(GlyphIndex:TpvInt32):TpvInt32;
       function GetGlyphRightSideBearing(GlyphIndex:TpvInt32):TpvInt32;
       function GetGlyphTopSideBearing(GlyphIndex:TpvInt32):TpvInt32;
       function GetGlyphBottomSideBearing(GlyphIndex:TpvInt32):TpvInt32;
       function GetKerning(Left,Right:TpvUInt32;Horizontal:boolean):TpvInt32;
       function GetStyleIndex(Thin,Bold,Italic:boolean):TpvInt32;
       function TextWidth(const aText:TpvUTF8String):TpvInt32;
       function TextHeight(const aText:TpvUTF8String):TpvInt32;
       procedure TextSize(const aText:TpvUTF8String;out aWidth,aHeight:TpvInt32);
       function RowHeight(const Percent:TpvInt32):TpvInt32;
       function GetUnitsPerEm:TpvInt32;
       function GetScaleFactor:TpvDouble;
       function GetScaleFactorFixed:TpvInt32;
       function Scale(Value:TpvInt32):TpvInt32;
       function FloatScale(Value:TpvDouble):TpvDouble;
       function GetScale:TpvInt32;
       function ScaleRound(Value:TpvInt32):TpvInt32;
       function IsPostScriptGlyph(const GlyphIndex:TpvInt32):boolean;
       procedure ResetGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer);
       procedure TransformGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer;GlyphStartPointIndex,StartIndex,EndIndex:TpvInt32);
       procedure FillGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer;const GlyphIndex:TpvInt32);
       procedure ResetPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer);
       procedure FillPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const GlyphBuffer:TpvTrueTypeFontGlyphBuffer);
       procedure FillPostScriptPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const GlyphIndex:TpvInt32);
       procedure FillTextPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const Text:TpvUTF8String;const StartX:TpvInt32=0;const StartY:TpvInt32=0);
       procedure GetPolygonBufferBounds(const PolygonBuffer:TpvTrueTypeFontPolygonBuffer;out x0,y0,x1,y1:TpvDouble;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32);
       procedure DrawPolygonBuffer(Rasterizer:TpvTrueTypeFontRasterizer;const PolygonBuffer:TpvTrueTypeFontPolygonBuffer;x,y:TpvInt32;Tolerance:TpvInt32=2;MaxLevel:TpvInt32=32);
       procedure GenerateSimpleLinearSignedDistanceFieldTextureArray(const aDestinationData:TpvPointer;
                                                                     const aTextureArrayWidth:TpvInt32;
                                                                     const aTextureArrayHeight:TpvInt32;
                                                                     const aTextureArrayDepth:TpvInt32);
       property TargetPPI:TpvInt32 read fTargetPPI;
       property Glyphs:TpvTrueTypeFontGlyphs read fGlyphs;
       property CountGlyphs:TpvInt32 read fCountGlyphs;
       property KerningTables:TpvTrueTypeFontKerningTables read fKerningTables;
       property Size:TpvInt32 read fSize write SetSize;
       property LetterSpacingX:TpvInt32 read fLetterSpacingX write fLetterSpacingX;
       property LetterSpacingY:TpvInt32 read fLetterSpacingY write fLetterSpacingY;
       property StyleIndex:TpvInt32 read fStyleIndex write fStyleIndex;
       property Hinting:boolean read fHinting write fHinting;
       property GASPRanges:TpvTrueTypeFontGASPRanges read fGASPRanges;
       property MinX:TpvInt16 read fMinX;
       property MinY:TpvInt16 read fMinY;
       property MaxX:TpvInt16 read fMaxX;
       property MaxY:TpvInt16 read fMaxY;
       property OS2Ascender:TpvInt16 read fOS2Ascender;
       property OS2Descender:TpvInt16 read fOS2Descender;
       property OS2LineGap:TpvInt16 read fOS2LineGap;
       property HorizontalAscender:TpvInt16 read fHorizontalAscender;
       property HorizontalDescender:TpvInt16 read fHorizontalDescender;
       property HorizontalLineGap:TpvInt16 read fHorizontalLineGap;
       property VerticalAscender:TpvInt16 read fVerticalAscender;
       property VerticalDescender:TpvInt16 read fVerticalDescender;
       property VerticalLineGap:TpvInt16 read fVerticalLineGap;
       property AdvanceWidthMax:TpvUInt16 read fAdvanceWidthMax;
       property AdvanceHeightMax:TpvUInt16 read fAdvanceHeightMax;
       property Copyright:TpvRawByteString read fStringCopyright;
       property Family:TpvRawByteString read fStringFamily;
       property SubFamily:TpvRawByteString read fStringSubFamily;
       property FullName:TpvRawByteString read fStringFullName;
       property UniqueID:TpvRawByteString read fStringUniqueID;
       property Version:TpvRawByteString read fStringVersion;
       property PostScript:TpvRawByteString read fStringPostScript;
       property Trademark:TpvRawByteString read fStringTrademark;
     end;

implementation

uses PasVulkan.Utils,
     PasVulkan.Framework,
     PasVulkan.SignedDistanceField2D;

const PixelBits=8;
      PixelFactor=1 shl PixelBits;
      HalfPixel=PixelFactor shr 1;
      OnePixel=PixelFactor;
      PixelMask=PixelFactor-1;

      deg2rad=pi/180;
      rad2deg=180/pi;

      ARGS_ARE_WORDS=$0001;
      ARGS_ARE_XY_VALUES=$0002;
      ROUND_XY_TO_GRID=$0004;
      WE_HAVE_A_SCALE=$0008;
      MORE_COMPONENTS=$0020;
      WE_HAVE_AN_XY_SCALE=$0040;
      WE_HAVE_A_2X2=$0080;
      WE_HAVE_INSTR=$0100;
      USE_MY_METRICS=$0200;
      OVERLAP_COMPOUND=$0400;
      SCALED_COMPONENT_OFFSET=$0800;
      UNSCALED_COMPONENT_OFFSET=$1000;

      // https://developer.apple.com/fonts/TTRefMan/RM07/appendixA.html

      opSVTCA0=$00;    // Set freedom and projection Vectors To Coordinate Axis
      opSVTCA1=$01;    // .
      opSPVTCA0=$02;   // Set Projection Vector To Coordinate Axis
      opSPVTCA1=$03;   // .
      opSFVTCA0=$04;   // Set Freedom Vector to Coordinate Axis
      opSFVTCA1=$05;   // .
      opSPVTL0=$06;    // Set Projection Vector To Line
      opSPVTL1=$07;    // .
      opSFVTL0=$08;    // Set Freedom Vector To Line
      opSFVTL1=$09;    // .
      opSPVFS=$0a;     // Set Projection Vector From Stack
      opSFVFS=$0b;     // Set Freedom Vector From Stack
      opGPV=$0c;       // Get Projection Vector
      opGFV=$0d;       // Get Freedom Vector
      opSFVTPV=$0e;    // Set Freedom Vector To Projection Vector
      opISECT=$0f;     // move point to InterSECTion of two lines
      opSRP0=$10;      // Set Reference Point 0
      opSRP1=$11;      // Set Reference Point 1
      opSRP2=$12;      // Set Reference Point 2
      opSZP0=$13;      // Set Zone TpvPointer 0
      opSZP1=$14;      // Set Zone TpvPointer 1
      opSZP2=$15;      // Set Zone TpvPointer 2
      opSZPS=$16;      // Set Zone PointerS
      opSLOOP=$17;     // Set LOOP variable
      opRTG=$18;       // Round To Grid
      opRTHG=$19;      // Round To Half Grid
      opSMD=$1a;       // Set Minimum Distance
      opELSE=$1b;      // ELSE clause
      opJMPR=$1c;      // JuMP Relative
      opSCVTCI=$1d;    // Set Control Value Table Cut-In
      opSSWCI=$1e;     // Set Single Width Cut-In
      opSSW=$1f;       // Set Single Width
      opDUP=$20;       // DUPlicate top stack element
      opPOP=$21;       // POP top stack element
      opCLEAR=$22;     // CLEAR the stack
      opSWAP=$23;      // SWAP the top two elements on the stack
      opDEPTH=$24;     // DEPTH of the stack
      opCINDEX=$25;    // Copy the INDEXed element to the top of the stack
      opMINDEX=$26;    // Move the INDEXed element to the top of the stack
      opALIGNPTS=$27;  // ALIGN PoinTS
      op_0x28=$28;
      opUTP=$29;       // UnTouch Point
      opLOOPCALL=$2a;  // LOOP and CALL function
      opCALL=$2b;      // CALL function
      opFDEF=$2c;      // Function DEFinition
      opENDF=$2d;      // END Function definition
      opMDAP0=$2e;     // Move Direct Absolute Point
      opMDAP1=$2f;     // .
      opIUP0=$30;      // Interpolate Untouched Points through the Stroke
      opIUP1=$31;      // .
      opSHP0=$32;      // SHift Point by the last point
      opSHP1=$33;      // .
      opSHC0=$34;      // SHift Contour by the last point
      opSHC1=$35;      // .
      opSHZ0=$36;      // SHift Zone by the last point
      opSHZ1=$37;      // .
      opSHPIX=$38;     // SHift Point by a piXel amount
      opIP=$39;        // Interpolate Point
      opMSIRP0=$3a;    // Move Stack Indirect Relative Point
      opMSIRP1=$3b;    // .
      opALIGNRP=$3c;   // ALIGN to Reference Point
      opRTDG=$3d;      // Round To TpvDouble Grid
      opMIAP0=$3e;     // Move Indirect Absolute Point
      opMIAP1=$3f;     // .
      opNPUSHB=$40;    // PUSH N Bytes
      opNPUSHW=$41;    // PUSH N Words
      opWS=$42;        // Write Store
      opRS=$43;        // Read Store
      opWCVTP=$44;     // Write Control Value Table in Pixels
      opRCVT=$45;      // Read Control Value Table
      opGC0=$46;       // Get Coordinate projected onto the projection vector with current coordinates
      opGC1=$47;       // Get Coordinate projected onto the projection vector with original coordinates
      opSCFS=$48;      // Set Coordinate From Stack using projection and freedom vector
      opMD0=$49;       // Measure Distance with current coordinates
      opMD1=$4a;       // Measure Distance with original coordinates
      opMPPEM=$4b;     // Measure Pixels Per EM
      opMPS=$4c;       // Measure Point Size
      opFLIPON=$4d;    // set the auto FLIP Boolean to ON
      opFLIPOFF=$4e;   // set the auto FLIP Boolean to OFF
      opDEBUG=$4f;     // DEBUG call
      opLT=$50;        // Less Than
      opLTEQ=$51;      // Less Than or EQual
      opGT=$52;        // Greater Than
      opGTEQ=$53;      // Greater Than or EQual
      opEQ=$54;        // EQual
      opNEQ=$55;       // Not EQual
      opODD=$56;       // ODD
      opEVEN=$57;      // EVEN
      opIF=$58;        // IF test
      opEIF=$59;       // End IF
      opAND=$5a;       // logical AND
      opOR=$5b;        // logical OR
      opNOT=$5c;       // logical NOT
      opDELTAP1=$5d;   // DELTA exception P1
      opSDB=$5e;       // Set Delta Base in the graphics state
      opSDS=$5f;       // Set Delta Shift in the graphics state
      opADD=$60;       // ADD
      opSUB=$61;       // SUBtract
      opDIV=$62;       // DIVide
      opMUL=$63;       // MULtiply
      opABS=$64;       // ABSolute value
      opNEG=$65;       // NEGate
      opFLOOR=$66;     // FLOOR
      opCEILING=$67;   // CEILING
      opROUND00=$68;   // ROUND value
      opROUND01=$69;   // .
      opROUND10=$6a;   // .
      opROUND11=$6b;   // .
      opNROUND00=$6c;  // No ROUNDing of value
      opNROUND01=$6d;  // .
      opNROUND10=$6e;  // .
      opNROUND11=$6f;  // .
      opWCVTF=$70;     // Write Control Value Table in Font units
      opDELTAP2=$71;   // DELTA exception P2
      opDELTAP3=$72;   // DELTA exception P3
      opDELTAC1=$73;   // DELTA exception C1
      opDELTAC2=$74;   // DELTA exception C2
      opDELTAC3=$75;   // DELTA exception C3
      opSROUND=$76;    // Super ROUND
      opS45ROUND=$77;  // Super ROUND 45 degrees
      opJROT=$78;      // Jump Relative On True
      opJROF=$79;      // Jump Relative On False
      opROFF=$7a;      // Round OFF
      op_0x7b=$7b;
      opRUTG=$7c;      // Round Up To Grid
      opRDTG=$7d;      // Round Down To Grid
      opSANGW=$7e;     // Set ANGle Weight
      opAA=$7f;        // Adjust Angle
      opFLIPPT=$80;    // FLIP PoinT
      opFLIPRGON=$81;  // FLIP RanGe ON
      opFLIPRGOFF=$82; // FLIP RanGe OFF
      op_0x83=$83;
      op_0x84=$84;
      opSCANCTRL=$85;  // SCAN conversion ConTRoL
      opSDPVTL0=$86;   // Set Dual Projection Vector To Line
      opSDPVTL1=$87;   // .
      opGETINFO=$88;   // GET INFOrmation
      opIDEF=$89;      // Instruction DEFinition
      opROLL=$8a;      // ROLL the top three stack elements
      opMAX=$8b;       // MAXimum of top two stack elements
      opMIN=$8c;       // MINimum of top two stack elements
      opSCANTYPE=$8d;  // SCANTYPE
      opINSTCTRL=$8e;  // INSTruction ConTRoL
      op_0x8f=$8f;
      op_0x90=$90;
      op_0x91=$91;
      op_0x92=$92;
      op_0x93=$93;
      op_0x94=$94;
      op_0x95=$95;
      op_0x96=$96;
      op_0x97=$97;
      op_0x98=$98;
      op_0x99=$99;
      op_0x9a=$9a;
      op_0x9b=$9b;
      op_0x9c=$9c;
      op_0x9d=$9d;
      op_0x9e=$9e;
      op_0x9f=$9f;
      op_0xa0=$a0;
      op_0xa1=$a1;
      op_0xa2=$a2;
      op_0xa3=$a3;
      op_0xa4=$a4;
      op_0xa5=$a5;
      op_0xa6=$a6;
      op_0xa7=$a7;
      op_0xa8=$a8;
      op_0xa9=$a9;
      op_0xaa=$aa;
      op_0xab=$ab;
      op_0xac=$ac;
      op_0xad=$ad;
      op_0xae=$ae;
      op_0xaf=$af;
      opPUSHB000=$b0;  // PUSH Bytes
      opPUSHB001=$b1;  // .
      opPUSHB010=$b2;  // .
      opPUSHB011=$b3;  // .
      opPUSHB100=$b4;  // .
      opPUSHB101=$b5;  // .
      opPUSHB110=$b6;  // .
      opPUSHB111=$b7;  // .
      opPUSHW000=$b8;  // PUSH Words
      opPUSHW001=$b9;  // .
      opPUSHW010=$ba;  // .
      opPUSHW011=$bb;  // .
      opPUSHW100=$bc;  // .
      opPUSHW101=$bd;  // .
      opPUSHW110=$be;  // .
      opPUSHW111=$bf;  // .
      opMDRP00000=$c0; // Move Direct Relative Point
      opMDRP00001=$c1; // .
      opMDRP00010=$c2; // .
      opMDRP00011=$c3; // .
      opMDRP00100=$c4; // .
      opMDRP00101=$c5; // .
      opMDRP00110=$c6; // .
      opMDRP00111=$c7; // .
      opMDRP01000=$c8; // .
      opMDRP01001=$c9; // .
      opMDRP01010=$ca; // .
      opMDRP01011=$cb; // .
      opMDRP01100=$cc; // .
      opMDRP01101=$cd; // .
      opMDRP01110=$ce; // .
      opMDRP01111=$cf; // .
      opMDRP10000=$d0; // .
      opMDRP10001=$d1; // .
      opMDRP10010=$d2; // .
      opMDRP10011=$d3; // .
      opMDRP10100=$d4; // .
      opMDRP10101=$d5; // .
      opMDRP10110=$d6; // .
      opMDRP10111=$d7; // .
      opMDRP11000=$d8; // .
      opMDRP11001=$d9; // .
      opMDRP11010=$da; // .
      opMDRP11011=$db; // .
      opMDRP11100=$dc; // .
      opMDRP11101=$dd; // .
      opMDRP11110=$de; // .
      opMDRP11111=$df; // .
      opMIRP00000=$e0; // Move Indirect Relative Point
      opMIRP00001=$e1; // .
      opMIRP00010=$e2; // .
      opMIRP00011=$e3; // .
      opMIRP00100=$e4; // .
      opMIRP00101=$e5; // .
      opMIRP00110=$e6; // .
      opMIRP00111=$e7; // .
      opMIRP01000=$e8; // .
      opMIRP01001=$e9; // .
      opMIRP01010=$ea; // .
      opMIRP01011=$eb; // .
      opMIRP01100=$ec; // .
      opMIRP01101=$ed; // .
      opMIRP01110=$ee; // .
      opMIRP01111=$ef; // .
      opMIRP10000=$f0; // .
      opMIRP10001=$f1; // .
      opMIRP10010=$f2; // .
      opMIRP10011=$f3; // .
      opMIRP10100=$f4; // .
      opMIRP10101=$f5; // .
      opMIRP10110=$f6; // .
      opMIRP10111=$f7; // .
      opMIRP11000=$f8; // .
      opMIRP11001=$f9; // .
      opMIRP11010=$fa; // .
      opMIRP11011=$fb; // .
      opMIRP11100=$fc; // .
      opMIRP11101=$fd; // .
      opMIRP11110=$fe; // .
      opMIRP11111=$ff; // .

      x=255;

      OpcodePopCount:array[0..255] of TpvUInt8=
       (
     // 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f
        0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,5, // 0
        1,1,1,1,1,1,1,1,0,0,1,0,1,1,1,1, // 1
        1,1,0,2,0,1,1,2,x,1,2,1,1,0,1,1, // 2
        0,0,0,0,1,1,1,1,0,0,2,2,0,0,2,2, // 3
        0,0,2,1,2,0,0,0,2,1,1,0,0,0,0,0, // 4
        2,2,2,2,2,2,1,1,1,0,2,2,1,0,1,1, // 5
        2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1, // 6
        2,0,0,0,0,0,1,1,2,2,0,x,0,0,1,1, // 7
        0,2,2,x,x,1,2,2,1,1,3,2,2,1,x,x, // 8
        x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x, // 9
        x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x, // a
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // b
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // c
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // d
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, // e
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2  // f
       );

      DefaultGraphicsStateControlValueCutIn=(17 shl 6) div 16;

      DefaultGraphicsState:TpvTrueTypeFontGraphicsState=
       (
        pv:($4000,0);
        fv:($4000,0);
        dv:($4000,0);
        rp:(0,0,0);
        zp:(1,1,1);
        ControlValueCutIn:DefaultGraphicsStateControlValueCutIn;
        SingleWidthCutIn:0;
        SingleWidth:0;
        DeltaBase:9;
        DeltaShift:3;//1;
        MinDist:1 shl 6;
        Loop:1;
        RoundPeriod:1 shl 6;
        RoundPhase:0;
        RoundThreshold:1 shl 5;
        RoundSuper45:false;
        AutoFlip:true;
        InstructionControl:0;
       );

      OpcodeNames:array[0..255] of TpvRawByteString=
       (
        'SVTCA y','SVTCA x','SPVTCA y','SPVTCA x','SFVTCA y','SFVTCA x','SPVTL ||','SPVTL +',
        'SFVTL ||','SFVTL +','SPVFS','SFVFS','GPV','GFV','SFVTPV','ISECT',
        'SRP0','SRP1','SRP2','SZP0','SZP1','SZP2','SZPS','SLOOP',
        'RTG','RTHG','SMD','ELSE','JMPR','SCVTCI','SSWCI','SSW',
        'DUP','POP','CLEAR','SWAP','DEPTH','CINDEX','MINDEX','ALIGNPTS',
        'INS_$28','INS_$29','LOOPCALL','CALL','FDEF','ENDF','MDAP[0]','MDAP[1]',
        'IUP[0]','IUP[1]','SHP[0]','SHP[1]','SHC[0]','SHC[1]','SHZ[0]','SHZ[1]',
        'SHPIX','IP','MSIRP[0]','MSIRP[1]','ALIGNRP','RTDG','MIAP[0]','MIAP[1]',
        'NPUSHB','NPUSHW','WS','RS','WCVTP','RCVT','GC[0]','GC[1]',
        'SCFS','MD[0]','MD[1]','MPPEM','MPS','FLIPON','FLIPOFF','DEBUG',
        'LT','LTEQ','GT','GTEQ','EQ','NEQ','ODD','EVEN',
        'IF','EIF','AND','OR','NOT','DELTAP1','SDB','SDS',
        'ADD','SUB','DIV','MUL','ABS','NEG','FLOOR','CEILING',
        'ROUND[0]','ROUND[1]','ROUND[2]','ROUND[3]','NROUND[0]','NROUND[1]','NROUND[2]','NROUND[3]',
        'WCVTF','DELTAP2','DELTAP3','DELTAC1','DELTAC2','DELTAC3','SROUND','S45ROUND',
        'JROT','JROF','ROFF','INS_$7B','RUTG','RDTG','SANGW','AA',
        'FLIPPT','FLIPRGON','FLIPRGOFF','INS_$83','INS_$84','SCANCTRL','SDPVTL[0]','SDPVTL[1]',
        'GETINFO','IDEF','ROLL','MAX','MIN','SCANTYPE','INSTCTRL','INS_$8F',
        'INS_$90','INS_$91','INS_$92','INS_$93','INS_$94','INS_$95','INS_$96','INS_$97',
        'INS_$98','INS_$99','INS_$9A','INS_$9B','INS_$9C','INS_$9D','INS_$9E','INS_$9F',
        'INS_$A0','INS_$A1','INS_$A2','INS_$A3','INS_$A4','INS_$A5','INS_$A6','INS_$A7',
        'INS_$A8','INS_$A9','INS_$AA','INS_$AB','INS_$AC','INS_$AD','INS_$AE','INS_$AF',
        'PUSHB[0]','PUSHB[1]','PUSHB[2]','PUSHB[3]','PUSHB[4]','PUSHB[5]','PUSHB[6]','PUSHB[7]',
        'PUSHW[0]','PUSHW[1]','PUSHW[2]','PUSHW[3]','PUSHW[4]','PUSHW[5]','PUSHW[6]','PUSHW[7]',
        'MDRP[G]','MDRP[B]','MDRP[W]','MDRP[?]','MDRP[rG]','MDRP[rB]','MDRP[rW]','MDRP[r?]',
        'MDRP[mG]','MDRP[mB]','MDRP[mW]','MDRP[m?]','MDRP[mrG]','MDRP[mrB]','MDRP[mrW]','MDRP[mr?]',
        'MDRP[pG]','MDRP[pB]','MDRP[pW]','MDRP[p?]','MDRP[prG]','MDRP[prB]','MDRP[prW]','MDRP[pr?]',
        'MDRP[pmG]','MDRP[pmB]','MDRP[pmW]','MDRP[pm?]','MDRP[pmrG]','MDRP[pmrB]','MDRP[pmrW]','MDRP[pmr?]',
        'MIRP[G]','MIRP[B]','MIRP[W]','MIRP[?]','MIRP[rG]','MIRP[rB]','MIRP[rW]','MIRP[r?]',
        'MIRP[mG]','MIRP[mB]','MIRP[mW]','MIRP[m?]','MIRP[mrG]','MIRP[mrB]','MIRP[mrW]','MIRP[mr?]',
        'MIRP[pG]','MIRP[pB]','MIRP[pW]','MIRP[p?]','MIRP[prG]','MIRP[prB]','MIRP[prW]','MIRP[pr?]',
        'MIRP[pmG]','MIRP[pmB]','MIRP[pmW]','MIRP[pm?]','MIRP[pmrG]','MIRP[pmrB]','MIRP[pmrW]','MIRP[pmr?]'
       );

{$ifndef HasSAR}
function SARLongint(Value,Shift:TpvInt32):TpvInt32;
{$ifdef cpu386}
{$ifdef fpc} assembler; register; //inline;
asm
 mov ecx,edx
 sar eax,cl
end;// ['eax','edx','ecx'];
{$else} assembler; register;
asm
 mov ecx,edx
 sar eax,cl
end;
{$endif}
{$else}
{$ifdef cpuarm} assembler; //inline;
asm
 mov r0,r0,asr R1
end;// ['r0','R1'];
{$else}{$ifdef CAN_INLINE}inline;{$endif}
begin
 Shift:=Shift and 31;
 result:=(TpvUInt32(Value) shr Shift) or (TpvUInt32(TpvInt32(TpvUInt32(0-TpvUInt32(TpvUInt32(Value) shr 31)) and TpvUInt32(0-TpvUInt32(ord(Shift<>0) and 1)))) shl (32-Shift));
end;
{$endif}
{$endif}
{$endif}

{$ifndef HasSAR}
function SARInt64(Value:TpvInt64;Shift:TpvInt32):TpvInt64;{$ifdef UseRegister}register;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
begin
 Shift:=Shift and 63;
 result:=TpvInt64(TpvUInt64(TpvUInt64(TpvUInt64(Value) shr Shift) or (TpvUInt64(TpvInt64(TpvUInt64(0-TpvUInt64(TpvUInt64(Value) shr 63)) and TpvUInt64(TpvInt64(0-(ord(Shift<>0) and 1))))) shl (64-Shift))));
end;
{$endif}

function RoundUpToPowerOfTwo(x:TpvUInt32):TpvUInt32;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 result:=x+1;
end;

function MulFix(a,b:TpvInt32):TpvInt32;
var s:TpvInt32;
begin
 s:=1;
 if a<0 then begin
  a:=-a;
  s:=-1;
 end;
 if b<0 then begin
  b:=-b;
  s:=-s;
 end;
 result:=((TpvInt64(a)*TpvInt64(b))+$8000) div 65536;
 if s<0 then begin
  result:=-result;
 end;
end;

function SQRTFixed(x:TpvInt32):TpvInt32;
var rh,rl,td:TpvUInt32;
    c:TpvInt32;
begin
 result:=0;
 if x>0 then begin
  rh:=0;
  rl:=x;
  c:=24;
  repeat
   rh:=(rh shl 2) or (rl shr 30);
   rl:=rl shl 2;
   result:=result shl 1;
   td:=(result shl 1)+1;
   if rh>=td then begin
    dec(rh,td);
    inc(result);
   end;
   dec(c);
  until c=0;
 end;
end;

function MSB(v:TpvUInt32):TpvInt32;
begin
 result:=0;
 if (v and $ffff0000)<>0 then begin
  v:=v shr 16;
  inc(result,16);
 end;
 if (v and $ff00)<>0 then begin
  v:=v shr 8;
  inc(result,8);
 end;
 if (v and $f0)<>0 then begin
  v:=v shr 4;
  inc(result,4);
 end;
 if (v and $c)<>0 then begin
  v:=v shr 2;
  inc(result,2);
 end;
 if (v and 2)<>0 then begin
  inc(result);
 end;
end;

procedure Transform(var x,y:TpvInt32;xx,yx,xy,yy:TpvInt32);
var xz,yz:TpvInt32;
begin
 xz:=MulFix(x,xx)+MulFix(y,xy);
 yz:=MulFix(x,yx)+MulFix(y,yy);
 x:=xz;
 y:=yz;
end;

function isqrt(x:TpvUInt32):TpvUInt32;
const isqrtLookUpTable:array[0..1023] of TpvUInt32=(
       0,2048,2896,3547,4096,4579,5017,5418,5793,6144,6476,6792,7094,7384,7663,7932,8192,8444,
       8689,8927,9159,9385,9606,9822,10033,10240,10443,10642,10837,11029,11217,11403,11585,
       11765,11942,12116,12288,12457,12625,12790,12953,13114,13273,13430,13585,13738,13890,
       14040,14189,14336,14482,14626,14768,14910,15050,15188,15326,15462,15597,15731,15864,
       15995,16126,16255,16384,16512,16638,16764,16888,17012,17135,17257,17378,17498,17618,
       17736,17854,17971,18087,18203,18318,18432,18545,18658,18770,18882,18992,19102,19212,
       19321,19429,19537,19644,19750,19856,19961,20066,20170,20274,20377,20480,20582,20684,
       20785,20886,20986,21085,21185,21283,21382,21480,21577,21674,21771,21867,21962,22058,
       22153,22247,22341,22435,22528,22621,22713,22806,22897,22989,23080,23170,23261,23351,
       23440,23530,23619,23707,23796,23884,23971,24059,24146,24232,24319,24405,24491,24576,
       24661,24746,24831,24915,24999,25083,25166,25249,25332,25415,25497,25580,25661,25743,
       25824,25905,25986,26067,26147,26227,26307,26387,26466,26545,26624,26703,26781,26859,
       26937,27015,27092,27170,27247,27324,27400,27477,27553,27629,27705,27780,27856,27931,
       28006,28081,28155,28230,28304,28378,28452,28525,28599,28672,28745,28818,28891,28963,
       29035,29108,29180,29251,29323,29394,29466,29537,29608,29678,29749,29819,29890,29960,
       30030,30099,30169,30238,30308,30377,30446,30515,30583,30652,30720,30788,30856,30924,
       30992,31059,31127,31194,31261,31328,31395,31462,31529,31595,31661,31727,31794,31859,
       31925,31991,32056,32122,32187,32252,32317,32382,32446,32511,32575,32640,32704,32768,
       32832,32896,32959,33023,33086,33150,33213,33276,33339,33402,33465,33527,33590,33652,
       33714,33776,33839,33900,33962,34024,34086,34147,34208,34270,34331,34392,34453,34514,
       34574,34635,34695,34756,34816,34876,34936,34996,35056,35116,35176,35235,35295,35354,
       35413,35472,35531,35590,35649,35708,35767,35825,35884,35942,36001,36059,36117,36175,
       36233,36291,36348,36406,36464,36521,36578,36636,36693,36750,36807,36864,36921,36978,
       37034,37091,37147,37204,37260,37316,37372,37429,37485,37540,37596,37652,37708,37763,
       37819,37874,37929,37985,38040,38095,38150,38205,38260,38315,38369,38424,38478,38533,
       38587,38642,38696,38750,38804,38858,38912,38966,39020,39073,39127,39181,39234,39287,
       39341,39394,39447,39500,39553,39606,39659,39712,39765,39818,39870,39923,39975,40028,
       40080,40132,40185,40237,40289,40341,40393,40445,40497,40548,40600,40652,40703,40755,
       40806,40857,40909,40960,41011,41062,41113,41164,41215,41266,41317,41368,41418,41469,
       41519,41570,41620,41671,41721,41771,41821,41871,41922,41972,42021,42071,42121,42171,
       42221,42270,42320,42369,42419,42468,42518,42567,42616,42665,42714,42763,42813,42861,
       42910,42959,43008,43057,43105,43154,43203,43251,43300,43348,43396,43445,43493,43541,
       43589,43637,43685,43733,43781,43829,43877,43925,43972,44020,44068,44115,44163,44210,
       44258,44305,44352,44400,44447,44494,44541,44588,44635,44682,44729,44776,44823,44869,
       44916,44963,45009,45056,45103,45149,45195,45242,45288,45334,45381,45427,45473,45519,
       45565,45611,45657,45703,45749,45795,45840,45886,45932,45977,46023,46069,46114,46160,
       46205,46250,46296,46341,46386,46431,46477,46522,46567,46612,46657,46702,46746,46791,
       46836,46881,46926,46970,47015,47059,47104,47149,47193,47237,47282,47326,47370,47415,
       47459,47503,47547,47591,47635,47679,47723,47767,47811,47855,47899,47942,47986,48030,
       48074,48117,48161,48204,48248,48291,48335,48378,48421,48465,48508,48551,48594,48637,
       48680,48723,48766,48809,48852,48895,48938,48981,49024,49067,49109,49152,49195,49237,
       49280,49322,49365,49407,49450,49492,49535,49577,49619,49661,49704,49746,49788,49830,
       49872,49914,49956,49998,50040,50082,50124,50166,50207,50249,50291,50332,50374,50416,
       50457,50499,50540,50582,50623,50665,50706,50747,50789,50830,50871,50912,50954,50995,
       51036,51077,51118,51159,51200,51241,51282,51323,51364,51404,51445,51486,51527,51567,
       51608,51649,51689,51730,51770,51811,51851,51892,51932,51972,52013,52053,52093,52134,
       52174,52214,52254,52294,52334,52374,52414,52454,52494,52534,52574,52614,52654,52694,
       52734,52773,52813,52853,52892,52932,52972,53011,53051,53090,53130,53169,53209,53248,
       53287,53327,53366,53405,53445,53484,53523,53562,53601,53640,53679,53719,53758,53797,
       53836,53874,53913,53952,53991,54030,54069,54108,54146,54185,54224,54262,54301,54340,
       54378,54417,54455,54494,54532,54571,54609,54647,54686,54724,54762,54801,54839,54877,
       54915,54954,54992,55030,55068,55106,55144,55182,55220,55258,55296,55334,55372,55410,
       55447,55485,55523,55561,55599,55636,55674,55712,55749,55787,55824,55862,55900,55937,
       55975,56012,56049,56087,56124,56162,56199,56236,56273,56311,56348,56385,56422,56459,
       56497,56534,56571,56608,56645,56682,56719,56756,56793,56830,56867,56903,56940,56977,
       57014,57051,57087,57124,57161,57198,57234,57271,57307,57344,57381,57417,57454,57490,
       57527,57563,57599,57636,57672,57709,57745,57781,57817,57854,57890,57926,57962,57999,
       58035,58071,58107,58143,58179,58215,58251,58287,58323,58359,58395,58431,58467,58503,
       58538,58574,58610,58646,58682,58717,58753,58789,58824,58860,58896,58931,58967,59002,
       59038,59073,59109,59144,59180,59215,59251,59286,59321,59357,59392,59427,59463,59498,
       59533,59568,59603,59639,59674,59709,59744,59779,59814,59849,59884,59919,59954,59989,
       60024,60059,60094,60129,60164,60199,60233,60268,60303,60338,60373,60407,60442,60477,
       60511,60546,60581,60615,60650,60684,60719,60753,60788,60822,60857,60891,60926,60960,
       60995,61029,61063,61098,61132,61166,61201,61235,61269,61303,61338,61372,61406,61440,
       61474,61508,61542,61576,61610,61644,61678,61712,61746,61780,61814,61848,61882,61916,
       61950,61984,62018,62051,62085,62119,62153,62186,62220,62254,62287,62321,62355,62388,
       62422,62456,62489,62523,62556,62590,62623,62657,62690,62724,62757,62790,62824,62857,
       62891,62924,62957,62991,63024,63057,63090,63124,63157,63190,63223,63256,63289,63323,
       63356,63389,63422,63455,63488,63521,63554,63587,63620,63653,63686,63719,63752,63785,
       63817,63850,63883,63916,63949,63982,64014,64047,64080,64113,64145,64178,64211,64243,
       64276,64309,64341,64374,64406,64439,64471,64504,64536,64569,64601,64634,64666,64699,
       64731,64763,64796,64828,64861,64893,64925,64957,64990,65022,65054,65086,65119,65151,
       65183,65215,65247,65279,65312,65344,65376,65408,65440,65472,65504);
      isqrtBitSliderLookUpTable:array[TpvUInt8] of TpvUInt8=(
       0,0,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
       5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
       6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
       6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
       7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
       7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
       7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
       7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7);
var bit:TpvInt32;
    t,shift:TpvUInt32;
begin
 t:=x;
 shift:=11;
 bit:=t shr 24;
 if bit<>0 then begin
  bit:=isqrtBitSliderLookUpTable[bit]+24;
 end else begin
  bit:=(t shr 16) and $ff;
  if bit<>0 then begin
   bit:=isqrtBitSliderLookUpTable[bit]+16;
  end else begin
   bit:=(t shr 8) and $ff;
   if bit<>0 then begin
    bit:=isqrtBitSliderLookUpTable[bit]+8;
   end else begin
    bit:=isqrtBitSliderLookUpTable[t];
   end;
  end;
 end;
 bit:=bit-9;
 if bit>0 then begin
  bit:=(SARLongint(bit,1))+(bit and 1);
  dec(shift,bit);
  x:=x shr (bit shl 1);
 end;
 result:=isqrtLookUpTable[x] shr shift;
end;

function CompareKerningPairs(const a,b:TpvPointer):TpvInt32;
begin
 result:=PpvTrueTypeFontKerningPair(a)^.Left-PpvTrueTypeFontKerningPair(b)^.Left;
 if result=0 then begin
  result:=PpvTrueTypeFontKerningPair(a)^.Right-PpvTrueTypeFontKerningPair(b)^.Right;
 end;
end;

constructor TpvTrueTypeFontRasterizer.Create;
begin
 inherited Create;
end;

destructor TpvTrueTypeFontRasterizer.Destroy;
begin
 inherited Destroy;
end;

function TpvTrueTypeFontRasterizer.GetCanvas:TpvPointer;
begin
 result:=nil;
end;

procedure TpvTrueTypeFontRasterizer.SetCanvas(NewCanvas:TpvPointer);
begin
end;

function TpvTrueTypeFontRasterizer.GetWidth:TpvInt32;
begin
 result:=0;
end;

procedure TpvTrueTypeFontRasterizer.SetWidth(NewWidth:TpvInt32);
begin
end;

function TpvTrueTypeFontRasterizer.GetHeight:TpvInt32;
begin
 result:=0;
end;

procedure TpvTrueTypeFontRasterizer.SetHeight(NewHeight:TpvInt32);
begin
end;

function TpvTrueTypeFontRasterizer.GetWindingRule:TpvInt32;
begin
 result:=0;
end;

procedure TpvTrueTypeFontRasterizer.SetWindingRule(NewWindingRule:TpvInt32);
begin
end;

procedure TpvTrueTypeFontRasterizer.Clear;
begin
end;

procedure TpvTrueTypeFontRasterizer.Reset;
begin
end;

procedure TpvTrueTypeFontRasterizer.Resize(NewWidth,NewHeight:TpvInt32);
begin
end;

procedure TpvTrueTypeFontRasterizer.MoveTo(ToX,ToY:TpvInt32);
begin
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontRasterizer.LineTo(ToX,ToY:TpvInt32);
begin
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontRasterizer.QuadraticCurveTo(const ControlX,ControlY,AnchorX,AnchorY:TpvInt32;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32);
 procedure Recursive(const x1,y1,x2,y2,x3,y3,Level:TpvInt32);
 var x12,y12,x23,y23,x123,y123,MiddleX,MiddleY,Delta:TpvInt32;
 begin
  x12:=SARLongint(x1+x2,1);
  y12:=SARLongint(y1+y2,1);
  x23:=SARLongint(x2+x3,1);
  y23:=SARLongint(y2+y3,1);
  x123:=SARLongint(x12+x23,1);
  y123:=SARLongint(y12+y23,1);
  MiddleX:=SARLongint(x1+x3,1);
  MiddleY:=SARLongint(y1+y3,1);
  Delta:=abs(MiddleX-x123)+abs(MiddleY-y123);
  if (Level>MaxLevel) or (Delta<Tolerance) then begin
   LineTo(x123,y123);
  end else begin
   Recursive(x1,y1,x12,y12,x123,y123,Level+1);
   Recursive(x123,y123,x23,y23,x3,y3,Level+1);
  end;
 end;
begin
 Recursive(fLastX,fLastY,ControlX,ControlY,AnchorX,AnchorY,0);
 LineTo(AnchorX,AnchorY);
end;

procedure TpvTrueTypeFontRasterizer.CubicCurveTo(const c1x,c1y,c2x,c2y,ax,ay:TpvInt32;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32);
 procedure Recursive(const x1,y1,x2,y2,x3,y3,x4,y4,Level:TpvInt32);
 var x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234,d:TpvInt32;
 begin
  x12:=SARLongint(x1+x2,1);
  y12:=SARLongint(y1+y2,1);
  x23:=SARLongint(x2+x3,1);
  y23:=SARLongint(y2+y3,1);
  x34:=SARLongint(x3+x4,1);
  y34:=SARLongint(y3+y4,1);
  x123:=SARLongint(x12+x23,1);
  y123:=SARLongint(y12+y23,1);
  x234:=SARLongint(x23+x34,1);
  y234:=SARLongint(y23+y34,1);
  x1234:=SARLongint(x123+x234,1);
  y1234:=SARLongint(y123+y234,1);
// d:=abs(SARlongint(x1+x4,1)-x1234)+abs(SARLongint(y1+y4,1)-y1234);
  d:=abs(((x1+x3)-x2)-x2)+abs(((y1+y3)-y2)-y2)+abs(((x2+x4)-x3)-x3)+abs(((y2+y4)-y3)-y3);
  if (Level>MaxLevel) or (d<Tolerance) then begin
   LineTo(x1234,y1234);
  end else begin
   Recursive(x1,y1,x12,y12,x123,y123,x1234,y1234,Level+1);
   Recursive(x1234,y1234,x234,y234,x34,y34,x4,y4,Level+1);
  end;
 end;
begin
 Recursive(fLastX,fLastY,c1x,c1y,c2x,c2y,ax,ay,0);
 LineTo(ax,ay);
end;

procedure TpvTrueTypeFontRasterizer.Close;
begin
end;

procedure TpvTrueTypeFontRasterizer.Render;
begin
end;

constructor TpvTrueTypeFontPolygonRasterizer.Create;
begin
 inherited Create;
 fCanvas:=nil;
 fCurrentWindingRule:=pvTTF_PolygonWindingRule_NONZERO;
 fCurrentWidth:=0;
 fCurrentHeight:=0;
 fScanlines:=nil;
 fCells:=nil;
 fAntialiasing:=true;
 fForceNonAntialiasing:=false;
 fCurrentGamma:=0.0;
 SetGamma(1.0);
 Reset;
end;

destructor TpvTrueTypeFontPolygonRasterizer.Destroy;
var i:TpvInt32;
begin
 for i:=0 to length(fCells)-1 do begin
  if assigned(fCells[i]) then begin
   dispose(fCells[i]);
   fCells[i]:=nil;
  end;
 end;
 SetLength(fCells,0);
 SetLength(fScanlines,0);
 inherited Destroy;
end;

function TpvTrueTypeFontPolygonRasterizer.GetCanvas:TpvPointer;
begin
 result:=fCanvas;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetCanvas(NewCanvas:TpvPointer);
begin
 fCanvas:=NewCanvas;
end;

function TpvTrueTypeFontPolygonRasterizer.GetWidth:TpvInt32;
begin
 result:=fCurrentWidth;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetWidth(NewWidth:TpvInt32);
begin
 Resize(NewWidth,fCurrentHeight);
end;

function TpvTrueTypeFontPolygonRasterizer.GetHeight:TpvInt32;
begin
 result:=fCurrentHeight;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetHeight(NewHeight:TpvInt32);
begin
 Resize(fCurrentWidth,NewHeight);
end;

function TpvTrueTypeFontPolygonRasterizer.GetWindingRule:TpvInt32;
begin
 result:=fCurrentWindingRule;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetWindingRule(NewWindingRule:TpvInt32);
begin
 fCurrentWindingRule:=NewWindingRule;
end;

procedure TpvTrueTypeFontPolygonRasterizer.Clear;
begin
 if assigned(Canvas) then begin
  FillChar(Canvas^,fCurrentWidth*fCurrentHeight*SizeOf(TpvUInt8),AnsiChar(#0));
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.Reset;
var i:TpvInt32;
begin
 fNumCells:=0;
 fArea:=0;
 fCover:=0;
 for i:=0 to length(fScanlines)-1 do begin
  fScanlines[i].CellFirst:=nil;
  fScanlines[i].CellLast:=nil;
 end;
 fCellX:=-1;
 fCellY:=-1;
 fRenderMinY:=$7fffffff;
 fRenderMaxY:=-$7fffffff;
 fNeedToClose:=false;
 fMoveToX:=0;
 fMoveToY:=0;
 fLastX:=0;
 fLastY:=0;
end;

procedure TpvTrueTypeFontPolygonRasterizer.Resize(NewWidth,NewHeight:TpvInt32);
var i:TpvInt32;
begin
 fCurrentWidth:=NewWidth;
 fCurrentHeight:=NewHeight;
 if length(fScanlines)<>fCurrentHeight then begin
  SetLength(fScanlines,fCurrentHeight);
  for i:=0 to length(fScanlines)-1 do begin
   fScanlines[i].CellFirst:=nil;
   fScanlines[i].CellLast:=nil;
  end;
 end;
end;

function TpvTrueTypeFontPolygonRasterizer.NewCell:PpvTrueTypeFontPolygonRasterizerCell;
 procedure InsertBefore(CellNew,CellOld:PpvTrueTypeFontPolygonRasterizerCell);
 begin
  CellNew^.Next:=CellOld;
  CellNew^.Previous:=CellOld^.Previous;
  if assigned(CellOld^.Previous) then begin
   CellOld^.Previous^.Next:=CellNew;
  end;
  CellOld^.Previous:=CellNew;
  if CellOld=fScanlines[fCellY].CellFirst then begin
   fScanlines[fCellY].CellFirst:=CellNew;
  end;
 end;
 procedure InsertAfter(CellOld,CellNew:PpvTrueTypeFontPolygonRasterizerCell);
 begin
  CellNew^.Next:=CellOld^.Next;
  CellNew^.Previous:=CellOld;
  if assigned(CellOld^.Next) then begin
   CellOld^.Next^.Previous:=CellNew;
  end;
  CellOld^.Next:=CellNew;
  if CellOld=fScanlines[fCellY].CellLast then begin
   fScanlines[fCellY].CellLast:=CellNew;
  end;
 end;
 function GetCell:PpvTrueTypeFontPolygonRasterizerCell;
 var i,OldCount,NewCount:TpvInt32;
 begin
  if fNumCells>=length(fCells) then begin
   OldCount:=length(fCells);
   NewCount:=(fNumCells+1)*2;
   SetLength(fCells,NewCount);
   for i:=OldCount to NewCount-1 do begin
    New(fCells[i]);
   end;
  end;
  result:=fCells[fNumCells];
  inc(fNumCells);
  result^.x:=fCellX;
  result^.Area:=0;
  result^.Cover:=0;
  result^.Previous:=nil;
  result^.Next:=nil;
 end;
var CurrentCell:PpvTrueTypeFontPolygonRasterizerCell;
begin
 if (fCellY<0) or (fCellY>=length(fScanlines)) then begin
  result:=nil;
 end else begin
  if assigned(fScanlines[fCellY].CellFirst) and assigned(fScanlines[fCellY].CellLast) then begin
   if fScanlines[fCellY].CellFirst^.x=fCellX then begin
    result:=fScanlines[fCellY].CellFirst;
   end else if fScanlines[fCellY].CellLast^.x=fCellX then begin
    result:=fScanlines[fCellY].CellLast;
   end else if fScanlines[fCellY].CellFirst^.x>fCellX then begin
    result:=GetCell;
    InsertBefore(result,fScanlines[fCellY].CellFirst);
   end else if fScanlines[fCellY].CellLast^.x<fCellX then begin
    result:=GetCell;
    InsertAfter(fScanlines[fCellY].CellLast,result);
   end else begin
    CurrentCell:=fScanlines[fCellY].CellFirst;
    while assigned(CurrentCell) and (CurrentCell^.x<fCellX) do begin
     CurrentCell:=CurrentCell^.Next;
    end;
    if assigned(CurrentCell) then begin
     if CurrentCell^.x=fCellX then begin
      result:=CurrentCell;
     end else begin
      result:=GetCell;
      InsertBefore(result,CurrentCell);
     end;
    end else begin
     result:=GetCell;
     InsertAfter(fScanlines[fCellY].CellLast,result);
    end;
   end;
  end else begin
   result:=GetCell;
   fScanlines[fCellY].CellFirst:=result;
   fScanlines[fCellY].CellLast:=result;
  end;
  if fRenderMinY>fCellY then begin
   fRenderMinY:=fCellY;
  end;
  if fRenderMaxY<fCellY then begin
   fRenderMaxY:=fCellY;
  end;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.RecordCell;
var Cell:PpvTrueTypeFontPolygonRasterizerCell;
begin
 if (fArea<>0) or (fCover<>0) then begin
  Cell:=NewCell;
  if assigned(Cell) then begin
   inc(Cell^.Area,fArea);
   inc(Cell^.Cover,fCover);
  end;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetCell(NewX,NewY:TpvInt32;Force:boolean=false);
begin
 if (fCellX<>NewX) or (fCellY<>NewY) or Force then begin
  RecordCell;
  fCellX:=NewX;
  fCellY:=NewY;
  fArea:=0;
  fCover:=0;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.StartCell(NewX,NewY:TpvInt32);
begin
 fArea:=0;
 fCover:=0;
 SetCell(NewX,NewY,true);
end;

procedure TpvTrueTypeFontPolygonRasterizer.RenderScanLine(NewY,x1,y1,x2,y2:TpvInt32);
var ex1,ex2,fx1,fx2,Delta,Temp,First,DeltaX,Increment,Lift,Modulo,Remainder:TpvInt32;
begin
 DeltaX:=x2-x1;
 ex1:=SARLongint(x1,PixelBits);
 ex2:=SARLongint(x2,PixelBits);
 fx1:=x1 and PixelMask;
 fx2:=x2 and PixelMask;

 if y1=y2 then begin
  // A trivial case. Happens often
  SetCell(ex2,NewY);
  exit;
 end;

 if ex1=ex2 then begin
  // Everything is located in a single x-based cell. That is easy!
  Delta:=y2-y1;
  inc(fArea,(fx1+fx2)*Delta);
  inc(fCover,Delta);
  exit;
 end;

 // Ok, we'll have to render a run of adjacent fCells on the same scanline.
 if DeltaX<0 then begin
  Temp:=fx1*(y2-y1);
  First:=0;
  Increment:=-1;
  DeltaX:=-DeltaX;
 end else begin
  Temp:=(OnePixel-fx1)*(y2-y1);
  First:=OnePixel;
  Increment:=1;
 end;

 Delta:=Temp div DeltaX;
 Modulo:=Temp mod DeltaX;
 if Modulo<0 then begin
  dec(Delta);
  inc(Modulo,DeltaX);
 end;

 inc(fArea,(fx1+First)*Delta);
 inc(fCover,Delta);

 inc(ex1,Increment);
 SetCell(ex1,NewY);
 inc(y1,Delta);

 if ex1<>ex2 then begin
  Temp:=OnePixel*((y2-y1)+Delta);
  Lift:=Temp div DeltaX;
  Remainder:=Temp mod DeltaX;
  if Remainder<0 then begin
   dec(Lift);
   inc(Remainder,DeltaX);
  end;
  dec(Modulo,DeltaX);
  while ex1<>ex2 do begin
   Delta:=Lift;
   inc(Modulo,Remainder);
   if Modulo>=0 then begin
    dec(Modulo,DeltaX);
    inc(Delta);
   end;
   inc(fArea,OnePixel*Delta);
   inc(fCover,Delta);
   inc(y1,Delta);
   inc(ex1,Increment);
   SetCell(ex1,NewY);
  end;
 end;
 Delta:=y2-y1;
 inc(fArea,(fx2+OnePixel-First)*Delta);
 inc(fCover,Delta);
end;

procedure TpvTrueTypeFontPolygonRasterizer.RenderLine(ToX,ToY:TpvInt32);
var ey1,ey2,fy1,fy2,DeltaX,DeltaY,NewX,NextX,Temp,First,Delta,Remainder,Modulo,Lift,Increment,MinValue,MaxValue,NewCellX,TwoFracX,Area:TpvInt32;
begin
 ey1:=SARLongint(fY,PixelBits);
 ey2:=SARLongint(ToY,PixelBits);
 fy1:=fY and PixelMask;
 fy2:=ToY and PixelMask;

 DeltaX:=ToX-fX;
 DeltaY:=ToY-fY;

 // Perform vertical clipping
 if ey1<ey2 then begin
  MinValue:=ey1;
  MaxValue:=ey2;
 end else begin
  MinValue:=ey2;
  MaxValue:=ey1;
 end;

 if (MinValue>=fCurrentHeight) or (MaxValue<0) then begin
  fX:=ToX;
  fY:=ToY;
  exit;
 end;

 if ey1=ey2 then begin
  // Everything is on a single scanline
  RenderScanLine(ey1,fX,fy1,ToX,fy2);
  fX:=ToX;
  fY:=ToY;
  exit;
 end;

 // Vertical line - avoid calling RenderScanLine
 Increment:=1;
 if DeltaX=0 then begin
  NewCellX:=SARLongint(fX,PixelBits);
  TwoFracX:=(fX and PixelMask) shl 1;

  First:=OnePixel;
  if DeltaY<0 then begin
   First:=0;
   Increment:=-1;
  end;

  Delta:=First-fy1;
  inc(fArea,TwoFracX*Delta);
  inc(fCover,Delta);
  inc(ey1,Increment);

  SetCell(NewCellX,ey1);

  Delta:=(First+First)-OnePixel;
  Area:=TwoFracX*Delta;
  while ey1<>ey2 do begin
   inc(fArea,Area);
   inc(fCover,Delta);
   inc(ey1,Increment);
   SetCell(NewCellX,ey1);
  end;

  Delta:=(fy2-OnePixel)+First;
  inc(fArea,TwoFracX*Delta);
  inc(fCover,Delta);
  fX:=ToX;
  fY:=ToY;
  exit;
 end;

 // Ok, we have to render several fScanlines
 if DeltaY<0 then begin
  Temp:=fy1*DeltaX;
  First:=0;
  Increment:=-1;
  DeltaY:=-DeltaY;
 end else begin
  Temp:=(OnePixel-fy1)*DeltaX;
  First:=OnePixel;
  Increment:=1;
 end;

 Delta:=Temp div DeltaY;
 Modulo:=Temp mod DeltaY;
 if Modulo<0 then begin
  dec(Delta);
  inc(Modulo,DeltaY);
 end;

 NewX:=fX+Delta;
 RenderScanLine(ey1,fX,fy1,NewX,First);

 inc(ey1,Increment);
 SetCell(SARLongint(NewX,PixelBits),ey1);

 if ey1<>ey2 then begin
  Temp:=OnePixel*DeltaX;
  Lift:=Temp div DeltaY;
  Remainder:=Temp mod DeltaY;
  if Remainder<0 then begin
   dec(Lift);
   inc(Remainder,DeltaY);
  end;
  while ey1<>ey2 do begin
   Delta:=Lift;
   inc(Modulo,Remainder);
   if Modulo>=0 then begin
    dec(Modulo,DeltaY);
    inc(Delta);
   end;
   NextX:=NewX+Delta;
   RenderScanLine(ey1,NewX,OnePixel-First,NextX,First);
   NewX:=NextX;
   inc(ey1,Increment);
   SetCell(SARLongint(NewX,PixelBits),ey1);
  end;
 end;
 RenderScanLine(ey1,NewX,OnePixel-First,ToX,fy2);

 fX:=ToX;
 fY:=ToY;
end;

procedure TpvTrueTypeFontPolygonRasterizer.ProcessSpan(x,y,Area,Len:TpvInt32);
const Bits=((PixelBits*2)+1)-8;
      Half=1 shl (Bits-1);
var Coverage:TpvInt32;
begin
 Coverage:=abs(SARLongint(Area+Half,Bits));
 case fCurrentWindingRule of
  pvTTF_PolygonWindingRule_NONZERO:begin
   if Coverage>255 then begin
    Coverage:=255;
   end;
  end;
  pvTTF_PolygonWindingRule_EVENODD:begin
   Coverage:=Coverage and 511;
   if Coverage>256 then begin
    Coverage:=512-Coverage;
   end else if Coverage=256 then begin
    Coverage:=255;
   end;
  end;
 end;
 if Coverage<>0 then begin
  RenderSpanCoverage(y,x,Len,Coverage);
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.MakeScanLineSpansAndRenderThese;
var Cover,x,Area,i:TpvInt32;
    c:PpvTrueTypeFontPolygonRasterizerCell;
begin
 if fNumCells<>0 then begin
  for i:=fRenderMinY to fRenderMaxY do begin
   x:=0;
   Cover:=0;
   c:=fScanlines[i].CellFirst;
   while assigned(c) do begin
    if (c^.x>x) and (Cover<>0) then begin
     ProcessSpan(x,i,Cover*(OnePixel*2),c^.x-x);
    end;
    inc(Cover,c^.Cover);
    Area:=(Cover*(OnePixel*2))-c^.Area;
    if (Area<>0) and (c^.x>=0) then begin
     ProcessSpan(c^.x,i,Area,1);
    end;
    x:=c^.x+1;
    c:=c^.Next;
   end;
  end;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.SetGamma(AGamma:TpvDouble);
const div255=1/255;
var i,j:TpvInt32;
begin
 if fCurrentGamma<>AGamma then begin
  fCurrentGamma:=AGamma;
  fForceNonAntialiasing:=AGamma<1e-8;
  for i:=low(TpvTrueTypeFontPolygonRasterizerGammaLookUpTable) to high(TpvTrueTypeFontPolygonRasterizerGammaLookUpTable) do begin
   if i=0 then begin
    j:=0;
   end else if fForceNonAntialiasing then begin
    j:=255;
   end else begin
    j:=trunc(power(i*div255,AGamma)*255);
    if j<0 then begin
     j:=0;
    end else if j>255 then begin
     j:=255;
    end;
   end;
   fCurrentGammaLookUpTable[i]:=j;
  end;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.MoveTo(ToX,ToY:TpvInt32);
begin
 Close;
 fNeedToClose:=true;
 StartCell(SARLongint(ToX,PixelBits),SARLongint(ToY,PixelBits));
 fX:=ToX;
 fY:=ToY;
 fMoveToX:=ToX;
 fMoveToY:=ToY;
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontPolygonRasterizer.LineTo(ToX,ToY:TpvInt32);
begin
 RenderLine(ToX,ToY);
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontPolygonRasterizer.Close;
begin
 if fNeedToClose then begin
  fNeedToClose:=false;
  if (fMoveToX<>fLastX) or (fMoveToY<>fLastY) then begin
   RenderLine(fMoveToX,fMoveToY);
   fLastX:=fMoveToX;
   fLastY:=fMoveToY;
  end;
  RecordCell;
 end;
end;

procedure TpvTrueTypeFontPolygonRasterizer.Render;
begin
 Close;
 MakeScanLineSpansAndRenderThese;
 Reset;
end;

procedure TpvTrueTypeFontPolygonRasterizer.RenderSpanCoverage(y,x,Len,Coverage:TpvInt32);
var p:PpvUInt8;
    Alpha:TpvUInt32;
    i:TpvInt32;
begin
 if (Coverage<>0) and (((x+Len)>0) and (x<fCurrentWidth)) then begin
  if x<0 then begin
   inc(Len,x);
   if Len<0 then begin
    Len:=0;
   end else begin
    x:=0;
   end;
  end;
  if Len>(fCurrentWidth-x) then begin
   Len:=fCurrentWidth-x;
  end;
  if Len>0 then begin
   p:=@PpvTrueTypeFontByteArray(Canvas)^[(y*fCurrentWidth)+x];
   if fAntialiasing then begin
    Alpha:=GammaLookUpTable[Coverage and $ff];
    case Alpha of
     0:begin
     end;
     1..254:begin
      for i:=1 to Len do begin
       if p^<Alpha then begin
        p^:=Alpha;
       end;
       inc(p);
      end;
     end;
     else begin
      for i:=1 to Len shr 2 do begin
       PpvUInt32(TpvPointer(p))^:=$ffffffff;
       inc(p,SizeOf(TpvUInt32));
      end;
      for i:=1 to Len and 3 do begin
       p^:=$ff;
       inc(p);
      end;
     end;
    end;
   end else begin
    if Coverage>=128 then begin
     for i:=1 to Len shr 2 do begin
      PpvUInt32(TpvPointer(p))^:=$ffffffff;
      inc(p,SizeOf(TpvUInt32));
     end;
     for i:=1 to Len and 3 do begin
      p^:=$ff;
      inc(p);
     end;
    end;
   end;
  end;
 end;
end;

constructor TpvTrueTypeFontStrokeRasterizer.Create(Rasterizer:TpvTrueTypeFontRasterizer);
begin
 inherited Create;
 fRasterizer:=Rasterizer;
 fLinePoints:=nil;
 fNumLinePoints:=0;
 fLineWidth:=1.0;
 fLineCapMode:=pvTTF_LineCapMode_BUTT;
 fLineJoinMode:=pvTTF_LineJoinMode_BEVEL;
 fLineInnerJoinMode:=pvTTF_LineInnerJoinMode_BEVEL;
 fLineStrokePattern:='';
 fLineStrokePatternStepSize:=4.0;
 fFlushLineOnWork:=false;
end;

destructor TpvTrueTypeFontStrokeRasterizer.Destroy;
begin
 SetLength(fLinePoints,0);
 inherited Destroy;
end;

procedure TpvTrueTypeFontStrokeRasterizer.AddLinePoint(const x,y:TpvInt32);
begin
 if fNumLinePoints>=length(fLinePoints) then begin
  SetLength(fLinePoints,(fNumLinePoints+1)*2);
 end;
 fLinePoints[fNumLinePoints].x:=x;
 fLinePoints[fNumLinePoints].y:=y;
 inc(fNumLinePoints);
end;

procedure TpvTrueTypeFontStrokeRasterizer.ConvertLineStorkeToPolygon;
var CurrentLineWidth,i,x1,y1,x2,y2,dx,dy,d,fx,fy,lx,ly:TpvInt32;
    First,Closed:boolean;
    lhw:TpvFloat;
 procedure Point(x,y:TpvInt32);
 begin
  if First then begin
   First:=false;
   if assigned(fRasterizer) then begin
    fRasterizer.MoveTo(x,y);
   end;
   fx:=x;
   fy:=y;
  end else begin
   if assigned(fRasterizer) then begin
    fRasterizer.LineTo(x,y);
   end;
  end;
  lx:=x;
  ly:=y;
 end;
 procedure CloseLine;
 begin
  if ((lx<>fx) or (ly<>fy)) and not First then begin
   Point(fx,fy);
  end;
 end;
 function CalcIntersection(ax,ay,bx,by,cx,cy,dx,dy:TpvFloat;out x,y:TpvFloat):boolean;
 var r,num,den:TpvFloat;
 begin
  num:=((ay-cy)*(dx-cx))-((ax-cx)*(dy-cy));
  den:=((bx-ax)*(dy-cy))-((by-ay)*(dx-cx));
  if abs(den)<1.0E-14 then begin
   result:=false;
  end else begin
   r:=num/den;
   x:=ax+(r*(bx-ax));
   y:=ay+(r*(by-ay));
   result:=true;
  end;
 end;
 procedure DoArc(x,y,dx1,dy1,dx2,dy2:TpvInt32);
 var a1,a2,da:TpvFloat;
     ccw:boolean;
 begin
  a1:=arctan2(dy1,dx1);
  a2:=arctan2(dy2,dx2);
  da:=a1-a2;
  ccw:=(da>0) and (da<pi);
  da:=arccos(lhw/(lhw+32))*2;
  Point(x+dx1,y+dy1);
  if ccw then begin
   if a1<a2 then begin
    a2:=a2-(2*pi);
   end;
   a2:=a2+(da*0.25);
   a1:=a1-da;
   while a1>a2 do begin
    Point(trunc(x+(cos(a1)*lhw)),trunc(y+(sin(a1)*lhw)));
    a1:=a1-da;
   end;
  end else begin
   if a1>a2 then begin
    a2:=a2+(2*pi);
   end;
   a2:=a2-(da*0.25);
   a1:=a1+da;
   while a1<a2 do begin
    Point(trunc(x+(cos(a1)*lhw)),trunc(y+(sin(a1)*lhw)));
    a1:=a1+da;
   end;
  end;
  Point(x+dx2,y+dy2);
 end;
 procedure DoMiter(p1x,p1y,p2x,p2y,p3x,p3y,dx1,dy1,dx2,dy2,CurrentLineJoinMode,miterlimit:TpvInt32);
 var xi,yi,d1,lim,x2,y2:TpvFloat;
     miterlimitexceeded:boolean;
 begin
  xi:=p2x;
  yi:=p2y;
  miterlimitexceeded:=true;
  if CalcIntersection(p1x+dx1,p1y-dy1,p2x+dx1,p2y-dy1,p2x+dx2,p2y-dy2,p3x+dx2,p3y-dy2,xi,yi) then begin
   d1:=sqrt(sqr(p2x-xi)+sqr(p2y-yi));
   lim:=SARLongint(CurrentLineWidth*miterlimit,9); // div (256*2);
   if d1<=lim then begin
    Point(trunc(xi),trunc(yi));
    miterlimitexceeded:=false;
   end;
  end else begin
   x2:=p2x+dx1;
   y2:=p2y-dy1;
   if ((((x2-p1x)*dy1)-((p1y-y2)*dx1))<0)<>((((x2-p3x)*dy1)-((p3y-y2)*dx1)<0)) then begin
    Point(p2x+dx1,p2y-dy1);
    miterlimitexceeded:=false;
   end;
  end;
  if miterlimitexceeded then begin
   case CurrentLineJoinMode of
    pvTTF_LineJoinMode_MITERREVERT:begin
     Point(p2x+dx1,p2y-dy1);
     Point(p2x+dx2,p2y-dy2);
    end;
    pvTTF_LineJoinMode_MITERROUND:begin
     DoArc(p2x,p2y,dx1,-dy1,dx2,-dy2);
    end;
    else begin
     Point((p2x+dx1)+SARLongint(dy1*miterlimit,8),(p2y-dy1)+SARLongint(dx1*miterlimit,8));
     Point((p2x+dx2)-SARLongint(dy2*miterlimit,8),(p2y-dy2)-SARLongint(dx2*miterlimit,8));
    end;
   end;
  end;
 end;
 procedure Join(i1,i2,i3,di1,di2:TpvInt32);
  function calc_point_location(x1,y1,x2,y2,x3,y3:TpvInt32):TpvInt32;
  begin
   result:=((x3-x2)*(y2-y1))-((y3-y2)*(x2-x1));
  end;
 var x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2,d1,d2,d:TpvInt32;
 begin
  x1:=fLinePoints[i1].x;
  y1:=fLinePoints[i1].y;
  x2:=fLinePoints[i2].x;
  y2:=fLinePoints[i2].y;
  x3:=fLinePoints[i3].x;
  y3:=fLinePoints[i3].y;
  d1:=fLinePoints[di1].d;
  d2:=fLinePoints[di2].d;
  dx1:=(CurrentLineWidth*(y2-y1)) div (d1*2);
  dy1:=(CurrentLineWidth*(x2-x1)) div (d1*2);
  dx2:=(CurrentLineWidth*(y3-y2)) div (d2*2);
  dy2:=(CurrentLineWidth*(x3-x2)) div (d2*2);
  if calc_point_location(x1,y1,x2,y2,x3,y3)>0 then begin
   case fLineInnerJoinMode of
    pvTTF_LineInnerJoinMode_BEVEL:begin
     Point(x2+dx1,y2-dy1);
     Point(x2+dx2,y2-dy2);
    end;
    pvTTF_LineInnerJoinMode_MITER:begin
     DoMiter(x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2,pvTTF_LineJoinMode_MITERREVERT,258);
    end;
    pvTTF_LineInnerJoinMode_JAG:begin
     d:=((dx1-dx2)*(dx1-dx2))+((dy1-dy2)*(dy1-dy2));
     if (d<(d1*d1)) and (d<(d2*d2)) then begin
      DoMiter(x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2,pvTTF_LineJoinMode_MITERREVERT,258);
     end else begin
      Point(x2+dx1,y2-dy1);
      Point(x2,y2);
      Point(x2+dx2,y2-dy2);
     end;
    end;
    pvTTF_LineInnerJoinMode_ROUND:begin
     d:=((dx1-dx2)*(dx1-dx2))+((dy1-dy2)*(dy1-dy2));
     if (d<(d1*d1)) and (d<(d2*d2)) then begin
      DoMiter(x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2,pvTTF_LineJoinMode_MITERREVERT,258);
     end else begin
      Point(x2+dx1,y2-dy1);
      Point(x2,y2);
      DoArc(x2,y2,dx2,-dy2,dx1,-dy1);
      Point(x2,y2);
      Point(x2+dx2,y2-dy2);
     end;
    end;
   end;
  end else begin
   case fLineJoinMode of
    pvTTF_LineJoinMode_BEVEL:begin
     Point(x2+dx1,y2-dy1);
     Point(x2+dx2,y2-dy2);
    end;
    pvTTF_LineJoinMode_ROUND:begin
     DoArc(x2,y2,dx1,-dy1,dx2,-dy2);
    end;
    pvTTF_LineJoinMode_MITER,pvTTF_LineJoinMode_MITERREVERT,pvTTF_LineJoinMode_MITERROUND:begin
     DoMiter(x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2,fLineJoinMode,1024);
    end;
   end;
  end;
 end;
 procedure Cap(i1,i2,di:TpvInt32);
 var x1,y1,x2,y2,dx1,dy1,dx2,dy2,d:TpvInt32;
     a1,a2,da:TpvFloat;
 begin
  x1:=fLinePoints[i1].x;
  y1:=fLinePoints[i1].y;
  x2:=fLinePoints[i2].x;
  y2:=fLinePoints[i2].y;
  d:=fLinePoints[di].d;
  dx1:=(CurrentLineWidth*(y2-y1)) div (2*d);
  dy1:=(CurrentLineWidth*(x2-x1)) div (2*d);
  case fLineCapMode of
   pvTTF_LineCapMode_ROUND:begin
    Point(x1-dx1,y1+dy1);
    if dx1=0 then begin
     dx1:=1;
    end;
    a1:=arctan2(dy1,-dx1);
    a2:=a1+pi;
    da:=arccos(lhw/(lhw+32))*2;
    a1:=a1+da;
    a2:=a2-(da*0.25);
    while a1<a2 do begin
     Point(trunc(x1+(cos(a1)*lhw)),trunc(y1+(sin(a1)*lhw)));
     a1:=a1+da;
    end;
    Point(x1+dx1,y1-dy1);
   end;
   else begin
    case fLineCapMode of
     pvTTF_LineCapMode_SQUARE:begin
      dx2:=dx1;
      dy2:=dy1;
     end;
     else begin
      dx2:=0;
      dy2:=0;
     end;
    end;
    Point(x1-dx1-dx2,y1+dy1-dy2);
    Point(x1+dx1-dx2,y1-dy1-dy2);
   end;
  end;
 end;
 function VectorLength(x,y:TpvInt32):TpvInt32;
 const Inv256=1/256;
 begin
  if (abs(x)+abs(y))<32768 then begin
   result:=isqrt((x*x)+(y*y));
  end else begin
   result:=round(sqrt(sqr(x*Inv256)+sqr(y*Inv256))*256);
  end;
 end;
begin
 if fNumLinePoints>=2 then begin
  CurrentLineWidth:=round(fLineWidth*256);
  Closed:=false;
  if (fLinePoints[0].x=fLinePoints[fNumLinePoints-1].x) and (fLinePoints[0].y=fLinePoints[fNumLinePoints-1].y) then begin
   dec(fNumLinePoints);
   Closed:=true;
  end;
  for i:=0 to fNumLinePoints-1 do begin
   x1:=fLinePoints[i].x;
   y1:=fLinePoints[i].y;
   x2:=fLinePoints[(i+1) mod fNumLinePoints].x;
   y2:=fLinePoints[(i+1) mod fNumLinePoints].y;
   dx:=x2-x1;
   dy:=y2-y1;
   d:=VectorLength(dx,dy);
   if d=0 then begin
    d:=1;
   end;
   fLinePoints[i].d:=d;
  end;
  lhw:=abs(CurrentLineWidth*0.5);
  if Closed then begin
   First:=true;
   for i:=0 to fNumLinePoints-1 do begin
    Join((i+fNumLinePoints-1) mod fNumLinePoints,i,(i+1) mod fNumLinePoints,(i+fNumLinePoints-1) mod fNumLinePoints,i);
   end;
   CloseLine;
   First:=true;
   for i:=fNumLinePoints-1 downto 0 do begin
    Join((i+1) mod fNumLinePoints,i,(i+fNumLinePoints-1) mod fNumLinePoints,i,(i+fNumLinePoints-1) mod fNumLinePoints);
   end;
   CloseLine;
  end else begin
   First:=true;
   Cap(0,1,0);
   for i:=1 to fNumLinePoints-2 do begin
    Join((i+fNumLinePoints-1) mod fNumLinePoints,i,(i+1) mod fNumLinePoints,(i+fNumLinePoints-1) mod fNumLinePoints,i);
   end;
   Cap(fNumLinePoints-1,fNumLinePoints-2,fNumLinePoints-2);
   for i:=fNumLinePoints-2 downto 1 do begin
    Join((i+1) mod fNumLinePoints,i,(i+fNumLinePoints-1) mod fNumLinePoints,i,(i+fNumLinePoints-1) mod fNumLinePoints);
   end;
  end;
  CloseLine;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.FlushLine;
var StepCounter,StepIndex,
    StepEndX,StepEndY:TpvInt32;
    NewLine,LastStepBool,StepBool,DoFlushStepLine,DoConvertLineStorkeToPolygon:boolean;
    LinePointsBuf:TpvTrueTypeFontStrokeRasterizerPoints;
    i:TpvInt32;
 procedure AddLinePointEx(x,y:TpvInt32);
 begin
  if (fNumLinePoints=0) or ((fNumLinePoints>0) and ((fLinePoints[fNumLinePoints-1].x<>x) or (fLinePoints[fNumLinePoints-1].y<>y))) then begin
   AddLinePoint(x,y);
   DoConvertLineStorkeToPolygon:=true;
  end;
 end;
 procedure FlushStepLine;
 begin
  if DoConvertLineStorkeToPolygon then begin
   if fNumLinePoints>1 then begin
    DoFlushStepLine:=false;
    DoConvertLineStorkeToPolygon:=false;
    ConvertLineStorkeToPolygon;
    fNumLinePoints:=0;
   end;
  end;
 end;
 procedure StepPoint(x,y:TpvInt32);
 begin
  if StepCounter=0 then begin
   if StepIndex>length(fLineStrokePattern) then begin
    StepIndex:=1;
   end;
   LastStepBool:=StepBool;
   if StepIndex<=length(fLineStrokePattern) then begin
    StepBool:=fLineStrokePattern[StepIndex]<>' ';
   end else begin
    StepBool:=false;
   end;
   if StepBool then begin
    DoFlushStepLine:=true;
    if not LastStepBool then begin
     AddLinePointEx(x,y);
    end;
   end else begin
    FlushStepLine;
    DoFlushStepLine:=false;
   end;
  end else if NewLine then begin
   if StepBool then begin
    AddLinePointEx(x,y);
   end;
  end;
  if StepBool then begin
   StepEndX:=x;
   StepEndY:=y;
  end;
  inc(StepCounter);
  if StepCounter>=fLineStrokePatternStepSize then begin
   if StepBool then begin
    AddLinePointEx(x,y);
   end;
   StepCounter:=0;
   inc(StepIndex);
  end;
  NewLine:=false;
 end;
 function Scale(ps,pc,pe,vs,ve:TpvInt32):TpvInt32;
 begin
  if ps=pe then begin
   result:=vs;
  end else begin
   if ps<pe then begin
    result:=vs+(((ve-vs)*(pc-ps)) div (pe-ps));
   end else begin
    result:=vs+(((ve-vs)*(pc-pe)) div (ps-pe));
   end;
  end;
 end;
 procedure StepLine(x0,y0,x1,y1:TpvInt32);
 var stepx,stepy{,xs,ys},dx,dy,fraction:TpvInt32;
 begin
  NewLine:=false;
  dx:=x1-x0;
  dy:=y1-y0;
  if dx<0 then begin
   dx:=-dx;
   stepx:=-1;
  end else begin
   stepx:=1;
  end;
  if dy<0 then begin
   dy:=-dy;
   stepy:=-1;
  end else begin
   stepy:=1;
  end;
{ xs:=x0;
  ys:=y0;}
  dx:=dx*2;
  dy:=dy*2;
  StepPoint(x0,y0);
  if dx>dy then begin
   fraction:=dy-SARLongint(dx,1);
   while x0<>x1 do begin
    if fraction>=0 then begin
     inc(y0,stepy);
     dec(fraction,dx);
    end;
    inc(x0,stepx);
    inc(fraction,dy);
    StepPoint(x0,y0);
   end;
  end else begin
   fraction:=dx-SARLongint(dy,1);
   while y0<>y1 do begin
    if fraction>=0 then begin
     inc(x0,stepx);
     dec(fraction,dy);
    end;
    inc(y0,stepy);
    inc(fraction,dx);
    StepPoint(x0,y0);
   end;
  end;
 end;
begin
 if not fFlushLineOnWork then begin
  fFlushLineOnWork:=true;
  if fNumLinePoints>0 then begin
   if length(fLineStrokePattern)>0 then begin
    StepCounter:=0;
    StepIndex:=1;
    DoFlushStepLine:=false;
    DoConvertLineStorkeToPolygon:=false;
    SetLength(LinePointsBuf,fNumLinePoints);
    try
     for i:=0 to fNumLinePoints-1 do begin
      LinePointsBuf[i]:=fLinePoints[i];
     end;
     LastStepBool:=false;
     StepBool:=false;
     fNumLinePoints:=0;
     if length(LinePointsBuf)=0 then begin
      StepLine(LinePointsBuf[0].x,LinePointsBuf[0].y,LinePointsBuf[0].x,LinePointsBuf[0].y);
     end else begin
      for i:=1 to length(LinePointsBuf)-1 do begin
       StepLine(LinePointsBuf[i-1].x,LinePointsBuf[i-1].y,LinePointsBuf[i].x,LinePointsBuf[i].y);
      end;
     end;
     if StepBool and DoFlushStepLine then begin
      AddLinePointEx(StepEndX,StepEndY);
     end;
     FlushStepLine;
    finally
     SetLength(LinePointsBuf,0);
     fNumLinePoints:=0;
    end;
   end else begin
    try
     ConvertLineStorkeToPolygon;
    finally
     fNumLinePoints:=0;
    end;
   end;
  end;
  fFlushLineOnWork:=false;
 end;
end;

function TpvTrueTypeFontStrokeRasterizer.GetCanvas:TpvPointer;
begin
 if assigned(fRasterizer) then begin
  result:=fRasterizer.GetCanvas;
 end else begin
  result:=nil;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.SetCanvas(NewCanvas:TpvPointer);
begin
 if assigned(fRasterizer) then begin
  fRasterizer.SetCanvas(NewCanvas);
 end;
end;

function TpvTrueTypeFontStrokeRasterizer.GetWidth:TpvInt32;
begin
 if assigned(fRasterizer) then begin
  result:=fRasterizer.GetWidth;
 end else begin
  result:=0;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.SetWidth(NewWidth:TpvInt32);
begin
 if assigned(fRasterizer) then begin
  fRasterizer.SetWidth(NewWidth);
 end;
end;

function TpvTrueTypeFontStrokeRasterizer.GetHeight:TpvInt32;
begin
 if assigned(fRasterizer) then begin
  result:=fRasterizer.GetHeight;
 end else begin
  result:=0;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.SetHeight(NewHeight:TpvInt32);
begin
 if assigned(fRasterizer) then begin
  fRasterizer.SetHeight(NewHeight);
 end;
end;

function TpvTrueTypeFontStrokeRasterizer.GetWindingRule:TpvInt32;
begin
 if assigned(fRasterizer) then begin
  result:=fRasterizer.GetWindingRule;
 end else begin
  result:=0;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.SetWindingRule(NewWindingRule:TpvInt32);
begin
 if assigned(fRasterizer) then begin
  fRasterizer.SetWindingRule(NewWindingRule);
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.Clear;
begin
 if assigned(fRasterizer) then begin
  fRasterizer.Clear;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.Reset;
begin
 if assigned(fRasterizer) then begin
  fRasterizer.Reset;
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.Resize(NewWidth,NewHeight:TpvInt32);
begin
 if assigned(fRasterizer) then begin
  fRasterizer.Resize(NewWidth,NewHeight);
 end;
end;

procedure TpvTrueTypeFontStrokeRasterizer.MoveTo(ToX,ToY:TpvInt32);
begin
 FlushLine;
 fStartLineX:=ToX;
 fStartLineY:=ToY;
 AddLinePoint(ToX,ToY);
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontStrokeRasterizer.LineTo(ToX,ToY:TpvInt32);
begin
 AddLinePoint(ToX,ToY);
 fLastX:=ToX;
 fLastY:=ToY;
end;

procedure TpvTrueTypeFontStrokeRasterizer.Close;
begin
 FlushLine;
 fRasterizer.Close;
end;

procedure TpvTrueTypeFontStrokeRasterizer.Render;
begin
 if assigned(fRasterizer) then begin
  fRasterizer.Render;
 end;
end;

type TMatrix=array[0..5] of single;

const MatrixIdentity:TMatrix=(1,0,0,1,0,0);
      MatrixNull:TMatrix=(0,0,0,0,0,0);

function MatrixTranslate(tx,ty:TpvFloat):TMatrix;
begin
 result:=MatrixIdentity;
 result[4]:=tx;
 result[5]:=ty;
end;

function MatrixScale(sx,sy:TpvFloat):TMatrix;
begin
 result:=MatrixIdentity;
 result[0]:=sx;
 result[3]:=sy;
end;

function MatrixRotate(degress:TpvFloat):TMatrix;
var rad,c,s:TpvFloat;
begin
 rad:=degress*deg2rad;
 c:=cos(rad);
 s:=sin(rad);
 result:=MatrixIdentity;
 result[0]:=c;
 result[1]:=s;
 result[2]:=-s;
 result[3]:=c;
end;

function MatrixSkewX(x:TpvFloat):TMatrix;
begin
 result:=MatrixIdentity;
 result[1]:=tan(x*deg2rad);
end;

function MatrixSkewY(y:TpvFloat):TMatrix;
begin
 result:=MatrixIdentity;
 result[2]:=tan(y*deg2rad);
end;

function MatrixMul(const a,b:TMatrix):TMatrix;
begin
 result[0]:=(a[0]*b[0])+(a[1]*b[2]);
 result[1]:=(a[0]*b[1])+(a[1]*b[3]);
 result[2]:=(a[2]*b[0])+(a[3]*b[2]);
 result[3]:=(a[2]*b[1])+(a[3]*b[3]);
 result[4]:=(a[4]*b[0])+(a[5]*b[2])+b[4];
 result[5]:=(a[4]*b[1])+(a[5]*b[3])+b[5];
end;

function MatrixInverse(const a:TMatrix):TMatrix;
var det,idet:TpvFloat;
begin
 det:=(a[0]*a[3])-(a[1]*a[2]);
 if abs(det)<1E-14 then begin
  result:=a;
 end else begin
  idet:=1/det;
  result[0]:=a[3]*idet;
  result[1]:=-a[1]*idet;
  result[2]:=-a[2]*idet;
  result[3]:=a[0]*idet;
  result[4]:=-(a[4]*result[0])-(a[5]*result[2]);
  result[5]:=-(a[4]*result[1])-(a[5]*result[3]);
 end;
end;

procedure ApplyMatrixToXY(const m:TMatrix;var x,y:TpvInt32); overload;
var tx:TpvInt32;
begin
 tx:=x;
 x:=trunc((tx*m[0])+(y*m[2])+m[4]);
 y:=trunc((tx*m[1])+(y*m[3])+m[5]);
end;

procedure ApplyMatrixToXY(const m:TMatrix;var x,y:TpvFloat); overload;
var tx:TpvFloat;
begin
 tx:=x;
 x:=(tx*m[0])+(y*m[2])+m[4];
 y:=(tx*m[1])+(y*m[3])+m[5];
end;

function ToDOUBLE(const x:TpvUInt32):TpvDouble;
var a:TpvInt16;
    aw:TpvUInt16 absolute a;
begin
 aw:=x shr 16;
 if a>0 then begin
  result:=aw+((x and 65535)/$ffffffff);
 end else begin
  result:=aw-((x and 65535)/$ffffffff);
 end;
end;

function ToWORD(const b1,b2:TpvUInt8):TpvUInt16;
begin
 result:=(b1 shl 8) or b2;
end;

function ToSMALLINT(const b1,b2:TpvUInt8):TpvInt16;
begin
 result:=TpvInt16(TpvUInt16(ToWORD(b1,b2)));
end;

function ToLONGWORD(const b1,b2,b3,b4:TpvUInt8):TpvUInt32;
begin
 result:=(b1 shl 24) or (b2 shl 16) or (b3 shl 8) or b4;
end;

function ToLONGINT(const b1,b2,b3,b4:TpvUInt8):TpvInt32;
begin
 result:=TpvInt32(TpvUInt32((b1 shl 24) or (b2 shl 16) or (b3 shl 8) or b4));
end;

function ToUINT24(const b1,b2,b3:TpvUInt8):TpvUInt32;
begin
 result:=(b1 shl 16) or (b2 shl 8) or b3;
end;

function IsBitSet(const ByteValue,Bit:TpvUInt8):boolean;
begin
 result:=(ByteValue and (1 shl Bit))<>0;
end;

procedure TpvTrueTypeFontPolygonBuffer.ConvertToVectorPath(const aVectorPath:TpvVectorPath;const aFillRule:TpvInt32=pvTTF_PolygonWindingRule_NONZERO);
var CommandIndex:TpvInt32;
    Command:PpvTrueTypeFontPolygonCommand;
begin
 if aFillRule=pvTTF_PolygonWindingRule_NONZERO then begin
  aVectorPath.FillRule:=TpvVectorPathFillRule.NonZero;
 end else begin
  aVectorPath.FillRule:=TpvVectorPathFillRule.EvenOdd;
 end;
 for CommandIndex:=0 to CountCommands-1 do begin
  Command:=@Commands[CommandIndex];
  case Command^.CommandType of
   TpvTrueTypeFontPolygonCommandType.MoveTo:begin
    aVectorPath.MoveTo(Command^.Points[0].x,
                       Command^.Points[0].y);
   end;
   TpvTrueTypeFontPolygonCommandType.LineTo:begin
    aVectorPath.LineTo(Command^.Points[0].x,
                       Command^.Points[0].y);
   end;
   TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo:begin
    aVectorPath.QuadraticCurveTo(Command^.Points[0].x,
                                 Command^.Points[0].y,
                                 Command^.Points[1].x,
                                 Command^.Points[1].y);
   end;
   TpvTrueTypeFontPolygonCommandType.CubicCurveTo:begin
    aVectorPath.CubicCurveTo(Command^.Points[0].x,
                             Command^.Points[0].y,
                             Command^.Points[1].x,
                             Command^.Points[1].y,
                             Command^.Points[2].x,
                             Command^.Points[2].y);
   end;
   TpvTrueTypeFontPolygonCommandType.Close:begin
    aVectorPath.Close;
   end;
  end;
 end;
end;

constructor TpvTrueTypeFontByteCodeInterpreter.Create(AFont:TpvTrueTypeFont);
var i:TpvInt32;
begin
 inherited Create;
 fFont:=AFont;
{$ifdef ttfdebug}
 fLastCVT:=nil;
 fLastStack:=nil;
 fLastStorage:=nil;
 FillChar(fLastGraphicsState,SizeOf(TpvTrueTypeFontGraphicsState),AnsiChar(#0));
 FillChar(fLastPoints,SizeOf(TpvTrueTypeFontByteCodeInterpreterPoints),AnsiChar(#0));
{$endif}
 fCVT:=nil;
 fStack:=nil;
 fStorage:=nil;
 fFunctions:=nil;
 fScale:=not fFont.Size;
 fForceReinitialize:=false;
 fGraphicsState:=DefaultGraphicsState;
 fDefaultGraphicsState:=DefaultGraphicsState;
 FillChar(fPoints,SizeOf(TpvTrueTypeFontByteCodeInterpreterPoints),AnsiChar(#0));
 fEnds:=nil;
{$ifdef ttfdebug}
 SetLength(fLastCVT,length(fFont.fCVT));
 SetLength(fLastStack,RoundUpToPowerOfTwo(fFont.fMaxStackElements+256));
 SetLength(fLastStorage,RoundUpToPowerOfTwo(fFont.fMaxStorage+16));
{$endif}
 SetLength(fCVT,length(fFont.fCVT));
 SetLength(fStack,RoundUpToPowerOfTwo(fFont.fMaxStackElements+256));
 SetLength(fStorage,RoundUpToPowerOfTwo(fFont.fMaxStorage+16));
{$ifdef ttfdebug}
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current],fFont.fMaxTwilightPoints+4);
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted],fFont.fMaxTwilightPoints+4);
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits],fFont.fMaxTwilightPoints+4);
{$endif}
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current],fFont.fMaxTwilightPoints+4);
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted],fFont.fMaxTwilightPoints+4);
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits],fFont.fMaxTwilightPoints+4);
 SetLength(fFunctions,fFont.fMaxFunctionDefs);
 for i:=0 to fFont.fMaxFunctionDefs-1 do begin
  fFunctions[i].Data:=nil;
  fFunctions[i].Size:=0;
 end;
 if assigned(fFont.fFPGM.Data) and (fFont.fFPGM.Size>0) then begin
{$ifdef ttfdebug}
  writeln('FPGM');
  writeln('====');
{$endif}
  Run(fFont.fFPGM);
{$ifdef ttfdebug}
  writeln;
{$endif}
 end;
 Reinitialize;
{$ifdef ttfdebug}
 fForceReinitialize:=true;
{$endif}
end;

destructor TpvTrueTypeFontByteCodeInterpreter.Destroy;
begin
{$ifdef ttfdebug}
 SetLength(fLastCVT,0);
 SetLength(fLastStack,0);
 SetLength(fLastStorage,0);
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current],0);
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted],0);
 SetLength(fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits],0);
 SetLength(fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current],0);
 SetLength(fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted],0);
 SetLength(fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits],0);
{$endif}
 SetLength(fCVT,0);
 SetLength(fStack,0);
 SetLength(fStorage,0);
 SetLength(fFunctions,0);
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current],0);
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted],0);
 SetLength(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits],0);
 SetLength(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current],0);
 SetLength(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted],0);
 SetLength(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits],0);
 SetLength(fEnds,0);
 inherited Destroy;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.Reinitialize;
var i:TpvInt32;
begin
 if (fScale<>fFont.Size) or fForceReinitialize then begin
  fScale:=fFont.Size;
  fForceReinitialize:=false;
  if assigned(fFont.fPREP.Data) and (fFont.fPREP.Size>0) then begin
   for i:=0 to (fFont.fMaxTwilightPoints+4)-1 do begin
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i].x:=0;
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i].y:=0;
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i].x:=0;
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i].y:=0;
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i].x:=0;
    fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i].y:=0;
{$ifdef ttfdebug}
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i].x:=0;
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i].y:=0;
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i].x:=0;
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i].y:=0;
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i].x:=0;
    fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i].y:=0;
{$endif}
   end;
   for i:=0 to length(fStorage)-1 do begin
    fStorage[i]:=0;
{$ifdef ttfdebug}
    fLastStorage[i]:=0;
{$endif}
   end;
   for i:=0 to length(fCVT)-1 do begin
    fCVT[i]:=fFont.Scale(fFont.fCVT[i]);
{$ifdef ttfdebug}
    fLastCVT[i]:=fCVT[i];
{$endif}
   end;
   fGraphicsState:=DefaultGraphicsState;
{$ifdef ttfdebug}
   writeln('PREP');
   writeln('====');
{$endif}
   Run(fFont.fPREP);
{$ifdef ttfdebug}
   writeln;
{$endif}
   fDefaultGraphicsState:=fGraphicsState;
   fDefaultGraphicsState.pv:=DefaultGraphicsState.pv;
   fDefaultGraphicsState.fv:=DefaultGraphicsState.fv;
   fDefaultGraphicsState.dv:=DefaultGraphicsState.dv;
   fDefaultGraphicsState.rp:=DefaultGraphicsState.rp;
   fDefaultGraphicsState.zp:=DefaultGraphicsState.zp;
   fDefaultGraphicsState.Loop:=DefaultGraphicsState.Loop;
  end;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.SkipInstructionPayload(const ProgramBytes:TpvTrueTypeFontByteCodeInterpreterProgramBytes;var PC:TpvInt32):boolean;
begin
 case ProgramBytes.Data^[PC] of
  opNPUSHB:begin
   inc(PC);
   if PC>=ProgramBytes.Size then begin
    PC:=0;
    result:=false;
   end else begin
    inc(PC,ProgramBytes.Data^[PC]);
    result:=true;
   end;
  end;
  opNPUSHW:begin
   inc(PC);
   if PC>=ProgramBytes.Size then begin
    PC:=0;
    result:=false;
   end else begin
    inc(PC,ProgramBytes.Data^[PC] shl 1);
    result:=true;
   end;
  end;
  opPUSHB000,opPUSHB001,opPUSHB010,opPUSHB011,opPUSHB100,opPUSHB101,opPUSHB110,opPUSHB111:begin
   inc(PC,(ProgramBytes.Data^[PC]-opPUSHB000)+1);
   result:=true;
  end;
  opPUSHW000,opPUSHW001,opPUSHW010,opPUSHW011,opPUSHW100,opPUSHW101,opPUSHW110,opPUSHW111:begin
   inc(PC,((ProgramBytes.Data^[PC]-opPUSHW000)+1) shl 1);
   result:=true;
  end;
  else begin
   result:=true;
  end;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.MulDiv(a,b,c:TpvInt32;DoRound:boolean):TpvInt32;
var s:TpvInt32;
begin
 if (a=0) or (b=c) then begin
  result:=a;
 end else begin
  s:=1;
  if a<0 then begin
   a:=-a;
   s:=-s;
  end;
  if b<0 then begin
   b:=-b;
   s:=-s;
  end;
  if c<0 then begin
   c:=-c;
   s:=-s;
  end;
  if c>0 then begin
   if (a=0) or (b=0) then begin
    result:=0;
   end else begin
    if (a<46341) and (b<46341) and ((c<176096) or not DoRound) then begin
     if DoRound then begin
      result:=((a*b)+SARLongint(c,1)) div c;
     end else begin
      result:=(a*b) div c;
     end;
    end else begin
     if DoRound then begin
      result:=((TpvInt64(a)*b)+SARLongint(c,1)) div c;
     end else begin
      result:=(TpvInt64(a)*b) div c;
     end;
    end;
   end;
  end else begin
   result:=$7fffffff;
  end;
  if s<0 then begin
   result:=-result;
  end;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.MovePoint(var p:TpvTrueTypeFontGlyphPoint;Distance:TpvInt32;Touch:boolean);
var FVdotPV:TpvInt64;
begin
 if (fGraphicsState.fv[0]=$4000) and (fGraphicsState.pv[0]=$4000) and (fGraphicsState.fv[1]=0) and (fGraphicsState.pv[1]=0) then begin
  inc(p.x,Distance);
  if Touch then begin
   p.Flags:=p.Flags or pvTTF_PathFlag_TouchedX;
  end;
 end else if (fGraphicsState.fv[0]=0) and (fGraphicsState.pv[0]=0) and (fGraphicsState.fv[1]=$4000) and (fGraphicsState.pv[1]=$4000) then begin
  inc(p.y,Distance);
  if Touch then begin
   p.Flags:=p.Flags or pvTTF_PathFlag_TouchedY;
  end;
 end else begin
  FVdotPV:=SARInt64((TpvInt64(fGraphicsState.fv[0])*fGraphicsState.pv[0])+(TpvInt64(fGraphicsState.fv[1])*fGraphicsState.pv[1]),14);
  if fGraphicsState.fv[0]<>0 then begin
   inc(p.x,MulDiv(Distance,fGraphicsState.fv[0],FVdotPV,true));
   if Touch then begin
    p.Flags:=p.Flags or pvTTF_PathFlag_TouchedX;
   end;
  end;
  if fGraphicsState.fv[1]<>0 then begin
   inc(p.y,MulDiv(Distance,fGraphicsState.fv[1],FVdotPV,true));
   if Touch then begin
    p.Flags:=p.Flags or pvTTF_PathFlag_TouchedY;
   end;
  end;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.DotProduct(x,y:TpvTrueTypeFont26d6;const q:TpvTrueTypeFontVector2d14):TpvTrueTypeFont26d6;
{$ifdef TTFCompactDotProduct}
var v:TpvInt64;
{$else}
var l,lo1,lo2,lo:TpvUInt32;
    m,hi1,hi2,hi,s:TpvInt32;
{$endif}
begin
{$ifdef TTFCompactDotProduct}
 v:=(TpvInt64(x)*q[0])+(TpvInt64(y)*q[1]);
 if v<0 then begin
  result:=-(((-v)+$2000) shr 14);
 end else begin
  result:=(v+$2000) shr 14;
 end;
{$else}
 l:=TpvUInt32(TpvInt32(TpvInt32(x and $ffff)*TpvInt32(q[0])));
 m:=SARLongint(x,16)*TpvInt32(q[0]);

 lo1:=l+(TpvUInt32(m) shl 16);
 hi1:=SARLongint(m,16)+SARLongint(l,31);
 if lo1<l then begin
  inc(hi1);
 end;

 l:=TpvUInt32(TpvInt32(TpvInt32(y and $ffff)*TpvInt32(q[1])));
 m:=SARLongint(y,16)*TpvInt32(q[1]);

 lo2:=l+(TpvUInt32(m) shl 16);
 hi2:=SARLongint(m,16)+SARLongint(l,31);
 if lo2<l then begin
  inc(hi2);
 end;

 lo:=lo1+lo2;
 hi:=hi1+hi2;
 if lo<lo1 then begin
  inc(hi);
 end;

 s:=SARLongint(hi,31);
 l:=lo+TpvUInt32(s);
 inc(hi,s);
 if l<lo then begin
  inc(hi);
 end;
 lo:=l;

 l:=lo+$2000;
 if l<lo then begin
  inc(hi);
 end;

 result:=TpvUInt32((TpvUInt32(hi) shl 18) or (TpvUInt32(l) shr 14));
{$endif}
end;

function TpvTrueTypeFontByteCodeInterpreter.Div18d14(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
var s:TpvInt32;
begin
 s:=1;
 if a<0 then begin
  a:=-a;
  s:=-s;
 end;
 if b<0 then begin
  b:=-b;
  s:=-s;
 end;
 if b>0 then begin
  if (a<$20000) and (b<$3fff) then begin
   result:=((a shl 14)+SARLongint(b,1)) div b;
  end else begin
   result:=((TpvInt64(a) shl 14)+SARLongint(b,1)) div b;
  end;
 end else begin
  result:=$7fffffff;
 end;
 if s<0 then begin
  result:=-result;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.Mul18d14(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
var s:TpvInt32;
begin
 s:=1;
 if a<0 then begin
  a:=-a;
  s:=-s;
 end;
 if b<0 then begin
  b:=-b;
  s:=-s;
 end;
 if (a<46341) and (b<46341) then begin
  result:=SARLongint((a*b)+$2000,14);
 end else begin
  result:=SARInt64((TpvInt64(a)*b)+$2000,14);
 end;
 if s<0 then begin
  result:=-result;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.Div26d6(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
var s:TpvInt32;
begin
 s:=1;
 if a<0 then begin
  a:=-a;
  s:=-s;
 end;
 if b<0 then begin
  b:=-b;
  s:=-s;
 end;
 if b>0 then begin
  if a<$1ffffff then begin
   result:=(a shl 6) div b;
  end else begin
   result:=(TpvInt64(a) shl 6) div b;
  end;
 end else begin
  result:=$7fffffff;
 end;
 if s<0 then begin
  result:=-result;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.Mul26d6(a,b:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
var s:TpvInt32;
begin
 s:=1;
 if a<0 then begin
  a:=-a;
  s:=-s;
 end;
 if b<0 then begin
  b:=-b;
  s:=-s;
 end;
 if (a<46341) and (b<46341) then begin
  result:=SARLongint((a*b)+32,6);
 end else begin
  result:=SARInt64((TpvInt64(a)*b)+32,6);
 end;
 if s<0 then begin
  result:=-result;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.RoundValue(Value:TpvTrueTypeFont26d6):TpvTrueTypeFont26d6;
begin
 if fGraphicsState.RoundPeriod=0 then begin
  result:=Value;
 end else begin
  if Value>=0 then begin
   result:=(Value-fGraphicsState.RoundPhase)+fGraphicsState.RoundThreshold;
   if fGraphicsState.RoundSuper45 then begin
    result:=(result div fGraphicsState.RoundPeriod)*fGraphicsState.RoundPeriod;
   end else begin
    result:=result and (-fGraphicsState.RoundPeriod);
   end;
   if (Value<>0) and (result<0) then begin
    result:=0;
   end;
   inc(result,fGraphicsState.RoundPhase);
  end else begin
   result:=((-Value)-fGraphicsState.RoundPhase)+fGraphicsState.RoundThreshold;
   if fGraphicsState.RoundSuper45 then begin
    result:=(result div fGraphicsState.RoundPeriod)*fGraphicsState.RoundPeriod;
   end else begin
    result:=result and (-fGraphicsState.RoundPeriod);
   end;
   if result<0 then begin
    result:=0;
   end;
   result:=-(result+fGraphicsState.RoundPhase);
  end;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.IUPInterpolate(IUPY:boolean;p1,p2,ref1,ref2:TpvInt32);
var ifu1,ifu2,t,unh1,unh2,delta1,delta2,xy,ifuXY,i:TpvInt32;
    Scale:TpvInt64;
    ScaleOK:boolean;
begin
 if (p1<=p2) and ((ref1<length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current])) and (ref2<length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]))) then begin
  if IUPY then begin
   ifu1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,ref1].y;
   ifu2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,ref2].y;
  end else begin
   ifu1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,ref1].x;
   ifu2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,ref2].x;
  end;
  if ifu1>ifu2 then begin
   t:=ifu1;
   ifu1:=ifu2;
   ifu2:=t;
   t:=ref1;
   ref1:=ref2;
   ref2:=t;
  end;
  if IUPY then begin
   unh1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,ref1].y;
   unh2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,ref2].y;
   delta1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,ref1].y-unh1;
   delta2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,ref2].y-unh2;
  end else begin
   unh1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,ref1].x;
   unh2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,ref2].x;
   delta1:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,ref1].x-unh1;
   delta2:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,ref2].x-unh2;
  end;
  if ifu1=ifu2 then begin
   for i:=p1 to p2 do begin
    if IUPY then begin
     xy:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i].y;
    end else begin
     xy:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i].x;
    end;
    if xy<=unh1 then begin
     inc(xy,delta1);
    end else begin
     inc(xy,delta2);
    end;
    if IUPY then begin
     fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].y:=xy;
    end else begin
     fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].x:=xy;
    end;
   end;
  end else begin
   Scale:=0;
   ScaleOK:=false;
   for i:=p1 to p2 do begin
    if IUPY then begin
     xy:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i].y;
     IFUXY:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,i].y;
    end else begin
     xy:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i].x;
     IFUXY:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,i].x;
    end;
    if xy<=unh1 then begin
     inc(xy,delta1);
    end else if xy>=unh2 then begin
     inc(xy,delta2);
    end else begin
     if not ScaleOK then begin
      ScaleOK:=true;
      Scale:=MulDiv((unh2+delta2)-(unh1+delta1),$10000,ifu2-ifu1,true);
     end;
     xy:=(unh1+delta1)+MulDiv(ifuXY-ifu1,Scale,$10000,true);
    end;
    if IUPY then begin
     fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].y:=xy;
    end else begin
     fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].x:=xy;
    end;
   end;
  end;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.IUPShift(IUPY:boolean;p1,p2,p:TpvInt32);
var Delta,i:TpvInt32;
begin
 if IUPY then begin
  Delta:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,p].y-fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,p].y;
 end else begin
  Delta:=fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,p].x-fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,p].x;
 end;
 if Delta<>0 then begin
  for i:=p1 to p2 do begin
   if i<>p then begin
    if IUPY then begin
     inc(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].y,Delta);
    end else begin
     inc(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i].x,Delta);
    end;
   end;
  end;
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.GetPoint(ZonePointer,PointType,Index:TpvInt32):PpvTrueTypeFontGlyphPoint;
begin
 if ((ZonePointer>=0) and (ZonePointer<3)) and
    ((fGraphicsState.zp[ZonePointer]>=0) and (fGraphicsState.zp[ZonePointer]<pvTTF_Zone_Count)) and
    ((Index>=0) and (Index<length(fPoints[fGraphicsState.zp[ZonePointer],PointType]))) then begin
  result:=@fPoints[fGraphicsState.zp[ZonePointer],PointType,Index];
 end else begin
  result:=nil;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.Normalize(var x,y:TpvTrueTypeFont26d6);
var l:TpvInt32;
begin
 if (x<>0) or (y<>0) then begin
  if (abs(x)<$4000) and (abs(y)<$4000) then begin
   x:=x shl 14;
   y:=y shl 14;
  end;
  if x=0 then begin
   l:=abs(y);
  end else if y=0 then begin
   l:=abs(x);
  end else begin
   l:=round(sqrt(sqr(x/4096.0)+sqr(y/4096.0))*4096.0);
  end;
  x:=MulDiv(x,$4000,l,true);
  y:=MulDiv(y,$4000,l,true);
 end;
end;

function TpvTrueTypeFontByteCodeInterpreter.GetCVT(Index:TpvInt32):TpvInt32;
begin
 if (Index>=0) and (Index<length(fCVT)) then begin
  result:=fCVT[Index];
 end else begin
  result:=0;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.SetCVT(Index,Value:TpvInt32);
begin
 if (Index>=0) and (Index<length(fCVT)) then begin
  fCVT[Index]:=Value;
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.ComputePointDisplacement(Flag:boolean;var Zone,Ref:TpvInt32;var dx,dy:TpvTrueTypeFont26d6);
var Distance,FVdotPV:TpvInt64;
    p1,p2:PpvTrueTypeFontGlyphPoint;
begin
 if Flag then begin
  Ref:=fGraphicsState.rp[1];
  Zone:=0;
 end else begin
  Ref:=fGraphicsState.rp[2];
  Zone:=1;
 end;
 p1:=GetPoint(Zone,pvTTF_PointType_Unhinted,Ref);
 p2:=GetPoint(Zone,pvTTF_PointType_Current,Ref);
 if assigned(p1) and assigned(p2) then begin
  Distance:=DotProduct(p2^.x-p1.x,p2^.y-p1^.y,fGraphicsState.pv);
  if (fGraphicsState.fv[0]=$4000) and (fGraphicsState.pv[0]=$4000) and (fGraphicsState.fv[1]=0) and (fGraphicsState.pv[1]=0) then begin
   dx:=Distance;
   dy:=0;
  end else if (fGraphicsState.fv[0]=0) and (fGraphicsState.pv[0]=0) and (fGraphicsState.fv[1]=$4000) and (fGraphicsState.pv[1]=$4000) then begin
   dx:=0;
   dy:=Distance;
  end else begin
   FVdotPV:=SARInt64((TpvInt64(fGraphicsState.fv[0])*fGraphicsState.pv[0])+(TpvInt64(fGraphicsState.fv[1])*fGraphicsState.pv[1]),14);
   if FVdotPV<>0 then begin
    dx:=MulDiv(fGraphicsState.fv[0],Distance,FVdotPV,true);
    dy:=MulDiv(fGraphicsState.fv[1],Distance,FVdotPV,true);
   end else begin
    dx:=0;
    dy:=0;
   end;
  end;
 end else begin
  raise EpvTrueTypeFont.Create('Out of point bounds');
 end;
end;

procedure TpvTrueTypeFontByteCodeInterpreter.Run(ProgramBytes:TpvTrueTypeFontByteCodeInterpreterProgramBytes;Parameters:PpvTrueTypeFontByteCodeInterpreterParameters=nil);
var Steps,PC,Top,CallStackTop,PopCount,Depth,Temp,x,StartPC,i,Distance,PrevEnd,j,k,FirstTouched,CurrentTouched,PointType,
    FirstPoint,EndPoint,CurrentPoint,OldDist,CurrentDist,NewDist,t1,t2,t3,CVTDist,d1,d2,dx,dy,d,ZonePointer,RefIndex,
    Base,Count,a0,a1,b0,b1:TpvInt32;
    Mask:TpvUInt32;
    Opcode:TpvUInt8;
    CallStack:TpvTrueTypeFontByteCodeInterpreterCallStackEntries;
    OK,Twilight:boolean;
    f:TpvTrueTypeFontByteCodeInterpreterProgramBytes;
    p,OldP,CurrentP,Ref,q,p0,p1,p2:PpvTrueTypeFontGlyphPoint;
    OldRange,CurrentRange,ax0,ay0,ax1,ay1,bx0,by0,bx1,by1:TpvTrueTypeFont26d6;
    dxa,dya,dxb,dyb,det,v:TpvInt64;
{$ifdef ttfdebug}
 procedure StoreState;
 var i:TpvInt32;
 begin
  for i:=0 to length(fCVT)-1 do begin
   fLastCVT[i]:=fCVT[i];
  end;
  for i:=0 to length(fStack)-1 do begin
   fLastStack[i]:=fStack[i];
  end;
  for i:=0 to length(fStorage)-1 do begin
   fLastStorage[i]:=fStorage[i];
  end;
  fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current]:=copy(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current]);
  fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted]:=copy(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted]);
  fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits]:=copy(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits]);
  fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]:=copy(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]);
  fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted]:=copy(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted]);
  fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits]:=copy(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits]);
  fLastGraphicsState:=fGraphicsState;
 end;
 procedure DumpState;
 var i:TpvInt32;
     p1,p2:PpvTrueTypeFontGlyphPoint;
 begin
  if (fLastGraphicsState.pv[0]<>fGraphicsState.pv[0]) or (fLastGraphicsState.pv[1]<>fGraphicsState.pv[1]) then begin
    writeln('    pv: ',fLastGraphicsState.pv[0],',',fLastGraphicsState.pv[1],' => ',fGraphicsState.pv[0],',',fGraphicsState.pv[1]);
  end;
  if (fLastGraphicsState.dv[0]<>fGraphicsState.dv[0]) or (fLastGraphicsState.dv[1]<>fGraphicsState.dv[1]) then begin
    writeln('    dv: ',fLastGraphicsState.dv[0],',',fLastGraphicsState.dv[1],' => ',fGraphicsState.dv[0],',',fGraphicsState.dv[1]);
  end;
  if (fLastGraphicsState.fv[0]<>fGraphicsState.fv[0]) or (fLastGraphicsState.fv[1]<>fGraphicsState.fv[1]) then begin
    writeln('    fv: ',fLastGraphicsState.fv[0],',',fLastGraphicsState.fv[1],' => ',fGraphicsState.fv[0],',',fGraphicsState.fv[1]);
  end;
  if (fLastGraphicsState.zp[0]<>fGraphicsState.zp[0]) or (fLastGraphicsState.zp[1]<>fGraphicsState.zp[1]) or (fLastGraphicsState.zp[2]<>fGraphicsState.zp[2]) then begin
    writeln('    zp: ',fLastGraphicsState.zp[0],',',fLastGraphicsState.zp[1],',',fLastGraphicsState.zp[2],' => ',fGraphicsState.zp[0],',',fGraphicsState.zp[1],',',fGraphicsState.zp[2]);
  end;
  if (fLastGraphicsState.rp[0]<>fGraphicsState.rp[0]) or (fLastGraphicsState.rp[1]<>fGraphicsState.rp[1]) or (fLastGraphicsState.rp[2]<>fGraphicsState.rp[2]) then begin
    writeln('    rp: ',fLastGraphicsState.rp[0],',',fLastGraphicsState.rp[1],',',fLastGraphicsState.rp[2],' => ',fGraphicsState.rp[0],',',fGraphicsState.rp[1],',',fGraphicsState.rp[2]);
  end;
  for i:=0 to length(fCVT)-1 do begin
   if fLastCVT[i]<>fCVT[i] then begin
    writeln('    CVT[',i,']: ',fLastCVT[i],' => ',fCVT[i]);
   end;
  end;
  for i:=0 to length(fStack)-1 do begin
   if fLastStack[i]<>fStack[i] then begin
    writeln('    Stack[',i,']: ',fLastStack[i],' => ',fStack[i]);
   end;
  end;
  for i:=0 to length(fStorage)-1 do begin
   if fLastStorage[i]<>fStorage[i] then begin
    writeln('    Storage[',i,']: ',fLastStorage[i],' => ',fStorage[i]);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i];
   p2:=@fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    CurrentPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i];
   p2:=@fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    OriginalPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,i];
   p2:=@fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    InFontUnitsPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i];
   p2:=@fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Current,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    TwilightCurrentPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i];
   p2:=@fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_Unhinted,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    TwilightOriginalPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
  for i:=0 to length(fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits])-1 do begin
   p1:=@fLastPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i];
   p2:=@fPoints[pvTTF_Zone_Twilight,pvTTF_PointType_InFontUnits,i];
   if (p1^.x<>p2^.x) or (p1^.y<>p2^.y) then begin
    writeln('    TwilightInFontUnitsPoints[',i,']: ',p1^.x,',',p1^.y,' => ',p2^.x,',',p2^.y);
   end;
  end;
 end;
{$endif}
begin
 fGraphicsState:=fDefaultGraphicsState;
 if assigned(Parameters) then begin
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]:=Parameters^.pCurrent;
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted]:=Parameters^.pUnhinted;
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits]:=Parameters^.pInFontUnits;
  fEnds:=Parameters^.Ends;
 end else begin
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]:=nil;
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Unhinted]:=nil;
  fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_InFontUnits]:=nil;
  fEnds:=nil;
 end;
 if ProgramBytes.Size>50000 then begin
  raise EpvTrueTypeFont.Create('Too many instructions');
 end else begin
  Steps:=0;
  PC:=0;
  Top:=0;
  CallStack[0].PC:=0;
  CallStackTop:=0;
{$ifdef ttfdebug}
  StoreState;
{$endif}
  while (PC>=0) and (PC<ProgramBytes.Size) do begin
{$ifdef ttfdebug}
   DumpState;
   StoreState;
{$endif}
   inc(Steps);
   if Steps=100000 then begin
    raise EpvTrueTypeFont.Create('Too many steps');
   end else begin
    Opcode:=ProgramBytes.Data^[PC];
    PopCount:=OpcodePopCount[Opcode];
    if PopCount=255 then begin
     if Opcode<>0 then begin
      if Opcode<>0 then begin
      end;
     end;
     raise EpvTrueTypeFont.Create('Unimplemented instruction');
    end else if Top<PopCount then begin
     raise EpvTrueTypeFont.Create('Stack underflow');
    end else begin
     if (ProgramBytes.Size>14) and (ProgramBytes.Data^[13] in [opMSIRP0,opMSIRP1]) then begin
      if (ProgramBytes.Size>14) and (ProgramBytes.Data^[13] in [opMSIRP0,opMSIRP1]) then begin
      end;
     end;
{$ifdef ttfdebug}
      writeln('Opcode: ',OpcodeNames[Opcode]);
{$endif}
     case Opcode of
      opSVTCA0:begin
       fGraphicsState.pv[0]:=0;
       fGraphicsState.pv[1]:=$4000;
       fGraphicsState.fv[0]:=0;
       fGraphicsState.fv[1]:=$4000;
       fGraphicsState.dv[0]:=0;
       fGraphicsState.dv[1]:=$4000;
      end;
      opSVTCA1:begin
       fGraphicsState.pv[0]:=$4000;
       fGraphicsState.pv[1]:=0;
       fGraphicsState.fv[0]:=$4000;
       fGraphicsState.fv[1]:=0;
       fGraphicsState.dv[0]:=$4000;
       fGraphicsState.dv[1]:=0;
      end;
      opSPVTCA0:begin
       fGraphicsState.pv[0]:=0;
       fGraphicsState.pv[1]:=$4000;
       fGraphicsState.dv[0]:=0;
       fGraphicsState.dv[1]:=$4000;
      end;
      opSPVTCA1:begin
       fGraphicsState.pv[0]:=$4000;
       fGraphicsState.pv[1]:=0;
       fGraphicsState.dv[0]:=$4000;
       fGraphicsState.dv[1]:=0;
      end;
      opSFVTCA0:begin
       fGraphicsState.fv[0]:=0;
       fGraphicsState.fv[1]:=$4000;
      end;
      opSFVTCA1:begin
       fGraphicsState.fv[0]:=$4000;
       fGraphicsState.fv[1]:=0;
      end;
      opSPVTL0,opSPVTL1,opSFVTL0,opSFVTL1:begin
       dec(Top,2);
       p1:=GetPoint(1,pvTTF_PointType_Current,fStack[Top]);
       p2:=GetPoint(2,pvTTF_PointType_Current,fStack[Top+1]);
       if assigned(p1) and assigned(p2) then begin
        dx:=p1^.x-p2^.x;
        dy:=p1^.y-p2^.y;
        if (dx=0) and (dy=0) then begin
         dx:=$4000;
        end else if Opcode in [opSPVTL1,opSFVTL1] then begin
         d:=dx;
         dx:=-dy;
         dy:=d;
        end;
        Normalize(dx,dy);
        case Opcode of
         opSFVTL0,opSFVTL1:begin
          fGraphicsState.fv[0]:=dx;
          fGraphicsState.fv[1]:=dy;
         end;
         else begin
          fGraphicsState.pv[0]:=dx;
          fGraphicsState.pv[1]:=dy;
          fGraphicsState.dv:=fGraphicsState.pv;
         end;
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opSPVFS:begin
       dec(Top,2);
       dx:=TpvInt16(TpvUInt16(fStack[Top] and $ffff));
       dy:=TpvInt16(TpvUInt16(fStack[Top+1] and $ffff));
       Normalize(dx,dy);
       fGraphicsState.pv[0]:=dx;
       fGraphicsState.pv[1]:=dy;
       fGraphicsState.dv:=fGraphicsState.pv;
      end;
      opSFVFS:begin
       dec(Top,2);
       dx:=TpvInt16(TpvUInt16(fStack[Top] and $ffff));
       dy:=TpvInt16(TpvUInt16(fStack[Top+1] and $ffff));
       Normalize(dx,dy);
       fGraphicsState.fv[0]:=dx;
       fGraphicsState.fv[1]:=dy;
      end;
      opGPV:begin
       if (Top+1)>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=fGraphicsState.pv[0];
        fStack[Top+1]:=fGraphicsState.pv[1];
        inc(Top,2);
       end;
      end;
      opGFV:begin
       if (Top+1)>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=fGraphicsState.fv[0];
        fStack[Top+1]:=fGraphicsState.fv[1];
        inc(Top,2);
       end;
      end;
      opSFVTPV:begin
       fGraphicsState.fv:=fGraphicsState.pv;
      end;
      opISECT:begin
       dec(Top,5);
       b1:=fStack[Top+4];
       b0:=fStack[Top+3];
       a1:=fStack[Top+2];
       a0:=fStack[Top+1];
       p:=GetPoint(2,pvTTF_PointType_Current,fStack[Top]);
       if assigned(p) then begin
        p^.Flags:=p^.Flags or (pvTTF_PathFlag_TouchedX or pvTTF_PathFlag_TouchedY);
        p0:=GetPoint(1,pvTTF_PointType_Current,a0);
        if assigned(p0) then begin
         ax0:=p0^.x;
         ay0:=p0^.y;
         p0:=GetPoint(1,pvTTF_PointType_Current,a1);
         if assigned(p0) then begin
          ax1:=p0^.x;
          ay1:=p0^.y;
          p0:=GetPoint(0,pvTTF_PointType_Current,b0);
          if assigned(p0) then begin
           bx0:=p0^.x;
           by0:=p0^.y;
           p0:=GetPoint(0,pvTTF_PointType_Current,b1);
           if assigned(p0) then begin
            bx1:=p0^.x;
            by1:=p0^.y;
            dxa:=ax1-ax0;
            dya:=ay1-ay0;
            dxb:=bx1-bx0;
            dyb:=by1-by0;
            det:=(dya*dxb)-(dyb*dxa);
            if abs(det)>=$80 then begin
             v:=((bx0-ax0)*(-dyb))+((by0-ay0)*dxb);
             p^.x:=ax0+((v*dxa) div det);
             p^.y:=ay0+((v*dya) div det);
            end else begin
             // lines are (almost) parallel
             p^.x:=SARLongint(ax0+ax1+bx0+bx1,2);
             p^.y:=SARLongint(ay0+ay1+by0+by1,2);
            end;
           end else begin
            raise EpvTrueTypeFont.Create('Out of point bounds');
           end;
          end else begin
           raise EpvTrueTypeFont.Create('Out of point bounds');
          end;
         end else begin
          raise EpvTrueTypeFont.Create('Out of point bounds');
         end;
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opSRP0,opSRP1,opSRP2:begin
       dec(Top);
       fGraphicsState.rp[Opcode-opSRP0]:=fStack[Top];
      end;
      opSZP0,opSZP1,opSZP2:begin
       dec(Top);
       fGraphicsState.zp[Opcode-opSZP0]:=fStack[Top];
      end;
      opSZPS:begin
       dec(Top);
       fGraphicsState.zp[0]:=fStack[Top];
       fGraphicsState.zp[1]:=fStack[Top];
       fGraphicsState.zp[2]:=fStack[Top];
      end;
      opSLOOP:begin
       dec(Top);
       // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM05/Chap5.html#SLOOP
       // "Setting the loop variable to zero is an error", but in reality, at some
       // byte code sequences in some font files (for example the "2" glyph at
       // DejaVuSansMono.ttf) gets the SLOOP instruction a zero on top of the stack, so
       // we use here <0 instead <=0 (which would be more correct according to the
       // TTF specifications)
       if fStack[Top]<0 then begin
        raise EpvTrueTypeFont.Create('Invalid data');
       end else begin
        fGraphicsState.Loop:=fStack[Top];
       end;
      end;
      opRTG:begin
       fGraphicsState.RoundPeriod:=1 shl 6;
       fGraphicsState.RoundPhase:=0;
       fGraphicsState.RoundThreshold:=1 shl 5;
       fGraphicsState.RoundSuper45:=false;
      end;
      opRTHG:begin
       fGraphicsState.RoundPeriod:=1 shl 6;
       fGraphicsState.RoundPhase:=1 shl 5;
       fGraphicsState.RoundThreshold:=1 shl 5;
       fGraphicsState.RoundSuper45:=false;
      end;
      opSMD:begin
       dec(Top);
       fGraphicsState.MinDist:=fStack[Top];
      end;
      opELSE:begin
       Depth:=0;
       repeat
        inc(PC);
        if PC>=ProgramBytes.Size then begin
         raise EpvTrueTypeFont.Create('Unbalanced ELSE');
        end else begin
         case ProgramBytes.Data^[PC] of
          opIF:begin
           inc(Depth);
          end;
          opELSE:begin
          end;
          opEIF:begin
           dec(Depth);
           if Depth<0 then begin
            break;
           end;
          end;
          else begin
           OK:=SkipInstructionPayload(ProgramBytes,PC);
           if not OK Then begin
            raise EpvTrueTypeFont.Create('Unbalanced ELSE');
           end;
          end;
         end;
        end;
       until false;
      end;
      opJMPR:begin
       dec(Top);
       inc(PC,fStack[Top]);
       continue;
      end;
      opSCVTCI:begin
       dec(Top);
       fGraphicsState.ControlValueCutIn:=fStack[Top];
      end;
      opSSWCI:begin
       dec(Top);
       fGraphicsState.SingleWidthCutIn:=fStack[Top];
      end;
      opSSW:begin
       dec(Top);
       fGraphicsState.SingleWidth:=fFont.Scale(fStack[Top]);
      end;
      opDUP:begin
       if Top>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=fStack[Top-1];
        inc(Top);
       end;
      end;
      opPOP:begin
       dec(Top);
      end;
      opCLEAR:begin
       Top:=0;
      end;
      opSWAP:begin
       Temp:=fStack[Top-1];
       fStack[Top-1]:=fStack[Top-2];
       fStack[Top-2]:=Temp;
      end;
      opDEPTH:begin
       if Top>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=Top;
        inc(Top);
       end;
      end;
      opCINDEX:begin
       x:=fStack[Top-1];
       if (x>0) and (x<Top) then begin
        fStack[Top-1]:=fStack[Top-(x+1)];
       end else begin
        raise EpvTrueTypeFont.Create('Invalid data');
       end;
      end;
      opMINDEX:begin
       Count:=fStack[Top-1];
       if (Count>0) and (Count<Top) then begin
        dec(Top);
        Temp:=fStack[Top-Count];
        for i:=Top-Count to Top-2 do begin
         fStack[i]:=fStack[i+1];
        end;
        fStack[Top-1]:=Temp;
       end else begin
        raise EpvTrueTypeFont.Create('Invalid data');
       end;
      end;
      opALIGNPTS:begin
       dec(Top,2);
       p1:=GetPoint(0,pvTTF_PointType_Current,fStack[Top+1]);
       p2:=GetPoint(1,pvTTF_PointType_Current,fStack[Top]);
       if assigned(p1) and assigned(p2) then begin
        Distance:=SARLongint(DotProduct(p1^.x-p2^.x,p1^.y-p2^.y,fGraphicsState.pv),1);
        MovePoint(p1^,Distance,true);
        MovePoint(p2^,-Distance,true);
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opUTP:begin
       dec(Top);
       p:=GetPoint(2,pvTTF_PointType_Current,fStack[Top]);
       if assigned(p) then begin
        if fGraphicsState.fv[0]<>0 then begin
         p^.Flags:=p^.Flags and not pvTTF_PathFlag_TouchedX;
        end;
        if fGraphicsState.fv[1]<>0 then begin
         p^.Flags:=p^.Flags and not pvTTF_PathFlag_TouchedY;
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opLOOPCALL:begin
       if CallStackTop>=length(CallStack) then begin
        raise EpvTrueTypeFont.Create('Call stack overflow');
       end else begin
        dec(Top);
        f:=fFunctions[fStack[Top]];
        if not (assigned(f.Data) and (f.Size>0)) then begin
         raise EpvTrueTypeFont.Create('Undefined function');
        end else begin
         CallStack[CallStackTop].ProgramBytes:=ProgramBytes;
         CallStack[CallStackTop].PC:=PC;
         CallStack[CallStackTop].LoopCount:=1;
         dec(Top);
         if fStack[Top]<>0 then begin
          CallStack[CallStackTop].LoopCount:=fStack[Top];
          inc(CallStackTop);
          ProgramBytes:=f;
          PC:=0;
          continue;
         end;
        end;
       end;
      end;
      opCALL:begin
       if CallStackTop>=length(CallStack) then begin
        raise EpvTrueTypeFont.Create('Call stack overflow');
       end else begin
        dec(Top);
        f:=fFunctions[fStack[Top]];
        if not (assigned(f.Data) and (f.Size>0)) then begin
         raise EpvTrueTypeFont.Create('Undefined function');
        end else begin
         CallStack[CallStackTop].ProgramBytes:=ProgramBytes;
         CallStack[CallStackTop].PC:=PC;
         CallStack[CallStackTop].LoopCount:=1;
         inc(CallStackTop);
         ProgramBytes:=f;
         PC:=0;
         continue;
        end;
       end;
      end;
      opFDEF:begin
       StartPC:=PC+1;
       repeat
        inc(PC);
        if PC>=ProgramBytes.Size then begin
         raise EpvTrueTypeFont.Create('Unbalanced FDEF');
        end else begin
         case ProgramBytes.Data^[PC] of
          opFDEF:begin
           raise EpvTrueTypeFont.Create('Nested FDEF');
          end;
          opENDF:begin
           dec(Top);
           fFunctions[fStack[Top]].Data:=TpvPointer(@ProgramBytes.Data^[StartPC]);
           fFunctions[fStack[Top]].Size:=(PC-StartPC)+2;
           break;
          end;
          else begin
           OK:=SkipInstructionPayload(ProgramBytes,PC);
           if not OK Then begin
            raise EpvTrueTypeFont.Create('Unbalanced FDEF');
           end;
          end;
         end;
        end;
       until false;
      end;
      opENDF:begin
       if CallStackTop<=0 then begin
        raise EpvTrueTypeFont.Create('Call stack underflow');
       end else begin
        dec(CallStackTop);
        dec(CallStack[CallStackTop].LoopCount);
        if CallStack[CallStackTop].LoopCount>0 then begin
         inc(CallStackTop);
         PC:=0;
         continue;
        end else begin
         ProgramBytes:=CallStack[CallStackTop].ProgramBytes;
         PC:=CallStack[CallStackTop].PC;
        end;
       end;
      end;
      opMDAP0:begin
       dec(Top);
       i:=fStack[Top];
       p:=GetPoint(0,pvTTF_PointType_Current,i);
       if assigned(p) then begin
        MovePoint(p^,0,true);
        fGraphicsState.rp[0]:=i;
        fGraphicsState.rp[1]:=i;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opMDAP1:begin
       dec(Top);
       i:=fStack[Top];
       p:=GetPoint(0,pvTTF_PointType_Current,i);
       if assigned(p) then begin
        Distance:=DotProduct(p^.x,p^.y,fGraphicsState.pv);
        Distance:=RoundValue(Distance)-Distance;
        MovePoint(p^,Distance,true);
        fGraphicsState.rp[0]:=i;
        fGraphicsState.rp[1]:=i;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opIUP0,opIUP1:begin
       if Opcode=opIUP0 then begin
        Mask:=pvTTF_PathFlag_TouchedY;
       end else begin
        Mask:=pvTTF_PathFlag_TouchedX;
       end;
       CurrentPoint:=0;
       for i:=0 to length(fEnds)-1 do begin
        EndPoint:=fEnds[i];
        FirstPoint:=CurrentPoint;
        if EndPoint>=length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current]) then begin
         EndPoint:=length(fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current])-1;
        end;
        while (CurrentPoint<=EndPoint) and ((fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,CurrentPoint].Flags and Mask)=0) do begin
         inc(CurrentPoint);
        end;
        if CurrentPoint<=EndPoint then begin
         FirstTouched:=CurrentPoint;
         CurrentTouched:=CurrentPoint;
         inc(CurrentPoint);
         while CurrentPoint<=EndPoint do begin
          if (fPoints[pvTTF_Zone_Glyph,pvTTF_PointType_Current,CurrentPoint].Flags and Mask)<>0 then begin
           IUPInterpolate(Opcode=opIUP0,CurrentTouched+1,CurrentPoint-1,CurrentTouched,CurrentPoint);
           CurrentTouched:=CurrentPoint;
          end;
          inc(CurrentPoint);
         end;
         if CurrentTouched=FirstTouched then begin
          IUPShift(Opcode=opIUP0,FirstPoint,EndPoint,CurrentTouched);
         end else begin
          IUPInterpolate(Opcode=opIUP0,CurrentTouched+1,EndPoint,CurrentTouched,FirstTouched);
          if FirstTouched>0 then begin
           IUPInterpolate(Opcode=opIUP0,FirstPoint,FirstTouched-1,CurrentTouched,FirstTouched);
          end;
         end;
        end;
       end;
      end;
      opSHP0,opSHP1:begin
       if Top<fGraphicsState.Loop then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        ComputePointDisplacement(Opcode=opSHP1,ZonePointer,RefIndex,dx,dy);
        while fGraphicsState.Loop<>0 do begin
         dec(Top);
         i:=fStack[Top];
         p:=GetPoint(2,pvTTF_PointType_Current,i);
         if fGraphicsState.fv[0]<>0 then begin
          inc(p^.x,dx);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedX;
         end;
         if fGraphicsState.fv[1]<>0 then begin
          inc(p^.y,dy);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedY;
         end;
         dec(fGraphicsState.Loop);
        end;
        fGraphicsState.Loop:=1;
       end;
      end;
      opSHC0,opSHC1:begin
       ComputePointDisplacement(Opcode=opSHC1,ZonePointer,RefIndex,dx,dy);
       dec(Top);
       x:=fStack[Top];
       if (x<0) or (x>=length(fEnds)) then begin
        raise EpvTrueTypeFont.Create('Contour range underflow');
       end else if x=0 then begin
        i:=0;
        j:=fEnds[x];
       end else begin
        i:=fEnds[x-1]+1;
        j:=fEnds[x];
       end;
       while i<=j do begin
        if (ZonePointer<>2) or (i<>RefIndex) then begin
         p:=GetPoint(2,pvTTF_PointType_Current,i);
         if fGraphicsState.fv[0]<>0 then begin
          inc(p^.x,dx);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedX;
         end;
         if fGraphicsState.fv[1]<>0 then begin
          inc(p^.y,dy);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedY;
         end;
        end;
        inc(i);
       end;
      end;
      opSHZ0,opSHZ1:begin
       ComputePointDisplacement(Opcode=opSHZ1,ZonePointer,RefIndex,dx,dy);
       dec(Top);
       x:=fStack[Top];
       if (x<0) or (x>2) then begin
        raise EpvTrueTypeFont.Create('Zone range underflow');
       end else begin
        i:=0;
        j:=length(fPoints[fGraphicsState.zp[x],pvTTF_PointType_Current]);
        if fGraphicsState.zp[x]=pvTTF_Zone_Glyph then begin
         dec(j,4);
        end;
        while i<j do begin
         if (ZonePointer<>x) or (i<>RefIndex) then begin
          p:=GetPoint(2,pvTTF_PointType_Current,i);
          if fGraphicsState.fv[0]<>0 then begin
           inc(p^.x,dx);
          end;
          if fGraphicsState.fv[1]<>0 then begin
           inc(p^.y,dy);
          end;
         end;
         inc(i);
        end;
       end;
      end;
      opSHPIX:begin
       if Top<(fGraphicsState.Loop+1) then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        dec(Top);
        Distance:=fStack[Top];
        dx:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[0],14);
        dy:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[1],14);
        while fGraphicsState.Loop<>0 do begin
         dec(Top);
         i:=fStack[Top];
         p:=GetPoint(2,pvTTF_PointType_Current,i);
         if fGraphicsState.fv[0]<>0 then begin
          inc(p^.x,dx);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedX;
         end;
         if fGraphicsState.fv[1]<>0 then begin
          inc(p^.y,dy);
          p^.Flags:=p^.Flags or pvTTF_PathFlag_TouchedY;
         end;
         dec(fGraphicsState.Loop);
        end;
        fGraphicsState.Loop:=1;
       end;
      end;
      opIP:begin
       if Top<fGraphicsState.Loop then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        Twilight:=(fGraphicsState.zp[0]=0) or (fGraphicsState.zp[1]=0) or (fGraphicsState.zp[2]=0);
        if Twilight then begin
         PointType:=pvTTF_PointType_Unhinted;
        end else begin
         PointType:=pvTTF_PointType_InFontUnits;
        end;
        p:=GetPoint(1,PointType,fGraphicsState.rp[2]);
        OldP:=GetPoint(0,PointType,fGraphicsState.rp[1]);
        if assigned(p) and assigned(OldP) then begin
         if PointType=pvTTF_PointType_InFontUnits then begin
          OldRange:=DotProduct(fFont.Scale(p^.x-OldP^.x),fFont.Scale(p^.y-OldP^.y),fGraphicsState.dv);
         end else begin
          OldRange:=DotProduct(p^.x-OldP^.x,p^.y-OldP^.y,fGraphicsState.dv);
         end;
        end else begin
         OldRange:=0;
        end;
        p:=GetPoint(1,pvTTF_PointType_Current,fGraphicsState.rp[2]);
        CurrentP:=GetPoint(0,pvTTF_PointType_Current,fGraphicsState.rp[1]);
        if assigned(p) and assigned(CurrentP) then begin
         CurrentRange:=DotProduct(p^.x-CurrentP^.x,p^.y-CurrentP^.y,fGraphicsState.pv);
        end else begin
         CurrentRange:=0;
        end;
        while fGraphicsState.Loop<>0 do begin
         dec(Top);
         i:=fStack[Top];
         p:=GetPoint(2,PointType,i);
         if assigned(p) then begin
          if PointType=pvTTF_PointType_InFontUnits then begin
           OldDist:=DotProduct(fFont.Scale(p^.x-OldP^.x),fFont.Scale(p^.y-OldP^.y),fGraphicsState.dv);
          end else begin
           OldDist:=DotProduct(p^.x-OldP^.x,p^.y-OldP^.y,fGraphicsState.dv);
          end;
          p:=GetPoint(2,pvTTF_PointType_Current,i);
          if assigned(p) then begin
           CurrentDist:=DotProduct(p^.x-CurrentP^.x,p^.y-CurrentP^.y,fGraphicsState.pv);
           if OldDist<>0 then begin
            if OldRange<>0 then begin
             NewDist:=MulDiv(OldDist,CurrentRange,OldRange,true);
            end else begin
             NewDist:=-OldDist;
            end;
           end else begin
            NewDist:=0;
           end;
           MovePoint(p^,NewDist-CurrentDist,true);
          end;
         end;
         dec(fGraphicsState.Loop);
        end;
        fGraphicsState.Loop:=1;
       end;
      end;
      opMSIRP0,opMSIRP1:begin
       dec(Top,2);
       d:=fStack[Top+1];
       i:=fStack[Top];
       if fGraphicsState.zp[0]=pvTTF_Zone_Twilight then begin
        // undocumented behaviour
        p0:=GetPoint(0,pvTTF_PointType_Unhinted,fGraphicsState.rp[0]);
        p1:=GetPoint(1,pvTTF_PointType_Unhinted,fGraphicsState.rp[0]);
        p2:=GetPoint(1,pvTTF_PointType_Current,fGraphicsState.rp[0]);
        if assigned(p0) and assigned(p1) and assigned(p2) then begin
         p1^:=p0^;
         p2^:=p0^;
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end;
       p1:=GetPoint(1,pvTTF_PointType_Current,i);
       p2:=GetPoint(0,pvTTF_PointType_Current,fGraphicsState.rp[0]);
       if assigned(p1) and assigned(p2) then begin
        Distance:=DotProduct(p1^.x-p2^.x,p1^.y-p2^.y,fGraphicsState.pv);
        MovePoint(p1^,d-Distance,true);
        fGraphicsState.rp[1]:=fGraphicsState.rp[0];
        fGraphicsState.rp[2]:=i;
        if Opcode=opMSIRP1 then begin
         fGraphicsState.rp[0]:=i;
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opALIGNRP:begin
       if Top<fGraphicsState.Loop then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        Ref:=GetPoint(0,pvTTF_PointType_Current,fGraphicsState.rp[0]);
        if assigned(Ref) then begin
         while fGraphicsState.Loop<>0 do begin
          dec(Top);
          p:=GetPoint(1,pvTTF_PointType_Current,fStack[Top]);
          if assigned(p) then begin
           MovePoint(p^,-DotProduct(p^.x-Ref^.x,p^.y-Ref^.y,fGraphicsState.pv),true);
           dec(fGraphicsState.Loop);
          end else begin
           raise EpvTrueTypeFont.Create('Out of point bounds');
          end;
         end;
         fGraphicsState.Loop:=1;
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end;
      end;
      opRTDG:begin
       fGraphicsState.RoundPeriod:=1 shl 5;
       fGraphicsState.RoundPhase:=0;
       fGraphicsState.RoundThreshold:=1 shl 4;
       fGraphicsState.RoundSuper45:=false;
      end;
      opMIAP0:begin
       dec(Top,2);
       i:=fStack[Top];
       Distance:=GetCVT(fStack[Top+1]);
       if fGraphicsState.zp[0]=0 then begin
        p:=GetPoint(0,pvTTF_PointType_Unhinted,i);
        q:=GetPoint(0,pvTTF_PointType_Current,i);
        if assigned(p) and assigned(q) then begin
         p^.x:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[0],14);
         p^.y:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[1],14);
         q^:=p^;
        end;
       end;
       p:=GetPoint(0,pvTTF_PointType_Current,i);
       if assigned(p) then begin
        OldDist:=DotProduct(p^.x,p^.y,fGraphicsState.pv);
        MovePoint(p^,Distance-OldDist,true);
       end;
       fGraphicsState.rp[0]:=i;
       fGraphicsState.rp[1]:=i;
      end;
      opMIAP1:begin
       dec(Top,2);
       i:=fStack[Top];
       Distance:=GetCVT(fStack[Top+1]);
       if fGraphicsState.zp[0]=0 then begin
        p:=GetPoint(0,pvTTF_PointType_Unhinted,i);
        q:=GetPoint(0,pvTTF_PointType_Current,i);
        if assigned(p) and assigned(q) then begin
         p^.x:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[0],14);
         p^.y:=SARInt64(TpvInt64(Distance)*fGraphicsState.fv[1],14);
         q^:=p^;
        end;
       end;
       p:=GetPoint(0,pvTTF_PointType_Current,i);
       if assigned(p) then begin
        OldDist:=DotProduct(p^.x,p^.y,fGraphicsState.pv);
        if abs(Distance-OldDist)>fGraphicsState.ControlValueCutIn then begin
         Distance:=OldDist;
        end;
        Distance:=RoundValue(Distance);
        MovePoint(p^,Distance-OldDist,true);
       end;
       fGraphicsState.rp[0]:=i;
       fGraphicsState.rp[1]:=i;
      end;
      opNPUSHB:begin
       inc(PC);
       if PC>=ProgramBytes.Size then begin
        raise EpvTrueTypeFont.Create('Insufficient data');
       end else begin
        Opcode:=ProgramBytes.Data^[PC];
        inc(PC);
        if (Top+Opcode)>length(fStack) then begin
         raise EpvTrueTypeFont.Create('Stack overflow');
        end else if (PC+Opcode)>ProgramBytes.Size then begin
         raise EpvTrueTypeFont.Create('Insufficient data');
        end else begin
         while Opcode>0 do begin
          fStack[Top]:=ProgramBytes.Data^[PC];
          inc(Top);
          inc(PC);
          dec(Opcode);
         end;
        end;
       end;
       continue;
      end;
      opNPUSHW:begin
       inc(PC);
       if PC>=ProgramBytes.Size then begin
        raise EpvTrueTypeFont.Create('Insufficient data');
       end else begin
        Opcode:=ProgramBytes.Data^[PC];
        inc(PC);
        if (Top+Opcode)>length(fStack) then begin
         raise EpvTrueTypeFont.Create('Stack overflow');
        end else if (PC+(Opcode*2))>ProgramBytes.Size then begin
         raise EpvTrueTypeFont.Create('Insufficient data');
        end else begin
         while Opcode>0 do begin
          fStack[Top]:=TpvInt16(TpvUInt16((ProgramBytes.Data^[PC] shl 8) or ProgramBytes.Data^[PC+1]));
          inc(Top);
          inc(PC,2);
          dec(Opcode);
         end;
        end;
       end;
       continue;
      end;
      opWS:begin
       dec(Top,2);
       i:=fStack[Top];
       if (i>=0) and (i<length(fStorage)) then begin
        fStorage[i]:=fStack[Top+1];
       end else begin
        raise EpvTrueTypeFont.Create('Invalid data');
       end;
      end;
      opRS:begin
       i:=fStack[Top-1];
       if (i>=0) and (i<length(fStorage)) then begin
        fStack[Top-1]:=fStorage[i];
       end else begin
        raise EpvTrueTypeFont.Create('Invalid data');
       end;
      end;
      opWCVTP:begin
       dec(Top,2);
       SetCVT(fStack[Top],fStack[Top+1]);
      end;
      opRCVT:begin
       fStack[Top-1]:=GetCVT(fStack[Top-1]);
      end;
      opGC0,opGC1:begin
       p:=GetPoint(2,pvTTF_PointType_Current,fStack[Top-1]);
       if assigned(p) then begin
        case Opcode of
         opGC0:begin
          fStack[Top-1]:=DotProduct(p^.x,p^.y,fGraphicsState.pv);
         end;
         opGC1:begin
          fStack[Top-1]:=DotProduct(p^.x,p^.y,fGraphicsState.dv);
         end;
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opSCFS:begin
       dec(Top,2);
       Distance:=fStack[Top+1];
       p:=GetPoint(2,pvTTF_PointType_Current,fStack[Top]);
       if assigned(p) then begin
        OldDist:=DotProduct(p^.x,p^.y,fGraphicsState.pv);
        MovePoint(p^,Distance-OldDist,true);
        if fGraphicsState.zp[2]=0 then begin
         // UNDOCUMENTED! The MS rasterizer does that with twilight points
         p1:=GetPoint(2,pvTTF_PointType_Unhinted,fStack[Top]);
         if assigned(p1) then begin
{         p1^.x:=p0^.x;
          p1^.y:=p0^.y;}
          p1^.x:=p^.x;
          p1^.y:=p^.y;
         end;
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opMD0:begin
       dec(Top);
       p0:=GetPoint(0,pvTTF_PointType_Current,fStack[Top-1]);
       p1:=GetPoint(1,pvTTF_PointType_Current,fStack[Top]);
       if assigned(p0) and assigned(p1) then begin
        fStack[Top-1]:=DotProduct(p0^.x-p1^.x,p0^.y-p1^.y,fGraphicsState.pv);
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opMD1:begin
       dec(Top);
       if (fGraphicsState.zp[0]=0) or (fGraphicsState.zp[1]=0) then begin
        p0:=GetPoint(0,pvTTF_PointType_Unhinted,fStack[Top-1]);
        p1:=GetPoint(1,pvTTF_PointType_Unhinted,fStack[Top]);
        if assigned(p0) and assigned(p1) then begin
         fStack[Top-1]:=DotProduct(p0^.x-p1^.x,p0^.y-p1^.y,fGraphicsState.dv);
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end else begin
        // UNDOCUMENTED: twilight zone special case
        p0:=GetPoint(0,pvTTF_PointType_InFontUnits,fStack[Top-1]);
        p1:=GetPoint(1,pvTTF_PointType_InFontUnits,fStack[Top]);
        if assigned(p0) and assigned(p1) then begin
         fStack[Top-1]:=DotProduct(fFont.Scale(p0^.x-p1^.x),fFont.Scale(p0^.y-p1^.y),fGraphicsState.dv);
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end;
      end;
      opMPPEM:begin
       if Top>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=SARLongint(Font.GetScale+32,6);
        inc(Top);
       end;
      end;
      opMPS:begin
       if Top>=length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else begin
        fStack[Top]:=SARLongint(Font.GetScale+32,6);
        inc(Top);
       end;
      end;
      opFLIPON:begin
       fGraphicsState.AutoFlip:=true;
      end;
      opFLIPOFF:begin
       fGraphicsState.AutoFlip:=false;
      end;
      opDEBUG:begin
      end;
      opLT:begin
       dec(Top);
       if fStack[Top-1]<fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opLTEQ:begin
       dec(Top);
       if fStack[Top-1]<=fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opGT:begin
       dec(Top);
       if fStack[Top-1]>fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opGTEQ:begin
       dec(Top);
       if fStack[Top-1]>=fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opEQ:begin
       dec(Top);
       if fStack[Top-1]=fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opNEQ:begin
       dec(Top);
       if fStack[Top-1]<>fStack[Top] then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opODD:begin
       fStack[Top-1]:=SARLongint(RoundValue(fStack[Top-1]),6) and 1;
      end;
      opEVEN:begin
       fStack[Top-1]:=(SARLongint(RoundValue(fStack[Top-1]),6) and 1) xor 1;
      end;
      opIF:begin
       dec(Top);
       if fStack[Top]=0 then begin
        Depth:=0;
        repeat
         inc(PC);
         if PC>=ProgramBytes.Size then begin
          raise EpvTrueTypeFont.Create('Unbalanced IF');
         end else begin
          case ProgramBytes.Data^[PC] of
           opIF:begin
            inc(Depth);
           end;
           opELSE:begin
            if Depth=0 then begin
             break;
            end;
           end;
           opEIF:begin
            dec(Depth);
            if Depth<0 then begin
             break;
            end;
           end;
           else begin
            OK:=SkipInstructionPayload(ProgramBytes,PC);
            if not OK Then begin
             raise EpvTrueTypeFont.Create('Unbalanced IF');
            end;
           end;
          end;
         end;
        until false;
       end;
      end;
      opEIF:begin
      end;
      opAND:begin
       dec(Top);
       if (fStack[Top-1]<>0) and (fStack[Top]<>0) then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opOR:begin
       dec(Top);
       if (fStack[Top-1] or fStack[Top])<>0 then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opNOT:begin
       if fStack[Top-1]=0 then begin
        fStack[Top-1]:=1;
       end else begin
        fStack[Top-1]:=0;
       end;
      end;
      opDELTAP1,opDELTAP2,opDELTAP3:begin
       if Top<1 then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        dec(Top);
        Base:=fGraphicsState.DeltaBase;
        case Opcode of
         opDELTAP2:begin
          inc(Base,16);
         end;
         opDELTAP3:begin
          inc(Base,32);
         end;
        end;
        x:=SARLongint(fFont.GetScale,6);
        Count:=fStack[Top];
        if Top<(Count*2) then begin
         raise EpvTrueTypeFont.Create('Stack underflow');
        end else begin
         while Count<>0 do begin
          dec(Top,2);
          i:=fStack[Top+1];
          j:=fStack[Top];
          k:=((j and $f0) shr 4)+Base;
          if k=x then begin
           p:=GetPoint(0,pvTTF_PointType_Current,i);
           if assigned(p) then begin
            j:=(j and $f)-8;
            if j>=0 then begin
             inc(j);
            end;
            MovePoint(p^,(j*64) div (1 shl fGraphicsState.DeltaShift),true);
           end;
          end;
          dec(Count);
         end;
        end;
       end;
      end;
      opDELTAC1,opDELTAC2,opDELTAC3:begin
       if Top<1 then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        dec(Top);
        Base:=fGraphicsState.DeltaBase;
        case Opcode of
         opDELTAC2:begin
          inc(Base,16);
         end;
         opDELTAC3:begin
          inc(Base,32);
         end;
        end;
        x:=SARLongint(fFont.GetScale+32,6);
        Count:=fStack[Top];
        if Top<(Count*2) then begin
         raise EpvTrueTypeFont.Create('Stack underflow');
        end else begin
         while Count<>0 do begin
          dec(Top,2);
          i:=fStack[Top+1];
          j:=fStack[Top];
          k:=((j and $f0) shr 4)+Base;
          if k=x then begin
           j:=(j and $f)-8;
           if j>=0 then begin
            inc(j);
           end;
           j:=(j*64) div (1 shl fGraphicsState.DeltaShift);
           if (i>=0) and (i<length(fFont.fCVT)) then begin
            inc(fCVT[i],j);
           end;
          end;
          dec(Count);
         end;
        end;
       end;
      end;
      opSDB:begin
       dec(Top);
       fGraphicsState.DeltaBase:=fStack[Top];
      end;
      opSDS:begin
       dec(Top);
       fGraphicsState.DeltaShift:=fStack[Top];
      end;
      opADD:begin
       dec(Top);
       inc(fStack[Top-1],fStack[Top]);
      end;
      opSUB:begin
       dec(Top);
       dec(fStack[Top-1],fStack[Top]);
      end;
      opDIV:begin
       dec(Top);
       if fStack[Top]=0 then begin
        raise EpvTrueTypeFont.Create('Division by zero');
       end else begin
        fStack[Top-1]:=Div26d6(fStack[Top-1],fStack[Top]);
       end;
      end;
      opMUL:begin
       dec(Top);
       fStack[Top-1]:=Mul26d6(fStack[Top-1],fStack[Top]);
      end;
      opABS:begin
       if fStack[Top-1]<0 then begin
        fStack[Top-1]:=-fStack[Top-1];
       end;
      end;
      opNEG:begin
       fStack[Top-1]:=-fStack[Top-1];
      end;
      opFLOOR:begin
       fStack[Top-1]:=fStack[Top-1] and not 63;
      end;
      opCEILING:begin
       fStack[Top-1]:=(fStack[Top-1]+63) and not 63;
      end;
      opROUND00,opROUND01,opROUND10,opROUND11:begin
       fStack[Top-1]:=RoundValue(fStack[Top-1]);
      end;
      opNROUND00,opNROUND01,opNROUND10,opNROUND11:begin
       // Not needed, since we do not our job for dot-matrix printers :-)
      end;
      opWCVTF:begin
       dec(Top,2);
       SetCVT(fStack[Top],SARLongint(Font.Scale(fStack[Top+1])+32,6));
      end;
      opSROUND,opS45ROUND:begin
       dec(Top);
       case SARLongint(fStack[Top],6) and 3 of
        0:begin
         fGraphicsState.RoundPeriod:=1 shl 5;
        end;
        1,3:begin
         fGraphicsState.RoundPeriod:=1 shl 6;
        end;
        2:begin
         fGraphicsState.RoundPeriod:=1 shl 7;
        end;
       end;
       if Opcode=opS45ROUND then begin
        fGraphicsState.RoundSuper45:=true;
        fGraphicsState.RoundPeriod:=SARLongint(fGraphicsState.RoundPeriod*46341,16);
       end else begin
        fGraphicsState.RoundSuper45:=false;
       end;
       fGraphicsState.RoundPhase:=SARLongint(fGraphicsState.RoundPeriod*(SARLongint(fStack[Top],4) and 3),2);
       x:=fStack[Top] and $f;
       if x<>0 then begin
        fGraphicsState.RoundThreshold:=SARLongint(fGraphicsState.RoundPeriod*(x-4),3);
       end else begin
        fGraphicsState.RoundThreshold:=fGraphicsState.RoundPeriod-1;
       end;
      end;
      opJROT:begin
       dec(Top,2);
       if fStack[Top+1]<>0 then begin
        inc(PC,fStack[Top]);
        continue;
       end;
      end;
      opJROF:begin
       dec(Top,2);
       if fStack[Top+1]=0 then begin
        inc(PC,fStack[Top]);
        continue;
       end;
      end;
      opROFF:begin
       fGraphicsState.RoundPeriod:=0;
       fGraphicsState.RoundPhase:=0;
       fGraphicsState.RoundThreshold:=0;
       fGraphicsState.RoundSuper45:=false;
      end;
      opRUTG:begin
       fGraphicsState.RoundPeriod:=1 shl 6;
       fGraphicsState.RoundPhase:=0;
       fGraphicsState.RoundThreshold:=(1 shl 6)-1;
       fGraphicsState.RoundSuper45:=false;
      end;
      opRDTG:begin
       fGraphicsState.RoundPeriod:=1 shl 6;
       fGraphicsState.RoundPhase:=0;
       fGraphicsState.RoundThreshold:=0;
       fGraphicsState.RoundSuper45:=false;
      end;
      opSANGW:begin
       dec(Top);
      end;
      opFLIPPT:begin
       if Top<fGraphicsState.Loop then begin
        raise EpvTrueTypeFont.Create('Stack underflow');
       end else begin
        dec(Top);
        while fGraphicsState.Loop<>0 do begin
         dec(Top);
         i:=fStack[Top];
         p:=GetPoint(1,pvTTF_PointType_Current,i);
         if assigned(p) then begin
          p^.Flags:=p^.Flags xor pvTTF_PathFlag_OnCurve;
         end;
         dec(fGraphicsState.Loop);
        end;
        fGraphicsState.Loop:=1;
       end;
      end;
      opFLIPRGON:begin
       dec(Top,2);
       j:=fStack[Top+1];
       i:=fStack[Top];
       while i<=j do begin
        p:=GetPoint(1,pvTTF_PointType_Current,i);
        if assigned(p) then begin
         p^.Flags:=p^.Flags or pvTTF_PathFlag_OnCurve;
        end;
        inc(i);
       end;
      end;
      opFLIPRGOFF:begin
       dec(Top,2);
       j:=fStack[Top+1];
       i:=fStack[Top];
       while i<=j do begin
        p:=GetPoint(1,pvTTF_PointType_Current,i);
        if assigned(p) then begin
         p^.Flags:=p^.Flags and not pvTTF_PathFlag_OnCurve;
        end;
        inc(i);
       end;
      end;
      opAA:begin
       dec(Top);
      end;
      opSCANCTRL:begin
       dec(Top);
      end;
      opSDPVTL0,opSDPVTL1:begin
       dec(Top,2);
       p1:=GetPoint(1,pvTTF_PointType_Unhinted,fStack[Top]);
       p2:=GetPoint(2,pvTTF_PointType_Unhinted,fStack[Top+1]);
       if assigned(p1) and assigned(p2) then begin
        dx:=p1^.x-p2^.x;
        dy:=p1^.y-p2^.y;
        if (dx=0) and (dy=0) then begin
         dx:=$4000;
         Opcode:=opSDPVTL0;
        end;
        Normalize(dx,dy);
        if Opcode=opSDPVTL0 then begin
         fGraphicsState.dv[0]:=dx;
         fGraphicsState.dv[1]:=dy;
        end else begin
         fGraphicsState.dv[0]:=-dy;
         fGraphicsState.dv[1]:=dx;
        end;
        p1:=GetPoint(1,pvTTF_PointType_Current,fStack[Top]);
        p2:=GetPoint(2,pvTTF_PointType_Current,fStack[Top+1]);
        if assigned(p1) and assigned(p2) then begin
         dx:=p1^.x-p2^.x;
         dy:=p1^.y-p2^.y;
         if (dx=0) and (dy=0) then begin
          dx:=$4000;
          Opcode:=opSDPVTL0;
         end;
         Normalize(dx,dy);
         if Opcode=opSDPVTL0 then begin
          fGraphicsState.pv[0]:=dx;
          fGraphicsState.pv[1]:=dy;
         end else begin
          fGraphicsState.pv[0]:=-dy;
          fGraphicsState.pv[1]:=dx;
         end;
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opGETINFO:begin
       x:=0;
       if (fStack[Top-1] and 1)<>0 then begin
        x:=x or 35; // Version 35, same as Windows 98 and Freetype
       end;
       if (fStack[Top-1] and 32)<>0 then begin
        x:=x or 4096; // Greyscale suppiort
       end;
       fStack[Top-1]:=x;
      end;
      opIDEF:begin
       raise EpvTrueTypeFont.Create('Unsupported IDEF instruction');
      end;
      opROLL:begin
       t1:=fStack[Top-1];
       t2:=fStack[Top-2];
       t3:=fStack[Top-3];
       fStack[Top-1]:=t3;
       fStack[Top-2]:=t1;
       fStack[Top-3]:=t2;
      end;
      opMAX:begin
       dec(Top);
       if fStack[Top-1]<fStack[Top] then begin
        fStack[Top-1]:=fStack[Top];
       end;
      end;
      opMIN:begin
       dec(Top);
       if fStack[Top-1]>fStack[Top] then begin
        fStack[Top-1]:=fStack[Top];
       end;
      end;
      opSCANTYPE:begin
       dec(Top);
      end;
      opINSTCTRL:begin
       dec(Top,2);
       if (fStack[Top+1]>=1) and (fStack[Top+1]<=2) then begin
        if fStack[Top]<>0 then begin
         fGraphicsState.InstructionControl:=(fGraphicsState.InstructionControl and not fStack[Top+1]) or fStack[Top+1];
        end else begin
         fGraphicsState.InstructionControl:=(fGraphicsState.InstructionControl and not fStack[Top+1]) or fStack[Top];
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Invalid reference');
       end;
      end;
      opPUSHB000,opPUSHB001,opPUSHB010,opPUSHB011,opPUSHB100,opPUSHB101,opPUSHB110,opPUSHB111:begin
       inc(PC);
       dec(Opcode,opPUSHB000-1);
       if (Top+Opcode)>length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else if (PC+Opcode)>ProgramBytes.Size then begin
        raise EpvTrueTypeFont.Create('Insufficient data');
       end else begin
        while Opcode>0 do begin
         fStack[Top]:=ProgramBytes.Data^[PC];
         inc(Top);
         inc(PC);
         dec(Opcode);
        end;
       end;
       continue;
      end;
      opPUSHW000,opPUSHW001,opPUSHW010,opPUSHW011,opPUSHW100,opPUSHW101,opPUSHW110,opPUSHW111:begin
       inc(PC);
       dec(Opcode,opPUSHW000-1);
       if (Top+Opcode)>length(fStack) then begin
        raise EpvTrueTypeFont.Create('Stack overflow');
       end else if (PC+(Opcode*2))>ProgramBytes.Size then begin
        raise EpvTrueTypeFont.Create('Insufficient data');
       end else begin
        while Opcode>0 do begin
         fStack[Top]:=TpvInt16(TpvUInt16((ProgramBytes.Data^[PC] shl 8) or ProgramBytes.Data^[PC+1]));
         inc(Top);
         inc(PC,2);
         dec(Opcode);
        end;
       end;
       continue;
      end;
      opMDRP00000,opMDRP00001,opMDRP00010,opMDRP00011,opMDRP00100,opMDRP00101,opMDRP00110,opMDRP00111,
      opMDRP01000,opMDRP01001,opMDRP01010,opMDRP01011,opMDRP01100,opMDRP01101,opMDRP01110,opMDRP01111,
      opMDRP10000,opMDRP10001,opMDRP10010,opMDRP10011,opMDRP10100,opMDRP10101,opMDRP10110,opMDRP10111,
      opMDRP11000,opMDRP11001,opMDRP11010,opMDRP11011,opMDRP11100,opMDRP11101,opMDRP11110,opMDRP11111:begin
       dec(Top);
       i:=fStack[Top];
       Ref:=GetPoint(0,pvTTF_PointType_Current,fGraphicsState.rp[0]);
       p:=GetPoint(1,pvTTF_PointType_Current,i);
       if assigned(Ref) and assigned(p) then begin
        if (fGraphicsState.zp[0]=0) or (fGraphicsState.zp[1]=0) then begin
         p0:=GetPoint(1,pvTTF_PointType_Unhinted,i);
         p1:=GetPoint(0,pvTTF_PointType_Unhinted,fGraphicsState.rp[0]);
         OldDist:=DotProduct(p0^.x-p1^.x,p0^.y-p1^.y,fGraphicsState.dv);
        end else begin
         p0:=GetPoint(1,pvTTF_PointType_InFontUnits,i);
         p1:=GetPoint(0,pvTTF_PointType_InFontUnits,fGraphicsState.rp[0]);
         OldDist:=fFont.Scale(DotProduct(p0^.x-p1^.x,p0^.y-p1^.y,fGraphicsState.dv));
        end;
        if abs(OldDist-fGraphicsState.SingleWidth)<fGraphicsState.SingleWidthCutIn then begin
         if OldDist>=0 then begin
          OldDist:=fGraphicsState.SingleWidth;
         end else begin
          OldDist:=-fGraphicsState.SingleWidth;
         end;
        end;
        if (Opcode and 4)<>0 then begin
         Distance:=RoundValue(OldDist);
        end else begin
         Distance:=OldDist;
        end;
        if (Opcode and 8)<>0 then begin
         if OldDist>=0 then begin
          if Distance<fGraphicsState.MinDist then begin
           Distance:=fGraphicsState.MinDist;
          end;
         end else begin
          if Distance>(-fGraphicsState.MinDist) then begin
           Distance:=-fGraphicsState.MinDist;
          end;
         end;
        end;
        fGraphicsState.rp[1]:=fGraphicsState.rp[0];
        if (Opcode and 16)<>0 then begin
         fGraphicsState.rp[0]:=i;
        end;
        fGraphicsState.rp[2]:=i;
        OldDist:=DotProduct(p^.x-Ref^.x,p^.y-Ref^.y,fGraphicsState.pv);
        MovePoint(p^,Distance-OldDist,true);
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      opMIRP00000,opMIRP00001,opMIRP00010,opMIRP00011,opMIRP00100,opMIRP00101,opMIRP00110,opMIRP00111,
      opMIRP01000,opMIRP01001,opMIRP01010,opMIRP01011,opMIRP01100,opMIRP01101,opMIRP01110,opMIRP01111,
      opMIRP10000,opMIRP10001,opMIRP10010,opMIRP10011,opMIRP10100,opMIRP10101,opMIRP10110,opMIRP10111,
      opMIRP11000,opMIRP11001,opMIRP11010,opMIRP11011,opMIRP11100,opMIRP11101,opMIRP11110,opMIRP11111:begin
       dec(Top,2);
       i:=fStack[Top];
       CVTDist:=GetCVT(fStack[Top+1]);
       if abs(CVTDist-fGraphicsState.SingleWidth)<fGraphicsState.SingleWidthCutIn then begin
        if CVTDist>=0 then begin
         CVTDist:=fGraphicsState.SingleWidth;
        end else begin
         CVTDist:=-fGraphicsState.SingleWidth;
        end;
       end;
       if fGraphicsState.zp[1]=pvTTF_Zone_Twilight then begin
        // UNDOCUMENTED: when moving a twilight zone point, its original position is changed as well.
        p0:=GetPoint(0,pvTTF_PointType_Unhinted,fGraphicsState.rp[0]);
        p1:=GetPoint(1,pvTTF_PointType_Unhinted,i);
        if assigned(p0) and assigned(p1) then begin
         p1^.x:=p0^.x+MulDiv(CVTDist,fGraphicsState.fv[0],$4000,true);
         p1^.y:=p0^.y+MulDiv(CVTDist,fGraphicsState.fv[1],$4000,true);
         p2:=GetPoint(1,pvTTF_PointType_Current,i);
         if assigned(p2) then begin
          p2^.x:=p1^.x;
          p2^.y:=p1^.y;
         end;
        end;
       end;
       Ref:=GetPoint(0,pvTTF_PointType_Unhinted,fGraphicsState.rp[0]);
       p:=GetPoint(1,pvTTF_PointType_Unhinted,i);
       if assigned(Ref) and assigned(p) then begin
        OldDist:=DotProduct(p^.x-Ref^.x,p^.y-Ref^.y,fGraphicsState.dv);
        Ref:=GetPoint(0,pvTTF_PointType_Current,fGraphicsState.rp[0]);
        p:=GetPoint(1,pvTTF_PointType_Current,i);
        if assigned(Ref) and assigned(p) then begin
         CurrentDist:=DotProduct(p^.x-Ref^.x,p^.y-Ref^.y,fGraphicsState.pv);
         if fGraphicsState.AutoFlip and (TpvInt32(OldDist xor CVTDist)<0) then begin
          CVTDist:=-CVTDist;
         end;
         if (Opcode and 4)<>0 then begin
          if (fGraphicsState.zp[0]=fGraphicsState.zp[1]) and
             (abs(CVTDist-OldDist)>fGraphicsState.ControlValueCutIn) then begin
           CVTDist:=OldDist;
          end;
          Distance:=RoundValue(CVTDist);
         end else begin
          Distance:=CVTDist;
         end;
         if (Opcode and 8)<>0 then begin
          if OldDist>=0 then begin
           if Distance<fGraphicsState.MinDist then begin
            Distance:=fGraphicsState.MinDist;
           end;
          end else begin
           if Distance>(-fGraphicsState.MinDist) then begin
            Distance:=-fGraphicsState.MinDist;
           end;
          end;
         end;
         fGraphicsState.rp[1]:=fGraphicsState.rp[0];
         if (Opcode and 16)<>0 then begin
          fGraphicsState.rp[0]:=i;
         end;
         fGraphicsState.rp[2]:=i;
         MovePoint(p^,Distance-CurrentDist,true);
        end else begin
         raise EpvTrueTypeFont.Create('Out of point bounds');
        end;
       end else begin
        raise EpvTrueTypeFont.Create('Out of point bounds');
       end;
      end;
      else begin
       raise EpvTrueTypeFont.Create('Unrecognized instruction');
      end;
     end;
     inc(PC);
    end;
   end;
  end;
 end;
{$ifdef ttfdebug}
 DumpState;
{$endif}
end;

constructor TpvTrueTypeFont.Create(const Stream:TStream;const TargetPPI:TpvInt32=96;const ForceSelector:boolean=false;const PlatformID:TpvUInt16=pvTTF_PID_Microsoft;const SpecificID:TpvUInt16=pvTTF_SID_MS_UNICODE_CS;const LanguageID:TpvUInt16=pvTTF_LID_MS_USEnglish;const CollectionIndex:TpvInt32=0);
begin
 inherited Create;
 fTargetPPI:=TargetPPI;
 fForceSelector:=ForceSelector;
 fPlatformID:=PlatformID;
 fSpecificID:=SpecificID;
 FLanguageID:=LanguageID;
 fFontDataSize:=0;
 fFontData:=nil;
 fCMaps[0]:=nil;
 fCMaps[1]:=nil;
 fCMapLengths[0]:=0;
 fCMapLengths[1]:=0;
 fCMapFormat:=0;
 fNumTables:=0;
 fIndexToLocationFormat:=0;
 FillChar(fGlyphBuffer,SizeOf(TpvTrueTypeFontGlyphBuffer),AnsiChar(#0));
 FillChar(fPolygonBuffer,SizeOf(TpvTrueTypeFontPolygonBuffer),AnsiChar(#0));
 fGlyfOffset:=0;
 fGlyphLoadedBitmap:=nil;
 fGlyphs:=nil;
 fGlyphOffsetArray:=nil;
 fCountGlyphs:=0;
 fMaxTwilightPoints:=0;
 fMaxStorage:=0;
 fMaxFunctionDefs:=0;
 fMaxStackElements:=0;
 fCVT:=nil;
 FillChar(fFPGM,SizeOf(TpvTrueTypeFontByteCodeInterpreterProgramBytes),AnsiChar(#0));
 FillChar(fPREP,SizeOf(TpvTrueTypeFontByteCodeInterpreterProgramBytes),AnsiChar(#0));
 fStringCopyright:='';
 fStringFamily:='';
 fStringSubFamily:='';
 fStringFullName:='';
 fStringUniqueID:='';
 fStringVersion:='';
 fStringPostScript:='';
 fStringTrademark:='';
 fMaxX:=0;
 fMinX:=0;
 fMaxY:=0;
 fMinY:=0;
 fUnitsPerEm:=0;
 fUnitsPerPixel:=0;
 fThinBoldStrength:=0;
 fOS2Ascender:=0;
 fOS2Descender:=0;
 fOS2LineGap:=0;
 fHorizontalAscender:=0;
 fHorizontalDescender:=0;
 fHorizontalLineGap:=0;
 fVerticalAscender:=0;
 fVerticalDescender:=0;
 fVerticalLineGap:=0;
 fKerningTables:=nil;
 fSize:=12;
 fLetterSpacingX:=0;
 fLetterSpacingY:=0;
 fStyleIndex:=0;
 fHinting:=false;
 fByteCodeInterpreter:=nil;
 fCFFCodePointToGlyphIndexTable:=nil;
 begin
  SetLength(fGASPRanges,4);
  begin
   fGASPRanges[0].LowerPPEM:=0;
   fGASPRanges[0].UpperPPEM:=8;
   fGASPRanges[0].Flags:=pvTTF_GASP_DOGRAY or pvTTF_GASP_SYMMETRIC_GRIDFIT;
  end;
  begin
   fGASPRanges[1].LowerPPEM:=9;
   fGASPRanges[1].UpperPPEM:=16;
   fGASPRanges[1].Flags:=pvTTF_GASP_GRIDFIT or pvTTF_GASP_SYMMETRIC_GRIDFIT;
  end;
  begin
   fGASPRanges[2].LowerPPEM:=17;
   fGASPRanges[2].UpperPPEM:=19;
   fGASPRanges[2].Flags:=pvTTF_GASP_GRIDFIT or pvTTF_GASP_DOGRAY or pvTTF_GASP_SYMMETRIC_GRIDFIT;
  end;
  begin
   fGASPRanges[3].LowerPPEM:=20;
   fGASPRanges[3].UpperPPEM:=$7ffffff;
   fGASPRanges[3].Flags:=pvTTF_GASP_GRIDFIT or pvTTF_GASP_DOGRAY or pvTTF_GASP_SYMMETRIC_GRIDFIT or pvTTF_GASP_SYMMETRIC_SMOOTHING;
  end;
 end;
 FillChar(fByteCodeInterpreterParameters,SizeOf(TpvTrueTypeFontByteCodeInterpreterParameters),#0);
 fIgnoreByteCodeInterpreter:=true;
 fLastError:=pvTTF_TT_ERR_NoError;
 fPostScriptFlavored:=false;
 try
  if ReadFontData(Stream,CollectionIndex)=pvTTF_TT_ERR_NoError then begin

   repeat

    fLastError:=LoadOS2;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadHEAD;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadMAXP;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadNAME;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadCMAP;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadCFF;
    if fLastError=pvTTF_TT_ERR_NoError then begin

     fPostScriptFlavored:=true;

    end else begin

     fLastError:=LoadLOCA;
     if fLastError<>pvTTF_TT_ERR_NoError then begin
      break;
     end;

     fLastError:=LoadGLYF;
     if fLastError<>pvTTF_TT_ERR_NoError then begin
      break;
     end;

    end;

    fLastError:=LoadHHEA;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadHMTX;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadVHEA;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    fLastError:=LoadVMTX;
    if fLastError<>pvTTF_TT_ERR_NoError then begin
     break;
    end;

    LoadGPOS; // GPOS table is only optional
    LoadKERN; // Kerning table is only optional

    if not fPostScriptFlavored then begin

     LoadCVT; // CVT table is only optional
     LoadFPGM; // FPGM table is only optional
     LoadPREP; // PREP table is only optional

    end;

    LoadGASP; // GASP table is only optional

    break;

   until true;

  end;
  try
   fByteCodeInterpreter:=TpvTrueTypeFontByteCodeInterpreter.Create(self);
   fIgnoreByteCodeInterpreter:=false;
   fByteCodeInterpreter.Reinitialize;
  except
   fByteCodeInterpreter:=nil;
   fIgnoreByteCodeInterpreter:=true;
  end;
 finally
 end;
 if fLastError<>pvTTF_TT_ERR_NoError then begin
  case fLastError of
   pvTTF_TT_ERR_InvalidFile:begin
    raise EpvTrueTypeFont.Create('Invalid font file');
   end;
   pvTTF_TT_ERR_CorruptFile:begin
    raise EpvTrueTypeFont.Create('Corrupt font file');
   end;
   pvTTF_TT_ERR_OutOfMemory:begin
    raise EpvTrueTypeFont.Create('Out of memory');
   end;
   pvTTF_TT_ERR_TableNotFound:begin
    raise EpvTrueTypeFont.Create('Font table not found');
   end;
   pvTTF_TT_ERR_NoCharacterMapFound:begin
    raise EpvTrueTypeFont.Create('No character map found');
   end;
   pvTTF_TT_ERR_UnknownCharacterMapFormat:begin
    raise EpvTrueTypeFont.Create('Unknown character map format');
   end;
   pvTTF_TT_ERR_CharacterMapNotPresent:begin
    raise EpvTrueTypeFont.Create('Character map not present');
   end;
   pvTTF_TT_ERR_UnableToOpenFile:begin
    raise EpvTrueTypeFont.Create('Unable to open file');
   end;
   pvTTF_TT_ERR_UnknownKerningFormat:begin
    raise EpvTrueTypeFont.Create('Unknown kerning format');
   end;
   pvTTF_TT_ERR_OutOfBounds:begin
    raise EpvTrueTypeFont.Create('Out of bounds');
   end;
   else begin
    raise EpvTrueTypeFont.Create('Unknown font error');
   end;
  end;
 end;
end;

destructor TpvTrueTypeFont.Destroy;
var i:TpvInt32;
begin
 SetLength(fByteCodeInterpreterParameters.pCurrent,0);
 SetLength(fByteCodeInterpreterParameters.pUnhinted,0);
 SetLength(fByteCodeInterpreterParameters.pInFontUnits,0);
 SetLength(fByteCodeInterpreterParameters.Ends,0);
 FreeAndNil(fByteCodeInterpreter);
 for i:=0 to length(fGlyphs)-1 do begin
  SetLength(fGlyphs[i].Points,0);
  SetLength(fGlyphs[i].EndPointIndices,0);
  SetLength(fGlyphs[i].CompositeSubGlyphs,0);
 end;
 SetLength(fGlyphs,0);
 SetLength(fFontData,0);
 fCMaps[0]:=nil;
 fCMaps[1]:=nil;
 SetLength(fGlyphOffsetArray,0);
 for i:=0 to length(fKerningTables)-1 do begin
  SetLength(fKerningTables[i].KerningPairs,0);
 end;
 SetLength(fCVT,0);
 SetLength(fKerningTables,0);
 SetLength(fGlyphLoadedBitmap,0);
 SetLength(fGASPRanges,0);
 SetLength(fPolygonBuffer.Commands,0);
 SetLength(fGlyphBuffer.Points,0);
 SetLength(fGlyphBuffer.UnhintedPoints,0);
 SetLength(fGlyphBuffer.InFontUnitsPoints,0);
 SetLength(fGlyphBuffer.EndPointIndices,0);
 SetLength(fCFFCodePointToGlyphIndexTable,0);
 inherited Destroy;
end;

procedure TpvTrueTypeFont.SetSize(NewSize:TpvInt32);
begin
 if fSize<>NewSize then begin
  fSize:=NewSize;
  if assigned(fByteCodeInterpreter) and not fIgnoreByteCodeInterpreter then begin
   try
    fByteCodeInterpreter.Reinitialize;
   except
    fByteCodeInterpreter:=nil;
    fIgnoreByteCodeInterpreter:=true;
   end;
  end;
 end;
end;

function TpvTrueTypeFont.ReadFontData(Stream:TStream;CollectionIndex:TpvInt32):TpvInt32;
var i,tablelength,tabledirsize,tabledatasize:TpvInt32;
    tfd:array[0..pvTTF_OFFSET_TABLE_SIZE-1] of TpvUInt8;
    TableDirectory:array of TpvUInt8;
    i64:TpvInt64;
begin
 if (not assigned(Stream)) or (Stream.Seek(0,soBeginning)<>0) then begin
  result:=pvTTF_TT_ERR_UnableToOpenFile;
  exit;
 end;

 if Stream.Read(tfd,pvTTF_OFFSET_TABLE_SIZE)<>pvTTF_OFFSET_TABLE_SIZE then begin
  result:=pvTTF_TT_ERR_CorruptFile;
  exit;
 end;

 if ((tfd[0]=ord('t')) and (tfd[1]=ord('t')) and (tfd[2]=ord('c')) and (tfd[3]=ord('f'))) and
    ((tfd[4]=$00) or (tfd[5] in [$01,$02]) or (tfd[6]=$00) or (tfd[7]=$00)) then begin
  i:=CollectionIndex;
  if TpvUInt32(i+0)>=ToLONGWORD(tfd[8],tfd[9],tfd[10],tfd[11]) then begin
   result:=pvTTF_TT_ERR_InvalidFile;
   exit;
  end;
  if Stream.Seek(12+(i*14),soBeginning)<>(12+(i*14)) then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;
  if Stream.Read(tfd,4)<>4 then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;
  i64:=ToLONGWORD(tfd[0],tfd[1],tfd[2],tfd[3]);
  if Stream.Seek(i64,soBeginning)<>i64 then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;
  if Stream.Read(tfd,pvTTF_OFFSET_TABLE_SIZE)<>pvTTF_OFFSET_TABLE_SIZE then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;
 end;

 if ((tfd[0]=ord('1')) and (tfd[1]=$00) and (tfd[2]=$00) and (tfd[3]=$00)) or                         // 1\x00\x00\x00    - TrueType 1
    ((tfd[0]=$00) and (tfd[1]=$01) and (tfd[2]=$00) and (tfd[3]=$00)) or                              // \x00\x01\x00\x00 - OpenType 1.0
    ((tfd[0]=ord('t')) and (tfd[1]=ord('y')) and (tfd[2]=ord('p')) and (tfd[3]=ord('1'))) or          // typ1             - TrueType with type 1 font data (but type 1 stuff is not supported here!)
    ((tfd[0]=ord('t')) and (tfd[1]=ord('r')) and (tfd[2]=ord('u')) and (tfd[3]=ord('e'))) or          // true             - TrueType
    ((tfd[0]=ord('O')) and (tfd[1]=ord('T')) and (tfd[2]=ord('T')) and (tfd[3]=ord('O'))) then begin  // OTTO             - OpenType with CFF

  fNumTables:=ToWORD(tfd[4],tfd[5]); // Get the number of Tables in this font
  tabledirsize:=sizeof(TpvUInt32)*4*fNumTables; // Calculate Size of Table Directory
  TableDirectory:=nil;
  SetLength(TableDirectory,tabledirsize);              // Allocate storage for Table Directory
  if length(TableDirectory)<>tabledirsize then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;

  tabledatasize:=0;
  i:=0;
  while i<tabledirsize do begin
   if Stream.Read(TableDirectory[i],16)<>16 then begin
    SetLength(TableDirectory,0);
    result:=pvTTF_TT_ERR_CorruptFile;
    exit;
   end;
   tablelength:=ToLONGWORD(TableDirectory[i+12],TableDirectory[i+13],TableDirectory[i+14],TableDirectory[i+15]);
   if (tablelength and 3)<>0 then begin
    inc(tablelength,4-(tablelength and 3));
   end;
   inc(tabledatasize,tablelength);
   inc(i,16);
  end;

  fFontDataSize:=pvTTF_OFFSET_TABLE_SIZE+tabledirsize+tabledatasize; // Calculate Size of entire font file
  SetLength(fFontData,fFontDataSize); // Allocate space for all that Data
  if length(fFontData)<>fFontDataSize then begin
   SetLength(TableDirectory,0);
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;
  FillChar(fFontData[0],fFontDataSize,#0);

  Move(tfd[0],fFontData[0],pvTTF_OFFSET_TABLE_SIZE); // Store the Offset Table
  Move(TableDirectory[0],fFontData[pvTTF_OFFSET_TABLE_SIZE],tabledirsize); // Store the Offset Table
  if Stream.Read(fFontData[pvTTF_OFFSET_TABLE_SIZE+tabledirsize],(fFontDataSize-(pvTTF_OFFSET_TABLE_SIZE+tabledirsize)))<>((fFontDataSize-(pvTTF_OFFSET_TABLE_SIZE+tabledirsize))) then begin // Store the rest of the font
   // Some TTF files are shorter than they must be? So this is commented out:
 { SetLength(TableDirectory,0);
   SetLength(fFontData,0);
   fFontDataSize:=0;
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;}
  end;

  SetLength(TableDirectory,0);

  result:=pvTTF_TT_ERR_NoError;

 end else begin

  result:=pvTTF_TT_ERR_CorruptFile;

 end;
end;

function TpvTrueTypeFont.GetTableDirEntry(Tag:TpvUInt32;var CheckSum,Offset,Size:TpvUInt32):TpvInt32;
var i:TpvInt32;
    Position,CurrentTag:TpvUInt32;
    Found:boolean;
begin
 Position:=pvTTF_OFFSET_TABLE_SIZE;
 Found:=false;
 for i:=0 to fNumTables-1 do begin
  CurrentTag:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
  if CurrentTag=Tag then begin
   CheckSum:=ToLONGWORD(fFontData[Position+4],fFontData[Position+5],fFontData[Position+6],fFontData[Position+7]);
   Offset:=ToLONGWORD(fFontData[Position+8],fFontData[Position+9],fFontData[Position+10],fFontData[Position+11]);
   Size:=ToLONGWORD(fFontData[Position+12],fFontData[Position+13],fFontData[Position+14],fFontData[Position+15]);
   Found:=true;
   break;
  end;
  inc(Position,16);
 end;
 if Found then begin
  result:=pvTTF_TT_ERR_NoError;
 end else begin
  result:=pvTTF_TT_ERR_TableNotFound;
 end;
end;

function TpvTrueTypeFont.LoadOS2:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,Version:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('O'),TpvUInt8('S'),TpvUInt8('/'),TpvUInt8('2'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;
  Version:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  if Version<6 then begin
   inc(Position,sizeof(TpvUInt16)); // avg char width
   inc(Position,sizeof(TpvUInt16)); // weight class
   inc(Position,sizeof(TpvUInt16)); // width class
   inc(Position,sizeof(TpvUInt16)); // fs type
   inc(Position,sizeof(TpvUInt16)); // subscript x size
   inc(Position,sizeof(TpvUInt16)); // subscript y size
   inc(Position,sizeof(TpvUInt16)); // subscript x offset
   inc(Position,sizeof(TpvUInt16)); // subscript y offset
   inc(Position,sizeof(TpvUInt16)); // superscript x size
   inc(Position,sizeof(TpvUInt16)); // superscript y size
   inc(Position,sizeof(TpvUInt16)); // superscript x offset
   inc(Position,sizeof(TpvUInt16)); // superscript y offset
   inc(Position,sizeof(TpvUInt16)); // strikeout size
   inc(Position,sizeof(TpvUInt16)); // strikeout offset
   inc(Position,sizeof(TpvUInt16)); // family class
   inc(Position,10); // panose
   inc(Position,sizeof(TpvUInt32)); // unicode range 1
   inc(Position,sizeof(TpvUInt32)); // unicode range 2
   inc(Position,sizeof(TpvUInt32)); // unicode range 3
   inc(Position,sizeof(TpvUInt32)); // unicode range 4
   inc(Position,sizeof(TpvUInt16)); // fs selection
   inc(Position,sizeof(TpvUInt16)); // first char index
   inc(Position,sizeof(TpvUInt16)); // last char index
   fOS2Ascender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16)); // typo ascender
   fOS2Descender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16)); // typo descender
   fOS2LineGap:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16)); // typo line gap
   inc(Position,sizeof(TpvUInt16)); // win ascent
   inc(Position,sizeof(TpvUInt16)); // win descent
   if Version>0 then begin
    inc(Position,sizeof(TpvUInt32)); // ulCodePageRange1
    inc(Position,sizeof(TpvUInt32)); // ulCodePageRange2
    if Version>1 then begin
     inc(Position,sizeof(TpvUInt16)); // x height
     inc(Position,sizeof(TpvUInt16)); // cap height
     inc(Position,sizeof(TpvUInt16)); // default char
     inc(Position,sizeof(TpvUInt16)); // break char
     inc(Position,sizeof(TpvUInt16)); // max context
    end;
   end;
   if Position<>0 then begin
   end;
   result:=pvTTF_TT_ERR_NoError;
  end else begin
   result:=pvTTF_TT_ERR_InvalidFile;
  end;
 end;
end;

function TpvTrueTypeFont.LoadHEAD:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,MagicNumber:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('h'),TpvUInt8('e'),TpvUInt8('a'),TpvUInt8('d'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;
  inc(Position,sizeof(TpvUInt32)); // Table version number
  inc(Position,sizeof(TpvUInt32)); // Font revision number
  inc(Position,sizeof(TpvUInt32)); // CheckSum adjustment
  MagicNumber:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
  inc(Position,sizeof(TpvUInt32)); // Magic number
  if MagicNumber<>$5f0f3cf5 then begin
   result:=pvTTF_TT_ERR_InvalidFile;
   exit;
  end;
  inc(Position,sizeof(TpvUInt16)); // Flags
  fUnitsPerEm:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  inc(Position,8); // Date created
  inc(Position,8); // Date modified
  fMinX:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fMinY:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fMaxX:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fMaxY:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  inc(Position,sizeof(TpvUInt16)); // Mac-style
  inc(Position,sizeof(TpvUInt16)); // Lowest rec pen
  inc(Position,sizeof(TpvInt16)); // Font direction hint
  fIndexToLocationFormat:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
//inc(Position,sizeof(TpvInt16));
  if fUnitsPerEm=0 then begin
   fUnitsPerEm:=1;
  end;
//fUnitsPerPixel:=fMaxY-fMinY;
  fUnitsPerPixel:=SARLongint(fUnitsPerEm,1);
  if fUnitsPerPixel=0 then begin
   fUnitsPerPixel:=1;
  end;
  fThinBoldStrength:=SARLongint(fUnitsPerEm,4);
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadMAXP:TpvInt32;
var Tag,CheckSum,Offset,Size:TpvUInt32;
    i:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('m'),TpvUInt8('a'),TpvUInt8('x'),TpvUInt8('p'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  fCountGlyphs:=ToWORD(fFontData[Offset+4],fFontData[Offset+5]);
  fMaxTwilightPoints:=ToWORD(fFontData[Offset+16],fFontData[Offset+17]);
  fMaxStorage:=ToWORD(fFontData[Offset+18],fFontData[Offset+19]);
  fMaxFunctionDefs:=ToWORD(fFontData[Offset+20],fFontData[Offset+21]);
  fMaxStackElements:=ToWORD(fFontData[Offset+24],fFontData[Offset+25]);
  SetLength(fGlyphs,fCountGlyphs);
  if length(fGlyphs)<>fCountGlyphs then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;
  for i:=0 to fCountGlyphs-1 do begin
   FillChar(fGlyphs[i],sizeof(TpvTrueTypeFontGlyph),#0);
  end;
  SetLength(fGlyphLoadedBitmap,(fCountGlyphs+31) shr 3);
  if length(fGlyphLoadedBitmap)<>((fCountGlyphs+31) shr 3) then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;
  for i:=0 to length(fGlyphLoadedBitmap)-1 do begin
   fGlyphLoadedBitmap[i]:=0;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadNAME:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,NumNameRecords,StringStorageOffset,i,j,c,c2,o:TpvUInt32;
    ThisPlatformID,ThisSpecificID,ThisLanguageID,ThisNameID,ThisStringLength,ThisStringOffset:TpvUInt16;
    NameFound:boolean;
    u8s:PpvRawByteString;
    s:TpvRawByteString;
    si,sl:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('n'),TpvUInt8('a'),TpvUInt8('m'),TpvUInt8('e'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;
  inc(Position,sizeof(TpvUInt16)); // Format Selector
  NumNameRecords:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  StringStorageOffset:=ToWORD(fFontData[Position],fFontData[Position+1])+Offset;
  inc(Position,sizeof(TpvUInt16));
  for i:=1 to NumNameRecords do begin
   ThisPlatformID:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   ThisSpecificID:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   ThisLanguageID:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   ThisNameID:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   ThisStringLength:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   ThisStringOffset:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   if (ThisPlatformID=fPlatformID) and (ThisSpecificID=fSpecificID) and (ThisLanguageID=fLanguageID) then begin
    NameFound:=false;
    u8s:=nil;
    case ThisNameID of
     pvTTF_NID_Copyright:begin
      NameFound:=true;
      u8s:=@fStringCopyright;
     end;
     pvTTF_NID_Family:begin
      NameFound:=true;
      u8s:=@fStringFamily;
     end;
     pvTTF_NID_Subfamily:begin
      NameFound:=true;
      u8s:=@fStringSubFamily;
     end;
     pvTTF_NID_UniqueID:begin
      NameFound:=true;
      u8s:=@fStringUniqueID;
     end;
     pvTTF_NID_FullName:begin
      NameFound:=true;
      u8s:=@fStringFullName;
     end;
     pvTTF_NID_Version:begin
      NameFound:=true;
      u8s:=@fStringVersion;
     end;
     pvTTF_NID_PostscriptName:begin
      NameFound:=true;
      u8s:=@fStringPostScript;
     end;
     pvTTF_NID_Trademark:begin
      NameFound:=true;
      u8s:=@fStringTrademark;
     end;
    end;
    if NameFound then begin
     case ThisPlatformID of
      pvTTF_PID_Microsoft:begin
       s:='';
       SetLength(s,ThisStringLength*2);
       if length(s)<>(ThisStringLength*2) then begin
        result:=pvTTF_TT_ERR_OutOfMemory;
        exit;
       end;
       j:=0;
       o:=StringStorageOffset+ThisStringOffset;
       si:=0;
       while j<ThisStringLength do begin
        c:=ToWORD(fFontData[o],fFontData[o+1]);
        inc(j,2);
        inc(o,2);
        if ((c and $fc00)=$d800) and (j<ThisStringLength) then begin
         c2:=ToWORD(fFontData[o],fFontData[o+1]);
         if (c2 and $fc00)=$dc00 then begin
          c:=(((c and $3ff) shl 10) or (c2 and $3ff))+$10000;
          inc(j,2);
          inc(o,2);
         end;
        end;
        sl:=PUCUUTF32CharToUTF8At(c,s,si+1);
        inc(si,sl);
       end;
       SetLength(s,si);
       u8s^:=s;
       s:='';
      end;
      else begin
       s:='';
       SetLength(s,ThisStringLength);
       if length(s)<>ThisStringLength then begin
        result:=pvTTF_TT_ERR_OutOfMemory;
        exit;
       end;
       Move(fFontData[StringStorageOffset+ThisStringOffset],s[1],ThisStringLength);
       u8s^:=PUCUUTF8Correct(s);
       s:='';
      end;
     end;
    end;
   end;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadCFF:TpvInt32;
const CFFScaleFactor=4.0;
      TopDictVersionOp=0;
      TopDictNoticeOp=1;
      TopDictFullNameOp=2;
      TopDictFamilyNameOp=3;
      TopDictWeightOp=4;
      TopDictFontBBoxOp=5;
      TopDictUniqueIdOp=13;
      TopDictXuidOp=14;
      TopDictCharsetOp=15;
      TopDictEncodingOp=16;
      TopDictCharStringsOp=17;
      TopDictPrivateOp=18;
      TopDictCopyrightOp=1200;
      TopDictIsFixedPitchOp=1201;
      TopDictItalicAngleOp=1202;
      TopDictUnderlinePositionOp=1203;
      TopDictUnderlineThicknessOp=1204;
      TopDictPaintTypeOp=1205;
      TopDictCharstringTypeOp=1206;
      TopDictFontMatrixOp=1207;
      TopDictStrokeWidthOp=1208;
      PrivateDictSubRoutineOp=19;
      PrivateDictDefaultWidthXOp=20;
      PrivateDictNominalWidthXOp=21;
      CFFStandardStrings:array[0..390] of TpvRawByteString=
       (
        '.notdef','space','exclam','quotedbl','numbersign','dollar','percent','ampersand','quoteright',
        'parenleft','parenright','asterisk','plus','comma','hyphen','period','slash','zero','one','two',
        'three','four','five','six','seven','eight','nine','colon','semicolon','less','equal','greater',
        'question','at','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S',
        'T','U','V','W','X','Y','Z','bracketleft','backslash','bracketright','asciicircum','underscore',
        'quoteleft','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
        'u','v','w','x','y','z','braceleft','bar','braceright','asciitilde','exclamdown','cent','sterling',
        'fraction','yen','florin','section','currency','quotesingle','quotedblleft','guillemotleft',
        'guilsinglleft','guilsinglright','fi','fl','endash','dagger','daggerdbl','periodcentered','paragraph',
        'bullet','quotesinglbase','quotedblbase','quotedblright','guillemotright','ellipsis','perthousand',
        'questiondown','grave','acute','circumflex','tilde','macron','breve','dotaccent','dieresis','ring',
        'cedilla','hungarumlaut','ogonek','caron','emdash','AE','ordfeminine','Lslash','Oslash','OE',
        'ordmasculine','ae','dotlessi','lslash','oslash','oe','germandbls','onesuperior','logicalnot','mu',
        'trademark','Eth','onehalf','plusminus','Thorn','onequarter','divide','brokenbar','degree','thorn',
        'threequarters','twosuperior','registered','minus','eth','multiply','threesuperior','copyright',
        'Aacute','Acircumflex','Adieresis','Agrave','Aring','Atilde','Ccedilla','Eacute','Ecircumflex',
        'Edieresis','Egrave','Iacute','Icircumflex','Idieresis','Igrave','Ntilde','Oacute','Ocircumflex',
        'Odieresis','Ograve','Otilde','Scaron','Uacute','Ucircumflex','Udieresis','Ugrave','Yacute',
        'Ydieresis','Zcaron','aacute','acircumflex','adieresis','agrave','aring','atilde','ccedilla','eacute',
        'ecircumflex','edieresis','egrave','iacute','icircumflex','idieresis','igrave','ntilde','oacute',
        'ocircumflex','odieresis','ograve','otilde','scaron','uacute','ucircumflex','udieresis','ugrave',
        'yacute','ydieresis','zcaron','exclamsmall','Hungarumlautsmall','dollaroldstyle','dollarsuperior',
        'ampersandsmall','Acutesmall','parenleftsuperior','parenrightsuperior','266 ff','onedotenleader',
        'zerooldstyle','oneoldstyle','twooldstyle','threeoldstyle','fouroldstyle','fiveoldstyle','sixoldstyle',
        'sevenoldstyle','eightoldstyle','nineoldstyle','commasuperior','threequartersemdash','periodsuperior',
        'questionsmall','asuperior','bsuperior','centsuperior','dsuperior','esuperior','isuperior','lsuperior',
        'msuperior','nsuperior','osuperior','rsuperior','ssuperior','tsuperior','ff','ffi','ffl',
        'parenleftinferior','parenrightinferior','Circumflexsmall','hyphensuperior','Gravesmall','Asmall',
        'Bsmall','Csmall','Dsmall','Esmall','Fsmall','Gsmall','Hsmall','Ismall','Jsmall','Ksmall','Lsmall',
        'Msmall','Nsmall','Osmall','Psmall','Qsmall','Rsmall','Ssmall','Tsmall','Usmall','Vsmall','Wsmall',
        'Xsmall','Ysmall','Zsmall','colonmonetary','onefitted','rupiah','Tildesmall','exclamdownsmall',
        'centoldstyle','Lslashsmall','Scaronsmall','Zcaronsmall','Dieresissmall','Brevesmall','Caronsmall',
        'Dotaccentsmall','Macronsmall','figuredash','hypheninferior','Ogoneksmall','Ringsmall','Cedillasmall',
        'questiondownsmall','oneeighth','threeeighths','fiveeighths','seveneighths','onethird','twothirds',
        'zerosuperior','foursuperior','fivesuperior','sixsuperior','sevensuperior','eightsuperior','ninesuperior',
        'zeroinferior','oneinferior','twoinferior','threeinferior','fourinferior','fiveinferior','sixinferior',
        'seveninferior','eightinferior','nineinferior','centinferior','dollarinferior','periodinferior',
        'commainferior','Agravesmall','Aacutesmall','Acircumflexsmall','Atildesmall','Adieresissmall',
        'Aringsmall','AEsmall','Ccedillasmall','Egravesmall','Eacutesmall','Ecircumflexsmall','Edieresissmall',
        'Igravesmall','Iacutesmall','Icircumflexsmall','Idieresissmall','Ethsmall','Ntildesmall','Ogravesmall',
        'Oacutesmall','Ocircumflexsmall','Otildesmall','Odieresissmall','OEsmall','Oslashsmall','Ugravesmall',
        'Uacutesmall','Ucircumflexsmall','Udieresissmall','Yacutesmall','Thornsmall','Ydieresissmall','001.000',
        '001.001','001.002','001.003','Black','Bold','Book','Light','Medium','Regular','Roman','Semibold'
       );
      CFFStandardEncoding:array[0..251] of TpvRawByteString=
       (
        '','','','','','','','','','','','','','','','','','','','','','','','','','','','',
        '','','','','space','exclam','quotedbl','numbersign','dollar','percent','ampersand','quoteright',
        'parenleft','parenright','asterisk','plus','comma','hyphen','period','slash','zero','one','two',
        'three','four','five','six','seven','eight','nine','colon','semicolon','less','equal','greater',
        'question','at','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S',
        'T','U','V','W','X','Y','Z','bracketleft','backslash','bracketright','asciicircum','underscore',
        'quoteleft','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
        'u','v','w','x','y','z','braceleft','bar','braceright','asciitilde','','','','','','','','',
        '','','','','','','','','','','','','','','','','','','','','','','','','','',
        'exclamdown','cent','sterling','fraction','yen','florin','section','currency','quotesingle',
        'quotedblleft','guillemotleft','guilsinglleft','guilsinglright','fi','fl','','endash','dagger',
        'daggerdbl','periodcentered','','paragraph','bullet','quotesinglbase','quotedblbase','quotedblright',
        'guillemotright','ellipsis','perthousand','','questiondown','','grave','acute','circumflex','tilde',
        'macron','breve','dotaccent','dieresis','','ring','cedilla','','hungarumlaut','ogonek','caron',
        'emdash','','','','','','','','','','','','','','','','','AE','','ordfeminine','','','',
        '','Lslash','Oslash','OE','ordmasculine','','','','','','ae','','','','dotlessi','','',
        'lslash','oslash','oe','germandbls'
       );
      CFFExpertEncoding:array[0..254] of TpvRawByteString=
       (
        '','','','','','','','','','','','','','','','','','','','','','','','','','','','',
        '','','','','space','exclamsmall','Hungarumlautsmall','','dollaroldstyle','dollarsuperior',
        'ampersandsmall','Acutesmall','parenleftsuperior','parenrightsuperior','twodotenleader','onedotenleader',
        'comma','hyphen','period','fraction','zerooldstyle','oneoldstyle','twooldstyle','threeoldstyle',
        'fouroldstyle','fiveoldstyle','sixoldstyle','sevenoldstyle','eightoldstyle','nineoldstyle','colon',
        'semicolon','commasuperior','threequartersemdash','periodsuperior','questionsmall','','asuperior',
        'bsuperior','centsuperior','dsuperior','esuperior','','','isuperior','','','lsuperior','msuperior',
        'nsuperior','osuperior','','','rsuperior','ssuperior','tsuperior','','ff','fi','fl','ffi','ffl',
        'parenleftinferior','','parenrightinferior','Circumflexsmall','hyphensuperior','Gravesmall','Asmall',
        'Bsmall','Csmall','Dsmall','Esmall','Fsmall','Gsmall','Hsmall','Ismall','Jsmall','Ksmall','Lsmall',
        'Msmall','Nsmall','Osmall','Psmall','Qsmall','Rsmall','Ssmall','Tsmall','Usmall','Vsmall','Wsmall',
        'Xsmall','Ysmall','Zsmall','colonmonetary','onefitted','rupiah','Tildesmall','','','','','','','',
        '','','','','','','','','','','','','','','','','','','','','','','','','','','',
        'exclamdownsmall','centoldstyle','Lslashsmall','','','Scaronsmall','Zcaronsmall','Dieresissmall',
        'Brevesmall','Caronsmall','','Dotaccentsmall','','','Macronsmall','','','figuredash','hypheninferior',
        '','','Ogoneksmall','Ringsmall','Cedillasmall','','','','onequarter','onehalf','threequarters',
        'questiondownsmall','oneeighth','threeeighths','fiveeighths','seveneighths','onethird','twothirds','',
        '','zerosuperior','onesuperior','twosuperior','threesuperior','foursuperior','fivesuperior',
        'sixsuperior','sevensuperior','eightsuperior','ninesuperior','zeroinferior','oneinferior','twoinferior',
        'threeinferior','fourinferior','fiveinferior','sixinferior','seveninferior','eightinferior',
        'nineinferior','centinferior','dollarinferior','periodinferior','commainferior','Agravesmall',
        'Aacutesmall','Acircumflexsmall','Atildesmall','Adieresissmall','Aringsmall','AEsmall','Ccedillasmall',
        'Egravesmall','Eacutesmall','Ecircumflexsmall','Edieresissmall','Igravesmall','Iacutesmall',
        'Icircumflexsmall','Idieresissmall','Ethsmall','Ntildesmall','Ogravesmall','Oacutesmall',
        'Ocircumflexsmall','Otildesmall','Odieresissmall','OEsmall','Oslashsmall','Ugravesmall','Uacutesmall',
        'Ucircumflexsmall','Udieresissmall','Yacutesmall','Thornsmall','Ydieresissmall'
           );
type PIndexDataItem=^TIndexDataItem;
     TIndexDataItem=record
      Position:TpvInt32;
      Size:TpvInt32;
     end;
     TIndexData=array of TIndexDataItem;
     PNumberKind=^TNumberKind;
     TNumberKind=
      (
       FLOAT,
       INT
      );
     PNumber=^TNumber;
     TNumber=record
      case Kind:TNumberKind of
       TNumberKind.FLOAT:(
        FloatValue:TpvDouble;
       );
       TNumberKind.INT:(
        IntegerValue:TpvInt64;
       );
     end;
     TNumberArray=array of TNumber;
     PDictEntry=^TDictEntry;
     TDictEntry=record
      Op:TpvInt32;
      Operands:TNumberArray;
     end;
     TDictEntryArray=array of TDictEntry;
     TStringIntegerHashMap=TpvStringHashMap<TpvInt32>;
var Position,Tag,CheckSum,Offset,Size,EndOffset:TpvUInt32;
    HeaderFormatMajor,HeaderFormatMinor,HeaderSize,HeaderOffsetSize,
    HeaderStartOffset,HeaderEndOffset,i,j,Count,UntilExcludingPosition,
    TopDictCharStringType,TopDictCharset,TopDictEncoding,TopDictCharStrings,
    PrivateDictSubRoutine,PrivateDictDefaultWidthX,PrivateDictNominalWidthX,
    CharsetFormat,SID,EncodingFormat,CountCodes,Code,CountRanges,First,
    CountSubCodes:TpvInt32;
    TopDictFontBBox:array[0..3] of TpvInt32;
    TopDictPrivate:array[0..1] of TpvInt32;
    TopDictFontMatrix:array[0..5] of TpvDouble;
    NameIndexData,TopDictIndexData,StringIndexData,
    GlobalSubroutineIndexData,SubroutineIndexData,
    TopDictCharStringsIndexData:TIndexData;
    DictEntry:PDictEntry;
    StringTable,CharsetTable,EncodingTable:array of TpvRawByteString;
    CurrentRawByteString:TpvRawByteString;
    CharsetTableHashMap:TStringIntegerHashMap;
    CFFGlobalSubroutineBias:TpvInt32;
    CFFSubroutineBias:TpvInt32;
 function GetCFFSubroutineBias(const SubroutineIndexData:TIndexData):TpvInt32;
 begin
  // http://download.microsoft.com/download/8/0/1/801a191c-029d-4af3-9642-555f6fe514ee/type2.pdf
  // Chapter 4.7 "Subroutine operators"
  case length(SubroutineIndexData) of
   0..1239:begin
    result:=107;
   end;
   1240..33899:begin
    result:=1131;
   end;
   else begin
    result:=32768;
   end;
  end;
 end;
 function LoadIndex(out IndexData:TIndexData):TpvInt32;
 var BaseOffset,Count,OffsetSize,OffsetValue,i,j:TpvInt32;
     IndexDataItem:PIndexDataItem;
 begin

  IndexData:=nil;

  BaseOffset:=Position;

  if ((Position+SizeOf(TpvUInt16))-1)>=(Offset+Size) then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;
  Count:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,SizeOf(TpvUInt16));

  if Count>0 then begin

   if ((Position+SizeOf(TpvUInt8))-1)>=(Offset+Size) then begin
    result:=pvTTF_TT_ERR_CorruptFile;
    exit;
   end;
   OffsetSize:=fFontData[Position];
   inc(Position,SizeOf(TpvUInt8));

   SetLength(IndexData,Count+1);
   try
    for i:=0 to Count do begin
     OffsetValue:=0;
     for j:=0 to OffsetSize-1 do begin
      if ((Position+SizeOf(TpvUInt8))-1)>=(Offset+Size) then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      OffsetValue:=(OffsetValue shl 8) or fFontData[Position];
      inc(Position,SizeOf(TpvUInt8));
     end;
     IndexDataItem:=@IndexData[i];
     IndexDataItem^.Position:=OffsetValue;
    end;
    for i:=0 to Count-1 do begin
     IndexDataItem:=@IndexData[i];
     IndexDataItem^.Size:=IndexData[i+1].Position-IndexDataItem^.Position;
    end;
    for i:=0 to Count do begin
     inc(IndexData[i].Position,Position-1);
    end;
    Position:=IndexData[Count].Position;
   finally
    SetLength(IndexData,Count);
   end;

  end;

  result:=pvTTF_TT_ERR_NoError;

 end;
 function LoadDict(const DictPosition,DictSize:TpvInt32;out DictEntryArray:TDictEntryArray):TpvInt32;
 const FloatStrings:array[0..15] of string=('0','1','2','3','4','5','6','7','8','9','.','e','e-','','-','');
 var Position,UntilExcludingPosition,Op,CountOperands,CountDictEntries,Value,Code:TpvInt32;
     Operands:TNumberArray;
     DictEntry:PDictEntry;
     FloatString:string;
 begin

  Position:=DictPosition;
  UntilExcludingPosition:=DictPosition+DictSize;

  CountDictEntries:=0;

  DictEntryArray:=nil;
  try

   Operands:=nil;
   try

    CountOperands:=0;

    while Position<UntilExcludingPosition do begin

     if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
      result:=pvTTF_TT_ERR_CorruptFile;
      exit;
     end;
     Op:=fFontData[Position];
     inc(Position,SizeOf(TpvUInt8));

     case Op of
      12:begin
       SetLength(Operands,CountOperands);
       if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       Op:=1200+fFontData[Position];
       inc(Position,SizeOf(TpvUInt8));
       if length(DictEntryArray)<(CountDictEntries+1) then begin
        SetLength(DictEntryArray,(CountDictEntries+1)*2);
       end;
       DictEntry:=@DictEntryArray[CountDictEntries];
       inc(CountDictEntries);
       DictEntry^.Op:=Op;
       DictEntry^.Operands:=Operands;
       Operands:=nil;
       CountOperands:=0;
      end;
      0..11,13..21:begin
       SetLength(Operands,CountOperands);
       if length(DictEntryArray)<(CountDictEntries+1) then begin
        SetLength(DictEntryArray,(CountDictEntries+1)*2);
       end;
       DictEntry:=@DictEntryArray[CountDictEntries];
       inc(CountDictEntries);
       DictEntry^.Op:=Op;
       DictEntry^.Operands:=Operands;
       Operands:=nil;
       CountOperands:=0;
      end;
      28:begin
       if ((Position+SizeOf(TpvUInt16))-1)>=UntilExcludingPosition then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.INT;
       Operands[CountOperands].IntegerValue:=ToWORD(fFontData[Position],fFontData[Position+1]);
       inc(CountOperands);
       inc(Position,SizeOf(TpvUInt16));
      end;
      29:begin
       if ((Position+SizeOf(TpvUInt32))-1)>=UntilExcludingPosition then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.INT;
       Operands[CountOperands].IntegerValue:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
       inc(CountOperands);
       inc(Position,SizeOf(TpvUInt32));
      end;
      30:begin
       FloatString:='';
       repeat
        if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        Value:=fFontData[Position];
        inc(Position,SizeOf(TpvUInt8));
        if (Value and $f0)=$f0 then begin
         break;
        end else begin
         FloatString:=FloatString+FloatStrings[Value shr 4];
         if (Value and $0f)=$0f then begin
          break;
         end else begin
          FloatString:=FloatString+FloatStrings[Value and $f];
         end;
        end;
       until false;
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.FLOAT;
       Val(FloatString,Operands[CountOperands].FloatValue,Code);
       inc(CountOperands);
      end;
      32..246:begin
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.INT;
       Operands[CountOperands].IntegerValue:=Op-139;
       inc(CountOperands);
      end;
      247..250:begin
       if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.INT;
       Operands[CountOperands].IntegerValue:=(((Op-247) shl 8)+fFontData[Position])+108;
       inc(CountOperands);
       inc(Position,SizeOf(TpvUInt8));
      end;
      251..254:begin
       if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       if length(Operands)<(CountOperands+1) then begin
        SetLength(Operands,(CountOperands+1)*2);
       end;
       Operands[CountOperands].Kind:=TNumberKind.INT;
       Operands[CountOperands].IntegerValue:=((-((Op-251)*256))-fFontData[Position])-108;
       inc(CountOperands);
       inc(Position,SizeOf(TpvUInt8));
      end;
      else begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
     end;

    end;

   finally
    Operands:=nil;
   end;

  finally
   SetLength(DictEntryArray,CountDictEntries);
  end;

  result:=pvTTF_TT_ERR_NoError;

 end;
{function ConvertDict(const DictEntryArray:TDictEntryArray;var Dict:TDict):TpvInt32;
 var i,j:TpvInt32;
     DictEntry:PDictEntry;
 begin
  for i:=0 to length(DictEntryArray)-1 do begin
   DictEntry:=@DictEntryArray[i];
   if (DictEntry^.Op>=Low(TDict)) and (DictEntry^.Op<=High(TDict)) then begin
    if length(DictEntry^.Operands)<length(Dict[DictEntry^.Op]) then begin
     for j:=0 to length(DictEntry^.Operands)-1 do begin
      Dict[DictEntry^.Op,j]:=DictEntry^.Operands[j];
     end;
    end else begin
     Dict[DictEntry^.Op]:=copy(DictEntry^.Operands);
    end;
   end else begin
    result:=pvTTF_TT_ERR_CorruptFile;
    exit;
   end;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;}
 function GetCFFString(const SID:TpvInt32):TpvRawByteString;
 begin
  case SID of
   0..390:begin
    result:=CFFStandardStrings[SID];
   end;
   else begin
    result:=StringTable[SID-391];
   end;
  end;
 end;
 function LoadCFFGlyph(var Glyph:TpvTrueTypeFontGlyph;const GlyphPosition,GlyphSize:TpvInt32):TpvInt32;
 type TStack=array of TpvDouble;
 var i,v,StackSize,CountStems:TpvInt32;
     Width,x,y,c0x,c0y,c1x,c1y,GlyphMinX,GlyphMinY,GlyphMaxX,GlyphMaxY:TpvDouble;
     Stack:TStack;
     HaveWidth:boolean;
  function StackShift:TpvDouble;
  begin
   if StackSize>0 then begin
    result:=Stack[0];
    dec(StackSize);
    if StackSize>0 then begin
     Move(Stack[1],Stack[0],StackSize*SizeOf(TpvDouble));
    end;
   end else begin
    result:=0;
   end;
  end;
  function StackPop:TpvDouble;
  begin
   if StackSize>0 then begin
    dec(StackSize);
    result:=Stack[StackSize];
   end else begin
    result:=0;
   end;
  end;
  procedure StackPush(const Value:TpvDouble);
  begin
   if length(Stack)<(StackSize+1) then begin
    SetLength(Stack,(StackSize+1)*2);
   end;
   Stack[StackSize]:=Value;
   inc(StackSize);
  end;
  procedure ParseStems;
  var HasWidthArgument:boolean;
  begin
   HasWidthArgument:=(StackSize and 1)<>0;
   if HasWidthArgument and not HaveWidth then begin
    Width:=StackShift+PrivateDictNominalWidthX;
   end;
   inc(CountStems,StackSize shr 1);
   StackSize:=0;
   HaveWidth:=true;
  end;
  procedure MoveTo(aX,aY:TpvDouble);
  var CommandIndex:TpvInt32;
      Command:PpvTrueTypeFontPolygonCommand;
  begin
   aY:=fMaxY-aY;
   CommandIndex:=Glyph.PostScriptPolygon.CountCommands;
   inc(Glyph.PostScriptPolygon.CountCommands);
   if length(Glyph.PostScriptPolygon.Commands)<Glyph.PostScriptPolygon.CountCommands then begin
    SetLength(Glyph.PostScriptPolygon.Commands,Glyph.PostScriptPolygon.CountCommands*2);
   end;
   Command:=@Glyph.PostScriptPolygon.Commands[CommandIndex];
   Command^.CommandType:=TpvTrueTypeFontPolygonCommandType.MoveTo;
   Command^.Points[0].x:=aX*CFFScaleFactor;
   Command^.Points[0].y:=aY*CFFScaleFactor;
   GlyphMinX:=Min(GlyphMinX,aX);
   GlyphMinY:=Min(GlyphMinY,aY);
   GlyphMaxX:=Max(GlyphMaxX,aX);
   GlyphMaxY:=Max(GlyphMaxY,aY);
  end;
  procedure LineTo(aX,aY:TpvDouble);
  var CommandIndex:TpvInt32;
      Command:PpvTrueTypeFontPolygonCommand;
  begin
   aY:=fMaxY-aY;
   CommandIndex:=Glyph.PostScriptPolygon.CountCommands;
   inc(Glyph.PostScriptPolygon.CountCommands);
   if length(Glyph.PostScriptPolygon.Commands)<Glyph.PostScriptPolygon.CountCommands then begin
    SetLength(Glyph.PostScriptPolygon.Commands,Glyph.PostScriptPolygon.CountCommands*2);
   end;
   Command:=@Glyph.PostScriptPolygon.Commands[CommandIndex];
   Command^.CommandType:=TpvTrueTypeFontPolygonCommandType.LineTo;
   Command^.Points[0].x:=aX*CFFScaleFactor;
   Command^.Points[0].y:=aY*CFFScaleFactor;
   GlyphMinX:=Min(GlyphMinX,aX);
   GlyphMinY:=Min(GlyphMinY,aY);
   GlyphMaxX:=Max(GlyphMaxX,aX);
   GlyphMaxY:=Max(GlyphMaxY,aY);
  end;
  procedure CubicCurveTo(aC0X,aC0Y,aC1X,aC1Y,aAX,aAY:TpvDouble);
  var CommandIndex:TpvInt32;
      Command:PpvTrueTypeFontPolygonCommand;
  begin
   aC0Y:=fMaxY-aC0Y;
   aC1Y:=fMaxY-aC1Y;
   aAY:=fMaxY-aAY;
   CommandIndex:=Glyph.PostScriptPolygon.CountCommands;
   inc(Glyph.PostScriptPolygon.CountCommands);
   if length(Glyph.PostScriptPolygon.Commands)<Glyph.PostScriptPolygon.CountCommands then begin
    SetLength(Glyph.PostScriptPolygon.Commands,Glyph.PostScriptPolygon.CountCommands*2);
   end;
   Command:=@Glyph.PostScriptPolygon.Commands[CommandIndex];
   Command^.CommandType:=TpvTrueTypeFontPolygonCommandType.CubicCurveTo;
   Command^.Points[0].x:=aC0X*CFFScaleFactor;
   Command^.Points[0].y:=aC0Y*CFFScaleFactor;
   Command^.Points[1].x:=aC1X*CFFScaleFactor;
   Command^.Points[1].y:=aC1Y*CFFScaleFactor;
   Command^.Points[2].x:=aAX*CFFScaleFactor;
   Command^.Points[2].y:=aAY*CFFScaleFactor;
   GlyphMinX:=Min(GlyphMinX,aC0X);
   GlyphMinY:=Min(GlyphMinY,aC0Y);
   GlyphMaxX:=Max(GlyphMaxX,aC0X);
   GlyphMaxY:=Max(GlyphMaxY,aC0Y);
   GlyphMinX:=Min(GlyphMinX,aC1X);
   GlyphMinY:=Min(GlyphMinY,aC1Y);
   GlyphMaxX:=Max(GlyphMaxX,aC1X);
   GlyphMaxY:=Max(GlyphMaxY,aC1Y);
   GlyphMinX:=Min(GlyphMinX,aAX);
   GlyphMinY:=Min(GlyphMinY,aAY);
   GlyphMaxX:=Max(GlyphMaxX,aAX);
   GlyphMaxY:=Max(GlyphMaxY,aAY);
  end;
  procedure ClosePath;
  var CommandIndex:TpvInt32;
      Command:PpvTrueTypeFontPolygonCommand;
  begin
   CommandIndex:=Glyph.PostScriptPolygon.CountCommands;
   inc(Glyph.PostScriptPolygon.CountCommands);
   if length(Glyph.PostScriptPolygon.Commands)<Glyph.PostScriptPolygon.CountCommands then begin
    SetLength(Glyph.PostScriptPolygon.Commands,Glyph.PostScriptPolygon.CountCommands*2);
   end;
   Command:=@Glyph.PostScriptPolygon.Commands[CommandIndex];
   Command^.CommandType:=TpvTrueTypeFontPolygonCommandType.Close;
  end;
  function Execute(const CodePosition,CodeSize:TpvInt32):TpvInt32;
  var Position,UntilExcludingPosition,CodeIndex:TpvInt32;
      dx1,dy1,dx2,dy2,dx3,dy3,dx4,dy4,dx5,dy5,dx6,dy6,dx,dy:TpvDouble;
  begin
   Position:=CodePosition;
   UntilExcludingPosition:=CodePosition+CodeSize;
   while Position<UntilExcludingPosition do begin
    if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    v:=fFontData[Position];
    inc(Position,SizeOf(TpvUInt8));
    case v of
     1:begin
      // hstem
      ParseStems;
     end;
     3:begin
      // vstem
      ParseStems;
     end;
     4:begin
      // vmoveto
      if (StackSize>1) and not HaveWidth then begin
       Width:=StackShift+PrivateDictNominalWidthX;
       HaveWidth:=true;
      end;
      y:=y+StackPop;
      MoveTo(x,y);
     end;
     5:begin
      // rlineto
      while StackSize>0 do begin
       x:=x+StackShift;
       y:=y+StackShift;
       LineTo(x,y);
      end;
     end;
     6:begin
      // hlineto
      while StackSize>0 do begin
       x:=x+StackShift;
       LineTo(x,y);
       if StackSize>0 then begin
        y:=y+StackShift;
        LineTo(x,y);
       end else begin
        break;
       end;
      end;
     end;
     7:begin
      // vlineto
      while StackSize>0 do begin
       y:=y+StackShift;
       LineTo(x,y);
       if StackSize>0 then begin
        x:=x+StackShift;
        LineTo(x,y);
       end else begin
        break;
       end;
      end;
     end;
     8:begin
      // rrcurveto
      while StackSize>0 do begin
       c0x:=x+StackShift;
       c0y:=y+StackShift;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       x:=c1x+StackShift;
       y:=c1y+StackShift;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
      end;
     end;
     10:begin
      // callsubr
      CodeIndex:=trunc(StackPop)+CFFSubroutineBias;
      if SubroutineIndexData[CodeIndex].Size>0 then begin
       result:=Execute(SubroutineIndexData[CodeIndex].Position,SubroutineIndexData[CodeIndex].Size);
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
     end;
     11:begin
      // return
      result:=pvTTF_TT_ERR_NoError;
      exit;
     end;
     12:begin
      // escape
      if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      v:=fFontData[Position];
      inc(Position,SizeOf(TpvUInt8));
      case v of
       34:begin
        // hflex
        dx1:=StackShift;
        dx2:=StackShift;
        dy2:=StackShift;
        dx3:=StackShift;
        dx4:=StackShift;
        dx5:=StackShift;
        dx6:=StackShift;
        c0x:=x+dx1;
        c0y:=y+0.0;
        c1x:=c0x+dx2;
        c1y:=c0y+dy2;
        x:=c1x+dx3;
        y:=c1y+0.0;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
        c0x:=x+dx4;
        c0y:=y+0.0;
        c1x:=c0x+dx5;
        c1y:=c0y-dy2;
        x:=c1x+dx6;
        y:=c1y+0.0;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end;
       35:begin
        // flex
        dx1:=StackShift;
        dy1:=StackShift;
        dx2:=StackShift;
        dy2:=StackShift;
        dx3:=StackShift;
        dy3:=StackShift;
        dx4:=StackShift;
        dy4:=StackShift;
        dx5:=StackShift;
        dy5:=StackShift;
        dx6:=StackShift;
        dy6:=StackShift;
        StackShift;
        c0x:=x+dx1;
        c0y:=y+dy1;
        c1x:=c0x+dx2;
        c1y:=c0y+dy2;
        x:=c1x+dx3;
        y:=c1y+dy3;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
        c0x:=x+dx4;
        c0y:=y+dy4;
        c1x:=c0x+dx5;
        c1y:=c0y+dy5;
        x:=c1x+dx6;
        y:=c1y+dy6;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end;
       36:begin
        // hflex1
        dx1:=StackShift;
        dy1:=StackShift;
        dx2:=StackShift;
        dy2:=StackShift;
        dx3:=StackShift;
        dx4:=StackShift;
        dx5:=StackShift;
        dy5:=StackShift;
        dx6:=StackShift;
        c0x:=x+dx1;
        c0y:=y+dy1;
        c1x:=c0x+dx2;
        c1y:=c0y+dy2;
        x:=c1x+dx3;
        y:=c1y+0.0;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
        c0x:=x+dx4;
        c0y:=y+0.0;
        c1x:=c0x+dx5;
        c1y:=c0y+dy5;
        x:=c1x+dx6;
        y:=c1y-(dy1+dy2+dy5);
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end;
       37:begin
        // flex1
        dx1:=StackShift;
        dy1:=StackShift;
        dx2:=StackShift;
        dy2:=StackShift;
        dx3:=StackShift;
        dy3:=StackShift;
        dx4:=StackShift;
        dy4:=StackShift;
        dx5:=StackShift;
        dy5:=StackShift;
        dx6:=StackShift;
        dy6:=dx6;
        dx:=dx1+dx2+dx3+dx4+dx5;
        dy:=dy1+dy2+dy3+dy4+dy5;
        if abs(dx)<abs(dy) then begin
         dx6:=-dx;
        end else begin
         dy6:=-dy;
        end;
        c0x:=x+dx1;
        c0y:=y+dy1;
        c1x:=c0x+dx2;
        c1y:=c0y+dy2;
        x:=c1x+dx3;
        y:=c1y+dy3;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
        c0x:=x+dx4;
        c0y:=y+dy4;
        c1x:=c0x+dx5;
        c1y:=c0y+dy5;
        x:=c1x+dx6;
        y:=c1y+dy6;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end;
       else begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
      end;
     end;
     14:begin
      // endchar
      if (StackSize>0) and not HaveWidth then begin
       Width:=StackShift+PrivateDictNominalWidthX;
       HaveWidth:=true;
      end;
      ClosePath;
     end;
     18:begin
      // hstemhm
      ParseStems;
     end;
     19:begin
      // hintmask
      ParseStems;
      inc(Position,(CountStems+7) shr 3);
     end;
     20:begin
      // cntrmask
      ParseStems;
      inc(Position,(CountStems+7) shr 3);
     end;
     21:begin
      // rmoveto
      if (StackSize>2) and not HaveWidth then begin
       Width:=StackShift+PrivateDictNominalWidthX;
       HaveWidth:=true;
      end;
      y:=y+StackPop;
      x:=x+StackPop;
      MoveTo(x,y);
     end;
     22:begin
      // hmoveto
      if (StackSize>1) and not HaveWidth then begin
       Width:=StackShift+PrivateDictNominalWidthX;
       HaveWidth:=true;
      end;
      x:=x+StackPop;
      MoveTo(x,y);
     end;
     23:begin
      // vstemhm
      ParseStems;
     end;
     24:begin
      // rcurveline
      while StackSize>2 do begin
       c0x:=x+StackShift;
       c0y:=y+StackShift;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       x:=c1x+StackShift;
       y:=c1y+StackShift;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
      end;
      x:=x+StackShift;
      y:=y+StackShift;
      LineTo(x,y);
     end;
     25:begin
      // rlinecurve
      while StackSize>6 do begin
       x:=x+StackShift;
       y:=y+StackShift;
       LineTo(x,y);
      end;
      c0x:=x+StackShift;
      c0y:=y+StackShift;
      c1x:=c0x+StackShift;
      c1y:=c0y+StackShift;
      x:=c1x+StackShift;
      y:=c1y+StackShift;
      CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
     end;
     26:begin
      // vvcurveto
      if (StackSize and 1)<>0 then begin
       x:=x+StackShift;
      end;
      while StackSize>0 do begin
       c0x:=x;
       c0y:=y+StackShift;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       x:=c1x;
       y:=c1y+StackShift;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
      end;
     end;
     27:begin
      // hhcurveto
      if (StackSize and 1)<>0 then begin
       y:=y+StackShift;
      end;
      while StackSize>0 do begin
       c0x:=x+StackShift;
       c0y:=y;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       x:=c1x+StackShift;
       y:=c1y;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
      end;
     end;
     28:begin
      // smallint
      if ((Position+SizeOf(TpvUInt16))-1)>=UntilExcludingPosition then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      StackPush(ToSMALLINT(fFontData[Position],fFontData[Position+1]));
      inc(Position,SizeOf(TpvUInt16));
     end;
     29:begin
      // callgsubnr
      CodeIndex:=trunc(StackPop)+CFFGlobalSubroutineBias;
      if GlobalSubroutineIndexData[CodeIndex].Size>0 then begin
       result:=Execute(GlobalSubroutineIndexData[CodeIndex].Position,GlobalSubroutineIndexData[CodeIndex].Size);
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
     end;
     30:begin
      // vhcurveto
      while StackSize>0 do begin
       c0x:=x;
       c0y:=y+StackShift;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       x:=c1x+StackShift;
       if StackSize=1 then begin
        y:=c1y+StackShift;
       end else begin
        y:=c1y;
       end;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       if StackSize>0 then begin
        c0x:=x+StackShift;
        c0y:=y;
        c1x:=c0x+StackShift;
        c1y:=c0y+StackShift;
        y:=c1y+StackShift;
        if StackSize=1 then begin
         x:=c1x+StackShift;
        end else begin
         x:=c1x;
        end;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end else begin
        break;
       end;
      end;
     end;
     31:begin
      // hvcurveto
      while StackSize>0 do begin
       c0x:=x+StackShift;
       c0y:=y;
       c1x:=c0x+StackShift;
       c1y:=c0y+StackShift;
       y:=c1y+StackShift;
       if StackSize=1 then begin
        x:=c1x+StackShift;
       end else begin
        x:=c1x;
       end;
       CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       if StackSize>0 then begin
        c0x:=x;
        c0y:=y+StackShift;
        c1x:=c0x+StackShift;
        c1y:=c0y+StackShift;
        x:=c1x+StackShift;
        if StackSize=1 then begin
         y:=c1y+StackShift;
        end else begin
         y:=c1y;
        end;
        CubicCurveTo(c0x,c0y,c1x,c1y,x,y);
       end else begin
        break;
       end;
      end;
     end;
     32..246:begin
      StackPush(v-139);
     end;
     247..250:begin
      if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      StackPush((((v-247) shl 8)+fFontData[Position])+108);
      inc(Position,SizeOf(TpvUInt8));
     end;
     251..254:begin
      if ((Position+SizeOf(TpvUInt8))-1)>=UntilExcludingPosition then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      StackPush(((-((v-251)*256))-fFontData[Position])-108);
      inc(Position,SizeOf(TpvUInt8));
     end;
     255:begin
      if ((Position+SizeOf(TpvUInt32))-1)>=UntilExcludingPosition then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      StackPush(ToLONGINT(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3])/65536.0);
      inc(Position,SizeOf(TpvUInt32));
     end
     else begin
      result:=pvTTF_TT_ERR_CorruptFile;
      exit;
     end;
    end;
   end;
   result:=pvTTF_TT_ERR_NoError;
  end;
 begin
  Stack:=nil;
  try
   StackSize:=0;
   HaveWidth:=false;
   CountStems:=0;
   x:=0.0;
   y:=0.0;
   Width:=PrivateDictDefaultWidthX;
   GlyphMinX:=MaxDouble;
   GlyphMinY:=MaxDouble;
   GlyphMaxX:=-MaxDouble;
   GlyphMaxY:=-MaxDouble;
   FillChar(Glyph,SizeOf(TpvTrueTypeFontGlyph),#0);
   Glyph.PostScriptPolygon.Commands:=nil;
   Glyph.PostScriptPolygon.CountCommands:=0;
   try
    result:=Execute(GlyphPosition,GlyphSize);
   finally
    SetLength(Glyph.PostScriptPolygon.Commands,Glyph.PostScriptPolygon.CountCommands);
   end;
   Glyph.AdvanceWidth:=ceil(Width);
   Glyph.Bounds.XMin:=floor(GlyphMinX);
   Glyph.Bounds.YMin:=floor(GlyphMinY);
   Glyph.Bounds.XMax:=ceil(GlyphMaxX);
   Glyph.Bounds.YMax:=ceil(GlyphMaxY);
  finally
   Stack:=nil;
  end;
 end;
var TopDictEntryArray,PrivateDictEntryArray:TDictEntryArray;
    IndexDataItem:PIndexDataItem;
begin
 Tag:=ToLONGWORD(TpvUInt8('C'),TpvUInt8('F'),TpvUInt8('F'),TpvUInt8(32));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin

  CFFGlobalSubroutineBias:=0;
  CFFSubroutineBias:=0;

  TopDictEntryArray:=nil;
  try

   PrivateDictEntryArray:=nil;
   try

    TopDictCharStringType:=2;
    TopDictCharset:=0;
    TopDictEncoding:=0;
    TopDictCharStrings:=0;
    TopDictFontBBox[0]:=0;
    TopDictFontBBox[1]:=0;
    TopDictFontBBox[2]:=0;
    TopDictFontBBox[3]:=0;
    TopDictPrivate[0]:=0;
    TopDictPrivate[1]:=0;
    TopDictFontMatrix[0]:=1e-3;
    TopDictFontMatrix[1]:=0.0;
    TopDictFontMatrix[2]:=0.0;
    TopDictFontMatrix[3]:=0.0;
    TopDictFontMatrix[4]:=1e-3;
    TopDictFontMatrix[5]:=0.0;

    PrivateDictSubRoutine:=0;
    PrivateDictDefaultWidthX:=0;
    PrivateDictNominalWidthX:=0;

    Position:=Offset;

    EndOffset:=Offset+Size;

    if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    HeaderFormatMajor:=fFontData[Position];
    inc(Position,SizeOf(TpvUInt8));

    if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    HeaderFormatMinor:=fFontData[Position];
    inc(Position,SizeOf(TpvUInt8));

    if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    HeaderSize:=fFontData[Position];
    inc(Position,SizeOf(TpvUInt8));

    if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    HeaderOffsetSize:=fFontData[Position];
    inc(Position,SizeOf(TpvUInt8));

    Position:=Offset+TpvUInt32(HeaderSize);

    result:=LoadIndex(NameIndexData);
    if result<>pvTTF_TT_ERR_NoError then begin
     exit;
    end;
    if length(NameIndexData)>0 then begin
    end;

    result:=LoadIndex(TopDictIndexData);
    if result<>pvTTF_TT_ERR_NoError then begin
     exit;
    end;
    if length(TopDictIndexData)>0 then begin

     result:=LoadDict(TopDictIndexData[0].Position,TopDictIndexData[0].Size,TopDictEntryArray);
     if result<>pvTTF_TT_ERR_NoError then begin
      exit;
     end;

     for i:=0 to length(TopDictEntryArray)-1 do begin
      DictEntry:=@TopDictEntryArray[i];
      case DictEntry^.Op of
       TopDictCharStringTypeOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictCharStringType:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictCharStringType:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       TopDictCharsetOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictCharset:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictCharset:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       TopDictEncodingOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictEncoding:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictEncoding:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       TopDictCharStringsOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictCharStrings:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictCharStrings:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       TopDictFontBBoxOp:begin
        if length(DictEntry^.Operands)<4 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictFontBBox[0]:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictFontBBox[0]:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
        if DictEntry^.Operands[1].Kind=TNumberKind.INT then begin
         TopDictFontBBox[1]:=DictEntry^.Operands[1].IntegerValue;
        end else begin
         TopDictFontBBox[1]:=trunc(DictEntry^.Operands[1].FloatValue);
        end;
        if DictEntry^.Operands[2].Kind=TNumberKind.INT then begin
         TopDictFontBBox[2]:=DictEntry^.Operands[2].IntegerValue;
        end else begin
         TopDictFontBBox[2]:=trunc(DictEntry^.Operands[2].FloatValue);
        end;
        if DictEntry^.Operands[3].Kind=TNumberKind.INT then begin
         TopDictFontBBox[3]:=DictEntry^.Operands[3].IntegerValue;
        end else begin
         TopDictFontBBox[3]:=trunc(DictEntry^.Operands[3].FloatValue);
        end;
        fMinX:=TopDictFontBBox[0];
        fMinY:=TopDictFontBBox[1];
        fMaxX:=TopDictFontBBox[2];
        fMaxY:=TopDictFontBBox[3];
       end;
       TopDictPrivateOp:begin
        if length(DictEntry^.Operands)<2 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         TopDictPrivate[0]:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         TopDictPrivate[0]:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
        if DictEntry^.Operands[1].Kind=TNumberKind.INT then begin
         TopDictPrivate[1]:=DictEntry^.Operands[1].IntegerValue;
        end else begin
         TopDictPrivate[1]:=trunc(DictEntry^.Operands[1].FloatValue);
        end;
       end;
       TopDictFontMatrixOp:begin
        if length(DictEntry^.Operands)<6 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        for j:=0 to 5 do begin
         if DictEntry^.Operands[j].Kind=TNumberKind.INT then begin
          TopDictFontMatrix[j]:=DictEntry^.Operands[j].IntegerValue;
         end else begin
          TopDictFontMatrix[j]:=DictEntry^.Operands[j].FloatValue;
         end;
        end;
       end;
      end;

     end;

    end;

    if (TopDictPrivate[0]>0) and (TopDictPrivate[1]>0) then begin

     result:=LoadDict(TpvInt32(Offset)+TopDictPrivate[1],TopDictPrivate[0],PrivateDictEntryArray);
     if result<>pvTTF_TT_ERR_NoError then begin
      exit;
     end;

     for i:=0 to length(PrivateDictEntryArray)-1 do begin
      DictEntry:=@PrivateDictEntryArray[i];
      case DictEntry^.Op of
       PrivateDictSubRoutineOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         PrivateDictSubRoutine:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         PrivateDictSubRoutine:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       PrivateDictDefaultWidthXOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         PrivateDictDefaultWidthX:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         PrivateDictDefaultWidthX:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
       PrivateDictNominalWidthXOp:begin
        if length(DictEntry^.Operands)<1 then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        if DictEntry^.Operands[0].Kind=TNumberKind.INT then begin
         PrivateDictNominalWidthX:=DictEntry^.Operands[0].IntegerValue;
        end else begin
         PrivateDictNominalWidthX:=trunc(DictEntry^.Operands[0].FloatValue);
        end;
       end;
      end;
     end;

    end else begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;

    StringTable:=nil;
    try

     result:=LoadIndex(StringIndexData);
     if result<>pvTTF_TT_ERR_NoError then begin
      exit;
     end;
     if length(StringIndexData)>0 then begin
      SetLength(StringTable,length(StringIndexData));
      for i:=0 to length(StringIndexData)-1 do begin
       IndexDataItem:=@StringIndexData[i];
       SetLength(CurrentRawByteString,IndexDataItem^.Size);
       if TpvUInt32(IndexDataItem^.Position+(IndexDataItem^.Size-1))<EndOffset then begin
        Move(fFontData[IndexDataItem^.Position],CurrentRawByteString[1],IndexDataItem^.Size);
        StringTable[i]:=CurrentRawByteString;
       end else begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
      end;
     end;

     result:=LoadIndex(GlobalSubroutineIndexData);
     if result<>pvTTF_TT_ERR_NoError then begin
      exit;
     end;
     if length(GlobalSubroutineIndexData)>0 then begin
      for i:=0 to length(GlobalSubroutineIndexData)-1 do begin
       if ((GlobalSubroutineIndexData[i].Position+GlobalSubroutineIndexData[i].Size)-1)>=TpvInt32(EndOffset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
      end;
     end;
     CFFGlobalSubroutineBias:=GetCFFSubroutineBias(GlobalSubroutineIndexData);

     if (TopDictPrivate[0]>0) and (TopDictPrivate[1]>0) and (PrivateDictSubRoutine<>0) then begin
      Position:=TpvInt32(Offset)+TopDictPrivate[1]+PrivateDictSubRoutine;
      result:=LoadIndex(SubroutineIndexData);
      if result<>pvTTF_TT_ERR_NoError then begin
       exit;
      end;
      if length(SubroutineIndexData)>0 then begin
       for i:=0 to length(SubroutineIndexData)-1 do begin
        if ((SubroutineIndexData[i].Position+SubroutineIndexData[i].Size)-1)>=TpvInt32(EndOffset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
       end;
      end;
      CFFSubroutineBias:=GetCFFSubroutineBias(SubroutineIndexData);
     end;

     if TopDictCharStrings>0 then begin
      Position:=TpvInt32(TpvInt32(Offset)+TopDictCharStrings);
      result:=LoadIndex(TopDictCharStringsIndexData);
      if result<>pvTTF_TT_ERR_NoError then begin
       exit;
      end;
      fCountGlyphs:=length(TopDictCharStringsIndexData);
      SetLength(fGlyphs,fCountGlyphs);
      for i:=0 to fCountGlyphs-1 do begin
       result:=LoadCFFGlyph(fGlyphs[i],TopDictCharStringsIndexData[i].Position,TopDictCharStringsIndexData[i].Size);
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
     end else begin
      result:=pvTTF_TT_ERR_CorruptFile;
      exit;
     end;

     CharsetTable:=nil;
     try

      if TopDictCharset>0 then begin
       Position:=TpvInt32(TpvInt32(Offset)+TopDictCharset);
       if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       CharsetFormat:=fFontData[Position];
       inc(Position,SizeOf(TpvUInt8));
       SetLength(CharsetTable,fCountGlyphs);
       CharsetTable[0]:='.notdef';
       case CharsetFormat of
        0:begin
         for i:=0 to fCountGlyphs-2 do begin
          if ((Position+SizeOf(TpvUInt16))-1)>=EndOffset then begin
           result:=pvTTF_TT_ERR_CorruptFile;
           exit;
          end;
          SID:=ToWORD(fFontData[Position],fFontData[Position+1]);
          inc(Position,SizeOf(TpvUInt16));
          CharsetTable[i+1]:=GetCFFString(SID);
         end;
        end;
        1,2:begin
         i:=1;
         while i<fCountGlyphs do begin
          if ((Position+SizeOf(TpvUInt16))-1)>=EndOffset then begin
           result:=pvTTF_TT_ERR_CorruptFile;
           exit;
          end;
          SID:=ToWORD(fFontData[Position],fFontData[Position+1]);
          inc(Position,SizeOf(TpvUInt16));
          if CharsetFormat=1 then begin
           if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
            result:=pvTTF_TT_ERR_CorruptFile;
            exit;
           end;
           Count:=fFontData[Position];
           inc(Position,SizeOf(TpvUInt8));
          end else begin
           if ((Position+SizeOf(TpvUInt16))-1)>=EndOffset then begin
            result:=pvTTF_TT_ERR_CorruptFile;
            exit;
           end;
           Count:=ToWORD(fFontData[Position],fFontData[Position+1]);
           inc(Position,SizeOf(TpvUInt16));
          end;
          if Count=0 then begin
           result:=pvTTF_TT_ERR_CorruptFile;
           exit;
          end else begin
           for j:=1 to Count do begin
            CharsetTable[i]:=GetCFFString(SID);
            inc(i);
           end;
          end;
         end;
        end;
        else begin
         result:=pvTTF_TT_ERR_UnknownCharsetFormat;
         exit;
        end;
       end;
      end else begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;

      EncodingTable:=nil;
      try

       case TopDictEncoding of
        0:begin
         SetLength(EncodingTable,length(CFFStandardEncoding));
         for i:=0 to length(CFFStandardEncoding)-1 do begin
          EncodingTable[i]:=CFFStandardEncoding[i];
         end;
        end;
        1:begin
         SetLength(EncodingTable,length(CFFExpertEncoding));
         for i:=0 to length(CFFExpertEncoding)-1 do begin
          EncodingTable[i]:=CFFExpertEncoding[i];
         end;
        end;
        else begin
         Position:=TpvInt32(TpvInt32(Offset)+TopDictEncoding);
         if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
          result:=pvTTF_TT_ERR_CorruptFile;
          exit;
         end;
         EncodingFormat:=fFontData[Position];
         inc(Position,SizeOf(TpvUInt8));
         case EncodingFormat of
          0:begin
           if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
            result:=pvTTF_TT_ERR_CorruptFile;
            exit;
           end;
           CountCodes:=fFontData[Position];
           inc(Position,SizeOf(TpvUInt8));
           SetLength(EncodingTable,CountCodes);
           for i:=0 to CountCodes-1 do begin
            if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
             result:=pvTTF_TT_ERR_CorruptFile;
             exit;
            end;
            Code:=fFontData[Position];
            inc(Position,SizeOf(TpvUInt8));
            EncodingTable[i]:=TpvRawByteString(IntToStr(Code));
           end;
          end;
          1:begin
           CountCodes:=0;
           try
            if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
             result:=pvTTF_TT_ERR_CorruptFile;
             exit;
            end;
            CountRanges:=fFontData[Position];
            inc(Position,SizeOf(TpvUInt8));
            Code:=1;
            for i:=0 to CountRanges-1 do begin
             if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
              result:=pvTTF_TT_ERR_CorruptFile;
              exit;
             end;
             First:=fFontData[Position];
             inc(Position,SizeOf(TpvUInt8));
             if ((Position+SizeOf(TpvUInt8))-1)>=EndOffset then begin
              result:=pvTTF_TT_ERR_CorruptFile;
              exit;
             end;
             CountSubCodes:=fFontData[Position];
             inc(Position,SizeOf(TpvUInt8));
             for j:=First to First+CountSubCodes do begin
              if length(EncodingTable)<(j+1) then begin
               SetLength(EncodingTable,(j+1)*2);
              end;
              CountCodes:=Max(CountCodes,j+1);
              EncodingTable[j]:=TpvRawByteString(IntToStr(Code));
              inc(Code);
             end;
            end;
           finally
            SetLength(EncodingTable,CountCodes);
           end;
          end;
          else begin
           result:=pvTTF_TT_ERR_UnknownEncodingFormat;
           exit;
          end;
         end;
        end;
       end;

       CharsetTableHashMap:=TStringIntegerHashMap.Create(-1);
       try

        for i:=0 to length(CharsetTable)-1 do begin
         if not CharsetTableHashMap.ExistKey(CharsetTable[i]) then begin
          CharsetTableHashMap.Add(CharsetTable[i],i);
         end;
        end;

        SetLength(fCFFCodePointToGlyphIndexTable,length(EncodingTable));

        for i:=0 to length(EncodingTable)-1 do begin
         if CharsetTableHashMap.TryGet(EncodingTable[i],j) then begin
          fCFFCodePointToGlyphIndexTable[i]:=j;
         end else begin
          fCFFCodePointToGlyphIndexTable[i]:=-1;
         end;
        end;

       finally
        CharsetTableHashMap.Free;
       end;

      finally
       EncodingTable:=nil;
      end;

     finally
      CharsetTable:=nil;
     end;

    finally
     StringTable:=nil;
    end;

   finally
    PrivateDictEntryArray:=nil;
   end;

  finally
   TopDictEntryArray:=nil;
  end;

  result:=pvTTF_TT_ERR_NoError;

 end;
end;

function TpvTrueTypeFont.LoadLOCA:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,thisOffset:TpvUInt32;
    i:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('l'),TpvUInt8('o'),TpvUInt8('c'),TpvUInt8('a'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;
  SetLength(fGlyphOffsetArray,fCountGlyphs+1);
  if length(fGlyphOffsetArray)<>(fCountGlyphs+1) then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;
  thisOffset:=0;
  for i:=0 to fCountGlyphs do begin
   case fIndexToLocationFormat of
    0:begin
     thisOffset:=ToWORD(fFontData[Position],fFontData[Position+1])*2;
     inc(Position,sizeof(TpvUInt16));
    end;
    1:begin
     thisOffset:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
     inc(Position,sizeof(TpvUInt32));
    end;
    else begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
   end;
   fGlyphOffsetArray[i]:=thisOffset;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadGLYF:TpvInt32;
var Tag,CheckSum,Offset,Size:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('g'),TpvUInt8('l'),TpvUInt8('y'),TpvUInt8('f'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  fGlyfOffset:=Offset;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadHHEA:TpvInt32;
var Position,Tag,CheckSum,Offset,Size:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('h'),TpvUInt8('h'),TpvUInt8('e'),TpvUInt8('a'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result<>pvTTF_TT_Err_NoError then begin
  Tag:=ToLONGWORD(TpvUInt8('v'),TpvUInt8('h'),TpvUInt8('e'),TpvUInt8('a'));
  result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 end else begin
  Position:=Offset;
  inc(Position,sizeof(TpvUInt32)); // Table Version number
  fHorizontalAscender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fHorizontalDescender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fHorizontalLineGap:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fAdvanceWidthMax:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  inc(Position,sizeof(TpvInt16)); // MinLeftSideBearing
  inc(Position,sizeof(TpvInt16)); // MinRightSideBearing
  inc(Position,sizeof(TpvInt16)); // XMaxExtent
  inc(Position,sizeof(TpvInt16)); // CaretSlopeRise
  inc(Position,sizeof(TpvInt16)); // CaretSlopeRun
  inc(Position,sizeof(TpvUInt16)*5); // 5 reserved words
  inc(Position,sizeof(TpvInt16)); // MetricDataFormat
  fNumfHMetrics:=ToWORD(fFontData[Position],fFontData[Position+1]);
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadHMTX:TpvInt32;
var Position,Tag,CheckSum,Offset,Size:TpvUInt32;
    i,j:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('h'),TpvUInt8('m'),TpvUInt8('t'),TpvUInt8('x'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result<>pvTTF_TT_Err_NoError then begin
  Tag:=ToLONGWORD(TpvUInt8('v'),TpvUInt8('m'),TpvUInt8('t'),TpvUInt8('x'));
  result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 end else begin
  Position:=Offset;
  i:=0;
  while i<fNumfHMetrics do begin
   fGlyphs[i].AdvanceWidth:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   fGlyphs[i].LeftSideBearing:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvInt16));
   inc(i);
  end;
  if fNumfHMetrics<>fCountGlyphs then begin
   j:=fGlyphs[i-1].AdvanceWidth;
   while i<fCountGlyphs do begin
    fGlyphs[i].AdvanceWidth:=j;
    fGlyphs[i].LeftSideBearing:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));
    inc(i);
   end;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadVHEA:TpvInt32;
var Position,Tag,CheckSum,Offset,Size:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('v'),TpvUInt8('h'),TpvUInt8('e'),TpvUInt8('a'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result<>pvTTF_TT_Err_NoError then begin
  Tag:=ToLONGWORD(TpvUInt8('h'),TpvUInt8('h'),TpvUInt8('e'),TpvUInt8('a'));
  result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 end else begin
  Position:=Offset;
  inc(Position,sizeof(TpvUInt32)); // Table Version number
  fVerticalAscender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fVerticalDescender:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fVerticalLineGap:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvInt16));
  fAdvanceHeightMax:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  inc(Position,sizeof(TpvInt16)); // MinTopSideBearing
  inc(Position,sizeof(TpvInt16)); // MinBottomSideBearing
  inc(Position,sizeof(TpvInt16)); // YMaxExtent
  inc(Position,sizeof(TpvInt16)); // CaretSlopeRise
  inc(Position,sizeof(TpvInt16)); // CaretSlopeRun
  inc(Position,sizeof(TpvUInt16)*5); // 5 reserved words
  inc(Position,sizeof(TpvInt16)); // MetricDataFormat
  fNumfVMetrics:=ToWORD(fFontData[Position],fFontData[Position+1]);
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadVMTX:TpvInt32;
var Position,Tag,CheckSum,Offset,Size:TpvUInt32;
    i,j:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('v'),TpvUInt8('m'),TpvUInt8('t'),TpvUInt8('x'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result<>pvTTF_TT_Err_NoError then begin
  Tag:=ToLONGWORD(TpvUInt8('h'),TpvUInt8('m'),TpvUInt8('t'),TpvUInt8('x'));
  result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 end else begin
  Position:=Offset;
  i:=0;
  while i<fNumfVMetrics do begin
   fGlyphs[i].AdvanceHeight:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   fGlyphs[i].TopSideBearing:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvInt16));
   inc(i);
  end;
  if fNumfVMetrics<>fCountGlyphs then begin
   j:=fGlyphs[i-1].AdvanceHeight;
   while i<fCountGlyphs do begin
    fGlyphs[i].AdvanceWidth:=j;
    fGlyphs[i].TopSideBearing:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));
    inc(i);
   end;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadGPOS:TpvInt32;
type PGlyphs=^TGlyphs;
     TGlyphs=record
      Count:TpvInt32;
      Items:array of TpvInt32;
     end;
     TGlyphsByClass=array of TGlyphs;
var Position,Tag,CheckSum,Offset,Size,Next:TpvUInt32;
    MajorVersion,MinorVersion,
    FeatureVariations,LookupType,LookupFlags,
    i,j,k,h,BaseOffset,ScriptListOffset,
    FeatureListOffset,LookupListOffset,LookupListCount,
    LookupTableOffset,SubTableCount,SubTableOffset:TpvInt32;
 function LoadSubTable(const LookupType,SubTableOffset:TpvInt32):TpvInt32;
 var GlyphArray:array of TpvUInt32;
  function LoadCoverageTable(const CoverageOffset:TpvInt32):TpvInt32;
  type TInt64HashMap=TpvHashMap<TpvInt64,TpvInt64>;
  var CoverageFormat,CurrentPosition:TpvUInt32;
      k,h,GlyphCount,RangeCount,StartIndex,EndIndex:TpvInt32;
      GlyphInt64HashMap:TInt64HashMap;
  begin

   CoverageFormat:=ToWORD(fFontData[CoverageOffset+0],fFontData[CoverageOffset+1]);

   GlyphCount:=0;

   case CoverageFormat of
    1:begin
     GlyphCount:=ToWORD(fFontData[CoverageOffset+2],fFontData[CoverageOffset+3]);
     SetLength(GlyphArray,GlyphCount);
     for k:=0 to GlyphCount-1 do begin
      GlyphArray[k]:=ToWORD(fFontData[CoverageOffset+4+(k*2)],fFontData[CoverageOffset+5+(k*2)]);
     end;
    end;
    2:begin
     RangeCount:=ToWORD(fFontData[CoverageOffset+2],fFontData[CoverageOffset+3]);
     try
      GlyphInt64HashMap:=TInt64HashMap.Create(-1);
      try
       CurrentPosition:=CoverageOffset+4;
       for k:=0 to RangeCount-1 do begin
        StartIndex:=ToWORD(fFontData[CurrentPosition+0],fFontData[CurrentPosition+1]);
        EndIndex:=ToWORD(fFontData[CurrentPosition+2],fFontData[CurrentPosition+3]);
        inc(CurrentPosition,6);
        for h:=StartIndex to EndIndex do begin
         if not GlyphInt64HashMap.ExistKey(h) then begin
          GlyphInt64HashMap.Add(h,0);
          if length(GlyphArray)<(GlyphCount+1) then begin
           SetLength(GlyphArray,(GlyphCount+1)*2);
          end;
          GlyphArray[GlyphCount]:=h;
          inc(GlyphCount);
         end;
        end;
       end;
      finally
       GlyphInt64HashMap.Free;
      end;
     finally
      SetLength(GlyphArray,GlyphCount);
     end;
    end;
    else begin
     result:=pvTTF_TT_ERR_UnknownGPOSFormat;
     exit;
    end;
   end;

   result:=pvTTF_TT_Err_NoError;

  end;
  function LoadClassDefinition(Offset:TpvInt32;const ClassCount:TpvInt32;var GlyphsByClass:TGlyphsByClass):TpvInt32;
  var ClassFormat,StartGlyph,GlyphCount,i,Glyph,GlyphClass,ClassRangeCount,StartIndex,EndIndex:TpvInt32;
      Glyphs:PGlyphs;
  begin
   GlyphsByClass:=nil;
   try
    SetLength(GlyphsByClass,ClassCount);
    for i:=0 to ClassCount-1 do begin
     GlyphsByClass[i].Count:=0;
     GlyphsByClass[i].Items:=nil;
    end;
    ClassFormat:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
    inc(Offset,2);
    case ClassFormat of
     1:begin
      StartGlyph:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
      inc(Offset,2);
      GlyphCount:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
      inc(Offset,2);
      for i:=0 to GlyphCount-1 do begin
       Glyph:=StartGlyph+i;
       GlyphClass:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
       inc(Offset,2);
       Glyphs:=@GlyphsByClass[GlyphClass];
       if length(Glyphs^.Items)<(Glyphs^.Count+1) then begin
        SetLength(Glyphs^.Items,(Glyphs^.Count+1)*2);
       end;
       Glyphs^.Items[Glyphs^.Count]:=Glyph;
       inc(Glyphs^.Count);
      end;
     end;
     2:begin
      ClassRangeCount:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
      inc(Offset,2);
      for i:=0 to ClassRangeCount-1 do begin
       StartIndex:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
       inc(Offset,2);
       EndIndex:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
       inc(Offset,2);
       GlyphClass:=ToWORD(fFontData[Offset+0],fFontData[Offset+1]);
       inc(Offset,2);
       for Glyph:=StartIndex to EndIndex do begin
        Glyphs:=@GlyphsByClass[GlyphClass];
        if length(Glyphs^.Items)<(Glyphs^.Count+1) then begin
         SetLength(Glyphs^.Items,(Glyphs^.Count+1)*2);
        end;
        Glyphs^.Items[Glyphs^.Count]:=Glyph;
        inc(Glyphs^.Count);
       end;
      end;
     end;
     else begin
      result:=pvTTF_TT_ERR_UnknownGPOSFormat;
      exit;
     end;
    end;
   finally
   end;
   result:=pvTTF_TT_Err_NoError;
  end;
  function ReadValueFromValueRecord(var Offset:TpvInt32;const ValueFormat,TargetMask:TpvInt32):TpvInt32;
  var Mask,Value:TpvInt32;
  begin
   result:=0;
   Mask:=1;
   while (Mask<=$8000) and (Mask<=ValueFormat) do begin
    Value:=ToSMALLINT(fFontData[Offset+0],fFontData[Offset+1]);
    inc(Offset,2);
    if Mask=TargetMask then begin
     result:=Value;
    end;
    Mask:=Mask shl 1;
   end;
  end;
  procedure AddKerningPair(const FirstGlyph,SecondGlyph,Value:TpvInt32;const Horizontal:boolean);
  var i:TpvInt32;
      KerningTable:PpvTrueTypeFontKerningTable;
      KerningPair:PpvTrueTypeFontKerningPair;
  begin
   KerningTable:=nil;
   for i:=0 to length(fKerningTables)-1 do begin
    if fKerningTables[i].Horizontal=Horizontal then begin
     KerningTable:=@fKerningTables[i];
     break;
    end;
   end;
   if not assigned(KerningTable) then begin
    i:=length(fKerningTables);
    SetLength(fKerningTables,i+1);
    KerningTable:=@fKerningTables[i];
    KerningTable^.Horizontal:=Horizontal;
    KerningTable^.Minimum:=false;
    KerningTable^.XStream:=not Horizontal;
    KerningTable^.ValueOverride:=true;
    KerningTable^.BinarySearch:=false;
    KerningTable^.KerningPairs:=nil;
    KerningTable^.CountKerningPairs:=0;
   end;
   i:=KerningTable^.CountKerningPairs;
   inc(KerningTable^.CountKerningPairs);
   if length(KerningTable^.KerningPairs)<KerningTable^.CountKerningPairs then begin
    SetLength(KerningTable^.KerningPairs,KerningTable^.CountKerningPairs*2);
   end;
   KerningPair:=@KerningTable^.KerningPairs[i];
   KerningPair^.Left:=FirstGlyph;
   KerningPair^.Right:=SecondGlyph;
   KerningPair^.Value:=Value;
  end;
 var i,j,k,h,SubTableType,CoverageOffset,ValueFormat1,ValueFormat2,PairSetCount,
     PairSetTableOffset,FirstGlyph,SecondGlyph,CurrentPosition,
     x,ClassDefOffset1,ClassDefOffset2,Class1Count,Class2Count,
     PairValueCount,NewLookupType,Glyph:TpvInt32;
     GlyphsByClass1,GlyphsByClass2:TGlyphsByClass;
     Found:boolean;
     Glyphs1,Glyphs2:PGlyphs;
 begin

  case LookupType of
   2:begin

    // Pair adjustment subtable

    SubTableType:=ToWORD(fFontData[SubTableOffset+0],fFontData[SubTableOffset+1]);

    case SubTableType of
     1:begin

      // Format 1

      CoverageOffset:=SubTableOffset+ToWORD(fFontData[SubTableOffset+2],fFontData[SubTableOffset+3]);
      ValueFormat1:=ToWORD(fFontData[SubTableOffset+4],fFontData[SubTableOffset+5]);
      ValueFormat2:=ToWORD(fFontData[SubTableOffset+6],fFontData[SubTableOffset+7]);
      PairSetCount:=ToWORD(fFontData[SubTableOffset+8],fFontData[SubTableOffset+9]);
      PairSetTableOffset:=SubTableOffset+10;

      GlyphArray:=nil;
      try

       result:=LoadCoverageTable(CoverageOffset);
       if result<>pvTTF_TT_Err_NoError then begin
        exit;
       end;

       PairSetCount:=Min(PairSetCount,length(GlyphArray));

       for k:=0 to PairSetCount-1 do begin
        FirstGlyph:=GlyphArray[k];
        CurrentPosition:=SubTableOffset+ToWORD(fFontData[PairSetTableOffset+0+(k*2)],fFontData[PairSetTableOffset+1+(k*2)]);
        PairValueCount:=ToWORD(fFontData[CurrentPosition+0],fFontData[CurrentPosition+1]);
        inc(CurrentPosition,2);
        for h:=0 to PairValueCount-1 do begin
         SecondGlyph:=ToWORD(fFontData[CurrentPosition+0],fFontData[CurrentPosition+1]);
         inc(CurrentPosition,2);
         x:=ReadValueFromValueRecord(CurrentPosition,ValueFormat1,$0004);
         ReadValueFromValueRecord(CurrentPosition,ValueFormat2,$0004);
         AddKerningPair(FirstGlyph,SecondGlyph,x,true);
        end;
       end;

      finally
       GlyphArray:=nil;
      end;

     end;
     2:begin

      // Format 2

      CoverageOffset:=SubTableOffset+ToWORD(fFontData[SubTableOffset+2],fFontData[SubTableOffset+3]);
      ValueFormat1:=ToWORD(fFontData[SubTableOffset+4],fFontData[SubTableOffset+5]);
      ValueFormat2:=ToWORD(fFontData[SubTableOffset+6],fFontData[SubTableOffset+7]);
      ClassDefOffset1:=ToWORD(fFontData[SubTableOffset+8],fFontData[SubTableOffset+9]);
      ClassDefOffset2:=ToWORD(fFontData[SubTableOffset+10],fFontData[SubTableOffset+11]);
      Class1Count:=ToWORD(fFontData[SubTableOffset+12],fFontData[SubTableOffset+13]);
      Class2Count:=ToWORD(fFontData[SubTableOffset+14],fFontData[SubTableOffset+15]);

      GlyphArray:=nil;
      try

       result:=LoadCoverageTable(CoverageOffset);
       if result<>pvTTF_TT_Err_NoError then begin
        exit;
       end;

       GlyphsByClass1:=nil;
       try

        GlyphsByClass2:=nil;
        try

         result:=LoadClassDefinition(SubTableOffset+ClassDefOffset1,Class1Count,GlyphsByClass1);
         if result<>pvTTF_TT_Err_NoError then begin
          exit;
         end;

         result:=LoadClassDefinition(SubTableOffset+ClassDefOffset2,Class2Count,GlyphsByClass2);
         if result<>pvTTF_TT_Err_NoError then begin
          exit;
         end;

         for i:=0 to length(GlyphArray)-1 do begin
          Glyph:=GlyphArray[i];
          Found:=false;
          for j:=1 to Class1Count-1 do begin
           Glyphs1:=@GlyphsByClass1[j];
           for k:=0 to Glyphs1^.Count-1 do begin
            if Glyphs1^.Items[k]=Glyph then begin
             Found:=true;
             break;
            end;
           end;
           if Found then begin
            break;
           end;
          end;
          if not Found then begin
           Glyphs1:=@GlyphsByClass1[0];
           if length(Glyphs1^.Items)<(Glyphs1^.Count+1) then begin
            SetLength(Glyphs1^.Items,(Glyphs1^.Count+1)*2);
           end;
           Glyphs1^.Items[Glyphs1^.Count]:=Glyph;
           inc(Glyphs1^.Count);
          end;
         end;

         CurrentPosition:=SubTableOffset+16;

         for i:=0 to Class1Count-1 do begin
          for j:=0 to Class2Count-1 do begin
           x:=ReadValueFromValueRecord(CurrentPosition,ValueFormat1,$0004);
           ReadValueFromValueRecord(CurrentPosition,ValueFormat2,$0004);
           if x<>0 then begin
            Glyphs1:=@GlyphsByClass1[i];
            for k:=0 to Glyphs1^.Count-1 do begin
             FirstGlyph:=Glyphs1^.Items[k];
             Glyphs2:=@GlyphsByClass2[j];
             for h:=0 to Glyphs2^.Count-1 do begin
              SecondGlyph:=Glyphs2^.Items[h];
              AddKerningPair(FirstGlyph,SecondGlyph,x,true);
             end;
            end;
           end;
          end;
         end;

        finally
         GlyphsByClass2:=nil;
        end;

       finally
        GlyphsByClass1:=nil;
       end;

      finally
       GlyphArray:=nil;
      end;

     end;
    end;

   end;
   9:begin

    // Extension positioning subtable

    SubTableType:=ToWORD(fFontData[SubTableOffset+0],fFontData[SubTableOffset+1]);

    case SubTableType of
     1:begin

      // Format 1

      NewLookupType:=ToWORD(fFontData[SubTableOffset+2],fFontData[SubTableOffset+3]);
      CurrentPosition:=SubTableOffset+TpvInt32(ToLONGWORD(fFontData[SubTableOffset+4],fFontData[SubTableOffset+5],fFontData[SubTableOffset+6],fFontData[SubTableOffset+7]));

      result:=LoadSubTable(NewLookupType,CurrentPosition);
      if result<>pvTTF_TT_Err_NoError then begin
       exit;
      end;

     end;
    end;

   end;
  end;

  result:=pvTTF_TT_Err_NoError;

 end;
var KerningTable:PpvTrueTypeFontKerningTable;
    DoNeedSort:boolean;
begin

 Tag:=ToLONGWORD(TpvUInt8('G'),TpvUInt8('P'),TpvUInt8('O'),TpvUInt8('S'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin

  Position:=Offset;

  BaseOffset:=Position;

  MajorVersion:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  MinorVersion:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  ScriptListOffset:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  FeatureListOffset:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  LookupListOffset:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  if (MajorVersion=1) and (MinorVersion=0) then begin
   FeatureVariations:=0;
  end else if (MajorVersion=1) and (MinorVersion=1) then begin
   FeatureVariations:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
   inc(Position,sizeof(TpvUInt32));
  end else begin
   result:=pvTTF_TT_ERR_UnknownGPOSFormat;
   exit;
  end;

  if ScriptListOffset<>0 then begin
  end;

  if FeatureListOffset<>0 then begin
  end;

  LookupListCount:=ToWORD(fFontData[BaseOffset+LookupListOffset+0],fFontData[BaseOffset+LookupListOffset+1]);

  fKerningTables:=nil;

  for i:=0 to LookupListCount-1 do begin

   LookupTableOffset:=BaseOffset+LookupListOffset+ToWORD(fFontData[BaseOffset+LookupListOffset+2+(i*2)],fFontData[BaseOffset+LookupListOffset+3+(i*2)]);

   LookupType:=ToWORD(fFontData[LookupTableOffset+0],fFontData[LookupTableOffset+1]);

   LookupFlags:=ToWORD(fFontData[LookupTableOffset+2],fFontData[LookupTableOffset+3]);

   SubTableCount:=ToWORD(fFontData[LookupTableOffset+4],fFontData[LookupTableOffset+5]);

   for j:=0 to SubTableCount-1 do begin

    SubTableOffset:=LookupTableOffset+ToWORD(fFontData[LookupTableOffset+6+(i*2)],fFontData[LookupTableOffset+7+(i*2)]);

    result:=LoadSubTable(LookupType,SubTableOffset);
    if result<>pvTTF_TT_Err_NoError then begin
     exit;
    end;

   end;

  end;

  for i:=0 to length(fKerningTables)-1 do begin
   KerningTable:=@fKerningTables[i];
   SetLength(KerningTable^.KerningPairs,KerningTable^.CountKerningPairs);
   KerningTable^.BinarySearch:=false;
   if length(KerningTable^.KerningPairs)<>0 then begin
    DoNeedSort:=false;
    for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
     if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
      DoNeedSort:=true;
      break;
     end;
    end;
    if DoNeedSort then begin
     UntypedDirectIntroSort(@KerningTable^.KerningPairs[0],0,length(KerningTable^.KerningPairs)-1,SizeOf(TpvTrueTypeFontKerningPair),CompareKerningPairs);
    end;
    KerningTable^.BinarySearch:=true;
    for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
     if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
      KerningTable^.BinarySearch:=false;
      break;
     end;
    end;
   end;
  end;

  result:=pvTTF_TT_ERR_NoError;

 end;

end;

function TpvTrueTypeFont.LoadKERN:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,SubTableSize,Next,Version:TpvUInt32;
    CountSubTables,i,j:TpvInt32;
    CoverageFormat,CoverageFlags:TpvUInt8;
    DoNeedSort,Minimum,XStream:boolean;
    KerningTable:PpvTrueTypeFontKerningTable;
 function LoadKerningTableFormat0:TpvInt32;
 var i,j:TpvInt32;
     DoNeedSort:boolean;
     KerningPair:PpvTrueTypeFontKerningPair;
 begin

  KerningTable^.CountKerningPairs:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  inc(Position,sizeof(TpvUInt16)); // Search range
  inc(Position,sizeof(TpvUInt16)); // Entry selector
  inc(Position,sizeof(TpvUInt16)); // Range shift

  KerningTable^.KerningPairs:=nil;
  SetLength(KerningTable^.KerningPairs,KerningTable^.CountKerningPairs);
  if length(KerningTable^.KerningPairs)<>KerningTable^.CountKerningPairs then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;

  if (length(KerningTable^.KerningPairs)*12)>length(fFontData) then begin
   result:=pvTTF_TT_ERR_CorruptFile;
   exit;
  end;

  for j:=0 to length(KerningTable^.KerningPairs)-1 do begin
   KerningPair:=@KerningTable^.KerningPairs[j];
   KerningPair^.Left:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   KerningPair^.Right:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   KerningPair^.Value:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvInt16));
  end;

  KerningTable^.BinarySearch:=false;
  if length(KerningTable^.KerningPairs)<>0 then begin
   DoNeedSort:=false;
   for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
    if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
     DoNeedSort:=true;
     break;
    end;
   end;
   if DoNeedSort then begin
    UntypedDirectIntroSort(@KerningTable^.KerningPairs[0],0,length(KerningTable^.KerningPairs)-1,SizeOf(TpvTrueTypeFontKerningPair),CompareKerningPairs);
   end;
   KerningTable^.BinarySearch:=true;
   for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
    if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
     KerningTable^.BinarySearch:=false;
     break;
    end;
   end;
  end;

  result:=pvTTF_TT_ERR_NoError;

 end;
 function LoadKerningTableFormat2:TpvInt32;
 var i,j,Offset,RowWidth,LeftOffsetTable,RightOffsetTable,KernArray,
     LeftClassOffset,RightClassOffset,LeftFirstGlyph,LeftCountGlyphs,
     RightFirstGlyph,RightCountGlyphs,LeftGlyphCounter,RightGlyphCounter,
     KerningPairIndex:TpvInt32;
     DoNeedSort:boolean;
     KerningPair:PpvTrueTypeFontKerningPair;
 begin

  Offset:=Position;

  RowWidth:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  LeftOffsetTable:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  RightOffsetTable:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  KernArray:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));

  LeftFirstGlyph:=ToWORD(fFontData[Offset+LeftOffsetTable+0],fFontData[Offset+LeftOffsetTable+1]);
  LeftCountGlyphs:=ToWORD(fFontData[Offset+LeftOffsetTable+2],fFontData[Offset+LeftOffsetTable+3]);

  RightFirstGlyph:=ToWORD(fFontData[Offset+RightOffsetTable+0],fFontData[Offset+RightOffsetTable+1]);
  RightCountGlyphs:=ToWORD(fFontData[Offset+RightOffsetTable+2],fFontData[Offset+RightOffsetTable+3]);

  KerningTable^.CountKerningPairs:=0;
  KerningTable^.KerningPairs:=nil;
  try
   for LeftGlyphCounter:=0 to LeftCountGlyphs-1 do begin
    LeftClassOffset:=ToWORD(fFontData[(Offset+LeftOffsetTable+4)+(LeftGlyphCounter*2)],fFontData[(Offset+LeftOffsetTable+5)+(LeftGlyphCounter*2)]);
    for RightGlyphCounter:=0 to RightCountGlyphs-1 do begin
     RightClassOffset:=ToWORD(fFontData[(Offset+RightOffsetTable+4)+(RightGlyphCounter*2)],fFontData[(Offset+RightOffsetTable+5)+(RightGlyphCounter*2)]);
     KerningPairIndex:=KerningTable^.CountKerningPairs;
     inc(KerningTable^.CountKerningPairs);
     if length(KerningTable^.KerningPairs)<KerningTable^.CountKerningPairs then begin
      SetLength(KerningTable^.KerningPairs,KerningTable^.CountKerningPairs*2);
     end;
     KerningPair:=@KerningTable^.KerningPairs[KerningPairIndex];
     KerningPair^.Left:=LeftGlyphCounter+LeftFirstGlyph;
     KerningPair^.Right:=RightGlyphCounter+RightFirstGlyph;
     KerningPair^.Value:=ToSMALLINT(fFontData[Offset+KernArray+LeftClassOffset+RightClassOffset+0],fFontData[Offset+KernArray+LeftClassOffset+RightClassOffset+1]);
    end;
   end;
  finally
   SetLength(KerningTable^.KerningPairs,KerningTable^.CountKerningPairs);
  end;

  if length(KerningTable^.KerningPairs)<>KerningTable^.CountKerningPairs then begin
   result:=pvTTF_TT_ERR_OutOfMemory;
   exit;
  end;

  KerningTable^.BinarySearch:=false;
  if length(KerningTable^.KerningPairs)<>0 then begin
   DoNeedSort:=false;
   for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
    if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
     DoNeedSort:=true;
     break;
    end;
   end;
   if DoNeedSort then begin
    UntypedDirectIntroSort(@KerningTable^.KerningPairs[0],0,length(KerningTable^.KerningPairs)-1,SizeOf(TpvTrueTypeFontKerningPair),CompareKerningPairs);
   end;
   KerningTable^.BinarySearch:=true;
   for j:=1 to length(KerningTable^.KerningPairs)-1 do begin
    if CompareKerningPairs(@KerningTable^.KerningPairs[j-1],@KerningTable^.KerningPairs[j])>0 then begin
     KerningTable^.BinarySearch:=false;
     break;
    end;
   end;
  end;

  result:=pvTTF_TT_ERR_NoError;

 end;

begin
 Tag:=ToLONGWORD(TpvUInt8('k'),TpvUInt8('e'),TpvUInt8('r'),TpvUInt8('n'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;

  Version:=ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16)); // Table Version number

  case Version of
   0:begin

    CountSubTables:=ToWORD(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvUInt16));

    SetLength(fKerningTables,CountSubTables);
    if length(fKerningTables)<>CountSubTables then begin
     result:=pvTTF_TT_ERR_OutOfMemory;
     exit;
    end;

    for i:=0 to CountSubTables-1 do begin

     KerningTable:=@fKerningTables[i];

     inc(Position,sizeof(TpvUInt16)); // Subtable version number
     SubTableSize:=ToWORD(fFontData[Position],fFontData[Position+1]);
     inc(Position,sizeof(TpvUInt16)); // Subtable Size
     CoverageFormat:=fFontData[Position];
     CoverageFlags:=fFontData[Position+1];
     inc(Position,2);
     Next:=(Position+SubTableSize)-6;

     KerningTable^.Horizontal:=(CoverageFlags and 1)<>0;
     KerningTable^.Minimum:=(CoverageFlags and 2)<>0;
     KerningTable^.XStream:=(CoverageFlags and 4)<>0;
     KerningTable^.ValueOverride:=(CoverageFlags and 8)<>0;

     case CoverageFormat of
      0:begin
       result:=LoadKerningTableFormat0;
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
      2:begin
       result:=LoadKerningTableFormat2;
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
     end;

     Position:=Next;
    end;

    result:=pvTTF_TT_ERR_NoError;

   end;
   1:begin

    inc(Position,sizeof(TpvUInt16)); // Version-Lo

    CountSubTables:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
    inc(Position,sizeof(TpvUInt32));

    SetLength(fKerningTables,CountSubTables);
    if length(fKerningTables)<>CountSubTables then begin
     result:=pvTTF_TT_ERR_OutOfMemory;
     exit;
    end;

    for i:=0 to CountSubTables-1 do begin

     KerningTable:=@fKerningTables[i];

     SubTableSize:=ToLONGWORD(fFontData[Position],fFontData[Position+1],fFontData[Position+2],fFontData[Position+3]);
     inc(Position,sizeof(TpvUInt32)); // Subtable Size
     CoverageFormat:=fFontData[Position];
     CoverageFlags:=fFontData[Position+1];
     inc(Position,2);
     inc(Position,sizeof(TpvUInt16)); // Tuple Index
     Next:=(Position+SubTableSize)-8;

     if (CoverageFlags and 2)<>0 then begin
      // No support for variation values
      Position:=Next;
      continue;
     end;

     KerningTable^.Horizontal:=(CoverageFlags and 8)<>0;
     KerningTable^.Minimum:=false;
     KerningTable^.XStream:=(CoverageFlags and 4)<>0;
     KerningTable^.ValueOverride:=false;

     case CoverageFormat of
      0:begin
       result:=LoadKerningTableFormat0;
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
      end;
      end;
      2:begin
       result:=LoadKerningTableFormat2;
       if result<>pvTTF_TT_ERR_NoError then begin
        exit;
       end;
      end;
     end;

     Position:=Next;

    end;

    result:=pvTTF_TT_ERR_NoError;

   end;
   else begin

    result:=pvTTF_TT_ERR_UnknownKerningFormat;

   end;
  end;

 end;
end;

function TpvTrueTypeFont.LoadCMAP:TpvInt32;
type PTryEntry=^TTryEntry;
     TTryEntry=record
      PlatformID:TpvUInt32;
      SpecificID:TpvUInt32;
     end;
const TryEntries:array[0..9] of TTryEntry=
       ((PlatformID:pvTTF_PID_Microsoft;SpecificID:pvTTF_SID_MS_UCS_4),
        (PlatformID:pvTTF_PID_Apple;SpecificID:pvTTF_SID_APPLE_UNICODE32),
        (PlatformID:pvTTF_PID_Apple;SpecificID:pvTTF_SID_APPLE_UNICODE_2_0),
        (PlatformID:pvTTF_PID_Microsoft;SpecificID:pvTTF_SID_MS_UNICODE_CS),
        (PlatformID:pvTTF_PID_Apple;SpecificID:pvTTF_SID_APPLE_UNICODE_1_1),
        (PlatformID:pvTTF_PID_Apple;SpecificID:pvTTF_SID_APPLE_DEFAULT),
        (PlatformID:pvTTF_PID_Apple;SpecificID:pvTTF_SID_APPLE_ISO_10646),
        (PlatformID:pvTTF_PID_ISO;SpecificID:pvTTF_SID_ISO_10646),
        (PlatformID:pvTTF_PID_ISO;SpecificID:pvTTF_SID_ISO_8859_1),
        (PlatformID:pvTTF_PID_ISO;SpecificID:pvTTF_SID_ISO_ASCII)
       );
var Position,Tag,CheckSum,Offset,Size,NumSubTables,ThisPlatformID,ThisSpecificID,ThisSubtableOffset,SubtableOffset,
    SubtablePosition,i,j:TpvUInt32;
    SubtableLength,CMapIndex:TpvInt32;
    SubtableFound:boolean;
    TryEntry:PTryEntry;
begin
 Tag:=ToLONGWORD(TpvUInt8('c'),TpvUInt8('m'),TpvUInt8('a'),TpvUInt8('p'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin

  for CMapIndex:=0 to 1 do begin
   fCMaps[CMapIndex]:=nil;
   fCMapLengths[CMapIndex]:=0;
  end;

  for CMapIndex:=0 to 1 do begin

   Position:=Offset;
   inc(Position,sizeof(TpvUInt16)); // Table Version number
   NumSubTables:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));

   SubtableFound:=false;
   SubtableOffset:=0;

   if fForceSelector then begin
    SubtablePosition:=Position;
    for i:=1 to NumSubTables do begin
     ThisPlatformID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
     inc(SubtablePosition,sizeof(TpvUInt16));
     ThisSpecificID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
     inc(SubtablePosition,sizeof(TpvUInt16));
     ThisSubtableOffset:=ToLONGWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1],fFontData[SubtablePosition+2],fFontData[SubtablePosition+3]);
     inc(SubtablePosition,sizeof(TpvUInt32));
     if (ThisPlatformID=fPlatformID) and (ThisSpecificID=fSpecificID) then begin
      SubtableFound:=true;
      SubtableOffset:=ThisSubtableOffset;
      break;
     end;
    end;
   end;

{$ifdef HandleVariantSelectorCMap}
   if (CMapIndex=0) and not SubtableFound then begin
    SubtablePosition:=Position;
    for i:=1 to NumSubTables do begin
     ThisPlatformID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
     inc(SubtablePosition,sizeof(TpvUInt16));
     ThisSpecificID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
     inc(SubtablePosition,sizeof(TpvUInt16));
     ThisSubtableOffset:=ToLONGWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1],fFontData[SubtablePosition+2],fFontData[SubtablePosition+3]);
     inc(SubtablePosition,sizeof(TpvUInt32));
     if (ThisPlatformID=pvTTF_PID_Apple) and (ThisSpecificID=pvTTF_SID_APPLE_VARIANT_SELECTOR) then begin
      SubtableFound:=true;
      SubtableOffset:=ThisSubtableOffset;
      break;
     end;
    end;
   end;
{$endif}

   if not SubtableFound then begin

    for i:=low(TryEntries) to high(TryEntries) do begin
     TryEntry:=@TryEntries[i];
     SubtablePosition:=Position;
     for j:=1 to NumSubTables do begin
      ThisPlatformID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
      inc(SubtablePosition,sizeof(TpvUInt16));
      ThisSpecificID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
      inc(SubtablePosition,sizeof(TpvUInt16));
      ThisSubtableOffset:=ToLONGWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1],fFontData[SubtablePosition+2],fFontData[SubtablePosition+3]);
      inc(SubtablePosition,sizeof(TpvUInt32));
      if (ThisPlatformID=TryEntry^.PlatformID) and (ThisSpecificID=TryEntry^.SpecificID) then begin
       SubtableFound:=true;
       SubtableOffset:=ThisSubtableOffset;
       break;
      end;
     end;
     if SubtableFound then begin
      break;
     end;
    end;

    if not SubtableFound then begin

     SubtablePosition:=Position;
     for i:=1 to NumSubTables do begin
      ThisPlatformID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
      inc(SubtablePosition,sizeof(TpvUInt16));
      ThisSpecificID:=ToWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1]);
      inc(SubtablePosition,sizeof(TpvUInt16));
      ThisSubtableOffset:=ToLONGWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1],fFontData[SubtablePosition+2],fFontData[SubtablePosition+3]);
      inc(SubtablePosition,sizeof(TpvUInt32));
      if (ThisPlatformID<>pvTTF_PID_Apple) and (ThisSpecificID<>pvTTF_SID_APPLE_VARIANT_SELECTOR) then begin
       SubtableFound:=true;
       SubtableOffset:=ThisSubtableOffset;
       break;
      end;
     end;

     if (not SubtableFound) and (NumSubTables>0) then begin
      SubtableFound:=true;
      SubtablePosition:=Position+4;
      SubtableOffset:=ToLONGWORD(fFontData[SubtablePosition],fFontData[SubtablePosition+1],fFontData[SubtablePosition+2],fFontData[SubtablePosition+3]);
     end;

     if not SubtableFound then begin
      result:=pvTTF_TT_ERR_NoCharacterMapFound;
      exit;
     end;

    end;

   end;

   Position:=Offset+SubtableOffset;

   fCMapFormat:=ToWORD(fFontData[Position],fFontData[Position+1]);

   case fCMapFormat of
    pvTTF_CMAP_FORMAT0,pvTTF_CMAP_FORMAT2,pvTTF_CMAP_FORMAT4,pvTTF_CMAP_FORMAT6:begin
     SubtableLength:=ToWORD(fFontData[Position+2],fFontData[Position+3]);
    end;
    pvTTF_CMAP_FORMAT8,pvTTF_CMAP_FORMAT10,pvTTF_CMAP_FORMAT12,pvTTF_CMAP_FORMAT13:begin
     SubtableLength:=ToLONGWORD(fFontData[Position+4],fFontData[Position+5],fFontData[Position+6],fFontData[Position+7]);
    end;
    pvTTF_CMAP_FORMAT14:begin
     SubtableLength:=ToLONGWORD(fFontData[Position+2],fFontData[Position+3],fFontData[Position+4],fFontData[Position+5]);
    end;
    else begin
     result:=pvTTF_TT_ERR_UnknownCharacterMapFormat;
     exit;
    end;
   end;

   fCMaps[CMapIndex]:=@fFontData[Offset+SubtableOffset];
   fCMapLengths[CMapIndex]:=SubtableLength;

   if fCMapFormat<>pvTTF_CMAP_FORMAT14 then begin
    break;
   end;

  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadCVT:TpvInt32;
var Position,Tag,CheckSum,Offset,Size:TpvUInt32;
    Index:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('c'),TpvUInt8('v'),TpvUInt8('t'),TpvUInt8(' '));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  SetLength(fCVT,(Size+1) shr 1);
  Position:=Offset;
  for Index:=0 to length(fCVT)-1 do begin
   fCVT[Index]:=TpvInt16(TpvUInt16(ToWORD(fFontData[Position],fFontData[Position+1])));
   inc(Position,SizeOf(TpvUInt16));
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadFPGM:TpvInt32;
var Tag,CheckSum,Offset,Size:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('f'),TpvUInt8('p'),TpvUInt8('g'),TpvUInt8('m'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  fFPGM.Data:=TpvPointer(@fFontData[Offset]);
  fFPGM.Size:=Size;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadPREP:TpvInt32;
var Tag,CheckSum,Offset,Size:TpvUInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('p'),TpvUInt8('r'),TpvUInt8('e'),TpvUInt8('p'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  fPREP.Data:=TpvPointer(@fFontData[Offset]);
  fPREP.Size:=Size;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.LoadGASP:TpvInt32;
var Position,Tag,CheckSum,Offset,Size,{Version,}NumRanges,Index:TpvUInt32;
    LowerRange:TpvInt32;
begin
 Tag:=ToLONGWORD(TpvUInt8('g'),TpvUInt8('a'),TpvUInt8('s'),TpvUInt8('p'));
 result:=GetTableDirEntry(Tag,CheckSum,Offset,Size);
 if result=pvTTF_TT_Err_NoError then begin
  Position:=Offset;
  {Version:=}ToWORD(fFontData[Position],fFontData[Position+1]);
  inc(Position,sizeof(TpvUInt16));
  begin
   NumRanges:=ToWORD(fFontData[Position],fFontData[Position+1]);
   inc(Position,sizeof(TpvUInt16));
   if NumRanges>0 then begin
    SetLength(fGASPRanges,NumRanges);
    LowerRange:=0;
    Index:=0;
    while Index<NumRanges do begin
     fGASPRanges[Index].LowerPPEM:=LowerRange;
     fGASPRanges[Index].UpperPPEM:=ToWORD(fFontData[Position],fFontData[Position+1]);
     inc(Position,sizeof(TpvUInt16));
     fGASPRanges[Index].Flags:=ToWORD(fFontData[Position],fFontData[Position+1]);
     inc(Position,sizeof(TpvUInt16));
     LowerRange:=fGASPRanges[Index].UpperPPEM+1;
     inc(Index);
    end;
    if fGASPRanges[NumRanges-1].UpperPPEM=$ffff then begin
     fGASPRanges[NumRanges-1].UpperPPEM:=$7fffffff;
    end;
   end;
  end;
  result:=pvTTF_TT_ERR_NoError;
 end;
end;

function TpvTrueTypeFont.GetGASPRange:PpvTrueTypeFontGASPRange;
var l,h,m,v:TpvInt32;
begin
 l:=0;
 h:=length(fGASPRanges);
 result:=@fGASPRanges[h-1];
 v:=SARLongint(GetScale+32,6);
 while l<h do begin
  m:=(l+h) shr 1;
  if v<fGASPRanges[m].LowerPPEM then begin
   h:=m;
  end else if v>fGASPRanges[m].UpperPPEM then begin
   l:=m+1;
  end else begin
   result:=@fGASPRanges[m];
   break;
  end;
 end;
end;

function TpvTrueTypeFont.LoadGlyphData(GlyphIndex:TpvInt32):TpvInt32;
var Offset,Size,CurrentGlyphOffset,NextGlyphOffset,CurrentGlyphLength,Position,OldPosition,CurrentFlags,CurrentIndex,
    InstructionLength,RepeatCount,CurrentFlag:TpvUInt32;
    SubGlyphIndex,NumContours,Index,NumAllPoints,Last,Current:TpvInt32;
    carg1,carg2,cxx,cyx,cxy,cyy:TpvInt32;
begin
 if (fGlyfOffset<>0) and ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) then begin

  if (fGlyphLoadedBitmap[GlyphIndex shr 3] and (TpvUInt32(1) shl TpvUInt32(GlyphIndex and 31)))=0 then begin

   fGlyphLoadedBitmap[GlyphIndex shr 3]:=fGlyphLoadedBitmap[GlyphIndex shr 3] or (TpvUInt32(1) shl TpvUInt32(GlyphIndex and 31));

   Offset:=fGlyfOffset;

   fGlyphs[GlyphIndex].CompositeSubGlyphs:=nil;

   fGlyphs[GlyphIndex].PostScriptPolygon.Commands:=nil;
   fGlyphs[GlyphIndex].PostScriptPolygon.CountCommands:=0;

   FillChar(fGlyphs[GlyphIndex].Instructions,SizeOf(TpvTrueTypeFontByteCodeInterpreterProgramBytes),AnsiChar(#0));

   CurrentGlyphOffset:=fGlyphOffsetArray[GlyphIndex];
   NextGlyphOffset:=fGlyphOffsetArray[GlyphIndex+1];
   CurrentGlyphLength:=NextGlyphOffset-CurrentGlyphOffset;

   fGlyphs[GlyphIndex].UseMetricsFrom:=-1;

   if CurrentGlyphLength=0 then begin

    fGlyphs[GlyphIndex].Points:=nil;
    fGlyphs[GlyphIndex].Bounds.XMin:=0;
    fGlyphs[GlyphIndex].Bounds.YMin:=0;
    fGlyphs[GlyphIndex].Bounds.XMax:=0;
    fGlyphs[GlyphIndex].Bounds.YMax:=0;

   end else begin

    Position:=Offset+CurrentGlyphOffset;

    if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    NumContours:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));

    if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    fGlyphs[GlyphIndex].Bounds.XMin:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));

    if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    fGlyphs[GlyphIndex].Bounds.YMin:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));

    if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    fGlyphs[GlyphIndex].Bounds.XMax:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));

    if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
     result:=pvTTF_TT_ERR_CorruptFile;
     exit;
    end;
    fGlyphs[GlyphIndex].Bounds.YMax:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
    inc(Position,sizeof(TpvInt16));

    if NumContours<=0 then begin

     if NumContours=-1 then begin

      OldPosition:=Position;

      SubGlyphIndex:=0;

      repeat

       if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       CurrentFlags:=ToWORD(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvUInt16));

       if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       inc(Position,sizeof(TpvUInt16));

       if (CurrentFlags and ARGS_ARE_WORDS)<>0 then begin
        if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));
       end else begin
        if (Position+sizeof(shortint))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position);

        if (Position+sizeof(shortint))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position);
       end;

       if (CurrentFlags and WE_HAVE_A_SCALE)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));
       end else if (CurrentFlags and WE_HAVE_AN_XY_SCALE)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));
       end else if (CurrentFlags and WE_HAVE_A_2X2)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        inc(Position,sizeof(TpvInt16));
       end;

       inc(SubGlyphIndex);

      until (CurrentFlags and MORE_COMPONENTS)=0;

      Position:=OldPosition;

      SetLength(fGlyphs[GlyphIndex].CompositeSubGlyphs,SubGlyphIndex);

      SubGlyphIndex:=0;
      repeat

       if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       CurrentFlags:=ToWORD(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvUInt16));

       if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       CurrentIndex:=ToWORD(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvUInt16));

       if (CurrentFlags and USE_MY_METRICS)<>0 then begin
        fGlyphs[GlyphIndex].UseMetricsFrom:=CurrentIndex;
       end;

       if (CurrentFlags and ARGS_ARE_WORDS)<>0 then begin
        if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        carg1:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        carg2:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
        inc(Position,sizeof(TpvInt16));
       end else begin
        if (Position+sizeof(shortint))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        carg1:=SHORTINT(fFontData[Position]);
        inc(Position);

        if (Position+sizeof(shortint))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        carg2:=SHORTINT(fFontData[Position]);
        inc(Position);
       end;

       cxx:=$10000;
       cyy:=$10000;
       cxy:=0;
       cyx:=0;

       if (CurrentFlags and WE_HAVE_A_SCALE)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cxx:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));
        cyy:=cxx;
       end else if (CurrentFlags and WE_HAVE_AN_XY_SCALE)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cxx:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cyy:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));
       end else if (CurrentFlags and WE_HAVE_A_2X2)<>0 then begin
        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cxx:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cyx:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cxy:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));

        if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
         result:=pvTTF_TT_ERR_CorruptFile;
         exit;
        end;
        cyy:=ToSMALLINT(fFontData[Position],fFontData[Position+1])*4;
        inc(Position,sizeof(TpvInt16));
       end;

       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].Flags:=CurrentFlags;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].Glyph:=CurrentIndex;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].Arg1:=carg1;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].Arg2:=carg2;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].xx:=cxx;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].yx:=cyx;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].xy:=cxy;
       fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphIndex].yy:=cyy;

       inc(SubGlyphIndex);
      until (CurrentFlags and MORE_COMPONENTS)=0;

      if (CurrentFlags and WE_HAVE_INSTR)<>0 then begin

       // TpvUInt8 code instruction Data
       if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       InstructionLength:=ToWORD(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvUInt16));
       if (Position+InstructionLength)>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;

       if InstructionLength>0 then begin
        fGlyphs[GlyphIndex].Instructions.Data:=TpvPointer(@fFontData[Position]);
        fGlyphs[GlyphIndex].Instructions.Size:=InstructionLength;
       end else begin
        fGlyphs[GlyphIndex].Instructions.Data:=nil;
        fGlyphs[GlyphIndex].Instructions.Size:=0;
       end;

      end;

     end;

    end else begin

     SetLength(fGlyphs[GlyphIndex].EndPointIndices,NumContours);
     if length(fGlyphs[GlyphIndex].EndPointIndices)<>NumContours then begin
      result:=pvTTF_TT_ERR_OutOfMemory;
      exit;
     end;

     // End point indices
     for Index:=0 to NumContours-1 do begin
      if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      fGlyphs[GlyphIndex].EndPointIndices[Index]:=ToWORD(fFontData[Position],fFontData[Position+1]);
      inc(Position,sizeof(TpvUInt16));
     end;
     NumAllPoints:=fGlyphs[GlyphIndex].EndPointIndices[length(fGlyphs[GlyphIndex].EndPointIndices)-1]+1;

     // TpvUInt8 code instruction Data
     if (Position+sizeof(TpvUInt16))>(NextGlyphOffset+Offset) then begin
      result:=pvTTF_TT_ERR_CorruptFile;
      exit;
     end;
     InstructionLength:=ToWORD(fFontData[Position],fFontData[Position+1]);
     inc(Position,sizeof(TpvUInt16));
     if (Position+InstructionLength)>(NextGlyphOffset+Offset) then begin
      result:=pvTTF_TT_ERR_CorruptFile;
      exit;
     end;

     if InstructionLength>0 then begin
      fGlyphs[GlyphIndex].Instructions.Data:=TpvPointer(@fFontData[Position]);
      fGlyphs[GlyphIndex].Instructions.Size:=InstructionLength;
     end else begin
      fGlyphs[GlyphIndex].Instructions.Data:=nil;
      fGlyphs[GlyphIndex].Instructions.Size:=0;
     end;
     inc(Position,InstructionLength);

     SetLength(fGlyphs[GlyphIndex].Points,NumAllPoints);
     if length(fGlyphs[GlyphIndex].Points)<>NumAllPoints then begin
      result:=pvTTF_TT_ERR_OutOfMemory;
      exit;
     end;

     // Flags
     Index:=0;
     while Index<NumAllPoints do begin
      if (Position+sizeof(TpvUInt8))>(NextGlyphOffset+Offset) then begin
       result:=pvTTF_TT_ERR_CorruptFile;
       exit;
      end;
      fGlyphs[GlyphIndex].Points[Index].Flags:=fFontData[Position];
      inc(Position);
      if (fGlyphs[GlyphIndex].Points[Index].Flags and pvTTF_PathFlag_Repeat)<>0 then begin
       RepeatCount:=fFontData[Position];
       inc(Position);
       while RepeatCount>0 do begin
        inc(Index);
        fGlyphs[GlyphIndex].Points[Index].Flags:=fGlyphs[GlyphIndex].Points[Index-1].Flags;
        dec(RepeatCount);
       end;
      end;
      inc(Index);
     end;

     // X points
     Last:=0;
     for Index:=0 to NumAllPoints-1 do begin
      CurrentFlag:=fGlyphs[GlyphIndex].Points[Index].Flags;
      if (CurrentFlag and pvTTF_PathFlag_OnXShortVector)<>0 then begin
       if (Position+sizeof(TpvUInt8))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       Current:=fFontData[Position];
       inc(Position);
       if (CurrentFlag and pvTTF_PathFlag_PositiveXShortVector)=0 then begin
        Current:=-Current;
       end;
      end else if (CurrentFlag and pvTTF_PathFlag_ThisXIsSame)<>0 then begin
       Current:=0;
      end else begin
       if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       Current:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvInt16));
      end;
      Last:=Last+Current;
      fGlyphs[GlyphIndex].Points[Index].x:=Last;
     end;

     // Y points
     Last:=0;
     for Index:=0 to NumAllPoints-1 do begin
      CurrentFlag:=fGlyphs[GlyphIndex].Points[Index].Flags;
      if (CurrentFlag and pvTTF_PathFlag_OnYShortVector)<>0 then begin
       if (Position+sizeof(TpvUInt8))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       Current:=fFontData[Position];
       inc(Position);
       if (CurrentFlag and pvTTF_PathFlag_PositiveYShortVector)=0 then begin
        Current:=-Current;
       end;
      end else if (CurrentFlag and pvTTF_PathFlag_ThisYIsSame)<>0 then begin
       Current:=0;
      end else begin
       if (Position+sizeof(TpvInt16))>(NextGlyphOffset+Offset) then begin
        result:=pvTTF_TT_ERR_CorruptFile;
        exit;
       end;
       Current:=ToSMALLINT(fFontData[Position],fFontData[Position+1]);
       inc(Position,sizeof(TpvInt16));
      end;
      Last:=Last+Current;
      fGlyphs[GlyphIndex].Points[Index].y:=Last;
     end;

    end;

   end;

   if (fGlyphs[GlyphIndex].UseMetricsFrom>=0) and (fGlyphs[GlyphIndex].UseMetricsFrom<fCountGlyphs) then begin
    if LoadGlyphData(fGlyphs[GlyphIndex].UseMetricsFrom)=pvTTF_TT_ERR_NoError then begin
     fGlyphs[GlyphIndex].Bounds:=fGlyphs[fGlyphs[GlyphIndex].UseMetricsFrom].Bounds;
    end;
   end;

   result:=pvTTF_TT_ERR_NoError;

  end else begin

   result:=pvTTF_TT_ERR_NoError;

  end;

 end else begin

  result:=pvTTF_TT_ERR_OutOfBounds;

 end;

end;

function TpvTrueTypeFont.GetGlyphIndex(CodePointCode:TpvUInt32;CMapIndex:TpvInt32=0):TpvUInt32;
var CMap:PpvTrueTypeFontByteArray;
    SegCount,u:TpvUInt16;
    EndCount,StartCount,IDDelta,IDRangeOffset,Data,SubHeaderKeysData:PpvTrueTypeFontByteArray;
    CMapLength,EndV,Start,Delta,Range,Index,Seg,i,NumSH,NumGlyphID,index1,Idx,IDDeltaValue,
    IDRangeOffsetValue,Offset,FirstCode,EntryCount,l,h,m,CharHi,CharLo,
    NumSelectors,SelectorIndex,LastVarSelector,VarSelector,DefaultOffset,
    NonDefaultOffset,NumMappings,Unicode:TpvUInt32;
begin
 if (CMapIndex>=0) and (CMapIndex<length(fCMaps)) then begin
  CMap:=fCMaps[CMapIndex];
  CMapLength:=fCMapLengths[CMapIndex];
 end else begin
  CMap:=nil;
  CMapLength:=0;
 end;
 if CMapLength=0 then begin
  fLastError:=pvTTF_TT_ERR_CharacterMapNotPresent;
  result:=0;
 end else begin
  fLastError:=pvTTF_TT_ERR_NoError;
  case fCMapFormat of
   pvTTF_CMAP_FORMAT0:begin
    Offset:=CodePointCode+6;
    if Offset<TpvUInt32(CMapLength) then begin
     result:=CMap^[Offset];
    end else begin
     result:=0;
    end;
   end;
   pvTTF_CMAP_FORMAT2:begin
    if CodePointCode>$ffff then begin
     result:=0;
    end else begin
     if CodePointCode<256 then begin
      Index:=CodePointCode;
     end else begin
      Index:=CodePointCode shr 8;
     end;
     SubHeaderKeysData:=@CMap^[6];
     NumSH:=0;
     for i:=0 to 255 do begin
      u:=ToWORD(SubHeaderKeysData[i*2],SubHeaderKeysData[(i*2)+1]) shr 3;
      fSubHeaderKeys[i]:=u;
      if NumSH<u then begin
       NumSH:=u;
      end;
     end;
     NumGlyphID:=((TpvUInt32(CMapLength)-(2*(256+3))-(NumSH*8)) and $ffff) shr 1;
     index1:=fSubHeaderKeys[Index];
     if index1=0 then begin
      if CodePointCode<256 then begin
       if CodePointCode<NumGlyphID then begin
        Data:=@CMap^[6+(256*2)+(NumSH*8)];
        result:=ToWORD(Data^[CodePointCode*2],Data^[(CodePointCode*2)+1]);
       end else begin
        result:=0;
       end;
      end else begin
       result:=0;
      end;
     end else begin
      if CodePointCode<256 then begin
       result:=0;
      end else begin
       idx:=CodePointCode and $ff;
       Data:=@CMap^[6+(256*2)+(index1*8)];
       FirstCode:=ToWORD(Data^[0],Data^[1]);
       EntryCount:=ToWORD(Data^[2],Data^[3]);
       IDDeltaValue:=ToWORD(Data^[4],Data^[5]);
       IDRangeOffsetValue:=ToWORD(Data^[6],Data^[7])-(((NumSH-index1)*8)+2);
       if (idx>=FirstCode) and (idx<(FirstCode+EntryCount)) then begin
        Offset:=(IDRangeOffsetValue shr 1)+(idx-FirstCode);
        if Offset<NumGlyphID then begin
         Data:=@CMap^[6+(256*2)+(NumSH*8)];
         result:=ToWORD(Data^[Offset*2],Data^[(Offset*2)+1]);
         if result<>0 then begin
          result:=(result+IDDeltaValue) and $ffff;
         end;
        end else begin
         result:=0;
        end;
       end else begin
        result:=0;
       end;
      end;
     end;
    end;
   end;
   pvTTF_CMAP_FORMAT4:begin
    if CodePointCode>$ffff then begin
     result:=0;
    end else begin
     CodePointCode:=CodePointCode and $ffff;
     SegCount:=ToWORD(CMap^[6],CMap^[7]) shr 1;
     EndCount:=@CMap^[14];
     StartCount:=@CMap^[16+(2*SegCount)];
     IDDelta:=@CMap^[16+(4*SegCount)];
     IDRangeOffset:=@CMap^[16+(6*SegCount)];
     seg:=0;
     EndV:=ToWORD(EndCount^[0],EndCount^[1]);
     while EndV<CodePointCode do begin
      inc(seg);
      EndV:=ToWORD(EndCount^[seg*2],EndCount^[(seg*2)+1]);
     end;
     Start:=ToWORD(StartCount^[seg*2],StartCount^[(seg*2)+1]);
     Delta:=ToWORD(IDDelta^[seg*2],IDDelta^[(seg*2)+1]);
     Range:=ToWORD(IDRangeOffset[seg*2],IDRangeOffset[(seg*2)+1]);
     if Start>CodePointCode then begin
      result:=0;
     end else begin
      if Range=0 then begin
       Index:=(TpvUInt16(CodePointCode)+TpvUInt16(Delta)) and $ffff;
      end else begin
       Index:=Range+((CodePointCode-Start)*2)+((16+(6*SegCount))+(seg*2));
       Index:=ToWORD(CMap^[Index],CMap^[Index+1]);
       if Index<>0 then begin
        Index:=(TpvUInt16(Index)+TpvUInt16(Delta)) and $ffff;
       end;
      end;
      result:=Index;
     end;
    end;
   end;
   pvTTF_CMAP_FORMAT6:begin
    FirstCode:=ToWORD(CMap^[6],CMap^[7]);
    EntryCount:=ToWORD(CMap^[8],CMap^[9]);
    if (CodePointCode>=FirstCode) and (CodePointCode<(FirstCode+EntryCount)) then begin
     Offset:=(TpvUInt32(CodePointCode-FirstCode)*2)+10;
     result:=ToWORD(CMap^[Offset],CMap^[Offset+1]);
    end else begin
     result:=0;
    end;
   end;
   pvTTF_CMAP_FORMAT8:begin
    result:=0;
    EntryCount:=ToLONGWORD(CMap^[8204],CMap^[8205],CMap^[8206],CMap^[8207]);
    if EntryCount>0 then begin
     l:=0;
     h:=EntryCount;
     while l<h do begin
      m:=(l+h) shr 1;
      Offset:=8208+(m*12);
      Start:=ToLONGWORD(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2],CMap^[Offset+3]);
      EndV:=ToLONGWORD(CMap^[Offset+4],CMap^[Offset+5],CMap^[Offset+6],CMap^[Offset+7]);
      if CodePointCode<Start then begin
       h:=m;
      end else if CodePointCode>EndV then begin
       l:=m+1;
      end else begin
       if (m and $ffff0000)=0 then begin
        if (CMap^[12+(m shr 3)] and ($80 shr (m and 7)))<>0 then begin
         break;
        end;
       end else begin
        if ((CMap^[12+((m and $ffff) shr 3)] and ($80 shr ((m and $ffff) and 7)))=0) or
            ((CMap^[12+(((m shr 16) and $ffff) shr 3)] and ($80 shr (((m shr 16) and $ffff) and 7)))=0) then begin
          break;
        end;
       end;
       result:=(ToLONGWORD(CMap^[Offset+8],CMap^[Offset+9],CMap^[Offset+10],CMap^[Offset+11])+CodePointCode)-Start;
       break;
      end;
     end;
    end;
   end;
   pvTTF_CMAP_FORMAT10:begin
    FirstCode:=ToLONGWORD(CMap^[12],CMap^[13],CMap^[14],CMap^[15]);
    EntryCount:=ToLONGWORD(CMap^[16],CMap^[17],CMap^[18],CMap^[19]);
    if (CodePointCode>=FirstCode) and (CodePointCode<(FirstCode+EntryCount)) then begin
     Offset:=(TpvUInt32(CodePointCode-FirstCode)*2)+20;
     result:=ToWORD(CMap^[Offset],CMap^[Offset+1]);
    end else begin
     result:=0;
    end;
   end;
   pvTTF_CMAP_FORMAT12:begin
    result:=0;
    EntryCount:=ToWORD(CMap^[6],CMap^[7]);
    if EntryCount>0 then begin
     l:=0;
     h:=EntryCount;
     while l<h do begin
      m:=(l+h) shr 1;
      Offset:=16+(m*12);
      Start:=ToLONGWORD(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2],CMap^[Offset+3]);
      EndV:=ToLONGWORD(CMap^[Offset+4],CMap^[Offset+5],CMap^[Offset+6],CMap^[Offset+7]);
      if CodePointCode<Start then begin
       h:=m;
      end else if CodePointCode>EndV then begin
       l:=m+1;
      end else begin
       result:=(ToLONGWORD(CMap^[Offset+8],CMap^[Offset+9],CMap^[Offset+10],CMap^[Offset+11])+CodePointCode)-Start;
       break;
      end;
     end;
    end;
   end;
   pvTTF_CMAP_FORMAT13:begin
    result:=0;
    EntryCount:=ToWORD(CMap^[6],CMap^[7]);
    if EntryCount>0 then begin
     l:=0;
     h:=EntryCount;
     while l<h do begin
      m:=(l+h) shr 1;
      Offset:=16+(m*12);
      Start:=ToLONGWORD(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2],CMap^[Offset+3]);
      EndV:=ToLONGWORD(CMap^[Offset+4],CMap^[Offset+5],CMap^[Offset+6],CMap^[Offset+7]);
      if CodePointCode<Start then begin
       h:=m;
      end else if CodePointCode>EndV then begin
       l:=m+1;
      end else begin
       result:=ToLONGWORD(CMap^[Offset+8],CMap^[Offset+9],CMap^[Offset+10],CMap^[Offset+11]);
       break;
      end;
     end;
    end;
   end;
   pvTTF_CMAP_FORMAT14:begin
    result:=0;
    NumSelectors:=ToLONGWORD(CMap^[6],CMap^[7],CMap^[8],CMap^[9]);
    if NumSelectors>0 then begin
     DefaultOffset:=0;
     NonDefaultOffset:=0;
     l:=0;
     h:=NumSelectors;
     while l<h do begin
      m:=(l+h) shr 1;
      Offset:=10+(m*11);
      VarSelector:=ToUINT24(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2]);
      DefaultOffset:=ToLONGWORD(CMap^[Offset+3],CMap^[Offset+4],CMap^[Offset+5],CMap^[Offset+6]);
      NonDefaultOffset:=ToLONGWORD(CMap^[Offset+7],CMap^[Offset+8],CMap^[Offset+9],CMap^[Offset+10]);
      if CodePointCode<VarSelector then begin
       h:=m;
      end else if CodePointCode>VarSelector then begin
       l:=m+1;
      end else begin
       break;
      end;
     end;
     if (DefaultOffset>0) and (DefaultOffset<TpvUInt32(CMapLength)) then begin
      NumMappings:=ToLONGWORD(CMap^[NonDefaultOffset],CMap^[NonDefaultOffset+1],CMap^[NonDefaultOffset+2],CMap^[NonDefaultOffset+3]);
      if ((NonDefaultOffset+4)+(NumMappings*4))<TpvUInt32(CMapLength) then begin
       l:=0;
       h:=NumMappings;
       while l<h do begin
        m:=(l+h) shr 1;
        Offset:=(NonDefaultOffset+4)+(m*4);
        Unicode:=ToUINT24(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2]);
        if CodePointCode<Unicode then begin
         h:=m;
        end else if CodePointCode>(Unicode+CMap^[Offset+3]) then begin
         l:=m+1;
        end else begin
         result:=GetGlyphIndex(CodePointCode,CMapIndex+1);
         exit;
        end;
       end;
      end;
     end;
     if (NonDefaultOffset>0) and (NonDefaultOffset<TpvUInt32(CMapLength)) then begin
      NumMappings:=ToLONGWORD(CMap^[NonDefaultOffset],CMap^[NonDefaultOffset+1],CMap^[NonDefaultOffset+2],CMap^[NonDefaultOffset+3]);
      if ((NonDefaultOffset+4)+(NumMappings*5))<TpvUInt32(CMapLength) then begin
       l:=0;
       h:=NumMappings;
       while l<h do begin
        m:=(l+h) shr 1;
        Offset:=(NonDefaultOffset+4)+(m*5);
        Unicode:=ToUINT24(CMap^[Offset],CMap^[Offset+1],CMap^[Offset+2]);
        if CodePointCode<Unicode then begin
         h:=m;
        end else if CodePointCode>Unicode then begin
         l:=m+1;
        end else begin
         result:=ToWORD(CMap^[Offset+3],CMap^[Offset+4]);
         break;
        end;
       end;
      end;
     end;
    end;
   end;
   else begin
    result:=0;
   end;
  end;
 end;
 if fLastError=pvTTF_TT_ERR_CharacterMapNotPresent then begin
  if (TpvInt32(CodePointCode)<length(fCFFCodePointToGlyphIndexTable)) and
     ((fCFFCodePointToGlyphIndexTable[TpvInt32(CodePointCode)]>=0) and
      (fCFFCodePointToGlyphIndexTable[TpvInt32(CodePointCode)]<fCountGlyphs)) then begin
   fLastError:=pvTTF_TT_ERR_NoError;
   result:=fCFFCodePointToGlyphIndexTable[TpvInt32(CodePointCode)];
  end;
 end;
end;

function TpvTrueTypeFont.GetGlyphAdvanceWidth(GlyphIndex:TpvInt32):TpvInt32;
begin
 if (GlyphIndex>=0) and (GlyphIndex<fCountGlyphs) then begin
  result:=fGlyphs[GlyphIndex].AdvanceWidth;
  case fStyleIndex of
   2,3:begin
    // Thin
    dec(result,fThinBoldStrength);
   end;
   4,5:begin
    // Bold
    inc(result,fThinBoldStrength);
   end;
  end;
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetGlyphAdvanceHeight(GlyphIndex:TpvInt32):TpvInt32;
begin
 if (GlyphIndex>=0) and (GlyphIndex<fCountGlyphs) then begin
  result:=fGlyphs[GlyphIndex].AdvanceHeight;
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetGlyphLeftSideBearing(GlyphIndex:TpvInt32):TpvInt32;
begin
 if (GlyphIndex>=0) and (GlyphIndex<fCountGlyphs) then begin
  result:=fGlyphs[GlyphIndex].LeftSideBearing;
  case fStyleIndex of
   2,3:begin
    // Thin
    dec(result,fThinBoldStrength);
   end;
   4,5:begin
    // Bold
    inc(result,fThinBoldStrength);
   end;
  end;
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetGlyphRightSideBearing(GlyphIndex:TpvInt32):TpvInt32;
begin
 if ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) and (LoadGlyphData(GlyphIndex)=pvTTF_TT_ERR_NoError) then begin
  result:=fGlyphs[GlyphIndex].LeftSideBearing;
  case fStyleIndex of
   2,3:begin
    // Thin
    dec(result,fThinBoldStrength);
   end;
   4,5:begin
    // Bold
    inc(result,fThinBoldStrength);
   end;
  end;
  result:=fGlyphs[GlyphIndex].AdvanceWidth-(result+(fGlyphs[GlyphIndex].Bounds.XMax-fGlyphs[GlyphIndex].Bounds.XMin));
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetGlyphTopSideBearing(GlyphIndex:TpvInt32):TpvInt32;
begin
 if (GlyphIndex>=0) and (GlyphIndex<fCountGlyphs) then begin
  result:=fGlyphs[GlyphIndex].TopSideBearing;
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetGlyphBottomSideBearing(GlyphIndex:TpvInt32):TpvInt32;
begin
 if ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) and (LoadGlyphData(GlyphIndex)=pvTTF_TT_ERR_NoError) then begin
  result:=fGlyphs[GlyphIndex].AdvanceHeight-(fGlyphs[GlyphIndex].TopSideBearing+(fGlyphs[GlyphIndex].Bounds.YMax-fGlyphs[GlyphIndex].Bounds.YMin));
 end else begin
  result:=0;
 end;
end;

function TpvTrueTypeFont.GetKerning(Left,Right:TpvUInt32;Horizontal:boolean):TpvInt32;
var KerningIndex,KerningPairIndex,LeftIndex,RightIndex,MiddleIndex,Index:TpvInt32;
    KerningTable:PpvTrueTypeFontKerningTable;
    KerningPair:PpvTrueTypeFontKerningPair;
begin
 result:=0;
 if length(fKerningTables)>0 then begin
  for KerningIndex:=0 to length(fKerningTables)-1 do begin
   KerningTable:=@fKerningTables[KerningIndex];
   if (length(KerningTable^.KerningPairs)<>0) and
      (Horizontal=((KerningTable^.Horizontal and not KerningTable^.XStream) or
                   ((not KerningTable^.Horizontal) and KerningTable^.XStream))) then begin
    Index:=-1;
    if KerningTable^.BinarySearch then begin
     LeftIndex:=0;
     RightIndex:=length(KerningTable^.KerningPairs);
     while LeftIndex<RightIndex do begin
      MiddleIndex:=(LeftIndex+RightIndex) shr 1;
      KerningPair:=@KerningTable^.KerningPairs[MiddleIndex];
      if (Left=KerningPair^.Left) and (Right=KerningPair^.Right) then begin
       Index:=MiddleIndex;
       break;
      end else begin
       if (Left<KerningPair^.Left) or ((Left=KerningPair^.Left) and (Right<KerningPair^.Right)) then begin
        RightIndex:=MiddleIndex;
       end else begin
        LeftIndex:=MiddleIndex+1;
       end;
      end;
     end;
    end else begin
     for KerningPairIndex:=0 to length(KerningTable^.KerningPairs)-1 do begin
      KerningPair:=@KerningTable^.KerningPairs[KerningPairIndex];
      if (Left=KerningPair^.Left) and (Right=KerningPair^.Right) then begin
       Index:=KerningPairIndex;
       break;
      end;
     end;
    end;
    if Index>=0 then begin
     if KerningTable^.Minimum then begin
      if KerningTable^.KerningPairs[Index].Value>=0 then begin
       result:=Min(result,KerningTable^.KerningPairs[Index].Value);
      end else begin
       result:=Max(result,KerningTable^.KerningPairs[Index].Value);
      end;
     end else if KerningTable^.ValueOverride then begin
      result:=KerningTable^.KerningPairs[Index].Value;
     end else begin
      inc(result,KerningTable^.KerningPairs[Index].Value);
     end;
    end;
   end;
  end;
 end;
end;

function TpvTrueTypeFont.GetScaleFactor:TpvDouble;
begin
 if fSize<0 then begin
  result:=(-fSize)/fUnitsPerEm;
 end else begin
  result:=(fSize*fTargetPPI)/(fUnitsPerEm*72);
 end;
end;

function TpvTrueTypeFont.GetScaleFactorFixed:TpvInt32;
begin
 if fSize<0 then begin
  result:=(TpvInt64(-fSize)*$10000) div fUnitsPerEm;
 end else begin
  result:=((TpvInt64(fSize*fTargetPPI)*$10000)+(fUnitsPerEm*36)) div (fUnitsPerEm*72);
 end;
end;

function TpvTrueTypeFont.Scale(Value:TpvInt32):TpvInt32;
begin
 if fSize<0 then begin
  if Value>=0 then begin
   result:=((Value*TpvInt64((-fSize)*64))+SARLongint(fUnitsPerEm+1,1)) div fUnitsPerEm;
  end else begin
   result:=((Value*TpvInt64((-fSize)*64))-SARLongint(fUnitsPerEm+1,1)) div fUnitsPerEm;
  end;
 end else begin
  if Value>=0 then begin
   result:=((Value*TpvInt64(fSize*64*fTargetPPI))+SARLongint((fUnitsPerEm*72)+1,1)) div (fUnitsPerEm*72);
  end else begin
   result:=((Value*TpvInt64(fSize*64*fTargetPPI))-SARLongint((fUnitsPerEm*72)+1,1)) div (fUnitsPerEm*72);
  end;
 end;
end;

function TpvTrueTypeFont.FloatScale(Value:TpvDouble):TpvDouble;
begin
 if fSize<0 then begin
  result:=(Value*TpvInt64((-fSize)*64))/fUnitsPerEm;
 end else begin
  result:=(Value*TpvInt64(fSize*64*fTargetPPI))/(fUnitsPerEm*72);
 end;
end;

function TpvTrueTypeFont.GetScale:TpvInt32;
begin
 if fSize<0 then begin
  result:=(-fSize)*64;
 end else begin
  result:=((fSize*64*fTargetPPI)+36) div 72;
 end;
end;

function TpvTrueTypeFont.ScaleRound(Value:TpvInt32):TpvInt32;
begin
 if fSize<0 then begin
  if Value>=0 then begin
   result:=(Value+SARLongint(fUnitsPerPixel,1)) div fUnitsPerPixel;
  end else begin
   result:=(Value-SARLongint(fUnitsPerPixel,1)) div fUnitsPerPixel;
  end;
 end else begin
  if Value>=0 then begin
   result:=((Value*fTargetPPI)+SARLongint(fUnitsPerEm*72,1)) div (fUnitsPerEm*72);
  end else begin
   result:=((Value*fTargetPPI)-SARLongint(fUnitsPerEm*72,1)) div (fUnitsPerEm*72);
  end;
 end;
end;

function TpvTrueTypeFont.IsPostScriptGlyph(const GlyphIndex:TpvInt32):boolean;
begin
 if ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) and not fGlyphs[GlyphIndex].Locked then begin
  fGlyphs[GlyphIndex].Locked:=true;
  try
   result:=fGlyphs[GlyphIndex].PostScriptPolygon.CountCommands>0;
  finally
   fGlyphs[GlyphIndex].Locked:=false;
  end;
 end else begin
  result:=false;
 end;
end;

procedure TpvTrueTypeFont.ResetGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer);
begin
 GlyphBuffer.CountPoints:=0;
 GlyphBuffer.CountIndices:=0;
end;

procedure TpvTrueTypeFont.TransformGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer;GlyphStartPointIndex,StartIndex,EndIndex:TpvInt32);
var Sum,Direction,StartPointIndex,i,j,x,y,xs,ys:TpvInt32;
    pprev,pfirst,pnext,pcur,pin,pout:TpvTrueTypeFontGlyphPoint;
    ain,aout,ad,s:TpvDouble;
    Matrix:TMatrix;
begin
 Sum:=0;
 StartPointIndex:=GlyphStartPointIndex;
 for i:=StartIndex to EndIndex do begin
  if ((GlyphBuffer.EndPointIndices[i]-StartPointIndex)+1)>0 then begin
   x:=GlyphBuffer.Points[StartPointIndex].x;
   y:=GlyphBuffer.Points[StartPointIndex].y;
   xs:=x;
   ys:=y;
   for j:=StartPointIndex to GlyphBuffer.EndPointIndices[i] do begin
    inc(Sum,(x*GlyphBuffer.Points[j].y)-(y*GlyphBuffer.Points[j].x));
    x:=GlyphBuffer.Points[j].x;
    y:=GlyphBuffer.Points[j].y;
   end;
   inc(Sum,(x*ys)-(y*xs));
  end;
  StartPointIndex:=GlyphBuffer.EndPointIndices[i]+1;
 end;
 if Sum<0 then begin
  Direction:=1;
 end else begin
  Direction:=-1;
 end;
 StartPointIndex:=GlyphStartPointIndex;
 for i:=StartIndex to EndIndex do begin
  if ((GlyphBuffer.EndPointIndices[i]-StartPointIndex)+1)>1 then begin
   if fStyleIndex in [2,3,4,5] then begin
    // Thin/Bold
    pfirst:=GlyphBuffer.Points[StartPointIndex];
    pprev:=GlyphBuffer.Points[GlyphBuffer.EndPointIndices[i]];
    pcur:=pfirst;
    for j:=StartPointIndex to GlyphBuffer.EndPointIndices[i] do begin
     if (j+1)<=GlyphBuffer.EndPointIndices[i] then begin
      pnext:=GlyphBuffer.Points[j+1];
     end else begin
      pnext:=pfirst;
     end;
     pin.x:=pcur.x-pprev.x;
     pin.y:=pcur.y-pprev.y;
     pout.x:=pnext.x-pcur.x;
     pout.y:=pnext.y-pcur.y;
     ain:=arctan2(pin.y,pin.x);
     aout:=arctan2(pout.y,pout.x);
     ad:=aout-ain;
     s:=cos(ad*0.5);
     if abs(s)<=0.25 then begin
      pin.x:=0;
      pin.y:=0;
     end else begin
      pin.x:=trunc(SARLongint(fThinBoldStrength,1)/s);
      pin.y:=0;
      if fStyleIndex in [2,3] then begin
       // Thin
       Matrix:=MatrixRotate(((ain+(ad*0.5)-((pi*0.5)*Direction))*rad2deg));
      end else begin
       // Bold
       Matrix:=MatrixRotate(((ain+(ad*0.5)+((pi*0.5)*Direction))*rad2deg));
      end;
      ApplyMatrixToXY(Matrix,pin.x,pin.y);
     end;
     GlyphBuffer.Points[j].x:=pcur.x+fThinBoldStrength+pin.x;
     GlyphBuffer.Points[j].y:=pcur.y+fThinBoldStrength+pin.y;
     pprev:=pcur;
     pcur:=pnext;
    end;
   end;
   if fStyleIndex in [1,3,5] then begin
    // Italic
    for j:=StartPointIndex to GlyphBuffer.EndPointIndices[i] do begin
     // Rotate only x coord by about 12 degrees
     Matrix[0]:=1;
     Matrix[1]:=0;
     Matrix[2]:=0.375;
     Matrix[3]:=1;
     Matrix[4]:=0;
     Matrix[5]:=0;
     ApplyMatrixToXY(Matrix,GlyphBuffer.Points[j].x,GlyphBuffer.Points[j].y);
    end;
   end;
  end;
  StartPointIndex:=GlyphBuffer.EndPointIndices[i]+1;
 end;
end;

procedure TpvTrueTypeFont.FillGlyphBuffer(var GlyphBuffer:TpvTrueTypeFontGlyphBuffer;const GlyphIndex:TpvInt32);
const fi65536=1.0/65536;
var CountSubGlyphs,SubGlyphArrayIndex,PointIndex,cx,cy,OriginalCount,DstCount,SrcCount,l,Offset,Count,EndOffset:TpvInt32;
    SubGlyph:PpvTrueTypeFontGlyphCompositeSubGlyph;
    HaveScale:boolean;
    p:TpvTrueTypeFontGlyphPoint;
begin
 if ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) and not fGlyphs[GlyphIndex].Locked then begin

  fGlyphs[GlyphIndex].Locked:=true;
  try

   if LoadGlyphData(GlyphIndex)=pvTTF_TT_ERR_NoError then begin

    if GlyphBuffer.CountPoints=0 then begin
     GlyphBuffer.Bounds:=fGlyphs[GlyphIndex].Bounds;
     GlyphBuffer.Bounds.XMin:=Scale(GlyphBuffer.Bounds.XMin);
     GlyphBuffer.Bounds.YMin:=Scale(GlyphBuffer.Bounds.YMin);
     GlyphBuffer.Bounds.XMax:=Scale(GlyphBuffer.Bounds.XMax);
     GlyphBuffer.Bounds.YMax:=Scale(GlyphBuffer.Bounds.YMax);
    end;

    CountSubGlyphs:=length(fGlyphs[GlyphIndex].CompositeSubGlyphs);
    if CountSubGlyphs>0 then begin

     OriginalCount:=GlyphBuffer.CountPoints;

     EndOffset:=GlyphBuffer.CountIndices;

     for SubGlyphArrayIndex:=0 to CountSubGlyphs-1 do begin

      SubGlyph:=@fGlyphs[GlyphIndex].CompositeSubGlyphs[SubGlyphArrayIndex];

      Offset:=GlyphBuffer.CountPoints;

      FillGlyphBuffer(GlyphBuffer,SubGlyph^.Glyph);

      if ((SubGlyph^.Flags and USE_MY_METRICS)<>0) and (SubGlyph^.Glyph<TpvUInt32(fCountGlyphs)) then begin
       GlyphBuffer.Bounds:=fGlyphs[SubGlyph^.Glyph].Bounds;
       GlyphBuffer.Bounds.XMin:=Scale(GlyphBuffer.Bounds.XMin);
       GlyphBuffer.Bounds.YMin:=Scale(GlyphBuffer.Bounds.YMin);
       GlyphBuffer.Bounds.XMax:=Scale(GlyphBuffer.Bounds.XMax);
       GlyphBuffer.Bounds.YMax:=Scale(GlyphBuffer.Bounds.YMax);
      end;

      HaveScale:=(SubGlyph^.Flags and (WE_HAVE_A_SCALE or WE_HAVE_AN_XY_SCALE or WE_HAVE_A_2X2))<>0;

      if HaveScale then begin
       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        Transform(GlyphBuffer.Points[PointIndex].x,GlyphBuffer.Points[PointIndex].y,SubGlyph^.xx,SubGlyph^.yx,SubGlyph^.xy,SubGlyph^.yy);
       end;
      end;

      if (SubGlyph^.Flags and ARGS_ARE_XY_VALUES)<>0 then begin
       cx:=SubGlyph^.Arg1;
       cy:=SubGlyph^.Arg2;
      end else if (SubGlyph^.Arg1>=0) and (SubGlyph^.Arg1<OriginalCount) and
                  (SubGlyph^.Arg2>=OriginalCount) and ((SubGlyph^.Arg2-OriginalCount)<GlyphBuffer.CountPoints) then begin
       cx:=GlyphBuffer.Points[SubGlyph^.Arg1].x-GlyphBuffer.Points[SubGlyph^.Arg2+OriginalCount].x;
       cy:=GlyphBuffer.Points[SubGlyph^.Arg1].y-GlyphBuffer.Points[SubGlyph^.Arg2+OriginalCount].y;
      end else begin
       cx:=0;
       cy:=0;
      end;

      if (cx<>0) or (cy<>0) then begin
       if HaveScale and ((SubGlyph^.Flags and UNSCALED_COMPONENT_OFFSET)=0) then begin
 {$ifdef cpuarm}
        cx:=MulFix(cx,SQRTFixed(MulFix(SubGlyph^.xx,SubGlyph^.xx)+MulFix(SubGlyph^.xy,SubGlyph^.xy)));
        cy:=MulFix(cy,SQRTFixed(MulFix(SubGlyph^.yx,SubGlyph^.yx)+MulFix(SubGlyph^.yy,SubGlyph^.yy)));
 {$else}
        cx:=round(cx*sqrt(sqr(SubGlyph^.xx*fi65536)+sqr(SubGlyph^.xy*fi65536)));
        cy:=round(cy*sqrt(sqr(SubGlyph^.yx*fi65536)+sqr(SubGlyph^.yy*fi65536)));
 {$endif}
       end;
      end;

      if fHinting and ((cx<>0) or (cy<>0)) then begin
       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.InFontUnitsPoints[PointIndex].x:=GlyphBuffer.InFontUnitsPoints[PointIndex].x+cx;
        GlyphBuffer.InFontUnitsPoints[PointIndex].y:=GlyphBuffer.InFontUnitsPoints[PointIndex].y+cy;
       end;
      end;

      cx:=Scale(cx);
      cy:=Scale(cy);

      if (SubGlyph^.Flags and ROUND_XY_TO_GRID)<>0 then begin
       cx:=(cx+32) and not 63;
       cy:=(cy+32) and not 63;
      end;

      if (cx<>0) or (cy<>0) then begin
       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.Points[PointIndex].x:=GlyphBuffer.Points[PointIndex].x+cx;
        GlyphBuffer.Points[PointIndex].y:=GlyphBuffer.Points[PointIndex].y+cy;
       end;
      end;

     end;

     if (fHinting and assigned(fByteCodeInterpreter)) and not fIgnoreByteCodeInterpreter then begin
      try

       Offset:=OriginalCount;

       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.UnhintedPoints[PointIndex]:=GlyphBuffer.Points[PointIndex];
       end;

       Count:=(GlyphBuffer.CountPoints-Offset)+4;
       SetLength(fByteCodeInterpreterParameters.pCurrent,Count);
       SetLength(fByteCodeInterpreterParameters.pUnhinted,Count);
       SetLength(fByteCodeInterpreterParameters.pInFontUnits,Count);
       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        fByteCodeInterpreterParameters.pCurrent[PointIndex-Offset]:=GlyphBuffer.Points[PointIndex];
        fByteCodeInterpreterParameters.pUnhinted[PointIndex-Offset]:=GlyphBuffer.UnhintedPoints[PointIndex];
        fByteCodeInterpreterParameters.pInFontUnits[PointIndex-Offset]:=GlyphBuffer.InFontUnitsPoints[PointIndex];
       end;

       p.x:=fGlyphs[GlyphIndex].Bounds.XMin-fGlyphs[GlyphIndex].LeftSideBearing;
       p.y:=0;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-4]:=p;
       fByteCodeInterpreterParameters.pUnhinted[Count-4]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-4]:=p;

       p.x:=(fGlyphs[GlyphIndex].Bounds.XMin-fGlyphs[GlyphIndex].LeftSideBearing)+fGlyphs[GlyphIndex].AdvanceWidth;
       p.y:=0;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-3]:=p;
       p.x:=Scale(p.x);
       fByteCodeInterpreterParameters.pUnhinted[Count-3]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-3]:=p;

       p.x:=0;
       p.y:=fGlyphs[GlyphIndex].Bounds.YMax+fGlyphs[GlyphIndex].TopSideBearing;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-2]:=p;
       p.y:=Scale(p.y);
       fByteCodeInterpreterParameters.pUnhinted[Count-2]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-2]:=p;

       p.x:=0;
       p.y:=(fGlyphs[GlyphIndex].Bounds.YMax+fGlyphs[GlyphIndex].TopSideBearing)-fGlyphs[GlyphIndex].AdvanceHeight;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-1]:=p;
       p.y:=Scale(p.y);
       fByteCodeInterpreterParameters.pUnhinted[Count-1]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-1]:=p;

       Count:=GlyphBuffer.CountIndices-EndOffset;
       SetLength(fByteCodeInterpreterParameters.Ends,Count);
       for PointIndex:=EndOffset to GlyphBuffer.CountIndices-1 do begin
        fByteCodeInterpreterParameters.Ends[PointIndex-EndOffset]:=GlyphBuffer.EndPointIndices[PointIndex]-EndOffset;
       end;

{$ifdef ttfdebug}
       writeln('GLYF');
       writeln('====');
{$endif}
       fByteCodeInterpreter.Run(fGlyphs[GlyphIndex].Instructions,@fByteCodeInterpreterParameters);
{$ifdef ttfdebug}
       writeln;
{$endif}

       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.Points[PointIndex]:=fByteCodeInterpreterParameters.pCurrent[PointIndex-Offset];
        GlyphBuffer.UnhintedPoints[PointIndex]:=fByteCodeInterpreterParameters.pUnhinted[PointIndex-Offset];
        GlyphBuffer.InFontUnitsPoints[PointIndex]:=fByteCodeInterpreterParameters.pInFontUnits[PointIndex-Offset];
       end;

      except
       fByteCodeInterpreter:=nil;
       fIgnoreByteCodeInterpreter:=true;
      end;
     end;

    end else begin

     Offset:=GlyphBuffer.CountPoints;
     DstCount:=Offset;
     SrcCount:=length(fGlyphs[GlyphIndex].Points);
     if SrcCount>0 then begin
      l:=DstCount+SrcCount;
      if (l+1)>=length(GlyphBuffer.Points) then begin
       SetLength(GlyphBuffer.Points,RoundUpToPowerOfTwo(l+1));
      end;
      if fHinting then begin
       if (l+1)>=length(GlyphBuffer.UnhintedPoints) then begin
        SetLength(GlyphBuffer.UnhintedPoints,RoundUpToPowerOfTwo(l+1));
       end;
       if (l+1)>=length(GlyphBuffer.InFontUnitsPoints) then begin
        SetLength(GlyphBuffer.InFontUnitsPoints,RoundUpToPowerOfTwo(l+1));
       end;
      end;
      Move(fGlyphs[GlyphIndex].Points[0],GlyphBuffer.Points[DstCount],SrcCount*SizeOf(TpvTrueTypeFontGlyphPoint));
      if fHinting then begin
       Move(fGlyphs[GlyphIndex].Points[0],GlyphBuffer.UnhintedPoints[DstCount],SrcCount*SizeOf(TpvTrueTypeFontGlyphPoint));
       Move(fGlyphs[GlyphIndex].Points[0],GlyphBuffer.InFontUnitsPoints[DstCount],SrcCount*SizeOf(TpvTrueTypeFontGlyphPoint));
      end;
      GlyphBuffer.CountPoints:=l;
     end;

     EndOffset:=GlyphBuffer.CountIndices;
     DstCount:=EndOffset;
     SrcCount:=length(fGlyphs[GlyphIndex].EndPointIndices);
     if SrcCount>0 then begin
      l:=DstCount+SrcCount;
      if (l+1)>=length(GlyphBuffer.EndPointIndices) then begin
       SetLength(GlyphBuffer.EndPointIndices,RoundUpToPowerOfTwo(l+1));
      end;
      Move(fGlyphs[GlyphIndex].EndPointIndices[0],GlyphBuffer.EndPointIndices[DstCount],SrcCount*SizeOf(TpvInt32));
      GlyphBuffer.CountIndices:=l;
      for l:=0 to SrcCount-1 do begin
       inc(GlyphBuffer.EndPointIndices[l+DstCount],Offset);
      end;
     end;

     if fStyleIndex<>0 then begin
      TransformGlyphBuffer(GlyphBuffer,Offset,DstCount,GlyphBuffer.CountIndices-1);
     end;

     for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
      GlyphBuffer.Points[PointIndex].x:=Scale(GlyphBuffer.Points[PointIndex].x);
      GlyphBuffer.Points[PointIndex].y:=Scale(GlyphBuffer.Points[PointIndex].y);
     end;

     if (fHinting and assigned(fByteCodeInterpreter)) and not fIgnoreByteCodeInterpreter then begin
      try

       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.UnhintedPoints[PointIndex]:=GlyphBuffer.Points[PointIndex];
       end;

       Count:=(GlyphBuffer.CountPoints-Offset)+4;
       SetLength(fByteCodeInterpreterParameters.pCurrent,Count);
       SetLength(fByteCodeInterpreterParameters.pUnhinted,Count);
       SetLength(fByteCodeInterpreterParameters.pInFontUnits,Count);
       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        fByteCodeInterpreterParameters.pCurrent[PointIndex-Offset]:=GlyphBuffer.Points[PointIndex];
        fByteCodeInterpreterParameters.pUnhinted[PointIndex-Offset]:=GlyphBuffer.UnhintedPoints[PointIndex];
        fByteCodeInterpreterParameters.pInFontUnits[PointIndex-Offset]:=GlyphBuffer.InFontUnitsPoints[PointIndex];
       end;

       p.x:=fGlyphs[GlyphIndex].Bounds.XMin-fGlyphs[GlyphIndex].LeftSideBearing;
       p.y:=0;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-4]:=p;
       p.x:=Scale(p.x);
       fByteCodeInterpreterParameters.pUnhinted[Count-4]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-4]:=p;

       p.x:=(fGlyphs[GlyphIndex].Bounds.XMin-fGlyphs[GlyphIndex].LeftSideBearing)+fGlyphs[GlyphIndex].AdvanceWidth;
       p.y:=0;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-3]:=p;
       p.x:=Scale(p.x);
       fByteCodeInterpreterParameters.pUnhinted[Count-3]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-3]:=p;

       p.x:=0;
       p.y:=fGlyphs[GlyphIndex].Bounds.YMax+fGlyphs[GlyphIndex].TopSideBearing;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-2]:=p;
       p.y:=Scale(p.y);
       fByteCodeInterpreterParameters.pUnhinted[Count-2]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-2]:=p;

       p.x:=0;
       p.y:=(fGlyphs[GlyphIndex].Bounds.YMax+fGlyphs[GlyphIndex].TopSideBearing)-fGlyphs[GlyphIndex].AdvanceHeight;
       p.Flags:=0;
       fByteCodeInterpreterParameters.pInFontUnits[Count-1]:=p;
       p.y:=Scale(p.y);
       fByteCodeInterpreterParameters.pUnhinted[Count-1]:=p;
       fByteCodeInterpreterParameters.pCurrent[Count-1]:=p;

       Count:=GlyphBuffer.CountIndices-EndOffset;
       SetLength(fByteCodeInterpreterParameters.Ends,Count);
       for PointIndex:=EndOffset to GlyphBuffer.CountIndices-1 do begin
        fByteCodeInterpreterParameters.Ends[PointIndex-EndOffset]:=GlyphBuffer.EndPointIndices[PointIndex]-EndOffset;
       end;

{$ifdef ttfdebug}
       writeln('GLYF');
       writeln('====');
{$endif}
       fByteCodeInterpreter.Run(fGlyphs[GlyphIndex].Instructions,@fByteCodeInterpreterParameters);
{$ifdef ttfdebug}
       writeln;
{$endif}

       for PointIndex:=Offset to GlyphBuffer.CountPoints-1 do begin
        GlyphBuffer.Points[PointIndex]:=fByteCodeInterpreterParameters.pCurrent[PointIndex-Offset];
        GlyphBuffer.UnhintedPoints[PointIndex]:=fByteCodeInterpreterParameters.pUnhinted[PointIndex-Offset];
        GlyphBuffer.InFontUnitsPoints[PointIndex]:=fByteCodeInterpreterParameters.pInFontUnits[PointIndex-Offset];
       end;

      except
       fByteCodeInterpreter:=nil;
       fIgnoreByteCodeInterpreter:=true;
      end;
     end;

    end;

   end;

  finally
   fGlyphs[GlyphIndex].Locked:=false;
  end;

 end;

end;

procedure TpvTrueTypeFont.ResetPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer);
begin
 PolygonBuffer.CountCommands:=0;
end;

procedure TpvTrueTypeFont.FillPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const GlyphBuffer:TpvTrueTypeFontGlyphBuffer);
var StartPointIndex,CommandIndex,CommandCount,i,j,fx,fy,lx,ly,cx,cy,x,y,MiddleX,MiddleY,MaxY:TpvInt32;
    OnCurve:boolean;
begin
 CommandCount:=PolygonBuffer.CountCommands;
 StartPointIndex:=0;
 MaxY:=Scale(fMaxY);
 for i:=0 to GlyphBuffer.CountIndices-1 do begin
  if (GlyphBuffer.EndPointIndices[i]-StartPointIndex)>=0 then begin
   fx:=GlyphBuffer.Points[StartPointIndex].x*4;
   fy:=(MaxY-GlyphBuffer.Points[StartPointIndex].y)*4;
   lx:=GlyphBuffer.Points[GlyphBuffer.EndPointIndices[i]].x*4;
   ly:=(MaxY-GlyphBuffer.Points[GlyphBuffer.EndPointIndices[i]].y)*4;
   cx:=fx;
   cy:=fy;
   OnCurve:=(GlyphBuffer.Points[StartPointIndex].Flags and pvTTF_PathFlag_OnCurve)<>0;
   if (not OnCurve) and ((GlyphBuffer.Points[GlyphBuffer.EndPointIndices[i]].Flags and pvTTF_PathFlag_OnCurve)=0) then begin
    lx:=SARLongint((fx+lx)+1,1);
    ly:=SARLongint((fy+ly)+1,1);
   end;
   CommandIndex:=CommandCount;
   inc(CommandCount);
   if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
    SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
   end;
   PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.MoveTo;
   PolygonBuffer.Commands[CommandIndex].Points[0].x:=fx;
   PolygonBuffer.Commands[CommandIndex].Points[0].y:=fy;
   for j:=StartPointIndex+1 to GlyphBuffer.EndPointIndices[i] do begin
    x:=GlyphBuffer.Points[j].x*4;
    y:=(MaxY-GlyphBuffer.Points[j].y)*4;
    if OnCurve then begin
     OnCurve:=(GlyphBuffer.Points[j].Flags and pvTTF_PathFlag_OnCurve)<>0;
     if OnCurve then begin
      CommandIndex:=CommandCount;
      inc(CommandCount);
      if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
       SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
      end;
      PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.LineTo;
      PolygonBuffer.Commands[CommandIndex].Points[0].x:=x;
      PolygonBuffer.Commands[CommandIndex].Points[0].y:=y;
     end else begin
      cx:=x;
      cy:=y;
     end;
    end else begin
     OnCurve:=(GlyphBuffer.Points[j].Flags and pvTTF_PathFlag_OnCurve)<>0;
     if OnCurve then begin
      CommandIndex:=CommandCount;
      inc(CommandCount);
      if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
       SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
      end;
      PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo;
      PolygonBuffer.Commands[CommandIndex].Points[0].x:=cx;
      PolygonBuffer.Commands[CommandIndex].Points[0].y:=cy;
      PolygonBuffer.Commands[CommandIndex].Points[1].x:=x;
      PolygonBuffer.Commands[CommandIndex].Points[1].y:=y;
     end else begin
      MiddleX:=SARLongint((cx+x)+1,1);
      MiddleY:=SARLongint((cy+y)+1,1);
      CommandIndex:=CommandCount;
      inc(CommandCount);
      if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
       SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
      end;
      PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo;
      PolygonBuffer.Commands[CommandIndex].Points[0].x:=cx;
      PolygonBuffer.Commands[CommandIndex].Points[0].y:=cy;
      PolygonBuffer.Commands[CommandIndex].Points[1].x:=MiddleX;
      PolygonBuffer.Commands[CommandIndex].Points[1].y:=MiddleY;
      cx:=x;
      cy:=y;
     end;
    end;
   end;
   if (GlyphBuffer.Points[StartPointIndex].Flags and pvTTF_PathFlag_OnCurve)<>0 then begin
    if OnCurve then begin
     CommandIndex:=CommandCount;
     inc(CommandCount);
     if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
      SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
     end;
     PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.LineTo;
     PolygonBuffer.Commands[CommandIndex].Points[0].x:=fx;
     PolygonBuffer.Commands[CommandIndex].Points[0].y:=fy;
    end else begin
     CommandIndex:=CommandCount;
     inc(CommandCount);
     if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
      SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
     end;
     PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo;
     PolygonBuffer.Commands[CommandIndex].Points[0].x:=cx;
     PolygonBuffer.Commands[CommandIndex].Points[0].y:=cy;
     PolygonBuffer.Commands[CommandIndex].Points[1].x:=fx;
     PolygonBuffer.Commands[CommandIndex].Points[1].y:=fy;
    end;
   end else begin
    if not OnCurve then begin
     CommandIndex:=length(PolygonBuffer.Commands);
     SetLength(PolygonBuffer.Commands,CommandIndex+1);
     PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo;
     PolygonBuffer.Commands[CommandIndex].Points[0].x:=cx;
     PolygonBuffer.Commands[CommandIndex].Points[0].y:=cy;
     PolygonBuffer.Commands[CommandIndex].Points[1].x:=lx;
     PolygonBuffer.Commands[CommandIndex].Points[1].y:=ly;
    end;
   end;
  end;
  StartPointIndex:=GlyphBuffer.EndPointIndices[i]+1;
 end;
 CommandIndex:=CommandCount;
 inc(CommandCount);
 if (CommandCount+1)>=length(PolygonBuffer.Commands) then begin
  SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
 end;
 PolygonBuffer.Commands[CommandIndex].CommandType:=TpvTrueTypeFontPolygonCommandType.Close;
 PolygonBuffer.CountCommands:=CommandCount;
end;

procedure TpvTrueTypeFont.FillPostScriptPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const GlyphIndex:TpvInt32);
var CommandIndex,BaseIndex:TpvInt32;
    Glyph:PpvTrueTypeFontGlyph;
    Command:PpvTrueTypeFontPolygonCommand;
begin
 if ((GlyphIndex>=0) and (GlyphIndex<fCountGlyphs)) and not fGlyphs[GlyphIndex].Locked then begin

  Glyph:=@fGlyphs[GlyphIndex];

  fGlyphs[GlyphIndex].Locked:=true;
  try

   BaseIndex:=PolygonBuffer.CountCommands;
   inc(PolygonBuffer.CountCommands,Glyph^.PostScriptPolygon.CountCommands);
   if length(PolygonBuffer.Commands)<PolygonBuffer.CountCommands then begin
    if PolygonBuffer.CountCommands=Glyph^.PostScriptPolygon.CountCommands then begin
     SetLength(PolygonBuffer.Commands,PolygonBuffer.CountCommands);
    end else begin
     SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(PolygonBuffer.CountCommands));
    end;
   end;

   for CommandIndex:=0 to Glyph^.PostScriptPolygon.CountCommands-1 do begin
    Command:=@PolygonBuffer.Commands[BaseIndex+CommandIndex];
    Command^:=Glyph^.PostScriptPolygon.Commands[CommandIndex];
    case Command^.CommandType of
     TpvTrueTypeFontPolygonCommandType.MoveTo:begin
      Command^.Points[0].x:=FloatScale(Command^.Points[0].x);
      Command^.Points[0].y:=FloatScale(Command^.Points[0].y);
     end;
     TpvTrueTypeFontPolygonCommandType.LineTo:begin
      Command^.Points[0].x:=FloatScale(Command^.Points[0].x);
      Command^.Points[0].y:=FloatScale(Command^.Points[0].y);
     end;
     TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo:begin
      Command^.Points[0].x:=FloatScale(Command^.Points[0].x);
      Command^.Points[0].y:=FloatScale(Command^.Points[0].y);
      Command^.Points[1].x:=FloatScale(Command^.Points[1].x);
      Command^.Points[1].y:=FloatScale(Command^.Points[1].y);
     end;
     TpvTrueTypeFontPolygonCommandType.CubicCurveTo:begin
      Command^.Points[0].x:=FloatScale(Command^.Points[0].x);
      Command^.Points[0].y:=FloatScale(Command^.Points[0].y);
      Command^.Points[1].x:=FloatScale(Command^.Points[1].x);
      Command^.Points[1].y:=FloatScale(Command^.Points[1].y);
      Command^.Points[2].x:=FloatScale(Command^.Points[2].x);
      Command^.Points[2].y:=FloatScale(Command^.Points[2].y);
     end;
     TpvTrueTypeFontPolygonCommandType.Close:begin
     end;
    end;
   end;

  finally
   fGlyphs[GlyphIndex].Locked:=false;
  end;

 end;
end;

procedure TpvTrueTypeFont.FillTextPolygonBuffer(var PolygonBuffer:TpvTrueTypeFontPolygonBuffer;const Text:TpvUTF8String;const StartX:TpvInt32=0;const StartY:TpvInt32=0);
var TextIndex,CurrentGlyph,LastGlyph,CurrentX,CurrentY,OffsetX,OffsetY,
    CommandCount,CommandIndex,CommandBaseIndex:TpvInt32;
    GlyphBuffer:TpvTrueTypeFontGlyphBuffer;
    GlyphPolygonBuffer:TpvTrueTypeFontPolygonBuffer;
    Command:PpvTrueTypeFontPolygonCommand;
begin
 Initialize(GlyphBuffer);
 Initialize(GlyphPolygonBuffer);
 try

  CommandCount:=PolygonBuffer.CountCommands;

  CurrentX:=StartX;
  CurrentY:=StartY;

  LastGlyph:=-1;

  TextIndex:=1;
  while TextIndex<=length(Text) do begin

   CurrentGlyph:=GetGlyphIndex(PUCUUTF8CodeUnitGetCharAndIncFallback(Text,TextIndex));
   if (CurrentGlyph>0) or (CurrentGlyph<fCountGlyphs) then begin

    if (LastGlyph>=0) and (LastGlyph<fCountGlyphs) then begin
     inc(CurrentX,GetKerning(LastGlyph,CurrentGlyph,true));
     inc(CurrentY,GetKerning(LastGlyph,CurrentGlyph,false));
    end;

{   if LastGlyph<0 then begin
     dec(CurrentX,GetGlyphLeftSideBearing(CurrentGlyph));
     dec(CurrentY,GetGlyphTopSideBearing(CurrentGlyph));
    end;}

    if IsPostScriptGlyph(CurrentGlyph) then begin

     ResetPolygonBuffer(GlyphPolygonBuffer);
     FillPostScriptPolygonBuffer(GlyphPolygonBuffer,CurrentGlyph);

    end else begin

     ResetGlyphBuffer(GlyphBuffer);
     FillGlyphBuffer(GlyphBuffer,CurrentGlyph);

     ResetPolygonBuffer(GlyphPolygonBuffer);
     FillPolygonBuffer(GlyphPolygonBuffer,GlyphBuffer);

    end;

    CommandBaseIndex:=CommandCount;
    inc(CommandCount,GlyphPolygonBuffer.CountCommands);
    if CommandCount>=length(PolygonBuffer.Commands) then begin
     SetLength(PolygonBuffer.Commands,RoundUpToPowerOfTwo(CommandCount+1));
    end;

    // *4 because from 1/64 truetype font units to 1/256 rasterizer units
    OffsetX:=Scale(CurrentX)*4;
    OffsetY:=Scale(CurrentY)*4;

    for CommandIndex:=0 to GlyphPolygonBuffer.CountCommands-1 do begin
     Command:=@PolygonBuffer.Commands[CommandBaseIndex+CommandIndex];
     Command^:=GlyphPolygonBuffer.Commands[CommandIndex];
     Command^.Points[0].x:=Command^.Points[0].x+OffsetX;
     Command^.Points[0].y:=Command^.Points[0].y+OffsetY;
     Command^.Points[1].x:=Command^.Points[1].x+OffsetX;
     Command^.Points[1].y:=Command^.Points[1].y+OffsetY;
     Command^.Points[2].x:=Command^.Points[2].x+OffsetX;
     Command^.Points[2].y:=Command^.Points[2].y+OffsetY;
    end;

    inc(CurrentX,GetGlyphAdvanceWidth(CurrentGlyph)+fLetterSpacingX);
    inc(CurrentY,GetGlyphAdvanceHeight(CurrentGlyph)+fLetterSpacingY);

   end;

   LastGlyph:=CurrentGlyph;

  end;

  PolygonBuffer.CountCommands:=CommandCount;

 finally
  Finalize(GlyphBuffer);
  Finalize(GlyphPolygonBuffer);
 end;
end;

function TpvTrueTypeFont.GetStyleIndex(Thin,Bold,Italic:boolean):TpvInt32;
begin
 if Bold then begin
  if Italic then begin
   result:=5;
  end else begin
   result:=4;
  end;
 end else if Thin then begin
  if Italic then begin
   result:=3;
  end else begin
   result:=2;
  end;
 end else begin
  if Italic then begin
   result:=1;
  end else begin
   result:=0;
  end;
 end;
end;

function TpvTrueTypeFont.TextWidth(const aText:TpvUTF8String):TpvInt32;
var TextIndex,CurrentGlyph,LastGlyph,Width,NewWidth:TpvInt32;
begin
 result:=0;
 Width:=0;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentGlyph:=GetGlyphIndex(PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex));
  if (CurrentGlyph>0) or (CurrentGlyph<fCountGlyphs) then begin
   if (LastGlyph>=0) and (LastGlyph<fCountGlyphs) then begin
    inc(result,GetKerning(LastGlyph,CurrentGlyph,true));
   end;
{  if LastGlyph<0 then begin
    dec(result,GetGlyphLeftSideBearing(CurrentGlyph));
   end;}
   if LoadGlyphData(CurrentGlyph)=pvTTF_TT_ERR_NoError then begin
    NewWidth:=result+(fGlyphs[CurrentGlyph].Bounds.XMax-fGlyphs[CurrentGlyph].Bounds.XMin);
    if Width<NewWidth then begin
     Width:=NewWidth;
    end;
   end;
   inc(result,GetGlyphAdvanceWidth(CurrentGlyph)+fLetterSpacingX);
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if result=0 then begin
  result:=fMaxX-fMinX;
 end;
 if result<Width then begin
  result:=Width;
 end;
end;

function TpvTrueTypeFont.TextHeight(const aText:TpvUTF8String):TpvInt32;
var TextIndex,CurrentGlyph,LastGlyph,Height,NewHeight:TpvInt32;
begin
 result:=0;
 Height:=0;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentGlyph:=GetGlyphIndex(PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex));
  if (CurrentGlyph>0) or (CurrentGlyph<fCountGlyphs) then begin
   if (LastGlyph>=0) and (LastGlyph<fCountGlyphs) then begin
    inc(result,GetKerning(LastGlyph,CurrentGlyph,false));
   end;
{  if LastGlyph<0 then begin
    dec(result,GetGlyphTopSideBearing(CurrentGlyph));
   end;}
   if LoadGlyphData(CurrentGlyph)=pvTTF_TT_ERR_NoError then begin
    NewHeight:=result+(fGlyphs[CurrentGlyph].Bounds.YMax-fGlyphs[CurrentGlyph].Bounds.YMin);
    if Height<NewHeight then begin
     Height:=NewHeight;
    end;
   end;
   inc(result,GetGlyphAdvanceHeight(CurrentGlyph)+fLetterSpacingY);
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if result=0 then begin
  result:=fMaxY-fMinY;
 end;
 if result<Height then begin
  result:=Height;
 end;
end;

procedure TpvTrueTypeFont.TextSize(const aText:TpvUTF8String;out aWidth,aHeight:TpvInt32);
var TextIndex,CurrentGlyph,LastGlyph,Width,NewWidth,Height,NewHeight:TpvInt32;
begin
 aWidth:=0;
 aHeight:=0;
 Width:=0;
 Height:=0;
 TextIndex:=1;
 LastGlyph:=-1;
 while TextIndex<=length(aText) do begin
  CurrentGlyph:=GetGlyphIndex(PUCUUTF8CodeUnitGetCharAndIncFallback(aText,TextIndex));
  if (CurrentGlyph>0) or (CurrentGlyph<fCountGlyphs) then begin
   if (LastGlyph>=0) and (LastGlyph<fCountGlyphs) then begin
    inc(aWidth,GetKerning(LastGlyph,CurrentGlyph,true));
    inc(aHeight,GetKerning(LastGlyph,CurrentGlyph,false));
   end;
{  if LastGlyph<0 then begin
    dec(aWidth,GetGlyphLeftSideBearing(CurrentGlyph));
    dec(aHeight,GetGlyphTopSideBearing(CurrentGlyph));
   end;}
   if LoadGlyphData(CurrentGlyph)=pvTTF_TT_ERR_NoError then begin
    NewWidth:=aWidth+(fGlyphs[CurrentGlyph].Bounds.XMax-fGlyphs[CurrentGlyph].Bounds.XMin);
    NewHeight:=aHeight+(fGlyphs[CurrentGlyph].Bounds.YMax-fGlyphs[CurrentGlyph].Bounds.YMin);
    if Width<NewWidth then begin
     Width:=NewWidth;
    end;
    if Height<NewHeight then begin
     Height:=NewHeight;
    end;
   end;
   inc(aWidth,GetGlyphAdvanceWidth(CurrentGlyph)+fLetterSpacingX);
   inc(aHeight,GetGlyphAdvanceHeight(CurrentGlyph)+fLetterSpacingY);
  end;
  LastGlyph:=CurrentGlyph;
 end;
 if aWidth=0 then begin
  aWidth:=fMaxX-fMinX;
 end;
 if aWidth<Width then begin
  aWidth:=Width;
 end;
 if aHeight=0 then begin
  aHeight:=fMaxY-fMinY;
 end;
 if aHeight<Height then begin
  aHeight:=Height;
 end;
end;

function TpvTrueTypeFont.RowHeight(const Percent:TpvInt32):TpvInt32;
begin
 result:=((fUnitsPerEm*Percent)+50) div 100;
end;

function TpvTrueTypeFont.GetUnitsPerEm:TpvInt32;
begin
 result:=fUnitsPerEm;
end;

procedure TpvTrueTypeFont.GetPolygonBufferBounds(const PolygonBuffer:TpvTrueTypeFontPolygonBuffer;out x0,y0,x1,y1:TpvDouble;const Tolerance:TpvInt32=2;const MaxLevel:TpvInt32=32);
var lastcx,lastcy:TpvDouble;
    First:boolean;
 procedure ExtendWith(x,y:TpvDouble);
 begin
  if First then begin
   First:=false;
   x0:=x;
   y0:=y;
   x1:=x;
   y1:=y;
  end else begin
   if x0>x then begin
    x0:=x;
   end;
   if y0>y then begin
    y0:=y;
   end;
   if x1<x then begin
    x1:=x;
   end;
   if y1<y then begin
    y1:=y;
   end;
  end;
 end;
 procedure PointAt(x,y:TpvDouble);
 begin
  lastcx:=x;
  lastcy:=y;
  ExtendWith(x,y);
 end;
 procedure QuadraticCurveTo(const cx,cy,ax,ay:TpvDouble);
 var t,s:TpvVectorPathVector;
     Points:array[0..2] of TpvVectorPathVector;
     BoundingBox:TpvVectorPathBoundingBox;
 begin
  Points[0]:=TpvVectorPathVector.Create(lastcx,lastcy);
  Points[1]:=TpvVectorPathVector.Create(cx,cy);
  Points[2]:=TpvVectorPathVector.Create(ax,ay);
  // This code calculates the bounding box for a quadratic bezier curve. It starts by initializing the
  // bounding box to the minimum and maximum values of the start and end points of the curve. It then
  // checks if the control point is already contained within the bounding box, and if it is not, it
  // calculates the value of t at which the derivative of the curve (which is a linear equation) is
  // equal to 0. If t is within the range of 0 to 1, the code calculates the corresponding point on the
  // curve and extends the bounding box to include that point if necessary.
  // Overall, this code appears to be well written and effective at calculating the bounding box for a
  // quadratic bezier curve. It is concise and uses a clever method for finding the extrema of the curve.
  BoundingBox:=TpvVectorPathBoundingBox.Create(Points[0].Minimum(Points[2]),Points[0].Maximum(Points[2]));
  if not BoundingBox.Contains(Points[1]) then begin
   // Since the bezier is quadratic, the bounding box can be compute here with a linear equation.
   // p = (1-t)^2*p0 + 2(1-t)t*p1 + t^2*p2
   // dp/dt = 2(t-1)*p0 + 2(1-2t)*p1 + 2t*p2 = t*(2*p0-4*p1+2*p2) + 2*(p1-p0)
   // dp/dt = 0 -> t*(p0-2*p1+p2) = (p0-p1);
   // Credits for the idea: Inigo Quilez
   t:=(Points[0]-Points[1])/((Points[0]-(Points[1]*2.0))+Points[2]);
   if t.x<=0.0 then begin
    t.x:=0.0;
   end else if t.x>=1.0 then begin
    t.x:=1.0;
   end;
   if t.y<=0.0 then begin
    t.y:=0.0;
   end else if t.y>=1.0 then begin
    t.y:=1.0;
   end;
   s:=TpvVectorPathVector.Create(1.0,1.0)-t;
   BoundingBox.Extend((Points[0]*(s*s))+(Points[1]*((t*s)*2.0))+(Points[2]*(t*t)));
  end;
  ExtendWith(BoundingBox.Min.x,BoundingBox.Min.y);
  ExtendWith(BoundingBox.Max.x,BoundingBox.Max.y);
  PointAt(ax,ay);
 end;
 procedure CubicCurveTo(const c1x,c1y,c2x,c2y,ax,ay:TpvDouble);
 var a,b,c,h:TpvVectorPathVector;
     t,s,q:TpvDouble;
     Points:array[0..3] of TpvVectorPathVector;
     BoundingBox:TpvVectorPathBoundingBox;
 begin
  Points[0]:=TpvVectorPathVector.Create(lastcx,lastcy);
  Points[1]:=TpvVectorPathVector.Create(c1x,c1y);
  Points[2]:=TpvVectorPathVector.Create(c2x,c2y);
  Points[3]:=TpvVectorPathVector.Create(ax,ay);
  // This code appears to be a correct implementation for computing the bounding box of a cubic bezier curve.
  // It uses the fact that the bounding box of a cubic Bezier curve can be computed by finding the roots of
  // quadratic equation formed from the bezier curve's coefficients. The roots of this equation correspond
  // to the parameter values at which the curve reaches an extreme point (i.e., a minimum or maximum). The
  // bounding box is then constructed by evaluating the curve at these parameter values and using the
  // resulting points to extend the initial bounding box.
  // One thing to note is that the code only handles the case where the roots of the quadratic equation are real.
  // If the roots are complex, the bounding box is not extended. This is acceptable since complex roots do not
  // correspond to physical points on the curve.
  // Overall, I would rate this code as good and efficient for computing the bounding box of a cubic bezier curve.
  BoundingBox:=TpvVectorPathBoundingBox.Create(Points[0].Minimum(Points[3]),Points[0].Maximum(Points[3]));
  // Since the bezier is cubic, the bounding box can be compute here with a quadratic equation with
  // pascal triangle coefficients. Credits for the idea: Inigo Quilez
  a:=(((-Points[0])+(Points[1]*3.0))-(Points[2]*3.0))+Points[3];
  b:=(Points[0]-(Points[1]*2.0))+Points[2];
  c:=Points[1]-Points[0];
  h:=(b*b)-(c*a);
  if h.x>0.0 then begin
   h.x:=sqrt(h.x);
   t:=c.x/((-b.x)-h.x);
   if (t>0.0) and (t<1.0) then begin
    s:=1.0-t;
    q:=(Points[0].x*(sqr(s)*s))+(Points[1].x*(3.0*sqr(s)*t))+(Points[2].x*(3.0*s*sqr(t)))+(Points[3].x*sqr(t)*t);
    if BoundingBox.Min.x<q then begin
     BoundingBox.Min.x:=q;
    end;
    if BoundingBox.Max.x>q then begin
     BoundingBox.Max.x:=q;
    end;
   end;
   t:=c.x/((-b.x)+h.x);
   if (t>0.0) and (t<1.0) then begin
    s:=1.0-t;
    q:=(Points[0].x*(sqr(s)*s))+(Points[1].x*(3.0*sqr(s)*t))+(Points[2].x*(3.0*s*sqr(t)))+(Points[3].x*sqr(t)*t);
    if BoundingBox.Min.x<q then begin
     BoundingBox.Min.x:=q;
    end;
    if BoundingBox.Max.x>q then begin
     BoundingBox.Max.x:=q;
    end;
   end;
  end;
  if h.y>0.0 then begin
   h.y:=sqrt(h.y);
   t:=c.y/((-b.y)-h.y);
   if (t>0.0) and (t<1.0) then begin
    s:=1.0-t;
    q:=(Points[0].y*(sqr(s)*s))+(Points[1].y*(3.0*sqr(s)*t))+(Points[2].y*(3.0*s*sqr(t)))+(Points[3].y*sqr(t)*t);
    if BoundingBox.Min.y<q then begin
     BoundingBox.Min.y:=q;
    end;
    if BoundingBox.Max.y>q then begin
     BoundingBox.Max.y:=q;
    end;
   end;
   t:=c.y/((-b.y)+h.y);
   if (t>0.0) and (t<1.0) then begin
    s:=1.0-t;
    q:=(Points[0].y*(sqr(s)*s))+(Points[1].y*(3.0*sqr(s)*t))+(Points[2].y*(3.0*s*sqr(t)))+(Points[3].y*sqr(t)*t);
    if BoundingBox.Min.y<q then begin
     BoundingBox.Min.y:=q;
    end;
    if BoundingBox.Max.y>q then begin
     BoundingBox.Max.y:=q;
    end;
   end;
  end;
  ExtendWith(BoundingBox.Min.x,BoundingBox.Min.y);
  ExtendWith(BoundingBox.Max.x,BoundingBox.Max.y);
  PointAt(ax,ay);
 end;
var CommandIndex:TpvInt32;
begin
 x0:=0;
 y0:=0;
 x1:=0;
 y1:=0;
 First:=true;
 fPolygonBuffer.CountCommands:=0;
 for CommandIndex:=0 to PolygonBuffer.CountCommands-1 do begin
  case PolygonBuffer.Commands[CommandIndex].CommandType of
   TpvTrueTypeFontPolygonCommandType.MoveTo,TpvTrueTypeFontPolygonCommandType.LineTo:begin
    PointAt(PolygonBuffer.Commands[CommandIndex].Points[0].x,PolygonBuffer.Commands[CommandIndex].Points[0].y);
   end;
   TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo:begin
    QuadraticCurveTo(PolygonBuffer.Commands[CommandIndex].Points[0].x,PolygonBuffer.Commands[CommandIndex].Points[0].y,
                     PolygonBuffer.Commands[CommandIndex].Points[1].x,PolygonBuffer.Commands[CommandIndex].Points[1].y);
   end;
   TpvTrueTypeFontPolygonCommandType.CubicCurveTo:begin
    CubicCurveTo(PolygonBuffer.Commands[CommandIndex].Points[0].x,PolygonBuffer.Commands[CommandIndex].Points[0].y,
                 PolygonBuffer.Commands[CommandIndex].Points[1].x,PolygonBuffer.Commands[CommandIndex].Points[1].y,
                 PolygonBuffer.Commands[CommandIndex].Points[2].x,PolygonBuffer.Commands[CommandIndex].Points[2].y);
   end;
   TpvTrueTypeFontPolygonCommandType.Close:begin
   end;
  end;
 end;
end;

procedure TpvTrueTypeFont.DrawPolygonBuffer(Rasterizer:TpvTrueTypeFontRasterizer;const PolygonBuffer:TpvTrueTypeFontPolygonBuffer;x,y:TpvInt32;Tolerance:TpvInt32=2;MaxLevel:TpvInt32=32);
var CommandIndex:TpvInt32;
begin
 if assigned(Rasterizer) then begin
  fPolygonBuffer.CountCommands:=0;
  for CommandIndex:=0 to PolygonBuffer.CountCommands-1 do begin
   case PolygonBuffer.Commands[CommandIndex].CommandType of
    TpvTrueTypeFontPolygonCommandType.MoveTo:begin
     Rasterizer.MoveTo(round(x+PolygonBuffer.Commands[CommandIndex].Points[0].x),
                       round(y+PolygonBuffer.Commands[CommandIndex].Points[0].y));
    end;
    TpvTrueTypeFontPolygonCommandType.LineTo:begin
     Rasterizer.LineTo(round(x+PolygonBuffer.Commands[CommandIndex].Points[0].x),
                       round(y+PolygonBuffer.Commands[CommandIndex].Points[0].y));
    end;
    TpvTrueTypeFontPolygonCommandType.QuadraticCurveTo:begin
     Rasterizer.QuadraticCurveTo(round(x+PolygonBuffer.Commands[CommandIndex].Points[0].x),
                                 round(y+PolygonBuffer.Commands[CommandIndex].Points[0].y),
                                 round(x+PolygonBuffer.Commands[CommandIndex].Points[1].x),
                                 round(y+PolygonBuffer.Commands[CommandIndex].Points[1].y),
                                 Tolerance,MaxLevel);
    end;
    TpvTrueTypeFontPolygonCommandType.CubicCurveTo:begin
     Rasterizer.CubicCurveTo(round(x+PolygonBuffer.Commands[CommandIndex].Points[0].x),
                             round(y+PolygonBuffer.Commands[CommandIndex].Points[0].y),
                             round(x+PolygonBuffer.Commands[CommandIndex].Points[1].x),
                             round(y+PolygonBuffer.Commands[CommandIndex].Points[1].y),
                             round(x+PolygonBuffer.Commands[CommandIndex].Points[2].x),
                             round(y+PolygonBuffer.Commands[CommandIndex].Points[2].y),
                             Tolerance,MaxLevel);
    end;
    TpvTrueTypeFontPolygonCommandType.Close:begin
     Rasterizer.Close;
    end;
   end;
  end;
 end;
end;

procedure TpvTrueTypeFont.GenerateSimpleLinearSignedDistanceFieldTextureArrayParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
const Scale=1.0/256.0;
var Index:TPasMPNativeInt;
    x,y,p,w,h,fx,fy,v,xo,yo:TpvInt32;
    JobData:PpvTrueTypeFontSignedDistanceFieldJob;
    x0,y0,x1,y1,ox,oy:TpvDouble;
    VectorPath:TpvVectorPath;
    VectorPathShape:TpvVectorPathShape;
    SignedDistanceField:TpvSignedDistanceField2D;
begin

 SignedDistanceField.Pixels:=nil;

 try

  Index:=FromIndex;

  while Index<=ToIndex do begin

   JobData:=@PpvTrueTypeFontSignedDistanceFieldJobArray(Data)^[Index];

   GetPolygonBufferBounds(JobData^.PolygonBuffer,x0,y0,x1,y1);

   ox:=(x0*Scale)-(VulkanDistanceField2DSpreadValue*2.0);
   oy:=(y0*Scale)-(VulkanDistanceField2DSpreadValue*2.0);

   w:=Max(1,ceil(((x1-x0)*Scale)+(VulkanDistanceField2DSpreadValue*4.0)));
   h:=Max(1,ceil(((y1-y0)*Scale)+(VulkanDistanceField2DSpreadValue*4.0)));

   SignedDistanceField.Width:=w;
   SignedDistanceField.Height:=h;
   SignedDistanceField.Pixels:=nil;
   SetLength(SignedDistanceField.Pixels,SignedDistanceField.Width*SignedDistanceField.Height);

   VectorPath:=TpvVectorPath.Create;
   try

    JobData^.PolygonBuffer.ConvertToVectorPath(VectorPath);

    VectorPathShape:=TpvVectorPathShape.Create(VectorPath);
    try

     TpvSignedDistanceField2DGenerator.Generate(SignedDistanceField,
                                                VectorPathShape,
                                                Scale,
                                                -ox,
                                                -oy,
                                                TpvSignedDistanceField2DVariant.SDF);

    finally
     FreeAndNil(VectorPathShape);
    end;

   finally
    FreeAndNil(VectorPath);
   end;

   xo:=round(((JobData^.Width-((JobData^.BoundsX0+JobData^.BoundsX1)*Scale))*0.5)+ox);
   yo:=round(((JobData^.Height-((JobData^.BoundsY0+JobData^.BoundsY1)*Scale))*0.5)+oy);

   p:=0;
   for y:=0 to JobData^.Height-1 do begin
    for x:=0 to JobData^.Width-1 do begin
     fx:=Min(Max(x-xo,0),SignedDistanceField.Width-1);
     fy:=Min(Max(y-yo,0),SignedDistanceField.Height-1);
     if (fx>=0) and (fx<SignedDistanceField.Width) and
        (fy>=0) and (fy<SignedDistanceField.Height) then begin
      v:=SignedDistanceField.Pixels[(fy*SignedDistanceField.Width)+fx].a;
     end else begin
      v:=128;
     end;
     PpvUInt8Array(JobData^.Destination)^[p]:=v;
     inc(p);
    end;
   end;

   inc(Index);

  end;

 finally

  SignedDistanceField.Pixels:=nil;

 end;

end;

procedure TpvTrueTypeFont.GenerateSimpleLinearSignedDistanceFieldTextureArray(const aDestinationData:TpvPointer;
                                                                              const aTextureArrayWidth:TpvInt32;
                                                                              const aTextureArrayHeight:TpvInt32;
                                                                              const aTextureArrayDepth:TpvInt32);
const Scale=1.0/256.0;
var Index,TTFGlyphIndex,x,y:TpvInt32;
    PolygonBuffers:TpvTrueTypeFontPolygonBuffers;
    PolygonBuffer:TpvTrueTypeFontPolygonBuffer;
    GlyphBuffer:TpvTrueTypeFontGlyphBuffer;
    SignedDistanceFieldJobs:TpvTrueTypeFontSignedDistanceFieldJobs;
    SignedDistanceFieldJob:PpvTrueTypeFontSignedDistanceFieldJob;
    PasMPInstance:TPasMP;
    x0,y0,x1,y1:TpvDouble;
    BoundsX0,BoundsY0,BoundsX1,BoundsY1:TpvDouble;
begin

 PasMPInstance:=TPasMP.GetGlobalInstance;

 FillChar(aDestinationData^,aTextureArrayWidth*aTextureArrayHeight*aTextureArrayDepth,$80);

 Hinting:=false;

 y:=aTextureArrayHeight;
 for Index:=0 to aTextureArrayDepth-1 do begin
  x:=aTextureArrayHeight;
  repeat
   Size:=-x;
   TTFGlyphIndex:=GetGlyphIndex(Index);
   if TTFGlyphIndex>=0 then begin
    ResetPolygonBuffer(PolygonBuffer);
    if IsPostScriptGlyph(TTFGlyphIndex) then begin
     FillPostScriptPolygonBuffer(PolygonBuffer,TTFGlyphIndex);
     end else begin
     ResetGlyphBuffer(GlyphBuffer);
     FillGlyphBuffer(GlyphBuffer,TTFGlyphIndex);
     FillPolygonBuffer(PolygonBuffer,GlyphBuffer);
    end;
    GetPolygonBufferBounds(PolygonBuffer,x0,y0,x1,y1);
    x0:=x0*Scale;
    y0:=y0*Scale;
    x1:=x1*Scale;
    y1:=y1*Scale;
    if ((x1-x0)<=aTextureArrayWidth) and
       ((y1-y0)<=aTextureArrayHeight) and
       (x1<=aTextureArrayWidth) and
       (y1<=aTextureArrayHeight) then begin
     break;
    end else if x>2 then begin
     dec(x);
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  until false;
  y:=Min(y,x);
 end;

 Size:=-y;

 BoundsX0:=MaxDouble;
 BoundsY0:=MaxDouble;
 BoundsX1:=-MaxDouble;
 BoundsY1:=-MaxDouble;

 PolygonBuffers:=nil;
 try

  SetLength(PolygonBuffers,aTextureArrayDepth);

  for Index:=0 to aTextureArrayDepth-1 do begin

   TTFGlyphIndex:=GetGlyphIndex(Index);
   if TTFGlyphIndex>=0 then begin

    if IsPostScriptGlyph(TTFGlyphIndex) then begin

     FillPostScriptPolygonBuffer(PolygonBuffers[Index],TTFGlyphIndex);

    end else begin

     ResetGlyphBuffer(GlyphBuffer);
     FillGlyphBuffer(GlyphBuffer,TTFGlyphIndex);

     FillPolygonBuffer(PolygonBuffers[Index],GlyphBuffer);

    end;

    GetPolygonBufferBounds(PolygonBuffers[Index],x0,y0,x1,y1);

    BoundsX0:=Min(BoundsX0,x0);
    BoundsY0:=Min(BoundsY0,y0);
    BoundsX1:=Max(BoundsX1,x1);
    BoundsY1:=Max(BoundsY1,y1);

   end;

  end;

  SignedDistanceFieldJobs:=nil;
  try
   SetLength(SignedDistanceFieldJobs,aTextureArrayDepth);
   for Index:=0 to aTextureArrayDepth-1 do begin
    SignedDistanceFieldJob:=@SignedDistanceFieldJobs[Index];
    SignedDistanceFieldJob^.PolygonBuffer:=PolygonBuffers[Index];
    SignedDistanceFieldJob^.Destination:=@PpvUInt8Array(aDestinationData)^[(aTextureArrayWidth*aTextureArrayHeight)*Index];
    SignedDistanceFieldJob^.Width:=aTextureArrayWidth;
    SignedDistanceFieldJob^.Height:=aTextureArrayHeight;
    SignedDistanceFieldJob^.BoundsX0:=BoundsX0;
    SignedDistanceFieldJob^.BoundsY0:=BoundsY0;
    SignedDistanceFieldJob^.BoundsX1:=BoundsX1;
    SignedDistanceFieldJob^.BoundsY1:=BoundsY1;
   end;
   if aTextureArrayDepth>0 then begin
    PasMPInstance.Invoke(PasMPInstance.ParallelFor(@SignedDistanceFieldJobs[0],0,aTextureArrayDepth-1,GenerateSimpleLinearSignedDistanceFieldTextureArrayParallelForJobFunction,1,10,nil,0));
   end;
  finally
   SignedDistanceFieldJobs:=nil;
  end;

 finally
  PolygonBuffers:=nil;
 end;

end;

end.
