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
unit PasVulkan.Scene3D.Renderer.Exposure;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}
{$scopedenums on}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.VirtualReality,
     PasVulkan.VirtualFileSystem;

type TpvScene3DRendererExposure=class
      public
       type TUnitKind=(
             Exposure,
             EV100,
             Luminance,
             Illuminance
            );
      private
       fUnitKind:TUnitKind;
       fExposure:TpvFloat;
       fEV100:TpvFloat;
       fLuminance:TpvFloat;
       fIlluminace:TpvFloat;
       procedure SetExposure(const aExposure:TpvFloat);
       procedure SetEV100(const aEV100:TpvFloat);
       procedure SetLuminance(const aLuminance:TpvFloat);
       procedure SetIlluminace(const aIlluminace:TpvFloat);
       function GetLMax:TpvFloat;
      public
       constructor Create; reintroduce;
       constructor CreateFromCameraProperties(const aAperture,aShutterSpeed,aISOSensitivity:TpvFloat);
       constructor CreateFromCamera(const aFlangeFocalDistance,aFocalLength,aFNumber:TpvFloat);
       destructor Destroy; override;
       procedure Assign(const aFrom:TpvScene3DRendererExposure);
       procedure SetFromCameraProperties(const aAperture,aShutterSpeed,aISOSensitivity:TpvFloat);
       procedure SetFromCamera(const aFlangeFocalDistance,aFocalLength,aFNumber:TpvFloat);
       procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
       function SaveToJSON:TPasJSONItemObject;
      public 
       property UnitKind:TUnitKind read fUnitKind write fUnitKind;
       property Exposure:TpvFloat read fExposure write SetExposure;
       property EV100:TpvFloat read fEV100 write SetEV100;
       property Luminance:TpvFloat read fLuminance write SetLuminance;
       property Illuminace:TpvFloat read fIlluminace write SetIlluminace;
       property LMax:TpvFloat read GetLMax;
     end;
     
     PpvScene3DRendererExposure=^TpvScene3DRendererExposure;

implementation

// References: https://en.wikipedia.org/wiki/Exposure_value and https://en.wikipedia.org/wiki/Film_speed
//
// This comprehensive comment merges the mathematical framework and principles for calculating exposure values (EV) in both photography 
// and digital imaging. It integrates essential concepts such as aperture (N), shutter speed (t), ISO sensitivity (S), luminance (L), and 
// illuminance (E), pivotal for achieving the desired luminance in images or simulating realistic lighting conditions in 3D rendering 
// environments. Additionally, it incorporates key calibration constants:
//
//   K for reflected-light meters (typically 12.5)
//   C for incident-light meters (typically 250)
//   q for lens and vignetting attenuation (typically 0.65)
//
// Together, these variables and constants form the foundation of the exposure calculation process, underscoring the intricate balance 
// between light capture and sensor sensitivity in photographic science and visual arts.
//
// Calculating EV100 from aperture, shutter speed, and sensitivity:
//
//   EV100 is derived to standardize exposure across different ISO settings, using the formula:
//
//     EV100 = log2((N^2 / t) * (100 / S))
//
//   This formula balances the aperture, shutter speed, and sensitivity to calculate a standardized exposure value.
//
// Relating luminance to exposure:
//
//   The average scene luminance (L) is related to exposure through the reflected-light meter calibration constant (K), with the formula:
//
//     EV = log2(L * S / K)
//
//   For standard settings (K = 12.5), this simplifies to EV100 calculation as:
//
//     EV100 = log2(L * 100 / 12.5)
//
// Incorporating illuminance into exposure calculations:
//
//   Illuminance (E) affects exposure through the incident-light meter calibration constant (C), with:
//
//     EV100 = log2(E * 100 / C)
//
//   For a typical sensor calibration (C = 250), this formula adjusts EV100 based on illuminance.
//
// Defining photometric exposure (H):
//
//   H quantifies the total light exposure on a surface, factored by lens attenuation (q), with:
//
//     H = (q * t / (N^2)) * L
//
//   This concept is pivotal for understanding how light interacts with camera sensors.
//
// Saturation-based sensitivity (S_sat) and maximum luminance (Lmax):
//
//   The saturation-based sensitivity method uses a constant (78) to define the maximum exposure without clipping, considering an 18% 
//   reflective surface and specular reflections. This leads to the formula for Lmax, indicating the sensor's maximum luminance capacity
//   without saturation:
//
//     Lmax = (78 / (S * q)) * (N^2 / t)
//
//   Adjusted for typical values, this formula helps in calculating the maximum luminance a sensor can capture, crucial for avoiding 
//   overexposure.
//
// Normalizing pixel values in rendering:
//
//   The incident luminance (L) at a pixel's position is normalized against Lmax, facilitating realistic rendering of light intensity 
//   and contrast in digital images or 3D scenes.
//
// Together, these formulas offer a robust method for simulating realistic photographic exposure, enabling precise control over digital 
// imaging and rendering processes by mimicking the physical properties of light and camera behavior.
//
// Variables and Constants:
//
//   - N: Aperture, controlling the amount of light reaching the sensor.
//   - t: Shutter Speed, the duration the sensor is exposed to light.
//   - S: Sensitivity (ISO), affecting exposure and image noise levels.
//   - L: Average Scene Luminance, the brightness of the scene.
//   - E: Illuminance, the total luminous flux incident on a surface.
//   - K: Reflected-light Meter Calibration Constant, typically 12.5.
//   - C: Incident-light Meter Calibration Constant, typically 250.
//   - q: Lens and Vignetting Attenuation Factor, typically 0.65.
//   - H: Photometric Exposure, the total light exposure on a surface.
//   - Lmax: Maximum Luminance, the highest luminance a sensor can capture without saturation.
//   - S_sat: Saturation-based Sensitivity, defining maximum exposure without clipping.
//
// Formulas and Applications:
//
//   1. Exposure Value (EV) Calculation:
//      - Basic EV for a given ISO: EVs = log2(N^2 / t)
//      - Adjusting EV for ISO Sensitivity: EVs = EV100 + log2(S / 100)
//      - Deriving EV100: EV100 = log2((N^2 / t) * (100 / S))
//
//   2. Luminance and Exposure:
//      - Calculating EV from luminance: EV = log2(L * S / K)
//      - Direct relation of EV100 to luminance: EV100 = log2(L * 100 / 12.5)
//
//   3. Illuminance and Exposure:
//      - Incorporating illuminance into EV calculation: EV = log2(E * S / C) or EV100 = log2(E * 100 / C)
//      - Standard calculation with C = 250: EV100 = log2(E * 100 / 250)
//
//   4. Photometric Exposure (H):
//      - Defining H with attenuation factor: H = (q * t / (N^2)) * L
//      - Saturation-based sensitivity for maximum exposure: S_sat = 78 / H_sat
//
//   5. Maximum Luminance (Lmax):
//      - Calculating Lmax to avoid sensor saturation: Lmax = (78 / (S * q)) * (N^2 / t)
//      - Adjusted formula for typical q and S values: Lmax = 1.2 * 2^EV100
//
//   6. Normalizing Pixel Values:
//      - Normalizing incident luminance with Lmax for rendering: Pixel Value = L / Lmax
//
    
constructor TpvScene3DRendererExposure.Create;
begin
 inherited Create;
 fUnitKind:=TUnitKind.Exposure;
 fExposure:=1.0;
 fEV100:=0.0;
 fLuminance:=0.0;
 fIlluminace:=0.0;
end;

constructor TpvScene3DRendererExposure.CreateFromCameraProperties(const aAperture,aShutterSpeed,aISOSensitivity:TpvFloat);
begin
 inherited Create;
 SetFromCameraProperties(aAperture,aShutterSpeed,aISOSensitivity);
end;

constructor TpvScene3DRendererExposure.CreateFromCamera(const aFlangeFocalDistance,aFocalLength,aFNumber:TpvFloat);
begin
 inherited Create;
 SetFromCamera(aFlangeFocalDistance,aFocalLength,aFNumber);
end;

destructor TpvScene3DRendererExposure.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererExposure.Assign(const aFrom:TpvScene3DRendererExposure);
begin
 fUnitKind:=aFrom.fUnitKind;
 fExposure:=aFrom.fExposure;
 fEV100:=aFrom.fEV100;
 fLuminance:=aFrom.fLuminance;
 fIlluminace:=aFrom.fIlluminace;
end;

procedure TpvScene3DRendererExposure.SetExposure(const aExposure:TpvFloat);
begin
 fUnitKind:=TUnitKind.Exposure;
 fExposure:=aExposure;
 fEV100:=Log2(1.0/(1.2*fExposure));
 fLuminance:=0.1041666666667/fExposure; // Power(2.0,fEV100-3.0); 1/96
 fIlluminace:=2.08333333333333/fExposure; // 2.5*Power(2.0,fEV100); 25/12
end;

procedure TpvScene3DRendererExposure.SetEV100(const aEV100:TpvFloat);
begin
 fUnitKind:=TUnitKind.EV100;
 fExposure:=1.0/(1.2*Power(2.0,aEV100));
 fEV100:=aEV100; 
 fLuminance:=Exp2(fEV100-3.0);
 fIlluminace:=2.5*Exp2(fEV100);
end;

procedure TpvScene3DRendererExposure.SetLuminance(const aLuminance:TpvFloat);
begin
 fUnitKind:=TUnitKind.Luminance;
 fExposure:=0.1041666666667/aLuminance; // 1.0/(1.2*aLuminance*(100.0/12.5));
 fEV100:=Log2(aLuminance*(100.0/12.5));
 fLuminance:=aLuminance;
 fIlluminace:=20.0*aLuminance; // 2.5*(aLuminance*(100.0/12.5));
end;

procedure TpvScene3DRendererExposure.SetIlluminace(const aIlluminace:TpvFloat);
begin
 fUnitKind:=TUnitKind.Illuminance;
 fExposure:=2.08333333333333/aIlluminace; // 1.0/(1.2*aIlluminace*(100.0/250.0));
 fEV100:=Log2(aIlluminace*(100.0/250.0));
 fLuminance:=aIlluminace*0.05; // Power(2.0,Log2(aIlluminace*(100.0/250.0))-3.0);
 fIlluminace:=aIlluminace;
end;

procedure TpvScene3DRendererExposure.SetFromCameraProperties(const aAperture,aShutterSpeed,aISOSensitivity:TpvFloat);
var e:TpvFloat;
begin
 fUnitKind:=TUnitKind.Exposure;
 e:=(sqr(aAperture)*100.0)/(aShutterSpeed*aISOSensitivity);
 fExposure:=1.0/(1.2*e);
 fEV100:=Log2(e);
 fLuminance:=e*0.125;
 fIlluminace:=e*2.5;
end;

procedure TpvScene3DRendererExposure.SetFromCamera(const aFlangeFocalDistance,aFocalLength,aFNumber:TpvFloat);
begin
 // Original formula source: http://research.tri-ace.com/Data/S2015/05_ImplementationBokeh-S2015.pptx on slide 25
 // Hint: Flange focal distance is the distance from lens to sensor
 fUnitKind:=TUnitKind.Exposure;
 fExposure:=((aFlangeFocalDistance/aFocalLength)*aFNumber)/(PI*4.0);
 fEV100:=Log2(1.0/(1.2*fExposure));
 fLuminance:=0.1041666666667/fExposure;
 fIlluminace:=2.08333333333333/fExposure;
end;

function TpvScene3DRendererExposure.GetLMax:TpvFloat;
begin
 result:=1.2*Exp2(fEV100);
end;

procedure TpvScene3DRendererExposure.LoadFromJSON(const aJSONItem:TPasJSONItem);
var Item:TPasJSONItem;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  Item:=TPasJSONItemObject(aJSONItem).Properties['exposure'];
  if assigned(Item) and (Item is TPasJSONItemNumber) then begin
   SetExposure(TPasJSON.GetNumber(Item,fExposure));
  end else begin 
   Item:=TPasJSONItemObject(aJSONItem).Properties['ev100'];
   if assigned(Item) and (Item is TPasJSONItemNumber) then begin
    SetEV100(TPasJSON.GetNumber(Item,fEV100));
   end else begin 
    Item:=TPasJSONItemObject(aJSONItem).Properties['luminance'];
    if assigned(Item) and (Item is TPasJSONItemNumber) then begin
     SetLuminance(TPasJSON.GetNumber(Item,fLuminance));
    end else begin 
     Item:=TPasJSONItemObject(aJSONItem).Properties['illuminace'];
     if assigned(Item) and (Item is TPasJSONItemNumber) then begin
      SetIlluminace(TPasJSON.GetNumber(Item,fIlluminace));
     end;
    end;
   end;
  end;
 end;
end;

function TpvScene3DRendererExposure.SaveToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 case fUnitKind of
  TUnitKind.Exposure:begin
   result.Add('exposure',TPasJSONItemNumber.Create(fExposure));
  end;
  TUnitKind.EV100:begin
   result.Add('ev100',TPasJSONItemNumber.Create(fEV100));
  end;
  TUnitKind.Luminance:begin
   result.Add('luminance',TPasJSONItemNumber.Create(fLuminance));
  end;
  TUnitKind.Illuminance:begin
   result.Add('illuminace',TPasJSONItemNumber.Create(fIlluminace));
  end;
  else begin
   result.Add('exposure',TPasJSONItemNumber.Create(fExposure));
  end;
 end; 
end;

end.
