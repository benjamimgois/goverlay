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
unit PasVulkan.Value;
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
     Variants,
     PasDblStrUtils,
     PasVulkan.Types;

type PpvValueType=^TpvValueType;
     TpvValueType=
      (
       Unknown,
       Boolean,
       Integer,
       Double,
       Char,
       String_
      );

     PPpvValue=^PpvValue;
     PpvValue=^TpvValue;
     TpvValue=record
      public
       class operator Implicit(const aInput:boolean):TpvValue; inline;
       class operator Implicit(const aInput:TpvInt64):TpvValue; inline;
       class operator Implicit(const aInput:TpvDouble):TpvValue; inline;
       class operator Implicit(const aInput:Char):TpvValue; inline;
       class operator Implicit(const aInput:String):TpvValue; inline;
       class operator Implicit(const aInput:Variant):TpvValue; inline;
       class operator Implicit(const aInput:TpvValue):boolean;
       class operator Implicit(const aInput:TpvValue):TpvInt64;
       class operator Implicit(const aInput:TpvValue):TpvDouble;
       class operator Implicit(const aInput:TpvValue):Char;
       class operator Implicit(const aInput:TpvValue):String;
       class operator Implicit(const aInput:TpvValue):Variant;
       class operator Explicit(const aInput:boolean):TpvValue; inline;
       class operator Explicit(const aInput:TpvInt64):TpvValue; inline;
       class operator Explicit(const aInput:TpvDouble):TpvValue; inline;
       class operator Explicit(const aInput:Char):TpvValue; inline;
       class operator Explicit(const aInput:String):TpvValue; inline;
       class operator Explicit(const aInput:Variant):TpvValue; inline;
       class operator Explicit(const aInput:TpvValue):boolean;
       class operator Explicit(const aInput:TpvValue):TpvInt64;
       class operator Explicit(const aInput:TpvValue):TpvDouble;
       class operator Explicit(const aInput:TpvValue):Char;
       class operator Explicit(const aInput:TpvValue):String;
       class operator Explicit(const aInput:TpvValue):Variant;
       class operator Equal(const aInputA,aInputB:TpvValue):boolean;
       class operator NotEqual(const aInputA,aInputB:TpvValue):boolean;
       class operator GreaterThan(const aInputA,aInputB:TpvValue):boolean;
       class operator GreaterThanOrEqual(const aInputA,aInputB:TpvValue):boolean;
       class operator LessThan(const aInputA,aInputB:TpvValue):boolean;
       class operator LessThanOrEqual(const aInputA,aInputB:TpvValue):boolean;
       class operator Inc(const aInput:TpvValue):TpvValue;
       class operator Dec(const aInput:TpvValue):TpvValue;
       class operator Add(const aInputA,aInputB:TpvValue):TpvValue;
       class operator Subtract(const aInputA,aInputB:TpvValue):TpvValue;
       class operator Multiply(const aInputA,aInputB:TpvValue):TpvValue;
       class operator Divide(const aInputA,aInputB:TpvValue):TpvValue;
       class operator IntDivide(const aInputA,aInputB:TpvValue):TpvValue;
       class operator Modulus(const aInputA,aInputB:TpvValue):TpvValue;
       class operator LeftShift(const aInputA,aInputB:TpvValue):TpvValue;
       class operator RightShift(const aInputA,aInputB:TpvValue):TpvValue;
{      class operator LogicalAnd(const aInputA,aInputB:TpvValue):TpvValue;
       class operator LogicalOr(const aInputA,aInputB:TpvValue):TpvValue;
       class operator LogicalXor(const aInputA,aInputB:TpvValue):TpvValue;}
       class operator BitwiseAnd(const aInputA,aInputB:TpvValue):TpvValue;
       class operator BitwiseOr(const aInputA,aInputB:TpvValue):TpvValue;
       class operator BitwiseXor(const aInputA,aInputB:TpvValue):TpvValue;
       class operator Negative(const aInput:TpvValue):TpvValue;
       class operator Positive(const aInput:TpvValue):TpvValue;
      public
       ValueString:string;
       case ValueType:TpvValueType of
        TpvValueType.Unknown:(
        );
        TpvValueType.Boolean:(
         ValueBoolean:Boolean;
        );
        TpvValueType.Integer:(
         ValueInt64:Int64;
        );
        TpvValueType.Double:(
         ValueDouble:Double;
        );
        TpvValueType.Char:(
         ValueChar:Char;
        );
     end;

implementation

class operator TpvValue.Implicit(const aInput:boolean):TpvValue;
begin
 result.ValueType:=TpvValueType.Boolean;
 result.ValueBoolean:=aInput;
end;

class operator TpvValue.Implicit(const aInput:TpvInt64):TpvValue;
begin
 result.ValueType:=TpvValueType.Integer;
 result.ValueInt64:=aInput;
end;

class operator TpvValue.Implicit(const aInput:TpvDouble):TpvValue;
begin
 result.ValueType:=TpvValueType.Double;
 result.ValueDouble:=aInput;
end;

class operator TpvValue.Implicit(const aInput:Char):TpvValue;
begin
 result.ValueType:=TpvValueType.Char;
 result.ValueChar:=aInput;
end;

class operator TpvValue.Implicit(const aInput:String):TpvValue;
begin
 result.ValueType:=TpvValueType.String_;
 result.ValueString:=aInput;
end;

class operator TpvValue.Implicit(const aInput:Variant):TpvValue;
begin
 case VarType(aInput) of
  varSmallInt,varInteger,varShortInt,varByte,varWord,varLongWord,varInt64{$ifdef fpc},varQWord{$endif}:begin
   result.ValueType:=TpvValueType.Integer;
   result.ValueInt64:=aInput;
  end;
  varSingle,varDouble,varDATE,varCurrency:begin
   result.ValueType:=TpvValueType.Double;
   result.ValueDouble:=aInput;
  end;
  varBoolean:begin
   result.ValueType:=TpvValueType.Boolean;
   result.ValueBoolean:=aInput;
  end;
  varString,varOleStr:begin
   result.ValueType:=TpvValueType.String_;
   result.ValueString:=aInput;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):boolean;
begin
case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=aInput.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64<>0;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble<>0.0;
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar<>#0;
  end;
  TpvValueType.String_:begin
   result:=length(aInput.ValueString)>0;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):TpvInt64;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=ord(aInput.ValueBoolean) and 1;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=trunc(aInput.ValueDouble);
  end;
  TpvValueType.Char:begin
   result:=StrToIntDef(aInput.ValueChar,0);
  end;
  TpvValueType.String_:begin
   result:=StrToIntDef(aInput.ValueString,0);
  end;
  else begin
   result:=0;
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):TpvDouble;
begin
case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=ord(aInput.ValueBoolean) and 1;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble;
  end;
  TpvValueType.Char:begin
   result:=ConvertStringToDouble(aInput.ValueChar,rmNearest,nil,-1);
  end;
  TpvValueType.String_:begin
   result:=ConvertStringToDouble(aInput.ValueString,rmNearest,nil,-1);
  end;
  else begin
   result:=0.0;
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):Char;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   if aInput.ValueBoolean then begin
    result:=#1;
   end else begin
    result:=#0;
   end;
  end;
  TpvValueType.Integer:begin
   result:=chr(aInput.ValueInt64);
  end;
  TpvValueType.Double:begin
   result:=chr(trunc(aInput.ValueDouble));
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   if length(aInput.ValueString)>0 then begin
    result:=aInput.ValueString[1];
   end else begin
    result:=#0;
   end;
  end;
  else begin
   result:=#0;
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):String;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   if aInput.ValueBoolean then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end;
  TpvValueType.Integer:begin
   result:=IntToStr(aInput.ValueInt64);
  end;
  TpvValueType.Double:begin
   result:=ConvertDoubleToString(aInput.ValueDouble,omStandard,0);
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   result:=aInput.ValueString;
  end;
  else begin
   result:='';
  end;
 end;
end;

class operator TpvValue.Implicit(const aInput:TpvValue):Variant;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=aInput.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble;
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   result:=aInput.ValueString;
  end;
  else begin
   result:=Variants.Unassigned;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:boolean):TpvValue;
begin
 result.ValueType:=TpvValueType.Boolean;
 result.ValueBoolean:=aInput;
end;

class operator TpvValue.Explicit(const aInput:TpvInt64):TpvValue;
begin
 result.ValueType:=TpvValueType.Integer;
 result.ValueInt64:=aInput;
end;

class operator TpvValue.Explicit(const aInput:TpvDouble):TpvValue;
begin
 result.ValueType:=TpvValueType.Double;
 result.ValueDouble:=aInput;
end;

class operator TpvValue.Explicit(const aInput:Char):TpvValue;
begin
 result.ValueType:=TpvValueType.Char;
 result.ValueChar:=aInput;
end;

class operator TpvValue.Explicit(const aInput:String):TpvValue;
begin
 result.ValueType:=TpvValueType.String_;
 result.ValueString:=aInput;
end;

class operator TpvValue.Explicit(const aInput:Variant):TpvValue;
begin
 case VarType(aInput) of
  varSmallInt,varInteger,varShortInt,varByte,varWord,varLongWord,varInt64{$ifdef fpc},varQWord{$endif}:begin
   result.ValueType:=TpvValueType.Integer;
   result.ValueInt64:=aInput;
  end;
  varSingle,varDouble,varDATE,varCurrency:begin
   result.ValueType:=TpvValueType.Double;
   result.ValueDouble:=aInput;
  end;
  varBoolean:begin
   result.ValueType:=TpvValueType.Boolean;
   result.ValueBoolean:=aInput;
  end;
  varString,varOleStr:begin
   result.ValueType:=TpvValueType.String_;
   result.ValueString:=aInput;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):boolean;
begin
case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=aInput.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64<>0;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble<>0.0;
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar<>#0;
  end;
  TpvValueType.String_:begin
   result:=length(aInput.ValueString)>0;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):TpvInt64;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=ord(aInput.ValueBoolean) and 1;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=trunc(aInput.ValueDouble);
  end;
  TpvValueType.Char:begin
   result:=StrToIntDef(aInput.ValueChar,0);
  end;
  TpvValueType.String_:begin
   result:=StrToIntDef(aInput.ValueString,0);
  end;
  else begin
   result:=0;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):TpvDouble;
begin
case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=ord(aInput.ValueBoolean) and 1;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble;
  end;
  TpvValueType.Char:begin
   result:=ConvertStringToDouble(aInput.ValueChar,rmNearest,nil,-1);
  end;
  TpvValueType.String_:begin
   result:=ConvertStringToDouble(aInput.ValueString,rmNearest,nil,-1);
  end;
  else begin
   result:=0.0;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):Char;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   if aInput.ValueBoolean then begin
    result:=#1;
   end else begin
    result:=#0;
   end;
  end;
  TpvValueType.Integer:begin
   result:=chr(aInput.ValueInt64);
  end;
  TpvValueType.Double:begin
   result:=chr(trunc(aInput.ValueDouble));
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   if length(aInput.ValueString)>0 then begin
    result:=aInput.ValueString[1];
   end else begin
    result:=#0;
   end;
  end;
  else begin
   result:=#0;
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):String;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   if aInput.ValueBoolean then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end;
  TpvValueType.Integer:begin
   result:=IntToStr(aInput.ValueInt64);
  end;
  TpvValueType.Double:begin
   result:=ConvertDoubleToString(aInput.ValueDouble,omStandard,0);
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   result:=aInput.ValueString;
  end;
  else begin
   result:='';
  end;
 end;
end;

class operator TpvValue.Explicit(const aInput:TpvValue):Variant;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result:=aInput.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result:=aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result:=aInput.ValueDouble;
  end;
  TpvValueType.Char:begin
   result:=aInput.ValueChar;
  end;
  TpvValueType.String_:begin
   result:=aInput.ValueString;
  end;
  else begin
   result:=Variants.Unassigned;
  end;
 end;
end;

class operator TpvValue.Equal(const aInputA,aInputB:TpvValue):boolean;
begin
case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean=aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean=boolean(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar=aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar=aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.NotEqual(const aInputA,aInputB:TpvValue):boolean;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean<>aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean<>boolean(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64<>(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64<>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64<>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)<>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble<>(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble<>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble<>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)<>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<>aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar<>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<>aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString<>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.GreaterThan(const aInputA,aInputB:TpvValue):boolean;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean>aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean>(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64>(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble>(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble>aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble>aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar>aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar>aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.GreaterThanOrEqual(const aInputA,aInputB:TpvValue):boolean;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean>=aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)>=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)>=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean>=boolean(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64>=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64>=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64>=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)>=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble>=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble>=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble>=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)>aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar>=aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar>=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar>=aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString>=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.LessThan(const aInputA,aInputB:TpvValue):boolean;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean<aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean<boolean(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64<(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64<aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64<aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)<aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble<(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble<aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble<aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)<aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar<aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString<aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.LessThanOrEqual(const aInputA,aInputB:TpvValue):boolean;
begin
case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueBoolean<=aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=(ord(aInputA.ValueBoolean) and 1)<=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueBoolean<=boolean(length(aInputB.ValueString)>0);
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueInt64<=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueInt64<=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueInt64<=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=IntToStr(aInputA.ValueInt64)<=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result:=aInputA.ValueDouble<=(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result:=aInputA.ValueDouble<=aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result:=aInputA.ValueDouble<=aInputB.ValueDouble;
    end;
    TpvValueType.String_:begin
     result:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)<=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<=aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueChar<=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Char:begin
     result:=aInputA.ValueChar<=aInputB.ValueString;
    end;
    TpvValueType.String_:begin
     result:=aInputA.ValueString<=aInputB.ValueString;
    end;
    else begin
     result:=false;
    end;
   end;
  end;
  else begin
   result:=false;
  end;
 end;
end;

class operator TpvValue.Inc(const aInput:TpvValue):TpvValue;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result.ValueType:=TpvValueType.Boolean;
   result.ValueBoolean:=not result.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result.ValueType:=TpvValueType.Integer;
   result.ValueInt64:=aInput.ValueInt64+1;
  end;
  TpvValueType.Double:begin
   result.ValueType:=TpvValueType.Double;
   result.ValueDouble:=aInput.ValueDouble+1;
  end;
  TpvValueType.Char:begin
   result.ValueType:=TpvValueType.Char;
   result.ValueChar:=aInput.ValueChar;
   inc(result.ValueChar);
  end;
  TpvValueType.String_:begin
   result.ValueType:=TpvValueType.Unknown;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Dec(const aInput:TpvValue):TpvValue;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result.ValueType:=TpvValueType.Boolean;
   result.ValueBoolean:=not result.ValueBoolean;
  end;
  TpvValueType.Integer:begin
   result.ValueType:=TpvValueType.Integer;
   result.ValueInt64:=aInput.ValueInt64-1;
  end;
  TpvValueType.Double:begin
   result.ValueType:=TpvValueType.Double;
   result.ValueDouble:=aInput.ValueDouble-1;
  end;
  TpvValueType.Char:begin
   result.ValueType:=TpvValueType.Char;
   result.ValueChar:=aInput.ValueChar;
   dec(result.ValueChar);
  end;
  TpvValueType.String_:begin
   result.ValueType:=TpvValueType.Unknown;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Add(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean xor aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1)+aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=(ord(aInputA.ValueBoolean) and 1)+aInputB.ValueDouble;
    end;
    TpvValueType.Char:begin
     result.ValueType:=TpvValueType.String_;
     if aInputA.ValueBoolean then begin
      result.ValueString:='true'+aInputB.ValueChar;
     end else begin
      result.ValueString:='false'+aInputB.ValueChar;
     end;
    end;
    TpvValueType.String_:begin
     result.ValueType:=TpvValueType.String_;
     if aInputA.ValueBoolean then begin
      result.ValueString:='true'+aInputB.ValueString;
     end else begin
      result.ValueString:='false'+aInputB.ValueString;
     end;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64+(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64+aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64+aInputB.ValueDouble;
    end;
    TpvValueType.Char:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=IntToStr(aInputA.ValueInt64)+aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=IntToStr(aInputA.ValueInt64)+aInputB.ValueString;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble+(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble+aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble+aInputB.ValueDouble;
    end;
    TpvValueType.Char:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)+aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=ConvertDoubleToString(aInputA.ValueDouble,omStandard,0)+aInputB.ValueString;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Char:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.String_;
     if aInputB.ValueBoolean then begin
      result.ValueString:=aInputA.ValueChar+'true';
     end else begin
      result.ValueString:=aInputA.ValueChar+'false';
     end;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueChar+IntToStr(aInputB.ValueInt64);
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueChar+ConvertDoubleToString(aInputB.ValueDouble,omStandard,0);
    end;
    TpvValueType.Char:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueChar+aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueChar+aInputB.ValueString;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.String_:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.String_;
     if aInputB.ValueBoolean then begin
      result.ValueString:=aInputA.ValueString+'true';
     end else begin
      result.ValueString:=aInputA.ValueString+'false';
     end;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueString+IntToStr(aInputB.ValueInt64);
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueString+ConvertDoubleToString(aInputB.ValueDouble,omStandard,0);
    end;
    TpvValueType.Char:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueString+aInputB.ValueChar;
    end;
    TpvValueType.String_:begin
     result.ValueType:=TpvValueType.String_;
     result.ValueString:=aInputA.ValueString+aInputB.ValueString;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Subtract(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean xor aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1)-aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=(ord(aInputA.ValueBoolean) and 1)-aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64-(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64-aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64-aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble-(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble-aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble-aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Multiply(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64*(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64*aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64*aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*(ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Divide(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64/aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64/aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.IntDivide(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 div aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64/aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/aInputB.ValueDouble;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Modulus(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 mod aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64-(floor(aInputA.ValueInt64*aInputB.ValueDouble)/aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble-(floor(aInputA.ValueDouble*aInputB.ValueInt64)/aInputB.ValueInt64);
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble-(floor(aInputA.ValueDouble*aInputB.ValueDouble)/aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.LeftShift(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=int64(ord(aInputA.ValueBoolean) and 1) shl aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=(ord(aInputA.ValueBoolean) and 1)*power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 shl (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 shl aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64*power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*(2.0*(ord(aInputB.ValueBoolean) and 1));
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*power(2.0,aInputB.ValueInt64);
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.RightShift(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=int64(ord(aInputA.ValueBoolean) and 1) shr aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=(ord(aInputA.ValueBoolean) and 1)/power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 shr (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 shr aInputB.ValueInt64;
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueInt64/power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Double:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble*(0.5*(ord(aInputB.ValueBoolean) and 1));
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/power(2.0,aInputB.ValueInt64);
    end;
    TpvValueType.Double:begin
     result.ValueType:=TpvValueType.Double;
     result.ValueDouble:=aInputA.ValueDouble/power(2.0,aInputB.ValueDouble);
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

{class operator TpvValue.LogicalAnd(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean and aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) and aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 and (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 and aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.LogicalOr(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean or aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) or aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 or (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 or aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.LogicalXor(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean xor aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) xor aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 xor (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 xor aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;}

class operator TpvValue.BitwiseAnd(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean and aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) and aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 and (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 and aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.BitwiseOr(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean or aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) or aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 or (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 or aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.BitwiseXor(const aInputA,aInputB:TpvValue):TpvValue;
begin
 case aInputA.ValueType of
  TpvValueType.Boolean:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Boolean;
     result.ValueBoolean:=aInputA.ValueBoolean xor aInputB.ValueBoolean;
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=(ord(aInputA.ValueBoolean) and 1) xor aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  TpvValueType.Integer:begin
   case aInputB.ValueType of
    TpvValueType.Boolean:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 xor (ord(aInputB.ValueBoolean) and 1);
    end;
    TpvValueType.Integer:begin
     result.ValueType:=TpvValueType.Integer;
     result.ValueInt64:=aInputA.ValueInt64 xor aInputB.ValueInt64;
    end;
    else begin
     result.ValueType:=TpvValueType.Unknown;
    end;
   end;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Negative(const aInput:TpvValue):TpvValue;
begin
 case aInput.ValueType of
  TpvValueType.Boolean:begin
   result.ValueType:=TpvValueType.Unknown;
  end;
  TpvValueType.Integer:begin
   result.ValueType:=TpvValueType.Integer;
   result.ValueInt64:=-aInput.ValueInt64;
  end;
  TpvValueType.Double:begin
   result.ValueType:=TpvValueType.Double;
   result.ValueDouble:=-aInput.ValueDouble;
  end;
  TpvValueType.Char:begin
   result.ValueType:=TpvValueType.Unknown;
  end;
  TpvValueType.String_:begin
   result.ValueType:=TpvValueType.Unknown;
  end;
  else begin
   result.ValueType:=TpvValueType.Unknown;
  end;
 end;
end;

class operator TpvValue.Positive(const aInput:TpvValue):TpvValue;
begin
 result:=aInput;
end;

end.

