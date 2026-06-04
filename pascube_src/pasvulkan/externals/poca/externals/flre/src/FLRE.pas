(*******************************************************************************
                                 L I C E N S E
********************************************************************************

FLRE - Fast Light Regular Expressions - A fast light regular expression library
Copyright (C) 2015-2025, Benjamin 'BeRo' Rosseaux

The source code of the FLRE engine library and helper tools are
distributed under the Library GNU Lesser General Public License Version 2.1 
(see the files COPYING and COPYING.FLRE) with the following modification:

As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent modules,
and to copy and distribute the resulting executable under terms of your choice,
provided that you also meet, for each linked independent module, the terms
and conditions of the license of that module. An independent module is a module
which is not derived from or based on this library. If you modify this
library, you may extend this exception to your version of the library, but you
are not obligated to do so. If you do not wish to do so, delete this exception
statement from your version.

If you didn't receive a copy of the license, see <http://www.gnu.org/licenses/>
or contact:
      Free Software Foundation
      675 Mass Ave
      Cambridge, MA  02139
      USA

*******************************************************************************)
unit FLRE;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
 {$endif}
 {$ifdef cpu386}
  {$define cpux86}
  {$define cpu32}
  {$asmmode intel}
 {$endif}
 {$ifdef cpux86_64}
  {$define cpux64}
  {$define cpu64}
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
 {$define HasAdvancedRecords}
 {$define NewCompiler}
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
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$ifdef cpux64}
  {$define cpux86_64}
  {$define cpu64}
 {$else}
  {$ifdef cpu386}
   {$define cpux86}
   {$define cpu32}
  {$endif}
 {$endif}
 {$undef CanInline}
 {$undef HasAdvancedRecords}
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
   {$define CanInline}
   {$define HasAdvancedRecords}
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
   {$define NewCompiler}
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
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
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
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
  {$undef HAS_TYPE_UTF8STRING}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64) or defined(WinCE)}
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
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{-$define UseOpcodeJMP}

interface

uses {$ifdef windows}Windows,{$endif}{$ifdef unix}dl,BaseUnix,Unix,UnixType,{$endif}SysUtils,Classes,PUCU;

const FLREVersion=$00000006;

      FLREVersionString='1.00.2025.11.28.22.41.0000';

      FLREMaxPrefixCharClasses=32;

      FLREMinNativeCodeBlockContainerSize=1048576;

      carfIGNORECASE=1 shl 0;
      carfSINGLELINE=1 shl 1;
      carfMULTILINE=1 shl 2;
      carfFREESPACING=1 shl 3;
      carfNAMED=1 shl 4;
      carfNOCAPTURES=1 shl 5;
      carfUNGREEDY=1 shl 6;
      carfLONGEST=1 shl 7;
      carfMULTIMATCH=1 shl 8;
      carfUTF8=1 shl 9;
      carfONLYFASTOPTIMIZATIONS=1 shl 10;
      carfDELIMITERS=1 shl 11;

type EFLRE=class(Exception);

     PFLREInt8=^TFLREInt8;
     TFLREInt8={$if declared(Int8)}Int8{$else}ShortInt{$ifend};

     PFLREUInt8=^TFLREUInt8;
     TFLREUInt8={$if declared(UInt8)}UInt8{$else}Byte{$ifend};

     PFLREInt16=^TFLREInt16;
     TFLREInt16={$if declared(Int16)}Int16{$else}SmallInt{$ifend};

     PFLREUInt16=^TFLREUInt16;
     TFLREUInt16={$if declared(UInt16)}UInt16{$else}Word{$ifend};

     PFLREInt32=^TFLREInt32;
     TFLREInt32={$if declared(Int32)}Int32{$else}LongInt{$ifend};

     PFLREUInt32=^TFLREUInt32;
     TFLREUInt32={$if declared(UInt32)}UInt32{$else}LongWord{$ifend};

     PFLREInt64=^TFLREInt64;
     TFLREInt64=Int64;

     PFLREUInt64=^TFLREUInt64;
     TFLREUInt64={$if declared(UInt64)}UInt64{$else}QWord{$ifend};

     PFLRENativeInt=^TFLRENativeInt;
     TFLRENativeInt={$if declared(PtrInt)}PtrInt{$elseif defined(NewCompiler) and declared(NativeInt)}NativeInt{$else}TFLREInt32{$ifend};

     PFLRENativeUInt=^TFLRENativeUInt;
     TFLRENativeUInt={$if declared(PtrUInt)}PtrUInt{$elseif defined(NewCompiler) and declared(NativeUInt)}NativeUInt{$else}TFLREUInt32{$ifend};

     PFLRESizeInt=^TFLRESizeInt;
     TFLRESizeInt={$if declared(PtrInt)}PtrInt{$elseif defined(NewCompiler) and declared(NativeInt)}NativeInt{$else}TFLREInt32{$ifend};

     PFLRESizeUInt=^TFLRESizeUInt;
     TFLRESizeUInt={$if declared(PtrUInt)}PtrUInt{$elseif defined(NewCompiler) and declared(NativeUInt)}NativeUInt{$else}TFLREUInt32{$ifend};

     PFLREPtrInt=^TFLREPtrInt;
     TFLREPtrInt={$if declared(PtrInt)}PtrInt{$elseif defined(NewCompiler) and declared(NativeInt)}NativeInt{$else}TFLREInt32{$ifend};

     PFLREPtrUInt=^TFLREPtrUInt;
     TFLREPtrUInt={$if declared(PtrUInt)}PtrUInt{$elseif defined(NewCompiler) and declared(NativeUInt)}NativeUInt{$else}TFLREUInt32{$ifend};

     TFLREUTF8String={$ifdef HAS_TYPE_UTF8STRING}UTF8String{$else}AnsiString{$endif};

     TFLRERawByteString={$ifdef HAS_TYPE_RAWBYTESTRING}RawByteString{$else}AnsiString{$endif};

     PFLRERawByteChar=PAnsiChar;
     TFLRERawByteChar=AnsiChar;

     PFLRERawByteCharSet=^TFLRERawByteCharSet;
     TFLRERawByteCharSet=Set of AnsiChar;

     PFLREQWord=^TFLREQWord;
     TFLREQWord={$ifdef fpc}qword{$else}{$if Declared(CompilerVersion) and (CompilerVersion>=23.0)}TFLREUInt64{$else}TFLREInt64{$ifend}{$endif};

     PFLREParallelLock=^TFLREParallelLock;
     TFLREParallelLock=TFLREInt32;

     TFLREPointerList={$ifdef fpc}TFPList{$else}TList{$endif};

     TFLRE=class;

     PFLREFlag=^TFLREFlag;
     TFLREFlag=(rfIGNORECASE,
                rfSINGLELINE,
                rfMULTILINE,
                rfFREESPACING,
                rfNAMED,
                rfNOCAPTURES,
                rfUNGREEDY,
                rfLONGEST,
                rfMULTIMATCH,
                rfUTF8,
                rfONLYFASTOPTIMIZATIONS,
                rfDELIMITERS);

     PFLREMatchMode=^TFLREMatchMode;
     TFLREMatchMode=(mmFirstMatch,
                     mmLongestMatch,
                     mmFullMatch,
                     mmMultiMatch);

     TFLREFlags=set of TFLREFlag;

     PFLRECapture=^TFLRECapture;
     TFLRECapture=record
      Start:TFLRESizeInt;
      Length:TFLRESizeInt;
     end;

     TFLRECaptures=array of TFLRECapture;

     TFLREMultiCaptures=array of TFLRECaptures;

     TFLREStrings=array of TFLRERawByteString;

     TFLREMultiStrings=array of TFLREStrings;

     PFLRECharClass=^TFLRECharClass;
     TFLRECharClass=set of TFLRERawByteChar;

     TPFLRECharClasses=array of PFLRECharClass;

     PFLRECharRange=^TFLRECharRange;
     TFLRECharRange=record
      FromChar:TFLRERawByteChar;
      ToChar:TFLRERawByteChar;
     end;

     TFLRECharRanges=array of TFLRECharRange;

     TFLRECharClassChars=array of TFLRERawByteChar;

     TFLREReplacementCallback=function(const Data:pointer;const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt;const Captures:TFLRECaptures):TFLRERawByteString;

     TFLREReplacementObjectCallback=function(const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt;const Captures:TFLRECaptures):TFLRERawByteString of object;

     TFLREReplacementExternalCallback=function(const Data:pointer;const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt;const Captures:Pointer;const CountCaptures:TFLRESizeInt;const Replacement:PPAnsiChar;const ReplacementLength:PFLRESizeInt):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}

     PPFLRENode=^PFLRENode;
     PFLRENode=^TFLRENode;
     TFLRENode=record
      NodeType:TFLREInt32;
      Value:TFLREInt32;
      Flags:TFLREUInt32;
      Group:TFLREInt32;
      Left:PFLRENode;
      Right:PFLRENode;
      Index:TFLREInt32;
      Name:TFLRERawByteString;
     end;

     TFLRELookAssertionString=TFLRERawByteString;

     TFLRELookAssertionStrings=array of TFLRELookAssertionString;

     TFLREInternalFlag=(fifCanMatchEmptyStrings,
                        fifOnePassNFAReady,
                        fifBitStateNFAReady,
                        fifDFAReady,
                        fifDFANeedVerification,
                        fifDFAFast,
                        fifDFAFastBeginningSearch,
                        fifBeginTextAnchor,
                        fifEndTextAnchor,
                        fifBeginningWildcardLoop,
                        fifHasWordBoundaries,
                        fifHasNewLineAssertions,
                        fifHasLookAssertions,
                        fifHasBackReferences,
                        fifHaveUnanchoredStart,
                        fifHasRange,
                        fifHasPrefilter);

     TFLREInternalFlags=set of TFLREInternalFlag;

     PPFLREInstruction=^PFLREInstruction;
     PFLREInstruction=^TFLREInstruction;
     TFLREInstruction=record
      IDandOpcode:TFLREPtrInt;
      Value:TFLREPtrInt;
      Next:PFLREInstruction;
      OtherNext:PFLREInstruction;
     end;

     TFLREInstructions=array of TFLREInstruction;

     TPFLREInstructions=array of PFLREInstruction;

     PPFLREInstructionsStatic=^TPFLREInstructionsStatic;
     TPFLREInstructionsStatic=array[0..65535] of PFLREInstruction;

     TFLRECapturesToSubMatchesMap=array of TFLREInt32;

     PFLRENativeCodeMemoryManagerBlock=^TFLRENativeCodeMemoryManagerBlock;
     TFLRENativeCodeMemoryManagerBlock=packed record
      Signature:TFLREPtrUInt;
      Previous:PFLRENativeCodeMemoryManagerBlock;
      Next:PFLRENativeCodeMemoryManagerBlock;
      Size:TFLREPtrUInt;
     end;

     PFLRENativeCodeMemoryManagerBlockContainer=^TFLRENativeCodeMemoryManagerBlockContainer;
     TFLRENativeCodeMemoryManagerBlockContainer=record
      Previous:PFLRENativeCodeMemoryManagerBlockContainer;
      Next:PFLRENativeCodeMemoryManagerBlockContainer;
      Base:pointer;
      Size:TFLREPtrUInt;
      Used:TFLREPtrUInt;
      First:PFLRENativeCodeMemoryManagerBlock;
      Last:PFLRENativeCodeMemoryManagerBlock;
     end;

     TFLRENativeCodeMemoryManager=class
      private
       PageSize:TFLREPtrUInt;
       Alignment:TFLREPtrUInt;
       function AllocateBlockContainer(BlockContainerSize:TFLREPtrUInt):PFLRENativeCodeMemoryManagerBlockContainer;
       procedure FreeBlockContainer(BlockContainer:PFLRENativeCodeMemoryManagerBlockContainer);
      public
       First:PFLRENativeCodeMemoryManagerBlockContainer;
       Last:PFLRENativeCodeMemoryManagerBlockContainer;
       constructor Create;
       destructor Destroy; override;
       function GetMemory(Size:TFLREPtrUInt):pointer;
       procedure FreeMemory(p:pointer);
       function ReallocMemory(p:pointer;Size:TFLREPtrUInt):pointer;
     end;

     PFLREParallelNFAStateItem=^TFLREParallelNFAStateItem;
     TFLREParallelNFAStateItem=TFLRESizeInt;

     TFLREParallelNFAStateItems=array of TFLREParallelNFAStateItem;

     PFLREParallelNFAState=^TFLREParallelNFAState;
     TFLREParallelNFAState=record
      Next:PFLREParallelNFAState;
      ReferenceCounter:TFLREInt32;
      Count:TFLREInt32;
      SubMatchesBitmap:TFLREUInt32;
      SubMatches:TFLREParallelNFAStateItems;
     end;

     PFLREParallelNFAThread=^TFLREParallelNFAThread;
     TFLREParallelNFAThread=record
      Instruction:PFLREInstruction;
      State:PFLREParallelNFAState;
     end;

     TFLREParallelNFAThreads=array of TFLREParallelNFAThread;

     PFLREParallelNFAThreadList=^TFLREParallelNFAThreadList;
     TFLREParallelNFAThreadList=record
      Threads:TFLREParallelNFAThreads;
      CountThreads:TFLREInt32;
     end;

     TFLREParallelNFAThreadLists=array[0..1] of TFLREParallelNFAThreadList;

     PFLREParallelNFAStackItem=^TFLREParallelNFAStackItem;
     TFLREParallelNFAStackItem=record
      Instruction:PFLREInstruction;
      State:PFLREParallelNFAState;
     end;

     TFLREParallelNFAStack=array of TFLREParallelNFAStackItem;

     PFLREByteMap=^TFLREByteMap;
     TFLREByteMap=array[byte] of byte;

     PFLREOnePassNFAStateCharClassAction=^TFLREOnePassNFAStateCharClassAction;
     TFLREOnePassNFAStateCharClassAction=record // 32-bit: 16 bytes, 64-bit: 32 bytes
      AllNext:PFLREOnePassNFAStateCharClassAction;
      Next:PFLREOnePassNFAStateCharClassAction;
      CharClass:PFLRECharClass;
      Condition:TFLREUInt32;
     end;

     PFLREOnePassNFAState=^TFLREOnePassNFAState;
     TFLREOnePassNFAState=record
      MatchCondition,NoAction:TFLREUInt32;
      CharClassAction:PFLREOnePassNFAStateCharClassAction;
      Action:array[0..0] of TFLREUInt32;
     end;

     TFLREOnePassNFASubMatches=array of TFLRESizeInt;

     PFLREBitStateNFAJob=^TFLREBitStateNFAJob;
     TFLREBitStateNFAJob=record
      Instruction:PFLREInstruction;
      Position:TFLRESizeInt;
      Argument:TFLREInt32;
{$ifndef cpu64}
      Dummy:TFLREInt32;
{$endif}
     end;

     TFLREBitStateNFAJobs=array of TFLREBitStateNFAJob;

     TFLREBitStateNFAVisited=array[0..(32768 div SizeOf(TFLREUInt32))-1] of TFLREUInt32;
     
     PFLREBitStateNFAVisited=^TFLREBitStateNFAVisited;     

     TFLREBitStateNFASubMatches=array of TFLRESizeInt;

     PPFLREDFAState=^PFLREDFAState;
     PFLREDFAState=^TFLREDFAState;

     TPFLREDFAStates=array of PFLREDFAState;

     PPFLREDFANextStatesByteBlock=^TPFLREDFANextStatesByteBlock;
     TPFLREDFANextStatesByteBlock=array[0..256] of PFLREDFAState;

     TFLREDFAState=record
      Flags:TFLREUInt32;
      Instructions:TPFLREInstructions;
      CountInstructions:TFLREInt32;
      NextStates:TPFLREDFANextStatesByteBlock;
     end;

     PFLREDFAStatePool=^TFLREDFAStatePool;
     TFLREDFAStatePool=record
      Next:PFLREDFAStatePool;
      States:pointer;
      EndState:pointer;
      NextState:pointer;
     end;

     PFLREDFAStateHashMapEntity=^TFLREDFAStateHashMapEntity;
     TFLREDFAStateHashMapEntity=record
      Key:PFLREDFAState;
      Value:TFLREInt64;
     end;

     TFLREDFAStateHashMapEntities=array of TFLREDFAStateHashMapEntity;

     TFLREDFAStateHashMapEntityIndices=array of TFLREInt32;

     TFLREDFAStateHashMap=class
      private
       RealSize:TFLRESizeInt;
       LogSize:TFLRESizeInt;
       Size:TFLRESizeInt;
       Entities:TFLREDFAStateHashMapEntities;
       EntityToCellIndex:TFLREDFAStateHashMapEntityIndices;
       CellToEntityIndex:TFLREDFAStateHashMapEntityIndices;
       function FindCell(const Key:PFLREDFAState):TFLREUInt32;
       procedure Resize;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Get(const Key:PFLREDFAState):PFLREDFAState;
       function Add(const Key:PFLREDFAState):PFLREDFAStateHashMapEntity;
       function Delete(const Key:PFLREDFAState):boolean;
       property Keys[const Key:PFLREDFAState]:PFLREDFAState read Get; default;
     end;

     TFLRESparseSetIntegerArray=array of TFLREInt32;

     TFLRESparseSet=class
      public
       Size:TFLREInt32;
       MaxSize:TFLREInt32;
       SparseToDense:TFLRESparseSetIntegerArray;
       Dense:TFLRESparseSetIntegerArray;
       constructor Create(MaximumSize:TFLREInt32=0);
       destructor Destroy; override;
       procedure Clear;
       procedure Resize(NewMaximumSize:TFLREInt32);
       function Contains(const Value:TFLREInt32):boolean;
       procedure Add(const Value:TFLREInt32);
       procedure AddNew(const Value:TFLREInt32);
     end;

     TFLREDFAWorkQueue=class
      public
       Instructions:TPFLREInstructions;
       CountInstructions:TFLREInt32;
       SparseToDenseIDs:TFLRESparseSetIntegerArray;
       DenseIDs:TFLRESparseSetIntegerArray;
       CountIDs:TFLREInt32;
       AllocatedIDs:TFLREInt32;
       LastWasMark:longbool;
       constructor Create(Preallocated:TFLREInt32=16);
       destructor Destroy; override;
       procedure Clear;
       procedure Mark;
       function IsMark(const Instruction:PFLREInstruction):boolean;
       function Contains(const Instruction:PFLREInstruction):boolean;
       procedure AddNew(const Instruction:PFLREInstruction);
       procedure Add(const Instruction:PFLREInstruction);
     end;

     TFLREDFAWorkQueues=array[0..1] of TFLREDFAWorkQueue;

     PFLRECharPatternBitMasks=^TFLRECharPatternBitMasks;
     TFLRECharPatternBitMasks=array[TFLRERawByteChar] of TFLREUInt32;

     TFLREBoyerMooreNext=array of TFLREInt32;

     TFLREPrefixCharClasses=array of TFLRECharClass;

     PFLREIntegerArray=^TFLREIntegerArray;
     TFLREIntegerArray=array[0..(2147483647 div sizeof(TFLREInt32))-1] of TFLREInt32;

     TFLREIntegerList=class
      private
       List:PFLREIntegerArray;
       CountItems:TFLREInt32;
       Allocated:TFLREInt32;
       IsSorted:boolean;
       function GetItem(Index:TFLREInt32):TFLREInt32;
       procedure SetItem(Index:TFLREInt32;Value:TFLREInt32);
       function GetItemPointer(Index:TFLREInt32):pointer;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Add(Item:TFLREInt32):TFLREInt32;
       procedure AddSorted(Item:TFLREInt32);
       procedure Insert(Index:TFLREInt32;Item:TFLREInt32);
       procedure Delete(Index:TFLREInt32);
       function Remove(Item:TFLREInt32):TFLREInt32;
       function Find(Item:TFLREInt32):TFLREInt32;
       function IndexOf(Item:TFLREInt32):TFLREInt32;
       procedure Exchange(Index1,Index2:TFLREInt32);
       procedure SetCapacity(NewCapacity:TFLREInt32);
       procedure SetCount(NewCount:TFLREInt32);
       procedure Sort;
       property Count:TFLREInt32 read CountItems;
       property Capacity:TFLREInt32 read Allocated write SetCapacity;
       property Item[Index:TFLREInt32]:TFLREInt32 read GetItem write SetItem; default;
       property Items[Index:TFLREInt32]:TFLREInt32 read GetItem write SetItem;
       property PItems[Index:TFLREInt32]:pointer read GetItemPointer;
     end;

     TFLRENodeHashSetEntities=array of PFLRENode;

     TFLRENodeHashSetEntityIndices=array of TFLREInt32;

     TFLRENodeHashSet=class
      private
       function FindCell(const Key:PFLRENode):TFLREUInt32;
       procedure Resize;
       procedure Toggle(const Key:PFLRENode;aInclude:boolean);
      public
       RealSize:TFLREInt32;
       LogSize:TFLREInt32;
       Size:TFLREInt32;
       Entities:TFLRENodeHashSetEntities;
       EntityToCellIndex:TFLRENodeHashSetEntityIndices;
       CellToEntityIndex:TFLRENodeHashSetEntityIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Add(const Key:PFLRENode);
       function Contains(const Key:PFLRENode):boolean;
       function Delete(const Key:PFLRENode):boolean;
       property Values[const Key:PFLRENode]:Boolean read Contains write Toggle; default;
     end;

     TFLREStringIntegerPairHashMapData=TFLREInt64;

     PFLREStringIntegerPairHashMapEntity=^TFLREStringIntegerPairHashMapEntity;
     TFLREStringIntegerPairHashMapEntity=record
      Key:TFLRERawByteString;
      Value:TFLREStringIntegerPairHashMapData;
     end;

     TFLREStringIntegerPairHashMapEntities=array of TFLREStringIntegerPairHashMapEntity;

     TFLREStringIntegerPairHashMapEntityIndices=array of TFLREInt32;

     TFLREStringIntegerPairHashMap=class
      private
       function FindCell(const Key:TFLRERawByteString):TFLREUInt32;
       procedure Resize;
      protected
       function GetValue(const Key:TFLRERawByteString):TFLREStringIntegerPairHashMapData;
       procedure SetValue(const Key:TFLRERawByteString;const Value:TFLREStringIntegerPairHashMapData);
      public
       RealSize:TFLREInt32;
       LogSize:TFLREInt32;
       Size:TFLREInt32;
       Entities:TFLREStringIntegerPairHashMapEntities;
       EntityToCellIndex:TFLREStringIntegerPairHashMapEntityIndices;
       CellToEntityIndex:TFLREStringIntegerPairHashMapEntityIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure LowerCaseAssignFrom(const HashMap:TFLREStringIntegerPairHashMap);
       function Add(const Key:TFLRERawByteString;Value:TFLREStringIntegerPairHashMapData):PFLREStringIntegerPairHashMapEntity;
       function Get(const Key:TFLRERawByteString;CreateIfNotExist:boolean=false):PFLREStringIntegerPairHashMapEntity;
       function Delete(const Key:TFLRERawByteString):boolean;
       property Values[const Key:TFLRERawByteString]:TFLREStringIntegerPairHashMapData read GetValue write SetValue; default;
     end;

     TFLRECharClassHashMapData=TFLREInt64;

     PFLRECharClassHashMapEntity=^TFLRECharClassHashMapEntity;
     TFLRECharClassHashMapEntity=record
      Key:TFLRECharClass;
      Value:TFLRECharClassHashMapData;
     end;

     TFLRECharClassHashMapEntities=array of TFLRECharClassHashMapEntity;

     TFLRECharClassHashMapEntityIndices=array of TFLREInt32;

     TFLRECharClassHashMap=class
      private
       function FindCell(const Key:TFLRECharClass):TFLREUInt32;
       procedure Resize;
      protected
       function GetValue(const Key:TFLRECharClass):TFLRECharClassHashMapData;
       procedure SetValue(const Key:TFLRECharClass;const Value:TFLRECharClassHashMapData);
      public
       RealSize:TFLREInt32;
       LogSize:TFLREInt32;
       Size:TFLREInt32;
       Entities:TFLRECharClassHashMapEntities;
       EntityToCellIndex:TFLRECharClassHashMapEntityIndices;
       CellToEntityIndex:TFLRECharClassHashMapEntityIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Add(const Key:TFLRECharClass;Value:TFLRECharClassHashMapData):PFLRECharClassHashMapEntity;
       function Get(const Key:TFLRECharClass;CreateIfNotExist:boolean=false):PFLRECharClassHashMapEntity;
       function Delete(const Key:TFLRECharClass):boolean;
       property Values[const Key:TFLRECharClass]:TFLRECharClassHashMapData read GetValue write SetValue; default;
     end;

     TFLREMultiSubMatches=array of TFLRESizeInt;

     TFLREInstructionGenerations=array of TFLREInt64;

     TFLREPrefilterNode=class;

     TFLREPrefilterNodeList=class(TFLREPointerList)
      protected
       function GetNodeItem(Index:TFLREInt32):TFLREPrefilterNode;
       procedure SetNodeItem(Index:TFLREInt32;Value:TFLREPrefilterNode);
      public
       property Items[Index:TFLREInt32]:TFLREPrefilterNode read GetNodeItem write SetNodeItem; default;
     end;

     TFLREPrefilterNodeOperation=(FLREpfnoANY,FLREpfnoATOM,FLREpfnoAND,FLREpfnoOR);

     TFLREPrefilterNode=class
      public
       Operation:TFLREPrefilterNodeOperation;
       Subs:TFLREPrefilterNodeList;
       Atom:TFLRERawByteString;
       Exact:boolean;
       constructor Create;
       destructor Destroy; override;
       function Clone:TFLREPrefilterNode;
       function Expression:TFLRERawByteString;
       function ShortExpression:TFLRERawByteString;
       function SQLBooleanFullTextExpression:TFLRERawByteString;
       function SQLExpression(const Field:TFLRERawByteString):TFLRERawByteString;
     end;

     TFLREThreadLocalStorageInstance=class;

     TFLREParallelNFA=class
      public
       Instance:TFLRE;
       ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
       MatchMode:TFLREMatchMode;
       ParallelNFAThreadLists:TFLREParallelNFAThreadLists;
       ParallelNFAStack:TFLREParallelNFAStack;
       Generation:TFLREInt64;
       InstructionGenerations:TFLREInstructionGenerations;
       FreeStates:PFLREParallelNFAState;
       AllStates:TFLREPointerList;
       CurrentSatisfyFlags:TFLREUInt32;
       constructor Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
       destructor Destroy; override;
       function StateAllocate(const Count:TFLREInt32;const SubMatchesBitmap:TFLREUInt32):PFLREParallelNFAState; {$ifdef caninline}inline;{$endif}
       function StateAcquire(const State:PFLREParallelNFAState):PFLREParallelNFAState; {$ifdef caninline}inline;{$endif}
       procedure StateRelease(const State:PFLREParallelNFAState); {$ifdef caninline}inline;{$endif}
       function StateUpdate(const State:PFLREParallelNFAState;const Index:TFLREInt32;const Position:TFLRESizeInt):PFLREParallelNFAState; //{$ifdef fpc}{$ifndef cpu386}{$ifdef caninline}inline;{$endif}{$endif}{$endif}
       function BackReferenceAssertion(const State:PFLREParallelNFAState;const CaptureSubMatch,BackReferenceSubMatch:TFLREInt32;const IgnoreCase:boolean):boolean;
       procedure AddThread(const ThreadList:PFLREParallelNFAThreadList;Instruction:PFLREInstruction;State:PFLREParallelNFAState;const Position:TFLRESizeInt);
       function SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt;const UnanchoredStart:boolean):boolean;
     end;

     TFLREOnePassNFA=class
      public
       Instance:TFLRE;
       ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
       MatchMode:TFLREMatchMode;
       WorkSubMatches:TFLREOnePassNFASubMatches;
       MatchSubMatches:TFLREOnePassNFASubMatches;
       constructor Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
       destructor Destroy; override;
       function SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt):boolean;
     end;

     TFLREBitStateNFA=class
      public
       Instance:TFLRE;
       ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
       MatchMode:TFLREMatchMode;
       Visited:TFLREBitStateNFAVisited;
       CountVisited:TFLREInt32;
       Jobs:TFLREBitStateNFAJobs;
       CountJobs:TFLREInt32;
       MaxJob:TFLREInt32;
       WorkSubMatches:TFLREBitStateNFASubMatches;
       MatchSubMatches:TFLREBitStateNFASubMatches;       
       constructor Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
       destructor Destroy; override;
       function SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt;const UnanchoredStart:boolean):TFLREInt32;
     end;

     PFLREDFAByteMap=^TFLREDFAByteMap;
     TFLREDFAByteMap=array[0..256] of TFLREUInt32;

     TFLREDFASearchMatch=function(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32 of object; {$ifdef cpu386}stdcall;{$endif}

     TFLREDFA=class
      public

       Instance:TFLRE;

       ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;

       CountInstructions:TFLREInt32;

       MatchMode:TFLREMatchMode;

       NeedMark:longbool;

       Reversed:longbool;

       IsUnanchored:longbool;

       DoFastDFA:longbool;

       Generation:TFLREInt64;

       InstructionGenerations:TFLREInstructionGenerations;

       StackInstructions:TPFLREInstructions;

       StateCache:TFLREDFAStateHashMap;

       ByteMap:TFLREDFAByteMap;

       DefaultStates:array[0..4{dskFastReversed}] of PFLREDFAState;

       StartStates:array[0..4*3{sskMax}] of PFLREDFAState;

       TemporaryState:TFLREDFAState;

       NewState:TFLREDFAState;

       CountStatesCached:TFLREInt32;

       NextStatesSize:TFLREPtrInt;

       StateSize:TFLREPtrInt;
       StatePoolUsed:PFLREDFAStatePool;
       StatePoolFree:PFLREDFAStatePool;
       StatePoolSize:TFLREPtrUInt;
       StatePoolSizePowerOfTwo:TFLREPtrUInt;

       WorkQueues:TFLREDFAWorkQueues;

       QueueInstructionArray:TPFLREInstructions;
       QueueStack:TPFLREInstructions;

       SearchMatch:TFLREDFASearchMatch;

       MaximalDFAStates:TFLREInt32;

       HadReset:longbool;

       constructor Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;const AReversed:boolean;const AMaximalDFAStates:TFLREInt32);
       destructor Destroy; override;

       function CacheState(const State:PFLREDFAState):PFLREDFAState; {$ifdef caninline}inline;{$endif}
       procedure DestroyStatePool(var StatePool:PFLREDFAStatePool);
       procedure FreeUsedStatePool;
       function AllocateNewStatePool:PFLREDFAStatePool;
       function GetState:PFLREDFAState;
       function TakeOverState(TakeOverFrom:PFLREDFAState):PFLREDFAState;
       procedure FreeState(State:PFLREDFAState);
       procedure Reset;

       procedure FastAddInstructionThread(const State:PFLREDFAState;Instruction:PFLREInstruction); {$ifdef cpu386}register;{$endif}
       function FastProcessNextState(State:PFLREDFAState;const CurrentChar:TFLRERawByteChar):PFLREDFAState; {$ifdef cpu386}register;{$endif}
       function SearchMatchFast(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}stdcall;{$endif}
       function SearchMatchFastReversed(const StartPosition,UntilIncludingPosition:TFLRESizeInt;out MatchBegin:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}stdcall;{$endif}

       function WorkQueueToCachedState(const WorkQueue:TFLREDFAWorkQueue;Flags:TFLREUInt32):PFLREDFAState;
       procedure StateToWorkQueue(const DFAState:PFLREDFAState;const WorkQueue:TFLREDFAWorkQueue);
       procedure AddToWorkQueue(const WorkQueue:TFLREDFAWorkQueue;Instruction:PFLREInstruction;Flags:TFLREUInt32);
       procedure ProcessWorkQueueOnZeroWidthString(const OldWorkQueue,NewWorkQueue:TFLREDFAWorkQueue;Flags:TFLREUInt32);
       procedure ProcessWorkQueueOnByte(const OldWorkQueue,NewWorkQueue:TFLREDFAWorkQueue;CurrentChar,Flags:TFLREUInt32;var IsMatch:boolean);
       function RunStateOnByte(State:PFLREDFAState;const Position:TFLRESizeInt;const CurrentChar:TFLREUInt32):PFLREDFAState;
       function InitializeStartState(const StartPosition:TFLRESizeInt;const UnanchoredStart:boolean):PFLREDFAState;

       function SearchMatchFull(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}stdcall;{$endif}
       function SearchMatchFullReversed(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}stdcall;{$endif}

     end;

     TFLREThreadLocalStorageInstance=class
      private
       AllNext:TFLREThreadLocalStorageInstance;
       FreeNext:TFLREThreadLocalStorageInstance;
      public

       Instance:TFLRE;

       Input:PFLRERawByteChar;
       InputLength:TFLRESizeInt;

       MatchMode:TFLREMatchMode;

       MultiSubMatches:TFLREMultiSubMatches;

       ParallelNFA:TFLREParallelNFA;

       OnePassNFA:TFLREOnePassNFA;

       BitStateNFA:TFLREBitStateNFA;

       DFA:TFLREDFA;
       ReversedDFA:TFLREDFA;

       constructor Create(AInstance:TFLRE);
       destructor Destroy; override;
       function GetSatisfyFlags(const Position:TFLRESizeInt):TFLREUInt32;
       function LookAssertion(const Position,WhichLookAssertionString:TFLRESizeInt;const LookBehind,Negative:boolean):boolean;
       function BackReferenceAssertion(const CaptureStart,CaptureEnd,BackReferenceStart,BackReferenceEnd:TFLRESizeInt;const IgnoreCase:boolean):boolean;
     end;

     TFLRE=class
      private

       RegularExpression:TFLRERawByteString;

       OriginalRegularExpression:TFLRERawByteString;

       Flags:TFLREFlags;

       InternalFlags:TFLREInternalFlags;

       AnchoredRootNode:PFLRENode;

       UnanchoredRootNode:PFLRENode;

       RegularExpressionHasCharClasses:longbool;

       Nodes:TFLREPointerList;

       CountCaptures:TFLREInt32;

       CountInternalCaptures:TFLREInt32;

       CountSubMatches:TFLREInt32;

       CountMultiSubMatches:TFLREInt32;

       CapturesToSubMatchesMap:TFLRECapturesToSubMatchesMap;

       ForwardInstructions:TFLREInstructions;
       CountForwardInstructions:TFLREInt32;

       BackwardInstructions:TFLREInstructions;
       CountBackwardInstructions:TFLREInt32;

       AnchoredStartInstruction:PFLREInstruction;
       UnanchoredStartInstruction:PFLREInstruction;
       ReversedStartInstruction:PFLREInstruction;

       CharClasses:TPFLRECharClasses;
       CountCharClasses:TFLREInt32;

       CharClassHashMap:TFLRECharClassHashMap;

       LookAssertionStrings:TFLRELookAssertionStrings;
       CountLookAssertionStrings:TFLREInt32;

       FixedString:TFLRERawByteString;
       FixedStringIsWholeRegExp:longbool;
       FixedStringLength:TFLRESizeInt;
       FixedStringPatternBitMasks:PFLRECharPatternBitMasks;
       FixedStringBoyerMooreSkip:PFLRECharPatternBitMasks;
       FixedStringBoyerMooreNext:TFLREBoyerMooreNext;

       FirstPrefixCharClass:PFLRECharClass;
       FirstPrefixCharClassSize:TFLREInt32;
       FirstPrefixCharClassRepeatedCount:TFLREInt32;
       FirstPrefixCharRanges:TFLRECharRanges;
       CountFirstPrefixCharRanges:TFLREInt32;
       FirstPrefixCharClassChars:TFLRECharClassChars;
       CountPrefixCharClasses:TFLREInt32;
       AveragePrefixCharClassesVariance:TFLREInt32;
       PrefixPatternBitMasks:PFLRECharPatternBitMasks;

       ByteMap:TFLREByteMap;
       UnByteMap:TFLREByteMap;
       ByteCharSetMap:TFLRECharClass;
       ByteMapCount:TFLREInt32;

       OnePassNFANodes:PFLREOnePassNFAState;
       OnePassNFANodesCount:TFLREInt32;
       OnePassNFAStart:PFLREOnePassNFAState;
       OnePassNFAStateSize:TFLREInt32;
       OnePassNFACharClassActions:PFLREOnePassNFAStateCharClassAction;

       NamedGroupStringList:TStringList;
       NamedGroupStringIntegerPairHashMap:TFLREStringIntegerPairHashMap;
       NamedGroupStringIndexList:TFLREIntegerList;

       ParallelLock:TFLREParallelLock;

       ThreadLocalStorageInstanceManagerParallelLock:TFLREParallelLock;

       ThreadLocalStorageInstances:TFLREThreadLocalStorageInstance;
       FreeThreadLocalStorageInstances:TFLREThreadLocalStorageInstance;

       RangeLow:TFLRERawByteString;
       RangeHigh:TFLRERawByteString;

       PrefilterRootNode:TFLREPrefilterNode;
       
       MaxBitStateNFATextSize:TFLRESizeInt;

       function NewCharClass(const CharClass:TFLRECharClass;const FromRegularExpression:boolean):TFLREInt32;
       function GetCharClass(const CharClass:TFLREInt32):TFLRECharClass;

       function NewNode(const NodeType:TFLREInt32;const Left,Right:PFLRENode;const Value:TFLREInt32):PFLRENode;
       procedure FreeNode(var Node:PFLRENode);
       function CopyNode(Node:PFLRENode):PFLRENode;
       procedure FreeUnusedNodes(RootNode:PFLRENode);

       function AreNodesEqual(NodeA,NodeB:PFLRENode):boolean;
       function AreNodesEqualSafe(NodeA,NodeB:PFLRENode):boolean;

       function IsStarNullable(Node:PFLRENode):boolean;
       function StarDenull(Node:PFLRENode):PFLRENode;

       function Concat(NodeLeft,NodeRight:PFLRENode):PFLRENode;

       function NewEmptyMatch:PFLRENode;

       function NewAlt(NodeLeft,NodeRight:PFLRENode):PFLRENode;
       function NewPlus(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
       function NewStar(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
       function NewQuest(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
       function NewExact(Node:PFLRENode;MinCount,MaxCount,Kind:TFLREInt32):PFLRENode;

       function OptimizeNode(StartNodeEx:PPFLRENode):boolean;

       procedure Parse;

       procedure Compile;
       procedure CompileRange;
       procedure CompilePrefix;
       procedure CompileFixedStringSearch;
       procedure CompilePrefixCharClasses;
       procedure CompileByteMapForOnePassNFAAndDFA;
       procedure CompileOnePassNFA;

       procedure ScanProgram;

       function PrefilterOptimize(Node:TFLREPrefilterNode):TFLREPrefilterNode;
       function CompilePrefilterTree(RootNode:PFLRENode):TFLREPrefilterNode;

       function IsWordChar(const CharValue:TFLREUInt32):boolean; //{$ifdef caninline}inline;{$endif}

       function AcquireThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
       procedure ReleaseThreadLocalStorageInstance(const ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);

       function SearchNextPossibleStart(const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt):TFLRESizeInt; {$ifdef cpu386}register;{$endif}

       function SearchNextPossibleStartForDFA(const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt):TFLRESizeInt; {$ifdef cpu386}register;{$endif}

       function SearchMatch(ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;var Captures:TFLRECaptures;StartPosition,UntilExcludingPosition:TFLRESizeInt;UnanchoredStart:boolean):boolean;

       function DumpRegularExpressionNode(StartNode:PFLRENode):TFLRERawByteString;

      public

       MaximalDFAStates:TFLREInt32;

       constructor Create(const ARegularExpression:TFLRERawByteString;const AFlags:TFLREFlags=[rfDELIMITERS]); overload;
       constructor Create(const ARegularExpressions:array of TFLRERawByteString;const AFlags:TFLREFlags=[]); overload;
       destructor Destroy; override;

       function PtrMatch(const Input:pointer;const InputLength:TFLRESizeInt;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=0):boolean;
       function PtrMatchNext(const Input:pointer;const InputLength:TFLRESizeInt;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=0):boolean;
       function PtrMatchAll(const Input:pointer;const InputLength:TFLRESizeInt;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):boolean;
       function PtrExtractAll(const Input:pointer;const InputLength:TFLRESizeInt;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):boolean;
       function PtrReplace(const Input:pointer;const InputLength:TFLRESizeInt;const Replacement:pointer;const ReplacementLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString;
       function PtrReplaceCallback(const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function PtrReplaceCallback(const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function PtrSplit(const Input:pointer;const InputLength:TFLRESizeInt;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
       function PtrTest(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):boolean;
       function PtrTestAll(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):boolean;
       function PtrFind(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):TFLRESizeInt;

       function Match(const Input:TFLRERawByteString;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
       function MatchNext(const Input:TFLRERawByteString;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
       function MatchAll(const Input:TFLRERawByteString;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
       function ExtractAll(const Input:TFLRERawByteString;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
       function Replace(const Input,Replacement:TFLRERawByteString;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
       function ReplaceCallback(const Input:TFLRERawByteString;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function ReplaceCallback(const Input:TFLRERawByteString;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function Split(const Input:TFLRERawByteString;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
       function Test(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):boolean;
       function TestAll(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):boolean;
       function Find(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):TFLRESizeInt;

       function UTF8Match(const Input:TFLREUTF8String;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
       function UTF8MatchNext(const Input:TFLREUTF8String;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
       function UTF8MatchAll(const Input:TFLREUTF8String;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
       function UTF8ExtractAll(const Input:TFLREUTF8String;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
       function UTF8Replace(const Input,Replacement:TFLREUTF8String;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLREUTF8String;
       function UTF8ReplaceCallback(const Input:TFLREUTF8String;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function UTF8ReplaceCallback(const Input:TFLREUTF8String;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString; overload;
       function UTF8Split(const Input:TFLREUTF8String;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
       function UTF8Test(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):boolean;
       function UTF8TestAll(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):boolean;
       function UTF8Find(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):TFLRESizeInt;

       function GetRange(var LowRange,HighRange:TFLRERawByteString):boolean;

       function DumpRegularExpression:TFLRERawByteString;

       function GetPrefilterExpression:TFLRERawByteString;
       function GetPrefilterShortExpression:TFLRERawByteString;
       function GetPrefilterSQLBooleanFullTextExpression:TFLRERawByteString;
       function GetPrefilterSQLExpression(Field:TFLRERawByteString):TFLRERawByteString;

      published

       property NamedGroups:TStringList read NamedGroupStringList;
       property NamedGroupIndices:TFLREStringIntegerPairHashMap read NamedGroupStringIntegerPairHashMap;
       property NamedGroupStringIndices:TFLREIntegerList read NamedGroupStringIndexList;

       property RegularExpressionSource:TFLRERawByteString read OriginalRegularExpression;

       property RegularExpressionFlags:TFLREFlags read Flags;

     end;

     TFLRECacheHashMapData=TFLRE;

     PFLRECacheHashMapEntity=^TFLRECacheHashMapEntity;
     TFLRECacheHashMapEntity=record
      Key:TFLRERawByteString;
      Value:TFLRECacheHashMapData;
     end;

     TFLRECacheHashMapEntities=array of TFLRECacheHashMapEntity;

     TFLRECacheHashMapEntityIndices=array of TFLREInt32;

     TFLRECacheHashMap=class
      private
       function FindCell(const Key:TFLRERawByteString):TFLREUInt32;
       procedure Resize;
      protected
       function GetValue(const Key:TFLRERawByteString):TFLRECacheHashMapData;
       procedure SetValue(const Key:TFLRERawByteString;const Value:TFLRECacheHashMapData);
      public
       RealSize:TFLREInt32;
       LogSize:TFLREInt32;
       Size:TFLREInt32;
       Entities:TFLRECacheHashMapEntities;
       EntityToCellIndex:TFLRECacheHashMapEntityIndices;
       CellToEntityIndex:TFLRECacheHashMapEntityIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Add(const Key:TFLRERawByteString;Value:TFLRECacheHashMapData):PFLRECacheHashMapEntity;
       function Get(const Key:TFLRERawByteString;CreateIfNotExist:boolean=false):PFLRECacheHashMapEntity;
       function Delete(const Key:TFLRERawByteString):boolean;
       property Values[const Key:TFLRERawByteString]:TFLRECacheHashMapData read GetValue write SetValue; default;
     end;

     TFLRECache=class
      private
       ParallelLock:TFLREParallelLock;
       List:TFLREPointerList;
       HashMap:TFLRECacheHashMap;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Get(const ARegularExpression:TFLRERawByteString;const AFlags:TFLREFlags=[rfDELIMITERS]):TFLRE; overload;
       function Get(const ARegularExpressions:array of TFLRERawByteString;const AFlags:TFLREFlags=[]):TFLRE; overload;
     end;

var FLREMaximalRepetitionCount:TFLREInt32=4096;

function FLREPtrCopy(const Src:PFLRERawByteChar;const From,Len:TFLRESizeInt):TFLRERawByteString;

function FLREGetVersion:TFLREUInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetVersionString:PFLRERawByteChar; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLRECreate(const RegularExpression:PFLRERawByteChar;const RegularExpressionLength:TFLRESizeInt;const Flags:TFLREUInt32;const Error:PPAnsiChar):pointer; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
procedure FLREDestroy(const Instance:pointer); {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREAlloc(const Size:TFLRESizeInt):pointer; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
procedure FLREFree(const Data:pointer); {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetCountCaptures(const Instance:pointer):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetNamedGroupIndex(const Instance:pointer;const GroupName:PFLRERawByteChar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREDumpRegularExpression(const Instance:pointer;const RegularExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetPrefilterExpression(const Instance:pointer;const Expression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetPrefilterShortExpression(const Instance:pointer;const ShortExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetPrefilterSQLBooleanFullTextExpression(const Instance:pointer;const SQLBooleanFullTextExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetPrefilterSQLExpression(const Instance:pointer;const Field:PFLRERawByteChar;SQLExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREGetRange(const Instance:pointer;const LowRange,HighRange:PPAnsiChar;const LowRangeLength,HighRangeLength:PFLRESizeInt;const Error:PPAnsiChar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
function FLREMatch(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Captures:PPointer;const MaxCaptures:TFLRESizeInt;const CountCaptures:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLREMatchNext(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Captures:PPointer;const MaxCaptures:TFLRESizeInt;const CountCaptures:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLREMatchAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const MultiCaptures:PPointer;const MaxMultiCaptures:TFLRESizeInt;const CountMultiCaptures,CountCaptures:PFLRESizeInt;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLREReplaceAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Replacement:pointer;const ReplacementLength:TFLRESizeInt;const ResultString:PPointer;const ResultStringLength:PFLREInt32;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLREReplaceCallback(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementExternalCallback;const ResultString:PPointer;const ResultStringLength:PFLREInt32;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLRESplit(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;SplittedStrings:PPointer;const CountSplittedStrings:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Limit:TFLRESizeInt;const WithEmpty:TFLREInt32;const Error:PPAnsiChar):TFLREInt32;
function FLRETest(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLRETestAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
function FLREFind(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLRESizeInt;

procedure InitializeFLRE;

implementation

const MaxGeneration=TFLREInt64($4000000000000000);

      Mark=nil;

      EmptyCharClass{:TFLRECharClass}=[];

      AllCharClass{:TFLRECharClass}=[#0..#255];

      // State flags
      sfEmptyMatch=0;
      sfEmptyBeginLine=1 shl 0;
      sfEmptyEndLine=1 shl 1;
      sfEmptyBeginText=1 shl 2;
      sfEmptyEndText=1 shl 3;
      sfEmptyWordBoundary=1 shl 4;
      sfEmptyNonWordBoundary=1 shl 5;
      sfEmptyAllFlags=(1 shl 6)-1;
      sfIndexShift=16;
      sfEmptyShift=6;
      sfRealCapShift=sfEmptyShift+1;
      sfRealMaxCap=((sfIndexShift-sfRealCapShift) shr 1)*2;
      sfCapShift=sfRealCapShift;
      sfMaxCap=sfRealMaxCap;
      sfMatchWins=1 shl sfEmptyShift;
      sfCapMask=((1 shl sfRealMaxCap)-1) shl sfRealCapShift;
      sfImpossible=sfEmptyWordBoundary or sfEmptyNonWordBoundary;
      sfDFAMatchWins=1 shl (sfEmptyShift+0);
      sfDFALastWord=1 shl (sfEmptyShift+1);
      sfDFADead=1 shl (sfEmptyShift+2);
      sfDFAFullMatch=1 shl (sfEmptyShift+3);
      sfDFAStart=1 shl (sfEmptyShift+4);
      sfDFANeedShift=16;
      sfDFACacheMask=TFLREUInt32(TFLREUInt32($ffffffff) and not sfDFAStart);

      // Default state kind
      dskDead=0;
      dskFullMatch=1;
      dskFastUnanchored=2;
      dskFastAnchored=3;
      dskFastReversed=4;

      // Start state kind
      sskUnanchored=0;
      sskAnchored=1;
      sskReversed=2;
      ///
      sskBeginText=0*3;
      sskBeginLine=1*3;
      sskAfterWordChar=2*3;
      sskAfterNonWordChar=3*3;
      sskMax=4*3;

      // Node types
      ntALT=0;
      ntCAT=1;
      ntCHAR=2;
      ntPAREN=3;
      ntQUEST=4;
      ntSTAR=5;
      ntPLUS=6;
      ntMULTIMATCH=7;
      ntZEROWIDTH=8;
      ntLOOKBEHINDNEGATIVE=9;
      ntLOOKBEHINDPOSITIVE=10;
      ntLOOKAHEADNEGATIVE=11;
      ntLOOKAHEADPOSITIVE=12;
      ntBACKREFERENCE=13;
      ntBACKREFERENCEIGNORECASE=14;

      // Opcodes
      opNONE=0;
      opSINGLECHAR=1;
      opCHAR=2;
      opANY=3;
      opMATCH=4;
{$ifdef UseOpcodeJMP}
      opJMP=5;
{$endif}
      opSPLIT=6;
      opSPLITMATCH=7;
      opSAVE=8;
      opZEROWIDTH=9;
      opLOOKBEHINDNEGATIVE=10;
      opLOOKBEHINDPOSITIVE=11;
      opLOOKAHEADNEGATIVE=12;
      opLOOKAHEADPOSITIVE=13;
      opBACKREFERENCE=14;
      opBACKREFERENCEIGNORECASE=15;
      opNOP=16;

      // Split kind
      skALT=0;
      skPLUS=1;
      skQUEST=2;
      skSTAR=3;

      // Qualifier kind
      qkGREEDY=0;
      qkLAZY=1;

      // DFA result return values
      DFAError=-1;
      DFAFail=0;
      DFAMatch=1;

      // Bitstate NFA result return values
      BitStateNFAError=-1;
      BitStateNFAFail=0;
      BitStateNFAMatch=1;

      // For hash map
      CELL_EMPTY=-1;
      CELL_DELETED=-2;

      // For hash map
      ENT_EMPTY=-1;
      ENT_DELETED=-2;

      suDONOTKNOW=-1;
      suNOUTF8=0;
      suPOSSIBLEUTF8=1;
      suISUTF8=2;

      ucACCEPT=0;
      ucERROR=16;

      // Node precedences
      npAtom=0;
      npUnary=1;
      npConcat=2;
      npAlternate=3;
      npZeroWidth=4;
      npParen=5;
      npMultiMatch=6;
      npTopLevel=7;

      NodePrecedences:array[ntALT..ntBACKREFERENCEIGNORECASE] of TFLREInt32=
       (
        npAlternate,   // ntALT=0;
        npConcat,      // ntCAT=1;
        npAtom,        // ntCHAR=2;
        npParen,       // ntPAREN=3;
        npUnary,       // ntQUEST=4;
        npUnary,       // ntSTAR=5;
        npUnary,       // ntPLUS=6;
        npMultiMatch,  // ntMULTIMATCH=7;
        npZeroWidth,   // ntZEROWIDTH=8;
        npZeroWidth,   // ntLOOKBEHINDNEGATIVE=9;
        npZeroWidth,   // ntLOOKBEHINDPOSITIVE=10;
        npZeroWidth,   // ntLOOKAHEADNEGATIVE=11;
        npZeroWidth,   // ntLOOKAHEADPOSITIVE=12;
        npZeroWidth,   // ntBACKREFERENCE=13;
        npZeroWidth    // ntBACKREFERENCEIGNORECASE=14;
       );

      FLREInitialized:longbool=false;

type TUTF8Chars=array[TFLRERawByteChar] of TFLREUInt8;

     TUTF8Bytes=array[TFLREUInt8] of TFLREUInt8;

{$ifdef FLREStrictUTF8}
                              //0 1 2 3 4 5 6 7 8 9 a b c d e f
const UTF8CharSteps:TUTF8Chars=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
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
                              //0 1 2 3 4 5 6 7 8 9 a b c d e f

{$ifndef FLRERuntimeUTF8DFATableGeneration}
      UTF8DFACharClasses:TUTF8Chars=( 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
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

      UTF8DFATransitions:TUTF8Bytes=( 0,16,32,48,80,128,112,16,16,16,64,96,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16, 0,16,16,16, 16, 16, 0,16, 0,16,16,16,16,16,16,
                                     16,32,16,16,16, 16, 16,32,16,32,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,32,16,16,16,16,16,16,16,16,
                                     16,32,16,16,16, 16, 16,16,16,32,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,48,16,48,16,16,16,16,16,16,
                                     16,48,16,16,16, 16, 16,48,16,48,16,16,16,16,16,16,
                                     16,48,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16, 16, 16,16,16,16,16,16,16,16,16,16);

{$endif}

{$else}

                              //0 1 2 3 4 5 6 7 8 9 a b c d e f
const UTF8CharSteps:TUTF8Chars=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
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
                                2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // c
                                2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // d
                                3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,  // e
                                4,4,4,4,4,4,4,4,5,5,5,5,6,6,1,1); // f
                              //0 1 2 3 4 5 6 7 8 9 a b c d e f

{$ifndef FLRERuntimeUTF8DFATableGeneration}
      UTF8DFACharClasses:TUTF8Chars=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                     3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
                                     3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
                                     4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
                                     5,5,5,5,5,5,5,5,6,6,6,6,7,7,8,8);

      UTF8DFATransitions:TUTF8Bytes=( 0,16,16,32,48,64,80,96,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16, 0,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,32,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,48,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,64,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,80,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
                                     16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16);

{$endif}

{$endif}

var NativeCodeMemoryManager:TFLRENativeCodeMemoryManager;
{$ifdef HasJIT}
{$ifdef unix}
    fpmprotect:function(__addr:pointer;__len:cardinal;__prot:TFLREInt32):TFLREInt32; cdecl;// external 'c' name 'mprotect';
{$endif}
{$endif}

{$ifdef FLRERuntimeUTF8DFATableGeneration}
    UTF8DFACharClasses:TUTF8Chars;
    UTF8DFATransitions:TUTF8Bytes;
{$endif}

function RoundUpToPowerOfTwo(x:TFLREPtrUInt):TFLREPtrUInt; {$ifdef caninline}inline;{$endif}
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
{$ifdef cpu64}
 x:=x or (x shr 32);
{$endif}
 result:=x+1;
end;

function RoundUpToMask(x,m:TFLREPtrUInt):TFLREPtrUInt; {$ifdef caninline}inline;{$endif}
begin
 if (x and (m-1))<>0 then begin
  result:=(x+m) and not (m-1);
 end else begin
  result:=x;
 end;
end;

procedure GetMemAligned(var p;Size:TFLRESizeInt;Align:TFLRESizeInt=16);
var Original,Aligned:pointer;
    Mask:TFLREPtrUInt;
begin
 if (Align and (Align-1))<>0 then begin
  Align:=RoundUpToPowerOfTwo(Align);
 end;
 Mask:=Align-1;
 inc(Size,((Align shl 1)+sizeof(pointer)));
 GetMem(Original,Size);
 FillChar(Original^,Size,#0);
 Aligned:=pointer(TFLREPtrUInt(TFLREPtrUInt(Original)+sizeof(pointer)));
 if (Align>1) and ((TFLREPtrUInt(Aligned) and Mask)<>0) then begin
  inc(TFLREPtrUInt(Aligned),TFLREPtrUInt(TFLREPtrUInt(Align)-(TFLREPtrUInt(Aligned) and Mask)));
 end;
 pointer(pointer(TFLREPtrUInt(TFLREPtrUInt(Aligned)-sizeof(pointer)))^):=Original;
 pointer(pointer(@p)^):=Aligned;
end;

procedure FreeMemAligned(const p);
var pp:pointer;
begin
 pp:=pointer(pointer(@p)^);
 if assigned(pp) then begin
  pp:=pointer(pointer(TFLREPtrUInt(TFLREPtrUInt(pp)-sizeof(pointer)))^);
  FreeMem(pp);
 end;
end;

function CompareInstruction(const a,b:pointer):TFLRESizeInt;
begin
 if assigned(a) and assigned(b) then begin
  result:=TFLRESizeInt(PFLREInstruction(a)^.IDandOpcode shr 8)-TFLRESizeInt(PFLREInstruction(b)^.IDandOpcode shr 8);
 end else if assigned(a) then begin
  result:=1;
 end else if assigned(b) then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

type TSortCompareFunction=function(const a,b:pointer):TFLRESizeInt;

function IntLog2(x:TFLREUInt32):TFLREUInt32; {$ifdef cpu386}assembler; register;
asm
 test eax,eax
 jz @Done
 bsr eax,eax
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
 x:=x-((x shr 1) and $55555555);
 x:=((x shr 2) and $33333333)+(x and $33333333);
 x:=((x shr 4)+x) and $0f0f0f0f;
 x:=x+(x shr 8);
 x:=x+(x shr 16);
 result:=x and $3f;
end;
{$endif}

procedure MemorySwap(a,b:pointer;Size:TFLRESizeInt);
var Temp:TFLREInt32;
begin
 while Size>=SizeOf(TFLREInt32) do begin
  Temp:=TFLREUInt32(a^);
  TFLREUInt32(a^):=TFLREUInt32(b^);
  TFLREUInt32(b^):=Temp;
  inc(TFLREPtrUInt(a),SizeOf(TFLREUInt32));
  inc(TFLREPtrUInt(b),SizeOf(TFLREUInt32));
  dec(Size,SizeOf(TFLREUInt32));
 end;
 while Size>=SizeOf(TFLREUInt8) do begin
  Temp:=TFLREUInt8(a^);
  TFLREUInt8(a^):=TFLREUInt8(b^);
  TFLREUInt8(b^):=Temp;
  inc(TFLREPtrUInt(a),SizeOf(TFLREUInt8));
  inc(TFLREPtrUInt(b),SizeOf(TFLREUInt8));
  dec(Size,SizeOf(TFLREUInt8));
 end;
end;

procedure DirectIntroSort(Items:pointer;Left,Right,ElementSize:TFLRESizeInt;CompareFunc:TSortCompareFunction);
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TFLREUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TFLRESizeInt;
     end;
var Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TFLRESizeInt;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if Left<Right then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=Left;
  StackItem^.Right:=Right;
  StackItem^.Depth:=IntLog2((Right-Left)+1) shl 1;
  inc(StackItem);
  while TFLREPtrUInt(pointer(StackItem))>TFLREPtrUInt(pointer(@Stack[0])) do begin
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
           (CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iC*ElementSize]))>0) do begin
      MemorySwap(@PByteArray(Items)^[iA*ElementSize],@PByteArray(Items)^[iC*ElementSize],ElementSize);
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TFLREPtrUInt(pointer(StackItem))>=TFLREPtrUInt(pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        MemorySwap(@PByteArray(Items)^[(Left+Size)*ElementSize],@PByteArray(Items)^[Left*ElementSize],ElementSize);
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (CompareFunc(pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child+1)*ElementSize]))<0) then begin
         inc(Child);
        end;
        if CompareFunc(pointer(@PByteArray(Items)^[(Left+Parent)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]))<0 then begin
         MemorySwap(@PByteArray(Items)^[(Left+Parent)*ElementSize],@PByteArray(Items)^[(Left+Child)*ElementSize],ElementSize);
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
      if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Middle*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Middle*ElementSize],ElementSize);
      end;
      if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
      end;
      if CompareFunc(pointer(@PByteArray(Items)^[Middle*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (CompareFunc(pointer(@PByteArray(Items)^[i*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))<0) do begin
       inc(i);
      end;
      while (j>=i) and (CompareFunc(pointer(@PByteArray(Items)^[j*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        MemorySwap(@PByteArray(Items)^[i*ElementSize],@PByteArray(Items)^[j*ElementSize],ElementSize);
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

procedure IndirectIntroSort(Items:pointer;Left,Right:TFLRESizeInt;CompareFunc:TSortCompareFunction);
type PPointers=^TPointers;
     TPointers=array[0..$ffff] of pointer;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TFLRESizeInt;
     end;
var Depth,i,j,Middle,Size,Parent,Child:TFLRESizeInt;
    Pivot,Temp:pointer;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if Left<Right then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=Left;
  StackItem^.Right:=Right;
  StackItem^.Depth:=IntLog2((Right-Left)+1) shl 1;
  inc(StackItem);
  while TFLREPtrUInt(pointer(StackItem))>TFLREPtrUInt(pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    for i:=Left+1 to Right do begin
     Temp:=PPointers(Items)^[i];
     j:=i-1;
     if (j>=Left) and (CompareFunc(PPointers(Items)^[j],Temp)>0) then begin
      repeat
       PPointers(Items)^[j+1]:=PPointers(Items)^[j];
       dec(j);
      until not ((j>=Left) and (CompareFunc(PPointers(Items)^[j],Temp)>0));
      PPointers(Items)^[j+1]:=Temp;
     end;
    end;
   end else begin
    if (Depth=0) or (TFLREPtrUInt(pointer(StackItem))>=TFLREPtrUInt(pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     Temp:=nil;
     repeat
      if i>Left then begin
       dec(i);
       Temp:=PPointers(Items)^[Left+i];
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PPointers(Items)^[Left+Size];
        PPointers(Items)^[Left+Size]:=PPointers(Items)^[Left];
       end else begin
        break;
       end;
      end;
      Parent:=i;
      Child:=(i*2)+1;
      while Child<Size do begin
       if ((Child+1)<Size) and (CompareFunc(PPointers(Items)^[Left+Child+1],PPointers(Items)^[Left+Child])>0) then begin
        inc(Child);
       end;
       if CompareFunc(PPointers(Items)^[Left+Child],Temp)>0 then begin
        PPointers(Items)^[Left+Parent]:=PPointers(Items)^[Left+Child];
        Parent:=Child;
        Child:=(Parent*2)+1;
       end else begin
        break;
       end;
      end;
      PPointers(Items)^[Left+Parent]:=Temp;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if CompareFunc(PPointers(Items)^[Left],PPointers(Items)^[Middle])>0 then begin
       Temp:=PPointers(Items)^[Left];
       PPointers(Items)^[Left]:=PPointers(Items)^[Middle];
       PPointers(Items)^[Middle]:=Temp;
      end;
      if CompareFunc(PPointers(Items)^[Left],PPointers(Items)^[Right])>0 then begin
       Temp:=PPointers(Items)^[Left];
       PPointers(Items)^[Left]:=PPointers(Items)^[Right];
       PPointers(Items)^[Right]:=Temp;
      end;
      if CompareFunc(PPointers(Items)^[Middle],PPointers(Items)^[Right])>0 then begin
       Temp:=PPointers(Items)^[Middle];
       PPointers(Items)^[Middle]:=PPointers(Items)^[Right];
       PPointers(Items)^[Right]:=Temp;
      end;
     end;
     Pivot:=PPointers(Items)^[Middle];
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (CompareFunc(PPointers(Items)^[i],Pivot)<0) do begin
       inc(i);
      end;
      while (j>=i) and (CompareFunc(PPointers(Items)^[j],Pivot)>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PPointers(Items)^[i];
        PPointers(Items)^[i]:=PPointers(Items)^[j];
        PPointers(Items)^[j]:=Temp;
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

{$ifdef cpux64}
function InterlockedCompareExchange128Ex(Target,NewValue,Comperand:pointer):boolean; assembler; register;
asm
 push rbx
{$ifdef win64}
 push rdi
 push rsi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,qword ptr [r8+4]
 mov rax,qword ptr [r8+0]
{$else}
 mov rax,qword ptr [rdx+0]
 mov rdx,qword ptr [rdx+4]
{$endif}
 mov rcx,qword ptr [rsi+4]
 mov rbx,qword ptr [rsi+0]
 lock cmpxchg16b [rdi]
 setz al
{$ifdef win64}
 pop rsi
 pop rdi
{$endif}
 pop rbx
end;
{$endif}

{$ifdef cpu386}
{$ifndef ver130}
function InterlockedCompareExchange64Ex(Target,NewValue,Comperand:pointer):boolean; assembler; register;
asm
 push ebx
 push edi
 push esi
 mov edi,eax
 mov esi,edx
 mov edx,dword ptr [ecx+4]
 mov eax,dword ptr [ecx+0]
 mov ecx,dword ptr [esi+4]
 mov ebx,dword ptr [esi+0]
 lock cmpxchg8b [edi]
 setz al
 pop esi
 pop edi
 pop ebx
end;

function InterlockedCompareExchange64(var Target:TFLREInt64;NewValue:TFLREInt64;Comperand:TFLREInt64):TFLREInt64; assembler; register;
asm
 push ebx
 push edi
 mov edi,eax
 mov edx,dword ptr [Comperand+4]
 mov eax,dword ptr [Comperand+0]
 mov ecx,dword ptr [NewValue+4]
 mov ebx,dword ptr [NewValue+0]
 lock cmpxchg8b [edi]
 pop edi
 pop ebx
end;
{$endif}
{$endif}

{$ifndef fpc}
{$ifdef cpu386}
function InterlockedDecrement(var Target:TFLREInt32):TFLREInt32; assembler; register;
asm
 mov edx,$ffffffff
 xchg eax,edx
 lock xadd dword ptr [edx],eax
 dec eax
end;

function InterlockedIncrement(var Target:TFLREInt32):TFLREInt32; assembler; register;
asm
 mov edx,1
 xchg eax,edx
 lock xadd dword ptr [edx],eax
 inc eax
end;

function InterlockedExchange(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; assembler; register;
asm
 lock xchg dword ptr [eax],edx
 mov eax,edx
end;

function InterlockedExchangeAdd(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; assembler; register;
asm
 xchg edx,eax
 lock xadd dword ptr [edx],eax
end;

function InterlockedCompareExchange(var Target:TFLREInt32;NewValue,Comperand:TFLREInt32):TFLREInt32; assembler; register;
asm
 xchg ecx,eax
 lock cmpxchg dword ptr [ecx],edx
end;
{$else}
function InterlockedDecrement(var Target:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=Windows.InterlockedDecrement(Target);
end;

function InterlockedIncrement(var Target:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=Windows.InterlockedIncrement(Target);
end;

function InterlockedExchange(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=Windows.InterlockedExchange(Target,Source);
end;

function InterlockedExchangeAdd(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=Windows.InterlockedExchangeAdd(Target,Source);
end;

function InterlockedCompareExchange(var Target:TFLREInt32;NewValue,Comperand:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=Windows.InterlockedCompareExchange(Target,NewValue,Comperand);
end;
{$endif}
{$else}
function InterlockedDecrement(var Target:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=System.InterlockedDecrement(Target);
end;

function InterlockedIncrement(var Target:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=System.InterlockedIncrement(Target);
end;

function InterlockedExchange(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=System.InterlockedExchange(Target,Source);
end;

function InterlockedExchangeAdd(var Target:TFLREInt32;Source:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=System.InterlockedExchangeAdd(Target,Source);
end;

function InterlockedCompareExchange(var Target:TFLREInt32;NewValue,Comperand:TFLREInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=System.InterlockedCompareExchange(Target,NewValue,Comperand);
end;
{$endif}

function DCAS(Target,NewValue,Comperand:pointer):boolean;
{$ifdef cpu386} assembler; register;
{$define HasDCAS}
asm
 push ebx
 push edi
 push esi
 mov edi,eax
 mov esi,edx
 mov edx,dword ptr [ecx+4]
 mov eax,dword ptr [ecx+0]
 mov ecx,dword ptr [esi+4]
 mov ebx,dword ptr [esi+0]
 lock cmpxchg8b [edi]
 setz al
 pop esi
 pop edi
 pop ebx
end;
{$else}
{$ifdef cpux64} assembler; register;
{$define HasDCAS}
asm
 push rbx
{$ifdef windows}
 push rdi
 push rsi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,qword ptr [r8+8]
 mov rax,qword ptr [r8+0]
{$else}
 mov rax,qword ptr [rdx+0]
 mov rdx,qword ptr [rdx+8]
{$endif}
 mov rcx,qword ptr [rsi+8]
 mov rbx,qword ptr [rsi+0]
 lock cmpxchg16b [rdi]
 setz al
{$ifdef windows}
 pop rsi
 pop rdi
{$endif}
 pop rbx
end;
{$else}
{$undef HasDCAS}
begin
 result:=false;
end;
{$endif}
{$endif}

procedure ParallelLockEnter(Lock:PFLREParallelLock);{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 mov ecx,eax
 xor edx,edx
 not edx
 @TryAgain:
  xor eax,eax
  lock cmpxchg dword ptr [ecx],edx
  jz @End
  @Wait:
   rep nop // aka pause opcode
   mov eax,dword ptr [ecx]
   test eax,eax
  jnz @Wait
  jmp @TryAgain
 @End:          
end;
{$else}{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 xor rdx,rdx
 not rdx
 @TryAgain:
  xor rax,rax
{$ifdef windows}
  lock cmpxchg dword ptr [rcx],edx
{$else}
  lock cmpxchg dword ptr [rdi],edx
{$endif}
  jz @End
  @Wait:
   rep nop // aka pause opcode
{$ifdef windows}
   mov eax,dword ptr [rcx]
{$else}
   mov eax,dword ptr [rdi]
{$endif}
   test eax,eax
  jnz @Wait
  jmp @TryAgain
 @End:
end;
{$else}
begin
 while InterlockedCompareExchange(Lock^,-1,0)<>0 do begin
 end;
end;
{$endif}
{$endif}

procedure ParallelLockLeave(Lock:PFLREParallelLock);{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 xor edx,edx
 lock xchg dword ptr [eax],edx // xchg doesn't need lock actually (see IA-32 Intel® Architecture Software Developer’s Manual Volume 3A: System Programming Guide, Part 1, 7.1.2.1), but sure is sure and it does no harm on the performance
end;
{$else}{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 xor rax,rax
{$ifdef windows}
 lock xchg dword ptr [rcx],eax // xchg doesn't need lock actually (see IA-32 Intel® Architecture Software Developer’s Manual Volume 3A: System Programming Guide, Part 1, 7.1.2.1), but sure is sure and it does no harm on the performance
{$else}
 lock xchg dword ptr [rdi],eax // xchg doesn't need lock actually (see IA-32 Intel® Architecture Software Developer’s Manual Volume 3A: System Programming Guide, Part 1, 7.1.2.1), but sure is sure and it does no harm on the performance
{$endif}
end;
{$else}
begin
 InterlockedExchange(Lock^,0);
end;
{$endif}
{$endif}

function Max(const a,b:TFLREInt64):TFLREInt64;
begin
 if a<b then begin
  result:=b;
 end else begin
  result:=a;
 end;
end;

function UnicodeGetCategoryFromTable(c:TFLREUInt32):TFLREUInt32; {$ifdef caninline}inline;{$endif}
var Index:TFLREUInt32;
begin
 if c<=$10ffff then begin
  Index:=c shr PUCUUnicodeCategoryArrayBlockBits;
  result:=PUCUUnicodeCategoryArrayBlockData[PUCUUnicodeCategoryArrayIndexBlockData[PUCUUnicodeCategoryArrayIndexIndexData[Index shr PUCUUnicodeCategoryArrayIndexBlockBits],Index and PUCUUnicodeCategoryArrayIndexBlockMask],c and PUCUUnicodeCategoryArrayBlockMask];
 end else begin
  result:=0;
 end;
end;

function UnicodeGetScriptFromTable(c:TFLREUInt32):TFLREUInt32; {$ifdef caninline}inline;{$endif}
var Index:TFLREUInt32;
begin
 if c<=$10ffff then begin
  Index:=c shr PUCUUnicodeScriptArrayBlockBits;
  result:=PUCUUnicodeScriptArrayBlockData[PUCUUnicodeScriptArrayIndexBlockData[PUCUUnicodeScriptArrayIndexIndexData[Index shr PUCUUnicodeScriptArrayIndexBlockBits],Index and PUCUUnicodeScriptArrayIndexBlockMask],c and PUCUUnicodeScriptArrayBlockMask];
 end else begin
  result:=0;
 end;
end;

function UnicodeGetUpperCaseDeltaFromTable(c:TFLREUInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
var Index:TFLREUInt32;
begin
 if c<=$10ffff then begin
  Index:=c shr PUCUUnicodeUpperCaseDeltaArrayBlockBits;
  result:=PUCUUnicodeUpperCaseDeltaArrayBlockData[PUCUUnicodeUpperCaseDeltaArrayIndexBlockData[PUCUUnicodeUpperCaseDeltaArrayIndexIndexData[Index shr PUCUUnicodeUpperCaseDeltaArrayIndexBlockBits],Index and PUCUUnicodeUpperCaseDeltaArrayIndexBlockMask],c and PUCUUnicodeUpperCaseDeltaArrayBlockMask];
 end else begin
  result:=0;
 end;
end;

function UnicodeGetLowerCaseDeltaFromTable(c:TFLREUInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
var Index:TFLREUInt32;
begin
 if c<=$10ffff then begin
  Index:=c shr PUCUUnicodeLowerCaseDeltaArrayBlockBits;
  result:=PUCUUnicodeLowerCaseDeltaArrayBlockData[PUCUUnicodeLowerCaseDeltaArrayIndexBlockData[PUCUUnicodeLowerCaseDeltaArrayIndexIndexData[Index shr PUCUUnicodeLowerCaseDeltaArrayIndexBlockBits],Index and PUCUUnicodeLowerCaseDeltaArrayIndexBlockMask],c and PUCUUnicodeLowerCaseDeltaArrayBlockMask];
 end else begin
  result:=0;
 end;
end;

function UnicodeGetTitleCaseDeltaFromTable(c:TFLREUInt32):TFLREInt32; {$ifdef caninline}inline;{$endif}
var Index:TFLREUInt32;
begin
 if c<=$10ffff then begin
  Index:=c shr PUCUUnicodeTitleCaseDeltaArrayBlockBits;
  result:=PUCUUnicodeTitleCaseDeltaArrayBlockData[PUCUUnicodeTitleCaseDeltaArrayIndexBlockData[PUCUUnicodeTitleCaseDeltaArrayIndexIndexData[Index shr PUCUUnicodeTitleCaseDeltaArrayIndexBlockBits],Index and PUCUUnicodeTitleCaseDeltaArrayIndexBlockMask],c and PUCUUnicodeTitleCaseDeltaArrayBlockMask];
 end else begin
  result:=0;
 end;
end;

function UnicodeIsWord(c:TFLREUInt32):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(UnicodeGetCategoryFromTable(c) in [PUCUUnicodeCategoryLu,PUCUUnicodeCategoryLl,PUCUUnicodeCategoryLt,PUCUUnicodeCategoryLm,PUCUUnicodeCategoryLo,PUCUUnicodeCategoryNd,PUCUUnicodeCategoryNl,PUCUUnicodeCategoryNo,PUCUUnicodeCategoryPc]) or (c=ord('_'));
end;

function UnicodeIsIDBegin(c:TFLREUInt32):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(UnicodeGetCategoryFromTable(c) in [PUCUUnicodeCategoryLu,PUCUUnicodeCategoryLl,PUCUUnicodeCategoryLt,PUCUUnicodeCategoryLm,PUCUUnicodeCategoryLo,PUCUUnicodeCategoryNl,PUCUUnicodeCategoryNo,PUCUUnicodeCategoryPc]) or (c=ord('_'));
end;

function UnicodeIsIDPart(c:TFLREUInt32):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(UnicodeGetCategoryFromTable(c) in [PUCUUnicodeCategoryLu,PUCUUnicodeCategoryLl,PUCUUnicodeCategoryLt,PUCUUnicodeCategoryLm,PUCUUnicodeCategoryLo,PUCUUnicodeCategoryNd,PUCUUnicodeCategoryNl,PUCUUnicodeCategoryNo,PUCUUnicodeCategoryPc]) or (c=ord('_'));
end;

function UnicodeIsWhiteSpace(c:TFLREUInt32):boolean; {$ifdef caninline}inline;{$endif}
begin
//result:=UnicodeGetCategoryFromTable(c) in [PUCUUnicodeCategoryZs,PUCUUnicodeCategoryZp,PUCUUnicodeCategoryZl];
 result:=((c>=$0009) and (c<=$000d)) or (c=$0020) or (c=$00a0) or (c=$1680) or (c=$180e) or ((c>=$2000) and (c<=$200b)) or (c=$2028) or (c=$2029) or (c=$202f) or (c=$205f) or (c=$3000) or (c=$feff) or (c=$fffe);
end;

function UnicodeToUpper(c:TFLREUInt32):TFLREUInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=TFLREUInt32(TFLREInt32(TFLREInt32(c)+UnicodeGetUpperCaseDeltaFromTable(c)));
end;

function UnicodeToLower(c:TFLREUInt32):TFLREUInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=TFLREUInt32(TFLREInt32(TFLREInt32(c)+UnicodeGetLowerCaseDeltaFromTable(c)));
end;

function UnicodeToTitle(c:TFLREUInt32):TFLREUInt32; {$ifdef caninline}inline;{$endif}
begin
 result:=TFLREUInt32(TFLREInt32(TFLREInt32(c)+UnicodeGetTitleCaseDeltaFromTable(c)));
end;

function UTF32CharToUTF8(CharValue:TFLREUInt32):TFLRERawByteString;
var Data:array[0..{$ifdef FLREStrictUTF8}3{$else}5{$endif}] of TFLRERawByteChar;
    ResultLen:TFLRESizeInt;
begin
 if CharValue=0 then begin
  result:=#0;
 end else begin
  if CharValue<=$7f then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8(CharValue));
   ResultLen:=1;
  end else if CharValue<=$7ff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=2;
{$ifdef FLREStrictUTF8}
  end else if CharValue<=$d7ff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
   Data[2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=3;
  end else if CharValue<=$dfff then begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
{$endif}
  end else if CharValue<=$ffff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
   Data[2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=3;
  end else if CharValue<=$1fffff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
   Data[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
   Data[3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=4;
{$ifndef FLREStrictUTF8}
  end else if CharValue<=$3ffffff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
   Data[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
   Data[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
   Data[4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=5;
  end else if CharValue<=$7fffffff then begin
   Data[0]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
   Data[1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
   Data[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
   Data[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
   Data[4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
   Data[5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   ResultLen:=6;
{$endif}
  end else begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
  end;
  SetString(result,PFLRERawByteChar(@Data[0]),ResultLen);
 end;
end;

function FLREUTF32CharToUTF8Len(CharValue:TFLREUInt32):TFLRESizeInt;
begin
 if CharValue<=$7f then begin
  result:=1;
 end else if CharValue<=$7ff then begin
  result:=2;
 end else if CharValue<=$ffff then begin
  result:=3;
 end else if CharValue<=$1fffff then begin
  result:=4;
{$ifndef FLREStrictUTF8}
 end else if CharValue<=$3ffffff then begin
  result:=5;
 end else if CharValue<=$7fffffff then begin
  result:=6;
{$endif}
 end else begin
  result:=3;
 end;
end;

function FLREIsUTF8(const s:TFLRERawByteString):boolean;
var CodeUnit,CodePoints:TFLRESizeInt;
    State:TFLREUInt32;
begin
 State:=ucACCEPT;
 CodePoints:=0;
 for CodeUnit:=1 to length(s) do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
  case State of
   ucACCEPT:begin
    inc(CodePoints);
   end;
   ucERROR:begin
    result:=false;
    exit;
   end;
  end;
 end;
 result:=(State=ucACCEPT) and (length(s)<>CodePoints);
end;

function UTF8Validate(const s:TFLRERawByteString):boolean;
var CodeUnit:TFLRESizeInt;
    State:TFLREUInt32;
begin
 State:=ucACCEPT;
 for CodeUnit:=1 to length(s) do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
  if State=ucERROR then begin
   result:=false;
   exit;
  end;
 end;
 result:=State=ucACCEPT;
end;

function UTF8Get(const s:TFLRERawByteString):TFLRESizeInt;
var CodeUnit,CodePoints:TFLRESizeInt;
    State:TFLREUInt32;
begin
 State:=ucACCEPT;
 CodePoints:=0;
 for CodeUnit:=1 to length(s) do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
  case State of
   ucACCEPT:begin
    inc(CodePoints);
   end;
   ucERROR:begin
    result:=suNOUTF8;
    exit;
   end;
  end;
 end;
 if State=ucACCEPT then begin
  if length(s)<>CodePoints then begin
   result:=suISUTF8;
  end else begin
   result:=suPOSSIBLEUTF8;
  end;
 end else begin
  result:=suNOUTF8;
 end;
end;

function UTF8PtrGet(const s:PFLRERawByteChar;Len:TFLRESizeInt):TFLRESizeInt;
var CodeUnit,CodePoints:TFLRESizeInt;
    State:TFLREUInt32;
begin
 State:=ucACCEPT;
 CodePoints:=0;
 for CodeUnit:=0 to Len-1 do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
  case State of
   ucACCEPT:begin
    inc(CodePoints);
   end;
   ucERROR:begin
    result:=suNOUTF8;
    exit;
   end;
  end;
 end;
 if State=ucACCEPT then begin
  if length(s)<>CodePoints then begin
   result:=suISUTF8;
  end else begin
   result:=suPOSSIBLEUTF8;
  end;
 end else begin
  result:=suNOUTF8;
 end;
end;

procedure UTF8SafeInc(const s:TFLRERawByteString;var CodeUnit:TFLRESizeInt);
var Len:TFLRESizeInt;
    StartCodeUnit,State:TFLREUInt32;
begin
 Len:=length(s);
 if CodeUnit>0 then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  while CodeUnit<=Len do begin
   State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
   inc(CodeUnit);
   if State<=ucERROR then begin
    break;
   end;
  end;
  if State<>ucACCEPT then begin
   CodeUnit:=StartCodeUnit+1;
  end;
 end;
end;

procedure UTF8PtrSafeInc(const s:PFLRERawByteChar;var Len,CodeUnit:TFLRESizeInt);
var StartCodeUnit:TFLRESizeInt;
    State:TFLREUInt32;
begin
 if CodeUnit>=0 then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  while CodeUnit<Len do begin
   State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
   inc(CodeUnit);
   if State<=ucERROR then begin
    break;
   end;
  end;
  if State<>ucACCEPT then begin
   CodeUnit:=StartCodeUnit+1;
  end;
 end;
end;

procedure UTF8Inc(const s:TFLRERawByteString;var CodeUnit:TFLRESizeInt);
begin
 if (CodeUnit>0) and (CodeUnit<=length(s)) then begin
  inc(CodeUnit,UTF8CharSteps[s[CodeUnit]]);
 end;
end;

procedure UTF8PtrInc(const s:PFLRERawByteChar;Len:TFLRESizeInt;var CodeUnit:TFLRESizeInt);
begin
 if (CodeUnit>=0) and (CodeUnit<Len) then begin
  inc(CodeUnit,UTF8CharSteps[s[CodeUnit]]);
 end;
end;

procedure UTF8Dec(const s:TFLRERawByteString;var CodeUnit:TFLRESizeInt);
begin
 if (CodeUnit>=1) and (CodeUnit<=(length(s)+1)) then begin
  dec(CodeUnit);
  while CodeUnit>0 do begin
   if s[CodeUnit] in [#$80..#$bf] then begin
    dec(CodeUnit);
   end else begin
    break;
   end;
  end;
 end;
end;

procedure UTF8PtrDec(const s:PFLRERawByteChar;Len:TFLRESizeInt;var CodeUnit:TFLRESizeInt);
begin
 if (CodeUnit>0) and (CodeUnit<=Len) then begin
  dec(CodeUnit);
  while CodeUnit>=0 do begin
   if s[CodeUnit] in [#$80..#$bf] then begin
    dec(CodeUnit);
   end else begin
    break;
   end;
  end;
 end;
end;

procedure UTF8Delete(var s:TFLRERawByteString;CodeUnit:TFLRESizeInt);
begin
 if (CodeUnit>=1) and (CodeUnit<=length(s)) then begin
  Delete(s,CodeUnit,1);
  while ((CodeUnit>=1) and (CodeUnit<=length(s))) and (s[CodeUnit] in [#$80..#$bf]) do begin
   Delete(s,CodeUnit,1);
  end;
 end;
end;

function UTF8Length(const s:TFLRERawByteString):TFLRESizeInt; {$ifdef cpu386} assembler; register;
asm
 test eax,eax
 jz @End
  push esi
   cld
   mov esi,eax
   mov ecx,dword ptr [esi-4]
   xor edx,edx
   jecxz @LoopEnd
    @Loop:
      lodsb
      shl al,1
      js @IsASCIICharOrUTF8Begin
      jc @IsUTF8Part
      @IsASCIICharOrUTF8Begin:
       inc edx
      @IsUTF8Part:
     dec ecx
    jnz @Loop
   @LoopEnd:
   mov eax,edx
  pop esi
 @End:
end;
{$else}
var CodeUnit:TFLRESizeInt;
begin
 result:=0;
 for CodeUnit:=1 to length(s) do begin
  if (TFLREUInt8(s[CodeUnit]) and $c0)<>$80 then begin
   inc(result);
  end;
 end;
end;
{$endif}

function UTF8PtrLength(const s:TFLRERawByteString;Len:TFLRESizeInt):TFLRESizeInt;
{$ifdef cpu386} assembler; register;
asm
 test eax,eax
 jz @End
  push esi
   cld
   mov esi,eax
   mov ecx,edx
   xor edx,edx
   jecxz @LoopEnd
    @Loop:
      lodsb
      shl al,1
      js @IsASCIICharOrUTF8Begin
      jc @IsUTF8Part
      @IsASCIICharOrUTF8Begin:
       inc edx
      @IsUTF8Part:
     dec ecx
    jnz @Loop
   @LoopEnd:
   mov eax,edx
  pop esi
 @End:
end;
{$else}
var CodeUnit:TFLRESizeInt;
begin
 result:=0;
 for CodeUnit:=0 to Len-1 do begin
  if (TFLREUInt8(s[CodeUnit]) and $c0)<>$80 then begin
   inc(result);
  end;
 end;
end;
{$endif}

function UTF8LengthEx(const s:TFLRERawByteString):TFLRESizeInt;
var State:TFLREUInt32;
    CodeUnit:TFLRESizeInt;
begin
 result:=0;
 State:=ucACCEPT;
 for CodeUnit:=1 to length(s) do begin
  State:=UTF8DFATransitions[State+UTF8DFACharClasses[s[CodeUnit]]];
  case State of
   ucACCEPT:begin
    inc(result);
   end;
   ucERROR:begin
    result:=0;
    exit;
   end;
  end;
 end;
 if State=ucERROR then begin
  result:=0;
 end;
end;

function UTF8GetCodePoint(const s:TFLRERawByteString;CodeUnit:TFLRESizeInt):TFLRESizeInt;
var CurrentCodeUnit,Len:TFLRESizeInt;
begin
 if CodeUnit<1 then begin
  result:=-1;
 end else begin
  result:=0;
  CurrentCodeUnit:=1;
  Len:=length(s);
  while (CurrentCodeUnit<=Len) and (CurrentCodeUnit<>CodeUnit) do begin
   inc(result);
   inc(CurrentCodeUnit,UTF8CharSteps[s[CurrentCodeUnit]]);
  end;
 end;
end;

function UTF8PtrGetCodePoint(const s:PFLRERawByteChar;Len,CodeUnit:TFLRESizeInt):TFLRESizeInt;
var CurrentCodeUnit:TFLRESizeInt;
begin
 result:=-1;
 if CodeUnit<0 then begin
  CurrentCodeUnit:=0;
  while (CurrentCodeUnit<Len) and (CurrentCodeUnit<>CodeUnit) do begin
   inc(result);
   inc(CurrentCodeUnit,UTF8CharSteps[s[CurrentCodeUnit]]);
  end;
 end;
end;

function UTF8GetCodeUnit(const s:TFLRERawByteString;CodePoint:TFLRESizeInt):TFLRESizeInt;
var CurrentCodePoint,Len:TFLRESizeInt;
begin
 if CodePoint<0 then begin
  result:=0;
 end else begin
  result:=1;
  CurrentCodePoint:=0;
  Len:=length(s);
  while (result<=Len) and (CurrentCodePoint<>CodePoint) do begin
   inc(CurrentCodePoint);
   inc(result,UTF8CharSteps[s[result]]);
  end;
 end;
end;

function UTF8PtrGetCodeUnit(const s:TFLRERawByteString;Len,CodePoint:TFLRESizeInt):TFLRESizeInt;
var CurrentCodePoint:TFLRESizeInt;
begin
 result:=-1;
 if CodePoint>=0 then begin
  result:=1;
  CurrentCodePoint:=0;
  Len:=length(s);
  while (result<Len) and (CurrentCodePoint<>CodePoint) do begin
   inc(CurrentCodePoint);
   inc(result,UTF8CharSteps[s[result]]);
  end;
 end;
end;

function UTF8CodeUnitGetChar(const s:TFLRERawByteString;CodeUnit:TFLRESizeInt):TFLREUInt32;
var Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 if (CodeUnit>0) and (CodeUnit<=length(s)) then begin
  State:=ucACCEPT;
  for CodeUnit:=CodeUnit to length(s) do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=$fffd;
  end;
 end;
end;

function UTF8PtrCodeUnitGetChar(const s:PFLRERawByteChar;Len,CodeUnit:TFLRESizeInt):TFLREUInt32;
var Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 if (CodeUnit>=0) and (CodeUnit<Len) then begin
  State:=ucACCEPT;
  for CodeUnit:=CodeUnit to Len-1 do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=$fffd;
  end;
 end;
end;

function UTF8PtrCodeUnitGetCharFallback(const s:PFLRERawByteChar;Len,CodeUnit:TFLRESizeInt):TFLREUInt32;
var Value,CharClass,State:TFLREUInt32;
    StartCodeUnit:TFLRESizeInt;
begin
 result:=0;
 if (CodeUnit>=0) and (CodeUnit<Len) then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  for CodeUnit:=CodeUnit to Len-1 do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=TFLREUInt8(TFLRERawByteChar(s[StartCodeUnit]));
  end;
 end;
end;

function UTF8CodeUnitGetCharAndInc(const s:TFLRERawByteString;var CodeUnit:TFLRESizeInt):TFLREUInt32;
var Len:TFLRESizeInt;
    Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 Len:=length(s);
 if (CodeUnit>0) and (CodeUnit<=Len) then begin
  State:=ucACCEPT;
  while CodeUnit<=Len do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   inc(CodeUnit);
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=$fffd;
  end;
 end;
end;

function UTF8PtrCodeUnitGetCharAndInc(const s:PFLRERawByteChar;Len:TFLRESizeInt;var CodeUnit:TFLRESizeInt):TFLREUInt32;
var Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 if (CodeUnit>=0) and (CodeUnit<Len) then begin
  State:=ucACCEPT;
  while CodeUnit<Len do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   inc(CodeUnit);
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=$fffd;
  end;
 end;
end;

function UTF8CodeUnitGetCharFallback(const s:TFLRERawByteString;CodeUnit:TFLRESizeInt):TFLREUInt32;
var Len:TFLRESizeInt;
    StartCodeUnit,Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 Len:=length(s);
 if (CodeUnit>0) and (CodeUnit<=Len) then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  while CodeUnit<=Len do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   inc(CodeUnit);
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=TFLREUInt8(TFLRERawByteChar(s[StartCodeUnit]));
  end;
 end;
end;

function UTF8CodeUnitGetCharAndIncFallback(const s:TFLRERawByteString;var CodeUnit:TFLRESizeInt):TFLREUInt32;
var Len:TFLRESizeInt;
    StartCodeUnit,Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 Len:=length(s);
 if (CodeUnit>0) and (CodeUnit<=Len) then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  while CodeUnit<=Len do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   inc(CodeUnit);
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=TFLREUInt8(TFLRERawByteChar(s[StartCodeUnit]));
   CodeUnit:=StartCodeUnit+1;
  end;
 end;
end;

function UTF8PtrCodeUnitGetCharAndIncFallback(const s:PFLRERawByteChar;const Len:TFLRESizeInt;var CodeUnit:TFLRESizeInt):TFLREUInt32;
var StartCodeUnit,Value,CharClass,State:TFLREUInt32;
begin
 result:=0;
 if (CodeUnit>=0) and (CodeUnit<Len) then begin
  StartCodeUnit:=CodeUnit;
  State:=ucACCEPT;
  while CodeUnit<Len do begin
   Value:=TFLREUInt8(TFLRERawByteChar(s[CodeUnit]));
   inc(CodeUnit);
   CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
   result:=TFLREUInt8(TFLRERawByteChar(s[StartCodeUnit]));
   CodeUnit:=StartCodeUnit+1;
  end;
 end;
end;

function UTF8CodePointGetChar(const s:TFLRERawByteString;CodePoint:TFLRESizeInt;Fallback:boolean=false):TFLREUInt32;
begin
 result:=UTF8CodeUnitGetChar(s,UTF8GetCodeUnit(s,CodePoint));
end;

function UTF8GetCharLen(const s:TFLRERawByteString;i:TFLRESizeInt):TFLREUInt32;
begin
 if (i>0) and (i<=length(s)) then begin
  result:=UTF8CharSteps[s[i]];
 end else begin
  result:=0;
 end;
end;

function UTF8Pos(const FindStr,InStr:TFLRERawByteString):TFLRESizeInt;
var i,j,l:TFLRESizeInt;
    ok:boolean;
begin
 result:=0;
 i:=1;
 while i<=length(InStr) do begin
  l:=i+length(FindStr)-1;
  if l>length(InStr) then begin
   exit;
  end;
  ok:=true;
  for j:=1 to length(FindStr) do begin
   if InStr[i+j-1]<>FindStr[j] then begin
    ok:=false;
    break;
   end;
  end;
  if ok then begin
   result:=i;
   exit;
  end;
  inc(i,UTF8CharSteps[InStr[i]]);
 end;
end;

function UTF8Copy(const Str:TFLRERawByteString;Start,Len:TFLRESizeInt):TFLRERawByteString;
var CodeUnit:TFLRESizeInt;
begin
 result:='';
 CodeUnit:=1;
 while (CodeUnit<=length(Str)) and (Start>0) do begin
  inc(CodeUnit,UTF8CharSteps[Str[CodeUnit]]);
  dec(Start);
 end;
 if Start=0 then begin
  Start:=CodeUnit;
  while (CodeUnit<=length(Str)) and (Len>0) do begin
   inc(CodeUnit,UTF8CharSteps[Str[CodeUnit]]);
   dec(Len);
  end;
  if Start<CodeUnit then begin
   result:=copy(Str,Start,CodeUnit-Start);
  end;
 end;
end;

function UTF8UpperCase(const Str:TFLRERawByteString):TFLRERawByteString;
var CodeUnit,Len,ResultLen:TFLRESizeInt;
    StartCodeUnit,Value,CharClass,State,CharValue:TFLREUInt32;
    Data:PFLRERawByteChar;
begin
 result:='';
 CodeUnit:=1;
 Len:=length(Str);
 if Len>0 then begin
  SetLength(result,Len*{$ifdef FLREStrictUTF8}4{$else}6{$endif});
  Data:=@result[1];
  ResultLen:=0;
  while CodeUnit<=Len do begin
   StartCodeUnit:=CodeUnit;
   State:=ucACCEPT;
   CharValue:=0;
   while CodeUnit<=Len do begin
    Value:=TFLREUInt8(TFLRERawByteChar(Str[CodeUnit]));
    inc(CodeUnit);
    CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
    CharValue:=TFLREUInt8(TFLRERawByteChar(Str[StartCodeUnit]));
    CodeUnit:=StartCodeUnit+1;
   end;
   if CharValue<=$10ffff then begin
    Value:=CharValue shr PUCUUnicodeUpperCaseDeltaArrayBlockBits;
    CharValue:=TFLREUInt32(TFLREInt32(TFLREInt32(CharValue)+PUCUUnicodeUpperCaseDeltaArrayBlockData[PUCUUnicodeUpperCaseDeltaArrayIndexBlockData[PUCUUnicodeUpperCaseDeltaArrayIndexIndexData[Value shr PUCUUnicodeUpperCaseDeltaArrayIndexBlockBits],Value and PUCUUnicodeUpperCaseDeltaArrayIndexBlockMask],CharValue and PUCUUnicodeUpperCaseDeltaArrayBlockMask]));
   end;
   if CharValue<=$7f then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8(CharValue));
    inc(ResultLen);
   end else if CharValue<=$7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,2);
{$ifdef FLREStrictUTF8}
   end else if CharValue<=$d7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$dfff then begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
{$endif}
   end else if CharValue<=$ffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$1fffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,4);
{$ifndef FLREStrictUTF8}
   end else if CharValue<=$3ffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,5);
   end else if CharValue<=$7fffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
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

function UTF8LowerCase(const Str:TFLRERawByteString):TFLRERawByteString;
var CodeUnit,Len,ResultLen:TFLRESizeInt;
    StartCodeUnit,Value,CharClass,State,CharValue:TFLREUInt32;
    Data:PFLRERawByteChar;
begin
 result:='';
 CodeUnit:=1;
 Len:=length(Str);
 if Len>0 then begin
  SetLength(result,Len*{$ifdef FLREStrictUTF8}4{$else}6{$endif});
  Data:=@result[1];
  ResultLen:=0;
  while CodeUnit<=Len do begin
   StartCodeUnit:=CodeUnit;
   State:=ucACCEPT;
   CharValue:=0;
   while CodeUnit<=Len do begin
    Value:=TFLREUInt8(TFLRERawByteChar(Str[CodeUnit]));
    inc(CodeUnit);
    CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
    CharValue:=TFLREUInt8(TFLRERawByteChar(Str[StartCodeUnit]));
    CodeUnit:=StartCodeUnit+1;
   end;
   if CharValue<=$10ffff then begin
    Value:=CharValue shr PUCUUnicodeLowerCaseDeltaArrayBlockBits;
    CharValue:=TFLREUInt32(TFLREInt32(TFLREInt32(CharValue)+PUCUUnicodeLowerCaseDeltaArrayBlockData[PUCUUnicodeLowerCaseDeltaArrayIndexBlockData[PUCUUnicodeLowerCaseDeltaArrayIndexIndexData[Value shr PUCUUnicodeLowerCaseDeltaArrayIndexBlockBits],Value and PUCUUnicodeLowerCaseDeltaArrayIndexBlockMask],CharValue and PUCUUnicodeLowerCaseDeltaArrayBlockMask]));
   end;
   if CharValue<=$7f then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8(CharValue));
    inc(ResultLen);
   end else if CharValue<=$7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,2);
{$ifdef FLREStrictUTF8}
   end else if CharValue<=$d7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$dfff then begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
{$endif}
   end else if CharValue<=$ffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$1fffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,4);
{$ifndef FLREStrictUTF8}
   end else if CharValue<=$3ffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,5);
   end else if CharValue<=$7fffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
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

function UTF8Trim(const Str:TFLRERawByteString):TFLRERawByteString;
var i,j:TFLRESizeInt;
begin
 i:=1;
 while UnicodeIsWhiteSpace(UTF8CodeUnitGetChar(Str,i)) do begin
  inc(i,UTF8CharSteps[Str[i]]);
 end;
 j:=length(Str)+1;
 UTF8Dec(Str,j);
 while UnicodeIsWhiteSpace(UTF8CodeUnitGetChar(Str,j)) do begin
  UTF8Dec(Str,j);
 end;
 if (j<=length(Str)) and (Str[j]>=#80) then begin
  inc(j,TFLRESizeInt(UTF8GetCharLen(Str,j))-1);
 end;
 if i<=j then begin
  result:=copy(Str,i,(j-i)+1);
 end else begin
  result:='';
 end;
end;

function UTF8Correct(const Str:TFLRERawByteString):TFLRERawByteString;
var CodeUnit,Len,ResultLen:TFLRESizeInt;
    StartCodeUnit,Value,CharClass,State,CharValue:TFLREUInt32;
    Data:PFLRERawByteChar;
begin
 if (length(Str)=0) or UTF8Validate(Str) then begin
  result:=Str;
 end else begin
  result:='';
  CodeUnit:=1;
  Len:=length(Str);
  SetLength(result,Len*{$ifdef FLREStrictUTF8}4{$else}6{$endif});
  Data:=@result[1];
  ResultLen:=0;
  while CodeUnit<=Len do begin
   StartCodeUnit:=CodeUnit;
   State:=ucACCEPT;
   CharValue:=0;
   while CodeUnit<=Len do begin
    Value:=TFLREUInt8(TFLRERawByteChar(Str[CodeUnit]));
    inc(CodeUnit);
    CharClass:=UTF8DFACharClasses[TFLRERawByteChar(Value)];
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
    CharValue:=TFLREUInt8(TFLRERawByteChar(Str[StartCodeUnit]));
    CodeUnit:=StartCodeUnit+1;
   end;
   if CharValue<=$7f then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8(CharValue));
    inc(ResultLen);
   end else if CharValue<=$7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,2);
{$ifdef FLREStrictUTF8}
   end else if CharValue<=$d7ff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$dfff then begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
{$endif}
   end else if CharValue<=$ffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$1fffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,4);
{$ifndef FLREStrictUTF8}
   end else if CharValue<=$3ffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,5);            
   end else if CharValue<=$7fffffff then begin
    Data[ResultLen]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
    Data[ResultLen+1]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
    Data[ResultLen+2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    Data[ResultLen+3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
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

function UTF8FromLatin1(const Str:TFLRERawByteString):TFLRERawByteString;
var CodeUnit:TFLRESizeInt;
begin
 if UTF8Validate(Str) then begin
  result:=Str;
 end else begin
  result:='';
  for CodeUnit:=1 to length(Str) do begin
   result:=result+UTF32CharToUTF8(TFLREUInt8(TFLRERawByteChar(Str[CodeUnit])));
  end;
 end;
end;

function UTF8LevenshteinDistance(const s,t:TFLRERawByteString):TFLRESizeInt;
var d:array of array of TFLRESizeInt;
    n,m,i,j,ci,cj,oi,oj,Deletion,Insertion,Substitution:TFLRESizeInt;
    si,tj:TFLRESizeUInt;
begin
 n:=UTF8LengthEx(s);
 m:=UTF8LengthEx(t);
 oi:=1;
 oj:=1;
 while ((n>0) and (m>0)) and (UTF8CodeUnitGetChar(s,oi)=UTF8CodeUnitGetChar(t,oj)) do begin
  if (oi>0) and (oi<=length(s)) then begin
   inc(oi,UTF8CharSteps[s[oi]]);
  end else begin
   break;
  end;
  if (oj>0) and (oj<=length(t)) then begin
   inc(oj,UTF8CharSteps[t[oj]]);
  end else begin
   break;
  end;
  dec(n);
  dec(m);
 end;
 if ((n>0) and (m>0)) and (s[length(s)]=t[length(t)]) then begin
  ci:=length(s)+1;
  cj:=length(t)+1;
  UTF8Dec(s,ci);
  UTF8Dec(t,cj);
  while ((n>0) and (m>0)) and (UTF8CodeUnitGetChar(s,ci)=UTF8CodeUnitGetChar(t,cj)) do begin
   UTF8Dec(s,ci);
   UTF8Dec(t,cj);
   dec(n);
   dec(m);
  end;
 end;
 if n=0 then begin
  result:=m;
 end else if m=0 then begin
  result:=n;
 end else begin
  d:=nil;
  SetLength(d,n+1,m+1);
  for i:=0 to n do begin
   d[i,0]:=i;
  end;
  for j:=0 to m do begin
   d[0,j]:=j;
  end;
  ci:=oi;
  for i:=1 to n do begin
   si:=UTF8CodeUnitGetCharAndInc(s,ci);
   cj:=oj;
   for j:=1 to m do begin
    tj:=UTF8CodeUnitGetCharAndInc(t,cj);
    if si<>tj then begin
     Deletion:=d[i-1,j]+1;
     Insertion:=d[i,j-1]+1;
     Substitution:=d[i-1,j-1]+1;
     if Deletion<Insertion then begin
      if Deletion<Substitution then begin
       d[i,j]:=Deletion;
      end else begin
       d[i,j]:=Substitution;
      end;
     end else begin
      if Insertion<Substitution then begin
       d[i,j]:=Insertion;
      end else begin
       d[i,j]:=Substitution;
      end;
     end;
    end else begin
     d[i,j]:=d[i-1,j-1];
    end;
   end;
  end;
  result:=d[n,m];
  SetLength(d,0);
 end;
end;

function UTF8DamerauLevenshteinDistance(const s,t:TFLRERawByteString):TFLRESizeInt;
var d:array of array of TFLRESizeInt;
    n,m,i,j,ci,cj,oi,oj,Cost,Deletion,Insertion,Substitution,Transposition,Value:TFLRESizeInt;
    si,tj,lsi,ltj:TFLRESizeUInt;
begin
 n:=UTF8LengthEx(s);
 m:=UTF8LengthEx(t);
 oi:=1;
 oj:=1;
 while ((n>0) and (m>0)) and (UTF8CodeUnitGetChar(s,oi)=UTF8CodeUnitGetChar(t,oj)) do begin
  if (oi>0) and (oi<=length(s)) then begin
   inc(oi,UTF8CharSteps[s[oi]]);
  end else begin
   break;
  end;
  if (oj>0) and (oj<=length(t)) then begin
   inc(oj,UTF8CharSteps[t[oj]]);
  end else begin
   break;
  end;
  dec(n);
  dec(m);
 end;
 if ((n>0) and (m>0)) and (s[length(s)]=t[length(t)]) then begin
  ci:=length(s)+1;
  cj:=length(t)+1;
  UTF8Dec(s,ci);
  UTF8Dec(t,cj);
  while ((n>0) and (m>0)) and (UTF8CodeUnitGetChar(s,ci)=UTF8CodeUnitGetChar(t,cj)) do begin
   UTF8Dec(s,ci);
   UTF8Dec(t,cj);
   dec(n);
   dec(m);
  end;
 end;
 if n=0 then begin
  result:=m;
 end else if m=0 then begin
  result:=n;
 end else begin
  d:=nil;
  SetLength(d,n+1,m+1);
  for i:=0 to n do begin
   d[i,0]:=i;
  end;
  for j:=0 to m do begin
   d[0,j]:=j;
  end;
  ci:=oi;
  si:=0;
  for i:=1 to n do begin
   lsi:=si;
   si:=UTF8CodeUnitGetCharAndInc(s,ci);
   cj:=oj;
   tj:=0;
   for j:=1 to m do begin
    ltj:=tj;
    tj:=UTF8CodeUnitGetCharAndInc(t,cj);
    if si<>tj then begin
     Cost:=1;
    end else begin
     Cost:=0;
    end;
    Deletion:=d[i-1,j]+1;
    Insertion:=d[i,j-1]+1;
    Substitution:=d[i-1,j-1]+Cost;
    if Deletion<Insertion then begin
     if Deletion<Substitution then begin
      Value:=Deletion;
     end else begin
      Value:=Substitution;
     end;
    end else begin
     if Insertion<Substitution then begin
      Value:=Insertion;
     end else begin
      Value:=Substitution;
     end;
    end;
    if ((i>1) and (j>1)) and ((si=ltj) and (lsi=tj)) then begin
     Transposition:=d[i-2,j-2]+Cost;
     if Transposition<Value then begin
      Value:=Transposition;
     end;
    end;
    d[i,j]:=Value;
   end;
  end;
  result:=d[n,m];
  SetLength(d,0);
 end;
end;

function FLREStringLength(const s:TFLRERawByteString):TFLRESizeInt;
begin
 if FLREIsUTF8(s) then begin
  result:=UTF8Length(s);
 end else begin
  result:=length(s);
 end;
end;

function PopFirstOneBit(var Value:TFLREUInt32):TFLREUInt32;{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 push esi
 mov esi,Value
 xor eax,eax
 bsf ecx,dword ptr [esi]
 jz @Found
 xor eax,ecx
 xor edx,edx
 inc edx
 shl edx,cl
 xor dword ptr [esi],edx
 @Found:
 pop esi
end;
{$else}
{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifdef win64}
 mov eax,dword ptr [rcx]
{$else}
 mov eax,dword ptr [rdi]
{$endif}
{$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION < 20700)}
 mov edx,eax
 dec edx
{$else}
 lea edx,[eax-1]
{$ifend}
 bsf eax,eax
{$ifdef win64}
 and dword ptr [rcx],edx
{$else}
 and dword ptr [rdi],edx
{$endif}
end;
{$else}
begin
{$ifdef fpc}
 result:=BsfDWord(Value);
{$else}
 result:=(Value and (-Value))-1;
 result:=result-((result shr 1) and $55555555);
 result:=(result and $33333333)+((result shr 2) and $33333333);
 result:=(result+(result shr 4)) and $0f0f0f0f;
 inc(result,result shr 8);
 inc(result,result shr 16);
 result:=result and $1f;
{$endif}
 Value:=Value and (Value-1);
end;
{$endif}
{$endif}

{$ifdef cpux86_64}

// Thanks to Jeffrey Lim

function PtrPosCharSearch(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi
 movq xmm0,rsi
 pxor xmm1,xmm1
 pshufb xmm0,xmm1
 and rdi,-32
 and ecx,31
 movdqa xmm1,[rdi]
 movdqa xmm2,[rdi+16]
 pcmpeqb xmm1,xmm0
 pcmpeqb xmm2,xmm0
 pmovmskb eax,xmm1
 pmovmskb r10d,xmm2
 shl r10d,16
 or eax,r10d
 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm1,[rdi+rdx]
 movdqa xmm2,[rdi+rdx+16]
 pcmpeqb xmm1,xmm0
 pcmpeqb xmm2,xmm0
 por xmm2,xmm1
 pmovmskb eax,xmm2
 test eax,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 pmovmskb r10d,xmm1
 shl eax,16
 or eax,r10d
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosChar(const SearchChar:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSearch(@Text[Offset],TFLREUInt8(TFLRERawByteChar(SearchChar)),@Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

type TXMMValue=record
      Lo:TFLREQWord;
      Hi:TFLREQWord;
     end{$ifndef fpc}{$if CompilerVersion>=28.0}align 16{$ifend}{$endif};

function PtrPosCharSetOf2Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 pxor xmm2,xmm2
{$ifdef fpc}
 movdqa xmm3,[rip+XMM1Constant]
{$else}
 movdqa xmm3,[rel XMM1Constant]
{$endif}
 pshufb xmm0,xmm2
 pshufb xmm1,xmm3

 mov ecx,edi
 and rdi,-32
 and ecx,31
 movdqa xmm2,[rdi]
 movdqa xmm3,[rdi]
 movdqa xmm4,[rdi+16]
 movdqa xmm5,[rdi+16]
 pcmpeqb xmm2,xmm0
 pcmpeqb xmm3,xmm1
 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1
 por xmm3,xmm2
 por xmm5,xmm4
 pmovmskb eax,xmm3
 pmovmskb r10d,xmm5
 shl r10d,16
 or eax,r10d
 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm2,[rdi+rdx]
 movdqa xmm3,[rdi+rdx]
 movdqa xmm4,[rdi+rdx+16]
 movdqa xmm5,[rdi+rdx+16]
 pcmpeqb xmm2,xmm0
 pcmpeqb xmm3,xmm1
 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1
 por xmm3,xmm2
 por xmm5,xmm4
 por xmm5,xmm3
 pmovmskb eax,xmm5
 test eax,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 pmovmskb r10d,xmm3
 shl eax,16
 or eax,r10d
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf2(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf2Search(@Text[Offset],(TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),@Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf3Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi

 and rdi,-32
 and ecx,31

 pxor xmm9,xmm9
{$ifdef fpc}
 movdqa xmm10,[rip+XMM1Constant]
 movdqa xmm11,[rip+XMM2Constant]
{$else}
 movdqa xmm10,[rel XMM1Constant]
 movdqa xmm11,[rel XMM2Constant]
{$endif}

 movdqa xmm3,[rdi]
 movdqa xmm4,[rdi]
 movdqa xmm5,[rdi]

 pshufb xmm0,xmm9
 pshufb xmm1,xmm10
 pshufb xmm2,xmm11

 movdqa xmm6,[rdi+16]
 movdqa xmm7,[rdi+16]
 movdqa xmm8,[rdi+16]

 pcmpeqb xmm3,xmm0
 pcmpeqb xmm4,xmm1
 pcmpeqb xmm5,xmm2
 pcmpeqb xmm6,xmm0
 pcmpeqb xmm7,xmm1
 pcmpeqb xmm8,xmm2
 por xmm4,xmm3
 por xmm7,xmm6
 por xmm5,xmm4
 por xmm8,xmm7
 pmovmskb eax,xmm5
 pmovmskb r10d,xmm8
 shl r10d,16
 or eax,r10d
 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm3,[rdi+rdx]
 movdqa xmm4,[rdi+rdx]
 movdqa xmm5,[rdi+rdx]
 movdqa xmm6,[rdi+rdx+16]
 movdqa xmm7,[rdi+rdx+16]
 movdqa xmm8,[rdi+rdx+16]
 pcmpeqb xmm3,xmm0
 pcmpeqb xmm4,xmm1
 pcmpeqb xmm5,xmm2
 pcmpeqb xmm6,xmm0
 pcmpeqb xmm7,xmm1
 pcmpeqb xmm8,xmm2
 por xmm4,xmm3
 por xmm7,xmm6
 por xmm5,xmm4
 por xmm8,xmm7
 por xmm8,xmm5
 pmovmskb eax,xmm8
 test eax,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 pmovmskb r10d,xmm5
 shl eax,16
 or eax,r10d
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf3(const SearchChar0,SearchChar1,SearchChar2:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf3Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf4Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi

 and rdi,-32
 and ecx,31

 pxor xmm12,xmm12
{$ifdef fpc}
 movdqa xmm13,[rip+XMM1Constant]
 movdqa xmm14,[rip+XMM2Constant]
 movdqa xmm15,[rip+XMM3Constant]
{$else}
 movdqa xmm13,[rel XMM1Constant]
 movdqa xmm14,[rel XMM2Constant]
 movdqa xmm15,[rel XMM3Constant]
{$endif}

 movdqa xmm4,[rdi]
 movdqa xmm5,[rdi]
 movdqa xmm6,[rdi]
 movdqa xmm7,[rdi]

 pshufb xmm0,xmm12
 pshufb xmm1,xmm13
 pshufb xmm2,xmm14
 pshufb xmm3,xmm15

 movdqa xmm8,[rdi+16]
 movdqa xmm9,[rdi+16]
 movdqa xmm10,[rdi+16]
 movdqa xmm11,[rdi+16]

 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1
 pcmpeqb xmm6,xmm2
 pcmpeqb xmm7,xmm3
 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 por xmm5,xmm4
 por xmm7,xmm6
 por xmm9,xmm8
 por xmm11,xmm10
 por xmm7,xmm5
 por xmm11,xmm9
 pmovmskb eax,xmm7
 pmovmskb r10d,xmm11
 shl r10d,16
 or eax,r10d
 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm4,[rdi+rdx]
 movdqa xmm5,[rdi+rdx]
 movdqa xmm6,[rdi+rdx]
 movdqa xmm7,[rdi+rdx]
 movdqa xmm8,[rdi+rdx+16]
 movdqa xmm9,[rdi+rdx+16]
 movdqa xmm10,[rdi+rdx+16]
 movdqa xmm11,[rdi+rdx+16]
 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1
 pcmpeqb xmm6,xmm2
 pcmpeqb xmm7,xmm3
 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 por xmm5,xmm4
 por xmm7,xmm6
 por xmm9,xmm8
 por xmm11,xmm10
 por xmm7,xmm5
 por xmm11,xmm9
 por xmm11,xmm7
 pmovmskb eax,xmm11
 test eax,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 pmovmskb r10d,xmm7
 shl eax,16
 or eax,r10d
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf4(const SearchChar0,SearchChar1,SearchChar2,SearchChar3:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf4Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar3))) shl 24) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf5Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi

 and rdi,-16
 and ecx,15

 pxor xmm11,xmm11
{$ifdef fpc}
 movdqa xmm12,[rip+XMM1Constant]
 movdqa xmm13,[rip+XMM2Constant]
 movdqa xmm14,[rip+XMM3Constant]
 movdqa xmm15,[rip+XMM4Constant]
{$else}
 movdqa xmm12,[rel XMM1Constant]
 movdqa xmm13,[rel XMM2Constant]
 movdqa xmm14,[rel XMM3Constant]
 movdqa xmm15,[rel XMM4Constant]
{$endif}

 pshufb xmm0,xmm11
 pshufb xmm1,xmm12
 pshufb xmm2,xmm13
 pshufb xmm3,xmm14
 pshufb xmm4,xmm15

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm9,xmm12
 por xmm9,xmm11

 pmovmskb eax,xmm9

 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm9,xmm12
 por xmm9,xmm11

 pmovmskb eax,xmm9
 test eax,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf5(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf5Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar4))) shl 32) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar3))) shl 24) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf6Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
      XMM5Constant:TXMMValue=(Lo:TFLREQWord($0505050505050505);Hi:TFLREQWord($0505050505050505));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi
 movq xmm5,rsi

 and rdi,-16
 and ecx,15

 pxor xmm10,xmm10
{$ifdef fpc}
 movdqa xmm11,[rip+XMM1Constant]
 movdqa xmm12,[rip+XMM2Constant]
 movdqa xmm13,[rip+XMM3Constant]
 movdqa xmm14,[rip+XMM4Constant]
 movdqa xmm15,[rip+XMM5Constant]
{$else}
 movdqa xmm11,[rel XMM1Constant]
 movdqa xmm12,[rel XMM2Constant]
 movdqa xmm13,[rel XMM3Constant]
 movdqa xmm14,[rel XMM4Constant]
 movdqa xmm15,[rel XMM5Constant]
{$endif}

 pshufb xmm0,xmm10
 pshufb xmm1,xmm11
 pshufb xmm2,xmm12
 pshufb xmm3,xmm13
 pshufb xmm4,xmm14
 pshufb xmm5,xmm15

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]
 movdqa xmm13,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm11,xmm9
 por xmm13,xmm11

 pmovmskb eax,xmm13

 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]
 movdqa xmm13,[rdi+rdx]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm11,xmm9
 por xmm13,xmm11

 pmovmskb eax,xmm13
 test eax,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf6(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf6Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar5))) shl 40) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar4))) shl 32) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar3))) shl 24) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf7Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
      XMM5Constant:TXMMValue=(Lo:TFLREQWord($0505050505050505);Hi:TFLREQWord($0505050505050505));
      XMM6Constant:TXMMValue=(Lo:TFLREQWord($0606060606060606);Hi:TFLREQWord($0606060606060606));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi
 movq xmm5,rsi
 movq xmm6,rsi

 and rdi,-16
 and ecx,15

 pxor xmm9,xmm9
{$ifdef fpc}
 movdqa xmm10,[rip+XMM1Constant]
 movdqa xmm11,[rip+XMM2Constant]
 movdqa xmm12,[rip+XMM3Constant]
 movdqa xmm13,[rip+XMM4Constant]
 movdqa xmm14,[rip+XMM5Constant]
 movdqa xmm15,[rip+XMM6Constant]
{$else}
 movdqa xmm10,[rel XMM1Constant]
 movdqa xmm11,[rel XMM2Constant]
 movdqa xmm12,[rel XMM3Constant]
 movdqa xmm13,[rel XMM4Constant]
 movdqa xmm14,[rel XMM5Constant]
 movdqa xmm15,[rel XMM6Constant]
{$endif}

 pshufb xmm0,xmm9
 pshufb xmm1,xmm10
 pshufb xmm2,xmm11
 pshufb xmm3,xmm12
 pshufb xmm4,xmm13
 pshufb xmm5,xmm14
 pshufb xmm6,xmm15

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]
 movdqa xmm13,[rdi]
 movdqa xmm14,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm9,xmm14
 por xmm13,xmm11
 por xmm13,xmm9

 pmovmskb eax,xmm13

 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]
 movdqa xmm13,[rdi+rdx]
 movdqa xmm14,[rdi+rdx]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm9,xmm14
 por xmm13,xmm11
 por xmm13,xmm9

 pmovmskb eax,xmm13
 test eax,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf7(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf7Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar6))) shl 48) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar5))) shl 40) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar4))) shl 32) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar3))) shl 24) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf8Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
      XMM5Constant:TXMMValue=(Lo:TFLREQWord($0505050505050505);Hi:TFLREQWord($0505050505050505));
      XMM6Constant:TXMMValue=(Lo:TFLREQWord($0606060606060606);Hi:TFLREQWord($0606060606060606));
      XMM7Constant:TXMMValue=(Lo:TFLREQWord($0707070707070707);Hi:TFLREQWord($0707070707070707));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 mov ecx,edi

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi
 movq xmm5,rsi
 movq xmm6,rsi
 movq xmm7,rsi

 and rdi,-16
 and ecx,15

 pxor xmm8,xmm8
{$ifdef fpc}
 movdqa xmm9,[rip+XMM1Constant]
 movdqa xmm10,[rip+XMM2Constant]
 movdqa xmm11,[rip+XMM3Constant]
 movdqa xmm12,[rip+XMM4Constant]
 movdqa xmm13,[rip+XMM5Constant]
 movdqa xmm14,[rip+XMM6Constant]
 movdqa xmm15,[rip+XMM7Constant]
{$else}
 movdqa xmm9,[rel XMM1Constant]
 movdqa xmm10,[rel XMM2Constant]
 movdqa xmm11,[rel XMM3Constant]
 movdqa xmm12,[rel XMM4Constant]
 movdqa xmm13,[rel XMM5Constant]
 movdqa xmm14,[rel XMM6Constant]
 movdqa xmm15,[rel XMM7Constant]
{$endif}

 pshufb xmm0,xmm8
 pshufb xmm1,xmm9
 pshufb xmm2,xmm10
 pshufb xmm3,xmm11
 pshufb xmm4,xmm12
 pshufb xmm5,xmm13
 pshufb xmm6,xmm14
 pshufb xmm7,xmm15

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]
 movdqa xmm13,[rdi]
 movdqa xmm14,[rdi]
 movdqa xmm15,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6
 pcmpeqb xmm15,xmm7

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm15,xmm14
 por xmm11,xmm9
 por xmm15,xmm13
 por xmm15,xmm11

 pmovmskb eax,xmm15

 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]
 movdqa xmm13,[rdi+rdx]
 movdqa xmm14,[rdi+rdx]
 movdqa xmm15,[rdi+rdx]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6
 pcmpeqb xmm15,xmm7

 por xmm9,xmm8
 por xmm11,xmm10
 por xmm13,xmm12
 por xmm15,xmm14
 por xmm11,xmm9
 por xmm15,xmm13
 por xmm15,xmm11

 pmovmskb eax,xmm15
 test eax,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf8(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6,SearchChar7:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf8Search(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar7))) shl 56) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar6))) shl 48) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar5))) shl 40) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar4))) shl 32) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar3))) shl 24) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar2))) shl 16) or
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharPairSearch(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 pxor xmm2,xmm2
{$ifdef fpc}
 movdqa xmm3,[rip+XMM1Constant]
{$else}
 movdqa xmm3,[rel XMM1Constant]
{$endif}
 pshufb xmm0,xmm2
 pshufb xmm1,xmm3

 mov ecx,edi
 and rdi,-32
 and ecx,31
 movdqa xmm2,[rdi]
 movdqa xmm3,[rdi]
 movdqa xmm4,[rdi+16]
 movdqa xmm5,[rdi+16]
 pcmpeqb xmm2,xmm0
 pcmpeqb xmm3,xmm1
 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1

 pmovmskb r8d,xmm2
 pmovmskb r9d,xmm3
 pmovmskb r10d,xmm4
 pmovmskb r11d,xmm5

 shl r10,17
 shl r11d,16
 add ecx,1 // inc ecx
 or r9d,r11d
 lea rax,[r10+r8*2]

 and r9d,eax
 shr r9,cl
 bsf eax,r9d
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 sub rax,1 // dec rax
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm2,[rdi+rdx]
 movdqa xmm3,[rdi+rdx]
 movdqa xmm4,[rdi+rdx+16]
 movdqa xmm5,[rdi+rdx+16]

 shr rax,32

 pcmpeqb xmm2,xmm0
 pcmpeqb xmm3,xmm1
 pcmpeqb xmm4,xmm0
 pcmpeqb xmm5,xmm1

 pmovmskb r8d,xmm2
 pmovmskb r9d,xmm3
 pmovmskb r10d,xmm4
 pmovmskb r11d,xmm5

 lea rax,[rax+r8*2]
 shl r10,17
 shl r11d,16
 add rax,r10
 or r9d,r11d

 and r9d,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,r9d
 sub rdx,1 // dec rdx
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharPair(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharPairSearch(@Text[Offset],(TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),@Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf2Of2Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi

 mov ecx,edi
 pxor xmm4,xmm4
{$ifdef fpc}
 movdqa xmm5,[rip+XMM1Constant]
 movdqa xmm6,[rip+XMM2Constant]
 movdqa xmm7,[rip+XMM3Constant]
{$else}
 movdqa xmm5,[rel XMM1Constant]
 movdqa xmm6,[rel XMM2Constant]
 movdqa xmm7,[rel XMM3Constant]
{$endif}

 and rdi,-32
 and ecx,31

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]

 pshufb xmm0,xmm4
 pshufb xmm1,xmm5
 pshufb xmm2,xmm6
 pshufb xmm3,xmm7

 movdqa xmm12,[rdi+16]
 movdqa xmm13,[rdi+16]
 movdqa xmm14,[rdi+16]
 movdqa xmm15,[rdi+16]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm0
 pcmpeqb xmm13,xmm1
 pcmpeqb xmm14,xmm2
 pcmpeqb xmm15,xmm3

 por xmm8,xmm9
 por xmm10,xmm11
 por xmm12,xmm13
 por xmm14,xmm15

 pmovmskb r8d,xmm8
 pmovmskb r9d,xmm10
 pmovmskb r10d,xmm12
 pmovmskb r11d,xmm14

 shl r10,17
 shl r11d,16
 add ecx,1 // inc ecx
 or r9d,r11d
 lea rax,[r10+r8*2]

 and r9d,eax
 shr r9,cl
 bsf eax,r9d
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 sub rax,1 // dec rax
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx+16]
 movdqa xmm13,[rdi+rdx+16]
 movdqa xmm14,[rdi+rdx+16]
 movdqa xmm15,[rdi+rdx+16]

 shr rax,32

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm0
 pcmpeqb xmm13,xmm1
 pcmpeqb xmm14,xmm2
 pcmpeqb xmm15,xmm3

 por xmm8,xmm9
 por xmm10,xmm11
 por xmm12,xmm13
 por xmm14,xmm15

 pmovmskb r8d,xmm8
 pmovmskb r9d,xmm10
 pmovmskb r10d,xmm12
 pmovmskb r11d,xmm14

 lea rax,[rax+r8*2]
 shl r10,17
 shl r11d,16
 add rax,r10
 or r9d,r11d

 and r9d,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,r9d
 sub rdx,1 // dec rdx
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf2Of2(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf2Of2Search(@Text[Offset],
                                    (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                    TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                    @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf2Of3Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
      XMM5Constant:TXMMValue=(Lo:TFLREQWord($0505050505050505);Hi:TFLREQWord($0505050505050505));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi
 movq xmm5,rsi

 mov ecx,edi
 pxor xmm6,xmm6
{$ifdef fpc}
 movdqa xmm7,[rip+XMM1Constant]
 movdqa xmm8,[rip+XMM2Constant]
 movdqa xmm9,[rip+XMM3Constant]
 movdqa xmm10,[rip+XMM4Constant]
 movdqa xmm11,[rip+XMM5Constant]
{$else}
 movdqa xmm7,[rel XMM1Constant]
 movdqa xmm8,[rel XMM2Constant]
 movdqa xmm9,[rel XMM3Constant]
 movdqa xmm10,[rel XMM4Constant]
 movdqa xmm11,[rel XMM5Constant]
{$endif}

 and rdi,-16
 and ecx,15

 pshufb xmm0,xmm6
 pshufb xmm1,xmm7
 pshufb xmm2,xmm8
 pshufb xmm3,xmm9
 pshufb xmm4,xmm10
 pshufb xmm5,xmm11

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]
 movdqa xmm13,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5

 por xmm8,xmm9
 por xmm11,xmm12
 por xmm8,xmm10
 por xmm11,xmm13

 pmovmskb r8d,xmm8
 pmovmskb r10d,xmm11

 add ecx,1 // inc ecx
 lea rax,[r8+r8]

 and r10d,eax
 shr r10d,cl
 bsf eax,r10d
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 sub rax,1 // dec rax
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]
 movdqa xmm13,[rdi+rdx]

 shr rax,16

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5

 por xmm8,xmm9
 por xmm11,xmm12
 por xmm8,xmm10
 por xmm11,xmm13

 pmovmskb r8d,xmm8
 pmovmskb r10d,xmm11

 lea rax,[rax+r8*2]

 and r10d,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,r10d
 sub rdx,1 // dec rdx
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf2Of3(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf2Of3Search(@Text[Offset],
                                    (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                    TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                    @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharSetOf2Of4Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM4Constant:TXMMValue=(Lo:TFLREQWord($0404040404040404);Hi:TFLREQWord($0404040404040404));
      XMM5Constant:TXMMValue=(Lo:TFLREQWord($0505050505050505);Hi:TFLREQWord($0505050505050505));
      XMM6Constant:TXMMValue=(Lo:TFLREQWord($0606060606060606);Hi:TFLREQWord($0606060606060606));
      XMM7Constant:TXMMValue=(Lo:TFLREQWord($0707070707070707);Hi:TFLREQWord($0707070707070707));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi
 movq xmm4,rsi
 movq xmm5,rsi
 movq xmm6,rsi
 movq xmm7,rsi

 mov ecx,edi
 pxor xmm8,xmm8
{$ifdef fpc}
 movdqa xmm9,[rip+XMM1Constant]
 movdqa xmm10,[rip+XMM2Constant]
 movdqa xmm11,[rip+XMM3Constant]
 movdqa xmm12,[rip+XMM4Constant]
 movdqa xmm13,[rip+XMM5Constant]
 movdqa xmm14,[rip+XMM6Constant]
 movdqa xmm15,[rip+XMM7Constant]
{$else}
 movdqa xmm9,[rel XMM1Constant]
 movdqa xmm10,[rel XMM2Constant]
 movdqa xmm11,[rel XMM3Constant]
 movdqa xmm12,[rel XMM4Constant]
 movdqa xmm13,[rel XMM5Constant]
 movdqa xmm14,[rel XMM6Constant]
 movdqa xmm15,[rel XMM7Constant]
{$endif}

 and rdi,-16
 and ecx,15

 pshufb xmm0,xmm8
 pshufb xmm1,xmm9
 pshufb xmm2,xmm10
 pshufb xmm3,xmm11
 pshufb xmm4,xmm12
 pshufb xmm5,xmm13
 pshufb xmm6,xmm14
 pshufb xmm7,xmm15

 movdqa xmm8,[rdi]
 movdqa xmm9,[rdi]
 movdqa xmm10,[rdi]
 movdqa xmm11,[rdi]
 movdqa xmm12,[rdi]
 movdqa xmm13,[rdi]
 movdqa xmm14,[rdi]
 movdqa xmm15,[rdi]

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6
 pcmpeqb xmm15,xmm7

 por xmm8,xmm9
 por xmm10,xmm11
 por xmm12,xmm13
 por xmm14,xmm15
 por xmm8,xmm10
 por xmm12,xmm14

 pmovmskb r8d,xmm8
 pmovmskb r10d,xmm12

 add ecx,1 // inc ecx
 lea rax,[r8+r8]

 and r10d,eax
 shr r10d,cl
 bsf eax,r10d
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 sub rax,1 // dec rax
 jmp @Done

@DoMainLoop:
 add rdi,16
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm8,[rdi+rdx]
 movdqa xmm9,[rdi+rdx]
 movdqa xmm10,[rdi+rdx]
 movdqa xmm11,[rdi+rdx]
 movdqa xmm12,[rdi+rdx]
 movdqa xmm13,[rdi+rdx]
 movdqa xmm14,[rdi+rdx]
 movdqa xmm15,[rdi+rdx]

 shr rax,16

 pcmpeqb xmm8,xmm0
 pcmpeqb xmm9,xmm1
 pcmpeqb xmm10,xmm2
 pcmpeqb xmm11,xmm3
 pcmpeqb xmm12,xmm4
 pcmpeqb xmm13,xmm5
 pcmpeqb xmm14,xmm6
 pcmpeqb xmm15,xmm7

 por xmm8,xmm9
 por xmm10,xmm11
 por xmm12,xmm13
 por xmm14,xmm15
 por xmm8,xmm10
 por xmm12,xmm14

 pmovmskb r8d,xmm8
 pmovmskb r10d,xmm12

 lea rax,[rax+r8*2]

 and r10d,eax
 jne @Found
 add rdi,16
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,r10d
 sub rdx,1 // dec rdx
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharSetOf2Of4(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharSetOf2Of4Search(@Text[Offset],
                                    (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar1))) shl 8) or
                                    TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchChar0))),
                                    @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharRangeSearch(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM126Constant:TXMMValue=(Lo:TFLREQWord($7e7e7e7e7e7e7e7e);Hi:TFLREQWord($7e7e7e7e7e7e7e7e));
      XMM127Constant:TXMMValue=(Lo:TFLREQWord($7f7f7f7f7f7f7f7f);Hi:TFLREQWord($7f7f7f7f7f7f7f7f));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi

 mov ecx,edi
 pxor xmm4,xmm4
{$ifdef fpc}
 movdqa xmm5,[rip+XMM1Constant]
 movdqa xmm6,[rip+XMM126Constant]
 movdqa xmm7,[rip+XMM127Constant]
{$else}
 movdqa xmm5,[rel XMM1Constant]
 movdqa xmm6,[rel XMM126Constant]
 movdqa xmm7,[rel XMM127Constant]
{$endif}

 and rdi,-32
 and ecx,31

 pshufb xmm0,xmm4
 pshufb xmm1,xmm5
 psubb xmm6,xmm1
 psubb xmm7,xmm1
 paddb xmm6,xmm0

 movdqa xmm2,[rdi]
 movdqa xmm3,[rdi+16]
 paddb xmm2,xmm7
 paddb xmm3,xmm7
 pcmpgtb xmm2,xmm6
 pcmpgtb xmm3,xmm6
 pmovmskb eax,xmm2
 pmovmskb r10d,xmm3
 shl r10d,16
 or eax,r10d
 shr eax,cl
 bsf eax,eax
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm2,[rdi+rdx]
 movdqa xmm3,[rdi+rdx+16]
 paddb xmm2,xmm7
 paddb xmm3,xmm7
 pcmpgtb xmm2,xmm6
 pcmpgtb xmm3,xmm6
 por xmm3,xmm2
 pmovmskb eax,xmm3
 test eax,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 pmovmskb r10d,xmm2
 shl eax,16
 or eax,r10d
 bsf eax,eax
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharRange(const SearchFromChar,SearchToChar:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharRangeSearch(@Text[Offset],
                                (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchToChar))) shl 8) or
                                TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchFromChar))),
                                @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

function PtrPosCharRangeOf2Search(const p:pointer;const v:TFLREQWord;const pEnd:pointer):TFLREPtrInt; assembler; register;
{$if defined(fpc) and (fpc_version>=3)}{$push}{$codealign localmin=16}{$codealign varmin=16}{$codealign constmin=16}{$ifend}
const XMM1Constant:TXMMValue=(Lo:TFLREQWord($0101010101010101);Hi:TFLREQWord($0101010101010101));
      XMM2Constant:TXMMValue=(Lo:TFLREQWord($0202020202020202);Hi:TFLREQWord($0202020202020202));
      XMM3Constant:TXMMValue=(Lo:TFLREQWord($0303030303030303);Hi:TFLREQWord($0303030303030303));
      XMM126Constant:TXMMValue=(Lo:TFLREQWord($7e7e7e7e7e7e7e7e);Hi:TFLREQWord($7e7e7e7e7e7e7e7e));
      XMM127Constant:TXMMValue=(Lo:TFLREQWord($7f7f7f7f7f7f7f7f);Hi:TFLREQWord($7f7f7f7f7f7f7f7f));
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
asm
{$ifdef Windows}
 // Win64 ABI to System-V ABI wrapper
 push rsi
 push rdi
 mov rdi,rcx
 mov rsi,rdx
 mov rdx,r8
//mov rcx,r9
{$endif}

 movq xmm0,rsi
 movq xmm1,rsi
 movq xmm2,rsi
 movq xmm3,rsi

 mov ecx,edi
 pxor xmm8,xmm8
{$ifdef fpc}
 movdqa xmm9,[rip+XMM1Constant]
 movdqa xmm10,[rip+XMM2Constant]
 movdqa xmm11,[rip+XMM3Constant]
 movdqa xmm12,[rip+XMM126Constant]
 movdqa xmm13,[rip+XMM127Constant]
 movdqa xmm14,[rip+XMM126Constant]
 movdqa xmm15,[rip+XMM127Constant]
{$else}
 movdqa xmm9,[rel XMM1Constant]
 movdqa xmm10,[rel XMM2Constant]
 movdqa xmm11,[rel XMM3Constant]
 movdqa xmm12,[rel XMM126Constant]
 movdqa xmm13,[rel XMM127Constant]
 movdqa xmm14,[rel XMM126Constant]
 movdqa xmm15,[rel XMM127Constant]
{$endif}

 and rdi,-32
 and ecx,31

 pshufb xmm0,xmm8
 pshufb xmm1,xmm9
 pshufb xmm2,xmm10
 pshufb xmm3,xmm11

 psubb xmm12,xmm1
 psubb xmm13,xmm1
 psubb xmm14,xmm3
 psubb xmm15,xmm3
 paddb xmm12,xmm0
 paddb xmm14,xmm2

 movdqa xmm4,[rdi]
 movdqa xmm5,[rdi]
 movdqa xmm6,[rdi+16]
 movdqa xmm7,[rdi+16]
 paddb xmm4,xmm13
 paddb xmm5,xmm15
 paddb xmm6,xmm13
 paddb xmm7,xmm15
 pcmpgtb xmm4,xmm12
 pcmpgtb xmm5,xmm14
 pcmpgtb xmm6,xmm12
 pcmpgtb xmm7,xmm14

 pmovmskb r8d,xmm4
 pmovmskb r9d,xmm5
 pmovmskb r10d,xmm5
 pmovmskb r11d,xmm5

 shl r10,17
 shl r11d,16
 add ecx,1 // inc ecx
 or r9d,r11d
 lea rax,[r10+r8*2]

 and r9d,eax
 shr r9,cl
 bsf eax,r9d
 jz @DoMainLoop
 add rdi,rcx
 add rax,rdi
 cmp rax,rdx
 jae @Fail
 sub rax,1 // dec rax
 jmp @Done

@DoMainLoop:
 add rdi,32
 sub rdi,rdx
 jnc @Fail

@MainLoop:
 movdqa xmm4,[rdi+rdx]
 movdqa xmm5,[rdi+rdx]
 movdqa xmm6,[rdi+rdx+16]
 movdqa xmm7,[rdi+rdx+16]

 shr rax,32

 paddb xmm4,xmm13
 paddb xmm5,xmm15
 paddb xmm6,xmm13
 paddb xmm7,xmm15
 pcmpgtb xmm4,xmm12
 pcmpgtb xmm5,xmm14
 pcmpgtb xmm6,xmm12
 pcmpgtb xmm7,xmm14

 pmovmskb r8d,xmm4
 pmovmskb r9d,xmm5
 pmovmskb r10d,xmm5
 pmovmskb r11d,xmm5

 lea rax,[rax+r8*2]
 shl r10,17
 shl r11d,16
 add rax,r10
 or r9d,r11d

 and r9d,eax
 jne @Found
 add rdi,32
 jnc @MainLoop

@Fail:
 xor eax,eax
 jmp @Done

@Found:
 bsf eax,r9d
 sub rdx,1 // dec rdx
 add rax,rdi
 jc @Fail
 add rax,rdx
@Done:
{$ifdef Windows}
 pop rdi
 pop rsi
{$endif}
end;

function PtrPosCharRangeOf2(const SearchFromChar0,SearchToChar0,SearchFromChar1,SearchToChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
begin
 if Offset<TextLength then begin
  result:=PtrPosCharRangeOf2Search(@Text[Offset],
                                   (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchToChar1))) shl 24) or
                                   (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchFromChar1))) shl 16) or
                                   (TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchToChar0))) shl 8) or
                                   TFLREQWord(TFLREUInt8(TFLRERawByteChar(SearchFromChar0))),
                                   @Text[TextLength]);
  if result=0 then begin
   result:=-1;
  end else begin
   dec(result,TFLREPtrInt(pointer(@Text[Offset])));
  end;
 end else begin
  result:=-1;
 end;
end;

{$else}
function PtrPosChar(const SearchChar:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask,XoredChunk,Size:TFLREPtrUInt;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask:=TFLREUInt8(SearchChar);
  XorMask:=XorMask or (XorMask shl 8);
  XorMask:=XorMask or (XorMask shl 16);
{$ifdef cpu64}
  XorMask:=XorMask or (XorMask shl 32);
{$endif}

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    XoredChunk:=CurrentChunk^ xor XorMask;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if (((XoredChunk+MaskA) and not XoredChunk) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^=SearchChar then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    XoredChunk:=CurrentChunk^ xor XorMask;
    if (((XoredChunk+MaskA) and not XoredChunk) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5]=Pattern then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7]=SearchChar then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk:=XoredChunk xor XorMask;
     if TFLREUInt8(SearchChar)=0 then begin
      // Special case
      XoredChunk:=not XoredChunk;
      while (XoredChunk<>0) and ((XoredChunk and $ff)<>$ff) do begin
       XoredChunk:=XoredChunk shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while (XoredChunk<>0) and ((XoredChunk and $ff)<>TFLREUInt8(SearchChar)) do begin
       XoredChunk:=XoredChunk shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if XoredChunk<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^=SearchChar then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf2(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XoredChunk0,XoredChunk1,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      while ((XoredChunk0 or XoredChunk1)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf3(const SearchChar0,SearchChar1,SearchChar2:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XoredChunk0,XoredChunk1,XoredChunk2,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and (TFLREUInt8(SearchChar2)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf4(const SearchChar0,SearchChar1,SearchChar2,SearchChar3:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XorMask3,XoredChunk0,XoredChunk1,XoredChunk2,XoredChunk3,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  XorMask3:=TFLREUInt8(SearchChar3);
  XorMask3:=XorMask3 or (XorMask3 shl 8);
  XorMask3:=XorMask3 or (XorMask3 shl 16);
{$ifdef cpu64}
  XorMask3:=XorMask3 or (XorMask3 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2,SearchChar3];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
    XoredChunk3:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2) or
        ((XoredChunk3+MaskA) and not XoredChunk3)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2) or
         ((XoredChunk3+MaskA) and not XoredChunk3)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     XoredChunk3:=XoredChunk3 xor XorMask3;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and
        (TFLREUInt8(SearchChar2)=0) and (TFLREUInt8(SearchChar3)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      XoredChunk3:=not XoredChunk3;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) and
            ((XoredChunk3 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) and
            ((XoredChunk3 and $ff)<>TFLREUInt8(SearchChar3)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf5(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XorMask3,XorMask4,XoredChunk0,XoredChunk1,XoredChunk2,XoredChunk3,XoredChunk4,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  XorMask3:=TFLREUInt8(SearchChar3);
  XorMask3:=XorMask3 or (XorMask3 shl 8);
  XorMask3:=XorMask3 or (XorMask3 shl 16);
{$ifdef cpu64}
  XorMask3:=XorMask3 or (XorMask3 shl 32);
{$endif}

  XorMask4:=TFLREUInt8(SearchChar4);
  XorMask4:=XorMask4 or (XorMask4 shl 8);
  XorMask4:=XorMask4 or (XorMask4 shl 16);
{$ifdef cpu64}
  XorMask4:=XorMask4 or (XorMask4 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
    XoredChunk3:=0;
    XoredChunk4:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2) or
        ((XoredChunk3+MaskA) and not XoredChunk3) or
        ((XoredChunk4+MaskA) and not XoredChunk4)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2) or
         ((XoredChunk3+MaskA) and not XoredChunk3) or
         ((XoredChunk4+MaskA) and not XoredChunk4)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     XoredChunk3:=XoredChunk3 xor XorMask3;
     XoredChunk4:=XoredChunk4 xor XorMask4;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and
        (TFLREUInt8(SearchChar2)=0) and (TFLREUInt8(SearchChar3)=0) and
        (TFLREUInt8(SearchChar4)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      XoredChunk3:=not XoredChunk3;
      XoredChunk4:=not XoredChunk4;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) and
            ((XoredChunk3 and $ff)<>$ff) and
            ((XoredChunk4 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) and
            ((XoredChunk3 and $ff)<>TFLREUInt8(SearchChar3)) and
            ((XoredChunk4 and $ff)<>TFLREUInt8(SearchChar4)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf6(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XorMask3,XorMask4,XorMask5,XoredChunk0,XoredChunk1,XoredChunk2,XoredChunk3,XoredChunk4,XoredChunk5,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  XorMask3:=TFLREUInt8(SearchChar3);
  XorMask3:=XorMask3 or (XorMask3 shl 8);
  XorMask3:=XorMask3 or (XorMask3 shl 16);
{$ifdef cpu64}
  XorMask3:=XorMask3 or (XorMask3 shl 32);
{$endif}

  XorMask4:=TFLREUInt8(SearchChar4);
  XorMask4:=XorMask4 or (XorMask4 shl 8);
  XorMask4:=XorMask4 or (XorMask4 shl 16);
{$ifdef cpu64}
  XorMask4:=XorMask4 or (XorMask4 shl 32);
{$endif}

  XorMask5:=TFLREUInt8(SearchChar5);
  XorMask5:=XorMask5 or (XorMask5 shl 8);
  XorMask5:=XorMask5 or (XorMask5 shl 16);
{$ifdef cpu64}
  XorMask5:=XorMask5 or (XorMask5 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
    XoredChunk3:=0;
    XoredChunk4:=0;
    XoredChunk5:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2) or
        ((XoredChunk3+MaskA) and not XoredChunk3) or
        ((XoredChunk4+MaskA) and not XoredChunk4) or
        ((XoredChunk5+MaskA) and not XoredChunk5)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2) or
         ((XoredChunk3+MaskA) and not XoredChunk3) or
         ((XoredChunk4+MaskA) and not XoredChunk4) or
         ((XoredChunk5+MaskA) and not XoredChunk5)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     XoredChunk3:=XoredChunk3 xor XorMask3;
     XoredChunk4:=XoredChunk4 xor XorMask4;
     XoredChunk5:=XoredChunk5 xor XorMask5;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and
        (TFLREUInt8(SearchChar2)=0) and (TFLREUInt8(SearchChar3)=0) and
        (TFLREUInt8(SearchChar4)=0) and (TFLREUInt8(SearchChar5)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      XoredChunk3:=not XoredChunk3;
      XoredChunk4:=not XoredChunk4;
      XoredChunk5:=not XoredChunk5;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) and
            ((XoredChunk3 and $ff)<>$ff) and
            ((XoredChunk4 and $ff)<>$ff) and
            ((XoredChunk5 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) and
            ((XoredChunk3 and $ff)<>TFLREUInt8(SearchChar3)) and
            ((XoredChunk4 and $ff)<>TFLREUInt8(SearchChar4)) and
            ((XoredChunk5 and $ff)<>TFLREUInt8(SearchChar5)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf7(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XorMask3,XorMask4,XorMask5,XorMask6,XoredChunk0,XoredChunk1,XoredChunk2,XoredChunk3,XoredChunk4,XoredChunk5,XoredChunk6,CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  XorMask3:=TFLREUInt8(SearchChar3);
  XorMask3:=XorMask3 or (XorMask3 shl 8);
  XorMask3:=XorMask3 or (XorMask3 shl 16);
{$ifdef cpu64}
  XorMask3:=XorMask3 or (XorMask3 shl 32);
{$endif}

  XorMask4:=TFLREUInt8(SearchChar4);
  XorMask4:=XorMask4 or (XorMask4 shl 8);
  XorMask4:=XorMask4 or (XorMask4 shl 16);
{$ifdef cpu64}
  XorMask4:=XorMask4 or (XorMask4 shl 32);
{$endif}

  XorMask5:=TFLREUInt8(SearchChar5);
  XorMask5:=XorMask5 or (XorMask5 shl 8);
  XorMask5:=XorMask5 or (XorMask5 shl 16);
{$ifdef cpu64}
  XorMask5:=XorMask5 or (XorMask5 shl 32);
{$endif}

  XorMask6:=TFLREUInt8(SearchChar6);
  XorMask6:=XorMask6 or (XorMask6 shl 8);
  XorMask6:=XorMask6 or (XorMask6 shl 16);
{$ifdef cpu64}
  XorMask6:=XorMask6 or (XorMask6 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
    XoredChunk6:=CurrentChunkValue xor XorMask6;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
    XoredChunk3:=0;
    XoredChunk4:=0;
    XoredChunk5:=0;
    XoredChunk6:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2) or
        ((XoredChunk3+MaskA) and not XoredChunk3) or
        ((XoredChunk4+MaskA) and not XoredChunk4) or
        ((XoredChunk5+MaskA) and not XoredChunk5) or
        ((XoredChunk6+MaskA) and not XoredChunk6)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
    XoredChunk6:=CurrentChunkValue xor XorMask6;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2) or
         ((XoredChunk3+MaskA) and not XoredChunk3) or
         ((XoredChunk4+MaskA) and not XoredChunk4) or
         ((XoredChunk5+MaskA) and not XoredChunk5) or
         ((XoredChunk6+MaskA) and not XoredChunk6)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     XoredChunk3:=XoredChunk3 xor XorMask3;
     XoredChunk4:=XoredChunk4 xor XorMask4;
     XoredChunk5:=XoredChunk5 xor XorMask5;
     XoredChunk6:=XoredChunk6 xor XorMask6;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and
        (TFLREUInt8(SearchChar2)=0) and (TFLREUInt8(SearchChar3)=0) and
        (TFLREUInt8(SearchChar4)=0) and (TFLREUInt8(SearchChar5)=0) and
        (TFLREUInt8(SearchChar6)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      XoredChunk3:=not XoredChunk3;
      XoredChunk4:=not XoredChunk4;
      XoredChunk5:=not XoredChunk5;
      XoredChunk6:=not XoredChunk6;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) and
            ((XoredChunk3 and $ff)<>$ff) and
            ((XoredChunk4 and $ff)<>$ff) and
            ((XoredChunk5 and $ff)<>$ff) and
            ((XoredChunk6 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       XoredChunk6:=XoredChunk6 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) and
            ((XoredChunk3 and $ff)<>TFLREUInt8(SearchChar3)) and
            ((XoredChunk4 and $ff)<>TFLREUInt8(SearchChar4)) and
            ((XoredChunk5 and $ff)<>TFLREUInt8(SearchChar5)) and
            ((XoredChunk6 and $ff)<>TFLREUInt8(SearchChar6)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       XoredChunk6:=XoredChunk6 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharSetOf8(const SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6,SearchChar7:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
type pptruint=^TFLREPtrUInt;
const MaskA=TFLREPtrUInt({$ifdef cpu64}$fefefefefefefeff{$else}$fefefeff{$endif}); // it is: 0-$01010101 / 0-$0101010101010101
      MaskB=TFLREPtrUInt({$ifdef cpu64}$8080808080808080{$else}$80808080{$endif});
var CurrentChar:PFLRERawByteChar;
    CurrentChunk:pptruint;
    XorMask0,XorMask1,XorMask2,XorMask3,XorMask4,XorMask5,XorMask6,XorMask7,
    XoredChunk0,XoredChunk1,XoredChunk2,XoredChunk3,XoredChunk4,XoredChunk5,XoredChunk6,XoredChunk7,
    CurrentChunkValue,Size:TFLREPtrUInt;
    CharSet:TFLRERawByteCharSet;
begin
 result:=-1;

 Size:=TextLength-Offset;
 if (Offset<TextLength) and (TFLREPtrInt(Size)>0) then begin

  XorMask0:=TFLREUInt8(SearchChar0);
  XorMask0:=XorMask0 or (XorMask0 shl 8);
  XorMask0:=XorMask0 or (XorMask0 shl 16);
{$ifdef cpu64}
  XorMask0:=XorMask0 or (XorMask0 shl 32);
{$endif}

  XorMask1:=TFLREUInt8(SearchChar1);
  XorMask1:=XorMask1 or (XorMask1 shl 8);
  XorMask1:=XorMask1 or (XorMask1 shl 16);
{$ifdef cpu64}
  XorMask1:=XorMask1 or (XorMask1 shl 32);
{$endif}

  XorMask2:=TFLREUInt8(SearchChar2);
  XorMask2:=XorMask2 or (XorMask2 shl 8);
  XorMask2:=XorMask2 or (XorMask2 shl 16);
{$ifdef cpu64}
  XorMask2:=XorMask2 or (XorMask2 shl 32);
{$endif}

  XorMask3:=TFLREUInt8(SearchChar3);
  XorMask3:=XorMask3 or (XorMask3 shl 8);
  XorMask3:=XorMask3 or (XorMask3 shl 16);
{$ifdef cpu64}
  XorMask3:=XorMask3 or (XorMask3 shl 32);
{$endif}

  XorMask4:=TFLREUInt8(SearchChar4);
  XorMask4:=XorMask4 or (XorMask4 shl 8);
  XorMask4:=XorMask4 or (XorMask4 shl 16);
{$ifdef cpu64}
  XorMask4:=XorMask4 or (XorMask4 shl 32);
{$endif}

  XorMask5:=TFLREUInt8(SearchChar5);
  XorMask5:=XorMask5 or (XorMask5 shl 8);
  XorMask5:=XorMask5 or (XorMask5 shl 16);
{$ifdef cpu64}
  XorMask5:=XorMask5 or (XorMask5 shl 32);
{$endif}

  XorMask6:=TFLREUInt8(SearchChar6);
  XorMask6:=XorMask6 or (XorMask6 shl 8);
  XorMask6:=XorMask6 or (XorMask6 shl 16);
{$ifdef cpu64}
  XorMask6:=XorMask6 or (XorMask6 shl 32);
{$endif}

  XorMask7:=TFLREUInt8(SearchChar7);
  XorMask7:=XorMask7 or (XorMask7 shl 8);
  XorMask7:=XorMask7 or (XorMask7 shl 16);
{$ifdef cpu64}
  XorMask7:=XorMask7 or (XorMask7 shl 32);
{$endif}

  CharSet:=[SearchChar0,SearchChar1,SearchChar2,SearchChar3,SearchChar4,SearchChar5,SearchChar6,SearchChar7];

  CurrentChar:=@Text[Offset];

  if Size>(SizeOf(TFLREPtrUInt)*2) then begin

   // Alignment initialization
   CurrentChunk:=pointer(TFLREPtrUInt(TFLREPtrUInt(CurrentChar) and not (SizeOf(TFLREPtrUInt)-1)));

   // Try to get first chunk
   if TFLREPtrUInt(CurrentChunk)>=TFLREPtrUInt(Text) then begin
    // Yes, we can the get first chunk
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
    XoredChunk6:=CurrentChunkValue xor XorMask6;
    XoredChunk7:=CurrentChunkValue xor XorMask7;
   end else begin
    // No, so return dummy value to force to check the few first characters
    XoredChunk0:=0;
    XoredChunk1:=0;
    XoredChunk2:=0;
    XoredChunk3:=0;
    XoredChunk4:=0;
    XoredChunk5:=0;
    XoredChunk6:=0;
    XoredChunk7:=0;
   end;

   // Jump to next chunk
   inc(CurrentChunk);

   // Subtract the first chunk from size
   dec(TFLREPtrUInt(Size),TFLREPtrUInt(CurrentChunk)-TFLREPtrUInt(CurrentChar));

   // Scan first chunk
   if ((((XoredChunk0+MaskA) and not XoredChunk0) or
        ((XoredChunk1+MaskA) and not XoredChunk1) or
        ((XoredChunk2+MaskA) and not XoredChunk2) or
        ((XoredChunk3+MaskA) and not XoredChunk3) or
        ((XoredChunk4+MaskA) and not XoredChunk4) or
        ((XoredChunk5+MaskA) and not XoredChunk5) or
        ((XoredChunk6+MaskA) and not XoredChunk6) or
        ((XoredChunk7+MaskA) and not XoredChunk7)) and MaskB)<>0 then begin
    while TFLREPtrUInt(CurrentChar)<TFLREPtrUInt(CurrentChunk) do begin
     if CurrentChar^ in CharSet then begin
      result:=TFLREPtrUInt(CurrentChar)-TFLREPtrUInt(Text);
      exit;
     end;
     inc(CurrentChar);
    end;
   end;

   // Scan until the last whole chunk
   while Size>=SizeOf(TFLREPtrUInt) do begin
    CurrentChunkValue:=CurrentChunk^;
    XoredChunk0:=CurrentChunkValue xor XorMask0;
    XoredChunk1:=CurrentChunkValue xor XorMask1;
    XoredChunk2:=CurrentChunkValue xor XorMask2;
    XoredChunk3:=CurrentChunkValue xor XorMask3;
    XoredChunk4:=CurrentChunkValue xor XorMask4;
    XoredChunk5:=CurrentChunkValue xor XorMask5;
    XoredChunk6:=CurrentChunkValue xor XorMask6;
    XoredChunk7:=CurrentChunkValue xor XorMask7;
    if ((((XoredChunk0+MaskA) and not XoredChunk0) or
         ((XoredChunk1+MaskA) and not XoredChunk1) or
         ((XoredChunk2+MaskA) and not XoredChunk2) or
         ((XoredChunk3+MaskA) and not XoredChunk3) or
         ((XoredChunk4+MaskA) and not XoredChunk4) or
         ((XoredChunk5+MaskA) and not XoredChunk5) or
         ((XoredChunk6+MaskA) and not XoredChunk6) or
         ((XoredChunk7+MaskA) and not XoredChunk7)) and MaskB)<>0 then begin
{$ifdef POSCHARSAFECHECK}
     CurrentChar:=pointer(CurrentChunk);
     if CurrentChar[0] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[0]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[1] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[1]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[2] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[2]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[3] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[3]))-TFLREPtrUInt(Text);
      exit;
     end;
{$ifdef cpu64}
     if CurrentChar[4] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[4]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[5] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[5]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[6] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[6]))-TFLREPtrUInt(Text);
      exit;
     end;
     if CurrentChar[7] in CharSet then begin
      result:=TFLREPtrUInt(pointer(@CurrentChar[7]))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
{$else}
     CurrentChar:=pointer({$ifdef BIG_ENDIAN}TFLREPtrUInt(TFLREPtrUInt(CurrentChunk)+TFLREPtrUInt(SizeOf(TFLREPtrUInt)-1)){$else}CurrentChunk{$endif});
     XoredChunk0:=XoredChunk0 xor XorMask0;
     XoredChunk1:=XoredChunk1 xor XorMask1;
     XoredChunk2:=XoredChunk2 xor XorMask2;
     XoredChunk3:=XoredChunk3 xor XorMask3;
     XoredChunk4:=XoredChunk4 xor XorMask4;
     XoredChunk5:=XoredChunk5 xor XorMask5;
     XoredChunk6:=XoredChunk6 xor XorMask6;
     XoredChunk7:=XoredChunk7 xor XorMask7;
     if (TFLREUInt8(SearchChar0)=0) and (TFLREUInt8(SearchChar1)=0) and
        (TFLREUInt8(SearchChar2)=0) and (TFLREUInt8(SearchChar3)=0) and
        (TFLREUInt8(SearchChar4)=0) and (TFLREUInt8(SearchChar5)=0) and
        (TFLREUInt8(SearchChar6)=0) and (TFLREUInt8(SearchChar7)=0) then begin
      // Special case
      XoredChunk0:=not XoredChunk0;
      XoredChunk1:=not XoredChunk1;
      XoredChunk2:=not XoredChunk2;
      XoredChunk3:=not XoredChunk3;
      XoredChunk4:=not XoredChunk4;
      XoredChunk5:=not XoredChunk5;
      XoredChunk6:=not XoredChunk6;
      XoredChunk7:=not XoredChunk7;
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6 or XoredChunk7)<>0) and
            ((XoredChunk0 and $ff)<>$ff) and
            ((XoredChunk1 and $ff)<>$ff) and
            ((XoredChunk2 and $ff)<>$ff) and
            ((XoredChunk3 and $ff)<>$ff) and
            ((XoredChunk4 and $ff)<>$ff) and
            ((XoredChunk5 and $ff)<>$ff) and
            ((XoredChunk6 and $ff)<>$ff) and
            ((XoredChunk7 and $ff)<>$ff) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       XoredChunk6:=XoredChunk6 shr 8;
       XoredChunk7:=XoredChunk7 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end else begin
      while ((XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6 or XoredChunk7)<>0) and
            ((XoredChunk0 and $ff)<>TFLREUInt8(SearchChar0)) and
            ((XoredChunk1 and $ff)<>TFLREUInt8(SearchChar1)) and
            ((XoredChunk2 and $ff)<>TFLREUInt8(SearchChar2)) and
            ((XoredChunk3 and $ff)<>TFLREUInt8(SearchChar3)) and
            ((XoredChunk4 and $ff)<>TFLREUInt8(SearchChar4)) and
            ((XoredChunk5 and $ff)<>TFLREUInt8(SearchChar5)) and
            ((XoredChunk6 and $ff)<>TFLREUInt8(SearchChar6)) and
            ((XoredChunk7 and $ff)<>TFLREUInt8(SearchChar7)) do begin
       XoredChunk0:=XoredChunk0 shr 8;
       XoredChunk1:=XoredChunk1 shr 8;
       XoredChunk2:=XoredChunk2 shr 8;
       XoredChunk3:=XoredChunk3 shr 8;
       XoredChunk4:=XoredChunk4 shr 8;
       XoredChunk5:=XoredChunk5 shr 8;
       XoredChunk6:=XoredChunk6 shr 8;
       XoredChunk7:=XoredChunk7 shr 8;
       {$ifdef BIG_ENDIAN}dec{$else}inc{$endif}(CurrentChar);
      end;
     end;
     if (XoredChunk0 or XoredChunk1 or XoredChunk2 or XoredChunk3 or XoredChunk4 or XoredChunk5 or XoredChunk6 or XoredChunk7)<>0 then begin
      result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
      exit;
     end;
{$endif}
    end;
    inc(CurrentChunk);
    dec(Size,SizeOf(TFLREPtrUInt));
   end;

   // Set chunkwise to charwise pointer
   CurrentChar:=pointer(CurrentChunk);
  end;

  // Scan rest of the remained characters, if there are any
  while Size>0 do begin
   if CurrentChar^ in CharSet then begin
    result:=TFLREPtrUInt(pointer(CurrentChar))-TFLREPtrUInt(Text);
    exit;
   end;
   inc(CurrentChar);
   dec(Size);
  end;

 end;
end;

function PtrPosCharPair(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
//  CurrentChar:TFLRERawByteChar;
begin
 Index:=Offset;
 while Index<(TextLength-1) do begin
  result:=PtrPosChar(SearchChar0,Text,TextLength,Index);
  if result<0 then begin
   exit;
  end else if result>=(TextLength-1) then begin
   break;
  end else if Text[result+1]=SearchChar1 then begin
   exit;
  end else begin
   Index:=result+1;
  end;
 end;
 result:=-1;
end;

function PtrPosCharSetOf2Of2(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
//  CurrentChar:TFLRERawByteChar;
begin
 Index:=Offset;
 while Index<(TextLength-1) do begin
  result:=PtrPosCharSetOf2(SearchChar0,SearchChar1,Text,TextLength,Index);
  if result<0 then begin
   exit;
  end else if result>=(TextLength-1) then begin
   break;
  end else if (Text[result+1]=SearchChar0) or (Text[result+1]=SearchChar1) then begin
   exit;
  end else begin
   Index:=result+1;
  end;
 end;
 result:=-1;
end;

function PtrPosCharSetOf2Of3(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
//  CurrentChar:TFLRERawByteChar;
begin
 Index:=Offset;
 while Index<(TextLength-2) do begin
  result:=PtrPosCharSetOf2(SearchChar0,SearchChar1,Text,TextLength,Index);
  if result<0 then begin
   exit;
  end else if result>=(TextLength-2) then begin
   break;
  end else if ((Text[result+1]=SearchChar0) or (Text[result+1]=SearchChar1)) and
              ((Text[result+2]=SearchChar0) or (Text[result+2]=SearchChar1)) then begin
   exit;
  end else begin
   Index:=result+1;
  end;
 end;
 result:=-1;
end;

function PtrPosCharSetOf2Of4(const SearchChar0,SearchChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
//  CurrentChar:TFLRERawByteChar;
begin
 Index:=Offset;
 while Index<(TextLength-3) do begin
  result:=PtrPosCharSetOf2(SearchChar0,SearchChar1,Text,TextLength,Index);
  if result<0 then begin
   exit;
  end else if result>=(TextLength-3) then begin
   break;
  end else if ((Text[result+1]=SearchChar0) or (Text[result+1]=SearchChar1)) and
              ((Text[result+2]=SearchChar0) or (Text[result+2]=SearchChar1)) and
              ((Text[result+3]=SearchChar0) or (Text[result+3]=SearchChar1)) then begin
   exit;
  end else begin
   Index:=result+1;
  end;
 end;
 result:=-1;
end;

function PtrPosCharRange(const SearchFromChar,SearchToChar:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
    CurrentChar:TFLRERawByteChar;
begin
 for Index:=Offset to TextLength-1 do begin
  CurrentChar:=Text[Index];
  if (CurrentChar>=SearchFromChar) and (CurrentChar<=SearchToChar) then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function PtrPosCharRangeOf2(const SearchFromChar0,SearchToChar0,SearchFromChar1,SearchToChar1:TFLRERawByteChar;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;Offset:TFLRESizeInt=0):TFLRESizeInt;
var Index:TFLRESizeInt;
    CurrentChar:TFLRERawByteChar;
begin
 for Index:=Offset to TextLength-2 do begin
  CurrentChar:=Text[Index];
  if (CurrentChar>=SearchFromChar0) and (CurrentChar<=SearchToChar0) then begin
   CurrentChar:=Text[Index+1];
   if (CurrentChar>=SearchFromChar1) and (CurrentChar<=SearchToChar1) then begin
    result:=Index;
    exit;
   end;
  end;
 end;
 result:=-1;
end;
{$endif}

function PtrPosBoyerMoore(const Pattern:TFLRERawByteString;const Text:PFLRERawByteChar;const TextLength:TFLRESizeInt;const Skip:TFLRECharPatternBitMasks;const Next:TFLREBoyerMooreNext;Position:TFLRESizeInt=0):TFLRESizeInt;
var PatternPosition,BadSkip,GoodSkip,PatternLength:TFLRESizeInt;
begin
 PatternLength:=length(Pattern);
 result:=-1;
 if PatternLength<>0 then begin
  Position:=PtrPosChar(Pattern[1],Text,TextLength,Position);
  if Position>=0 then begin
   inc(Position,PatternLength-1);
   while Position<TextLength do begin
    PatternPosition:=0;
    while (PatternPosition<PatternLength) and (Text[Position-PatternPosition]=Pattern[PatternLength-PatternPosition]) do begin
     inc(PatternPosition);
    end;
    if PatternPosition<>PatternLength then begin
     BadSkip:=Skip[Text[Position-PatternPosition]];
     GoodSkip:=Next[PatternPosition];
     if BadSkip>GoodSkip then begin
      inc(Position,BadSkip-PatternPosition);
     end else begin
      inc(Position,GoodSkip);
     end;
    end else begin
     result:=(Position-PatternLength)+1;
     exit;
    end;
   end;
  end;
 end;
end;

function PtrPosPatternCharClass(const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;const PatternCharClass:TFLRECharClass;Position:TFLRESizeInt=0):TFLRESizeInt; {$ifdef cpu386}register;{$endif}
var Index:TFLRESizeInt;
begin
 for Index:=Position to TextLength-1 do begin
  if Text[Index] in PatternCharClass then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function PtrPosPatternSBNDMQ1(PatternLength:TFLRESizeInt;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;const PatternBitMasks:TFLRECharPatternBitMasks;Position:TFLRESizeInt=0):TFLRESizeInt;
var CheckPosition:TFLRESizeInt;
    State:TFLREUInt32;
begin
 inc(Position,PatternLength-1);
 while Position<TextLength do begin
  State:=PatternBitMasks[Text[Position]];
  if State<>0 then begin
   CheckPosition:=Position-PatternLength;
   repeat
    dec(Position);
    if Position<0 then begin
     break;
    end;
    State:=(State shr 1) and PatternBitMasks[Text[Position]];
   until State=0;
   if Position=CheckPosition then begin
    result:=CheckPosition+1;
    exit;
   end;
  end;
  inc(Position,PatternLength);
 end;
 result:=-1;
end;

function PtrPosPatternSBNDMQ2(PatternLength:TFLRESizeInt;const Text:PFLRERawByteChar;TextLength:TFLRESizeInt;const PatternBitMasks:TFLRECharPatternBitMasks;Position:TFLRESizeInt=0):TFLRESizeInt;
var CheckPosition:TFLRESizeInt;
    State:TFLREUInt32;
begin
 inc(Position,PatternLength-2);
 dec(TextLength);
 while Position<TextLength do begin
  State:=(PatternBitMasks[Text[Position+1]] shr 1) and PatternBitMasks[Text[Position]];
  if State<>0 then begin
   CheckPosition:=Position-(PatternLength-1);
   repeat
    dec(Position);
    if Position<0 then begin
     break;
    end;
    State:=(State shr 1) and PatternBitMasks[Text[Position]];
   until State=0;
   if Position=CheckPosition then begin
    result:=CheckPosition+1;
    exit;
   end;
  end;
  inc(Position,PatternLength-1);
 end;
 result:=-1;
end;

function FLREPtrCopy(const Src:PFLRERawByteChar;const From,Len:TFLRESizeInt):TFLRERawByteString;
begin
 SetLength(result,Len);
 if Len>0 then begin
  Move(Src[From],result[1],Len);
 end;
end;

function GetMinimalPerfectHashTableValueHashFromString(Seed:TFLREUInt32;const s:TFLRERawByteString):TFLREUInt32;
var Index:TFLRESizeInt;
begin
 if Seed=0 then begin
  result:=$811c9dc5;
 end else begin
  result:=Seed;
 end;
 for Index:=1 to length(s) do begin
  result:=(result+(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24)) xor TFLREUInt8(TFLRERawByteChar(s[Index]));
 end;
 result:=result and $7fffffff;
end;

function GetMinimalPerfectHashTableValue(const Seeds,Keys,Values:pointer;const SeedBits,ValueBits,Size:TFLREInt32;const Key:TFLRERawByteString):TFLREInt64;
type PFLREInt8s=^TFLREInt8s;
     TFLREInt8s=array[0..0] of TFLREInt8;
     PFLREInt16s=^TFLREInt16s;
     TFLREInt16s=array[0..0] of TFLREInt16;
     PFLREInt32s=^TFLREInt32s;
     TFLREInt32s=array[0..0] of TFLREInt32;
     PFLREUInt8s=^TFLREUInt8s;
     TFLREUInt8s=array[0..0] of TFLREUInt8;
     PFLREUInt16s=^TFLREUInt16s;
     TFLREUInt16s=array[0..0] of TFLREUInt16;
     PTFLREUInt32s=^TTFLREUInt32s;
     TTFLREUInt32s=array[0..0] of TFLREUInt32;
     PTFLREInt64s=^TTFLREInt64s;
     TTFLREInt64s=array[0..0] of TFLREInt64;
     PRawByteStrings=^TRawByteStrings;
     TRawByteStrings=array[0..0] of TFLRERawByteString;
var Seed,Index:TFLREInt32;
begin
 Index:=TFLREInt32(GetMinimalPerfectHashTableValueHashFromString(0,Key)) mod Size;
 case SeedBits of
  8:begin
   Seed:=PFLREInt8s(Seeds)^[Index]; // Signed 8-bit
  end;
  16:begin
   Seed:=PFLREInt16s(Seeds)^[Index]; // Signed 16-bit
  end;
  32:begin
   Seed:=PFLREInt32s(Seeds)^[Index]; // Signed 32-bit
  end;
  else begin
   result:=-1;
   exit;
  end;
 end;
 if Seed<0 then begin
  Index:=-(Seed+1);
 end else begin
  Index:=TFLREInt32(GetMinimalPerfectHashTableValueHashFromString(TFLREUInt32(Seed),Key)) mod Size;
 end;
 if (Index>=0) and (Index<Size) and (PRawByteStrings(Keys)^[Index]=Key) then begin
  case ValueBits of
   8:begin
    result:=PFLREUInt8s(Values)^[Index]; // Unsigned 8-bit
   end;
   16:begin
    result:=PFLREUInt16s(Values)^[Index]; // Unsigned 16-bit
   end;
   32:begin
    result:=PTFLREUInt32s(Values)^[Index]; // Unsigned 32-bit
   end;
   64:begin
    result:=PTFLREInt64s(Values)^[Index]; // Signed 64-bit
   end;
   else begin
    result:=-1;
   end;
  end;
 end else begin
  result:=-1;
 end;
end;

function HashString(const Str:TFLRERawByteString):TFLREUInt32;
{$ifdef cpuarm}
var b:PFLRERawByteChar;
    len,h,i:TFLREUInt32;
begin
 result:=2166136261;
 len:=length(Str);
 h:=len;
 if len>0 then begin
  b:=PFLRERawByteChar(Str);
  while len>3 do begin
   i:=TFLREUInt32(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(len,4);
  end;
  if len>1 then begin
   i:=TFLREUInt16(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(len,2);
  end;
  if len>0 then begin
   i:=TFLREUInt8(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$else}
const m=TFLREUInt32($57559429);
      n=TFLREUInt32($5052acdb);
var b:PFLRERawByteChar;
    h,k,len:TFLREUInt32;
    p:{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif};
begin
 len:=length(Str);
 h:=len;
 k:=h+n+1;
 if len>0 then begin
  b:=PFLRERawByteChar(Str);
  while len>7 do begin
   begin
    p:=TFLREUInt32(pointer(b)^)*{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif}(n);
    h:=h xor TFLREUInt32(p and $ffffffff);
    k:=k xor TFLREUInt32(p shr 32);
    inc(b,4);
   end;
   begin
    p:=TFLREUInt32(pointer(b)^)*{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif}(m);
    k:=k xor TFLREUInt32(p and $ffffffff);
    h:=h xor TFLREUInt32(p shr 32);
    inc(b,4);
   end;
   dec(len,8);
  end;
  if len>3 then begin
   p:=TFLREUInt32(pointer(b)^)*{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif}(n);
   h:=h xor TFLREUInt32(p and $ffffffff);
   k:=k xor TFLREUInt32(p shr 32);
   inc(b,4);
   dec(len,4);
  end;
  if len>0 then begin
   if len>1 then begin
    p:=TFLREUInt16(pointer(b)^);
    inc(b,2);
    dec(len,2);
   end else begin
    p:=0;
   end;
   if len>0 then begin
    p:=p or (TFLREUInt8(b^) shl 16);
   end;
   p:=p*{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif}(m);
   k:=k xor TFLREUInt32(p and $ffffffff);
   h:=h xor TFLREUInt32(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*{$ifdef fpc}TFLREUInt64{$else}TFLREInt64{$endif}(n);
  h:=h xor TFLREUInt32(p and $ffffffff);
  k:=k xor TFLREUInt32(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

function HashData(const Data:pointer;Len:TFLREUInt32):TFLREUInt32;
{$ifdef cpuarm}
var b:PFLRERawByteChar;
    h,i:TFLREUInt32;
begin
 result:=$811c9dc5;
 h:=Len;
 if Len>0 then begin
  b:=Data;
  while Len>3 do begin
   i:=TFLREUInt32(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(Len,4);
  end;
  if Len>1 then begin
   i:=TFLREUInt16(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(Len,2);
  end;
  if Len>0 then begin
   i:=TFLREUInt8(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$else}
const m=TFLREUInt32($57559429);
      n=TFLREUInt32($5052acdb);
var b:PFLRERawByteChar;
    h,k:TFLREUInt32;
    p:TFLREUInt64;
begin
 h:=Len;
 k:=h+n+1;
 if Len>0 then begin
  b:=Data;
  while Len>7 do begin
   begin
    p:=TFLREUInt32(pointer(b)^)*TFLREUInt64(n);
    h:=h xor TFLREUInt32(p and $ffffffff);
    k:=k xor TFLREUInt32(p shr 32);
    inc(b,4);
   end;
   begin
    p:=TFLREUInt32(pointer(b)^)*TFLREUInt64(m);
    k:=k xor TFLREUInt32(p and $ffffffff);
    h:=h xor TFLREUInt32(p shr 32);
    inc(b,4);
   end;
   dec(Len,8);
  end;
  if Len>3 then begin
   p:=TFLREUInt32(pointer(b)^)*TFLREUInt64(n);
   h:=h xor TFLREUInt32(p and $ffffffff);
   k:=k xor TFLREUInt32(p shr 32);
   inc(b,4);
   dec(Len,4);
  end;
  if Len>0 then begin
   if Len>1 then begin
    p:=TFLREUInt16(pointer(b)^);
    inc(b,2);
    dec(Len,2);
   end else begin
    p:=0;
   end;
   if Len>0 then begin
    p:=p or (TFLREUInt8(b^) shl 16);
   end;
   p:=p*TFLREUInt64(m);
   k:=k xor TFLREUInt32(p and $ffffffff);
   h:=h xor TFLREUInt32(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*TFLREUInt64(n);
  h:=h xor TFLREUInt32(p and $ffffffff);
  k:=k xor TFLREUInt32(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

{$warnings off}
function HashPointer(Data:pointer):TFLREUInt32;
const m=TFLREUInt32($57559429);
      n=TFLREUInt32($5052acdb);
var Temporary:TFLREUInt64;
begin
 Temporary:=TFLREUInt32(TFLREPtrUInt(Pointer(Data)) and $ffffffff)*TFLREUInt64(n);
 result:=m xor (Temporary and $ffffffff) xor (Temporary shr 32);
{$ifdef CPU64}
 result:=result xor TFLREUInt32(TFLREPtrUInt(Pointer(Data)) shr 32);
{$endif}
end;
{$warnings on}

function UTF8RangeToRegEx(Lo,Hi:TFLREUInt32):TFLRERawByteString;
type TString6Chars=array[0..6] of TFLRERawByteChar;
const Seq0010ffff:array[0..6,0..4,0..1] of TFLREInt32=((($00,$7f),(-1,-1),(-1,-1),(-1,-1),(-1,-1)),        // 00-7F
                                                       (($c2,$df),($80,$bf),(-1,-1),(-1,-1),(-1,-1)),      // C2-DF 80-BF
                                                       (($e0,$e0),($a0,$bf),($80,$bf),(-1,-1),(-1,-1)),    // E0-E0 A0-BF 80-BF
                                                       (($e1,$ef),($80,$bf),($80,$bf),(-1,-1),(-1,-1)),    // E1-EF 80-BF 80-BF
                                                       (($f0,$f0),($80,$bf),($80,$bf),($80,$bf),(-1,-1)),  // F0-F0 90-BF 80-BF 80-BF
                                                       (($f1,$f3),($80,$bf),($80,$bf),($80,$bf),(-1,-1)),  // F1-F3 80-BF 80-BF 80-BF
                                                       (($f4,$f4),($80,$bf),($80,$bf),($80,$bf),(-1,-1))); // F4-F4 80-8F 80-BF 80-BF
      HexChars:array[$0..$f] of TFLRERawByteChar='0123456789ABCDEF';
var OutputCharSequence:TFLRERawByteString;
 function ToString(CharValue:TFLREUInt32):TString6Chars;
 begin
  case CharValue of
   $00000000..$0000007f:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(1));
    result[1]:=TFLRERawByteChar(TFLREUInt8(CharValue));
   end;
   $00000080..$000007ff:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(2));
    result[1]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
    result[2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   end;
// {$ifdef PLREStrictUTF8}$00000800..$0000d7ff,$0000e000..$0000ffff{$else}$00000800..$0000ffff{$endif}:begin
   $00000800..$0000ffff:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(3));
    result[1]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
    result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    result[3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   end;
   $00010000..$0010ffff:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(4));
    result[1]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
    result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    result[4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   end;
   $00200000..$03ffffff:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(5));
    result[1]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
    result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    result[4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    result[5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   end;
   $04000000..$7fffffff:begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(6));
    result[1]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
    result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
    result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
    result[4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
    result[5]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
    result[6]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
   end;
   else begin
    result[0]:=TFLRERawByteChar(TFLREUInt8(3));
    result[1]:=#$ef;
    result[2]:=#$bf;
    result[3]:=#$bd;
   end;
  end;
 end;
 procedure AddRange(Lo,Hi:TFLREUInt8);
 var Data:array[0..11] of TFLRERawByteChar;
 begin
  Data:='[\x00-\x00]';
  Data[3]:=HexChars[(Lo shr 4) and $f];
  Data[4]:=HexChars[Lo and $f];
  Data[8]:=HexChars[(Hi shr 4) and $f];
  Data[9]:=HexChars[Hi and $f];
  OutputCharSequence:=OutputCharSequence+Data;
 end;
 procedure ProcessRange(Lo,Hi:TFLREUInt32);
 var i,m:TFLREUInt32;
     StrLo,StrHi:TString6Chars;
 begin
  if Hi>$0010ffff then begin
   Hi:=$0010ffff;
  end;
  if Lo<=Hi then begin
    if (Lo=$00000000) and (Hi=$0010ffff) then begin
    for m:=low(Seq0010ffff) to high(Seq0010ffff) do begin
     for i:=low(Seq0010ffff[m]) to high(Seq0010ffff[m]) do begin
      if Seq0010ffff[m,i,0]<0 then begin
       break;
      end;
      AddRange(TFLREUInt8(Seq0010ffff[m,i,0]),TFLREUInt8(Seq0010ffff[m,i,1]));
     end;
     OutputCharSequence:=OutputCharSequence+'|';
    end;
   end else if (Lo=$00000080) and (Hi=$0010ffff) then begin
    for m:=1 to high(Seq0010ffff) do begin
     for i:=low(Seq0010ffff[m]) to high(Seq0010ffff[m]) do begin
      if Seq0010ffff[m,i,0]<0 then begin
       break;
      end;
      AddRange(TFLREUInt8(Seq0010ffff[m,i,0]),TFLREUInt8(Seq0010ffff[m,i,1]));
     end;
     OutputCharSequence:=OutputCharSequence+'|';
    end;
   end else begin
    for i:=1 to 3 do begin
     if i=1 then begin
      m:=7;
     end else begin
      m:=(7-i)+(6*(i-1));
     end;
     m:=(1 shl m)-1;
     if (Lo<=m) and (m<Hi) then begin
      ProcessRange(Lo,m);
      ProcessRange(m+1,Hi);
      exit;
     end;
    end;
    if Hi<128 then begin
     AddRange(Lo,Hi);
     OutputCharSequence:=OutputCharSequence+'|';
    end else begin
     for i:=1 to 3 do begin
      m:=(1 shl (6*i))-1;
      if (Lo and not m)<>(Hi and not m) then begin
       if (Lo and m)<>0 then begin
        ProcessRange(Lo,Lo or m);
        ProcessRange((Lo or m)+1,Hi);
        exit;
       end else if (Hi and m)<>m then begin
        ProcessRange(Lo,(Hi and not m)-1);
        ProcessRange(Hi and not m,Hi);
        exit;
       end;
      end;
     end;
     StrLo:=ToString(Lo);
     StrHi:=ToString(Hi);
     if TFLREUInt8(TFLRERawByteChar(StrLo[0]))=TFLREUInt8(TFLRERawByteChar(StrHi[0])) then begin
      for i:=1 to TFLREUInt8(TFLRERawByteChar(StrLo[0])) do begin
       AddRange(TFLREUInt8(StrLo[i]),TFLREUInt8(StrHi[i]));
      end;
      OutputCharSequence:=OutputCharSequence+'|';
     end;
    end;
   end;
  end;
 end;
begin
 OutputCharSequence:='';
 ProcessRange(Lo,Hi);
 result:=copy(OutputCharSequence,1,length(OutputCharSequence)-1);
end;

function HashDFAState(const Key:PFLREDFAState):TFLREUInt32;
begin
 if assigned(Key) and (Key.CountInstructions>0) then begin
  result:=HashData(@Key.Instructions[0],Key.CountInstructions*sizeof(PFLREInstruction));
  result:=result xor ((TFLREUInt32(Key.CountInstructions) shr 16) or (TFLREUInt32(Key.CountInstructions) shl 16));
  result:=result xor (((Key.Flags and sfDFACacheMask) shl 19) or ((Key.Flags and sfDFACacheMask) shr 13));
  if result=0 then begin
   result:=$ffffffff;
  end;
 end else begin
  result:=0;
 end;
end;

function CompareDFAState(const a,b:PFLREDFAState):boolean;
var i:TFLREInt32;
begin
 result:=a=b;
 if not result then begin
  if (assigned(a) and assigned(b)) and
     ((a.CountInstructions=b.CountInstructions) and ((a.Flags and sfDFACacheMask)=(b.Flags and sfDFACacheMask))) then begin
   result:=true;
   for i:=0 to a.CountInstructions-1 do begin
    if a.Instructions[i]<>b.Instructions[i] then begin
     result:=false;
     exit;
    end;
   end;
  end;
 end;
end;

function IsInstructionGreedy(Instruction:PFLREInstruction):boolean;
begin
 result:=assigned(Instruction^.Next) and ((Instruction^.Next^.IDandOpcode and $ff) in [opNONE,opSINGLECHAR,opCHAR,opANY]);
end;

const bncmmMemoryBlockSignature:TFLREPtrUInt={$ifdef cpu64}$1337bab3deadc0d3{$else}$deadc0d3{$endif};

constructor TFLRENativeCodeMemoryManager.Create;
{$ifdef windows}
var SystemInfo:TSystemInfo;
{$else}
{$ifdef unix}
{$endif}
{$endif}
begin
 inherited Create;
{$ifdef windows}
 GetSystemInfo(SystemInfo);
 PageSize:=RoundUpToPowerOfTwo(SystemInfo.dwPageSize);
{$else}
{$ifdef unix}
 PageSize:=4096;
{$else}
 PageSize:=4096;
{$endif}
{$endif}
{$ifdef cpu386}
 Alignment:=16;
{$else}
{$ifdef cpux64}
 Alignment:=16;
{$else}
{$ifdef cpuarm}
 Alignment:=16;
{$else}
 Alignment:=PageSize;
{$endif}
{$endif}
{$endif}
 First:=nil;
 Last:=nil;
end;

destructor TFLRENativeCodeMemoryManager.Destroy;
begin
 while assigned(First) do begin
  FreeBlockContainer(First);
 end;
 inherited Destroy;
end;

function TFLRENativeCodeMemoryManager.AllocateBlockContainer(BlockContainerSize:TFLREPtrUInt):PFLRENativeCodeMemoryManagerBlockContainer;
var Size:TFLREPtrUInt;
    Block:PFLRENativeCodeMemoryManagerBlock;
begin
 if BlockContainerSize>0 then begin
  Size:=RoundUpToMask(BlockContainerSize,PageSize);
  New(result);
{$ifdef windows}
  result^.Base:=VirtualAlloc(nil,Size,MEM_COMMIT,PAGE_EXECUTE_READWRITE);
{$else}
{$ifdef unix}
  result^.Base:=fpmmap(nil,Size,PROT_READ or PROT_WRITE or PROT_EXEC,MAP_PRIVATE or MAP_ANONYMOUS,-1,0);
{$else}
  GetMem(result^.Base,Size);
{$endif}
{$endif}
  result^.Size:=Size;
  result^.Used:=sizeof(TFLRENativeCodeMemoryManagerBlock)*2;
  if assigned(Last) then begin
   Last^.Next:=result;
   result^.Previous:=Last;
   Last:=result;
   result^.Next:=nil;
  end else begin
   First:=result;
   Last:=result;
   result^.Previous:=nil;
   result^.Next:=nil;
  end;
  FillChar(result^.Base^,result^.Size,#0);
  result^.First:=result^.Base;
  result^.Last:=pointer(@PFLRERawByteChar(result^.Base)[result^.Size-sizeof(TFLRENativeCodeMemoryManagerBlock)]);
  Block:=result^.First;
  Block^.Signature:=bncmmMemoryBlockSignature;
  Block^.Previous:=nil;
  Block^.Next:=result^.Last;
  Block^.Size:=0;
  Block:=result^.Last;
  Block^.Signature:=bncmmMemoryBlockSignature;
  Block^.Previous:=result^.First;
  Block^.Next:=nil;
  Block^.Size:=0;
 end else begin
  result:=nil;
 end;
end;

procedure TFLRENativeCodeMemoryManager.FreeBlockContainer(BlockContainer:PFLRENativeCodeMemoryManagerBlockContainer);
begin
 if assigned(BlockContainer^.Previous) then begin
  BlockContainer^.Previous^.Next:=BlockContainer^.Next;
 end else begin
  First:=BlockContainer^.Next;
 end;
 if assigned(BlockContainer^.Next) then begin
  BlockContainer^.Next^.Previous:=BlockContainer^.Previous;
 end else begin
  Last:=BlockContainer^.Previous;
 end;
{$ifdef windows}
 VirtualFree(BlockContainer^.Base,0,MEM_RELEASE);
{$else}
{$ifdef unix}
 fpmunmap(BlockContainer^.Base,BlockContainer^.Size);
{$else}
 FreeMem(BlockContainer^.Base);
{$endif}
{$endif}
 Dispose(BlockContainer);
end;

function TFLRENativeCodeMemoryManager.GetMemory(Size:TFLREPtrUInt):pointer;
var BlockContainer:PFLRENativeCodeMemoryManagerBlockContainer;
    CurrentBlock,NewBlock:PFLRENativeCodeMemoryManagerBlock;
    DestSize,BlockContainerSize:TFLREPtrUInt;
begin
 result:=nil;
 if Size>0 then begin
  DestSize:=Size+sizeof(TFLRENativeCodeMemoryManagerBlock);
  BlockContainer:=First;
  while true do begin
   while assigned(BlockContainer) do begin
    if (BlockContainer^.Used+DestSize)<=BlockContainer^.Size then begin
     CurrentBlock:=BlockContainer^.First;
     while assigned(CurrentBlock) and (CurrentBlock^.Signature=bncmmMemoryBlockSignature) and assigned(CurrentBlock^.Next) do begin
      NewBlock:=pointer(TFLREPtrUInt(RoundUpToMask(TFLREPtrUInt(pointer(@PFLRERawByteChar(CurrentBlock)[(sizeof(TFLRENativeCodeMemoryManagerBlock)*2)+CurrentBlock^.Size])),Alignment)-sizeof(TFLRENativeCodeMemoryManagerBlock)));
      if (TFLREPtrUInt(CurrentBlock^.Next)-TFLREPtrUInt(NewBlock))>=DestSize then begin
       NewBlock^.Signature:=bncmmMemoryBlockSignature;
       NewBlock^.Previous:=CurrentBlock;
       NewBlock^.Next:=CurrentBlock^.Next;
       NewBlock^.Size:=Size;
       CurrentBlock^.Next^.Previous:=NewBlock;
       CurrentBlock^.Next:=NewBlock;
       result:=pointer(@PFLRERawByteChar(NewBlock)[sizeof(TFLRENativeCodeMemoryManagerBlock)]);
       inc(BlockContainer^.Used,DestSize);
       exit;
      end else begin
       CurrentBlock:=CurrentBlock^.Next;
      end;
     end;
    end;
    BlockContainer:=BlockContainer^.Next;
   end;
   if DestSize<=FLREMinNativeCodeBlockContainerSize then begin
    BlockContainerSize:=FLREMinNativeCodeBlockContainerSize;
   end else begin
    BlockContainerSize:=RoundUpToPowerOfTwo(DestSize);
   end;
   BlockContainer:=AllocateBlockContainer(BlockContainerSize);
   if not assigned(BlockContainer) then begin
    break;
   end;
  end;
 end;
end;

procedure TFLRENativeCodeMemoryManager.FreeMemory(p:pointer);
var BlockContainer:PFLRENativeCodeMemoryManagerBlockContainer;
    CurrentBlock:PFLRENativeCodeMemoryManagerBlock;
begin
 BlockContainer:=First;
 while assigned(BlockContainer) do begin
  if ((TFLREPtrUInt(BlockContainer^.Base)+sizeof(TFLRENativeCodeMemoryManagerBlock))<=TFLREPtrUInt(p)) and ((TFLREPtrUInt(p)+sizeof(TFLRENativeCodeMemoryManagerBlock))<(TFLREPtrUInt(BlockContainer^.Base)+BlockContainer^.Size)) then begin
   CurrentBlock:=pointer(TFLREPtrUInt(TFLREPtrUInt(p)-sizeof(TFLRENativeCodeMemoryManagerBlock)));
   if (CurrentBlock^.Signature=bncmmMemoryBlockSignature) and (CurrentBlock<>BlockContainer^.First) and (CurrentBlock<>BlockContainer^.Last) then begin
    dec(BlockContainer^.Used,CurrentBlock^.Size+sizeof(TFLRENativeCodeMemoryManagerBlock));
    CurrentBlock^.Signature:=0;
    CurrentBlock^.Previous^.Next:=CurrentBlock^.Next;
    CurrentBlock^.Next^.Previous:=CurrentBlock^.Previous;
    if (assigned(BlockContainer^.First) and (BlockContainer^.First^.Next=BlockContainer^.Last)) or not assigned(BlockContainer^.First) then begin
     FreeBlockContainer(BlockContainer);
    end;
    exit;
   end;
  end;
  BlockContainer:=BlockContainer^.Next;
 end;
end;

function TFLRENativeCodeMemoryManager.ReallocMemory(p:pointer;Size:TFLREPtrUInt):pointer;
var BlockContainer:PFLRENativeCodeMemoryManagerBlockContainer;
    CurrentBlock:PFLRENativeCodeMemoryManagerBlock;
    DestSize:TFLREPtrUInt;
begin
 result:=nil;
 if assigned(p) then begin
  if Size=0 then begin
   FreeMemory(p);
  end else begin
   DestSize:=Size+sizeof(TFLRENativeCodeMemoryManagerBlock);
   BlockContainer:=First;
   while assigned(BlockContainer) do begin
    if ((TFLREPtrUInt(BlockContainer^.Base)+sizeof(TFLRENativeCodeMemoryManagerBlock))<=TFLREPtrUInt(p)) and ((TFLREPtrUInt(p)+sizeof(TFLRENativeCodeMemoryManagerBlock))<(TFLREPtrUInt(BlockContainer^.Base)+BlockContainer^.Size)) then begin
     CurrentBlock:=pointer(TFLREPtrUInt(TFLREPtrUInt(p)-sizeof(TFLRENativeCodeMemoryManagerBlock)));
     if (CurrentBlock^.Signature=bncmmMemoryBlockSignature) and (CurrentBlock<>BlockContainer^.First) and (CurrentBlock<>BlockContainer^.Last) then begin
      if (TFLREPtrUInt(CurrentBlock^.Next)-TFLREPtrUInt(CurrentBlock))>=DestSize then begin
       CurrentBlock^.Size:=Size;
       result:=p;
       exit;
      end else begin
       result:=GetMemory(Size);
       if assigned(result) then begin
        if CurrentBlock^.Size<Size then begin
         Move(p^,result^,CurrentBlock^.Size);
        end else begin
         Move(p^,result^,Size);
        end;
       end;
       FreeMemory(p);
       exit;
      end;
     end;
    end;
    BlockContainer:=BlockContainer^.Next;
   end;
  end;
  FreeMemory(p);
 end else if Size<>0 then begin
  result:=GetMemory(Size);
 end;
end;

constructor TFLREDFAStateHashMap.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TFLREDFAStateHashMap.Destroy;
begin
 Clear;
 SetLength(Entities,0);
 inherited Destroy;
end;

procedure TFLREDFAStateHashMap.Clear;
begin
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

function TFLREDFAStateHashMap.FindCell(const Key:PFLREDFAState):TFLREUInt32;
var HashCode,Mask,Step:TFLREUInt32;
    Entity:TFLREInt32;
begin
 HashCode:=HashDFAState(Key);
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and CompareDFAState(Entities[Entity].Key,Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

function TFLREDFAStateHashMap.Add(const Key:PFLREDFAState):PFLREDFAStateHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
  result^.Key:=Key;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  result:=@Entities[Entity];
  result^.Key:=Key;
 end;
end;

procedure TFLREDFAStateHashMap.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TFLREInt32;
    OldEntities:TFLREDFAStateHashMapEntities;
    OldCellToEntityIndex:TFLREDFAStateHashMapEntityIndices;
    OldEntityToCellIndex:TFLREDFAStateHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key);
   end;
  end;
 end;
end;

function TFLREDFAStateHashMap.Get(const Key:PFLREDFAState):PFLREDFAState;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=Entities[Entity].Key;
 end;
end;

function TFLREDFAStateHashMap.Delete(const Key:PFLREDFAState):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity].Key:=nil;
  Entities[Entity].Value:=0;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  dec(RealSize);
  result:=true;
 end;
end;

constructor TFLRESparseSet.Create(MaximumSize:TFLREInt32=0);
begin
 inherited Create;
 Size:=0;
 MaxSize:=MaximumSize;
 SparseToDense:=nil;
 Dense:=nil;
 SetLength(SparseToDense,MaxSize);
 SetLength(Dense,MaxSize);
 FillChar(SparseToDense[0],MaxSize*SizeOf(TFLREInt32),$ff);
 FillChar(Dense[0],MaxSize*SizeOf(TFLREInt32),$ff);
end;

destructor TFLRESparseSet.Destroy;
begin
 SetLength(SparseToDense,0);
 SetLength(Dense,0);
 inherited Destroy;
end;

procedure TFLRESparseSet.Clear;
begin
 Size:=0;
end;

procedure TFLRESparseSet.Resize(NewMaximumSize:TFLREInt32);
begin
 SetLength(SparseToDense,NewMaximumSize);
 SetLength(Dense,NewMaximumSize);
 if MaxSize<NewMaximumSize then begin
  FillChar(SparseToDense[MaxSize],(MaxSize-NewMaximumSize)*SizeOf(TFLREInt32),$ff);
  FillChar(Dense[MaxSize],(MaxSize-NewMaximumSize)*SizeOf(TFLREInt32),$ff);
 end;
 MaxSize:=NewMaximumSize;
end;

function TFLRESparseSet.Contains(const Value:TFLREInt32):boolean;
begin
 result:=((Value>=0) and (Value<MaxSize) and (SparseToDense[Value]<Size)) and (Dense[SparseToDense[Value]]=Value);
end;

procedure TFLRESparseSet.Add(const Value:TFLREInt32);
begin
 if (Value>=0) and (Value<MaxSize) then begin
  SparseToDense[Value]:=Size;
  Dense[Size]:=Value;
  inc(Size);
 end;
end;

procedure TFLRESparseSet.AddNew(const Value:TFLREInt32);
begin
 if not Contains(Value) then begin
  Add(Value);
 end;
end;

constructor TFLREDFAWorkQueue.Create(Preallocated:TFLREInt32=16);
begin
 inherited Create;
 Instructions:=nil;
 SetLength(Instructions,Preallocated);
 CountInstructions:=0;
 SparseToDenseIDs:=nil;
 DenseIDs:=nil;
 SetLength(SparseToDenseIDs,Preallocated);
 SetLength(DenseIDs,Preallocated);
 CountIDs:=0;
 AllocatedIDs:=0;
 LastWasMark:=false;
end;

destructor TFLREDFAWorkQueue.Destroy;
begin
 SetLength(Instructions,0);
 SetLength(SparseToDenseIDs,0);
 SetLength(DenseIDs,0);
 inherited Destroy;
end;

procedure TFLREDFAWorkQueue.Clear;
begin
 CountInstructions:=0;
 CountIDs:=0;
 LastWasMark:=false;
end;

procedure TFLREDFAWorkQueue.Mark;
begin
 if not LastWasMark then begin
  LastWasMark:=true;
  if (CountInstructions+1)>length(Instructions) then begin
   SetLength(Instructions,(CountInstructions+1)*2);
  end;
  Instructions[CountInstructions]:=nil;
  inc(CountInstructions);
 end;
end;

function TFLREDFAWorkQueue.IsMark(const Instruction:PFLREInstruction):boolean;
begin
 result:=not assigned(Instruction);
end;

function TFLREDFAWorkQueue.Contains(const Instruction:PFLREInstruction):boolean;
var ID:TFLREInt32;
begin
 ID:=Instruction^.IDandOpcode shr 8;
 result:=((ID>=0) and (ID<AllocatedIDs) and (SparseToDenseIDs[ID]<CountIDs)) and (DenseIDs[SparseToDenseIDs[ID]]=ID);
end;

procedure TFLREDFAWorkQueue.AddNew(const Instruction:PFLREInstruction);
var ID:TFLREInt32;
begin
 ID:=Instruction^.IDandOpcode shr 8;
 if (ID+1)>AllocatedIDs then begin
  AllocatedIDs:=ID+1;
  SetLength(SparseToDenseIDs,AllocatedIDs);
  SetLength(DenseIDs,AllocatedIDs);
 end;
 if (CountInstructions+1)>length(Instructions) then begin
  SetLength(Instructions,(CountInstructions+1)*2);
 end;
 Instructions[CountInstructions]:=Instruction;
 inc(CountInstructions);
 SparseToDenseIDs[ID]:=CountIDs;
 DenseIDs[CountIDs]:=ID;
 inc(CountIDs);
end;

procedure TFLREDFAWorkQueue.Add(const Instruction:PFLREInstruction);
begin
 if not Contains(Instruction) then begin
  LastWasMark:=false;
  AddNew(Instruction);
 end;
end;

constructor TFLREIntegerList.Create;
begin
 inherited Create;
 CountItems:=0;
 Allocated:=0;
 List:=nil;
 Clear;
end;

destructor TFLREIntegerList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TFLREIntegerList.Clear;
begin
 CountItems:=0;
 Allocated:=0;
 IsSorted:=false;
 ReallocMem(List,0);
end;

procedure TFLREIntegerList.SetCapacity(NewCapacity:TFLREInt32);
begin
 if NewCapacity>=0 then begin
  ReallocMem(List,NewCapacity*sizeof(TFLREInt32));
  Allocated:=NewCapacity;
 end;
end;

procedure TFLREIntegerList.SetCount(NewCount:TFLREInt32);
begin
 if NewCount>=0 then begin
  if NewCount<CountItems then begin
   CountItems:=NewCount;
  end else if NewCount>CountItems then begin
   if NewCount>Allocated then begin
    SetCapacity((CountItems+4096) and not 4095);
   end;
   if CountItems<NewCount then begin
    FillChar(List^[CountItems],(NewCount-CountItems)*sizeof(TFLREInt32),#0);
   end;
   CountItems:=NewCount;
  end;
 end;
end;

function TFLREIntegerList.Add(Item:TFLREInt32):TFLREInt32;
begin
 if CountItems>=Allocated then begin
  Allocated:=(CountItems+4096) and not 4095;
  ReallocMem(List,Allocated*sizeof(TFLREInt32));
 end;
 List^[CountItems]:=Item;
 result:=CountItems;
 inc(CountItems);
 IsSorted:=false;
end;

procedure TFLREIntegerList.AddSorted(Item:TFLREInt32);
var i:TFLREInt32;
begin
 if IsSorted then begin
  if CountItems=0 then begin
   Add(Item);
  end else begin
   i:=0;
   while (i<CountItems) and (Item>=List^[i]) do begin
    inc(i);
   end;
   Insert(i,Item);
  end;
  IsSorted:=true;
 end else begin
  Add(Item);
  Sort;
 end;
end;

procedure TFLREIntegerList.Insert(Index:TFLREInt32;Item:TFLREInt32);
var i:TFLREInt32;
begin
 if (Index>=0) and (Index<CountItems) then begin
  SetCount(CountItems+1);
  for i:=CountItems-1 downto Index do begin
   List^[i+1]:=List^[i];
  end;
  List^[Index]:=Item;
 end else if Index=CountItems then begin
  Add(Item);
 end else if Index>CountItems then begin
  SetCount(Index);
  Add(Item);
 end;
 IsSorted:=false;
end;

procedure TFLREIntegerList.Delete(Index:TFLREInt32);
var i,j,k:TFLREInt32;
begin
 if (Index>=0) and (Index<CountItems) then begin
  k:=CountItems-1;
  j:=Index;
  for i:=j to k-1 do begin
   List^[i]:=List^[i+1];
  end;
  SetCount(k);
 end;
end;

function TFLREIntegerList.Remove(Item:TFLREInt32):TFLREInt32;
var i,j,k:TFLREInt32;
begin
 result:=-1;
 k:=CountItems;
 j:=-1;
 for i:=0 to k-1 do begin
  if List^[i]=Item then begin
   j:=i;
   break;
  end;
 end;
 if j>=0 then begin
  dec(k);
  for i:=j to k-1 do begin
   List^[i]:=List^[i+1];
  end;
  SetCount(k);
  result:=j;
 end;
end;

function TFLREIntegerList.Find(Item:TFLREInt32):TFLREInt32;
var i,l,r:TFLREInt32;
begin
 result:=-1;
 if IsSorted then begin
  l:=0;
  r:=CountItems-1;
  while l<=r do begin
   i:=(l+r) shr 1;
   if List^[i]=Item then begin
    result:=i;
    break;
   end else begin
    if List^[i]<Item then begin
     l:=i+1;
    end else begin
     r:=i-1;
    end;
   end;
  end;
 end else begin
  for i:=0 to CountItems-1 do begin
   if List^[i]=Item then begin
    result:=i;
    break;
   end;
  end;
 end;
end;

function TFLREIntegerList.IndexOf(Item:TFLREInt32):TFLREInt32;
begin
 result:=Find(Item);
end;

procedure TFLREIntegerList.Exchange(Index1,Index2:TFLREInt32);
var TempInteger:TFLREInt32;
begin
 if (Index1>=0) and (Index1<CountItems) and (Index2>=0) and (Index2<CountItems) then begin
  TempInteger:=List^[Index1];
  List^[Index1]:=List^[Index2];
  List^[Index2]:=TempInteger;
  IsSorted:=false;
 end;
end;

function TFLREIntegerList.GetItem(Index:TFLREInt32):TFLREInt32;
begin
 if (Index>=0) and (Index<CountItems) then begin
  result:=List^[Index];
 end else begin
  result:=0;
 end;
end;

procedure TFLREIntegerList.SetItem(Index:TFLREInt32;Value:TFLREInt32);
begin
 if (Index>=0) and (Index<CountItems) then begin
  List^[Index]:=Value;
  IsSorted:=false;
 end;
end;

function TFLREIntegerList.GetItemPointer(Index:TFLREInt32):pointer;
begin
 if (Index>=0) and (Index<CountItems) then begin
  result:=@List^[Index];
 end else begin
  result:=nil;
 end;
end;

procedure TFLREIntegerList.Sort;
 procedure IntroSort(Left,Right,Depth:TFLREInt32);
  procedure SiftDown(Current,MaxIndex:TFLREInt32);
  var SiftLeft,SiftRight,Largest:TFLREInt32;
      v:TFLREInt32;
  begin
   SiftLeft:=Left+(2*(Current-Left))+1;
   SiftRight:=Left+(2*(Current-Left))+2;
   Largest:=Current;
   if (SiftLeft<=MaxIndex) and (List^[SiftLeft]>List^[Largest]) then begin
    Largest:=SiftLeft;
   end;
   if (SiftRight<=MaxIndex) and (List^[SiftRight]>List^[Largest]) then begin
    Largest:=SiftRight;
   end;
   if Largest<>Current then begin
    v:=List^[Current];
    List^[Current]:=List^[Largest];
    List^[Largest]:=v;
    SiftDown(Largest,MaxIndex);
   end;
  end;
  procedure InsertionSort;
  var i,j:TFLREInt32;
      t:TFLREInt32;
  begin
   i:=Left+1;
   while i<=Right do begin
    t:=List^[i];
    j:=i-1;
    while (j>=Left) and (t<List^[j]) do begin
     List^[j+1]:=List^[j];
     dec(j);
    end;
    List^[j+1]:=t;
    inc(i);
   end;
  end;
  procedure HeapSort;
  var i:TFLREInt32;
      v:TFLREInt32;
  begin
   i:=((Left+Right+1) div 2)-1;
   while i>=Left do begin
    SiftDown(i,Right);
    dec(i);
   end;
   i:=Right;
   while i>=Left+1 do begin
    v:=List^[i];
    List^[i]:=List^[Left];
    List^[Left]:=v;
    SiftDown(Left,i-1);
    dec(i);
   end;
  end;
  procedure QuickSortWidthMedianOfThreeOptimization;
  var Middle,i,j:TFLREInt32;
      Pivot,v:TFLREInt32;
  begin
   Middle:=(Left+Right) div 2;
   if (Right-Left)>3 then begin
    if List^[Left]>List^[Middle] then begin
     v:=List^[Left];
     List^[Left]:=List^[Middle];
     List^[Middle]:=v;
    end;
    if List^[Left]>List^[Right] then begin
     v:=List^[Left];
     List^[Left]:=List^[Right];
     List^[Right]:=v;
    end;
    if List^[Middle]>List^[Right] then begin
     v:=List^[Middle];
     List^[Middle]:=List^[Right];
     List^[Right]:=v;
    end;
   end;
   Pivot:=List^[Middle];
   i:=Left;
   j:=Right;
   while true do begin
    while (i<j) and (List^[i]<Pivot) do begin
     inc(i);
    end;
    while (j>i) and (List^[j]>Pivot) do begin
     dec(j);
    end;
    if i>j then begin
     break;
    end;
    v:=List^[i];
    List^[i]:=List^[j];
    List^[j]:=v;
    inc(i);
    dec(j);
   end;
   IntroSort(Left,j,Depth-1);
   IntroSort(i,Right,Depth-1);
  end;
 begin
  if Left<Right then begin
   if (Right-Left)<16 then begin
    InsertionSort;
   end else if Depth=0 then begin
    HeapSort;
   end else begin
    QuickSortWidthMedianOfThreeOptimization;
   end;
  end;
 end;
 procedure QuickSort(L,R:TFLREInt32);
 var Pivot,vL,vR:TFLREInt32;
     v:TFLREInt32;
 begin
  if (R-L)<=1 then begin
   if (L<R) and (List[R]<List[L]) then begin
    v:=List^[L];
    List^[L]:=List^[R];
    List^[R]:=v;
   end;
  end else begin
   vL:=L;
   vR:=R;
   Pivot:=L+Random(R-L);
   while vL<vR do begin
    while (vL<Pivot) and (List^[vL]<=List^[Pivot]) do begin
     inc(vL);
    end;
    while (vR>Pivot) and (List^[vR]>List^[Pivot]) do begin
     dec(vR);
    end;
    v:=List^[vL];
    List^[vL]:=List^[vR];
    List^[vR]:=v;
    if Pivot=vL then begin
     Pivot:=vR;
    end else if Pivot=vR then begin
     Pivot:=vL;
    end;
   end;
   if (Pivot-1)>=L then begin
    QuickSort(L,Pivot-1);
   end;
   if (Pivot+1)<=R then begin
    QuickSort(Pivot+1,R);
   end;
  end;
 end;
 procedure QuickSortEx(Left,Right:TFLREInt32);
 var Pivot,i,j:TFLREInt32;
     v:TFLREInt32;
 begin
  i:=Left;
  j:=Right;
  Pivot:=List^[(i+j) div 2];
  while i<=j do begin
   while List^[i]<Pivot do begin
    inc(i);
   end;
   while List^[j]>Pivot do begin
    dec(j);
   end;
   if i<=j then begin
    v:=List^[i];
    List^[i]:=List^[i];
    List^[j]:=v;
    inc(i);
    dec(j);
   end;
  end;
  if Left<j then begin
   QuickSortEx(Left,j);
  end;
  if i<Right then begin
   QuickSortEx(i,Right);
  end;
 end;
 procedure BeRoSort;
 var i:TFLREInt32;
     v:TFLREInt32;
 begin
  i:=0;
  while i<(CountItems-1) do begin
   if List^[i]>List^[i+1] then begin
    v:=List^[i];
    List^[i]:=List^[i+1];
    List^[i+1]:=v;
    if i>0 then begin
     dec(i);
    end else begin
     inc(i);
    end;
   end else begin
    inc(i);
   end;
  end;
 end;
begin
 if CountItems>0 then begin
  IntroSort(0,CountItems-1,IntLog2(CountItems)*2);
  IsSorted:=true;
 end;
end;

constructor TFLRENodeHashSet.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TFLRENodeHashSet.Destroy;
var Counter:TFLREInt32;
begin
 Clear;
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter]:=nil;
 end;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 inherited Destroy;
end;

procedure TFLRENodeHashSet.Clear;
var Counter:TFLREInt32;
begin
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter]:=nil;
 end;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

function TFLRENodeHashSet.FindCell(const Key:PFLRENode):TFLREUInt32;
var HashCode,Mask,Step:TFLREUInt32;
    Entity:TFLREInt32;
begin
 HashCode:=HashPointer(Key);
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (Entities[Entity]=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TFLRENodeHashSet.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TFLREInt32;
    OldEntities:TFLRENodeHashSetEntities;
    OldCellToEntityIndex:TFLRENodeHashSetEntityIndices;
    OldEntityToCellIndex:TFLRENodeHashSetEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter]);
   end;
  end;
 end;
end;

procedure TFLRENodeHashSet.Toggle(const Key:PFLRENode;aInclude:boolean);
begin
 if Contains(Key)<>aInclude then begin
  if aInclude then begin
   Add(Key);
  end else begin
   Delete(key);
  end;
 end;
end;

procedure TFLRENodeHashSet.Add(const Key:PFLRENode);
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity]:=Key;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  Entities[Entity]:=Key;
 end;
end;

function TFLRENodeHashSet.Contains(const Key:PFLRENode):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 result:=Entity>=0;
end;

function TFLRENodeHashSet.Delete(const Key:PFLRENode):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity]:=nil;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

constructor TFLREStringIntegerPairHashMap.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TFLREStringIntegerPairHashMap.Destroy;
var Counter:TFLREInt32;
begin
 Clear;
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 inherited Destroy;
end;

procedure TFLREStringIntegerPairHashMap.Clear;
var Counter:TFLREInt32;
begin
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

procedure TFLREStringIntegerPairHashMap.LowerCaseAssignFrom(const HashMap:TFLREStringIntegerPairHashMap);
var Counter:TFLREInt32;
begin
 Clear;
 for Counter:=0 to length(HashMap.EntityToCellIndex)-1 do begin
  if HashMap.EntityToCellIndex[Counter]>=0 then begin
   Add(UTF8LowerCase(HashMap.Entities[Counter].Key),HashMap.Entities[Counter].Value);
  end;
 end;
end;

function TFLREStringIntegerPairHashMap.FindCell(const Key:TFLRERawByteString):TFLREUInt32;
var HashCode,Mask,Step:TFLREUInt32;
    Entity:TFLREInt32;
begin
 HashCode:=HashString(Key);
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (Entities[Entity].Key=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TFLREStringIntegerPairHashMap.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TFLREInt32;
    OldEntities:TFLREStringIntegerPairHashMapEntities;
    OldCellToEntityIndex:TFLREStringIntegerPairHashMapEntityIndices;
    OldEntityToCellIndex:TFLREStringIntegerPairHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 for Counter:=0 to length(OldEntities)-1 do begin
  OldEntities[Counter].Key:='';
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TFLREStringIntegerPairHashMap.Add(const Key:TFLRERawByteString;Value:TFLREStringIntegerPairHashMapData):PFLREStringIntegerPairHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
 end;
end;

function TFLREStringIntegerPairHashMap.Get(const Key:TFLRERawByteString;CreateIfNotExist:boolean=false):PFLREStringIntegerPairHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
 end else if CreateIfNotExist then begin
  result:=Add(Key,-1);
 end;
end;

function TFLREStringIntegerPairHashMap.Delete(const Key:TFLRERawByteString):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity].Key:='';
  Entities[Entity].Value:=-1;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TFLREStringIntegerPairHashMap.GetValue(const Key:TFLRERawByteString):TFLREStringIntegerPairHashMapData;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=Entities[Entity].Value;
 end else begin
  result:=-1;
 end;
end;

procedure TFLREStringIntegerPairHashMap.SetValue(const Key:TFLRERawByteString;const Value:TFLREStringIntegerPairHashMapData);
begin
 Add(Key,Value);
end;

constructor TFLRECharClassHashMap.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TFLRECharClassHashMap.Destroy;
begin
 Clear;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 inherited Destroy;
end;

procedure TFLRECharClassHashMap.Clear;
begin
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

function TFLRECharClassHashMap.FindCell(const Key:TFLRECharClass):TFLREUInt32;
var HashCode,Mask,Step:TFLREUInt32;
    Entity:TFLREInt32;
begin
 HashCode:=HashData(@Key,SizeOf(TFLRECharClass));
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (Entities[Entity].Key=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TFLRECharClassHashMap.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TFLREInt32;
    OldEntities:TFLRECharClassHashMapEntities;
    OldCellToEntityIndex:TFLRECharClassHashMapEntityIndices;
    OldEntityToCellIndex:TFLRECharClassHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TFLRECharClassHashMap.Add(const Key:TFLRECharClass;Value:TFLRECharClassHashMapData):PFLRECharClassHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
 end;
end;

function TFLRECharClassHashMap.Get(const Key:TFLRECharClass;CreateIfNotExist:boolean=false):PFLRECharClassHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
 end else if CreateIfNotExist then begin
  result:=Add(Key,-1);
 end;
end;

function TFLRECharClassHashMap.Delete(const Key:TFLRECharClass):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity].Key:=[];
  Entities[Entity].Value:=-1;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TFLRECharClassHashMap.GetValue(const Key:TFLRECharClass):TFLRECharClassHashMapData;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=Entities[Entity].Value;
 end else begin
  result:=-1;
 end;
end;

procedure TFLRECharClassHashMap.SetValue(const Key:TFLRECharClass;const Value:TFLRECharClassHashMapData);
begin
 Add(Key,Value);
end;

type TFLREUnicodeCharClass=class;

     TFLREUnicodeCharClassRange=class
      public
       CharClass:TFLREUnicodeCharClass;
       Previous,Next,Left,Right:TFLREUnicodeCharClassRange;
       Lo,Hi:TFLREUInt32;
       constructor Create(ACharClass:TFLREUnicodeCharClass;ALo,AHi:TFLREUInt32);
       constructor CreateBefore(ACharClass:TFLREUnicodeCharClass;ABefore:TFLREUnicodeCharClassRange;ALo,AHi:TFLREUInt32);
       constructor CreateAfter(ACharClass:TFLREUnicodeCharClass;AAfter:TFLREUnicodeCharClassRange;ALo,AHi:TFLREUInt32);
       destructor Destroy; override;
     end;

     TFLREUnicodeCharClassCharSet=set of TFLRERawByteChar;

     TFLREUnicodeCharClassRanges=array of TFLREUnicodeCharClassRange;

     TFLREUnicodeCharClass=class
      public
       First,Last,Root:TFLREUnicodeCharClassRange;
       CharSet:TFLREUnicodeCharClassCharSet;
       Inverted:longbool;
       Canonicalized:longbool;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Dump;
       procedure DebugDump;
       procedure Optimize;
       procedure AddRange(Lo,Hi:TFLREUInt32;IgnoreCase:boolean=false);
       procedure AddChar(c:TFLREUInt32;IgnoreCase:boolean=false);
       procedure AddUnicodeCategory(CategoryFlags:TFLREUInt32;IgnoreCase:boolean=false);
       procedure AddUnicodeScript(Script:TFLREUInt32;IgnoreCase:boolean=false);
       procedure AddUnicodeBlock(Block:TFLREUInt32;IgnoreCase:boolean=false);
       procedure AddUnicodeAdditionalBlock(Block:TFLREUInt32;IgnoreCase:boolean=false);
       procedure Combine(From:TFLREUnicodeCharClass);
       function Subtraction(From,SubtractWith:TFLREUnicodeCharClass):boolean;
       function Intersection(From,IntersectWith:TFLREUnicodeCharClass):boolean;
       function IntersectionWithLowerUpperCaseUnicodeCharClass(From:TFLREUnicodeCharClass):boolean;
       procedure TakeoverCombine(From:TFLREUnicodeCharClass);
       procedure TakeoverDirtyCombine(From:TFLREUnicodeCharClass);
       procedure Assign(From:TFLREUnicodeCharClass);
       procedure Append(From:TFLREUnicodeCharClass);
       procedure Invert;
       procedure Canonicalize;
       procedure CompileBinarySearchTree;
       procedure CompileCharset;
       procedure Finalize;
       function Count:TFLREUInt32;
       function Contains(c:TFLREUInt32):boolean;
       function Intersects(Other:TFLREUnicodeCharClass):boolean;
       function IsSingle:boolean;
       function HashCode:TFLREUInt32;
       function EqualsTo(OtherObject:TFLREUnicodeCharClass):boolean;
     end;

constructor TFLREUnicodeCharClassRange.Create(ACharClass:TFLREUnicodeCharClass;ALo,AHi:TFLREUInt32);
begin
 inherited Create;
 CharClass:=ACharClass;
 Lo:=ALo;
 Hi:=AHi;
 if assigned(CharClass.Last) then begin
  Previous:=CharClass.Last;
  CharClass.Last:=self;
  Previous.Next:=self;
  Next:=nil;
 end else begin
  CharClass.First:=self;
  CharClass.Last:=self;
  Previous:=nil;
  Next:=nil;
 end;
 Left:=nil;
 Right:=nil;
end;

constructor TFLREUnicodeCharClassRange.CreateBefore(ACharClass:TFLREUnicodeCharClass;ABefore:TFLREUnicodeCharClassRange;ALo,AHi:TFLREUInt32);
begin
 inherited Create;
 CharClass:=ACharClass;
 Lo:=ALo;
 Hi:=AHi;
 Previous:=ABefore.Previous;
 Next:=ABefore;
 ABefore.Previous:=self;
 if assigned(Previous) then begin
  Previous.Next:=self;
 end else begin
  CharClass.First:=self;
 end;
end;

constructor TFLREUnicodeCharClassRange.CreateAfter(ACharClass:TFLREUnicodeCharClass;AAfter:TFLREUnicodeCharClassRange;ALo,AHi:TFLREUInt32);
begin
 inherited Create;
 CharClass:=ACharClass;
 Lo:=ALo;
 Hi:=AHi;
 Previous:=AAfter;
 Next:=AAfter.Next;
 AAfter.Next:=self;
 if assigned(Next) then begin
  Next.Previous:=self;
 end else begin
  CharClass.Last:=self;
 end;
end;

destructor TFLREUnicodeCharClassRange.Destroy;
begin
 if assigned(Previous) then begin
  Previous.Next:=Next;
 end else if CharClass.First=self then begin
  CharClass.First:=Next;
 end;
 if assigned(Next) then begin
  Next.Previous:=Previous;
 end else if CharClass.Last=self then begin
  CharClass.Last:=Previous;
 end;
 Previous:=nil;
 Next:=nil;
 inherited Destroy;
end;

constructor TFLREUnicodeCharClass.Create;
begin
 inherited Create;
 First:=nil;
 Last:=nil;
 Root:=nil;
 Inverted:=false;
 Canonicalized:=false;
 CharSet:=[];
end;

destructor TFLREUnicodeCharClass.Destroy;
begin
 while assigned(First) do begin
  First.Free;
 end;
 inherited Destroy;
end;

procedure TFLREUnicodeCharClass.Clear;
begin
 while assigned(First) do begin
  First.Free;
 end;
 Inverted:=false;
 Canonicalized:=false;
 Root:=nil;
end;

procedure TFLREUnicodeCharClass.Dump;
var Range:TFLREUnicodeCharClassRange;
begin
 Range:=First;
 while assigned(Range) do begin
  writeln(Range.Lo:8,' ',Range.Hi:8);
  Range:=Range.Next;
 end;
end;

procedure TFLREUnicodeCharClass.DebugDump;
var Range:TFLREUnicodeCharClassRange;
begin
 Range:=First;
 while assigned(Range) do begin
  Range:=Range.Next;
 end;
end;

procedure TFLREUnicodeCharClass.Optimize;
var Range:TFLREUnicodeCharClassRange;
begin
 Range:=First;
 while assigned(Range) do begin
  if assigned(Range.Previous) and (((Range.Previous.Hi>=Range.Lo) or ((Range.Previous.Hi+1)=Range.Lo))) then begin
   if Range.Lo>Range.Previous.Lo then begin
    Range.Lo:=Range.Previous.Lo;
   end;
   if Range.Hi<Range.Previous.Hi then begin
    Range.Hi:=Range.Previous.Hi;
   end;
   Range.Previous.Free;
   if assigned(Range.Previous) then begin
    Range:=Range.Previous;
   end;
  end else if assigned(Range.Next) and (((Range.Hi>=Range.Next.Lo) or ((Range.Hi+1)=Range.Next.Lo))) then begin
   if Range.Lo>Range.Next.Lo then begin
    Range.Lo:=Range.Next.Lo;
   end;
   if Range.Hi<Range.Next.Hi then begin
    Range.Hi:=Range.Next.Hi;
   end;
   Range.Next.Free;
   if assigned(Range.Previous) then begin
    Range:=Range.Previous;
   end;
  end else begin
   Range:=Range.Next;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.AddRange(Lo,Hi:TFLREUInt32;IgnoreCase:boolean=false);
var Range,TempRange:TFLREUnicodeCharClassRange;
    c,cl,cu:TFLREUInt32;
    Temp,OtherTemp:TFLREUnicodeCharClass;
begin
 if IgnoreCase then begin
  AddRange(Lo,Hi,false);
  Temp:=TFLREUnicodeCharClass.Create;
  try
   OtherTemp:=TFLREUnicodeCharClass.Create;
   try
    OtherTemp.AddRange(Lo,Hi,false);
    Temp.IntersectionWithLowerUpperCaseUnicodeCharClass(OtherTemp);
   finally
    OtherTemp.Free;
   end;
   TempRange:=Temp.First;
   while assigned(TempRange) do begin
    for c:=TempRange.Lo to TempRange.Hi do begin
     cl:=UnicodeToLower(c);
     cu:=UnicodeToUpper(c);
     if cl<>c then begin
      AddRange(cl,cl,false);
     end;
     if cu<>c then begin
      AddRange(cu,cu,false);
     end;
    end;
    TempRange:=TempRange.Next;
   end;
  finally
   Temp.Free;
  end;
 end else begin
  Range:=First;
  while assigned(Range) do begin
   if (Lo>=Range.Lo) and (Hi<=Range.Hi) then begin
    exit;
   end else if (Lo<=Range.Lo) or ((Lo=Range.Lo) and (Hi<=Range.Hi)) then begin
    break;
   end;
   Range:=Range.Next;
  end;
  if assigned(Range) then begin
   TFLREUnicodeCharClassRange.CreateBefore(self,Range,Lo,Hi);
  end else begin
   TFLREUnicodeCharClassRange.Create(self,Lo,Hi);
  end;
  Optimize;
 end;
end;

procedure TFLREUnicodeCharClass.AddChar(c:TFLREUInt32;IgnoreCase:boolean=false);
begin
 AddRange(c,c,IgnoreCase);
end;

procedure TFLREUnicodeCharClass.AddUnicodeCategory(CategoryFlags:TFLREUInt32;IgnoreCase:boolean=false);
var Range:TFLREInt32;
    UnicodeCharRanges:PPUCUUnicodeCharRanges;
    Bits,Category:TFLREUInt32;
begin
 Bits:=CategoryFlags;
 while Bits<>0 do begin
  Category:=PopFirstOneBit(Bits);
  if Category<PUCUUnicodeCategoryCount then begin
   if IgnoreCase then begin
    UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeIgnoreCaseCategoryBlocksData[Category]);
    for Range:=0 to PUCUUnicodeIgnoreCaseCategoryBlocksCounts[Category]-1 do begin
     AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
    end;
   end else begin
    UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeCategoryBlocksData[Category]);
    for Range:=0 to PUCUUnicodeCategoryBlocksCounts[Category]-1 do begin
     AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
    end;
   end;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.AddUnicodeScript(Script:TFLREUInt32;IgnoreCase:boolean=false);
var Range:TFLREInt32;
    UnicodeCharRanges:PPUCUUnicodeCharRanges;
begin
 if Script<PUCUUnicodeScriptCount then begin
  if IgnoreCase then begin
   UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeIgnoreCaseScriptBlocksData[Script]);
   for Range:=0 to PUCUUnicodeIgnoreCaseScriptBlocksCounts[Script]-1 do begin
    AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
   end;
  end else begin
   UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeScriptBlocksData[Script]);
   for Range:=0 to PUCUUnicodeScriptBlocksCounts[Script]-1 do begin
    AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
   end;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.AddUnicodeBlock(Block:TFLREUInt32;IgnoreCase:boolean=false);
var Range:TFLREInt32;
    UnicodeCharRanges:PPUCUUnicodeCharRanges;
begin
 if Block<PUCUUnicodeBlockCount then begin
  if IgnoreCase then begin
   UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeIgnoreCaseBlockBlocksData[Block]);
   for Range:=0 to PUCUUnicodeIgnoreCaseBlockBlocksCounts[Block]-1 do begin
    AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
   end;
  end else begin
   UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeBlockBlocksData[Block]);
   for Range:=0 to PUCUUnicodeBlockBlocksCounts[Block]-1 do begin
    AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
   end;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.AddUnicodeAdditionalBlock(Block:TFLREUInt32;IgnoreCase:boolean=false);
var Range:TFLREInt32;
    UnicodeCharRanges:PPUCUUnicodeCharRanges;
begin
 if IgnoreCase then begin
  UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeIgnoreCaseAdditionalBlocksData[Block]);
  for Range:=0 to PUCUUnicodeIgnoreCaseAdditionalBlocksCounts[Block]-1 do begin
   AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
  end;
 end else begin
  UnicodeCharRanges:=PPUCUUnicodeCharRanges(PUCUUnicodeAdditionalBlocksData[Block]);
  for Range:=0 to PUCUUnicodeAdditionalBlocksCounts[Block]-1 do begin
   AddRange(UnicodeCharRanges^[Range,0],UnicodeCharRanges^[Range,1],false);
  end;
 end;
end;

procedure TFLREUnicodeCharClass.Combine(From:TFLREUnicodeCharClass);
var Range:TFLREUnicodeCharClassRange;
begin
 if assigned(From) then begin
  if assigned(First) then begin
   Canonicalized:=Canonicalized and From.Canonicalized;
  end else begin
   Canonicalized:=From.Canonicalized;
  end;
  Range:=From.First;
  while assigned(Range) do begin
   AddRange(Range.Lo,Range.Hi,false);
   Range:=Range.Next;
  end;
 end;
end;
                                 
function TFLREUnicodeCharClass.Subtraction(From,SubtractWith:TFLREUnicodeCharClass):boolean;
var Range1,Range2:TFLREUnicodeCharClassRange;
    First,Min,Max:TFLREUInt32;
begin
 result:=false;
 if ((assigned(From) and assigned(SubtractWith)) and (assigned(From.First) and assigned(SubtractWith.First))) and ((From.First.Lo<=SubtractWith.Last.Hi) and (SubtractWith.First.Lo<=From.Last.Hi)) then begin
  Canonicalized:=From.Canonicalized;
  Range1:=From.First;
  while assigned(Range1) do begin
   First:=Range1.Lo;
   Range2:=SubtractWith.First;
   while assigned(Range2) do begin
    if (First<=Range2.Hi) and (Range2.Lo<=Range1.Hi) then begin
     result:=true;
     if First>Range2.Lo then begin
      Min:=First;
     end else begin
      Min:=Range2.Lo;
     end;
     if Range1.Hi<Range2.Hi then begin
      Max:=Range1.Hi;
     end else begin
      Max:=Range2.Hi;
     end;
     if First<Min then begin
      AddRange(First,Min-1,false);
     end;
     First:=Max+1;
    end;
    Range2:=Range2.Next;
   end;
   if First<=Range1.Hi then begin
    AddRange(First,Range1.Hi,false);
   end;
   Range1:=Range1.Next;
  end;
 end;
end;

function TFLREUnicodeCharClass.Intersection(From,IntersectWith:TFLREUnicodeCharClass):boolean;
var Range1,Range2:TFLREUnicodeCharClassRange;
    Min,Max:TFLREUInt32;
begin
 result:=false;
 if ((assigned(From) and assigned(IntersectWith)) and (assigned(From.First) and assigned(IntersectWith.First))) and ((From.First.Lo<=IntersectWith.Last.Hi) and (IntersectWith.First.Lo<=From.Last.Hi)) then begin
  Canonicalized:=From.Canonicalized;
  Range1:=From.First;
  while assigned(Range1) do begin
   Range2:=IntersectWith.First;
   while assigned(Range2) do begin
    if (Range1.Lo<=Range2.Hi) and (Range2.Lo<=Range1.Hi) then begin
     result:=true;
     if Range1.Lo>Range2.Lo then begin
      Min:=Range1.Lo;
     end else begin
      Min:=Range2.Lo;
     end;
     if Range1.Hi<Range2.Hi then begin
      Max:=Range1.Hi;
     end else begin
      Max:=Range2.Hi;
     end;
     if Min<=Max then begin
      AddRange(Min,Max,false);
     end;
    end;
    Range2:=Range2.Next;
   end;
   Range1:=Range1.Next;
  end;
 end;
end;

function TFLREUnicodeCharClass.IntersectionWithLowerUpperCaseUnicodeCharClass(From:TFLREUnicodeCharClass):boolean;
var Range2:TFLREInt32;
    Range1:TFLREUnicodeCharClassRange;
    Min,Max:TFLREUInt32;
begin
 result:=false;
 if (assigned(From) and assigned(From.First)) and
    ((From.First.Lo<=PUCULowerUpperCaseUnicodeCharClass[PUCULowerUpperCaseUnicodeCharClassSize-1,1]) and
     (PUCULowerUpperCaseUnicodeCharClass[0,0]<=From.Last.Hi)) then begin
  Canonicalized:=From.Canonicalized;
  Range1:=From.First;
  while assigned(Range1) do begin
   for Range2:=0 to PUCULowerUpperCaseUnicodeCharClassSize-1 do begin
    if (Range1.Lo<=PUCULowerUpperCaseUnicodeCharClass[Range2,1]) and (PUCULowerUpperCaseUnicodeCharClass[Range2,0]<=Range1.Hi) then begin
     result:=true;
     if Range1.Lo>PUCULowerUpperCaseUnicodeCharClass[Range2,0] then begin
      Min:=Range1.Lo;
     end else begin
      Min:=PUCULowerUpperCaseUnicodeCharClass[Range2,0];
     end;
     if Range1.Hi<PUCULowerUpperCaseUnicodeCharClass[Range2,1] then begin
      Max:=Range1.Hi;
     end else begin
      Max:=PUCULowerUpperCaseUnicodeCharClass[Range2,1];
     end;
     if Min<=Max then begin
      AddRange(Min,Max,false);
     end;
    end;
   end;
   Range1:=Range1.Next;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.TakeoverCombine(From:TFLREUnicodeCharClass);
var SrcRange,NextSrcRange,Range:TFLREUnicodeCharClassRange;
begin
 if assigned(From) then begin
  if assigned(First) then begin
   Canonicalized:=Canonicalized and From.Canonicalized;
  end else begin
   Canonicalized:=From.Canonicalized;
  end;
  SrcRange:=From.First;
  while assigned(SrcRange) do begin
   Range:=First;
   while assigned(Range) do begin
    if (SrcRange.Lo>=Range.Lo) and (SrcRange.Hi<=Range.Hi) then begin
     exit;
    end else if (SrcRange.Lo<=Range.Lo) or ((SrcRange.Lo=Range.Lo) and (SrcRange.Hi<=Range.Hi)) then begin
     break;
    end;
    Range:=Range.Next;
   end;
   SrcRange.CharClass:=self;
   NextSrcRange:=SrcRange.Next;
   if assigned(SrcRange.Previous) then begin
    SrcRange.Previous.Next:=SrcRange.Next;
   end else if From.First=SrcRange then begin
    From.First:=SrcRange.Next;
   end;
   if assigned(SrcRange.Next) then begin
    SrcRange.Next.Previous:=SrcRange.Previous;
   end else if From.Last=SrcRange then begin
    From.Last:=SrcRange.Previous;
   end;
   SrcRange.Previous:=nil;
   SrcRange.Next:=nil;
   if assigned(Range) then begin
    SrcRange.Previous:=Range.Previous;
    SrcRange.Next:=Range;
    Range.Previous:=SrcRange;
    if assigned(SrcRange.Previous) then begin
     SrcRange.Previous.Next:=SrcRange;
    end else begin
     SrcRange.CharClass.First:=SrcRange;
    end;
   end else begin
    if assigned(SrcRange.CharClass.Last) then begin
     SrcRange.Previous:=SrcRange.CharClass.Last;
     SrcRange.CharClass.Last:=SrcRange;
     SrcRange.Previous.Next:=SrcRange;
     SrcRange.Next:=nil;
    end else begin
     SrcRange.CharClass.First:=SrcRange;
     SrcRange.CharClass.Last:=SrcRange;
     SrcRange.Previous:=nil;
     SrcRange.Next:=nil;
    end;
   end;
   Optimize;
   SrcRange:=NextSrcRange;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.TakeoverDirtyCombine(From:TFLREUnicodeCharClass);
var SrcRange:TFLREUnicodeCharClassRange;
begin
 if assigned(From) then begin
  if assigned(First) then begin
   Canonicalized:=Canonicalized and From.Canonicalized;
  end else begin
   Canonicalized:=From.Canonicalized;
  end;
  SrcRange:=From.First;
  while assigned(SrcRange) do begin
   SrcRange.CharClass:=self;
   SrcRange:=SrcRange.Next;
  end;
  if assigned(Last) then begin
   Last.Next:=From.First;
   From.First.Previous:=Last;
   Last:=From.Last;
  end else begin
   First:=From.First;
   Last:=From.Last;
  end;
  From.First:=nil;
  From.Last:=nil;
 end;
end;

procedure TFLREUnicodeCharClass.Assign(From:TFLREUnicodeCharClass);
var Range:TFLREUnicodeCharClassRange;
begin
 if assigned(From) then begin
  while assigned(First) do begin
   First.Free;
  end;
  Inverted:=From.Inverted;
  Canonicalized:=From.Canonicalized;
  Range:=From.First;
  while assigned(Range) do begin
   Range.CharClass:=self;
   Range:=Range.Next;
  end;
  First:=From.First;
  Last:=From.Last;
  From.First:=nil;
  From.Last:=nil;
 end;
end;

procedure TFLREUnicodeCharClass.Append(From:TFLREUnicodeCharClass);
var Range:TFLREUnicodeCharClassRange;
begin
 if assigned(From) then begin
  Range:=From.First;
  while assigned(Range) do begin
   TFLREUnicodeCharClassRange.Create(self,Range.Lo,Range.Hi);
   Range:=Range.Next;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.Invert;
var NewList:TFLREUnicodeCharClass;
    Range:TFLREUnicodeCharClassRange;
    Lo,Hi:TFLREUInt32;
begin
 Optimize;
 Inverted:=not Inverted;
 if assigned(First) and (First=Last) and (First.Lo=0) and (First.Hi=$ffffffff) then begin
  First.Free;
 end else if not assigned(First) then begin
  TFLREUnicodeCharClassRange.Create(self,0,$ffffffff);
 end else begin
  NewList:=TFLREUnicodeCharClass.Create;
  try
   Range:=First;
   if Range.Lo>0 then begin
    TFLREUnicodeCharClassRange.Create(NewList,0,Range.Lo-1);
   end;
   Lo:=Range.Hi;
   Range:=Range.Next;
   while assigned(Range) do begin
    if (Lo+1)<Range.Lo then begin
     Hi:=Range.Lo;
     TFLREUnicodeCharClassRange.Create(NewList,Lo+1,Hi-1);
    end;
    Lo:=Range.Hi;
    Range:=Range.Next;
   end;
   if Lo<>$ffffffff then begin
    TFLREUnicodeCharClassRange.Create(NewList,Lo+1,$ffffffff);
   end;
   while assigned(First) do begin
    First.Free;
   end;
   Range:=NewList.First;
   while assigned(Range) do begin
    Range.CharClass:=self;
    Range:=Range.Next;
   end;
   First:=NewList.First;
   Last:=NewList.Last;
   NewList.First:=nil;
   NewList.Last:=nil;
   Range:=First;
   while assigned(Range) do begin
    Range.CharClass:=self;
    Range:=Range.Next;
   end;
  finally
   NewList.Free;
  end;
 end;
end;

procedure TFLREUnicodeCharClass.Canonicalize;
var NewList:TFLREUnicodeCharClass;
    Range:TFLREUnicodeCharClassRange;
    OldInverted:boolean;
begin
 if not Canonicalized then begin
  NewList:=TFLREUnicodeCharClass.Create;
  try
   OldInverted:=Inverted;
   if Inverted then begin
    Invert;
   end;
   Range:=First;
   while assigned(Range) do begin
    NewList.AddRange(Range.Lo,Range.Hi,true);
    Range:=Range.Next;
   end;
   while assigned(First) do begin
    First.Free;
   end;
   First:=NewList.First;
   Last:=NewList.Last;
   NewList.First:=nil;
   NewList.Last:=nil;
   Range:=First;
   while assigned(Range) do begin
    Range.CharClass:=self;
    Range:=Range.Next;
   end;
   if OldInverted then begin
    Invert;
   end;
   Inverted:=OldInverted;
  finally
   NewList.Free;
  end;
  Canonicalized:=true;
 end;
end;

procedure TFLREUnicodeCharClass.CompileBinarySearchTree;
type PTFLREUnicodeCharClassRange=^TFLREUnicodeCharClassRange;
var Ranges:TFLREUnicodeCharClassRanges;
 procedure Process(Parent:PTFLREUnicodeCharClassRange;LowIndex,HighIndex:TFLREInt32);
 var Middle:TFLREInt32;
 begin
  while LowIndex<=HighIndex do begin
   Middle:=(LowIndex+HighIndex) div 2;
   Parent^:=Ranges[Middle];
   case HighIndex-LowIndex of
    0:begin
     break;
    end;
    1:begin
     if Middle=LowIndex then begin
      Parent:=@Parent^.Right;
      LowIndex:=Middle+1;
     end else begin
      Parent:=@Parent^.Left;
      HighIndex:=Middle-1;
     end;
    end;
    else begin
     Process(@Parent^.Left,LowIndex,Middle-1);
     Parent:=@Parent^.Right;
     LowIndex:=Middle+1;
    end;
   end;
  end;
 end;
var Range:TFLREUnicodeCharClassRange;
    Count:TFLREInt32;
begin
 Root:=nil;
 Ranges:=nil;
 try
  Count:=0;
  Range:=First;
  while assigned(Range) do begin
   inc(Count);
   Range:=Range.Next;
  end;
  SetLength(Ranges,Count);
  Count:=0;
  Range:=First;
  while assigned(Range) do begin
   Ranges[Count]:=Range;
   inc(Count);
   Range:=Range.Next;
  end;
  if Count>0 then begin
   Process(@Root,0,Count-1);
  end;
 finally
  SetLength(Ranges,0);
 end;
end;

procedure TFLREUnicodeCharClass.CompileCharset;
var Range:TFLREUnicodeCharClassRange;
begin
 CharSet:=[];
 Range:=First;
 while assigned(Range) and (Range.Lo<256) do begin
  if Range.Lo=Range.Hi then begin
   System.Include(CharSet,TFLRERawByteChar(TFLREUInt8(Range.Lo)));
  end else begin
   if Range.Hi<256 then begin
    CharSet:=CharSet+[TFLRERawByteChar(TFLREUInt8(Range.Lo))..TFLRERawByteChar(TFLREUInt8(Range.Hi))];
   end else begin
    CharSet:=CharSet+[TFLRERawByteChar(TFLREUInt8(Range.Lo))..#$ff];
   end;
  end;
  Range:=Range.Next;
 end;
end;

procedure TFLREUnicodeCharClass.Finalize;
begin
 CompileCharset;
 CompileBinarySearchTree;
end;

function TFLREUnicodeCharClass.Count:TFLREUInt32;
var Range:TFLREUnicodeCharClassRange;
begin
 result:=0;
 Range:=First;
 while assigned(Range) do begin
  inc(result,(Range.Hi-Range.Lo)+1);
  Range:=Range.Next;
 end;
end;

function TFLREUnicodeCharClass.Contains(c:TFLREUInt32):boolean;
var Range:TFLREUnicodeCharClassRange;
begin
 result:=false;
 Range:=Root;
 if assigned(Range) and ((c>=First.Lo) and (c<=Last.Hi)) then begin
  if First=Last then begin
   result:=true;
   exit;
  end else begin
   if c<256 then begin
    result:=TFLRERawByteChar(TFLREUInt8(c)) in CharSet;
   end else begin
    repeat
     if (c>=Range.Lo) and (c<=Range.Hi) then begin
      result:=true;
      break;
     end;
     if c<Range.Lo then begin
      Range:=Range.Left;
      continue;
     end;
     if Range.Hi<c then begin
      Range:=Range.Right;
      continue;
     end;
     result:=false;
     break;
    until not assigned(Range);
   end;
  end;
 end;
end;

function TFLREUnicodeCharClass.Intersects(Other:TFLREUnicodeCharClass):boolean;
var Range1,Range2:TFLREUnicodeCharClassRange;
begin
 result:=false;
 if (assigned(Other) and (assigned(First) and assigned(Other.First))) and ((First.Lo<=Other.Last.Hi) and (Other.First.Lo<=Last.Hi)) then begin
  Range1:=First;
  while assigned(Range1) do begin
   Range2:=Other.First;
   while assigned(Range2) do begin
    if (Range1.Lo<=Range2.Hi) and (Range2.Lo<=Range1.Hi) then begin
     result:=true;
     exit;
    end;
    Range2:=Range2.Next;
   end;
   Range1:=Range1.Next;
  end;
 end;
end;

function TFLREUnicodeCharClass.IsSingle:boolean;
begin
 result:=(First=Last) and ((assigned(First) and (First.Lo=First.Hi)) or not assigned(First));
end;

function TFLREUnicodeCharClass.HashCode:TFLREUInt32;
var Range:TFLREUnicodeCharClassRange;
    h,i:TFLREUInt32;
begin
 result:=$811c9dc5;
 Range:=First;
 h:=0;
 while assigned(Range) do begin
  inc(h);
  Range:=Range.Next;
 end;
 Range:=First;
 while assigned(Range) do begin
  i:=((Range.Hi and $ffff) shl 16) or (Range.Lo and $ffff);
  h:=(h xor i) xor $2e63823a;
  inc(h,(h shl 15) or (h shr (32-15)));
  dec(h,(h shl 9) or (h shr (32-9)));
  inc(h,(h shl 4) or (h shr (32-4)));
  dec(h,(h shl 1) or (h shr (32-1)));
  h:=h xor (h shl 2) or (h shr (32-2));
  result:=result xor i;
  inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  i:=(Range.Hi and $ffff0000) or ((Range.Lo and $ffff0000) shr 16);
  h:=(h xor i) xor $2e63823a;
  inc(h,(h shl 15) or (h shr (32-15)));
  dec(h,(h shl 9) or (h shr (32-9)));
  inc(h,(h shl 4) or (h shr (32-4)));
  dec(h,(h shl 1) or (h shr (32-1)));
  h:=h xor (h shl 2) or (h shr (32-2));
  result:=result xor i;
  inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  Range:=Range.Next;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function CompareCharClasses(c1,c2:TFLREUnicodeCharClass):TFLREInt32;
var r1,r2:TFLREUnicodeCharClassRange;
begin
 r1:=c1.First;
 r2:=c2.First;
 while assigned(r1) and assigned(r2) do begin
  if r1.Lo<>r2.Lo then begin
   result:=TFLREInt32(r1.Lo)-TFLREInt32(r2.Lo);
   exit;
  end;
  if r1.Hi<>r2.Hi then begin
   result:=TFLREInt32(r1.Hi)-TFLREInt32(r2.Hi);
   exit;
  end;
  r1:=r1.Next;
  r2:=r2.Next;
 end;
 if assigned(r1) then begin
  result:=1;
 end else if assigned(r2) then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function TFLREUnicodeCharClass.EqualsTo(OtherObject:TFLREUnicodeCharClass):boolean;
begin
 result:=CompareCharClasses(self,TFLREUnicodeCharClass(OtherObject))=0;
end;

function TFLREPrefilterNodeList.GetNodeItem(Index:TFLREInt32):TFLREPrefilterNode;
begin
 result:=TFLREPrefilterNode(inherited Items[Index]);
end;

procedure TFLREPrefilterNodeList.SetNodeItem(Index:TFLREInt32;Value:TFLREPrefilterNode);
begin
 inherited Items[Index]:=Value;
end;

constructor TFLREPrefilterNode.Create;
begin
 inherited Create;
 Operation:=FLREpfnoANY;
 Subs:=TFLREPrefilterNodeList.Create;
 Atom:='';
 Exact:=false;
end;

destructor TFLREPrefilterNode.Destroy;
var Counter:TFLREInt32;
begin
 for Counter:=0 to Subs.Count-1 do begin
  Subs[Counter].Free;
 end;
 FreeAndNil(Subs);
 Atom:='';
 inherited Destroy;
end;

function TFLREPrefilterNode.Clone:TFLREPrefilterNode;
var Counter:TFLREInt32;
begin
 result:=TFLREPrefilterNode.Create;
 result.Operation:=Operation;
 result.Atom:=Atom;
 result.Exact:=Exact;
 for Counter:=0 to Subs.Count-1 do begin
  result.Subs.Add(Subs[Counter].Clone);
 end;
end;

function TFLREPrefilterNode.Expression:TFLRERawByteString;
var Counter:TFLREInt32;
    s:TFLRERawByteString;
begin
 result:='';
 case Operation of
  FLREpfnoATOM:begin
   result:=Atom;
   Counter:=1;
   while Counter<=length(result) do begin
    case result[Counter] of
     '\','"':begin
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #0:begin
      result[Counter]:='0';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     else begin
      inc(Counter);
     end;
    end;
   end;
   result:='"'+result+'"';
  end;
  FLREpfnoANY:begin
   result:='*';
  end;
  FLREpfnoAND:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].Expression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].Expression;
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' AND ';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
  FLREpfnoOR:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].Expression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].Expression;
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' OR ';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
 end;
end;

function TFLREPrefilterNode.ShortExpression:TFLRERawByteString;
var Counter:TFLREInt32;
    s:TFLRERawByteString;
begin
 result:='';
 case Operation of
  FLREpfnoATOM:begin
   result:=Atom;
   Counter:=1;
   while Counter<=length(result) do begin
    case result[Counter] of
     '\','(',')','|','*':begin
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #0:begin
      result[Counter]:='0';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     else begin
      inc(Counter);
     end;
    end;
   end;
  end;
  FLREpfnoANY:begin
   result:='*';
  end;
  FLREpfnoAND:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].ShortExpression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      result:=result+Subs[Counter].ShortExpression;
     end;
     result:='('+result+')';
    end;
   end;
  end;
  FLREpfnoOR:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].ShortExpression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].ShortExpression;
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+'|';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
 end;
end;

function TFLREPrefilterNode.SQLBooleanFullTextExpression:TFLRERawByteString;
var Counter:TFLREInt32;
    s:TFLRERawByteString;
begin
 result:='';
 case Operation of
  FLREpfnoATOM:begin
   result:=Atom;
   Counter:=1;
   while Counter<=length(result) do begin
    case result[Counter] of
     '\','"','''','%':begin
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$1a:begin
      result[Counter]:='Z';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$13:begin
      result[Counter]:='r';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$10:begin
      result[Counter]:='n';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$00:begin
      result[Counter]:='0';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     else begin
      inc(Counter);
     end;
    end;
   end;
   result:='"'+result+'"';
  end;
  FLREpfnoANY:begin
   result:='';
  end;
  FLREpfnoAND:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].SQLBooleanFullTextExpression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].SQLBooleanFullTextExpression;
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' ';
       end;
       result:=result+'+'+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
  FLREpfnoOR:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].SQLBooleanFullTextExpression;
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].SQLBooleanFullTextExpression;
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' ';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
 end;
end;

function TFLREPrefilterNode.SQLExpression(const Field:TFLRERawByteString):TFLRERawByteString;
var Counter:TFLREInt32;
    s:TFLRERawByteString;
begin
 result:='';
 case Operation of
  FLREpfnoATOM:begin
   result:=Atom;
   Counter:=1;
   while Counter<=length(result) do begin
    case result[Counter] of
     '\','"','''','%':begin
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$1a:begin
      result[Counter]:='Z';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$13:begin
      result[Counter]:='r';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$10:begin
      result[Counter]:='n';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     #$00:begin
      result[Counter]:='0';
      System.Insert('\',result,Counter);
      inc(Counter,2);
     end;
     else begin
      inc(Counter);
     end;
    end;
   end;
   if length(result)>0 then begin
    result:='('+Field+' LIKE ''%'+result+'%'')';
   end;
  end;
  FLREpfnoAND:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].SQLExpression(Field);
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].SQLExpression(Field);
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' AND ';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
  FLREpfnoOR:begin
   case Subs.Count of
    0:begin
     result:='';
    end;
    1:begin
     result:=Subs[0].SQLExpression(Field);
    end;
    else begin
     for Counter:=0 to Subs.Count-1 do begin
      s:=Subs[Counter].SQLExpression(Field);
      if length(s)>0 then begin
       if length(result)>0 then begin
        result:=result+' OR ';
       end;
       result:=result+s;
      end;
     end;
     result:='('+result+')';
    end;
   end;
  end;
  else begin
  end;
 end;
end;

constructor TFLREParallelNFA.Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
var Index:TFLRESizeInt;
begin
 inherited Create;

 ThreadLocalStorageInstance:=AThreadLocalStorageInstance;

 Instance:=ThreadLocalStorageInstance.Instance;

 MatchMode:=ThreadLocalStorageInstance.MatchMode;

 Generation:=0;

 InstructionGenerations:=nil;
 SetLength(InstructionGenerations,Instance.CountForwardInstructions);
 for Index:=0 to length(InstructionGenerations)-1 do begin
  InstructionGenerations[Index]:=-1;
 end;

 ParallelNFAThreadLists[0].Threads:=nil;
 ParallelNFAThreadLists[1].Threads:=nil;
 SetLength(ParallelNFAThreadLists[0].Threads,Instance.CountForwardInstructions*2);
 SetLength(ParallelNFAThreadLists[1].Threads,Instance.CountForwardInstructions*2);

 ParallelNFAStack:=nil;
 SetLength(ParallelNFAStack,Instance.CountForwardInstructions*2);

 FreeStates:=nil;
 AllStates:=TFLREPointerList.Create;

end;

destructor TFLREParallelNFA.Destroy;
var State:PFLREParallelNFAState;
begin

 while assigned(FreeStates) do begin
  State:=FreeStates;
  FreeStates:=FreeStates^.Next;
  SetLength(State^.SubMatches,0);
  Finalize(State^);
  FreeMem(State);
 end;
 FreeStates:=nil;

 FreeAndNil(AllStates);

 SetLength(InstructionGenerations,0);

 SetLength(ParallelNFAThreadLists[0].Threads,0);
 SetLength(ParallelNFAThreadLists[1].Threads,0);

 SetLength(ParallelNFAStack,0);

 inherited Destroy;
end;

function TFLREParallelNFA.StateAllocate(const Count:TFLREInt32;const SubMatchesBitmap:TFLREUInt32):PFLREParallelNFAState;
begin
 if assigned(FreeStates) then begin
  result:=FreeStates;
  FreeStates:=result^.Next;
 end else begin
  GetMem(result,SizeOf(TFLREParallelNFAState));
  FillChar(result^,SizeOf(TFLREParallelNFAState),#0);
  SetLength(result^.SubMatches,Instance.CountSubMatches);
  AllStates.Add(result);
 end;
 result^.ReferenceCounter:=1;
 result^.Count:=Count;
 result^.SubMatchesBitmap:=SubMatchesBitmap;
end;

function TFLREParallelNFA.StateAcquire(const State:PFLREParallelNFAState):PFLREParallelNFAState;
begin
 inc(State^.ReferenceCounter);
 result:=State;
end;

procedure TFLREParallelNFA.StateRelease(const State:PFLREParallelNFAState);
begin
 dec(State^.ReferenceCounter);
 if State^.ReferenceCounter=0 then begin
  State^.Next:=FreeStates;
  FreeStates:=State;
 end;
end;

function TFLREParallelNFA.StateUpdate(const State:PFLREParallelNFAState;const Index:TFLREInt32;const Position:TFLRESizeInt):PFLREParallelNFAState;
var Counter:TFLREInt32;
{$ifndef cpu386}
    SubMatchesBitmap:TFLREUInt32;
{$endif}    
begin
 result:=State;
 if result^.ReferenceCounter>1 then begin
  result:=StateAllocate(State^.Count,State^.SubMatchesBitmap);
{$ifdef cpu386}
  asm
   push ebx
   push esi
   push edi
    mov ebx,dword ptr result
    mov ecx,dword ptr [ebx+TFLREParallelNFAState.SubMatchesBitmap]
    test ecx,ecx // or test ecx,$80000000; jnz @CopyAll
    js @CopyAll
    jecxz @Done
     mov esi,dword ptr State
     mov esi,dword ptr [esi+TFLREParallelNFAState.SubMatches]
     mov edi,dword ptr [ebx+TFLREParallelNFAState.SubMatches]
     @CopySelectedLoop:
       bsf eax,ecx
       mov edx,dword ptr [esi+eax*4]
       mov dword ptr [edi+eax*4],edx
       lea edx,[ecx-1]
       and ecx,edx
      jnz @CopySelectedLoop
     jmp @Done
     @CopyAll:
      mov esi,dword ptr State
      mov ecx,dword ptr [esi+TFLREParallelNFAState.Count]
      mov esi,dword ptr [esi+TFLREParallelNFAState.SubMatches]
      mov edi,dword ptr [ebx+TFLREParallelNFAState.SubMatches]
      rep movsd
    @Done:
   pop edi
   pop esi
   pop ebx
  end;
{$else}
  if (result^.SubMatchesBitmap and TFLREUInt32($80000000))=0 then begin
   SubMatchesBitmap:=result^.SubMatchesBitmap;
   while SubMatchesBitmap<>0 do begin
    Counter:=PopFirstOneBit(SubMatchesBitmap);
    result^.SubMatches[Counter]:=State^.SubMatches[Counter];
   end;
  end else begin
   Move(State^.SubMatches[0],result^.SubMatches[0],State^.Count*SizeOf(TFLREParallelNFAStateItem));
  end;
{$endif}
  dec(State^.ReferenceCounter);
 end;
 if (result^.SubMatchesBitmap and TFLREUInt32($80000000))=0 then begin
  if Index>30 then begin
   for Counter:=0 to 30 do begin
    if (result^.SubMatchesBitmap and (TFLREUInt32(1) shl Counter))=0 then begin
     result^.SubMatches[Counter]:=0;
    end;
   end;
   result^.SubMatchesBitmap:=$ffffffff;
  end else begin
   result^.SubMatchesBitmap:=result^.SubMatchesBitmap or (TFLREUInt32(1) shl Index);
  end;
 end;
 result^.SubMatches[Index]:=Position;
end;

function TFLREParallelNFA.BackReferenceAssertion(const State:PFLREParallelNFAState;const CaptureSubMatch,BackReferenceSubMatch:TFLREInt32;const IgnoreCase:boolean):boolean;
var CaptureStart,CaptureEnd,BackReferenceStart,BackReferenceEnd:TFLRESizeInt;
begin
 result:=false;
 if (CaptureSubMatch>=0) and (BackReferenceSubMatch>=0) then begin
  if (State^.SubMatchesBitmap and $80000000)<>0 then begin
   CaptureStart:=State^.SubMatches[CaptureSubMatch];
   CaptureEnd:=State^.SubMatches[CaptureSubMatch+1];
   BackReferenceStart:=State^.SubMatches[BackReferenceSubMatch];
   BackReferenceEnd:=State^.SubMatches[BackReferenceSubMatch+1];
  end else begin
   if (State^.SubMatchesBitmap and (TFLREUInt32(1) shl CaptureSubMatch))<>0 then begin
    CaptureStart:=State^.SubMatches[CaptureSubMatch];
   end else begin
    exit;
   end;
   if (State^.SubMatchesBitmap and (TFLREUInt32(1) shl (CaptureSubMatch+1)))<>0 then begin
    CaptureEnd:=State^.SubMatches[CaptureSubMatch+1];
   end else begin
    exit;
   end;
   if (State^.SubMatchesBitmap and (TFLREUInt32(1) shl BackReferenceSubMatch))<>0 then begin
    BackReferenceStart:=State^.SubMatches[BackReferenceSubMatch];
   end else begin
    exit;
   end;
   if (State^.SubMatchesBitmap and (TFLREUInt32(1) shl (BackReferenceSubMatch+1)))<>0 then begin
    BackReferenceEnd:=State^.SubMatches[BackReferenceSubMatch+1];
   end else begin
    exit;
   end;
  end;
  result:=ThreadLocalStorageInstance.BackReferenceAssertion(CaptureStart,CaptureEnd,BackReferenceStart,BackReferenceEnd,IgnoreCase);
 end;
end;

procedure TFLREParallelNFA.AddThread(const ThreadList:PFLREParallelNFAThreadList;Instruction:PFLREInstruction;State:PFLREParallelNFAState;const Position:TFLRESizeInt);
var Thread:PFLREParallelNFAThread;
    StackItem:PFLREParallelNFAStackItem;
    StackSize,InstructionID:TFLREInt32;
begin
 StackSize:=0;
 StackItem:=@ParallelNFAStack[StackSize];
 StackItem^.Instruction:=Instruction;
 StackItem^.State:=State;
 inc(StackSize);
 while StackSize>0 do begin
  dec(StackSize);
  StackItem:=@ParallelNFAStack[StackSize];
  Instruction:=StackItem^.Instruction;
  State:=StackItem^.State;
  while assigned(Instruction) do begin
   InstructionID:=Instruction^.IDandOpcode shr 8;
   if InstructionGenerations[InstructionID]=Generation then begin
    StateRelease(State);
    break;
   end else begin
    InstructionGenerations[InstructionID]:=Generation;
    case Instruction^.IDandOpcode and $ff of
{$ifdef UseOpcodeJMP}
     opJMP:begin
      Instruction:=Instruction^.Next;
      continue;
     end;
{$endif}
     opSPLIT,opSPLITMATCH:begin
      StackItem:=@ParallelNFAStack[StackSize];
      StackItem^.Instruction:=Instruction^.OtherNext;
      StackItem^.State:=State;
      inc(StackSize);
      Instruction:=Instruction^.Next;
      State:=StateAcquire(State);
      continue;
     end;
     opSAVE:begin
      State:=StateUpdate(State,Instruction^.Value,Position);
      Instruction:=Instruction^.Next;
      continue;
     end;
     opZEROWIDTH:begin
      if CurrentSatisfyFlags=$ffffffff then begin
       CurrentSatisfyFlags:=ThreadLocalStorageInstance.GetSatisfyFlags(Position);
      end;
      if ((TFLREUInt32(Instruction^.Value) and sfEmptyAllFlags) and not CurrentSatisfyFlags)=0 then begin
       Instruction:=Instruction^.Next;
       continue;
      end else begin
       StateRelease(State);
       break;
      end;
     end;
     opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE:begin
      if ThreadLocalStorageInstance.LookAssertion(Position,
                                                  Instruction^.Value,
                                                  (Instruction^.IDandOpcode and $ff) in [opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE],
                                                  (Instruction^.IDandOpcode and $ff) in [opLOOKBEHINDNEGATIVE,opLOOKAHEADNEGATIVE]) then begin
       Instruction:=Instruction^.Next;
       continue;
      end else begin
       StateRelease(State);
       break;
      end;
     end;
     opBACKREFERENCE,opBACKREFERENCEIGNORECASE:begin
      if assigned(Instruction^.OtherNext) and BackReferenceAssertion(State,
                                                                     Instruction^.Value,
                                                                     Instruction^.OtherNext^.Value,
                                                                     (Instruction^.IDandOpcode and $ff)=opBACKREFERENCEIGNORECASE) then begin
       Instruction:=Instruction^.Next;
       continue;
      end else begin
       StateRelease(State);
       break;
      end;
     end;
     opNOP:begin
      Instruction:=Instruction^.Next;
      continue;
     end;
     else begin
      Thread:=@ThreadList^.Threads[ThreadList^.CountThreads];
      inc(ThreadList^.CountThreads);
      Thread^.Instruction:=Instruction;
      Thread^.State:=State;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function TFLREParallelNFA.SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt;const UnanchoredStart:boolean):boolean;
var LocalInputLength,CurrentPosition,Counter,ThreadIndex,CurrentLength,LastPosition,Index:TFLRESizeInt;
    CurrentThreadList,NewThreadList,TemporaryThreadList:PFLREParallelNFAThreadList;
    State,Matched,BestState:PFLREParallelNFAState;
    CurrentThread:PFLREParallelNFAThread;
    Instruction:PFLREInstruction;
    CurrentChar:TFLREInt32;
    Capture:PFLRECapture;
    SubMatchesBitmap:TFLREUInt32;
    LocalInput:PFLRERawByteChar;
begin
 result:=false;

 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalInputLength:=ThreadLocalStorageInstance.InputLength;

 CurrentThreadList:=@ParallelNFAThreadLists[0];
 NewThreadList:=@ParallelNFAThreadLists[1];

 CurrentThreadList^.CountThreads:=0;
 NewThreadList^.CountThreads:=0;

 State:=StateAllocate(Instance.CountSubMatches,0);

 CurrentSatisfyFlags:=$ffffffff;

 inc(Generation);
 if UnanchoredStart then begin
  AddThread(CurrentThreadList,Instance.UnanchoredStartInstruction,State,StartPosition);
 end else begin
  AddThread(CurrentThreadList,Instance.AnchoredStartInstruction,State,StartPosition);
 end;

 Matched:=nil;

 BestState:=nil;

 LastPosition:=-1;

 for CurrentPosition:=StartPosition to UntilExcludingPosition{-1} do begin // including one dummy step more, therefore no -1 here
  if CurrentThreadList^.CountThreads=0 then begin
   break;
  end;
  if CurrentPosition<LocalInputLength then begin
   CurrentChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[CurrentPosition]));
  end else begin
   CurrentChar:=-1;
  end;
  inc(Generation);
  CurrentSatisfyFlags:=$ffffffff;
  for ThreadIndex:=0 to CurrentThreadList^.CountThreads-1 do begin
   CurrentThread:=@CurrentThreadList^.Threads[ThreadIndex];
   Instruction:=CurrentThread^.Instruction;
   State:=CurrentThread^.State;
   if (MatchMode=mmLongestMatch) and
      assigned(BestState) and
      (((BestState^.SubMatchesBitmap and State^.SubMatchesBitmap) and 1)<>0) and
      (BestState^.SubMatches[0]<State^.SubMatches[0]) then begin
    // Skip any threads started after our current best match, when we are searching the longest match       
    StateRelease(State);
   end else begin
    case Instruction^.IDandOpcode and $ff of
     opNONE:begin
      StateRelease(State);
     end;
     opSINGLECHAR:begin
      if CurrentChar=Instruction^.Value then begin
       AddThread(NewThreadList,Instruction^.Next,State,CurrentPosition+1);
      end else begin
       StateRelease(State);
      end;
     end;
     opCHAR:begin
      if (CurrentChar>=0) and (TFLRERawByteChar(TFLREUInt8(CurrentChar)) in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^) then begin
       AddThread(NewThreadList,Instruction^.Next,State,CurrentPosition+1);
      end else begin
       StateRelease(State);
      end;
     end;
     opANY:begin
      if CurrentChar<0 then begin
       StateRelease(State);
      end else begin
       AddThread(NewThreadList,Instruction^.Next,State,CurrentPosition+1);
      end;
     end;
     opMATCH:begin
      if MatchMode in [mmLongestMatch,mmFullMatch,mmMultiMatch] then begin
       if (MatchMode=mmMultiMatch) and
          (((Instruction^.Value>=0) and (Instruction^.Value<Instance.CountMultiSubMatches)) and
           (ThreadLocalStorageInstance.MultiSubMatches[Instruction^.Value]<CurrentPosition)) then begin
        ThreadLocalStorageInstance.MultiSubMatches[Instruction^.Value]:=CurrentPosition;
        State^.SubMatchesBitmap:=State^.SubMatchesBitmap or 2;
        if State^.SubMatches[1]<CurrentPosition then begin
         State^.SubMatches[1]:=CurrentPosition;
        end;
       end;
       if not assigned(BestState) then begin
        BestState:=StateAllocate(Instance.CountSubMatches,State^.SubMatchesBitmap);
       end;
       if State^.SubMatchesBitmap<>0 then begin
        if LastPosition<CurrentPosition then begin
         LastPosition:=CurrentPosition;
         BestState^.SubMatchesBitmap:=State^.SubMatchesBitmap;
         Move(State^.SubMatches[0],BestState^.SubMatches[0],State^.Count*SizeOf(TFLREParallelNFAStateItem));
        end;
       end;
      end else begin
       if assigned(Matched) then begin
        StateRelease(Matched);
       end;
       Matched:=State;
       for Counter:=ThreadIndex+1 to CurrentThreadList^.CountThreads-1 do begin
        StateRelease(CurrentThreadList^.Threads[Counter].State);
       end;
       break;
      end;
     end;
    end;
   end;
  end;
  TemporaryThreadList:=CurrentThreadList;
  CurrentThreadList:=NewThreadList;
  NewThreadList:=TemporaryThreadList;
  NewThreadList^.CountThreads:=0;
 end;

 if assigned(BestState) then begin
  if assigned(Matched) then begin
   StateRelease(Matched);
  end;
  Matched:=BestState;
 end;

 if assigned(Matched) then begin
  SubMatchesBitmap:=Matched^.SubMatchesBitmap;
  for Counter:=0 to Instance.CountCaptures-1 do begin
   Capture:=@Captures[Counter];
   Index:=Instance.CapturesToSubMatchesMap[Counter] shl 1;
   if (SubMatchesBitmap and TFLREUInt32($80000000))<>0 then begin
    CurrentPosition:=Matched^.SubMatches[Index];
    CurrentLength:=Matched^.SubMatches[Index or 1]-CurrentPosition;
   end else begin
    if (SubMatchesBitmap and (TFLREUInt32(1) shl Index))<>0 then begin
     CurrentPosition:=Matched^.SubMatches[Index];
    end else begin
     CurrentPosition:=0;
    end;
    if (SubMatchesBitmap and (TFLREUInt32(1) shl (Index or 1)))<>0 then begin
     CurrentLength:=Matched^.SubMatches[Index or 1]-CurrentPosition;
    end else begin
     CurrentLength:=0;
    end;
   end;
   Capture^.Start:=CurrentPosition;
   if CurrentLength<1 then begin
    Capture^.Length:=0;
   end else begin
    Capture^.Length:=CurrentLength;
   end;
  end;
  StateRelease(Matched);
  result:=true;
 end;

 if Generation>MaxGeneration then begin
  Generation:=0;
  for Index:=0 to length(InstructionGenerations)-1 do begin
   InstructionGenerations[Index]:=-1;
  end;
 end;

end;

constructor TFLREOnePassNFA.Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
begin
 inherited Create;

 ThreadLocalStorageInstance:=AThreadLocalStorageInstance;

 Instance:=ThreadLocalStorageInstance.Instance;

 MatchMode:=ThreadLocalStorageInstance.MatchMode;

 WorkSubMatches:=nil;
 MatchSubMatches:=nil;

 SetLength(WorkSubMatches,Instance.CountSubMatches);
 SetLength(MatchSubMatches,Instance.CountSubMatches);

end;

destructor TFLREOnePassNFA.Destroy;
begin
 SetLength(WorkSubMatches,0);
 SetLength(MatchSubMatches,0);
 inherited Destroy;
end;

function TFLREOnePassNFA.SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt):boolean;
var State,Nodes:PFLREOnePassNFAState;
    CurrentPosition:TFLRESizeInt;
    StateSize,CountSubMatches,Counter,Index:TFLREInt32;
    LocalByteMap:PFLREByteMap;
    Done:boolean;
    NextMatchCondition,MatchCondition,Condition,NextIndex:TFLREUInt32;
    LocalInput:PFLRERawByteChar;
begin

 CountSubMatches:=Instance.CountSubMatches;

 for Counter:=0 to CountSubMatches-1 do begin
  WorkSubMatches[Counter]:=0;
 end;

 for Counter:=0 to CountSubMatches-1 do begin
  MatchSubMatches[Counter]:=0;
 end;

 LocalInput:=ThreadLocalStorageInstance.Input;

 State:=Instance.OnePassNFAStart;
 Nodes:=Instance.OnePassNFANodes;
 StateSize:=Instance.OnePassNFAStateSize;
 LocalByteMap:=@Instance.ByteMap;

 result:=false;
 Done:=false;

 NextMatchCondition:=State^.MatchCondition;
//Condition:=0;
 CurrentPosition:=StartPosition;

 while CurrentPosition<UntilExcludingPosition do begin

  Condition:=State^.Action[LocalByteMap^[TFLREUInt8(TFLRERawByteChar(LocalInput[CurrentPosition]))]];
  MatchCondition:=NextMatchCondition;

  if ((Condition and sfEmptyAllFlags)=0) or
     (((Condition and sfEmptyAllFlags) and not ThreadLocalStorageInstance.GetSatisfyFlags(CurrentPosition))=0) then begin
   NextIndex:=Condition shr sfIndexShift;
   State:=pointer(@PFLRERawByteChar(Nodes)[StateSize*TFLREInt32(NextIndex)]);
   NextMatchCondition:=State^.MatchCondition;
  end else begin
   State:=nil;
   NextMatchCondition:=sfImpossible;
  end;

  if (MatchCondition<>sfImpossible) and
     (((Condition and sfMatchWins)<>0) or ((NextMatchCondition and sfEmptyAllFlags)<>0)) and
     (((MatchCondition and sfEmptyAllFlags)=0) or
      (((MatchCondition and sfEmptyAllFlags) and not ThreadLocalStorageInstance.GetSatisfyFlags(CurrentPosition))=0)) then begin
   for Counter:=0 to CountSubMatches-1 do begin
    MatchSubMatches[Counter]:=WorkSubMatches[Counter];
   end;
   if (MatchCondition and sfCapMask)<>0 then begin
    for Counter:=0 to CountSubMatches-1 do begin
     if (MatchCondition and ((1 shl sfCapShift) shl Counter))<>0 then begin
      MatchSubMatches[Counter]:=CurrentPosition;
     end;
    end;
   end;
   result:=true;
   if ((Condition and sfMatchWins)<>0) and not (MatchMode in [mmLongestMatch,mmFullMatch,mmMultiMatch]) then begin
    Done:=true;
    break;
   end;
  end;

  if not assigned(State) then begin
   Done:=true;
   break;
  end;

  if (Condition and sfCapMask)<>0 then begin
   for Counter:=0 to CountSubMatches-1 do begin
    if (Condition and ((1 shl sfCapShift) shl Counter))<>0 then begin
     WorkSubMatches[Counter]:=CurrentPosition;
    end;
   end;
  end;

  inc(CurrentPosition);
 end;

 if assigned(State) and not Done then begin
  MatchCondition:=State^.MatchCondition;
  if (MatchCondition<>sfImpossible) and
     (((MatchCondition and sfEmptyAllFlags)=0) or
      (((MatchCondition and sfEmptyAllFlags) and not ThreadLocalStorageInstance.GetSatisfyFlags(CurrentPosition))=0)) then begin
   if ((MatchCondition and sfCapMask)<>0) and (CountSubMatches>0) then begin
    for Counter:=0 to CountSubMatches-1 do begin
     if (MatchCondition and ((1 shl sfCapShift) shl Counter))<>0 then begin   
      WorkSubMatches[Counter]:=CurrentPosition;
     end;
    end;
   end;
   for Counter:=0 to CountSubMatches-1 do begin
    MatchSubMatches[Counter]:=WorkSubMatches[Counter];
   end;
   result:=true;
  end;
 end;

 if result then begin
  for Counter:=0 to Instance.CountCaptures-1 do begin
   Index:=Instance.CapturesToSubMatchesMap[Counter] shl 1;
   Captures[Counter].Start:=MatchSubMatches[Index];
   Captures[Counter].Length:=MatchSubMatches[Index or 1]-MatchSubMatches[Index];
  end;
 end;

end;

constructor TFLREBitStateNFA.Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
begin
 inherited Create;

 ThreadLocalStorageInstance:=AThreadLocalStorageInstance;

 Instance:=ThreadLocalStorageInstance.Instance;

 MatchMode:=ThreadLocalStorageInstance.MatchMode;

 CountVisited:=0;
 Jobs:=nil;
 CountJobs:=0;
 MaxJob:=0;

 WorkSubMatches:=nil;
 MatchSubMatches:=nil;

 SetLength(WorkSubMatches,Instance.CountSubMatches);
 SetLength(MatchSubMatches,Instance.CountSubMatches);

end;

destructor TFLREBitStateNFA.Destroy;
begin
 SetLength(Jobs,0);
 SetLength(WorkSubMatches,0);
 SetLength(MatchSubMatches,0);
 inherited Destroy;
end;

function TFLREBitStateNFA.SearchMatch(var Captures:TFLRECaptures;const StartPosition,UntilExcludingPosition:TFLRESizeInt;const UnanchoredStart:boolean):TFLREInt32;
var LocalInputLength,BasePosition,Len:TFLRESizeInt;
    LocalInput:PFLRERawByteChar;
 function ShouldVisit(const Instruction:PFLREInstruction;const Position:TFLRESizeInt):boolean; {$ifdef fpc}{$ifdef caninline}inline;{$endif}{$endif}
 var Index:TFLRESizeUInt;
     Mask:TFLREUInt32;
 begin
  Index:=(TFLREPtrUInt(Instruction^.IDandOpcode shr 8)*TFLRESizeUInt(TFLRESizeUInt(Len)+1))+TFLRESizeUInt(TFLRESizeInt(Position-BasePosition));
  Mask:=TFLREUInt32(1) shl TFLREUInt32(TFLRESizeUInt(Index and 31));
  Index:=Index shr 5;
  result:=(Index<length(Visited)) and ((Visited[Index] and Mask)=0);
  if result then begin
   Visited[Index]:=Visited[Index] or Mask;
  end;
 end;
 procedure Push(const Instruction:PFLREInstruction;const Position:TFLRESizeInt;const Argument:TFLREInt32);
 var Job:PFLREBitStateNFAJob;
 begin
  if assigned(Instruction) and not ((Argument=0) and not ShouldVisit(Instruction,Position)) then begin
   if CountJobs>=length(Jobs) then begin
    SetLength(Jobs,(CountJobs+1)*2);
   end;
   Job:=@Jobs[CountJobs];
   inc(CountJobs);
   Job^.Instruction:=Instruction;
   Job^.Position:=Position;
   Job^.Argument:=Argument;
  end;
 end;
 function TrySearch(StartInstruction:PFLREInstruction;var Position:TFLRESizeInt):boolean;
 var Job:PFLREBitStateNFAJob;
     Instruction:PFLREInstruction;
     Argument,Index:TFLREInt32;
     LastPosition:TFLRESizeInt;
 begin
  result:=false;

  LastPosition:=-1;

  CountJobs:=0;
  Push(StartInstruction,Position,0);

  while CountJobs>0 do begin
   dec(CountJobs);
   Job:=@Jobs[CountJobs];

   Instruction:=Job^.Instruction;
   Position:=Job^.Position;
   Argument:=Job^.Argument;

   repeat

    case Instruction^.IDandOpcode and $ff of
     opSPLIT,opSPLITMATCH:begin
      case Argument of
       0:begin
        Push(Instruction,Position,1);
        Instruction:=Instruction^.Next;
        if ShouldVisit(Instruction,Position) then begin
         continue;
        end;
       end;
       1:begin
        Argument:=0;
        Instruction:=Instruction^.OtherNext;
        if ShouldVisit(Instruction,Position) then begin
         continue;
        end;
       end;
      end;
     end;
{    opSPLITMATCH:begin
      if IsInstructionGreedy(Instruction) then begin
       // Greedy (TFLREUInt8, match)
       Push(Instruction^.OtherNext,Position,0);
       Instruction:=Instruction^.OtherNext;
       Position:=UntilExcludingPosition-1;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end else begin
       // Non-greedy (Match, TFLREUInt8)
       Push(Instruction^.Next,UntilExcludingPosition-1,0);
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;{}
     opNONE:begin
      // Match against nothing
     end;
     opSINGLECHAR:begin
      if (Position<LocalInputLength) and (TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))=Instruction^.Value) then begin
       inc(Position);
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opCHAR:begin
      if (Position<LocalInputLength) and (LocalInput[Position] in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^) then begin
       inc(Position);
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opANY:begin
      if Position<LocalInputLength then begin
       inc(Position);
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opMATCH:begin
      result:=true;
      if MatchMode in [mmLongestMatch,mmFullMatch,mmMultiMatch] then begin
       if (MatchMode=mmMultiMatch) and
          (((Instruction^.Value>=0) and (Instruction^.Value<Instance.CountMultiSubMatches)) and
           (ThreadLocalStorageInstance.MultiSubMatches[Instruction^.Value]<Position)) then begin
        ThreadLocalStorageInstance.MultiSubMatches[Instruction^.Value]:=Position;
        if WorkSubMatches[1]<Position then begin
         WorkSubMatches[1]:=Position;
        end;
       end;
       if LastPosition<Position then begin
        LastPosition:=Position;
        for Index:=0 to Instance.CountSubMatches-1 do begin
         MatchSubMatches[Index]:=WorkSubMatches[Index];
        end;
       end;
      end else begin
       for Index:=0 to Instance.CountSubMatches-1 do begin
        MatchSubMatches[Index]:=WorkSubMatches[Index];
       end;
       exit;
      end;
     end;
{$ifdef UseOpcodeJMP}
     opJMP:begin
      Instruction:=Instruction^.Next;
      if ShouldVisit(Instruction,Position) then begin
       continue;
      end;
     end;
{$endif}
     opSAVE:begin
      case Argument of
       0:begin
        Push(Instruction,WorkSubMatches[Instruction^.Value],1);
        WorkSubMatches[Instruction^.Value]:=Position;
        Instruction:=Instruction^.Next;
        if ShouldVisit(Instruction,Position) then begin
         continue;
        end;
       end;
       1:begin
        WorkSubMatches[Instruction^.Value]:=Position;
       end;
      end;
     end;
     opZEROWIDTH:begin
      if ((TFLREUInt32(Instruction^.Value) and sfEmptyAllFlags) and not ThreadLocalStorageInstance.GetSatisfyFlags(Position))=0 then begin
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE:begin
      if ThreadLocalStorageInstance.LookAssertion(Position,
                                                  Instruction^.Value,
                                                  (Instruction^.IDandOpcode and $ff) in [opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE],
                                                  (Instruction^.IDandOpcode and $ff) in [opLOOKBEHINDNEGATIVE,opLOOKAHEADNEGATIVE]) then begin
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opBACKREFERENCE,opBACKREFERENCEIGNORECASE:begin
      if assigned(Instruction^.OtherNext) and
         ThreadLocalStorageInstance.BackReferenceAssertion(WorkSubMatches[Instruction^.Value],
                                                           WorkSubMatches[Instruction^.Value or 1],
                                                           WorkSubMatches[Instruction^.OtherNext^.Value],
                                                           WorkSubMatches[Instruction^.OtherNext^.Value or 1],
                                                           (Instruction^.IDandOpcode and $ff)=opBACKREFERENCEIGNORECASE) then begin
       Instruction:=Instruction^.Next;
       if ShouldVisit(Instruction,Position) then begin
        continue;
       end;
      end;
     end;
     opNOP:begin
      Instruction:=Instruction^.Next;
      if ShouldVisit(Instruction,Position) then begin
       continue;
      end;
     end;
    end;

    break;
   until false;

  end;

 end;
var VisitedLength:TFLRESizeUInt;
    Position:TFLRESizeInt;
    Counter,Index:TFLREInt32;
    StartInstruction:PFLREInstruction;
begin
 result:=BitStateNFAError;

 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalInputLength:=ThreadLocalStorageInstance.InputLength;

 Len:=UntilExcludingPosition-StartPosition;
 if Len<1 then begin
  exit;
 end else if Len>=Instance.MaxBitStateNFATextSize then begin
  // Too big for 32kb visited bitmap
  exit;
 end;

 BasePosition:=StartPosition;
 Position:=StartPosition;

 VisitedLength:=TFLRESizeUInt(TFLREUInt64((TFLREUInt64(Len+1)*TFLREUInt32(Instance.CountForwardInstructions))+31) shr 5);
 if TFLRESizeUInt(VisitedLength)>TFLRESizeUInt(SizeOf(TFLREBitStateNFAVisited) div SizeOf(TFLREUInt32)) then begin
  // Too big for 32kb visited bitmap
  exit;
 end;
 FillChar(Visited[0],VisitedLength*SizeOf(TFLREUInt32),#0);

 if UnanchoredStart then begin
  StartInstruction:=Instance.UnanchoredStartInstruction;
 end else begin
  StartInstruction:=Instance.AnchoredStartInstruction;
 end;

 for Counter:=0 to Instance.CountSubMatches-1 do begin
  WorkSubMatches[Counter]:=0;
 end;

 for Counter:=0 to Instance.CountSubMatches-1 do begin
  MatchSubMatches[Counter]:=0;
 end;

 if TrySearch(StartInstruction,Position) then begin
  for Counter:=0 to Instance.CountCaptures-1 do begin
   Index:=Instance.CapturesToSubMatchesMap[Counter] shl 1;
   Captures[Counter].Start:=MatchSubMatches[Index];
   Captures[Counter].Length:=MatchSubMatches[Index or 1]-MatchSubMatches[Index];
  end;
  result:=BitStateNFAMatch;
 end else begin
  result:=BitStateNFAFail;
 end;

end;

constructor TFLREDFA.Create(const AThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;const AReversed:boolean;const AMaximalDFAStates:TFLREInt32);
var Index:TFLREInt32;
    FLREDFAStateCreateTempDFAState:TFLREDFAState;
    DFAState:PFLREDFAState;
begin
 inherited Create;

 ThreadLocalStorageInstance:=AThreadLocalStorageInstance;

 Instance:=ThreadLocalStorageInstance.Instance;

 MaximalDFAStates:=AMaximalDFAStates;

 HadReset:=false;

 if AReversed then begin

  CountInstructions:=Instance.CountBackwardInstructions;

  MatchMode:=mmLongestMatch;

 end else begin

  CountInstructions:=Instance.CountForwardInstructions;

  MatchMode:=ThreadLocalStorageInstance.MatchMode;

 end;

 NeedMark:=MatchMode=mmLongestMatch;

 Reversed:=AReversed;

 IsUnanchored:=false;

 DoFastDFA:=(fifDFAFast in Instance.InternalFlags) and not (MatchMode in [mmLongestMatch,mmFullMatch,mmMultiMatch]);

 StackInstructions:=nil;
 StateCache:=TFLREDFAStateHashMap.Create;
 NextStatesSize:=0;
 StateSize:=0;
 StatePoolUsed:=nil;
 StatePoolFree:=nil;
 StatePoolSize:=0;
 StatePoolSizePowerOfTwo:=0;
 FillChar(DefaultStates,SizeOf(DefaultStates),#0);
 FillChar(StartStates,SizeOf(StartStates),#0);

 for Index:=0 to 255 do begin
  ByteMap[Index]:=Instance.ByteMap[Index];
 end;
 ByteMap[256]:=Instance.ByteMapCount;

 begin
  CountStatesCached:=0;

  StackInstructions:=nil;
  SetLength(StackInstructions,Max(Instance.CountForwardInstructions,Instance.CountBackwardInstructions) shl 1);

  StatePoolUsed:=nil;
  StatePoolFree:=nil;

  NextStatesSize:=(Instance.ByteMapCount+1)*sizeof(PFLREDFAState);
  StateSize:=TFLREPtrInt(TFLREPtrUInt(pointer(@FLREDFAStateCreateTempDFAState.NextStates))-TFLREPtrUInt(pointer(@FLREDFAStateCreateTempDFAState)))+NextStatesSize;

  StatePoolSize:=(65536 div StateSize)*StateSize;
  if StatePoolSize=0 then begin
   StatePoolSize:=StateSize*64;
  end;

  StatePoolSizePowerOfTwo:=RoundUpToPowerOfTwo(StatePoolSize);

  AllocateNewStatePool;

  FillChar(TemporaryState,SizeOf(TFLREDFAState),#0);
  FillChar(NewState,SizeOf(TFLREDFAState),#0);

  InstructionGenerations:=nil;

  if DoFastDFA then begin
   SetLength(InstructionGenerations,CountInstructions);
   for Index:=0 to length(InstructionGenerations)-1 do begin
    InstructionGenerations[Index]:=-1;
   end;
  end;

  inc(Generation);
  GetMem(DFAState,StateSize);
  FillChar(DFAState^,StateSize,#0);
  DFAState^.Flags:=sfDFADead;
  StateCache.Add(DFAState);
  inc(CountStatesCached);
  DefaultStates[dskDead]:=DFAState;

  inc(Generation);
  GetMem(DFAState,StateSize);
  FillChar(DFAState^,StateSize,#0);
  DFAState^.Flags:=sfDFAFullMatch;
  StateCache.Add(DFAState);
  inc(CountStatesCached);
  DefaultStates[dskFullMatch]:=DFAState;

  if DoFastDFA then begin

   inc(Generation);
   GetMem(DFAState,StateSize);
   FillChar(DFAState^,StateSize,#0);
   FastAddInstructionThread(DFAState,Instance.AnchoredStartInstruction);
   StateCache.Add(DFAState);
   inc(CountStatesCached);
   DefaultStates[dskFastAnchored]:=DFAState;

   inc(Generation);
   GetMem(DFAState,StateSize);
   FillChar(DFAState^,StateSize,#0);
   FastAddInstructionThread(DFAState,Instance.UnanchoredStartInstruction);
   if fifDFAFastBeginningSearch in Instance.InternalFlags then begin
    DFAState.Flags:=DFAState.Flags or sfDFAStart;
   end;
   StateCache.Add(DFAState);
   inc(CountStatesCached);
   DefaultStates[dskFastUnanchored]:=DFAState;

   inc(Generation);
   GetMem(DFAState,StateSize);
   FillChar(DFAState^,StateSize,#0);
   FastAddInstructionThread(DFAState,Instance.ReversedStartInstruction);
   StateCache.Add(DFAState);
   inc(CountStatesCached);
   DefaultStates[dskFastReversed]:=DFAState;

  end;

 end;

 QueueInstructionArray:=nil;
 QueueStack:=nil;

 if DoFastDFA then begin
  WorkQueues[0]:=nil;
  WorkQueues[1]:=nil;
  if Reversed then begin
   SearchMatch:=SearchMatchFastReversed;
  end else begin
   SearchMatch:=SearchMatchFast;
  end;
 end else begin
  if NeedMark then begin
   WorkQueues[0]:=TFLREDFAWorkQueue.Create(CountInstructions*3);
   WorkQueues[1]:=TFLREDFAWorkQueue.Create(CountInstructions*3);
   SetLength(QueueInstructionArray,CountInstructions*3);
   SetLength(QueueStack,CountInstructions*3);
  end else begin
   WorkQueues[0]:=TFLREDFAWorkQueue.Create(CountInstructions*2);
   WorkQueues[1]:=TFLREDFAWorkQueue.Create(CountInstructions*2);
   SetLength(QueueInstructionArray,CountInstructions*2);
   SetLength(QueueStack,CountInstructions*2);
  end;
  if Reversed then begin
   SearchMatch:=SearchMatchFullReversed;
  end else begin
   SearchMatch:=SearchMatchFull;
  end;
 end;

end;

destructor TFLREDFA.Destroy;
var Index:TFLREInt32;
begin
 SetLength(QueueInstructionArray,0);
 SetLength(QueueStack,0);
 DestroyStatePool(StatePoolUsed);
 DestroyStatePool(StatePoolFree);
 StatePoolUsed:=nil;
 StatePoolFree:=nil;
 FreeState(@TemporaryState);
 FreeState(@NewState);
 for Index:=0 to length(DefaultStates)-1 do begin
  if assigned(DefaultStates[Index]) then begin
   FreeState(DefaultStates[Index]);
   FreeMem(DefaultStates[Index]);
  end;
 end;
 FreeAndNil(StateCache);
 SetLength(StackInstructions,0);
 SetLength(InstructionGenerations,0);
 WorkQueues[0].Free;
 WorkQueues[1].Free;
 inherited Destroy;
end;

function TFLREDFA.CacheState(const State:PFLREDFAState):PFLREDFAState;
begin

 // Is it already cached?
 result:=StateCache[State];
 if not assigned(result) then begin
  // No, it is not already cached yet

  // Do we need reset the states?
  if CountStatesCached>=MaximalDFAStates then begin
   // Yes, so do it
   Reset;
  end;

  // Move state in an own new memory instance
  result:=TakeOverState(State);

  // Add state to state cache hash map
  StateCache.Add(result);
  inc(CountStatesCached);

 end;

end;

procedure TFLREDFA.DestroyStatePool(var StatePool:PFLREDFAStatePool);
var Pool,NextPool:PFLREDFAStatePool;
    State:PFLREDFAState;
begin
 Pool:=StatePool;
 StatePool:=nil;
 while assigned(Pool) do begin
  NextPool:=Pool^.Next;
  State:=Pool^.States;
  while assigned(State) and (State<>Pool^.EndState) do begin
   FreeState(State);
   inc(TFLREPtrUInt(State),StateSize);
  end;
  FreeMem(Pool^.States);
  FreeMem(Pool);
  Pool:=NextPool;
 end;
end;

procedure TFLREDFA.FreeUsedStatePool;
var Pool,NextPool:PFLREDFAStatePool;
    State:PFLREDFAState;
begin
 Pool:=StatePoolUsed;
 StatePoolUsed:=nil;
 while assigned(Pool) do begin
  NextPool:=Pool^.Next;
  State:=Pool^.States;
  while assigned(State) and (State<>Pool^.EndState) do begin
   FreeState(State);
   inc(TFLREPtrUInt(State),StateSize);
  end;
  FillChar(Pool^.States^,StatePoolSize,#0);
  Pool^.Next:=StatePoolFree;
  StatePoolFree:=Pool;
  Pool:=NextPool;
 end;
end;

function TFLREDFA.AllocateNewStatePool:PFLREDFAStatePool;
begin
 if assigned(StatePoolFree) then begin
  result:=StatePoolFree;
  StatePoolFree:=result^.Next;
 end else begin
  GetMem(result,SizeOf(TFLREDFAStatePool));
  FillChar(result^,SizeOf(TFLREDFAStatePool),#0);
  GetMem(result^.States,StatePoolSizePowerOfTwo);
  FillChar(result^.States^,StatePoolSize,#0);
  result^.EndState:=pointer(TFLREPtrUInt(TFLREPtrUInt(result^.States)+TFLREPtrUInt(StatePoolSize)));
 end;
 result^.Next:=StatePoolUsed;
 StatePoolUsed:=result;
 result^.NextState:=result^.States;
end;

function TFLREDFA.GetState:PFLREDFAState;
begin
 if StatePoolUsed^.NextState=StatePoolUsed^.EndState then begin
  AllocateNewStatePool;
 end;
 result:=StatePoolUsed^.NextState;
 inc(TFLREPtrUInt(StatePoolUsed^.NextState),StateSize);
end;

function TFLREDFA.TakeOverState(TakeOverFrom:PFLREDFAState):PFLREDFAState;
begin
 result:=GetState;
 result^.Instructions:=TakeOverFrom^.Instructions;
 result^.CountInstructions:=TakeOverFrom^.CountInstructions;
 result^.Flags:=TakeOverFrom^.Flags;
 TakeOverFrom^.Instructions:=nil;
 TakeOverFrom^.CountInstructions:=0;
 TakeOverFrom^.Flags:=0;
end;

procedure TFLREDFA.FreeState(State:PFLREDFAState);
begin
 if assigned(State) then begin
  SetLength(State^.Instructions,0);
  if assigned(StatePoolUsed) and
     ((TFLREPtrUInt(TFLREPtrUInt(State)-TFLREPtrUInt(StatePoolUsed^.States))<StatePoolSize) and
      (pointer(TFLREPtrUInt(TFLREPtrUInt(StatePoolUsed^.NextState)-TFLREPtrUInt(StateSize)))=State)) then begin
   FillChar(State^,StateSize,#0);
   dec(TFLREPtrUInt(StatePoolUsed^.NextState),StateSize);
  end;
 end;
end;

procedure TFLREDFA.Reset;
var Index:TFLREInt32;
    State:PFLREDFAState;
begin

 // Reset state pools
 FreeUsedStatePool;
 AllocateNewStatePool;

 // Reset state cache
 StateCache.Clear;
 CountStatesCached:=0;

 // Reset and recaching start states
 for Index:=0 to length(DefaultStates)-1 do begin
  State:=DefaultStates[Index];
  if assigned(State) then begin
   FillChar(State^.NextStates,NextStatesSize,#0);
   StateCache.Add(State);
   inc(CountStatesCached);
  end;
 end;

 FillChar(StartStates,SizeOf(StartStates),#0);

 HadReset:=true;

end;

procedure TFLREDFA.FastAddInstructionThread(const State:PFLREDFAState;Instruction:PFLREInstruction); {$ifdef cpu386}register;{$endif}
var StackPointer:TFLREInt32;
    Stack:PPFLREInstructionsStatic;
begin
 Stack:=@StackInstructions[0];
 StackPointer:=0;
 Stack^[StackPointer]:=Instruction;
 inc(StackPointer);
 while StackPointer>0 do begin
  dec(StackPointer);
  Instruction:=Stack[StackPointer];
  while assigned(Instruction) and (InstructionGenerations[Instruction^.IDandOpcode shr 8]<>Generation) do begin
   InstructionGenerations[Instruction^.IDandOpcode shr 8]:=Generation;
   case Instruction^.IDandOpcode and $ff of
{$ifdef UseOpcodeJMP}
    opJMP,
{$endif}
    opSAVE,
    opZEROWIDTH,
    opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,
    opBACKREFERENCE,opBACKREFERENCEIGNORECASE,
    opNOP:begin
     // No-ops at DFA
     Instruction:=Instruction^.Next;
    end;
    opSPLIT,opSPLITMATCH:begin
     Stack^[StackPointer]:=Instruction^.OtherNext;
     inc(StackPointer);
     Instruction:=Instruction^.Next;
    end;
    else begin
     if State.CountInstructions>=length(State.Instructions) then begin
      SetLength(State.Instructions,(State.CountInstructions+1)*2);
     end;
     State.Instructions[State.CountInstructions]:=Instruction;
     inc(State.CountInstructions);
     case Instruction^.IDandOpcode and $ff of
      opMATCH:begin
       State.Flags:=State.Flags or sfDFAMatchWins;
      end;
     end;
     break;
    end;
   end;
  end;
 end;
end;

function TFLREDFA.FastProcessNextState(State:PFLREDFAState;const CurrentChar:TFLRERawByteChar):PFLREDFAState; {$ifdef cpu386}register;{$endif}
var Counter:TFLREInt32;        
    Instruction:PFLREInstruction;
begin

 // Reset generation ID on overflow
 if Generation>MaxGeneration then begin
  Generation:=0;
  for Counter:=0 to length(InstructionGenerations)-1 do begin
   InstructionGenerations[Counter]:=-1;
  end;
 end;

 // Process state instructions
 inc(Generation);
 NewState.CountInstructions:=0;
 NewState.Flags:=0;
 for Counter:=0 To State^.CountInstructions-1 do begin
  Instruction:=State^.Instructions[Counter];
  case Instruction^.IDandOpcode and $ff of
   opNONE:begin
    // Match against nothing
   end;
   opSINGLECHAR:begin
    if TFLREUInt8(TFLRERawByteChar(CurrentChar))=Instruction^.Value then begin
     FastAddInstructionThread(@NewState,Instruction^.Next);
    end;
   end;
   opCHAR:begin
    if CurrentChar in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^ then begin
     FastAddInstructionThread(@NewState,Instruction^.Next);
    end;
   end;
   opANY:begin
    FastAddInstructionThread(@NewState,Instruction^.Next);
   end;
   opMATCH:begin
    if not (MatchMode in [mmLongestMatch,mmFullMatch,mmMultiMatch]) then begin
     // We can stop processing the instruction list queue here since we found a match (for the PCRE leftmost first valid match behaviour)
     break;
    end;
   end;
   else begin
    // Oops?! Invalid TFLREUInt8 code instruction for the DFA processing context! So abort and fallback to NFA...
    result:=nil;
    exit;
   end;
  end;
 end;

 HadReset:=false;

 // Dead state? If yes, ...
 if NewState.CountInstructions=0 then begin
  // ... drop it and take the dead state as the next state
  result:=DefaultStates[dskDead];
 end else begin
  // .. otherwise try caching it
  result:=CacheState(@NewState);
 end;

 if not HadReset then begin
  // Connect the last state to the new state with the current char
  State.NextStates[Instance.ByteMap[TFLREUInt8(TFLRERawByteChar(CurrentChar))]]:=result;
 end;

end;

function TFLREDFA.SearchMatchFast(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}assembler; stdcall;
var ResultValue:TFLREInt32;
    StartOffset:pointer;
asm
 push ebx
 push esi
 push edi

  mov dword ptr ResultValue,DFAFail

  mov edx,self

  mov edi,dword ptr [edx+TFLREDFA.ThreadLocalStorageInstance]

  mov esi,dword ptr [edi+TFLREThreadLocalStorageInstance.Input]
  inc esi
  mov dword ptr StartOffset,esi
  dec esi
  add esi,dword ptr StartPosition

  mov ecx,dword ptr UntilExcludingPosition
  sub ecx,dword ptr StartPosition
  jz @Done
  js @Done

  cmp dword ptr UnanchoredStart,0
  je @AnchoredStart
  @UnanchoredStart:
   mov edi,dword ptr [edx+TFLREDFA.DefaultStates+dskFastUnanchored*4]
   jmp @AnchoredStartSkip
  @AnchoredStart:
   mov edi,dword ptr [edx+TFLREDFA.DefaultStates+dskFastAnchored*4]
  @AnchoredStartSkip:

  test edi,edi
  jz @Error

  mov edx,[edx+TFLREDFA.Instance]
  lea edx,[edx+TFLRE.ByteMap]

  @Loop:

    movzx eax,TFLREUInt8 ptr [esi]
    inc esi

    movzx ebx,TFLREUInt8 ptr [edx+eax]
    mov ebx,dword ptr [edi+TFLREDFAState.NextStates+ebx*4]
    xchg edi,ebx
    test edi,edi
    jz @HaveNoNextState
    @HaveNextState:

    mov ebx,dword ptr [edi+TFLREDFAState.Flags]
    test ebx,sfDFAMatchWins or sfDFADead or sfDFAStart
    jnz @CheckFlags

   @BackToLoop:
   dec ecx
   jnz @Loop
   jmp @Done

   @CheckFlags:
    test ebx,sfDFADead
    jz @IsNotDFADead
     cmp dword ptr ResultValue,DFAMatch
     jz @Done
      mov dword ptr ResultValue,DFAFail
      jmp @Done
    @IsNotDFADead:
    test ebx,sfDFAMatchWins
    jz @IsNotMatchWin
     push ebx
     mov eax,esi
     sub eax,dword ptr StartOffset
     mov ebx,dword ptr MatchEnd
     mov dword ptr [ebx],eax
     mov dword ptr ResultValue,DFAMatch
     pop ebx
    @IsNotMatchWin:
    test ebx,sfDFAStart
    jz @IsNotStartState
     cmp ecx,2
     jb @IsStartStateSkip
      movzx eax,TFLREUInt8 ptr [esi]
      movzx eax,TFLREUInt8 ptr [edx+eax]
      mov eax,dword ptr [edi+TFLREDFAState.NextStates+eax*4]
      test eax,eax
      jz @IsStartStateSkip
      test dword ptr [eax+TFLREDFAState.Flags],sfDFAStart
      jz @IsStartStateSkip
       push ecx
       push edx
        dec ecx // because "dec ecx" comes after @BackToLoop first, but "inc esi" already directly after fetching the char TFLREUInt8
        mov edx,esi
        mov eax,self
        mov eax,dword ptr [eax+TFLREDFA.Instance]
        call TFLRE.SearchNextPossibleStartForDFA
       pop edx
       pop ecx
       test eax,eax
       js @Done
        add esi,eax
        sub ecx,eax
        inc ecx // because "dec ecx" after @BackToLoop
     @IsStartStateSkip:
    @IsNotStartState:
    jmp @BackToLoop

   @HaveNoNextState:
    push ecx
    push edx
     mov ecx,eax // Char
     mov eax,self
     mov edx,ebx // State
     call FastProcessNextState
    pop edx
    pop ecx
    mov edi,eax
    test edi,edi
    jnz @HaveNextState

    @Error:
    mov dword ptr ResultValue,DFAError

  @Done:

  mov eax,dword ptr ResultValue

 pop edi
 pop esi
 pop ebx
end;
{$else}
var Position,Offset:TFLRESizeInt;
    State,LastState,TemporaryTestState:PFLREDFAState;
    LocalInput:PFLRERawByteChar;
    LocalByteMap:PFLREByteMap;
begin
 result:=DFAFail;
 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalByteMap:=@Instance.ByteMap;
 if UnanchoredStart then begin
  State:=DefaultStates[dskFastUnanchored];
 end else begin
  State:=DefaultStates[dskFastAnchored];
 end;
 if not assigned(State) then begin
  result:=DFAError;
  exit;
 end;
 Position:=StartPosition;
 while Position<UntilExcludingPosition do begin
  LastState:=State;
  State:=State^.NextStates[LocalByteMap[TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))]];
  inc(Position);
  if not assigned(State) then begin
   State:=FastProcessNextState(LastState,LocalInput[Position-1]);
   if not assigned(State) then begin
    result:=DFAError;
    exit;
   end;
  end;
  if (State^.Flags and (sfDFAMatchWins or sfDFADead or sfDFAStart))<>0 then begin
   if (State^.Flags and sfDFADead)<>0 then begin
    if result<>DFAMatch then begin
     result:=DFAFail;
    end;
    exit;
   end;
   if (State^.Flags and sfDFAMatchWins)<>0 then begin
    MatchEnd:=Position-1;
    result:=DFAMatch;
   end;
   if (State^.Flags and sfDFAStart)<>0 then begin
    if Position<UntilExcludingPosition then begin
     TemporaryTestState:=State^.NextStates[LocalByteMap[TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))]];
     if assigned(TemporaryTestState) and ((TemporaryTestState^.Flags and sfDFAStart)<>0) then begin
      Offset:=Instance.SearchNextPossibleStartForDFA(@LocalInput[Position],UntilExcludingPosition-Position);
      if Offset<0 then begin
       exit;
      end;
      inc(Position,Offset);
     end;
    end;
   end;
  end;
 end;
end;
{$endif}

function TFLREDFA.SearchMatchFastReversed(const StartPosition,UntilIncludingPosition:TFLRESizeInt;out MatchBegin:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32; {$ifdef cpu386}assembler; stdcall;
var ResultValue:TFLREInt32;
    StartOffset:pointer;
asm
 push ebx
 push esi
 push edi

  mov dword ptr ResultValue,DFAFail

  mov edx,self

  mov edi,dword ptr [edx+TFLREDFA.ThreadLocalStorageInstance]

  mov esi,dword ptr [edi+TFLREThreadLocalStorageInstance.Input]
  inc esi
  mov dword ptr StartOffset,esi
  dec esi
  add esi,dword ptr StartPosition

  mov edi,dword ptr [edx+TFLREDFA.DefaultStates+dskFastReversed*4]
  test edi,edi
  jz @Error

  mov ecx,dword ptr StartPosition
  sub ecx,dword ptr UntilIncludingPosition
  inc ecx
  jz @Done
  js @Done

  mov edx,[edx+TFLREDFA.Instance]
  lea edx,[edx+TFLRE.ByteMap]

  @Loop:

    movzx eax,TFLREUInt8 ptr [esi]
    dec esi

    movzx ebx,TFLREUInt8 ptr [edx+eax]
    mov ebx,dword ptr [edi+TFLREDFAState.NextStates+ebx*4]
    xchg edi,ebx
    test edi,edi
    jz @HaveNoNextState
    @HaveNextState:

    mov ebx,dword ptr [edi+TFLREDFAState.Flags]
    test ebx,sfDFAMatchWins or sfDFADead
    jnz @CheckFlags

   @BackToLoop:
   dec ecx
   jnz @Loop
   jmp @Done

   @CheckFlags:
    test ebx,sfDFADead
    jz @IsNotDFADead
     cmp dword ptr ResultValue,DFAMatch
     jz @Done
      mov dword ptr ResultValue,DFAFail
      jmp @Done
    @IsNotDFADead:
    test ebx,sfDFAMatchWins
    jz @IsNotMatchWin
     mov eax,esi
     sub eax,dword ptr StartOffset
     mov ebx,dword ptr MatchBegin
     mov dword ptr [ebx],eax
     mov dword ptr ResultValue,DFAMatch
    @IsNotMatchWin:
    jmp @BackToLoop

   @HaveNoNextState:
    push ecx
    push edx          
     mov ecx,eax // Char
     mov eax,self
     mov edx,ebx // State
     call FastProcessNextState
    pop edx
    pop ecx
    mov edi,eax
    test edi,edi
    jnz @HaveNextState

    @Error:
    mov dword ptr ResultValue,DFAError

  @Done:

  mov eax,dword ptr ResultValue

 pop edi
 pop esi
 pop ebx
end;
{$else}
var Position:TFLRESizeInt;
    State,LastState:PFLREDFAState;
    LocalInput:PFLRERawByteChar;
    LocalByteMap:PFLREByteMap;
begin
 result:=DFAFail;
 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalByteMap:=@Instance.ByteMap;
 State:=DefaultStates[dskFastReversed];
 if not assigned(State) then begin
  result:=DFAError;
  exit;
 end;
 for Position:=StartPosition downto UntilIncludingPosition do begin
  LastState:=State;
  State:=State^.NextStates[LocalByteMap[TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))]];
  if not assigned(State) then begin
   State:=FastProcessNextState(LastState,LocalInput[Position]);
   if not assigned(State) then begin
    result:=DFAError;
    exit;
   end;
  end;
  if (State^.Flags and (sfDFAMatchWins or sfDFADead))<>0 then begin
   if (State^.Flags and sfDFADead)<>0 then begin
    if result<>DFAMatch then begin
     result:=DFAFail;
    end;
    exit;
   end;
   if (State^.Flags and sfDFAMatchWins)<>0 then begin
    MatchBegin:=Position;
    result:=DFAMatch;
   end;
  end;
 end;
end;
{$endif}

function TFLREDFA.WorkQueueToCachedState(const WorkQueue:TFLREDFAWorkQueue;Flags:TFLREUInt32):PFLREDFAState;
var Index,CountInstructions,Count:TFLREInt32;
    NeedFlags:TFLREUInt32;
    SawMatch,SawMark:boolean;
    Instruction:PFLREInstruction;
    CurrentItem,EndItem,MarkItem:PPFLREInstruction;
begin

 CountInstructions:=0;
 NeedFlags:=0;
 SawMatch:=false;
 SawMark:=false;

 if WorkQueue.CountInstructions>length(QueueInstructionArray) then begin
  SetLength(QueueInstructionArray,WorkQueue.CountInstructions);
 end;

 for Index:=0 to WorkQueue.CountInstructions-1 do begin
  Instruction:=WorkQueue.Instructions[Index];
  if SawMatch and ((MatchMode=mmFirstMatch) or WorkQueue.IsMark(Instruction)) then begin
   break;
  end;
  if WorkQueue.IsMark(Instruction) then begin
   if (CountInstructions>0) and (QueueInstructionArray[CountInstructions-1]<>Mark) then begin
    SawMark:=true;
    if (CountInstructions+1)>length(QueueInstructionArray) then begin
     SetLength(QueueInstructionArray,(CountInstructions+1)*2);
    end;
    QueueInstructionArray[CountInstructions]:=Mark;
    inc(CountInstructions);
   end;
   continue;
  end;
  case Instruction^.IDandOpcode and $ff of
   opNONE,opSINGLECHAR,opCHAR,opANY,opMATCH,opSPLIT,opSPLITMATCH,opZEROWIDTH,opNOP:begin
{   if (Instruction^.IDandOpcode and $ff)=opSPLITMATCH then begin
     if (MatchMode<>mmMultiMatch) and
        ((MatchMode<>mmFirstMatch) or ((Index=0) and IsInstructionGreedy(Instruction))) and
        ((MatchMode<>mmLongestMatch) or not SawMark) and
        ((Flags and sfDFAMatchWins)<>0) then begin
      result:=DefaultStates[dskFullMatch];
      exit;
     end;
    end;{}
    if (CountInstructions+1)>length(QueueInstructionArray) then begin
     SetLength(QueueInstructionArray,(CountInstructions+1)*2);
    end;
    QueueInstructionArray[CountInstructions]:=Instruction;
    inc(CountInstructions);
    if (Instruction^.IDandOpcode and $ff)=opZEROWIDTH then begin
     NeedFlags:=NeedFlags or TFLREUInt32(Instruction^.Value);
    end;
    if ((Instruction^.IDandOpcode and $ff)=opMATCH) and not (fifEndTextAnchor in Instance.InternalFlags) then begin
     SawMatch:=true;
    end;
   end;
  end;
 end;

 // For suppress compiler variable-unused warning
 if SawMark then begin
 end;

 if (CountInstructions>0) and (QueueInstructionArray[CountInstructions-1]=Mark) then begin
  dec(CountInstructions);
 end;

 // Drop flags if no zero-width instructions are there, to save unneeded cached states
 if NeedFlags=0 then begin
  Flags:=Flags and sfDFAMatchWins;
 end;

 // Dead state? If yes, ...
 if (CountInstructions=0) and (Flags=0) then begin
  // ... drop it and take the dead state as the next state
  result:=DefaultStates[dskDead];
  exit;
 end;

 if (MatchMode=mmLongestMatch) and (CountInstructions>0) then begin
  // Sort in longest match mode to reduce the number of distinct sets which must be stored
  CurrentItem:=@QueueInstructionArray[0];
  EndItem:=@QueueInstructionArray[CountInstructions];
  while TFLREPtrUInt(pointer(CurrentItem))<TFLREPtrUInt(pointer(EndItem)) do begin
   MarkItem:=CurrentItem;
   Count:=0;
   while (TFLREPtrUInt(pointer(MarkItem))<TFLREPtrUInt(pointer(EndItem))) and (MarkItem^<>Mark) do begin
    inc(MarkItem);
    inc(Count);
   end;
   IndirectIntroSort(pointer(CurrentItem),0,Count-1,CompareInstruction);
   if TFLREPtrUInt(pointer(MarkItem))<TFLREPtrUInt(pointer(EndItem)) then begin
    inc(MarkItem);
   end;
   CurrentItem:=MarkItem;
  end;
 end;

 NewState.Flags:=Flags or (NeedFlags shl sfDFANeedShift);
 if CountInstructions>0 then begin
  SetLength(NewState.Instructions,CountInstructions);
  Move(QueueInstructionArray[0],NewState.Instructions[0],CountInstructions*SizeOf(PFLREInstruction));
  NewState.CountInstructions:=CountInstructions;
 end else begin
  NewState.Instructions:=nil;
  NewState.CountInstructions:=0;
 end;

 result:=CacheState(@NewState);

end;

procedure TFLREDFA.StateToWorkQueue(const DFAState:PFLREDFAState;const WorkQueue:TFLREDFAWorkQueue);
var Index:TFLREInt32;
begin
 WorkQueue.Clear;
 for Index:=0 to DFAState^.CountInstructions-1 do begin
  if DFAState^.Instructions[Index]=Mark then begin
   WorkQueue.Mark;
  end else begin
   WorkQueue.AddNew(DFAState^.Instructions[Index]);
  end;
 end;
end;

procedure TFLREDFA.AddToWorkQueue(const WorkQueue:TFLREDFAWorkQueue;Instruction:PFLREInstruction;Flags:TFLREUInt32);
var StackPointer:TFLREInt32;
begin
 StackPointer:=0;
 if (StackPointer+1)>length(QueueStack) then begin
  SetLength(QueueStack,(StackPointer+1)*2);
 end;
 QueueStack[StackPointer]:=Instruction;
 inc(StackPointer);
 while StackPointer>0 do begin
  dec(StackPointer);
  Instruction:=QueueStack[StackPointer];
  if Instruction=Mark then begin
   WorkQueue.Mark;
  end else if not WorkQueue.Contains(Instruction) then begin
   WorkQueue.AddNew(Instruction);
   case Instruction^.IDandOpcode and $ff of
    opNONE,opSINGLECHAR,opCHAR,opANY,opMATCH:begin
     // Just save onto the queue
    end;
    {$ifdef UseOpcodeJMP}opJMP,{$endif}opSAVE,opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE,opNOP:begin
     // No-ops at DFA
     if (StackPointer+1)>length(QueueStack) then begin
      SetLength(QueueStack,(StackPointer+1)*2);
     end;
     QueueStack[StackPointer]:=Instruction^.Next;
     inc(StackPointer);
    end;
    opSPLIT,opSPLITMATCH:begin
     if (StackPointer+3)>length(QueueStack) then begin
      SetLength(QueueStack,(StackPointer+3)*2);
     end;
     QueueStack[StackPointer]:=Instruction^.OtherNext;
     inc(StackPointer);
     if NeedMark and IsUnanchored and assigned(Instruction) then begin
      QueueStack[StackPointer]:=Mark;
      inc(StackPointer);
     end;
     QueueStack[StackPointer]:=Instruction^.Next;
     inc(StackPointer);
    end;
    opZEROWIDTH:begin
     if (TFLREUInt32(Instruction^.Value) and not Flags)=0 then begin
      if (StackPointer+1)>length(QueueStack) then begin
       SetLength(QueueStack,(StackPointer+1)*2);
      end;
      QueueStack[StackPointer]:=Instruction^.Next;
      inc(StackPointer);
     end;
    end;
   end;
  end;
 end;
end;

procedure TFLREDFA.ProcessWorkQueueOnZeroWidthString(const OldWorkQueue,NewWorkQueue:TFLREDFAWorkQueue;Flags:TFLREUInt32);
var Index:TFLREInt32;
    Instruction:PFLREInstruction;
begin
 NewWorkQueue.Clear;
 for Index:=0 to OldWorkQueue.CountInstructions-1 do begin
  Instruction:=OldWorkQueue.Instructions[Index];
  if OldWorkQueue.IsMark(Instruction) then begin
   AddToWorkQueue(NewWorkQueue,Mark,Flags);
  end else begin
   AddToWorkQueue(NewWorkQueue,Instruction,Flags);
  end;
 end;
end;

procedure TFLREDFA.ProcessWorkQueueOnByte(const OldWorkQueue,NewWorkQueue:TFLREDFAWorkQueue;CurrentChar,Flags:TFLREUInt32;var IsMatch:boolean);
var Index:TFLREInt32;
    Instruction:PFLREInstruction;
begin
 NewWorkQueue.Clear;
 for Index:=0 to OldWorkQueue.CountInstructions-1 do begin
  Instruction:=OldWorkQueue.Instructions[Index];
  if OldWorkQueue.IsMark(Instruction) then begin
   if IsMatch then begin
    exit;
   end;
   NewWorkQueue.Mark;
  end else begin
   case Instruction^.IDandOpcode and $ff of
    {$ifdef UseOpcodeJMP}opJMP,{$endif}opSAVE,opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE,opSPLIT,opSPLITMATCH,opZEROWIDTH,opNOP:begin
     // Already processed
    end;
    opNONE:begin
     // Match against nothing
    end;
    opSINGLECHAR:begin
     if CurrentChar=TFLREUInt32(Instruction^.Value) then begin
      AddToWorkQueue(NewWorkQueue,Instruction^.Next,Flags);
     end;
    end;
    opCHAR:begin
     if (CurrentChar<>256) and (TFLRERawByteChar(TFLREUInt8(CurrentChar)) in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^) then begin
      AddToWorkQueue(NewWorkQueue,Instruction^.Next,Flags);
     end;
    end;
    opANY:begin
     if CurrentChar<>256 then begin
      AddToWorkQueue(NewWorkQueue,Instruction^.Next,Flags);
     end;
    end;
    opMATCH:begin
     if not ((fifEndTextAnchor in Instance.InternalFlags) and (CurrentChar<>256)) then begin
      IsMatch:=true;
      if MatchMode=mmFirstMatch then begin
       exit;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function TFLREDFA.RunStateOnByte(State:PFLREDFAState;const Position:TFLRESizeInt;const CurrentChar:TFLREUInt32):PFLREDFAState;
var NeedFlags,BeforeFlags,OldBeforeFlags,AfterFlags,Flags,UnicodeChar:TFLREUInt32;
    IsMatch,IsWordChar:boolean;
    Queues:array[0..2] of TFLREDFAWorkQueue;
begin

 if assigned(State) then begin
  if (State^.Flags and sfDFADead)<>0 then begin
   result:=nil;
   exit;
  end else if (State^.Flags and sfDFAFullMatch)<>0 then begin
   result:=DefaultStates[dskFullMatch];
   exit;
  end;
 end else begin
  result:=nil;
  exit;
 end;

 if assigned(State^.NextStates[ByteMap[CurrentChar]]) then begin
  result:=State^.NextStates[ByteMap[CurrentChar]];
  exit;
 end;

 Queues[0]:=WorkQueues[0];
 Queues[1]:=WorkQueues[1];

 StateToWorkQueue(State,Queues[0]);

 // Fetch flags
 NeedFlags:=(State^.Flags and sfDFACacheMask) shr sfDFANeedShift;
 BeforeFlags:=State^.Flags and sfEmptyAllFlags;
 OldBeforeFlags:=BeforeFlags and sfDFACacheMask;
 AfterFlags:=0;

 // Calculate flags
 if CurrentChar<>256 then begin
  if (rfUTF8 in Instance.Flags) and (CurrentChar>=$80) then begin
   UnicodeChar:=UTF8PtrCodeUnitGetCharFallback(ThreadLocalStorageInstance.Input,ThreadLocalStorageInstance.InputLength,Position);
   case UnicodeChar of
    $2028,$2029:begin
     BeforeFlags:=BeforeFlags or sfEmptyEndLine;
     AfterFlags:=AfterFlags or sfEmptyBeginLine;
    end;
   end;
   IsWordChar:=Instance.IsWordChar(UnicodeChar);
  end else begin
   case CurrentChar of
    $0a,$0d,$85:begin
     BeforeFlags:=BeforeFlags or sfEmptyEndLine;
     AfterFlags:=AfterFlags or sfEmptyBeginLine;
    end;
   end;
   IsWordChar:=Instance.IsWordChar(CurrentChar);
  end;
 end else begin
  IsWordChar:=false;
  BeforeFlags:=BeforeFlags or (sfEmptyEndLine or sfEmptyEndText);
  AfterFlags:=AfterFlags or (sfEmptyBeginLine or sfEmptyBeginText);
 end;

{if not Reversed then begin
  writeln(' ',((State.Flags and sfDFALastWord)<>0)=IsWordChar,' ',(State.Flags and sfDFALastWord)<>0,' ',IsWordChar);
 end;{}

 if ((State^.Flags and sfDFALastWord)<>0)=IsWordChar then begin
  BeforeFlags:=BeforeFlags or sfEmptyNonWordBoundary;
 end else begin
  BeforeFlags:=BeforeFlags or sfEmptyWordBoundary;
 end;

 // Process zero-width-string step
 if ((BeforeFlags and not OldBeforeFlags) and NeedFlags)<>0 then begin
  ProcessWorkQueueOnZeroWidthString(Queues[0],Queues[1],BeforeFlags);
  Queues[2]:=Queues[0];
  Queues[0]:=Queues[1];
  Queues[1]:=Queues[2];
 end;

 // Process state instructions
 IsMatch:=false;
 ProcessWorkQueueOnByte(Queues[0],Queues[1],CurrentChar,AfterFlags,IsMatch);

 if (CurrentChar<>256) or (MatchMode<>mmMultiMatch) then begin
  Queues[2]:=Queues[0];
  Queues[0]:=Queues[1];
  Queues[1]:=Queues[2];
 end;

 // Add missed flags
 Flags:=AfterFlags;
 if IsMatch then begin
  Flags:=Flags or sfDFAMatchWins;
 end;
 if IsWordChar then begin
  Flags:=Flags or sfDFALastWord;
 end;

 // Convert and cache it
 result:=WorkQueueToCachedState(Queues[0],Flags);

 // Connect the last state to the new state with the current char
 State^.NextStates[ByteMap[CurrentChar]]:=result;

end;

function TFLREDFA.InitializeStartState(const StartPosition:TFLRESizeInt;const UnanchoredStart:boolean):PFLREDFAState;
var LocalInputLength,Start,PreviousPosition,NextPosition:TFLRESizeInt;
    PreviousChar,NextChar,Flags:TFLREUInt32;
    LocalInput:PFLRERawByteChar;
    StartInstruction:PFLREInstruction;
    StartState:PPFLREDFAState;
begin

 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalInputLength:=ThreadLocalStorageInstance.InputLength;

 if Reversed then begin

  if StartPosition=(ThreadLocalStorageInstance.InputLength-1) then begin
   Start:=sskBeginText;
   Flags:=sfEmptyBeginText or sfEmptyBeginLine;
  end else begin
   if (rfUTF8 in Instance.Flags) and ((TFLREUInt8(TFLRERawByteChar(LocalInput[StartPosition])) and $80)<>0) then begin
    NextPosition:=StartPosition;
    UTF8PtrSafeInc(LocalInput,LocalInputLength,NextPosition);
    if (NextPosition>=0) and (NextPosition<ThreadLocalStorageInstance.InputLength) then begin
     NextChar:=UTF8PtrCodeUnitGetCharFallback(LocalInput,ThreadLocalStorageInstance.InputLength,NextPosition);
    end else begin
     NextChar:=$ffffffff;
    end;
   end else begin
    NextChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[StartPosition+1]));
   end;
   case NextChar of
    $0a,$0d,$85,$2028,$2029:begin
     Start:=sskBeginLine;
     Flags:=sfEmptyBeginLine;
    end;
    else begin
     if Instance.IsWordChar(NextChar) then begin
      Start:=sskAfterWordChar;
      Flags:=sfDFALastWord;
     end else begin
      Start:=sskAfterNonWordChar;
      Flags:=0;
     end;
    end;
   end;
  end;

  StartInstruction:=Instance.ReversedStartInstruction;
  inc(Start,sskReversed);

 end else begin

  if StartPosition<=0 then begin
   Start:=sskBeginText;
   Flags:=sfEmptyBeginText or sfEmptyBeginLine;
  end else begin
   if rfUTF8 in Instance.Flags then begin
    PreviousPosition:=StartPosition;
    UTF8PtrDec(LocalInput,ThreadLocalStorageInstance.InputLength,PreviousPosition);
    if (PreviousPosition>=0) and (PreviousPosition<ThreadLocalStorageInstance.InputLength) then begin
     PreviousChar:=UTF8PtrCodeUnitGetCharFallback(LocalInput,ThreadLocalStorageInstance.InputLength,PreviousPosition);
    end else begin
     PreviousChar:=$ffffffff;
    end;
   end else begin
    PreviousChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[StartPosition-1]));
   end;
   case PreviousChar of
    $0a,$0d,$85,$2028,$2029:begin
     Start:=sskBeginLine;
     Flags:=sfEmptyBeginLine;
    end;
    else begin
     if Instance.IsWordChar(PreviousChar) then begin
      Start:=sskAfterWordChar;
      Flags:=sfDFALastWord;
     end else begin
      Start:=sskAfterNonWordChar;
      Flags:=0;
     end;
    end;
   end;
  end;

  if UnanchoredStart then begin
   if fifDFAFastBeginningSearch in Instance.InternalFlags then begin
    Flags:=Flags or sfDFAStart;
   end;
   StartInstruction:=Instance.UnanchoredStartInstruction;
   inc(Start,sskUnanchored);
  end else begin
   StartInstruction:=Instance.AnchoredStartInstruction;
   inc(Start,sskAnchored);
  end;

 end;

 StartState:=@StartStates[Start];
 if assigned(StartState^) then begin
  result:=StartState^;
 end else begin
  WorkQueues[0].Clear;
  AddToWorkQueue(WorkQueues[0],StartInstruction,Flags);
  result:=WorkQueueToCachedState(WorkQueues[0],Flags);
  StartState^:=result;
 end;

end;

function TFLREDFA.SearchMatchFull(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32;
{$ifdef cpu386}
label ProcessNewStartState,SkipProcessNewStartState,NewStartState,ExitFunction;
{$endif}
var Position,LocalInputLength{,Index},Offset:TFLRESizeInt;
    State,LastState,TemporaryTestState:PFLREDFAState;
    LocalInput:PFLRERawByteChar;
    {Flags,}CurrentChar:TFLREUInt32;
    LocalByteMap:PFLREDFAByteMap;
//  Instruction:PFLREInstruction;
begin

 result:=DFAFail;

 State:=InitializeStartState(StartPosition,UnanchoredStart);

 if not assigned(State) then begin
  result:=DFAError;
  exit;
 end;

 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalInputLength:=ThreadLocalStorageInstance.InputLength;
 if LocalInputLength<>0 then begin
 end;

 LocalByteMap:=@ByteMap;

 if assigned(State) and ((State^.Flags and sfDFAMatchWins)<>0) then begin
  MatchEnd:=StartPosition-1;
  result:=DFAMatch;
 end;

 Position:=StartPosition;

{$ifdef cpu386}
 NewStartState:
 asm

   pushad

   mov ecx,dword ptr UntilExcludingPosition
   sub ecx,dword ptr Position
   jz @EmptyDone
   js @EmptyDone

   mov esi,dword ptr LocalInput
   add esi,dword ptr Position

   mov edx,dword ptr LocalByteMap

   mov edi,dword ptr State

    @Loop:

     movzx eax,TFLREUInt8 ptr [esi]
     inc esi

     mov ebx,dword ptr [edx+eax*4]
     mov ebx,dword ptr [edi+TFLREDFAState.NextStates+ebx*4]
     xchg edi,ebx
     test edi,edi
     jz @HaveNoNextState
     @HaveNextState:

     mov ebx,dword ptr [edi+TFLREDFAState.Flags]
     test ebx,sfDFAMatchWins or sfDFADead or sfDFAFullMatch or sfDFAStart
     jnz @CheckFlags

    @BackToLoop:
    dec ecx
    jnz @Loop
    jmp @Done

    @CheckFlags:
     test ebx,sfDFADead
     jz @IsNotDFADead
      cmp dword ptr result,DFAMatch
      jz @DoneMatch
       mov dword ptr result,DFAFail
      @DoneMatch: 
      popad
      jmp ExitFunction
     @IsNotDFADead:
     test ebx,sfDFAFullMatch
     jz @IsNotFullMatch
      mov eax,dword ptr UntilExcludingPosition
      dec eax
      mov dword ptr MatchEnd,eax
      mov dword ptr result,DFAMatch
      popad
      jmp ExitFunction
     @IsNotFullMatch:
     test ebx,sfDFAMatchWins
     jz @IsNotMatchWin
      push ebx
      lea eax,[esi-2]
      sub eax,dword ptr LocalInput
      mov ebx,dword ptr MatchEnd
      mov dword ptr [ebx],eax
      mov dword ptr result,DFAMatch
      pop ebx
     @IsNotMatchWin:
     test ebx,sfDFAStart
     jz @IsNotStartState
       sub esi,dword ptr LocalInput
       mov dword ptr Position,esi
       popad
      jmp ProcessNewStartState
     @IsNotStartState:
     jmp @BackToLoop

    @HaveNoNextState:
     push ecx
     push edx
      push eax // Char
      lea ecx,[esi-1]
      sub ecx,dword ptr LocalInput
      mov eax,self
      mov edx,ebx // State
      call RunStateOnByte
     pop edx
     pop ecx
     mov edi,eax
     test edi,edi
     jnz @HaveNextState

     mov dword ptr result,DFAError
     popad
     jmp ExitFunction

    @Done:

    mov dword ptr State,edi

    @EmptyDone:

   popad

   jmp SkipProcessNewStartState
 end;
 ProcessNewStartState:
  if Position<UntilExcludingPosition then begin
   TemporaryTestState:=State^.NextStates[LocalByteMap^[TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))]];
   if assigned(TemporaryTestState) and ((TemporaryTestState^.Flags and sfDFAStart)<>0) then begin
    Offset:=Instance.SearchNextPossibleStartForDFA(@LocalInput[Position],UntilExcludingPosition-Position);
    if Offset<0 then begin
     exit;
    end;
    inc(Position,Offset);
    State:=InitializeStartState(Position,UnanchoredStart);
    if assigned(State) and ((State^.Flags and sfDFAMatchWins)<>0) then begin
     MatchEnd:=Position-1;
     result:=DFAMatch;
    end;
   end;
  end;
  goto NewStartState;
 SkipProcessNewStartState:
{$else}
 while Position<UntilExcludingPosition do begin
  CurrentChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[Position]));
  inc(Position);
  LastState:=State;
//write(chr(CurrentChar),' ',LocalByteMap^[CurrentChar],' ');
  State:=State^.NextStates[LocalByteMap^[CurrentChar]];
  if not assigned(State) then begin
   State:=RunStateOnByte(LastState,Position-1,CurrentChar);
   if not assigned(State) then begin
    result:=DFAError;
    exit;
   end;
{ end else begin
   writeln(' cached');{}
  end;
  if (State^.Flags and (sfDFAMatchWins or sfDFADead or sfDFAFullMatch or sfDFAStart))<>0 then begin
   if (State^.Flags and sfDFADead)<>0 then begin
    if result<>DFAMatch then begin
     result:=DFAFail;
    end;
    exit;
   end;
   if (State^.Flags and sfDFAFullMatch)<>0 then begin
    MatchEnd:=UntilExcludingPosition-1;
    result:=DFAMatch;
    exit;
   end;
   if (State^.Flags and sfDFAMatchWins)<>0 then begin
    MatchEnd:=Position-2;
//  writeln('Match: ',LocalInput[Position-2],LocalInput[Position-1]);
    result:=DFAMatch;
   end;
   if (State^.Flags and sfDFAStart)<>0 then begin
    if Position<UntilExcludingPosition then begin
     TemporaryTestState:=State^.NextStates[LocalByteMap^[TFLREUInt8(TFLRERawByteChar(LocalInput[Position]))]];
     if assigned(TemporaryTestState) and ((TemporaryTestState^.Flags and sfDFAStart)<>0) then begin
      Offset:=Instance.SearchNextPossibleStartForDFA(@LocalInput[Position],UntilExcludingPosition-Position);
      if Offset<0 then begin
       exit;
      end;
      inc(Position,Offset);
      State:=InitializeStartState(Position,UnanchoredStart);
      if assigned(State) and ((State^.Flags and sfDFAMatchWins)<>0) then begin
       MatchEnd:=Position-1;
       result:=DFAMatch;
      end;
     end;
    end;
   end;
  end;
 end;
{$endif}

 Position:=UntilExcludingPosition;

 if (Position>=0) and (Position<LocalInputLength) then begin
  CurrentChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[Position]));
 end else begin
  CurrentChar:=256;
 end;

 LastState:=State;
 State:=State^.NextStates[LocalByteMap^[CurrentChar]];
 if not assigned(State) then begin
  State:=RunStateOnByte(LastState,Position,CurrentChar);
  if not assigned(State) then begin
   result:=DFAError;
   exit;
  end;
 end;
 if (State^.Flags and (sfDFAMatchWins or sfDFADead or sfDFAFullMatch))<>0 then begin
  if (State^.Flags and sfDFADead)<>0 then begin
   if result<>DFAMatch then begin
    result:=DFAFail;
   end;
   exit;
  end;
  if (State^.Flags and sfDFAFullMatch)<>0 then begin
   MatchEnd:=UntilExcludingPosition-1;
   result:=DFAMatch;
   exit;
  end;
  if (State^.Flags and sfDFAMatchWins)<>0 then begin
   MatchEnd:=Position-1;
   result:=DFAMatch;
{  if MatchMode=mmMultiMatch then begin
    for Index:=0 to State^.CountInstructions-1 do begin
     Instruction:=State^.Instructions[Index];
     if assigned(Instruction) and ((Instruction^.IDandOpcode and $ff)=opMATCH) then begin
      if (Instruction.Value>=0) and (Instruction.Value<Instance.CountMultiSubMatches) then begin
       ThreadLocalStorageInstance.MultiSubMatches[Instruction.Value]:=Instruction.Value;
      end;
     end;
    end;
   end;{}
  end;
 end;

{$ifdef cpu386}
 ExitFunction:
{$endif}
end;

function TFLREDFA.SearchMatchFullReversed(const StartPosition,UntilExcludingPosition:TFLRESizeInt;out MatchEnd:TFLRESizeInt;const UnanchoredStart:longbool):TFLREInt32;
{$ifdef cpu386}
label ExitFunction;
{$endif}
var Position,LocalInputLength:TFLRESizeInt;
    State,LastState:PFLREDFAState;
    LocalInput:PFLRERawByteChar;
    {Flags,}CurrentChar:TFLREUInt32;
    LocalByteMap:PFLREDFAByteMap;
//  Instruction:PFLREInstruction;
begin

 result:=DFAFail;

 State:=InitializeStartState(StartPosition,UnanchoredStart);

 if not assigned(State) then begin
  result:=DFAError;
  exit;
 end;

 LocalInput:=ThreadLocalStorageInstance.Input;
 LocalInputLength:=ThreadLocalStorageInstance.InputLength;
 if LocalInputLength<>0 then begin
 end;

 LocalByteMap:=@ByteMap;

 if assigned(State) and ((State^.Flags and sfDFAMatchWins)<>0) then begin
  MatchEnd:=StartPosition+1;
  result:=DFAMatch;
 end;

{$ifdef cpu386}
 asm

  pushad

  mov ecx,dword ptr StartPosition
  sub ecx,dword ptr UntilExcludingPosition
  js @EmptyDone

  mov esi,dword ptr LocalInput
  add esi,dword ptr StartPosition

  mov edx,dword ptr LocalByteMap

  mov edi,dword ptr State

   @Loop:

    movzx eax,TFLREUInt8 ptr [esi]
    dec esi

    mov ebx,dword ptr [edx+eax*4]
    mov ebx,dword ptr [edi+TFLREDFAState.NextStates+ebx*4]
    xchg edi,ebx
    test edi,edi
    jz @HaveNoNextState
    @HaveNextState:

    mov ebx,dword ptr [edi+TFLREDFAState.Flags]
    test ebx,sfDFAMatchWins or sfDFADead or sfDFAFullMatch
    jnz @CheckFlags

   @BackToLoop:
   dec ecx
   jns @Loop
   jmp @Done

   @CheckFlags:
    test ebx,sfDFADead
    jz @IsNotDFADead
     cmp dword ptr result,DFAMatch
     jz @DoneMatch
      mov dword ptr result,DFAFail
     @DoneMatch:
      popad
      jmp ExitFunction
    @IsNotDFADead:
    test ebx,sfDFAFullMatch
    jz @IsNotFullMatch
     mov eax,dword ptr UntilExcludingPosition
     mov dword ptr MatchEnd,eax
     mov dword ptr result,DFAMatch
     popad
     jmp ExitFunction
    @IsNotFullMatch:
    test ebx,sfDFAMatchWins
    jz @IsNotMatchWin
     lea eax,[esi+2]
     sub eax,dword ptr LocalInput
     mov ebx,dword ptr MatchEnd
     mov dword ptr [ebx],eax
     mov dword ptr result,DFAMatch
    @IsNotMatchWin:
    jmp @BackToLoop

   @HaveNoNextState:
    push ecx
    push edx
     push eax // Char
     lea ecx,[esi+1]
     sub ecx,dword ptr LocalInput
     mov eax,self
     mov edx,ebx // State
     call RunStateOnByte
    pop edx
    pop ecx
    mov edi,eax
    test edi,edi
    jnz @HaveNextState

    mov dword ptr result,DFAError
    popad
    jmp ExitFunction

   @Done:

   mov dword ptr State,edi

   @EmptyDone:

  popad

 end;
{$else}
 for Position:=StartPosition downto UntilExcludingPosition do begin
  CurrentChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[Position]));
  LastState:=State;
  State:=State^.NextStates[LocalByteMap^[CurrentChar]];
  if not assigned(State) then begin
   State:=RunStateOnByte(LastState,Position,CurrentChar);
   if not assigned(State) then begin
    result:=DFAError;
    exit;
   end;
  end;
  if (State^.Flags and (sfDFAMatchWins or sfDFADead or sfDFAFullMatch))<>0 then begin
   if (State^.Flags and sfDFADead)<>0 then begin
    if result<>DFAMatch then begin
     result:=DFAFail;
    end;
    exit;
   end;
   if (State^.Flags and sfDFAFullMatch)<>0 then begin
    MatchEnd:=UntilExcludingPosition;
    result:=DFAMatch;
    exit;
   end;
   if (State^.Flags and sfDFAMatchWins)<>0 then begin
    MatchEnd:=Position+1;
    result:=DFAMatch;
   end;
  end;
 end;
{$endif}

 Position:=UntilExcludingPosition-1;

 if (Position>=0) and (Position<LocalInputLength) then begin
  CurrentChar:=TFLREUInt8(TFLRERawByteChar(LocalInput[Position]));
 end else begin
  CurrentChar:=256;
 end;

 LastState:=State;
 State:=State^.NextStates[LocalByteMap^[CurrentChar]];
 if not assigned(State) then begin
  State:=RunStateOnByte(LastState,Position,CurrentChar);
  if not assigned(State) then begin
   result:=DFAError;
   exit;
  end;
 end;
 if (State^.Flags and (sfDFAMatchWins or sfDFADead or sfDFAFullMatch))<>0 then begin
  if (State^.Flags and sfDFADead)<>0 then begin
   if result<>DFAMatch then begin
    result:=DFAFail;
   end;
   exit;
  end;
  if (State^.Flags and sfDFAFullMatch)<>0 then begin
   MatchEnd:=UntilExcludingPosition;
   result:=DFAMatch;
   exit;
  end;
  if (State^.Flags and sfDFAMatchWins)<>0 then begin
   MatchEnd:=Position+1;
   result:=DFAMatch;
  end;
 end;

{$ifdef cpu386}
 ExitFunction:
{$endif}
end;

constructor TFLREThreadLocalStorageInstance.Create(AInstance:TFLRE);
begin
 inherited Create;

 AllNext:=nil;
 FreeNext:=nil;

 Instance:=AInstance;

 Input:=nil;
 InputLength:=0;

 if rfMULTIMATCH in Instance.Flags then begin
  MatchMode:=mmMultiMatch;
 end else if rfLONGEST in Instance.Flags then begin
  MatchMode:=mmLongestMatch;
 end else begin
  MatchMode:=mmFirstMatch;
 end;

 MultiSubMatches:=nil;
 SetLength(MultiSubMatches,Instance.CountMultiSubMatches);

 ParallelNFA:=TFLREParallelNFA.Create(self);

 if fifOnePassNFAReady in Instance.InternalFlags then begin
  OnePassNFA:=TFLREOnePassNFA.Create(self);
 end else begin
  OnePassNFA:=nil;
 end;

 if fifBitStateNFAReady in Instance.InternalFlags then begin
  BitStateNFA:=TFLREBitStateNFA.Create(self);
 end else begin
  BitStateNFA:=nil;
 end;

 if fifDFAReady in Instance.InternalFlags then begin
  DFA:=TFLREDFA.Create(self,false,Instance.MaximalDFAStates);
  ReversedDFA:=TFLREDFA.Create(self,true,Instance.MaximalDFAStates);
 end else begin
  DFA:=nil;
  ReversedDFA:=nil;
 end;

end;

destructor TFLREThreadLocalStorageInstance.Destroy;
begin

 SetLength(MultiSubMatches,0);

 ParallelNFA.Free;

 OnePassNFA.Free;

 BitStateNFA.Free;

 DFA.Free;
 ReversedDFA.Free;

 inherited Destroy;
end;

function TFLREThreadLocalStorageInstance.GetSatisfyFlags(const Position:TFLRESizeInt):TFLREUInt32;
var PreviousPosition:TFLRESizeInt;
    PreviousChar,CurrentChar:TFLREUInt32;
begin
 result:=0;
 if rfUTF8 in Instance.Flags then begin
  PreviousPosition:=Position;
  UTF8PtrDec(Input,InputLength,PreviousPosition);
  if (PreviousPosition>=0) and (PreviousPosition<InputLength) then begin
   PreviousChar:=UTF8PtrCodeUnitGetCharFallback(Input,InputLength,PreviousPosition);
  end else begin
   PreviousChar:=0;
  end;
  if (Position>=0) and (Position<InputLength) then begin
   CurrentChar:=UTF8PtrCodeUnitGetCharFallback(Input,InputLength,Position);
  end else begin
   CurrentChar:=0;
  end;
 end else begin
  PreviousPosition:=Position-1;
  if (PreviousPosition>=0) and (PreviousPosition<InputLength) then begin
   PreviousChar:=TFLREUInt8(TFLRERawByteChar(Input[PreviousPosition]));
  end else begin
   PreviousChar:=0;
  end;
  if (Position>=0) and (Position<InputLength) then begin
   CurrentChar:=TFLREUInt8(TFLRERawByteChar(Input[Position]));
  end else begin
   CurrentChar:=0;
  end;
 end;
 if Position<=0 then begin
  result:=result or (sfEmptyBeginText or sfEmptyBeginLine);
 end else begin
  case PreviousChar of
   $0a,$0d,$85,$2028,$2029:begin
    result:=result or sfEmptyBeginLine;
   end;
  end;
 end;
 if Position>=InputLength then begin
  result:=result or (sfEmptyEndText or sfEmptyEndLine);
 end else begin
  case CurrentChar of
   $0a,$0d,$85,$2028,$2029:begin
    result:=result or sfEmptyEndLine;
   end;
  end;
 end;
 if InputLength>0 then begin
  if Position=0 then begin
   if Instance.IsWordChar(CurrentChar) then begin
    result:=result or sfEmptyWordBoundary;
   end;
  end else if Position>=InputLength then begin
   if Instance.IsWordChar(PreviousChar) then begin
    result:=result or sfEmptyWordBoundary;
   end;
  end else if Instance.IsWordChar(PreviousChar)<>Instance.IsWordChar(CurrentChar) then begin
   result:=result or sfEmptyWordBoundary;
  end;
 end;
 if (result and sfEmptyWordBoundary)=0 then begin
  result:=result or sfEmptyNonWordBoundary;
 end;
end;

function TFLREThreadLocalStorageInstance.LookAssertion(const Position,WhichLookAssertionString:TFLRESizeInt;const LookBehind,Negative:boolean):boolean;
var Index,LookAssertionStringLength,BasePosition:TFLRESizeInt;
    LookAssertionString:TFLRERawByteString;
begin
 if WhichLookAssertionString<Instance.CountLookAssertionStrings then begin
  LookAssertionString:=Instance.LookAssertionStrings[WhichLookAssertionString];
  LookAssertionStringLength:=length(LookAssertionString);
  if LookBehind then begin
   if Position>=LookAssertionStringLength then begin
    result:=true;
    for Index:=0 to LookAssertionStringLength-1 do begin
     if Input[(Position-Index)-1]<>LookAssertionString[LookAssertionStringLength-Index] then begin
      result:=false;
      break;
     end;
    end;
   end else begin
    result:=false;
   end;
  end else begin
   if (Position+LookAssertionStringLength)<=InputLength then begin
    result:=true;
    BasePosition:=Position;
    if rfUTF8 in Instance.Flags then begin
     UTF8PtrSafeInc(Input,InputLength,BasePosition);
     dec(BasePosition);
    end;
    for Index:=1 to LookAssertionStringLength do begin
     if Input[(BasePosition+Index)-1]<>LookAssertionString[Index] then begin
      result:=false;
      break;
     end;
    end;
   end else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
 result:=result xor Negative;
end;

function TFLREThreadLocalStorageInstance.BackReferenceAssertion(const CaptureStart,CaptureEnd,BackReferenceStart,BackReferenceEnd:TFLRESizeInt;const IgnoreCase:boolean):boolean;
var CapturePosition,BackReferencePosition:TFLRESizeInt;
begin
 result:=false;
 if (CaptureStart>=0) and (CaptureEnd>0) and (BackReferenceStart>=0) and (BackReferenceEnd>0) then begin
  if IgnoreCase then begin
   if rfUTF8 in Instance.Flags then begin
    result:=true;
    CapturePosition:=CaptureStart;
    BackReferencePosition:=BackReferenceStart;
    while (CapturePosition<CaptureEnd) and (BackReferencePosition<BackReferenceEnd) do begin
     if UnicodeToLower(UTF8PtrCodeUnitGetCharAndIncFallback(Input,InputLength,CapturePosition))<>UnicodeToLower(UTF8PtrCodeUnitGetCharAndIncFallback(Input,InputLength,BackReferencePosition)) then begin
      result:=false;
      exit;
     end;
    end;
   end else begin
    if (CaptureEnd-CaptureStart)=(BackReferenceEnd-BackReferenceStart) then begin
     result:=true;
     CapturePosition:=CaptureStart;
     BackReferencePosition:=BackReferenceStart;
     while (CapturePosition<CaptureEnd) and (BackReferencePosition<BackReferenceEnd) do begin
      if UnicodeToLower(TFLREUInt8(TFLRERawByteChar(Input[CapturePosition])))<>UnicodeToLower(TFLREUInt8(TFLRERawByteChar(Input[BackReferencePosition]))) then begin
       result:=false;
       exit;
      end;
      inc(CapturePosition);
      inc(BackReferencePosition);
     end;
    end;
   end;
  end else begin
   if (CaptureEnd-CaptureStart)=(BackReferenceEnd-BackReferenceStart) then begin
    result:=true;
    CapturePosition:=CaptureStart;
    BackReferencePosition:=BackReferenceStart;
    while (CapturePosition<CaptureEnd) and (BackReferencePosition<BackReferenceEnd) do begin
     if Input[CapturePosition]<>Input[BackReferencePosition] then begin
      result:=false;
      exit;
     end;
     inc(CapturePosition);
     inc(BackReferencePosition);
    end;
   end;
  end;
 end;
end;

constructor TFLRE.Create(const ARegularExpression:TFLRERawByteString;const AFlags:TFLREFlags=[rfDELIMITERS]);
const EmptyString:pansichar='';
var StartDelimiter,EndDelimiter:TFLRERawByteChar;
    Index,SubIndex:TFLRESizeInt;
    FlagsStr:TFLRERawByteString;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Captures:TFLRECaptures;
begin
 inherited Create;

 OriginalRegularExpression:=ARegularExpression;

 MaximalDFAStates:=4096;

 InternalFlags:=[fifDFAFast];

 CountCaptures:=0;

 CountInternalCaptures:=0;

 AnchoredRootNode:=nil;

 UnanchoredRootNode:=nil;

 RegularExpressionHasCharClasses:=false;

 Nodes:=TFLREPointerList.Create;

 ForwardInstructions:=nil;
 CountForwardInstructions:=0;

 BackwardInstructions:=nil;
 CountBackwardInstructions:=0;

 AnchoredStartInstruction:=nil;
 UnanchoredStartInstruction:=nil;
 ReversedStartInstruction:=nil;

 CharClasses:=nil;
 CountCharClasses:=0;

 CharClassHashMap:=TFLRECharClassHashMap.Create;

 LookAssertionStrings:=nil;
 CountLookAssertionStrings:=0;

 FixedStringPatternBitMasks:=nil;
 FixedStringBoyerMooreSkip:=nil;

 PrefixPatternBitMasks:=nil;

 FirstPrefixCharClass:=nil;
 FirstPrefixCharClassSize:=0;
 FirstPrefixCharClassRepeatedCount:=0;

 FirstPrefixCharRanges:=nil;
 CountFirstPrefixCharRanges:=0;

 FirstPrefixCharClassChars:=nil;

 RegularExpression:=ARegularExpression;

 Flags:=AFlags;

 if rfDELIMITERS in Flags then begin

  if length(RegularExpression)=0 then begin
   raise EFLRE.Create('Invalid regular expression');
  end;

  StartDelimiter:=RegularExpression[1];

  case StartDelimiter of
   '(':begin
    EndDelimiter:=')';
   end;
   '[':begin
    EndDelimiter:=']';
   end;
   '{':begin
    EndDelimiter:='}';
   end;
   else begin
    EndDelimiter:=StartDelimiter;
   end;
  end;

  Index:=0;
  for SubIndex:=length(RegularExpression) downto 2 do begin
   if RegularExpression[SubIndex]=EndDelimiter then begin
    Index:=SubIndex;
    break;
   end;
  end;

  if Index=0 then begin
   raise EFLRE.Create('Invalid regular expression');
  end;

  FlagsStr:=copy(RegularExpression,Index+1,(length(RegularExpression)-Index)+1);
  RegularExpression:=copy(RegularExpression,2,Index-2);

  for Index:=1 to length(FlagsStr) do begin
   case FlagsStr[Index] of
    'x':begin
     if rfFREESPACING in Flags then begin
      raise EFLRE.Create('Too many free-spacing regular expression modifier flags');
     end else begin
      Include(Flags,rfFREESPACING);
     end;
    end;
    'i':begin
     if rfIGNORECASE in Flags then begin
      raise EFLRE.Create('Too many ignore-case regular expression modifier flags');
     end else begin
      Include(Flags,rfIGNORECASE);
     end;
    end;
    'n':begin
     if rfNAMED in Flags then begin
      raise EFLRE.Create('Too many named regular expression modifier flags');
     end else begin
      Include(Flags,rfNAMED);
     end;
    end;       
    's':begin
     if rfSINGLELINE in Flags then begin
      raise EFLRE.Create('Too many single-line regular expression modifier flags');
     end else begin
      Include(Flags,rfSINGLELINE);
     end;
    end;
    'm':begin
     if rfMULTILINE in Flags then begin
      raise EFLRE.Create('Too many multi-line regular expression modifier flags');
     end else begin
      Include(Flags,rfMULTILINE);
     end;
    end;
    'u':begin
     if rfUTF8 in Flags then begin
      raise EFLRE.Create('Too many UTF8 regular expression modifier flags');
     end else begin
      Include(Flags,rfUTF8);
     end;
    end;
    'U':begin
     if rfUNGREEDY in Flags then begin
      raise EFLRE.Create('Too many ungreedy regular expression modifier flags');
     end else begin
      Include(Flags,rfUNGREEDY);
     end;
    end;
    'p':begin
     if rfLONGEST in Flags then begin
      raise EFLRE.Create('Too many longest regular expression modifier flags');
     end else begin
      Include(Flags,rfLONGEST);
     end;
    end;
    'o':begin
     if rfONLYFASTOPTIMIZATIONS in Flags then begin
      raise EFLRE.Create('Too many only fast optimization regular expression modifier flags');
     end else begin
      Include(Flags,rfONLYFASTOPTIMIZATIONS);
     end;
    end;
    'a':begin
     if rfMULTIMATCH in Flags then begin
      raise EFLRE.Create('Too many only fast multimatch regular expression modifier flags');
     end else begin
      Include(Flags,rfMULTIMATCH);
     end;
    end;
    else begin
     raise EFLRE.Create('Unknown regular expression modifier flag');
    end;
   end;
  end;
 end;

 FixedString:='';
 FixedStringBoyerMooreNext:=nil;

 OnePassNFANodes:=nil;
 OnePassNFANodesCount:=0;
 OnePassNFAStart:=nil;
 OnePassNFAStateSize:=0;
 OnePassNFACharClassActions:=nil;

 NamedGroupStringList:=TStringList.Create;
 NamedGroupStringIntegerPairHashMap:=TFLREStringIntegerPairHashMap.Create;
 NamedGroupStringIndexList:=TFLREIntegerList.Create;

 CapturesToSubMatchesMap:=nil;

 ParallelLock:=0;

 ThreadLocalStorageInstanceManagerParallelLock:=0;

 ThreadLocalStorageInstances:=nil;
 FreeThreadLocalStorageInstances:=nil;

 RangeLow:='';
 RangeHigh:='';

 PrefilterRootNode:=nil;

 CountMultiSubMatches:=0;

 try

  try

   Parse;

   Compile;

  finally
   SetLength(CharClasses,CountCharClasses);
   SetLength(LookAssertionStrings,CountLookAssertionStrings);
  end;

  CountSubMatches:=CountInternalCaptures*2;

  SetLength(CapturesToSubMatchesMap,CountCaptures);

  ScanProgram;

  CompilePrefix;

  CompileFixedStringSearch;

  CompilePrefixCharClasses;

  CompileByteMapForOnePassNFAAndDFA;

  if not ((fifHasLookAssertions in InternalFlags) or (fifHasBackReferences in InternalFlags)) then begin
   Include(InternalFlags,fifDFAReady);
   CompileOnePassNFA;
  end;

  if (CountForwardInstructions>0) and (CountForwardInstructions<512) then begin
   Include(InternalFlags,fifBitStateNFAReady);
   MaxBitStateNFATextSize:=SizeOf(TFLREBitStateNFAVisited) div CountForwardInstructions;
  end else begin
   MaxBitStateNFATextSize:=0;
  end;

  if not (fifBeginTextAnchor in InternalFlags) then begin
   Include(InternalFlags,fifHaveUnanchoredStart);
  end;

  if fifCanMatchEmptyStrings in InternalFlags then begin
   if RegularExpressionHasCharClasses then begin
    ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
    try
     ThreadLocalStorageInstance.Input:=EmptyString;
     ThreadLocalStorageInstance.InputLength:=0;
     Captures:=nil;
     try
      SetLength(Captures,CountCaptures);
      if not ThreadLocalStorageInstance.ParallelNFA.SearchMatch(Captures,0,1,false) then begin
       Exclude(InternalFlags,fifCanMatchEmptyStrings);
      end;
     finally
      SetLength(Captures,0);
     end;
    finally
     ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
    end;
   end;
  end;

 finally
 end;

end;

constructor TFLRE.Create(const ARegularExpressions:array of TFLRERawByteString;const AFlags:TFLREFlags=[]);
var Index:TFLRESizeInt;
    RegularExpressions:TFLRERawByteString;
begin
 RegularExpressions:='';
 for Index:=0 to length(ARegularExpressions)-1 do begin
  if Index>0 then begin
   RegularExpressions:=RegularExpressions+#0;
  end;
  RegularExpressions:=RegularExpressions+ARegularExpressions[Index];
 end;
 Create(RegularExpressions,(AFlags+[rfMULTIMATCH])-[rfDELIMITERS]);
end;

destructor TFLRE.Destroy;
var Index:TFLRESizeInt;
    NextCharClassAction:PFLREOnePassNFAStateCharClassAction;
    ThreadLocalStorageInstance,NextThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin

 ThreadLocalStorageInstance:=ThreadLocalStorageInstances;
 ThreadLocalStorageInstances:=nil;
 while assigned(ThreadLocalStorageInstance) do begin
  NextThreadLocalStorageInstance:=ThreadLocalStorageInstance.AllNext;
  ThreadLocalStorageInstance.Free;
  ThreadLocalStorageInstance:=NextThreadLocalStorageInstance;
 end;

 if assigned(Nodes) then begin
  for Index:=0 to Nodes.Count-1 do begin
   PFLRENode(Nodes[Index])^.Name:='';
   FreeMem(Nodes[Index]);
  end;
 end;
 FreeAndNil(Nodes);

 if assigned(FixedStringPatternBitMasks) then begin
  FreeMem(FixedStringPatternBitMasks);
 end;

 if assigned(FixedStringBoyerMooreSkip) then begin
  FreeMem(FixedStringBoyerMooreSkip);
 end;

 if assigned(PrefixPatternBitMasks) then begin
  FreeMem(PrefixPatternBitMasks);
 end;

 if assigned(FirstPrefixCharClass) then begin
  FreeMem(FirstPrefixCharClass);
 end;

 SetLength(FirstPrefixCharRanges,0);

 SetLength(FirstPrefixCharClassChars,0);

 SetLength(CapturesToSubMatchesMap,0);

 SetLength(ForwardInstructions,0);

 SetLength(BackwardInstructions,0);

 for Index:=0 to CountCharClasses-1 do begin
  FreeMem(CharClasses[Index]);
 end;
 SetLength(CharClasses,0);
 CountCharClasses:=0;

 CharClassHashMap.Free;

 SetLength(LookAssertionStrings,0);

 if assigned(OnePassNFANodes) then begin
  FreeMem(OnePassNFANodes);
  OnePassNFANodes:=nil;
 end;
 OnePassNFANodesCount:=0;
 OnePassNFAStart:=nil;
 OnePassNFAStateSize:=0;

 while assigned(OnePassNFACharClassActions) do begin
  NextCharClassAction:=OnePassNFACharClassActions^.AllNext;
  FreeMem(OnePassNFACharClassActions);
  OnePassNFACharClassActions:=NextCharClassAction;
 end;
 OnePassNFACharClassActions:=nil;

 SetLength(FixedStringBoyerMooreNext,0);

 NamedGroupStringList.Free;
 NamedGroupStringIntegerPairHashMap.Free;
 NamedGroupStringIndexList.Free;

 RangeLow:='';
 RangeHigh:='';

 PrefilterRootNode.Free;

 inherited Destroy;
end;

function TFLRE.NewCharClass(const CharClass:TFLRECharClass;const FromRegularExpression:boolean):TFLREInt32;
begin
 if FromRegularExpression then begin
  RegularExpressionHasCharClasses:=true;
 end;
 result:=CharClassHashMap.GetValue(CharClass);
 if result<0 then begin
  result:=CountCharClasses;
  inc(CountCharClasses);
  if CountCharClasses>length(CharClasses) then begin
   SetLength(CharClasses,CountCharClasses*2);
  end;
  GetMem(CharClasses[result],SizeOf(TFLRECharClass));
  CharClasses[result]^:=CharClass;
  CharClassHashMap.Add(CharClass,result);
 end;
end;

function TFLRE.GetCharClass(const CharClass:TFLREInt32):TFLRECharClass;
begin
 if (CharClass>=0) and (CharClass<CountCharClasses) then begin
  result:=CharClasses[CharClass]^;
 end else begin
  result:=[];
 end;
end;

function TFLRE.NewNode(const NodeType:TFLREInt32;const Left,Right:PFLRENode;const Value:TFLREInt32):PFLRENode;
begin
 GetMem(result,SizeOf(TFLRENode));
 FillChar(result^,SizeOf(TFLRENode),#0);
 result^.NodeType:=NodeType;
 result^.Left:=Left;
 result^.Right:=Right;
 result^.Value:=Value;
 result^.Index:=Nodes.Add(result);
end;

procedure TFLRE.FreeNode(var Node:PFLRENode);
begin
 if assigned(Node) then begin
  if assigned(Node^.Left) then begin
   FreeNode(Node^.Left);
  end;
  if assigned(Node^.Right) then begin
   FreeNode(Node^.Right);
  end;
  FreeMem(Node);
  Node:=nil;
 end;
end;

function TFLRE.CopyNode(Node:PFLRENode):PFLRENode;
begin
 if assigned(Node) then begin
  result:=NewNode(Node^.NodeType,nil,nil,Node^.Value);
  result^.Flags:=Node^.Flags;
  result^.Group:=Node^.Group;
  result^.Name:=Node^.Name;
  if assigned(Node^.Left) then begin
   result^.Left:=CopyNode(Node^.Left);
  end;
  if assigned(Node^.Right) then begin
   result^.Right:=CopyNode(Node^.Right);
  end;
 end else begin
  result:=nil;
 end;
end;

// Mark-and-sweep garbage collector for freeing unused nodes
procedure TFLRE.FreeUnusedNodes(RootNode:PFLRENode);
var Index,Count:TFLREInt32;
    Visited:TFLRENodeHashSet;
    Stack:TFLREPointerList;
    Node:PFLRENode;
begin
 Visited:=TFLRENodeHashSet.Create;
 try
  Count:=0;
  Stack:=TFLREPointerList.Create;
  try
   Stack.Add(RootNode);
   while Stack.Count>0 do begin
    Node:=Stack[Stack.Count-1];
    Stack.Delete(Stack.Count-1);
    if assigned(Node) then begin
     Visited.Add(Node);
     inc(Count);
     if assigned(Node^.Left) and not Visited.Contains(Node^.Left) then begin
      Stack.Add(Node^.Left);
     end;
     if assigned(Node^.Right) and not Visited.Contains(Node^.Right) then begin
      Stack.Add(Node^.Right);
     end;
    end;
   end;
  finally
   Stack.Free;
  end;
  if Count<>Nodes.Count then begin
   Index:=0;
   while Index<Nodes.Count do begin
    Node:=Nodes[Index];
    Node^.Index:=Index;
    if Visited.Contains(Node) then begin
     inc(Index);
    end else begin
     Node^.Name:='';
     Finalize(Node^);
     FreeMem(Node);
     Nodes.Delete(Index);
    end;
   end;
  end;
 finally
  Visited.Free;
 end;
end;

function TFLRE.AreNodesEqual(NodeA,NodeB:PFLRENode):boolean;
begin
 result:=(NodeA=NodeB) or
         ((((assigned(NodeA) and assigned(NodeB))) and
          ((NodeA^.NodeType=NodeB^.NodeType) and
           ((NodeA^.Value=NodeB^.Value) and
            (NodeA^.Flags=NodeB^.Flags) and
            (NodeA^.Group=NodeB^.Group) and
            (AreNodesEqual(NodeA^.Left,NodeB^.Left) and AreNodesEqual(NodeA^.Right,NodeB^.Right))))) or
          not (assigned(NodeA) or assigned(NodeB)));
end;

function TFLRE.AreNodesEqualSafe(NodeA,NodeB:PFLRENode):boolean;
begin
 result:=(NodeA=NodeB) or
         ((((assigned(NodeA) and assigned(NodeB))) and
           (((NodeA^.NodeType=NodeB^.NodeType) and not (NodeB^.NodeType in [ntPAREN])) and
            ((NodeA^.Value=NodeB^.Value) and
             (NodeA^.Flags=NodeB^.Flags) and
             (NodeA^.Group=NodeB^.Group) and
             (AreNodesEqualSafe(NodeA^.Left,NodeB^.Left) and
              AreNodesEqualSafe(NodeA^.Right,NodeB^.Right))))) or
          not (assigned(NodeA) or assigned(NodeB)));
end;

// More infos to this see: Xing2004 "A Simple Way to Construct NFA with Fewer States and Transitions"
function TFLRE.IsStarNullable(Node:PFLRENode):boolean;
begin
 if assigned(Node) then begin
  case Node^.NodeType of
   ntSTAR:begin
    result:=Node^.Value=qkGREEDY;
   end;
   ntALT:begin
    result:=(IsStarNullable(Node^.Left) or IsStarNullable(Node^.Right)) or not (assigned(Node^.Left) and assigned(Node^.Right));
   end;
   ntCAT:begin
    result:=IsStarNullable(Node^.Left) and IsStarNullable(Node^.Right);
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

// More infos to this see: Xing2004 "A Simple Way to Construct NFA with Fewer States and Transitions"
function TFLRE.StarDenull(Node:PFLRENode):PFLRENode;
begin
 result:=Node;
 if IsStarNullable(result) then begin
  case result^.NodeType of
   ntSTAR:begin
    result:=result^.Left;
   end;
   ntCAT:begin
    result^.NodeType:=ntALT;
    result^.Left:=StarDenull(result^.Left);
    result^.Right:=StarDenull(result^.Right);
   end;
   ntALT:begin
    result^.Left:=StarDenull(result^.Left);
    result^.Right:=StarDenull(result^.Right);
   end;
  end;
 end;
end;

function TFLRE.Concat(NodeLeft,NodeRight:PFLRENode):PFLRENode;
 function ConcatEqualPlus(const NodeLeftMightBecomeCat,PlusNodeRight:PFLRENode):PFLRENode;
 begin
  if (NodeLeftMightBecomeCat^.NodeType=ntPLUS) and
     assigned(NodeLeftMightBecomeCat^.Right) and
     (PlusNodeRight^.NodeType=ntPLUS) then begin
   NodeLeftMightBecomeCat^.NodeType:=ntCAT;
   NodeLeftMightBecomeCat^.Right:=PlusNodeRight;
   result:=NodeLeftMightBecomeCat;
  end else begin
   result:=PlusNodeRight;
  end;
 end;
begin
 if assigned(NodeLeft) and assigned(NodeRight) then begin
  if (NodeLeft^.NodeType=ntZEROWIDTH) and (NodeRight^.NodeType=ntZEROWIDTH) then begin
   NodeLeft^.Value:=NodeLeft^.Value or NodeRight^.Value;
   result:=NodeLeft;
  end else if ((NodeLeft^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (NodeRight^.NodeType=ntPLUS)) and AreNodesEqualSafe(NodeLeft^.Left,NodeRight^.Left) and (NodeLeft^.Value=0) and (NodeRight^.Value=0) then begin
   result:=ConcatEqualPlus(NodeLeft,NodeRight);
  end else if ((NodeLeft^.NodeType in [ntSTAR,ntPLUS]) and (NodeRight^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(NodeLeft^.Left,NodeRight^.Left) and (NodeLeft^.Value=0) and (NodeRight^.Value=0) then begin
   result:=NodeLeft;
  end else if (NodeLeft^.NodeType=ntCAT) and assigned(NodeLeft^.Left) and assigned(NodeLeft^.Right) then begin
   if (NodeLeft^.Right^.NodeType=ntZEROWIDTH) and (NodeRight^.NodeType=ntZEROWIDTH) then begin
    NodeLeft^.Right^.Value:=NodeLeft^.Right^.Value or NodeRight^.Value;
    result:=NodeLeft;
   end else if ((NodeLeft^.Right^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (NodeRight^.NodeType=ntPLUS)) and AreNodesEqualSafe(NodeLeft^.Right^.Left,NodeRight^.Left) and (NodeLeft^.Right^.Value=0) and (NodeRight^.Value=0) then begin
    NodeLeft^.Right:=ConcatEqualPlus(NodeLeft^.Right,NodeRight);
    result:=NodeLeft;
   end else if ((NodeLeft^.Right^.NodeType in [ntSTAR,ntPLUS]) and (NodeRight^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(NodeLeft^.Right^.Left,NodeRight^.Left) and (NodeLeft^.Right^.Value=0) and (NodeRight^.Value=0) then begin
    result:=NodeLeft;
   end else begin
    result:=NewNode(ntCAT,NodeLeft,NodeRight,0);
   end;
  end else begin
   result:=NewNode(ntCAT,NodeLeft,NodeRight,0);
  end;
 end else begin
  if assigned(NodeLeft) then begin
   result:=NodeLeft;
  end else if assigned(NodeRight) then begin
   result:=NodeRight;
  end else begin
   result:=nil;
  end;
 end;
 if not (rfONLYFASTOPTIMIZATIONS in Flags) then begin
  while (assigned(result) and (result^.NodeType=ntCAT)) and (assigned(result^.Left) and assigned(result^.Right)) do begin
   if (result^.Left^.NodeType=ntCAT) and (result^.Right^.NodeType=ntZEROWIDTH) and assigned(result^.Left^.Right) and (result^.Left^.Right^.NodeType=ntZEROWIDTH) then begin
    result^.Left^.Right^.Value:=result^.Left^.Right^.Value or result^.Right^.Value;
    result:=result^.Left;
    continue;
   end else if (result^.Left^.NodeType=ntZEROWIDTH) and (result^.Right^.NodeType=ntCAT) and assigned(result^.Right^.Left) and (result^.Right^.Left^.NodeType=ntZEROWIDTH) then begin
    result^.Right^.Left^.Value:=result^.Right^.Left^.Value or result^.Left^.Value;
    result:=result^.Right;
    continue;
   end else if (result^.Left^.NodeType=ntCAT) and (result^.Right^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and assigned(result^.Left^.Right) and (result^.Right^.Value=0) then begin
    if ((result^.Left^.Right^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Right^.NodeType=ntPLUS)) and AreNodesEqualSafe(result^.Left^.Right^.Left,result^.Right^.Left) then begin
     result^.Left^.Right:=ConcatEqualPlus(result^.Left^.Right,result^.Right);
     result:=result^.Left;
     continue;
    end else if ((result^.Left^.Right^.NodeType in [ntSTAR,ntPLUS]) and (result^.Right^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(result^.Left^.Right^.Left,result^.Right^.Left) then begin
     result:=result^.Left;
     continue;
    end;
   end else if (result^.Left^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Right^.NodeType=ntCAT) and assigned(result^.Right^.Left) and (result^.Left^.Value=0) then begin
    if ((result^.Left^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Right^.Left^.NodeType=ntPLUS)) and AreNodesEqualSafe(result^.Left^.Left,result^.Right^.Left^.Left) and (result^.Right^.Left^.Value=0) then begin
     if (result^.Left^.NodeType=ntPLUS) and assigned(result^.Left^.Right) then begin
      result^.Left:=result^.Left^.Left;
     end else begin
      result:=result^.Right;
     end;
     continue;
    end else if ((result^.Left^.NodeType in [ntSTAR,ntPLUS]) and (result^.Right^.Left^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(result^.Left^.Left,result^.Right^.Left^.Left) and (result^.Right^.Left^.Value=0) then begin
     result^.Right^.Left:=result^.Left;
     result:=result^.Right;
     continue;
    end;
   end else if (result^.Left^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Right^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Left^.Value=0) and (result^.Right^.Value=0) then begin
    if ((result^.Left^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (result^.Right^.NodeType=ntPLUS)) and AreNodesEqualSafe(result^.Left^.Left,result^.Right^.Left) then begin
     if (result^.Left^.NodeType=ntPLUS) and assigned(result^.Left^.Right) then begin
      result^.Left:=result^.Left^.Left;
     end else begin
      result:=result^.Right;
     end;
     continue;
    end else if ((result^.Left^.NodeType in [ntSTAR,ntPLUS]) and (result^.Right^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(result^.Left^.Left,result^.Right^.Left) then begin
     result:=result^.Left;
     continue;
    end;
   end;
   break;
  end;
 end;
end;

function TFLRE.NewEmptyMatch:PFLRENode;
begin
 result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyMatch);
end;

function TFLRE.NewAlt(NodeLeft,NodeRight:PFLRENode):PFLRENode;
var NodeEx,pl,pr:PPFLRENode;
    Node,l,r:PFLRENode;
begin
 if assigned(NodeLeft) and assigned(NodeRight) then begin
  if (NodeLeft^.NodeType=ntCAT) and (NodeRight^.NodeType=ntCAT) and not (rfONLYFASTOPTIMIZATIONS in Flags) then begin
   result:=NewNode(ntALT,NodeLeft,NodeRight,0);
   NodeEx:=@result;
   while (((assigned(NodeEx) and assigned(NodeEx^)) and (NodeEx^^.NodeType=ntALT)) and (assigned(NodeEx^^.Left) and assigned(NodeEx^^.Right))) and ((NodeEx^^.Left^.NodeType=ntCAT) and (NodeEx^^.Right^.NodeType=ntCAT)) do begin
    Node:=NodeEx^;
    pl:=@Node^.Left;
    l:=Node^.Left;
    while (assigned(l) and assigned(l^.Left)) and (l^.Left^.NodeType=ntCAT) do begin
     pl:=@l^.Left;
     l:=l^.Left;
    end;
    pr:=@Node^.Right;
    r:=Node^.Right;
    while (assigned(r) and assigned(r^.Left)) and (r^.Left^.NodeType=ntCAT) do begin
     pr:=@r^.Left;
     r:=r^.Left;
    end;
    if ((assigned(l^.Left) and assigned(l^.Right)) and (assigned(r^.Left) and assigned(r^.Right))) and AreNodesEqualSafe(l^.Left,r^.Left) then begin
     NodeEx^:=l;
     pl^:=l^.Right;
     pr^:=r^.Right;
     l^.Right:=Node;
     NodeEx:=@l^.Right;
     continue;
    end;
    break;
   end;
  end else if AreNodesEqualSafe(NodeLeft,NodeRight) then begin
   result:=NodeLeft;
  end else if (NodeLeft^.NodeType=ntCHAR) and (NodeRight^.NodeType=ntCHAR) then begin
   result:=NewNode(ntCHAR,nil,nil,NewCharClass(GetCharClass(NodeLeft^.Value)+GetCharClass(NodeRight^.Value),true));
  end else begin
   result:=NewNode(ntALT,NodeLeft,NodeRight,0);
  end;
 end else begin
  if assigned(NodeLeft) then begin
   result:=NodeLeft;
  end else if assigned(NodeRight) then begin
   result:=NodeRight;
  end else begin
   result:=nil;
  end;
 end;
end;

{ * (a*)* equals a*
  * (a+)+ equals a+
  * (a?)? equals a?
  * (a*)+ equals (a+)* equals a*
  * (a*)? equals (a?)* equals a*
  * (a+)? equals (a?)+ equals a*
}
function TFLRE.NewPlus(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
begin
 if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntPAREN)) and ((assigned(Node^.Left) and (Node^.Left^.NodeType in [ntPLUS,ntSTAR])) and (Node^.Left^.Value=qkGREEDY))) then begin
  result:=Node;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntPLUS)) and (Node^.Value=qkGREEDY)) then begin
  result:=Node;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType in [ntSTAR,ntQUEST])) and (Node^.Value=qkGREEDY)) then begin
  result:=Node;
  result^.NodeType:=ntSTAR;
 end else begin
  result:=NewNode(ntPLUS,Node,nil,Kind);
 end;
end;

function TFLRE.NewStar(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
begin
  if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntPAREN)) and ((assigned(Node^.Left) and (Node^.Left^.NodeType in [ntSTAR,ntPLUS{,ntQUEST}])) and (Node^.Left^.Value=qkGREEDY))) then begin
  result:=Node;
  result^.Left^.NodeType:=ntSTAR;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType in [ntPLUS,ntQUEST,ntSTAR])) and (Node^.Value=qkGREEDY)) then begin
  result:=Node;
  result^.NodeType:=ntSTAR;
 end else begin
  result:=NewNode(ntSTAR,StarDenull(Node),nil,Kind);
 end;
end;

function TFLRE.NewQuest(Node:PFLRENode;Kind:TFLREInt32):PFLRENode;
begin
 if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntPAREN)) and ((assigned(Node^.Left) and (Node^.Left^.NodeType=ntQUEST)) and (Node^.Left^.Value=qkGREEDY))) then begin
  result:=Node;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntPAREN)) and ((assigned(Node^.Left) and (Node^.Left^.NodeType in [ntSTAR,ntPLUS{,ntQUEST}])) and (Node^.Left^.Value=qkGREEDY))) then begin
  result:=Node;
  result^.Left^.NodeType:=ntSTAR;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType=ntQUEST)) and (Node^.Value=qkGREEDY)) then begin
  result:=Node;
 end else if (Kind=qkGREEDY) and ((assigned(Node) and (Node^.NodeType in [ntPLUS,ntSTAR])) and (Node^.Value=qkGREEDY)) then begin
  result:=Node;
  result^.NodeType:=ntSTAR;
 end else begin
  result:=NewNode(ntQUEST,Node,nil,Kind);
 end;
end;

function TFLRE.NewExact(Node:PFLRENode;MinCount,MaxCount,Kind:TFLREInt32):PFLRENode;
var Counter:TFLREInt32;
    OptionalNode:PFLRENode;
begin
 begin
  // Limiting repetition counts to FLREMaximalRepetitionCount for to avoid memory-wasting vulnerabilities
  if MinCount>FLREMaximalRepetitionCount then begin
   MinCount:=FLREMaximalRepetitionCount;
  end;
  if MaxCount>FLREMaximalRepetitionCount then begin
   MaxCount:=FLREMaximalRepetitionCount;
  end;
 end;
 if (MinCount>=0) and (MaxCount<0) then begin
  case MinCount of
   0:begin
    // x{0,} is x*
    result:=NewStar(StarDenull(Node),Kind);
   end;
   1:begin
    // x{1,} is x+
    result:=NewPlus(Node,Kind);
   end;
   else begin
    // x{2,} is xx+, x{3,} is xxx+, x{4,} is xxxx+ and so on...
    result:=Node;
    for Counter:=3 to MinCount do begin
     result:=Concat(result,CopyNode(Node));
    end;
    result:=Concat(result,NewPlus(CopyNode(Node),Kind));
   end;
  end;
 end else if (MinCount=0) and (MaxCount=0) then begin
  // x{0,0} is nothing
  result:=NewEmptyMatch;
 end else if (MinCount=0) and (MaxCount=1) then begin
  // x{0,1} is x?
  result:=NewQuest(Node,Kind);
 end else if (MinCount=1) and (MaxCount=1) then begin
  // x{1,1} is just x
  result:=Node;
 end else if (MinCount>0) and (MinCount=MaxCount) then begin
  // x{n,m}, when where n equals to m, is n-multiple x
  result:=Node;
  for Counter:=2 to MaxCount do begin
   result:=Concat(result,CopyNode(Node));
  end;
 end else if (MinCount>=0) and (MinCount<MaxCount) then begin
  // x{n,m} is n-multiple x + m-multiple x?
  if MinCount=0 then begin
   result:=nil;
  end else begin
   result:=Node;
   for Counter:=2 to MinCount do begin
    result:=Concat(result,CopyNode(Node));
   end;
  end;
  if MaxCount>MinCount then begin
   OptionalNode:=NewQuest(CopyNode(Node),Kind);
   for Counter:=MinCount+2 to MaxCount do begin
    OptionalNode:=NewQuest(Concat(CopyNode(Node),OptionalNode),Kind);
   end;
   result:=Concat(result,OptionalNode);
  end;
 end else begin
  // Oops, this should never happen, so cases like min > max, or min < max < 0, but the parser rejects such cases.
  result:=Node;
  raise EFLRE.Create('Syntax error');
 end;
end;

function TFLRE.OptimizeNode(StartNodeEx:PPFLRENode):boolean;
 procedure ParseNodes(NodeList:TFLREPointerList;n:PFLRENode;NodeType:TFLREInt32);
 begin
  while assigned(n) do begin
   if n^.NodeType=NodeType then begin
    if assigned(n^.Right) then begin
     if n^.Right^.NodeType=NodeType then begin
      ParseNodes(NodeList,n^.Right,NodeType);
     end else begin
      NodeList.Add(n^.Right);
     end;
    end;
    if assigned(n^.Left) then begin
     if n^.Left^.NodeType=NodeType then begin
      n:=n^.Left;
     end else begin
      NodeList.Add(n^.Left);
      break;
     end;
    end else begin
     break;
    end;
   end else begin
    NodeList.Add(n);
    break;
   end;
  end;
 end;
 function CreateOrClearList(const aList:TFLREPointerList):TFLREPointerList;
 begin
  if assigned(aList) then begin
   result:=aList;
   result.Clear;
  end else begin
   result:=TFLREPointerList.Create;
  end;
 end;
 function CreateOrClearNodeHashSet(const aNodeHashSet:TFLRENodeHashSet):TFLRENodeHashSet;
 begin
  if assigned(aNodeHashSet) then begin
   result:=aNodeHashSet;
   result.Clear;
  end else begin
   result:=TFLRENodeHashSet.Create;
  end;
 end;
var NodeEx:PPFLRENode;
    Node,SeedNode,TestNode,l,r,Prefix,Suffix,Alternative,TempNode:PFLRENode;
    pr,pl:PPFLRENode;
    HasOptimizations,DoContinue,Optimized:boolean;
    Visited:TFLRENodeHashSet;
    NodeStack,NodeList,NodeListLeft,TempNodeList,NewNodeList:TFLREPointerList;
    NodeIndex,SubNodeIndex,NewNodeIndex:TFLREInt32;
begin
 result:=false;
 Visited:=nil;
 NodeList:=nil;
 NewNodeList:=nil;
 TempNodeList:=nil;
 NodeListLeft:=nil;
 NodeStack:=TFLREPointerList.Create;
 try
  repeat
   HasOptimizations:=false;
   NodeStack.Clear;
   NodeStack.Add(StartNodeEx);
   while NodeStack.Count>0 do begin
    NodeEx:=NodeStack[NodeStack.Count-1];
    NodeStack.Delete(NodeStack.Count-1);
    repeat
     Node:=NodeEx^;
     if assigned(Node) then begin
      case Node^.NodeType of
       ntCHAR,ntZEROWIDTH,ntLOOKBEHINDNEGATIVE,ntLOOKBEHINDPOSITIVE,ntLOOKAHEADNEGATIVE,ntLOOKAHEADPOSITIVE,ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
       end;
       ntPAREN:begin
        NodeEx:=@Node^.Left;
        continue;
       end;
       ntPLUS:begin
        if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntPAREN)) and (assigned(Node^.Left^.Left) and (Node^.Left^.Left^.NodeType in [ntPLUS,ntSTAR])) and ((Node^.Left^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntPLUS)) and ((Node^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType in [ntSTAR,ntQUEST])) and ((Node^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         NodeEx^^.NodeType:=ntSTAR;
         HasOptimizations:=true;
         continue;
        end else begin
         NodeEx:=@Node^.Left;
         continue;
        end;
       end;
       ntSTAR:begin
        if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntPAREN)) and (assigned(Node^.Left^.Left) and (Node^.Left^.Left^.NodeType in [ntSTAR,ntPLUS{,ntQUEST}])) and ((Node^.Left^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         NodeEx^^.Left^.NodeType:=ntSTAR;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType in [ntPLUS,ntQUEST,ntSTAR])) and ((Node^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         NodeEx^^.NodeType:=ntSTAR;
         HasOptimizations:=true;
         continue;
        end else begin
         if IsStarNullable(Node^.Left) then begin
          Node^.Left:=StarDenull(Node^.Left);
          HasOptimizations:=true;
         end;
         NodeEx:=@Node^.Left;
         continue;
        end;
       end;
       ntQUEST:begin
        if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntPAREN)) and (assigned(Node^.Left^.Left) and (Node^.Left^.Left^.NodeType=ntQUEST)) and ((Node^.Left^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntPAREN)) and (assigned(Node^.Left^.Left) and (Node^.Left^.Left^.NodeType in [ntSTAR,ntPLUS{,ntQUEST}])) and ((Node^.Left^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         NodeEx^^.Left^.NodeType:=ntSTAR;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType=ntQUEST)) and ((Node^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         HasOptimizations:=true;
         continue;
        end else if (assigned(Node^.Left) and (Node^.Left^.NodeType in [ntPLUS,ntSTAR])) and ((Node^.Left^.Value=qkGREEDY) and (Node^.Value=qkGREEDY)) then begin
         NodeEx^:=Node^.Left;
         NodeEx^^.NodeType:=ntSTAR;
         HasOptimizations:=true;
         continue;
        end else begin
         NodeEx:=@Node^.Left;
         continue;
        end;
       end;
       ntCAT:begin
        if assigned(Node^.Left) and assigned(Node^.Right) then begin
         if (Node^.Left^.NodeType=ntZEROWIDTH) and (Node^.Right^.NodeType=ntZEROWIDTH) then begin
          Node^.Left^.Value:=Node^.Left^.Value or Node^.Right^.Value;
          NodeEx^:=Node^.Left;
          HasOptimizations:=true;
          continue;
         end else if ((Node^.Left^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (Node^.Right^.NodeType=ntPLUS)) and AreNodesEqual(Node^.Left^.Left,Node^.Right^.Left) then begin
          if Node^.Left^.NodeType=ntPLUS then begin
           Node^.Left:=Node^.Left^.Left;
          end else begin
           NodeEx^:=Node^.Right;
          end;
          HasOptimizations:=true;
          continue;
         end else if ((Node^.Left^.NodeType in [ntSTAR,ntPLUS]) and (Node^.Right^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqual(Node^.Left^.Left,Node^.Right^.Left) then begin
          NodeEx^:=Node^.Left;
          HasOptimizations:=true;
          continue;
         end else begin
          NodeList:=CreateOrClearList(NodeList);
          begin
           ParseNodes(NodeList,Node,ntCAT);
           Optimized:=false;
           DoContinue:=true;
           while DoContinue do begin
            DoContinue:=false;
            NodeIndex:=NodeList.Count-1;
            while NodeIndex>0 do begin
             l:=PFLRENode(NodeList[NodeIndex]);
             r:=PFLRENode(NodeList[NodeIndex-1]);
             if (l^.NodeType=ntZEROWIDTH) and (r^.NodeType=ntZEROWIDTH) then begin
              l^.Value:=l^.Value or r^.Value;
              NodeList.Delete(NodeIndex-1);
              if NodeIndex>=NodeList.Count then begin
               NodeIndex:=NodeList.Count-1;
              end;
              DoContinue:=true;
              Optimized:=true;
             end else if ((l^.NodeType in [ntSTAR,ntPLUS,ntQUEST]) and (r^.NodeType=ntPLUS)) and AreNodesEqualSafe(l^.Left,r^.Left) then begin
              if l^.NodeType=ntPLUS then begin
               NodeList[NodeIndex]:=l^.Left;
              end else begin
               NodeList.Delete(NodeIndex);
               if NodeIndex>=NodeList.Count then begin
                NodeIndex:=NodeList.Count-1;
               end;
              end;
              DoContinue:=true;
              Optimized:=true;
             end else if ((l^.NodeType in [ntSTAR,ntPLUS]) and (r^.NodeType in [ntSTAR,ntQUEST])) and AreNodesEqualSafe(l^.Left,r^.Left) then begin
              NodeList.Delete(NodeIndex-1);
              if NodeIndex>=NodeList.Count then begin
               NodeIndex:=NodeList.Count-1;
              end;
              DoContinue:=true;
              Optimized:=true;
             end else begin
              dec(NodeIndex);
             end;
            end;
           end;
           if Optimized and (NodeList.Count>0) then begin
            NodeEx^:=NodeList[NodeList.Count-1];
            for NodeIndex:=NodeList.Count-2 downto 0 do begin
             NodeEx^:=NewNode(ntCAT,NodeEx^,NodeList[NodeIndex],0);
            end;
            DoContinue:=true;
            HasOptimizations:=true;
           end;
          end;
          if DoContinue then begin
           continue;
          end else if not Optimized then begin
           NodeStack.Add(@Node^.Right);
           NodeEx:=@Node^.Left;
           continue;
          end;
         end;
        end else begin
         NodeStack.Add(@Node^.Right);
         NodeEx:=@Node^.Left;
         continue;
        end;
       end;
       ntALT:begin
        if assigned(Node^.Left) and assigned(Node^.Right) then begin
         if AreNodesEqualSafe(Node^.Left,Node^.Right) then begin
          NodeEx^:=Node^.Left;
          HasOptimizations:=true;
          continue;
         end else if (Node^.Left^.NodeType=ntALT) or (Node^.Right^.NodeType=ntALT) then begin
          begin
           // Prefix factoring
           Optimized:=false;
           repeat
            DoContinue:=false;
            NodeList:=CreateOrClearList(NodeList);
            begin
             ParseNodes(NodeList,Node,ntALT);
             NewNodeList:=CreateOrClearList(NewNodeList);
             begin
              Visited:=CreateOrClearNodeHashSet(Visited);
              begin
               for NodeIndex:=NodeList.Count-1 downto 0 do begin
                SeedNode:=NodeList[NodeIndex];
                if not Visited.Contains(SeedNode) then begin
                 Visited.Add(SeedNode);
                 TempNodeList:=CreateOrClearList(TempNodeList);
                 begin
                  TempNodeList.Add(SeedNode);
                  l:=SeedNode;
                  while assigned(l) and (l^.NodeType=ntCAT) do begin
                   l:=l^.Left;
                  end;
                  for SubNodeIndex:=NodeIndex-1 downto 0 do begin
                   TestNode:=NodeList[SubNodeIndex];
                   if not Visited.Contains(TestNode) then begin
                    r:=TestNode;
                    while assigned(r) and (r^.NodeType=ntCAT) do begin
                     r:=r^.Left;
                    end;
                    if (assigned(l) and assigned(r)) and AreNodesEqualSafe(l,r) then begin
                     Visited.Add(TestNode);
                     TempNodeList.Add(TestNode);
                    end;
                   end;
                  end;
                  if TempNodeList.Count>1 then begin
                   Prefix:=l;
                   Alternative:=nil;
                   for SubNodeIndex:=0 to TempNodeList.Count-1 do begin
                    TestNode:=TempNodeList[SubNodeIndex];
                    NodeListLeft:=CreateOrClearList(NodeListLeft);
                    begin
                     ParseNodes(NodeListLeft,TestNode,ntCAT);
                     NodeListLeft.Delete(NodeListLeft.Count-1);
                     if NodeListLeft.Count>0 then begin
                      TempNode:=NodeListLeft[NodeListLeft.Count-1];
                      for NewNodeIndex:=NodeListLeft.Count-2 downto 0 do begin
                       TempNode:=NewNode(ntCAT,TempNode,NodeListLeft[NewNodeIndex],0);
                      end;
                      Alternative:=NewAlt(Alternative,TempNode);
                     end else begin
                      TempNode:=NewNode(ntZEROWIDTH,nil,nil,0);
                      Alternative:=NewAlt(Alternative,TempNode);
                     end;
                    end;
                   end;
                   TempNode:=Concat(Prefix,Alternative);
                   if assigned(TempNode) then begin
                    NewNodeList.Add(TempNode);
                   end;
                   DoContinue:=true;
                   Optimized:=true;
                  end else begin
                   NewNodeList.Add(SeedNode);
                  end;
                 end;
                end;
               end;
              end;
              if DoContinue and (NewNodeList.Count>0) then begin
               NodeEx^:=NewNodeList[0];
               for NodeIndex:=1 to NewNodeList.Count-1 do begin
                NodeEx^:=NewNode(ntALT,NodeEx^,NewNodeList[NodeIndex],0);
               end;
               Node:=NodeEx^;
              end;
             end;
            end;
           until not DoContinue;
           if Optimized then begin
            HasOptimizations:=true;
            continue;
           end;
          end;
          begin
           // Suffix factoring
           Optimized:=false;
           repeat
            DoContinue:=false;
            NodeList:=CreateOrClearList(NodeList);
            begin
             ParseNodes(NodeList,Node,ntALT);
             NewNodeList:=CreateOrClearList(NewNodeList);
             begin
              Visited:=CreateOrClearNodeHashSet(Visited);
              begin
               for NodeIndex:=NodeList.Count-1 downto 0 do begin
                SeedNode:=NodeList[NodeIndex];
                if not Visited.Contains(SeedNode) then begin
                 Visited.Add(SeedNode);
                 TempNodeList:=CreateOrClearList(TempNodeList);
                 begin
                  TempNodeList.Add(SeedNode);
                  l:=SeedNode;
                  while assigned(l) and (l^.NodeType=ntCAT) do begin
                   l:=l^.Right;
                  end;
                  for SubNodeIndex:=NodeIndex-1 downto 0 do begin
                   TestNode:=NodeList[SubNodeIndex];
                   if not Visited.Contains(TestNode) then begin
                    r:=TestNode;
                    while assigned(r) and (r^.NodeType=ntCAT) do begin
                     r:=r^.Right;
                    end;
                    if (assigned(l) and assigned(r)) and AreNodesEqualSafe(l,r) then begin
                     Visited.Add(TestNode);
                     TempNodeList.Add(TestNode);
                    end;
                   end;
                  end;
                  if TempNodeList.Count>1 then begin
                   Suffix:=l;
                   Alternative:=nil;
                   for SubNodeIndex:=0 to TempNodeList.Count-1 do begin
                    TestNode:=TempNodeList[SubNodeIndex];
                    NodeListLeft:=CreateOrClearList(NodeListLeft);
                    begin
                     ParseNodes(NodeListLeft,TestNode,ntCAT);
                     NodeListLeft.Delete(0);
                     if NodeListLeft.Count>0 then begin
                      TempNode:=NodeListLeft[NodeListLeft.Count-1];
                      for NewNodeIndex:=NodeListLeft.Count-2 downto 0 do begin
                       TempNode:=NewNode(ntCAT,TempNode,NodeListLeft[NewNodeIndex],0);
                      end;
                      Alternative:=NewAlt(Alternative,TempNode);
                     end else begin
                      TempNode:=NewNode(ntZEROWIDTH,nil,nil,0);
                      Alternative:=NewAlt(Alternative,TempNode);
                     end;
                    end;
                   end;                               
                   TempNode:=Concat(Alternative,Suffix);
                   if assigned(TempNode) then begin
                    NewNodeList.Add(TempNode);
                   end;
                   DoContinue:=true;
                   Optimized:=true;
                  end else begin
                   NewNodeList.Add(SeedNode);
                  end;
                 end;
                end;
               end;
              end;
              if DoContinue and (NewNodeList.Count>0) then begin
               NodeEx^:=NewNodeList[0];
               for NodeIndex:=1 to NewNodeList.Count-1 do begin
                NodeEx^:=NewNode(ntALT,NodeEx^,NewNodeList[NodeIndex],0);
               end;
               Node:=NodeEx^;
              end;
             end;
            end;
           until not DoContinue;
           if Optimized then begin
            HasOptimizations:=true;
            continue;
           end;
          end;
          begin
           NodeStack.Add(@Node^.Right);
           NodeEx:=@Node^.Left;
           continue;
          end;
         end else if (Node^.Left^.NodeType=ntCAT) and (Node^.Right^.NodeType=ntCAT) then begin
          pl:=@Node^.Left;
          l:=Node^.Left;
          while (assigned(l) and assigned(l^.Left)) and (l^.Left^.NodeType=ntCAT) do begin
           pl:=@l^.Left;
           l:=l^.Left;
          end;
          pr:=@Node^.Right;
          r:=Node^.Right;
          while (assigned(r) and assigned(r^.Left)) and (r^.Left^.NodeType=ntCAT) do begin
           pr:=@r^.Left;
           r:=r^.Left;
          end;
          if ((assigned(l^.Left) and assigned(l^.Right)) and (assigned(r^.Left) and assigned(r^.Right))) and AreNodesEqualSafe(l^.Left,r^.Left) then begin
           NodeEx^:=l;
           pl^:=l^.Right;
           pr^:=r^.Right;
           l^.Right:=Node;
           HasOptimizations:=true;
           continue;
          end else begin
           NodeStack.Add(@Node^.Right);
           NodeEx:=@Node^.Left;
           continue;
          end;
         end else if (Node^.Left^.NodeType=ntCHAR) and (Node^.Right^.NodeType=ntCHAR) then begin
          Node^.NodeType:=ntCHAR;
          Node^.Value:=NewCharClass(GetCharClass(Node^.Left^.Value)+GetCharClass(Node^.Right^.Value),true);
          Node^.Left:=nil;
          Node^.Right:=nil;
          HasOptimizations:=true;
          continue;
         end else begin
          NodeStack.Add(@Node^.Right);
          NodeEx:=@Node^.Left;
          continue;
         end;
        end else begin
         NodeStack.Add(@Node^.Right);
         NodeEx:=@Node^.Left;
         continue;
        end;
       end;
      end;
     end;
     break;
    until false;
   end;
   if HasOptimizations then begin
    result:=true;
   end else begin
    break;
   end;
  until false;
 finally
  FreeAndNil(NodeStack);
  FreeAndNil(NodeList);
  FreeAndNil(NewNodeList);
  FreeAndNil(TempNodeList);
  FreeAndNil(NodeListLeft);
  FreeAndNil(Visited);
 end;
end;

procedure TFLRE.Parse;
var SourcePosition,SourceLength:TFLRESizeInt;
    Source:TFLRERawByteString;
    GroupIndexIntegerStack:TFLREIntegerList;
    GroupNameStringStack:TStringList;
    BackReferenceComparisonGroup:boolean;
 function Hex2Value(const c:TFLRERawByteChar):TFLREUInt32;
 begin
  case c of
   '0'..'9':begin
    result:=TFLREUInt8(TFLRERawByteChar(c))-TFLREUInt8(TFLRERawByteChar('0'))
   end;
   'a'..'f':begin
    result:=(TFLREUInt8(TFLRERawByteChar(c))-TFLREUInt8(TFLRERawByteChar('a')))+$a;
   end;
   'A'..'F':begin
    result:=(TFLREUInt8(TFLRERawByteChar(c))-TFLREUInt8(TFLRERawByteChar('A')))+$a;
   end;
   else begin
    result:=0;
   end;
  end;
 end;
 function ParseDisjunction:PFLRENode; forward;
 procedure GetCharClassPerName(const Name:TFLRERawByteString;const UnicodeCharClass:TFLREUnicodeCharClass;const IgnoreCase,WithLowerCase:boolean);
 var i:TFLREInt32;
     f:TFLREInt64;
     LowerCaseName:TFLRERawByteString;
 begin
  if WithLowerCase then begin
   LowerCaseName:=UTF8LowerCase(Name);
  end else begin
   LowerCaseName:='';
  end;
  begin
   if WithLowerCase then begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeClassLowerCaseHashMapSeeds,
                                       @PUCUUnicodeClassLowerCaseHashMapKeys,
                                       @PUCUUnicodeClassLowerCaseHashMapValues,
                                       PUCUUnicodeClassLowerCaseHashMapSeedBits,
                                       PUCUUnicodeClassLowerCaseHashMapValueBits,
                                       PUCUUnicodeClassLowerCaseHashMapSize,
                                       LowerCaseName);
   end else begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeClassHashMapSeeds,
                                       @PUCUUnicodeClassHashMapKeys,
                                       @PUCUUnicodeClassHashMapValues,
                                       PUCUUnicodeClassHashMapSeedBits,
                                       PUCUUnicodeClassHashMapValueBits,
                                       PUCUUnicodeClassHashMapSize,
                                       Name);
   end;
   if f>0 then begin
    UnicodeCharClass.AddUnicodeCategory(f,IgnoreCase);
    UnicodeCharClass.Canonicalized:=true;
    exit;
   end;
  end;
  begin
   if WithLowerCase then begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeScriptLowerCaseHashMapSeeds,
                                       @PUCUUnicodeScriptLowerCaseHashMapKeys,
                                       @PUCUUnicodeScriptLowerCaseHashMapValues,
                                       PUCUUnicodeScriptLowerCaseHashMapSeedBits,
                                       PUCUUnicodeScriptLowerCaseHashMapValueBits,
                                       PUCUUnicodeScriptLowerCaseHashMapSize,
                                       LowerCaseName);
   end else begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeScriptHashMapSeeds,
                                       @PUCUUnicodeScriptHashMapKeys,
                                       @PUCUUnicodeScriptHashMapValues,
                                       PUCUUnicodeScriptHashMapSeedBits,
                                       PUCUUnicodeScriptHashMapValueBits,
                                       PUCUUnicodeScriptHashMapSize,
                                       Name);
   end;
   if f>0 then begin
    UnicodeCharClass.AddUnicodeScript(f,IgnoreCase);
    UnicodeCharClass.Canonicalized:=true;
    exit;
   end;
  end;
  begin
   if WithLowerCase then begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeBlockLowerCaseHashMapSeeds,
                                       @PUCUUnicodeBlockLowerCaseHashMapKeys,
                                       @PUCUUnicodeBlockLowerCaseHashMapValues,
                                       PUCUUnicodeBlockLowerCaseHashMapSeedBits,
                                       PUCUUnicodeBlockLowerCaseHashMapValueBits,
                                       PUCUUnicodeBlockLowerCaseHashMapSize,
                                       LowerCaseName);
   end else begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeBlockHashMapSeeds,
                                       @PUCUUnicodeBlockHashMapKeys,
                                       @PUCUUnicodeBlockHashMapValues,
                                       PUCUUnicodeBlockHashMapSeedBits,
                                       PUCUUnicodeBlockHashMapValueBits,
                                       PUCUUnicodeBlockHashMapSize,
                                       Name);
   end;
   if f>0 then begin
    UnicodeCharClass.AddUnicodeBlock(f,IgnoreCase);
    UnicodeCharClass.Canonicalized:=true;
    exit;
   end;
  end;
  begin
   if WithLowerCase then begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeAdditionalBlockLowerCaseHashMapSeeds,
                                       @PUCUUnicodeAdditionalBlockLowerCaseHashMapKeys,
                                       @PUCUUnicodeAdditionalBlockLowerCaseHashMapValues,
                                       PUCUUnicodeAdditionalBlockLowerCaseHashMapSeedBits,
                                       PUCUUnicodeAdditionalBlockLowerCaseHashMapValueBits,
                                       PUCUUnicodeAdditionalBlockLowerCaseHashMapSize,
                                       LowerCaseName);
   end else begin
    f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeAdditionalBlockHashMapSeeds,
                                       @PUCUUnicodeAdditionalBlockHashMapKeys,
                                       @PUCUUnicodeAdditionalBlockHashMapValues,
                                       PUCUUnicodeAdditionalBlockHashMapSeedBits,
                                       PUCUUnicodeAdditionalBlockHashMapValueBits,
                                       PUCUUnicodeAdditionalBlockHashMapSize,
                                       Name);
   end;
   if f>0 then begin
    UnicodeCharClass.AddUnicodeAdditionalBlock(f,IgnoreCase);
    UnicodeCharClass.Canonicalized:=true;
    exit;
   end;
  end;
  if (WithLowerCase and (LowerCaseName='alnum')) or
     ((not WithLowerCase) and (Name='Alnum')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory((1 shl PUCUUnicodeCategoryLu) or (1 shl PUCUUnicodeCategoryLl) or (1 shl PUCUUnicodeCategoryLt) or (1 shl PUCUUnicodeCategoryNd),IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange(ord('a'),ord('z'),IgnoreCase);
    UnicodeCharClass.AddRange(ord('A'),ord('Z'),IgnoreCase);
    UnicodeCharClass.AddRange(ord('0'),ord('9'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='alpha')) or
              ((not WithLowerCase) and (Name='Alpha')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory((1 shl PUCUUnicodeCategoryLu) or (1 shl PUCUUnicodeCategoryLl) or (1 shl PUCUUnicodeCategoryLt),IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange(ord('a'),ord('z'),IgnoreCase);
    UnicodeCharClass.AddRange(ord('A'),ord('Z'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='ascii')) or
              ((not WithLowerCase) and (Name='ASCII')) then begin
   UnicodeCharClass.AddRange($00,$7f,IgnoreCase);
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='blank')) or
              ((not WithLowerCase) and (Name='Blank')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory(1 shl PUCUUnicodeCategoryZs,IgnoreCase);
   end else begin
    UnicodeCharClass.AddChar(9,IgnoreCase);
    UnicodeCharClass.AddChar(32,IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='cntrl')) or
              ((not WithLowerCase) and (Name='Cntrl')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory(1 shl PUCUUnicodeCategoryCc,IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange($00,$1f,IgnoreCase);
    UnicodeCharClass.AddChar($7f,IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='digits')) or
              ((not WithLowerCase) and (Name='Digits')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory(1 shl PUCUUnicodeCategoryNd,IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange(ord('0'),ord('9'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='graph')) or
              ((not WithLowerCase) and (Name='Graph')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory((1 shl PUCUUnicodeCategoryZs) or (1 shl PUCUUnicodeCategoryZl) or (1 shl PUCUUnicodeCategoryZp) or (1 shl PUCUUnicodeCategoryCc) or (1 shl PUCUUnicodeCategoryCf) or (1 shl PUCUUnicodeCategoryCo) or (1 shl PUCUUnicodeCategoryCs) or (1 shl PUCUUnicodeCategoryCn),IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange($21,$7e,IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='inbasiclatin')) or
              ((not WithLowerCase) and (Name='InBasicLatin')) then begin
   UnicodeCharClass.AddRange($00,$7f,IgnoreCase);
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and ((LowerCaseName='inno_block') or (LowerCaseName='isno_block') or (LowerCaseName='innoblock') or (LowerCaseName='isnoblock'))) or
              ((not WithLowerCase) and ((Name='InNo_Block') or (Name='IsNo_Block') or (Name='InNoBlock') or (Name='IsNoBlock'))) then begin
   for i:=0 to PUCUUnicodeBlockCount-1 do begin
    UnicodeCharClass.AddUnicodeBlock(i,false);
   end;
   UnicodeCharClass.Invert;
   UnicodeCharClass.Inverted:=false;
   if IgnoreCase then begin
    UnicodeCharClass.Canonicalize;
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='lower')) or
              ((not WithLowerCase) and (Name='Lower')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory(1 shl PUCUUnicodeCategoryLl,IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange(ord('a'),ord('z'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='print')) or
              ((not WithLowerCase) and (Name='Print')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory((1 shl PUCUUnicodeCategoryCc) or (1 shl PUCUUnicodeCategoryCf) or (1 shl PUCUUnicodeCategoryCo) or (1 shl PUCUUnicodeCategoryCs) or (1 shl PUCUUnicodeCategoryCn),IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange($20,$7e,IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='punct')) or
              ((not WithLowerCase) and (Name='Punct')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory((1 shl PUCUUnicodeCategoryPd) or (1 shl PUCUUnicodeCategoryPs) or (1 shl PUCUUnicodeCategoryPe) or (1 shl PUCUUnicodeCategoryPc) or (1 shl PUCUUnicodeCategoryPo),IgnoreCase);
   end else begin
    UnicodeCharClass.AddChar(ord('!'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('"'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('#'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('$'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('%'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('&'),IgnoreCase);
    UnicodeCharClass.AddChar(ord(''''),IgnoreCase);
    UnicodeCharClass.AddChar(ord('('),IgnoreCase);
    UnicodeCharClass.AddChar(ord('!'),IgnoreCase);
    UnicodeCharClass.AddChar(ord(')'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('*'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('+'),IgnoreCase);
    UnicodeCharClass.AddChar(ord(','),IgnoreCase);
    UnicodeCharClass.AddChar(ord('\'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('-'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('.'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('/'),IgnoreCase);
    UnicodeCharClass.AddChar(ord(':'),IgnoreCase);
    UnicodeCharClass.AddChar(ord(';'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('<'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('='),IgnoreCase);
    UnicodeCharClass.AddChar(ord('>'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('?'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('@'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('['),IgnoreCase);
    UnicodeCharClass.AddChar(ord('^'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('_'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('`'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('{'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('|'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('}'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('~'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='space')) or
              ((not WithLowerCase) and (Name='Space')) then begin
   if rfUTF8 in Flags then begin
    for i:=0 to PUCUUnicodeCharRangeClassesCounts[PUCUucrWHITESPACES]-1 do begin
     UnicodeCharClass.AddRange(PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWHITESPACES])^[i,0],
                               PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWHITESPACES])^[i,1],
                               IgnoreCase);
    end;
   end else begin
    UnicodeCharClass.AddRange(9,13,IgnoreCase);
    UnicodeCharClass.AddChar(32,IgnoreCase);
   end;
  end else if (WithLowerCase and (LowerCaseName='upper')) or
              ((not WithLowerCase) and (Name='Upper')) then begin
   if rfUTF8 in Flags then begin
    UnicodeCharClass.AddUnicodeCategory(1 shl PUCUUnicodeCategoryLu,IgnoreCase);
   end else begin
    UnicodeCharClass.AddRange(ord('A'),ord('Z'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='word')) or
              ((not WithLowerCase) and (Name='Word')) then begin
   if rfUTF8 in Flags then begin
    for i:=0 to PUCUUnicodeCharRangeClassesCounts[PUCUucrWORDS]-1 do begin
     UnicodeCharClass.AddRange(PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWORDS])^[i,0],
                               PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWORDS])^[i,1],
                               IgnoreCase);
    end;
   end else begin
    UnicodeCharClass.AddRange(ord('a'),ord('z'),IgnoreCase);
    UnicodeCharClass.AddRange(ord('A'),ord('Z'),IgnoreCase);
    UnicodeCharClass.AddRange(ord('0'),ord('9'),IgnoreCase);
    UnicodeCharClass.AddChar(ord('_'),IgnoreCase);
   end;
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='xdigit')) or
              ((not WithLowerCase) and (Name='XDigit')) then begin
   UnicodeCharClass.AddRange(ord('a'),ord('f'),IgnoreCase);
   UnicodeCharClass.AddRange(ord('A'),ord('f'),IgnoreCase);
   UnicodeCharClass.AddRange(ord('0'),ord('9'),IgnoreCase);
   UnicodeCharClass.Canonicalized:=true;
  end else if (WithLowerCase and (LowerCaseName='any')) or
              ((not WithLowerCase) and (Name='Any')) then begin
   UnicodeCharClass.AddRange(0,$10ffff,IgnoreCase);
   UnicodeCharClass.Canonicalized:=true;
  end else begin
   raise EFLRE.Create('Syntax error');
  end;
 end;
 procedure SkipFreeSpacingWhiteSpace;
 var TemporarySourcePosition:TFLRESizeInt;
 begin
  if rfFREESPACING in Flags then begin
   if rfUTF8 in Flags then begin
    while SourcePosition<=SourceLength do begin
     TemporarySourcePosition:=SourcePosition;
     case UTF8CodeUnitGetCharAndIncFallback(Source,TemporarySourcePosition) of
      $0009..$000d,$0020,$00a0,$1680,$180e,$2000..$200b,$2028..$2029,$202f,$205f,$3000,$fffe,$feff:begin
       SourcePosition:=TemporarySourcePosition;
      end;
      ord('#'):begin
       SourcePosition:=TemporarySourcePosition;
       while SourcePosition<=SourceLength do begin
        case UTF8CodeUnitGetCharAndIncFallback(Source,TemporarySourcePosition) of
         $000a,$000d,$2028,$2029:begin
          SourcePosition:=TemporarySourcePosition;
          while SourcePosition<=SourceLength do begin
           case UTF8CodeUnitGetCharAndIncFallback(Source,TemporarySourcePosition) of
            $000a,$000d,$2028,$2029:begin
             SourcePosition:=TemporarySourcePosition;
            end;
            else begin
             break;
            end;
           end;
          end;
          break;
         end;
         else begin
          SourcePosition:=TemporarySourcePosition;
         end;
        end;
       end;
      end;
      else begin
       break;
      end;
     end;
    end;
   end else begin
    while SourcePosition<=SourceLength do begin
     case Source[SourcePosition] of
      #$09..#$0d,#$20,#$a0:begin
       inc(SourcePosition);
      end;
      '#':begin
       inc(SourcePosition);
       while SourcePosition<=SourceLength do begin
        case Source[SourcePosition] of
         #$0a,#$0d:begin
          inc(SourcePosition);
          while (SourcePosition<=SourceLength) and (Source[SourcePosition] in [#$0a,#$0d]) do begin
           inc(SourcePosition);
          end;
          break;
         end;
         else begin
          inc(SourcePosition);
         end;
        end;
       end;
      end;
      else begin
       break;
      end;
     end;
    end;
   end;
  end;
 end;
 function NewUnicodeChar(UnicodeChar:TFLREUInt32):PFLRENode;
 var Index:TFLREInt32;
     TemporaryString:TFLRERawByteString;
     TemporaryNode:PFLRENode;
 begin
  result:=nil;
  TemporaryString:=UTF32CharToUTF8(UnicodeChar);
  try
   for Index:=1 to length(TemporaryString) do begin
    TemporaryNode:=NewNode(ntCHAR,nil,nil,NewCharClass([TemporaryString[Index]],true));
    if assigned(result) then begin
     result:=Concat(result,TemporaryNode);
    end else begin
     result:=TemporaryNode;
    end;
   end;
  finally
   TemporaryString:='';
  end;
 end;
 function NewCharEx(UnicodeChar:TFLREUInt32):PFLRENode;
 begin           
  if (rfUTF8 in Flags) and (UnicodeChar>=$80) then begin
   result:=NewUnicodeChar(UnicodeChar);
  end else if UnicodeChar<=$ff then begin
   result:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(UnicodeChar))],true));
  end else begin
   raise EFLRE.Create('Syntax error');
  end;
 end;
 function NewChar(UnicodeChar:TFLREUInt32):PFLRENode;
 var LowerCaseUnicodeChar,UpperCaseUnicodeChar:TFLREUInt32;
 begin
  LowerCaseUnicodeChar:=UnicodeToLower(UnicodeChar);
  UpperCaseUnicodeChar:=UnicodeToUpper(UnicodeChar);
  if (rfIGNORECASE in Flags) and (LowerCaseUnicodeChar<>UpperCaseUnicodeChar) then begin
   if (rfUTF8 in Flags) and ((LowerCaseUnicodeChar>=$80) or (UpperCaseUnicodeChar>=$80)) then begin
    result:=NewAlt(NewCharEx(LowerCaseUnicodeChar),NewCharEx(UpperCaseUnicodeChar));
   end else begin
    result:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(LowerCaseUnicodeChar)),TFLRERawByteChar(TFLREUInt8(UpperCaseUnicodeChar))],true));
   end;
  end else begin
   if (rfUTF8 in Flags) and (UnicodeChar>=$80) then begin
    result:=NewCharEx(UnicodeChar);
   end else begin
    result:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(UnicodeChar))],true));
   end;
  end;
 end;
 function CompileUTF8Range(Lo,Hi:TFLREUInt32):PFLRENode;
 type TString6Chars=array[0..6] of TFLRERawByteChar;
 const Seq0010ffff:array[0..6,0..4,0..1] of TFLREInt32=((($00,$7f),(-1,-1),(-1,-1),(-1,-1),(-1,-1)),        // 00-7F
                                                     (($c2,$df),($80,$bf),(-1,-1),(-1,-1),(-1,-1)),      // C2-DF 80-BF
                                                     (($e0,$e0),($a0,$bf),($80,$bf),(-1,-1),(-1,-1)),    // E0-E0 A0-BF 80-BF
                                                     (($e1,$ef),($80,$bf),($80,$bf),(-1,-1),(-1,-1)),    // E1-EF 80-BF 80-BF
                                                     (($f0,$f0),($80,$bf),($80,$bf),($80,$bf),(-1,-1)),  // F0-F0 90-BF 80-BF 80-BF
                                                     (($f1,$f3),($80,$bf),($80,$bf),($80,$bf),(-1,-1)),  // F1-F3 80-BF 80-BF 80-BF
                                                     (($f4,$f4),($80,$bf),($80,$bf),($80,$bf),(-1,-1))); // F4-F4 80-8F 80-BF 80-BF
 var OutputNode,NodeChain:PFLRENode;
  procedure Add(const NewNode:PFLRENode);
  begin
   if assigned(NewNode) then begin
    if assigned(NodeChain) then begin
     NodeChain:=Concat(NodeChain,NewNode);
    end else begin
     NodeChain:=NewNode;
    end;
   end;
  end;
  procedure AddSuffix;
  begin
   if assigned(NodeChain) then begin
    if assigned(OutputNode) then begin
     OutputNode:=NewAlt(OutputNode,NodeChain);
    end else begin
     OutputNode:=NodeChain;
    end;
    NodeChain:=nil;
   end;
  end;
  function ToString(CharValue:TFLREUInt32):TString6Chars;
  begin
   case CharValue of
    $00000000..$0000007f:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(1));
     result[1]:=TFLRERawByteChar(TFLREUInt8(CharValue));
    end;
    $00000080..$000007ff:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(2));
     result[1]:=TFLRERawByteChar(TFLREUInt8($c0 or ((CharValue shr 6) and $1f)));
     result[2]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    end;
 // {$ifdef PLREStrictUTF8}$00000800..$0000d7ff,$0000e000..$0000ffff{$else}$00000800..$0000ffff{$endif}:begin
    $00000800..$0000ffff:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(3));
     result[1]:=TFLRERawByteChar(TFLREUInt8($e0 or ((CharValue shr 12) and $0f)));
     result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
     result[3]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    end;
    $00010000..$0010ffff:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(4));
     result[1]:=TFLRERawByteChar(TFLREUInt8($f0 or ((CharValue shr 18) and $07)));
     result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
     result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
     result[4]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    end;
    $00200000..$03ffffff:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(5));
     result[1]:=TFLRERawByteChar(TFLREUInt8($f8 or ((CharValue shr 24) and $03)));
     result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
     result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
     result[4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
     result[5]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    end;
    $04000000..$7fffffff:begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(6));
     result[1]:=TFLRERawByteChar(TFLREUInt8($fc or ((CharValue shr 30) and $01)));
     result[2]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 24) and $3f)));
     result[3]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 18) and $3f)));
     result[4]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 12) and $3f)));
     result[5]:=TFLRERawByteChar(TFLREUInt8($80 or ((CharValue shr 6) and $3f)));
     result[6]:=TFLRERawByteChar(TFLREUInt8($80 or (CharValue and $3f)));
    end;
    else begin
     result[0]:=TFLRERawByteChar(TFLREUInt8(3));
     result[1]:=#$ef;
     result[2]:=#$bf;
     result[3]:=#$bd;
    end;
   end;
  end;
  procedure AddRange(const Lo,Hi:TFLREUInt8);
  var Node:PFLRENode;
  begin
   Node:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(Lo))..TFLRERawByteChar(TFLREUInt8(Hi))],true));
   Add(Node);
  end;
  procedure ProcessRange(Lo,Hi:TFLREUInt32);
  var i,m:TFLREUInt32;
      StrLo,StrHi:TString6Chars;
  begin
   if Hi>$0010ffff then begin
    Hi:=$0010ffff;
   end;
   if Lo<=Hi then begin
    if (Lo=$00000000) and (Hi=$0010ffff) then begin
     for m:=low(Seq0010ffff) to high(Seq0010ffff) do begin
      for i:=low(Seq0010ffff[m]) to high(Seq0010ffff[m]) do begin
       if Seq0010ffff[m,i,0]<0 then begin
        break;
       end;
       AddRange(TFLREUInt8(Seq0010ffff[m,i,0]),TFLREUInt8(Seq0010ffff[m,i,1]));
      end;
      AddSuffix;
     end;
    end else if (Lo=$00000080) and (Hi=$0010ffff) then begin
     for m:=1 to high(Seq0010ffff) do begin
      for i:=low(Seq0010ffff[m]) to high(Seq0010ffff[m]) do begin
       if Seq0010ffff[m,i,0]<0 then begin
        break;
       end;
       AddRange(TFLREUInt8(Seq0010ffff[m,i,0]),TFLREUInt8(Seq0010ffff[m,i,1]));
      end;
      AddSuffix;
     end;
    end else begin
     for i:=1 to 3 do begin
      if i=1 then begin
       m:=7;
      end else begin
       m:=(7-i)+(6*(i-1));
      end;
      m:=(1 shl m)-1;
      if (Lo<=m) and (m<Hi) then begin
       ProcessRange(Lo,m);
       ProcessRange(m+1,Hi);
       exit;
      end;
     end;
     if Hi<128 then begin
      AddRange(Lo,Hi);
      AddSuffix;
     end else begin
      for i:=1 to 3 do begin
       m:=(1 shl (6*i))-1;
       if (Lo and not m)<>(Hi and not m) then begin
        if (Lo and m)<>0 then begin
         ProcessRange(Lo,Lo or m);
         ProcessRange((Lo or m)+1,Hi);
         exit;
        end else if (Hi and m)<>m then begin
         ProcessRange(Lo,(Hi and not m)-1);
         ProcessRange(Hi and not m,Hi);
         exit;
        end;
       end;
      end;
      StrLo:=ToString(Lo);
      StrHi:=ToString(Hi);
      if TFLREUInt8(TFLRERawByteChar(StrLo[0]))=TFLREUInt8(TFLRERawByteChar(StrHi[0])) then begin
       for i:=1 to TFLREUInt8(TFLRERawByteChar(StrLo[0])) do begin
        AddRange(TFLREUInt8(TFLRERawByteChar(StrLo[i])),TFLREUInt8(TFLRERawByteChar(StrHi[i])));
       end;
       AddSuffix;
      end;
     end;
    end;
   end;
  end;
 begin
  OutputNode:=nil;
  NodeChain:=nil;
  ProcessRange(Lo,Hi);
  result:=OutputNode;
 end;
 function NewUnicodeCharClass(UnicodeCharClass:TFLREUnicodeCharClass):PFLRENode;
 var Range:TFLREUnicodeCharClassRange;
     Node:PFLRENode;
     CharClass:TFLRECharClass;
 begin
  UnicodeCharClass.Optimize;
  if UnicodeCharClass.IsSingle then begin
   if assigned(UnicodeCharClass.First) and (UnicodeCharClass.First.Lo<=UnicodeCharClass.First.Hi) then begin
    result:=NewChar(UnicodeCharClass.First.Lo);
   end else begin
    result:=NewNode(ntCHAR,nil,nil,NewCharClass(EmptyCharClass,true));
   end;
  end else begin
   if (rfUTF8 in Flags) and assigned(UnicodeCharClass.Last) and (UnicodeCharClass.Last.Hi>=128) then begin
    result:=nil;
    Range:=UnicodeCharClass.First;
    while assigned(Range) do begin
     if (Range.Lo<=$10ffff) and (Range.Lo=Range.Hi) then begin
      Node:=NewCharEx(Range.Lo);
     end else begin
      Node:=CompileUTF8Range(Range.Lo,Range.Hi);
     end;
     if assigned(result) then begin
      result:=NewAlt(result,Node);
     end else begin
      result:=Node;
     end;
     Range:=Range.Next;
    end;
   end else begin
    CharClass:=[];
    Range:=UnicodeCharClass.First;
    while assigned(Range) and (Range.Lo<256) do begin
     if Range.Lo=Range.Hi then begin
      Include(CharClass,TFLRERawByteChar(TFLREUInt8(Range.Lo)));
     end else begin
      if Range.Hi<256 then begin
       CharClass:=CharClass+[TFLRERawByteChar(TFLREUInt8(Range.Lo))..TFLRERawByteChar(TFLREUInt8(Range.Hi))];
      end else begin
       CharClass:=CharClass+[TFLRERawByteChar(TFLREUInt8(Range.Lo))..#$ff];
      end;
     end;
     Range:=Range.Next;
    end;
    result:=NewNode(ntCHAR,nil,nil,NewCharClass(CharClass,true));
   end;
  end;
 end;
 function TestClassPOSIXCharacterClass:boolean;
 var LocalSourcePosition,Index:TFLRESizeInt;
 begin
  result:=false;
  LocalSourcePosition:=SourcePosition;

  if (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition]='[') then begin
   inc(LocalSourcePosition);
  end else begin
   exit;
  end;

  if (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition]=':') then begin
   inc(LocalSourcePosition);
  end else begin
   exit;
  end;

  if (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition]='^') then begin
   inc(LocalSourcePosition);
  end else begin
   exit;
  end;

  Index:=0;
  while (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition] in ['a'..'z','A'..'Z','0'..'9','_','-']) do begin
   inc(Index);
   inc(LocalSourcePosition);
  end;
  if Index=0 then begin
   exit;
  end;

  if (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition]=':') then begin
   inc(LocalSourcePosition);
  end else begin
   exit;
  end;

  if (LocalSourcePosition<=SourceLength) and (Source[LocalSourcePosition]=']') then begin
// inc(LocalSourcePosition);
  end else begin
   exit;
  end;

  result:=true;
 end;
 function ParseClassPOSIXCharacterClass(const UnicodeCharClass:TFLREUnicodeCharClass;const CanBeAlreadyCanonicalized:boolean):boolean;
 var Name:TFLRERawByteString;
     Negate,IgnoreCase:boolean;
 begin
//result:=false;

  IgnoreCase:=CanBeAlreadyCanonicalized and (rfIGNORECASE in Flags);

  if (SourcePosition<=SourceLength) and (Source[SourcePosition]='[') then begin
   inc(SourcePosition);
  end else begin
   raise EFLRE.Create('Syntax error');
  end;

  if (SourcePosition<=SourceLength) and (Source[SourcePosition]=':') then begin
   inc(SourcePosition);
  end else begin
   raise EFLRE.Create('Syntax error');
  end;

  if (SourcePosition<=SourceLength) and (Source[SourcePosition]='^') then begin
   inc(SourcePosition);
   Negate:=true;
  end else begin
   Negate:=false;
  end;

  Name:='';
  while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['a'..'z','A'..'Z','0'..'9','_','-']) do begin
   Name:=Name+Source[SourcePosition];
   inc(SourcePosition);
  end;

  if (SourcePosition<=SourceLength) and (Source[SourcePosition]=':') then begin
   inc(SourcePosition);
  end else begin
   raise EFLRE.Create('Syntax error');
  end;

  if (SourcePosition<=SourceLength) and (Source[SourcePosition]=']') then begin
   inc(SourcePosition);
  end else begin
   raise EFLRE.Create('Syntax error');
  end;

  GetCharClassPerName(Name,UnicodeCharClass,IgnoreCase,true);
  if Negate then begin
   UnicodeCharClass.Invert;
   UnicodeCharClass.Inverted:=false;
  end;

  result:=true;
 end;
 function ParseClassEscapeUnicodeProperty(const UnicodeCharClass:TFLREUnicodeCharClass;const CanBeAlreadyCanonicalized:boolean):boolean;
 var Identifier:TFLRERawByteString;
     IgnoreCase,IsNegative:boolean;
     f:TFLREInt32;
     LastSourcePos,UntilSourcePos:TFLRESizeInt;
 begin
  result:=false;
  if SourcePosition<=SourceLength then begin
   IgnoreCase:=CanBeAlreadyCanonicalized and (rfIGNORECASE in Flags);
   case Source[SourcePosition] of
    'a'..'z','A'..'Z':begin
     f:=GetMinimalPerfectHashTableValue(@PUCUUnicodeClassHashMapSeeds,
                                        @PUCUUnicodeClassHashMapKeys,
                                        @PUCUUnicodeClassHashMapValues,
                                        PUCUUnicodeClassHashMapSeedBits,
                                        PUCUUnicodeClassHashMapValueBits,
                                        PUCUUnicodeClassHashMapSize,
                                        UTF32CharToUTF8(TFLREUInt8(TPUCURawByteChar(Source[SourcePosition]))));
     if f>=0 then begin
      inc(SourcePosition);
      UnicodeCharClass.AddUnicodeCategory(f,IgnoreCase);
      result:=true;
     end;
    end;
    '{':begin
     inc(SourcePosition);
     LastSourcePos:=SourcePosition;
     if (SourcePosition<=SourceLength) and (Source[SourcePosition]='^') then begin
      inc(SourcePosition);
      LastSourcePos:=SourcePosition;
      IsNegative:=true;
      IgnoreCase:=false;
     end else begin
      IsNegative:=false;
     end;
     UntilSourcePos:=LastSourcePos;
     while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['a'..'z','A'..'Z','0'..'9','_','-']) do begin
      UntilSourcePos:=SourcePosition;
      inc(SourcePosition);
     end;
     if (LastSourcePos<=UntilSourcePos) and ((SourcePosition<=SourceLength) and (Source[SourcePosition]='}')) then begin
      Identifier:=copy(Source,LastSourcePos,(UntilSourcePos-LastSourcePos)+1);
      inc(SourcePosition);
      GetCharClassPerName(Identifier,UnicodeCharClass,IgnoreCase,false);
      if IsNegative and assigned(UnicodeCharClass.First) then begin
       UnicodeCharClass.Invert;
       UnicodeCharClass.Inverted:=false;
       if CanBeAlreadyCanonicalized and (rfIGNORECASE in Flags) then begin
        UnicodeCharClass.Canonicalize;
       end;
      end;
      result:=true;
     end;
    end;
   end;
  end;
 end;
 function ParseClassEscape(const CanBeAlreadyCanonicalized:boolean):TFLREUnicodeCharClass;
 var i:TFLREInt32;
     IgnoreCase:boolean;
     UnicodeChar:TFLREUInt32;
 begin
  result:=nil;
  try
   IgnoreCase:=CanBeAlreadyCanonicalized and (rfIGNORECASE in Flags);
   result:=TFLREUnicodeCharClass.Create;
   if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) then begin
    i:=0;
    while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) do begin
     i:=(i*10)+TFLREInt32(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('0')));
     inc(SourcePosition);
    end;
    if i<>0 then begin
     raise EFLRE.Create('Syntax error');
    end;
    result.AddChar(i,IgnoreCase);
    result.Canonicalized:=IgnoreCase;
    exit;
   end;
   case Source[SourcePosition] of
    'a':begin
     inc(SourcePosition);
     result.AddChar($0007,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'b':begin
     inc(SourcePosition);
     result.AddChar($0008,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'B':begin
     inc(SourcePosition);
     result.AddChar(ord('\'),IgnoreCase);
     result.Canonicalized:=true;
    end;
    't':begin
     inc(SourcePosition);
     result.AddChar(9,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'n':begin
     inc(SourcePosition);
     result.AddChar(10,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'v':begin
     inc(SourcePosition);
     result.AddChar(11,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'f':begin
     inc(SourcePosition);
     result.AddChar(12,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'r':begin
     inc(SourcePosition);
     result.AddChar(13,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'e':begin
     inc(SourcePosition);
     result.AddChar($1b,IgnoreCase);
     result.Canonicalized:=true;
    end;
    'w','W':begin
     if rfUTF8 in Flags then begin
      for i:=0 to PUCUUnicodeCharRangeClassesCounts[PUCUucrWORDS]-1 do begin
       result.AddRange(PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWORDS])^[i,0],
                       PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWORDS])^[i,1],
                       IgnoreCase);
      end;
     end else begin
      result.AddRange(ord('a'),ord('z'),IgnoreCase);
      result.AddRange(ord('A'),ord('Z'),IgnoreCase);
      result.AddRange(ord('0'),ord('9'),IgnoreCase);
      result.AddChar(ord('_'),IgnoreCase);
     end;
     if Source[SourcePosition]='W' then begin
      result.Invert;
      result.Inverted:=false;
     end;
     result.Canonicalized:=true;
     inc(SourcePosition);
    end;
    's','S':begin
     if rfUTF8 in Flags then begin
      for i:=0 to PUCUUnicodeCharRangeClassesCounts[PUCUucrWHITESPACES]-1 do begin
       result.AddRange(PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWHITESPACES])^[i,0],
                       PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrWHITESPACES])^[i,1],
                       IgnoreCase);
      end;
     end else begin
      result.AddRange(9,13,IgnoreCase);
      result.AddChar(32,IgnoreCase);
     end;
     if Source[SourcePosition]='S' then begin
      result.Invert;
      result.Inverted:=false;
     end;
     result.Canonicalized:=true;
     inc(SourcePosition);
    end;
    'd','D':begin
     if rfUTF8 in Flags then begin
      for i:=0 to PUCUUnicodeCharRangeClassesCounts[PUCUucrDIGITS]-1 do begin
       result.AddRange(PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrDIGITS])^[i,0],
                       PPUCUUnicodeCharRanges(PUCUUnicodeCharRangeClassesData[PUCUucrDIGITS])^[i,1],
                       IgnoreCase);
      end;
     end else begin
      result.AddRange(ord('0'),ord('9'),IgnoreCase);
     end;
     if Source[SourcePosition]='D' then begin
      result.Invert;
      result.Inverted:=false;
     end;
     result.Canonicalized:=true;
     inc(SourcePosition);
    end;
    'p':begin
     inc(SourcePosition);
     if ParseClassEscapeUnicodeProperty(result,CanBeAlreadyCanonicalized) then begin
      result.Canonicalized:=true;
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
    'P':begin
     inc(SourcePosition);
     if ParseClassEscapeUnicodeProperty(result,CanBeAlreadyCanonicalized) then begin
      result.Canonicalized:=true;
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
     result.Invert;
     result.Inverted:=false;
     result.Canonicalized:=true;
    end;
    'c':begin
     inc(SourcePosition);
     if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['a'..'z','A'..'Z']) then begin
      case Source[SourcePosition] of
       'a'..'z':begin
        result.AddChar(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('a')),IgnoreCase);
       end;
       'A'..'Z':begin
        result.AddChar(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('A')),IgnoreCase);
       end;
      end;
      result.Canonicalized:=IgnoreCase;
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
    'x':begin
     inc(SourcePosition);
     if ((SourcePosition+1)<=SourceLength) and
        (Source[SourcePosition+0] in ['0'..'9','a'..'f','A'..'F']) and
        (Source[SourcePosition+1] in ['0'..'9','a'..'f','A'..'F']) then begin
      result.AddChar((Hex2Value(Source[SourcePosition+0]) shl 4) or Hex2Value(Source[SourcePosition+1]),IgnoreCase);
      inc(SourcePosition,2);
     end else if (SourcePosition<=SourceLength) and (Source[SourcePosition]='{') then begin
      inc(SourcePosition);
      UnicodeChar:=0;
      while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','a'..'f','A'..'F']) do begin
       UnicodeChar:=(UnicodeChar shl 4) or Hex2Value(Source[SourcePosition]);
       inc(SourcePosition);
      end;
      if (SourcePosition<=SourceLength) and (Source[SourcePosition]='}') then begin
       inc(SourcePosition);
       result.AddChar(UnicodeChar,IgnoreCase);
      end else begin
       raise EFLRE.Create('Syntax error');
      end;
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
    'u':begin
     inc(SourcePosition);
     if ((SourcePosition+3)<=SourceLength) and
        (Source[SourcePosition+0] in ['0'..'9','a'..'f','A'..'F']) and
        (Source[SourcePosition+1] in ['0'..'9','a'..'f','A'..'F']) and
        (Source[SourcePosition+2] in ['0'..'9','a'..'f','A'..'F']) and
        (Source[SourcePosition+3] in ['0'..'9','a'..'f','A'..'F']) then begin
      UnicodeChar:=(Hex2Value(Source[SourcePosition+0]) shl 24) or (Hex2Value(Source[SourcePosition+1]) shl 16) or (Hex2Value(Source[SourcePosition+2]) shl 8) or Hex2Value(Source[SourcePosition+3]);
      inc(SourcePosition,4);
      result.AddChar(UnicodeChar,IgnoreCase);
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
    'U':begin
     inc(SourcePosition);
     if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','a'..'f','A'..'F']) then begin
      UnicodeChar:=0;
      while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','a'..'f','A'..'F']) do begin
       UnicodeChar:=(UnicodeChar shl 4) or Hex2Value(Source[SourcePosition]);
       inc(SourcePosition);
      end;
      result.AddChar(UnicodeChar,IgnoreCase);
     end else begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
    'Q':begin
     inc(SourcePosition);
     while SourcePosition<=SourceLength do begin
      if Source[SourcePosition]='\' then begin
       inc(SourcePosition);
       if (SourcePosition<=SourceLength) and (Source[SourcePosition]='E') then begin
        inc(SourcePosition);
        break;
       end else begin
        result.AddChar(ord('\'),IgnoreCase);
       end;
      end else begin
       if (rfUTF8 in Flags) and (TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))>=$80) then begin
        UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition);
        result.AddChar(UnicodeChar,IgnoreCase);
       end else begin
        result.AddChar(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition])),IgnoreCase);
        inc(SourcePosition);
       end;
      end;
     end;
     result.Canonicalized:=IgnoreCase;
    end;
    else begin
     if (rfUTF8 in Flags) and (TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))>=$80) then begin
      UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition);
      result.AddChar(UnicodeChar,IgnoreCase);
     end else begin
      result.AddChar(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition])),IgnoreCase);
      inc(SourcePosition);
     end;
    end;
   end;
  except
   FreeAndNil(result);
   raise;
  end;
 end;
 function ParseClassAtom:TFLREUnicodeCharClass;
 begin
  result:=nil;
  try
   if SourcePosition<=SourceLength then begin
    if Source[SourcePosition]='\' then begin
     inc(SourcePosition);
     result:=ParseClassEscape(false);
    end else if TestClassPOSIXCharacterClass then begin
     result:=TFLREUnicodeCharClass.Create;
     if not ParseClassPOSIXCharacterClass(result,false) then begin
      raise EFLRE.Create('Syntax error');
     end;
    end else begin
     result:=TFLREUnicodeCharClass.Create;
     if (rfUTF8 in Flags) and (TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))>=$80) then begin
      result.AddChar(UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition));
     end else begin
      result.AddChar(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition])));
      inc(SourcePosition);
     end;
    end;
   end else begin
    raise EFLRE.Create('Syntax error');
   end;
  except
   FreeAndNil(result);
   raise;
  end;
 end;
 function ParseCharacterClass:TFLREUnicodeCharClass;
 var InvertFlag:boolean;
     a,b,c:TFLREUnicodeCharClass;
 begin
  result:=nil;
  try
   a:=nil;
   b:=nil;
   try
    result:=TFLREUnicodeCharClass.Create;
    if (SourcePosition<=SourceLength) and (Source[SourcePosition]='[') then begin
     inc(SourcePosition);
    end else begin
     raise EFLRE.Create('Syntax error');
    end;
    if (SourcePosition<=SourceLength) and (Source[SourcePosition]='^') then begin
     inc(SourcePosition);
     InvertFlag:=true;
    end else begin
     InvertFlag:=false;
    end;
    while (SourcePosition<=SourceLength) and (Source[SourcePosition]<>']') do begin
     if ((SourcePosition+1)<=SourceLength) and ((Source[SourcePosition]='-') and (Source[SourcePosition+1] in ['[',']'])) then begin
      inc(SourcePosition);
      if Source[SourcePosition]=']' then begin
       a:=TFLREUnicodeCharClass.Create;
       a.AddChar(ord('-'));
      end else begin
       a:=ParseCharacterClass;
       b:=TFLREUnicodeCharClass.Create;
       if b.Subtraction(result,a) then begin
        FreeAndNil(result);
        result:=b;
        b:=nil;
       end else begin
        FreeAndNil(b);
       end;
       FreeAndNil(a);
       if not ((SourcePosition<=SourceLength) and (Source[SourcePosition]=']')) then begin
        raise EFLRE.Create('Syntax error');
       end;
       continue;
      end;
     end else begin
      a:=ParseClassAtom;
     end;
     if ((SourcePosition+1)<=SourceLength) and ((Source[SourcePosition]='&') and (Source[SourcePosition+1]='&')) then begin
      inc(SourcePosition,2);
      if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['[',']']) then begin
       if Source[SourcePosition]='[' then begin
        if assigned(a) then begin
         result.TakeoverCombine(a);
         FreeAndNil(a);
        end;
        a:=ParseCharacterClass;
        b:=TFLREUnicodeCharClass.Create;
        if b.Intersection(result,a) then begin
         FreeAndNil(result);
         result:=b;
         b:=nil;
        end else begin
         FreeAndNil(b);
        end;
        FreeAndNil(a);
        if not ((SourcePosition<=SourceLength) and (Source[SourcePosition]=']')) then begin
         raise EFLRE.Create('Syntax error');
        end;
        continue;
       end else begin
        raise EFLRE.Create('Syntax error');
       end;
      end else begin
       raise EFLRE.Create('Syntax error');
      end;
     end else if (SourcePosition<=SourceLength) and (Source[SourcePosition]='-') then begin
      inc(SourcePosition);
      if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['[',']']) then begin
       if Source[SourcePosition]='[' then begin
        if assigned(a) then begin
         result.TakeoverCombine(a);
         FreeAndNil(a);
        end;
        a:=ParseCharacterClass;
        b:=TFLREUnicodeCharClass.Create;
        if b.Subtraction(result,a) then begin
         FreeAndNil(result);
         result:=b;
         b:=nil;
        end else begin
         FreeAndNil(b);
        end;
        FreeAndNil(a);
        if not ((SourcePosition<=SourceLength) and (Source[SourcePosition]=']')) then begin
         raise EFLRE.Create('Syntax error');
        end;
        continue;
       end else begin
        a.AddChar(ord('-'));
       end;
      end else if assigned(a) then begin
       if not a.IsSingle then begin
        if assigned(a.Last) and (a.Last.Lo<=a.Last.Hi) then begin
         c:=TFLREUnicodeCharClass.Create;
         c.AddChar(a.Last.Hi);
         c.Canonicalized:=a.Canonicalized;
         c.Inverted:=a.Inverted;
         result.TakeoverCombine(a);
         FreeAndNil(a);
         a:=c;
        end else begin
         FreeAndNil(a);
         raise EFLRE.Create('Syntax error');
        end;
       end;
       b:=ParseClassAtom;
       if (not b.IsSingle) and (assigned(b.First) and (a.First.Lo<=a.First.Hi)) then begin
        c:=TFLREUnicodeCharClass.Create;
        c.AddChar(b.First.Lo);
        c.Canonicalized:=b.Canonicalized;
        c.Inverted:=b.Inverted;
        result.TakeoverCombine(b);
        FreeAndNil(b);
        b:=c;
       end;
       if (not b.IsSingle) or ((assigned(a.Last) and assigned(b.Last)) and not (a.Last.Lo<=b.Last.Hi)) then begin
        FreeAndNil(a);
        FreeAndNil(b);
        raise EFLRE.Create('Syntax error');
       end;
       if assigned(a.Last) and assigned(b.Last) then begin
        a.Last.Hi:=b.Last.Hi;
       end else begin
        a.TakeoverCombine(b);
       end;
       FreeAndNil(b);
      end;
     end;
     if assigned(a) then begin
      result.TakeoverCombine(a);
      FreeAndNil(a);
     end;
    end;
    if (SourcePosition<=SourceLength) and (Source[SourcePosition]=']') then begin
     inc(SourcePosition);
    end else begin
     raise EFLRE.Create('Syntax error');
    end;
    if (rfIGNORECASE in Flags) and not result.Canonicalized then begin
     result.Canonicalize;
    end;
    if InvertFlag then begin
     result.Invert;
    end;
   finally
    FreeAndNil(a);
    FreeAndNil(b);
   end;
  except
   FreeAndNil(result);
   raise;
  end;
 end;
 function NewNumberedGroup:PFLRENode;
 var SubMatchIndex,GroupIndex:TFLREInt32;
 begin
  if ([rfNOCAPTURES,rfMULTIMATCH]*Flags)<>[] then begin
   result:=ParseDisjunction;
  end else begin
   SubMatchIndex:=CountInternalCaptures;
   inc(CountInternalCaptures);
   GroupIndex:=CountCaptures;
   inc(CountCaptures);
   if CountCaptures>length(CapturesToSubMatchesMap) then begin
    SetLength(CapturesToSubMatchesMap,CountCaptures*2);
   end;
   CapturesToSubMatchesMap[GroupIndex]:=SubMatchIndex;
   NamedGroupStringIntegerPairHashMap.Add(TFLRERawByteString(IntToStr(GroupIndex)),GroupIndex);
   if NamedGroupStringList.IndexOf(IntToStr(GroupIndex))<0 then begin
    NamedGroupStringIndexList.Add(NamedGroupStringList.Add(IntToStr(GroupIndex)));
   end else begin
    raise EFLRE.Create('Duplicate named group');
   end;
   GroupIndexIntegerStack.Add(GroupIndex);
   try
    result:=NewNode(ntPAREN,ParseDisjunction,nil,SubMatchIndex);
   finally
    GroupIndexIntegerStack.Delete(GroupIndexIntegerStack.Count-1);
   end;
  end;
 end;
 function NewNamedGroup(const Name:TFLRERawByteString):PFLRENode;
 var SubMatchIndex,GroupIndex:TFLREInt32;
 begin
  if ([rfNOCAPTURES,rfMULTIMATCH]*Flags)<>[] then begin
   result:=ParseDisjunction;
  end else begin
   SubMatchIndex:=CountInternalCaptures;
   inc(CountInternalCaptures);
   GroupIndex:=CountCaptures;
   inc(CountCaptures);
   if CountCaptures>length(CapturesToSubMatchesMap) then begin
    SetLength(CapturesToSubMatchesMap,CountCaptures*2);
   end;
   CapturesToSubMatchesMap[GroupIndex]:=SubMatchIndex;
   NamedGroupStringIntegerPairHashMap.Add(Name,GroupIndex);
   if NamedGroupStringList.IndexOf(String(Name))<0 then begin
    NamedGroupStringIndexList.Add(NamedGroupStringList.Add(String(Name)));
   end else begin
    raise EFLRE.Create('Duplicate named group');
   end;
   NamedGroupStringIntegerPairHashMap.Add(TFLRERawByteString(IntToStr(GroupIndex)),GroupIndex);
   if NamedGroupStringList.IndexOf(IntToStr(GroupIndex))<0 then begin
    NamedGroupStringList.Add(IntToStr(GroupIndex));
   end else begin
    raise EFLRE.Create('Duplicate named group');
   end;
   GroupIndexIntegerStack.Add(GroupIndex);
   GroupNameStringStack.Add(String(Name));
   try
    result:=NewNode(ntPAREN,ParseDisjunction,nil,SubMatchIndex);
   finally
    GroupIndexIntegerStack.Delete(GroupIndexIntegerStack.Count-1);
    GroupNameStringStack.Delete(GroupNameStringStack.Count-1);
   end;
  end;
 end;
 function NewBackReferencePerIndex(const Group:TFLREInt32;const ComparisonGroup:boolean):PFLRENode;
 var Value:TFLREInt32;
 begin
  result:=nil;
  if (Group>=CountCaptures) or (GroupIndexIntegerStack.IndexOf(Group)>=0) then begin
   raise EFLRE.Create('Syntax error');
  end else begin
   Value:=CountInternalCaptures;
   inc(CountInternalCaptures);
   if rfIGNORECASE in Flags then begin
    result:=NewNode(ntBACKREFERENCEIGNORECASE,nil,nil,Value);
   end else begin
    result:=NewNode(ntBACKREFERENCE,nil,nil,Value);
   end;
   result^.Group:=Group;
   if ComparisonGroup then begin
    result^.Flags:=1;
   end else begin
    result^.Flags:=0;
   end;
  end;
 end;
 function NewBackReferencePerName(const Name:TFLRERawByteString;const ComparisonGroup:boolean):PFLRENode;
 var Start,Index:TFLRESizeInt;
     Value:TFLREInt32;
     Minus:boolean;
 begin
  result:=nil;
  if (length(Name)>0) and (Name[1]='-') then begin
   Minus:=true;
   Start:=2;
  end else begin
   Minus:=false;
   Start:=1;
  end;
  Value:=-1;
  for Index:=Start to length(Name) do begin
   if Name[Index] in ['0'..'9'] then begin
    if Index>Start then begin
     Value:=Value*10;
    end else begin
     Value:=0;
    end;
    inc(Value,TFLREUInt8(TFLRERawByteChar(Name[Index]))-TFLREUInt8(TFLRERawByteChar('0')));
   end else begin
    Value:=-1;
    break;
   end;
  end;
  if Value>=0 then begin
   if Minus then begin
    Value:=CountCaptures-Value;
    if (Value>=0) and (Value<CountCaptures) then begin
     result:=NewBackReferencePerIndex(CountCaptures-Value,ComparisonGroup);
    end else begin
     raise EFLRE.Create('Syntax error');
    end;
   end else begin
    result:=NewBackReferencePerIndex(Value,ComparisonGroup);
   end;
  end else begin
   if (NamedGroupStringList.IndexOf(String(Name))<0) or (GroupNameStringStack.IndexOf(String(Name))>=0) then begin
    raise EFLRE.Create('Syntax error');
   end else begin
    Value:=CountInternalCaptures;
    inc(CountInternalCaptures);
    if rfIGNORECASE in Flags then begin
     result:=NewNode(ntBACKREFERENCEIGNORECASE,nil,nil,Value);
    end else begin
     result:=NewNode(ntBACKREFERENCE,nil,nil,Value);
    end;
    result^.Group:=-1;
    result^.Name:=Name;
    if ComparisonGroup then begin
     result^.Flags:=1;
    end else begin
     result^.Flags:=0;
    end;
   end;
  end;
 end;
 function UnescapeString(const aEscapedString:TFLRERawByteString):TFLRERawByteString;
 var Index,Len:TFLRESizeInt;
     UnicodeChar:TFLREUInt32;
 begin
  Len:=length(aEscapedString);
  if PtrPosChar(TFLRERawByteChar('\'),@aEscapedString[1],Len,0)>=0 then begin
   result:='';
   Index:=1;
   while Index<=Len do begin
    case aEscapedString[Index] of
     TFLRERawByteChar('\'):begin
      inc(Index);
      if Index<Len then begin
       case aEscapedString[Index] of
        'a':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$07);
        end;
        'b':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$08);
        end;
        'B':begin
         inc(Index);
         result:=result+TFLRERawByteChar('\');
        end;
        't':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$09);
        end;
        'n':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$0a);
        end;
        'v':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$0b);
        end;
        'f':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$0c);
        end;
        'r':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$0d);
        end;
        'e':begin
         inc(Index);
         result:=result+TFLRERawByteChar(#$1b);
        end;
        'w','W':begin
         raise EFLRE.Create('Syntax error');
        end;
        's','S':begin
         raise EFLRE.Create('Syntax error');
        end;
        'd','D':begin
         raise EFLRE.Create('Syntax error');
        end;
        'p':begin
         raise EFLRE.Create('Syntax error');
        end;
        'P':begin
         raise EFLRE.Create('Syntax error');
        end;
        'c':begin
         inc(Index);
         if (Index<=Len) and (aEscapedString[Index] in ['a'..'z','A'..'Z']) then begin
          case aEscapedString[Index] of
           'a'..'z':begin
            result:=result+TFLRERawByteChar(TFLREUInt8(TFLRERawByteChar(aEscapedString[Index]))-TFLREUInt8(TFLRERawByteChar('a')));
           end;
           'A'..'Z':begin
            result:=result+TFLRERawByteChar(TFLREUInt8(TFLRERawByteChar(aEscapedString[Index]))-TFLREUInt8(TFLRERawByteChar('A')));
           end;
          end;
         end else begin
          raise EFLRE.Create('Syntax error');
         end;
        end;
        'x':begin
         inc(Index);
         if ((Index+1)<=Len) and
            (aEscapedString[Index+0] in ['0'..'9','a'..'f','A'..'F']) and
            (aEscapedString[Index+1] in ['0'..'9','a'..'f','A'..'F']) then begin
          if rfUTF8 in Flags then begin
           result:=result+PUCUUTF32CharToUTF8((Hex2Value(aEscapedString[Index+0]) shl 4) or Hex2Value(aEscapedString[Index+1]));
          end else begin
           result:=result+TFLRERawByteChar((Hex2Value(aEscapedString[Index+0]) shl 4) or Hex2Value(aEscapedString[Index+1]));
          end;
          inc(Index,2);
         end else if (Index<=Len) and (aEscapedString[Index]='{') then begin
          inc(Index);
          UnicodeChar:=0;
          while (Index<=Len) and (aEscapedString[Index] in ['0'..'9','a'..'f','A'..'F']) do begin
           UnicodeChar:=(UnicodeChar shl 4) or Hex2Value(aEscapedString[Index]);
           inc(Index);
          end;
          if (Index<=Len) and (aEscapedString[Index]='}') then begin
           inc(Index);
           if rfUTF8 in Flags then begin
            result:=result+PUCUUTF32CharToUTF8(UnicodeChar);
           end else begin
            if UnicodeChar<$100 then begin
             result:=result+TFLRERawByteChar(TFLREUInt8(UnicodeChar));
            end else begin
             raise EFLRE.Create('Syntax error');
            end;
           end;
          end else begin
           raise EFLRE.Create('Syntax error');
          end;
         end else begin
          raise EFLRE.Create('Syntax error');
         end;
        end;
        'u':begin
         inc(Index);
         if ((Index+3)<=Len) and
            (aEscapedString[Index+0] in ['0'..'9','a'..'f','A'..'F']) and
            (aEscapedString[Index+1] in ['0'..'9','a'..'f','A'..'F']) and
            (aEscapedString[Index+2] in ['0'..'9','a'..'f','A'..'F']) and
            (aEscapedString[Index+3] in ['0'..'9','a'..'f','A'..'F']) then begin
          UnicodeChar:=(Hex2Value(aEscapedString[Index+0]) shl 24) or (Hex2Value(aEscapedString[Index+1]) shl 16) or (Hex2Value(aEscapedString[Index+2]) shl 8) or Hex2Value(aEscapedString[Index+3]);
          inc(Index,4);
          if rfUTF8 in Flags then begin
           result:=result+PUCUUTF32CharToUTF8(UnicodeChar);
          end else begin
           if UnicodeChar<$100 then begin
            result:=result+TFLRERawByteChar(TFLREUInt8(UnicodeChar));
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          end;
         end else begin
          raise EFLRE.Create('Syntax error');
         end;
        end;
        'U':begin
         inc(Index);
         if (Index<=Len) and (aEscapedString[Index] in ['0'..'9','a'..'f','A'..'F']) then begin
          UnicodeChar:=0;
          while (Index<=Len) and (aEscapedString[Index] in ['0'..'9','a'..'f','A'..'F']) do begin
           UnicodeChar:=(UnicodeChar shl 4) or Hex2Value(aEscapedString[Index]);
           inc(Index);
          end;
          if rfUTF8 in Flags then begin
           result:=result+PUCUUTF32CharToUTF8(UnicodeChar);
          end else begin
           if UnicodeChar<$100 then begin
            result:=result+TFLRERawByteChar(TFLREUInt8(UnicodeChar));
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          end;
         end else begin
          raise EFLRE.Create('Syntax error');
         end;
        end;
        'Q':begin
         inc(Index);
         while Index<=Len do begin
          if aEscapedString[Index]='\' then begin
           inc(Index);
           if (Index<=Len) and (aEscapedString[Index]='E') then begin
            inc(Index);
            break;
           end else begin
            result:=result+'\';
           end;
          end else begin
           if (rfUTF8 in Flags) and (TFLREUInt8(TFLRERawByteChar(aEscapedString[Index]))>=$80) then begin
            UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(aEscapedString,Index);
            result:=result+PUCUUTF32CharToUTF8(UnicodeChar);
           end else begin
            result:=result+aEscapedString[Index];
            inc(Index);
           end;
          end;
         end;
        end;
        else begin
         result:=result+aEscapedString[Index];
         inc(Index);
        end;
       end;
      end;
     end;
     else begin
      result:=result+aEscapedString[Index];
      inc(Index);
     end;
    end;
   end;
  end else begin
   result:=aEscapedString;
  end;
 end;
 function ParseAtom:PFLRENode;
 var Value,Index:TFLREInt32;
     Negate,Done,IsNegative,OldBackReferenceComparisonGroup:boolean;
     UnicodeChar,LowerCaseUnicodeChar,UpperCaseUnicodeChar:TFLREUInt32;
     UnicodeCharClass:TFLREUnicodeCharClass;
     OldFlags:TFLREFlags;
     Name,TemporaryString:TFLRERawByteString;
     TemporaryNode:PFLRENode;
     TerminateChar:TFLRERawByteChar;
 begin
  result:=nil;
  try
   repeat
    Done:=true;
    if SourcePosition<=SourceLength then begin
     case Source[SourcePosition] of
      '*','+','?',')',']','{','}','|',#0:begin
       raise EFLRE.Create('Syntax error');
      end;
      '(':begin
       inc(SourcePosition);
       if (SourcePosition<=SourceLength) and (Source[SourcePosition]='?') then begin
        inc(SourcePosition);
        if SourcePosition<=SourceLength then begin
         case Source[SourcePosition] of
          '#':begin
           inc(SourcePosition);
           while (SourcePosition<=SourceLength) and (Source[SourcePosition]<>')') do begin
            inc(SourcePosition);
           end;
           Done:=false;
          end;
          '+','-','a'..'z':begin
           OldFlags:=Flags;
           IsNegative:=false;
           while SourcePosition<=SourceLength do begin
            case Source[SourcePosition] of
             ')':begin
              break;
             end;
             '-':begin
              inc(SourcePosition);
              IsNegative:=true;
             end;
             '+':begin
              inc(SourcePosition);
              IsNegative:=false;
             end;
             'i':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfIGNORECASE);
              end else begin
               Include(Flags,rfIGNORECASE);
              end;
             end;
             'n':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfNAMED);
              end else begin
               Include(Flags,rfNAMED);
              end;
             end;
             'm':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfMULTILINE);
              end else begin
               Include(Flags,rfMULTILINE);
              end;
             end;
             's':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfSINGLELINE);
              end else begin
               Include(Flags,rfSINGLELINE);
              end;
             end;
             'x':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfFREESPACING);
              end else begin
               Include(Flags,rfFREESPACING);
              end;
             end;
             'p':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfLONGEST);
              end else begin
               Include(Flags,rfLONGEST);
              end;
             end;
             'U':begin
              inc(SourcePosition);
              if IsNegative then begin
               Exclude(Flags,rfUNGREEDY);
              end else begin
               Include(Flags,rfUNGREEDY);
              end;
             end;
             ':':begin
              inc(SourcePosition);
              result:=ParseDisjunction;
              Flags:=OldFlags;
              break;
             end;
             else begin
              inc(SourcePosition);
              raise EFLRE.Create('Syntax error');
             end;
            end;
           end;
          end;
          ':':begin
           inc(SourcePosition);
           result:=ParseDisjunction;
          end;
          '''':begin
           inc(SourcePosition);
           Name:='';
           while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_']) do begin
            Name:=Name+Source[SourcePosition];
            inc(SourcePosition);
           end;
           if (SourcePosition<=SourceLength) and (Source[SourcePosition]='''') then begin
            inc(SourcePosition);
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
           if BackReferenceComparisonGroup then begin
            result:=ParseDisjunction;
           end else begin
            result:=NewNamedGroup(Name);
           end;
          end;
          '!','=':begin
           Negate:=Source[SourcePosition]='!';
           inc(SourcePosition);
           TemporaryString:='';
           while (SourcePosition<=SourceLength) and (Source[SourcePosition]<>')') do begin
            if Source[SourcePosition]='\' then begin
             TemporaryString:=TemporaryString+'\';
             inc(SourcePosition);
             if SourcePosition<=SourceLength then begin
              TemporaryString:=TemporaryString+Source[SourcePosition];
              inc(SourcePosition);
             end else begin
              raise EFLRE.Create('Syntax error');
             end;
            end else begin
             TemporaryString:=TemporaryString+Source[SourcePosition];
             inc(SourcePosition);
            end;
           end;
           TemporaryString:=UnescapeString(TemporaryString);
           Value:=-1;
           for Index:=0 to CountLookAssertionStrings-1 do begin
            if LookAssertionStrings[Index]=TemporaryString then begin
             Value:=Index;
             break;
            end;
           end;
           if Value<0 then begin
            Value:=CountLookAssertionStrings;
            inc(CountLookAssertionStrings);
            if CountLookAssertionStrings>length(LookAssertionStrings) then begin
             SetLength(LookAssertionStrings,CountLookAssertionStrings*2);
            end;
            LookAssertionStrings[Value]:=TemporaryString;
           end;
           if Negate then begin
            result:=NewNode(ntLOOKAHEADNEGATIVE,nil,nil,Value);
           end else begin
            result:=NewNode(ntLOOKAHEADPOSITIVE,nil,nil,Value);
           end;
          end;
          '<':begin
           inc(SourcePosition);
           if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['!','=']) then begin
            Negate:=Source[SourcePosition]='!';
            inc(SourcePosition);
            TemporaryString:='';
            while (SourcePosition<=SourceLength) and (Source[SourcePosition]<>')') do begin
             if Source[SourcePosition]='\' then begin
              TemporaryString:=TemporaryString+'\';
              inc(SourcePosition);
              if SourcePosition<=SourceLength then begin
               TemporaryString:=TemporaryString+Source[SourcePosition];
               inc(SourcePosition);
              end else begin
               raise EFLRE.Create('Syntax error');
              end;
             end else begin
              TemporaryString:=TemporaryString+Source[SourcePosition];
              inc(SourcePosition);
             end;
            end;
            TemporaryString:=UnescapeString(TemporaryString);
            Value:=-1;
            for Index:=0 to CountLookAssertionStrings-1 do begin
             if LookAssertionStrings[Index]=TemporaryString then begin
              Value:=Index;
              break;
             end;
            end;
            if Value<0 then begin
             Value:=CountLookAssertionStrings;
             inc(CountLookAssertionStrings);
             if CountLookAssertionStrings>length(LookAssertionStrings) then begin
              SetLength(LookAssertionStrings,CountLookAssertionStrings*2);
             end;
             LookAssertionStrings[Value]:=TemporaryString;
            end;
            if Negate then begin
             result:=NewNode(ntLOOKBEHINDNEGATIVE,nil,nil,Value);
            end else begin
             result:=NewNode(ntLOOKBEHINDPOSITIVE,nil,nil,Value);
            end;
           end else begin
            Name:='';
            while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_']) do begin
             Name:=Name+Source[SourcePosition];
             inc(SourcePosition);
            end;
            if (SourcePosition<=SourceLength) and (Source[SourcePosition]='>') then begin
             inc(SourcePosition);
            end else begin
             raise EFLRE.Create('Syntax error');
            end;
            if BackReferenceComparisonGroup then begin
             result:=ParseDisjunction;
            end else begin
             result:=NewNamedGroup(Name);
            end;
           end;
          end;
          'P':begin
           inc(SourcePosition);
           if SourcePosition<=SourceLength then begin
            case Source[SourcePosition] of
             '=':begin
              inc(SourcePosition);
              Name:='';
              while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_','-']) do begin
               Name:=Name+Source[SourcePosition];
               inc(SourcePosition);
              end;
              if (SourcePosition<=SourceLength) and (Source[SourcePosition]=':') then begin
               inc(SourcePosition);
               result:=NewBackReferencePerName(Name,true);
               OldBackReferenceComparisonGroup:=BackReferenceComparisonGroup;
               BackReferenceComparisonGroup:=true;
               try
                result^.Left:=ParseDisjunction;
               finally
                BackReferenceComparisonGroup:=OldBackReferenceComparisonGroup;
               end;
              end else begin
               result:=NewBackReferencePerName(Name,false);
              end;
             end;
             '<':begin
              inc(SourcePosition);
              Name:='';
              while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_']) do begin
               Name:=Name+Source[SourcePosition];
               inc(SourcePosition);
              end;
              if (SourcePosition<=SourceLength) and (Source[SourcePosition]='>') then begin
               inc(SourcePosition);
              end else begin
               raise EFLRE.Create('Syntax error');
              end;          
              if BackReferenceComparisonGroup then begin
               result:=ParseDisjunction;
              end else begin
               result:=NewNamedGroup(Name);
              end;
             end
             else begin
              raise EFLRE.Create('Syntax error');
             end;
            end;
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          end;
          else begin
           raise EFLRE.Create('Syntax error');
          end;
         end;
        end else begin
         raise EFLRE.Create('Syntax error');
        end;
       end else begin
        if BackReferenceComparisonGroup then begin
         result:=ParseDisjunction;
        end else begin
         result:=NewNumberedGroup;
        end;
       end;
       if (SourcePosition<=SourceLength) and (Source[SourcePosition]=')') then begin
        inc(SourcePosition);
       end else begin
        raise EFLRE.Create('Syntax error');
       end;
      end;
      '\':begin
       inc(SourcePosition);
       if SourcePosition<=SourceLength then begin
        case Source[SourcePosition] of
         '0'..'9':begin
          Value:=TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('0'));
          inc(SourcePosition);
          while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) do begin
           Value:=(Value*10)+(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('0')));
           inc(SourcePosition);
          end;
          result:=NewBackReferencePerIndex(Value,false);
         end;
         'C':begin
          // Any TFLREUInt8
          result:=NewNode(ntCHAR,nil,nil,NewCharClass(AllCharClass,true));
          inc(SourcePosition);
         end;
         'b','y':begin
          result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyWordBoundary);
          inc(SourcePosition);
         end;
         'B','Y':begin
          result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyNonWordBoundary);
          inc(SourcePosition);
         end;
         'A':begin
          result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyBeginText);
          inc(SourcePosition);
         end;
         'Z':begin
          result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyEndText);
          inc(SourcePosition);
         end;
         'p':begin
          inc(SourcePosition);
          UnicodeCharClass:=nil;
          try
           UnicodeCharClass:=TFLREUnicodeCharClass.Create;
           if not ParseClassEscapeUnicodeProperty(UnicodeCharClass,true) then begin
            raise EFLRE.Create('Syntax error');
           end;
           UnicodeCharClass.Canonicalized:=true;
           if assigned(UnicodeCharClass) then begin
            result:=NewUnicodeCharClass(UnicodeCharClass);
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          finally
           FreeAndNil(UnicodeCharClass);
          end;
         end;
         'P':begin
          inc(SourcePosition);
          UnicodeCharClass:=nil;
          try
           UnicodeCharClass:=TFLREUnicodeCharClass.Create;
           if not ParseClassEscapeUnicodeProperty(UnicodeCharClass,true) then begin
            raise EFLRE.Create('Syntax error');
           end;
           UnicodeCharClass.Invert;
           UnicodeCharClass.Inverted:=false;
           UnicodeCharClass.Canonicalized:=true;
           if assigned(UnicodeCharClass) then begin
            result:=NewUnicodeCharClass(UnicodeCharClass);
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          finally
           FreeAndNil(UnicodeCharClass);
          end;
         end;
         'g':begin
          inc(SourcePosition);
          if SourcePosition<=SourceLength then begin
           case Source[SourcePosition] of
            '-':begin
             inc(SourcePosition);
             Name:='-';
             if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) then begin
              repeat
               Name:=Name+Source[SourcePosition];
               inc(SourcePosition);
              until (SourcePosition>SourceLength) or not (Source[SourcePosition] in ['0'..'9']);
              result:=NewBackReferencePerName(Name,false);
             end else begin
              raise EFLRE.Create('Syntax error');
             end;   
            end;
            '0'..'9':begin
             Name:='';
             while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) do begin
              Name:=Name+Source[SourcePosition];
              inc(SourcePosition);
             end;
             result:=NewBackReferencePerName(Name,false);
            end;
            '{':begin
             TerminateChar:='}';
             inc(SourcePosition);
             Name:='';
             while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_','-']) do begin
              Name:=Name+Source[SourcePosition];
              inc(SourcePosition);
             end;
             if (SourcePosition<=SourceLength) and (Source[SourcePosition]=TerminateChar) then begin
              inc(SourcePosition);
              result:=NewBackReferencePerName(Name,false);
             end else begin
              raise EFLRE.Create('Syntax error');
             end;
            end;
            else begin
             raise EFLRE.Create('Syntax error');
            end;
           end;
          end else begin
           raise EFLRE.Create('Syntax error');
          end;
         end;
         'k':begin
          inc(SourcePosition);
          if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['{','''','<']) then begin
           case Source[SourcePosition] of
            '{':begin
             TerminateChar:='}';
            end;
            '<':begin
             TerminateChar:='>';
            end;
            else begin
             TerminateChar:='''';
            end;
           end;
           inc(SourcePosition);
           Name:='';
           while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9','A'..'Z','a'..'z','_','-']) do begin
            Name:=Name+Source[SourcePosition];
            inc(SourcePosition);
           end;
           if (SourcePosition<=SourceLength) and (Source[SourcePosition]=TerminateChar) then begin
            inc(SourcePosition);
            result:=NewBackReferencePerName(Name,false);
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          end else begin
           raise EFLRE.Create('Syntax error');
          end;
         end;
         'Q':begin
          inc(SourcePosition);
          while SourcePosition<=SourceLength do begin
           TemporaryNode:=nil;
           case Source[SourcePosition] of
            '\':begin
             inc(SourcePosition);
             if (SourcePosition<=SourceLength) and (Source[SourcePosition]='E') then begin
              inc(SourcePosition);
              break;
             end else begin
              TemporaryNode:=NewNode(ntCHAR,nil,nil,NewCharClass(['\'],true));
             end;
            end;
            #128..#255:begin
             if rfUTF8 in Flags then begin
              UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition);
              LowerCaseUnicodeChar:=UnicodeToLower(UnicodeChar);
              UpperCaseUnicodeChar:=UnicodeToUpper(UnicodeChar);
              if (rfIGNORECASE in Flags) and (LowerCaseUnicodeChar<>UpperCaseUnicodeChar) then begin
               TemporaryNode:=NewAlt(NewUnicodeChar(LowerCaseUnicodeChar),NewUnicodeChar(UpperCaseUnicodeChar));
              end else begin
               TemporaryNode:=NewUnicodeChar(UnicodeChar);
              end;
             end else begin
              TemporaryNode:=NewNode(ntCHAR,nil,nil,NewCharClass([Source[SourcePosition]],true));
              inc(SourcePosition);
             end;
            end;
            else begin
             if (rfIGNORECASE in Flags) and (Source[SourcePosition] in ['a'..'z','A'..'Z']) then begin
              UnicodeChar:=TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]));
              LowerCaseUnicodeChar:=UnicodeToLower(UnicodeChar);
              UpperCaseUnicodeChar:=UnicodeToUpper(UnicodeChar);
              TemporaryNode:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(LowerCaseUnicodeChar)),TFLRERawByteChar(TFLREUInt8(UpperCaseUnicodeChar))],true));
             end else begin
              TemporaryNode:=NewNode(ntCHAR,nil,nil,NewCharClass([Source[SourcePosition]],true));
              inc(SourcePosition);
             end;
            end;
           end;
           if assigned(TemporaryNode) then begin
            if assigned(result) then begin
             result:=Concat(result,TemporaryNode);
            end else begin
             result:=TemporaryNode;
            end;
           end else begin
            raise EFLRE.Create('Syntax error');
           end;
          end;
         end;
         else begin
          if (rfUTF8 in Flags) and (TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))>=$80) then begin
           UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition);
           result:=NewUnicodeChar(UnicodeChar);
          end else begin
           UnicodeCharClass:=nil;
           try
            UnicodeCharClass:=ParseClassEscape(true);
            if assigned(UnicodeCharClass) then begin
             result:=NewUnicodeCharClass(UnicodeCharClass);
            end else begin
             raise EFLRE.Create('Syntax error');
            end;
           finally
            FreeAndNil(UnicodeCharClass);
           end;
          end;
         end;
        end;
       end else begin
        raise EFLRE.Create('Syntax error');
       end;
      end;
      '[':begin
       UnicodeCharClass:=nil;
       try
        if TestClassPOSIXCharacterClass then begin
         UnicodeCharClass:=TFLREUnicodeCharClass.Create;
         if not ParseClassPOSIXCharacterClass(UnicodeCharClass,true) then begin
          raise EFLRE.Create('Syntax error');
         end;
        end else begin
         UnicodeCharClass:=ParseCharacterClass;
        end;
        if assigned(UnicodeCharClass) then begin
         result:=NewUnicodeCharClass(UnicodeCharClass);
        end else begin
         raise EFLRE.Create('Syntax error');
        end;
       finally
        FreeAndNil(UnicodeCharClass);
       end;
      end;
      '.':begin
       inc(SourcePosition);
       if rfUTF8 in Flags then begin
        UnicodeCharClass:=nil;
        try
         UnicodeCharClass:=TFLREUnicodeCharClass.Create;
         if rfSINGLELINE in Flags then begin
          UnicodeCharClass.AddRange($00000000,$ffffffff);
         end else begin
          UnicodeCharClass.AddChar(10);
          UnicodeCharClass.AddChar(13);
          UnicodeCharClass.Invert;
          UnicodeCharClass.Inverted:=false;
         end;
         result:=NewUnicodeCharClass(UnicodeCharClass);
        finally
         FreeAndNil(UnicodeCharClass);
        end;
       end else begin
        if rfSINGLELINE in Flags then begin
         result:=NewNode(ntCHAR,nil,nil,NewCharClass(AllCharClass,true));
        end else begin
         result:=NewNode(ntCHAR,nil,nil,NewCharClass(AllCharClass-[#10,#13],true));
        end;
       end;
      end;
      '^':begin
       if rfMULTILINE in Flags then begin
        result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyBeginLine);
       end else begin
        result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyBeginText);
       end;
       inc(SourcePosition);
      end;
      '$':begin
       if rfMULTILINE in Flags then begin
        result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyEndLine);
       end else begin
        result:=NewNode(ntZEROWIDTH,nil,nil,sfEmptyEndText);
       end;
       inc(SourcePosition);
      end;
      #128..#255:begin
       if rfUTF8 in Flags then begin
        UnicodeChar:=UTF8CodeUnitGetCharAndIncFallback(Source,SourcePosition);
        LowerCaseUnicodeChar:=UnicodeToLower(UnicodeChar);
        UpperCaseUnicodeChar:=UnicodeToUpper(UnicodeChar);
        if (rfIGNORECASE in Flags) and (LowerCaseUnicodeChar<>UpperCaseUnicodeChar) then begin
         result:=NewAlt(NewUnicodeChar(LowerCaseUnicodeChar),NewUnicodeChar(UpperCaseUnicodeChar));
        end else begin
         result:=NewUnicodeChar(UnicodeChar);
        end;
       end else begin
        result:=NewNode(ntCHAR,nil,nil,NewCharClass([Source[SourcePosition]],true));
        inc(SourcePosition);
       end;
      end;
      else begin
       if (rfIGNORECASE in Flags) and (Source[SourcePosition] in ['a'..'z','A'..'Z']) then begin
        UnicodeChar:=TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]));
        inc(SourcePosition);
        LowerCaseUnicodeChar:=UnicodeToLower(UnicodeChar);
        UpperCaseUnicodeChar:=UnicodeToUpper(UnicodeChar);
        result:=NewNode(ntCHAR,nil,nil,NewCharClass([TFLRERawByteChar(TFLREUInt8(LowerCaseUnicodeChar)),TFLRERawByteChar(TFLREUInt8(UpperCaseUnicodeChar))],true));
       end else begin
        result:=NewNode(ntCHAR,nil,nil,NewCharClass([Source[SourcePosition]],true));
        inc(SourcePosition);
       end;
      end;
     end;
    end else begin
     raise EFLRE.Create('Syntax error');
    end;
    if Done or assigned(result) or ((SourcePosition<=SourceLength) and (Source[SourcePosition] in ['|',')',#0])) then begin
     break;
    end else begin
     SkipFreeSpacingWhiteSpace;
    end;
   until false;
  except
   raise;
  end;
 end;
 function ParseTerm:PFLRENode;
 var MinCount,MaxCount,Kind:TFLREInt32;
 begin
  result:=nil;
  try
   if SourcePosition<=SourceLength then begin
    result:=ParseAtom;
    if SourcePosition<=SourceLength then begin
     case Source[SourcePosition] of
      '*':begin
       inc(SourcePosition);
       if not assigned(result) then begin
        raise EFLRE.Create('Syntax error');
       end;
       if ((SourcePosition<=SourceLength) and (Source[SourcePosition]='?')) xor (rfUNGREEDY in Flags) then begin
        inc(SourcePosition);
        result:=NewStar(result,qkLAZY);
        if rfLONGEST in Flags then begin
         raise EFLRE.Create('Syntax error');
        end;
       end else begin
        if rfLONGEST in Flags then begin
         result:=NewStar(result,qkLAZY);
        end else begin
         result:=NewStar(result,qkGREEDY);
        end;
       end;
      end;
      '+':begin
       inc(SourcePosition);
       if not assigned(result) then begin
        raise EFLRE.Create('Syntax error');
       end;
       if ((SourcePosition<=SourceLength) and (Source[SourcePosition]='?')) xor (rfUNGREEDY in Flags) then begin
        inc(SourcePosition);
        result:=NewPlus(result,qkLAZY);
        if rfLONGEST in Flags then begin
         raise EFLRE.Create('Syntax error');
        end;
       end else begin
        if rfLONGEST in Flags then begin
         result:=NewPlus(result,qkLAZY);
        end else begin
         result:=NewPlus(result,qkGREEDY);
        end;
       end;
      end;
      '?':begin
       inc(SourcePosition);
       if not assigned(result) then begin
        raise EFLRE.Create('Syntax error');
       end;
       if ((SourcePosition<=SourceLength) and (Source[SourcePosition]='?')) xor (rfUNGREEDY in Flags) then begin
        inc(SourcePosition);
        result:=NewQuest(result,qkLAZY);
        if rfLONGEST in Flags then begin
         raise EFLRE.Create('Syntax error');
        end;
       end else begin
        if rfLONGEST in Flags then begin
         result:=NewQuest(result,qkLAZY);
        end else begin
         result:=NewQuest(result,qkGREEDY);
        end;
       end;
      end;
      '{':begin
       inc(SourcePosition);
       if not assigned(result) then begin
        raise EFLRE.Create('Syntax error');
       end;
       if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) then begin
        MinCount:=0;
        while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) do begin
         MinCount:=(MinCount*10)+(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('0')));
         inc(SourcePosition);
        end;
       end else begin
        raise EFLRE.Create('Syntax error');
        MinCount:=-1;
       end;
       if (SourcePosition<=SourceLength) and (Source[SourcePosition]=',') then begin
        inc(SourcePosition);
        if (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) then begin
         MaxCount:=0;
         while (SourcePosition<=SourceLength) and (Source[SourcePosition] in ['0'..'9']) do begin
          MaxCount:=(MaxCount*10)+(TFLREUInt8(TFLRERawByteChar(Source[SourcePosition]))-TFLREUInt8(TFLRERawByteChar('0')));
          inc(SourcePosition);
         end;
         if MinCount>MaxCount then begin
          raise EFLRE.Create('Syntax error');
         end;
        end else begin
         MaxCount:=-1;
        end;
       end else begin
        MaxCount:=MinCount;
       end;
       if (SourcePosition<=SourceLength) and (Source[SourcePosition]='}') then begin
        inc(SourcePosition);
        if (SourcePosition<=SourceLength) and (Source[SourcePosition]='?') then begin
         inc(SourcePosition);
         if rfLONGEST in Flags then begin
          raise EFLRE.Create('Syntax error');
         end;
         Kind:=qkLAZY;
        end else begin
         if rfLONGEST in Flags then begin
          Kind:=qkLAZY;
         end else begin
          Kind:=qkGREEDY;
         end;
        end;
        result:=NewExact(result,MinCount,MaxCount,Kind);
       end else begin
        raise EFLRE.Create('Syntax error');
       end;
      end;
     end;
    end;
   end;
  except
   raise;
  end;
 end;
 function ParseAlternative:PFLRENode;
 var Node:PFLRENode;
 begin
  result:=nil;
  try
   SkipFreeSpacingWhiteSpace;
   while (SourcePosition<=SourceLength) and not (Source[SourcePosition] in ['|',')',#0]) do begin
    Node:=ParseTerm;
    SkipFreeSpacingWhiteSpace;
    if assigned(result) then begin
     result:=Concat(result,Node);
    end else begin
     result:=Node;
    end;
    if SourcePosition<=SourceLength then begin
     case Source[SourcePosition] of
      '|',')',#0:begin
       break;
      end;
     end;
    end else begin
     break;
    end;
   end;
  except
   raise;
  end;
 end;
 function ParseDisjunction:PFLRENode;
 var Node:PFLRENode;
 begin
  result:=nil;
  try
   SkipFreeSpacingWhiteSpace;
   repeat
    if (SourcePosition<=SourceLength) and not (Source[SourcePosition] in [')',#0]) then begin
     Node:=ParseAlternative;
    end else begin
     Node:=nil;
    end;
    if not assigned(Node) then begin
     Node:=NewEmptyMatch;
    end;
    SkipFreeSpacingWhiteSpace;
    if assigned(result) then begin
     result:=NewAlt(result,Node);
    end else begin
     result:=Node;
    end;
    if SourcePosition<=SourceLength then begin
     case Source[SourcePosition] of
      '|':begin
       inc(SourcePosition);
      end;
      ')',#0:begin
       break;
      end;
     end;
    end else begin
     break;
    end;
   until false;
  except
   raise;
  end;
 end;
 function ParseMultiMatch:PFLRENode;
 var Node:PFLRENode;
     OldFlags:TFLREFlags;
 begin
  result:=nil;
  try
   SkipFreeSpacingWhiteSpace;
   while SourcePosition<=SourceLength do begin
    OldFlags:=Flags;
    Node:=NewNode(ntMULTIMATCH,ParseDisjunction,nil,CountMultiSubMatches);
    Flags:=OldFlags;
    inc(CountMultiSubMatches);
    SkipFreeSpacingWhiteSpace;
    if assigned(result) then begin
     result:=NewAlt(result,Node);
    end else begin
     result:=Node;
    end;
    if (SourcePosition<=SourceLength) and (Source[SourcePosition]=#0) then begin
     inc(SourcePosition);
    end else begin
     break;
    end;
   end;
  except
   raise;
  end;
 end;
var Counter,SubCounter:TFLRESizeInt;
    SubMatchIndex:TFLREInt32;
    Node,SubNode:PFLRENode;
begin
 Source:=RegularExpression;
 SourcePosition:=1;
 SourceLength:=length(Source);
 begin
  NamedGroupStringIntegerPairHashMap.Add('wholematch',0);
  NamedGroupStringIndexList.Add(NamedGroupStringList.Add('wholematch'));
  NamedGroupStringIntegerPairHashMap.Add('0',0);
  NamedGroupStringList.Add('0');
  CountCaptures:=1;
  CountInternalCaptures:=1;
  SetLength(CapturesToSubMatchesMap,1);
  CapturesToSubMatchesMap[0]:=0;
  GroupIndexIntegerStack:=TFLREIntegerList.Create;
  GroupNameStringStack:=TStringList.Create;
  BackReferenceComparisonGroup:=false;
  try
   if rfMULTIMATCH in Flags then begin
    AnchoredRootNode:=NewNode(ntPAREN,ParseMultiMatch,nil,0);
   end else begin
    AnchoredRootNode:=NewNode(ntPAREN,ParseDisjunction,nil,0);
   end;
  finally
   GroupIndexIntegerStack.Free;
   GroupNameStringStack.Free;
  end;
  FreeUnusedNodes(AnchoredRootNode);
  if assigned(AnchoredRootNode) and not (rfONLYFASTOPTIMIZATIONS in Flags) then begin
   if OptimizeNode(@AnchoredRootNode) then begin
    FreeUnusedNodes(AnchoredRootNode);
   end;
  end;
  if rfLONGEST in Flags then begin
   UnanchoredRootNode:=NewNode(ntCAT,NewNode(ntSTAR,NewNode(ntCHAR,nil,nil,NewCharClass(AllCharClass,false)),nil,qkGREEDY),AnchoredRootNode,0);
  end else begin
   UnanchoredRootNode:=NewNode(ntCAT,NewNode(ntSTAR,NewNode(ntCHAR,nil,nil,NewCharClass(AllCharClass,false)),nil,qkLAZY),AnchoredRootNode,0);
  end;
  InternalFlags:=InternalFlags-[fifDFANeedVerification,fifHasWordBoundaries,fifHasNewLineAssertions,fifHasLookAssertions,fifHasBackReferences];
  for Counter:=0 to Nodes.Count-1 do begin
   Node:=Nodes[Counter];
   case Node^.NodeType of
    ntMULTIMATCH:begin
     Include(InternalFlags,fifDFANeedVerification);
    end;
    ntZEROWIDTH:begin
     //DFANeedVerification:=true;
     Exclude(InternalFlags,fifDFAFast);
     if (Node^.Value and (sfEmptyBeginLine or sfEmptyEndLine or sfEmptyBeginText or sfEmptyEndText))<>0 then begin
      Include(InternalFlags,fifHasNewLineAssertions);
     end;
     if (Node^.Value and (sfEmptyWordBoundary or sfEmptyNonWordBoundary))<>0 then begin
      Include(InternalFlags,fifHasWordBoundaries);
     end;
    end;
    ntLOOKBEHINDNEGATIVE,ntLOOKBEHINDPOSITIVE,ntLOOKAHEADNEGATIVE,ntLOOKAHEADPOSITIVE:begin
     InternalFlags:=InternalFlags+[fifDFANeedVerification,fifHasLookAssertions];
    end;
    ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
     InternalFlags:=InternalFlags+[fifDFANeedVerification,fifHasBackReferences];
     if Node^.Group<0 then begin
      Node^.Group:=NamedGroupStringIntegerPairHashMap[Node^.Name];
      Node^.Name:='';
     end;
     if (Node^.Group<0) or (Node^.Group>=CountCaptures) then begin
      raise EFLRE.Create('Syntax error');
     end;
     if (Node^.Flags and 1)=0 then begin
      Node^.Left:=nil;
      SubMatchIndex:=CapturesToSubMatchesMap[Node^.Group];
      for SubCounter:=0 to Nodes.Count-1 do begin
       SubNode:=Nodes[SubCounter];
       if (Node<>SubNode) and (SubNode^.NodeType=ntPAREN) and (SubNode^.Value=SubMatchIndex) then begin
        Node^.Left:=SubNode;
        break;
       end;
      end;
     end;
     if not assigned(Node^.Left) then begin
      raise EFLRE.Create('Syntax error');
     end;
    end;
   end;
  end;
  if SourcePosition<=SourceLength then begin
   raise EFLRE.Create('Syntax error');
  end;
 end;
end;

procedure TFLRE.Compile;
 procedure GenerateInstructions(var Instructions:TFLREInstructions;var CountInstructions:TFLREInt32;const Reversed:boolean);
 var NodeStack:TFLREPointerList;
  function NewInstruction(Opcode:TFLREUInt32):TFLREInt32;
  begin
   result:=CountInstructions;
   inc(CountInstructions);
   if CountInstructions>length(Instructions) then begin
    SetLength(Instructions,CountInstructions*2);
   end;
   Instructions[result].IDandOpcode:=(TFLREUInt32(result) shl 8) or (Opcode and $ff);
   Instructions[result].Next:=pointer(TFLREPtrInt(-1));
   Instructions[result].OtherNext:=pointer(TFLREPtrInt(-1));
  end;
  procedure Emit(Node,BackreferenceParentNode:PFLRENode);
  type PStackItem=^TStackItem;
       TStackItem=record
        Node,BackreferenceParentNode:PFLRENode;
        Argument,i0,i1{$ifndef UseOpcodeJMP},FromIndex,ToIndex,OutIndex{$endif}:TFLREInt32;
       end;
       TStackItems=array of TStackItem;
  var Stack:TStackItems;
      StackItem:PStackItem;
      StackSize,Count,Argument,i0,i1,Index{$ifndef UseOpcodeJMP},FromIndex,ToIndex,OutIndex{$endif},Flags:TFLREInt32;
      CurrentChar,SingleChar:TFLRERawByteChar;
      CharClass:TFLRECharClass;
  begin
   Stack:=nil;
   try
    SetLength(Stack,(Nodes.Count*2)+16);
    StackSize:=0;
    StackItem:=@Stack[StackSize];
    StackItem^.Node:=Node;
    StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
    StackItem^.Argument:=0;
    inc(StackSize);
    while StackSize>0 do begin
     dec(StackSize);
     StackItem:=@Stack[StackSize];
     Node:=StackItem^.Node;
     BackreferenceParentNode:=StackItem^.BackreferenceParentNode;
     Argument:=StackItem^.Argument;
     i0:=StackItem^.i0;
     i1:=StackItem^.i1;
{$ifndef UseOpcodeJMP}
     FromIndex:=StackItem^.FromIndex;
     ToIndex:=StackItem^.ToIndex;
     OutIndex:=StackItem^.OutIndex;
{$endif}
     if assigned(Node) and ((Argument<>0) or (NodeStack.IndexOf(Node)<0)) then begin
      case Node^.NodeType of
       ntALT:begin
        case Argument of
         0:begin
          i0:=NewInstruction(opSPLIT);
          Instructions[i0].Value:=skALT;
          Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
{$ifndef UseOpcodeJMP}
          FromIndex:=CountInstructions;
{$endif}
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=1;
           StackItem^.i0:=i0;
{$ifndef UseOpcodeJMP}
           StackItem^.FromIndex:=FromIndex;
{$endif}
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Left;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         1:begin
{$ifndef UseOpcodeJMP}
          ToIndex:=CountInstructions-1;
          OutIndex:=CountInstructions;
{$endif}
{$ifdef UseOpcodeJMP}
          i1:=NewInstruction(opJMP);
{$endif}
          Instructions[i0].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=2;
           StackItem^.i0:=i0;
           StackItem^.i1:=i1;
{$ifndef UseOpcodeJMP}
           StackItem^.FromIndex:=FromIndex;
           StackItem^.ToIndex:=ToIndex;
           StackItem^.OutIndex:=OutIndex;
{$endif}
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Right;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         2:begin
{$ifdef UseOpcodeJMP}
          Instructions[i1].Next:=pointer(TFLREPtrInt(CountInstructions));
{$else}
          for Index:=FromIndex to ToIndex do begin
           if TFLREPtrUInt(Instructions[Index].Next)=TFLREPtrUInt(OutIndex) then begin
            Instructions[Index].Next:=pointer(TFLREPtrUInt(CountInstructions));
           end;
           if TFLREPtrUInt(Instructions[Index].OtherNext)=TFLREPtrUInt(OutIndex) then begin
            Instructions[Index].OtherNext:=pointer(TFLREPtrUInt(CountInstructions));
           end;
          end;
{$endif}
         end;
        end;
       end;
       ntCAT:begin
        if Reversed then begin
         begin
          if (StackSize+1)>length(Stack) then begin
           SetLength(Stack,(StackSize+1)*2);
          end;
          StackItem:=@Stack[StackSize];
          inc(StackSize);
          StackItem^.Node:=Node^.Left;
          StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
          StackItem^.Argument:=0;
         end;
         begin
          if (StackSize+1)>length(Stack) then begin
           SetLength(Stack,(StackSize+1)*2);
          end;
          StackItem:=@Stack[StackSize];
          inc(StackSize);
          StackItem^.Node:=Node^.Right;
          StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
          StackItem^.Argument:=0;
         end;
        end else begin
         begin
          if (StackSize+1)>length(Stack) then begin
           SetLength(Stack,(StackSize+1)*2);
          end;
          StackItem:=@Stack[StackSize];
          inc(StackSize);
          StackItem^.Node:=Node^.Right;
          StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
          StackItem^.Argument:=0;
         end;
         begin
          if (StackSize+1)>length(Stack) then begin
           SetLength(Stack,(StackSize+1)*2);
          end;
          StackItem:=@Stack[StackSize];
          inc(StackSize);
          StackItem^.Node:=Node^.Left;
          StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
          StackItem^.Argument:=0;
         end;
        end;
       end;
       ntCHAR:begin
        CharClass:=GetCharClass(Node^.Value);
        if CharClass=EmptyCharClass then begin
         i0:=NewInstruction(opNONE);
         Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        end else if CharClass=AllCharClass then begin
         i0:=NewInstruction(opANY);
         Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        end else begin
         SingleChar:=#0;
         Count:=0;
         for CurrentChar:=#0 to #255 do begin
          if CurrentChar in CharClass then begin
           if Count=0 then begin
            SingleChar:=CurrentChar;
            inc(Count);
           end else begin
            inc(Count);
            break;
           end;
          end;
         end;
         if Count=1 then begin
          i0:=NewInstruction(opSINGLECHAR);
          Instructions[i0].Value:=TFLREUInt8(TFLRERawByteChar(SingleChar));
         end else begin
          i0:=NewInstruction(opCHAR);
          Instructions[i0].Value:=TFLREPtrUInt(pointer(CharClasses[Node^.Value]));
         end;
         Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        end;
       end;
       ntPAREN:begin
        case Argument of
         0:begin
          if assigned(BackreferenceParentNode) then begin
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node^.Left;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=0;
           end;
          end else begin
           i0:=NewInstruction(opSAVE);
           Instructions[i0].Value:=Node^.Value shl 1;
           Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=1;
           end;
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node^.Left;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=0;
           end;
          end;
         end;
         1:begin
          i0:=NewInstruction(opSAVE);
          Instructions[i0].Value:=(Node^.Value shl 1) or 1;
          Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
         end;
        end;
       end;
       ntQUEST:begin
        case Argument of
         0:begin
          i0:=NewInstruction(opSPLIT);
          Instructions[i0].Value:=skQUEST;
          if Node^.Value<>0 then begin
           // Non-greedy
           Instructions[i0].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=1;
            StackItem^.i0:=i0;
           end;
          end else begin
           // Greedy
           Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=2;
            StackItem^.i0:=i0;
           end;
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Left;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         1:begin
          // Non-greedy
          Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
         end;
         2:begin
          // Greedy
          Instructions[i0].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
         end;
        end;
       end;
       ntSTAR:begin
        case Argument of
         0:begin
          i0:=NewInstruction(opSPLIT);
          Instructions[i0].Value:=skSTAR;
          if Node^.Value<>0 then begin
           // Non-greedy
           Instructions[i0].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
{$ifndef UseOpcodeJMP}
           FromIndex:=CountInstructions;
{$endif}
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=1;
           StackItem^.i0:=i0;
{$ifndef UseOpcodeJMP}
           StackItem^.FromIndex:=FromIndex;
{$endif}
          end else begin
           // Greedy
           Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
{$ifndef UseOpcodeJMP}
           FromIndex:=CountInstructions;
{$endif}
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=2;
           StackItem^.i0:=i0;
{$ifndef UseOpcodeJMP}
           StackItem^.FromIndex:=FromIndex;
{$endif}
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Left;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         1,2:begin
{$ifndef UseOpcodeJMP}
          ToIndex:=CountInstructions-1;
          OutIndex:=CountInstructions;
{$endif}
{$ifdef UseOpcodeJMP}
          i1:=NewInstruction(opJMP);
          Instructions[i1].Next:=pointer(TFLREPtrInt(i0));
{$endif}
          case Argument of
           1:begin
            // Non-greedy
            Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
           end;
           2:begin
            // Greedy
            Instructions[i0].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
           end;
          end;
{$ifndef UseOpcodeJMP}
          for Index:=FromIndex to ToIndex do begin
           if TFLREPtrUInt(Instructions[Index].Next)=TFLREPtrUInt(OutIndex) then begin
            Instructions[Index].Next:=pointer(TFLREPtrUInt(i0));
           end;
           if TFLREPtrUInt(Instructions[Index].OtherNext)=TFLREPtrUInt(OutIndex) then begin
            Instructions[Index].OtherNext:=pointer(TFLREPtrUInt(i0));
           end;
          end;
{$endif}
         end;
        end;
       end;
       ntPLUS:begin
        case Argument of
         0:begin
          i0:=CountInstructions;
          if Node^.Value<>0 then begin
           // Non-greedy
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=1;
           StackItem^.i0:=i0;
          end else begin
           // Greedy
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=2;
           StackItem^.i0:=i0;
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Left;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         1:begin  
          // Non-greedy
          i1:=NewInstruction(opSPLIT);
          Instructions[i1].Value:=skPLUS;
          Instructions[i1].OtherNext:=pointer(TFLREPtrInt(i0));
          Instructions[i1].Next:=pointer(TFLREPtrInt(CountInstructions));
         end;
         2:begin
          // Greedy
          i1:=NewInstruction(opSPLIT);
          Instructions[i1].Value:=skPLUS;
          Instructions[i1].Next:=pointer(TFLREPtrInt(i0));
          Instructions[i1].OtherNext:=pointer(TFLREPtrInt(CountInstructions));
         end;
        end;
       end;
       ntMULTIMATCH:begin
        case Argument of
         0:begin
          if not assigned(BackreferenceParentNode) then begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=1;
          end;
          begin
           if (StackSize+1)>length(Stack) then begin
            SetLength(Stack,(StackSize+1)*2);
           end;
           StackItem:=@Stack[StackSize];
           inc(StackSize);
           StackItem^.Node:=Node^.Left;
           StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
           StackItem^.Argument:=0;
          end;
         end;
         1:begin
          i0:=NewInstruction(opMATCH);
          Instructions[i0].Value:=Node^.Value;
          Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
         end;
        end;
       end;
       ntZEROWIDTH:begin
        if Reversed then begin
         Flags:=Node^.Value and (sfEmptyWordBoundary or sfEmptyNonWordBoundary);
         if (Node^.Value and sfEmptyBeginLine)<>0 then begin
          Flags:=Flags or sfEmptyEndLine;
         end;
         if (Node^.Value and sfEmptyEndLine)<>0 then begin
          Flags:=Flags or sfEmptyBeginLine;
         end;
         if (Node^.Value and sfEmptyBeginText)<>0 then begin
          Flags:=Flags or sfEmptyEndText;
         end;
         if (Node^.Value and sfEmptyEndText)<>0 then begin
          Flags:=Flags or sfEmptyBeginText;
         end;
        end else begin
         Flags:=Node^.Value;
        end;
        if Flags<>0 then begin
         i0:=NewInstruction(opZEROWIDTH);
         Instructions[i0].Value:=Flags;
         Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        end else begin
         i0:=NewInstruction(opNOP);
         Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        end;
       end;
       ntLOOKBEHINDNEGATIVE:begin
        i0:=NewInstruction(opLOOKBEHINDNEGATIVE);
        Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        Instructions[i0].Value:=Node^.Value;
       end;
       ntLOOKBEHINDPOSITIVE:begin
        i0:=NewInstruction(opLOOKBEHINDPOSITIVE);
        Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        Instructions[i0].Value:=Node^.Value;
       end;
       ntLOOKAHEADNEGATIVE:begin
        i0:=NewInstruction(opLOOKAHEADNEGATIVE);
        Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        Instructions[i0].Value:=Node^.Value;
       end;
       ntLOOKAHEADPOSITIVE:begin
        i0:=NewInstruction(opLOOKAHEADPOSITIVE);
        Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
        Instructions[i0].Value:=Node^.Value;
       end;
       ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
        if Reversed then begin
         case Argument of
          0:begin
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=1;
           end;
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node^.Left;
            if assigned(BackreferenceParentNode) then begin
             StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            end else begin
             StackItem^.BackreferenceParentNode:=Node;
            end;
            StackItem^.Argument:=0;
           end;
           NodeStack.Add(Node);
          end;
          1:begin
           NodeStack.Delete(NodeStack.Count-1);
          end;
         end;
        end else begin
         case Argument of
          0:begin
           i0:=NewInstruction(opSAVE);
           Instructions[i0].Value:=Node^.Value shl 1;
           Instructions[i0].Next:=pointer(TFLREPtrInt(CountInstructions));
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node;
            StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            StackItem^.Argument:=1;
            StackItem^.i0:=i0;
           end;
           begin
            if (StackSize+1)>length(Stack) then begin
             SetLength(Stack,(StackSize+1)*2);
            end;
            StackItem:=@Stack[StackSize];
            inc(StackSize);
            StackItem^.Node:=Node^.Left;
            if assigned(BackreferenceParentNode) then begin
             StackItem^.BackreferenceParentNode:=BackreferenceParentNode;
            end else begin
             StackItem^.BackreferenceParentNode:=Node;
            end;
            StackItem^.Argument:=0;
           end;
           NodeStack.Add(Node);
          end;
          1:begin
           NodeStack.Delete(NodeStack.Count-1);
           i1:=NewInstruction(opSAVE);
           Instructions[i1].Value:=(Node^.Value shl 1) or 1;
           Instructions[i1].Next:=pointer(TFLREPtrInt(CountInstructions));
           if Node^.NodeType=ntBACKREFERENCEIGNORECASE then begin
            i1:=NewInstruction(opBACKREFERENCEIGNORECASE);
           end else begin
            i1:=NewInstruction(opBACKREFERENCE);
           end;
           Instructions[i1].Value:=CapturesToSubMatchesMap[Node^.Group] shl 1;
           Instructions[i1].Next:=pointer(TFLREPtrInt(CountInstructions));
           Instructions[i1].OtherNext:=pointer(TFLREPtrInt(i0));
          end;
         end;
        end;
       end;
       else begin
        raise EFLRE.Create('Internal error');
       end;
      end;
     end;
    end;
   finally
    SetLength(Stack,0);
   end;
  end;
 var Counter:TFLRESizeInt;
     Instruction:PFLREInstruction;
 begin
  SetLength(Instructions,4096);
  CountInstructions:=0;
  try
   try
    NodeStack:=TFLREPointerList.Create;
    try
     if Reversed then begin
      Emit(AnchoredRootNode,nil);
     end else begin
      Emit(UnanchoredRootNode,nil);
     end;
    finally
     NodeStack.Free;
    end;
   except
    CountInstructions:=0;
    raise;
   end;
   Instructions[NewInstruction(opMATCH)].Value:=-1;
  finally
   SetLength(Instructions,CountInstructions);
   for Counter:=0 to CountInstructions-1 do begin
    Instruction:=@Instructions[Counter];
    if Instruction^.Next<>pointer(TFLREPtrUInt(TFLREPtrInt(-1))) then begin
     Instruction^.Next:=@Instructions[TFLREPtrUInt(Instruction^.Next)];
    end else begin
     Instruction^.Next:=nil;
    end;
    if Instruction^.OtherNext<>pointer(TFLREPtrUInt(TFLREPtrInt(-1))) then begin
     Instruction^.OtherNext:=@Instructions[TFLREPtrUInt(Instruction^.OtherNext)];
    end else begin
     Instruction^.OtherNext:=nil;
    end;
   end;
   for Counter:=0 to CountInstructions-1 do begin
    Instruction:=@Instructions[Counter];
    if (Instruction^.IDandOpcode and $ff)=opSPLIT then begin
     if ((((Instruction^.Next^.IDandOpcode and $ff)=opANY) or
          (((Instruction^.Next^.IDandOpcode and $ff)=opCHAR) and (PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Next^.Value)))^=AllCharClass))) and
         ((Instruction^.OtherNext^.IDandOpcode and $ff)=opMATCH)) or
        ((((Instruction^.OtherNext^.IDandOpcode and $ff)=opANY) or
          (((Instruction^.OtherNext^.IDandOpcode and $ff)=opCHAR) and (PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.OtherNext^.Value)))^=AllCharClass))) and
         ((Instruction^.Next^.IDandOpcode and $ff)=opMATCH)) then begin
      Instruction^.IDandOpcode:=(TFLREUInt32(Instruction^.IDandOpcode) and TFLREUInt32($ffffff00)) or opSPLITMATCH;
     end;
    end;
   end;
   if Reversed then begin
    ReversedStartInstruction:=@Instructions[0];
   end else begin
    AnchoredStartInstruction:=@Instructions[0];
    UnanchoredStartInstruction:=@Instructions[0];
    for Counter:=0 to CountInstructions-1 do begin
     Instruction:=@Instructions[Counter];
     if ((Instruction^.IDandOpcode and $ff)=opSAVE) and (Instruction^.Value=0) then begin
      AnchoredStartInstruction:=Instruction;
      break;
     end;
    end;
   end;
  end;
 end;
begin
 GenerateInstructions(ForwardInstructions,CountForwardInstructions,false);
 GenerateInstructions(BackwardInstructions,CountBackwardInstructions,true);
end;

procedure TFLRE.CompileRange;
var LowRangeString,HighRangeString:TFLRERawByteString;
    LastIndex,LastMatchIndex,RangeStringLength:TFLRESizeInt;
 function AddChars(Index:TFLRESizeInt;const Str:TFLRERawByteString):TFLRESizeInt;
 var Len,Counter,NewLen:TFLRESizeInt;
 begin
  Len:=length(Str);
  result:=Index+Len;
  if RangeStringLength<result then begin
   Counter:=RangeStringLength+1;
   RangeStringLength:=result;
   NewLen:=RoundUpToPowerOfTwo(result);
   if NewLen<16 then begin
    NewLen:=16;
   end;
   if length(LowRangeString)<NewLen then begin
    SetLength(LowRangeString,NewLen);
   end;
   if length(HighRangeString)<NewLen then begin
    SetLength(HighRangeString,NewLen);
   end;
   while Counter<=result do begin
    LowRangeString[Counter]:=Str[Counter-Index];
    HighRangeString[Counter]:=Str[Counter-Index];
    inc(Counter);
   end;
  end;
  for Counter:=1 to Len do begin
   if LowRangeString[Counter+Index]>Str[Counter] then begin
    LowRangeString[Counter+Index]:=Str[Counter];
   end;
   if HighRangeString[Counter+Index]<Str[Counter] then begin
    HighRangeString[Counter+Index]:=Str[Counter];
   end;
  end;
 end;
 procedure ThreadPass(Instruction:PFLREInstruction;Index:TFLRESizeInt);
 var CurrentChar:TFLRERawByteChar;
 begin
  while assigned(Instruction) do begin
   case Instruction^.IDandOpcode and $ff of
    opSPLIT,opSPLITMATCH:begin
     if Instruction^.Value in [skALT,skQUEST] then begin
      ThreadPass(Instruction^.OtherNext,Index);
      Instruction:=Instruction^.Next;
     end else begin
      if (LastIndex<0) or (Index<LastIndex) then begin
       LastIndex:=Index;
      end;
      break;
     end;
    end;
    opNONE:begin
     // Match against nothing
     if (LastIndex<0) or (Index<LastIndex) then begin
      LastIndex:=Index;
     end;
     break;
    end;
    opSINGLECHAR:begin
     AddChars(Index,TFLRERawByteChar(TFLREUInt8(Instruction^.Value)));
     inc(Index);
     Instruction:=Instruction^.Next;
    end;
    opCHAR:begin
     for CurrentChar:=#0 to #255 do begin
      if CurrentChar in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^ then begin
       AddChars(Index,TFLRERawByteChar(TFLREUInt8(CurrentChar)));
       break;
      end;
     end;
     for CurrentChar:=#255 downto #0 do begin
      if CurrentChar in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^ then begin
       AddChars(Index,TFLRERawByteChar(TFLREUInt8(CurrentChar)));
       break;
      end;
     end;
     inc(Index);
     Instruction:=Instruction^.Next;
    end;
    opANY:begin
     AddChars(Index,#0);
     AddChars(Index,#255);
     inc(Index);
     Instruction:=Instruction^.Next;
    end;
    {$ifdef UseOpcodeJMP}opJMP,{$endif}opSAVE,opZEROWIDTH,opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE,opNOP:begin
     Instruction:=Instruction^.Next;
    end;
    opMATCH:begin
     if (LastMatchIndex<0) or (Index<LastMatchIndex) then begin
      LastMatchIndex:=Index;
     end;
     break;
    end;
    else begin
     if (LastIndex<0) or (Index<LastIndex) then begin
      LastIndex:=Index;
     end;
     break;
    end;
   end;
  end;
 end;
begin
 LowRangeString:='';
 HighRangeString:='';
 if not (fifHasRange in InternalFlags) then begin
  RangeLow:=#$00;
  RangeHigh:=#$ff;
  RangeStringLength:=0;
  try
   LastIndex:=-1;
   LastMatchIndex:=-1;
   if assigned(AnchoredStartInstruction) then begin
    ThreadPass(AnchoredStartInstruction,0);
   end;
   if LastMatchIndex>=0 then begin
    if LastMatchIndex<RangeStringLength then begin
     RangeStringLength:=LastMatchIndex;
//   LastIndex:=LastMatchIndex;
    end;
    if LastMatchIndex<LastIndex then begin
     LastIndex:=LastMatchIndex;
    end;
   end;
   if LastIndex<0 then begin
    while (RangeStringLength>1) and ((LowRangeString[RangeStringLength]=#0) and (HighRangeString[RangeStringLength]=#255)) do begin
     dec(RangeStringLength);
     LastIndex:=RangeStringLength;
    end;
   end;
   if LastIndex=0 then begin
    LowRangeString:=#$00;
    HighRangeString:=#$ff;
    RangeStringLength:=1;
   end else if LastIndex>0 then begin
    while LastIndex>0 do begin
     while (LastIndex>1) and ((LowRangeString[LastIndex]=#0) and (HighRangeString[LastIndex]=#255)) do begin
      dec(LastIndex);
     end;
     if HighRangeString[LastIndex]<#$ff then begin
      inc(HighRangeString[LastIndex]);
     end;
     if (LastIndex<2) or ((LowRangeString[LastIndex]<>#0) or (HighRangeString[LastIndex]<>#255)) then begin
      break;
     end;
    end;
    RangeStringLength:=LastIndex;
   end;
   SetLength(LowRangeString,RangeStringLength);
   SetLength(HighRangeString,RangeStringLength);
   RangeLow:=LowRangeString;
   RangeHigh:=HighRangeString;
   Include(InternalFlags,fifHasRange);
  finally
   LowRangeString:='';
   HighRangeString:='';
  end;
 end;
end;

procedure TFLRE.CompilePrefix;
type TStackItem=record
      Node:PFLRENode;
      Argument:TFLREPtrInt;
     end;
var Node:PFLRENode;
    Argument:TFLREPtrInt;
    StackPointer,Counter:TFLREInt32;
    NodeStrings:array of TFLRERawByteString;
    Stack:array of TStackItem;
    Stop,First,IsSingle:boolean;
    SingleChar,CurrentChar:TFLRERawByteChar;
    CharClass:TFLRECharClass;
begin
 NodeStrings:=nil;
 Stack:=nil;
 FixedString:='';
 FixedStringIsWholeRegExp:=false;
 try
  SetLength(NodeStrings,Nodes.Count);
  StackPointer:=Nodes.Count;
  for Counter:=0 to Nodes.Count-1 do begin
   Node:=Nodes[Counter];
   if assigned(Node) then begin
    case Node^.NodeType of
     ntCAT:begin
      inc(StackPointer,2);
     end;
    end;
   end;
  end;
  SetLength(Stack,StackPointer+1);
  for Counter:=0 to length(NodeStrings)-1 do begin
   NodeStrings[Counter]:='';
  end;
  StackPointer:=0;
  if assigned(UnanchoredRootNode) then begin
   Stack[StackPointer].Node:=AnchoredRootNode;
   Stack[StackPointer].Argument:=0;
   inc(StackPointer);
   FixedStringIsWholeRegExp:=true;
  end;
  Stop:=false;
  while StackPointer>0 do begin
   dec(StackPointer);
   Node:=Stack[StackPointer].Node;
   Argument:=Stack[StackPointer].Argument;
   while assigned(Node) do begin
    case Node^.NodeType of
     ntPAREN,ntMULTIMATCH:begin
      case Argument of
       1:begin
        if assigned(Node^.Left) then begin
         NodeStrings[Node^.Index]:=NodeStrings[Node^.Left^.Index];
        end;
       end;
       else begin
        if assigned(Node^.Left) and not Stop then begin
         Stack[StackPointer].Node:=Node;
         Stack[StackPointer].Argument:=1;
         inc(StackPointer);
         Node:=Node^.Left;
         Argument:=0;
         continue;
        end;
       end;
      end;
     end;
     ntCAT:begin
      case Argument of
       2:begin
        if assigned(Node^.Left) and assigned(Node^.Right) then begin
         NodeStrings[Node^.Index]:=NodeStrings[Node^.Left^.Index]+NodeStrings[Node^.Right^.Index];
        end else if assigned(Node^.Left) then begin
         NodeStrings[Node^.Index]:=NodeStrings[Node^.Left^.Index];
        end else if assigned(Node^.Right) then begin
         NodeStrings[Node^.Index]:=NodeStrings[Node^.Right^.Index];
        end;
       end;
       1:begin
        if assigned(Node^.Right) and not Stop then begin
         Stack[StackPointer].Node:=Node;
         Stack[StackPointer].Argument:=2;
         inc(StackPointer);
         Node:=Node^.Right;
         Argument:=0;
        end else begin
         Argument:=2;
        end;
        continue;
       end;
       else {0:}begin
        NodeStrings[Node^.Index]:='';
        if assigned(Node^.Left) and not Stop then begin
         Stack[StackPointer].Node:=Node;
         Stack[StackPointer].Argument:=1;
         inc(StackPointer);
         Node:=Node^.Left;
         Argument:=0;
         continue;
        end else begin
         if assigned(Node^.Right) and not Stop then begin
          Stack[StackPointer].Node:=Node;
          Stack[StackPointer].Argument:=2;
          inc(StackPointer);
          Node:=Node^.Right;
          Argument:=0;
          continue;
         end;
        end;
       end;
      end;
     end;
     ntPLUS:begin
      case Argument of
       1:begin
        if assigned(Node^.Left) then begin
         NodeStrings[Node^.Index]:=NodeStrings[Node^.Left^.Index];
        end;
        FixedStringIsWholeRegExp:=false;
        Stop:=true;
       end;
       else {0:}begin
        NodeStrings[Node^.Index]:='';
        if assigned(Node^.Left) and not Stop then begin
         Stack[StackPointer].Node:=Node;
         Stack[StackPointer].Argument:=1;
         inc(StackPointer);
         Node:=Node^.Left;
         Argument:=0;
         continue;
        end;
       end;
      end;
     end;
     ntCHAR:begin
      CharClass:=GetCharClass(Node^.Value);
      First:=true;
      IsSingle:=false;
      SingleChar:=#0;
      for CurrentChar:=#0 to #255 do begin
       if CurrentChar in CharClass then begin
        if First then begin
         IsSingle:=true;
         First:=false;
         SingleChar:=CurrentChar;
        end else begin
         IsSingle:=false;
        end;
       end;
      end;
      if IsSingle then begin
       NodeStrings[Node^.Index]:=SingleChar;
      end else begin
       NodeStrings[Node^.Index]:='';
       FixedStringIsWholeRegExp:=false;
       Stop:=true;
      end;
     end;
     ntZEROWIDTH,ntLOOKBEHINDNEGATIVE,ntLOOKBEHINDPOSITIVE,ntLOOKAHEADNEGATIVE,ntLOOKAHEADPOSITIVE:begin
      // No-op instruction here, so don't stop but mark it as non-pure-string-literal regular expression
      FixedStringIsWholeRegExp:=false;
     end;
     else begin
      FixedStringIsWholeRegExp:=false;
      Stop:=true;
     end;
    end;
    break;
   end;
  end;
  if assigned(AnchoredRootNode) then begin
   FixedString:=NodeStrings[AnchoredRootNode^.Index];
  end else begin
   FixedString:='';
  end;
  FixedStringIsWholeRegExp:=FixedStringIsWholeRegExp and (length(FixedString)>0);
 finally
  SetLength(NodeStrings,0);
  SetLength(Stack,0);
 end;
end;

procedure TFLRE.CompileFixedStringSearch;
var //c:TFLRERawByteChar;
    i,j,k:TFLRESizeInt;
    HasMatch:boolean;
begin
 FixedStringLength:=length(FixedString);
 if FixedStringLength>1 then begin
  if FixedStringLength<32 then begin
   if not assigned(FixedStringPatternBitMasks) then begin
    GetMem(FixedStringPatternBitMasks,SizeOf(TFLRECharPatternBitMasks));
   end;
   FillChar(FixedStringPatternBitMasks^,SizeOf(TFLRECharPatternBitMasks),#$0);
   for i:=1 to FixedStringLength do begin
    FixedStringPatternBitMasks^[FixedString[i]]:=FixedStringPatternBitMasks^[FixedString[i]] or (1 shl (i-1));
   end;
  end else begin
   if not assigned(FixedStringBoyerMooreSkip) then begin
    GetMem(FixedStringBoyerMooreSkip,SizeOf(TFLRECharPatternBitMasks));
   end;
   FillChar(FixedStringBoyerMooreSkip^,SizeOf(TFLRECharPatternBitMasks),#$0);
   for i:=1 to FixedStringLength do begin
    FixedStringBoyerMooreSkip^[FixedString[i]]:=((FixedStringLength-(i-1))-1);
   end;
   SetLength(FixedStringBoyerMooreNext,FixedStringLength+1);
   for j:=0 to FixedStringLength do begin
    i:=FixedStringLength-1;
    while i>=1 do begin
     HasMatch:=true;
     for k:=1 to j do begin
      if (i-k)<0 then begin
       break;
      end;
      if FixedString[(FixedStringLength-k)+1]<>FixedString[(i-k)+1] then begin
       HasMatch:=false;
       break;
      end;
     end;
     if HasMatch then begin
      break;
     end;
     dec(i);
    end;
    FixedStringBoyerMooreNext[j]:=FixedStringLength-i;
   end;
  end;
 end;
end;

procedure TFLRE.CompilePrefixCharClasses;
type PThread=^TThread;
     TThread=record
      Instruction:PFLREInstruction;
     end;
     TThreads=array of TThread;
     PThreadList=^TThreadList;
     TThreadList=record
      Threads:TThreads;
      Count:TFLREInt32;
     end;
     TThreadLists=array[0..1] of TThreadList;
var CurrentPosition:TFLRESizeInt;
    Generation:TFLREInt64;
    InstructionGenerations:TFLREInstructionGenerations;
    PrefixCharClasses:TFLREPrefixCharClasses;
 procedure AddThread(const ThreadList:PThreadList;Instruction:PFLREInstruction);
 begin
  while assigned(Instruction) do begin
   if InstructionGenerations[Instruction^.IDandOpcode shr 8]=Generation then begin
    break;
   end else begin
    InstructionGenerations[Instruction^.IDandOpcode shr 8]:=Generation;
    case Instruction^.IDandOpcode and $ff of
{$ifdef UseOpcodeJMP}
     opJMP:begin
      Instruction:=Instruction^.Next;
      continue;
     end;
{$endif}
     opSPLIT,opSPLITMATCH:begin
      AddThread(ThreadList,Instruction^.Next);
      Instruction:=Instruction^.OtherNext;
      continue;
     end;
     opSAVE,opZEROWIDTH,opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE,opNOP:begin
      Instruction:=Instruction^.Next;
      continue;
     end;
     else begin
      ThreadList^.Threads[ThreadList^.Count].Instruction:=Instruction;
      inc(ThreadList^.Count);
      break;
     end;
    end;
   end;
  end;
 end;
 procedure CompilePrefixPattern;
 var CurrentPosition:TFLRESizeInt;
     CurrentChar:TFLRERawByteChar;
 begin
  if not assigned(PrefixPatternBitMasks) then begin
   GetMem(PrefixPatternBitMasks,SizeOf(TFLRECharPatternBitMasks));
  end;
  FillChar(PrefixPatternBitMasks^,SizeOf(TFLRECharPatternBitMasks),#$0);
  for CurrentPosition:=0 to CountPrefixCharClasses-1 do begin
   for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
    if CurrentChar in PrefixCharClasses[CurrentPosition] then begin
     PrefixPatternBitMasks^[CurrentChar]:=PrefixPatternBitMasks^[CurrentChar] or TFLREUInt32(TFLREUInt32(1) shl CurrentPosition);
    end;
   end;
  end;
 end;
var ThreadIndex,Count,TotalCount,Index:TFLREInt32;
    CurrentThreadList,NewThreadList,TemporaryThreadList:PThreadList;
    CurrentThread:PThread;
    Instruction:PFLREInstruction;
    CurrentChar,LowChar,HighChar:TFLRERawByteChar;
    ThreadLists:TThreadLists;
    HasCountPrefixCharClasses,OK:boolean;
begin

 Generation:=0;

 PrefixCharClasses:=nil;
 try

  InstructionGenerations:=nil;
  try

   SetLength(PrefixCharClasses,FLREMaxPrefixCharClasses);

   SetLength(InstructionGenerations,CountForwardInstructions+1);
   for Index:=0 to length(InstructionGenerations)-1 do begin
    InstructionGenerations[Index]:=-1;
   end;

   for CurrentPosition:=0 to FLREMaxPrefixCharClasses-1 do begin
    PrefixCharClasses[CurrentPosition]:=[];
   end;

   CountPrefixCharClasses:=0;
   HasCountPrefixCharClasses:=false;

   ThreadLists[0].Threads:=nil;
   ThreadLists[1].Threads:=nil;
   try
    SetLength(ThreadLists[0].Threads,(CountForwardInstructions+1)*4);
    SetLength(ThreadLists[1].Threads,(CountForwardInstructions+1)*4);

    CurrentThreadList:=@ThreadLists[0];
    NewThreadList:=@ThreadLists[1];

    CurrentThreadList^.Count:=0;
    NewThreadList^.Count:=0;

    Generation:=1;
//  CurrentPosition:=0;
    AddThread(CurrentThreadList,AnchoredStartInstruction);

    Count:=0;

    for CurrentPosition:=0 to FLREMaxPrefixCharClasses do begin
     if CurrentThreadList^.Count=0 then begin
      break;
     end;
     inc(Generation);
     inc(Count);
     for ThreadIndex:=0 to CurrentThreadList^.Count-1 do begin
      CurrentThread:=@CurrentThreadList^.Threads[ThreadIndex];
      Instruction:=CurrentThread^.Instruction;
      case Instruction^.IDandOpcode and $ff of
       opNONE:begin
        // Match against nothing
        HasCountPrefixCharClasses:=true;
       end;
       opSINGLECHAR:begin
        if CurrentPosition<FLREMaxPrefixCharClasses then begin
         PrefixCharClasses[CurrentPosition]:=PrefixCharClasses[CurrentPosition]+[TFLRERawByteChar(TFLREUInt8(Instruction^.Value))];
        end;
        AddThread(NewThreadList,Instruction^.Next);
       end;
       opCHAR:begin
        if CurrentPosition<FLREMaxPrefixCharClasses then begin
         PrefixCharClasses[CurrentPosition]:=PrefixCharClasses[CurrentPosition]+PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^;
        end;
        AddThread(NewThreadList,Instruction^.Next);
       end;
       opANY:begin
        if CurrentPosition<FLREMaxPrefixCharClasses then begin
         PrefixCharClasses[CurrentPosition]:=PrefixCharClasses[CurrentPosition]+AllCharClass;
        end;
        AddThread(NewThreadList,Instruction^.Next);
       end;
       opMATCH:begin
        if CountPrefixCharClasses=0 then begin
         CountPrefixCharClasses:=CurrentPosition;
         if CountPrefixCharClasses>0 then begin
          HasCountPrefixCharClasses:=true;
         end;
        end;
       end;
      end;
     end;
     TemporaryThreadList:=CurrentThreadList;
     CurrentThreadList:=NewThreadList;
     NewThreadList:=TemporaryThreadList;
     NewThreadList^.Count:=0;
    end;

    if not HasCountPrefixCharClasses then begin
     CountPrefixCharClasses:=Count;
     if CountPrefixCharClasses>FLREMaxPrefixCharClasses then begin
      CountPrefixCharClasses:=FLREMaxPrefixCharClasses;
     end;
    end;

    TotalCount:=0;
    for CurrentPosition:=0 to CountPrefixCharClasses-1 do begin
     Count:=0;
     for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
      if CurrentChar in PrefixCharClasses[CurrentPosition] then begin
       inc(Count);
      end;
     end;
     inc(TotalCount,Count);
    end;

    if CountPrefixCharClasses>0 then begin
     AveragePrefixCharClassesVariance:=(TotalCount+((CountPrefixCharClasses+1) div 2)) div CountPrefixCharClasses;
    end else begin
     AveragePrefixCharClassesVariance:=255;
    end;

    case CountPrefixCharClasses of
     0..2:begin
      // For so short prefixes it would be overkill in the most cases, and SBNDMQ2 do need a prefix pattern of length 3 at least
      Exclude(InternalFlags,fifDFAFastBeginningSearch);
     end;
     3..15:begin
      if AveragePrefixCharClassesVariance<(((CountPrefixCharClasses*128)+8) shr 4) then begin
       Include(InternalFlags,fifDFAFastBeginningSearch);
      end else begin
       Exclude(InternalFlags,fifDFAFastBeginningSearch);
      end;
     end;
     else begin
      if AveragePrefixCharClassesVariance<128 then begin
       Include(InternalFlags,fifDFAFastBeginningSearch);
      end else begin
       Exclude(InternalFlags,fifDFAFastBeginningSearch);
      end;
     end;
    end;

    CompilePrefixPattern;

    FirstPrefixCharClassRepeatedCount:=1;

    if TotalCount=2 then begin
     case CountPrefixCharClasses of
      2:begin
       if PrefixCharClasses[0]=PrefixCharClasses[1] then begin
        FirstPrefixCharClassRepeatedCount:=2;
        CountPrefixCharClasses:=1;
       end;
      end;
      3:begin
       if (PrefixCharClasses[0]=PrefixCharClasses[1]) and (PrefixCharClasses[0]=PrefixCharClasses[2]) then begin
        FirstPrefixCharClassRepeatedCount:=3;
        CountPrefixCharClasses:=1;
       end;
      end;
      4:begin
       if (PrefixCharClasses[0]=PrefixCharClasses[1]) and (PrefixCharClasses[0]=PrefixCharClasses[2]) and (PrefixCharClasses[0]=PrefixCharClasses[3]) then begin
        FirstPrefixCharClassRepeatedCount:=4;
        CountPrefixCharClasses:=1;
       end;
      end;
     end;
    end else begin
     case CountPrefixCharClasses of
      2:begin
       if PrefixCharClasses[0]=PrefixCharClasses[1] then begin
        FirstPrefixCharClassRepeatedCount:=2;
        CountPrefixCharClasses:=1;
       end;
      end;
     end;
    end;

    case CountPrefixCharClasses of
     1:begin
      FirstPrefixCharClassSize:=TotalCount;
      case FirstPrefixCharClassSize of
       1..8:begin
        SetLength(FirstPrefixCharClassChars,FirstPrefixCharClassSize);
        Count:=0;
        for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
         if CurrentChar in PrefixCharClasses[0] then begin
          FirstPrefixCharClassChars[Count]:=CurrentChar;
          inc(Count);
         end;
        end;
       end;
       else begin
        Count:=0;
        LowChar:=#$ff;
        HighChar:=#$00;
        for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
         if CurrentChar in PrefixCharClasses[0] then begin
          if LowChar<=HighChar then begin
           if (TFLREUInt8(TFLRERawByteChar(HighChar))+1)=TFLREUInt8(TFLRERawByteChar(CurrentChar)) then begin
            HighChar:=CurrentChar;
           end else begin
            inc(Count);
            LowChar:=CurrentChar;
            HighChar:=CurrentChar;
           end;
          end else begin
           LowChar:=CurrentChar;
           HighChar:=CurrentChar;
          end;
         end;
        end;
        if LowChar<=HighChar then begin
         inc(Count);
        end;
        case Count of
         1:begin
          CountFirstPrefixCharRanges:=1;
          SetLength(FirstPrefixCharRanges,1);
          Count:=0;
          LowChar:=#$ff;
          HighChar:=#$00;
          for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
           if CurrentChar in PrefixCharClasses[0] then begin
            if LowChar<=HighChar then begin
             if (TFLREUInt8(TFLRERawByteChar(HighChar))+1)=TFLREUInt8(TFLRERawByteChar(CurrentChar)) then begin
              HighChar:=CurrentChar;
             end else begin
              FirstPrefixCharRanges[Count].FromChar:=LowChar;
              FirstPrefixCharRanges[Count].ToChar:=HighChar;
              inc(Count);
              LowChar:=CurrentChar;
              HighChar:=CurrentChar;
             end;
            end else begin
             LowChar:=CurrentChar;
             HighChar:=CurrentChar;
            end;
           end;
          end;
          if LowChar<=HighChar then begin
           FirstPrefixCharRanges[Count].FromChar:=LowChar;
           FirstPrefixCharRanges[Count].ToChar:=HighChar;
          end;
         end;
         else begin
          CountFirstPrefixCharRanges:=0;
          if not assigned(FirstPrefixCharClass) then begin
           GetMem(FirstPrefixCharClass,SizeOf(TFLRECharClass));
          end;
          FirstPrefixCharClass^:=PrefixCharClasses[0];
         end;
        end;
       end;
      end;
     end;
     2:begin
      OK:=true;
      for CurrentPosition:=0 to CountPrefixCharClasses-1 do begin
       Count:=0;
       LowChar:=#$ff;
       HighChar:=#$00;
       for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
        if CurrentChar in PrefixCharClasses[CurrentPosition] then begin
         if LowChar<=HighChar then begin
          if (TFLREUInt8(TFLRERawByteChar(HighChar))+1)=TFLREUInt8(TFLRERawByteChar(CurrentChar)) then begin
           HighChar:=CurrentChar;
          end else begin
           inc(Count);
           LowChar:=CurrentChar;
           HighChar:=CurrentChar;
          end;
         end else begin
          LowChar:=CurrentChar;
          HighChar:=CurrentChar;
         end;
        end;
       end;
       if LowChar<=HighChar then begin
        inc(Count);
       end;
       if Count<>1 then begin
        OK:=false;
        break;
       end;
      end;
      if OK then begin
       CountFirstPrefixCharRanges:=2;
       SetLength(FirstPrefixCharRanges,2);
       for CurrentPosition:=0 to CountPrefixCharClasses-1 do begin
        LowChar:=#$ff;
        HighChar:=#$00;
        for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
         if CurrentChar in PrefixCharClasses[CurrentPosition] then begin
          if LowChar<=HighChar then begin
           if (TFLREUInt8(TFLRERawByteChar(HighChar))+1)=TFLREUInt8(TFLRERawByteChar(CurrentChar)) then begin
            HighChar:=CurrentChar;
           end else begin
            FirstPrefixCharRanges[CurrentPosition].FromChar:=LowChar;
            FirstPrefixCharRanges[CurrentPosition].ToChar:=HighChar;
            LowChar:=CurrentChar;
            HighChar:=CurrentChar;
           end;
          end else begin
           LowChar:=CurrentChar;
           HighChar:=CurrentChar;
          end;
         end;
        end;
        if LowChar<=HighChar then begin
         FirstPrefixCharRanges[CurrentPosition].FromChar:=LowChar;
         FirstPrefixCharRanges[CurrentPosition].ToChar:=HighChar;
        end;
       end;
      end;
     end;
    end;

   finally
    SetLength(ThreadLists[0].Threads,0);
    SetLength(ThreadLists[1].Threads,0);
   end;

  finally
   SetLength(InstructionGenerations,0);
  end;

 finally
  SetLength(PrefixCharClasses,0);
 end;

end;

procedure TFLRE.CompileByteMapForOnePassNFAAndDFA;
var Node:PFLRENode;
    Index,ByteCount:TFLRESizeInt;
    CurrentChar:TFLRERawByteChar;
    CharSetMap:TFLRECharClass;
    CharClass,NodeCharClass:TFLRECharClass;
    NewLines,Words:boolean;
begin
 NewLines:=false;
 Words:=false;
 FillChar(ByteMap,SizeOf(TFLREByteMap),#0);
 FillChar(UnByteMap,SizeOf(TFLREByteMap),#0);
 ByteCount:=0;
 CharSetMap:=[];
 CharClass:=[];
 for Index:=0 to Nodes.Count-1 do begin
  Node:=Nodes[Index];
  if assigned(Node) then begin
   case Node^.NodeType of
    ntZEROWIDTH:begin
     if (Node^.Value and (sfEmptyBeginLine or sfEmptyEndLine))<>0 then begin
      NewLines:=true;
     end;
     if (Node^.Value and (sfEmptyWordBoundary or sfEmptyNonWordBoundary))<>0 then begin
      Words:=true;
     end;
    end;
    ntCHAR:begin
     NodeCharClass:=GetCharClass(Node^.Value);
     if NodeCharClass<>AllCharClass then begin
      CharClass:=CharClass+NodeCharClass;
     end;
    end;
   end;
  end;
 end;
 if NewLines or Words then begin
  if NewLines then begin
   CharClass:=CharClass+[#$0a..#$0d];
   if rfUTF8 in Flags then begin
    CharClass:=CharClass+(([#$c2,#$85]{U+0085 NEXT LINE (NEL)})+
                          ([#$e2,#$80,#$a8]{U+2028 LINE SEPARATOR})+
                          ([#$e2,#$80,#$a9]{U+2029 PARAGRAPH SEPARATOR}));
   end else begin
    CharClass:=CharClass+[#$85];
   end;
  end;
  if Words then begin
   CharClass:=CharClass+['a'..'z','A'..'Z','0'..'9','_'];
   if rfUTF8 in Flags then begin
    CharClass:=CharClass+[#$80..#$ff];
   end;
  end;
 end;
 if CharClass<>[] then begin
  for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
   if (CurrentChar in CharClass) and not (CurrentChar in CharSetMap) then begin
    System.Include(CharSetMap,CurrentChar);
    ByteMap[TFLREUInt8(TFLRERawByteChar(CurrentChar))]:=ByteCount;
    UnByteMap[ByteCount]:=TFLREUInt8(TFLRERawByteChar(CurrentChar));
    inc(ByteCount);
   end;
  end;
 end;
 if ByteCount<256 then begin
  for CurrentChar:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
   if CurrentChar in CharSetMap then begin
    inc(ByteMap[TFLREUInt8(TFLRERawByteChar(CurrentChar))]);
   end;
  end;
  inc(ByteCount);
 end;
 ByteCharSetMap:=CharSetMap;
 ByteMapCount:=ByteCount;
end;

procedure TFLRE.CompileOnePassNFA;
type TStackItem=record
      Instruction:PFLREInstruction;
      Condition:TFLREUInt32;
     end;
     TStack=array of TStackItem;
var Instruction:PFLREInstruction;
    ToVisit,WorkQueue:TFLREPointerList;
    Stack:TStack;
    StackPointer,Len,MaxNodes,StateSize,Index,NextIndex,NodesCount,ByteValue,ToVisitIndex,IndexValue:TFLREInt32;
    Condition,Action,NewAction:TFLREUInt32;
    NodeByID:array of TFLREInt32;
    Nodes:PFLREOnePassNFAState;
    Node:PFLREOnePassNFAState;
    Matched,HasMatch:boolean;
    CharClass:TFLRECharClass;
    CharClassAction:PFLREOnePassNFAStateCharClassAction;
    DestCharClassAction:PFLREOnePassNFAStateCharClassAction;
begin
 Include(InternalFlags,fifOnePassNFAReady);
 Node:=nil;
 Instruction:=AnchoredStartInstruction;
 Len:=CountForwardInstructions;
 MaxNodes:=Len+2;
 StateSize:=SizeOf(TFLREOnePassNFAState)+((ByteMapCount+1)*SizeOf(TFLREUInt32));
 HasMatch:=false;
 Stack:=nil;
 try
  SetLength(Stack,Len*4);
  NodeByID:=nil;
  try
   SetLength(NodeByID,Len+2);
   FillChar(NodeByID[0],length(NodeByID)*SizeOf(TFLREInt32),#$ff);
   Nodes:=nil;
   try
    GetMem(Nodes,StateSize*MaxNodes);
    FillChar(Nodes^,StateSize*MaxNodes,#$00);
    NodeByID[AnchoredStartInstruction^.IDandOpcode shr 8]:=0;
    NodesCount:=1;
    Condition:=0;
    ToVisit:=TFLREPointerList.Create;
    try
     WorkQueue:=TFLREPointerList.Create;
     try
      ToVisit.Add(AnchoredStartInstruction);
      ToVisitIndex:=0;
      while (fifOnePassNFAReady in InternalFlags) and (ToVisitIndex<ToVisit.Count) do begin
       Instruction:=ToVisit[ToVisitIndex];
       inc(ToVisitIndex);
       if assigned(Instruction) then begin
        Node:=pointer(@PFLRERawByteChar(Nodes)[StateSize*TFLREInt32(NodeByID[Instruction^.IDandOpcode shr 8])]);
        for Index:=0 to ByteMapCount-1 do begin
         Node^.Action[Index]:=sfImpossible;
        end;
        Node^.MatchCondition:=sfImpossible;
        Node^.NoAction:=sfImpossible;
        Matched:=false;
        WorkQueue.Clear;
        Stack[0].Instruction:=Instruction;
        Stack[0].Condition:=0;
        StackPointer:=1;
        while (fifOnePassNFAReady in InternalFlags) and (StackPointer>0) do begin
         dec(StackPointer);
         Instruction:=Stack[StackPointer].Instruction;
         Condition:=Stack[StackPointer].Condition;
         case Instruction^.IDandOpcode and $ff of
{$ifdef UseOpcodeJMP}
          opJMP:begin
           if WorkQueue.IndexOf(Instruction^.Next)>=0 then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           WorkQueue.Add(Instruction^.Next);
           Stack[StackPointer].Instruction:=Instruction^.Next;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
          end;
{$endif}
          opNONE,opSINGLECHAR,opCHAR,opANY:begin
           NextIndex:=NodeByID[Instruction^.Next^.IDandOpcode shr 8];
           if NextIndex<0 then begin
            if NodesCount>=MaxNodes then begin
             Exclude(InternalFlags,fifOnePassNFAReady);
             break;
            end;
            NextIndex:=NodesCount;
            NodeByID[Instruction^.Next^.IDandOpcode shr 8]:=NextIndex;
            inc(NodesCount);
            ToVisit.Add(Instruction^.Next);
           end;
           if Matched then begin
            Condition:=Condition or sfMatchWins;
           end;
           NewAction:=TFLREUInt32(NextIndex shl sfIndexShift) or Condition;
           begin
            case Instruction^.IDandOpcode and $ff of
             opNONE:begin
              CharClass:=EmptyCharClass;
             end;
             opSINGLECHAR:begin
              CharClass:=[TFLRERawByteChar(TFLREUInt8(Instruction^.Value))];
             end;
             opCHAR:begin
              CharClass:=PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^;
             end;
             else {opANY:}begin
              CharClass:=AllCharClass;
             end;
            end;
            DestCharClassAction:=nil;
            CharClassAction:=Node^.CharClassAction;
            while assigned(CharClassAction) do begin
             if (CharClassAction.CharClass^*CharClass)<>[] then begin
              DestCharClassAction:=CharClassAction;
              break;
             end;
             CharClassAction:=CharClassAction^.Next;
            end;
            if assigned(DestCharClassAction) then begin
             if DestCharClassAction^.Condition<>NewAction then begin
              Exclude(InternalFlags,fifOnePassNFAReady);
              break;
             end;
            end else begin
             New(DestCharClassAction);
             FillChar(DestCharClassAction^,SizeOf(TFLREOnePassNFAStateCharClassAction),#0);
             DestCharClassAction^.AllNext:=OnePassNFACharClassActions;
             OnePassNFACharClassActions:=DestCharClassAction;
             DestCharClassAction^.Next:=Node^.CharClassAction;
             Node^.CharClassAction:=DestCharClassAction;
             DestCharClassAction^.CharClass:=CharClasses[NewCharClass(CharClass,false)];
             DestCharClassAction^.Condition:=NewAction;
            end;
           end;
           begin
            case Instruction^.IDandOpcode and $ff of
             opNONE:begin
              Exclude(InternalFlags,fifOnePassNFAReady);
              break;
             end;
             opSINGLECHAR:begin
              ByteValue:=ByteMap[Instruction^.Value and $ff];
              Action:=Node^.Action[ByteValue];
              if (Action and sfImpossible)=sfImpossible then begin
               Node^.Action[ByteValue]:=NewAction;
              end else if Action<>NewAction then begin
               Exclude(InternalFlags,fifOnePassNFAReady);
               break;
              end;
             end;
             opCHAR:begin
              if PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^=AllCharClass then begin
               for Index:=0 to ByteMapCount-1 do begin
                Action:=Node^.Action[Index];
                if (Action and sfImpossible)=sfImpossible then begin
                 Node^.Action[Index]:=NewAction;
                end else if Action<>NewAction then begin
                 Exclude(InternalFlags,fifOnePassNFAReady);
                 break;
                end;
               end;
              end else begin
               for Index:=0 to 255 do begin
                if TFLRERawByteChar(TFLREUInt8(Index)) in PFLRECharClass(pointer(TFLREPtrUInt(Instruction^.Value)))^ then begin
                 ByteValue:=ByteMap[Index];
                 Action:=Node^.Action[ByteValue];
                 if (Action and sfImpossible)=sfImpossible then begin
                  Node^.Action[ByteValue]:=NewAction;
                 end else if Action<>NewAction then begin
                  Exclude(InternalFlags,fifOnePassNFAReady);
                  break;
                 end;
                end;
               end;
              end;
              if not (fifOnePassNFAReady in InternalFlags) then begin
               break;
              end;
             end;
             else {opANY:}begin
              for Index:=0 to ByteMapCount-1 do begin
               Action:=Node^.Action[Index];
               if (Action and sfImpossible)=sfImpossible then begin
                Node^.Action[Index]:=NewAction;
               end else if Action<>NewAction then begin
                Exclude(InternalFlags,fifOnePassNFAReady);
                break;
               end;
              end;
              if not (fifOnePassNFAReady in InternalFlags) then begin
               break;
              end;
             end;
            end;
           end;
          end;
          opMATCH:begin
           if Matched or (Instruction^.Value>=0) then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           Matched:=true;
           HasMatch:=true;
           Node^.MatchCondition:=Condition;
           if NodesCount>=MaxNodes then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end else begin
            NextIndex:=0;
            NewAction:=TFLREUInt32(NextIndex shl sfIndexShift) or (Condition or sfMatchWins);
            if (Node^.NoAction shr sfIndexShift)=0 then begin
             if (Node^.NoAction and sfImpossible)=sfImpossible then begin
              Node^.NoAction:=NewAction;
             end else if Node^.NoAction<>NewAction then begin
              Exclude(InternalFlags,fifOnePassNFAReady);
              break;
             end;
            end;
            for Index:=0 to ByteMapCount-1 do begin
             Action:=Node^.Action[Index];
             if (Action shr sfIndexShift)=0 then begin
              if (Action and sfImpossible)=sfImpossible then begin
               Node^.Action[Index]:=NewAction;
              end else if Action<>NewAction then begin
               Exclude(InternalFlags,fifOnePassNFAReady);
               break;
              end;
             end;
            end;
           end;
          end;
          opSPLIT,opSPLITMATCH:begin
           if (WorkQueue.IndexOf(Instruction^.Next)>=0) or
              (WorkQueue.IndexOf(Instruction^.OtherNext)>=0) then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           WorkQueue.Add(Instruction^.Next);
           WorkQueue.Add(Instruction^.OtherNext);
           Stack[StackPointer].Instruction:=Instruction^.OtherNext;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
           Stack[StackPointer].Instruction:=Instruction^.Next;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
          end;
          opSAVE:begin
           IndexValue:=Instruction^.Value;
           if IndexValue>=sfMaxCap then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           Condition:=Condition or ((1 shl sfCapShift) shl IndexValue);
           if WorkQueue.IndexOf(Instruction^.Next)>=0 then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           WorkQueue.Add(Instruction^.Next);
           Stack[StackPointer].Instruction:=Instruction^.Next;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
          end;
          opZEROWIDTH:begin
           Condition:=Condition or TFLREUInt32(Instruction^.Value);
           if WorkQueue.IndexOf(Instruction^.Next)>=0 then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           WorkQueue.Add(Instruction^.Next);
           Stack[StackPointer].Instruction:=Instruction^.Next;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
          end;
          opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE:begin
           Exclude(InternalFlags,fifOnePassNFAReady);
           break;
          end;
          opNOP:begin
           if WorkQueue.IndexOf(Instruction^.Next)>=0 then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
           WorkQueue.Add(Instruction^.Next);
           Stack[StackPointer].Instruction:=Instruction^.Next;
           Stack[StackPointer].Condition:=Condition;
           inc(StackPointer);
          end;
          else begin
           Exclude(InternalFlags,fifOnePassNFAReady);
           break;
          end;
         end;
        end;
       end else begin
        break;
       end;
      end;
      if not HasMatch then begin
       Exclude(InternalFlags,fifOnePassNFAReady);
      end;
      if fifOnePassNFAReady in InternalFlags then begin
       if NodesCount>=MaxNodes then begin
        Exclude(InternalFlags,fifOnePassNFAReady);
       end else begin
        NextIndex:=0;
        NewAction:=TFLREUInt32(NextIndex shl sfIndexShift) or (Condition or sfMatchWins);
        if (Node^.NoAction shr sfIndexShift)=0 then begin
         if (Node^.NoAction and sfImpossible)=sfImpossible then begin
          Node^.NoAction:=NewAction;
         end else if Node^.NoAction<>NewAction then begin
          Exclude(InternalFlags,fifOnePassNFAReady);
         end;
        end;
        if fifOnePassNFAReady in InternalFlags then begin
         for Index:=0 to ByteMapCount-1 do begin
          Action:=Node^.Action[Index];
          if (Action shr sfIndexShift)=0 then begin
           if (Action and sfImpossible)=sfImpossible then begin
            Node^.Action[Index]:=NewAction;
           end else if Action<>NewAction then begin
            Exclude(InternalFlags,fifOnePassNFAReady);
            break;
           end;
          end;
         end;
        end;
       end;
      end;
      if fifOnePassNFAReady in InternalFlags then begin
       GetMem(OnePassNFANodes,NodesCount*StateSize);
       OnePassNFANodesCount:=NodesCount;
       Move(Nodes^,OnePassNFANodes^,NodesCount*StateSize);
       OnePassNFAStart:=pointer(@PFLRERawByteChar(OnePassNFANodes)[StateSize*TFLREInt32(NodeByID[AnchoredStartInstruction^.IDandOpcode shr 8])]);
       OnePassNFAStateSize:=StateSize;
      end;
     finally
      WorkQueue.Free;
     end;
    finally
     ToVisit.Free;
    end;
   finally
    if assigned(Nodes) then begin
     FreeMem(Nodes);
    end;
   end;
  finally
   SetLength(NodeByID,0);
  end;
 finally
  SetLength(Stack,0);
 end;
end;

procedure TFLRE.ScanProgram;
type PThread=^TThread;
     TThread=record
      Instruction:PFLREInstruction;
      PossibleBeginningSplit:boolean;
      PossibleBeginningAnchor:boolean;
      PossibleEndingSplit:boolean;
      PossibleEndingAnchor:boolean;
     end;
     TThreads=array of TThread;
     PThreadList=^TThreadList;
     TThreadList=record
      Threads:TThreads;
      Count:TFLREInt32;
     end;
     TThreadLists=array[0..1] of TThreadList;
var CurrentPosition:TFLRESizeInt;
    Generation:TFLREInt64;
    InstructionGenerations:TFLREInstructionGenerations;
    InstructionVisitedCounts:TFLREInstructionGenerations;
    BeginningJump,BeginningSplit,EndingSplit,BeginningWildCard,BeginningAnchor,EndingAnchor,
    HaveBeginningAnchorWithoutBeginningSplit,HaveBeginningAnchorWithBeginningSplit,HaveBeginningWithoutBeginningAnchor:boolean;
 procedure AddThread(const ThreadList:PThreadList;Instruction:PFLREInstruction;PossibleBeginningSplit,PossibleBeginningAnchor,PossibleEndingSplit,PossibleEndingAnchor:boolean);
 var Thread:PThread;
 begin
  while assigned(Instruction) do begin
   if (InstructionGenerations[Instruction^.IDandOpcode shr 8]=Generation) or
      (InstructionVisitedCounts[Instruction^.IDandOpcode shr 8]>0) then begin
    break;
   end else begin
    InstructionGenerations[Instruction^.IDandOpcode shr 8]:=Generation;
    inc(InstructionVisitedCounts[Instruction^.IDandOpcode shr 8]);
    case Instruction^.IDandOpcode and $ff of
{$ifdef UseOpcodeJMP}
     opJMP:begin
      if (CurrentPosition=0) and ((Instruction^.Next^.IDandOpcode shr 8)<=(Instruction^.IDandOpcode shr 8)) then begin
       BeginningJump:=true;
      end;
      Instruction:=Instruction^.Next;
      continue;
     end;
{$endif}
     opSPLIT,opSPLITMATCH:begin
      if CurrentPosition=0 then begin
       BeginningSplit:=true;
{$ifndef UseOpcodeJMP}
       if (CurrentPosition=0) and assigned(Instruction^.Next) and assigned(Instruction^.Next^.Next) and ((Instruction^.Next^.Next^.IDandOpcode shr 8)<=(Instruction^.Next^.IDandOpcode shr 8)) then begin
        BeginningJump:=true;
       end else if (CurrentPosition=0) and assigned(Instruction^.OtherNext) and assigned(Instruction^.Next^.Next) and ((Instruction^.OtherNext^.Next^.IDandOpcode shr 8)<=(Instruction^.Next^.IDandOpcode shr 8)) then begin
        BeginningJump:=true;
       end;
{$endif}
      end;
      PossibleBeginningSplit:=true;
      PossibleEndingSplit:=true;
      AddThread(ThreadList,Instruction^.Next,PossibleBeginningSplit,PossibleBeginningAnchor,PossibleEndingSplit,PossibleEndingAnchor);
      Instruction:=Instruction^.OtherNext;
      continue;
     end;
     opZEROWIDTH:begin
      if CurrentPosition=0 then begin
       if (Instruction^.Value and sfEmptyBeginText)<>0 then begin
        BeginningAnchor:=true;
        PossibleBeginningAnchor:=true;
        if PossibleBeginningSplit then begin
         HaveBeginningAnchorWithBeginningSplit:=true;
        end else begin
         HaveBeginningAnchorWithoutBeginningSplit:=true;
        end;
       end;
      end;
      if (Instruction^.Value and sfEmptyEndText)<>0 then begin
       PossibleEndingAnchor:=true;
      end;
      Instruction:=Instruction^.Next;
      continue;
     end;
     opSAVE,opLOOKBEHINDNEGATIVE,opLOOKBEHINDPOSITIVE,opLOOKAHEADNEGATIVE,opLOOKAHEADPOSITIVE,opBACKREFERENCE,opBACKREFERENCEIGNORECASE,opNOP:begin
      Instruction:=Instruction^.Next;
      continue;
     end;
     else begin
      Thread:=@ThreadList^.Threads[ThreadList^.Count];
      Thread^.Instruction:=Instruction;
      Thread^.PossibleBeginningSplit:=PossibleBeginningSplit;
      Thread^.PossibleBeginningAnchor:=PossibleBeginningAnchor;
      Thread^.PossibleEndingSplit:=PossibleEndingSplit;
      Thread^.PossibleEndingAnchor:=PossibleEndingAnchor;
      inc(ThreadList^.Count);
      break;
     end;
    end;
   end;
  end;
 end;
 procedure SearchForZeroWidthEmptyBeginningEndingTextInsideAlternative(Node:PFLRENode;Beginning:boolean);
  type PStackItem=^TStackItem;
       TStackItem=record
        Node:PFLRENode;
        Alternative:boolean;
       end;
       TStackItems=array of TStackItem;
  var Stack:TStackItems;
      StackItem:PStackItem;
      StackSize:TFLREInt32;
      Alternative:boolean;
 begin
  Stack:=nil;
  try
   SetLength(Stack,(Nodes.Count*2)+16);
   StackSize:=0;
   StackItem:=@Stack[StackSize];
   StackItem^.Node:=Node;
   StackItem^.Alternative:=false;
   inc(StackSize);
   while StackSize>0 do begin
    dec(StackSize);
    StackItem:=@Stack[StackSize];
    Node:=StackItem^.Node;
    Alternative:=StackItem^.Alternative;
    while assigned(Node) do begin
     case Node^.NodeType of
      ntALT:begin
       Alternative:=true;
       begin
        if (StackSize+1)>length(Stack) then begin
         SetLength(Stack,(StackSize+1)*2);
        end;
        StackItem:=@Stack[StackSize];
        inc(StackSize);
        StackItem^.Node:=Node^.Left;
        StackItem^.Alternative:=Alternative;
       end;
       Node:=Node^.Right;
       continue;
      end;
      ntCAT:begin
       begin
        if (StackSize+1)>length(Stack) then begin
         SetLength(Stack,(StackSize+1)*2);
        end;
        StackItem:=@Stack[StackSize];
        inc(StackSize);
        StackItem^.Node:=Node^.Right;
        StackItem^.Alternative:=Alternative;
       end;
       Node:=Node^.Left;
       continue;
      end;
      ntPAREN,ntMULTIMATCH:begin
       Node:=Node^.Left;
       continue;
      end;
      ntCHAR:begin
      end;
      ntQUEST,ntSTAR,ntPLUS:begin
       Node:=Node^.Left;
       continue;
      end;
      ntZEROWIDTH:begin
       if Beginning then begin
        if ((Node^.Value and sfEmptyBeginText)<>0) and Alternative then begin
         Exclude(InternalFlags,fifBeginTextAnchor);
         StackSize:=0;
        end;
       end else begin
        if ((Node^.Value and sfEmptyEndText)<>0) and Alternative then begin
         Exclude(InternalFlags,fifEndTextAnchor);
         StackSize:=0;
        end;
       end;
      end;
      ntLOOKBEHINDNEGATIVE,ntLOOKBEHINDPOSITIVE,ntLOOKAHEADNEGATIVE,ntLOOKAHEADPOSITIVE:begin
      end;
      ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
       if (Node^.Flags and 1)<>0 then begin
        Node:=Node^.Left;
        continue;
       end;
      end;
     end;
     break;
    end;
   end;
  finally
   SetLength(Stack,0);
  end;
 end;
var ThreadIndex{,Count,TotalCount},Index:TFLREInt32;
    CurrentThreadList,NewThreadList,TemporaryThreadList:PThreadList;
    CurrentThread:PThread;
    Instruction:PFLREInstruction;
//  CurrentChar:TFLRERawByteChar;
    ThreadLists:TThreadLists;
    PossibleBeginningSplit,PossibleBeginningAnchor,PossibleEndingSplit,PossibleEndingAnchor,
    HaveEndingAnchorWithoutEndingSplit,HaveEndingAnchorWithEndingSplit,HaveEndingWithoutEndingAnchor:boolean;
begin

 BeginningJump:=false;
 BeginningSplit:=false;
 EndingSplit:=false;
 BeginningWildCard:=false;
 BeginningAnchor:=false;
 EndingAnchor:=false;

 InternalFlags:=InternalFlags-[fifBeginTextAnchor,fifEndTextAnchor,fifCanMatchEmptyStrings];

 HaveBeginningAnchorWithoutBeginningSplit:=false;
 HaveBeginningAnchorWithBeginningSplit:=false;
 HaveBeginningWithoutBeginningAnchor:=false;

 HaveEndingAnchorWithoutEndingSplit:=false;
 HaveEndingAnchorWithEndingSplit:=false;
 HaveEndingWithoutEndingAnchor:=false;

 Generation:=0;

 InstructionVisitedCounts:=nil;
 try

  SetLength(InstructionVisitedCounts,CountForwardInstructions+1);
  for Index:=0 to length(InstructionVisitedCounts)-1 do begin
   InstructionVisitedCounts[Index]:=0;
  end;

  InstructionGenerations:=nil;
  try

   SetLength(InstructionGenerations,CountForwardInstructions+1);
   for Index:=0 to length(InstructionGenerations)-1 do begin
    InstructionGenerations[Index]:=-1;
   end;

   ThreadLists[0].Threads:=nil;
   ThreadLists[1].Threads:=nil;
   try
    SetLength(ThreadLists[0].Threads,(CountForwardInstructions+1)*4);
    SetLength(ThreadLists[1].Threads,(CountForwardInstructions+1)*4);

    CurrentThreadList:=@ThreadLists[0];
    NewThreadList:=@ThreadLists[1];

    CurrentThreadList^.Count:=0;
    NewThreadList^.Count:=0;

    Generation:=1;
    CurrentPosition:=0;
    AddThread(CurrentThreadList,AnchoredStartInstruction,false,false,false,false);

//  Count:=0;

    for CurrentPosition:=0 to $7fffffff do begin
     if CurrentThreadList^.Count=0 then begin
      break;
     end;
     inc(Generation);
//   inc(Count);
     for ThreadIndex:=0 to CurrentThreadList^.Count-1 do begin
      CurrentThread:=@CurrentThreadList^.Threads[ThreadIndex];
      Instruction:=CurrentThread^.Instruction;
      PossibleBeginningSplit:=CurrentThread^.PossibleBeginningSplit;
      PossibleBeginningAnchor:=CurrentThread^.PossibleBeginningAnchor;
      PossibleEndingSplit:=CurrentThread^.PossibleEndingSplit;
      PossibleEndingAnchor:=CurrentThread^.PossibleEndingAnchor;
      case Instruction^.IDandOpcode and $ff of
       opNONE:begin
        // Match against nothing
        if (CurrentPosition=0) and not PossibleBeginningAnchor then begin
         HaveBeginningWithoutBeginningAnchor:=true;
        end;
       end;
       opSINGLECHAR:begin
        if (CurrentPosition=0) and not PossibleBeginningAnchor then begin
         HaveBeginningWithoutBeginningAnchor:=true;
        end;
        AddThread(NewThreadList,Instruction^.Next,PossibleBeginningSplit,PossibleBeginningAnchor,false,false);
       end;
       opCHAR:begin
        if (CurrentPosition=0) and not PossibleBeginningAnchor then begin
         HaveBeginningWithoutBeginningAnchor:=true;
        end;
        AddThread(NewThreadList,Instruction^.Next,PossibleBeginningSplit,PossibleBeginningAnchor,false,false);
       end;
       opANY:begin
        if CurrentPosition=0 then begin
         if not PossibleBeginningAnchor then begin
          HaveBeginningWithoutBeginningAnchor:=true;
         end;
         BeginningWildCard:=true;
        end;
        AddThread(NewThreadList,Instruction^.Next,PossibleBeginningSplit,PossibleBeginningAnchor,false,false);
       end;
       opMATCH:begin
        if CurrentPosition=0 then begin
         Include(InternalFlags,fifCanMatchEmptyStrings);
        end;
        if PossibleEndingAnchor then begin
         if PossibleEndingSplit then begin
          HaveEndingAnchorWithEndingSplit:=true;
         end else begin
          HaveEndingAnchorWithoutEndingSplit:=true;
         end;
        end else begin
         HaveEndingWithoutEndingAnchor:=true;
        end;
        if PossibleEndingSplit then begin
         EndingSplit:=true;
        end;
        if PossibleEndingAnchor then begin
         EndingAnchor:=true;
        end;
       end;
      end;
     end;
     TemporaryThreadList:=CurrentThreadList;
     CurrentThreadList:=NewThreadList;
     NewThreadList:=TemporaryThreadList;
     NewThreadList^.Count:=0;
    end;

   finally
    SetLength(ThreadLists[0].Threads,0);
    SetLength(ThreadLists[1].Threads,0);
   end;

  finally
   SetLength(InstructionGenerations,0);
  end;

 finally
  SetLength(InstructionVisitedCounts,0);
 end;

 if HaveBeginningAnchorWithoutBeginningSplit and not (HaveBeginningWithoutBeginningAnchor or HaveBeginningAnchorWithBeginningSplit) then begin
  if BeginningAnchor and not BeginningSplit then begin
   Include(InternalFlags,fifBeginTextAnchor);
   SearchForZeroWidthEmptyBeginningEndingTextInsideAlternative(AnchoredRootNode,true);
  end else begin
   Exclude(InternalFlags,fifBeginTextAnchor);
  end;
 end;

 if HaveEndingAnchorWithoutEndingSplit and not (HaveEndingWithoutEndingAnchor or HaveEndingAnchorWithEndingSplit) then begin
  if EndingAnchor and not EndingSplit then begin
   Include(InternalFlags,fifEndTextAnchor);
   SearchForZeroWidthEmptyBeginningEndingTextInsideAlternative(AnchoredRootNode,false);
  end else begin
   Exclude(InternalFlags,fifEndTextAnchor);
  end;
 end;

 if BeginningJump and BeginningSplit and BeginningWildcard then begin
  Include(InternalFlags,fifBeginningWildcardLoop);
 end else begin
  Exclude(InternalFlags,fifBeginningWildcardLoop);
 end;

end;

function TFLRE.PrefilterOptimize(Node:TFLREPrefilterNode):TFLREPrefilterNode;
var OK:boolean;
    Counter:TFLREInt32;
    Temp:TFLREPrefilterNode;
begin
 result:=Node;
 while assigned(result) do begin
  for Counter:=0 to result.Subs.Count-1 do begin
   result.Subs[Counter]:=PrefilterOptimize(result.Subs[Counter]);
  end;
  case result.Operation of
   FLREpfnoAND,FLREpfnoOR:begin
    OK:=false;
    Counter:=0;
    while Counter<result.Subs.Count do begin
     Temp:=result.Subs[Counter];
     if not assigned(Temp) then begin
      result.Subs.Delete(Counter);
      OK:=true;
     end else if Temp.Operation=FLREpfnoANY then begin
      Temp.Free;
      result.Subs.Delete(Counter);
      result.Exact:=false;
      OK:=true;
     end else begin
      inc(Counter);
     end;
    end;
    case result.Subs.Count of
     0:begin
      FreeAndNil(result);
     end;
     1:begin
      Temp:=result.Subs[0];
      Temp.Exact:=Temp.Exact and result.Exact;
      result.Subs.Clear;
      result.Free;
      result:=Temp;
     end;
     else begin
      if OK then begin
       continue;
      end;
     end;
    end;
   end;
   else begin
   end;
  end;
  break;
 end;
end;

function TFLRE.CompilePrefilterTree(RootNode:PFLRENode):TFLREPrefilterNode;
 function Process(Node:PFLRENode):TFLREPrefilterNode;
 var Left,Right,Temp,OtherTemp:TFLREPrefilterNode;
     Counter,SubCounter,IndexCounter,Count:TFLREInt32;
     CharClass:TFLRECharClass;
     SingleChar,CurrentChar:TFLRERawByteChar;
     OK,ParentLoop:boolean;
 begin
  result:=nil;
  if assigned(Node) then begin

   // Convertion and generation pass ===============================================================================

   case Node^.NodeType of
    ntCAT:begin
     Left:=Process(Node^.Left);
     Right:=Process(Node^.Right);
     if assigned(Left) and assigned(Right) then begin
      if ((Left.Operation=FLREpfnoATOM) and (Right.Operation=FLREpfnoATOM)) and (Left.Exact and Right.Exact) then begin
       result:=Left;
       result.Atom:=result.Atom+Right.Atom;
       FreeAndNil(Right);
      end else if (Left.Operation=FLREpfnoAND) and (Right.Operation=FLREpfnoAND) then begin
       result:=Left;
       for Counter:=0 to Right.Subs.Count-1 do begin
        result.Subs.Add(Right.Subs[Counter]);
        result.Exact:=result.Exact and Right.Subs[Counter].Exact;
       end;
       Right.Subs.Clear;
       FreeAndNil(Right);
      end else if Left.Operation=FLREpfnoAND then begin
       result:=Left;
       result.Subs.Add(Right);
       result.Exact:=result.Exact and Right.Exact;
      end else if Right.Operation=FLREpfnoAND then begin
       result:=Right;
       result.Subs.Insert(0,Left);
       result.Exact:=result.Exact and Left.Exact;
      end else begin
       result:=TFLREPrefilterNode.Create;
       result.Operation:=FLREpfnoAND;
       result.Exact:=Left.Exact and Right.Exact;
       result.Subs.Add(Left);
       result.Subs.Add(Right);
      end;
     end else if assigned(Left) then begin
      result:=Left;
     end else if assigned(Right) then begin
      result:=Right;
     end;
    end;
    ntALT:begin
     Left:=Process(Node^.Left);
     Right:=Process(Node^.Right);
     if assigned(Left) and assigned(Right) then begin
      if (Left.Operation=FLREpfnoOR) and (Right.Operation=FLREpfnoOR) then begin
       result:=Left;
       for Counter:=0 to Right.Subs.Count-1 do begin
        result.Subs.Add(Right.Subs[Counter]);
        result.Exact:=result.Exact and Right.Subs[Counter].Exact;
       end;
       Right.Subs.Clear;
       FreeAndNil(Right);
      end else if Left.Operation=FLREpfnoOR then begin
       result:=Left;
       result.Subs.Add(Right);
       result.Exact:=result.Exact and Right.Exact;
      end else if Right.Operation=FLREpfnoOR then begin
       result:=Right;
       result.Subs.Insert(0,Left);
       result.Exact:=result.Exact and Left.Exact;
      end else begin
       result:=TFLREPrefilterNode.Create;
       result.Operation:=FLREpfnoOR;
       result.Exact:=Left.Exact and Right.Exact;
       result.Subs.Add(Left);
       result.Subs.Add(Right);
      end;
     end else if assigned(Left) then begin
      result:=Left;
     end else if assigned(Right) then begin
      result:=Right;
     end;
    end;
    ntPAREN,ntMULTIMATCH:begin
     result:=Process(Node^.Left);
    end;
    ntCHAR:begin
     CharClass:=GetCharClass(Node^.Value);
     SingleChar:=#0;
     Count:=0;
     for CurrentChar:=#0 to #255 do begin
      if CurrentChar in CharClass then begin
       if Count=0 then begin
        SingleChar:=CurrentChar;
        inc(Count);
       end else begin
        inc(Count);
       end;
      end;
     end;
     if Count=1 then begin
      result:=TFLREPrefilterNode.Create;
      result.Operation:=FLREpfnoATOM;
      result.Atom:=SingleChar;
      result.Exact:=true;
     end else begin
      if Count<=10 then begin
       result:=TFLREPrefilterNode.Create;
       result.Operation:=FLREpfnoOR;
       result.Exact:=true;
       for CurrentChar:=#0 to #255 do begin
        if CurrentChar in CharClass then begin
         Left:=TFLREPrefilterNode.Create;
         Left.Operation:=FLREpfnoATOM;
         Left.Atom:=CurrentChar;
         Left.Exact:=true;
         result.Subs.Add(Left);
        end;
       end;
      end else begin
       result:=TFLREPrefilterNode.Create;
       result.Operation:=FLREpfnoANY;
       result.Exact:=false;
      end;
     end;
    end;
    ntQUEST,ntSTAR,ntZEROWIDTH,ntLOOKBEHINDNEGATIVE,ntLOOKBEHINDPOSITIVE,ntLOOKAHEADNEGATIVE,ntLOOKAHEADPOSITIVE,ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
     result:=TFLREPrefilterNode.Create;
     result.Operation:=FLREpfnoANY;
     result.Exact:=false;
    end;
    ntPLUS:begin
     Left:=Process(Node^.Left);
     Right:=TFLREPrefilterNode.Create;
     Right.Operation:=FLREpfnoANY;
     Right.Exact:=false;
     result:=TFLREPrefilterNode.Create;
     result.Operation:=FLREpfnoAND;
     result.Subs.Add(Left);
     result.Subs.Add(Right);
     result.Exact:=false;
    end;
    else begin
     result:=nil;
    end;
   end;

   // Optimization pass ============================================================================================

   while assigned(result) do begin

    case result.Operation of

     FLREpfnoAND:begin

      for Counter:=0 to result.Subs.Count-1 do begin
       result.Exact:=result.Exact and result.Subs[Counter].Exact;
      end;

      OK:=false;
      Counter:=0;
      while Counter<result.Subs.Count do begin
       Left:=result.Subs[Counter];
       if not assigned(Left) then begin
        result.Subs.Delete(Counter);
        OK:=true;
       end else begin
        inc(Counter);
       end;
      end;
      if OK and (result.Subs.Count>1) then begin
       continue;
      end;

      case result.Subs.Count of
       0:begin
        FreeAndNil(result);
       end;
       1:begin
        Left:=result.Subs[0];
        Left.Exact:=Left.Exact and result.Exact;
        result.Subs.Clear;
        result.Free;
        result:=Left;
       end;
       else begin
        ParentLoop:=false;
        IndexCounter:=0;
        while IndexCounter<(result.Subs.Count-1) do begin
         Left:=result.Subs[IndexCounter];
         Right:=result.Subs[IndexCounter+1];
         if ((Left.Operation=FLREpfnoATOM) and (Right.Operation=FLREpfnoATOM)) and (Left.Exact and Right.Exact) then begin
          Left.Atom:=Left.Atom+Right.Atom;
          FreeAndNil(Right);
          result.Subs.Delete(IndexCounter+1);
          ParentLoop:=true;
          continue;
         end else if (Left.Operation=FLREpfnoANY) and (Right.Operation=FLREpfnoANY) then begin
          FreeAndNil(Right);
          result.Subs.Delete(IndexCounter+1);
          ParentLoop:=true;
          continue;
         end else if ((Left.Operation=FLREpfnoATOM) and (Right.Operation=FLREpfnoOR)) and (Left.Exact and Right.Exact) then begin
          OK:=true;
          for Counter:=0 to Right.Subs.Count-1 do begin
           if (Right.Subs[Counter].Operation<>FLREpfnoATOM) or not Right.Subs[Counter].Exact then begin
            OK:=false;
            break;
           end;
          end;
          if OK then begin
           for Counter:=0 to Right.Subs.Count-1 do begin
            Right.Subs[Counter].Atom:=Left.Atom+Right.Subs[Counter].Atom;
           end;
           FreeAndNil(Left);
           result.Subs.Delete(IndexCounter);
           ParentLoop:=false;
           continue;
          end;
         end else if ((Left.Operation=FLREpfnoOR) and (Right.Operation=FLREpfnoATOM)) and (Left.Exact and Right.Exact) then begin
          OK:=true;
          for Counter:=0 to Left.Subs.Count-1 do begin
           if (Left.Subs[Counter].Operation<>FLREpfnoATOM) or not Left.Subs[Counter].Exact then begin
            OK:=false;
            break;
           end;
          end;
          if OK then begin
           for Counter:=0 to Left.Subs.Count-1 do begin
            Left.Subs[Counter].Atom:=Left.Subs[Counter].Atom+Right.Atom;
           end;
           FreeAndNil(Right);
           result.Subs.Delete(IndexCounter+1);
           ParentLoop:=false;
           continue;
          end;
         end else if (Left.Operation=FLREpfnoOR) and (Right.Operation=FLREpfnoOR) and (Left.Exact and Right.Exact) then begin
          OK:=true;
          for Counter:=0 to Left.Subs.Count-1 do begin
           if (Left.Subs[Counter].Operation<>FLREpfnoATOM) or not Left.Subs[Counter].Exact then begin
            OK:=false;
            break;
           end;
          end;
          if OK then begin
           for Counter:=0 to Right.Subs.Count-1 do begin
            if (Right.Subs[Counter].Operation<>FLREpfnoATOM) or not Right.Subs[Counter].Exact then begin
             OK:=false;
             break;
            end;
           end;
           if OK then begin
            OtherTemp:=TFLREPrefilterNode.Create;
            OtherTemp.Operation:=FLREpfnoOR;
            OtherTemp.Exact:=true;
            for Counter:=0 to Left.Subs.Count-1 do begin
             for SubCounter:=0 to Right.Subs.Count-1 do begin
              Temp:=TFLREPrefilterNode.Create;
              Temp.Operation:=FLREpfnoATOM;
              Temp.Atom:=Left.Subs[Counter].Atom+Right.Subs[SubCounter].Atom;
              Temp.Exact:=true;
              OtherTemp.Subs.Add(Temp);
             end;
            end;
            FreeAndNil(Left);
            FreeAndNil(Right);
            result.Subs[IndexCounter]:=OtherTemp;
            result.Subs.Delete(IndexCounter+1);
            continue;
           end;
          end;
         end;
         inc(IndexCounter);
        end;
        if ParentLoop then begin
         continue;
        end;
       end;
      end;

     end;

     FLREpfnoOR:begin

      OK:=true;
      for Counter:=0 to result.Subs.Count-1 do begin
       Left:=result.Subs[Counter];
       if assigned(Left) and ((Left.Operation=FLREpfnoANY) or not Left.Exact) then begin
        OK:=false;
        break;
       end;
      end;
      if not OK then begin
       result.Free;
       result:=TFLREPrefilterNode.Create;
       result.Operation:=FLREpfnoANY;
       result.Exact:=false;
       continue;
      end;

      OK:=false;
      Counter:=0;
      while Counter<result.Subs.Count do begin
       Left:=result.Subs[Counter];
       if not assigned(Left) then begin
        result.Subs.Delete(Counter);
        OK:=true;
       end else begin
        inc(Counter);
       end;
      end;
      if OK and (result.Subs.Count>1) then begin
       continue;
      end;

      case result.Subs.Count of
       0:begin
        FreeAndNil(result);
       end;
       1:begin
        Left:=result.Subs[0];
        Left.Exact:=Left.Exact and result.Exact;
        result.Subs.Clear;
        result.Free;
        result:=Left;
       end;
      end;

     end;

     else begin
     end;

    end;

    break;
   end;

   // End ==========================================================================================================

  end;
 end;
begin
 result:=Process(RootNode);
end;

function TFLRE.IsWordChar(const CharValue:TFLREUInt32):boolean;
begin
 if CharValue=$ffffffff then begin
  result:=false;
 end else begin
  if rfUTF8 in Flags then begin
   result:=UnicodeIsWord(CharValue);
  end else begin
   case CharValue of
    ord('a')..ord('z'),ord('A')..ord('Z'),ord('0')..ord('9'),ord('_'):begin
     result:=true;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
 end;
end;

function TFLRE.AcquireThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 ParallelLockEnter(@ThreadLocalStorageInstanceManagerParallelLock);
 try
  result:=FreeThreadLocalStorageInstances;
  if assigned(result) then begin
   FreeThreadLocalStorageInstances:=result.FreeNext;
  end else begin
   result:=TFLREThreadLocalStorageInstance.Create(self);
   result.AllNext:=ThreadLocalStorageInstances;
   ThreadLocalStorageInstances:=result;
  end;
 finally
  ParallelLockLeave(@ThreadLocalStorageInstanceManagerParallelLock);
 end;
end;

procedure TFLRE.ReleaseThreadLocalStorageInstance(const ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance);
begin
 ParallelLockEnter(@ThreadLocalStorageInstanceManagerParallelLock);
 try
  ThreadLocalStorageInstance.FreeNext:=FreeThreadLocalStorageInstances;
  FreeThreadLocalStorageInstances:=ThreadLocalStorageInstance;
 finally
  ParallelLockLeave(@ThreadLocalStorageInstanceManagerParallelLock);
 end;
end;

function TFLRE.SearchNextPossibleStart(const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt):TFLRESizeInt; {$ifdef cpu386}register;{$endif}
begin
 if CountPrefixCharClasses>0 then begin
  if (CountPrefixCharClasses<=FixedStringLength) and not (rfIGNORECASE in Flags) then begin
   case FixedStringLength of
    0:begin
     result:=0;
    end;
    1:begin
     result:=PtrPosChar(FixedString[1],Input,InputLength,0);
    end;
    2:begin
{$ifdef cpux86_64}
     result:=PtrPosCharPair(FixedString[1],FixedString[2],Input,InputLength,0);
{$else}
     result:=PtrPosPatternSBNDMQ1(FixedStringLength,Input,InputLength,FixedStringPatternBitMasks^,0);
{$endif}
    end;
    3..31:begin
     result:=PtrPosPatternSBNDMQ2(FixedStringLength,Input,InputLength,FixedStringPatternBitMasks^,0);
    end;
    else begin
     result:=PtrPosBoyerMoore(FixedString,Input,InputLength,FixedStringBoyerMooreSkip^,FixedStringBoyerMooreNext,0);
    end;
   end;
  end else begin
   case CountPrefixCharClasses of
    0:begin
     result:=0;
    end;
    1:begin
     case FirstPrefixCharClassSize of
      1:begin
       result:=PtrPosChar(FirstPrefixCharClassChars[0],Input,InputLength,0);
      end;
      2:begin
       case FirstPrefixCharClassRepeatedCount of
        1:begin
         result:=PtrPosCharSetOf2(FirstPrefixCharClassChars[0],
                                  FirstPrefixCharClassChars[1],
                                  Input,
                                  InputLength,
                                  0);
        end;
        2:begin
         result:=PtrPosCharSetOf2Of2(FirstPrefixCharClassChars[0],
                                     FirstPrefixCharClassChars[1],
                                     Input,
                                     InputLength,
                                     0);
        end;
        3:begin
         result:=PtrPosCharSetOf2Of3(FirstPrefixCharClassChars[0],
                                     FirstPrefixCharClassChars[1],
                                     Input,
                                     InputLength,
                                     0);
        end;
        4:begin
         result:=PtrPosCharSetOf2Of4(FirstPrefixCharClassChars[0],
                                     FirstPrefixCharClassChars[1],
                                     Input,
                                     InputLength,
                                     0);
        end;
        else begin
         result:=0;
        end;
       end;
      end;
      3:begin
       result:=PtrPosCharSetOf3(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                Input,
                                InputLength,
                                0);
      end;
      4:begin
       result:=PtrPosCharSetOf4(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                FirstPrefixCharClassChars[3],
                                Input,
                                InputLength,
                                0);
      end;
      5:begin
       result:=PtrPosCharSetOf5(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                FirstPrefixCharClassChars[3],
                                FirstPrefixCharClassChars[4],
                                Input,
                                InputLength,
                                0);
      end;
      6:begin
       result:=PtrPosCharSetOf6(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                FirstPrefixCharClassChars[3],
                                FirstPrefixCharClassChars[4],
                                FirstPrefixCharClassChars[5],
                                Input,
                                InputLength,
                                0);
      end;
      7:begin
       result:=PtrPosCharSetOf7(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                FirstPrefixCharClassChars[3],
                                FirstPrefixCharClassChars[4],
                                FirstPrefixCharClassChars[5],
                                FirstPrefixCharClassChars[6],
                                Input,
                                InputLength,
                                0);
      end;
      8:begin
       result:=PtrPosCharSetOf8(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                FirstPrefixCharClassChars[2],
                                FirstPrefixCharClassChars[3],
                                FirstPrefixCharClassChars[4],
                                FirstPrefixCharClassChars[5],
                                FirstPrefixCharClassChars[6],
                                FirstPrefixCharClassChars[7],
                                Input,
                                InputLength,
                                0);
      end;
      else begin
       case CountFirstPrefixCharRanges of
        1:begin
         result:=PtrPosCharRange(FirstPrefixCharRanges[0].FromChar,
                                 FirstPrefixCharRanges[0].ToChar,
                                 Input,
                                 InputLength,
                                 0);
        end;
        2:begin
         result:=PtrPosCharRangeOf2(FirstPrefixCharRanges[0].FromChar,
                                    FirstPrefixCharRanges[0].ToChar,
                                    FirstPrefixCharRanges[1].FromChar,
                                    FirstPrefixCharRanges[1].ToChar,
                                    Input,
                                    InputLength,
                                    0);
        end;
        else begin
         result:=PtrPosPatternCharClass(Input,InputLength,FirstPrefixCharClass^,0);
        end;
       end;
      end;
     end;
    end;
    2:begin
     result:=PtrPosPatternSBNDMQ1(CountPrefixCharClasses,Input,InputLength,PrefixPatternBitMasks^,0);
    end;
    else begin
     result:=PtrPosPatternSBNDMQ2(CountPrefixCharClasses,Input,InputLength,PrefixPatternBitMasks^,0);
    end;
   end;
  end;
 end else begin
  result:=0;
 end;
end;

function TFLRE.SearchNextPossibleStartForDFA(const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt):TFLRESizeInt; {$ifdef cpu386}register;{$endif}
begin
 case CountPrefixCharClasses of
  0:begin
   result:=0;
  end;
  1:begin
   case FirstPrefixCharClassSize of
    1:begin
     result:=PtrPosChar(FirstPrefixCharClassChars[0],Input,InputLength,0);
    end;
    2:begin
     case FirstPrefixCharClassRepeatedCount of
      1:begin
       result:=PtrPosCharSetOf2(FirstPrefixCharClassChars[0],
                                FirstPrefixCharClassChars[1],
                                Input,
                                InputLength,
                                0);
      end;
      2:begin
       result:=PtrPosCharSetOf2Of2(FirstPrefixCharClassChars[0],
                                   FirstPrefixCharClassChars[1],
                                   Input,
                                   InputLength,
                                   0);
      end;
      3:begin
       result:=PtrPosCharSetOf2Of3(FirstPrefixCharClassChars[0],
                                   FirstPrefixCharClassChars[1],
                                   Input,
                                   InputLength,
                                   0);
      end;
      4:begin
       result:=PtrPosCharSetOf2Of4(FirstPrefixCharClassChars[0],
                                   FirstPrefixCharClassChars[1],
                                   Input,
                                   InputLength,
                                   0);
      end;
      else begin
       result:=0;
      end;
     end;
    end;
    3:begin
     result:=PtrPosCharSetOf3(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              Input,
                              InputLength,
                              0);
    end;
    4:begin
     result:=PtrPosCharSetOf4(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              FirstPrefixCharClassChars[3],
                              Input,
                              InputLength,
                              0);
    end;
    5:begin
     result:=PtrPosCharSetOf5(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              FirstPrefixCharClassChars[3],
                              FirstPrefixCharClassChars[4],
                              Input,
                              InputLength,
                              0);
    end;
    6:begin
     result:=PtrPosCharSetOf6(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              FirstPrefixCharClassChars[3],
                              FirstPrefixCharClassChars[4],
                              FirstPrefixCharClassChars[5],
                              Input,
                              InputLength,
                              0);
    end;
    7:begin
     result:=PtrPosCharSetOf7(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              FirstPrefixCharClassChars[3],
                              FirstPrefixCharClassChars[4],
                              FirstPrefixCharClassChars[5],
                              FirstPrefixCharClassChars[6],
                              Input,
                              InputLength,
                              0);
    end;
    8:begin
     result:=PtrPosCharSetOf8(FirstPrefixCharClassChars[0],
                              FirstPrefixCharClassChars[1],
                              FirstPrefixCharClassChars[2],
                              FirstPrefixCharClassChars[3],
                              FirstPrefixCharClassChars[4],
                              FirstPrefixCharClassChars[5],
                              FirstPrefixCharClassChars[6],
                              FirstPrefixCharClassChars[7],
                              Input,
                              InputLength,
                              0);
    end;
    else begin
     case CountFirstPrefixCharRanges of
      1:begin
       result:=PtrPosCharRange(FirstPrefixCharRanges[0].FromChar,
                               FirstPrefixCharRanges[0].ToChar,
                               Input,
                               InputLength,
                               0);
      end;
      2:begin
       result:=PtrPosCharRangeOf2(FirstPrefixCharRanges[0].FromChar,
                                  FirstPrefixCharRanges[0].ToChar,
                                  FirstPrefixCharRanges[1].FromChar,
                                  FirstPrefixCharRanges[1].ToChar,
                                  Input,
                                  InputLength,
                                  0);
      end;
      else begin
       result:=PtrPosPatternCharClass(Input,InputLength,FirstPrefixCharClass^,0);
      end;
     end;
    end;
   end;
  end;
  2:begin
   result:=PtrPosPatternSBNDMQ1(CountPrefixCharClasses,Input,InputLength,PrefixPatternBitMasks^,0);
  end;
  else begin
   result:=PtrPosPatternSBNDMQ2(CountPrefixCharClasses,Input,InputLength,PrefixPatternBitMasks^,0);
  end;
 end;
end;

function TFLRE.SearchMatch(ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;var Captures:TFLRECaptures;StartPosition,UntilExcludingPosition:TFLRESizeInt;UnanchoredStart:boolean):boolean;
var MatchBegin,MatchEnd,Offset,Len:TFLRESizeInt;
begin

 // Check the start position
 if (StartPosition<0) and (StartPosition>=UntilExcludingPosition) then begin
  result:=false;
  exit;
 end;

 // First try to find the next possible match start with heuristic magic and so on (but only at regular expressions, which can't match also
 // empty strings)
 if (CountPrefixCharClasses>0) and not (fifCanMatchEmptyStrings in InternalFlags) then begin
  Len:=UntilExcludingPosition-StartPosition;
  if FixedStringIsWholeRegExp and not UnanchoredStart then begin
   if Len>=FixedStringLength then begin
    Len:=FixedStringLength;
   end else begin
    result:=false;
    exit;
   end;
  end;
  Offset:=SearchNextPossibleStart(@PFLRERawByteChar(ThreadLocalStorageInstance.Input)[StartPosition],Len);
  if Offset<0 then begin
   result:=false;
   exit;
  end else begin
   inc(StartPosition,Offset);
   if (StartPosition<>0) and not UnanchoredStart then begin
    result:=false;
    exit;
   end else if FixedStringIsWholeRegExp and (CountCaptures<2) and (CountPrefixCharClasses<=FixedStringLength) and not (rfIGNORECASE in Flags) then begin
    Captures[0].Start:=StartPosition;
    Captures[0].Length:=FixedStringLength;
    result:=true;
    exit;
   end;
  end;
 end;

 // Then try DFA
 if (fifDFAReady in InternalFlags) and
 
    // If we have only a small amount of text and we need submatch information anyway and we 
    // use OnePass or BitState to do it, we can save the trouble with DFA. OnePass or BitState 
    // perform fast enough for that. For very small texts, OnePass will actually beat DFA and 
    // doesn't have the shared state and occasional overhead that DFA has.     
    (not 
     ((((fifOnePassNFAReady in InternalFlags) and not UnanchoredStart) and 
       ((UntilExcludingPosition-StartPosition)<=4096) and
       ((CountCaptures>=2) or ((UntilExcludingPosition-StartPosition)<=16))) or
      ((fifBitStateNFAReady in InternalFlags) and (CountCaptures>=2) and ((UntilExcludingPosition-StartPosition)<=MaxBitStateNFATextSize)))) 
     then begin
  ThreadLocalStorageInstance.DFA.IsUnanchored:=UnanchoredStart;
  case ThreadLocalStorageInstance.DFA.SearchMatch(StartPosition,UntilExcludingPosition,MatchEnd,UnanchoredStart) of
   DFAMatch:begin
    if UnanchoredStart then begin
     // For unanchored searchs, we must do also a "backward" DFA search
     case ThreadLocalStorageInstance.ReversedDFA.SearchMatch(MatchEnd,StartPosition,MatchBegin,false) of
      DFAMatch:begin
       if MatchBegin<StartPosition then begin
        MatchBegin:=StartPosition;
       end;
       if (CountCaptures=1) and not (fifDFANeedVerification in InternalFlags) then begin
        // If we have only the root group capture without the need for the verification of the found, then don't execute the slower *NFA algorithms
        Captures[0].Start:=MatchBegin;
        Captures[0].Length:=(MatchEnd-MatchBegin)+1;
        result:=true;
        exit;
       end else begin
        // Otherwise if we have group captures or if we do need verify the found, set the new start position for the *NFA algorithms
        StartPosition:=MatchBegin;
        UnanchoredStart:=false;
       end;
      end;
     end;
    end;
    if (CountCaptures=1) and not ((fifDFANeedVerification in InternalFlags) or UnanchoredStart) then begin
     // If we have only the root group capture without the need for the verification of the found, then don't execute the slower *NFA algorithms
     Captures[0].Start:=StartPosition;
     Captures[0].Length:=(MatchEnd-StartPosition)+1;
     result:=true;
     exit;
    end else begin
     // Otherwise if we have group captures or if we do need verify the found, limit search length for the slower *NFA algorithms
     if UntilExcludingPosition>(MatchEnd+1) then begin
      UntilExcludingPosition:=MatchEnd+1;
     end;
    end;
   end;
   DFAFail:begin
    if not (fifCanMatchEmptyStrings in InternalFlags) then begin
     // No DFA match => stop
     result:=false;
     exit;
    end;
   end;
   else {DFAError:}begin
    // Argh, a DFA internal error is happen => fallback to NFA
   end;
  end;
 end;

 // Then the NFA stuff
 if (fifOnePassNFAReady in InternalFlags) and not UnanchoredStart then begin
  if ThreadLocalStorageInstance.OnePassNFA.SearchMatch(Captures,StartPosition,UntilExcludingPosition) then begin
   result:=true;
   exit;
  end;
 end else begin
  if (fifBitStateNFAReady in InternalFlags) and ((UntilExcludingPosition-StartPosition)<=MaxBitStateNFATextSize) then begin
   case ThreadLocalStorageInstance.BitStateNFA.SearchMatch(Captures,StartPosition,UntilExcludingPosition,UnanchoredStart) of
    BitStateNFAFail:begin
     result:=false;
     exit;
    end;
    BitStateNFAMatch:begin
     result:=true;
     exit;
    end;
(*  else{BitStateNFAError:}begin
    end;*)
   end;
  end;
  if ThreadLocalStorageInstance.ParallelNFA.SearchMatch(Captures,StartPosition,UntilExcludingPosition,UnanchoredStart) then begin
   result:=true;
   exit;
  end;
 end;

 result:=false;

end;

function TFLRE.PtrMatch(const Input:pointer;const InputLength:TFLRESizeInt;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=0):boolean;
var ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Index,Count:TFLRESizeInt;
begin
 ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
 try
  ThreadLocalStorageInstance.Input:=Input;
  ThreadLocalStorageInstance.InputLength:=InputLength;
  if rfMULTIMATCH in Flags then begin
   for Index:=0 to CountMultiSubMatches-1 do begin
    ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
   end;
   Count:=CountMultiSubMatches+1;
  end else begin
   Count:=CountCaptures;
  end;
  SetLength(Captures,Count);
  result:=SearchMatch(ThreadLocalStorageInstance,Captures,StartPosition,InputLength,false);
  if result and (rfMULTIMATCH in Flags) then begin
   for Index:=0 to CountMultiSubMatches-1 do begin
    Captures[Index+1].Start:=Index;
    if ThreadLocalStorageInstance.MultiSubMatches[Index]>=0 then begin
     Captures[Index+1].Length:=1;
    end else begin
     Captures[Index+1].Length:=0;
    end;
   end;
  end;
 finally
  ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
 end;
end;

function TFLRE.PtrMatchNext(const Input:pointer;const InputLength:TFLRESizeInt;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=0):boolean;
var ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Index,Count:TFLRESizeInt;
begin
 if (StartPosition>=0) and (StartPosition<InputLength) then begin
  ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
  try
   ThreadLocalStorageInstance.Input:=Input;
   ThreadLocalStorageInstance.InputLength:=InputLength;
   if rfMULTIMATCH in Flags then begin
    for Index:=0 to CountMultiSubMatches-1 do begin
     ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
    end;
    Count:=CountMultiSubMatches+1;
   end else begin
    Count:=CountCaptures;
   end;
   SetLength(Captures,Count);
   result:=SearchMatch(ThreadLocalStorageInstance,Captures,StartPosition,InputLength,fifHaveUnanchoredStart in InternalFlags);
   if result and (rfMULTIMATCH in Flags) then begin
    for Index:=0 to CountMultiSubMatches-1 do begin
     Captures[Index+1].Start:=Index;
     if ThreadLocalStorageInstance.MultiSubMatches[Index]>=0 then begin
      Captures[Index+1].Length:=1;
     end else begin
      Captures[Index+1].Length:=0;
     end;
    end;
   end;
  finally
   ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
  end;
 end else begin
  result:=false;
 end;
end;

function TFLRE.PtrMatchAll(const Input:pointer;const InputLength:TFLRESizeInt;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):boolean;
var CurrentPosition,CountMultiCaptures,Next,Index,Count:TFLRESizeInt;
    MatchResult:TFLRECaptures;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:=false;
 MatchResult:=nil;
 CountMultiCaptures:=0;
 //SetLength(MultiCaptures,0);
 CurrentPosition:=StartPosition;
 if CurrentPosition>=0 then begin
  try
   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
   try
    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;
    if rfMULTIMATCH in Flags then begin
     for Index:=0 to CountMultiSubMatches-1 do begin
      ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
     end;
     Count:=CountMultiSubMatches+1;
    end else begin
     Count:=CountCaptures;
    end;
    //SetLength(MultiCaptures,0,Count);
    SetLength(MatchResult,Count);
    while (CurrentPosition<InputLength) and (Limit<>0) and SearchMatch(ThreadLocalStorageInstance,MatchResult,CurrentPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) do begin
     Next:=CurrentPosition+1;
     CurrentPosition:=MatchResult[0].Start+MatchResult[0].Length;
     if CurrentPosition<Next then begin
      CurrentPosition:=Next;
     end;
     if CountMultiCaptures>=length(MultiCaptures) then begin
      SetLength(MultiCaptures,(CountMultiCaptures+1)*2);
      for Index:=CountMultiCaptures to length(MultiCaptures)-1 do begin
       SetLength(MultiCaptures[Index],Count);
      end;
     end;
     if rfMULTIMATCH in Flags then begin
      for Index:=0 to CountMultiSubMatches-1 do begin
       MatchResult[Index+1].Start:=Index;
       if ThreadLocalStorageInstance.MultiSubMatches[Index]>=0 then begin
        MatchResult[Index+1].Length:=1;
       end else begin
        MatchResult[Index+1].Length:=0;
       end;
      end;
      for Index:=0 to CountMultiSubMatches-1 do begin
       ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
      end;
     end;
     Move(MatchResult[0],MultiCaptures[CountMultiCaptures,0],Count*SizeOf(TFLRECapture));
     inc(CountMultiCaptures);
     if Limit>0 then begin
      dec(Limit);
     end;
    end;
    result:=CountMultiCaptures>0;
   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;
  finally
   SetLength(MatchResult,0);
   SetLength(MultiCaptures,CountMultiCaptures);
  end;
 end;
end;

function TFLRE.PtrExtractAll(const Input:pointer;const InputLength:TFLRESizeInt;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):boolean;
var CurrentPosition,CountMultiExtractions,Next,Index,Count:TFLRESizeInt;
    MatchResult:TFLRECaptures;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:=false;
 if rfMULTIMATCH in Flags then begin
  raise EFLRE.Create('ExtractAll unsupported in multi match mode');
 end;
 MatchResult:=nil;
 CountMultiExtractions:=0;
 //SetLength(MultiExtractions,0);
 CurrentPosition:=StartPosition;
 if CurrentPosition>=0 then begin
  try
   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
   try
    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;
    Count:=CountCaptures;
    //SetLength(MultiExtractions,0,Count);
    SetLength(MatchResult,Count);
    while (CurrentPosition<InputLength) and (Limit<>0) and SearchMatch(ThreadLocalStorageInstance,MatchResult,CurrentPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) do begin
     Next:=CurrentPosition+1;
     CurrentPosition:=MatchResult[0].Start+MatchResult[0].Length;
     if CurrentPosition<Next then begin
      CurrentPosition:=Next;
     end;
     if CountMultiExtractions>=length(MultiExtractions) then begin
      SetLength(MultiExtractions,(CountMultiExtractions+1)*2);
      for Index:=CountMultiExtractions to length(MultiExtractions)-1 do begin
       SetLength(MultiExtractions[Index],Count);
      end;
     end;
     for Index:=0 to CountCaptures-1 do begin
      MultiExtractions[CountMultiExtractions,Index]:=FLREPtrCopy(Input,MatchResult[Index].Start,MatchResult[Index].Length);
     end;
     inc(CountMultiExtractions);
     if Limit>0 then begin
      dec(Limit);
     end;
    end;
    result:=CountMultiExtractions>0;
   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;
  finally
   SetLength(MatchResult,0);
   SetLength(MultiExtractions,CountMultiExtractions);
  end;
 end;
end;

function TFLRE.PtrReplace(const Input:pointer;const InputLength:TFLRESizeInt;const Replacement:pointer;const ReplacementLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString;
var CurrentPosition,LastEnd,i,j,e:TFLRESizeInt;
    Captures:TFLRECaptures;
    SimpleReplacement:boolean;
    c,cc:TFLRERawByteChar;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:='';
 if rfMULTIMATCH in Flags then begin
  raise EFLRE.Create('Replace unsupported in multi match mode');
 end;
 Captures:=nil;
 try
  SimpleReplacement:=(PtrPosChar('$',Replacement,ReplacementLength)<0) and (PtrPosChar('\',Replacement,ReplacementLength)<0);
  CurrentPosition:=StartPosition;
  if CurrentPosition>=0 then begin
   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
   try
    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;
    LastEnd:=-1;
    SetLength(Captures,CountCaptures);
    while (CurrentPosition<=InputLength) and (Limit<>0) and SearchMatch(ThreadLocalStorageInstance,Captures,CurrentPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) do begin
     if CurrentPosition<Captures[0].Start then begin
      result:=result+FLREPtrCopy(PFLRERawByteChar(Input),CurrentPosition,Captures[0].Start-CurrentPosition);
     end;
     if (Captures[0].Start=LastEnd) and (Captures[0].Length=0) then begin
      if CurrentPosition<InputLength then begin
       result:=result+FLREPtrCopy(PFLRERawByteChar(Input),CurrentPosition,1);
      end;
      inc(CurrentPosition);
      continue;
     end;
     if SimpleReplacement then begin
      result:=result+FLREPtrCopy(PFLRERawByteChar(Replacement),0,ReplacementLength);
     end else begin
      i:=0;
      while i<ReplacementLength do begin
       c:=PFLRERawByteChar(Replacement)[i];
       case c of
        '$','\':begin
         cc:=c;
         inc(i);
         if i<ReplacementLength then begin
          c:=PFLRERawByteChar(Replacement)[i];
          case c of
           '$':begin
            if cc='$' then begin
             result:=result+c;
             inc(i);
            end else begin
             result:=result+'\$';
             inc(i);
            end;
           end;
           '\':begin
            if cc='\' then begin
             result:=result+c;
             inc(i);
            end else begin
             result:=result+'$\';
             inc(i);
            end;
           end;
           '&':begin
            result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[0].Start,Captures[0].Length);
            inc(i);
           end;
           '`':begin
            result:=result+FLREPtrCopy(PFLRERawByteChar(Input),0,Captures[0].Start-1);
            inc(i);
           end;
           '''':begin
            result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[0].Start+Captures[0].Length,(InputLength-(Captures[0].Start+Captures[0].Length))+1);
            inc(i);
           end;
           '_':begin
            result:=result+TFLRERawByteString(PFLRERawByteChar(Input));
            inc(i);
           end;
           '-':begin
            if length(Captures)>1 then begin
             result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[1].Start,Captures[1].Length);
            end;
            inc(i);
           end;
           '+':begin
            if length(Captures)>1 then begin
             e:=length(Captures)-1;
             result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[e].Start,Captures[e].Length);
            end;
            inc(i);
           end;
           'g':begin
            if cc='\' then begin
             e:=-1;
             inc(i);
             j:=i;
             while i<ReplacementLength do begin
              if PFLRERawByteChar(Replacement)[i] in ['a'..'z','A'..'Z','_','0'..'9'] then begin
               inc(i);
              end else begin
               break;
              end;
             end;
             if j<i then begin
              e:=NamedGroupStringIntegerPairHashMap.GetValue(FLREPtrCopy(PFLRERawByteChar(Replacement),j,i-j));
             end;
             if e<0 then begin
              result:=result+cc+'g';
              i:=j;
             end else begin
              if (e>=0) and (e<length(Captures)) then begin
               result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[e].Start,Captures[e].Length);
              end;
             end;
            end else begin
             result:=result+cc+'g';
             inc(i);
            end;
           end;
           '{':begin
            e:=-1;
            inc(i);
            j:=i;
            if i<ReplacementLength then begin
             case PFLRERawByteChar(Replacement)[i] of
              '0'..'9':begin
               e:=0;
               while i<ReplacementLength do begin
                c:=PFLRERawByteChar(Replacement)[i];
                case c of
                 '0'..'9':begin
                  e:=(e*10)+(ord(c)-ord('0'));
                  inc(i);
                 end;
                 else begin
                  break;
                 end;
                end;
               end;
               if (i<ReplacementLength) and (PFLRERawByteChar(Replacement)[i]='}') then begin
                inc(i);
               end else begin
                e:=-1;
               end;
              end;
              else begin
               while i<ReplacementLength do begin
                if PFLRERawByteChar(Replacement)[i] in ['a'..'z','A'..'Z','_','0'..'9'] then begin
                 inc(i);
                end else begin
                 break;
                end;
               end;
               if (j<i) and (PFLRERawByteChar(Replacement)[i]='}') then begin
                e:=NamedGroupStringIntegerPairHashMap.GetValue(FLREPtrCopy(PFLRERawByteChar(Replacement),j,i-j));
                inc(i);
               end else begin
                e:=-1;
               end;
              end;
             end;
            end;
            if e<0 then begin
             result:=result+cc+'{';
             i:=j;
            end else begin
             if (e>=0) and (e<length(Captures)) then begin
              result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[e].Start,Captures[e].Length);
             end;
            end;
           end;
           '0'..'9':begin
            if length(Captures)<10 then begin
             e:=ord(c)-ord('0');
             inc(i);
            end else begin
             e:=0;
             while i<ReplacementLength do begin
              c:=PFLRERawByteChar(Replacement)[i];
              case c of
               '0'..'9':begin
                e:=(e*10)+(ord(c)-ord('0'));
                inc(i);
               end;
               else begin
                break;
               end;
              end;
             end;
            end;
            if (e>=0) and (e<length(Captures)) then begin
             result:=result+FLREPtrCopy(PFLRERawByteChar(Input),Captures[e].Start,Captures[e].Length);
            end;
           end;
           else begin
            result:=result+c;
            inc(i);
           end;
          end;
         end;
        end;
        else begin
         result:=result+c;
         inc(i);
        end;
       end;
      end;
     end;
     CurrentPosition:=Captures[0].Start+Captures[0].Length;
     LastEnd:=CurrentPosition;
     if Limit>0 then begin
      dec(Limit);
     end;
    end;
    if CurrentPosition<InputLength then begin
     result:=result+FLREPtrCopy(PFLRERawByteChar(Input),CurrentPosition,InputLength-CurrentPosition);
    end;
   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;
  end;
 finally
  SetLength(Captures,0);
 end;
end;

function TFLRE.PtrReplaceCallback(const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString;
var CurrentPosition,Next,LastPosition:TFLRESizeInt;
    Captures:TFLRECaptures;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:='';
 if rfMULTIMATCH in Flags then begin
  raise EFLRE.Create('ReplaceCallback unsupported in multi match mode');
 end;
 if not assigned(ReplacementCallback) then begin
  raise EFLRE.Create('ReplaceCallback does need a replacement callback');
 end;
 Captures:=nil;
 try
  CurrentPosition:=StartPosition;
  LastPosition:=CurrentPosition;
  if CurrentPosition>=0 then begin
   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
   try
    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;
    SetLength(Captures,CountCaptures);
    while (CurrentPosition<InputLength) and (Limit<>0) and SearchMatch(ThreadLocalStorageInstance,Captures,CurrentPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) do begin
     Next:=CurrentPosition+1;
     if (Captures[0].Start+Captures[0].Length)=LastPosition then begin
      CurrentPosition:=Captures[0].Start+Captures[0].Length;
      if CurrentPosition<Next then begin
       CurrentPosition:=Next;
      end;
     end else begin
      if LastPosition<Captures[0].Start then begin
       result:=result+FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,Captures[0].Start-LastPosition);
      end;
      result:=result+ReplacementCallback(ReplacementCallbackData,PFLRERawByteChar(Input),InputLength,Captures);
      CurrentPosition:=Captures[0].Start+Captures[0].Length;
      if CurrentPosition<Next then begin
       CurrentPosition:=Next;
      end;
      LastPosition:=CurrentPosition;
     end;
     if Limit>0 then begin
      dec(Limit);
     end;
    end;
    if LastPosition<InputLength then begin
     result:=result+FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,InputLength-LastPosition);
    end;
   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;
  end;
 finally
  SetLength(Captures,0);
 end;
end;

function TFLRE.PtrReplaceCallback(const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1):TFLRERawByteString;
var CurrentPosition,Next,LastPosition:TFLRESizeInt;
    Captures:TFLRECaptures;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:='';
 if rfMULTIMATCH in Flags then begin
  raise EFLRE.Create('ReplaceCallback unsupported in multi match mode');
 end;
 if not assigned(ReplacementCallback) then begin
  raise EFLRE.Create('ReplaceCallback does need a replacement callback');
 end;
 Captures:=nil;
 try
  CurrentPosition:=StartPosition;
  LastPosition:=CurrentPosition;
  if CurrentPosition>=0 then begin
   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
   try
    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;
    SetLength(Captures,CountCaptures);
    while (CurrentPosition<InputLength) and (Limit<>0) and SearchMatch(ThreadLocalStorageInstance,Captures,CurrentPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) do begin
     Next:=CurrentPosition+1;
     if (Captures[0].Start+Captures[0].Length)=LastPosition then begin
      CurrentPosition:=Captures[0].Start+Captures[0].Length;
      if CurrentPosition<Next then begin
       CurrentPosition:=Next;
      end;
     end else begin
      if LastPosition<Captures[0].Start then begin
       result:=result+FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,Captures[0].Start-LastPosition);
      end;
      result:=result+ReplacementCallback(PFLRERawByteChar(Input),InputLength,Captures);
      CurrentPosition:=Captures[0].Start+Captures[0].Length;
      if CurrentPosition<Next then begin
       CurrentPosition:=Next;
      end;
      LastPosition:=CurrentPosition;
     end;
     if Limit>0 then begin
      dec(Limit);
     end;
    end;
    if LastPosition<InputLength then begin
     result:=result+FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,InputLength-LastPosition);
    end;
   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;
  end;
 finally
  SetLength(Captures,0);
 end;
end;

function TFLRE.PtrSplit(const Input:pointer;const InputLength:TFLRESizeInt;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=0;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
var LastPosition,MatchPosition,MatchEnd,Count,Index:TFLRESizeInt;
//  Done:boolean;
    Captures:TFLRECaptures;
    ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
begin
 result:=false;

 if rfMULTIMATCH in Flags then begin
  raise EFLRE.Create('Split unsupported in multi match mode');
 end;

 Count:=0;

 Captures:=nil;

 try

  LastPosition:=StartPosition;

  MatchPosition:=StartPosition;

  if LastPosition>=0 then begin

   ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;

   try

    ThreadLocalStorageInstance.Input:=Input;
    ThreadLocalStorageInstance.InputLength:=InputLength;

    SetLength(Captures,CountCaptures);

    if Limit<>0 then begin

     if InputLength=0 then begin

      if WithEmpty and not SearchMatch(ThreadLocalStorageInstance,Captures,MatchPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) then begin
       Count:=1;
       SetLength(SplittedStrings,Count);
       SplittedStrings[0]:='';
       result:=true;
      end;

     end else begin

      LastPosition:=StartPosition;
      MatchPosition:=StartPosition;

      while MatchPosition<InputLength do begin

       if not SearchMatch(ThreadLocalStorageInstance,Captures,MatchPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) then begin
        break;
       end;

       MatchPosition:=Captures[0].Start;
       if MatchPosition>=InputLength then begin
        break;
       end;

       MatchEnd:=Captures[0].Start+Captures[0].Length;

       if MatchEnd=LastPosition then begin
        inc(MatchPosition);
        continue;
       end;
           
       Assert(MatchEnd<>0,'FLRE internal error 2015-12-31-00-17-0000');

       if Count>=length(SplittedStrings) then begin
        SetLength(SplittedStrings,(Count+1)*2);
       end;
       SplittedStrings[Count]:=FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,MatchPosition-LastPosition);
       inc(Count);

       result:=true;

       if Limit>0 then begin
        dec(Limit);
        if Limit=0 then begin
         break;
        end;
       end;

       LastPosition:=MatchEnd;
       MatchPosition:=MatchEnd;

       for Index:=1 to CountCaptures-1 do begin
        if Captures[Index].Length>0 then begin
         if Count>=length(SplittedStrings) then begin
          SetLength(SplittedStrings,(Count+1)*2);
         end;
         SplittedStrings[Count]:=FLREPtrCopy(PFLRERawByteChar(Input),Captures[Index].Start,Captures[Index].Length);
         inc(Count);
        end else if WithEmpty then begin
         if Count>=length(SplittedStrings) then begin
          SetLength(SplittedStrings,(Count+1)*2);
         end;
         SplittedStrings[Count]:='';
         inc(Count);
        end;
        if Limit>0 then begin
         dec(Limit);
         if Limit=0 then begin
          break;
         end;
        end;
       end;

       if Limit=0 then begin
        break;
       end;
       
      end;

      if Limit<>0 then begin
       if LastPosition<InputLength then begin
        if Count>=length(SplittedStrings) then begin
         SetLength(SplittedStrings,(Count+1)*2);
        end;
        SplittedStrings[Count]:=FLREPtrCopy(PFLRERawByteChar(Input),LastPosition,InputLength-LastPosition);
        inc(Count);
       end else if WithEmpty then begin
        if Count>=length(SplittedStrings) then begin
         SetLength(SplittedStrings,(Count+1)*2);
        end;
        SplittedStrings[Count]:='';
        inc(Count);
       end;
      end;

     end;

    end;

    SetLength(SplittedStrings,Count);

   finally
    ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
   end;

  end;

 finally
  SetLength(Captures,0);
 end;

end;

function TFLRE.PtrTest(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):boolean;
var ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Index,Count:TFLRESizeInt;
    Captures:TFLRECaptures;
begin
 ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
 try
  ThreadLocalStorageInstance.Input:=Input;
  ThreadLocalStorageInstance.InputLength:=InputLength;
  Captures:=nil;
  try
   if rfMULTIMATCH in Flags then begin
    for Index:=0 to CountMultiSubMatches-1 do begin
     ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
    end;
    Count:=CountMultiSubMatches+1;
   end else begin
    Count:=CountCaptures;
   end;
   SetLength(Captures,Count);
   result:=SearchMatch(ThreadLocalStorageInstance,Captures,StartPosition,InputLength,false);
  finally
   SetLength(Captures,0);
  end;
 finally
  ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
 end;
end;

function TFLRE.PtrTestAll(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):boolean;
var ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Index,Count:TFLRESizeInt;
    Captures:TFLRECaptures;
begin
 ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
 try
  ThreadLocalStorageInstance.Input:=Input;
  ThreadLocalStorageInstance.InputLength:=InputLength;
  Captures:=nil;
  try
   if rfMULTIMATCH in Flags then begin
    for Index:=0 to CountMultiSubMatches-1 do begin
     ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
    end;
    Count:=CountMultiSubMatches+1;
   end else begin
    Count:=CountCaptures;
   end;
   SetLength(Captures,Count);
   result:=SearchMatch(ThreadLocalStorageInstance,Captures,StartPosition,InputLength,fifHaveUnanchoredStart in InternalFlags);
  finally
   SetLength(Captures,0);
  end;
 finally
  ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
 end;
end;

function TFLRE.PtrFind(const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt=0):TFLRESizeInt;
var ThreadLocalStorageInstance:TFLREThreadLocalStorageInstance;
    Index,Count:TFLRESizeInt;
    Captures:TFLRECaptures;
begin
 ThreadLocalStorageInstance:=AcquireThreadLocalStorageInstance;
 try
  ThreadLocalStorageInstance.Input:=Input;
  ThreadLocalStorageInstance.InputLength:=InputLength;
  Captures:=nil;
  try
   if rfMULTIMATCH in Flags then begin
    for Index:=0 to CountMultiSubMatches-1 do begin
     ThreadLocalStorageInstance.MultiSubMatches[Index]:=-1;
    end;
    Count:=CountMultiSubMatches+1;
   end else begin
    Count:=CountCaptures;
   end;
   SetLength(Captures,Count);
   if SearchMatch(ThreadLocalStorageInstance,Captures,StartPosition,InputLength,fifHaveUnanchoredStart in InternalFlags) then begin
    result:=Captures[0].Start;
   end else begin
    result:=-1;
   end;
  finally
   SetLength(Captures,0);
  end;
 finally
  ReleaseThreadLocalStorageInstance(ThreadLocalStorageInstance);
 end;
end;

function TFLRE.Match(const Input:TFLRERawByteString;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
var Counter:TFLRESizeInt;
begin
 result:=PtrMatch(PFLRERawByteChar(@Input[1]),length(Input),Captures,StartPosition-1);
 for Counter:=0 to length(Captures)-1 do begin
  inc(Captures[Counter].Start);
  if (rfMULTIMATCH in Flags) and (Counter=0) then begin
   break;
  end;
 end;
end;

function TFLRE.MatchNext(const Input:TFLRERawByteString;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
var Counter:TFLRESizeInt;
begin
 result:=PtrMatchNext(PFLRERawByteChar(@Input[1]),length(Input),Captures,StartPosition-1);
 for Counter:=0 to length(Captures)-1 do begin
  inc(Captures[Counter].Start);
  if (rfMULTIMATCH in Flags) and (Counter=0) then begin
   break;
  end;
 end;
end;

function TFLRE.MatchAll(const Input:TFLRERawByteString;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
var Counter,SubCounter:TFLRESizeInt;
begin
 result:=PtrMatchAll(PFLRERawByteChar(@Input[1]),length(Input),MultiCaptures,StartPosition-1,Limit);
 for Counter:=0 to length(MultiCaptures)-1 do begin
  for SubCounter:=0 to length(MultiCaptures[Counter])-1 do begin
   inc(MultiCaptures[Counter,SubCounter].Start);
   if (rfMULTIMATCH in Flags) and (SubCounter=0) then begin
    break;
   end;
  end;
 end;
end;

function TFLRE.ExtractAll(const Input:TFLRERawByteString;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
begin
 result:=PtrExtractAll(PFLRERawByteChar(@Input[1]),length(Input),MultiExtractions,StartPosition-1,Limit);
end;

function TFLRE.Replace(const Input,Replacement:TFLRERawByteString;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
begin
 result:=PtrReplace(PFLRERawByteChar(@Input[1]),length(Input),PFLRERawByteChar(@Replacement[1]),length(Replacement),StartPosition-1,Limit);
end;

function TFLRE.ReplaceCallback(const Input:TFLRERawByteString;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
begin
 result:=PtrReplaceCallback(PFLRERawByteChar(@Input[1]),length(Input),ReplacementCallbackData,ReplacementCallback,StartPosition-1,Limit);
end;

function TFLRE.ReplaceCallback(const Input:TFLRERawByteString;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
begin
 result:=PtrReplaceCallback(PFLRERawByteChar(@Input[1]),length(Input),ReplacementCallback,StartPosition-1,Limit);
end;

function TFLRE.Split(const Input:TFLRERawByteString;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
begin
 result:=PtrSplit(PFLRERawByteChar(@Input[1]),length(Input),SplittedStrings,StartPosition-1,Limit,WithEmpty);
end;

function TFLRE.Test(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):boolean;
begin
 result:=PtrTest(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1);
end;

function TFLRE.TestAll(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):boolean;
begin
 result:=PtrTestAll(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1);
end;

function TFLRE.Find(const Input:TFLRERawByteString;const StartPosition:TFLRESizeInt=1):TFLRESizeInt;
begin
 result:=PtrFind(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1)+1;
end;

function TFLRE.UTF8Match(const Input:TFLREUTF8String;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
var Counter:TFLRESizeInt;
begin
 result:=PtrMatch(PFLRERawByteChar(@Input[1]),length(Input),Captures,StartPosition-1);
 for Counter:=0 to length(Captures)-1 do begin
  inc(Captures[Counter].Start);
  if (rfMULTIMATCH in Flags) and (Counter=0) then begin
   break;
  end;
 end;
end;

function TFLRE.UTF8MatchNext(const Input:TFLREUTF8String;var Captures:TFLRECaptures;const StartPosition:TFLRESizeInt=1):boolean;
var Counter:TFLRESizeInt;
begin
 result:=PtrMatchNext(PFLRERawByteChar(@Input[1]),length(Input),Captures,StartPosition-1);
 for Counter:=0 to length(Captures)-1 do begin
  inc(Captures[Counter].Start);
  if (rfMULTIMATCH in Flags) and (Counter=0) then begin
   break;
  end;
 end;
end;

function TFLRE.UTF8MatchAll(const Input:TFLREUTF8String;var MultiCaptures:TFLREMultiCaptures;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
var Counter,SubCounter:TFLRESizeInt;
begin
 result:=PtrMatchAll(PFLRERawByteChar(@Input[1]),length(Input),MultiCaptures,StartPosition-1,Limit);
 for Counter:=0 to length(MultiCaptures)-1 do begin
  for SubCounter:=0 to length(MultiCaptures[Counter])-1 do begin
   inc(MultiCaptures[Counter,SubCounter].Start);
   if (rfMULTIMATCH in Flags) and (SubCounter=0) then begin
    break;
   end;
  end;
 end;
end;

function TFLRE.UTF8ExtractAll(const Input:TFLREUTF8String;var MultiExtractions:TFLREMultiStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):boolean;
begin
 result:=PtrExtractAll(PFLRERawByteChar(@Input[1]),length(Input),MultiExtractions,StartPosition-1,Limit);
end;

function TFLRE.UTF8Replace(const Input,Replacement:TFLREUTF8String;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLREUTF8String;
begin
 result:=PtrReplace(PFLRERawByteChar(@Input[1]),length(Input),PFLRERawByteChar(@Replacement[1]),length(Replacement),StartPosition-1,Limit);
end;

function TFLRE.UTF8ReplaceCallback(const Input:TFLREUTF8String;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
begin
 result:=PtrReplaceCallback(PFLRERawByteChar(@Input[1]),length(Input),ReplacementCallbackData,ReplacementCallback,StartPosition-1,Limit);
end;

function TFLRE.UTF8ReplaceCallback(const Input:TFLREUTF8String;const ReplacementCallback:TFLREReplacementObjectCallback;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1):TFLRERawByteString;
begin
 result:=PtrReplaceCallback(PFLRERawByteChar(@Input[1]),length(Input),ReplacementCallback,StartPosition-1,Limit);
end;

function TFLRE.UTF8Split(const Input:TFLREUTF8String;var SplittedStrings:TFLREStrings;const StartPosition:TFLRESizeInt=1;Limit:TFLRESizeInt=-1;const WithEmpty:boolean=true):boolean;
begin
 result:=PtrSplit(PFLRERawByteChar(@Input[1]),length(Input),SplittedStrings,StartPosition-1,Limit,WithEmpty);
end;

function TFLRE.UTF8Test(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):boolean;
begin
 result:=PtrTest(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1);
end;

function TFLRE.UTF8TestAll(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):boolean;
begin
 result:=PtrTestAll(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1);
end;

function TFLRE.UTF8Find(const Input:TFLREUTF8String;const StartPosition:TFLRESizeInt=1):TFLRESizeInt;
begin
 result:=PtrFind(PFLRERawByteChar(@Input[1]),length(Input),StartPosition-1)+1;
end;

function TFLRE.GetRange(var LowRange,HighRange:TFLRERawByteString):boolean;
begin
 result:=false;
 ParallelLockEnter(@ParallelLock);
 try
  if not (fifHasRange in InternalFlags) then begin
   CompileRange;
  end;
  if fifHasRange in InternalFlags then begin
   LowRange:=RangeLow;
   HighRange:=RangeHigh;
   result:=true;
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRE.DumpRegularExpressionNode(StartNode:PFLRENode):TFLRERawByteString;
var CharClass:TFLRECharClass;
 function ProcessNode(Node:PFLRENode;ParentPrecedence:TFLREInt32):TFLRERawByteString;
 const HexChars:array[$0..$f] of TFLRERawByteChar='0123456789abcdef';
 var Count,Counter,LowChar,HighChar:TFLREInt32;
     SingleChar,CurrentChar:TFLRERawByteChar;
 begin
  result:='';
  if assigned(Node) then begin
   case Node^.NodeType of
    ntALT:begin
     if assigned(Node^.Left) then begin
      if NodePrecedences[Node^.Left^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType]);
      end;
     end;
     result:=result+'|';
     if assigned(Node^.Right) then begin
      if NodePrecedences[Node^.Right^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Right,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Right,NodePrecedences[Node^.NodeType]);
      end;
     end;
    end;
    ntCAT:begin
     if assigned(Node^.Left) then begin
      if NodePrecedences[Node^.Left^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType]);
      end;
     end;
     if assigned(Node^.Right) then begin
      if NodePrecedences[Node^.Right^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Right,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Right,NodePrecedences[Node^.NodeType]);
      end;
     end;
    end;
    ntCHAR:begin
     CharClass:=GetCharClass(Node^.Value);
     SingleChar:=#0;
     Count:=0;
     for CurrentChar:=#0 to #255 do begin
      if CurrentChar in CharClass then begin
       if Count=0 then begin
        SingleChar:=CurrentChar;
        inc(Count);
       end else begin
        inc(Count);
        break;
       end;
      end;
     end;
     if Count=1 then begin
      if SingleChar in ['a'..'z','A'..'Z','0'..'9','_','@',' ','/'] then begin
       result:=result+SingleChar;
      end else begin
       result:=result+'\x'+HexChars[TFLREUInt8(TFLRERawByteChar(SingleChar)) shr 4]+HexChars[TFLREUInt8(TFLRERawByteChar(SingleChar)) and $f];
      end;
     end else begin
      result:=result+'[';
      Counter:=0;
      while Counter<256 do begin
       CurrentChar:=TFLRERawByteChar(TFLREUInt8(Counter));
       if CurrentChar in CharClass then begin
        LowChar:=Counter;
        HighChar:=Counter;
        while Counter<256 do begin
         CurrentChar:=TFLRERawByteChar(TFLREUInt8(Counter));
         if CurrentChar in CharClass then begin
          HighChar:=Counter;
          inc(Counter);
         end else begin
          break;
         end;
        end;
        if LowChar=HighChar then begin
         if TFLRERawByteChar(TFLREUInt8(LowChar)) in ['a'..'z','A'..'Z','0'..'9','_','@',' ','/'] then begin
          result:=result+TFLRERawByteChar(TFLREUInt8(LowChar));
         end else begin
          result:=result+'\x'+HexChars[LowChar shr 4]+HexChars[LowChar and $f];
         end;
        end else begin
         if TFLRERawByteChar(TFLREUInt8(LowChar)) in ['a'..'z','A'..'Z','0'..'9','_','@',' ','/'] then begin
          result:=result+TFLRERawByteChar(TFLREUInt8(LowChar));
         end else begin
          result:=result+'\x'+HexChars[LowChar shr 4]+HexChars[LowChar and $f];
         end;
         result:=result+'-';
         if TFLRERawByteChar(TFLREUInt8(HighChar)) in ['a'..'z','A'..'Z','0'..'9','_','@',' ','/'] then begin
          result:=result+TFLRERawByteChar(TFLREUInt8(HighChar));
         end else begin
          result:=result+'\x'+HexChars[HighChar shr 4]+HexChars[HighChar and $f];
         end;
        end;
       end else begin
        inc(Counter);
       end;
      end;
      result:=result+']';
     end;
    end;
    ntPAREN,ntMULTIMATCH:begin
     result:='('+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
    end;
    ntQUEST:begin
     if assigned(Node^.Left) then begin
      if NodePrecedences[Node^.Left^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType]);
      end;
     end;
     result:=result+'?';
     if Node^.Value=qkLAZY then begin
      result:=result+'?';
     end;
    end;
    ntSTAR:begin
     if assigned(Node^.Left) then begin
      if NodePrecedences[Node^.Left^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType]);
      end;
     end;
     result:=result+'*';
     if Node^.Value=qkLAZY then begin
      result:=result+'?';
     end;
    end;
    ntPLUS:begin
     if assigned(Node^.Left) then begin
      if NodePrecedences[Node^.Left^.NodeType]>NodePrecedences[Node^.NodeType] then begin
       result:=result+'(?:'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
      end else begin
       result:=result+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType]);
      end;
     end;
     result:=result+'+';
     if Node^.Value=qkLAZY then begin
      result:=result+'?';
     end;
    end;
    ntZEROWIDTH:begin
     if (Node^.Value and sfEmptyBeginLine)<>0 then begin
      result:=result+'(?m:^)';
     end;
     if (Node^.Value and sfEmptyEndLine)<>0 then begin
      result:=result+'(?m:$)';
     end;
     if (Node^.Value and sfEmptyBeginText)<>0 then begin
      result:=result+'(?-m:^)';
     end;
     if (Node^.Value and sfEmptyEndText)<>0 then begin
      result:=result+'(?-m:$)';
     end;
     if (Node^.Value and sfEmptyWordBoundary)<>0 then begin
      result:=result+'\b';
     end;
     if (Node^.Value and sfEmptyNonWordBoundary)<>0 then begin
      result:=result+'\B';
     end;
    end;
    ntLOOKBEHINDNEGATIVE:begin
     if Node^.Value<CountLookAssertionStrings then begin
      result:=result+'(?<!'+LookAssertionStrings[Node^.Value]+')';
     end else begin
      result:=result+'(?<!)';
     end;
    end;
    ntLOOKBEHINDPOSITIVE:begin
     if Node^.Value<CountLookAssertionStrings then begin
      result:=result+'(?<='+LookAssertionStrings[Node^.Value]+')';
     end else begin
      result:=result+'(?<=)';
     end;
    end;
    ntLOOKAHEADNEGATIVE:begin
     if Node^.Value<CountLookAssertionStrings then begin
      result:=result+'(?!'+LookAssertionStrings[Node^.Value]+')';
     end else begin
      result:=result+'(?!)';
     end;
    end;
    ntLOOKAHEADPOSITIVE:begin
     if Node^.Value<CountLookAssertionStrings then begin
      result:=result+'(?='+LookAssertionStrings[Node^.Value]+')';
     end else begin
      result:=result+'(?=)';
     end;
    end;
    ntBACKREFERENCE,ntBACKREFERENCEIGNORECASE:begin
     if (Node^.Flags and 1)<>0 then begin
      result:=result+'(?P='+TFLRERawByteString(IntToStr(Node^.Value shr 1))+':'+ProcessNode(Node^.Left,NodePrecedences[Node^.NodeType])+')';
     end else begin
      result:=result+'\g{'+TFLRERawByteString(IntToStr(Node^.Value shr 1))+'}';
     end;
    end;
   end;
  end;
 end;
begin
 result:=ProcessNode(StartNode,npTopLevel);
end;

function TFLRE.DumpRegularExpression:TFLRERawByteString;
begin
 result:=DumpRegularExpressionNode(AnchoredRootNode);
end;

function TFLRE.GetPrefilterExpression:TFLRERawByteString;
begin
 result:='';
 ParallelLockEnter(@ParallelLock);
 try
  if not (fifHasPrefilter in InternalFlags) then begin
   PrefilterRootNode:=CompilePrefilterTree(AnchoredRootNode);
   PrefilterRootNode:=PrefilterOptimize(PrefilterRootNode);
   Include(InternalFlags,fifHasPrefilter);
  end;
  if assigned(PrefilterRootNode) then begin
   result:=PrefilterRootNode.Expression;
   if (length(result)>0) and (result[1]='(') then begin
    result:=copy(result,2,length(result)-2);
   end;
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRE.GetPrefilterShortExpression:TFLRERawByteString;
begin
 result:='';
 ParallelLockEnter(@ParallelLock);
 try
  if not (fifHasPrefilter in InternalFlags) then begin
   PrefilterRootNode:=CompilePrefilterTree(AnchoredRootNode);
   PrefilterRootNode:=PrefilterOptimize(PrefilterRootNode);
   Include(InternalFlags,fifHasPrefilter);
  end;
  if assigned(PrefilterRootNode) then begin
   result:=PrefilterRootNode.ShortExpression;
   if (length(result)>0) and (result[1]='(') then begin
    result:=copy(result,2,length(result)-2);
   end;
  end;
  if length(result)=0 then begin
   result:='*';
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRE.GetPrefilterSQLBooleanFullTextExpression:TFLRERawByteString;
begin
 result:='';
 ParallelLockEnter(@ParallelLock);
 try
  if not (fifHasPrefilter in InternalFlags) then begin
   PrefilterRootNode:=CompilePrefilterTree(AnchoredRootNode);
   PrefilterRootNode:=PrefilterOptimize(PrefilterRootNode);
   Include(InternalFlags,fifHasPrefilter);
  end;
  if assigned(PrefilterRootNode) then begin
   result:=PrefilterRootNode.SQLBooleanFullTextExpression;
   if (length(result)>0) and (result[1]='(') then begin
    result:=copy(result,2,length(result)-2);
   end;
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRE.GetPrefilterSQLExpression(Field:TFLRERawByteString):TFLRERawByteString;
begin
 result:='';
 ParallelLockEnter(@ParallelLock);
 try
  if not (fifHasPrefilter in InternalFlags) then begin
   PrefilterRootNode:=CompilePrefilterTree(AnchoredRootNode);
   PrefilterRootNode:=PrefilterOptimize(PrefilterRootNode);
   Include(InternalFlags,fifHasPrefilter);
  end;
  if assigned(PrefilterRootNode) then begin
   if length(trim(String(Field)))=0 then begin
    Field:='textfield';
   end;
   result:=PrefilterRootNode.SQLExpression(Field);
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
 if length(result)=0 then begin
  result:='('+Field+' LIKE "%")';
 end;
end;

constructor TFLRECacheHashMap.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TFLRECacheHashMap.Destroy;
var Counter:TFLRESizeInt;
begin
 Clear;
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 inherited Destroy;
end;

procedure TFLRECacheHashMap.Clear;
var Counter:TFLRESizeInt;
begin
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

function TFLRECacheHashMap.FindCell(const Key:TFLRERawByteString):TFLREUInt32;
var HashCode,Mask,Step:TFLREUInt32;
    Entity:TFLREInt32;
begin
 HashCode:=HashString(Key);
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (Entities[Entity].Key=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TFLRECacheHashMap.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TFLREInt32;
    OldEntities:TFLRECacheHashMapEntities;
    OldCellToEntityIndex:TFLRECacheHashMapEntityIndices;
    OldEntityToCellIndex:TFLRECacheHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 for Counter:=0 to length(OldEntities)-1 do begin
  OldEntities[Counter].Key:='';
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TFLRECacheHashMap.Add(const Key:TFLRERawByteString;Value:TFLRECacheHashMapData):PFLRECacheHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
 end;
end;

function TFLRECacheHashMap.Get(const Key:TFLRERawByteString;CreateIfNotExist:boolean=false):PFLRECacheHashMapEntity;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
 end else if CreateIfNotExist then begin
  result:=Add(Key,nil);
 end;
end;

function TFLRECacheHashMap.Delete(const Key:TFLRERawByteString):boolean;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity].Key:='';
  Entities[Entity].Value:=nil;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TFLRECacheHashMap.GetValue(const Key:TFLRERawByteString):TFLRECacheHashMapData;
var Entity:TFLREInt32;
    Cell:TFLREUInt32;
begin
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=Entities[Entity].Value;
 end else begin
  result:=nil;
 end;
end;

procedure TFLRECacheHashMap.SetValue(const Key:TFLRERawByteString;const Value:TFLRECacheHashMapData);
begin
 Add(Key,Value);
end;         

constructor TFLRECache.Create;
begin
 inherited Create;
 ParallelLock:=0;
 List:=TFLREPointerList.Create;
 HashMap:=TFLRECacheHashMap.Create;
end;

destructor TFLRECache.Destroy;
var Index:TFLREInt32;
begin
 for Index:=0 to List.Count-1 do begin
  TFLRE(List[Index]).Free;
 end;
 List.Free;
 HashMap.Free;
 inherited Destroy;
end;

procedure TFLRECache.Clear;
var Index:TFLREInt32;
begin
 ParallelLockEnter(@ParallelLock);
 try
  for Index:=0 to List.Count-1 do begin
   TFLRE(List[Index]).Free;
  end;
  List.Clear;
  HashMap.Clear;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRECache.Get(const ARegularExpression:TFLRERawByteString;const AFlags:TFLREFlags=[rfDELIMITERS]):TFLRE;
var HashKey:TFLRERawByteString;
begin
 HashKey:=FLREPtrCopy(pointer(@AFlags),0,SizeOf(TFLREFlags))+#0#1#0+ARegularExpression;
 ParallelLockEnter(@ParallelLock);
 try
  result:=HashMap.GetValue(HashKey);
  if not assigned(result) then begin
   result:=TFLRE.Create(ARegularExpression,AFlags);
   List.Add(result);
   HashMap.Add(HashKey,result);
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

function TFLRECache.Get(const ARegularExpressions:array of TFLRERawByteString;const AFlags:TFLREFlags=[]):TFLRE;
var Index:TFLREInt32;
    HashKey:TFLRERawByteString;
begin
 HashKey:=FLREPtrCopy(pointer(@AFlags),0,SizeOf(TFLREFlags));
 for Index:=0 to length(ARegularExpressions)-1 do begin
  HashKey:=HashKey+#0#2#0+ARegularExpressions[Index];
 end;
 ParallelLockEnter(@ParallelLock);
 try
  result:=HashMap.GetValue(HashKey);
  if not assigned(result) then begin
   result:=TFLRE.Create(ARegularExpressions,AFlags);
   List.Add(result);
   HashMap.Add(HashKey,result);
  end;
 finally
  ParallelLockLeave(@ParallelLock);
 end;
end;

const FLREGetVersionStringData:TFLRERawByteString=FLREVersionString+#0;

function FLREGetVersion:TFLREUInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 result:=FLREVersion;
end;

function FLREGetVersionString:PFLRERawByteChar; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 result:=PFLRERawByteChar(@FLREGetVersionStringData[1]);
end;

function FLRECreate(const RegularExpression:PFLRERawByteChar;const RegularExpressionLength:TFLRESizeInt;const Flags:TFLREUInt32;const Error:PPAnsiChar):pointer; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var RealFlags:TFLREFlags;
    s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=nil;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 try
  RealFlags:=[];
  if (Flags and carfIGNORECASE)<>0 then begin
   Include(RealFlags,rfIGNORECASE);
  end;
  if (Flags and carfSINGLELINE)<>0 then begin
   Include(RealFlags,rfSINGLELINE);
  end;
  if (Flags and carfMULTILINE)<>0 then begin
   Include(RealFlags,rfMULTILINE);
  end;
  if (Flags and carfFREESPACING)<>0 then begin
   Include(RealFlags,rfFREESPACING);
  end;
  if (Flags and carfNAMED)<>0 then begin
   Include(RealFlags,rfNAMED);
  end;
  if (Flags and carfNOCAPTURES)<>0 then begin
   Include(RealFlags,rfNOCAPTURES);
  end;
  if (Flags and carfUNGREEDY)<>0 then begin
   Include(RealFlags,rfUNGREEDY);
  end;
  if (Flags and carfLONGEST)<>0 then begin
   Include(RealFlags,rfLONGEST);
  end;
  if (Flags and carfMULTIMATCH)<>0 then begin
   Include(RealFlags,rfMULTIMATCH);
  end;
  if (Flags and carfUTF8)<>0 then begin
   Include(RealFlags,rfUTF8);
  end;
  if (Flags and carfONLYFASTOPTIMIZATIONS)<>0 then begin
   Include(RealFlags,rfONLYFASTOPTIMIZATIONS);
  end;
  if (Flags and carfDELIMITERS)<>0 then begin
   Include(RealFlags,rfDELIMITERS);
  end;
  try
   TFLRE(result):=TFLRE.Create(TFLRERawByteString(FLREPtrCopy(RegularExpression,0,RegularExpressionLength)),RealFlags);
  except
   FreeAndNil(TFLRE(result));
   raise;
  end;
 except
  on e:Exception do begin
   if assigned(Error) then begin
    s:=TFLRERawByteString(e.Message);
    Len:=length(s);
    if Len>0 then begin
     GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
     Move(s[1],Error^[0],Len);
     Error^[Len]:=#0;
    end else begin
     Error^:=nil;
    end;
   end;
   result:=nil;
  end;
 end;
end;

procedure FLREDestroy(const Instance:pointer); {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 TFLRE(Instance).Free;
end;

function FLREAlloc(const Size:TFLRESizeInt):pointer; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 GetMem(result,Size);
end;

procedure FLREFree(const Data:pointer); {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 FreeMem(Data);
end;

function FLREGetCountCaptures(const Instance:pointer):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 if assigned(Instance) then begin
  result:=TFLRE(Instance).CountCaptures;
 end else begin
  result:=0;
 end;
end;

function FLREGetNamedGroupIndex(const Instance:pointer;const GroupName:PFLRERawByteChar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
begin
 if assigned(Instance) then begin
  result:=TFLRE(Instance).NamedGroupStringIntegerPairHashMap.GetValue(GroupName);
 end else begin
  result:=-1;
 end;
end;

function FLREDumpRegularExpression(const Instance:pointer;const RegularExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(RegularExpression) and assigned(RegularExpression^) then begin
  FreeMem(RegularExpression^);
  RegularExpression^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(RegularExpression) then begin
    s:='';
    try
     s:=TFLRE(Instance).DumpRegularExpression;
     Len:=length(s);
     if Len>0 then begin
      GetMem(RegularExpression^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],RegularExpression^[0],Len);
      RegularExpression^[Len]:=#0;
     end else begin
      RegularExpression^:=nil;
     end;
    finally
     s:='';
    end;
   end;
   result:=1;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREGetPrefilterExpression(const Instance:pointer;const Expression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(Expression) and assigned(Expression^) then begin
  FreeMem(Expression^);
  Expression^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(Expression) then begin
    s:='';
    try
     s:=TFLRE(Instance).GetPrefilterExpression;
     Len:=length(s);
     if Len>0 then begin
      GetMem(Expression^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Expression^[0],Len);
      Expression^[Len]:=#0;
     end else begin
      Expression^:=nil;
     end;
    finally
     s:='';
    end;
   end;
   result:=1;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREGetPrefilterShortExpression(const Instance:pointer;const ShortExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(ShortExpression) and assigned(ShortExpression^) then begin
  FreeMem(ShortExpression^);
  ShortExpression^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(ShortExpression) then begin
    s:='';
    try
     s:=TFLRE(Instance).GetPrefilterShortExpression;
     Len:=length(s);
     if Len>0 then begin
      GetMem(ShortExpression^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],ShortExpression^[0],Len);
      ShortExpression^[Len]:=#0;
     end else begin
      ShortExpression^:=nil;
     end;
    finally
     s:='';
    end;
   end;
   result:=1;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREGetPrefilterSQLBooleanFullTextExpression(const Instance:pointer;const SQLBooleanFullTextExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(SQLBooleanFullTextExpression) and assigned(SQLBooleanFullTextExpression^) then begin
  FreeMem(SQLBooleanFullTextExpression^);
  SQLBooleanFullTextExpression^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(SQLBooleanFullTextExpression) then begin
    s:='';
    try
     s:=TFLRE(Instance).GetPrefilterSQLBooleanFullTextExpression;
     Len:=length(s);
     if Len>0 then begin
      GetMem(SQLBooleanFullTextExpression^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],SQLBooleanFullTextExpression^[0],Len);
      SQLBooleanFullTextExpression^[Len]:=#0;
     end else begin
      SQLBooleanFullTextExpression^:=nil;
     end;
    finally
     s:='';
    end;
   end;
   result:=1;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREGetPrefilterSQLExpression(const Instance:pointer;const Field:PFLRERawByteChar;SQLExpression,Error:ppansichar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(SQLExpression) and assigned(SQLExpression^) then begin
  FreeMem(SQLExpression^);
  SQLExpression^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(SQLExpression) then begin
    s:='';
    try
     s:=TFLRE(Instance).GetPrefilterSQLExpression(Field);
     Len:=length(s);
     if Len>0 then begin
      GetMem(SQLExpression^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],SQLExpression^[0],Len);
      SQLExpression^[Len]:=#0;
     end else begin
      SQLExpression^:=nil;
     end;
    finally
     s:='';
    end;
   end;
   result:=1;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREGetRange(const Instance:pointer;const LowRange,HighRange:PPAnsiChar;const LowRangeLength,HighRangeLength:PFLRESizeInt;const Error:PPAnsiChar):TFLREInt32; {$ifdef win32}{$ifdef cpu386}stdcall;{$endif}{$endif}
var LocalLowRange,LocalHighRange:TFLRERawByteString;
begin
 LocalLowRange:='';
 LocalHighRange:='';
 try
  if TFLRE(Instance).GetRange(LocalLowRange,LocalHighRange) then begin
   GetMem(LowRange^,(length(LocalLowRange)+1)*SizeOf(TFLRERawByteChar));
   GetMem(HighRange^,(length(LocalHighRange)+1)*SizeOf(TFLRERawByteChar));
   if length(LocalLowRange)>0 then begin
    Move(LocalLowRange[1],LowRange^[0],length(LocalLowRange));
   end;
   if length(LocalHighRange)>0 then begin
    Move(LocalHighRange[1],HighRange^[0],length(LocalHighRange));
   end;
   LowRange^[length(LocalLowRange)]:=#0;
   HighRange^[length(LocalHighRange)]:=#0;
   LowRangeLength^:=length(LocalLowRange);
   HighRangeLength^:=length(LocalHighRange);
   result:=1;
  end else begin
   result:=0;
  end;
 finally
  LocalLowRange:='';
  LocalHighRange:='';
 end;
end;

function FLREMatch(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Captures:PPointer;const MaxCaptures:TFLRESizeInt;const CountCaptures:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
type TTFLRESizeInts=array[0..65535] of TFLRESizeInt;
     PFLRESizeInts=^TTFLRESizeInts;
var s:TFLRERawByteString;
    Len,Index:TFLRESizeInt;
    LocalCaptures:TFLRECaptures;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(Captures) and assigned(Captures^) then begin
  FreeMem(Captures^);
  Captures^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(Captures) then begin
    LocalCaptures:=nil;
    try
     if TFLRE(Instance).PtrMatch(Input,InputLength,LocalCaptures,StartPosition) then begin
      if MaxCaptures<0 then begin
       GetMem(Captures^,length(LocalCaptures)*(sizeof(TFLRESizeInt)*2));
       for Index:=0 to length(LocalCaptures)-1 do begin
        PFLRESizeInts(Captures^)^[(Index shl 1) or 0]:=LocalCaptures[Index].Start;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 1]:=LocalCaptures[Index].Length;
       end;
      end else begin
       for Index:=0 to length(LocalCaptures)-1 do begin
        if Index>=MaxCaptures then begin
         break;
        end;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 0]:=LocalCaptures[Index].Start;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 1]:=LocalCaptures[Index].Length;
       end;
      end;
      if assigned(CountCaptures) then begin
       if MaxCaptures<0 then begin
        CountCaptures^:=length(LocalCaptures);
       end else if length(LocalCaptures)>MaxCaptures then begin
        CountCaptures^:=MaxCaptures;
       end else begin
        CountCaptures^:=length(LocalCaptures);
       end;
      end;
      result:=1;
     end;
    finally
     SetLength(LocalCaptures,0);
    end;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREMatchNext(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Captures:PPointer;const MaxCaptures:TFLRESizeInt;const CountCaptures:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
type TTFLRESizeInts=array[0..65535] of TFLRESizeInt;
     PFLRESizeInts=^TTFLRESizeInts;
var s:TFLRERawByteString;
    Len,Index:TFLRESizeInt;
    LocalCaptures:TFLRECaptures;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if (MaxCaptures<0) and assigned(Captures) and assigned(Captures^) then begin
  FreeMem(Captures^);
  Captures^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(Captures) then begin
    LocalCaptures:=nil;
    try
     if TFLRE(Instance).PtrMatchNext(Input,InputLength,LocalCaptures,StartPosition) then begin
      if MaxCaptures<0 then begin
       GetMem(Captures^,length(LocalCaptures)*(sizeof(TFLRESizeInt)*2));
       for Index:=0 to length(LocalCaptures)-1 do begin
        PFLRESizeInts(Captures^)^[(Index shl 1) or 0]:=LocalCaptures[Index].Start;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 1]:=LocalCaptures[Index].Length;
       end;
      end else begin
       for Index:=0 to length(LocalCaptures)-1 do begin
        if Index>=MaxCaptures then begin
         break;
        end;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 0]:=LocalCaptures[Index].Start;
        PFLRESizeInts(Captures^)^[(Index shl 1) or 1]:=LocalCaptures[Index].Length;
       end;
      end;
      if assigned(CountCaptures) then begin
       if MaxCaptures<0 then begin
        CountCaptures^:=length(LocalCaptures);
       end else if length(LocalCaptures)>MaxCaptures then begin
        CountCaptures^:=MaxCaptures;
       end else begin
        CountCaptures^:=length(LocalCaptures);
       end;
      end;
      result:=1;
     end;
    finally
     SetLength(LocalCaptures,0);
    end;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREMatchAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const MultiCaptures:PPointer;const MaxMultiCaptures:TFLRESizeInt;const CountMultiCaptures,CountCaptures:PFLRESizeInt;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len,Index,SubIndex:TFLRESizeInt;
    LocalMultiCaptures:TFLREMultiCaptures;
    p:PFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if (MaxMultiCaptures<0) and assigned(MultiCaptures) and assigned(MultiCaptures^) then begin
  FreeMem(MultiCaptures^);
  MultiCaptures^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(MultiCaptures) then begin
    LocalMultiCaptures:=nil;
    try
     if TFLRE(Instance).PtrMatchAll(Input,InputLength,LocalMultiCaptures,StartPosition,Limit) then begin
      if MaxMultiCaptures<0 then begin
       GetMem(MultiCaptures^,length(LocalMultiCaptures)*TFLRE(Instance).CountCaptures*(sizeof(TFLRESizeInt)*2));
       p:=MultiCaptures^;
       for Index:=0 to length(LocalMultiCaptures)-1 do begin
        for SubIndex:=0 to length(LocalMultiCaptures[Index])-1 do begin
         p^:=LocalMultiCaptures[Index,SubIndex].Start;
         inc(p);
         p^:=LocalMultiCaptures[Index,SubIndex].Length;
         inc(p);
        end;
       end;
      end else begin
       p:=MultiCaptures^;
       for Index:=0 to length(LocalMultiCaptures)-1 do begin
        if Index>=MaxMultiCaptures then begin
         break;
        end;
        for SubIndex:=0 to length(LocalMultiCaptures[Index])-1 do begin
         p^:=LocalMultiCaptures[Index,SubIndex].Start;
         inc(p);
         p^:=LocalMultiCaptures[Index,SubIndex].Length;
         inc(p);
        end;
       end;
      end;
      if assigned(CountMultiCaptures) then begin
       if MaxMultiCaptures<0 then begin
        CountMultiCaptures^:=length(LocalMultiCaptures);
       end else if length(LocalMultiCaptures)>MaxMultiCaptures then begin
        CountMultiCaptures^:=MaxMultiCaptures;
       end else begin
        CountMultiCaptures^:=length(LocalMultiCaptures);
       end;
      end;
      if assigned(CountCaptures) then begin
       CountCaptures^:=TFLRE(Instance).CountCaptures;
      end;
      result:=1;
     end;
    finally
     SetLength(LocalMultiCaptures,0);
    end;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREReplaceAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const Replacement:pointer;const ReplacementLength:TFLRESizeInt;const ResultString:PPointer;const ResultStringLength:PFLREInt32;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(ResultString) and assigned(ResultString^) then begin
  FreeMem(ResultString^);
  ResultString^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(ResultString) then begin
    s:='';
    try
     s:=TFLRE(Instance).PtrReplace(Input,InputLength,Replacement,ReplacementLength,StartPosition,Limit);
     Len:=length(s);
     if Len>0 then begin
      GetMem(ResultString^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],PFLRERawByteChar(ResultString^)[0],Len);
      PFLRERawByteChar(ResultString^)[Len]:=#0;
     end else begin
      ResultString^:=nil;
     end;
     if assigned(ResultStringLength) then begin
      ResultStringLength^:=Len;
     end;
     result:=1;
    finally
     s:='';
    end;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

type TFLREReplaceCallbackData=record
      Input:pointer;
      InputLength:TFLRESizeInt;
      CallbackData:pointer;
      Callback:TFLREReplacementExternalCallback;
     end;
     PFLREReplaceCallbackData=^TFLREReplaceCallbackData;

function FLREReplaceCallbackHandler(const Data:pointer;const Input:PFLRERawByteChar;const InputLength:TFLRESizeInt;const Captures:TFLRECaptures):TFLRERawByteString;
type TTFLRESizeInts=array[0..65535] of TFLRESizeInt;
     PFLRESizeInts=^TTFLRESizeInts;
var CallbackData:PFLREReplaceCallbackData;
    Replacement:PAnsiChar;
    ReplacementLength,Index:TFLRESizeInt;
    TemporaryCaptures:Pointer;
begin
 result:='';
 CallbackData:=Data;
 if (length(Captures)>0) and assigned(CallbackData) and assigned(CallbackData^.Callback) then begin
  TemporaryCaptures:=nil;
  try
   Replacement:=nil;
   ReplacementLength:=0;
   try
    GetMem(TemporaryCaptures,length(Captures)*(sizeof(TFLRESizeInt)*2));
    for Index:=0 to length(Captures)-1 do begin
     PFLRESizeInts(TemporaryCaptures)^[(Index shl 1) or 0]:=Captures[Index].Start;
     PFLRESizeInts(TemporaryCaptures)^[(Index shl 1) or 1]:=Captures[Index].Length;
    end;
    if CallbackData^.Callback(CallbackData^.CallbackData,
                              CallbackData^.Input,
                              CallbackData^.InputLength,
                              TemporaryCaptures,
                              length(Captures),
                              @Replacement,
                              @ReplacementLength)>0 then begin
     SetLength(result,ReplacementLength);
     if ReplacementLength>0 then begin
      Move(Replacement^,result[1],ReplacementLength);
     end;
    end;
   finally
    if assigned(Replacement) then begin
     FreeMem(Replacement);
     Replacement:=nil;
    end;
   end;
  finally
   if assigned(TemporaryCaptures) then begin
    FreeMem(TemporaryCaptures);
    TemporaryCaptures:=nil;
   end;
  end;
 end;
end;

function FLREReplaceCallback(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const ReplacementCallbackData:pointer;const ReplacementCallback:TFLREReplacementExternalCallback;const ResultString:PPointer;const ResultStringLength:PFLREInt32;const StartPosition,Limit:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
    CallbackData:TFLREReplaceCallbackData;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(ResultString) and assigned(ResultString^) then begin
  FreeMem(ResultString^);
  ResultString^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if assigned(ResultString) then begin
    CallbackData.Input:=Input;
    CallbackData.InputLength:=InputLength;
    CallbackData.CallbackData:=ReplacementCallbackData;
    CallbackData.Callback:=ReplacementCallback;
    s:='';
    try
     s:=TFLRE(Instance).PtrReplaceCallback(Input,InputLength,@CallbackData,FLREReplaceCallbackHandler,StartPosition,Limit);
     Len:=length(s);
     if Len>0 then begin
      GetMem(ResultString^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],PFLRERawByteChar(ResultString^)[0],Len);
      PFLRERawByteChar(ResultString^)[Len]:=#0;
     end else begin
      ResultString^:=nil;
     end;
     if assigned(ResultStringLength) then begin
      ResultStringLength^:=Len;
     end;
     result:=1;
    finally
     s:='';
    end;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLRESplit(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;SplittedStrings:PPointer;const CountSplittedStrings:PFLRESizeInt;const StartPosition:TFLRESizeInt;const Limit:TFLRESizeInt;const WithEmpty:TFLREInt32;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len,Index:TFLRESizeInt;
    TemporarySplittedStrings:TFLREStrings;
    p:PFLREUInt8;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(SplittedStrings) and assigned(SplittedStrings^) then begin
  FreeMem(SplittedStrings^);
  SplittedStrings^:=nil;
 end;
 if assigned(Instance) then begin
  try
   TemporarySplittedStrings:=nil;
   try
    if TFLRE(Instance).PtrSplit(Input,InputLength,TemporarySplittedStrings,StartPosition,Limit,WithEmpty<>0) then begin
     CountSplittedStrings^:=length(TemporarySplittedStrings);
     if length(TemporarySplittedStrings)>0 then begin
      Len:=0;
      for Index:=0 to length(TemporarySplittedStrings)-1 do begin
       inc(Len,SizeOf(TFLRESizeInt)+((length(TemporarySplittedStrings[Index])+1)*SizeOf(TFLRERawByteChar)));
      end;
      GetMem(SplittedStrings^,Len);
      p:=SplittedStrings^;
      for Index:=0 to length(TemporarySplittedStrings)-1 do begin
       TFLRESizeInt(pointer(p)^):=length(TemporarySplittedStrings[Index]);
       inc(p,SizeOf(TFLRESizeInt));
       if length(TemporarySplittedStrings[Index])>0 then begin
        Move(TemporarySplittedStrings[Index][1],p^,length(TemporarySplittedStrings[Index])*SizeOf(TFLRERawByteChar));
        inc(p,length(TemporarySplittedStrings[Index])*SizeOf(TFLRERawByteChar));
       end;
       TFLRERawByteChar(pointer(p)^):=#0;
       inc(p,SizeOf(TFLRERawByteChar));
      end;
     end;
     result:=1;
    end else begin
     result:=0;
    end;
   finally
    TemporarySplittedStrings:=nil;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLRETest(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if TFLRE(Instance).PtrTest(Input,InputLength,StartPosition) then begin
    result:=1;
   end else begin
    result:=0;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLRETestAll(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLREInt32;
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=0;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(Instance) then begin
  try
   if TFLRE(Instance).PtrTestAll(Input,InputLength,StartPosition) then begin
    result:=1;
   end else begin
    result:=0;
   end;
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=0;
   end;
  end;
 end;
end;

function FLREFind(const Instance:pointer;const Input:pointer;const InputLength:TFLRESizeInt;const StartPosition:TFLRESizeInt;const Error:PPAnsiChar):TFLRESizeInt;
var s:TFLRERawByteString;
    Len:TFLRESizeInt;
begin
 result:=-1;
 if assigned(Error) and assigned(Error^) then begin
  FreeMem(Error^);
  Error^:=nil;
 end;
 if assigned(Instance) then begin
  try
   result:=TFLRE(Instance).PtrFind(Input,InputLength,StartPosition);
  except
   on e:Exception do begin
    if assigned(Error) then begin
     s:=TFLRERawByteString(e.Message);
     Len:=length(s);
     if Len>0 then begin
      GetMem(Error^,(Len+1)*SizeOf(TFLRERawByteChar));
      Move(s[1],Error^[0],Len);
      Error^[Len]:=#0;
     end else begin
      Error^:=nil;
     end;
     s:='';
    end;
    result:=-1;
   end;
  end;
 end;
end;

procedure InitializeFLRE;
const FLRESignature:TFLRERawByteString=' FLRE - yet another efficient, principled regular expression library - Version '+FLREVersionString+' - Copyright (C) 2015, Benjamin ''BeRo'' Rosseaux - benjamin@rosseaux.com - http://www.rosseaux.com ';
{$ifdef FLRERuntimeUTF8DFATableGeneration}
 procedure InitializeUTF8DFA;
 type TAnsiCharSet=set of TFLRERawByteChar;
{$ifdef FLREStrictUTF8}
{ c0  8 11000000   | d0  2 11(010000) | e0 10 11100000   | f0 11 11110000
  c1  8 11000001   | d1  2 11(010001) | e1  3 111(00001) | f1  6 111100(01)
  c2  2 11(000010) | d2  2 11(010010) | e2  3 111(00010) | f2  6 111100(10)
  c3  2 11(000011) | d3  2 11(010011) | e3  3 111(00011) | f3  6 111100(11)
  c4  2 11(000100) | d4  2 11(010100) | e4  3 111(00100) | f4  5 11110(100)
  c5  2 11(000101) | d5  2 11(010101) | e5  3 111(00101) | f5  8 11110101
  c6  2 11(000110) | d6  2 11(010110) | e6  3 111(00110) | f6  8 11110110
  c7  2 11(000111) | d7  2 11(010111) | e7  3 111(00111) | f7  8 11110111
  c8  2 11(001000) | d8  2 11(011000) | e8  3 111(01000) | f8  8 11111000
  c9  2 11(001001) | d9  2 11(011001) | e9  3 111(01001) | f9  8 11111001
  ca  2 11(001010) | da  2 11(011010) | ea  3 111(01010) | fa  8 11111010
  cb  2 11(001011) | db  2 11(011011) | eb  3 111(01011) | fb  8 11111011
  cc  2 11(001100) | dc  2 11(011100) | ec  3 111(01100) | fc  8 11111100
  cd  2 11(001101) | dd  2 11(011101) | ed  4 1110(1101) | fd  8 11111101
  ce  2 11(001110) | de  2 11(011110) | ee  3 111(01110) | fe  8 11111110
  cf  2 11(001111) | df  2 11(011111) | ef  3 111(01111) | ff  8 11111111  }
 const cc007F=$0;
       cc808F=$1;
       ccC2DF=$2;
       ccE1ECEEEF=$3;
       ccED=$4;
       ccF4=$5;
       ccF1F3=$6;
       ccA0BF=$7;
       ccC0C1F5FF=$8;
       cc909F=$9;
       ccE0=$a;
       ccF0=$b;
       tsBEGIN=0;
       tsERROR=1;
       tsSINGLETAIL=2;
       tsDOUBLETAIL=3;
       tsDOUBLETAILwithA0BFonly=4;
       tsDOUBLETAILwith809FFonly=5;
       tsTRIPLETAILwith90BFonly=6;
       tsTRIPLETAIL=7;
       tsTRIPLETAILwith808Fonly=8;
{$else}
 const cc007F=$0;
       cc80BF=$1; // Tail
       ccC0DF=$3; // ($ff shr $03)=$1f
       ccE0EF=$4; // ($ff shr $04)=$0f
       ccF0F7=$5; // ($ff shr $05)=$07
       ccF8FB=$6; // ($ff shr $06)=$03
       ccFCFD=$7; // ($ff shr $07)=$01
       ccFEFF=$8; // ($ff shr $08)=$00
       tsBEGIN=0;
       tsERROR=1;
       tsSINGLETAIL=2;
       tsDOUBLETAIL=3;
       tsTRIPLETAIL=4;
       tsQUADTAIL=5;
       tsQUINTAIL=6;
{$endif}
       tsMUL=16;
  procedure AssignCharsetToCharClass(const Charset:TAnsiCharSet;const CharClass:TFLREUInt8);
  var c:TFLRERawByteChar;
  begin
   for c:=low(TFLRERawByteChar) to high(TFLRERawByteChar) do begin
    if c in Charset then begin
     UTF8DFACharClasses[c]:=CharClass;
    end;
   end;
  end;
  procedure AddTranslation(const FromState,AtCharClass,ToState:TFLREUInt8);
  begin
   UTF8DFATransitions[(FromState*tsMUL)+AtCharClass]:=ToState*tsMUL;
  end;
 var i:TFLREInt32;
 begin
  FillChar(UTF8DFACharClasses,sizeof(TUTF8Chars),#0);
  FillChar(UTF8DFATransitions,sizeof(TUTF8Bytes),#0);
  begin
{$ifdef FLREStrictUTF8}
   AssignCharsetToCharClass([#$00..#$7f],cc007F);
   AssignCharsetToCharClass([#$80..#$8f],cc808F);
   AssignCharsetToCharClass([#$90..#$9f],cc909F);
   AssignCharsetToCharClass([#$a0..#$bf],ccA0BF);
   AssignCharsetToCharClass([#$c0..#$c1],ccC0C1F5FF);
   AssignCharsetToCharClass([#$c2..#$df],ccC2DF);
   AssignCharsetToCharClass([#$e0],ccE0);
   AssignCharsetToCharClass([#$e1..#$ec,#$ee..#$ef],ccE1ECEEEF);
   AssignCharsetToCharClass([#$ed],ccED);
   AssignCharsetToCharClass([#$f0],ccF0);
   AssignCharsetToCharClass([#$f1..#$f3],ccF1F3);
   AssignCharsetToCharClass([#$f4],ccF4);
   AssignCharsetToCharClass([#$f5..#$ff],ccC0C1F5FF);
{$else}
   AssignCharsetToCharClass([#$00..#$7f],cc007F);
   AssignCharsetToCharClass([#$80..#$bf],cc80BF);
   AssignCharsetToCharClass([#$c0..#$df],ccC0DF);
   AssignCharsetToCharClass([#$e0..#$ef],ccE0EF);
   AssignCharsetToCharClass([#$f0..#$f7],ccF0F7);
   AssignCharsetToCharClass([#$f8..#$fb],ccF8FB);
   AssignCharsetToCharClass([#$fc..#$fd],ccFCFD);
   AssignCharsetToCharClass([#$fe..#$ff],ccFEFF);
{$endif}
  end;
  begin
   for i:=low(TUTF8Bytes) to high(TUTF8Bytes) do begin
    UTF8DFATransitions[i]:=tsERROR*tsMUL;
   end;
{$ifdef FLREStrictUTF8}
   begin
    AddTranslation(tsBEGIN,cc007F,tsBEGIN);
    AddTranslation(tsBEGIN,cc808F,tsERROR);
    AddTranslation(tsBEGIN,cc909F,tsERROR);
    AddTranslation(tsBEGIN,ccA0BF,tsERROR);
    AddTranslation(tsBEGIN,ccC2DF,tsSINGLETAIL);
    AddTranslation(tsBEGIN,ccE0,tsDOUBLETAILwithA0BFonly);
    AddTranslation(tsBEGIN,ccE1ECEEEF,tsDOUBLETAIL);
    AddTranslation(tsBEGIN,ccED,tsDOUBLETAILwith809FFonly);
    AddTranslation(tsBEGIN,ccF0,tsTRIPLETAILwith90BFonly);
    AddTranslation(tsBEGIN,ccF1F3,tsTRIPLETAIL);
    AddTranslation(tsBEGIN,ccF4,tsTRIPLETAILwith808Fonly);
    AddTranslation(tsBEGIN,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsERROR,cc007F,tsERROR);
    AddTranslation(tsERROR,cc808F,tsERROR);
    AddTranslation(tsERROR,cc909F,tsERROR);
    AddTranslation(tsERROR,ccA0BF,tsERROR);
    AddTranslation(tsERROR,ccC2DF,tsERROR);
    AddTranslation(tsERROR,ccE0,tsERROR);
    AddTranslation(tsERROR,ccE1ECEEEF,tsERROR);
    AddTranslation(tsERROR,ccED,tsERROR);
    AddTranslation(tsERROR,ccF0,tsERROR);
    AddTranslation(tsERROR,ccF1F3,tsERROR);
    AddTranslation(tsERROR,ccF4,tsERROR);
    AddTranslation(tsERROR,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsSINGLETAIL,cc007F,tsERROR);
    AddTranslation(tsSINGLETAIL,cc808F,tsBEGIN);
    AddTranslation(tsSINGLETAIL,cc909F,tsBEGIN);
    AddTranslation(tsSINGLETAIL,ccA0BF,tsBEGIN);
    AddTranslation(tsSINGLETAIL,ccC2DF,tsERROR);
    AddTranslation(tsSINGLETAIL,ccE0,tsERROR);
    AddTranslation(tsSINGLETAIL,ccE1ECEEEF,tsERROR);
    AddTranslation(tsSINGLETAIL,ccED,tsERROR);
    AddTranslation(tsSINGLETAIL,ccF0,tsERROR);
    AddTranslation(tsSINGLETAIL,ccF1F3,tsERROR);
    AddTranslation(tsSINGLETAIL,ccF4,tsERROR);
    AddTranslation(tsSINGLETAIL,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsDOUBLETAIL,cc007F,tsERROR);
    AddTranslation(tsDOUBLETAIL,cc808F,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAIL,cc909F,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAIL,ccA0BF,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAIL,ccC2DF,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccE0,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccE1ECEEEF,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccED,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccF0,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccF1F3,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccF4,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsDOUBLETAILwithA0BFonly,cc007F,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,cc808F,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,cc909F,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccA0BF,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccC2DF,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccE0,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccE1ECEEEF,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccED,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccF0,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccF1F3,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccF4,tsERROR);
    AddTranslation(tsDOUBLETAILwithA0BFonly,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsDOUBLETAILwith809FFonly,cc007F,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,cc808F,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAILwith809FFonly,cc909F,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccA0BF,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccC2DF,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccE0,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccE1ECEEEF,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccED,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccF0,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccF1F3,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccF4,tsERROR);
    AddTranslation(tsDOUBLETAILwith809FFonly,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsTRIPLETAILwith90BFonly,cc007F,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,cc808F,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,cc909F,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccA0BF,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccC2DF,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccE0,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccE1ECEEEF,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccED,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccF0,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccF1F3,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccF4,tsERROR);
    AddTranslation(tsTRIPLETAILwith90BFonly,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsTRIPLETAIL,cc007F,tsERROR);
    AddTranslation(tsTRIPLETAIL,cc808F,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAIL,cc909F,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAIL,ccA0BF,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAIL,ccC2DF,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccE0,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccE1ECEEEF,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccED,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccF0,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccF1F3,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccF4,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccC0C1F5FF,tsERROR);
   end;
   begin
    AddTranslation(tsTRIPLETAILwith808Fonly,cc007F,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,cc808F,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAILwith808Fonly,cc909F,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccA0BF,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccC2DF,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccE0,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccE1ECEEEF,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccED,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccF0,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccF1F3,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccF4,tsERROR);
    AddTranslation(tsTRIPLETAILwith808Fonly,ccC0C1F5FF,tsERROR);
   end;
  end;
{$else}
   begin
    AddTranslation(tsBEGIN,cc007F,tsBEGIN);
    AddTranslation(tsBEGIN,cc80BF,tsERROR);
    AddTranslation(tsBEGIN,ccC0DF,tsSINGLETAIL);
    AddTranslation(tsBEGIN,ccE0EF,tsDOUBLETAIL);
    AddTranslation(tsBEGIN,ccF0F7,tsTRIPLETAIL);
    AddTranslation(tsBEGIN,ccF8FB,tsQUADTAIL);
    AddTranslation(tsBEGIN,ccFCFD,tsQUINTAIL);
    AddTranslation(tsBEGIN,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsERROR,cc007F,tsERROR);
    AddTranslation(tsERROR,cc80BF,tsERROR);
    AddTranslation(tsERROR,ccC0DF,tsERROR);
    AddTranslation(tsERROR,ccE0EF,tsERROR);
    AddTranslation(tsERROR,ccF0F7,tsERROR);
    AddTranslation(tsERROR,ccF8FB,tsERROR);
    AddTranslation(tsERROR,ccFCFD,tsERROR);
    AddTranslation(tsERROR,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsSINGLETAIL,cc007F,tsERROR);
    AddTranslation(tsSINGLETAIL,cc80BF,tsBEGIN);
    AddTranslation(tsSINGLETAIL,ccC0DF,tsERROR);
    AddTranslation(tsSINGLETAIL,ccE0EF,tsERROR);
    AddTranslation(tsSINGLETAIL,ccF0F7,tsERROR);
    AddTranslation(tsSINGLETAIL,ccF8FB,tsERROR);
    AddTranslation(tsSINGLETAIL,ccFCFD,tsERROR);
    AddTranslation(tsSINGLETAIL,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsDOUBLETAIL,cc007F,tsERROR);
    AddTranslation(tsDOUBLETAIL,cc80BF,tsSINGLETAIL);
    AddTranslation(tsDOUBLETAIL,ccC0DF,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccE0EF,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccF0F7,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccF8FB,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccFCFD,tsERROR);
    AddTranslation(tsDOUBLETAIL,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsTRIPLETAIL,cc007F,tsERROR);
    AddTranslation(tsTRIPLETAIL,cc80BF,tsDOUBLETAIL);
    AddTranslation(tsTRIPLETAIL,ccC0DF,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccE0EF,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccF0F7,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccF8FB,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccFCFD,tsERROR);
    AddTranslation(tsTRIPLETAIL,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsQUADTAIL,cc007F,tsERROR);
    AddTranslation(tsQUADTAIL,cc80BF,tsTRIPLETAIL);
    AddTranslation(tsQUADTAIL,ccC0DF,tsERROR);
    AddTranslation(tsQUADTAIL,ccE0EF,tsERROR);
    AddTranslation(tsQUADTAIL,ccF0F7,tsERROR);
    AddTranslation(tsQUADTAIL,ccF8FB,tsERROR);
    AddTranslation(tsQUADTAIL,ccFCFD,tsERROR);
    AddTranslation(tsQUADTAIL,ccFEFF,tsERROR);
   end;
   begin
    AddTranslation(tsQUINTAIL,cc007F,tsERROR);
    AddTranslation(tsQUINTAIL,cc80BF,tsQUADTAIL);
    AddTranslation(tsQUINTAIL,ccC0DF,tsERROR);
    AddTranslation(tsQUINTAIL,ccE0EF,tsERROR);
    AddTranslation(tsQUINTAIL,ccF0F7,tsERROR);
    AddTranslation(tsQUINTAIL,ccF8FB,tsERROR);
    AddTranslation(tsQUINTAIL,ccFCFD,tsERROR);
    AddTranslation(tsQUINTAIL,ccFEFF,tsERROR);
   end;
  end;
{$endif}
{$ifdef FLRERuntimeUTF8DFATableGenerationDump}
  for i:=0 to 255 do begin
   write(UTF8DFACharClasses[TFLRERawByteChar(TFLREUInt8(i))],',');
  end;
  writeln;
  for i:=0 to 255 do begin
   write(UTF8DFATransitions[i],',');
  end;
  writeln;
  readln;
{$endif}
 end;
{$endif}
begin
 if (not FLREInitialized) and (length(FLRESignature)>0) then begin
  FLREInitialized:=true;
{$ifdef FLRERuntimeUTF8DFATableGeneration}
  InitializeUTF8DFA;
{$endif}
{$ifdef HasJIT}
{$ifdef unix}
{$ifdef darwin}
  fpmprotect:=dlsym(dlopen('libc.dylib',RTLD_NOW),'mprotect');
{$else}
  fpmprotect:=dlsym(dlopen('libc.so',RTLD_NOW),'mprotect');
{$endif}
  if not assigned(fpmprotect) then begin
   raise Exception.Create('Importing of mprotect from libc.so failed!');
  end;
{$endif}
{$endif}
  NativeCodeMemoryManager:=TFLRENativeCodeMemoryManager.Create;
 end;
end;

procedure FinalizeFLRE;
//var i:TFLREInt32;
begin
 if FLREInitialized then begin
  FreeAndNil(NativeCodeMemoryManager);
  FLREInitialized:=false;
 end;
end;

initialization
 InitializeFLRE;
finalization
 FinalizeFLRE;
end.


