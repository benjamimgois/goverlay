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
unit PasVulkan.Scene3D.Renderer.CameraPreset;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

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
     PasVulkan.VirtualFileSystem,
     PasVulkan.Scene3D.Renderer.Exposure;

type { TpvScene3DRendererCameraPreset }
     TpvScene3DRendererCameraPreset=class
      public
       type TExposureMode=
             (
              Auto,
              Camera,
              Manual
             );
            TShaderData=packed record
             SensorSize:TpvVector2;
             FocalLength:TpvFloat;
             FlangeFocalDistance:TpvFloat;
             FocalPlaneDistance:TpvFloat;
             FNumber:TpvFloat;
             FNumberMin:TpvFloat;
             FNumberMax:TpvFloat;
             Ngon:TpvFloat;
             HighlightThreshold:TpvFloat;
             HighlightGain:TpvFloat;
             BokehChromaticAberration:TpvFloat;
            end;
            PShaderData=^TShaderData;
      private
       fFieldOfView:TpvFloat;
       fSensorSize:TpvVector2;
       fSensorSizeProperty:TpvVector2Property;
       fFocalLength:TpvFloat;
       fFlangeFocalDistance:TpvFloat;
       fFocalPlaneDistance:TpvFloat;
       fFNumber:TpvFloat;
       fFNumberMin:TpvFloat;
       fFNumberMax:TpvFloat;
       fBlurKernelSize:TpvInt32;
       fNgon:TpvFloat;
       fMaxCoC:TpvFloat;
       fHighlightThreshold:TpvFloat;
       fHighlightGain:TpvFloat;
       fBokehChromaticAberration:TpvFloat;
       fDepthOfField:boolean;
       fAutoFocus:boolean;
       fExposureMode:TExposureMode;
       fExposure:TpvScene3DRendererExposure;
       fMinLogLuminance:TpvFloat;
       fMaxLogLuminance:TpvFloat;
       fReset:boolean;
       function GetFieldOfViewAngleRadians:TpvFloat;
       function GetAspectRatio:TpvFloat;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Assign(const aFrom:TpvScene3DRendererCameraPreset);
       procedure UpdateExposure;
       procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
       procedure LoadFromJSONStream(const aStream:TStream);
       procedure LoadFromJSONFile(const aFileName:string);
       function SaveToJSON:TPasJSONItemObject;
       procedure SaveToJSONStream(const aStream:TStream);
       procedure SaveToJSONFile(const aFileName:string);
      published

       // Field of view, > 0.0 = horizontal and < 0.0 = vertical
       property FieldOfView:TpvFloat read fFieldOfView write fFieldOfView;

       // Sensor size at digital cameras in mm (or film size at analog cameras)
       property SensorSize:TpvVector2Property read fSensorSizeProperty;

       // Focal length in mm
       property FocalLength:TpvFloat read fFocalLength write fFocalLength;

       // Flange focal distance in mm (distance from lens to sensor)
       property FlangeFocalDistance:TpvFloat read fFlangeFocalDistance write fFlangeFocalDistance;

       // Focal plane distance in mm (distance from lens to focused plane world point)
       property FocalPlaneDistance:TpvFloat read fFocalPlaneDistance write fFocalPlaneDistance;

       // f-number (f/n)
       property FNumber:TpvFloat read fFNumber write fFNumber;

       // minimum f-number
       property FNumberMin:TpvFloat read fFNumberMin write fFNumberMin;

       // maximum f-number
       property FNumberMax:TpvFloat read fFNumberMax write fFNumberMax;

       // ngon
       property Ngon:TpvFloat read fNgon write fNgon;

       // Blur kernel size
       property BlurKernelSize:TpvInt32 read fBlurKernelSize write fBlurKernelSize;

       // maximum CoC radius
       property MaxCoC:TpvFloat read fMaxCoC write fMaxCoC;

       // Highlight threshold
       property HighlightThreshold:TpvFloat read fHighlightThreshold write fHighlightThreshold;

       // Highlight gain
       property HighlightGain:TpvFloat read fHighlightGain write fHighlightGain;

       // Bokeh chromatic aberration/fringing
       property BokehChromaticAberration:TpvFloat read fBokehChromaticAberration write fBokehChromaticAberration;

       // Angle of field of view in radians
       property FieldOfViewAngleRadians:TpvFloat read GetFieldOfViewAngleRadians;

       // Aspect ratio
       property AspectRatio:TpvFloat read GetAspectRatio;

       // Depth of field
       property DepthOfField:boolean read fDepthOfField write fDepthOfField;

       // Auto-Focus
       property AutoFocus:boolean read fAutoFocus write fAutoFocus;

       // Exposure mode
       property ExposureMode:TExposureMode read fExposureMode write fExposureMode;

       // Exposure
       property Exposure:TpvScene3DRendererExposure read fExposure;

       // Minimum log luminance
       property MinLogLuminance:TpvFloat read fMinLogLuminance write fMinLogLuminance;

       // Maximum log luminance
       property MaxLogLuminance:TpvFloat read fMaxLogLuminance write fMaxLogLuminance;

       // Reset, when completely new view
       property Reset:boolean read fReset write fReset;

    end;

implementation

uses PasVulkan.JSON;

{ TpvScene3DRendererCameraPreset }

constructor TpvScene3DRendererCameraPreset.Create;
begin
 inherited Create;
 fFieldOfView:=53.13010235415598;
 fSensorSize:=TpvVector2.Create(36.0,24.0); // 36 x 24 mm
 fSensorSizeProperty:=TpvVector2Property.Create(@fSensorSize);
 fFocalLength:=50.0;
 fFlangeFocalDistance:=100.0;
 fFocalPlaneDistance:=4000.0;
 fFNumber:=16.0;
 fFNumberMin:=1.0;
 fFNumberMax:=16.0;
 fNgon:=6;
 fBlurKernelSize:=8;
 fMaxCoC:=0.05;
 fHighlightThreshold:=0.25;
 fHighlightGain:=1.0;
 fBokehChromaticAberration:=0.7;
 fDepthOfField:=true;
 fAutoFocus:=true;
 fExposureMode:=TExposureMode.Auto;
 fExposure:=TpvScene3DRendererExposure.Create;
 fMinLogLuminance:=-8.0;
 fMaxLogLuminance:=6.0;
 fReset:=false;
end;

destructor TpvScene3DRendererCameraPreset.Destroy;
begin
 FreeAndNil(fSensorSizeProperty);
 FreeAndNil(fExposure);
 inherited Destroy;
end;

procedure TpvScene3DRendererCameraPreset.Assign(const aFrom:TpvScene3DRendererCameraPreset);
begin
 fFieldOfView:=aFrom.fFieldOfView;
 fSensorSize:=aFrom.fSensorSize;
 fFocalLength:=aFrom.fFocalLength;
 fFlangeFocalDistance:=aFrom.fFlangeFocalDistance;
 fFocalPlaneDistance:=aFrom.fFocalPlaneDistance;
 fFNumber:=aFrom.fFNumber;
 fFNumberMin:=aFrom.fFNumberMin;
 fFNumberMax:=aFrom.fFNumberMax;
 fBlurKernelSize:=aFrom.fBlurKernelSize;
 fNgon:=aFrom.fNgon;
 fMaxCoC:=aFrom.fMaxCoC;
 fHighlightThreshold:=aFrom.fHighlightThreshold;
 fHighlightGain:=aFrom.fHighlightGain;
 fBokehChromaticAberration:=aFrom.fBokehChromaticAberration;
 fDepthOfField:=aFrom.fDepthOfField;
 fAutoFocus:=aFrom.fAutoFocus;
 fExposureMode:=aFrom.fExposureMode;
 fExposure.Assign(aFrom.fExposure);
 fMinLogLuminance:=aFrom.fMinLogLuminance;
 fMaxLogLuminance:=aFrom.fMaxLogLuminance;
 fReset:=aFrom.fReset;
end;

function TpvScene3DRendererCameraPreset.GetFieldOfViewAngleRadians:TpvFloat;
begin
 // Original formula source: http://research.tri-ace.com/Data/S2015/05_ImplementationBokeh-S2015.pptx on slide 25
 result:=2.0*ArcTan((fSensorSize.x*(fFocalPlaneDistance-fFocalLength))/(2.0*fFocalPlaneDistance*fFocalLength));
end;

function TpvScene3DRendererCameraPreset.GetAspectRatio:TpvFloat;
begin
 result:=fSensorSize.x/fSensorSize.y;
end;

procedure TpvScene3DRendererCameraPreset.UpdateExposure;
begin
 fExposure.SetFromCamera(fFlangeFocalDistance,fFocalLength,fFNumber); 
end;

procedure TpvScene3DRendererCameraPreset.LoadFromJSON(const aJSONItem:TPasJSONItem);
var s:TpvUTF8String;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fFieldOfView:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['fieldofview'],fFieldOfView);
  fSensorSize:=JSONToVector2(TPasJSONItemObject(aJSONItem).Properties['sensorsize'],fSensorSize);
  fFocalLength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['focallength'],fFocalLength);
  fFlangeFocalDistance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flangefocaldistance'],fFlangeFocalDistance);
  fFocalPlaneDistance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['focalplanedistance'],fFocalPlaneDistance);
  fFNumber:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['fnumber'],fFNumber);
  fFNumberMin:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['fnumbermin'],fFNumberMin);
  fFNumberMax:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['fnumbermax'],fFNumberMax);
  fBlurKernelSize:=TPasJSON.GetInt64(TPasJSONItemObject(aJSONItem).Properties['blurkernelsize'],fBlurKernelSize);
  fNgon:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['ngon'],fNgon);
  fMaxCoC:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maxcoc'],fMaxCoC);
  fHighlightThreshold:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['highlightthreshold'],fHighlightThreshold);
  fHighlightGain:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['highlightgain'],fHighlightGain);
  fBokehChromaticAberration:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['bokehchromaticaberration'],fBokehChromaticAberration);
  fDepthOfField:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['depthoffield'],fDepthOfField);
  fAutoFocus:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['autofocus'],fAutoFocus);
  s:=LowerCase(TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['exposuremode'],'auto'));
  if s='auto' then begin
   fExposureMode:=TExposureMode.Auto;
  end else if s='camera' then begin
   fExposureMode:=TExposureMode.Camera;
  end else if s='manual' then begin
   fExposureMode:=TExposureMode.Manual;
  end else begin
   fExposureMode:=TExposureMode.Auto;
  end; 
  fExposure.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['exposure']);
  fMinLogLuminance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['minlogluminance'],fMinLogLuminance);
  fMaxLogLuminance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maxlogluminance'],fMaxLogLuminance);
  fReset:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['reset'],fReset);
 end;
end;

procedure TpvScene3DRendererCameraPreset.LoadFromJSONStream(const aStream:TStream);
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

procedure TpvScene3DRendererCameraPreset.LoadFromJSONFile(const aFileName:string);
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

function TpvScene3DRendererCameraPreset.SaveToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 result.Add('fieldofview',TPasJSONItemNumber.Create(fFieldOfView));
 result.Add('sensorsize',Vector2ToJSON(fSensorSize));
 result.Add('focallength',TPasJSONItemNumber.Create(fFocalLength));
 result.Add('flangefocaldistance',TPasJSONItemNumber.Create(fFlangeFocalDistance));
 result.Add('focalplanedistance',TPasJSONItemNumber.Create(fFocalPlaneDistance));
 result.Add('fnumber',TPasJSONItemNumber.Create(fFNumber));
 result.Add('fnumbermin',TPasJSONItemNumber.Create(fFNumberMin));
 result.Add('fnumbermax',TPasJSONItemNumber.Create(fFNumberMax));
 result.Add('blurkernelsize',TPasJSONItemNumber.Create(fBlurKernelSize));
 result.Add('ngon',TPasJSONItemNumber.Create(fNgon));
 result.Add('maxcoc',TPasJSONItemNumber.Create(fMaxCoC));
 result.Add('highlightthreshold',TPasJSONItemNumber.Create(fHighlightThreshold));
 result.Add('highlightgain',TPasJSONItemNumber.Create(fHighlightGain));
 result.Add('bokehchromaticaberration',TPasJSONItemNumber.Create(fBokehChromaticAberration));
 result.Add('depthoffield',TPasJSONItemBoolean.Create(fDepthOfField));
 result.Add('autofocus',TPasJSONItemBoolean.Create(fAutoFocus));
 case fExposureMode of
  TExposureMode.Auto:begin
   result.Add('exposuremode',TPasJSONItemString.Create('auto'));
  end;
  TExposureMode.Camera:begin
   result.Add('exposuremode',TPasJSONItemString.Create('camera'));
  end;
  TExposureMode.Manual:begin
   result.Add('exposuremode',TPasJSONItemString.Create('manual'));
  end;
  else begin
   result.Add('exposuremode',TPasJSONItemString.Create('auto'));
  end;
 end;
 result.Add('exposure',fExposure.SaveToJSON);
 result.Add('minlogluminance',TPasJSONItemNumber.Create(fMinLogLuminance));
 result.Add('maxlogluminance',TPasJSONItemNumber.Create(fMaxLogLuminance));
 result.Add('reset',TPasJSONItemBoolean.Create(fReset));
end;

procedure TpvScene3DRendererCameraPreset.SaveToJSONStream(const aStream:TStream);
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

procedure TpvScene3DRendererCameraPreset.SaveToJSONFile(const aFileName:string);
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


initialization
finalization
end.
