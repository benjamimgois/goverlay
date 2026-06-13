(******************************************************************************
 *                                 PasJSON                                    *
 ******************************************************************************
 *                          Version 2025-08-18-17-44                          *
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
 *    http://github.com/BeRo1985/pasjson                                      *
 * 4. Write code which's compatible with newer modern Delphi versions and     *
 *    FreePascal >= 3.0.0                                                     *
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
unit PasJSON;
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
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
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
 {$define CAN_INLINE}
 {$define HAS_ADVANCED_RECORDS}
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
 {$undef CAN_INLINE}
 {$undef HAS_ADVANCED_RECORDS}
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
  {$if CompilerVersion>=24.0}
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
   {$define CAN_INLINE}
   {$define HAS_ADVANCED_RECORDS}
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
   {$legacyifend on}
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
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}
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
{$ifndef HAS_TYPE_SINGLE}
 {$error No single floating point precision}
{$endif}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$scopedenums on}
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
     Math;

type PPPasJSONInt8=^PPasJSONInt8;
     PPasJSONInt8=^TPasJSONInt8;
     TPasJSONInt8={$ifdef fpc}Int8{$else}shortint{$endif};

     PPPasJSONUInt8=^PPasJSONUInt8;
     PPasJSONUInt8=^TPasJSONUInt8;
     TPasJSONUInt8={$ifdef fpc}UInt8{$else}byte{$endif};

     PPPasJSONUInt8Array=^PPasJSONUInt8Array;
     PPasJSONUInt8Array=^TPasJSONUInt8Array;
     TPasJSONUInt8Array=array[0..65535] of TPasJSONUInt8;

     PPPasJSONInt16=^PPasJSONInt16;
     PPasJSONInt16=^TPasJSONInt16;
     TPasJSONInt16={$ifdef fpc}Int16{$else}smallint{$endif};

     PPPasJSONUInt16=^PPasJSONUInt16;
     PPasJSONUInt16=^TPasJSONUInt16;
     TPasJSONUInt16={$ifdef fpc}UInt16{$else}word{$endif};

     PPPasJSONInt32=^PPasJSONInt32;
     PPasJSONInt32=^TPasJSONInt32;
     TPasJSONInt32={$ifdef fpc}Int32{$else}longint{$endif};

     PPPasJSONUInt32=^PPasJSONUInt32;
     PPasJSONUInt32=^TPasJSONUInt32;
     TPasJSONUInt32={$ifdef fpc}UInt32{$else}longword{$endif};

     PPPasJSONInt64=^PPasJSONInt64;
     PPasJSONInt64=^TPasJSONInt64;
     TPasJSONInt64=Int64;

     PPPasJSONUInt64=^PPasJSONUInt64;
     PPasJSONUInt64=^TPasJSONUInt64;
     TPasJSONUInt64=UInt64;

     PPPasJSONChar=^PAnsiChar;
     PPasJSONChar=PAnsiChar;
     TPasJSONChar=AnsiChar;

     PPPasJSONRawByteChar=^PAnsiChar;
     PPasJSONRawByteChar=PAnsiChar;
     TPasJSONRawByteChar=AnsiChar;

     PPPasJSONUTF16Char=^PWideChar;
     PPasJSONUTF16Char=PWideChar;
     TPasJSONUTF16Char=WideChar;

     PPPasJSONPointer=^PPasJSONPointer;
     PPasJSONPointer=^TPasJSONPointer;
     TPasJSONPointer=Pointer;

     PPPasJSONPointers=^PPasJSONPointers;
     PPasJSONPointers=^TPasJSONPointers;
     TPasJSONPointers=array[0..65535] of TPasJSONPointer;

     PPPasJSONVoid=^PPasJSONVoid;
     PPasJSONVoid=TPasJSONPointer;

     PPPasJSONFloat=^PPasJSONFloat;
     PPasJSONFloat=^TPasJSONFloat;
     TPasJSONFloat=Single;

     TPasJSONFloats=array of TPasJSONFloat;

     PPPasJSONDouble=^PPasJSONDouble;
     PPasJSONDouble=^TPasJSONDouble;
     TPasJSONDouble=Double;

     PPPasJSONPtrUInt=^PPasJSONPtrUInt;
     PPPasJSONPtrInt=^PPasJSONPtrInt;
     PPasJSONPtrUInt=^TPasJSONPtrUInt;
     PPasJSONPtrInt=^TPasJSONPtrInt;
{$ifdef fpc}
     TPasJSONPtrUInt=PtrUInt;
     TPasJSONPtrInt=PtrInt;
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
     TPasJSONPtrUInt=NativeUInt;
     TPasJSONPtrInt=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
{$ifdef cpu64}
     TPasJSONPtrUInt=uint64;
     TPasJSONPtrInt=int64;
{$else}
     TPasJSONPtrUInt=longword;
     TPasJSONPtrInt=longint;
{$endif}
{$endif}

     PPPasJSONSizeUInt=^PPasJSONSizeUInt;
     PPasJSONSizeUInt=^TPasJSONSizeUInt;
     TPasJSONSizeUInt=TPasJSONPtrUInt;

     PPPasJSONSizeInt=^PPasJSONSizeInt;
     PPasJSONSizeInt=^TPasJSONSizeInt;
     TPasJSONSizeInt=TPasJSONPtrInt;

     PPPasJSONNativeUInt=^PPasJSONNativeUInt;
     PPasJSONNativeUInt=^TPasJSONNativeUInt;
     TPasJSONNativeUInt=TPasJSONPtrUInt;

     PPPasJSONNativeInt=^PPasJSONNativeInt;
     PPasJSONNativeInt=^TPasJSONNativeInt;
     TPasJSONNativeInt=TPasJSONPtrInt;

     PPPasJSONSize=^PPasJSONSizeUInt;
     PPasJSONSize=^TPasJSONSizeUInt;
     TPasJSONSize=TPasJSONPtrUInt;

     PPPasJSONPtrDiff=^PPasJSONPtrDiff;
     PPasJSONPtrDiff=^TPasJSONPtrDiff;
     TPasJSONPtrDiff=TPasJSONPtrInt;

     PPPasJSONRawByteString=^PPasJSONRawByteString;
     PPasJSONRawByteString=^TPasJSONRawByteString;
     TPasJSONRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     PPPasJSONUTF8String=^PPasJSONUTF8String;
     PPasJSONUTF8String=^TPasJSONUTF8String;
     TPasJSONUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     PPPasJSONUTF16String=^PPasJSONUTF16String;
     PPasJSONUTF16String=^TPasJSONUTF16String;
     TPasJSONUTF16String={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

     EPasJSONSyntaxError=class(Exception)
      private
       fPosition:TPasJSONSizeInt;
      public
       constructor Create(const aMessage:string;const aPosition:TPasJSONSizeInt); reintroduce;
      published
       property Position:TPasJSONSizeInt read fPosition write fPosition;
     end;

     EPasJSONMergeError=class(Exception);

     TPasJSONMergeFlag=
      (
       ForceObjectPropertyValueDestinationType
      );

     TPasJSONMergeFlags=set of TPasJSONMergeFlag;

     TPasJSONItem=class
      public
       constructor Create;
       destructor Destroy; override;
       function Clone:TPasJSONItem; virtual; abstract;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); virtual;
     end;

     TPasJSONItems=array of TPasJSONItem;

     TPasJSONItemNull=class(TPasJSONItem)
      public
       constructor Create;
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
     end;

     TPasJSONItemBoolean=class(TPasJSONItem)
      private
       fValue:boolean;
      public
       constructor Create(const AValue:boolean);
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
      published
       property Value:boolean read fValue write fValue;
     end;

     TPasJSONItemNumber=class(TPasJSONItem)
      private
       fValue:TPasJSONDouble;
      public
       constructor Create(const AValue:TPasJSONDouble);
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
      published
       property Value:TPasJSONDouble read fValue write fValue;
     end;

     TPasJSONItemString=class(TPasJSONItem)
      private
       fValue:TPasJSONUTF8String;
      public
       constructor Create(const AValue:TPasJSONUTF8String);
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
      published
       property Value:TPasJSONUTF8String read fValue write fValue;
     end;

     TPasJSONItemObjectProperty=class
      private
       fKey:TPasJSONUTF8String;
       fValue:TPasJSONItem;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
      published
       property Key:TPasJSONUTF8String read fKey write fKey;
       property Value:TPasJSONItem read fValue write fValue;
     end;

     TPasJSONItemObjectProperties=array of TPasJSONItemObjectProperty;

     TPasJSONItemObject=class(TPasJSONItem)
      public
       type PPasJSONItemObjectEnumerator=^TPasJSONItemObjectEnumerator;
            TPasJSONItemObjectEnumerator=record
             private
              fOwner:TPasJSONItemObject;
              fIndex:TPasJSONSizeInt;
              function GetCurrent:TPasJSONItemObjectProperty; inline;
             public
              constructor Create(const aOwner:TPasJSONItemObject);
              function MoveNext:boolean; inline;
              property Current:TPasJSONItemObjectProperty read GetCurrent;
            end;
      private
       fProperties:TPasJSONItemObjectProperties;
       fCount:TPasJSONSizeInt;
       function GetKeyIndex(const aKey:TPasJSONUTF8String):TPasJSONInt32;
       function GetKey(const aIndex:TPasJSONSizeInt):TPasJSONUTF8String;
       procedure SetKey(const aIndex:TPasJSONSizeInt;const aKey:TPasJSONUTF8String);
       function GetValue(const aIndex:TPasJSONSizeInt):TPasJSONItem;
       procedure SetValue(const aIndex:TPasJSONSizeInt;const aItem:TPasJSONItem);
       function GetProperty(const aKey:TPasJSONUTF8String):TPasJSONItem;
       procedure SetProperty(const aKey:TPasJSONUTF8String;const aItem:TPasJSONItem);
      public
       constructor Create;
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       function GetEnumerator:TPasJSONItemObjectEnumerator; inline;
       procedure Clear;
       procedure Add(const aKey:TPasJSONUTF8String;const aValue:TPasJSONItem);
       procedure Delete(const aIndex:TPasJSONSizeInt); overload;
       procedure Delete(const aKey:TPasJSONUTF8String); overload;
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
       property Count:TPasJSONSizeInt read fCount;
       property Indices[const Key:TPasJSONUTF8String]:TPasJSONInt32 read GetKeyIndex;
       property Keys[const Index:TPasJSONSizeInt]:TPasJSONUTF8String read GetKey write SetKey;
       property Values[const Index:TPasJSONSizeInt]:TPasJSONItem read GetValue write SetValue;
       property Properties[const Key:TPasJSONUTF8String]:TPasJSONItem read GetProperty write SetProperty; default;
     end;

     TPasJSONItemArray=class(TPasJSONItem)
      public
       type PPasJSONItemArrayEnumerator=^TPasJSONItemArrayEnumerator;
            TPasJSONItemArrayEnumerator=record
             private
              fOwner:TPasJSONItemArray;
              fIndex:TPasJSONSizeInt;
              function GetCurrent:TPasJSONItem; inline;
             public
              constructor Create(const aOwner:TPasJSONItemArray);
              function MoveNext:boolean; inline;
              property Current:TPasJSONItem read GetCurrent;
            end;
      private
       fItems:TPasJSONItems;
       fCount:TPasJSONInt32;
       function GetValue(const Index:TPasJSONInt32):TPasJSONItem;
       procedure SetValue(const Index:TPasJSONInt32;const Item:TPasJSONItem);
      public
       constructor Create;
       destructor Destroy; override;
       function Clone:TPasJSONItem; override;
       function GetEnumerator:TPasJSONItemArrayEnumerator; inline;
       procedure Clear;
       procedure Add(const aValue:TPasJSONItem);
       procedure Delete(const aIndex:TPasJSONSizeInt);
       procedure Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]); override;
       property Count:TPasJSONInt32 read fCount;
       property Items[const Index:TPasJSONInt32]:TPasJSONItem read GetValue write SetValue; default;
     end;

     PPasJSONModeFlag=^TPasJSONModeFlag;
     TPasJSONModeFlag=
      (
       UnquotedKeys,
       Comments,
       ImplicitRootObject,
       OptionalCommas,
       EqualsForColon,
       MultilineStrings,
       HexadecimalNumbers
      );

     PPasJSONModeFlags=^TPasJSONModeFlag;
     TPasJSONModeFlags=set of TPasJSONModeFlag;

     PPasJSONEncoding=^TPasJSONEncoding;
     TPasJSONEncoding=
      (
       AutomaticDetection,
       Latin1,
       UTF8,
       UTF16LE,
       UTF16BE,
       UTF32LE,
       UTF32BE
      );

     TPasJSON=class
      public
       // Simplified JSON notation as in http://bitsquid.blogspot.de/2009/10/simplified-json-notation.html
       const SimplifiedJSONModeFlags:TPasJSONModeFlags=[TPasJSONModeFlag.UnquotedKeys,
                                                        TPasJSONModeFlag.Comments,
                                                        TPasJSONModeFlag.ImplicitRootObject,
                                                        TPasJSONModeFlag.OptionalCommas,
                                                        TPasJSONModeFlag.EqualsForColon,
                                                        TPasJSONModeFlag.MultilineStrings];
      public
       class function StringQuote(const aString:TPasJSONUTF8String):TPasJSONRawByteString; static;
       class function Parse(const aSource:TPasJSONRawByteString;const aModeFlags:TPasJSONModeFlags=[TPasJSONModeFlag.Comments];const aEncoding:TPasJSONEncoding=TPasJSONEncoding.AutomaticDetection):TPasJSONItem; overload; static;
       class function Parse(const aStream:TStream;const aModeFlags:TPasJSONModeFlags=[TPasJSONModeFlag.Comments];const aEncoding:TPasJSONEncoding=TPasJSONEncoding.AutomaticDetection):TPasJSONItem; overload; static;
       class function Stringify(const aJSONItem:TPasJSONItem;const aFormatting:boolean=false;const aModeFlags:TPasJSONModeFlags=[];const aLevel:TPasJSONInt32=0):TPasJSONRawByteString; static;
       class procedure StringifyToStream(const aStream:TStream;const aJSONItem:TPasJSONItem;const aFormatting:boolean=false;const aModeFlags:TPasJSONModeFlags=[];const aLevel:TPasJSONInt32=0); static;
       class function GetNumber(const aItem:TPasJSONItem;const aDefault:TPasJSONDouble=0.0):TPasJSONDouble; static;
       class function GetInt64(const aItem:TPasJSONItem;const aDefault:TPasJSONInt64=0):TPasJSONInt64; static;
       class function GetUInt64(const aItem:TPasJSONItem;const aDefault:TPasJSONUInt64=0):TPasJSONUInt64; static;
       class function GetString(const aItem:TPasJSONItem;const aDefault:TPasJSONUTF8String=''):TPasJSONUTF8String; static;
       class function GetBoolean(const aItem:TPasJSONItem;const aDefault:boolean=false):boolean; static;
       class function LoadBinaryFromStream(const aStream:TStream):TPasJSONItem; static;
       class procedure SaveBinaryToStream(const aStream:TStream;const aJSONItem:TPasJSONItem); static;
     end;

implementation

uses PasDblStrUtils;

                                           //0 1 2 3 4 5 6 7 8 9 a b c d e f
const{UTF8CharSteps:array[AnsiChar] of byte=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 1
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 2
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 3
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 4
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 5
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 6
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 7
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 8
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 9
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // a
                                             1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // b
                                             1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // c
                                             2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // d
                                             3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,  // e
                                             4,4,4,4,4,1,1,1,1,1,1,1,1,1,1,1); // f
                                           //0 1 2 3 4 5 6 7 8 9 a b c d e f  }

      UTF8DFACharClasses:array[AnsiChar] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                                  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
                                                  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                                                  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                                                  8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
                                                  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
                                                  10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3,
                                                  11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8);

      UTF8DFATransitions:array[byte] of byte=(0,16,32,48,80,128,112,16,16,16,64,96,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,0,16,16,16,16,16,0,16,0,16,16,16,16,16,16,
                                              16,32,16,16,16,16,16,32,16,32,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,32,16,16,16,16,16,16,16,16,
                                              16,32,16,16,16,16,16,16,16,32,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,48,16,48,16,16,16,16,16,16,
                                              16,48,16,16,16,16,16,48,16,48,16,16,16,16,16,16,
                                              16,48,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                              16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16);

      suDONOTKNOW=-1;
      suNOUTF8=0;
      suPOSSIBLEUTF8=1;
      suISUTF8=2;

      ucACCEPT=0;
      ucERROR=16;

function GetNextUTF8Char(const aString:PPasJSONRawByteChar;const aStringLength:TPasJSONInt32;var aCodeUnit:TPasJSONInt32):TPasJSONUInt32;
var StartCodeUnit,Value,CharClass,State:TPasJSONUInt32;
begin
 result:=0;
 if (aCodeUnit>0) and (aCodeUnit<=aStringLength) then begin
  dec(aCodeUnit);
  StartCodeUnit:=aCodeUnit;
  State:=ucACCEPT;
  while aCodeUnit<aStringLength do begin
   Value:=byte(AnsiChar(aString[aCodeUnit]));
   inc(aCodeUnit);
   CharClass:=UTF8DFACharClasses[AnsiChar(Value)];
   if State=ucACCEPT then begin
    result:=Value and ($ff shr CharClass);
   end else begin
    result:=(result shl 6) or (Value and $3f);
   end;
   State:=UTF8DFATransitions[State+CharClass];
   if State<=ucERROR then begin
    break;
   end;
  end;
  if State<>ucACCEPT then begin
   result:=byte(AnsiChar(aString[StartCodeUnit]));
   aCodeUnit:=StartCodeUnit+1;
  end;
  inc(aCodeUnit);
 end;
end;

function ConvertUTF16ToUTF8(const aUTF16String:TPasJSONUTF16String):TPasJSONUTF8String;
var i,j:TPasJSONInt32;
    w:UInt16;
    u4c:TPasJSONUInt32;
begin
 result:='';
 j:=0;
 i:=1;
 while i<=length(aUTF16String) do begin
  w:=UInt16(TPasJSONUTF16Char(aUTF16String[i]));
  if (w<=$d7ff) or (w>=$e000) then begin
   u4c:=w;
   inc(i);
  end else if ((i+1)<=length(aUTF16String)) and ((w>=$d800) and (w<=$dbff)) and ((UInt16(aUTF16String[i+1])>=$dc00) and (UInt16(aUTF16String[i+1])<=$dfff)) then begin
   u4c:=(TPasJSONUInt32(TPasJSONUInt32(w and $3ff) shl 10) or TPasJSONUInt32(UInt16(TPasJSONUTF16Char(aUTF16String[i+1])) and $3ff))+$10000;
   inc(i,2);
  end else begin
   u4c:=$fffd;
   inc(i);
  end;
  if u4c<=$7f then begin
   inc(j);
  end else if u4c<=$7ff then begin
   inc(j,2);
  end else if u4c<=$ffff then begin
   inc(j,3);
  end else if u4c<=$1fffff then begin
   inc(j,4);
  end else begin
   inc(j,3);
  end;
 end;
 SetLength(result,j);
 j:=1;
 i:=1;
 while i<=length(aUTF16String) do begin
  w:=UInt16(TPasJSONUTF16Char(aUTF16String[i]));
  if (w<=$d7ff) or (w>=$e000) then begin
   u4c:=w;
   inc(i);
  end else if ((i+1)<=length(aUTF16String)) and ((w>=$d800) and (w<=$dbff)) and ((UInt16(aUTF16String[i+1])>=$dc00) and (UInt16(aUTF16String[i+1])<=$dfff)) then begin
   u4c:=(TPasJSONUInt32(TPasJSONUInt32(w and $3ff) shl 10) or TPasJSONUInt32(UInt16(TPasJSONUTF16Char(aUTF16String[i+1])) and $3ff))+$10000;
   inc(i,2);
  end else begin
   u4c:=$fffd;
   inc(i);
  end;
  if u4c<=$7f then begin
   result[j]:=ansichar(byte(u4c));
   inc(j);
  end else if u4c<=$7ff then begin
   result[j]:=ansichar(byte($c0 or ((u4c shr 6) and $1f)));
   result[j+1]:=ansichar(byte($80 or (u4c and $3f)));
   inc(j,2);
  end else if u4c<=$ffff then begin
   result[j]:=ansichar(byte($e0 or ((u4c shr 12) and $0f)));
   result[j+1]:=ansichar(byte($80 or ((u4c shr 6) and $3f)));
   result[j+2]:=ansichar(byte($80 or (u4c and $3f)));
   inc(j,3);
  end else if u4c<=$1fffff then begin
   result[j]:=ansichar(byte($f0 or ((u4c shr 18) and $07)));
   result[j+1]:=ansichar(byte($80 or ((u4c shr 12) and $3f)));
   result[j+2]:=ansichar(byte($80 or ((u4c shr 6) and $3f)));
   result[j+3]:=ansichar(byte($80 or (u4c and $3f)));
   inc(j,4);
  end else begin
   u4c:=$fffd;
   result[j]:=ansichar(byte($e0 or (u4c shr 12)));
   result[j+1]:=ansichar(byte($80 or ((u4c shr 6) and $3f)));
   result[j+2]:=ansichar(byte($80 or (u4c and $3f)));
   inc(j,3);
  end;
 end;
end;

constructor EPasJSONSyntaxError.Create(const aMessage:string;const aPosition:TPasJSONSizeInt);
begin
 inherited Create(aMessage);
 fPosition:=aPosition;
end;

constructor TPasJSONItem.Create;
begin
 inherited Create;
end;

destructor TPasJSONItem.Destroy;
begin
 inherited Destroy;
end;

procedure TPasJSONItem.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
begin
 if not (assigned(aWith) and (aWith is TPasJSONItem)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
end;

constructor TPasJSONItemNull.Create;
begin
 inherited Create;
end;

destructor TPasJSONItemNull.Destroy;
begin
 inherited Destroy;
end;

function TPasJSONItemNull.Clone:TPasJSONItem;
begin
 result:=TPasJSONItemNull.Create;
end;

procedure TPasJSONItemNull.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemNull)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
end;

constructor TPasJSONItemBoolean.Create(const AValue:boolean);
begin
 inherited Create;
 fValue:=AValue;
end;

destructor TPasJSONItemBoolean.Destroy;
begin
 inherited Destroy;
end;

function TPasJSONItemBoolean.Clone:TPasJSONItem;
begin
 result:=TPasJSONItemBoolean.Create(fValue);
end;

procedure TPasJSONItemBoolean.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemBoolean)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
 fValue:=TPasJSONItemBoolean(aWith).Value;
end;

constructor TPasJSONItemNumber.Create(const AValue:TPasJSONDouble);
begin
 inherited Create;
 fValue:=AValue;
end;

destructor TPasJSONItemNumber.Destroy;
begin
 inherited Destroy;
end;

function TPasJSONItemNumber.Clone:TPasJSONItem;
begin
 result:=TPasJSONItemNumber.Create(fValue);
end;

procedure TPasJSONItemNumber.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemNumber)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
 fValue:=TPasJSONItemNumber(aWith).Value;
end;

constructor TPasJSONItemString.Create(const AValue:TPasJSONUTF8String);
begin
 inherited Create;
 fValue:=AValue;
end;

destructor TPasJSONItemString.Destroy;
begin
 fValue:='';
 inherited Destroy;
end;

function TPasJSONItemString.Clone:TPasJSONItem;
begin
 result:=TPasJSONItemString.Create(fValue);
end;

procedure TPasJSONItemString.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemString)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
 fValue:=TPasJSONItemString(aWith).Value;
end;

constructor TPasJSONItemObjectProperty.Create;
begin
 inherited Create;
 fKey:='';
 fValue:=nil;
end;

destructor TPasJSONItemObjectProperty.Destroy;
begin
 fKey:='';
 FreeAndNil(fValue);
 inherited Destroy;
end;

constructor TPasJSONItemObject.TPasJSONItemObjectEnumerator.Create(const aOwner:TPasJSONItemObject);
begin
 fOwner:=aOwner;
 fIndex:=-1;
end;

function TPasJSONItemObject.TPasJSONItemObjectEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=(fIndex>=0) and (fIndex<fOwner.fCount);
end;

function TPasJSONItemObject.TPasJSONItemObjectEnumerator.GetCurrent:TPasJSONItemObjectProperty;
begin
 result:=fOwner.fProperties[fIndex];
end;

constructor TPasJSONItemObject.Create;
begin
 inherited Create;
 fProperties:=nil;
 fCount:=0;
end;

destructor TPasJSONItemObject.Destroy;
var Index:TPasJSONInt32;
begin
 for Index:=0 to fCount-1 do begin
  FreeAndNil(fProperties[Index]);
 end;
 SetLength(fProperties,0);
 inherited Destroy;
end;

function TPasJSONItemObject.Clone:TPasJSONItem;
var ClonedObject:TPasJSONItemObject;
    Index:TPasJSONInt32;
begin
 ClonedObject:=TPasJSONItemObject.Create;
 for Index:=0 to fCount-1 do begin
  ClonedObject.Add(fProperties[Index].Key,fProperties[Index].Value.Clone);
 end;
 result:=ClonedObject;
end;

function TPasJSONItemObject.GetKeyIndex(const aKey:TPasJSONUTF8String):TPasJSONInt32;
var Index:TPasJSONInt32;
begin
 for Index:=0 to fCount-1 do begin
  if fProperties[Index].Key=aKey then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TPasJSONItemObject.GetKey(const aIndex:TPasJSONSizeInt):TPasJSONUTF8String;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fProperties[aIndex].Key;
 end else begin
  result:='';
 end;
end;

procedure TPasJSONItemObject.SetKey(const aIndex:TPasJSONSizeInt;const aKey:TPasJSONUTF8String);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  fProperties[aIndex].Key:=aKey;
 end;
end;

function TPasJSONItemObject.GetValue(const aIndex:TPasJSONSizeInt):TPasJSONItem;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fProperties[aIndex].Value;
 end else begin
  result:=nil;
 end;
end;

procedure TPasJSONItemObject.SetValue(const aIndex:TPasJSONSizeInt;const aItem:TPasJSONItem);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  fProperties[aIndex].Value:=aItem;
 end;
end;

function TPasJSONItemObject.GetProperty(const aKey:TPasJSONUTF8String):TPasJSONItem;
begin
 result:=GetValue(GetKeyIndex(aKey));
end;

procedure TPasJSONItemObject.SetProperty(const aKey:TPasJSONUTF8String;const aItem:TPasJSONItem);
begin
 SetValue(GetKeyIndex(aKey),aItem);
end;

function TPasJSONItemObject.GetEnumerator:TPasJSONItemObject.TPasJSONItemObjectEnumerator;
begin
 result:=TPasJSONItemObject.TPasJSONItemObjectEnumerator.Create(self);
end;

procedure TPasJSONItemObject.Clear;
var Index:TPasJSONInt32;
begin
 for Index:=0 to fCount-1 do begin
  FreeAndNil(fProperties[Index]);
 end;
 SetLength(fProperties,0);
 fCount:=0;
end;

procedure TPasJSONItemObject.Add(const aKey:TPasJSONUTF8String;const aValue:TPasJSONItem);
var Index:TPasJSONSizeInt;
    ObjectProperty:TPasJSONItemObjectProperty;
begin
 Index:=fCount;
 inc(fCount);
 if fCount>=length(fProperties) then begin
  SetLength(fProperties,fCount*2);
 end;
 ObjectProperty:=TPasJSONItemObjectProperty.Create;
 fProperties[Index]:=ObjectProperty;
 ObjectProperty.Key:=aKey;
 ObjectProperty.Value:=aValue;
end;

procedure TPasJSONItemObject.Delete(const aIndex:TPasJSONSizeInt);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  FreeAndNil(fProperties[aIndex]);
  dec(fCount);
  Move(fProperties[aIndex+1],fProperties[aIndex],fCount*SizeOf(TPasJSONItemObjectProperty));
 end;
end;

procedure TPasJSONItemObject.Delete(const aKey:TPasJSONUTF8String);
begin
 Delete(GetKeyIndex(aKey));
end;

procedure TPasJSONItemObject.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
var Index,KeyIndex:TPasJSONSizeint;
    SrcProperty,OurProperty:TPasJSONItemObjectProperty;
    NewItem:TPasJSONItem;
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemObject)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
 for Index:=0 to TPasJSONItemObject(aWith).Count-1 do begin
  SrcProperty:=TPasJSONItemObject(aWith).fProperties[Index];
  if assigned(SrcProperty.Value) then begin
   KeyIndex:=GetKeyIndex(SrcProperty.Key);
   if KeyIndex>=0 then begin
    OurProperty:=fProperties[KeyIndex];
    if (TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType in aFlags) and
       ((not assigned(OurProperty.Value)) or
        (assigned(OurProperty.Value) and
         (OurProperty.Value.ClassType<>SrcProperty.Value.ClassType))) then begin
     if assigned(OurProperty.Value) then begin
      OurProperty.Value.Free;
     end;
     OurProperty.Value:=TPasJSONItem(SrcProperty.Value.ClassType.Create);
    end;
    if assigned(OurProperty.Value) and (OurProperty.Value.ClassType=SrcProperty.Value.ClassType) then begin
     OurProperty.Value.Merge(SrcProperty.Value,aFlags);
    end;
   end else begin
    NewItem:=nil;
    try
     NewItem:=TPasJSONItem(SrcProperty.Value.ClassType.Create);
     NewItem.Merge(SrcProperty.Value,aFlags);
     Add(SrcProperty.Key,NewItem);
    except
     NewItem.Free;
     raise;
    end;
   end;
  end;
 end;
end;

constructor TPasJSONItemArray.TPasJSONItemArrayEnumerator.Create(const aOwner:TPasJSONItemArray);
begin
 fOwner:=aOwner;
 fIndex:=-1;
end;

function TPasJSONItemArray.TPasJSONItemArrayEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=(fIndex>=0) and (fIndex<fOwner.fCount);
end;

function TPasJSONItemArray.TPasJSONItemArrayEnumerator.GetCurrent:TPasJSONItem;
begin
 result:=fOwner.fItems[fIndex];
end;

constructor TPasJSONItemArray.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
end;

destructor TPasJSONItemArray.Destroy;
var Index:TPasJSONInt32;
begin
 for Index:=0 to fCount-1 do begin
  FreeAndNil(fItems[Index]);
 end;
 SetLength(fItems,0);
 inherited Destroy;
end;

function TPasJSONItemArray.Clone:TPasJSONItem;
var ClonedArray:TPasJSONItemArray;
    Index:TPasJSONInt32;
begin
 ClonedArray:=TPasJSONItemArray.Create;
 for Index:=0 to fCount-1 do begin
  ClonedArray.Add(fItems[Index].Clone);
 end;
 result:=ClonedArray;
end;

function TPasJSONItemArray.GetValue(const Index:TPasJSONInt32):TPasJSONItem;
begin
 if (Index>=0) and (Index<fCount) then begin
  result:=fItems[Index];
 end else begin
  result:=nil;
 end;
end;

procedure TPasJSONItemArray.SetValue(const Index:TPasJSONInt32;const Item:TPasJSONItem);
begin
 if (Index>=0) and (Index<fCount) then begin
  fItems[Index]:=Item;
 end;
end;

function TPasJSONItemArray.GetEnumerator:TPasJSONItemArray.TPasJSONItemArrayEnumerator;
begin
 result:=TPasJSONItemArray.TPasJSONItemArrayEnumerator.Create(self);
end;

procedure TPasJSONItemArray.Clear;
var Index:TPasJSONInt32;
begin
 for Index:=0 to fCount-1 do begin
  FreeAndNil(fItems[Index]);
 end;
 SetLength(fItems,0);
 fCount:=0;
end;

procedure TPasJSONItemArray.Add(const aValue:TPasJSONItem);
var Index:TPasJSONSizeInt;
begin
 Index:=fCount;
 inc(fCount);
 if fCount>=length(fItems) then begin
  SetLength(fItems,fCount*2);
 end;
 fItems[Index]:=aValue;
end;

procedure TPasJSONItemArray.Delete(const aIndex:TPasJSONSizeInt);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  FreeAndNil(fItems[aIndex]);
  dec(fCount);
  Move(fItems[aIndex+1],fItems[aIndex],fCount*SizeOf(TPasJSONItem));
 end;
end;

procedure TPasJSONItemArray.Merge(const aWith:TPasJSONItem;const aFlags:TPasJSONMergeFlags=[]);
var Index:TPasJSONSizeInt;
    Item,NewItem:TPasJSONItem;
begin
 if not (assigned(aWith) and (aWith is TPasJSONItemArray)) then begin
  raise EPasJSONMergeError.Create('Incompatible data type');
 end;
 for Index:=0 to TPasJSONItemArray(aWith).Count-1 do begin
  Item:=TPasJSONItemArray(aWith).Items[Index];
  if assigned(Item) then begin
   NewItem:=TPasJSONItem(Item.ClassType.Create);
   Add(NewItem);
   NewItem.Merge(Item,aFlags);
  end;
 end;
end;

const HexChars:array[boolean,0..15] of ansichar=(('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'),
                                                 ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'));

class function TPasJSON.StringQuote(const aString:TPasJSONUTF8String):TPasJSONRawByteString;
var i,l:TPasJSONInt32;
    c,t:TPasJSONUInt32;
begin
 result:='"';
 i:=1;
 l:=length(aString);
 while i<=l do begin
  case aString[i] of
   '"','\':begin
    result:=result+'\'+AnsiChar(aString[i]);
    inc(i);
   end;
   #$08:begin
    result:=result+'\b';
    inc(i);
   end;
   #$09:begin
    result:=result+'\t';
    inc(i);
   end;
   #$0a:begin
    result:=result+'\n';
    inc(i);
   end;
   #$0b:begin
    result:=result+'\v';
    inc(i);
   end;
   #$0c:begin
    result:=result+'\f';
    inc(i);
   end;
   #$0d:begin
    result:=result+'\r';
    inc(i);
   end;
   #$00..#$07,#$0e..#$1f,#$7e..#$7f:begin
    c:=byte(AnsiChar(aString[i]));
    result:=result+'\u00'+HexChars[false,(c shr 4) and $f]+HexChars[false,c and $f];
    inc(i);
   end;
   #$80..#$ff:begin
    c:=GetNextUTF8Char(PAnsiChar(@aString[1]),l,i);
    case c of
     $0000..$d7ff,$f000..$fffc:begin
      result:=result+'\u'+HexChars[false,(c shr 12) and $f]+HexChars[false,(c shr 8) and $f]+HexChars[false,(c shr 4) and $f]+HexChars[false,c and $f];
     end;
     $10000..$10ffff:begin
      dec(c,$10000);
      t:=(c shr 10) or $d800;
      result:=result+'\u'+HexChars[false,(t shr 12) and $f]+HexChars[false,(t shr 8) and $f]+HexChars[false,(t shr 4) and $f]+HexChars[false,t and $f];
      t:=(c and $3ff) or $dc00;
      result:=result+'\u'+HexChars[false,(t shr 12) and $f]+HexChars[false,(t shr 8) and $f]+HexChars[false,(t shr 4) and $f]+HexChars[false,t and $f];
     end;
     else {-$d800..$dfff,$fffd..$ffff,$110000..$ffffffff:}begin
      result:=result+'\ufffd';
     end;
    end;
   end;
   else begin
    result:=result+AnsiChar(aString[i]);
    inc(i);
   end;
  end;
 end;
 result:=result+'"';
end;

class function TPasJSON.Parse(const aSource:TPasJSONRawByteString;const aModeFlags:TPasJSONModeFlags=[TPasJSONModeFlag.Comments];const aEncoding:TPasJSONEncoding=TPasJSONEncoding.AutomaticDetection):TPasJSONItem;
var Position:TPasJSONInt32;
    CurrentChar:TPasJSONUInt32;
    CharEOF:boolean;
    Encoding:TPasJSONEncoding;
 procedure NextChar;
 const UTF16Shifts:array[TPasJSONEncoding.UTF16LE..TPasJSONEncoding.UTF16BE,0..1] of TPasJSONInt32=((0,8),(8,0));
 var Temp:TPasJSONUInt32;
 begin
  if Position<=length(aSource) then begin
   case Encoding of
    TPasJSONEncoding.UTF8:begin
     CurrentChar:=GetNextUTF8Char(PAnsiChar(@aSource[1]),Length(aSource),Position);
    end;
    TPasJSONEncoding.UTF16LE,TPasJSONEncoding.UTF16BE:begin
     if (Position+1)<=length(aSource) then begin
      CurrentChar:=(TPasJSONUInt32(byte(AnsiChar(aSource[Position]))) shl UTF16Shifts[Encoding,0]) or (TPasJSONUInt32(byte(AnsiChar(aSource[Position+1]))) shl UTF16Shifts[Encoding,1]);
      inc(Position,2);
      if ((CurrentChar>=$d800) and (CurrentChar<=$dbff)) and ((Position+1)<=length(aSource)) then begin
       Temp:=(TPasJSONUInt32(byte(AnsiChar(aSource[Position]))) shl UTF16Shifts[Encoding,0]) or (TPasJSONUInt32(byte(AnsiChar(aSource[Position+1]))) shl UTF16Shifts[Encoding,1]);
       if (Temp>=$dc00) and (Temp<=$dfff) then begin
        CurrentChar:=(TPasJSONUInt32(TPasJSONUInt32(CurrentChar and $3ff) shl 10) or TPasJSONUInt32(Temp and $3ff))+$10000;
        inc(Position,2);
       end else begin
        CurrentChar:=$fffd;
       end;
      end else if not ((CurrentChar<=$d7ff) or (CurrentChar>=$e000)) then begin
       CurrentChar:=$fffd;
      end;
     end else begin
      inc(Position);
      CurrentChar:=0;
      CharEOF:=true;
     end;
    end;
    TPasJSONEncoding.UTF32LE:begin
     if (Position+3)<=length(aSource) then begin
      CurrentChar:=(TPasJSONUInt32(byte(AnsiChar(aSource[Position]))) shl 0) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+1]))) shl 8) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+2]))) shl 16) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+3]))) shl 24);
      inc(Position,4);
     end else begin
      inc(Position);
      CurrentChar:=0;
      CharEOF:=true;
     end;
    end;
    TPasJSONEncoding.UTF32BE:begin
     if (Position+3)<=length(aSource) then begin
      CurrentChar:=(TPasJSONUInt32(byte(AnsiChar(aSource[Position]))) shl 24) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+1]))) shl 16) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+2]))) shl 8) or
                   (TPasJSONUInt32(byte(AnsiChar(aSource[Position+3]))) shl 0);
      inc(Position,4);
     end else begin
      inc(Position);
      CurrentChar:=0;
      CharEOF:=true;
     end;
    end;
    else begin
     CurrentChar:=byte(AnsiChar(aSource[Position]));
     inc(Position);
    end;
   end;
  end else begin
   CurrentChar:=0;
   CharEOF:=true;
  end;
 end;
 procedure JSONError;
 begin
  raise EPasJSONSyntaxError.Create('Parser error at byte position '+IntToStr(Position),Position);
 end;
 procedure SkipWhite;
 var LastChar:TPasJSONUInt32;
 begin
  while not CharEOF do begin
   case CurrentChar of
    $0009,$000a,$000d,$0020:begin
     NextChar;
    end;
    ord('/'):begin
     if TPasJSONModeFlag.Comments in aModeFlags then begin
      NextChar;
      case CurrentChar of
       ord('/'):begin
        NextChar;
        while not (CharEOF or ((CurrentChar=$000a) or (CurrentChar=$000d))) do begin
         NextChar;
        end;
       end;
       ord('*'):begin
        NextChar;
        LastChar:=0;
        while not (CharEOF or ((LastChar=ord('*')) and (CurrentChar=ord('/')))) do begin
         LastChar:=CurrentChar;
         NextChar;
        end;
        if CurrentChar=ord('/') then begin
         NextChar;
        end;
       end;
       else begin
        JSONError;
       end;
      end;
     end else begin
      JSONError;
     end;
    end;
    else begin
     break;
    end;
   end;
  end;
 end;
 function IsChar(c:TPasJSONUTF16Char):boolean;
 begin
  result:=(not CharEOF) and (CurrentChar=UInt16(c));
 end;
 procedure ExpectChar(c:TPasJSONUTF16Char);
 begin
  if IsChar(c) then begin
   NextChar;
  end else begin
   JSONError;
  end;
 end;
 function ParseValue(const ImplicitRootObject:boolean):TPasJSONItem;
  function ParseString:TPasJSONItem;
  var w:TPasJSONUTF16String; // <= because of easy correct handling of UTF16 surrogates (see ECMAScript and JSON specs)
      wl:TPasJSONInt32;
      wc:TPasJSONUInt32;
   procedure AddChar16(c:TPasJSONUInt32);
   var cl:TPasJSONInt32;
   begin
    if (c>=$10000) and (c<=$10ffff) then begin
     cl:=2;
    end else begin
     cl:=1;
    end;
    if (wl+cl)>length(w) then begin
     SetLength(w,(wl+cl) shl 1);
    end;
    if c<=$ffff then begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16(c));
    end else if c<=$10ffff then begin
     dec(c,$10000);
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16((c shr 10) or $d800));
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16((c and $3ff) or $dc00));
    end else begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16($fffd));
    end;
   end;
   procedure AddChar(c:TPasJSONUInt32);
   var cl:TPasJSONInt32;
   begin
    if (c>=$10000) and (c<=$10ffff) then begin
     cl:=2;
    end else begin
     cl:=1;
    end;
    if (wl+cl)>length(w) then begin
     SetLength(w,(wl+cl) shl 1);
    end;
    if c<=$d7ff then begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16(c));
    end else if c<=$dfff then begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16($fffd));
    end else if c<=$fffd then begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16(c));
    end else if c<=$ffff then begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16($fffd));
    end else if c<=$10ffff then begin
     dec(c,$10000);
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16((c shr 10) or $d800));
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16((c and $3ff) or $dc00));
    end else begin
     inc(wl);
     w[wl]:=TPasJSONUTF16Char(UInt16($fffd));
    end;
   end;
  begin
   result:=nil;
   w:='';
   try
    try
     SetLength(w,512);
     wl:=0;
     if IsChar('"') then begin
      NextChar;
      while not (CharEOF or IsChar('"')) do begin
       case CurrentChar of
        $0000..$001f:begin
         if TPasJSONModeFlag.MultiLineStrings in aModeFlags then begin
          AddChar(CurrentChar);
          NextChar;
         end else begin
          JSONError;
         end;
        end;
        ord('\'):begin
         NextChar;
         case CurrentChar of
          ord('"'),ord('\'),ord('/'):begin
           AddChar(CurrentChar);
           NextChar;
          end;
          ord('b'):begin
           AddChar($0008);
           NextChar;
          end;
          ord('f'):begin
           AddChar($000c);
           NextChar;
          end;
          ord('n'):begin
           AddChar($000a);
           NextChar;
          end;
          ord('r'):begin
           AddChar($000d);
           NextChar;
          end;
          ord('t'):begin
           AddChar($0009);
           NextChar;
          end;
          ord('u'):begin
           NextChar;
           if (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or ((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))) and not CharEOF then begin
            if (CurrentChar>=ord('0')) and (CurrentChar<=ord('9')) then begin
             wc:=UInt16(CurrentChar)-ord('0');
            end else if (CurrentChar>=ord('a')) and (CurrentChar<=ord('f')) then begin
             wc:=(UInt16(CurrentChar)-ord('a'))+$a;
            end else if (CurrentChar>=ord('A')) and (CurrentChar<=ord('F')) then begin
             wc:=(UInt16(CurrentChar)-ord('A'))+$a;
            end else begin
             wc:=0;
            end;
            wc:=wc shl 4;
            NextChar;
            if (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or ((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))) and not CharEOF then begin
             if (CurrentChar>=ord('0')) and (CurrentChar<=ord('9')) then begin
              wc:=wc or UInt16(UInt16(CurrentChar)-ord('0'));
             end else if (CurrentChar>=ord('a')) and (CurrentChar<=ord('f')) then begin
              wc:=wc or UInt16((UInt16(CurrentChar)-ord('a'))+$a);
             end else if (CurrentChar>=ord('A')) and (CurrentChar<=ord('F')) then begin
              wc:=wc or UInt16((UInt16(CurrentChar)-ord('A'))+$a);
             end;
             wc:=wc shl 4;
             NextChar;
             if (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or ((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))) and not CharEOF then begin
              if (CurrentChar>=ord('0')) and (CurrentChar<=ord('9')) then begin
               wc:=wc or UInt16(UInt16(CurrentChar)-ord('0'));
              end else if (CurrentChar>=ord('a')) and (CurrentChar<=ord('f')) then begin
               wc:=wc or UInt16((UInt16(CurrentChar)-ord('a'))+$a);
              end else if (CurrentChar>=ord('A')) and (CurrentChar<=ord('F')) then begin
               wc:=wc or UInt16((UInt16(CurrentChar)-ord('A'))+$a);
              end;
              wc:=wc shl 4;
              NextChar;
              if (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or ((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))) and not CharEOF then begin
               if (CurrentChar>=ord('0')) and (CurrentChar<=ord('9')) then begin
                wc:=wc or UInt16(UInt16(CurrentChar)-ord('0'));
               end else if (CurrentChar>=ord('a')) and (CurrentChar<=ord('f')) then begin
                wc:=wc or UInt16((UInt16(CurrentChar)-ord('a'))+$a);
               end else if (CurrentChar>=ord('A')) and (CurrentChar<=ord('F')) then begin
                wc:=wc or UInt16((UInt16(CurrentChar)-ord('A'))+$a);
               end;
               AddChar16(wc);
               NextChar;
              end else begin
               JSONError;
              end;
             end else begin
              JSONError;
             end;
            end else begin
             JSONError;
            end;
           end else begin
            JSONError;
           end;
          end;
          else begin
           JSONError;
          end;
         end;
        end;
        else begin
         AddChar(CurrentChar);
         NextChar;
        end;
       end;
      end;
      ExpectChar('"');
      SetLength(w,wl);
      result:=TPasJSONItemString.Create(ConvertUTF16ToUTF8(w));
     end else begin
      JSONError;
     end;
     SkipWhite;
    except
     FreeAndNil(result);
     raise;
    end;
   finally
    w:='';
   end;
  end;
  function ParseNumber:TPasJSONItem;
  var s:TPasJSONRawByteString;
      OK:TPasDblStrUtilsBoolean;
      Value:TPasJSONDouble;
      IsHexadecimal:boolean;
  begin
   result:=nil;
   s:='';
   try
    try
     if CharEOF then begin
      JSONError;
     end;
     case CurrentChar of
      ord('-'),ord('0')..ord('9'):begin
       if IsChar('-') then begin
        s:=s+ansichar(byte(CurrentChar));
        NextChar;
        if CharEOF or not ((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) then begin
         JSONError;
        end;
       end;
       IsHexadecimal:=false;
       if (not CharEOF) and (CurrentChar=ord('0')) then begin
        s:=s+ansichar(byte(CurrentChar));
        NextChar;
        if (TPasJSONModeFlag.HexadecimalNumbers in aModeFlags) and
           ((not CharEOF) and (CurrentChar in [ord('x'),ord('X')])) then begin
         s:=s+ansichar(byte(CurrentChar));
         NextChar;
         while (not CharEOF) and
               (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or
                ((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or
                ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))) do begin
          s:=s+ansichar(byte(CurrentChar));
          NextChar;
         end;
         IsHexadecimal:=true;
        end else begin
         if (not CharEOF) and ((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) then begin
          JSONError;
         end;
        end;
       end else begin
        while (not CharEOF) and ((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) do begin
         s:=s+ansichar(byte(CurrentChar));
         NextChar;
        end;
       end;
       if IsChar('.') then begin
        s:=s+ansichar(byte(CurrentChar));
        NextChar;
        if CharEOF or not (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or
                           (IsHexadecimal and
                            (((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or
                             ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))))) then begin
         JSONError;
        end;
        while (not CharEOF) and (((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) or
                                  (IsHexadecimal and
                                   (((CurrentChar>=ord('a')) and (CurrentChar<=ord('f'))) or
                                    ((CurrentChar>=ord('A')) and (CurrentChar<=ord('F')))))) do begin
         s:=s+ansichar(byte(CurrentChar));
         NextChar;
        end;
       end;
       if (not CharEOF) and ((CurrentChar=ord('e')) or (CurrentChar=ord('E'))) then begin
        s:=s+ansichar(byte(CurrentChar));
        NextChar;
        if (not CharEOF) and ((CurrentChar=ord('-')) or (CurrentChar=ord('+'))) then begin
         s:=s+ansichar(byte(CurrentChar));
         NextChar;
        end;
        if CharEOF or not ((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) then begin
         JSONError;
        end;
        while (not CharEOF) and ((CurrentChar>=ord('0')) and (CurrentChar<=ord('9'))) do begin
         s:=s+ansichar(byte(CurrentChar));
         NextChar;
        end;
       end;
      end else begin
       JSONError;
      end;
     end;
     if length(s)>0 then begin
      OK:=false;
      Value:=ConvertStringToDouble(s,rmNearest,@OK);
      if not OK then begin
       JSONError;
      end;
      result:=TPasJSONItemNumber.Create(Value);
     end;
    except
     FreeAndNil(result);
     raise;
    end;
   finally
    s:='';
   end;
  end;
  procedure ParseObjectProperty(DestinationObject:TPasJSONItemObject);
  var Key:TPasJSONUTF8String;
      Value:TPasJSONItem;
  begin
   result:=nil;
   try
    if (TPasJSONModeFlag.UnquotedKeys in aModeFlags) and
       (not CharEOF) and
       ((CurrentChar=UInt16(TPasJSONUTF16Char('_'))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('a'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('z')))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('A'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('Z')))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('0'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('9'))))) then begin
     Key:=TPasJSONUTF8String(AnsiChar(byte(CurrentChar)));
     NextChar;
     while ((CurrentChar=UInt16(TPasJSONUTF16Char('_'))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('a'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('z')))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('A'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('Z')))) or
        ((CurrentChar>=UInt16(TPasJSONUTF16Char('0'))) and (CurrentChar<=UInt16(TPasJSONUTF16Char('9'))))) do begin
      Key:=Key+TPasJSONUTF8String(AnsiChar(byte(CurrentChar)));
      NextChar;
     end;
     SkipWhite;
    end else begin
     Value:=ParseString;
     if assigned(Value) and (Value is TPasJSONItemString) then begin
      Key:=TPasJSONItemString(Value).Value;
      FreeAndNil(Value);
     end else begin
      FreeAndNil(Value);
      JSONError;
      Key:='';
     end;
    end;
    SkipWhite;
    if TPasJSONModeFlag.EqualsForColon in aModeFlags then begin
     ExpectChar('=');
    end else begin
     ExpectChar(':');
    end;
    SkipWhite;
    Value:=ParseValue(false);
    DestinationObject.Add(Key,Value);
   except
    FreeAndNil(result);
    raise;
   end;
  end;
  function ParseObject(const ImplicitRootObject:boolean):TPasJSONItem;
  begin
   result:=TPasJSONItemObject.Create;
   try
    if not ImplicitRootObject then begin
     ExpectChar('{');
    end;
    SkipWhite;
    while not (CharEOF or ((not ImplicitRootObject) and IsChar('}'))) do begin
     ParseObjectProperty(TPasJSONItemObject(result));
     SkipWhite;
     if IsChar(',') then begin
      NextChar;
      SkipWhite;
      if (not (CharEOF or ImplicitRootObject)) and IsChar('}') then begin
       JSONError;
      end;
     end else if not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
      break;
     end;
    end;
    if not ImplicitRootObject then begin
     ExpectChar('}');
    end;
   except
    FreeAndNil(result);
    raise;
   end;
  end;
  function ParseArray:TPasJSONItem;
  begin
   result:=TPasJSONItemArray.Create;
   try
    ExpectChar('[');
    SkipWhite;
    while not (CharEOF or IsChar(']')) do begin
     TPasJSONItemArray(result).Add(ParseValue(false));
     SkipWhite;
     if IsChar(',') then begin
      NextChar;
      SkipWhite;
      if (not CharEOF) and IsChar(']') then begin
       JSONError;
      end;
     end else if not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
      break;
     end;
    end;
    ExpectChar(']');
   except
    FreeAndNil(result);
    raise;
   end;
  end;
  procedure ExpectKeyword(const Keyword:TPasJSONUTF8String);
  var i:TPasJSONInt32;
  begin
   for i:=1 to length(Keyword) do begin
    ExpectChar(TPasJSONUTF16Char(Keyword[i]));
   end;
  end;
 begin
  result:=nil;
  try
   SkipWhite;
   if CharEOF then begin
    JSONError;
   end;
   if ImplicitRootObject then begin
    result:=ParseObject(true);
   end else begin
    case CurrentChar of
     ord('{'):begin
      result:=ParseObject(false);
     end;
     ord('['):begin
      result:=ParseArray;
     end;
     ord('"'):begin
      result:=ParseString;
     end;
     ord('-'),ord('0')..ord('9'):begin
      result:=ParseNumber;
     end;
     ord('t'):begin
      ExpectKeyword('true');
      result:=TPasJSONItemBoolean.Create(true);
     end;
     ord('f'):begin
      ExpectKeyword('false');
      result:=TPasJSONItemBoolean.Create(false);
     end;
     ord('n'):begin
      ExpectKeyword('null');
      result:=TPasJSONItemNull.Create;
     end;
     else begin
      JSONError;
     end;
    end;
   end;
  except
   FreeAndNil(result);
   raise;
  end;
 end;
begin
 result:=nil;
 try
  CharEOF:=false;
  if aEncoding=TPasJSONEncoding.AutomaticDetection then begin
   if (length(aSource)>=3) and ((byte(ansichar(aSource[1]))=$ef) and (byte(ansichar(aSource[2]))=$bb) and (byte(ansichar(aSource[3]))=$bf)) then begin
    Position:=4;
    Encoding:=TPasJSONEncoding.UTF8;
   end else if (length(aSource)>=4) and ((byte(ansichar(aSource[1]))=$ff) and (byte(ansichar(aSource[2]))=$fe) and (byte(ansichar(aSource[3]))=$00) and (byte(ansichar(aSource[4]))=$00)) then begin
    Position:=5;
    Encoding:=TPasJSONEncoding.UTF32LE;
   end else if (length(aSource)>=4) and ((byte(ansichar(aSource[1]))=$00) and (byte(ansichar(aSource[2]))=$00) and (byte(ansichar(aSource[3]))=$fe) and (byte(ansichar(aSource[4]))=$ff)) then begin
    Position:=5;
    Encoding:=TPasJSONEncoding.UTF32BE;
   end else if (length(aSource)>=2) and ((byte(ansichar(aSource[1]))=$ff) and (byte(ansichar(aSource[2]))=$fe)) then begin
    Position:=3;
    Encoding:=TPasJSONEncoding.UTF16LE;
   end else if (length(aSource)>=2) and ((byte(ansichar(aSource[1]))=$fe) and (byte(ansichar(aSource[2]))=$ff)) then begin
    Position:=3;
    Encoding:=TPasJSONEncoding.UTF16BE;
   end else begin
    Position:=1;
    Encoding:=TPasJSONEncoding.Latin1;
   end;
  end else begin
   Position:=1;
   Encoding:=aEncoding;
  end;
  NextChar;
  result:=ParseValue(TPasJSONModeFlag.ImplicitRootObject in aModeFlags);
  SkipWhite;
  if not CharEOF then begin
   JSONError;
  end;
 except
  FreeAndNil(result);
  raise;
 end;
end;

class function TPasJSON.Parse(const aStream:TStream;const aModeFlags:TPasJSONModeFlags=[TPasJSONModeFlag.Comments];const aEncoding:TPasJSONEncoding=TPasJSONEncoding.AutomaticDetection):TPasJSONItem;
var StringValue:TPasJSONRawByteString;
begin
 StringValue:='';
 try
  SetLength(StringValue,aStream.Size);
  if length(StringValue)>0 then begin
   if aStream.Seek(0,soBeginning)<>0 then begin
    raise EInOutError.Create('Stream seek error');
   end;
   aStream.ReadBuffer(StringValue[1],aStream.Size);
  end;
  result:=TPasJSON.Parse(StringValue,aModeFlags,aEncoding);
 finally
  StringValue:='';
 end;
end;

class function TPasJSON.Stringify(const aJSONItem:TPasJSONItem;const aFormatting:boolean=false;const aModeFlags:TPasJSONModeFlags=[];const aLevel:TPasJSONInt32=0):TPasJSONRawByteString;
 function IsIdentifier(const pKey:TPasJSONUTF8String):boolean;
 var Index:TPasJSONInt32;
 begin
  result:=length(pKey)>0;
  for Index:=1 to length(pKey) do begin
   case UInt16(TPasJSONUTF16Char(pKey[Index])) of
    UInt16(TPasJSONUTF16Char('_')),
    UInt16(TPasJSONUTF16Char('a'))..UInt16(TPasJSONUTF16Char('z')),
    UInt16(TPasJSONUTF16Char('A'))..UInt16(TPasJSONUTF16Char('Z')),
    UInt16(TPasJSONUTF16Char('0'))..UInt16(TPasJSONUTF16Char('9')):begin
    end;
    else begin
     result:=false;
     break;
    end;
   end;
  end;
 end;
{$undef TPasJSONStringifyRealRecursive}
{$if defined(TPasJSONStringifyRealRecursive)}
var Index,Count,Ident,LevelOffset:TPasJSONInt32;
    IntegerValue:Int64;
    Key:TPasJSONUTF8String;
begin
 if assigned(aJSONItem) then begin
  if aJSONItem is TPasJSONItemNull then begin
   result:='null';
  end else if aJSONItem is TPasJSONItemBoolean then begin
   if TPasJSONItemBoolean(aJSONItem).Value then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end else if aJSONItem is TPasJSONItemNumber then begin
   if IsInfinite(TPasJSONItemNumber(aJSONItem).Value) then begin
    if (TPasJSONUInt64(Pointer(@TPasJSONItemNumber(aJSONItem).Value)^) shr 63)<>0 then begin
     result:=TPasJSON.StringQuote('-Infinity');
    end else begin
     result:=TPasJSON.StringQuote('Infinity');
    end;
   end else if IsNaN(TPasJSONItemNumber(aJSONItem).Value) then begin
    if (TPasJSONUInt64(Pointer(@TPasJSONItemNumber(aJSONItem).Value)^) shr 63)<>0 then begin
     result:=TPasJSON.StringQuote('-NaN');
    end else begin
     result:=TPasJSON.StringQuote('NaN');
    end;
   end else begin
    IntegerValue:=trunc(TPasJSONItemNumber(aJSONItem).Value);
    if TPasJSONItemNumber(aJSONItem).Value=IntegerValue then begin
     result:=IntToStr(IntegerValue);
    end else begin
     result:=ConvertDoubleToString(TPasJSONItemNumber(aJSONItem).Value,omStandard,0);
    end;
   end;
  end else if aJSONItem is TPasJSONItemString then begin
   result:=TPasJSON.StringQuote(TPasJSONItemString(aJSONItem).Value);
  end else if aJSONItem is TPasJSONItemArray then begin
   result:='[';
   if aFormatting then begin
    result:=result+#13#10;
   end;
   Count:=TPasJSONItemArray(aJSONItem).Count;
   if TPasJSONModeFlag.ImplicitRootObject in aModeFlags then begin
    LevelOffset:=-1;
   end else begin
    LevelOffset:=0;
   end;
   for Index:=0 to Count-1 do begin
    if aFormatting then begin
     for Ident:=0 to aLevel+LevelOffset do begin
      result:=result+'  ';
     end;
    end;
    result:=result+TPasJSON.Stringify(TPasJSONItemArray(aJSONItem).Items[Index],aFormatting,aModeFlags,aLevel+1);
    if ((Index+1)<Count) and not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
     result:=result+',';
    end;
    if aFormatting then begin
     result:=result+#13#10;
    end;
   end;
   if aFormatting then begin
    for Ident:=1 to aLevel+LevelOffset do begin
     result:=result+'  ';
    end;
   end;
   result:=result+']';
  end else if aJSONItem is TPasJSONItemObject then begin
   if (not (TPasJSONModeFlag.ImplicitRootObject in aModeFlags)) or (aLevel<>0) then begin
    result:='{';
    if aFormatting then begin
     result:=result+#13#10;
    end;
   end else begin
    result:='';
   end;
   if TPasJSONModeFlag.ImplicitRootObject in aModeFlags then begin
    LevelOffset:=-1;
   end else begin
    LevelOffset:=0;
   end;
   Count:=TPasJSONItemObject(aJSONItem).Count;
   for Index:=0 to Count-1 do begin
    if aFormatting then begin
     for Ident:=0 to aLevel+LevelOffset do begin
      result:=result+'  ';
     end;
    end;
    Key:=TPasJSONItemObject(aJSONItem).Keys[Index];
    if (TPasJSONModeFlag.UnquotedKeys in aModeFlags) and IsIdentifier(Key) then begin
     result:=result+TPasJSONRawByteString(Key);
    end else begin
     result:=result+TPasJSON.StringQuote(Key);
    end;
    if TPasJSONModeFlag.EqualsForColon in aModeFlags then begin
     if aFormatting then begin
      result:=result+' ';
     end;
     result:=result+'=';
    end else begin
     result:=result+':';
    end;
    if aFormatting then begin
     result:=result+' ';
    end;
    result:=result+TPasJSON.Stringify(TPasJSONItemObject(aJSONItem).Values[Index],aFormatting,aModeFlags,aLevel+1);
    if ((Index+1)<Count) and not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
     result:=result+',';
    end;
    if aFormatting then begin
     result:=result+#13#10;
    end;
   end;
   if aFormatting then begin
    for Ident:=1 to aLevel+LevelOffset do begin
     result:=result+'  ';
    end;
   end;
   if (not (TPasJSONModeFlag.ImplicitRootObject in aModeFlags)) or (aLevel<>0) then begin
    result:=result+'}';
   end;
  end else begin
   result:='null';
  end;
 end else begin
  result:='null';
 end;
end;
{$else}
{$define UseOwnStringBuilder} // For better performance
type TStackItem=record
      JSONItem:TPasJSONItem;
      State:TPasJSONSizeInt;
      Index:TPasJSONSizeInt;
      Level:TPasJSONSizeInt;
     end;
     PStackItem=^TStackItem;
     TStackItems=array of TStackItem;
var StackItems:TStackItems;
    StackItemPointer:TPasJSONSizeInt;
{$ifdef UseOwnStringBuilder}
    OutputString:TPasJSONUTF8String;
    OutputStringLen:TPasJSONSizeInt;
{$endif}
{$ifdef UseOwnStringBuilder}
 procedure AddString(const aString:TPasJSONUTF8String);
 var StringLen,NewOutputStringLen:TPasJSONSizeInt;
 begin
  StringLen:=length(aString);
  if StringLen>0 then begin
   NewOutputStringLen:=OutputStringLen+StringLen;
   if length(OutputString)<NewOutputStringLen then begin
    SetLength(OutputString,NewOutputStringLen+((NewOutputStringLen+1) shr 1));
   end;
   Move(aString[1],OutputString[OutputStringLen+1],StringLen);
   OutputStringLen:=NewOutputStringLen;
  end; 
 end;
{$endif}
 procedure Push(const aJSONItem:TPasJSONItem;const aState,aIndex,aLevel:TPasJSONSizeInt);
 var StackItem:PStackItem;
 begin
  inc(StackItemPointer);
  if StackItemPointer>=length(StackItems) then begin
   SetLength(StackItems,StackItemPointer+(((StackItemPointer+1) shr 1)+1));
  end;
  StackItem:=@StackItems[StackItemPointer-1];
  StackItem^.JSONItem:=aJSONItem;
  StackItem^.State:=aState;
  StackItem^.Index:=aIndex;
  StackItem^.Level:=aLevel;
 end;
var StackItem:TStackItem;
    LevelOffset,Ident:TPasJSONSizeInt;
    IntegerValue:Int64;
    Key:TPasJSONUTF8String;
begin
 if assigned(aJSONItem) then begin
{$ifdef UseOwnStringBuilder}
  OutputString:='';
  OutputStringLen:=0;
{$else}
  result:='';
{$endif} 
  StackItems:=nil;
  try
   StackItemPointer:=0;
   Push(aJSONItem,0,0,aLevel);
   while StackItemPointer>0 do begin
    dec(StackItemPointer);
    StackItem:=StackItems[StackItemPointer];
    case StackItem.State of
     0:begin
      if assigned(StackItem.JSONItem) then begin
       if StackItem.JSONItem is TPasJSONItemNull then begin       
{$ifdef UseOwnStringBuilder}
        AddString('null');
{$else}
        result:=result+'null';
{$endif}
       end else if StackItem.JSONItem is TPasJSONItemBoolean then begin
        if TPasJSONItemBoolean(StackItem.JSONItem).Value then begin
{$ifdef UseOwnStringBuilder}
         AddString('true');
{$else}
         result:=result+'true';
{$endif}
        end else begin
{$ifdef UseOwnStringBuilder}
         AddString('false');
{$else}
         result:=result+'false';
{$endif}
        end;
       end else if StackItem.JSONItem is TPasJSONItemNumber then begin
        if IsInfinite(TPasJSONItemNumber(StackItem.JSONItem).Value) then begin
         if (TPasJSONUInt64(Pointer(@TPasJSONItemNumber(StackItem.JSONItem).Value)^) shr 63)<>0 then begin
{$ifdef UseOwnStringBuilder}
          AddString(TPasJSON.StringQuote('-Infinity'));
{$else}
          result:=result+TPasJSON.StringQuote('-Infinity');
{$endif}
         end else begin
{$ifdef UseOwnStringBuilder}
          AddString(TPasJSON.StringQuote('Infinity'));
{$else}
          result:=result+TPasJSON.StringQuote('Infinity');
{$endif}
         end;
        end else if IsNaN(TPasJSONItemNumber(StackItem.JSONItem).Value) then begin
         if (TPasJSONUInt64(Pointer(@TPasJSONItemNumber(StackItem.JSONItem).Value)^) shr 63)<>0 then begin
{$ifdef UseOwnStringBuilder}
          AddString(TPasJSON.StringQuote('-NaN')); 
{$else}
          result:=result+TPasJSON.StringQuote('-NaN');
{$endif}
         end else begin
{$ifdef UseOwnStringBuilder}
          AddString(TPasJSON.StringQuote('NaN'));      
{$else}
          result:=result+TPasJSON.StringQuote('NaN');
{$endif}
         end;
        end else begin
         IntegerValue:=trunc(TPasJSONItemNumber(StackItem.JSONItem).Value);
         if TPasJSONItemNumber(StackItem.JSONItem).Value=IntegerValue then begin
{$ifdef UseOwnStringBuilder}
          AddString(IntToStr(IntegerValue));
{$else}
          result:=result+IntToStr(IntegerValue);
{$endif}
         end else begin
{$ifdef UseOwnStringBuilder}
          AddString(ConvertDoubleToString(TPasJSONItemNumber(StackItem.JSONItem).Value,omStandard,0));     
{$else}
          result:=result+ConvertDoubleToString(TPasJSONItemNumber(StackItem.JSONItem).Value,omStandard,0);
{$endif}
         end;
        end;
       end else if StackItem.JSONItem is TPasJSONItemString then begin
{$ifdef UseOwnStringBuilder}
        AddString(TPasJSON.StringQuote(TPasJSONItemString(StackItem.JSONItem).Value));   
{$else}
        result:=result+TPasJSON.StringQuote(TPasJSONItemString(StackItem.JSONItem).Value);
{$endif}
       end else if StackItem.JSONItem is TPasJSONItemArray then begin
{$ifdef UseOwnStringBuilder}
        AddString('[');
        if aFormatting then begin
         AddString(#13#10);
        end;
{$else}
        result:=result+'[';
        if aFormatting then begin
         result:=result+#13#10;
        end;
{$endif}
        Push(StackItem.JSONItem,1,0,StackItem.Level);
        if TPasJSONModeFlag.ImplicitRootObject in aModeFlags then begin
         LevelOffset:=-1;
        end else begin
         LevelOffset:=0;
        end;
        Push(StackItem.JSONItem,2,0,StackItem.Level+LevelOffset);
       end else if StackItem.JSONItem is TPasJSONItemObject then begin
        if (not (TPasJSONModeFlag.ImplicitRootObject in aModeFlags)) or (aLevel<>0) then begin
{$ifdef UseOwnStringBuilder}
         AddString('{');
         if aFormatting then begin
          AddString(#13#10);
         end;
{$else}
         result:=result+'{';
         if aFormatting then begin
          result:=result+#13#10;
         end;
{$endif}
        end else begin
{$ifdef UseOwnStringBuilder}
         OutputString:='';
         OutputStringLen:=0;
{$else}
         result:='';
{$endif}
        end;
        Push(StackItem.JSONItem,4,0,StackItem.Level);
        if TPasJSONModeFlag.ImplicitRootObject in aModeFlags then begin
         LevelOffset:=-1;
        end else begin
         LevelOffset:=0;
        end;
        Push(StackItem.JSONItem,5,0,StackItem.Level+LevelOffset);
       end else begin
{$ifdef UseOwnStringBuilder}
        AddString('null');
{$else}
        result:=result+'null';
{$endif}
       end;
      end else begin
{$ifdef UseOwnStringBuilder}
       AddString('null');
{$else}
       result:=result+'null';
{$endif}
      end;
     end;
     1:begin
{$ifdef UseOwnStringBuilder}
      if aFormatting then begin
       for Ident:=0 to StackItem.Level do begin
        AddString('  ');
       end;
      end; 
      AddString(']');
{$else}    
      if aFormatting then begin
       for Ident:=1 to StackItem.Level do begin
        result:=result+'  ';
       end;
      end;
      result:=result+']';
{$endif}
     end;
     2:begin
      if StackItem.Index<TPasJSONItemArray(StackItem.JSONItem).Count then begin
{$ifdef UseOwnStringBuilder}
       if aFormatting then begin
        for Ident:=0 to StackItem.Level do begin
         AddString('  ');
        end;
       end; 
{$else}
       if aFormatting then begin
        for Ident:=0 to StackItem.Level do begin
         result:=result+'  ';
        end;
       end;
{$endif}
       Push(StackItem.JSONItem,3,StackItem.Index,StackItem.Level);
       Push(TPasJSONItemArray(StackItem.JSONItem).Items[StackItem.Index],0,0,StackItem.Level+1);
      end;
     end;
     3:begin
{$ifdef UseOwnStringBuilder}
      if ((StackItem.Index+1)<TPasJSONItemArray(StackItem.JSONItem).Count) and not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
       AddString(',');
      end;
      if aFormatting then begin
       AddString(#13#10);
      end;
      if aFormatting then begin
       for Ident:=1 to StackItem.Level do begin
        AddString('  ');
       end;
      end;
{$else}
      if ((StackItem.Index+1)<TPasJSONItemArray(StackItem.JSONItem).Count) and not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
       result:=result+',';
      end;
      if aFormatting then begin
        result:=result+#13#10;
      end;
      if aFormatting then begin
       for Ident:=1 to StackItem.Level do begin
        result:=result+'  ';
       end;
      end;
{$endif}
      if (StackItem.Index+1)<TPasJSONItemArray(StackItem.JSONItem).Count then begin
       Push(StackItem.JSONItem,2,StackItem.Index+1,StackItem.Level);
      end;
     end;
     4:begin
{$ifdef UseOwnStringBuilder}
      if aFormatting then begin
       for Ident:=0 to StackItem.Level do begin
        AddString('  ');
       end;
      end;
      if (not (TPasJSONModeFlag.ImplicitRootObject in aModeFlags)) or (StackItem.Level<>0) then begin
       AddString('}');
      end;
{$else}
      if aFormatting then begin
       for Ident:=1 to StackItem.Level do begin
        result:=result+'  ';
       end;
      end;
      if (not (TPasJSONModeFlag.ImplicitRootObject in aModeFlags)) or (StackItem.Level<>0) then begin
       result:=result+'}';
      end;
{$endif}
     end;
     5:begin
      if StackItem.Index<TPasJSONItemObject(StackItem.JSONItem).Count then begin
       if aFormatting then begin
        for Ident:=0 to StackItem.Level do begin
{$ifdef UseOwnStringBuilder}
         AddString('  ');
{$else}       
         result:=result+'  ';
{$endif}
        end;
       end;
       Key:=TPasJSONItemObject(StackItem.JSONItem).Keys[StackItem.Index];
       if (TPasJSONModeFlag.UnquotedKeys in aModeFlags) and IsIdentifier(Key) then begin
{$ifdef UseOwnStringBuilder}
        AddString(TPasJSONRawByteString(Key));
{$else}
        result:=result+TPasJSONRawByteString(Key);
{$endif}
       end else begin
{$ifdef UseOwnStringBuilder}
        AddString(TPasJSON.StringQuote(Key));
{$else}
        result:=result+TPasJSON.StringQuote(Key);
{$endif}
       end;
       if TPasJSONModeFlag.EqualsForColon in aModeFlags then begin
        if aFormatting then begin
{$ifdef UseOwnStringBuilder}
         AddString(' ');
{$else}       
         result:=result+' ';
{$endif}
        end;
{$ifdef UseOwnStringBuilder}
        AddString('=');
{$else}        
        result:=result+'=';
{$endif}
       end else begin
{$ifdef UseOwnStringBuilder}
        AddString(':');
{$else}
        result:=result+':';
{$endif}
       end;
       if aFormatting then begin
{$ifdef UseOwnStringBuilder}
        AddString(' ');
{$else}
        result:=result+' ';
{$endif}
       end;
       Push(StackItem.JSONItem,6,StackItem.Index,StackItem.Level);
       Push(TPasJSONItemObject(StackItem.JSONItem).Values[StackItem.Index],0,0,StackItem.Level+1);
      end;
     end;
     6:begin
      if ((StackItem.Index+1)<TPasJSONItemObject(StackItem.JSONItem).Count) and not (TPasJSONModeFlag.OptionalCommas in aModeFlags) then begin
{$ifdef UseOwnStringBuilder}
       AddString(',');
{$else}
       result:=result+',';
{$endif}
      end;
      if aFormatting then begin
{$ifdef UseOwnStringBuilder}
       AddString(#13#10);     
{$else}
       result:=result+#13#10;
{$endif}
      end;
      if (StackItem.Index+1)<TPasJSONItemObject(StackItem.JSONItem).Count then begin
       Push(StackItem.JSONItem,5,StackItem.Index+1,StackItem.Level);
      end;
     end;
    end;
   end;
  finally
   StackItems:=nil;
  end;
{$ifdef UseOwnStringBuilder}
  if OutputStringLen>0 then begin
   SetLength(OutputString,OutputStringLen);
   result:=OutputString;
  end else begin
   result:='null';
  end;
{$endif}
 end else begin
  result:='null';
 end;
end;
{$ifend}

class procedure TPasJSON.StringifyToStream(const aStream:TStream;const aJSONItem:TPasJSONItem;const aFormatting:boolean=false;const aModeFlags:TPasJSONModeFlags=[];const aLevel:TPasJSONInt32=0);
var StringValue:TPasJSONRawByteString;
begin
 StringValue:=Stringify(aJSONItem,aFormatting,aModeFlags,aLevel);
 try
  if length(StringValue)>0 then begin
   aStream.WriteBuffer(StringValue[1],length(StringValue));
  end;
 finally
  StringValue:='';
 end;
end;

class function TPasJSON.GetNumber(const aItem:TPasJSONItem;const aDefault:TPasJSONDouble=0.0):TPasJSONDouble;
var OK:TPasDblStrUtilsBoolean;
begin
 if assigned(aItem) and (aItem is TPasJSONItemNumber) then begin
  result:=TPasJSONItemNumber(aItem).Value;
 end else if assigned(aItem) and (aItem is TPasJSONItemString) then begin
  OK:=false;
  result:=ConvertStringToDouble(TPasJSONItemString(aItem).Value,rmNearest,@OK,-1);
  if not OK then begin
   result:=aDefault;
  end;
 end else if assigned(aItem) and (aItem is TPasJSONItemBoolean) then begin
  result:=ord(TPasJSONItemBoolean(aItem).Value) and 1;
 end else begin
  result:=aDefault;
 end;
end;

class function TPasJSON.GetInt64(const aItem:TPasJSONItem;const aDefault:TPasJSONInt64=0):TPasJSONInt64;
begin
 if assigned(aItem) and (aItem is TPasJSONItemNumber) then begin
  result:=Trunc(TPasJSONItemNumber(aItem).Value);
 end else if assigned(aItem) and (aItem is TPasJSONItemString) then begin
  result:=StrToInt64Def(TPasJSONItemString(aItem).Value,aDefault);
 end else if assigned(aItem) and (aItem is TPasJSONItemBoolean) then begin
  result:=ord(TPasJSONItemBoolean(aItem).Value) and 1;
 end else begin
  result:=aDefault;
 end;
end;

class function TPasJSON.GetUInt64(const aItem:TPasJSONItem;const aDefault:TPasJSONUInt64=0):TPasJSONUInt64;
begin
 if assigned(aItem) and (aItem is TPasJSONItemNumber) then begin
  result:=Trunc(TPasJSONItemNumber(aItem).Value);
 end else if assigned(aItem) and (aItem is TPasJSONItemString) then begin
  result:=StrToUInt64Def(TPasJSONItemString(aItem).Value,aDefault);
 end else if assigned(aItem) and (aItem is TPasJSONItemBoolean) then begin
  result:=ord(TPasJSONItemBoolean(aItem).Value) and 1;
 end else begin
  result:=aDefault;
 end;
end;

class function TPasJSON.GetString(const aItem:TPasJSONItem;const aDefault:TPasJSONUTF8String=''):TPasJSONUTF8String;
begin
 if assigned(aItem) and (aItem is TPasJSONItemString) then begin
  result:=TPasJSONItemString(aItem).Value;
 end else if assigned(aItem) and (aItem is TPasJSONItemNumber) then begin
  result:=ConvertDoubleToString(TPasJSONItemNumber(aItem).Value,omStandard);
 end else if assigned(aItem) and (aItem is TPasJSONItemBoolean) then begin
  if TPasJSONItemBoolean(aItem).Value then begin
   result:='true';
  end else begin
   result:='false';
  end;
 end else begin
  result:=aDefault;
 end;
end;

class function TPasJSON.GetBoolean(const aItem:TPasJSONItem;const aDefault:boolean=false):boolean;
begin
 if assigned(aItem) and (aItem is TPasJSONItemBoolean) then begin
  result:=TPasJSONItemBoolean(aItem).Value;
 end else if assigned(aItem) and (aItem is TPasJSONItemNumber) then begin
  result:=TPasJSONItemNumber(aItem).Value<>0.0;
 end else if assigned(aItem) and (aItem is TPasJSONItemString) then begin
  result:=(LowerCase(TPasJSONItemString(aItem).Value)<>'false') and
          (TPasJSONItemString(aItem).Value<>'0');
 end else begin
  result:=aDefault;
 end;
end;

class function TPasJSON.LoadBinaryFromStream(const aStream:TStream):TPasJSONItem;
 function LoadJSONItem:TPasJSONItem;
 var ItemType,BooleanValue:TPasJSONUInt8;
     Count,Counter,Len:TPasJSONInt32;
     TempString:TPasJSONUTF8String;
     DoubleValue:TPasJSONDouble;
 begin
  result:=nil;
  if aStream.Read(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
   raise EInOutError.Create('Stream read error');
  end;
  case ItemType of
   0:begin
    result:=TPasJSONItemNull.Create;
   end;
   1:begin
    result:=TPasJSONItemArray.Create;
    if aStream.Read(Count,SizeOf(TPasJSONUInt32))<>SizeOf(TPasJSONInt32) then begin
     raise EInOutError.Create('Stream read error');
    end;
    for Counter:=0 to Count-1 do begin
     TPasJSONItemArray(result).Add(LoadJSONItem);
    end;
   end;
   2:begin
    TempString:='';
    try
     result:=TPasJSONItemObject.Create;
     if aStream.Read(Count,SizeOf(TPasJSONUInt32))<>SizeOf(TPasJSONInt32) then begin
      raise EInOutError.Create('Stream read error');
     end;
     for Counter:=0 to Count-1 do begin
      if aStream.Read(Len,SizeOf(TPasJSONUInt32))<>SizeOf(TPasJSONInt32) then begin
       raise EInOutError.Create('Stream read error');
      end;
      SetLength(TempString,Len);
      if Len>0 then begin
       if TPasJSONInt64(aStream.Read(TempString[1],Len*SizeOf(AnsiChar)))<>TPasJSONInt64(Len*SizeOf(AnsiChar)) then begin
        raise EInOutError.Create('Stream read error');
       end;
      end;
      TPasJSONItemObject(result).Add(TempString,LoadJSONItem);
     end;
    finally
     TempString:='';
    end;
   end;
   3:begin
    if aStream.Read(BooleanValue,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream read error');
    end;
    result:=TPasJSONItemBoolean.Create(BooleanValue<>0);
   end;
   4:begin
    if aStream.Read(DoubleValue,SizeOf(TPasJSONDouble))<>SizeOf(TPasJSONDouble) then begin
     raise EInOutError.Create('Stream read error');
    end;
    result:=TPasJSONItemNumber.Create(DoubleValue);
   end;
   5:begin
    TempString:='';
    try
     if aStream.Read(Len,SizeOf(TPasJSONInt32))<>SizeOf(TPasJSONInt32) then begin
      raise EInOutError.Create('Stream read error');
     end;
     SetLength(TempString,Len);
     if Len>0 then begin
      if TPasJSONInt64(aStream.Read(TempString[1],Len*SizeOf(AnsiChar)))<>TPasJSONInt64(Len*SizeOf(AnsiChar)) then begin
       raise EInOutError.Create('Stream read error');
      end;
     end;
     result:=TPasJSONItemString.Create(TempString);
    finally
     TempString:='';
    end;
   end;
   else begin
    raise EInOutError.Create('Stream read error');
   end;
  end;
 end;
begin
 if assigned(aStream) and (aStream.Position<aStream.Size) then begin
  result:=LoadJSONItem;
 end else begin
  result:=nil;
 end;
end;

class procedure TPasJSON.SaveBinaryToStream(const aStream:TStream;const aJSONItem:TPasJSONItem);
 procedure SaveJSONItem(const pCurrentJSONItem:TPasJSONItem);
 var ItemType,BooleanValue:TPasJSONUInt8;
     Count,Counter,Len:TPasJSONInt32;
     TempString:TPasJSONUTF8String;
     DoubleValue:TPasJSONDouble;
 begin
  if assigned(pCurrentJSONItem) then begin
   if pCurrentJSONItem is TPasJSONItemNull then begin
    ItemType:=0;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
   end else if pCurrentJSONItem is TPasJSONItemArray then begin
    ItemType:=1;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    Count:=TPasJSONItemArray(pCurrentJSONItem).Count;
    if aStream.Write(Count,SizeOf(TPasJSONInt32))<>SizeOf(TPasJSONInt32) then begin
     raise EInOutError.Create('Stream write error');
    end;
    for Counter:=0 to Count-1 do begin
     SaveJSONItem(TPasJSONItemArray(pCurrentJSONItem).Items[Counter]);
    end;
   end else if pCurrentJSONItem is TPasJSONItemObject then begin
    ItemType:=2;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    Count:=TPasJSONItemObject(pCurrentJSONItem).Count;
    if aStream.Write(Count,SizeOf(TPasJSONInt32))<>SizeOf(TPasJSONInt32) then begin
     raise EInOutError.Create('Stream write error');
    end;
    try
     for Counter:=0 to Count-1 do begin
      TempString:=TPasJSONItemObject(pCurrentJSONItem).Keys[Counter];
      Len:=length(TempString);
      if aStream.Write(Len,SizeOf(TPasJSONInt32))<>SizeOf(TPasJSONInt32) then begin
       raise EInOutError.Create('Stream write error');
      end;
      if Len>0 then begin
       if TPasJSONInt64(aStream.Write(TempString[1],Len*SizeOf(AnsiChar)))<>TPasJSONInt64(Len*SizeOf(AnsiChar)) then begin
        raise EInOutError.Create('Stream write error');
       end;
      end;
      SaveJSONItem(TPasJSONItemObject(pCurrentJSONItem).Values[Counter]);
     end;
    finally
     TempString:='';
    end;
   end else if pCurrentJSONItem is TPasJSONItemBoolean then begin
    ItemType:=3;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    if TPasJSONItemBoolean(pCurrentJSONItem).fValue then begin
     BooleanValue:=$ff;
    end else begin
     BooleanValue:=$00;
    end;
    if aStream.Write(BooleanValue,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
   end else if pCurrentJSONItem is TPasJSONItemNumber then begin
    ItemType:=4;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    DoubleValue:=TPasJSONItemNumber(pCurrentJSONItem).fValue;
    if aStream.Write(DoubleValue,SizeOf(TPasJSONDouble))<>SizeOf(TPasJSONDouble) then begin
     raise EInOutError.Create('Stream write error');
    end;
   end else if pCurrentJSONItem is TPasJSONItemString then begin
    ItemType:=5;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    TempString:=TPasJSONItemString(pCurrentJSONItem).fValue;
    Len:=length(TempString);
    if aStream.Write(Len,SizeOf(TPasJSONInt32))<>SizeOf(TPasJSONInt32) then begin
     raise EInOutError.Create('Stream write error');
    end;
    if Len>0 then begin
     if TPasJSONInt64(aStream.Write(TempString[1],Len*SizeOf(AnsiChar)))<>TPasJSONInt64(Len*SizeOf(AnsiChar)) then begin
      raise EInOutError.Create('Stream write error');
     end;
    end;
   end else begin
    ItemType:=0;
    if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
   end;
  end else begin
   ItemType:=0;
   if aStream.Write(ItemType,SizeOf(TPasJSONUInt8))<>SizeOf(TPasJSONUInt8) then begin
    raise EInOutError.Create('Stream write error');
   end;
  end;
 end;
begin
 if assigned(aJSONItem) and assigned(aStream) then begin
  SaveJSONItem(aJSONItem);
 end;
end;

initialization
end.

