(******************************************************************************
 *                        PasHTMLDownCanvasRenderer Libary                    *
 ******************************************************************************
 *                        Version 2025-08-30-18-56-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pashtmldown                                  *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 3.0 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that, but if needed, make *
 *    it out-ifdef-able.                                                      *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 *                                                                            *
 ******************************************************************************)
unit PasHTMLDownCanvasRenderer;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define CanInline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
 {$if declared(UnicodeString)}
  {$define HAS_TYPE_UNICODESTRING}
 {$else}
  {$undef HAS_TYPE_UNICODESTRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
 {$ifdef conditionalexpressions}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
  {$if declared(UnicodeString)}
   {$define HAS_TYPE_UNICODESTRING}
  {$else}
   {$undef HAS_TYPE_UNICODESTRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
  {$undef HAS_TYPE_UTF8STRING}
  {$undef HAS_TYPE_UNICODESTRING}
 {$endif}
 {$ifndef BCB}
  {$ifdef ver120}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver140}
   {$define Delphi6}
  {$endif}
  {$ifdef ver150}
   {$define Delphi7}
  {$endif}
  {$ifdef ver170}
   {$define Delphi2005}
  {$endif}
 {$else}
  {$ifdef ver120}
   {$define Delphi4or5}
   {$define BCB4}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
 {$endif}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24}
   {$legacyifend on}
  {$ifend}
  {$if CompilerVersion>=14.0}
   {$if CompilerVersion=14.0}
    {$define Delphi6}
   {$ifend}
   {$define Delphi6AndUp}
  {$ifend}
  {$if CompilerVersion>=15.0}
   {$if CompilerVersion=15.0}
    {$define Delphi7}
   {$ifend}
   {$define Delphi7AndUp}
  {$ifend}
  {$if CompilerVersion>=17.0}
   {$if CompilerVersion=17.0}
    {$define Delphi2005}
   {$ifend}
   {$define Delphi2005AndUp}
  {$ifend}
  {$if CompilerVersion>=18.0}
   {$if CompilerVersion=18.0}
    {$define BDS2006}
    {$define Delphi2006}
   {$ifend}
   {$define Delphi2006AndUp}
  {$ifend}
  {$if CompilerVersion>=18.5}
   {$if CompilerVersion=18.5}
    {$define Delphi2007}
   {$ifend}
   {$define Delphi2007AndUp}
  {$ifend}
  {$if CompilerVersion=19.0}
   {$define Delphi2007Net}
  {$ifend}
  {$if CompilerVersion>=20.0}
   {$if CompilerVersion=20.0}
    {$define Delphi2009}
   {$ifend}
   {$define Delphi2009AndUp}
  {$ifend}
  {$if CompilerVersion>=21.0}
   {$if CompilerVersion=21.0}
    {$define Delphi2010}
   {$ifend}
   {$define Delphi2010AndUp}
  {$ifend}
  {$if CompilerVersion>=22.0}
   {$if CompilerVersion=22.0}
    {$define DelphiXE}
   {$ifend}
   {$define DelphiXEAndUp}
  {$ifend}
  {$if CompilerVersion>=23.0}
   {$if CompilerVersion=23.0}
    {$define DelphiXE2}
   {$ifend}
   {$define DelphiXE2AndUp}
  {$ifend}
  {$if CompilerVersion>=24.0}
   {$if CompilerVersion=24.0}
    {$define DelphiXE3}
   {$ifend}
   {$define DelphiXE3AndUp}
  {$ifend}
  {$if CompilerVersion>=25.0}
   {$if CompilerVersion=25.0}
    {$define DelphiXE4}
   {$ifend}
   {$define DelphiXE4AndUp}
  {$ifend}
  {$if CompilerVersion>=26.0}
   {$if CompilerVersion=26.0}
    {$define DelphiXE5}
   {$ifend}
   {$define DelphiXE5AndUp}
  {$ifend}
  {$if CompilerVersion>=27.0}
   {$if CompilerVersion=27.0}
    {$define DelphiXE6}
   {$ifend}
   {$define DelphiXE6AndUp}
  {$ifend}
  {$if CompilerVersion>=28.0}
   {$if CompilerVersion=28.0}
    {$define DelphiXE7}
   {$ifend}
   {$define DelphiXE7AndUp}
  {$ifend}
  {$if CompilerVersion>=29.0}
   {$if CompilerVersion=29.0}
    {$define DelphiXE8}
   {$ifend}
   {$define DelphiXE8AndUp}
  {$ifend}
  {$if CompilerVersion>=30.0}
   {$if CompilerVersion=30.0}
    {$define Delphi10Seattle}
   {$ifend}
   {$define Delphi10SeattleAndUp}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$if CompilerVersion=31.0}
    {$define Delphi10Berlin}
   {$ifend}
   {$define Delphi10BerlinAndUp}
  {$ifend}
 {$endif}
 {$ifndef Delphi4or5}
  {$ifndef BCB}
   {$define Delphi6AndUp}
  {$endif}
   {$ifndef Delphi6}
    {$define BCB6OrDelphi7AndUp}
    {$ifndef BCB}
     {$define Delphi7AndUp}
    {$endif}
    {$ifndef BCB}
     {$ifndef Delphi7}
      {$ifndef Delphi2005}
       {$define BDS2006AndUp}
      {$endif}
     {$endif}
    {$endif}
   {$endif}
 {$endif}
 {$ifdef Delphi6AndUp}
  {$warn symbol_platform off}
  {$warn symbol_deprecated off}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$scopedenums on}
{$ifdef PasHTMLDownCanvasRendererFMX}
 {$define FMX}
{$else}
 {$undef FMX}
{$endif}

interface

uses SysUtils,Classes,Math,
     {$ifdef fpc}Types,{$endif}
     {$ifdef PasHTMLDownCanvasRendererFMX}
      System.Types,
      System.UITypes,
      FMX.Types,
      FMX.Graphics
     {$else}
      {$ifdef fpc}
       Graphics
      {$else}
       VCL.Graphics
      {$endif}
     {$endif},
     PasHTMLDown;

type TMarkDownRendererUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     TMarkDownRendererRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     TMarkdownRendererInt8={$if declared(UInt8)}Int8{$else}ShortInt{$ifend};
     PMarkdownRendererInt8=^TMarkdownRendererInt8;

     TMarkdownRendererUInt8={$if declared(UInt8)}UInt8{$else}Byte{$ifend};
     PMarkdownRendererUInt8=^TMarkdownRendererUInt8;

     TMarkDownRendererUInt8Array=array[0..65535] of TMarkDownRendererUInt8;
     PMarkDownRendererUInt8Array=^TMarkDownRendererUInt8Array;

     TMarkdownRendererInt16={$if declared(UInt8)}Int16{$else}SmallInt{$ifend};
     PMarkdownRendererInt16=^TMarkdownRendererInt16;

     TMarkdownRendererUInt16={$if declared(UInt8)}UInt16{$else}Word{$ifend};
     PMarkdownRendererUInt16=^TMarkdownRendererUInt16;

     TMarkDownRendererInt32={$if declared(Int32)}Int32{$else}LongInt{$ifend};
     PMarkDownRendererInt32=^TMarkDownRendererInt32;

     TMarkDownRendererUInt32={$if declared(Int32)}UInt32{$else}LongWord{$ifend};
     PMarkDownRendererUInt32=^TMarkDownRendererUInt32;

     TMarkDownRendererInt64={$if declared(Int64)}Int64{$else}Int64{$ifend};
     PMarkDownRendererInt64=^TMarkDownRendererInt64;

     TMarkDownRendererUInt64={$if declared(Int64)}UInt64{$else}QWord{$ifend};
     PMarkDownRendererUInt64=^TMarkDownRendererUInt64;

     TMarkDownRendererSizeInt={$if declared(PtrInt)}PtrInt{$else}{$if declared(SizeInt)}SizeInt{$else}LongInt{$ifend}{$ifend};
     PMarkDownRendererSizeInt=^TMarkDownRendererSizeInt;

     TMarkDownRendererSizeUInt={$if declared(PtrUInt)}PtrUInt{$else}{$if declared(SizeUInt)}SizeUInt{$else}LongWord{$ifend}{$ifend};
     PMarkDownRendererSizeUInt=^TMarkDownRendererSizeUInt;

     TMarkDownRendererPtrInt={$if declared(PtrInt)}PtrInt{$else}{$if declared(SizeInt)}SizeInt{$else}LongInt{$ifend}{$ifend};
     PMarkDownRendererPtrInt=^TMarkDownRendererPtrInt;

     TMarkDownRendererPtrUInt={$if declared(PtrUInt)}PtrUInt{$else}{$if declared(SizeUInt)}SizeUInt{$else}LongWord{$ifend}{$ifend};
     PMarkDownRendererPtrUInt=^TMarkDownRendererPtrUInt;

     TMarkDownRendererPointer=Pointer;
     PMarkDownRendererPointer=^TMarkDownRendererPointer;

     TMarkDownRendererFloat=Single;

     { TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue> }
     TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>=class
      private
       type TMarkDownRendererHashMapKey=TMarkDownRendererRawByteString;
            TEntity=record
             public
              const Empty=0;
                    Deleted=1;
                    Used=2;
             public
              State:TMarkDownRendererUInt32;
              Key:TMarkDownRendererHashMapKey;
              Value:TMarkDownRendererHashMapValue;
            end;
            PEntity=^TEntity;
            TEntities=array of TEntity;
      private
       type TEntityEnumerator=record
             private
              fHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
              fIndex:TMarkDownRendererSizeInt;
              function GetCurrent:TEntity; inline;
             public
              constructor Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TEntity read GetCurrent;
            end;
            TKeyEnumerator=record
             private
              fHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
              fIndex:TMarkDownRendererSizeInt;
              function GetCurrent:TMarkDownRendererHashMapKey; inline;
             public
              constructor Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TMarkDownRendererHashMapKey read GetCurrent;
            end;
            THashMapValueEnumerator=record
             private
              fHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
              fIndex:TMarkDownRendererSizeInt;
              function GetCurrent:TMarkDownRendererHashMapValue; inline;
             public
              constructor Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TMarkDownRendererHashMapValue read GetCurrent;
            end;
            TEntitiesObject=class
             private
              fOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
             public
              constructor Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function GetEnumerator:TEntityEnumerator;
            end;
            TKeysObject=class
             private
              fOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
             public
              constructor Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function GetEnumerator:TKeyEnumerator;
            end;
            TValuesObject=class
             private
              fOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>;
              function GetValue(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererHashMapValue; inline;
              procedure SetValue(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue); inline;
             public
              constructor Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
              function GetEnumerator:THashMapValueEnumerator;
              property Values[const Key:TMarkDownRendererHashMapKey]:TMarkDownRendererHashMapValue read GetValue write SetValue; default;
            end;
      private
       fSize:TMarkDownRendererSizeUInt;
       fLogSize:TMarkDownRendererSizeUInt;
       fCountNonEmptyEntites:TMarkDownRendererSizeUInt;
       fCountDeletedEntites:TMarkDownRendererSizeUInt;
       fEntities:TEntities;
       fDefaultValue:TMarkDownRendererHashMapValue;
       fCanShrink:boolean;
       fEntitiesObject:TEntitiesObject;
       fKeysObject:TKeysObject;
       fValuesObject:TValuesObject;
       function HashKey(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererUInt32;
       function FindEntity(const aKey:TMarkDownRendererHashMapKey):PEntity;
       function FindEntityForAdd(const aKey:TMarkDownRendererHashMapKey):PEntity;
       procedure Resize;
      protected
       function GetValue(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererHashMapValue;
       procedure SetValue(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue);
      public
       constructor Create(const aDefaultValue:TMarkDownRendererHashMapValue);
       destructor Destroy; override;
       procedure Clear(const aCanFree:Boolean=true);
       function Add(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue):PEntity;
       function Get(const aKey:TMarkDownRendererHashMapKey;const aCreateIfNotExist:boolean=false):PEntity;
       function TryGet(const aKey:TMarkDownRendererHashMapKey;out aValue:TMarkDownRendererHashMapValue):boolean;
       function ExistKey(const aKey:TMarkDownRendererHashMapKey):boolean;
       function Delete(const aKey:TMarkDownRendererHashMapKey):boolean;
       property EntityValues[const Key:TMarkDownRendererHashMapKey]:TMarkDownRendererHashMapValue read GetValue write SetValue; default;
       property Entities:TEntitiesObject read fEntitiesObject;
       property Keys:TKeysObject read fKeysObject;
       property Values:TValuesObject read fValuesObject;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;

     TMarkDownRenderer=class
      
      public

       const MaxHeightString='HAgIEi!|';

       type TLayoutItemKind=
             (
              LayoutText,
              LayoutHR,
              LayoutBullet,
              LayoutRect,
              LayoutCodeBG
             );

            // === Basic items =============================================================
            TLayoutItem=class
             private
              fKind:TLayoutItemKind;
              fX:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fText:TMarkDownRendererUTF8String;
              fFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fFontStyle:TFontStyles;
              fLinkHref:TMarkDownRendererUTF8String;
              fMetaA:TMarkDownRendererInt32;
              fMetaB:TMarkDownRendererInt32;
              fMono:boolean;
              fCode:boolean;
              fBlockQuote:boolean;
              fMark:boolean;
              fThink:boolean;
             public
              property Kind:TLayoutItemKind read fKind write fKind;
              property X:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fX write fX;
              property Y:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fY write fY;
              property Width:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fWidth write fWidth;
              property Height:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fHeight write fHeight;
              property Text:TMarkDownRendererUTF8String read fText write fText;
              property FontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fFontSize write fFontSize;
              property FontStyle:TFontStyles read fFontStyle write fFontStyle;
              property LinkHref:TMarkDownRendererUTF8String read fLinkHref write fLinkHref;
              property MetaA:TMarkDownRendererInt32 read fMetaA write fMetaA;
              property MetaB:TMarkDownRendererInt32 read fMetaB write fMetaB;
              property Mono:boolean read fMono write fMono; //
              property Code:boolean read fCode write fCode;
              property BlockQuote:boolean read fBlockQuote write fBlockQuote;
              property Mark:boolean read fMark write fMark;
              property Think:boolean read fThink write fThink;
            end;

            TLayoutItemList=class
             private
              fItems:array of TLayoutItem;
              fCount:TMarkDownRendererInt32;
              procedure EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
             public
              constructor Create;
              destructor Destroy; override;
              procedure Clear;
              function NewItem:TLayoutItem;
              function GetItem(const aIndex:TMarkDownRendererInt32):TLayoutItem;
              property Count:TMarkDownRendererInt32 read fCount;
              property Items[const Index:TMarkDownRendererInt32]:TLayoutItem read GetItem; default;
            end;

            //=== Link hit rects ==========================================================
            TLinkHitRect=class
             private
              fX:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fW:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fH:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fHref:TMarkDownRendererUTF8String;
             public
              property X:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fX write fX;
              property Y:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fY write fY;
              property W:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fW write fW;
              property H:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fH write fH;
              property Href:TMarkDownRendererUTF8String read fHref write fHref;
            end;

            TLinkHitRectList=class
             private
              fItems:array of TLinkHitRect;
              fCount:TMarkDownRendererInt32;
              procedure EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
             public
              constructor Create;
              destructor Destroy; override;
              procedure Clear;
              procedure Add(const aX,aY,aWidth,aHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aHref:TMarkDownRendererUTF8String);
              function GetItem(const aIndex:TMarkDownRendererInt32):TLinkHitRect;
              property Count:TMarkDownRendererInt32 read fCount;
              property Items[const Index:TMarkDownRendererInt32]:TLinkHitRect read GetItem; default;
            end;

            //=== Table model (classes + lists, no records) ===============================
            TTableCell=class
             private
              fText:TMarkDownRendererUTF8String;
              fColSpan:TMarkDownRendererInt32;
              fRowSpan:TMarkDownRendererInt32;
              fNode:THTML.TNode;
             public
              property Text:TMarkDownRendererUTF8String read fText write fText;
              property ColSpan:TMarkDownRendererInt32 read fColSpan write fColSpan;
              property RowSpan:TMarkDownRendererInt32 read fRowSpan write fRowSpan;
              property Node:THTML.TNode read fNode write fNode;
            end;

            TTableCellList=class
             private
              fItems:array of TTableCell;
              fCount:TMarkDownRendererInt32;
              procedure EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
             public
              constructor Create;
              destructor Destroy; override;
              procedure Clear;
              function AddNew:TTableCell;
              function GetItem(const aIndex:TMarkDownRendererInt32):TTableCell;
              property Count:TMarkDownRendererInt32 read fCount;
              property Items[const Index:TMarkDownRendererInt32]:TTableCell read GetItem; default;
            end;

            TTableRow=class
             private
              fCells:TTableCellList;
             public
              constructor Create;
              destructor Destroy; override;
              property Cells:TTableCellList read fCells;
            end;

            TTableRowList=class
             private
              fItems:array of TTableRow;
              fCount:TMarkDownRendererInt32;
              procedure EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
             public
              constructor Create;
              destructor Destroy; override;
              procedure Clear;
              function AddNew:TTableRow;
              function GetItem(const aIndex:TMarkDownRendererInt32):TTableRow;
              property Count:TMarkDownRendererInt32 read fCount;
              property Items[const Index:TMarkDownRendererInt32]:TTableRow read GetItem; default;
            end;

            TTable=class
             private
              fRows:TTableRowList;
              fRowCount:TMarkDownRendererInt32;
              fColCount:TMarkDownRendererInt32;
             public
              constructor Create;
              destructor Destroy; override;
              property Rows:TTableRowList read fRows;
              property RowCount:TMarkDownRendererInt32 read fRowCount write fRowCount;
              property ColCount:TMarkDownRendererInt32 read fColCount write fColCount;
            end;

            TTextSizeCacheItem=record
             Width:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
             Height:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
            end;

            TTextSizeCacheHashMap=TMarkDownRendererStringHashMap<TTextSizeCacheItem>;

      private
       
       // items/layout state

       fItems:TLayoutItemList;
       fCalculatedWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fCalculatedHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fMaxWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       fLineX:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fLineY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fLineWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fLineHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       // per line overhang handling for superscript/subscript
       fLineAboveExtra:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}; // extra pixels above line top due to superscripts
       fLineBelowExtra:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}; // extra pixels below baseline due to subscripts
       fLineItemStartIndex:TMarkDownRendererInt32; // index of first item in current line
       fLinkRectStartIndex:TMarkDownRendererInt32; // index of first link rect in current line
       fParagraphSpacing:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fIndentStep:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fCurrentIndent:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       fTextSizeCacheHashMap:TTextSizeCacheHashMap;

       fListDepth:TMarkDownRendererInt32;
       fOrderedListDepthCount:array[0..31] of TMarkDownRendererInt32;

       fBaseFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fNeedSpaceBeforeNextText:boolean;

       fLinkRects:TLinkHitRectList;

       fTargetDPI:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fFontName:TMarkDownRendererUTF8String;
       fMonoFontName:TMarkDownRendererUTF8String;

       fBGCodeColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fFontCodeColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fBGMarkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fFontMarkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fBGThinkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fFontThinkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};

       fBGColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fFontColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fFontQuoteColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};

       fHTMLDoc:THTML;

       // current inline baseline shift (negative=up for <sup>, positive=down for <sub>)
       fBaselineShiftCurrent:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       // current inline mark highlight state
       fMarkActive:boolean;
       // current inline think state
       fThinkActive:boolean;

{$ifdef FMX}
       fCurrentFontColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
{$endif}

       function DIP(const aValue:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       procedure Clear;
       procedure BeginLayout;
       procedure EndLayout;

       procedure NewLine(const aCanvas:TCanvas);
       procedure ParagraphBreak(const aCanvas:TCanvas);

       procedure ApplyFont(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean);
       procedure MeasureText(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean;out aWidth,aHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
       function MeasureTextWidth(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       function MeasureTextHeight(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       procedure ShiftCurrentLineItems(const aDeltaY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
       procedure FlushTextRun(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aLinkHref:TMarkDownRendererUTF8String;const aUseMono,aUseCode,aIsBlockQuote:boolean;const aDryRun:boolean);
       procedure LayoutTextWrapped(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aLinkHref:TMarkDownRendererUTF8String;const aUseMono,aUseCode,aIsBlockQuote:boolean;const aPreserveWhitespace,aDryRun:boolean);
       procedure LayoutHR(const aCanvas:TCanvas;const aIsBlockQuote:Boolean);
       procedure LayoutBullet(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aIsBlockQuote:Boolean);

       procedure LayoutCodeBlock(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});

       function HeaderFontSize(const aLevel:TMarkDownRendererInt32;const aBase:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       procedure TraverseHTML(const aCanvas:TCanvas;const aNode:THTML.TNode;const aIsBlock:boolean;aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};aFontStyle:TFontStyles;aLinkHref:TMarkDownRendererUTF8String;aUseMono,aIsBlockQuote:boolean);

       // tables
       function ExtractNodeText(const aNode:THTML.TNode):TMarkDownRendererUTF8String;
       function GetAttrInt(const aNode:THTML.TNode;const aKey:TMarkDownRendererUTF8String;const aDefaultValue:TMarkDownRendererInt32):TMarkDownRendererInt32;

       procedure CollectTable(const aNode:THTML.TNode;out aTableModel:TTable);
       procedure NormalizeTable(var aTableModel:TTable);
       procedure MeasureTableColumns(const aCanvas:TCanvas;const aTableModel:TTable;var aMinCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aPrefCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aIsBlockQuote:Boolean);
       procedure DistributeColumns(const aAvailable:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aMinCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aPrefCol:array of  {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aColumnWidth:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aIsBlockQuote:Boolean);
       procedure LayoutTable(const aCanvas:TCanvas;var aTableModel:TTable;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aIsBlockQuote:Boolean);

      public
       constructor Create;
       destructor Destroy; override;

       // aIsHTML=false => MarkDownToHTML
       procedure Parse(const aMarkDownOrHTML:TMarkDownRendererUTF8String;const IsHTML:boolean);
       procedure Calculate(const aCanvas:TCanvas;const aMaxWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aContentWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aContentHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
       procedure Render(const aCanvas:TCanvas;const aLeftPosition,aTopPosition:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
       function HitTestLink(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aHref:TMarkDownRendererUTF8String):boolean;

       // Public properties
       property CalculatedWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fCalculatedWidth;
       property CalculatedHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fCalculatedHeight;
       property TargetDPI:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fTargetDPI write fTargetDPI;
       property FontName:TMarkDownRendererUTF8String read fFontName write fFontName;
       property MonoFontName:TMarkDownRendererUTF8String read fMonoFontName write fMonoFontName;

       property BGCodeColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fBGCodeColor write fBGCodeColor;
       property FontCodeColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fFontCodeColor write fFontCodeColor;
       property BGMarkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fBGMarkColor write fBGMarkColor;
       property FontMarkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fFontMarkColor write fFontMarkColor;
       property BGThinkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fBGThinkColor write fBGThinkColor;
       property FontThinkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fFontThinkColor write fFontThinkColor;

       property BGColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fBGColor write fBGColor;
       property FontColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fFontColor write fFontColor;
       property FontQuoteColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fFontQuoteColor write fFontQuoteColor;

       property BaseFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif} read fBaseFontSize write fBaseFontSize;

     end;

function IntLog2(x:TMarkDownRendererUInt32):TMarkDownRendererUInt32;
function IntLog264(x:TMarkDownRendererUInt64):TMarkDownRendererUInt32;

implementation

//=== small utils ===========================================================

function IntLog2(x:TMarkDownRendererUInt32):TMarkDownRendererUInt32; {$if defined(fpc)}
begin
 if x<>0 then begin
  result:=BSRDWord(x);
 end else begin
  result:=0;
 end;
end;
{$elseif defined(cpu386)}
asm
 test eax,eax
 jz @Done
 bsr eax,eax
 @Done:
end;
{$elseif defined(cpux86_64)}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr eax,ecx
{$else}
 bsr eax,edi
{$endif}
 jnz @Done
 xor eax,eax
@Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x shr 1;
 dec(x,(x shr 1) and $55555555);
 x:=((x shr 2) and $33333333)+(x and $33333333);
 x:=((x shr 4)+x) and $0f0f0f0f;
 inc(x,x shr 8);
 inc(x,x shr 16);
 result:=x and $3f;
end;
{$ifend}

function IntLog264(x:TMarkDownRendererUInt64):TMarkDownRendererUInt32; {$if defined(fpc)}
begin
 if x<>0 then begin
  result:=BSRQWord(x);
 end else begin
  result:=0;
 end;
end;
{$elseif defined(cpu386)}
asm
 bsr eax,dword ptr [x+4]
 jz @LowPart
 add eax,32
 jmp @Done
@LowPart:
 xor ecx,ecx
 bsr eax,dword ptr [x+0]
 jnz @Done
 xor eax,eax
@Done:
end;
{$elseif defined(cpux86_64)}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr rax,rcx
{$else}
 bsr rax,rdi
{$endif}
 jnz @Done
 xor eax,eax
@Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x or (x shr 32);
 x:=x shr 1;
 dec(x,(x shr 1) and $5555555555555555);
 x:=((x shr 2) and $3333333333333333)+(x and $3333333333333333);
 x:=((x shr 4)+x) and $0f0f0f0f0f0f0f0f;
 inc(x,x shr 8);
 inc(x,x shr 16);
 inc(x,x shr 32);
 result:=x and $7f;
end;
{$ifend}

function TrimRightSpaces(const S:TMarkDownRendererUTF8String):TMarkDownRendererUTF8String;
var Index:TMarkDownRendererInt32;
begin
 Index:=length(S);
 while (Index>0) and (S[Index]<=' ') do begin
  dec(Index);
 end;
 if Index<length(S) then begin
  result:=copy(S,1,Index);
 end else begin
  result:=S;
 end;
end;

function HTMLDecodeUTF8String(const aText:TMarkDownRendererUTF8String):TMarkDownRendererUTF8String;
var Index,TextLength,CodePoint,OutLength,TempLength:TMarkDownRendererInt32;
    Character:ansichar;
    NumberText:TMarkDownRendererUTF8String;
    TempBytes:array[0..3] of ansichar;
begin
 TempBytes[0]:=#0;
 TextLength:=length(aText);
 SetLength(Result,TextLength); // initial capacity: not smaller than input
 OutLength:=0;
 Index:=1;
 while Index<=TextLength do begin
  Character:=aText[Index];
  if Character='&' then begin
   // --- numeric entity ---
   if (Index+1<=TextLength) and (aText[Index+1]='#') then begin
    CodePoint:=0;
    // hexadecimal entity: &#xHHHH;
    if (Index+2<=TextLength) and ((aText[Index+2]='x') or (aText[Index+2]='X')) then begin
     NumberText:='';
     inc(Index,3);
     while (Index<=TextLength) and (aText[Index]<>';') do begin
      NumberText:=NumberText+aText[Index];
      inc(Index);
     end;
     for TempLength:=1 to length(NumberText) do begin
      case NumberText[TempLength] of
       '0'..'9':begin
        CodePoint:=(CodePoint shl 4)+(ord(NumberText[TempLength])-ord('0'));
       end;
       'a'..'f':begin
        CodePoint:=(CodePoint shl 4)+10+(ord(NumberText[TempLength])-ord('a'));
       end;
       'A'..'F':begin
        CodePoint:=(CodePoint shl 4)+10+(ord(NumberText[TempLength])-ord('A'));
       end;
      end;
     end;
     if (Index<=TextLength) and (aText[Index]=';') then begin
      inc(Index);
     end;
    end else begin
     // decimal entity: &#DDDD;
     NumberText:='';
     inc(Index,2);
     while (Index<=TextLength) and (aText[Index]<>';') do begin
      NumberText:=NumberText+aText[Index];
      inc(Index);
     end;
     if (Index<=TextLength) and (aText[Index]=';') then begin
      inc(Index);
     end;
     for TempLength:=1 to length(NumberText) do begin
      if (NumberText[TempLength]>='0') and (NumberText[TempLength]<='9') then begin
       CodePoint:=(CodePoint*10)+(ord(NumberText[TempLength])-ord('0'));
      end;
     end;
    end;
    // encode CodePoint into UTF-8 sequence
    if CodePoint<=$7F then begin
     TempBytes[0]:=ansichar(CodePoint);
     TempLength:=1;
    end else if CodePoint<=$7FF then begin
     TempBytes[0]:=ansichar($C0 or ((CodePoint shr 6) and $1F));
     TempBytes[1]:=ansichar($80 or (CodePoint and $3F));
     TempLength:=2;
    end else begin
     TempBytes[0]:=ansichar($E0 or ((CodePoint shr 12) and $0F));
     TempBytes[1]:=ansichar($80 or ((CodePoint shr 6) and $3F));
     TempBytes[2]:=ansichar($80 or (CodePoint and $3F));
     TempLength:=3;
    end;
    if OutLength+TempLength>length(Result) then begin
     SetLength(Result,(OutLength+TempLength)*2);
    end;
    Move(TempBytes[0],Result[OutLength+1],TempLength);
    inc(OutLength,TempLength);
    continue;
   end else begin
    // --- named entities ---
    if (Index+4<=TextLength) and (copy(aText,Index,5)='&amp;') then begin
     inc(OutLength);
     if OutLength>length(Result) then begin
      SetLength(Result,OutLength*2);
     end;
     Result[OutLength]:='&';
     inc(Index,5);
     continue;
    end;
    if (Index+3<=TextLength) and (copy(aText,Index,4)='&lt;') then begin
     inc(OutLength);
     if OutLength>length(Result) then begin
      SetLength(Result,OutLength*2);
     end;
     Result[OutLength]:='<';
     inc(Index,4);
     continue;
    end;
    if (Index+3<=TextLength) and (copy(aText,Index,4)='&gt;') then begin
     inc(OutLength);
     if OutLength>length(Result) then begin
      SetLength(Result,OutLength*2);
     end;
     Result[OutLength]:='>';
     inc(Index,4);
     continue;
    end;
    if (Index+5<=TextLength) and (copy(aText,Index,6)='&quot;') then begin
     inc(OutLength);
     if OutLength>length(Result) then begin
      SetLength(Result,OutLength*2);
     end;
     Result[OutLength]:='"';
     inc(Index,6);
     continue;
    end;
    if (Index+5<=TextLength) and (copy(aText,Index,6)='&apos;') then begin
     inc(OutLength);
     if OutLength>length(Result) then begin
      SetLength(Result,OutLength*2);
     end;
     Result[OutLength]:='''';
     inc(Index,6);
     continue;
    end;
   end;
  end;
  // normal character passthrough
  inc(OutLength);
  if OutLength>length(Result) then begin
   SetLength(Result,OutLength*2);
  end;
  Result[OutLength]:=Character;
  inc(Index);
 end;
 SetLength(Result,OutLength);
end;

function ReplaceTabs(const S:TMarkDownRendererUTF8String):TMarkDownRendererUTF8String;
var Index:TMarkDownRendererInt32;
    ResultBuilder:TMarkDownRendererUTF8String;
begin
 ResultBuilder:='';
 Index:=1;
 while Index<=length(S) do begin
  if S[Index]=#9 then begin
   ResultBuilder:=ResultBuilder+'    ';
  end else begin
   ResultBuilder:=ResultBuilder+S[Index];
  end;
  inc(Index);
 end;
 result:=ResultBuilder;
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntityEnumerator }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntityEnumerator.Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntityEnumerator.GetCurrent:TEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntityEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeyEnumerator }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeyEnumerator.Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeyEnumerator.GetCurrent:TMarkDownRendererHashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeyEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.THashMapValueEnumerator }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.THashMapValueEnumerator.Create(const aHashMap:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.THashMapValueEnumerator.GetCurrent:TMarkDownRendererHashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.THashMapValueEnumerator.MoveNext:boolean;
begin
 repeat
  inc(fIndex);
  if fIndex<fHashMap.fSize then begin
   if fHashMap.fEntities[fIndex].State=TEntity.Used then begin
    result:=true;
    exit;
   end;
  end else begin
   break;
  end;
 until false;
 result:=false;
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntitiesObject }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntitiesObject.Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TEntitiesObject.GetEnumerator:TEntityEnumerator;
begin
 result:=TEntityEnumerator.Create(fOwner);
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeysObject }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeysObject.Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TKeysObject.GetEnumerator:TKeyEnumerator;
begin
 result:=TKeyEnumerator.Create(fOwner);
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TValuesObject }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TValuesObject.Create(const aOwner:TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TValuesObject.GetEnumerator:THashMapValueEnumerator;
begin
 result:=THashMapValueEnumerator.Create(fOwner);
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TValuesObject.GetValue(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererHashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TValuesObject.SetValue(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;

{ TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue> }

constructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Create(const aDefaultValue:TMarkDownRendererHashMapValue);
begin
 inherited Create;
 fSize:=0;
 fLogSize:=0;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 fEntities:=nil;
 fDefaultValue:=aDefaultValue;
 fCanShrink:=true;
 fEntitiesObject:=TEntitiesObject.Create(self);
 fKeysObject:=TKeysObject.Create(self);
 fValuesObject:=TValuesObject.Create(self);
 Resize;
end;

destructor TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Destroy;
var Index:TMarkDownRendererSizeInt;
begin
 Clear;
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fEntities:=nil;
 FreeAndNil(fEntitiesObject);
 FreeAndNil(fKeysObject);
 FreeAndNil(fValuesObject);
 inherited Destroy;
end;

procedure TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Clear(const aCanFree:Boolean);
var Index:TMarkDownRendererSizeInt;
begin
 for Index:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Index].Key);
  Finalize(fEntities[Index].Value);
 end;
 fCountNonEmptyEntites:=0;
 fCountDeletedEntites:=0;
 if fCanShrink and aCanFree then begin
  fSize:=0;
  fLogSize:=0;
  fEntities:=nil;
  Resize;
 end else begin
  for Index:=0 to length(fEntities)-1 do begin
   fEntities[Index].State:=TEntity.Empty;
  end;
 end;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.HashKey(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererUInt32;
// xxHash32
const PRIME32_1=TMarkDownRendererUInt32(2654435761);
      PRIME32_2=TMarkDownRendererUInt32(2246822519);
      PRIME32_3=TMarkDownRendererUInt32(3266489917);
      PRIME32_4=TMarkDownRendererUInt32(668265263);
      PRIME32_5=TMarkDownRendererUInt32(374761393);
      Seed=TMarkDownRendererUInt32($1337c0d3);
      v1Initialization=TMarkDownRendererUInt32(TMarkDownRendererUInt64(TMarkDownRendererUInt64(Seed)+TMarkDownRendererUInt64(PRIME32_1)+TMarkDownRendererUInt64(PRIME32_2)));
      v2Initialization=TMarkDownRendererUInt32(TMarkDownRendererUInt64(TMarkDownRendererUInt64(Seed)+TMarkDownRendererUInt64(PRIME32_2)));
      v3Initialization=TMarkDownRendererUInt32(TMarkDownRendererUInt64(TMarkDownRendererUInt64(Seed)+TMarkDownRendererUInt64(0)));
      v4Initialization=TMarkDownRendererUInt32(TMarkDownRendererUInt64(TMarkDownRendererInt64(TMarkDownRendererInt64(Seed)-TMarkDownRendererInt64(PRIME32_1))));
      HashInitialization=TMarkDownRendererUInt32(TMarkDownRendererUInt64(TMarkDownRendererUInt64(Seed)+TMarkDownRendererUInt64(PRIME32_5)));
var v1,v2,v3,v4,DataLength:TMarkDownRendererUInt32;
    p,e{,Limit}:PMarkDownRendererUInt8;
begin
 p:=TMarkDownRendererPointer(@aKey[1]);
 DataLength:=length(aKey)*SizeOf(aKey[1]);
 if DataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PMarkDownRendererUInt8Array(TMarkDownRendererPointer(@aKey[1]))^[DataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2)),13)*TMarkDownRendererUInt32(PRIME32_1);
{$else}
   inc(v1,TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*TMarkDownRendererUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TMarkDownRendererUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2)),13)*TMarkDownRendererUInt32(PRIME32_1);
{$else}
   inc(v2,TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*TMarkDownRendererUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TMarkDownRendererUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2)),13)*TMarkDownRendererUInt32(PRIME32_1);
{$else}
   inc(v3,TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*TMarkDownRendererUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TMarkDownRendererUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2)),13)*TMarkDownRendererUInt32(PRIME32_1);
{$else}
   inc(v4,TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*TMarkDownRendererUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TMarkDownRendererUInt32));
  until {%H-}TMarkDownRendererPtrUInt(p)>{%H-}TMarkDownRendererPtrUInt(e);
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(v1,1)+ROLDWord(v2,7)+ROLDWord(v3,12)+ROLDWord(v4,18);
{$else}
  result:=((v1 shl 1) or (v1 shr 31))+
          ((v2 shl 7) or (v2 shr 25))+
          ((v3 shl 12) or (v3 shr 20))+
          ((v4 shl 18) or (v4 shr 14));
{$ifend}
 end else begin
  result:=HashInitialization;
 end;
 inc(result,DataLength);
 e:=@PMarkDownRendererUInt8Array(TMarkDownRendererPointer(@aKey[1]))^[DataLength];
 while ({%H-}TMarkDownRendererPtrUInt(p)+SizeOf(TMarkDownRendererUInt32))<={%H-}TMarkDownRendererPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_3)),17)*TMarkDownRendererUInt32(PRIME32_4);
{$else}
  inc(result,TMarkDownRendererUInt32(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*TMarkDownRendererUInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(TMarkDownRendererUInt32));
 end;
 while {%H-}TMarkDownRendererPtrUInt(p)<{%H-}TMarkDownRendererPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TMarkDownRendererUInt8(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_5)),11)*TMarkDownRendererUInt32(PRIME32_1);
{$else}
  inc(result,TMarkDownRendererUInt8(TMarkDownRendererPointer(p)^)*TMarkDownRendererUInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*TMarkDownRendererUInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(TMarkDownRendererUInt8));
 end;
 result:=(result xor (result shr 15))*TMarkDownRendererUInt32(PRIME32_2);
 result:=(result xor (result shr 13))*TMarkDownRendererUInt32(PRIME32_3);
 result:=result xor (result shr 16);
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-TMarkDownRendererUInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.FindEntity(const aKey:TMarkDownRendererHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TMarkDownRendererSizeUInt;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  if (result^.State=TEntity.Empty) or ((result^.State=TEntity.Used) and (result^.Key=aKey)) then begin
   exit;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=nil;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.FindEntityForAdd(const aKey:TMarkDownRendererHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TMarkDownRendererSizeUInt;
    DeletedEntity:PEntity;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 DeletedEntity:=nil;
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  case result^.State of
   TEntity.Empty:begin
    if assigned(DeletedEntity) then begin
     result:=DeletedEntity;
    end;
    exit;
   end;
   TEntity.Deleted:begin
    if not assigned(DeletedEntity) then begin
     DeletedEntity:=result;
    end;
   end;
   else {TEntity.Used:}begin
    if result^.Key=aKey then begin
     exit;
    end;
   end;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=DeletedEntity;
end;

procedure TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Resize;
var Index:TMarkDownRendererSizeInt;
    OldEntities:TEntities;
    OldEntity:PEntity;
begin

 fLogSize:={$ifdef cpu64}IntLog264{$else}IntLog2{$endif}(fCountNonEmptyEntites)+1;

 fSize:=2 shl fLogSize;

 fCountNonEmptyEntites:=0;

 fCountDeletedEntites:=0;

 OldEntities:=fEntities;

 fEntities:=nil;
 SetLength(fEntities,fSize);

 for Index:=0 to length(fEntities)-1 do begin
  fEntities[Index].State:=TEntity.Empty;
 end;

 if length(OldEntities)>0 then begin
  try
   for Index:=0 to length(OldEntities)-1 do begin
    OldEntity:=@OldEntities[Index];
    if OldEntity^.State=TEntity.Used then begin
     Add(OldEntity^.Key,OldEntity^.Value);
    end;
{   Finalize(OldEntity^.Key);
    Finalize(OldEntity^.Value);}
   end;
  finally
   OldEntities:=nil;
  end;
 end;

end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Add(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue):PEntity;
begin
 repeat
  while fCountNonEmptyEntites>=(1 shl fLogSize) do begin
   Resize;
  end;
  result:=FindEntityForAdd(aKey);
  if assigned(result) then begin
   case result^.State of
    TEntity.Empty:begin
     inc(fCountNonEmptyEntites);
    end;
    TEntity.Deleted:begin
     dec(fCountDeletedEntites);
    end;
    else begin
    end;
   end;
   result^.State:=TEntity.Used;
   result^.Key:=aKey;
   result^.Value:=aValue;
   break;
  end else begin
   Resize;
  end;
 until false;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Get(const aKey:TMarkDownRendererHashMapKey;const aCreateIfNotExist:boolean):PEntity;
var Value:TMarkDownRendererHashMapValue;
begin
 result:=FindEntity(aKey);
 if assigned(result) then begin
  case result^.State of
   TEntity.Used:begin
   end;
   else {TEntity.Empty,TEntity.Deleted:}begin
    if aCreateIfNotExist then begin
     Initialize(Value);
     result:=Add(aKey,Value);
    end else begin
     result:=nil;
    end;
   end;
  end;
 end else begin
  result:=nil;
 end;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.TryGet(const aKey:TMarkDownRendererHashMapKey;out aValue:TMarkDownRendererHashMapValue):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
  if result then begin
   aValue:=Entity^.Value;
  end else begin
   Initialize(aValue);
  end;
 end else begin
  result:=false;
 end;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.ExistKey(const aKey:TMarkDownRendererHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
 end else begin
  result:=false;
 end;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.Delete(const aKey:TMarkDownRendererHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
  if result then begin
   Entity^.State:=TEntity.Deleted;
   Finalize(Entity^.Key);
   Finalize(Entity^.Value);
   inc(fCountDeletedEntites);
   if fCanShrink and (fSize>=8) and (fCountDeletedEntites>=((fSize+3) shr 2)) then begin
    dec(fCountNonEmptyEntites,fCountDeletedEntites);
    Resize;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

function TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.GetValue(const aKey:TMarkDownRendererHashMapKey):TMarkDownRendererHashMapValue;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) and (Entity^.State=TEntity.Used) then begin
  result:=Entity^.Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TMarkDownRendererStringHashMap<TMarkDownRendererHashMapValue>.SetValue(const aKey:TMarkDownRendererHashMapKey;const aValue:TMarkDownRendererHashMapValue);
begin
 Add(aKey,aValue);
end;

///=== TLayoutItemList =======================================================

constructor TMarkDownRenderer.TLayoutItemList.Create;
begin
 inherited Create;
 SetLength(fItems,0);
 fCount:=0;
end;

destructor TMarkDownRenderer.TLayoutItemList.Destroy;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 inherited Destroy;
end;

procedure TMarkDownRenderer.TLayoutItemList.EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
var NewCapacity:TMarkDownRendererInt32;
begin
 if length(fItems)<aNeeded then begin
  NewCapacity:=length(fItems);
  if NewCapacity=0 then begin
   NewCapacity:=8;
  end;
  while NewCapacity<aNeeded do begin
   NewCapacity:=NewCapacity*2;
  end;
  SetLength(fItems,NewCapacity);
 end;
end;

procedure TMarkDownRenderer.TLayoutItemList.Clear;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 fCount:=0;
end;

function TMarkDownRenderer.TLayoutItemList.NewItem:TLayoutItem;
begin
 inc(fCount);
 EnsureCapacity(fCount);
 result:=TLayoutItem.Create;
 fItems[fCount-1]:=result;
 result.Kind:=TLayoutItemKind.LayoutText;
 result.X:=0; 
 result.Y:=0; 
 result.Width:=0; 
 result.Height:=0;
 result.Text:='';
 result.FontSize:=0; 
 result.FontStyle:=[];
 result.LinkHref:='';
 result.MetaA:=0; 
 result.MetaB:=0;
 result.Mono:=false;
 result.Mark:=false;
end;

function TMarkDownRenderer.TLayoutItemList.GetItem(const aIndex:TMarkDownRendererInt32):TLayoutItem;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

{=== TLinkHitRectList ======================================================}

constructor TMarkDownRenderer.TLinkHitRectList.Create;
begin
 inherited Create;
 SetLength(fItems,0);
 fCount:=0;
end;

destructor TMarkDownRenderer.TLinkHitRectList.Destroy;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 inherited Destroy;
end;

procedure TMarkDownRenderer.TLinkHitRectList.EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
var NewCapacity:TMarkDownRendererInt32;
begin
 if length(fItems)<aNeeded then begin
  NewCapacity:=length(fItems);
  if NewCapacity=0 then begin
   NewCapacity:=8;
  end;
  while NewCapacity<aNeeded do begin
   NewCapacity:=NewCapacity*2;
  end;
  SetLength(fItems,NewCapacity);
 end;
end;

procedure TMarkDownRenderer.TLinkHitRectList.Clear;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 fCount:=0;
end;

procedure TMarkDownRenderer.TLinkHitRectList.Add(const aX,aY,aWidth,aHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aHref:TMarkDownRendererUTF8String);
var RectObj:TLinkHitRect;
begin
 inc(fCount);
 EnsureCapacity(fCount);
 RectObj:=TLinkHitRect.Create;
 RectObj.X:=aX;
 RectObj.Y:=aY;
 RectObj.W:=aWidth;
 RectObj.H:=aHeight;
 RectObj.Href:=aHref;
 fItems[fCount-1]:=RectObj;
end;

function TMarkDownRenderer.TLinkHitRectList.GetItem(const aIndex:TMarkDownRendererInt32):TLinkHitRect;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

{=== Table model classes ===================================================}

constructor TMarkDownRenderer.TTableRow.Create;
begin
 inherited Create;
 fCells:=TTableCellList.Create;
end;

destructor TMarkDownRenderer.TTableRow.Destroy;
begin
 fCells.Free;
 inherited Destroy;
end;

constructor TMarkDownRenderer.TTable.Create;
begin
 inherited Create;
 fRows:=TTableRowList.Create;
 fRowCount:=0;
 fColCount:=0;
end;

destructor TMarkDownRenderer.TTable.Destroy;
begin
 fRows.Free;
 inherited Destroy;
end;

constructor TMarkDownRenderer.TTableCellList.Create;
begin
 inherited Create;
 SetLength(fItems,0);
 fCount:=0;
end;

destructor TMarkDownRenderer.TTableCellList.Destroy;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 inherited Destroy;
end;

procedure TMarkDownRenderer.TTableCellList.EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
var NewCapacity:TMarkDownRendererInt32;
begin
 if length(fItems)<aNeeded then begin
  NewCapacity:=length(fItems);
  if NewCapacity=0 then begin
   NewCapacity:=8;
  end;
  while NewCapacity<aNeeded do begin
   NewCapacity:=NewCapacity*2;
  end;
  SetLength(fItems,NewCapacity);
 end;
end;

procedure TMarkDownRenderer.TTableCellList.Clear;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 fCount:=0;
end;

function TMarkDownRenderer.TTableCellList.AddNew:TTableCell;
begin
 inc(fCount);
 EnsureCapacity(fCount);
 fItems[fCount-1]:=TTableCell.Create;
 fItems[fCount-1].Text:='';
 fItems[fCount-1].ColSpan:=1;
 fItems[fCount-1].RowSpan:=1;
 fItems[fCount-1].Node:=nil;
 result:=fItems[fCount-1];
end;

function TMarkDownRenderer.TTableCellList.GetItem(const aIndex:TMarkDownRendererInt32):TTableCell;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

constructor TMarkDownRenderer.TTableRowList.Create;
begin
 inherited Create;
 SetLength(fItems,0);
 fCount:=0;
end;

destructor TMarkDownRenderer.TTableRowList.Destroy;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 inherited Destroy;
end;

procedure TMarkDownRenderer.TTableRowList.EnsureCapacity(const aNeeded:TMarkDownRendererInt32);
var NewCapacity:TMarkDownRendererInt32;
begin
 if length(fItems)<aNeeded then begin
  NewCapacity:=length(fItems);
  if NewCapacity=0 then begin
   NewCapacity:=8;
  end;
  while NewCapacity<aNeeded do begin
   NewCapacity:=NewCapacity*2;
  end;
  SetLength(fItems,NewCapacity);
 end;
end;

procedure TMarkDownRenderer.TTableRowList.Clear;
var Index:TMarkDownRendererInt32;
begin
 for Index:=0 to fCount-1 do begin
  fItems[Index].Free;
 end;
 SetLength(fItems,0);
 fCount:=0;
end;

function TMarkDownRenderer.TTableRowList.AddNew:TTableRow;
begin
 inc(fCount);
 EnsureCapacity(fCount);
 fItems[fCount-1]:=TTableRow.Create;
 result:=fItems[fCount-1];
end;

function TMarkDownRenderer.TTableRowList.GetItem(const aIndex:TMarkDownRendererInt32):TTableRow;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

{=== Renderer ctor/dtor ====================================================}

constructor TMarkDownRenderer.Create;
var TextSizeCacheItem:TTextSizeCacheItem;
begin
 inherited Create;

 FillChar(TextSizeCacheItem,SizeOf(TTextSizeCacheItem),#0);
 fTextSizeCacheHashMap:=TTextSizeCacheHashMap.Create(TextSizeCacheItem);

 fItems:=TLayoutItemList.Create;
 fLinkRects:=TLinkHitRectList.Create;

 fCalculatedWidth:=0;
 fCalculatedHeight:=0;
 fMaxWidth:=0;

 fLineX:=0;
 fLineY:=0;
 fLineWidth:=0;
 fLineHeight:=0;
 fLineAboveExtra:=0;
 fLineBelowExtra:=0;
 fLineItemStartIndex:=0;
 fLinkRectStartIndex:=0;
 fParagraphSpacing:=6;
 fIndentStep:=16;
 fCurrentIndent:=0;

 fListDepth:=0;
 FillChar(fOrderedListDepthCount,SizeOf(fOrderedListDepthCount),#0);

 fBaseFontSize:=12;
 fNeedSpaceBeforeNextText:=false;
 fTargetDPI:=96;
 fFontName:='Sans Serif';
 fMonoFontName:='Monospace';

{$ifdef FMX}
 fBGCodeColor:=TColorRec.cINFOBK;
 fFontCodeColor:=TColorRec.cINFOTEXT;
 fBGMarkColor:=TColorRec.cHIGHLIGHT;
 fFontMarkColor:=TColorRec.cHIGHLIGHTTEXT;
 fBGThinkColor:=TColorRec.cWINDOW;
 fFontThinkColor:=TColorRec.cGRAYTEXT;

 fBGColor:=TColorRec.cWINDOW;
 fFontColor:=TColorRec.cWINDOWTEXT;
 fFontQuoteColor:=TColorRec.cWINDOWFRAME;
{$else}
 fBGCodeColor:=clInfoBk;
 fFontCodeColor:=clInfoText;
 fBGMarkColor:=clYellow;
 fFontMarkColor:=clBlack;
 fBGThinkColor:=clWindow;
 fFontThinkColor:=clGrayText;

 fBGColor:=clWindow;
 fFontColor:=clWindowText;
 fFontQuoteColor:=clWindowFrame;
{$endif}

 fHTMLDoc:=THTML.Create;

 fBaselineShiftCurrent:=0;
 fMarkActive:=false;
 fThinkActive:=false;

end;

destructor TMarkDownRenderer.Destroy;
begin
 FreeAndNil(fItems);
 FreeAndNil(fLinkRects);
 FreeAndNil(fHTMLDoc);
 FreeAndNil(fTextSizeCacheHashMap);
 inherited Destroy;
end;

function TMarkDownRenderer.DIP(const aValue:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 // scale integer based on target DPI (reference 96)
{$ifdef FMX}
 result:=(aValue*fTargetDPI)/96.0;
{$else}
 result:=(aValue*fTargetDPI+48) div 96;
{$endif}
end;

procedure TMarkDownRenderer.Clear;
begin
 fItems.Clear;
 fLinkRects.Clear;
 fCalculatedWidth:=0;
 fCalculatedHeight:=0;
 fMaxWidth:=0;

 fLineX:=0;
 fLineY:=0;
 fLineWidth:=0;
 fLineHeight:=0;
 fLineAboveExtra:=0;
 fLineBelowExtra:=0;
 fLineItemStartIndex:=0;
 fLinkRectStartIndex:=0;
 fCurrentIndent:=0;
 fNeedSpaceBeforeNextText:=false;

 fListDepth:=0;
 FillChar(fOrderedListDepthCount,SizeOf(fOrderedListDepthCount),#0);

 fBaselineShiftCurrent:=0;
end;

procedure TMarkDownRenderer.BeginLayout;
begin
 Clear;
 // start of first line
 fLineItemStartIndex:=0;
 fLinkRectStartIndex:=0;
end;

procedure TMarkDownRenderer.EndLayout;
begin
 // reserved for future batching hooks
end;

procedure TMarkDownRenderer.ApplyFont(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean);
begin
 if aUseMono then begin
  if length(fMonoFontName)>0 then begin
{$ifdef FMX}
   if aCanvas.Font.Family<>fMonoFontName then begin
    aCanvas.Font.Family:=fMonoFontName;
   end;
{$else}
   aCanvas.Font.Name:=fMonoFontName;
{$endif}
  end;
 end else begin
  if length(fFontName)>0 then begin
{$ifdef FMX}
   if aCanvas.Font.Family<>fFontName then begin
    aCanvas.Font.Family:=fFontName;
   end;
{$else}
   aCanvas.Font.Name:=fFontName;
{$endif}
  end;
 end;
 if aCanvas.Font.Size<>aFontSize then begin
  aCanvas.Font.Size:=aFontSize;
 end;
 if aCanvas.Font.Style<>aFontStyle then begin
  aCanvas.Font.Style:=aFontStyle;
 end;
 if aIsBlockQuote then begin
{$ifdef FMX}
  fCurrentFontColor:=fFontQuoteColor;
{$else}
  aCanvas.Font.Color:=fFontQuoteColor;
{$endif}
 end else if aUseCode then begin
{$ifdef FMX}
  fCurrentFontColor:=fFontCodeColor;
{$else}
  aCanvas.Font.Color:=fFontCodeColor;
{$endif}
 end else begin
{$ifdef FMX}
  fCurrentFontColor:=fFontColor;
{$else}
  aCanvas.Font.Color:=fFontColor;
{$endif}
 end;
end;

procedure TMarkDownRenderer.MeasureText(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean;out aWidth,aHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var HashString:RawByteString;
    Size:TMarkDownRendererInt32;
    TextSizeCacheItem:TTextSizeCacheItem;
begin
 if length(aText)>0 then begin
  Size:=SizeOf(aFontSize)+SizeOf(aFontStyle)+SizeOf(TMarkdownRendererUInt8)+SizeOf(TMarkdownRendererUInt8)+SizeOf(TMarkdownRendererUInt8)+length(aText);
  HashString:='';
  SetLength(HashString,Size);
  Move(aFontSize,HashString[1],SizeOf(aFontSize));
  Move(aFontStyle,HashString[SizeOf(aFontSize)+1],SizeOf(aFontStyle));
  if aUseMono then begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+1]:=#1;
  end else begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+1]:=#0;
  end;
  if aUseCode then begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+(SizeOf(TMarkdownRendererUInt8)*1)+1]:=#1;
  end else begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+(SizeOf(TMarkdownRendererUInt8)*1)+1]:=#0;
  end;
  if aIsBlockQuote then begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+(SizeOf(TMarkdownRendererUInt8)*2)+1]:=#1;
  end else begin
   HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+(SizeOf(TMarkdownRendererUInt8)*2)+1]:=#0;
  end;
  Move(aText[1],HashString[SizeOf(aFontSize)+SizeOf(aFontStyle)+(SizeOf(TMarkdownRendererUInt8)*3)+1],length(aText));
  if fTextSizeCacheHashMap.TryGet(HashString,TextSizeCacheItem) then begin
   aWidth:=TextSizeCacheItem.Width;
   aHeight:=TextSizeCacheItem.Height;
  end else begin
   ApplyFont(aCanvas,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
{$ifdef fpc}
   aWidth:=aCanvas.TextWidth(aText);
   aHeight:=aCanvas.TextHeight(aText+MaxHeightString);
{$else}
{$ifdef fmx}
   aWidth:=aCanvas.TextWidth(aText);
   aHeight:=aCanvas.TextHeight(aText+MaxHeightString);
{$else}
   aWidth:=aCanvas.TextWidth(UTF8Decode(aText));
   aHeight:=aCanvas.TextHeight(UTF8Decode(aText+MaxHeightString));
{$endif}
{$endif}
   TextSizeCacheItem.Width:=aWidth;
   TextSizeCacheItem.Height:=aHeight;
   fTextSizeCacheHashMap.Add(HashString,TextSizeCacheItem);   
  end;
 end else begin
  aWidth:=0;
  aHeight:=0;
 end;
end;

function TMarkDownRenderer.MeasureTextWidth(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
{begin
 ApplyFont(aCanvas,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
 result:=aCanvas.TextWidth(aText);
end;}
var Width,Height:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin 
 MeasureText(aCanvas,aText,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote,Width,Height);
 result:=Width;
end;

function TMarkDownRenderer.MeasureTextHeight(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aUseMono,aUseCode,aIsBlockQuote:boolean):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
{begin
 ApplyFont(aCanvas,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
 result:=aCanvas.TextHeight(MaxHeightString);
end;}
var Width,Height:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 MeasureText(aCanvas,MaxHeightString,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote,Width,Height);
 result:=Height;
end;

procedure TMarkDownRenderer.NewLine(const aCanvas:TCanvas);
begin
 fLineX:=0;
 // advance by top overhang + content height + below overhang
 fLineY:=fLineY+(fLineAboveExtra+fLineHeight+fLineBelowExtra);
 fLineHeight:=0;
 fLineAboveExtra:=0;
 fLineBelowExtra:=0;
 // start indices for new line items/links
 fLineItemStartIndex:=fItems.Count;
 fLinkRectStartIndex:=fLinkRects.Count;
 fNeedSpaceBeforeNextText:=false;
end;

procedure TMarkDownRenderer.ParagraphBreak(const aCanvas:TCanvas);
begin
 if fLineX<>0 then begin
  NewLine(aCanvas);
 end;
 fLineY:=fLineY+DIP(fParagraphSpacing);
 fLineAboveExtra:=0;
 fLineBelowExtra:=0;
 fLineItemStartIndex:=fItems.Count;
 fLinkRectStartIndex:=fLinkRects.Count;
end;
 
procedure TMarkDownRenderer.ShiftCurrentLineItems(const aDeltaY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var Index:TMarkDownRendererInt32;
    Item:TLayoutItem;
    LinkObj:TLinkHitRect;
begin
 if aDeltaY=0 then begin
  exit;
 end;
 // shift items of current line
 Index:=fLineItemStartIndex;
 while Index<fItems.Count do begin
  Item:=fItems[Index];
  if assigned(Item) then begin
   Item.Y:=Item.Y+aDeltaY;
  end;
  inc(Index);
 end;
 // shift link rects of current line
 Index:=fLinkRectStartIndex;
 while Index<fLinkRects.Count do begin
  LinkObj:=fLinkRects[Index];
  if assigned(LinkObj) then begin
   LinkObj.Y:=LinkObj.Y+aDeltaY;
  end;
  inc(Index);
 end;
end;

procedure TMarkDownRenderer.FlushTextRun(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aLinkHref:TMarkDownRendererUTF8String;const aUseMono,aUseCode,aIsBlockQuote:boolean;const aDryRun:boolean);
var Item:TLayoutItem;
    TextHeight,TextWidth,RectX,RectY,
    BaselineShift,TopOver,BottomOver,DeltaY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin

 if length(aText)>0 then begin

  TextWidth:=MeasureTextWidth(aCanvas,aText,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
  TextHeight:=MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);

  BaselineShift:=fBaselineShiftCurrent;
  if BaselineShift<0 then begin
   TopOver:=-BaselineShift;
  end else begin
   TopOver:=0;
  end;
  if BaselineShift>0 then begin
   BottomOver:=BaselineShift;
  end else begin
   BottomOver:=0;
  end;

    // if superscript introduces top overhang, push current line down accordingly
  if TopOver>fLineAboveExtra then begin
   DeltaY:=TopOver-fLineAboveExtra;
   fLineAboveExtra:=TopOver;
   if not aDryRun then begin
    ShiftCurrentLineItems(DeltaY);
   end;
  end;

    // ensure line height includes subscript bottom overhang
  if fLineHeight<(TextHeight+BottomOver) then begin
   fLineHeight:=TextHeight+BottomOver;
  end;
  if BottomOver>fLineBelowExtra then begin
   fLineBelowExtra:=BottomOver;
  end;

  if not aDryRun then begin

   Item:=fItems.NewItem;
   Item.Kind:=TLayoutItemKind.LayoutText;
   Item.X:=fCurrentIndent+fLineX;
    Item.Y:=fLineY+fLineAboveExtra+BaselineShift; // apply baseline shift and top overhang
   Item.Width:=TextWidth;
   Item.Height:=TextHeight;
   Item.Text:=aText;
   Item.FontSize:=aFontSize;
   Item.FontStyle:=aFontStyle;
   Item.LinkHref:=aLinkHref;
   Item.Mono:=aUseMono;
   Item.Code:=aUseCode;
   Item.BlockQuote:=aIsBlockQuote;
   Item.Mark:=fMarkActive;
   Item.Think:=fThinkActive;

   RectX:=Item.X;
   RectY:=Item.Y;

   if length(aLinkHref)<>0 then begin
    fLinkRects.Add(RectX,RectY,TextWidth,TextHeight,aLinkHref);
   end;

  end;

  fLineX:=fLineX+TextWidth;
  if fLineWidth<(fCurrentIndent+fLineX) then begin
   fLineWidth:=fCurrentIndent+fLineX;
  end;
  if fCalculatedWidth<(fCurrentIndent+fLineX) then begin
   fCalculatedWidth:=(fCurrentIndent+fLineX);
  end;

 end;
end;

procedure TMarkDownRenderer.LayoutTextWrapped(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aLinkHref:TMarkDownRendererUTF8String;const aUseMono,aUseCode,aIsBlockQuote:boolean;const aPreserveWhitespace,aDryRun:boolean);
var Index,TextLength:TMarkDownRendererInt32;
    Character:ansichar;
    WordBuffer,LineBuffer,LocalText:TMarkDownRendererUTF8String;
    TextHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    NeedSpace:boolean;

 procedure FlushCurrentLine;
 begin
  if length(LineBuffer)>0 then begin
   FlushTextRun(aCanvas,TrimRightSpaces(LineBuffer),aFontSize,aFontStyle,aLinkHref,aUseMono,aUseCode,aIsBlockQuote,aDryRun);
   LineBuffer:='';
  end;
 end;

 function NextUTF8CharLenAt(const aString:TMarkDownRendererUTF8String;const aPosition:TMarkdownRendererInt32):TMarkdownRendererInt32;
 var ByteValue:TMarkdownRendererUInt8;
 begin
  if (aPosition<1) or (aPosition>length(aString)) then begin
   result:=0;
   exit;
  end;
  ByteValue:=TMarkdownRendererUInt8(aString[aPosition]);
  if ByteValue<$80 then begin
   result:=1;
  end else if (ByteValue and $e0)=$c0 then begin
   result:=2;
  end else if (ByteValue and $f0)=$e0 then begin
   result:=3;
  end else begin
   result:=4;
  end;
 end;

 procedure BreakLongWord(const aWord:TMarkDownRendererUTF8String);
 var CharPos,WordLen,CharLen:TMarkDownRendererInt32;
     CharBuffer,CurrentChar:TMarkDownRendererUTF8String;
     CharWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 begin

  WordLen:=length(aWord);
  CharBuffer:='';
  CharPos:=1;

  while CharPos<=WordLen do begin

   CharLen:=NextUTF8CharLenAt(aWord,CharPos);
   if CharLen<=0 then begin
    CharLen:=1; // fallback for invalid UTF-8
   end;
   
   CurrentChar:=copy(aWord,CharPos,CharLen);
   CharWidth:=MeasureTextWidth(aCanvas,CharBuffer+CurrentChar,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);

   if (fCurrentIndent+fLineX+CharWidth)>fMaxWidth then begin
    if length(CharBuffer)>0 then begin
     FlushTextRun(aCanvas,CharBuffer,aFontSize,aFontStyle,aLinkHref,aUseMono,aUseCode,aIsBlockQuote,aDryRun);
     CharBuffer:='';
    end;
    NewLine(aCanvas);
    CharBuffer:=CurrentChar;
   end else begin
    CharBuffer:=CharBuffer+CurrentChar;
   end;
   
   inc(CharPos,CharLen);
  end;

  if length(CharBuffer)>0 then begin
   FlushTextRun(aCanvas,CharBuffer,aFontSize,aFontStyle,aLinkHref,aUseMono,aUseCode,aIsBlockQuote,aDryRun);
  end;

  NeedSpace:=true;
  
 end;

 procedure AddWordToLine(const aWord:TMarkDownRendererUTF8String);
 var TestLine:TMarkDownRendererUTF8String;
     TestWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 begin

  if length(aWord)>0 then begin

   // Build test line with potential space
   TestLine:=LineBuffer;
   if NeedSpace and (length(LineBuffer)>0) then begin
    TestLine:=TestLine+' ';
   end;
   TestLine:=TestLine+aWord;
   
   TestWidth:=MeasureTextWidth(aCanvas,TestLine,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
   
   if (fCurrentIndent+fLineX+TestWidth)<=fMaxWidth then begin
    // aWord fits on current line
    if NeedSpace and (length(LineBuffer)>0) then begin
     LineBuffer:=LineBuffer+' ';
    end else if NeedSpace and (length(LineBuffer)=0) and (fLineX>0) then begin
     // Add space at start of line buffer if we're continuing text on the same line
     LineBuffer:=' ';
    end;
    LineBuffer:=LineBuffer+aWord;
    NeedSpace:=true;
   end else begin
    // aWord doesn't fit, flush current line and try on new line
    FlushCurrentLine;
    NewLine(aCanvas);
    NeedSpace:=false;
    
    // Check if aWord fits on new line
    TestWidth:=MeasureTextWidth(aCanvas,aWord,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
    if (fCurrentIndent+fLineX+TestWidth)<=fMaxWidth then begin
     LineBuffer:=aWord;
     NeedSpace:=true;
    end else begin
     // aWord is too long, break it character by character
     BreakLongWord(aWord);
    end;
   end;
  end;

 end;

var FirstIndex,LastIndex:TMarkDownRendererInt32;
begin

 LocalText:=ConvertEntities(aText,THTML.TCharset.UTF_8,aPreserveWhitespace); //HTMLDecodeUTF8String(aText);
 
 if length(LocalText)>0 then begin

  TextHeight:=MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,aUseCode,aIsBlockQuote);
  if TextHeight>fLineHeight then begin
   fLineHeight:=TextHeight;
  end;

  TextLength:=length(LocalText);
  Index:=1;
  WordBuffer:='';
  LineBuffer:='';
  NeedSpace:=fNeedSpaceBeforeNextText;

  FirstIndex:=-1;
  LastIndex:=-1;

  while Index<=TextLength do begin
   Character:=LocalText[Index];

   case Character of
    
    #32,#9,#13,#10:begin

     // Whitespace - end of word, process accumulated word
     if FirstIndex>=0 then begin
      // We were accumulating a word, extract it
      WordBuffer:=copy(LocalText,FirstIndex,(LastIndex-FirstIndex)+1);
      FirstIndex:=-1;
      LastIndex:=-1;
     end;
     if length(WordBuffer)>0 then begin
      AddWordToLine(WordBuffer);
      WordBuffer:='';
     end;

     if aPreserveWhitespace and not (Character in [#13,#10]) then begin

      NeedSpace:=false;

      AddWordToLine(Character);

      NeedSpace:=false;

     end else begin

      NeedSpace:=true;

     end;

     // Handle CRLF pairs - skip the LF if we just processed a CR
     if (Character=#13) and (Index<TextLength) and (LocalText[Index+1]=#10) then begin
      inc(Index);
     end;     
    
    end;
    else begin
     // Regular character - add to current word
     if FirstIndex<0 then begin
      FirstIndex:=Index;
     end;
     LastIndex:=Index;
     //WordBuffer:=WordBuffer+Character;
    end;

   end;

   inc(Index);
  end;

  // Process final word if any
  if FirstIndex>=0 then begin
   // We were accumulating a word, extract it
   WordBuffer:=copy(LocalText,FirstIndex,(LastIndex-FirstIndex)+1);
   FirstIndex:=-1;
   LastIndex:=-1;
  end;
  if length(WordBuffer)>0 then begin
   AddWordToLine(WordBuffer);
  end;

  // Flush final line
  FlushCurrentLine;

  // Update global flag based on whether original text ended with whitespace
  if length(LocalText)>0 then begin
   case LocalText[length(LocalText)] of
    #32,#9,#13,#10:begin
     fNeedSpaceBeforeNextText:=true;
    end; 
    else begin
     fNeedSpaceBeforeNextText:=false;
    end; 
   end;
  end else begin
   fNeedSpaceBeforeNextText:=false;
  end;

 end;

end;

procedure TMarkDownRenderer.LayoutHR(const aCanvas:TCanvas;const aIsBlockQuote:Boolean);
var Item:TLayoutItem;
    YLine:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 if fLineX<>0 then begin
  ParagraphBreak(aCanvas);
 end;
 // draw at current baseline for stability
 YLine:=fLineY;
//YLine:=fLineY+MeasureTextHeight(aCanvas,fBaseFontSize,[],false) div 2;
 Item:=fItems.NewItem;
 Item.Kind:=TLayoutItemKind.LayoutHR;
 Item.X:=fCurrentIndent;
 Item.Y:=YLine;
 Item.Width:=fMaxWidth-fCurrentIndent;
 Item.Height:=1;
 NewLine(aCanvas);
 ParagraphBreak(aCanvas);
end;

procedure TMarkDownRenderer.LayoutBullet(const aCanvas:TCanvas;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aIsBlockQuote:Boolean);
var Item:TLayoutItem;
    FontHeight,DeltaY,Size:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 FontHeight:=MeasureTextHeight(aCanvas,aFontSize,aFontStyle,false,false,aIsBlockQuote);
 if fLineHeight<FontHeight then begin
  fLineHeight:=FontHeight;
 end;
 Item:=fItems.NewItem;
 Item.Kind:=TLayoutItemKind.LayoutBullet;
 Size:=DIP(6);
 Item.Width:=Size;
 Item.Height:=Size;
 DeltaY:={$ifdef FMX}(FontHeight-Size)*0.5{$else}(FontHeight-Size) div 2{$endif};
 Item.X:=fCurrentIndent+DIP(2);
 Item.Y:=fLineY+DeltaY;
end;

procedure TMarkDownRenderer.LayoutCodeBlock(const aCanvas:TCanvas;const aText:TMarkDownRendererUTF8String;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var Pass,Index,TextLength,LineStart,LineEnd,OldItemStart,OldLinkStart:TMarkDownRendererInt32;
    OldLineY,OldLineHeight,OldAbove,OldBelow,
    OldBaseline,MaxWidth,BlockHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    LineText,ProcessedText:TMarkDownRendererUTF8String;
    BackgroundItem:TLayoutItem;
begin

 if fLineX<>0 then begin
  ParagraphBreak(aCanvas);
 end;

 ProcessedText:=ReplaceTabs(aText);
 TextLength:=length(ProcessedText);
 
 if TextLength=0 then begin
  ParagraphBreak(aCanvas);
  exit;
 end;

{// First pass: measure maximum line width
 MaxWidth:=0;
 Index:=1;
 LineStart:=1;
 
 while Index<=TextLength do begin

  case ProcessedText[Index] of

   #13,#10:begin

    // Found line break - measure current line
    LineEnd:=Index-1;
    if LineEnd>=LineStart then begin
     LineText:=copy(ProcessedText,LineStart,LineEnd-LineStart+1);
     if MeasureTextWidth(aCanvas,LineText,aFontSize,[],true)>MaxWidth then begin
      MaxWidth:=MeasureTextWidth(aCanvas,LineText,aFontSize,[],true);
     end;
    end;

    // Skip line break characters (handle CRLF pairs)
    if (ProcessedText[Index]=#13) and ((Index+1)<=TextLength) and (ProcessedText[Index+1]=#10) then begin
     inc(Index,2); // Skip both CR and LF
    end else begin
     inc(Index); // Skip single LF or CR
    end;
    LineStart:=Index;
   end;

   else begin
    inc(Index);
   end;

  end;

 end;
 
 // Handle final line if text doesn't end with line break
 if LineStart<=TextLength then begin
  LineText:=copy(ProcessedText,LineStart,TextLength-LineStart+1);
  if MeasureTextWidth(aCanvas,LineText,aFontSize,[],true)>MaxWidth then begin
   MaxWidth:=MeasureTextWidth(aCanvas,LineText,aFontSize,[],true);
  end;
 end;}

 MaxWidth:=0;

 OldLineY:=0;
 OldLineHeight:=0;

 fLineWidth:=0;

 BackgroundItem:=nil;

 for Pass:=0 to 1 do begin

  case Pass of

   0:begin
    OldLineY:=fLineY;
    OldLineHeight:=fLineHeight;
    OldAbove:=fLineAboveExtra;
    OldBelow:=fLineBelowExtra;
    OldItemStart:=fLineItemStartIndex;
    OldLinkStart:=fLinkRectStartIndex;
    OldBaseline:=fBaselineShiftCurrent;
   end;

   1:begin

    // Create background item
    BackgroundItem:=fItems.NewItem;
    BackgroundItem.Kind:=TLayoutItemKind.LayoutCodeBG;
    BackgroundItem.X:=fCurrentIndent;
    BackgroundItem.Y:=fLineY;
    BackgroundItem.Width:=MaxWidth+DIP(8);
    BackgroundItem.Height:=0;

   end;

   else begin
   end;

  end;

  // Second pass: render lines
  Index:=1;
  LineStart:=1;

  while Index<=TextLength do begin

   case ProcessedText[Index] of

    #13,#10:begin

     // Found line break - render current line
     LineEnd:=Index-1;
     if LineEnd>=LineStart then begin
      LineText:=copy(ProcessedText,LineStart,LineEnd-LineStart+1);
     end else begin
      LineText:=' '; // Empty line
     end;
     LayoutTextWrapped(aCanvas,LineText,aFontSize,[],'',true,true,false,true,Pass=0);
     MaxWidth:=Max(MaxWidth,fLineWidth-fCurrentIndent);
     NewLine(aCanvas);

     // Skip line break characters (handle CRLF pairs)
     if (ProcessedText[Index]=#13) and ((Index+1)<=TextLength) and (ProcessedText[Index+1]=#10) then begin
      inc(Index,2); // Skip both CR and LF
     end else begin
      inc(Index); // Skip single LF or CR
     end;
     LineStart:=Index;

    end;

    else begin
     inc(Index);
    end;

   end;

  end;

  // Handle final line if text doesn't end with line break
  if LineStart<=TextLength then begin
   LineText:=copy(ProcessedText,LineStart,TextLength-LineStart+1);
   LayoutTextWrapped(aCanvas,LineText,aFontSize,[],'',true,true,false,true,Pass=0);
   MaxWidth:=Max(MaxWidth,fLineWidth-fCurrentIndent);
   NewLine(aCanvas);
  end;

  case Pass of

   0:begin
    fLineY:=OldLineY;
    fLineHeight:=OldLineHeight;
    fLineAboveExtra:=OldAbove;
    fLineBelowExtra:=OldBelow;
    fLineItemStartIndex:=OldItemStart;
    fLinkRectStartIndex:=OldLinkStart;
    fBaselineShiftCurrent:=OldBaseline;
    fLineX:=0;
   end;

   1:begin

    if assigned(BackgroundItem) then begin

     BlockHeight:=fLineY-BackgroundItem.Y;
     BackgroundItem.Height:=BlockHeight;
     ParagraphBreak(aCanvas);

    end;

   end;

  end;

 end;


end;

function TMarkDownRenderer.HeaderFontSize(const aLevel:TMarkDownRendererInt32;const aBase:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 case aLevel of
  1:begin 
   result:=aBase+10; 
  end;
  2:begin 
   result:=aBase+8; 
  end;
  3:begin 
   result:=aBase+6; 
  end;
  4:begin 
   result:=aBase+4; 
  end;
  5:begin 
   result:=aBase+2; 
  end;
  else begin 
   result:=aBase+0; 
  end;
 end;
end;

function TMarkDownRenderer.ExtractNodeText(const aNode:THTML.TNode):TMarkDownRendererUTF8String;
var ChildIndex:TMarkDownRendererInt32;
begin
 result:='';
 if not assigned(aNode) then begin
  exit;
 end;
 if aNode.NodeType=THTML.TNodeType.Text then begin
  result:=result+aNode.Text;
 end else begin
  if aNode.NodeType=THTML.TNodeType.Tag then begin
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     result:=result+ExtractNodeText(aNode.Children[ChildIndex]);
     inc(ChildIndex);
    end;
   end;
  end;
 end;
end;

function TMarkDownRenderer.GetAttrInt(const aNode:THTML.TNode;const aKey:TMarkdownRendererUTF8String;const aDefaultValue:TMarkDownRendererInt32):TMarkDownRendererInt32;
var TagParameter:THTML.TTagParameter;
begin
 TagParameter:=aNode.TagParameters.FindByName(aKey);
 if assigned(TagParameter) then begin
  result:=StrToIntDef(TagParameter.Value,aDefaultValue);
 end else begin
  result:=aDefaultValue;
 end;
end;

procedure TMarkDownRenderer.CollectTable(const aNode:THTML.TNode;out aTableModel:TTable);
var RowList:THTML.TNodeList;
    RowNode,CellNode,SubRowNode:THTML.TNode;
    RowIndex,CellIndex,SubRowIndex,SumColumns:TMarkDownRendererInt32;
    NewRow:TTableRow;
    NewCell:TTableCell;
    ColSpanVal,RowSpanVal:TMarkDownRendererInt32;
    TagUpper:TMarkDownRendererUTF8String;
begin
 aTableModel:=TTable.Create;

 RowList:=aNode.Children;
 if not assigned(RowList) then begin
  exit;
 end;

 RowIndex:=0;
 while RowIndex<RowList.Count do begin
  RowNode:=RowList[RowIndex];
  if assigned(RowNode) then begin
   if RowNode.NodeType=THTML.TNodeType.Tag then begin
    TagUpper:=UpperCase(RowNode.TagName);
    if TagUpper='TR' then begin
     NewRow:=aTableModel.Rows.AddNew;
     inc(aTableModel.fRowCount);
     CellIndex:=0;
     SumColumns:=0;
     while CellIndex<RowNode.Children.Count do begin
      CellNode:=RowNode.Children[CellIndex];
      if assigned(CellNode) then begin
       if CellNode.NodeType=THTML.TNodeType.Tag then begin
        TagUpper:=UpperCase(CellNode.TagName);
        if (TagUpper='TD') or (TagUpper='TH') then begin
         NewCell:=NewRow.Cells.AddNew;
         NewCell.Text:=ExtractNodeText(CellNode);
         NewCell.Node:=CellNode;
         ColSpanVal:=GetAttrInt(CellNode,'colspan',1);
         RowSpanVal:=GetAttrInt(CellNode,'rowspan',1);
         if ColSpanVal<1 then begin ColSpanVal:=1; end;
         if RowSpanVal<1 then begin RowSpanVal:=1; end;
         NewCell.ColSpan:=ColSpanVal;
         NewCell.RowSpan:=RowSpanVal;
         inc(SumColumns,ColSpanVal);
        end;
       end;
      end;
      inc(CellIndex);
     end;
     if SumColumns>aTableModel.fColCount then begin
      aTableModel.fColCount:=SumColumns;
     end;
    end;
   end;
  end;
  inc(RowIndex);
 end;

 // handle thead/tbody/tfoot containers (flatten rows)
 RowIndex:=0;
 while RowIndex<RowList.Count do begin
  RowNode:=RowList[RowIndex];
  if assigned(RowNode) then begin
   if RowNode.NodeType=THTML.TNodeType.Tag then begin
    TagUpper:=UpperCase(RowNode.TagName);
    if (TagUpper='THEAD') or (TagUpper='TBODY') or (TagUpper='TFOOT') then begin
     SubRowIndex:=0;
     if assigned(RowNode.Children) then begin
      while SubRowIndex<RowNode.Children.Count do begin
       SubRowNode:=RowNode.Children[SubRowIndex];
       if assigned(SubRowNode) then begin
        if SubRowNode.NodeType=THTML.TNodeType.Tag then begin
         TagUpper:=UpperCase(SubRowNode.TagName);
         if TagUpper='TR' then begin
          NewRow:=aTableModel.Rows.AddNew;
          inc(aTableModel.fRowCount);
          CellIndex:=0;
          SumColumns:=0;
          if assigned(SubRowNode.Children) then begin
           while CellIndex<SubRowNode.Children.Count do begin
            CellNode:=SubRowNode.Children[CellIndex];
            if assigned(CellNode) then begin
             if CellNode.NodeType=THTML.TNodeType.Tag then begin
              TagUpper:=UpperCase(CellNode.TagName);
              if (TagUpper='TD') or (TagUpper='TH') then begin
               NewCell:=NewRow.Cells.AddNew;
               NewCell.Text:=ExtractNodeText(CellNode);
               NewCell.Node:=CellNode;
               ColSpanVal:=GetAttrInt(CellNode,'colspan',1);
               RowSpanVal:=GetAttrInt(CellNode,'rowspan',1);
               if ColSpanVal<1 then begin
                ColSpanVal:=1;
               end;
               if RowSpanVal<1 then begin
                RowSpanVal:=1;
               end;
               NewCell.ColSpan:=ColSpanVal;
               NewCell.RowSpan:=RowSpanVal;
               inc(SumColumns,ColSpanVal);
              end;
             end;
            end;
            inc(CellIndex);
           end;
          end;
          if SumColumns>aTableModel.fColCount then begin
           aTableModel.fColCount:=SumColumns;
          end;
         end;
        end;
       end;
       inc(SubRowIndex);
      end;
     end;
    end;
   end;
  end;
  inc(RowIndex);
 end;

end;

procedure TMarkDownRenderer.NormalizeTable(var aTableModel:TTable);
var TotalColumns:TMarkDownRendererInt32;
    RowIndex,ColumnIndex,SpanRow,SpanCol:TMarkDownRendererInt32;
    SourceRow,DestinationRow:TTableRow;
    SourceCell,DestinationCell:TTableCell;
    Occupied:array of array of boolean;
    NewRows:TTableRowList;
    NextFreeColumn:TMarkDownRendererInt32;
begin
 TotalColumns:=aTableModel.fColCount;
 if (aTableModel.fRowCount<=0) or (TotalColumns<=0) then begin
  exit;
 end;

 NewRows:=TTableRowList.Create;

 SetLength(Occupied,aTableModel.fRowCount);
 RowIndex:=0;
 while RowIndex<aTableModel.fRowCount do begin
  SetLength(Occupied[RowIndex],TotalColumns);
  ColumnIndex:=0;
  while ColumnIndex<TotalColumns do begin
   Occupied[RowIndex][ColumnIndex]:=false;
   inc(ColumnIndex);
  end;
  inc(RowIndex);
 end;

 RowIndex:=0;
 while RowIndex<aTableModel.fRowCount do begin
  DestinationRow:=NewRows.AddNew;
  ColumnIndex:=0;
  while ColumnIndex<TotalColumns do begin
   DestinationCell:=DestinationRow.Cells.AddNew;
   DestinationCell.Text:='';
   DestinationCell.ColSpan:=1;
   DestinationCell.RowSpan:=1;
   inc(ColumnIndex);
  end;
  inc(RowIndex);
 end;

 RowIndex:=0;
 while RowIndex<aTableModel.fRows.Count do begin
  SourceRow:=aTableModel.Rows[RowIndex];
  DestinationRow:=NewRows[RowIndex];
  NextFreeColumn:=0;

  ColumnIndex:=0;
  while ColumnIndex<SourceRow.Cells.Count do begin
   SourceCell:=SourceRow.Cells[ColumnIndex];

   while (NextFreeColumn<TotalColumns) and Occupied[RowIndex][NextFreeColumn] do begin
    inc(NextFreeColumn);
   end;

   if NextFreeColumn>=TotalColumns then begin
    break;
   end;

   DestinationCell:=DestinationRow.Cells[NextFreeColumn];
   DestinationCell.Text:=SourceCell.Text;
   DestinationCell.ColSpan:=SourceCell.ColSpan;
   DestinationCell.RowSpan:=SourceCell.RowSpan;
   DestinationCell.Node:=SourceCell.Node;

   SpanRow:=0;
   while SpanRow<DestinationCell.RowSpan do begin
    SpanCol:=0;
    while SpanCol<DestinationCell.ColSpan do begin
     if (RowIndex+SpanRow<aTableModel.fRowCount) and (NextFreeColumn+SpanCol<TotalColumns) then begin
      Occupied[RowIndex+SpanRow][NextFreeColumn+SpanCol]:=true;
     end;
     inc(SpanCol);
    end;
    inc(SpanRow);
   end;

   inc(NextFreeColumn);
   inc(ColumnIndex);
  end;

  inc(RowIndex);
 end;

 FreeAndNil(aTableModel.fRows);
 aTableModel.fRows:=NewRows;
end;

procedure TMarkDownRenderer.MeasureTableColumns(const aCanvas:TCanvas;const aTableModel:TTable;var aMinCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aPrefCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aIsBlockQuote:Boolean);
var ColumnIndex,RowIndex,TotalColumns,LocalIndex,Span:TMarkDownRendererInt32;
    Cell:TTableCell;
    MinimumWord,PreferredNoWrap:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

 function MaxWordWidth(const Text:TMarkDownRendererUTF8String):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 var ScanIndex:TMarkDownRendererInt32;
     WordBuffer:TMarkDownRendererUTF8String;
     BestWidth,Current:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 begin
  BestWidth:=0;
  WordBuffer:='';
  ScanIndex:=1;
  while ScanIndex<=length(Text) do begin
   if (Text[ScanIndex]=' ') or (Text[ScanIndex]=#9) or (Text[ScanIndex]=#10) or (Text[ScanIndex]=#13) then begin
    if length(WordBuffer)>0 then begin
     Current:=MeasureTextWidth(aCanvas,WordBuffer,fBaseFontSize,[],false,false,aIsBlockQuote);
     if Current>BestWidth then begin
      BestWidth:=Current;
     end;
     WordBuffer:='';
    end;
   end else begin
    WordBuffer:=WordBuffer+Text[ScanIndex];
   end;
   inc(ScanIndex);
  end;
  if length(WordBuffer)>0 then begin
   Current:=MeasureTextWidth(aCanvas,WordBuffer,fBaseFontSize,[],false,false,aIsBlockQuote);
   if Current>BestWidth then begin
    BestWidth:=Current;
   end;
  end;
  result:=BestWidth;
 end;

 function NoWrapWidth(const Text:TMarkDownRendererUTF8String):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 begin
  result:=MeasureTextWidth(aCanvas,Text,fBaseFontSize,[],false,false,aIsBlockQuote);
 end;

begin
 TotalColumns:=aTableModel.ColCount;

 ColumnIndex:=0;
 while ColumnIndex<TotalColumns do begin
  aMinCol[ColumnIndex]:=DIP(16);
  aPrefCol[ColumnIndex]:=DIP(16);
  inc(ColumnIndex);
 end;

 RowIndex:=0;
 while RowIndex<aTableModel.fRows.Count do begin
  ColumnIndex:=0;
  while ColumnIndex<TotalColumns do begin
   Cell:=aTableModel.Rows[RowIndex].Cells[ColumnIndex];
   Span:=Cell.ColSpan;
   if Span<1 then begin
    Span:=1;
   end;
   MinimumWord:=MaxWordWidth(Cell.Text)+DIP(8);
   PreferredNoWrap:=NoWrapWidth(Cell.Text)+DIP(8);
   if Span=1 then begin
    if MinimumWord>aMinCol[ColumnIndex] then begin
     aMinCol[ColumnIndex]:=MinimumWord;
    end;
    if PreferredNoWrap>aPrefCol[ColumnIndex] then begin
     aPrefCol[ColumnIndex]:=PreferredNoWrap;
    end;
   end else begin
    LocalIndex:=0;
    while LocalIndex<Span do begin
{$ifdef FMX}
     if (MinimumWord/Span)>aMinCol[ColumnIndex+LocalIndex] then begin
      aMinCol[ColumnIndex+LocalIndex]:=MinimumWord/Span;
     end;
     if (PreferredNoWrap/Span)>aPrefCol[ColumnIndex+LocalIndex] then begin
      aPrefCol[ColumnIndex+LocalIndex]:=PreferredNoWrap/Span;
     end;
{$else}
     if (MinimumWord div Span)>aMinCol[ColumnIndex+LocalIndex] then begin
      aMinCol[ColumnIndex+LocalIndex]:=MinimumWord div Span;
     end;
     if (PreferredNoWrap div Span)>aPrefCol[ColumnIndex+LocalIndex] then begin
      aPrefCol[ColumnIndex+LocalIndex]:=PreferredNoWrap div Span;
     end;
{$endif}
     inc(LocalIndex);
    end;
   end;
   inc(ColumnIndex,Span);
  end;
  inc(RowIndex);
 end;
end;

procedure TMarkDownRenderer.DistributeColumns(const aAvailable:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aMinCol:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aPrefCol:array of  {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aColumnWidth:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aIsBlockQuote:Boolean);
var TotalColumns,IndexColumn:TMarkDownRendererInt32;
    TotalMin,TotalPref,Extra,Remain,Room,Denom,SpanVal:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin

 TotalColumns:=length(aColumnWidth);
 TotalMin:=0;
 TotalPref:=0;

 IndexColumn:=0;
 while IndexColumn<TotalColumns do begin
  TotalMin:=TotalMin+aMinCol[IndexColumn];
  TotalPref:=TotalPref+aPrefCol[IndexColumn];
  inc(IndexColumn);
 end;

 if aAvailable<=TotalMin then begin
  IndexColumn:=0;
  while IndexColumn<TotalColumns do begin
   aColumnWidth[IndexColumn]:=aMinCol[IndexColumn];
   inc(IndexColumn);
  end;
 end else if aAvailable>=TotalPref then begin
  Extra:=aAvailable-TotalPref;
  IndexColumn:=0;
  while IndexColumn<TotalColumns do begin
{$ifdef FMX}
   aColumnWidth[IndexColumn]:=aPrefCol[IndexColumn]+(Extra/TotalColumns);
{$else}
   aColumnWidth[IndexColumn]:=aPrefCol[IndexColumn]+(Extra div TotalColumns);
{$endif}
   inc(IndexColumn);
  end;
{$ifdef FMX}
  Remain:=Floor(Extra-(trunc(Extra/TotalColumns)*TotalColumns));
{$else}
  Remain:=Extra mod TotalColumns;
{$endif}
  IndexColumn:=0;
  while IndexColumn<Remain do begin
{$ifdef FMX}
   aColumnWidth[IndexColumn]:=aColumnWidth[IndexColumn]+1.0;
{$else}
   inc(aColumnWidth[IndexColumn]);
{$endif}
   inc(IndexColumn);
  end;
 end else begin
  Room:=aAvailable-TotalMin;
  Denom:=TotalPref-TotalMin;
  IndexColumn:=0;
  while IndexColumn<TotalColumns do begin
   SpanVal:=aPrefCol[IndexColumn]-aMinCol[IndexColumn];
   if Denom>0 then begin
{$ifdef FMX}
    aColumnWidth[IndexColumn]:=aMinCol[IndexColumn]+((SpanVal*Room)/Denom);
{$else}
    aColumnWidth[IndexColumn]:=aMinCol[IndexColumn]+((SpanVal*Room) div Denom);
{$endif}
   end else begin
    aColumnWidth[IndexColumn]:=aMinCol[IndexColumn];
   end;
   inc(IndexColumn);
  end;
 end;
end;

procedure TMarkDownRenderer.LayoutTable(const aCanvas:TCanvas;var aTableModel:TTable;const aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aFontStyle:TFontStyles;const aIsBlockQuote:Boolean);
var RowIndex,ColumnIndex,Span,IndexSpan,TotalColumns:TMarkDownRendererInt32;
    PrefCol:array of  {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    MinCol,ColWidth:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    RowHeights:array of {$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    AvailableWidth,GridSize,CellPadding,
    CellWidth,TextWidth,StartX,StartY,CurrentY,CurrentX:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    SavedIndent,SavedAbove,SavedBelow,SavedMax,SavedX,SavedY,SavedLH,
    SavedBaseline:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    SavedItemStart,SavedLinkStart:TMarkDownRendererInt32;
    Cell:TTableCell;
    RectItem:TLayoutItem;
    TempItems:TLayoutItemList;
    TempLinkRects:TLinkHitRectList;
    SavedItems:TLayoutItemList;
    SavedLinkRects:TLinkHitRectList;
    SavedNeed:boolean;
    CellFontStyle:TFontStyles;
begin
 if fLineX<>0 then begin
  ParagraphBreak(aCanvas);
 end;

 NormalizeTable(aTableModel);

 TotalColumns:=aTableModel.ColCount;
 if (aTableModel.RowCount<=0) or (TotalColumns<=0) then begin
  exit;
 end;

 GridSize:=DIP(1);
 CellPadding:=DIP(4);

 AvailableWidth:=fMaxWidth-fCurrentIndent-(TotalColumns-1)*GridSize;
 if AvailableWidth<1 then begin
  AvailableWidth:=1;
 end;

 SetLength(MinCol,TotalColumns);
 SetLength(PrefCol,TotalColumns);
 SetLength(ColWidth,TotalColumns);

 MeasureTableColumns(aCanvas,aTableModel,MinCol,PrefCol,aIsBlockQuote);
 DistributeColumns(AvailableWidth,MinCol,PrefCol,ColWidth,aIsBlockQuote);

 SetLength(RowHeights,aTableModel.RowCount);

 RowIndex:=0;
 while RowIndex<aTableModel.fRows.Count do begin
  RowHeights[RowIndex]:=0;
  ColumnIndex:=0;
  while ColumnIndex<TotalColumns do begin
   Cell:=aTableModel.Rows[RowIndex].Cells[ColumnIndex];
   if assigned(Cell) then begin
    Span:=Cell.ColSpan;
    if Span<1 then begin
     Span:=1;
    end;
   end else begin
    Span:=1;
   end;

   CellWidth:=0;
   IndexSpan:=0;
   while IndexSpan<Span do begin
    CellWidth:=CellWidth+ColWidth[ColumnIndex+IndexSpan];
    if IndexSpan>0 then begin
     CellWidth:=CellWidth+GridSize;
    end;
    inc(IndexSpan);
   end;

   TextWidth:=CellWidth-(CellPadding*2);
   if TextWidth<1 then begin
    TextWidth:=1;
   end;

   SavedMax:=fMaxWidth;
   SavedIndent:=fCurrentIndent;
   SavedX:=fLineX;
   SavedY:=fLineY;
   SavedLH:=fLineHeight;

   fMaxWidth:=TextWidth;
   fCurrentIndent:=0;
   fLineX:=0;
   fLineY:=0;
   fLineHeight:=0;
   // reset inline overhang state for measurement sub-layout
   SavedAbove:=fLineAboveExtra;
   SavedBelow:=fLineBelowExtra;
   SavedItemStart:=fLineItemStartIndex;
   SavedLinkStart:=fLinkRectStartIndex;
   SavedBaseline:=fBaselineShiftCurrent;
   fLineAboveExtra:=0;
   fLineBelowExtra:=0;
   fLineItemStartIndex:=0;
   fLinkRectStartIndex:=0;
   fBaselineShiftCurrent:=0;

   // apply <th> styling locally (real render)
   CellFontStyle:=aFontStyle;
   if assigned(Cell.Node) then begin

    if UpperCase(Cell.Node.TagName)='TH' then begin
//   Include(CellFontStyle,fsBold);
    end;

    // dry-run traversal inside a temporary items/link list to measure height only
    SavedItems:=fItems;
    SavedLinkRects:=fLinkRects;
    SavedNeed:=fNeedSpaceBeforeNextText;
    TempItems:=TLayoutItemList.Create;
    TempLinkRects:=TLinkHitRectList.Create;
    fItems:=TempItems;
    fLinkRects:=TempLinkRects;
    try
     TraverseHTML(aCanvas,Cell.Node,false,aFontSize,CellFontStyle,'',false,false);
    finally
     TempItems.Free;
     TempLinkRects.Free;
     fItems:=SavedItems;
     fLinkRects:=SavedLinkRects;
     fNeedSpaceBeforeNextText:=SavedNeed;
    end;
   end else begin
    LayoutTextWrapped(aCanvas,Cell.Text,aFontSize,aFontStyle,'',false,false,aIsBlockQuote,false,true);
   end;

   if (fLineY+fLineHeight)>RowHeights[RowIndex] then begin
    RowHeights[RowIndex]:=fLineY+fLineHeight;
   end;

   fMaxWidth:=SavedMax;
   fCurrentIndent:=SavedIndent;
   fLineX:=SavedX;
   fLineY:=SavedY;
   fLineHeight:=SavedLH;
   fLineAboveExtra:=SavedAbove;
   fLineBelowExtra:=SavedBelow;
   fLineItemStartIndex:=SavedItemStart;
   fLinkRectStartIndex:=SavedLinkStart;
   fBaselineShiftCurrent:=SavedBaseline;

   inc(ColumnIndex,Span);
  end;

  if RowHeights[RowIndex]<MeasureTextHeight(aCanvas,aFontSize,aFontStyle,false,false,aIsBlockQuote) then begin
   RowHeights[RowIndex]:=MeasureTextHeight(aCanvas,aFontSize,aFontStyle,false,false,aIsBlockQuote);
  end;
  RowHeights[RowIndex]:=RowHeights[RowIndex]+(CellPadding*2);

  inc(RowIndex);
 end;

 StartX:=fCurrentIndent;
 StartY:=fLineY;
 CurrentY:=StartY;

 RowIndex:=0;
 while RowIndex<aTableModel.fRows.Count do begin
  CurrentX:=StartX;
  ColumnIndex:=0;
  while ColumnIndex<TotalColumns do begin
   Cell:=aTableModel.Rows[RowIndex].Cells[ColumnIndex];
   if assigned(Cell) then begin
    Span:=Cell.ColSpan;
    if Span<1 then begin
     Span:=1;
    end;
   end else begin
    Span:=1;
   end;

   CellWidth:=0;
   IndexSpan:=0;
   while IndexSpan<Span do begin
    CellWidth:=CellWidth+ColWidth[ColumnIndex+IndexSpan];
    if IndexSpan>0 then begin
     CellWidth:=CellWidth+GridSize;
    end;
    inc(IndexSpan);
   end;

   RectItem:=fItems.NewItem;
   RectItem.Kind:=TLayoutItemKind.LayoutRect;
   RectItem.X:=CurrentX;
   RectItem.Y:=CurrentY;
   RectItem.Width:=CellWidth;
   RectItem.Height:=RowHeights[RowIndex];

   SavedMax:=fMaxWidth;
   SavedIndent:=fCurrentIndent;
   SavedX:=fLineX;
   SavedY:=fLineY;
   SavedLH:=fLineHeight;

   fMaxWidth:=CurrentX+CellWidth-CellPadding;
   fCurrentIndent:=CurrentX+CellPadding;
   fLineX:=0;
   fLineY:=CurrentY+CellPadding;
   fLineHeight:=0;
   // reset inline overhang state for render sub-layout
   SavedAbove:=fLineAboveExtra;
   SavedBelow:=fLineBelowExtra;
   SavedItemStart:=fLineItemStartIndex;
   SavedLinkStart:=fLinkRectStartIndex;
   SavedBaseline:=fBaselineShiftCurrent;
   fLineAboveExtra:=0;
   fLineBelowExtra:=0;
   fLineItemStartIndex:=fItems.Count;
   fLinkRectStartIndex:=fLinkRects.Count;
   fBaselineShiftCurrent:=0;

   // apply <th> styling locally (real render)
   CellFontStyle:=aFontStyle;
   if assigned(Cell.Node) then begin

    if UpperCase(Cell.Node.TagName)='TH' then begin
     //Include(CellFontStyle,fsBold);
    end;

    TraverseHTML(aCanvas,Cell.Node,false,aFontSize,CellFontStyle,'',false,aIsBlockQuote);

   end else begin
    LayoutTextWrapped(aCanvas,Cell.Text,fBaseFontSize,aFontStyle,'',false,false,aIsBlockQuote,false,false);
   end;

   fMaxWidth:=SavedMax;
   fCurrentIndent:=SavedIndent;
   fLineX:=SavedX;
   fLineY:=SavedY;
   fLineHeight:=SavedLH;
   fLineAboveExtra:=SavedAbove;
   fLineBelowExtra:=SavedBelow;
   fLineItemStartIndex:=SavedItemStart;
   fLinkRectStartIndex:=SavedLinkStart;
   fBaselineShiftCurrent:=SavedBaseline;

   IndexSpan:=0;
   while IndexSpan<Span do begin
    CurrentX:=CurrentX+ColWidth[ColumnIndex+IndexSpan];
    if (IndexSpan+1)<Span then begin
     CurrentX:=CurrentX+GridSize;
    end;
    inc(IndexSpan);
   end;
   CurrentX:=CurrentX+GridSize;

   inc(ColumnIndex,Span);
  end;

  CurrentY:=CurrentY+(RowHeights[RowIndex]+GridSize);
  inc(RowIndex);
 end;

 fLineY:=CurrentY;
 NewLine(aCanvas);
 ParagraphBreak(aCanvas);
end;

{$ifdef FMX}
function RawByteStringToUTF8String(aString:RawByteString):UTF8String;
var UTF8Str:UTF8String;
begin
 SetCodePage(aString,0,false);
 SetLength(UTF8Str,Length(aString));
 if Length(aString)>0 then begin
  Move(aString[1],UTF8Str[1],Length(UTF8Str));
 end;
 result:=UTF8Str;
end;
{$endif}

procedure TMarkDownRenderer.TraverseHTML(const aCanvas:TCanvas;const aNode:THTML.TNode;const aIsBlock:boolean;aFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};aFontStyle:TFontStyles;aLinkHref:TMarkDownRendererUTF8String;aUseMono,aIsBlockQuote:boolean);
var ChildIndex:TMarkDownRendererInt32;
    ChildNode:THTML.TNode;
    TagUpper:TMarkDownRendererUTF8String;
    ListIsOrdered:boolean;
    HeaderLevel:TMarkDownRendererInt32;
    HeaderFontSizeValue:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    Accumulator:TMarkDownRendererUTF8String;
    TableModel:TTable;
    TagParameter:THTML.TTagParameter;
    PrevFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    PrevFontStyle:TFontStyles;
    PrevLinkHref:TMarkDownRendererUTF8String;
    PrevUseMono:boolean;
    PrevBaselineShift:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    PrevMark:boolean;
    PrevThink:boolean;
    PreviousLineX:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    PreviousIndent:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
 procedure Push;
 begin
  PrevFontSize:=aFontSize;
  PrevFontStyle:=aFontStyle;
  PrevLinkHref:=aLinkHref;
  PrevUseMono:=aUseMono;
  PrevBaselineShift:=fBaselineShiftCurrent;
  PrevMark:=fMarkActive;
  PrevThink:=fThinkActive;
 end;
 procedure Pop;
 begin
  aFontSize:=PrevFontSize;
  aFontStyle:=PrevFontStyle;
  aLinkHref:=PrevLinkHref;
  aUseMono:=PrevUseMono;
  fBaselineShiftCurrent:=PrevBaselineShift;
  fMarkActive:=PrevMark;
  fThinkActive:=PrevThink;
 end;
begin
 if not assigned(aNode) then begin
  exit;
 end;

 Push;

 if aNode.NodeType=THTML.TNodeType.Tag then begin
  TagUpper:=UpperCase(aNode.TagName);

  if TagUpper='P' then begin
   if fLineX<>0 then begin
    ParagraphBreak(aCanvas);
   end;
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     ChildNode:=aNode.Children[ChildIndex];
     TraverseHTML(aCanvas,ChildNode,false,aFontSize,aFontStyle,aLinkHref,aUseMono,aIsBlockQuote);
     inc(ChildIndex);
    end;
   end;
   ParagraphBreak(aCanvas);
   Pop;
   exit;
  end else if TagUpper='BR' then begin
   NewLine(aCanvas);
   Pop;
   exit;
  end else if TagUpper='HR' then begin
   LayoutHR(aCanvas,aIsBlockQuote);
   Pop;
   exit;
  end else if TagUpper='BLOCKQUOTE' then begin
   fCurrentIndent:=fCurrentIndent+DIP(16);
   ParagraphBreak(aCanvas);
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     TraverseHTML(aCanvas,aNode.Children[ChildIndex],true,aFontSize,aFontStyle,aLinkHref,aUseMono,true);
     inc(ChildIndex);
    end;
   end;
   ParagraphBreak(aCanvas);
   fCurrentIndent:=fCurrentIndent-DIP(16);
   Pop;
   exit;
  end else if (TagUpper='UL') or (TagUpper='OL') then begin
   ListIsOrdered:=TagUpper='OL';
   if fLineX<>0 then begin
    ParagraphBreak(aCanvas);
   end;
   if fListDepth<32 then begin
    if ListIsOrdered then begin
     fOrderedListDepthCount[fListDepth]:=1;
    end else begin
     fOrderedListDepthCount[fListDepth]:=0;
    end;
   end;
   inc(fListDepth);
   fCurrentIndent:=fCurrentIndent+DIP(16);
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     ChildNode:=aNode.Children[ChildIndex];
     if assigned(ChildNode) and (ChildNode.NodeType=THTML.TNodeType.Tag) and (LowerCase(ChildNode.TagName)='li') then begin
      PreviousLineX:=fLineX;
      PreviousIndent:=fCurrentIndent;
      if ListIsOrdered then begin
       LayoutTextWrapped(aCanvas,IntToStr(fOrderedListDepthCount[fListDepth-1])+'. ',aFontSize,aFontStyle,'',false,false,aIsBlockQuote,false,false);
       inc(fOrderedListDepthCount[fListDepth-1]);
       fCurrentIndent:=fCurrentIndent+DIP(8);
      end else begin
       LayoutBullet(aCanvas,aFontSize,aFontStyle,aIsBlockQuote);
       fCurrentIndent:=fCurrentIndent+DIP(14); // a little more gap to bullet
      end;
      fCurrentIndent:=fCurrentIndent+fLineX;
      fLineX:=0;
      if assigned(ChildNode.Children) then begin
       HeaderLevel:=0;
       while HeaderLevel<ChildNode.Children.Count do begin
        TraverseHTML(aCanvas,ChildNode.Children[HeaderLevel],false,aFontSize,aFontStyle,aLinkHref,aUseMono,aIsBlockQuote);
        inc(HeaderLevel);
       end;
      end;
      fCurrentIndent:=PreviousIndent;
      fLineX:=PreviousLineX;
      NewLine(aCanvas);
     end;
     inc(ChildIndex);
    end;
   end;
   ParagraphBreak(aCanvas);
   fCurrentIndent:=fCurrentIndent-DIP(16);
   dec(fListDepth);
   Pop;
   exit;
  end else if (length(TagUpper)>=2) and (TagUpper[1]='H') and (TagUpper[2] in ['1'..'6']) then begin
   HeaderLevel:=Ord(TagUpper[2])-Ord('0');
   HeaderFontSizeValue:=HeaderFontSize(HeaderLevel,fBaseFontSize);
   if fLineX<>0 then begin
    ParagraphBreak(aCanvas);
   end;
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     TraverseHTML(aCanvas,aNode.Children[ChildIndex],false,HeaderFontSizeValue,aFontStyle,aLinkHref,aUseMono,aIsBlockQuote);
     inc(ChildIndex);
    end;
   end;
   ParagraphBreak(aCanvas);
   Pop;
   exit;
  end else if TagUpper='PRE' then begin
   Accumulator:='';
   if assigned(aNode.Children) then begin
    ChildIndex:=0;
    while ChildIndex<aNode.Children.Count do begin
     ChildNode:=aNode.Children[ChildIndex];
     if assigned(ChildNode) then begin
      if ChildNode.NodeType=THTML.TNodeType.Text then begin
       Accumulator:=Accumulator+ChildNode.Text;
      end else if (ChildNode.NodeType=THTML.TNodeType.Tag) and assigned(ChildNode.Children) then begin
       HeaderLevel:=0;
       while HeaderLevel<ChildNode.Children.Count do begin
        if assigned(ChildNode.Children[HeaderLevel]) and (ChildNode.Children[HeaderLevel].NodeType=THTML.TNodeType.Text) then begin
         Accumulator:=Accumulator+ChildNode.Children[HeaderLevel].Text;
        end;
        inc(HeaderLevel);
       end;
      end;
     end;
     inc(ChildIndex);
    end;
   end;
   LayoutCodeBlock(aCanvas,Accumulator,fBaseFontSize);
   Pop;
   exit;
  end else if TagUpper='CODE' then begin
   aUseMono:=true;
  end else if (TagUpper='STRONG') or (TagUpper='B') then begin
{$ifdef FMX}
   Include(aFontStyle,TFontStyle.fsBold);
{$else}
   Include(aFontStyle,fsBold);
{$endif}
  end else if (TagUpper='EM') or (TagUpper='I') then begin
{$ifdef FMX}
   Include(aFontStyle,TFontStyle.fsItalic);
{$else}
   Include(aFontStyle,fsItalic);
{$endif}
  end else if TagUpper='DEL' then begin
{$ifdef FMX}
   Include(aFontStyle,TFontStyle.fsStrikeOut);
{$else}
   Include(aFontStyle,fsStrikeOut);
{$endif}
  end else if TagUpper='MARK' then begin
   fMarkActive:=true;
  end else if TagUpper='THINK' then begin
   fThinkActive:=true;
{$ifdef FMX}
   Include(aFontStyle,TFontStyle.fsItalic);
   aFontSize:=Max(1,aFontSize*0.9);
{$else}
   Include(aFontStyle,fsItalic);
   aFontSize:=Max(1,(aFontSize*9) div 10);
{$endif}
  end else if TagUpper='SUP' then begin
   // superscript - smaller font and baseline up
{$ifdef FMX}
   aFontSize:=Max(1,aFontSize*0.75);
   fBaselineShiftCurrent:=fBaselineShiftCurrent-((MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,false,aIsBlockQuote)+1)*0.5);
{$else}
   aFontSize:=Max(1,(aFontSize*3) div 4);
   dec(fBaselineShiftCurrent,(MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,false,aIsBlockQuote)+1) div 2);
{$endif}
  end else if TagUpper='SUB' then begin
   // subscript - smaller font and baseline down
{$ifdef FMX}
   aFontSize:=Max(1,aFontSize*0.75);
   fBaselineShiftCurrent:=fBaselineShiftCurrent+((MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,false,aIsBlockQuote)+1)*0.333333333);
{$else}
   aFontSize:=Max(1,(aFontSize*3) div 4);
   inc(fBaselineShiftCurrent,(MeasureTextHeight(aCanvas,aFontSize,aFontStyle,aUseMono,false,aIsBlockQuote)+1) div 3);
{$endif}
  end else if TagUpper='A' then begin
{$ifdef FMX}
   Include(aFontStyle,TFontStyle.fsUnderline);
{$else}
   Include(aFontStyle,fsUnderline);
{$endif}
   TagParameter:=aNode.TagParameters.FindByName('HREF');
   if assigned(TagParameter) then begin
    aLinkHref:=ConvertEntities(TagParameter.Value,THTML.TCharset.UTF_8,true);
   end else begin
    aLinkHref:='';
   end;
  end else if TagUpper='IMG' then begin
   TagParameter:=aNode.TagParameters.FindByName('ALT');
   if assigned(TagParameter) then begin
    LayoutTextWrapped(aCanvas,'[img '+TagParameter.Value+']',aFontSize,aFontStyle,'',false,false,aIsBlockQuote,false,false);
   end else begin
    LayoutTextWrapped(aCanvas,'[img]',aFontSize,aFontStyle,'',false,false,aIsBlockQuote,false,false);
   end;
   Pop;
   exit;
  end else if TagUpper='TABLE' then begin
   CollectTable(aNode,TableModel);
   if TableModel.RowCount=0 then begin
    TableModel.RowCount:=TableModel.Rows.Count;
   end;
   try
    LayoutTable(aCanvas,TableModel,fBaseFontSize,aFontStyle,aIsBlockQuote);
   finally
    FreeAndNil(TableModel);
   end;
   Pop;
   exit;
  end;
 end;

 if aNode.NodeType=THTML.TNodeType.Text then begin
  if length(aNode.Text)>0 then begin
   LayoutTextWrapped(aCanvas,{$ifdef FMX}RawByteStringToUTF8String(aNode.Text){$else}aNode.Text{$endif},aFontSize,aFontStyle,aLinkHref,aUseMono,false,aIsBlockQuote,false,false);
  end;
 end else begin
  if assigned(aNode.Children) then begin
   ChildIndex:=0;
   while ChildIndex<aNode.Children.Count do begin
    ChildNode:=aNode.Children[ChildIndex];
    TraverseHTML(aCanvas,ChildNode,false,aFontSize,aFontStyle,aLinkHref,aUseMono,aIsBlockQuote);
    inc(ChildIndex);
   end;
  end;
 end;

 Pop;

end;

procedure TMarkDownRenderer.Parse(const aMarkDownOrHTML:TMarkDownRendererUTF8String;const IsHTML:boolean);
var MarkDown:TMarkdown;
begin
 FreeAndNil(fHTMLDoc);
 if IsHTML then begin
  fHTMLDoc:=THTML.Create(aMarkDownOrHTML,THTML.TCharset.UTF_8);
 end else begin
//HtmlDoc:=THTML.Create(MarkDownToHTML(aMarkDownOrHTML),THTML.TCharset.UTF_8);
  MarkDown:=TMarkdown.Create(aMarkDownOrHTML);
  try
   fHTMLDoc:=MarkDown.GetHTML;   
  finally
   FreeAndNil(MarkDown);
  end;
 end;
end;

procedure TMarkDownRenderer.Calculate(const aCanvas:TCanvas;const aMaxWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aContentWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aContentHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var CurrentFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    CurrentFontStyle:TFontStyles;
    CurrentLinkHref:TMarkDownRendererUTF8String;
    UseMono:boolean;
{$ifdef FMX}
    ta,tb:uint64;
{$endif}
begin
 if not assigned(aCanvas) then begin
  aContentWidth:=0;
  aContentHeight:=0;
  exit;
 end;

 BeginLayout;

 fMaxWidth:=aMaxWidth;
 if fMaxWidth<=0 then begin
  fMaxWidth:=1;
 end;

{fBaseFontSize:=aCanvas.Font.Size;
 if fBaseFontSize<=0 then begin
  fBaseFontSize:=10;
 end;}

//writeln(fMaxWidth:7:3);

 if assigned(fHTMLDoc) then begin
  CurrentFontSize:=fBaseFontSize;
  CurrentFontStyle:=[];
  CurrentLinkHref:='';
  UseMono:=false;
{$ifdef FMX}
  ta:=TThread.GetTickCount64;
{$endif}
  TraverseHTML(aCanvas,fHTMLDoc.RootNode,true,CurrentFontSize,CurrentFontStyle,CurrentLinkHref,UseMono,false);
  if fLineX<>0 then begin
   NewLine(aCanvas);
  end;
{$ifdef FMX}
  tb:=TThread.GetTickCount64;
//writeln(tb-ta);
{$endif}
  fCalculatedHeight:=fLineY;
 end;

 aContentWidth:=fCalculatedWidth;
 aContentHeight:=fCalculatedHeight;

 EndLayout;
end;

procedure TMarkDownRenderer.Render(const aCanvas:TCanvas;const aLeftPosition,aTopPosition:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var Index:TMarkDownRendererInt32;
    Item:TLayoutItem;
    OldStyle:TFontStyles;
    OldSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    OldName:TMarkDownRendererUTF8String;
{$ifndef FMX}
    OldBrushStyle:TBrushStyle;
    OldPenStyle:TPenStyle;
    OldPenColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    OldBrushColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
{$endif}
{$ifdef FMX}
    r:TRectF;
    State:TCanvasSaveState;
{$endif}
begin
 if not assigned(aCanvas) then begin
  exit;
 end;

 Index:=0;
 while Index<fItems.Count do begin

{$ifdef FMX}
  OldStyle:=aCanvas.Font.Style;
  OldSize:=aCanvas.Font.Size;
  OldName:=aCanvas.Font.Family;
  State:=aCanvas.SaveState;
{$else}
  OldStyle:=aCanvas.Font.Style;
  OldSize:=aCanvas.Font.Size;
  OldName:=aCanvas.Font.Name;
  OldBrushStyle:=aCanvas.Brush.Style;
  OldPenStyle:=aCanvas.Pen.Style;
  OldPenColor:=aCanvas.Pen.Color;
  OldBrushColor:=aCanvas.Brush.Color;
{$endif}

  aCanvas.Font.Style:=[];

  Item:=fItems[Index];
  case Item.Kind of
   TLayoutItemKind.LayoutText:begin
{$ifdef FMX}
    r:=TRectF.Create(aLeftPosition+Item.X,
                     aTopPosition+Item.Y,
                     aLeftPosition+Item.X+Item.Width,
                     aTopPosition+Item.Y+Item.Height);
    if Item.Code then begin
//   aCanvas.Fill.Color:=fBGCodeColor;
     aCanvas.Fill.Color:=fFontCodeColor;
    end else if Item.Mark then begin
     aCanvas.Fill.Color:=fBGMarkColor;
     aCanvas.FillRect(r,1.0);
     aCanvas.Fill.Color:=fFontMarkColor;
    end else if Item.Think then begin
     aCanvas.Fill.Color:=fBGThinkColor;
     aCanvas.FillRect(r,1.0);
     aCanvas.Fill.Color:=fFontThinkColor;
    end else begin
//   aCanvas.Fill.Color:=fBGColor;
     aCanvas.Fill.Color:=fFontColor;
    end;
    ApplyFont(aCanvas,Item.FontSize,Item.FontStyle,Item.Mono,Item.Code,Item.BlockQuote);
    aCanvas.FillText(r,Item.Text,false,1.0,[],TTextAlign.Leading,TTextAlign.Leading);
{$else}
    if Item.Code then begin
     aCanvas.Brush.Color:=fBGCodeColor;
     aCanvas.Pen.Color:=fFontCodeColor;
    end else if Item.Mark then begin
     aCanvas.Brush.Color:=fBGMarkColor;
     aCanvas.Pen.Color:=fFontMarkColor;
    end else if Item.Think then begin
     aCanvas.Brush.Color:=fBGThinkColor;
     aCanvas.Pen.Color:=fFontThinkColor;
    end else begin
     aCanvas.Brush.Color:=fBGColor;
     aCanvas.Pen.Color:=fFontColor;
    end;
    // background for mark/think highlight
    if Item.Mark or Item.Think then begin
     aCanvas.Brush.Style:=bsSolid;
     aCanvas.Pen.Style:=psClear;
     aCanvas.Rectangle(aLeftPosition+Item.X,
                       aTopPosition+Item.Y,
                       aLeftPosition+Item.X+Item.Width,
                       aTopPosition+Item.Y+Item.Height);
    end;
    // draw text
    aCanvas.Brush.Style:=bsClear;
    aCanvas.Pen.Style:=psClear;
    ApplyFont(aCanvas,Item.FontSize,Item.FontStyle,Item.Mono,Item.Code,Item.BlockQuote);
    if Item.Mark then begin
     aCanvas.Font.Color:=fFontMarkColor;
    end else if Item.Think then begin
     aCanvas.Font.Color:=fFontThinkColor;
    end;
{$ifdef fpc}
    aCanvas.TextOut(aLeftPosition+Item.X,aTopPosition+Item.Y,Item.Text);
{$else}
    aCanvas.TextOut(aLeftPosition+Item.X,aTopPosition+Item.Y,UTF8Decode(Item.Text));
{$endif}
{$endif}
   end;
   TLayoutItemKind.LayoutHR:begin
{$ifdef FMX}
    aCanvas.Stroke.Color:=fFontColor;
    aCanvas.Stroke.Thickness:=1.0;
    aCanvas.Stroke.Dash:=TStrokeDash.Solid;
    aCanvas.DrawLine(TPointF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y+0.5),
                     TPointF.Create(aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+0.5),1.0);
{$else}
    aCanvas.Brush.Style:=bsClear;
    aCanvas.Pen.Style:=psSolid;
    aCanvas.Pen.Color:=fFontColor;
    aCanvas.Brush.Color:=fFontColor;
    aCanvas.MoveTo(aLeftPosition+Item.X,aTopPosition+Item.Y);
    aCanvas.LineTo(aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y);
{$endif}
   end;
   TLayoutItemKind.LayoutBullet:begin
{$ifdef FMX}
    aCanvas.Stroke.Color:=fFontColor;
    aCanvas.Stroke.Thickness:=1.0;
    aCanvas.Stroke.Dash:=TStrokeDash.Solid;
    aCanvas.Fill.Color:=fFontColor;
    aCanvas.FillEllipse(TRectF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height),1.0);
{$else}
    aCanvas.Brush.Style:=bsSolid;
    aCanvas.Pen.Style:=psSolid;
    aCanvas.Pen.Color:=fFontColor;
    aCanvas.Brush.Color:=fFontColor;
    aCanvas.Ellipse(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height);
{$endif}
   end;
   TLayoutItemKind.LayoutRect:begin
{$ifdef FMX}
    aCanvas.Stroke.Color:=fFontColor;
    aCanvas.Stroke.Thickness:=1.0;
    aCanvas.Stroke.Dash:=TStrokeDash.Solid; 
    aCanvas.Fill.Color:=fBGColor;
    aCanvas.FillRect(TRectF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height),1.0);
    aCanvas.DrawRect(TRectF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height),1.0);
{$else}
    aCanvas.Brush.Style:=bsClear;
    aCanvas.Pen.Style:=psSolid;
    aCanvas.Pen.Color:=fFontColor;
    aCanvas.Brush.Color:=fBGColor;
    aCanvas.Rectangle(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height);
{$endif}
   end;
   TLayoutItemKind.LayoutCodeBG:begin
{$ifdef FMX}
    aCanvas.Stroke.Color:=fFontColor;
    aCanvas.Stroke.Thickness:=1.0;
    aCanvas.Stroke.Dash:=TStrokeDash.Solid;
    aCanvas.Fill.Color:=fBGCodeColor;
    aCanvas.FillRect(TRectF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height),1.0);
    aCanvas.DrawRect(TRectF.Create(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height),1.0);
{$else}
    aCanvas.Brush.Style:=bsSolid;
    aCanvas.Pen.Style:=psDot;
    aCanvas.Brush.Color:=fBGCodeColor;
    aCanvas.Pen.Color:=fFontColor;
    aCanvas.Rectangle(aLeftPosition+Item.X,aTopPosition+Item.Y,aLeftPosition+Item.X+Item.Width,aTopPosition+Item.Y+Item.Height);
{$endif}
   end;
   else begin
   end;
  end;

{$ifdef FMX}
  aCanvas.RestoreState(State);
  aCanvas.Font.Style:=OldStyle;
  aCanvas.Font.Size:=OldSize;
  aCanvas.Font.Family:=OldName;
{$else}
  aCanvas.Font.Style:=OldStyle;
  aCanvas.Font.Size:=OldSize;
  aCanvas.Font.Name:=OldName;
  aCanvas.Brush.Style:=OldBrushStyle;
  aCanvas.Pen.Style:=OldPenStyle;
  aCanvas.Brush.Color:=OldBrushColor;
  aCanvas.Pen.Color:=OldPenColor;
{$endif}

  inc(Index);
 end;

end;

function TMarkDownRenderer.HitTestLink(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aHref:TMarkDownRendererUTF8String):boolean;
var Index:TMarkDownRendererInt32;
    RectObj:TLinkHitRect;
begin
 for Index:=0 to fLinkRects.Count-1 do begin
  RectObj:=fLinkRects[Index];
  if ((aX>=RectObj.X) and (aX<(RectObj.X+RectObj.W))) and
     ((aY>=RectObj.Y) and (aY<(RectObj.Y+RectObj.H))) then begin
   aHref:=RectObj.Href;
   result:=true;
   exit;
  end;
 end;
 aHref:='';
 result:=false;
end;

end.
