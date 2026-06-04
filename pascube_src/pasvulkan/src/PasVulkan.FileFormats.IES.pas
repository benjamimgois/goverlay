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
unit PasVulkan.FileFormats.IES;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$scopedenums on}

interface

uses SysUtils,
     Classes,
     Math,
     PasDblStrUtils,
     Vulkan,     
     PasVulkan.Collections,
     PasVulkan.Math,
     PasVulkan.Types;

type EpvIESLoader=class(Exception);

     { TpvIESLoader }     
     TpvIESLoader=class
      public
       type TIESVersion=
             (
              IESVersionUnknown,
              IESVersion1986, // IES LM-63-1986
              IESVersion1991, // IES LM-63-1991
              IESVersion2002, // IES LM-63-2002
              IESVersion2005, // IES LM-63-2005
              IESVersion2011  // IES LM-63-2011
             );
            PIESVersion=^TIESVersion;
            TIESPhotometricType=
             (
              TypeA,
              TypeB, 
              TypeC 
             );
            PIESPhotometricType=^TIESPhotometricType; 
            TParserState=record
             Data:TpvRawByteString;
             Position:TpvSizeInt;
            end;
            PParserState=^TParserState;
            TFloatDynamicArray=TpvDynamicArrayList<TpvFloat>;
            TTextureData=array of TpvFloat;
            TTexture=record
             Width:TpvInt32;
             Height:TpvInt32;
             Data:TTextureData;
            end;
            PTexture=^TTexture;
      private     
       fVersion:TIESVersion;
       fPhotometricType:TIESPhotometricType;
       fHorizontalAngles:TFloatDynamicArray;
       fVerticalAngles:TFloatDynamicArray;
       fCandelaValues:TFloatDynamicArray;
       fBrightness:TpvFloat;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       class procedure SkipWhiteSpace(var aParserState:TParserState); static;
       class function GetLine(var aParserState:TParserState;const aUntilWhiteSpace:Boolean):TpvRawByteString; static;
       class function GetFloat(var aParserState:TParserState;out aValue:TpvFloat):Boolean; static;
       class function GetInt32(var aParserState:TParserState;out aValue:TpvInt32):Boolean; static;
       function GetNearestCandelaValue(const aX,aY:TpvInt32):TpvFloat;
       function GetBilinearCandelaValue(const aX,aY:TpvDouble):TpvFloat;
       function GetFilterPosition(const aValue:TpvFloat;const aFloatDynamicArray:TFloatDynamicArray):TpvFloat;
       function Interpolate2D(const aHorizontalAngle,aVerticalAngle:TpvFloat):TpvFloat;
       function Interpolate1D(const aVerticalAngle:TpvFloat):TpvFloat;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure LoadFromString(const aData:TpvRawByteString);
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:TpvUTF8String);
       procedure GetTexture(out aTexture:TTexture;const a2D:Boolean);
      public
       property Version:TIESVersion read fVersion;
       property PhotometricType:TIESPhotometricType read fPhotometricType;
       property HorizontalAngles:TFloatDynamicArray read fHorizontalAngles;
       property VerticalAngles:TFloatDynamicArray read fVerticalAngles;
       property CandelaValues:TFloatDynamicArray read fCandelaValues;
       property Brightness:TpvFloat read fBrightness; 
       property Width:TpvInt32 read fWidth;
       property Height:TpvInt32 read fHeight;
     end; 

implementation

{ TpvIESLoader }

constructor TpvIESLoader.Create;
begin
 inherited Create;
 fHorizontalAngles:=TFloatDynamicArray.Create;
 fVerticalAngles:=TFloatDynamicArray.Create;
 fCandelaValues:=TFloatDynamicArray.Create;
 fVersion:=TIESVersion.IESVersionUnknown;
 fPhotometricType:=TIESPhotometricType.TypeC;
 fBrightness:=1000.0;
 fWidth:=256;
 fHeight:=256;
end; 

destructor TpvIESLoader.Destroy;
begin
 FreeAndNil(fHorizontalAngles);
 FreeAndNil(fVerticalAngles);
 FreeAndNil(fCandelaValues);
 inherited Destroy;
end;

class procedure TpvIESLoader.SkipWhiteSpace(var aParserState:TParserState);
begin
 while (aParserState.Position<=length(aParserState.Data)) and (aParserState.Data[aParserState.Position] in [#0..#32]) do begin
  inc(aParserState.Position);
 end;
end;

class function TpvIESLoader.GetLine(var aParserState:TParserState;const aUntilWhiteSpace:Boolean):TpvRawByteString;
var Index:TpvSizeInt;
begin
 result:='';
 SkipWhiteSpace(aParserState);
 while aParserState.Position<=length(aParserState.Data) do begin
  case aParserState.Data[aParserState.Position] of
   #10:begin
    inc(aParserState.Position);
    break;
   end;
   #13:begin
    inc(aParserState.Position);
    if aParserState.Position<=length(aParserState.Data) then begin
     if aParserState.Data[aParserState.Position]=#10 then begin
      inc(aParserState.Position);
     end;
    end;
    break;
   end;
   #0..#9,#11..#12,#14..#32:begin
    if aUntilWhiteSpace then begin
     break;
    end else begin
     result:=result+aParserState.Data[aParserState.Position];
     inc(aParserState.Position);
    end; 
   end;
   else begin
    result:=result+aParserState.Data[aParserState.Position];
    inc(aParserState.Position);
   end;
  end;
 end; 
end;

class function TpvIESLoader.GetFloat(var aParserState:TParserState;out aValue:TpvFloat):Boolean;
var s:TpvRawByteString;
    OK:TPasDblStrUtilsBoolean;
begin
 s:=GetLine(aParserState,true);
 if length(s)>0 then begin
  OK:=false;
  aValue:=ConvertStringToDouble(s,rmNearest,@OK,-1);
  result:=OK;
 end else begin 
  aValue:=0.0;
  result:=false;
 end;
end;

class function TpvIESLoader.GetInt32(var aParserState:TParserState;out aValue:TpvInt32):Boolean;
var Code:TpvInt32;
    s:TpvRawByteString;
begin
 s:=GetLine(aParserState,true);
 if length(s)>0 then begin
  Val(s,aValue,Code);
  result:=Code=0;
 end else begin 
  aValue:=0;
  result:=false;
 end;
end;

procedure TpvIESLoader.LoadFromString(const aData:TpvRawByteString);
var Index:TpvSizeInt; 
    ParserState:TParserState;
    Line:TpvRawByteString;
    LumensPerLamp,CandelaMultiplier,Width,Len,Height,BallastFactor,FutureUse,InputWatts,MinValue,
    Value:TpvFloat;
    CountLightCreations,CountHorizontalAngles,CountVerticalAngles,PhotometricTypeValue,UnitType:TpvInt32;
begin
 
 fVersion:=TIESVersion.IESVersion1986;

 ParserState.Data:=aData;
 ParserState.Position:=1;

 Line:=TpvIESLoader.GetLine(ParserState,false);
 if length(Line)>0 then begin
  if Line='IESNA:LM-63-1986' then begin
   fVersion:=TIESVersion.IESVersion1986;
  end else if (Line='IESNA:LM-63-1991') or (Line='IESNA91') then begin
   fVersion:=TIESVersion.IESVersion1991;
  end else if Line='IESNA:LM-63-2002' then begin
   fVersion:=TIESVersion.IESVersion2002;
  end else if Line='IESNA:LM-63-2005' then begin
   fVersion:=TIESVersion.IESVersion2005;
  end else if Line='IESNA:LM-63-2011' then begin
   fVersion:=TIESVersion.IESVersion2011;
  end else begin
   fVersion:=TIESVersion.IESVersion1986;
   ParserState.Position:=1; // Reset, because it could be a IES file without version
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 while ParserState.Position<=length(ParserState.Data) do begin
  Line:=TpvIESLoader.GetLine(ParserState,false);
  if length(Line)>0 then begin
   if (Line='TILT=NONE') or (Line='TILT= NONE') or (Line='TILT =NONE') or (Line='TILT = NONE') then begin
    break;
   end else if (pos('TILT=',UpperCase(Line))=1) or (pos('TILT =',UpperCase(Line))=1) then begin
    raise EpvIESLoader.Create('Tiled IES files are not supported');
   end;  
  end;  
 end;  

 if TpvIESLoader.GetInt32(ParserState,CountLightCreations) then begin
  if CountLightCreations<1 then begin
   raise EpvIESLoader.Create('Count of light creations needs to be greater than zero and not negative');
  end; 
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,LumensPerLamp) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if TpvIESLoader.GetFloat(ParserState,CandelaMultiplier) then begin
  if CandelaMultiplier<0.0 then begin
   raise EpvIESLoader.Create('Candela multiplier needs positive');
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if TpvIESLoader.GetInt32(ParserState,CountVerticalAngles) then begin
  if CountVerticalAngles<0 then begin
   raise EpvIESLoader.Create('Count of vertical angles needs to be positive');
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if TpvIESLoader.GetInt32(ParserState,CountHorizontalAngles) then begin
  if CountHorizontalAngles<0 then begin
   raise EpvIESLoader.Create('Count of horizontal angles needs to be positive');
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if TpvIESLoader.GetInt32(ParserState,PhotometricTypeValue) then begin
  case PhotometricTypeValue of
   1:begin
    fPhotometricType:=TIESPhotometricType.TypeC;
   end;
   2:begin
    fPhotometricType:=TIESPhotometricType.TypeB;
   end;
   3:begin
    fPhotometricType:=TIESPhotometricType.TypeA;
   end;   
   else begin
    // Fall back to type C
    fPhotometricType:=TIESPhotometricType.TypeC;
   end;
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if TpvIESLoader.GetInt32(ParserState,UnitType) then begin
  case UnitType of
   1:begin
    // Feet
   end;
   2:begin
    // Meters
   end;
   else begin
    raise EpvIESLoader.Create('Invalid IES file');
   end;
  end;
 end else begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,Width) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,Len) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,Height) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,BallastFactor) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,FutureUse) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 if not TpvIESLoader.GetFloat(ParserState,InputWatts) then begin
  raise EpvIESLoader.Create('Invalid IES file');
 end;

 begin
  MinValue:=-Infinity;
  fVerticalAngles.Resize(CountVerticalAngles);
  for Index:=0 to CountVerticalAngles-1 do begin
   if TpvIESLoader.GetFloat(ParserState,Value) then begin
    if Value<MinValue then begin
     raise EpvIESLoader.Create('Vertical angles are not in increasing order');
    end else begin
     MinValue:=Value;
     fVerticalAngles.Items[Index]:=Value;
    end; 
   end else begin 
    raise EpvIESLoader.Create('Invalid IES file');
   end;
  end;
 end;

 begin
  MinValue:=-Infinity;
  fHorizontalAngles.Resize(CountHorizontalAngles);
  for Index:=0 to CountHorizontalAngles-1 do begin
   if TpvIESLoader.GetFloat(ParserState,Value) then begin
    if Value<MinValue then begin
     raise EpvIESLoader.Create('Horizontal angles are not in increasing order');
    end else begin
     MinValue:=Value;
     fHorizontalAngles.Items[Index]:=Value;
    end; 
   end else begin 
    raise EpvIESLoader.Create('Invalid IES file');
   end;
  end;
 end;

 begin
  fCandelaValues.Resize(CountVerticalAngles*CountHorizontalAngles);
  for Index:=0 to (CountVerticalAngles*CountHorizontalAngles)-1 do begin
   if TpvIESLoader.GetFloat(ParserState,Value) then begin
    fCandelaValues.Items[Index]:=Value*CandelaMultiplier;
   end else begin 
    raise EpvIESLoader.Create('Invalid IES file');
   end;
  end;
 end;

 TpvIESLoader.SkipWhiteSpace(ParserState);

 if ParserState.Position<=length(ParserState.Data) then begin
  Line:=TpvIESLoader.GetLine(ParserState,true);
  if Line<>'END' then begin
   raise EpvIESLoader.Create('Invalid IES file');
  end;
 end;

 fBrightness:=-Infinity;
 for Index:=0 to fCandelaValues.Count-1 do begin
  fBrightness:=Max(fBrightness,fCandelaValues.Items[Index]);
 end;
 if fBrightness<=0.0 then begin
  fBrightness:=1000.0;
 end;

end;

procedure TpvIESLoader.LoadFromStream(const aStream:TStream);
var Data:TpvRawByteString;
begin
 if assigned(aStream) and (aStream.Size>0) then begin
  SetLength(Data,aStream.Size);
  aStream.Seek(0,soBeginning);
  aStream.Read(Data[1],aStream.Size);
  LoadFromString(Data);
 end else begin
  raise EpvIESLoader.Create('Invalid stream');
 end;
end;

procedure TpvIESLoader.LoadFromFile(const aFileName:TpvUTF8String);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(string(aFileName));
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

function TpvIESLoader.GetNearestCandelaValue(const aX,aY:TpvInt32):TpvFloat;
var x,y:TpvInt32;
begin
 x:=aX mod fHorizontalAngles.Count; 
 y:=aY mod fVerticalAngles.Count;
 if (x>=0) and (x<fHorizontalAngles.Count) and (y>=0) and (y<fVerticalAngles.Count) then begin
  result:=fCandelaValues.Items[(y*fVerticalAngles.Count)+x];
 end else begin
  result:=0.0;
 end;
end;

function TpvIESLoader.GetBilinearCandelaValue(const aX,aY:TpvDouble):TpvFloat;
var x,y,c:TpvInt32;
    fx,fy,ifx:TpvDouble;
    v00,v01,v10,v11:TpvFloat;
begin
 x:=trunc(aX);
 y:=trunc(aY);
 fx:=aX-x;
 fy:=aY-y;
 ifx:=1.0-fx;
 c:=fVerticalAngles.Count;
 v00:=GetNearestCandelaValue(x,y);
 v01:=GetNearestCandelaValue(x+1,y);
 v10:=GetNearestCandelaValue(x,y+1);
 v11:=GetNearestCandelaValue(x+1,y+1);
 result:=(((v00*ifx)+(v01*fx))*fy)+(((v10*ifx)+(v11*fx))*(1.0-fy));
end;

function TpvIESLoader.GetFilterPosition(const aValue:TpvFloat;const aFloatDynamicArray:TFloatDynamicArray):TpvFloat;
var StartPosition,EndPosition,TestPosition:TpvSizeInt;
    TestValue,LeftValue,RightValue,DeltaValue,Fraction:TpvFloat;
begin
 if aFloatDynamicArray.Count>0 then begin  
  StartPosition:=0;
  EndPosition:=aFloatDynamicArray.Count-1;
  if aValue<aFloatDynamicArray.Items[StartPosition] then begin
   result:=0.0;
  end else if aValue>aFloatDynamicArray.Items[EndPosition] then begin
   result:=EndPosition;
  end else begin
   while StartPosition<EndPosition do begin
    TestPosition:=((StartPosition+EndPosition)+1) shr 1;
    TestValue:=aFloatDynamicArray.Items[TestPosition];
    if aValue>=TestValue then begin
     if StartPosition=TestPosition then begin
      StartPosition:=TestPosition;
     end else begin
      StartPosition:=TestPosition;
     end;
    end else begin
     if EndPosition=TestPosition-1 then begin
      EndPosition:=TestPosition-1;
     end else begin
      EndPosition:=TestPosition-1;
     end;
    end;
   end;
   LeftValue:=aFloatDynamicArray.Items[StartPosition];
   Fraction:=0.0;
   if StartPosition+1<aFloatDynamicArray.Count then begin
    RightValue:=aFloatDynamicArray.Items[StartPosition+1];
    DeltaValue:=RightValue-LeftValue;
    if DeltaValue>0.0001 then begin
     Fraction:=(aValue-LeftValue)/DeltaValue;
    end;
   end;
   result:=StartPosition+Fraction;
  end;
 end else begin
  result:=0.0;
 end;
end;

function TpvIESLoader.Interpolate2D(const aHorizontalAngle,aVerticalAngle:TpvFloat):TpvFloat;
var x,y,z,u,v,NewHorizontalAngle,NewVerticalAngle:TpvFloat;
    HorizontalQuadrant:TpvInt32;
begin
 u:=0.0;
 v:=0.0;
 if fPhotometricType=TIESPhotometricType.TypeA then begin
  x:=Cos(aVerticalAngle*DEG2RAD);
  y:=Sin(aVerticalAngle*DEG2RAD)*Sin(aHorizontalAngle*DEG2RAD);
  z:=Sin(aVerticalAngle*DEG2RAD)*Cos(aHorizontalAngle*DEG2RAD);
  NewVerticalAngle:=ArcSin(z)*RAD2DEG;
  NewHorizontalAngle:=-ArcTan2(y,x)*RAD2DEG;
  u:=GetFilterPosition(NewHorizontalAngle,fHorizontalAngles);
  v:=GetFilterPosition(NewVerticalAngle,fVerticalAngles);
 end else begin
  if fHorizontalAngles.Count>0 then begin
   if (fHorizontalAngles.Items[fHorizontalAngles.Count-1]>0.0) and (aHorizontalAngle>fHorizontalAngles.Items[fHorizontalAngles.Count-1]) then begin
    HorizontalQuadrant:=trunc(aHorizontalAngle/fHorizontalAngles.Items[fHorizontalAngles.Count-1]);
    if (HorizontalQuadrant=1) or (HorizontalQuadrant=3) then begin
     NewHorizontalAngle:=fHorizontalAngles.Items[fHorizontalAngles.Count-1]-Frac(aHorizontalAngle/fHorizontalAngles.Items[fHorizontalAngles.Count-1]);
    end else begin
     NewHorizontalAngle:=Frac(aHorizontalAngle/fHorizontalAngles.Items[fHorizontalAngles.Count-1]);
    end;
   end else if (fHorizontalAngles.Items[0]>0.0) and (aHorizontalAngle<fHorizontalAngles.Items[0]) then begin
    NewHorizontalAngle:=(fHorizontalAngles.Items[fHorizontalAngles.Count-1]-fHorizontalAngles.Items[0])-aHorizontalAngle;
   end;
  end else begin
   NewHorizontalAngle:=aHorizontalAngle;
  end;
  u:=GetFilterPosition(NewHorizontalAngle,fHorizontalAngles);
  v:=GetFilterPosition(aVerticalAngle,fVerticalAngles);
 end;
 result:=GetBilinearCandelaValue(u,v);
end;

function TpvIESLoader.Interpolate1D(const aVerticalAngle:TpvFloat):TpvFloat;
var Index:TpvInt32;
    VerticalAngle:TpvFloat;
begin
 VerticalAngle:=GetFilterPosition(aVerticalAngle,fVerticalAngles);
 result:=0.0;
 for Index:=0 to fHorizontalAngles.Count-1 do begin
  result:=result+GetBilinearCandelaValue(Index,VerticalAngle);
 end;
 if fHorizontalAngles.Count>0 then begin
  result:=result/fHorizontalAngles.Count;
 end;
end;

procedure TpvIESLoader.GetTexture(out aTexture:TTexture;const a2D:Boolean);
var x,y:TpvInt32;
    InverseMaxValue,InverseWidth,InverseHeight,HorizontalFraction,VerticalFraction:TpvFloat;
begin

 aTexture.Width:=fWidth;
 aTexture.Height:=fHeight;
 aTexture.Data:=nil;

 SetLength(aTexture.Data,aTexture.Width*aTexture.Height);

 InverseWidth:=1.0/aTexture.Width;
 InverseHeight:=1.0/aTexture.Height;

 InverseMaxValue:=1.0/fBrightness;

 for y:=0 to aTexture.Height-1 do begin
  HorizontalFraction:=y*InverseHeight;
  for x:=0 to aTexture.Width-1 do begin
   VerticalFraction:=x*InverseWidth;
   if a2D then begin
    aTexture.Data[(y*aTexture.Width)+x]:=Interpolate2D(HorizontalFraction*360.0,VerticalFraction*180.0)*InverseMaxValue;
   end else begin
    aTexture.Data[(y*aTexture.Width)+x]:=Interpolate1D(VerticalFraction*180.0)*InverseMaxValue;
   end;
  end;
 end;

end;
    
end.
