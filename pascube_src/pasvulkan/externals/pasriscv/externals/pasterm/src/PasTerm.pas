(******************************************************************************
 *                                  PasTerm                                   *
 ******************************************************************************
 *                        Version 2025-01-18-08-48-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2024-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 *****************************************************************************)
 unit PasTerm;
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

type PPPasTermInt8=^PPasTermInt8;
     PPasTermInt8=^TPasTermInt8;
     TPasTermInt8={$ifdef fpc}Int8{$else}shortint{$endif};

     PPPasTermUInt8=^PPasTermUInt8;
     PPasTermUInt8=^TPasTermUInt8;
     TPasTermUInt8={$ifdef fpc}UInt8{$else}byte{$endif};

     PPPasTermUInt8Array=^PPasTermUInt8Array;
     PPasTermUInt8Array=^TPasTermUInt8Array;
     TPasTermUInt8Array=array[0..65535] of TPasTermUInt8;

     TPasTermUInt8DynamicArray=array of TPasTermUInt8;

     PPPasTermInt16=^PPasTermInt16;
     PPasTermInt16=^TPasTermInt16;
     TPasTermInt16={$ifdef fpc}Int16{$else}smallint{$endif};

     PPPasTermUInt16=^PPasTermUInt16;
     PPasTermUInt16=^TPasTermUInt16;
     TPasTermUInt16={$ifdef fpc}UInt16{$else}word{$endif};

     PPPasTermInt32=^PPasTermInt32;
     PPasTermInt32=^TPasTermInt32;
     TPasTermInt32={$ifdef fpc}Int32{$else}longint{$endif};

     PPPasTermUInt32=^PPasTermUInt32;
     PPasTermUInt32=^TPasTermUInt32;
     TPasTermUInt32={$ifdef fpc}UInt32{$else}longword{$endif};

     PPPasTermInt64=^PPasTermInt64;
     PPasTermInt64=^TPasTermInt64;
     TPasTermInt64=Int64;

     PPPasTermUInt64=^PPasTermUInt64;
     PPasTermUInt64=^TPasTermUInt64;
     TPasTermUInt64=UInt64;

     PPPasTermChar=^PAnsiChar;
     PPasTermChar=PAnsiChar;
     TPasTermChar=AnsiChar;

     PPPasTermRawByteChar=^PAnsiChar;
     PPasTermRawByteChar=PAnsiChar;
     TPasTermRawByteChar=AnsiChar;

     PPPasTermUTF16Char=^PWideChar;
     PPasTermUTF16Char=PWideChar;
     TPasTermUTF16Char=WideChar;

     PPPasTermPointer=^PPasTermPointer;
     PPasTermPointer=^TPasTermPointer;
     TPasTermPointer=Pointer;

     PPPasTermPointers=^PPasTermPointers;
     PPasTermPointers=^TPasTermPointers;
     TPasTermPointers=array[0..65535] of TPasTermPointer;

     PPPasTermVoid=^PPasTermVoid;
     PPasTermVoid=TPasTermPointer;

     PPPasTermFloat=^PPasTermFloat;
     PPasTermFloat=^TPasTermFloat;
     TPasTermFloat=Single;

     TPasTermFloats=array of TPasTermFloat;

     PPPasTermDouble=^PPasTermDouble;
     PPasTermDouble=^TPasTermDouble;
     TPasTermDouble=Double;

     PPPasTermPtrUInt=^PPasTermPtrUInt;
     PPPasTermPtrInt=^PPasTermPtrInt;
     PPasTermPtrUInt=^TPasTermPtrUInt;
     PPasTermPtrInt=^TPasTermPtrInt;
{$ifdef fpc}
     TPasTermPtrUInt=PtrUInt;
     TPasTermPtrInt=PtrInt;
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
     TPasTermPtrUInt=NativeUInt;
     TPasTermPtrInt=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
{$ifdef cpu64}
     TPasTermPtrUInt=uint64;
     TPasTermPtrInt=int64;
{$else}
     TPasTermPtrUInt=longword;
     TPasTermPtrInt=longint;
{$endif}
{$endif}

     PPPasTermSizeUInt=^PPasTermSizeUInt;
     PPasTermSizeUInt=^TPasTermSizeUInt;
     TPasTermSizeUInt=TPasTermPtrUInt;

     PPPasTermSizeInt=^PPasTermSizeInt;
     PPasTermSizeInt=^TPasTermSizeInt;
     TPasTermSizeInt=TPasTermPtrInt;

     PPPasTermNativeUInt=^PPasTermNativeUInt;
     PPasTermNativeUInt=^TPasTermNativeUInt;
     TPasTermNativeUInt=TPasTermPtrUInt;

     PPPasTermNativeInt=^PPasTermNativeInt;
     PPasTermNativeInt=^TPasTermNativeInt;
     TPasTermNativeInt=TPasTermPtrInt;

     PPPasTermSize=^PPasTermSizeUInt;
     PPasTermSize=^TPasTermSizeUInt;
     TPasTermSize=TPasTermPtrUInt;

     PPPasTermPtrDiff=^PPasTermPtrDiff;
     PPasTermPtrDiff=^TPasTermPtrDiff;
     TPasTermPtrDiff=TPasTermPtrInt;

     PPPasTermRawByteString=^PPasTermRawByteString;
     PPasTermRawByteString=^TPasTermRawByteString;
     TPasTermRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     PPPasTermUTF8String=^PPasTermUTF8String;
     PPasTermUTF8String=^TPasTermUTF8String;
     TPasTermUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     PPPasTermUTF16String=^PPasTermUTF16String;
     PPasTermUTF16String=^TPasTermUTF16String;
     TPasTermUTF16String={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

type { TPasTerm }
     TPasTerm=class
      public
       const MaxCountEscapeValues=16;
             UTF8DecoderBufferSize=16;
             FLAG_OCRNL=TPasTermUInt32(1) shl 0;
             FLAG_OFDE=TPasTermUInt32(1) shl 1;
             FLAG_OFILL=TPasTermUInt32(1) shl 2;
             FLAG_OLCUC=TPasTermUInt32(1) shl 3;
             FLAG_ONLCR=TPasTermUInt32(1) shl 4;
             FLAG_ONLRET=TPasTermUInt32(1) shl 5;
             FLAG_ONOCR=TPasTermUInt32(1) shl 6;
             FLAG_OPOST=TPasTermUInt32(1) shl 7;
             MAP_LATIN1=0; // Latin-1 (ISO 8859-1)
             MAP_VT100=1;  // VT100 graphics
             MAP_CP437=2;  // also known as CP437 / Codepage 437
             MAP_USER=3;   // User defined mapping
             MAP_FIRST=MAP_LATIN1;
             MAP_LAST=MAP_USER;
             TranslationMaps:array[MAP_LATIN1..MAP_USER,0..255] of TPasTermUInt32=
              (
               ( // MAP_LATIN1 - Latin-1 (ISO 8859-1) - Very trivial mapping to Unicode codepoints since Latin-1 is a subset of Unicode 
                $000000,$000001,$000002,$000003,$000004,$000005,$000006,$000007,
                $000008,$000009,$00000a,$00000b,$00000c,$00000d,$00000e,$00000f,
                $000010,$000011,$000012,$000013,$000014,$000015,$000016,$000017,
                $000018,$000019,$00001a,$00001b,$00001c,$00001d,$00001e,$00001f,
                $000020,$000021,$000022,$000023,$000024,$000025,$000026,$000027,
                $000028,$000029,$00002a,$00002b,$00002c,$00002d,$00002e,$00002f,
                $000030,$000031,$000032,$000033,$000034,$000035,$000036,$000037,
                $000038,$000039,$00003a,$00003b,$00003c,$00003d,$00003e,$00003f,
                $000040,$000041,$000042,$000043,$000044,$000045,$000046,$000047,
                $000048,$000049,$00004a,$00004b,$00004c,$00004d,$00004e,$00004f,
                $000050,$000051,$000052,$000053,$000054,$000055,$000056,$000057,
                $000058,$000059,$00005a,$00005b,$00005c,$00005d,$00005e,$00005f,
                $000060,$000061,$000062,$000063,$000064,$000065,$000066,$000067,
                $000068,$000069,$00006a,$00006b,$00006c,$00006d,$00006e,$00006f,
                $000070,$000071,$000072,$000073,$000074,$000075,$000076,$000077,
                $000078,$000079,$00007a,$00007b,$00007c,$00007d,$00007e,$00007f,
                $000080,$000081,$000082,$000083,$000084,$000085,$000086,$000087,
                $000088,$000089,$00008a,$00008b,$00008c,$00008d,$00008e,$00008f,
                $000090,$000091,$000092,$000093,$000094,$000095,$000096,$000097,
                $000098,$000099,$00009a,$00009b,$00009c,$00009d,$00009e,$00009f,
                $0000a0,$0000a1,$0000a2,$0000a3,$0000a4,$0000a5,$0000a6,$0000a7,
                $0000a8,$0000a9,$0000aa,$0000ab,$0000ac,$0000ad,$0000ae,$0000af,
                $0000b0,$0000b1,$0000b2,$0000b3,$0000b4,$0000b5,$0000b6,$0000b7,
                $0000b8,$0000b9,$0000ba,$0000bb,$0000bc,$0000bd,$0000be,$0000bf,
                $0000c0,$0000c1,$0000c2,$0000c3,$0000c4,$0000c5,$0000c6,$0000c7,
                $0000c8,$0000c9,$0000ca,$0000cb,$0000cc,$0000cd,$0000ce,$0000cf,
                $0000d0,$0000d1,$0000d2,$0000d3,$0000d4,$0000d5,$0000d6,$0000d7,
                $0000d8,$0000d9,$0000da,$0000db,$0000dc,$0000dd,$0000de,$0000df,
                $0000e0,$0000e1,$0000e2,$0000e3,$0000e4,$0000e5,$0000e6,$0000e7,
                $0000e8,$0000e9,$0000ea,$0000eb,$0000ec,$0000ed,$0000ee,$0000ef,
                $0000f0,$0000f1,$0000f2,$0000f3,$0000f4,$0000f5,$0000f6,$0000f7,
                $0000f8,$0000f9,$0000fa,$0000fb,$0000fc,$0000fd,$0000fe,$0000ff
               ),
               ( // MAP_VT100 - VT100 graphics mapping - This is a mapping to Unicode codepoints for the VT100 graphics characters
                $000000,$000001,$000002,$000003,$000004,$000005,$000006,$000007,
                $000008,$000009,$00000a,$00000b,$00000c,$00000d,$00000e,$00000f,
                $000010,$000011,$000012,$000013,$000014,$000015,$000016,$000017,
                $000018,$000019,$00001a,$00001b,$00001c,$00001d,$00001e,$00001f,
                $000020,$000021,$000022,$000023,$000024,$000025,$000026,$000027,
                $000028,$000029,$00002a,$002192,$002190,$002191,$002193,$00002f,
                $002588,$000031,$000032,$000033,$000034,$000035,$000036,$000037,
                $000038,$000039,$00003a,$00003b,$00003c,$00003d,$00003e,$00003f,
                $000040,$000041,$000042,$000043,$000044,$000045,$000046,$000047,
                $000048,$000049,$00004a,$00004b,$00004c,$00004d,$00004e,$00004f,
                $000050,$000051,$000052,$000053,$000054,$000055,$000056,$000057,
                $000058,$000059,$00005a,$00005b,$00005c,$00005d,$00005e,$0000a0,
                $0025c6,$002592,$002409,$00240c,$00240d,$00240a,$0000b0,$0000b1,
                $002591,$00240b,$002518,$002510,$00250c,$002514,$00253c,$0023ba,
                $0023bb,$002500,$0023bc,$0023bd,$00251c,$002524,$002534,$00252c,
                $002502,$002264,$002265,$0003c0,$002260,$0000a3,$0000b7,$00007f,
                $000080,$000081,$000082,$000083,$000084,$000085,$000086,$000087,
                $000088,$000089,$00008a,$00008b,$00008c,$00008d,$00008e,$00008f,
                $000090,$000091,$000092,$000093,$000094,$000095,$000096,$000097,
                $000098,$000099,$00009a,$00009b,$00009c,$00009d,$00009e,$00009f,
                $0000a0,$0000a1,$0000a2,$0000a3,$0000a4,$0000a5,$0000a6,$0000a7,
                $0000a8,$0000a9,$0000aa,$0000ab,$0000ac,$0000ad,$0000ae,$0000af,
                $0000b0,$0000b1,$0000b2,$0000b3,$0000b4,$0000b5,$0000b6,$0000b7,
                $0000b8,$0000b9,$0000ba,$0000bb,$0000bc,$0000bd,$0000be,$0000bf,
                $0000c0,$0000c1,$0000c2,$0000c3,$0000c4,$0000c5,$0000c6,$0000c7,
                $0000c8,$0000c9,$0000ca,$0000cb,$0000cc,$0000cd,$0000ce,$0000cf,
                $0000d0,$0000d1,$0000d2,$0000d3,$0000d4,$0000d5,$0000d6,$0000d7,
                $0000d8,$0000d9,$0000da,$0000db,$0000dc,$0000dd,$0000de,$0000df,
                $0000e0,$0000e1,$0000e2,$0000e3,$0000e4,$0000e5,$0000e6,$0000e7,
                $0000e8,$0000e9,$0000ea,$0000eb,$0000ec,$0000ed,$0000ee,$0000ef,
                $0000f0,$0000f1,$0000f2,$0000f3,$0000f4,$0000f5,$0000f6,$0000f7,
                $0000f8,$0000f9,$0000fa,$0000fb,$0000fc,$0000fd,$0000fe,$0000ff
               ),
               ( // MAP_CP437 - IBM PC Codepage 437 - This is a mapping to Unicode codepoints for the IBM PC Codepage 437
                $000000,$00263a,$00263b,$002665,$002666,$002663,$002660,$002022,
                $0025d8,$0025cb,$0025d9,$002642,$002640,$00266a,$00266b,$00263c,
                $0025b6,$0025c0,$002195,$00203c,$0000b6,$0000a7,$0025ac,$0021a8,
                $002191,$002193,$002192,$002190,$00221f,$002194,$0025b2,$0025bc,
                $000020,$000021,$000022,$000023,$000024,$000025,$000026,$000027,
                $000028,$000029,$00002a,$00002b,$00002c,$00002d,$00002e,$00002f,
                $000030,$000031,$000032,$000033,$000034,$000035,$000036,$000037,
                $000038,$000039,$00003a,$00003b,$00003c,$00003d,$00003e,$00003f,
                $000040,$000041,$000042,$000043,$000044,$000045,$000046,$000047,
                $000048,$000049,$00004a,$00004b,$00004c,$00004d,$00004e,$00004f,
                $000050,$000051,$000052,$000053,$000054,$000055,$000056,$000057,
                $000058,$000059,$00005a,$00005b,$00005c,$00005d,$00005e,$00005f,
                $000060,$000061,$000062,$000063,$000064,$000065,$000066,$000067,
                $000068,$000069,$00006a,$00006b,$00006c,$00006d,$00006e,$00006f,
                $000070,$000071,$000072,$000073,$000074,$000075,$000076,$000077,
                $000078,$000079,$00007a,$00007b,$00007c,$00007d,$00007e,$002302,
                $0000c7,$0000fc,$0000e9,$0000e2,$0000e4,$0000e0,$0000e5,$0000e7,
                $0000ea,$0000eb,$0000e8,$0000ef,$0000ee,$0000ec,$0000c4,$0000c5,
                $0000c9,$0000e6,$0000c6,$0000f4,$0000f6,$0000f2,$0000fb,$0000f9,
                $0000ff,$0000d6,$0000dc,$0000a2,$0000a3,$0000a5,$0020a7,$000192,
                $0000e1,$0000ed,$0000f3,$0000fa,$0000f1,$0000d1,$0000aa,$0000ba,
                $0000bf,$002310,$0000ac,$0000bd,$0000bc,$0000a1,$0000ab,$0000bb,
                $002591,$002592,$002593,$002502,$002524,$002561,$002562,$002556,
                $002555,$002563,$002551,$002557,$00255d,$00255c,$00255b,$002510,
                $002514,$002534,$00252c,$00251c,$002500,$00253c,$00255e,$00255f,
                $00255a,$002554,$002569,$002566,$002560,$002550,$00256c,$002567,
                $002568,$002564,$002565,$002559,$002558,$002552,$002553,$00256b,
                $00256a,$002518,$00250c,$002588,$002584,$00258c,$002590,$002580,
                $0003b1,$0000df,$000393,$0003c0,$0003a3,$0003c3,$0000b5,$0003c4,
                $0003a6,$000398,$0003a9,$0003b4,$00221e,$0003c6,$0003b5,$002229,
                $002261,$0000b1,$002265,$002264,$002320,$002321,$0000f7,$002248,
                $0000b0,$002219,$0000b7,$00221a,$00207f,$0000b2,$0025a0,$0000a0
               ),
               ( // MAP_USER - User defined mapping - This is a mapping to Unicode codepoints for a user defined mapping
                $00f000,$00f001,$00f002,$00f003,$00f004,$00f005,$00f006,$00f007,
                $00f008,$00f009,$00f00a,$00f00b,$00f00c,$00f00d,$00f00e,$00f00f,
                $00f010,$00f011,$00f012,$00f013,$00f014,$00f015,$00f016,$00f017,
                $00f018,$00f019,$00f01a,$00f01b,$00f01c,$00f01d,$00f01e,$00f01f,
                $00f020,$00f021,$00f022,$00f023,$00f024,$00f025,$00f026,$00f027,
                $00f028,$00f029,$00f02a,$00f02b,$00f02c,$00f02d,$00f02e,$00f02f,
                $00f030,$00f031,$00f032,$00f033,$00f034,$00f035,$00f036,$00f037,
                $00f038,$00f039,$00f03a,$00f03b,$00f03c,$00f03d,$00f03e,$00f03f,
                $00f040,$00f041,$00f042,$00f043,$00f044,$00f045,$00f046,$00f047,
                $00f048,$00f049,$00f04a,$00f04b,$00f04c,$00f04d,$00f04e,$00f04f,
                $00f050,$00f051,$00f052,$00f053,$00f054,$00f055,$00f056,$00f057,
                $00f058,$00f059,$00f05a,$00f05b,$00f05c,$00f05d,$00f05e,$00f05f,
                $00f060,$00f061,$00f062,$00f063,$00f064,$00f065,$00f066,$00f067,
                $00f068,$00f069,$00f06a,$00f06b,$00f06c,$00f06d,$00f06e,$00f06f,
                $00f070,$00f071,$00f072,$00f073,$00f074,$00f075,$00f076,$00f077,
                $00f078,$00f079,$00f07a,$00f07b,$00f07c,$00f07d,$00f07e,$00f07f,
                $00f080,$00f081,$00f082,$00f083,$00f084,$00f085,$00f086,$00f087,
                $00f088,$00f089,$00f08a,$00f08b,$00f08c,$00f08d,$00f08e,$00f08f,
                $00f090,$00f091,$00f092,$00f093,$00f094,$00f095,$00f096,$00f097,
                $00f098,$00f099,$00f09a,$00f09b,$00f09c,$00f09d,$00f09e,$00f09f,
                $00f0a0,$00f0a1,$00f0a2,$00f0a3,$00f0a4,$00f0a5,$00f0a6,$00f0a7,
                $00f0a8,$00f0a9,$00f0aa,$00f0ab,$00f0ac,$00f0ad,$00f0ae,$00f0af,
                $00f0b0,$00f0b1,$00f0b2,$00f0b3,$00f0b4,$00f0b5,$00f0b6,$00f0b7,
                $00f0b8,$00f0b9,$00f0ba,$00f0bb,$00f0bc,$00f0bd,$00f0be,$00f0bf,
                $00f0c0,$00f0c1,$00f0c2,$00f0c3,$00f0c4,$00f0c5,$00f0c6,$00f0c7,
                $00f0c8,$00f0c9,$00f0ca,$00f0cb,$00f0cc,$00f0cd,$00f0ce,$00f0cf,
                $00f0d0,$00f0d1,$00f0d2,$00f0d3,$00f0d4,$00f0d5,$00f0d6,$00f0d7,
                $00f0d8,$00f0d9,$00f0da,$00f0db,$00f0dc,$00f0dd,$00f0de,$00f0df,
                $00f0e0,$00f0e1,$00f0e2,$00f0e3,$00f0e4,$00f0e5,$00f0e6,$00f0e7,
                $00f0e8,$00f0e9,$00f0ea,$00f0eb,$00f0ec,$00f0ed,$00f0ee,$00f0ef,
                $00f0f0,$00f0f1,$00f0f2,$00f0f3,$00f0f4,$00f0f5,$00f0f6,$00f0f7,
                $00f0f8,$00f0f9,$00f0fa,$00f0fb,$00f0fc,$00f0fd,$00f0fe,$00f0ff
               )
              );
             Colors256:array[0..255] of TPasTermUInt32=
              (
               TPasTermUInt32($000000),TPasTermUInt32($0000aa),TPasTermUInt32($00aa00),TPasTermUInt32($00aaaa),TPasTermUInt32($aa0000),TPasTermUInt32($aa00aa),TPasTermUInt32($aaaa00),TPasTermUInt32($aaaaaa),
               TPasTermUInt32($555555),TPasTermUInt32($5555ff),TPasTermUInt32($55ff55),TPasTermUInt32($55ffff),TPasTermUInt32($ff5555),TPasTermUInt32($ff55ff),TPasTermUInt32($ffff55),TPasTermUInt32($ffffff),
               TPasTermUInt32($000000),TPasTermUInt32($5f0000),TPasTermUInt32($870000),TPasTermUInt32($af0000),TPasTermUInt32($d70000),TPasTermUInt32($ff0000),TPasTermUInt32($005f00),TPasTermUInt32($5f5f00),
               TPasTermUInt32($875f00),TPasTermUInt32($af5f00),TPasTermUInt32($d75f00),TPasTermUInt32($ff5f00),TPasTermUInt32($008700),TPasTermUInt32($5f8700),TPasTermUInt32($878700),TPasTermUInt32($af8700),
               TPasTermUInt32($d78700),TPasTermUInt32($ff8700),TPasTermUInt32($00af00),TPasTermUInt32($5faf00),TPasTermUInt32($87af00),TPasTermUInt32($afaf00),TPasTermUInt32($d7af00),TPasTermUInt32($ffaf00),
               TPasTermUInt32($00d700),TPasTermUInt32($5fd700),TPasTermUInt32($87d700),TPasTermUInt32($afd700),TPasTermUInt32($d7d700),TPasTermUInt32($ffd700),TPasTermUInt32($00ff00),TPasTermUInt32($5fff00),
               TPasTermUInt32($87ff00),TPasTermUInt32($afff00),TPasTermUInt32($d7ff00),TPasTermUInt32($ffff00),TPasTermUInt32($00005f),TPasTermUInt32($5f005f),TPasTermUInt32($87005f),TPasTermUInt32($af005f),
               TPasTermUInt32($d7005f),TPasTermUInt32($ff005f),TPasTermUInt32($005f5f),TPasTermUInt32($5f5f5f),TPasTermUInt32($875f5f),TPasTermUInt32($af5f5f),TPasTermUInt32($d75f5f),TPasTermUInt32($ff5f5f),
               TPasTermUInt32($00875f),TPasTermUInt32($5f875f),TPasTermUInt32($87875f),TPasTermUInt32($af875f),TPasTermUInt32($d7875f),TPasTermUInt32($ff875f),TPasTermUInt32($00af5f),TPasTermUInt32($5faf5f),
               TPasTermUInt32($87af5f),TPasTermUInt32($afaf5f),TPasTermUInt32($d7af5f),TPasTermUInt32($ffaf5f),TPasTermUInt32($00d75f),TPasTermUInt32($5fd75f),TPasTermUInt32($87d75f),TPasTermUInt32($afd75f),
               TPasTermUInt32($d7d75f),TPasTermUInt32($ffd75f),TPasTermUInt32($00ff5f),TPasTermUInt32($5fff5f),TPasTermUInt32($87ff5f),TPasTermUInt32($afff5f),TPasTermUInt32($d7ff5f),TPasTermUInt32($ffff5f),
               TPasTermUInt32($000087),TPasTermUInt32($5f0087),TPasTermUInt32($870087),TPasTermUInt32($af0087),TPasTermUInt32($d70087),TPasTermUInt32($ff0087),TPasTermUInt32($005f87),TPasTermUInt32($5f5f87),
               TPasTermUInt32($875f87),TPasTermUInt32($af5f87),TPasTermUInt32($d75f87),TPasTermUInt32($ff5f87),TPasTermUInt32($008787),TPasTermUInt32($5f8787),TPasTermUInt32($878787),TPasTermUInt32($af8787),
               TPasTermUInt32($d78787),TPasTermUInt32($ff8787),TPasTermUInt32($00af87),TPasTermUInt32($5faf87),TPasTermUInt32($87af87),TPasTermUInt32($afaf87),TPasTermUInt32($d7af87),TPasTermUInt32($ffaf87),
               TPasTermUInt32($00d787),TPasTermUInt32($5fd787),TPasTermUInt32($87d787),TPasTermUInt32($afd787),TPasTermUInt32($d7d787),TPasTermUInt32($ffd787),TPasTermUInt32($00ff87),TPasTermUInt32($5fff87),
               TPasTermUInt32($87ff87),TPasTermUInt32($afff87),TPasTermUInt32($d7ff87),TPasTermUInt32($ffff87),TPasTermUInt32($0000af),TPasTermUInt32($5f00af),TPasTermUInt32($8700af),TPasTermUInt32($af00af),
               TPasTermUInt32($d700af),TPasTermUInt32($ff00af),TPasTermUInt32($005faf),TPasTermUInt32($5f5faf),TPasTermUInt32($875faf),TPasTermUInt32($af5faf),TPasTermUInt32($d75faf),TPasTermUInt32($ff5faf),
               TPasTermUInt32($0087af),TPasTermUInt32($5f87af),TPasTermUInt32($8787af),TPasTermUInt32($af87af),TPasTermUInt32($d787af),TPasTermUInt32($ff87af),TPasTermUInt32($00afaf),TPasTermUInt32($5fafaf),
               TPasTermUInt32($87afaf),TPasTermUInt32($afafaf),TPasTermUInt32($d7afaf),TPasTermUInt32($ffafaf),TPasTermUInt32($00d7af),TPasTermUInt32($5fd7af),TPasTermUInt32($87d7af),TPasTermUInt32($afd7af),
               TPasTermUInt32($d7d7af),TPasTermUInt32($ffd7af),TPasTermUInt32($00ffaf),TPasTermUInt32($5fffaf),TPasTermUInt32($87ffaf),TPasTermUInt32($afffaf),TPasTermUInt32($d7ffaf),TPasTermUInt32($ffffaf),
               TPasTermUInt32($0000d7),TPasTermUInt32($5f00d7),TPasTermUInt32($8700d7),TPasTermUInt32($af00d7),TPasTermUInt32($d700d7),TPasTermUInt32($ff00d7),TPasTermUInt32($005fd7),TPasTermUInt32($5f5fd7),
               TPasTermUInt32($875fd7),TPasTermUInt32($af5fd7),TPasTermUInt32($d75fd7),TPasTermUInt32($ff5fd7),TPasTermUInt32($0087d7),TPasTermUInt32($5f87d7),TPasTermUInt32($8787d7),TPasTermUInt32($af87d7),
               TPasTermUInt32($d787d7),TPasTermUInt32($ff87d7),TPasTermUInt32($00afd7),TPasTermUInt32($5fafd7),TPasTermUInt32($87afd7),TPasTermUInt32($afafd7),TPasTermUInt32($d7afd7),TPasTermUInt32($ffafd7),
               TPasTermUInt32($00d7d7),TPasTermUInt32($5fd7d7),TPasTermUInt32($87d7d7),TPasTermUInt32($afd7d7),TPasTermUInt32($d7d7d7),TPasTermUInt32($ffd7d7),TPasTermUInt32($00ffd7),TPasTermUInt32($5fffd7),
               TPasTermUInt32($87ffd7),TPasTermUInt32($afffd7),TPasTermUInt32($d7ffd7),TPasTermUInt32($ffffd7),TPasTermUInt32($0000ff),TPasTermUInt32($5f00ff),TPasTermUInt32($8700ff),TPasTermUInt32($af00ff),
               TPasTermUInt32($d700ff),TPasTermUInt32($ff00ff),TPasTermUInt32($005fff),TPasTermUInt32($5f5fff),TPasTermUInt32($875fff),TPasTermUInt32($af5fff),TPasTermUInt32($d75fff),TPasTermUInt32($ff5fff),
               TPasTermUInt32($0087ff),TPasTermUInt32($5f87ff),TPasTermUInt32($8787ff),TPasTermUInt32($af87ff),TPasTermUInt32($d787ff),TPasTermUInt32($ff87ff),TPasTermUInt32($00afff),TPasTermUInt32($5fafff),
               TPasTermUInt32($87afff),TPasTermUInt32($afafff),TPasTermUInt32($d7afff),TPasTermUInt32($ffafff),TPasTermUInt32($00d7ff),TPasTermUInt32($5fd7ff),TPasTermUInt32($87d7ff),TPasTermUInt32($afd7ff),
               TPasTermUInt32($d7d7ff),TPasTermUInt32($ffd7ff),TPasTermUInt32($00ffff),TPasTermUInt32($5fffff),TPasTermUInt32($87ffff),TPasTermUInt32($afffff),TPasTermUInt32($d7ffff),TPasTermUInt32($ffffff),
               TPasTermUInt32($080808),TPasTermUInt32($121212),TPasTermUInt32($1c1c1c),TPasTermUInt32($262626),TPasTermUInt32($303030),TPasTermUInt32($3a3a3a),TPasTermUInt32($444444),TPasTermUInt32($4e4e4e),
               TPasTermUInt32($585858),TPasTermUInt32($626262),TPasTermUInt32($6c6c6c),TPasTermUInt32($767676),TPasTermUInt32($808080),TPasTermUInt32($8a8a8a),TPasTermUInt32($949494),TPasTermUInt32($9e9e9e),
               TPasTermUInt32($a8a8a8),TPasTermUInt32($b2b2b2),TPasTermUInt32($bcbcbc),TPasTermUInt32($c6c6c6),TPasTermUInt32($d0d0d0),TPasTermUInt32($dadada),TPasTermUInt32($e4e4e4),TPasTermUInt32($eeeeee)
              );
             UTF8CharSteps:array[TPasTermUInt8] of TPasTermUInt8=
              ( // 0 1 2 3 4 5 6 7 8 9 a b c d e f
                   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
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
                   4,4,4,4,4,1,1,1,1,1,1,1,1,1,1,1   // f
              );// 0 1 2 3 4 5 6 7 8 9 a b c d e f
             UTF8DFACharClasses:array[TPasTermUInt8] of TPasTermUInt8=
              (
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
               $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,
               $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,
               $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
               $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
               $08,$08,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
               $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
               $0a,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$04,$03,$03,
               $0b,$06,$06,$06,$05,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
              );
             UTF8DFATransitions:array[TPasTermUInt8] of TPasTermUInt8=
              (
               $00,$10,$20,$30,$50,$80,$70,$10,$10,$10,$40,$60,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$00,$10,$10,$10,$10,$10,$00,$10,$00,$10,$10,$10,$10,$10,$10,
               $10,$20,$10,$10,$10,$10,$10,$20,$10,$20,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$20,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$20,$10,$10,$10,$10,$10,$10,$10,$20,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$30,$10,$30,$10,$10,$10,$10,$10,$10,
               $10,$30,$10,$10,$10,$10,$10,$30,$10,$30,$10,$10,$10,$10,$10,$10,
               $10,$30,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
               $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
              );
             UTF8DecoderStateAccept=0;
             UTF8DecoderStateError=16;
       type TInputEncodingMode=
             (
              UTF8=0,
              Raw=1
             );
            TOutputEncodingMode=
             (
              Unicode=0,
              ASCII=1,
              Latin1=2,
              CP437=3
             );
            TCharset=
             (
              UTF8_Latin1=0, // UTF8 or Latin1, since Latin1 is a unicode subset
              VT100=1,
              CP437=2,
              User=3
             );
            TState=record
             ForegroundBold:Boolean;
             BackgroundBold:Boolean;
             ReverseVideo:Boolean;
             CurrentCharset:TPasTermSizeInt;
             CurrentForegroundColor:TPasTermSizeInt;
             CurrentBackgroundColor:TPasTermSizeInt;
             CursorColumn:TPasTermSizeInt;
             CursorRow:TPasTermSizeInt;
             TextForegroundColor:TPasTermUInt32;
             TextBackgroundColor:TPasTermUInt32;
            end;
            PState=^TState;
            TInterval=record
             First:TPasTermUInt32;
             Last:TPasTermUInt32;
            end;
            PInterval=^TInterval;
            TIntervalArray=array[0..65535] of TInterval;
            PIntervalArray=^TIntervalArray;
            TEscapeValues=array[0..MaxCountEscapeValues-1] of TPasTermUInt32;
            { TDataQueue }
            TDataQueue=class
             public
              type TQueueItem=TPasTermUInt32;
                   TQueueItems=array of TQueueItem;
             private
              fItems:TQueueItems;
              fHead:TPasTermSizeInt;
              fTail:TPasTermSizeInt;
              fCount:TPasTermSizeInt;
              fSize:TPasTermSizeInt;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure GrowResize(const aSize:TPasTermSizeInt);
              procedure Clear;
              function IsEmpty:boolean;
              procedure EnqueueAtFront(const aItem:TQueueItem);
              procedure Enqueue(const aItem:TQueueItem);
              function Dequeue(out aItem:TQueueItem):boolean; overload;
              function Dequeue:boolean; overload;
              function Peek(out aItem:TQueueItem):boolean;
            end;
            TFrameBufferCodePoint=record
             CodePoint:TPasTermUInt32;
             ForegroundColor:TPasTermUInt32;
             BackgroundColor:TPasTermUInt32;
            end;
            PFrameBufferCodePoint=^TFrameBufferCodePoint;
            TFrameBufferQueueItem=record
             Column:TPasTermSizeInt;
             Row:TPasTermSizeInt;
             CodePoint:TFrameBufferCodePoint;
            end;
            PFrameBufferQueueItem=^TFrameBufferQueueItem;
            { TFrameBufferQueue }
            TFrameBufferQueue=class
             private
              fTerm:TPasTerm;
              fItems:array of TFrameBufferQueueItem;
              fCount:TPasTermSizeInt;
              fFillIndex:TPasTermSizeInt;
             public
              constructor Create(const aTerm:TPasTerm); reintroduce;
              destructor Destroy; override;
              procedure Resize;
              procedure Clear;
              function Add(const aItem:TFrameBufferQueueItem):TPasTermSizeInt; overload;
              function Add(const aCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt):TPasTermSizeInt; overload;
              function Get(const aIndex:TPasTermSizeInt):PFrameBufferQueueItem;
             public
              property Count:TPasTermSizeInt read fCount;
            end;
            TFrameBufferContentQueueMap=array of TPasTermSizeInt;
            TFrameBufferContent=array of TFrameBufferCodePoint;
            { TFrameBufferSnapshot }
            TFrameBufferSnapshot=class
             private
              fTerm:TPasTerm;
              fContent:TFrameBufferContent;
              fColumns:TPasTermSizeInt;
              fRows:TPasTermSizeInt;
              fCursorColumn:TPasTermSizeInt;
              fCursorRow:TPasTermSizeInt;
              fCursorEnabled:Boolean;
              fInsertMode:Boolean;
             public
              constructor Create(const aTerm:TPasTerm); reintroduce;
              destructor Destroy; override;
              procedure Update;
             public
              property Columns:TPasTermSizeInt read fColumns;
              property Rows:TPasTermSizeInt read fRows;
              property Content:TFrameBufferContent read fContent;
              property CursorColumn:TPasTermSizeInt read fCursorColumn;
              property CursorRow:TPasTermSizeInt read fCursorRow;
              property CursorEnabled:Boolean read fCursorEnabled;
              property InsertMode:Boolean read fInsertMode;
            end;
            TOnDEC=procedure(const aSender:TPasTerm;const aCodePoint:TPasTermUInt32;const aEscapeValues:TPasTerm.TEscapeValues;const fCountEscapeValues:TPasTermSizeInt) of object;
            TOnBell=procedure(const aSender:TPasTerm) of object;
            TOnPrivateID=procedure(const aSender:TPasTerm;const aCodePoint:TPasTermUInt32) of object;
            TOnStatusReport=procedure(const aSender:TPasTerm) of object;
            TOnPositionReport=procedure(const aSender:TPasTerm;const aColumn,aRow:TPasTermSizeInt) of object;
            TOnKeyboardLEDs=procedure(const aSender:TPasTerm;const aValue:TPasTermUInt32) of object;
            TOnMode=procedure(const aSender:TPasTerm;const aCodePoint:TPasTermUInt32;const aEscapeValues:TPasTerm.TEscapeValues;const fCountEscapeValues:TPasTermSizeInt) of object;
            TOnLinux=procedure(const aSender:TPasTerm;const aEscapeValues:TPasTerm.TEscapeValues;const fCountEscapeValues:TPasTermSizeInt) of object;
            TOnDrawBackground=procedure(const aSender:TPasTerm) of object;
            TOnDrawCodePoint=procedure(const aSender:TPasTerm;const aCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt) of object;
            TOnDrawCodePointMasked=procedure(const aSender:TPasTerm;const aCodePoint,aOldCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt) of object;
            TOnDrawCursor=procedure(const aSender:TPasTerm;const aColumn,aRow:TPasTermSizeInt) of object;
      private
       fTabSize:TPasTermSizeInt;
       fAutoFlush:Boolean;
       fCursorEnabled:Boolean;
       fScrollEnabled:Boolean;
       fControlSequence:Boolean;
       fEscape:Boolean;
       fOSC:Boolean;
       fOSCEscape:Boolean;
       fRRR:Boolean;
       fDiscardNext:Boolean;
       fDECPrivate:Boolean;
       fInsertMode:Boolean;
       fUTF8DecoderBuffer:array[0..UTF8DecoderBufferSize-1] of TPasTermUInt8;
       fUTF8DecoderBufferIndex:TPasTermUInt32;
       fUTF8DecoderState:TPasTermUInt32;
       fUTF8DecoderValue:TPasTermUInt32;
       fUTF8DataQueue:TDataQueue;
       fUTF8MissingBuffer:TPasTermRawByteString;
       fGSelect:TPasTermUInt8;
       fCharsetSelect:Boolean;
       fCharsets:array[0..3] of TCharset;
       fEscapeOffset:TPasTermSizeInt;
       fCountEscapeValues:TPasTermSizeInt;
       fSavedCursorX:TPasTermSizeInt;
       fSavedCursorY:TPasTermSizeInt;
       fScrollTopMargin:TPasTermSizeInt;
       fScrollBottomMargin:TPasTermSizeInt;
       fEscapeValues:TEscapeValues;
       fFlags:TPasTermUInt32;
       fInputEncodingMode:TInputEncodingMode;
       fOutputEncodingMode:TOutputEncodingMode;
       fState:TState;
       fSavedState:TState;
       fSavedScreenState:TState;
       fRows:TPasTermSizeInt;
       fColumns:TPasTermSizeInt;
       fQueue:TFrameBufferQueue;
       fContentQueueMap:TFrameBufferContentQueueMap;
       fContent:TFrameBufferContent;
       fContentColumns:TPasTermSizeInt;
       fContentRows:TPasTermSizeInt;
       fSavedScreenContent:TFrameBufferContent;
       fSavedScreenContentColumns:TPasTermSizeInt;
       fSavedScreenContentRows:TPasTermSizeInt;
       fOldCursorColumn:TPasTermSizeInt;
       fOldCursorRow:TPasTermSizeInt;
       fOnDEC:TOnDEC;
       fOnBell:TOnBell;
       fOnPrivateID:TOnPrivateID;
       fOnStatusReport:TOnStatusReport;
       fOnPositionReport:TOnPositionReport;
       fOnKeyboardLEDs:TOnKeyboardLEDs;
       fOnMode:TOnMode;
       fOnLinux:TOnLinux;
       fOnDrawBackground:TOnDrawBackground;
       fOnDrawCodePoint:TOnDrawCodePoint;
       fOnDrawCodePointMasked:TOnDrawCodePointMasked;
       fOnDrawCursor:TOnDrawCursor;
       procedure RestoreScreen;
       procedure SaveScreen;
       procedure SetRows(const aRows:TPasTermSizeInt);
       procedure SetColumns(const aColumns:TPasTermSizeInt);
       procedure SGR;
       procedure ParseControlSequence(const aCodePoint:TPasTermUInt32);
       procedure DoSaveState;
       procedure DoRestoreState;
       procedure ParseEscape(const aCodePoint:TPasTermUInt32);
       class function BinarySearch(const aUCS:TPasTermUInt32;const aIntervals:PIntervalArray;const aCount:TPasTermSizeInt):Boolean; static;
       class function WCWidth(const aUCS:TPasTermUInt32):TPasTermSizeInt; static;
       class function UnicodeToCP437(const aCodePoint:TPasTermUInt64):TPasTermInt32; static;
       procedure Enqueue(const aCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt);
       procedure ProcessCodePoint(const aCodePoint:TPasTermUInt32);
       function DecodeCodePoint(const aCodePoint:TPasTermUInt32):Boolean;
       procedure TranslateCodePoint(const aCodePoint:TPasTermUInt32);
       procedure WriteCodePoint(const aCodePoint:TPasTermUInt32);
      public
       constructor Create(const aColumns:TPasTermSizeInt=80;const aRows:TPasTermSizeInt=25);
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure Resize;
       procedure Reinit;
       procedure Clear(const aMove:Boolean); virtual;
       procedure OutputCodePoint(const aCodePoint:TPasTermUInt32);
       function GetCodePoint(const aColumn,aRow:TPasTermSizeInt;const aFlush:Boolean=false):TFrameBufferCodePoint;
       procedure SetCursorPosition(const aColumn,aRow:TPasTermSizeInt);
       procedure GetCursorPosition(out aColumn,aRow:TPasTermSizeInt);
       procedure SetTextForegroundColor(const aFG:TPasTermUInt8);
       procedure SetTextBackgroundColor(const aBG:TPasTermUInt8);
       procedure SetTextForegroundColorBright(const aFG:TPasTermUInt8);
       procedure SetTextBackgroundColorBright(const aBG:TPasTermUInt8);
       procedure SetTextForegroundColorRGB(const aFG:TPasTermUInt32);
       procedure SetTextBackgroundColorRGB(const aBG:TPasTermUInt32);
       procedure SetTextForegroundColorDefault;
       procedure SetTextBackgroundColorDefault;
       procedure SetTextForegroundColorDefaultBright;
       procedure SetTextBackgroundColorDefaultBright;
       procedure MoveCharacter(const aNewColumn,aNewRow,aOldColumn,aOldRow:TPasTermSizeInt);
       procedure Scroll;
       procedure ReverseScroll;
       procedure SwapPalette;
       procedure SaveState;
       procedure RestoreState;
       procedure Flush;
       procedure Refresh;
       procedure Write(const aData:Pointer;const aCount:TPasTermSizeInt); overload;
       procedure Write(const aString:TPasTermRawByteString); overload;
       procedure Write(const aChar:AnsiChar); overload;
       procedure NewLine;
      published
       property Rows:TPasTermSizeInt read fRows write SetRows;
       property Columns:TPasTermSizeInt read fColumns write SetColumns;
       property InputEncodingMode:TInputEncodingMode read fInputEncodingMode write fInputEncodingMode;
       property OutputEncodingMode:TOutputEncodingMode read fOutputEncodingMode write fOutputEncodingMode;
       property Flags:TPasTermUInt32 read fFlags write fFlags;
       property OnDEC:TOnDEC read fOnDEC write fOnDEC;
       property OnBell:TOnBell read fOnBell write fOnBell;
       property OnPrivateID:TOnPrivateID read fOnPrivateID write fOnPrivateID;
       property OnStatusReport:TOnStatusReport read fOnStatusReport write fOnStatusReport;
       property OnPositionReport:TOnPositionReport read fOnPositionReport write fOnPositionReport;
       property OnKeyboardLEDs:TOnKeyboardLEDs read fOnKeyboardLEDs write fOnKeyboardLEDs;
       property OnMode:TOnMode read fOnMode write fOnMode;
       property OnLinux:TOnLinux read fOnLinux write fOnLinux;
       property OnDrawBackground:TOnDrawBackground read fOnDrawBackground write fOnDrawBackground;
       property OnDrawCodePoint:TOnDrawCodePoint read fOnDrawCodePoint write fOnDrawCodePoint;
       property OnDrawCodePointMasked:TOnDrawCodePointMasked read fOnDrawCodePointMasked write fOnDrawCodePointMasked;
       property OnDrawCursor:TOnDrawCursor read fOnDrawCursor write fOnDrawCursor;
     end;

implementation

{ TPasTerm.TDataQueue }

constructor TPasTerm.TDataQueue.Create;
begin
 inherited Create;
 fItems:=nil;
 fHead:=0;
 fTail:=0;
 fCount:=0;
 fSize:=0;
end;

destructor TPasTerm.TDataQueue.Destroy;
begin
 fItems:=nil;
 inherited Destroy;
end;

procedure TPasTerm.TDataQueue.GrowResize(const aSize:TPasTermSizeInt);
var Index,OtherIndex:TPasTermSizeInt;
    NewItems:TQueueItems;
begin
 SetLength(NewItems,aSize);
 OtherIndex:=fHead;
 for Index:=0 to fCount-1 do begin
  NewItems[Index]:=fItems[OtherIndex];
  inc(OtherIndex);
  if OtherIndex>=fSize then begin
   OtherIndex:=0;
  end;
 end;
 fItems:=NewItems;
 fHead:=0;
 fTail:=fCount;
 fSize:=aSize;
end;

procedure TPasTerm.TDataQueue.Clear;
begin
 while fCount>0 do begin
  dec(fCount);
  System.Finalize(fItems[fHead]);
  inc(fHead);
  if fHead>=fSize then begin
   fHead:=0;
  end;
 end;
 fItems:=nil;
 fHead:=0;
 fTail:=0;
 fCount:=0;
 fSize:=0;
end;

function TPasTerm.TDataQueue.IsEmpty:boolean;
begin
 result:=fCount=0;
end;

procedure TPasTerm.TDataQueue.EnqueueAtFront(const aItem:TQueueItem);
var Index:TPasTermSizeInt;
begin
 if fSize<=fCount then begin
  GrowResize(fCount+1);
 end;
 dec(fHead);
 if fHead<0 then begin
  inc(fHead,fSize);
 end;
 Index:=fHead;
 fItems[Index]:=aItem;
 inc(fCount);
end;

procedure TPasTerm.TDataQueue.Enqueue(const aItem:TQueueItem);
var Index:TPasTermSizeInt;
begin
 if fSize<=fCount then begin
  GrowResize(fCount+1);
 end;
 Index:=fTail;
 inc(fTail);
 if fTail>=fSize then begin
  fTail:=0;
 end;
 fItems[Index]:=aItem;
 inc(fCount);
end;

function TPasTerm.TDataQueue.Dequeue(out aItem:TQueueItem):boolean;
begin
 result:=fCount>0;
 if result then begin
  dec(fCount);
  aItem:=fItems[fHead];
  System.Finalize(fItems[fHead]);
  FillChar(fItems[fHead],SizeOf(TQueueItem),#0);
  if fCount=0 then begin
   fHead:=0;
   fTail:=0;
  end else begin
   inc(fHead);
   if fHead>=fSize then begin
    fHead:=0;
   end;
  end;
 end;
end;

function TPasTerm.TDataQueue.Dequeue:boolean;
begin
 result:=fCount>0;
 if result then begin
  dec(fCount);
  System.Finalize(fItems[fHead]);
  FillChar(fItems[fHead],SizeOf(TQueueItem),#0);
  if fCount=0 then begin
   fHead:=0;
   fTail:=0;
  end else begin
   inc(fHead);
   if fHead>=fSize then begin
    fHead:=0;
   end;
  end;
 end;
end;

function TPasTerm.TDataQueue.Peek(out aItem:TQueueItem):boolean;
begin
 result:=fCount>0;
 if result then begin
  aItem:=fItems[fHead];
 end;
end;

{ TPasTerm.FrameBufferQueue }

constructor TPasTerm.TFrameBufferQueue.Create(const aTerm:TPasTerm);
begin
 inherited Create;
 fTerm:=aTerm;
 fItems:=nil;
 fCount:=0;
 fFillIndex:=0;
end;

destructor TPasTerm.TFrameBufferQueue.Destroy;
begin
 fItems:=nil;
 inherited Destroy;
end;

procedure TPasTerm.TFrameBufferQueue.Resize;
var OldCount,Index:TPasTermSizeInt;
    Item:PFrameBufferQueueItem;
begin
 fCount:=fTerm.fRows*fTerm.fColumns;
 OldCount:=length(fItems);
 if OldCount<fCount then begin
  SetLength(fItems,fCount);
  for Index:=OldCount to fCount-1 do begin
   Item:=@fItems[Index];
   Item^.Column:=0;
   Item^.Row:=0;
   Item^.CodePoint.CodePoint:=0;
   Item^.CodePoint.ForegroundColor:=0;
   Item^.CodePoint.BackgroundColor:=0;
  end;
 end;
end;

procedure TPasTerm.TFrameBufferQueue.Clear;
begin
 fFillIndex:=0;
end;

function TPasTerm.TFrameBufferQueue.Add(const aItem:TFrameBufferQueueItem):TPasTermSizeInt;
var OldCount,Index:TPasTermSizeInt;
    Item:PFrameBufferQueueItem;
begin
 if (fFillIndex+1)>fCount then begin
  OldCount:=fCount;
  fCount:=(fFillIndex+1)+((fFillIndex+2) shr 1);
  SetLength(fItems,fCount);
  for Index:=OldCount to fCount-1 do begin
   Item:=@fItems[Index];
   Item^.Column:=0;
   Item^.Row:=0;
   Item^.CodePoint.CodePoint:=0;
   Item^.CodePoint.ForegroundColor:=0;
   Item^.CodePoint.BackgroundColor:=0;
  end;
 end;
 fItems[fFillIndex]:=aItem;
 result:=fFillIndex;
 inc(fFillIndex);
end;

function TPasTerm.TFrameBufferQueue.Add(const aCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt):TPasTermSizeInt;
var Item:TFrameBufferQueueItem;
begin
 Item.Column:=aColumn;
 Item.Row:=aRow;
 Item.CodePoint:=aCodePoint;
 result:=Add(Item);
end;

function TPasTerm.TFrameBufferQueue.Get(const aIndex:TPasTermSizeInt):PFrameBufferQueueItem;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=@fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

{ TPasTerm.FrameBufferSnapshot }

constructor TPasTerm.TFrameBufferSnapshot.Create(const aTerm:TPasTerm);
begin
 inherited Create;
 fTerm:=aTerm;
 fContent:=nil;
 fColumns:=0;
 fRows:=0;
 fCursorColumn:=0;
 fCursorRow:=0;
 fCursorEnabled:=false;
 fInsertMode:=false;
end;

destructor TPasTerm.TFrameBufferSnapshot.Destroy;
begin
 fContent:=nil;
 inherited Destroy;
end;

procedure TPasTerm.TFrameBufferSnapshot.Update;
var x,y,Index:TPasTermSizeInt;
begin
 fColumns:=fTerm.fColumns;
 fRows:=fTerm.fRows;
 if length(fContent)<>(fColumns*fRows) then begin
  SetLength(fContent,fColumns*fRows);
 end;
 Index:=0;
 for y:=0 to fRows-1 do begin
  for x:=0 to fColumns-1 do begin
   fContent[Index]:=fTerm.fContent[Index];
   inc(Index);
  end;
 end;
 fCursorColumn:=fTerm.fState.CursorColumn;
 fCursorRow:=fTerm.fState.CursorRow;
 fCursorEnabled:=fTerm.fCursorEnabled;
 fInsertMode:=fTerm.fInsertMode;
end;

{ TPasTerm }

constructor TPasTerm.Create(const aColumns: TPasTermSizeInt;
 const aRows: TPasTermSizeInt);
begin
 inherited Create;

 fUTF8DataQueue:=TDataQueue.Create;

 fUTF8MissingBuffer:='';

 fQueue:=TFrameBufferQueue.Create(self);

 fContentQueueMap:=nil;

 fContent:=nil;
 fSavedScreenContent:=nil;

 fOnDEC:=nil;
 fOnBell:=nil;
 fOnPrivateID:=nil;
 fOnStatusReport:=nil;
 fOnPositionReport:=nil;
 fOnKeyboardLEDs:=nil;
 fOnMode:=nil;
 fOnLinux:=nil;
 fOnDrawBackground:=nil;
 fOnDrawCodePoint:=nil;
 fOnDrawCodePointMasked:=nil;
 fOnDrawCursor:=nil;

 fInputEncodingMode:=TInputEncodingMode.UTF8;

 fOutputEncodingMode:=TOutputEncodingMode.Unicode;

 fFlags:=FLAG_ONLCR;

 fRows:=aRows;
 fColumns:=aColumns;

 fContentRows:=0;
 fContentColumns:=0;

 fSavedScreenContentColumns:=0;
 fSavedScreenContentRows:=0;

 fOldCursorColumn:=-1;
 fOldCursorRow:=-1;

end;

destructor TPasTerm.Destroy;
begin
 fContent:=nil;
 fSavedScreenContent:=nil;
 fContentQueueMap:=nil;
 FreeAndNil(fQueue);
 FreeAndNil(fUTF8DataQueue);
 fUTF8MissingBuffer:='';
 inherited Destroy;
end;

procedure TPasTerm.AfterConstruction;
begin
 inherited AfterConstruction;
 Resize;
 Reinit;
end;

procedure TPasTerm.BeforeDestruction;
begin
 inherited BeforeDestruction;
end;

procedure TPasTerm.SetRows(const aRows:TPasTermSizeInt);
begin
 if fRows<>aRows then begin
  fRows:=aRows;
 end;
end;

procedure TPasTerm.SetColumns(const aColumns:TPasTermSizeInt);
begin
 if fColumns<>aColumns then begin
  fColumns:=aColumns;
 end;
end;

procedure TPasTerm.Resize;
var Count,Index,x,y:TPasTermSizeInt;
    OldContent:TFrameBufferContent;
begin

 Count:=fRows*fColumns;
 if length(fContentQueueMap)<>Count then begin
  SetLength(fContentQueueMap,Count);
  for Index:=0 to Count-1 do begin
   fContentQueueMap[Index]:=-1;
  end;
 end;

 fQueue.Resize;

 if (length(fContent)=0) or (fRows<>fContentRows) or (fColumns<>fContentColumns) then begin
  OldContent:=fContent;
  try
   fContent:=nil;
   SetLength(fContent,Count);
   for Index:=0 to Count-1 do begin
    fContent[Index].CodePoint:=0;
    fContent[Index].ForegroundColor:=0;
    fContent[Index].BackgroundColor:=0;
   end;
   for y:=0 to Min(fContentRows-1,fRows-1) do begin
    for x:=0 to Min(fContentColumns-1,fColumns-1) do begin
     fContent[(y*fColumns)+x]:=OldContent[(y*fContentColumns)+x];
    end;
   end;
   fContentColumns:=fColumns;
   fContentRows:=fRows;
  finally
   OldContent:=nil;
  end;
 end;

end;

procedure TPasTerm.Reinit;
begin
 fTabSize:=8;
 fAutoFlush:=true;
 fCursorEnabled:=true;
 fScrollEnabled:=true;
 fControlSequence:=false;
 fEscape:=false;
 fOSC:=false;
 fOSCEscape:=false;
 fRRR:=false;
 fDiscardNext:=false;
 fState.ForegroundBold:=false;
 fState.BackgroundBold:=false;
 fState.ReverseVideo:=false;
 fDECPrivate:=false;
 fInsertMode:=false;
 fUTF8DecoderBufferIndex:=0;
 fUTF8DecoderState:=UTF8DecoderStateAccept;
 fUTF8DecoderValue:=0;
 fGSelect:=0;
 fCharsetSelect:=false;
 fCharsets[0]:=TCharset.UTF8_Latin1;
 fCharsets[1]:=TCharset.VT100;
 fState.CurrentCharset:=0;
 fEscapeOffset:=0;
 fCountEscapeValues:=0;
 fSavedCursorX:=0;
 fSavedCursorY:=0;
 fState.CurrentForegroundColor:=-1;
 fState.CurrentBackgroundColor:=-1;
 fScrollTopMargin:=0;
 fScrollBottomMargin:=fRows;
 fState.CursorColumn:=0;
 fState.CursorRow:=0;
 fState.TextForegroundColor:=Colors256[7];
 fState.TextBackgroundColor:=Colors256[0];
end;

procedure TPasTerm.SaveScreen;
var Column,Row,Index:TPasTermSizeInt;
begin
 Flush;
 fSavedScreenState:=fState;
 fSavedScreenContentColumns:=fColumns;
 fSavedScreenContentRows:=fRows;
 if length(fSavedScreenContent)<>(fColumns*fRows) then begin
  SetLength(fSavedScreenContent,fColumns*fRows);
 end;
 Index:=0;
 for Row:=0 to fRows-1 do begin
  for Column:=0 to fColumns-1 do begin
   fSavedScreenContent[Index]:=fContent[Index];
   inc(Index);
  end;
 end;
end;

procedure TPasTerm.RestoreScreen;
var Column,Row:TPasTermSizeInt;
begin
 if fAutoFlush then begin
  Flush;
 end;
 for Row:=0 to Min(fSavedScreenContentRows,fRows)-1 do begin
  for Column:=0 to Min(fSavedScreenContentColumns,fColumns)-1 do begin
   Enqueue(fSavedScreenContent[(Row*fSavedScreenContentColumns)+Column],Column,Row);
  end;
 end;
 if fAutoFlush then begin
  Flush;
 end;
 fState:=fSavedScreenState;
end;

procedure TPasTerm.SGR;
var Index:TPasTermSizeInt;
    Offset:TPasTermSizeInt;
    Foreground:Boolean;
    RGBValue,Color:TPasTermUInt32;
begin

 Index:=0;

 if fCountEscapeValues=0 then begin
  if fState.ReverseVideo then begin
   fState.ReverseVideo:=false;
   SwapPalette;
  end;
  fState.ForegroundBold:=false;
  fState.BackgroundBold:=false;
  fState.CurrentForegroundColor:=-1;
  fState.CurrentBackgroundColor:=-1;
  SetTextForegroundColorDefault;
  SetTextBackgroundColorDefault;
 end;

 while Index<fCountEscapeValues do begin

  Offset:=0;
  case fEscapeValues[Index] of
   0:begin
    if fState.ReverseVideo then begin
     fState.ReverseVideo:=false;
     SwapPalette;
    end;
    fState.ForegroundBold:=false;
    fState.BackgroundBold:=false;
    fState.CurrentCharset:=-1;
    fState.CurrentForegroundColor:=-1;
    fState.CurrentBackgroundColor:=-1;
    SetTextForegroundColorDefault;
    SetTextBackgroundColorDefault;
    inc(Index);
    continue;
   end;

   1:begin
    fState.ForegroundBold:=true;
    if fState.CurrentForegroundColor>=0 then begin
     if fState.ReverseVideo then begin
      SetTextBackgroundColorBright(fState.CurrentForegroundColor);
     end else begin
      SetTextForegroundColorBright(fState.CurrentForegroundColor);
     end;
    end else begin
     if fState.ReverseVideo then begin
      SetTextBackgroundColorDefaultBright;
     end else begin
      SetTextForegroundColorDefaultBright;
     end;
    end;
    inc(Index);
    continue;
   end;

   5:begin
    fState.BackgroundBold:=true;
    if fState.CurrentBackgroundColor>=0 then begin
     if not fState.ReverseVideo then begin
      SetTextBackgroundColorBright(fState.CurrentBackgroundColor);
     end else begin
      SetTextForegroundColorBright(fState.CurrentBackgroundColor);
     end;
    end else begin
     if not fState.ReverseVideo then begin
      SetTextBackgroundColorDefaultBright;
     end else begin
      SetTextForegroundColorDefaultBright;
     end;
    end;
    inc(Index);
    continue;
   end;

   22:begin
    fState.ForegroundBold:=false;
    if fState.CurrentForegroundColor>=0 then begin
     if fState.ReverseVideo then begin
      SetTextBackgroundColor(fState.CurrentForegroundColor);
     end else begin
      SetTextForegroundColor(fState.CurrentForegroundColor);
     end;
    end else begin
     if fState.ReverseVideo then begin
      SetTextBackgroundColorDefault;
     end else begin
      SetTextForegroundColorDefault;
     end;
    end;
    inc(Index);
    continue;
   end;

   25:begin
    fState.BackgroundBold:=false;
    if fState.CurrentBackgroundColor>=0 then begin
     if fState.ReverseVideo then begin
      SetTextForegroundColor(fState.CurrentBackgroundColor);
     end else begin
      SetTextBackgroundColor(fState.CurrentBackgroundColor);
     end;
    end else begin
     if fState.ReverseVideo then begin
      SetTextForegroundColorDefault;
     end else begin
      SetTextBackgroundColorDefault;
     end;
    end;
    inc(Index);
    continue;
   end;

   30..37:begin
    Offset:=30;
    fState.CurrentForegroundColor:=fEscapeValues[Index]-Offset;
    if fState.ReverseVideo then begin
     if fState.ForegroundBold then begin
      SetTextBackgroundColorBright(fState.CurrentForegroundColor);
     end else begin
      SetTextBackgroundColor(fState.CurrentForegroundColor);
     end;
    end else begin
     if fState.ForegroundBold then begin
      SetTextForegroundColorBright(fState.CurrentForegroundColor);
     end else begin
      SetTextForegroundColor(fState.CurrentForegroundColor);
     end;
    end;
    inc(Index);
    continue;
   end;

   40..47:begin
    Offset:=40;
    fState.CurrentBackgroundColor:=fEscapeValues[Index]-Offset;
    if fState.ReverseVideo then begin
     if fState.BackgroundBold then begin
      SetTextForegroundColorBright(fState.CurrentBackgroundColor);
     end else begin
      SetTextForegroundColor(fState.CurrentBackgroundColor);
     end;
    end else begin
     if fState.BackgroundBold then begin
      SetTextBackgroundColorBright(fState.CurrentBackgroundColor);
     end else begin
      SetTextBackgroundColor(fState.CurrentBackgroundColor);
     end;
    end;
    inc(Index);
    continue;
   end;

   90..97:begin
    Offset:=90;
    fState.CurrentForegroundColor:=fEscapeValues[Index]-Offset;
    if fState.ReverseVideo then begin
     SetTextBackgroundColorBright(fState.CurrentForegroundColor);
    end else begin
     SetTextForegroundColorBright(fState.CurrentForegroundColor);
    end;
    inc(Index);
    continue;
   end;

   100..107:begin
    Offset:=100;
    fState.CurrentBackgroundColor:=fEscapeValues[Index]-Offset;
    if fState.ReverseVideo then begin
     SetTextForegroundColorBright(fState.CurrentBackgroundColor);
    end else begin
     SetTextBackgroundColorBright(fState.CurrentBackgroundColor);
    end;
    inc(Index);
    continue;
   end;

   39:begin
    fState.CurrentForegroundColor:=-1;
    if fState.ReverseVideo then begin
     SwapPalette;
    end;
    if fState.ForegroundBold then begin
     SetTextForegroundColorDefaultBright;
    end else begin
     SetTextForegroundColorDefault;
    end;
    if fState.ReverseVideo then begin
     SwapPalette;
    end;
    inc(Index);
    continue;
   end;

   49:begin
    fState.CurrentBackgroundColor:=-1;
    if fState.ReverseVideo then begin
     SwapPalette;
    end;
    if fState.BackgroundBold then begin
     SetTextBackgroundColorDefaultBright;
    end else begin
     SetTextBackgroundColorDefault;
    end;
    if fState.ReverseVideo then begin
     SwapPalette;
    end;
    inc(Index);
    continue;
   end;

   7:begin
    if not fState.ReverseVideo then begin
     fState.ReverseVideo:=true;
     SwapPalette;
    end;
    inc(Index);
    continue;
   end;

   27:begin
    if fState.ReverseVideo then begin
     fState.ReverseVideo:=false;
     SwapPalette;
    end;
    inc(Index);
    continue;
   end;

   38,48:begin

    Foreground:=fEscapeValues[Index]=38;

    inc(Index);
    if Index>=fCountEscapeValues then begin
     break;
    end;

    case fEscapeValues[Index] of
     2:begin
      if (Index+3)>=fCountEscapeValues then begin
       break;
      end;
      RGBValue:=(fEscapeValues[Index+1] shl 0) or (fEscapeValues[Index+2] shl 8) or (fEscapeValues[Index+3] shl 16);
      inc(Index,3);
      if Foreground then begin
       SetTextForegroundColorRGB(RGBValue);
      end else begin
       SetTextBackgroundColorRGB(RGBValue);
      end;
     end;
     5:begin
      if (Index+1)>=fCountEscapeValues then begin
       break;
      end;
      Color:=fEscapeValues[Index+1];
      inc(Index);
      if Color<8 then begin
       if Foreground then begin
        SetTextForegroundColor(Color);
       end else begin
        SetTextBackgroundColor(Color);
       end;
      end else if Color<16 then begin
       if Foreground then begin
        SetTextForegroundColorBright(Color-8);
       end else begin
        SetTextBackgroundColorBright(Color-8);
       end;
      end else if Color<256 then begin
       RGBValue:=Colors256[Color];
       if Foreground then begin
        SetTextForegroundColorRGB(RGBValue);
       end else begin
        SetTextBackgroundColorRGB(RGBValue);
       end;
      end;
     end;
    end;
    inc(Index);
    continue;
   end;

   else begin
    inc(Index);
    continue;
   end;

  end;

 end;

end;

procedure TPasTerm.ParseControlSequence(const aCodePoint:TPasTermUInt32);
var WasScrollEnabled,WillBeInScrollRegion,Active:Boolean;
    Column,Row,DefaultEscapeValue,Index,OriginalRow,DestRow,Count,OldScrollTopMargin:TPasTermSizeInt;
begin

 if fEscapeOffset=2 then begin
  case aCodePoint of
   ord('['):begin
    fDiscardNext:=true;
    fControlSequence:=false;
    fEscape:=false;
    exit;
   end;
   ord('?'):begin
    fDECPrivate:=true;
    exit;
   end;
  end;
 end;

 if (aCodePoint>=ord('0')) and (aCodePoint<=ord('9')) then begin
  if fCountEscapeValues=MaxCountEscapeValues then begin
   exit;
  end;
  fRRR:=true;
  fEscapeValues[fCountEscapeValues]:=(fEscapeValues[fCountEscapeValues]*10)+(aCodePoint-ord('0'));
  exit;
 end;

 if fRRR then begin
  inc(fCountEscapeValues);
  fRRR:=false;
  if aCodePoint=ord(';') then begin
   exit;
  end;
 end else if aCodePoint=ord(';') then begin
  if fCountEscapeValues=MaxCountEscapeValues then begin
   exit;
  end;
  fEscapeValues[fCountEscapeValues]:=0;
  inc(fCountEscapeValues);
  exit;
 end;

 case aCodePoint of
  ord('J'),ord('K'),ord('q'):begin
   DefaultEscapeValue:=0;
  end;
  else begin
   DefaultEscapeValue:=1;
  end;
 end;

 for Index:=fCountEscapeValues to MaxCountEscapeValues-1 do begin
  fEscapeValues[Index]:=DefaultEscapeValue;
 end;

 if fDECPrivate then begin
  // DEC
  fDECPrivate:=false;
  fControlSequence:=false;
  fEscape:=false;
  if (fCountEscapeValues<>0) and ((aCodePoint=ord('h')) or (aCodePoint=ord('l'))) then begin
   Active:=aCodePoint=ord('h');
   case fEscapeValues[0] of
    25:begin
     fCursorEnabled:=Active;
    end;
    1049:begin
     if Active then begin
      SaveScreen;
     end else begin
      RestoreScreen;
     end;
    end;
    else begin
     if assigned(fOnDEC) then begin
      fOnDEC(self,aCodePoint,fEscapeValues,fCountEscapeValues);
     end;
    end;
   end;
  end;
  exit;
 end;

 WasScrollEnabled:=fScrollEnabled;
 fScrollEnabled:=false;
 GetCursorPosition(Column,Row);

 case aCodePoint of
  ord('F'),ord('A'):begin
   if aCodePoint=ord('F') then begin
    Column:=0;
   end;
   if fEscapeValues[0]>Row then begin
    fEscapeValues[0]:=Row;
   end;
   OriginalRow:=Row;
   DestRow:=Row-fEscapeValues[0];
   WillBeInScrollRegion:=false;
   if ((fScrollTopMargin>=DestRow) and (fScrollTopMargin<=OriginalRow)) or ((fScrollBottomMargin>=DestRow) and (fScrollBottomMargin<=OriginalRow)) then begin
    WillBeInScrollRegion:=true;
   end;
   if WillBeInScrollRegion and (DestRow<fScrollTopMargin) then begin
    DestRow:=fScrollTopMargin;
   end;
   SetCursorPosition(Column,DestRow);
  end;
  ord('E'),ord('e'),ord('B'):begin
   if aCodePoint=ord('E') then begin
    Column:=0;
   end;
   if (Row+fEscapeValues[0])>(fRows-1) then begin
    fEscapeValues[0]:=(fRows-1)-Row;
   end;
   OriginalRow:=Row;
   DestRow:=Row+fEscapeValues[0];
   WillBeInScrollRegion:=false;
   if ((fScrollTopMargin>=OriginalRow) and (fScrollTopMargin<=DestRow)) or ((fScrollBottomMargin>=OriginalRow) and (fScrollBottomMargin<=DestRow)) then begin
    WillBeInScrollRegion:=true;
   end;
   if WillBeInScrollRegion and (DestRow>=fScrollBottomMargin) then begin
    DestRow:=fScrollBottomMargin-1;
   end;
   SetCursorPosition(Column,DestRow);
  end;
  ord('a'),ord('C'):begin
   if (Column+fEscapeValues[0])>(fColumns-1) then begin
    fEscapeValues[0]:=(fColumns-1)-Column;
   end;
   SetCursorPosition(Column+fEscapeValues[0],Row);
  end;
  ord('D'):begin
   if fEscapeValues[0]>Column then begin
    fEscapeValues[0]:=Column;
   end;
   SetCursorPosition(Column-fEscapeValues[0],Row);
  end;
  ord('c'):begin
   if assigned(fOnPrivateID) then begin
    fOnPrivateID(self,fEscapeValues[0]);
   end;
  end;
  ord('d'):begin
   dec(fEscapeValues[0]);
   if fEscapeValues[0]>=fRows then begin
    fEscapeValues[0]:=fRows-1;
   end;
   SetCursorPosition(Column,fEscapeValues[0]);
  end;
  ord('G'),ord('`'):begin
   dec(fEscapeValues[0]);
   if fEscapeValues[0]>=fColumns then begin
    fEscapeValues[0]:=fColumns-1;
   end;
   SetCursorPosition(fEscapeValues[0],Row);
  end;
  ord('H'),ord('f'):begin
   if fEscapeValues[0]<>0 then begin
    dec(fEscapeValues[0]);
   end;
   if fEscapeValues[1]<>0 then begin
    dec(fEscapeValues[1]);
   end;
   if fEscapeValues[1]>=fColumns then begin
    fEscapeValues[1]:=fColumns-1;
   end;
   if fEscapeValues[0]>=fRows then begin
    fEscapeValues[0]:=fRows-1;
   end;
   SetCursorPosition(fEscapeValues[1],fEscapeValues[0]);
  end;
  ord('M'):begin
   Count:=fEscapeValues[0];
   if Count>fRows then begin
    Count:=fRows;
   end;
   for Index:=0 to Count-1 do begin
    Scroll;
   end;
  end;
  ord('L'):begin
   OldScrollTopMargin:=fScrollTopMargin;
   fScrollTopMargin:=Row;
   Count:=fEscapeValues[0];
   if Count>fRows then begin
    Count:=fRows;
   end;
   for Index:=0 to Count-1 do begin
    ReverseScroll;
   end;
   fScrollTopMargin:=OldScrollTopMargin;
  end;
  ord('n'):begin
   case fEscapeValues[0] of
    5:begin
     if assigned(fOnStatusReport) then begin
      fOnStatusReport(self);
     end;
    end;
    6:begin
     if assigned(fOnPositionReport) then begin
      fOnPositionReport(self,Column,Row);
     end;
    end;
   end;
  end;
  ord('q'):begin
   if assigned(fOnKeyboardLEDs) then begin
    fOnKeyboardLEDs(self,fEscapeValues[0]);
   end;
  end;
  ord('J'):begin
   case fEscapeValues[0] of
    0:begin
     Count:=(((fRows-(Row+1))*fColumns)+((fColumns-(Column+1))))+1;
     for Index:=0 to Count-1 do begin
      OutputCodePoint($20);
     end;
     SetCursorPosition(Column,Row);
    end;
    1:begin
     SetCursorPosition(0,0);
     for Index:=0 to (Row*Columns)+Column do begin
      OutputCodePoint($20);
     end;
     SetCursorPosition(Column,Row);
    end;
    2:begin
     Clear(false);
     Refresh;
    end;
    3:begin
     // TODO: Scrollback stuff
     Clear(false);
     Refresh;
    end;
   end;
  end;
  ord('@'):begin
   for Index:=fColumns-1 downto 0 do begin
    MoveCharacter(Index+fEscapeValues[0],Row,Index,Row);
    SetCursorPosition(Index,Row);
    OutputCodePoint($20);
    if Index=Column then begin
     break;
    end;
   end;
   SetCursorPosition(Column,Row);
  end;
  ord('P'),ord('X'):begin
   if aCodePoint=ord('P') then begin
    for Index:=Column+fEscapeValues[0] to fColumns-1 do begin
     MoveCharacter(Index-fEscapeValues[0],Row,Index,Row);
    end;
    SetCursorPosition(fColumns-fEscapeValues[0],Row);
   end;
   Count:=fEscapeValues[0];
   if Count>fColumns then begin
    Count:=fColumns;
   end;
   for Index:=0 to Count-1 do begin
    OutputCodePoint($20);
   end;
   SetCursorPosition(Column,Row);
  end;
  ord('m'):begin
   SGR;
  end;
  ord('s'):begin
   GetCursorPosition(fSavedCursorX,fSavedCursorY);
  end;
  ord('u'):begin
   SetCursorPosition(fSavedCursorX,fSavedCursorY);
  end;
  ord('K'):begin
   case fEscapeValues[0] of
    0:begin
     for Index:=Column to fColumns-1 do begin
      OutputCodePoint($20);
     end;
     SetCursorPosition(Column,Row);
    end;
    1:begin
     SetCursorPosition(0,Row);
     for Index:=0 to Column-1 do begin
      OutputCodePoint($20);
     end;
    end;
    2:begin
     SetCursorPosition(0,Row);
     for Index:=0 to fColumns-1 do begin
      OutputCodePoint($20);
     end;
     SetCursorPosition(Column,Row);
    end;
   end;
  end;
  ord('r'):begin
   if fEscapeValues[0]=0 then begin
    fEscapeValues[0]:=1;
   end;
   if fEscapeValues[1]=0 then begin
    fEscapeValues[1]:=1;
   end;
   fScrollTopMargin:=0;
   fScrollBottomMargin:=fRows;
   if fCountEscapeValues>0 then begin
    fScrollTopMargin:=fEscapeValues[0]-1;
   end;
   if fCountEscapeValues>1 then begin
    fScrollBottomMargin:=fEscapeValues[1];
   end;
   if (fScrollTopMargin>=fRows) or (fScrollBottomMargin>fRows) or (fScrollTopMargin>=(fScrollBottomMargin-1)) then begin
    fScrollTopMargin:=0;
    fScrollBottomMargin:=fRows;
   end;
   SetCursorPosition(0,0);
  end;
  ord('l'),ord('h'):begin
   // Mode
   if (fCountEscapeValues<>0) and ((aCodePoint=ord('h')) or (aCodePoint=ord('l'))) then begin
    Active:=aCodePoint=ord('h');
    case fEscapeValues[0] of
     4:begin
      fInsertMode:=Active;
     end;
     else begin
      if assigned(fOnMode) then begin
       fOnMode(self,aCodePoint,fEscapeValues,fCountEscapeValues);
      end;
     end;
    end;
   end;
  end;
  ord(']'):begin
   // Linux
   if (fCountEscapeValues<>0) and assigned(fOnLinux) then begin
    fOnLinux(self,fEscapeValues,fCountEscapeValues);
   end;
  end;
  else begin
  end;
 end;

 fScrollEnabled:=WasScrollEnabled;

 fControlSequence:=false;
 fEscape:=false;

end;

procedure TPasTerm.DoSaveState;
begin
 fSavedState:=fState;
end;

procedure TPasTerm.DoRestoreState;
begin
 fState:=fSavedState;
end;

procedure TPasTerm.ParseEscape(const aCodePoint:TPasTermUInt32);
var x,y,Index:TPasTermSizeInt;
begin

 inc(fEscapeOffset);

 if fOSC then begin
  // OSC
  if fOSCEscape and (aCodePoint=ord('\')) then begin
   fOSCEscape:=false;
   fOSC:=false;
   fEscape:=false;
  end else begin
   fOSCEscape:=false;
   case aCodePoint of
    ord(#7):begin
     fOSC:=false;
     fEscape:=false;
    end;
    ord('R'):begin
     fOSC:=false;
     fEscape:=false;
    end;
    ord(#27):begin
     fOSCEscape:=true;
    end;
   end;
  end;
  exit;
 end;

 if fControlSequence then begin
  ParseControlSequence(aCodePoint);
  exit;
 end;

 GetCursorPosition(x,y);

 case aCodePoint of
  ord(']'):begin
   fOSCEscape:=false;
   fOSC:=true;
   exit;
  end;
  ord('['):begin
   for Index:=0 to MaxCountEscapeValues-1 do begin
    fEscapeValues[Index]:=0;
   end;
   fCountEscapeValues:=0;
   fRRR:=false;
   fControlSequence:=true;
   exit;
  end;
  ord('7'):begin
   DoSaveState;
  end;
  ord('8'):begin
   DoRestoreState;
  end;
  ord('c'):begin
   Reinit;
   Clear(true);
   Refresh;
  end;
  ord('D'):begin
   if y=(fScrollBottomMargin-1) then begin
    Scroll;
    SetCursorPosition(x,y);
   end else begin
    SetCursorPosition(x,y+1);
   end;
  end;
  ord('E'):begin
   if y=(fScrollBottomMargin-1) then begin
    Scroll;
    SetCursorPosition(0,y);
   end else begin
    SetCursorPosition(0,y+1);
   end;
  end;
  ord('M'):begin
   if y=fScrollTopMargin then begin
    ReverseScroll;
    SetCursorPosition(0,y);
   end else begin
    SetCursorPosition(0,y-1);
   end;
  end;
  ord('Z'):begin
   if assigned(fOnPrivateID) then begin
    fOnPrivateID(self,0);
   end;
  end;
  ord('('),ord(')'):begin
   fGSelect:=aCodePoint-ord('''');
  end;
  ord('%'):begin
   fCharsetSelect:=true;
  end;
  else begin
  end;
 end;

 fEscape:=false;

end;

class function TPasTerm.BinarySearch(const aUCS:TPasTermUInt32;const aIntervals:PIntervalArray;const aCount:TPasTermSizeInt):Boolean;
var Low,High,Mid:TPasTermSizeInt;
begin
 Low:=0;
 High:=aCount-1;
 if (aUCS<aIntervals[Low].First) or (aUCS>aIntervals[High].Last) then begin
  result:=false;
 end else begin
  while Low<=High do begin
   Mid:=Low+((High-Low) shr 1);
   if aUCS>aIntervals[Mid].Last then begin
    Low:=Mid+1;
   end else if aUCS<aIntervals[Mid].First then begin
    High:=Mid-1;
   end else begin
    result:=true;
    exit;
   end;
  end;
  result:=false;
 end;
end;

class function TPasTerm.WCWidth(const aUCS:TPasTermUInt32):TPasTermSizeInt;
const Intervals:array[0..141] of TInterval=
       (
        (First:$0300;Last:$036f),(First:$0483;Last:$0486),(First:$0488;Last:$0489),
        (First:$0591;Last:$05bd),(First:$05bf;Last:$05bf),(First:$05c1;Last:$05c2),
        (First:$05c4;Last:$05c5),(First:$05c7;Last:$05c7),(First:$0600;Last:$0603),
        (First:$0610;Last:$0615),(First:$064b;Last:$065e),(First:$0670;Last:$0670),
        (First:$06d6;Last:$06e4),(First:$06e7;Last:$06e8),(First:$06ea;Last:$06ed),
        (First:$070f;Last:$070f),(First:$0711;Last:$0711),(First:$0730;Last:$074a),
        (First:$07a6;Last:$07b0),(First:$07eb;Last:$07f3),(First:$0901;Last:$0902),
        (First:$093c;Last:$093c),(First:$0941;Last:$0948),(First:$094d;Last:$094d),
        (First:$0951;Last:$0954),(First:$0962;Last:$0963),(First:$0981;Last:$0981),
        (First:$09bc;Last:$09bc),(First:$09c1;Last:$09c4),(First:$09cd;Last:$09cd),
        (First:$09e2;Last:$09e3),(First:$0a01;Last:$0a02),(First:$0a3c;Last:$0a3c),
        (First:$0a41;Last:$0a42),(First:$0a47;Last:$0a48),(First:$0a4b;Last:$0a4d),
        (First:$0a70;Last:$0a71),(First:$0a81;Last:$0a82),(First:$0abc;Last:$0abc),
        (First:$0ac1;Last:$0ac5),(First:$0ac7;Last:$0ac8),(First:$0acd;Last:$0acd),
        (First:$0ae2;Last:$0ae3),(First:$0b01;Last:$0b01),(First:$0b3c;Last:$0b3c),
        (First:$0b3f;Last:$0b3f),(First:$0b41;Last:$0b43),(First:$0b4d;Last:$0b4d),
        (First:$0b56;Last:$0b56),(First:$0b82;Last:$0b82),(First:$0bc0;Last:$0bc0),
        (First:$0bcd;Last:$0bcd),(First:$0c3e;Last:$0c40),(First:$0c46;Last:$0c48),
        (First:$0c4a;Last:$0c4d),(First:$0c55;Last:$0c56),(First:$0cbc;Last:$0cbc),
        (First:$0cbf;Last:$0cbf),(First:$0cc6;Last:$0cc6),(First:$0ccc;Last:$0ccd),
        (First:$0ce2;Last:$0ce3),(First:$0d41;Last:$0d43),(First:$0d4d;Last:$0d4d),
        (First:$0dca;Last:$0dca),(First:$0dd2;Last:$0dd4),(First:$0dd6;Last:$0dd6),
        (First:$0e31;Last:$0e31),(First:$0e34;Last:$0e3a),(First:$0e47;Last:$0e4e),
        (First:$0eb1;Last:$0eb1),(First:$0eb4;Last:$0eb9),(First:$0ebb;Last:$0ebc),
        (First:$0ec8;Last:$0ecd),(First:$0f18;Last:$0f19),(First:$0f35;Last:$0f35),
        (First:$0f37;Last:$0f37),(First:$0f39;Last:$0f39),(First:$0f71;Last:$0f7e),
        (First:$0f80;Last:$0f84),(First:$0f86;Last:$0f87),(First:$0f90;Last:$0f97),
        (First:$0f99;Last:$0fbc),(First:$0fc6;Last:$0fc6),(First:$102d;Last:$1030),
        (First:$1032;Last:$1032),(First:$1036;Last:$1037),(First:$1039;Last:$1039),
        (First:$1058;Last:$1059),(First:$1160;Last:$11ff),(First:$135f;Last:$135f),
        (First:$1712;Last:$1714),(First:$1732;Last:$1734),(First:$1752;Last:$1753),
        (First:$1772;Last:$1773),(First:$17b4;Last:$17b5),(First:$17b7;Last:$17bd),
        (First:$17c6;Last:$17c6),(First:$17c9;Last:$17d3),(First:$17dd;Last:$17dd),
        (First:$180b;Last:$180d),(First:$18a9;Last:$18a9),(First:$1920;Last:$1922),
        (First:$1927;Last:$1928),(First:$1932;Last:$1932),(First:$1939;Last:$193b),
        (First:$1a17;Last:$1a18),(First:$1b00;Last:$1b03),(First:$1b34;Last:$1b34),
        (First:$1b36;Last:$1b3a),(First:$1b3c;Last:$1b3c),(First:$1b42;Last:$1b42),
        (First:$1b6b;Last:$1b73),(First:$1dc0;Last:$1dca),(First:$1dfe;Last:$1dff),
        (First:$200b;Last:$200f),(First:$202a;Last:$202e),(First:$2060;Last:$2063),
        (First:$206a;Last:$206f),(First:$20d0;Last:$20ef),(First:$302a;Last:$302f),
        (First:$3099;Last:$309a),(First:$a806;Last:$a806),(First:$a80b;Last:$a80b),
        (First:$a825;Last:$a826),(First:$fb1e;Last:$fb1e),(First:$fe00;Last:$fe0f),
        (First:$fe20;Last:$fe23),(First:$feff;Last:$feff),(First:$fff9;Last:$fffb),
        (First:$10a01;Last:$10a03),(First:$10a05;Last:$10a06),(First:$10a0c;Last:$10a0f),
        (First:$10a38;Last:$10a3a),(First:$10a3f;Last:$10a3f),(First:$1d167;Last:$1d169),
        (First:$1d173;Last:$1d182),(First:$1d185;Last:$1d18b),(First:$1d1aa;Last:$1d1ad),
        (First:$1d242;Last:$1d244),(First:$e0001;Last:$e0001),(First:$e0020;Last:$e007f),
        (First:$e0100;Last:$e01ef)
       );
begin
 case aUCS of
  0:Begin
   result:=0;
  end;
  1..32,$7f..$9f:begin
   result:=1;
  end;
  else begin
   if BinarySearch(aUCS,@Intervals,Length(Intervals)) then begin
    result:=0;
   end else begin
    case aUCS of
     $1100..$115f, // Hangul Jamo init. consonants
     $2329,$232a,
     $2e80..$303e,$3040..$a4cf, // CJK ... Yi
     $ac00..$d7a3, // Hangul Syllables
     $f900..$faff, // CJK Compatibility Ideographs
     $fe10..$fe19, // Vertical forms
     $fe30..$fe6f, // CJK Compatibility Forms
     $ff00..$ff60, // Fullwidth Forms
     $ffe0..$ffe6,
     $20000..$2fffd,
     $30000..$3fffd:begin
      result:=2;
     end;
     else begin
      result:=1;
     end;
    end;
   end;
  end;
 end;
end;

class function TPasTerm.UnicodeToCP437(const aCodePoint:TPasTermUInt64):TPasTermInt32;
begin
 case aCodePoint of
  $263a:begin
   result:=1;
  end;
  $263b:begin
   result:=2;
  end;
  $2665:begin
   result:=3;
  end;
  $2666:begin
   result:=4;
  end;
  $2663:begin
   result:=5;
  end;
  $2660:begin
   result:=6;
  end;
  $2022:begin
   result:=7;
  end;
  $25d8:begin
   result:=8;
  end;
  $25cb:begin
   result:=9;
  end;
  $25d9:begin
   result:=10;
  end;
  $2642:begin
   result:=11;
  end;
  $2640:begin
   result:=12;
  end;
  $266a:begin
   result:=13;
  end;
  $266b:begin
   result:=14;
  end;
  $263c:begin
   result:=15;
  end;
  $25ba:begin
   result:=16;
  end;
  $25c4:begin
   result:=17;
  end;
  $2195:begin
   result:=18;
  end;
  $203c:begin
   result:=19;
  end;
  $00b6:begin
   result:=20;
  end;
  $00a7:begin
   result:=21;
  end;
  $25ac:begin
   result:=22;
  end;
  $21a8:begin
   result:=23;
  end;
  $2191:begin
   result:=24;
  end;
  $2193:begin
   result:=25;
  end;
  $2192:begin
   result:=26;
  end;
  $2190:begin
   result:=27;
  end;
  $221f:begin
   result:=28;
  end;
  $2194:begin
   result:=29;
  end;
  $25b2:begin
   result:=30;
  end;
  $25bc:begin
   result:=31;
  end;
  $2302:begin
   result:=127;
  end;
  $00c7:begin
   result:=128;
  end;
  $00fc:begin
   result:=129;
  end;
  $00e9:begin
   result:=130;
  end;
  $00e2:begin
   result:=131;
  end;
  $00e4:begin
   result:=132;
  end;
  $00e0:begin
   result:=133;
  end;
  $00e5:begin
   result:=134;
  end;
  $00e7:begin
   result:=135;
  end;
  $00ea:begin
   result:=136;
  end;
  $00eb:begin
   result:=137;
  end;
  $00e8:begin
   result:=138;
  end;
  $00ef:begin
   result:=139;
  end;
  $00ee:begin
   result:=140;
  end;
  $00ec:begin
   result:=141;
  end;
  $00c4:begin
   result:=142;
  end;
  $00c5:begin
   result:=143;
  end;
  $00c9:begin
   result:=144;
  end;
  $00e6:begin
   result:=145;
  end;
  $00c6:begin
   result:=146;
  end;
  $00f4:begin
   result:=147;
  end;
  $00f6:begin
   result:=148;
  end;
  $00f2:begin
   result:=149;
  end;
  $00fb:begin
   result:=150;
  end;
  $00f9:begin
   result:=151;
  end;
  $00ff:begin
   result:=152;
  end;
  $00d6:begin
   result:=153;
  end;
  $00dc:begin
   result:=154;
  end;
  $00a2:begin
   result:=155;
  end;
  $00a3:begin
   result:=156;
  end;
  $00a5:begin
   result:=157;
  end;
  $20a7:begin
   result:=158;
  end;
  $0192:begin
   result:=159;
  end;
  $00e1:begin
   result:=160;
  end;
  $00ed:begin
   result:=161;
  end;
  $00f3:begin
   result:=162;
  end;
  $00fa:begin
   result:=163;
  end;
  $00f1:begin
   result:=164;
  end;
  $00d1:begin
   result:=165;
  end;
  $00aa:begin
   result:=166;
  end;
  $00ba:begin
   result:=167;
  end;
  $00bf:begin
   result:=168;
  end;
  $2310:begin
   result:=169;
  end;
  $00ac:begin
   result:=170;
  end;
  $00bd:begin
   result:=171;
  end;
  $00bc:begin
   result:=172;
  end;
  $00a1:begin
   result:=173;
  end;
  $00ab:begin
   result:=174;
  end;
  $00bb:begin
   result:=175;
  end;
  $2591:begin
   result:=176;
  end;
  $2592:begin
   result:=177;
  end;
  $2593:begin
   result:=178;
  end;
  $2502:begin
   result:=179;
  end;
  $2524:begin
   result:=180;
  end;
  $2561:begin
   result:=181;
  end;
  $2562:begin
   result:=182;
  end;
  $2556:begin
   result:=183;
  end;
  $2555:begin
   result:=184;
  end;
  $2563:begin
   result:=185;
  end;
  $2551:begin
   result:=186;
  end;
  $2557:begin
   result:=187;
  end;
  $255d:begin
   result:=188;
  end;
  $255c:begin
   result:=189;
  end;
  $255b:begin
   result:=190;
  end;
  $2510:begin
   result:=191;
  end;
  $2514:begin
   result:=192;
  end;
  $2534:begin
   result:=193;
  end;
  $252c:begin
   result:=194;
  end;
  $251c:begin
   result:=195;
  end;
  $2500:begin
   result:=196;
  end;
  $253c:begin
   result:=197;
  end;
  $255e:begin
   result:=198;
  end;
  $255f:begin
   result:=199;
  end;
  $255a:begin
   result:=200;
  end;
  $2554:begin
   result:=201;
  end;
  $2569:begin
   result:=202;
  end;
  $2566:begin
   result:=203;
  end;
  $2560:begin
   result:=204;
  end;
  $2550:begin
   result:=205;
  end;
  $256c:begin
   result:=206;
  end;
  $2567:begin
   result:=207;
  end;
  $2568:begin
   result:=208;
  end;
  $2564:begin
   result:=209;
  end;
  $2565:begin
   result:=210;
  end;
  $2559:begin
   result:=211;
  end;
  $2558:begin
   result:=212;
  end;
  $2552:begin
   result:=213;
  end;
  $2553:begin
   result:=214;
  end;
  $256b:begin
   result:=215;
  end;
  $256a:begin
   result:=216;
  end;
  $2518:begin
   result:=217;
  end;
  $250c:begin
   result:=218;
  end;
  $2588:begin
   result:=219;
  end;
  $2584:begin
   result:=220;
  end;
  $258c:begin
   result:=221;
  end;
  $2590:begin
   result:=222;
  end;
  $2580:begin
   result:=223;
  end;
  $03b1:begin
   result:=224;
  end;
  $00df:begin
   result:=225;
  end;
  $0393:begin
   result:=226;
  end;
  $03c0:begin
   result:=227;
  end;
  $03a3:begin
   result:=228;
  end;
  $03c3:begin
   result:=229;
  end;
  $00b5:begin
   result:=230;
  end;
  $03c4:begin
   result:=231;
  end;
  $03a6:begin
   result:=232;
  end;
  $0398:begin
   result:=233;
  end;
  $03a9:begin
   result:=234;
  end;
  $03b4:begin
   result:=235;
  end;
  $221e:begin
   result:=236;
  end;
  $03c6:begin
   result:=237;
  end;
  $03b5:begin
   result:=238;
  end;
  $2229:begin
   result:=239;
  end;
  $2261:begin
   result:=240;
  end;
  $00b1:begin
   result:=241;
  end;
  $2265:begin
   result:=242;
  end;
  $2264:begin
   result:=243;
  end;
  $2320:begin
   result:=244;
  end;
  $2321:begin
   result:=245;
  end;
  $00f7:begin
   result:=246;
  end;
  $2248:begin
   result:=247;
  end;
  $00b0:begin
   result:=248;
  end;
  $2219:begin
   result:=249;
  end;
  $00b7:begin
   result:=250;
  end;
  $221a:begin
   result:=251;
  end;
  $207f:begin
   result:=252;
  end;
  $00b2:begin
   result:=253;
  end;
  $25a0:begin
   result:=254;
  end;
  else begin
   result:=-1;
  end;
 end;
end;

procedure TPasTerm.Enqueue(const aCodePoint:TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt);
var Index,MapIndex:TPasTermSizeInt;
    CodePoint:PFrameBufferCodePoint;
begin
 if (aColumn>=0) and (aColumn<fColumns) and (aRow>=0) and (aRow<fRows) then begin
  Index:=(aRow*fColumns)+aColumn;
  MapIndex:=fContentQueueMap[Index];
  if MapIndex>=0 then begin
   fQueue.fItems[MapIndex].CodePoint:=aCodePoint;
  end else begin
   CodePoint:=@fContent[Index];
   if (CodePoint^.CodePoint<>aCodePoint.CodePoint) or
      (CodePoint^.ForegroundColor<>aCodePoint.ForegroundColor) or
      (CodePoint^.BackgroundColor<>aCodePoint.BackgroundColor) then begin
    MapIndex:=fQueue.Add(aCodePoint,aColumn,aRow);
    fContentQueueMap[Index]:=MapIndex;
   end;
  end;
 end;
end;

procedure TPasTerm.Clear(const aMove:Boolean);
var Row,Column:TPasTermSizeInt;
    Empty:TFrameBufferCodePoint;
begin
 Empty.CodePoint:=$20;
 Empty.ForegroundColor:=fState.TextForegroundColor;
 Empty.BackgroundColor:=fState.TextBackgroundColor;
 for Row:=0 to fRows-1 do begin
  for Column:=0 to fColumns-1 do begin
   Enqueue(Empty,Column,Row);
  end;
 end;
 if aMove then begin
  fState.CursorColumn:=0;
  fState.CursorRow:=0;
 end;
end;

procedure TPasTerm.OutputCodePoint(const aCodePoint:TPasTermUInt32);
var CodePoint:TFrameBufferCodePoint;
begin
 if (fState.CursorColumn>=fColumns) and ((fState.CursorRow<fScrollBottomMargin-1) or fScrollEnabled) then begin
  fState.CursorColumn:=0;
  inc(fState.CursorRow);
  if fState.CursorRow=fScrollBottomMargin then begin
   dec(fState.CursorRow);
   Scroll;
  end;
  if fState.CursorRow>=fColumns then begin
   fState.CursorRow:=fColumns-1;
  end;
 end;
 CodePoint.CodePoint:=aCodePoint;
 CodePoint.ForegroundColor:=fState.TextForegroundColor;
 CodePoint.BackgroundColor:=fState.TextBackgroundColor;
 Enqueue(CodePoint,fState.CursorColumn,fState.CursorRow);
 inc(fState.CursorColumn);
end;

function TPasTerm.GetCodePoint(const aColumn,aRow:TPasTermSizeInt;const aFlush:Boolean):TFrameBufferCodePoint;
var Index,MapIndex:TPasTermSizeInt;
begin
 if (aColumn>=0) and (aColumn<fColumns) and (aRow>=0) and (aRow<fRows) then begin
  Index:=(aRow*fColumns)+aColumn;
  MapIndex:=fContentQueueMap[Index];
  if MapIndex>=0 then begin
   result:=fQueue.fItems[MapIndex].CodePoint;
   if aFlush then begin
    fContent[Index]:=result;
    fContentQueueMap[Index]:=-1;
   end;
  end else begin
   result:=fContent[Index];
  end;
 end else begin
  result.CodePoint:=0;
  result.ForegroundColor:=fState.TextForegroundColor;
  result.BackgroundColor:=fState.TextBackgroundColor;
 end;
end;

procedure TPasTerm.SetCursorPosition(const aColumn,aRow:TPasTermSizeInt);
var x,y:TPasTermSizeInt;
begin
 x:=aColumn;
 y:=aRow;
 if x<0 then begin
  x:=0;
 end else if x>=fColumns then begin
  x:=fColumns-1;
 end;
 if y<0 then begin
  y:=0;
 end else if y>=fRows then begin
  y:=fRows-1;
 end;
 fState.CursorColumn:=x;
 fState.CursorRow:=y;
end;

procedure TPasTerm.GetCursorPosition(out aColumn,aRow:TPasTermSizeInt);
begin
 if fState.CursorColumn<0 then begin
  aColumn:=0;
 end else if fState.CursorColumn>=fColumns then begin
  aColumn:=fColumns-1;
 end else begin
  aColumn:=fState.CursorColumn;
 end;
 if fState.CursorRow<0 then begin
  aRow:=0;
 end else if fState.CursorRow>=fRows then begin
  aRow:=fRows-1;
 end else begin
  aRow:=fState.CursorRow;
 end;
end;

procedure TPasTerm.SetTextForegroundColor(const aFG:TPasTermUInt8);
begin
 fState.TextForegroundColor:=Colors256[aFG and 7];
end;

procedure TPasTerm.SetTextBackgroundColor(const aBG:TPasTermUInt8);
begin
 fState.TextBackgroundColor:=Colors256[aBG and 7];
end;

procedure TPasTerm.SetTextForegroundColorBright(const aFG:TPasTermUInt8);
begin
 fState.TextForegroundColor:=Colors256[(aFG and 7) or 8];
end;

procedure TPasTerm.SetTextBackgroundColorBright(const aBG:TPasTermUInt8);
begin
 fState.TextBackgroundColor:=Colors256[(aBG and 7) or 8];
end;

procedure TPasTerm.SetTextForegroundColorRGB(const aFG:TPasTermUInt32);
begin
 fState.TextForegroundColor:=aFG;
end;

procedure TPasTerm.SetTextBackgroundColorRGB(const aBG:TPasTermUInt32);
begin
 fState.TextBackgroundColor:=aBG;
end;

procedure TPasTerm.SetTextForegroundColorDefault;
begin
 fState.TextForegroundColor:=Colors256[7];
end;

procedure TPasTerm.SetTextBackgroundColorDefault;
begin
 fState.TextBackgroundColor:=Colors256[0];
end;

procedure TPasTerm.SetTextForegroundColorDefaultBright;
begin
 fState.TextForegroundColor:=Colors256[15];
end;

procedure TPasTerm.SetTextBackgroundColorDefaultBright;
begin
 fState.TextBackgroundColor:=Colors256[0]; // even if it is bright, keep it black
end;

procedure TPasTerm.MoveCharacter(const aNewColumn,aNewRow,aOldColumn,aOldRow:TPasTermSizeInt);
var Index:TPasTermSizeInt;
    QueueItem:PFrameBufferQueueItem;
    CodePoint:TFrameBufferCodePoint;
begin
 if (aOldColumn>=0) and (aOldColumn<fColumns) and (aOldRow>=0) and (aOldRow<fRows) and
    (aNewColumn>=0) and (aNewColumn<fColumns) and (aNewRow>=0) and (aNewRow<fRows) then begin
  Index:=(aOldRow*fColumns)+aOldColumn;
  if fContentQueueMap[Index]<0 then begin
   CodePoint:=fContent[Index];
  end else begin
   QueueItem:=fQueue.Get(fContentQueueMap[Index]);
   CodePoint:=QueueItem^.CodePoint;
  end;
  Enqueue(CodePoint,aNewColumn,aNewRow);
 end;
end;

procedure TPasTerm.Scroll;
var Index,MapIndex:TPasTermSizeInt;
    QueueItem:PFrameBufferQueueItem;
    Empty:TFrameBufferCodePoint;
    CodePoint:TFrameBufferCodePoint;
begin
 for Index:=(fScrollTopMargin+1)*fColumns to (fScrollBottomMargin*fColumns)-1 do begin
  MapIndex:=fContentQueueMap[Index];
  if MapIndex<0 then begin
   CodePoint:=fContent[Index];
  end else begin
   QueueItem:=fQueue.Get(MapIndex);
   CodePoint:=QueueItem^.CodePoint;
  end;
  Enqueue(CodePoint,(Index-fColumns) mod fColumns,(Index-fColumns) div fColumns);
 end;
 Empty.CodePoint:=$20;
 Empty.ForegroundColor:=fState.TextForegroundColor;
 Empty.BackgroundColor:=fState.TextBackgroundColor;
 for Index:=0 to fColumns-1 do begin
  Enqueue(Empty,Index,fScrollBottomMargin-1);
 end;
end;

procedure TPasTerm.ReverseScroll;
var Index,MapIndex:TPasTermSizeInt;
    QueueItem:PFrameBufferQueueItem;
    Empty:TFrameBufferCodePoint;
    CodePoint:TFrameBufferCodePoint;
begin
 for Index:=((fScrollBottomMargin-1)*fColumns)-1 downto fScrollTopMargin*fColumns do begin
  if Index<0 then begin
   break;
  end;
  MapIndex:=fContentQueueMap[Index];
  if MapIndex<0 then begin
   CodePoint:=fContent[Index];
  end else begin
   QueueItem:=fQueue.Get(MapIndex);
   CodePoint:=QueueItem^.CodePoint;
  end;
  Enqueue(CodePoint,(Index+fColumns) mod fColumns,(Index+fColumns) div fColumns);
 end;
 Empty.CodePoint:=$20;
 Empty.ForegroundColor:=fState.TextForegroundColor;
 Empty.BackgroundColor:=fState.TextBackgroundColor;
 for Index:=0 to fColumns-1 do begin
  Enqueue(Empty,Index,fScrollTopMargin);
 end;
end;

procedure TPasTerm.SwapPalette;
var Temporary:TPasTermUInt32;
begin
 Temporary:=fState.TextForegroundColor;
 fState.TextForegroundColor:=fState.TextBackgroundColor;
 fState.TextBackgroundColor:=Temporary;
end;

procedure TPasTerm.SaveState;
begin
end;

procedure TPasTerm.RestoreState;
begin
end;

procedure TPasTerm.Flush;
var Index,Offset:TPasTermSizeInt;
    QueueItem:PFrameBufferQueueItem;
    CodePoint:PFrameBufferCodePoint;
begin

 if fCursorEnabled and assigned(fOnDrawCursor) then begin
  fOnDrawCursor(self,fState.CursorColumn,fState.CursorRow);
 end;

 for Index:=0 to fQueue.fFillIndex-1 do begin
  QueueItem:=@fQueue.fItems[Index];
  Offset:=(QueueItem^.Row*fColumns)+QueueItem^.Column;
  if fContentQueueMap[Offset]>=0 then begin
   fContentQueueMap[Offset]:=-1;
   CodePoint:=@fContent[Offset];
   if assigned(fOnDrawCodePointMasked) and
      (QueueItem^.CodePoint.BackgroundColor=CodePoint^.BackgroundColor) and
      (QueueItem^.CodePoint.ForegroundColor=CodePoint^.ForegroundColor) then begin
    fOnDrawCodePointMasked(self,QueueItem^.CodePoint,CodePoint^,QueueItem^.Column,QueueItem^.Row);
   end else if assigned(fOnDrawCodePoint) then begin
    fOnDrawCodePoint(self,QueueItem^.CodePoint,QueueItem^.Column,QueueItem^.Row);
   end;
   CodePoint^:=QueueItem^.CodePoint;
  end;
 end;
 fQueue.fFillIndex:=0;

 if ((fOldCursorColumn<>fState.CursorColumn) or (fOldCursorRow<>fState.CursorRow) or not fCursorEnabled) and
    ((fOldCursorColumn>=0) and (fOldCursorColumn<fColumns) and (fOldCursorRow>=0) and (fOldCursorRow<fRows)) and
    assigned(fOnDrawCodePoint) then begin
  fOnDrawCodePoint(self,fContent[(fOldCursorRow*fColumns)+fOldCursorColumn],fOldCursorColumn,fOldCursorRow);
 end;


 fOldCursorColumn:=fState.CursorColumn;
 fOldCursorRow:=fState.CursorRow;

end;

procedure TPasTerm.Refresh;
var Index,Offset,Column,Row:TPasTermSizeInt;
    QueueItem:PFrameBufferQueueItem;
    CodePoint:TFrameBufferCodePoint;
begin

 for Index:=0 to fQueue.fFillIndex-1 do begin
  QueueItem:=@fQueue.fItems[Index];
  Offset:=(QueueItem^.Row*fColumns)+QueueItem^.Column;
  if fContentQueueMap[Offset]>=0 then begin
   fContentQueueMap[Offset]:=-1;
   fContent[Offset]:=QueueItem^.CodePoint;
  end;
 end;
 fQueue.fFillIndex:=0;

 if assigned(fOnDrawBackground) then begin
  fOnDrawBackground(self);
 end;

 if assigned(fOnDrawCodePoint) then begin
  Index:=0;
  for Column:=0 to fColumns-1 do begin
   for Row:=0 to fRows-1 do begin
    CodePoint:=fContent[Index];
    fOnDrawCodePoint(self,CodePoint,Column,Row);
    inc(Index);
   end;
  end;
 end;

 if fCursorEnabled and assigned(fOnDrawCursor) then begin
  fOnDrawCursor(self,fState.CursorColumn,fState.CursorRow);
 end;

end;

procedure TPasTerm.ProcessCodePoint(const aCodePoint:TPasTermUInt32);
var Index,Column,Row,ReplacementWidth:TPasTermSizeInt;
    CodePoint:TPasTermUInt32;
    TranslatedCodePoint:TPasTermInt32;
begin

 if fDiscardNext or ((aCodePoint=$18) or (aCodePoint=$1a)) then begin
  fDiscardNext:=false;
  fEscape:=false;
  fControlSequence:=false;
  fUTF8DecoderBufferIndex:=0;
  fUTF8DecoderState:=UTF8DecoderStateAccept;
  fUTF8DecoderValue:=0;
  fOSC:=false;
  fOSCEscape:=false;
  fGSelect:=0;
  fCharsetSelect:=false;
  exit;
 end;

 if fEscape then begin
  ParseEscape(aCodePoint);
  exit;
 end;

 if fCharsetSelect then begin
  fCharsetSelect:=false;
  case aCodePoint of
   ord('G'):begin
    fInputEncodingMode:=TInputEncodingMode.UTF8;
   end;
   ord('@'):begin
    fInputEncodingMode:=TInputEncodingMode.Raw;
   end;
  end;
  exit;
 end;

 if fGSelect<>0 then begin
  dec(fGSelect);
  case aCodePoint of
   ord('B'):begin
    fCharsets[fGSelect]:=TCharset.UTF8_Latin1;
   end;
   ord('0'):begin
    fCharsets[fGSelect]:=TCharset.VT100;
   end;
  end;
  fGSelect:=0;
  exit;
 end;

 GetCursorPosition(Column,Row);

 case aCodePoint of
  $00,$7f:begin
   exit;
  end;
  $1b:begin
   fEscapeOffset:=0;
   fEscape:=true;
   exit;
  end;
  ord(#9):begin
   if ((Column div fTabSize)+1)>=fColumns then begin
    SetCursorPosition(fColumns-1,Row);
   end else begin
    SetCursorPosition(((Column div fTabSize)+1)*fTabSize,Row);
   end;
   exit;
  end;
  $0b,$0c,$0a:begin
   if Row=(fScrollBottomMargin-1) then begin
    Scroll;
    if (fFlags and FLAG_ONLCR)<>0 then begin
     SetCursorPosition(0,Row);
    end else begin
     SetCursorPosition(Column,Row);
    end;
   end else begin
    if (fFlags and FLAG_ONLCR)<>0 then begin
     SetCursorPosition(0,Row+1);
    end else begin
     SetCursorPosition(Column,Row+1);
    end;
   end;
   exit;
  end;
  $08:begin
   SetCursorPosition(Column-1,Row);
   exit;
  end;
  $0d:begin
   SetCursorPosition(0,Row);
   exit;
  end;
  $07:begin
   if assigned(fOnBell) then begin
    fOnBell(self);
   end;
   exit;
  end;
  $0e:begin
   fState.CurrentCharset:=1;
   exit;
  end;
  $0f:begin
   fState.CurrentCharset:=0;
   exit;
  end;
  else begin
  end;
 end;

 if fInsertMode then begin
  for Index:=fColumns-1 downto 0 do begin
   MoveCharacter(Index+1,Row,Index,Row);
   if Index=Column then begin
    break;
   end;
  end;
 end;

 if aCodePoint<$100 then begin
  case fCharsets[fState.CurrentCharset] of
   TCharset.VT100:begin
    CodePoint:=TranslationMaps[MAP_VT100,aCodePoint and $ff];
   end;
   TCharset.CP437:begin
    CodePoint:=TranslationMaps[MAP_CP437,aCodePoint and $ff];
   end;
   TCharset.User:begin
    CodePoint:=TranslationMaps[MAP_USER,aCodePoint and $ff];
   end;
   else{TCharset.Latin1:}begin
    CodePoint:=aCodePoint;
   end;
  end;
 end else begin
  CodePoint:=aCodePoint;
 end;

 case fOutputEncodingMode of

  TOutputEncodingMode.ASCII:begin
   if aCodePoint>=$80 then begin
    ReplacementWidth:=WCWidth(aCodePoint);
    if ReplacementWidth>0 then begin
     ProcessCodePoint(ord('?'));
    end;
    for Index:=1 to ReplacementWidth-1 do begin
     ProcessCodePoint($20);
    end;
   end else begin
    ProcessCodePoint(CodePoint);
   end;
  end;

  TOutputEncodingMode.Latin1:begin
   if aCodePoint>=$100 then begin
    ReplacementWidth:=WCWidth(aCodePoint);
    if ReplacementWidth>0 then begin
     ProcessCodePoint(ord('?'));
    end;
    for Index:=1 to ReplacementWidth-1 do begin
     ProcessCodePoint($20);
    end;
   end else begin
    ProcessCodePoint(CodePoint);
   end;
  end;

  TOutputEncodingMode.CP437:begin
   TranslatedCodePoint:=UnicodeToCP437(CodePoint);
   if TranslatedCodePoint<0 then begin
    ReplacementWidth:=WCWidth(CodePoint);
    if ReplacementWidth>0 then begin
     ProcessCodePoint($fe);
    end;
    for Index:=1 to ReplacementWidth-1 do begin
     ProcessCodePoint($20);
    end;
   end else begin
    ProcessCodePoint(TranslatedCodePoint);
   end;
  end;

  else{TOutputEncodingMode.Unicode:}begin

   OutputCodePoint(CodePoint);

  end;
 end;

end;

procedure TPasTerm.TranslateCodePoint(const aCodePoint:TPasTermUInt32);
begin
 ProcessCodePoint(aCodePoint);
end;

function TPasTerm.DecodeCodePoint(const aCodePoint:TPasTermUInt32):Boolean;
var Index:TPasTermSizeInt;
    Value,CharClass:TPasTermUInt32;
begin

 case fInputEncodingMode of

  TInputEncodingMode.Raw:begin
   TranslateCodePoint(aCodePoint);
   result:=true;
  end;

  else {TInputEncodingMode.UTF8:}begin

   if aCodePoint<$80 then begin

    TranslateCodePoint(aCodePoint);

    result:=true;

   end else begin

    if fUTF8DecoderBufferIndex<UTF8DecoderBufferSize then begin

     fUTF8DecoderBuffer[fUTF8DecoderBufferIndex]:=aCodePoint;
     inc(fUTF8DecoderBufferIndex);

     Value:=aCodePoint and $ff;
     CharClass:=UTF8DFACharClasses[Value];
     if fUTF8DecoderState=UTF8DecoderStateAccept then begin
      fUTF8DecoderValue:=Value and ($ff shr CharClass);
     end else begin
      fUTF8DecoderValue:=(fUTF8DecoderValue shl 6) or (Value and $3f);
     end;
     fUTF8DecoderState:=UTF8DFATransitions[fUTF8DecoderState+CharClass];

    end else begin

     fUTF8DecoderState:=UTF8DecoderStateError;

    end;

    case fUTF8DecoderState of

     UTF8DecoderStateAccept:begin

      fUTF8DecoderBufferIndex:=0;

      TranslateCodePoint(fUTF8DecoderValue);

      result:=true;

     end;

     1..UTF8DecoderStateError:begin

      TranslateCodePoint(fUTF8DecoderBuffer[0]);

      if fUTF8DecoderBufferIndex>1 then begin
       for Index:=1 to fUTF8DecoderBufferIndex-1 do begin
        fUTF8MissingBuffer:=fUTF8MissingBuffer+AnsiChar(fUTF8DecoderBuffer[Index]);
       end;
      end;

      fUTF8DecoderBufferIndex:=0;
      fUTF8DecoderState:=UTF8DecoderStateAccept;
      fUTF8DecoderValue:=0;

      result:=false;

     end;

     else begin

      result:=true;

     end;

    end;

   end;

  end;

 end;

end;

procedure TPasTerm.WriteCodePoint(const aCodePoint:TPasTermUInt32);
var Index:TPasTermSizeInt;
    MissingBuffer:TPasTermRawByteString;
begin
 case fInputEncodingMode of
  TInputEncodingMode.Raw:begin
   DecodeCodePoint(aCodePoint);
  end;
  else {TInputEncodingMode.UTF8:}begin
   DecodeCodePoint(aCodePoint);
   while length(fUTF8MissingBuffer)>0 do begin
    MissingBuffer:=fUTF8MissingBuffer;
    fUTF8MissingBuffer:='';
    for Index:=1 to length(MissingBuffer) do begin
     if not DecodeCodePoint(TPasTermUInt8(TPasTermRawByteChar(MissingBuffer[Index]))) then begin
      if Index<length(MissingBuffer) then begin
       fUTF8MissingBuffer:=fUTF8MissingBuffer+copy(MissingBuffer,Index+1,length(MissingBuffer)-Index);
      end;
      break;
     end;
    end;
   end;
  end;
 end;
end;

procedure TPasTerm.Write(const aData:Pointer;const aCount:TPasTermSizeInt);
var Index:TPasTermSizeInt;
begin
 for Index:=0 to aCount-1 do begin
  WriteCodePoint(PPasTermUInt8Array(aData)^[Index]);
 end;
 if fAutoFlush then begin
  Flush;
 end;
end;

procedure TPasTerm.Write(const aString:TPasTermRawByteString);
begin
 if length(aString)>0 then begin
  Write(@aString[1],length(aString));
 end;
end;

procedure TPasTerm.Write(const aChar:AnsiChar);
begin
 WriteCodePoint(ord(aChar));
 if fAutoFlush then begin
  Flush;
 end;
end;

procedure TPasTerm.NewLine;
begin
 Write(#13#10);
end;

end.
