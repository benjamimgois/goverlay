(******************************************************************************
 *                                    PasLLM                                  *
 ******************************************************************************
 *                        Version 2025-10-11-13-19-0000                       *
 ******************************************************************************
 *                                   License                                  *
 *============================================================================*
 *                                                                            *
 * It is dual-licensed under the terms of the AGPL 3.0 license and            *
 * a commercial license for proprietary use. See the license.txt file in the  *
 * project root for details.                                                  *
 *                                                                            *
 ******************************************************************************
 *                               AGPL 3.0 license                             *
 *============================================================================*
 *                                                                            *
 * PasLLM - A LLM interference engine                                         *
 * Copyright (C) 2025-2025, Benjamin Rosseaux (benjamin@rosseaux.com)         *
 *                                                                            *
 *  This program is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU Affero General Public License as published  *
 *  by the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                       *
 *                                                                            *
 *  This program is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 *  GNU Affero General Public License for more details.                       *
 *                                                                            *
 *  You should have received a copy of the GNU Affero General Public License  *
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.    *
 *                                                                            *
 ******************************************************************************
 *                              Commercial license                            *
 *============================================================================*
 *                                                                            *
 * Contact the author (benjamin@rosseaux.com) for details, as it is custom    *
 * for every use case.                                                        *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the same *
 *    license(s).                                                             *
 * 2. The license headers goes at the top of each source file, with           *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/PasLLM                                       *
 * 4. Write code, which is compatible with Delphi >=11.2 and FreePascal       *
 *    >= 3.3.1                                                                *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 * 10. Make sure the code runs on platforms with weak and strong memory       *
 *     models without any issues.                                             *
 *                                                                            *
 ******************************************************************************)
unit PasLLM;
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
 {$if defined(cpux86_64) or defined(cpux64)}
  {$define cpuamd64}
 {$ifend}
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

{$undef LoadModelIntoMemory}

{$define UseMCP}

interface

uses {$ifdef Unix}
      BaseUnix,
      Unix,
      UnixType,
      UnixUtil,
     {$else}
      Windows,
     {$endif}
     SysUtils,
     Classes,
     SyncObjs,
     Generics.Collections,
     Math,
     PasMP,
     PasJSON,
{$ifdef UseMCP}
     httpsend,
     ssl_openssl3,
{$endif}
     Pinja,
     PinjaChatTemplate;

const fmCreateTemporary=4;

{$ifndef fpc}
      feInvalidHandle=-1;
{$endif}

      DefaultViewSize=0; // 0 = whole file, otherwise the size of the view in bytes

type PPPasLLMInt8=^PPasLLMInt8;
     PPasLLMInt8=^TPasLLMInt8;
     TPasLLMInt8={$ifdef fpc}Int8{$else}shortint{$endif};

     PPPasLLMInt8Array=^PPasLLMInt8Array;
     PPasLLMInt8Array=^TPasLLMInt8Array;
     TPasLLMInt8Array=array[0..65535] of TPasLLMInt8;

     PPPasLLMUInt8=^PPasLLMUInt8;
     PPasLLMUInt8=^TPasLLMUInt8;
     TPasLLMUInt8={$ifdef fpc}UInt8{$else}byte{$endif};

     PPPasLLMUInt8Array=^PPasLLMUInt8Array;
     PPasLLMUInt8Array=^TPasLLMUInt8Array;
     TPasLLMUInt8Array=array[0..65535] of TPasLLMUInt8;

     TPasLLMUInt8DynamicArray=array of TPasLLMUInt8;

     PPPasLLMInt16=^PPasLLMInt16;
     PPasLLMInt16=^TPasLLMInt16;
     TPasLLMInt16={$ifdef fpc}Int16{$else}smallint{$endif};

     PPPasLLMUInt16=^PPasLLMUInt16;
     PPasLLMUInt16=^TPasLLMUInt16;
     TPasLLMUInt16={$ifdef fpc}UInt16{$else}word{$endif};

     PPPasLLMUInt16Array=^PPasLLMUInt16Array;
     PPasLLMUInt16Array=^TPasLLMUInt16Array;
     TPasLLMUInt16Array=array[0..65535] of TPasLLMUInt16;

     PPPasLLMInt32=^PPasLLMInt32;
     PPasLLMInt32=^TPasLLMInt32;
     TPasLLMInt32={$ifdef fpc}Int32{$else}longint{$endif};

     TPasLLMInt32Array=array[0..65535] of TPasLLMInt32;
     PPasLLMInt32Array=^TPasLLMInt32Array;
     PPPasLLMInt32Array=^PPasLLMInt32Array;

     TPasLLMInt32DynamicArray=array of TPasLLMInt32;

     PPPasLLMUInt32=^PPasLLMUInt32;
     PPasLLMUInt32=^TPasLLMUInt32;
     TPasLLMUInt32={$ifdef fpc}UInt32{$else}longword{$endif};

     PPPasLLMUInt32Array=^PPasLLMUInt32Array;
     PPasLLMUInt32Array=^TPasLLMUInt32Array;
     TPasLLMUInt32Array=array[0..65535] of TPasLLMUInt32;

     TPasLLMUInt32DynamicArray=array of TPasLLMUInt32;

     PPPasLLMInt64=^PPasLLMInt64;
     PPasLLMInt64=^TPasLLMInt64;
     TPasLLMInt64=Int64;

     PPPasLLMUInt64=^PPasLLMUInt64;
     PPasLLMUInt64=^TPasLLMUInt64;
     TPasLLMUInt64=UInt64;

     PPPasLLMUInt64Array=^PPasLLMUInt64Array;
     PPasLLMUInt64Array=^TPasLLMUInt64Array;
     TPasLLMUInt64Array=array[0..65535] of TPasLLMUInt64;

     TPasLLMUInt64DynamicArray=array of TPasLLMUInt64;

     PPPasLLMChar=^PAnsiChar;
     PPasLLMChar=PAnsiChar;
     TPasLLMChar=AnsiChar;

     PPPasLLMRawByteChar=^PAnsiChar;
     PPasLLMRawByteChar=PAnsiChar;
     TPasLLMRawByteChar=AnsiChar;

     PPPasLLMUTF16Char=^PWideChar;
     PPasLLMUTF16Char=PWideChar;
     TPasLLMUTF16Char=WideChar;

     PPPasLLMPointer=^PPasLLMPointer;
     PPasLLMPointer=^TPasLLMPointer;
     TPasLLMPointer=Pointer;

     PPPasLLMPointers=^PPasLLMPointers;
     PPasLLMPointers=^TPasLLMPointers;
     TPasLLMPointers=array[0..65535] of TPasLLMPointer;

     PPPasLLMVoid=^PPasLLMVoid;
     PPasLLMVoid=TPasLLMPointer;

     PPPasLLMFloat=^PPasLLMFloat;
     PPasLLMFloat=^TPasLLMFloat;
     TPasLLMFloat=Single;

     PPPasLLMFloatArray=^PPasLLMFloatArray;
     PPasLLMFloatArray=^TPasLLMFloatArray;
     TPasLLMFloatArray=array[0..65535] of TPasLLMFloat;

     TPasLLMFloatDynamicArray=array of TPasLLMFloat;

     TPasLLMFloatDynamicArrayDynamicArray=array of TPasLLMFloatDynamicArray;

     TPPasLLMFloatArrayDynamicArray=array of PPasLLMFloatArray;

     TPasLLMFloats=array of TPasLLMFloat;

     PPPasLLMDouble=^PPasLLMDouble;
     PPasLLMDouble=^TPasLLMDouble;
     TPasLLMDouble=Double;

     PPPasLLMPtrUInt=^PPasLLMPtrUInt;
     PPPasLLMPtrInt=^PPasLLMPtrInt;
     PPasLLMPtrUInt=^TPasLLMPtrUInt;
     PPasLLMPtrInt=^TPasLLMPtrInt;
{$ifdef fpc}
     TPasLLMPtrUInt=PtrUInt;
     TPasLLMPtrInt=PtrInt;
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
     TPasLLMPtrUInt=NativeUInt;
     TPasLLMPtrInt=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
{$ifdef cpu64}
     TPasLLMPtrUInt=uint64;
     TPasLLMPtrInt=int64;
{$else}
     TPasLLMPtrUInt=longword;
     TPasLLMPtrInt=longint;
{$endif}
{$endif}

     PPPasLLMSizeUInt=^PPasLLMSizeUInt;
     PPasLLMSizeUInt=^TPasLLMSizeUInt;
     TPasLLMSizeUInt=TPasLLMPtrUInt;

     PPPasLLMSizeInt=^PPasLLMSizeInt;
     PPasLLMSizeInt=^TPasLLMSizeInt;
     TPasLLMSizeInt=TPasLLMPtrInt;

     PPPasLLMNativeUInt=^PPasLLMNativeUInt;
     PPasLLMNativeUInt=^TPasLLMNativeUInt;
     TPasLLMNativeUInt=TPasLLMPtrUInt;

     PPPasLLMNativeInt=^PPasLLMNativeInt;
     PPasLLMNativeInt=^TPasLLMNativeInt;
     TPasLLMNativeInt=TPasLLMPtrInt;

     PPPasLLMSize=^PPasLLMSizeUInt;
     PPasLLMSize=^TPasLLMSizeUInt;
     TPasLLMSize=TPasLLMPtrUInt;

     PPPasLLMPtrDiff=^PPasLLMPtrDiff;
     PPasLLMPtrDiff=^TPasLLMPtrDiff;
     TPasLLMPtrDiff=TPasLLMPtrInt;

     PPPasLLMRawByteString=^PPasLLMRawByteString;
     PPasLLMRawByteString=^TPasLLMRawByteString;
     TPasLLMRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     PPPasLLMUTF8String=^PPasLLMUTF8String;
     PPasLLMUTF8String=^TPasLLMUTF8String;
     TPasLLMUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     TPasLLMUTF8StringDynamicArray=array of TPasLLMUTF8String;

     PPPasLLMUTF16String=^PPasLLMUTF16String;
     PPasLLMUTF16String=^TPasLLMUTF16String;
     TPasLLMUTF16String={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

     EPasLLMFileMappedStream=class(Exception);

     TPasLLMTypedSort<T>=class
      private
       type PStackItem=^TStackItem;
            TStackItem=record
             Left,Right,Depth:TPasLLMInt32;
            end;
      public
       type TPasLLMTypedSortCompareFunction=function(const a,b:T):TPasLLMInt32;
      public
       class procedure IntroSort(const aItems:Pointer;const aLeft,aRight:TPasLLMInt32); overload;
       class procedure IntroSort(const aItems:Pointer;const aLeft,aRight:TPasLLMInt32;const aCompareFunc:TPasLLMTypedSortCompareFunction); overload;
     end;

     { TPasLLMPCG32 }

     TPasLLMPCG32=record
      public
       const DefaultState=TPasLLMUInt64($853c49e6748fea9b);
             DefaultStream=TPasLLMUInt64($da3e39cb94b95bdb);
             Mult=TPasLLMUInt64($5851f42d4c957f2d);
      private
       fState:TPasLLMUInt64;
       fIncrement:TPasLLMUInt64;
      public
       procedure Init(const aSeed:TPasLLMUInt64=0);
       function Get32:TPasLLMUInt32; {$ifdef caninline}inline;{$endif}
       function Get64:TPasLLMUInt64; {$ifdef caninline}inline;{$endif}
       function GetBiasedBounded32Bit(const aRange:TPasLLMUInt32):TPasLLMUInt32; {$ifdef caninline}inline;{$endif}
       function GetUnbiasedBounded32Bit(const aRange:TPasLLMUInt32):TPasLLMUInt32;
       function GetFloat:TPasLLMFloat; // -1.0 .. 1.0
       function GetFloatAbs:TPasLLMFloat; // 0.0 .. 1.0
       function GetDouble:TPasLLMDouble; // -1.0 .. 1.0
       function GetDoubleAbs:TPasLLMDouble; // 0.0 .. 1.0
     end;

     { TPasLLMFileMappedStream }

     TPasLLMFileMappedStream=class(TStream)
      private
       fFileHandle:{$ifdef Unix}TPasLLMInt32{$else}hFile{$endif};
{$ifndef Unix}
       fMapHandle:{$ifdef Unix}Pointer{$else}THandle{$endif};
{$endif}
       fAllocationGranularity:TPasLLMInt64;
       fMemory:Pointer;
       fReadOnly:Boolean;
       fCurrentViewOffset:TPasLLMInt64;
       fCurrentViewSize:TPasLLMInt64;
       fViewSize:TPasLLMInt64;
       fViewMask:TPasLLMInt64;
       fPosition:TPasLLMInt64;
       fSize:TPasLLMInt64;
       fFileName:String;
{$ifdef Unix}
       fTemporary:Boolean;
{$endif}
       procedure CreateMapView;
       procedure UpdateMapView;
       procedure CloseMapView;
      protected
       procedure SetSize(NewSize:TPasLLMInt32); overload; override;
       procedure SetSize(const NewSize:TPasLLMInt64); overload; override;
      public
       constructor Create(const FileName:String;Mode:Word);
       destructor Destroy; override;
       procedure Clear;
       procedure Flush;
       function Read(var Buffer;Count:TPasLLMInt32):TPasLLMInt32; override;
       function Write(const Buffer;Count:TPasLLMInt32):TPasLLMInt32; override;
       function Seek(const Offset:TPasLLMInt64;Origin:TSeekOrigin):TPasLLMInt64; override;
       property Memory:Pointer read fMemory;
       property MemoryViewOffset:TPasLLMInt64 read fCurrentViewOffset;
       property MemoryViewSize:TPasLLMInt64 read fCurrentViewSize;
       property ReadOnly:Boolean read fReadOnly;
     end;

     { TPasLLMRingBuffer } 
     TPasLLMRingBuffer<T>=class
      public
       type TArrayOfT=array of T;
      private
       fBuffer:TArrayOfT; // The ring buffer
       fCapacity:TPasLLMSizeInt; // Capacity of the ring buffer
       fHead:TPasLLMSizeInt; // Head index
       fTail:TPasLLMSizeInt; // Tail index
       fCount:TPasLLMSizeInt; // Number of elements in the ring buffer
      public
       constructor Create(const aCapacity:TPasLLMSizeInt); // Create a ring buffer with the specified size capacity
       destructor Destroy; override;
       procedure Clear; // Clear the ring buffer
       function IsEmpty:Boolean; // Check if the ring buffer is empty
       function IsFull:Boolean; // Check if the ring buffer is full
       procedure Push(const aItem:T); // Push an item into the ring buffer
       function Pop:T; // Pop an item from the ring buffer
       function Peek:T; // Peek the next item in the ring buffer
       function PeekAt(const aIndex:TPasLLMSizeInt):T; // Peek an item at the specified index in the ring buffer
      public
       property Capacity:TPasLLMSizeInt read fCapacity; // Capacity of the ring buffer
       property Count:TPasLLMSizeInt read fCount; // Number of elements in the ring buffer
       property Head:TPasLLMSizeInt read fHead; // Head index
       property Tail:TPasLLMSizeInt read fTail; // Tail index
     end;

     TPasLLMRingBufferInt32=TPasLLMRingBuffer<TPasLLMInt32>;

     EPasLLM=class(Exception);

     EPasLLMInvalidCheckpoint=class(EPasLLM);

     EPasLLMInvalidModel=class(EPasLLM);

     { TPasLLMTokenList }

     TPasLLMTokenList=class
      private
       fTokens:TPasLLMInt32DynamicArray;
       fCount:TPasLLMInt32;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Add(const aToken:TPasLLMInt32);
       procedure Append(const aTokens:array of TPasLLMInt32;const aCount:TPasLLMInt32=-1);
       procedure Delete(const aIndex:TPasLLMInt32);
       function Get(const aIndex:TPasLLMInt32):TPasLLMInt32;
       property Tokens:TPasLLMInt32DynamicArray read fTokens;
       property Count:TPasLLMInt32 read fCount;
     end;

     TPasLLM=class;

     TPasLLMJobManagerWorkerThread=class;

     TPasLLMJobManager=class;

     TPasLLMRunState=class;

     TPasLLMModel=class;

     TPasLLMModelInferenceInstance=class;

     TPasLLMTokenizer=class;

     TPasLLMSampler=class;

     TPasLLMBaseDataType=
      (
       F32,
       F16,
       BF16,
       F8_E5M2,
       F8_E4M3,
       I64,
       I32,
       I16,
       I8,
       U8
      );

     TPasLLMTensorDataType=
      (
       Unknown,
       I8,
       U8,
       Q3F8,
       Q6F16,
       Q7F8,
       Q40,
       Q40NL,
       Q41NL,
       Q42NL,
       Q43NL,
       Q80,
       F8_E4M3,
       F8_E5M2,
       BF16,
       F16,
       F32
      );

     TPasLLMModelTemplate=
      (
       LLAMA,
       LLAMA3,
       CHATML,
       GEMMA,
       GEMMA2,
       COHERE,
       PHI3,
       MINICPM,
       K2
      );

     { TPasLLMDataTypeData }
     TPasLLMDataTypeData=record
      Name:TPasLLMUTF8String; // Name of the data type
      Size:TPasLLMSizeInt; // Size in bytes of the data type
      Bits:TPasLLMSizeInt; // Number of bits of the data type
      GroupSize:TPasLLMSizeInt; // Number of bits of the data type
      GroupBytes:TPasLLMSizeInt; // Number of bits of the data type
     end;
     PPasLLMDataTypeData=^TPasLLMDataTypeData;

     TPasLLMNormalizationType=
      (
       RMSNorm,
       LayerNorm,
       LayerNormPar
      );

     TPasLLMActivationType=
      (
       SILU,
       GELU,
       XIELU,
       RELU,
       RELU2,
       SWISH,
       SoftPlus,
       MISH,
       LINEAR           
      );

     TPasLLMPositionalEncoding=
      (
       NoPE,
       RoPE
      );

     TPasLLMPositionalEncodings=array of TPasLLMPositionalEncoding;

     // This RapidHash implementation is endian-dependent, so the results are not interchangeable between
     // different endian architectures. So be careful when using this hash function in a cross-platform / 
     // cross-endian-architecture context. The hash function is designed to be fast and efficient on little-endian
     // architectures, such as ARM, AArch64, RISC-V, x86 and x86-64. It is not optimized for older big-endian 
     // architectures, such as PowerPC or SPARC. These big-endian architectures are almost dead in the modern world
     // anyway, so this is not a big problem. Indeed ARM and AArch64 can be either little-endian or big-endian, but
     // the vast majority of modern newer ARM and AArch64 implementations and operating systems are little-endian. 
     // And RISC-V is also practically always little-endian. So this implementation is optimized for little-endian 
     // architectures.

     // Equivalent to the C implementation of RapidHash with the following defines:
     // #define RAPIDHASH_LITTLE_ENDIAN
     // #define RAPIDHASH_UNROLLED
     // #define RAPIDHASH_FAST
     // and the secrets here are fixed to the following values:
     // #define RAPID_SECRET0 0x2d358dccaa6c78a5ULL
     // #define RAPID_SECRET1 0x8bb84b93962eacc9ULL
     // #define RAPID_SECRET2 0x4b33a62ed433d4a3ULL 

     TPasLLMHashRapidHash=class
      public
       const RapidSeed=TPasLLMUInt64($bdd89aa982704029);
             Secret0=TPasLLMUInt64($2d358dccaa6c78a5);
             Secret1=TPasLLMUInt64($8bb84b93962eacc9);
             Secret2=TPasLLMUInt64($4b33a62ed433d4a3);
       type TMessageDigest=TPasLLMUInt64;
            PMessageDigest=^TMessageDigest;
      private
{$ifndef cpuamd64}
       class procedure MUM(var aA,aB:TPasLLMUInt64); static; {$ifndef cpuamd64}inline;{$endif}
       class function Mix(aA,aB:TPasLLMUInt64):TPasLLMUInt64; static; inline;
{$ifdef BIG_ENDIAN}
       class function Read32(const aData:Pointer):TPasLLMUInt32; static; inline;
       class function Read64(const aData:Pointer):TPasLLMUInt64; static; inline;
       class function ReadSmall(const aData:Pointer;const aDataLength:TPasLLMSizeUInt):TPasLLMUInt64; static; inline;
{$endif}
{$endif}
      public
       class function Process(const aKey:pointer;const aLength:TPasLLMSizeUInt;aSeed:TPasLLMUInt64=RapidSeed):TMessageDigest; static;
     end;                     

     TPasLLMAttentionType=(None,Full,SlidingWindow);
     TPasLLMAttentionTypes=array of TPasLLMAttentionType;

     TPasLLMSWAType=(None,Standard,Chunked,Symmetric);

     { TPasLLMConfiguration }
     TPasLLMConfiguration=class
      private
       fArchitectureName:TPasLLMUTF8String; // Architecture name
       fChatTemplate:TPasLLMUTF8String; // Chat template
       fBOSToken:TPasLLMUTF8String; // Begin of stream token
       fEOSToken:TPasLLMUTF8String; // End of stream token
       fToolCallBeginToken:TPasLLMUTF8String; // Tool call begin token
       fToolCallEndToken:TPasLLMUTF8String; // Tool call end token
       fToolCallBeginTokenID:TPasLLMInt32; // Tool call begin token ID
       fToolCallEndTokenID:TPasLLMInt32; // Tool call end token ID
       fToolResponseBeginToken:TPasLLMUTF8String; // Tool response begin token
       fToolResponseEndToken:TPasLLMUTF8String; // Tool response end token
       fToolResponseBeginTokenID:TPasLLMInt32; // Tool response begin token ID
       fToolResponseEndTokenID:TPasLLMInt32; // Tool response end token ID
       fDim:TPasLLMNativeInt; // Transformer dimension
       fHiddenDim:TPasLLMNativeInt; // Hidden dimension for FFN layers
       fExpertHiddenDim:TPasLLMNativeInt; // Hidden dimension for expert FFN layers
       fHeadDim:TPasLLMNativeInt; // Dimension of each head, usually fDim / fCountQueryHeads
       fCountLayers:TPasLLMNativeInt; // Number of layers
       fCountQueryHeads:TPasLLMNativeInt; // Number of query heads
       fCountKeyValueHeads:TPasLLMNativeInt; // Number of key/value heads (can be < query heads because of multiquery)
       fVocabularySize:TPasLLMNativeInt; // Vocabulary size, usually 256 (byte-level)
       fMaximumSequenceLength:TPasLLMNativeInt; // Max sequence length
       fRotaryDim:TPasLLMNativeInt; // Rotary dimension, same as fHiddenDim if not used
       fDataType:TPasLLMTensorDataType; // Data type of the tensors
       fCountExperts:TPasLLMInt32; // Number of experts in the mixture of experts, 1 = no experts (because single)
       fCountActiveExperts:TPasLLMInt32; // Number of active experts in the mixture of experts, 1 = no experts (because single)
       fQKVClip:TPasLLMFloat; // Clipping value for Q/K/V tensors, inf/zero = no clipping
       fQKNormalization:Boolean; // QK normalization, default is false
       fQKRMSNormalization:Boolean; // QK RMS normalization, default is false
       fQKRoPENonInterleaved:Boolean; // QK RoPE non-interleaved, default is false
       fPostNormalization:Boolean; // Post normalization, default is false
       fRoPENonInterleaved:Boolean; // RoPE non-interleaved, default is false
       fPositionalEncoding:TPasLLMPositionalEncoding; // Positional encoding type, default is RoPE when a model doesn't specify it explicitly (for backward compatibility)
       fPositionalEncodings:TPasLLMPositionalEncodings; // Positional encoding type, default is RoPE when a model doesn't specify it explicitly (for backward compatibility)
       fAttentionTypes:TPasLLMAttentionTypes;        // None | Full | Sliding (SWA)
       fSlidingWindowSizes:TPasLLMInt32DynamicArray;      // SWA window per layer (tokens)
       fSWAType:TPasLLMSWAType;                      // SWA variant (model-level)
       fSWAChunkSize:TPasLLMInt32;                   // SWA chunk size for CHUNKED       
       fQueryPreAttentionScalar:TPasLLMFloat; // 0.0 = disabled, otherwise multiply the query vectors with this scalar before attention 
       fNormalizationEpsilon:TPasLLMFloat; // Epsilon for normalization layers, default is 1e-5
       fAttnLogitSoftcapping:TPasLLMFloat;
       fFinalLogitSoftcapping:TPasLLMFloat;
       fNormalizationType:TPasLLMNormalizationType; // Type of normalization to use, default is RMSNorm
       fActivationType:TPasLLMActivationType; // Type of activation to use, default is SiLU
       fRoPETheta:TPasLLMFloat; // RoPE theta value, default is 10000.0, or 500000.0 for Llama 3.2 based models
       fBeginOfStreamToken:TPasLLMInt32DynamicArray; // Begin of stream token, usually 128000
       fEndOfStreamToken:TPasLLMInt32DynamicArray; // End of stream token, usually 128001
       fTemperature:TPasLLMFloat; // The temperature for sampling, 0.0 = greedy deterministic. 1.0 = original. don't set higher
       fTopP:TPasLLMFloat; // The top-p value for nucleus sampling, 1.0 = off. 0.9 works well, but slower
       fPenaltyLastN:TPasLLMInt32; // Penalty for the last N tokens, 0 = disable, -1 = complete context length
       fPenaltyRepeat:TPasLLMFloat; // Penalty value for repeated tokens
       fPenaltyFrequency:TPasLLMFloat; // Penalty value for frequency of tokens
       fPenaltyPresence:TPasLLMFloat; // Penalty value for presence of tokens
      public
       constructor Create; reintroduce; // Create from raw config
       destructor Destroy; override;
      public
       property ArchitectureName:TPasLLMUTF8String read fArchitectureName; // Architecture name
       property ChatTemplate:TPasLLMUTF8String read fChatTemplate; // Chat template
       property BOSToken:TPasLLMUTF8String read fBOSToken; // Begin of stream token
       property EOSToken:TPasLLMUTF8String read fEOSToken; // End of stream token
       property ToolCallBeginToken:TPasLLMUTF8String read fToolCallBeginToken; // Tool call begin token
       property ToolCallEndToken:TPasLLMUTF8String read fToolCallEndToken; // Tool call end token
       property ToolCallBeginTokenID:TPasLLMInt32 read fToolCallBeginTokenID; // Tool call begin token ID
       property ToolCallEndTokenID:TPasLLMInt32 read fToolCallEndTokenID; // Tool call end end token ID
       property ToolResponseBeginToken:TPasLLMUTF8String read fToolResponseBeginToken; // Tool response begin token
       property ToolResponseEndToken:TPasLLMUTF8String read fToolResponseEndToken; // Tool response end token
       property ToolResponseBeginTokenID:TPasLLMInt32 read fToolResponseBeginTokenID; // Tool response begin token ID
       property ToolResponseEndTokenID:TPasLLMInt32 read fToolResponseEndTokenID; // Tool response end token ID
       property Dim:TPasLLMNativeInt read fDim; // Transformer dimension
       property HiddenDim:TPasLLMNativeInt read fHiddenDim; // Hidden dimension for FFN layers
       property ExpertHiddenDim:TPasLLMNativeInt read fExpertHiddenDim; // Hidden dimension for expert FFN layers
       property HeadDim:TPasLLMNativeInt read fHeadDim; // Dimension of each head, usually fDim / fCountQueryHeads
       property CountLayers:TPasLLMNativeInt read fCountLayers; // Number of layers
       property CountQueryHeads:TPasLLMNativeInt read fCountQueryHeads; // Number of query heads
       property CountKeyValueHeads:TPasLLMNativeInt read fCountKeyValueHeads; // Number of key/value heads (can be < query heads because of multiquery)
       property VocabularySize:TPasLLMNativeInt read fVocabularySize; // Vocabulary size, usually 256 (byte-level)
       property MaximumSequenceLength:TPasLLMNativeInt read fMaximumSequenceLength; // Max sequence length
       property RotaryDim:TPasLLMNativeInt read fRotaryDim; // Rotary dimension, same as fHiddenDim if not used
       property DataType:TPasLLMTensorDataType read fDataType; // Data type of the tensors
       property CountExperts:TPasLLMInt32 read fCountExperts; // Number of experts in the mixture of experts
       property CountActiveExperts:TPasLLMInt32 read fCountActiveExperts; // Number of active experts in the mixture of experts
       property QKVClip:TPasLLMFloat read fQKVClip; // Clipping value for Q/K/V tensors, inf/zero = no clipping
       property QKNormalization:Boolean read fQKNormalization; // QK normalization, default is false
       property QKRMSNormalization:Boolean read fQKRMSNormalization; // QK RMS normalization, default is false
       property QKRoPENonInterleaved:Boolean read fQKRoPENonInterleaved; // QK RoPE non-interleaved, default is false
       property PostNormalization:Boolean read fPostNormalization; // Post normalization, default is false
       property RoPENonInterleaved:Boolean read fRoPENonInterleaved; // RoPE non-interleaved, default is false
       property PositionalEncoding:TPasLLMPositionalEncoding read fPositionalEncoding; // Positional encoding type
       property PositionalEncodings:TPasLLMPositionalEncodings read fPositionalEncodings; // Positional encoding type
       property AttentionTypes:TPasLLMAttentionTypes read fAttentionTypes;        // None | Full | Sliding (SWA)
       property SlidingWindowSizes:TPasLLMInt32DynamicArray read fSlidingWindowSizes;      // SWA window per layer (tokens)
       property SWAType:TPasLLMSWAType read fSWAType;                     // SWA variant (model-level) 
       property SWAChunkSize:TPasLLMInt32 read fSWAChunkSize;              // SWA chunk size for CHUNKED
       property QueryPreAttentionScalar:TPasLLMFloat read fQueryPreAttentionScalar; // 0.0 = disabled, otherwise multiply the query vectors with this scalar before attention
       property NormalizationEpsilon:TPasLLMFloat read fNormalizationEpsilon; // Epsilon for normalization layers, default is 1e-5
       property NormalizationType:TPasLLMNormalizationType read fNormalizationType; // Type of normalization to use, default is RMSNorm
       property FinalLogitSoftcapping:TPasLLMFloat read fFinalLogitSoftcapping; // Final logit softcapping value
       property AttnLogitSoftcapping:TPasLLMFloat read fAttnLogitSoftcapping; // Attention logit softcapping value
       property ActivationType:TPasLLMActivationType read fActivationType; // Type of activation to use, default is SiLU
       property RoPETheta:TPasLLMFloat read fRoPETheta; // RoPE theta value, default is 10000.0, or 500000.0 for Llama 3.2 based models
       property BeginOfStreamToken:TPasLLMInt32DynamicArray read fBeginOfStreamToken; // Begin of stream token, usually 128000
       property EndOfStreamToken:TPasLLMInt32DynamicArray read fEndOfStreamToken; // End of stream token, usually 128001
       property Temperature:TPasLLMFloat read fTemperature write fTemperature; // The temperature for sampling, 0.0 = greedy deterministic. 1.0 = original. don't set higher
       property TopP:TPasLLMFloat read fTopP write fTopP; // The top-p value for nucleus sampling, 1.0 = off. 0.9
       property PenaltyLastN:TPasLLMInt32 read fPenaltyLastN write fPenaltyLastN; // Penalty for the last N tokens, 0 = disable, -1 = complete context length
       property PenaltyRepeat:TPasLLMFloat read fPenaltyRepeat write fPenaltyRepeat; // Penalty value for repeated tokens
       property PenaltyFrequency:TPasLLMFloat read fPenaltyFrequency write fPenaltyFrequency; // Penalty value for frequency of tokens
       property PenaltyPresence:TPasLLMFloat read fPenaltyPresence write fPenaltyPresence; // Penalty value for presence of tokens
     end;

     { TPasLLMTensor }
     TPasLLMTensor=class
      private
       fDataType:TPasLLMTensorDataType;
       fAllocated:Boolean; // True if the quantized tensor was allocated or memory mapped
       fDataSize:TPasLLMSizeInt;
       fSize:TPasLLMSizeInt; // Size in items (not bytes) of the quantized tensor
       fValues:Pointer; // Quantized or non-quantized values
      public
       constructor Create(const aDim:TPasLLMInt32;const aDataType:TPasLLMTensorDataType); reintroduce; overload; // Create a quantized tensor with the given dimension
       constructor Create(const aQ:PPasLLMInt8Array;const aSize:TPasLLMSizeInt;const aDataType:TPasLLMTensorDataType); reintroduce; overload; // Create a quantized tensor with the given quantized values and scaling factors
       constructor Create(const aRawPointer:Pointer;const aDataType:TPasLLMTensorDataType;const aDimensions:array of TPasLLMSizeInt); reintroduce; overload; // Create a quantized tensor
       destructor Destroy; override;
       procedure Reset;
       procedure Dequantize(const aX:PPasLLMFloatArray;const aCount:TPasLLMSizeInt); // Dequantize the given quantized tensor into the given float array
       procedure Quantize(const aX:PPasLLMFloatArray;const aCount:TPasLLMSizeInt); // Quantize the given float array into the quantized tensor
      public
       property DataType:TPasLLMTensorDataType read fDataType;
       property Size:TPasLLMSizeInt read fSize; // Size in items (not bytes) of the quantized tensor
       property Values:Pointer read fValues; // Quantized values
     end;

     TPasLLMTensors=array of TPasLLMTensor;

     TPasLLMExpertTensors=array of TPasLLMTensors;

     { TPasLLMModelWeights }
     TPasLLMModelWeights=class
      private

       fModel:TPasLLMModel;

       // Token embedding table
       fQTokens:TPasLLMTensor; // (vocab_size, dim)
       fTokenEmbeddingTable:PPasLLMFloatArray; // same, but dequantized

       // Weights for rmsnorms
       fRMSAttentionWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim) rmsnorm weights
       fRMSLayerNormalizationWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)
       fRMSQNormalizationWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)
       fRMSKNormalizationWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)
       fRMSPreFeedForwardLayerNormWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)
       fRMSPostFeedForwardLayerNormWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)
       fRMSFeedForwardLayerNormWeights:TPPasLLMFloatArrayDynamicArray; // (layer, dim)

       // Weights for matmuls. note dim == n_heads * head_size
       fWQ:TPasLLMTensors; // (layer, dim, n_heads * head_size)
       fWK:TPasLLMTensors; // (layer, dim, n_kv_heads * head_size)
       fWV:TPasLLMTensors; // (layer, dim, n_kv_heads * head_size)
       fWO:TPasLLMTensors; // (layer, n_heads * head_size, dim)

       // QKV biases
       fWQBias:TPPasLLMFloatArrayDynamicArray; // (layer, n_heads * head_size)
       fWKBias:TPPasLLMFloatArrayDynamicArray; // (layer, n_kv_heads * head_size)
       fWVBias:TPPasLLMFloatArrayDynamicArray; // (layer, n_kv_heads * head_size)

       // Activation parameters
       fActivationFunctionAlphaN:TPPasLLMFloatArrayDynamicArray; // (n_experts, layer) 
       fActivationFunctionAlphaP:TPPasLLMFloatArrayDynamicArray; // (n_experts, layer)
       fActivationFunctionBeta:TPPasLLMFloatArrayDynamicArray; // (n_experts, layer)
       fActivationFunctionEpsilon:TPPasLLMFloatArrayDynamicArray; // (n_experts, layer)

       // Weights for Mixed Of Experts
       fMixtureOfExpertGate:TPasLLMTensors; // (layer, dim, n_experts )

       // Weights for ffn
       fW1:TPasLLMExpertTensors; // (expert, layer, hidden_dim, dim)
       fW2:TPasLLMExpertTensors; // (expert, layer, dim, hidden_dim)
       fW3:TPasLLMExpertTensors; // (expert, layer, hidden_dim, dim)

       // Final rmsnorm
       fRMSFinalWeights:PPasLLMFloatArray; // (dim,)

       // (Optional) classifier weights for the logits, on the last layer
       fWCLS:TPasLLMTensor; // optional classifier weights for the logits, on the last layer

       procedure DestroyQuantizedTensors(var aQ:TPasLLMTensors); // Free the quantized tensors if they were allocated

      public

       constructor Create(const aModel:TPasLLMModel); reintroduce; // Create the model weights with the given configuration
       destructor Destroy; override; // Free all the allocated memory

     end;

     { TPasLLMRunState }
     TPasLLMRunState=class
      private

       fPasLLM:TPasLLM; // reference to the PasLLM instance for memory mapping

       fModel:TPasLLMModel; // The model

       fCountExpertBuffers:TPasLLMSizeInt; // Number of expert buffers, usually 1, but can be more for multi-expert models

       fX:TPasLLMFloatDynamicArray; // Activation at current time stamp (dim,)
       fXB:TPasLLMFloatDynamicArray; // Same, but inside a residual branch (dim,)
       fXB2:TPasLLMFloatDynamicArray; // An additional buffer just for convenience (dim,)
       fEB:TPasLLMFloatDynamicArray; // Buffer for experts
       fXQ:TPasLLMTensor; // Quantized x (dim,)
       fQ:TPasLLMFloatDynamicArray; // Query (dim,)
       fRoPECache:TPasLLMFloatDynamicArray; // RoPE cache
       fStreamingLLMRoPECache:TPasLLMFloatDynamicArray; // StreamingLLM RoPE cache
       fAtt:TPasLLMFloatDynamicArray; // Buffer for scores/attention values (n_heads, seq_len)
       fLogits:TPasLLMFloatDynamicArray; // Output logits

       // Buffers for the feed forward neural network, a dimension more is used for the expert indices, so that it can be used
       // for the mixture of experts together with parallelization
       fHB3:TPasLLMFloatDynamicArrayDynamicArray; // An additional buffer after hidden_dim (dim,)
       fHB:TPasLLMFloatDynamicArrayDynamicArray; // Buffer for hidden dimension in the ffn (hidden_dim,)
       fHB2:TPasLLMFloatDynamicArrayDynamicArray; // Buffer for hidden dimension in the ffn (hidden_dim,)
       fHQ:TPasLLMTensors; // Quantized fHB (hidden_dim,)

       // kv cache
       fKeyCache:TPasLLMFloatDynamicArray;   // (layer, seq_len, dim)
       fValueCache:TPasLLMFloatDynamicArray; // (layer, seq_len, dim)

       // Mixture Of Experts
       fMixtureOfExpertWeights:TPasLLMFloatDynamicArray;
       fMixtureOfExpertWeightIndices:TPasLLMInt32DynamicArray;

      public
       constructor Create(const aModel:TPasLLMModel); reintroduce;
       destructor Destroy; override;
       procedure Reset;
     end;

     { TPasLLMModel }
     TPasLLMModel=class
      private
       fPasLLM:TPasLLM; // reference to the PasLLM instance for memory mapping
       fModelFilePath:TPasLLMUTF8String;
       fTokenizer:TPasLLMTokenizer; // The tokenizer for the model
       fFileStream:TStream; // the file mapped stream for the checkpoint file
//     fFileSize:TPasLLMSizeUInt; // size of the checkpoint file in bytes
       fConfiguration:TPasLLMConfiguration; // The configuration of the modekl
       fWeights:TPasLLMModelWeights; // the weights of the model
       fMetaDataHash:TPasLLMUInt64;
       fTokenEmbeddingTableHash:TPasLLMUInt64;
       fHash:TPasLLMUInt64;
       fData:Pointer; // memory mapped data pointer
      public
       constructor Create(const aPasLLM:TPasLLM;const aModelFilePath:TPasLLMUTF8String;const aMaximumSequenceLength:TPasLLMInt32=TPasLLMInt32($7fffffff)); overload;
       destructor Destroy; override;
      published
       property ModelFilePath:TPasLLMUTF8String read fModelFilePath;
       property Tokenizer:TPasLLMTokenizer read fTokenizer;
       property Configuration:TPasLLMConfiguration read fConfiguration;
     end;

     TPasLLMHashMapEntityIndices=array of TPasLLMInt32;

     TPasLLMHashMapUInt128=array[0..1] of TPasLLMUInt64;

     { TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue> }
     TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>=class
      public
       type TEntity=record
             public
              const Empty=0;
                    Deleted=1;
                    Used=2;
             public
              State:TPasLLMUInt32;
              Key:TPasLLMHashMapKey;
              Value:TPasLLMHashMapValue;
            end;
            PEntity=^TEntity;
            TEntities=array of TEntity;
      private
       type TEntityEnumerator=record
             private
              fHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TEntity; inline;
             public
              constructor Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TEntity read GetCurrent;
            end;
            TKeyEnumerator=record
             private
              fHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TPasLLMHashMapKey; inline;
             public
              constructor Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TPasLLMHashMapKey read GetCurrent;
            end;
            TPasLLMHashMapValueEnumerator=record
             private
              fHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TPasLLMHashMapValue; inline;
             public
              constructor Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TPasLLMHashMapValue read GetCurrent;
            end;
            TEntitiesObject=class
             private
              fOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
             public
              constructor Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function GetEnumerator:TEntityEnumerator;
            end;
            TKeysObject=class
             private
              fOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
             public
              constructor Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function GetEnumerator:TKeyEnumerator;
            end;
            TValuesObject=class
             private
              fOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>;
              function GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue; inline;
              procedure SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue); inline;
             public
              constructor Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
              function GetEnumerator:TPasLLMHashMapValueEnumerator;
              property Values[const Key:TPasLLMHashMapKey]:TPasLLMHashMapValue read GetValue write SetValue; default;
            end;
      private
       fSize:TPasLLMSizeUInt;
       fLogSize:TPasLLMSizeUInt;
       fCountNonEmptyEntites:TPasLLMSizeUInt;
       fCountDeletedEntites:TPasLLMSizeUInt;
       fEntities:TEntities;
       fDefaultValue:TPasLLMHashMapValue;
       fCanShrink:boolean;
       fEntitiesObject:TEntitiesObject;
       fKeysObject:TKeysObject;
       fValuesObject:TValuesObject;
       function HashData(const aData:TPasLLMPointer;const aDataLength:TPasLLMUInt32):TPasLLMUInt32;
       function HashKey(const aKey:TPasLLMHashMapKey):TPasLLMUInt32;
       function CompareKey(const aKeyA,aKeyB:TPasLLMHashMapKey):boolean;
       function FindEntity(const aKey:TPasLLMHashMapKey):PEntity;
       function FindEntityForAdd(const aKey:TPasLLMHashMapKey):PEntity;
       procedure Resize;
      protected
       function GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
       procedure SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
      public
       constructor Create(const aDefaultValue:TPasLLMHashMapValue);
       destructor Destroy; override;
       procedure Clear(const aCanFree:Boolean=true);
       function Add(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue):PEntity;
       function Get(const aKey:TPasLLMHashMapKey;const aCreateIfNotExist:boolean=false):PEntity;
       function TryGet(const aKey:TPasLLMHashMapKey;out aValue:TPasLLMHashMapValue):boolean;
       function ExistKey(const aKey:TPasLLMHashMapKey):boolean;
       function Delete(const aKey:TPasLLMHashMapKey):boolean;
       property EntityValues[const Key:TPasLLMHashMapKey]:TPasLLMHashMapValue read GetValue write SetValue; default;
       property Entities:TEntitiesObject read fEntitiesObject;
       property Keys:TKeysObject read fKeysObject;
       property Values:TValuesObject read fValuesObject;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;

     { TPasLLMStringHashMap<TPasLLMHashMapValue> }
     TPasLLMStringHashMap<TPasLLMHashMapValue>=class
      private
       type TPasLLMHashMapKey=TPasLLMRawByteString;
            TEntity=record
             public
              const Empty=0;
                    Deleted=1;
                    Used=2;
             public
              State:TPasLLMUInt32;
              Key:TPasLLMHashMapKey;
              Value:TPasLLMHashMapValue;
            end;
            PEntity=^TEntity;
            TEntities=array of TEntity;
      private
       type TEntityEnumerator=record
             private
              fHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TEntity; inline;
             public
              constructor Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TEntity read GetCurrent;
            end;
            TKeyEnumerator=record
             private
              fHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TPasLLMHashMapKey; inline;
             public
              constructor Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TPasLLMHashMapKey read GetCurrent;
            end;
            THashMapValueEnumerator=record
             private
              fHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>;
              fIndex:TPasLLMSizeInt;
              function GetCurrent:TPasLLMHashMapValue; inline;
             public
              constructor Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function MoveNext:boolean; inline;
              property Current:TPasLLMHashMapValue read GetCurrent;
            end;
            TEntitiesObject=class
             private
              fOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>;
             public
              constructor Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function GetEnumerator:TEntityEnumerator;
            end;
            TKeysObject=class
             private
              fOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>;
             public
              constructor Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function GetEnumerator:TKeyEnumerator;
            end;
            TValuesObject=class
             private
              fOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>;
              function GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue; inline;
              procedure SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue); inline;
             public
              constructor Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
              function GetEnumerator:THashMapValueEnumerator;
              property Values[const Key:TPasLLMHashMapKey]:TPasLLMHashMapValue read GetValue write SetValue; default;
            end;
      private
       fSize:TPasLLMSizeUInt;
       fLogSize:TPasLLMSizeUInt;
       fCountNonEmptyEntites:TPasLLMSizeUInt;
       fCountDeletedEntites:TPasLLMSizeUInt;
       fEntities:TEntities;
       fDefaultValue:TPasLLMHashMapValue;
       fCanShrink:boolean;
       fEntitiesObject:TEntitiesObject;
       fKeysObject:TKeysObject;
       fValuesObject:TValuesObject;
       function HashKey(const aKey:TPasLLMHashMapKey):TPasLLMUInt32;
       function FindEntity(const aKey:TPasLLMHashMapKey):PEntity;
       function FindEntityForAdd(const aKey:TPasLLMHashMapKey):PEntity;
       procedure Resize;
      protected
       function GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
       procedure SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
      public
       constructor Create(const aDefaultValue:TPasLLMHashMapValue);
       destructor Destroy; override;
       procedure Clear(const aCanFree:Boolean=true);
       function Add(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue):PEntity;
       function Get(const aKey:TPasLLMHashMapKey;const aCreateIfNotExist:boolean=false):PEntity;
       function TryGet(const aKey:TPasLLMHashMapKey;out aValue:TPasLLMHashMapValue):boolean;
       function ExistKey(const aKey:TPasLLMHashMapKey):boolean;
       function Delete(const aKey:TPasLLMHashMapKey):boolean;
       property EntityValues[const Key:TPasLLMHashMapKey]:TPasLLMHashMapValue read GetValue write SetValue; default;
       property Entities:TEntitiesObject read fEntitiesObject;
       property Keys:TKeysObject read fKeysObject;
       property Values:TValuesObject read fValuesObject;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;

     TPasLLMStringTreeData=TPasLLMInt64;

     { TPasLLMStringTreeNode }
     PPasLLMStringTreeNode=^TPasLLMStringTreeNode;
     TPasLLMStringTreeNode=record
      TheChar:AnsiChar;
      Data:TPasLLMStringTreeData;
      DataExist:Boolean;
      Previous:PPasLLMStringTreeNode;
      Next:PPasLLMStringTreeNode;
      Up:PPasLLMStringTreeNode;
      Down:PPasLLMStringTreeNode;
     end;

     { TPasLLMStringTree }

     TPasLLMStringTree=class
      private
       fRoot:PPasLLMStringTreeNode;
       function CreateStringTreeNode(const aChar:AnsiChar):PPasLLMStringTreeNode;
       procedure DestroyStringTreeNode(const aNode:PPasLLMStringTreeNode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Dumptree;
       procedure DumpList;
       procedure AppendTo(const aDestStringTree:TPasLLMStringTree);
       procedure Optimize(const aDestStringTree:TPasLLMStringTree);
       function Add(const aContent:TPasLLMUTF8String;const aData:TPasLLMStringTreeData;const aReplace:boolean=false):boolean;
       function Delete(const aContent:TPasLLMUTF8String):boolean;
       function Find(const aContent:TPasLLMUTF8String;const aPosition:TPasLLMInt32;var aData:TPasLLMStringTreeData):boolean;
       function FindEx(const aContent:TPasLLMUTF8String;const aPosition:TPasLLMInt32;var aData:TPasLLMStringTreeData;var aLen:TPasLLMInt32;const aStopEarly:Boolean):boolean;
     end;

     { TPasLLMTokenIndex }
     TPasLLMTokenIndex=record
      Str:TPasLLMUTF8String; // the string representation of the token
      ID:TPasLLMInt32; // the ID of the token
     end;
     PPasLLMTokenIndex=^TPasLLMTokenIndex;

     TPasLLMTokenIndexDynamicArray=array of TPasLLMTokenIndex;

     TPasLLMTokenStrings=array of TPasLLMUTF8String;

     TPasLLMTokenizerBytePieces=array[0..511] of AnsiChar; // byte pieces for the tokenizer, 512 is the maximum length of a byte piece

     TPasLLMTokenizerHashMap=TPasLLMStringHashMap<TPasLLMInt32>;

     TPasLLMTokenizerMerge=record
      LeftTokenPosition:TPasLLMInt32; // Left position of the token pair
      LeftTokenID:TPasLLMInt32; // Left token ID
      RightTokenPosition:TPasLLMInt32; // Right position of the token pair
      RightTokenID:TPasLLMInt32; // Right token ID
      ResultTokenID:TPasLLMInt32; // Resulting token ID after merging
      Score:TPasLLMFloat; // Score of the resulting token
     end;
     PPasLLMTokenizerMerge=^TPasLLMTokenizerMerge;

     TPasLLMTokenizerMergeArray=array[0..65535] of TPasLLMTokenizerMerge;
     PPasLLMTokenizerMergeArray=^TPasLLMTokenizerMergeArray;

     TPasLLMTokenizerMergeDynamicArray=array of TPasLLMTokenizerMerge; // Dynamic array to hold token merges

     { TPasLLMTokenizer }
     TPasLLMTokenizer=class
      private
       fModel:TPasLLMModel; // Reference to the PasLLM instance for memory mapping
       fVocab:TPasLLMTokenStrings; // The vocabulary of the tokenizer
       fVocabScores:TPasLLMFloatDynamicArray; // The scores for the vocabulary tokens
     //fVocabStringTree:TPasLLMStringTree; // The string tree for the tokenizer
       fVocabHashMap:TPasLLMTokenizerHashMap; // The hash map for the tokenizer
//     fSortedVocab:TPasLLMTokenIndexDynamicArray; // The sorted vocabulary tokens
       //fMaxTokenLength:TPasLLMUInt32; // The maximum length of a token
       fBOSToken:TPasLLMInt32; // The ID of the BOS token
       fEOSToken:TPasLLMInt32; // The ID of the EOS token
       fStartHeaderIDToken:TPasLLMInt32; // The ID of the start header ID token
       fEOTToken:TPasLLMInt32; // The ID of the EOT token
       fStartOfThinkToken:TPasLLMInt32;
       fEndOfThinkToken:TPasLLMInt32;
       fToolCallBeginToken:TPasLLMInt32;
       fToolCallEndToken:TPasLLMInt32;
       fToolResponseBeginToken:TPasLLMInt32;
       fToolResponseEndToken:TPasLLMInt32;
       fByteFallbacks:TPasLLMInt32; // The start ID for byte fallbacks, used for byte-level tokenization
       fModelTemplate:TPasLLMModelTemplate;
       fChatTemplate:TPasLLMUTF8String;

       function SafeString(const aString:TPasLLMUTF8String):TPasLLMUTF8String; // Ensure the string is safe for processing, removing any invalid characters

       function StringLookup(const aString:TPasLLMUTF8String):TPasLLMInt32; // Lookup the string in the vocabulary and return its ID, or -1 if not found

       function GetNextTokenLength(const aString:TPasLLMUTF8String;const aPosition:TPasLLMInt32):TPasLLMInt32; // Lookup the string in the vocabulary and return its ID, or -1 if not found

       class procedure MergeHeapSwap(const aHeap:PPasLLMTokenizerMergeArray;const aI,aJ:TPasLLMInt32); static; // Swap two elements in the heap
       class procedure MergeHeapInsert(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32;const aValue:TPasLLMTokenizerMerge); static; // Insert a new element into the heap
       class procedure MergeHeapPop(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32); static; // Pop the top element from the heap
       function MergeTryAdd(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32;const aLeftTokenPosition,aLeftTokenID,aRightTokenPosition,aRightTokenID:TPasLLMInt32):TPasLLMInt32; // Try to add a new token merge to the heap
       function Merge(const aTokens:PPasLLMInt32Array;const aCountToken:TPasLLMSizeInt):TPasLLMSizeInt; // Merge tokens in the given array of tokens

      public

       constructor Create(const aModel:TPasLLMModel;const aTokenizerTokens,aTokenizerScores:Pointer); reintroduce; overload;
       destructor Destroy; override;

       procedure InitializeModel;

       class function TokenContains(const aTokenIDs:TPasLLMInt32DynamicArray;const aToken:TPasLLMInt32):Boolean; static;

       function Decode(const aPrevious:TPasLLMUTF8String;const aPreviousToken,aToken:TPasLLMInt32):TPasLLMUTF8String; // Decode the given token into a UTF-8 string, using the previous token for context

       procedure Encode(const aString:TPasLLMUTF8String;const aBOS,aEOS:Boolean;var aTokens:TPasLLMInt32DynamicArray;var aCountToken:TPasLLMSizeInt); // Encode the given string into tokens, optionally adding BOS and EOS tokens

      published
     end;

     { TPasLLMSamplerProbIndex }
     TPasLLMSamplerProbIndex=record
      Probability:TPasLLMFloat; // the probability of the token
      Index:TPasLLMInt32; // the index of the token in the vocabulary
     end;
     PPasLLMSamplerProbIndex=^TPasLLMSamplerProbIndex;

     TPasLLMSamplerProbIndexDynamicArray=array of TPasLLMSamplerProbIndex;

     { TPasLLMSamplerPenalties }
     TPasLLMSamplerPenalties=class
      private
       fPasLLM:TPasLLM; // reference to the PasLLM instance for memory mapping
       fConfiguration:TPasLLMConfiguration; // The configuration of the model
       fPenaltyLastN:TPasLLMInt32; // Penalty for the last N tokens, 0 = disable, -1 = complete context length
       fPenaltyRepeat:TPasLLMFloat; // Penalty value for repeated tokens
       fPenaltyFrequency:TPasLLMFloat; // Penalty value for frequency of tokens
       fPenaltyPresence:TPasLLMFloat; // Penalty value for presence of tokens
       fPreviousRingBuffer:TPasLLMRingBufferInt32; // Ring buffer for the previous tokens, used for penalties
       fTokenCounts:TPasLLMInt32DynamicArray; // Counts of the tokens in the context, used for frequency and presence penalties
       fTokenBitmap:TPasLLMUInt32DynamicArray; // Bitmap for the tokens in the context, if the token is present, the bit is set to 1, otherwise 0
      public
       constructor Create(const aPasLLM:TPasLLM;const aConfiguration:TPasLLMConfiguration); reintroduce;
       destructor Destroy; override;
       procedure Update;
       procedure Reset;
       procedure Accept(const aToken:TPasLLMInt32); // Accept a new token and update the penalties
       procedure Apply(const aProbabilities:PPasLLMFloatArray); // Apply the penalties to the given probabilities
     end; 

     { TPasLLMSampler }
     TPasLLMSampler=class
      private
       fPasLLM:TPasLLM;
       fModelInferenceInstance:TPasLLMModelInferenceInstance;
       fProbIndex:TPasLLMSamplerProbIndexDynamicArray; // The probability index for sampling
       fTemperature:TPasLLMFloat; // The temperature for sampling, 0.0 = greedy deterministic. 1.0 = original. don't set higher
       fTopP:TPasLLMFloat; // The top-p value for nucleus sampling, 1.0 = off. 0.9 works well, but slower
       procedure SetTemperature(const aValue:TPasLLMFloat);
       procedure SetTopP(const aValue:TPasLLMFloat);
       class function SampleArgMax(const aProbabilities:PPasLLMFloatArray;const aCount:TPasLLMSizeInt):TPasLLMInt32; static; // Sample the index with the highest probability
       class function SampleMulti(const aProbabilities:PPasLLMFloatArray;const aCount:TPasLLMSizeInt;const aCoin:TPasLLMFloat):TPasLLMInt32; static; // Sample the index based on the probabilities and a coin flip
       class function Compare(const aA,aB:TPasLLMSamplerProbIndex):TPasLLMInt32; static; // Compare function for sorting the probability index
       class function ParallelCompare(const aA,aB:Pointer):TPasMPInt32; static; // Compare function for sorting the probability index
       function SampleTopP(const aProbabilities:PPasLLMFloatArray;const aTopP:TPasLLMFloat;const aCount:TPasLLMSizeInt;var aPropIndex:TPasLLMSamplerProbIndexDynamicArray;const aCoin:TPasLLMFloat):TPasLLMInt32; // Sample the index based on the probabilities and a coin flip
       class function SampleProbability(const aProbabilities:PPasLLMFloatArray;const aIndex,aCount:TPasLLMSizeInt):TPasLLMFloat; static;
      public
       constructor Create(const aModelInferenceInstance:TPasLLMModelInferenceInstance); reintroduce; // Create the sampler with the given PasLLM instance
       destructor Destroy; override; // Free the allocated memory
       function Sample(const aLogits:PPasLLMFloatArray):TPasLLMInt32; // Sample the index based on the probabilities
       property Temperature:TPasLLMFloat read fTemperature write SetTemperature;
       property TopP:TPasLLMFloat read fTopP write SetTopP;
     end;

     // Callback for input processing, returns the processed prompt string
     TPasLLMModelInferenceInstanceOnInput=function(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String of object;

     // Callback for output processing, receives the generated output string
     TPasLLMModelInferenceInstanceOnOutput=procedure(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aOutput:TPasLLMUTF8String) of object;

     // Callback for side turn
     TPasLLMModelInferenceInstanceOnSideTurn=procedure(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aSide:TPasLLMUTF8String) of object;

     // Callback for checking if termination is requested, returns true if termination is requested
     TPasLLMModelInferenceInstanceOnCheckTerminated=function(const aModelInferenceInstance:TPasLLMModelInferenceInstance):Boolean of object;

     // Callback for checking if abort is requested, returns true if abort is requested
     TPasLLMModelInferenceInstanceOnCheckAbort=function(const aModelInferenceInstance:TPasLLMModelInferenceInstance):Boolean of object;

     TPasLLMModelInferenceInstanceParallelMatMulData=record
      Counter:TPasMPInt32;
      XOut:Pointer;
      X:TPasLLMTensor;
      W:TPasLLMTensor;
      D:TPasLLMInt32;
      N:TPasLLMInt32;
     end;
     PPasLLMModelInferenceInstanceParallelMatMulData=^TPasLLMModelInferenceInstanceParallelMatMulData;

     TPasLLMModelInferenceInstanceParallelAttentionData=record
      Counter:TPasMPInt32;
      XOut:PPasLLMFloatArray; // Pointer to the output array
      AttH:PPasLLMFloatArray; // Pointer to the attention scores array
      QH:PPasLLMFloatArray; // Pointer to the query head array
      KH:PPasLLMFloatArray; // Pointer to the key head array
      VH:PPasLLMFloatArray; // Pointer to the value head array
      HeadDim:TPasLLMInt32;
      KVMul:TPasLLMInt32;
      KVDim:TPasLLMInt32;
      KVLen:TPasLLMInt32;
      SWAType:TPasLLMSWAType;
      IsSliding:Boolean;
      ChunkLen:TPasLLMInt32;      
     end;
     PPasLLMModelInferenceInstanceParallelAttentionData=^TPasLLMModelInferenceInstanceParallelAttentionData;

     TPasLLMModelInferenceInstanceParallelQKVData=record
      Counter:TPasMPInt32;
      RunState:TPasLLMRunState; // Run state for the model inference instance
      Weights:TPasLLMModelWeights; // Weights for the model (inf/zero = no clipping)
      QKVClip:TPasLLMFloat; // Clipping value for Q/K/V tensors
      Dim:TPasLLMInt32; // Dimension of the input tensor
      QDim:TPasLLMInt32; // Dimension of the query tensor
      KVDim:TPasLLMInt32; // Dimension of the key/value tensor
      LayerIndex:TPasLLMInt32; // Index of the layer being processed
      QueryRow:PPasLLMFloatArray; // Pointer to the query row
      KeyCacheRow:PPasLLMFloatArray; // Pointer to the key cache row
      ValueCacheRow:PPasLLMFloatArray; // Pointer to the value cache row
     end;
     PPasLLMModelInferenceInstanceParallelQKVData=^TPasLLMModelInferenceInstanceParallelQKVData;

     TPasLLMModelInferenceInstanceParallelRoPEData=record
      Counter:TPasMPInt32;
      QueryRow:PPasLLMFloatArray; // Pointer to the query row data
      KeyCacheRow:PPasLLMFloatArray; // Pointer to the key cache row data
      LayerIndex:TPasLLMInt32; // Index of the layer for RoPE application
      HeadDim:TPasLLMInt32; // Dimension of the head for RoPE application
      RotaryDim:TPasLLMInt32; // Dimension of the rotary embedding for RoPE application
     end;
     PPasLLMModelInferenceInstanceParallelRoPEData=^TPasLLMModelInferenceInstanceParallelRoPEData;

     TPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData=record
      Counter:TPasMPInt32;
      KeyCacheBase:PPasLLMFloatArray; // Pointer to the base of the key cache
      HeadDim:TPasLLMInt32; // Dimension of the head for RoPE application
      RotaryDim:TPasLLMInt32; // Dimension of the rotary embedding for RoPE application
      KVDim:TPasLLMInt32; // KV dimension
      KVSink:TPasLLMInt32; // KVSink index for the RoPE application
     end;
     PPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData=^TPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData;

     TPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData=record
      LayerIndex:TPasLLMInt32; // Index of the layer being processed
     end;
     PPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData=^TPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData;

     TPasLLMModelInferenceInstanceParallelHBHB2Data=record
      Counter:TPasMPInt32;
      RunState:TPasLLMRunState;
      Weights:TPasLLMModelWeights;
      ExpertBufferIndex:TPasLLMInt32;
      ExpertWeightsIndex:TPasLLMInt32; // Index of the expert being processed
      LayerIndex:TPasLLMInt32; // Index of the layer being processed
      Dim:TPasLLMInt32; // Dimension of the input tensor
      HiddenDim:TPasLLMInt32; // Hidden dimension for the model
     end;
     PPasLLMModelInferenceInstanceParallelHBHB2Data=^TPasLLMModelInferenceInstanceParallelHBHB2Data;

     { TPasLLMModelInferenceInstance }
     TPasLLMModelInferenceInstance=class
      public
       type { TChatSession }
            TChatSession=class
             public
              type TTool=class;

                   { TMCPServer }
                   TMCPServer=class
                    private
                     fID:TPasLLMUTF8String;      // Local identifier for the MCP server (arbitrary, unique)
                     fEndpoint:TPasLLMUTF8String; // JSON-RPC HTTP endpoint (e.g. http(s)://host/api/mcp)
                     fAuthorization:TPasLLMUTF8String; // Optional "Bearer ..." or custom token header value
                     fTimeoutMilliseconds:TPasLLMInt32; // HTTP timeout
                    public
                     constructor Create(const aID,aEndpoint,aAuthorization:TPasLLMUTF8String;const aTimeoutMilliseconds:TPasLLMInt32=30000); reintroduce;
                     destructor Destroy; override;
                    published
                     property ID:TPasLLMUTF8String read fID write fID;
                     property Endpoint:TPasLLMUTF8String read fEndpoint write fEndpoint;
                     property Authorization:TPasLLMUTF8String read fAuthorization write fAuthorization;
                     property TimeoutMilliseconds:TPasLLMInt32 read fTimeoutMilliseconds write fTimeoutMilliseconds;
                   end;

                   TMCPServers=TObjectList<TMCPServer>;

                   TMCPServerHashMap=TPasLLMStringHashMap<TMCPServer>;

                   { TMCPClient }
                   TMCPClient=class
                    private
                     fServer:TMCPServer;
                     function InternalHTTPPostJSON(const aRequestJSON:TPasJSONItemObject;out aResponseJSON:TPasJSONItemObject):Boolean;
                     function NextID:TPasLLMUTF8String;
                    public
                     constructor Create(const aServer:TMCPServer); reintroduce;
                     destructor Destroy; override;
                     function RPC(const aMethod:TPasLLMUTF8String;const aParameters:TPasJSONItem):TPasJSONItemObject; // returns "result" object or raises error via nil with "error"
                     function ListTools:TPasJSONItemArray; // returns tools array (server-specific schema)
                     function CallTool(const aToolName:TPasLLMUTF8String;const aArguments:TPasJSONItem;out aIsError:Boolean):TPasJSONItem; // returns tool call result (arbitrary JSON)
                    published
                     property Server:TMCPServer read fServer;
                   end;

                   { TMCPToolBinding }
                   TMCPToolBinding=class
                    private
                     fServerID:TPasLLMUTF8String; // Which MCP server to use
                     fRemoteToolName:TPasLLMUTF8String; // Remote tool name
                    public
                     constructor Create(const aServerID,aRemoteToolName:TPasLLMUTF8String); reintroduce;
                     destructor Destroy; override;
                    published
                     property ServerID:TPasLLMUTF8String read fServerID write fServerID;
                     property RemoteToolName:TPasLLMUTF8String read fRemoteToolName write fRemoteToolName;
                   end;

                   { TToolCall }
                   TToolCall=class
                    public
                     type TArgument=class
                           private 
                            fName:TPasLLMUTF8String; // Name of the argument
                            fValue:TPasLLMUTF8String; // Value of the argument
                           public
                            constructor Create(const aName:TPasLLMUTF8String='';const aValue:TPasLLMUTF8String=''); reintroduce; overload;
                            constructor Create(const aJSON:TPasJSONItem); reintroduce; overload;
                            destructor Destroy; override;
                            function ToJSON:TPasJSONItemObject; // Convert to JSON object
                           public
                            property Name:TPasLLMUTF8String read fName write fName;
                            property Value:TPasLLMUTF8String read fValue write fValue; 
                          end;
                          TArguments=TObjectList<TArgument>;
                    private
                     fName:TPasLLMUTF8String; // Name of the function to call
                     fID:TPasLLMUTF8String; // Unique identifier for the tool call
                     fArguments:TArguments; // Arguments for the function call
                    public
                     constructor Create(const aName:TPasLLMUTF8String='';const aID:TPasLLMUTF8String='';const aArguments:TArguments=nil); reintroduce; overload;
                     constructor Create(const aJSON:TPasJSONItem); reintroduce; overload;
                     constructor CreateFromJSONString(const aJSON:TPasLLMUTF8String); reintroduce;
                     destructor Destroy; override;
                     function ToJSON(const aForChatTemplate:Boolean):TPasJSONItemObject; // Convert to JSON object
                     function GetArgumentValue(const aName:TPasLLMUTF8String):TPasLLMUTF8String;
                    public
                     property Name:TPasLLMUTF8String read fName write fName;
                     property ID:TPasLLMUTF8String read fID write fID;
                     property Arguments:TArguments read fArguments write fArguments;
                   end;

                   TToolCalls=TObjectList<TToolCall>;
                   
                   TToolResult=class
                    private
                     fToolName:TPasLLMUTF8String; // ID of the tool call this is a result for
                     fToolCallID:TPasLLMUTF8String; // ID of the tool call this is a result for
                     fContent:TPasLLMUTF8String; // Result content
                     fIsError:Boolean; // Whether this is an error result
                    public
                     constructor Create(const aToolName,aToolCallID,aContent:TPasLLMUTF8String;const aIsError:Boolean=false); reintroduce;
                     destructor Destroy; override;
                     function ToJSON:TPasJSONItemObject; // Convert to JSON object
                     procedure FromJSON(const aJSON:TPasJSONItemObject); // Load from JSON object
                    published
                     property ToolName:TPasLLMUTF8String read fToolName write fToolName;
                     property ToolCallID:TPasLLMUTF8String read fToolCallID write fToolCallID;
                     property Content:TPasLLMUTF8String read fContent write fContent;
                     property IsError:Boolean read fIsError write fIsError;
                   end;
                   TToolResults=TObjectList<TToolResult>;

                   TTool=class
                    public 
                     type TOnFunctionCall=function(const aChatSession:TChatSession;const aToolCall:TToolCall;const aToolResult:TToolResult):Boolean; // Event triggered when the tool is called
                          TOnMethodCall=function(const aChatSession:TChatSession;const aToolCall:TToolCall;const aToolResult:TToolResult):Boolean of object; // Event triggered when the tool is called
                          TArgument=class
                           private
                            fName:TPasLLMUTF8String; // Name of the argument
                            fDescription:TPasLLMUTF8String; // Description of the argument
                            fExample:TPasLLMUTF8String; // Example value of the argument
                           public
                            constructor Create(const aName:TPasLLMUTF8String='';const aDescription:TPasLLMUTF8String='';const aExample:TPasLLMUTF8String=''); reintroduce;
                            destructor Destroy; override;
                           published
                            property Name:TPasLLMUTF8String read fName write fName;
                            property Description:TPasLLMUTF8String read fDescription write fDescription;
                            property Example:TPasLLMUTF8String read fExample write fExample;
                          end;
                          TArguments=TObjectList<TArgument>;
                    private
                     fID:TPasLLMUTF8String; // ID of the tool
                     fName:TPasLLMUTF8String; // Name of the tool
                     fDescription:TPasLLMUTF8String; // Description of the tool
                     fOnFunctionCall:TOnFunctionCall; // Event triggered when the tool is called
                     fOnMethodCall:TOnMethodCall; // Event triggered when the tool is called
                     fArguments:TArguments; // Arguments for the tool
                     fEnabled:Boolean; // Whether the tool is enabled
                     fMCPBinding:TMCPToolBinding;
                     procedure GenerateID;
                    public
                     constructor Create; reintroduce; overload;
                     constructor Create(const aName:TPasLLMUTF8String;const aDescription:TPasLLMUTF8String;const aOnFunctionCall:TOnFunctionCall);  reintroduce; overload;
                     constructor Create(const aName:TPasLLMUTF8String;const aDescription:TPasLLMUTF8String;const aOnMethodCall:TOnMethodCall);  reintroduce; overload;
                     destructor Destroy; override;
                    public
                     property ID:TPasLLMUTF8String read fID write fID;
                     property Name:TPasLLMUTF8String read fName write fName;
                     property Description:TPasLLMUTF8String read fDescription write fDescription;
                     property OnFunctionCall:TOnFunctionCall read fOnFunctionCall write fOnFunctionCall;
                     property OnMethodCall:TOnMethodCall read fOnMethodCall write fOnMethodCall;
                     property Arguments:TArguments read fArguments write fArguments;
                     property Enabled:Boolean read fEnabled write fEnabled;
                     property MCPBinding:TMCPToolBinding read fMCPBinding write fMCPBinding;
                   end;

                   TTools=TObjectList<TTool>;

                   TToolHashMap=TPasLLMStringHashMap<TTool>;
                   
                   TMessage=class
                    private
                     fRole:TPasLLMUTF8String; // The role of the message, e.g. "user", "assistant", "system", "tool"
                     fContent:TPasLLMUTF8String; // The content of the message
                     fTimeStamp:TDateTime; // The timestamp of the message
                     fToolCalls:TToolCalls; // Tool calls in this message (for assistant messages)
                     fToolCallID:TPasLLMUTF8String; // Tool call ID (for tool response messages)
                     fToolName:TPasLLMUTF8String; // Name field for tool messages
                    public
                     constructor Create(const aRole:TPasLLMUTF8String='';aContent:TPasLLMUTF8String=''); reintroduce;
                     destructor Destroy; override;
                     function ToJSON(const aForChatTemplate:Boolean):TPasJSONItemObject; // Convert to JSON object
                     procedure FromJSON(const aJSON:TPasJSONItemObject); // Load from JSON object
                     procedure AddToolCall(const aToolCall:TToolCall); // Add a tool call to this message
                     function HasToolCalls:Boolean; // Check if message has tool calls
                    published 
                     property Role:TPasLLMUTF8String read fRole write fRole;
                     property Content:TPasLLMUTF8String read fContent write fContent;
                     property TimeStamp:TDateTime read fTimeStamp write fTimeStamp;
                     property ToolCalls:TToolCalls read fToolCalls;
                     property ToolCallID:TPasLLMUTF8String read fToolCallID write fToolCallID;
                     property ToolName:TPasLLMUTF8String read fToolName write fToolName;
                   end;
                   TMessages=TObjectList<TMessage>;
                   TState=
                    (
                     Unknown,
                     ProcessingPlaybackTokens,
                     Initial,
                     SystemPromptInput,
                     UserInput,
                     SetupUserPromptProcessing,
                     ProcessingUserPromptToken,
                     SetupAssistantAnswerGenerating,
                     GeneratingAssistantAnswer,
                     ProcessPendingToolCalls,
                     SetupToolPromptProcessing,
                     ProcessingToolPromptToken,
                     Aborted,
                     Terminated
                    );
                   TOnMessage=procedure(const aSender:TChatSession;const aMessage:TMessage) of object;
                   TOnStateChange=procedure(const aSender:TChatSession;const aOldState,aNewState:TState) of object;
                   TOnTokenGenerated=procedure(const aSender:TChatSession;const aToken:TPasLLMUTF8String) of object;
                   TOnInput=function(const aSender:TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String of object;
                   TOnOutput=procedure(const aSender:TChatSession;const aOutput:TPasLLMUTF8String) of object;
                   TOnSideTurn=procedure(const aSender:TChatSession;const aSide:TPasLLMUTF8String) of object;
                   TOnCheckAbort=function(const aSender:TChatSession):Boolean of object;
                   TOnCheckTerminated=function(const aSender:TChatSession):Boolean of object;
                   TOnGetModelInfo=function(const aSender:TChatSession):TPasLLMUTF8String of object; // Callback to get current model information
             private

              // Main stuff
              fOwner:TPasLLMModelInferenceInstance;
              fTitle:TPasLLMUTF8String; // Title of the chat session
              fTimeStamp:TDateTime; // Timestamp of session creation or update
              fMessages:TMessages;
              fLastState:TState;
              fState:TState;
              fSystemPrompt:TPasLLMUTF8String;
              fCurrentPosition:TPasLLMInt32;
              fThinkMode:TPinjaChatTemplateThinkMode;
              fThinking:Boolean;
              fOutputThinking:Boolean;
              fInToolCall:Boolean;
              fToolCallContent:TPasLLMUTF8String;
              fLastSamplerOutput:Boolean;
              fMaxSteps:TPasLLMInt32;
              fCurrentStep:TPasLLMInt32;
              fChatTemplate:TPinjaChatTemplate;
              fAssistantMessage:TMessage;
              fToolMessage:TMessage;
              fPromptTokens:TPasLLMInt32DynamicArray;
              fCountPromptTokens:TPasLLMSizeInt;
              fPlaybackPromptTokens:TPasLLMInt32DynamicArray; // Tokens for session playback
              fCountPlaybackPromptTokens:TPasLLMSizeInt; // Count of playback tokens
              fPlaybackPromptTokenIndex:TPasLLMInt32; // Index for playback tokens
              fPromptIndex:TPasLLMInt32;
              fNextToken:TPasLLMInt32; // Next token to be processed
              fPreviousToken:TPasLLMInt32; // Previous token
              fPreviousOutput:TPasLLMUTF8String; // Previous output for token decoding
              fSessionContinuation:Boolean; // Whether we're continuing a loaded session
              fOnlyLastMessage:Boolean; // Whether we're continuing a loaded session
              fBackupStateForPlayback:TState; // Backup of original state before playback processing
              fTokenList:TPasLLMTokenList; // List of tokens for the current session
              fPlaybackTokenList:TPasLLMTokenList; // List of tokens for playback
              fSavedTokenList:TPasLLMTokenList; // Token list saved with the session, for to avoid lost on too early re-saving  
              fSavedHash:TPasLLMUInt64; // Hash of the model of the saved chat session for checking of token compatibly

              // Tool calling support
              fToolsEnabled:Boolean; // Whether tool calling is enabled
              fPendingToolCalls:TToolCalls; // Tool calls waiting for results
              fToolResults:TToolResults; // Tool results to be processed
              fAvailableTools:TPasJSONItemArray; // Available tool definitions

              // MCP stuff
              fMCPServers:TMCPServers;
              fMCPServerHashMap:TMCPServerHashMap;

              // Performance tracking
              fPromptAccumulatedTime:TPasLLMUInt64;
              fPromptAccumulatedTokens:TPasLLMUInt64;
              fOutputAccumulatedTime:TPasLLMUInt64;
              fOutputAccumulatedTokens:TPasLLMUInt64;

              // Events
              fOnMessage:TOnMessage;
              fOnStateChange:TOnStateChange;
              fOnTokenGenerated:TOnTokenGenerated;
              fOnInput:TOnInput;
              fOnOutput:TOnOutput;
              fOnSideTurn:TOnSideTurn;
              fOnCheckAbort:TOnCheckAbort;
              fOnCheckTerminated:TOnCheckTerminated;
              fOnGetModelInfo:TOnGetModelInfo;

              // Tools
              fTools:TTools;
              fToolHashMap:TToolHashMap;

              // Tavily
              fTavilyKey:TPasLLMUTF8String;

              // Internal methods
              procedure SetState(const aNewState:TState); // Set state and fire change event
              procedure HandleSpecialCommands(var aUserPrompt:TPasLLMUTF8String); // Handle commands like /think, /quit etc.
              function RenderPromptWithTools(const aOnlyLastMessage:Boolean=false;const aMessageIndex:TPasLLMInt32=-1):TPasLLMUTF8String; // Render prompt including tool definitions
              procedure AddToolCall(const aContent:TPasLLMUTF8String); // Parse and process tool calls from model output
              procedure AddToolResultMessage(const aToolResult:TToolResult); // Add tool result as message
              procedure PrepareSessionContinuation; // Prepare session for continuation after loading

              // Default tools
              function ToolOnGetGurrentDatetime(const aChatSession:TChatSession;const aToolCall:TToolCall;const aToolResult:TToolResult):Boolean;
              function ToolOnWebSearch(const aChatSession:TChatSession;const aToolCall:TPasLLMModelInferenceInstance.TChatSession.TToolCall;const aToolResult:TChatSession.TToolResult):Boolean;

             public
              
              constructor Create(const aOwner:TPasLLMModelInferenceInstance);
              destructor Destroy; override;

              // Tool management 
              procedure ClearTools; // Clear all tool definitions
              procedure AddDefaultTools; // Add some default tools
              procedure AddTool(const aTool:TTool); // Add a tool definition
              procedure RemoveTool(const aToolName:TPasLLMUTF8String); // Remove a tool definition by name
              function FindTool(const aToolName:TPasLLMUTF8String):TTool; // Find a tool definition by name
              function GetToolCount:TPasLLMInt32; // Get the number of tools
              function GetTool(const aIndex:TPasLLMInt32):TTool; // Get a tool by index
              procedure EnableTool(const aToolName:TPasLLMUTF8String;const aEnabled:Boolean); // Enable/disable a tool by name
              function IsToolEnabled(const aToolName:TPasLLMUTF8String):Boolean; // Check if a tool is enabled by name

              // MCP
              function RegisterMCPServer(const aID,aEndpoint,aAuthorization:TPasLLMUTF8String;const aTimeoutMilliseconds:TPasLLMInt32=30000):Boolean;
              function RegisterMCPToolsFromServer(const aServerID:TPasLLMUTF8String):Boolean;
              function UnregisterMCPServer(const aServerID:TPasLLMUTF8String):Boolean;
              function ToolOnMCPCall(const aChatSession:TChatSession;const aToolCall:TToolCall;const aToolResult:TToolResult):Boolean; // bind to OnMethodCall
              procedure LoadMCPServersFromJSON(const aJSON:TPasJSONItem);
              procedure LoadMCPServersFromJSONStream(const aStream:TStream);
              procedure LoadMCPServersFromJSONFile(const aFileName:TPasLLMUTF8String);
              
              // Core functionality
              procedure Reset;
              procedure SetSystemPrompt(const aPrompt:TPasLLMUTF8String);
              procedure AddUserMessage(const aMessage:TPasLLMUTF8String);
              procedure AddAssistantMessage(const aMessage:TPasLLMUTF8String); // Add assistant message
              function AddToolMessage(const aToolName:TPasLLMUTF8String;const aToolCallID,aContent:TPasLLMUTF8String):TMessage; // Add tool result message
              function Step:Boolean; // Returns false when session is complete
              procedure Run(const aMaxSteps:TPasLLMInt32=0); // Run until completion or max steps
              procedure Abort;
              procedure ForceAbort;

              // Default console I/O handlers
              function DefaultOnInput(const aSender:TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String; // Default console input handler
              procedure DefaultOnOutput(const aSender:TChatSession;const aText:TPasLLMUTF8String); // Default console output handler
              
              // State conversion utilities
              class function StateToString(const aState:TState):TPasLLMUTF8String; static; // Convert state enum to string
              class function StringToState(const aStateString:TPasLLMUTF8String):TState; static; // Convert string to state enum
              
              // Tool calling support
              procedure EnableTools(const aEnabled:Boolean=true); // Enable/disable tool calling
              procedure AddToolResult(const aToolResult:TToolResult); // Add a tool call result
              procedure SetAvailableTools(const aTools:TPasJSONItemArray); // Set available tool definitions
              procedure AddAvailableTool(const aToolDefinition:TPasJSONItemObject); // Add a single tool definition
              procedure ClearAvailableTools; // Clear all tool definitions
              
              // Session continuation helpers
              procedure AddPlaybackTokens(const aContent:TPasLLMUTF8String); // Helper to add tokens to playback sequence
              
              // Message management
              procedure ClearMessages;
              function GetMessageCount:TPasLLMInt32;
              function GetMessage(const aIndex:TPasLLMInt32):TMessage; // Changed return type to TMessage
              procedure LoadFromJSON(const aJSON:TPasLLMUTF8String);
              procedure LoadFromJSONFile(const aFileName:TPasLLMUTF8String);
              function SaveToJSON:TPasLLMUTF8String;
              procedure SaveToJSONFile(const aFileName:TPasLLMUTF8String);
              procedure LoadSessionContentFromJSONObject(const aJSONObject:TPasJSONItemObject); // Load content without model info from JSON object
              function SaveToJSONObject:TPasJSONItemObject; // Save to JSON object
              
              // Split loading methods
              function LoadSessionModelInfoFromJSONFile(const aFileName:TPasLLMUTF8String;var aModelInfo:TPasLLMUTF8String):Boolean; // Load only model info
              procedure LoadSessionContentFromJSONFile(const aFileName:TPasLLMUTF8String); // Load content without model info
              
              // State queries
              function IsWaitingForUser:Boolean;
              function IsGenerating:Boolean;
              function IsComplete:Boolean;
              function IsWaitingForToolResult:Boolean; // Check if waiting for tool results
              function GetProgress:Double; // Returns 0.0-1.0 progress if max steps set
              
              // Performance metrics
              function GetTokensPerSecond:Double;
              function GetPromptTokensPerSecond:Double;
              function GetOutputTokensPerSecond:Double;             

             published

              property Owner:TPasLLMModelInferenceInstance read fOwner;
              property Title:TPasLLMUTF8String read fTitle write fTitle;
              property TimeStamp:TDateTime read fTimeStamp write fTimeStamp;
              property Messages:TMessages read fMessages;
              property State:TState read fState write SetState;
              property SystemPrompt:TPasLLMUTF8String read fSystemPrompt write SetSystemPrompt;
              property CurrentPosition:TPasLLMInt32 read fCurrentPosition write fCurrentPosition;
              property ThinkMode:TPinjaChatTemplateThinkMode read fThinkMode write fThinkMode;
              property Thinking:Boolean read fThinking write fThinking;
              property OutputThinking:Boolean read fOutputThinking write fOutputThinking;
              property InToolCall:Boolean read fInToolCall write fInToolCall;
              property ToolCallContent:TPasLLMUTF8String read fToolCallContent write fToolCallContent;
              property MaxSteps:TPasLLMInt32 read fMaxSteps write fMaxSteps;
              property CurrentStep:TPasLLMInt32 read fCurrentStep write fCurrentStep;
              property ChatTemplate:TPinjaChatTemplate read fChatTemplate write fChatTemplate;
              property PromptTokens:TPasLLMInt32DynamicArray read fPromptTokens write fPromptTokens;
              property CountPromptTokens:TPasLLMSizeInt read fCountPromptTokens write fCountPromptTokens;
              property PromptIndex:TPasLLMInt32 read fPromptIndex write fPromptIndex;
              
              // Tool calling properties
              property ToolsEnabled:Boolean read fToolsEnabled write fToolsEnabled;
              property PendingToolCalls:TToolCalls read fPendingToolCalls;
              property ToolResults:TToolResults read fToolResults;
              property AvailableTools:TPasJSONItemArray read fAvailableTools;

              // Tavily
              property TavilyKey:TPasLLMUTF8String read fTavilyKey write fTavilyKey;

              // Performance tracking
              property PromptAccumulatedTime:TPasLLMUInt64 read fPromptAccumulatedTime write fPromptAccumulatedTime;
              property PromptAccumulatedTokens:TPasLLMUInt64 read fPromptAccumulatedTokens write fPromptAccumulatedTokens;
              property OutputAccumulatedTime:TPasLLMUInt64 read fOutputAccumulatedTime write fOutputAccumulatedTime;
              property OutputAccumulatedTokens:TPasLLMUInt64 read fOutputAccumulatedTokens write fOutputAccumulatedTokens;

              // Events
              property OnMessage:TOnMessage read fOnMessage write fOnMessage;
              property OnStateChange:TOnStateChange read fOnStateChange write fOnStateChange;
              property OnTokenGenerated:TOnTokenGenerated read fOnTokenGenerated write fOnTokenGenerated;
              property OnInput:TOnInput read fOnInput write fOnInput;
              property OnOutput:TOnOutput read fOnOutput write fOnOutput;
              property OnSideTurn:TOnSideTurn read fOnSideTurn write fOnSideTurn;
              property OnCheckAbort:TOnCheckAbort read fOnCheckAbort write fOnCheckAbort;
              property OnCheckTerminated:TOnCheckTerminated read fOnCheckTerminated write fOnCheckTerminated;
              property OnGetModelInfo:TOnGetModelInfo read fOnGetModelInfo write fOnGetModelInfo;

            end;

      private

       fPasLLM:TPasLLM; // reference to the PasLLM instance for memory mapping

       fModel:TPasLLMModel; // the model instance

       fSamplerPenalties:TPasLLMSamplerPenalties; // The sampler penalties for the model

       fSampler:TPasLLMSampler; // The sampler for the model

       fRunState:TPasLLMRunState; // buffers for the "wave" of activations in the forward pass

       fJobManager:TPasLLMJobManager; // Job manager

       fSteps:TPasLLMInt32; // The number of steps to run for

       fPCG32:TPasLLMPCG32;

       fOnInput:TPasLLMModelInferenceInstanceOnInput; // The input callback for the model
       fOnOutput:TPasLLMModelInferenceInstanceOnOutput; // The output callback for the model
       fOnSideTurn:TPasLLMModelInferenceInstanceOnSideTurn; // The side turn callback
       fOnCheckTerminated:TPasLLMModelInferenceInstanceOnCheckTerminated; // The check terminated callback for the model
       fOnCheckAbort:TPasLLMModelInferenceInstanceOnCheckAbort; // The check abort callback for the model

       fParallelMatMulData:TPasLLMModelInferenceInstanceParallelMatMulData;
       fParallelAttentionData:TPasLLMModelInferenceInstanceParallelAttentionData;
       fParallelQKVData:TPasLLMModelInferenceInstanceParallelQKVData;
       fParallelRoPEData:TPasLLMModelInferenceInstanceParallelRoPEData;
       fParallelStreamingLLMRoPEData:TPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData;
       fParallelFeedForwardNeuralNetworkForwardData:TPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData;
       fParallelHBHB2Data:TPasLLMModelInferenceInstanceParallelHBHB2Data;

       fChatInput:TPasLLMUTF8String;
       fChatOutput:TPasLLMUTF8String;

       function ChatOnInput(const aSender:TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
       procedure ChatOnOutput(const aSender:TChatSession;const aOutput:TPasLLMUTF8String);
       procedure ChatOnSideTurn(const aSender:TChatSession;const aSide:TPasLLMUTF8String);
       function GetTemperature:TPasLLMFloat;
       procedure SetTemperature(const aValue:TPasLLMFloat);

       function GetTopP:TPasLLMFloat;
       procedure SetTopP(const aValue:TPasLLMFloat);

       procedure SetSteps(const aValue:TPasLLMInt32);

       class procedure AdvanceSWAKVSink(var aKVSink,aKVLen:TPasLLMSizeInt;const aWindow,aMaxSequenceLength:TPasLLMSizeInt); static;

       class procedure MatMulParallelForProcedure(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt); static;
       procedure ParallelMatMulFunction(const aData:Pointer);

       procedure MatMul(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aD:TPasLLMInt32);

       procedure MatMulQParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       procedure MatMulKParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       procedure MatMulVParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       procedure ParallelMatMulQKVFunction(const aData:Pointer);
       procedure ParallelPostQKVFunction(const aData:Pointer);

       procedure RoPEQParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure RoPEKParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure ParallelRoPEFunction(const aData:Pointer);

       procedure StreamingLLMRoPEParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure ParallelStreamingLLMRoPEFunction(const aData:Pointer);

       procedure MatMulHBParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       procedure MatMulHB2ParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);

       procedure AttentionParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure ParallelAttentionFunction(const aData:Pointer);

       class function RoPEYaRNCorrectionDimension(const aCountDim,aCountOriginalCtx:TPasLLMInt32;const aCountRotation,aBase:TPasLLMFloat):TPasLLMFloat; static;
       class procedure RoPEYaRNCorrectionDimensions(const aCountDim,aCountOriginalCtx:TPasLLMInt32;const aFrequencyBase,aBetaFast,aBetaSlow:TPasLLMFloat;out aCorrDimsV0,aCorrDimsV1:TPasLLMFloat); static;
       class function RoPEYaRNRamp(const aLow,aHigh:TPasLLMFloat;const aI0:TPasLLMInt32):TPasLLMFloat; static; inline;
       class procedure RoPEYaRN(const aThetaExtrapolation,aFrequencyScale:TPasLLMFloat;const aCorrDimsV0,aCorrDimsV1:TPasLLMFloat;const aI0:TPasLLMInt32;const aExtrapolationFactor,aMagnitudeScale:TPasLLMFloat;out aSinTheta,aCosTheta:TPasLLMFloat); static;

       class procedure CachedRoPEPrepare(const aSinusCosinusVector:PPasLLMFloatArray;const aHeadDim,aPosition:TPasLLMInt32;const aTheta:TPasLLMFloat;const aRotaryDim:TPasLLMInt32); static;

       class procedure CachedRoPESingleHeadInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32); static;

       class procedure CachedRoPESingleHeadNonInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32); static;

       class procedure CachedRoPESingleHead(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32;const aNonInterleaved:Boolean); static;

       class procedure CachedRoPEMultiHeads(const aVector,aRoPECache:PPasLLMFloatArray;const aCountHeads,aHeadDim,aRotaryDim:TPasLLMInt32;const aNonInterleaved:Boolean); static;

       class procedure Attention(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat); static;

       class procedure AttentionChunked(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen,aChunkLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat); static;

       class procedure AttentionDispatch(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen:TPasLLMInt32;const aSWAType:TPasLLMSWAType;const aIsSliding:Boolean;const aChunkLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat); static;

       class procedure DoaGEGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);

       class procedure DoSwiGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);

       class function GELU(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function SILU(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function XIELU(const aValue,aAlphaP,aAlphaN,aBeta,aEpsilon:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function RELU(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function RELU2(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function SWISH(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function SoftPlus(const aValue:TPasLLMFloat;const aBeta:TPasLLMFloat=1.0;const aThreshold:TPasLLMFloat=20.0):TPasLLMFloat; static; inline;

       class function MISH(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       class function LINEAR(const aValue:TPasLLMFloat):TPasLLMFloat; static; inline;

       procedure MixtureOfExpertGate;

       procedure FeedForwardNeuralNetworkForward(const aLayerIndex,aActiveExpertIndex:TPasLLMSizeInt);

       procedure FeedForwardNeuralNetworkForwardParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);

       function DefaultOnInput(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String; // Default input callback, gets the input from the console
       procedure DefaultOnOutput(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aOutput:TPasLLMUTF8String); // Default output callback, prints the output to the console

      public

       constructor Create(const aModel:TPasLLMModel;const aSeed:TPasLLMUInt64=0); reintroduce; // Create the model inference with the given PasLLM instance
       destructor Destroy; override;

       procedure Reset; // Reset the run state

       function Forward(const aToken,aPosition:TPasLLMInt32;const aUpdateKVOnly:Boolean):Pointer; // Forward pass for the given token and position, returns the quantized tensor for the token embedding

       procedure Generate(const aPrompt:TPasLLMUTF8String;const aSteps:TPasLLMInt32=0);
       function Chat(const aPrompt:TPasLLMUTF8String;const aSteps:TPasLLMInt32=0;const aSystemPrompt:TPasLLMUTF8String=''):TPasLLMUTF8String;
       procedure Study(const aPath:TPasLLMUTF8String;const aSteps:TPasLLMInt32=0);
       procedure TokenizerEncoderTest(const aString:TPasLLMUTF8String);
       
       // Chat session management
       function CreateChatSession:TChatSession; // Create a new chat session instance

      published

       property SamplerPenalties:TPasLLMSamplerPenalties read fSamplerPenalties;

       property RunState:TPasLLMRunState read fRunState;

       property Temperature:TPasLLMFloat read GetTemperature write SetTemperature;
       property TopP:TPasLLMFloat read GetTopP write SetTopP;
       
       property Steps:TPasLLMInt32 read fSteps write SetSteps;

       property OnInput:TPasLLMModelInferenceInstanceOnInput read fOnInput write fOnInput; // Callback for input processing, returns the processed prompt string
       property OnOutput:TPasLLMModelInferenceInstanceOnOutput read fOnOutput write fOnOutput; // Callback for output processing, receives the generated output string
       property OnSideTurn:TPasLLMModelInferenceInstanceOnSideTurn read fOnSideTurn write fOnSideTurn; // Callback for side turn
       property OnCheckTerminated:TPasLLMModelInferenceInstanceOnCheckTerminated read fOnCheckTerminated write fOnCheckTerminated; // Callback for checking if termination is requested, returns true if termination is requested
       property OnCheckAbort:TPasLLMModelInferenceInstanceOnCheckAbort read fOnCheckAbort write fOnCheckAbort; // Callback for checking if abort is requested, returns true if abort is requested

     end;

     TPasLLMJobManagerJobMethod=procedure(const aData:pointer) of object;

     // Shared for all worker threads, simple counter-based parallelization
     TPasLLMJobManagerJob=record
      JobMethod:TPasLLMJobManagerJobMethod;
      Data:Pointer;
     end;
     PPasLLMJobManagerJob=^TPasLLMJobManagerJob;

     { TPasLLMJobManager }
     TPasLLMJobManagerWorkerThread=class(TPasMPThread)
      private
       fPasLLM:TPasLLM;
       fJobManager:TPasLLMJobManager;
      protected
       procedure Execute; override;
      public
       constructor Create(const aJobManager:TPasLLMJobManager); reintroduce;
       destructor Destroy; override;
     end;

     TPasLLMJobManagerWorkerThreads=array of TPasLLMJobManagerWorkerThread;

     { TPasLLMJobManager }
     TPasLLMJobManager=class
      private
       fPasLLM:TPasLLM;
       fConfiguration:TPasLLMConfiguration;
       fModelInferenceInstance:TPasLLMModelInferenceInstance;
       fWorkerThreads:TPasLLMJobManagerWorkerThreads;
       fLock:TPasMPSlimReaderWriterLock;
       fJob:TPasLLMJobManagerJob;
       fStartedThreads:TPasMPInt32;
       fStoppedThreads:TPasMPInt32;
       fWakeUpConditionVariableLock:TPasMPConditionVariableLock;
       fWakeUpConditionVariable:TPasMPConditionVariable;
       fAwareConditionVariableLock:TPasMPConditionVariableLock;
       fAwareConditionVariable:TPasMPConditionVariable;
       fSleepConditionVariableLock:TPasMPConditionVariableLock;
       fSleepConditionVariable:TPasMPConditionVariable;
       fWakeUpGeneration:TPasMPUInt64;
       procedure WakeUpThreads;
       procedure WaitForThreads;
      public
       constructor Create(const aModelInferenceInstance:TPasLLMModelInferenceInstance); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
       procedure Execute(const aJobMethod:TPasLLMJobManagerJobMethod;const aData:Pointer);
     end;

     { TPasLLM }
     TPasLLM=class
      private
       fPasMPInstance:TPasMP;
       fRandomState:TPasLLMUInt64; // The random state for the random number generator
       function GetRandomUInt32:TPasLLMUInt32; // Get a random unsigned 32-bit integer
       function GetRandomFloat:TPasLLMFloat; // Get a random float in the range
      public
       constructor Create(const aPasMPInstance:TPasMP=nil); reintroduce;
       destructor Destroy; override;
      published
       property PasMPInstance:TPasMP read fPasMPInstance;
     end;

const PasLLMBaseDataTypes:array[TPasLLMBaseDataType] of TPasLLMDataTypeData=
       (
        (Name:'F32';Size:4;Bits:32;GroupSize:1;GroupBytes:4), // 32-bit float
        (Name:'F16';Size:2;Bits:16;GroupSize:1;GroupBytes:2), // 16-bit float
        (Name:'BF16';Size:2;Bits:16;GroupSize:1;GroupBytes:2), // 16-bit bfloat
        (Name:'F8_E5M2';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit float E5M2
        (Name:'F8_E4M3';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit float E4M3
        (Name:'I64';Size:8;Bits:64;GroupSize:1;GroupBytes:8), // 64-bit signed integer
        (Name:'I32';Size:4;Bits:32;GroupSize:1;GroupBytes:4), // 32-bit signed integer
        (Name:'I16';Size:2;Bits:16;GroupSize:1;GroupBytes:2), // 16-bit signed integer
        (Name:'I8';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit signed integer
        (Name:'U8';Size:1;Bits:8;GroupSize:1;GroupBytes:1) // 8-bit unsigned integer
       );

      PasLLMTensorDataTypes:array[TPasLLMTensorDataType] of TPasLLMDataTypeData=
       (
        (Name:'Unknown';Size:0;Bits:0;GroupSize:0;GroupBytes:0),
        (Name:'I8';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit signed integer
        (Name:'U8';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit unsigned integer
        (Name:'Q3F8';Size:0;Bits:4;GroupSize:8;GroupBytes:4), // 3-bit 8x values with fp8e5m2 scale
        (Name:'Q6F16';Size:1;Bits:8;GroupSize:8;GroupBytes:8), // 6-bit 8x values with fp16 scale
        (Name:'Q7F8';Size:1;Bits:8;GroupSize:8;GroupBytes:8), // 7-bit 8x values with fp8e5m2 scale
        (Name:'Q40';Size:0;Bits:4;GroupSize:32;GroupBytes:18), // 4-bit quantized float
        (Name:'Q40NL';Size:0;Bits:4;GroupSize:32;GroupBytes:18), // 4-bit quantized float (non-linear)
        (Name:'Q41NL';Size:0;Bits:4;GroupSize:32;GroupBytes:18), // 4-bit quantized float (non-linear)
        (Name:'Q42NL';Size:0;Bits:4;GroupSize:32;GroupBytes:18), // 4-bit quantized float (non-linear)
        (Name:'Q43NL';Size:0;Bits:4;GroupSize:32;GroupBytes:19), // 4-bit quantized float (non-linear)
        (Name:'Q80';Size:1;Bits:8;GroupSize:32;GroupBytes:34), // 8-bit quantized float
        (Name:'F8_E4M3';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit float E4M3
        (Name:'F8_E5M2';Size:1;Bits:8;GroupSize:1;GroupBytes:1), // 8-bit float E5M2
        (Name:'BF16';Size:2;Bits:16;GroupSize:1;GroupBytes:2), // 16-bit bfloat
        (Name:'F16';Size:2;Bits:16;GroupSize:1;GroupBytes:2), // 16-bit float
        (Name:'F32';Size:4;Bits:32;GroupSize:1;GroupBytes:4) // 32-bit float
       );

{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
const PasLLMCPUFeatures_X86_F16C_Mask=1 shl 0;
      PasLLMCPUFeatures_X86_SSE42_Mask=1 shl 1;
      PasLLMCPUFeatures_X86_PCLMUL_Mask=1 shl 2;
      PasLLMCPUFeatures_X86_AVX_Mask=1 shl 3;
      PasLLMCPUFeatures_X86_AVX2_Mask=1 shl 4;
      PasLLMCPUFeatures_X86_FMA3_Mask=1 shl 5;

type TPasLLMCPUFeatures=TPasLLMUInt32;

var PasLLMCPUFeatures:TPasLLMCPUFeatures=0;
{$ifend}

var FloatToHalfFloatBaseTable:array[0..511] of TPasLLMUInt16;
    FloatToHalfFloatShiftTable:array[0..511] of TPasLLMUInt8;

    HalfFloatToFloatMantissaTable:array[0..2047] of TPasLLMUInt32;
    HalfFloatToFloatExponentTable:array[0..63] of TPasLLMUInt32;
    HalfFloatToFloatOffsetTable:array[0..63] of TPasLLMUInt32;

    // Tables for 8-bit floating point formats, just simple lookup tables, since 8-bit are just 256 values
    FP8E5M2ToFloat32Table:array[0..255] of TPasLLMFloat; // Table for converting FP8 E5M2 and E4M3 to float32
    FP8E4M3ToFloat32Table:array[0..255] of TPasLLMFloat; // Table for converting FP8 E5M2 and E4M3 to float32

    // Tables for multiplying FP8 E5M2 and E4M3 with Q80 values, used for quantized matrix multiplication
    FP8E5M2FP8E5M2MulTable:array[0..255,0..255] of TPasLLMFloat; // Table for multiplying FP8 E5M2 values
    FP8E5M2Q80MulTable:array[0..255,0..255] of TPasLLMFloat; // Table for multiplying FP8 E5M2 with Q80 values
    FP8E4M3Q80MulTable:array[0..255,0..255] of TPasLLMFloat; // Table for multiplying FP8 E4M3 with Q80 values

function FlushNaNToZero(const aValue:TPasLLMFloat):TPasLLMFloat; inline;

function UTF8Validate(const aString:TPasLLMUTF8String):boolean;
function UTF8Correct(const aString:TPasLLMUTF8String):TPasLLMUTF8String;

function ConvertBFloat16ToFloat32(const aValue:TPasLLMUInt16):TPasLLMFloat; inline;
function ConvertFloat32ToBFloat16(const aValue:TPasLLMFloat):TPasLLMUInt16; inline;

function ConvertFloat16ToFloat32(const aValue:TPasLLMUInt16):TPasLLMFloat; inline;
function ConvertFloat32ToFloat16(const aValue:TPasLLMFloat):TPasLLMUInt16; inline;

function ConvertFP8E5M2ToFloat32(const aValue:TPasLLMUInt8):TPasLLMFloat;
function ConvertFloat32ToFP8E5M2(const aValue:TPasLLMFloat):TPasLLMUInt8;

function ConvertFP8E4M3ToFloat32(const aValue:TPasLLMUInt8):TPasLLMFloat;
function ConvertFloat32ToFP8E4M3(const aValue:TPasLLMFloat):TPasLLMUInt8;

function ConvertQ3F8ToFloat32(const aValue,aIndex:TPasLLMUInt32):TPasLLMFloat;
function ConvertFloat32ToQ3F8(const aValue0:TPasLLMFloat=0.0;
                              const aValue1:TPasLLMFloat=0.0;
                              const aValue2:TPasLLMFloat=0.0;
                              const aValue3:TPasLLMFloat=0.0;
                              const aValue4:TPasLLMFloat=0.0;
                              const aValue5:TPasLLMFloat=0.0;
                              const aValue6:TPasLLMFloat=0.0;
                              const aValue7:TPasLLMFloat=0.0):TPasLLMUInt32;

function ConvertQ6F16ToFloat32(const aValue:TPasLLMUInt64;const aIndex:TPasLLMUInt32):TPasLLMFloat;
function ConvertFloat32ToQ6F16(const aValue0:TPasLLMFloat=0.0;
                               const aValue1:TPasLLMFloat=0.0;
                               const aValue2:TPasLLMFloat=0.0;
                               const aValue3:TPasLLMFloat=0.0;
                               const aValue4:TPasLLMFloat=0.0;
                               const aValue5:TPasLLMFloat=0.0;
                               const aValue6:TPasLLMFloat=0.0;
                               const aValue7:TPasLLMFloat=0.0):TPasLLMUInt64;

function ConvertQ7F8ToFloat32(const aValue:TPasLLMUInt64;const aIndex:TPasLLMUInt32):TPasLLMFloat;
function ConvertFloat32ToQ7F8(const aValue0:TPasLLMFloat=0.0;
                              const aValue1:TPasLLMFloat=0.0;
                              const aValue2:TPasLLMFloat=0.0;
                              const aValue3:TPasLLMFloat=0.0;
                              const aValue4:TPasLLMFloat=0.0;
                              const aValue5:TPasLLMFloat=0.0;
                              const aValue6:TPasLLMFloat=0.0;
                              const aValue7:TPasLLMFloat=0.0):TPasLLMUInt64;

function IntLog2(x:TPasLLMUInt32):TPasLLMUInt32;
function IntLog264(x:TPasLLMUInt64):TPasLLMUInt32;

function DecodeQ40NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; inline;
function DecodeQ40NLValueNibble(const aValue:TPasLLMInt32):TPasLLMFloat; inline;
function EncodeQ40NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; inline;
function EncodeQ40NLValueNibble(const aValue:TPasLLMFloat):TPasLLMInt32; inline;

function DecodeQ41NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; inline;
function DecodeQ41NLValueNibble(const aValue:TPasLLMInt32):TPasLLMFloat; inline;
function EncodeQ41NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; inline;
function EncodeQ41NLValueNibble(const aValue:TPasLLMFloat):TPasLLMInt32; inline;

function DecodeQ42NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat; inline;
function DecodeQ42NLValueNibble(const aValue:TPasLLMInt32;const aCurve:TPasLLMFloat):TPasLLMFloat; inline;
function EncodeQ42NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
function EncodeQ42NLValueNibble(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMInt32;

function DecodeQ43NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat; inline;
function DecodeQ43NLValueNibble(const aValue:TPasLLMInt32;const aCurve:TPasLLMFloat):TPasLLMFloat; inline;
function EncodeQ43NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
function EncodeQ43NLValueNibble(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMInt32;

function TPinjaChatTemplateThinkModeToString(const aThinkMode:TPinjaChatTemplateThinkMode):TPasLLMUTF8String;
function StringToTPinjaChatTemplateThinkMode(const aThinkModeString:TPasLLMUTF8String):TPinjaChatTemplateThinkMode;

implementation

uses Generics.Defaults;

const Q40NLLookUpTable:array[0..15] of TPasLLMInt8=(-127,-127,-101,-78,-57,-39,-23,-10,0,10,23,39,57,78,101,127);
      Q40NLInverseScale=1.0/127.0;

      Q41NLLookUpTable:array[0..15] of TPasLLMInt8=(-127,-127,-93,-65,-41,-23,-10,-3,0,3,10,23,41,65,93,127);
      Q41NLInverseScale=1.0/127.0;

                                           //0 1 2 3 4 5 6 7 8 9 a b c d e f
     {UTF8CharSteps:array[AnsiChar] of TPasLLMUInt8=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
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

      UTF8DFACharClasses:array[AnsiChar] of TPasLLMUInt8=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
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

      UTF8DFATransitions:array[TPasLLMUInt8] of TPasLLMUInt8=(0,16,32,48,80,128,112,16,16,16,64,96,16,16,16,16,
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

      HexChars:array[0..15] of AnsiChar=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');

function FlushNaNToZero(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 if (PPasLLMUInt32(Pointer(@aValue))^ and $7ff00000)>$7f800000 then begin
  result:=0.0;
 end else begin
  result:=aValue;
 end;
end;

function UInt64ToString(const aValue:TPasLLMUInt64):TPasLLMUTF8String;
begin
 result:=HexChars[(aValue shr 60) and $0f]+
         HexChars[(aValue shr 56) and $0f]+
         HexChars[(aValue shr 52) and $0f]+
         HexChars[(aValue shr 48) and $0f]+
         HexChars[(aValue shr 44) and $0f]+
         HexChars[(aValue shr 40) and $0f]+
         HexChars[(aValue shr 36) and $0f]+
         HexChars[(aValue shr 32) and $0f]+
         HexChars[(aValue shr 28) and $0f]+
         HexChars[(aValue shr 24) and $0f]+
         HexChars[(aValue shr 20) and $0f]+
         HexChars[(aValue shr 16) and $0f]+
         HexChars[(aValue shr 12) and $0f]+
         HexChars[(aValue shr 8) and $0f]+
         HexChars[(aValue shr 4) and $0f]+
         HexChars[(aValue shr 0) and $0f];
end;

function StringToUInt64(const aString:TPasLLMUTF8String):TPasLLMUInt64;
var Index:TPasLLMInt32;
    c:AnsiChar;
begin
 result:=0;
 for Index:=1 to length(aString) do begin
  c:=aString[Index];
  case c of
   '0'..'9':begin
    result:=(result shl 4) or (TPasLLMUInt8(c)-TPasLLMUInt8(AnsiChar('0')));
   end;
   'a'..'f':begin
    result:=(result shl 4) or ((TPasLLMUInt8(c)-TPasLLMUInt8(AnsiChar('a')))+10);
   end;
   'A'..'F':begin
    result:=(result shl 4) or ((TPasLLMUInt8(c)-TPasLLMUInt8(AnsiChar('A')))+10);
   end;
  end;
 end;
end;

function GetNextUTF8Char(const aString:PPasLLMRawByteChar;const aStringLength:TPasLLMInt32;var aCodeUnit:TPasLLMInt32):TPasLLMUInt32;
var StartCodeUnit,Value,CharClass,State:TPasLLMUInt32;
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

function GetNextUTF8CharFallback(const aString:TPasLLMUTF8String;const aCodeUnit:TPasLLMInt32;out aCodePoint:TPasLLMUInt32):TPasLLMInt32;
var CodeUnit,StartCodeUnit:TPasLLMInt32;
    Value,CharClass,State:TPasLLMUInt32;
begin
 result:=0;
 aCodePoint:=0;
 if (aCodeUnit>=1) and (aCodeUnit<=length(aString)) then begin
  StartCodeUnit:=aCodeUnit;
  State:=ucACCEPT;
  for CodeUnit:=aCodeUnit to length(aString) do begin
   Value:=TPasLLMUInt8(TPasLLMRawByteChar(aString[CodeUnit]));
   CharClass:=UTF8DFACharClasses[TPasLLMRawByteChar(Value)];
   if State=ucACCEPT then begin
    aCodePoint:=Value and ($ff shr CharClass);
   end else begin
    aCodePoint:=(aCodePoint shl 6) or (Value and $3f);
   end;
   inc(result);
   State:=UTF8DFATransitions[State+CharClass];
   if State<=ucERROR then begin
    break;
   end;
  end;
  if State<>ucACCEPT then begin
   aCodePoint:=TPasLLMUInt8(TPasLLMRawByteChar(aString[StartCodeUnit]));
   result:=1;
  end;
 end;
end;

function UTF8Validate(const aString:TPasLLMUTF8String):boolean;
var CodeUnit:TPasLLMInt32;
    State:TPasLLMUInt32;
begin
 State:=ucACCEPT;
 for CodeUnit:=1 to length(aString) do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[aString[CodeUnit]]];
  if State=ucERROR then begin
   result:=false;
   exit;
  end;
 end;
 result:=State=ucACCEPT;
end;

function UTF8Correct(const aString:TPasLLMUTF8String):TPasLLMUTF8String;
var CodeUnit,Len,ResultLen:TPasLLMInt32;
    StartCodeUnit,Value,CharClass,State,CharValue:TPasLLMUInt32;
    Data:PPasLLMRawByteChar;
begin
 if (length(aString)=0) or UTF8Validate(aString) then begin
  result:=aString;
 end else begin
  result:='';
  CodeUnit:=1;
  Len:=length(aString);
  SetLength(result,Len*{$ifdef PasLLMStrictUTF8}4{$else}6{$endif});
  Data:=@result[1];
  ResultLen:=0;
  while CodeUnit<=Len do begin
   StartCodeUnit:=CodeUnit;
   State:=ucACCEPT;
   CharValue:=0;
   while CodeUnit<=Len do begin
    Value:=TPasLLMUInt8(TPasLLMRawByteChar(aString[CodeUnit]));
    inc(CodeUnit);
    CharClass:=UTF8DFACharClasses[TPasLLMRawByteChar(Value)];
    if State=ucACCEPT then begin
     CharValue:=Value and ($ff shr CharClass);
    end else begin
     CharValue:=(CharValue shl 6) or (Value and $3f);
    end;
    State:=UTF8DFATransitions[State+CharClass];
    if State<=ucERROR then begin
     break;
    end;
   end;
   if State<>ucACCEPT then begin
    CharValue:=TPasLLMUInt8(TPasLLMRawByteChar(aString[StartCodeUnit]));
    CodeUnit:=StartCodeUnit+1;
   end;
   if CharValue<=$7f then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8(CharValue));
    inc(ResultLen);
   end else if CharValue<=$7ff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($c0 or ((CharValue shr 6) and $1f)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,2);
{$ifdef PasLLMStrictUTF8}
   end else if CharValue<=$d7ff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$dfff then begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
{$endif}
   end else if CharValue<=$ffff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$1fffff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($f0 or ((CharValue shr 18) and $07)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+2]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+3]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,4);
{$ifndef PasLLMStrictUTF8}
   end else if CharValue<=$3ffffff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($f8 or ((CharValue shr 24) and $03)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+2]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+3]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+4]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,5);
   end else if CharValue<=$7fffffff then begin
    Data[ResultLen]:=TPasLLMRawByteChar(TPasLLMUInt8($fc or ((CharValue shr 30) and $01)));
    Data[ResultLen+1]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 24) and $3f)));
    Data[ResultLen+2]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+3]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+4]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+5]:=TPasLLMRawByteChar(TPasLLMUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,6);
{$endif}
   end else begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
   end;
  end;
  SetLength(result,ResultLen);
 end;
end;

// Generate the lookup tables for half-float conversion in both directions
procedure GenerateHalfFloatLookUpTables;
var i,e:TPasLLMInt32;
    Mantissa,Exponent:TPasLLMUInt32;
begin
 for i:=0 to 255 do begin
  e:=i-127;
  case e of
   -127..-25:begin
    // Very small numbers maps to zero
    FloatToHalfFloatBaseTable[i or $000]:=$0000;
    FloatToHalfFloatBaseTable[i or $100]:=$8000;
    FloatToHalfFloatShiftTable[i or $000]:=24;
    FloatToHalfFloatShiftTable[i or $100]:=24;
   end;
   -24..-15:begin
    // Small numbers maps to denormals
    FloatToHalfFloatBaseTable[i or $000]:=($0400 shr ((-e)-14)) or $0000;
    FloatToHalfFloatBaseTable[i or $100]:=($0400 shr ((-e)-14)) or $8000;
    FloatToHalfFloatShiftTable[i or $000]:=(-e)-1;
    FloatToHalfFloatShiftTable[i or $100]:=(-e)-1;
   end;
   -14..15:begin
    // Normal numbers just loses precision
    FloatToHalfFloatBaseTable[i or $000]:=((e+15) shl 10) or $0000;
    FloatToHalfFloatBaseTable[i or $100]:=((e+15) shl 10) or $8000;
    FloatToHalfFloatShiftTable[i or $000]:=13;
    FloatToHalfFloatShiftTable[i or $100]:=13;
   end;
   16..127:begin
    // Large numbers maps to infinity
    FloatToHalfFloatBaseTable[i or $000]:=$7c00;
    FloatToHalfFloatBaseTable[i or $100]:=$fc00;
    FloatToHalfFloatShiftTable[i or $000]:=24;
    FloatToHalfFloatShiftTable[i or $100]:=24;
   end;
   else begin
    // Infinity and NaN's stay infinity and NaN's
    FloatToHalfFloatBaseTable[i or $000]:=$7c00;
    FloatToHalfFloatBaseTable[i or $100]:=$fc00;
    FloatToHalfFloatShiftTable[i or $000]:=13;
    FloatToHalfFloatShiftTable[i or $100]:=13;
   end;
  end;
 end;
 begin
  begin
   HalfFloatToFloatMantissaTable[0]:=0;
   for i:=1 to 1023 do begin
    Mantissa:=i shl 13;
    Exponent:=0;
    while (Mantissa and $00800000)=0 do begin // While not normalized
     dec(Exponent,$00800000);                 // Decrement exponent by 1 shl 23
     Mantissa:=Mantissa shl 1;                // Shift mantissa
    end;
    Mantissa:=Mantissa and not $00800000;     // Clear leading 1 bit
    inc(Exponent,$38800000);                  // Adjust bias by (127-14) shl 23
    HalfFloatToFloatMantissaTable[i]:=Mantissa or Exponent;
   end;
   for i:=1024 to 2047 do begin
    HalfFloatToFloatMantissaTable[i]:=TPasLLMUInt32($38000000)+TPasLLMUInt32(TPasLLMUInt32(i-1024) shl 13);
   end;
  end;
  begin
   HalfFloatToFloatExponentTable[0]:=0;
   for i:=1 to 30 do begin
    HalfFloatToFloatExponentTable[i]:=i shl 23;
   end;
   HalfFloatToFloatExponentTable[31]:=$47800000;
   HalfFloatToFloatExponentTable[32]:=0;
   for i:=33 to 62 do begin
    HalfFloatToFloatExponentTable[i]:=TPasLLMUInt32(TPasLLMUInt32(i-32) shl 23) or TPasLLMUInt32($80000000);
   end;
   HalfFloatToFloatExponentTable[63]:=$c7800000;
  end;
  begin
   HalfFloatToFloatOffsetTable[0]:=0;
   for i:=1 to 31 do begin
    HalfFloatToFloatOffsetTable[i]:=1024;
   end;
   HalfFloatToFloatOffsetTable[32]:=0;
   for i:=33 to 63 do begin
    HalfFloatToFloatOffsetTable[i]:=1024;
   end;
  end;
 end;
end;

// BFloat16 to Float32 conversion, bfloat16 is just a truncated float32, so we can just convert it by shifting the bits
function ConvertBFloat16ToFloat32(const aValue:TPasLLMUInt16):TPasLLMFloat;
var Casted:TPasLLMUInt32;
begin
 Casted:=TPasLLMUInt32(aValue) shl 16;
 result:=TPasLLMFloat(Pointer(@Casted)^);
end;

// Float32 to BFloat16 conversion, bfloat16 is just a truncated float32, so we can just convert it by shifting the bits
function ConvertFloat32ToBFloat16(const aValue:TPasLLMFloat):TPasLLMUInt16;
var CastedValue:TPasLLMUInt32 absolute aValue;
begin
 result:=TPasLLMUInt16(CastedValue shr 16);
end;

// Float16 to Float32 conversion, float16 is a half-precision floating point format, we need to convert it to float32
// This is done by looking up the base and shift values for the exponent and mantissa
// and combining them to form the float32 representation
function ConvertFloat16ToFloat32(const aValue:TPasLLMUInt16):TPasLLMFloat;
var f:TPasLLMUInt32;
begin
 f:=HalfFloatToFloatMantissaTable[HalfFloatToFloatOffsetTable[aValue shr 10]+(aValue and $3ff)]+
    HalfFloatToFloatExponentTable[aValue shr 10];
 result:=TPasLLMFloat(pointer(@f)^);
end;

// Float32 to Float16 conversion, float16 is a half-precision floating point format, we need to convert it from float32
// This is done by looking up the base and shift values for the exponent and mantissa
// and combining them to form the float16 representation
function ConvertFloat32ToFloat16(const aValue:TPasLLMFloat):TPasLLMUInt16;
var CastedValue:TPasLLMUInt32 absolute aValue;
begin
 result:=FloatToHalfFloatBaseTable[CastedValue shr 23]+TPasLLMUInt16((CastedValue and $007fffff) shr FloatToHalfFloatShiftTable[CastedValue shr 23]);
end;

// Convert FP8E5M2 to Float32
function ConvertFP8E5M2ToFloat32(const aValue:TPasLLMUInt8):TPasLLMFloat;
var Sign,Exponent,Mantissa,Casted,Shift:TPasLLMUInt32;
begin
 Sign:=TPasLLMUInt32(aValue) and $80;
 Exponent:=(TPasLLMUInt32(aValue) shr 2) and $1f;
 Mantissa:=TPasLLMUInt32(aValue) and $03;
 if Exponent=$1f then begin
  if Mantissa<>0 then begin
   // NaN
   Casted:=TPasLLMUInt32($7fc00000) or TPasLLMUInt32(Sign shl 24);
  end else begin
   // Infinity
   Casted:=TPasLLMUInt32($7f800000) or TPasLLMUInt32(Sign shl 24);
  end;
 end else if Exponent=0 then begin
  if Mantissa=0 then begin
   // Zero
   Casted:=TPasLLMUInt32(Sign shl 24);
  end else begin
   // Denormalized number
   Shift:=3-((TPasMPMath.BitScanReverse(Mantissa)+1) and 3);
   Casted:=TPasLLMUInt32(((113-Shift)) shl 23) or (TPasLLMUInt32((Mantissa shl Shift) and 3) shl 21) or TPasLLMUInt32(Sign shl 24);
  end;
 end else begin
  // Normalized number
  Casted:=TPasLLMUInt32((Exponent+112) shl 23)+TPasLLMUInt32(Mantissa shl 21)+TPasLLMUInt32(Sign shl 24);
 end;
 result:=TPasLLMFloat(pointer(@Casted)^);
end;

// Convert Float32 to FP8E5M2
function ConvertFloat32ToFP8E5M2(const aValue:TPasLLMFloat):TPasLLMUInt8;
var CastedValue:TPasLLMUInt32 absolute aValue;
    Sign,Mantissa,Offset:TPasLLMUInt32;
    Exponent:TPasLLMInt32;
    IsDenormal,RoundUp:Boolean;
begin
 Sign:=(CastedValue shr 24) and $80;
 result:=Sign;
 if IsNaN(aValue) then begin
  // NaN
  result:=result or $7e;
 end else if abs(aValue)>=61440.0 then begin
  // Infinity
  result:=result or $7c;
 end else begin
  Exponent:=((CastedValue shr 23) and $ff)-112; // Get the exponent and adjust it
  if (CastedValue=0) or (Exponent<-2) then begin
   // Zero or underflow
   // Do nothing, result is already 0 with sign bit
  end else begin
   Mantissa:=CastedValue and $007fffff;
   IsDenormal:=Exponent<=0;
   RoundUp:=false;
   if IsDenormal then begin
    Offset:=1-Exponent;
    RoundUp:=(Mantissa and ((1 shl Offset)-1))<>0;
    Mantissa:=(Mantissa or $800000) shr Offset;
   end;
   RoundUp:=RoundUp or ((Mantissa and $2fffff)<>0);
   if ((Mantissa and $100000)<>0) and RoundUp then begin
    inc(Mantissa,$200000);
    if (Mantissa and $800000)<>0 then begin
     Mantissa:=0;
     inc(Exponent);
    end;
   end;
   if not IsDenormal then begin
    result:=result or (Exponent shl 2);
   end;
   result:=result or (Mantissa shr 21);
  end;
 end;
end;

// Convert FP8E4M3 to Float32
function ConvertFP8E4M3ToFloat32(const aValue:TPasLLMUInt8):TPasLLMFloat;
var Sign,Exponent,Mantissa,Casted,Shift:TPasLLMUInt32;
begin
 Sign:=TPasLLMUInt32(aValue) and $80;
 Exponent:=(TPasLLMUInt32(aValue) shr 3) and $0f;
 Mantissa:=TPasLLMUInt32(aValue) and $07;
 if (Exponent=$0f) and (Mantissa=$7) then begin
   // NaN
   Casted:=TPasLLMUInt32($7fc00000) or TPasLLMUInt32(Sign shl 24);
 end else if Exponent=0 then begin
  if Mantissa=0 then begin
   Casted:=TPasLLMUInt32(Sign shl 24); // Zero
  end else begin
   // Denormalized number
   Shift:=4-(TPasMPMath.BitScanReverse(Mantissa)+1);
   Casted:=TPasLLMUInt32(((121-Shift)) shl 23) or (TPasLLMUInt32((Mantissa shl Shift) and 7) shl 20) or TPasLLMUInt32(Sign shl 24);
  end;
 end else begin
  // Normalized number
  Casted:=TPasLLMUInt32((Exponent+120) shl 23) or (TPasLLMUInt32(Mantissa shl 20)) or TPasLLMUInt32(Sign shl 24);
 end;
 result:=TPasLLMFloat(pointer(@Casted)^);
end;

// Convert Float32 to FP8E4M3
function ConvertFloat32ToFP8E4M3(const aValue:TPasLLMFloat):TPasLLMUInt8;
var CastedValue:TPasLLMUInt32 absolute aValue;
    Sign,Mantissa,Offset:TPasLLMUInt32;
    Exponent:TPasLLMInt32;
    IsDenormal,RoundUp:Boolean;
begin
 Sign:=(CastedValue shr 24) and $80;
 if IsNaN(aValue) or (abs(aValue)>464.0) then begin
  result:=Sign or $7f; // NaN. FP8E4M3 does not support infinity
 end else begin
  Exponent:=((CastedValue shr 23) and $ff)-120; // Get the exponent and adjust it
  Mantissa:=CastedValue and $007fffff;
  result:=Sign;
  if Exponent<-3 then begin
   // Underflow, return zero
   // Do nothing, result is already 0 with sign bit
  end else begin
   IsDenormal:=Exponent<=0;
   RoundUp:=false;
   if IsDenormal then begin
    Offset:=1-Exponent;
    RoundUp:=(Mantissa and ((1 shl Offset)-1))<>0;
    Mantissa:=(Mantissa or $800000) shr Offset;
   end;
   RoundUp:=RoundUp or ((Mantissa and $17ffff)<>0);
   if ((Mantissa and $080000)<>0) and RoundUp then begin
    inc(Mantissa,$100000);
    if (Mantissa and $800000)<>0 then begin
     Mantissa:=0;
     inc(Exponent);
    end;
   end;
   if not IsDenormal then begin
    result:=result or (Exponent shl 3);
   end;
   result:=result or (Mantissa shr 20);
  end;
 end;
end;

// Convert Q3F8 to Float32
// Q3F8 is a quantized format, where 8 values are quantized into 32 bits, 3-bit normalized signed integer per value plus one shared fp8e5m2 scale factor
function ConvertQ3F8ToFloat32(const aValue,aIndex:TPasLLMUInt32):TPasLLMFloat;
begin
 result:=(TPasLLMInt32(TPasLLMUInt32(TPasLLMUInt32(aValue shr (8+((aIndex and 7)*3))) and $07))-4)* // Get the 3-bit value
         (FP8E5M2ToFloat32Table[aValue and $ff]*-0.25); // Scale it by the shared fp8e5m2 scale factor and by -0.25 (2 bits of precision excluding flipped sign bit)
//       (ConvertFP8E5M2ToFloat32(aValue and $ff)*-0.25); // Scale it by the shared fp8e5m2 scale factor and by -0.25 (2 bits of precision excluding flipped sign bit)
end;

// Convert Float32 to Q3F8
// Q3F8 is a quantized format, where 8 values are quantized into 32 bits, 3-bit normalized signed integer per value plus one shared fp8e5m2 scale factor
function ConvertFloat32ToQ3F8(const aValue0:TPasLLMFloat;
                             const aValue1:TPasLLMFloat;
                             const aValue2:TPasLLMFloat;
                             const aValue3:TPasLLMFloat;
                             const aValue4:TPasLLMFloat;
                             const aValue5:TPasLLMFloat;
                             const aValue6:TPasLLMFloat;
                             const aValue7:TPasLLMFloat):TPasLLMUInt32;
var MaxValue,Value,Value0,Value1,Value2,Value3,Value4,Value5,Value6,Value7:TPasLLMFloat;
begin

 // Find the maximum absolute value among the 8 values
 MaxValue:=abs(aValue0);
 Value:=abs(aValue1);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue2);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue3);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue4);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue5);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue6);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue7);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;

 // Ensuring that the maximum value has the right rounded quantization range by converting it to FP8E5M2 and back to Float32
 MaxValue:=FP8E5M2ToFloat32Table[ConvertFloat32ToFP8E5M2(MaxValue) and $ff];

 // If the maximum value is zero, we return zero in order to avoid division by zero
 if IsZero(MaxValue) then begin

  // Return zero
  result:=0;

 end else begin

  // Otherwise:

  // Normalize the values by the maximum value
  Value0:=aValue0/MaxValue;
  Value1:=aValue1/MaxValue;
  Value2:=aValue2/MaxValue;
  Value3:=aValue3/MaxValue;
  Value4:=aValue4/MaxValue;
  Value5:=aValue5/MaxValue;
  Value6:=aValue6/MaxValue;
  Value7:=aValue7/MaxValue;

  // Encode the Q3F8 32-bit value
  result:=(TPasLLMUInt32(ConvertFloat32ToFP8E5M2(MaxValue)) and $ff) or // Store the scale factor in the lowest byte as fp8e5m2
          ((TPasLLMUInt32(round(Min(Max(4.0-(Value0*4.0),0.0),7.0)) and $07) shl 8) or // Store the values as a 3-bit signed integers, quantized to the range -4 to 3
           (TPasLLMUInt32(round(Min(Max(4.0-(Value1*4.0),0.0),7.0)) and $07) shl 11) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value2*4.0),0.0),7.0)) and $07) shl 14) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value3*4.0),0.0),7.0)) and $07) shl 17) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value4*4.0),0.0),7.0)) and $07) shl 20) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value5*4.0),0.0),7.0)) and $07) shl 23) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value6*4.0),0.0),7.0)) and $07) shl 26) or
           (TPasLLMUInt32(round(Min(Max(4.0-(Value7*4.0),0.0),7.0)) and $07) shl 29));

  // Done

 end;

end;

// Convert Q6F16 to Float32
// Q6F16 is a quantized format, where 8 values are quantized into 64 bits, 6-bit normalized signed integer per value plus one shared fp16 scale factor
function ConvertQ6F16ToFloat32(const aValue:TPasLLMUInt64;const aIndex:TPasLLMUInt32):TPasLLMFloat;
begin
 result:=(TPasLLMInt64(TPasLLMUInt64(TPasLLMUInt64(aValue shr (16+((aIndex and 7)*6))) and $3f))-32)* // Get the 6-bit value
         (ConvertFloat16ToFloat32(aValue and $ffff)*-0.03125); // Scale it by the shared fp16 scale factor and by -0.03125 (5 bits of precision excluding flipped sign bit)
end;

// Convert Float32 to Q6F16
// Q6F16 is a quantized format, where 8 values are quantized into 64 bits, 6-bit normalized signed integer per value plus one shared fp16 scale factor
function ConvertFloat32ToQ6F16(const aValue0:TPasLLMFloat;
                               const aValue1:TPasLLMFloat;
                               const aValue2:TPasLLMFloat;
                               const aValue3:TPasLLMFloat;
                               const aValue4:TPasLLMFloat;
                               const aValue5:TPasLLMFloat;
                               const aValue6:TPasLLMFloat;
                               const aValue7:TPasLLMFloat):TPasLLMUInt64;
var MaxValue,Value,Value0,Value1,Value2,Value3,Value4,Value5,Value6,Value7:TPasLLMFloat;
begin

 // Find the maximum absolute value among the 8 values
 MaxValue:=abs(aValue0);
 Value:=abs(aValue1);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue2);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue3);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue4);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue5);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue6);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue7);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;

 // Ensuring that the maximum value has the right rounded quantization range by converting it to FP8E5M2 and back to Float32
 MaxValue:=ConvertFloat16ToFloat32(ConvertFloat32ToFloat16(MaxValue));

 // If the maximum value is zero, we return zero in order to avoid division by zero
 if IsZero(MaxValue) then begin

  // Return zero
  result:=0;

 end else begin

  // Otherwise:

  // Normalize the values by the maximum value
  Value0:=aValue0/MaxValue;
  Value1:=aValue1/MaxValue;
  Value2:=aValue2/MaxValue;
  Value3:=aValue3/MaxValue;
  Value4:=aValue4/MaxValue;
  Value5:=aValue5/MaxValue;
  Value6:=aValue6/MaxValue;
  Value7:=aValue7/MaxValue;

  // Encode the Q6F16 32-bit value
  result:=(TPasLLMUInt64(ConvertFloat32ToFloat16(MaxValue)) and $ffff) or // Store the scale factor in the lowest bytes as fp16
          ((TPasLLMUInt64(round(Min(Max(32.0-(Value0*32.0),0.0),64.0)) and $3f) shl (16+(0*6))) or // Store the values as a 7-bit signed integers, quantized to the range -64 to 63
           (TPasLLMUInt64(round(Min(Max(32.0-(Value1*32.0),0.0),64.0)) and $3f) shl (16+(1*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value2*32.0),0.0),64.0)) and $3f) shl (16+(2*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value3*32.0),0.0),64.0)) and $3f) shl (16+(3*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value4*32.0),0.0),64.0)) and $3f) shl (16+(4*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value5*32.0),0.0),64.0)) and $3f) shl (16+(5*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value6*32.0),0.0),64.0)) and $3f) shl (16+(6*6))) or
           (TPasLLMUInt64(round(Min(Max(32.0-(Value7*32.0),0.0),64.0)) and $3f) shl (16+(7*6))));

  // Done

 end;

end;

// Convert Q7F8 to Float32
// Q7F8 is a quantized format, where 8 values are quantized into 64 bits, 7-bit normalized signed integer per value plus one shared fp8e5m2 scale factor
function ConvertQ7F8ToFloat32(const aValue:TPasLLMUInt64;const aIndex:TPasLLMUInt32):TPasLLMFloat;
begin
 result:=(TPasLLMInt64(TPasLLMUInt64(TPasLLMUInt64(aValue shr (8+((aIndex and 7)*7))) and $7f))-64)* // Get the 7-bit value
         (FP8E5M2ToFloat32Table[aValue and $ff]*-0.015625); // Scale it by the shared fp8e5m2 scale factor and by -0.015625 (6 bits of precision excluding flipped sign bit)
end;

// Convert Float32 to Q7F8
// Q7F8 is a quantized format, where 8 values are quantized into 64 bits, 7-bit normalized signed integer per value plus one shared fp8e5m2 scale factor
function ConvertFloat32ToQ7F8(const aValue0:TPasLLMFloat;
                              const aValue1:TPasLLMFloat;
                              const aValue2:TPasLLMFloat;
                              const aValue3:TPasLLMFloat;
                              const aValue4:TPasLLMFloat;
                              const aValue5:TPasLLMFloat;
                              const aValue6:TPasLLMFloat;
                              const aValue7:TPasLLMFloat):TPasLLMUInt64;
var MaxValue,Value,Value0,Value1,Value2,Value3,Value4,Value5,Value6,Value7:TPasLLMFloat;
begin

 // Find the maximum absolute value among the 8 values
 MaxValue:=abs(aValue0);
 Value:=abs(aValue1);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue2);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue3);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue4);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue5);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue6);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;
 Value:=abs(aValue7);
 if MaxValue<Value then begin
  MaxValue:=Value;
 end;

 // Ensuring that the maximum value has the right rounded quantization range by converting it to FP8E5M2 and back to Float32
 MaxValue:=FP8E5M2ToFloat32Table[ConvertFloat32ToFP8E5M2(MaxValue) and $ff];

 // If the maximum value is zero, we return zero in order to avoid division by zero
 if IsZero(MaxValue) then begin

  // Return zero
  result:=0;

 end else begin

  // Otherwise:

  // Normalize the values by the maximum value
  Value0:=aValue0/MaxValue;
  Value1:=aValue1/MaxValue;
  Value2:=aValue2/MaxValue;
  Value3:=aValue3/MaxValue;
  Value4:=aValue4/MaxValue;
  Value5:=aValue5/MaxValue;
  Value6:=aValue6/MaxValue;
  Value7:=aValue7/MaxValue;

  // Encode the Q7F8 32-bit value
  result:=(TPasLLMUInt64(ConvertFloat32ToFP8E5M2(MaxValue)) and $ff) or // Store the scale factor in the lowest byte as fp8e5m2
          ((TPasLLMUInt64(round(Min(Max(64.0-(Value0*64.0),0.0),127.0)) and $7f) shl (8+(0*7))) or // Store the values as a 7-bit signed integers, quantized to the range -64 to 63
           (TPasLLMUInt64(round(Min(Max(64.0-(Value1*64.0),0.0),127.0)) and $7f) shl (8+(1*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value2*64.0),0.0),127.0)) and $7f) shl (8+(2*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value3*64.0),0.0),127.0)) and $7f) shl (8+(3*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value4*64.0),0.0),127.0)) and $7f) shl (8+(4*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value5*64.0),0.0),127.0)) and $7f) shl (8+(5*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value6*64.0),0.0),127.0)) and $7f) shl (8+(6*7))) or
           (TPasLLMUInt64(round(Min(Max(64.0-(Value7*64.0),0.0),127.0)) and $7f) shl (8+(7*7))));

  // Done

 end;

end;

// Generate the lookup tables for FP8E5M2 and FP8E4M3 conversion
procedure GenerateFP8ToFloat32LookUpTables;
var Index,OtherIndex:TPasLLMInt32;
begin

 // Generate the FP8* to Float32 conversion tables
 for Index:=0 to 255 do begin
  FP8E5M2ToFloat32Table[Index]:=ConvertFP8E5M2ToFloat32(TPasLLMUInt8(Index));
  FP8E4M3ToFloat32Table[Index]:=ConvertFP8E4M3ToFloat32(TPasLLMUInt8(Index));
 end;

 // Generate the FP8 multiplication tables
 for Index:=0 to 255 do begin // FP LUT index
  for OtherIndex:=0 to 255 do begin // uint8 => signed int8 => signed int32
   FP8E5M2FP8E5M2MulTable[Index,OtherIndex]:=FP8E5M2ToFloat32Table[TPasLLMUInt8(Index)]*FP8E5M2ToFloat32Table[TPasLLMUInt8(OtherIndex)];
   FP8E5M2Q80MulTable[Index,OtherIndex]:=FP8E5M2ToFloat32Table[TPasLLMUInt8(Index)]*TPasLLMInt32(TPasLLMInt8(TPasLLMUInt8(OtherIndex)));
   FP8E4M3Q80MulTable[Index,OtherIndex]:=FP8E4M3ToFloat32Table[TPasLLMUInt8(Index)]*TPasLLMInt32(TPasLLMInt8(TPasLLMUInt8(OtherIndex)));
  end;
 end;

end;

function DecodeQ40NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; 
begin
 result:=((abs(aValue)*aValue)+aValue)*0.5;
end;

function DecodeQ40NLValueNibble(const aValue:TPasLLMInt32):TPasLLMFloat;
{$ifdef fpc}
const Inv7:TPasLLMFloat=1.0/7.0;
begin
 result:=DecodeQ40NLValue(((aValue and $f)-8)*Inv7);
end;
{$else}
begin
 result:=DecodeQ40NLValue(((aValue and $f)-8)*(1.0/7.0));
end;
{$endif}

function EncodeQ40NLValue(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 result:=(sqrt((8.0*abs(aValue))+1)-1)*0.5;
 if aValue<0.0 then begin
  result:=-result; 
 end; 
end;

function EncodeQ40NLValueNibble(const aValue:TPasLLMFloat):TPasLLMInt32;
begin
 result:=round(EncodeQ40NLValue(aValue)*7.0);
 if result<-7 then begin
  result:=-7;
 end else if result>7 then begin
  result:=7;
 end;
 inc(result,8);
end;

function DecodeQ41NLValue(const aValue:TPasLLMFloat):TPasLLMFloat; 
begin
 result:=abs(aValue)*aValue;
end;

function DecodeQ41NLValueNibble(const aValue:TPasLLMInt32):TPasLLMFloat;
{$ifdef fpc}
const Inv7:TPasLLMFloat=1.0/7.0;
begin
 result:=DecodeQ41NLValue(((aValue and $f)-8)*Inv7);
end;
{$else}
begin
 result:=DecodeQ41NLValue(((aValue and $f)-8)*(1.0/7.0));
end;
{$endif}

function EncodeQ41NLValue(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 result:=sqrt(abs(aValue));
 if aValue<0.0 then begin
  result:=-result; 
 end; 
end;

function EncodeQ41NLValueNibble(const aValue:TPasLLMFloat):TPasLLMInt32;
begin
 result:=round(EncodeQ41NLValue(aValue)*7.0);
 if result<-7 then begin
  result:=-7;
 end else if result>7 then begin
  result:=7;
 end;
 inc(result,8);
end;

function DecodeQ42NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
begin
 result:=(aValue*(1.0-aCurve))+((abs(aValue)*aValue)*aCurve);
end;

function DecodeQ42NLValueNibble(const aValue:TPasLLMInt32;const aCurve:TPasLLMFloat):TPasLLMFloat;
{$ifdef fpc}
const Inv7:TPasLLMFloat=1.0/7.0;
begin
 result:=DecodeQ42NLValue(((aValue and $f)-8)*Inv7,aCurve);
end;
{$else}
begin
 result:=DecodeQ42NLValue(((aValue and $f)-8)*(1.0/7.0),aCurve);
end;
{$endif}

function EncodeQ42NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
var AbsValue,Sign,Value,Discriminant,b:TPasLLMFloat;
begin
 if abs(aCurve)<1e-6 then begin
  result:=aValue;
 end else begin
  if aValue<0.0 then begin
   AbsValue:=-aValue;
   Sign:=-1.0;
  end else begin
   AbsValue:=aValue;
   Sign:=1.0;
  end;
  if aCurve>=1.0 then begin
   // y = u^2
   Value:=sqrt(AbsValue);
  end else if aCurve<=-1.0 then begin
   // y = 2u - u^2 => u = 1 - sqrt(1 - y)
   Value:=1.0-sqrt(1.0-AbsValue);
  end else begin
   // Curve*Value^2 + (1-Curve)*Value - y = 0
   b:=1.0-aCurve;
   Discriminant:=(b*b)+(4.0*aCurve*AbsValue);
   if Discriminant<0.0 then begin
    Discriminant:=0.0; // guard tiny negatives
   end;
   Value:=(sqrt(Discriminant)-b)/(2.0*aCurve);
   if Value<0.0 then begin
    Value:=0.0;
   end else if Value>1.0 then begin
    Value:=1.0;
   end;
  end;
  result:=Sign*Value;
 end;
end;

function EncodeQ42NLValueNibble(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMInt32;
begin
 result:=round(EncodeQ42NLValue(aValue,aCurve)*7.0);
 if result<-7 then begin
  result:=-7;
 end else if result>7 then begin
  result:=7;
 end;
 inc(result,8);
end;

function DecodeQ43NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
begin
 result:=(aValue*(1.0-aCurve))+((abs(aValue)*aValue)*aCurve);
end;

function DecodeQ43NLValueNibble(const aValue:TPasLLMInt32;const aCurve:TPasLLMFloat):TPasLLMFloat;
{$ifdef fpc}
const Inv7:TPasLLMFloat=1.0/7.0;
begin
 result:=DecodeQ43NLValue(((aValue and $f)-8)*Inv7,aCurve);
end;
{$else}
begin
 result:=DecodeQ43NLValue(((aValue and $f)-8)*(1.0/7.0),aCurve);
end;
{$endif}

function EncodeQ43NLValue(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMFloat;
var AbsValue,Sign,Value,Discriminant,b:TPasLLMFloat;
begin
 if abs(aCurve)<1e-6 then begin
  result:=aValue;
 end else begin
  if aValue<0.0 then begin
   AbsValue:=-aValue;
   Sign:=-1.0;
  end else begin
   AbsValue:=aValue;
   Sign:=1.0;
  end;
  if aCurve>=1.0 then begin
   // y = u^2
   Value:=sqrt(AbsValue);
  end else if aCurve<=-1.0 then begin
   // y = 2u - u^2 => u = 1 - sqrt(1 - y)
   Value:=1.0-sqrt(1.0-AbsValue);
  end else begin
   // Curve*Value^2 + (1-Curve)*Value - y = 0
   b:=1.0-aCurve;
   Discriminant:=(b*b)+(4.0*aCurve*AbsValue);
   if Discriminant<0.0 then begin
    Discriminant:=0.0; // guard tiny negatives
   end;
   Value:=(sqrt(Discriminant)-b)/(2.0*aCurve);
   if Value<0.0 then begin
    Value:=0.0;
   end else if Value>1.0 then begin
    Value:=1.0;
   end;
  end;
  result:=Sign*Value;
 end;
end;

function EncodeQ43NLValueNibble(const aValue:TPasLLMFloat;const aCurve:TPasLLMFloat):TPasLLMInt32;
begin
 result:=round(EncodeQ43NLValue(aValue,aCurve)*7.0);
 if result<-7 then begin
  result:=-7;
 end else if result>7 then begin
  result:=7;
 end;
 inc(result,8);
end;

{$ifdef cpuamd64}
function AMD64DotProductQ3F8Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
     TAlign8xUInt32=record
      Values:array[0..7] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_4:TAlign16xUInt8=(Values:(128,0,128,4,128,8,128,12,0,0,0,0,0,0,0,0));
      LCPI0_1:TAlign8xUInt32=(Values:(8,11,14,17,20,23,26,29));
      LCPI0_2:TAlign8xUInt32=(Values:($3f800000,$3f400000,$3f000000,$3e800000,$80000000,$be800000,$bf000000,$bf400000));
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($3f800000);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  sub rsp, 104
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  test r8d, r8d
  jle @LBB0_1
  mov eax, r8d
  vpxor xmm0, xmm0, xmm0
  xor r8d, r8d
  vmovq xmm1, qword ptr [rip + LCPI0_4]
  vmovdqu ymm2, yword ptr [rip + LCPI0_1]
  vmovdqu ymm3, yword ptr [rip + LCPI0_2]
  vxorps xmm4, xmm4, xmm4
@LBB0_5:
  vpmovsxbd ymm6, qword ptr [rdx]
  vpmovsxbd ymm7, qword ptr [rdx + 8]
  vpmovsxbd ymm8, qword ptr [rdx + 16]
  vpmovsxbd ymm9, qword ptr [rdx + 24]
  vpinsrw xmm5, xmm0, word ptr [rdx + 32], 0
  vcvtph2ps xmm5, xmm5
  vbroadcastss ymm5, xmm5
  vcvtdq2ps ymm6, ymm6
  vcvtdq2ps ymm7, ymm7
  vcvtdq2ps ymm8, ymm8
  vmovdqu xmm10, dqword ptr [rcx]
  vpshufb xmm10, xmm10, xmm1
  vcvtph2ps xmm10, xmm10
  vpbroadcastd ymm11, dword ptr [rcx]
  vcvtdq2ps ymm9, ymm9
  vpsrlvd ymm11, ymm11, ymm2
  vpermd ymm11, ymm11, ymm3
  vmulps ymm6, ymm11, ymm6
  vpbroadcastd ymm11, dword ptr [rcx + 4]
  vpsrlvd ymm11, ymm11, ymm2
  vpermd ymm11, ymm11, ymm3
  vmulps ymm7, ymm11, ymm7
  vpbroadcastd ymm11, dword ptr [rcx + 8]
  vpsrlvd ymm11, ymm11, ymm2
  vpermd ymm11, ymm11, ymm3
  vmulps ymm8, ymm11, ymm8
  vpbroadcastd ymm11, dword ptr [rcx + 12]
  vpsrlvd ymm11, ymm11, ymm2
  vpermd ymm11, ymm11, ymm3
  vmulps ymm9, ymm11, ymm9
  vbroadcastss ymm11, xmm10
  vmulps ymm6, ymm11, ymm6
  vmovshdup xmm11, xmm10
  vbroadcastss ymm11, xmm11
  vmulps ymm7, ymm11, ymm7
  vshufpd xmm11, xmm10, xmm10, 1
  vbroadcastss ymm11, xmm11
  vfmadd213ps ymm11, ymm8, ymm6
  vshufps xmm6, xmm10, xmm10, 255
  vbroadcastss ymm6, xmm6
  vfmadd213ps ymm6, ymm9, ymm7
  vfmadd231ps ymm0, ymm5, ymm11
  vfmadd231ps ymm4, ymm5, ymm6
  add rdx, 34
  add r8, 32
  add rcx, 16
  cmp r8, rax
  jb @LBB0_5
  vaddps ymm0, ymm0, ymm4
  jmp @LBB0_3
@LBB0_1:
  vxorps xmm0, xmm0, xmm0
@LBB0_3:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vbroadcastss xmm1, dword ptr [rip + LCPI0_3]
  vdpps xmm0, xmm0, xmm1, 241
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  add rsp, 104
  vzeroupper
end;
{$endif}

function PascalDotProductQ3F8Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var CountGroups,GroupIndex,GroupRelativeIndex,Q3F8GroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt32;
    WGroup:PPasLLMUInt32;
    XGroup:PPasLLMUInt8;
    Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt32(@PPasLLMUInt8Array(aW)^[GroupIndex*(GroupSize shr 1)]); // Pointer to the current group in w (Q3F8)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0.0; // Initialize the sum for this group
  GroupRelativeIndex:=0;
  while GroupRelativeIndex<GroupSize do begin
   // Q3F8 is quantized in groups of 8, so we process 4 groups of 8 values at a time
   for Q3F8GroupRelativeIndex:=0 to 3 do begin
    // Calculate the dot product for the current group
    WValue:=PPasLLMUInt32(WGroup)^; inc(WGroup);
    Sum:=Sum+(
     ((TPasLLMInt32((WValue shr (8+(0*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[0])))+
     ((TPasLLMInt32((WValue shr (8+(1*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[1])))+
     ((TPasLLMInt32((WValue shr (8+(2*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[2])))+
     ((TPasLLMInt32((WValue shr (8+(3*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[3])))+
     ((TPasLLMInt32((WValue shr (8+(4*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[4])))+
     ((TPasLLMInt32((WValue shr (8+(5*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[5])))+
     ((TPasLLMInt32((WValue shr (8+(6*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[6])))+
     ((TPasLLMInt32((WValue shr (8+(7*3))) and $07)-4)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[7])))
    )*(FP8E5M2ToFloat32Table[WValue and $ff]*-0.25);
    inc(XGroup,8);
   end;
   inc(GroupRelativeIndex,32);
  end;
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^)); // Scale the sum and add it to the result
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ3F8F8E5M2(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
     TAlign8xUInt32=record
      Values:array[0..7] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_4:TAlign16xUInt8=(Values:(128,0,128,4,128,8,128,12,0,0,0,0,0,0,0,0));
      LCPI0_1:TAlign8xUInt32=(Values:(8,11,14,17,20,23,26,29));
      LCPI0_2:TAlign8xUInt32=(Values:($3f800000,$3f400000,$3f000000,$3e800000,$80000000,$be800000,$bf000000,$bf400000));
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($3f800000);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if true}
  sub rsp, 136
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  test r8d, r8d
  jle @LBB0_1
  mov eax, r8d
  vxorps xmm0, xmm0, xmm0
  xor r8d, r8d
  vmovq xmm1, qword ptr [rip + LCPI0_4]
  vmovdqu ymm2, yword ptr [rip + LCPI0_1]
  vmovdqu ymm3, yword ptr [rip + LCPI0_2]
  vxorps xmm4, xmm4, xmm4
  vxorps xmm5, xmm5, xmm5
  vxorps xmm6, xmm6, xmm6
@LBB0_5:
  vpmovzxbw ymm7, dqword ptr [rdx + r8]
  vpmovzxbw ymm8, dqword ptr [rdx + r8 + 16]
  vpsllw ymm9, ymm7, 8
  vcvtph2ps ymm10, xmm9
  vpsllw ymm7, ymm8, 8
  vextracti128 xmm8, ymm9, 1
  vcvtph2ps ymm11, xmm8
  vcvtph2ps ymm8, xmm7
  vmovdqu xmm9, dqword ptr [rcx]
  vpshufb xmm9, xmm9, xmm1
  vcvtph2ps xmm9, xmm9
  vpbroadcastd ymm12, dword ptr [rcx]
  vpsrlvd ymm12, ymm12, ymm2
  vpermd ymm12, ymm12, ymm3
  vbroadcastss ymm13, xmm9
  vmulps ymm12, ymm13, ymm12
  vfmadd231ps ymm0, ymm10, ymm12
  vpbroadcastd ymm10, dword ptr [rcx + 4]
  vpsrlvd ymm10, ymm10, ymm2
  vpermd ymm10, ymm10, ymm3
  vmovshdup xmm12, xmm9
  vbroadcastss ymm12, xmm12
  vmulps ymm10, ymm12, ymm10
  vfmadd231ps ymm4, ymm11, ymm10
  vpbroadcastd ymm10, dword ptr [rcx + 8]
  vpsrlvd ymm10, ymm10, ymm2
  vpermd ymm10, ymm10, ymm3
  vshufpd xmm11, xmm9, xmm9, 1
  vbroadcastss ymm11, xmm11
  vmulps ymm10, ymm11, ymm10
  vfmadd231ps ymm5, ymm8, ymm10
  vpbroadcastd ymm8, dword ptr [rcx + 12]
  vpsrlvd ymm8, ymm8, ymm2
  vpermd ymm8, ymm8, ymm3
  vshufps xmm9, xmm9, xmm9, 255
  vbroadcastss ymm9, xmm9
  vmulps ymm8, ymm9, ymm8
  vextracti128 xmm7, ymm7, 1
  vcvtph2ps ymm7, xmm7
  vfmadd231ps ymm6, ymm7, ymm8
  add r8, 32
  add rcx, 16
  cmp r8, rax
  jb @LBB0_5
  vaddps ymm1, ymm5, ymm6
  vaddps ymm0, ymm4, ymm0
  vaddps ymm0, ymm1, ymm0
  jmp @LBB0_3
@LBB0_1:
  vxorps xmm0, xmm0, xmm0
@LBB0_3:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vbroadcastss xmm1, dword ptr [rip + LCPI0_3]
  vdpps xmm0, xmm0, xmm1, 241
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  add rsp, 136
  vzeroupper
 {$else} 
  sub rsp, 104
  vmovdqa dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  test r8d, r8d
  jle @LBB0_1
  mov eax, r8d
  vxorps xmm2, xmm2, xmm2
  xor r8d, r8d
  vmovq xmm0, qword ptr [rip + LCPI0_4]
  vmovdqu ymm1, yword ptr [rip + LCPI0_1]
  vmovdqu ymm3, yword ptr [rip + LCPI0_2]
  vxorps xmm4, xmm4, xmm4
@LBB0_5:
  vpmovzxbw ymm5, dqword ptr [rdx + r8]
  vpmovzxbw ymm6, dqword ptr [rdx + r8 + 16]
  vpsllw ymm5, ymm5, 8
  vcvtph2ps ymm7, xmm5
  vextracti128 xmm5, ymm5, 1
  vcvtph2ps ymm5, xmm5
  vpsllw ymm6, ymm6, 8
  vcvtph2ps ymm8, xmm6
  vextracti128 xmm6, ymm6, 1
  vcvtph2ps ymm6, xmm6
  vmovdqu xmm9, dqword ptr [rcx]
  vpshufb xmm9, xmm9, xmm0
  vcvtph2ps xmm9, xmm9
  vpbroadcastd ymm10, dword ptr [rcx]
  vpsrlvd ymm10, ymm10, ymm1
  vpermd ymm10, ymm10, ymm3
  vpbroadcastd ymm11, dword ptr [rcx + 4]
  vmulps ymm7, ymm10, ymm7
  vpsrlvd ymm10, ymm11, ymm1
  vpermd ymm10, ymm10, ymm3
  vmulps ymm5, ymm10, ymm5
  vpbroadcastd ymm10, dword ptr [rcx + 8]
  vpsrlvd ymm10, ymm10, ymm1
  vpermd ymm10, ymm10, ymm3
  vmulps ymm8, ymm10, ymm8
  vpbroadcastd ymm10, dword ptr [rcx + 12]
  vpsrlvd ymm10, ymm10, ymm1
  vpermd ymm10, ymm10, ymm3
  vmulps ymm6, ymm10, ymm6
  vbroadcastss ymm10, xmm9
  vfmadd213ps ymm10, ymm7, ymm2
  vmovshdup xmm2, xmm9
  vbroadcastss ymm7, xmm2
  vfmadd213ps ymm7, ymm5, ymm4
  vshufpd xmm2, xmm9, xmm9, 1
  vbroadcastss ymm2, xmm2
  vfmadd213ps ymm2, ymm8, ymm10
  vshufps xmm4, xmm9, xmm9, 255
  vbroadcastss ymm4, xmm4
  vfmadd213ps ymm4, ymm6, ymm7
  add r8, 32
  add rcx, 16
  cmp r8, rax
  jb @LBB0_5
  vaddps ymm0, ymm2, ymm4
  jmp @LBB0_3
@LBB0_1:
  vxorps xmm0, xmm0, xmm0
@LBB0_3:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vbroadcastss xmm1, dword ptr [rip + LCPI0_3]
  vdpps xmm0, xmm0, xmm1, 241
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  add rsp, 104
  vzeroupper
{$ifend}
end;
{$endif}

function PascalDotProductQ3F8F8E5M2(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var CountGroups,GroupIndex,GroupRelativeIndex,Q3F8GroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt32;
    WGroup:PPasLLMUInt32;
    XGroup:PPasLLMUInt8;
    Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt32(@PPasLLMUInt8Array(aW)^[GroupIndex*(GroupSize shr 1)]); // Pointer to the current group in w (Q3F8)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*GroupSize]); // Pointer to the current group in x (F8E5M2)
  Sum:=0.0; // Initialize the sum for this group
  GroupRelativeIndex:=0;
  while GroupRelativeIndex<GroupSize do begin
   // Q3F8 is quantized in groups of 8, so we process 4 groups of 8 values at a time
   for Q3F8GroupRelativeIndex:=0 to 3 do begin
    // Calculate the dot product for the current group
    WValue:=PPasLLMUInt32(WGroup)^; inc(WGroup);
    Sum:=Sum+(
     ((TPasLLMInt32((WValue shr (8+(0*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[0]])+
     ((TPasLLMInt32((WValue shr (8+(1*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[1]])+
     ((TPasLLMInt32((WValue shr (8+(2*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[2]])+
     ((TPasLLMInt32((WValue shr (8+(3*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[3]])+
     ((TPasLLMInt32((WValue shr (8+(4*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[4]])+
     ((TPasLLMInt32((WValue shr (8+(5*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[5]])+
     ((TPasLLMInt32((WValue shr (8+(6*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[6]])+
     ((TPasLLMInt32((WValue shr (8+(7*3))) and $07)-4)*FP8E5M2ToFloat32Table[PPasLLMInt8Array(Pointer(XGroup))^[7]])
    )*(FP8E5M2ToFloat32Table[WValue and $ff]*-0.25);
    inc(XGroup,8);
   end;
   inc(GroupRelativeIndex,32);
  end;
  result:=result+Sum;
 end;
end;

function PascalDotProductQ6F16Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var CountGroups,GroupIndex,GroupRelativeIndex,Q6F16GroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt64;
    WGroup:PPasLLMUInt64;
    XGroup:PPasLLMUInt8;
    Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt64(@PPasLLMUInt8Array(aW)^[GroupIndex*GroupSize]); // Pointer to the current group in w (Q6F16)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0.0; // Initialize the sum for this group
  GroupRelativeIndex:=0;
  while GroupRelativeIndex<GroupSize do begin
   // Q6F16 is quantized in groups of 8, so we process 4 groups of 8 values at a time
   for Q6F16GroupRelativeIndex:=0 to 3 do begin
    // Calculate the dot product for the current group
    WValue:=PPasLLMUInt64(WGroup)^; inc(WGroup);
    Sum:=Sum+(
     ((TPasLLMInt32((WValue shr (16+(0*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[0])))+
     ((TPasLLMInt32((WValue shr (16+(1*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[1])))+
     ((TPasLLMInt32((WValue shr (16+(2*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[2])))+
     ((TPasLLMInt32((WValue shr (16+(3*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[3])))+
     ((TPasLLMInt32((WValue shr (16+(4*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[4])))+
     ((TPasLLMInt32((WValue shr (16+(5*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[5])))+
     ((TPasLLMInt32((WValue shr (16+(6*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[6])))+
     ((TPasLLMInt32((WValue shr (16+(7*6))) and $3f)-32)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[7])))
    )*(ConvertFloat16ToFloat32(WValue and $ffff)*-0.03125);
    inc(XGroup,8);
   end;
   inc(GroupRelativeIndex,32);
  end;
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^)); // Scale the sum and add it to the result
 end;
end;

function PascalDotProductQ7F8Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var CountGroups,GroupIndex,GroupRelativeIndex,Q7F8GroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt64;
    WGroup:PPasLLMUInt64;
    XGroup:PPasLLMUInt8;
    Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt64(@PPasLLMUInt8Array(aW)^[GroupIndex*GroupSize]); // Pointer to the current group in w (Q7F8)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0.0; // Initialize the sum for this group
  GroupRelativeIndex:=0;
  while GroupRelativeIndex<GroupSize do begin
   // Q7F8 is quantized in groups of 8, so we process 4 groups of 8 values at a time
   for Q7F8GroupRelativeIndex:=0 to 3 do begin
    // Calculate the dot product for the current group
    WValue:=PPasLLMUInt64(WGroup)^; inc(WGroup);
    Sum:=Sum+(
     ((TPasLLMInt32((WValue shr (8+(0*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[0])))+
     ((TPasLLMInt32((WValue shr (8+(1*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[1])))+
     ((TPasLLMInt32((WValue shr (8+(2*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[2])))+
     ((TPasLLMInt32((WValue shr (8+(3*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[3])))+
     ((TPasLLMInt32((WValue shr (8+(4*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[4])))+
     ((TPasLLMInt32((WValue shr (8+(5*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[5])))+
     ((TPasLLMInt32((WValue shr (8+(6*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[6])))+
     ((TPasLLMInt32((WValue shr (8+(7*7))) and $7f)-64)*TPasLLMInt32(TPasLLMInt8(PPasLLMInt8Array(Pointer(XGroup))^[7])))
    )*(FP8E5M2ToFloat32Table[WValue and $ff]*-0.015625);
    inc(XGroup,8);
   end;
   inc(GroupRelativeIndex,32);
  end;
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^)); // Scale the sum and add it to the result
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ40Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const NibbleMask:TPasLLMUInt8=TPasLLMUInt8($0f);                  // Nibble mask, keep lower nibbles
      Q4SignBias:TPasLLMUInt8=TPasLLMUInt8($f8);                 // 0..15 => −8..7 for sign/abs
      PairwiseWordSumOnes:TPasLLMUInt16=TPasLLMUInt16($0001);    // x*1 + y*1 pairwise sum
asm
{$ifndef fpc}
 .noframe
{$endif}
 lea eax,[r8+31]
 test r8d,r8d
 cmovns eax,r8d
 vpxor xmm0,xmm0, xmm0
 cmp r8d,32
 jl @EarlyExit
 sub rsp,40
 vmovdqa dqword ptr [rsp+16],xmm7
 vmovdqa dqword ptr [rsp],xmm6
 sar eax,5
 vpxor xmm0,xmm0,xmm0 
 vpbroadcastb ymm1,byte ptr [rip+NibbleMask]
 vpbroadcastb ymm2,byte ptr [rip+Q4SignBias]
 vpbroadcastw ymm3,word ptr [rip+PairwiseWordSumOnes]
@Loop:
 vmovdqu xmm4,dqword ptr [rcx]
 vpsrlw xmm5,xmm4,4
 vpunpckhbw xmm6,xmm4,xmm5
 vpunpcklbw xmm4,xmm4,xmm5
 vinserti128 ymm4,ymm4,xmm6,1
 vpand ymm4,ymm4,ymm1
 vpaddb ymm4,ymm4,ymm2
 vpinsrw xmm5,xmm0,word ptr [rcx+16],0
 vcvtph2ps xmm5,xmm5
 vpinsrw xmm6,xmm0,word ptr [rdx+32],0
 vcvtph2ps xmm6,xmm6
 vmovdqu ymm7,yword ptr [rdx]
 vmulss xmm5,xmm6,xmm5
 vbroadcastss ymm5,xmm5
 vpsignb ymm6,ymm4,ymm4
 vpsignb ymm4,ymm7,ymm4
 vpmaddubsw ymm4,ymm6,ymm4
 vpmaddwd ymm4,ymm4,ymm3
 vcvtdq2ps ymm4,ymm4
 vfmadd231ps ymm0,ymm5,ymm4
 add rcx,18
 add rdx,34
 dec eax
 jne @Loop
 vmovaps xmm6,dqword ptr [rsp]
 vmovaps xmm7,dqword ptr [rsp+16]
 add rsp,40
@EarlyExit:
 vextracti128 xmm1,ymm0,1
 vaddps xmm0,xmm1,xmm0
 vshufpd xmm1,xmm0,xmm0,1
 vaddps xmm0,xmm1,xmm0
 vmovshdup xmm1,xmm0
 vaddss xmm0,xmm0,xmm1
 vzeroupper
end;
{$endif}

function PascalDotProductQ40Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
      HalfGroupSize=GroupSize shr 1;
var CountGroups,GroupIndex,HalfGroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt8;
    WGroup,XGroup:PPasLLMUInt8;
    Scale:TPasLLMFloat;
    Sum:TPasLLMInt32;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aW)^[GroupIndex*(HalfGroupSize+2)]); // Pointer to the current group in w (Q40)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0; // Initialize the sum for this group
  for HalfGroupRelativeIndex:=0 to HalfGroupSize-1 do begin
   // Calculate the dot product for the current group
   WValue:=WGroup^; inc(WGroup);
   inc(Sum,((TPasLLMInt32(WValue and $0f)-8)*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^))); inc(XGroup);
   inc(Sum,((TPasLLMInt32(WValue shr 4)-8)*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^))); inc(XGroup);
  end;
  // Get the scale factors from the end of the groups
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(WGroup))^)*
         ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^);
  // Scale the sum and add it to the result
  result:=result+(Sum*Scale);
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ40NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign32xUInt8=record
      Values:array[0..31] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_1:TAlign32xUInt8=(Values:(129,129,155,178,199,217,233,246,0,10,23,39,57,78,101,127,
                                      129,129,155,178,199,217,233,246,0,10,23,39,57,78,101,127));
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_4:TPasLLMUInt8=TPasLLMUInt8($0f); 
      LCPI0_5:TPasLLMUInt16=TPasLLMUInt16($0001);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  lea eax, [r8 + 31]
  test r8d, r8d
  cmovns eax, r8d
  vpxor xmm0, xmm0, xmm0
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 56
  vmovdqa dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  sar eax, 5
  vpxor xmm0, xmm0, xmm0
  vpbroadcastb ymm1, byte ptr [rip + LCPI0_4]
  vmovdqu ymm2, yword ptr [rip + LCPI0_1]
  vmovss xmm3, dword ptr [rip + LCPI0_2]
  vpbroadcastw ymm4, word ptr [rip + LCPI0_5]
@LBB0_2:
  vmovdqu xmm5, dqword ptr [rcx]
  vpsrlw xmm6, xmm5, 4
  vpunpckhbw xmm7, xmm5, xmm6
  vpunpcklbw xmm5, xmm5, xmm6
  vinserti128 ymm5, ymm5, xmm7, 1
  vpand ymm5, ymm5, ymm1
  vpshufb ymm5, ymm2, ymm5
  vmovdqu ymm6, yword ptr [rdx]
  vpinsrw xmm7, xmm0, word ptr [rcx + 16], 0
  vcvtph2ps xmm7, xmm7
  vpinsrw xmm8, xmm0, word ptr [rdx + 32], 0
  vcvtph2ps xmm8, xmm8
  vmulss xmm7, xmm8, xmm7
  vmulss xmm7, xmm7, xmm3
  vbroadcastss ymm7, xmm7
  vpsignb ymm8, ymm5, ymm5
  vpsignb ymm5, ymm6, ymm5
  vpmaddubsw ymm5, ymm8, ymm5
  vpmaddwd ymm5, ymm5, ymm4
  vcvtdq2ps ymm5, ymm5
  vfmadd231ps ymm0, ymm7, ymm5
  add rcx, 18
  add rdx, 34
  dec eax
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 56
@LBB0_4:
  vextracti128 xmm1, ymm0, 1
  vaddps xmm0, xmm1, xmm0
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm1, xmm0
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  vzeroupper
end;
{$endif}

function PascalDotProductQ40NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
      HalfGroupSize=GroupSize shr 1;
var CountGroups,GroupIndex,HalfGroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt8;
    WGroup,XGroup:PPasLLMUInt8;
    Scale:TPasLLMFloat;
    Sum:TPasLLMInt32;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aW)^[GroupIndex*(HalfGroupSize+2)]); // Pointer to the current group in w (Q40)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0; // Initialize the sum for this group
  for HalfGroupRelativeIndex:=0 to HalfGroupSize-1 do begin
   // Calculate the dot product for the current group
   WValue:=WGroup^; inc(WGroup);
   inc(Sum,Q40NLLookUpTable[WValue and $0f]*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^)); inc(XGroup);
   inc(Sum,Q40NLLookUpTable[WValue shr 4]*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^)); inc(XGroup);
  end;
  // Get the scale factors from the end of the groups
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(WGroup))^)*
         ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^)*
         Q40NLInverseScale;
  // Scale the sum and add it to the result
  result:=result+(Sum*Scale);
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ41NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign32xUInt8=record
      Values:array[0..31] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_1:TAlign32xUInt8=(Values:(129,129,163,191,215,233,246,253,0,3,10,23,41,65,93,127,
                                      129,129,163,191,215,233,246,253,0,3,10,23,41,65,93,127));
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_4:TPasLLMUInt8=TPasLLMUInt8($0f); 
      LCPI0_5:TPasLLMUInt16=TPasLLMUInt16($0001);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  lea eax, [r8 + 31]
  test r8d, r8d
  cmovns eax, r8d
  vpxor xmm0, xmm0, xmm0
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 56
  vmovdqa dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  sar eax, 5
  vpxor xmm0, xmm0, xmm0
  vpbroadcastb ymm1, byte ptr [rip + LCPI0_4]
  vmovdqu ymm2, yword ptr [rip + LCPI0_1]
  vmovss xmm3, dword ptr [rip + LCPI0_2]
  vpbroadcastw ymm4, word ptr [rip + LCPI0_5]
@LBB0_2:
  vmovdqu xmm5, dqword ptr [rcx]
  vpsrlw xmm6, xmm5, 4
  vpunpckhbw xmm7, xmm5, xmm6
  vpunpcklbw xmm5, xmm5, xmm6
  vinserti128 ymm5, ymm5, xmm7, 1
  vpand ymm5, ymm5, ymm1
  vpshufb ymm5, ymm2, ymm5
  vmovdqu ymm6, yword ptr [rdx]
  vpinsrw xmm7, xmm0, word ptr [rcx + 16], 0
  vcvtph2ps xmm7, xmm7
  vpinsrw xmm8, xmm0, word ptr [rdx + 32], 0
  vcvtph2ps xmm8, xmm8
  vmulss xmm7, xmm8, xmm7
  vmulss xmm7, xmm7, xmm3
  vbroadcastss ymm7, xmm7
  vpsignb ymm8, ymm5, ymm5
  vpsignb ymm5, ymm6, ymm5
  vpmaddubsw ymm5, ymm8, ymm5
  vpmaddwd ymm5, ymm5, ymm4
  vcvtdq2ps ymm5, ymm5
  vfmadd231ps ymm0, ymm7, ymm5
  add rcx, 18
  add rdx, 34
  dec eax
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 56
@LBB0_4:
  vextracti128 xmm1, ymm0, 1
  vaddps xmm0, xmm1, xmm0
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm1, xmm0
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  vzeroupper
end;
{$endif}

function PascalDotProductQ41NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
      HalfGroupSize=GroupSize shr 1;
var CountGroups,GroupIndex,HalfGroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt8;
    WGroup,XGroup:PPasLLMUInt8;
    Scale:TPasLLMFloat;
    Sum:TPasLLMInt32;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aW)^[GroupIndex*(HalfGroupSize+2)]); // Pointer to the current group in w (Q40)
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  Sum:=0; // Initialize the sum for this group
  for HalfGroupRelativeIndex:=0 to HalfGroupSize-1 do begin
   // Calculate the dot product for the current group
   WValue:=WGroup^; inc(WGroup);
   inc(Sum,Q41NLLookUpTable[WValue and $0f]*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^)); inc(XGroup);
   inc(Sum,Q41NLLookUpTable[WValue shr 4]*TPasLLMInt32(PPasLLMInt8(Pointer(XGroup))^)); inc(XGroup);
  end;
  // Get the scale factors from the end of the groups
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(WGroup))^)*
         ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(XGroup))^)*
         Q41NLInverseScale;
  // Scale the sum and add it to the result
  result:=result+(Sum*Scale);
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ42NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_2:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_3:TAlign16xUInt8=(Values:(248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  vxorps xmm0, xmm0, xmm0
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 168
  vmovdqa dqword ptr [rsp + 144], xmm15
  vmovaps dqword ptr [rsp + 128], xmm14
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovdqa dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  add rdx, 32
  shr r8d, 4
  and r8d, -2
  lea rax, [r8 + 8*r8]
  vxorps xmm0, xmm0, xmm0
  xor r8d, r8d
  vbroadcastss ymm4, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
  vmovdqu xmm6, dqword ptr [rip + LCPI0_3]
  vxorps xmm7, xmm7, xmm7
  vxorps xmm8, xmm8, xmm8
  vxorps xmm9, xmm9, xmm9
@LBB0_2:
  movsx r9d, byte ptr [rcx + r8 + 17]
  vxorps xmm15, xmm15, xmm15
  vcvtsi2ss xmm10, xmm15, r9d
  movzx r9d, byte ptr [rcx + r8 + 16]
  vmulss xmm10, xmm10, dword ptr [rip + LCPI0_0]
  vbroadcastss ymm11, xmm10
  vmovss xmm1, dword ptr [rip + LCPI0_1]
  vsubss xmm10, xmm1, xmm10
  vbroadcastss ymm10, xmm10
  vmovdqu xmm12, dqword ptr [rcx + r8]
  vpsrlw xmm13, xmm12, 4
  vmovdqu xmm1, dqword ptr [rip + LCPI0_2]
  vpand xmm12, xmm12, xmm1
  vpand xmm13, xmm13, xmm1
  vpunpcklbw xmm14, xmm12, xmm13
  vpunpckhbw xmm12, xmm12, xmm13
  vpaddb xmm13, xmm14, xmm6
  vpaddb xmm15, xmm12, xmm6
  vpshufd xmm12, xmm13, 238
  vpmovsxbd ymm13, xmm13
  vcvtdq2ps ymm13, ymm13
  vpmovsxbd ymm12, xmm12
  vcvtdq2ps ymm12, ymm12
  vpmovsxbd ymm14, xmm15
  vcvtdq2ps ymm14, ymm14
  vmulps ymm1, ymm13, ymm4
  vmulps ymm2, ymm12, ymm4
  vmulps ymm3, ymm14, ymm4
  vandps ymm12, ymm1, ymm5
  vmulps ymm13, ymm11, ymm1
  vmulps ymm13, ymm13, ymm12
  vandps ymm12, ymm2, ymm5
  vfmadd231ps ymm13, ymm10, ymm1
  vmulps ymm1, ymm11, ymm2
  vmulps ymm12, ymm12, ymm1
  vandps ymm1, ymm3, ymm5
  vfmadd231ps ymm12, ymm10, ymm2
  vmulps ymm2, ymm11, ymm3
  vmulps ymm14, ymm2, ymm1
  vmovd xmm1, r9d
  vpslld xmm1, xmm1, 8
  vcvtph2ps xmm1, xmm1
  vpshufd xmm2, xmm15, 238
  vpmovsxbd ymm2, xmm2
  vcvtdq2ps ymm2, ymm2
  vmulps ymm2, ymm2, ymm4
  vfmadd231ps ymm14, ymm10, ymm3
  vandps ymm3, ymm2, ymm5
  vmulps ymm11, ymm11, ymm2
  vmulps ymm3, ymm11, ymm3
  vpinsrw xmm11, xmm0, word ptr [rdx], 0
  vfmadd231ps ymm3, ymm10, ymm2
  vcvtph2ps xmm2, xmm11
  vmulss xmm1, xmm1, xmm2
  vpmovsxbd ymm2, qword ptr [rdx - 32]
  vcvtdq2ps ymm2, ymm2
  vbroadcastss ymm1, xmm1
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm0, ymm13, ymm2
  vpmovsxbd ymm2, qword ptr [rdx - 24]
  vpmovsxbd ymm10, qword ptr [rdx - 16]
  vcvtdq2ps ymm2, ymm2
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm7, ymm12, ymm2
  vcvtdq2ps ymm2, ymm10
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm8, ymm14, ymm2
  vpmovsxbd ymm2, qword ptr [rdx - 8]
  vcvtdq2ps ymm2, ymm2
  vmulps ymm1, ymm1, ymm2
  vfmadd231ps ymm9, ymm3, ymm1
  add rdx, 34
  add r8, 18
  cmp rax, r8
  jne @LBB0_2
  vaddps ymm1, ymm8, ymm9
  vaddps ymm0, ymm7, ymm0
  vaddps ymm0, ymm1, ymm0
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  vmovaps xmm14, dqword ptr [rsp + 128]
  vmovaps xmm15, dqword ptr [rsp + 144]
  add rsp, 168
@LBB0_4:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vzeroupper
end;
{$endif}

function PascalDotProductQ42NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
      HalfGroupSize=GroupSize shr 1;
      OneOver127=1.0/127.0;
var CountGroups,GroupIndex,HalfGroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt8;
    WGroup,XGroup:PPasLLMUInt8;
    WScale,WCurve,XScale,Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aW)^[GroupIndex*(HalfGroupSize+2)]); // Pointer to the current group in w (Q42NL)
  WScale:=FP8E5M2ToFloat32Table[PPasLLMUInt8(Pointer(@PPasLLMUInt8Array(WGroup)^[HalfGroupSize]))^]; // Get the scale factor from the end of the group in w (Q42NL)
  WCurve:=PPasLLMInt8(@PPasLLMUInt8Array(WGroup)^[HalfGroupSize+1])^*OneOver127; // Get the WCurve factor from the end of the group
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  XScale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^); // Get the scale factor from the end of the group in x (Q80)
  Sum:=0.0; // Initialize the sum for this group
  for HalfGroupRelativeIndex:=0 to HalfGroupSize-1 do begin
   // Calculate the dot product for the current group
   WValue:=WGroup^; inc(WGroup);
   Sum:=Sum+((DecodeQ42NLValueNibble(WValue and $0f,WCurve)*WScale)*(PPasLLMInt8(Pointer(XGroup))^*XScale)); inc(XGroup);
   Sum:=Sum+((DecodeQ42NLValueNibble(WValue shr 4,WCurve)*WScale)*(PPasLLMInt8(Pointer(XGroup))^*XScale)); inc(XGroup);
  end;
  // Add sum to the result
  result:=result+Sum;
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ43NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_2:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_3:TAlign16xUInt8=(Values:(248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  vxorps xmm0, xmm0, xmm0
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 168
  vmovdqa dqword ptr [rsp + 144], xmm15
  vmovaps dqword ptr [rsp + 128], xmm14
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovdqa dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  shr r8d, 5
  add rdx, 32
  lea rax, [r8 + 8*r8]
  lea rax, [r8 + 2*rax]
  vxorps xmm0, xmm0, xmm0
  xor r8d, r8d
  vbroadcastss ymm4, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
  vmovdqu xmm6, dqword ptr [rip + LCPI0_3]
  vxorps xmm7, xmm7, xmm7
  vxorps xmm8, xmm8, xmm8
  vxorps xmm9, xmm9, xmm9
@LBB0_2:
  movsx r9d, byte ptr [rcx + r8 + 18]
  vxorps xmm15, xmm15, xmm15
  vcvtsi2ss xmm10, xmm15, r9d
  vmulss xmm10, xmm10, dword ptr [rip + LCPI0_0]
  vbroadcastss ymm11, xmm10
  vmovss xmm1, dword ptr [rip + LCPI0_1]
  vsubss xmm10, xmm1, xmm10
  vbroadcastss ymm10, xmm10
  vmovdqu xmm12, dqword ptr [rcx + r8]
  vpsrlw xmm13, xmm12, 4
  vmovdqu xmm1, dqword ptr [rip + LCPI0_2]
  vpand xmm12, xmm12, xmm1
  vpand xmm13, xmm13, xmm1
  vpunpcklbw xmm14, xmm12, xmm13
  vpunpckhbw xmm12, xmm12, xmm13
  vpaddb xmm13, xmm14, xmm6
  vpaddb xmm15, xmm12, xmm6
  vpshufd xmm12, xmm13, 238
  vpmovsxbd ymm13, xmm13
  vcvtdq2ps ymm13, ymm13
  vpmovsxbd ymm12, xmm12
  vcvtdq2ps ymm12, ymm12
  vpmovsxbd ymm14, xmm15
  vcvtdq2ps ymm14, ymm14
  vmulps ymm1, ymm13, ymm4
  vmulps ymm2, ymm12, ymm4
  vmulps ymm3, ymm14, ymm4
  vandps ymm12, ymm1, ymm5
  vmulps ymm13, ymm11, ymm1
  vmulps ymm13, ymm13, ymm12
  vandps ymm12, ymm2, ymm5
  vfmadd231ps ymm13, ymm10, ymm1
  vmulps ymm1, ymm11, ymm2
  vmulps ymm12, ymm12, ymm1
  vandps ymm1, ymm3, ymm5
  vfmadd231ps ymm12, ymm10, ymm2
  vmulps ymm2, ymm11, ymm3
  vmulps ymm14, ymm2, ymm1
  vpinsrw xmm1, xmm0, word ptr [rcx + r8 + 16], 0
  vcvtph2ps xmm1, xmm1
  vpshufd xmm2, xmm15, 238
  vpmovsxbd ymm2, xmm2
  vcvtdq2ps ymm2, ymm2
  vmulps ymm2, ymm2, ymm4
  vfmadd231ps ymm14, ymm10, ymm3
  vandps ymm3, ymm2, ymm5
  vmulps ymm11, ymm11, ymm2
  vmulps ymm3, ymm11, ymm3
  vpinsrw xmm11, xmm0, word ptr [rdx], 0
  vfmadd231ps ymm3, ymm10, ymm2
  vcvtph2ps xmm2, xmm11
  vmulss xmm1, xmm2, xmm1
  vpmovsxbd ymm2, qword ptr [rdx - 32]
  vcvtdq2ps ymm2, ymm2
  vbroadcastss ymm1, xmm1
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm0, ymm13, ymm2
  vpmovsxbd ymm2, qword ptr [rdx - 24]
  vpmovsxbd ymm10, qword ptr [rdx - 16]
  vcvtdq2ps ymm2, ymm2
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm7, ymm12, ymm2
  vcvtdq2ps ymm2, ymm10
  vmulps ymm2, ymm1, ymm2
  vfmadd231ps ymm8, ymm14, ymm2
  vpmovsxbd ymm2, qword ptr [rdx - 8]
  vcvtdq2ps ymm2, ymm2
  vmulps ymm1, ymm1, ymm2
  vfmadd231ps ymm9, ymm3, ymm1
  add rdx, 34
  add r8, 19
  cmp rax, r8
  jne @LBB0_2
  vaddps ymm1, ymm8, ymm9
  vaddps ymm0, ymm7, ymm0
  vaddps ymm0, ymm1, ymm0
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  vmovaps xmm14, dqword ptr [rsp + 128]
  vmovaps xmm15, dqword ptr [rsp + 144]
  add rsp, 168
@LBB0_4:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vzeroupper
end;
{$endif}

function PascalDotProductQ43NLQ80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
      HalfGroupSize=GroupSize shr 1;
      OneOver127=1.0/127.0;
var CountGroups,GroupIndex,HalfGroupRelativeIndex:TPasLLMInt32;
    WValue:TPasLLMUInt8;
    WGroup,XGroup:PPasLLMUInt8;
    WScale,WCurve,XScale,Sum:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to CountGroups-1 do begin
  WGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aW)^[GroupIndex*(HalfGroupSize+3)]); // Pointer to the current group in w (Q42NL)
  WScale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(WGroup)^[HalfGroupSize]))^); // Get the scale factor from the end of the group in w (Q43NL)
  WCurve:=PPasLLMInt8(@PPasLLMUInt8Array(WGroup)^[HalfGroupSize+2])^*OneOver127; // Get the WCurve factor from the end of the group
  XGroup:=PPasLLMUInt8(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x (Q80)
  XScale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^); // Get the scale factor from the end of the group in x (Q80)
  Sum:=0.0; // Initialize the sum for this group
  for HalfGroupRelativeIndex:=0 to HalfGroupSize-1 do begin
   // Calculate the dot product for the current group
   WValue:=WGroup^; inc(WGroup);
   Sum:=Sum+((DecodeQ43NLValueNibble(WValue and $0f,WCurve)*WScale)*(PPasLLMInt8(Pointer(XGroup))^*XScale)); inc(XGroup);
   Sum:=Sum+((DecodeQ43NLValueNibble(WValue shr 4,WCurve)*WScale)*(PPasLLMInt8(Pointer(XGroup))^*XScale)); inc(XGroup);
  end;
  // Add sum to the result
  result:=result+Sum;
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductQ80Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const One:TPasLLMUInt16=1;
asm
{$ifndef fpc}
 .noframe
{$endif}
 test r8d,r8d
 jle @EarlyExit
 xor eax,eax
 vpxor xmm0,xmm0,xmm0
 vpbroadcastw ymm1,word ptr [rip+One]
 xor r9d,r9d
@Loop:
 vmovdqu ymm2,yword ptr [rdx + rax]
 vmovdqu ymm3,yword ptr [rcx + rax]
 vpsignb ymm4,ymm2,ymm2
 vpsignb ymm2,ymm3,ymm2
 vpmaddubsw ymm2,ymm4,ymm2
 vpmaddwd ymm2,ymm2,ymm1
 vcvtdq2ps ymm2,ymm2
 vpinsrw xmm3,xmm0,word ptr [rdx+rax+32],0
 vcvtph2ps xmm3,xmm3
 vpinsrw xmm4,xmm0,word ptr [rcx+rax+32],0
 vcvtph2ps xmm4,xmm4
 vmulss xmm3,xmm4,xmm3
 vbroadcastss ymm3,xmm3
 vfmadd231ps ymm0,ymm2,ymm3
 add r9d,32
 add rax,34
 cmp r9d,r8d
 jl @Loop
 jmp @Done
@EarlyExit:
 vpxor xmm0,xmm0,xmm0
@Done:
 vextracti128 xmm1,ymm0,1
 vaddps xmm0,xmm0,xmm1
 vhaddps xmm0,xmm0,xmm0
 vhaddps xmm0,xmm0,xmm0
 vzeroupper
end;
{$endif}

function PascalDotProductQ80Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupBaseIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup,XGroup:PPasLLMInt8Array;
    Scale:TPasLLMFloat;
    Sum:TPasLLMInt32;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  GroupBaseIndex:=GroupIndex*(GroupSize+2); // Calculate the offset for the current group
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupBaseIndex]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupBaseIndex]); // Pointer to the current group in x
  Sum:=0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   inc(Sum,TPasLLMInt32(TPasLLMInt8(WGroup^[GroupRelativeIndex]))*TPasLLMInt32(TPasLLMInt8(XGroup^[GroupRelativeIndex])));
  end;
  // Get the scale factors from the end of the groups
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(WGroup)^[GroupSize]))^)*
         ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^);
  // Scale the sum and add it to the result
  result:=result+(Sum*Scale);
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductF8E5M2Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 cmp r8d,31
 jle @EarlyExit
 vxorps xmm3,xmm3,xmm3
 sar r8d,5
 xor r10d,r10d
 vxorps xmm4,xmm4,xmm4
@Loop:
 xor r9d,r9d
 vxorps xmm2,xmm2,xmm2
@InnerLoop:
 movsx eax,byte ptr [rdx+r9]
 vpxor xmm5,xmm5,xmm5
 vcvtsi2ss xmm0,xmm3,eax
 movzx eax,byte ptr [rcx+r9]
 add r9,1
 sal eax,8
 vmovaps xmm1,xmm0
 vpinsrw xmm0,xmm5,eax,0
 vcvtph2ps xmm0,xmm0
 vmulss xmm0,xmm1,xmm0
 vaddss xmm2,xmm2,xmm0
 cmp r9,32
 jne @InnerLoop
 vpinsrw xmm0,xmm5,word ptr [rdx+32],0
 add r10,1
 add rdx,34
 add rcx,32
 vcvtph2ps xmm0,xmm0
 vmulss xmm2,xmm2,xmm0
 vaddss xmm4,xmm4,xmm2
 cmp r8d,r10d
 jg @Loop
 vmovaps xmm0,xmm4
 jmp @Exit
@EarlyExit:
 vxorps xmm4,xmm4,xmm4
 vmovaps xmm0,xmm4
@Exit:
end;
{$endif}

function PascalDotProductF8E5M2Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup:PPasLLMUInt8Array;
    XGroup:PPasLLMInt8Array;
    Sum:TPasLLMFloat;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupIndex*GroupSize]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x
  Sum:=0.0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   Sum:=Sum+(FP8E5M2Q80MulTable[WGroup^[GroupRelativeIndex],TPasLLMUInt8(XGroup^[GroupRelativeIndex])]);
  end;
  // Scale the sum and add it to the result
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^));
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductF8E5M2F8E5M2(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3f800000); // 1.0 in IEEE 754 single-precision format
asm
{$ifndef fpc}
 .noframe
{$endif}
  sub rsp, 88
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovdqa dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  vxorps xmm0, xmm0, xmm0
  test r8d, r8d
  jle @LBB0_4
  xor eax, eax
  vxorps xmm1, xmm1, xmm1
  vxorps xmm2, xmm2, xmm2
  vxorps xmm3, xmm3, xmm3
@LBB0_2:
  vpmovzxbw ymm4, dqword ptr [rdx + rax]
  vpmovzxbw ymm5, dqword ptr [rdx + rax + 16]
  vpsllw ymm4, ymm4, 8
  vcvtph2ps ymm6, xmm4
  vextracti128 xmm4, ymm4, 1
  vcvtph2ps ymm4, xmm4
  vpsllw ymm5, ymm5, 8
  vcvtph2ps ymm7, xmm5
  vextracti128 xmm5, ymm5, 1
  vcvtph2ps ymm5, xmm5
  vpmovzxbw ymm8, dqword ptr [rcx + rax]
  vpmovzxbw ymm9, dqword ptr [rcx + rax + 16]
  vpsllw ymm8, ymm8, 8
  vpsllw ymm9, ymm9, 8
  vcvtph2ps ymm10, xmm8
  vfmadd231ps ymm0, ymm6, ymm10
  vextracti128 xmm6, ymm8, 1
  vcvtph2ps ymm6, xmm6
  vcvtph2ps ymm8, xmm9
  vfmadd231ps ymm1, ymm4, ymm6
  vextracti128 xmm4, ymm9, 1
  vcvtph2ps ymm4, xmm4
  vfmadd231ps ymm2, ymm7, ymm8
  vfmadd231ps ymm3, ymm5, ymm4
  add rax, 32
  cmp eax, r8d
  jl @LBB0_2
  vaddps ymm2, ymm2, ymm3
  vaddps ymm0, ymm1, ymm0
  vaddps ymm0, ymm2, ymm0
@LBB0_4:
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vbroadcastss xmm1, dword ptr [rip + LCPI0_0]
  vdpps xmm0, xmm0, xmm1, 241
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  add rsp, 88
end;
{$endif}

function PascalDotProductF8E5M2F8E5M2(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupBaseIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup,XGroup:PPasLLMUInt8Array;
    Sum:TPasLLMFloat;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  GroupBaseIndex:=GroupIndex*GroupSize; // Calculate the offset for the current group
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupBaseIndex]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupBaseIndex]); // Pointer to the current group in x
  Sum:=0.0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   Sum:=Sum+(FP8E5M2FP8E5M2MulTable[WGroup^[GroupRelativeIndex],XGroup^[GroupRelativeIndex]]);
  end;
  // Scale the sum and add it to the result
  result:=result+Sum;
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductBF16Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 cmp r8d,31
 jle @EarlyExit
 push rbp
 sar r8d,5
 xor eax,eax
 vxorps xmm2,xmm2,xmm2
 mov rbp,rsp
 sub rsp,16
 and rsp,-32
 vmovaps dqword ptr [rsp],xmm6
@Loop:
  vmovdqu ymm4,yword ptr [rcx]
  vmovdqu ymm0,yword ptr [rdx]
  add eax,1
  add rcx,64
  vmovdqu ymm3,yword ptr [rcx-32]
  add rdx,34
  vpmovsxbw ymm1,xmm0
  vpmovzxwd ymm6,xmm4
  vextracti128 xmm4,ymm4,1
  vpmovsxwd ymm5,xmm1
  vpslld ymm6,ymm6,16
  vpmovzxwd ymm4,xmm4
  vextracti128 xmm1,ymm1,1
  vpslld ymm4,ymm4,16
  vextracti128 xmm0,ymm0,1
  vcvtdq2ps ymm5,ymm5
  vpmovsxwd ymm1,xmm1
  vpmovsxbw ymm0,xmm0
  vcvtdq2ps ymm1,ymm1
  vmulps ymm1,ymm1,ymm4
  vfmadd132ps ymm5,ymm1,ymm6
  vpxor xmm6,xmm6,xmm6
  vpinsrw xmm4,xmm6,word ptr [rdx-2],0
  vpmovzxwd ymm6,xmm3
  vextracti128 xmm3,ymm3,1
  vpmovsxwd ymm1,xmm0
  vpmovzxwd ymm3,xmm3
  vextracti128 xmm0,ymm0,1
  vcvtdq2ps ymm1,ymm1
  vcvtph2ps xmm4,xmm4
  vpslld ymm3,ymm3,16
  vpslld ymm6,ymm6,16
  vpmovsxwd ymm0,xmm0
  vcvtdq2ps ymm0,ymm0
  vmulps ymm0,ymm0,ymm3
  vfmadd231ps ymm0,ymm1,ymm6
  vaddps ymm0,ymm0,ymm5
  vextractf128 xmm1,ymm0,1
  vaddps xmm0,xmm1,xmm0
  vmovhlps xmm1,xmm0,xmm0
  vaddps xmm1,xmm1,xmm0
  vshufps xmm0,xmm1,xmm1,85
  vaddps xmm0,xmm0,xmm1
  vfmadd231ss xmm2,xmm0,xmm4
 cmp r8d,eax
 jg @Loop
 vzeroupper
 vmovaps xmm6,dqword ptr [rsp]
 vmovaps xmm0,xmm2
 leave
 jmp @Exit
@EarlyExit:
 vxorps xmm2,xmm2,xmm2
 vmovaps xmm0,xmm2
@Exit:
end;
{$endif}

function PascalDotProductBF16Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup:PPasLLMUInt16Array;
    XGroup:PPasLLMInt8Array;
    Sum:TPasLLMFloat;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupIndex*(GroupSize*2)]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x
  Sum:=0.0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   Sum:=Sum+(ConvertBFloat16ToFloat32(WGroup^[GroupRelativeIndex])*TPasLLMInt32(TPasLLMInt8(XGroup^[GroupRelativeIndex])));
  end;
  // Scale the sum and add it to the result
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt64(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^));
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductF16Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 cmp r8d,31
 jle @EarlyExit
 vxorps xmm3,xmm3,xmm3
 sar r8d,5
 xor r10d,r10d
 vxorps xmm4,xmm4,xmm4
@Loop:
 xor eax,eax
 vxorps xmm2,xmm2,xmm2
@InnerLoop:
 movsx r9d,byte ptr [rdx+rax]
 vpxor xmm5,xmm5,xmm5
 vpinsrw xmm1,xmm5,word ptr [rcx+rax*2],0
 add rax,1
 vcvtsi2ss xmm0,xmm3,r9d
 vcvtph2ps xmm1,xmm1
 vmulss xmm0,xmm0,xmm1
 vaddss xmm2,xmm2,xmm0
 cmp rax,32
 jne @InnerLoop
 vpinsrw xmm0,xmm5,word ptr [rdx+32],0
 add r10,1
 add rdx,34
 add rcx,64
 vcvtph2ps xmm0,xmm0
 vmulss xmm2,xmm2,xmm0
 vaddss xmm4,xmm4,xmm2
 cmp r8d,r10d
 jg @Loop
 vmovaps xmm0,xmm4
 jmp @Exit
@EarlyExit:
 vxorps xmm4,xmm4,xmm4
 vmovaps xmm0,xmm4
@Exit:
end;
{$endif}

function PascalDotProductF16Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup:PPasLLMUInt16Array;
    XGroup:PPasLLMInt8Array;
    Sum:TPasLLMFloat;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupIndex*(GroupSize*2)]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x
  Sum:=0.0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   Sum:=Sum+(ConvertFloat16ToFloat32(WGroup^[GroupRelativeIndex])*TPasLLMInt32(TPasLLMInt8(XGroup^[GroupRelativeIndex])));
  end;
  // Scale the sum and add it to the result
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt64(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^));
 end;
end;

{$ifdef cpuamd64}
function AMD64DotProductF32Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d,31
  jle @EarlyExit
  sar r8d,5
  xor eax,eax
  vxorps xmm2,xmm2,xmm2
@Loop:
  vmovdqu ymm0,yword ptr [rdx]
  vpxor xmm5,xmm5,xmm5
  add eax,1
  sub rcx,-128
  vpinsrw xmm4,xmm5,word ptr [rdx+32],0
  add rdx,34
  vpmovsxbw ymm1,xmm0
  vextracti128 xmm0,ymm0,1
  vpmovsxwd ymm3,xmm1
  vextracti128 xmm1,ymm1,1
  vpmovsxbw ymm0,xmm0
  vcvtph2ps xmm4,xmm4
  vpmovsxwd ymm1,xmm1
  vcvtdq2ps ymm3,ymm3
  vcvtdq2ps ymm1,ymm1
  vmulps ymm1,ymm1,yword ptr [rcx-96]
  vfmadd132ps ymm3,ymm1,yword ptr [rcx-128]
  vpmovsxwd ymm1,xmm0
  vextracti128 xmm0,ymm0,1
  vpmovsxwd ymm0,xmm0
  vcvtdq2ps ymm1,ymm1
  vcvtdq2ps ymm0,ymm0
  vmulps ymm0,ymm0,yword ptr [rcx-32]
  vfmadd231ps ymm0,ymm1,yword ptr [rcx-64]
  vaddps ymm0,ymm0,ymm3
  vextractf128 xmm1,ymm0,1
  vaddps xmm0,xmm1,xmm0
  vmovhlps xmm1,xmm0,xmm0
  vaddps xmm1,xmm1,xmm0
  vshufps xmm0,xmm1,xmm1,85
  vaddps xmm0,xmm0,xmm1
  vfmadd231ss xmm2,xmm0,xmm4
 cmp r8d,eax
 jg @Loop
 vzeroupper
 vmovaps xmm0,xmm2
 jmp @Exit
@EarlyExit:
 vxorps xmm2,xmm2,xmm2
 vmovaps xmm0,xmm2
@Exit:
end;
{$endif}

function PascalDotProductF32Q80(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$if defined(fpc) and defined(cpuamd64)}ms_abi_default;{$ifend}
const GroupSize=32;
var GroupCount,GroupIndex,GroupRelativeIndex:TPasLLMInt32;
    WGroup:PPasLLMFloatArray;
    XGroup:PPasLLMInt8Array;
    Sum:TPasLLMFloat;
begin
 GroupCount:=Count div GroupSize; // Number of groups
 result:=0.0; // Initialize the result to zero
 for GroupIndex:=0 to GroupCount-1 do begin
  WGroup:=Pointer(@PPasLLMUInt8Array(aW)^[GroupIndex*(GroupSize*2)]); // Pointer to the current group in w
  XGroup:=Pointer(@PPasLLMUInt8Array(aX)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in x
  Sum:=0.0; // Initialize the sum for this group
  for GroupRelativeIndex:=0 to GroupSize-1 do begin
   // Calculate the dot product for the current group
   Sum:=Sum+(WGroup^[GroupRelativeIndex]*TPasLLMInt32(TPasLLMInt8(XGroup^[GroupRelativeIndex])));
  end;
  // Scale the sum and add it to the result
  result:=result+(Sum*ConvertFloat16ToFloat32(PPasLLMUInt64(Pointer(@PPasLLMUInt8Array(XGroup)^[GroupSize]))^));
 end;
end;

procedure LoadRawFromFile(const aFileName:String;const aDest:Pointer);
var Stream:TStream;
    Size:TPasLLMInt64;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead);
 try
  Size:=Stream.Size;
  Stream.ReadBuffer(aDest^,Size);
 finally
  Stream.Free;
 end;
end;

procedure SaveRawToFile(const aFileName:String;const aSource:Pointer;const aSize:TPasLLMInt64);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  Stream.WriteBuffer(aSource^,aSize);
 finally
  Stream.Free;
 end;
end;

{$if not (defined(fpc) and declared(CLZDWord))}
function CLZDWord(x:TPasLLMUInt32):TPasLLMUInt32;{$if defined(cpu386)}assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr eax,eax
 jz @Done
 xor edx,edx
 shl eax,1
 @Done:
end;
{$elseif defined(cpux86_64)}assembler; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Windows}
 bsr eax,ecx
{$else}
 bsr eax,edi
{$endif}
 jnz @Done
 xor eax,eax
 xor edx,edx
 shl eax,1
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
 if x<>0 then begin
  result:=63-result;
 end else begin
  result:=0;
 end;
end;
{$ifend}
{$ifend}

function IntLog2(x:TPasLLMUInt32):TPasLLMUInt32; {$if defined(fpc)}
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

function IntLog264(x:TPasLLMUInt64):TPasLLMUInt32; {$if defined(fpc)}
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

function ConvertScale(const aValue,aFromScale,aToScale:TPasLLMUInt64):TPasLLMUInt64;
var FromScaleRemainder:TPasLLMUInt64;
begin
 FromScaleRemainder:=aValue mod aFromScale;
 result:=((aValue div aFromScale)*aToScale)+((FromScaleRemainder*aToScale) div aFromScale);
end;

const CLOCK_FREQUENCY=1000000; // Default clock frequency in microseconds

{$if defined(Windows)}
type TCreateWaitableTimerExW=function(lpTimerAttributes:Pointer;lpTimerName:LPCWSTR;dwFlags,dwDesiredAccess:dword):THandle; {$ifdef cpu386}stdcall;{$endif}

     TNtDelayExecution=function(Alertable:BOOL;var Interval:TLargeInteger):LONG{NTSTATUS}; {$ifdef cpu386}stdcall;{$endif}
     TNtQueryTimerResolution=function(var MinimumResolution,MaximumResolution,CurrentResolution:ULONG):LONG{NTSTATUS}; {$ifdef cpu386}stdcall;{$endif}
     TNtSetTimerResolution=function(var DesiredResolution:ULONG;SetResolution:BOOL;var CurrentResolution:ULONG):LONG{NTSTATUS}; {$ifdef cpu386}stdcall;{$endif}

var KERNEL32LibHandle:HMODULE=HMODULE(0);
    CreateWaitableTimerExW:TCreateWaitableTimerExW=nil;

    NTDLLLibHandle:HMODULE=HMODULE(0);
    NtDelayExecution:TNtDelayExecution=nil;
    NtQueryTimerResolution:TNtQueryTimerResolution=nil;
    NtSetTimerResolution:TNtSetTimerResolution=nil;

    MinimumResolution:ULONG=0;
    MaximumResolution:ULONG=0;
    CurrentResolution:ULONG=0;

//function NtDelayExecution(Alertable:BOOL;var Interval:TLargeInteger):LONG{NTSTATUS}; {$ifdef cpu386}stdcall;{$endif} external 'ntdll.dll' name 'NtDelayExecution';
{$ifend}

{$if defined(fpc) and defined(Unix)}
{$if not declared(clock_gettime)}

const CLOCK_REALTIME=0;
      CLOCK_MONOTONIC=1;
      CLOCK_PROCESS_CPUTIME_ID=2;
      CLOCK_THREAD_CPUTIME_ID=3;
      CLOCK_MONOTONIC_RAW=4;
      CLOCK_REALTIME_COARSE=5;
      CLOCK_MONOTONIC_COARSE=6;

function clock_gettime(clk_id:TPasLLMInt32;tp:ptimespec):cint; cdecl; external 'c' name 'clock_gettime';
{$ifend}

function GetCurrentTime:TPasLLMUInt64;
var Now:TTimeSpec;
begin
 clock_gettime(CLOCK_MONOTONIC,@Now);
{$if CLOCK_FREQUENCY=10000000}
 result:=(TPasLLMUInt64(Now.tv_sec)*10000000)+(TPasLLMUInt64(Now.tv_nsec) div TPasLLMUInt64(100));
{$elseif CLOCK_FREQUENCY=1000000}
 result:=(TPasLLMUInt64(Now.tv_sec)*1000000)+(TPasLLMUInt64(Now.tv_nsec) div TPasLLMUInt64(1000));
{$elseif CLOCK_FREQUENCY=100000}
 result:=(TPasLLMUInt64(Now.tv_sec)*100000)+(TPasLLMUInt64(Now.tv_nsec) div TPasLLMUInt64(10000));
{$elseif CLOCK_FREQUENCY=10000}
 result:=(TPasLLMUInt64(Now.tv_sec)*10000)+(TPasLLMUInt64(Now.tv_nsec) div TPasLLMUInt64(100000));
{$elseif CLOCK_FREQUENCY=1000}
 result:=(TPasLLMUInt64(Now.tv_sec)*1000)+(TPasLLMUInt64(Now.tv_nsec) div TPasLLMUInt64(1000000));
{$else}
 result:=(TPasLLMUInt64(Now.tv_sec)*CLOCK_FREQUENCY)+((TPasLLMUInt64(Now.tv_nsec)*CLOCK_FREQUENCY) div TPasLLMUInt64(1000000000));
{$ifend}
end;

function GetCurrentFrequencyTime(const aFrequency:TPasLLMUInt64):TPasLLMUInt64;
var Now:TTimeSpec;
begin
 clock_gettime(CLOCK_MONOTONIC,@Now);
 result:=(TPasLLMUInt64(Now.tv_sec)*aFrequency)+((TPasLLMUInt64(Now.tv_nsec)*aFrequency) div TPasLLMUInt64(1000000000));
end;

{$elseif defined(Windows)}
var QPCLock:TPasMPUInt32=0;
    QPCLast:TPasMPUInt64=0;
    QPCFrequency:TPasMPUInt64=0;
    QPCFrequencyShift:TPasMPUInt32=0;

function GetCurrentTime:TPasLLMUInt64;
var QPCNow:TPasMPUInt64;
    Value:TPasMPInt64;
begin
 result:=TPasMPInterlocked.Read(QPCLast);
 if TPasMPInterlocked.CompareExchange(QPCLock,1,0)=0 then begin
  if QPCFrequency=0 then begin
   if QueryPerformanceFrequency(Value) and (Value<>0) then begin
    QPCFrequency:=Value;
    while (QPCFrequency and $ffffffffe0000000)<>0 do begin
     QPCFrequency:=QPCFrequency shr 1;
     inc(QPCFrequencyShift);
    end;
   end else begin
    QPCFrequency:=1000;
   end;
  end;
  QueryPerformanceCounter(Value);
  QPCNow:=TPasMPUInt64(Value) shr QPCFrequencyShift;
  if result<=QPCNow then begin
   result:=QPCNow;
   TPasMPInterlocked.Write(QPCLast,result);
  end;
  TPasMPInterlocked.Write(QPCLock,0);
 end;
 if QPCFrequency<>CLOCK_FREQUENCY then begin
  result:=ConvertScale(result,QPCFrequency,CLOCK_FREQUENCY);
 end;
end;

function GetCurrentFrequencyTime(const aFrequency:TPasLLMUInt64):TPasLLMUInt64;
var QPCNow:TPasMPUInt64;
    Value:TPasMPInt64;
begin
 result:=TPasMPInterlocked.Read(QPCLast);
 if TPasMPInterlocked.CompareExchange(QPCLock,1,0)=0 then begin
  if QPCFrequency=0 then begin
   if QueryPerformanceFrequency(Value) and (Value<>0) then begin
    QPCFrequency:=Value;
    while (QPCFrequency and $ffffffffe0000000)<>0 do begin
     QPCFrequency:=QPCFrequency shr 1;
     inc(QPCFrequencyShift);
    end;
   end else begin
    QPCFrequency:=1000;
   enD;
  end;
  QueryPerformanceCounter(Value);
  QPCNow:=TPasMPUInt64(Value) shr QPCFrequencyShift;
  if result<=QPCNow then begin
   result:=QPCNow;
   TPasMPInterlocked.Write(QPCLast,result);
  end;
  TPasMPInterlocked.Write(QPCLock,0);
 end;
 if QPCFrequency<>aFrequency then begin
  result:=ConvertScale(result,QPCFrequency,aFrequency);
 end;
end;

{$else}
function GetCurrentTime:TPasLLMUInt64;
begin
{$if CLOCK_FREQUENCY=1000}
 result:=GetTickCount64;
{$elseif CLOCK_FREQUENCY=10000}
 result:=GetTickCount64*10;
{$elseif CLOCK_FREQUENCY=100000}
 result:=GetTickCount64*100;
{$elseif CLOCK_FREQUENCY=1000000}
 result:=GetTickCount64*1000;
{$elseif CLOCK_FREQUENCY=10000000}
 result:=GetTickCount64*10000;
{$else}
 result:=ConvertScale(GetTickCount64,1000,CLOCK_FREQUENCY);
{$ifend}
end;

function GetCurrentFrequencyTime(const aFrequency:TPasLLMUInt64):TPasLLMUInt64;
begin
 result:=ConvertScale(GetTickCount64,1000,aFrequency);
end;
{$ifend}

class procedure TPasLLMTypedSort<T>.IntroSort(const aItems:Pointer;const aLeft,aRight:TPasLLMInt32);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TPasLLMInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
    Comparer:IComparer<T>;
begin
 Comparer:=TComparer<T>.Default;
 if aLeft<aRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=aLeft;
  StackItem^.Right:=aRight;
  StackItem^.Depth:=IntLog2((aRight-aLeft)+1) shl 1;
  inc(StackItem);
  while TPasLLMPtrUInt(Pointer(StackItem))>TPasLLMPtrUInt(Pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (Comparer.Compare(PItemArray(aItems)^[iA],PItemArray(aItems)^[iC])>0) do begin
      Temp:=PItemArray(aItems)^[iA];
      PItemArray(aItems)^[iA]:=PItemArray(aItems)^[iC];
      PItemArray(aItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TPasLLMPtrUInt(Pointer(StackItem))>=TPasLLMPtrUInt(Pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(aItems)^[Left+Size];
        PItemArray(aItems)^[Left+Size]:=PItemArray(aItems)^[Left];
        PItemArray(aItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (Comparer.Compare(PItemArray(aItems)^[Left+Child],PItemArray(aItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if Comparer.Compare(PItemArray(aItems)^[Left+Parent],PItemArray(aItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(aItems)^[Left+Parent];
         PItemArray(aItems)^[Left+Parent]:=PItemArray(aItems)^[Left+Child];
         PItemArray(aItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if Comparer.Compare(PItemArray(aItems)^[Left],PItemArray(aItems)^[Middle])>0 then begin
       Temp:=PItemArray(aItems)^[Left];
       PItemArray(aItems)^[Left]:=PItemArray(aItems)^[Middle];
       PItemArray(aItems)^[Middle]:=Temp;
      end;
      if Comparer.Compare(PItemArray(aItems)^[Left],PItemArray(aItems)^[Right])>0 then begin
       Temp:=PItemArray(aItems)^[Left];
       PItemArray(aItems)^[Left]:=PItemArray(aItems)^[Right];
       PItemArray(aItems)^[Right]:=Temp;
      end;
      if Comparer.Compare(PItemArray(aItems)^[Middle],PItemArray(aItems)^[Right])>0 then begin
       Temp:=PItemArray(aItems)^[Middle];
       PItemArray(aItems)^[Middle]:=PItemArray(aItems)^[Right];
       PItemArray(aItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (Comparer.Compare(PItemArray(aItems)^[i],PItemArray(aItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (Comparer.Compare(PItemArray(aItems)^[j],PItemArray(aItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(aItems)^[i];
        PItemArray(aItems)^[i]:=PItemArray(aItems)^[j];
        PItemArray(aItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

class procedure TPasLLMTypedSort<T>.IntroSort(const aItems:Pointer;const aLeft,aRight:TPasLLMInt32;const aCompareFunc:TPasLLMTypedSortCompareFunction);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array[0..65535] of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TPasLLMInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
begin
 if aLeft<aRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=aLeft;
  StackItem^.Right:=aRight;
  StackItem^.Depth:=IntLog2((aRight-aLeft)+1) shl 1;
  inc(StackItem);
  while TPasLLMPtrUInt(Pointer(StackItem))>TPasLLMPtrUInt(Pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (aCompareFunc(PItemArray(aItems)^[iA],PItemArray(aItems)^[iC])>0) do begin
      Temp:=PItemArray(aItems)^[iA];
      PItemArray(aItems)^[iA]:=PItemArray(aItems)^[iC];
      PItemArray(aItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TPasLLMPtrUInt(Pointer(StackItem))>=TPasLLMPtrUInt(Pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(aItems)^[Left+Size];
        PItemArray(aItems)^[Left+Size]:=PItemArray(aItems)^[Left];
        PItemArray(aItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (aCompareFunc(PItemArray(aItems)^[Left+Child],PItemArray(aItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if aCompareFunc(PItemArray(aItems)^[Left+Parent],PItemArray(aItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(aItems)^[Left+Parent];
         PItemArray(aItems)^[Left+Parent]:=PItemArray(aItems)^[Left+Child];
         PItemArray(aItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if aCompareFunc(PItemArray(aItems)^[Left],PItemArray(aItems)^[Middle])>0 then begin
       Temp:=PItemArray(aItems)^[Left];
       PItemArray(aItems)^[Left]:=PItemArray(aItems)^[Middle];
       PItemArray(aItems)^[Middle]:=Temp;
      end;
      if aCompareFunc(PItemArray(aItems)^[Left],PItemArray(aItems)^[Right])>0 then begin
       Temp:=PItemArray(aItems)^[Left];
       PItemArray(aItems)^[Left]:=PItemArray(aItems)^[Right];
       PItemArray(aItems)^[Right]:=Temp;
      end;
      if aCompareFunc(PItemArray(aItems)^[Middle],PItemArray(aItems)^[Right])>0 then begin
       Temp:=PItemArray(aItems)^[Middle];
       PItemArray(aItems)^[Middle]:=PItemArray(aItems)^[Right];
       PItemArray(aItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (aCompareFunc(PItemArray(aItems)^[i],PItemArray(aItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (aCompareFunc(PItemArray(aItems)^[j],PItemArray(aItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(aItems)^[i];
        PItemArray(aItems)^[i]:=PItemArray(aItems)^[j];
        PItemArray(aItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

{ TPasLLMPCG32 }

procedure TPasLLMPCG32.Init(const aSeed:TPasLLMUInt64);
begin
 if aSeed=0 then begin
  fState:=DefaultState;
  fIncrement:=DefaultStream;
 end else begin
  fState:=DefaultState xor (aSeed*362436069);
  if fState=0 then begin
   fState:=DefaultState;
  end;
  fIncrement:=DefaultStream xor (aSeed*1566083941);
  inc(fIncrement,1-(fIncrement and 1));
 end;
end;

function TPasLLMPCG32.Get32:TPasLLMUInt32;
var OldState:TPasLLMUInt64;
{$ifndef fpc}
    XorShifted,Rotation:TPasLLMUInt32;
{$endif}
begin
 OldState:=fState;
 fState:=(OldState*TPasLLMPCG32.Mult)+fIncrement;
{$ifdef fpc}
 result:=RORDWord(((OldState shr 18) xor OldState) shr 27,OldState shr 59);
{$else}
 XorShifted:=((OldState shr 18) xor OldState) shr 27;
 Rotation:=OldState shr 59;
 result:=(XorShifted shr Rotation) or (XorShifted shl ((-Rotation) and 31));
{$endif}
end;

function TPasLLMPCG32.Get64:TPasLLMUInt64;
begin
 result:=Get32;
 result:=(result shl 32) or Get32;
end;

function TPasLLMPCG32.GetBiasedBounded32Bit(const aRange:TPasLLMUInt32):TPasLLMUInt32;
var Temporary:TPasLLMUInt64;
begin
 // For avoid compiler code generation bugs, when a compiler is optimizing the 64-bit casting away wrongly, thus,
 // we use a temporary 64-bit variable for the multiplication and shift operations, so it is sure that the multiplication
 // and shift operations are done on 64-bit values and not on 32-bit values.
 Temporary:=TPasLLMUInt64(Get32);
 Temporary:=Temporary*aRange;
 result:=Temporary shr 32;
end;

function TPasLLMPCG32.GetUnbiasedBounded32Bit(const aRange:TPasLLMUInt32):TPasLLMUInt32;
var x,l,t:TPasLLMUInt32;
    m:TPasLLMUInt64;
begin
 if aRange<=1 then begin
  // For ranges of 0 or 1, just output always zero, but do a dummy Get32 call with discarding its result
  Get32;
  result:=0;
 end else if (aRange and (aRange-1))<>0 then begin
  // For non-power-of-two ranges: Debiased Integer Multiplication — Lemire's Method
  x:=Get32;
  m:=TPasLLMUInt64(x);
  m:=m*TPasLLMUInt64(aRange);
  l:=TPasLLMUInt32(m and $ffffffff);
  if l<aRange then begin
   t:=-aRange;
   if t>=aRange then begin
    dec(t,aRange);
    if t>=aRange then begin
     t:=t mod aRange;
    end;
   end;
   while l<t do begin
    x:=Get32;
    m:=TPasLLMUInt64(x);
    m:=m*TPasLLMUInt64(aRange);
    l:=TPasLLMUInt32(m and $ffffffff);
   end;
  end;
  result:=m shr 32;
 end else begin
  // For power-of-two ranges: Bitmask with Rejection (Unbiased) — Apple's Method
  m:=TPasLLMUInt32($ffffffff);
  t:=aRange-1;
{$if defined(fpc) and declared(BSRDWord)}
  m:=m shr (31-BSRDWord(t or 1));
{$else}
  m:=m shr CLZDWord(t or 1);
{$ifend}
  repeat
   result:=Get32 and m;
  until result<=t;
 end;
end;

function TPasLLMPCG32.GetFloat:TPasLLMFloat; // -1.0 .. 1.0
var t:TPasLLMUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $40000000;
 result:=TPasLLMFloat(pointer(@t)^)-3.0;
end;

function TPasLLMPCG32.GetFloatAbs:TPasLLMFloat; // 0.0 .. 1.0
var t:TPasLLMUInt32;
begin
 t:=Get32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $3f800000;
 result:=TPasLLMFloat(pointer(@t)^)-1.0;
end;

function TPasLLMPCG32.GetDouble:TPasLLMDouble; // -1.0 .. 1.0
var t:TPasLLMUInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $fffffffffffff)+((t shr 11) and 1)) or $4000000000000000;
 result:=TPasLLMDouble(pointer(@t)^)-3.0;
end;

function TPasLLMPCG32.GetDoubleAbs:TPasLLMDouble; // 0.0 .. 1.0
var t:TPasLLMInt64;
begin
 t:=Get64;
 t:=(((t shr 12) and $7ffffffffffff)+((t shr 11) and 1)) or $3ff0000000000000;
 result:=TPasLLMDouble(pointer(@t)^)-1.0;
end;

{ TPasLLMFileMappedStream }

constructor TPasLLMFileMappedStream.Create(const FileName:String;Mode:Word);
{$ifdef unix}
const Access:array[0..4] of TPasLLMUInt32=(O_RdOnly,O_WrOnly,O_RdWr,O_RdWr,O_RdWr);
      CreateFlag:array[0..4] of TPasLLMUInt32=(0,0,0,O_Creat,O_Creat);
var StatInfo:BaseUnix.Stat;
    ModeEx:TPasLLMUInt32;
begin
 inherited Create;
 fAllocationGranularity:=65556;
 fFileName:=FileName;
 ModeEx:=Mode and not (fmShareExclusive or fmShareExclusive or fmShareDenyRead or fmShareDenyWrite or fmShareDenyNone);
 fCurrentViewOffset:=0;
 fCurrentViewSize:=0;
 if DefaultViewSize=0 then begin
  fViewSize:=High(TPasLLMInt64); // use the whole file
  fViewMask:=fViewSize; // it is already power of two
 end else begin
  fViewSize:=DefaultViewSize;
  fViewMask:=fViewSize-1;
 end;
 fReadOnly:=ModeEx=0;
 fTemporary:=ModeEx=fmCreateTemporary;
 if Mode=fmCreate then begin
  ModeEx:=3;
 end;
 fFileHandle:=fpOpen(PChar(fFileName),Access[ModeEx] or CreateFlag[ModeEx]);
 if fFileHandle<>feInvalidHandle then begin
  if fpfstat(fFileHandle,StatInfo)<>0 then begin
   raise EPasLLMFileMappedStream.Create('Cann''t access file');
  end;
  fSize:=StatInfo.st_size;
  if fSize<1 then begin
   FpLseek(fFileHandle,1,Seek_Set);
   fSize:=1;
  end;
  CreateMapView;
 end else begin
  raise EPasLLMFileMappedStream.Create('Can''t access file');
 end;
end;
{$else}
const Access:array[0..4] of TPasLLMUInt32=(GENERIC_READ,GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE);
      CreateFlag:array[0..4] of TPasLLMUInt32=(OPEN_EXISTING,OPEN_EXISTING,OPEN_EXISTING,CREATE_ALWAYS,CREATE_ALWAYS);
var ModeEx,FileFlags,ShareFlags,HighFileSize:TPasLLMUInt32;
    SystemInfo:TSystemInfo;
begin
 inherited Create;
 GetSystemInfo(SystemInfo);
 fAllocationGranularity:=SystemInfo.dwAllocationGranularity;
 fFileName:=FileName;
 ModeEx:=Mode and not (fmShareExclusive or fmShareExclusive or fmShareDenyRead or fmShareDenyWrite or fmShareDenyNone);
 fCurrentViewOffset:=0;
 fCurrentViewSize:=0;
 if DefaultViewSize=0 then begin
  fViewSize:=High(TPasLLMInt64); // use the whole file
  fViewMask:=fViewSize; // it is already power of two
 end else begin
  fViewSize:=DefaultViewSize;
  fViewMask:=fViewSize-1;
 end;
 fReadOnly:=ModeEx=0;
 if Mode=fmCreate then begin
  ModeEx:=3;
 end;
 if ModeEx<>4 then begin
  FileFlags:=FILE_ATTRIBUTE_NORMAL;
 end else begin
  FileFlags:=FILE_FLAG_DELETE_ON_CLOSE;
 end;
 ShareFlags:=FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE;
 if (Mode and fmShareDenyNone)=0 then begin
  if (Mode and fmShareExclusive)<>0 then begin
   ShareFlags:=0;
  end else begin
   if (Mode and fmShareDenyRead)<>0 then begin
    ShareFlags:=ShareFlags and not FILE_SHARE_READ;
   end;
   if (Mode and fmShareDenyWrite)<>0 then begin
    ShareFlags:=ShareFlags and not (FILE_SHARE_WRITE or FILE_SHARE_DELETE);
   end;
  end;
 end;
 fFileHandle:=CreateFile(PChar(fFileName),Access[ModeEx],ShareFlags,nil,CreateFlag[ModeEx],FileFlags,0);
 if fFileHandle<>INVALID_HANDLE_VALUE then begin
  fSize:=GetFileSize(fFileHandle,pointer(@HighFileSize));
  fSize:=fSize or (TPasLLMUInt64(HighFileSize) shl 32);
  if fSize<1 then begin
   SetFilePointer(fFileHandle,1,nil,FILE_BEGIN);
   SetEndOfFile(fFileHandle);
   fSize:=1;
  end;
  CreateMapView;
 end else begin
  raise EPasLLMFileMappedStream.Create(SysErrorMessage(GetLastError));
 end;
end;
{$endif}

destructor TPasLLMFileMappedStream.Destroy;
begin
 CloseMapView;
{$ifdef Unix}
 if fFileHandle<>feInvalidHandle then begin
  fpclose(fFileHandle);
  fFileHandle:=feInvalidHandle;
 end;
 if fTemporary then begin
  FpUnlink(fFileName);
 end;
{$else}
 if fFileHandle<>INVALID_HANDLE_VALUE then begin
  CloseHandle(fFileHandle);
  fFileHandle:=INVALID_HANDLE_VALUE;
 end;
{$endif}
 inherited Destroy;
end;

{ TPasLLMTokenList }

constructor TPasLLMTokenList.Create;
begin
 inherited Create;
 fTokens:=nil;
 fCount:=0;
end;

destructor TPasLLMTokenList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TPasLLMTokenList.Clear;
begin
 fTokens:=nil;
 fCount:=0;
end;

procedure TPasLLMTokenList.Add(const aToken:TPasLLMInt32);
begin
 inc(fCount);
 if length(fTokens)<fCount then begin
  SetLength(fTokens,fCount*2); // Grow the list by doubling its size
 end;
 fTokens[fCount-1]:=aToken;
end;

procedure TPasLLMTokenList.Append(const aTokens:array of TPasLLMInt32;const aCount:TPasLLMInt32);
var BaseIndex,Count,Index:TPasLLMInt32;
begin
 if aCount<0 then begin
  Count:=length(aTokens);
 end else begin
  Count:=Min(aCount,length(aTokens));
 end;
 if Count>0 then begin
  BaseIndex:=fCount;
  inc(fCount,Count);
  if length(fTokens)<fCount then begin
   SetLength(fTokens,fCount*2); // Grow the list by doubling its size
  end; 
  for Index:=0 to Count-1 do begin
   fTokens[BaseIndex+Index]:=aTokens[Index];
  end;
 end;
end;

procedure TPasLLMTokenList.Delete(const aIndex:TPasLLMInt32);
var Index:TPasLLMInt32;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  for Index:=aIndex to fCount-2 do begin
   fTokens[Index]:=fTokens[Index+1];
  end;
  dec(fCount);
 end;
end;

function TPasLLMTokenList.Get(const aIndex:TPasLLMInt32):TPasLLMInt32;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fTokens[aIndex];
 end else begin
  result:=-1;
 end;
end;

{$ifdef Windows}

// CalcLargeFileView - calculate large mapping size, view and offset
function CalcLargeFileView(const aRequiredViewSize,aRequiredViewOffset:TPasLLMUInt32;out aMappedViewSize,aMappedViewOffset:TPasLLMUInt32):TPasLLMUInt32;
var SystemInfo:TSystemInfo;
    AllocationGranularity:TPasLLMUInt32;
    AdjustedOffset:TPasLLMUInt32;
    Quotient,Remainder:TPasLLMUInt32;
begin

 GetSystemInfo(SystemInfo);
 AllocationGranularity:=SystemInfo.dwAllocationGranularity;

 // Calculate mapped view size
 if aRequiredViewSize<AllocationGranularity then begin
  aMappedViewSize:=AllocationGranularity+AllocationGranularity;
 end else begin
  Quotient:=aRequiredViewSize div AllocationGranularity;
  Remainder:=aRequiredViewSize mod AllocationGranularity;
  if Remainder>0 then begin
   // We have a remainder, so calc to add AllocationGranularity to RequiredViewSize - remainder
   aMappedViewSize:=aRequiredViewSize-Remainder+AllocationGranularity+AllocationGranularity;
  end else begin
   // We have a multiple of AllocationGranularity, so just return the RequiredViewSize as actual size
   aMappedViewSize:=aRequiredViewSize;
  end;
 end;

 // Calculate mapped view offset
 if aRequiredViewOffset<AllocationGranularity then begin
  AdjustedOffset:=AllocationGranularity-aRequiredViewOffset;
  aMappedViewOffset:=0;
 end else begin
  Quotient:=aRequiredViewOffset div AllocationGranularity;
  Remainder:=aRequiredViewOffset mod AllocationGranularity;
  if Remainder>0 then begin
   // We have a remainder
   AdjustedOffset:=Remainder;
   aMappedViewOffset:=aRequiredViewOffset-Remainder;
  end else begin
   // We have a multiple of AllocationGranularity
   aMappedViewOffset:=aRequiredViewOffset;
   AdjustedOffset:=0;
  end;
 end;

 result:=AdjustedOffset;
end;

// OpenLargeMapView - opens a view in a large mem mapped file to access data pointed to
// by RequiredViewOffset. Returns adjusted offset of memory where RequiredViewOffset
// can be accessed. Once finished with this view use CloseLargeMapView to close it.
function OpenLargeMapView(const aFileMapping:THandle;const aDesiredAccess:DWORD;const aRequiredViewSize,aRequiredViewOffset:TPasLLMUInt32):Pointer;
var LargeMapResourceSize:TPasLLMUInt32;
    LargeMapResourceOffset:TPasLLMUInt32;
    LargeMapAdjOffset:TPasLLMUInt32;
    LargeMemMapPtr:Pointer;
begin
 result:=nil;
 
 LargeMapAdjOffset:=CalcLargeFileView(aRequiredViewSize,aRequiredViewOffset,LargeMapResourceSize,LargeMapResourceOffset);

 LargeMemMapPtr:=MapViewOfFile(aFileMapping,aDesiredAccess,0,LargeMapResourceOffset,LargeMapResourceSize);
 if not assigned(LargeMemMapPtr) then begin
  // Try again with 0 as no bytes to map - otherwise end of files are a problem,
  // can't alloc size > max file size, let MapViewOfFile handle this with 0 specified as no bytes to map
  LargeMemMapPtr:=MapViewOfFile(aFileMapping,aDesiredAccess,0,LargeMapResourceOffset,0);
  if not assigned(LargeMemMapPtr) then begin
   exit;
  end;
 end;

 result:=Pointer(TPasLLMPtrUInt(TPasLLMPtrUInt(LargeMemMapPtr)+LargeMapAdjOffset));
end;

{$endif}

procedure TPasLLMFileMappedStream.CreateMapView;
{$ifdef Unix}
var StatInfo:BaseUnix.Stat;
begin
 if fpfstat(fFileHandle,StatInfo)<>0 then begin
  CloseMapView;
  raise EPasLLMFileMappedStream.Create('Cannot create map view.');
  exit;
 end;
 fSize:=StatInfo.st_size;
 if fSize=0 then begin
  CloseMapView;
  raise EPasLLMFileMappedStream.Create('Cannot create map view.');
  exit;
 end;
 fCurrentViewSize:=fViewSize;
 if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
  fCurrentViewSize:=fSize-fCurrentViewOffset;
 end;
 if ReadOnly then begin
  fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ,MAP_PRIVATE,fFileHandle,fCurrentViewOffset);
 end else begin
  fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ or PROT_WRITE,MAP_SHARED,fFileHandle,fCurrentViewOffset);
 end;
 if ptruint(fMemory)=ptruint(ptrint(-1)) then begin
  fMemory:=nil;
  CloseMapView;
  raise EPasLLMFileMappedStream.Create('Cannot create map view.');
 end;
end;
{$else}
begin
 if ReadOnly then begin
  fMapHandle:=CreateFileMapping(fFileHandle,nil,PAGE_READONLY,fSize shr 32,fSize and TPasLLMUInt32($ffffffff),nil);
 end else begin
  fMapHandle:=CreateFileMapping(fFileHandle,nil,PAGE_READWRITE,fSize shr 32,fSize and TPasLLMUInt32($ffffffff),nil);
 end;
 if fMapHandle=0 then begin
  raise EPasLLMFileMappedStream.Create(SysErrorMessage(GetLastError));
 end;
 fCurrentViewSize:=fViewSize;
 if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
  fCurrentViewSize:=fSize-fCurrentViewOffset;
 end;
 if ReadOnly then begin
  fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
 end else begin
  fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ or FILE_MAP_WRITE,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
 end;
 if not assigned(fMemory) then begin
  raise EPasLLMFileMappedStream.Create(SysErrorMessage(GetLastError));
 end;
end;
{$endif}

procedure TPasLLMFileMappedStream.UpdateMapView;
begin
 if (fPosition<fCurrentViewOffset) or ((fCurrentViewOffset+fCurrentViewSize)<fPosition) then begin
  if (fAllocationGranularity and (fAllocationGranularity-1))<>0 then begin
   fCurrentViewOffset:=fPosition;
   if (fCurrentViewOffset mod fAllocationGranularity)<>0 then begin
    dec(fCurrentViewOffset,fCurrentViewOffset mod fAllocationGranularity);
   end;
   fCurrentViewSize:=fViewSize;
   if (fCurrentViewSize mod fAllocationGranularity)<>0 then begin
    inc(fCurrentViewSize,fAllocationGranularity-(fCurrentViewOffset mod fAllocationGranularity));
   end;
  end else begin
   fCurrentViewOffset:=fPosition and not (fAllocationGranularity-1);
   fCurrentViewSize:=(fViewSize+(fAllocationGranularity-1)) and not (fAllocationGranularity-1);
  end;
  if fCurrentViewOffset<0 then begin
   fCurrentViewOffset:=0;
  end;
  if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
   fCurrentViewSize:=fSize-fCurrentViewOffset;
  end;
{$ifdef Unix}
  if assigned(fMemory) then begin
   fpmunmap(fMemory,fCurrentViewSize);
   fMemory:=nil;
  end;
  if ReadOnly then begin
   fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ,MAP_PRIVATE,fFileHandle,fCurrentViewOffset);
  end else begin
   fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ or PROT_WRITE,MAP_SHARED,fFileHandle,fCurrentViewOffset);
  end;
  if ptruint(fMemory)=ptruint(ptrint(-1)) then begin
   fMemory:=nil;
   CloseMapView;
   raise EPasLLMFileMappedStream.Create('Cannot create map view.');
  end;
{$else}
  if assigned(fMemory) then begin
   UnmapViewOfFile(fMemory);
   fMemory:=nil;
  end;
  if ReadOnly then begin
   fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
  end else begin
   fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ or FILE_MAP_WRITE,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
  end;
  if not assigned(fMemory) then begin
   raise EPasLLMFileMappedStream.Create(SysErrorMessage(GetLastError));
  end;
{$endif}
 end;
end;

procedure TPasLLMFileMappedStream.CloseMapView;
begin
{$ifdef Unix}
 if assigned(fMemory) then begin
  fpmunmap(fMemory,fCurrentViewSize);
  fMemory:=nil;
 end;
 if fFileHandle<>feInvalidHandle then begin
  fpClose(fFileHandle);
  fFileHandle:=feInvalidHandle;
 end;
{$else}
 if assigned(fMemory) then begin
  UnmapViewOfFile(fMemory);
  fMemory:=nil;
 end;
 if fMapHandle<>0 then begin
  CloseHandle(fMapHandle);
 end;
{$endif}
end;

procedure TPasLLMFileMappedStream.SetSize(NewSize:longint);
begin
 SetSize(int64(NewSize));
end;

procedure TPasLLMFileMappedStream.SetSize(const NewSize:int64);
begin
 CloseMapView;
{$ifdef Unix}
 FpLseek(fFileHandle,NewSize,Seek_Set);
{$else}
 SetFilePointer(fFileHandle,NewSize,nil,FILE_BEGIN);
 SetEndOfFile(fFileHandle);
{$endif}
 if fCurrentViewOffset>NewSize then begin
  fCurrentViewOffset:=(NewSize-1) and fViewMask;
 end;
 if fCurrentViewOffset<0 then begin
  fCurrentViewOffset:=0;
 end;
 fSize:=NewSize;
 CreateMapView;
end;

procedure TPasLLMFileMappedStream.Clear;
begin
 SetSize(1);
 fPosition:=0;
 fCurrentViewOffset:=0;
end;

procedure TPasLLMFileMappedStream.Flush;
begin
{$ifdef Unix}
 // At freepascal is no fpmsync or msync, so we must do it over this workaround
 CloseMapView;
 fpfsync(fFileHandle);
 CreateMapView;
{$else}
 if assigned(fMemory) then begin
  FlushViewOfFile(fMemory,fCurrentViewSize);
  FlushFileBuffers(fFileHandle);
 end else begin
  CloseMapView;
  FlushFileBuffers(fFileHandle);
  CreateMapView;
 end;
{$endif}
end;

function TPasLLMFileMappedStream.Seek(const Offset:int64;Origin:TSeekOrigin):int64;
begin
 case Origin of
  soBeginning:begin
   fPosition:=Offset;
  end;
  soCurrent:begin
   fPosition:=fPosition+Offset;
  end;
  soEnd:begin
   fPosition:=fSize+Offset;
  end;
 end;
 if fPosition>fSize then begin
  if fReadOnly then begin
   fPosition:=fSize;
   UpdateMapView;
   result:=-1;
   exit;
  end else begin
   SetSize(fPosition);
  end;
 end;
 UpdateMapView;
 result:=fPosition;
end;

function TPasLLMFileMappedStream.Read(var Buffer;Count:TPasLLMInt32):TPasLLMInt32;
var Remain,ToDo:TPasLLMInt32;
    BufferPointer:PAnsiChar;
begin
 if assigned(fMemory) then begin
  if (fPosition+Count)>Size then begin
   Count:=fSize-fPosition;
  end;
  Remain:=Count;
  BufferPointer:=@Buffer;
  while Remain>0 do begin
   UpdateMapView;
   ToDo:=Remain;
   if (fPosition+ToDo)>(fCurrentViewOffset+fCurrentViewSize) then begin
    ToDo:=(fCurrentViewOffset+fCurrentViewSize)-fPosition;
   end;
   Move(Pointer(TPasLLMPtrUInt(TPasLLMPtrUInt(fMemory)+(fPosition-fCurrentViewOffset)))^,BufferPointer^,ToDo);
   inc(fPosition,ToDo);
   inc(BufferPointer,ToDo);
   dec(Remain,ToDo);
  end;
  result:=Count;
 end else begin
  raise EPasLLMFileMappedStream.Create('No data available');
 end;
end;

function TPasLLMFileMappedStream.Write(const Buffer;Count:TPasLLMInt32):TPasLLMInt32;
var Remain,ToDo:TPasLLMInt32;
    BufferPointer:PAnsiChar;
begin
 if assigned(fMemory) and not ReadOnly then begin
  if (fPosition+Count)>fSize then begin
   SetSize(fPosition+Count);
  end;
  Remain:=Count;
  BufferPointer:=@Buffer;
  while Remain>0 do begin
   UpdateMapView;
   ToDo:=Remain;
   if (fPosition+ToDo)>(fCurrentViewOffset+fCurrentViewSize) then begin
    ToDo:=(fCurrentViewOffset+fCurrentViewSize)-fPosition;
   end;
   Move(BufferPointer^,Pointer(TPasLLMPtrUInt(TPasLLMPtrUInt(fMemory)+(fPosition-fCurrentViewOffset)))^,ToDo);
   inc(fPosition,ToDo);
   inc(BufferPointer,ToDo);
   dec(Remain,ToDo);
  end;
  result:=Count;
 end else begin
  raise EPasLLMFileMappedStream.Create('Cannot access memory data');
 end;
end;

{ TPasLLMHashMap }

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TEntityEnumerator.Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TEntityEnumerator.GetCurrent:TEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TEntityEnumerator.MoveNext:boolean;
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

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TKeyEnumerator.Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TKeyEnumerator.GetCurrent:TPasLLMHashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TKeyEnumerator.MoveNext:boolean;
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

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TPasLLMHashMapValueEnumerator.Create(const aHashMap:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TPasLLMHashMapValueEnumerator.GetCurrent:TPasLLMHashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TPasLLMHashMapValueEnumerator.MoveNext:boolean;
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

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TEntitiesObject.Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TEntitiesObject.GetEnumerator:TEntityEnumerator;
begin
 result:=TEntityEnumerator.Create(fOwner);
end;

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TKeysObject.Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TKeysObject.GetEnumerator:TKeyEnumerator;
begin
 result:=TKeyEnumerator.Create(fOwner);
end;

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TValuesObject.Create(const aOwner:TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TValuesObject.GetEnumerator:TPasLLMHashMapValueEnumerator;
begin
 result:=TPasLLMHashMapValueEnumerator.Create(fOwner);
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TValuesObject.GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TValuesObject.SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;

constructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Create(const aDefaultValue:TPasLLMHashMapValue);
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

destructor TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Destroy;
var Index:TPasLLMSizeInt;
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

procedure TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Clear(const aCanFree:Boolean);
var Index:TPasLLMSizeInt;
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

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.HashData(const aData:TPasLLMPointer;const aDataLength:TPasLLMUInt32):TPasLLMUInt32;
// xxHash32
const PRIME32_1=TPasLLMUInt32(2654435761);
      PRIME32_2=TPasLLMUInt32(2246822519);
      PRIME32_3=TPasLLMUInt32(3266489917);
      PRIME32_4=TPasLLMUInt32(668265263);
      PRIME32_5=TPasLLMUInt32(374761393);
      Seed=TPasLLMUInt32($1337c0d3);
      v1Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_1)+TPasLLMUInt64(PRIME32_2)));
      v2Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_2)));
      v3Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(0)));
      v4Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMInt64(TPasLLMInt64(Seed)-TPasLLMInt64(PRIME32_1))));
      HashInitialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_5)));
var v1,v2,v3,v4:TPasLLMUInt32;
    p,e,Limit:PPasLLMUInt8;
begin
 p:=aData;
 if aDataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PPasLLMUInt8Array(aData)^[aDataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v1,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v2,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v3,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v4,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
  until {%H-}TPasLLMPtrUInt(p)>{%H-}TPasLLMPtrUInt(e);
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
 inc(result,aDataLength);
 e:=@PPasLLMUInt8Array(aData)^[aDataLength];
 while ({%H-}TPasLLMPtrUInt(p)+SizeOf(TPasLLMUInt32))<={%H-}TPasLLMPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_3)),17)*TPasLLMUInt32(PRIME32_4);
{$else}
  inc(result,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*TPasLLMUInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(TPasLLMUInt32));
 end;
 while {%H-}TPasLLMPtrUInt(p)<{%H-}TPasLLMPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TPasLLMUInt8(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_5)),11)*TPasLLMUInt32(PRIME32_1);
{$else}
  inc(result,TPasLLMUInt8(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*TPasLLMUInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(TPasLLMUInt8));
 end;
 result:=(result xor (result shr 15))*TPasLLMUInt32(PRIME32_2);
 result:=(result xor (result shr 13))*TPasLLMUInt32(PRIME32_3);
 result:=result xor (result shr 16);
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.HashKey(const aKey:TPasLLMHashMapKey):TPasLLMUInt32;
var p:TPasLLMUInt64;
begin
 // We're hoping here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
{$ifndef ExtraStringHashMap}
 if (SizeOf(TPasLLMHashMapKey)=SizeOf(AnsiString)) and
    (TypeInfo(TPasLLMHashMapKey)=TypeInfo(AnsiString)) then begin
  result:=HashData(PPasLLMUInt8(@AnsiString(TPasLLMPointer(@aKey)^)[1]),length(AnsiString(TPasLLMPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(UTF8String)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(UTF8String)) then begin
  result:=HashData(PPasLLMUInt8(@UTF8String(TPasLLMPointer(@aKey)^)[1]),length(UTF8String(TPasLLMPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(RawByteString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(RawByteString)) then begin
  result:=HashData(PPasLLMUInt8(@RawByteString(TPasLLMPointer(@aKey)^)[1]),length(RawByteString(TPasLLMPointer(@aKey)^))*SizeOf(AnsiChar));
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(WideString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(WideString)) then begin
  result:=HashData(PPasLLMUInt8(@WideString(TPasLLMPointer(@aKey)^)[1]),length(WideString(TPasLLMPointer(@aKey)^))*SizeOf(WideChar));
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(UnicodeString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(UnicodeString)) then begin
  result:=HashData(PPasLLMUInt8(@UnicodeString(TPasLLMPointer(@aKey)^)[1]),length(UnicodeString(TPasLLMPointer(@aKey)^))*SizeOf(WideChar));
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(String)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(String)) then begin
  result:=HashData(PPasLLMUInt8(@String(TPasLLMPointer(@aKey)^)[1]),length(String(TPasLLMPointer(@aKey)^))*SizeOf(Char));
{end else if TypeInfo(TPasLLMHashMapKey)=TypeInfo(TPasLLMUUID) then begin
  result:=(TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[0]*73856093) xor
          (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[1]*19349669) xor
          (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[2]*83492791) xor
          (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[3]*50331653);}
 end else{$endif}begin
  case SizeOf(TPasLLMHashMapKey) of
   SizeOf(UInt16):begin
    // 16-bit big => use 16-bit integer-rehashing
    result:=TPasLLMUInt16(TPasLLMPointer(@aKey)^);
    result:=(result or (((not result) and $ffff) shl 16));
    dec(result,result shl 6);
    result:=result xor (result shr 17);
    dec(result,result shl 9);
    result:=result xor (result shl 4);
    dec(result,result shl 3);
    result:=result xor (result shl 10);
    result:=result xor (result shr 15);
   end;
   SizeOf(TPasLLMUInt32):begin
    // 32-bit big => use 32-bit integer-rehashing
    result:=TPasLLMUInt32(TPasLLMPointer(@aKey)^);
    dec(result,result shl 6);
    result:=result xor (result shr 17);
    dec(result,result shl 9);
    result:=result xor (result shl 4);
    dec(result,result shl 3);
    result:=result xor (result shl 10);
    result:=result xor (result shr 15);
   end;
   SizeOf(TPasLLMUInt64):begin
    // 64-bit big => use 64-bit to 32-bit integer-rehashing
    p:=TPasLLMUInt64(TPasLLMPointer(@aKey)^);
    p:=(not p)+(p shl 18); // p:=((p shl 18)-p-)1;
    p:=p xor (p shr 31);
    p:=p*21; // p:=(p+(p shl 2))+(p shl 4);
    p:=p xor (p shr 11);
    p:=p+(p shl 6);
    result:=TPasLLMUInt32(TPasLLMPtrUInt(p xor (p shr 22)));
   end;
{  SizeOf(TPasLLMHashMapUInt128):begin
    // 128-bit
   result:=(TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[0]*73856093) xor
           (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[1]*19349669) xor
           (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[2]*83492791) xor
           (TPasLLMUUID(TPasLLMPointer(@aKey)^).UInt32s[3]*50331653);
   end;}
   else begin
    result:=HashData(PPasLLMUInt8(TPasLLMPointer(@aKey)),SizeOf(TPasLLMHashMapKey));
   end;
  end;
 end;
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-TPasLLMUInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.CompareKey(const aKeyA,aKeyB:TPasLLMHashMapKey):boolean;
var Index:TPasLLMInt32;
    pA,pB:PPasLLMUInt8Array;
begin
 // We're hoping also here that the compiler is here so smart, so that the compiler optimizes the
 // unused if-branches away
{$ifndef ExtraStringHashMap}
 if (SizeOf(TPasLLMHashMapKey)=SizeOf(AnsiString)) and
    (TypeInfo(TPasLLMHashMapKey)=TypeInfo(AnsiString)) then begin
  result:=AnsiString(TPasLLMPointer(@aKeyA)^)=AnsiString(TPasLLMPointer(@aKeyB)^);
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(UTF8String)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(UTF8String)) then begin
  result:=UTF8String(TPasLLMPointer(@aKeyA)^)=UTF8String(TPasLLMPointer(@aKeyB)^);
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(RawByteString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(RawByteString)) then begin
  result:=RawByteString(TPasLLMPointer(@aKeyA)^)=RawByteString(TPasLLMPointer(@aKeyB)^);
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(WideString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(WideString)) then begin
  result:=WideString(TPasLLMPointer(@aKeyA)^)=WideString(TPasLLMPointer(@aKeyB)^);
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(UnicodeString)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(UnicodeString)) then begin
  result:=UnicodeString(TPasLLMPointer(@aKeyA)^)=UnicodeString(TPasLLMPointer(@aKeyB)^);
 end else if (SizeOf(TPasLLMHashMapKey)=SizeOf(String)) and
             (TypeInfo(TPasLLMHashMapKey)=TypeInfo(String)) then begin
  result:=String(TPasLLMPointer(@aKeyA)^)=String(TPasLLMPointer(@aKeyB)^);
 end else{$endif}begin
  case SizeOf(TPasLLMHashMapKey) of
   SizeOf(TPasLLMUInt8):begin
    result:=UInt8(TPasLLMPointer(@aKeyA)^)=UInt8(TPasLLMPointer(@aKeyB)^);
   end;
   SizeOf(TPasLLMUInt16):begin
    result:=UInt16(TPasLLMPointer(@aKeyA)^)=UInt16(TPasLLMPointer(@aKeyB)^);
   end;
   SizeOf(TPasLLMUInt32):begin
    result:=TPasLLMUInt32(TPasLLMPointer(@aKeyA)^)=TPasLLMUInt32(TPasLLMPointer(@aKeyB)^);
   end;
   SizeOf(TPasLLMUInt64):begin
    result:=TPasLLMUInt64(TPasLLMPointer(@aKeyA)^)=TPasLLMUInt64(TPasLLMPointer(@aKeyB)^);
   end;
{$ifdef fpc}
   SizeOf(TPasLLMHashMapUInt128):begin
    result:=(TPasLLMHashMapUInt128(TPasLLMPointer(@aKeyA)^)[0]=TPasLLMHashMapUInt128(TPasLLMPointer(@aKeyB)^)[0]) and
            (TPasLLMHashMapUInt128(TPasLLMPointer(@aKeyA)^)[1]=TPasLLMHashMapUInt128(TPasLLMPointer(@aKeyB)^)[1]);
   end;
{$endif}
   else begin
    Index:=0;
    pA:=@aKeyA;
    pB:=@aKeyB;
    while (Index+SizeOf(TPasLLMUInt32))<SizeOf(TPasLLMHashMapKey) do begin
     if TPasLLMUInt32(TPasLLMPointer(@pA^[Index])^)<>TPasLLMUInt32(TPasLLMPointer(@pB^[Index])^) then begin
      result:=false;
      exit;
     end;
     inc(Index,SizeOf(TPasLLMUInt32));
    end;
    while (Index+SizeOf(UInt8))<SizeOf(TPasLLMHashMapKey) do begin
     if UInt8(TPasLLMPointer(@pA^[Index])^)<>UInt8(TPasLLMPointer(@pB^[Index])^) then begin
      result:=false;
      exit;
     end;
     inc(Index,SizeOf(UInt8));
    end;
    result:=true;
   end;
  end;
 end;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.FindEntity(const aKey:TPasLLMHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TPasLLMSizeUInt;
begin
 HashCode:=HashKey(aKey);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 Index:=HashCode shr (32-fLogSize);
 Start:=Index;
 repeat
  result:=@fEntities[Index];
  if (result^.State=TEntity.Empty) or ((result^.State=TEntity.Used) and CompareKey(result^.Key,aKey)) then begin
   exit;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=nil;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.FindEntityForAdd(const aKey:TPasLLMHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TPasLLMSizeUInt;
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
    if CompareKey(result^.Key,aKey) then begin
     exit;
    end;
   end;
  end;
  Index:=(Index+Step) and Mask;
 until Index=Start;
 result:=DeletedEntity;
end;

procedure TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Resize;
var Index:TPasLLMSizeInt;
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

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Add(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue):PEntity;
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

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Get(const aKey:TPasLLMHashMapKey;const aCreateIfNotExist:boolean):PEntity;
var Value:TPasLLMHashMapValue;
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
 end;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.TryGet(const aKey:TPasLLMHashMapKey;out aValue:TPasLLMHashMapValue):boolean;
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

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.ExistKey(const aKey:TPasLLMHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
 end else begin
  result:=false;
 end;
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.Delete(const aKey:TPasLLMHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
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
end;

function TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) and (Entity^.State=TEntity.Used) then begin
  result:=Entity^.Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TPasLLMHashMap<TPasLLMHashMapKey,TPasLLMHashMapValue>.SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
begin
 Add(aKey,aValue);
end;

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntityEnumerator }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntityEnumerator.Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntityEnumerator.GetCurrent:TEntity;
begin
 result:=fHashMap.fEntities[fIndex];
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntityEnumerator.MoveNext:boolean;
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

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeyEnumerator }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeyEnumerator.Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeyEnumerator.GetCurrent:TPasLLMHashMapKey;
begin
 result:=fHashMap.fEntities[fIndex].Key;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeyEnumerator.MoveNext:boolean;
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

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.THashMapValueEnumerator }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.THashMapValueEnumerator.Create(const aHashMap:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 fHashMap:=aHashMap;
 fIndex:=-1;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.THashMapValueEnumerator.GetCurrent:TPasLLMHashMapValue;
begin
 result:=fHashMap.fEntities[fIndex].Value;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.THashMapValueEnumerator.MoveNext:boolean;
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

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntitiesObject }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntitiesObject.Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TEntitiesObject.GetEnumerator:TEntityEnumerator;
begin
 result:=TEntityEnumerator.Create(fOwner);
end;

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeysObject }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeysObject.Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TKeysObject.GetEnumerator:TKeyEnumerator;
begin
 result:=TKeyEnumerator.Create(fOwner);
end;

{ TPasLLMStringHashMap<TPasLLMHashMapValue>.TValuesObject }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.TValuesObject.Create(const aOwner:TPasLLMStringHashMap<TPasLLMHashMapValue>);
begin
 inherited Create;
 fOwner:=aOwner;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TValuesObject.GetEnumerator:THashMapValueEnumerator;
begin
 result:=THashMapValueEnumerator.Create(fOwner);
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TValuesObject.GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
begin
 result:=fOwner.GetValue(aKey);
end;

procedure TPasLLMStringHashMap<TPasLLMHashMapValue>.TValuesObject.SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
begin
 fOwner.SetValue(aKey,aValue);
end;

{ TPasLLMStringHashMap<TPasLLMHashMapValue> }

constructor TPasLLMStringHashMap<TPasLLMHashMapValue>.Create(const aDefaultValue:TPasLLMHashMapValue);
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

destructor TPasLLMStringHashMap<TPasLLMHashMapValue>.Destroy;
var Index:TPasLLMSizeInt;
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

procedure TPasLLMStringHashMap<TPasLLMHashMapValue>.Clear(const aCanFree:Boolean);
var Index:TPasLLMSizeInt;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.HashKey(const aKey:TPasLLMHashMapKey):TPasLLMUInt32;
// xxHash32
const PRIME32_1=TPasLLMUInt32(2654435761);
      PRIME32_2=TPasLLMUInt32(2246822519);
      PRIME32_3=TPasLLMUInt32(3266489917);
      PRIME32_4=TPasLLMUInt32(668265263);
      PRIME32_5=TPasLLMUInt32(374761393);
      Seed=TPasLLMUInt32($1337c0d3);
      v1Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_1)+TPasLLMUInt64(PRIME32_2)));
      v2Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_2)));
      v3Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(0)));
      v4Initialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMInt64(TPasLLMInt64(Seed)-TPasLLMInt64(PRIME32_1))));
      HashInitialization=TPasLLMUInt32(TPasLLMUInt64(TPasLLMUInt64(Seed)+TPasLLMUInt64(PRIME32_5)));
var v1,v2,v3,v4,DataLength:TPasLLMUInt32;
    p,e{,Limit}:PPasLLMUInt8;
begin
 p:=TPasLLMPointer(@aKey[1]);
 DataLength:=length(aKey)*SizeOf(aKey[1]);
 if DataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PPasLLMUInt8Array(TPasLLMPointer(@aKey[1]))^[DataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v1,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v2,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v3,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2)),13)*TPasLLMUInt32(PRIME32_1);
{$else}
   inc(v4,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*TPasLLMUInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(TPasLLMUInt32));
  until {%H-}TPasLLMPtrUInt(p)>{%H-}TPasLLMPtrUInt(e);
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
 e:=@PPasLLMUInt8Array(TPasLLMPointer(@aKey[1]))^[DataLength];
 while ({%H-}TPasLLMPtrUInt(p)+SizeOf(TPasLLMUInt32))<={%H-}TPasLLMPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_3)),17)*TPasLLMUInt32(PRIME32_4);
{$else}
  inc(result,TPasLLMUInt32(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*TPasLLMUInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(TPasLLMUInt32));
 end;
 while {%H-}TPasLLMPtrUInt(p)<{%H-}TPasLLMPtrUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(TPasLLMUInt8(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_5)),11)*TPasLLMUInt32(PRIME32_1);
{$else}
  inc(result,TPasLLMUInt8(TPasLLMPointer(p)^)*TPasLLMUInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*TPasLLMUInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(TPasLLMUInt8));
 end;
 result:=(result xor (result shr 15))*TPasLLMUInt32(PRIME32_2);
 result:=(result xor (result shr 13))*TPasLLMUInt32(PRIME32_3);
 result:=result xor (result shr 16);
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-TPasLLMUInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.FindEntity(const aKey:TPasLLMHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TPasLLMSizeUInt;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.FindEntityForAdd(const aKey:TPasLLMHashMapKey):PEntity;
var Index,HashCode,Mask,Step,Start:TPasLLMSizeUInt;
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

procedure TPasLLMStringHashMap<TPasLLMHashMapValue>.Resize;
var Index:TPasLLMSizeInt;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.Add(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue):PEntity;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.Get(const aKey:TPasLLMHashMapKey;const aCreateIfNotExist:boolean):PEntity;
var Value:TPasLLMHashMapValue;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.TryGet(const aKey:TPasLLMHashMapKey;out aValue:TPasLLMHashMapValue):boolean;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.ExistKey(const aKey:TPasLLMHashMapKey):boolean;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) then begin
  result:=Entity^.State=TEntity.Used;
 end else begin
  result:=false;
 end;
end;

function TPasLLMStringHashMap<TPasLLMHashMapValue>.Delete(const aKey:TPasLLMHashMapKey):boolean;
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

function TPasLLMStringHashMap<TPasLLMHashMapValue>.GetValue(const aKey:TPasLLMHashMapKey):TPasLLMHashMapValue;
var Entity:PEntity;
begin
 Entity:=FindEntity(aKey);
 if assigned(Entity) and (Entity^.State=TEntity.Used) then begin
  result:=Entity^.Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TPasLLMStringHashMap<TPasLLMHashMapValue>.SetValue(const aKey:TPasLLMHashMapKey;const aValue:TPasLLMHashMapValue);
begin
 Add(aKey,aValue);
end;

{ TPasLLMStringTree }

constructor TPasLLMStringTree.Create;
begin
 inherited Create;
 fRoot:=nil;
 Clear;
end;

destructor TPasLLMStringTree.Destroy;
begin
 Clear;
 inherited Destroy;
end;

function TPasLLMStringTree.CreateStringTreeNode(const aChar:AnsiChar):PPasLLMStringTreeNode;
begin
 GetMem(result,SizeOf(TPasLLMStringTreeNode));
 result^.TheChar:=aChar;
 result^.Data:=0;
 result^.DataExist:=false;
 result^.Previous:=nil;
 result^.Next:=nil;
 result^.Up:=nil;
 result^.Down:=nil;
end;

procedure TPasLLMStringTree.DestroyStringTreeNode(const aNode:PPasLLMStringTreeNode);
begin
 if assigned(aNode) then begin
  DestroyStringTreeNode(aNode^.Next);
  DestroyStringTreeNode(aNode^.Down);
  FreeMem(aNode);
 end;
end;

procedure TPasLLMStringTree.Clear;
begin
 DestroyStringTreeNode(fRoot);
 fRoot:=nil;
end;

procedure TPasLLMStringTree.Dumptree;
var Ident:TPasLLMInt32;
 procedure DumpNode(const aNode:PPasLLMStringTreeNode);
 var SubNode:PPasLLMStringTreeNode;
     IdentCounter,IdentOld:TPasLLMInt32;
 begin
  for IdentCounter:=1 to Ident do begin
   write(' ');
  end;
  write(aNode^.TheChar);
  IdentOld:=Ident;
  SubNode:=aNode^.Next;
  while assigned(SubNode) do begin
   write(SubNode.TheChar);
   if not assigned(SubNode^.Next) then begin
    break;
   end;
   inc(Ident);
   SubNode:=SubNode^.Next;
  end;
  writeln;
  inc(Ident);
  while assigned(SubNode) and (SubNode<>aNode) do begin
   if assigned(SubNode^.Down) then begin
    DumpNode(SubNode^.Down);
   end;
   SubNode:=SubNode^.Previous;
   dec(Ident);
  end;
  Ident:=IdentOld;
  if assigned(aNode^.Down) then begin
   DumpNode(aNode^.Down);
  end;
 end;
begin
 Ident:=0;
 DumpNode(fRoot);
end;

procedure TPasLLMStringTree.DumpList;
 procedure DumpNode(const aNode:PPasLLMStringTreeNode;const aParentStr:TPasLLMUTF8String);
 begin
  if assigned(aNode) then begin
   if aNode^.DataExist then begin
    writeln(aParentStr+TPasLLMUTF8String(aNode^.TheChar));
   end;
   if assigned(aNode^.Next) then begin
    DumpNode(aNode^.Next,aParentStr+TPasLLMUTF8String(aNode^.TheChar));
   end;
   if assigned(aNode^.Down) then begin
    DumpNode(aNode^.Down,aParentStr);
   end;
  end;
 end;
begin
 if assigned(fRoot) then begin
  DumpNode(fRoot,'');
 end;
end;

procedure TPasLLMStringTree.AppendTo(const aDestStringTree:TPasLLMStringTree);
 procedure DumpNode(const aNode:PPasLLMStringTreeNode;const aParentStr:TPasLLMUTF8String);
 begin
  if assigned(aNode) then begin
   if aNode^.DataExist then begin
    aDestStringTree.Add(aParentStr+aNode^.TheChar,aNode^.Data);
   end;
   if assigned(aNode^.Next) then begin
    DumpNode(aNode^.Next,aParentStr+aNode^.TheChar);
   end;
   if assigned(aNode^.Down) then begin
    DumpNode(aNode^.Down,aParentStr);
   end;
  end;
 end;
begin
 if assigned(aDestStringTree) and assigned(fRoot) then begin
  DumpNode(fRoot,'');
 end;
end;

procedure TPasLLMStringTree.Optimize(const aDestStringTree:TPasLLMStringTree);
 procedure DumpNode(const aNode:PPasLLMStringTreeNode;const aParentStr:TPasLLMUTF8String);
 begin
  if assigned(aNode) then begin
   if aNode^.DataExist then begin
    aDestStringTree.Add(aParentStr+aNode^.TheChar,aNode^.Data);
   end;
   if assigned(aNode^.Next) then begin
    DumpNode(aNode^.Next,aParentStr+aNode^.TheChar);
   end;
   if assigned(aNode^.Down) then begin
    DumpNode(aNode^.Down,aParentStr);
   end;
  end;
 end;
begin
 if assigned(aDestStringTree) then begin
  aDestStringTree.Clear;
  if assigned(fRoot) then begin
   DumpNode(fRoot,'');
  end;
 end;
end;

function TPasLLMStringTree.Add(const aContent:TPasLLMUTF8String;const aData:TPasLLMStringTreeData;const aReplace:boolean=false):boolean;
var StringLength,Position,PositionCounter:TPasLLMInt32;
    NewNode,LastNode,Node:PPasLLMStringTreeNode;
    StringChar,NodeChar:AnsiChar;
begin
 result:=false;
 StringLength:=length(aContent);
 if StringLength>0 then begin
  LastNode:=nil;
  Node:=fRoot;
  for Position:=1 to StringLength do begin
   StringChar:=aContent[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    if NodeChar=StringChar then begin
     LastNode:=Node;
     Node:=Node^.Next;
   end else begin
     while (NodeChar<StringChar) and assigned(Node^.Down) do begin
      Node:=Node^.Down;
      NodeChar:=Node^.TheChar;
     end;
     if NodeChar=StringChar then begin
      LastNode:=Node;
      Node:=Node^.Next;
     end else begin
      NewNode:=CreateStringTreeNode(StringChar);
      if NodeChar<StringChar then begin
       NewNode^.Down:=Node^.Down;
       NewNode^.Up:=Node;
       if assigned(NewNode^.Down) then begin
        NewNode^.Down^.Up:=NewNode;
       end;
       NewNode^.Previous:=Node^.Previous;
       Node^.Down:=NewNode;
      end else if NodeChar>StringChar then begin
       NewNode^.Down:=Node;
       NewNode^.Up:=Node^.Up;
       if assigned(NewNode^.Up) then begin
        NewNode^.Up^.Down:=NewNode;
       end;
       NewNode^.Previous:=Node^.Previous;
       if not assigned(NewNode^.Up) then begin
        if assigned(NewNode^.Previous) then begin
         NewNode^.Previous^.Next:=NewNode;
        end else begin
         fRoot:=NewNode;
        end;
       end;
       Node^.Up:=NewNode;
      end;
      LastNode:=NewNode;
      Node:=LastNode^.Next;
     end;
    end;
   end else begin
    for PositionCounter:=Position to StringLength do begin
     NewNode:=CreateStringTreeNode(aContent[PositionCounter]);
     if assigned(LastNode) then begin
      NewNode^.Previous:=LastNode;
      LastNode^.Next:=NewNode;
      LastNode:=LastNode^.Next;
     end else begin
      if not assigned(fRoot) then begin
       fRoot:=NewNode;
       LastNode:=fRoot;
      end;
     end;
    end;
    break;
   end;
  end;
  if assigned(LastNode) then begin
   if aReplace or not LastNode^.DataExist then begin
    LastNode^.Data:=aData;
    LastNode^.DataExist:=true;
    result:=true;
   end;
  end;
 end;
end;

function TPasLLMStringTree.Delete(const aContent:TPasLLMUTF8String):boolean;
var StringLength,Position:TPasLLMInt32;
    Node:PPasLLMStringTreeNode;
    StringChar,NodeChar:AnsiChar;
begin
 result:=false;
 StringLength:=length(aContent);
 if StringLength>0 then begin
  Node:=fRoot;
  for Position:=1 to StringLength do begin
   StringChar:=aContent[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if (Position=StringLength) and Node^.DataExist then begin
      Node^.DataExist:=false;
      result:=true;
      exit;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

function TPasLLMStringTree.Find(const aContent:TPasLLMUTF8String;const aPosition:TPasLLMInt32;var aData:TPasLLMStringTreeData):boolean;
var StringLength,Position:TPasLLMInt32;
    Node:PPasLLMStringTreeNode;
    StringChar,NodeChar:AnsiChar;
begin
 result:=false;
 StringLength:=(length(aContent)-aPosition)+1;
 if StringLength>0 then begin
  Node:=fRoot;
  for Position:=1 to StringLength do begin
   StringChar:=aContent[(Position+aPosition)-1];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if (Position=StringLength) and Node^.DataExist then begin
      aData:=Node^.Data;
      result:=true;
      exit;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

function TPasLLMStringTree.FindEx(const aContent:TPasLLMUTF8String;const aPosition:TPasLLMInt32;var aData:TPasLLMStringTreeData;var aLen:TPasLLMInt32;const aStopEarly:Boolean):boolean;
var StringLength,Position:TPasLLMInt32;
    Node:PPasLLMStringTreeNode;
    StringChar,NodeChar:AnsiChar;
begin
 result:=false;
 aLen:=0;
 StringLength:=(length(aContent)-aPosition)+1;
 if StringLength>0 then begin
  Node:=fRoot;
  for Position:=1 to StringLength do begin
   StringChar:=aContent[(Position+aPosition)-1];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if Node^.DataExist then begin
      aLen:=Position;
      aData:=Node^.Data;
      result:=true;
      if aStopEarly then begin
       break; // Stop early if requested
      end;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

{ TPasLLMRingBuffer }

constructor TPasLLMRingBuffer<T>.Create(const aCapacity:TPasLLMSizeInt);
begin

 inherited Create;

 if aCapacity<=0 then begin
  raise EPasLLM.Create('Capacity must be greater than zero');
 end;
 
 fCapacity:=aCapacity;
 
 fBuffer:=nil;
 SetLength(fBuffer,fCapacity);
 
 fHead:=0;
 
 fTail:=0;
 
 fCount:=0;

end;

destructor TPasLLMRingBuffer<T>.Destroy;
begin
 fBuffer:=nil; // Clear the buffer
 inherited Destroy;
end;

procedure TPasLLMRingBuffer<T>.Clear;
begin
 fHead:=0;
 fTail:=0;
 fCount:=0;
end;

function TPasLLMRingBuffer<T>.IsEmpty:Boolean;
begin
 result:=fCount=0; // Check if the count is zero
end;

function TPasLLMRingBuffer<T>.IsFull:Boolean;
begin
 result:=fCount=fCapacity; // Check if the count is equal to the capacity
end;

procedure TPasLLMRingBuffer<T>.Push(const aItem:T);
begin
 if fCount=fCapacity then begin
  inc(fHead); // Increment head if full
  if fHead>=fCapacity then begin
   fHead:=0; // Wrap around head if it exceeds capacity
  end;
 end else begin
  inc(fCount); // Increment count if not full
 end;
 fBuffer[fTail]:=aItem; // Store the item at the tail
 inc(fTail); // Increment tail
 if fTail>=fCapacity then begin
  fTail:=0; // Wrap around tail if it exceeds capacity
 end;
end;

function TPasLLMRingBuffer<T>.Pop:T;
begin
 if fCount=0 then begin
  raise EPasLLM.Create('Ring buffer is empty'); // Raise an error if empty
 end;
 result:=fBuffer[fHead]; // Get the item at the head
 inc(fHead); // Increment head
 if fHead>=fCapacity then begin
  fHead:=0; // Wrap around head if it exceeds capacity
 end;
 dec(fCount); // Decrement count
end;

function TPasLLMRingBuffer<T>.Peek:T;
begin
 if fCount=0 then begin
  raise EPasLLM.Create('Ring buffer is empty'); // Raise an error if empty
 end;
 result:=fBuffer[fHead]; // Get the item at the head without removing it
end;

function TPasLLMRingBuffer<T>.PeekAt(const aIndex:TPasLLMSizeInt):T;
var Index:TPasLLMSizeInt;
begin
 if (aIndex<0) or (aIndex>=fCount) then begin
  raise EPasLLM.Create('Index out of bounds'); // Raise an error if index is out of bounds
 end;
 Index:=(fHead+aIndex) mod fCapacity; // Calculate the actual index in the buffer
 result:=fBuffer[Index]; // Get the item at the calculated index
end;

{ TPasLLMHashRapidHash }

{$ifndef cpuamd64}
class procedure TPasLLMHashRapidHash.MUM(var aA,aB:TPasLLMUInt64);{$ifdef cpuamd64} assembler; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if defined(Windows)}
 // Pointer of aA is in rcx
 // Pointer of aB is in rdx
 // Save the pointers
 mov r8,rcx
 mov r9,rdx
 // Load aA and aB
 mov rax,qword ptr [rcx]
 mov rdx,qword ptr [rdx]
 // Multiply aA and aB
 mul rdx
 // Lo is in rax, Hi is in rdx 
 // Store the result back to aA and aB
 mov qword ptr [r8],rax
 mov qword ptr [r9],rdx
{$else}
 // Pointer of aA is in rdi
 // Pointer of aB is in rsi
 // Save the pointers
 mov r8,rdi
 mov r9,rsi
 // Load aA and aB
 mov rax,qword ptr [rdi]
 mov rdx,qword ptr [rsi]
 // Multiply aA and aB
 mul rdx
 // Lo is in rax, Hi is in rdx 
 // Store the result back to aA and aB
 mov qword ptr [r8],rax
 mov qword ptr [r9],rdx
{$ifend}
end;
{$else} 
var ha,hb,la,lb,hi,lo:TPasLLMUInt64;
    rh,rm0,rm1,rl:TPasLLMUInt64;
    t:TPasLLMUInt64;
    c:TPasLLMUInt64;
begin
 ha:=aA shr 32;
 hb:=aB shr 32;
 la:=TPasLLMUInt32(aA);
 lb:=TPasLLMUInt32(aB);
 rh:=ha*hb;
 rm0:=ha*lb;
 rm1:=hb*la;
 rl:=la*lb;
 t:=rl+(rm0 shl 32);
 c:=ord(t<rl) and 1;
 lo:=t+(rm1 shl 32);
 inc(c,ord(lo<t) and 1);
 hi:=rh+(rm0 shr 32)+(rm1 shr 32)+c;
 aA:=lo;
 aB:=hi;
end;
{$endif}

class function TPasLLMHashRapidHash.Mix(aA,aB:TPasLLMUInt64):TPasLLMUInt64;
begin
 MUM(aA,aB);
 result:=aA xor aB;
end; 

{$ifdef BIG_ENDIAN}
class function TPasLLMHashRapidHash.Read32(const aData:Pointer):TPasLLMUInt32;
begin
 result:=PPasLLMUInt32(aData)^;
 result:=(result shl 24) or ((result and TPasLLMUInt32($00ff0000)) shr 8) or ((result and TPasLLMUInt32($0000ff00)) shl 8) or (result shr 24);
end;

class function TPasLLMHashRapidHash.Read64(const aData:Pointer):TPasLLMUInt64;
begin
 result:=PPasLLMUInt64(aData)^;
 result:=(result shl 56) or 
         ((result and TPasLLMUInt64($00ff000000000000)) shr 8) or 
         ((result and TPasLLMUInt64($0000ff0000000000)) shl 8) or 
         ((result and TPasLLMUInt64($000000ff00000000)) shr 24) or 
         ((result and TPasLLMUInt64($00000000ff000000)) shl 24) or 
         ((result and TPasLLMUInt64($0000000000ff0000)) shr 40) or 
         ((result and TPasLLMUInt64($000000000000ff00)) shl 40) or
         (result shr 56);
end;

class function TPasLLMHashRapidHash.ReadSmall(const aData:Pointer;const aDataLength:TPasLLMSizeUInt):TPasLLMUInt64;
begin
 result:=(PPasLLMUInt8Array(aData)^[0] shl 56) or (PPasLLMUInt8Array(aData)^[TPasLLMPtrUInt(aDataLength) shr 1] shl 32) or PPasLLMUInt8Array(aData)^[TPasLLMPtrUInt(aDataLength)-1];
end;
{$endif}
{$endif}

{$ifdef cpuamd64}
function TPasLLMHashRapidHashProcess(aKey:pointer;aLength:TPasLLMSizeUInt;aSeed:TPasLLMUInt64):TPasLLMUInt64; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  
 // Windows x64 calling convention (forced by ms_abi_default, even on Non-Windows x86-64 targets)
 // Function arguments are passed in registers:  
 // rcx = aKey (pointer to the key data)
 // rdx = aLength (length of the key data) 
 // r8  = aSeed (initial seed value)
 // rax = return value (hash result)
 
 push r15 // Save non-volatile registers
 push r14
 push r12
 push rsi
 push rdi
 push rbx

 mov rdi,rdx // RDI = len
 mov r10,rcx // R10 = key pointer (p)

 // Load secrets
{$ifdef fpc}
 movabs r9,-8378864009470890807 // R9 = RAPID_SECRET1 (0x8bb84b93962eacc9)
 movabs rbx,3257665815644502181 // RBX = RAPID_SECRET0 (0x2d358dccaa6c78a5)
{$else}
 mov r9,-8378864009470890807    // R9 = RAPID_SECRET1 (0x8bb84b93962eacc9)
 mov rbx,3257665815644502181    // RBX = RAPID_SECRET0 (0x2d358dccaa6c78a5)
{$endif}

 // Initial seed calculation: seed ^= rapid_mix(seed^SECRET0, SECRET1) ^ len
 mov rax,r8  // RAX = initial seed
 xor rax,rbx // seed ^ SECRET0
 mul r9      // 128-bit multiply: (seed ^ SECRET0) * SECRET1. Result in RDX:RAX
 xor rdx,rdi // Mix high64 with len
 xor rdx,r8  // Mix with initial seed
 xor rdx,rax // Mix with low64. RDX now holds the updated seed.

 cmp rdi,16 // Check if len <= 16
 ja @Handle_Len_GreaterThan_16 // If len > 16, jump to long input handler

 // --- Handle Short Inputs (len <= 16) ---
 cmp rdi,4 // Check if len < 4
 jb @Handle_Len_1_to_3 // If len < 4, jump to very short input handler

 // --- Handle Length 4 to 16 ---
 // Corresponds to: a = (read32(p) << 32) | read32(p + len - 4); b = ... complex delta calculation ...
 lea rax,[r10+rdi] // RAX = p + len
 add rax,-4        // RAX = p + len - 4 (points to last 4 bytes)
 mov ecx,dword ptr [r10] // ECX = first 4 bytes
 shl rcx,32              // RCX = first 4 bytes << 32
 mov r8d,dword ptr [rax] // R8D = last 4 bytes
 or r8,rcx               // R8 = (first 4 bytes << 32) | last 4 bytes ('a' value)
 // Calculate 'b' value based on delta offset reads
 mov r11d,edi            // R11D = len
 and r11d,24             // R11D = len & 24
 mov ecx,edi             // ECX = len
 shr ecx,3               // ECX = len >> 3
 shr r11,cl              // R11 = (len & 24) >> (len >> 3) ('delta')
 mov ecx,dword ptr [r10+r11] // ECX = read32(p + delta)
 shl rcx,32                  // RCX = read32(p + delta) << 32
 sub rax,r11                 // RAX = (p + len - 4) - delta (points to plast - delta)
 mov eax,dword ptr [rax]     // EAX = read32(plast - delta)
 or rax,rcx                  // RAX = (read32(p + delta) << 32) | read32(plast - delta) ('b' value)
 // Fall through to final mix (@Final_Mix_And_Return_Path)
 // Note: R8 = 'a', RAX = 'b' for the final mixing stage.

@Final_Mix_And_Return_Path:
 // --- Final Mixing Stage ---
 // Finishes the hash calculation using accumulated state.
 // Input State: R8='a', RAX='b', RDX='seed', R9=SECRET1, RBX=SECRET0, RDI='len'
 xor rax,rdx  // b ^= seed
 xor r8,r9    // a ^= SECRET1
 mul r8       // rapid_mum(&rax, &r8) -> 128-bit result in RDX:RAX
 // Final rapid_mix step: rapid_mix(a^SECRET0^len, b^SECRET1)
 xor rdi,rbx  // len ^= SECRET0
 xor rdi,rax  // (len ^ SECRET0) ^ low64(a*b) -> RDI = a' = a^SECRET0^len
 xor r9,rdx   // SECRET1 ^= high64(a*b) -> R9 = b' = b^SECRET1
 mov rax,r9   // RAX = b'
 mul rdi      // rapid_mix(a', b') -> 128-bit result in RDX:RAX
 xor rax,rdx  // Final hash result = low64 ^ high64

 // --- Function Epilogue ---
 pop rbx      // Restore non-volatile registers
 pop rdi
 pop rsi
 pop r12
 pop r14
 pop r15
 jmp @Exit    // Jump to return

@Handle_Len_GreaterThan_16:
 // --- Handle Long Inputs (len > 16) ---
{$ifdef fpc}
 movabs r15,5418857496715711651 // R15 = RAPID_SECRET2 (0x4b33a62ed433d4a3)
{$else}
 mov r15,5418857496715711651    // R15 = RAPID_SECRET2 (0x4b33a62ed433d4a3)
{$endif}
 cmp rdi,49 // Check if len >= 49 (i.e., len > 48)
 jae @Handle_Len_GreaterThan_48 // If len > 48, jump to main loop processing

 // --- Handle Length 17 to 48 (or remainder < 48 after loops) ---
 mov r14,rdi // R14 = remaining length (i)

@Process_Remaining_17_to_48_Bytes_Mix:
 // Corresponds to `if(i>16)` block in C - mix first 8/16/24/32 bytes
 mov rcx,qword ptr [r10] // Read p[0..7]
 xor rcx,r15             // rcx ^ SECRET2
 xor rdx,qword ptr [r10+8] // seed ^ p[8..15]
 xor rdx,r9              // (seed ^ p[8..15]) ^ SECRET1
 mov rax,rdx
 mul rcx                 // rapid_mix(p[0..7]^S2, seed^p[8..15]^S1) -> RDX=new seed
 xor rdx,rax             // Finalize mix into RDX (seed)
 cmp r14,33 // Check if remaining length > 32
 jb @Read_Last_16_Bytes // If not, skip next mix (only needed for len > 32)
 // Handle `if(i > 32)` part - mix next 16 bytes
 xor r15,qword ptr [r10+16] // SECRET2 ^ p[16..23]
 xor rdx,qword ptr [r10+24] // seed ^ p[24..31]
 mov rax,rdx
 mul r15                 // rapid_mix(p[16..23]^S2, seed^p[24..31]) -> RDX=new seed
 xor rdx,rax             // Finalize mix into RDX (seed)
 // Fall through to read last 16 bytes

@Read_Last_16_Bytes:
 // Reads the last 16 bytes regardless of exact length (if > 16)
 // Corresponds to: a=read64(p+i-16), b=read64(p+i-8)
 mov r8,qword ptr [r10+r14-16] // R8 = a = read64(p+i-16)
 mov rax,qword ptr [r10+r14-8] // RAX = b = read64(p+i-8)
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing stage

@Handle_Len_1_to_3:
 // --- Handle Length 1 to 3 ---
 test rdi,rdi // Check if len == 0
 je @Handle_Len_0 // If len is 0, jump to zero handler
 // Corresponds to `a = rapid_readSmall(p, len); b = 0;`
 // Combine first byte, middle byte, and last byte into R8 ('a')
 movzx eax,byte ptr [r10] // Read p[0]
 shl rax,56               // RAX = p[0] << 56
 mov rcx,rdi              // RCX = len
 shr rcx,1                // RCX = len >> 1 (middle index)
 movzx ecx,byte ptr [r10+rcx] // Read p[len >> 1]
 shl rcx,32               // RCX = p[len >> 1] << 32
 or rcx,rax               // RCX = (p[0] << 56) | (p[len >> 1] << 32)
 movzx r8d,byte ptr [r10+rdi-1] // Read p[len - 1]
 or r8,rcx                // R8 = (p[0] << 56) | (p[len >> 1] << 32) | p[len - 1] ('a')
 xor eax,eax              // RAX = 0 ('b')
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing

@Handle_Len_GreaterThan_48:
 // --- Setup for Large Input Processing (len > 48) ---
 // Initialize intermediate seed states see1, see2 (from C code)
 mov rsi,rdx // RSI = seed (used for see2 accumulation)
 mov r11,rdx // R11 = seed (used for seed accumulation)
 mov rcx,rsi // RCX = seed (used for see1 accumulation)
 mov r14,rdi // R14 = remaining length (i)
 cmp rdi,96 // Check if length >= 96 for the unrolled loop
 jb @Process_48_Byte_Chunk // If less than 96, jump to handle potential 48-byte chunk first

@Loop_Process_96_Bytes:
 // --- Main Loop: Process 96 Bytes per Iteration (Unrolled) ---
 // Mix 6 blocks of 16 bytes (total 96 bytes) using seed, see1, see2 accumulators
 // Block 1 (seed: R11)
 mov rdx,qword ptr [r10]    // read p[0..7]
 xor r11,qword ptr [r10+8]  // seed ^ p[8..15]
 xor rdx,rbx                // p[0..7] ^ SECRET0
 mov rax,r11
 mul rdx                    // rapid_mix(...)
 mov r11,rax
 xor r11,rdx                // Update intermediate seed (R11)
 // Block 2 (see1: RCX)
 mov rdx,qword ptr [r10+16] // read p[16..23]
 xor rdx,r9                 // p[16..23] ^ SECRET1
 xor rcx,qword ptr [r10+24] // see1 ^ p[24..31]
 mov rax,rcx
 mul rdx                    // rapid_mix(...)
 mov rcx,rax
 xor rcx,rdx                // Update see1 (RCX)
 // Block 3 (see2: RSI)
 mov rdx,qword ptr [r10+32] // read p[32..39]
 mov rax,rsi                // see2
 xor rax,qword ptr [r10+40] // see2 ^ p[40..47]
 xor rdx,r15                // p[32..39] ^ SECRET2
 mul rdx                    // rapid_mix(...)
 mov rsi,rax
 xor rsi,rdx                // Update see2 (RSI)
 // Block 4 (seed: R11)
 mov rdx,qword ptr [r10+48] // read p[48..55]
 xor rdx,rbx                // p[48..55] ^ SECRET0
 xor r11,qword ptr [r10+56] // seed ^ p[56..63]
 mov rax,r11
 mul rdx                    // rapid_mix(...)
 mov r11,rdx
 xor r11,rax                // Update intermediate seed (R11)
 // Block 5 (see1: RCX)
 mov rdx,qword ptr [r10+64] // read p[64..71]
 xor rcx,qword ptr [r10+72] // see1 ^ p[72..79]
 xor rdx,r9                 // p[64..71] ^ SECRET1
 mov rax,rcx
 mul rdx                    // rapid_mix(...)
 mov rcx,rdx
 xor rcx,rax                // Update see1 (RCX)
 // Block 6 (see2: RSI)
 mov rdx,qword ptr [r10+80] // read p[80..87]
 xor rdx,r15                // p[80..87] ^ SECRET2
 xor rsi,qword ptr [r10+88] // see2 ^ p[88..95]
 mov rax,rsi
 mul rdx                    // rapid_mix(...)
 xor rdx,rax
 mov rsi,rdx                // Update see2 (RSI)

 add r10,96  // Advance key pointer by 96 bytes
 add r14,-96 // Decrement remaining length by 96
 cmp r14,95  // Check if remaining length >= 96
 ja @Loop_Process_96_Bytes // Loop if more 96-byte chunks exist

 // --- After 96-byte Loop ---
 cmp r14,48 // Check if remaining length >= 48
 jae @Process_48_Byte_Chunk // If yes, handle the final 48-byte chunk

 // --- Fall through if remaining length < 48 ---

@Combine_Loop_States_Check_Remainder:
 // Combine the intermediate seed states: seed ^= see1 ^ see2
 // R11 holds seed, RCX holds see1, RSI holds see2
 xor r11,rcx // R11 = seed ^ see1
 mov rdx,rsi // RDX = see2
 xor rdx,r11 // RDX = see2 ^ (seed ^ see1) = final seed state after loops
 // Check how many bytes remain (R14 holds remaining length `i`)
 cmp r14,17 // Check if remaining length >= 17 (i.e., i > 16)
 jae @Process_Remaining_17_to_48_Bytes_Mix // If > 16, process those remaining bytes using the 17-48 logic
 jmp @Read_Last_16_Bytes // Otherwise (remainder <= 16), just read the last 16 bytes

@Handle_Len_0:
 // --- Handle Length 0 ---
 // Set 'a' and 'b' to 0 for final mixing
 xor r8d,r8d // R8 = a = 0
 xor eax,eax // RAX = b = 0
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing

@Process_48_Byte_Chunk:
 // --- Process a Single 48-Byte Chunk ---
 // Used if len was 49-95 initially, or as the last chunk after the 96-byte loop.
 // Mix 3 blocks of 16 bytes (total 48 bytes)
 // Block 1 (seed: R11)
 mov rdx,qword ptr [r10]    // read p[0..7]
 xor rdx,rbx                // p[0..7] ^ SECRET0
 xor r11,qword ptr [r10+8]  // seed ^ p[8..15]
 mov rax,r11
 mul rdx                    // rapid_mix(...) -> RDX:RAX
 mov r8,rax                 // Store low64 temporarily in R8
 // Block 2 (see1: RCX)
 mov r12,qword ptr [r10+16] // read p[16..23]
 xor r12,r9                 // p[16..23] ^ SECRET1
 xor rcx,qword ptr [r10+24] // see1 ^ p[24..31]
 mov r11,rdx                // R11 = high64 from previous mix
 mov rax,rcx
 mul r12                    // rapid_mix(...) -> RDX:RAX
 xor r11,r8                 // Update R11 (intermediate seed)
 mov rcx,rdx                // RCX = high64 from this mix
 xor rcx,rax                // Update RCX (see1)
 // Block 3 (see2: RSI)
 mov rdx,qword ptr [r10+32] // read p[32..39]
 xor rdx,r15                // p[32..39] ^ SECRET2
 mov rax,rsi                // see2
 xor rax,qword ptr [r10+40] // see2 ^ p[40..47]
 mul rdx                    // rapid_mix(...) -> RDX:RAX
 xor rdx,rax                // high64 ^ low64
 mov rsi,rdx                // Update RSI (see2)

 add r10,48  // Advance key pointer by 48 bytes
 add r14,-48 // Decrement remaining length by 48
 jmp @Combine_Loop_States_Check_Remainder // Combine states and check remainder

@Exit:
 // Function return point (RET instruction would typically be here or implicitly after last POP)
end;
{$endif}

class function TPasLLMHashRapidHash.Process(const aKey:pointer;const aLength:TPasLLMSizeUInt;aSeed:TPasLLMUInt64):TMessageDigest;
{$ifdef cpuamd64}
begin
 result:=TPasLLMHashRapidHashProcess(aKey,aLength,aSeed);
end;
{$else}
var p,pLast:PPasLLMUInt8;
    i:TPasLLMSizeUInt;
    a,b:TPasLLMUInt64;
    Delta:TPasLLMUInt64;
    See1,See2:TPasLLMUInt64;
begin
 p:=aKey;
 aSeed:=aSeed xor (Mix(aSeed xor Secret0,Secret1) xor aLength);
 if aLength<=16 then begin
  if aLength>=4 then begin
   pLast:=@PPasLLMUInt8Array(aKey)^[aLength-4];
{$ifdef BIG_ENDIAN}   
   a:=(Read32(p) shl 32) or Read32(pLast);
{$else}
   a:=(PPasLLMUInt32(p)^ shl 32) or PPasLLMUInt32(pLast)^;
{$endif}
   Delta:=(aLength and 24) shr (aLength shr 3);
{$ifdef BIG_ENDIAN}
   b:=(Read32(@PPasLLMUInt8Array(aKey)^[Delta]) shl 32) or Read32(@PPasLLMUInt8Array(aKey)^[aLength-Delta]);
{$else}
   b:=(PPasLLMUInt32(@PPasLLMUInt8Array(aKey)^[Delta])^ shl 32) or PPasLLMUInt32(@PPasLLMUInt8Array(aKey)^[aLength-Delta])^;
{$endif}
  end else if aLength>0 then begin
{$ifdef BIG_ENDIAN}  
   a:=ReadSmall(p,aLength);
{$else}
   a:=(TPasLLMUInt64(PPasLLMUInt8Array(p)^[0]) shl 56) or (TPasLLMUInt64(PPasLLMUInt8Array(p)^[TPasLLMPtrUInt(aLength) shr 1]) shl 32) or PPasLLMUInt8Array(p)^[TPasLLMPtrUInt(aLength)-1];
{$endif}
   b:=0;
  end else begin
   a:=0;
   b:=0;
  end;
 end else begin
  i:=aLength;
  if i>48 then begin
   See1:=aSeed;
   See2:=aSeed;
   while i>=96 do begin
{$ifdef BIG_ENDIAN}
    aSeed:=Mix(Read64(p)^ xor Secret0,Read64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(Read64(@PPasLLMUInt8Array(p)^[16])^ xor Secret1,Read64(@PPasLLMUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(Read64(@PPasLLMUInt8Array(p)^[32])^ xor Secret2,Read64(@PPasLLMUInt8Array(p)^[40])^ xor See2);
    aSeed:=Mix(Read64(@PPasLLMUInt8Array(p)^[48])^ xor Secret0,Read64(@PPasLLMUInt8Array(p)^[56])^ xor aSeed);
    See1:=Mix(Read64(@PPasLLMUInt8Array(p)^[64])^ xor Secret1,Read64(@PPasLLMUInt8Array(p)^[72])^ xor See1);
    See2:=Mix(Read64(@PPasLLMUInt8Array(p)^[80])^ xor Secret2,Read64(@PPasLLMUInt8Array(p)^[88])^ xor See2);
{$else}
    aSeed:=Mix(PPasLLMUInt64(p)^ xor Secret0,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[16])^ xor Secret1,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[32])^ xor Secret2,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[40])^ xor See2);
    aSeed:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[48])^ xor Secret0,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[56])^ xor aSeed);
    See1:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[64])^ xor Secret1,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[72])^ xor See1);
    See2:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[80])^ xor Secret2,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[88])^ xor See2);
{$endif}
    p:=@PPasLLMUInt8Array(p)^[96];
    dec(i,96);
   end;
   if i>=48 then begin
{$ifdef BIG_ENDIAN}
    aSeed:=Mix(Read64(p)^ xor Secret0,Read64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(Read64(@PPasLLMUInt8Array(p)^[16])^ xor Secret1,Read64(@PPasLLMUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(Read64(@PPasLLMUInt8Array(p)^[32])^ xor Secret2,Read64(@PPasLLMUInt8Array(p)^[40])^ xor See2);
{$else}
    aSeed:=Mix(PPasLLMUInt64(p)^ xor Secret0,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[16])^ xor Secret1,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[32])^ xor Secret2,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[40])^ xor See2);
{$endif}
    p:=@PPasLLMUInt8Array(p)^[48];
    dec(i,48);
   end;
   aSeed:=aSeed xor See1 xor See2;
  end;
  if i>16 then begin
{$ifdef BIG_ENDIAN}
   aSeed:=Mix(Read64(p)^ xor Secret2,Read64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed xor Secret1);
   if i>32 then begin
    aSeed:=Mix(Read64(@PPasLLMUInt8Array(p)^[16])^ xor Secret2,Read64(@PPasLLMUInt8Array(p)^[24])^ xor aSeed);
   end;
{$else}
   aSeed:=Mix(PPasLLMUInt64(p)^ xor Secret2,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[8])^ xor aSeed xor Secret1);
   if i>32 then begin
    aSeed:=Mix(PPasLLMUInt64(@PPasLLMUInt8Array(p)^[16])^ xor Secret2,PPasLLMUInt64(@PPasLLMUInt8Array(p)^[24])^ xor aSeed);
   end;
{$endif}
  end;
{$ifdef BIG_ENDIAN}
  a:=Read64(@PPasLLMUInt8Array(aKey)^[i-16]);
  b:=Read64(@PPasLLMUInt8Array(aKey)^[i-8]);
{$else}
  a:=PPasLLMUInt64(@PPasLLMUInt8Array(aKey)^[i-16])^;
  b:=PPasLLMUInt64(@PPasLLMUInt8Array(aKey)^[i-8])^;
{$endif}
 end;
 a:=a xor Secret1;
 b:=b xor aSeed;
 MUM(a,b);
 result:=Mix(a xor Secret0 xor aLength,b xor Secret1);
end;
{$endif}                                                                                                                

{ TPasLLMConfiguration }

constructor TPasLLMConfiguration.Create;
begin
 inherited Create;
 fChatTemplate:='';
 fBOSToken:='';
 fEOSToken:='';
 fToolCallBeginToken:=''; 
 fToolCallEndToken:='';
 fToolCallBeginTokenID:=-1;
 fToolCallEndTokenID:=-1;
 fToolResponseBeginToken:='';
 fToolResponseEndToken:='';
 fToolResponseBeginTokenID:=-1;
 fToolResponseEndTokenID:=-1;
 fDim:=0;
 fHeadDim:=0;
 fHiddenDim:=0;
 fExpertHiddenDim:=0;
 fCountLayers:=0;
 fCountQueryHeads:=0;
 fCountKeyValueHeads:=0;
 fVocabularySize:=0;
 fMaximumSequenceLength:=0;
 fRotaryDim:=0;
 fDataType:=TPasLLMTensorDataType.Q80; // Default data type is Q80
 fCountExperts:=1;
 fCountActiveExperts:=1;
 fQKVClip:=Infinity;
 fQKNormalization:=false;
 fQKRMSNormalization:=false;
 fQKRoPENonInterleaved:=false;
 fPostNormalization:=false;
 fRoPENonInterleaved:=false;
 fPositionalEncoding:=TPasLLMPositionalEncoding.RoPE;
 fPositionalEncodings:=nil;
 fAttentionTypes:=nil;
 fSlidingWindowSizes:=nil;
 fSWAType:=TPasLLMSWAType.Standard;
 fSWAChunkSize:=0; // 0 => fallback to per-layer window size
 fQueryPreAttentionScalar:=0.0; // 0.0 => disabled
 fNormalizationEpsilon:=1e-5;
 fNormalizationType:=TPasLLMNormalizationType.RMSNorm;
 fActivationType:=TPasLLMActivationType.SILU;
 fAttnLogitSoftcapping:=0.0; // 0.0 => disabled
 fFinalLogitSoftcapping:=0.0; // 0.0 => disabled
 fRoPETheta:=500000.0;
 fBeginOfStreamToken:=[128000];
 fEndOfStreamToken:=[128001,128008,128009];
 fTemperature:=0.6; // 0.0 = greedy deterministic. 1.0 = original
 fTopP:=0.9; // top-p in nucleus sampling. 1.0 = off. 0.9 works well, but slower
 fPenaltyLastN:=0;
 fPenaltyRepeat:=1.0;
 fPenaltyFrequency:=0.0;
 fPenaltyPresence:=0.0;
end;

destructor TPasLLMConfiguration.Destroy;
begin
 fPositionalEncodings:=nil;
 fAttentionTypes:=nil;
 fSlidingWindowSizes:=nil;
 fBeginOfStreamToken:=nil;
 fEndOfStreamToken:=nil;
 inherited Destroy;
end;

{ TPasLLMTensor }

constructor TPasLLMTensor.Create(const aDim:TPasLLMInt32;const aDataType:TPasLLMTensorDataType);
var DataTypeData:PPasLLMDataTypeData;
begin
 inherited Create;

 fDataType:=aDataType;

 fSize:=aDim; // Set the size to the given dimension

 DataTypeData:=@PasLLMTensorDataTypes[fDataType];
 if DataTypeData^.GroupSize<>0 then begin
  fDataSize:=(fSize div DataTypeData^.GroupSize)*DataTypeData^.GroupBytes;
 end else begin
  fDataSize:=0;
 end;

 if fDataSize>0 then begin
  fAllocated:=true; // We allocated the quantized tensor
  GetMem(fValues,fDataSize); // Allocate the quantized values
  FillChar(fValues^,fDataSize,#0);
 end else begin
  fAllocated:=false;
  fValues:=nil;
 end;

end;

constructor TPasLLMTensor.Create(const aQ:PPasLLMInt8Array;const aSize:TPasLLMSizeInt;const aDataType:TPasLLMTensorDataType);
var DataTypeData:PPasLLMDataTypeData;
begin
 inherited Create;

 fDataType:=aDataType;

 fSize:=aSize; // Set the size to the given size

 DataTypeData:=@PasLLMTensorDataTypes[fDataType];
 if DataTypeData^.GroupSize<>0 then begin
  fDataSize:=(fSize div DataTypeData^.GroupSize)*DataTypeData^.GroupBytes;
 end else begin
  fDataSize:=0;
 end;

 fAllocated:=false; // We did not allocate the quantized tensor, it was passed in

 fValues:=aQ; // Set the quantized values to the given pointer

end;

constructor TPasLLMTensor.Create(const aRawPointer:Pointer;const aDataType:TPasLLMTensorDataType;const aDimensions:array of TPasLLMSizeInt);
var Index,Dimension:TPasLLMSizeInt;
    DataTypeData:PPasLLMDataTypeData;
begin
 inherited Create;

 fDataType:=aDataType;

 fAllocated:=false;

 if length(aDimensions)>0 then begin
  fSize:=1;
  for Index:=0 to length(aDimensions)-1 do begin
   Dimension:=aDimensions[Index];
   if Dimension>0 then begin
    fSize:=fSize*Dimension;
   end;
  end;
 end else begin
  fSize:=0;
 end;

 DataTypeData:=@PasLLMTensorDataTypes[fDataType];
 if DataTypeData^.GroupSize<>0 then begin
  fDataSize:=(fSize div DataTypeData^.GroupSize)*DataTypeData^.GroupBytes;
 end else begin
  fDataSize:=0;
 end;

 fValues:=aRawPointer;

end;

destructor TPasLLMTensor.Destroy;
begin
 if fAllocated then begin
  FreeMem(fValues); // Free the quantized values if we allocated them
 end;
 fValues:=nil;
 inherited Destroy;
end;

procedure TPasLLMTensor.Reset;
begin
 if fAllocated then begin
  FillChar(fValues^,fDataSize,#0);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64DequantizeQ3F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign32xUInt8=record
      Values:array[0..31] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LCPI1_0:TAlign32xUInt8=(Values:(0,1,4,5,8,9,12,13,0,0,0,0,0,0,0,0,16,17,20,21,24,25,28,29,0,0,0,0,0,0,0,0));
      LCPI1_1:TPasLLMUInt32=TPasLLMUInt32($be800000);
      LCPI1_2:TPasLLMUInt32=TPasLLMUInt32(7);
      LCPI1_3:TPasLLMUInt32=TPasLLMUInt32(4294967292);
      LCPI1_4:TAlign4xUInt32=(Values:(8,11,14,17));
      LCPI1_6:TAlign4xUInt32=(Values:(20,23,0,0));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB1_9
  push rsi
  sub rsp, 256
  vmovaps dqword ptr [rsp + 240], xmm15
  vmovaps dqword ptr [rsp + 224], xmm14
  vmovaps dqword ptr [rsp + 208], xmm13
  vmovaps dqword ptr [rsp + 192], xmm12
  vmovaps dqword ptr [rsp + 176], xmm11
  vmovaps dqword ptr [rsp + 160], xmm10
  vmovaps dqword ptr [rsp + 144], xmm9
  vmovaps dqword ptr [rsp + 128], xmm8
  vmovaps dqword ptr [rsp + 112], xmm7
  vmovaps dqword ptr [rsp + 96], xmm6
  mov eax, r8d
  cmp r8d, 57
  jae @LBB1_3
  xor r8d, r8d
  jmp @LBB1_6
@LBB1_3:
  lea r9, [rax - 1]
  shr r9, 3
  inc r9
  mov r10, r9
  and r10, -8
  lea r8, [8*r10]
  xor r11d, r11d
  vpbroadcastd ymm1, dword ptr [rip + LCPI1_2]
  vpbroadcastd ymm3, dword ptr [rip + LCPI1_3]
  mov rsi, rcx
@LBB1_4:
  vmovdqu ymm0, yword ptr [rdx + 4*r11]
  vpshufb ymm4, ymm0, yword ptr [rip + LCPI1_0]
  vpermq ymm4, ymm4, 232
  vpsllw xmm4, xmm4, 8
  vcvtph2ps ymm4, xmm4
  vbroadcastss ymm2, dword ptr [rip + LCPI1_1]
  vmulps ymm8, ymm4, ymm2
  vpsrld ymm4, ymm0, 26
  vpand ymm6, ymm4, ymm1
  vpsrld ymm7, ymm0, 29
  vpsrld ymm4, ymm0, 20
  vpsrld ymm5, ymm0, 23
  vpand ymm5, ymm5, ymm1
  vpand ymm4, ymm4, ymm1
  vpaddd ymm4, ymm4, ymm3
  vpaddd ymm5, ymm5, ymm3
  vcvtdq2ps ymm5, ymm5
  vcvtdq2ps ymm4, ymm4
  vmulps ymm4, ymm8, ymm4
  vmulps ymm5, ymm8, ymm5
  vpaddd ymm7, ymm7, ymm3
  vpaddd ymm6, ymm6, ymm3
  vcvtdq2ps ymm9, ymm6
  vcvtdq2ps ymm6, ymm7
  vmulps ymm6, ymm8, ymm6
  vmulps ymm7, ymm8, ymm9
  vpsrld ymm9, ymm0, 14
  vpsrld ymm10, ymm0, 17
  vpsrld ymm11, ymm0, 8
  vpsrld ymm0, ymm0, 11
  vpand ymm0, ymm0, ymm1
  vpand ymm11, ymm11, ymm1
  vpand ymm10, ymm10, ymm1
  vpand ymm9, ymm9, ymm1
  vpaddd ymm9, ymm9, ymm3
  vpaddd ymm10, ymm10, ymm3
  vpaddd ymm11, ymm11, ymm3
  vpaddd ymm0, ymm0, ymm3
  vcvtdq2ps ymm0, ymm0
  vcvtdq2ps ymm11, ymm11
  vcvtdq2ps ymm10, ymm10
  vcvtdq2ps ymm9, ymm9
  vmulps ymm9, ymm8, ymm9
  vmulps ymm10, ymm8, ymm10
  vmulps ymm11, ymm8, ymm11
  vmulps ymm12, ymm8, ymm0
  vunpcklps ymm0, ymm7, ymm6
  vshufps ymm8, ymm5, ymm4, 17
  vshufps ymm0, ymm8, ymm0, 226
  vshufps ymm8, ymm12, ymm11, 17
  vextractf128 xmm8, ymm8, 1
  vshufps ymm13, ymm10, ymm9, 17
  vshufps ymm13, ymm13, ymm13, 226
  vpermpd ymm13, ymm13, 170
  vshufps xmm8, xmm8, xmm13, 226
  vblendps ymm0, ymm0, ymm8, 15
  vmovups yword ptr [rsp + 64], ymm0
  vunpckhps ymm0, ymm7, ymm6
  vshufps ymm13, ymm5, ymm4, 51
  vshufps ymm0, ymm13, ymm0, 226
  vshufps ymm13, ymm12, ymm11, 51
  vextractf128 xmm13, ymm13, 1
  vshufps ymm14, ymm10, ymm9, 51
  vshufps ymm14, ymm14, ymm14, 226
  vpermpd ymm14, ymm14, 170
  vshufps xmm13, xmm13, xmm14, 226
  vblendps ymm0, ymm0, ymm13, 15
  vmovups yword ptr [rsp + 32], ymm0
  vmovlhps xmm0, xmm10, xmm9
  vunpcklps xmm14, xmm11, xmm12
  vshufps xmm0, xmm14, xmm0, 36
  vunpcklps xmm14, xmm4, xmm5
  vinsertf128 ymm14, ymm0, xmm14, 1
  vmovlhps xmm15, xmm6, xmm7
  vshufps xmm15, xmm15, xmm15, 36
  vinsertf128 ymm15, ymm0, xmm15, 1
  vblendps ymm14, ymm14, ymm15, 192
  vblendps ymm0, ymm14, ymm0, 15
  vmovups yword ptr [rsp], ymm0
  vunpckhps xmm0, xmm9, xmm10
  vshufps xmm15, xmm12, xmm11, 51
  vshufps xmm0, xmm15, xmm0, 226
  vunpckhps xmm15, xmm7, xmm6
  vinsertf128 ymm15, ymm0, xmm15, 1
  vshufps xmm2, xmm5, xmm4, 51
  vshufps xmm2, xmm2, xmm2, 226
  vinsertf128 ymm2, ymm0, xmm2, 1
  vblendps ymm2, ymm2, ymm15, 192
  vblendps ymm15, ymm2, ymm0, 15
  vunpcklpd ymm0, ymm6, ymm7
  vunpcklps ymm2, ymm4, ymm5
  vshufps ymm0, ymm2, ymm0, 36
  vunpcklps ymm2, ymm11, ymm12
  vextractf128 xmm2, ymm2, 1
  vunpcklps ymm8, ymm9, ymm10
  vpermpd ymm8, ymm8, 170
  vblendps xmm2, xmm8, xmm2, 3
  vblendps ymm0, ymm0, ymm2, 15
  vunpckhpd ymm2, ymm6, ymm7
  vunpckhps ymm8, ymm4, ymm5
  vshufps ymm2, ymm8, ymm2, 36
  vunpckhps ymm8, ymm11, ymm12
  vextractf128 xmm8, ymm8, 1
  vunpckhps ymm13, ymm9, ymm10
  vpermpd ymm13, ymm13, 170
  vblendps xmm8, xmm13, xmm8, 3
  vblendps ymm2, ymm2, ymm8, 15
  vinsertps xmm8, xmm12, xmm11, 76
  vunpcklps xmm13, xmm9, xmm10
  vblendps xmm8, xmm13, xmm8, 3
  vunpcklps xmm13, xmm7, xmm6
  vinsertf128 ymm13, ymm0, xmm13, 1
  vinsertps xmm14, xmm5, xmm4, 76
  vinsertf128 ymm14, ymm0, xmm14, 1
  vblendps ymm13, ymm14, ymm13, 192
  vblendps ymm8, ymm13, ymm8, 15
  vunpckhps xmm11, xmm11, xmm12
  vinsertps xmm9, xmm9, xmm10, 179
  vblendps xmm9, xmm9, xmm11, 3
  vinsertps xmm6, xmm7, xmm6, 179
  vunpckhps xmm4, xmm4, xmm5
  vinsertf128 ymm5, ymm0, xmm6, 1
  vinsertf128 ymm4, ymm0, xmm4, 1
  vblendps ymm4, ymm4, ymm5, 192
  vblendps ymm4, ymm4, ymm9, 15
  vmovups yword ptr [rsi + 64], ymm4
  vmovups yword ptr [rsi + 32], ymm8
  vmovups yword ptr [rsi + 192], ymm2
  vmovups yword ptr [rsi + 128], ymm0
  vmovups yword ptr [rsi + 96], ymm15
  vmovups ymm0, yword ptr [rsp]
  vmovups yword ptr [rsi], ymm0
  vmovups ymm0, yword ptr [rsp + 32]
  vmovups yword ptr [rsi + 224], ymm0
  vmovups ymm0, yword ptr [rsp + 64]
  vmovups yword ptr [rsi + 160], ymm0
  add r11, 8
  add rsi, 256
  cmp r10, r11
  jne @LBB1_4
  cmp r9, r10
  je @LBB1_8
@LBB1_6:
  mov r9, r8
  shr r9, 1
  add rdx, r9
  vmovss xmm0, dword ptr [rip + LCPI1_1]
  vmovdqu xmm1, dqword ptr [rip + LCPI1_4]
  vmovq xmm2, qword ptr [rip + LCPI1_6]
  vpbroadcastd ymm3, dword ptr [rip + LCPI1_2]
  vpbroadcastd ymm4, dword ptr [rip + LCPI1_3]
@LBB1_7:
  mov r9d, dword ptr [rdx]
  vmovd xmm5, r9d
  vpbroadcastd ymm5, xmm5
  vpslld xmm6, xmm5, 8
  vcvtph2ps xmm6, xmm6
  vmulss xmm6, xmm6, xmm0
  shr r9d, 26
  vpsrlvd xmm7, xmm5, xmm1
  vpsrlvd xmm8, xmm5, xmm2
  vmovd xmm9, r9d
  vpbroadcastd ymm9, xmm9
  vpblendd ymm7, ymm9, ymm7, 15
  vpbroadcastq ymm8, xmm8
  vpblendd ymm7, ymm7, ymm8, 48
  vpand ymm7, ymm7, ymm3
  vpsrld ymm5, ymm5, 29
  vpblendd ymm5, ymm7, ymm5, 128
  vpaddd ymm5, ymm5, ymm4
  vcvtdq2ps ymm5, ymm5
  vbroadcastss ymm6, xmm6
  vmulps ymm5, ymm6, ymm5
  vmovups yword ptr [rcx + 4*r8], ymm5
  add r8, 8
  add rdx, 4
  cmp r8, rax
  jb @LBB1_7
@LBB1_8:
  vmovaps xmm6, dqword ptr [rsp + 96]
  vmovaps xmm7, dqword ptr [rsp + 112]
  vmovaps xmm8, dqword ptr [rsp + 128]
  vmovaps xmm9, dqword ptr [rsp + 144]
  vmovaps xmm10, dqword ptr [rsp + 160]
  vmovaps xmm11, dqword ptr [rsp + 176]
  vmovaps xmm12, dqword ptr [rsp + 192]
  vmovaps xmm13, dqword ptr [rsp + 208]
  vmovaps xmm14, dqword ptr [rsp + 224]
  vmovaps xmm15, dqword ptr [rsp + 240]
  add rsp, 256
  pop rsi
@LBB1_9:
  vzeroupper
 end;
{$endif}

procedure PascalDequantizeQ3F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index,BaseIndex:TPasLLMSizeInt;
    QValue:TPasLLMUInt32;
    Scale:TPasLLMFloat;
begin
 for Index:=0 to (aCount shr 3)-1 do begin
  QValue:=PPasLLMUInt32Array(aQ)^[Index];
  BaseIndex:=Index shl 3;
  Scale:=FP8E5M2ToFloat32Table[QValue and $ff]*-0.25;
  PPasLLMFloatArray(aX)^[BaseIndex+0]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(0*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+1]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(1*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+2]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(2*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+3]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(3*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+4]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(4*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+5]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(5*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+6]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(6*3)))) and $7)-4)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+7]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(7*3)))) and $7)-4)*Scale;
 end;
end;

procedure PascalDequantizeQ6F16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index,BaseIndex:TPasLLMSizeInt;
    QValue:TPasLLMUInt64;
    Scale:TPasLLMFloat;
begin
 for Index:=0 to (aCount shr 3)-1 do begin
  QValue:=PPasLLMUInt64Array(aQ)^[Index];
  BaseIndex:=Index shl 3;
  Scale:=ConvertFloat16ToFloat32(QValue and $ffff)*-0.03125;
  PPasLLMFloatArray(aX)^[BaseIndex+0]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(0*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+1]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(1*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+2]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(2*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+3]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(3*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+4]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(4*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+5]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(5*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+6]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(6*6)))) and $3f)-32)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+7]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (16+(7*6)))) and $3f)-32)*Scale;
 end;
end;

procedure PascalDequantizeQ7F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index,BaseIndex:TPasLLMSizeInt;
    QValue:TPasLLMUInt64;
    Scale:TPasLLMFloat;
begin
 for Index:=0 to (aCount shr 3)-1 do begin
  QValue:=PPasLLMUInt64Array(aQ)^[Index];
  BaseIndex:=Index shl 3;
  Scale:=FP8E5M2ToFloat32Table[QValue and $ff]*-0.015625;
  PPasLLMFloatArray(aX)^[BaseIndex+0]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(0*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+1]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(1*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+2]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(2*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+3]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(3*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+4]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(4*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+5]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(5*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+6]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(6*7)))) and $7f)-64)*Scale;
  PPasLLMFloatArray(aX)^[BaseIndex+7]:=((TPasLLMInt32(TPasLLMUInt32(QValue shr (8+(7*7)))) and $7f)-64)*Scale;
 end;
end;

procedure PascalDequantizeF8E4M3(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  PPasLLMFloatArray(aX)^[Index]:=FP8E4M3ToFloat32Table[PPasLLMUInt8Array(aQ)^[Index]];
 end;
end; 

{$ifdef cpuamd64}
procedure AMD64DequantizeQ40(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 cmp r8d, 31
 jle @L11
 sub rsp, 104
 mov eax, 252645135
 mov r9, rcx
 sar r8d, 5
 vmovaps dqword ptr [rsp+16], xmm7
 vmovd xmm7, eax
 mov rcx, rdx
 xor r10d, r10d
 mov eax, -117901064
 vmovaps dqword ptr [rsp], xmm6
 vxorps xmm4, xmm4, xmm4
 vpbroadcastd xmm7, xmm7
 vmovd xmm6, eax
 vmovaps dqword ptr [rsp+32], xmm8
 vmovaps dqword ptr [rsp+48], xmm9
 vpbroadcastd xmm6, xmm6
 vmovaps dqword ptr [rsp+64], xmm10
 vmovaps dqword ptr [rsp+80], xmm11
 jmp @L6
@L7:
 vmovdqu xmm1, dqword ptr [rcx]
 vbroadcastss xmm2, xmm0
 add r10d, 1
 add rcx, 18
 vpsrlw xmm0, xmm1, 4
 vpand xmm1, xmm1, xmm7
 vpand xmm0, xmm7, xmm0
 vpaddb xmm1, xmm1, xmm6
 vpaddb xmm0, xmm0, xmm6
 vpmovsxbw xmm10, xmm1
 vpmovsxbw xmm3, xmm0
 vpsrldq xmm0, xmm0, 8
 vpmovsxwd xmm11, xmm10
 vpmovsxbw xmm0, xmm0
 vpsrldq xmm1, xmm1, 8
 vpmovsxwd xmm8, xmm3
 vcvtdq2ps xmm11, xmm11
 vpmovsxwd xmm5, xmm0
 vpsrldq xmm9, xmm0, 8
 vpmovsxbw xmm0, xmm1
 vcvtdq2ps xmm8, xmm8
 vpsrldq xmm1, xmm10, 8
 vpsrldq xmm3, xmm3, 8
 vpmovsxwd xmm10, xmm0
 vcvtdq2ps xmm5, xmm5
 vmulps xmm8, xmm8, xmm2
 vpmovsxwd xmm3, xmm3
 vpmovsxwd xmm1, xmm1
 vcvtdq2ps xmm10, xmm10
 vmulps xmm11, xmm11, xmm2
 vpsrldq xmm0, xmm0, 8
 vcvtdq2ps xmm3, xmm3
 vcvtdq2ps xmm1, xmm1
 vmulps xmm3, xmm3, xmm2
 vpmovsxwd xmm9, xmm9
 vpmovsxwd xmm0, xmm0
 vmulps xmm1, xmm1, xmm2
 vcvtdq2ps xmm9, xmm9
 vcvtdq2ps xmm0, xmm0
 vmulps xmm5, xmm5, xmm2
 vmulps xmm10, xmm10, xmm2
 vmulps xmm9, xmm9, xmm2
 vmulps xmm0, xmm0, xmm2
 vunpcklps xmm2, xmm11, xmm8
 vunpckhps xmm11, xmm11, xmm8
 vmovups dqword ptr [rax], xmm2
 vunpcklps xmm2, xmm1, xmm3
 vunpckhps xmm1, xmm1, xmm3
 vmovups dqword ptr [rax+48], xmm1
 vunpcklps xmm1, xmm10, xmm5
 vunpckhps xmm10, xmm10, xmm5
 vmovups dqword ptr [rax+16], xmm11
 vmovups dqword ptr [rax+64], xmm1
 vunpcklps xmm1, xmm0, xmm9
 vunpckhps xmm0, xmm0, xmm9
 vmovups dqword ptr [rax+32], xmm2
 vmovups dqword ptr [rax+80], xmm10
 vmovups dqword ptr [rax+96], xmm1
 vmovups dqword ptr [rax+112], xmm0
 cmp r8d, r10d
 jle @L15
@L6:
 vpxor xmm5, xmm5, xmm5
 vpinsrw xmm0, xmm5, word ptr [rcx+16], 0
 lea rdx, [rcx+16]
 mov rax, r9
 sub r9, -128
 vcvtph2ps xmm0, xmm0
 cmp rax, rdx
 jnb @L7
 cmp rcx, r9
 jnb @L7
 movzx edx, byte ptr [rcx]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+4], xmm1
 movzx edx, byte ptr [rcx+1]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+8], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+12], xmm1
 movzx edx, byte ptr [rcx+2]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+16], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+20], xmm1
 movzx edx, byte ptr [rcx+3]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+24], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+28], xmm1
 movzx edx, byte ptr [rcx+4]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+32], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+36], xmm1
 movzx edx, byte ptr [rcx+5]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+40], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+44], xmm1
 movzx edx, byte ptr [rcx+6]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+48], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+52], xmm1
 movzx edx, byte ptr [rcx+7]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+56], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+60], xmm1
 movzx edx, byte ptr [rcx+8]
 mov r11d, edx
 and r11d, 15
 shr dl, 4
 sub r11d, 8
 movzx edx, dl
 vcvtsi2ss xmm1, xmm4, r11d
 sub edx, 8
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+64], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+68], xmm1
 movzx edx, byte ptr [rcx+9]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+72], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+76], xmm1
 movzx edx, byte ptr [rcx+10]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+80], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+84], xmm1
 movzx edx, byte ptr [rcx+11]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+88], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+92], xmm1
 movzx edx, byte ptr [rcx+12]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+96], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+100], xmm1
 movzx edx, byte ptr [rcx+13]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+104], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+108], xmm1
 movzx edx, byte ptr [rcx+14]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+112], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+116], xmm1
 movzx edx, byte ptr [rcx+15]
 mov r11d, edx
 shr dl, 4
 and r11d, 15
 movzx edx, dl
 sub r11d, 8
 sub edx, 8
 add r10d, 1
 add rcx, 18
 vcvtsi2ss xmm1, xmm4, r11d
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+120], xmm1
 vcvtsi2ss xmm1, xmm4, edx
 vmulss xmm1, xmm1, xmm0
 vmovss dword ptr [rax+124], xmm1
 cmp r8d, r10d
 jg @L6
@L15:
 vmovaps xmm6, dqword ptr [rsp]
 vmovaps xmm7, dqword ptr [rsp+16]
 vmovaps xmm8, dqword ptr [rsp+32]
 vmovaps xmm9, dqword ptr [rsp+48]
 vmovaps xmm10, dqword ptr [rsp+64]
 vmovaps xmm11, dqword ptr [rsp+80]
 add rsp, 104
@L11:
end;
{$endif}

procedure PascalDequantizeQ40(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      HalfGroupSize=GroupSize shr 1; // Half group size for quantization
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloat;
    QGroup:PPasLLMUInt8Array;
    QValue:TPasLLMUInt8;
    Scale:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(HalfGroupSize+2)]);
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@QGroup^[HalfGroupSize]))^);
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to HalfGroupSize-1 do begin
   QValue:=QGroup^[Index];
   XGroup^:=(((TPasLLMInt8(QValue and $f))-8)*Scale); inc(XGroup);
   XGroup^:=(((TPasLLMInt8(QValue shr 4))-8)*Scale); inc(XGroup);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DequantizeQ40NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};    
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_2:TAlign16xUInt8=(Values:(129,129,155,178,199,217,233,246,0,10,23,39,57,78,101,127));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 40
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  add rcx, 96
  shr r8d, 4
  and r8d, -2
  lea rax, [r8 + 8*r8]
  xor r8d, r8d
  vmovd xmm0, dword ptr [rip + LCPI0_0]
  vmovdqu xmm1, dqword ptr [rip + LCPI0_1]
  vmovdqu xmm2, dqword ptr [rip + LCPI0_2]
@LBB0_2:
  vpinsrw xmm3, xmm0, word ptr [rdx + r8 + 16], 0
  vcvtph2ps xmm3, xmm3
  vmulss xmm3, xmm3, xmm0
  vbroadcastss ymm3, xmm3
  vmovdqu xmm4, dqword ptr [rdx + r8]
  vpsrlw xmm5, xmm4, 4
  vpand xmm4, xmm4, xmm1
  vpshufb xmm4, xmm2, xmm4
  vpand xmm5, xmm5, xmm1
  vpshufb xmm5, xmm2, xmm5
  vpunpcklbw xmm6, xmm4, xmm5
  vpunpckhbw xmm4, xmm4, xmm5
  vpmovsxbw ymm5, xmm6
  vpmovsxbw ymm4, xmm4
  vpmovsxwd ymm6, xmm5
  vcvtdq2ps ymm6, ymm6
  vextracti128 xmm5, ymm5, 1
  vpmovsxwd ymm5, xmm5
  vcvtdq2ps ymm5, ymm5
  vpmovsxwd ymm7, xmm4
  vcvtdq2ps ymm7, ymm7
  vextracti128 xmm4, ymm4, 1
  vpmovsxwd ymm4, xmm4
  vcvtdq2ps ymm4, ymm4
  vmulps ymm6, ymm3, ymm6
  vmovups yword ptr [rcx - 96], ymm6
  vmulps ymm5, ymm3, ymm5
  vmovups yword ptr [rcx - 64], ymm5
  vmulps ymm5, ymm3, ymm7
  vmovups yword ptr [rcx - 32], ymm5
  vmulps ymm3, ymm3, ymm4
  vmovups yword ptr [rcx], ymm3
  sub rcx, -128
  add r8, 18
  cmp rax, r8
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  add rsp, 40
@LBB0_4:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeQ40NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      HalfGroupSize=GroupSize shr 1; // Half group size for quantization
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloat;
    QGroup:PPasLLMUInt8Array;
    QValue:TPasLLMUInt8;
    Scale:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(HalfGroupSize+2)]);
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@QGroup^[HalfGroupSize]))^)*Q40NLInverseScale;
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to HalfGroupSize-1 do begin
   QValue:=QGroup^[Index];
   XGroup^:=Q40NLLookUpTable[QValue and $f]*Scale; inc(XGroup);
   XGroup^:=Q40NLLookUpTable[QValue shr 4]*Scale; inc(XGroup);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DequantizeQ41NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif}; 
     TAlign16xInt8=record
      Values:array[0..15] of TPasLLMInt8;
     end {$ifndef fpc}align 16{$endif};    
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_2:TAlign16xInt8=(Values:(-127,-127,-93,-65,-41,-23,-10,-3,0,3,10,23,41,65,93,127));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 40
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  add rcx, 96
  shr r8d, 4
  and r8d, -2
  lea rax, [r8 + 8*r8]
  xor r8d, r8d
  vmovd xmm0, dword ptr [rip + LCPI0_0]
  vmovdqu xmm1, dqword ptr [rip + LCPI0_1]
  vmovdqu xmm2, dqword ptr [rip + LCPI0_2]
@LBB0_2:
  vpinsrw xmm3, xmm0, word ptr [rdx + r8 + 16], 0
  vcvtph2ps xmm3, xmm3
  vmulss xmm3, xmm3, xmm0
  vbroadcastss ymm3, xmm3
  vmovdqu xmm4, dqword ptr [rdx + r8]
  vpsrlw xmm5, xmm4, 4
  vpand xmm4, xmm4, xmm1
  vpshufb xmm4, xmm2, xmm4
  vpand xmm5, xmm5, xmm1
  vpshufb xmm5, xmm2, xmm5
  vpunpcklbw xmm6, xmm4, xmm5
  vpunpckhbw xmm4, xmm4, xmm5
  vpmovsxbw ymm5, xmm6
  vpmovsxbw ymm4, xmm4
  vpmovsxwd ymm6, xmm5
  vcvtdq2ps ymm6, ymm6
  vextracti128 xmm5, ymm5, 1
  vpmovsxwd ymm5, xmm5
  vcvtdq2ps ymm5, ymm5
  vpmovsxwd ymm7, xmm4
  vcvtdq2ps ymm7, ymm7
  vextracti128 xmm4, ymm4, 1
  vpmovsxwd ymm4, xmm4
  vcvtdq2ps ymm4, ymm4
  vmulps ymm6, ymm3, ymm6
  vmovups yword ptr [rcx - 96], ymm6
  vmulps ymm5, ymm3, ymm5
  vmovups yword ptr [rcx - 64], ymm5
  vmulps ymm5, ymm3, ymm7
  vmovups yword ptr [rcx - 32], ymm5
  vmulps ymm3, ymm3, ymm4
  vmovups yword ptr [rcx], ymm3
  sub rcx, -128
  add r8, 18
  cmp rax, r8
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  add rsp, 40
@LBB0_4:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeQ41NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      HalfGroupSize=GroupSize shr 1; // Half group size for quantization
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloat;
    QGroup:PPasLLMUInt8Array;
    QValue:TPasLLMUInt8;
    Scale:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(HalfGroupSize+2)]);
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@QGroup^[HalfGroupSize]))^)*Q41NLInverseScale;
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to HalfGroupSize-1 do begin
   QValue:=QGroup^[Index];
   XGroup^:=Q41NLLookUpTable[QValue and $f]*Scale; inc(XGroup);
   XGroup^:=Q41NLLookUpTable[QValue shr 4]*Scale; inc(XGroup);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DequantizeQ42NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif}; 
     TAlign16xInt8=record
      Values:array[0..15] of TPasLLMInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925); // 0.145
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff); // mask for andps
      LCPI0_2:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_6:TPasLLMUInt8=TPasLLMUInt8(248); // 15 for addition
{$ifdef fpc}{$pop}{$endif}     
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 136
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  add rcx, 96
  shr r8d, 4
  and r8d, -2
  lea rax, [r8 + 8*r8]
  xor r8d, r8d
  vmovss xmm0, dword ptr [rip + LCPI0_0]
  vmovss xmm1, dword ptr [rip + LCPI0_1]
  vmovdqu xmm2, dqword ptr [rip + LCPI0_2]
  vpbroadcastb ymm3, byte ptr [rip + LCPI0_6]
  vbroadcastss ymm4, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
@LBB0_2:
  movsx r9d, byte ptr [rdx + r8 + 17]
  vcvtsi2ss xmm6, xmm15, r9d
  vmulss xmm6, xmm6, xmm0
  vbroadcastss ymm7, xmm6
  vsubss xmm6, xmm1, xmm6
  vbroadcastss ymm6, xmm6
  vmovdqu xmm8, dqword ptr [rdx + r8]
  vpsrlw xmm9, xmm8, 4
  vpand xmm8, xmm8, xmm2
  vpand xmm9, xmm9, xmm2
  vpunpckhbw xmm10, xmm8, xmm9
  vpunpcklbw xmm8, xmm8, xmm9
  vinserti128 ymm8, ymm8, xmm10, 1
  vpaddb ymm8, ymm8, ymm3
  vextracti128 xmm9, ymm8, 1
  vpshufd xmm10, xmm8, 238
  vpmovsxbd ymm8, xmm8
  vcvtdq2ps ymm8, ymm8
  vpmovsxbd ymm10, xmm10
  vcvtdq2ps ymm10, ymm10
  vpmovsxbd ymm11, xmm9
  vcvtdq2ps ymm11, ymm11
  vmulps ymm8, ymm8, ymm4
  vmulps ymm10, ymm10, ymm4
  vmulps ymm11, ymm11, ymm4
  vandps ymm12, ymm8, ymm5
  vmulps ymm13, ymm8, ymm7
  vmulps ymm12, ymm13, ymm12
  vandps ymm13, ymm10, ymm5
  vfmadd231ps ymm12, ymm6, ymm8
  vmulps ymm8, ymm10, ymm7
  vmulps ymm8, ymm8, ymm13
  vandps ymm13, ymm11, ymm5
  vfmadd231ps ymm8, ymm6, ymm10
  vmulps ymm10, ymm11, ymm7
  vmulps ymm10, ymm10, ymm13
  vpshufd xmm9, xmm9, 238
  vpmovsxbd ymm9, xmm9
  vcvtdq2ps ymm9, ymm9
  vmulps ymm9, ymm9, ymm4
  vfmadd231ps ymm10, ymm6, ymm11
  vandps ymm11, ymm9, ymm5
  vmulps ymm7, ymm9, ymm7
  vmulps ymm7, ymm11, ymm7
  vfmadd231ps ymm7, ymm6, ymm9
  movzx r9d, byte ptr [rdx + r8 + 16]
  vmovd xmm6, r9d
  vpslld xmm6, xmm6, 8
  vcvtph2ps xmm6, xmm6
  vbroadcastss ymm6, xmm6
  vmulps ymm9, ymm12, ymm6
  vmulps ymm8, ymm8, ymm6
  vmulps ymm10, ymm10, ymm6
  vmulps ymm6, ymm7, ymm6
  vmovups yword ptr [rcx - 96], ymm9
  vmovups yword ptr [rcx - 64], ymm8
  vmovups yword ptr [rcx - 32], ymm10
  vmovups yword ptr [rcx], ymm6
  sub rcx, -128
  add r8, 18
  cmp rax, r8
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  add rsp, 136
@LBB0_4:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeQ42NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      HalfGroupSize=GroupSize shr 1; // Half group size for quantization
      OneOver127=1.0/127.0;
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloat;
    QGroup:PPasLLMUInt8Array;
    QValue:TPasLLMUInt8;
    QScale,QCurve:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(HalfGroupSize+2)]);
  QScale:=FP8E5M2ToFloat32Table[PPasLLMUInt8(Pointer(@QGroup^[HalfGroupSize]))^];
  QCurve:=PPasLLMInt8(Pointer(@QGroup^[HalfGroupSize+1]))^*OneOver127;
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to HalfGroupSize-1 do begin
   QValue:=QGroup^[Index];
   XGroup^:=DecodeQ42NLValueNibble(QValue and $f,QCurve)*QScale;
   inc(XGroup);
   XGroup^:=DecodeQ42NLValueNibble(QValue shr 4,QCurve)*QScale;
   inc(XGroup);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DequantizeQ43NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif}; 
     TAlign16xInt8=record
      Values:array[0..15] of TPasLLMInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff); // mask for andps
      LCPI0_2:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_6:TPasLLMUInt8=TPasLLMUInt8(248); // 15 for addition
{$ifdef fpc}{$pop}{$endif}     
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_4
  sub rsp, 136
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  shr r8d, 5
  add rcx, 96
  lea rax, [r8 + 8*r8]
  lea rax, [r8 + 2*rax]
  xor r8d, r8d
  vmovss xmm0, dword ptr [rip + LCPI0_0]
  vmovss xmm1, dword ptr [rip + LCPI0_1]
  vmovdqu xmm2, dqword ptr [rip + LCPI0_2]
  vpbroadcastb ymm3, byte ptr [rip + LCPI0_6]
  vbroadcastss ymm4, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
@LBB0_2:
  movsx r9d, byte ptr [rdx + r8 + 18]
  vcvtsi2ss xmm6, xmm15, r9d
  vmulss xmm6, xmm6, xmm0
  vbroadcastss ymm7, xmm6
  vsubss xmm6, xmm1, xmm6
  vbroadcastss ymm6, xmm6
  vmovdqu xmm8, dqword ptr [rdx + r8]
  vpsrlw xmm9, xmm8, 4
  vpand xmm8, xmm8, xmm2
  vpand xmm9, xmm9, xmm2
  vpunpckhbw xmm10, xmm8, xmm9
  vpunpcklbw xmm8, xmm8, xmm9
  vinserti128 ymm8, ymm8, xmm10, 1
  vpaddb ymm8, ymm8, ymm3
  vextracti128 xmm9, ymm8, 1
  vpshufd xmm10, xmm8, 238
  vpmovsxbd ymm8, xmm8
  vcvtdq2ps ymm8, ymm8
  vpmovsxbd ymm10, xmm10
  vcvtdq2ps ymm10, ymm10
  vpmovsxbd ymm11, xmm9
  vcvtdq2ps ymm11, ymm11
  vmulps ymm8, ymm8, ymm4
  vmulps ymm10, ymm10, ymm4
  vmulps ymm11, ymm11, ymm4
  vandps ymm12, ymm8, ymm5
  vmulps ymm13, ymm8, ymm7
  vmulps ymm12, ymm13, ymm12
  vandps ymm13, ymm10, ymm5
  vfmadd231ps ymm12, ymm6, ymm8
  vmulps ymm8, ymm10, ymm7
  vmulps ymm8, ymm8, ymm13
  vandps ymm13, ymm11, ymm5
  vfmadd231ps ymm8, ymm6, ymm10
  vmulps ymm10, ymm11, ymm7
  vmulps ymm10, ymm10, ymm13
  vpshufd xmm9, xmm9, 238
  vpmovsxbd ymm9, xmm9
  vcvtdq2ps ymm9, ymm9
  vmulps ymm9, ymm9, ymm4
  vfmadd231ps ymm10, ymm6, ymm11
  vandps ymm11, ymm9, ymm5
  vmulps ymm7, ymm9, ymm7
  vmulps ymm7, ymm11, ymm7
  vfmadd231ps ymm7, ymm6, ymm9
  vpinsrw xmm6, xmm0, word ptr [rdx + r8 + 16], 0
  vcvtph2ps xmm6, xmm6
  vbroadcastss ymm6, xmm6
  vmulps ymm9, ymm12, ymm6
  vmulps ymm8, ymm8, ymm6
  vmulps ymm10, ymm10, ymm6
  vmulps ymm6, ymm7, ymm6
  vmovups yword ptr [rcx - 96], ymm9
  vmovups yword ptr [rcx - 64], ymm8
  vmovups yword ptr [rcx - 32], ymm10
  vmovups yword ptr [rcx], ymm6
  sub rcx, -128
  add r8, 19
  cmp rax, r8
  jne @LBB0_2
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  add rsp, 136
@LBB0_4:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeQ43NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      HalfGroupSize=GroupSize shr 1; // Half group size for quantization
      OneOver127=1.0/127.0;
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloat;
    QGroup:PPasLLMUInt8Array;
    QValue:TPasLLMUInt8;
    QScale,QCurve:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(HalfGroupSize+3)]);
  QScale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@QGroup^[HalfGroupSize]))^);
  QCurve:=PPasLLMInt8(Pointer(@QGroup^[HalfGroupSize+2]))^*OneOver127;
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to HalfGroupSize-1 do begin
   QValue:=QGroup^[Index];
   XGroup^:=DecodeQ43NLValueNibble(QValue and $f,QCurve)*QScale;
   inc(XGroup);
   XGroup^:=DecodeQ43NLValueNibble(QValue shr 4,QCurve)*QScale;
   inc(XGroup);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DequantizeQ80(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 31
  jle @L11
  vxorps xmm2, xmm2, xmm2
  sar r8d, 5
  xor r11d, r11d
  jmp @L6
@L8:
  vmovdqu ymm0, yword ptr [rdx]
  vbroadcastss ymm3, xmm3
  add r11, 1
  add rdx, 34
  vpmovsxbw ymm1, xmm0
  vextracti128 xmm0, ymm0, 1
  vpmovsxwd ymm4, xmm1
  vextracti128 xmm1, ymm1, 1
  vpmovsxbw ymm0, xmm0
  vpmovsxwd ymm1, xmm1
  vcvtdq2ps ymm4, ymm4
  vcvtdq2ps ymm1, ymm1
  vmulps ymm1, ymm1, ymm3
  vmulps ymm4, ymm4, ymm3
  vmovups yword ptr [r10+32], ymm1
  vpmovsxwd ymm1, xmm0
  vextracti128 xmm0, ymm0, 1
  vpmovsxwd ymm0, xmm0
  vcvtdq2ps ymm1, ymm1
  vmovups yword ptr [r10], ymm4
  vmulps ymm1, ymm1, ymm3
  vcvtdq2ps ymm0, ymm0
  vmulps ymm0, ymm0, ymm3
  vmovups yword ptr [r10+64], ymm1
  vmovups yword ptr [r10+96], ymm0
  cmp r8d, r11d
  jle @L13
@L6:
  vpxor xmm5, xmm5, xmm5
  vpinsrw xmm3, xmm5, word ptr [rdx+32], 0
  lea rax, [rdx+32]
  mov r10, rcx
  sub rcx, -128
  vcvtph2ps xmm3, xmm3
  vmovaps xmm1, xmm3
  cmp r10, rax
  jnb @L8
  cmp rdx, rcx
  jnb @L8
  xor eax, eax
@L3:
  movsx r9d, byte ptr [rdx+rax]
  vcvtsi2ss xmm0, xmm2, r9d
  vmulss xmm0, xmm0, xmm1
  vmovss dword ptr [r10+rax*4], xmm0
  add rax, 1
  cmp rax, 32
  jne @L3
  add r11, 1
  add rdx, 34
  cmp r8d, r11d
  jg @L6
@L13:
  vzeroupper
@L11:
end;
{$endif}

procedure PascalDequantizeQ80(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
var CountGroups,GroupIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMInt8Array;
    Scale:TPasLLMFloat;
begin
 CountGroups:=Count div GroupSize;
 for GroupIndex:=0 to CountGroups-1 do begin
  QGroup:=Pointer(@PPasLLMInt8Array(aQ)^[GroupIndex*(GroupSize+2)]);
  Scale:=ConvertFloat16ToFloat32(PPasLLMUInt16(Pointer(@QGroup^[GroupSize]))^);
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[GroupIndex*GroupSize]);
  for Index:=0 to GroupSize-1 do begin
   XGroup^[Index]:=QGroup^[Index]*Scale;
  end;
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64DequantizeF8E5M2(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_17
  mov eax, r8d
  cmp r8d, 3
  jbe @LBB0_2
  lea r9, [rcx + 4*rax]
  lea r10, [rdx + rax]
  cmp rcx, r10
  setb r10b
  cmp rdx, r9
  setb r9b
  test r10b, r9b
  je @LBB0_8
@LBB0_2:
  xor r8d, r8d
@LBB0_3:
  mov r9, r8
  test al, 1
  je @LBB0_5
  movzx r9d, byte ptr [rdx + r8]
  vmovd xmm0, r9d
  vpslld xmm0, xmm0, 8
  vcvtph2ps xmm0, xmm0
  vmovd dword ptr [rcx + 4*r8], xmm0
  mov r9, r8
  or r9, 1
@LBB0_5:
  lea r10, [rax - 1]
  cmp r8, r10
  je @LBB0_17
@LBB0_6:
  movzx r8d, byte ptr [rdx + r9]
  vmovd xmm0, r8d
  vpslld xmm0, xmm0, 8
  vcvtph2ps xmm0, xmm0
  vmovss dword ptr [rcx + 4*r9], xmm0
  movzx r8d, byte ptr [rdx + r9 + 1]
  vmovd xmm0, r8d
  vpslld xmm0, xmm0, 8
  vcvtph2ps xmm0, xmm0
  vmovd dword ptr [rcx + 4*r9 + 4], xmm0
  add r9, 2
  cmp rax, r9
  jne @LBB0_6
@LBB0_17:
  vzeroupper
  jmp @Exit
@LBB0_8:
  cmp r8d, 32
  jae @LBB0_10
  xor r8d, r8d
  jmp @LBB0_14
@LBB0_10:
  mov r8d, eax
  and r8d, 2147483616
  xor r9d, r9d
@LBB0_11:
  vpmovzxbw xmm0, qword ptr [rdx + r9]
  vpmovzxbw xmm1, qword ptr [rdx + r9 + 8]
  vpmovzxbw xmm2, qword ptr [rdx + r9 + 16]
  vpmovzxbw xmm3, qword ptr [rdx + r9 + 24]
  vpsllw xmm0, xmm0, 8
  vpsllw xmm1, xmm1, 8
  vpsllw xmm2, xmm2, 8
  vpsllw xmm3, xmm3, 8
  vcvtph2ps ymm0, xmm0
  vcvtph2ps ymm1, xmm1
  vcvtph2ps ymm2, xmm2
  vcvtph2ps ymm3, xmm3
  vmovdqu yword ptr [rcx + 4*r9], ymm0
  vmovups yword ptr [rcx + 4*r9 + 32], ymm1
  vmovups yword ptr [rcx + 4*r9 + 64], ymm2
  vmovups yword ptr [rcx + 4*r9 + 96], ymm3
  add r9, 32
  cmp r8, r9
  jne @LBB0_11
  cmp r8d, eax
  je @LBB0_17
  test al, 28
  je @LBB0_3
@LBB0_14:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
  vpxor xmm0, xmm0, xmm0
@LBB0_15:
  vmovd xmm1, dword ptr [rdx + r9]
  vpunpcklbw xmm1, xmm0, xmm1
  vcvtph2ps xmm1, xmm1
  vmovups dqword ptr [rcx + 4*r9], xmm1
  add r9, 4
  cmp r8, r9
  jne @LBB0_15
  cmp r8d, eax
  jne @LBB0_3
  jmp @LBB0_17
@Exit:
end;
{$endif}

procedure PascalDequantizeF8E5M2(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  PPasLLMFloatArray(aX)^[Index]:=FP8E5M2ToFloat32Table[PPasLLMUInt8Array(aQ)^[Index]];
 end;
end; 

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64DequantizeBF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_13
  mov eax, r8d
  cmp r8d, 3
  ja @LBB0_3
  xor r8d, r8d
  jmp @LBB0_12
@LBB0_3:
  cmp r8d, 32
  jae @LBB0_5
  xor r8d, r8d
  jmp @LBB0_9
@LBB0_5:
  mov r8d, eax
  and r8d, 2147483616
  lea r9d, [rax + rax]
  and r9d, -64
  xor r10d, r10d
@LBB0_6:
  vpmovzxwd ymm0, dqword ptr [rdx + r10]
  vpmovzxwd ymm1, dqword ptr [rdx + r10 + 16]
  vpmovzxwd ymm2, dqword ptr [rdx + r10 + 32]
  vpmovzxwd ymm3, dqword ptr [rdx + r10 + 48]
  vpslld ymm0, ymm0, 16
  vpslld ymm1, ymm1, 16
  vpslld ymm2, ymm2, 16
  vpslld ymm3, ymm3, 16
  vmovdqu yword ptr [rcx + 2*r10], ymm0
  vmovdqu yword ptr [rcx + 2*r10 + 32], ymm1
  vmovdqu yword ptr [rcx + 2*r10 + 64], ymm2
  vmovdqu yword ptr [rcx + 2*r10 + 96], ymm3
  add r10, 64
  cmp r9, r10
  jne @LBB0_6
  cmp r8d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_12
@LBB0_9:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
@LBB0_10:
  vpmovzxwd xmm0, qword ptr [rdx + 2*r9]
  vpslld xmm0, xmm0, 16
  vmovdqu dqword ptr [rcx + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_10
  cmp r8d, eax
  je @LBB0_13
@LBB0_12:
  movzx r9d, word ptr [rdx + 2*r8]
  shl r9d, 16
  mov dword ptr [rcx + 4*r8], r9d
  inc r8
  cmp rax, r8
  jne @LBB0_12
@LBB0_13:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeBF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  PPasLLMFloatArray(aX)^[Index]:=ConvertBFloat16ToFloat32(PPasLLMUInt16Array(aQ)^[Index]);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64DequantizeF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_13
  mov eax, r8d
  cmp r8d, 3
  ja @LBB0_3
  xor r8d, r8d
  jmp @LBB0_12
@LBB0_3:
  cmp r8d, 32
  jae @LBB0_5
  xor r8d, r8d
  jmp @LBB0_9
@LBB0_5:
  mov r8d, eax
  and r8d, 2147483616
  lea r9d, [rax + rax]
  and r9d, -64
  xor r10d, r10d
@LBB0_6:
  vcvtph2ps ymm0, dqword ptr [rdx + r10]
  vcvtph2ps ymm1, dqword ptr [rdx + r10 + 16]
  vcvtph2ps ymm2, dqword ptr [rdx + r10 + 32]
  vcvtph2ps ymm3, dqword ptr [rdx + r10 + 48]
  vmovdqu yword ptr [rcx + 2*r10], ymm0
  vmovups yword ptr [rcx + 2*r10 + 32], ymm1
  vmovups yword ptr [rcx + 2*r10 + 64], ymm2
  vmovups yword ptr [rcx + 2*r10 + 96], ymm3
  add r10, 64
  cmp r9, r10
  jne @LBB0_6
  cmp r8d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_12
@LBB0_9:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
@LBB0_10:
  vcvtph2ps xmm0, qword ptr [rdx + 2*r9]
  vmovdqu dqword ptr [rcx + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_10
  cmp r8d, eax
  je @LBB0_13
@LBB0_12:
  vpinsrw xmm0, xmm0, word ptr [rdx + 2*r8], 0
  vcvtph2ps xmm0, xmm0
  vmovd dword ptr [rcx + 4*r8], xmm0
  inc r8
  cmp rax, r8
  jne @LBB0_12
@LBB0_13:
  vzeroupper
end;
{$endif}

procedure PascalDequantizeF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  PPasLLMFloatArray(aX)^[Index]:=ConvertFloat16ToFloat32(PPasLLMUInt16Array(aQ)^[Index]);
 end;
end;

procedure TPasLLMTensor.Dequantize(const aX:PPasLLMFloatArray;const aCount:TPasLLMSizeInt);
begin
 case fDataType of
  TPasLLMTensorDataType.Q40:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ40(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ40(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q40NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ40NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ40NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q41NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ41NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ41NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q42NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ42NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ42NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q43NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ43NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ43NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q80:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeQ80(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ80(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q3F8:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    AMD64DequantizeQ3F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ3F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q6F16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
//  AMD64DequantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
    PascalDequantizeQ6F16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ6F16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q7F8:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
//  AMD64DequantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
    PascalDequantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F8_E4M3:begin
   PascalDequantizeF8E4M3(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
  end;
  TPasLLMTensorDataType.F8_E5M2:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    AMD64DequantizeF8E5M2(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeF8E5M2(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;   
  TPasLLMTensorDataType.BF16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    AMD64DequantizeBF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeBF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    AMD64DequantizeF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalDequantizeF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F32:begin
   Move(fValues^,aX^[0],aCount*SizeOf(TPasLLMFloat));
  end;
  else begin
  end;
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64QuantizeQ3F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($3727c5ac);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($40800000);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($40e00000);
      LCPI0_6:TPasLLMUInt32=TPasLLMUInt32($80000000);
      LCPI0_7:TPasLLMUInt32=TPasLLMUInt32($3effffff);
      LCPI0_8:TPasLLMUInt32=TPasLLMUInt32($4f000000);
      LCPI0_9:TPasLLMUInt32=TPasLLMUInt32(1792);
      LCPI0_10:TPasLLMUInt32=TPasLLMUInt32(14336);
      LCPI0_11:TPasLLMUInt32=TPasLLMUInt32(114688);
      LCPI0_12:TPasLLMUInt32=TPasLLMUInt32(917504);
      LCPI0_13:TPasLLMUInt32=TPasLLMUInt32(7340032);
      LCPI0_14:TPasLLMUInt32=TPasLLMUInt32(58720256);
      LCPI0_15:TPasLLMUInt32=TPasLLMUInt32(469762048);
      LCPI0_1:TAlign16xUInt8=(Values:(0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255));
      LCPI0_16:TAlign4xUInt32=(Values:(8,11,14,17));
      LCPI0_17:TAlign4xUInt32=(Values:(1792,14336,114688,917504));
      LCPI0_18:TAlign4xUInt32=(Values:(20,26,0,0));
      LCPI0_19:TAlign4xUInt32=(Values:(7340032,469762048,0,0));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  sub rsp, 744
  vmovaps dqword ptr [rsp + 720], xmm15
  vmovaps dqword ptr [rsp + 704], xmm14
  vmovaps dqword ptr [rsp + 688], xmm13
  vmovdqa dqword ptr [rsp + 672], xmm12
  vmovaps dqword ptr [rsp + 656], xmm11
  vmovdqa dqword ptr [rsp + 640], xmm10
  vmovaps dqword ptr [rsp + 624], xmm9
  vmovdqa dqword ptr [rsp + 608], xmm8
  vmovdqa dqword ptr [rsp + 592], xmm7
  vmovdqa dqword ptr [rsp + 576], xmm6
  xor eax, eax
  mov r9d, 0
  cmp r8d, 8
  jl @LBB0_10
  lea r9d, [r8 - 8]
  mov eax, r9d
  shr eax, 3
  inc eax
  cmp r9d, 56
  jae @LBB0_3
  xor r10d, r10d
  xor r9d, r9d
  jmp @LBB0_6
@LBB0_3:
  mov r10d, eax
  and r10d, -8
  lea r9, [8*r10]
  vbroadcastss ymm0, dword ptr [rip + LCPI0_0]
  vmovups yword ptr [rsp + 416], ymm0
  xor r11d, r11d
  vbroadcastss ymm0, dword ptr [rip + LCPI0_6]
  vmovups yword ptr [rsp + 384], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_7]
  vmovups yword ptr [rsp + 352], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_9]
  vmovups yword ptr [rsp + 320], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_10]
  vmovups yword ptr [rsp + 288], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_11]
  vmovups yword ptr [rsp + 256], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_12]
  vmovups yword ptr [rsp + 224], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_13]
  vmovups yword ptr [rsp + 192], ymm0
  vbroadcastss ymm0, dword ptr [rip + LCPI0_14]
  vmovups yword ptr [rsp + 160], ymm0
  mov rsi, rcx
  vbroadcastss ymm0, dword ptr [rip + LCPI0_15]
  vmovups yword ptr [rsp + 128], ymm0
@LBB0_4:
  vmovups ymm0, yword ptr [rsi + 96]
  vmovups yword ptr [rsp + 32], ymm0
  vmovups xmm8, dqword ptr [rsi + 160]
  vmovups xmm12, dqword ptr [rsi + 128]
  vmovups xmm1, dqword ptr [rsi + 192]
  vmovups xmm4, dqword ptr [rsi + 224]
  vunpcklps xmm0, xmm12, xmm8
  vmovups xmm11, dqword ptr [rsi]
  vmovups xmm13, dqword ptr [rsi + 32]
  vmovups xmm14, dqword ptr [rsi + 64]
  vinsertf128 ymm3, ymm0, xmm0, 1
  vmovups xmm0, dqword ptr [rsi + 96]
  vmovlhps xmm5, xmm0, xmm14
  vunpcklps xmm6, xmm11, xmm13
  vshufps xmm2, xmm6, xmm5, 36
  vmovups yword ptr [rsp], ymm2
  vunpcklps xmm6, xmm1, xmm4
  vinsertf128 ymm6, ymm0, xmm6, 1
  vinsertps xmm7, xmm8, xmm12, 76
  vinsertf128 ymm7, ymm0, xmm7, 1
  vunpcklps xmm9, xmm14, xmm0
  vinsertps xmm10, xmm13, xmm11, 76
  vblendps xmm10, xmm9, xmm10, 3
  vblendps ymm6, ymm7, ymm6, 192
  vinsertps xmm7, xmm1, xmm4, 179
  vinsertps xmm9, xmm14, xmm0, 179
  vunpckhps xmm15, xmm11, xmm13
  vinsertf128 ymm7, ymm0, xmm7, 1
  vblendps xmm2, xmm9, xmm15, 3
  vunpckhps xmm9, xmm12, xmm8
  vinsertf128 ymm9, ymm0, xmm9, 1
  vblendps ymm7, ymm9, ymm7, 192
  vmovlhps xmm9, xmm4, xmm1
  vshufps xmm9, xmm9, xmm9, 36
  vinsertf128 ymm9, ymm0, xmm9, 1
  vblendps ymm3, ymm3, ymm9, 192
  vmovups yword ptr [rsp + 96], ymm3
  vmovups ymm5, yword ptr [rsi + 64]
  vunpckhps xmm1, xmm1, xmm4
  vmovups ymm9, yword ptr [rsi + 32]
  vblendps ymm3, ymm6, ymm10, 15
  vmovups yword ptr [rsp + 64], ymm3
  vmovups ymm10, yword ptr [rsi]
  vshufps xmm6, xmm8, xmm12, 51
  vmovups ymm15, yword ptr [rsi + 160]
  vblendps ymm2, ymm7, ymm2, 15
  vmovups yword ptr [rsp + 480], ymm2
  vmovups ymm4, yword ptr [rsi + 128]
  vinsertf128 ymm1, ymm0, xmm1, 1
  vshufps xmm2, xmm6, xmm6, 226
  vinsertf128 ymm2, ymm0, xmm2, 1
  vblendps ymm8, ymm2, ymm1, 192
  vmovups ymm7, yword ptr [rsi + 192]
  vunpckhps xmm1, xmm14, xmm0
  vmovups ymm3, yword ptr [rsi + 224]
  vshufps xmm2, xmm13, xmm11, 51
  vshufps xmm6, xmm2, xmm1, 226
  vunpcklpd ymm1, ymm3, ymm7
  vunpcklps ymm2, ymm4, ymm15
  vshufps ymm13, ymm2, ymm1, 36
  vunpcklps ymm1, ymm10, ymm9
  vextractf128 xmm1, ymm1, 1
  vmovups ymm0, yword ptr [rsp + 96]
  vblendps ymm0, ymm0, yword ptr [rsp], 15
  vmovups yword ptr [rsp + 448], ymm0
  vmovups ymm11, yword ptr [rsp + 32]
  vmovaps ymm0, ymm5
  vunpcklps ymm2, ymm5, ymm11
  vpermpd ymm2, ymm2, 170
  vblendps xmm1, xmm2, xmm1, 3
  vunpcklps ymm2, ymm7, ymm3
  vshufps ymm5, ymm15, ymm4, 17
  vshufps ymm14, ymm5, ymm2, 226
  vunpckhpd ymm2, ymm3, ymm7
  vunpckhps ymm5, ymm4, ymm15
  vshufps ymm2, ymm5, ymm2, 36
  vunpckhps ymm5, ymm10, ymm9
  vextractf128 xmm5, ymm5, 1
  vunpckhps ymm12, ymm0, ymm11
  vpermpd ymm12, ymm12, 170
  vblendps xmm12, xmm12, xmm5, 3
  vunpckhps ymm3, ymm7, ymm3
  vblendps ymm5, ymm8, ymm6, 15
  vshufps ymm6, ymm15, ymm4, 51
  vshufps ymm4, ymm9, ymm10, 17
  vextractf128 xmm7, ymm4, 1
  vblendps ymm13, ymm13, ymm1, 15
  vshufps ymm1, ymm11, ymm0, 17
  vmovaps ymm8, ymm0
  vshufps ymm1, ymm1, ymm1, 226
  vpermpd ymm1, ymm1, 170
  vshufps xmm1, xmm7, xmm1, 226
  vshufps ymm0, ymm6, ymm3, 226
  vshufps ymm6, ymm9, ymm10, 51
  vextractf128 xmm6, ymm6, 1
  vblendps ymm4, ymm2, ymm12, 15
  vmovups yword ptr [rsp + 544], ymm4
  vshufps ymm2, ymm11, ymm8, 51
  vshufps ymm2, ymm2, ymm2, 226
  vpermpd ymm2, ymm2, 170
  vblendps ymm9, ymm14, ymm1, 15
  vmovups yword ptr [rsp + 512], ymm9
  vshufps xmm1, xmm6, xmm2, 226
  vmovups ymm7, yword ptr [rsp + 416]
  vmovups ymm12, yword ptr [rsp + 64]
  vandps ymm2, ymm12, ymm7
  vmovups ymm14, yword ptr [rsp + 480]
  vandps ymm3, ymm14, ymm7
  vmovups ymm8, yword ptr [rsp + 448]
  vandps ymm6, ymm8, ymm7
  vmaxps ymm2, ymm2, ymm3
  vandps ymm3, ymm5, ymm7
  vmaxps ymm3, ymm6, ymm3
  vandps ymm6, ymm13, ymm7
  vmaxps ymm2, ymm2, ymm6
  vandps ymm6, ymm9, ymm7
  vmaxps ymm3, ymm3, ymm6
  vblendps ymm1, ymm0, ymm1, 15
  vmovups yword ptr [rsp + 96], ymm1
  vandps ymm0, ymm4, ymm7
  vmaxps ymm0, ymm2, ymm0
  vandps ymm1, ymm1, ymm7
  vmaxps ymm1, ymm3, ymm1
  vmaxps ymm0, ymm1, ymm0
{$ifdef fpc}
  vcvtps2ph xmm0, ymm0, 4
{$else}
  db $c4,$e3,$7d,$1d,$c0,$04
{$endif}
  vmovaps dqword ptr [rsp], xmm0
  vandps xmm0, xmm0, dqword ptr [rip + LCPI0_1]
  vcvtph2ps ymm1, xmm0
  vmovups yword ptr [rsp + 32], ymm1
  vrcpps ymm0, ymm1
  vmulps ymm1, ymm1, ymm0
  vbroadcastss ymm6, dword ptr [rip + LCPI0_2]
  vsubps ymm1, ymm6, ymm1
  vmulps ymm1, ymm0, ymm1
  vaddps ymm11, ymm0, ymm1
  vbroadcastss ymm15, dword ptr [rip + LCPI0_4]
  vmulps ymm0, ymm8, ymm15
  vmulps ymm0, ymm11, ymm0
  vsubps ymm0, ymm15, ymm0
  vxorps xmm1, xmm1, xmm1
  vmaxps ymm0, ymm0, ymm1
  vxorps xmm4, xmm4, xmm4
  vbroadcastss ymm10, dword ptr [rip + LCPI0_5]
  vminps ymm0, ymm10, ymm0
  vmovups ymm2, yword ptr [rsp + 384]
  vandps ymm1, ymm0, ymm2
  vmovups ymm3, yword ptr [rsp + 352]
  vorps ymm1, ymm1, ymm3
  vaddps ymm0, ymm0, ymm1
  vroundps ymm0, ymm0, 11
  vmulps ymm6, ymm12, ymm15
  vcvttps2dq ymm1, ymm0
  vmulps ymm6, ymm11, ymm6
  vsubps ymm6, ymm15, ymm6
  vmaxps ymm6, ymm6, ymm4
  vbroadcastss ymm9, dword ptr [rip + LCPI0_8]
  vsubps ymm0, ymm0, ymm9
  vminps ymm6, ymm10, ymm6
  vandps ymm7, ymm6, ymm2
  vorps ymm7, ymm7, ymm3
  vpsrad ymm12, ymm1, 31
  vaddps ymm6, ymm6, ymm7
  vroundps ymm6, ymm6, 11
  vcvttps2dq ymm8, ymm6
  vcvttps2dq ymm0, ymm0
  vpsrad ymm7, ymm8, 31
  vsubps ymm6, ymm6, ymm9
  vmulps ymm14, ymm14, ymm15
  vcvttps2dq ymm6, ymm6
  vmulps ymm14, ymm14, ymm11
  vsubps ymm14, ymm15, ymm14
  vmaxps ymm14, ymm14, ymm4
  vpand ymm12, ymm12, ymm0
  vminps ymm0, ymm14, ymm10
  vandps ymm14, ymm0, ymm2
  vorps ymm14, ymm14, ymm3
  vpand ymm6, ymm6, ymm7
  vaddps ymm0, ymm14, ymm0
  vroundps ymm7, ymm0, 11
  vcvttps2dq ymm0, ymm7
  vpsrad ymm14, ymm0, 31
  vsubps ymm7, ymm7, ymm9
  vmulps ymm5, ymm15, ymm5
  vmulps ymm5, ymm11, ymm5
  vcvttps2dq ymm7, ymm7
  vsubps ymm5, ymm15, ymm5
  vmaxps ymm5, ymm5, ymm4
  vminps ymm5, ymm10, ymm5
  vpand ymm7, ymm14, ymm7
  vandps ymm14, ymm5, ymm2
  vorps ymm14, ymm14, ymm3
  vaddps ymm5, ymm14, ymm5
  vpor ymm1, ymm12, ymm1
  vmovdqu yword ptr [rsp + 64], ymm1
  vroundps ymm12, ymm5, 11
  vcvttps2dq ymm5, ymm12
  vsubps ymm12, ymm12, ymm9
  vpsrad ymm14, ymm5, 31
  vcvttps2dq ymm12, ymm12
  vpand ymm12, ymm12, ymm14
  vmulps ymm4, ymm13, ymm15
  vmulps ymm4, ymm11, ymm4
  vsubps ymm4, ymm15, ymm4
  vpxor xmm1, xmm1, xmm1
  vmaxps ymm4, ymm4, ymm1
  vminps ymm4, ymm10, ymm4
  vpor ymm6, ymm8, ymm6
  vandps ymm8, ymm4, ymm2
  vorps ymm8, ymm8, ymm3
  vaddps ymm4, ymm8, ymm4
  vpor ymm0, ymm0, ymm7
  vroundps ymm4, ymm4, 11
  vcvttps2dq ymm7, ymm4
  vsubps ymm4, ymm4, ymm9
  vpsrad ymm8, ymm7, 31
  vcvttps2dq ymm4, ymm4
  vpand ymm8, ymm8, ymm4
  vmulps ymm4, ymm15, yword ptr [rsp + 512]
  vmulps ymm4, ymm11, ymm4
  vsubps ymm4, ymm15, ymm4
  vmaxps ymm4, ymm4, ymm1
  vminps ymm13, ymm10, ymm4
  vmovaps ymm14, ymm10
  vpor ymm4, ymm12, ymm5
  vandps ymm5, ymm13, ymm2
  vorps ymm5, ymm5, ymm3
  vaddps ymm12, ymm13, ymm5
  vpor ymm5, ymm8, ymm7
  vroundps ymm7, ymm12, 11
  vcvttps2dq ymm8, ymm7
  vsubps ymm7, ymm7, ymm9
  vpsrad ymm12, ymm8, 31
  vcvttps2dq ymm7, ymm7
  vpand ymm7, ymm12, ymm7
  vpslld ymm6, ymm6, 11
  vpslld ymm0, ymm0, 14
  vpor ymm7, ymm8, ymm7
  vmulps ymm8, ymm15, yword ptr [rsp + 544]
  vmulps ymm8, ymm8, ymm11
  vpand ymm6, ymm6, yword ptr [rsp + 288]
  vsubps ymm8, ymm15, ymm8
  vmaxps ymm8, ymm8, ymm1
  vminps ymm8, ymm8, ymm10
  vpand ymm0, ymm0, yword ptr [rsp + 256]
  vandps ymm10, ymm8, ymm2
  vorps ymm10, ymm10, ymm3
  vaddps ymm8, ymm8, ymm10
  vpor ymm0, ymm6, ymm0
  vroundps ymm6, ymm8, 11
  vcvttps2dq ymm8, ymm6
  vsubps ymm6, ymm6, ymm9
  vpsrad ymm10, ymm8, 31
  vcvttps2dq ymm6, ymm6
  vpand ymm6, ymm10, ymm6
  vpor ymm6, ymm8, ymm6
  vmulps ymm8, ymm15, yword ptr [rsp + 96]
  vmulps ymm8, ymm8, ymm11
  vpslld ymm4, ymm4, 17
  vpslld ymm5, ymm5, 20
  vpand ymm4, ymm4, yword ptr [rsp + 224]
  vpand ymm5, ymm5, yword ptr [rsp + 192]
  vpslld ymm7, ymm7, 23
  vsubps ymm8, ymm15, ymm8
  vpor ymm4, ymm4, ymm5
  vmaxps ymm5, ymm8, ymm1
  vminps ymm5, ymm14, ymm5
  vandps ymm8, ymm5, ymm2
  vpand ymm7, ymm7, yword ptr [rsp + 160]
  vorps ymm8, ymm8, ymm3
  vaddps ymm5, ymm8, ymm5
  vroundps ymm5, ymm5, 11
  vpor ymm4, ymm4, ymm7
  vcvttps2dq ymm7, ymm5
  vsubps ymm5, ymm5, ymm9
  vcvttps2dq ymm5, ymm5
  vpsrad ymm8, ymm7, 31
  vpand ymm5, ymm8, ymm5
  vpor ymm5, ymm7, ymm5
  vmovdqa xmm2, dqword ptr [rsp]
  vpsrlw xmm3, xmm2, 8
  vpmovzxwd ymm3, xmm3
  vpslld ymm5, ymm5, 29
  vpor ymm3, ymm5, ymm3
  vmovdqu ymm1, yword ptr [rsp + 64]
  vpslld ymm1, ymm1, 8
  vpand ymm1, ymm1, yword ptr [rsp + 320]
  vpor ymm1, ymm3, ymm1
  vpor ymm0, ymm1, ymm0
  vpor ymm0, ymm0, ymm4
  vpslld ymm1, ymm6, 26
  vpand ymm1, ymm1, yword ptr [rsp + 128]
  vpor ymm0, ymm0, ymm1
  vbroadcastss ymm1, dword ptr [rip + LCPI0_3]
  vcmpleps ymm1, ymm1, yword ptr [rsp + 32]
  vandps ymm0, ymm1, ymm0
  vmovups yword ptr [rdx + 4*r11], ymm0
  add r11, 8
  add rsi, 256
  cmp r10, r11
  jne @LBB0_4
  cmp r10d, eax
  jne @LBB0_6
@LBB0_10:
  cmp r9d, r8d
  jge @LBB0_26
  mov r10d, r9d
  or r10d, 1
  vpxor xmm3, xmm3, xmm3
  vpxor xmm4, xmm4, xmm4
  cmp r10d, r8d
  jge @LBB0_13
  mov r10d, r10d
  vmovd xmm4, dword ptr [rcx + 4*r10]
@LBB0_13:
  mov r10d, r9d
  or r10d, 2
  cmp r10d, r8d
  jge @LBB0_15
  mov r10d, r10d
  vmovd xmm3, dword ptr [rcx + 4*r10]
@LBB0_15:
  mov r10d, r9d
  or r10d, 3
  vxorps xmm0, xmm0, xmm0
  vxorps xmm5, xmm5, xmm5
  cmp r10d, r8d
  jge @LBB0_17
  mov r10d, r10d
  vmovss xmm5, dword ptr [rcx + 4*r10]
@LBB0_17:
  mov r10d, r9d
  mov r11d, r9d
  or r11d, 4
  cmp r11d, r8d
  jge @LBB0_19
  mov r11d, r11d
  vmovss xmm0, dword ptr [rcx + 4*r11]
@LBB0_19:
  mov r11d, r9d
  or r11d, 5
  vxorps xmm2, xmm2, xmm2
  vxorps xmm1, xmm1, xmm1
  cmp r11d, r8d
  jge @LBB0_21
  mov r11d, r11d
  vmovss xmm1, dword ptr [rcx + 4*r11]
@LBB0_21:
  vmovss xmm6, dword ptr [rcx + 4*r10]
  or r9d, 6
  cmp r9d, r8d
  jge @LBB0_23
  mov r9d, r9d
  vmovss xmm2, dword ptr [rcx + 4*r9]
@LBB0_23:
  vinsertps xmm4, xmm6, xmm4, 16
  vinsertps xmm3, xmm4, xmm3, 32
  vinsertps xmm6, xmm3, xmm5, 48
  vbroadcastss xmm3, dword ptr [rip + LCPI0_0]
  vandps xmm4, xmm6, xmm3
  vandps xmm5, xmm0, xmm3
  vandps xmm7, xmm1, xmm3
  vandps xmm8, xmm2, xmm3
  vshufps xmm9, xmm4, xmm4, 78
  vmaxps xmm4, xmm9, xmm4
  vmovshdup xmm9, xmm4
  vmaxss xmm5, xmm4, xmm5
  vmaxss xmm4, xmm8, xmm7
  vmaxss xmm7, xmm9, xmm4
  vxorps xmm4, xmm4, xmm4
  vmaxss xmm5, xmm5, xmm4
  vmaxss xmm5, xmm5, xmm7
{$ifdef fpc}
  vcvtps2ph xmm5, xmm5, 4
{$else}
  db $c4,$e3,$79,$1d,$ed,$04
{$endif}
  vpextrw ecx, xmm5, 0
  mov r9d, ecx
  and r9d, 65280
  vmovd xmm5, r9d
  vcvtph2ps xmm7, xmm5
  xor r9d, r9d
  vucomiss xmm7, dword ptr [rip + LCPI0_3]
  jb @LBB0_25
  movzx ecx, cx
  vbroadcastss xmm5, dword ptr [rip + LCPI0_4]
  vmulps xmm8, xmm6, xmm5
  vmovss xmm6, dword ptr [rip + LCPI0_2]
  vdivss xmm12, xmm6, xmm7
  vbroadcastss xmm6, xmm12
  vmulps xmm7, xmm8, xmm6
  vsubps xmm8, xmm5, xmm7
  vxorps xmm7, xmm7, xmm7
  vmaxps xmm10, xmm8, xmm7
  vbroadcastss xmm8, dword ptr [rip + LCPI0_5]
  vbroadcastss xmm9, dword ptr [rip + LCPI0_6]
  vminps xmm11, xmm10, xmm8
  vandps xmm13, xmm11, xmm9
  vbroadcastss xmm10, dword ptr [rip + LCPI0_7]
  vorps xmm13, xmm13, xmm10
  vaddps xmm11, xmm11, xmm13
  vroundps xmm13, xmm11, 11
  vcvttps2dq xmm14, xmm13
  vpsrad xmm15, xmm14, 31
  vbroadcastss xmm11, dword ptr [rip + LCPI0_8]
  vsubps xmm13, xmm13, xmm11
  vcvttps2dq xmm13, xmm13
  vpand xmm13, xmm13, xmm15
  vpor xmm13, xmm14, xmm13
  vpsllvd xmm13, xmm13, dqword ptr [rip + LCPI0_16]
  shr ecx, 8
  vpand xmm13, xmm13, dqword ptr [rip + LCPI0_17]
  vinsertps xmm0, xmm0, xmm2, 16
  vmulps xmm0, xmm0, xmm5
  vmovss xmm2, dword ptr [rip + LCPI0_4]
  vmulss xmm1, xmm1, xmm2
  vmulss xmm1, xmm12, xmm1
  vsubss xmm1, xmm2, xmm1
  vmaxss xmm1, xmm1, xmm4
  vminss xmm1, xmm1, dword ptr [rip + LCPI0_5]
  vandnps xmm2, xmm3, xmm1
  vmovss xmm4, dword ptr [rip + LCPI0_7]
  vandps xmm3, xmm4, xmm3
  vorps xmm2, xmm3, xmm2
  vaddss xmm1, xmm1, xmm2
  vroundss xmm1, xmm1, xmm1, 11
  vcvttss2si r9, xmm1
  and r9d, 7
  shl r9d, 23
  vpshufd xmm1, xmm13, 238
  vpor xmm1, xmm13, xmm1
  vpshufd xmm2, xmm1, 85
  vpor xmm1, xmm1, xmm2
  vmulps xmm0, xmm0, xmm6
  vsubps xmm0, xmm5, xmm0
  vmaxps xmm0, xmm0, xmm7
  vminps xmm0, xmm8, xmm0
  vandps xmm2, xmm9, xmm0
  vorps xmm2, xmm10, xmm2
  vaddps xmm0, xmm0, xmm2
  vroundps xmm0, xmm0, 11
  vcvttps2dq xmm2, xmm0
  vpsrad xmm3, xmm2, 31
  vsubps xmm0, xmm0, xmm11
  vcvttps2dq xmm0, xmm0
  vpand xmm0, xmm0, xmm3
  vpor xmm0, xmm2, xmm0
  vpsllvd xmm0, xmm0, dqword ptr [rip + LCPI0_18]
  vpand xmm0, xmm0, dqword ptr [rip + LCPI0_19]
  vpinsrd xmm1, xmm1, r9d, 1
  vpor xmm0, xmm1, xmm0
  vpshufd xmm1, xmm0, 85
  vpor xmm0, xmm0, xmm1
  vmovd r9d, xmm0
  or r9d, ecx
  or r9d, -2147483648
@LBB0_25:
  mov ecx, eax
  inc eax
  mov dword ptr [rdx + 4*rcx], r9d
@LBB0_26:
  lea ecx, [r8 + 7]
  add r8d, 14
  test ecx, ecx
  cmovns r8d, ecx
  sar r8d, 3
  cmp eax, r8d
  jge @LBB0_40
  mov r9d, eax
  mov eax, r8d
  mov rcx, rax
  sub rcx, r9
  cmp rcx, 8
  jae @LBB0_29
  mov r10, r9
  jmp @LBB0_39
@LBB0_6:
  vbroadcastss ymm12, dword ptr [rip + LCPI0_0]
  vmovss xmm1, dword ptr [rip + LCPI0_3]
  vbroadcastss xmm2, dword ptr [rip + LCPI0_6]
  vmovaps dqword ptr [rsp + 32], xmm2
  vbroadcastss xmm2, dword ptr [rip + LCPI0_7]
  vmovaps dqword ptr [rsp], xmm2
  vbroadcastss xmm8, dword ptr [rip + LCPI0_4]
  vmovaps xmm7, dqword ptr [rsp + 32]
  vmovaps xmm11, dqword ptr [rsp]
  vpxor xmm5, xmm5, xmm5
  jmp @LBB0_7
@LBB0_9:
  mov dword ptr [rdx + 4*r10], esi
  inc r10
  add r9, 8
  cmp rax, r10
  je @LBB0_10
@LBB0_7:
  vmovups ymm9, yword ptr [rcx + 4*r9]
  vandps ymm10, ymm9, ymm12
  vextractf128 xmm14, ymm10, 1
  vmaxps xmm10, xmm10, xmm14
  vshufpd xmm14, xmm10, xmm10, 1
  vmaxps xmm10, xmm10, xmm14
  vmovshdup xmm14, xmm10
  vmaxss xmm10, xmm10, xmm14
{$ifdef fpc}
  vcvtps2ph xmm10, xmm10, 4
{$else}
  db $c4,$43,$79,$1d,$d2,$04
{$endif}
  vpextrw r11d, xmm10, 0
  mov esi, r11d
  and esi, 32512
  vmovd xmm10, esi
  vcvtph2ps xmm14, xmm10
  xor esi, esi
  vucomiss xmm14, xmm1
  jb @LBB0_9
  vmovups xmm10, dqword ptr [rcx + 4*r9 + 16]
  vmulps xmm15, xmm9, xmm8
  vmovss xmm3, dword ptr [rip + LCPI0_2]
  vdivss xmm14, xmm3, xmm14
  vbroadcastss xmm9, xmm14
  vmulps xmm15, xmm15, xmm9
  vsubps xmm15, xmm8, xmm15
  vxorps xmm0, xmm0, xmm0
  vmaxps xmm15, xmm15, xmm0
  vbroadcastss xmm13, dword ptr [rip + LCPI0_5]
  vminps xmm15, xmm15, xmm13
  vandps xmm3, xmm15, xmm7
  vorps xmm3, xmm11, xmm3
  vaddps xmm3, xmm15, xmm3
  vroundps xmm3, xmm3, 11
  vcvttps2dq xmm15, xmm3
  vmovaps xmm13, xmm1
  vpsrad xmm1, xmm15, 31
  vbroadcastss xmm2, dword ptr [rip + LCPI0_8]
  vsubps xmm3, xmm3, xmm2
  vcvttps2dq xmm3, xmm3
  vpand xmm1, xmm3, xmm1
  vpor xmm1, xmm15, xmm1
  vmovshdup xmm3, xmm10
  vmovss xmm0, dword ptr [rip + LCPI0_4]
  vmulss xmm3, xmm3, xmm0
  vmulss xmm3, xmm14, xmm3
  vsubss xmm3, xmm0, xmm3
  vmaxss xmm3, xmm3, xmm5
  vmovss xmm2, dword ptr [rip + LCPI0_5]
  vminss xmm3, xmm3, xmm2
  vbroadcastss xmm15, dword ptr [rip + LCPI0_0]
  vandnps xmm4, xmm15, xmm3
  vmovss xmm6, dword ptr [rip + LCPI0_7]
  vandps xmm6, xmm15, xmm6
  vorps xmm4, xmm6, xmm4
  vaddss xmm3, xmm3, xmm4
  vroundss xmm3, xmm3, xmm3, 11
  vcvttss2si rsi, xmm3
  vshufps xmm3, xmm10, xmm10, 255
  vmulss xmm3, xmm3, xmm0
  vmulss xmm3, xmm14, xmm3
  vsubss xmm3, xmm0, xmm3
  vmaxss xmm3, xmm3, xmm5
  vminss xmm3, xmm3, xmm2
  vandnps xmm4, xmm15, xmm3
  vorps xmm4, xmm6, xmm4
  vaddss xmm3, xmm3, xmm4
  vpsllvd xmm1, xmm1, dqword ptr [rip + LCPI0_16]
  vpand xmm1, xmm1, dqword ptr [rip + LCPI0_17]
  vshufps xmm4, xmm10, xmm10, 232
  vmulps xmm4, xmm8, xmm4
  vroundss xmm3, xmm3, xmm3, 11
  vcvttss2si rdi, xmm3
  vpshufd xmm3, xmm1, 238
  vpor xmm1, xmm1, xmm3
  vpshufd xmm3, xmm1, 85
  vpor xmm1, xmm1, xmm3
  vmulps xmm3, xmm9, xmm4
  vsubps xmm3, xmm8, xmm3
  vxorps xmm2, xmm2, xmm2
  vmaxps xmm3, xmm3, xmm2
  vbroadcastss xmm2, dword ptr [rip + LCPI0_5]
  vminps xmm3, xmm3, xmm2
  vandps xmm4, xmm3, xmm7
  vorps xmm4, xmm11, xmm4
  vaddps xmm3, xmm3, xmm4
  vroundps xmm3, xmm3, 11
  vcvttps2dq xmm4, xmm3
  vpsrad xmm6, xmm4, 31
  vbroadcastss xmm2, dword ptr [rip + LCPI0_8]
  vsubps xmm3, xmm3, xmm2
  vcvttps2dq xmm3, xmm3
  vpand xmm3, xmm3, xmm6
  vpor xmm3, xmm4, xmm3
  and esi, 7
  shl esi, 23
  vpsllvd xmm3, xmm3, dqword ptr [rip + LCPI0_18]
  vpand xmm3, xmm3, dqword ptr [rip + LCPI0_19]
  vpinsrd xmm1, xmm1, esi, 1
  vpor xmm1, xmm1, xmm3
  vpshufd xmm3, xmm1, 85
  vpor xmm1, xmm1, xmm3
  vmovd esi, xmm1
  vmovaps xmm1, xmm13
  movzx r11d, r11w
  shr r11d, 8
  shl edi, 29
  or edi, r11d
  or esi, edi
  jmp @LBB0_9
@LBB0_29:
  cmp rcx, 32
  jae @LBB0_34
  xor r8d, r8d
  jmp @LBB0_31
@LBB0_34:
  mov r8, rcx
  and r8, -32
  lea r10, [rdx + 4*r9]
  add r10, 96
  xor r11d, r11d
  vxorps xmm0, xmm0, xmm0
@LBB0_35:
  vmovups yword ptr [r10 + 4*r11 - 96], ymm0
  vmovups yword ptr [r10 + 4*r11 - 64], ymm0
  vmovups yword ptr [r10 + 4*r11 - 32], ymm0
  vmovups yword ptr [r10 + 4*r11], ymm0
  add r11, 32
  cmp r8, r11
  jne @LBB0_35
  cmp rcx, r8
  je @LBB0_40
  test cl, 24
  je @LBB0_38
@LBB0_31:
  mov r11, rcx
  and r11, -8
  lea r10, [r11 + r9]
  lea r9, [rdx + 4*r9]
  vxorps xmm0, xmm0, xmm0
@LBB0_32:
  vmovups yword ptr [r9 + 4*r8], ymm0
  add r8, 8
  cmp r11, r8
  jne @LBB0_32
  cmp rcx, r11
  jne @LBB0_39
  jmp @LBB0_40
@LBB0_38:
  add r8, r9
  mov r10, r8
@LBB0_39:
  mov dword ptr [rdx + 4*r10], 0
  inc r10
  cmp rax, r10
  jne @LBB0_39
@LBB0_40:
  vmovaps xmm6, dqword ptr [rsp + 576]
  vmovaps xmm7, dqword ptr [rsp + 592]
  vmovaps xmm8, dqword ptr [rsp + 608]
  vmovaps xmm9, dqword ptr [rsp + 624]
  vmovaps xmm10, dqword ptr [rsp + 640]
  vmovaps xmm11, dqword ptr [rsp + 656]
  vmovaps xmm12, dqword ptr [rsp + 672]
  vmovaps xmm13, dqword ptr [rsp + 688]
  vmovaps xmm14, dqword ptr [rsp + 704]
  vmovaps xmm15, dqword ptr [rsp + 720]
  add rsp, 744
  pop rdi
  pop rsi
  vzeroupper
end;
{$endif}

procedure PascalQuantizeQ3F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 Index:=0;
 while (Index+7)<aCount do begin
  PPasLLMUInt32Array(aQ)^[Index shr 3]:=ConvertFloat32ToQ3F8(PPasLLMFloatArray(aX)^[Index+0],
                                                           PPasLLMFloatArray(aX)^[Index+1],
                                                           PPasLLMFloatArray(aX)^[Index+2],
                                                           PPasLLMFloatArray(aX)^[Index+3],
                                                           PPasLLMFloatArray(aX)^[Index+4],
                                                           PPasLLMFloatArray(aX)^[Index+5],
                                                           PPasLLMFloatArray(aX)^[Index+6],
                                                           PPasLLMFloatArray(aX)^[Index+7]);
  inc(Index,8);
 end;
end;

procedure PascalQuantizeQ6F16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 Index:=0;
 while (Index+7)<aCount do begin
  PPasLLMUInt64Array(aQ)^[Index shr 3]:=ConvertFloat32ToQ6F16(PPasLLMFloatArray(aX)^[Index+0],
                                                            PPasLLMFloatArray(aX)^[Index+1],
                                                            PPasLLMFloatArray(aX)^[Index+2],
                                                            PPasLLMFloatArray(aX)^[Index+3],
                                                            PPasLLMFloatArray(aX)^[Index+4],
                                                            PPasLLMFloatArray(aX)^[Index+5],
                                                            PPasLLMFloatArray(aX)^[Index+6],
                                                            PPasLLMFloatArray(aX)^[Index+7]);
  inc(Index,8);
 end;
end;

procedure PascalQuantizeQ7F8(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 Index:=0;
 while (Index+7)<aCount do begin
  PPasLLMUInt64Array(aQ)^[Index shr 3]:=ConvertFloat32ToQ7F8(PPasLLMFloatArray(aX)^[Index+0],
                                                           PPasLLMFloatArray(aX)^[Index+1],
                                                           PPasLLMFloatArray(aX)^[Index+2],
                                                           PPasLLMFloatArray(aX)^[Index+3],
                                                           PPasLLMFloatArray(aX)^[Index+4],
                                                           PPasLLMFloatArray(aX)^[Index+5],
                                                           PPasLLMFloatArray(aX)^[Index+6],
                                                           PPasLLMFloatArray(aX)^[Index+7]);
  inc(Index,8);
 end;
end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ40(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LC2:TPasLLMUInt32=TPasLLMUInt32(2147483647);
      LC3:TPasLLMUInt32=TPasLLMUInt32(956640078);
      LC4:TPasLLMUInt32=TPasLLMUInt32(1006699012);
      LC5:TPasLLMUInt32=TPasLLMUInt32(1123942400);
      LC7:TPasLLMUInt32=TPasLLMUInt32(1056964607);
      LC9:TPasLLMUInt32=TPasLLMUInt32(-2147483648);
asm
{$ifndef fpc}
 .noframe
{$endif}
 cmp r8d,31
 jle @L21
 push rbp
 mov r10,rdx
 mov edx,134744072
 vpcmpeqd xmm0,xmm0,xmm0
 mov rax,rcx
 mov rbp,rsp
 push rsi
 mov esi,r8d
 xor r8d,r8d
 push rbx
 sar esi,5
 sub rsp,160
 and rsp,-32
 sub rsp,64
 vmovaps dqword ptr [rsp+64],xmm6
 vmovd xmm6,edx
 mov edx,-252645136
 vmovaps dqword ptr [rsp+80],xmm7
 vpbroadcastd xmm7,xmm6
 vmovd xmm6,edx
 mov edx,252645135
 vmovdqa dqword ptr [rsp+32],xmm7
 vpbroadcastd xmm7,xmm6
 vmovd xmm6,edx
 vmovdqa dqword ptr [rsp+16],xmm7
 vpbroadcastd xmm7,xmm6
 vmovaps dqword ptr [rsp+96],xmm8
 vbroadcastss ymm8,dword ptr [rip+LC2]
 vmovaps dqword ptr [rsp+112],xmm9
 vbroadcastss xmm9,dword ptr [rip+LC9]
 vmovaps dqword ptr [rsp+128],xmm10
 vbroadcastss xmm10,dword ptr [rip+LC7]
 vmovaps dqword ptr [rsp+208],xmm15
 vpsrlw xmm15,xmm0,8
 vmovaps dqword ptr [rsp+144],xmm11
 vmovaps dqword ptr [rsp+160],xmm12
 vmovaps dqword ptr [rsp+176],xmm13
 vmovaps dqword ptr [rsp+192],xmm14
 vmovdqa dqword ptr [rsp],xmm7
 jmp @L9
@L26:
 vpxor xmm0,xmm0,xmm0
 lea rbx,[rax+128]
 vmovdqu dqword ptr [r10],xmm0
 vxorps xmm0,xmm0,xmm0
@L5:
 add r8d,1
 vpextrw word ptr [r10+16],xmm0,0
 mov rax,rbx
 add r10,18
 cmp esi,r8d
 jle @L25
@L9:
 vandps ymm1,ymm8,yword ptr [rax+32]
 vandps ymm0,ymm8,yword ptr [rax]
 vandps ymm2,ymm8,yword ptr [rax+96]
 vmovss xmm6,dword ptr [rip+LC3]
 vmaxps ymm0,ymm0,ymm1
 vxorps xmm1,xmm1,xmm1
 vmaxps ymm0,ymm0,ymm1
 vandps ymm1,ymm8,yword ptr [rax+64]
 vmaxps ymm1,ymm1,ymm2
 vmaxps ymm0,ymm0,ymm1
 vextractf128 xmm1,ymm0,1
 vmaxps xmm0,xmm1,xmm0
 vmovhlps xmm1,xmm0,xmm0
 vmaxps xmm1,xmm1,xmm0
 vshufps xmm0,xmm1,xmm1,85
 vmaxps xmm0,xmm0,xmm1
 vcomiss xmm6,xmm0
 ja @L26
 vmulss xmm7,xmm0,dword ptr [rip+LC4]
 vmovss xmm1,dword ptr [rip+LC5]
 lea rdx,[r10+16]
 lea rbx,[rax+128]
 vdivss xmm1,xmm1,xmm0
 vmovd r11d,xmm7
 cmp rax,rdx
 jnb @L13
 cmp r10,rbx
 jb @L11
@L13:
 vmovups xmm12,dqword ptr [rax+112]
 vmovups xmm7,dqword ptr [rax+16]
 vbroadcastss xmm1,xmm1
 vmovups xmm4,dqword ptr [rax+96]
 vmovups xmm14,dqword ptr [rax+48]
 vmovups xmm0,dqword ptr [rax]
 vmovups xmm5,dqword ptr [rax+32]
 vmovaps dqword ptr [rsp+48],xmm7
 vshufps xmm7,xmm4,xmm12,136
 vshufps xmm4,xmm4,xmm12,221
 vmulps xmm12,xmm4,xmm1
 vshufps xmm4,xmm0,dqword ptr [rsp+48],221
 vshufps xmm0,xmm0,dqword ptr [rsp+48],136
 vmulps xmm0,xmm0,xmm1
 vshufps xmm6,xmm5,xmm14,136
 vmovups xmm13,dqword ptr [rax+80]
 vmulps xmm4,xmm4,xmm1
 vmovups xmm2,dqword ptr [rax+64]
 vshufps xmm5,xmm5,xmm14,221
 vmulps xmm6,xmm6,xmm1
 vmulps xmm5,xmm5,xmm1
 vshufps xmm3,xmm2,xmm13,136
 vshufps xmm2,xmm2,xmm13,221
 vmulps xmm3,xmm3,xmm1
 vmulps xmm7,xmm7,xmm1
 vmulps xmm2,xmm2,xmm1
 vandps xmm1,xmm9,xmm0
 vandps xmm13,xmm9,xmm4
 vorps xmm1,xmm10,xmm1
 vorps xmm13,xmm10,xmm13
 vaddps xmm0,xmm0,xmm1
 vandps xmm1,xmm9,xmm6
 vaddps xmm13,xmm4,xmm13
 vorps xmm1,xmm10,xmm1
 vandps xmm4,xmm9,xmm5
 vaddps xmm1,xmm6,xmm1
 vorps xmm4,xmm10,xmm4
 vaddps xmm14,xmm5,xmm4
 vpxor xmm4,xmm4,xmm4
 vroundps xmm13,xmm13,3
 vroundps xmm0,xmm0,3
 vcvttps2dq xmm13,xmm13
 vcvttps2dq xmm0,xmm0
 vpblendw xmm5,xmm4,xmm13,85
 vpblendw xmm0,xmm4,xmm0,85
 vandps xmm13,xmm9,xmm2
 vroundps xmm1,xmm1,3
 vcvttps2dq xmm1,xmm1
 vpblendw xmm1,xmm4,xmm1,85
 vorps xmm13,xmm10,xmm13
 vpackusdw xmm1,xmm0,xmm1
 vandps xmm0,xmm9,xmm3
 vroundps xmm14,xmm14,3
 vaddps xmm2,xmm2,xmm13
 vorps xmm0,xmm10,xmm0
 vandps xmm13,xmm9,xmm12
 vcvttps2dq xmm14,xmm14
 vaddps xmm0,xmm3,xmm0
 vorps xmm13,xmm10,xmm13
 vandps xmm3,xmm9,xmm7
 vaddps xmm12,xmm12,xmm13
 vorps xmm3,xmm10,xmm3
 vpblendw xmm14,xmm4,xmm14,85
 vaddps xmm3,xmm7,xmm3
 vroundps xmm2,xmm2,3
 vcvttps2dq xmm2,xmm2
 vpand xmm1,xmm15,xmm1
 vpblendw xmm2,xmm4,xmm2,85
 vpackusdw xmm5,xmm5,xmm14
 vroundps xmm0,xmm0,3
 vcvttps2dq xmm0,xmm0
 vroundps xmm12,xmm12,3
 vcvttps2dq xmm12,xmm12
 vpblendw xmm12,xmm4,xmm12,85
 vpblendw xmm0,xmm4,xmm0,85
 vpackusdw xmm12,xmm2,xmm12
 vroundps xmm3,xmm3,3
 vcvttps2dq xmm3,xmm3
 vpblendw xmm4,xmm4,xmm3,85
 vmovdqa xmm14,dqword ptr [rsp+32]
 vpand xmm2,xmm15,xmm5
 vpackusdw xmm0,xmm0,xmm4
 vpand xmm5,xmm15,xmm12
 vpackuswb xmm2,xmm2,xmm5
 vpand xmm0,xmm15,xmm0
 vpaddb xmm2,xmm2,xmm14
 vpackuswb xmm0,xmm1,xmm0
 vpsllw xmm2,xmm2,4
 vpaddb xmm0,xmm0,xmm14
 vpand xmm2,xmm2,dqword ptr [rsp+16]
 vpand xmm0,xmm0,dqword ptr [rsp]
 vpor xmm2,xmm2,xmm0
 vmovdqu dqword ptr [r10],xmm2
@L8:
 vmovd xmm0,r11d
{$ifdef fpc}
 vcvtps2ph xmm0,xmm0,4
{$else}
 db $c4,$e3,$79,$1d,$c0,$04
{$endif}
 jmp @L5
@L25:
 vzeroupper
 vmovaps xmm6,dqword ptr [rsp+64]
 vmovaps xmm7,dqword ptr [rsp+80]
 vmovaps xmm8,dqword ptr [rsp+96]
 vmovaps xmm9,dqword ptr [rsp+112]
 vmovaps xmm10,dqword ptr [rsp+128]
 vmovaps xmm11,dqword ptr [rsp+144]
 vmovaps xmm12,dqword ptr [rsp+160]
 vmovaps xmm13,dqword ptr [rsp+176]
 vmovaps xmm14,dqword ptr [rsp+192]
 vmovaps xmm15,dqword ptr [rsp+208]
 lea rsp,[rbp-16]
 pop rbx
 pop rsi
 pop rbp
 jmp @L21
@L11:
 vmovss xmm0,dword ptr [rip+LC7]
 vmovss xmm4,dword ptr [rip+LC9]
 xor ecx,ecx
 vmovaps xmm5,xmm0
@L6:
 vmulss xmm2,xmm1,dword ptr [rax+rcx*8]
 vandps xmm3,xmm4,xmm2
 vorps xmm0,xmm0,xmm3
 vmulss xmm3,xmm1,dword ptr [rax+4+rcx*8]
 vaddss xmm0,xmm0,xmm2
 vcvttss2si r9d,xmm0
 vmovaps xmm0,xmm5
 vandps xmm2,xmm4,xmm3
 vorps xmm2,xmm5,xmm2
 vaddss xmm2,xmm2,xmm3
 add r9d,8
 and r9d,15
 vcvttss2si edx,xmm2
 add edx,8
 sal edx,4
 or edx,r9d
 mov byte ptr [r10+rcx],dl
 add rcx,1
 cmp rcx,16
 jne @L6
 jmp @L8
@L21:
end;
{$endif}

procedure PascalQuantizeQ40(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      QMax=127.0; // Max value for int8_t
var CountGroups,GroupIndex,BaseIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale:TPasLLMFloat;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group

  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x

  MaxValue:=0.0; // Initialize the max value for this group
  for Index:=0 to GroupSize-1 do begin
   // Find the max absolute value in the current group
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue/QMax;

  // Calculate and write the quantized values and the scaling factor
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*((GroupSize shr 1)+2)]); // Pointer to the current group in q
  if Scale<1e-6 then begin
   // If the scale is too small, set all values to zero
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=0; // Set the scale factor to zero
  end else begin
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=((TPasLLMUInt8(round(XGroup^[(Index*2)+0]/Scale)+8) and $f) shl 0) or
                    ((TPasLLMUInt8(round(XGroup^[(Index*2)+1]/Scale)+8) and $f) shl 4); // Quantize the values
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=ConvertFloat32ToFloat16(Scale); // Store the scale factor in the last two bytes
  end;
 end;

end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ40NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LC2:TAlign4xUInt32=(Values:(TPasLLMUInt32(2147483647),0,0,0));
      LC3:TPasLLMUInt32=TPasLLMUInt32(897988541);
      LC4:TPasLLMUInt32=TPasLLMUInt32(1065353216);
      LC5:TAlign4xUInt32=(Values:(TPasLLMUInt32(2147483647),0,0,0));
      LC6:TPasLLMUInt32=TPasLLMUInt32(1090519040);
      LC7:TAlign4xUInt32=(Values:(TPasLLMUInt32(-2147483648),0,0,0));
      LC8:TPasLLMUInt32=TPasLLMUInt32(1080033280);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 31
  jle @L22
  push rbp
  sar r8d, 5
  mov r9, rdx
  xor r11d, r11d
  mov r10d, 1
  mov rbp, rsp
  push rsi
  push rbx
  sub rsp, 96
  vmovss xmm1, dword ptr [rip+LC4]
  vmovss xmm2, dword ptr [rip+LC6]
  vmovss xmm4, dword ptr [rip+LC7]
  and rsp, -32
  vmovss xmm3, dword ptr [rip+LC8]
  vmovaps dqword ptr [rsp+48], xmm9
  vpxor xmm9, xmm9, xmm9
  vmovaps dqword ptr [rsp], xmm6
  vbroadcastss ymm6, dword ptr [rip+LC2]
  vmovaps dqword ptr [rsp+16], xmm7
  vmovaps ymm7, ymm9
  vmovaps dqword ptr [rsp+32], xmm8
  vmovss xmm8, dword ptr [rip+LC3]
  vmovaps dqword ptr [rsp+64], xmm10
  vmovaps dqword ptr [rsp+80], xmm11
  jmp @L11
@L27:
  vmovdqu dqword ptr [r9], xmm9
  vxorps xmm0, xmm0, xmm0
@L5:
  add r11d, 1
  vpextrw word ptr [r9+16], xmm0, 0
  sub rcx, -128
  add r9, 18
  cmp r8d, r11d
  jle @L26
@L11:
  vandps ymm5, ymm6, yword ptr [rcx+32]
  vandps ymm0, ymm6, yword ptr [rcx]
  vandps ymm10, ymm6, yword ptr [rcx+96]
  vmaxps ymm0, ymm0, ymm5
  vandps ymm5, ymm6, yword ptr [rcx+64]
  vmaxps ymm5, ymm5, ymm10
  vmaxps ymm0, ymm0, ymm7
  vmaxps ymm0, ymm0, ymm5
  vextractf128 xmm5, ymm0, $1
  vmaxps xmm5, xmm5, xmm0
  vmovhlps xmm0, xmm5, xmm5
  vmaxps xmm0, xmm0, xmm5
  vshufps xmm5, xmm0, xmm0, 85
  vmaxps xmm5, xmm5, xmm0
  vcomiss xmm8, xmm5
  ja @L27
  vdivss xmm11, xmm1, xmm5
  xor edx, edx
@L10:
  vmulss xmm0, xmm11, dword ptr [rcx+rdx*8]
  mov eax, 7
  vandps xmm10, xmm0, dqword ptr [rip+LC5]
  vfmadd132ss xmm10, xmm1, xmm2
  vandps xmm0, xmm4, xmm0
  vorps xmm0, xmm3, xmm0
  vsqrtss xmm10, xmm10, xmm10
  vsubss xmm10, xmm10, xmm1
  vfmadd132ss xmm0, xmm2, xmm10
  vcvtss2si rbx, xmm0
  vmulss xmm0, xmm11, dword ptr [rcx+4+rdx*8]
  vandps xmm10, xmm0, dqword ptr [rip+LC5]
  vfmadd132ss xmm10, xmm1, xmm2
  cmp bl, al
  vandps xmm0, xmm4, xmm0
  cmovle eax, ebx
  vorps xmm0, xmm3, xmm0
  add eax, 8
  cmp bl, -8
  vsqrtss xmm10, xmm10, xmm10
  cmovle eax, r10d
  vsubss xmm10, xmm10, xmm1
  vfmadd132ss xmm0, xmm2, xmm10
  vcvtss2si rbx, xmm0
  cmp bl, -7
  jl @L7
  mov esi, 7
  cmp bl, sil
  cmovg ebx, esi
  add ebx, 8
  sal ebx, 4
  or ebx, eax
  mov byte ptr [r9+rdx], bl
  add rdx, 1
  cmp rdx, 16
  jne @L10
  vinsertps xmm0, xmm5, xmm5, $e
{$ifdef fpc}
  vcvtps2ph xmm0,xmm0,4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  jmp @L5
@L7:
  or eax, 16
  mov byte ptr [r9+rdx], al
  add rdx, 1
  cmp rdx, 16
  jne @L10
  vinsertps xmm0, xmm5, xmm5, $e
{$ifdef fpc}
  vcvtps2ph xmm0,xmm0,4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  jmp @L5
@L26:
  vzeroupper
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp+16]
  vmovaps xmm8, dqword ptr [rsp+32]
  vmovaps xmm9, dqword ptr [rsp+48]
  vmovaps xmm10, dqword ptr [rsp+64]
  vmovaps xmm11, dqword ptr [rsp+80]
  lea rsp, [rbp-16]
  pop rbx
  pop rsi
  pop rbp
@L22:
end;
{$endif}

procedure PascalQuantizeQ40NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
var CountGroups,GroupIndex,BaseIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale:TPasLLMFloat;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group

  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x

  MaxValue:=0.0; // Initialize the max value for this group
  for Index:=0 to GroupSize-1 do begin
   // Find the max absolute value in the current group
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue;

  // Calculate and write the quantized values and the scaling factor
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*((GroupSize shr 1)+2)]); // Pointer to the current group in q
  if Scale<1e-6 then begin
   // If the scale is too small, set all values to zero
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=0; // Set the scale factor to zero
  end else begin
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=(EncodeQ40NLValueNibble(XGroup^[(Index*2)+0]/Scale) shl 0) or
                    (EncodeQ40NLValueNibble(XGroup^[(Index*2)+1]/Scale) shl 4); // Quantize the values
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=ConvertFloat32ToFloat16(Scale); // Store the scale factor in the last two bytes
  end;
 end;

end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ41NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign4xUInt32=record
      Values:array[0..3] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};
const LC2:TAlign4xUInt32=(Values:(TPasLLMUInt32(2147483647),0,0,0));
      LC3:TPasLLMUInt32=TPasLLMUInt32(897988541);
      LC4:TPasLLMUInt32=TPasLLMUInt32(1065353216);
      LC5:TAlign4xUInt32=(Values:(TPasLLMUInt32(2147483647),0,0,0));
      LC6:TAlign4xUInt32=(Values:(TPasLLMUInt32(-2147483648),0,0,0));
      LC7:TPasLLMUInt32=TPasLLMUInt32(1088421888);
      LC8:TPasLLMUInt32=TPasLLMUInt32(1090519040);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 31
  jle @L22
  push rbp
  sar r8d, 5
  mov r9, rdx
  xor r11d, r11d
  mov r10d, 1
  mov rbp, rsp
  push rsi
  push rbx
  sub rsp, 96
  vmovss xmm3, dword ptr [rip+LC7]
  vbroadcastss ymm5, dword ptr [rip+LC2]
  vmovss xmm1, dword ptr [rip+LC6]
  and rsp, -32
  vmovss xmm2, dword ptr [rip+LC8]
  vmovaps dqword ptr [rsp+32], xmm8
  vpxor xmm8, xmm8, xmm8
  vmovaps dqword ptr [rsp], xmm6
  vmovaps ymm6, ymm8
  vmovaps dqword ptr [rsp+16], xmm7
  vmovss xmm7, dword ptr [rip+LC3]
  vmovaps dqword ptr [rsp+48], xmm9
  vmovss xmm9, dword ptr [rip+LC4]
  vmovaps dqword ptr [rsp+64], xmm10
  vmovaps dqword ptr [rsp+80], xmm11
  jmp @L11
@L27:
  vmovdqu dqword ptr [r9], xmm8
  vxorps xmm0, xmm0, xmm0
@L5:
  add r11d, 1
  vpextrw word ptr [r9+16], xmm0, 0
  sub rcx, -128
  add r9, 18
  cmp r8d, r11d
  jle @L26
@L11:
  vandps ymm4, ymm5, yword ptr [rcx+32]
  vandps ymm0, ymm5, yword ptr [rcx]
  vandps ymm10, ymm5, yword ptr [rcx+96]
  vmaxps ymm0, ymm0, ymm4
  vandps ymm4, ymm5, yword ptr [rcx+64]
  vmaxps ymm4, ymm4, ymm10
  vmaxps ymm0, ymm0, ymm6
  vmaxps ymm0, ymm0, ymm4
  vextractf128 xmm4, ymm0, $1
  vmaxps xmm4, xmm4, xmm0
  vmovhlps xmm0, xmm4, xmm4
  vmaxps xmm0, xmm0, xmm4
  vshufps xmm4, xmm0, xmm0, 85
  vmaxps xmm4, xmm4, xmm0
  vcomiss xmm7, xmm4
  ja @L27
  vdivss xmm10, xmm9, xmm4
  xor edx, edx
@L10:
  vmulss xmm11, xmm10, dword ptr [rcx+rdx*8]
  mov eax, 7
  vandps xmm0, xmm11, dqword ptr [rip+LC5]
  vsqrtss xmm0, xmm0, xmm0
  vandps xmm11, xmm1, xmm11
  vandnps xmm0, xmm1, xmm0
  vorps xmm0, xmm0, xmm11
  vmulss xmm11, xmm10, dword ptr [rcx+4+rdx*8]
  vfmadd132ss xmm0, xmm2, xmm3
  vcvtss2si rsi, xmm0
  vandps xmm0, xmm11, dqword ptr [rip+LC5]
  vandps xmm11, xmm1, xmm11
  vsqrtss xmm0, xmm0, xmm0
  cmp sil, al
  vandnps xmm0, xmm1, xmm0
  cmovle eax, esi
  cmp sil, -8
  vorps xmm0, xmm0, xmm11
  vfmadd132ss xmm0, xmm2, xmm3
  lea ebx, [rax+8]
  cmovle ebx, r10d
  vcvtss2si rax, xmm0
  cmp al, -7
  jl @L7
  mov esi, 7
  cmp al, sil
  cmovg eax, esi
  add eax, 8
  sal eax, 4
  or eax, ebx
  mov byte ptr [r9+rdx], al
  add rdx, 1
  cmp rdx, 16
  jne @L10
  vinsertps xmm0, xmm4, xmm4, $e
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  jmp @L5
@L7:
  or ebx, 16
  mov byte ptr [r9+rdx], bl
  add rdx, 1
  cmp rdx, 16
  jne @L10
  vinsertps xmm0, xmm4, xmm4, $e
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  jmp @L5
@L26:
  vzeroupper
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp+16]
  vmovaps xmm8, dqword ptr [rsp+32]
  vmovaps xmm9, dqword ptr [rsp+48]
  vmovaps xmm10, dqword ptr [rsp+64]
  vmovaps xmm11, dqword ptr [rsp+80]
  lea rsp, [rbp-16]
  pop rbx
  pop rsi
  pop rbp
@L22:
end;
{$endif}

procedure PascalQuantizeQ41NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
var CountGroups,GroupIndex,BaseIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale:TPasLLMFloat;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group

  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x

  MaxValue:=0.0; // Initialize the max value for this group
  for Index:=0 to GroupSize-1 do begin
   // Find the max absolute value in the current group
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue;

  // Calculate and write the quantized values and the scaling factor
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*((GroupSize shr 1)+2)]); // Pointer to the current group in q
  if Scale<1e-6 then begin
   // If the scale is too small, set all values to zero
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=0; // Set the scale factor to zero
  end else begin
   for Index:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[Index]:=(EncodeQ41NLValueNibble(XGroup^[(Index*2)+0]/Scale) shl 0) or
                    (EncodeQ41NLValueNibble(XGroup^[(Index*2)+1]/Scale) shl 4); // Quantize the values
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=ConvertFloat32ToFloat16(Scale); // Store the scale factor in the last two bytes
  end;
 end;

end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ42NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($358637bd);
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($bf800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7f800000);
      LCPI0_6:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_7:TPasLLMUInt32=TPasLLMUInt32($40800000);
      LCPI0_8:TPasLLMUInt32=TPasLLMUInt32($40000000);
      LCPI0_9:TPasLLMUInt32=TPasLLMUInt32($c0400000);
      LCPI0_10:TPasLLMUInt32=TPasLLMUInt32($bf000000);
      LCPI0_11:TPasLLMUInt32=TPasLLMUInt32($00800000);
      LCPI0_12:TPasLLMUInt32=TPasLLMUInt32($3f000000);
      LCPI0_13:TPasLLMUInt32=TPasLLMUInt32($80000000);
      LCPI0_14:TPasLLMUInt32=TPasLLMUInt32($40e00000);
      LCPI0_15:TPasLLMUInt32=TPasLLMUInt32($3effffff);
      LCPI0_16:TAlign16xUInt8=(Values:(249,249,249,249,249,249,249,249,0,0,0,0,0,0,0,0));
      LCPI0_17:TAlign16xUInt8=(Values:(7,7,7,7,7,7,7,7,0,0,0,0,0,0,0,0));
      LCPI0_18:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_19:TAlign16xUInt8=(Values:(8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8));
      LCPI0_22:TAlign16xUInt8=(Values:(0,2,4,6,8,10,12,14,0,0,0,0,0,0,0,0));
      LCPI0_23:TAlign16xUInt8=(Values:(1,3,5,7,9,11,13,15,0,0,0,0,0,0,0,0));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_15
  push r14
  push rsi
  push rdi
  push rbp
  push rbx
  sub rsp, 672
  vmovdqa dqword ptr [rsp + 656], xmm15
  vmovaps dqword ptr [rsp + 640], xmm14
  vmovaps dqword ptr [rsp + 624], xmm13
  vmovdqa dqword ptr [rsp + 608], xmm12
  vmovaps dqword ptr [rsp + 592], xmm11
  vmovaps dqword ptr [rsp + 576], xmm10
  vmovaps dqword ptr [rsp + 560], xmm9
  vmovaps dqword ptr [rsp + 544], xmm8
  vmovdqa dqword ptr [rsp + 528], xmm7
  vmovaps dqword ptr [rsp + 512], xmm6
  shr r8d, 5
  xor eax, eax
  vbroadcastss xmm5, dword ptr [rip + LCPI0_0]
  vxorps xmm6, xmm6, xmm6
  vbroadcastss ymm11, dword ptr [rip + LCPI0_2]
  mov r9, rcx
  vxorps xmm9, xmm9, xmm9
  vpxor xmm4, xmm4, xmm4
  vbroadcastss ymm13, dword ptr [rip + LCPI0_0]
  jmp @LBB0_2
@LBB0_12:
  vmovdqu xmm2, dqword ptr [rip + LCPI0_18]
  vpand xmm0, xmm2, dqword ptr [rsp + 16]
  vmovdqu xmm3, dqword ptr [rip + LCPI0_19]
  vpxor xmm0, xmm0, xmm3
  vmovq xmm4, qword ptr [rip + LCPI0_22]
  vpshufb xmm1, xmm0, xmm4
  vmovq xmm5, qword ptr [rip + LCPI0_23]
  vpshufb xmm0, xmm0, xmm5
  vpsllw xmm0, xmm0, 4
  vpand xmm2, xmm2, dqword ptr [rsp + 32]
  vpxor xmm2, xmm2, xmm3
  vpshufb xmm3, xmm2, xmm4
  vpunpcklqdq xmm1, xmm1, xmm3
  vpshufb xmm2, xmm2, xmm5
  vpsllw xmm2, xmm2, 4
  vpunpcklqdq xmm0, xmm0, xmm2
  vpor xmm0, xmm0, xmm1
  vmovdqu dqword ptr [r10], xmm0
  mov byte ptr [r10 + 16], r11b
  add sil, -127
  mov byte ptr [r10 + 17], sil
  vbroadcastss xmm5, dword ptr [rip + LCPI0_0]
  vxorps xmm6, xmm6, xmm6
  vpxor xmm4, xmm4, xmm4
  inc rax
  sub r9, -128
  cmp rax, r8
  je @LBB0_14
@LBB0_2:
  mov r10, rax
  shl r10, 7
  vmovss xmm0, dword ptr [rcx + r10]
  vmovss xmm1, dword ptr [rcx + r10 + 4]
  vmovss xmm2, dword ptr [rcx + r10 + 8]
  vmovss xmm3, dword ptr [rcx + r10 + 12]
  vandps xmm0, xmm0, xmm5
  vmaxss xmm0, xmm0, xmm6
  vandps xmm1, xmm1, xmm5
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vandps xmm1, xmm3, xmm5
  vmovss xmm2, dword ptr [rcx + r10 + 16]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 20]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vmovss xmm1, dword ptr [rcx + r10 + 24]
  vandps xmm1, xmm1, xmm5
  vmovss xmm2, dword ptr [rcx + r10 + 28]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 32]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 36]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vmovss xmm1, dword ptr [rcx + r10 + 40]
  vandps xmm1, xmm1, xmm5
  vmovss xmm2, dword ptr [rcx + r10 + 44]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 48]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 52]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 56]
  vandps xmm2, xmm2, xmm5
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm1, xmm1, xmm0
  vmovss xmm0, dword ptr [rcx + r10 + 60]
  vandps xmm2, xmm0, xmm5
  vmovss xmm0, dword ptr [rcx + r10 + 64]
  vandps xmm3, xmm0, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 68]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 72]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 76]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 80]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 84]
  vandps xmm2, xmm2, xmm5
  vmovss xmm3, dword ptr [rcx + r10 + 88]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 92]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 96]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 100]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 104]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 108]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 112]
  vandps xmm2, xmm2, xmm5
  vmovss xmm3, dword ptr [rcx + r10 + 116]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 120]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 124]
  vandps xmm3, xmm3, xmm5
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vucomiss xmm1, xmm6
  jbe @LBB0_3
{$ifdef fpc}
  vcvtps2ph xmm2, xmm1, 4
{$else}
  db $c4,$e3,$79,$1d,$ca,$04
{$endif}
  vcvtph2ps xmm3, xmm2
  vucomiss xmm1, xmm3
  seta r10b
  vpextrw esi, xmm2, 0
  movzx r11d, si
  cmp r11d, 31743
  setb r11b
  and r11b, r10b
  movzx r11d, r11b
  add r11d, esi
  mov r10d, r11d
  and r10d, 32512
  vmovd xmm1, r10d
  vcvtph2ps xmm1, xmm1
  lea r10, [rax + 8*rax]
  lea r10, [rdx + 2*r10]
  vucomiss xmm1, dword ptr [rip + LCPI0_1]
  jbe @LBB0_5
  mov rsi, rax
  shl rsi, 5
  vmovss xmm2, dword ptr [rip + LCPI0_2]
  vdivss xmm2, xmm2, xmm1
  vbroadcastss ymm2, xmm2
  vmulps ymm3, ymm2, yword ptr [rcx + 4*rsi]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_3]
  vmaxps ymm3, ymm3, ymm5
  vminps ymm3, ymm11, ymm3
  vmovups yword ptr [rsp + 384], ymm3
  vmulps ymm3, ymm2, yword ptr [rcx + 4*rsi + 32]
  shr r11d, 8
  vmaxps ymm3, ymm3, ymm5
  vminps ymm3, ymm11, ymm3
  vmovups yword ptr [rsp + 416], ymm3
  vinsertps xmm0, xmm0, dword ptr [rcx + 4*rsi + 68], 16
  vinsertf128 ymm0, ymm0, dqword ptr [rcx + 4*rsi + 80], 1
  vmovddup xmm3, qword ptr [rcx + 4*rsi + 72]
  vblendps ymm0, ymm0, ymm3, 12
  vmulps ymm0, ymm0, ymm2
  vmaxps ymm0, ymm0, ymm5
  vminps ymm0, ymm11, ymm0
  vmovups yword ptr [rsp + 448], ymm0
  vmulps ymm0, ymm2, yword ptr [rcx + 4*rsi + 96]
  vmaxps ymm0, ymm0, ymm5
  vminps ymm0, ymm11, ymm0
  vmovups yword ptr [rsp + 480], ymm0
  vmulss xmm0, xmm1, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm10, xmm0
  xor edi, edi
  xor esi, esi
  vmovss xmm0, dword ptr [rip + LCPI0_5]
  vmovss dword ptr [rsp + 12], xmm0
  vmovups yword ptr [rsp + 192], ymm10
  jmp @LBB0_7
@LBB0_11:
  inc edi
  cmp edi, 255
  je @LBB0_12
@LBB0_7:
  vcvtsi2ss xmm0, xmm13, edi
  vmulss xmm0, xmm0, dword ptr [rip + LCPI0_6]
  vmovss xmm3, dword ptr [rip + LCPI0_3]
  vaddss xmm2, xmm0, xmm3
  vmulss xmm1, xmm2, dword ptr [rip + LCPI0_7]
  vmovss xmm4, dword ptr [rip + LCPI0_8]
  vsubss xmm0, xmm4, xmm0
  vucomiss xmm2, xmm3
  seta bl
  vmulss xmm3, xmm0, xmm0
  vmovss xmm6, dword ptr [rip + LCPI0_2]
  vucomiss xmm2, xmm6
  setb bpl
  vbroadcastss ymm4, xmm2
  vbroadcastss xmm5, dword ptr [rip + LCPI0_0]
  vmovups yword ptr [rsp + 352], ymm4
  vandps xmm5, xmm4, xmm5
  vucomiss xmm5, dword ptr [rip + LCPI0_1]
  setb r14b
  vmovd xmm5, ebx
  vpbroadcastb xmm4, xmm5
  vmovd xmm5, ebp
  vpbroadcastb xmm7, xmm5
  vmovd xmm5, r14d
  vpbroadcastb xmm5, xmm5
  vbroadcastss ymm0, xmm0
  vmovups yword ptr [rsp + 320], ymm0
  vbroadcastss ymm0, xmm3
  vmovups yword ptr [rsp + 288], ymm0
  vbroadcastss ymm0, xmm1
  vmovups yword ptr [rsp + 256], ymm0
  vpor xmm0, xmm5, xmm7
  vmovdqa dqword ptr [rsp + 96], xmm0
  vmovdqa dqword ptr [rsp + 112], xmm5
  vpandn xmm0, xmm5, xmm7
  vpandn xmm1, xmm4, xmm0
  vmovdqa dqword ptr [rsp + 64], xmm1
  vdivss xmm2, xmm6, xmm2
  vbroadcastss ymm1, xmm2
  vmovups yword ptr [rsp + 224], ymm1
  vmovdqa dqword ptr [rsp + 128], xmm4
  vmovdqa dqword ptr [rsp + 80], xmm0
  vpand xmm0, xmm0, xmm4
  vmovdqa dqword ptr [rsp + 48], xmm0
  vxorps xmm8, xmm8, xmm8
  xor ebx, ebx
@LBB0_8:
  vmovups ymm2, yword ptr [rsp + 4*rbx + 384]
  vandps ymm15, ymm13, ymm2
  vmaxps ymm7, ymm15, ymm9
  vpxor xmm4, xmm4, xmm4
  vrsqrtps ymm9, ymm7
  vmulps ymm10, ymm9, ymm7
  vbroadcastss ymm14, dword ptr [rip + LCPI0_9]
  vfmadd213ps ymm9, ymm10, ymm14
  vbroadcastss ymm3, dword ptr [rip + LCPI0_10]
  vmulps ymm10, ymm10, ymm3
  vmulps ymm9, ymm10, ymm9
  vandps ymm7, ymm13, ymm7
  vbroadcastss ymm1, dword ptr [rip + LCPI0_11]
  vcmpleps ymm7, ymm1, ymm7
  vandps ymm9, ymm9, ymm7
  vcmpleps ymm7, ymm9, ymm11
  vextractf128 xmm10, ymm7, 1
  vpackssdw xmm0, xmm7, xmm10
  vmovdqa dqword ptr [rsp + 144], xmm0
  vsubps ymm7, ymm11, ymm15
  vmaxps ymm7, ymm7, ymm4
  vrsqrtps ymm10, ymm7
  vmovaps ymm0, ymm11
  vmulps ymm11, ymm10, ymm7
  vfmadd213ps ymm10, ymm11, ymm14
  vmulps ymm11, ymm11, ymm3
  vmulps ymm10, ymm11, ymm10
  vandps ymm7, ymm13, ymm7
  vcmpleps ymm7, ymm1, ymm7
  vandps ymm7, ymm10, ymm7
  vsubps ymm10, ymm0, ymm7
  vcmpltps ymm7, ymm10, ymm4
  vextractf128 xmm11, ymm7, 1
  vpackssdw xmm7, xmm7, xmm11
  vcmpltps ymm11, ymm0, ymm10
  vextractf128 xmm5, ymm11, 1
  vpackssdw xmm11, xmm11, xmm5
  vpmovzxwd ymm5, dqword ptr [rsp + 112]
  vpslld ymm5, ymm5, 31
  vblendvps ymm5, ymm9, ymm15, ymm5
  vmovups ymm1, yword ptr [rsp + 256]
  vfmadd213ps ymm15, ymm1, yword ptr [rsp + 288]
  vmaxps ymm9, ymm15, ymm4
  vrsqrtps ymm15, ymm9
  vmovdqa xmm12, dqword ptr [rsp + 64]
  vpandn xmm3, xmm7, xmm12
  vpand xmm3, xmm11, xmm3
  vmulps ymm6, ymm9, ymm15
  vfmadd213ps ymm15, ymm6, ymm14
  vbroadcastss ymm1, dword ptr [rip + LCPI0_10]
  vmulps ymm6, ymm6, ymm1
  vmulps ymm6, ymm15, ymm6
  vandps ymm9, ymm9, ymm13
  vbroadcastss ymm1, dword ptr [rip + LCPI0_11]
  vcmpleps ymm9, ymm1, ymm9
  vandps ymm6, ymm9, ymm6
  vmovups ymm1, yword ptr [rsp + 320]
  vsubps ymm6, ymm6, ymm1
  vbroadcastss ymm9, dword ptr [rip + LCPI0_12]
  vmulps ymm6, ymm9, ymm6
  vmulps ymm9, ymm6, yword ptr [rsp + 224]
  vcmpltps ymm6, ymm9, ymm4
  vextractf128 xmm15, ymm6, 1
  vpackssdw xmm6, xmm6, xmm15
  vpor xmm15, xmm7, dqword ptr [rsp + 128]
  vpor xmm11, xmm15, xmm11
  vmovdqa xmm4, dqword ptr [rsp + 144]
  vpor xmm14, xmm4, dqword ptr [rsp + 96]
  vpmovzxwd ymm14, xmm14
  vpslld ymm14, ymm14, 31
  vblendvps ymm5, ymm0, ymm5, ymm14
  vpand xmm7, xmm12, xmm7
  vpmovzxwd ymm7, xmm7
  vpslld ymm7, ymm7, 31
  vpsrad ymm7, ymm7, 31
  vpandn ymm5, ymm7, ymm5
  vpandn xmm7, xmm11, dqword ptr [rsp + 80]
  vmovaps ymm11, ymm0
  vpmovzxwd ymm7, xmm7
  vpslld ymm7, ymm7, 31
  vblendvps ymm5, ymm5, ymm10, ymm7
  vcmpltps ymm7, ymm0, ymm9
  vextractf128 xmm10, ymm7, 1
  vpackssdw xmm7, xmm7, xmm10
  vmovdqu xmm10, dqword ptr [rip + LCPI0_17]
  vmovdqu xmm4, dqword ptr [rip + LCPI0_16]
  vbroadcastss ymm0, dword ptr [rip + LCPI0_14]
  vpmovzxwd ymm3, xmm3
  vpslld ymm3, ymm3, 31
  vblendvps ymm3, ymm5, ymm11, ymm3
  vmovdqa xmm12, dqword ptr [rsp + 48]
  vpand xmm5, xmm12, xmm6
  vpmovzxwd ymm5, xmm5
  vpslld ymm5, ymm5, 31
  vpsrad ymm5, ymm5, 31
  vpandn ymm3, ymm5, ymm3
  vpor xmm5, xmm6, xmm7
  vpandn xmm5, xmm5, xmm12
  vpmovzxwd ymm5, xmm5
  vpslld ymm5, ymm5, 31
  vblendvps ymm3, ymm3, ymm9, ymm5
  vxorps xmm9, xmm9, xmm9
  vpandn xmm5, xmm6, xmm12
  vpand xmm5, xmm5, xmm7
  vpmovzxwd ymm5, xmm5
  vpslld ymm5, ymm5, 31
  vblendvps ymm3, ymm3, ymm11, ymm5
  vcmpleps ymm2, ymm9, ymm2
  vbroadcastss ymm5, dword ptr [rip + LCPI0_13]
  vxorps ymm6, ymm3, ymm5
  vblendvps ymm2, ymm6, ymm3, ymm2
  vmulps ymm2, ymm2, ymm0
  vandps ymm3, ymm2, ymm5
  vbroadcastss ymm5, dword ptr [rip + LCPI0_15]
  vorps ymm3, ymm3, ymm5
  vaddps ymm2, ymm2, ymm3
  vroundps ymm2, ymm2, 11
  vcvttps2dq ymm2, ymm2
  vextracti128 xmm3, ymm2, 1
  vpackssdw xmm2, xmm2, xmm3
  vpacksswb xmm2, xmm2, xmm2
  vpmaxsb xmm2, xmm2, xmm4
  vpminsb xmm2, xmm2, xmm10
  vmovups ymm10, yword ptr [rsp + 192]
  vbroadcastss ymm0, dword ptr [rip + LCPI0_4]
  vmovq qword ptr [rsp + rbx + 160], xmm2
  vpmovsxbd ymm2, xmm2
  vcvtdq2ps ymm2, ymm2
  vmulps ymm3, ymm2, ymm0
  vandps ymm3, ymm13, ymm3
  vfmadd132ps ymm3, ymm1, yword ptr [rsp + 352]
  vmulps ymm2, ymm10, ymm2
  vfnmadd213ps ymm2, ymm3, yword ptr [r9 + 4*rbx]
  vfmadd231ps ymm8, ymm2, ymm2
  add rbx, 8
  cmp rbx, 32
  jne @LBB0_8
  vextractf128 xmm0, ymm8, 1
  vaddps xmm0, xmm8, xmm0
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  vucomiss xmm0, dword ptr [rsp + 12]
  jae @LBB0_11
  vmovaps xmm1, dqword ptr [rsp + 160]
  vmovaps dqword ptr [rsp + 16], xmm1
  vmovaps xmm1, dqword ptr [rsp + 176]
  vmovaps dqword ptr [rsp + 32], xmm1
  vmovss dword ptr [rsp + 12], xmm0
  mov esi, edi
  jmp @LBB0_11
@LBB0_3:
  lea r10, [rax + 8*rax]
  lea r10, [rdx + 2*r10]
@LBB0_5:
  vmovdqu dqword ptr [r10], xmm4
  mov word ptr [r10 + 16], 0
  inc rax
  sub r9, -128
  cmp rax, r8
  jne @LBB0_2
@LBB0_14:
  vmovaps xmm6, dqword ptr [rsp + 512]
  vmovaps xmm7, dqword ptr [rsp + 528]
  vmovaps xmm8, dqword ptr [rsp + 544]
  vmovaps xmm9, dqword ptr [rsp + 560]
  vmovaps xmm10, dqword ptr [rsp + 576]
  vmovaps xmm11, dqword ptr [rsp + 592]
  vmovaps xmm12, dqword ptr [rsp + 608]
  vmovaps xmm13, dqword ptr [rsp + 624]
  vmovaps xmm14, dqword ptr [rsp + 640]
  vmovaps xmm15, dqword ptr [rsp + 656]
  add rsp, 672
  pop rbx
  pop rbp
  pop rdi
  pop rsi
  pop r14
@LBB0_15:
  vzeroupper
end;
{$endif}

function GroupReconstructionErrorQ42NL(const XGroup:PPasLLMFloatArray;const aScale,aCurve:TPasLLMFloat):TPasLLMFloat;
const GroupSize=32;
var Index:TPasLLMInt32;
    InvScale,x:TPasLLMFloat;
begin
 result:=0.0;
 InvScale:=1.0/aScale;
 for Index:=0 to GroupSize-1 do begin
  x:=XGroup^[Index];
  result:=result+sqr(x-(DecodeQ42NLValueNibble(EncodeQ42NLValueNibble(x*InvScale,aCurve),aCurve)*aScale));
 end;
end;

procedure PascalQuantizeQ42NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      MaxBisectionIterations=12; // number of curve search iterations per group
var CountGroups,GroupIndex,BaseIndex,Index,ByteIndex:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale,ScaleRounded,ScaleUp,Curve,LowCurve,HighCurve,
    MidCurveCandidate,LowCurveCandidate,HighCurveCandidate,CurveCandidateStep,ErrorLeft,ErrorRight,ErrorMid,
    BestCurve,BestError:TPasLLMFloat;
    ScaleFP8:TPasLLMUInt8;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*((GroupSize shr 1)+2)]); // Pointer to the current group in q

  // Find the max absolute value in the current group
  MaxValue:=0.0;
  for Index:=0 to GroupSize-1 do begin
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue;

  if Scale<1e-6 then begin

  // If the scale is too small, set all values to zero
   for ByteIndex:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[ByteIndex]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=0; // Scale and curve both zero

  end else begin

   // Round up to next fp8 value to ensure dynamic range is not smaller than needed
   if Scale>0.0 then begin
    ScaleFP8:=ConvertFloat32ToFP8E5M2(Scale);
    ScaleRounded:=ConvertFP8E5M2ToFloat32(ScaleFP8);
    // If rounded value is less than original and incrementing doesn't overflow to NaN/Inf
    if (ScaleRounded<Scale) and (ScaleFP8<255) then begin
     ScaleUp:=ConvertFP8E5M2ToFloat32(ScaleFP8+1);
     // Check if ScaleUp is finite: exponent bits ($7f800000) must not be all 1s
     if (TPasLLMUInt32(pointer(@ScaleUp)^) and TPasLLMUInt32($7f800000))<>TPasLLMUInt32($7f800000) then begin
      Scale:=ScaleUp;
     end else begin
      Scale:=ScaleRounded;
     end;
    end else begin
     Scale:=ScaleRounded;
    end;
   end;

   // Automatic curve selection per group
   LowCurve:=-1.0;
   HighCurve:=1.0;

   // Initial best = neutral curve
   BestCurve:=0.0;
   BestError:=GroupReconstructionErrorQ42NL(XGroup,Scale,0.0);

   // Endpoint left
   ErrorLeft:=GroupReconstructionErrorQ42NL(XGroup,Scale,LowCurve);
   if ErrorLeft<BestError then begin
    BestError:=ErrorLeft;
    BestCurve:=LowCurve;
   end;

   // Endpoint right
   ErrorRight:=GroupReconstructionErrorQ42NL(XGroup,Scale,HighCurve);
   if ErrorRight<BestError then begin
    BestError:=ErrorRight;
    BestCurve:=HighCurve;
   end;

   // Bisection iterations
   for Index:=1 to MaxBisectionIterations do begin
    MidCurveCandidate:=(LowCurve+HighCurve)*0.5;
    CurveCandidateStep:=(HighCurve-LowCurve)*0.25;
    if CurveCandidateStep<1e-4 then begin
     CurveCandidateStep:=1e-4;
    end;
    LowCurveCandidate:=MidCurveCandidate-CurveCandidateStep;
    HighCurveCandidate:=MidCurveCandidate+CurveCandidateStep;
    if LowCurveCandidate<-1.0 then begin
     LowCurveCandidate:=-1.0;
    end else if HighCurveCandidate>1.0 then begin
     HighCurveCandidate:=1.0;
    end;
    ErrorLeft:=GroupReconstructionErrorQ42NL(XGroup,Scale,LowCurveCandidate);
    ErrorRight:=GroupReconstructionErrorQ42NL(XGroup,Scale,HighCurveCandidate);
    ErrorMid:=GroupReconstructionErrorQ42NL(XGroup,Scale,MidCurveCandidate);
    if ErrorMid<BestError then begin
     BestError:=ErrorMid;
     BestCurve:=MidCurveCandidate;
    end;
    if ErrorLeft<ErrorRight then begin
     HighCurve:=MidCurveCandidate;
    end else begin
     LowCurve:=MidCurveCandidate;
    end;
   end;

   // Clamp chosen curve (paranoia)
   Curve:=BestCurve;
   if Curve<-1.0 then begin
    Curve:=-1.0;
   end else if Curve>1.0 then begin
    Curve:=1.0;
   end;

   // Final quantization with best curve
   for ByteIndex:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[ByteIndex]:=(EncodeQ42NLValueNibble(XGroup^[(ByteIndex*2)+0]/Scale,Curve) shl 0) or
                        (EncodeQ42NLValueNibble(XGroup^[(ByteIndex*2)+1]/Scale,Curve) shl 4);
   end;

   // Store scale (FP8E5M2) and curve (signed int8)
   PPasLLMUInt8(Pointer(@QGroup[GroupSize shr 1]))^:=ConvertFloat32ToFP8E5M2(Scale);
   PPasLLMInt8(Pointer(@QGroup[(GroupSize shr 1)+1]))^:=TPasLLMInt8(round(Curve*127.0));

  end;

 end;

end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ43NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($358637bd);
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($bf800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7f800000);
      LCPI0_6:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_7:TPasLLMUInt32=TPasLLMUInt32($40800000);
      LCPI0_8:TPasLLMUInt32=TPasLLMUInt32($40000000);
      LCPI0_9:TPasLLMUInt32=TPasLLMUInt32($c0400000);
      LCPI0_10:TPasLLMUInt32=TPasLLMUInt32($bf000000); 
      LCPI0_11:TPasLLMUInt32=TPasLLMUInt32($00800000); 
      LCPI0_12:TPasLLMUInt32=TPasLLMUInt32($3f000000); 
      LCPI0_13:TPasLLMUInt32=TPasLLMUInt32($80000000); 
      LCPI0_14:TPasLLMUInt32=TPasLLMUInt32($40e00000); 
      LCPI0_15:TPasLLMUInt32=TPasLLMUInt32($3effffff); 
      LCPI0_16:TAlign16xUInt8=(Values:(249,249,249,249,249,249,249,249,0,0,0,0,0,0,0,0));    
      LCPI0_17:TAlign16xUInt8=(Values:(7,7,7,7,7,7,7,7,0,0,0,0,0,0,0,0));
      LCPI0_18:TAlign16xUInt8=(Values:(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));
      LCPI0_19:TAlign16xUInt8=(Values:(8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8));
      LCPI0_22:TAlign16xUInt8=(Values:(0,2,4,6,8,10,12,14,0,0,0,0,0,0,0,0));
      LCPI0_23:TAlign16xUInt8=(Values:(1,3,5,7,9,11,13,15,0,0,0,0,0,0,0,0));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  cmp r8d, 32
  jl @LBB0_17
  push rsi
  push rdi
  push rbp
  push rbx
  sub rsp, 760
  vmovaps dqword ptr [rsp + 736], xmm15
  vmovaps dqword ptr [rsp + 720], xmm14
  vmovaps dqword ptr [rsp + 704], xmm13
  vmovdqa dqword ptr [rsp + 688], xmm12
  vmovaps dqword ptr [rsp + 672], xmm11
  vmovaps dqword ptr [rsp + 656], xmm10
  vmovaps dqword ptr [rsp + 640], xmm9
  vmovaps dqword ptr [rsp + 624], xmm8
  vmovaps dqword ptr [rsp + 608], xmm7
  vmovaps dqword ptr [rsp + 592], xmm6
  shr r8d, 5
  xor eax, eax
  vbroadcastss xmm4, dword ptr [rip + LCPI0_0]
  vxorps xmm6, xmm6, xmm6
  vbroadcastss ymm9, dword ptr [rip + LCPI0_2]
  vxorps xmm10, xmm10, xmm10
  mov r9, rcx
  vmovdqu xmm15, dqword ptr [rip + LCPI0_17]
  vbroadcastss ymm8, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm14, dword ptr [rip + LCPI0_0]
  jmp @LBB0_2
@LBB0_14:
  vmovdqu xmm2, dqword ptr [rip + LCPI0_18]
  vpand xmm0, xmm2, dqword ptr [rsp + 32]
  vmovdqu xmm3, dqword ptr [rip + LCPI0_19]
  vpxor xmm0, xmm0, xmm3
  vmovq xmm4, qword ptr [rip + LCPI0_22]
  vpshufb xmm1, xmm0, xmm4
  vmovq xmm5, qword ptr [rip + LCPI0_23]
  vpshufb xmm0, xmm0, xmm5
  vpsllw xmm0, xmm0, 4
  vpand xmm2, xmm2, dqword ptr [rsp + 48]
  vpxor xmm2, xmm2, xmm3
  vpshufb xmm3, xmm2, xmm4
  vpunpcklqdq xmm1, xmm1, xmm3
  vpshufb xmm2, xmm2, xmm5
  vpsllw xmm2, xmm2, 4
  vpunpcklqdq xmm0, xmm0, xmm2
  vpor xmm0, xmm0, xmm1
  vmovdqu dqword ptr [rdx + r10], xmm0
  vmovdqa xmm0, dqword ptr [rsp + 16]
  vpextrw word ptr [rdx + r10 + 16], xmm0, 0
  add r11b, -127
  mov byte ptr [rdx + r10 + 18], r11b
  vbroadcastss xmm4, dword ptr [rip + LCPI0_0]
  vxorps xmm6, xmm6, xmm6
  inc rax
  sub r9, -128
  cmp rax, r8
  je @LBB0_16
@LBB0_2:
  mov r10, rax
  shl r10, 7
  vmovss xmm0, dword ptr [rcx + r10]
  vmovss xmm1, dword ptr [rcx + r10 + 4]
  vmovss xmm2, dword ptr [rcx + r10 + 8]
  vmovss xmm3, dword ptr [rcx + r10 + 12]
  vandps xmm0, xmm0, xmm4
  vmaxss xmm0, xmm0, xmm6
  vandps xmm1, xmm1, xmm4
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vandps xmm1, xmm3, xmm4
  vmovss xmm2, dword ptr [rcx + r10 + 16]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 20]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vmovss xmm1, dword ptr [rcx + r10 + 24]
  vandps xmm1, xmm1, xmm4
  vmovss xmm2, dword ptr [rcx + r10 + 28]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 32]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 36]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm0, xmm1, xmm0
  vmovss xmm1, dword ptr [rcx + r10 + 40]
  vandps xmm1, xmm1, xmm4
  vmovss xmm2, dword ptr [rcx + r10 + 44]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 48]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 52]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 56]
  vandps xmm2, xmm2, xmm4
  vmaxss xmm1, xmm2, xmm1
  vmaxss xmm1, xmm1, xmm0
  vmovss xmm0, dword ptr [rcx + r10 + 60]
  vandps xmm2, xmm0, xmm4
  vmovss xmm0, dword ptr [rcx + r10 + 64]
  vandps xmm3, xmm0, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 68]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 72]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 76]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 80]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 84]
  vandps xmm2, xmm2, xmm4
  vmovss xmm3, dword ptr [rcx + r10 + 88]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 92]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 96]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 100]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 104]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 108]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [rcx + r10 + 112]
  vandps xmm2, xmm2, xmm4
  vmovss xmm3, dword ptr [rcx + r10 + 116]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 120]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmovss xmm3, dword ptr [rcx + r10 + 124]
  vandps xmm3, xmm3, xmm4
  vmaxss xmm2, xmm3, xmm2
  vmaxss xmm1, xmm2, xmm1
  vucomiss xmm1, xmm6
  vxorps xmm3, xmm3, xmm3
  jbe @LBB0_6
{$ifdef fpc}
  vcvtps2ph xmm3, xmm1, 4
{$else}
  db $c4,$e3,$79,$1d,$cb,$04
{$endif}
  vcvtph2ps xmm2, xmm3
  vucomiss xmm1, xmm2
  jbe @LBB0_6
  vpextrw r10d, xmm3, 0
  inc r10d
  mov r11d, r10d
  and r11d, 32767
  cmp r11d, 31744
  jge @LBB0_6
  vpinsrw xmm3, xmm0, r10d, 0
@LBB0_6:
  vcvtph2ps xmm1, xmm3
  lea r10, [rax + 8*rax]
  lea r10, [rax + 2*r10]
  vucomiss xmm1, dword ptr [rip + LCPI0_1]
  jbe @LBB0_7
  vmovaps dqword ptr [rsp + 16], xmm3
  mov r11, rax
  shl r11, 5
  vmovss xmm2, dword ptr [rip + LCPI0_2]
  vdivss xmm2, xmm2, xmm1
  vbroadcastss ymm2, xmm2
  vmulps ymm3, ymm2, yword ptr [rcx + 4*r11]
  vbroadcastss ymm4, dword ptr [rip + LCPI0_3]
  vmaxps ymm3, ymm3, ymm4
  vminps ymm3, ymm9, ymm3
  vmovups yword ptr [rsp + 464], ymm3
  vmulps ymm3, ymm2, yword ptr [rcx + 4*r11 + 32]
  vmaxps ymm3, ymm3, ymm4
  vminps ymm3, ymm9, ymm3
  vmovups yword ptr [rsp + 496], ymm3
  vinsertps xmm0, xmm0, dword ptr [rcx + 4*r11 + 68], 16
  vinsertf128 ymm0, ymm0, dqword ptr [rcx + 4*r11 + 80], 1
  vmovddup xmm3, qword ptr [rcx + 4*r11 + 72]
  vblendps ymm0, ymm0, ymm3, 12
  vmulps ymm0, ymm0, ymm2
  vmaxps ymm0, ymm0, ymm4
  vminps ymm0, ymm9, ymm0
  vmovups yword ptr [rsp + 528], ymm0
  vmulps ymm0, ymm2, yword ptr [rcx + 4*r11 + 96]
  vmaxps ymm0, ymm0, ymm4
  vminps ymm0, ymm9, ymm0
  vmovups yword ptr [rsp + 560], ymm0
  vmulss xmm0, xmm1, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm11, xmm0
  xor esi, esi
  xor r11d, r11d
  vmovss xmm0, dword ptr [rip + LCPI0_5]
  vmovss dword ptr [rsp + 12], xmm0
  vmovups yword ptr [rsp + 208], ymm11
  jmp @LBB0_9
@LBB0_13:
  inc esi
  cmp esi, 255
  je @LBB0_14
@LBB0_9:
  vcvtsi2ss xmm0, xmm14, esi
  vmulss xmm0, xmm0, dword ptr [rip + LCPI0_6]
  vmovss xmm3, dword ptr [rip + LCPI0_3]
  vaddss xmm2, xmm0, xmm3
  vmulss xmm1, xmm2, dword ptr [rip + LCPI0_7]
  vmovss xmm4, dword ptr [rip + LCPI0_8]
  vsubss xmm0, xmm4, xmm0
  vucomiss xmm2, xmm3
  seta dil
  vmulss xmm4, xmm0, xmm0
  vmovss xmm7, dword ptr [rip + LCPI0_2]
  vucomiss xmm2, xmm7
  setb bl
  vbroadcastss ymm5, xmm2
  vbroadcastss xmm3, dword ptr [rip + LCPI0_0]
  vmovups yword ptr [rsp + 368], ymm5
  vandps xmm3, xmm5, xmm3
  vucomiss xmm3, dword ptr [rip + LCPI0_1]
  setb bpl
  vmovd xmm3, edi
  vpbroadcastb xmm5, xmm3
  vmovd xmm3, ebx
  vpbroadcastb xmm6, xmm3
  vmovd xmm3, ebp
  vpbroadcastb xmm3, xmm3
  vbroadcastss ymm0, xmm0
  vmovups yword ptr [rsp + 336], ymm0
  vbroadcastss ymm0, xmm4
  vmovups yword ptr [rsp + 304], ymm0
  vbroadcastss ymm0, xmm1
  vmovups yword ptr [rsp + 272], ymm0
  vpor xmm0, xmm3, xmm6
  vmovdqa dqword ptr [rsp + 112], xmm0
  vmovdqa dqword ptr [rsp + 128], xmm3
  vpandn xmm1, xmm3, xmm6
  vpandn xmm0, xmm5, xmm1
  vmovdqa dqword ptr [rsp + 80], xmm0
  vdivss xmm0, xmm7, xmm2
  vbroadcastss ymm0, xmm0
  vmovups yword ptr [rsp + 240], ymm0
  vmovdqa dqword ptr [rsp + 144], xmm5
  vmovdqa dqword ptr [rsp + 96], xmm1
  vpand xmm0, xmm1, xmm5
  vmovdqa dqword ptr [rsp + 64], xmm0
  vpxor xmm1, xmm1, xmm1
  xor edi, edi
@LBB0_10:
  vmovdqu yword ptr [rsp + 432], ymm1
  vmovups ymm0, yword ptr [rsp + 4*rdi + 464]
  vmovups yword ptr [rsp + 400], ymm0
  vandps ymm6, ymm14, ymm0
  vmaxps ymm0, ymm10, ymm6
  vrsqrtps ymm7, ymm0
  vpxor xmm5, xmm5, xmm5
  vmulps ymm10, ymm0, ymm7
  vbroadcastss ymm13, dword ptr [rip + LCPI0_9]
  vfmadd213ps ymm7, ymm10, ymm13
  vbroadcastss ymm11, dword ptr [rip + LCPI0_10]
  vmulps ymm10, ymm10, ymm11
  vmulps ymm7, ymm10, ymm7
  vandps ymm0, ymm14, ymm0
  vbroadcastss ymm2, dword ptr [rip + LCPI0_11]
  vcmpleps ymm0, ymm2, ymm0
  vandps ymm0, ymm0, ymm7
  vcmpleps ymm7, ymm0, ymm9
  vextractf128 xmm10, ymm7, 1
  vpackssdw xmm1, xmm7, xmm10
  vmovdqa dqword ptr [rsp + 160], xmm1
  vsubps ymm7, ymm9, ymm6
  vmaxps ymm7, ymm7, ymm5
  vrsqrtps ymm10, ymm7
  vmulps ymm12, ymm10, ymm7
  vfmadd213ps ymm10, ymm12, ymm13
  vmulps ymm12, ymm12, ymm11
  vmulps ymm10, ymm12, ymm10
  vandps ymm7, ymm14, ymm7
  vcmpleps ymm7, ymm2, ymm7
  vandps ymm7, ymm10, ymm7
  vsubps ymm10, ymm9, ymm7
  vcmpltps ymm7, ymm10, ymm5
  vextractf128 xmm12, ymm7, 1
  vpackssdw xmm7, xmm7, xmm12
  vcmpltps ymm12, ymm9, ymm10
  vmovaps ymm3, ymm9
  vextractf128 xmm9, ymm12, 1
  vpackssdw xmm12, xmm12, xmm9
  vpmovzxwd ymm9, dqword ptr [rsp + 128]
  vpslld ymm9, ymm9, 31
  vblendvps ymm9, ymm0, ymm6, ymm9
  vmovups ymm0, yword ptr [rsp + 272]
  vfmadd213ps ymm6, ymm0, yword ptr [rsp + 304]
  vmaxps ymm0, ymm6, ymm5
  vrsqrtps ymm6, ymm0
  vmovdqa xmm2, dqword ptr [rsp + 80]
  vpandn xmm1, xmm7, xmm2
  vpand xmm4, xmm12, xmm1
  vmovaps ymm1, ymm8
  vmovdqa xmm8, xmm15
  vmulps ymm15, ymm0, ymm6
  vfmadd213ps ymm6, ymm15, ymm13
  vmulps ymm15, ymm15, ymm11
  vmulps ymm6, ymm15, ymm6
  vandps ymm0, ymm14, ymm0
  vbroadcastss ymm11, dword ptr [rip + LCPI0_11]
  vcmpleps ymm0, ymm11, ymm0
  vandps ymm0, ymm0, ymm6
  vmovups ymm13, yword ptr [rsp + 336]
  vsubps ymm0, ymm0, ymm13
  vbroadcastss ymm6, dword ptr [rip + LCPI0_12]
  vmulps ymm0, ymm0, ymm6
  vmulps ymm0, ymm0, yword ptr [rsp + 240]
  vcmpltps ymm6, ymm0, ymm5
  vextractf128 xmm15, ymm6, 1
  vpackssdw xmm6, xmm6, xmm15
  vpor xmm15, xmm7, dqword ptr [rsp + 144]
  vpor xmm12, xmm15, xmm12
  vmovdqa xmm15, xmm8
  vmovaps ymm8, ymm1
  vmovdqa xmm1, dqword ptr [rsp + 160]
  vpor xmm11, xmm1, dqword ptr [rsp + 112]
  vpmovzxwd ymm11, xmm11
  vpslld ymm11, ymm11, 31
  vblendvps ymm9, ymm3, ymm9, ymm11
  vmovups ymm11, yword ptr [rsp + 208]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_14]
  vpand xmm7, xmm2, xmm7
  vpmovzxwd ymm7, xmm7
  vpslld ymm7, ymm7, 31
  vpsrad ymm7, ymm7, 31
  vpandn ymm7, ymm7, ymm9
  vpandn xmm9, xmm12, dqword ptr [rsp + 96]
  vmovdqu xmm12, dqword ptr [rip + LCPI0_16]
  vpmovzxwd ymm9, xmm9
  vpslld ymm9, ymm9, 31
  vblendvps ymm7, ymm7, ymm10, ymm9
  vcmpltps ymm9, ymm3, ymm0
  vextractf128 xmm10, ymm9, 1
  vpackssdw xmm9, xmm9, xmm10
  vxorps xmm10, xmm10, xmm10
  vpmovzxwd ymm1, xmm4
  vpslld ymm1, ymm1, 31
  vblendvps ymm1, ymm7, ymm3, ymm1
  vmovdqa xmm2, dqword ptr [rsp + 64]
  vpand xmm7, xmm2, xmm6
  vpmovzxwd ymm7, xmm7
  vpslld ymm7, ymm7, 31
  vpsrad ymm7, ymm7, 31
  vpandn ymm1, ymm7, ymm1
  vpor xmm7, xmm9, xmm6
  vpandn xmm7, xmm7, xmm2
  vpmovzxwd ymm7, xmm7
  vpslld ymm7, ymm7, 31
  vblendvps ymm0, ymm1, ymm0, ymm7
  vpandn xmm1, xmm6, xmm2
  vpand xmm1, xmm9, xmm1
  vmovaps ymm9, ymm3
  vpmovzxwd ymm1, xmm1
  vpslld ymm1, ymm1, 31
  vblendvps ymm0, ymm0, ymm3, ymm1
  vcmpleps ymm1, ymm10, yword ptr [rsp + 400]
  vbroadcastss ymm2, dword ptr [rip + LCPI0_13]
  vxorps ymm6, ymm0, ymm2
  vblendvps ymm0, ymm6, ymm0, ymm1
  vmulps ymm0, ymm0, ymm5
  vandps ymm1, ymm0, ymm2
  vbroadcastss ymm2, dword ptr [rip + LCPI0_15]
  vorps ymm1, ymm1, ymm2
  vaddps ymm0, ymm0, ymm1
  vroundps ymm0, ymm0, 11
  vcvttps2dq ymm0, ymm0
  vextracti128 xmm1, ymm0, 1
  vpackssdw xmm0, xmm0, xmm1
  vpacksswb xmm0, xmm0, xmm0
  vpmaxsb xmm0, xmm0, xmm12
  vpminsb xmm0, xmm0, xmm15
  vmovq qword ptr [rsp + rdi + 176], xmm0
  vpmovsxbd ymm0, xmm0
  vcvtdq2ps ymm0, ymm0
  vmulps ymm1, ymm8, ymm0
  vandps ymm1, ymm14, ymm1
  vfmadd132ps ymm1, ymm13, yword ptr [rsp + 368]
  vmulps ymm0, ymm11, ymm0
  vfnmadd213ps ymm0, ymm1, yword ptr [r9 + 4*rdi]
  vmovups ymm1, yword ptr [rsp + 432]
  vfmadd231ps ymm1, ymm0, ymm0
  add rdi, 8
  cmp rdi, 32
  jne @LBB0_10
  vextractf128 xmm0, ymm1, 1
  vaddps xmm0, xmm1, xmm0
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  vucomiss xmm0, dword ptr [rsp + 12]
  jae @LBB0_13
  vmovaps xmm1, dqword ptr [rsp + 176]
  vmovaps dqword ptr [rsp + 32], xmm1
  vmovaps xmm1, dqword ptr [rsp + 192]
  vmovaps dqword ptr [rsp + 48], xmm1
  vmovss dword ptr [rsp + 12], xmm0
  mov r11d, esi
  jmp @LBB0_13
@LBB0_7:
  vpxor xmm0, xmm0, xmm0
  vmovdqu dqword ptr [rdx + r10], xmm0
  vpxor xmm0, xmm0, xmm0
  vpextrw word ptr [rdx + r10 + 16], xmm0, 0
  mov byte ptr [rdx + r10 + 18], 0
  inc rax
  sub r9, -128
  cmp rax, r8
  jne @LBB0_2
@LBB0_16:
  vmovaps xmm6, dqword ptr [rsp + 592]
  vmovaps xmm7, dqword ptr [rsp + 608]
  vmovaps xmm8, dqword ptr [rsp + 624]
  vmovaps xmm9, dqword ptr [rsp + 640]
  vmovaps xmm10, dqword ptr [rsp + 656]
  vmovaps xmm11, dqword ptr [rsp + 672]
  vmovaps xmm12, dqword ptr [rsp + 688]
  vmovaps xmm13, dqword ptr [rsp + 704]
  vmovaps xmm14, dqword ptr [rsp + 720]
  vmovaps xmm15, dqword ptr [rsp + 736]
  add rsp, 760
  pop rbx
  pop rbp
  pop rdi
  pop rsi
@LBB0_17:
  vzeroupper
end;
{$endif}     

function GroupReconstructionErrorQ43NL(const XGroup:PPasLLMFloatArray;const aScale,aCurve:TPasLLMFloat):TPasLLMFloat;
const GroupSize=32;
var Index:TPasLLMInt32;
    InvScale,x:TPasLLMFloat;
begin
 result:=0.0;
 InvScale:=1.0/aScale;
 for Index:=0 to GroupSize-1 do begin
  x:=XGroup^[Index];
  result:=result+sqr(x-(DecodeQ43NLValueNibble(EncodeQ43NLValueNibble(x*InvScale,aCurve),aCurve)*aScale));
 end;
end;

procedure PascalQuantizeQ43NL(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      MaxBisectionIterations=12; // number of curve search iterations per group
var CountGroups,GroupIndex,BaseIndex,Index,ByteIndex:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale,ScaleRounded,ScaleUp,Curve,LowCurve,HighCurve,
    MidCurveCandidate,LowCurveCandidate,HighCurveCandidate,CurveCandidateStep,ErrorLeft,ErrorRight,ErrorMid,
    BestCurve,BestError:TPasLLMFloat;
    ScaleFP16:TPasLLMUInt16;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group
  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*((GroupSize shr 1)+3)]); // Pointer to the current group in q

  // Find the max absolute value in the current group
  MaxValue:=0.0;
  for Index:=0 to GroupSize-1 do begin
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue;

  if Scale<1e-6 then begin

  // If the scale is too small, set all values to zero
   for ByteIndex:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[ByteIndex]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=0; // Scale and curve both zero
   PPasLLMUInt8(Pointer(@QGroup[(GroupSize shr 1)+2]))^:=0; // Scale and curve both zero

  end else begin

   // Round up to next fp16 value to ensure dynamic range is not smaller than needed
   if Scale>0.0 then begin
    ScaleFP16:=ConvertFloat32ToFloat16(Scale);
    ScaleRounded:=ConvertFloat32ToFloat16(ScaleFP16);
    // If rounded value is less than original and incrementing doesn't overflow to NaN/Inf
    if (ScaleRounded<Scale) and (ScaleFP16<65535) then begin
     ScaleUp:=ConvertFloat16ToFloat32(ScaleFP16+1);
     // Check if ScaleUp is finite: exponent bits ($7f800000) must not be all 1s
     if (TPasLLMUInt32(pointer(@ScaleUp)^) and TPasLLMUInt32($7f800000))<>TPasLLMUInt32($7f800000) then begin
      Scale:=ScaleUp;
     end else begin
      Scale:=ScaleRounded;
     end;
    end else begin
     Scale:=ScaleRounded;
    end;
   end;

   // Automatic curve selection per group
   LowCurve:=-1.0;
   HighCurve:=1.0;

   // Initial best = neutral curve
   BestCurve:=0.0;
   BestError:=GroupReconstructionErrorQ43NL(XGroup,Scale,0.0);

   // Endpoint left
   ErrorLeft:=GroupReconstructionErrorQ43NL(XGroup,Scale,LowCurve);
   if ErrorLeft<BestError then begin
    BestError:=ErrorLeft;
    BestCurve:=LowCurve;
   end;

   // Endpoint right
   ErrorRight:=GroupReconstructionErrorQ43NL(XGroup,Scale,HighCurve);
   if ErrorRight<BestError then begin
    BestError:=ErrorRight;
    BestCurve:=HighCurve;
   end;

   // Bisection iterations
   for Index:=1 to MaxBisectionIterations do begin
    MidCurveCandidate:=(LowCurve+HighCurve)*0.5;
    CurveCandidateStep:=(HighCurve-LowCurve)*0.25;
    if CurveCandidateStep<1e-4 then begin
     CurveCandidateStep:=1e-4;
    end;
    LowCurveCandidate:=MidCurveCandidate-CurveCandidateStep;
    HighCurveCandidate:=MidCurveCandidate+CurveCandidateStep;
    if LowCurveCandidate<-1.0 then begin
     LowCurveCandidate:=-1.0;
    end else if HighCurveCandidate>1.0 then begin
     HighCurveCandidate:=1.0;
    end;
    ErrorLeft:=GroupReconstructionErrorQ43NL(XGroup,Scale,LowCurveCandidate);
    ErrorRight:=GroupReconstructionErrorQ43NL(XGroup,Scale,HighCurveCandidate);
    ErrorMid:=GroupReconstructionErrorQ43NL(XGroup,Scale,MidCurveCandidate);
    if ErrorMid<BestError then begin
     BestError:=ErrorMid;
     BestCurve:=MidCurveCandidate;
    end;
    if ErrorLeft<ErrorRight then begin
     HighCurve:=MidCurveCandidate;
    end else begin
     LowCurve:=MidCurveCandidate;
    end;
   end;

   // Clamp chosen curve (paranoia)
   Curve:=BestCurve;
   if Curve<-1.0 then begin
    Curve:=-1.0;
   end else if Curve>1.0 then begin
    Curve:=1.0;
   end;

   // Final quantization with best curve
   for ByteIndex:=0 to (GroupSize shr 1)-1 do begin
    QGroup^[ByteIndex]:=(EncodeQ43NLValueNibble(XGroup^[(ByteIndex*2)+0]/Scale,Curve) shl 0) or
                        (EncodeQ43NLValueNibble(XGroup^[(ByteIndex*2)+1]/Scale,Curve) shl 4);
   end;

   // Store scale (FP16) and curve (signed int8)
   PPasLLMUInt16(Pointer(@QGroup[GroupSize shr 1]))^:=ConvertFloat32ToFloat16(Scale);
   PPasLLMInt8(Pointer(@QGroup[(GroupSize shr 1)+2]))^:=TPasLLMInt8(round(Curve*127.0));

  end;

 end;

end;

{$ifdef cpuamd64}
procedure AMD64ClearNaNs(const aX:Pointer;const aCount:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 test edx,edx
 jle @Exit
 sub edx,1
 shr edx,3
 sal rdx,5
 lea rax,[rcx+rdx+32]
@Loop:
 vmovups ymm0,yword ptr [rcx]
 vcmpps ymm1,ymm0,ymm0,7
 vpsrad ymm1,ymm1,31
 vandps ymm0,ymm0,ymm1
 vmovups yword ptr [rcx],ymm0
 add rcx,32
 cmp rax,rcx
 jne @Loop
 vzeroupper
@Exit:
end;
{$endif}

procedure PascalClearNaNs(const aX:Pointer;const aCount:TPasLLMInt32);
var Index:TPasLLMInt32;
    Value:PPasLLMUInt32;
    Casted:TPasLLMUInt32;
begin
 Value:=aX;
 for Index:=0 to aCount-1 do begin
  Casted:=PPasLLMUInt32(Value)^;
  if ((Casted and $7f800000)=$7f800000) and ((Casted and $007fffff)<>0) then begin
   PPasLLMUInt32(Value)^:=0;
  end;
  inc(Value);
 end;
end;

procedure ClearNaNs(const aX:Pointer;const aCount:TPasLLMInt32);
begin
 if aCount>0 then begin
 {$if defined(cpuamd64)}
  if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
   AMD64ClearNaNs(aX,aCount);
   if (aCount and 7)<>0 then begin
    PascalClearNaNs(@PPasLLMFloatArray(aX)^[aCount and not 7],aCount and 7);
   end;
  end else{$ifend}begin
   PascalClearNaNs(aX,aCount);
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64QuantizeQ80(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const AbsoluteBitMask:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      OneOver127:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      OneDotNullMinusE6:TPasLLMUInt32=TPasLLMUInt32($358637bd);
      Value127:TPasLLMUInt32=TPasLLMUInt32($42fe0000);
      Shuffles:array[0..7] of TPasLLMUInt32=(0,4,1,5,2,6,3,7);
asm
{$ifndef fpc}
 .noframe
{$endif}
  lea eax, [r8 + 31]
  test r8d, r8d
  cmovns eax, r8d
  cmp r8d, 32
  jl @Exit
  sub rsp, 104
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovapd dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  sar eax, 5
  vbroadcastss ymm0, dword ptr [rip + AbsoluteBitMask]
  vmovss xmm1, dword ptr [rip + OneOver127]
  vmovss xmm2, dword ptr [rip + OneDotNullMinusE6]
  vmovss xmm3, dword ptr [rip + Value127]
  vmovdqu ymm4, yword ptr [rip + Shuffles]
  jmp @LoopStart
@LoopQuantize:
  vbroadcastss ymm10, xmm11
  vmulps ymm5, ymm10, ymm5
  vmulps ymm6, ymm10, ymm6
  vmulps ymm7, ymm10, ymm7
  vmulps ymm8, ymm10, ymm8
  vroundps ymm5, ymm5, 0
  vroundps ymm6, ymm6, 0
  vroundps ymm7, ymm7, 0
  vroundps ymm8, ymm8, 0
  vcvtps2dq ymm5, ymm5
  vcvtps2dq ymm6, ymm6
  vpackssdw ymm5, ymm5, ymm6
  vcvtps2dq ymm6, ymm7
  vcvtps2dq ymm7, ymm8
  vpackssdw ymm6, ymm6, ymm7
  vpacksswb ymm5, ymm5, ymm6
  vpermd ymm6, ymm4, ymm5
{$ifdef fpc}
  vcvtps2ph xmm5, xmm9, 4
{$else}
  db $c4,$63,$79,$1d,$cd,$04
{$endif}
@LoopStoreResult:
  vmovdqu yword ptr [rdx], ymm6
  vpextrw word ptr [rdx + 32], xmm5, 0
  add rdx, 34
  sub rcx, -128
  dec eax
  je @LoopExit
@LoopStart:
  vmovups ymm5, yword ptr [rcx]
  vmovups ymm6, yword ptr [rcx + 32]
  vmovups ymm7, yword ptr [rcx + 64]
  vmovups ymm8, yword ptr [rcx + 96]
  vandps ymm9, ymm5, ymm0
  vandps ymm10, ymm6, ymm0
  vmaxps ymm9, ymm9, ymm10
  vandps ymm10, ymm7, ymm0
  vandps ymm11, ymm8, ymm0
  vmaxps ymm10, ymm10, ymm11
  vmaxps ymm9, ymm9, ymm10
  vextractf128 xmm10, ymm9, 1
  vmaxps xmm9, xmm10, xmm9
  vshufpd xmm10, xmm9, xmm9, 3
  vmaxps xmm9, xmm9, xmm10
  vmovshdup xmm10, xmm9
  vmaxss xmm10, xmm9, xmm10
  vmulss xmm9, xmm10, xmm1
  vucomiss xmm9, xmm2
  jae @LoopScalarNotZero
@LoopScalarZero:
  vxorps xmm5, xmm5, xmm5
  vxorps xmm6, xmm6, xmm6
  jmp @LoopStoreResult
@LoopScalarNotZero:
  vxorps xmm11, xmm11, xmm11
  vucomiss xmm10, xmm11
  je @LoopQuantize
  vdivss xmm11, xmm3, xmm10
  jmp @LoopQuantize
@LoopExit:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  add rsp, 104
@Exit:
  vzeroupper
end;
{$endif}

procedure PascalQuantizeQ80(const aX:Pointer;const aQ:Pointer;const Count:TPasLLMInt32); {$ifdef fpc}ms_abi_default;{$endif}
const GroupSize=32; // Group size for quantization
      QMax=127.0; // Max value for int8_t
var CountGroups,GroupIndex,BaseIndex,Index:TPasLLMInt32;
    XGroup:PPasLLMFloatArray;
    QGroup:PPasLLMUInt8Array;
    Value,MaxValue,Scale:TPasLLMFloat;
begin

 CountGroups:=Count div GroupSize; // Number of groups

 for GroupIndex:=0 to CountGroups-1 do begin

  BaseIndex:=GroupIndex*GroupSize; // Calculate the base index for the current group

  XGroup:=Pointer(@PPasLLMFloatArray(aX)^[BaseIndex]); // Pointer to the current group in x

  MaxValue:=0.0; // Initialize the max value for this group
  for Index:=0 to GroupSize-1 do begin
   // Find the max absolute value in the current group
   Value:=abs(XGroup^[Index]);
   if MaxValue<Value then begin
    MaxValue:=Value;
   end;
  end;

  // Calculate the scaling factor
  Scale:=MaxValue/QMax;

  // Calculate and write the quantized values and the scaling factor
  QGroup:=Pointer(@PPasLLMUInt8Array(aQ)^[GroupIndex*(GroupSize+2)]); // Pointer to the current group in q
  if Scale<1e-6 then begin
   // If the scale is too small, set all values to zero
   for Index:=0 to GroupSize-1 do begin
    QGroup^[Index]:=0; // Set to zero if scale is too small
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize]))^:=0; // Set the scale factor to zero
  end else begin
   for Index:=0 to GroupSize-1 do begin
    QGroup^[Index]:=TPasLLMInt8(round(XGroup^[Index]/Scale)); // Round and clamp
   end;
   PPasLLMUInt16(Pointer(@QGroup[GroupSize]))^:=ConvertFloat32ToFloat16(Scale); // Store the scale factor in the last two bytes
  end;
 end;

end;

procedure PascalQuantizeF8E4M3(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  // Convert each float to FP8 E4M3 format
  PPasLLMUInt8Array(aQ)^[Index]:=ConvertFloat32ToFP8E4M3(PPasLLMFloatArray(aX)^[Index]);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64QuantizeF8E5M2(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_18
  push rsi
  push rdi
  push rbx
  mov eax, r8d
  cmp r8d, 3
  jbe @LBB0_2
  lea r9, [rdx + rax]
  lea r10, [rcx + 4*rax]
  cmp rdx, r10
  setb r10b
  cmp rcx, r9
  setb r9b
  test r10b, r9b
  je @LBB0_8
@LBB0_2:
  xor esi, esi
@LBB0_3:
  mov rdi, rsi
  test al, 1
  je @LBB0_5
  vmovss xmm0, dword ptr [rcx + 4*rsi]
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  vpextrw ebx, xmm0, 0
  mov byte ptr [rdx + rsi], bh
  mov rdi, rsi
  or rdi, 1
@LBB0_5:
  lea r8, [rax - 1]
  cmp rsi, r8
  je @LBB0_17
@LBB0_6:
  vmovss xmm0, dword ptr [rcx + 4*rdi]
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  vpextrw ebx, xmm0, 0
  mov byte ptr [rdx + rdi], bh
  vmovss xmm0, dword ptr [rcx + 4*rdi + 4]
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  vpextrw ebx, xmm0, 0
  mov byte ptr [rdx + rdi + 1], bh
  add rdi, 2
  cmp rax, rdi
  jne @LBB0_6
@LBB0_17:
  pop rbx
  pop rdi
  pop rsi
@LBB0_18:
  vzeroupper
  jmp @Exit
@LBB0_8:
  cmp r8d, 32
  jae @LBB0_10
  xor esi, esi
  jmp @LBB0_14
@LBB0_10:
  mov esi, eax
  and esi, 2147483616
  xor r8d, r8d
@LBB0_11:
  vmovups ymm0, yword ptr [rcx + 4*r8]
  vmovups ymm1, yword ptr [rcx + 4*r8 + 32]
{$ifdef fpc}
  vcvtps2ph xmm0, ymm0, 4
{$else}
  db $c4,$e3,$7d,$1d,$c0,$04
{$endif}
  vmovups ymm2, yword ptr [rcx + 4*r8 + 64]
{$ifdef fpc}
  vcvtps2ph xmm1, ymm1, 4
{$else}
  db $c4,$e3,$7d,$1d,$c9,$04
{$endif}
  vmovups ymm3, yword ptr [rcx + 4*r8 + 96]
{$ifdef fpc}
  vcvtps2ph xmm2, ymm2, 4
{$else}
  db $c4,$e3,$7d,$1d,$d2,$04
{$endif}
{$ifdef fpc}
  vcvtps2ph xmm3, ymm3, 4
{$else}
  db $c4,$e3,$7d,$1d,$db,$04
{$endif}
  vinserti128 ymm2, ymm2, xmm3, 1
  vpsrlw ymm2, ymm2, 8
  vinserti128 ymm0, ymm0, xmm1, 1
  vpsrlw ymm0, ymm0, 8
  vpackuswb ymm0, ymm0, ymm2
  vpermq ymm0, ymm0, 216
  vmovdqu yword ptr [rdx + r8], ymm0
  add r8, 32
  cmp rsi, r8
  jne @LBB0_11
  cmp esi, eax
  je @LBB0_17
  test al, 28
  je @LBB0_3
@LBB0_14:
  mov r8, rsi
  mov esi, eax
  and esi, 2147483644
@LBB0_15:
  vmovups xmm0, dqword ptr [rcx + 4*r8]
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  vpsrlw xmm0, xmm0, 8
  vpackuswb xmm0, xmm0, xmm0
  vmovd dword ptr [rdx + r8], xmm0
  add r8, 4
  cmp rsi, r8
  jne @LBB0_15
  cmp esi, eax
  jne @LBB0_3
  jmp @LBB0_17
@Exit:
end;
{$endif}

procedure PascalQuantizeF8E5M2(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  // Convert each float to FP8 E5M2 format
  PPasLLMUInt8Array(aQ)^[Index]:=ConvertFloat32ToFP8E5M2(PPasLLMFloatArray(aX)^[Index]);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64QuantizeBF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_13
  mov eax, r8d
  cmp r8d, 3
  ja @LBB0_3
  xor r8d, r8d
  jmp @LBB0_12
@LBB0_3:
  cmp r8d, 32
  jae @LBB0_5
  xor r8d, r8d
  jmp @LBB0_9
@LBB0_5:
  mov r8d, eax
  and r8d, 2147483616
  lea r9d, [rax + rax]
  and r9d, -64
  xor r10d, r10d
@LBB0_6:
  vmovdqu ymm0, yword ptr [rcx + 2*r10]
  vmovdqu ymm1, yword ptr [rcx + 2*r10 + 32]
  vmovdqu ymm2, yword ptr [rcx + 2*r10 + 64]
  vmovdqu ymm3, yword ptr [rcx + 2*r10 + 96]
  vpsrld ymm0, ymm0, 16
  vpsrld ymm1, ymm1, 16
  vpsrld ymm2, ymm2, 16
  vpsrld ymm3, ymm3, 16
  vextracti128 xmm4, ymm0, 1
  vpackusdw xmm0, xmm0, xmm4
  vextracti128 xmm4, ymm1, 1
  vpackusdw xmm1, xmm1, xmm4
  vextracti128 xmm4, ymm2, 1
  vpackusdw xmm2, xmm2, xmm4
  vextracti128 xmm4, ymm3, 1
  vpackusdw xmm3, xmm3, xmm4
  vmovdqu dqword ptr [rdx + r10], xmm0
  vmovdqu dqword ptr [rdx + r10 + 16], xmm1
  vmovdqu dqword ptr [rdx + r10 + 32], xmm2
  vmovdqu dqword ptr [rdx + r10 + 48], xmm3
  add r10, 64
  cmp r9, r10
  jne @LBB0_6
  cmp r8d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_12
@LBB0_9:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
@LBB0_10:
  vmovdqu xmm0, dqword ptr [rcx + 4*r9]
  vpsrld xmm0, xmm0, 16
  vpackusdw xmm0, xmm0, xmm0
  vmovq qword ptr [rdx + 2*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_10
  cmp r8d, eax
  je @LBB0_13
@LBB0_12:
  movzx r9d, word ptr [rcx + 4*r8 + 2]
  mov word ptr [rdx + 2*r8], r9w
  inc r8
  cmp rax, r8
  jne @LBB0_12
@LBB0_13:
  vzeroupper
end;
{$endif}

procedure PascalQuantizeBF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  // Convert each float to BFloat16 format
  PPasLLMUInt16Array(aQ)^[Index]:=ConvertFloat32ToBFloat16(PPasLLMFloatArray(aX)^[Index]);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2 and F16C
procedure AMD64QuantizeF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_13
  mov eax, r8d
  cmp r8d, 3
  ja @LBB0_3
  xor r8d, r8d
  jmp @LBB0_12
@LBB0_3:
  cmp r8d, 32
  jae @LBB0_5
  xor r8d, r8d
  jmp @LBB0_9
@LBB0_5:
  mov r8d, eax
  and r8d, 2147483616
  lea r9d, [rax + rax]
  and r9d, -64
  xor r10d, r10d
@LBB0_6:
  vmovdqu ymm0, yword ptr [rcx + 2*r10]
  vmovups ymm1, yword ptr [rcx + 2*r10 + 32]
  vmovups ymm2, yword ptr [rcx + 2*r10 + 64]
  vmovups ymm3, yword ptr [rcx + 2*r10 + 96]
  vcvtps2ph dqword ptr [rdx + r10], ymm0, 4
  vcvtps2ph dqword ptr [rdx + r10 + 16], ymm1, 4
  vcvtps2ph dqword ptr [rdx + r10 + 32], ymm2, 4
  vcvtps2ph dqword ptr [rdx + r10 + 48], ymm3, 4
  add r10, 64
  cmp r9, r10
  jne @LBB0_6
  cmp r8d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_12
@LBB0_9:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
@LBB0_10:
  vmovdqu xmm0, dqword ptr [rcx + 4*r9]
{$ifdef fpc}
  vcvtps2ph qword ptr [rdx + 2*r9], xmm0, 4
{$else}
  db $c4,$a3,$79,$1d,$04,$4a,$04
{$endif}
  add r9, 4
  cmp r8, r9
  jne @LBB0_10
  cmp r8d, eax
  je @LBB0_13
@LBB0_12:
  vmovss xmm0, dword ptr [rcx + 4*r8]
{$ifdef fpc}
  vcvtps2ph xmm0, xmm0, 4
{$else}
  db $c4,$e3,$79,$1d,$c0,$04
{$endif}
  vpextrw word ptr [rdx + 2*r8], xmm0, 0
  inc r8
  cmp rax, r8
  jne @LBB0_12
@LBB0_13:
  vzeroupper
end;
{$endif}

procedure PascalQuantizeF16(const aX,aQ:Pointer;const aCount:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  // Convert each float to Float16 format
  PPasLLMUInt16Array(aQ)^[Index]:=ConvertFloat32ToFloat16(PPasLLMFloatArray(aX)^[Index]);
 end;
end;

// Quantize the given float array into the quantized tensor
procedure TPasLLMTensor.Quantize(const aX:PPasLLMFloatArray;const aCount:TPasLLMSizeInt);
begin
 case fDataType of
  TPasLLMTensorDataType.Q40:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ40(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ40(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q40NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ40NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ40NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q41NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ41NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ41NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q42NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ42NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ42NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q43NL:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ43NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ43NL(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q80:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ80(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ80(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q3F8:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeQ3F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ3F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q6F16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    // Use the optimized AMD64 quantization function for better performance
//  AMD64QuantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
    PascalQuantizeQ6F16(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ6F16(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.Q7F8:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    // Use the optimized AMD64 quantization function for better performance
//  AMD64QuantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
    PascalQuantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeQ7F8(Pointer(@aX^[0]),Pointer(@PPasLLMInt8Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F8_E4M3:begin
   PascalQuantizeF8E4M3(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
  end;  
  TPasLLMTensorDataType.F8_E5M2:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeF8E5M2(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeF8E5M2(Pointer(@aX^[0]),Pointer(@PPasLLMUInt8Array(fValues)^[0]),aCount);
   end;   
  end;
  TPasLLMTensorDataType.BF16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeBF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeBF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F16:begin
  {$if defined(cpuamd64)}
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    // Use the optimized AMD64 quantization function for better performance
    AMD64QuantizeF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end else{$ifend}begin
    PascalQuantizeF16(Pointer(@aX^[0]),Pointer(@PPasLLMUInt16Array(fValues)^[0]),aCount);
   end;
  end;
  TPasLLMTensorDataType.F32:begin
   Move(aX^[0],fValues^,aCount*SizeOf(TPasLLMFloat));
  end;
  else begin
  end;
 end;
end;

{ TPasLLMModelWeights }

constructor TPasLLMModelWeights.Create(const aModel:TPasLLMModel);
begin
 inherited Create;
 fModel:=aModel; // Store the reference to the PasLLM instance for memory mapping
 fQTokens:=nil; // Initialize the quantized token tensor to nil
 fTokenEmbeddingTable:=nil; // Initialize the dequantized token embedding table to nil
 fRMSAttentionWeights:=nil; // Initialize the rmsnorm weights for attention to nil
 fRMSLayerNormalizationWeights:=nil; // Initialize the rmsnorm weights for ffn to nil
 fRMSQNormalizationWeights:=nil;
 fRMSKNormalizationWeights:=nil;
 fRMSPreFeedForwardLayerNormWeights:=nil;
 fRMSPostFeedForwardLayerNormWeights:=nil;
 fRMSFeedForwardLayerNormWeights:=nil;
 fWQ:=nil; // Initialize the query weights to nil
 fWK:=nil; // Initialize the key weights to nil
 fWV:=nil; // Initialize the value weights to nil
 fWO:=nil; // Initialize the output weights to nil
 fWQBias:=nil;
 fWKBias:=nil;
 fWVBias:=nil;
 fActivationFunctionAlphaN:=nil;
 fActivationFunctionAlphaP:=nil;
 fActivationFunctionBeta:=nil;
 fActivationFunctionEpsilon:=nil;
 fMixtureOfExpertGate:=nil;
 fW1:=nil; // Initialize the first ffn weights to nil
 fW2:=nil; // Initialize the second ffn weights to nil
 fW3:=nil; // Initialize the third ffn weights to nil
 fRMSFinalWeights:=nil; // Initialize the final rmsnorm weights to nil
 fWCLS:=nil; // Initialize the classifier weights to nil
end;

destructor TPasLLMModelWeights.Destroy;
var Index:TPasLLMSizeInt;
begin

 // Free the classifier weights if they were allocated and not shared with fQTokens
 if fWCLS<>fQTokens then begin
  FreeAndNil(fWCLS);
 end;

 FreeAndNil(fQTokens); // Free the quantized token tensor if it was allocated

 if assigned(fTokenEmbeddingTable) then begin
  FreeMem(fTokenEmbeddingTable); // Free the dequantized token embedding table if it was allocated
  fTokenEmbeddingTable:=nil; // Set the pointer to nil
 end;

 fRMSAttentionWeights:=nil; // Set the pointer to nil

 fRMSLayerNormalizationWeights:=nil; // Set the pointer to nil

 fRMSQNormalizationWeights:=nil;

 fRMSKNormalizationWeights:=nil;

 fRMSPreFeedForwardLayerNormWeights:=nil;
 fRMSPostFeedForwardLayerNormWeights:=nil;
 fRMSFeedForwardLayerNormWeights:=nil;

 DestroyQuantizedTensors(fWQ); // Free the query weights if they were allocated
 DestroyQuantizedTensors(fWK); // Free the key weights if they were allocated
 DestroyQuantizedTensors(fWV); // Free the value weights if they were allocated
 DestroyQuantizedTensors(fWO); // Free the output weights if they were allocated

 fWQBias:=nil;
 fWKBias:=nil;
 fWVBias:=nil;

 fActivationFunctionAlphaN:=nil;
 fActivationFunctionAlphaP:=nil;
 fActivationFunctionBeta:=nil;
 fActivationFunctionEpsilon:=nil;

 DestroyQuantizedTensors(fMixtureOfExpertGate);

 for Index:=0 to length(fW1)-1 do begin
  DestroyQuantizedTensors(fW1[Index]); // Free the first ffn weights if they were allocated
 end;
 fW1:=nil;

 for Index:=0 to length(fW2)-1 do begin
  DestroyQuantizedTensors(fW2[Index]); // Free the second ffn weights if they were allocated
 end;
 fW2:=nil;

 for Index:=0 to length(fW3)-1 do begin
  DestroyQuantizedTensors(fW3[Index]); // Free the third ffn weights if they were allocated
 end;
 fW3:=nil;

{if assigned(fRMSFinalWeights) then begin
  FreeMem(fRMSFinalWeights); // Free the final rmsnorm weights if they were allocated
  fRMSFinalWeights:=nil; // Set the pointer to nil
 end;}

 inherited Destroy;

end;

procedure TPasLLMModelWeights.DestroyQuantizedTensors(var aQ:TPasLLMTensors);
var Index:TPasLLMSizeInt;
begin
 if length(aQ)>0 then begin
  for Index:=0 to length(aQ)-1 do begin
   FreeAndNil(aQ[Index]); // Free each quantized tensor in the array
  end;
  aQ:=nil; // Set the array to nil
 end;
end;

{ TPasLLMRunState }

constructor TPasLLMRunState.Create(const aModel:TPasLLMModel);
var Index,QDim,KVDim,Dim,XDim:TPasLLMSizeInt;
    TensorDataType:TPasLLMTensorDataType;
begin

 inherited Create;

 fModel:=aModel;
 fPasLLM:=fModel.fPasLLM;

 case fModel.fConfiguration.fDataType of
  TPasLLMTensorDataType.Q3F8,
  TPasLLMTensorDataType.F8_E5M2:begin
   if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
    TensorDataType:=TPasLLMTensorDataType.F8_E5M2;
   end else begin
    TensorDataType:=TPasLLMTensorDataType.Q80;
   end;
  end;
  else begin
   TensorDataType:=TPasLLMTensorDataType.Q80;
  end;
 end;

 QDim:=fModel.Configuration.fHeadDim*fModel.fConfiguration.fCountQueryHeads;
 KVDim:=fModel.Configuration.fHeadDim*fModel.fConfiguration.fCountKeyValueHeads;
 Dim:=fModel.fConfiguration.fDim;
 XDim:=Max(QDim,Dim);

 if assigned(fPasLLM.fPasMPInstance) then begin
  fCountExpertBuffers:=Max(1,fModel.Configuration.fCountActiveExperts);
 end else begin
  fCountExpertBuffers:=1;
 end;

 fX:=nil; // initialize to nil
 fXB:=nil; // initialize to nil
 fXB2:=nil; // initialize to nil
 fHB:=nil; // initialize to nil
 fHB2:=nil; // initialize to nil
 fHB3:=nil; // initialize to nil
 fEB:=nil;
 fXQ:=nil; // initialize to nil
 fHQ:=nil; // initialize to nil
 fQ:=nil; // initialize to nil
 fRoPECache:=nil;
 fStreamingLLMRoPECache:=nil;
 fAtt:=nil; // initialize to nil
 fLogits:=nil; // initialize to nil
 fKeyCache:=nil; // initialize to nil
 fValueCache:=nil; // initialize to nil
 fMixtureOfExpertWeights:=nil;
 fMixtureOfExpertWeightIndices:=nil;

 SetLength(fX,XDim);
 SetLength(fXB,XDim);
 SetLength(fXB2,XDim);
 SetLength(fHB,fCountExpertBuffers,Max(fModel.fConfiguration.fHiddenDim,fModel.fConfiguration.fExpertHiddenDim));
 SetLength(fHB2,fCountExpertBuffers,Max(fModel.fConfiguration.fHiddenDim,fModel.fConfiguration.fExpertHiddenDim));
 SetLength(fHB3,fCountExpertBuffers,XDim);
 SetLength(fEB,fModel.fConfiguration.fCountExperts+(fModel.fConfiguration.fCountActiveExperts*2));

 fXQ:=TPasLLMTensor.Create(XDim,TensorDataType);

 SetLength(fHQ,fCountExpertBuffers);
 for Index:=0 to fCountExpertBuffers-1 do begin
  fHQ[Index]:=TPasLLMTensor.Create(Max(fModel.fConfiguration.fHiddenDim,fModel.fConfiguration.fExpertHiddenDim),TensorDataType);
 end;

 SetLength(fQ,QDim);

 SetLength(fRoPECache,fModel.fConfiguration.fHeadDim);
 SetLength(fStreamingLLMRoPECache,fModel.fConfiguration.fHeadDim);

 SetLength(fAtt,fModel.fConfiguration.fCountQueryHeads*fModel.fConfiguration.fMaximumSequenceLength);
 SetLength(fLogits,fModel.fConfiguration.fVocabularySize);

 SetLength(fKeyCache,fModel.fConfiguration.fCountLayers*fModel.fConfiguration.fMaximumSequenceLength*KVDim);
 FillChar(fKeyCache[0],Length(fKeyCache)*SizeOf(TPasLLMFloat),#0);

 SetLength(fValueCache,fModel.fConfiguration.fCountLayers*fModel.fConfiguration.fMaximumSequenceLength*KVDim);
 FillChar(fValueCache[0],Length(fValueCache)*SizeOf(TPasLLMFloat),#0);

 SetLength(fMixtureOfExpertWeights,fModel.fConfiguration.fCountExperts);
 SetLength(fMixtureOfExpertWeightIndices,fModel.fConfiguration.fCountExperts);

end;

destructor TPasLLMRunState.Destroy;
var Index:TPasLLMSizeInt;
begin
 fX:=nil; // free the activation buffer
 fXB:=nil; // free the residual branch buffer
 fXB2:=nil; // free the additional buffer
 fHB:=nil; // free the hidden dimension buffer
 fHB2:=nil; // free the additional hidden dimension buffer
 fHB3:=nil; // free the additional hidden dimension buffer
 fEB:=nil;
 FreeAndNil(fXQ); // free the quantized fX buffer
 for Index:=0 to length(fHQ)-1 do begin
  FreeAndNil(fHQ[Index]); // free the quantized fHB buffer
 end;
 fHQ:=nil;
 fQ:=nil; // free the query buffer
 fRoPECache:=nil; // free the RoPE cache
 fStreamingLLMRoPECache:=nil;
 fAtt:=nil; // free the attention buffer
 fLogits:=nil; // free the fLogits buffer
 fKeyCache:=nil; // free the key cache buffer
 fValueCache:=nil; // free the value cache buffer
 fMixtureOfExpertWeights:=nil;
 fMixtureOfExpertWeightIndices:=nil;
 inherited Destroy;
end;

procedure TPasLLMRunState.Reset;
begin
 FillChar(fKeyCache[0],Length(fKeyCache)*SizeOf(TPasLLMFloat),#0);
 FillChar(fValueCache[0],Length(fValueCache)*SizeOf(TPasLLMFloat),#0);
end;

{ TPasLLMModel }

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64RMSNorm(const aO,aX,aWeight:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;aNormEps:TPasLLMFloat); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=$3f800000;
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r9d, r9d
  jle @LBB0_26
  push rsi
  sub rsp, 48
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  vmovss xmm0, dword ptr [rsp + 96]
  mov eax, r9d
  cmp r9d, 3
  ja @LBB0_3
  vxorps xmm1, xmm1, xmm1
  xor r10d, r10d
  jmp @LBB0_12
@LBB0_3:
  cmp r9d, 32
  jae @LBB0_5
  vxorps xmm1, xmm1, xmm1
  xor r10d, r10d
  jmp @LBB0_9
@LBB0_5:
  mov r10d, eax
  and r10d, 2147483616
  mov r11d, eax
  shr r11d, 5
  and r11d, 67108863
  shl r11, 7
  vxorps xmm1, xmm1, xmm1
  xor esi, esi
  vxorps xmm2, xmm2, xmm2
  vxorps xmm3, xmm3, xmm3
  vxorps xmm4, xmm4, xmm4
@LBB0_6:
  vmovups ymm5, yword ptr [rdx + rsi]
  vmovups ymm6, yword ptr [rdx + rsi + 32]
  vmovups ymm7, yword ptr [rdx + rsi + 64]
  vmovups ymm8, yword ptr [rdx + rsi + 96]
  vmulps ymm5, ymm5, ymm5
  vaddps ymm1, ymm5, ymm1
  vmulps ymm5, ymm6, ymm6
  vaddps ymm2, ymm5, ymm2
  vmulps ymm5, ymm7, ymm7
  vaddps ymm3, ymm5, ymm3
  vmulps ymm5, ymm8, ymm8
  vaddps ymm4, ymm5, ymm4
  sub rsi, -128
  cmp r11, rsi
  jne @LBB0_6
  vaddps ymm1, ymm2, ymm1
  vaddps ymm1, ymm3, ymm1
  vaddps ymm1, ymm4, ymm1
  vextractf128 xmm2, ymm1, 1
  vaddps xmm1, xmm1, xmm2
  vshufpd xmm2, xmm1, xmm1, 1
  vaddps xmm1, xmm1, xmm2
  vmovshdup xmm2, xmm1
  vaddss xmm1, xmm1, xmm2
  cmp r10d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_12
@LBB0_9:
  mov r11, r10
  mov r10d, eax
  and r10d, 2147483644
  vxorps xmm2, xmm2, xmm2
  vblendps xmm1, xmm2, xmm1, 1
@LBB0_10:
  vmovups xmm2, dqword ptr [rdx + 4*r11]
  vmulps xmm2, xmm2, xmm2
  vaddps xmm1, xmm2, xmm1
  add r11, 4
  cmp r10, r11
  jne @LBB0_10
  vshufpd xmm2, xmm1, xmm1, 1
  vaddps xmm1, xmm1, xmm2
  vmovshdup xmm2, xmm1
  vaddss xmm1, xmm1, xmm2
  cmp r10d, eax
  je @LBB0_13
@LBB0_12:
  vmovss xmm2, dword ptr [rdx + 4*r10]
  vmulss xmm2, xmm2, xmm2
  vaddss xmm1, xmm2, xmm1
  inc r10
  cmp rax, r10
  jne @LBB0_12
@LBB0_13:
  vcvtsi2ss xmm2, xmm15, r9d
  vdivss xmm1, xmm1, xmm2
  vaddss xmm0, xmm1, xmm0
  vsqrtss xmm0, xmm0, xmm0
  cmp r9d, 8
  jb @LBB0_14
  mov r9, rcx
  sub r9, r8
  cmp r9, 32
  setb r9b
  mov r10, rcx
  sub r10, rdx
  cmp r10, 32
  setb r10b
  or r10b, r9b
  je @LBB0_17
@LBB0_14:
  xor r9d, r9d
@LBB0_20:
  mov r10, r9
  test al, 1
  je @LBB0_22
  vmovss xmm1, dword ptr [rdx + 4*r9]
  vmulss xmm1, xmm1, dword ptr [r8 + 4*r9]
  vdivss xmm1, xmm1, xmm0
  vmovss dword ptr [rcx + 4*r9], xmm1
  mov r10, r9
  or r10, 1
@LBB0_22:
  lea r11, [rax - 1]
  cmp r9, r11
  je @LBB0_25
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm0, xmm1, xmm0
@LBB0_24:
  vmovss xmm1, dword ptr [rdx + 4*r10]
  vmulss xmm1, xmm1, dword ptr [r8 + 4*r10]
  vmulss xmm1, xmm1, xmm0
  vmovss dword ptr [rcx + 4*r10], xmm1
  vmovss xmm1, dword ptr [rdx + 4*r10 + 4]
  vmulss xmm1, xmm1, dword ptr [r8 + 4*r10 + 4]
  vmulss xmm1, xmm1, xmm0
  vmovss dword ptr [rcx + 4*r10 + 4], xmm1
  add r10, 2
  cmp rax, r10
  jne @LBB0_24
  jmp @LBB0_25
@LBB0_17:
  mov r9d, eax
  and r9d, 2147483640
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm1, xmm1, xmm0
  vbroadcastss ymm1, xmm1
  xor r10d, r10d
@LBB0_18:
  vmovups ymm2, yword ptr [rdx + 4*r10]
  vmulps ymm2, ymm2, yword ptr [r8 + 4*r10]
  vmulps ymm2, ymm2, ymm1
  vmovups yword ptr [rcx + 4*r10], ymm2
  add r10, 8
  cmp r9, r10
  jne @LBB0_18
  cmp r9d, eax
  jne @LBB0_20
@LBB0_25:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 48
  pop rsi
@LBB0_26:
  vzeroupper
end;
{$endif}

procedure PascalRMSNorm(const aO,aX,aWeight:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aNormEps:TPasLLMFloat);
var Index:TPasLLMSizeInt;
    SumSquares:TPasLLMFloat;
begin
 SumSquares:=0.0; // Initialize the sum of squares
 for Index:=0 to aSize-1 do begin
  SumSquares:=SumSquares+sqr(aX^[Index]); // Calculate the sum of squares
 end;
 SumSquares:=1.0/sqrt((SumSquares/aSize)+aNormEps); // Normalize the sum of squares and add a small epsilon to avoid division by zero
 for Index:=0 to aSize-1 do begin
  aO^[Index]:=aWeight^[Index]*(SumSquares*aX^[Index]); // Normalize and scale the output
 end;
end;

procedure RMSNorm(const aO,aX,aWeight:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aNormEps:TPasLLMFloat);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64RMSNorm(aO,aX,aWeight,aSize,aNormEps);
 end else{$ifend}begin
  PascalRMSNorm(aO,aX,aWeight,aSize,aNormEps);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64RMSNormNoWeights(const aO,aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;aNormEps:TPasLLMFloat); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=$3f800000;
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_31
  sub rsp, 56
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  mov eax, r8d
  cmp r8d, 3
  ja @LBB0_4
  vxorps xmm0, xmm0, xmm0
  xor r9d, r9d
  jmp @LBB0_3
@LBB0_4:
  cmp r8d, 32
  jae @LBB0_6
  vxorps xmm0, xmm0, xmm0
  xor r9d, r9d
  jmp @LBB0_10
@LBB0_6:
  mov r9d, eax
  and r9d, 2147483616
  mov r10d, eax
  shr r10d, 5
  and r10d, 67108863
  shl r10, 7
  vxorps xmm0, xmm0, xmm0
  xor r11d, r11d
  vxorps xmm1, xmm1, xmm1
  vxorps xmm2, xmm2, xmm2
  vxorps xmm4, xmm4, xmm4
@LBB0_7:
  vmovups ymm5, yword ptr [rdx + r11]
  vmovups ymm6, yword ptr [rdx + r11 + 32]
  vmovups ymm7, yword ptr [rdx + r11 + 64]
  vmovups ymm8, yword ptr [rdx + r11 + 96]
  vfmadd231ps ymm0, ymm5, ymm5
  vfmadd231ps ymm1, ymm6, ymm6
  vfmadd231ps ymm2, ymm7, ymm7
  vfmadd231ps ymm4, ymm8, ymm8
  sub r11, -128
  cmp r10, r11
  jne @LBB0_7
  vaddps ymm0, ymm1, ymm0
  vaddps ymm1, ymm4, ymm2
  vaddps ymm0, ymm1, ymm0
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  cmp r9d, eax
  je @LBB0_13
  test al, 28
  je @LBB0_3
@LBB0_10:
  mov r10, r9
  mov r9d, eax
  and r9d, 2147483644
  vxorps xmm1, xmm1, xmm1
  vblendps xmm0, xmm1, xmm0, 1
@LBB0_11:
  vmovups xmm1, dqword ptr [rdx + 4*r10]
  vfmadd231ps xmm0, xmm1, xmm1
  add r10, 4
  cmp r9, r10
  jne @LBB0_11
  vshufpd xmm1, xmm0, xmm0, 1
  vaddps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vaddss xmm0, xmm0, xmm1
  cmp r9d, eax
  je @LBB0_13
@LBB0_3:
  vmovss xmm1, dword ptr [rdx + 4*r9]
  vfmadd231ss xmm0, xmm1, xmm1
  inc r9
  cmp rax, r9
  jne @LBB0_3
@LBB0_13:
  vcvtsi2ss xmm1, xmm15, r8d
  vdivss xmm0, xmm0, xmm1
  vaddss xmm0, xmm0, xmm3
  vsqrtss xmm0, xmm0, xmm0
  cmp r8d, 4
  setae r9b
  mov r10, rcx
  sub r10, rdx
  cmp r10, 127
  seta r10b
  test r9b, r10b
  jne @LBB0_21
  xor r8d, r8d
  jmp @LBB0_15
@LBB0_21:
  cmp r8d, 32
  jae @LBB0_23
  xor r8d, r8d
  jmp @LBB0_27
@LBB0_23:
  mov r8d, eax
  and r8d, 2147483616
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm1, xmm1, xmm0
  vbroadcastss ymm1, xmm1
  xor r9d, r9d
@LBB0_24:
  vmulps ymm2, ymm1, yword ptr [rdx + 4*r9]
  vmulps ymm3, ymm1, yword ptr [rdx + 4*r9 + 32]
  vmulps ymm4, ymm1, yword ptr [rdx + 4*r9 + 64]
  vmulps ymm5, ymm1, yword ptr [rdx + 4*r9 + 96]
  vmovups yword ptr [rcx + 4*r9], ymm2
  vmovups yword ptr [rcx + 4*r9 + 32], ymm3
  vmovups yword ptr [rcx + 4*r9 + 64], ymm4
  vmovups yword ptr [rcx + 4*r9 + 96], ymm5
  add r9, 32
  cmp r8, r9
  jne @LBB0_24
  cmp r8d, eax
  je @LBB0_30
  test al, 28
  je @LBB0_15
@LBB0_27:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm1, xmm1, xmm0
  vbroadcastss xmm1, xmm1
@LBB0_28:
  vmulps xmm2, xmm1, dqword ptr [rdx + 4*r9]
  vmovups dqword ptr [rcx + 4*r9], xmm2
  add r9, 4
  cmp r8, r9
  jne @LBB0_28
  cmp r8d, eax
  je @LBB0_30
@LBB0_15:
  mov r10, rax
  mov r9, r8
  and r10, 3
  je @LBB0_18
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm1, xmm1, xmm0
  mov r9, r8
@LBB0_17:
  vmulss xmm2, xmm1, dword ptr [rdx + 4*r9]
  vmovss dword ptr [rcx + 4*r9], xmm2
  inc r9
  dec r10
  jne @LBB0_17
@LBB0_18:
  sub r8, rax
  cmp r8, -4
  ja @LBB0_30
  vmovss xmm1, dword ptr [rip + LCPI0_0]
  vdivss xmm0, xmm1, xmm0
@LBB0_20:
  vmulss xmm1, xmm0, dword ptr [rdx + 4*r9]
  vmovss dword ptr [rcx + 4*r9], xmm1
  vmulss xmm1, xmm0, dword ptr [rdx + 4*r9 + 4]
  vmovss dword ptr [rcx + 4*r9 + 4], xmm1
  vmulss xmm1, xmm0, dword ptr [rdx + 4*r9 + 8]
  vmovss dword ptr [rcx + 4*r9 + 8], xmm1
  vmulss xmm1, xmm0, dword ptr [rdx + 4*r9 + 12]
  vmovss dword ptr [rcx + 4*r9 + 12], xmm1
  add r9, 4
  cmp rax, r9
  jne @LBB0_20
@LBB0_30:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 56
@LBB0_31:
  vzeroupper
end;
{$endif}

procedure PascalRMSNormNoWeights(const aO,aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aNormEps:TPasLLMFloat);
var Index:TPasLLMSizeInt;
    SumSquares:TPasLLMFloat;
begin
 SumSquares:=0.0; // Initialize the sum of squares
 for Index:=0 to aSize-1 do begin
  SumSquares:=SumSquares+sqr(aX^[Index]); // Calculate the sum of squares
 end;
 SumSquares:=1.0/sqrt((SumSquares/aSize)+aNormEps); // Normalize the sum of squares and add a small epsilon to avoid division by zero
 for Index:=0 to aSize-1 do begin
  aO^[Index]:=SumSquares*aX^[Index]; // Normalize and scale the output
 end;
end;

procedure RMSNormNoWeights(const aO,aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aNormEps:TPasLLMFloat);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64RMSNormNoWeights(aO,aX,aSize,aNormEps);
 end else{$ifend}begin
  PascalRMSNormNoWeights(aO,aX,aSize,aNormEps);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64ClipFloats(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aMin,aMax:TPasLLMFloat); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test edx, edx
  jle @LBB0_16
  mov eax, edx
  cmp edx, 7
  ja @LBB0_3
  xor edx, edx
  jmp @LBB0_12
@LBB0_3:
  cmp edx, 32
  jae @LBB0_5
  xor edx, edx
  jmp @LBB0_9
@LBB0_5:
  sub rsp, 104
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  mov edx, eax
  and edx, 2147483616
  vbroadcastss ymm0, xmm2
  vbroadcastss ymm1, xmm3
  mov r8d, eax
  shr r8d, 5
  and r8d, 67108863
  shl r8, 7
  lea r9, [rcx + 96]
  xor r10d, r10d
@LBB0_6:
  vmovups ymm4, yword ptr [r9 + r10 - 96]
  vmovups ymm5, yword ptr [r9 + r10 - 64]
  vmovups ymm6, yword ptr [r9 + r10 - 32]
  vmovups ymm7, yword ptr [r9 + r10]
  vcmpltps ymm8, ymm4, ymm0
  vcmpltps ymm9, ymm5, ymm0
  vcmpltps ymm10, ymm6, ymm0
  vcmpltps ymm11, ymm7, ymm0
  vcmpltps ymm4, ymm1, ymm4
  vcmpltps ymm5, ymm1, ymm5
  vcmpltps ymm6, ymm1, ymm6
  vcmpltps ymm7, ymm1, ymm7
  vorps ymm4, ymm8, ymm4
  vorps ymm5, ymm9, ymm5
  vorps ymm6, ymm10, ymm6
  vorps ymm7, ymm11, ymm7
  vblendvps ymm8, ymm1, ymm0, ymm8
  vblendvps ymm9, ymm1, ymm0, ymm9
  vblendvps ymm10, ymm1, ymm0, ymm10
  vblendvps ymm11, ymm1, ymm0, ymm11
  vmaskmovps yword ptr [r9 + r10 - 96], ymm4, ymm8
  vmaskmovps yword ptr [r9 + r10 - 64], ymm5, ymm9
  vmaskmovps yword ptr [r9 + r10 - 32], ymm6, ymm10
  vmaskmovps yword ptr [r9 + r10], ymm7, ymm11
  sub r10, -128
  cmp r8, r10
  jne @LBB0_6
  cmp edx, eax
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  lea rsp, [rsp + 104]
  je @LBB0_16
  test al, 24
  je @LBB0_12
@LBB0_9:
  mov r8, rdx
  mov edx, eax
  and edx, 2147483640
  vbroadcastss ymm0, xmm2
  vbroadcastss ymm1, xmm3
@LBB0_10:
  vmovups ymm4, yword ptr [rcx + 4*r8]
  vcmpltps ymm5, ymm4, ymm0
  vcmpltps ymm4, ymm1, ymm4
  vorps ymm4, ymm5, ymm4
  vblendvps ymm5, ymm1, ymm0, ymm5
  vmaskmovps yword ptr [rcx + 4*r8], ymm4, ymm5
  add r8, 8
  cmp rdx, r8
  jne @LBB0_10
  cmp edx, eax
  jne @LBB0_12
@LBB0_16:
  vzeroupper
  jmp @Exit
@LBB0_14:
  vmovss dword ptr [rcx + 4*rdx], xmm0
@LBB0_15:
  inc rdx
  cmp rax, rdx
  je @LBB0_16
@LBB0_12:
  vmovss xmm1, dword ptr [rcx + 4*rdx]
  vucomiss xmm2, xmm1
  vmovaps xmm0, xmm2
  ja @LBB0_14
  vucomiss xmm1, xmm3
  vmovaps xmm0, xmm3
  ja @LBB0_14
  jmp @LBB0_15
 @Exit:
end;
{$endif}

procedure PascalClipFloats(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aMin,aMax:TPasLLMFloat);
var Index:TPasLLMSizeInt;
    Value:TPasLLMFloat;
begin
 for Index:=0 to aSize-1 do begin
  Value:=aX^[Index]; // Get the current value
  if Value<aMin then begin
   aX^[Index]:=aMin; // Clip to minimum if below threshold
  end else if Value>aMax then begin
   aX^[Index]:=aMax; // Clip to maximum if above threshold
  end;
 end;
end;

procedure ClipFloats(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aMin,aMax:TPasLLMFloat); overload;
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64ClipFloats(aX,aSize,aMin,aMax);
 end else{$ifend}begin
  PascalClipFloats(aX,aSize,aMin,aMax);
 end;
end;

procedure ClipFloats(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aClipValue:TPasLLMFloat); overload;
begin
 ClipFloats(aX,aSize,-aClipValue,aClipValue); // Call the overloaded method with min and max values
end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64AddFloats(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_18
  mov eax, r8d
  cmp r8d, 3
  jbe @LBB0_2
  lea r9, [rcx + 4*rax]
  lea r10, [rdx + 4*rax]
  cmp rcx, r10
  setb r10b
  cmp rdx, r9
  setb r9b
  test r10b, r9b
  je @LBB0_9
@LBB0_2:
  xor r8d, r8d
@LBB0_3:
  mov r10, rax
  mov r9, r8
  and r10, 3
  je @LBB0_6
  mov r9, r8
@LBB0_5:
  vmovss xmm0, dword ptr [rcx + 4*r9]
  vaddss xmm0, xmm0, dword ptr [rdx + 4*r9]
  vmovss dword ptr [rcx + 4*r9], xmm0
  inc r9
  dec r10
  jne @LBB0_5
@LBB0_6:
  sub r8, rax
  cmp r8, -4
  ja @LBB0_18
@LBB0_7:
  vmovss xmm0, dword ptr [rcx + 4*r9]
  vaddss xmm0, xmm0, dword ptr [rdx + 4*r9]
  vmovss xmm1, dword ptr [rcx + 4*r9 + 4]
  vmovss dword ptr [rcx + 4*r9], xmm0
  vaddss xmm0, xmm1, dword ptr [rdx + 4*r9 + 4]
  vmovss dword ptr [rcx + 4*r9 + 4], xmm0
  vmovss xmm0, dword ptr [rcx + 4*r9 + 8]
  vaddss xmm0, xmm0, dword ptr [rdx + 4*r9 + 8]
  vmovss dword ptr [rcx + 4*r9 + 8], xmm0
  vmovss xmm0, dword ptr [rcx + 4*r9 + 12]
  vaddss xmm0, xmm0, dword ptr [rdx + 4*r9 + 12]
  vmovss dword ptr [rcx + 4*r9 + 12], xmm0
  add r9, 4
  cmp rax, r9
  jne @LBB0_7
@LBB0_18:
  vzeroupper
  jmp @Exit
@LBB0_9:
  cmp r8d, 32
  jae @LBB0_11
  xor r8d, r8d
  jmp @LBB0_15
@LBB0_11:
  mov r8d, eax
  and r8d, 2147483616
  mov r9d, eax
  shr r9d, 5
  and r9d, 67108863
  shl r9, 7
  xor r10d, r10d
@LBB0_12:
  vmovups ymm0, yword ptr [rcx + r10]
  vmovups ymm1, yword ptr [rcx + r10 + 32]
  vmovups ymm2, yword ptr [rcx + r10 + 64]
  vmovups ymm3, yword ptr [rcx + r10 + 96]
  vaddps ymm0, ymm0, yword ptr [rdx + r10]
  vaddps ymm1, ymm1, yword ptr [rdx + r10 + 32]
  vaddps ymm2, ymm2, yword ptr [rdx + r10 + 64]
  vaddps ymm3, ymm3, yword ptr [rdx + r10 + 96]
  vmovups yword ptr [rcx + r10], ymm0
  vmovups yword ptr [rcx + r10 + 32], ymm1
  vmovups yword ptr [rcx + r10 + 64], ymm2
  vmovups yword ptr [rcx + r10 + 96], ymm3
  sub r10, -128
  cmp r9, r10
  jne @LBB0_12
  cmp r8d, eax
  je @LBB0_18
  test al, 28
  je @LBB0_3
@LBB0_15:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
@LBB0_16:
  vmovups xmm0, dqword ptr [rcx + 4*r9]
  vaddps xmm0, xmm0, dqword ptr [rdx + 4*r9]
  vmovups dqword ptr [rcx + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_16
  cmp r8d, eax
  jne @LBB0_3
  jmp @LBB0_18
@Exit:
end;
{$endif}

procedure PascalAddFloats(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aSize-1 do begin
  aX^[Index]:=aX^[Index]+aY^[Index]; // Add the values from aX to aY
 end;
end;

procedure AddFloats(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64AddFloats(aX,aY,aSize);
 end else{$ifend}begin
  PascalAddFloats(aX,aY,aSize);
 end;
end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64AddFloatsWithFactor(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aScale:TPasLLMFloat); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB1_17
  mov eax, r8d
  cmp r8d, 3
  jbe @LBB1_2
  lea r9, [rcx + 4*rax]
  lea r10, [rdx + 4*rax]
  cmp rcx, r10
  setb r10b
  cmp rdx, r9
  setb r9b
  test r10b, r9b
  je @LBB1_8
@LBB1_2:
  xor r8d, r8d
@LBB1_3:
  mov r9, r8
  test al, 1
  je @LBB1_5
  vmulss xmm0, xmm3, dword ptr [rdx + 4*r8]
  vaddss xmm0, xmm0, dword ptr [rcx + 4*r8]
  vmovss dword ptr [rcx + 4*r8], xmm0
  mov r9, r8
  or r9, 1
@LBB1_5:
  lea r10, [rax - 1]
  cmp r8, r10
  je @LBB1_17
@LBB1_6:
  vmulss xmm0, xmm3, dword ptr [rdx + 4*r9]
  vaddss xmm0, xmm0, dword ptr [rcx + 4*r9]
  vmovss dword ptr [rcx + 4*r9], xmm0
  vmulss xmm0, xmm3, dword ptr [rdx + 4*r9 + 4]
  vaddss xmm0, xmm0, dword ptr [rcx + 4*r9 + 4]
  vmovss dword ptr [rcx + 4*r9 + 4], xmm0
  add r9, 2
  cmp rax, r9
  jne @LBB1_6
@LBB1_17:
  vzeroupper
  jmp @Exit
@LBB1_8:
  cmp r8d, 32
  jae @LBB1_10
  xor r8d, r8d
  jmp @LBB1_14
@LBB1_10:
  mov r8d, eax
  and r8d, 2147483616
  vbroadcastss ymm0, xmm3
  mov r9d, eax
  shr r9d, 5
  and r9d, 67108863
  shl r9, 7
  xor r10d, r10d
@LBB1_11:
  vmulps ymm1, ymm0, yword ptr [rdx + r10]
  vmulps ymm2, ymm0, yword ptr [rdx + r10 + 32]
  vmulps ymm4, ymm0, yword ptr [rdx + r10 + 64]
  vmulps ymm5, ymm0, yword ptr [rdx + r10 + 96]
  vaddps ymm1, ymm1, yword ptr [rcx + r10]
  vaddps ymm2, ymm2, yword ptr [rcx + r10 + 32]
  vaddps ymm4, ymm4, yword ptr [rcx + r10 + 64]
  vaddps ymm5, ymm5, yword ptr [rcx + r10 + 96]
  vmovups yword ptr [rcx + r10], ymm1
  vmovups yword ptr [rcx + r10 + 32], ymm2
  vmovups yword ptr [rcx + r10 + 64], ymm4
  vmovups yword ptr [rcx + r10 + 96], ymm5
  sub r10, -128
  cmp r9, r10
  jne @LBB1_11
  cmp r8d, eax
  je @LBB1_17
  test al, 28
  je @LBB1_3
@LBB1_14:
  mov r9, r8
  mov r8d, eax
  and r8d, 2147483644
  vbroadcastss xmm0, xmm3
@LBB1_15:
  vmulps xmm1, xmm0, dqword ptr [rdx + 4*r9]
  vaddps xmm1, xmm1, dqword ptr [rcx + 4*r9]
  vmovups dqword ptr [rcx + 4*r9], xmm1
  add r9, 4
  cmp r8, r9
  jne @LBB1_15
  cmp r8d, eax
  jne @LBB1_3
  jmp @LBB1_17
@Exit:
end;
{$endif}

procedure PascalAddFloatsWithFactor(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aScale:TPasLLMFloat);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aSize-1 do begin
  aX^[Index]:=aX^[Index]+(aY^[Index]*aScale); // Add the scaled values from aY to aX
 end;
end;

procedure AddFloatsWithFactor(const aX,aY:PPasLLMFloatArray;const aSize:TPasLLMSizeInt;const aScale:TPasLLMFloat);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64AddFloatsWithFactor(aX,aY,aSize,aScale);
 end else{$ifend}begin
  PascalAddFloatsWithFactor(aX,aY,aSize,aScale);
 end;
end;

{$ifdef cpuamd64}
function AMD64Exp(f:TPasLLMFloat):TPasLLMFloat; {$ifdef fpc}ms_abi_default;{$endif}
begin
 result:=Exp(f);
end;

// Needs AVX2
procedure AMD64SoftMax(const aX:PPasLLMFloatArray;const aSize:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI1_0:TPasLLMUInt32=$3f800000;
asm
{$ifndef fpc}
 .noframe
{$endif}
  push r14
  push rsi
  push rdi
  push rbx
  sub rsp, 72
  vmovaps dqword ptr [rsp + 48], xmm7
  vmovaps dqword ptr [rsp + 32], xmm6
  mov edi, edx
  mov rsi, rcx
  vmovss xmm7, dword ptr [rcx]
  mov ebx, edx
  cmp edx, 2
  jl @LBB1_13
  mov edx, 1
  cmp edi, 4
  jbe @LBB1_7
  lea rax, [rbx - 1]
  cmp edi, 33
  jae @LBB1_8
  xor ecx, ecx
  jmp @LBB1_4
@LBB1_13:
  cmp edi, 1
  je @LBB1_14
  jmp @LBB1_29
@LBB1_8:
  mov rcx, rax
  and rcx, -32
  vbroadcastss ymm0, xmm7
  xor edx, edx
  vmovaps ymm1, ymm0
  vmovaps ymm2, ymm0
  vmovaps ymm3, ymm0
@LBB1_9:
  vmaxps ymm0, ymm0, yword ptr [rsi + 4*rdx + 4]
  vmaxps ymm1, ymm1, yword ptr [rsi + 4*rdx + 36]
  vmaxps ymm2, ymm2, yword ptr [rsi + 4*rdx + 68]
  vmaxps ymm3, ymm3, yword ptr [rsi + 4*rdx + 100]
  add rdx, 32
  cmp rcx, rdx
  jne @LBB1_9
  vmaxps ymm0, ymm0, ymm1
  vmaxps ymm1, ymm2, ymm3
  vmaxps ymm0, ymm0, ymm1
  vextractf128 xmm1, ymm0, 1
  vmaxps xmm0, xmm0, xmm1
  vshufpd xmm1, xmm0, xmm0, 1
  vmaxps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vmaxss xmm7, xmm0, xmm1
  cmp rax, rcx
  je @LBB1_14
  test al, 28
  je @LBB1_12
@LBB1_4:
  mov r8, rax
  and r8, -4
  lea rdx, [r8 + 1]
  vbroadcastss xmm0, xmm7
@LBB1_5:
  vmaxps xmm0, xmm0, dqword ptr [rsi + 4*rcx + 4]
  add rcx, 4
  cmp r8, rcx
  jne @LBB1_5
  vshufpd xmm1, xmm0, xmm0, 1
  vmaxps xmm0, xmm0, xmm1
  vmovshdup xmm1, xmm0
  vmaxss xmm7, xmm0, xmm1
  cmp rax, r8
  jne @LBB1_7
  jmp @LBB1_14
@LBB1_12:
  or rcx, 1
  mov rdx, rcx
@LBB1_7:
  vmaxss xmm7, xmm7, dword ptr [rsi + 4*rdx]
  inc rdx
  cmp rbx, rdx
  jne @LBB1_7
@LBB1_14:
  vxorps xmm6, xmm6, xmm6
  xor r14d, r14d
@LBB1_15:
  vmovss xmm0, dword ptr [rsi + 4*r14]
  vsubss xmm0, xmm0, xmm7
  vzeroupper
  call AMD64Exp
  vmovss dword ptr [rsi + 4*r14], xmm0
  vaddss xmm6, xmm0, xmm6
  inc r14
  cmp rbx, r14
  jne @LBB1_15
  cmp edi, 3
  ja @LBB1_20
  xor eax, eax
  jmp @LBB1_18
@LBB1_20:
  cmp edi, 32
  jae @LBB1_22
  xor eax, eax
  jmp @LBB1_26
@LBB1_22:
  mov eax, ebx
  and eax, 2147483616
  vmovss xmm0, dword ptr [rip + LCPI1_0]
  vdivss xmm0, xmm0, xmm6
  vbroadcastss ymm0, xmm0
  xor ecx, ecx
@LBB1_23:
  vmulps ymm1, ymm0, yword ptr [rsi + 4*rcx]
  vmulps ymm2, ymm0, yword ptr [rsi + 4*rcx + 32]
  vmulps ymm3, ymm0, yword ptr [rsi + 4*rcx + 64]
  vmulps ymm4, ymm0, yword ptr [rsi + 4*rcx + 96]
  vmovups yword ptr [rsi + 4*rcx], ymm1
  vmovups yword ptr [rsi + 4*rcx + 32], ymm2
  vmovups yword ptr [rsi + 4*rcx + 64], ymm3
  vmovups yword ptr [rsi + 4*rcx + 96], ymm4
  add rcx, 32
  cmp rax, rcx
  jne @LBB1_23
  cmp eax, ebx
  je @LBB1_29
  test bl, 28
  je @LBB1_18
@LBB1_26:
  mov rcx, rax
  mov eax, ebx
  and eax, 2147483644
  vmovss xmm0, dword ptr [rip + LCPI1_0]
  vdivss xmm0, xmm0, xmm6
  vbroadcastss xmm0, xmm0
@LBB1_27:
  vmulps xmm1, xmm0, dqword ptr [rsi + 4*rcx]
  vmovups dqword ptr [rsi + 4*rcx], xmm1
  add rcx, 4
  cmp rax, rcx
  jne @LBB1_27
  cmp eax, ebx
  je @LBB1_29
@LBB1_18:
  vmovss xmm0, dword ptr [rip + LCPI1_0]
  vdivss xmm0, xmm0, xmm6
@LBB1_19:
  vmulss xmm1, xmm0, dword ptr [rsi + 4*rax]
  vmovss dword ptr [rsi + 4*rax], xmm1
  inc rax
  cmp rbx, rax
  jne @LBB1_19
@LBB1_29:
  vmovaps xmm6, dqword ptr [rsp + 32]
  vmovaps xmm7, dqword ptr [rsp + 48]
  add rsp, 72
  pop rbx
  pop rdi
  pop rsi
  pop r14
  vzeroupper
end;
{$endif}

procedure PascalSoftMax(const aX:PPasLLMFloatArray;const aSize:TPasLLMInt32);
var Index:TPasLLMSizeInt;
    MaxValue,Sum:TPasLLMFloat;
begin

 // Find the maximum value in the array for numerical stability
 MaxValue:=aX^[0]; // Initialize the max value to the first element
 for Index:=1 to aSize-1 do begin
  if MaxValue<aX^[Index] then begin
   MaxValue:=aX^[Index]; // Update the max value if the current element is greater
  end;
 end;

 // Exponentiate and sum the values
 Sum:=0.0; // Initialize the sum to zero
 for Index:=0 to aSize-1 do begin
  aX^[Index]:=exp(aX^[Index]-MaxValue); // Exponentiate the value minus the max value for numerical stability
  Sum:=Sum+aX^[Index]; // Add the exponentiated value to the sum
 end;

 // Normalize the output by dividing each value by the sum
 for Index:=0 to aSize-1 do begin
  aX^[Index]:=aX^[Index]/Sum; // Normalize the output
 end;

end;

procedure SoftMax(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
  AMD64SoftMax(aX,aSize);
 end else{$ifend}begin
  PascalSoftMax(aX,aSize);
 end;
end;

function CheckNaNs(const aX:PPasLLMFloatArray;const aSize:TPasLLMSizeInt):Boolean;
var Index:TPasLLMSizeInt;
begin
 result:=false;
 for Index:=0 to aSize-1 do begin
  if IsNaN(aX^[Index]) or IsInfinite(aX^[Index]) then begin
   result:=true;
   exit;
  end;
 end;
end;

{$ifdef cpuamd64}
procedure AMD64MatMulQ3F8Q80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xInt8=record
      Values:array[0..15] of TPasLLMInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign4xInt32=record
      Values:array[0..3] of TPasLLMInt32;
     end {$ifndef fpc}align 16{$endif};
     TAlign8xInt32=record
      Values:array[0..7] of TPasLLMInt32;
     end {$ifndef fpc}align 16{$endif};
const LC0:TAlign16xInt8=(Values:(-1,0,-1,4,-1,8,-1,12,-1,-1,-1,-1,-1,-1,-1,-1));
      LC1:TAlign8xInt32=(Values:(8,11,14,17,20,23,26,29));
      LC2:TAlign8xInt32=(Values:(1065353216,1061158912,1056964608,1048576000,-2147483648,-1098907648,-1090519040,-1086324736));
      LC3:TAlign4xInt32=(Values:(1065353216,1065353216,1065353216,1065353216));
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rbp
  mov rbp, rsp
  push r12
  push rdi
  mov rdi, rdx
  push rsi
  push rbx
  sub rsp, 160
  mov edx, dword ptr [rbp+48]
  mov eax, dword ptr [rbp+56]
  and rsp, -32
  vmovaps dqword ptr [rsp], xmm6
  vmovaps dqword ptr [rsp+16], xmm7
  vmovaps dqword ptr [rsp+32], xmm8
  vmovaps dqword ptr [rsp+48], xmm9
  vmovaps dqword ptr [rsp+64], xmm10
  vmovaps dqword ptr [rsp+80], xmm11
  vmovaps dqword ptr [rsp+96], xmm12
  vmovaps dqword ptr [rsp+112], xmm13
  vmovaps dqword ptr [rsp+128], xmm14
  vmovaps dqword ptr [rsp+144], xmm15
  cmp edx, eax
  jg @L10
  test r9d, r9d
  lea ebx, [r9+7]
  db $4c,$63,$d2 // movsx r10, edx
  vmovdqu ymm9, yword ptr [rip+LC1]
  cmovns ebx, r9d
  sub eax, edx
  vmovups ymm8, yword ptr [rip+LC2]
  lea r11, [rcx+r10*4]
  add rax, r10
  sar ebx, 3
  lea rsi, [rcx+4+rax*4]
  lea r12d, [0+rbx*4]
  imul ebx, edx
  sal ebx, 2
@L5:
  test r9d, r9d
  jle @L7
  vxorps xmm13, xmm13, xmm13
  db $4c,$63,$d3 // movsx r10, ebx
  mov rax, rdi
  xor edx, edx
  vmovaps ymm12, ymm13
@L4:
  mov ecx, edx
  vpmovsxbd ymm4, qword ptr [rax+24]
  vpxor xmm6, xmm6, xmm6
  add edx, 32
  sar ecx, 3
  vpinsrw xmm5, xmm6, word ptr [rax+32], 0
  vpmovsxbd ymm6, qword ptr [rax+16]
  add rax, 34
  lea rcx, [r8+rcx*4]
  vcvtdq2ps ymm4, ymm4
  vpmovsxbd ymm10, qword ptr [rax-34]
  vpmovsxbd ymm11, qword ptr [rax-26]
  vmovdqu xmm0, dqword ptr [rcx+r10]
  vcvtdq2ps ymm6, ymm6
  vcvtph2ps xmm5, xmm5
  vbroadcastss ymm5, xmm5
  vcvtdq2ps ymm10, ymm10
  vcvtdq2ps ymm11, ymm11
  vpshufb xmm1, xmm0, dqword ptr [rip+LC0]
  vinserti128 ymm0, ymm0, xmm0, 1
  vpshufd ymm3, ymm0, 0
  vpshufd ymm2, ymm0, 85
  vpshufd ymm7, ymm0, 170
  vcvtph2ps xmm1, xmm1
  vpshufd ymm0, ymm0, 255
  vpsrlvd ymm7, ymm7, ymm9
  vinserti128 ymm1, ymm1, xmm1, 1
  vpsrlvd ymm0, ymm0, ymm9
  vpsrlvd ymm3, ymm3, ymm9
  vpermilps ymm14, ymm1, 85
  vpermps ymm7, ymm7, ymm8
  vpsrlvd ymm2, ymm2, ymm9
  vpermilps ymm15, ymm1, 255
  vmulps ymm6, ymm6, ymm7
  vpermps ymm0, ymm0, ymm8
  vpermps ymm3, ymm3, ymm8
  vmulps ymm4, ymm4, ymm0
  vpermps ymm2, ymm2, ymm8
  vmulps ymm3, ymm10, ymm3
  vpermilps ymm10, ymm1, 0
  vpermilps ymm1, ymm1, 170
  vmulps ymm2, ymm11, ymm2
  vmulps ymm1, ymm1, ymm6
  vmulps ymm4, ymm4, ymm15
  vfmadd132ps ymm3, ymm1, ymm10
  vfmadd132ps ymm2, ymm4, ymm14
  vfmadd231ps ymm12, ymm5, ymm3
  vfmadd231ps ymm13, ymm5, ymm2
  cmp r9d, edx
  jg @L4
  vaddps ymm12, ymm12, ymm13
@L3:
  vextractf128 xmm0, ymm12, 1
  add r11, 4
  add ebx, r12d
  vaddps xmm0, xmm0, xmm12
  vdpps xmm0, xmm0, dqword ptr [rip+LC3], 241
  vmovss dword ptr [r11-4], xmm0
  cmp r11, rsi
  jne @L5
  vzeroupper
@L10:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp+16]
  vmovaps xmm8, dqword ptr [rsp+32]
  vmovaps xmm9, dqword ptr [rsp+48]
  vmovaps xmm10, dqword ptr [rsp+64]
  vmovaps xmm11, dqword ptr [rsp+80]
  vmovaps xmm12, dqword ptr [rsp+96]
  vmovaps xmm13, dqword ptr [rsp+112]
  vmovaps xmm14, dqword ptr [rsp+128]
  vmovaps xmm15, dqword ptr [rsp+144]
  lea rsp, [rbp-32]
  pop rbx
  pop rsi
  pop rdi
  pop r12
  pop rbp
  jmp @Exit
@L7:
  vxorps xmm12, xmm12, xmm12
  jmp @L3
@Exit:
end;

procedure AMD64MatMulQ3F8F8E5M2(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign16xUInt8=record
      Values:array[0..15] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign8xUInt32=record
      Values:array[0..7] of TPasLLMUInt32;
     end {$ifndef fpc}align 16{$endif};     
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3f800000); // 1.0
      LCPI0_4:TAlign16xUInt8=(Values:(128,0,128,4,128,8,128,12,0,0,0,0,0,0,0,0));
      LCPI0_2:TAlign8xUInt32=(Values:(8,11,14,17,20,23,26,29));
      LCPI0_3:TAlign8xUInt32=(Values:($3f800000,$3f400000,$3f000000,$3e800000,$80000000,$be800000,$bf000000,$bf400000));
{$ifdef fpc}{$pop}{$endif}
asm
{$if true}
  push rsi
  push rdi
  sub rsp, 152
  vmovaps dqword ptr [rsp + 128], xmm14
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 216]
  mov r10d, dword ptr [rsp + 208]
  lea r11d, [r9 + 7]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_15
  test r9d, r9d
  jle @LBB0_6
  sar r11d, 3
  shl r11d, 2
  inc eax
  mov r9d, r9d
  movsxd r10, r10d
  mov r11d, r11d
  mov rsi, r10
  imul rsi, r11
  add r8, rsi
  vmovq xmm0, qword ptr [rip + LCPI0_4]
  vmovdqu ymm1, yword ptr [rip + LCPI0_2]
  vmovdqu ymm2, yword ptr [rip + LCPI0_3]
  vbroadcastss xmm3, dword ptr [rip + LCPI0_0]
@LBB0_3:
  vxorps xmm4, xmm4, xmm4
  mov rsi, r8
  xor edi, edi
  vxorps xmm5, xmm5, xmm5
  vxorps xmm6, xmm6, xmm6
  vxorps xmm7, xmm7, xmm7
@LBB0_4:
  vpmovzxbw ymm8, dqword ptr [rdx + rdi]
  vpmovzxbw ymm9, dqword ptr [rdx + rdi + 16]
  vpsllw ymm10, ymm8, 8
  vcvtph2ps ymm11, xmm10
  vpsllw ymm8, ymm9, 8
  vextracti128 xmm9, ymm10, 1
  vcvtph2ps ymm12, xmm9
  vcvtph2ps ymm9, xmm8
  vmovdqu xmm10, dqword ptr [rsi]
  vpshufb xmm10, xmm10, xmm0
  vcvtph2ps xmm10, xmm10
  vpbroadcastd ymm13, dword ptr [rsi]
  vpsrlvd ymm13, ymm13, ymm1
  vpermd ymm13, ymm13, ymm2
  vbroadcastss ymm14, xmm10
  vmulps ymm13, ymm14, ymm13
  vfmadd231ps ymm4, ymm11, ymm13
  vpbroadcastd ymm11, dword ptr [rsi + 4]
  vpsrlvd ymm11, ymm11, ymm1
  vpermd ymm11, ymm11, ymm2
  vmovshdup xmm13, xmm10
  vbroadcastss ymm13, xmm13
  vmulps ymm11, ymm13, ymm11
  vfmadd231ps ymm5, ymm12, ymm11
  vpbroadcastd ymm11, dword ptr [rsi + 8]
  vpsrlvd ymm11, ymm11, ymm1
  vpermd ymm11, ymm11, ymm2
  vshufpd xmm12, xmm10, xmm10, 1
  vbroadcastss ymm12, xmm12
  vmulps ymm11, ymm12, ymm11
  vfmadd231ps ymm6, ymm9, ymm11
  vpbroadcastd ymm9, dword ptr [rsi + 12]
  vpsrlvd ymm9, ymm9, ymm1
  vpermd ymm9, ymm9, ymm2
  vshufps xmm10, xmm10, xmm10, 255
  vbroadcastss ymm10, xmm10
  vmulps ymm9, ymm10, ymm9
  vextracti128 xmm8, ymm8, 1
  vcvtph2ps ymm8, xmm8
  vfmadd231ps ymm7, ymm8, ymm9
  add rdi, 32
  add rsi, 16
  cmp rdi, r9
  jb @LBB0_4
  vaddps ymm6, ymm6, ymm7
  vaddps ymm4, ymm5, ymm4
  vaddps ymm4, ymm6, ymm4
  vextractf128 xmm5, ymm4, 1
  vaddps xmm4, xmm4, xmm5
  vdpps xmm4, xmm4, xmm3, 241
  vmovss dword ptr [rcx + 4*r10], xmm4
  inc r10
  add r8, r11
  cmp eax, r10d
  jne @LBB0_3
  jmp @LBB0_15
@LBB0_6:
  vbroadcastss xmm0, dword ptr [rip + LCPI0_0]
  vxorps xmm1, xmm1, xmm1
  vdpps xmm0, xmm1, xmm0, 241
  movsxd r9, r10d
  cmp esi, 2
  ja @LBB0_10
  mov r11, r9
  jmp @LBB0_8
@LBB0_10:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_16
  xor r10d, r10d
  jmp @LBB0_12
@LBB0_16:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_17:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_17
  cmp rdx, r10
  je @LBB0_15
  test dl, 28
  je @LBB0_20
@LBB0_12:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_13:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_13
  cmp rdx, r8
  jne @LBB0_8
  jmp @LBB0_15
@LBB0_20:
  add r10, r9
  mov r11, r10
@LBB0_8:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_9:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_9
@LBB0_15:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  vmovaps xmm14, dqword ptr [rsp + 128]
  add rsp, 152
  pop rdi
  pop rsi
  vzeroupper
 {$else} 
  push rsi
  push rdi
  sub rsp, 120
  vmovdqa dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 184]
  mov r10d, dword ptr [rsp + 176]
  lea r11d, [r9 + 7]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_15
  test r9d, r9d
  jle @LBB0_6
  sar r11d, 3
  shl r11d, 2
  inc eax
  mov r9d, r9d
  movsxd r10, r10d
  mov r11d, r11d
  mov rsi, r10
  imul rsi, r11
  add r8, rsi
  vmovq xmm0, qword ptr [rip + LCPI0_4]
  vmovdqu ymm1, yword ptr [rip + LCPI0_2]
  vmovdqu ymm2, yword ptr [rip + LCPI0_3]
  vbroadcastss xmm3, dword ptr [rip + LCPI0_0]
@LBB0_3:
  vxorps xmm4, xmm4, xmm4
  mov rsi, r8
  xor edi, edi
  vxorps xmm5, xmm5, xmm5
@LBB0_4:
  vpmovzxbw ymm6, dqword ptr [rdx + rdi]
  vpmovzxbw ymm7, dqword ptr [rdx + rdi + 16]
  vpsllw ymm6, ymm6, 8
  vcvtph2ps ymm8, xmm6
  vextracti128 xmm6, ymm6, 1
  vcvtph2ps ymm6, xmm6
  vpsllw ymm7, ymm7, 8
  vcvtph2ps ymm9, xmm7
  vextracti128 xmm7, ymm7, 1
  vcvtph2ps ymm7, xmm7
  vmovdqu xmm10, dqword ptr [rsi]
  vpshufb xmm10, xmm10, xmm0
  vcvtph2ps xmm10, xmm10
  vpbroadcastd ymm11, dword ptr [rsi]
  vpsrlvd ymm11, ymm11, ymm1
  vpermd ymm11, ymm11, ymm2
  vpbroadcastd ymm12, dword ptr [rsi + 4]
  vmulps ymm8, ymm11, ymm8
  vpsrlvd ymm11, ymm12, ymm1
  vpermd ymm11, ymm11, ymm2
  vmulps ymm6, ymm11, ymm6
  vpbroadcastd ymm11, dword ptr [rsi + 8]
  vpsrlvd ymm11, ymm11, ymm1
  vpermd ymm11, ymm11, ymm2
  vmulps ymm9, ymm11, ymm9
  vpbroadcastd ymm11, dword ptr [rsi + 12]
  vpsrlvd ymm11, ymm11, ymm1
  vpermd ymm11, ymm11, ymm2
  vmulps ymm7, ymm11, ymm7
  vbroadcastss ymm11, xmm10
  vfmadd213ps ymm11, ymm8, ymm4
  vmovshdup xmm4, xmm10
  vbroadcastss ymm8, xmm4
  vfmadd213ps ymm8, ymm6, ymm5
  vshufpd xmm4, xmm10, xmm10, 1
  vbroadcastss ymm4, xmm4
  vfmadd213ps ymm4, ymm9, ymm11
  vshufps xmm5, xmm10, xmm10, 255
  vbroadcastss ymm5, xmm5
  vfmadd213ps ymm5, ymm7, ymm8
  add rdi, 32
  add rsi, 16
  cmp rdi, r9
  jb @LBB0_4
  vaddps ymm4, ymm4, ymm5
  vextractf128 xmm5, ymm4, 1
  vaddps xmm4, xmm4, xmm5
  vdpps xmm4, xmm4, xmm3, 241
  vmovss dword ptr [rcx + 4*r10], xmm4
  inc r10
  add r8, r11
  cmp eax, r10d
  jne @LBB0_3
  jmp @LBB0_15
@LBB0_6:
  vbroadcastss xmm0, dword ptr [rip + LCPI0_0]
  vxorps xmm1, xmm1, xmm1
  vdpps xmm0, xmm1, xmm0, 241
  movsxd r9, r10d
  cmp esi, 2
  ja @LBB0_10
  mov r11, r9
  jmp @LBB0_8
@LBB0_10:
  lea rdx, [rsi + 1]
  movabs r8, 8589934560
  cmp esi, 31
  jae @LBB0_16
  xor r10d, r10d
  jmp @LBB0_12
@LBB0_16:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_17:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_17
  cmp rdx, r10
  je @LBB0_15
  test dl, 28
  je @LBB0_20
@LBB0_12:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_13:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_13
  cmp rdx, r8
  jne @LBB0_8
  jmp @LBB0_15
@LBB0_20:
  add r10, r9
  mov r11, r10
@LBB0_8:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_9:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_9
@LBB0_15:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  add rsp, 120
  pop rdi
  pop rsi
  vzeroupper
{$ifend}
end;

procedure AMD64MatMulQ40Q80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_3:TPasLLMUInt8=TPasLLMUInt8($0f); // Nibble mask
      LCPI0_4:TPasLLMUInt8=TPasLLMUInt8($f8); // -8
      LCPI0_5:TPasLLMUInt16=TPasLLMUInt16($0001); // One
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  push rbx
  sub rsp, 32
  vmovdqa dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 104]
  mov r10d, dword ptr [rsp + 96]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_20
  movsxd r10, r10d
  cmp r9d, 31
  jle @LBB0_2
  sar r11d, 5
  lea r9d, [r11 + r11]
  lea r9d, [r9 + 8*r9]
  mov r9d, r9d
  inc eax
  vpbroadcastb ymm0, byte ptr [rip + LCPI0_3]
  vpbroadcastb ymm1, byte ptr [rip + LCPI0_4]
  vpbroadcastw ymm2, word ptr [rip + LCPI0_5]
@LBB0_17:
  mov rsi, r10
  imul rsi, r9
  add rsi, r8
  vxorps xmm3, xmm3, xmm3
  mov edi, r11d
  mov rbx, rdx
@LBB0_18:
  vmovdqu xmm4, dqword ptr [rsi]
  vpsrlw xmm5, xmm4, 4
  vpunpckhbw xmm6, xmm4, xmm5
  vpunpcklbw xmm4, xmm4, xmm5
  vinserti128 ymm4, ymm4, xmm6, 1
  vpand ymm4, ymm4, ymm0
  vpaddb ymm4, ymm4, ymm1
  vpinsrw xmm5, xmm0, word ptr [rsi + 16], 0
  vcvtph2ps xmm5, xmm5
  vpinsrw xmm6, xmm0, word ptr [rbx + 32], 0
  vcvtph2ps xmm6, xmm6
  vmovdqu ymm7, yword ptr [rbx]
  vmulss xmm5, xmm6, xmm5
  vbroadcastss ymm5, xmm5
  vpsignb ymm6, ymm4, ymm4
  vpsignb ymm4, ymm7, ymm4
  vpmaddubsw ymm4, ymm6, ymm4
  vpmaddwd ymm4, ymm4, ymm2
  vcvtdq2ps ymm4, ymm4
  vfmadd231ps ymm3, ymm5, ymm4
  add rsi, 18
  add rbx, 34
  dec edi
  jne @LBB0_18
  vextractf128 xmm4, ymm3, 1
  vaddps xmm3, xmm4, xmm3
  vshufpd xmm4, xmm3, xmm3, 1
  vaddps xmm3, xmm4, xmm3
  vmovshdup xmm4, xmm3
  vaddss xmm3, xmm3, xmm4
  vmovss dword ptr [rcx + 4*r10], xmm3
  inc r10
  cmp eax, r10d
  jne @LBB0_17
  jmp @LBB0_20
@LBB0_2:
  cmp esi, 2
  ja @LBB0_6
  mov r11, r10
  jmp @LBB0_4
@LBB0_6:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_11
  xor r9d, r9d
  jmp @LBB0_8
@LBB0_11:
  mov r9, rdx
  and r9, r8
  lea r11, [rcx + 4*r10]
  add r11, 96
  xor esi, esi
  vpxor xmm0, xmm0, xmm0
@LBB0_12:
  vmovdqu yword ptr [r11 + 4*rsi - 96], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 64], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 32], ymm0
  vmovdqu yword ptr [r11 + 4*rsi], ymm0
  add rsi, 32
  cmp r9, rsi
  jne @LBB0_12
  cmp rdx, r9
  je @LBB0_20
  test dl, 28
  je @LBB0_15
@LBB0_8:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r10]
  lea r10, [rcx + 4*r10]
  vpxor xmm0, xmm0, xmm0
@LBB0_9:
  vmovdqu dqword ptr [r10 + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_9
  cmp rdx, r8
  jne @LBB0_4
  jmp @LBB0_20
@LBB0_15:
  add r9, r10
  mov r11, r9
@LBB0_4:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_5:
  mov dword ptr [rcx + 4*rdx], 0
  inc rdx
  cmp eax, edx
  jne @LBB0_5
@LBB0_20:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  add rsp, 32
  pop rbx
  pop rdi
  pop rsi
  vzeroupper
end;

procedure AMD64MatMulQ40NLQ80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign32xUInt8=record
      Values:array[0..31] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_1:TAlign32xUInt8=(Values:(129,129,155,178,199,217,233,246,0,10,23,39,57,78,101,127,
                                      129,129,155,178,199,217,233,246,0,10,23,39,57,78,101,127));
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_4:TPasLLMUInt8=TPasLLMUInt8($0f); 
      LCPI0_5:TPasLLMUInt16=TPasLLMUInt16($0001);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  push rbx
  sub rsp, 48
  vmovdqa dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 120]
  mov r10d, dword ptr [rsp + 112]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_20
  movsxd r10, r10d
  cmp r9d, 31
  jle @LBB0_2
  sar r11d, 5
  lea r9d, [r11 + r11]
  lea r9d, [r9 + 8*r9]
  mov r9d, r9d
  inc eax
  vpbroadcastb ymm0, byte ptr [rip + LCPI0_4]
  vmovdqu ymm1, yword ptr [rip + LCPI0_1]
  vmovss xmm2, dword ptr [rip + LCPI0_2]
  vpbroadcastw ymm3, word ptr [rip + LCPI0_5]
@LBB0_17:
  mov rsi, r10
  imul rsi, r9
  add rsi, r8
  vxorps xmm4, xmm4, xmm4
  mov edi, r11d
  mov rbx, rdx
@LBB0_18:
  vmovdqu xmm5, dqword ptr [rsi]
  vpsrlw xmm6, xmm5, 4
  vpunpckhbw xmm7, xmm5, xmm6
  vpunpcklbw xmm5, xmm5, xmm6
  vinserti128 ymm5, ymm5, xmm7, 1
  vpand ymm5, ymm5, ymm0
  vpshufb ymm5, ymm1, ymm5
  vmovdqu ymm6, yword ptr [rbx]
  vpinsrw xmm7, xmm0, word ptr [rsi + 16], 0
  vcvtph2ps xmm7, xmm7
  vpinsrw xmm8, xmm0, word ptr [rbx + 32], 0
  vcvtph2ps xmm8, xmm8
  vmulss xmm7, xmm8, xmm7
  vmulss xmm7, xmm7, xmm2
  vbroadcastss ymm7, xmm7
  vpsignb ymm8, ymm5, ymm5
  vpsignb ymm5, ymm6, ymm5
  vpmaddubsw ymm5, ymm8, ymm5
  vpmaddwd ymm5, ymm5, ymm3
  vcvtdq2ps ymm5, ymm5
  vfmadd231ps ymm4, ymm7, ymm5
  add rsi, 18
  add rbx, 34
  dec edi
  jne @LBB0_18
  vextractf128 xmm5, ymm4, 1
  vaddps xmm4, xmm5, xmm4
  vshufpd xmm5, xmm4, xmm4, 1
  vaddps xmm4, xmm5, xmm4
  vmovshdup xmm5, xmm4
  vaddss xmm4, xmm4, xmm5
  vmovss dword ptr [rcx + 4*r10], xmm4
  inc r10
  cmp eax, r10d
  jne @LBB0_17
  jmp @LBB0_20
@LBB0_2:
  cmp esi, 2
  ja @LBB0_6
  mov r11, r10
  jmp @LBB0_4
@LBB0_6:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_11
  xor r9d, r9d
  jmp @LBB0_8
@LBB0_11:
  mov r9, rdx
  and r9, r8
  lea r11, [rcx + 4*r10]
  add r11, 96
  xor esi, esi
  vpxor xmm0, xmm0, xmm0
@LBB0_12:
  vmovdqu yword ptr [r11 + 4*rsi - 96], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 64], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 32], ymm0
  vmovdqu yword ptr [r11 + 4*rsi], ymm0
  add rsi, 32
  cmp r9, rsi
  jne @LBB0_12
  cmp rdx, r9
  je @LBB0_20
  test dl, 28
  je @LBB0_15
@LBB0_8:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r10]
  lea r10, [rcx + 4*r10]
  vpxor xmm0, xmm0, xmm0
@LBB0_9:
  vmovdqu dqword ptr [r10 + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_9
  cmp rdx, r8
  jne @LBB0_4
  jmp @LBB0_20
@LBB0_15:
  add r9, r10
  mov r11, r9
@LBB0_4:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_5:
  mov dword ptr [rcx + 4*rdx], 0
  inc rdx
  cmp eax, edx
  jne @LBB0_5
@LBB0_20:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 48
  pop rbx
  pop rdi
  pop rsi
  vzeroupper
end;

procedure AMD64MatMulQ41NLQ80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$ifdef fpc}{$push}{$codealign recordmin=16}{$codealign constmin=16}{$codealign varmin=16}{$codealign localmin=16}{$endif}
type TAlign32xUInt8=record
      Values:array[0..31] of TPasLLMUInt8;
     end {$ifndef fpc}align 16{$endif};
     TAlign32xInt8=record
      Values:array[0..31] of TPasLLMInt8;
     end {$ifndef fpc}align 16{$endif};
const LCPI0_1:TAlign32xInt8=(Values:(-127,-127,-93,-65,-41,-23,-10,-3,0,3,10,23,41,65,93,127,
                                     -127,-127,-93,-65,-41,-23,-10,-3,0,3,10,23,41,65,93,127));
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_4:TPasLLMUInt8=TPasLLMUInt8($0f); 
      LCPI0_5:TPasLLMUInt16=TPasLLMUInt16($0001);
{$ifdef fpc}{$pop}{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  push rbx
  sub rsp, 48
  vmovdqa dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovdqa dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 120]
  mov r10d, dword ptr [rsp + 112]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_20
  movsxd r10, r10d
  cmp r9d, 31
  jle @LBB0_2
  sar r11d, 5
  lea r9d, [r11 + r11]
  lea r9d, [r9 + 8*r9]
  mov r9d, r9d
  inc eax
  vpbroadcastb ymm0, byte ptr [rip + LCPI0_4]
  vmovdqu ymm1, yword ptr [rip + LCPI0_1]
  vmovss xmm2, dword ptr [rip + LCPI0_2]
  vpbroadcastw ymm3, word ptr [rip + LCPI0_5]
@LBB0_17:
  mov rsi, r10
  imul rsi, r9
  add rsi, r8
  vxorps xmm4, xmm4, xmm4
  mov edi, r11d
  mov rbx, rdx
@LBB0_18:
  vmovdqu xmm5, dqword ptr [rsi]
  vpsrlw xmm6, xmm5, 4
  vpunpckhbw xmm7, xmm5, xmm6
  vpunpcklbw xmm5, xmm5, xmm6
  vinserti128 ymm5, ymm5, xmm7, 1
  vpand ymm5, ymm5, ymm0
  vpshufb ymm5, ymm1, ymm5
  vmovdqu ymm6, yword ptr [rbx]
  vpinsrw xmm7, xmm0, word ptr [rsi + 16], 0
  vcvtph2ps xmm7, xmm7
  vpinsrw xmm8, xmm0, word ptr [rbx + 32], 0
  vcvtph2ps xmm8, xmm8
  vmulss xmm7, xmm8, xmm7
  vmulss xmm7, xmm7, xmm2
  vbroadcastss ymm7, xmm7
  vpsignb ymm8, ymm5, ymm5
  vpsignb ymm5, ymm6, ymm5
  vpmaddubsw ymm5, ymm8, ymm5
  vpmaddwd ymm5, ymm5, ymm3
  vcvtdq2ps ymm5, ymm5
  vfmadd231ps ymm4, ymm7, ymm5
  add rsi, 18
  add rbx, 34
  dec edi
  jne @LBB0_18
  vextractf128 xmm5, ymm4, 1
  vaddps xmm4, xmm5, xmm4
  vshufpd xmm5, xmm4, xmm4, 1
  vaddps xmm4, xmm5, xmm4
  vmovshdup xmm5, xmm4
  vaddss xmm4, xmm4, xmm5
  vmovss dword ptr [rcx + 4*r10], xmm4
  inc r10
  cmp eax, r10d
  jne @LBB0_17
  jmp @LBB0_20
@LBB0_2:
  cmp esi, 2
  ja @LBB0_6
  mov r11, r10
  jmp @LBB0_4
@LBB0_6:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_11
  xor r9d, r9d
  jmp @LBB0_8
@LBB0_11:
  mov r9, rdx
  and r9, r8
  lea r11, [rcx + 4*r10]
  add r11, 96
  xor esi, esi
  vpxor xmm0, xmm0, xmm0
@LBB0_12:
  vmovdqu yword ptr [r11 + 4*rsi - 96], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 64], ymm0
  vmovdqu yword ptr [r11 + 4*rsi - 32], ymm0
  vmovdqu yword ptr [r11 + 4*rsi], ymm0
  add rsi, 32
  cmp r9, rsi
  jne @LBB0_12
  cmp rdx, r9
  je @LBB0_20
  test dl, 28
  je @LBB0_15
@LBB0_8:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r10]
  lea r10, [rcx + 4*r10]
  vpxor xmm0, xmm0, xmm0
@LBB0_9:
  vmovdqu dqword ptr [r10 + 4*r9], xmm0
  add r9, 4
  cmp r8, r9
  jne @LBB0_9
  cmp rdx, r8
  jne @LBB0_4
  jmp @LBB0_20
@LBB0_15:
  add r9, r10
  mov r11, r9
@LBB0_4:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_5:
  mov dword ptr [rcx + 4*rdx], 0
  inc rdx
  cmp eax, edx
  jne @LBB0_5
@LBB0_20:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  add rsp, 48
  pop rbx
  pop rdi
  pop rsi
  vzeroupper
end;

procedure AMD64MatMulQ42NLQ80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_2:array[0..15] of TPasLLMUInt8=(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15);
      LCPI0_3:array[0..15] of TPasLLMUInt8=(248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248);
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  push rbx
  sub rsp, 224
  vmovaps dqword ptr [rsp + 208], xmm15
  vmovaps dqword ptr [rsp + 192], xmm14
  vmovaps dqword ptr [rsp + 176], xmm13
  vmovaps dqword ptr [rsp + 160], xmm12
  vmovaps dqword ptr [rsp + 144], xmm11
  vmovaps dqword ptr [rsp + 128], xmm10
  vmovaps dqword ptr [rsp + 112], xmm9
  vmovaps dqword ptr [rsp + 96], xmm8
  vmovaps dqword ptr [rsp + 80], xmm7
  vmovaps dqword ptr [rsp + 64], xmm6
  mov eax, dword ptr [rsp + 296]
  mov r10d, dword ptr [rsp + 288]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_13
  cmp r9d, 32
  jl @LBB0_6
  sar r11d, 5
  lea r9d, [r11 + r11]
  lea esi, [r9 + 8*r9]
  movsxd r9, r10d
  mov r10d, esi
  inc eax
  mov r11d, r11d
  mov rsi, r9
  imul rsi, r10
  add r8, rsi
  add r8, 17
  mov rsi, r11
  shl rsi, 5
  lea r11, [rsi + 2*r11]
  vmovss xmm2, dword ptr [rip + LCPI0_0]
  vmovss xmm3, dword ptr [rip + LCPI0_1]
  vmovdqu xmm4, dqword ptr [rip + LCPI0_2]
  vmovdqu xmm5, dqword ptr [rip + LCPI0_3]
  vbroadcastss ymm15, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm6, dword ptr [rip + LCPI0_5]
@LBB0_3:
  vxorps xmm7, xmm7, xmm7
  mov rsi, r8
  xor edi, edi
  vxorps xmm11, xmm11, xmm11
  vxorps xmm8, xmm8, xmm8
  vxorps xmm9, xmm9, xmm9
@LBB0_4:
  vmovups yword ptr [rsp], ymm11
  vmovups yword ptr [rsp + 32], ymm7
  movsx ebx, byte ptr [rsi]
  vxorps xmm13, xmm13, xmm13
  vcvtsi2ss xmm10, xmm13, ebx
  movzx ebx, byte ptr [rsi - 1]
  vmulss xmm10, xmm10, xmm2
  vbroadcastss ymm11, xmm10
  vsubss xmm10, xmm3, xmm10
  vbroadcastss ymm10, xmm10
  vmovdqu xmm12, dqword ptr [rsi - 17]
  vpsrlw xmm13, xmm12, 4
  vpand xmm12, xmm12, xmm4
  vpand xmm13, xmm13, xmm4
  vpunpcklbw xmm14, xmm12, xmm13
  vpunpckhbw xmm12, xmm12, xmm13
  vpaddb xmm13, xmm14, xmm5
  vpaddb xmm7, xmm12, xmm5
  vpshufd xmm12, xmm13, 238
  vpmovsxbd ymm13, xmm13
  vcvtdq2ps ymm13, ymm13
  vpmovsxbd ymm12, xmm12
  vcvtdq2ps ymm12, ymm12
  vpmovsxbd ymm14, xmm7
  vcvtdq2ps ymm14, ymm14
  vmulps ymm0, ymm13, ymm15
  vmulps ymm1, ymm12, ymm15
  vmovdqa xmm5, xmm4
  vmovaps xmm4, xmm3
  vmovaps xmm3, xmm2
  vmulps ymm2, ymm14, ymm15
  vandps ymm12, ymm0, ymm6
  vmulps ymm13, ymm11, ymm0
  vmulps ymm13, ymm13, ymm12
  vandps ymm12, ymm1, ymm6
  vfmadd231ps ymm13, ymm10, ymm0
  vmulps ymm0, ymm11, ymm1
  vmulps ymm12, ymm12, ymm0
  vandps ymm0, ymm2, ymm6
  vfmadd231ps ymm12, ymm10, ymm1
  vmulps ymm1, ymm11, ymm2
  vmulps ymm14, ymm1, ymm0
  vmovd xmm0, ebx
  vpslld xmm0, xmm0, 8
  vcvtph2ps xmm0, xmm0
  vpshufd xmm1, xmm7, 238
  vmovups ymm7, yword ptr [rsp + 32]
  vpmovsxbd ymm1, xmm1
  vcvtdq2ps ymm1, ymm1
  vmulps ymm1, ymm15, ymm1
  vfmadd231ps ymm14, ymm10, ymm2
  vandps ymm2, ymm1, ymm6
  vmulps ymm11, ymm11, ymm1
  vmulps ymm2, ymm11, ymm2
  vpinsrw xmm11, xmm0, word ptr [rdx + rdi + 32], 0
  vfmadd231ps ymm2, ymm10, ymm1
  vcvtph2ps xmm1, xmm11
  vmovups ymm11, yword ptr [rsp]
  vmulss xmm0, xmm0, xmm1
  vpmovsxbd ymm1, qword ptr [rdx + rdi]
  vcvtdq2ps ymm1, ymm1
  vbroadcastss ymm0, xmm0
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm7, ymm13, ymm1
  vpmovsxbd ymm1, qword ptr [rdx + rdi + 8]
  vpmovsxbd ymm10, qword ptr [rdx + rdi + 16]
  vcvtdq2ps ymm1, ymm1
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm11, ymm12, ymm1
  vcvtdq2ps ymm1, ymm10
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm8, ymm14, ymm1
  vpmovsxbd ymm1, qword ptr [rdx + rdi + 24]
  vcvtdq2ps ymm1, ymm1
  vmulps ymm0, ymm0, ymm1
  vfmadd231ps ymm9, ymm2, ymm0
  vmovaps xmm2, xmm3
  vmovaps xmm3, xmm4
  vmovdqa xmm4, xmm5
  vmovdqu xmm5, dqword ptr [rip + LCPI0_3]
  add rdi, 34
  add rsi, 18
  cmp r11, rdi
  jne @LBB0_4
  vaddps ymm0, ymm8, ymm9
  vaddps ymm1, ymm11, ymm7
  vaddps ymm0, ymm0, ymm1
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vmovss dword ptr [rcx + 4*r9], xmm0
  inc r9
  add r8, r10
  cmp eax, r9d
  jne @LBB0_3
  jmp @LBB0_13
@LBB0_6:
  vxorps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  movsxd r9, r10d
  cmp esi, 3
  jae @LBB0_8
  mov r11, r9
  jmp @LBB0_19
@LBB0_8:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_14
  xor r10d, r10d
  jmp @LBB0_10
@LBB0_14:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_15:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_15
  cmp rdx, r10
  je @LBB0_13
  test dl, 28
  je @LBB0_18
@LBB0_10:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_11:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_11
  cmp rdx, r8
  je @LBB0_13
@LBB0_19:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_20:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_20
@LBB0_13:
  vmovaps xmm6, dqword ptr [rsp + 64]
  vmovaps xmm7, dqword ptr [rsp + 80]
  vmovaps xmm8, dqword ptr [rsp + 96]
  vmovaps xmm9, dqword ptr [rsp + 112]
  vmovaps xmm10, dqword ptr [rsp + 128]
  vmovaps xmm11, dqword ptr [rsp + 144]
  vmovaps xmm12, dqword ptr [rsp + 160]
  vmovaps xmm13, dqword ptr [rsp + 176]
  vmovaps xmm14, dqword ptr [rsp + 192]
  vmovaps xmm15, dqword ptr [rsp + 208]
  add rsp, 224
  pop rbx
  pop rdi
  pop rsi
  vzeroupper
  jmp @Exit
@LBB0_18:
  add r10, r9
  mov r11, r10
  jmp @LBB0_19
@Exit:
end;

procedure AMD64MatMulQ43NLQ80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3c010204);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($3e124925);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_2:array[0..15] of TPasLLMUInt8=(15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15);
      LCPI0_3:array[0..15] of TPasLLMUInt8=(248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248);
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  push rdi
  push rbx
  sub rsp, 192
  vmovdqa dqword ptr [rsp + 176], xmm15
  vmovaps dqword ptr [rsp + 160], xmm14
  vmovaps dqword ptr [rsp + 144], xmm13
  vmovaps dqword ptr [rsp + 128], xmm12
  vmovaps dqword ptr [rsp + 112], xmm11
  vmovaps dqword ptr [rsp + 96], xmm10
  vmovaps dqword ptr [rsp + 80], xmm9
  vmovaps dqword ptr [rsp + 64], xmm8
  vmovaps dqword ptr [rsp + 48], xmm7
  vmovaps dqword ptr [rsp + 32], xmm6
  mov eax, dword ptr [rsp + 264]
  mov r10d, dword ptr [rsp + 256]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_13
  cmp r9d, 32
  jl @LBB0_6
  sar r11d, 5
  lea r9d, [r11 + 8*r11]
  lea esi, [r11 + 2*r9]
  movsxd r9, r10d
  mov r10d, esi
  inc eax
  mov r11d, r11d
  mov rsi, r9
  imul rsi, r10
  add r8, rsi
  add r8, 18
  mov rsi, r11
  shl rsi, 5
  lea r11, [rsi + 2*r11]
  vmovss xmm2, dword ptr [rip + LCPI0_0]
  vmovss xmm3, dword ptr [rip + LCPI0_1]
  vmovdqu xmm4, dqword ptr [rip + LCPI0_2]
  vmovdqu xmm15, dqword ptr [rip + LCPI0_3]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm6, dword ptr [rip + LCPI0_5]
@LBB0_3:
  vxorps xmm7, xmm7, xmm7
  mov rsi, r8
  xor edi, edi
  vxorps xmm11, xmm11, xmm11
  vxorps xmm8, xmm8, xmm8
  vxorps xmm9, xmm9, xmm9
@LBB0_4:
  vmovups yword ptr [rsp], ymm11
  movsx ebx, byte ptr [rsi]
  vxorps xmm13, xmm13, xmm13
  vcvtsi2ss xmm10, xmm13, ebx
  vmulss xmm10, xmm10, xmm2
  vbroadcastss ymm11, xmm10
  vsubss xmm10, xmm3, xmm10
  vbroadcastss ymm10, xmm10
  vmovdqu xmm12, dqword ptr [rsi - 18]
  vpsrlw xmm13, xmm12, 4
  vpand xmm12, xmm12, xmm4
  vpand xmm13, xmm13, xmm4
  vpunpcklbw xmm14, xmm12, xmm13
  vpunpckhbw xmm12, xmm12, xmm13
  vpaddb xmm13, xmm14, xmm15
  vmovaps ymm4, ymm7
  vmovdqa xmm7, xmm15
  vpaddb xmm15, xmm12, xmm15
  vpshufd xmm12, xmm13, 238
  vpmovsxbd ymm13, xmm13
  vcvtdq2ps ymm13, ymm13
  vpmovsxbd ymm12, xmm12
  vcvtdq2ps ymm12, ymm12
  vpmovsxbd ymm14, xmm15
  vcvtdq2ps ymm14, ymm14
  vmulps ymm0, ymm13, ymm5
  vmulps ymm1, ymm12, ymm5
  vmovaps xmm3, xmm2
  vmulps ymm2, ymm14, ymm5
  vandps ymm12, ymm0, ymm6
  vmulps ymm13, ymm11, ymm0
  vmulps ymm13, ymm13, ymm12
  vandps ymm12, ymm1, ymm6
  vfmadd231ps ymm13, ymm10, ymm0
  vmulps ymm0, ymm11, ymm1
  vmulps ymm12, ymm12, ymm0
  vandps ymm0, ymm2, ymm6
  vfmadd231ps ymm12, ymm10, ymm1
  vmulps ymm1, ymm11, ymm2
  vmulps ymm14, ymm1, ymm0
  vpinsrw xmm0, xmm0, word ptr [rsi - 2], 0
  vcvtph2ps xmm0, xmm0
  vpshufd xmm1, xmm15, 238
  vmovdqa xmm15, xmm7
  vmovaps ymm7, ymm4
  vpmovsxbd ymm1, xmm1
  vcvtdq2ps ymm1, ymm1
  vmulps ymm1, ymm1, ymm5
  vfmadd231ps ymm14, ymm10, ymm2
  vandps ymm2, ymm1, ymm6
  vmulps ymm11, ymm11, ymm1
  vmulps ymm2, ymm11, ymm2
  vpinsrw xmm11, xmm0, word ptr [rdx + rdi + 32], 0
  vfmadd231ps ymm2, ymm10, ymm1
  vcvtph2ps xmm1, xmm11
  vmovups ymm11, yword ptr [rsp]
  vmulss xmm0, xmm1, xmm0
  vpmovsxbd ymm1, qword ptr [rdx + rdi]
  vcvtdq2ps ymm1, ymm1
  vbroadcastss ymm0, xmm0
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm7, ymm13, ymm1
  vpmovsxbd ymm1, qword ptr [rdx + rdi + 8]
  vpmovsxbd ymm10, qword ptr [rdx + rdi + 16]
  vcvtdq2ps ymm1, ymm1
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm11, ymm12, ymm1
  vcvtdq2ps ymm1, ymm10
  vmulps ymm1, ymm0, ymm1
  vfmadd231ps ymm8, ymm14, ymm1
  vpmovsxbd ymm1, qword ptr [rdx + rdi + 24]
  vcvtdq2ps ymm1, ymm1
  vmulps ymm0, ymm0, ymm1
  vfmadd231ps ymm9, ymm2, ymm0
  vmovaps xmm2, xmm3
  vmovss xmm3, dword ptr [rip + LCPI0_1]
  vmovdqu xmm4, dqword ptr [rip + LCPI0_2]
  add rdi, 34
  add rsi, 19
  cmp r11, rdi
  jne @LBB0_4
  vaddps ymm0, ymm8, ymm9
  vaddps ymm1, ymm11, ymm7
  vaddps ymm0, ymm0, ymm1
  vextractf128 xmm1, ymm0, 1
  vaddps xmm0, xmm0, xmm1
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vmovss dword ptr [rcx + 4*r9], xmm0
  inc r9
  add r8, r10
  cmp eax, r9d
  jne @LBB0_3
  jmp @LBB0_13
@LBB0_6:
  vxorps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  movsxd r9, r10d
  cmp esi, 3
  jae @LBB0_8
  mov r11, r9
  jmp @LBB0_19
@LBB0_8:
  lea rdx, [rsi + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp esi, 31
  jae @LBB0_14
  xor r10d, r10d
  jmp @LBB0_10
@LBB0_14:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_15:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_15
  cmp rdx, r10
  je @LBB0_13
  test dl, 28
  je @LBB0_18
@LBB0_10:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_11:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_11
  cmp rdx, r8
  je @LBB0_13
@LBB0_19:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_20:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_20
@LBB0_13:
  vmovaps xmm6, dqword ptr [rsp + 32]
  vmovaps xmm7, dqword ptr [rsp + 48]
  vmovaps xmm8, dqword ptr [rsp + 64]
  vmovaps xmm9, dqword ptr [rsp + 80]
  vmovaps xmm10, dqword ptr [rsp + 96]
  vmovaps xmm11, dqword ptr [rsp + 112]
  vmovaps xmm12, dqword ptr [rsp + 128]
  vmovaps xmm13, dqword ptr [rsp + 144]
  vmovaps xmm14, dqword ptr [rsp + 160]
  vmovaps xmm15, dqword ptr [rsp + 176]
  add rsp, 192
  pop rbx
  pop rdi
  pop rsi
  vzeroupper
  jmp @Exit
@LBB0_18:
  add r10, r9
  mov r11, r10
  jmp @LBB0_19
@Exit:
end;

procedure AMD64MatMulQ80Q80(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const One:TPasLLMUInt16=1;
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if true}
  push rsi
  push rdi
  mov eax, dword ptr [rsp + 64]
  mov r10d, dword ptr [rsp + 56]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  cmp r10d, eax
  jg @LBB0_6
  test r9d, r9d
  jle @LBB0_7
  mov esi, r11d
  sar esi, 5
  and r11d, -32
  lea r11d, [r11 + 2*rsi]
  movsxd r10, r10d
  mov r11d, r11d
  inc eax
  mov rsi, r10
  imul rsi, r11
  add r8, rsi
  vpbroadcastw ymm0, word ptr [rip + One]
@LBB0_3:
  xor esi, esi
  vxorps xmm1, xmm1, xmm1
  xor edi, edi
@LBB0_4:
  vmovdqu ymm2, yword ptr [rdx + rsi]
  vmovdqu ymm3, yword ptr [r8 + rsi]
  vpsignb ymm4, ymm2, ymm2
  vpsignb ymm2, ymm3, ymm2
  vpmaddubsw ymm2, ymm4, ymm2
  vpmaddwd ymm2, ymm2, ymm0
  vcvtdq2ps ymm2, ymm2
  vpinsrw xmm3, xmm0, word ptr [rdx + rsi + 32], 0
  vcvtph2ps xmm3, xmm3
  vpinsrw xmm4, xmm0, word ptr [r8 + rsi + 32], 0
  vcvtph2ps xmm4, xmm4
  vmulss xmm3, xmm4, xmm3
  vbroadcastss ymm3, xmm3
  vfmadd231ps ymm1, ymm2, ymm3
  add edi, 32
  add rsi, 34
  cmp edi, r9d
  jl @LBB0_4
  vextractf128 xmm2, ymm1, 1
  vaddps xmm1, xmm1, xmm2
  vhaddps xmm1, xmm1, xmm1
  vhaddps xmm1, xmm1, xmm1
  vmovss dword ptr [rcx + 4*r10], xmm1
  inc r10
  add r8, r11
  cmp eax, r10d
  jne @LBB0_3
  jmp @LBB0_6
@LBB0_7:
  vxorps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  movsxd rdx, r10d
  lea rcx, [rcx + 4*rdx]
  sub eax, r10d
  inc eax
  xor edx, edx
@LBB0_8:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_8
@LBB0_6:
  pop rdi
  pop rsi
  vzeroupper
{$else}  
  push rsi
  push rdi
  mov eax, dword ptr [rsp + 64]
  mov r10d, dword ptr [rsp + 56]
  lea r11d, [r9 + 31]
  test r9d, r9d
  cmovns r11d, r9d
  mov esi, eax
  sub esi, r10d
  jl @LBB0_15
  test r9d, r9d
  jle @LBB0_6
  mov esi, r11d
  sar esi, 5
  and r11d, -32
  lea r11d, [r11 + 2*rsi]
  movsxd r10, r10d
  mov r11d, r11d
  inc eax
  mov rsi, r10
  imul rsi, r11
  add r8, rsi
  vpbroadcastw ymm0, word ptr [rip + One]
@LBB0_3:
  xor esi, esi
  vxorps xmm1, xmm1, xmm1
  xor edi, edi
@LBB0_4:
  vmovdqu ymm2, yword ptr [rdx + rsi]
  vmovdqu ymm3, yword ptr [r8 + rsi]
  vpsignb ymm4, ymm2, ymm2
  vpsignb ymm2, ymm3, ymm2
  vpmaddubsw ymm2, ymm4, ymm2
  vpmaddwd ymm2, ymm2, ymm0
  vcvtdq2ps ymm2, ymm2
  vpinsrw xmm3, xmm0, word ptr [rdx + rsi + 32], 0
  vcvtph2ps xmm3, xmm3
  vpinsrw xmm4, xmm0, word ptr [r8 + rsi + 32], 0
  vcvtph2ps xmm4, xmm4
  vmulss xmm3, xmm4, xmm3
  vbroadcastss ymm3, xmm3
  vfmadd231ps ymm1, ymm2, ymm3
  add edi, 32
  add rsi, 34
  cmp edi, r9d
  jl @LBB0_4
  vextractf128 xmm2, ymm1, 1
  vaddps xmm1, xmm1, xmm2
  vhaddps xmm1, xmm1, xmm1
  vhaddps xmm1, xmm1, xmm1
  vmovss dword ptr [rcx + 4*r10], xmm1
  inc r10
  add r8, r11
  cmp eax, r10d
  jne @LBB0_3
  jmp @LBB0_15
@LBB0_6:
  vxorps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  vhaddps xmm0, xmm0, xmm0
  movsxd r9, r10d
  cmp esi, 2
  ja @LBB0_10
  mov r11, r9
  jmp @LBB0_8
@LBB0_10:
  lea rdx, [rsi + 1]
  movabs r8, 8589934560
  cmp esi, 31
  jae @LBB0_16
  xor r10d, r10d
  jmp @LBB0_12
@LBB0_16:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_17:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_17
  cmp rdx, r10
  je @LBB0_15
  test dl, 28
  je @LBB0_20
@LBB0_12:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_13:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_13
  cmp rdx, r8
  jne @LBB0_8
  jmp @LBB0_15
@LBB0_20:
  add r10, r9
  mov r11, r10
@LBB0_8:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_9:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_9
@LBB0_15:
  pop rdi
  pop rsi
  vzeroupper
{$ifend}  
end;

procedure AMD64MatMulF8E5M2F8E5M2(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3f800000); // 1.0
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  sub rsp, 96
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovdqa dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  mov eax, dword ptr [rsp + 152]
  mov r11d, dword ptr [rsp + 144]
  mov r10d, eax
  sub r10d, r11d
  jl @LBB0_15
  test r9d, r9d
  jle @LBB0_6
  movsxd r10, r11d
  mov r11d, r9d
  inc eax
  mov rsi, r10
  imul rsi, r11
  add r8, rsi
  vbroadcastss xmm0, dword ptr [rip + LCPI0_0]
@LBB0_3:
  vxorps xmm1, xmm1, xmm1
  xor esi, esi
  vxorps xmm2, xmm2, xmm2
  vxorps xmm3, xmm3, xmm3
  vxorps xmm4, xmm4, xmm4
@LBB0_4:
  vpmovzxbw ymm5, dqword ptr [rdx + rsi]
  vpmovzxbw ymm6, dqword ptr [rdx + rsi + 16]
  vpsllw ymm5, ymm5, 8
  vcvtph2ps ymm7, xmm5
  vextracti128 xmm5, ymm5, 1
  vcvtph2ps ymm5, xmm5
  vpsllw ymm6, ymm6, 8
  vcvtph2ps ymm8, xmm6
  vextracti128 xmm6, ymm6, 1
  vcvtph2ps ymm6, xmm6
  vpmovzxbw ymm9, dqword ptr [r8 + rsi]
  vpmovzxbw ymm10, dqword ptr [r8 + rsi + 16]
  vpsllw ymm9, ymm9, 8
  vpsllw ymm10, ymm10, 8
  vcvtph2ps ymm11, xmm9
  vfmadd231ps ymm1, ymm7, ymm11
  vextracti128 xmm7, ymm9, 1
  vcvtph2ps ymm7, xmm7
  vcvtph2ps ymm9, xmm10
  vfmadd231ps ymm2, ymm5, ymm7
  vextracti128 xmm5, ymm10, 1
  vcvtph2ps ymm5, xmm5
  vfmadd231ps ymm3, ymm8, ymm9
  vfmadd231ps ymm4, ymm6, ymm5
  add rsi, 32
  cmp esi, r9d
  jl @LBB0_4
  vaddps ymm3, ymm3, ymm4
  vaddps ymm1, ymm2, ymm1
  vaddps ymm1, ymm3, ymm1
  vextractf128 xmm2, ymm1, 1
  vaddps xmm1, xmm1, xmm2
  vdpps xmm1, xmm1, xmm0, 241
  vmovss dword ptr [rcx + 4*r10], xmm1
  inc r10
  add r8, r11
  cmp eax, r10d
  jne @LBB0_3
  jmp @LBB0_15
@LBB0_6:
  vbroadcastss xmm0, dword ptr [rip + LCPI0_0]
  vxorps xmm1, xmm1, xmm1
  vdpps xmm0, xmm1, xmm0, 241
  movsxd r9, r11d
  cmp r10d, 2
  ja @LBB0_10
  mov r11, r9
  jmp @LBB0_8
@LBB0_10:
  lea rdx, [r10 + 1]
{$ifdef fpc}
  movabs r8, 8589934560
{$else}
  mov r8, 8589934560
{$endif}
  cmp r10d, 31
  jae @LBB0_16
  xor r10d, r10d
  jmp @LBB0_12
@LBB0_16:
  mov r10, rdx
  and r10, r8
  vbroadcastss ymm1, xmm0
  lea r11, [rcx + 4*r9]
  add r11, 96
  xor esi, esi
@LBB0_17:
  vmovups yword ptr [r11 + 4*rsi - 96], ymm1
  vmovups yword ptr [r11 + 4*rsi - 64], ymm1
  vmovups yword ptr [r11 + 4*rsi - 32], ymm1
  vmovups yword ptr [r11 + 4*rsi], ymm1
  add rsi, 32
  cmp r10, rsi
  jne @LBB0_17
  cmp rdx, r10
  je @LBB0_15
  test dl, 28
  je @LBB0_20
@LBB0_12:
  add r8, 28
  and r8, rdx
  lea r11, [r8 + r9]
  vbroadcastss xmm1, xmm0
  lea r9, [rcx + 4*r9]
@LBB0_13:
  vmovups dqword ptr [r9 + 4*r10], xmm1
  add r10, 4
  cmp r8, r10
  jne @LBB0_13
  cmp rdx, r8
  jne @LBB0_8
  jmp @LBB0_15
@LBB0_20:
  add r10, r9
  mov r11, r10
@LBB0_8:
  lea rcx, [rcx + 4*r11]
  sub eax, r11d
  inc eax
  xor edx, edx
@LBB0_9:
  vmovss dword ptr [rcx + 4*rdx], xmm0
  inc rdx
  cmp eax, edx
  jne @LBB0_9
@LBB0_15:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  add rsp, 96
  pop rsi
  vzeroupper
 end;
{$endif}

type TMatMulProc=function(const aXOut,aX,aW:Pointer;const aN,aA,aB:TPasLLMInt32):TPasLLMFloat; {$ifdef fpc}ms_abi_default;{$endif}

     TDotProduct=function(const aW:Pointer;const aX:Pointer;const Count:TPasLLMInt32):TPasLLMFloat; {$ifdef fpc}ms_abi_default;{$endif}

     // Unknown, I8, U8, Q3F8, Q6F16, Q7F8, Q40, Q40NL, Q41NL, Q42NL, Q43NL, Q80, F8_E4M3, F8_E5M2, BF16, F16, F32
     TTensorDataTypeMatMulProcMatrix=array[TPasLLMTensorDataType,TPasLLMTensorDataType] of TMatMulProc;
     TTensorDataTypeDotProductMatrix=array[TPasLLMTensorDataType,TPasLLMTensorDataType] of TDotProduct;

var TensorDataTypeMatMulProcMatrix:TTensorDataTypeMatMulProcMatrix;
    TensorDataTypeDotProductMatrix:TTensorDataTypeDotProductMatrix;

procedure InitializeTensorDataTypeMatrices;
var DataTypeX,DataTypeW:TPasLLMTensorDataType;
    MatMulProc:TMatMulProc;
    DotProduct:TDotProduct;
begin
 FillChar(TensorDataTypeMatMulProcMatrix,SizeOf(TTensorDataTypeMatMulProcMatrix),#0);
 FillChar(TensorDataTypeDotProductMatrix,SizeOf(TTensorDataTypeDotProductMatrix),#0);
 for DataTypeX:=Low(TPasLLMTensorDataType) to High(TPasLLMTensorDataType) do begin
  for DataTypeW:=Low(TPasLLMTensorDataType) to High(TPasLLMTensorDataType) do begin
   case DataTypeX of
    TPasLLMTensorDataType.Q80:begin
     case DataTypeW of
      TPasLLMTensorDataType.F8_E5M2:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
        DotProduct:=@AMD64DotProductF8E5M2Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductF8E5M2Q80;
       end;
      end;
      TPasLLMTensorDataType.Q80:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ80Q80;
        DotProduct:=@AMD64DotProductQ80Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ80Q80;
       end;
      end;
      TPasLLMTensorDataType.Q40:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ40Q80;
        DotProduct:=@AMD64DotProductQ40Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ40Q80;
       end;
      end;
      TPasLLMTensorDataType.Q40NL:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ40NLQ80;
        DotProduct:=@AMD64DotProductQ40NLQ80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ40NLQ80;
       end;
      end;
      TPasLLMTensorDataType.Q41NL:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ41NLQ80;
        DotProduct:=@AMD64DotProductQ41NLQ80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ41NLQ80;
       end;
      end;
      TPasLLMTensorDataType.Q42NL:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ42NLQ80;
        DotProduct:=@AMD64DotProductQ42NLQ80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ42NLQ80;
       end;
      end;
      TPasLLMTensorDataType.Q43NL:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ43NLQ80;
        DotProduct:=@AMD64DotProductQ43NLQ80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ43NLQ80;
       end;
      end;
      TPasLLMTensorDataType.Q3F8:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ3F8Q80;
        DotProduct:=@AMD64DotProductQ3F8Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ3F8Q80;
       end;
      end;
      TPasLLMTensorDataType.Q6F16:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
//      DotProduct:=@AMD64DotProductQ6F16Q80;
        DotProduct:=@PascalDotProductQ6F16Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ6F16Q80;
       end;
      end;
      TPasLLMTensorDataType.Q7F8:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
//      DotProduct:=@AMD64DotProductQ7F8Q80;
        DotProduct:=@PascalDotProductQ7F8Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ7F8Q80;
       end;
      end;
      TPasLLMTensorDataType.BF16:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
        DotProduct:=@AMD64DotProductBF16Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductBF16Q80;
       end;
      end;
      TPasLLMTensorDataType.F16:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
        DotProduct:=@AMD64DotProductF16Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductF16Q80;
       end;
      end;
      TPasLLMTensorDataType.F32:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=nil;
        DotProduct:=@AMD64DotProductF32Q80;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductF32Q80;
       end;
      end;
      else begin
       MatMulProc:=nil;
       DotProduct:=nil;
      end;
     end;
    end;
    TPasLLMTensorDataType.F8_E5M2:begin
     case DataTypeW of
      TPasLLMTensorDataType.Q3F8:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulQ3F8F8E5M2;
        DotProduct:=@AMD64DotProductQ3F8F8E5M2;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductQ3F8F8E5M2;
       end;
      end;
      TPasLLMTensorDataType.F8_E5M2:begin
      {$if defined(cpuamd64)}
       if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask or PasLLMCPUFeatures_X86_F16C_Mask) then begin
        MatMulProc:=@AMD64MatMulF8E5M2F8E5M2;
        DotProduct:=@AMD64DotProductF8E5M2F8E5M2;
       end else{$ifend}begin
        MatMulProc:=nil;
        DotProduct:=@PascalDotProductF8E5M2F8E5M2;
       end;
      end;
      else begin
       MatMulProc:=nil;
       DotProduct:=nil;
      end;
     end;
    end;
    else begin
     MatMulProc:=nil;
     DotProduct:=nil;
    end;
   end;
   TensorDataTypeMatMulProcMatrix[DataTypeX,DataTypeW]:=MatMulProc;
   TensorDataTypeDotProductMatrix[DataTypeX,DataTypeW]:=DotProduct;
  end;
 end;
end;

procedure QuantizedMatMul(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aA,aB:TPasLLMInt32);
var Index,Mul:TPasLLMSizeInt;
    MatMulProc:TMatMulProc;
    DotProduct:TDotProduct;
    XQ,WQ:Pointer;
    WDataTypeData:PPasLLMDataTypeData;
begin
 if (aN>0) and (aA>=0) and (aA<=aB) then begin
  MatMulProc:=TensorDataTypeMatMulProcMatrix[aX.fDataType,aW.fDataType];
  if assigned(MatMulProc) then begin
   // Use optimized matrix multiplication procedure
   MatMulProc(aXOut,aX.fValues,aW.fValues,aN,aA,aB);
 //ClearNaNs(@aXOut^[aA],(aB-aA)+1);
  end else begin
   // Otherwise, use a dot product for each output element
   DotProduct:=TensorDataTypeDotProductMatrix[aX.fDataType,aW.fDataType];
   if assigned(DotProduct) then begin
    WDataTypeData:=@PasLLMTensorDataTypes[aW.fDataType];
    Mul:=(aN div WDataTypeData^.GroupSize)*WDataTypeData^.GroupBytes;
    XQ:=aX.fValues;
    WQ:=aW.fValues;
    for Index:=aA to aB do begin
     aXOut^[Index]:={FlushNaNToZero}(DotProduct(@PPasLLMUInt8Array(WQ)^[Index*Mul],XQ,aN));
    end;
   end;
  end;
 end;
end;

constructor TPasLLMModel.Create(const aPasLLM:TPasLLM;const aModelFilePath:TPasLLMUTF8String;const aMaximumSequenceLength:TPasLLMInt32);
type TPasJSONItemStringHashMap=TPasLLMStringHashMap<TPasJSONItem>;
var Index,LayerIndex,ExpertIndex:TPasLLMSizeInt;
    Size,HeaderSize:TPasLLMUInt64;
    TokenizerTokens,TokenizerScores:Pointer;
    TensorDataType:TPasLLMTensorDataType;
    JSONContent,TemporaryString:TPasJSONRawByteString;
    JSONRootItem:TPasJSONItem;
    JSONRootItemObject:TPasJSONItemObject;
    JSONMetaDataItem:TPasJSONItem;
    JSONMetaDataItemObject:TPasJSONItemObject;
    JSONItem:TPasJSONItem;
    JSONItemArray:TPasJSONItemArray;
    Int32DynamicArray:TPasLLMInt32DynamicArray;
    JSONRootItemHashMap:TPasJSONItemStringHashMap;
 // 128000 or [128001, 128008, 128009]
function ParseIntArray(const aString:TPasLLMUTF8String):TPasLLMInt32DynamicArray;
  var Index,Len,CountValues:TPasLLMSizeInt;
     Value:TPasLLMInt32;
     Negative:Boolean;
 begin

  result:=nil;

  Index:=1;
  Len:=length(aString);

  // Skip whitespace
  while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
   inc(Index);
  end;

  if (Index<=Len) and (aString[Index] in ['-','0'..'9']) then begin

   Negative:=(Index<=Len) and (aString[Index]='-');
   if Negative then begin
    inc(Index);
   end;

   // Single integer literal
   Value:=0;
   while (Index<=Len) and (aString[Index] in ['0'..'9']) do begin
    Value:=(Value*10)+(TPasLLMUInt8(AnsiChar(aString[Index]))-Ord('0'));
    inc(Index);
   end;

   if Negative then begin
    Value:=-Value;
   end;

   result:=[Value];

  end else if (Index<=Len) and (aString[Index]='[') then begin

   inc(Index); // Skip the opening bracket

   CountValues:=0; // Initialize the count of values
   //ValueIndex:=0; // Initialize the index for the result array

   while (Index<=Len) and (aString[Index]<>']') do begin

    // Skip whitespace
    while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
     inc(Index);
    end;

    if (Index<=Len) and (aString[Index] in ['-','0'..'9']) then begin

     // Single integer literal

     Negative:=(Index<=Len) and (aString[Index]='-');
     if Negative then begin
      inc(Index);
     end;

     Value:=0;
     while (Index<=Len) and (aString[Index] in ['0'..'9']) do begin
      Value:=(Value*10)+(TPasLLMUInt8(AnsiChar(aString[Index]))-Ord('0'));
      inc(Index);
     end;

     if Negative then begin
      Value:=-Value;
     end;

     inc(CountValues);
     if length(result)<CountValues then begin
      SetLength(result,CountValues*2);
     end;
     result[CountValues-1]:=Value;

     // Skip whitespace
     while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
      inc(Index);
     end;

     if (Index<=Len) and (aString[Index]=',') then begin
      inc(Index); // Skip the comma
     end else begin
      if (Index<=Len) and (aString[Index]=']') then begin
       break; // End of the list
      end else begin
       raise EPasLLMInvalidModel.Create('Invalid integer array literal string: '+aString);
      end;
     end;

    end else begin
     if (Index<=Len) and (aString[Index]=']') then begin
      break;
     end else begin
      raise EPasLLMInvalidModel.Create('Invalid integer array literal string: '+aString);
     end;
    end;

   end;

   SetLength(result,CountValues);

  end else begin
   raise EPasLLMInvalidModel.Create('Invalid integer array literal string: '+aString); // Raise an exception if the string is invalid
  end;

 end;
 function ParseStringArray(const aString:TPasLLMUTF8String):TPasLLMUTF8StringDynamicArray; // "abc" or ["abc","def","ghi"]
 var Index,Len,CountValues:TPasLLMSizeInt;
     ValueString:TPasLLMUTF8String;
     EscapeNext:Boolean;
 begin 
  result:=nil;

  Index:=1;
  Len:=length(aString);

  // Skip whitespace
  while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
   inc(Index);
  end;

  if (Index<=Len) and ((aString[Index]='"') or (aString[Index]='''')) then begin

   // Single string literal

   inc(Index); // Skip the opening quote

   ValueString:='';
   EscapeNext:=false;
   while (Index<=Len) and (EscapeNext or ((aString[Index]<>'"') and (aString[Index]<>''''))) do begin
    if EscapeNext then begin
     case aString[Index] of
      'n':begin
       ValueString:=ValueString+#10;
      end;
      'r':begin
       ValueString:=ValueString+#13;
      end;
      't':begin
       ValueString:=ValueString+#9;
      end;
      '\':begin
       ValueString:=ValueString+'\';
      end;
      '"':begin
       ValueString:=ValueString+'"';
      end;
      else begin
       ValueString:=ValueString+aString[Index];
      end;
     end;
     EscapeNext:=false;
    end else begin
     if aString[Index]='\' then begin
      EscapeNext:=true;
     end else begin
      ValueString:=ValueString+aString[Index];
     end;
    end;
    inc(Index);
   end;

   if (Index>Len) or ((aString[Index]<>'"') and (aString[Index]<>'''')) then begin
    raise EPasLLMInvalidModel.Create('Invalid string array literal string: '+aString);
   end;

   inc(Index); // Skip the closing quote

   SetLength(result,1);
   result[0]:=ValueString;

  end else if (Index<=Len) and (aString[Index]='[') then begin

   inc(Index); // Skip the opening bracket

   CountValues:=0; // Initialize the count of values

   while (Index<=Len) and (aString[Index]<>']') do begin

    // Skip whitespace
    while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
     inc(Index);
    end;

    if (Index<=Len) and ((aString[Index]='"') or (aString[Index]='''')) then begin

     // Single string literal

     inc(Index); // Skip the opening quote

     ValueString:='';
     EscapeNext:=false;
     while (Index<=Len) and ((EscapeNext) or ((aString[Index]<>'"') and (aString[Index]<>''''))) do begin
      if EscapeNext then begin
       case aString[Index] of
        'n':begin 
         ValueString:=ValueString+#10;
        end;
        'r':begin
         ValueString:=ValueString+#13;
        end;
        't':begin
         ValueString:=ValueString+#9;
        end;
        '\':begin
         ValueString:=ValueString+'\';
        end;
        '"':begin
         ValueString:=ValueString+'"';
        end;
        else begin
         ValueString:=ValueString+aString[Index];
        end;
       end;
       EscapeNext:=false;
      end else begin
       if aString[Index]='\' then begin
        EscapeNext:=true;
       end else begin
        ValueString:=ValueString+aString[Index];
       end;
      end;
      inc(Index);
     end;
    end;

    if (Index>Len) or ((aString[Index]<>'"') and (aString[Index]<>'''')) then begin
     raise EPasLLMInvalidModel.Create('Invalid string array literal string: '+aString);
    end;

    inc(Index); // Skip the closing quote
    inc(CountValues);
    if length(result)<CountValues then begin
     SetLength(result,CountValues*2); 
    end;
    result[CountValues-1]:=ValueString;

    // Skip whitespace
    while (Index<=Len) and (aString[Index] in [#0..#32]) do begin
     inc(Index);
    end;

    if (Index<=Len) and (aString[Index]=',') then begin
     inc(Index); // Skip the comma
    end else begin
     if (Index<=Len) and (aString[Index]=']') then begin
      break; // End of the list
     end else begin
      raise EPasLLMInvalidModel.Create('Invalid string array literal string: '+aString);
     end;
    end;
   
   end;

   SetLength(result,CountValues);

  end else begin
   raise EPasLLMInvalidModel.Create('Invalid string array literal string: '+aString); // Raise an exception if the string is invalid
  end;

 end;
 function GetRawTensor(const aName:TPasJSONRawByteString;const aDataType:TPasLLMTensorDataType;const aDimensions:array of TPasLLMSizeInt;out aTensorDataType:TPasLLMTensorDataType):Pointer; overload;
 var Index,ExpectedLength,MaxElements,Dim,Count:TPasLLMSizeInt;
     JSONItem,JSONSubItem,JSONOtherSubItem:TPasJSONItem;
     JSONItemObject:TPasJSONItemObject;
     JSONSubItemArray:TPasJSONItemArray;
     TemporaryString:TPasJSONRawByteString;
     DataType:TPasLLMBaseDataType;
     StartOffset,EndOffset:TPasLLMInt64;
     Shapes:array[0..3] of TPasLLMSizeInt; // Array to hold the shape of the tensor
 begin

  result:=nil;

  aTensorDataType:=fConfiguration.DataType;

  JSONItem:=JSONRootItemHashMap[aName];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin

   JSONItemObject:=TPasJSONItemObject(JSONItem);

   TemporaryString:=TPasJSON.GetString(JSONItemObject.Properties['dtype'],'');
   if TemporaryString='F32' then begin
    DataType:=TPasLLMBaseDataType.F32; // Set the data type to F32
   end else if TemporaryString='F16' then begin
    DataType:=TPasLLMBaseDataType.F16; // Set the data type to F16
   end else if TemporaryString='BF16' then begin
    DataType:=TPasLLMBaseDataType.BF16; // Set the data type to BF16
   end else if TemporaryString='F8_E5M2' then begin
    DataType:=TPasLLMBaseDataType.F8_E5M2; // Set the data type to F8_E5M2
   end else if TemporaryString='F8_E4M3' then begin
    DataType:=TPasLLMBaseDataType.F8_E4M3; // Set the data type to F8_E4M3
   end else if TemporaryString='I64' then begin
    DataType:=TPasLLMBaseDataType.I64; // Set the data type to I64
   end else if TemporaryString='I32' then begin
    DataType:=TPasLLMBaseDataType.I32; // Set the data type to I32
   end else if TemporaryString='I16' then begin
    DataType:=TPasLLMBaseDataType.I16; // Set the data type to I16
   end else if TemporaryString='I8' then begin
    DataType:=TPasLLMBaseDataType.I8; // Set the data type to I8
   end else if TemporaryString='U8' then begin
    DataType:=TPasLLMBaseDataType.U8; // Set the data type to U8
   end else begin
    raise EPasLLMInvalidModel.Create('Invalid tensor data type: '+TemporaryString); // Raise an exception if the data type is invalid
   end;

   ExpectedLength:=1;
   JSONSubItem:=JSONItemObject.Properties['shape'];
   if assigned(JSONSubItem) and (JSONSubItem is TPasJSONItemArray) then begin
    JSONSubItemArray:=TPasJSONItemArray(JSONSubItem);
    Count:=JSONSubItemArray.Count; // Get the count of dimensions in the shape
    if Count>4 then begin
     raise EPasLLMInvalidModel.Create('Invalid tensor shape: '+aName); // Raise an exception if the shape is invalid
    end;
    for Index:=0 to Count-1 do begin
     JSONOtherSubItem:=JSONSubItemArray.Items[Index];
     Shapes[Index]:=TPasJSON.GetInt64(JSONOtherSubItem,0); // Get the shape of the tensor
    end;
    MaxElements:=High(TPasLLMSizeInt);
    for Index:=0 to Count-1 do begin
     if Shapes[Index]=0 then begin
      Dim:=1;
     end else begin
      Dim:=Shapes[Index]; // Get the dimension size
     end;
     if (Dim<0) or (Dim>MaxElements) then begin
      raise EPasLLMInvalidModel.Create('Invalid tensor shape: '+aName); // Raise an exception if the dimension size is invalid
     end;
     ExpectedLength:=ExpectedLength*Dim; // Calculate the expected length of the tensor
     MaxElements:=MaxElements div Dim; // Update the maximum elements to prevent overflow
    end;
   end else begin
    raise EPasLLMInvalidModel.Create('Invalid tensor shape: '+aName); // Raise an exception if the shape is invalid
   end;

   JSONSubItem:=JSONItemObject.Properties['data_offsets'];
   if not (assigned(JSONSubItem) and (JSONSubItem is TPasJSONItemArray)) then begin
    JSONSubItem:=JSONItemObject.Properties['offsets'];
   end;
   if assigned(JSONSubItem) and (JSONSubItem is TPasJSONItemArray) then begin
    JSONSubItemArray:=TPasJSONItemArray(JSONSubItem);
    if JSONSubItemArray.Count<>2 then begin
     raise EPasLLMInvalidModel.Create('Invalid tensor offsets: '+aName); // Raise an exception if the offsets count does not match the shape count
    end;
    StartOffset:=HeaderSize+TPasJSON.GetInt64(JSONSubItemArray.Items[0],0); // Get the start offset of the tensor
    EndOffset:=HeaderSize+TPasJSON.GetInt64(JSONSubItemArray.Items[1],0); // Get the end offset of the tensor
    if (StartOffset<0) or (EndOffset<StartOffset) or (EndOffset>fFileStream.Size) then begin
     raise EPasLLMInvalidModel.Create('Invalid tensor offsets: '+aName); // Raise an exception if the offsets are invalid
    end;
    if (length(aDimensions)>0) and
       (ExpectedLength>0) and
       ((EndOffset-StartOffset)<>(ExpectedLength*PasLLMBaseDataTypes[DataType].Size)) then begin
     raise EPasLLMInvalidModel.Create('Invalid tensor size: '+aName); // Raise an exception if the size does not match the expected length
    end;
    if fFileStream is TMemoryStream then begin
     result:=TMemoryStream(fFileStream).Memory; // Get the memory mapped data pointer from the memory stream
    end else if fFileStream is TPasLLMFileMappedStream then begin
     result:=TPasLLMFileMappedStream(fFileStream).Memory; // Get the memory mapped data pointer from the memory stream
    end else begin
     raise EPasLLMInvalidModel.Create('Invalid tensor offsets: '+aName); // Raise an exception if the file stream type is invalid
     result:=nil; // Make the compiler happy
    end;
    result:=Pointer(TPasLLMPtrUInt(TPasLLMPtrUInt(result)+TPasLLMPtrUInt(StartOffset))); // Set the result pointer to the start offset of the tensor data
   end else begin
    raise EPasLLMInvalidModel.Create('Invalid tensor offsets: '+aName); // Raise an exception if the offsets are invalid
   end;

  end;

 end;
 function GetRawTensor(const aName:TPasJSONRawByteString;const aDataType:TPasLLMTensorDataType;const aD0,aD1,aD2,aD3:TPasLLMSizeInt;out aTensorDataType:TPasLLMTensorDataType):Pointer; overload;
 begin
  result:=GetRawTensor(aName,aDataType,[aD0,aD1,aD2,aD3],TensorDataType);
 end;
 function GetTensor(const aName:TPasJSONRawByteString;const aDataType:TPasLLMTensorDataType;const aDimensions:array of TPasLLMSizeInt):TPasLLMTensor; overload;
 var RawPointer:Pointer;
     TensorDataType:TPasLLMTensorDataType;
 begin
  RawPointer:=GetRawTensor(aName,aDataType,aDimensions,TensorDataType);
  if assigned(RawPointer) then begin
   result:=TPasLLMTensor.Create(RawPointer,aDataType,aDimensions);
  end else begin
   result:=nil;
  end;
 end;
 function GetTensor(const aName:TPasJSONRawByteString;const aDataType:TPasLLMTensorDataType;const aD0,aD1,aD2,aD3:TPasLLMSizeInt):TPasLLMTensor; overload;
 begin
  result:=GetTensor(aName,aDataType,[aD0,aD1,aD2,aD3]);
 end;
{$if defined(LoadModelIntoMemory) and not defined(fpc)}
var FileStream:TFileStream;
    Remain,ToDo:TPasLLMUInt64;
{$ifend}
var Value:TPasLLMInt64;
    StringItems:TPasLLMUTF8StringDynamicArray;
begin

 inherited Create;

 fPasLLM:=aPasLLM; // Store the reference to the PasLLM instance for memory

 fConfiguration:=TPasLLMConfiguration.Create;

 fModelFilePath:=aModelFilePath;

{$ifdef LoadModelIntoMemory}

 fFileStream:=TMemoryStream.Create;

{$ifdef fpc}
 TMemoryStream(fFileStream).LoadFromFile(aModelFilePath);
{$else}
 FileStream:=TFileStream.Create(aModelFilePath,fmOpenRead or fmShareDenyNone);
 try
  FileStream.Seek(0,soBeginning);
  Remain:=FileStream.Size;
  while Remain>0 do begin
   ToDo:=Min(Remain,TPasLLMUInt64(1) shl 20);
   fFileStream.CopyFrom(FileStream,ToDo);
   dec(Remain,ToDo);
  end;
  fFileStream.Seek(0,soBeginning);
 finally
  FreeAndNil(FileStream);
 end;
{$endif}

 fData:=TMemoryStream(fFileStream).Memory; // Get the memory mapped data pointer
 if not assigned(fData) then begin
  raise EPasLLMInvalidModel.Create('Cannot map model file: '+aModelFilePath); // Raise an exception if the memory mapping failed
 end;

{$else}

 fFileStream:=TPasLLMFileMappedStream.Create(aModelFilePath,fmOpenRead or fmShareDenyNone); // Create a file mapped stream for the checkpoint file

 fData:=TPasLLMFileMappedStream(fFileStream).Memory; // Get the memory mapped data pointer
 if not assigned(fData) then begin
  raise EPasLLMInvalidModel.Create('Cannot map model file: '+aModelFilePath);
 end;

{$endif}

 fFileStream.Seek(0,soBeginning);
 fFileStream.ReadBuffer(Size,SizeOf(TPasLLMUInt64));

 if (Size=0) or (Size>(fFileStream.Size-SizeOf(TPasLLMUInt64))) then begin
  raise EPasLLMInvalidModel.Create('Invalid map model file: '+aModelFilePath);
 end;

 fMetaDataHash:=0;
 fTokenEmbeddingTableHash:=0;

 HeaderSize:=Size+SizeOf(TPasLLMUInt64);

 JSONContent:='';
 SetLength(JSONContent,Size);
 fFileStream.ReadBuffer(JSONContent[1],Size);

 if (length(JSONContent)=0) or (JSONContent[1]<>'{') then begin
  raise EPasLLMInvalidModel.Create('Invalid map model file: '+aModelFilePath);
 end;

 fWeights:=TPasLLMModelWeights.Create(self); // Create the weights of the model

 JSONRootItem:=TPasJSON.Parse(JSONContent,[],TPasJSONEncoding.AutomaticDetection);
 if assigned(JSONRootItem) then begin

  if length(JSONContent)>0 then begin
   fMetaDataHash:=TPasLLMHashRapidHash.Process(@JSONContent[1],length(JSONContent));
  end else begin
   fMetaDataHash:=0; 
  end; 

  try

   if JSONRootItem is TPasJSONItemObject then begin

    JSONRootItemObject:=TPasJSONItemObject(JSONRootItem);

    JSONRootItemHashMap:=TPasJSONItemStringHashMap.Create(nil);
    try

     for Index:=0 to JSONRootItemObject.Count-1 do begin
      JSONRootItemHashMap.Add(JSONRootItemObject.Keys[Index],JSONRootItemObject.Values[Index]);
     end;

     JSONMetaDataItem:=JSONRootItemHashMap['__metadata__'];
     if assigned(JSONMetaDataItem) and (JSONMetaDataItem is TPasJSONItemObject) then begin

      JSONMetaDataItemObject:=TPasJSONItemObject(JSONMetaDataItem);

      if not TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['pasllm'],TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['palm'],false)) then begin
       raise EPasLLMInvalidModel.Create('Invalid model file: '+aModelFilePath);
      end;

      fConfiguration.fArchitectureName:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['arch'],''); // Get the architecture name from the metadata

      TemporaryString:=UpperCase(TPasJSON.GetString(JSONMetaDataItemObject.Properties['dtype'],'Q80')); // Get the data type from the metadata
      if TemporaryString='Q3F8' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q3F8;
      end else if TemporaryString='Q6F16' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q6F16;
      end else if TemporaryString='Q7F8' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q7F8;
      end else if TemporaryString='Q40' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q40;
      end else if TemporaryString='Q40NL' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q40NL;
      end else if TemporaryString='Q41NL' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q41NL;
      end else if TemporaryString='Q42NL' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q42NL;
      end else if TemporaryString='Q43NL' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q43NL;
      end else if TemporaryString='Q80' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.Q80;
      end else if TemporaryString='F8_E4M3' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.F8_E4M3;
      end else if (TemporaryString='F8_E5M2') or (TemporaryString='FP8') then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.F8_E5M2;
      end else if TemporaryString='BF16' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.BF16;
      end else if TemporaryString='F16' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.F16;
      end else if TemporaryString='F32' then begin
       fConfiguration.fDataType:=TPasLLMTensorDataType.F32;
      end else begin
       raise EPasLLMInvalidModel.Create('Invalid data type: '+TemporaryString);
      end;

      fConfiguration.fChatTemplate:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['chat_template'],'');
      fConfiguration.fBOSToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['bos_token'],'');
      fConfiguration.fEOSToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['eos_token'],'');

      fConfiguration.fToolCallBeginToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['tool_call_begin_token'],'');
      fConfiguration.fToolCallEndToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['tool_call_end_token'],'');
      fConfiguration.fToolCallBeginTokenID:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['tool_call_begin_token_id'],-1);
      fConfiguration.fToolCallEndTokenID:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['tool_call_end_token_id'],-1);
      fConfiguration.fToolResponseBeginToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['tool_response_begin_token'],'');
      fConfiguration.fToolResponseEndToken:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['tool_response_end_token'],'');
      fConfiguration.fToolResponseBeginTokenID:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['tool_response_begin_token_id'],-1);
      fConfiguration.fToolResponseEndTokenID:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['tool_response_end_token_id'],-1);

      fConfiguration.fDim:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['dim'],0); // Get the dimension from the metadata
      fConfiguration.fHiddenDim:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['hidden_dim'],0); // Get the hidden dimension from the metadata
      fConfiguration.fExpertHiddenDim:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['expert_hidden_dim'],fConfiguration.fHiddenDim); // Get the expert hidden dimension from the metadata
      fConfiguration.fHeadDim:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['head_dim'],0); // Get the head dimension from the metadata
      fConfiguration.fCountLayers:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['n_layers'],0); // Get the number of query layers from the metadata
      fConfiguration.fCountQueryHeads:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['n_heads'],0); // Get the number of heads from the metadata
      fConfiguration.fCountKeyValueHeads:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['n_kv_heads'],0); // Get the number of key-value heads from the metadata
      fConfiguration.fVocabularySize:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['vocab_size'],0); // Get the vocabulary size from the metadata
      fConfiguration.fMaximumSequenceLength:=Min(TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['max_seq_len'],0),Max(16,aMaximumSequenceLength)); // Get the maximum sequence length from the metadata
      fConfiguration.fBeginOfStreamToken:=ParseIntArray(TPasJSON.GetString(JSONMetaDataItemObject.Properties['bos_token_id'],'')); // Get the beginning of sequence token ID from the metadata
      fConfiguration.fEndOfStreamToken:=ParseIntArray(TPasJSON.GetString(JSONMetaDataItemObject.Properties['eos_token_id'],'')); // Get the end of sequence token ID from the metadata
      fConfiguration.fRoPETheta:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['rope_theta'],500000.0); // Get the RoPE theta from the metadata
      fConfiguration.fRotaryDim:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['rotary_dim'],128); // Get the rotary dimension from the metadata
      fConfiguration.fCountExperts:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['n_experts'],1);
      fConfiguration.fCountActiveExperts:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['n_experts_active'],1);
      fConfiguration.fQKVClip:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['qkv_clip'],Infinity);
      fConfiguration.fQKNormalization:=TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['qk_norm'],false);
      fConfiguration.fQKRMSNormalization:=TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['qk_rmsnorm'],false);
      fConfiguration.fQKRoPENonInterleaved:=TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['qk_rope_noninterleaved'],false);
      fConfiguration.fPostNormalization:=TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['post_norm'],false);
      fConfiguration.fRoPENonInterleaved:=TPasJSON.GetBoolean(JSONMetaDataItemObject.Properties['rope_noninterleaved'],false);
      fConfiguration.fNormalizationEpsilon:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['norm_eps'],1e-05); // Get the normalization epsilon from the metadata
      fConfiguration.fQueryPreAttentionScalar:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['query_pre_attn_scalar'],0.0); // 0.0 => disabled
      fConfiguration.fAttnLogitSoftcapping:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['attn_logit_softcapping'],0.0); // 0.0 => disabled
      fConfiguration.fFinalLogitSoftcapping:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['final_logit_softcapping'],0.0); // 0.0

      // Load the inference parameters from the metadata, if available 
      fConfiguration.fTemperature:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['temperature'],fConfiguration.fTemperature);
      fConfiguration.fTopP:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['top_p'],fConfiguration.fTopP);
      fConfiguration.fPenaltyLastN:=TPasJSON.GetInt64(JSONMetaDataItemObject.Properties['penalty_last_n'],fConfiguration.fPenaltyLastN);
      fConfiguration.fPenaltyRepeat:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['penalty_repeat'],fConfiguration.fPenaltyRepeat);
      fConfiguration.fPenaltyFrequency:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['penalty_frequency'],fConfiguration.fPenaltyFrequency);
      fConfiguration.fPenaltyPresence:=TPasJSON.GetNumber(JSONMetaDataItemObject.Properties['penalty_presence'],fConfiguration.fPenaltyPresence);

      TemporaryString:=LowerCase(TPasJSON.GetString(JSONMetaDataItemObject.Properties['positional_encoding'],'rope')); // Get the positional encoding type from the metadata
      if TemporaryString='nope' then begin
       fConfiguration.fPositionalEncoding:=TPasLLMPositionalEncoding.NoPE;
      end else begin
       fConfiguration.fPositionalEncoding:=TPasLLMPositionalEncoding.RoPE; // Default to RoPE if not specified, since older models doesn't have this field, so for backwards compatibility
      end;

      fConfiguration.fPositionalEncodings:=nil;

      JSONItem:=JSONMetaDataItemObject.Properties['no_rope_layers'];
      if assigned(JSONItem) then begin
       if JSONItem is TPasJSONItemArray then begin
        JSONItemArray:=TPasJSONItemArray(JSONItem);
        SetLength(fConfiguration.fPositionalEncodings,fConfiguration.fCountLayers);
        for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin
         if LayerIndex<JSONItemArray.Count then begin
          if TPasJSON.GetBoolean(JSONItemArray.Items[LayerIndex],false) then begin
           fConfiguration.fPositionalEncodings[LayerIndex]:=TPasLLMPositionalEncoding.RoPE;
          end else begin
           fConfiguration.fPositionalEncodings[LayerIndex]:=TPasLLMPositionalEncoding.NoPE;
          end;
         end else begin
          fConfiguration.fPositionalEncodings[LayerIndex]:=fConfiguration.fPositionalEncoding;
         end;
        end;
       end else if JSONItem is TPasJSONItemString then begin
        Int32DynamicArray:=ParseIntArray(TPasJSONItemString(JSONItem).Value);
        try
         if length(Int32DynamicArray)>0 then begin
          SetLength(fConfiguration.fPositionalEncodings,fConfiguration.fCountLayers);
          for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin
           if LayerIndex<length(Int32DynamicArray) then begin
            if Int32DynamicArray[LayerIndex]<>0 then begin
             fConfiguration.fPositionalEncodings[LayerIndex]:=TPasLLMPositionalEncoding.RoPE;
            end else begin
             fConfiguration.fPositionalEncodings[LayerIndex]:=TPasLLMPositionalEncoding.NoPE;
            end;
           end else begin
            fConfiguration.fPositionalEncodings[LayerIndex]:=fConfiguration.fPositionalEncoding;
           end;
          end;
         end;
        finally
         Int32DynamicArray:=nil;
        end;
       end;
      end;

      // SWA
      begin

       // First initialize all layers to use full attention with sliding window size equal to maximum sequence length
       SetLength(fConfiguration.fAttentionTypes,fConfiguration.fCountLayers);
       SetLength(fConfiguration.fSlidingWindowSizes,fConfiguration.fCountLayers);
       for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin
        fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.Full;
        fConfiguration.fSlidingWindowSizes[LayerIndex]:=fConfiguration.fMaximumSequenceLength;
       end;

       // Then override with the values from the metadata if available
       JSONItem:=JSONMetaDataItemObject.Properties['attention_types'];
       if assigned(JSONItem) and (JSONItem is TPasJSONItemString) then begin
        StringItems:=ParseStringArray(TPasJSONItemString(JSONItem).Value);
        try
         if length(StringItems)>0 then begin
          for LayerIndex:=0 to Min(length(StringItems),fConfiguration.fCountLayers)-1 do begin
           if LayerIndex<length(StringItems) then begin
            TemporaryString:=LowerCase(StringItems[LayerIndex]);
            if TemporaryString='full_attention' then begin
             fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.Full;
            end else if TemporaryString='sliding_attention' then begin
             fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.SlidingWindow;
            end else if TemporaryString='no_attention' then begin
             fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.None;
            end else begin
             raise EPasLLMInvalidModel.Create('Invalid attention type: '+TemporaryString);
            end;
           end;
          end;
         end;
        finally
         StringItems:=nil;
        end;
       end else if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
        JSONItemArray:=TPasJSONItemArray(JSONItem);
        for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin
         if LayerIndex<JSONItemArray.Count then begin
          TemporaryString:=LowerCase(TPasJSON.GetString(JSONItemArray.Items[LayerIndex],'full_attention'));
          if TemporaryString='full_attention' then begin
           fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.Full;
          end else if TemporaryString='sliding_attention' then begin
           fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.SlidingWindow;
          end else if TemporaryString='no_attention' then begin
           fConfiguration.fAttentionTypes[LayerIndex]:=TPasLLMAttentionType.None;
          end else begin
           raise EPasLLMInvalidModel.Create('Invalid attention type: '+TemporaryString);
          end;
         end;
        end;
       end;

       JSONItem:=JSONMetaDataItemObject.Properties['sliding_window_sizes'];
       if assigned(JSONItem) and (JSONItem is TPasJSONItemString) then begin
        Int32DynamicArray:=ParseIntArray(TPasJSONItemString(JSONItem).Value);
        try
         if length(Int32DynamicArray)>0 then begin
          for LayerIndex:=0 to Min(length(Int32DynamicArray),fConfiguration.fCountLayers)-1 do begin
           if LayerIndex<length(Int32DynamicArray) then begin
            Value:=Int32DynamicArray[LayerIndex];
            fConfiguration.fSlidingWindowSizes[LayerIndex]:=Min(Value,fConfiguration.fMaximumSequenceLength);
           end;
          end;
         end;
        finally
         Int32DynamicArray:=nil;
        end;
       end else if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
        JSONItemArray:=TPasJSONItemArray(JSONItem);
        for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin
         if LayerIndex<JSONItemArray.Count then begin
          Value:=TPasJSON.GetInt64(JSONItemArray.Items[LayerIndex],fConfiguration.fMaximumSequenceLength);
          if (Value>0) and (Value<=fConfiguration.fMaximumSequenceLength) then begin
           fConfiguration.fSlidingWindowSizes[LayerIndex]:=Value;
          end else begin
           raise EPasLLMInvalidModel.Create('Invalid sliding window size: '+IntToStr(Value));
          end;
         end;
        end;
       end;

       fConfiguration.fSWAType:=TPasLLMSWAType.Standard;
       fConfiguration.fSWAChunkSize:=0; // 0 => fallback to per-layer window size

       JSONItem:=JSONMetaDataItemObject.Properties['swa_type'];
       if assigned(JSONItem) then begin
        TemporaryString:=LowerCase(TPasJSON.GetString(JSONItem,'standard'));
        if TemporaryString='none' then begin
         fConfiguration.fSWAType:=TPasLLMSWAType.None;
        end else if TemporaryString='standard' then begin
         fConfiguration.fSWAType:=TPasLLMSWAType.Standard;
        end else if TemporaryString='chunked' then begin
         fConfiguration.fSWAType:=TPasLLMSWAType.Chunked;
        end else if TemporaryString='symmetric' then begin
         fConfiguration.fSWAType:=TPasLLMSWAType.Symmetric;
        end else begin
         raise EPasLLMInvalidModel.Create('Invalid swa_type: '+TemporaryString);
        end;
       end;

       JSONItem:=JSONMetaDataItemObject.Properties['swa_chunk_size'];
       if assigned(JSONItem) then begin
        Value:=TPasJSON.GetInt64(JSONItem,0);
        if (Value<0) or (Value>fConfiguration.fMaximumSequenceLength) then begin
         raise EPasLLMInvalidModel.Create('Invalid swa_chunk_size: '+IntToStr(Value));
        end else begin
         fConfiguration.fSWAChunkSize:=Value;
        end;
       end;       

      end;

      TemporaryString:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['norm_type'],'rmsnorm'); // Get the normalization type from the metadata
      if TemporaryString='rmsnorm' then begin
       fConfiguration.fNormalizationType:=TPasLLMNormalizationType.RMSNorm;
      end else if TemporaryString='layernorm' then begin
       fConfiguration.fNormalizationType:=TPasLLMNormalizationType.LayerNorm;
      end else if TemporaryString='layernorm_par' then begin
       fConfiguration.fNormalizationType:=TPasLLMNormalizationType.LayerNormPar;
      end else begin
       raise EPasLLMInvalidModel.Create('Invalid normalization type: '+TemporaryString);
      end;

      TemporaryString:=TPasJSON.GetString(JSONMetaDataItemObject.Properties['act_type'],'silu');
      if TemporaryString='silu' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.SILU;
      end else if (TemporaryString='gelu') or (TemporaryString='gelu_pytorch_tanh') then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.GELU; 
      end else if TemporaryString='xielu' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.XIELU;
      end else if TemporaryString='relu' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.RELU;
      end else if TemporaryString='relu2' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.RELU2;
      end else if TemporaryString='swish' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.SWISH;
      end else if TemporaryString='softplus' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.SoftPlus;
      end else if TemporaryString='mish' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.MISH;
      end else if TemporaryString='linear' then begin
       fConfiguration.fActivationType:=TPasLLMActivationType.LINEAR;   
      end else begin
       raise EPasLLMInvalidModel.Create('Invalid activation type: '+TemporaryString);
      end;

     end else begin
      raise EPasLLMInvalidModel.Create('Invalid model file: '+aModelFilePath);
     end;

     // Get the tensors from the model file

     // Get the embedding weights tensor
     fWeights.fQTokens:=GetTensor('model.embed.weight',
                                  fConfiguration.DataType,
                                  fConfiguration.fVocabularySize,fConfiguration.fDim,0,0);
     if not assigned(fWeights.fQTokens) then begin
      raise EPasLLMInvalidModel.Create('Invalid embedding weights tensor in model file: '+aModelFilePath);
     end;
     GetMem(fWeights.fTokenEmbeddingTable,fConfiguration.fVocabularySize*fConfiguration.fDim*SizeOf(TPasLLMFloat)); // Allocate memory for the dequantized token embedding table
     FillChar(fWeights.fTokenEmbeddingTable^,fConfiguration.fVocabularySize*fConfiguration.fDim*SizeOf(TPasLLMFloat),#0);
     fWeights.fQTokens.Dequantize(Pointer(fWeights.fTokenEmbeddingTable),fConfiguration.fVocabularySize*fConfiguration.fDim); // Dequantize the token embedding table

     fTokenEmbeddingTableHash:=TPasLLMHashRapidHash.Process(Pointer(fWeights.fTokenEmbeddingTable),fConfiguration.fVocabularySize*fConfiguration.fDim*SizeOf(TPasLLMFloat));

     SetLength(fWeights.fRMSAttentionWeights,fConfiguration.fCountLayers); // Initialize the attention weights array
     SetLength(fWeights.fRMSLayerNormalizationWeights,fConfiguration.fCountLayers); // Initialize the layer normalization weights array
     SetLength(fWeights.fRMSQNormalizationWeights,fConfiguration.fCountLayers); // Initialize the layer q normalization weights array
     SetLength(fWeights.fRMSKNormalizationWeights,fConfiguration.fCountLayers); // Initialize the layer k normalization weights array
     SetLength(fWeights.fRMSPreFeedForwardLayerNormWeights,fConfiguration.fCountLayers); // Initialize the pre feedforward layer normalization weights array
     SetLength(fWeights.fRMSPostFeedForwardLayerNormWeights,fConfiguration.fCountLayers); // Initialize the post feedforward layer normalization weights array
     SetLength(fWeights.fRMSFeedForwardLayerNormWeights,fConfiguration.fCountLayers); // Initialize the feedforward layer normalization weights array
     SetLength(fWeights.fWQ,fConfiguration.fCountLayers); // Initialize the WQ weights array
     SetLength(fWeights.fWK,fConfiguration.fCountLayers); // Initialize the WK weights array
     SetLength(fWeights.fWV,fConfiguration.fCountLayers); // Initialize the WV weights array
     SetLength(fWeights.fWO,fConfiguration.fCountLayers); // Initialize the WO weights array
     SetLength(fWeights.fWQBias,fConfiguration.fCountLayers); // Initialize the WQ bias weights array
     SetLength(fWeights.fWKBias,fConfiguration.fCountLayers); // Initialize the WK bias weights array
     SetLength(fWeights.fWVBias,fConfiguration.fCountLayers); // Initialize the WV bias weights array
     if fConfiguration.fActivationType=TPasLLMActivationType.XIELU then begin
      SetLength(fWeights.fActivationFunctionAlphaN,Max(1,fConfiguration.fCountExperts)); // Initialize the activation function alpha n array
      SetLength(fWeights.fActivationFunctionAlphaP,Max(1,fConfiguration.fCountExperts)); // Initialize the activation function alpha p array
      SetLength(fWeights.fActivationFunctionBeta,Max(1,fConfiguration.fCountExperts)); // Initialize the activation function beta array
      SetLength(fWeights.fActivationFunctionEpsilon,Max(1,fConfiguration.fCountExperts)); // Initialize the activation function epsilon array
     end else begin
      fWeights.fActivationFunctionAlphaN:=nil;
      fWeights.fActivationFunctionAlphaP:=nil;
      fWeights.fActivationFunctionBeta:=nil;
      fWeights.fActivationFunctionEpsilon:=nil;
     end;
     SetLength(fWeights.fMixtureOfExpertGate,fConfiguration.fCountLayers); // Initialize the mixture of experts gate weights array
     if Configuration.ActivationType=TPasLLMActivationType.XIELU then begin
      fWeights.fW1:=nil;
     end else begin
      SetLength(fWeights.fW1,Max(1,fConfiguration.fCountExperts),fConfiguration.fCountLayers); // Initialize the W1 weights array
     end;

     SetLength(fWeights.fW2,Max(1,fConfiguration.fCountExperts),fConfiguration.fCountLayers); // Initialize the W2 weights array
     SetLength(fWeights.fW3,Max(1,fConfiguration.fCountExperts),fConfiguration.fCountLayers); // Initialize the W3 weights array

     if fConfiguration.fActivationType=TPasLLMActivationType.XIELU then begin
      if fConfiguration.fCountExperts<=1 then begin
       fWeights.fActivationFunctionAlphaN[0]:=GetRawTensor('model.act_fn_alpha_n',
                                                           TPasLLMTensorDataType.F32,
                                                           fConfiguration.fCountLayers,0,0,0,                                                           
                                                           TensorDataType);
       if not assigned(fWeights.fActivationFunctionAlphaN[0]) then begin 
        raise EPasLLMInvalidModel.Create('Invalid activation function alpha n tensor in model file: '+aModelFilePath);
       end;
       fWeights.fActivationFunctionAlphaP[0]:=GetRawTensor('model.act_fn_alpha_p',
                                                           TPasLLMTensorDataType.F32,
                                                           fConfiguration.fCountLayers,0,0,0,                                                           
                                                           TensorDataType);
       if not assigned(fWeights.fActivationFunctionAlphaP[0]) then begin 
        raise EPasLLMInvalidModel.Create('Invalid activation function alpha p tensor in model file: '+aModelFilePath);
       end;
       fWeights.fActivationFunctionBeta[0]:=GetRawTensor('model.act_fn_beta',
                                                         TPasLLMTensorDataType.F32,
                                                         fConfiguration.fCountLayers,0,0,0,
                                                         TensorDataType);
       if not assigned(fWeights.fActivationFunctionBeta[0]) then begin 
        raise EPasLLMInvalidModel.Create('Invalid activation function beta tensor in model file: '+aModelFilePath);
       end;
       fWeights.fActivationFunctionEpsilon[0]:=GetRawTensor('model.act_fn_eps',
                                                            TPasLLMTensorDataType.F32,
                                                            fConfiguration.fCountLayers,0,0,0,
                                                            TensorDataType);
       if not assigned(fWeights.fActivationFunctionEpsilon[0]) then begin 
        raise EPasLLMInvalidModel.Create('Invalid activation function epsilon tensor in model file: '+aModelFilePath);
       end;
      end else begin
       for ExpertIndex:=0 to fConfiguration.fCountExperts-1 do begin
        fWeights.fActivationFunctionAlphaN[ExpertIndex]:=GetRawTensor('model.experts.'+IntToStr(ExpertIndex)+'.act_fn_alpha_n',
                                                                      TPasLLMTensorDataType.F32,
                                                                      fConfiguration.fCountLayers,0,0,0,
                                                                      TensorDataType);
        if not assigned(fWeights.fActivationFunctionAlphaN[ExpertIndex]) then begin 
         raise EPasLLMInvalidModel.Create('Invalid activation function alpha n tensor in model file: '+aModelFilePath);
        end;
        fWeights.fActivationFunctionAlphaP[ExpertIndex]:=GetRawTensor('model.experts.'+IntToStr(ExpertIndex)+'.act_fn_alpha_p',
                                                                      TPasLLMTensorDataType.F32,
                                                                      fConfiguration.fCountLayers,0,0,0,
                                                                      TensorDataType);
        if not assigned(fWeights.fActivationFunctionAlphaP[ExpertIndex]) then begin 
         raise EPasLLMInvalidModel.Create('Invalid activation function alpha p tensor in model file: '+aModelFilePath);
        end;
        fWeights.fActivationFunctionBeta[ExpertIndex]:=GetRawTensor('model.experts.'+IntToStr(ExpertIndex)+'.act_fn_beta',
                                                                    TPasLLMTensorDataType.F32,
                                                                    fConfiguration.fCountLayers,0,0,0,
                                                                    TensorDataType);
        if not assigned(fWeights.fActivationFunctionBeta[ExpertIndex]) then begin 
         raise EPasLLMInvalidModel.Create('Invalid activation function beta tensor in model file: '+aModelFilePath);
        end;
        fWeights.fActivationFunctionEpsilon[ExpertIndex]:=GetRawTensor('model.experts.'+IntToStr(ExpertIndex)+'.act_fn_eps',
                                                                       TPasLLMTensorDataType.F32,
                                                                       fConfiguration.fCountLayers,0,0,0,
                                                                       TensorDataType);
        if not assigned(fWeights.fActivationFunctionEpsilon[ExpertIndex]) then begin 
         raise EPasLLMInvalidModel.Create('Invalid activation function epsilon tensor in model file: '+aModelFilePath);
        end;
       end;
      end; 
     end; 

     for LayerIndex:=0 to fConfiguration.fCountLayers-1 do begin

      // Get the RMS attention weights tensor
      fWeights.fRMSAttentionWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.norm.weight',
                                                              TPasLLMTensorDataType.F32,
                                                              fConfiguration.fDim,0,0,0,
                                                              TensorDataType);
      if not assigned(fWeights.fRMSAttentionWeights[LayerIndex]) then begin
       raise EPasLLMInvalidModel.Create('Invalid RMS attention weights tensor in model file: '+aModelFilePath);
      end;

      // Get the RMS Q normalization weights tensor (optional, so no exception if not found)
      fWeights.fRMSQNormalizationWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wq_norm.weight',
                                                                   TPasLLMTensorDataType.F32,
                                                                   fConfiguration.fHeadDim,0,0,0,
                                                                   TensorDataType);

      // Get the RMS K normalization weights tensor (optional, so no exception if not found)
      fWeights.fRMSKNormalizationWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wk_norm.weight',
                                                                   TPasLLMTensorDataType.F32,
                                                                   fConfiguration.fHeadDim,0,0,0,
                                                                   TensorDataType);

      // Get the layer normalization weights tensor
      if fConfiguration.fNormalizationType<>TPasLLMNormalizationType.LayerNormPar then begin
       fWeights.fRMSLayerNormalizationWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.norm.weight',
                                                                        TPasLLMTensorDataType.F32,
                                                                        fConfiguration.fDim,0,0,0,
                                                                        TensorDataType);
       if not assigned(fWeights.fRMSLayerNormalizationWeights[LayerIndex]) then begin
        raise EPasLLMInvalidModel.Create('Invalid layer normalization weights tensor in model file: '+aModelFilePath);
       end;
      end else begin
       fWeights.fRMSLayerNormalizationWeights[LayerIndex]:=nil; // Set to nil if not used
      end;

      // Get the pre and post feedforward layer normalization weights tensors (optional, so no exception if not found)
      fWeights.fRMSPreFeedForwardLayerNormWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.pre_feedforward_layernorm.weight',
                                                                            TPasLLMTensorDataType.F32,
                                                                            fConfiguration.fDim,0,0,0,
                                                                            TensorDataType);
      fWeights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.post_feedforward_layernorm.weight',
                                                                             TPasLLMTensorDataType.F32,
                                                                             fConfiguration.fDim,0,0,0,
                                                                             TensorDataType);
      fWeights.fRMSFeedForwardLayerNormWeights[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.ffn.norm.weight',
                                                                         TPasLLMTensorDataType.F32,
                                                                         fConfiguration.fDim,0,0,0,
                                                                         TensorDataType);

      // Get the WQ tensor
      fWeights.fWQ[LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wq.weight',
                                          fConfiguration.fDataType,
                                          fConfiguration.fCountQueryHeads*fConfiguration.fHeadDim,fConfiguration.fDim,0,0);
      if not assigned(fWeights.fWQ[LayerIndex]) then begin
       raise EPasLLMInvalidModel.Create('Invalid WQ tensor in model file: '+aModelFilePath);
      end;

      // Get the WK tensor
      fWeights.fWK[LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wk.weight',
                                          fConfiguration.fDataType,
                                          fConfiguration.fCountKeyValueHeads*fConfiguration.fHeadDim,fConfiguration.fDim,0,0);
      if not assigned(fWeights.fWK[LayerIndex]) then begin
       raise EPasLLMInvalidModel.Create('Invalid WK tensor in model file: '+aModelFilePath);
      end;

      // Get the WV tensor
      fWeights.fWV[LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wv.weight',
                                          fConfiguration.fDataType,
                                          fConfiguration.fCountKeyValueHeads*fConfiguration.fHeadDim,fConfiguration.fDim,0,0);
      if not assigned(fWeights.fWV[LayerIndex]) then begin
       raise EPasLLMInvalidModel.Create('Invalid WV tensor in model file: '+aModelFilePath);
      end;

      // Get the WO tensor
      fWeights.fWO[LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wo.weight',
                                          fConfiguration.fDataType,
                                          fConfiguration.fDim,fConfiguration.fCountQueryHeads*fConfiguration.fHeadDim,0,0);
      if not assigned(fWeights.fWO[LayerIndex]) then begin
       raise EPasLLMInvalidModel.Create('Invalid WO tensor in model file: '+aModelFilePath);
      end;

      // Optional WQKV bias tensors

      // Get the WQ bias tensor
      fWeights.fWQBias[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wq.bias',
                                                 TPasLLMTensorDataType.F32,
                                                 fConfiguration.fCountQueryHeads*fConfiguration.fHeadDim,0,0,0,
                                                 TensorDataType);

      // Get the WK bias tensor
      fWeights.fWKBias[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wk.bias',
                                                 TPasLLMTensorDataType.F32,
                                                 fConfiguration.fCountKeyValueHeads*fConfiguration.fHeadDim,0,0,0,
                                                 TensorDataType);

      // Get the WV bias tensor
      fWeights.fWVBias[LayerIndex]:=GetRawTensor('model.layers.'+IntToStr(LayerIndex)+'.attn.wv.bias',
                                                 TPasLLMTensorDataType.F32,
                                                 fConfiguration.fCountKeyValueHeads*fConfiguration.fHeadDim,0,0,0,
                                                 TensorDataType);

      if fConfiguration.fCountExperts>=2 then begin

       // Get the mixture of experts gate tensor
       fWeights.fMixtureOfExpertGate[LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.moegate.weight',
                                                            fConfiguration.fDataType,
                                                            fConfiguration.fCountExperts,fConfiguration.fDim,0,0);
       if not assigned(fWeights.fMixtureOfExpertGate[LayerIndex]) then begin
        raise EPasLLMInvalidModel.Create('Invalid mixture of experts gate tensor in model file: '+aModelFilePath);
       end;

       for ExpertIndex:=0 to fConfiguration.fCountExperts-1 do begin

        // Get the W1 tensor for each expert
        if Configuration.ActivationType<>TPasLLMActivationType.XIELU then begin
         fWeights.fW1[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.experts.'+IntToStr(ExpertIndex)+'.w1.weight',
                                                         fConfiguration.fDataType,
                                                         fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
         if not assigned(fWeights.fW1[ExpertIndex,LayerIndex]) then begin
          fWeights.fW1[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.experts.'+IntToStr(ExpertIndex)+'.mlp.w1.weight',
                                                          fConfiguration.fDataType,
                                                          fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
         end;
         if not assigned(fWeights.fW1[ExpertIndex,LayerIndex]) then begin
          raise EPasLLMInvalidModel.Create('Invalid W1 tensor in model file: '+aModelFilePath);
         end;
        end;

        // Get the W2 tensor for each expert
        fWeights.fW2[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.experts.'+IntToStr(ExpertIndex)+'.w2.weight',
                                                        fConfiguration.fDataType,
                                                        fConfiguration.fDim,fConfiguration.fExpertHiddenDim,0,0);
        if not assigned(fWeights.fW2[ExpertIndex,LayerIndex]) then begin
         fWeights.fW2[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.experts.'+IntToStr(ExpertIndex)+'.mlp.w2.weight',
                                                         fConfiguration.fDataType,
                                                         fConfiguration.fDim,fConfiguration.fExpertHiddenDim,0,0);
        end;
        if not assigned(fWeights.fW2[ExpertIndex,LayerIndex]) then begin
         raise EPasLLMInvalidModel.Create('Invalid W2 tensor in model file: '+aModelFilePath);
        end;

        // Get the W3 tensor for each expert
        fWeights.fW3[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.experts.'+IntToStr(ExpertIndex)+'.w3.weight',
                                                        fConfiguration.fDataType,
                                                        fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
        if not assigned(fWeights.fW3[ExpertIndex,LayerIndex]) then begin
         fWeights.fW3[ExpertIndex,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.experts.'+IntToStr(ExpertIndex)+'.mlp.w3.weight',
                                                         fConfiguration.fDataType,
                                                         fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
        end;
        if not assigned(fWeights.fW3[ExpertIndex,LayerIndex]) then begin
         raise EPasLLMInvalidModel.Create('Invalid W3 tensor in model file: '+aModelFilePath);
        end;

       end;

      end else begin

       // Get the W1 tensor
       if Configuration.ActivationType<>TPasLLMActivationType.XIELU then begin
        fWeights.fW1[0,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.w1.weight',
                                              fConfiguration.fDataType,
                                              fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
        if not assigned(fWeights.fW1[0,LayerIndex]) then begin
         raise EPasLLMInvalidModel.Create('Invalid W1 tensor in model file: '+aModelFilePath);
        end;
       end;

       // Get the W2 tensor
       fWeights.fW2[0,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.w2.weight',
                                             fConfiguration.fDataType,
                                             fConfiguration.fDim,fConfiguration.fExpertHiddenDim,0,0);
       if not assigned(fWeights.fW2[0,LayerIndex]) then begin
        raise EPasLLMInvalidModel.Create('Invalid W2 tensor in model file: '+aModelFilePath);
       end;

       // Get the W3 tensor
       fWeights.fW3[0,LayerIndex]:=GetTensor('model.layers.'+IntToStr(LayerIndex)+'.mlp.w3.weight',
                                             fConfiguration.fDataType,
                                             fConfiguration.fExpertHiddenDim,fConfiguration.fDim,0,0);
       if not assigned(fWeights.fW3[0,LayerIndex]) then begin
        raise EPasLLMInvalidModel.Create('Invalid W3 tensor in model file: '+aModelFilePath);
       end;

      end;

     end;

     // Get the final RMS weight tensor
     fWeights.fRMSFinalWeights:=GetRawTensor('model.norm.weight',
                                             TPasLLMTensorDataType.F32,
                                             [fConfiguration.fDim,0,0,0],
                                             TensorDataType);
     if not assigned(fWeights.fRMSFinalWeights) then begin
      raise EPasLLMInvalidModel.Create('Invalid final RMS weight tensor in model file: '+aModelFilePath);
     end;

     // Get the output weight tensor
     fWeights.fWCLS:=GetTensor('model.output.weight',
                               fConfiguration.fDataType,
                               fConfiguration.fVocabularySize,fConfiguration.fDim,0,0);
     if not assigned(fWeights.fWCLS) then begin
      fWeights.fWCLS:=fWeights.fQTokens; // If the output weight tensor is not found, use the token embedding table as the output weight
     end;

     // Get the tokenizer tensors from the model file

     // Get the tokenizer tokens tensor
     TokenizerTokens:=GetRawTensor('tokenizer.tokens',
                                   TPasLLMTensorDataType.U8,
                                   [],
                                   TensorDataType);
     if not assigned(TokenizerTokens) then begin
      raise EPasLLMInvalidModel.Create('Invalid tokenizer tokens tensor in model file: '+aModelFilePath);
     end;

     // Get the tokenizer scores tensor
     TokenizerScores:=GetRawTensor('tokenizer.scores',
                                    TPasLLMTensorDataType.U8,
                                    [],
                                    TensorDataType);
     if not assigned(TokenizerScores) then begin
      raise EPasLLMInvalidModel.Create('Invalid tokenizer scores tensor in model file: '+aModelFilePath);
     end;

     fTokenizer:=TPasLLMTokenizer.Create(self,TokenizerTokens,TokenizerScores);

    finally
     FreeAndNil(JSONRootItemHashMap);
    end;

   end else begin
    raise EPasLLMInvalidModel.Create('Invalid model file: '+aModelFilePath);
   end;

  finally
   FreeAndNil(JSONRootItem);
  end;

  fHash:=fMetaDataHash xor fTokenEmbeddingTableHash;

 end else begin
  fHash:=0;
  raise EPasLLMInvalidModel.Create('Invalid model file: '+aModelFilePath);
 end;

end;

destructor TPasLLMModel.Destroy;
begin
 FreeAndNil(fTokenizer);
 FreeAndNil(fWeights); // Free the weights of the model
 FreeAndNil(fFileStream); // Free the file mapped stream
 FreeAndNil(fConfiguration);
 fData:=nil; // Set the data pointer to nil
 inherited Destroy; // Call the inherited destructor
end;

{ TPasLLMTokenizer }

function TPasLLMTokenizerCompareTokenIndex(const a,b:TPasLLMTokenIndex):TPasLLMInt32;
begin
 if a.Str<b.Str then begin
  result:=-1;
 end else if a.Str>b.Str then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

constructor TPasLLMTokenizer.Create(const aModel:TPasLLMModel;const aTokenizerTokens,aTokenizerScores:Pointer);
var Index:TPasLLMSizeInt;
    Len:TPasLLMUInt32;
    s:TPasLLMUTF8String;
    p:PPasLLMUInt8;
begin

 inherited Create;

 fModel:=aModel;

 SetLength(fVocab,fModel.fConfiguration.fVocabularySize); // Set the length of the vocabulary to the vocabulary size from the configuration
 SetLength(fVocabScores,fModel.fConfiguration.fVocabularySize); // Set the length of the vocabulary scores to the vocabulary size from the configuration

 fVocabHashMap:=TPasLLMTokenizerHashMap.Create(-1);

 p:=aTokenizerTokens;

 for Index:=0 to length(fVocab)-1 do begin
  Len:=PPasLLMUInt32(Pointer(p))^; // Read the length of the token string
  inc(p,SizeOf(TPasLLMUInt32)); // Move the pointer to the next
  if Len>0 then begin
   SetLength(s,Len); // Set the length of the token string
   Move(p^,s[1],Len); // Copy the token string from the pointer
   inc(p,Len); // Move the pointer to the next
  end else begin
   s:=''; // If the length is zero, set the token string to an empty string
  end;
  fVocabHashMap.Add(s,Index); // Add the token string to the vocabulary hash map with its index
  fVocab[Index]:=s; // Set the token string in the vocabulary array
  fVocabScores[Index]:=PPasLLMFloat(TPasLLMPointer(TPasLLMPtrUInt(aTokenizerScores)+TPasLLMPtrUInt(Index*SizeOf(TPasLLMFloat))))^; // Read the vocabulary score from the pointer
 end;

 InitializeModel;

end;

destructor TPasLLMTokenizer.Destroy;
begin
 fVocab:=nil;
 fVocabScores:=nil;
//FreeAndNil(fVocabStringTree);
 FreeAndNil(fVocabHashMap);
//fSortedVocab:=nil;
 inherited Destroy;
end;

procedure TPasLLMTokenizer.InitializeModel;
//var Index:TPasLLMSizeInt;
begin

{fSortedVocab:=nil; // Initialize the sorted vocabulary tokens to nil
 SetLength(fSortedVocab,length(fVocab)); // Set the length of the sorted vocabulary tokens to the vocabulary size
 for Index:=0 to length(fVocab)-1 do begin
  fSortedVocab[Index].Str:=fVocab[Index]; // Copy the token string to the sorted vocabulary token
  fSortedVocab[Index].ID:=Index; // Set the ID of the sorted vocabulary token to its index
 end;

 // Create the sorted vocabulary tokens
 if length(fSortedVocab)>0 then begin
  TPasLLMTypedSort<TPasLLMTokenIndex>.IntroSort(@fSortedVocab[0],0,length(fSortedVocab)-1,TPasLLMTokenizerCompareTokenIndex);
 end;}

 if StringLookup('<|im_start|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.CHATML;

  fBOSToken:=StringLookup('<|im_start|>');
  fEOSToken:=StringLookup('<|im_end|>');
  fStartHeaderIDToken:=-1;
  fEOTToken:=StringLookup('<|endoftext|>');

 end else if StringLookup('<|eot_id|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.LLAMA3;

  fBOSToken:=StringLookup('<|begin_of_text|>');
  if fBOSToken<0 then begin
   fBOSToken:=128000;
  end;

  fEOSToken:=StringLookup('<|end_of_text|>');
  if fEOSToken<0 then begin
   fEOSToken:=128001;
  end;

  fStartHeaderIDToken:=StringLookup('<|start_header_id|>');
  if fStartHeaderIDToken<0 then begin
   fStartHeaderIDToken:=128006;
  end;

  fEOTToken:=StringLookup('<|eot_id|>');
  if fEOTToken<0 then begin
   fEOTToken:=128009;
  end;

 end else if StringLookup('<|start_of_turn|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.GEMMA;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end else if StringLookup('<start_of_turn>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.GEMMA2;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end else if StringLookup('<|START_OF_TURN_TOKEN|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.COHERE;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end else if StringLookup('<|assistant|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.PHI3;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end else if StringLookup('<|beginofsystem|>')>=0 then begin

  fModelTemplate:=TPasLLMModelTemplate.K2;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end else begin

  if fModel.fConfiguration.fArchitectureName='minicpm' then begin

   fModelTemplate:=TPasLLMModelTemplate.MINICPM;

  end else begin

   fModelTemplate:=TPasLLMModelTemplate.LLAMA;

  end;

  fBOSToken:=-1;
  fEOSToken:=-1;
  fStartHeaderIDToken:=-1;
  fEOTToken:=-1;

 end;

 // Initialize tool call and response tokens
 fToolCallBeginToken:=StringLookup('<tool_call>');
 fToolCallEndToken:=StringLookup('</tool_call>');
 if (fToolCallBeginToken<0) or (fToolCallEndToken<0) then begin
  fToolCallBeginToken:=StringLookup('<|tool_call_begin|>');
  fToolCallEndToken:=StringLookup('<|tool_call_end|>');
  if (fToolCallBeginToken<0) or (fToolCallEndToken<0) then begin
   fToolCallBeginToken:=StringLookup('<|tool_call|>');
   fToolCallEndToken:=StringLookup('</|tool_call|>');
  end;
 end;

 fToolResponseBeginToken:=StringLookup('<tool_response>');
 fToolResponseEndToken:=StringLookup('</tool_response>');
 if (fToolResponseBeginToken<0) or (fToolResponseEndToken<0) then begin
  fToolResponseBeginToken:=StringLookup('<|tool_output_start|>');
  fToolResponseEndToken:=StringLookup('<|tool_output_end|>');
  if (fToolResponseBeginToken<0) or (fToolResponseEndToken<0) then begin
   fToolResponseBeginToken:=StringLookup('<|tool_response|>');
   fToolResponseEndToken:=StringLookup('</|tool_response|>');
  end;
 end;

 fStartOfThinkToken:=StringLookup('<think>');
 fEndOfThinkToken:=StringLookup('</think>');

 fByteFallbacks:=StringLookup('<0x00>');

 if length(fModel.fConfiguration.fChatTemplate)>0 then begin

  fChatTemplate:=fModel.fConfiguration.fChatTemplate;

 end else begin

  case fModelTemplate of

   TPasLLMModelTemplate.LLAMA3:begin
    fChatTemplate:='{% for message in messages %}'+
                   '<|start_header_id|>{{ message.role }}<|end_header_id|>'#10#10+'{{ message.content }}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}<|start_header_id|>assistant<|end_header_id|>{% endif %}';
   end;

   TPasLLMModelTemplate.CHATML:begin
    fChatTemplate:='{% for message in messages %}'+
                    '<|im_start|>{{ message.role }}'#10+'{{ message.content }}<|im_end|>'#10+
                   '{% endfor %}';
    if (fStartOfThinkToken>=0) and (fEndOfThinkToken>=0) then begin
     fChatTemplate:=fChatTemplate+
                    '{%- if add_generation_prompt %}'+
                     '{{- ''<|im_start|>assistant\n'' }}'+
                      '{%- if enable_thinking is defined and enable_thinking is false %}'+
                      '{{- ''<think>\n\n</think>\n\n'' }}'+
                     '{%- endif %}'+
                    '{%- endif %}';
    end else begin
     fChatTemplate:=fChatTemplate+'{% if add_generation_prompt %}{{ ''<|im_start|>assistant\n'' }}{% endif %}';
    end;
   end;

   TPasLLMModelTemplate.GEMMA:begin
    fChatTemplate:='{% for message in messages %}'+
                   '{% if message.role == ''system'' %}<start_of_turn>user'+#10+'SYSTEM: {{ message.content }}'+#10#10+'<end_of_turn>'#10+
                   '{% elif message.role == ''user'' %}<start_of_turn>user'+#10+'{{ message.content }}<end_of_turn>'#10+
                   '{% elif message.role == ''assistant'' %}<start_of_turn>model'+#10+'{{ message.content }}<end_of_turn>'#10+
                   '{% endif %}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ ''<start_of_turn>model\n'' }}{% endif %}';
   end;

   TPasLLMModelTemplate.COHERE:begin
    fChatTemplate:='{% for message in messages %}'+
                   '{% if message.role == ''system'' %}<|START_OF_TURN_TOKEN|><|SYSTEM_TOKEN|>{{ message.content }}<|END_OF_TURN_TOKEN|>'+
                   '{% elif message.role == ''user'' %}<|START_OF_TURN_TOKEN|><|USER_TOKEN|>{{ message.content }}<|END_OF_TURN_TOKEN|>'+
                   '{% elif message.role == ''assistant'' %}<|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|>{{ message.content }}<|END_OF_TURN_TOKEN|>'+
                   '{% endif %}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ ''<|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|>'' }}{% endif %}';
   end;

   TPasLLMModelTemplate.PHI3:begin
    fChatTemplate:='{% for message in messages %}'+
                   '<|{{ message.role }}|>'#10+'{{ message.content }}<|end|>'#10+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ ''<|assistant|>\n'' }}{% endif %}';
   end;

   TPasLLMModelTemplate.K2:begin
    fChatTemplate:='{% for message in messages %}'+
                   '{% if message.role == ''system'' %}<|beginofsystem|>{{ message.content }}<|endofsystemprompt|>'+
                   '{% elif message.role == ''user'' %}<|beginofuser|>{{ message.content }}'+
                   '{% elif message.role == ''assistant'' %}<|beginofsystem|>{{ message.content }}'+
                   '{% endif %}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ ''<|beginofsystem|>'' }}{% endif %}';
   end;

   TPasLLMModelTemplate.MINICPM:begin
    fChatTemplate:='{% for message in messages %}'+
                   '{% if message.role == ''user'' %}'+#$3c+#$e7+#$94+#$a8+#$e6+#$88+#$b7+#$3e+'{{ message.content }}'+
                   '{% elif message.role == ''assistant'' %}<AI>{{ message.content }}'+
                   '{% endif %}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ ''<AI>'' }}{% endif %}';
   end;

   else {TPasLLMModelTemplate.LLAMA:}begin
    fChatTemplate:='{% for message in messages %}'+
                   '{% if message.role == ''system'' %}[INST] <<SYS>>'#10+'{{ message.content }}'#10+'<</SYS>>'#10#10+
                   '{% elif message.role == ''user'' %}{% if loop.index > 1 %}[INST] {% endif %}{{ message.content }} [/INST]'+
                   '{% elif message.role == ''assistant'' %}{{ message.content }}'+
                   '{% endif %}'+
                   '{% endfor %}'+
                   '{% if add_generation_prompt %}{{ '''' }}{% endif %}';
   end;

  end;

 end;

end;

class function TPasLLMTokenizer.TokenContains(const aTokenIDs:TPasLLMInt32DynamicArray;const aToken:TPasLLMInt32):Boolean;
var Index:TPasLLMSizeInt;
begin
 result:=false;
 for Index:=0 to length(aTokenIDs)-1 do begin
  if aTokenIDs[Index]=aToken then begin
   result:=true; // If the token is found in the array, return true
   exit;
  end;
 end;
end;

function TPasLLMTokenizer.Decode(const aPrevious:TPasLLMUTF8String;const aPreviousToken,aToken:TPasLLMInt32):TPasLLMUTF8String; // Decode the given token into a UTF-8 string, using the previous token for context
var ByteValue,Code:TPasLLMUInt32;
begin
 result:=fVocab[aToken]; // Get the token string from the vocabulary
 if (aPreviousToken=fBOSToken) and (length(result)>0) and (result[1]=' ') then begin
  result:=Copy(result,2,length(result)-1); // Strip leading whitespace if the previous token is BOS (1)
 end else if ((length(aPrevious)>=2) and (aPrevious[length(aPrevious)]='"')) and
             ((length(aPrevious)>=2) and not (aPrevious[length(aPrevious)-1] in [#10,#13,#32])) and
             ((length(result)>=1) and not (result[1] in [#10,#13,#32])) then begin
  // If the previous token ends with a quote and does not end with whitespace, and the current token does not start with whitespace, add
  // a space before the current token, to ensure proper spacing in the output, as the tokenizer vocab data is flawed in this regard, where
  // some tokens are not properly spaced. Therefore this is a workaround to ensure proper spacing in the output.
  result:=' '+result;
 end;
 if (length(result)>=6) and (result[1]='<') and (result[2]='0') and (result[3]='x') and (result[6]='>') then begin
  result:='$'+Copy(result,4,2); // Convert the token string to a hexadecimal representation if it looks like a raw byte
  Val(result,ByteValue,Code); // Convert the hexadecimal string to a byte value
  if Code<>0 then begin
   result:=''; // If the conversion failed, return an empty string
  end else begin
   result:=AnsiChar(TPasLLMUInt8(ByteValue)); // Convert the byte value to an Ansi character
  end;
 end;
end;

function TPasLLMTokenizer.SafeString(const aString:TPasLLMUTF8String):TPasLLMUTF8String; // Ensure the string is safe for processing, removing any invalid characters
begin
 result:=aString;
(*if length(result)=1 then begin
  case TPasLLMUInt8(AnsiChar(result[1])) of
   $09,$0a,$0b,$0c,$0d,$20,
   ord('0')..ord('9'),ord('A')..ord('Z'),ord('a')..ord('z'),
   ord('!'),ord('"'),ord('#'),ord('$'),ord('%'),ord('&'),ord(''''),
   ord('('),ord(')'),ord('*'),ord('+'),ord(','),ord('-'),ord('.'),
   ord('/'),ord(':'),ord(';'),ord('<'),ord('='),ord('>'),ord('?'),
   ord('@'),ord('['),ord('\'),ord(']'),ord('^'),ord('_'),ord('`'),
   ord('{'),ord('|'),ord('}'),ord('~'):begin
    // Do nothing
   end;
   else begin
    result:='';
   end;
  end;
 end; *)
 if result=#0 then begin
  result:='';
 end;
end;

function TPasLLMTokenizer.StringLookup(const aString:TPasLLMUTF8String):TPasLLMInt32; // Lookup the string in the vocabulary and return its ID, or -1 if not found
begin
 result:=fVocabHashMap[aString];
end;
(*var LowIndex,HighIndex,MidIndex:TPasLLMInt32;
    Token:TPasLLMUTF8String;
begin
 result:=-1; // Initialize the result to -1 (not found)
 if length(aString)>0 then begin
  LowIndex:=0; // Initialize the low index to 0
  HighIndex:=Length(fSortedVocab)-1; // Initialize the high index to the last index of the vocabulary
  while LowIndex<=HighIndex do begin // Binary search for the token in the vocabulary
   MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1); // Calculate the middle index
   Token:=fSortedVocab[MidIndex].Str; // Get the token at the middle index
   if aString=Token then begin // If the token matches the input string
    result:=fSortedVocab[MidIndex].ID; // Return the index of the token
    break;
   end else if aString<Token then begin // If the input string is less than the token
    HighIndex:=MidIndex-1; // Search in the lower half
   end else begin // If the input string is greater than the token
    LowIndex:=MidIndex+1; // Search in the upper half
   end;
  end;
 end;
end;*)

// This function is used to get the length of the next token in the string based on the tokenizer's regular expression rules.
// The rules are as follows:
// (?i:'s|'t|'re|'ve|'m|'ll|'d)          // 1 - contractions like 's, 't, 're, 've, 'm, 'll, 'd
// |[^\r\n\p{L}\p{N}]?\p{L}+             // 2 - words starting with a letter, possibly preceded by a non-word character
// |\p{N}{1,3}                           // 3 - numbers with 1 to 3 digits
// | ?[^ \s\p{L}\p{N}]+[\r\n]*           // 4 - non-word characters, possibly followed by whitespace or newlines
// |\s*[\r\n]+                           // 5 - whitespace or newlines
// |\s+(?!\S)                            // 6 - whitespace that is not followed by a non-whitespace character
// |\s+                                  // 7 - whitespace
function TPasLLMTokenizer.GetNextTokenLength(const aString:TPasLLMUTF8String;const aPosition:TPasLLMInt32):TPasLLMInt32; // Lookup the string in the vocabulary and return its ID, or -1 if not found
 function IsNewLine(const aCodePoint:TPasLLMUInt32):boolean; // Check if the code point is a new line
 begin
  result:=(aCodePoint=10) or (aCodePoint=13);
 end;
 function IsWAlpha(const aCodePoint:TPasLLMUInt32):boolean; // Check if the code point is a letter
 begin
  case aCodePoint of
   $0041..$005a, // Basic Latin uppercase A–Z
   $0061..$007a, // Basic Latin lowercase a–z
   $00c0..$00d6, // Latin-1 Supplement À–Ö
   $00d8..$00f6, // Latin-1 Supplement Ø–ö
   $00f8..$00ff, // Latin-1 Supplement ø–ÿ
   $0100..$017f, // Latin Extended-A
   $0180..$024f, // Latin Extended-B
   $0250..$02af, // IPA Extensions
   $02b0..$02b8, // Spacing Modifier Letters
   $02bb..$02c1, // Spacing Modifier Letters
   $02d0..$02d1, // Spacing Modifier Letters
   $02e0..$02e4, // Spacing Modifier Letters
   $0370..$03ff, // Greek and Coptic
   $0400..$04ff, // Cyrillic
   $0500..$052f, // Cyrillic Supplement
   $0531..$058f, // Armenian
   $0590..$05ff, // Hebrew
   $0600..$06ff, // Arabic
   $0750..$077f, // Arabic Supplement
   $0900..$097f, // Devanagari
   $0980..$09ff, // Bengali
   $0a00..$0a7f, // Gurmukhi
   $0a80..$0aff, // Gujarati
   $0b00..$0b7f, // Oriya
   $0b80..$0bff, // Tamil
   $0c00..$0c7f, // Telugu
   $0c80..$0cff, // Kannada
   $0d00..$0d7f, // Malayalam
   $0d80..$0dff, // Sinhala
   $0e00..$0e7f, // Thai
   $0e80..$0eff, // Lao
   $0f00..$0fff, // Tibetan
   $1000..$109f, // Myanmar
   $1100..$11ff, // Hangul Jamo
   $3130..$318f, // Hangul Compatibility Jamo
   $ac00..$d7a3, // Hangul Syllables
   $1200..$137f, // Ethiopic
   $1380..$139f, // Ethiopic Supplement
   $2d80..$2ddf, // Ethiopic Extended
   $13a0..$13ff, // Cherokee
   $1400..$167f, // Unified Canadian Aboriginal Syllabics
   $1680..$169a, // Ogham
   $16a0..$16f0, // Runic
   $1700..$171f, // Tagalog
   $1720..$173f, // Hanunoo
   $1740..$175f, // Buhid
   $1760..$177f, // Tagbanwa
   $1780..$17ff, // Khmer
   $1800..$18af, // Mongolian
   $1900..$194f, // Limbu
   $1950..$197f, // Tai Le
   $1980..$19df, // New Tai Lue
   $1b00..$1b7f, // Balinese
   $1b80..$1bbf, // Sundanese
   $1c00..$1c4f, // Lepcha
   $1c50..$1c7f, // Ol Chiki
   $a880..$a8df, // Saurashtra
   $a900..$a92f, // Kayah Li
   $a930..$a95f, // Rejang
   $a980..$a9df, // Javanese
   $aa00..$aa5f, // Cham
   $abc0..$abff, // Meetei Mayek
   $4e00..$9fff, // CJK Unified Ideographs
   $ff21..$ff3a, // Fullwidth Latin uppercase
   $ff41..$ff5a:begin // Fullwidth Latin lowercase
    result:=true; // It's a letter
   end;
   else begin
    result:=false; // Not a letter
   end;
  end;
 end;
 function IsWDigit(const aCodePoint:TPasLLMUInt32):boolean; // Check if the code point is a digit
 begin
  case aCodePoint of
   $0030..$0039, // Basic Latin digits
   $0660..$0669, // Arabic-Indic digits
   $06f0..$06f9, // Extended Arabic-Indic digits
   $07c0..$07c9, // N'Ko digits
   $0966..$096f, // Devanagari digits
   $09e6..$09ef, // Bengali digits
   $0a66..$0a6f, // Gurmukhi digits
   $0ae6..$0aef, // Gujarati digits
   $0b66..$0b6f, // Oriya digits
   $0be6..$0bef, // Tamil digits
   $0c66..$0c6f, // Telugu digits
   $0ce6..$0cef, // Kannada digits
   $0d66..$0d6f, // Malayalam digits
   $0de6..$0def, // Sinhala Lith digits
   $0e50..$0e59, // Thai digits
   $0ed0..$0ed9, // Lao digits
   $0f20..$0f29, // Tibetan digits
   $1040..$1049, // Myanmar digits
   $1090..$1099, // Shan digits
   $17e0..$17e9, // Khmer digits
   $1810..$1819, // Mongolian digits
   $1946..$194f, // Limbu digits
   $19d0..$19d9, // New Tai Lue digits
   $1a80..$1a89, // Tai Tham Hora digits
   $1a90..$1a99, // Tai Tham Tham digits
   $1b50..$1b59, // Balinese digits
   $1bb0..$1bb9, // Sundanese digits
   $1c40..$1c49, // Lepcha digits
   $1c50..$1c59, // Ol Chiki digits
   $a620..$a629, // Vai digits
   $a8d0..$a8d9, // Saurashtra digits
   $a900..$a909, // Kayah Li digits
   $a9d0..$a9d9, // Javanese digits
   $aa50..$aa59, // Cham digits
   $abf0..$abf9, // Meetei Mayek digits
   $ff10..$ff19:begin // Fullwidth digits
    result:=true; // It's a digit
   end;
   else begin
    result:=false; // Not a digit
   end;
  end;
 end;
 function IsWSpace(const aCodePoint:TPasLLMUInt32):boolean; // Check if the code point is a whitespace character (space, tab, etc.)
 begin
  case aCodePoint of
   $0009..$000d, // C0: HT, LF, VT, FF, CR
   $0020, // SPACE
   $0085, // NEL
   $00a0, // NO-BREAK SPACE
   $1680, // OGHAM SPACE MARK
   $2000..$200a, // EN QUAD…HAIR SPACE
   $2028..$2029, // LINE SEPARATOR, PARAGRAPH SEPARATOR
   $202f, // NARROW NO-BREAK SPACE
   $205f, // MEDIUM MATHEMATICAL SPACE
   $3000:begin // IDEOGRAPHIC SPACE
    result:=true; // It's a whitespace character
   end;
   else begin
    result:=false; // Not a whitespace character
   end;
  end;
 end;
 function IsWHSpace(const aCodePoint:TPasLLMUInt32):boolean; // Check if the code point is a non‑newline whitespace
 begin
  result:=IsWSpace(aCodePoint) and not IsNewLine(aCodePoint);
 end;
var Len,RemainingLength,Position,CurrentPosition,FirstPosition,LastLength,
    CodePointLength,FirstCodePointLength:TPasLLMInt32;
    CodePointValue,FirstCodePointValue:TPasLLMUInt32;
    OK:Boolean;
begin

 result:=0;

 Position:=aPosition; // Start from the given position
 Len:=length(aString);

 RemainingLength:=(Len-Position)+1; // Calculate the remaining length of the string

 if RemainingLength<=0 then begin
  exit;
 end;

 // 1) Contractions: 's, 't, 're, 've, 'm, 'll, 'd
 // Regular expression: /(?i:'s|'t|'re|'ve|'m|'ll|'d)/
 if (Position<=Len) and (aString[Position]='''') then begin
  if ((Position+2)<=Len) and // 3-byte contractions
     ((((aString[Position+1]='r') or (aString[Position+1]='R')) and ((aString[Position+2]='e') or (aString[Position+2]='E'))) or // 're contraction
      (((aString[Position+1]='v') or (aString[Position+1]='V')) and ((aString[Position+2]='e') or (aString[Position+2]='E'))) or // 've contraction
      (((aString[Position+1]='l') or (aString[Position+1]='L')) and ((aString[Position+2]='l') or (aString[Position+2]='L')))) then begin // 'll contraction
   result:=3; // 're, 've, or 'll contraction
   exit;
  end else if ((Position+1)<=Len) and // 2-byte contractions
              (((aString[Position+1]='s') or (aString[Position+1]='S')) or
               ((aString[Position+1]='t') or (aString[Position+1]='T')) or
               ((aString[Position+1]='m') or (aString[Position+1]='M')) or
               ((aString[Position+1]='d') or (aString[Position+1]='D'))) then begin
   result:=2; // 's, 't, 'm, or 'd contraction
   exit;
  end;
 end;

 CurrentPosition:=Position;
 FirstCodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,FirstCodePointValue);
 FirstPosition:=CurrentPosition;

 // 2) Letter-run (with optional one codepoint punctuation prefix)
 // /[^\r\n\p{L}\p{N}]?\p{L}+/
 begin
  CodePointValue:=FirstCodePointValue;
  if IsWAlpha(CodePointValue) then begin
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWAlpha(CodePointValue) then begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end else begin
     break;
    end;
   end;
   exit;
  end else if not (IsNewLine(CodePointValue) or IsWAlpha(CodePointValue) or IsWDigit(CodePointValue)) then begin
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   OK:=false;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWAlpha(CodePointValue) then begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
     OK:=true;
    end else begin
     break;
    end;
   end;
   if OK then begin
    exit;
   end;
  end;
 end;

 // 3) Number run (1–3 digits)
 // Regular expression: /\p{N}{1,3}/
 begin
  CodePointValue:=FirstCodePointValue;
  if IsWDigit(CodePointValue) then begin
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
   if IsWDigit(CodePointValue) then begin
    inc(CurrentPosition,CodePointLength);
    inc(result,CodePointLength);
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWDigit(CodePointValue) then begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end;
   end;
   exit;
  end;
 end;

 // 4) Punctuation cluster (opt. leading space) + trailing CR/LF
 // Regular expression: / ?[^\s\p{L}\p{N}]+[\r\n]*/
 begin
  CodePointValue:=FirstCodePointValue;
  if CodePointValue=32 then begin
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
  end else begin
   CodePointLength:=0;
   CurrentPosition:=Position;
   result:=0;
  end;
  begin
   OK:=false;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWSpace(CodePointValue) or IsWAlpha(CodePointValue) or IsWDigit(CodePointValue) then begin
     break;
    end else begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
     OK:=true;
    end;
   end;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsNewLine(CodePointValue) then begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end else begin
     break;
    end;
   end;
   if OK then begin
    exit;
   end;
  end;

 end;

 // 5) Newline cluster (opt. spaces/tabs before)
 // Regular expression: /\s*[\r\n]+*/
 // Hint: Correct as written – it greedily consumes all whitespace (including CR/LF) and tracks
 //       only the final code point via `OK:=IsNewLine(...)`, ensuring the token ends in one
 //       or more newline characters exactly as PCRE’s backtracking enforces.
 begin
  CodePointValue:=FirstCodePointValue;
  if IsWSpace(CodePointValue) then begin
   OK:=IsNewLine(CodePointValue);
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWSpace(CodePointValue) then begin
     OK:=IsNewLine(CodePointValue);
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end else begin
     break;
    end;
   end;
   if OK then begin
    exit;
   end;
  end;
 end;

 // 6) Whitespace-run until non-whitespace
 // Regular expression: /\s+(?!\S)/
 begin
  CodePointValue:=FirstCodePointValue;
  if IsWSpace(CodePointValue) then begin
   LastLength:=0;
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWSpace(CodePointValue) then begin
     LastLength:=result;
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end else begin
     break;
    end;
   end;
   if CurrentPosition>Len then begin
    exit;
   end else begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWSpace(CodePointValue) then begin
     exit;
    end else if LastLength>0 then begin
     result:=LastLength;
     exit;
    end;
   end;
  end;
 end;

 // 7) Whitespace
 // Regular expression: /\s+/
 begin
  CodePointValue:=FirstCodePointValue;
  if IsWSpace(CodePointValue) then begin
   CodePointLength:=FirstCodePointLength;
   CurrentPosition:=FirstPosition+CodePointLength;
   result:=CodePointLength;
   while CurrentPosition<=Len do begin
    CodePointLength:=GetNextUTF8CharFallback(aString,CurrentPosition,CodePointValue);
    if IsWSpace(CodePointValue) then begin
     inc(CurrentPosition,CodePointLength);
     inc(result,CodePointLength);
    end else begin
     break;
    end;
   end;
   exit;
  end;
 end;

 // 8) Fallback: single code-point
 result:=FirstCodePointLength; // If none of the above matched, return the length of the single code point
 exit;

end;

class procedure TPasLLMTokenizer.MergeHeapSwap(const aHeap:PPasLLMTokenizerMergeArray;const aI,aJ:TPasLLMInt32); // Swap two elements in the heap
var Temp:TPasLLMTokenizerMerge;
begin
 Temp:=aHeap^[aI]; // Store the element at index aI in a temporary variable
 aHeap^[aI]:=aHeap^[aJ]; // Swap the elements at indices aI and aJ
 aHeap^[aJ]:=Temp; // Restore the temporary variable to index aJ
end;

class procedure TPasLLMTokenizer.MergeHeapInsert(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32;const aValue:TPasLLMTokenizerMerge); // Insert a new element into the heap
var Index,Count:TPasLLMInt32;
begin
 Count:=aCount; // Get the current count of elements in the heap

 // Insert the new value at the end of the heap (breaks the heap invariant)
 aHeap^[Count]:=aValue;
 inc(Count);

 // Bubble up the new element to its correct position
 Index:=Count-1; // Start from the last index
 while (Index>0) and (aHeap^[Index].Score>aHeap^[(Index-1) shr 1].Score) do begin // If the score of the current element is greater than its parent
  MergeHeapSwap(aHeap,Index,(Index-1) shr 1); // Swap the current element with its parent
  Index:=(Index-1) shr 1; // Move the index to the parent
 end;

end;

class procedure TPasLLMTokenizer.MergeHeapPop(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32); // Pop the top element from the heap
var Index,Count,ChildIndex:TPasLLMInt32;
begin

 Count:=aCount; // Get the current count of elements in the heap

 // Move the last element to the top (breaks the heap invariant)
 dec(Count); // Decrement the count
 aHeap^[0]:=aHeap^[Count]; // Move the last element to the top

 // Bubble down the new top element to its correct position
 Index:=0; // Start from the top index
 while ((Index shl 1) or 1)<Count do begin // While there is at least one child

  // Find the largest child
  ChildIndex:=Index shl 1; // Left child index
  if (ChildIndex+1)<Count then begin // If there is a right child
   if aHeap^[ChildIndex+1].Score>aHeap^[ChildIndex].Score then begin // If the right child has a greater score than the left child
    inc(ChildIndex); // Use the right child index
   end;
  end;

  // If the largest child is smaller than the parent, we're done
  if aHeap^[ChildIndex].Score<=aHeap^[Index].Score then begin
   break; // Exit the loop if the parent score is greater than or equal to the largest child's score
  end;

  // Otherwise, swap the parent and child
  MergeHeapSwap(aHeap,Index,ChildIndex); // Swap the parent with the largest child

  Index:=ChildIndex; // Move the index to the largest child's index

 end;

end;

function TPasLLMTokenizer.MergeTryAdd(const aHeap:PPasLLMTokenizerMergeArray;const aCount:TPasLLMInt32;const aLeftTokenPosition,aLeftTokenID,aRightTokenPosition,aRightTokenID:TPasLLMInt32):TPasLLMInt32; // Try to add a new token merge to the heap
var TokenID:TPasLLMInt32;
    Merge:TPasLLMTokenizerMerge;
begin
 result:=aCount;
 if (aLeftTokenID>=0) and (aRightTokenID>=0) then begin
  TokenID:=StringLookup(fVocab[aLeftTokenID]+fVocab[aRightTokenID]);
  if TokenID>=0 then begin
   Merge.LeftTokenPosition:=aLeftTokenPosition;
   Merge.LeftTokenID:=aLeftTokenID;
   Merge.RightTokenPosition:=aRightTokenPosition;
   Merge.RightTokenID:=aRightTokenID;
   Merge.ResultTokenID:=TokenID;
   Merge.Score:=fVocabScores[TokenID];
   MergeHeapInsert(aHeap,result,Merge);
   inc(result);
  end;
 end;
end;

function TPasLLMTokenizer.Merge(const aTokens:PPasLLMInt32Array;const aCountToken:TPasLLMSizeInt):TPasLLMSizeInt; // Merge tokens in the given array of tokens
var Heap:TPasLLMTokenizerMergeDynamicArray; // Dynamic array to hold the token merges
    Index,Count:TPasLLMInt32; // Index and count variables
    Merge:TPasLLMTokenizerMerge; // Temporary variable to hold a token merge
begin

 Heap:=nil; // Initialize the heap to nil

 SetLength(Heap,aCountToken shl 1); // Allocate memory for the heap with double the size of the token count

 Count:=0;

 // Insert all initial pairs of tokens into the heap
 for Index:=0 to aCountToken-2 do begin
  Count:=MergeTryAdd(@Heap[0],Count,Index,aTokens^[Index],Index+1,aTokens^[Index+1]);
 end;

 // Merge all pairs of tokens
 while Count>0 do begin // While there are token merges in the heap

  Merge:=Heap[0]; // Get the top element from the heap
  MergeHeapPop(@Heap[0],Count); // Pop the top element from the heap
  dec(Count);

  // Check if the tokens at the left and right positions are still valid
  if (aTokens^[Merge.LeftTokenPosition]=Merge.LeftTokenID) and (aTokens^[Merge.RightTokenPosition]=Merge.RightTokenID) then begin

   // Merge the tokens
   aTokens^[Merge.LeftTokenPosition]:=Merge.ResultTokenID; // Replace the left token with the resulting token ID
   aTokens^[Merge.RightTokenPosition]:=-1; // Mark the right token as invalid

   // We might have new pairs to merge, check the left side
   for Index:=Merge.LeftTokenPosition-1 downto 0 do begin // Iterate backwards
    if aTokens^[Index]>=0 then begin // If the token is valid
     Count:=MergeTryAdd(@Heap[0],Count,Index,aTokens^[Index],Merge.LeftTokenPosition,Merge.ResultTokenID); // Try to add a new token merge to the heap
     break; // Exit the loop after adding the new merge
    end;
   end;

   // Check the right side for new pairs to merge
   for Index:=Merge.RightTokenPosition+1 to aCountToken-1 do begin // Iterate forwards
    if aTokens^[Index]>=0 then begin // If the token is valid
     Count:=MergeTryAdd(@Heap[0],Count,Merge.LeftTokenPosition,Merge.ResultTokenID,Index,aTokens^[Index]); // Try to add a new token merge to the heap
     break; // Exit the loop after adding the new merge
    end;
   end;

  end; // If the tokens at the left and right positions are still valid, continue merging

 end;

 // Compact the tokens array by removing invalid tokens
 result:=0; // Initialize the result count
 for Index:=0 to aCountToken-1 do begin
  if aTokens^[Index]>=0 then begin // If the token is valid
   aTokens^[result]:=aTokens^[Index]; // Move the valid token to the end of the array
   inc(result); // Increment the count of valid tokens
  end;
 end;

 Heap:=nil; // Free the heap memory

end;

// Encode the given string into tokens, optionally adding BOS and EOS tokens
procedure TPasLLMTokenizer.Encode(const aString:TPasLLMUTF8String;const aBOS,aEOS:Boolean;var aTokens:TPasLLMInt32DynamicArray;var aCountToken:TPasLLMSizeInt);
var Position,Len,ScanPosition,ScanLength,UntilPosition,
    SpecialToken,SpecialTokenLength,TokenLength,Token,OtherUntilPosition,
    Index,BestID,BestIndex:TPasLLMInt32;
    CodePoint:TPasLLMUInt32;
    BestScore:TPasLLMFloat;
    OpeningChar,ClosingChar:AnsiChar;
begin

 aCountToken:=0; // If the string is empty, set the token count to 0

 if length(aString)=0 then begin
  exit; // Exit the procedure
 end;

 // Add the BOS token if requested
 if aBOS and ((fBOSToken>=0) or (length(fModel.fConfiguration.fBeginOfStreamToken)>0)) then begin
  if length(aTokens)<=aCountToken then begin
   SetLength(aTokens,(aCountToken+1)*2);
  end;
  if fBOSToken>=0 then begin
   aTokens[aCountToken]:=fBOSToken;
   inc(aCountToken); // Increment the token count
  end else if (length(fModel.fConfiguration.fBeginOfStreamToken)>0) and
              (fModel.fConfiguration.fBeginOfStreamToken[0]>=0) then begin
   aTokens[aCountToken]:=fModel.fConfiguration.fBeginOfStreamToken[0];
   inc(aCountToken); // Increment the token count
  end;
 end;

 Len:=length(aString); // Get the length of the input string

 Position:=1; // Initialize the position to 1
 while Position<=Len do begin

  case fModelTemplate of

   TPasLLMModelTemplate.LLAMA3:begin

    // Scan for next special token like <|token|> for ensuring special tokens are handled correctly in an uninterrupted
    // atomic manner without splitting the string into smaller parts. This is necessary to avoid splitting special tokens
    // like <|endoftext|> or <|startoftext|> which should be treated as a single token and not split into smaller parts.
    ScanPosition:=Position; // Start scanning from the current position
    UntilPosition:=Len+1; // Initialize the until position to the end of the string, when no special token is found
    SpecialToken:=-1; // Initialize the special token to -1 (not found)
    SpecialTokenLength:=0; // Initialize the special token length to 0
    while (ScanPosition+3)<=Len do begin // Minimum length of a special token is 4 characters (<|...|>)
     if ((ScanPosition+1)<=Len) and (aString[ScanPosition]='<') and (aString[ScanPosition+1]='|') then begin
      ScanLength:=2; // Start with the length of the special token
      while ((ScanPosition+ScanLength+1)<=Len) and not ((aString[ScanPosition+ScanLength]='|') and (aString[ScanPosition+ScanLength+1]='>')) do begin
       inc(ScanLength); // Count the length of the special token until the closing pipe character
      end;
      if ((ScanPosition+ScanLength+1)<=Len) and (aString[ScanPosition+ScanLength]='|') and (aString[ScanPosition+ScanLength+1]='>') then begin
       inc(ScanLength,2); // Include the closing pipe and angle bracket in the special token length
       Token:=StringLookup(Copy(aString,ScanPosition,ScanLength)); // Lookup the special token in the vocabulary
       if Token>=0 then begin // If the special token is found in the vocabulary
        UntilPosition:=ScanPosition; // Set the until position to the start of the special token
        SpecialToken:=Token;
        SpecialTokenLength:=ScanLength;
        break; // Exit if valid special token is found
       end else begin
        // If the special token is not found, continue scanning for the next special token
        inc(ScanPosition,2); // Skip just the '<|' characters, for little performance gain
       end;
      end else begin
       // If no valid special token is found, skip the '<|' characters for little performance gain
       inc(ScanPosition,2);
      end;
     end else begin
      inc(ScanPosition); // Move to the next character if no special token is found
     end;
    end;

   end;

   else begin

    if fModelTemplate=TPasLLMModelTemplate.LLAMA then begin
     OpeningChar:='[';
     ClosingChar:=']';
    end else begin
     OpeningChar:='<';
     ClosingChar:='>';
    end;

    // Scan for next special token like <token> for ensuring special tokens are handled correctly in an uninterrupted
    // atomic manner without splitting the string into smaller parts. This is necessary to avoid splitting special tokens
    // like <endoftext> or <startoftext> which should be treated as a single token and not split into smaller parts.
    ScanPosition:=Position; // Start scanning from the current position
    UntilPosition:=Len+1; // Initialize the until position to the end of the string
    SpecialToken:=-1; // Initialize the special token to -1 (not found)
    SpecialTokenLength:=0; // Initialize the special token length to 0
    while (ScanPosition+2)<=Len do begin // Minimum length of a special token is 3 characters (<...>)
     if (aString[ScanPosition]=OpeningChar) then begin
      ScanLength:=1; // Start with the length of the special token
      while ((ScanPosition+ScanLength)<=Len) and not (aString[ScanPosition+ScanLength]=ClosingChar) do begin
       inc(ScanLength); // Count the length of the special token until the closing character
      end;
      if (ScanPosition+ScanLength)<=Len then begin
       inc(ScanLength); // Include the closing angle bracket in the special token length
       Token:=StringLookup(Copy(aString,ScanPosition,ScanLength)); // Lookup the special token in the vocabulary
       if Token>=0 then begin // If the special token is found
        UntilPosition:=ScanPosition; // Set the until position to the start of the special token
        SpecialToken:=Token; // Store the special token ID
        SpecialTokenLength:=ScanLength; // Store the special token length
        break; // Exit if valid special token is found
       end else begin
        // If the special token is not found, continue scanning for the next special token
        inc(ScanPosition); // Skip just the opening character, for little performance gain
       end;
      end else begin
       // If no valid special token is found, skip the opening character for little performance gain
       inc(ScanPosition);
      end;
     end else begin
      inc(ScanPosition); // Move to the next character if no special token is found
     end;
    end;

   end;

  end;

  // Tokenize the string from the current position to the until position (next special token or end of string)
  while Position<UntilPosition do begin

   TokenLength:=GetNextTokenLength(aString,Position);
   if TokenLength>0 then begin
    Token:=StringLookup(copy(aString,Position,TokenLength));
    if Token>=0 then begin
     if length(aTokens)<=aCountToken then begin
      SetLength(aTokens,(aCountToken+1)*2);
     end;
     aTokens[aCountToken]:=Token; // Get the token ID from the vocabulary
     inc(aCountToken); // Increment the token count
     inc(Position,TokenLength); // Move the position forward by the token length
     continue;
    end;
   end;

   // Byte-pair encoding (BPE)
   OtherUntilPosition:=Min(UntilPosition,Position+TokenLength);
   while Position<OtherUntilPosition do begin

    TokenLength:=GetNextUTF8CharFallback(aString,Position,CodePoint);
    if TokenLength>0 then begin

     Token:=StringLookup(copy(aString,Position,TokenLength));
     if Token>=0 then begin

      if length(aTokens)<=aCountToken then begin
       SetLength(aTokens,(aCountToken+1)*2);
      end;
      aTokens[aCountToken]:=Token; // Get the token ID from the vocabulary
      inc(aCountToken); // Increment the token count
      inc(Position,TokenLength); // Move the position forward by the token length

     end else begin

      // If no token is found, use byte fallbacks
      while TokenLength>0 do begin

       if fByteFallbacks>=0 then begin

        Token:=fByteFallbacks+TPasLLMUInt8(AnsiChar(aString[Position])); // Use the byte fallback for unknown characters
        if Token<length(fVocab) then begin
         if length(aTokens)<=aCountToken then begin
          SetLength(aTokens,(aCountToken+1)*2);
         end;
         aTokens[aCountToken]:=Token; // Add the byte fallback token ID to the tokens array
         inc(aCountToken); // Increment the token count
         inc(Position); // Move the position forward by 1 character
         dec(TokenLength);
         continue;
        end;

       end else begin

        Token:=StringLookup(aString[Position]);
        if Token>=0 then begin
         if length(aTokens)<=aCountToken then begin
          SetLength(aTokens,(aCountToken+1)*2);
         end;
         aTokens[aCountToken]:=Token; // Get the token ID from the vocabulary
         inc(aCountToken); // Increment the token count
         inc(Position); // Move the position forward by the token length
         dec(TokenLength);
         continue;
        end;

       end;

       inc(Position); // Skip
       dec(TokenLength);

      end;

     end;

    end else begin
     inc(Position); // Skip
    end;

   end;

  end;

  // If a special token was found before, add it to the tokens array now
  if SpecialToken>=0 then begin
   if length(aTokens)<=aCountToken then begin
    SetLength(aTokens,(aCountToken+1)*2);
   end;
   aTokens[aCountToken]:=SpecialToken; // Add the special token ID to the tokens array
   inc(aCountToken); // Increment the token count
   Position:=UntilPosition+SpecialTokenLength; // Move the position forward by the special token length
   continue; // Skip to the next iteration
  end;

 end;

 // Try to merge tokens if possible
 if aCountToken>1 then begin

  // First attempt with heap-based merging
  aCountToken:=Merge(@aTokens[0],aCountToken); // Merge tokens in the tokens array

  // If heap-based merging didn't reduce the token count, try greedy merging
  if aCountToken>1 then begin
   repeat
    BestScore:=-Infinity;
    BestID:=-1;
    BestIndex:=-1;
    for Index:=0 to aCountToken-2 do begin // Iterate over all tokens except the last one
     Token:=StringLookup(fVocab[aTokens[Index]]+fVocab[aTokens[Index+1]]); // Lookup the combined token in the vocabulary
     if (Token>=0) and (BestScore<fVocabScores[Token]) then begin // If the score of the combined token is better than the best score found so far
      BestScore:=fVocabScores[Token]; // Update the best score
      BestID:=Token; // Update the best token ID
      BestIndex:=Index; // Update the best index
     end;
    end;
    if BestID>=0 then begin // If a best token was found
     // Merge the best token with the next one
     aTokens[BestIndex]:=BestID; // Replace the first token with the combined token ID
     for Index:=BestIndex+1 to aCountToken-2 do begin // Shift the remaining tokens left
      aTokens[Index]:=aTokens[Index+1]; // Move each token one position to the left
     end;
     dec(aCountToken); // Decrement the token count
    end else begin
     break; // If no best token was found, exit the loop
    end;
   until false;
  end;

 end;

 // Add the EOS token if requested
 if aEOS and ((fEOSToken>=0) or (length(fModel.fConfiguration.fEndOfStreamToken)>0)) then begin
  if length(aTokens)<=aCountToken then begin
   SetLength(aTokens,(aCountToken+1)*2);
  end;
  if fEOSToken>=0 then begin
   aTokens[aCountToken]:=fEOSToken;
   inc(aCountToken); // Increment the token count
  end else if (length(fModel.fConfiguration.fEndOfStreamToken)>0) and
              (fModel.fConfiguration.fEndOfStreamToken[0]>=0) then begin
   aTokens[aCountToken]:=fModel.fConfiguration.fEndOfStreamToken[0];
   inc(aCountToken); // Increment the token count
  end;
 end;

{aTokens:=[128000,128006,9125,128007,271,2675,527,264,11919,6369,6465,2663,4997,78,11,279,1888,4333,315,452,710,19870,11,264,3995,5333,11,389,264,40666,13726,12,51174,13,128009,128006,882,128007,271,9906,13,10699,527,499,30,128009,128006,78191,128007];
 aCountToken:=length(aTokens);}

{
 // Dump back as string
 for Index:=0 to aCountToken-1 do begin
  if aTokens[Index]>=0 then begin
   Write(Index,'="',fVocab[aTokens[Index]],'", '); // Write the token to the output
  end;
 end;
 WriteLn; // Write a newline after all tokens}

end;

{ TPasLLMSamplerPenalties }

constructor TPasLLMSamplerPenalties.Create(const aPasLLM:TPasLLM;const aConfiguration:TPasLLMConfiguration);
begin

 inherited Create;

 fPasLLM:=aPasLLM; // Assign the PasLLMinstance
 
 fConfiguration:=aConfiguration; // Assign the configuration
 
 fPenaltyLastN:=aConfiguration.fPenaltyLastN; // Get the penalty for the last N tokens
 if fPenaltyLastN<0 then begin
  fPenaltyLastN:=fConfiguration.fMaximumSequenceLength; // If the penalty is -1, use the full context length
 end else if fPenaltyLastN>=fConfiguration.fMaximumSequenceLength then begin
  fPenaltyLastN:=fConfiguration.fMaximumSequenceLength; // If the penalty is greater than or equal to the context length, use context length
 end;

 fPenaltyRepeat:=fConfiguration.fPenaltyRepeat; // Get the penalty for repeated tokens

 fPenaltyFrequency:=fConfiguration.fPenaltyFrequency; // Get the penalty for frequency of tokens

 fPenaltyPresence:=fConfiguration.fPenaltyPresence; // Get the penalty for presence of tokens

 fPreviousRingBuffer:=TPasLLMRingBufferInt32.Create(Max(1,fPenaltyLastN));

 fTokenCounts:=nil; // Initialize the token counts array to nil
 SetLength(fTokenCounts,aConfiguration.fVocabularySize); // Initialize the token counts array 
 FillChar(fTokenCounts[0],Length(fTokenCounts)*SizeOf(TPasLLMInt32),#0); // Fill the token counts array with zeros

 fTokenBitmap:=nil; // Initialize the token bitmap to nil
 SetLength(fTokenBitmap,(fConfiguration.fVocabularySize+31) shr 5); // Initialize the token bitmap array
 FillChar(fTokenBitmap[0],Length(fTokenBitmap)*SizeOf(TPasLLMUInt32),#0); // Fill the token bitmap array with zeros

end;

destructor TPasLLMSamplerPenalties.Destroy;
begin
 FreeAndNil(fPreviousRingBuffer); // Free the previous ring buffer
 fTokenCounts:=nil; // Clear the token counts array
 fTokenBitmap:=nil; // Clear the token bitmap array
 inherited Destroy; // Call the inherited destructor
end;

procedure TPasLLMSamplerPenalties.Update;
begin

 fPenaltyLastN:=fConfiguration.fPenaltyLastN; // Get the penalty for the last N tokens
 if fPenaltyLastN<0 then begin
  fPenaltyLastN:=fConfiguration.fMaximumSequenceLength; // If the penalty is -1, use the full context length
 end else if fPenaltyLastN>=fConfiguration.fMaximumSequenceLength then begin
  fPenaltyLastN:=fConfiguration.fMaximumSequenceLength; // If the penalty is greater than or equal to the context length, use context length
 end;

 fPenaltyRepeat:=fConfiguration.fPenaltyRepeat; // Get the penalty for repeated tokens

 fPenaltyFrequency:=fConfiguration.fPenaltyFrequency; // Get the penalty for frequency of tokens

 fPenaltyPresence:=fConfiguration.fPenaltyPresence; // Get the penalty for presence of tokens

 if fPreviousRingBuffer.Capacity<>Max(1,fPenaltyLastN) then begin
  FreeAndNil(fPreviousRingBuffer);
  fPreviousRingBuffer:=TPasLLMRingBufferInt32.Create(Max(1,fPenaltyLastN));
 end;

end;

procedure TPasLLMSamplerPenalties.Reset;
begin
 if fPenaltyLastN<>0 then begin
  fPreviousRingBuffer.Clear; // Clear the previous ring buffer
  FillChar(fTokenCounts[0],Length(fTokenCounts)*SizeOf(TPasLLMInt32),#0); // Reset the token counts array to zeros
  FillChar(fTokenBitmap[0],Length(fTokenBitmap)*SizeOf(TPasLLMUInt32),#0); // Reset the token bitmap array to zeros
 end;
end; 

procedure TPasLLMSamplerPenalties.Accept(const aToken:TPasLLMInt32);
var OldToken:TPasLLMInt32;
    BitIndex:TPasLLMUInt32;
begin
 
 if (fPenaltyLastN=0) or (aToken<0) or (aToken>=fConfiguration.fVocabularySize) then begin
  exit; // If the penalty for the last N tokens is 0 or the token is invalid, do nothing
 end;

 // Increment the count for the accepted token
 inc(fTokenCounts[aToken]);

 // Set the bit for the token in the bitmap
 BitIndex:=aToken shr 5; // Calculate the index in the bitmap array
 fTokenBitmap[BitIndex]:=fTokenBitmap[BitIndex] or (TPasLLMUInt32(1) shl (aToken and 31)); // Set the bit for the token in the bitmap

 // If the ring buffer is full, remove the oldest token
 if fPreviousRingBuffer.Count>=fPenaltyLastN then begin
 
  // Pop the oldest token from the ring buffer  
  OldToken:=fPreviousRingBuffer.Pop;
 
  // Decrement the count for the oldest token  
  dec(fTokenCounts[OldToken]); 

  // Clear the bit for the oldest token in the bitmap
  BitIndex:=OldToken shr 5; // Calculate the index in the bitmap array
  fTokenBitmap[BitIndex]:=fTokenBitmap[BitIndex] and not (TPasLLMUInt32(1) shl (OldToken and 31)); // Clear the bit for the oldest token

 end;

 // Push the new token into the ring buffer 
 fPreviousRingBuffer.Push(aToken); 

end; 

procedure TPasLLMSamplerPenalties.Apply(const aProbabilities:PPasLLMFloatArray);
var Index,Token,Count:TPasLLMInt32;
    BitmapValue,BitPosition:TPasLLMUInt32;
begin

 if (fPenaltyLastN=0) or
    ((SameValue(fPenaltyRepeat,1.0)) and (SameValue(fPenaltyFrequency,0.0)) and (SameValue(fPenaltyPresence,0.0))) then begin
  exit; // If no penalties are set, do nothing and save computation time
 end;

 // Apply penalties to the probabilities
 for Index:=0 to length(fTokenBitmap)-1 do begin

  // Get the bitmask for the current index
  BitmapValue:=fTokenBitmap[Index]; 

  // While there are still bits set in the bitmap
  while BitmapValue<>0 do begin 

   // Find the first set bit in the bitmap   
   BitPosition:=TPasMPMath.BitScanForward32(BitmapValue);

   // Clear the bit at the current position
   BitmapValue:=BitmapValue and not (TPasLLMUInt32(1) shl BitPosition); 
   
   // Calculate the token index from the bit position
   Token:=(Index shl 5) or BitPosition;

   // Apply penalties based on the token
   if aProbabilities^[Token]<=0 then begin
    aProbabilities^[Token]:=aProbabilities^[Token]*fPenaltyRepeat;
   end else begin
    aProbabilities^[Token]:=aProbabilities^[Token]/fPenaltyRepeat;
   end;

   // Get the count of the token in the context
   Count:=fTokenCounts[Token]; 

   // Apply frequency and presence penalties
   aProbabilities^[Token]:=aProbabilities^[Token]-((Count*fPenaltyFrequency)+((ord(Count>0) and 1)*fPenaltyPresence)); 

  end;  
 
 end;    

end;

{ TPasLLMSampler }

constructor TPasLLMSampler.Create(const aModelInferenceInstance:TPasLLMModelInferenceInstance);
begin
 inherited Create;
 fModelInferenceInstance:=aModelInferenceInstance;
 fPasLLM:=fModelInferenceInstance.fPasLLM;
 fProbIndex:=nil;
 SetLength(fProbIndex,fModelInferenceInstance.fModel.fConfiguration.fVocabularySize);
 FillChar(fProbIndex[0],Length(fProbIndex)*SizeOf(TPasLLMSamplerProbIndex),#0);
 fTemperature:=fModelInferenceInstance.fModel.fConfiguration.fTemperature; // default temperature from model configuration
 fTopP:=fModelInferenceInstance.fModel.fConfiguration.fTopP; // default top-p from model configuration
end;

destructor TPasLLMSampler.Destroy;
begin
 fProbIndex:=nil;
 inherited Destroy;
end;

procedure TPasLLMSampler.SetTemperature(const aValue:TPasLLMFloat);
begin
 if aValue<0.0 then begin
  fTemperature:=0.0; // Clamp temperature to 0.0 if negative
 end else if aValue>1.0 then begin
  fTemperature:=1.0; // Clamp temperature to 1.0 if greater than 1.0
 end else begin
  fTemperature:=aValue; // Set temperature to the given value
 end;
end;

procedure TPasLLMSampler.SetTopP(const aValue:TPasLLMFloat);
begin
 if aValue<0.0 then begin
  fTopP:=0.0; // Clamp top-p to 0.0 if negative
 end else if aValue>1.0 then begin
  fTopP:=1.0; // Clamp top-p to 1.0 if greater than 1.0
 end else begin
  fTopP:=aValue; // Set top-p to the given value
 end;
end;

// Sample index from probabilities (they must sum to 1!), returns the index of the token with the highest probability
class function TPasLLMSampler.SampleArgMax(const aProbabilities:PPasLLMFloatArray;const aCount:TPasLLMSizeInt):TPasLLMInt32;
var Index:TPasLLMInt32;
    MaxValue:TPasLLMFloat;
begin
 result:=0;
 MaxValue:=aProbabilities^[0];
 for Index:=1 to aCount-1 do begin
  if MaxValue<aProbabilities^[Index] then begin
   MaxValue:=aProbabilities^[Index];
   result:=Index;
  end;
 end;
end;

// Sample index from probabilities (they must sum to 1!), coin is a random number in [0, 1), usually from a random number generator
class function TPasLLMSampler.SampleMulti(const aProbabilities:PPasLLMFloatArray;const aCount:TPasLLMSizeInt;const aCoin:TPasLLMFloat):TPasLLMInt32;
var Index:TPasLLMInt32;
    CDF:TPasLLMFloat;
begin
 result:=aCount-1;
 CDF:=0.0;
 for Index:=0 to aCount-1 do begin
  CDF:=CDF+aProbabilities^[Index];
  if aCoin<CDF then begin
   result:=Index;
   exit;
  end;
 end;
end;

class function TPasLLMSampler.Compare(const aA,aB:TPasLLMSamplerProbIndex):TPasLLMInt32;
begin
 if aA.Probability<aB.Probability then begin
  result:=1;
 end else if aA.Probability>aB.Probability then begin
  result:=-1;
 end else begin
  result:=0; // Equal probabilities
 end;
end;

class function TPasLLMSampler.ParallelCompare(const aA,aB:Pointer):TPasMPInt32; // Compare function for sorting the probability index
begin
 if PPasLLMSamplerProbIndex(aA)^.Probability<PPasLLMSamplerProbIndex(aB)^.Probability then begin
  result:=1;
 end else if PPasLLMSamplerProbIndex(aA)^.Probability>PPasLLMSamplerProbIndex(aB)^.Probability then begin
  result:=-1;
 end else begin
  result:=0; // Equal probabilities
 end;
end;

// Top-P sampling (or "nucleus sampling") samples from the smallest set of tokens that exceed probability `aTopP`.
// This way we never sample tokens that have very low probabilities and are less likely to go "off the rails".
// `aCoin` is a random number in [0, 1), usually from a random number generator.
function TPasLLMSampler.SampleTopP(const aProbabilities:PPasLLMFloatArray;const aTopP:TPasLLMFloat;const aCount:TPasLLMSizeInt;var aPropIndex:TPasLLMSamplerProbIndexDynamicArray;const aCoin:TPasLLMFloat):TPasLLMInt32;
var Index,Count,LastIndex:TPasLLMInt32;
    Cutoff,CumulativeProb,CDF,r:TPasLLMFloat;
    ProbIndex:PPasLLMSamplerProbIndex;
begin

 Count:=0; // Initialize the count of valid tokens

 // Quick sort indices in descending order of probabilities
 // Values smaller than (1 - aTopP) / (aCount - 1) cannot be part of the result
 // so for efficiency we crop these out as candidates before sorting
 Cutoff:=(1.0-aTopP)/(aCount-1); // Calculate the cutoff value for the top-p sampling

 for Index:=0 to aCount-1 do begin
  if aProbabilities^[Index]>=Cutoff then begin // If the probability is above the cutoff
   ProbIndex:=@aPropIndex[Count];
   ProbIndex^.Index:=Index; // Store the index of the token
   ProbIndex^.Probability:=aProbabilities^[Index]; // Store the probability of the token
   inc(Count); // Increment the count of valid tokens
  end;
 end;

 // Sort the valid tokens in descending order of probability
 if Count>1 then begin
  if assigned(fPasLLM.fPasMPInstance) and (Count>=1024) then begin
   fPasLLM.fPasMPInstance.Invoke(
    fPasLLM.fPasMPInstance.ParallelDirectIntroSort(
     @aPropIndex[0],
     0,
     Count-1,
     SizeOf(TPasLLMSamplerProbIndex),
     TPasLLMSampler.ParallelCompare,
     16
    )
   );
  end else begin
   TPasLLMTypedSort<TPasLLMSamplerProbIndex>.IntroSort(@aPropIndex[0],0,Count-1,TPasLLMSampler.Compare);
  end;
 end;

 // Truncate the list where cumulative probability exceeds aTopP
 CumulativeProb:=0.0;
 LastIndex:=Count-1;
 for Index:=0 to Count-1 do begin
  CumulativeProb:=CumulativeProb+aPropIndex[Index].Probability;
  if CumulativeProb>aTopP then begin
   LastIndex:=Index;
   break;
  end;
 end;

 // Sample from the truncated list
 r:=aCoin*CumulativeProb;
 CDF:=0.0;
 for Index:=0 to LastIndex do begin
  ProbIndex:=@aPropIndex[Index];
  CDF:=CDF+ProbIndex^.Probability;
  if r<CDF then begin
   result:=ProbIndex^.Index;
   exit;
  end;
 end;

 // In case of rounding errors, return the last index
 if LastIndex>=0 then begin
  result:=aPropIndex[LastIndex].Index;
 end else begin
  result:=-1;
 end;

end;

class function TPasLLMSampler.SampleProbability(const aProbabilities:PPasLLMFloatArray;const aIndex,aCount:TPasLLMSizeInt):TPasLLMFloat;
var Index:TPasLLMInt32;
    Value,MaxValue,Sum:TPasLLMFloat;
begin
 MaxValue:=-Infinity; // Initialize the maximum value to negative infinity
 for Index:=0 to aCount-1 do begin
  Value:=aProbabilities^[Index];
  if MaxValue<Value then begin // Find the maximum value in the probabilities
   MaxValue:=Value;
  end;
 end;
 Sum:=0.0; // Initialize the sum of probabilities
 for Index:=0 to aCount-1 do begin
  Sum:=Sum+Exp(aProbabilities^[Index]-MaxValue);
 end;
 if IsZero(Sum) then begin
  result:=0.0; // If the sum is zero, return zero probability
 end else begin
  // Calculate the probability of the given index
  result:=Exp(aProbabilities^[aIndex]-MaxValue)/Sum; // Return the probability of the token at the given index
 end;
end;

// Sample the next token based on the logits (probabilities) provided in `aLogits`.
function TPasLLMSampler.Sample(const aLogits:PPasLLMFloatArray):TPasLLMInt32;
var Index,VocabularySize:TPasLLMInt32;
    Coin:TPasLLMFloat;
begin

 VocabularySize:=fModelInferenceInstance.fModel.fConfiguration.fVocabularySize; // Get the vocabulary size from the model configuration

 if IsZero(fTemperature) then begin

  // Greedy argmax sampling: take the token with the highest probability
  result:=SampleArgMax(aLogits,VocabularySize);

 end else begin

  // Apply the temperature to the logits
  for Index:=0 to VocabularySize-1 do begin
   aLogits^[Index]:=aLogits^[Index]/fTemperature; // Scale logits by temperature
  end;

  // Apply softmax to the logits to get the probabilities for next token
  SoftMax(aLogits,VocabularySize);

  // Flip a (float) coin (this is our source of entropy for sampling)
  Coin:=fModelInferenceInstance.fPCG32.GetFloatAbs; // Get a random float in [0, 1)

  // Sample from the distribution to get the next token
  if (fTopP>0.0) and (fTopP<1.0) then begin

   // Top-p (nucleus) sampling, clamping the least likely tokens to zero
   result:=SampleTopP(aLogits,fTopP,VocabularySize,fProbIndex,Coin);

  end else begin

   // Simply sample from the predicted probability distribution
   result:=SampleMulti(aLogits,VocabularySize,Coin);

  end;

 end;

end;

{ TPasLLMModelInferenceInstance.TChatSession.TMCPServer }

constructor TPasLLMModelInferenceInstance.TChatSession.TMCPServer.Create(const aID,aEndpoint,aAuthorization:TPasLLMUTF8String;const aTimeoutMilliseconds:TPasLLMInt32);
begin
 inherited Create;
 fID:=aID;
 fEndpoint:=aEndpoint;
 fAuthorization:=aAuthorization;
 fTimeoutMilliseconds:=aTimeoutMilliseconds;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TMCPServer.Destroy;
begin
 inherited Destroy;
end;

{ TPasLLMModelInferenceInstance.TChatSession.TMCPClient }

constructor TPasLLMModelInferenceInstance.TChatSession.TMCPClient.Create(const aServer:TMCPServer);
begin
 inherited Create;
 fServer:=aServer;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TMCPClient.Destroy;
begin
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.TMCPClient.NextID:TPasLLMUTF8String;
var Counter:TPasLLMUInt64;
begin
 Counter:=TPasLLMUInt64(GetTickCount64);
 result:='pasmcp-'+TPasLLMUTF8String(UInt64ToString(Counter));
end;

function TPasLLMModelInferenceInstance.TChatSession.TMCPClient.InternalHTTPPostJSON(const aRequestJSON:TPasJSONItemObject;out aResponseJSON:TPasJSONItemObject):Boolean;
{$if declared(THTTPSend)}
var HTTPSenderInstance:THTTPSend;
    RequestBodyRaw,ResponseBodyRaw:RawByteString;
    ResponseJSON:TPasJSONItem;
begin
 aResponseJSON:=nil;
 result:=false;
 HTTPSenderInstance:=THTTPSend.Create;
 try
  HTTPSenderInstance.Timeout:=fServer.fTimeoutMilliseconds;
  HTTPSenderInstance.UserAgent:='PasLLM-MCP/1.0';
  HTTPSenderInstance.MimeType:='application/json';
  if length(fServer.fAuthorization)>0 then begin
   HTTPSenderInstance.Headers.Add('Authorization: '+fServer.fAuthorization);
  end;
  RequestBodyRaw:=TPasJSON.Stringify(aRequestJSON,false,[]);
  HTTPSenderInstance.Document.Size:=0;
  if length(RequestBodyRaw)>0 then begin
   HTTPSenderInstance.Document.WriteBuffer(RequestBodyRaw[1],length(RequestBodyRaw));
   HTTPSenderInstance.Document.Seek(0,soBeginning);
  end;
  if HTTPSenderInstance.HTTPMethod('POST',fServer.fEndpoint) then begin
   SetLength(ResponseBodyRaw,HTTPSenderInstance.Document.Size);
   if HTTPSenderInstance.Document.Size>0 then begin
    HTTPSenderInstance.Document.Seek(0,soBeginning);
    HTTPSenderInstance.Document.ReadBuffer(ResponseBodyRaw[1],length(ResponseBodyRaw));
   end;
   ResponseJSON:=TPasJSON.Parse(ResponseBodyRaw);
   if assigned(ResponseJSON) and (ResponseJSON is TPasJSONItemObject) then begin
    aResponseJSON:=TPasJSONItemObject(ResponseJSON);
    result:=true;
   end else begin
    FreeAndNil(ResponseJSON);
    result:=false;
   end;
  end;
 finally
  FreeAndNil(HTTPSenderInstance);
 end;
end;
{$else}
begin
 result:=false;
end;
{$ifend}

function TPasLLMModelInferenceInstance.TChatSession.TMCPClient.RPC(const aMethod:TPasLLMUTF8String;const aParameters:TPasJSONItem):TPasJSONItemObject;
var JSONRequestObject,JSONResponseObject:TPasJSONItemObject;
    JSONItem:TPasJSONItem;
begin
 result:=nil;
 JSONRequestObject:=TPasJSONItemObject.Create;
 try
  JSONRequestObject.Add('jsonrpc',TPasJSONItemString.Create('2.0'));
  JSONRequestObject.Add('id',TPasJSONItemString.Create(NextID));
  JSONRequestObject.Add('method',TPasJSONItemString.Create(aMethod));
  if assigned(aParameters) then begin
   JSONRequestObject.Add('params',aParameters.Clone);
  end else begin
   JSONRequestObject.Add('params',TPasJSONItemObject.Create);
  end;
  if InternalHTTPPostJSON(JSONRequestObject,JSONResponseObject) then begin
   try
    JSONItem:=JSONResponseObject.Properties['error'];
    if not assigned(JSONItem) then begin
     JSONItem:=JSONResponseObject.Properties['result'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      result:=TPasJSONItemObject(JSONItem.Clone);
     end;
    end;
   finally
    FreeAndNil(JSONResponseObject);
   end;
  end;
 finally
  FreeAndNil(JSONRequestObject);
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.TMCPClient.ListTools:TPasJSONItemArray;
var JSONResponseObject:TPasJSONItemObject;
    JSONTools:TPasJSONItem;
begin
 result:=nil;
 JSONResponseObject:=RPC('tools/list',nil);
 if assigned(JSONResponseObject) then begin
  try
   JSONTools:=JSONResponseObject.Properties['tools'];
   if assigned(JSONTools) and (JSONTools is TPasJSONItemArray) then begin
    result:=TPasJSONItemArray(JSONTools.Clone);
   end;
  finally
   FreeAndNil(JSONResponseObject);
  end;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.TMCPClient.CallTool(const aToolName:TPasLLMUTF8String;const aArguments:TPasJSONItem;out aIsError:Boolean):TPasJSONItem;
var JSONParametersObject,JSONResponseObject:TPasJSONItemObject;
    JSONResultItem:TPasJSONItem;
begin
 result:=nil;
 aIsError:=true;
 JSONParametersObject:=TPasJSONItemObject.Create;
 try
  JSONParametersObject.Add('name',TPasJSONItemString.Create(aToolName));
  if assigned(aArguments) then begin
   JSONParametersObject.Add('arguments',aArguments.Clone);
  end else begin
   JSONParametersObject.Add('arguments',TPasJSONItemObject.Create);
  end;
  JSONResponseObject:=RPC('tools/call',JSONParametersObject);
  if assigned(JSONResponseObject) then begin
   try
    aIsError:=TPasJSON.GetBoolean(JSONResponseObject.Properties['isError'],false); // Check if the response indicates an error
    // If you want to extract only the 'content' property from the response, uncomment the following lines
{   begin
     JSONResultItem:=JSONResponseObject.Properties['content'];
     if assigned(JSONResultItem) then begin
      result:=JSONResultItem.Clone;
     end;
    end;}
    // Otherwise just passthrough the full whole response object and let the LLM handle itself (including error handling, when needed) 
    result:=JSONResponseObject.Clone; 
   finally
    FreeAndNil(JSONResponseObject);
   end;
  end;
 finally
  FreeAndNil(JSONParametersObject);
 end;
end;

{ TPasLLMModelInferenceInstance.TChatSession.TMCPToolBinding }

constructor TPasLLMModelInferenceInstance.TChatSession.TMCPToolBinding.Create(const aServerID,aRemoteToolName:TPasLLMUTF8String);
begin
 inherited Create;
 fServerID:=aServerID;
 fRemoteToolName:=aRemoteToolName;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TMCPToolBinding.Destroy;
begin
 inherited Destroy;
end;

{ TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument }

constructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.Create(const aName:TPasLLMUTF8String;const aValue:TPasLLMUTF8String);
begin
 inherited Create;
 fName:=aName;
 fValue:=aValue;
end;

constructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.Create(const aJSON:TPasJSONItem);
var ItemObject:TPasJSONItemObject;
begin 
 inherited Create;
 fName:='';
 fValue:='';
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  ItemObject:=TPasJSONItemObject(aJSON);
  fName:=TPasJSON.GetString(ItemObject.Properties['name'],'');
  fValue:=TPasJSON.GetString(ItemObject.Properties['value'],'');
 end;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.Destroy;
begin
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.ToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 try
  result.Add('name',TPasJSONItemString.Create(fName));
  result.Add('value',TPasJSONItemString.Create(fValue));
 except
  FreeAndNil(result);
  raise;
 end;
end;

{ TPasLLMModelInferenceInstance.TChatSession.TToolCall }

constructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.Create(const aName:TPasLLMUTF8String;const aID:TPasLLMUTF8String;const aArguments:TArguments);
begin
 inherited Create;
 fName:=aName;
 fID:=aID;
 fArguments:=aArguments;
end;

constructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.Create(const aJSON:TPasJSONItem);
var JSONObject:TPasJSONItemObject;
    ArgumentsItem:TPasJSONItem;
    ArgumentsObject:TPasJSONItemObject;
    Index:TPasJSONSizeInt;
    KeyName:TPasLLMUTF8String;
begin
 inherited Create;
 
 fName:='';
 fID:='';
 fArguments:=TArguments.Create;

 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  
  JSONObject:=TPasJSONItemObject(aJSON);

  ArgumentsItem:=nil;

  // Some LLMs add extra spaces, so we trim the keys before comparing
  for Index:=0 to JSONObject.Count-1 do begin
   KeyName:=Trim(JSONObject.Keys[Index]);
   if KeyName='name' then begin
    fName:=TPasJSON.GetString(JSONObject.Values[Index],'');
   end else if KeyName='id' then begin
    fID:=TPasJSON.GetString(JSONObject.Values[Index],'');
   end else if KeyName='arguments' then begin
    ArgumentsItem:=JSONObject.Values[Index];
   end;
  end;
  
  if assigned(ArgumentsItem) and (ArgumentsItem is TPasJSONItemString) then begin
   fArguments.Add(
     TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.Create(
      'arg',
      TPasJSON.GetString(ArgumentsItem,'')
     )
   );
  end else if assigned(ArgumentsItem) and (ArgumentsItem is TPasJSONItemObject) then begin
   ArgumentsObject:=TPasJSONItemObject(ArgumentsItem);
   for Index:=0 to ArgumentsObject.Count-1 do begin
    fArguments.Add(
     TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument.Create(
      Trim(ArgumentsObject.Keys[Index]),
      TPasJSON.GetString(ArgumentsObject.Values[Index],'')
     )
    );
   end;

  end;

 end;

end;

constructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.CreateFromJSONString(const aJSON:TPasLLMUTF8String);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aJSON);
 if assigned(JSON) then begin
  try
   Create(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end else begin
  inherited Create;
  fName:='';
  fID:='';
  fArguments:=nil;
 end; 
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TToolCall.Destroy;
begin
 FreeAndNil(fArguments);
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.TToolCall.ToJSON(const aForChatTemplate:Boolean):TPasJSONItemObject;
var FunctionObject:TPasJSONItemObject;
    ArgumentsObject:TPasJSONItemObject;
    Index:TPasJSONSizeInt;
    Argument:TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument;
begin

 result:=TPasJSONItemObject.Create;
 try

  begin

   result.Add('name',TPasJSONItemString.Create(fName));
   result.Add('id',TPasJSONItemString.Create(fID));

   ArgumentsObject:=TPasJSONItemObject.Create;
   try
    for Index:=0 to fArguments.Count-1 do begin
     Argument:=fArguments[Index];
     if assigned(Argument) then begin
      ArgumentsObject.Add(Argument.Name,TPasJSONItemString.Create(Argument.Value));
     end;
    end;
   finally
    result.Add('arguments',ArgumentsObject);
   end;

  end;

  // And again as an additional function object for some chat templates which are expected in this way.
  if aForChatTemplate then begin

   result.Add('type',TPasJSONItemString.Create('function_call'));

   FunctionObject:=TPasJSONItemObject.Create;
   try

    FunctionObject.Add('name',TPasJSONItemString.Create(fName));
    FunctionObject.Add('id',TPasJSONItemString.Create(fID));

    ArgumentsObject:=TPasJSONItemObject.Create;
    try
     for Index:=0 to fArguments.Count-1 do begin
      Argument:=fArguments[Index];
      if assigned(Argument) then begin
       ArgumentsObject.Add(Argument.Name,TPasJSONItemString.Create(Argument.Value));
      end;
     end;
    finally
     FunctionObject.Add('arguments',ArgumentsObject);
    end;

   finally
    result.Add('function',FunctionObject);
   end;

  end;

 except

  FreeAndNil(result);
  raise;

 end;

end;

function TPasLLMModelInferenceInstance.TChatSession.TToolCall.GetArgumentValue(const aName:TPasLLMUTF8String):TPasLLMUTF8String;
var Index:TPasLLMInt32;
    Argument:TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument;
begin
 for Index:=0 to fArguments.Count-1 do begin
  Argument:=fArguments[Index];
  if assigned(Argument) and (Argument.Name=aName) then begin
   result:=Argument.Value;
   exit;
  end;
 end;
 result:='';
end;

{ TPasLLMModelInferenceInstance.TChatSession.TToolResult }

constructor TPasLLMModelInferenceInstance.TChatSession.TToolResult.Create(const aToolName,aToolCallID,aContent:TPasLLMUTF8String;const aIsError:Boolean);
begin
 inherited Create;
 fToolName:=aToolName;
 fToolCallID:=aToolCallID;
 fContent:=aContent;
 fIsError:=aIsError;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TToolResult.Destroy;
begin
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.TToolResult.ToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 try
  result.Add('toolname',TPasJSONItemString.Create(fToolName));
  result.Add('tool_call_id',TPasJSONItemString.Create(fToolCallID));
  result.Add('content',TPasJSONItemString.Create(fContent));
  result.Add('is_error',TPasJSONItemBoolean.Create(fIsError));
 except
  FreeAndNil(result);
  raise;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.TToolResult.FromJSON(const aJSON:TPasJSONItemObject);
begin

 if assigned(aJSON.Properties['toolname']) and (aJSON.Properties['toolname'] is TPasJSONItemString) then begin
  fToolName:=TPasJSONItemString(aJSON.Properties['toolname']).Value;
 end;

 if assigned(aJSON.Properties['tool_call_id']) and (aJSON.Properties['tool_call_id'] is TPasJSONItemString) then begin
  fToolCallID:=TPasJSONItemString(aJSON.Properties['tool_call_id']).Value;
 end;

 if assigned(aJSON.Properties['content']) and (aJSON.Properties['content'] is TPasJSONItemString) then begin
  fContent:=TPasJSONItemString(aJSON.Properties['content']).Value;
 end;
 
 if assigned(aJSON.Properties['is_error']) and (aJSON.Properties['is_error'] is TPasJSONItemBoolean) then begin
  fIsError:=TPasJSONItemBoolean(aJSON.Properties['is_error']).Value;
 end;

end;

{ TPasLLMModelInferenceInstance.TChatSession.TTool.TArgument }

constructor TPasLLMModelInferenceInstance.TChatSession.TTool.TArgument.Create(const aName:TPasLLMUTF8String;const aDescription:TPasLLMUTF8String;const aExample:TPasLLMUTF8String);
begin
 inherited Create;
 fName:=aName;
 fDescription:=aDescription;
 fExample:=aExample;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TTool.TArgument.Destroy;
begin
 inherited Destroy;
end;

{ TPasLLMModelInferenceInstance.TChatSession.TTool }

constructor TPasLLMModelInferenceInstance.TChatSession.TTool.Create;
begin
 inherited Create;
 fName:='';
 fDescription:='';
 fOnFunctionCall:=nil;
 fOnMethodCall:=nil;
 fArguments:=TArguments.Create(true);
 fEnabled:=true;
 GenerateID;
end;

constructor TPasLLMModelInferenceInstance.TChatSession.TTool.Create(const aName:TPasLLMUTF8String;const aDescription:TPasLLMUTF8String;const aOnFunctionCall:TOnFunctionCall);
begin
 inherited Create;
 fName:=aName;
 fDescription:=aDescription;
 fOnFunctionCall:=aOnFunctionCall;
 fOnMethodCall:=nil;
 fArguments:=TArguments.Create(true);
 fEnabled:=true;
 GenerateID;
end;

constructor TPasLLMModelInferenceInstance.TChatSession.TTool.Create(const aName:TPasLLMUTF8String;const aDescription:TPasLLMUTF8String;const aOnMethodCall:TOnMethodCall);
begin
 inherited Create;
 fName:=aName;
 fDescription:=aDescription;
 fOnFunctionCall:=nil;
 fOnMethodCall:=aOnMethodCall;
 fArguments:=TArguments.Create(true);
 fEnabled:=true;
 fMCPBinding:=nil;
 GenerateID;
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TTool.Destroy;
begin
 FreeAndNil(fMCPBinding);
 FreeAndNil(fArguments);
 inherited Destroy;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.TTool.GenerateID;
const HexChars:array[0..15] of AnsiChar=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
var Value:TPasLLMUInt64;
begin
 // Just use the self pointer value as a unique ID, since it is already unique without need for collision-check
 Value:=TPasLLMPtrUInt(self);
 fID:=HexChars[(Value shr 60) and $0f]+
      HexChars[(Value shr 56) and $0f]+
      HexChars[(Value shr 52) and $0f]+
      HexChars[(Value shr 48) and $0f]+
      HexChars[(Value shr 44) and $0f]+
      HexChars[(Value shr 40) and $0f]+
      HexChars[(Value shr 36) and $0f]+
      HexChars[(Value shr 32) and $0f]+
      HexChars[(Value shr 28) and $0f]+
      HexChars[(Value shr 24) and $0f]+
      HexChars[(Value shr 20) and $0f]+
      HexChars[(Value shr 16) and $0f]+
      HexChars[(Value shr 12) and $0f]+
      HexChars[(Value shr 8) and $0f]+
      HexChars[(Value shr 4) and $0f]+
      HexChars[(Value shr 0) and $0f];
end;

{ TPasLLMModelInferenceInstance.TChatSession.TMessage }

constructor TPasLLMModelInferenceInstance.TChatSession.TMessage.Create(const aRole:TPasLLMUTF8String;aContent:TPasLLMUTF8String);
begin
 inherited Create;
 fRole:=aRole;
 fContent:=aContent;
 fTimeStamp:=Now;
 fToolCalls:=TToolCalls.Create(true);
 fToolCallID:='';
 fToolName:='';
end;

destructor TPasLLMModelInferenceInstance.TChatSession.TMessage.Destroy;
begin
 FreeAndNil(fToolCalls);
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.TMessage.ToJSON(const aForChatTemplate:Boolean):TPasJSONItemObject;
var ToolCallsArray:TPasJSONItemArray;
    Index:TPasLLMInt32;
begin
 result:=TPasJSONItemObject.Create;
 try
  result.Add('role',TPasJSONItemString.Create(fRole));
  result.Add('content',TPasJSONItemString.Create(fContent));
  result.Add('timestamp',TPasJSONItemNumber.Create(fTimeStamp));
  
  if length(fToolName)>0 then begin
   result.Add('toolname',TPasJSONItemString.Create(fToolName));
  end;
  
  if length(fToolCallID)>0 then begin
   result.Add('tool_call_id',TPasJSONItemString.Create(fToolCallID));
  end;
  
  if assigned(fToolCalls) and (fToolCalls.Count>0) then begin
   ToolCallsArray:=TPasJSONItemArray.Create;
   try
    for Index:=0 to fToolCalls.Count-1 do begin
     ToolCallsArray.Add(fToolCalls[Index].ToJSON(aForChatTemplate));
    end;
    result.Add('tool_calls',ToolCallsArray);
   except
    FreeAndNil(ToolCallsArray);
    raise;
   end;
  end;

 except
  FreeAndNil(result);
  raise;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.TMessage.FromJSON(const aJSON:TPasJSONItemObject);
var ToolCallsArray:TPasJSONItemArray;
    ToolCallObject:TPasJSONItemObject;
    ToolCall:TToolCall;
    Index:TPasLLMInt32;
begin

 fRole:=TPasJSON.GetString(aJSON.Properties['role'],'');

 fContent:=TPasJSON.GetString(aJSON.Properties['content'],'');

 fTimeStamp:=TPasJSON.GetNumber(aJSON.Properties['timestamp'],Now);

 fToolName:=TPasJSON.GetString(aJSON.Properties['toolname'],'');
 
 if assigned(aJSON.Properties['tool_call_id']) and (aJSON.Properties['tool_call_id'] is TPasJSONItemString) then begin
  fToolCallID:=TPasJSONItemString(aJSON.Properties['tool_call_id']).Value;
 end;
 
 if assigned(aJSON.Properties['tool_calls']) and (aJSON.Properties['tool_calls'] is TPasJSONItemArray) then begin
  ToolCallsArray:=TPasJSONItemArray(aJSON.Properties['tool_calls']);
  fToolCalls.Clear;
  for Index:=0 to ToolCallsArray.Count-1 do begin
   if assigned(ToolCallsArray.Items[Index]) and (ToolCallsArray.Items[Index] is TPasJSONItemObject) then begin
    ToolCallObject:=TPasJSONItemObject(ToolCallsArray.Items[Index]);
    ToolCall:=TToolCall.Create(ToolCallObject);
    try
     fToolCalls.Add(ToolCall);
    except
     FreeAndNil(ToolCall);
     raise;
    end;
   end;
  end;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.TMessage.AddToolCall(const aToolCall:TToolCall);
begin
 if assigned(fToolCalls) then begin
  fToolCalls.Add(aToolCall);
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.TMessage.HasToolCalls:Boolean;
begin
 result:=assigned(fToolCalls) and (fToolCalls.Count>0);
end;

{ TPasLLMModelInferenceInstance.TChatSession }

constructor TPasLLMModelInferenceInstance.TChatSession.Create(const aOwner:TPasLLMModelInferenceInstance);
begin
 inherited Create;
 fOwner:=aOwner;
 fTitle:='';
 fTimeStamp:=Now;
 fMessages:=TMessages.Create(true);
 fLastState:=TState.Unknown;
 fState:=TState.Initial;
 fSystemPrompt:='';
 fCurrentPosition:=0;
 fThinkMode:=TPinjaChatTemplateThinkMode.Auto;
 fThinking:=false;
 fOutputThinking:=false;
 fInToolCall:=false;
 fToolCallContent:='';
 fLastSamplerOutput:=false;
 fMaxSteps:=0;
 fCurrentStep:=0;
 fChatTemplate:=nil;
 fAssistantMessage:=nil;
 fToolMessage:=nil;
 fPromptTokens:=nil;
 fCountPromptTokens:=0;
 fPlaybackPromptTokens:=nil;
 fCountPlaybackPromptTokens:=0;
 fPlaybackPromptTokenIndex:=0;
 fPromptIndex:=0;
 fNextToken:=0; // Initialize next token
 fPreviousToken:=-1;
 fPreviousOutput:=''; // Initialize previous output
 fSessionContinuation:=false; // Not continuing a session initially
 fOnlyLastMessage:=false;
 fBackupStateForPlayback:=TState.Initial; // Initialize backup state
 fTokenList:=TPasLLMTokenList.Create; // Initialize token list
 fPlaybackTokenList:=TPasLLMTokenList.Create; // Initialize playback token list
 fSavedTokenList:=TPasLLMTokenList.Create; // Initialize saved token list
 fToolsEnabled:=false;
 fPendingToolCalls:=TToolCalls.Create(true);
 fToolResults:=TToolResults.Create(true);
 fAvailableTools:=TPasJSONItemArray.Create;
 fTavilyKey:='';
 fPromptAccumulatedTime:=0;
 fPromptAccumulatedTokens:=0;
 fOutputAccumulatedTime:=0;
 fOutputAccumulatedTokens:=0;
 fOnMessage:=nil;
 fOnStateChange:=nil;
 fOnTokenGenerated:=nil;
 fOnInput:=DefaultOnInput;  // Set default console input handler
 fOnOutput:=DefaultOnOutput; // Set default console output handler
 fOnSideTurn:=nil;
 fOnCheckAbort:=nil;
 fOnCheckTerminated:=nil;
 fTools:=TTools.Create(true);
 fToolHashMap:=TToolHashMap.Create(nil);
 fMCPServers:=TMCPServers.Create(true);
 fMCPServerHashMap:=TMCPServerHashMap.Create(nil);
end;

destructor TPasLLMModelInferenceInstance.TChatSession.Destroy;
begin
 FreeAndNil(fMessages);
 FreeAndNil(fMCPServerHashMap);
 FreeAndNil(fMCPServers);
 FreeAndNil(fPendingToolCalls);
 FreeAndNil(fToolResults);
 FreeAndNil(fAvailableTools);
 FreeAndNil(fTools);
 FreeAndNil(fToolHashMap);
 FreeAndNil(fChatTemplate);
 FreeAndNil(fTokenList);
 FreeAndNil(fPlaybackTokenList);
 FreeAndNil(fSavedTokenList);
 fPromptTokens:=nil;
 inherited Destroy;
end;

function TPasLLMModelInferenceInstance.TChatSession.ToolOnGetGurrentDatetime(const aChatSession:TChatSession;const aToolCall:TToolCall;const aToolResult:TToolResult):Boolean;
begin
 aToolResult.Content:=FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',Now);
 result:=true;
end;

function TPasLLMModelInferenceInstance.TChatSession.ToolOnWebSearch(const aChatSession:TChatSession;const aToolCall:TPasLLMModelInferenceInstance.TChatSession.TToolCall;const aToolResult:TChatSession.TToolResult):Boolean;
{$if declared(THTTPSend)}
{$undef UseDuckDuckGo}
{$if defined(UseDuckDuckGo)}
var HTTPSender:THTTPSend;
    RawByteStringData,QueryString,URL,IAJSON,HTMLDocument:RawByteString;

 function URLEncode(const aValue:RawByteString):RawByteString;
 const HexChars:array[0..15] of AnsiChar=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
 var CharacterIndex:TPasLLMInt32;
     CurrentByte:TPasLLMUInt8;
 begin
  result:='';
  for CharacterIndex:=1 to length(aValue) do begin
   CurrentByte:=TPasLLMUInt8(AnsiChar(aValue[CharacterIndex]));
   case CurrentByte of
    ord('A')..ord('Z'),ord('a')..ord('z'),ord('0')..ord('9'),ord('-'),ord('_'),ord('.'),ord('~'):begin
     result:=result+AnsiChar(CurrentByte);
    end;
    32:begin
     result:=result+'+';
    end;
    else begin
     result:=result+'%'+HexChars[CurrentByte shr 4]+HexChars[CurrentByte and $f];
    end;
   end;
  end;
 end;

function URLDecode(const aValue:RawByteString):RawByteString;
 var Index,Code,ErrorIndex:TPasLLMInt32;
     Hex:RawByteString;
 begin
  result:='';
  Index:=1;
  while Index<=length(aValue) do begin
   case aValue[Index] of
    '+':begin
     result:=result+' ';
     inc(Index);
    end;
    '%':begin
     if (Index+2)<=length(aValue) then begin
      Hex:=Copy(aValue,Index+1,2);
      Val('$'+UTF8Encode(Hex),Code,ErrorIndex);
      if ErrorIndex=0 then begin
       result:=result+AnsiChar(TPasLLMUInt8(Code));
       inc(Index,3);
      end else begin
       result:=result+'%';
       inc(Index);
      end;
     end else begin
      result:=result+'%';
      inc(Index);
     end;
    end;
    else begin
     result:=result+aValue[Index];
     inc(Index);
    end;
   end;
  end;
 end;

 function JSONEscape(const aValue:RawByteString):RawByteString;
 var CharacterIndex:TPasLLMInt32;
     CurrentByte:TPasLLMUInt8;
 begin
  result:='"';
  for CharacterIndex:=1 to length(aValue) do begin
   CurrentByte:=TPasLLMUInt8(aValue[CharacterIndex]);
   case CurrentByte of
    8:begin
     result:=result+'\b';
    end;
    9:begin
     result:=result+'\t';
    end;
    10:begin
     result:=result+'\n';
    end;
    12:begin
     result:=result+'\f';
    end;
    13:begin
     result:=result+'\r';
    end;
    34:begin
     result:=result+'\"';
    end;
    92:begin
     result:=result+'\\';
    end;
    else begin
     if CurrentByte<32 then begin
      result:=result+'\u'+RawByteString(IntToHex(CurrentByte,4));
     end else begin
      result:=result+AnsiChar(CurrentByte);
     end;
    end;
   end;
  end;
  result:=result+'"';
 end;

 function StripHTMLTags(const aHTML:RawByteString):RawByteString;
 var CharacterIndex,TagDepth:TPasLLMInt32;
     CurrentChar:AnsiChar;
 begin
  result:='';
  TagDepth:=0;
  for CharacterIndex:=1 to length(aHTML) do begin
   CurrentChar:=aHTML[CharacterIndex];
   if CurrentChar='<' then begin
    inc(TagDepth);
   end else if (CurrentChar='>') and (TagDepth>0) then begin
    dec(TagDepth);
   end else if TagDepth=0 then begin
    result:=result+CurrentChar;
   end;
  end;
 end;

 function DecodeBasicHTMLEntities(const aText:RawByteString):RawByteString;
 begin
  result:=StringReplace(aText,'&amp;','&',[rfReplaceAll]);
  result:=StringReplace(result,'&lt;','<',[rfReplaceAll]);
  result:=StringReplace(result,'&gt;','>',[rfReplaceAll]);
  result:=StringReplace(result,'&quot;','"',[rfReplaceAll]);
  result:=StringReplace(result,'&#39;','''',[rfReplaceAll]);
 end;

 function LooksEmptyIA(const aJSON:RawByteString):Boolean;
 begin
  result:=(length(aJSON)=0) or ((Pos('"Abstract":""',aJSON)>0) and (Pos('"Results":[]',aJSON)>0) and (Pos('"RelatedTopics":[]',aJSON)>0));
 end;

 function PosEx(const aSubStr,aStr:RawByteString;const aFromPos:TPasLLMInt32):TPasLLMInt32;
 var Offset:TPasLLMInt32;
     FoundAt:TPasLLMInt32;
 begin
  if aFromPos<=1 then begin
   result:=Pos(aSubStr,aStr);
  end else begin
   Offset:=aFromPos-1;
   FoundAt:=Pos(aSubStr,Copy(aStr,aFromPos,length(aStr)-Offset));
   if FoundAt>0 then begin
    result:=Offset+FoundAt;
   end else begin
    result:=0;
   end;
  end;
 end;

 function ExtractParameterValue(const aURLText,aParameterName:RawByteString):RawByteString;
 var ParameterPosition,ValueStart,ValueEnd:TPasLLMInt32;
     SearchKey:RawByteString;
 begin
  result:='';
  SearchKey:=aParameterName+'=';
  ParameterPosition:=Pos(SearchKey,aURLText);
  if ParameterPosition>0 then begin
   ValueStart:=ParameterPosition+length(SearchKey);
   ValueEnd:=PosEx('&',aURLText,ValueStart);
   if ValueEnd=0 then begin
    ValueEnd:=length(aURLText)+1;
   end;
   result:=Copy(aURLText,ValueStart,ValueEnd-ValueStart);
  end;
 end;

 function NormalizeDuckDuckGoURL(const aHref:RawByteString):RawByteString;
 var WorkingURL,ParameterValue:RawByteString;
 begin

  // absolutize protocol-relative links
  if (length(aHref)>=2) and (aHref[1]='/') and (aHref[2]='/') then begin
   WorkingURL:='https:'+aHref;
  end else begin
   WorkingURL:=aHref;
  end;

  // unwrap DuckDuckGo redirect: /l/?uddg=<encoded>&rut=...
  if Pos('/l/?',WorkingURL)>0 then begin
   ParameterValue:=ExtractParameterValue(WorkingURL,'uddg');
   if length(ParameterValue)>0 then begin
    WorkingURL:=URLDecode(ParameterValue);
   end;
  end;

  result:=WorkingURL;
 end;

 function ParseDuckDuckGoHTMLToJSON(const aHTML,aQuery:RawByteString):RawByteString;
 var SearchPosition,AnchorStart,AnchorEnd,HrefStart,HrefEnd,TitleStart,TitleEnd,SnippetStart,SnippetEnd:TPasLLMInt32;
     Items,ExtractedURL,ExtractedTitle,ExtractedSnippet:RawByteString;
     ItemCount:TPasLLMInt32;
 begin
  Items:='';
  ItemCount:=0;
  SearchPosition:=1;

  // Parse <a class="result__a" href="...">Title</a> and a nearby element with class result__snippet
  while true do begin

   AnchorStart:=PosEx('<a',aHTML,SearchPosition);
   if AnchorStart=0 then begin
    break;
   end;

   AnchorEnd:=PosEx('>',aHTML,AnchorStart+2);
   if AnchorEnd=0 then begin
    break;
   end;

   if (PosEx('class="result__a"',aHTML,AnchorStart)<>0) and (PosEx('class="result__a"',aHTML,AnchorStart)<AnchorEnd) then begin

    // Found a result anchor
    HrefStart:=PosEx('href="',aHTML,AnchorStart);
    if (HrefStart>0) and (HrefStart<AnchorEnd) then begin
     HrefStart:=HrefStart+6;
     HrefEnd:=PosEx('"',aHTML,HrefStart);
     ExtractedURL:=NormalizeDuckDuckGoURL(Copy(aHTML,HrefStart,HrefEnd-HrefStart));
    end else begin
     ExtractedURL:='';
    end;

    // Extract title
    TitleStart:=AnchorEnd+1;
    TitleEnd:=PosEx('</a>',aHTML,TitleStart);
    ExtractedTitle:=Copy(aHTML,TitleStart,TitleEnd-TitleStart);

    // Extract snippet: choose enclosing close tag to avoid cutting inside nested markup
    ExtractedSnippet:='';
    SnippetStart:=PosEx('result__snippet',aHTML,TitleEnd);
    if SnippetStart>0 then begin
     SnippetStart:=PosEx('>',aHTML,SnippetStart);
     if SnippetStart>0 then begin
      SnippetEnd:=PosEx('</',aHTML,SnippetStart+1);
      if SnippetEnd>0 then begin
       ExtractedSnippet:=Copy(aHTML,SnippetStart+1,SnippetEnd-(SnippetStart+1));
      end;
     end;
    end;

    // Append to items
    if ItemCount>0 then begin
     Items:=Items+',';
    end;
    Items:=Items+'{"title":'+JSONEscape(StripHTMLTags(DecodeBasicHTMLEntities(ExtractedTitle)))+',"url":'+JSONEscape(DecodeBasicHTMLEntities(ExtractedURL))+',"snippet":'+JSONEscape(StripHTMLTags(DecodeBasicHTMLEntities(ExtractedSnippet)))+'}';
    inc(ItemCount);

    // Continue searching after this result
    SearchPosition:=TitleEnd+4;

   end else begin

    // Not a result anchor, continue searching
    SearchPosition:=AnchorEnd+1;

   end;

  end;

  // Construct final JSON
  result:='{"engine":"duckduckgo","query":'+JSONEscape(aQuery)+',"results":['+Items+']}';

 end;

begin
 result:=false;

 QueryString:=Trim(aToolCall.GetArgumentValue('query'));
 if length(QueryString)>0 then begin

  try

   HTTPSender:=THTTPSend.Create;
   try

    // 1) Try DuckDuckGo Instant Answer JSON API
    HTTPSender.MimeType:='application/json';
    HTTPSender.Headers.Add('Accept: application/json');
    URL:='https://api.duckduckgo.com/?q='+URLEncode(QueryString)+'&format=json&no_html=1&no_redirect=1&skip_disambig=1';
    HTTPSender.Document.Clear;
    if HTTPSender.HTTPMethod('GET',UTF8Encode(URL)) then begin
     IAJSON:='';
     if HTTPSender.Document.Size>0 then begin
      SetLength(IAJSON,HTTPSender.Document.Size);
      System.Move(HTTPSender.Document.Memory^,IAJSON[1],HTTPSender.Document.Size);
     end;
     if not LooksEmptyIA(IAJSON) then begin
{$if declared(UTF8Decode) and not defined(fpc)}
      aToolResult.Content:=UTF8Decode(IAJSON);
{$else}
      aToolResult.Content:=IAJSON;
{$ifend}
      result:=true;
     end;
    end;

    // 2) Fallback: scrape HTML search results page
    if not result then begin
     HTTPSender.Headers.Clear;
     HTTPSender.MimeType:='text/html';
     HTTPSender.Headers.Add('Accept: text/html');
     URL:='https://html.duckduckgo.com/html/?q='+URLEncode(QueryString);
     HTTPSender.Document.Clear;
     if HTTPSender.HTTPMethod('GET',UTF8Encode(URL)) then begin
      HTMLDocument:='';
      if HTTPSender.Document.Size>0 then begin
       SetLength(HTMLDocument,HTTPSender.Document.Size);
       System.Move(HTTPSender.Document.Memory^,HTMLDocument[1],HTTPSender.Document.Size);
      end;
      RawByteStringData:=ParseDuckDuckGoHTMLToJSON(HTMLDocument,QueryString);
{$if declared(UTF8Decode) and not defined(fpc)}
      aToolResult.Content:=UTF8Decode(RawByteStringData);
{$else}
      aToolResult.Content:=RawByteStringData;
{$ifend}
      result:=true;
     end;
    end;
   finally
    FreeAndNil(HTTPSender);
   end;

  finally
   if not result then begin
    aToolResult.Content:='Error';
   end;
  end;

 end else begin
  aToolResult.Content:='Error';
 end;

end;
{$else}
var HTTPSender:THTTPSend;
    JSONItemObject:TPasJSONItemObject;
    RawByteStringData,QueryString:RawByteString;
begin
 result:=false;
 QueryString:=Trim(aToolCall.GetArgumentValue('query'));
 if (length(fTavilyKey)>0) and (length(QueryString)>0) then begin
  try
   HTTPSender:=THTTPSend.Create;
   try
//  HTTPSender.Headers.Add('Content-Type: application/json');
    HTTPSender.MimeType:='application/json';
    HTTPSender.Headers.Add('Authorization: Bearer '+fTavilyKey);
    JSONItemObject:=TPasJSONItemObject.Create;
    try
     JSONItemObject.Add('query',TPasJSONItemString.Create(QueryString));
     JSONItemObject.Add('include_answer',TPasJSONItemString.Create('basic'));
     JSONItemObject.Add('search_depth',TPasJSONItemString.Create('basic'));
     HTTPSender.Document.Clear;
     TPasJSON.StringifyToStream(HTTPSender.Document,JSONItemObject);
    finally
     FreeAndNil(JSONItemObject);
    end;
    if HTTPSender.HTTPMethod('POST','https://api.tavily.com/search') then begin
     RawByteStringData:='';
     if HTTPSender.Document.Size>0 then begin
      SetLength(RawByteStringData,HTTPSender.Document.Size);
      System.Move(HTTPSender.Document.Memory^,RawByteStringData[1],HTTPSender.Document.Size);
     end;
{$if declared(UTF8Decode) and not defined(fpc)}
     aToolResult.Content:=UTF8Decode(RawByteStringData);
{$else}
     aToolResult.Content:=RawByteStringData;
{$ifend}
     result:=true;
    end;
   finally
    FreeAndNil(HTTPSender);
   end;
  finally
   if not result then begin
    aToolResult.Content:='Error';
   end;
  end;
 end else begin
  aToolResult.Content:='Error';
 end;
end;
{$ifend}
{$else}
begin
 aToolResult.Content:='Error';
 result:=false;
end;
{$ifend}

procedure TPasLLMModelInferenceInstance.TChatSession.ClearTools;
begin
 fTools.Clear;
 fToolHashMap.Clear;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddDefaultTools;
var Tool:TTool;
begin

 Tool:=TTool.Create;
 try
  Tool.Name:='get_current_datetime';
  Tool.OnMethodCall:=ToolOnGetGurrentDatetime;
 finally
  AddTool(Tool);
 end;

 if length(fTavilyKey)>0 then begin
  Tool:=TTool.Create;
  try
   Tool.Name:='websearch';
   Tool.Arguments.Add(TPasLLMModelInferenceInstance.TChatSession.TTool.TArgument.Create('query','Search query'));
   Tool.OnMethodCall:=ToolOnWebSearch;
  finally
   AddTool(Tool);
  end;
 end;

end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddTool(const aTool:TTool);
begin
 if assigned(aTool) and (length(aTool.Name)>0) then begin
  if fToolHashMap.ExistKey(aTool.Name) then begin
   raise EPasLLM.Create('Tool with name "'+aTool.Name+'" already exists');
  end else begin
   fTools.Add(aTool);
   fToolHashMap.Add(aTool.Name,aTool);
  end;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.RemoveTool(const aToolName:TPasLLMUTF8String);
var Tool:TTool;
begin
 Tool:=FindTool(aToolName);
 if assigned(Tool) then begin
  fTools.Remove(Tool);
  fToolHashMap.Delete(aToolName); 
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.FindTool(const aToolName:TPasLLMUTF8String):TTool;
begin
 if length(aToolName)>0 then begin
  result:=fToolHashMap[aToolName];
 end else begin
  result:=nil;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetToolCount:TPasLLMInt32;
begin
 result:=fTools.Count;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetTool(const aIndex:TPasLLMInt32):TTool;
begin
 if (aIndex>=0) and (aIndex<fTools.Count) then begin
  result:=fTools[aIndex];
 end else begin
  result:=nil;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.EnableTool(const aToolName:TPasLLMUTF8String;const aEnabled:Boolean);
var Tool:TTool;
begin
 Tool:=FindTool(aToolName);
 if assigned(Tool) then begin
  Tool.Enabled:=aEnabled;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.IsToolEnabled(const aToolName:TPasLLMUTF8String):Boolean;
var Tool:TTool;
begin
 Tool:=FindTool(aToolName);
 if assigned(Tool) then begin
  result:=Tool.Enabled;
 end else begin
  result:=false;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.RegisterMCPServer(const aID,aEndpoint,aAuthorization:TPasLLMUTF8String;const aTimeoutMilliseconds:TPasLLMInt32):Boolean;
var MCPServer:TMCPServer;
begin
 if fMCPServerHashMap.ExistKey(aID) then begin
  result:=false;
 end else begin
  MCPServer:=TMCPServer.Create(aID,aEndpoint,aAuthorization,aTimeoutMilliseconds);
  try
   fMCPServerHashMap.Add(aID,MCPServer);
  finally
   fMCPServers.Add(MCPServer);
  end;
  result:=true;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.RegisterMCPToolsFromServer(const aServerID:TPasLLMUTF8String):Boolean;
var TargetMCPServer:TMCPServer;
    MCPClientInstance:TMCPClient;
    JSONToolsArray:TPasJSONItemArray;
    JSONToolObject:TPasJSONItemObject;
    JSONInputSchema:TPasJSONItem;
    JSONInputSchemaProperties:TPasJSONItem;
    JSONInputSchemaProperty:TPasJSONItem;
    ToolArrayIndex,ArgumentIndex:TPasLLMSizeInt;
    RemoteToolName,RemoteToolDescription:TPasLLMUTF8String;
    ImportedTool:TTool;
begin

 TargetMCPServer:=fMCPServerHashMap[aServerID];
 if assigned(TargetMCPServer) then begin

  MCPClientInstance:=TMCPClient.Create(TargetMCPServer);
  try

   JSONToolsArray:=MCPClientInstance.ListTools;
   if assigned(JSONToolsArray) then begin

    try

     for ToolArrayIndex:=0 to JSONToolsArray.Count-1 do begin
      if JSONToolsArray.Items[ToolArrayIndex] is TPasJSONItemObject then begin
       JSONToolObject:=TPasJSONItemObject(JSONToolsArray.Items[ToolArrayIndex]);
       RemoteToolName:=TPasJSON.GetString(JSONToolObject.Properties['name'],'');
       if length(RemoteToolName)>0 then begin
        RemoteToolDescription:=TPasJSON.GetString(JSONToolObject.Properties['description'],'');
        ImportedTool:=TTool.Create;
        try
         ImportedTool.fName:=RemoteToolName;
         ImportedTool.fDescription:=RemoteToolDescription;
         ImportedTool.fEnabled:=true;
         ImportedTool.fOnMethodCall:=ToolOnMCPCall;
         ImportedTool.fMCPBinding:=TMCPToolBinding.Create(aServerID,RemoteToolName);
         // Parse input schema for arguments
         JSONInputSchema:=JSONToolObject.Properties['input_schema'];
         if assigned(JSONInputSchema) and (JSONInputSchema is TPasJSONItemObject) then begin
          if TPasJSON.GetString(TPasJSONItemObject(JSONInputSchema).Properties['type'],'')='object' then begin
           JSONInputSchemaProperties:=TPasJSONItemObject(JSONInputSchema).Properties['properties'];
           if assigned(JSONInputSchemaProperties) and (JSONInputSchemaProperties is TPasJSONItemObject) then begin
            for ArgumentIndex:=0 to TPasJSONItemObject(JSONInputSchemaProperties).Count-1 do begin
             JSONInputSchemaProperty:=TPasJSONItemObject(JSONInputSchemaProperties).Values[ArgumentIndex];
             if assigned(JSONInputSchemaProperty) and (JSONInputSchemaProperty is TPasJSONItemObject) then begin
              ImportedTool.fArguments.Add(
               TTool.TArgument.Create(
                TPasJSONItemObject(JSONInputSchemaProperties).Keys[ArgumentIndex],
                TPasJSON.GetString(TPasJSONItemObject(JSONInputSchemaProperty).Properties['description'],''),
                TPasJSON.GetString(TPasJSONItemObject(JSONInputSchemaProperty).Properties['example'],'')
               )
              );
             end;
            end;
           end;
          end; 
         end;
        finally
         AddTool(ImportedTool);
        end;
       end;
      end;
     end;

     result:=true;

    finally
     FreeAndNil(JSONToolsArray);
    end;

   end else begin
    result:=false;
   end;

  finally
   FreeAndNil(MCPClientInstance);
  end;

 end else begin

  result:=false;

 end;

end;

function TPasLLMModelInferenceInstance.TChatSession.UnregisterMCPServer(const aServerID:TPasLLMUTF8String):Boolean;
var Index,ToolIndex:TPasLLMSizeInt;
    MCPServer:TMCPServer;   
    Tool:TTool;
begin

 result:=false;

 // Find server by ID
 MCPServer:=fMCPServerHashMap[aServerID];
 if assigned(MCPServer) then begin

  // Remove all tools bound to this server
  for ToolIndex:=fTools.Count-1 downto 0 do begin
   Tool:=fTools[ToolIndex];
   if assigned(Tool) and assigned(Tool.fMCPBinding) and (Tool.fMCPBinding.fServerID=aServerID) then begin
    fTools.Delete(ToolIndex);
    fToolHashMap.Delete(Tool.fName);
   end;
  end;

  // Remove server from list
  Index:=fMCPServers.IndexOf(MCPServer);
  if Index>=0 then begin
   fMCPServers.Delete(Index);
  end;

  // Remove server from hash map 
  fMCPServerHashMap.Delete(aServerID);

  result:=true;

 end;

end;

function TPasLLMModelInferenceInstance.TChatSession.ToolOnMCPCall(const aChatSession:TPasLLMModelInferenceInstance.TChatSession;const aToolCall:TPasLLMModelInferenceInstance.TChatSession.TToolCall;const aToolResult:TPasLLMModelInferenceInstance.TChatSession.TToolResult):Boolean;
var ArgumentIndex:TPasLLMSizeInt;
    Argument:TPasLLMModelInferenceInstance.TChatSession.TToolCall.TArgument;
    LocalTool:TTool;
    LocalToolBinding:TMCPToolBinding;
    TargetMCPServer:TMCPServer;
    MCPClientInstance:TMCPClient;
    ArgumentsJSONObject:TPasJSONItemObject;
    RawResultJSONItem:TPasJSONItem;
    IsError:Boolean;
begin

 result:=false;

 // Resolve tool and its binding
 LocalTool:=FindTool(aToolCall.fName);
 if assigned(LocalTool) then begin

  LocalToolBinding:=LocalTool.MCPBinding;
  if assigned(LocalToolBinding) then begin

   // Resolve server by ID
   TargetMCPServer:=fMCPServerHashMap[LocalToolBinding.ServerID];
   if assigned(TargetMCPServer) then begin

    // Build JSON arguments from call-time arguments
    ArgumentsJSONObject:=TPasJSONItemObject.Create;
    try

     if assigned(aToolCall.fArguments) then begin
      for ArgumentIndex:=0 to aToolCall.fArguments.Count-1 do begin
       Argument:=aToolCall.fArguments.Items[ArgumentIndex];
       ArgumentsJSONObject.Add(Argument.fName,TPasJSONItemString.Create(Argument.fValue));
      end;
     end;

     MCPClientInstance:=TMCPClient.Create(TargetMCPServer);
     try

      RawResultJSONItem:=MCPClientInstance.CallTool(LocalToolBinding.RemoteToolName,ArgumentsJSONObject,IsError);
      if assigned(RawResultJSONItem) then begin

       try
        aToolResult.fContent:=TPasJSON.Stringify(RawResultJSONItem,false,[]);
        aToolResult.fIsError:=IsError;
       finally
        FreeAndNil(RawResultJSONItem);
       end;

       result:=true;

      end;

     finally
      FreeAndNil(MCPClientInstance);
     end;

    finally
     FreeAndNil(ArgumentsJSONObject);
    end;

   end;

  end;

 end;

end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadMCPServersFromJSON(const aJSON:TPasJSONItem);
var Index:TPasLLMSizeInt;
    ServersArray:TPasJSONItemArray;
    ServersObject,ServerObject:TPasJSONItemObject;
    ServerItem:TPasJSONItem;
    ServerID,ServerEndpoint,ServerAuthorization:TPasLLMUTF8String;
    ServerTimeoutMilliseconds:TPasLLMInt64;
begin

 if assigned(aJSON) then begin
 
  if aJSON is TPasJSONItemArray then begin

   // Array of server objects
   ServersArray:=TPasJSONItemArray(aJSON);
   for Index:=0 to ServersArray.Count-1 do begin
    ServerItem:=ServersArray.Items[Index];
    if assigned(ServerItem) and (ServerItem is TPasJSONItemObject) then begin
     ServerObject:=TPasJSONItemObject(ServerItem);
     ServerID:=TPasJSON.GetString(ServerObject.Properties['id'],'');
     ServerEndpoint:=TPasJSON.GetString(ServerObject.Properties['endpoint'],'');
     ServerAuthorization:=TPasJSON.GetString(ServerObject.Properties['authorization'],'');
     ServerTimeoutMilliseconds:=TPasJSON.GetInt64(ServerObject.Properties['timeout_milliseconds'],30000);
     if length(ServerID)>0 then begin
      RegisterMCPServer(ServerID,ServerEndpoint,ServerAuthorization,ServerTimeoutMilliseconds);
      try
       RegisterMCPToolsFromServer(ServerID);
      except
      end;
     end;
    end;
   end;

  end else if aJSON is TPasJSONItemObject then begin
   
   // Object with server IDs as keys and server objects as values
   ServersObject:=TPasJSONItemObject(aJSON);
   for Index:=0 to ServersObject.Count-1 do begin
    ServerID:=Trim(ServersObject.Keys[Index]);
    if length(ServerID)>0 then begin
     ServerItem:=ServersObject.Values[Index];
     if assigned(ServerItem) and (ServerItem is TPasJSONItemObject) then begin
      ServerObject:=TPasJSONItemObject(ServerItem);
      ServerEndpoint:=TPasJSON.GetString(ServerObject.Properties['endpoint'],'');
      ServerAuthorization:=TPasJSON.GetString(ServerObject.Properties['authorization'],'');
      ServerTimeoutMilliseconds:=TPasJSON.GetInt64(ServerObject.Properties['timeout_milliseconds'],30000);
      RegisterMCPServer(ServerID,ServerEndpoint,ServerAuthorization,ServerTimeoutMilliseconds);
      try
       RegisterMCPToolsFromServer(ServerID);
      except
      end;
     end;
    end;
   end;

  end else begin

   // Ignore invalid format
   // raise EPasLLM.Create('Invalid JSON format for MCP servers');

  end;

 end;  

end;  

procedure TPasLLMModelInferenceInstance.TChatSession.LoadMCPServersFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadMCPServersFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadMCPServersFromJSONFile(const aFileName:TPasLLMUTF8String);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  Stream.Seek(0,soFromBeginning);
  LoadMCPServersFromJSONStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.Reset;
begin
 fTitle:='';
 fTimeStamp:=Now;
 fMessages.Clear;
 fPendingToolCalls.Clear;
 fToolResults.Clear;
 SetState(TState.Initial);
 fTokenList.Clear;
 fPlaybackTokenList.Clear;
 fSavedTokenList.Clear;
 fCurrentPosition:=0;
 fCurrentStep:=0;
 fThinking:=false;
 fOutputThinking:=false;
 fInToolCall:=false;
 fToolCallContent:='';
 fPromptIndex:=0;
 fNextToken:=0; // Reset next token
 fPreviousToken:=-1;
 fPreviousOutput:=''; // Reset previous output
 fSessionContinuation:=false; // Reset continuation mode
 fCountPromptTokens:=0;
 fPromptTokens:=nil;
 fCountPlaybackPromptTokens:=0;
 fPlaybackPromptTokens:=nil;
 fPlaybackPromptTokenIndex:=0;
 fPromptAccumulatedTime:=0;
 fPromptAccumulatedTokens:=0;
 fOutputAccumulatedTime:=0;
 fOutputAccumulatedTokens:=0;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.SetState(const aNewState:TState);
begin

 if fState<>aNewState then begin

  fLastState:=fState;
  fState:=aNewState;
  
  if assigned(fOnStateChange) then begin
   fOnStateChange(self,fLastState,aNewState);
  end;

 end;

end;

procedure TPasLLMModelInferenceInstance.TChatSession.SetSystemPrompt(const aPrompt:TPasLLMUTF8String);
begin
 fSystemPrompt:=aPrompt;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddUserMessage(const aMessage:TPasLLMUTF8String);
var Message:TMessage;
begin
 Message:=TMessage.Create('user',aMessage);
 try
  fMessages.Add(Message);
  if assigned(fOnMessage) then begin
   fOnMessage(self,Message);
  end;
 except
  FreeAndNil(Message);
  raise;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddAssistantMessage(const aMessage:TPasLLMUTF8String);
var Message:TMessage;
begin
 Message:=TMessage.Create('assistant',aMessage);
 try
  fMessages.Add(Message);
  if assigned(fOnMessage) then begin
   fOnMessage(self,Message);
  end;
 except
  FreeAndNil(Message);
  raise;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.AddToolMessage(const aToolName:TPasLLMUTF8String;const aToolCallID,aContent:TPasLLMUTF8String):TMessage;
var Message:TMessage;
begin
 Message:=TMessage.Create('tool',aContent);
 try
  Message.ToolName:=aToolName;
  Message.ToolCallID:=aToolCallID;
  fMessages.Add(Message);
  if assigned(fOnMessage) then begin
   fOnMessage(self,Message);
  end;
 except
  FreeAndNil(Message);
  raise;
 end;
 result:=Message;
end;

function TPasLLMModelInferenceInstance.TChatSession.Step:Boolean;
var UserPrompt,RenderedPrompt:TPasLLMUTF8String;
    Token:TPasLLMInt32;
    StartTime:TPasLLMUInt64;
    Logits:PPasLLMFloatArray;
    Output:TPasLLMUTF8String;
    Index:TPasLLMInt32;
    ToolCall:TToolCall;
    ToolResult:TToolResult;
    Tool:TTool;
begin

 // Check if session is complete or terminated
 if IsComplete or (fState=TState.Terminated) or (fState=TState.Aborted) then begin
  result:=false;
  exit;
 end;
 
 // Check for abort condition
 if assigned(fOnCheckAbort) and fOnCheckAbort(self) then begin
  SetState(TState.Aborted);
  result:=false;
  exit;
 end;
 
 // Check for termination condition
 if assigned(fOnCheckTerminated) and fOnCheckTerminated(self) then begin
  SetState(TState.Terminated);
  result:=false;
  exit;
 end;
 
 // Check step limits
 if (fMaxSteps>0) and (fCurrentStep>=fMaxSteps) then begin
  SetState(TState.Aborted);
  result:=false;
  exit;
 end;
 
 // Handle state transitions atomically
 case fState of

  /////////////////////////////////////////////////////////////////////////////////

  TState.ProcessingPlaybackTokens:begin

   // Process one playback token

   if fPlaybackPromptTokenIndex<fCountPlaybackPromptTokens then begin

    Token:=fPlaybackPromptTokens[fPlaybackPromptTokenIndex];
    inc(fPlaybackPromptTokenIndex);
    
    // Forward the model
    StartTime:=GetCurrentTime;
    fOwner.Forward(Token,fCurrentPosition,true);
    inc(fPromptAccumulatedTime,GetCurrentTime-StartTime);
    inc(fPromptAccumulatedTokens);

    inc(fCurrentPosition);
    inc(fCurrentStep);

    if fPlaybackPromptTokenIndex<fCountPlaybackPromptTokens then begin

     fLastSamplerOutput:=false;

     if assigned(fOnOutput) then begin
      fOnOutput(self,'');
     end;

     result:=true;

    end else begin

     // Finished playback, restore the original state after playback is complete
     SetState(fBackupStateForPlayback);
     result:=true;

    end;

   end else begin

    // Finished playback, restore the original state after playback is complete
    SetState(fBackupStateForPlayback);
    result:=true;

   end;

  end;
  
  /////////////////////////////////////////////////////////////////////////////////

  TState.Initial:begin

   // Initialize for user input

   fCurrentPosition:=0;

   fAssistantMessage:=nil;

   fToolMessage:=nil;

   if fSystemPrompt=#0 then begin
    SetState(TState.SystemPromptInput);
   end else begin
    SetState(TState.UserInput);
   end;

   fOnlyLastMessage:=false;

   result:=true;

  end;
  
  /////////////////////////////////////////////////////////////////////////////////

  TState.SystemPromptInput:begin

   // Handle system prompt input

   fAssistantMessage:=nil;

   fToolMessage:=nil;

   if (fSystemPrompt=#0) or (length(fSystemPrompt)=0) then begin
    if assigned(fOnInput) then begin
     if assigned(fOnSideTurn) then begin
      fOnSideTurn(self,'System');
     end;
     fSystemPrompt:=Trim(fOnInput(self,'System: '));
    end;
   end;
   
   // Move to user input regardless of whether system prompt was provided
   SetState(TState.UserInput);
   result:=true;
  end;
  
  /////////////////////////////////////////////////////////////////////////////////
  
  TState.UserInput:begin

   // Get user input if we need it

   fAssistantMessage:=nil;

   fToolMessage:=nil;

   if assigned(fOnInput) then begin

    if assigned(fOnSideTurn) then begin
     fOnSideTurn(self,'User');
    end;
    UserPrompt:=Trim(fOnInput(self,'User: '));

    // If terminated by command, exit
    if (fState=TState.Terminated) or (fState=TState.Aborted) then begin
     result:=false;
     exit;
    end;

    // Handle special commands
    HandleSpecialCommands(UserPrompt);

    // If we have a prompt, add it as user message
    if length(UserPrompt)>0 then begin

     AddUserMessage(UserPrompt);
     SetState(TState.SetupUserPromptProcessing);
     result:=true;

    end else begin

     // No input, stay in UserInput state
     result:=true;

    end;

   end else begin

    // No input handler, stay in UserInput state
    result:=true;

   end;

  end;
  
  TState.SetupUserPromptProcessing:begin

   // Setup prompt processing
   RenderedPrompt:=RenderPromptWithTools(fOnlyLastMessage);
   fOnlyLastMessage:=true;
// writeln(RenderedPrompt);

   fCountPromptTokens:=0;
   fOwner.fModel.fTokenizer.Encode(RenderedPrompt,true,false,fPromptTokens,fCountPromptTokens);

   fPromptIndex:=0;
   fLastSamplerOutput:=false;
   fAssistantMessage:=nil;
   fToolMessage:=nil;

   fOutputThinking:=false;

   fNextToken:=-1;
   fPreviousToken:=-1;

   // Transition to appropriate processing state
   SetState(TState.ProcessingUserPromptToken);

   result:=true;

  end;
  
  /////////////////////////////////////////////////////////////////////////////////

  TState.ProcessingUserPromptToken:begin

   // Process one user prompt token

   if fNextToken>=0 then begin

    Token:=fNextToken;

    // Forward the model
    StartTime:=GetCurrentTime;
    fOwner.Forward(Token,fCurrentPosition,true);
    inc(fPromptAccumulatedTime,GetCurrentTime-StartTime);
    inc(fPromptAccumulatedTokens);

    inc(fCurrentPosition);
    inc(fCurrentStep);

   end;

   if fPromptIndex<fCountPromptTokens then begin

    Token:=fPromptTokens[fPromptIndex];
    inc(fPromptIndex);

    if fPromptIndex>=fCountPromptTokens then begin
     SetState(TState.SetupAssistantAnswerGenerating);
    end;

    fNextToken:=Token;

    fTokenList.Add(fNextToken);

    fPreviousToken:=fNextToken;

    // Toggle the thinking state based on the current token
    if (fOwner.fModel.fTokenizer.fStartOfThinkToken>=0) and (fOwner.fModel.fTokenizer.fEndOfThinkToken>=0) then begin
     if fNextToken=fOwner.fModel.fTokenizer.fStartOfThinkToken then begin
      fOutputThinking:=true;
     end else if fNextToken=fOwner.fModel.fTokenizer.fEndOfThinkToken then begin
      fOutputThinking:=false;
     end;
    end;

    result:=true;

   end else begin

    SetState(TState.UserInput);
    result:=true;

   end;

  end;

  /////////////////////////////////////////////////////////////////////////////////

  TState.SetupAssistantAnswerGenerating:begin

   fInToolCall:=false;
   fToolCallContent:='';

   fAssistantMessage:=TMessage.Create('assistant','');
   try
    fAssistantMessage.fRole:='assistant';
   finally
    fMessages.Add(fAssistantMessage);
   end;

   if assigned(fOnSideTurn) then begin
    fOnSideTurn(self,'Assistant');
   end else if assigned(fOnOutput) then begin
    fOnOutput(self,'Assistant: ');
   end;

   if fOutputThinking then begin
    fOutputThinking:=false;
    fThinking:=true;
    if (fOwner.fModel.fTokenizer.fStartOfThinkToken>=0) and (fOwner.fModel.fTokenizer.fEndOfThinkToken>=0) then begin
     fPreviousToken:=fOwner.fModel.fTokenizer.fStartOfThinkToken;
     Output:=fOwner.fModel.fTokenizer.fVocab[fOwner.fModel.fTokenizer.fStartOfThinkToken];
     if assigned(fAssistantMessage) then begin
      fAssistantMessage.fContent:=fAssistantMessage.fContent+Output;
     end;
     if assigned(fOnOutput) then begin
      fOnOutput(self,Output);
     end;
    end;
   end else begin
    fThinking:=false;
   end;

   SetState(TState.GeneratingAssistantAnswer);

  end;

  /////////////////////////////////////////////////////////////////////////////////

  TState.GeneratingAssistantAnswer:begin

   // Generate one token using the previously sampled next token

   // Use the next token sampled from previous turn
   Token:=fNextToken;
  
   // Forward the model to get logits for the next token
   StartTime:=GetCurrentTime;
   Logits:=fOwner.Forward(Token,fCurrentPosition,false); // Not processing prompt anymore
// inc(fOutputAccumulatedTime,GetCurrentTime-StartTime);

   // Increment the position in the sequence
   inc(fCurrentPosition);
   inc(fCurrentStep);
   
   // If we have logits, sample next token
   if assigned(Logits) then begin
    if not fLastSamplerOutput then begin
     fOwner.fSamplerPenalties.Reset;
     fLastSamplerOutput:=true;
    end;
//  StartTime:=GetCurrentTime;
    fOwner.fSamplerPenalties.Apply(Logits);
    fNextToken:=fOwner.fSampler.Sample(Logits);
//  writeln(fNextToken);
    fOwner.fSamplerPenalties.Accept(fNextToken);
    inc(fOutputAccumulatedTime,GetCurrentTime-StartTime);
    inc(fOutputAccumulatedTokens);

    fTokenList.Add(fNextToken);

    if (fNextToken>=0) and (fNextToken<length(fOwner.fModel.fTokenizer.fVocab)) then begin

     // Check for end of stream tokens
     if TPasLLMTokenizer.TokenContains(fOwner.fModel.fConfiguration.fEndOfStreamToken,fNextToken) or
        ((length(fOwner.fModel.fConfiguration.fEndOfStreamToken)=0) and
         (((fOwner.fModel.fTokenizer.fEOSToken>=0) and (fNextToken=fOwner.fModel.fTokenizer.fEOSToken)) or
          ((fOwner.fModel.fTokenizer.fEOTToken>=0) and (fNextToken=fOwner.fModel.fTokenizer.fEOTToken)))) then begin

      if fThinking then begin

       // Workaround for faulty thinking token handling
       fThinking:=false;
       Token:=fOwner.fModel.fTokenizer.fEndOfThinkToken;
       if assigned(fAssistantMessage) then begin
        fAssistantMessage.fContent:=fAssistantMessage.fContent+fOwner.fModel.fTokenizer.fVocab[Token];
       end;
       if assigned(fOnOutput) then begin
        fOnOutput(self,fOwner.fModel.fTokenizer.fVocab[Token]);
       end;
       SetState(TState.GeneratingAssistantAnswer);

      end else begin

       // End of turn, record assistant message and check for pending tool calls
       if assigned(fAssistantMessage) then begin
        fAssistantMessage.fContent:=fAssistantMessage.fContent+#10;
       end;
       if assigned(fOnOutput) then begin
        fOnOutput(self,#10);
       end;

       // Reset for next turn
       fAssistantMessage:=nil;
       fToolMessage:=nil;

       if fInToolCall then begin
        fInToolCall:=false;
        AddToolCall(Trim(fToolCallContent));
       end;

       // Check if we have pending tool calls
       if fPendingToolCalls.Count>0 then begin
        SetState(TState.ProcessPendingToolCalls);
       end else begin
        // No tool calls, switch to user turn
        SetState(TState.UserInput);
       end;

      end;

     end else if not ((fOwner.fModel.fTokenizer.fStartHeaderIDToken>=0) and (fNextToken=fOwner.fModel.fTokenizer.fStartHeaderIDToken)) then begin

      // Decode and output the token
      Output:=fOwner.fModel.fTokenizer.SafeString(fOwner.fModel.fTokenizer.Decode(fPreviousOutput,Token,fNextToken));
      fPreviousOutput:=Copy(fPreviousOutput+Output,1,64);

      // Toggle the thinking state based on the current token
      if ((fOwner.fModel.fTokenizer.fStartOfThinkToken>=0) and (fOwner.fModel.fTokenizer.fEndOfThinkToken>=0)) and
         ((fNextToken=fOwner.fModel.fTokenizer.fStartOfThinkToken) or (fNextToken=fOwner.fModel.fTokenizer.fEndOfThinkToken)) then begin
       if fNextToken=fOwner.fModel.fTokenizer.fStartOfThinkToken then begin
        if fThinking then begin
         // Avoid duplicate output of thinking tokens
         Output:='';
        end;
        fThinking:=true;
       end else if fNextToken=fOwner.fModel.fTokenizer.fEndOfThinkToken then begin
        if not fThinking then begin
         // Avoid duplicate output of thinking tokens
         Output:='';
        end;
        fThinking:=false;
       end;
       if (Token=fNextToken) or (fPreviousToken=fNextToken) then begin
        // Avoid duplicate output of thinking tokens
        Output:='';
       end;
      end;

      // Tool call processing
      if fToolsEnabled then begin
       if (fOwner.fModel.fTokenizer.fToolCallBeginToken>=0) and (fNextToken=fOwner.fModel.fTokenizer.fToolCallBeginToken) then begin
        // Beginning of tool call, reset thinking state
        fInToolCall:=true;
        fToolCallContent:='';
       end else if (fOwner.fModel.fTokenizer.fToolCallEndToken>=0) and (fNextToken=fOwner.fModel.fTokenizer.fToolCallEndToken) then begin
        // End of tool call, reset thinking state
        if fInToolCall then begin
         AddToolCall(Trim(fToolCallContent));
        end;
        fInToolCall:=false;
       end else if fInToolCall then begin
        fToolCallContent:=fToolCallContent+Output;
       end;
      end;

      if length(Output)>0 then begin

       // Accumulate assistant output for message recording
       if assigned(fAssistantMessage) then begin
        fAssistantMessage.fContent:=fAssistantMessage.fContent+Output;
       end;

       if assigned(fOnOutput) then begin
        fOnOutput(self,Output);
       end;

       // Fire token generated event
       if assigned(fOnTokenGenerated) then begin
        fOnTokenGenerated(self,Output);
       end;

      end;

     end;

    end;

    fPreviousToken:=fNextToken;

    // Continue generation (stay in GeneratingAssistantAnswer state)

   end else begin
    // No logits, something went wrong
    SetState(TState.Terminated);
   end;
   
   result:=true;
  end;
  
  /////////////////////////////////////////////////////////////////////////////////

  TState.ProcessPendingToolCalls:begin

   // Check if we have tool results to process

   fAssistantMessage:=nil;
   fToolMessage:=nil;

   if fPendingToolCalls.Count>0 then begin

    // Process tool calls
{$ifdef fpc}
    ToolCall:=fPendingToolCalls.ExtractIndex(0);
{$else}
    ToolCall:=fPendingToolCalls.ExtractAt(0);
{$endif}
    if assigned(ToolCall) then begin
     try
      Tool:=FindTool(ToolCall.fName);
      if assigned(Tool) and assigned(Tool.fOnFunctionCall) then begin
       ToolResult:=TToolResult.Create(ToolCall.fName,ToolCall.fID,'',false);
       try
        ToolResult.fIsError:=false;
        if not Tool.fOnFunctionCall(self,ToolCall,ToolResult) then begin
         ToolResult.fContent:='Error';
         ToolResult.fIsError:=true;
        end;
       finally
        AddToolResult(ToolResult);
       end;
      end else if assigned(Tool) and assigned(Tool.fOnMethodCall) then begin
       ToolResult:=TToolResult.Create(ToolCall.fName,ToolCall.fID,'',false);
       try
        ToolResult.fIsError:=false;
        if not Tool.fOnMethodCall(self,ToolCall,ToolResult) then begin
         ToolResult.fContent:='Error';
         ToolResult.fIsError:=true;
        end;
       finally
        AddToolResult(ToolResult);
       end;
      end else begin
       ToolResult:=TToolResult.Create(ToolCall.fName,ToolCall.fID,'Error',true);
       AddToolResult(ToolResult);
      end;
     finally
      FreeAndNil(ToolCall);
     end;
    end;

    if fPendingToolCalls.Count=0 then begin
     if fToolResults.Count=0 then begin
      SetState(TState.UserInput);
     end else begin
      SetState(TState.SetupToolPromptProcessing);
     end;
    end;

    result:=true;

   end else begin
   
    SetState(TState.Terminated);
    result:=false;

   end;

  end;

  /////////////////////////////////////////////////////////////////////////////////

  TState.SetupToolPromptProcessing:begin

   if fToolResults.Count>0 then begin

{$ifdef fpc}
    ToolResult:=fToolResults.ExtractIndex(0);
{$else}
    ToolResult:=fToolResults.ExtractAt(0);
{$endif}
    if assigned(ToolResult) then begin

     try

      fToolMessage:=AddToolMessage(ToolResult.ToolName,ToolResult.ToolCallID,ToolResult.Content);

      if assigned(fOnSideTurn) then begin
       fOnSideTurn(self,'Tool');
      end else if assigned(fOnOutput) then begin
       fOnOutput(self,'Tool: ');
      end;

      if assigned(fToolMessage) then begin

       Output:=fToolMessage.fContent;

       if assigned(fOnOutput) then begin
        fOnOutput(self,Output);
       end;

       if assigned(fOnMessage) then begin
        fOnMessage(self,fToolMessage);
       end;

      end;

      // Setup prompt processing
      RenderedPrompt:=RenderPromptWithTools(true);
//    writeln(RenderedPrompt);

      fCountPromptTokens:=0;
      fOwner.fModel.fTokenizer.Encode(RenderedPrompt,true,false,fPromptTokens,fCountPromptTokens);

      fPromptIndex:=0;
      fLastSamplerOutput:=false;
      fAssistantMessage:=nil;

      fNextToken:=-1;

     finally
      FreeAndNil(ToolResult);
     end;

     fPreviousToken:=fNextToken;

     SetState(TState.ProcessingToolPromptToken);
     result:=true;

    end else begin

     fToolMessage:=nil;

     SetState(TState.SetupAssistantAnswerGenerating);
     result:=true;

    end;

   end else begin

    fToolMessage:=nil;

    SetState(TState.SetupAssistantAnswerGenerating);
    result:=true;

   end;

  end;

  /////////////////////////////////////////////////////////////////////////////////

  TState.ProcessingToolPromptToken:begin

   // Process one user prompt token

   if fNextToken>=0 then begin

    Token:=fNextToken;

    // Forward the model
    StartTime:=GetCurrentTime;
    fOwner.Forward(Token,fCurrentPosition,true);
    inc(fPromptAccumulatedTime,GetCurrentTime-StartTime);
    inc(fPromptAccumulatedTokens);

    inc(fCurrentPosition);
    inc(fCurrentStep);

   end;

   if fPromptIndex<fCountPromptTokens then begin

    Token:=fPromptTokens[fPromptIndex];
    inc(fPromptIndex);

    if fPromptIndex>=fCountPromptTokens then begin
     SetState(TState.SetupToolPromptProcessing);
    end;

    fNextToken:=Token;

    fTokenList.Add(fNextToken);

    fPreviousToken:=fNextToken;

    result:=true;

   end else begin

    SetState(TState.SetupToolPromptProcessing);
    result:=true;

   end;

  end;

  /////////////////////////////////////////////////////////////////////////////////

  TState.Aborted:begin
   result:=false;
  end;

  /////////////////////////////////////////////////////////////////////////////////

  else begin

   // Invalid state, terminate

   SetState(TState.Terminated);
   result:=false;

  end;

  /////////////////////////////////////////////////////////////////////////////////

 end;

end;

procedure TPasLLMModelInferenceInstance.TChatSession.Run(const aMaxSteps:TPasLLMInt32);
begin
 fMaxSteps:=aMaxSteps;
 while Step do begin
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.Abort;
begin
 SetState(TState.Aborted);
end;

procedure TPasLLMModelInferenceInstance.TChatSession.ForceAbort;
begin
 fState:=TState.Aborted;
end;

function TPasLLMModelInferenceInstance.TChatSession.DefaultOnInput(const aSender:TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
begin
 Write(aPrompt);
 ReadLn(result);
end;

procedure TPasLLMModelInferenceInstance.TChatSession.DefaultOnOutput(const aSender:TChatSession;const aText:TPasLLMUTF8String);
begin
 Write(aText);
end;

class function TPasLLMModelInferenceInstance.TChatSession.StateToString(const aState:TState):TPasLLMUTF8String;
begin
 case aState of
  TState.Unknown:begin
   result:='unknown';
  end;
  TState.ProcessingPlaybackTokens:begin
   result:='processing_playback_tokens';
  end;
  TState.Initial:begin
   result:='initial';
  end;
  TState.SystemPromptInput:begin
   result:='system_prompt_input';
  end;
  TState.UserInput:begin
   result:='user_input';
  end;
  TState.SetupUserPromptProcessing:begin
   result:='setup_user_prompt_processing';
  end;
  TState.ProcessingUserPromptToken:begin
   result:='processing_user_prompt_token';
  end;
  TState.SetupAssistantAnswerGenerating:begin
   result:='setup_assistant_answer_generating';
  end;
  TState.GeneratingAssistantAnswer:begin
   result:='generating_assistant_answer';
  end;
  TState.ProcessPendingToolCalls:begin
   result:='process_pending_tool_calls';
  end;
  TState.SetupToolPromptProcessing:begin
   result:='setup_tool_prompt_processing';
  end;
  TState.ProcessingToolPromptToken:begin
   result:='processing_tool_prompt_token';
  end;
  TState.Terminated:begin
   result:='terminated';
  end;
  else begin
   result:='unknown';
  end;
 end;
end;

class function TPasLLMModelInferenceInstance.TChatSession.StringToState(const aStateString:TPasLLMUTF8String):TState;
begin
 if aStateString='unknown' then begin
  result:=TState.Unknown;
 end else if aStateString='processing_playback_tokens' then begin
  result:=TState.ProcessingPlaybackTokens;
 end else if aStateString='initial' then begin
  result:=TState.Initial;
 end else if aStateString='system_prompt_input' then begin
  result:=TState.SystemPromptInput;
 end else if aStateString='user_input' then begin
  result:=TState.UserInput;
 end else if aStateString='setup_user_prompt_processing' then begin
  result:=TState.SetupUserPromptProcessing;
 end else if aStateString='processing_user_prompt_token' then begin
  result:=TState.ProcessingUserPromptToken;
 end else if aStateString='setup_assistant_answer_generating' then begin
  result:=TState.SetupAssistantAnswerGenerating;
 end else if aStateString='generating_assistant_answer' then begin
  result:=TState.GeneratingAssistantAnswer;
 end else if aStateString='process_pending_tool_calls' then begin
  result:=TState.ProcessPendingToolCalls;
 end else if aStateString='setup_tool_prompt_processing' then begin
  result:=TState.SetupToolPromptProcessing;
 end else if aStateString='processing_tool_prompt_token' then begin
  result:=TState.ProcessingToolPromptToken;
 end else if aStateString='terminated' then begin
  result:=TState.Terminated;
 end else begin
  result:=TState.Unknown;
 end;
end;

function TPinjaChatTemplateThinkModeToString(const aThinkMode:TPinjaChatTemplateThinkMode):TPasLLMUTF8String;
begin
 case aThinkMode of
  TPinjaChatTemplateThinkMode.Auto:begin
   result:='auto';
  end;
  TPinjaChatTemplateThinkMode.Enable:begin
   result:='enable';
  end;
  TPinjaChatTemplateThinkMode.Disable:begin
   result:='disable';
  end;
  else begin
   result:='auto';
  end;
 end;
end;

function StringToTPinjaChatTemplateThinkMode(const aThinkModeString:TPasLLMUTF8String):TPinjaChatTemplateThinkMode;
begin
 if aThinkModeString='auto' then begin
  result:=TPinjaChatTemplateThinkMode.Auto;
 end else if aThinkModeString='enable' then begin
  result:=TPinjaChatTemplateThinkMode.Enable;
 end else if aThinkModeString='disable' then begin
  result:=TPinjaChatTemplateThinkMode.Disable;
 end else begin
  result:=TPinjaChatTemplateThinkMode.Auto;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.EnableTools(const aEnabled:Boolean);
begin
 fToolsEnabled:=aEnabled;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddToolResult(const aToolResult:TToolResult);
begin
 fToolResults.Add(aToolResult);
end;

procedure TPasLLMModelInferenceInstance.TChatSession.SetAvailableTools(const aTools:TPasJSONItemArray);
begin
 if assigned(fAvailableTools) then begin
  FreeAndNil(fAvailableTools);
 end;
 if assigned(aTools) then begin
  fAvailableTools:=TPasJSONItemArray(aTools.Clone);
 end else begin
  fAvailableTools:=TPasJSONItemArray.Create;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddAvailableTool(const aToolDefinition:TPasJSONItemObject);
begin
 if assigned(fAvailableTools) and assigned(aToolDefinition) then begin
  fAvailableTools.Add(aToolDefinition.Clone);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.ClearAvailableTools;
begin
 if assigned(fAvailableTools) then begin
  fAvailableTools.Clear;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.ClearMessages;
begin
 if assigned(fMessages) then begin
  fMessages.Clear;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetMessageCount:TPasLLMInt32;
begin
 if assigned(fMessages) then begin
  result:=fMessages.Count;
 end else begin
  result:=0;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetMessage(const aIndex:TPasLLMInt32):TMessage;
begin
 if assigned(fMessages) and (aIndex>=0) and (aIndex<fMessages.Count) then begin
  result:=fMessages[aIndex];
 end else begin
  result:=nil;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadFromJSON(const aJSON:TPasLLMUTF8String);
var JSONObject:TPasJSONItem;
begin
 JSONObject:=TPasJSON.Parse(aJSON);
 try
  if assigned(JSONObject) and (JSONObject is TPasJSONItemObject) then begin
   LoadSessionContentFromJSONObject(TPasJSONItemObject(JSONObject));
  end else begin
   raise EPasLLM.Create('Invalid JSON format for chat session');
  end;
 finally
  FreeAndNil(JSONObject);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadFromJSONFile(const aFileName:TPasLLMUTF8String);
var Stream:TStream;
    JSONObject:TPasJSONItem;
begin
 Stream:=TMemoryStream.Create;
 try
  TMemoryStream(Stream).LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  JSONObject:=TPasJSON.Parse(Stream);
  try
   if assigned(JSONObject) and (JSONObject is TPasJSONItemObject) then begin
    LoadSessionContentFromJSONObject(TPasJSONItemObject(JSONObject));
   end else begin
    raise EPasLLM.Create('Invalid JSON format for chat session');
   end;
  finally
   FreeAndNil(JSONObject);
  end;
 finally
  FreeAndNil(Stream);
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.LoadSessionModelInfoFromJSONFile(const aFileName:TPasLLMUTF8String;var aModelInfo:TPasLLMUTF8String):Boolean;
var Stream:TStream;
    JSONItem:TPasJSONItem;
    JSONObject:TPasJSONItemObject;
begin
 result:=false;
 aModelInfo:='';
 Stream:=TMemoryStream.Create;
 try
  TMemoryStream(Stream).LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  JSONItem:=TPasJSON.Parse(Stream);
  try
   if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
    JSONObject:=TPasJSONItemObject(JSONItem);
    // Extract model information directly
    if assigned(JSONObject.Properties['model_info']) then begin
     aModelInfo:=TPasJSON.GetString(JSONObject.Properties['model_info'],'');
     fToolsEnabled:=TPasJSON.GetBoolean(JSONObject.Properties['tools_enabled'],false);
     result:=length(aModelInfo)>0;
    end;
   end;
  finally
   FreeAndNil(JSONItem);
  end;
 finally
  FreeAndNil(Stream);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadSessionContentFromJSONFile(const aFileName:TPasLLMUTF8String);
var Stream:TStream;
    JSONObject:TPasJSONItem;
    JSONObjectObj:TPasJSONItemObject;
begin
 Stream:=TMemoryStream.Create;
 try
  TMemoryStream(Stream).LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  JSONObject:=TPasJSON.Parse(Stream);
  try
   if assigned(JSONObject) and (JSONObject is TPasJSONItemObject) then begin
    JSONObjectObj:=TPasJSONItemObject(JSONObject);
    // Load content without model info processing
    LoadSessionContentFromJSONObject(JSONObjectObj);
   end else begin
    raise EPasLLM.Create('Invalid JSON format for chat session');
   end;
  finally
   FreeAndNil(JSONObject);
  end;
 finally
  FreeAndNil(Stream);
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.SaveToJSON:TPasLLMUTF8String;
var JSONObject:TPasJSONItemObject;
begin
 JSONObject:=SaveToJSONObject;
 try
  result:=TPasJSON.Stringify(JSONObject,false,[]);
 finally
  FreeAndNil(JSONObject);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.SaveToJSONFile(const aFileName:TPasLLMUTF8String);
var Stream:TStream;
    JSONObject:TPasJSONItemObject;
    s:TPasLLMUTF8String;
begin 
 JSONObject:=SaveToJSONObject;
 try
  s:=TPasJSON.Stringify(JSONObject,false,[]);
 finally
  FreeAndNil(JSONObject);
 end;
 Stream:=TMemoryStream.Create;
 try
  if length(s)>0 then begin
   Stream.WriteBuffer(s[1],length(s));
  end; 
  TMemoryStream(Stream).SaveToFile(aFileName);
 finally
  FreeAndNil(Stream);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.LoadSessionContentFromJSONObject(const aJSONObject:TPasJSONItemObject);
var MessagesArray:TPasJSONItemArray;
    MessageObject:TPasJSONItemObject;
    TokenListArray:TPasJSONItemArray;
    Message:TMessage;
    Index,Version,Token:TPasLLMInt32;
begin
 ClearMessages;
 
 // Check version for compatibility
 Version:=TPasJSON.GetInt64(aJSONObject.Properties['version'],1); // Default version 1
 
 // For future version compatibility checks
 if Version>1 then begin
  raise EPasLLM.Create('Unsupported chat session version: '+IntToStr(Version));
 end;

 // Skip model information - it's handled separately by LoadSessionModelInfoFromJSONFile

 fTitle:=TPasJSON.GetString(aJSONObject.Properties['title'],'');

 fTimeStamp:=TPasJSON.GetNumber(aJSONObject.Properties['timestamp'],Now);

 fSystemPrompt:=TPasJSON.GetString(aJSONObject.Properties['system_prompt'],'');

 fToolsEnabled:=TPasJSON.GetBoolean(aJSONObject.Properties['tools_enabled'],false);

 fThinkMode:=StringToTPinjaChatTemplateThinkMode(TPasJSON.GetString(aJSONObject.Properties['think_mode']));

 fMaxSteps:=TPasJSON.GetInt64(aJSONObject.Properties['max_steps'],0);

 fCurrentStep:=TPasJSON.GetInt64(aJSONObject.Properties['current_step'],0);

 fState:=StringToState(TPasJSON.GetString(aJSONObject.Properties['state'],'unknown'));

 // Load available tools if present
 if assigned(aJSONObject.Properties['available_tools']) and (aJSONObject.Properties['available_tools'] is TPasJSONItemArray) then begin
  if assigned(fAvailableTools) then begin
   FreeAndNil(fAvailableTools);
  end;
  fAvailableTools:=TPasJSONItemArray(aJSONObject.Properties['available_tools'].Clone);
 end;
 
 if assigned(aJSONObject.Properties['messages']) and (aJSONObject.Properties['messages'] is TPasJSONItemArray) then begin
  MessagesArray:=TPasJSONItemArray(aJSONObject.Properties['messages']);
  for Index:=0 to MessagesArray.Count-1 do begin
   if assigned(MessagesArray.Items[Index]) and (MessagesArray.Items[Index] is TPasJSONItemObject) then begin
    MessageObject:=TPasJSONItemObject(MessagesArray.Items[Index]);
    Message:=TMessage.Create('','');
    try
     Message.FromJSON(MessageObject);
     fMessages.Add(Message);
    except
     FreeAndNil(Message);
     raise;
    end;
   end;
  end;
 end;

// Load token list if present
 if assigned(aJSONObject.Properties['token_list']) and (aJSONObject.Properties['token_list'] is TPasJSONItemArray) then begin
  TokenListArray:=TPasJSONItemArray(aJSONObject.Properties['token_list']);
  fPlaybackTokenList.Clear;
  fSavedTokenList.Clear;
  for Index:=0 to TokenListArray.Count-1 do begin
   Token:=TPasJSON.GetInt64(TokenListArray.Items[Index],0);
   fPlaybackTokenList.Add(Token);
   fSavedTokenList.Add(Token);
  end;
 end else begin
  fPlaybackTokenList.Clear; 
  fSavedTokenList.Clear;
 end;

 // Load saved hash for model compatibility check
 fSavedHash:=StringToUInt64(TPasJSON.GetString(aJSONObject.Properties['model_hash'],''));

 // Prepare session for continuation if needed
 PrepareSessionContinuation;

end;

function TPasLLMModelInferenceInstance.TChatSession.SaveToJSONObject:TPasJSONItemObject;
var MessagesArray:TPasJSONItemArray;
    TokenListArray:TPasJSONItemArray;
    Index:TPasLLMInt32;
    ModelInfo:TPasLLMUTF8String;
begin
 result:=TPasJSONItemObject.Create;
 try
  result.Add('version',TPasJSONItemNumber.Create(1));
  result.Add('title',TPasJSONItemString.Create(fTitle));
  result.Add('timestamp',TPasJSONItemNumber.Create(fTimeStamp));
  result.Add('system_prompt',TPasJSONItemString.Create(fSystemPrompt));
  result.Add('tools_enabled',TPasJSONItemBoolean.Create(fToolsEnabled));
  result.Add('think_mode',TPasJSONItemString.Create(TPinjaChatTemplateThinkModeToString(fThinkMode)));
  result.Add('max_steps',TPasJSONItemNumber.Create(fMaxSteps));
  result.Add('current_step',TPasJSONItemNumber.Create(fCurrentStep));
  result.Add('state',TPasJSONItemString.Create(StateToString(fState)));
  
  // Add model information via callback
  if assigned(fOnGetModelInfo) then begin
   ModelInfo:=fOnGetModelInfo(Self);
   if length(ModelInfo)>0 then begin
    result.Add('model_info',TPasJSONItemString.Create(ModelInfo));
   end;
  end;
  
  // Add available tools if any
  if assigned(fAvailableTools) and (fAvailableTools.Count>0) then begin
   result.Add('available_tools',fAvailableTools.Clone);
  end;
  
  MessagesArray:=TPasJSONItemArray.Create;
  try
   for Index:=0 to fMessages.Count-1 do begin
    MessagesArray.Add(fMessages[Index].ToJSON(false));
   end;
   result.Add('messages',MessagesArray);
  except
   FreeAndNil(MessagesArray);
   raise;
  end;

  TokenListArray:=TPasJSONItemArray.Create;
  try
   if fTokenList.Count<fSavedTokenList.Count then begin
    // If we have fewer tokens than saved, save the saved list to avoid losing tokens in re-saving 
    for Index:=0 to fSavedTokenList.Count-1 do begin
     TokenListArray.Add(TPasJSONItemNumber.Create(fSavedTokenList.Get(Index)));
    end;
   end else begin
    for Index:=0 to fTokenList.Count-1 do begin
     TokenListArray.Add(TPasJSONItemNumber.Create(fTokenList.Get(Index)));
    end;
   end;
   result.Add('token_list',TokenListArray);  
  except
   FreeAndNil(TokenListArray);
   raise;
  end;

  result.Add('model_hash',TPasJSONItemString.Create(UInt64ToString(fOwner.fModel.fHash)));
  
 except
  FreeAndNil(result);
  raise;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.IsWaitingForUser:Boolean;
begin
 result:=(fState=TState.UserInput);
end;

function TPasLLMModelInferenceInstance.TChatSession.IsGenerating:Boolean;
begin
 result:=(fState=TState.GeneratingAssistantAnswer);
end;

function TPasLLMModelInferenceInstance.TChatSession.IsComplete:Boolean;
begin
 result:=(fState=TState.Terminated);
end;

function TPasLLMModelInferenceInstance.TChatSession.IsWaitingForToolResult:Boolean;
begin
 result:=(fState=TState.ProcessPendingToolCalls) or (fPendingToolCalls.Count>0);
end;

function TPasLLMModelInferenceInstance.TChatSession.GetProgress:Double;
begin
 if fMaxSteps>0 then begin
  result:=fCurrentStep/fMaxSteps;
  if result>1.0 then begin
   result:=1.0;
  end;
 end else begin
  result:=0.0;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetTokensPerSecond:Double;
var TotalTime:TPasLLMUInt64;
    TotalTokens:TPasLLMUInt64;
begin
 if assigned(self) then begin
  TotalTime:=fPromptAccumulatedTime+fOutputAccumulatedTime;
  TotalTokens:=fPromptAccumulatedTokens+fOutputAccumulatedTokens;
  if TotalTime>0 then begin
   result:=TotalTokens/(TotalTime*1e-6);
  end else begin
   result:=0.0;
  end;
 end else begin
  result:=0.0;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetPromptTokensPerSecond:Double;
begin
 if assigned(self) and (fPromptAccumulatedTime>0.0) then begin
  result:=fPromptAccumulatedTokens/(fPromptAccumulatedTime*1e-6);
 end else begin
  result:=0.0;
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.GetOutputTokensPerSecond:Double;
begin
 if assigned(self) and (fOutputAccumulatedTime>0.0) then begin
  result:=fOutputAccumulatedTokens/(fOutputAccumulatedTime*1e-6);
 end else begin
  result:=0.0;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.HandleSpecialCommands(var aUserPrompt:TPasLLMUTF8String);
var Output:TPasLLMUTF8String;
begin
 // Handle special commands like /think, /no_think, /quit, /stat
 if (length(aUserPrompt)>=9) and (copy(aUserPrompt,1,9)='/no_think') then begin
  fThinkMode:=TPinjaChatTemplateThinkMode.Disable;
  aUserPrompt:=copy(aUserPrompt,10,length(aUserPrompt)-9);
 end else if (length(aUserPrompt)>=6) and (copy(aUserPrompt,1,6)='/think') then begin
  fThinkMode:=TPinjaChatTemplateThinkMode.Enable;
  aUserPrompt:=copy(aUserPrompt,7,length(aUserPrompt)-6);
 end else if (length(aUserPrompt)>=11) and (copy(aUserPrompt,1,11)='/auto_think') then begin
  fThinkMode:=TPinjaChatTemplateThinkMode.Auto;
  aUserPrompt:=copy(aUserPrompt,12,length(aUserPrompt)-11);
 end else if aUserPrompt='/stat' then begin
  
  if assigned(fOnOutput) then begin
   
   Str((fPromptAccumulatedTokens/(fPromptAccumulatedTime*1e-6)):0:2,Output); // Format the achieved tokens per second
   fOnOutput(self,'Achieved prompt tokens per second: '+Output+#10); // Print achieved tokens per second
   
   Str((fOutputAccumulatedTokens/(fOutputAccumulatedTime*1e-6)):0:2,Output); // Format the achieved tokens per second
   fOnOutput(self,'Achieved output tokens per second: '+Output+#10); // Print achieved tokens per second
   
   Str(((fPromptAccumulatedTokens+fOutputAccumulatedTokens)/(Max(1,(fPromptAccumulatedTime+fOutputAccumulatedTime)*1e-6))):0:2,Output); // Format the total achieved tokens per second
   fOnOutput(self,'Achieved total tokens per second: '+Output+#10); // Print total achieved tokens per second

   if assigned(fOnSideTurn) then begin
    fOnSideTurn(self,'User');
   end;

  end;
  
  aUserPrompt:='';
  
 end else if aUserPrompt='/quit' then begin
  SetState(TState.Terminated);
  aUserPrompt:='';
 end;
end;

function TPasLLMModelInferenceInstance.TChatSession.RenderPromptWithTools(const aOnlyLastMessage:Boolean;const aMessageIndex:TPasLLMInt32):TPasLLMUTF8String;
var ChatTemplateInputs:TPinjaChatTemplateInputs;
    JSONTools:TPasJSONItemArray;
    JSONTool,JSONToolFunction:TPasJSONItemObject;
    JSONMessages:TPasJSONItemArray;
    JSONMessage:TPasJSONItemObject;
    JSONArguments:TPasJSONItemArray;
    JSONArgument:TPasJSONItemObject;
    ToolCallsArray:TPasJSONItemArray;
    Message:TMessage;
    Index,ArgumentIndex,ToolCallIndex:TPasLLMInt32;
    StartIndex,EndIndex:TPasLLMInt32;
    Tool:TTool;
    ToolArgument:TTool.TArgument;
begin
 result:='';
 
 if not assigned(fChatTemplate) then begin
  fChatTemplate:=TPinjaChatTemplate.Create(fOwner.fModel.fTokenizer.fChatTemplate,'','');
 end;
 
 ChatTemplateInputs:=TPinjaChatTemplateInputs.Create;
 try

  JSONTools:=TPasJSONItemArray.Create;
  try

   if fToolsEnabled then begin 
   
    for Index:=0 to fTools.Count-1 do begin
     Tool:=fTools[Index];
     if assigned(Tool) and (length(Tool.fName)>0) and Tool.fEnabled then begin
      JSONTool:=TPasJSONItemObject.Create;
      try
       JSONTool.Add('type',TPasJSONItemString.Create('function'));
       JSONToolFunction:=TPasJSONItemObject.Create;
       try
        JSONToolFunction.Add('name',TPasJSONItemString.Create(Tool.fName));
        if length(Tool.fDescription)>0 then begin
         JSONToolFunction.Add('description',TPasJSONItemString.Create(Tool.fDescription));
        end;
        JSONArguments:=TPasJSONItemArray.Create;
        try
         for ArgumentIndex:=0 to Tool.fArguments.Count-1 do begin
          ToolArgument:=Tool.fArguments[ArgumentIndex];
          if assigned(ToolArgument) and (length(ToolArgument.fName)>0) then begin
           JSONArgument:=TPasJSONItemObject.Create;
           try
            JSONArgument.Add(ToolArgument.fName,TPasJSONItemString.Create(ToolArgument.fExample));
           finally
            JSONArguments.Add(JSONArgument);
           end;
          end;
         end; 
        finally
         JSONToolFunction.Add('arguments',JSONArguments);
        end;        
{       if length(Tool.fID)>0 then begin
         JSONToolFunction.Add('id',TPasJSONItemString.Create(Tool.fID));
        end;}
       finally
        JSONTool.Add('function',JSONToolFunction);
       end; 
      finally
       JSONTools.Add(JSONTool);
      end;
     end;
    end;
       
   end; 

   JSONMessages:=TPasJSONItemArray.Create;
   try

    // Add system prompt if present (unless only last message requested)
    if (not aOnlyLastMessage) and (length(Trim(fSystemPrompt))>0) then begin
     JSONMessage:=TPasJSONItemObject.Create;
     try
      JSONMessage.Add('role',TPasJSONItemString.Create('system'));
      JSONMessage.Add('content',TPasJSONItemString.Create(fSystemPrompt));
     finally
      JSONMessages.Add(JSONMessage);
     end;
    end;

    // Calculate start and end index based on parameters
    if aMessageIndex>=0 then begin
     // Render messages up to and including the specified index
     StartIndex:=0;
     EndIndex:=Min(aMessageIndex,fMessages.Count-1);
    end else if aOnlyLastMessage then begin
     StartIndex:=Max(0,fMessages.Count-1);
     EndIndex:=fMessages.Count-1;
    end else begin
     StartIndex:=0;
     EndIndex:=fMessages.Count-1;
    end;

    // Add messages based on calculated range
    for Index:=StartIndex to EndIndex do begin

     Message:=fMessages[Index];

     JSONMessage:=TPasJSONItemObject.Create;
     try
      JSONMessage.Add('role',TPasJSONItemString.Create(Message.Role));
      JSONMessage.Add('content',TPasJSONItemString.Create(Message.Content));

      if length(Message.ToolName)>0 then begin
       JSONMessage.Add('name',TPasJSONItemString.Create(Message.ToolName));
      end;

      if length(Message.ToolCallID)>0 then begin
       JSONMessage.Add('tool_call_id',TPasJSONItemString.Create(Message.ToolCallID));
      end;

      // Add tool calls if present
      if Message.HasToolCalls then begin
       ToolCallsArray:=TPasJSONItemArray.Create;
       try
        for ToolCallIndex:=0 to Message.ToolCalls.Count-1 do begin
         ToolCallsArray.Add(Message.ToolCalls[ToolCallIndex].ToJSON(true));
        end;
        JSONMessage.Add('tool_calls',ToolCallsArray);
       except
        FreeAndNil(ToolCallsArray);
        raise;
       end;
      end;

     finally
      JSONMessages.Add(JSONMessage);
     end;
    end;

    ChatTemplateInputs.Messages:=JSONMessages.Clone;
    if fToolsEnabled then begin 
     ChatTemplateInputs.Tools:=JSONTools.Clone;
    end; 
    ChatTemplateInputs.AddGenerationPrompt:=true;
    ChatTemplateInputs.ThinkMode:=fThinkMode;

    // Set available tools if any are defined
    if assigned(fAvailableTools) and (fAvailableTools.Count>0) then begin
     ChatTemplateInputs.Tools:=fAvailableTools.Clone;
    end;

    result:=fChatTemplate.Apply(ChatTemplateInputs);

   finally
    FreeAndNil(JSONMessages);
   end;

  finally
   FreeAndNil(JSONTools);
  end;

 finally
  FreeAndNil(ChatTemplateInputs);
 end;

end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddToolCall(const aContent:TPasLLMUTF8String); // Parse and process tool calls from model output
var JSONItem,JSONItemArrayItem:TPasJSONItem;
    JSONItemArray:TPasJSONItemArray;
    Index:TPasLLMSizeInt;
    ToolCall:TToolCall;
begin
 JSONItem:=TPasJSON.Parse(aContent);
 try
  if assigned(JSONItem) then begin
   if JSONItem is TPasJSONItemArray then begin
    JSONItemArray:=TPasJSONItemArray(JSONItem);
    for Index:=0 to JSONItemArray.Count-1 do begin
     JSONItemArrayItem:=JSONItemArray.Items[Index];
     if assigned(JSONItemArrayItem) and (JSONItemArrayItem is TPasJSONItemObject) then begin
      ToolCall:=TToolCall.Create(TPasJSONItemObject(JSONItemArrayItem));
      if assigned(ToolCall) then begin
       fPendingToolCalls.Add(ToolCall);
      end;
     end;
    end;
   end else if JSONItem is TPasJSONItemObject then begin
    ToolCall:=TToolCall.Create(TPasJSONItemObject(JSONItem));
    if assigned(ToolCall) then begin
     fPendingToolCalls.Add(ToolCall);
    end;
   end;
  end;
 finally
  FreeAndNil(JSONItem);
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddToolResultMessage(const aToolResult:TToolResult);
var Message:TMessage;
begin
 Message:=TMessage.Create('tool',aToolResult.Content);
 try
  Message.ToolName:=aToolResult.ToolName;
  Message.ToolCallID:=aToolResult.ToolCallID;
  fMessages.Add(Message);
  if assigned(fOnMessage) then begin
   fOnMessage(self,Message);
  end;
 except
  FreeAndNil(Message);
  raise;
 end;
end;

procedure TPasLLMModelInferenceInstance.TChatSession.AddPlaybackTokens(const aContent:TPasLLMUTF8String);
var AdditionalTokens:TPasLLMInt32DynamicArray;
    AdditionalTokenCount:TPasLLMSizeInt;
    TokenIndex:TPasLLMInt32;
begin
 // Tokenize the content
 AdditionalTokenCount:=0;
 fOwner.fModel.fTokenizer.Encode(aContent,false,false,AdditionalTokens,AdditionalTokenCount);
 
 // Optimize array resizing
 if length(fPlaybackPromptTokens)<(fCountPlaybackPromptTokens+AdditionalTokenCount) then begin
  SetLength(fPlaybackPromptTokens,(fCountPlaybackPromptTokens+AdditionalTokenCount)*2);
 end;
 
 // Add tokens to playback sequence
 for TokenIndex:=0 to AdditionalTokenCount-1 do begin
  fPlaybackPromptTokens[fCountPlaybackPromptTokens+TokenIndex]:=AdditionalTokens[TokenIndex];
 end;
 inc(fCountPlaybackPromptTokens,AdditionalTokenCount);
end;

procedure TPasLLMModelInferenceInstance.TChatSession.PrepareSessionContinuation;
var TokenIndex,MessageIndex,Token:TPasLLMInt32;
    CurrentMessage:TMessage;
    RenderedPrompt:TPasLLMUTF8String;
    TemplateHasMessagesLoop:Boolean;
begin

 fOnlyLastMessage:=true;

 // Check if we have messages and need to continue
 if fMessages.Count=0 then begin
  exit; // Nothing to continue
 end;
 
 // Backup current state before starting playback processing
 fBackupStateForPlayback:=fState;
 case fBackupStateForPlayback of
  TState.ProcessingPlaybackTokens:begin
   fBackupStateForPlayback:=TState.UserInput;
  end;
  else begin
  end;
 end;

 // Start with empty playback token sequence
 fCountPlaybackPromptTokens:=0;
 fPlaybackPromptTokens:=nil;
 fTokenList.Clear;

 // If we have a saved token list and the model hash matches, use it directly 
 if (fPlaybackTokenList.Count>0) and (fSavedHash=fOwner.fModel.fHash) then begin

  fPlaybackPromptTokens:=nil;
  fCountPlaybackPromptTokens:=fPlaybackTokenList.Count;

  SetLength(fPlaybackPromptTokens,fCountPlaybackPromptTokens);
  for TokenIndex:=0 to fPlaybackTokenList.Count-1 do begin 
   Token:=fPlaybackTokenList.Get(TokenIndex);
   fPlaybackPromptTokens[TokenIndex]:=Token;
   fTokenList.Add(Token);
  end;
 
 end else begin

  // Otherwise, we need to re-render the prompt from messages
  // This may be less efficient but ensures compatibility with model changes

  // Check if the chat template contains a messages array processing loop
  TemplateHasMessagesLoop:=false;
  if assigned(fChatTemplate) then begin
   // Scan the template AST for messages loop constructs
   // Look for patterns like "{% for message in messages %}" or similar
   TemplateHasMessagesLoop:=fChatTemplate.ContainsMessagesLoop;
  end;
  
  if TemplateHasMessagesLoop then begin

   // Template handles message iteration internally - single call
   RenderedPrompt:=RenderPromptWithTools(false);
   AddPlaybackTokens(RenderedPrompt);

  end else begin

   // Template doesn't handle messages loop - we need to process individually

   // Replay each message by re-rendering the chat template incrementally
   for MessageIndex:=0 to fMessages.Count-1 do begin

    // Re-render chat template with messages up to this point
    RenderedPrompt:=RenderPromptWithTools(true,MessageIndex);
    AddPlaybackTokens(RenderedPrompt);

    // Also handle tool calls if present
    CurrentMessage:=fMessages[MessageIndex];
    if (CurrentMessage.Role='assistant') and CurrentMessage.HasToolCalls then begin
     AddPlaybackTokens('</tool_calls>');
    end;

   end;

  end;

 end;

 // Simple setup after replaying all messages
 fPromptIndex:=0;
 fCurrentPosition:=0;
 fNextToken:=0;
 fPreviousOutput:='';
 fPlaybackPromptTokenIndex:=0; // Start playback from beginning
 // Note: Don't set state here - it should have been restored from saved session data
 
 // The Step() function will now replay the entire token sequence silently
 // until fPlaybackPromptTokenIndex reaches fCountPlaybackPromptTokens, then start new generation
 
 // Set state to start playback processing if we have playback tokens
 if fCountPlaybackPromptTokens>0 then begin
  SetState(TState.ProcessingPlaybackTokens);
 end;

end;

{ TPasLLMModelInferenceInstance }

constructor TPasLLMModelInferenceInstance.Create(const aModel:TPasLLMModel;const aSeed:TPasLLMUInt64);
begin
 inherited Create; // Call the inherited constructor

 fModel:=aModel; // Get the model instance from the PasLLM

 fPasLLM:=fModel.fPasLLM; // Store the reference to the PasLLM instance for memory mapping

 fRunState:=TPasLLMRunState.Create(fModel); // Create the run state for the model inference

 fSamplerPenalties:=TPasLLMSamplerPenalties.Create(fPasLLM,fModel.fConfiguration); // Create the sampler penalties instance

 fSampler:=TPasLLMSampler.Create(self); // Create the sampler instance

 if assigned(fPasLLM.fPasMPInstance) then begin
  fJobManager:=nil;//TPasLLMJobManager.Create(self);
 end else begin
  fJobManager:=nil;
 end;

 fSteps:=0; // number of steps to run for

 fOnInput:=DefaultOnInput; // Default input handler
 fOnOutput:=DefaultOnOutput; // Default output handler
 fOnSideTurn:=nil;
 fOnCheckTerminated:=nil; // Default termination check handler
 fOnCheckAbort:=nil; // Default abort check handler

 if aSeed=0 then begin
  fPCG32.Init(GetTickCount64); // Initialize the PCG32 random number generator with the current time
 end else begin
  fPCG32.Init(aSeed); // Initialize the PCG32 random number generator
 end;

end;

destructor TPasLLMModelInferenceInstance.Destroy;
begin
 if assigned(fJobManager) then begin
  fJobManager.Shutdown;
  FreeAndNil(fJobManager);
 end;
 FreeAndNil(fSampler);
 FreeAndNil(fSamplerPenalties);
 FreeAndNil(fRunState);
 fModel:=nil;
 inherited Destroy; // Call the inherited destructor
end;

function TPasLLMModelInferenceInstance.GetTemperature:TPasLLMFloat;
begin
 result:=fSampler.fTemperature; // Get the current temperature from the sampler
end;

function TPasLLMModelInferenceInstance.ChatOnInput(const aSender:TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
begin
 if length(fChatInput)>0 then begin
  result:=fChatInput;
  fChatInput:='';
 end else begin
  result:='/quit';
 end;
end;

procedure TPasLLMModelInferenceInstance.ChatOnOutput(const aSender:TChatSession;const aOutput:TPasLLMUTF8String);
begin
 fChatOutput:=fChatOutput+aOutput;
end;

procedure TPasLLMModelInferenceInstance.ChatOnSideTurn(const aSender:TChatSession;const aSide:TPasLLMUTF8String);
begin
 //
end;

procedure TPasLLMModelInferenceInstance.SetTemperature(const aValue:TPasLLMFloat);
begin
 fSampler.SetTemperature(aValue); // Set the temperature for sampling
end;

function TPasLLMModelInferenceInstance.GetTopP:TPasLLMFloat;
begin
 result:=fSampler.fTopP; // Get the current top-p value from the sampler
end;

procedure TPasLLMModelInferenceInstance.SetTopP(const aValue:TPasLLMFloat);
begin
 fSampler.SetTopP(aValue); // Set the top-p value for nucleus sampling
end;

procedure TPasLLMModelInferenceInstance.SetSteps(const aValue:TPasLLMInt32);
begin
 if aValue<0 then begin
  fSteps:=0; // Clamp the steps to a minimum of 0
 end else begin
  fSteps:=aValue; // Set the number of steps to run for
 end;
end;

procedure TPasLLMModelInferenceInstance.Reset;
begin
 fRunState.Reset;
end;

class function TPasLLMModelInferenceInstance.RoPEYaRNCorrectionDimension(const aCountDim,aCountOriginalCtx:TPasLLMInt32;const aCountRotation,aBase:TPasLLMFloat):TPasLLMFloat;
begin
 // Calculate the correction dimension based on the count of dimensions, original context, rotation count, and base
 result:=aCountDim*Ln(aCountOriginalCtx/(aCountRotation*2.0*PI))/(2.0*Ln(aBase)); // Use logarithm to calculate the correction dimension
end;

class procedure TPasLLMModelInferenceInstance.RoPEYaRNCorrectionDimensions(const aCountDim,aCountOriginalCtx:TPasLLMInt32;const aFrequencyBase,aBetaFast,aBetaSlow:TPasLLMFloat;out aCorrDimsV0,aCorrDimsV1:TPasLLMFloat);
var StartCorrectionDimension,EndCorrectionDimension:TPasLLMFloat;
begin

 // Calculate the start and end correction dimensions based on the count of dimensions, original context, frequency base, and beta values
 StartCorrectionDimension:=RoPEYaRNCorrectionDimension(aCountDim,aCountOriginalCtx,aBetaFast,aFrequencyBase); // Calculate the start correction dimension
 EndCorrectionDimension:=RoPEYaRNCorrectionDimension(aCountDim,aCountOriginalCtx,aBetaSlow,aFrequencyBase); // Calculate the end correction dimension

 // Clamp the correction dimensions to valid ranges
 aCorrDimsV0:=Max(0.0,StartCorrectionDimension); // Ensure the start correction dimension is not negative
 aCorrDimsV1:=Min(aCountDim-1.0,EndCorrectionDimension); // Ensure the end correction dimension does not exceed the count of dimensions

end;

class function TPasLLMModelInferenceInstance.RoPEYaRNRamp(const aLow,aHigh:TPasLLMFloat;const aI0:TPasLLMInt32):TPasLLMFloat;
begin
 // Calculate the ramp value based on the low and high values and the index
 result:=((aI0 shr 1)-aLow)/Max(0.001,aHigh-aLow);
 result:=1.0-Min(1.0,Max(0.0,result)); // Clamp the result between 0.0 and 1.0
end;

class procedure TPasLLMModelInferenceInstance.RoPEYaRN(const aThetaExtrapolation,aFrequencyScale:TPasLLMFloat;const aCorrDimsV0,aCorrDimsV1:TPasLLMFloat;const aI0:TPasLLMInt32;const aExtrapolationFactor,aMagnitudeScale:TPasLLMFloat;out aSinTheta,aCosTheta:TPasLLMFloat);
var ThetaInterpolation,Theta,RampMix,MagnitudeScale:TPasLLMFloat;
begin

 // Get n-d rotational scaling corrected for extrapolation
 ThetaInterpolation:=aFrequencyScale*aThetaExtrapolation; // Calculate the interpolated theta value
 Theta:=ThetaInterpolation; // Initialize theta with the interpolated value
 
 if abs(aExtrapolationFactor)>0.0 then begin

  // Calculate the ramp mix based on the correlation dimensions and extrapolation factor
  RampMix:=RoPEYaRNRamp(aCorrDimsV0,aCorrDimsV1,aI0)*aExtrapolationFactor;

  // Adjust theta based on the ramp mix
  Theta:=(ThetaInterpolation*(1.0-RampMix))+(aThetaExtrapolation*RampMix);

  // Get n-d magnitude scaling corrected for interpolation
  MagnitudeScale:=aMagnitudeScale*(1.0+(Ln(1.0/aFrequencyScale)*0.1)); // Adjust the magnitude scaling based on the frequency scale

 end else begin

  MagnitudeScale:=aMagnitudeScale;

 end;

 // Calculate the cosine and sine of the theta value, scaled by the magnitude scaling factor
 SinCos(Theta,aSinTheta,aCosTheta); 
 aSinTheta:=aSinTheta*MagnitudeScale;
 aCosTheta:=aCosTheta*MagnitudeScale;

end;

class procedure TPasLLMModelInferenceInstance.CachedRoPEPrepare(const aSinusCosinusVector:PPasLLMFloatArray;const aHeadDim,aPosition:TPasLLMInt32;const aTheta:TPasLLMFloat;const aRotaryDim:TPasLLMInt32);
var Index:TPasLLMInt32;
    Frequency,Value,Cosinus,Sinus:TPasLLMFloat;
begin

 // Loop through the vector in steps of 2 to apply the rotary positional encoding
 Index:=0;
 while Index<aHeadDim do begin

  // Calculate the frequency based on the head dimension and rotary dimension
  if Index>=aRotaryDim then begin
   Frequency:=0.0;
  end else begin
   Frequency:=Power(aTheta,-(Index/aRotaryDim));
  end;

  // Calculate the value based on the position and frequency
  Value:=aPosition*Frequency;

  // Calculate the sine and cosine of the value
  SinCos(Value,Sinus,Cosinus);

  // Store sinus and cosinus values
  aSinusCosinusVector^[Index]:=Sinus;
  aSinusCosinusVector^[Index+1]:=Cosinus;

  inc(Index,2);

 end;

end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64CachedRoPESingleHeadInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  test r8d, r8d
  jle @LBB0_9
  mov eax, r8d
  cmp r8d, 15
  jae @LBB0_3
  xor r8d, r8d
  jmp @LBB0_8
@LBB0_3:
  lea r8, [4*rax - 4]
  and r8, -8
  lea r9, [rcx + r8]
  add r9, 8
  add r8, rdx
  add r8, 8
  cmp rcx, r8
  setb r8b
  cmp rdx, r9
  setb r9b
  test r8b, r9b
  je @LBB0_5
  xor r8d, r8d
  jmp @LBB0_8
@LBB0_5:
  lea r9, [rax - 1]
  shr r9, 1
  inc r9
  mov r10, r9
  and r10, -8
  lea r8, [r10 + r10]
  xor r11d, r11d
@LBB0_6:
  vmovups ymm0, yword ptr [rdx + 8*r11]
  vmovups ymm1, yword ptr [rdx + 8*r11 + 32]
  vshufps ymm2, ymm0, ymm1, 136
  vpermpd ymm2, ymm2, 216
  vshufps ymm0, ymm0, ymm1, 221
  vpermpd ymm0, ymm0, 216
  vmovups ymm1, yword ptr [rcx + 8*r11]
  vmovups ymm3, yword ptr [rcx + 8*r11 + 32]
  vshufps ymm4, ymm1, ymm3, 136
  vpermpd ymm4, ymm4, 216
  vshufps ymm1, ymm1, ymm3, 221
  vpermpd ymm1, ymm1, 216
  vmulps ymm3, ymm4, ymm0
  vmulps ymm5, ymm1, ymm2
  vsubps ymm3, ymm3, ymm5
  vmulps ymm2, ymm4, ymm2
  vmulps ymm0, ymm1, ymm0
  vaddps ymm0, ymm0, ymm2
  vunpckhps ymm1, ymm3, ymm0
  vunpcklps ymm0, ymm3, ymm0
  vperm2f128 ymm2, ymm0, ymm1, 49
  vperm2f128 ymm0, ymm0, ymm1, 32
  vmovups yword ptr [rcx + 8*r11], ymm0
  vmovups yword ptr [rcx + 8*r11 + 32], ymm2
  add r11, 8
  cmp r10, r11
  jne @LBB0_6
  cmp r9, r10
  je @LBB0_9
@LBB0_8:
  vmovss xmm0, dword ptr [rdx + 4*r8]
  vmovss xmm1, dword ptr [rdx + 4*r8 + 4]
  vmovss xmm2, dword ptr [rcx + 4*r8]
  vmovss xmm3, dword ptr [rcx + 4*r8 + 4]
  vmulss xmm4, xmm2, xmm1
  vmulss xmm5, xmm3, xmm0
  vsubss xmm4, xmm4, xmm5
  vmovss dword ptr [rcx + 4*r8], xmm4
  vmulss xmm0, xmm2, xmm0
  vmulss xmm1, xmm3, xmm1
  vaddss xmm0, xmm1, xmm0
  vmovss dword ptr [rcx + 4*r8 + 4], xmm0
  add r8, 2
  cmp r8, rax
  jb @LBB0_8
@LBB0_9:
  vzeroupper
end;
{$endif}

class procedure TPasLLMModelInferenceInstance.CachedRoPESingleHeadInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32);
var Index:TPasLLMInt32;
    Cosinus,Sinus,v0,v1:TPasLLMFloat;
begin

 // Loop through the vector in steps of 2 to apply the rotary positional encoding
 Index:=0;
 while Index<aHeadDim do begin

  // Get the sine and cosine values from the RoPE cache
  Sinus:=aRoPECache^[Index];
  Cosinus:=aRoPECache^[Index+1];

  // Get the next two values from the vector
  v0:=aVector^[Index];
  v1:=aVector^[Index+1];

  // Rotate the vector using the sine and cosine values and store the results back in the vector
  aVector^[Index]:=(v0*Cosinus)-(v1*Sinus);
  aVector^[Index+1]:=(v0*Sinus)+(v1*Cosinus);

  inc(Index,2);

 end;

end;

{$ifdef cpuamd64}
// Needs AVX2
procedure AMD64CachedRoPESingleHeadNonInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  sar r8d, 1
  test r8d, r8d
  jle @LBB0_9
  mov eax, r8d
  lea r9, [rcx + 4*rax]
  cmp r8d, 8
  jae @LBB0_3
  xor r8d, r8d
@LBB0_8:
  vmovss xmm0, dword ptr [rdx + 8*r8]
  vmovss xmm1, dword ptr [rdx + 8*r8 + 4]
  vmovss xmm2, dword ptr [rcx + 4*r8]
  vmovss xmm3, dword ptr [r9 + 4*r8]
  vmulss xmm4, xmm2, xmm1
  vmulss xmm5, xmm3, xmm0
  vsubss xmm4, xmm4, xmm5
  vmovss dword ptr [rcx + 4*r8], xmm4
  vmulss xmm0, xmm2, xmm0
  vmulss xmm1, xmm3, xmm1
  vaddss xmm0, xmm1, xmm0
  vmovss dword ptr [r9 + 4*r8], xmm0
  inc r8
  cmp rax, r8
  jne @LBB0_8
@LBB0_9:
  vzeroupper
  jmp @Exit
@LBB0_3:
  push rsi
  push rbx
  lea r8, [rcx + 8*rax]
  lea r10, [rdx + 8*rax]
  cmp r9, r10
  setb bl
  cmp rdx, r8
  setb sil
  cmp rcx, r10
  setb r10b
  cmp rdx, r9
  setb r11b
  xor r8d, r8d
  test bl, sil
  pop rbx
  pop rsi
  jne @LBB0_8
  and r10b, r11b
  jne @LBB0_8
  mov r8d, eax
  and r8d, 2147483640
  lea r10d, [rax + rax]
  and r10d, -16
  xor r11d, r11d
@LBB0_6:
  vmovups ymm0, yword ptr [rdx + 4*r11]
  vmovups ymm1, yword ptr [rdx + 4*r11 + 32]
  vshufps ymm2, ymm0, ymm1, 136
  vpermpd ymm2, ymm2, 216
  vshufps ymm0, ymm0, ymm1, 221
  vpermpd ymm0, ymm0, 216
  vmovups ymm1, yword ptr [rcx + 2*r11]
  vmovups ymm3, yword ptr [r9 + 2*r11]
  vmulps ymm4, ymm1, ymm0
  vmulps ymm5, ymm3, ymm2
  vsubps ymm4, ymm4, ymm5
  vmovups yword ptr [rcx + 2*r11], ymm4
  vmulps ymm1, ymm1, ymm2
  vmulps ymm0, ymm3, ymm0
  vaddps ymm0, ymm0, ymm1
  vmovups yword ptr [r9 + 2*r11], ymm0
  add r11, 16
  cmp r10, r11
  jne @LBB0_6
  cmp r8d, eax
  jne @LBB0_8
  jmp @LBB0_9
@Exit:
end;
{$endif}

class procedure TPasLLMModelInferenceInstance.CachedRoPESingleHeadNonInterleaved(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32);
var HalfDim,Index,RotaryIndex:TPasLLMInt32;
    Cosinus,Sinus,v0,v1:TPasLLMFloat;
begin

 // Calculate the half dimension for non-interleaved RoPE
 HalfDim:=aHeadDim shr 1;

 // Loop through the vector to apply the rotary positional encoding
 for Index:=0 to HalfDim-1 do begin

  // Calculate the rotary index based on the current index
  RotaryIndex:=Index shl 1;

  // Get the sine and cosine values from the RoPE cache
  Sinus:=aRoPECache^[RotaryIndex];
  Cosinus:=aRoPECache^[RotaryIndex+1];

  // Get the next two values from the vector
  v0:=aVector^[Index];
  v1:=aVector^[Index+HalfDim];

  // Rotate the vector using the sine and cosine values and store the results back in the vector
  aVector^[Index]:=(v0*Cosinus)-(v1*Sinus);
  aVector^[Index+HalfDim]:=(v0*Sinus)+(v1*Cosinus);

 end;

end;

class procedure TPasLLMModelInferenceInstance.CachedRoPESingleHead(const aVector,aRoPECache:PPasLLMFloatArray;const aHeadDim,aRotaryDim:TPasLLMInt32;const aNonInterleaved:Boolean);
begin
 if aNonInterleaved then begin
 {$if defined(cpuamd64)}
  if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
   AMD64CachedRoPESingleHeadNonInterleaved(aVector,aRoPECache,aHeadDim,aRotaryDim);
  end else{$ifend}begin
   CachedRoPESingleHeadNonInterleaved(aVector,aRoPECache,aHeadDim,aRotaryDim);
  end; 
 end else begin
 {$if defined(cpuamd64)}
  if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
   AMD64CachedRoPESingleHeadInterleaved(aVector,aRoPECache,aHeadDim,aRotaryDim);
  end else{$ifend}begin
   CachedRoPESingleHeadInterleaved(aVector,aRoPECache,aHeadDim,aRotaryDim);
  end;
 end;
end;

// Applies Rotary Positional Encoding (RoPE) to the vector aVec based on the given parameters
// aCountHeads: Count of heads, aHeadDim: Head dimension for RoPE,
// aPosition: Position in the sequence, aTheta: Frequency scaling factor, aRotaryDim: Rotary dimension
// The function modifies the vector in place by applying the RoPE transformation
// The transformation involves calculating sine and cosine values based on the position and frequency,
// and then rotating the vector elements accordingly.
// The vector is expected to have a length that is a multiple of 2, as it processes pairs of elements at a time.

class procedure TPasLLMModelInferenceInstance.CachedRoPEMultiHeads(const aVector,aRoPECache:PPasLLMFloatArray;const aCountHeads,aHeadDim,aRotaryDim:TPasLLMInt32;const aNonInterleaved:Boolean);
var Index:TPasLLMSizeInt;
begin
 for Index:=0 to aCountHeads-1 do begin
  CachedRoPESingleHead(@aVector^[Index*aHeadDim],@aRoPECache^[0],aHeadDim,aRotaryDim,aNonInterleaved);
 end;
end;

{$ifdef cpuamd64}
procedure AMD64Attention(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI1_0:TPasLLMUInt32=TPasLLMUInt32($ff800000);
      LCPI1_1:TPasLLMUInt32=TPasLLMUInt32($c0400000); 
      LCPI1_2:TPasLLMUInt32=TPasLLMUInt32($bf000000); 
      LCPI1_3:TPasLLMUInt32=TPasLLMUInt32($3f800000); 
asm
{$ifndef fpc}
 .noframe
{$endif}
  push r15
  push r14
  push r13
  push r12
  push rsi
  push rdi
  push rbp
  push rbx
  sub rsp, 168
  vmovaps dqword ptr [rsp + 144], xmm10
  vmovaps dqword ptr [rsp + 128], xmm9
  vmovaps dqword ptr [rsp + 112], xmm8
  vmovaps dqword ptr [rsp + 96], xmm7
  vmovaps dqword ptr [rsp + 80], xmm6
  mov rdi, rdx
  mov edx, dword ptr [rsp + 296]
  mov ebp, dword ptr [rsp + 280]
  test edx, edx
  jle @LBB1_16
  mov eax, dword ptr [rsp + 288]
  mov ebx, edx
  movsxd rsi, eax
  test ebp, ebp
  mov qword ptr [rsp + 72], rcx
  mov qword ptr [rsp + 48], rsi
  jle @LBB1_19
  vcvtsi2ss xmm0, xmm5, ebp
  vrsqrtss xmm1, xmm0, xmm0
  vmulss xmm0, xmm0, xmm1
  vmulss xmm0, xmm0, xmm1
  vaddss xmm0, xmm0, dword ptr [rip + LCPI1_1]
  vmulss xmm1, xmm1, dword ptr [rip + LCPI1_2]
  vmulss xmm0, xmm1, xmm0
  mov eax, ebp
  mov ecx, eax
  and ecx, 2147483616
  mov edx, eax
  and edx, 2147483644
  mov r10d, ebp
  shr r10d, 5
  and r10d, 67108863
  shl r10, 7
  lea r11, [r9 + 96]
  lea r12, [4*rsi]
  vmovss xmm6, dword ptr [rip + LCPI1_0]
  xor r13d, r13d
  vxorps xmm1, xmm1, xmm1
  jmp @LBB1_4
@LBB1_3:
  vmulss xmm2, xmm2, xmm0
  vmovss dword ptr [rdi + 4*r13], xmm2
  vmaxss xmm6, xmm2, xmm6
  inc r13
  add r11, r12
  add r9, r12
  cmp r13, rbx
  je @LBB1_44
@LBB1_4:
  cmp ebp, 4
  jae @LBB1_6
  vxorps xmm2, xmm2, xmm2
  xor esi, esi
  jmp @LBB1_15
@LBB1_6:
  cmp ebp, 32
  jae @LBB1_8
  vxorps xmm2, xmm2, xmm2
  xor r14d, r14d
  jmp @LBB1_12
@LBB1_8:
  vxorps xmm2, xmm2, xmm2
  xor esi, esi
  vxorps xmm3, xmm3, xmm3
  vxorps xmm4, xmm4, xmm4
  vxorps xmm5, xmm5, xmm5
@LBB1_9:
  vmovups ymm7, yword ptr [r11 + rsi - 96]
  vmovups ymm8, yword ptr [r11 + rsi - 64]
  vmovups ymm9, yword ptr [r11 + rsi - 32]
  vmovups ymm10, yword ptr [r11 + rsi]
  vmulps ymm7, ymm7, yword ptr [r8 + rsi]
  vaddps ymm2, ymm7, ymm2
  vmulps ymm7, ymm8, yword ptr [r8 + rsi + 32]
  vaddps ymm3, ymm7, ymm3
  vmulps ymm7, ymm9, yword ptr [r8 + rsi + 64]
  vmulps ymm8, ymm10, yword ptr [r8 + rsi + 96]
  vaddps ymm4, ymm7, ymm4
  vaddps ymm5, ymm8, ymm5
  sub rsi, -128
  cmp r10, rsi
  jne @LBB1_9
  vaddps ymm2, ymm3, ymm2
  vaddps ymm2, ymm4, ymm2
  vaddps ymm2, ymm5, ymm2
  vextractf128 xmm3, ymm2, 1
  vaddps xmm2, xmm2, xmm3
  vshufpd xmm3, xmm2, xmm2, 1
  vaddps xmm2, xmm2, xmm3
  vmovshdup xmm3, xmm2
  vaddss xmm2, xmm2, xmm3
  cmp ecx, eax
  je @LBB1_3
  mov r14, rcx
  mov rsi, rcx
  test al, 28
  je @LBB1_15
@LBB1_12:
  vblendps xmm2, xmm1, xmm2, 1
@LBB1_13:
  vmovups xmm3, dqword ptr [r9 + 4*r14]
  vmulps xmm3, xmm3, dqword ptr [r8 + 4*r14]
  vaddps xmm2, xmm3, xmm2
  add r14, 4
  cmp rdx, r14
  jne @LBB1_13
  vshufpd xmm3, xmm2, xmm2, 1
  vaddps xmm2, xmm2, xmm3
  vmovshdup xmm3, xmm2
  vaddss xmm2, xmm2, xmm3
  mov rsi, rdx
  cmp edx, eax
  je @LBB1_3
@LBB1_15:
  vmovss xmm3, dword ptr [r9 + 4*rsi]
  vmulss xmm3, xmm3, dword ptr [r8 + 4*rsi]
  vaddss xmm2, xmm3, xmm2
  inc rsi
  cmp rax, rsi
  jne @LBB1_15
  jmp @LBB1_3
@LBB1_16:
  test ebp, ebp
  jle @LBB1_80
  mov eax, ebp
  cmp ebp, 3
  ja @LBB1_21
  xor r9d, r9d
  jmp @LBB1_32
@LBB1_19:
  cmp edx, 3
  ja @LBB1_23
  xor eax, eax
  jmp @LBB1_42
@LBB1_21:
  cmp ebp, 32
  jae @LBB1_25
  xor r9d, r9d
  jmp @LBB1_29
@LBB1_23:
  cmp edx, 32
  jae @LBB1_33
  xor eax, eax
  jmp @LBB1_38
@LBB1_25:
  mov r9d, eax
  and r9d, 2147483616
  mov edx, eax
  shr edx, 5
  and edx, 67108863
  shl rdx, 7
  xor r8d, r8d
  vxorps xmm0, xmm0, xmm0
@LBB1_26:
  vmovups yword ptr [rcx + r8], ymm0
  vmovups yword ptr [rcx + r8 + 32], ymm0
  vmovups yword ptr [rcx + r8 + 64], ymm0
  vmovups yword ptr [rcx + r8 + 96], ymm0
  sub r8, -128
  cmp rdx, r8
  jne @LBB1_26
  cmp r9d, eax
  je @LBB1_80
  test al, 28
  je @LBB1_32
@LBB1_29:
  mov rdx, r9
  mov r9d, eax
  and r9d, 2147483644
  vxorps xmm0, xmm0, xmm0
@LBB1_30:
  vmovups dqword ptr [rcx + 4*rdx], xmm0
  add rdx, 4
  cmp r9, rdx
  jne @LBB1_30
  cmp r9d, eax
  je @LBB1_80
@LBB1_32:
  mov dword ptr [rcx + 4*r9], 0
  inc r9
  cmp rax, r9
  jne @LBB1_32
  jmp @LBB1_80
@LBB1_33:
  mov eax, ebx
  and eax, 2147483616
  mov ecx, ebx
  shr ecx, 5
  and ecx, 67108863
  shl rcx, 7
  xor edx, edx
  vxorps xmm0, xmm0, xmm0
@LBB1_34:
  vmovups yword ptr [rdi + rdx], ymm0
  vmovups yword ptr [rdi + rdx + 32], ymm0
  vmovups yword ptr [rdi + rdx + 64], ymm0
  vmovups yword ptr [rdi + rdx + 96], ymm0
  sub rdx, -128
  cmp rcx, rdx
  jne @LBB1_34
  cmp eax, ebx
  je @LBB1_36
  test bl, 28
  je @LBB1_42
@LBB1_38:
  mov rcx, rax
  mov eax, ebx
  and eax, 2147483644
  vxorps xmm0, xmm0, xmm0
@LBB1_39:
  vmovups dqword ptr [rdi + 4*rcx], xmm0
  add rcx, 4
  cmp rax, rcx
  jne @LBB1_39
  cmp eax, ebx
  jne @LBB1_42
@LBB1_36:
  vmovss xmm6, dword ptr [rip + LCPI1_0]
  jmp @LBB1_44
@LBB1_42:
  vmovss xmm6, dword ptr [rip + LCPI1_0]
@LBB1_43:
  mov dword ptr [rdi + 4*rax], 0
  inc rax
  cmp rbx, rax
  jne @LBB1_43
@LBB1_44:
  mov r15, qword ptr [rsp + 272]
  vxorps xmm7, xmm7, xmm7
  xor esi, esi
@LBB1_45:
  vmovss xmm0, dword ptr [rdi + 4*rsi]
  vsubss xmm0, xmm0, xmm6
  vzeroupper
  call AMD64Exp
  vmovss dword ptr [rdi + 4*rsi], xmm0
  vaddss xmm7, xmm0, xmm7
  inc rsi
  cmp rbx, rsi
  jne @LBB1_45
  mov eax, dword ptr [rsp + 296]
  cmp eax, 3
  ja @LBB1_48
  xor eax, eax
  jmp @LBB1_57
@LBB1_48:
  cmp eax, 32
  jae @LBB1_50
  xor eax, eax
  jmp @LBB1_54
@LBB1_50:
  mov eax, ebx
  and eax, 2147483616
  vmovss xmm0, dword ptr [rip + LCPI1_3]
  vdivss xmm0, xmm0, xmm7
  vbroadcastss ymm0, xmm0
  xor ecx, ecx
@LBB1_51:
  vmulps ymm1, ymm0, yword ptr [rdi + 4*rcx]
  vmulps ymm2, ymm0, yword ptr [rdi + 4*rcx + 32]
  vmulps ymm3, ymm0, yword ptr [rdi + 4*rcx + 64]
  vmulps ymm4, ymm0, yword ptr [rdi + 4*rcx + 96]
  vmovups yword ptr [rdi + 4*rcx], ymm1
  vmovups yword ptr [rdi + 4*rcx + 32], ymm2
  vmovups yword ptr [rdi + 4*rcx + 64], ymm3
  vmovups yword ptr [rdi + 4*rcx + 96], ymm4
  add rcx, 32
  cmp rax, rcx
  jne @LBB1_51
  cmp eax, ebx
  je @LBB1_59
  test bl, 28
  je @LBB1_57
@LBB1_54:
  mov rcx, rax
  mov eax, ebx
  and eax, 2147483644
  vmovss xmm0, dword ptr [rip + LCPI1_3]
  vdivss xmm0, xmm0, xmm7
  vbroadcastss xmm0, xmm0
@LBB1_55:
  vmulps xmm1, xmm0, dqword ptr [rdi + 4*rcx]
  vmovups dqword ptr [rdi + 4*rcx], xmm1
  add rcx, 4
  cmp rax, rcx
  jne @LBB1_55
  cmp eax, ebx
  je @LBB1_59
@LBB1_57:
  vmovss xmm0, dword ptr [rip + LCPI1_3]
  vdivss xmm0, xmm0, xmm7
@LBB1_58:
  vmulss xmm1, xmm0, dword ptr [rdi + 4*rax]
  vmovss dword ptr [rdi + 4*rax], xmm1
  inc rax
  cmp rbx, rax
  jne @LBB1_58
@LBB1_59:
  test ebp, ebp
  jle @LBB1_80
  mov eax, ebp
  mov qword ptr [rsp + 64], rax
  cmp dword ptr [rsp + 296], 4
  setae al
  mov rcx, qword ptr [rsp + 48]
  cmp ecx, 1
  sete dl
  and dl, al
  mov byte ptr [rsp + 47], dl
  mov edx, ebx
  and edx, 2147483616
  mov r14d, ebx
  and r14d, 2147483644
  mov eax, ebx
  and eax, 3
  mov qword ptr [rsp + 56], rax
  lea r10, [r15 + 96]
  lea rax, [4*rcx]
  shl rcx, 4
  mov qword ptr [rsp + 48], rcx
  xor r13d, r13d
  vxorps xmm0, xmm0, xmm0
  mov r9, qword ptr [rsp + 48]
  jmp @LBB1_62
@LBB1_61:
  mov rcx, qword ptr [rsp + 72]
  vmovss dword ptr [rcx + 4*r13], xmm1
  inc r13
  add r10, 4
  add r15, 4
  cmp r13, qword ptr [rsp + 64]
  je @LBB1_80
@LBB1_62:
  cmp byte ptr [rsp + 47], 0
  je @LBB1_65
  cmp dword ptr [rsp + 296], 32
  jae @LBB1_66
  vxorps xmm1, xmm1, xmm1
  xor ecx, ecx
  jmp @LBB1_70
@LBB1_65:
  vxorps xmm1, xmm1, xmm1
  xor r8d, r8d
  jmp @LBB1_73
@LBB1_66:
  vxorps xmm1, xmm1, xmm1
  xor r8d, r8d
  vxorps xmm2, xmm2, xmm2
  vxorps xmm3, xmm3, xmm3
  vxorps xmm4, xmm4, xmm4
@LBB1_67:
  vmovups ymm5, yword ptr [r10 + 4*r8 - 96]
  vmovups ymm6, yword ptr [r10 + 4*r8 - 64]
  vmovups ymm7, yword ptr [r10 + 4*r8 - 32]
  vmovups ymm8, yword ptr [r10 + 4*r8]
  vmulps ymm5, ymm5, yword ptr [rdi + 4*r8]
  vaddps ymm1, ymm5, ymm1
  vmulps ymm5, ymm6, yword ptr [rdi + 4*r8 + 32]
  vaddps ymm2, ymm5, ymm2
  vmulps ymm5, ymm7, yword ptr [rdi + 4*r8 + 64]
  vmulps ymm6, ymm8, yword ptr [rdi + 4*r8 + 96]
  vaddps ymm3, ymm5, ymm3
  vaddps ymm4, ymm6, ymm4
  add r8, 32
  cmp rdx, r8
  jne @LBB1_67
  vaddps ymm1, ymm2, ymm1
  vaddps ymm1, ymm3, ymm1
  vaddps ymm1, ymm4, ymm1
  vextractf128 xmm2, ymm1, 1
  vaddps xmm1, xmm1, xmm2
  vshufpd xmm2, xmm1, xmm1, 1
  vaddps xmm1, xmm1, xmm2
  vmovshdup xmm2, xmm1
  vaddss xmm1, xmm1, xmm2
  cmp edx, ebx
  je @LBB1_61
  mov rcx, rdx
  mov r8, rdx
  test bl, 28
  je @LBB1_73
@LBB1_70:
  vblendps xmm1, xmm0, xmm1, 1
@LBB1_71:
  vmovups xmm2, dqword ptr [r15 + 4*rcx]
  vmulps xmm2, xmm2, dqword ptr [rdi + 4*rcx]
  vaddps xmm1, xmm2, xmm1
  add rcx, 4
  cmp r14, rcx
  jne @LBB1_71
  vshufpd xmm2, xmm1, xmm1, 1
  vaddps xmm1, xmm1, xmm2
  vmovshdup xmm2, xmm1
  vaddss xmm1, xmm1, xmm2
  mov r8, r14
  cmp r14d, ebx
  je @LBB1_61
@LBB1_73:
  mov r11, qword ptr [rsp + 56]
  test r11, r11
  je @LBB1_77
  mov rcx, rax
  imul rcx, r8
  add rcx, r15
  mov rbp, r8
@LBB1_75:
  vmovss xmm2, dword ptr [rcx]
  vmulss xmm2, xmm2, dword ptr [rdi + 4*rbp]
  vaddss xmm1, xmm2, xmm1
  inc rbp
  add rcx, rax
  dec r11
  jne @LBB1_75
  sub r8, rbx
  cmp r8, -4
  ja @LBB1_61
  jmp @LBB1_78
@LBB1_77:
  mov rbp, r8
  sub r8, rbx
  cmp r8, -4
  ja @LBB1_61
@LBB1_78:
  lea r8, [rbp + 3]
  imul r8, rax
  lea rsi, [rbp + 2]
  imul rsi, rax
  mov r11, rax
  imul r11, rbp
  lea rcx, [rbp + 1]
  imul rcx, rax
  mov r12, r15
@LBB1_79:
  vmovss xmm2, dword ptr [r12 + r11]
  vmulss xmm2, xmm2, dword ptr [rdi + 4*rbp]
  vaddss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [r12 + rcx]
  vmulss xmm2, xmm2, dword ptr [rdi + 4*rbp + 4]
  vmovss xmm3, dword ptr [r12 + rsi]
  vmulss xmm3, xmm3, dword ptr [rdi + 4*rbp + 8]
  vaddss xmm2, xmm3, xmm2
  vaddss xmm1, xmm2, xmm1
  vmovss xmm2, dword ptr [r12 + r8]
  vmulss xmm2, xmm2, dword ptr [rdi + 4*rbp + 12]
  vaddss xmm1, xmm2, xmm1
  add rbp, 4
  add r12, r9
  cmp rbx, rbp
  jne @LBB1_79
  jmp @LBB1_61
@LBB1_80:
  vmovaps xmm6, dqword ptr [rsp + 80]
  vmovaps xmm7, dqword ptr [rsp + 96]
  vmovaps xmm8, dqword ptr [rsp + 112]
  vmovaps xmm9, dqword ptr [rsp + 128]
  vmovaps xmm10, dqword ptr [rsp + 144]
  add rsp, 168
  pop rbx
  pop rbp
  pop rdi
  pop rsi
  pop r12
  pop r13
  pop r14
  pop r15
  vzeroupper
end;//*)
{$endif}
  
// Applies attention mechanism to the output vector aXOut using the query, key, and value heads
// aAttH: Attention scores, aQH: Query head, aKH: Key head, aVH: Value head
// aHeadDim: Dimension of the attention head, aKVDim: Dimension of key/value, aKVLen: Length of key/value
// The function computes the attention scores by calculating the dot product of the query and key heads,
// applies softmax to the scores for numerical stability, and then mixes the values with the attention weights.
// The result is stored in the output vector aXOut.
// The attention mechanism is crucial for focusing on relevant parts of the input sequence,
// allowing the model to weigh different parts of the input differently based on their relevance to the current context.
// The function uses a scaling factor (sqrt(aHeadDim)) to stabilize the gradients
// and prevent the scores from becoming too large, which can lead to numerical instability during training.
class procedure TPasLLMModelInferenceInstance.Attention(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat);
{$define AttentionInlinedSoftMax}
var TimeIndex,HeadIndex:TPasLLMInt32;
    Score,{$ifdef AttentionInlinedSoftMax}ScoreMax,ScoreSum,{$endif}Res:TPasLLMFloat;
begin

 if aAttnLogitSoftcapping>0.0 then begin

  for TimeIndex:=0 to aKVLen-1 do begin // Loop through the key/value length   
   Score:=0.0; // Initialize the score for this time step
   for HeadIndex:=0 to aHeadDim-1 do begin // Loop through the head dimension
    Score:=Score+(aQH^[HeadIndex]*aKH^[(TimeIndex*aKVDim)+HeadIndex]); // Calculate the dot product of query and key
   end;
   Score:=Score/sqrt(aHeadDim); // Scale the score by the square root of the head dimension
   Score:=Tanh(Score/aAttnLogitSoftcapping)*aAttnLogitSoftcapping; // Apply softcapping using tanh
   aAttH^[TimeIndex]:=Score;
  end;
   
  SoftMax(@aAttH^[0],aKVLen);

  // Mix values with attention weights
  for HeadIndex:=0 to aHeadDim-1 do begin // Loop through the head dimension
   Res:=0.0; // Initialize the result for this head
   for TimeIndex:=0 to aKVLen-1 do begin // Loop through the key/value length
    Res:=Res+(aAttH^[TimeIndex]*aVH^[(TimeIndex*aKVDim)+HeadIndex]); // Mix the value with the attention weight
   end;
   aXOut^[HeadIndex]:=Res; // Store the result in the output array
  end;

 end else begin

 {$if defined(cpuamd64)}
  if (PasLLMCPUFeatures and PasLLMCPUFeatures_X86_AVX2_Mask)<>0 then begin
   AMD64Attention(aXOut,aAttH,aQH,aKH,aVH,aHeadDim,aKVDim,aKVLen);
  end else{$ifend}begin

  {$ifdef AttentionInlinedSoftMax}
   ScoreMax:=-Infinity; // Initialize the maximum score to negative infinity
  {$endif}

   for TimeIndex:=0 to aKVLen-1 do begin // Loop through the key/value length
   
    Score:=0.0; // Initialize the score for this time step

    for HeadIndex:=0 to aHeadDim-1 do begin // Loop through the head dimension
     Score:=Score+(aQH^[HeadIndex]*aKH^[(TimeIndex*aKVDim)+HeadIndex]); // Calculate the dot product of query and key
    end;
    Score:=Score/sqrt(aHeadDim); // Scale the score by the square root of the head dimension
  {$ifdef AttentionInlinedSoftMax}
    if (TimeIndex=0) or (ScoreMax<Score) then begin
     ScoreMax:=Score; // Update the maximum score if the current score is greater
    end;
  {$endif}
    aAttH^[TimeIndex]:=Score; // Store the score in the attention array
   end;

   // Softmax the scores to get attention weights
  {$ifdef AttentionInlinedSoftMax}
   ScoreSum:=0.0; // Initialize the sum of scores to zero
   for TimeIndex:=0 to aKVLen-1 do begin // Loop through the key/value length
    aAttH^[TimeIndex]:=exp(aAttH^[TimeIndex]-ScoreMax); // Exponentiate the score minus the maximum score for numerical stability
    ScoreSum:=ScoreSum+aAttH^[TimeIndex]; // Add the exponentiated score to the sum
   end;
  {$else}
   SoftMax(@aAttH^[0],aKVLen);
  {$endif}

   // Mix values with attention weights
   for HeadIndex:=0 to aHeadDim-1 do begin // Loop through the head dimension
    Res:=0.0; // Initialize the result for this head
    for TimeIndex:=0 to aKVLen-1 do begin // Loop through the key/value length
     Res:=Res+({$ifdef AttentionInlinedSoftMax}(aAttH^[TimeIndex]/ScoreSum){$else}aAttH^[TimeIndex]{$endif}*aVH^[(TimeIndex*aKVDim)+HeadIndex]); // Mix the value with the attention weight
    end;
    aXOut^[HeadIndex]:=Res; // Store the result in the output array
   end;

  end;

 end;

end;

class procedure TPasLLMModelInferenceInstance.AttentionChunked(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen,aChunkLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat);
var ChunkStart,LocalLen,TimeIndex,HeadIndex:TPasLLMInt32;
    Score,ScoreMax,ScoreSum,Res:TPasLLMFloat;
begin

 if aAttnLogitSoftcapping>0.0 then begin

  ChunkStart:=0;
  while ChunkStart<aKVLen do begin
   LocalLen:=Min(aChunkLen,aKVLen-ChunkStart);
   for TimeIndex:=0 to LocalLen-1 do begin
    Score:=0.0;
    for HeadIndex:=0 to aHeadDim-1 do begin
     Score:=Score+(aQH^[HeadIndex]*aKH^[((ChunkStart+TimeIndex)*aKVDim)+HeadIndex]);
    end;
    Score:=Score/sqrt(aHeadDim);
    Score:=Tanh(Score/aAttnLogitSoftcapping)*aAttnLogitSoftcapping;
    aAttH^[ChunkStart+TimeIndex]:=Score;
   end;
   inc(ChunkStart,LocalLen);
  end;

  SoftMax(@aAttH^[0],aKVLen);

  for HeadIndex:=0 to aHeadDim-1 do begin
   Res:=0.0;
   ChunkStart:=0;
   while ChunkStart<aKVLen do begin
    LocalLen:=Min(aChunkLen,aKVLen-ChunkStart);
    for TimeIndex:=0 to LocalLen-1 do begin
     Res:=Res+(aAttH^[ChunkStart+TimeIndex]*aVH^[((ChunkStart+TimeIndex)*aKVDim)+HeadIndex]);
    end;
    inc(ChunkStart,LocalLen);
   end;
   aXOut^[HeadIndex]:=Res;
  end;

 end else begin

  // 1) Scores in tiles, track global max
  ScoreMax:=-Infinity;

  ChunkStart:=0;
  while ChunkStart<aKVLen do begin
   LocalLen:=Min(aChunkLen,aKVLen-ChunkStart);
   for TimeIndex:=0 to LocalLen-1 do begin
    Score:=0.0;
    for HeadIndex:=0 to aHeadDim-1 do begin
     Score:=Score+(aQH^[HeadIndex]*aKH^[((ChunkStart+TimeIndex)*aKVDim)+HeadIndex]);
    end;
    aAttH^[ChunkStart+TimeIndex]:=Score;
    if Score>ScoreMax then begin
     ScoreMax:=Score;
    end;
   end;
   inc(ChunkStart,LocalLen);
  end;

  // 2) Softmax
  ScoreSum:=0.0;
  for TimeIndex:=0 to aKVLen-1 do begin
   aAttH^[TimeIndex]:=exp(aAttH^[TimeIndex]-ScoreMax);
   ScoreSum:=ScoreSum+aAttH^[TimeIndex];
  end;
  if ScoreSum<>0.0 then begin
   for TimeIndex:=0 to aKVLen-1 do begin
    aAttH^[TimeIndex]:=aAttH^[TimeIndex]/ScoreSum;
   end;
  end;

  // 3) Mix values in tiles
  for HeadIndex:=0 to aHeadDim-1 do begin
   Res:=0.0;
   ChunkStart:=0;
   while ChunkStart<aKVLen do begin
    LocalLen:=Min(aChunkLen,aKVLen-ChunkStart);
    for TimeIndex:=0 to LocalLen-1 do begin
     Res:=Res+(aAttH^[ChunkStart+TimeIndex]*aVH^[((ChunkStart+TimeIndex)*aKVDim)+HeadIndex]);
    end;
    inc(ChunkStart,LocalLen);
   end;
   aXOut^[HeadIndex]:=Res;
  end;

 end;

end;

class procedure TPasLLMModelInferenceInstance.AttentionDispatch(const aXOut,aAttH,aQH,aKH,aVH:PPasLLMFloatArray;const aHeadDim,aKVDim,aKVLen:TPasLLMInt32;const aSWAType:TPasLLMSWAType;const aIsSliding:Boolean;const aChunkLen:TPasLLMInt32;const aAttnLogitSoftcapping:TPasLLMFloat);
begin
 if aIsSliding and (aSWAType=TPasLLMSWAType.Chunked) then begin
  AttentionChunked(aXOut,aAttH,aQH,aKH,aVH,aHeadDim,aKVDim,aKVLen,Max(1,aChunkLen),aAttnLogitSoftcapping);
end else begin
  Attention(aXOut,aAttH,aQH,aKH,aVH,aHeadDim,aKVDim,aKVLen,aAttnLogitSoftcapping);
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DoGEGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($3d372713);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($3f800000);
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3f4c422a);
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32($41102cb3);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($40000000);
      LCPI0_6:TPasLLMUInt32=TPasLLMUInt32($4038aa3b);
      LCPI0_7:TPasLLMUInt32=TPasLLMUInt32($cb400000);
      LCPI0_8:TPasLLMUInt32=TPasLLMUInt32($bf317200);
      LCPI0_9:TPasLLMUInt32=TPasLLMUInt32($b5bfbe8e);
      LCPI0_10:TPasLLMUInt32=TPasLLMUInt32($3effffff);
      LCPI0_11:TPasLLMUInt32=TPasLLMUInt32($3e2aaa57);
      LCPI0_12:TPasLLMUInt32=TPasLLMUInt32($3d2aab9b);
      LCPI0_13:TPasLLMUInt32=TPasLLMUInt32($3c09143e);
      LCPI0_14:TPasLLMUInt32=TPasLLMUInt32($3ab5aad1);
      LCPI0_15:TPasLLMUInt32=TPasLLMUInt32($bf800000);
      LCPI0_16:TPasLLMUInt32=TPasLLMUInt32($80000000);
      LCPI0_17:TPasLLMUInt32=TPasLLMUInt32($3f000000);
      LCPI0_18:array[0..3] of TPasLLMUInt32=(1,2,3,4);
asm
{$ifndef fpc}
 .noframe
{$endif}
  push rsi
  sub rsp, 160
  vmovaps dqword ptr [rsp + 144], xmm15
  vmovaps dqword ptr [rsp + 128], xmm14
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  xor r10d, r10d
  cmp r9d, 8
  jl @LBB0_3
  mov eax, r9d
  xor r10d, r10d
  vpbroadcastd ymm1, dword ptr [rip + LCPI0_1]
  vbroadcastss ymm3, dword ptr [rip + LCPI0_3]
  vbroadcastss ymm7, dword ptr [rip + LCPI0_7]
  vbroadcastss ymm12, dword ptr [rip + LCPI0_12]
  vbroadcastss ymm10, dword ptr [rip + LCPI0_13]
  vbroadcastss ymm14, dword ptr [rip + LCPI0_14]
  vbroadcastss ymm15, dword ptr [rip + LCPI0_15]
  vbroadcastss ymm0, dword ptr [rip + LCPI0_16]
  vbroadcastss ymm2, dword ptr [rip + LCPI0_17]
@LBB0_2:
  mov r11, r10
  vmovups ymm4, yword ptr [rdx + 4*r10]
  vmulps ymm5, ymm4, ymm4
  vbroadcastss ymm6, dword ptr [rip + LCPI0_0]
  vmulps ymm6, ymm5, ymm6
  vbroadcastss ymm5, dword ptr [rip + LCPI0_2]
  vmulps ymm5, ymm4, ymm5
  vfmadd213ps ymm5, ymm6, ymm5
  vaddps ymm6, ymm5, ymm5
  vbroadcastss ymm8, dword ptr [rip + LCPI0_6]
  vfmsub213ps ymm8, ymm5, ymm7
  vaddps ymm8, ymm8, ymm7
  vbroadcastss ymm9, dword ptr [rip + LCPI0_8]
  vfmadd231ps ymm6, ymm8, ymm9
  vbroadcastss ymm9, dword ptr [rip + LCPI0_9]
  vfmadd231ps ymm6, ymm9, ymm8
  vmulps ymm9, ymm6, ymm6
  vbroadcastss ymm11, dword ptr [rip + LCPI0_11]
  vbroadcastss ymm13, dword ptr [rip + LCPI0_10]
  vfmadd213ps ymm11, ymm6, ymm13
  vmovaps ymm13, ymm10
  vfmadd213ps ymm13, ymm6, ymm12
  vfmadd213ps ymm13, ymm9, ymm11
  vmulps ymm11, ymm9, ymm9
  vfmadd231ps ymm13, ymm14, ymm11
  vcvttps2dq ymm8, ymm8
  vpslld ymm8, ymm8, 23
  vfmadd213ps ymm13, ymm9, ymm6
  vpaddd ymm6, ymm8, ymm1
  vaddps ymm8, ymm15, ymm6
  vfmadd231ps ymm8, ymm6, ymm13
  vbroadcastss ymm6, dword ptr [rip + LCPI0_5]
  vaddps ymm6, ymm8, ymm6
  vrcpps ymm9, ymm6
  vmulps ymm11, ymm8, ymm9
  vfmsub231ps ymm8, ymm11, ymm6
  vfnmadd213ps ymm8, ymm9, ymm11
  vandps ymm6, ymm5, ymm3
  vbroadcastss ymm9, dword ptr [rip + LCPI0_4]
  vcmpleps ymm6, ymm6, ymm9
  vandps ymm5, ymm5, ymm0
  vorps ymm5, ymm5, ymm1
  vblendvps ymm5, ymm5, ymm8, ymm6
  vmulps ymm4, ymm4, ymm2
  vmulps ymm4, ymm4, yword ptr [r8 + 4*r10]
  vfmadd213ps ymm4, ymm5, ymm4
  vmovups yword ptr [rcx + 4*r10], ymm4
  add r10, 8
  add r11, 15
  cmp r11, rax
  jb @LBB0_2
@LBB0_3:
  cmp r10d, r9d
  jge @LBB0_5
  vmovd xmm0, r10d
  vpbroadcastd xmm0, xmm0
  vpor xmm0, xmm0, dqword ptr [rip + LCPI0_18]
  vmovd xmm1, r9d
  mov eax, r10d
  or eax, 5
  xor r11d, r11d
  cmp eax, r9d
  mov eax, 0
  sbb eax, eax
  mov esi, r10d
  or esi, 6
  cmp esi, r9d
  sbb r11d, r11d
  vpbroadcastd xmm1, xmm1
  vpmaxud xmm1, xmm0, xmm1
  vpcmpeqd xmm0, xmm0, xmm1
  vpcmpeqd xmm1, xmm1, xmm1
  vpshufd xmm0, xmm0, 147
  vpxor xmm0, xmm0, xmm1
  vpermq ymm0, ymm0, 196
  mov r9d, -1
  vmovd xmm1, r9d
  vpblendd ymm0, ymm0, ymm1, 129
  vmovd xmm1, eax
  vpbroadcastd ymm1, xmm1
  vpblendd ymm0, ymm0, ymm1, 32
  vmovd xmm1, r11d
  vpbroadcastd ymm1, xmm1
  vpblendd ymm0, ymm0, ymm1, 64
  mov eax, r10d
  vmaskmovps ymm1, ymm0, yword ptr [rdx + 4*rax]
  vbroadcastss ymm2, dword ptr [rip + LCPI0_0]
  vmulps ymm3, ymm1, ymm1
  vmulps ymm4, ymm3, ymm2
  vpbroadcastd ymm2, dword ptr [rip + LCPI0_1]
  vbroadcastss ymm3, dword ptr [rip + LCPI0_2]
  vmulps ymm3, ymm1, ymm3
  vfmadd213ps ymm3, ymm4, ymm3
  vbroadcastss ymm5, dword ptr [rip + LCPI0_3]
  vbroadcastss ymm4, dword ptr [rip + LCPI0_4]
  vandps ymm5, ymm3, ymm5
  vaddps ymm7, ymm3, ymm3
  vbroadcastss ymm6, dword ptr [rip + LCPI0_5]
  vbroadcastss ymm8, dword ptr [rip + LCPI0_6]
  vbroadcastss ymm9, dword ptr [rip + LCPI0_7]
  vfmsub213ps ymm8, ymm3, ymm9
  vaddps ymm8, ymm8, ymm9
  vbroadcastss ymm9, dword ptr [rip + LCPI0_8]
  vcvttps2dq ymm10, ymm8
  vfmadd213ps ymm9, ymm8, ymm7
  vbroadcastss ymm7, dword ptr [rip + LCPI0_9]
  vfmadd213ps ymm7, ymm8, ymm9
  vmulps ymm8, ymm7, ymm7
  vbroadcastss ymm9, dword ptr [rip + LCPI0_10]
  vbroadcastss ymm11, dword ptr [rip + LCPI0_11]
  vbroadcastss ymm12, dword ptr [rip + LCPI0_12]
  vfmadd213ps ymm11, ymm7, ymm9
  vbroadcastss ymm9, dword ptr [rip + LCPI0_13]
  vfmadd213ps ymm9, ymm7, ymm12
  vmulps ymm12, ymm8, ymm8
  vfmadd213ps ymm9, ymm8, ymm11
  vbroadcastss ymm11, dword ptr [rip + LCPI0_14]
  vfmadd213ps ymm11, ymm12, ymm9
  vfmadd213ps ymm11, ymm8, ymm7
  vpslld ymm7, ymm10, 23
  vpaddd ymm7, ymm7, ymm2
  vbroadcastss ymm8, dword ptr [rip + LCPI0_15]
  vaddps ymm8, ymm8, ymm7
  vfmadd231ps ymm8, ymm7, ymm11
  vaddps ymm6, ymm8, ymm6
  vrcpps ymm7, ymm6
  vcmpleps ymm4, ymm5, ymm4
  vmulps ymm5, ymm8, ymm7
  vfmsub231ps ymm8, ymm5, ymm6
  vfnmadd213ps ymm8, ymm7, ymm5
  vbroadcastss ymm5, dword ptr [rip + LCPI0_16]
  vandps ymm3, ymm3, ymm5
  vorps ymm2, ymm3, ymm2
  vblendvps ymm2, ymm2, ymm8, ymm4
  vbroadcastss ymm3, dword ptr [rip + LCPI0_17]
  vmaskmovps ymm4, ymm0, yword ptr [r8 + 4*rax]
  vmulps ymm1, ymm1, ymm3
  vmulps ymm1, ymm1, ymm4
  vfmadd213ps ymm1, ymm2, ymm1
  vmaskmovps yword ptr [rcx + 4*rax], ymm0, ymm1
@LBB0_5:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  vmovaps xmm14, dqword ptr [rsp + 128]
  vmovaps xmm15, dqword ptr [rsp + 144]
  add rsp, 160
  pop rsi
  vzeroupper
end;
{$endif}

procedure PascalDoaGEGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);
var Index:TPasLLMInt32;
    Value:TPasLLMFloat;
begin
 for Index:=0 to aSize-1 do begin
  Value:=aA^[Index];
  aOut^[Index]:=(0.5*Value*(1.0+(TanH(0.797885*(Value+(0.044715*Value*Value*Value))))))*aB^[Index];
 end;
end;

class procedure TPasLLMModelInferenceInstance.DoaGEGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask) then begin
  AMD64DoGEGLU(aOut,aA,aB,aSize);
 end else{$ifend}begin
  PascalDoaGEGLU(aOut,aA,aB,aSize);
 end;
end;

{$ifdef cpuamd64}
procedure AMD64DoSwiGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const LCPI0_0:TPasLLMUInt32=TPasLLMUInt32($bfb8aa3b);
      LCPI0_1:TPasLLMUInt32=TPasLLMUInt32($cb400000);
      LCPI0_2:TPasLLMUInt32=TPasLLMUInt32($3f317200);
      LCPI0_3:TPasLLMUInt32=TPasLLMUInt32($b5bfbe8e);
      LCPI0_4:TPasLLMUInt32=TPasLLMUInt32(1065353216);
      LCPI0_5:TPasLLMUInt32=TPasLLMUInt32($7fffffff);
      LCPI0_6:TPasLLMUInt32=TPasLLMUInt32($42fc0000);
      LCPI0_7:TPasLLMUInt32=TPasLLMUInt32($3d2b9f17);
      LCPI0_8:TPasLLMUInt32=TPasLLMUInt32($3c072010);
      LCPI0_9:TPasLLMUInt32=TPasLLMUInt32($3efffedb);
      LCPI0_10:TPasLLMUInt32=TPasLLMUInt32($3e2aaf33);
      LCPI0_11:TPasLLMUInt32=TPasLLMUInt32($3f7ffff6);
      LCPI0_12:TPasLLMUInt32=TPasLLMUInt32(2181038080);
      LCPI0_13:TPasLLMUInt32=TPasLLMUInt32(2130706432);
      LCPI0_14:TPasLLMUInt32=TPasLLMUInt32($43400000);
      LCPI0_15:array[0..3] of TPasLLMUInt32=(5,6,0,0);
      LCPI0_16:array[0..3] of TPasLLMUInt32=(4,1,2,3);
asm
{$ifndef fpc}
 .noframe
{$endif}
  sub rsp, 168
  vmovaps dqword ptr [rsp + 144], xmm15
  vmovdqa dqword ptr [rsp + 128], xmm14
  vmovaps dqword ptr [rsp + 112], xmm13
  vmovaps dqword ptr [rsp + 96], xmm12
  vmovaps dqword ptr [rsp + 80], xmm11
  vmovaps dqword ptr [rsp + 64], xmm10
  vmovaps dqword ptr [rsp + 48], xmm9
  vmovaps dqword ptr [rsp + 32], xmm8
  vmovaps dqword ptr [rsp + 16], xmm7
  vmovaps dqword ptr [rsp], xmm6
  xor r11d, r11d
  cmp r9d, 8
  jl @LBB0_6
  mov eax, r9d
  vbroadcastss ymm1, dword ptr [rip + LCPI0_1]
  vpbroadcastd ymm4, dword ptr [rip + LCPI0_4]
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
  vbroadcastss ymm8, dword ptr [rip + LCPI0_8]
  vbroadcastss ymm7, dword ptr [rip + LCPI0_10]
  vbroadcastss ymm11, dword ptr [rip + LCPI0_11]
  vbroadcastss ymm12, dword ptr [rip + LCPI0_4]
  xor r10d, r10d
  jmp @LBB0_2
@LBB0_4:
  vxorps xmm9, xmm9, xmm9
  vcmpleps ymm0, ymm0, ymm9
  vbroadcastss ymm10, dword ptr [rip + LCPI0_12]
  vpbroadcastd ymm9, dword ptr [rip + LCPI0_13]
  vandps ymm0, ymm10, ymm0
  vpaddd ymm9, ymm9, ymm0
  vpsubd ymm0, ymm14, ymm0
  vbroadcastss ymm10, dword ptr [rip + LCPI0_14]
  vcmpleps ymm6, ymm6, ymm10
  vmulps ymm10, ymm9, ymm9
  vfmadd231ps ymm0, ymm3, ymm0
  vmulps ymm0, ymm9, ymm0
  vfmadd231ps ymm13, ymm3, ymm13
  vblendvps ymm0, ymm13, ymm0, ymm2
  vblendvps ymm13, ymm10, ymm0, ymm6
@LBB0_5:
  vaddps ymm0, ymm13, ymm12
  vrcpps ymm2, ymm0
  vmulps ymm3, ymm15, yword ptr [r8 + 4*r10]
  vmulps ymm6, ymm3, ymm2
  vfmsub213ps ymm0, ymm6, ymm3
  vfnmadd213ps ymm0, ymm2, ymm6
  vmovups yword ptr [rcx + 4*r10], ymm0
  lea r11, [r10 + 8]
  add r10, 15
  cmp r10, rax
  mov r10, r11
  jae @LBB0_6
@LBB0_2:
  vmovups ymm15, yword ptr [rdx + 4*r10]
  vbroadcastss ymm2, dword ptr [rip + LCPI0_0]
  vfmsub213ps ymm2, ymm15, ymm1
  vaddps ymm0, ymm2, ymm1
  vbroadcastss ymm3, dword ptr [rip + LCPI0_2]
  vfmadd213ps ymm3, ymm0, ymm15
  vbroadcastss ymm6, dword ptr [rip + LCPI0_3]
  vfmsub231ps ymm3, ymm0, ymm6
  vpslld ymm14, ymm2, 23
  vmulps ymm2, ymm3, ymm3
  vmovaps ymm6, ymm8
  vbroadcastss ymm9, dword ptr [rip + LCPI0_7]
  vfmadd213ps ymm6, ymm3, ymm9
  vmovaps ymm10, ymm7
  vbroadcastss ymm9, dword ptr [rip + LCPI0_9]
  vfmadd213ps ymm10, ymm3, ymm9
  vfmadd231ps ymm10, ymm2, ymm6
  vpaddd ymm13, ymm14, ymm4
  vmulps ymm3, ymm11, ymm3
  vfmadd231ps ymm3, ymm2, ymm10
  vandps ymm6, ymm0, ymm5
  vbroadcastss ymm2, dword ptr [rip + LCPI0_6]
  vcmpltps ymm2, ymm2, ymm6
  vtestps ymm2, ymm2
  jne @LBB0_4
  vfmadd213ps ymm13, ymm3, ymm13
  jmp @LBB0_5
@LBB0_6:
  cmp r11d, r9d
  jge @LBB0_11
  vmovd xmm0, r11d
  vpbroadcastd xmm0, xmm0
  vpor xmm1, xmm0, dqword ptr [rip + LCPI0_15]
  vmovd xmm2, r9d
  vpbroadcastd xmm2, xmm2
  vpor xmm0, xmm0, dqword ptr [rip + LCPI0_16]
  vpcmpgtd xmm0, xmm2, xmm0
  vpermq ymm0, ymm0, 196
  mov eax, -1
  vmovd xmm3, eax
  vpblendd ymm0, ymm0, ymm3, 129
  vpcmpgtd xmm1, xmm2, xmm1
  vpmovsxdq xmm1, xmm1
  vinserti128 ymm1, ymm0, xmm1, 1
  vpblendd ymm0, ymm0, ymm1, 96
  mov r9d, r11d
  vmaskmovps ymm1, ymm0, yword ptr [rdx + 4*r9]
  vbroadcastss ymm2, dword ptr [rip + LCPI0_0]
  vbroadcastss ymm3, dword ptr [rip + LCPI0_1]
  lea rax, [rcx + 4*r9]
  vfmsub213ps ymm2, ymm1, ymm3
  vbroadcastss ymm4, dword ptr [rip + LCPI0_2]
  vaddps ymm3, ymm2, ymm3
  vfmadd213ps ymm4, ymm3, ymm1
  vbroadcastss ymm6, dword ptr [rip + LCPI0_3]
  vfmsub213ps ymm6, ymm3, ymm4
  vpslld ymm4, ymm2, 23
  vpbroadcastd ymm2, dword ptr [rip + LCPI0_4]
  vpaddd ymm2, ymm4, ymm2
  vbroadcastss ymm5, dword ptr [rip + LCPI0_5]
  vandps ymm5, ymm3, ymm5
  vbroadcastss ymm7, dword ptr [rip + LCPI0_6]
  vbroadcastss ymm8, dword ptr [rip + LCPI0_7]
  vmulps ymm9, ymm6, ymm6
  vbroadcastss ymm10, dword ptr [rip + LCPI0_8]
  vfmadd213ps ymm10, ymm6, ymm8
  vbroadcastss ymm8, dword ptr [rip + LCPI0_9]
  vbroadcastss ymm11, dword ptr [rip + LCPI0_10]
  vfmadd213ps ymm11, ymm6, ymm8
  vfmadd231ps ymm11, ymm9, ymm10
  vbroadcastss ymm8, dword ptr [rip + LCPI0_11]
  vmulps ymm6, ymm8, ymm6
  vfmadd231ps ymm6, ymm9, ymm11
  vcmpltps ymm7, ymm7, ymm5
  vtestps ymm7, ymm7
  je @LBB0_8
  vxorps xmm8, xmm8, xmm8
  vcmpleps ymm3, ymm3, ymm8
  vbroadcastss ymm8, dword ptr [rip + LCPI0_12]
  vandps ymm3, ymm8, ymm3
  vpbroadcastd ymm8, dword ptr [rip + LCPI0_13]
  vpaddd ymm8, ymm8, ymm3
  vpsubd ymm3, ymm4, ymm3
  vbroadcastss ymm4, dword ptr [rip + LCPI0_14]
  vcmpleps ymm4, ymm5, ymm4
  vmulps ymm5, ymm8, ymm8
  vfmadd231ps ymm3, ymm6, ymm3
  vmulps ymm3, ymm8, ymm3
  vfmadd231ps ymm2, ymm6, ymm2
  vblendvps ymm2, ymm2, ymm3, ymm7
  vblendvps ymm2, ymm5, ymm2, ymm4
  jmp @LBB0_10
@LBB0_8:
  vfmadd213ps ymm2, ymm6, ymm2
@LBB0_10:
  vbroadcastss ymm3, dword ptr [rip + LCPI0_4]
  vaddps ymm2, ymm2, ymm3
  vrcpps ymm3, ymm2
  vmaskmovps ymm4, ymm0, yword ptr [r8 + 4*r9]
  vmulps ymm1, ymm4, ymm1
  vmulps ymm4, ymm1, ymm3
  vfmsub213ps ymm2, ymm4, ymm1
  vfnmadd213ps ymm2, ymm3, ymm4
  vmaskmovps yword ptr [rax], ymm0, ymm2
@LBB0_11:
  vmovaps xmm6, dqword ptr [rsp]
  vmovaps xmm7, dqword ptr [rsp + 16]
  vmovaps xmm8, dqword ptr [rsp + 32]
  vmovaps xmm9, dqword ptr [rsp + 48]
  vmovaps xmm10, dqword ptr [rsp + 64]
  vmovaps xmm11, dqword ptr [rsp + 80]
  vmovaps xmm12, dqword ptr [rsp + 96]
  vmovaps xmm13, dqword ptr [rsp + 112]
  vmovaps xmm14, dqword ptr [rsp + 128]
  vmovaps xmm15, dqword ptr [rsp + 144]
  add rsp, 168
  vzeroupper
end;
{$endif}

procedure PascalDoSwiGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);
var Index:TPasLLMInt32;
    Value:TPasLLMFloat;
begin
 for Index:=0 to aSize-1 do begin
  Value:=aA^[Index];
  aOut^[Index]:=(Value/(1.0+exp(-Value)))*aB^[Index];
 end;
end;

class procedure TPasLLMModelInferenceInstance.DoSwiGLU(const aOut,aA,aB:PPasLLMFloatArray;const aSize:TPasLLMInt32);
begin
{$if defined(cpuamd64)}
 if (PasLLMCPUFeatures and (PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask))=(PasLLMCPUFeatures_X86_AVX2_Mask or PasLLMCPUFeatures_X86_FMA3_Mask) then begin
  AMD64DoSwiGLU(aOut,aA,aB,aSize);
 end else{$ifend}begin
  PascalDoSwiGLU(aOut,aA,aB,aSize);
 end;
end;

class function TPasLLMModelInferenceInstance.GELU(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the GEGLU activation function to the input value
 // GEGLU is a combination of the Gaussian Error Linear Unit (GELU) and the Gated Linear Unit (GLU) activations
 // It is defined as: GEGLU(x) = x * GELU(x)
 // This function is used to introduce non-linearity in the model
 // The GELU activation is defined as: GELU(x) = 0.5 * x * (1 + tanh(0.797885 * (x + 0.044715 * x^3)))
 result:=0.5*aValue*(1.0+(TanH(0.797885*(aValue+(0.044715*aValue*aValue*aValue))))); // Apply the GELU activation
end;

class function TPasLLMModelInferenceInstance.SILU(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the SwiGLU activation function to the input value
 // SwiGLU is a combination of the Swish and GLU (Gated Linear Unit) activations
 // It is defined as: SwiGLU(x) = x * sigmoid(x)
 // This function is used to introduce non-linearity in the model
 result:=aValue/(1.0+exp(-aValue)); // Apply the Swish activation
end;

class function TPasLLMModelInferenceInstance.XIELU(const aValue,aAlphaP,aAlphaN,aBeta,aEpsilon:TPasLLMFloat):TPasLLMFloat;
var Value:TPasLLMFloat;
begin
 if aValue>0.0 then begin
  result:=(sqr(aValue)*aAlphaP)+(aValue*aBeta);
 end else begin
  if aEpsilon<aValue then begin
   Value:=aEpsilon;
  end else begin
   Value:=aValue;
  end;
  Value:=(((exp(Value)-1.0)-aValue)*aAlphaN)+(aValue*aBeta);
 end;
end;

class function TPasLLMModelInferenceInstance.RELU(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the ReLU (Rectified Linear Unit) activation function to the input value
 // ReLU is defined as: ReLU(x) = max(0, x)
 // This function is used to introduce non-linearity in the model
 if aValue>0.0 then begin
  result:=aValue; // If the input value is positive, return it as is
 end else begin
  result:=0.0; // If the input value is negative or zero, return zero
 end;
end;

class function TPasLLMModelInferenceInstance.RELU2(const aValue:TPasLLMFloat):TPasLLMFloat;
var ValueSquared:TPasLLMFloat;
begin
 // Applies the ReLU2 activation function to the input value
 // ReLU2 is defined as: ReLU2(x) = max(0, x^2)
 // This function is used to introduce non-linearity in the model
 if aValue>0.0 then begin
  ValueSquared:=aValue*aValue; // Calculate the square of the input value
  if ValueSquared>0.0 then begin
   result:=ValueSquared; // If the squared value is positive, return it
  end else begin
   result:=0.0; // If the squared value is negative or zero, return zero
  end;
 end else begin
  result:=0.0; // If the input value is negative or zero, return zero
 end;
end;

class function TPasLLMModelInferenceInstance.SWISH(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the Swish activation function to the input value
 // Swish is defined as: Swish(x) = x * sigmoid(x)
 // This function is used to introduce non-linearity in the model
 result:=aValue/(1.0+exp(-aValue)); // Apply the Swish activation
end;

class function TPasLLMModelInferenceInstance.SoftPlus(const aValue:TPasLLMFloat;const aBeta:TPasLLMFloat;const aThreshold:TPasLLMFloat):TPasLLMFloat; 
begin
 if (aValue*aBeta)>aThreshold then begin
  result:=aValue;
 end else begin
  result:=Ln(1.0+Exp(aValue*aBeta))/aBeta;
 end; 
end;

class function TPasLLMModelInferenceInstance.MISH(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the Mish activation function to the input value
 // Mish is defined as: Mish(x) = x * tanh(softplus(x))
 // This function is used to introduce non-linearity in the model
 result:=aValue*Tanh(SoftPlus(aValue)); // Apply the Mish activation
end;

class function TPasLLMModelInferenceInstance.LINEAR(const aValue:TPasLLMFloat):TPasLLMFloat;
begin
 // Applies the Linear activation function to the input value
 // Linear is defined as: Linear(x) = x
 // This function is used to introduce non-linearity in the model
 result:=aValue; // Apply the Linear activation
end;

class procedure TPasLLMModelInferenceInstance.AdvanceSWAKVSink(var aKVSink,aKVLen:TPasLLMSizeInt;const aWindow,aMaxSequenceLength:TPasLLMSizeInt);
var Excess:TPasLLMSizeInt;
begin
 if (aMaxSequenceLength>0) and (aWindow>0) and (aKVLen>aWindow) then begin
  Excess:=aKVLen-aWindow;
  if Excess>0 then begin
   aKVSink:=(aKVSink+Excess) mod aMaxSequenceLength;
  end;
 end;
end;

class procedure TPasLLMModelInferenceInstance.MatMulParallelForProcedure(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Data:PPasLLMModelInferenceInstanceParallelMatMulData;
begin
 Data:=PPasLLMModelInferenceInstanceParallelMatMulData(aData); // Cast the data pointer to the parallel matmul data type
 QuantizedMatMul(Data.XOut,Data.X,Data.W,Data.N,aFromIndex,aToIndex); // Perform the matrix multiplication for each index
end;

procedure TPasLLMModelInferenceInstance.ParallelMatMulFunction(const aData:Pointer);
var Index:TPasMPInt32;
    ParallelMatMulData:PPasLLMModelInferenceInstanceParallelMatMulData;
begin
 ParallelMatMulData:=PPasLLMModelInferenceInstanceParallelMatMulData(aData);
 // Loop through the ParallelAttentionFunction heads
 repeat
  Index:=TPasMPInterlocked.Increment(ParallelMatMulData^.Counter)-1;
  if Index<ParallelMatMulData^.D then begin
   // Perform the matrix multiplication for each index
   QuantizedMatMul(ParallelMatMulData^.XOut,
                   ParallelMatMulData^.X,
                   ParallelMatMulData^.W,
                   ParallelMatMulData^.N,
                   Index,
                   Index);
  end else begin
   break;
  end;
 until false;
end;

procedure TPasLLMModelInferenceInstance.MatMul(const aXOut:PPasLLMFloatArray;const aX,aW:TPasLLMTensor;const aN,aD:TPasLLMInt32);
var ParallelMatMulData:TPasLLMModelInferenceInstanceParallelMatMulData;
    DesiredChunks,CountTotalValues,ValuesPerChunk,Granularity:TPasLLMSizeInt;
begin

 // Multiply aX by aW and store in aXOut.
 // aX: input matrix, aW: weight matrix, aXOut: output matrix.
 // aN: number of columns in aX / rows in aW.
 // aD: number of rows in aX / columns in aW.
 // Run in parallel only if aD > 1 and PasMP is available.

 // Check if parallel execution is available and desired
 if (aD>1) and assigned(fPasLLM.fPasMPInstance) then begin

  // Initialize the parallel matrix multiplication data structure
  ParallelMatMulData.Counter:=0;
  ParallelMatMulData.XOut:=aXOut;
  ParallelMatMulData.X:=aX;
  ParallelMatMulData.W:=aW;
  ParallelMatMulData.D:=aD;
  ParallelMatMulData.N:=aN;

  // Use job manager if assigned (naive parallel, can be slower for small aD)
  if assigned(fJobManager) then begin

   // Parallel execution via job manager
   fJobManager.Execute(ParallelMatMulFunction,@ParallelMatMulData);

  end else begin

   // Determine number of chunks: threads (at least 1, max aD), no multiplier.
   DesiredChunks:=Min(Max(1,fPasLLM.fPasMPInstance.CountJobWorkerThreads),aD);

   // Total number of values to process (Rows * Columns).
   CountTotalValues:=TPasLLMSizeInt(aD)*TPasLLMSizeInt(aN);

   // Compute values per chunk: Ceil(CountTokens / DesiredChunks)
   // Ensures each chunk has approximately equal work
   ValuesPerChunk:=(CountTotalValues+(DesiredChunks-1)) div DesiredChunks;

   // Compute granularity: Ceil(ValuesPerChunk / Columns)
   // Ensures that the granularity is in whole rows
   Granularity:=(ValuesPerChunk+(aN-1)) div aN;

   // Clamp granularity to be at least 1 and at most aD
   Granularity:=Min(Max(Granularity,1),aD);

   // Use PasMP parallel-for if enough chunks, else run direct
   // This allows efficient parallelism for large jobs, falls back for small
   if Granularity<aD then begin

    // Run PasMP parallel-for over row blocks
    fPasLLM.fPasMPInstance.Invoke(
     fPasLLM.fPasMPInstance.ParallelFor(
      @ParallelMatMulData,
      0,
      aD-1,
      MatMulParallelForProcedure,
      Granularity,
      PasMPDefaultDepth,
      nil,
      0,
      0,
      0,
      true
     )
    );

   end else begin

    // Not worth parallelism: run direct, saving overhead
    QuantizedMatMul(aXOut,aX,aW,aN,0,aD-1);

   end;

  end;

 end else begin

  // Fallback: direct single-threaded multiply
  QuantizedMatMul(aXOut,aX,aW,aN,0,aD-1);

 end;

end;

procedure TPasLLMModelInferenceInstance.MatMulQParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var ParallelQKVData:PPasLLMModelInferenceInstanceParallelQKVData;
begin
 ParallelQKVData:=PPasLLMModelInferenceInstanceParallelQKVData(aJob^.Data);
 MatMul(
  ParallelQKVData^.QueryRow,
  ParallelQKVData^.RunState.fXQ,
  ParallelQKVData^.Weights.fWQ[ParallelQKVData.LayerIndex],
  ParallelQKVData^.Dim,
  ParallelQKVData^.QDim
 );
 if (length(ParallelQKVData^.Weights.fWQBias)>0) and assigned(ParallelQKVData^.Weights.fWQBias[ParallelQKVData^.LayerIndex]) then begin
  AddFloats(Pointer(ParallelQKVData^.QueryRow),Pointer(@ParallelQKVData^.Weights.fWQBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.QDim);
 end;
 if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
  ClipFloats(ParallelQKVData^.QueryRow,ParallelQKVData^.QDim,ParallelQKVData^.QKVClip);
 end;
end;

procedure TPasLLMModelInferenceInstance.MatMulKParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var ParallelQKVData:PPasLLMModelInferenceInstanceParallelQKVData;
begin
 ParallelQKVData:=PPasLLMModelInferenceInstanceParallelQKVData(aJob^.Data);
 MatMul(
  ParallelQKVData^.KeyCacheRow,
  ParallelQKVData^.RunState.fXQ,
  ParallelQKVData^.Weights.fWK[ParallelQKVData.LayerIndex],
  ParallelQKVData^.Dim,
  ParallelQKVData^.KVDim
 );
 if (length(ParallelQKVData^.Weights.fWKBias)>0) and assigned(ParallelQKVData^.Weights.fWKBias[ParallelQKVData^.LayerIndex]) then begin
  AddFloats(Pointer(ParallelQKVData^.KeyCacheRow),Pointer(@ParallelQKVData^.Weights.fWKBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.KVDim);
 end;
 if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
  ClipFloats(ParallelQKVData^.KeyCacheRow,ParallelQKVData^.KVDim,ParallelQKVData^.QKVClip);
 end;
end;

procedure TPasLLMModelInferenceInstance.MatMulVParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var ParallelQKVData:PPasLLMModelInferenceInstanceParallelQKVData;
begin
 ParallelQKVData:=PPasLLMModelInferenceInstanceParallelQKVData(aJob^.Data);
 MatMul(
  ParallelQKVData^.ValueCacheRow,
  ParallelQKVData^.RunState.fXQ,
  ParallelQKVData^.Weights.fWV[ParallelQKVData.LayerIndex],
  ParallelQKVData^.Dim,
  ParallelQKVData^.KVDim
 );
 if (length(ParallelQKVData^.Weights.fWVBias)>0) and assigned(ParallelQKVData^.Weights.fWVBias[ParallelQKVData^.LayerIndex]) then begin
  AddFloats(Pointer(ParallelQKVData^.ValueCacheRow),Pointer(@ParallelQKVData^.Weights.fWVBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.KVDim);
 end;
 if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
  ClipFloats(ParallelQKVData^.ValueCacheRow,ParallelQKVData^.KVDim,ParallelQKVData^.QKVClip);
 end;
end;

procedure TPasLLMModelInferenceInstance.ParallelMatMulQKVFunction(const aData:Pointer);
var Index:TPasMPInt32;
    ParallelQKVData:PPasLLMModelInferenceInstanceParallelQKVData;
begin

 ParallelQKVData:=PPasLLMModelInferenceInstanceParallelQKVData(aData);

 // Perform the matrix multiplication for each index
 repeat

  Index:=TPasMPInterlocked.Increment(ParallelQKVData^.Counter)-1;

  if Index<ParallelQKVData^.QDim then begin
   QuantizedMatMul(ParallelQKVData^.QueryRow,
                   ParallelQKVData^.RunState.fXQ,
                   ParallelQKVData^.Weights.fWQ[ParallelQKVData^.LayerIndex],
                   ParallelQKVData^.Dim,
                   Index,
                   Index);
   continue;
  end else begin
   dec(Index,ParallelQKVData^.QDim);
  end;

  if Index<ParallelQKVData^.KVDim then begin
   QuantizedMatMul(ParallelQKVData^.KeyCacheRow,
                   ParallelQKVData^.RunState.fXQ,
                   ParallelQKVData^.Weights.fWK[ParallelQKVData^.LayerIndex],
                   ParallelQKVData^.Dim,
                   Index,
                   Index);
   continue;
  end else begin
   dec(Index,ParallelQKVData^.KVDim);
  end;

  if Index<ParallelQKVData^.KVDim then begin
   QuantizedMatMul(ParallelQKVData^.ValueCacheRow,
                   ParallelQKVData^.RunState.fXQ,
                   ParallelQKVData^.Weights.fWV[ParallelQKVData^.LayerIndex],
                   ParallelQKVData^.Dim,
                   Index,
                   Index);
   continue;
  end;

  break;

 until false;
end;

procedure TPasLLMModelInferenceInstance.ParallelPostQKVFunction(const aData:Pointer);
var Index:TPasMPInt32;
    ParallelQKVData:PPasLLMModelInferenceInstanceParallelQKVData;
begin
 ParallelQKVData:=PPasLLMModelInferenceInstanceParallelQKVData(aData);

 // Perform the matrix multiplication for each index

 repeat

  Index:=TPasMPInterlocked.Increment(ParallelQKVData^.Counter)-1;

  case Index of

   0:begin
    // Q
    if (length(ParallelQKVData^.Weights.fWQBias)>0) and assigned(ParallelQKVData^.Weights.fWQBias[ParallelQKVData^.LayerIndex]) then begin
     AddFloats(Pointer(ParallelQKVData^.QueryRow),Pointer(@ParallelQKVData^.Weights.fWQBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.QDim);
    end;
    if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
     ClipFloats(ParallelQKVData^.QueryRow,ParallelQKVData^.QDim,ParallelQKVData^.QKVClip);
    end;
   end;

   1:begin
    // K
    if (length(ParallelQKVData^.Weights.fWKBias)>0) and assigned(ParallelQKVData^.Weights.fWKBias[ParallelQKVData^.LayerIndex]) then begin
     AddFloats(Pointer(ParallelQKVData^.KeyCacheRow),Pointer(@ParallelQKVData^.Weights.fWKBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.KVDim);
    end;
    if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
     ClipFloats(ParallelQKVData^.KeyCacheRow,ParallelQKVData^.KVDim,ParallelQKVData^.QKVClip);
    end;
   end;

   2:begin
    // V
    if (length(ParallelQKVData^.Weights.fWVBias)>0) and assigned(ParallelQKVData^.Weights.fWVBias[ParallelQKVData^.LayerIndex]) then begin
     AddFloats(Pointer(ParallelQKVData^.ValueCacheRow),Pointer(@ParallelQKVData^.Weights.fWVBias[ParallelQKVData^.LayerIndex]^[0]),ParallelQKVData^.KVDim);
    end;
    if not (IsInfinite(ParallelQKVData^.QKVClip) or IsZero(ParallelQKVData^.QKVClip)) then begin
     ClipFloats(ParallelQKVData^.ValueCacheRow,ParallelQKVData^.KVDim,ParallelQKVData^.QKVClip);
    end;
   end;

   else begin
    break;
   end;

  end;

 until false;

end;

procedure TPasLLMModelInferenceInstance.RoPEQParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ParallelRoPEData:PPasLLMModelInferenceInstanceParallelRoPEData; // Pointer to the parallel RoPE data
    HeadIndex:TPasMPNativeInt;
begin

 ParallelRoPEData:=PPasLLMModelInferenceInstanceParallelRoPEData(aData); // Cast the data pointer to the parallel RoPE data type
 for HeadIndex:=aFromIndex to aToIndex do begin // Loop through the heads

  // Normalize the query row if normalization is enabled
  if fModel.fConfiguration.fQKNormalization then begin
   RMSNormNoWeights(
    @ParallelRoPEData.QueryRow^[HeadIndex*ParallelRoPEData.HeadDim],
    @ParallelRoPEData.QueryRow^[HeadIndex*ParallelRoPEData.HeadDim],
    ParallelRoPEData.HeadDim,
    fModel.fConfiguration.fNormalizationEpsilon
   );
  end;

  // Normalize the query row if RMS normalization is enabled
  if fModel.fConfiguration.fQKRMSNormalization then begin
   RMSNorm(
    @ParallelRoPEData.QueryRow^[HeadIndex*ParallelRoPEData.HeadDim],
    @ParallelRoPEData.QueryRow^[HeadIndex*ParallelRoPEData.HeadDim],
    Pointer(@fModel.fWeights.fRMSQNormalizationWeights[ParallelRoPEData.LayerIndex]^[0]),
    ParallelRoPEData.HeadDim,
    fModel.fConfiguration.fNormalizationEpsilon
   );
  end;

  // Apply RoPE to the query vector
  CachedRoPESingleHead(
   @ParallelRoPEData.QueryRow^[HeadIndex*ParallelRoPEData.HeadDim],
   @fRunState.fRoPECache[0],
   ParallelRoPEData.HeadDim,
   ParallelRoPEData.RotaryDim,
   fModel.fConfiguration.fQKRoPENonInterleaved
  );

 end;
end;

procedure TPasLLMModelInferenceInstance.RoPEKParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ParallelRoPEData:PPasLLMModelInferenceInstanceParallelRoPEData; // Pointer to the parallel RoPE data
    HeadIndex:TPasMPNativeInt;
begin

 ParallelRoPEData:=PPasLLMModelInferenceInstanceParallelRoPEData(aData); // Cast the data pointer to the parallel RoPE data type

 for HeadIndex:=aFromIndex to aToIndex do begin // Loop through the heads

  // Normalize the key cache row if normalization is enabled
  if fModel.fConfiguration.fQKNormalization then begin
   RMSNormNoWeights(
    @ParallelRoPEData.KeyCacheRow^[HeadIndex*ParallelRoPEData.HeadDim],
    @ParallelRoPEData.KeyCacheRow^[HeadIndex*ParallelRoPEData.HeadDim],
    ParallelRoPEData.HeadDim,
    fModel.fConfiguration.fNormalizationEpsilon
   );
  end;

  // Normalize the key cache row if RMS normalization is enabled
  if fModel.fConfiguration.fQKRMSNormalization then begin
   RMSNorm(
    @ParallelRoPEData.KeyCacheRow^[HeadIndex*ParallelRoPEData.HeadDim],
    @ParallelRoPEData.KeyCacheRow^[HeadIndex*ParallelRoPEData.HeadDim],
    Pointer(@fModel.fWeights.fRMSKNormalizationWeights[ParallelRoPEData.LayerIndex]^[0]),
    ParallelRoPEData.HeadDim,
    fModel.fConfiguration.fNormalizationEpsilon
   );
  end;

  // Apply RoPE to the key vector
  CachedRoPESingleHead(
   @ParallelRoPEData.KeyCacheRow^[HeadIndex*ParallelRoPEData.HeadDim],
   @fRunState.fRoPECache[0],
   ParallelRoPEData.HeadDim,
   ParallelRoPEData.RotaryDim,
   fModel.fConfiguration.fQKRoPENonInterleaved
  );

 end;

end;

procedure TPasLLMModelInferenceInstance.ParallelRoPEFunction(const aData:Pointer);
var HeadIndex:TPasMPInt32;
    ParallelRoPEData:PPasLLMModelInferenceInstanceParallelRoPEData; // Pointer to the parallel RoPE data
    QueryRow,KeyCacheRow:PPasLLMFloatArray; // Pointers to the query and key cache rows
    CountQueryHeads,CountKeyValueHeads,
    LayerIndex,HeadDim,RotaryDim:TPasLLMInt32; // Layer index, head dimension, and rotary dimension
    Weights:TPasLLMModelWeights; // Pointer to the model weights
    RunState:TPasLLMRunState; // Pointer to the run state of the model inference instance
    QKNormalization,QKRMSNormalization,QKRoPENonInterleaved:Boolean;
    NormalizationEpsilon:TPasLLMFloat;
begin

 ParallelRoPEData:=PPasLLMModelInferenceInstanceParallelRoPEData(aData); // Cast the data pointer to the parallel RoPE data type
 QueryRow:=ParallelRoPEData^.QueryRow; // Get the query row pointer
 KeyCacheRow:=ParallelRoPEData^.KeyCacheRow; // Get the key cache row
 LayerIndex:=ParallelRoPEData^.LayerIndex; // Get the layer index
 HeadDim:=ParallelRoPEData^.HeadDim; // Get the head dimension
 RotaryDim:=ParallelRoPEData^.RotaryDim; // Get the rotary dimension
 Weights:=fModel.fWeights; // Get the model weights
 RunState:=fRunState; // Get the run state of the model

 CountQueryHeads:=fModel.fConfiguration.fCountQueryHeads;
 CountKeyValueHeads:=fModel.fConfiguration.fCountKeyValueHeads;
 QKNormalization:=fModel.fConfiguration.fQKNormalization;
 QKRMSNormalization:=fModel.fConfiguration.fQKRMSNormalization;
 NormalizationEpsilon:=fModel.fConfiguration.fNormalizationEpsilon;
 QKRoPENonInterleaved:=fModel.fConfiguration.fQKRoPENonInterleaved;

 // Loop through the ParallelAttentionFunction heads
 repeat

  HeadIndex:=TPasMPInterlocked.Increment(ParallelRoPEData^.Counter)-1;

  if HeadIndex<CountQueryHeads then begin
   if QKNormalization then begin
    RMSNormNoWeights(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],HeadDim,NormalizationEpsilon);
   end;
   if QKRMSNormalization then begin
    RMSNorm(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSQNormalizationWeights[LayerIndex]^[0]),HeadDim,NormalizationEpsilon);
   end;
   CachedRoPESingleHead(@QueryRow^[HeadIndex*HeadDim],@RunState.fRoPECache[0],HeadDim,RotaryDim,QKRoPENonInterleaved); // Apply RoPE to the query vector
   continue;
  end else begin
   dec(HeadIndex,CountQueryHeads);
  end;

  if HeadIndex<CountKeyValueHeads then begin
   if QKNormalization then begin
    RMSNormNoWeights(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],HeadDim,NormalizationEpsilon);
   end;
   if QKRMSNormalization then begin
    RMSNorm(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSKNormalizationWeights[LayerIndex]^[0]),HeadDim,NormalizationEpsilon);
   end;
   CachedRoPESingleHead(@KeyCacheRow^[HeadIndex*HeadDim],@RunState.fRoPECache[0],HeadDim,RotaryDim,QKRoPENonInterleaved); // Apply RoPE to the key vector
   continue;
  end;

  break;

 until false;

end;

procedure TPasLLMModelInferenceInstance.StreamingLLMRoPEParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Index,CountKeyValueHeads:TPasMPNativeInt;
    RotationIndex,HeadIndex:TPasMPInt32;
    ParallelStreamingLLMRoPEData:PPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData; // Pointer to the parallel streaming LLM RoPE data
    KeyCacheBase:PPasLLMFloatArray; // Pointer to the base of the key cache
    HeadDim,RotaryDim,KVDim:TPasLLMInt32; // Head dimension, rotary dimension, and KVSink index
begin

 ParallelStreamingLLMRoPEData:=PPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData(aData); // Cast the data pointer to the parallel streaming LLM RoPE data type
 KeyCacheBase:=ParallelStreamingLLMRoPEData^.KeyCacheBase; // Get the key cache base pointer
 HeadDim:=ParallelStreamingLLMRoPEData^.HeadDim; // Get the head dimension
 RotaryDim:=ParallelStreamingLLMRoPEData^.RotaryDim; // Get the rotary dimension
 CountKeyValueHeads:=fModel.fConfiguration.fCountKeyValueHeads;
 KVDim:=ParallelStreamingLLMRoPEData^.KVDim; // Get the KVSink index
//KVSink:=ParallelStreamingLLMRoPEData^.KVSink; // Get the KVSink index

 // Loop through the attention heads
 for Index:=aFromIndex to aToIndex do begin
  RotationIndex:=Index div CountKeyValueHeads;
  HeadIndex:=Index mod CountKeyValueHeads;
  CachedRoPESingleHead(
   Pointer(@KeyCacheBase^[(RotationIndex*KVDim)+(HeadIndex*HeadDim)]),
   @fRunState.fStreamingLLMRoPECache[0],
   HeadDim,
   RotaryDim,
   fModel.fConfiguration.fRoPENonInterleaved
  );
 end;

end;

procedure TPasLLMModelInferenceInstance.ParallelStreamingLLMRoPEFunction(const aData:Pointer);
var Index,CountKeyValueHeads,RotationIndex,HeadIndex:TPasMPInt32;
    ParallelStreamingLLMRoPEData:PPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData; // Pointer to the parallel streaming LLM RoPE data
    KeyCacheBase:PPasLLMFloatArray; // Pointer to the base of the key cache
    HeadDim,RotaryDim,KVDim,KVSink:TPasLLMInt32; // Head dimension, rotary dimension, and KVSink index
begin

 ParallelStreamingLLMRoPEData:=PPasLLMModelInferenceInstanceParallelStreamingLLMRoPEData(aData); // Cast the data pointer to the parallel streaming LLM RoPE data type
 KeyCacheBase:=ParallelStreamingLLMRoPEData^.KeyCacheBase; // Get the key cache base pointer
 HeadDim:=ParallelStreamingLLMRoPEData^.HeadDim; // Get the head dimension
 RotaryDim:=ParallelStreamingLLMRoPEData^.RotaryDim; // Get the rotary dimension
 KVDim:=ParallelStreamingLLMRoPEData^.KVDim; // Get the KVSink index
 KVSink:=ParallelStreamingLLMRoPEData^.KVSink; // Get the KVSink index
 CountKeyValueHeads:=fModel.fConfiguration.fCountKeyValueHeads;

 // Loop through the ParallelAttentionFunction heads
 repeat
  Index:=TPasMPInterlocked.Increment(ParallelStreamingLLMRoPEData^.Counter)-1;
  if Index<(KVSink*CountKeyValueHeads) then begin
   RotationIndex:=Index div CountKeyValueHeads;
   HeadIndex:=Index mod CountKeyValueHeads;
   CachedRoPESingleHead(
    Pointer(@KeyCacheBase^[(RotationIndex*KVDim)+(HeadIndex*HeadDim)]),
    @fRunState.fStreamingLLMRoPECache[0],
    HeadDim,
    RotaryDim,
    fModel.fConfiguration.fRoPENonInterleaved
   );
  end else begin
   break;
  end;
 until false;

end;

procedure TPasLLMModelInferenceInstance.MatMulHBParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var ParallelHBHB2Data:PPasLLMModelInferenceInstanceParallelHBHB2Data; // Pointer to the parallel HB data
begin
 ParallelHBHB2Data:=PPasLLMModelInferenceInstanceParallelHBHB2Data(aJob^.Data); // Cast the data pointer to the parallel HB data type
 MatMul(
  Pointer(@ParallelHBHB2Data^.RunState.fHB[ParallelHBHB2Data^.ExpertBufferIndex][0]),
  ParallelHBHB2Data^.RunState.fXQ,
  ParallelHBHB2Data^.Weights.fW1[ParallelHBHB2Data^.ExpertWeightsIndex][ParallelHBHB2Data^.LayerIndex],
  ParallelHBHB2Data^.Dim,
  ParallelHBHB2Data^.HiddenDim
 );
end;

procedure TPasLLMModelInferenceInstance.MatMulHB2ParallelMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var ParallelHBHB2Data:PPasLLMModelInferenceInstanceParallelHBHB2Data; // Pointer to the parallel HB2 data
begin
 ParallelHBHB2Data:=PPasLLMModelInferenceInstanceParallelHBHB2Data(aJob^.Data); // Cast the data pointer to the parallel HB2 data type
 MatMul(
  Pointer(@ParallelHBHB2Data^.RunState.fHB2[ParallelHBHB2Data^.ExpertBufferIndex][0]),
  ParallelHBHB2Data^.RunState.fXQ,
  ParallelHBHB2Data^.Weights.fW3[ParallelHBHB2Data^.ExpertWeightsIndex][ParallelHBHB2Data^.LayerIndex],
  ParallelHBHB2Data^.Dim,
  ParallelHBHB2Data^.HiddenDim
 );
end;

procedure TPasLLMModelInferenceInstance.AttentionParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ParallelAttentionData:PPasLLMModelInferenceInstanceParallelAttentionData; // Pointer to the parallel attention data
    HeadIndex:TPasMPNativeInt;
begin
 ParallelAttentionData:=PPasLLMModelInferenceInstanceParallelAttentionData(aData); // Cast the data pointer to the parallel attention data type
 for HeadIndex:=aFromIndex to aToIndex do begin // Loop through the attention heads
  TPasLLMModelInferenceInstance.AttentionDispatch(
   @ParallelAttentionData.XOut^[HeadIndex*ParallelAttentionData^.HeadDim],
   @ParallelAttentionData.AttH^[HeadIndex*fModel.fConfiguration.fMaximumSequenceLength],
   @ParallelAttentionData.QH^[HeadIndex*ParallelAttentionData^.HeadDim],
   @ParallelAttentionData.KH^[(HeadIndex div ParallelAttentionData.KVMul)*ParallelAttentionData^.HeadDim],
   @ParallelAttentionData.VH^[(HeadIndex div ParallelAttentionData.KVMul)*ParallelAttentionData^.HeadDim],
   ParallelAttentionData.HeadDim,
   ParallelAttentionData.KVDim,
   ParallelAttentionData.KVLen,
   ParallelAttentionData.SWAType,
   ParallelAttentionData.IsSliding,
   ParallelAttentionData.ChunkLen,
   fModel.fConfiguration.fAttnLogitSoftcapping
  );
 end;
end;

procedure TPasLLMModelInferenceInstance.ParallelAttentionFunction(const aData:Pointer);
var HeadIndex,CountQueryHeads,MaximumSequenceLength:TPasMPSizeInt;
    ParallelAttentionData:PPasLLMModelInferenceInstanceParallelAttentionData; // Pointer to the parallel attention data
begin

 ParallelAttentionData:=PPasLLMModelInferenceInstanceParallelAttentionData(aData); // Cast the data pointer to the parallel ParallelAttentionFunction data type

 CountQueryHeads:=fModel.fConfiguration.fCountQueryHeads;
 MaximumSequenceLength:=fModel.fConfiguration.fMaximumSequenceLength;

 // Loop through the ParallelAttentionFunction heads
 repeat
  HeadIndex:=TPasMPInterlocked.Increment(ParallelAttentionData^.Counter)-1;
  if HeadIndex<CountQueryHeads then begin
   TPasLLMModelInferenceInstance.AttentionDispatch(
    @ParallelAttentionData.XOut^[HeadIndex*ParallelAttentionData^.HeadDim],
    @ParallelAttentionData.AttH^[HeadIndex*MaximumSequenceLength],
    @ParallelAttentionData.QH^[HeadIndex*ParallelAttentionData^.HeadDim],
    @ParallelAttentionData.KH^[(HeadIndex div ParallelAttentionData.KVMul)*ParallelAttentionData^.HeadDim],
    @ParallelAttentionData.VH^[(HeadIndex div ParallelAttentionData.KVMul)*ParallelAttentionData^.HeadDim],
    ParallelAttentionData.HeadDim,
    ParallelAttentionData.KVDim,
    ParallelAttentionData.KVLen,
    ParallelAttentionData.SWAType,
    ParallelAttentionData.IsSliding,
    ParallelAttentionData.ChunkLen,
    fModel.fConfiguration.fAttnLogitSoftcapping
   );
  end else begin
   break;
  end;
 until false;

end;

procedure TPasLLMModelInferenceInstance.MixtureOfExpertGate;
var Index,OtherIndex,BestIndex:TPasLLMInt32;
    MaxValue,WeightSum,Value:TPasLLMFloat;
    Mask:array[0..7] of TPasLLMUInt32; // Bitmask to track selected experts (256 bits for maximal 256 experts)
    x:PPasLLMFloatArray; // Pointer to the input tensor
begin

 x:=Pointer(@fRunState.fEB[0]); // Get the pointer to the input tensor

 MaxValue:=-Infinity; // Initialize the maximum value to negative infinity
 for Index:=0 to fModel.fConfiguration.fCountExperts-1 do begin
  if MaxValue<x^[Index] then begin // Find the maximum value in the input tensor
   MaxValue:=x^[Index];
  end;
 end;

 // Top-k selection of experts
 for Index:=0 to 7 do begin // Initialize the mask to zero
  Mask[Index]:=0;
 end;
 WeightSum:=0.0; // Initialize the weight sum to zero
 for Index:=0 to fModel.fConfiguration.fCountActiveExperts-1 do begin // Loop through the active experts
  BestIndex:=-1; // Initialize the best index to -1
  for OtherIndex:=0 to fModel.fConfiguration.fCountExperts-1 do begin // Loop through all experts
   if ((Mask[OtherIndex shr 5] and (1 shl (OtherIndex and 31)))=0) and // Check if the expert is not already selected
      ((BestIndex=-1) or (x^[OtherIndex]>x^[BestIndex])) then begin
    BestIndex:=OtherIndex; // Update the best index if the current expert has a higher value
   end;
  end;
  if BestIndex>=0 then begin
   Value:=Exp(x^[BestIndex]-MaxValue); // Calculate the the exponential of the best expert's value
   WeightSum:=WeightSum+Value; // Update the weight sum with the exponential of the best expert's value
   Mask[BestIndex shr 5]:=Mask[BestIndex shr 5] or (1 shl (BestIndex and 31)); // Mark as processed
   fRunState.fMixtureOfExpertWeights[Index]:=Value; // Store the expert weight
   fRunState.fMixtureOfExpertWeightIndices[Index]:=BestIndex; // Store the best expert index in the run state
  end else begin
   fRunState.fMixtureOfExpertWeights[Index]:=0.0; // Set the expert weight to zero, if no expert
   fRunState.fMixtureOfExpertWeightIndices[Index]:=0; // Set the expert index to zero, if no expert
  end;
 end;

 // Normalize the weights for the selected experts
 for Index:=0 to fModel.fConfiguration.fCountActiveExperts-1 do begin // Loop through the active experts
  if fRunState.fMixtureOfExpertWeightIndices[Index]>=0 then begin
   fRunState.fMixtureOfExpertWeights[Index]:=fRunState.fMixtureOfExpertWeights[Index]/WeightSum; // Calculate the normalized weight for the expert
  end;
 end;

end;

procedure TPasLLMModelInferenceInstance.FeedForwardNeuralNetworkForward(const aLayerIndex,aActiveExpertIndex:TPasLLMSizeInt);
var ExpertBufferIndex,ExpertWeightsIndex,Dim,HiddenDim,Index:TPasLLMSizeInt;
    ExpertWeight,
    ActivationFunctionAlphaP,ActivationFunctionAlphaN,
    ActivationFunctionBeta,ActivationFunctionEpsilon:TPasLLMFloat;
    HB,HB2:PPasLLMFloatArray;
    ParallelHBHB2Data:TPasLLMModelInferenceInstanceParallelHBHB2Data;
begin

 Dim:=fModel.fConfiguration.fDim;
 HiddenDim:=fModel.fConfiguration.fExpertHiddenDim;

 if fRunState.fCountExpertBuffers>1 then begin
  ExpertBufferIndex:=aActiveExpertIndex;
 end else begin
  ExpertBufferIndex:=0;
 end;

 ExpertWeight:=fRunState.fMixtureOfExpertWeights[aActiveExpertIndex];
 if abs(ExpertWeight)>0.0 then begin

  ExpertWeightsIndex:=fRunState.fMixtureOfExpertWeightIndices[aActiveExpertIndex];

  // Now for FFN in PyTorch we have: self.fW2(F.silu(self.fW1(x)) * self.fW3(x))
  // First calculate self.fW1(x) and self.fW3(x)
  if assigned(fPasLLM.fPasMPInstance) and not assigned(fJobManager) then begin
   // Prepare the parallel HBHB2 data for the parallel for loop
   ParallelHBHB2Data.RunState:=fRunState;
   ParallelHBHB2Data.Weights:=fModel.fWeights;
   ParallelHBHB2Data.ExpertBufferIndex:=ExpertBufferIndex;
   ParallelHBHB2Data.ExpertWeightsIndex:=ExpertWeightsIndex;
   ParallelHBHB2Data.LayerIndex:=aLayerIndex;
   ParallelHBHB2Data.Dim:=Dim;
   ParallelHBHB2Data.HiddenDim:=HiddenDim;
   if fModel.fConfiguration.ActivationType=TPasLLMActivationType.XIELU then begin
    fPasLLM.fPasMPInstance.Invoke(
      fPasLLM.fPasMPInstance.Acquire(MatMulHB2ParallelMethod,@ParallelHBHB2Data)
    );
   end else begin
    fPasLLM.fPasMPInstance.Invoke(
     [
      fPasLLM.fPasMPInstance.Acquire(MatMulHBParallelMethod,@ParallelHBHB2Data),
      fPasLLM.fPasMPInstance.Acquire(MatMulHB2ParallelMethod,@ParallelHBHB2Data)
     ]
    );
   end;
  end else begin
   if fModel.fConfiguration.ActivationType<>TPasLLMActivationType.XIELU then begin
    MatMul(@fRunState.fHB[ExpertBufferIndex][0],fRunState.fXQ,fModel.fWeights.fW1[ExpertWeightsIndex][aLayerIndex],Dim,HiddenDim); // First ffn matrix multiplication
   end;
   MatMul(@fRunState.fHB2[ExpertBufferIndex][0],fRunState.fXQ,fModel.fWeights.fW3[ExpertWeightsIndex][aLayerIndex],Dim,HiddenDim); // Second ffn matrix multiplication
  end;

{ CheckNaNs(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim);
  CheckNaNs(@fRunState.fHB2[ExpertBufferIndex][0],HiddenDim);}

  HB:=@fRunState.fHB[ExpertBufferIndex][0];
  HB2:=@fRunState.fHB2[ExpertBufferIndex][0];
  case fModel.fConfiguration.fActivationType of
   TPasLLMActivationType.SILU:begin
    // SwiGLU non-linearity, silu(x)=x*σ(x), where σ(x) is the logistic sigmoid
   TPasLLMModelInferenceInstance.DoSwiGLU(HB,HB,HB2,HiddenDim); // Apply the SwiGLU activation
   {for Index:=0 to HiddenDim-1 do begin // Apply the SwiGLU activation
     HB^[Index]:=SILU(HB^[Index])*HB2^[Index];
    end;}
   end;
   TPasLLMActivationType.GELU:begin
    TPasLLMModelInferenceInstance.DoaGEGLU(HB,HB,HB2,HiddenDim); // Apply the DoaGEGLU activation
   {for Index:=0 to HiddenDim-1 do begin // Apply the GELU activation
     HB^[Index]:=GELU(HB^[Index])*HB2^[Index];
    end;}
   end;
   TPasLLMActivationType.XIELU:begin
    ActivationFunctionAlphaP:=PPasLLMFloatArray(fModel.fWeights.fActivationFunctionAlphaP[aActiveExpertIndex])^[aLayerIndex];
    ActivationFunctionAlphaN:=PPasLLMFloatArray(fModel.fWeights.fActivationFunctionAlphaN[aActiveExpertIndex])^[aLayerIndex];
    ActivationFunctionBeta:=PPasLLMFloatArray(fModel.fWeights.fActivationFunctionBeta[aActiveExpertIndex])^[aLayerIndex];
    ActivationFunctionEpsilon:=PPasLLMFloatArray(fModel.fWeights.fActivationFunctionEpsilon[aActiveExpertIndex])^[aLayerIndex];
    ActivationFunctionAlphaP:=SoftPlus(ActivationFunctionAlphaP);
    ActivationFunctionAlphaN:=ActivationFunctionBeta+SoftPlus(ActivationFunctionAlphaN);
    for Index:=0 to HiddenDim-1 do begin // Apply the XIELU activation
     HB^[Index]:=XIELU(HB2^[Index],ActivationFunctionAlphaP,ActivationFunctionAlphaN,ActivationFunctionBeta,ActivationFunctionEpsilon);
    end;
   end;
   TPasLLMActivationType.RELU:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the RELU activation
     HB^[Index]:=RELU(HB^[Index])*HB2^[Index];
    end;
   end;
   TPasLLMActivationType.RELU2:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the RELU2 activation
     HB^[Index]:=RELU2(HB^[Index])*HB2^[Index];
    end;
   end;
   TPasLLMActivationType.SWISH:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the SWISH activation
     HB^[Index]:=SWISH(HB^[Index])*HB2^[Index];
    end;
   end;
   TPasLLMActivationType.SoftPlus:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the SoftPlus activation
     HB^[Index]:=SoftPlus(HB^[Index])*HB2^[Index];
    end;
   end;
   TPasLLMActivationType.MISH:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the MISH activation
     HB^[Index]:=MISH(HB^[Index])*HB2^[Index];
    end;
   end;
   TPasLLMActivationType.LINEAR:begin
    for Index:=0 to HiddenDim-1 do begin // Apply the Linear activation
     HB^[Index]:=LINEAR(HB^[Index])*HB2^[Index];
    end;
   end;
   else begin   
   end;  
  end;

//CheckNaNs(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim);

  if (aLayerIndex<length(fModel.fWeights.fRMSFeedForwardLayerNormWeights)) and assigned(fModel.fWeights.fRMSFeedForwardLayerNormWeights[aLayerIndex]) then begin

   if fModel.fConfiguration.fPostNormalization then begin

//  CheckNaNs(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim);

    // Final MatMul to get the output of the ffn
    fRunState.fHQ[ExpertBufferIndex].Quantize(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim); // Quantize the first ffn output
    MatMul(@fRunState.fHB2[ExpertBufferIndex][0],fRunState.fHQ[ExpertBufferIndex],fModel.fWeights.fW2[ExpertWeightsIndex][aLayerIndex],HiddenDim,Dim); // Final ffn matrix multiplication
//  CheckNaNs(@fRunState.fHB2[ExpertBufferIndex][0],HiddenDim);

    RMSNorm(@fRunState.fHB3[ExpertBufferIndex][0],@fRunState.fHB2[ExpertBufferIndex][0],Pointer(@fModel.fWeights.fRMSFeedForwardLayerNormWeights[aLayerIndex]^[0]),Dim,fModel.fConfiguration.fNormalizationEpsilon);
//  CheckNaNs(@fRunState.fHB3[ExpertBufferIndex][0],HiddenDim);

   end else begin

//  CheckNaNs(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim);

    RMSNorm(@fRunState.fHB2[ExpertBufferIndex][0],@fRunState.fHB[ExpertBufferIndex][0],Pointer(@fModel.fWeights.fRMSFeedForwardLayerNormWeights[aLayerIndex]^[0]),Dim,fModel.fConfiguration.fNormalizationEpsilon);
//  CheckNaNs(@fRunState.fHB2[ExpertBufferIndex][0],HiddenDim);

    // Final MatMul to get the output of the ffn
    fRunState.fHQ[ExpertBufferIndex].Quantize(@fRunState.fHB2[ExpertBufferIndex][0],HiddenDim); // Quantize the first ffn output
    MatMul(@fRunState.fHB3[ExpertBufferIndex][0],fRunState.fHQ[ExpertBufferIndex],fModel.fWeights.fW2[ExpertWeightsIndex][aLayerIndex],HiddenDim,Dim); // Final ffn matrix multiplication
//  CheckNaNs(@fRunState.fHB3[ExpertBufferIndex][0],Dim);

   end;

  end else begin

// CheckNaNs(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim);

   // Final MatMul to get the output of the ffn
   fRunState.fHQ[ExpertBufferIndex].Quantize(@fRunState.fHB[ExpertBufferIndex][0],HiddenDim); // Quantize the first ffn output
   MatMul(@fRunState.fHB3[ExpertBufferIndex][0],fRunState.fHQ[ExpertBufferIndex],fModel.fWeights.fW2[ExpertWeightsIndex][aLayerIndex],HiddenDim,Dim); // Final ffn matrix multiplication
{  if CheckNaNs(@fRunState.fHB3[ExpertBufferIndex][0],Dim) then begin
    MatMul(@fRunState.fHB3[ExpertBufferIndex][0],fRunState.fHQ[ExpertBufferIndex],fModel.fWeights.fW2[ExpertWeightsIndex][aLayerIndex],HiddenDim,Dim); // Final ffn matrix multiplication
   end;}

  end;

 end;

end;

procedure TPasLLMModelInferenceInstance.FeedForwardNeuralNetworkForwardParallelForMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var LayerIndex,ActiveExpertIndex:TPasMPNativeInt;
    ParallelFeedForwardNeuralNetworkForwardData:PPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData;
begin
 ParallelFeedForwardNeuralNetworkForwardData:=PPasLLMModelInferenceInstanceParallelFeedForwardNeuralNetworkForwardData(aData);
 LayerIndex:=ParallelFeedForwardNeuralNetworkForwardData^.LayerIndex;
 for ActiveExpertIndex:=aFromIndex to aToIndex do begin
  FeedForwardNeuralNetworkForward(LayerIndex,ActiveExpertIndex);
 end;
end;

function TPasLLMModelInferenceInstance.Forward(const aToken,aPosition:TPasLLMInt32;const aUpdateKVOnly:Boolean):Pointer; // Forward pass for the given token and position, returns the quantized tensor for the token embedding
const KV_SINKS=4;
var ActiveExpertIndex,LayerIndex,HeadDim,LayerOffset,HeadIndex,CountActiveExperts,RotationIndex,
    KVSink,KVPosition,KVLen,RotaryDim,Dim,QDim,KVDim,KVMul,QIndex,Index:TPasLLMSizeInt;
    Weights:TPasLLMModelWeights;
    Configuration:TPasLLMConfiguration;
    x:PPasLLMFloatArray;
    KeyCacheBase,ValueCacheBase,QueryRow,KeyCacheRow,ValueCacheRow:PPasLLMFloatArray;
    ExpertWeight:TPasLLMFloat;
    PositionalEncoding:TPasLLMPositionalEncoding;
    RoPECacheInitialized:Boolean;
    AttentionType:TPasLLMAttentionType;
    SWAWindow,KVStartContig,EffectiveKVLen,SWAChunkSizeLocal,ChunkStartLocal,HalfWindow,LeftIndex,
    RightIndex,P1Index:TPasLLMInt32;
    QueryPreAttnScale:TPasLLMFloat;
begin

 Configuration:=fModel.fConfiguration; // Get the configuration pointer

 if Configuration.fQueryPreAttentionScalar>0.0 then begin
  if Configuration.fHeadDim>0 then begin
   QueryPreAttnScale:=Sqrt(Configuration.fHeadDim/Configuration.fQueryPreAttentionScalar);
  end else begin
   QueryPreAttnScale:=1.0;
  end;
 end else begin
  QueryPreAttnScale:=1.0;
 end;

 Weights:=fModel.fWeights;

 x:=Pointer(@fRunState.fX[0]); // Get the activation buffer pointer
 Dim:=Configuration.fDim; // Get the dimension from the configuration
 HeadDim:=Configuration.fHeadDim;
 QDim:=Configuration.fHeadDim*Configuration.fCountQueryHeads; // Calculate the key/value dimension
 KVDim:=Configuration.fHeadDim*Configuration.fCountKeyValueHeads; // Calculate the key/value dimension
 KVMul:=Configuration.fCountQueryHeads div Configuration.fCountKeyValueHeads; // Calculate the integer multiplier of the kv sharing in multiquery
 RotaryDim:=Configuration.fRotaryDim;

 RoPECacheInitialized:=false;

 if aPosition>=Configuration.fMaximumSequenceLength then begin
  KVSink:=KV_SINKS;
 end else begin
  KVSink:=0;
 end;
 KVPosition:=KVSink+((aPosition-KVSink) mod (Configuration.fMaximumSequenceLength-KVSink));
 if aPosition>=Configuration.fMaximumSequenceLength then begin
  KVLen:=Configuration.fMaximumSequenceLength;
 end else begin
  KVLen:=aPosition+1;
 end;

{if (Configuration.fSWAType<>TPasLLMSWAType.None) and (AttentionType=TPasLLMAttentionType.SlidingWindow) and (KVLen>SWAWindow) then begin
  TPasLLMModelInferenceInstance.AdvanceSWAKVSink(KVSink,KVLen,SWAWindow,Configuration.fMaximumSequenceLength);
 end;//}

 // Copy the token embedding into the activation buffer
 Move(Weights.fTokenEmbeddingTable^[aToken*Dim],x^,Dim*SizeOf(TPasLLMFloat));

 // Forward all the layers
 for LayerIndex:=0 to Configuration.fCountLayers-1 do begin

  // Decide attention mode for this layer
  if (LayerIndex>=0) and (LayerIndex<Length(Configuration.fAttentionTypes)) then begin
   AttentionType:=Configuration.fAttentionTypes[LayerIndex];
  end else begin
   AttentionType:=TPasLLMAttentionType.Full;
  end;

  // Compute SWA window and contiguous slice [KVStartContig .. KVStartContig+EffectiveKVLen)
  if (AttentionType=TPasLLMAttentionType.SlidingWindow) and (Configuration.fSWAType<>TPasLLMSWAType.None) then begin
  
   if LayerIndex<Length(Configuration.fSlidingWindowSizes) then begin
    SWAWindow:=Configuration.fSlidingWindowSizes[LayerIndex];
   end else begin
    SWAWindow:=Configuration.fMaximumSequenceLength;
   end;
   if SWAWindow<1 then begin
    SWAWindow:=1; // safety
   end;

   // Note: p1 is the logical query position (last index in current KV prefix)
   P1Index:=KVLen-1;

   case Configuration.fSWAType of

    // STANDARD: last W tokens (mask if p1 - p0 >= W)
    TPasLLMSWAType.Standard:begin
     if KVLen>SWAWindow then begin
      KVStartContig:=KVLen-SWAWindow;
      EffectiveKVLen:=SWAWindow;
     end else begin
      KVStartContig:=0;
      EffectiveKVLen:=KVLen;
     end;
    end;

    // CHUNKED: current non-overlapping chunk of size C
    TPasLLMSWAType.Chunked:begin
     SWAChunkSizeLocal:=Configuration.fSWAChunkSize;
     if SWAChunkSizeLocal<=0 then begin
      SWAChunkSizeLocal:=SWAWindow; // fallback to window size
     end;
     if SWAChunkSizeLocal<1 then begin
      SWAChunkSizeLocal:=1; // safety
     end;
     ChunkStartLocal:=(P1Index div SWAChunkSizeLocal)*SWAChunkSizeLocal;
     KVStartContig:=ChunkStartLocal;
     EffectiveKVLen:=Min(SWAChunkSizeLocal,KVLen-KVStartContig);
    end;

    // SYMMETRIC: allow keys with |p1 - p0| <= floor(W/2)
    // => slice is [p1-half .. p1+half] intersected with [0 .. KVLen-1]
    TPasLLMSWAType.Symmetric:begin
     HalfWindow:=SWAWindow shr 1; // floor(W/2)
     LeftIndex:=P1Index-HalfWindow;
     RightIndex:=P1Index+HalfWindow;

     if LeftIndex<0 then begin
      LeftIndex:=0;
     end;
     if RightIndex>(KVLen-1) then begin
      RightIndex:=KVLen-1;
     end;

     if RightIndex>=LeftIndex then begin
      KVStartContig:=LeftIndex;
      EffectiveKVLen:=(RightIndex-LeftIndex)+1;
     end else begin
      // Empty (should not happen), fall back to single element at p1
      KVStartContig:=P1Index;
      EffectiveKVLen:=1;
     end;
    end;

    else begin
     // NONE already filtered above; keep full
     KVStartContig:=0;
     EffectiveKVLen:=KVLen;
    end;

   end;

  end else begin

   // Full or None
   KVStartContig:=0;
   EffectiveKVLen:=KVLen;

  end;

  // Apply RMSNorm to the residual branch
{ CheckNaNs(x,Dim);
  CheckNaNs(Pointer(@Weights.fRMSAttentionWeights[LayerIndex]^[0]),Dim);}
  RMSNorm(@fRunState.fXB[0],x,Pointer(@Weights.fRMSAttentionWeights[LayerIndex]^[0]),Dim,Configuration.fNormalizationEpsilon);
//CheckNaNs(@fRunState.fXB[0],Dim);

  // key and ExpertWeight point to the kv cache
  LayerOffset:=LayerIndex*Configuration.fMaximumSequenceLength*KVDim; // Calculate the layer offset for the kv cache
  KeyCacheBase:=@fRunState.fKeyCache[LayerOffset]; // Get the key cache base pointer
  ValueCacheBase:=@fRunState.fValueCache[LayerOffset]; // Get the ExpertWeight cache base pointer

  // Get the row pointers for query, key, and ExpertWeight
  QueryRow:=Pointer(@fRunState.fQ[0]); // Get the query row pointer
  KeyCacheRow:=@KeyCacheBase^[KVPosition*KVDim]; // Get the key cache row pointer
  ValueCacheRow:=@ValueCacheBase^[KVPosition*KVDim]; // Get the ExpertWeight cache row pointer

  // Perform QKV matmuls for this position
  fRunState.fXQ.Quantize(@fRunState.fXB[0],Dim); // Quantize the residual branch

  if assigned(fPasLLM.fPasMPInstance) then begin
   fParallelQKVData.Counter:=0;
   fParallelQKVData.RunState:=fRunState; // Set the run state for the parallel QKV data
   fParallelQKVData.Weights:=fModel.fWeights; // Get the weights for the model
   fParallelQKVData.QKVClip:=Configuration.fQKVClip; // Set the clipping ExpertWeight for Q/K/V tensors
   fParallelQKVData.Dim:=Dim; // Set the dimension for the parallel QKV data
   fParallelQKVData.QDim:=QDim; // Set the dimension for the parallel QKV data
   fParallelQKVData.KVDim:=KVDim; // Set the key/value dimension for the parallel
   fParallelQKVData.LayerIndex:=LayerIndex; // Set the layer index for the parallel
   fParallelQKVData.QueryRow:=QueryRow; // Set the query row for the parallel
   fParallelQKVData.KeyCacheRow:=KeyCacheRow; // Set the key cache row for the parallel
   fParallelQKVData.ValueCacheRow:=ValueCacheRow; // Set the ExpertWeight cache row for the parallel
   if assigned(fJobManager) then begin
    begin
     fJobManager.Execute(ParallelMatMulQKVFunction,@fParallelQKVData);
    end;
    if ((length(Weights.fWQBias)>0) and assigned(Weights.fWQBias[LayerIndex])) or
       ((length(Weights.fWKBias)>0) and assigned(Weights.fWKBias[LayerIndex])) or
       ((length(Weights.fWVBias)>0) and assigned(Weights.fWVBias[LayerIndex])) or
       not (IsInfinite(Configuration.fQKVClip) or IsZero(Configuration.fQKVClip)) then begin
     fParallelQKVData.Counter:=0;
     fJobManager.Execute(ParallelPostQKVFunction,@fParallelQKVData);
    end;
   end else begin
    fPasLLM.fPasMPInstance.Invoke(
     [
      fPasLLM.fPasMPInstance.Acquire(MatMulQParallelMethod,@fParallelQKVData),
      fPasLLM.fPasMPInstance.Acquire(MatMulKParallelMethod,@fParallelQKVData),
      fPasLLM.fPasMPInstance.Acquire(MatMulVParallelMethod,@fParallelQKVData)
     ]
    );
   end;
  end else begin
   MatMul(QueryRow,fRunState.fXQ,Weights.fWQ[LayerIndex],Dim,QDim); // Query matrix multiplication
   MatMul(KeyCacheRow,fRunState.fXQ,Weights.fWK[LayerIndex],Dim,KVDim); // Key matrix multiplication
   MatMul(ValueCacheRow,fRunState.fXQ,Weights.fWV[LayerIndex],Dim,KVDim); // ExpertWeight matrix multiplication
   if (length(Weights.fWQBias)>0) and assigned(Weights.fWQBias[LayerIndex]) then begin
    AddFloats(Pointer(QueryRow),Pointer(@Weights.fWQBias[LayerIndex]^[0]),QDim);
   end;
   if (length(Weights.fWKBias)>0) and assigned(Weights.fWKBias[LayerIndex]) then begin
    AddFloats(Pointer(KeyCacheRow),Pointer(@Weights.fWKBias[LayerIndex]^[0]),KVDim);
   end;
   if (length(Weights.fWVBias)>0) and assigned(Weights.fWVBias[LayerIndex]) then begin
    AddFloats(Pointer(ValueCacheRow),Pointer(@Weights.fWVBias[LayerIndex]^[0]),KVDim);
   end;
   if not (IsInfinite(Configuration.fQKVClip) or IsZero(Configuration.fQKVClip)) then begin
    ClipFloats(QueryRow,Dim,Configuration.fQKVClip);
    ClipFloats(KeyCacheRow,KVDim,Configuration.fQKVClip);
    ClipFloats(ValueCacheRow,KVDim,Configuration.fQKVClip);
   end;
  end;

  if (length(Configuration.fPositionalEncodings)>0) and (LayerIndex<length(Configuration.fPositionalEncodings)) then begin
   PositionalEncoding:=Configuration.fPositionalEncodings[LayerIndex];
  end else begin
   PositionalEncoding:=Configuration.fPositionalEncoding;
  end;

  case PositionalEncoding of

   TPasLLMPositionalEncoding.RoPE:begin

    if not RoPECacheInitialized then begin

     RoPECacheInitialized:=true;

     CachedRoPEPrepare(@fRunState.fRoPECache[0],HeadDim,aPosition,Configuration.fRoPETheta,RotaryDim);

     if KVSink>0 then begin
      CachedRoPEPrepare(@fRunState.fStreamingLLMRoPECache[0],HeadDim,1,Configuration.fRoPETheta,RotaryDim);
     end;

    end;

    // Apply RoPE relative positional encoding: complex-valued rotate q and k in each head
    begin

     if assigned(fPasLLM.fPasMPInstance) then begin

      fParallelRoPEData.Counter:=0;
      fParallelRoPEData.QueryRow:=QueryRow; // Set the query row for the parallel RoPE data
      fParallelRoPEData.KeyCacheRow:=KeyCacheRow; // Set the key cache row for the parallel RoPE data
      fParallelRoPEData.LayerIndex:=LayerIndex; // Set the layer index for the parallel RoPE data
      fParallelRoPEData.HeadDim:=HeadDim; // Set the head dimension for the parallel RoPE data
      fParallelRoPEData.RotaryDim:=RotaryDim; // Set the rotary dimension for the parallel RoPE data

      if assigned(fJobManager) then begin
       fJobManager.Execute(ParallelRoPEFunction,@fParallelRoPEData);
      end else begin
       fPasLLM.fPasMPInstance.Invoke(
        [
         fPasLLM.fPasMPInstance.ParallelFor(
          @fParallelRoPEData,
          0,
          Configuration.fCountQueryHeads-1,
          RoPEQParallelForMethod,
          Min(Max(Configuration.fCountQueryHeads div Max(fPasLLM.fPasMPInstance.CountJobWorkerThreads,1),1),256),
          PasMPDefaultDepth
         ),
         fPasLLM.fPasMPInstance.ParallelFor(
          @fParallelRoPEData,
          0,
          Configuration.fCountKeyValueHeads-1,
          RoPEKParallelForMethod,
          Min(Max(Configuration.fCountKeyValueHeads div Max(fPasLLM.fPasMPInstance.CountJobWorkerThreads,1),1),256),
          PasMPDefaultDepth
         )
        ]
       );
      end;

     end else begin

      for HeadIndex:=0 to Configuration.fCountQueryHeads-1 do begin
       if Configuration.fQKNormalization then begin
        RMSNormNoWeights(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],HeadDim,Configuration.fNormalizationEpsilon);
       end;
       if Configuration.fQKRMSNormalization then begin
        RMSNorm(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSQNormalizationWeights[LayerIndex]^[0]),HeadDim,Configuration.fNormalizationEpsilon);
       end;
       CachedRoPESingleHead(@QueryRow^[HeadIndex*HeadDim],@fRunState.fRoPECache[0],HeadDim,RotaryDim,Configuration.fQKRoPENonInterleaved); // Apply RoPE to the query vector
      end;

      for HeadIndex:=0 to Configuration.fCountKeyValueHeads-1 do begin
       if Configuration.fQKNormalization then begin
        RMSNormNoWeights(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],HeadDim,Configuration.fNormalizationEpsilon);
       end;
       if Configuration.fQKRMSNormalization then begin
        RMSNorm(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSKNormalizationWeights[LayerIndex]^[0]),HeadDim,Configuration.fNormalizationEpsilon);
       end;
       CachedRoPESingleHead(@KeyCacheRow^[HeadIndex*HeadDim],@fRunState.fRoPECache[0],HeadDim,RotaryDim,Configuration.fQKRoPENonInterleaved); // Apply RoPE to the key vector
      end;

     end;

    end;

    // Rotate sink tokens forward to keep pace with non-sink tokens (StreamingLLM)
    if KVSink>0 then begin

     if assigned(fPasLLM.fPasMPInstance) then begin

      fParallelStreamingLLMRoPEData.Counter:=0;
      fParallelStreamingLLMRoPEData.KeyCacheBase:=KeyCacheBase; // Set the key cache base for the parallel RoPE data
      fParallelStreamingLLMRoPEData.HeadDim:=HeadDim; // Set the head dimension for the parallel RoPE data
      fParallelStreamingLLMRoPEData.RotaryDim:=RotaryDim; // Set the rotary dimension for the parallel RoPE data
      fParallelStreamingLLMRoPEData.KVDim:=KVDim; // Set the key/value dimension for the parallel
      fParallelStreamingLLMRoPEData.KVSink:=KVSink; // Set the KVSink for the parallel RoPE data

      if assigned(fJobManager) then begin
       fJobManager.Execute(ParallelStreamingLLMRoPEFunction,@fParallelStreamingLLMRoPEData);
      end else begin
       fPasLLM.fPasMPInstance.Invoke(
        fPasLLM.fPasMPInstance.ParallelFor(
         @fParallelStreamingLLMRoPEData,
         0,
         (KVSink*Configuration.fCountKeyValueHeads)-1,
         StreamingLLMRoPEParallelForMethod,
         Min(Max((KVDim*KVSink) div Max(fPasLLM.fPasMPInstance.CountJobWorkerThreads,1),16),256),
         PasMPDefaultDepth
        )
       );
      end;

     end else begin

      for RotationIndex:=0 to KVSink-1 do begin
       CachedRoPEMultiHeads(Pointer(@KeyCacheBase^[RotationIndex*KVDim]),@fRunState.fStreamingLLMRoPECache[0],Configuration.fCountKeyValueHeads,HeadDim,RotaryDim,Configuration.fRoPENonInterleaved);
      end;

     end;

    end;

   end;

   TPasLLMPositionalEncoding.NoPE:begin

    // No positional encoding

    if Configuration.fQKNormalization then begin

     for HeadIndex:=0 to Configuration.fCountQueryHeads-1 do begin
      RMSNormNoWeights(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],HeadDim,Configuration.fNormalizationEpsilon);
     end;
//   RMSNormNoWeights(QueryRow,QueryRow,QDim,Configuration.fNormalizationEpsilon);

     for HeadIndex:=0 to Configuration.fCountKeyValueHeads-1 do begin
      RMSNormNoWeights(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],HeadDim,Configuration.fNormalizationEpsilon);
     end;
//   RMSNormNoWeights(KeyCacheRow,KeyCacheRow,KVDim,Configuration.fNormalizationEpsilon);

    end;

    if Configuration.fQKRMSNormalization then begin

     for HeadIndex:=0 to Configuration.fCountQueryHeads-1 do begin
      RMSNorm(@QueryRow^[HeadIndex*HeadDim],@QueryRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSQNormalizationWeights[LayerIndex]^[0]),HeadDim,Configuration.fNormalizationEpsilon);
     end;
//   RMSNorm(QueryRow,QueryRow,Pointer(@Weights.fRMSQNormalizationWeights[LayerIndex]^[0]),QDim,Configuration.fNormalizationEpsilon);

     for HeadIndex:=0 to Configuration.fCountKeyValueHeads-1 do begin
      RMSNorm(@KeyCacheRow^[HeadIndex*HeadDim],@KeyCacheRow^[HeadIndex*HeadDim],Pointer(@Weights.fRMSKNormalizationWeights[LayerIndex]^[0]),HeadDim,Configuration.fNormalizationEpsilon);
     end;
//   RMSNorm(KeyCacheRow,KeyCacheRow,Pointer(@Weights.fRMSKNormalizationWeights[LayerIndex]^[0]),KVDim,Configuration.fNormalizationEpsilon);

    end;

   end;

  end; 

  if not SameValue(QueryPreAttnScale,1.0) then begin
   // Apply the query pre-attention scaling if needed
   for QIndex:=0 to QDim-1 do begin
    //QueryRow^[QIndex]:=QueryRow^[QIndex]*QueryPreAttnScale;
    fRunState.fQ[QIndex]:=fRunState.fQ[QIndex]*QueryPreAttnScale;
   end;
  end;

  if AttentionType=TPasLLMAttentionType.None then begin

   // Make the residual path a no-op for the attention block
   FillChar(fRunState.fXB[0],QDim*SizeOf(TPasLLMFloat),#0);

  end else begin

   SWAChunkSizeLocal:=Configuration.fSWAChunkSize;
   if SWAChunkSizeLocal<=0 then begin
    SWAChunkSizeLocal:=SWAWindow; // fallback
   end;

   // Multihead attention. Iterate over all heads
   if (Configuration.fCountQueryHeads>1) and assigned(fPasLLM.fPasMPInstance) then begin
    // Prepare the parallel attention data for the parallel for loop
    fParallelAttentionData.Counter:=0;
    fParallelAttentionData.XOut:=@fRunState.fXB[0]; // Output buffer for the attention
    fParallelAttentionData.AttH:=@fRunState.fAtt[0]; // Attention scores buffer
    fParallelAttentionData.QH:=@fRunState.fQ[0]; // Query vector buffer
    if AttentionType=TPasLLMAttentionType.SlidingWindow then begin
     fParallelAttentionData.KH:=@KeyCacheBase^[KVStartContig*KVDim]; // Key vector buffer
     fParallelAttentionData.VH:=@ValueCacheBase^[KVStartContig*KVDim]; // ExpertWeight vector buffer
     fParallelAttentionData.KVLen:=EffectiveKVLen; // key/value length
     fParallelAttentionData.SWAType:=Configuration.fSWAType;
     fParallelAttentionData.IsSliding:=true;
     fParallelAttentionData.ChunkLen:=SWAChunkSizeLocal;     
    end else begin
     fParallelAttentionData.KH:=@KeyCacheBase^[0]; // Key vector buffer
     fParallelAttentionData.VH:=@ValueCacheBase^[0]; // ExpertWeight vector buffer
     fParallelAttentionData.KVLen:=KVLen; // key/value length
     fParallelAttentionData.SWAType:=Configuration.fSWAType;
     fParallelAttentionData.IsSliding:=false;
     fParallelAttentionData.ChunkLen:=0;     
    end;
    fParallelAttentionData.HeadDim:=HeadDim; // Head dimension
    fParallelAttentionData.KVMul:=KVMul; // key/value mul
    fParallelAttentionData.KVDim:=KVDim; // key/value dimension
    if assigned(fJobManager) then begin
     fJobManager.Execute(ParallelAttentionFunction,@fParallelAttentionData);
    end else begin
     fPasLLM.fPasMPInstance.Invoke(
      fPasLLM.fPasMPInstance.ParallelFor(
       @fParallelAttentionData,
       0,
       Configuration.fCountQueryHeads-1,
       AttentionParallelForMethod,
       Min(Max(Configuration.fCountQueryHeads div Max(fPasLLM.fPasMPInstance.CountJobWorkerThreads,1),1),128),
       PasMPDefaultDepth
      )
     );
    end;
   end else begin
    if AttentionType=TPasLLMAttentionType.SlidingWindow then begin
     for HeadIndex:=0 to Configuration.fCountQueryHeads-1 do begin
      AttentionDispatch(Pointer(@fRunState.fXB[HeadIndex*HeadDim]), // Output buffer for this head
                        Pointer(@fRunState.fAtt[HeadIndex*Configuration.fMaximumSequenceLength]), // Attention scores for this head
                        Pointer(@fRunState.fQ[HeadIndex*HeadDim]), // Query vector for this head
                        Pointer(@KeyCacheBase^[(KVStartContig*KVDim)+((HeadIndex div KVMul)*HeadDim)]), // Get the key vector for this head
                        Pointer(@ValueCacheBase^[(KVStartContig*KVDim)+((HeadIndex div KVMul)*HeadDim)]), // Get the ExpertWeight vector for this head
                        HeadDim,
                        KVDim,
                        EffectiveKVLen,
                        Configuration.fSWAType,
                        true,                  // is sliding
                        SWAChunkSizeLocal,
                        Configuration.fAttnLogitSoftcapping);
     end;
    end else begin
     for HeadIndex:=0 to Configuration.fCountQueryHeads-1 do begin
      AttentionDispatch(Pointer(@fRunState.fXB[HeadIndex*HeadDim]), // Output buffer for this head
                        Pointer(@fRunState.fAtt[HeadIndex*Configuration.fMaximumSequenceLength]), // Attention scores for this head
                        Pointer(@fRunState.fQ[HeadIndex*HeadDim]), // Query vector for this head
                        Pointer(@KeyCacheBase^[(HeadIndex div KVMul)*HeadDim]), // Get the key vector for this head
                        Pointer(@ValueCacheBase^[(HeadIndex div KVMul)*HeadDim]), // Get the ExpertWeight vector for this head
                        HeadDim,
                        KVDim,
                        KVLen,
                        Configuration.fSWAType,
                        true,                  // is sliding
                        SWAChunkSizeLocal,
                        Configuration.fAttnLogitSoftcapping);
     end;
    end;
   end;

  end;

  // Final MatMul to get the output of the attention
  fRunState.fXQ.Quantize(@fRunState.fXB[0],QDim); // Quantize the residual branch
  MatMul(@fRunState.fXB2[0],fRunState.fXQ,Weights.fWO[LayerIndex],QDim,Dim); // Output matrix multiplication

  if Configuration.NormalizationType<>TPasLLMNormalizationType.LayerNormPar then begin

   if (LayerIndex<length(Weights.fRMSPreFeedForwardLayerNormWeights)) and assigned(Weights.fRMSPreFeedForwardLayerNormWeights[LayerIndex]) then begin

    RMSNorm(@fRunState.fXB[0],@fRunState.fXB2[0],Pointer(@Weights.fRMSLayerNormalizationWeights[LayerIndex]^[0]),Dim,Configuration.fNormalizationEpsilon);

    // Residual connection back into x
    // Add the output of the attention to the activation buffer
    AddFloats(Pointer(x),Pointer(@fRunState.fXB[0]),Dim);

    RMSNorm(@fRunState.fXB[0],x,Pointer(@Weights.fRMSPreFeedForwardLayerNormWeights[LayerIndex]^[0]),Dim,Configuration.fNormalizationEpsilon);

   end else begin

    // Residual connection back into x
    // Add the output of the attention to the activation buffer
    AddFloats(Pointer(x),Pointer(@fRunState.fXB2[0]),Dim);

    RMSNorm(@fRunState.fXB[0],x,Pointer(@Weights.fRMSLayerNormalizationWeights[LayerIndex]^[0]),Dim,Configuration.fNormalizationEpsilon);

   end;

  end else begin

   // Residual connection back into x
   // Add the output of the attention to the activation buffer
   AddFloats(Pointer(x),Pointer(@fRunState.fXB2[0]),Dim);

  end;

  fRunState.fXQ.Quantize(@fRunState.fXB[0],Dim); // Quantize the residual branch

  // Mixture of Experts gate
  if (Configuration.fCountExperts>1) and (Configuration.fCountActiveExperts>0) and (length(Weights.fMixtureOfExpertGate)>0) then begin

   // If there are multiple experts, we need to calculate the mixture of experts gate

   // First do a matrix multiplication to get the gate values
   MatMul(@fRunState.fEB[0],fRunState.fXQ,Weights.fMixtureOfExpertGate[LayerIndex],Dim,Configuration.fCountExperts);

   // Then apply the actual logic for gating the experts
   // This will select the top-k experts based on the gate values and calculate the weights for each expert
   MixtureOfExpertGate;

   // Set count of active experts to the number of experts that are actually active
   CountActiveExperts:=Configuration.fCountActiveExperts;

  end else begin

   // If there is only no or better one expert, we can skip the gate calculation and use the first "expert" directly

   // Set the first expert as the only active expert with full-weight 1.0 and index 0, since there is no gating
   fRunState.fMixtureOfExpertWeights[0]:=1.0;
   fRunState.fMixtureOfExpertWeightIndices[0]:=0;

   // Only one "expert" is active, so we set the count of active experts to 1
   CountActiveExperts:=1;

  end;

  // Now we have the mixture of experts weights and indices set up, we can proceed with the feed-forward neural network
  // This will apply the feed-forward neural network to each active expert

  // Check if we have multiple active experts and if parallelization is enabled
  if assigned(fPasLLM.fPasMPInstance) and (CountActiveExperts>1) and (fRunState.fCountExpertBuffers>1) and not assigned(fJobManager) then begin

   // If parallelization is enabled and we have multiple active experts, then we can use the parallel for method to process
   // all active experts in parallel

   fParallelFeedForwardNeuralNetworkForwardData.LayerIndex:=LayerIndex;

   // Process the feed-forward neural network forward method in parallel for each active expert
   fPasLLM.fPasMPInstance.Invoke(
    fPasLLM.fPasMPInstance.ParallelFor(
     @fParallelFeedForwardNeuralNetworkForwardData,
     0,
     CountActiveExperts-1,
     FeedForwardNeuralNetworkForwardParallelForMethod,
     1,
     PasMPDefaultDepth
    )
   );

   // Residual connection, sequentially as writing to the same destination buffer, as atomic floating point operations are not
   // supported on CPUs in the most cases
   for ActiveExpertIndex:=0 to CountActiveExperts-1 do begin
    ExpertWeight:=fRunState.fMixtureOfExpertWeights[ActiveExpertIndex];
    if abs(ExpertWeight)>0.0 then begin
     if (LayerIndex<length(Weights.fRMSPostFeedForwardLayerNormWeights)) and assigned(Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]) then begin
{     CheckNaNs(@fRunState.fHB3[ActiveExpertIndex][0],Dim);
      CheckNaNs(Pointer(@Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]^[0]),Dim);}
      RMSNorm(@fRunState.fXB[0],@fRunState.fHB3[ActiveExpertIndex][0],Pointer(@Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]^[0]),Dim,Configuration.fNormalizationEpsilon);
//    CheckNaNs(@fRunState.fXB[0],Dim);
      AddFloatsWithFactor(Pointer(x),Pointer(@fRunState.fXB[0]),Dim,ExpertWeight);
     end else begin
//    CheckNaNs(@fRunState.fHB3[ActiveExpertIndex][0],Dim);
      AddFloatsWithFactor(Pointer(x),Pointer(@fRunState.fHB3[ActiveExpertIndex][0]),Dim,ExpertWeight);
     end;
    end;
   end;

  end else begin

   // Otherwise if parallelization is not enabled or only one expert is active, we can process each expert sequentially

   for ActiveExpertIndex:=0 to CountActiveExperts-1 do begin

    ExpertWeight:=fRunState.fMixtureOfExpertWeights[ActiveExpertIndex];
    if abs(ExpertWeight)>0.0 then begin

     FeedForwardNeuralNetworkForward(LayerIndex,ActiveExpertIndex);

     if (LayerIndex<length(Weights.fRMSPostFeedForwardLayerNormWeights)) and assigned(Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]) then begin

{     CheckNaNs(Pointer(@fRunState.fHB3[IfThen(fRunState.fCountExpertBuffers>1,
                                                         ActiveExpertIndex,
                                                         0)][0]),Dim);
      CheckNaNs(Pointer(@Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]^[0]),Dim);}

      RMSNorm(@fRunState.fXB[0],
              @fRunState.fHB3[IfThen(fRunState.fCountExpertBuffers>1,
                                     ActiveExpertIndex,
                                     0)][0],
              Pointer(@Weights.fRMSPostFeedForwardLayerNormWeights[LayerIndex]^[0]),
              Dim,
              Configuration.fNormalizationEpsilon
             );

//    CheckNaNs(@fRunState.fXB[0],Dim);

      // Residual connection
      AddFloatsWithFactor(Pointer(x),
                          Pointer(@fRunState.fXB[0]),
                          Dim,
                          ExpertWeight);

     end else begin

{     CheckNaNs(Pointer(@fRunState.fHB3[IfThen(fRunState.fCountExpertBuffers>1,
                                                         ActiveExpertIndex,
                                                         0)][0]),Dim);}

      // Residual connection
      AddFloatsWithFactor(Pointer(x),
                          Pointer(@fRunState.fHB3[IfThen(fRunState.fCountExpertBuffers>1,
                                                         ActiveExpertIndex,
                                                         0)][0]),
                          Dim,
                          ExpertWeight);

     end;

    end;

   end;

  end;

 end;

if aUpdateKVOnly then begin
  result:=nil;
  exit;
 end;

 // Final RMSNorm
 RMSNorm(x,x,Pointer(@Weights.fRMSFinalWeights^[0]),Dim,Configuration.fNormalizationEpsilon); // Apply RMSNorm to the activation buffer

 // Classifier into logits
 fRunState.fXQ.Quantize(x,Dim); // Quantize the activation buffer
 MatMul(@fRunState.fLogits[0],fRunState.fXQ,Weights.fWCLS,Dim,Configuration.fVocabularySize); // Classifier matrix multiplication

 if Configuration.fFinalLogitSoftcapping>0.0 then begin
  for Index:=0 to Dim-1 do begin
   fRunState.fLogits[Index]:=Tanh(fRunState.fLogits[Index]/Configuration.fFinalLogitSoftcapping)*Configuration.fFinalLogitSoftcapping;
  end;
 end;

 result:=@fRunState.fLogits[0]; // Return the logits pointer

end;

function TPasLLMModelInferenceInstance.DefaultOnInput(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
begin
 Write(aPrompt);
 ReadLn(result);
end;

procedure TPasLLMModelInferenceInstance.DefaultOnOutput(const aModelInferenceInstance:TPasLLMModelInferenceInstance;const aOutput:TPasLLMUTF8String);
begin
 Write(aOutput);
end;

procedure TPasLLMModelInferenceInstance.Generate(const aPrompt:TPasLLMUTF8String;const aSteps:TPasLLMInt32=0);
var PromptTokens:TPasLLMInt32DynamicArray;
    CountPromptTokens:TPasLLMSizeInt;
    Token,Next,Position,Steps:TPasLLMInt32;
    StartTime,
    PromptAccumulatedTime,PromptAccumulatedTokens,
    OutputAccumulatedTime,OutputAccumulatedTokens:TPasLLMUInt64; // Variables for performance measurement
    Previous,Output:TPasLLMUTF8String;
    LastSamplerOutput:Boolean;
begin

 if aSteps<=0 then begin
  Steps:=fSteps; // Use the configured number of steps if not specified
 end else begin
  Steps:=aSteps;
 end;

 // Encode the prompt into tokens
 CountPromptTokens:=0; // Initialize the token count to 0
 PromptTokens:=nil;
 try

  LastSamplerOutput:=false;

  fModel.fTokenizer.Encode(aPrompt,true,false,PromptTokens,CountPromptTokens); // Encode the prompt with BOS token

  if CountPromptTokens<1 then begin
   raise EPasLLM.Create('Expected at least one token in the prompt'); // Raise an error if no tokens were generated
  end;

  Position:=0; // Initialize the position in the sequence to 0

  Token:=PromptTokens[Position]; // Get the first token from the encoded prompt

  PromptAccumulatedTime:=0; // Initialize accumulated time for prompt performance measurement
  PromptAccumulatedTokens:=0; // Initialize accumulated tokens for prompt performance measurement
  OutputAccumulatedTime:=0; // Initialize accumulated time for output performance measurement
  OutputAccumulatedTokens:=0; // Initialize accumulated tokens for output performance measurement

  Previous:='';

  fSamplerPenalties.Reset;

  while (aSteps<0) or (Steps<=0) or (Position<Steps) do begin

   StartTime:=GetCurrentTime; // Start the timer for performance measurement

   // Forward the model to get logits for the next token
   Forward(Token,Position,(Position+1)<CountPromptTokens); // Process the current token at the current position

   // Advance the state machine to get the next token
   if (Position+1)<CountPromptTokens then begin
    Next:=PromptTokens[Position+1]; // If still processing the prompt, use the next prompt token
    fSamplerPenalties.Accept(Next); // Accept the next token into the sampler penalties
    inc(PromptAccumulatedTime,GetCurrentTime-StartTime); // Accumulate the time taken for processing the current token
    inc(PromptAccumulatedTokens); // Increment the count of processed tokens
    LastSamplerOutput:=false;
   end else begin
    if not LastSamplerOutput then begin
     fSamplerPenalties.Reset;
     LastSamplerOutput:=true;
    end;

    fSamplerPenalties.Apply(@fRunState.fLogits[0]); // Apply penalties to the logits based on the sampler penalties
    Next:=fSampler.Sample(@fRunState.fLogits[0]); // Sample the next token from the logits using the sampler
    fSamplerPenalties.Accept(Next); // Accept the sampled token into the sampler penalties
    inc(OutputAccumulatedTime,GetCurrentTime-StartTime); // Accumulate the time taken for processing the current token
    inc(OutputAccumulatedTokens); // Increment the count of output tokens
   end;

   inc(Position); // Increment the position in the sequence

   // Check for BOS token (1) which delimits sequences and stops generation
   if Next=1 then begin
    break;
   end;

   Output:=fModel.fTokenizer.SafeString(fModel.fTokenizer.Decode(Previous,Token,Next)); // Decode the current and next token into a string and ensure it's safe for output

   Previous:=Copy(Previous+Output,1,64); // Update previous buffer

   Token:=Next; // Update the current token to the next token

   if (length(Output)>0) and assigned(fOnOutput) then begin
    fOnOutput(self,Output); // Call the output handler with the decoded string
   end;

   if assigned(fOnCheckTerminated) and fOnCheckTerminated(self) then begin
    break; // If the termination condition is met, exit the loop
   end;

   if assigned(fOnCheckAbort) and fOnCheckAbort(self) then begin
    break; // If the abort condition is met, exit the loop
   end;

  end;

  Output:=''; // Clear output string after generation

  if Position>1 then begin

   Str((PromptAccumulatedTokens/(PromptAccumulatedTime*1e-6)):0:2,Output); // Format the achieved tokens per second
   fOnOutput(self,'Achieved prompt tokens per second: '+Output+#10); // Print achieved tokens per second

   Str((OutputAccumulatedTokens/(OutputAccumulatedTime*1e-6)):0:2,Output); // Format the achieved tokens per second
   fOnOutput(self,'Achieved output tokens per second: '+Output+#10); // Print achieved tokens per second

   Str(((PromptAccumulatedTokens+OutputAccumulatedTokens)/(Max(1,(PromptAccumulatedTime+OutputAccumulatedTime)*1e-6))):0:2,Output); // Format the total achieved tokens per second
   fOnOutput(self,'Achieved total tokens per second: '+Output+#10); // Print total achieved tokens per second

  end;

 finally
  PromptTokens:=nil; // Free the memory allocated for the tokens array
 end;

end;

function TPasLLMModelInferenceInstance.Chat(const aPrompt:TPasLLMUTF8String;const aSteps:TPasLLMInt32;const aSystemPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
var ChatSession:TChatSession;
begin
 fChatInput:=aPrompt;
 fChatOutput:='';
 ChatSession:=TChatSession.Create(self);
 try
  ChatSession.OnInput:=ChatOnInput;
  ChatSession.OnOutput:=ChatOnOutput;
  ChatSession.OnSideTurn:=ChatOnSideTurn;
  ChatSession.SystemPrompt:=aSystemPrompt;
  ChatSession.Run(aSteps);
 finally
  FreeAndNil(ChatSession);
 end;
 if assigned(fOnOutput) then begin
  fOnOutput(self,fChatOutput);
 end;
 result:=fChatOutput;
end;

procedure TPasLLMModelInferenceInstance.Study(const aPath:TPasLLMUTF8String;const aSteps:TPasLLMInt32=0);
const MaxInputSize=64*1024; // Maximum input size for the study
var Input:TPasLLMUTF8String;
    Tokens:TPasLLMInt32DynamicArray;
    CountTokens,MaxTokens:TPasLLMSizeInt;
    StartTime,MidTime,EndTime:TPasLLMUInt64; // Variables for performance measurement
    LogProb,Sum,SquaredSum,Den,Perplexity,PerplexityError:TPasLLMFloat;
    Index,Position:TPasLLMInt32;
    Logits:PPasLLMFloatArray; // Pointer to the logits array returned by the model
    Stream:TMemoryStream;
begin

 Tokens:=nil;
 try

  MaxTokens:=MaxInputSize+3; // Get the maximum number of tokens for the input size
  SetLength(Tokens,MaxTokens); // Allocate memory for the tokens array

  // Read the input file into a string
  Stream:=TMemoryStream.Create;
  try
   Stream.LoadFromFile(aPath);
   SetLength(Input,Stream.Size);
   Stream.Seek(0,soBeginning);
   if Stream.Size>0 then begin
    Stream.ReadBuffer(Input[1],Stream.Size);
   end;
  finally
   Stream.Free;
  end;

  StartTime:=GetCurrentTime; // Start timing for performance measurement

  CountTokens:=0;
  fModel.fTokenizer.Encode(Input,true,false,Tokens,CountTokens); // Encode the input string into tokens with BOS token

  MidTime:=GetCurrentTime; // Record the time after encoding

  if CountTokens<1 then begin
   raise EPasLLM.Create('Expected at least one token in the input'); // Raise an error if no tokens were generated
  end;

  WriteLn('# ',aPath,': ',CountTokens,' tokens (',((MidTime-StartTime)*1e-6):0:3,' seconds), chunked with size ',aSteps);

  Sum:=0.0;
  SquaredSum:=0.0;
  Den:=0.0;
  Perplexity:=0.0;
  PerplexityError:=0.0;

  Position:=0; // Initialize the position in the sequence to 0

  fSamplerPenalties.Reset;

  for Index:=0 to CountTokens-2 do begin // Iterate over all tokens except the last one

   if assigned(fOnCheckTerminated) and fOnCheckTerminated(self) then begin
    break; // If the termination condition is met, exit the loop
   end;

   if assigned(fOnCheckAbort) and fOnCheckAbort(self) then begin
    break; // If the abort condition is met, exit the loop
   end;

   if (Index<>0) and (Index mod 1000=0) then begin
    WriteLn('# progress (',Index,'/',CountTokens,'): ',Perplexity:0:3,' ± ',PerplexityError:0:3); // Print progress every 1000 tokens
   end;

   if aSteps<=0 then begin
    Position:=Index; // Use the current index as position if steps are not set
   end else begin
    Position:=Index mod aSteps; // Use modulo to wrap around if steps are set
   end;

   Logits:=Forward(Tokens[Index],Position,(Position+1)<CountTokens); // Forward the model to get logits for the next token

   fSamplerPenalties.Apply(Logits); // Apply penalties to the logits based on the sampler penalties

   LogProb:=Ln(fSampler.SampleProbability(Logits,Tokens[Index+1],fModel.fConfiguration.fVocabularySize)); // Sample probability of the next token and take logarithm

   fSamplerPenalties.Accept(Tokens[Index+1]); // Accept the next token into the sampler penalties

   // Update stats for mean/std
   Sum:=Sum+LogProb; // Accumulate the log probability
   SquaredSum:=SquaredSum+sqr(LogProb); // Accumulate the square of the log probability
   Den:=Den+1; // Increment the denominator for mean/std calculation

   // Update perplexity and perplexity error using standard error of the mean
   Perplexity:=Exp(-Sum/Den); // Calculate perplexity as the exponent of the negative mean log probability
   if Den>1 then begin
    PerplexityError:=Perplexity*sqrt((SquaredSum-(sqr(Sum)/Den))/(Den*(Den-1))); // Calculate the standard error of the mean for perplexity
   end else begin
    PerplexityError:=0.0; // If only one token, set perplexity error to 0
   end;

  end;

  // Record the time after processing all tokens
  EndTime:=GetCurrentTime;

  // Print the final perplexity and performance metrics
  WriteLn('# perplexity: ',Perplexity:0:3,' ± ',PerplexityError:0:3,' (',((EndTime-MidTime)*1e-6):0:2,' seconds, ',(CountTokens-1)/((EndTime-MidTime)*1e-6):0:2,' tokens per second)');

 finally
  // Free the memory allocated for the tokens array
  Tokens:=nil;
 end;

end;

procedure TPasLLMModelInferenceInstance.TokenizerEncoderTest(const aString:TPasLLMUTF8String);
var Tokens:TPasLLMInt32DynamicArray;
    CountTokens,Index,Token:TPasLLMSizeInt;
begin

 CountTokens:=0;
 Tokens:=nil; // Initialize the tokens array

 fModel.fTokenizer.Encode(aString,false,false,Tokens,CountTokens); // Encode the input string into tokens with BOS token

 WriteLn('Encoded tokens: ',CountTokens); // Print the number of encoded tokens
 for Index:=0 to CountTokens-1 do begin
  Token:=Tokens[Index];
  if Token>=0 then begin
   if assigned(fOnOutput) then begin
    fOnOutput(self,IntToStr(Token)+' "'+fModel.fTokenizer.fVocab[Token]+'", '); // Print each token and its corresponding string from the vocabulary
   end;
  end;
 end;
 if assigned(fOnOutput) then begin
  fOnOutput(self,#10);
 end;

end;

function TPasLLMModelInferenceInstance.CreateChatSession:TChatSession;
begin
 result:=TChatSession.Create(self);
end;

{ TPasLLMJobManagerWorkerThread }

constructor TPasLLMJobManagerWorkerThread.Create(const aJobManager:TPasLLMJobManager);
begin
 fJobManager:=aJobManager;
 fPasLLM:=fJobManager.fPasLLM;
 inherited Create(false);
end;

destructor TPasLLMJobManagerWorkerThread.Destroy;
begin
 inherited Destroy;
end;

procedure TPasLLMJobManagerWorkerThread.Execute;
var Job:PPasLLMJobManagerJob;
    WakeUpGeneration:TPasMPUInt64;
begin

 Job:=@fJobManager.fJob;

 WakeUpGeneration:=0;

 while not Terminated do begin

  fJobManager.fWakeUpConditionVariableLock.Acquire;
  try
   repeat
    fJobManager.fWakeUpConditionVariable.Wait(fJobManager.fWakeUpConditionVariableLock);
    // Check if it is not a spurious wakeup, which can be happen with condition variables in some cases
    if WakeUpGeneration<>fJobManager.fWakeUpGeneration then begin
     WakeUpGeneration:=fJobManager.fWakeUpGeneration;
     break;
    end;
   until Terminated;
  finally
   fJobManager.fWakeUpConditionVariableLock.Release;
  end;

  fJobManager.fAwareConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Increment(fJobManager.fStartedThreads);
  finally
   fJobManager.fAwareConditionVariableLock.Release;
  end;
  fJobManager.fAwareConditionVariable.Broadcast;

  if assigned(Job) and assigned(Job^.JobMethod) and not Terminated then begin
   Job^.JobMethod(Job.Data);
  end;

  fJobManager.fSleepConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Increment(fJobManager.fStoppedThreads);
  finally
   fJobManager.fSleepConditionVariableLock.Release;
  end;
  fJobManager.fSleepConditionVariable.Broadcast;

 end;

end;

{ TPasLLMJobManager }

constructor TPasLLMJobManager.Create(const aModelInferenceInstance:TPasLLMModelInferenceInstance);
var Index:TPasLLMSizeInt;
    AvailableCPUCores:TPasMPAvailableCPUCores;
begin
 inherited Create;

 fModelInferenceInstance:=aModelInferenceInstance;

 fConfiguration:=fModelInferenceInstance.fModel.fConfiguration;

 fPasLLM:=fModelInferenceInstance.fPasLLM;

 fLock:=TPasMPSlimReaderWriterLock.Create;

 fWakeUpConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fWakeUpConditionVariable:=TPasMPConditionVariable.Create;

 fAwareConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fAwareConditionVariable:=TPasMPConditionVariable.Create;

 fSleepConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fSleepConditionVariable:=TPasMPConditionVariable.Create;

 fWorkerThreads:=nil;

 SetLength(fWorkerThreads,Max(0,TPasMP.GetCountOfHardwareThreads(AvailableCPUCores)-1));

 for Index:=0 to length(fWorkerThreads)-1 do begin
  fWorkerThreads[Index]:=TPasLLMJobManagerWorkerThread.Create(self);
 end;

end;

destructor TPasLLMJobManager.Destroy;
begin

 Shutdown;

 fWorkerThreads:=nil;

 FreeAndNil(fLock);

 FreeAndNil(fSleepConditionVariable);

 FreeAndNil(fSleepConditionVariableLock);

 FreeAndNil(fAwareConditionVariable);

 FreeAndNil(fAwareConditionVariableLock);

 FreeAndNil(fWakeUpConditionVariable);

 FreeAndNil(fWakeUpConditionVariableLock);

 inherited Destroy;

end;

procedure TPasLLMJobManager.Shutdown;
var Index:TPasLLMSizeInt;
begin

 if length(fWorkerThreads)>0 then begin

  for Index:=0 to length(fWorkerThreads)-1 do begin
   fWorkerThreads[Index].Terminate;
  end;

  WakeUpThreads;

  WaitForThreads;

  for Index:=0 to length(fWorkerThreads)-1 do begin
   fWorkerThreads[Index].WaitFor;
   FreeAndNil(fWorkerThreads[Index]);
  end;

  fWorkerThreads:=nil;

 end;

end;

procedure TPasLLMJobManager.Execute(const aJobMethod:TPasLLMJobManagerJobMethod;const aData:Pointer);
begin

 fJob.JobMethod:=aJobMethod;

 fJob.Data:=aData;

 if length(fWorkerThreads)>0 then begin
  WakeUpThreads;
 end;

 if assigned(aJobMethod) then begin
  aJobMethod(aData);
 end;

 if length(fWorkerThreads)>0 then begin
  WaitForThreads;
 end;

end;

procedure TPasLLMJobManager.WakeUpThreads;
begin

 fStartedThreads:=0;
 fStoppedThreads:=0;

 fWakeUpConditionVariableLock.Acquire;
 try
  inc(fWakeUpGeneration);
 finally
  fWakeUpConditionVariableLock.Release;
 end;

 fWakeUpConditionVariable.Broadcast;

 fAwareConditionVariableLock.Acquire;
 try
  while fStartedThreads<length(fWorkerThreads) do begin
   fAwareConditionVariable.Wait(fAwareConditionVariableLock,10);
   if fStartedThreads<length(fWorkerThreads) then begin
    fWakeUpConditionVariable.Broadcast;
   end else begin
    break;
   end;
  end;
 finally
  fAwareConditionVariableLock.Release;
 end;

end;

procedure TPasLLMJobManager.WaitForThreads;
begin
 fSleepConditionVariableLock.Acquire;
 try
  while fStoppedThreads<length(fWorkerThreads) do begin
   fSleepConditionVariable.Wait(fSleepConditionVariableLock,10);
  end;
 finally
  fSleepConditionVariableLock.Release;
 end;
end;

{ TPasLLM }

constructor TPasLLM.Create(const aPasMPInstance:TPasMP);
begin
 inherited Create;
 fPasMPInstance:=aPasMPInstance;
 fRandomState:=$1337c0d3; // Random state for reproducibility
end;

destructor TPasLLM.Destroy;
begin
 inherited Destroy;
end;

function TPasLLM.GetRandomUInt32:TPasLLMUInt32; // Get a random unsigned 32-bit integer
begin
 fRandomState:=fRandomState xor (fRandomState shr 12);
 fRandomState:=fRandomState xor (fRandomState shl 25);
 fRandomState:=fRandomState xor (fRandomState shr 27);
 result:=(fRandomState*TPasLLMUInt64($2545f4914f6cdd1d)) shr 32; // Scale the random state to a 32-bit unsigned integer
end;

function TPasLLM.GetRandomFloat:TPasLLMFloat; // Get a random float in the range [0, 1)
begin
 result:=(GetRandomUInt32 shr 8)/16777216.0; // Scale the random integer to a float in the range [0, 1)
end;

var CPUChecked:TPasMPBool32=false;

{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
type TCPUIDData=record
      case TPasLLMUInt32 of
       0:(
        Data:array[0..3] of TPasLLMUInt32;
       );
       1:(
        EAX,EBX,EDX,ECX:TPasLLMUInt32;
       );
       2:(
        String_:array[0..15] of AnsiChar;
       );
      end;

      PCPUIDData=^TCPUIDData;

procedure GetCPUID(EAXValue,ECXValue:TPasLLMUInt32;Data:PCPUIDData); assembler;
asm
{$if defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
 push rbx
{$if defined(Windows) or defined(Win32) or defined(Win64)}
 // Win64 ABI (rcx, rdx, r8, ...)
 mov eax,ecx
 mov ecx,edx
//mov r8,r8
{$else}
 // SysV x64 ABI (rdi, rsi, rdx ...)
 mov eax,edi
 mov ecx,esi
 mov r8,rdx
{$ifend}
{$else}
 // register (eax, edx, ...)
 push ebx
 push edi
 mov edi,ecx
{$ifend}
 cpuid
{$if defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
 mov dword ptr [r8+0],eax
 mov dword ptr [r8+4],ebx
 mov dword ptr [r8+8],edx
 mov dword ptr [r8+12],ecx
 pop rbx
{$else}
 mov dword ptr [edi+0],eax
 mov dword ptr [edi+4],ebx
 mov dword ptr [edi+8],edx
 mov dword ptr [edi+12],ecx
 pop edi
 pop ebx
{$ifend}
end;
{$ifend}

procedure DoCheckCPU;
{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
var CPUIDData:TCPUIDData;
begin
 PasLLMCPUFeatures:=0;
 begin
  FillChar(CPUIDData,SizeOf(TCPUIDData),#0);
  GetCPUID(0,0,@CPUIDData);
 end;
 begin
  FillChar(CPUIDData,SizeOf(TCPUIDData),#0);
  GetCPUID(1,0,@CPUIDData);
  if (CPUIDData.ECX and (TPasLLMUInt32(1) shl 1))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_PCLMUL_Mask;
  end;
  if (CPUIDData.ECX and (TPasLLMUInt32(1) shl 12))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_FMA3_Mask;
  end;
  if (CPUIDData.ECX and (TPasLLMUInt32(1) shl 20))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_SSE42_Mask;
  end;
  if (CPUIDData.ECX and (TPasLLMUInt32(1) shl 28))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_AVX_Mask;
  end;
  if (CPUIDData.ECX and (TPasLLMUInt32(1) shl 29))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_F16C_Mask;
  end;
 end;
 begin
  FillChar(CPUIDData,SizeOf(TCPUIDData),#0);
  GetCPUID(7,0,@CPUIDData);
  if (CPUIDData.EBX and (TPasLLMUInt32(1) shl 5))<>0 then begin
   PasLLMCPUFeatures:=PasLLMCPUFeatures or PasLLMCPUFeatures_X86_AVX2_Mask;
  end;
 end;
end;
{$else}
begin
end;
{$ifend}

procedure CheckCPU;
begin
 if (not CPUChecked) and
    (not TPasMPInterlocked.CompareExchange(CPUChecked,TPasMPBool32(true),TPasMPBool32(false))) then begin
  DoCheckCPU;
 end;
end;

initialization

 // Check CPU
 CheckCPU;

 // Set FPU exceptions to ignore invalid operations, denormalized numbers, zero divide, overflow, underflow, and precision errors
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);

 // Generate lookup tables for half-precision floating-point representation
 GenerateHalfFloatLookUpTables;

 // Generate the lookup tables for FP8E5M2 and FP8E4M3 conversion
 GenerateFP8ToFloat32LookUpTables;

 // Initialize TensorDataTypeDotProductMatrix* arrays
 InitializeTensorDataTypeMatrices;

end.
