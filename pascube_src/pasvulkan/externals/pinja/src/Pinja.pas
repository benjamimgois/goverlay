(******************************************************************************
 *                                   Pinja                                    *
 ******************************************************************************
 *                        Version 2025-10-26-16-26-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2025-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
      http://github.com/BeRo1985/palm                                         *
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

(******************************************************************************
  Pinja - A subset of Jinja2/3 template engine for Object Pascal
  
  Features:
  - Expression evaluation with filters and built-in functions
  - Control flow (if/elif/else, for loops with optional filters)
  - Variable assignment (set statements and set blocks)
  - Macros with positional and keyword arguments
  - Filter blocks for applying multiple filters to content
  - Comprehensive built-in filters and functions
  - Proper escaping for safe output
  - Compatible with LLM chat template formats
  
******************************************************************************)
unit Pinja;
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
                       
interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,Contnrs,StrUtils,Math,Generics.Collections,PasJSON;

type TPinjaInt8={$if declared(Int8)}Int8{$else}ShortInt{$ifend};
     PPinjaInt8=^TPinjaInt8;
     PPPinjaInt8=^PPinjaInt8;

     TPinjaInt16={$if declared(Int16)}Int16{$else}SmallInt{$ifend};
     PPinjaInt16=^TPinjaInt16;
     PPPinjaInt16=^PPinjaInt16;

     TPinjaInt32={$if declared(Int32)}Int32{$else}LongInt{$ifend};
     PPinjaInt32=^TPinjaInt32;
     PPPinjaInt32=^PPinjaInt32;

     TPinjaInt64={$if declared(Int64)}Int64{$else}Int64{$ifend};
     PPinjaInt64=^TPinjaInt64;
     PPPinjaInt64=^PPinjaInt64;

     TPinjaUInt8={$if declared(UInt8)}UInt8{$else}Byte{$ifend};
     PPinjaUInt8=^TPinjaUInt8;
     PPPinjaUInt8=^PPinjaUInt8;

     TPinjaUInt16={$if declared(UInt16)}UInt16{$else}Word{$ifend};
     PPinjaUInt16=^TPinjaUInt16;
     PPPinjaUInt16=^PPinjaUInt16;

     TPinjaUInt32={$if declared(UInt32)}UInt32{$else}LongWord{$ifend};
     PPinjaUInt32=^TPinjaUInt32;
     PPPinjaUInt32=^PPinjaUInt32;

     TPinjaUInt64={$if declared(UInt64)}UInt64{$else}Int64{$ifend};
     PPinjaUInt64=^TPinjaUInt64;
     PPPinjaUInt64=^PPinjaUInt64;

     TPinjaDouble={$if declared(Double)}Double{$else}Extended{$ifend};
     PPinjaDouble=^TPinjaDouble;
     PPPinjaDouble=^PPinjaDouble;

     TPinjaRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};
     PPinjaRawByteString=^TPinjaRawByteString;
     PPPinjaRawByteString=^PPinjaRawByteString;

     TPinjaObjectList=Contnrs.TObjectList; // workaround for fpc <=3.2.2 (3.3.1 has fixed it)

     TPinja=class
      public

        //==========================================================================
        // Output sink                                                              
        //==========================================================================
       type // TRawByteStringOutput 
            TRawByteStringOutput=class
             private
              fBuffer:TPinjaRawByteString;
             public
              procedure Clear; virtual;
              procedure AddString(const aString:TPinjaRawByteString); virtual;
              procedure AddChar(aCharacter:AnsiChar); virtual;
              function AsString:TPinjaRawByteString; virtual;
            end;

            TContext=class;

            ICallableObject=interface(IInterface)
             function GetObject:TObject;
            end;

            //==========================================================================
            // Values                                                                   
            //==========================================================================
            TValueKind=(vkNull,vkBool,vkInt,vkFloat,vkString,vkArray,vkObject,vkCallerObject);

            PValue=^TValue;
            TValue=record
             public

              // Reference-counted array object, as used by vkArray/vkObject for instance-wise behavior, but
              // without manual memory management that would be required for a "pure" object.  
              type TArrayObject=class;

                   IArrayObject=interface(IInterface)
                    function GetArrayObject:TArrayObject;
                    procedure Clear;
                    procedure Append(const aValue:TValue);
                    procedure ObjSet(const aName:TPinjaRawByteString;const aValue:TValue);
                    function ObjTryGet(const aName:TPinjaRawByteString;out aValue:TValue):Boolean;
                    function Count:TPinjaInt32;
                    function NameAt(aIndex:TPinjaInt32):TPinjaRawByteString;         
                    function ValueAt(aIndex:TPinjaInt32;out aValue:TValue):Boolean;
                   end;

                   TArrayObject=class(TInterfacedObject,IArrayObject)
                    private
                     fKind:TValueKind;
                     fCount:TPinjaInt32;                    // used for vkArray and vkObject
                     fKeys:array of TPinjaRawByteString;    // only used for vkObject (length = fCount)
                     fValues:array of TValue;               // used for vkArray (no keys) and vkObject (values)
                    public
                     constructor Create(const aKind:TValueKind);
                     destructor Destroy; override;
                     function GetArrayObject:TArrayObject;
                     procedure Clear;
                     procedure Append(const aValue:TValue);
                     procedure ObjSet(const aName:TPinjaRawByteString;const aValue:TValue);
                     function ObjTryGet(const aName:TPinjaRawByteString;out aValue:TValue):Boolean;
                     function Count:TPinjaInt32;
                     function NameAt(aIndex:TPinjaInt32):TPinjaRawByteString;         
                     function ValueAt(aIndex:TPinjaInt32;out aValue:TValue):Boolean; 
                   end;

             private
              fKind:TValueKind;
              fBooleanValue:Boolean;
              fIntegerValue:TPinjaInt64;
              fFloatValue:TPinjaDouble;
              fStringValue:TPinjaRawByteString;
              fArrayObject:IArrayObject;
              fCallableObject:ICallableObject;
             public

              // Factories
              class function Null:TValue; static;
              class function From(const aString:TPinjaRawByteString):TValue; overload; static;
              class function From(aInteger:TPinjaInt64):TValue; overload; static;
              class function From(aFloat:TPinjaDouble):TValue; overload; static;
              class function From(aBoolean:Boolean):TValue; overload; static;
              class function From(const aJSONItem:TPasJSONItem):TValue; overload; static;
              class function FromCallableObject(aCallableObject:ICallableObject):TValue; static;
              class function NewArray:TValue; static;
              class function NewObject:TValue; static;

              // Container helpers
              procedure Clear;
              procedure Append(const aValue:TValue);                                          // vkArray
              procedure ObjSet(const aName:TPinjaRawByteString;const aValue:TValue);          // vkObject
              function ObjTryGet(const aName:TPinjaRawByteString;out aValue:TValue):Boolean;  // vkObject
              function Count:TPinjaInt32;
              function NameAt(aIndex:TPinjaInt32):TPinjaRawByteString;                        // vkObject
              function ValueAt(aIndex:TPinjaInt32):TValue;                                    // vkArray/vkObject

              // Comparison helpers
              class function TryAsNumber(const aValue:TValue;out aFloatResult:TPinjaDouble):Boolean; static;
              class function Numbers(const aLeft,aRight:TValue;out aLeftFloat,aRightFloat:TPinjaDouble):Boolean; static;
              class function ArraysEqual(const aLeftArray,aRightArray:TValue):Boolean; static;
              class function ObjectsEqual(const aLeftObject,aRightObject:TValue):Boolean; static;

              // Accessors
              property Kind:TValueKind read fKind;
              function IsTruthy:Boolean;
              function AsString:TPinjaRawByteString;
              function AsFloat:TPinjaDouble;
              function AsInt64:TPinjaInt64;
              function ToJSON:TPasJSONItem;
              function ToJSONString:TPinjaRawByteString;
              function Clone:TValue;
              function CallAsCallable(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue;

              // Operators 
              class operator Implicit(const aString:TPinjaRawByteString):TValue;
              class operator Implicit(aInteger:TPinjaInt64):TValue;
              class operator Implicit(aFloat:TPinjaDouble):TValue;
              class operator Implicit(aBoolean:Boolean):TValue;

              class operator Add(const aLeft,aRight:TValue):TValue;
              class operator Subtract(const aLeft,aRight:TValue):TValue;
              class operator Equal(const aLeft,aRight:TValue):Boolean;
              class operator NotEqual(const aLeft,aRight:TValue):Boolean;
              class operator GreaterThan(const aLeft,aRight:TValue):Boolean;
              class operator LessThan(const aLeft,aRight:TValue):Boolean;
              class operator GreaterThanOrEqual(const aLeft,aRight:TValue):Boolean;
              class operator LessThanOrEqual(const aLeft,aRight:TValue):Boolean;
              class operator LogicalAnd(const aLeft,aRight:TValue):TValue;
              class operator LogicalOr(const aLeft,aRight:TValue):TValue;
              class operator LogicalNot(const aValue:TValue):TValue;
              class operator Multiply(const aLeft,aRight:TValue):TValue;
            end;

            // Unified callable signature
            TCallable=function(const aSelf:TValue;const aPos:array of TValue;var aKw:TPinja.TValue;const aContext:TContext):TValue;

            { TCallableObject }

            TCallableObject=class(TInterfacedObject,ICallableObject)
             private
              fCallable:TCallable;
             public
              constructor Create; virtual;
              function GetObject:TObject;
              function Call(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue; virtual;
            end;

            //==========================================================================
            // Context,Callables,Filters & Macros                                      
            //==========================================================================
            TOption=
             (
              TrimBlocks,
              LStripBlocks,
              KeepTrailingNewline
             );
            TOptions=set of TOption;

            TJoinerCallable=class(TCallableObject)
             private
              fSeparator:TPinjaRawByteString;
              fFirstCall:Boolean;
             public
              constructor Create(const aSeparator:TPinjaRawByteString);
              function Call(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue; override;
            end;

            // Legacy filter kept for compatibility; internally we call through TCallable
            TFilter=function(const aInput:TValue;const aArgs:array of TValue;const aContext:TContext):TValue;

            // Forward decl for macro def node 
            TNodeStatementMacroDefinition=class;

            TCallableList=TList<TCallable>;

            TFilterList=TList<TFilter>;

            TContext=class
             private

              fScopes:array of PValue;  // stack of heap-allocated TValue objects (vkObject)
              fCountScopes:TPinjaInt32;

              // Variable registry
              fCallNames:TStringList;
              fCallPtrs:TCallableList;

              // Filter registry 
              fFilterNames:TStringList;
              fFilterPtrs:TFilterList;

              // Macro registry 
              fMacroNames:TStringList;
              fMacroObjs:TList;
              fLastCallName:TPinjaRawByteString;

              fRaiseExceptionAtUnknownCallables:Boolean;

              function Top:PValue;      // returns last element pointer,raises if empty
              function FindFilterIndex(const aName:TPinjaRawByteString):TPinjaInt32;
              function FindCallableIndex(const aName:TPinjaRawByteString):TPinjaInt32;
              function FindMacroIndex(const aName:TPinjaRawByteString):TPinjaInt32;

              procedure RegisterDefaultFilters;
              procedure RegisterDefaultCallables;

             public

              constructor Create;
              destructor Destroy; override;

              procedure PushScope;
              procedure PopScope;
              procedure Clear;

              procedure SetVariable(const aName:TPinjaRawByteString;const aValue:TValue);
              function TryGetVariable(const aName:TPinjaRawByteString;out aValue:TValue):Boolean;

              procedure RegisterFilter(const aName:TPinjaRawByteString;aFilter:TFilter);
              function TryGetFilter(const aName:TPinjaRawByteString;out aFilter:TFilter):Boolean;

              procedure RegisterCallable(const aName:TPinjaRawByteString;aCallable:TCallable);
              function TryGetCallable(const aName:TPinjaRawByteString;out aCallable:TCallable):Boolean;

              procedure RegisterMacro(const aName:TPinjaRawByteString;aMacro:TNodeStatementMacroDefinition);
              function TryGetMacro(const aName:TPinjaRawByteString;out aMacro:TNodeStatementMacroDefinition):Boolean;

              property LastCallName:TPinjaRawByteString read fLastCallName;

              property RaiseExceptionAtUnknownCallables:Boolean read fRaiseExceptionAtUnknownCallables write fRaiseExceptionAtUnknownCallables;

            end;

            //==========================================================================
            // Lexer                                                                     
            //==========================================================================
            TLexer=class
             public
              type TTokenKind=
                    (
                     tkEOF,tkIdent,tkNumber,tkString,
                     tkLParen,tkRParen,tkLBracket,tkRBracket,tkLBrace,tkRBrace,
                     tkComma,tkColon,tkDot,tkPipe,
                     tkPlus,tkMinus,tkStar,tkSlash,tkFloorDiv,tkPercent,tkPow,tkTilde,
                     tkAmp,tkCaret,tkShl,tkShr,tkBor,
                     tkAssign,tkEq,tkNe,tkLt,tkLe,tkGt,tkGe,
                     tkIn,tkNotIn,tkIs,tkIsNot,tkAnd,tkOr,tkNot,tkIf,tkElse
                    );
             private
              fSource:TPinjaRawByteString;
              fPosition:TPinjaInt32;
              fLength:TPinjaInt32;
              fToken:TPinjaRawByteString;
              fKind:TTokenKind;
             public
              constructor Create(const aString:TPinjaRawByteString);
              function Peek:AnsiChar;
              function NextChar:AnsiChar;
              function EOF:Boolean;
              procedure Next; // tokenize next token 
              property Token:TPinjaRawByteString read fToken;
              property Kind:TTokenKind read fKind;

              // helpers (kept inside the class) 
              class function IsIdentStart(aCharacter:AnsiChar):Boolean; static;
              class function IsIdentChar(aCharacter:AnsiChar):Boolean; static;
              function ParseIdentifier:TPinjaRawByteString;
              function ParseStringLiteral:TPinjaRawByteString;
              function ParseNumber(out aIsFloat:Boolean;out aInteger:TPinjaInt64;out aFloat:TPinjaDouble):Boolean;

              function NextIsAssign:Boolean; // lookahead without consuming 
            end;

            //==========================================================================
            // AST — Expressions (typed ops)                                            
            //==========================================================================
            TUnaryOp=(uoNot,uoPos,uoNeg,uoBitNot);
            TCompareOp=(coEq,coNe,coLt,coLe,coGt,coGe,coIn,coNotIn);
            TLogicalOp=(loAnd,loOr);
            TAddOp=(aoPlus,aoMinus);
            TArithOp=(arMul,arDiv,arFloorDiv,arMod);
            TPowerOp=(poPow);
            TShiftOp=(soShl,soShr);
            TBitAndOp=(baAnd);
            TBitXorOp=(bxXor);
            TBitOrOp=(boOr);

            TNodeExpression=class
             public
              function Eval(const aContext:TContext):TValue; virtual; abstract;
            end;

            TNodeExpressions=class
             private
              fItems:array of TNodeExpression;
              fCount:TPinjaInt32;
             public
              constructor Create;
              destructor Destroy; override;
              procedure Add(aExpression:TNodeExpression);
              function Get(aIndex:TPinjaInt32):TNodeExpression;
              procedure Clear;
              property Count:TPinjaInt32 read fCount;
              property Items[aIndex:TPinjaInt32]:TNodeExpression read Get; default;
            end;

            TNodeExpressionValue=class(TNodeExpression)
             private
              fValue:TValue;
             public
              constructor Create(const aValue:TValue);
              function Eval(const aContext:TContext):TValue; override;
             public
              property Value:TValue read fValue;
            end;

            TNodeExpressionVariable=class(TNodeExpression)
             private
              fName:TPinjaRawByteString;
             public
              constructor Create(const aName:TPinjaRawByteString);
              function Eval(const aContext:TContext):TValue; override;
             published
              property Name:TPinjaRawByteString read fName;
            end;

            TNodeExpressionAttribute=class(TNodeExpression)
             private
              fBase:TNodeExpression;
              fName:TPinjaRawByteString;
             public
              constructor Create(aBase:TNodeExpression;const aName:TPinjaRawByteString);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Base:TNodeExpression read fBase;
              property Name:TPinjaRawByteString read fName;
            end;

            TNodeExpressionArgumentList=class
             private
              fPos:TPinjaObjectList;   // of TNodeExpression
              fKwNames:TStringList;
              fKwVals:TPinjaObjectList; // of TNodeExpression
             public
              constructor Create;
              destructor Destroy; override;
             published
              property Pos:TPinjaObjectList read fPos;
              property KwNames:TStringList read fKwNames;
              property KwVals:TPinjaObjectList read fKwVals;
            end;

            TNodeExpressionCallName=class(TNodeExpression)
             private
              fSelfExpression:TNodeExpression;     // may be nil
              fName:TPinjaRawByteString;
              fArguments:TNodeExpressionArgumentList;
             public
              constructor Create(aSelf:TNodeExpression;const aName:TPinjaRawByteString;aArguments:TNodeExpressionArgumentList);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property SelfExpression:TNodeExpression read fSelfExpression;
              property Name:TPinjaRawByteString read fName;
              property Arguments:TNodeExpressionArgumentList read fArguments;
            end;

            TNodeExpressionCall=class(TNodeExpression)
             private
              fTargetExpression:TNodeExpression;
              fArguments:TNodeExpressionArgumentList;
             public
              constructor Create(aTarget:TNodeExpression;aArguments:TNodeExpressionArgumentList);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property TargetExpression:TNodeExpression read fTargetExpression;
              property Arguments:TNodeExpressionArgumentList read fArguments;
            end;

            TNodeExpressionFilterPipe=class(TNodeExpression)
             private
              fBase:TNodeExpression;
              fNames:TStringList;
              fArgSets:TPinjaObjectList; // of TNodeExpressionArgumentList
             public
              constructor Create(aBase:TNodeExpression);
              destructor Destroy; override;
              procedure AddFilter(const aName:TPinjaRawByteString;aArgs:TNodeExpressionArgumentList);
              function Eval(const aContext:TContext):TValue; override;
             published
              property Base:TNodeExpression read fBase;
              property Names:TStringList read fNames;
              property ArgSets:TPinjaObjectList read fArgSets;
            end;

            TNodeExpressionUnary=class(TNodeExpression)
             private
              fOp:TUnaryOp;
              fA:TNodeExpression;
             public
              constructor Create(aOperator:TUnaryOp;aExpression:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TUnaryOp read fOp;
              property A:TNodeExpression read fA;
            end;

            TNodeExpressionPower=class(TNodeExpression)
             private
              fOp:TPowerOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TPowerOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TPowerOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;
            end;

            TNodeExpressionCompare=class(TNodeExpression)
             private
              fOp:TCompareOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TCompareOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TCompareOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;
            end;

            TNodeExpressionIs=class(TNodeExpression)
             private
              fNegate:Boolean;
              fTestName:TPinjaRawByteString;
              fLeftExpression:TNodeExpression;
              fTestParameters:TNodeExpressions;
             public
              constructor Create(aNegate:Boolean;const aTestName:TPinjaRawByteString;aLeftExpression:TNodeExpression;aTestParameters:TNodeExpressions=nil);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Negate:Boolean read fNegate;
              property TestName:TPinjaRawByteString read fTestName;
              property LeftExpression:TNodeExpression read fLeftExpression;
              property TestParameters:TNodeExpressions read fTestParameters;
            end;

            TNodeExpressionLogical=class(TNodeExpression)
             private
              fOp:TLogicalOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TLogicalOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TLogicalOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;          
            end;

            TNodeExpressionAdd=class(TNodeExpression)
             private
              fOp:TAddOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TAddOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TAddOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;          
            end;

            TNodeExpressionMulDivMod=class(TNodeExpression)
             private
              fOp:TArithOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TArithOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TArithOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;          
            end;

            TNodeExpressionShift=class(TNodeExpression)
             private
              fOp:TShiftOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TShiftOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TShiftOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;          
            end;

            TNodeExpressionBitAnd=class(TNodeExpression)
             private
              fOp:TBitAndOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TBitAndOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TBitAndOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;           
            end;

            TNodeExpressionBitXor=class(TNodeExpression)
             private
              fOp:TBitXorOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TBitXorOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TBitXorOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;           
            end;

            TNodeExpressionBitOr=class(TNodeExpression)
             private
              fOp:TBitOrOp;
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aOperator:TBitOrOp;aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Op:TBitOrOp read fOp;
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;       
            end;

            TNodeExpressionConcat=class(TNodeExpression)
             private
              fLhs:TNodeExpression;
              fRhs:TNodeExpression;
             public
              constructor Create(aLeft,aRight:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Lhs:TNodeExpression read fLhs;
              property Rhs:TNodeExpression read fRhs;         
            end;

            TNodeExpressionIndex=class(TNodeExpression)
             private
              fBase:TNodeExpression;
              fIndex:TNodeExpression;
             public
              constructor Create(aBase,aIndex:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Base:TNodeExpression read fBase;
              property Index:TNodeExpression read fIndex;         
            end;

            TNodeExpressionSlice=class(TNodeExpression)
             private
              fBase:TNodeExpression;
              fStart:TNodeExpression;
              fStop:TNodeExpression;
              fStep:TNodeExpression; // nils allowed
             public
              constructor Create(aBase,aStart,aStop,aStep:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Base:TNodeExpression read fBase;
              property Start:TNodeExpression read fStart;
              property Stop:TNodeExpression read fStop;
              property Step:TNodeExpression read fStep;           
            end;

            TNodeExpressionArrayLit=class(TNodeExpression)
             private
              fItems:TPinjaObjectList; // of TNodeExpression
             public
              constructor Create;
              destructor Destroy; override;
              procedure Add(aExpression:TNodeExpression);
              function Eval(const aContext:TContext):TValue; override;
             published
              property Items:TPinjaObjectList read fItems;
            end;

            TNodeExpressionDictLit=class(TNodeExpression)
             private
              fKeys:TPinjaObjectList;  // of TNodeExpression
              fVals:TPinjaObjectList;  // of TNodeExpression
             public
              constructor Create;
              destructor Destroy; override;
              procedure Add(aKey,aVal:TNodeExpression);
              function Eval(const aContext:TContext):TValue; override;
             published
              property Keys:TPinjaObjectList read fKeys;
              property Vals:TPinjaObjectList read fVals;
            end;

            TNodeExpressionTernary=class(TNodeExpression)
             private
              fThen:TNodeExpression;
              fCondition:TNodeExpression;
              fElse:TNodeExpression;
             public
              constructor Create(aThenE,aCondE,aElseE:TNodeExpression);
              destructor Destroy; override;
              function Eval(const aContext:TContext):TValue; override;
             published
              property Then_:TNodeExpression read fThen;
              property Condition:TNodeExpression read fCondition;
              property Else_:TNodeExpression read fElse;            
            end;

            //==========================================================================
            // AST — Statements                                                          
            //==========================================================================

            // Flow-control signals for break/continue 
            EBreakSignal=class(Exception);
            EContinueSignal=class(Exception);

            TNodeStatement=class
             public
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); virtual; // abstract;
            end;

            TNodeStatementText=class(TNodeStatement)
             private
              fText:TPinjaRawByteString;
             public
              constructor Create(const aString:TPinjaRawByteString);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Text:TPinjaRawByteString read fText;          
            end;

            TNodeStatementExpression=class(TNodeStatement)
             private
              fExpression:TNodeExpression;
             public
              constructor Create(aExpression:TNodeExpression);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Expression:TNodeExpression read fExpression;          
            end;

            TNodeStatementBlock=class(TNodeStatement)
             private
              fItems:TPinjaObjectList; // of TNodeStatement
             public
              constructor Create;
              destructor Destroy; override;
              procedure Add(aNode:TNodeStatement);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Items:TPinjaObjectList read fItems;
            end;

            TNodeStatementSet=class(TNodeStatement)
             private
              fName:TPinjaRawByteString;
              fExpression:TNodeExpression;
             public
              constructor Create(const aAName:TPinjaRawByteString;aExpression:TNodeExpression);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Name:TPinjaRawByteString read fName;
              property Expression:TNodeExpression read fExpression;           
            end;

            // {% set name %}...{% endset %}
            TNodeStatementSetBlock=class(TNodeStatement)
             private
              fName:TPinjaRawByteString;
              fBody:TNodeStatementBlock;
             public
              constructor Create(const aName:TPinjaRawByteString;aBody:TNodeStatementBlock);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Name:TPinjaRawByteString read fName;
              property Body:TNodeStatementBlock read fBody; 
            end;

            TNodeStatementIf=class(TNodeStatement)
             private
              fConditions:TPinjaObjectList; // of TNodeExpression
              fBodies:TPinjaObjectList; // of TNodeStatementBlock
              fElseBody:TNodeStatementBlock;
             public
              constructor Create;
              destructor Destroy; override;
              procedure AddBranch(aCond:TNodeExpression;aBody:TNodeStatementBlock);
              procedure SetElse(aBody:TNodeStatementBlock);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Conditions:TPinjaObjectList read fConditions;
              property Bodies:TPinjaObjectList read fBodies;
              property ElseBody:TNodeStatementBlock read fElseBody;
            end;

            TNodeStatementBreak=class(TNodeStatement)
             public
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
            end;

            TNodeStatementContinue=class(TNodeStatement)
             public
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
            end;

            TNodeStatementFor=class(TNodeStatement)
             private
              fKeyName:TPinjaRawByteString;
              fValueName:TPinjaRawByteString;
              fIterable:TNodeExpression;
              fBody:TNodeStatementBlock;
              fFilterCondition:TNodeExpression; // optional for "for ... if <expr>"
             public
              constructor Create(const aKey,aVal:TPinjaRawByteString;aExpression:TNodeExpression;aFilter:TNodeExpression;aBlock:TNodeStatementBlock);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property KeyName:TPinjaRawByteString read fKeyName;
              property ValueName:TPinjaRawByteString read fValueName;
              property Iterable:TNodeExpression read fIterable;
              property Body:TNodeStatementBlock read fBody;
              property FilterCondition:TNodeExpression read fFilterCondition;
            end;

            // {% filter chain %}...{% endfilter %}
            TNodeStatementFilterBlock=class(TNodeStatement)
             private
              fNames:TStringList;
              fArgSets:TPinjaObjectList; // of TNodeExpressionArgumentList
              fBody:TNodeStatementBlock;
             public
              constructor Create(aBody:TNodeStatementBlock);
              destructor Destroy; override;
              procedure AddFilter(const aName:TPinjaRawByteString;aArgs:TNodeExpressionArgumentList);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Names:TStringList read fNames;
              property ArgSets:TPinjaObjectList read fArgSets;
              property Body:TNodeStatementBlock read fBody;
            end;

            // {% macro name(params) %}...{% endmacro %}
            TNodeStatementMacroDefinition=class(TNodeStatement)
             private
              fName:TPinjaRawByteString;
              fPosNames:TStringList;   // ordered positional names
              fKwNames:TStringList;    // kw-only names (order preserved)
              fKwDefs:TPinjaObjectList;     // of TNodeExpression default expressions
              fBody:TNodeStatementBlock;
             public
              constructor Create(const aName:TPinjaRawByteString;aBody:TNodeStatementBlock);
              destructor Destroy; override;
              procedure AddPosName(const aName:TPinjaRawByteString);
              procedure AddKwDefault(const aName:TPinjaRawByteString;aExpression:TNodeExpression);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
              function Invoke(const aPos:array of TValue;var aKw:TPinja.TValue;const aContext:TContext):TValue;
             published
              property Name:TPinjaRawByteString read fName;
              property PosNames:TStringList read fPosNames;
              property KwNames:TStringList read fKwNames;
              property KwDefs:TPinjaObjectList read fKwDefs;
              property Body:TNodeStatementBlock read fBody;
            end;

            // {% call macro_name(args) %}...{% endcall %} or {% call(params) macro_name(args) %}...{% endcall %}
            TNodeStatementCall=class(TNodeStatement)
             private
              fMacroName:TPinjaRawByteString;
              fArguments:TNodeExpressionArgumentList;
              fBody:TNodeStatementBlock;
              fCallParameters:TStringList; // Parameters for the call block (e.g., "user" in {% call(user) %})
             public
              constructor Create(const aMacroName:TPinjaRawByteString;aArguments:TNodeExpressionArgumentList;aBody:TNodeStatementBlock);
              destructor Destroy; override;
              procedure AddCallParameter(const aParameterName:TPinjaRawByteString);
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property MacroName:TPinjaRawByteString read fMacroName;
              property Arguments:TNodeExpressionArgumentList read fArguments;
              property Body:TNodeStatementBlock read fBody;
              property CallParameters:TStringList read fCallParameters;
            end;

            // Helper class to make caller callable with arguments
            TNodeStatementCallCaller=class(TCallableObject)
             private
              fBody:TNodeStatementBlock;
              fParameters:TStringList;
             public
              constructor Create(aBody:TNodeStatementBlock;aParameters:TStringList);
              destructor Destroy; override;
              function Call(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue; override;
             published
              property Body:TNodeStatementBlock read fBody;
              property Parameters:TStringList read fParameters;
            end;

            // {% generation %}...{% endgeneration %}
            TNodeStatementGeneration=class(TNodeStatement)
             private
              fBody:TNodeStatementBlock;
             public
              constructor Create(aBody:TNodeStatementBlock);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput); override;
             published
              property Body:TNodeStatementBlock read fBody;
            end;

            //==========================================================================
            // Parser
            //==========================================================================
            TParser=class
             private
              fLexer:TLexer;
              function ParsePrimary:TNodeExpression;
              function ParseArgs:TNodeExpressionArgumentList;
              function ParsePostfix(aBase:TNodeExpression):TNodeExpression;  // filters,dot,index/slice
              function ParsePower:TNodeExpression;   // right-assoc **
              function ParseUnary:TNodeExpression;   // not, +, -, ~ ; lower than **
              function ParseMul:TNodeExpression;     // * / // %
              function ParseAdd:TNodeExpression;     // + -
              function ParseConcat:TNodeExpression;  // binary ~
              function ParseShift:TNodeExpression;   // << >>
              function ParseBitAnd:TNodeExpression;  // &
              function ParseBitXor:TNodeExpression;  // ^
              function ParseBitOr:TNodeExpression;   // bor (keyword)
              function ParseComparison:TNodeExpression; // == != < <= > >= in not in is is not
              function ParseAnd:TNodeExpression;
              function ParseOr:TNodeExpression;
              function ParseTernary:TNodeExpression; // then if cond else else
            public
              constructor Create(const aString:TPinjaRawByteString);
              destructor Destroy; override;
              function ParseExpression:TNodeExpression;
            end;

            //==========================================================================
            // Template wrapper
            //==========================================================================
            TTemplate=class
             private
              fRoot:TNodeStatementBlock;
              fOptions:TOptions;
             public
              constructor Create(const aSource:TPinjaRawByteString;const aOptions:TOptions);
              destructor Destroy; override;
              procedure Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
              function RenderToString(const aContext:TContext):TPinjaRawByteString; // convenience
             published
              property Root:TNodeStatementBlock read fRoot;
            end;

      public
     end;

implementation

function ParseFloat(const aString:TPinjaRawByteString;out aFloat:TPinjaDouble):Boolean;
var ErrorCode:TPinjaInt32;
begin
 Val(aString,aFloat,ErrorCode); // Without the mess with localization
 result:=ErrorCode=0;
end;

function ConvertStringToFloat(const aString:TPinjaRawByteString):TPinjaDouble;
begin
 if not ParseFloat(aString,result) then begin
  result:=0.0;
 end;
end;

function ConvertFloatToString(const aFloat:TPinjaDouble):TPinjaRawByteString;
begin
 Str(aFloat,result);
end;

{ TPinja.TRawByteStringOutput }
procedure TPinja.TRawByteStringOutput.Clear;
begin
 fBuffer:='';
end;

procedure TPinja.TRawByteStringOutput.AddString(const aString:TPinjaRawByteString);
begin
 if length(aString)<>0 then begin
  fBuffer:=fBuffer+aString;
 end;
end;

procedure TPinja.TRawByteStringOutput.AddChar(aCharacter:AnsiChar);
begin
 fBuffer:=fBuffer+aCharacter;
end;

function TPinja.TRawByteStringOutput.AsString:TPinjaRawByteString;
begin
 result:=fBuffer;
end;

//==============================================================================
// Helpers                                                                       
//==============================================================================
function EscapeJSONString(const aSourceString:TPinjaRawByteString):TPinjaRawByteString;
const HexChars:array[0..15] of AnsiChar=('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var StringIndex:TPinjaInt32;
    CurrentChar:AnsiChar;
    ByteValue:TPinjaUInt8;
    CodePoint,CodePoint0,CodePoint1:UInt32;
begin
 result:='"';
 StringIndex:=1;
 while StringIndex<=Length(aSourceString) do begin
  CurrentChar:=aSourceString[StringIndex];
  inc(StringIndex);
  case CurrentChar of
   '"':begin
    result:=result+'\"';
   end;
   '\':begin
    result:=result+'\\';
   end;
   #8:begin
    result:=result+'\b';
   end;
   #9:begin
    result:=result+'\t';
   end;
   #10:begin
    result:=result+'\n';
   end;
   #12:begin
    result:=result+'\f';
   end;
   #13:begin
    result:=result+'\r';
   end;
   else begin
    ByteValue:=TPinjaUInt8(CurrentChar);
    case ByteValue of
     0..31:begin
      result:=result+'\u00'+HexChars[ByteValue shr 4]+HexChars[ByteValue and $0F];
     end;
     32..127:begin
      result:=result+CurrentChar;
     end;
     else begin
      // UTF8
      if (ByteValue and $80)=0 then begin
       // 1 byte
       CodePoint:=ByteValue;
      end else if (ByteValue and $e0)=0 then begin
       // 2 bytes
       CodePoint:=((ByteValue and $1f) shl 6) or (TPinjaUInt8(aSourceString[StringIndex]) and $3f);
       inc(StringIndex);
      end else if (ByteValue and $f0)=0 then begin
       // 3 bytes
       CodePoint:=((ByteValue and $0f) shl 12) or ((TPinjaUInt8(aSourceString[StringIndex]) and $3f) shl 6) or (TPinjaUInt8(aSourceString[StringIndex+1]) and $3f);
       inc(StringIndex,2);
      end else if (ByteValue and $f8)=0 then begin
       // 4 bytes
       CodePoint:=((ByteValue and $07) shl 18) or ((TPinjaUInt8(aSourceString[StringIndex]) and $3f) shl 12) or ((TPinjaUInt8(aSourceString[StringIndex+1]) and $3f) shl 6) or (TPinjaUInt8(aSourceString[StringIndex+2]) and $3f);
       inc(StringIndex,3);
      end else begin
       // invalid UTF8, just escape as hex
       CodePoint:=ByteValue;
      end;
      if CodePoint<$ffff then begin
       // Smaller than or equal two bytes, so just encode as UTF-16 directly
       result:=result+'\u'+HexChars[CodePoint shr 12]+HexChars[(CodePoint shr 8) and $0f]+HexChars[(CodePoint shr 4) and $0f]+HexChars[CodePoint and $0f];
      end else begin
       // Larger than two bytes, so split into two surrogate pairs
       CodePoint0:=$d800 or ((CodePoint-$10000) shr 10); // first surrogate
       CodePoint1:=$dc00 or ((CodePoint-$10000) and $3ff); // second surrogate
       result:=result+'\u'+HexChars[CodePoint0 shr 12]+HexChars[(CodePoint0 shr 8) and $0f]+HexChars[(CodePoint0 shr 4) and $0f]+HexChars[CodePoint0 and $0f];
       result:=result+'\u'+HexChars[CodePoint1 shr 12]+HexChars[(CodePoint1 shr 8) and $0f]+HexChars[(CodePoint1 shr 4) and $0f]+HexChars[CodePoint1 and $0f];
      end;
     end;
    end;
   end;
  end;
 end;
 result:=result+'"';
end;

function HTMLEscape(const aString:TPinjaRawByteString):TPinjaRawByteString;
var CharIndex:TPinjaInt32;
    CurrentChar:AnsiChar;
begin
 result:='';
 for CharIndex:=1 to Length(aString) do begin
  CurrentChar:=aString[CharIndex];
  case CurrentChar of
   '&':begin
    result:=result+'&amp;';
   end;
   '<':begin
    result:=result+'&lt;';
   end;
   '>':begin
    result:=result+'&gt;';
   end;
   '"' : begin
    result:=result+'&quot;';
   end;
   '''': begin
    result:=result+'&#39;';
   end;
   else begin
    result:=result+CurrentChar;
   end;
  end;
 end;
end;                                         

function ClampIndex(const aIdx,aLen:TPinjaInt32):TPinjaInt32;
begin
 result:=aIdx;
 if result<0 then begin
  inc(result,aLen);
 end;
 if result<0 then begin 
  result:=0;
 end else if result>aLen then begin
  result:=aLen;
 end;
end;

function FloatMod(const aX,aY:TPinjaDouble):TPinjaDouble;
var Quotient:TPinjaDouble;
begin
 if IsZero(aY) then begin
  result:=0.0;
 end else begin
  Quotient:=aX/aY;
  if Quotient>=0 then begin
   Quotient:=Floor(Quotient);
  end else begin
   Quotient:=Ceil(Quotient);
  end;
  result:=aX-(Quotient*aY);
 end; 
end;

//==============================================================================
// TValue                                                                        
//==============================================================================

{ TPinja.TValue.TArrayObject }

constructor TPinja.TValue.TArrayObject.Create(const aKind:TValueKind);
begin
 inherited Create;
 fKind:=aKind;
 fCount:=0;
 fValues:=nil;
 fKeys:=nil;
end;

destructor TPinja.TValue.TArrayObject.Destroy;
begin
 fValues:=nil;
 fKeys:=nil;
 inherited Destroy;
end;

function TPinja.TValue.TArrayObject.GetArrayObject:TArrayObject;
begin
 result:=self;
end;

procedure TPinja.TValue.TArrayObject.Clear;
begin
 fValues:=nil;
 fKeys:=nil;
 fCount:=0;
end;

procedure TPinja.TValue.TArrayObject.Append(const aValue:TPinja.TValue);
var Index:TPinjaInt32;
begin
 if fKind<>TPinja.TValueKind.vkArray then begin
  raise Exception.Create('Append on non-array');
 end;
 Index:=fCount;
 if length(fValues)<=Index then begin
  SetLength(fValues,Max(4,(Index+1)*2));
 end;
 fValues[Index]:=aValue;
 inc(fCount);
end;

procedure TPinja.TValue.TArrayObject.ObjSet(const aName:TPinjaRawByteString;const aValue:TPinja.TValue);
var Index:TPinjaInt32;
begin
 if fKind<>TPinja.TValueKind.vkObject then begin 
  raise Exception.Create('ObjSet on non-object');
 end; 
 // linear search; keep insertion order
 for Index:=0 to fCount-1 do begin
  if fKeys[Index]=aName then begin 
   fValues[Index]:=aValue; 
   exit; 
  end;
 end;
 // append
 Index:=fCount;
 if length(fValues)<=Index then begin
  SetLength(fValues,Max(4,(Index+1)*2));
  SetLength(fKeys,length(fValues));
 end;
 fKeys[Index]:=aName;
 fValues[Index]:=aValue;
 inc(fCount);
end;

function TPinja.TValue.TArrayObject.ObjTryGet(const aName:TPinjaRawByteString;out aValue:TPinja.TValue):Boolean;
var Index:TPinjaInt32;
begin
 if fKind<>TPinja.TValueKind.vkObject then begin
  aValue:=TPinja.TValue.Null; 
  result:=false;
  exit; 
 end;
 for Index:=0 to fCount-1 do begin
  if fKeys[Index]=aName then begin 
   aValue:=fValues[Index];
   result:=true;
   exit;
  end;
 end;
 aValue:=TPinja.TValue.Null;
 result:=false;
end;

function TPinja.TValue.TArrayObject.Count:TPinjaInt32;
begin
 if fKind in [TPinja.TValueKind.vkArray,TPinja.TValueKind.vkObject] then begin
  result:=fCount;
 end else begin
  result:=0;
 end;
end;

function TPinja.TValue.TArrayObject.NameAt(aIndex:TPinjaInt32):TPinjaRawByteString;
begin
 if (fKind<>TPinja.TValueKind.vkObject) or (aIndex<0) or (aIndex>=fCount) then begin
  raise Exception.Create('NameAt out of range');
 end;
 result:=fKeys[aIndex];
end;

function TPinja.TValue.TArrayObject.ValueAt(aIndex:TPinjaInt32;out aValue:TPinja.TValue):Boolean; // vkObject/vkArray
begin
 if (not (fKind in [TPinja.TValueKind.vkArray,TPinja.TValueKind.vkObject])) or (aIndex<0) or (aIndex>=fCount) then begin
   raise Exception.Create('ValueAt out of range');
 end;
 aValue:=fValues[aIndex];
 result:=true;
end;

{ TPinja.TValue }

class function TPinja.TValue.Null:TValue;
begin
 result.fKind:=TPinja.TValueKind.vkNull;
 result.fArrayObject:=nil;
end;

class function TPinja.TValue.From(const aString:TPinjaRawByteString):TValue;
begin
 result.fKind:=TPinja.TValueKind.vkString;
 result.fStringValue:=aString;
 result.fArrayObject:=nil;
end;

class function TPinja.TValue.From(aInteger:TPinjaInt64):TValue;
begin
 result.fKind:=TPinja.TValueKind.vkInt;
 result.fIntegerValue:=aInteger;
 result.fFloatValue:=aInteger;
 result.fArrayObject:=nil;
end;

class function TPinja.TValue.From(aFloat:TPinjaDouble):TValue;
begin
 result.fKind:=TPinja.TValueKind.vkFloat;
 result.fFloatValue:=aFloat;
 result.fIntegerValue:=Round(aFloat);
 result.fArrayObject:=nil;
end;

class function TPinja.TValue.From(aBoolean:Boolean):TValue;
begin
 result.fKind:=TPinja.TValueKind.vkBool;
 result.fBooleanValue:=aBoolean;
 result.fArrayObject:=nil;
end;

class function TPinja.TValue.From(const aJSONItem:TPasJSONItem):TValue;
var Index:TPasJSONInt32;
    ArrayValue:TValue;
    ObjectValue:TValue;
    PropertyKey:TPasJSONUTF8String;
    PropertyValue:TValue;
begin
 result:=Null;
 
 if not assigned(aJSONItem) then begin
  exit;
 end;
 
 if aJSONItem is TPasJSONItemNull then begin
  result:=Null;
 end else if aJSONItem is TPasJSONItemBoolean then begin
  result:=From(TPasJSONItemBoolean(aJSONItem).Value);
 end else if aJSONItem is TPasJSONItemNumber then begin
  result:=From(TPasJSONItemNumber(aJSONItem).Value);
 end else if aJSONItem is TPasJSONItemString then begin
  result:=From(TPasJSONItemString(aJSONItem).Value);
 end else if aJSONItem is TPasJSONItemArray then begin
  ArrayValue:=NewArray;
  for Index:=0 to TPasJSONItemArray(aJSONItem).Count-1 do begin
   ArrayValue.Append(From(TPasJSONItemArray(aJSONItem).Items[Index]));
  end;
  result:=ArrayValue;
 end else if aJSONItem is TPasJSONItemObject then begin
  ObjectValue:=NewObject;
  for Index:=0 to TPasJSONItemObject(aJSONItem).Count-1 do begin
   PropertyKey:=TPasJSONItemObject(aJSONItem).Keys[Index];
   PropertyValue:=From(TPasJSONItemObject(aJSONItem).Values[Index]);
   ObjectValue.ObjSet(PropertyKey,PropertyValue);
  end;
  result:=ObjectValue;
 end;
end;

class function TPinja.TValue.FromCallableObject(aCallableObject:ICallableObject):TValue;
begin
 result.fKind:=TPinja.TValueKind.vkCallerObject;
 result.fCallableObject:=aCallableObject;
end;

class function TPinja.TValue.NewArray:TValue;
begin
 result.fKind:=TPinja.TValueKind.vkArray;
 result.fArrayObject:=TArrayObject.Create(TPinja.TValueKind.vkArray);
end;

class function TPinja.TValue.NewObject:TValue;
begin
 result.fKind:=TPinja.TValueKind.vkObject;
 result.fArrayObject:=TArrayObject.Create(TPinja.TValueKind.vkObject);
end;

procedure TPinja.TValue.Clear;
begin
 fArrayObject:=nil;
 fCallableObject:=nil;
 fStringValue:='';
 fKind:=TPinja.TValueKind.vkNull;
end;

procedure TPinja.TValue.Append(const aValue:TPinja.TValue);
begin
 if fKind<>TPinja.TValueKind.vkArray then begin
  raise Exception.Create('Append on non-array');
 end;
 if assigned(fArrayObject) then begin
  fArrayObject.Append(aValue);
 end else begin
  raise Exception.Create('Append on non-array');
 end;
end;

procedure TPinja.TValue.ObjSet(const aName:TPinjaRawByteString;const aValue:TPinja.TValue);
begin
 if fKind<>TPinja.TValueKind.vkObject then begin
  raise Exception.Create('ObjSet on non-object');
 end;
 if assigned(fArrayObject) then begin
  fArrayObject.ObjSet(aName,aValue);
 end else begin
  raise Exception.Create('ObjSet on non-object');
 end;
end;

function TPinja.TValue.ObjTryGet(const aName:TPinjaRawByteString;out aValue:TPinja.TValue):Boolean;
begin
 if fKind<>TPinja.TValueKind.vkObject then begin
  aValue:=TPinja.TValue.Null;
  result:=false;
  exit;
 end;
 if assigned(fArrayObject) then begin
  result:=fArrayObject.ObjTryGet(aName,aValue);
 end else begin
  result:=false;
 end;
end;

function TPinja.TValue.Count:TPinjaInt32;
begin
 if assigned(fArrayObject) then begin
  result:=fArrayObject.Count;
 end else begin
  result:=0;
 end;
end;

function TPinja.TValue.NameAt(aIndex:TPinjaInt32):TPinjaRawByteString;
begin
 if fKind<>TPinja.TValueKind.vkObject then begin
  raise Exception.Create('NameAt out of range');
 end;
 if assigned(fArrayObject) then begin
  result:=fArrayObject.NameAt(aIndex);
 end else begin
  result:='';
  raise Exception.Create('NameAt out of range');
 end;
end;

function TPinja.TValue.ValueAt(aIndex:TPinjaInt32):TPinja.TValue;
begin
 if not (assigned(fArrayObject) and fArrayObject.ValueAt(aIndex,result)) then begin
  result:=TPinja.TValue.Null;
  raise Exception.Create('ValueAt out of range');
 end;
end;

class function TPinja.TValue.TryAsNumber(const aValue:TPinja.TValue;out aFloatResult:TPinjaDouble):Boolean;
begin
 case aValue.fKind of
  TPinja.TValueKind.vkInt:begin 
   aFloatResult:=aValue.fIntegerValue; 
   result:=true; 
  end;
  TPinja.TValueKind.vkFloat:begin 
   aFloatResult:=aValue.fFloatValue; 
   result:=true; 
  end;
  TPinja.TValueKind.vkBool:begin 
   if aValue.fBooleanValue then begin
    aFloatResult:=1.0;
   end else begin
    aFloatResult:=0.0; 
   end;
   result:=true;
  end;
  TPinja.TValueKind.vkString:begin
   result:=ParseFloat(aValue.fStringValue,aFloatResult);
  end;
  else begin
   aFloatResult:=0.0; 
   result:=false;
  end;  
 end;
end;

class function TPinja.TValue.Numbers(const aLeft,aRight:TValue;out aLeftFloat,aRightFloat:TPinjaDouble):Boolean;
begin
 result:=TryAsNumber(aLeft,aLeftFloat) and TryAsNumber(aRight,aRightFloat);
end;

class function TPinja.TValue.ArraysEqual(const aLeftArray,aRightArray:TValue):Boolean;
var ElementIndex:TPinjaInt32;
    LeftArray,RightArray:TArrayObject;
begin

 if (aLeftArray.fKind<>TPinja.TValueKind.vkArray) or (aRightArray.fKind<>TPinja.TValueKind.vkArray) then begin
  result:=false;
  exit;
 end;

 if aLeftArray.Count<>aRightArray.Count then begin
  result:=false;
  exit;
 end;

 LeftArray:=aLeftArray.fArrayObject.GetArrayObject;
 RightArray:=aRightArray.fArrayObject.GetArrayObject;

 for ElementIndex:=0 to aLeftArray.Count-1 do begin
  if not (LeftArray.fValues[ElementIndex]=RightArray.fValues[ElementIndex]) then begin
   result:=false;
   exit;
  end;
 end;

 result:=true;

end;

class function TPinja.TValue.ObjectsEqual(const aLeftObject,aRightObject:TValue):Boolean;
var PropertyIndex:TPinjaInt32;
    LeftObject,RightObject:TArrayObject;
begin

 if (aLeftObject.fKind<>TPinja.TValueKind.vkObject) or (aRightObject.fKind<>TPinja.TValueKind.vkObject) then begin
  result:=false;
  exit;
 end;

 if aLeftObject.Count<>aRightObject.Count then begin
  result:=false;
  exit;
 end;

 LeftObject:=aLeftObject.fArrayObject.GetArrayObject;
 RightObject:=aRightObject.fArrayObject.GetArrayObject;

 for PropertyIndex:=0 to aLeftObject.Count-1 do begin
  if aLeftObject.NameAt(PropertyIndex)<>aRightObject.NameAt(PropertyIndex) then begin
   result:=false;
   exit;
  end;
  if not (LeftObject.fValues[PropertyIndex]=RightObject.fValues[PropertyIndex]) then begin
   result:=false;
   exit;
  end;
 end;

 result:=true;

end;

function TPinja.TValue.IsTruthy:Boolean;
begin
 case fKind of
  TPinja.TValueKind.vkNull:begin
   result:=false;
  end;
  TPinja.TValueKind.vkBool:begin
   result:=fBooleanValue;
  end; 
  TPinja.TValueKind.vkInt:begin
   result:=fIntegerValue<>0;
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=Abs(fFloatValue)>0.0;
  end;
  TPinja.TValueKind.vkString:begin
   result:=Length(fStringValue)<>0;
  end;
  TPinja.TValueKind.vkArray:begin
   result:=Count>0;
  end;
  TPinja.TValueKind.vkObject:begin
   result:=Count>0;
  end;
  TPinja.TValueKind.vkCallerObject:begin
   result:=assigned(fCallableObject);
  end;
  else begin
   result:=false;
  end;
 end;
end;

function TPinja.TValue.AsString:TPinjaRawByteString;
var ElementIndex:TPinjaInt32;
    ArrayObject:TArrayObject;
begin
 case fKind of
  TPinja.TValueKind.vkNull:begin
   result:='';
  end;
  TPinja.TValueKind.vkBool:begin
   if fBooleanValue then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end;
  TPinja.TValueKind.vkInt:begin
   result:=TPinjaRawByteString(IntToStr(fIntegerValue));
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=TPinjaRawByteString(ConvertFloatToString(fFloatValue));
  end;
  TPinja.TValueKind.vkString:begin
   result:=fStringValue;
  end;
  TPinja.TValueKind.vkArray:begin
   ArrayObject:=fArrayObject.GetArrayObject;
   result:='[';
   for ElementIndex:=0 to ArrayObject.fCount-1 do begin
    if ElementIndex>0 then begin
     result:=result+', ';
    end;
    result:=result+ArrayObject.fValues[ElementIndex].ToJSONString;
   end;
   result:=result+']';
  end;
  TPinja.TValueKind.vkObject:begin
   ArrayObject:=fArrayObject.GetArrayObject;
   result:='{';
   for ElementIndex:=0 to ArrayObject.fCount-1 do begin
    if ElementIndex>0 then begin
     result:=result+', ';
    end;
    result:=result+EscapeJSONString(ArrayObject.fKeys[ElementIndex])+': '+ArrayObject.fValues[ElementIndex].ToJSONString;
   end;
   result:=result+'}';
  end;
  TPinja.TValueKind.vkCallerObject:begin
   result:='<callable>';
  end;
 end;
end;

function TPinja.TValue.AsFloat:TPinjaDouble;
begin
 case fKind of
  TPinja.TValueKind.vkFloat:begin
   result:=fFloatValue;
  end;
  TPinja.TValueKind.vkInt:begin
   result:=fIntegerValue*1.0;
  end;
  TPinja.TValueKind.vkBool:begin
   if fBooleanValue then begin
    result:=1.0;
   end else begin
    result:=0.0;
   end;
  end;
  TPinja.TValueKind.vkString:begin
   result:=ConvertStringToFloat(fStringValue);
  end;
  else begin
   result:=0.0;
  end;
 end;
end;

function TPinja.TValue.AsInt64:TPinjaInt64;
begin
 case fKind of
  TPinja.TValueKind.vkFloat:begin
   result:=trunc(fFloatValue);
  end;
  TPinja.TValueKind.vkInt:begin
   result:=fIntegerValue;
  end;
  TPinja.TValueKind.vkBool:begin
   if fBooleanValue then begin
    result:=1;
   end else begin
    result:=0;
   end;
  end;
  TPinja.TValueKind.vkString:begin
   result:=StrToInt64Def(fStringValue,0);
  end;
  else begin
   result:=0;
  end;
 end;
end;

function TPinja.TValue.ToJSON:TPasJSONItem;
var Index:TPinjaInt32;
    ArrayObject:TArrayObject;
begin
 case fKind of
  TPinja.TValueKind.vkNull:begin
   result:=TPasJSONItemNull.Create;
  end;
  TPinja.TValueKind.vkBool:begin
   result:=TPasJSONItemBoolean.Create(fBooleanValue);
  end;
  TPinja.TValueKind.vkInt:begin
   result:=TPasJSONItemNumber.Create(fIntegerValue);
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=TPasJSONItemNumber.Create(fFloatValue);
  end;
  TPinja.TValueKind.vkString:begin
   result:=TPasJSONItemString.Create(fStringValue);
  end;
  TPinja.TValueKind.vkArray:begin
   result:=TPasJSONItemArray.Create;
   ArrayObject:=fArrayObject.GetArrayObject;
   for Index:=0 to ArrayObject.fCount-1 do begin
    TPasJSONItemArray(result).Add(ArrayObject.fValues[Index].ToJSON);
   end;
  end;
  TPinja.TValueKind.vkObject:begin
   result:=TPasJSONItemObject.Create;
   ArrayObject:=fArrayObject.GetArrayObject;
   for Index:=0 to ArrayObject.fCount-1 do begin
    TPasJSONItemObject(result).Add(ArrayObject.fKeys[Index],ArrayObject.fValues[Index].ToJSON);
   end;
  end;
  else begin
   result:=nil;
  end;
 end;
end;

function TPinja.TValue.ToJSONString:TPinjaRawByteString;
var Index:TPinjaInt32;
    ArrayObject:TArrayObject;
begin
 case fKind of
  TPinja.TValueKind.vkNull:begin
   result:='null';
  end;
  TPinja.TValueKind.vkBool:begin
   if fBooleanValue then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end;
  TPinja.TValueKind.vkInt:begin
   result:=TPinjaRawByteString(IntToStr(fIntegerValue));
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=TPinjaRawByteString(ConvertFloatToString(fFloatValue));
  end;
  TPinja.TValueKind.vkString:begin
   result:=EscapeJSONString(fStringValue);
  end;
  TPinja.TValueKind.vkArray:begin
   ArrayObject:=fArrayObject.GetArrayObject;
   result:='[';
   for Index:=0 to ArrayObject.fCount-1 do begin
    if Index>0 then begin
     result:=result+',';
    end;
    result:=result+ArrayObject.fValues[Index].ToJSONString;
   end;
   result:=result+']';
  end;
  TPinja.TValueKind.vkObject:begin
   ArrayObject:=fArrayObject.GetArrayObject;
   result:='{';
   for Index:=0 to ArrayObject.fCount-1 do begin
    if Index>0 then begin
     result:=result+',';
    end;
    result:=result+'"'+ArrayObject.fKeys[Index]+'":'+ArrayObject.fValues[Index].ToJSONString;
   end;
   result:=result+'}';
  end;
  TPinja.TValueKind.vkCallerObject:begin
   result:='"<callable>"';
  end;
 end;
end;

function TPinja.TValue.Clone:TValue;
begin
 // Shallow copy of references (arrays/objects) by design. 
 result:=Self;
end;

function TPinja.TValue.CallAsCallable(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue;
begin
 case fKind of
  TPinja.TValueKind.vkCallerObject:begin
   if assigned(fCallableObject) then begin
    result:=TCallableObject(fCallableObject.GetObject).Call(aSelfValue,aPosArgs,aKwArgs,aCtx);
   end else begin
    raise Exception.Create('No callable object assigned');
   end;
  end;
  else begin
   raise Exception.Create('Value is not callable');
  end;
 end;
end;

class operator TPinja.TValue.Implicit(const aString:TPinjaRawByteString):TValue;
begin
 result:=From(aString);
end;

class operator TPinja.TValue.Implicit(aInteger:TPinjaInt64):TValue;
begin
 result:=From(aInteger);
end;

class operator TPinja.TValue.Implicit(aFloat:TPinjaDouble):TValue;
begin
 result:=From(aFloat);
end;

class operator TPinja.TValue.Implicit(aBoolean:Boolean):TValue;
begin
 result:=From(aBoolean);
end;

class operator TPinja.TValue.Add(const aLeft,aRight:TValue):TValue;
var ElementIndex:TPinjaInt32;
    LeftArray,RightArray:TArrayObject;
begin
  
 if (aLeft.fKind=TPinja.TValueKind.vkArray) and (aRight.fKind=TPinja.TValueKind.vkArray) then begin

  // array + array -> concatenate elements

  LeftArray:=aLeft.fArrayObject.GetArrayObject;
  RightArray:=aRight.fArrayObject.GetArrayObject;

  result:=NewArray;

  // append A
  for ElementIndex:=0 to LeftArray.fCount-1 do begin
   result.Append(LeftArray.fValues[ElementIndex]);
  end;

  // append B
  for ElementIndex:=0 to RightArray.fCount-1 do begin
   result.Append(RightArray.fValues[ElementIndex]);
  end;

 end else if (aLeft.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (aRight.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) then begin
 
  // numeric + numeric

  if (aLeft.fKind=TPinja.TValueKind.vkInt) and (aRight.fKind=TPinja.TValueKind.vkInt) then begin
   result:=From(aLeft.fIntegerValue+aRight.fIntegerValue);
  end else begin
   result:=From(aLeft.AsFloat+aRight.AsFloat);
  end;
  
 end else begin
  result:=From(aLeft.AsString+aRight.AsString);
 end; 
end;

class operator TPinja.TValue.Subtract(const aLeft,aRight:TValue):TValue;
begin
  // numeric - numeric
 if (aLeft.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (aRight.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) then begin
  if (aLeft.fKind=TPinja.TValueKind.vkInt) and (aRight.fKind=TPinja.TValueKind.vkInt) then begin
    result:=From(aLeft.fIntegerValue-aRight.fIntegerValue);
  end else begin
    result:=From(aLeft.AsFloat-aRight.AsFloat);
  end;
 end else begin
  result:=Null;
 end;
end;

class operator TPinja.TValue.Multiply(const aLeft,aRight:TValue):TValue;
var LeftFloat,RightFloat:TPinjaDouble;
    RepeatCount:TPinjaInt64;
    Index,StringLength,Position:TPinjaInt32;
    StringValue,OutputString:TPinjaRawByteString;
begin
 
 // numeric * numeric
 if (aLeft.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (aRight.fKind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) then begin
  if (aLeft.fKind=TPinja.TValueKind.vkInt) and (aRight.fKind=TPinja.TValueKind.vkInt) then begin
   result:=TPinja.TValue.From(aLeft.fIntegerValue*aRight.fIntegerValue);
   exit;
  end else begin
   LeftFloat:=aLeft.AsFloat;
   RightFloat:=aRight.AsFloat;
   result:=TPinja.TValue.From(LeftFloat*RightFloat);
   exit;
  end;
 end;

 // string * int (either order) -> repeat
 if (aLeft.fKind=TPinja.TValueKind.vkString) and (aRight.fKind=TPinja.TValueKind.vkInt) then begin
  StringValue:=aLeft.fStringValue; 
  RepeatCount:=aRight.fIntegerValue;
 end else if (aRight.fKind=TPinja.TValueKind.vkString) and (aLeft.fKind=TPinja.TValueKind.vkInt) then begin
  StringValue:=aRight.fStringValue; 
  RepeatCount:=aLeft.fIntegerValue;
 end else begin
  // fallback:stringify + concat
  result:=TPinja.TValue.From(aLeft.AsString+aRight.AsString);
  exit;
 end;

 if (RepeatCount<=0) or (Length(StringValue)=0) then begin
  result:=TPinja.TValue.From(TPinjaRawByteString(''));
  exit;
 end;

 // optional safety against huge allocations
 if RepeatCount>(High(TPinjaInt32) div Max(1,Length(StringValue))) then begin
  raise Exception.Create('string repeat too large');
  exit;
 end; 

 OutputString:='';
 SetLength(OutputString,Length(StringValue)*TPinjaInt32(RepeatCount));
 StringLength:=Length(StringValue);
 Position:=1;
 for Index:=1 to TPinjaInt32(RepeatCount) do begin
  Move(StringValue[1],OutputString[Position],StringLength);
  inc(Position,StringLength);
 end;

 result:=TPinja.TValue.From(OutputString);

end;

class operator TPinja.TValue.Equal(const aLeft,aRight:TValue):Boolean;
var LeftFloat,RightFloat:TPinjaDouble;
begin

 // numeric-compatible:int/float/bool
 if Numbers(aLeft,aRight,LeftFloat,RightFloat) then begin
  result:=LeftFloat=RightFloat;
  exit;
 end;

 if aLeft.fKind=aRight.fKind then begin
  case aLeft.fKind of
   TPinja.TValueKind.vkNull:begin
    result:=true;
   end;
   TPinja.TValueKind.vkBool:begin
    result:=aLeft.fBooleanValue=aRight.fBooleanValue;
   end;
   TPinja.TValueKind.vkString:begin
    result:=aLeft.fStringValue=aRight.fStringValue;
   end;
   TPinja.TValueKind.vkArray:begin
    result:=ArraysEqual(aLeft,aRight);
   end;
   TPinja.TValueKind.vkObject:begin
    result:=ObjectsEqual(aLeft,aRight);
   end;
   else begin
    result:=false;
   end;
  end;
  exit;
 end;

 // cross-kind:only allow numeric mix handled above; otherwise not equal
 result:=false;

end;

class operator TPinja.TValue.NotEqual(const aLeft,aRight:TValue):Boolean;
begin
 result:=not (aLeft=aRight);
end;

class operator TPinja.TValue.LessThan(const aLeft,aRight:TValue):Boolean;
var LeftFloat,RightFloat:TPinjaDouble;
begin
 
 if Numbers(aLeft,aRight,LeftFloat,RightFloat) then begin
  result:=LeftFloat<RightFloat;
  exit;
 end;

 if (aLeft.fKind=TPinja.TValueKind.vkString) and (aRight.fKind=TPinja.TValueKind.vkString) then begin
  result:=aLeft.fStringValue<aRight.fStringValue;
  exit;
 end;

 // incomparable kinds -> false (do NOT fallback to AsString)
 result:=false;

end;

class operator TPinja.TValue.GreaterThan(const aLeft,aRight:TValue):Boolean;
var LeftFloat,RightFloat:TPinjaDouble;
begin
 
 if Numbers(aLeft,aRight,LeftFloat,RightFloat) then begin
  result:=LeftFloat>RightFloat;
  exit;
 end;

 if (aLeft.fKind=TPinja.TValueKind.vkString) and (aRight.fKind=TPinja.TValueKind.vkString) then begin
  result:=aLeft.fStringValue>aRight.fStringValue;
  exit;
 end;

 result:=false;

end;

class operator TPinja.TValue.LessThanOrEqual(const aLeft,aRight:TValue):Boolean;
var LeftFloat,RightFloat:TPinjaDouble;
begin
  
 if Numbers(aLeft,aRight,LeftFloat,RightFloat) then begin
  result:=LeftFloat<=RightFloat;
  exit;
 end;

 if (aLeft.fKind=TPinja.TValueKind.vkString) and (aRight.fKind=TPinja.TValueKind.vkString) then begin
  result:=aLeft.fStringValue<=aRight.fStringValue;
  exit;
 end;

 result:=false;

end;

class operator TPinja.TValue.GreaterThanOrEqual(const aLeft,aRight:TValue):Boolean;
var LeftFloat,RightFloat:TPinjaDouble;
begin
  
 if Numbers(aLeft,aRight,LeftFloat,RightFloat) then begin
  result:=LeftFloat>=RightFloat;
  exit;
 end;

 if (aLeft.fKind=TPinja.TValueKind.vkString) and (aRight.fKind=TPinja.TValueKind.vkString) then begin
  result:=aLeft.fStringValue>=aRight.fStringValue;
  exit;
 end;

 result:=false;

end;

class operator TPinja.TValue.LogicalAnd(const aLeft,aRight:TValue):TValue;
begin
 result:=From(aLeft.IsTruthy and aRight.IsTruthy);
end;

class operator TPinja.TValue.LogicalOr(const aLeft,aRight:TValue):TValue;
begin
 result:=From(aLeft.IsTruthy or aRight.IsTruthy);
end;

class operator TPinja.TValue.LogicalNot(const aValue:TValue):TValue;
begin
 result:=From(not aValue.IsTruthy);
end;

{ TPinja.TCallableObject }

constructor TPinja.TCallableObject.Create;
begin
 inherited Create;
 fCallable:=nil;
end;

function TPinja.TCallableObject.GetObject:TObject;
begin
 result:=self;
end;

function TPinja.TCallableObject.Call(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue;
begin
 if assigned(fCallable) then begin
  result:=fCallable(aSelfValue,aPosArgs,aKwArgs,aCtx);
 end else begin
  result:=TPinja.TValue.Null;
 end;
end;

//==============================================================================
// TContext                                                                      
//==============================================================================

{ TPinja.TContext }

constructor TPinja.TContext.Create;
begin

 inherited Create;

 fScopes:=nil;
 fCountScopes:=0;

 fCallNames:=TStringList.Create;
 fCallNames.Sorted:=true;
 fCallNames.Duplicates:=dupError;
 fCallPtrs:=TCallableList.Create;

 fFilterNames:=TStringList.Create;
 fFilterNames.Sorted:=true;
 fFilterNames.Duplicates:=dupError;
 fFilterPtrs:=TFilterList.Create;

 fMacroNames:=TStringList.Create;
 fMacroNames.Sorted:=true;
 fMacroNames.Duplicates:=dupError;
 fMacroObjs:=TList.Create;

 fLastCallName:='';

 RegisterDefaultFilters;
 RegisterDefaultCallables;

 fRaiseExceptionAtUnknownCallables:=true;

 PushScope;

end;

destructor TPinja.TContext.Destroy;
begin
 while fCountScopes>0 do begin
  PopScope;
 end;
 fScopes:=nil;
 FreeAndNil(fCallNames);
 FreeAndNil(fCallPtrs);
 FreeAndNil(fFilterNames);
 FreeAndNil(fFilterPtrs);
 FreeAndNil(fMacroNames);
 FreeAndNil(fMacroObjs);
 inherited Destroy;
end;

function TPinja.TContext.Top:PValue;
begin
 if fCountScopes<=0 then begin
  raise Exception.Create('No scope');
 end;
 result:=fScopes[fCountScopes-1];
end;

procedure TPinja.TContext.PushScope;
var ScopePointer:PValue;
    Index:TPinjaInt32;
begin
 New(ScopePointer);
 ScopePointer^:=TValue.NewObject;
 Index:=fCountScopes;
 inc(fCountScopes);
 if length(fScopes)<fCountScopes then begin
  SetLength(fScopes,fCountScopes*2);
 end; 
 fScopes[Index]:=ScopePointer;
end;

procedure TPinja.TContext.PopScope;
var Index:TPinjaInt32;
    ScopePointer:PValue;
begin
 Index:=fCountScopes-1;
 if Index<0 then begin
  raise Exception.Create('Pop underflow');
 end;
 dec(fCountScopes);
 ScopePointer:=fScopes[Index]; 
 ScopePointer^.Clear;
 Dispose(ScopePointer);
end;

procedure TPinja.TContext.Clear;
begin
 while fCountScopes>0 do begin
  PopScope;
 end; 
 PushScope;
 fMacroNames.Clear;
 fMacroObjs.Clear;
 fCallNames.Clear;
 fCallPtrs.Clear;
 fFilterNames.Clear;
 fFilterPtrs.Clear;
end;

procedure TPinja.TContext.SetVariable(const aName:TPinjaRawByteString;const aValue:TValue);
begin
 Top^.ObjSet(aName,aValue);
end;

function TPinja.TContext.TryGetVariable(const aName:TPinjaRawByteString;out aValue:TValue):Boolean;
var Index:TPinjaInt32;
begin
 for Index:=fCountScopes-1 downto 0 do begin
  if fScopes[Index]^.ObjTryGet(aName,aValue) then begin
   result:=true;
   exit;
  end;
 end;
 aValue:=TValue.Null;
 result:=false;
end;

procedure TPinja.TContext.RegisterFilter(const aName:TPinjaRawByteString;aFilter:TFilter);
var Index:TPinjaInt32;
begin
 if fFilterNames.Find(aName,Index) then begin
  fFilterPtrs[Index]:=aFilter;
 end else begin
  Index:=fFilterNames.Add(aName);
  fFilterPtrs.Insert(Index,aFilter);
 end;
end;

function TPinja.TContext.FindFilterIndex(const aName:TPinjaRawByteString):TPinjaInt32;
begin
 if not fFilterNames.Find(aName,result) then begin
  result:=-1;
 end;
end;

function TPinja.TContext.TryGetFilter(const aName:TPinjaRawByteString;out aFilter:TFilter):Boolean;
var Index:TPinjaInt32;
begin
 Index:=FindFilterIndex(aName);
 result:=Index>=0;
 if result then begin
  aFilter:=fFilterPtrs[Index];
 end else begin
  aFilter:=nil;
 end;
end;

procedure TPinja.TContext.RegisterCallable(const aName:TPinjaRawByteString;aCallable:TCallable);
var Index:TPinjaInt32;
begin
 if fCallNames.Find(aName,Index) then begin
  fCallPtrs[Index]:=aCallable;
 end else begin
  Index:=fCallNames.Add(aName);
  fCallPtrs.Insert(Index,aCallable);
 end;
end;

function TPinja.TContext.FindCallableIndex(const aName:TPinjaRawByteString):TPinjaInt32;
begin
 if not fCallNames.Find(aName,result) then begin
  result:=-1;
 end; 
end;

function TPinja.TContext.TryGetCallable(const aName:TPinjaRawByteString;out aCallable:TCallable):Boolean;
var Index:TPinjaInt32;
begin
 Index:=FindCallableIndex(aName);
 result:=Index>=0;
 if result then begin
  aCallable:=fCallPtrs[Index];
  fLastCallName:=aName;
 end else begin
  aCallable:=nil;
  fLastCallName:='';
 end;
end;

procedure TPinja.TContext.RegisterMacro(const aName:TPinjaRawByteString;aMacro:TNodeStatementMacroDefinition);
var Index:TPinjaInt32;
begin
 if fMacroNames.Find(aName,Index) then begin
  fMacroObjs[Index]:=aMacro;
 end else begin
  Index:=fMacroNames.Add(aName);
  fMacroObjs.Insert(Index,aMacro);
 end;
end;

function TPinja.TContext.FindMacroIndex(const aName:TPinjaRawByteString):TPinjaInt32;
begin
 if not fMacroNames.Find(aName,result) then begin
  result:=-1;
 end;
end;

function TPinja.TContext.TryGetMacro(const aName:TPinjaRawByteString;out aMacro:TNodeStatementMacroDefinition):Boolean;
var Index:TPinjaInt32;
begin
 Index:=FindMacroIndex(aName);
 result:=Index>=0;
 if result then begin
  aMacro:=TNodeStatementMacroDefinition(fMacroObjs[Index]);
 end else begin
  aMacro:=nil;
 end;
end;

// Default filters 
function F_upper(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 result:=TPinja.TValue.From(UpperCase(aInput.AsString));
end;

function F_lower(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 result:=TPinja.TValue.From(LowerCase(aInput.AsString));
end;

function F_trim(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 result:=TPinja.TValue.From(Trim(aInput.AsString));
end;

function F_length(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Count:TPinjaInt32;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   Count:=aInput.Count;
  end;
  TPinja.TValueKind.vkObject:begin
   Count:=aInput.Count;
  end;
  TPinja.TValueKind.vkNull:begin
   Count:=0;
  end;
  else begin
   Count:=Length(aInput.AsString);
  end;
 end;
 result:=TPinja.TValue.From(Count);
end;

function F_join(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Separator:TPinjaRawByteString;
    Index:TPinjaInt32;
    AccumulatorString:TPinjaRawByteString;
begin
 if length(aArgs)>0 then begin
  Separator:=aArgs[0].AsString;
 end else begin
  Separator:='';
 end;
 
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   AccumulatorString:='';
   for Index:=0 to aInput.Count-1 do begin
    if Index>0 then begin
     AccumulatorString:=AccumulatorString+Separator;
    end;
    AccumulatorString:=AccumulatorString+aInput.ValueAt(Index).AsString;
   end;
   result:=TPinja.TValue.From(AccumulatorString);
  end;
  else begin
   result:=aInput;
  end;
 end;
end;

function F_default(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var DefaultValue:TPinja.TValue;
    DefaultIfNone:Boolean;
begin
 if length(aArgs)>0 then begin
  DefaultValue:=aArgs[0];
 end else begin
  DefaultValue:=TPinja.TValue.From('');
 end;
 
 DefaultIfNone:=false;
 if length(aArgs)>1 then begin
  DefaultIfNone:=aArgs[1].IsTruthy;
 end;
 
 if DefaultIfNone then begin
  // Only use default if input is None/null
  if aInput.Kind=TPinja.TValueKind.vkNull then begin
   result:=DefaultValue;
  end else begin
   result:=aInput;
  end;
 end else begin
  // Use default if input is falsy (empty, None, false, 0, etc.)
  if aInput.IsTruthy then begin
   result:=aInput;
  end else begin
   result:=DefaultValue;
  end;
 end;
end;

function F_escape(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
  result:=TPinja.TValue.From(HTMLEscape(aInput.AsString));
end;

function F_to_json(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
  result:=TPinja.TValue.From(aInput.ToJSONString);
end;

function F_str(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
  result:=TPinja.TValue.From(aInput.AsString);
end;

function F_strip(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 result:=TPinja.TValue.From(Trim(aInput.AsString));
end;

function F_replace(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    OldSubstr,NewSubstr:TPinjaRawByteString;
    MaxCount:TPinjaInt32;
    CurrentCount:TPinjaInt32;
    PosValue:TPinjaInt32;
begin
 InputString:=aInput.AsString;
 
 if length(aArgs)<2 then begin
  result:=TPinja.TValue.From(InputString);
  exit;
 end;
 
 OldSubstr:=aArgs[0].AsString;
 NewSubstr:=aArgs[1].AsString;
 MaxCount:=MaxInt; // default: replace all
 
 if length(aArgs)>2 then begin
  MaxCount:=aArgs[2].AsInt64;
 end;
 
 CurrentCount:=0;
 PosValue:=System.Pos(OldSubstr,InputString);
 while (PosValue>0) and (CurrentCount<MaxCount) do begin
  Delete(InputString,PosValue,Length(OldSubstr));
  Insert(NewSubstr,InputString,PosValue);
  inc(CurrentCount);
  PosValue:=System.Pos(OldSubstr,InputString);
 end;
 
 result:=TPinja.TValue.From(InputString);
end;

function F_startswith(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var text,prefix:TPinjaRawByteString;
begin
 text:=aInput.AsString;
 if Length(aArgs)>=1 then begin
  prefix:=aArgs[0].AsString;
  result:=TPinja.TValue.From(Copy(text,1,Length(prefix))=prefix);
 end else begin
  result:=TPinja.TValue.From(false);
 end;
end;

function F_endswith(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var text,suffix:TPinjaRawByteString;
    textLen,suffixLen:TPinjaInt32;
begin
 text:=aInput.AsString;
 if Length(aArgs)>=1 then begin
  suffix:=aArgs[0].AsString;
  textLen:=Length(text);
  suffixLen:=Length(suffix);
  if suffixLen <= textLen then begin
   result:=TPinja.TValue.From(Copy(text,textLen-suffixLen+1,suffixLen)=suffix);
  end else begin
   result:=TPinja.TValue.From(false);
  end;
 end else begin
  result:=TPinja.TValue.From(false);
 end;
end;

function F_capitalize(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
begin
 InputString:=aInput.AsString;
 if length(InputString)>0 then begin
  InputString[1]:=upcase(InputString[1]);
 end;
 result:=TPinja.TValue.From(InputString);
end;

function F_count(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   result:=TPinja.TValue.From(TPinjaInt64(aInput.Count));
  end;
  TPinja.TValueKind.vkObject:begin
   result:=TPinja.TValue.From(TPinjaInt64(aInput.Count));
  end;
  TPinja.TValueKind.vkString:begin
   result:=TPinja.TValue.From(TPinjaInt64(length(aInput.AsString)));
  end;
  else begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
 end;
end;

function F_first(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   if aInput.Count>0 then begin
    result:=aInput.ValueAt(0);
   end else begin
    result:=TPinja.TValue.Null;
   end;
  end;
  TPinja.TValueKind.vkString:begin
   if length(aInput.AsString)>0 then begin
    result:=TPinja.TValue.From(aInput.AsString[1]);
   end else begin
    result:=TPinja.TValue.Null;
   end;
  end;
  else begin
   result:=TPinja.TValue.Null;
  end;
 end;
end;

function F_last(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   if aInput.Count>0 then begin
    result:=aInput.ValueAt(aInput.Count-1);
   end else begin
    result:=TPinja.TValue.Null;
   end;
  end;
  TPinja.TValueKind.vkString:begin
   InputString:=aInput.AsString;
   if length(InputString)>0 then begin
    result:=TPinja.TValue.From(InputString[length(InputString)]);
   end else begin
    result:=TPinja.TValue.Null;
   end;
  end;
  else begin
   result:=TPinja.TValue.Null;
  end;
 end;
end;

function F_safe(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 // Safe filter just returns the string representation without escaping
 result:=TPinja.TValue.From(aInput.AsString);
end;

function F_unique(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Index:TPinjaInt32;
    Seen:array of TPinja.TValue;
    Value:TPinja.TValue;
    SeenIndex:TPinjaInt32;
    Found:Boolean;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   result:=TPinja.TValue.NewArray;
   SetLength(Seen,0);
   for Index:=0 to aInput.Count-1 do begin
    Value:=aInput.ValueAt(Index);
    Found:=false;
    for SeenIndex:=0 to length(Seen)-1 do begin
     if Seen[SeenIndex]=Value then begin
      Found:=true;
      break;
     end;
    end;
    if not Found then begin
     SetLength(Seen,length(Seen)+1);
     Seen[length(Seen)-1]:=Value;
     result.Append(Value);
    end;
   end;
  end;
  else begin
   result:=aInput;
  end;
 end;
end;

function F_dictsort(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Index,Count:TPinjaInt32;
    Keys:array of TPinjaRawByteString;
    Values:array of TPinja.TValue;
    TempKey:TPinjaRawByteString;
    TempValue:TPinja.TValue;
    Pair:TPinja.TValue;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkObject:begin
   result:=TPinja.TValue.NewArray;
   SetLength(Keys,aInput.Count);
   SetLength(Values,aInput.Count);
   for Index:=0 to aInput.Count-1 do begin
    Keys[Index]:=aInput.NameAt(Index);
    Values[Index]:=aInput.ValueAt(Index);
   end;
   // Simple gnome-style sort
   Count:=length(Keys);
   if Count>1 then begin
    Index:=0;
    while (Index+1)<Count do begin
     if Keys[Index]>Keys[Index+1] then begin
      TempKey:=Keys[Index];
      Keys[Index]:=Keys[Index+1];
      Keys[Index+1]:=TempKey;
      TempValue:=Values[Index];
      Values[Index]:=Values[Index+1];
      Values[Index+1]:=TempValue;
      if Index>0 then begin
       dec(Index);
      end else begin
       inc(Index);
      end;
     end else begin
      inc(Index);
     end;
    end;
   end;
   for Index:=0 to length(Keys)-1 do begin
    Pair:=TPinja.TValue.NewArray;
    Pair.Append(TPinja.TValue.From(Keys[Index]));
    Pair.Append(Values[Index]);
    result.Append(Pair);
   end;
  end;
  else begin
   result:=TPinja.TValue.NewArray;
  end;
 end;
end;

function F_indent(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString,IndentStr,ResultString:TPinjaRawByteString;
    IndentSize:TPinjaInt32;
    FirstLine:Boolean;
    CharIndex,LineStart:TPinjaInt32;
begin
 InputString:=aInput.AsString;
 IndentSize:=4; // default
 FirstLine:=false; // default
 
 if length(aArgs)>0 then begin
  IndentSize:=aArgs[0].AsInt64;
 end;
 if length(aArgs)>1 then begin
  FirstLine:=aArgs[1].IsTruthy;
 end;
 
 IndentStr:=StringOfChar(' ',IndentSize);
 ResultString:='';
 LineStart:=1;
 
 for CharIndex:=1 to length(InputString) do begin
  if InputString[CharIndex]=#10 then begin
   if (LineStart=1) and FirstLine then begin
    ResultString:=ResultString+IndentStr+Copy(InputString,LineStart,CharIndex-LineStart+1);
   end else if LineStart>1 then begin
    ResultString:=ResultString+IndentStr+Copy(InputString,LineStart,CharIndex-LineStart+1);
   end else begin
    ResultString:=ResultString+Copy(InputString,LineStart,CharIndex-LineStart+1);
   end;
   LineStart:=CharIndex+1;
  end;
 end;
 
 // Handle last line if it doesn't end with newline
 if LineStart<=length(InputString) then begin
  if (LineStart=1) and FirstLine then begin
   ResultString:=ResultString+IndentStr+Copy(InputString,LineStart,length(InputString)-LineStart+1);
  end else if LineStart>1 then begin
   ResultString:=ResultString+IndentStr+Copy(InputString,LineStart,length(InputString)-LineStart+1);
  end else begin
   ResultString:=ResultString+Copy(InputString,LineStart,length(InputString)-LineStart+1);
  end;
 end;
 
 result:=TPinja.TValue.From(ResultString);
end;

function F_title(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    CharIndex:TPinjaInt32;
begin
 InputString:=aInput.AsString;
 for CharIndex:=1 to length(InputString) do begin
  if (CharIndex=1) or ((CharIndex>1) and (InputString[CharIndex-1]=' ')) then begin
   InputString[CharIndex]:=upcase(InputString[CharIndex]);
  end else begin
   if InputString[CharIndex] in ['A'..'Z'] then begin
    InputString[CharIndex]:=AnsiChar(TPinjaUInt8(InputString[CharIndex])+32);
   end;
  end;
 end;
 result:=TPinja.TValue.From(InputString);
end;

function F_reverse(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var LeftIndex,RightIndex:TPinjaInt32;
    TempValue:TPinja.TValue;
    InputString:TPinjaRawByteString;
    TempChar:AnsiChar;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   result:=aInput;
   LeftIndex:=0;
   RightIndex:=result.Count-1;
   while LeftIndex<RightIndex do begin
    TempValue:=result.ValueAt(LeftIndex);
    result.fArrayObject.GetArrayObject.fValues[LeftIndex]:=result.ValueAt(RightIndex);
    result.fArrayObject.GetArrayObject.fValues[RightIndex]:=TempValue;
    inc(LeftIndex);
    dec(RightIndex);
   end;
  end;
  TPinja.TValueKind.vkString:begin
   InputString:=aInput.AsString;
   // Reverse the string
   for LeftIndex:=1 to length(InputString) div 2 do begin
    RightIndex:=length(InputString)-LeftIndex+1;
    if LeftIndex<>RightIndex then begin
     TempChar:=InputString[LeftIndex];
     InputString[LeftIndex]:=InputString[RightIndex];
     InputString[RightIndex]:=TempChar;
    end;
   end;
   result:=TPinja.TValue.From(InputString);
  end;
  else begin
   result:=aInput;
  end;
 end;
end;

function F_round(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var FloatValue:TPinjaDouble;
    Precision:TPinjaInt32;
    Multiplier:TPinjaDouble;
begin
 FloatValue:=aInput.AsFloat;
 Precision:=0; // default
 
 if length(aArgs)>0 then begin
  Precision:=aArgs[0].AsInt64;
 end;
 
 if Precision=0 then begin
  result:=TPinja.TValue.From(TPinjaInt64(System.Round(FloatValue)));
 end else begin
  Multiplier:=1.0;
  while Precision>0 do begin
   Multiplier:=Multiplier*10.0;
   dec(Precision);
  end;
  while Precision<0 do begin
   Multiplier:=Multiplier/10.0;
   inc(Precision);
  end;
  result:=TPinja.TValue.From(System.Round(FloatValue*Multiplier)/Multiplier);
 end;
end;

function F_sort(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Index,OuterIndex,InnerIndex:TPinjaInt32;
    TempValue:TPinja.TValue;
    Reverse:Boolean;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   result:=aInput;
   Reverse:=false;
   if length(aArgs)>0 then begin
    Reverse:=aArgs[0].IsTruthy;
   end;
   
   // Simple bubble sort
   for OuterIndex:=0 to result.Count-2 do begin
    for InnerIndex:=0 to result.Count-2-OuterIndex do begin
     if (not Reverse and (result.ValueAt(InnerIndex).AsString>result.ValueAt(InnerIndex+1).AsString)) or
        (Reverse and (result.ValueAt(InnerIndex).AsString<result.ValueAt(InnerIndex+1).AsString)) then begin
      TempValue:=result.ValueAt(InnerIndex);
      result.fArrayObject.GetArrayObject.fValues[InnerIndex]:=result.ValueAt(InnerIndex+1);
      result.fArrayObject.GetArrayObject.fValues[InnerIndex+1]:=TempValue;
     end;
    end;
   end;
  end;
  else begin
   result:=aInput;
  end;
 end;
end;

function F_slice(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var StartIndex,EndIndex,Step:TPinjaInt32;
    Index,ResultIndex:TPinjaInt32;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkArray:begin
   StartIndex:=0;
   EndIndex:=aInput.Count;
   Step:=1;
   
   if length(aArgs)>0 then begin
    StartIndex:=aArgs[0].AsInt64;
   end;
   if length(aArgs)>1 then begin
    EndIndex:=aArgs[1].AsInt64;
   end;
   if length(aArgs)>2 then begin
    Step:=aArgs[2].AsInt64;
   end;
   
   if Step=0 then begin
    Step:=1; // avoid infinite loop
   end;
   
   result:=TPinja.TValue.NewArray;
   if Step>0 then begin
    Index:=StartIndex;
    while (Index<EndIndex) and (Index<aInput.Count) do begin
     if Index>=0 then begin
      result.Append(aInput.ValueAt(Index));
     end;
     Index:=Index+Step;
    end;
   end;
  end;
  else begin
   result:=aInput;
  end;
 end;
end;

function F_center(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    Width:TPinjaInt32;
    FillChar:AnsiChar;
    PadLeft,PadRight:TPinjaInt32;
begin
 InputString:=aInput.AsString;
 Width:=80; // default
 FillChar:=' '; // default
 
 if length(aArgs)>0 then begin
  Width:=aArgs[0].AsInt64;
 end;
 if length(aArgs)>1 then begin
  if length(aArgs[1].AsString)>0 then begin
   FillChar:=aArgs[1].AsString[1];
  end;
 end;
 
 if length(InputString)>=Width then begin
  result:=TPinja.TValue.From(InputString);
 end else begin
  PadLeft:=(Width-length(InputString)) div 2;
  PadRight:=Width-length(InputString)-PadLeft;
  result:=TPinja.TValue.From(StringOfChar(FillChar,PadLeft)+InputString+StringOfChar(FillChar,PadRight));
 end;
end;

function F_truncate(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    MaxLength:TPinjaInt32;
    Killwords:Boolean;
    EndString:TPinjaRawByteString;
    LastSpace:TPinjaInt32;
begin
 InputString:=aInput.AsString;
 MaxLength:=255; // default
 Killwords:=false; // default
 EndString:='...'; // default
 
 if length(aArgs)>0 then begin
  MaxLength:=aArgs[0].AsInt64;
 end;
 if length(aArgs)>1 then begin
  Killwords:=aArgs[1].IsTruthy;
 end;
 if length(aArgs)>2 then begin
  EndString:=aArgs[2].AsString;
 end;
 
 if length(InputString)<=MaxLength then begin
  result:=TPinja.TValue.From(InputString);
 end else begin
  if Killwords then begin
   result:=TPinja.TValue.From(Copy(InputString,1,MaxLength-length(EndString))+EndString);
  end else begin
   LastSpace:=MaxLength-length(EndString);
   while (LastSpace>0) and (InputString[LastSpace]<>' ') do begin
    dec(LastSpace);
   end;
   if LastSpace>0 then begin
    result:=TPinja.TValue.From(Copy(InputString,1,LastSpace-1)+EndString);
   end else begin
    result:=TPinja.TValue.From(Copy(InputString,1,MaxLength-length(EndString))+EndString);
   end;
  end;
 end;
end;

function F_wordcount(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    WordCount:TPinjaInt32;
    Index:TPinjaInt32;
    InWord:Boolean;
begin
 InputString:=aInput.AsString;
 WordCount:=0;
 InWord:=false;
 
 for Index:=1 to length(InputString) do begin
  if InputString[Index] in [#9,#10,#13,' '] then begin
   InWord:=false;
  end else begin
   if not InWord then begin
    inc(WordCount);
    InWord:=true;
   end;
  end;
 end;
 
 result:=TPinja.TValue.From(TPinjaInt64(WordCount));
end;

function F_format(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var FormatString:TPinjaRawByteString;
    Index:TPinjaInt32;
    PlaceholderPos:TPinjaInt32;
    ResultString:TPinjaRawByteString;
    ArgValue:TPinjaRawByteString;
begin
 FormatString:=aInput.AsString;
 ResultString:=FormatString;
 
 // Simple positional replacement of {} placeholders
 for Index:=0 to length(aArgs)-1 do begin
  PlaceholderPos:=Pos('{}',ResultString);
  if PlaceholderPos>0 then begin
   ArgValue:=aArgs[Index].AsString;
   Delete(ResultString,PlaceholderPos,2);
   Insert(ArgValue,ResultString,PlaceholderPos);
  end;
 end;
 
 result:=TPinja.TValue.From(ResultString);
end;

function F_list(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 if aInput.Kind=TPinja.TValueKind.vkArray then begin
  result:=aInput;
 end else begin
  result:=TPinja.TValue.NewArray;
  result.Append(aInput);
 end;
end;

function F_int(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 case aInput.Kind of
  TPinja.TValueKind.vkNull:begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
  TPinja.TValueKind.vkBool:begin
   if aInput.fBooleanValue then begin
    result:=TPinja.TValue.From(TPinjaInt64(1));
   end else begin
    result:=TPinja.TValue.From(TPinjaInt64(0));
   end;
  end;
  TPinja.TValueKind.vkInt:begin 
   result:=aInput;
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=TPinja.TValue.From(TPinjaInt64(Trunc(aInput.fFloatValue)));
  end;
  TPinja.TValueKind.vkString:begin
   result:=TPinja.TValue.From(StrToInt64Def(aInput.fStringValue,0));
  end;
  else begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
 end;
end;

function F_batch(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var BatchSize:TPinjaInt32;
    FillWith:TPinja.TValue;
    ItemIndex,ItemCount:TPinjaInt32;
    ResultArray:TPinja.TValue;
    BatchArray:TPinja.TValue;
    BatchIndex:TPinjaInt32;
begin
 // batch(iterable, linecount, fill_with=None)
 if (aInput.Kind<>TPinja.TValueKind.vkArray) or (length(aArgs)=0) then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 BatchSize:=aArgs[0].AsInt64;
 if BatchSize<=0 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 if length(aArgs)>1 then begin
  FillWith:=aArgs[1];
 end else begin
  FillWith:=TPinja.TValue.Null;
 end;
 
 ItemCount:=aInput.Count;
 ResultArray:=TPinja.TValue.NewArray;
 
 ItemIndex:=0;
 while ItemIndex<ItemCount do begin
  BatchArray:=TPinja.TValue.NewArray;
  for BatchIndex:=0 to BatchSize-1 do begin
   if (ItemIndex+BatchIndex)<ItemCount then begin
    BatchArray.Append(aInput.ValueAt(ItemIndex+BatchIndex));
   end else begin
    BatchArray.Append(FillWith);
   end;
  end;
  ResultArray.Append(BatchArray);
  inc(ItemIndex,BatchSize);
 end;
 
 result:=ResultArray;
end;

function F_groupby(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
type TGroup=record
      Key:TPinja.TValue;
      Items:TPinja.TValue;
     end;
     PGroup=^TGroup;
     TGroups=array of TGroup;
var Attribute:TPinjaRawByteString;
    ItemIndex:TPinjaInt32;
    CurrentItem,CurrentValue:TPinja.TValue;
    Groups:TGroups;
    GroupCount:TPinjaInt32;
    GroupIndex:TPinjaInt32;
    Found:Boolean;
    ResultArray:TPinja.TValue;
    GroupArray:TPinja.TValue;
    GroupValue:PGroup;
begin
 // groupby(iterable, attribute)
 if (aInput.Kind<>TPinja.TValueKind.vkArray) or (length(aArgs)=0) then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Attribute:=aArgs[0].AsString;
 GroupCount:=0;
 Groups:=nil;
 try
 
  for ItemIndex:=0 to aInput.Count-1 do begin
   CurrentItem:=aInput.ValueAt(ItemIndex);
   if CurrentItem.Kind=TPinja.TValueKind.vkObject then begin
    if CurrentItem.ObjTryGet(Attribute,CurrentValue) then begin
     // Find existing group
     Found:=false;
     for GroupIndex:=0 to GroupCount-1 do begin
      if Groups[GroupIndex].Key.AsString=CurrentValue.AsString then begin
       Groups[GroupIndex].Items.Append(CurrentItem);
       Found:=true;
       break;
      end;
     end;

     if not Found then begin
      // Create new group
      GroupIndex:=GroupCount;
      inc(GroupCount);
      if length(Groups)<GroupCount then begin
       SetLength(Groups,GroupCount*2);
      end;
      GroupValue:=@Groups[GroupIndex];
      GroupValue^.Key:=CurrentValue;
      GroupValue^.Items:=TPinja.TValue.NewArray;
      GroupValue^.Items.Append(CurrentItem);
     end;
    end;
   end;
  end;

  ResultArray:=TPinja.TValue.NewArray;
  for GroupIndex:=0 to GroupCount-1 do begin
   GroupArray:=TPinja.TValue.NewArray;
   GroupArray.Append(Groups[GroupIndex].Key);
   GroupArray.Append(Groups[GroupIndex].Items);
   ResultArray.Append(GroupArray);
  end;

  result:=ResultArray;

 finally
  Groups:=nil;
 end;

end;

function F_random(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Seed,Value:TPinjaUInt32;
    Index:TPinjaInt32;
begin
 // random(seq) - pick random item from sequence
 if aInput.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.Null;
  exit;
 end;
 
 if aInput.Count=0 then begin
  result:=TPinja.TValue.Null;
  exit;
 end;
 
 // XorShift32 with GetTickCount64 constant XORed seed
 Seed:=TPinjaUInt32(GetTickCount64) xor $12345678;
 Value:=Seed;
 Value:=Value xor (Value shl 13);
 Value:=Value xor (Value shr 17);
 Value:=Value xor (Value shl 5);
 
 Index:=Value mod TPinjaUInt32(aInput.Count);
 result:=aInput.ValueAt(Index);
end;

function F_urlize(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    OutputString:TPinjaRawByteString;
    CharacterIndex:TPinjaInt32;
    InUrl:Boolean;
    UrlStart:TPinjaInt32;
    UrlEnd:TPinjaInt32;
    Url:TPinjaRawByteString;
begin
 // urlize(text) - convert URLs in text to clickable links
 InputString:=aInput.AsString;
 OutputString:='';
 CharacterIndex:=1;
 InUrl:=false;
 
 while CharacterIndex<=length(InputString) do begin
  if not InUrl then begin
   if (CharacterIndex<=(length(InputString)-6)) and (Copy(InputString,CharacterIndex,7)='http://') then begin
    InUrl:=true;
    UrlStart:=CharacterIndex;
   end else if (CharacterIndex<=(length(InputString)-7)) and (Copy(InputString,CharacterIndex,8)='https://') then begin
    InUrl:=true;
    UrlStart:=CharacterIndex;
   end else begin
    OutputString:=OutputString+InputString[CharacterIndex];
   end;
  end else begin
   if InputString[CharacterIndex] in [' ',#9,#10,#13,'"','''','<','>'] then begin
    UrlEnd:=CharacterIndex-1;
    Url:=Copy(InputString,UrlStart,(UrlEnd-UrlStart)+1);
    OutputString:=OutputString+'<a href="'+Url+'">'+Url+'</a>'+InputString[CharacterIndex];
    InUrl:=false;
   end;
  end;
  inc(CharacterIndex);
 end;
 
 if InUrl then begin
  Url:=Copy(InputString,UrlStart,(length(InputString)-UrlStart)+1);
  OutputString:=OutputString+'<a href="'+Url+'">'+Url+'</a>';
 end;
 
 result:=TPinja.TValue.From(OutputString);
end;

function F_pprint(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 // pprint(value) - pretty print value (use JSON representation)
 result:=TPinja.TValue.From(aInput.ToJSONString);
end;

function F_striptags(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var InputString:TPinjaRawByteString;
    OutputString:TPinjaRawByteString;
    CharacterIndex:TPinjaInt32;
    InTag:Boolean;
begin
 // striptags(s) - strip HTML/XML tags from string
 InputString:=aInput.AsString;
 OutputString:='';
 InTag:=false;
 
 for CharacterIndex:=1 to length(InputString) do begin
  if InputString[CharacterIndex]='<' then begin
   InTag:=true;
  end else if InputString[CharacterIndex]='>' then begin
   InTag:=false;
  end else if not InTag then begin
   OutputString:=OutputString+InputString[CharacterIndex];
  end;
 end;
 
 result:=TPinja.TValue.From(OutputString);
end;

function F_xmlattr(const aInput:TPinja.TValue;const aArgs:array of TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var AttributeIndex:TPinjaInt32;
    AttributeName:TPinjaRawByteString;
    AttributeValue:TPinja.TValue;
    OutputString:TPinjaRawByteString;
    ValueString:TPinjaRawByteString;
    CharacterIndex:TPinjaInt32;
    EscapedValue:TPinjaRawByteString;
begin
 // xmlattr(d) - create XML attribute string from dict
 if aInput.Kind<>TPinja.TValueKind.vkObject then begin
  result:=TPinja.TValue.From('');
  exit;
 end;
 
 OutputString:='';
 for AttributeIndex:=0 to aInput.Count-1 do begin
  AttributeName:=aInput.NameAt(AttributeIndex);
  AttributeValue:=aInput.ValueAt(AttributeIndex);
  ValueString:=AttributeValue.AsString;
  
  // Escape XML attribute value
  EscapedValue:='';
  for CharacterIndex:=1 to length(ValueString) do begin
   case ValueString[CharacterIndex] of
    '&':begin
     EscapedValue:=EscapedValue+'&amp;';
    end;
    '<':begin
     EscapedValue:=EscapedValue+'&lt;';
    end;
    '>':begin
     EscapedValue:=EscapedValue+'&gt;';
    end;
    '"':begin
     EscapedValue:=EscapedValue+'&quot;';
    end;
    '''':begin
     EscapedValue:=EscapedValue+'&#x27;';
    end;
    else begin
     EscapedValue:=EscapedValue+ValueString[CharacterIndex];
    end;
   end;
  end;
  
  if OutputString<>'' then begin
   OutputString:=OutputString+' ';
  end;
  OutputString:=OutputString+AttributeName+'="'+EscapedValue+'"';
 end;
 
 result:=TPinja.TValue.From(OutputString);
end;

procedure TPinja.TContext.RegisterDefaultFilters;
begin
 RegisterFilter('upper',@F_upper);
 RegisterFilter('lower',@F_lower);
 RegisterFilter('trim',@F_trim);
 RegisterFilter('length',@F_length);
 RegisterFilter('join',@F_join);
 RegisterFilter('default',@F_default);
 RegisterFilter('escape',@F_escape);
 RegisterFilter('e',@F_escape);
 RegisterFilter('to_json',@F_to_json);
 RegisterFilter('str',@F_str);
 RegisterFilter('string',@F_str);
 RegisterFilter('strip',@F_strip);
 RegisterFilter('replace',@F_replace);
 RegisterFilter('startswith',@F_startswith);
 RegisterFilter('endswith',@F_endswith);
 RegisterFilter('capitalize',@F_capitalize);
 RegisterFilter('count',@F_count);
 RegisterFilter('first',@F_first);
 RegisterFilter('last',@F_last);
 RegisterFilter('safe',@F_safe);
 RegisterFilter('unique',@F_unique);
 RegisterFilter('dictsort',@F_dictsort);
 RegisterFilter('indent',@F_indent);
 RegisterFilter('title',@F_title);
 RegisterFilter('reverse',@F_reverse);
 RegisterFilter('round',@F_round);
 RegisterFilter('sort',@F_sort);
 RegisterFilter('slice',@F_slice);
 RegisterFilter('center',@F_center);
 RegisterFilter('truncate',@F_truncate);
 RegisterFilter('wordcount',@F_wordcount);
 RegisterFilter('format',@F_format);
 RegisterFilter('list',@F_list);
 RegisterFilter('int',@F_int);
 RegisterFilter('batch',@F_batch);
 RegisterFilter('groupby',@F_groupby);
 RegisterFilter('random',@F_random);
 RegisterFilter('urlize',@F_urlize);
 RegisterFilter('pprint',@F_pprint);
 RegisterFilter('striptags',@F_striptags);
 RegisterFilter('xmlattr',@F_xmlattr);
end;

// Default callables 

function C_len(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 case ValuePtr^.Kind of
  TPinja.TValueKind.vkNull:begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
  TPinja.TValueKind.vkString:begin
   result:=TPinja.TValue.From(TPinjaInt64(Length(ValuePtr^.fStringValue)));
  end;
  TPinja.TValueKind.vkArray:begin
   result:=TPinja.TValue.From(TPinjaInt64(ValuePtr^.Count));
  end;
  TPinja.TValueKind.vkObject:begin
   result:=TPinja.TValue.From(TPinjaInt64(ValuePtr^.Count));
  end;
  else begin
   result:=TPinja.TValue.From(TPinjaInt64(1));
  end;
 end; 
end;

function C_int(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
    FloatValue:TPinjaDouble;
    IntegerValue:TPinjaInt64;
    ErrorCode:TPinjaInt32;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 case ValuePtr^.Kind of
  TPinja.TValueKind.vkNull:begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
  TPinja.TValueKind.vkBool:begin
   result:=TPinja.TValue.From(TPinjaInt64(Ord(ValuePtr^.fBooleanValue) and 1));
  end;
  TPinja.TValueKind.vkInt:begin
   result:=ValuePtr^;
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=TPinja.TValue.From(TPinjaInt64(Trunc(ValuePtr^.fFloatValue)));
  end;
  TPinja.TValueKind.vkString:begin
   Val(ValuePtr^.fStringValue,IntegerValue,ErrorCode);
   if ErrorCode=0 then begin
    result:=TPinja.TValue.From(IntegerValue);
   end else begin
    Val(ValuePtr^.fStringValue,FloatValue,ErrorCode);
    if ErrorCode=0 then begin
     result:=TPinja.TValue.From(FloatValue);
    end else begin
     result:=TPinja.TValue.From(TPinjaInt64(0));
    end;
   end;
  end;
  else begin
   result:=TPinja.TValue.From(TPinjaInt64(0));
  end;
 end; 
end;

function C_float(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 case ValuePtr^.Kind of
  TPinja.TValueKind.vkNull:begin
   result:=TPinja.TValue.From(0.0);
  end;
  TPinja.TValueKind.vkBool:begin
   if ValuePtr^.fBooleanValue then begin
    result:=TPinja.TValue.From(1.0);
   end else begin
    result:=TPinja.TValue.From(0.0);
   end;
  end;
  TPinja.TValueKind.vkInt:begin 
   result:=TPinja.TValue.From(ValuePtr^.fIntegerValue*1.0);
  end;
  TPinja.TValueKind.vkFloat:begin
   result:=ValuePtr^;
  end;
  TPinja.TValueKind.vkString:begin
   result:=TPinja.TValue.From(ConvertStringToFloat(ValuePtr^.fStringValue));
  end;
  else begin
   result:=TPinja.TValue.From(0.0);
  end;
 end;
end;

function C_str(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 result:=TPinja.TValue.From(ValuePtr.AsString);
end;

function C_abs(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 case ValuePtr^.Kind of
  TPinja.TValueKind.vkInt:begin
   if ValuePtr^.fIntegerValue<0 then begin
    result:=TPinja.TValue.From(-ValuePtr^.fIntegerValue);
   end else begin
    result:=ValuePtr^;
   end;
  end;
  TPinja.TValueKind.vkFloat:begin
   if ValuePtr^.fFloatValue<0 then begin
    result:=TPinja.TValue.From(-ValuePtr^.fFloatValue);
   end else begin
    result:=ValuePtr^;
   end;
  end;
  TPinja.TValueKind.vkBool:begin
   if ValuePtr^.fBooleanValue then begin
    result:=TPinja.TValue.From(TPinjaInt64(1));
   end else begin
    result:=TPinja.TValue.From(TPinjaInt64(0));
   end;
  end;
  else begin
   result:=TPinja.TValue.From(ValuePtr^.AsString); // fallback
  end;
 end; 
end;

function C_sum(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
    ElementPtr:TPinja.PValue;
    Index:TPinjaInt32;
    Accumulator:TPinjaDouble;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 Accumulator:=0.0;
 if ValuePtr^.Kind=TPinja.TValueKind.vkArray then begin
  ArrayObject:=ValuePtr^.fArrayObject.GetArrayObject;
  for Index:=0 to ArrayObject.fCount-1 do begin
   ElementPtr:=@ArrayObject.fValues[Index];
   if ElementPtr^.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat] then begin
    Accumulator:=Accumulator+ElementPtr^.fFloatValue;
   end; 
  end;
  result:=TPinja.TValue.From(Accumulator);
 end else if ValuePtr^.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat] then begin
  result:=ValuePtr^;
 end else begin
  result:=TPinja.TValue.From(0.0);
 end;
end;

function C_min(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr,ElementPtr,BestPtr:TPinja.PValue;
    Index:TPinjaInt32;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 if ValuePtr^.Kind=TPinja.TValueKind.vkArray then begin
  ArrayObject:=ValuePtr^.fArrayObject.GetArrayObject;
  if ArrayObject.fCount=0 then begin
   result:=TPinja.TValue.Null;
   exit;
  end;
  BestPtr:=@ArrayObject.fValues[0];
  for Index:=1 to ArrayObject.fCount-1 do begin
   ElementPtr:=@ArrayObject.fValues[Index];
   if ElementPtr^<BestPtr^ then begin
    BestPtr:=ElementPtr;
   end;
  end;
  result:=BestPtr^;
 end else if Length(aPos)>1 then begin
  BestPtr:=@aPos[0];
  for Index:=1 to Length(aPos)-1 do begin
   if aPos[Index]<BestPtr^ then begin
    BestPtr:=@aPos[Index];
   end; 
  end;
  result:=BestPtr^;
 end else begin
  result:=ValuePtr^;
 end;
end;

function C_max(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr,ElementPtr,BestPtr:TPinja.PValue;
    Index:TPinjaInt32;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 if ValuePtr^.Kind=TPinja.TValueKind.vkArray then begin
  ArrayObject:=ValuePtr^.fArrayObject.GetArrayObject;
  if ArrayObject.fCount=0 then begin
   result:=TPinja.TValue.Null;
   exit;
  end;
  BestPtr:=@ArrayObject.fValues[0];
  for Index:=1 to ArrayObject.fCount-1 do begin
   ElementPtr:=@ArrayObject.fValues[Index];
   if ElementPtr^>BestPtr^ then begin
    BestPtr:=ElementPtr;
   end;
  end;
  result:=BestPtr^;
 end else if Length(aPos)>1 then begin
  BestPtr:=@aPos[0];
  for Index:=1 to Length(aPos)-1 do begin
   if aPos[Index]>BestPtr^ then begin
    BestPtr:=@aPos[Index];
   end;
  end;
  result:=BestPtr^;
 end else begin
  result:=ValuePtr^;
 end;
end;

function C_keys(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr,ResultPtr:TPinja.PValue;
    Index,Count:TPinjaInt32;
    ResultValue:TPinja.TValue;
    ResultArray,ObjectValue:TPinja.TValue.TArrayObject;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;

 ResultValue:=TPinja.TValue.NewArray;
 ResultPtr:=@ResultValue;

 if ValuePtr^.Kind=TPinja.TValueKind.vkObject then begin
  ResultArray:=ResultPtr^.fArrayObject.GetArrayObject;
  ObjectValue:=ValuePtr^.fArrayObject.GetArrayObject;
  Count:=ObjectValue.fCount;
  SetLength(ResultArray.fValues,Count);
  ResultArray.fCount:=Count;
  for Index:=0 to Count-1 do begin
   ResultArray.fValues[Index]:=TPinja.TValue.From(ObjectValue.fKeys[Index]);
  end; 
 end; 

 result:=ResultValue;

end;

function C_values(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr,ResultPtr:TPinja.PValue;
    Index,Count:TPinjaInt32;
    ResultValue:TPinja.TValue;
    ResultArray,ObjectValue:TPinja.TValue.TArrayObject;
begin

 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;

 ResultValue:=TPinja.TValue.NewArray;
 ResultPtr:=@ResultValue;

 if ValuePtr^.Kind=TPinja.TValueKind.vkObject then begin
  ResultArray:=ResultPtr^.fArrayObject.GetArrayObject;
  ObjectValue:=ValuePtr^.fArrayObject.GetArrayObject;
  Count:=ObjectValue.fCount;
  SetLength(ResultArray.fValues,Count);
  ResultArray.fCount:=Count;
  for Index:=0 to Count-1 do begin
   ResultArray.fValues[Index]:=ObjectValue.fValues[Index];
  end;
 end;

 result:=ResultValue;

end;

function C_items(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr,ResultPtr,PairPtr:TPinja.PValue;
    Index,Count:TPinjaInt32;
    ResultValue,PairValue:TPinja.TValue;
    ResultArray,ObjectValue,PairArray:TPinja.TValue.TArrayObject;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;

 ResultValue:=TPinja.TValue.NewArray;
 ResultPtr:=@ResultValue;

 if ValuePtr^.Kind=TPinja.TValueKind.vkObject then begin
  ResultArray:=ResultPtr^.fArrayObject.GetArrayObject;
  ObjectValue:=ValuePtr^.fArrayObject.GetArrayObject;
  Count:=ObjectValue.fCount;
  SetLength(ResultArray.fValues,Count);
  ResultArray.fCount:=Count;
  for Index:=0 to Count-1 do begin
   PairValue:=TPinja.TValue.NewArray;
   PairPtr:=@PairValue;
   PairArray:=PairPtr^.fArrayObject.GetArrayObject;
   // key
   SetLength(PairArray.fValues,2);
   PairArray.fCount:=2;
   PairArray.fValues[0]:=TPinja.TValue.From(ObjectValue.fKeys[Index]);
   // value (shallow copy)
   PairArray.fValues[1]:=ObjectValue.fValues[Index];
   ResultArray.fValues[Index]:=PairValue;
  end;
 end;

 result:=ResultValue;

end;

function C_range(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var StartValue,EndValue,StepValue,Count64,CurrentValue:TPinjaInt64;
   ResultValue:TPinja.TValue;
   ResultPtr:TPinja.PValue;
   CountValue,Index:TPinjaInt32;
   ArrayObject:TPinja.TValue.TArrayObject;
begin

 if (length(aPos)<2) or (length(aPos)>3) then begin
  raise Exception.Create('range expects 2 or 3 positional args');
 end;

 StartValue:=aPos[0].AsInt64;
 EndValue:=aPos[1].AsInt64;
 if length(aPos)=3 then begin
  StepValue:=aPos[2].AsInt64;
 end else begin
  StepValue:=1;
 end;

 if StepValue=0 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;

 ResultValue:=TPinja.TValue.NewArray;
 ResultPtr:=@ResultValue;

 if StepValue>0 then begin
  if StartValue<EndValue then begin
   Count64:=(((EndValue-StartValue)+StepValue)-1) div StepValue;
  end else begin
   Count64:=0;
  end;
 end else begin
  if StartValue>EndValue then begin
   Count64:=(((StartValue-EndValue)-StepValue)-1) div (-StepValue);
  end else begin
   Count64:=0;
  end;
 end;
 
 if Count64<0 then begin
  CountValue:=0;
 end else if Count64>High(TPinjaInt32) then begin
  CountValue:=High(TPinjaInt32);
 end else begin
  CountValue:=TPinjaInt32(Count64);
 end;

 ArrayObject:=ResultPtr^.fArrayObject.GetArrayObject;
 SetLength(ArrayObject.fValues,CountValue);
 ArrayObject.fCount:=CountValue;

 CurrentValue:=StartValue;
 for Index:=0 to CountValue-1 do begin
  ArrayObject.fValues[Index]:=TPinja.TValue.From(CurrentValue);
  inc(CurrentValue,StepValue);
 end;

 result:=ResultValue;

end;

function C_bool(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 result:=TPinja.TValue.From(ValuePtr^.IsTruthy);
end;

function C_list(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
    Index:TPinjaInt32;
    ArrayObject,SrcArrayObject:TPinja.TValue.TArrayObject;
    StringValue:TPinjaRawByteString;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 
 result:=TPinja.TValue.NewArray;
 ArrayObject:=result.fArrayObject.GetArrayObject;
 
 case ValuePtr^.Kind of
  TPinja.TValueKind.vkArray:begin
   // Copy array
   SrcArrayObject:=ValuePtr^.fArrayObject.GetArrayObject;
   SetLength(ArrayObject.fValues,SrcArrayObject.fCount);
   ArrayObject.fCount:=SrcArrayObject.fCount;
   for Index:=0 to SrcArrayObject.fCount-1 do begin
    ArrayObject.fValues[Index]:=SrcArrayObject.fValues[Index];
   end;
  end;
  TPinja.TValueKind.vkString:begin
   // Convert string to array of characters
   StringValue:=ValuePtr^.AsString;
   SetLength(ArrayObject.fValues,Length(StringValue));
   ArrayObject.fCount:=Length(StringValue);
   for Index:=1 to Length(StringValue) do begin
    ArrayObject.fValues[Index-1]:=TPinja.TValue.From(TPinjaRawByteString(StringValue[Index]));
   end;
  end;
  else begin
   // Single item
   SetLength(ArrayObject.fValues,1);
   ArrayObject.fCount:=1;
   ArrayObject.fValues[0]:=ValuePtr^;
  end;
 end;
end;

function C_namespace(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ArrayObject:TPinja.TValue.TArrayObject;
    Index:TPinjaInt32;
    KeyName:TPinjaRawByteString;
    KeyValue:TPinja.TValue;
begin
 // Create a new object (namespace)
 result:=TPinja.TValue.NewObject;
 
 // Add keyword arguments as properties
 if aKw.Kind=TPinja.TValueKind.vkObject then begin
  // Get the array object to access the keys and values
  ArrayObject:=aKw.fArrayObject.GetArrayObject;
  
  for Index:=0 to ArrayObject.Count-1 do begin
   KeyName:=ArrayObject.NameAt(Index);
   if ArrayObject.ValueAt(Index,KeyValue) then begin
    result.ObjSet(KeyName,KeyValue);
   end;
  end;
 end;
end;

function C_raise_exception(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Message:TPinjaRawByteString;
begin
 if length(aPos)>0 then begin
  Message:=aPos[0].AsString;
 end else begin
  Message:='Exception raised';
 end;
 result:=TPinja.TValue.From(nil); // This line will never be reached due to exception
 raise Exception.Create(Message);
end;

function C_tojson(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var ValuePtr:TPinja.PValue;
    JSONItem:TPasJSONItem;
begin
 if length(aPos)>0 then begin
  ValuePtr:=@aPos[0];
 end else begin
  ValuePtr:=@aSelf;
 end;
 
 JSONItem:=ValuePtr^.ToJSON;
 try
  result:=TPinja.TValue.From(TPasJSON.Stringify(JSONItem));
 finally
  JSONItem.Free;
 end;
end;

function C_equalto(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
begin
 if length(aPos)>=2 then begin
  result:=TPinja.TValue.From(aPos[0]=aPos[1]);
 end else if length(aPos)=1 then begin
  result:=TPinja.TValue.From(aSelf=aPos[0]);
 end else begin
  result:=TPinja.TValue.From(false);
 end;
end;

function C_in(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Item,Container:TPinja.TValue;
    Index:TPinjaInt32;
    Found:Boolean;
    ContainerString,ItemString:TPinjaRawByteString;
begin
 if length(aPos)>=2 then begin
  Item:=aPos[0];
  Container:=aPos[1];
 end else if length(aPos)=1 then begin
  Item:=aSelf;
  Container:=aPos[0];
 end else begin
  result:=TPinja.TValue.From(false);
  exit;
 end;
 
 Found:=false;
 case Container.Kind of
  TPinja.TValueKind.vkArray:begin
   for Index:=0 to Container.Count-1 do begin
    if Item=Container.ValueAt(Index) then begin
     Found:=true;
     break;
    end;
   end;
  end;
  TPinja.TValueKind.vkObject:begin
   Found:=Container.ObjTryGet(Item.AsString,Container);
  end;
  TPinja.TValueKind.vkString:begin
   ContainerString:=Container.AsString;
   ItemString:=Item.AsString;
   Found:=Pos(ItemString,ContainerString)>0;
  end;
 end;
 
 result:=TPinja.TValue.From(Found);
end;

function C_select(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Items:TPinja.TValue;
    FilterName:TPinjaRawByteString;
    FilterCallable:TPinja.TCallable;
    ItemIndex:TPinjaInt32;
    CurrentItem:TPinja.TValue;
    FilterResult:TPinja.TValue;
    ResultArray:TPinja.TValue.TArrayObject;
begin
 if length(aPos)<2 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Items:=aPos[0];
 FilterName:=aPos[1].AsString;
 
 if Items.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 if not aContext.TryGetCallable(FilterName,FilterCallable) then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 result:=TPinja.TValue.NewArray;
 try
  ResultArray:=result.fArrayObject.GetArrayObject;
  
  for ItemIndex:=0 to Items.Count-1 do begin
   CurrentItem:=Items.ValueAt(ItemIndex);
   FilterResult:=FilterCallable(CurrentItem,[CurrentItem],aKw,aContext);
   if FilterResult.IsTruthy then begin
    ResultArray.Append(CurrentItem);
   end;
  end;
 except
  result.Clear;
  raise;
 end;
end;

function C_reject(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Items:TPinja.TValue;
    FilterName:TPinjaRawByteString;
    FilterCallable:TPinja.TCallable;
    ItemIndex:TPinjaInt32;
    CurrentItem:TPinja.TValue;
    FilterResult:TPinja.TValue;
    ResultArray:TPinja.TValue.TArrayObject;
begin
 if length(aPos)<2 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Items:=aPos[0];
 FilterName:=aPos[1].AsString;
 
 if Items.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 if not aContext.TryGetCallable(FilterName,FilterCallable) then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 result:=TPinja.TValue.NewArray;
 try
  ResultArray:=result.fArrayObject.GetArrayObject;
  
  for ItemIndex:=0 to Items.Count-1 do begin
   CurrentItem:=Items.ValueAt(ItemIndex);
   FilterResult:=FilterCallable(CurrentItem,[CurrentItem],aKw,aContext);
   if not FilterResult.IsTruthy then begin
    ResultArray.Append(CurrentItem);
   end;
  end;
 except
  result.Clear;
  raise;
 end;
end;

function C_map(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Items:TPinja.TValue;
    FilterName:TPinjaRawByteString;
    FilterCallable:TPinja.TCallable;
    ItemIndex:TPinjaInt32;
    CurrentItem:TPinja.TValue;
    MappedResult:TPinja.TValue;
    ResultArray:TPinja.TValue.TArrayObject;
begin
 if length(aPos)<2 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Items:=aPos[0];
 FilterName:=aPos[1].AsString;
 
 if Items.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 if not aContext.TryGetCallable(FilterName,FilterCallable) then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 result:=TPinja.TValue.NewArray;
 try
  ResultArray:=result.fArrayObject.GetArrayObject;
  
  for ItemIndex:=0 to Items.Count-1 do begin
   CurrentItem:=Items.ValueAt(ItemIndex);
   MappedResult:=FilterCallable(CurrentItem,[CurrentItem],aKw,aContext);
   ResultArray.Append(MappedResult);
  end;
 except
  result.Clear;
  raise;
 end;
end;

function C_selectattr(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Items:TPinja.TValue;
    AttributeName:TPinjaRawByteString;
    TestName:TPinjaRawByteString;
    TestCallable:TPinja.TCallable;
    ItemIndex:TPinjaInt32;
    CurrentItem:TPinja.TValue;
    AttributeValue:TPinja.TValue;
    TestResult:TPinja.TValue;
    ResultArray:TPinja.TValue.TArrayObject;
    HasTest:Boolean;
begin
 if length(aPos)<2 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Items:=aPos[0];
 AttributeName:=aPos[1].AsString;
 
 if Items.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 HasTest:=false;
 if length(aPos)>=3 then begin
  TestName:=aPos[2].AsString;
  HasTest:=aContext.TryGetCallable(TestName,TestCallable);
 end;
 
 result:=TPinja.TValue.NewArray;
 try
  ResultArray:=result.fArrayObject.GetArrayObject;
  
  for ItemIndex:=0 to Items.Count-1 do begin
   CurrentItem:=Items.ValueAt(ItemIndex);
   if CurrentItem.ObjTryGet(AttributeName,AttributeValue) then begin
    if HasTest then begin
     TestResult:=TestCallable(AttributeValue,[AttributeValue],aKw,aContext);
     if TestResult.IsTruthy then begin
      ResultArray.Append(CurrentItem);
     end;
    end else begin
     if AttributeValue.IsTruthy then begin
      ResultArray.Append(CurrentItem);
     end;
    end;
   end;
  end;
 except
  result.Clear;
  raise;
 end;
end;

function C_rejectattr(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Items:TPinja.TValue;
    AttributeName:TPinjaRawByteString;
    TestName:TPinjaRawByteString;
    TestCallable:TPinja.TCallable;
    ItemIndex:TPinjaInt32;
    CurrentItem:TPinja.TValue;
    AttributeValue:TPinja.TValue;
    TestResult:TPinja.TValue;
    ResultArray:TPinja.TValue.TArrayObject;
    HasTest:Boolean;
begin
 if length(aPos)<2 then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 Items:=aPos[0];
 AttributeName:=aPos[1].AsString;
 
 if Items.Kind<>TPinja.TValueKind.vkArray then begin
  result:=TPinja.TValue.NewArray;
  exit;
 end;
 
 HasTest:=false;
 if length(aPos)>=3 then begin
  TestName:=aPos[2].AsString;
  HasTest:=aContext.TryGetCallable(TestName,TestCallable);
 end;
 
 result:=TPinja.TValue.NewArray;
 try
  ResultArray:=result.fArrayObject.GetArrayObject;
  
  for ItemIndex:=0 to Items.Count-1 do begin
   CurrentItem:=Items.ValueAt(ItemIndex);
   if CurrentItem.ObjTryGet(AttributeName,AttributeValue) then begin
    if HasTest then begin
     TestResult:=TestCallable(AttributeValue,[AttributeValue],aKw,aContext);
     if not TestResult.IsTruthy then begin
      ResultArray.Append(CurrentItem);
     end;
    end else begin
     if not AttributeValue.IsTruthy then begin
      ResultArray.Append(CurrentItem);
     end;
    end;
   end;
  end;
 except
  result.Clear;
  raise;
 end;
end;

constructor TPinja.TJoinerCallable.Create(const aSeparator:TPinjaRawByteString);
begin
 inherited Create;
 fSeparator:=aSeparator;
 fFirstCall:=true;
end;

function TPinja.TJoinerCallable.Call(const aSelfValue:TPinja.TValue;const aPosArgs:array of TPinja.TValue;var aKwArgs:TPinja.TValue;const aCtx:TPinja.TContext):TPinja.TValue;
begin
 if fFirstCall then begin
  fFirstCall:=false;
  result:=TPinja.TValue.From(''); // Return empty string on first call
 end else begin
  result:=TPinja.TValue.From(fSeparator); // Return separator on subsequent calls
 end;
end;

function C_joiner(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var Separator:TPinjaRawByteString;
    JoinerObj:TPinja.ICallableObject;
begin
 if length(aPos)>0 then begin
  Separator:=aPos[0].AsString;
 end else begin
  Separator:='';
 end;
 
 try
  JoinerObj:=TPinja.TJoinerCallable.Create(Separator);
  result:=TPinja.TValue.FromCallableObject(JoinerObj);
 except
  result:=TPinja.TValue.From('');
 end;

end;

procedure TPinja.TContext.RegisterDefaultCallables;
begin
 RegisterCallable('len',@C_len);
 RegisterCallable('int',@C_int);
 RegisterCallable('float',@C_float);
 RegisterCallable('str',@C_str);
 RegisterCallable('abs',@C_abs);
 RegisterCallable('min',@C_min);
 RegisterCallable('max',@C_max);
 RegisterCallable('sum',@C_sum);
 RegisterCallable('keys',@C_keys);
 RegisterCallable('values',@C_values);
 RegisterCallable('items',@C_items);
 RegisterCallable('range',@C_range);
 RegisterCallable('bool',@C_bool);
 RegisterCallable('list',@C_list);
 RegisterCallable('namespace',@C_namespace);
 RegisterCallable('raise_exception',@C_raise_exception);
 RegisterCallable('tojson',@C_tojson);
 RegisterCallable('equalto',@C_equalto);
 RegisterCallable('in',@C_in);
 RegisterCallable('select',@C_select);
 RegisterCallable('reject',@C_reject);
 RegisterCallable('map',@C_map);
 RegisterCallable('selectattr',@C_selectattr);
 RegisterCallable('rejectattr',@C_rejectattr);
 RegisterCallable('joiner',@C_joiner);
end;

//==============================================================================
// TLexer                                                                        
//==============================================================================

{ TPinja.TLexer }

constructor TPinja.TLexer.Create(const aString:TPinjaRawByteString);
begin
 inherited Create;
 fSource:=aString;
 fPosition:=1;
 fLength:=Length(fSource);
 Next;
end;

function TPinja.TLexer.Peek:AnsiChar;
begin
 if fPosition<=fLength then begin
  result:=fSource[fPosition];
 end else begin
  result:=#0;
 end;
end;

function TPinja.TLexer.NextChar:AnsiChar;
begin
 if fPosition<=fLength then begin 
  result:=fSource[fPosition];
  inc(fPosition); 
 end else begin
  result:=#0;
 end; 
end;

function TPinja.TLexer.EOF:Boolean;
begin
 result:=fPosition>fLength;
end;

class function TPinja.TLexer.IsIdentStart(aCharacter:AnsiChar):Boolean;
begin
 result:=(aCharacter='_') or (aCharacter in ['A'..'Z','a'..'z']) or (TPinjaUInt8(aCharacter)>=$80);
end;

class function TPinja.TLexer.IsIdentChar(aCharacter:AnsiChar):Boolean;
begin
 result:=IsIdentStart(aCharacter) or (aCharacter in ['0'..'9']);
end;

function TPinja.TLexer.ParseIdentifier:TPinjaRawByteString;
begin
 fToken:='';
 while IsIdentChar(Peek) do begin
  fToken:=fToken+NextChar;
 end;
 result:=fToken;
end;

function TPinja.TLexer.ParseStringLiteral:TPinjaRawByteString;
var QuoteChar,CurrentChar:AnsiChar;
begin
 result:='';
 QuoteChar:=NextChar; // opening quote
 while not EOF do begin
  CurrentChar:=NextChar;
  if CurrentChar=QuoteChar then begin
   break;
  end else if CurrentChar='\' then begin
   CurrentChar:=NextChar;
   case CurrentChar of
    'n':begin
     result:=result+#10;
    end;
    'r':begin
     result:=result+#13;
    end;
    't':begin
     result:=result+#9;
    end;
    '"':begin
     result:=result+'"';
    end;
    '''':begin
     result:=result+'''';
    end;
    '\':begin
     result:=result+'\';
    end;
    else begin
     result:=result+CurrentChar;
    end;
   end;
  end else begin
   result:=result+CurrentChar;
  end;
 end;
end;

function TPinja.TLexer.ParseNumber(out aIsFloat:Boolean;out aInteger:TPinjaInt64;out aFloat:TPinjaDouble):Boolean;
var StartPosition:TPinjaInt32;
    hasDot,hasExp:Boolean;
    NumberString:TPinjaRawByteString;
    ErrorCode:TPinjaInt32;
    CurrentChar:AnsiChar;
begin

 result:=false;
 
 aIsFloat:=false;
 aInteger:=0;
 aFloat:=0.0;

 if not (Peek in ['0'..'9']) then begin 
  exit;     // no leading sign here
 end;

 StartPosition:=fPosition;
 hasDot:=false;
 hasExp:=false;

 while not EOF do begin
  CurrentChar:=Peek;
  if CurrentChar in ['0'..'9'] then begin
   NextChar;
  end else if (CurrentChar = '.') and not (hasDot or hasExp) then begin 
   hasDot:=true; 
   NextChar; 
  end else if (CurrentChar in ['e','E']) and not hasExp then begin
   hasExp:=true;
   NextChar;
   if Peek in ['+','-'] then begin
    NextChar;    // sign only allowed after e/E
   end;
   if not (Peek in ['0'..'9']) then begin 
    break;
   end;
  end else begin 
   break;
  end;
 end;

 NumberString:=Copy(fSource,StartPosition,fPosition-StartPosition);
 aIsFloat:=hasDot or hasExp;

 if aIsFloat then begin
  result:=ParseFloat(NumberString,aFloat);
  if result then begin
   aInteger:=Trunc(aFloat);
  end;
 end else begin
  Val(NumberString,aInteger,ErrorCode);
  result:=ErrorCode=0;
  aFloat:=aInteger;
 end;

end;

// Check if the next token is an assignment operator (e.g., '=' but not '==') 
function TPinja.TLexer.NextIsAssign:Boolean;
var Position:TPinjaInt32;
    Character:AnsiChar;
begin
 Position:=fPosition;
 while (Position<=fLength) and (fSource[Position]<=#32) do begin
  inc(Position);
 end;
 if Position>fLength then begin
  result:=false;
  exit;
 end;
 Character:=fSource[Position];
 if Character<>'=' then  begin
  result:=false;
  exit;
 end;
 if (Position<fLength) and (fSource[Position+1]='=') then  begin
  result:=false;
  exit;
 end;
 result:=true;
end;

procedure TPinja.TLexer.Next;
var CurrentChar:AnsiChar;
    SavePosition:TPinjaInt32;
    IsFloatValue:Boolean;
    IntegerValue:TPinjaInt64;
    FloatValue:TPinjaDouble;

 procedure SkipWhiteSpace;
 var WhitespaceChar:AnsiChar;
 begin
  while fPosition<=fLength do begin
   WhitespaceChar:=Peek;
   if WhitespaceChar in [#0..#32] then begin
    NextChar;
   end else begin
    break;
   end;
  end;
 end;

 function NextIsWord(const aWord:TPinjaRawByteString;var aEndPos:TPinjaInt32):Boolean;
 var CharIndex,StartPosition:TPinjaInt32;
 begin
  StartPosition:=fPosition;
  CharIndex:=1;
  while (StartPosition<=fLength) and (fSource[StartPosition]<=#32) do begin
   inc(StartPosition);
  end;
  aEndPos:=StartPosition;
  while (aEndPos<=fLength) and (CharIndex<=Length(aWord)) and (fSource[aEndPos]=aWord[CharIndex]) do begin
   inc(aEndPos);
   inc(CharIndex);
  end;
  if (CharIndex-1)=length(aWord) then begin
   // ensure word boundary
   if (aEndPos>fLength) or not IsIdentChar(fSource[aEndPos]) then begin
    result:=true;
    exit;
   end;
  end;
  result:=false;
 end;

var EndPosition:TPinjaInt32;
begin

 // Whitespace 
 SkipWhiteSpace;

 if EOF then begin 
  fKind:=TPinja.TLexer.TTokenKind.tkEOF; 
  fToken:='';
  exit; 
 end;

 // Number? — allow leading + or - if followed by digits 
 SavePosition:=fPosition;
 if ParseNumber(IsFloatValue,IntegerValue,FloatValue) then begin
  fKind:=TPinja.TLexer.TTokenKind.tkNumber;
  if IsFloatValue then begin
   fToken:=ConvertFloatToString(FloatValue);
  end else begin
   fToken:=IntToStr(IntegerValue);
  end;
  exit;
 end else begin
  fPosition:=SavePosition; // rewind
 end;

 CurrentChar:=Peek;
 case CurrentChar of
  '(':begin 
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkLParen;   
   fToken:='(';
   exit; 
  end;
  ')':begin 
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkRParen;
   fToken:=')';
   exit; 
  end;
  '[':begin 
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkLBracket; 
   fToken:='['; 
   exit; 
  end;
  ']':begin 
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkRBracket; 
   fToken:=']'; 
   exit; 
  end;
  '{':begin
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkLBrace;   
   fToken:='{'; 
   exit; 
  end;
  '}':begin
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkRBrace;   
   fToken:='}'; 
   exit; 
  end;
  ',':begin
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkComma;  
   fToken:=','; 
   exit; 
  end;
  ':':begin
   NextChar; 
   fKind:=TPinja.TLexer.TTokenKind.tkColon;
   fToken:=':'; 
   exit; 
  end;
  '.':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkDot;
   fToken:='.'; 
   exit; 
  end;
  '|':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkPipe;
   fToken:='|';
   exit;
  end;
  '+':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkPlus;
   fToken:='+';
   exit;
  end;
  '-':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkMinus;
   fToken:='-';
   exit;
  end;
  '~':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkTilde;
   fToken:='~';
   exit;
  end;
  '&':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkAmp;
   fToken:='&';
   exit;
  end;
  '^':begin
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkCaret;
   fToken:='^';
   exit;
  end;
  '*':begin
   NextChar;
   if Peek='*' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkPow;
    fToken:='**';
    exit;
   end
   else begin
    fKind:=TPinja.TLexer.TTokenKind.tkStar;
    fToken:='*';
    exit;
   end;
  end;
  '/':begin
   NextChar;
   if Peek='/' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkFloorDiv; 
    fToken:='//'; 
    exit;
   end else begin
    fKind:=TPinja.TLexer.TTokenKind.tkSlash; 
    fToken:='/'; 
    exit;
   end;
  end;
  '%':begin 
   NextChar;
   fKind:=TPinja.TLexer.TTokenKind.tkPercent;
   fToken:='%'; 
   exit; 
  end;
  '<':begin
   NextChar;
   CurrentChar:=Peek;
   if CurrentChar='<' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkShl;
    fToken:='<<';
    exit;
   end else if CurrentChar='=' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkLe;
    fToken:='<='; 
    exit;
   end else begin 
    fKind:=TPinja.TLexer.TTokenKind.tkLt; 
    fToken:='<'; 
    exit; 
   end;
  end;
  '>':begin
   NextChar;
   CurrentChar:=Peek;
   if CurrentChar='>' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkShr;
    fToken:='>>';
    exit;
   end else if CurrentChar='=' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkGe;
    fToken:='>=';
    exit;
   end else begin
    fKind:=TPinja.TLexer.TTokenKind.tkGt;
    fToken:='>';
    exit;
   end;
  end;
  '=':begin
   NextChar;
   if Peek='=' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkEq; 
    fToken:='==';
    exit;
   end else begin
    fKind:=TPinja.TLexer.TTokenKind.tkAssign;
    fToken:='=';
    exit;
   end;
  end;
  '!':begin
   NextChar;
   if Peek='=' then begin
    NextChar;
    fKind:=TPinja.TLexer.TTokenKind.tkNe;
    fToken:='!=';
    exit;
   end;
  end;
  '''','"':begin
   fToken:=ParseStringLiteral; 
   fKind:=TPinja.TLexer.TTokenKind.tkString; 
   exit;
  end;
 end;

 // ident/keyword (+ combined) 
 if IsIdentStart(Peek) then begin
  fToken:=ParseIdentifier; 
  fKind:=TPinja.TLexer.TTokenKind.tkIdent;
  if SameText(fToken,'in') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkIn;
  end else if SameText(fToken,'and') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkAnd;
  end else if SameText(fToken,'or') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkOr;
  end else if SameText(fToken,'not') then begin
   // not in / not is
   EndPosition:=fPosition;
   if NextIsWord('in',EndPosition) then begin
    fKind:=TPinja.TLexer.TTokenKind.tkNotIn;
    fPosition:=EndPosition;
   end else if NextIsWord('is',EndPosition) then begin
    fKind:=TPinja.TLexer.TTokenKind.tkIsNot;
    fPosition:=EndPosition;
   end else begin
    fKind:=TPinja.TLexer.TTokenKind.tkNot;
   end; 
  end else if SameText(fToken,'is') then begin
   if NextIsWord('not',EndPosition) then begin
    fKind:=TPinja.TLexer.TTokenKind.tkIsNot;
    fPosition:=EndPosition;
   end else begin
    fKind:=TPinja.TLexer.TTokenKind.tkIs;
   end;
  end else if SameText(fToken,'bor') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkBor;
  end else if SameText(fToken,'if') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkIf;
  end else if SameText(fToken,'else') then begin
   fKind:=TPinja.TLexer.TTokenKind.tkElse;
  end;
  exit;
 end;

 // fallback 
 NextChar; // consume unknown 
 fKind:=TPinja.TLexer.TTokenKind.tkEOF;
 fToken:='';
end;

//==============================================================================
// AST — Expressions                                                             
//==============================================================================

{ TPinja.TNodeExpressions }
constructor TPinja.TNodeExpressions.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
end;

destructor TPinja.TNodeExpressions.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TPinja.TNodeExpressions.Add(aExpression:TNodeExpression);
begin
 if length(fItems)<=fCount then begin
  SetLength(fItems,(fCount*2)+1);
 end;
 fItems[fCount]:=aExpression;
 inc(fCount);
end;

function TPinja.TNodeExpressions.Get(aIndex:TPinjaInt32):TNodeExpression;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fItems[aIndex];
 end else begin
  result:=nil;
 end;
end;

procedure TPinja.TNodeExpressions.Clear;
var Index:TPinjaInt32;
begin
 for Index:=0 to fCount-1 do begin
  FreeAndNil(fItems[Index]);
 end;
 fItems:=nil;
 fCount:=0;
end;

{ TPinja.TNodeExpressionValue }
constructor TPinja.TNodeExpressionValue.Create(const aValue:TValue);
begin
 inherited Create;
 fValue:=aValue.Clone;
end;

function TPinja.TNodeExpressionValue.Eval(const aContext:TContext):TValue;
begin
 result:=fValue.Clone;
end;

{ TPinja.TNodeExpressionVariable }
constructor TPinja.TNodeExpressionVariable.Create(const aName:TPinjaRawByteString);
begin
 inherited Create;
 fName:=aName;
end;

function TPinja.TNodeExpressionVariable.Eval(const aContext:TContext):TValue;
var Callable:TCallable;
    CallableObject:TCallableObject;
begin
 if not aContext.TryGetVariable(fName,result) then begin
  if aContext.TryGetCallable(fName,Callable) then begin
   CallableObject:=TCallableObject.Create;
   try
    CallableObject.fCallable:=Callable;
   finally
    result:=TValue.FromCallableObject(CallableObject);
   end;
  end else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionAttribute }
constructor TPinja.TNodeExpressionAttribute.Create(aBase:TNodeExpression;const aName:TPinjaRawByteString);
begin
 inherited Create;
 fBase:=aBase;
 fName:=aName;
end;

destructor TPinja.TNodeExpressionAttribute.Destroy;
begin
 FreeAndNil(fBase);
 inherited Destroy;
end;

function TPinja.TNodeExpressionAttribute.Eval(const aContext:TContext):TValue;
var BaseValue:TValue;
begin
 BaseValue:=fBase.Eval(aContext);
 if (BaseValue.Kind=TPinja.TValueKind.vkObject) and BaseValue.ObjTryGet(fName,result) then begin
  exit;
 end else begin
  result:=TValue.Null;
 end;
end;

{ TPinja.TNodeExpressionArgumentList }
constructor TPinja.TNodeExpressionArgumentList.Create;
begin
 inherited Create;
 fPos:=TPinjaObjectList.Create(true);
 fKwNames:=TStringList.Create;
 fKwVals:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeExpressionArgumentList.Destroy;
begin
 FreeAndNil(fPos);
 FreeAndNil(fKwNames);
 FreeAndNil(fKwVals);
 inherited Destroy;
end;

{ TPinja.TNodeExpressionCallName }
constructor TPinja.TNodeExpressionCallName.Create(aSelf:TNodeExpression;const aName:TPinjaRawByteString;aArguments:TNodeExpressionArgumentList);
begin
 inherited Create;
 fSelfExpression:=aSelf;
 fName:=aName;
 fArguments:=aArguments;
end;

destructor TPinja.TNodeExpressionCallName.Destroy;
begin
 FreeAndNil(fSelfExpression);
 FreeAndNil(fArguments);
 inherited Destroy;
end;

function TPinja.TNodeExpressionCallName.Eval(const aContext:TContext):TValue;
var SelfValue:TValue;
    Index:TPinjaInt32;
    DynamicArguments:array of TValue;
    KeywordArguments:TValue;
    CallableHandler:TCallable;
    FilterHandler:TFilter;
    MacroHandler:TNodeStatementMacroDefinition;
begin

 if assigned(fSelfExpression) then begin
  SelfValue:=fSelfExpression.Eval(aContext);
 end else begin
  SelfValue:=TValue.Null;
 end; 

 DynamicArguments:=nil;

 SetLength(DynamicArguments,fArguments.fPos.Count);
 for Index:=0 to fArguments.fPos.Count-1 do begin
  DynamicArguments[Index]:=TNodeExpression(fArguments.fPos[Index]).Eval(aContext);
 end;

 // kwargs
 KeywordArguments:=TValue.NewObject;
 for Index:=0 to fArguments.fKwNames.Count-1 do begin
  KeywordArguments.ObjSet(fArguments.fKwNames[Index],TNodeExpression(fArguments.fKwVals[Index]).Eval(aContext));
 end;

 if aContext.TryGetCallable(fName,CallableHandler) then begin
  result:=CallableHandler(SelfValue,DynamicArguments,KeywordArguments,aContext);
 end else if aContext.TryGetFilter(fName,FilterHandler) then begin
  result:=FilterHandler(SelfValue,DynamicArguments,aContext);
 end else if aContext.TryGetMacro(fName,MacroHandler) then begin
  result:=MacroHandler.Invoke(DynamicArguments,KeywordArguments,aContext);
 end else if aContext.fRaiseExceptionAtUnknownCallables then begin
  raise Exception.Create('Unknown callable: '+fName);
 end;

end;

{ TPinja.TNodeExpressionCall }
constructor TPinja.TNodeExpressionCall.Create(aTarget:TNodeExpression;aArguments:TNodeExpressionArgumentList);
begin
 inherited Create;
 fTargetExpression:=aTarget;
 fArguments:=aArguments;
end;

destructor TPinja.TNodeExpressionCall.Destroy;
begin
 FreeAndNil(fTargetExpression);
 FreeAndNil(fArguments);
 inherited Destroy;
end;

function TPinja.TNodeExpressionCall.Eval(const aContext:TContext):TValue;
var TargetValue:TValue;
    Index:TPinjaInt32;
    DynamicArguments:array of TValue;
    KeywordArguments:TValue;
begin

 if assigned(fTargetExpression) then begin
  TargetValue:=fTargetExpression.Eval(aContext);
 end else begin
  TargetValue:=TValue.Null;
 end;

 DynamicArguments:=nil;

 SetLength(DynamicArguments,fArguments.fPos.Count);
 for Index:=0 to fArguments.fPos.Count-1 do begin
  DynamicArguments[Index]:=TNodeExpression(fArguments.fPos[Index]).Eval(aContext);
 end;

 // kwargs
 KeywordArguments:=TValue.NewObject;
 for Index:=0 to fArguments.fKwNames.Count-1 do begin
  KeywordArguments.ObjSet(fArguments.fKwNames[Index],TNodeExpression(fArguments.fKwVals[Index]).Eval(aContext));
 end;

 // Use CallAsCallable for vkCallerObject values, otherwise handle as before
 if TargetValue.Kind=TPinja.TValueKind.vkCallerObject then begin
  result:=TargetValue.CallAsCallable(TValue.Null,DynamicArguments,KeywordArguments,aContext);
 end else begin
  if aContext.fRaiseExceptionAtUnknownCallables then begin
   raise Exception.Create('Value is not callable: '+TargetValue.AsString);
  end else begin
   result:=TValue.Null;
  end;
 end;

end;

{ TPinja.TNodeExpressionFilterPipe }
constructor TPinja.TNodeExpressionFilterPipe.Create(aBase:TNodeExpression);
begin
 inherited Create;
 fBase:=aBase;
 fNames:=TStringList.Create;
 fArgSets:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeExpressionFilterPipe.Destroy;
begin
 FreeAndNil(fBase);
 FreeAndNil(fNames);
 FreeAndNil(fArgSets);
 inherited Destroy;
end;

procedure TPinja.TNodeExpressionFilterPipe.AddFilter(const aName:TPinjaRawByteString;aArgs:TNodeExpressionArgumentList);
begin
 fNames.Add(aName);
 fArgSets.Add(aArgs);
end;

function TPinja.TNodeExpressionFilterPipe.Eval(const aContext:TContext):TValue;
var Index,ArgIndex:TPinjaInt32;
    DynamicArguments:array of TValue;
    ResultValue:TValue;
    ArgumentsList:TNodeExpressionArgumentList;
    CallableHandler:TCallable;
    FilterHandler:TFilter;
    KeywordArguments:TValue;
begin
 
 ResultValue:=fBase.Eval(aContext);
 
 for Index:=0 to fNames.Count-1 do begin
  
  ArgumentsList:=fArgSets[Index] as TNodeExpressionArgumentList;

  DynamicArguments:=nil;
  SetLength(DynamicArguments,ArgumentsList.fPos.Count);
  for ArgIndex:=0 to ArgumentsList.fPos.Count-1 do begin
   DynamicArguments[ArgIndex]:=TNodeExpression(ArgumentsList.fPos[ArgIndex]).Eval(aContext);
  end;

  KeywordArguments:=TPinja.TValue.NewObject;
  for ArgIndex:=0 to ArgumentsList.fKwNames.Count-1 do begin
   KeywordArguments.ObjSet(ArgumentsList.fKwNames[ArgIndex],TNodeExpression(ArgumentsList.fKwVals[ArgIndex]).Eval(aContext));
  end;

  if aContext.TryGetCallable(fNames[Index],CallableHandler) then begin
   ResultValue:=CallableHandler(ResultValue,DynamicArguments,KeywordArguments,aContext);
  end else if aContext.TryGetFilter(fNames[Index],FilterHandler) then begin
   ResultValue:=FilterHandler(ResultValue,DynamicArguments,aContext);
  end else begin
   raise Exception.CreateFmt('Unknown filter/callable: %s', [fNames[Index]]);
  end;

 end;

 result:=ResultValue;

end;

{ TPinja.TNodeExpressionUnary }
constructor TPinja.TNodeExpressionUnary.Create(aOperator:TUnaryOp;aExpression:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fA:=aExpression;
end;

destructor TPinja.TNodeExpressionUnary.Destroy;
begin
 FreeAndNil(fA);
 inherited Destroy;
end;

function TPinja.TNodeExpressionUnary.Eval(const aContext:TContext):TValue;
var Value:TValue;
    ResultInt:TPinjaInt64;
begin
 case fOp of
  TPinja.TUnaryOp.uoNot:begin
   result:=not fA.Eval(aContext);
  end;
  TPinja.TUnaryOp.uoPos:begin
   Value:=fA.Eval(aContext);
   if Value.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat] then begin
    result:=Value.Clone;
   end else begin
    result:=TValue.Null;
   end;
  end;
  TPinja.TUnaryOp.uoNeg:begin
   Value:=fA.Eval(aContext);
   if Value.Kind=TPinja.TValueKind.vkInt then begin
    result:=TValue.From(-Value.fIntegerValue);
   end else if Value.Kind=TPinja.TValueKind.vkFloat then begin
    result:=TValue.From(-Value.fFloatValue);
   end else begin
    result:=TValue.Null;
   end;
  end;
  TPinja.TUnaryOp.uoBitNot:begin
   Value:=fA.Eval(aContext);
   if Value.Kind=TPinja.TValueKind.vkInt then begin
    ResultInt:=not Value.fIntegerValue;
    result:=TValue.From(ResultInt);
   end else begin
    result:=TValue.Null;
   end;
  end;
  else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionPower }
constructor TPinja.TNodeExpressionPower.Create(aOperator:TPowerOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionPower.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionPower.Eval(const aContext:TContext):TValue;
 function IntPow(aBase,aExp:TPinjaInt64):TPinjaInt64;
 begin
  result:=1;
  while aExp>0 do begin
   if (aExp and 1)<>0 then begin
    result:=result*aBase;
   end;
   aBase:=aBase*aBase;
   aExp:=aExp shr 1;
  end;
 end;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 
 if not ((LeftValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (RightValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat])) then begin
  result:=TValue.Null;
  exit;
 end;

 if (LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.fIntegerValue>=0) then begin
  result:=TValue.From(IntPow(LeftValue.fIntegerValue,RightValue.fIntegerValue));
 end else begin
  result:=TValue.From(Power(LeftValue.AsFloat,RightValue.AsFloat));
 end;

end;

{ TPinja.TNodeExpressionCompare }
constructor TPinja.TNodeExpressionCompare.Create(aOperator:TCompareOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionCompare.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionCompare.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue,TempValue:TValue;
    BooleanResult:Boolean;
    Index:TPinjaInt32;
    InResult:Boolean;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 case fOp of
  TPinja.TCompareOp.coEq:begin
   BooleanResult:=LeftValue=RightValue;
  end;
  TPinja.TCompareOp.coNe:begin
   BooleanResult:=LeftValue<>RightValue;
  end;
  TPinja.TCompareOp.coLt:begin
   BooleanResult:=LeftValue<RightValue;
  end;
  TPinja.TCompareOp.coLe:begin
   BooleanResult:=LeftValue<=RightValue;
  end;
  TPinja.TCompareOp.coGt:begin
   BooleanResult:=LeftValue>RightValue;
  end;
  TPinja.TCompareOp.coGe:begin
   BooleanResult:=LeftValue>=RightValue;
  end;
  TPinja.TCompareOp.coIn:begin
   if RightValue.Kind=TPinja.TValueKind.vkString then begin
    InResult:=Pos(LeftValue.AsString,RightValue.AsString)>0;
   end else if RightValue.Kind=TPinja.TValueKind.vkArray then begin
    InResult:=false;
    ArrayObject:=RightValue.fArrayObject.GetArrayObject;
    for Index:=0 to ArrayObject.fCount-1 do begin
     if LeftValue=ArrayObject.fValues[Index] then begin
      InResult:=true; 
      break;
     end;
    end;
   end else if RightValue.Kind=TPinja.TValueKind.vkObject then begin
    InResult:=RightValue.ObjTryGet(LeftValue.AsString,TempValue);
   end else begin
    InResult:=false;
   end;
   BooleanResult:=InResult;
  end;
  TPinja.TCompareOp.coNotIn:begin
   // compute directly without constructing another node 
   if RightValue.Kind=TPinja.TValueKind.vkString then begin
    InResult:=Pos(LeftValue.AsString,RightValue.AsString)>0;
   end else if RightValue.Kind=TPinja.TValueKind.vkArray then begin
    InResult:=false;
    ArrayObject:=RightValue.fArrayObject.GetArrayObject;
    for Index:=0 to ArrayObject.fCount-1 do begin
     if LeftValue=ArrayObject.fValues[Index] then begin
      InResult:=true;
      break;
     end;
    end;
   end else if RightValue.Kind=TPinja.TValueKind.vkObject then begin
    InResult:=RightValue.ObjTryGet(LeftValue.AsString,TempValue);
   end else begin
    InResult:=false;
   end;
   BooleanResult:=not InResult;
  end;
  else begin
   BooleanResult:=false;
  end;
 end;
 result:=TValue.From(BooleanResult);
end;

{ TPinja.TNodeExpressionIs }
constructor TPinja.TNodeExpressionIs.Create(aNegate:Boolean;const aTestName:TPinjaRawByteString;aLeftExpression:TNodeExpression;aTestParameters:TNodeExpressions=nil);
begin
 inherited Create;
 fNegate:=aNegate;
 fTestName:=LowerCase(aTestName);
 fLeftExpression:=aLeftExpression;
 fTestParameters:=aTestParameters;
end;

destructor TPinja.TNodeExpressionIs.Destroy;
begin
 FreeAndNil(fLeftExpression);
 FreeAndNil(fTestParameters);
 inherited Destroy;
end;

function TPinja.TNodeExpressionIs.Eval(const aContext:TContext):TValue;
var Value:TValue;
    Name:TPinjaRawByteString;
    BoolResult:Boolean;
    ParameterValue:TValue;
    DivisorValue:TPinjaInt32;
    CompareValue:TValue;
begin
 Value:=fLeftExpression.Eval(aContext);
 Name:=LowerCase(fTestName);
 BoolResult:=false;
 if Name='string' then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkString;
 end else if (Name='int') or (Name='integer') then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkInt;
 end else if (Name='number') or (Name='float') then begin
  BoolResult:=Value.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat];
 end else if (Name='bool') or (Name='boolean') then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkBool;
 end else if (Name='none') or (Name='null') then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkNull;
 end else if Name='defined' then begin
  BoolResult:=Value.Kind<>TPinja.TValueKind.vkNull;
 end else if Name='undefined' then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkNull;
 end else if (Name='array') or (Name='sequence') then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkArray;
 end else if (Name='object') or (Name='mapping') then begin
  BoolResult:=Value.Kind=TPinja.TValueKind.vkObject;
 end else if Name='odd' then begin
  BoolResult:=(Value.Kind=TPinja.TValueKind.vkInt) and ((Value.fIntegerValue and 1)=1);
 end else if Name='even' then begin
  BoolResult:=(Value.Kind=TPinja.TValueKind.vkInt) and ((Value.fIntegerValue and 1)=0);
 end else if Name='false' then begin
  case Value.Kind of
   TPinja.TValueKind.vkInt:begin
    BoolResult:=Value.fIntegerValue=0;
   end;
   TPinja.TValueKind.vkBool:begin
    BoolResult:=not Value.fBooleanValue;
   end;
   else begin
    BoolResult:=false;
   end;
  end;
 end else if Name='true' then begin
  case Value.Kind of
   TPinja.TValueKind.vkInt:begin
    BoolResult:=Value.fIntegerValue<>0;
   end;
   TPinja.TValueKind.vkBool:begin
    BoolResult:=Value.fBooleanValue;
   end;
   else begin
    BoolResult:=false;
   end;
  end;
 end else if Name='iterable' then begin
  BoolResult:=(Value.Kind in [TPinja.TValueKind.vkArray,TPinja.TValueKind.vkObject]) or
              (Value.Kind=TPinja.TValueKind.vkString);
 end else if Name='divisibleby' then begin
  // Test if value is divisible by the parameter
  if assigned(fTestParameters) and (fTestParameters.Count>0) and (Value.Kind=TPinja.TValueKind.vkInt) then begin
   ParameterValue:=fTestParameters[0].Eval(aContext);
   if ParameterValue.Kind=TPinja.TValueKind.vkInt then begin
    DivisorValue:=ParameterValue.fIntegerValue;
    if DivisorValue<>0 then begin
     BoolResult:=(Value.fIntegerValue mod DivisorValue)=0;
    end else begin
     BoolResult:=false; // Division by zero
    end;
   end else begin
    BoolResult:=false; // Parameter must be integer
   end;
  end else begin
   BoolResult:=false; // Value must be integer and parameter required
  end;
 end else if Name='sameas' then begin
  // Test if value is the same as the parameter (strict equality)
  if assigned(fTestParameters) and (fTestParameters.Count>0) then begin
   CompareValue:=fTestParameters[0].Eval(aContext);
   BoolResult:=Value=CompareValue;
  end else begin
   BoolResult:=false; // Parameter required
  end;
 end;
 if fNegate then begin
  BoolResult:=not BoolResult;
 end;
 result:=TValue.From(BoolResult);
end;

{ TPinja.TNodeExpressionLogical }
constructor TPinja.TNodeExpressionLogical.Create(aOperator:TLogicalOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionLogical.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionLogical.Eval(const aContext:TContext):TValue;
var LeftValue:TValue;
begin
 case fOp of
  TPinja.TLogicalOp.loAnd:begin
   LeftValue:=fLhs.Eval(aContext);
   if not LeftValue.IsTruthy then begin
    result:=TValue.From(false);
    exit;
   end;
   result:=TValue.From(fRhs.Eval(aContext).IsTruthy);
  end;
  TPinja.TLogicalOp.loOr:begin
   LeftValue:=fLhs.Eval(aContext);
   if LeftValue.IsTruthy then begin
    result:=TValue.From(true);
    exit;
   end;
   result:=TValue.From(fRhs.Eval(aContext).IsTruthy);
  end;
  else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionAdd }
constructor TPinja.TNodeExpressionAdd.Create(aOperator:TAddOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionAdd.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionAdd.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 case fOp of
  TPinja.TAddOp.aoPlus:begin
   result:=LeftValue+RightValue;
  end;
  TPinja.TAddOp.aoMinus:begin
   if (LeftValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (RightValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) then begin
    result:=LeftValue-RightValue;
   end else begin
    result:=TValue.Null;
   end;
  end;
  else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionMulDivMod }
constructor TPinja.TNodeExpressionMulDivMod.Create(aOperator:TArithOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionMulDivMod.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionMulDivMod.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
    Denominator:TPinjaDouble;
    Quotient:TPinjaDouble;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 if not ((LeftValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat]) and (RightValue.Kind in [TPinja.TValueKind.vkInt,TPinja.TValueKind.vkFloat])) then begin
  result:=TValue.Null;
  exit;
 end;

 case fOp of
  TPinja.TArithOp.arMul:begin
   result:=LeftValue*RightValue;
  end;
  TPinja.TArithOp.arDiv:begin
   Denominator:=RightValue.AsFloat;
   if Abs(Denominator)<1e-18 then begin
    result:=TValue.Null;
   end else begin
    result:=TValue.From(LeftValue.AsFloat/Denominator);
   end;
  end;
  TPinja.TArithOp.arFloorDiv:begin
   Denominator:=RightValue.AsFloat;
   if Abs(Denominator)<1e-18 then begin
    result:=TValue.Null;
   end else begin
    Quotient:=LeftValue.AsFloat/Denominator;
    result:=TValue.From(TPinjaInt64(Floor(Quotient)));
   end;
  end;
  TPinja.TArithOp.arMod:begin
   if (LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.fIntegerValue<>0) then begin
    result:=TValue.From(LeftValue.fIntegerValue mod RightValue.fIntegerValue);
   end else if Abs(RightValue.AsFloat)<1e-18 then begin
    result:=TValue.Null;
   end else begin
    result:=TValue.From(FloatMod(LeftValue.AsFloat,RightValue.AsFloat));
   end;
  end;
  else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionShift }
constructor TPinja.TNodeExpressionShift.Create(aOperator:TShiftOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionShift.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionShift.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
    ShiftAmount:TPinjaInt64;
    ValueToShift:TPinjaInt64;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 if not ((LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt)) then begin
  result:=TValue.Null;
  exit;
 end;

 ShiftAmount:=RightValue.fIntegerValue;
 if (ShiftAmount<0) then begin
  result:=TValue.Null;
  exit;
 end;
 if ShiftAmount>62 then begin
  ShiftAmount:=62;
 end;

 ValueToShift:=LeftValue.fIntegerValue;
 case fOp of
  TPinja.TShiftOp.soShl:begin
   result:=TValue.From(ValueToShift shl ShiftAmount);
  end;
  TPinja.TShiftOp.soShr:begin
   result:=TValue.From(ValueToShift shr ShiftAmount);
  end;
  else begin
   result:=TValue.Null;
  end;
 end;
end;

{ TPinja.TNodeExpressionBitAnd }
constructor TPinja.TNodeExpressionBitAnd.Create(aOperator:TBitAndOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionBitAnd.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionBitAnd.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 if (LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt) then begin
  result:=TValue.From(LeftValue.fIntegerValue and RightValue.fIntegerValue);
 end else begin
  result:=TValue.Null;
 end;
end;

{ TPinja.TNodeExpressionBitXor }
constructor TPinja.TNodeExpressionBitXor.Create(aOperator:TBitXorOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionBitXor.Destroy;
begin
  FreeAndNil(fLhs);
  FreeAndNil(fRhs);
  inherited Destroy;
end;

function TPinja.TNodeExpressionBitXor.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 if (LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt) then begin
  result:=TValue.From(LeftValue.fIntegerValue xor RightValue.fIntegerValue);
 end else begin
  result:=TValue.Null;
 end;
end;

{ TPinja.TNodeExpressionBitOr }
constructor TPinja.TNodeExpressionBitOr.Create(aOperator:TBitOrOp;aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fOp:=aOperator;
 fLhs:=aLeft;
 fRhs:=aRight;
end;

destructor TPinja.TNodeExpressionBitOr.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionBitOr.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 if (LeftValue.Kind=TPinja.TValueKind.vkInt) and (RightValue.Kind=TPinja.TValueKind.vkInt) then begin
  result:=TValue.From(LeftValue.fIntegerValue or RightValue.fIntegerValue);
 end else begin
  result:=TValue.Null;
 end;
end;

{ TPinja.TNodeExpressionConcat }
constructor TPinja.TNodeExpressionConcat.Create(aLeft,aRight:TNodeExpression);
begin
 inherited Create;
 fLhs:=aLeft;
 fRhs:=aRight;
end;destructor TPinja.TNodeExpressionConcat.Destroy;
begin
 FreeAndNil(fLhs);
 FreeAndNil(fRhs);
 inherited Destroy;
end;

function TPinja.TNodeExpressionConcat.Eval(const aContext:TContext):TValue;
var LeftValue,RightValue:TValue;
begin
 LeftValue:=fLhs.Eval(aContext);
 RightValue:=fRhs.Eval(aContext);
 result:=TValue.From(LeftValue.AsString+RightValue.AsString);
end;

{ TPinja.TNodeExpressionIndex }
constructor TPinja.TNodeExpressionIndex.Create(aBase,aIndex:TNodeExpression);
begin
 inherited Create;
 fBase:=aBase;
 fIndex:=aIndex;
end;

destructor TPinja.TNodeExpressionIndex.Destroy;
begin
 FreeAndNil(fBase);
 FreeAndNil(fIndex);
 inherited Destroy;
end;

function TPinja.TNodeExpressionIndex.Eval(const aContext:TContext):TValue;
var BaseValue,IndexValue:TValue;
    ArrayIndex:TPinjaInt32;
    StringValue:TPinjaRawByteString;
    StringLength:TPinjaInt32;
    CharResult:AnsiChar;
begin
 BaseValue:=self.fBase.Eval(aContext);
 IndexValue:=self.fIndex.Eval(aContext);

 if BaseValue.Kind=TPinja.TValueKind.vkArray then begin
  StringLength:=BaseValue.Count;
  ArrayIndex:=ClampIndex(IndexValue.fIntegerValue,StringLength);
  if (ArrayIndex<0) or (ArrayIndex>=StringLength) then begin
   result:=TValue.Null;
   exit;
  end;
  result:=BaseValue.ValueAt(ArrayIndex);
  exit;
 end else if BaseValue.Kind=TPinja.TValueKind.vkString then begin
  StringValue:=BaseValue.AsString;
  StringLength:=Length(StringValue);
  ArrayIndex:=IndexValue.fIntegerValue;
  ArrayIndex:=ClampIndex(ArrayIndex,StringLength);
  if (ArrayIndex<0) or (ArrayIndex>=StringLength) then begin
   result:=TValue.Null;
   exit;
  end;
  CharResult:=StringValue[ArrayIndex+1];
  result:=TValue.From(TPinjaRawByteString(CharResult));
  exit;
 end else if BaseValue.Kind=TPinja.TValueKind.vkObject then begin
  if BaseValue.ObjTryGet(IndexValue.AsString,result) then begin
   exit;
  end;
  result:=TValue.Null;
  exit;
 end;

 result:=TValue.Null;
end;

{ TPinja.TNodeExpressionSlice }
constructor TPinja.TNodeExpressionSlice.Create(aBase,aStart,aStop,aStep:TNodeExpression);
begin
 inherited Create;
 fBase:=aBase;
 fStart:=aStart;
 fStop:=aStop;
 fStep:=aStep;
end;

destructor TPinja.TNodeExpressionSlice.Destroy;
begin
 FreeAndNil(fBase);
 FreeAndNil(fStart);
 FreeAndNil(fStop);
 FreeAndNil(fStep);
 inherited Destroy;
end;

function TPinja.TNodeExpressionSlice.Eval(const aContext:TContext):TValue;
var BaseValue:TValue;
    StringValue,SliceString:TPinjaRawByteString;
    Index,StartIndex,StopIndex,StepIndex,Length:TPinjaInt32;
    Count,Position:TPinjaInt32;
    ArrayObjectResult,ArrayObjectBase:TPinja.TValue.TArrayObject;
begin
 BaseValue:=fBase.Eval(aContext);

 // parse start/stop/step
 if Assigned(fStep) then begin
  StepIndex:=fStep.Eval(aContext).fIntegerValue;
 end else begin
  StepIndex:=1;
 end;
 if StepIndex=0 then begin
  result:=TValue.Null;
  exit;
 end;

 if BaseValue.Kind=TPinja.TValueKind.vkString then begin
  StringValue:=BaseValue.AsString;
  Length:=System.Length(StringValue);
  if Assigned(fStart) then begin
   StartIndex:=ClampIndex(fStart.Eval(aContext).fIntegerValue,Length);
  end else begin
   if StepIndex>0 then begin
    StartIndex:=0;
   end else begin
    StartIndex:=Length-1;
   end;
  end;
  if Assigned(fStop) then begin
   StopIndex:=ClampIndex(fStop.Eval(aContext).fIntegerValue,Length);
  end else begin
   if StepIndex>0 then begin
    StopIndex:=Length;
   end else begin
    StopIndex:=-1;
   end;
  end;

  if StepIndex>0 then begin
   if StartIndex<StopIndex then begin
    Count:=(StopIndex-StartIndex+StepIndex-1) div StepIndex;
   end else begin
    Count:=0;
   end;
  end else begin
   if StartIndex>StopIndex then begin
    Count:=(StartIndex-StopIndex+(-StepIndex)-1) div (-StepIndex);
   end else begin
    Count:=0;
   end;
  end;

  // Create a new string for the slice result
  SliceString:='';
  if Count>0 then begin
   SetLength(SliceString,Count);
   Position:=0;
   Index:=StartIndex;
   while Position<Count do begin
    SliceString[Position+1]:=StringValue[Index+1];
    inc(Position);
    inc(Index,StepIndex);
   end;
  end;
  result:=TValue.From(SliceString);
  exit;
 end else if BaseValue.Kind=TPinja.TValueKind.vkArray then begin
  ArrayObjectBase:=BaseValue.fArrayObject.GetArrayObject;
  Length:=ArrayObjectBase.fCount;
  if Assigned(fStart) then begin
   StartIndex:=ClampIndex(fStart.Eval(aContext).fIntegerValue,Length);
  end else begin
   if StepIndex>0 then begin
    StartIndex:=0;
   end else begin
    StartIndex:=Length-1;
   end;
  end;
  if Assigned(fStop) then begin
   StopIndex:=ClampIndex(fStop.Eval(aContext).fIntegerValue,Length);
  end else begin
   if StepIndex>0 then begin
    StopIndex:=Length;
   end else begin
    StopIndex:=-1;
   end;
  end;

  if StepIndex>0 then begin
   if StartIndex<StopIndex then begin
    Count:=(StopIndex-StartIndex+StepIndex-1) div StepIndex;
   end else begin
    Count:=0;
   end;
  end else begin
   if StartIndex>StopIndex then begin
    Count:=(StartIndex-StopIndex+(-StepIndex)-1) div (-StepIndex);
   end else begin
    Count:=0;
   end;
  end;

  result:=TValue.NewArray;
  ArrayObjectResult:=result.fArrayObject.GetArrayObject;
  SetLength(ArrayObjectResult.fValues,Count);
  ArrayObjectResult.fCount:=Count;

  Position:=0;
  Index:=StartIndex;
  while Position<Count do begin
   ArrayObjectResult.fValues[Position]:=ArrayObjectBase.fValues[Index];
   inc(Position);
   inc(Index,StepIndex);
  end;
  exit;
 end;

 result:=TValue.Null;
end;

{ TPinja.TNodeExpressionArrayLit }
constructor TPinja.TNodeExpressionArrayLit.Create;
begin
 inherited Create;
 fItems:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeExpressionArrayLit.Destroy;
begin
 FreeAndNil(fItems);
 inherited Destroy;
end;

procedure TPinja.TNodeExpressionArrayLit.Add(aExpression:TNodeExpression);
begin
 fItems.Add(aExpression);
end;

function TPinja.TNodeExpressionArrayLit.Eval(const aContext:TContext):TValue;
var Index,Count:TPinjaInt32;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 result:=TValue.NewArray;
 ArrayObject:=result.fArrayObject.GetArrayObject;
 Count:=fItems.Count;
 SetLength(ArrayObject.fValues,Count);
 ArrayObject.fCount:=Count;
 for Index:=0 to Count-1 do begin
  ArrayObject.fValues[Index]:=TNodeExpression(fItems[Index]).Eval(aContext);
 end;
end;

{ TPinja.TNodeExpressionDictLit }
constructor TPinja.TNodeExpressionDictLit.Create;
begin
 inherited Create;
 fKeys:=TPinjaObjectList.Create(true);
 fVals:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeExpressionDictLit.Destroy;
begin
 FreeAndNil(fKeys);
 FreeAndNil(fVals);
 inherited;
end;

procedure TPinja.TNodeExpressionDictLit.Add(aKey,aVal:TNodeExpression);
begin
 fKeys.Add(aKey);
 fVals.Add(aVal);
end;

function TPinja.TNodeExpressionDictLit.Eval(const aContext:TContext):TValue;
var Index,Count,UsedCount,SearchIndex:TPinjaInt32;
    KeyValue,Value:TValue;
    KeyString:TPinjaRawByteString;
    ArrayObject:TPinja.TValue.TArrayObject;
begin
 result:=TValue.NewObject;
 ArrayObject:=result.fArrayObject.GetArrayObject;
 Count:=fKeys.Count;
 SetLength(ArrayObject.fKeys,Count);
 SetLength(ArrayObject.fValues,Count);
 UsedCount:=0;
 for Index:=0 to Count-1 do begin
  KeyValue:=TNodeExpression(fKeys[Index]).Eval(aContext);
  Value:=TNodeExpression(fVals[Index]).Eval(aContext);
  KeyString:=KeyValue.AsString;

  SearchIndex:=0;
  while SearchIndex<UsedCount do begin
   if ArrayObject.fKeys[SearchIndex]=KeyString then begin
    ArrayObject.fValues[SearchIndex]:=Value;
    break;
   end;
   inc(SearchIndex);
  end;

  if SearchIndex=UsedCount then begin
   ArrayObject.fKeys[UsedCount]:=KeyString;
   ArrayObject.fValues[UsedCount]:=Value;
   inc(UsedCount);
  end;
 end;

 if UsedCount<>Count then begin
  SetLength(ArrayObject.fKeys,UsedCount);
  SetLength(ArrayObject.fValues,UsedCount);
 end;
 ArrayObject.fCount:=UsedCount;
end;

{ TPinja.TNodeExpressionTernary }
constructor TPinja.TNodeExpressionTernary.Create(aThenE,aCondE,aElseE:TNodeExpression);
begin
 inherited Create;
 fThen:=aThenE; 
 fCondition:=aCondE; 
 fElse:=aElseE;
end;

destructor TPinja.TNodeExpressionTernary.Destroy;
begin
 FreeAndNil(fThen); 
 FreeAndNil(fCondition); 
 FreeAndNil(fElse);
 inherited;
end;

function TPinja.TNodeExpressionTernary.Eval(const aContext:TContext):TValue;
begin
 if fCondition.Eval(aContext).IsTruthy then begin
  result:=fThen.Eval(aContext);
 end else begin
  result:=fElse.Eval(aContext);
 end;
end;

//==============================================================================
// AST — Statements                                                              
//==============================================================================

{ TPinja.TNodeStatement }
procedure TPinja.TNodeStatement.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
end;

{ TPinja.TNodeStatementText }
constructor TPinja.TNodeStatementText.Create(const aString:TPinjaRawByteString);
begin
 inherited Create;
 fText:=aString;
end;

procedure TPinja.TNodeStatementText.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
 aOutput.AddString(fText);
end;

{ TPinja.TNodeStatementExpression }
constructor TPinja.TNodeStatementExpression.Create(aExpression:TNodeExpression);
begin
 inherited Create;
 fExpression:=aExpression;
end;

destructor TPinja.TNodeStatementExpression.Destroy;
begin
 FreeAndNil(fExpression);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementExpression.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
 aOutput.AddString(fExpression.Eval(aContext).AsString);
end;

{ TPinja.TNodeStatementBlock }
constructor TPinja.TNodeStatementBlock.Create;
begin
 inherited Create;
 fItems:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeStatementBlock.Destroy;
begin
 FreeAndNil(fItems);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementBlock.Add(aNode:TNodeStatement);
begin
 fItems.Add(aNode);
end;

procedure TPinja.TNodeStatementBlock.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var Index:TPinjaInt32;
    Statement:TPinja.TNodeStatement;
begin
 for Index:=0 to fItems.Count-1 do begin
  Statement:=TNodeStatement(fItems[Index]);
  Statement.Render(aContext,aOutput);
 end;
end;

{ TPinja.TNodeStatementSet }
constructor TPinja.TNodeStatementSet.Create(const aAName:TPinjaRawByteString;aExpression:TNodeExpression);
begin
 inherited Create;
 fName:=aAName;
 fExpression:=aExpression;
end;

destructor TPinja.TNodeStatementSet.Destroy;
begin
 FreeAndNil(fExpression);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementSet.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var DotPosition:TPinjaInt32;
    ObjectName,PropertyName:TPinjaRawByteString;
    ObjectValue:TValue;
begin
 // Check if this is a dotted property assignment (e.g., "ns.count")
 DotPosition:=Pos('.',fName);
 if DotPosition>0 then begin
  // Split into object name and property name
  ObjectName:=Copy(fName,1,DotPosition-1);
  PropertyName:=Copy(fName,DotPosition+1,MaxInt);
  
  // Get the object and set the property
  if aContext.TryGetVariable(ObjectName,ObjectValue) and (ObjectValue.Kind=TPinja.TValueKind.vkObject) then begin
   ObjectValue.ObjSet(PropertyName,fExpression.Eval(aContext));
  end else begin
   // If object doesn't exist or isn't an object, fall back to creating a literal variable
   aContext.SetVariable(fName,fExpression.Eval(aContext));
  end;
 end else begin
  // Simple variable assignment
  aContext.SetVariable(fName,fExpression.Eval(aContext));
 end;
end;

{ TPinja.TNodeStatementSetBlock }
constructor TPinja.TNodeStatementSetBlock.Create(const aName:TPinjaRawByteString;aBody:TNodeStatementBlock);
begin
 inherited Create;
 fName:=aName;
 fBody:=aBody;
end;

destructor TPinja.TNodeStatementSetBlock.Destroy;
begin
 FreeAndNil(fBody);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementSetBlock.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var TempOutput:TRawByteStringOutput;
    StringValue:TPinjaRawByteString;
begin
 TempOutput:=TRawByteStringOutput.Create;
 try
  fBody.Render(aContext,TempOutput);
  StringValue:=TempOutput.AsString;
  aContext.SetVariable(fName,TValue.From(StringValue));
 finally
  FreeAndNil(TempOutput);
 end;
end;

{ TPinja.TNodeStatementIf }
constructor TPinja.TNodeStatementIf.Create;
begin
 inherited Create;
 fConditions:=TPinjaObjectList.Create(true);
 fBodies:=TPinjaObjectList.Create(true);
 fElseBody:=nil;
end;

destructor TPinja.TNodeStatementIf.Destroy;
begin
 FreeAndNil(fConditions);
 FreeAndNil(fBodies);
 FreeAndNil(fElseBody);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementIf.AddBranch(aCond:TNodeExpression;aBody:TNodeStatementBlock);
begin
 fConditions.Add(aCond);
 fBodies.Add(aBody);
end;

procedure TPinja.TNodeStatementIf.SetElse(aBody:TNodeStatementBlock);
begin
 fElseBody:=aBody;
end;

procedure TPinja.TNodeStatementIf.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var Index:TPinjaInt32;
    Condition:TValue;
begin
 for Index:=0 to fConditions.Count-1 do begin
  Condition:=TNodeExpression(fConditions[Index]).Eval(aContext);
  if Condition.IsTruthy then begin
   TNodeStatementBlock(fBodies[Index]).Render(aContext,aOutput);
   exit;
  end;
 end;
 if Assigned(fElseBody) then begin
  fElseBody.Render(aContext,aOutput);
 end;
end;

{ TPinja.TNodeStatementBreak }
procedure TPinja.TNodeStatementBreak.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
  raise EBreakSignal.Create('break');
end;

{ TPinja.TNodeStatementContinue }
procedure TPinja.TNodeStatementContinue.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
 raise EContinueSignal.Create('continue');
end;

{ TPinja.TNodeStatementFor }
constructor TPinja.TNodeStatementFor.Create(const aKey,aVal:TPinjaRawByteString;aExpression:TNodeExpression;aFilter:TNodeExpression;aBlock:TNodeStatementBlock);
begin
 inherited Create;
 fKeyName:=aKey;
 fValueName:=aVal;
 fIterable:=aExpression;
 fFilterCondition:=aFilter;
 fBody:=aBlock;
end;

destructor TPinja.TNodeStatementFor.Destroy;
begin
 FreeAndNil(fIterable);
 FreeAndNil(fBody);
 FreeAndNil(fFilterCondition);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementFor.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var SourceValue:TValue;
    Index,LoopIndex,Count,SelectedCount:TPinjaInt32;
    ValueValue:TValue;
    PassesFilter:Boolean;
    SelectedIndices:array of TPinjaInt32;
 function BuildLoopObject(aLen,aIndex0:TPinjaInt32):TValue;
 var ArrayObject:TPinja.TValue.TArrayObject;
 begin
  result:=TValue.NewObject;

  ArrayObject:=result.fArrayObject.GetArrayObject;

  SetLength(ArrayObject.fKeys,7);
  SetLength(ArrayObject.fValues,7);
  ArrayObject.fCount:=7;

  ArrayObject.fKeys[0]:='index0';
  ArrayObject.fValues[0]:=TValue.From(TPinjaInt64(aIndex0));

  ArrayObject.fKeys[1]:='index';
  ArrayObject.fValues[1]:=TValue.From(TPinjaInt64(aIndex0+1));

  ArrayObject.fKeys[2]:='revindex0';
  ArrayObject.fValues[2]:=TValue.From(TPinjaInt64((aLen-1)-aIndex0));

  ArrayObject.fKeys[3]:='revindex';
  ArrayObject.fValues[3]:=TValue.From(TPinjaInt64(aLen-aIndex0));

  ArrayObject.fKeys[4]:='first';
  ArrayObject.fValues[4]:=TValue.From(aIndex0=0);

  ArrayObject.fKeys[5]:='last';
  ArrayObject.fValues[5]:=TValue.From(aIndex0=aLen-1);

  ArrayObject.fKeys[6]:='length';
  ArrayObject.fValues[6]:=TValue.From(TPinjaInt64(aLen));

 end;

 function EvaluateCondition(const aKey:TPinjaRawByteString;const aVal:TValue):Boolean;
 var condV:TValue;
 begin
 
  if not assigned(fFilterCondition) then begin
   result:=true;
   exit; 
  end;

  aContext.PushScope;
  try
   if length(fKeyName)<>0 then begin
    aContext.SetVariable(fKeyName,TValue.From(aKey));
   end;
   aContext.SetVariable(fValueName,aVal);
   condV:=fFilterCondition.Eval(aContext);
   result:=condV.IsTruthy;
  finally
   aContext.PopScope;
  end;

 end;

var ArrayObjectSrc:TPinja.TValue.TArrayObject;
    DoBreak:Boolean;
begin
 SourceValue:=fIterable.Eval(aContext);

 // Build selection indices after applying optional filter
 SelectedIndices:=nil;
 SetLength(SelectedIndices,0);
 if SourceValue.Kind=TPinja.TValueKind.vkArray then begin
  ArrayObjectSrc:=SourceValue.fArrayObject.GetArrayObject;
  Count:=ArrayObjectSrc.fCount;
  for Index:=0 to Count-1 do begin
   ValueValue:=ArrayObjectSrc.fValues[Index];
   PassesFilter:=EvaluateCondition('',ValueValue);
   if PassesFilter then begin
    SelectedCount:=Length(SelectedIndices);
    SetLength(SelectedIndices,SelectedCount+1);
    SelectedIndices[SelectedCount]:=Index;
   end;
  end;
 end else if SourceValue.Kind=TPinja.TValueKind.vkObject then begin
  ArrayObjectSrc:=SourceValue.fArrayObject.GetArrayObject;
  Count:=ArrayObjectSrc.fCount;
  for Index:=0 to Count-1 do begin
   ValueValue:=ArrayObjectSrc.fValues[Index];
   PassesFilter:=EvaluateCondition(ArrayObjectSrc.fKeys[Index],ValueValue);
   if PassesFilter then begin
    SelectedCount:=Length(SelectedIndices);
    SetLength(SelectedIndices,SelectedCount+1);
    SelectedIndices[SelectedCount]:=Index;
   end;
  end;
 end else begin
  exit; // non-fIterable
 end;

 ArrayObjectSrc:=SourceValue.fArrayObject.GetArrayObject;

 SelectedCount:=Length(SelectedIndices);
 for LoopIndex:=0 to SelectedCount-1 do begin

  Index:=SelectedIndices[LoopIndex];

  DoBreak:=false;

  aContext.PushScope;
  try
   // key/value variables
   if SourceValue.Kind=TPinja.TValueKind.vkArray then begin
    if fKeyName<>'' then begin
     aContext.SetVariable(fKeyName,TValue.From(LoopIndex)); // index within filtered list
    end;
    ValueValue:=ArrayObjectSrc.fValues[Index];
    aContext.SetVariable(fValueName,ValueValue);
   end else begin
    if fKeyName<>'' then begin
     aContext.SetVariable(fKeyName,TValue.From(ArrayObjectSrc.fKeys[Index]));
    end;
    ValueValue:=ArrayObjectSrc.fValues[Index];
    aContext.SetVariable(fValueName,ValueValue);
   end;

   // loop object
   aContext.SetVariable('loop',BuildLoopObject(SelectedCount,LoopIndex));

   try
    fBody.Render(aContext,aOutput);
   except
    on E:EContinueSignal do begin
     // skip to next
    end;
    on E:EBreakSignal do begin
     DoBreak:=true;
    end;
   end;

  finally
   aContext.PopScope;
  end;

  if DoBreak then begin
   break;
  end;

 end;

end;

{ TPinja.TNodeStatementFilterBlock }
constructor TPinja.TNodeStatementFilterBlock.Create(aBody:TNodeStatementBlock);
begin
 inherited Create;
 fNames:=TStringList.Create;
 fArgSets:=TPinjaObjectList.Create(true);
 fBody:=aBody;
end;

destructor TPinja.TNodeStatementFilterBlock.Destroy;
begin
 FreeAndNil(fNames);
 FreeAndNil(fArgSets);
 FreeAndNil(fBody);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementFilterBlock.AddFilter(const aName:TPinjaRawByteString;aArgs:TNodeExpressionArgumentList);
begin
 fNames.Add(aName);
 fArgSets.Add(aArgs);
end;

{ TPinja.TNodeStatementFilterBlock }
procedure TPinja.TNodeStatementFilterBlock.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var TempOutput:TRawByteStringOutput;
    ResultValue:TValue;
    Index,ArgIndex,Count:TPinjaInt32;
    ArgumentsList:TNodeExpressionArgumentList;
    DynamicArguments:array of TValue;
    CallableHandler:TCallable;
    FilterHandler:TFilter;
    ParameterValue:TValue;
    KeywordArguments:TValue;
    ArrayObjectKW:TPinja.TValue.TArrayObject;
begin
 TempOutput:=TRawByteStringOutput.Create;
 try
  fBody.Render(aContext,TempOutput);
  ResultValue:=TValue.From(TempOutput.AsString);

  for Index:=0 to fNames.Count-1 do begin
   ArgumentsList:=fArgSets[Index] as TNodeExpressionArgumentList;

   SetLength(DynamicArguments,ArgumentsList.fPos.Count);
   for ArgIndex:=0 to ArgumentsList.fPos.Count-1 do begin
    DynamicArguments[ArgIndex]:=TNodeExpression(ArgumentsList.fPos[ArgIndex]).Eval(aContext);
   end;

   KeywordArguments:=TValue.NewObject;
   ArrayObjectKW:=KeywordArguments.fArrayObject.GetArrayObject;
   Count:=ArgumentsList.fKwNames.Count;
   SetLength(ArrayObjectKW.fKeys,Count);
   SetLength(ArrayObjectKW.fValues,Count);
   ArrayObjectKW.fCount:=Count;
   for ArgIndex:=0 to Count-1 do begin
    ParameterValue:=TNodeExpression(ArgumentsList.fKwVals[ArgIndex]).Eval(aContext);
    ArrayObjectKW.fKeys[ArgIndex]:=ArgumentsList.fKwNames[ArgIndex];
    ArrayObjectKW.fValues[ArgIndex]:=ParameterValue;
   end;

   if aContext.TryGetCallable(fNames[Index],CallableHandler) then begin
    ResultValue:=CallableHandler(ResultValue,DynamicArguments,KeywordArguments,aContext);
   end else if aContext.TryGetFilter(fNames[Index],FilterHandler) then begin
    ResultValue:=FilterHandler(ResultValue,DynamicArguments,aContext);
   end else begin
    raise Exception.CreateFmt('Unknown filter in filter-block: %s', [fNames[Index]]);
   end;
  end;

  aOutput.AddString(ResultValue.AsString);

 finally
  FreeAndNil(TempOutput);
 end;
end;

{ TPinja.TNodeStatementMacroDefinition }
constructor TPinja.TNodeStatementMacroDefinition.Create(const aName:TPinjaRawByteString;aBody:TNodeStatementBlock);
begin
 inherited Create;
 fName:=aName;
 fBody:=aBody;
 fPosNames:=TStringList.Create;
 fKwNames:=TStringList.Create;
 fKwDefs:=TPinjaObjectList.Create(true);
end;

destructor TPinja.TNodeStatementMacroDefinition.Destroy;
begin
 FreeAndNil(fPosNames);
 FreeAndNil(fKwNames);
 FreeAndNil(fKwDefs);
 FreeAndNil(fBody);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementMacroDefinition.AddPosName(const aName:TPinjaRawByteString);
begin
 fPosNames.Add(aName);
end;

procedure TPinja.TNodeStatementMacroDefinition.AddKwDefault(const aName:TPinjaRawByteString;aExpression:TNodeExpression);
begin
 fKwNames.Add(aName);
 fKwDefs.Add(aExpression);
end;

procedure TPinja.TNodeStatementMacroDefinition.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
 // Registration-time effect; no direct output
 aContext.RegisterMacro(fName,Self);
end;

function TPinja.TNodeStatementMacroDefinition.Invoke(const aPos:array of TValue;var aKw:TValue;const aContext:TContext):TValue;
var Index:TPinjaInt32;
    tmpOut:TRawByteStringOutput;
    defV,got:TValue;
begin
 
 aContext.PushScope;
 try
 
  // bind pos args
  for Index:=0 to fPosNames.Count-1 do begin
   if Index<Length(aPos) then begin
    aContext.SetVariable(fPosNames[Index],aPos[Index]);
   end else begin
    aContext.SetVariable(fPosNames[Index],TValue.Null);
   end;
  end;

  // bind kwargs (with defaults)
  for Index:=0 to fKwNames.Count-1 do begin
   if (aKw.Kind=TPinja.TValueKind.vkObject) and aKw.ObjTryGet(TPinjaRawByteString(fKwNames[Index]),got) then begin
    aContext.SetVariable(fKwNames[Index],got);
   end else begin
    defV:=TNodeExpression(fKwDefs[Index]).Eval(aContext);
    aContext.SetVariable(fKwNames[Index],defV);
   end;
  end;

  tmpOut:=TRawByteStringOutput.Create;
  try
   fBody.Render(aContext,tmpOut);
   result:=TValue.From(tmpOut.AsString);
  finally
   FreeAndNil(tmpOut);
  end;

 finally
  aContext.PopScope;
 end;
 
end;

{ TPinja.TNodeStatementCall }
constructor TPinja.TNodeStatementCall.Create(const aMacroName:TPinjaRawByteString;aArguments:TNodeExpressionArgumentList;aBody:TNodeStatementBlock);
begin
 inherited Create;
 fMacroName:=aMacroName;
 fArguments:=aArguments;
 fBody:=aBody;
 fCallParameters:=TStringList.Create;
end;

destructor TPinja.TNodeStatementCall.Destroy;
begin
 FreeAndNil(fArguments);
 FreeAndNil(fBody);
 FreeAndNil(fCallParameters);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementCall.AddCallParameter(const aParameterName:TPinjaRawByteString);
begin
 fCallParameters.Add(aParameterName);
end;

{ TPinja.TNodeStatementCallCaller }
constructor TPinja.TNodeStatementCallCaller.Create(aBody:TNodeStatementBlock;aParameters:TStringList);
begin
 inherited Create;
 fBody:=aBody;
 fParameters:=aParameters;
end;

destructor TPinja.TNodeStatementCallCaller.Destroy;
begin
 // Note: fBody and fParameters are owned by TNodeStatementCall, so don't free them here
 inherited Destroy;
end;

function TPinja.TNodeStatementCallCaller.Call(const aSelfValue:TValue;const aPosArgs:array of TValue;var aKwArgs:TValue;const aCtx:TContext):TValue;
var ParameterIndex:TPinjaInt32;
    CallerOutput:TRawByteStringOutput;
begin
 // Create new scope and bind the arguments to the call parameters
 aCtx.PushScope;
 try
  // Bind positional arguments to call parameters
  for ParameterIndex:=0 to fParameters.Count-1 do begin
   if ParameterIndex<Length(aPosArgs) then begin
    aCtx.SetVariable(fParameters[ParameterIndex],aPosArgs[ParameterIndex]);
   end else begin
    aCtx.SetVariable(fParameters[ParameterIndex],TValue.Null);
   end;
  end;
  
  // Render the call body with the bound parameters
  CallerOutput:=TRawByteStringOutput.Create;
  try
   if Assigned(fBody) then begin
    fBody.Render(aCtx,CallerOutput);
   end;
   result:=TValue.From(CallerOutput.AsString);
  finally
   FreeAndNil(CallerOutput);
  end;
 finally
  aCtx.PopScope;
 end;
end;

procedure TPinja.TNodeStatementCall.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var Macro:TNodeStatementMacroDefinition;
    PositionalArgs:array of TValue;
    KeywordArgs:TValue;
    MacroResult:TValue;
    CallerCallable:TNodeStatementCallCaller;
    CallerValue:TValue;
    ArgumentIndex:TPinjaInt32;
    KwIndex:TPinjaInt32;
begin
 // Look up the macro
 if not aContext.TryGetMacro(fMacroName,Macro) then begin
  raise Exception.CreateFmt('Macro "%s" not found', [fMacroName]);
 end;

 // Evaluate arguments
 if Assigned(fArguments) then begin
  SetLength(PositionalArgs,fArguments.fPos.Count);
  for ArgumentIndex:=0 to fArguments.fPos.Count-1 do begin
   PositionalArgs[ArgumentIndex]:=TNodeExpression(fArguments.fPos[ArgumentIndex]).Eval(aContext);
  end;
  
  // Build keyword arguments object
  KeywordArgs:=TValue.NewObject;
  for KwIndex:=0 to fArguments.fKwNames.Count-1 do begin
   KeywordArgs.ObjSet(fArguments.fKwNames[KwIndex],TNodeExpression(fArguments.fKwVals[KwIndex]).Eval(aContext));
  end;
 end else begin
  SetLength(PositionalArgs,0);
  KeywordArgs:=TValue.NewObject;
 end;

 // Create callable caller object
 CallerCallable:=TNodeStatementCallCaller.Create(fBody,fCallParameters);
 CallerValue:=TValue.FromCallableObject(CallerCallable);

 // Set 'caller' variable in a new scope for the macro
 aContext.PushScope;
 try
  aContext.SetVariable('caller',CallerValue);
  
  // Invoke the macro
  MacroResult:=Macro.Invoke(PositionalArgs,KeywordArgs,aContext);
  aOutput.AddString(MacroResult.AsString);
 finally
  aContext.PopScope;
 end;
end;

{ TPinja.TNodeStatementGeneration }
constructor TPinja.TNodeStatementGeneration.Create(aBody:TNodeStatementBlock);
begin
 inherited Create;
 fBody:=aBody;
end;

destructor TPinja.TNodeStatementGeneration.Destroy;
begin
 FreeAndNil(fBody);
 inherited Destroy;
end;

procedure TPinja.TNodeStatementGeneration.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
begin
 // Generation blocks are rendered normally - they're just markers for the template system
 if Assigned(fBody) then begin
  fBody.Render(aContext,aOutput);
 end;
end;

//==============================================================================
// Parser                                                                        
//==============================================================================

{ TPinja.TParser }
constructor TPinja.TParser.Create(const aString:TPinjaRawByteString);
begin
 inherited Create;
 fLexer:=TLexer.Create(aString);
end;

destructor TPinja.TParser.Destroy;
begin
 FreeAndNil(fLexer);
 inherited;
end;

function TPinja.TParser.ParseArgs:TNodeExpressionArgumentList;
var name:TPinjaRawByteString;
    ValueExpression:TNodeExpression;
begin
 result:=TNodeExpressionArgumentList.Create;
 // assumes current token is '(' 
 if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
  fLexer.Next;
 end;
 if fLexer.Kind=TLexer.TTokenKind.tkRParen then begin 
  fLexer.Next; 
  exit; 
 end;

 while true do begin
  if (fLexer.Kind=TLexer.TTokenKind.tkIdent) and fLexer.NextIsAssign then begin
   name:=fLexer.Token; 
   fLexer.Next; // ident
   if fLexer.Kind<>TLexer.TTokenKind.tkAssign then begin
    raise Exception.Create('expected "=" in kwarg');
   end;
   fLexer.Next; // consume '='
   ValueExpression:=ParseExpression;
   result.fKwNames.Add(name);
   result.fKwVals.Add(ValueExpression);
  end else begin
   result.fPos.Add(ParseExpression);
  end;

  if fLexer.Kind=TLexer.TTokenKind.tkComma then begin
   fLexer.Next;
   if fLexer.Kind=TLexer.TTokenKind.tkRParen then begin 
    fLexer.Next; 
    break; 
   end;
   continue;
  end;

  if fLexer.Kind=TLexer.TTokenKind.tkRParen then begin
   fLexer.Next; 
   break;
  end;

  break;
 end;
end;

function TPinja.TParser.ParsePrimary:TNodeExpression;
var name:TPinjaRawByteString;
    args:TNodeExpressionArgumentList;
    keyE,valE:TNodeExpression;
begin
 case fLexer.Kind of
  TLexer.TTokenKind.tkIdent:begin
   name:=fLexer.Token; 
   fLexer.Next;
   if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
    args:=ParseArgs;
    result:=TNodeExpressionCallName.Create(nil,name,args);
   end else begin
    result:=TNodeExpressionVariable.Create(name);
   end;
   exit;
  end;
  TLexer.TTokenKind.tkString:begin
   result:=TNodeExpressionValue.Create(TValue.From(fLexer.Token));
   fLexer.Next;
   exit;
  end;
  TLexer.TTokenKind.tkNumber:begin
   if Pos('.',fLexer.Token)>0 then begin
    result:=TNodeExpressionValue.Create(TValue.From(ConvertStringToFloat(fLexer.Token)));
   end else begin
    result:=TNodeExpressionValue.Create(TValue.From(StrToInt64(fLexer.Token)));
   end;
   fLexer.Next;
   exit;
  end;
  TLexer.TTokenKind.tkLParen:begin
   fLexer.Next;
   result:=ParseExpression;
   if fLexer.Kind=TLexer.TTokenKind.tkRParen then begin
    fLexer.Next;
   end;
   exit;
  end;
  TLexer.TTokenKind.tkLBracket:begin
   // array literal 
   fLexer.Next;
   result:=TNodeExpressionArrayLit.Create;
   if fLexer.Kind<>TLexer.TTokenKind.tkRBracket then begin
    repeat
     TNodeExpressionArrayLit(result).Add(ParseExpression);
     if fLexer.Kind=TLexer.TTokenKind.tkComma then begin 
      fLexer.Next; 
      continue; 
     end else begin
      break;
     end;
    until false;
   end;
   if fLexer.Kind=TLexer.TTokenKind.tkRBracket then begin
    fLexer.Next;
   end;
   exit;
  end;
  TLexer.TTokenKind.tkLBrace:begin
   // dict literal: { key : value, ... } 
   fLexer.Next;
   result:=TNodeExpressionDictLit.Create;
   if fLexer.Kind<>TLexer.TTokenKind.tkRBrace then begin
    repeat
     keyE:=ParseExpression;
     if fLexer.Kind=TLexer.TTokenKind.tkColon then begin
      fLexer.Next;
     end else begin
      raise Exception.Create('":" expected in dict');
     end;
     valE:=ParseExpression;
     TNodeExpressionDictLit(result).Add(keyE,valE);
     if fLexer.Kind=TLexer.TTokenKind.tkComma then begin 
      fLexer.Next; 
      continue; 
     end else begin
      break;
     end;
    until false;
   end;
   if fLexer.Kind=TLexer.TTokenKind.tkRBrace then begin
    fLexer.Next;
   end;
   exit;
  end;
  else begin
  end;
 end;

 result:=TNodeExpressionValue.Create(TValue.Null);
end;

function TPinja.TParser.ParsePostfix(aBase:TNodeExpression):TNodeExpression;
var name:TPinjaRawByteString;
    args:TNodeExpressionArgumentList;
    startE,stopE,stepE:TNodeExpression;
begin
 result:=aBase;
 while true do begin
  if fLexer.Kind=TLexer.TTokenKind.tkPipe then begin
   fLexer.Next;
   if fLexer.Kind<>TLexer.TTokenKind.tkIdent then begin
    break;
   end;
   name:=fLexer.Token; 
   fLexer.Next;
   args:=nil;
   if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
    args:=ParseArgs;
   end else begin
    args:=TNodeExpressionArgumentList.Create; // no-args
   end;
   if not (result is TNodeExpressionFilterPipe) then begin
    result:=TNodeExpressionFilterPipe.Create(result);
   end;
   TNodeExpressionFilterPipe(result).AddFilter(name,args);
   continue;
  end else if fLexer.Kind=TLexer.TTokenKind.tkDot then begin
   fLexer.Next;
   if fLexer.Kind<>TLexer.TTokenKind.tkIdent then begin
    break;
   end;
   name:=fLexer.Token; 
   fLexer.Next;
   if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
    args:=ParseArgs;
    result:=TNodeExpressionCallName.Create(result,name,args);
   end else begin
    result:=TNodeExpressionAttribute.Create(result,name);
   end;
   continue;
  end else if fLexer.Kind=TLexer.TTokenKind.tkLBracket then begin
   fLexer.Next;
   startE:=nil; 
   stopE:=nil; 
   stepE:=nil;

   if fLexer.Kind=TLexer.TTokenKind.tkColon then begin
    // [:stop(:step)] 
   end else if fLexer.Kind<>TLexer.TTokenKind.tkRBracket then begin
    startE:=ParseExpression;
   end;

   if fLexer.Kind=TLexer.TTokenKind.tkColon then begin
    fLexer.Next;
    if (fLexer.Kind<>TLexer.TTokenKind.tkRBracket) and (fLexer.Kind<>TLexer.TTokenKind.tkColon) then begin
     stopE:=ParseExpression;
    end;
    if fLexer.Kind=TLexer.TTokenKind.tkColon then begin
     fLexer.Next;
     if fLexer.Kind<>TLexer.TTokenKind.tkRBracket then begin
      stepE:=ParseExpression;
     end;
    end;
    if fLexer.Kind=TLexer.TTokenKind.tkRBracket then begin
     fLexer.Next;
    end;
    result:=TNodeExpressionSlice.Create(result,startE,stopE,stepE);
   end else begin
    // indexing 
    if fLexer.Kind=TLexer.TTokenKind.tkRBracket then begin
     fLexer.Next;
    end;
    result:=TNodeExpressionIndex.Create(result,startE);
   end;

   continue;
  end else if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
   // Direct call of a callable value (expression)(args)
   args:=ParseArgs;
   result:=TNodeExpressionCall.Create(result,args);
   continue;
  end else begin
   break;
  end;
 end;
end;

function TPinja.TParser.ParsePower:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParsePostfix(ParsePrimary);
 if fLexer.Kind=TLexer.TTokenKind.tkPow then begin
  fLexer.Next;
  result:=TNodeExpressionPower.Create(TPinja.TPowerOp.poPow,LeftExpression,ParsePower); // right-assoc
 end else begin
  result:=LeftExpression; 
 end;
end;

function TPinja.TParser.ParseUnary:TNodeExpression;
var OperatorToken:TLexer.TTokenKind;
begin
 if fLexer.Kind in [TLexer.TTokenKind.tkNot,TLexer.TTokenKind.tkPlus,TLexer.TTokenKind.tkMinus,TLexer.TTokenKind.tkTilde] then begin
  OperatorToken:=fLexer.Kind;
  fLexer.Next;
  case OperatorToken of
   TLexer.TTokenKind.tkNot:begin
    result:=TNodeExpressionUnary.Create(TPinja.TUnaryOp.uoNot,ParseUnary);
    exit;
   end;
   TLexer.TTokenKind.tkPlus:begin
    result:=TNodeExpressionUnary.Create(TPinja.TUnaryOp.uoPos,ParseUnary);
    exit;
   end;
   TLexer.TTokenKind.tkMinus:begin
    result:=TNodeExpressionUnary.Create(TPinja.TUnaryOp.uoNeg,ParseUnary);
    exit;
   end;
   TLexer.TTokenKind.tkTilde:begin
    result:=TNodeExpressionUnary.Create(TPinja.TUnaryOp.uoBitNot,ParseUnary);
    exit;
   end;
   else begin
   end;
  end;
 end;
 result:=ParsePower;
end;

function TPinja.TParser.ParseMul:TNodeExpression;
var LeftExpression:TNodeExpression;
    OperatorToken:TLexer.TTokenKind;
    ArithmeticOperation:TArithOp;
begin
 LeftExpression:=ParseUnary;
 while fLexer.Kind in [TLexer.TTokenKind.tkStar,TLexer.TTokenKind.tkSlash,TLexer.TTokenKind.tkFloorDiv,TLexer.TTokenKind.tkPercent] do begin
  OperatorToken:=fLexer.Kind; 
  fLexer.Next;
  case OperatorToken of
   TLexer.TTokenKind.tkStar:begin
    ArithmeticOperation:=TPinja.TArithOp.arMul;
   end;
   TLexer.TTokenKind.tkSlash:begin
    ArithmeticOperation:=TPinja.TArithOp.arDiv;
   end;
   TLexer.TTokenKind.tkFloorDiv:begin
    ArithmeticOperation:=TPinja.TArithOp.arFloorDiv;
   end;
   TLexer.TTokenKind.tkPercent:begin
    ArithmeticOperation:=TPinja.TArithOp.arMod;
   end;
   else begin
    ArithmeticOperation:=TPinja.TArithOp.arMul;
   end;
  end;
  LeftExpression:=TNodeExpressionMulDivMod.Create(ArithmeticOperation,LeftExpression,ParseUnary);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseAdd:TNodeExpression;
var LeftExpression:TNodeExpression;
    OperatorToken:TLexer.TTokenKind;
    AdditionOperation:TAddOp;
begin
 LeftExpression:=ParseMul;
 while fLexer.Kind in [TLexer.TTokenKind.tkPlus,TLexer.TTokenKind.tkMinus] do begin
  OperatorToken:=fLexer.Kind; 
  fLexer.Next;
  if OperatorToken=TLexer.TTokenKind.tkPlus then begin
   AdditionOperation:=TPinja.TAddOp.aoPlus;
  end else begin
   AdditionOperation:=TPinja.TAddOp.aoMinus;
  end;
  LeftExpression:=TNodeExpressionAdd.Create(AdditionOperation,LeftExpression,ParseMul);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseConcat:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseAdd;
 while fLexer.Kind=TLexer.TTokenKind.tkTilde do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionConcat.Create(LeftExpression,ParseAdd);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseShift:TNodeExpression;
var LeftExpression:TNodeExpression;
    OperatorToken:TLexer.TTokenKind;
    ShiftOperation:TShiftOp;
begin
 LeftExpression:=ParseConcat;
 while fLexer.Kind in [TLexer.TTokenKind.tkShl,TLexer.TTokenKind.tkShr] do begin
  OperatorToken:=fLexer.Kind; 
  fLexer.Next;
  if OperatorToken=TLexer.TTokenKind.tkShl then begin
   ShiftOperation:=TPinja.TShiftOp.soShl;
  end else begin
   ShiftOperation:=TPinja.TShiftOp.soShr;
  end;
  LeftExpression:=TNodeExpressionShift.Create(ShiftOperation,LeftExpression,ParseConcat);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseBitAnd:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseShift;
 while fLexer.Kind=TLexer.TTokenKind.tkAmp do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionBitAnd.Create(TPinja.TBitAndOp.baAnd,LeftExpression,ParseShift);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseBitXor:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseBitAnd;
 while fLexer.Kind=TLexer.TTokenKind.tkCaret do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionBitXor.Create(TPinja.TBitXorOp.bxXor,LeftExpression,ParseBitAnd);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseBitOr:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseBitXor;
 while fLexer.Kind=TLexer.TTokenKind.tkBor do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionBitOr.Create(TPinja.TBitOrOp.boOr,LeftExpression,ParseBitXor);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseComparison:TNodeExpression;
var LeftExpression:TNodeExpression;
    RightExpression:TNodeExpression;
    OperatorToken:TLexer.TTokenKind;
    ComparisonOperation:TCompareOp;
    TestName:TPinjaRawByteString;
    TestParameters:TNodeExpressions;
begin
 LeftExpression:=ParseBitOr;
 while fLexer.Kind in [TLexer.TTokenKind.tkEq,TLexer.TTokenKind.tkNe,TLexer.TTokenKind.tkLt,TLexer.TTokenKind.tkLe,TLexer.TTokenKind.tkGt,TLexer.TTokenKind.tkGe,
                       TLexer.TTokenKind.tkIn,TLexer.TTokenKind.tkNotIn,TLexer.TTokenKind.tkIs,TLexer.TTokenKind.tkIsNot] do begin
  OperatorToken:=fLexer.Kind; 
  fLexer.Next;

  if OperatorToken in [TLexer.TTokenKind.tkIs,TLexer.TTokenKind.tkIsNot] then begin
   if fLexer.Kind=TLexer.TTokenKind.tkIdent then begin
    TestName:=fLexer.Token; 
    fLexer.Next;
     
    // Check if the test has parameters
    TestParameters:=TNodeExpressions.Create;
    try

     // Handle both parentheses syntax (optional) and space-separated syntax
     if fLexer.Kind=TLexer.TTokenKind.tkLParen then begin
      // Optional parentheses syntax: test(param1, param2)
      fLexer.Next; // consume '('

      // Parse parameters
      if fLexer.Kind<>TLexer.TTokenKind.tkRParen then begin
       TestParameters.Add(ParseExpression);

       while fLexer.Kind=TLexer.TTokenKind.tkComma do begin
        fLexer.Next; // consume ','
        TestParameters.Add(ParseExpression);
       end;
      end;

      if fLexer.Kind=TLexer.TTokenKind.tkRParen then begin
       fLexer.Next; // consume ')'
      end else begin
       // Clean up parameters on error
       FreeAndNil(TestParameters);
       raise Exception.Create('Expected '')'' after test parameters');
      end;
     end else if not (fLexer.Kind in [TLexer.TTokenKind.tkEq,TLexer.TTokenKind.tkNe,TLexer.TTokenKind.tkLt,TLexer.TTokenKind.tkLe,TLexer.TTokenKind.tkGt,TLexer.TTokenKind.tkGe,
                                      TLexer.TTokenKind.tkIn,TLexer.TTokenKind.tkNotIn,TLexer.TTokenKind.tkIs,TLexer.TTokenKind.tkIsNot,
                                      TLexer.TTokenKind.tkAnd,TLexer.TTokenKind.tkOr,TLexer.TTokenKind.tkRParen,TLexer.TTokenKind.tkComma,
                                      TLexer.TTokenKind.tkEOF,TLexer.TTokenKind.tkPercent,TLexer.TTokenKind.tkRBrace]) then begin
      // Jinja2 space-separated syntax: test param1 param2
      // Parse a single parameter (most tests only take one parameter)
      TestParameters.Add(ParseExpression);
     end;

    finally
     if assigned(TestParameters) and (TestParameters.Count=0) then begin
      FreeAndNil(TestParameters);
     end;
    end;

    LeftExpression:=TNodeExpressionIs.Create(OperatorToken=TLexer.TTokenKind.tkIsNot,TestName,LeftExpression,TestParameters);
    continue;
   end else begin
    result:=LeftExpression;
    exit;
   end;
  end;

  case OperatorToken of
   TLexer.TTokenKind.tkEq:begin
    ComparisonOperation:=TPinja.TCompareOp.coEq;
   end;
   TLexer.TTokenKind.tkNe:begin
    ComparisonOperation:=TPinja.TCompareOp.coNe;
   end;
   TLexer.TTokenKind.tkLt:begin
    ComparisonOperation:=TPinja.TCompareOp.coLt;
   end;
   TLexer.TTokenKind.tkLe:begin
    ComparisonOperation:=TPinja.TCompareOp.coLe;
   end;
   TLexer.TTokenKind.tkGt:begin
    ComparisonOperation:=TPinja.TCompareOp.coGt;
   end;
   TLexer.TTokenKind.tkGe:begin
    ComparisonOperation:=TPinja.TCompareOp.coGe;
   end;
   TLexer.TTokenKind.tkIn:begin
    ComparisonOperation:=TPinja.TCompareOp.coIn;
   end;
   TLexer.TTokenKind.tkNotIn:begin
    ComparisonOperation:=TPinja.TCompareOp.coNotIn;
   end;
   else begin
    ComparisonOperation:=TPinja.TCompareOp.coEq;
   end;
  end;
  
  RightExpression:=ParseBitOr;
  
  LeftExpression:=TNodeExpressionCompare.Create(ComparisonOperation,LeftExpression,RightExpression);

 end;

 result:=LeftExpression;

end;

function TPinja.TParser.ParseAnd:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseComparison;
 while fLexer.Kind=TLexer.TTokenKind.tkAnd do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionLogical.Create(TPinja.TLogicalOp.loAnd,LeftExpression,ParseComparison);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseOr:TNodeExpression;
var LeftExpression:TNodeExpression;
begin
 LeftExpression:=ParseAnd;
 while fLexer.Kind=TLexer.TTokenKind.tkOr do begin
  fLexer.Next;
  LeftExpression:=TNodeExpressionLogical.Create(TPinja.TLogicalOp.loOr,LeftExpression,ParseAnd);
 end;
 result:=LeftExpression;
end;

function TPinja.TParser.ParseTernary:TNodeExpression;
var thenE,condE,elseE:TNodeExpression;
begin
 thenE:=ParseOr;
 if fLexer.Kind=TLexer.TTokenKind.tkIf then begin
  fLexer.Next;
  condE:=ParseOr;
  if fLexer.Kind=TLexer.TTokenKind.tkElse then begin
   fLexer.Next;
  end;
  elseE:=ParseTernary; // right-assoc on else branch 
  result:=TNodeExpressionTernary.Create(thenE,condE,elseE);
 end else begin
  result:=thenE;
 end;
end;

function TPinja.TParser.ParseExpression:TNodeExpression;
begin
 result:=ParseTernary;
end;

//==============================================================================
// Template wrapper                                                              
//==============================================================================

function ExtractParts(const aSource:TPinjaRawByteString;const aOptions:TPinja.TOptions;aParts:TPinjaObjectList):TPinjaInt32;
var Position,SourceLength:TPinjaInt32;
    StartPosition:TPinjaInt32;
    SliceText,TagText,ExpressionText:TPinjaRawByteString;

 procedure AddText(const s:TPinjaRawByteString);
 begin
  aParts.Add(TPinja.TNodeStatementText.Create(s));
 end;

 procedure AddTagMarker(const TagText:TPinjaRawByteString);
 begin
  aParts.Add(nil); // marker 
  aParts.Add(TPinja.TNodeStatementText.Create('{%'+TagText+'%}'));
 end;

 function Remaining(aPos,aLen:TPinjaInt32):TPinjaInt32;
 begin
  if ((aLen-aPos)+1)<0 then begin
   result:=0;
  end else begin
   result:=(aLen-aPos)+1;
  end; 
 end;

 procedure LeftStripPending(var aString:TPinjaRawByteString;const aStrong:Boolean);
 // aStrong = true  -> hyphen form:strip spaces/tabs and one newline (CR/LF)
 // aStrong = false -> LStripBlocks:strip trailing spaces/tabs only if at line end
 var Position:TPinjaInt32;
 begin
  if Length(aString)=0 then begin
   exit;
  end;
  Position:=Length(aString);
  // strip trailing spaces/tabs 
  while (Position>0) and ((aString[Position]=' ') or (aString[Position]=#9)) do begin
   dec(Position);
  end;
  if aStrong then begin
   // also remove single CR/LF pair if present 
   if (Position>0) and (aString[Position]=#10) then begin
    dec(Position);
   end;
   if (Position>0) and (aString[Position]=#13) then begin
    dec(Position);
   end;
  end;
  SetLength(aString,Position);
 end;

 procedure RightStripFromPos(var aIndex:TPinjaInt32;const aLen:TPinjaInt32;const aEatNewline:Boolean);
 // Skip spaces/tabs; then if aEatNewline,also skip single CR/LF pair 
 begin
  while (aIndex<=aLen) and ((aSource[aIndex]=' ') or (aSource[aIndex]=#9)) do begin
   inc(aIndex);
  end;
  if aEatNewline then begin
   if (aIndex<=aLen) and (aSource[aIndex]=#13) then begin
    inc(aIndex);
   end;
   if (aIndex<=aLen) and (aSource[aIndex]=#10) then begin
    inc(aIndex);
   end;
  end;
 end;

var LeftTrim,RightTrim:Boolean;
    ContentStart,ContentEnd:TPinjaInt32;
    ExpressionParser:TPinja.TParser;
begin
 result:=0;
 Position:=1; 
 SourceLength:=Length(aSource); 
 StartPosition:=0;

 while Position<=SourceLength do begin
  // {{ expr }} 
  if (Position<SourceLength) and (aSource[Position]='{') and (aSource[Position+1]='{') then begin
   if StartPosition<>0 then begin
    SliceText:=Copy(aSource,StartPosition,Position-StartPosition);
    // left trim for expressions if '{{-' 
    LeftTrim:=(Position+2<=SourceLength) and (aSource[Position+2]='-');
    if LeftTrim then begin
     LeftStripPending(SliceText,true);
    end else if TPinja.TOption.LStripBlocks in aOptions then begin
     LeftStripPending(SliceText,false);
    end;
    AddText(SliceText);
   end;

   inc(Position,2);
   LeftTrim:=false;
   RightTrim:=false;
   if (Position<=SourceLength) and (aSource[Position]='-') then begin 
    LeftTrim:=true;
    inc(Position); 
   end;

   ContentStart:=Position;
   // find close,detect right hyphen 
   while (Position<SourceLength) and not ((aSource[Position]='}') and (aSource[Position+1]='}')) do begin
    inc(Position);
   end;
   ContentEnd:=Position-1;
   if (ContentEnd>=ContentStart) and (aSource[ContentEnd]='-') then begin
    RightTrim:=true;
    dec(ContentEnd);
   end;
   ExpressionText:=Trim(Copy(aSource,ContentStart,ContentEnd-ContentStart+1));
   ExpressionParser:=TPinja.TParser.Create(ExpressionText);
   try
    aParts.Add(TPinja.TNodeStatementExpression.Create(ExpressionParser.ParseExpression));
   finally
    FreeAndNil(ExpressionParser);
   end;

   inc(Position,2); // skip '}}'
   if RightTrim then begin
    RightStripFromPos(Position,SourceLength,true);
   end;

   StartPosition:=Position;
   continue;
  end;

  // {% tag %}
  if (Position<SourceLength) and (aSource[Position]='{') and (aSource[Position+1]='%') then begin
   if StartPosition<>0 then begin
    SliceText:=Copy(aSource,StartPosition,Position-StartPosition);
    LeftTrim:=(Position+2<=SourceLength) and (aSource[Position+2]='-');
    if LeftTrim then begin
     LeftStripPending(SliceText,true);
    end else if TPinja.TOption.LStripBlocks in aOptions then begin
     LeftStripPending(SliceText,false);
    end;
    AddText(SliceText);
   end;

   inc(Position,2);
   LeftTrim:=false;
   RightTrim:=false;
   if (Position<=SourceLength) and (aSource[Position]='-') then begin 
    LeftTrim:=true;
    inc(Position); 
   end;

   ContentStart:=Position;
   while (Position<SourceLength) and not ((aSource[Position]='%') and (aSource[Position+1]='}')) do begin
    inc(Position);
   end;
   ContentEnd:=Position-1;
   if (ContentEnd>=ContentStart) and (aSource[ContentEnd]='-') then begin
    RightTrim:=true;
    dec(ContentEnd);
   end;
   TagText:=Trim(Copy(aSource,ContentStart,ContentEnd-ContentStart+1));
   AddTagMarker(TagText);

   inc(Position,2); // skip '%}'
   if RightTrim then begin
    RightStripFromPos(Position,SourceLength,true);
   end else if TPinja.TOption.TrimBlocks in aOptions then begin
    RightStripFromPos(Position,SourceLength,true);
   end;

   StartPosition:=Position;
   continue;
  end;

  // {# comment #} 
  if (Position<SourceLength) and (aSource[Position]='{') and (aSource[Position+1]='#') then begin
   if StartPosition<>0 then begin
    SliceText:=Copy(aSource,StartPosition,Position-StartPosition);
    LeftTrim:=(Position+2<=SourceLength) and (aSource[Position+2]='-');
    if LeftTrim then begin
     LeftStripPending(SliceText,true);
    end else if TPinja.TOption.LStripBlocks in aOptions then begin
     LeftStripPending(SliceText,false);
    end;
    AddText(SliceText);
   end;

   inc(Position,2);
   LeftTrim:=false;
   RightTrim:=false;
   if (Position<=SourceLength) and (aSource[Position]='-') then begin 
    LeftTrim:=true;
    inc(Position); 
   end;

   ContentStart:=Position;
   while (Position<SourceLength) and not ((aSource[Position]='#') and (aSource[Position+1]='}')) do begin
    inc(Position);
   end;
   ContentEnd:=Position-1;
   if (ContentEnd>=ContentStart) and (aSource[ContentEnd]='-') then begin
    RightTrim:=true;
    dec(ContentEnd);
   end;
   // ignore comment content

   inc(Position,2); // skip '#}'
   if RightTrim then begin
    RightStripFromPos(Position,SourceLength,true);
   end;

   StartPosition:=Position;
   continue;
  end;

  if StartPosition=0 then begin
   StartPosition:=Position;
  end;
  inc(Position);
 end;

 if (StartPosition<>0) and (StartPosition<=SourceLength+1) then begin
  AddText(Copy(aSource,StartPosition,Remaining(StartPosition,SourceLength)));
 end;
end;

function BuildAST(const aParts:TPinjaObjectList):TPinja.TNodeStatementBlock;

 function IsMarker(aObj:TObject):Boolean;
 begin
  result:=(aObj=nil);
 end;

 function TagTextFromNode(aN:TPinja.TNodeStatementText):TPinjaRawByteString;
 begin
  result:=Trim(Copy(aN.fText,3,Length(aN.fText)-4)); // strip "{%" + "%}"
 end;

 function ParseExpression(const aString:TPinjaRawByteString):TPinja.TNodeExpression;
 var Parser:TPinja.TParser;
 begin
  Parser:=TPinja.TParser.Create(aString);
  try
   result:=Parser.ParseExpression;
  finally
   FreeAndNil(Parser);
  end;
 end;

 function SplitTopLevel(const aString:TPinjaRawByteString;aSeparator:AnsiChar):TStringList;
 var ResultList:TStringList;
     Index,StringLength,BracketLevel:TPinjaInt32;
     QuoteChar:AnsiChar;
     TokenBuffer:TPinjaRawByteString;
 begin
  ResultList:=TStringList.Create;
  TokenBuffer:='';
  StringLength:=Length(aString);
  BracketLevel:=0;
  QuoteChar:=#0;
  Index:=1;
  while Index<=StringLength do begin
   if (QuoteChar=#0) and ((aString[Index]='''') or (aString[Index]='"')) then begin
    QuoteChar:=aString[Index];
    TokenBuffer:=TokenBuffer+aString[Index];
   end else if (QuoteChar<>#0) then begin
    TokenBuffer:=TokenBuffer+aString[Index];
    if aString[Index]='\' then begin
     inc(Index);
     if Index<=StringLength then begin
      TokenBuffer:=TokenBuffer+aString[Index];
     end;
    end else if aString[Index]=QuoteChar then begin
     QuoteChar:=#0;
    end;
   end else begin
    if (aString[Index]='(') or (aString[Index]='[') or (aString[Index]='{') then begin
     inc(BracketLevel);
    end else if (aString[Index]=')') or (aString[Index]=']') or (aString[Index]='}') then begin
     dec(BracketLevel);
    end;
    if (BracketLevel=0) and (aString[Index]=aSeparator) then begin
     ResultList.Add(Trim(TokenBuffer));
     TokenBuffer:='';
    end else begin
     TokenBuffer:=TokenBuffer+aString[Index];
    end;
   end;
   inc(Index);
  end;
  if Length(Trim(TokenBuffer))>0 then begin
   ResultList.Add(Trim(TokenBuffer));
  end;
  result:=ResultList;
 end;

 function ParseFilterChain(const s:TPinjaRawByteString):TPinja.TNodeStatementFilterBlock;
 var PartsList:TStringList;
     Index:TPinjaInt32;
     Segment,FilterName,ArgumentsText:TPinjaRawByteString;
     Position1,Position2:TPinjaInt32;
     ArgumentsParser:TPinja.TParser;
     Arguments:TPinja.TNodeExpressionArgumentList;
     FilterBody:TPinja.TNodeStatementBlock;
 begin
  FilterBody:=TPinja.TNodeStatementBlock.Create; // placeholder,caller replaces with real body
  result:=TPinja.TNodeStatementFilterBlock.Create(FilterBody);
  PartsList:=SplitTopLevel(s,'|');
  try
   for Index:=0 to PartsList.Count-1 do begin
    Segment:=Trim(PartsList[Index]);
    if Length(Segment)=0 then begin
     continue;
    end;
    Position1:=Pos('(',Segment);
    if Position1>0 then begin
     Position2:=LastDelimiter(')',Segment);
     FilterName:=Trim(Copy(Segment,1,Position1-1));
     ArgumentsText:=Trim(Copy(Segment,Position1+1,Position2-Position1-1));
     ArgumentsParser:=TPinja.TParser.Create('('+ArgumentsText+')');
     try
      Arguments:=ArgumentsParser.ParseArgs;
      result.AddFilter(FilterName,Arguments);
     finally
      FreeAndNil(ArgumentsParser);
     end;
    end else begin
     FilterName:=Segment;
     Arguments:=TPinja.TNodeExpressionArgumentList.Create;
     result.AddFilter(FilterName,Arguments);
    end;
   end;
  finally
   FreeAndNil(PartsList);
  end;
 end;

 function ReadBlockUntil(var aIdx:TPinjaInt32;out aEndTag:TPinjaRawByteString;const aEnd:array of TPinjaRawByteString):TPinja.TNodeStatementBlock;

  function StartsWithCI(const aString,aPrefix:TPinjaRawByteString):Boolean;
  begin
   result:=SameText(Copy(aString,1,Length(aPrefix)),aPrefix);
  end;

 var Block:TPinja.TNodeStatementBlock;
     TagText,EndTag:TPinjaRawByteString;
     VariableNames,Expression,ExpressionString,ConditionString,HeaderText,
     MacroName,ParameterList,KeyName,ValueName,Item:TPinjaRawByteString;
     Index,EqualsPosition,InPosition,IfPosition,CommaPosition,Position1,Position2,
     BlockIndex:TPinjaInt32;
     Body,NestedBody:TPinja.TNodeStatementBlock;
     Parser:TPinja.TParser;
     Condition:TPinja.TNodeExpression;
     IFNode:TPinja.TNodeStatementIf;
     Filter:TPinja.TNodeStatementFilterBlock;
     Macro:TPinja.TNodeStatementMacroDefinition;
     CallStatement:TPinja.TNodeStatementCall;
     Parts:TStringList;
     DefaultExpression:TPinja.TNodeExpression;
     Arguments:TPinja.TNodeExpressionArgumentList;
     IsTopLevel:Boolean;
 begin

  IsTopLevel:=length(aEnd)=0;

  Block:=TPinja.TNodeStatementBlock.Create;

  try

   while aIdx<aParts.Count do begin

    if IsMarker(aParts[aIdx]) then begin

     // read tag text from the paired SText node
     TagText:=TagTextFromNode(TPinja.TNodeStatementText(aParts[aIdx+1]));

     // terminators (prefix match,case-insensitive) - only check if not top-level
     if not IsTopLevel then begin
      for Index:=0 to length(aEnd)-1 do begin
       if StartsWithCI(TagText,aEnd[Index]) then begin
        aEndTag:=aEnd[Index];
        inc(aIdx,2); // consume the marker + its text
        result:=Block;
        exit;
       end;
      end;
     end;

     // simple flow tags
     if SameText(TagText,'break') then begin
      Block.Add(TPinja.TNodeStatementBreak.Create);
      inc(aIdx,2);
      continue;
     end;

     if SameText(TagText,'continue') then begin
      Block.Add(TPinja.TNodeStatementContinue.Create);
      inc(aIdx,2);
      continue;
     end;

     // IF
     if StartsWithCI(TagText,'if ') then begin
      IFNode:=TPinja.TNodeStatementIf.Create;
      Condition:=ParseExpression(Trim(Copy(TagText,4,MaxInt)));
      BlockIndex:=aIdx+2;
      Body:=ReadBlockUntil(BlockIndex,EndTag,['elif','else','endif']);
      IFNode.AddBranch(Condition,Body);

      while SameText(EndTag,'elif') do begin
       // the 'elif <expr>' tag text is at BlockIndex-1
       TagText:=TagTextFromNode(TPinja.TNodeStatementText(aParts[BlockIndex-1]));
       Condition:=ParseExpression(Trim(Copy(TagText,5,MaxInt))); // after "elif "
       Body:=ReadBlockUntil(BlockIndex,EndTag,['elif','else','endif']);
       IFNode.AddBranch(Condition,Body);
      end;

      if SameText(EndTag,'else') then begin
       Body:=ReadBlockUntil(BlockIndex,EndTag,['endif']);
       IFNode.SetElse(Body);
      end;

      Block.Add(IFNode);
      aIdx:=BlockIndex;
      continue;
     end;

     // FOR
     if StartsWithCI(TagText,'for ') then begin
      Expression:=Trim(Copy(TagText,5,MaxInt)); // "<names> in <expr> [if <expr>]"
      InPosition:=Pos(' in ',Expression);
      if InPosition<=0 then begin
       raise Exception.Create('for syntax:for name[,name] in expr [if expr]');
      end;

      VariableNames:=Trim(Copy(Expression,1,InPosition-1));
      Expression:=Trim(Copy(Expression,InPosition+4,MaxInt));

      // Optional trailing " if <expr>"
      IfPosition:=Pos(' if ',Expression);
      if IfPosition>0 then begin
       ExpressionString:=Trim(Copy(Expression,1,IfPosition-1));
       ConditionString:=Trim(Copy(Expression,IfPosition+4,MaxInt));
      end else begin
       ExpressionString:=Expression;
       ConditionString:='';
      end;

      // Split key/value
      CommaPosition:=Pos(',',VariableNames);
      if CommaPosition>0 then begin
       KeyName:=Trim(Copy(VariableNames,1,CommaPosition-1));
       ValueName:=Trim(Copy(VariableNames,CommaPosition+1,MaxInt));
      end else begin
       KeyName:='';
       ValueName:=VariableNames;
      end;

      BlockIndex:=aIdx+2;
      Body:=ReadBlockUntil(BlockIndex,EndTag,['endfor']);
      if not SameText(EndTag,'endfor') then begin
       raise Exception.Create('Unterminated for-block');
      end;

      Parser:=TPinja.TParser.Create(ExpressionString);
      try
       if Length(ConditionString)>0 then begin
        Block.Add(TPinja.TNodeStatementFor.Create(KeyName,ValueName,Parser.ParseExpression,ParseExpression(ConditionString),Body));
       end else begin
        Block.Add(TPinja.TNodeStatementFor.Create(KeyName,ValueName,Parser.ParseExpression,nil,Body));
       end;
      finally
       FreeAndNil(Parser);
      end;

      aIdx:=BlockIndex;
      continue;
     end;

     // SET (inline or block)
     if StartsWithCI(TagText,'set ') then begin
      Expression:=Trim(Copy(TagText,5,MaxInt)); // either "name = expr" or just "name"
      EqualsPosition:=Pos('=',Expression);
      if EqualsPosition>0 then begin
       // inline: {% set name = expr %}
       VariableNames:=Trim(Copy(Expression,1,EqualsPosition-1));
       Expression:=Trim(Copy(Expression,EqualsPosition+1,MaxInt));
       Parser:=TPinja.TParser.Create(Expression);
       try
        Block.Add(TPinja.TNodeStatementSet.Create(VariableNames,Parser.ParseExpression));
       finally
        FreeAndNil(Parser);
       end;
       inc(aIdx,2);
       continue;
      end else begin
       // Block: {% set name %} ... {% endset %}
       VariableNames:=Expression; // just the variable name
       BlockIndex:=aIdx+2;
       NestedBody:=ReadBlockUntil(BlockIndex,EndTag,['endset']);
       if not SameText(EndTag,'endset') then begin
        raise Exception.Create('Unterminated set-block');
       end;
       Block.Add(TPinja.TNodeStatementSetBlock.Create(VariableNames,NestedBody));
       aIdx:=BlockIndex;
       continue;
      end;
     end;

     // FILTER
     if StartsWithCI(TagText,'filter ') then begin
      Expression:=Trim(Copy(TagText,8,MaxInt)); // the filter chain
      Filter:=ParseFilterChain(Expression);

      BlockIndex:=aIdx+2;
      NestedBody:=ReadBlockUntil(BlockIndex,EndTag,['endfilter']);
      if not SameText(EndTag,'endfilter') then begin
       raise Exception.Create('Unterminated filter-block');
      end;

      // Replace placeholder body
      if Assigned(Filter.fBody) then begin
       FreeAndNil(Filter.fBody);
      end;
      Filter.fBody:=NestedBody;

      Block.Add(Filter);
      aIdx:=BlockIndex;
      continue;
     end;

     // Macro
     if StartsWithCI(TagText,'macro ') then begin
      HeaderText:=Trim(Copy(TagText,7,MaxInt)); // "name(args...)"
      Position1:=Pos('(',HeaderText);
      Position2:=LastDelimiter(')',HeaderText);
      if (Position1<=0) or (Position2<=Position1) then begin
       raise Exception.Create('macro syntax:macro name(args)');
      end;

      MacroName:=Trim(Copy(HeaderText,1,Position1-1));
      ParameterList:=Trim(Copy(HeaderText,Position1+1,Position2-Position1-1));

      // Build Macro object with placeholder Body
      NestedBody:=TPinja.TNodeStatementBlock.Create;
      Macro:=TPinja.TNodeStatementMacroDefinition.Create(MacroName,NestedBody);

      // Parse parameters: "a,b, kw=expr, ..."
      Parts:=SplitTopLevel(ParameterList,',');
      try
       for Item in Parts do begin
        if Trim(Item)='' then begin
         continue;
        end;
        EqualsPosition:=Pos('=',Item);
        if EqualsPosition>0 then begin
         VariableNames:=Trim(Copy(Item,1,EqualsPosition-1));
         Expression:=Trim(Copy(Item,EqualsPosition+1,MaxInt));
         DefaultExpression:=ParseExpression(Expression);
         Macro.AddKwDefault(VariableNames,DefaultExpression);
        end else begin
         Macro.AddPosName(Trim(Item));
        end;
       end;
      finally
       FreeAndNil(Parts);
      end;

      // Read the Body
      BlockIndex:=aIdx+2;
      Body:=ReadBlockUntil(BlockIndex,EndTag,['endmacro']);
      if not SameText(EndTag,'endmacro') then begin
       raise Exception.Create('Unterminated macro');
      end;

      // Swap in the real Body
      if Assigned(Macro.fBody) and (Macro.fBody<>Body) then begin
       FreeAndNil(Macro.fBody);
       Macro.fBody:=Body;
      end;

      Block.Add(Macro);
      aIdx:=BlockIndex;
      continue;
     end;

     // CALL
     if StartsWithCI(TagText,'call') then begin
      HeaderText:=Trim(Copy(TagText,5,MaxInt)); // everything after "call"
      
      // Check if we have call parameters: call(param1, param2) macro_name(args)
      Position1:=0;
      Position2:=0;
      if (Length(HeaderText)>0) and (HeaderText[1]='(') then begin
       // Parse call parameters
       Position2:=Pos(')',HeaderText);
       if Position2<=1 then begin
        raise Exception.Create('call syntax: call(params) macro_name(args) or call macro_name(args)');
       end;
       ParameterList:=Trim(Copy(HeaderText,2,Position2-2)); // between ( and )
       HeaderText:=Trim(Copy(HeaderText,Position2+1,MaxInt)); // after )
      end else begin
       ParameterList:='';
       HeaderText:=Trim(HeaderText);
      end;
      
      // Now parse the macro call: macro_name(args...)
      Position1:=Pos('(',HeaderText);
      Position2:=LastDelimiter(')',HeaderText);
      if (Position1<=0) or (Position2<=Position1) then begin
       raise Exception.Create('call syntax: call(params) macro_name(args) or call macro_name(args)');
      end;

      MacroName:=Trim(Copy(HeaderText,1,Position1-1));
      Expression:=Trim(Copy(HeaderText,Position1+1,Position2-Position1-1)); // macro arguments

      // Parse macro arguments
      Parser:=TPinja.TParser.Create('dummy('+Expression+')');
      try
       Parser.fLexer.Next; // skip 'dummy'
       Parser.fLexer.Next; // skip '('
       if Parser.fLexer.Kind<>TPinja.TLexer.TTokenKind.tkRParen then begin
        Arguments:=Parser.ParseArgs;
       end else begin
        Arguments:=nil;
       end;
      finally
       FreeAndNil(Parser);
      end;

      // Read the body
      BlockIndex:=aIdx+2;
      NestedBody:=ReadBlockUntil(BlockIndex,EndTag,['endcall']);
      if not SameText(EndTag,'endcall') then begin
       raise Exception.Create('Unterminated call-block');
      end;

      // Create the call statement
      CallStatement:=TPinja.TNodeStatementCall.Create(MacroName,Arguments,NestedBody);
      
      // Parse call parameters if any
      if ParameterList<>'' then begin
       Parts:=SplitTopLevel(ParameterList,',');
       try
        for Item in Parts do begin
         if Trim(Item)<>'' then begin
          CallStatement.AddCallParameter(Trim(Item));
         end;
        end;
       finally
        FreeAndNil(Parts);
       end;
      end;

      Block.Add(CallStatement);
      aIdx:=BlockIndex;
      continue;
     end;

     // GENERATION
     if SameText(TagText,'generation') then begin
      BlockIndex:=aIdx+2;
      NestedBody:=ReadBlockUntil(BlockIndex,EndTag,['endgeneration']);
      if not SameText(EndTag,'endgeneration') then begin
       raise Exception.Create('Unterminated generation-block');
      end;

      Block.Add(TPinja.TNodeStatementGeneration.Create(NestedBody));
      aIdx:=BlockIndex;
      continue;
     end;

     // unknown tag inside a block (or stray end-tag at top-level)
     if IsTopLevel then begin
      raise Exception.Create('Unexpected tag at top-level: '+TagText);
     end else begin
      raise Exception.Create('Unexpected tag inside block: '+TagText);
     end;
    end else begin
     // regular prebuilt node (text or expression)
     Block.Add(TPinja.TNodeStatement(aParts[aIdx]));
     aParts[aIdx]:=nil;
     inc(aIdx);
    end;
   end;

   // if we got here and not top-level, no terminator was found
   if not IsTopLevel then begin
    aEndTag:='';
    raise Exception.Create('Unexpected end of template while searching for block terminator');
   end;
   
   // For top-level, reaching here is normal (end of template)
   aEndTag:='';
   result:=Block;
   
  except
   on E:Exception do begin
    // free partially built block on error,then re-raise
    FreeAndNil(Block);
    raise;
   end;
  end;
 end;

var Root:TPinja.TNodeStatementBlock;
    BlockIndex:TPinjaInt32;
    EndTag:TPinjaRawByteString;
begin
 BlockIndex:=0;
 Root:=ReadBlockUntil(BlockIndex,EndTag,[]); // Top-level: no terminators
 result:=Root;
end;

constructor TPinja.TTemplate.Create(const aSource:TPinjaRawByteString;const aOptions:TOptions);
var Parts:TPinjaObjectList;
begin
 inherited Create;
 fOptions:=aOptions;
 Parts:=TPinjaObjectList.Create(false);
 try
  ExtractParts(aSource,aOptions,Parts);
  fRoot:=BuildAST(Parts);
 finally
  Parts.OwnsObjects:=true;
  FreeAndNil(Parts);
 end;
end;

destructor TPinja.TTemplate.Destroy;
begin
 FreeAndNil(fRoot);
 inherited;
end;

procedure TPinja.TTemplate.Render(const aContext:TContext;const aOutput:TRawByteStringOutput);
var StringValue:TPinjaRawByteString;
begin
 if assigned(fRoot) then begin
  fRoot.Render(aContext,aOutput);
 end;
 if not (TPinja.TOption.KeepTrailingNewline in fOptions) then begin
  StringValue:=aOutput.AsString;
  if (Length(StringValue)>=2) and (StringValue[Length(StringValue)-1]=#13) and (StringValue[Length(StringValue)]=#10) then begin
   Delete(StringValue,Length(StringValue)-1,2);
  end else if (Length(StringValue)>=1) and (StringValue[Length(StringValue)]=#10) then begin
   Delete(StringValue,Length(StringValue),1);
  end;
  aOutput.Clear;
  aOutput.AddString(StringValue);
 end;
end;

function TPinja.TTemplate.RenderToString(const aContext:TContext):TPinjaRawByteString;
var Output:TRawByteStringOutput;
begin
 Output:=TRawByteStringOutput.Create;
 try
  Render(aContext,Output);
  result:=Output.AsString;
 finally
  FreeAndNil(Output);
 end;
end;

end.
