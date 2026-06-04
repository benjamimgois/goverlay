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
unit PasVulkan.Scene3D.Renderer.Instance.ColorGrading;
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
     Vulkan,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.JSON;

type { TpvScene3DRendererInstanceColorGradingSettings }
     TpvScene3DRendererInstanceColorGradingSettings=packed record
      public

       Exposure:TpvFloat;
       NightAdaptiation:TpvFloat;
       WhiteBalanceTemperature:TpvFloat;
       WhiteBalanceTint:TpvFloat;

       ChannelMixerRed:TpvVector4;
       ChannelMixerGreen:TpvVector4;
       ChannelMixerBlue:TpvVector4;

       Shadows:TpvVector4;
       Midtones:TpvVector4;
       Highlights:TpvVector4;
       TonalRanges:TpvVector4;

       ASCCDLSlope:TpvVector4;
       ASCCDLOffset:TpvVector4;
       ASCCDLPower:TpvVector4;

       Offset:TpvVector4;

       Contrast:TpvFloat;
       Vibrance:TpvFloat;
       Saturation:TpvFloat;
       Hue:TpvFloat;

       CurvesGamma:TpvVector4;
       CurvesMidPoint:TpvVector4;
       CurvesScale:TpvVector4;

      public
       procedure SetLiftGammaGain(const aLift,aGamma,aGain:TpvVector3);
       procedure LoadFromJSON(const aJSON:TPasJSONItem);
       procedure LoadFromJSONStream(const aStream:TStream);
       procedure LoadFromJSONFile(const aFileName:string);
       function SaveToJSON:TPasJSONItemObject;
       procedure SaveToJSONStream(const aStream:TStream);
       procedure SaveToJSONFile(const aFileName:string);
     end;
     PpvScene3DRendererInstanceColorGradingSettings=^TpvScene3DRendererInstanceColorGradingSettings;

     TpvScene3DRendererInstanceColorGradingSettingsArray=array[0..3] of TpvScene3DRendererInstanceColorGradingSettings;
     PpvScene3DRendererInstanceColorGradingSettingsArray=^TpvScene3DRendererInstanceColorGradingSettingsArray;

const DefaultColorGradingSettings:TpvScene3DRendererInstanceColorGradingSettings=(

       Exposure:0.0;
       NightAdaptiation:0.0;
       WhiteBalanceTemperature:0.0;
       WhiteBalanceTint:0.0;

       ChannelMixerRed:(x:1.0;y:0.0;z:0.0;w:0.0);
       ChannelMixerGreen:(x:0.0;y:1.0;z:0.0;w:0.0);
       ChannelMixerBlue:(x:0.0;y:0.0;z:1.0;w:0.0);
       
       Shadows:(x:1.0;y:1.0;z:1.0;w:1.0);
       Midtones:(x:1.0;y:1.0;z:1.0;w:1.0);
       Highlights:(x:1.0;y:1.0;z:1.0;w:1.0);
       TonalRanges:(x:0.0;y:0.333;z:0.55;w:1.0);
       
       ASCCDLSlope:(x:1.0;y:1.0;z:1.0;w:1.0);
       ASCCDLOffset:(x:0.0;y:0.0;z:0.0;w:0.0);
       ASCCDLPower:(x:1.0;y:1.0;z:1.0;w:1.0);

       Offset:(x:0.0;y:0.0;z:0.0;w:0.0);
       
       Contrast:1.0;
       Vibrance:1.0;
       Saturation:1.0;
       Hue:0.0;

       CurvesGamma:(x:1.0;y:1.0;z:1.0;w:1.0);
       CurvesMidPoint:(x:1.0;y:1.0;z:1.0;w:1.0);
       CurvesScale:(x:1.0;y:1.0;z:1.0;w:1.0);

      );     

implementation

{ TpvScene3DRendererInstanceColorGradingSettings }

procedure TpvScene3DRendererInstanceColorGradingSettings.SetLiftGammaGain(const aLift,aGamma,aGain:TpvVector3);
begin
 ASCCDLSlope:=TpvVector4.InlineableCreate(aLift*aGain,1.0);
 ASCCDLOffset:=TpvVector4.InlineableCreate((TpvVector3.InlineableCreate(1.0,1.0,1.0)-aLift)*aGain,0.0);
 if aGamma.x=0.0 then begin
  ASCCDLPower.x:=3.402823466e+38;
 end else begin
  ASCCDLPower.x:=1.0/aGamma.x;
 end;
 if aGamma.y=0.0 then begin
  ASCCDLPower.y:=3.402823466e+38;
 end else begin
  ASCCDLPower.y:=1.0/aGamma.y;
 end;
 if aGamma.z=0.0 then begin
  ASCCDLPower.z:=3.402823466e+38;
 end else begin
  ASCCDLPower.z:=1.0/aGamma.z;
 end;
end;

procedure TpvScene3DRendererInstanceColorGradingSettings.LoadFromJSON(const aJSON:TPasJSONItem);
begin
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  Exposure:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['exposure'],Exposure);
  NightAdaptiation:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['nightadaptiation'],NightAdaptiation);
  WhiteBalanceTemperature:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['whitebalancetemperature'],WhiteBalanceTemperature*100.0)*0.01;
  WhiteBalanceTint:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['whitebalancetint'],WhiteBalanceTint*100.0)*0.01;
  ChannelMixerRed:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['channelmixerred'],ChannelMixerRed);
  ChannelMixerGreen:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['channelmixergreen'],ChannelMixerGreen);
  ChannelMixerBlue:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['channelmixerblue'],ChannelMixerBlue);
  Shadows:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['shadows'],Shadows);
  Midtones:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['midtones'],Midtones);
  Highlights:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['highlights'],Highlights);
  TonalRanges:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['tonalranges'],TonalRanges);
  ASCCDLSlope:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['asccdlslope'],ASCCDLSlope);
  ASCCDLOffset:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['asccdloffset'],ASCCDLOffset);
  ASCCDLPower:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['asccdlpower'],ASCCDLPower);
  Offset:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['offset'],Offset);
  Contrast:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['contrast'],Contrast);
  Vibrance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['vibrance'],Vibrance);
  Saturation:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['saturation'],Saturation);
  Hue:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['hue'],Hue);
  CurvesGamma:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['curvesgamma'],CurvesGamma);
  CurvesMidPoint:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['curvesmidpoint'],CurvesMidPoint);
  CurvesScale:=JSONToVector4(TPasJSONItemObject(aJSON).Properties['curvesscale'],CurvesScale);
 end;
end;

procedure TpvScene3DRendererInstanceColorGradingSettings.LoadFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DRendererInstanceColorGradingSettings.LoadFromJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  LoadFromJSONStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
end;

function TpvScene3DRendererInstanceColorGradingSettings.SaveToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 result.Add('exposure',TPasJSONItemNumber.Create(Exposure));
 result.Add('nightadaptiation',TPasJSONItemNumber.Create(NightAdaptiation));
 result.Add('whitebalancetemperature',TPasJSONItemNumber.Create(WhiteBalanceTemperature*100.0));
 result.Add('whitebalancetint',TPasJSONItemNumber.Create(WhiteBalanceTint*100.0));
 result.Add('channelmixerred',Vector4ToJSON(ChannelMixerRed));
 result.Add('channelmixergreen',Vector4ToJSON(ChannelMixerGreen));
 result.Add('channelmixerblue',Vector4ToJSON(ChannelMixerBlue));
 result.Add('shadows',Vector4ToJSON(Shadows));
 result.Add('midtones',Vector4ToJSON(Midtones));
 result.Add('highlights',Vector4ToJSON(Highlights));
 result.Add('tonalranges',Vector4ToJSON(TonalRanges));
 result.Add('asccdlslope',Vector4ToJSON(ASCCDLSlope));
 result.Add('asccdloffset',Vector4ToJSON(ASCCDLOffset));
 result.Add('asccdlpower',Vector4ToJSON(ASCCDLPower));
 result.Add('offset',Vector4ToJSON(Offset));
 result.Add('contrast',TPasJSONItemNumber.Create(Contrast));
 result.Add('vibrance',TPasJSONItemNumber.Create(Vibrance));
 result.Add('saturation',TPasJSONItemNumber.Create(Saturation));
 result.Add('hue',TPasJSONItemNumber.Create(Hue));
 result.Add('curvesgamma',Vector4ToJSON(CurvesGamma));
 result.Add('curvesmidpoint',Vector4ToJSON(CurvesMidPoint));
 result.Add('curvesscale',Vector4ToJSON(CurvesScale));
end;

procedure TpvScene3DRendererInstanceColorGradingSettings.SaveToJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=SaveToJSON;
 if assigned(JSON) then begin
  try
   TPasJSON.StringifyToStream(aStream,JSON,true);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DRendererInstanceColorGradingSettings.SaveToJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToJSONStream(Stream);
  Stream.SaveToFile(aFileName);
 finally
  FreeAndNil(Stream);
 end;
end;

end.
