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
unit PasVulkan.POCA;
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
     PasMP,
     PasDblStrUtils,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.Framework,
     PasVulkan.Audio,
     PasVulkan.Application,
     PasVulkan.Collections,
     PasVulkan.VectorPath,
     PasVulkan.SignedDistanceField2D,
     PasVulkan.Canvas,
     PasVulkan.Sprites,
     PasVulkan.TrueTypeFont,
     PasVulkan.Font,
     POCA;

type TpvPOCAAudio=class;

     TPOCAHostData=record

      Instance:PPOCAInstance;

      GraphicsQueue:TpvVulkanQueue;
      GraphicsCommandBuffer:TpvVulkanCommandBuffer;
      GraphicsCommandBufferFence:TpvVulkanFence;

      TransferQueue:TpvVulkanQueue;
      TransferCommandBuffer:TpvVulkanCommandBuffer;
      TransferCommandBufferFence:TpvVulkanFence;

      Vector2Hash:TPOCAValue;
      Vector2HashEvents:TPOCAValue;

      Vector3Hash:TPOCAValue;
      Vector3HashEvents:TPOCAValue;

      Vector4Hash:TPOCAValue;
      Vector4HashEvents:TPOCAValue;

      QuaternionHash:TPOCAValue;
      QuaternionHashEvents:TPOCAValue;

      Matrix3x3Hash:TPOCAValue;
      Matrix3x3HashEvents:TPOCAValue;

      Matrix4x4Hash:TPOCAValue;
      Matrix4x4HashEvents:TPOCAValue;

      SpriteHash:TPOCAValue;
      SpriteHashEvents:TPOCAValue;

      SpriteAtlasHash:TPOCAValue;
      SpriteAtlasHashEvents:TPOCAValue;

      TextureHash:TPOCAValue;
      TextureHashEvents:TPOCAValue;
      TextureNameSpace:TPOCAValue;

      FontHash:TPOCAValue;
      FontHashEvents:TPOCAValue;

      CanvasFontHash:TPOCAValue;
      CanvasFontHashEvents:TPOCAValue;

      CanvasShapeHash:TPOCAValue;
      CanvasShapeHashEvents:TPOCAValue;

      CanvasHash:TPOCAValue;
      CanvasHashEvents:TPOCAValue;

     end;
     PPOCAHostData=^TPOCAHostData;

     TpvPOCAAudio=class
      public
       type TSound=class;
            TSounds=TpvObjectGenericList<TSound>;
            TSoundExistHashList=TpvHashMap<TSound,Boolean>;
            TSoundHashList=TpvStringHashMap<TSound>;
            TMusic=class;
            TMusics=TpvObjectGenericList<TMusic>;
            TMusicExistHashList=TpvHashMap<TMusic,Boolean>;
            TMusicHashList=TpvStringHashMap<TMusic>;
            { TSound }
            TSound=class
             private
              fPOCAAudio:TpvPOCAAudio;
              fIndex:TpvSizeInt;
              fUID:TPasMPUInt64;
              fUIDString:TpvUTF8String;
              fName:TpvUTF8String;
              fFileName:TpvUTF8String;
              fSoundSample:TpvAudioSoundSample;
              fReady:TPasMPBool32;
              fPolyphony:TpvInt32;
              fLoop:TpvInt32;
              fRealVoices:TpvInt32;
              fFadeOutDuration:TpvDouble;
              fPOCAInstanceValue:TPOCAValue;
              fUIDPOCAKeyValue:TPOCAValue;
              fReferenceCounter:TpvInt32;
             public
              constructor Create(const aSounds:TpvPOCAAudio;const aName,aFileName:TpvUTF8String;const aPolyphony:TpvInt32;const aLoop,aRealVoices:TpvInt32;const aFadeOutDuration:TpvDouble); reintroduce;
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure IncRef;
              procedure DecRef;
              procedure Load;
              procedure Reload;
              procedure UpdateAudio;
             public
              function Play(Volume,Panning,Rate:TpvFloat;VoiceIndexPointer:TpvPointer=nil):TpvID;
              function PlaySpatialization(Volume,Panning,Rate:TpvFloat;Spatialization:LongBool;const Position,Velocity:TpvVector3;const Local:LongBool=false;const VoiceIndexPointer:TpvPointer=nil):TpvID;
              procedure Stop(GlobalVoiceID:TpvID);
              procedure KeyOff(GlobalVoiceID:TpvID);
              function SetVolume(GlobalVoiceID:TpvID;Volume:TpvFloat):TpvID;
              function SetPanning(GlobalVoiceID:TpvID;Panning:TpvFloat):TpvID;
              function SetRate(GlobalVoiceID:TpvID;Rate:TpvFloat):TpvID;
              function SetPosition(GlobalVoiceID:TpvID;Spatialization:LongBool;const Origin,Velocity:TpvVector3;const Local:LongBool=false):TpvID;
              function SetEffectMix(GlobalVoiceID:TpvID;Active:LongBool):TpvID;
              function IsPlaying:boolean;
              function IsVoicePlaying(GlobalVoiceID:TpvID):boolean;
              function SampleOnIntervalHook(const aSampleVoice:TpvAudioSoundSampleVoice;const aDeltaSamples:TpvInt32):boolean;
             public
              property UID:TPasMPUInt64 read fUID;
              property Ready:TPasMPBool32 read fReady write fReady;
              property Polyphony:TpvInt32 read fPolyphony write fPolyphony;
              property Loop:TpvInt32 read fLoop write fLoop;
              property RealVoices:TpvInt32 read fRealVoices write fRealVoices;
              property SoundSample:TpvAudioSoundSample read fSoundSample;
              property POCAInstanceValue:TPOCAValue read fPOCAInstanceValue;
             published
            end;
            { TMusic }
            TMusic=class
             private
              fPOCAAudio:TpvPOCAAudio;
              fIndex:TpvSizeInt;
              fUID:TPasMPUInt64;
              fUIDString:TpvUTF8String;
              fName:TpvUTF8String;
              fFileName:TpvUTF8String;
              fMusic:TpvAudioSoundMusic;
              fReady:TPasMPBool32;
              fPOCAInstanceValue:TPOCAValue;
              fUIDPOCAKeyValue:TPOCAValue;
              fReferenceCounter:TpvInt32;
             public
              constructor Create(const aSounds:TpvPOCAAudio;const aName,aFileName:TpvUTF8String); reintroduce;
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure IncRef;
              procedure DecRef;
              procedure Load;
              procedure Reload;
              procedure UpdateAudio;
             public
              procedure Play(Volume,Panning,Rate:TpvFloat;Loop:boolean);
              procedure Stop;
              procedure SetVolume(Volume:TpvFloat);
              procedure SetPanning(Panning:TpvFloat);
              procedure SetRate(Rate:TpvFloat);
              function IsPlaying:boolean;
             public
              property UID:TPasMPUInt64 read fUID;
              property Ready:TPasMPBool32 read fReady write fReady;
              property Music:TpvAudioSoundMusic read fMusic;
              property POCAInstanceValue:TPOCAValue read fPOCAInstanceValue;
             published
            end;
            TUIDFreeList=TpvDynamicFastStack<TPasMPUInt64>;
      private
       fPOCAInstance:PPOCAInstance;
       fSounds:TSounds;
       fSoundExistHashList:TSoundExistHashList;
       fSoundHashList:TSoundHashList;
       fMusics:TMusics;
       fMusicExistHashList:TMusicExistHashList;
       fMusicHashList:TMusicHashList;
       fLock:TPasMPCriticalSection;
       fUIDCounter:TPasMPUInt64;
       fUIDFreeListLock:TPasMPCriticalSection;
       fUIDFreeList:TUIDFreeList;
       fPOCASubContext:PPOCAContext;
       fPOCASoundHash:TPOCAValue;
       fPOCASoundGhostHash:TPOCAValue;
       fPOCAMusicHash:TPOCAValue;
       fPOCAMusicGhostHash:TPOCAValue;
      public
       constructor Create(const aPOCAInstance:PPOCAInstance); reintroduce;
       destructor Destroy; override;
       procedure Load;
       procedure UpdateAudio;
       function Add(const aName,aFileName:TpvUTF8String;const aPolyphony:TpvInt32=1;const aLoop:TpvInt32=1;const aRealVoices:TpvInt32=-1;const aFadeOutDuration:TpvDouble=0.0):TSound;
       function Find(const aName:TpvUTF8String):TSound;
       procedure Remove(const aSound:TSound); overload;
       procedure Remove(const aName:TpvUTF8String); overload;
       function AddMusic(const aName,aFileName:TpvUTF8String):TMusic;
       function FindMusic(const aName:TpvUTF8String):TMusic;
       procedure RemoveMusic(const aMusic:TMusic); overload;
       procedure RemoveMusic(const aName:TpvUTF8String); overload;
       procedure Clear;
      public
     end;

// Pointers to the ghost types as forward declarations, for to avoid circular references and more complicated code
var POCAVector2GhostPointer:PPOCAGhostType=nil;
    POCAVector3GhostPointer:PPOCAGhostType=nil;
    POCAVector4GhostPointer:PPOCAGhostType=nil;
    POCAQuaternionGhostPointer:PPOCAGhostType=nil;
    POCAMatrix3x3GhostPointer:PPOCAGhostType=nil;
    POCAMatrix4x4GhostPointer:PPOCAGhostType=nil;
    POCASpriteGhostPointer:PPOCAGhostType=nil;
    POCASpriteAtlasGhostPointer:PPOCAGhostType=nil;
    POCATextureGhostPointer:PPOCAGhostType=nil;
    POCAFontGhostPointer:PPOCAGhostType=nil;
    POCACanvasFontGhostPointer:PPOCAGhostType=nil;
    POCACanvasShapeGhostPointer:PPOCAGhostType=nil;
    POCACanvasGhostPointer:PPOCAGhostType=nil;

function POCAGetHostData(const aContext:PPOCAContext):PPOCAHostData; //inline;
procedure POCASetHostData(const aContext:PPOCAContext;const aHostData:PPOCAHostData); //inline;

function POCANewVector2(const aContext:PPOCAContext;const aVector2:TpvVector2D):TPOCAValue; overload;
function POCANewVector2(const aContext:PPOCAContext;const aX:TpvDouble=0.0;const aY:TpvDouble=0.0):TPOCAValue; overload;
function POCAGetVector2Value(const aValue:TPOCAValue):TpvVector2D;

function POCANewVector3(const aContext:PPOCAContext;const aVector3:TpvVector3D):TPOCAValue; overload;
function POCANewVector3(const aContext:PPOCAContext;const aX:TpvDouble=0.0;const aY:TpvDouble=0.0;const aZ:TpvDouble=0.0):TPOCAValue; overload;
function POCAGetVector3Value(const aValue:TPOCAValue):TpvVector3D;

function POCANewVector4(const aContext:PPOCAContext;const aVector4:TpvVector4D):TPOCAValue; overload;
function POCANewVector4(const aContext:PPOCAContext;const aX:TpvDouble=0.0;const aY:TpvDouble=0.0;const aZ:TpvDouble=0.0;const aW:TpvDouble=0.0):TPOCAValue; overload;
function POCAGetVector4Value(const aValue:TPOCAValue):TpvVector4D;

function POCANewQuaternion(const aContext:PPOCAContext;const aQuaternion:TpvQuaternionD):TPOCAValue; overload;
function POCANewQuaternion(const aContext:PPOCAContext;const aX:TpvDouble=0.0;const aY:TpvDouble=0.0;const aZ:TpvDouble=0.0;const aW:TpvDouble=1.0):TPOCAValue; overload;
function POCAGetQuaternionValue(const aValue:TPOCAValue):TpvQuaternionD;

function POCANewMatrix3x3(const aContext:PPOCAContext;const aMatrix3x3:TpvMatrix3x3D):TPOCAValue; overload;
function POCANewMatrix3x3(const aContext:PPOCAContext;const aM00:TpvDouble=1.0;const aM01:TpvDouble=0.0;const aM02:TpvDouble=0.0;const aM10:TpvDouble=0.0;const aM11:TpvDouble=1.0;const aM12:TpvDouble=0.0;const aM20:TpvDouble=0.0;const aM21:TpvDouble=0.0;const aM22:TpvDouble=1.0):TPOCAValue; overload;
function POCAGetMatrix3x3Value(const aValue:TPOCAValue):TpvMatrix3x3D;

function POCANewMatrix4x4(const aContext:PPOCAContext;const aMatrix4x4:TpvMatrix4x4D):TPOCAValue; overload;
function POCANewMatrix4x4(const aContext:PPOCAContext;const aM00:TpvDouble=1.0;const aM01:TpvDouble=0.0;const aM02:TpvDouble=0.0;const aM03:TpvDouble=0.0;const aM10:TpvDouble=0.0;const aM11:TpvDouble=1.0;const aM12:TpvDouble=0.0;const aM13:TpvDouble=0.0;const aM20:TpvDouble=0.0;const aM21:TpvDouble=0.0;const aM22:TpvDouble=1.0;const aM23:TpvDouble=0.0;const aM30:TpvDouble=0.0;const aM31:TpvDouble=0.0;const aM32:TpvDouble=0.0;const aM33:TpvDouble=1.0):TPOCAValue; overload;
function POCAGetMatrix4x4Value(const aValue:TPOCAValue):TpvMatrix4x4D;

function POCANewSprite(const aContext:PPOCAContext;const aSprite:TpvSprite):TPOCAValue;
function POCAGetSpriteValue(const aValue:TPOCAValue):TpvSprite;

function POCANewSpriteAtlas(const aContext:PPOCAContext;const aSpriteAtlas:TpvSpriteAtlas):TPOCAValue;
function POCAGetSpriteAtlasValue(const aValue:TPOCAValue):TpvSpriteAtlas;

function POCANewTexture(const aContext:PPOCAContext;const aTexture:TpvVulkanTexture):TPOCAValue;
function POCAGetTextureValue(const aValue:TPOCAValue):TpvVulkanTexture;

function POCANewFont(const aContext:PPOCAContext;const aFont:TpvFont):TPOCAValue;
function POCAGetFontValue(const aValue:TPOCAValue):TpvFont;

function POCANewCanvasFont(const aContext:PPOCAContext;const aCanvasFont:TpvCanvasFont):TPOCAValue;
function POCAGetCanvasFontValue(const aValue:TPOCAValue):TpvCanvasFont;

function POCANewCanvasShape(const aContext:PPOCAContext;const aCanvasShape:TpvCanvasShape):TPOCAValue;
function POCAGetCanvasShapeValue(const aValue:TPOCAValue):TpvCanvasShape;

function POCANewCanvas(const aContext:PPOCAContext;const aCanvas:TpvCanvas):TPOCAValue;
function POCAGetCanvasValue(const aValue:TPOCAValue):TpvCanvas;

function POCANewInputEventHash(const aContext:PPOCAContext):TPOCAValue;
function POCASetInputEventHashNone(const aContext:PPOCAContext;const aHash:TPOCAValue):TPOCAValue;
function POCASetInputEventHashKey(const aContext:PPOCAContext;const aHash:TPOCAValue;const aKeyEvent:TpvApplicationInputKeyEvent):TPOCAValue;
function POCASetInputEventHashPointer(const aContext:PPOCAContext;const aHash:TPOCAValue;const aPointerEvent:TpvApplicationInputPointerEvent):TPOCAValue;
function POCASetInputEventHashScroll(const aContext:PPOCAContext;const aHash:TPOCAValue;const aRelativeAmount:TpvVector2):TPOCAValue;

function JSONToPOCAValue(const aContext:PPOCAContext;const aJSON:TPasJSONItem):TPOCAValue;
function POCAValueToJSON(const aContext:PPOCAContext;const aValue:TPOCAValue):TPasJSONItem;

procedure InitializeForPOCAContext(const aContext:PPOCAContext);
procedure FinalizeForPOCAContext(const aContext:PPOCAContext);

implementation

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Host data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function POCAGetHostData(const aContext:PPOCAContext):PPOCAHostData;
begin
 result:=aContext^.Instance^.Globals.HostData;
end;

procedure POCASetHostData(const aContext:PPOCAContext;const aHostData:PPOCAHostData);
begin
 aContext^.Instance^.Globals.HostData:=aHostData;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Vector2
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAVector2GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAVector2GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    result:=true;
   end;
   'y','g':begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

function POCAVector2GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector2:PpvVector2D;
    s:TpvUTF8String;
begin
 Vector2:=PpvVector2D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    aValue.Num:=Vector2^.x;
    result:=true;
   end;
   'y','g':begin
    aValue.Num:=Vector2^.y;
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAVector2GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector2:PpvVector2D;
    s:TpvUTF8String;
begin
 Vector2:=PpvVector2D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    Vector2^.x:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'y','g':begin
    Vector2^.y:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

const POCAVector2Ghost:TPOCAGhostType=
       (
        Destroy:POCAVector2GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAVector2GhostExistKey;
        GetKey:POCAVector2GhostGetKey;
        SetKey:POCAVector2GhostSetKey;
        Name:'Vector2'
       );

function POCANewVector2(const aContext:PPOCAContext;const aVector2:TpvVector2D):TPOCAValue; overload;
var Vector2:PpvVector2D;
begin
 Vector2:=nil;
 GetMem(Vector2,SizeOf(TpvVector2D));
 Vector2^:=aVector2;
 result:=POCANewGhost(aContext,@POCAVector2Ghost,Vector2,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Vector2Hash);
end;

function POCANewVector2(const aContext:PPOCAContext;const aX:TpvDouble;const aY:TpvDouble):TPOCAValue; overload;
begin
 result:=POCANewVector2(aContext,TpvVector2D.Create(aX,aY));
end;

function POCAGetVector2Value(const aValue:TPOCAValue):TpvVector2D;
begin
 if POCAGhostGetType(aValue)=@POCAVector2Ghost then begin
  result:=PpvVector2D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvVector2D.Create(0.0,0.0);
 end;
end;

function POCAVector2FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:TpvVector2D;
    Vector3:PpvVector3D;
    Vector4:PpvVector4D;
begin
 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=PpvVector2D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2.x:=Vector3^.x;
  Vector2.y:=Vector3^.y;
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2.x:=Vector4^.x;
  Vector2.y:=Vector4^.y;
 end else begin
  if aCountArguments>0 then begin
   Vector2.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Vector2.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Vector2.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector2.y:=0.0;
  end;
 end;
 result:=POCANewVector2(aContext,Vector2);
end;

function POCAVector2FunctionLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector2^.Length);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSquaredLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector2^.SquaredLength);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNormalize(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Vector2^:=Vector2^.Normalize;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionDot(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=Vector2^.Dot(OtherVector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionCross(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=Vector2^.Cross(OtherVector2^);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionDistanceTo(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=(Vector2^-OtherVector2^).Length;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector2^:=Vector2^.Lerp(OtherVector2^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector2^:=Vector2^.Nlerp(OtherVector2^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector2^:=Vector2^.Slerp(OtherVector2^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvVector2D;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[2])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=POCAGhostFastGetPointer(aThis);
  B:=POCAGhostFastGetPointer(aArguments^[0]);
  C:=POCAGhostFastGetPointer(aArguments^[1]);
  D:=POCAGhostFastGetPointer(aArguments^[2]);
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewVector2(aContext,Vector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=OtherVector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=Vector2^+OtherVector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=Vector2^-OtherVector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
    OtherMatrix3x3:PpvMatrix3x3D;
    OtherMatrix4x4:PpvMatrix4x4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector2^:=Vector2^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=Vector2^*OtherVector2^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=(TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)*OtherMatrix3x3^).xy;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=(TpvVector4D.Create(Vector2^.x,Vector2^.y,0.0,1.0)*OtherMatrix4x4^).xy;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector2^:=Vector2^/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=Vector2^/OtherVector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Vector2^:=-Vector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector2^=OtherVector2^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector2^<>OtherVector2^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  s:='['+ConvertDoubleToString(Vector2^.x,omStandard,-1)+','+ConvertDoubleToString(Vector2^.y,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

// "THIS" is null, because it is a binary operator, so the first argument is the first operand and the second argument is the second operand
function POCAVector2FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^+OtherVector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^-OtherVector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
    Matrix3x3:PpvMatrix3x3D;
    Matrix4x4:PpvMatrix4x4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^*OtherVector2^);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix3x3GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,(TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)*Matrix3x3^).xy);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix3x3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(Matrix3x3^*TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)).xy);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix4x4GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,(TpvVector4D.Create(Vector2^.x,Vector2^.y,0.0,1.0)*Matrix4x4^).xy);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix4x4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(Matrix4x4^*TpvVector4D.Create(Vector2^.x,Vector2^.y,0.0,1.0)).xy);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,Vector2^/OtherVector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector2^=OtherVector2^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PpvVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector2^<>OtherVector2^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,-Vector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,Sqrt(Vector2^.x),Sqrt(Vector2^.y));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PpvVector2D;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='['+ConvertDoubleToString(Vector2^.x,omStandard,-1)+','+ConvertDoubleToString(Vector2^.y,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitVector2Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.Vector2Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector2Hash);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'length',POCAVector2FunctionLength);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'squaredLength',POCAVector2FunctionSquaredLength);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'normalize',POCAVector2FunctionNormalize);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'dot',POCAVector2FunctionDot);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'cross',POCAVector2FunctionCross);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'distanceTo',POCAVector2FunctionDistanceTo);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'lerp',POCAVector2FunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'nlerp',POCAVector2FunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'slerp',POCAVector2FunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'sqlerp',POCAVector2FunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'clone',POCAVector2FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'copy',POCAVector2FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'add',POCAVector2FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'sub',POCAVector2FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'mul',POCAVector2FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'div',POCAVector2FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'neg',POCAVector2FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'equal',POCAVector2FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'notEqual',POCAVector2FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'toString',POCAVector2FunctionToString);

 HostData^.Vector2HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector2HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__add',POCAVector2FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__sub',POCAVector2FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__mul',POCAVector2FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__div',POCAVector2FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__eq',POCAVector2FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__neq',POCAVector2FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__neg',POCAVector2FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__sqrt',POCAVector2FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__tostring',POCAVector2FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Vector2Hash,HostData^.Vector2HashEvents);

end;

procedure POCAInitVector2Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAVector2FunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Vector2',Hash);
end;

procedure POCAInitVector2(aContext:PPOCAContext);
begin
 POCAInitVector2Hash(aContext);
 POCAInitVector2Namespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Vector3
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAVector3GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAVector3GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    result:=true;
   end;
   'y','g':begin
    result:=true;
   end;
   'z','b':begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAVector3GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector3:PpvVector3D;
    s:TpvUTF8String;
begin
 Vector3:=PpvVector3D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    aValue.Num:=Vector3^.x;
    result:=true;
   end;
   'y','g':begin
    aValue.Num:=Vector3^.y;
    result:=true;
   end;
   'z','b':begin
    aValue.Num:=Vector3^.z;
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;
 
function POCAVector3GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector3:PpvVector3D;
    s:TpvUTF8String;
begin
 Vector3:=PpvVector3D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    Vector3^.x:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'y','g':begin
    Vector3^.y:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'z','b':begin
    Vector3^.z:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;
 
const POCAVector3Ghost:TPOCAGhostType=
       (
        Destroy:POCAVector3GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAVector3GhostExistKey;
        GetKey:POCAVector3GhostGetKey;
        SetKey:POCAVector3GhostSetKey;
        Name:'Vector3'
       );

function POCANewVector3(const aContext:PPOCAContext;const aVector3:TpvVector3D):TPOCAValue; overload;
var Vector3:PpvVector3D;
begin
 Vector3:=nil;
 GetMem(Vector3,SizeOf(TpvVector3D));
 Vector3^:=aVector3;
 result:=POCANewGhost(aContext,@POCAVector3Ghost,Vector3,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Vector3Hash);
end;

function POCANewVector3(const aContext:PPOCAContext;const aX:TpvDouble;const aY:TpvDouble;const aZ:TpvDouble):TPOCAValue; overload;
begin
 result:=POCANewVector3(aContext,TpvVector3D.Create(aX,aY,aZ));
end;

function POCAGetVector3Value(const aValue:TPOCAValue):TpvVector3D;
begin
 if POCAGhostGetType(aValue)=@POCAVector3Ghost then begin
  result:=PpvVector3D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvVector3D.Create(0.0,0.0,0.0);
 end;
end;

function POCAVector3FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:TpvVector3D;
    Vector2:PpvVector2D;
    Vector4:PpvVector4D;
begin
 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3.x:=Vector2^.x;
  Vector3.y:=Vector2^.y;
  if aCountArguments>1 then begin
   Vector3.z:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector3.z:=0.0;
  end;
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3:=Vector4^.xyz;
 end else begin
  if aCountArguments>0 then begin
   Vector3.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Vector3.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Vector3.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector3.y:=0.0;
  end;
  if aCountArguments>2 then begin
   Vector3.z:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Vector3.z:=0.0;
  end;
 end;
 result:=POCANewVector3(aContext,Vector3);
end;

function POCAVector3FunctionLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if POCAGhostGetType(aThis)=@POCAVector3Ghost then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector3^.Length);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionSquaredLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if POCAGhostGetType(aThis)=@POCAVector3Ghost then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector3^.SquaredLength);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionNormalize(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if POCAGhostGetType(aThis)=@POCAVector3Ghost then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  Vector3^:=Vector3^.Normalize;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionDot(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=Vector3^.Dot(OtherVector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionCross(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^.Cross(OtherVector3^);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionDistanceTo(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=(Vector3^-OtherVector3^).Length;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector3^:=Vector3^.Lerp(OtherVector3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector3^:=Vector3^.Nlerp(OtherVector3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector3^:=Vector3^.Slerp(OtherVector3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvVector3D;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[2])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=POCAGhostFastGetPointer(aThis);
  B:=POCAGhostFastGetPointer(aArguments^[0]);
  C:=POCAGhostFastGetPointer(aArguments^[1]);
  D:=POCAGhostFastGetPointer(aArguments^[2]);
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  result:=POCANewVector3(aContext,Vector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=OtherVector3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^+OtherVector3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^-OtherVector3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
    OtherMatrix3x3:PpvMatrix3x3D;
    OtherMatrix4x4:PpvMatrix4x4D;
    OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector3^:=Vector3^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^*OtherVector3^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^*OtherMatrix3x3^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=(TpvVector4D.Create(Vector3^.x,Vector3^.y,Vector3^.z,1.0)*OtherMatrix4x4^).xyz;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^*OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector3^:=Vector3^/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3^:=Vector3^/OtherVector3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  Vector3^:=-Vector3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector3^=OtherVector3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector3^<>OtherVector3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aThis);
  s:='['+ConvertDoubleToString(Vector3^.x,omStandard,-1)+','+ConvertDoubleToString(Vector3^.y,omStandard,-1)+','+ConvertDoubleToString(Vector3^.z,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

// "THIS" is null, because it is a binary operator, so the first argument is the first operand and the second argument is the second operand
function POCAVector3FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^+OtherVector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^-OtherVector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
    Factor:TpvDouble;
    Matrix3x3:PpvMatrix3x3D;
    Matrix4x4:PpvMatrix4x4D;
    Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^*OtherVector3^);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix3x3GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^*Matrix3x3^);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix3x3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Matrix3x3^*Vector3^);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix4x4GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,(Vector3^*Matrix4x4^).xyz);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix4x4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,(Matrix4x4^*Vector3^).xyz);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAQuaternionGhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^*Quaternion^);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAQuaternionGhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Quaternion^*Vector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Vector3^/OtherVector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector3^=OtherVector3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3,OtherVector3:PpvVector3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector3^<>OtherVector3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,-Vector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Sqrt(Vector3^.x),Sqrt(Vector3^.y),Sqrt(Vector3^.z));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector3FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector3:PpvVector3D;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='['+ConvertDoubleToString(Vector3^.x,omStandard,-1)+','+ConvertDoubleToString(Vector3^.y,omStandard,-1)+','+ConvertDoubleToString(Vector3^.z,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitVector3Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.Vector3Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector3Hash);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'length',POCAVector3FunctionLength);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'squaredLength',POCAVector3FunctionSquaredLength);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'normalize',POCAVector3FunctionNormalize);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'dot',POCAVector3FunctionDot);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'cross',POCAVector3FunctionCross);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'distanceTo',POCAVector3FunctionDistanceTo);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'lerp',POCAVector3FunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'nlerp',POCAVector3FunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'slerp',POCAVector3FunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'sqlerp',POCAVector3FunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'clone',POCAVector3FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'copy',POCAVector3FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'add',POCAVector3FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'sub',POCAVector3FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'mul',POCAVector3FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'div',POCAVector3FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'neg',POCAVector3FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'equal',POCAVector3FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'notEqual',POCAVector3FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector3Hash,'toString',POCAVector3FunctionToString);

 HostData^.Vector3HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector3HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__add',POCAVector3FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__sub',POCAVector3FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__mul',POCAVector3FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__div',POCAVector3FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__eq',POCAVector3FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__neq',POCAVector3FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__neg',POCAVector3FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__sqrt',POCAVector3FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Vector3HashEvents,'__tostring',POCAVector3FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Vector3Hash,HostData^.Vector3HashEvents);

end;

procedure POCAInitVector3Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAVector3FunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Vector3',Hash);
end;

procedure POCAInitVector3(aContext:PPOCAContext);
begin
 POCAInitVector3Hash(aContext);
 POCAInitVector3Namespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Vector4
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAVector4GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAVector4GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    result:=true;
   end;
   'y','g':begin
    result:=true;
   end;
   'z','b':begin
    result:=true;
   end;
   'w','a':begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAVector4GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector4:PpvVector4D;
    s:TpvUTF8String;
begin
 Vector4:=PpvVector4D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    aValue.Num:=Vector4^.x;
    result:=true;
   end;
   'y','g':begin
    aValue.Num:=Vector4^.y;
    result:=true;
   end;
   'z','b':begin
    aValue.Num:=Vector4^.z;
    result:=true;
   end;
   'w','a':begin
    aValue.Num:=Vector4^.w;
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAVector4GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector4:PpvVector4D;
    s:TpvUTF8String;
begin
 Vector4:=PpvVector4D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    Vector4^.x:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'y','g':begin
    Vector4^.y:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'z','b':begin
    Vector4^.z:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'w','a':begin
    Vector4^.w:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end; 
end;

const POCAVector4Ghost:TPOCAGhostType=
       (
        Destroy:POCAVector4GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAVector4GhostExistKey;
        GetKey:POCAVector4GhostGetKey;
        SetKey:POCAVector4GhostSetKey;
        Name:'Vector4'
       );

function POCANewVector4(const aContext:PPOCAContext;const aVector4:TpvVector4D):TPOCAValue; overload;
var Vector4:PpvVector4D;
begin
 Vector4:=nil;
 GetMem(Vector4,SizeOf(TpvVector4D));
 Vector4^:=aVector4;
 result:=POCANewGhost(aContext,@POCAVector4Ghost,Vector4,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Vector4Hash);
end;

function POCANewVector4(const aContext:PPOCAContext;const aX:TpvDouble;const aY:TpvDouble;const aZ:TpvDouble;const aW:TpvDouble):TPOCAValue; overload;
begin
 result:=POCANewVector4(aContext,TpvVector4D.Create(aX,aY,aZ,aW));
end;

function POCAGetVector4Value(const aValue:TPOCAValue):TpvVector4D;
begin
 if POCAGhostGetType(aValue)=@POCAVector4Ghost then begin
  result:=PpvVector4D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvVector4D.Create(0.0,0.0,0.0,0.0);
 end;
end;

function POCAVector4FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:TpvVector4D;
    Vector2:PpvVector2D;
    Vector3:PpvVector3D;
begin
 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=PpvVector4D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4.x:=Vector2^.x;
  Vector4.y:=Vector2^.y;
  if aCountArguments>1 then begin
   Vector4.z:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector4.z:=0.0;
  end;
  if aCountArguments>2 then begin
   Vector4.w:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Vector4.w:=0.0;
  end;
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4.xyz:=Vector3^;
  if aCountArguments>1 then begin
   Vector4.w:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector4.w:=0.0;
  end;
 end else begin
  if aCountArguments>0 then begin
   Vector4.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Vector4.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Vector4.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector4.y:=0.0;
  end;
  if aCountArguments>2 then begin
   Vector4.z:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Vector4.z:=0.0;
  end;
  if aCountArguments>3 then begin
   Vector4.w:=POCAGetNumberValue(aContext,aArguments^[3]);
  end else begin
   Vector4.w:=0.0;
  end;
 end;
 result:=POCANewVector4(aContext,Vector4);
end;

function POCAVector4FunctionLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if POCAGhostGetType(aThis)=@POCAVector4Ghost then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector4^.Length);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionSquaredLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if POCAGhostGetType(aThis)=@POCAVector4Ghost then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Vector4^.SquaredLength);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionNormalize(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if POCAGhostGetType(aThis)=@POCAVector4Ghost then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  Vector4^:=Vector4^.Normalize;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionDot(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=Vector4^.Dot(OtherVector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionCross(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^.xyz:=Vector4^.xyz.Cross(OtherVector4^.xyz);
  Vector4^.w:=1.0;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionDistanceTo(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=(Vector4^-OtherVector4^).Length;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector4^:=Vector4^.Lerp(OtherVector4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector4^:=Vector4^.Nlerp(OtherVector4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Vector4^:=Vector4^.Slerp(OtherVector4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvVector4D;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[2])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=POCAGhostFastGetPointer(aThis);
  B:=POCAGhostFastGetPointer(aArguments^[0]);
  C:=POCAGhostFastGetPointer(aArguments^[1]);
  D:=POCAGhostFastGetPointer(aArguments^[2]);
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  result:=POCANewVector4(aContext,Vector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=OtherVector4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^+OtherVector4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^-OtherVector4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
    OtherMatrix3x3:PpvMatrix3x3D;
    OtherMatrix4x4:PpvMatrix4x4D;
    OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector4^:=Vector4^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^*OtherVector4^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^*OtherMatrix3x3^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^*OtherMatrix4x4^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^.xyz:=TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)*OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector4^:=Vector4^/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4^:=Vector4^/OtherVector4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  Vector4^:=-Vector4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector4^=OtherVector4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Vector4^<>OtherVector4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aThis);
  s:='['+ConvertDoubleToString(Vector4^.x,omStandard,-1)+','+ConvertDoubleToString(Vector4^.y,omStandard,-1)+','+ConvertDoubleToString(Vector4^.z,omStandard,-1)+','+ConvertDoubleToString(Vector4^.w,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

// "THIS" is null, because it is a binary operator, so the first argument is the first operand and the second argument is the second operand
function POCAVector4FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^+OtherVector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^-OtherVector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
    Matrix3x3:PpvMatrix3x3D;
    Matrix4x4:PpvMatrix4x4D;
    Quaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^*OtherVector4^);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix3x3GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^*Matrix3x3^);
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix3x3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,Matrix3x3^*Vector4^);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix4x4GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^*Matrix4x4^);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix4x4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[1]);
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,Matrix4x4^*Vector4^);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAQuaternionGhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,TpvVector4D.Create((TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)*Quaternion^).x,(TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)*Quaternion^).y,(TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)*Quaternion^).z,Vector4^.w));
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAQuaternionGhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[1]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,TpvVector4D.Create((Quaternion^*TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)).x,(Quaternion^*TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)).y,(Quaternion^*TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)).z,Vector4^.w));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Vector4^/OtherVector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector4^=OtherVector4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4,OtherVector4:PpvVector4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Vector4^<>OtherVector4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,-Vector4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,Sqrt(Vector4^.x),Sqrt(Vector4^.y),Sqrt(Vector4^.z));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector4FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector4:PpvVector4D;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='['+ConvertDoubleToString(Vector4^.x,omStandard,-1)+','+ConvertDoubleToString(Vector4^.y,omStandard,-1)+','+ConvertDoubleToString(Vector4^.z,omStandard,-1)+','+ConvertDoubleToString(Vector4^.w,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitVector4Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);
 
 HostData^.Vector4Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector4Hash);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'length',POCAVector4FunctionLength);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'squaredLength',POCAVector4FunctionSquaredLength);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'normalize',POCAVector4FunctionNormalize);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'dot',POCAVector4FunctionDot);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'cross',POCAVector4FunctionCross);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'distanceTo',POCAVector4FunctionDistanceTo);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'lerp',POCAVector4FunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'nlerp',POCAVector4FunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'slerp',POCAVector4FunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'sqlerp',POCAVector4FunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'clone',POCAVector4FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'copy',POCAVector4FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'add',POCAVector4FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'sub',POCAVector4FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'mul',POCAVector4FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'div',POCAVector4FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'neg',POCAVector4FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'equal',POCAVector4FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'notEqual',POCAVector4FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector4Hash,'toString',POCAVector4FunctionToString);

 HostData^.Vector4HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector4HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__add',POCAVector4FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__sub',POCAVector4FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__mul',POCAVector4FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__div',POCAVector4FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__eq',POCAVector4FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__neq',POCAVector4FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__neg',POCAVector4FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__sqrt',POCAVector4FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Vector4HashEvents,'__tostring',POCAVector4FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Vector4Hash,HostData^.Vector4HashEvents);

end;

procedure POCAInitVector4Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAVector4FunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Vector4',Hash);
end;

procedure POCAInitVector4(aContext:PPOCAContext);
begin
 POCAInitVector4Hash(aContext);
 POCAInitVector4Namespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Quaternion
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAQuaternionGhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAQuaternionGhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x':begin
    result:=true;
   end;
   'y':begin
    result:=true;
   end;
   'z':begin
    result:=true;
   end;
   'w':begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAQuaternionGhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Quaternion:PpvQuaternionD;
    s:TpvUTF8String;
begin
 Quaternion:=PpvQuaternionD(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x':begin
    aValue.Num:=Quaternion^.x;
    result:=true;
   end;
   'y':begin
    aValue.Num:=Quaternion^.y;
    result:=true;
   end;
   'z':begin
    aValue.Num:=Quaternion^.z;
    result:=true;
   end;
   'w':begin
    aValue.Num:=Quaternion^.w;
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

function POCAQuaternionGhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Quaternion:PpvQuaternionD;
    s:TpvUTF8String;
begin
 Quaternion:=PpvQuaternionD(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x':begin
    Quaternion^.x:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'y':begin
    Quaternion^.y:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'z':begin
    Quaternion^.z:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'w':begin
    Quaternion^.w:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end; 
 end else begin
  result:=false;
 end;
end;

const POCAQuaternionGhost:TPOCAGhostType=
       (
        Destroy:POCAQuaternionGhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAQuaternionGhostExistKey;
        GetKey:POCAQuaternionGhostGetKey;
        SetKey:POCAQuaternionGhostSetKey;
        Name:'Quaternion'
       );

function POCANewQuaternion(const aContext:PPOCAContext;const aQuaternion:TpvQuaternionD):TPOCAValue; overload;
var Quaternion:PpvQuaternionD;
begin
 Quaternion:=nil;
 GetMem(Quaternion,SizeOf(TpvQuaternionD));
 Quaternion^:=aQuaternion;
 result:=POCANewGhost(aContext,@POCAQuaternionGhost,Quaternion,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.QuaternionHash);
end;

function POCANewQuaternion(const aContext:PPOCAContext;const aX:TpvDouble;const aY:TpvDouble;const aZ:TpvDouble;const aW:TpvDouble):TPOCAValue; overload;
begin
 result:=POCANewQuaternion(aContext,TpvQuaternionD.Create(aX,aY,aZ,aW));
end;

function POCAGetQuaternionValue(const aValue:TPOCAValue):TpvQuaternionD;
begin
 if POCAGhostGetType(aValue)=@POCAQuaternionGhost then begin
  result:=PpvQuaternionD(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvQuaternionD.Create(0.0,0.0,0.0,0.0);
 end;
end;

function POCAQuaternionFunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:TpvQuaternionD;
    Vector2:PpvVector2D;
    Vector3:PpvVector3D;
    Vector4:PpvVector4D;
begin
 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=PpvQuaternionD(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion.x:=Vector2^.x;
  Quaternion.y:=Vector2^.y;
  if aCountArguments>1 then begin
   Quaternion.z:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Quaternion.z:=0.0;
  end;
  if aCountArguments>2 then begin
   Quaternion.w:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Quaternion.w:=0.0;
  end;
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion.xyz:=Vector3^;
  if aCountArguments>1 then begin
   Quaternion.w:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Quaternion.w:=0.0;
  end;
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) then begin
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion.x:=Vector4^.x;
  Quaternion.y:=Vector4^.y;
  Quaternion.z:=Vector4^.z;
  Quaternion.w:=Vector4^.w;
 end else begin
  if aCountArguments>0 then begin
   Quaternion.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Quaternion.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Quaternion.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Quaternion.y:=0.0;
  end;
  if aCountArguments>2 then begin
   Quaternion.z:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Quaternion.z:=0.0;
  end;
  if aCountArguments>3 then begin
   Quaternion.w:=POCAGetNumberValue(aContext,aArguments^[3]);
  end else begin
   Quaternion.w:=0.0;
  end;
 end;
 result:=POCANewQuaternion(aContext,Quaternion);
end;

function POCAQuaternionFunctionConjugate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=Quaternion^.Conjugate;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionInverse(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=Quaternion^.Inverse;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionLog(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=Quaternion^.Log;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionExp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=Quaternion^.Exp;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Quaternion^.Length);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionSquaredLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,Quaternion^.SquaredLength);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionNormalize(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if POCAGhostGetType(aThis)=@POCAQuaternionGhost then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=Quaternion^.Normalize;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionDot(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=Quaternion^.Dot(OtherQuaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCross(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^.xyz:=Quaternion^.xyz.Cross(OtherQuaternion^.xyz);
  Quaternion^.w:=1.0;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Quaternion^:=Quaternion^.Lerp(OtherQuaternion^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Quaternion^:=Quaternion^.Nlerp(OtherQuaternion^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Quaternion^:=Quaternion^.Slerp(OtherQuaternion^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvQuaternionD;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[2])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=POCAGhostFastGetPointer(aThis);
  B:=POCAGhostFastGetPointer(aArguments^[0]);
  C:=POCAGhostFastGetPointer(aArguments^[1]);
  D:=POCAGhostFastGetPointer(aArguments^[2]);
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  result:=POCANewQuaternion(aContext,Quaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^:=OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^:=Quaternion^+OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^:=Quaternion^-OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
    Vector3:PpvVector3D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Quaternion^:=Quaternion^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^:=Quaternion^*OtherQuaternion^;
  result:=aThis;
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Quaternion^*Vector3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Quaternion^.x:=Quaternion^.x/Factor;
  Quaternion^.y:=Quaternion^.y/Factor;
  Quaternion^.z:=Quaternion^.z/Factor;
  Quaternion^.w:=Quaternion^.w/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion^:=Quaternion^/OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  Quaternion^:=-Quaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Quaternion^=OtherQuaternion^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Quaternion^<>OtherQuaternion^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aThis);
  s:='['+ConvertDoubleToString(Quaternion^.x,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.y,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.z,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.w,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

// "THIS" is null, because it is a binary operator, so the first argument is the first operand and the second argument is the second operand
function POCAQuaternionFunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^+OtherQuaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^-OtherQuaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
    Vector3:PpvVector3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^*OtherQuaternion^);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Quaternion^*Vector3^);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Vector3^*Quaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^.x/Factor,Quaternion^.y/Factor,Quaternion^.z/Factor,Quaternion^.w/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewQuaternion(aContext,Quaternion^/OtherQuaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Quaternion^=OtherQuaternion^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion,OtherQuaternion:PpvQuaternionD;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Quaternion^<>OtherQuaternion^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewQuaternion(aContext,-Quaternion^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewQuaternion(aContext,Sqrt(Quaternion^.x),Sqrt(Quaternion^.y),Sqrt(Quaternion^.z));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='['+ConvertDoubleToString(Quaternion^.x,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.y,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.z,omStandard,-1)+','+ConvertDoubleToString(Quaternion^.w,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromAngleAxis(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Axis:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=2) then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  if assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
   Axis:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
   Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromAngleAxis(Angle,TpvVector3(Axis)));
   result:=POCANewQuaternion(aContext,Quaternion);
  end else begin
   result:=POCAValueNull;
  end;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromEuler(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Pitch,Yaw,Roll:TpvDouble;
    Angles:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  // From Vector3
  Angles:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromEuler(TpvVector3(Angles)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else if aCountArguments>=3 then begin
  // From three scalars (pitch, yaw, roll)
  Pitch:=POCAGetNumberValue(aContext,aArguments^[0]);
  Yaw:=POCAGetNumberValue(aContext,aArguments^[1]);
  Roll:=POCAGetNumberValue(aContext,aArguments^[2]);
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromEuler(Pitch,Yaw,Roll));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromToRotation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var FromDir,ToDir:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  FromDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  ToDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromToRotation(TpvVector3(FromDir),TpvVector3(ToDir)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromLookRotation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Forward,Up:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Forward:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Up:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromLookRotation(TpvVector3(Forward),TpvVector3(Up)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromScaledAngleAxis(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ScaledAxis:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  ScaledAxis:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromScaledAngleAxis(TpvVector3(ScaledAxis)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromAngularVelocity(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var AngularVelocity:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  AngularVelocity:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromAngularVelocity(TpvVector3(AngularVelocity)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromCols(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var C0,C1,C2:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=3) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[2])=POCAVector3GhostPointer) then begin
  C0:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  C1:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  C2:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[2]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromCols(TpvVector3(C0),TpvVector3(C1),TpvVector3(C2)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionCreateFromXY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var X,Y:TpvVector3D;
    Quaternion:TpvQuaternionD;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  X:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Y:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Quaternion:=TpvQuaternionD.Create(TpvQuaternion.CreateFromXY(TpvVector3(X),TpvVector3(Y)));
  result:=POCANewQuaternion(aContext,Quaternion);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToEuler(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    Euler:TpvVector3D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Euler:=TpvVector3D.Create(TpvQuaternion(Quaternion^).ToEuler);
  result:=POCANewVector3(aContext,Euler);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToPitch(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,TpvQuaternion(Quaternion^).ToPitch);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToYaw(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,TpvQuaternion(Quaternion^).ToYaw);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToRoll(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,TpvQuaternion(Quaternion^).ToRoll);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToAngleAxis(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    Angle:TpvScalar;
    Axis:TpvVector3;
    ResultHash:TPOCAValue;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  TpvQuaternion(Quaternion^).ToAngleAxis(Angle,Axis);
  // Return as hash with 'angle' and 'axis' keys
  ResultHash:=POCANewHash(aContext);
  POCAHashSetString(aContext,ResultHash,'angle',POCANewNumber(aContext,Angle));
  POCAHashSetString(aContext,ResultHash,'axis',POCANewVector3(aContext,TpvVector3D.Create(Axis)));
  result:=ResultHash;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionToScaledAngleAxis(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    ScaledAxis:TpvVector3D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  ScaledAxis:=TpvVector3D.Create(TpvQuaternion(Quaternion^).ToScaledAngleAxis);
  result:=POCANewVector3(aContext,ScaledAxis);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionApproximatedSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    Time:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Time:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).ApproximatedSlerp(TpvQuaternion(Q2^),Time));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionElerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    Time:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Time:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).Elerp(TpvQuaternion(Q2^),Time));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionUnflippedSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    Time:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Time:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).UnflippedSlerp(TpvQuaternion(Q2^),Time));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionUnflippedApproximatedSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    Time:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Time:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).UnflippedApproximatedSlerp(TpvQuaternion(Q2^),Time));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionUnflippedSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2,Q3,Q4:PpvQuaternionD;
    Time:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=5) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[2])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[3])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Q3:=POCAGhostFastGetPointer(aArguments^[2]);
  Q4:=POCAGhostFastGetPointer(aArguments^[3]);
  Time:=POCAGetNumberValue(aContext,aArguments^[4]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).UnflippedSqlerp(TpvQuaternion(Q2^),TpvQuaternion(Q3^),TpvQuaternion(Q4^),Time));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionAngleBetween(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    Angle:TpvDouble;
begin
 if (aCountArguments>=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  Angle:=TpvQuaternion(Q1^).AngleBetween(TpvQuaternion(Q2^));
  result:=POCANewNumber(aContext,Angle);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionBetween(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Q1,Q2:PpvQuaternionD;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Q1:=POCAGhostFastGetPointer(aArguments^[0]);
  Q2:=POCAGhostFastGetPointer(aArguments^[1]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Q1^).Between(TpvQuaternion(Q2^)));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionIntegrate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    Omega:TpvVector3D;
    DeltaTime:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Omega:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  DeltaTime:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Quaternion^).Integrate(TpvVector3(Omega),DeltaTime));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAQuaternionFunctionSpin(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:PpvQuaternionD;
    Omega:TpvVector3D;
    DeltaTime:TpvDouble;
    ResultQuat:TpvQuaternionD;
begin
 if (aCountArguments>=3) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and
    assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Omega:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  DeltaTime:=POCAGetNumberValue(aContext,aArguments^[2]);
  ResultQuat:=TpvQuaternionD.Create(TpvQuaternion(Quaternion^).Spin(TpvVector3(Omega),DeltaTime));
  result:=POCANewQuaternion(aContext,ResultQuat);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitQuaternionHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.QuaternionHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.QuaternionHash);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'conjugate',POCAQuaternionFunctionConjugate);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'inverse',POCAQuaternionFunctionInverse);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'log',POCAQuaternionFunctionLog);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'exp',POCAQuaternionFunctionExp);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'length',POCAQuaternionFunctionLength);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'squaredLength',POCAQuaternionFunctionSquaredLength);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'normalize',POCAQuaternionFunctionNormalize);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'dot',POCAQuaternionFunctionDot);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'cross',POCAQuaternionFunctionCross);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'lerp',POCAQuaternionFunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'nlerp',POCAQuaternionFunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'slerp',POCAQuaternionFunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'sqlerp',POCAQuaternionFunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'clone',POCAQuaternionFunctionClone);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'copy',POCAQuaternionFunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'add',POCAQuaternionFunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'sub',POCAQuaternionFunctionSub);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'mul',POCAQuaternionFunctionMul);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'div',POCAQuaternionFunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'neg',POCAQuaternionFunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'equal',POCAQuaternionFunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'notEqual',POCAQuaternionFunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHash,'toString',POCAQuaternionFunctionToString);

 HostData^.QuaternionHashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.QuaternionHashEvents);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__add',POCAQuaternionFunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__sub',POCAQuaternionFunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__mul',POCAQuaternionFunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__div',POCAQuaternionFunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__eq',POCAQuaternionFunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__neq',POCAQuaternionFunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__neg',POCAQuaternionFunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__sqrt',POCAQuaternionFunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.QuaternionHashEvents,'__tostring',POCAQuaternionFunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.QuaternionHash,HostData^.QuaternionHashEvents);

end;

procedure POCAInitQuaternionNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAQuaternionFunctionCREATE);
 POCAAddNativeFunction(aContext,Hash,'createFromAngleAxis',POCAQuaternionFunctionCreateFromAngleAxis);
 POCAAddNativeFunction(aContext,Hash,'createFromEuler',POCAQuaternionFunctionCreateFromEuler);
 POCAAddNativeFunction(aContext,Hash,'createFromToRotation',POCAQuaternionFunctionCreateFromToRotation);
 POCAAddNativeFunction(aContext,Hash,'createFromLookRotation',POCAQuaternionFunctionCreateFromLookRotation);
 POCAAddNativeFunction(aContext,Hash,'createFromScaledAngleAxis',POCAQuaternionFunctionCreateFromScaledAngleAxis);
 POCAAddNativeFunction(aContext,Hash,'createFromAngularVelocity',POCAQuaternionFunctionCreateFromAngularVelocity);
 POCAAddNativeFunction(aContext,Hash,'createFromCols',POCAQuaternionFunctionCreateFromCols);
 POCAAddNativeFunction(aContext,Hash,'createFromXY',POCAQuaternionFunctionCreateFromXY);
 POCAAddNativeFunction(aContext,Hash,'toEuler',POCAQuaternionFunctionToEuler);
 POCAAddNativeFunction(aContext,Hash,'toPitch',POCAQuaternionFunctionToPitch);
 POCAAddNativeFunction(aContext,Hash,'toYaw',POCAQuaternionFunctionToYaw);
 POCAAddNativeFunction(aContext,Hash,'toRoll',POCAQuaternionFunctionToRoll);
 POCAAddNativeFunction(aContext,Hash,'toAngleAxis',POCAQuaternionFunctionToAngleAxis);
 POCAAddNativeFunction(aContext,Hash,'toScaledAngleAxis',POCAQuaternionFunctionToScaledAngleAxis);
 POCAAddNativeFunction(aContext,Hash,'approximatedSlerp',POCAQuaternionFunctionApproximatedSlerp);
 POCAAddNativeFunction(aContext,Hash,'elerp',POCAQuaternionFunctionElerp);
 POCAAddNativeFunction(aContext,Hash,'unflippedSlerp',POCAQuaternionFunctionUnflippedSlerp);
 POCAAddNativeFunction(aContext,Hash,'unflippedApproximatedSlerp',POCAQuaternionFunctionUnflippedApproximatedSlerp);
 POCAAddNativeFunction(aContext,Hash,'unflippedSqlerp',POCAQuaternionFunctionUnflippedSqlerp);
 POCAAddNativeFunction(aContext,Hash,'angleBetween',POCAQuaternionFunctionAngleBetween);
 POCAAddNativeFunction(aContext,Hash,'between',POCAQuaternionFunctionBetween);
 POCAAddNativeFunction(aContext,Hash,'integrate',POCAQuaternionFunctionIntegrate);
 POCAAddNativeFunction(aContext,Hash,'spin',POCAQuaternionFunctionSpin);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Quaternion',Hash);
end;

procedure POCAInitQuaternion(aContext:PPOCAContext);
begin
 POCAInitQuaternionHash(aContext);
 POCAInitQuaternionNamespace(aContext);
end;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Matrix3x3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAMatrix3x3GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAMatrix3x3GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  result:=true;
 end else if s='m01' then begin
  result:=true;
 end else if s='m02' then begin
  result:=true;
 end else if s='m10' then begin
  result:=true;
 end else if s='m11' then begin
  result:=true;
 end else if s='m12' then begin
  result:=true;
 end else if s='m20' then begin
  result:=true;
 end else if s='m21' then begin
  result:=true;
 end else if s='m22' then begin
  result:=true;
 end else begin
  result:=false;
 end;
end;

function POCAMatrix3x3GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Matrix3x3:PpvMatrix3x3D;
    s:TpvUTF8String;
begin
 Matrix3x3:=PpvMatrix3x3D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  aValue.Num:=Matrix3x3^.RawComponents[0,0];
  result:=true;
 end else if s='m01' then begin
  aValue.Num:=Matrix3x3^.RawComponents[0,1];
  result:=true;
 end else if s='m02' then begin
  aValue.Num:=Matrix3x3^.RawComponents[0,2];
  result:=true;
 end else if s='m10' then begin
  aValue.Num:=Matrix3x3^.RawComponents[1,0];
  result:=true;
 end else if s='m11' then begin
  aValue.Num:=Matrix3x3^.RawComponents[1,1];
  result:=true;
 end else if s='m12' then begin
  aValue.Num:=Matrix3x3^.RawComponents[1,2];
  result:=true;
 end else if s='m20' then begin
  aValue.Num:=Matrix3x3^.RawComponents[2,0];
  result:=true;
 end else if s='m21' then begin
  aValue.Num:=Matrix3x3^.RawComponents[2,1];
  result:=true;
 end else if s='m22' then begin
  aValue.Num:=Matrix3x3^.RawComponents[2,2];
  result:=true;
 end else begin
  result:=false;
 end;
end;

function POCAMatrix3x3GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Matrix3x3:PpvMatrix3x3D;
    s:TpvUTF8String;
begin
 Matrix3x3:=PpvMatrix3x3D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  Matrix3x3^.RawComponents[0,0]:=aValue.Num;
  result:=true;
 end else if s='m01' then begin
  Matrix3x3^.RawComponents[0,1]:=aValue.Num;
  result:=true;
 end else if s='m02' then begin
  Matrix3x3^.RawComponents[0,2]:=aValue.Num;
  result:=true;
 end else if s='m10' then begin
  Matrix3x3^.RawComponents[1,0]:=aValue.Num;
  result:=true;
 end else if s='m11' then begin
  Matrix3x3^.RawComponents[1,1]:=aValue.Num;
  result:=true;
 end else if s='m12' then begin
  Matrix3x3^.RawComponents[1,2]:=aValue.Num;
  result:=true;
 end else if s='m20' then begin
  Matrix3x3^.RawComponents[2,0]:=aValue.Num;
  result:=true;
 end else if s='m21' then begin
  Matrix3x3^.RawComponents[2,1]:=aValue.Num;
  result:=true;
 end else if s='m22' then begin
  Matrix3x3^.RawComponents[2,2]:=aValue.Num;
  result:=true;
 end else begin
  result:=false;
 end;
end;

const POCAMatrix3x3Ghost:TPOCAGhostType=
       (
        Destroy:POCAMatrix3x3GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAMatrix3x3GhostExistKey;
        GetKey:POCAMatrix3x3GhostGetKey;
        SetKey:POCAMatrix3x3GhostSetKey;
        Name:'Matrix3x3'
       );

function POCANewMatrix3x3(const aContext:PPOCAContext;const aMatrix3x3:TpvMatrix3x3D):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 GetMem(Matrix3x3,SizeOf(TpvMatrix3x3D));
 Matrix3x3^:=aMatrix3x3;
 result:=POCANewGhost(aContext,@POCAMatrix3x3Ghost,Matrix3x3,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Matrix3x3Hash);
end;

function POCANewMatrix3x3(const aContext:PPOCAContext;const aM00:TpvDouble;const aM01:TpvDouble;const aM02:TpvDouble;const aM10:TpvDouble;const aM11:TpvDouble;const aM12:TpvDouble;const aM20:TpvDouble;const aM21:TpvDouble;const aM22:TpvDouble):TPOCAValue;
var Matrix3x3:TpvMatrix3x3D; 
begin 
 Matrix3x3.RawComponents[0,0]:=aM00;
 Matrix3x3.RawComponents[0,1]:=aM01; 
 Matrix3x3.RawComponents[0,2]:=aM02;
 Matrix3x3.RawComponents[1,0]:=aM10;
 Matrix3x3.RawComponents[1,1]:=aM11;
 Matrix3x3.RawComponents[1,2]:=aM12;
 Matrix3x3.RawComponents[2,0]:=aM20;
 Matrix3x3.RawComponents[2,1]:=aM21;
 Matrix3x3.RawComponents[2,2]:=aM22;
 result:=POCANewMatrix3x3(aContext,Matrix3x3);
end;

function POCAGetMatrix3x3Value(const aValue:TPOCAValue):TpvMatrix3x3D;
begin
 if POCAGhostGetType(aValue)=@POCAMatrix3x3Ghost then begin
  result:=PpvMatrix3x3D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvMatrix3x3.Create(1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0);
 end;
end;

function POCAMatrix3x3FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:TpvMatrix3x3D;
    Matrix4x4:PpvMatrix4x4D;
    Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=PpvMatrix3x3D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=POCAMatrix4x4GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3.RawComponents[0,0]:=Matrix4x4^.RawComponents[0,0];
  Matrix3x3.RawComponents[0,1]:=Matrix4x4^.RawComponents[0,1];
  Matrix3x3.RawComponents[0,2]:=Matrix4x4^.RawComponents[0,2];
  Matrix3x3.RawComponents[1,0]:=Matrix4x4^.RawComponents[1,0];
  Matrix3x3.RawComponents[1,1]:=Matrix4x4^.RawComponents[1,1];
  Matrix3x3.RawComponents[1,2]:=Matrix4x4^.RawComponents[1,2];
  Matrix3x3.RawComponents[2,0]:=Matrix4x4^.RawComponents[2,0];
  Matrix3x3.RawComponents[2,1]:=Matrix4x4^.RawComponents[2,1];
  Matrix3x3.RawComponents[2,2]:=Matrix4x4^.RawComponents[2,2];
 end else if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3:=TpvMatrix3x3D.Create(Quaternion^);
 end else begin
  if aCountArguments>0 then begin
   Matrix3x3.RawComponents[0,0]:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Matrix3x3.RawComponents[0,0]:=1.0;
  end;
  if aCountArguments>1 then begin
   Matrix3x3.RawComponents[0,1]:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Matrix3x3.RawComponents[0,1]:=0.0;
  end;
  if aCountArguments>2 then begin
   Matrix3x3.RawComponents[0,2]:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Matrix3x3.RawComponents[0,2]:=0.0;
  end;
  if aCountArguments>3 then begin
   Matrix3x3.RawComponents[1,0]:=POCAGetNumberValue(aContext,aArguments^[3]);
  end else begin
   Matrix3x3.RawComponents[1,0]:=0.0;
  end;
  if aCountArguments>4 then begin
   Matrix3x3.RawComponents[1,1]:=POCAGetNumberValue(aContext,aArguments^[4]);
  end else begin
   Matrix3x3.RawComponents[1,1]:=1.0;
  end;    
  if aCountArguments>5 then begin
   Matrix3x3.RawComponents[1,2]:=POCAGetNumberValue(aContext,aArguments^[5]);
  end else begin
   Matrix3x3.RawComponents[1,2]:=0.0;
  end;
  if aCountArguments>6 then begin
   Matrix3x3.RawComponents[2,0]:=POCAGetNumberValue(aContext,aArguments^[6]);
  end else begin
   Matrix3x3.RawComponents[2,0]:=0.0;
  end;
  if aCountArguments>7 then begin
   Matrix3x3.RawComponents[2,1]:=POCAGetNumberValue(aContext,aArguments^[7]);
  end else begin
   Matrix3x3.RawComponents[2,1]:=0.0;
  end;
  if aCountArguments>8 then begin
   Matrix3x3.RawComponents[2,2]:=POCAGetNumberValue(aContext,aArguments^[8]);
  end else begin
   Matrix3x3.RawComponents[2,2]:=1.0;
  end;
 end;
 result:=POCANewMatrix3x3(aContext,Matrix3x3);
end;

function POCAMatrix3x3FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=Matrix3x3^+OtherMatrix3x3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=Matrix3x3^-OtherMatrix3x3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=OtherMatrix3x3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    OtherVector2:PpvVector2D;
    OtherVector3:PpvVector3D;
    OtherVector4:PpvVector4D;
    OtherQuaternion:PpvQuaternionD;
    v:TpvVector4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix3x3^:=Matrix3x3^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=Matrix3x3^*OtherMatrix3x3^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2GhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(Matrix3x3^*TpvVector3.Create(OtherVector2^.x,OtherVector2^.y,0.0)).xy);
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Matrix3x3^*OtherVector3^);
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  v.xyz:=Matrix3x3^*TpvVector3D.Create(OtherVector4^.x,OtherVector4^.y,OtherVector4^.z);
  v.w:=1.0;
  result:=POCANewVector4(aContext,v);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=POCAQuaternionGhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=Matrix3x3^*OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix3x3^:=Matrix3x3^/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix3x3^:=Matrix3x3^/OtherMatrix3x3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Matrix3x3^:=-Matrix3x3^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^+OtherMatrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^-OtherMatrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Vector2:PpvVector2D;
    Vector3:PpvVector3D;
    Vector4:PpvVector4D;
    Quaternion:PpvQuaternionD;
    v:TpvVector4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^*OtherMatrix3x3^);
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector2GhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,(Matrix3x3^*TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)).xy);
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)*Matrix3x3^).xy);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,Matrix3x3^*Vector3^);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,Vector3^*Matrix3x3^);
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector4GhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4:=POCAGhostFastGetPointer(aArguments^[1]);
  v.xyz:=Matrix3x3^*TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z);
  v.w:=1.0;
  result:=POCANewVector4(aContext,v);
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  v.xyz:=TpvVector3D.Create(Vector4^.x,Vector4^.y,Vector4^.z)*Matrix3x3^;
  v.w:=1.0;
  result:=POCANewVector4(aContext,v);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=POCAQuaternionGhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^*Quaternion^);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAQuaternionGhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewMatrix3x3(aContext,Quaternion^*Matrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3^/OtherMatrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewMatrix3x3(aContext,-Matrix3x3^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:TpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=PpvMatrix3x3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix3x3.RawComponents[0,0]:=Sqrt(Matrix3x3.RawComponents[0,0]);
  Matrix3x3.RawComponents[0,1]:=Sqrt(Matrix3x3.RawComponents[0,1]);
  Matrix3x3.RawComponents[0,2]:=Sqrt(Matrix3x3.RawComponents[0,2]);
  Matrix3x3.RawComponents[1,0]:=Sqrt(Matrix3x3.RawComponents[1,0]);
  Matrix3x3.RawComponents[1,1]:=Sqrt(Matrix3x3.RawComponents[1,1]);
  Matrix3x3.RawComponents[1,2]:=Sqrt(Matrix3x3.RawComponents[1,2]);
  Matrix3x3.RawComponents[2,0]:=Sqrt(Matrix3x3.RawComponents[2,0]);
  Matrix3x3.RawComponents[2,1]:=Sqrt(Matrix3x3.RawComponents[2,1]);
  Matrix3x3.RawComponents[2,2]:=Sqrt(Matrix3x3.RawComponents[2,2]);
  result:=POCANewMatrix3x3(aContext,Matrix3x3);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='[['+ConvertDoubleToString(Matrix3x3^.RawComponents[0,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[0,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[0,2],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix3x3^.RawComponents[1,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[1,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[1,2],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix3x3^.RawComponents[2,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[2,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[2,2],omStandard,-1)+']]';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Matrix3x3^=OtherMatrix3x3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Matrix3x3^<>OtherMatrix3x3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionTranspose(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Matrix3x3^:=Matrix3x3^.Transpose;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionDeterminant(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=Matrix3x3^.Determinant;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionInverse(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Matrix3x3^:=Matrix3x3^.Inverse;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionAdjugate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  Matrix3x3^:=Matrix3x3^.Adjugate;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix3x3^:=Matrix3x3^.Lerp(OtherMatrix3x3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix3x3^:=Matrix3x3^.Nlerp(OtherMatrix3x3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix3x3^:=Matrix3x3^.Slerp(OtherMatrix3x3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionElerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix3x3^:=Matrix3x3^.Elerp(OtherMatrix3x3^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvMatrix3x3D;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[2])=@POCAMatrix3x3Ghost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=PpvMatrix3x3D(POCAGhostFastGetPointer(aThis));
  B:=PpvMatrix3x3D(POCAGhostFastGetPointer(aArguments^[0]));
  C:=PpvMatrix3x3D(POCAGhostFastGetPointer(aArguments^[1]));
  D:=PpvMatrix3x3D(POCAGhostFastGetPointer(aArguments^[2]));
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Matrix3x3^=OtherMatrix3x3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3,OtherMatrix3x3:PpvMatrix3x3D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  OtherMatrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Matrix3x3^<>OtherMatrix3x3^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix3x3:PpvMatrix3x3D;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix3x3Ghost) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aThis);
  s:='[['+ConvertDoubleToString(Matrix3x3^.RawComponents[0,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[0,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[0,2],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix3x3^.RawComponents[1,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[1,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[1,2],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix3x3^.RawComponents[2,0],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[2,1],omStandard,-1)+','+ConvertDoubleToString(Matrix3x3^.RawComponents[2,2],omStandard,-1)+']]';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateRotateX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateRotateX(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateRotateY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateRotateY(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateRotateZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateRotateZ(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateRotate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Axis:TpvVector3D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Axis:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateRotate(Angle,TpvVector3(Axis)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateScale(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sx,Sy,Sz:TpvDouble;
    Scale:TpvVector3D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  // From Vector3
  Scale:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateScale(TpvVector3(Scale)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else if aCountArguments>=3 then begin
  // From three scalars
  Sx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Sy:=POCAGetNumberValue(aContext,aArguments^[1]);
  Sz:=POCAGetNumberValue(aContext,aArguments^[2]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateScale(Sx,Sy,Sz));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else if aCountArguments>=2 then begin
  // From two scalars (for 2D)
  Sx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Sy:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateScale(Sx,Sy));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateTranslation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Tx,Ty:TpvDouble;
    Translation:TpvVector2D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=1) and assigned(POCAVector2GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) then begin
  // From Vector2
  Translation:=PpvVector2D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateTranslation(TpvVector2(Translation)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else if aCountArguments>=2 then begin
  // From two scalars
  Tx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Ty:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateTranslation(Tx,Ty));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateFromQuaternion(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:TpvQuaternionD;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=PpvQuaternionD(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateFromQuaternion(TpvQuaternion(Quaternion)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateFromQTangent(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var QTangent:TpvQuaternionD;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  QTangent:=PpvQuaternionD(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateFromQTangent(TpvQuaternion(QTangent)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateFromToRotation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var FromDir,ToDir:TpvVector3D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  FromDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  ToDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateFromToRotation(TpvVector3(FromDir),TpvVector3(ToDir)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateConstructForwardUp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Forward,Up:TpvVector3D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Forward:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Up:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateConstructForwardUp(TpvVector3(Forward),TpvVector3(Up)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateOuterProduct(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var U,V:TpvVector3D;
    Matrix:TpvMatrix3x3D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  U:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  V:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateOuterProduct(TpvVector3(U),TpvVector3(V)));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewYX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewYX(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewZX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewZX(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewXY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewXY(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewZY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewZY(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewXZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewXZ(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix3x3FunctionCreateSkewYZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix3x3D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix3x3D.Create(TpvMatrix3x3.CreateSkewYZ(Angle));
  result:=POCANewMatrix3x3(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitMatrix3x3Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.Matrix3x3Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Matrix3x3Hash);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'add',POCAMatrix3x3FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'sub',POCAMatrix3x3FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'clone',POCAMatrix3x3FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'copy',POCAMatrix3x3FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'mul',POCAMatrix3x3FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'div',POCAMatrix3x3FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'neg',POCAMatrix3x3FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'transpose',POCAMatrix3x3FunctionTranspose);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'determinant',POCAMatrix3x3FunctionDeterminant);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'inverse',POCAMatrix3x3FunctionInverse);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'adjugate',POCAMatrix3x3FunctionAdjugate);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'lerp',POCAMatrix3x3FunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'nlerp',POCAMatrix3x3FunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'slerp',POCAMatrix3x3FunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'elerp',POCAMatrix3x3FunctionElerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'sqlerp',POCAMatrix3x3FunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'equal',POCAMatrix3x3FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'notEqual',POCAMatrix3x3FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3Hash,'toString',POCAMatrix3x3FunctionToString);

 HostData^.Matrix3x3HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Matrix3x3HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__add',POCAMatrix3x3FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__sub',POCAMatrix3x3FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__mul',POCAMatrix3x3FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__div',POCAMatrix3x3FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__eq',POCAMatrix3x3FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__neq',POCAMatrix3x3FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__neg',POCAMatrix3x3FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__sqrt',POCAMatrix3x3FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Matrix3x3HashEvents,'__tostring',POCAMatrix3x3FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Matrix3x3Hash,HostData^.Matrix3x3HashEvents);

end;

procedure POCAInitMatrix3x3Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAMatrix3x3FunctionCREATE);
 POCAAddNativeFunction(aContext,Hash,'createRotateX',POCAMatrix3x3FunctionCreateRotateX);
 POCAAddNativeFunction(aContext,Hash,'createRotateY',POCAMatrix3x3FunctionCreateRotateY);
 POCAAddNativeFunction(aContext,Hash,'createRotateZ',POCAMatrix3x3FunctionCreateRotateZ);
 POCAAddNativeFunction(aContext,Hash,'createRotate',POCAMatrix3x3FunctionCreateRotate);
 POCAAddNativeFunction(aContext,Hash,'createScale',POCAMatrix3x3FunctionCreateScale);
 POCAAddNativeFunction(aContext,Hash,'createTranslation',POCAMatrix3x3FunctionCreateTranslation);
 POCAAddNativeFunction(aContext,Hash,'createFromQuaternion',POCAMatrix3x3FunctionCreateFromQuaternion);
 POCAAddNativeFunction(aContext,Hash,'createFromQTangent',POCAMatrix3x3FunctionCreateFromQTangent);
 POCAAddNativeFunction(aContext,Hash,'createFromToRotation',POCAMatrix3x3FunctionCreateFromToRotation);
 POCAAddNativeFunction(aContext,Hash,'createConstructForwardUp',POCAMatrix3x3FunctionCreateConstructForwardUp);
 POCAAddNativeFunction(aContext,Hash,'createOuterProduct',POCAMatrix3x3FunctionCreateOuterProduct);
 POCAAddNativeFunction(aContext,Hash,'createSkewYX',POCAMatrix3x3FunctionCreateSkewYX);
 POCAAddNativeFunction(aContext,Hash,'createSkewZX',POCAMatrix3x3FunctionCreateSkewZX);
 POCAAddNativeFunction(aContext,Hash,'createSkewXY',POCAMatrix3x3FunctionCreateSkewXY);
 POCAAddNativeFunction(aContext,Hash,'createSkewZY',POCAMatrix3x3FunctionCreateSkewZY);
 POCAAddNativeFunction(aContext,Hash,'createSkewXZ',POCAMatrix3x3FunctionCreateSkewXZ);
 POCAAddNativeFunction(aContext,Hash,'createSkewYZ',POCAMatrix3x3FunctionCreateSkewYZ);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Matrix3x3',Hash);
end;

procedure POCAInitMatrix3x3(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 POCAInitMatrix3x3Hash(aContext);
 POCAInitMatrix3x3Namespace(aContext);
end;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Matrix4x4
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure POCAMatrix4x4GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAMatrix4x4GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TpvUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  result:=true;
 end else if s='m01' then begin
  result:=true;
 end else if s='m02' then begin
  result:=true;
 end else if s='m03' then begin
  result:=true;
 end else if s='m10' then begin
  result:=true;
 end else if s='m11' then begin
  result:=true;
 end else if s='m12' then begin
  result:=true;
 end else if s='m13' then begin
  result:=true;
 end else if s='m20' then begin
  result:=true;
 end else if s='m21' then begin
  result:=true;
 end else if s='m22' then begin
  result:=true;
 end else if s='m23' then begin
  result:=true;
 end else if s='m30' then begin
  result:=true;
 end else if s='m31' then begin
  result:=true;
 end else if s='m32' then begin
  result:=true;
 end else if s='m33' then begin
  result:=true;
 end else begin
  result:=false;
 end;
end;

function POCAMatrix4x4GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Matrix4x4:PpvMatrix4x4D;
    s:TpvUTF8String;
begin
 Matrix4x4:=PpvMatrix4x4D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  aValue.Num:=Matrix4x4^.RawComponents[0,0];
  result:=true;
 end else if s='m01' then begin
  aValue.Num:=Matrix4x4^.RawComponents[0,1];
  result:=true;
 end else if s='m02' then begin
  aValue.Num:=Matrix4x4^.RawComponents[0,2];
  result:=true;
 end else if s='m03' then begin
  aValue.Num:=Matrix4x4^.RawComponents[0,3];
  result:=true;
 end else if s='m10' then begin
  aValue.Num:=Matrix4x4^.RawComponents[1,0];
  result:=true;
 end else if s='m11' then begin
  aValue.Num:=Matrix4x4^.RawComponents[1,1];
  result:=true;
 end else if s='m12' then begin
  aValue.Num:=Matrix4x4^.RawComponents[1,2];
  result:=true;
 end else if s='m13' then begin
  aValue.Num:=Matrix4x4^.RawComponents[1,3];
  result:=true;
 end else if s='m20' then begin
  aValue.Num:=Matrix4x4^.RawComponents[2,0];
  result:=true;
 end else if s='m21' then begin
  aValue.Num:=Matrix4x4^.RawComponents[2,1];
  result:=true;
 end else if s='m22' then begin
  aValue.Num:=Matrix4x4^.RawComponents[2,2];
  result:=true;
 end else if s='m23' then begin
  aValue.Num:=Matrix4x4^.RawComponents[2,3];
  result:=true;
 end else if s='m30' then begin
  aValue.Num:=Matrix4x4^.RawComponents[3,0];
  result:=true;
 end else if s='m31' then begin
  aValue.Num:=Matrix4x4^.RawComponents[3,1];
  result:=true;
 end else if s='m32' then begin
  aValue.Num:=Matrix4x4^.RawComponents[3,2];
  result:=true;
 end else if s='m33' then begin
  aValue.Num:=Matrix4x4^.RawComponents[3,3];
  result:=true;
 end else begin
  result:=false;
 end;
end;

function POCAMatrix4x4GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Matrix4x4:PpvMatrix4x4D;
    s:TpvUTF8String;
begin
 Matrix4x4:=PpvMatrix4x4D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if s='m00' then begin
  Matrix4x4^.RawComponents[0,0]:=aValue.Num;
  result:=true;
 end else if s='m01' then begin
  Matrix4x4^.RawComponents[0,1]:=aValue.Num;
  result:=true;
 end else if s='m02' then begin
  Matrix4x4^.RawComponents[0,2]:=aValue.Num;
  result:=true;
 end else if s='m03' then begin
  Matrix4x4^.RawComponents[0,3]:=aValue.Num;
  result:=true;
 end else if s='m10' then begin
  Matrix4x4^.RawComponents[1,0]:=aValue.Num;
  result:=true;
 end else if s='m11' then begin
  Matrix4x4^.RawComponents[1,1]:=aValue.Num;
  result:=true;
 end else if s='m12' then begin
  Matrix4x4^.RawComponents[1,2]:=aValue.Num;
  result:=true;
 end else if s='m13' then begin
  Matrix4x4^.RawComponents[1,3]:=aValue.Num;
  result:=true;
 end else if s='m20' then begin
  Matrix4x4^.RawComponents[2,0]:=aValue.Num;
  result:=true;
 end else if s='m21' then begin
  Matrix4x4^.RawComponents[2,1]:=aValue.Num;
  result:=true;
 end else if s='m22' then begin
  Matrix4x4^.RawComponents[2,2]:=aValue.Num;
  result:=true;
 end else if s='m23' then begin
  Matrix4x4^.RawComponents[2,3]:=aValue.Num;
  result:=true;
 end else if s='m30' then begin
  Matrix4x4^.RawComponents[3,0]:=aValue.Num;
  result:=true;
 end else if s='m31' then begin
  Matrix4x4^.RawComponents[3,1]:=aValue.Num;
  result:=true;
 end else if s='m32' then begin
  Matrix4x4^.RawComponents[3,2]:=aValue.Num;
  result:=true;
 end else if s='m33' then begin
  Matrix4x4^.RawComponents[3,3]:=aValue.Num;
  result:=true;
 end else begin
  result:=false;
 end;
end;

const POCAMatrix4x4Ghost:TPOCAGhostType=
       (
        Destroy:POCAMatrix4x4GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAMatrix4x4GhostExistKey;
        GetKey:POCAMatrix4x4GhostGetKey;
        SetKey:POCAMatrix4x4GhostSetKey;
        Name:'Matrix4x4'
       );

function POCANewMatrix4x4(const aContext:PPOCAContext;const aMatrix4x4:TpvMatrix4x4D):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 GetMem(Matrix4x4,SizeOf(TpvMatrix4x4D));
 Matrix4x4^:=aMatrix4x4;
 result:=POCANewGhost(aContext,@POCAMatrix4x4Ghost,Matrix4x4,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Matrix4x4Hash);
end;

function POCANewMatrix4x4(const aContext:PPOCAContext;const aM00:TpvDouble;const aM01:TpvDouble;const aM02:TpvDouble;const aM03:TpvDouble;const aM10:TpvDouble;const aM11:TpvDouble;const aM12:TpvDouble;const aM13:TpvDouble;const aM20:TpvDouble;const aM21:TpvDouble;const aM22:TpvDouble;const aM23:TpvDouble;const aM30:TpvDouble;const aM31:TpvDouble;const aM32:TpvDouble;const aM33:TpvDouble):TPOCAValue;
var Matrix4x4:TpvMatrix4x4D; 
begin 
 Matrix4x4.RawComponents[0,0]:=aM00;
 Matrix4x4.RawComponents[0,1]:=aM01; 
 Matrix4x4.RawComponents[0,2]:=aM02;
 Matrix4x4.RawComponents[0,3]:=aM03;
 Matrix4x4.RawComponents[1,0]:=aM10;
 Matrix4x4.RawComponents[1,1]:=aM11;
 Matrix4x4.RawComponents[1,2]:=aM12;
 Matrix4x4.RawComponents[1,3]:=aM13;
 Matrix4x4.RawComponents[2,0]:=aM20;
 Matrix4x4.RawComponents[2,1]:=aM21;
 Matrix4x4.RawComponents[2,2]:=aM22;
 Matrix4x4.RawComponents[2,3]:=aM23;
 Matrix4x4.RawComponents[3,0]:=aM30;
 Matrix4x4.RawComponents[3,1]:=aM31;
 Matrix4x4.RawComponents[3,2]:=aM32;
 Matrix4x4.RawComponents[3,3]:=aM33;
 result:=POCANewMatrix4x4(aContext,Matrix4x4);
end;

function POCAGetMatrix4x4Value(const aValue:TPOCAValue):TpvMatrix4x4D;
begin
 if POCAGhostGetType(aValue)=@POCAMatrix4x4Ghost then begin
  result:=PpvMatrix4x4D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result:=TpvMatrix4x4.Create(1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0);
 end;
end;

function POCAMatrix4x4FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:TpvMatrix4x4D;
    Matrix3x3:PpvMatrix3x3D;
    Quaternion:PpvQuaternionD;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=PpvMatrix4x4D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else if assigned(POCAMatrix3x3GhostPointer) and (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=POCAMatrix3x3GhostPointer) then begin
  Matrix3x3:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4.RawComponents[0,0]:=Matrix3x3^.RawComponents[0,0];
  Matrix4x4.RawComponents[0,1]:=Matrix3x3^.RawComponents[0,1];
  Matrix4x4.RawComponents[0,2]:=Matrix3x3^.RawComponents[0,2];
  Matrix4x4.RawComponents[0,3]:=0.0;
  Matrix4x4.RawComponents[1,0]:=Matrix3x3^.RawComponents[1,0];
  Matrix4x4.RawComponents[1,1]:=Matrix3x3^.RawComponents[1,1];
  Matrix4x4.RawComponents[1,2]:=Matrix3x3^.RawComponents[1,2];
  Matrix4x4.RawComponents[1,3]:=0.0;
  Matrix4x4.RawComponents[2,0]:=Matrix3x3^.RawComponents[2,0];
  Matrix4x4.RawComponents[2,1]:=Matrix3x3^.RawComponents[2,1];
  Matrix4x4.RawComponents[2,2]:=Matrix3x3^.RawComponents[2,2];
  Matrix4x4.RawComponents[2,3]:=0.0;
  Matrix4x4.RawComponents[3,0]:=0.0;
  Matrix4x4.RawComponents[3,1]:=0.0;
  Matrix4x4.RawComponents[3,2]:=0.0;
  Matrix4x4.RawComponents[3,3]:=1.0;
 end else if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4:=TpvMatrix4x4D.Create(Quaternion^);
 end else begin
  if aCountArguments>0 then begin
   Matrix4x4.RawComponents[0,0]:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Matrix4x4.RawComponents[0,0]:=1.0;
  end;
  if aCountArguments>1 then begin
   Matrix4x4.RawComponents[0,1]:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Matrix4x4.RawComponents[0,1]:=0.0;
  end;
  if aCountArguments>2 then begin
   Matrix4x4.RawComponents[0,2]:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Matrix4x4.RawComponents[0,2]:=0.0;
  end;
  if aCountArguments>3 then begin
   Matrix4x4.RawComponents[0,3]:=POCAGetNumberValue(aContext,aArguments^[3]);
  end else begin
   Matrix4x4.RawComponents[0,3]:=0.0;
  end;
  if aCountArguments>4 then begin
   Matrix4x4.RawComponents[1,0]:=POCAGetNumberValue(aContext,aArguments^[4]);
  end else begin
   Matrix4x4.RawComponents[1,0]:=0.0;
  end;
  if aCountArguments>5 then begin
   Matrix4x4.RawComponents[1,1]:=POCAGetNumberValue(aContext,aArguments^[5]);
  end else begin
   Matrix4x4.RawComponents[1,1]:=1.0;
  end;
  if aCountArguments>6 then begin
   Matrix4x4.RawComponents[1,2]:=POCAGetNumberValue(aContext,aArguments^[6]);
  end else begin
   Matrix4x4.RawComponents[1,2]:=0.0;
  end;
  if aCountArguments>7 then begin
   Matrix4x4.RawComponents[1,3]:=POCAGetNumberValue(aContext,aArguments^[7]);
  end else begin
   Matrix4x4.RawComponents[1,3]:=0.0;
  end;
  if aCountArguments>8 then begin
   Matrix4x4.RawComponents[2,0]:=POCAGetNumberValue(aContext,aArguments^[8]);
  end else begin
   Matrix4x4.RawComponents[2,0]:=0.0;
  end;
  if aCountArguments>9 then begin
   Matrix4x4.RawComponents[2,1]:=POCAGetNumberValue(aContext,aArguments^[9]);
  end else begin
   Matrix4x4.RawComponents[2,1]:=0.0;
  end;
  if aCountArguments>10 then begin
   Matrix4x4.RawComponents[2,2]:=POCAGetNumberValue(aContext,aArguments^[10]);
  end else begin
   Matrix4x4.RawComponents[2,2]:=1.0;
  end;
  if aCountArguments>11 then begin
   Matrix4x4.RawComponents[2,3]:=POCAGetNumberValue(aContext,aArguments^[11]);
  end else begin
   Matrix4x4.RawComponents[2,3]:=0.0;
  end;
  if aCountArguments>12 then begin
   Matrix4x4.RawComponents[3,0]:=POCAGetNumberValue(aContext,aArguments^[12]);
  end else begin
   Matrix4x4.RawComponents[3,0]:=0.0;
  end;
  if aCountArguments>13 then begin
   Matrix4x4.RawComponents[3,1]:=POCAGetNumberValue(aContext,aArguments^[13]);
  end else begin
   Matrix4x4.RawComponents[3,1]:=0.0;
  end;
  if aCountArguments>14 then begin
   Matrix4x4.RawComponents[3,2]:=POCAGetNumberValue(aContext,aArguments^[14]);
  end else begin
   Matrix4x4.RawComponents[3,2]:=0.0;
  end;
  if aCountArguments>15 then begin
   Matrix4x4.RawComponents[3,3]:=POCAGetNumberValue(aContext,aArguments^[15]);
  end else begin
   Matrix4x4.RawComponents[3,3]:=1.0;
  end;  
 end;
 result:=POCANewMatrix4x4(aContext,Matrix4x4);
end;

function POCAMatrix4x4FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=Matrix4x4^+OtherMatrix4x4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=Matrix4x4^-OtherMatrix4x4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=OtherMatrix4x4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    OtherVector2:PpvVector2D;
    OtherVector3:PpvVector3D;
    OtherVector4:PpvVector4D;
    OtherQuaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix4x4^:=Matrix4x4^*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=Matrix4x4^*OtherMatrix4x4^;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(Matrix4x4^*TpvVector3.Create(OtherVector2^.x,OtherVector2^.y,0.0)).xy);
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector3Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherVector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,(Matrix4x4^*OtherVector3^).xyz);
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherVector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,Matrix4x4^*OtherVector4^);
 end else if assigned(POCAQuaternionGhostPointer) and (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=POCAQuaternionGhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherQuaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=Matrix4x4^*OtherQuaternion^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix4x4^:=Matrix4x4^/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix4x4^:=Matrix4x4^/OtherMatrix4x4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Matrix4x4^:=-Matrix4x4^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^+OtherMatrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^-OtherMatrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Vector2:PpvVector2D;
    Vector3:PpvVector3D;
    Vector4:PpvVector4D;
    Quaternion:PpvQuaternionD;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^*Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^*OtherMatrix4x4^);
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector2GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector2(aContext,(Matrix4x4^*TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)).xy);
 end else if assigned(POCAVector2GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector2GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,(TpvVector3D.Create(Vector2^.x,Vector2^.y,0.0)*Matrix4x4^).xy);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector3(aContext,(Matrix4x4^*Vector3^).xyz);
 end else if assigned(POCAVector3GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector3:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector3(aContext,(Vector3^*Matrix4x4^).xyz);
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=POCAVector4GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewVector4(aContext,Matrix4x4^*Vector4^);
 end else if assigned(POCAVector4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  Vector4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector4(aContext,Vector4^*Matrix4x4^);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=POCAMatrix4x4GhostPointer) and (POCAGhostGetType(aArguments^[1])=@POCAQuaternionGhost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^*Quaternion^);
 end else if assigned(POCAMatrix4x4GhostPointer) and (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) and (POCAGhostGetType(aArguments^[1])=POCAMatrix4x4GhostPointer) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  Quaternion:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewMatrix4x4(aContext,Quaternion^*Matrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Factor:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^/Factor);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4^/OtherMatrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewMatrix4x4(aContext,-Matrix4x4^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:TpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=PpvMatrix4x4D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix4x4.RawComponents[0,0]:=Sqrt(Matrix4x4.RawComponents[0,0]);
  Matrix4x4.RawComponents[0,1]:=Sqrt(Matrix4x4.RawComponents[0,1]);
  Matrix4x4.RawComponents[0,2]:=Sqrt(Matrix4x4.RawComponents[0,2]);
  Matrix4x4.RawComponents[1,0]:=Sqrt(Matrix4x4.RawComponents[1,0]);
  Matrix4x4.RawComponents[1,1]:=Sqrt(Matrix4x4.RawComponents[1,1]);
  Matrix4x4.RawComponents[1,2]:=Sqrt(Matrix4x4.RawComponents[1,2]);
  Matrix4x4.RawComponents[2,0]:=Sqrt(Matrix4x4.RawComponents[2,0]);
  Matrix4x4.RawComponents[2,1]:=Sqrt(Matrix4x4.RawComponents[2,1]);
  Matrix4x4.RawComponents[2,2]:=Sqrt(Matrix4x4.RawComponents[2,2]);
  result:=POCANewMatrix4x4(aContext,Matrix4x4);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
    s:TpvUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='[['+ConvertDoubleToString(Matrix4x4^.RawComponents[0,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[1,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[2,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[3,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,3],omStandard,-1)+']]';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Matrix4x4^=OtherMatrix4x4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord(Matrix4x4^<>OtherMatrix4x4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionTranspose(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Matrix4x4^:=Matrix4x4^.Transpose;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionDeterminant(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  result.Num:=Matrix4x4^.Determinant;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionInverse(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Matrix4x4^:=Matrix4x4^.Inverse;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionAdjugate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  Matrix4x4^:=Matrix4x4^.Adjugate;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionLerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix4x4^:=Matrix4x4^.Lerp(OtherMatrix4x4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionNlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix4x4^:=Matrix4x4^.Nlerp(OtherMatrix4x4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionSlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix4x4^:=Matrix4x4^.Slerp(OtherMatrix4x4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionElerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
    Time:TpvDouble;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  Time:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix4x4^:=Matrix4x4^.Elerp(OtherMatrix4x4^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionSqlerp(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var A,B,C,D:PpvMatrix4x4D;
    Time:TpvDouble;
begin
 if (aCountArguments=4) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[2])=@POCAMatrix4x4Ghost) and (POCAGetValueType(aArguments^[3])=pvtNUMBER) then begin
  A:=PpvMatrix4x4D(POCAGhostFastGetPointer(aThis));
  B:=PpvMatrix4x4D(POCAGhostFastGetPointer(aArguments^[0]));
  C:=PpvMatrix4x4D(POCAGhostFastGetPointer(aArguments^[1]));
  D:=PpvMatrix4x4D(POCAGhostFastGetPointer(aArguments^[2]));
  Time:=POCAGetNumberValue(aContext,aArguments^[3]);
  A^:=A^.Sqlerp(B^,C^,D^,Time);
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Matrix4x4^=OtherMatrix4x4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4,OtherMatrix4x4:PpvMatrix4x4D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  OtherMatrix4x4:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord(Matrix4x4^<>OtherMatrix4x4^) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Matrix4x4:PpvMatrix4x4D;
    s:TpvUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAMatrix4x4Ghost) then begin
  Matrix4x4:=POCAGhostFastGetPointer(aThis);
  s:='[['+ConvertDoubleToString(Matrix4x4^.RawComponents[0,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[0,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[1,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[1,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[2,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[2,3],omStandard,-1)+'],'+
      '['+ConvertDoubleToString(Matrix4x4^.RawComponents[3,0],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,1],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,2],omStandard,-1)+','+ConvertDoubleToString(Matrix4x4^.RawComponents[3,3],omStandard,-1)+']]';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateRotateX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateRotateX(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateRotateY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateRotateY(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateRotateZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateRotateZ(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateRotate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Axis:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Axis:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateRotate(Angle,TpvVector3(Axis)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateRotation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SourceMatrix:PpvMatrix4x4D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) then begin
  SourceMatrix:=POCAGhostFastGetPointer(aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateRotation(TpvMatrix4x4(SourceMatrix^)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateScale(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sx,Sy,Sz:TpvDouble;
    Scale:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  // From Vector3
  Scale:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateScale(TpvVector3(Scale)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else if aCountArguments>=3 then begin
  // From three scalars
  Sx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Sy:=POCAGetNumberValue(aContext,aArguments^[1]);
  Sz:=POCAGetNumberValue(aContext,aArguments^[2]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateScale(Sx,Sy,Sz));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else if aCountArguments>=2 then begin
  // From two scalars
  Sx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Sy:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateScale(Sx,Sy));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateTranslation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Tx,Ty,Tz:TpvDouble;
    Translation:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=1) and assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) then begin
  // From Vector3
  Translation:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateTranslation(TpvVector3(Translation)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else if aCountArguments>=3 then begin
  // From three scalars
  Tx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Ty:=POCAGetNumberValue(aContext,aArguments^[1]);
  Tz:=POCAGetNumberValue(aContext,aArguments^[2]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateTranslation(Tx,Ty,Tz));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else if aCountArguments>=2 then begin
  // From two scalars
  Tx:=POCAGetNumberValue(aContext,aArguments^[0]);
  Ty:=POCAGetNumberValue(aContext,aArguments^[1]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateTranslation(Tx,Ty));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateTranslated(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SourceMatrix:PpvMatrix4x4D;
    Translation:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=2) and (POCAGhostGetType(aArguments^[0])=@POCAMatrix4x4Ghost) and
    assigned(POCAVector3GhostPointer) and (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  SourceMatrix:=POCAGhostFastGetPointer(aArguments^[0]);
  Translation:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateTranslated(TpvMatrix4x4(SourceMatrix^),TpvVector3(Translation)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateFromQuaternion(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Quaternion:TpvQuaternionD;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=1) and (POCAGhostGetType(aArguments^[0])=@POCAQuaternionGhost) then begin
  Quaternion:=PpvQuaternionD(POCAGhostFastGetPointer(aArguments^[0]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateFromQuaternion(TpvQuaternion(Quaternion)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateFromToRotation(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var FromDir,ToDir:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=2) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) then begin
  FromDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  ToDir:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateFromToRotation(TpvVector3(FromDir),TpvVector3(ToDir)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateLookAt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Eye,Center,Up:TpvVector3D;
    Matrix:TpvMatrix4x4D;
begin
 if (aCountArguments>=3) and assigned(POCAVector3GhostPointer) and 
    (POCAGhostGetType(aArguments^[0])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[1])=POCAVector3GhostPointer) and
    (POCAGhostGetType(aArguments^[2])=POCAVector3GhostPointer) then begin
  Eye:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[0]))^;
  Center:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[1]))^;
  Up:=PpvVector3D(POCAGhostFastGetPointer(aArguments^[2]))^;
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateLookAt(TpvVector3(Eye),TpvVector3(Center),TpvVector3(Up)));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreatePerspective(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Fovy,Aspect,ZNear,ZFar:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=4 then begin
  Fovy:=POCAGetNumberValue(aContext,aArguments^[0]);
  Aspect:=POCAGetNumberValue(aContext,aArguments^[1]);
  ZNear:=POCAGetNumberValue(aContext,aArguments^[2]);
  ZFar:=POCAGetNumberValue(aContext,aArguments^[3]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreatePerspective(Fovy,Aspect,ZNear,ZFar));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateOrtho(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Left,Right,Bottom,Top,ZNear,ZFar:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=6 then begin
  Left:=POCAGetNumberValue(aContext,aArguments^[0]);
  Right:=POCAGetNumberValue(aContext,aArguments^[1]);
  Bottom:=POCAGetNumberValue(aContext,aArguments^[2]);
  Top:=POCAGetNumberValue(aContext,aArguments^[3]);
  ZNear:=POCAGetNumberValue(aContext,aArguments^[4]);
  ZFar:=POCAGetNumberValue(aContext,aArguments^[5]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateOrtho(Left,Right,Bottom,Top,ZNear,ZFar));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewYX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewYX(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewZX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewZX(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewXY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewXY(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewZY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewZY(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewXZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewXZ(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAMatrix4x4FunctionCreateSkewYZ(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Angle:TpvDouble;
    Matrix:TpvMatrix4x4D;
begin
 if aCountArguments>=1 then begin
  Angle:=POCAGetNumberValue(aContext,aArguments^[0]);
  Matrix:=TpvMatrix4x4D.Create(TpvMatrix4x4.CreateSkewYZ(Angle));
  result:=POCANewMatrix4x4(aContext,Matrix);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitMatrix4x4Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.Matrix4x4Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Matrix4x4Hash);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'add',POCAMatrix4x4FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'sub',POCAMatrix4x4FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'clone',POCAMatrix4x4FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'copy',POCAMatrix4x4FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'mul',POCAMatrix4x4FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'div',POCAMatrix4x4FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'neg',POCAMatrix4x4FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'transpose',POCAMatrix4x4FunctionTranspose);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'determinant',POCAMatrix4x4FunctionDeterminant);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'inverse',POCAMatrix4x4FunctionInverse);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'adjugate',POCAMatrix4x4FunctionAdjugate);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'lerp',POCAMatrix4x4FunctionLerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'nlerp',POCAMatrix4x4FunctionNlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'slerp',POCAMatrix4x4FunctionSlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'elerp',POCAMatrix4x4FunctionElerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'sqlerp',POCAMatrix4x4FunctionSqlerp);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'equal',POCAMatrix4x4FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'notEqual',POCAMatrix4x4FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4Hash,'toString',POCAMatrix4x4FunctionToString);

 HostData^.Matrix4x4HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Matrix4x4HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__add',POCAMatrix4x4FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__sub',POCAMatrix4x4FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__mul',POCAMatrix4x4FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__div',POCAMatrix4x4FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__eq',POCAMatrix4x4FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__neq',POCAMatrix4x4FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__neg',POCAMatrix4x4FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__sqrt',POCAMatrix4x4FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Matrix4x4HashEvents,'__tostring',POCAMatrix4x4FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Matrix4x4Hash,HostData^.Matrix4x4HashEvents);

end;

procedure POCAInitMatrix4x4Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAMatrix4x4FunctionCREATE);
 POCAAddNativeFunction(aContext,Hash,'createRotateX',POCAMatrix4x4FunctionCreateRotateX);
 POCAAddNativeFunction(aContext,Hash,'createRotateY',POCAMatrix4x4FunctionCreateRotateY);
 POCAAddNativeFunction(aContext,Hash,'createRotateZ',POCAMatrix4x4FunctionCreateRotateZ);
 POCAAddNativeFunction(aContext,Hash,'createRotate',POCAMatrix4x4FunctionCreateRotate);
 POCAAddNativeFunction(aContext,Hash,'createRotation',POCAMatrix4x4FunctionCreateRotation);
 POCAAddNativeFunction(aContext,Hash,'createScale',POCAMatrix4x4FunctionCreateScale);
 POCAAddNativeFunction(aContext,Hash,'createTranslation',POCAMatrix4x4FunctionCreateTranslation);
 POCAAddNativeFunction(aContext,Hash,'createTranslated',POCAMatrix4x4FunctionCreateTranslated);
 POCAAddNativeFunction(aContext,Hash,'createFromQuaternion',POCAMatrix4x4FunctionCreateFromQuaternion);
 POCAAddNativeFunction(aContext,Hash,'createFromToRotation',POCAMatrix4x4FunctionCreateFromToRotation);
 POCAAddNativeFunction(aContext,Hash,'createLookAt',POCAMatrix4x4FunctionCreateLookAt);
 POCAAddNativeFunction(aContext,Hash,'createPerspective',POCAMatrix4x4FunctionCreatePerspective);
 POCAAddNativeFunction(aContext,Hash,'createOrtho',POCAMatrix4x4FunctionCreateOrtho);
 POCAAddNativeFunction(aContext,Hash,'createSkewYX',POCAMatrix4x4FunctionCreateSkewYX);
 POCAAddNativeFunction(aContext,Hash,'createSkewZX',POCAMatrix4x4FunctionCreateSkewZX);
 POCAAddNativeFunction(aContext,Hash,'createSkewXY',POCAMatrix4x4FunctionCreateSkewXY);
 POCAAddNativeFunction(aContext,Hash,'createSkewZY',POCAMatrix4x4FunctionCreateSkewZY);
 POCAAddNativeFunction(aContext,Hash,'createSkewXZ',POCAMatrix4x4FunctionCreateSkewXZ);
 POCAAddNativeFunction(aContext,Hash,'createSkewYZ',POCAMatrix4x4FunctionCreateSkewYZ);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Matrix4x4',Hash);
end;

procedure POCAInitMatrix4x4(aContext:PPOCAContext);
begin
 POCAInitMatrix4x4Hash(aContext);
 POCAInitMatrix4x4Namespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Sprite
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCASpriteGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Sprite'
       );

function POCANewSprite(const aContext:PPOCAContext;const aSprite:TpvSprite):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCASpriteGhost,aSprite,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.SpriteHash);
end;

function POCAGetSpriteValue(const aValue:TPOCAValue):TpvSprite;
begin
 if POCAGhostGetType(aValue)=@POCASpriteGhost then begin
  result:=TpvSprite(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCASpriteFunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
begin
 result.CastedUInt64:=POCAValueNullCastedUInt64; 
end;

procedure POCAInitSpriteHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=POCAGetHostData(aContext);
 HostData^.SpriteHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.SpriteHash);
end;

procedure POCAInitSpriteNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCASpriteFunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Sprite',Hash);
end;

procedure POCAInitSprite(aContext:PPOCAContext);
begin
 POCAInitSpriteHash(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SpriteAtlas
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCASpriteAtlasGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'SpriteAtlas'
       );

function POCANewSpriteAtlas(const aContext:PPOCAContext;const aSpriteAtlas:TpvSpriteAtlas):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCASpriteAtlasGhost,aSpriteAtlas,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.SpriteAtlasHash);
end;

function POCAGetSpriteAtlasValue(const aValue:TPOCAValue):TpvSpriteAtlas;
begin
 if POCAGhostGetType(aValue)=@POCASpriteAtlasGhost then begin
  result:=TpvSpriteAtlas(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCASpriteAtlasFunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
    sRGB:Boolean;
    Depth16Bit:Boolean;
    MipMaps:Boolean;
    UseConvexHullTrimming:Boolean;
begin
 if aCountArguments>0 then begin
  sRGB:=POCAGetBooleanValue(aContext,aArguments^[0]);
 end else begin
  sRGB:=true;  
 end;
 if aCountArguments>1 then begin
  Depth16Bit:=POCAGetBooleanValue(aContext,aArguments^[1]);
 end else begin
  Depth16Bit:=false;  
 end;
 if aCountArguments>2 then begin
  MipMaps:=POCAGetBooleanValue(aContext,aArguments^[2]);
 end else begin
  MipMaps:=true;  
 end;
 if aCountArguments>3 then begin
  UseConvexHullTrimming:=POCAGetBooleanValue(aContext,aArguments^[3]);
 end else begin
  UseConvexHullTrimming:=false;  
 end;
 SpriteAtlas:=TpvSpriteAtlas.Create(pvApplication.VulkanDevice,sRGB,Depth16Bit);
 SpriteAtlas.MipMaps:=MipMaps;
 SpriteAtlas.UseConvexHullTrimming:=UseConvexHullTrimming;
 result:=POCANewSpriteAtlas(aContext,SpriteAtlas);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.SpriteAtlasHash); 
end;

function POCASpriteAtlasFunctionDESTROY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
begin
 if POCAGhostGetType(aThis)=@POCASpriteAtlasGhost then begin
  SpriteAtlas:=TpvSpriteAtlas(POCAGhostFastGetPointer(aThis));
  if assigned(SpriteAtlas) then begin
   SpriteAtlas.Free;
   PPOCAGhost(POCAGetValueReferencePointer(aThis))^.Ptr:=nil; // For to avoid double free
  end;
 end;
 result.CastedUInt64:=POCAValueNullCastedUInt64;
end;

function POCASpriteAtlasFunctionLOAD(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
    Sprite:TpvSprite;
    Name,FileName:TpvUTF8String;
    AutomaticTrim:Boolean;
    Padding,TrimPadding:TpvInt32;
    Stream:TStream;
begin

 if POCAGhostGetType(aThis)<>@POCASpriteAtlasGhost then begin
  POCARuntimeError(aContext,'Invalid SpriteAtlas object');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end; 

 if aCountArguments>0 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>1 then begin
  FileName:=POCAGetStringValue(aContext,aArguments^[1]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>2 then begin
  AutomaticTrim:=POCAGetBooleanValue(aContext,aArguments^[2]);
 end else begin
  AutomaticTrim:=false;  
 end;

 if aCountArguments>3 then begin
  Padding:=trunc(POCAGetNumberValue(aContext,aArguments^[3]));
 end else begin
  Padding:=0;  
 end;

 if aCountArguments>4 then begin
  TrimPadding:=trunc(POCAGetNumberValue(aContext,aArguments^[4]));
 end else begin
  TrimPadding:=0;  
 end;

 SpriteAtlas:=TpvSpriteAtlas(POCAGhostFastGetPointer(aThis));
 if pvApplication.Assets.ExistAsset(String(FileName)) then begin
  Stream:=pvApplication.Assets.GetAssetStream(String(FileName));
  try
   Sprite:=SpriteAtlas.LoadSprite(String(Name),Stream,AutomaticTrim,Padding,TrimPadding);
   result:=POCANewSprite(aContext,Sprite);
  finally
   FreeAndNil(Stream);
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end; 

function POCASpriteAtlasFunctionLOADSIGNEDDISTANCEFIELDSPRITE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
    Sprite:TpvSprite;
    Name,SVGPath:TpvUTF8String;
    ImageWidth,ImageHeight:Integer;
    Scale,OffsetX,OffsetY:TpvDouble;
    VectorPathFillRule:TpvVectorPathFillRule;
    AutomaticTrim:Boolean;
    Padding,TrimPadding:TpvInt32;
    SDFVariant:TpvSignedDistanceField2DVariant;
    ProtectBorder:Boolean;
begin
 if POCAGhostGetType(aThis)<>@POCASpriteAtlasGhost then begin
  POCARuntimeError(aContext,'Invalid SpriteAtlas object');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end; 

 if aCountArguments>0 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>1 then begin
  SVGPath:=POCAGetStringValue(aContext,aArguments^[1]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>2 then begin
  ImageWidth:=trunc(POCAGetNumberValue(aContext,aArguments^[2]));
 end else begin
  ImageWidth:=64;
 end;

 if aCountArguments>3 then begin
  ImageHeight:=trunc(POCAGetNumberValue(aContext,aArguments^[3]));
 end else begin
  ImageHeight:=64;
 end;

 if aCountArguments>4 then begin
  AutomaticTrim:=POCAGetBooleanValue(aContext,aArguments^[4]);
 end else begin
  AutomaticTrim:=true;  
 end;

 if aCountArguments>5 then begin
  Padding:=trunc(POCAGetNumberValue(aContext,aArguments^[5]));
 end else begin
  Padding:=2;  
 end;

 if aCountArguments>6 then begin
  TrimPadding:=trunc(POCAGetNumberValue(aContext,aArguments^[6]));
 end else begin
  TrimPadding:=0;  
 end;

 if aCountArguments>7 then begin
  Scale:=POCAGetNumberValue(aContext,aArguments^[7]);
 end else begin
  Scale:=1.0;  
 end;

 if aCountArguments>8 then begin
  OffsetX:=POCAGetNumberValue(aContext,aArguments^[8]);
 end else begin
  OffsetX:=0.0;  
 end;

 if aCountArguments>9 then begin
  OffsetY:=POCAGetNumberValue(aContext,aArguments^[9]);
 end else begin
  OffsetY:=0.0;  
 end;

 if aCountArguments>10 then begin
  VectorPathFillRule:=TpvVectorPathFillRule(TPOCAInt32(trunc(POCAGetNumberValue(aContext,aArguments^[10]))));
 end else begin
  VectorPathFillRule:=TpvVectorPathFillRule.NonZero;  
 end;

 if aCountArguments>11 then begin
  SDFVariant:=TpvSignedDistanceField2DVariant(TPOCAInt32(trunc(POCAGetNumberValue(aContext,aArguments^[11]))));
 end else begin
  SDFVariant:=TpvSignedDistanceField2DVariant.Default;  
 end;

 if aCountArguments>12 then begin
  ProtectBorder:=POCAGetBooleanValue(aContext,aArguments^[12]);
 end else begin
  ProtectBorder:=false;  
 end; 

 SpriteAtlas:=TpvSpriteAtlas(POCAGhostFastGetPointer(aThis));

 Sprite:=SpriteAtlas.LoadSignedDistanceFieldSprite(Name,
                                                   SVGPath,
                                                   ImageWidth,
                                                   ImageHeight,
                                                   Scale,
                                                   OffsetX,
                                                   OffsetY,
                                                   VectorPathFillRule,
                                                   AutomaticTrim,
                                                   Padding,
                                                   TrimPadding,
                                                   SDFVariant,
                                                   ProtectBorder);
 result:=POCANewSprite(aContext,Sprite);

end;

function POCASpriteAtlasFunctionGET(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
    Sprite:TpvSprite;
    Name:TpvUTF8String;
begin
 if POCAGhostGetType(aThis)<>@POCASpriteAtlasGhost then begin
  POCARuntimeError(aContext,'Invalid SpriteAtlas object');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end; 

 if aCountArguments>0 then begin
  Name:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 SpriteAtlas:=TpvSpriteAtlas(POCAGhostFastGetPointer(aThis));
 Sprite:=SpriteAtlas.Sprites[Name];
 if assigned(Sprite) then begin
  result:=POCANewSprite(aContext,Sprite);
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end;

function POCASpriteAtlasFunctionUPLOAD(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var SpriteAtlas:TpvSpriteAtlas;
    HostData:PPOCAHostData;
begin

 if POCAGhostGetType(aThis)<>@POCASpriteAtlasGhost then begin
  POCARuntimeError(aContext,'Invalid SpriteAtlas object');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end; 

 HostData:=POCAGetHostData(aContext);

 SpriteAtlas:=TpvSpriteAtlas(POCAGhostFastGetPointer(aThis));
 if not SpriteAtlas.Uploaded then begin
  SpriteAtlas.Upload(HostData^.GraphicsQueue,
                     HostData^.GraphicsCommandBuffer,
                     HostData^.GraphicsCommandBufferFence,
                     HostData^.TransferQueue,
                     HostData^.TransferCommandBuffer,
                     HostData^.TransferCommandBufferFence);
 end;
 
 result:=aThis;

end;

procedure POCAInitSpriteAtlasHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=POCAGetHostData(aContext);
 HostData^.SpriteAtlasHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.SpriteAtlasHash);
 POCAAddNativeFunction(aContext,HostData^.SpriteAtlasHash,'destroy',POCASpriteAtlasFunctionDESTROY); 
 POCAAddNativeFunction(aContext,HostData^.SpriteAtlasHash,'load',POCASpriteAtlasFunctionLOAD);
 POCAAddNativeFunction(aContext,HostData^.SpriteAtlasHash,'loadSignedDistanceFieldSprite',POCASpriteAtlasFunctionLOADSIGNEDDISTANCEFIELDSPRITE);
 POCAAddNativeFunction(aContext,HostData^.SpriteAtlasHash,'get',POCASpriteAtlasFunctionGET);
 POCAAddNativeFunction(aContext,HostData^.SpriteAtlasHash,'upload',POCASpriteAtlasFunctionUPLOAD);
end;

procedure POCAInitSpriteAtlasNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCASpriteAtlasFunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'SpriteAtlas',Hash);
end;

procedure POCAInitSpriteAtlas(aContext:PPOCAContext);
begin
 POCAInitSpriteAtlasHash(aContext);
 POCAInitSpriteAtlasNamespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Texture
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCATextureGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Texture'
       );

function POCANewTexture(const aContext:PPOCAContext;const aTexture:TpvVulkanTexture):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCATextureGhost,aTexture,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.TextureHash);
end;

function POCAGetTextureValue(const aValue:TPOCAValue):TpvVulkanTexture;
begin
 if POCAGhostGetType(aValue)=@POCATextureGhost then begin
  result:=TpvVulkanTexture(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCATextureFunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Texture:TpvVulkanTexture;
    FileName:TpvUTF8String;
    MipMaps,sRGB,AdditionalSRGB:Boolean;
    Stream:TStream;
    HostData:PPOCAHostData;
    Queue:TpvVulkanQueue;
    CommandBufferPool:TpvVulkanCommandPool;
    CommandBuffer:TpvVulkanCommandBuffer;
    Fence:TpvVulkanFence;
begin

 if aCountArguments>0 then begin
  FileName:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>1 then begin
  FileName:=POCAGetStringValue(aContext,aArguments^[1]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>2 then begin
  MipMaps:=POCAGetBooleanValue(aContext,aArguments^[2]);
 end else begin
  MipMaps:=true;  
 end;

 if aCountArguments>3 then begin
  sRGB:=POCAGetBooleanValue(aContext,aArguments^[3]);
 end else begin
  sRGB:=true;  
 end;

 if aCountArguments>4 then begin
  AdditionalSRGB:=POCAGetBooleanValue(aContext,aArguments^[4]);
 end else begin
  AdditionalSRGB:=false;  
 end;

 if pvApplication.Assets.ExistAsset(String(FileName)) then begin
  Stream:=pvApplication.Assets.GetAssetStream(String(FileName));
  try
   HostData:=POCAGetHostData(aContext);
   Queue:=pvApplication.VulkanDevice.UniversalQueue;
   CommandBufferPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,pvApplication.VulkanDevice.UniversalQueueFamilyIndex,TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
   try
    CommandBuffer:=TpvVulkanCommandBuffer.Create(CommandBufferPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
    try
     Fence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);
     try
      Texture:=TpvVulkanTexture.CreateFromImage(pvApplication.VulkanDevice,
                                                Queue,
                                                CommandBuffer,
                                                Fence,
                                                Queue,
                                                CommandBuffer,
                                                Fence,
                                                Stream,
                                                MipMaps,
                                                sRGB,
                                                AdditionalSRGB);
      result:=POCANewTexture(aContext,Texture);
     finally
      FreeAndNil(Fence);
     end;
    finally
     FreeAndNil(CommandBuffer);
    end;
   finally
    FreeAndNil(CommandBufferPool);
   end;
  finally  
   FreeAndNil(Stream);
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end;

function POCATextureFunctionDESTROY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Texture:TpvVulkanTexture;
begin
 if POCAGhostGetType(aThis)=@POCATextureGhost then begin
  Texture:=TpvVulkanTexture(POCAGhostFastGetPointer(aThis));
  if assigned(Texture) then begin
   Texture.Free;
   PPOCAGhost(POCAGetValueReferencePointer(aThis))^.Ptr:=nil; // For to avoid double free
  end;
 end;
 result.CastedUInt64:=POCAValueNullCastedUInt64;
end;

procedure POCAInitTextureHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=POCAGetHostData(aContext);
 HostData^.TextureHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.TextureHash);
 POCAAddNativeFunction(aContext,HostData^.TextureHash,'destroy',POCATextureFunctionDESTROY); 
end;

procedure POCAInitTextureNamespace(aContext:PPOCAContext);
var HostData:PPOCAHostData;
    Hash:TPOCAValue;
begin
 HostData:=POCAGetHostData(aContext);
 Hash:=POCANewHash(aContext);
 HostData^.TextureNameSpace:=Hash;
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCATextureFunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Texture',Hash);
end;

procedure POCAInitTexture(aContext:PPOCAContext);
begin
 POCAInitTextureHash(aContext);
 POCAInitTextureNamespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Font
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCAFontGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Font'
       );

function POCANewFont(const aContext:PPOCAContext;const aFont:TpvFont):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCAFontGhost,aFont,nil,pgptRAW);
 POCATemporarySave(aContext,result);
//POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.FontHash);
end;

function POCAGetFontValue(const aValue:TPOCAValue):TpvFont;
begin
 if POCAGhostGetType(aValue)=@POCAFontGhost then begin
  result:=TpvFont(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

procedure POCAInitFont(aContext:PPOCAContext);
begin
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CanvasFont
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCACanvasFontGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'CanvasFont'
       );

function POCANewCanvasFont(const aContext:PPOCAContext;const aCanvasFont:TpvCanvasFont):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCACanvasFontGhost,aCanvasFont,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.CanvasFontHash);
end;

function POCAGetCanvasFontValue(const aValue:TPOCAValue):TpvCanvasFont;
begin
 if POCAGhostGetType(aValue)=@POCACanvasFontGhost then begin
  result:=TpvCanvasFont(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCACanvasFontFunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var CanvasFont:TpvCanvasFont;
    FileName:TpvUTF8String;
    DPI,AtlasSize:TpvInt32;
    FirstCodePoint,LastCodePoint:TpvUInt32;
begin

 if aCountArguments>0 then begin
  FileName:=POCAGetStringValue(aContext,aArguments^[0]);
 end else begin
  POCARuntimeError(aContext,'Invalid arguments');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if aCountArguments>1 then begin
  DPI:=trunc(POCAGetNumberValue(aContext,aArguments^[1]));
 end else begin
  DPI:=72;  
 end;

 if aCountArguments>2 then begin
  AtlasSize:=trunc(POCAGetNumberValue(aContext,aArguments^[2]));
 end else begin
  AtlasSize:=2048;  
 end;

 if aCountArguments>3 then begin
  FirstCodePoint:=trunc(POCAGetNumberValue(aContext,aArguments^[3]));
 end else begin
  FirstCodePoint:=0;  
 end;

 if aCountArguments>4 then begin
  LastCodePoint:=trunc(POCAGetNumberValue(aContext,aArguments^[4]));
 end else begin
  LastCodePoint:=255;  
 end;

 CanvasFont:=TpvCanvasFont.CreateFromTTF(FileName,DPI,AtlasSize,FirstCodePoint,LastCodePoint);

 result:=POCANewCanvasFont(aContext,CanvasFont);

end;

function POCACanvasFontFunctionDESTROY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var CanvasFont:TpvCanvasFont;
begin
 if POCAGhostGetType(aThis)=@POCACanvasFontGhost then begin
  CanvasFont:=TpvCanvasFont(POCAGhostFastGetPointer(aThis));
  if assigned(CanvasFont) then begin
   CanvasFont.Free;
   PPOCAGhost(POCAGetValueReferencePointer(aThis))^.Ptr:=nil; // For to avoid double free
  end;
 end;
 result.CastedUInt64:=POCAValueNullCastedUInt64;
end;

procedure POCAInitCanvasFontHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=POCAGetHostData(aContext);
 HostData^.CanvasFontHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.CanvasFontHash);
 POCAAddNativeFunction(aContext,HostData^.CanvasFontHash,'destroy',POCACanvasFontFunctionDESTROY); 
end;

procedure POCAInitCanvasFontNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCACanvasFontFunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'CanvasFont',Hash);
end;

procedure POCAInitCanvasFont(aContext:PPOCAContext);
begin
 POCAInitCanvasFontHash(aContext);
 POCAInitCanvasFontNamespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CanvasShape
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCACanvasShapeGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'CanvasShape'
       );

function POCANewCanvasShape(const aContext:PPOCAContext;const aCanvasShape:TpvCanvasShape):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCACanvasShapeGhost,aCanvasShape,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.CanvasShapeHash);
end;

function POCAGetCanvasShapeValue(const aValue:TPOCAValue):TpvCanvasShape;
begin
 if POCAGhostGetType(aValue)=@POCACanvasShapeGhost then begin
  result:=TpvCanvasShape(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCACanvasShapeFunctionDESTROY(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var CanvasShape:TpvCanvasShape;
begin
 if POCAGhostGetType(aThis)=@POCACanvasShapeGhost then begin
  CanvasShape:=TpvCanvasShape(POCAGhostFastGetPointer(aThis));
  if assigned(CanvasShape) then begin
   CanvasShape.Free;
   PPOCAGhost(POCAGetValueReferencePointer(aThis))^.Ptr:=nil; // For to avoid double free
  end;
 end;
 result.CastedUInt64:=POCAValueNullCastedUInt64;
end;

procedure POCAInitCanvasShapeHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=POCAGetHostData(aContext);
 HostData^.CanvasShapeHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.CanvasShapeHash);
end;

procedure POCAInitCanvasShape(aContext:PPOCAContext);
begin
 POCAInitCanvasShapeHash(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Canvas
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCACanvasGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Canvas'
       );

function POCANewCanvas(const aContext:PPOCAContext;const aCanvas:TpvCanvas):TPOCAValue;
begin
 result:=POCANewGhost(aContext,@POCACanvasGhost,aCanvas,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.CanvasHash);
end;

function POCAGetCanvasValue(const aValue:TPOCAValue):TpvCanvas;
begin
 if POCAGhostGetType(aValue)=@POCACanvasGhost then begin
  result:=TpvCanvas(POCAGhostFastGetPointer(aValue));
 end else begin
  result:=nil;
 end;
end;

function POCAInitCanvasBlendMode(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'None',POCANewNumber(aContext,TPOCAInt32(TpvCanvasBlendingMode.None)));
 POCAHashSetString(aContext,result,'NoDiscard',POCANewNumber(aContext,TPOCAInt32(TpvCanvasBlendingMode.NoDiscard)));
 POCAHashSetString(aContext,result,'AlphaBlending',POCANewNumber(aContext,TPOCAInt32(TpvCanvasBlendingMode.AlphaBlending)));
 POCAHashSetString(aContext,result,'AdditiveBlending',POCANewNumber(aContext,TPOCAInt32(TpvCanvasBlendingMode.AdditiveBlending)));
 POCAHashSetString(aContext,result,'OnlyDepth',POCANewNumber(aContext,TPOCAInt32(TpvCanvasBlendingMode.OnlyDepth)));
end;

function POCAInitCanvasLineJoin(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'Bevel',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineJoin.Bevel)));
 POCAHashSetString(aContext,result,'Miter',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineJoin.Miter)));
 POCAHashSetString(aContext,result,'Round',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineJoin.Round)));
end;

function POCAInitCanvasLineCap(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'Butt',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineCap.Butt)));
 POCAHashSetString(aContext,result,'Square',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineCap.Square)));
 POCAHashSetString(aContext,result,'Round',POCANewNumber(aContext,TPOCAInt32(TpvCanvasLineCap.Round)));
end;

function POCAInitCanvasFillRule(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'DoNotMatter',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillRule.DoNotMatter)));
 POCAHashSetString(aContext,result,'NonZero',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillRule.NonZero)));
 POCAHashSetString(aContext,result,'EvenOdd',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillRule.EvenOdd)));
end;

function POCAInitCanvasFillStyle(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'Color',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillStyle.Color)));
 POCAHashSetString(aContext,result,'Image',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillStyle.Image)));
 POCAHashSetString(aContext,result,'LinearGradient',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillStyle.LinearGradient)));
 POCAHashSetString(aContext,result,'RadialGradient',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillStyle.RadialGradient)));
end;

function POCAInitCanvasFillWrapMode(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'None',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillWrapMode.None)));
 POCAHashSetString(aContext,result,'WrappedRepeat',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillWrapMode.WrappedRepeat)));
 POCAHashSetString(aContext,result,'MirroredRepeat',POCANewNumber(aContext,TPOCAInt32(TpvCanvasFillWrapMode.MirroredRepeat)));
end;

function POCAInitCanvasTextHorizontalAlignment(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'Leading',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextHorizontalAlignment.Leading)));
 POCAHashSetString(aContext,result,'Center',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextHorizontalAlignment.Center)));
 POCAHashSetString(aContext,result,'Tailing',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextHorizontalAlignment.Tailing)));
end;

function POCAInitCanvasTextVerticalAlignment(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'Leading',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextVerticalAlignment.Leading)));
 POCAHashSetString(aContext,result,'Middle',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextVerticalAlignment.Middle)));
 POCAHashSetString(aContext,result,'Tailing',POCANewNumber(aContext,TPOCAInt32(TpvCanvasTextVerticalAlignment.Tailing)));
end;

function POCAInitCanvasVectorPathFillRule(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'NonZero',POCANewNumber(aContext,TPOCAInt32(TpvVectorPathFillRule.NonZero)));
 POCAHashSetString(aContext,result,'EvenOdd',POCANewNumber(aContext,TPOCAInt32(TpvVectorPathFillRule.EvenOdd)));
end;

function POCAInitCanvasSignedDistanceField2DVariant(aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'SDF',POCANewNumber(aContext,TPOCAInt32(TpvSignedDistanceField2DVariant.SDF)));
 POCAHashSetString(aContext,result,'SSAASDF',POCANewNumber(aContext,TPOCAInt32(TpvSignedDistanceField2DVariant.SSAASDF)));
 POCAHashSetString(aContext,result,'GSDF',POCANewNumber(aContext,TPOCAInt32(TpvSignedDistanceField2DVariant.GSDF)));
 POCAHashSetString(aContext,result,'MSDF',POCANewNumber(aContext,TPOCAInt32(TpvSignedDistanceField2DVariant.MSDF)));
 POCAHashSetString(aContext,result,'Default',POCANewNumber(aContext,TPOCAInt32(TpvSignedDistanceField2DVariant.Default)));
end;

function POCACanvasFunctionGETWIDTH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 result.Num:=Canvas.Width;

end;

function POCACanvasFunctionGETHEIGHT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 result.Num:=Canvas.Height;

end;

function POCACanvasFunctionCLEAR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Color:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=POCAVector4GhostPointer) then begin
  Color:=POCAGetVector4Value(aArguments^[0]); 
 end else begin
  if aCountArguments>0 then begin
   Color.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Color.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Color.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Color.y:=0.0;
  end;
  if aCountArguments>2 then begin
   Color.z:=POCAGetNumberValue(aContext,aArguments^[2]);
  end else begin
   Color.z:=0.0;
  end;
  if aCountArguments>3 then begin
   Color.w:=POCAGetNumberValue(aContext,aArguments^[3]);
  end else begin
   Color.w:=1.0; 
  end; 
 end;

 Canvas.Color:=Color;
 Canvas.DrawFilledRectangle(TpvRect.CreateAbsolute(0,0,Canvas.Width,Canvas.Height));

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDCIRCLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Radius:TpvFloat;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Centter
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;
 
 Canvas.DrawFilledCircle(Center,Radius);

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDELLIPSE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Radius:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Radius
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Radius:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Radius.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Radius.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Radius.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Radius.y:=0.0;
  end;
 end;

 Canvas.DrawFilledEllipse(Center,Radius);

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDRECTANGLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 Canvas.DrawFilledRectangle(TpvRect.CreateRelative(LeftTop,WidthHeight));

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDRECTANGLECENTER(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Bounds:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Bounds
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Bounds:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Bounds.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Bounds.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.y:=0.0;
  end;
 end;

 Canvas.DrawFilledRectangle(Center,Bounds);

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDROUNDEDRECTANGLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
    Radius:TpvFloat;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 Canvas.DrawFilledRoundedRectangle(TpvRect.CreateRelative(LeftTop,WidthHeight),Radius);

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDROUNDEDRECTANGLECENTER(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Bounds:TpvVector2;
    Radius:TpvFloat;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Bounds
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Bounds:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Bounds.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Bounds.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 Canvas.DrawFilledRoundedRectangle(Center,Bounds,Radius);

 result:=aThis;

end;

function POCACanvasFunctionDRAWFILLEDCIRCLEARCRINGSEGMENT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    InnerRadius:TpvFloat;
    OuterRadius:TpvFloat;
    StartAngle:TpvFloat;
    EndAngle:TpvFloat;
    GapThickness:TpvFloat;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for InnerRadius
 if ArgumentIndex<aCountArguments then begin
  InnerRadius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  InnerRadius:=0.0;
 end;

 // Check for OuterRadius
 if ArgumentIndex<aCountArguments then begin
  OuterRadius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  OuterRadius:=0.0;
 end;

 // Check for StartAngle
 if ArgumentIndex<aCountArguments then begin
  StartAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  StartAngle:=0.0;
 end;

 // Check for EndAngle
 if ArgumentIndex<aCountArguments then begin
  EndAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  EndAngle:=0.0;
 end;

 // Check for GapThickness
 if ArgumentIndex<aCountArguments then begin
  GapThickness:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  GapThickness:=0.0;
 end;

 Canvas.DrawFilledCircleArcRingSegment(Center,InnerRadius,OuterRadius,StartAngle,EndAngle,GapThickness);

 result:=aThis;

end;

function POCACanvasFunctionDRAWTEXTUREDRECTANGLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Texture:TpvVulkanTexture;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
    RotationAngle:TpvFloat;
    TextureArrayLayer:TpvInt32;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Texture
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCATextureGhostPointer) then begin
  Texture:=TpvVulkanTexture(POCAGhostFastGetPointer(aArguments^[0]));
  inc(ArgumentIndex);
 end else begin
  Texture:=nil;
 end;

 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 // Check for RotationAngle
 if ArgumentIndex<aCountArguments then begin
  RotationAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  RotationAngle:=0.0;
 end;

 // Check for TextureArrayLayer
 if ArgumentIndex<aCountArguments then begin
  TextureArrayLayer:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  TextureArrayLayer:=0;
 end;

 Canvas.DrawTexturedRectangle(Texture,TpvRect.CreateRelative(LeftTop,WidthHeight),RotationAngle,TextureArrayLayer);

 result:=aThis;

end;

function POCACanvasFunctionDRAWTEXTUREDRECTANGLECENTER(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Texture:TpvVulkanTexture;
    Center:TpvVector2;
    Bounds:TpvVector2;
    RotationAngle:TpvFloat;
    TextureArrayLayer:TpvInt32;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Texture
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCATextureGhostPointer) then begin
  Texture:=TpvVulkanTexture(POCAGhostFastGetPointer(aArguments^[0]));
  inc(ArgumentIndex);
 end else begin
  Texture:=nil;
 end;

 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Bounds
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Bounds:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Bounds.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Bounds.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.y:=0.0;
  end;
 end;

 // Check for RotationAngle
 if ArgumentIndex<aCountArguments then begin
  RotationAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  RotationAngle:=0.0;
 end;

 // Check for TextureArrayLayer
 if ArgumentIndex<aCountArguments then begin
  TextureArrayLayer:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  TextureArrayLayer:=0;
 end;

 Canvas.DrawTexturedRectangle(Texture,Center,Bounds,RotationAngle,TextureArrayLayer);

 result:=aThis;

end;

function POCACanvasFunctionDRAWSPRITE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Sprite:TpvSprite;
    SrcLeftTop:TpvVector2;
    SrcWidthHeight:TpvVector2;
    DestLeftTop:TpvVector2;
    DestWidthHeight:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Sprite
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCASpriteGhostPointer) then begin
  Sprite:=TpvSprite(POCAGhostFastGetPointer(aArguments^[0]));
  inc(ArgumentIndex);
 end else begin
  Sprite:=nil;
 end;

 // Check for SrcLeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  SrcLeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   SrcLeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcLeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   SrcLeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcLeftTop.y:=0.0;
  end;
 end;

 // Check for SrcWidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  SrcWidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   SrcWidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcWidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   SrcWidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcWidthHeight.y:=0.0;
  end;
 end;

 // Check for DestLeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  DestLeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   DestLeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestLeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   DestLeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestLeftTop.y:=0.0;
  end;
 end;

 // Check for DestWidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  DestWidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   DestWidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestWidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   DestWidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestWidthHeight.y:=0.0;
  end;
 end;

 Canvas.DrawSprite(Sprite,TpvRect.CreateRelative(SrcLeftTop,SrcWidthHeight),TpvRect.CreateRelative(DestLeftTop,DestWidthHeight));

 result:=aThis;

end;

function POCACanvasFunctionDRAWSPRITEORIGINROTATION(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Sprite:TpvSprite;
    SrcLeftTop:TpvVector2;
    SrcWidthHeight:TpvVector2;
    DestLeftTop:TpvVector2;
    DestWidthHeight:TpvVector2;
    Origin:TpvVector2;
    RotationAngle:TpvFloat;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Sprite
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCASpriteGhostPointer) then begin
  Sprite:=TpvSprite(POCAGhostFastGetPointer(aArguments^[0]));
  inc(ArgumentIndex);
 end else begin
  Sprite:=nil;
 end;

 // Check for SrcLeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  SrcLeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   SrcLeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcLeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   SrcLeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcLeftTop.y:=0.0;
  end;
 end;

 // Check for SrcWidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  SrcWidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   SrcWidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcWidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   SrcWidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   SrcWidthHeight.y:=0.0;
  end;
 end;

 // Check for DestLeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  DestLeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   DestLeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestLeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   DestLeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestLeftTop.y:=0.0;
  end;
 end;

 // Check for DestWidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  DestWidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   DestWidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestWidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   DestWidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   DestWidthHeight.y:=0.0;
  end;
 end;

 // Check for Origin
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Origin:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Origin.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Origin.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Origin.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Origin.y:=0.0;
  end;
 end;

 // Check for RotationAngle
 if ArgumentIndex<aCountArguments then begin
  RotationAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  RotationAngle:=0.0;
 end;

 Canvas.DrawSprite(Sprite,TpvRect.CreateRelative(SrcLeftTop,SrcWidthHeight),TpvRect.CreateRelative(DestLeftTop,DestWidthHeight),Origin,RotationAngle);

 result:=aThis;

end;

function POCACanvasFunctionDRAWSPRITEPOSITION(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Sprite:TpvSprite;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Sprite
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCASpriteGhostPointer) then begin
  Sprite:=TpvSprite(POCAGhostFastGetPointer(aArguments^[0]));
  inc(ArgumentIndex);
 end else begin
  Sprite:=nil;
 end;

 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.DrawSprite(Sprite,Position);

 result:=aThis;

end;

function POCACanvasFunctionDRAWTEXT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Text:TpvUTF8String;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Text
 if ArgumentIndex<aCountArguments then begin
  Text:=POCAGetStringValue(aContext,aArguments^[0]);
  inc(ArgumentIndex);
 end else begin
  Text:='';
 end;

 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.DrawText(Text,Position);

 result:=aThis;

end;

function POCACanvasFunctionDRAWTEXTCODEPOINT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    TextCodePoint:TpvUInt32;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for TextCodePoint
 if ArgumentIndex<aCountArguments then begin
  TextCodePoint:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  TextCodePoint:=0;
 end;

 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.DrawTextCodePoint(TextCodePoint,Position);

 result:=aThis;

end;

function POCACanvasFunctionTEXTWIDTH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Text:TpvUTF8String;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Text
 if ArgumentIndex<aCountArguments then begin
  Text:=POCAGetStringValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Text:='';
 end;

 result.Num:=Canvas.TextWidth(Text);

end;

function POCACanvasFunctionTEXTHEIGHT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Text:TpvUTF8String;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Text
 if ArgumentIndex<aCountArguments then begin
  Text:=POCAGetStringValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Text:='';
 end;

 result.Num:=Canvas.TextHeight(Text);

end;

function POCACanvasFunctionTEXTSIZE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Text:TpvUTF8String;
    WidthHeight:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Text
 if ArgumentIndex<aCountArguments then begin
  Text:=POCAGetStringValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Text:='';
 end;

 WidthHeight:=Canvas.TextSize(Text);

 result:=POCANewVector2(aContext,WidthHeight);

end;

function POCACanvasFunctionTEXTROWHEIGHT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Percent:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Percent
 if ArgumentIndex<aCountArguments then begin
  Percent:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Percent:=0.0;
 end;

 result.Num:=Canvas.TextRowHeight(Percent);

end;

function POCACanvasFunctionBEGINPATH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.BeginPath;

 result:=aThis;

end;

function POCACanvasFunctionMOVETO(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.MoveTo(Position);

 result:=aThis;

end;

function POCACanvasFunctionLINETO(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.LineTo(Position);

 result:=aThis;

end;

function POCACanvasFunctionQUADRATICCURVETO(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ControlPoint:TpvVector2;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ControlPoint
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  ControlPoint:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   ControlPoint.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   ControlPoint.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint.y:=0.0;
  end;
 end;

 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.QuadraticCurveTo(ControlPoint,Position);

 result:=aThis;

end;

function POCACanvasFunctionCUBICCURVETO(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ControlPoint1:TpvVector2;
    ControlPoint2:TpvVector2;
    Position:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ControlPoint1
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  ControlPoint1:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   ControlPoint1.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint1.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   ControlPoint1.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint1.y:=0.0;
  end;
 end;

 // Check for ControlPoint2
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  ControlPoint2:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   ControlPoint2.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint2.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   ControlPoint2.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   ControlPoint2.y:=0.0;
  end;
 end;

 // Check for Position
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position.y:=0.0;
  end;
 end;

 Canvas.CubicCurveTo(ControlPoint1,ControlPoint2,Position);

 result:=aThis;

end;

function POCACanvasFunctionARC(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Radius:TpvDouble;
    StartAngle:TpvDouble;
    EndAngle:TpvDouble;
    Clockwise:Boolean;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 // Check for StartAngle
 if ArgumentIndex<aCountArguments then begin
  StartAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  StartAngle:=0.0;
 end;

 // Check for EndAngle
 if ArgumentIndex<aCountArguments then begin
  EndAngle:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  EndAngle:=0.0;
 end;

 // Check for Clockwise
 if ArgumentIndex<aCountArguments then begin
  Clockwise:=(POCAGetBooleanValue(aContext,aArguments^[ArgumentIndex]));
 end else begin
  Clockwise:=false;
 end;

 Canvas.Arc(Center,Radius,StartAngle,EndAngle,Clockwise);

 result:=aThis;

end;

function POCACanvasFunctionARCTO(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Position1:TpvVector2;
    Position2:TpvVector2;
    Radius:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Position1
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position1:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position1.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position1.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position1.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position1.y:=0.0;
  end;
 end;

 // Check for Position2
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Position2:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Position2.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position2.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Position2.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Position2.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0;
 end;

 Canvas.ArcTo(Position1,Position2,Radius);

 result:=aThis;

end;

function POCACanvasFunctionELLIPSE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Radius:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Radius
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Radius:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Radius.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Radius.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Radius.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Radius.y:=0.0;
  end;
 end;

 Canvas.Ellipse(Center,Radius);

 result:=aThis;

end;

function POCACanvasFunctionCIRCLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Radius:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 Canvas.Circle(Center,Radius);

 result:=aThis;

end;

function POCACanvasFunctionRECTANGLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 Canvas.Rectangle(TpvRect.CreateRelative(LeftTop,WidthHeight));

 result:=aThis;

end;

function POCACanvasFunctionRECTANGLECENTER(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Bounds:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Bounds
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Bounds:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Bounds.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Bounds.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.y:=0.0;
  end;
 end;

 Canvas.Rectangle(Center,Bounds);

 result:=aThis;

end;

function POCACanvasFunctionROUNDEDRECTANGLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
    Radius:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 Canvas.RoundedRectangle(TpvRect.CreateRelative(LeftTop,WidthHeight),Radius);

 result:=aThis;

end;

function POCACanvasFunctionROUNDEDRECTANGLECENTER(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Center:TpvVector2;
    Bounds:TpvVector2;
    Radius:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Center
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Center:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Center.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Center.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Center.y:=0.0;
  end;
 end;

 // Check for Bounds
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  Bounds:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Bounds.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Bounds.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Bounds.y:=0.0;
  end;
 end;

 // Check for Radius
 if ArgumentIndex<aCountArguments then begin
  Radius:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  Radius:=0.0;
 end;

 Canvas.RoundedRectangle(Center,Bounds,Radius);

 result:=aThis;

end;

function POCACanvasFunctionCLOSEPATH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.ClosePath;

 result:=aThis;

end;

function POCACanvasFunctionENDPATH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.EndPath;

 result:=aThis;

end;

function POCACanvasFunctionSTROKE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.Stroke;

 result:=aThis;

end;

function POCACanvasFunctionFILL(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.Fill;

 result:=aThis;

end;

function POCACanvasFunctionPUSH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.Push;

 result:=aThis;

end;

function POCACanvasFunctionPOP(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.Pop;

 result:=aThis;

end;

function POCACanvasFunctionFLUSH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas.Flush;

 result:=aThis;

end;

function POCACanvasFunctionGETCLIPRECT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
begin    

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;
 
 LeftTop:=Canvas.ClipRect.LeftTop;
 WidthHeight:=Canvas.ClipRect.RightBottom-LeftTop;
 
 result:=POCANewHash(aContext);
 POCAHashSetString(aContext,result,'leftTop',POCANewVector2(aContext,LeftTop));
 POCAHashSetString(aContext,result,'widthHeight',POCANewVector2(aContext,WidthHeight));
  
end;

function POCACanvasFunctionSETCLIPRECT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LeftTop:TpvVector2;
    WidthHeight:TpvVector2;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LeftTop
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  LeftTop:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   LeftTop.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   LeftTop.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   LeftTop.y:=0.0;
  end;
 end;

 // Check for WidthHeight
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector2GhostPointer) then begin
  WidthHeight:=POCAGetVector2Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   WidthHeight.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   WidthHeight.y:=0.0;
  end;
 end;

 Canvas.ClipRect:=TpvRect.CreateRelative(LeftTop,WidthHeight);

 result:=aThis;

end;

function POCACanvasFunctionSETSCISSOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Left,Top,Width,Height:TpvInt32;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Left
 if ArgumentIndex<aCountArguments then begin
  Left:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Left:=0;
 end;

 // Check for Top
 if ArgumentIndex<aCountArguments then begin
  Top:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Top:=0;
 end;

 // Check for Width
 if ArgumentIndex<aCountArguments then begin
  Width:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Width:=0;
 end;

 // Check for Height
 if ArgumentIndex<aCountArguments then begin
  Height:=trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Height:=0;
 end;

 Canvas.SetScissor(Left,Top,Width,Height);

 result:=aThis;

end;

function POCACanvasFunctionGETBLENDINGMODE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    BlendingMode:TpvCanvasBlendingMode;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 BlendingMode:=Canvas.BlendingMode;

 result.Num:=TpvInt32(BlendingMode);

end;

function POCACanvasFunctionSETBLENDINGMODE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    BlendingMode:TpvCanvasBlendingMode;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for BlendingMode
 if ArgumentIndex<aCountArguments then begin
  BlendingMode:=TpvCanvasBlendingMode(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  BlendingMode:=TpvCanvasBlendingMode.None;
 end;

 Canvas.BlendingMode:=BlendingMode;

 result:=aThis;

end;

function POCACanvasFunctionGETLINECAP(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    LineCap:TpvCanvasLineCap;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 LineCap:=Canvas.LineCap;

 result.Num:=TpvInt32(LineCap);

end;

function POCACanvasFunctionSETLINECAP(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LineCap:TpvCanvasLineCap;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LineCap
 if ArgumentIndex<aCountArguments then begin
  LineCap:=TpvCanvasLineCap(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  LineCap:=TpvCanvasLineCap.Butt;
 end;

 Canvas.LineCap:=LineCap;

 result:=aThis;

end;

function POCACanvasFunctionGETLINEJOIN(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    LineJoin:TpvCanvasLineJoin;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 LineJoin:=Canvas.LineJoin;

 result.Num:=TpvInt32(LineJoin);

end;

function POCACanvasFunctionSETLINEJOIN(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LineJoin:TpvCanvasLineJoin;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LineJoin
 if ArgumentIndex<aCountArguments then begin
  LineJoin:=TpvCanvasLineJoin(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  LineJoin:=TpvCanvasLineJoin.Miter;
 end;

 Canvas.LineJoin:=LineJoin;

 result:=aThis;

end;

function POCACanvasFunctionGETLINEWIDTH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    LineWidth:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 LineWidth:=Canvas.LineWidth;

 result.Num:=LineWidth;

end;

function POCACanvasFunctionSETLINEWIDTH(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    LineWidth:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for LineWidth
 if ArgumentIndex<aCountArguments then begin
  LineWidth:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  LineWidth:=0.0;
 end;

 Canvas.LineWidth:=LineWidth;

 result:=aThis;

end;

function POCACanvasFunctionGETMITERLIMIT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    MiterLimit:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 MiterLimit:=Canvas.MiterLimit;

 result.Num:=MiterLimit;

end;

function POCACanvasFunctionSETMITERLIMIT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    MiterLimit:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for MiterLimit
 if ArgumentIndex<aCountArguments then begin
  MiterLimit:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  MiterLimit:=0.0;
 end;

 Canvas.MiterLimit:=MiterLimit;

 result:=aThis;

end;

function POCACanvasFunctionGETZPOSITION(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    ZPosition:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ZPosition:=Canvas.ZPosition;

 result.Num:=ZPosition;

end;

function POCACanvasFunctionSETZPOSITION(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ZPosition:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ZPosition
 if ArgumentIndex<aCountArguments then begin
  ZPosition:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  ZPosition:=0.0;
 end;

 Canvas.ZPosition:=ZPosition;

 result:=aThis;

end;

function POCACanvasFunctionGETTEXTHORIZONTALALIGNMENT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    TextHorizontalAlignment:TpvCanvasTextHorizontalAlignment;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 TextHorizontalAlignment:=Canvas.TextHorizontalAlignment;

 result.Num:=TpvInt32(TextHorizontalAlignment);

end;

function POCACanvasFunctionSETTEXTHORIZONTALALIGNMENT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    TextHorizontalAlignment:TpvCanvasTextHorizontalAlignment;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for TextHorizontalAlignment
 if ArgumentIndex<aCountArguments then begin
  TextHorizontalAlignment:=TpvCanvasTextHorizontalAlignment(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  TextHorizontalAlignment:=TpvCanvasTextHorizontalAlignment.Leading;
 end;

 Canvas.TextHorizontalAlignment:=TextHorizontalAlignment;

 result:=aThis;

end;

function POCACanvasFunctionGETTEXTVERTICALALIGNMENT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    TextVerticalAlignment:TpvCanvasTextVerticalAlignment;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 TextVerticalAlignment:=Canvas.TextVerticalAlignment;

 result.Num:=TpvInt32(TextVerticalAlignment);

end;

function POCACanvasFunctionSETTEXTVERTICALALIGNMENT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    TextVerticalAlignment:TpvCanvasTextVerticalAlignment;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for TextVerticalAlignment
 if ArgumentIndex<aCountArguments then begin
  TextVerticalAlignment:=TpvCanvasTextVerticalAlignment(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  TextVerticalAlignment:=TpvCanvasTextVerticalAlignment.Leading;
 end;

 Canvas.TextVerticalAlignment:=TextVerticalAlignment;

 result:=aThis;

end;

function POCACanvasFunctionGETFONT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Font:TpvFont;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Font:=Canvas.Font;

 if assigned(Font) then begin
  result:=POCANewFont(aContext,Font);
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end;

function POCACanvasFunctionSETFONT(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Font:TpvFont;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Font
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAFontGhostPointer) then begin
  Font:=TpvFont(POCAGhostFastGetPointer(aArguments^[ArgumentIndex]));
  Canvas.Font:=Font;
  inc(ArgumentIndex);
 end else if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCACanvasFontGhostPointer) then begin
  Font:=TpvCanvasFont(POCAGhostFastGetPointer(aArguments^[ArgumentIndex])).VulkanFont;
  Canvas.Font:=Font;
  inc(ArgumentIndex);
 end else begin
  Font:=nil;
 end;

 result:=aThis;

end;

function POCACanvasFunctionGETFONTSIZE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    FontSize:TpvDouble;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 FontSize:=Canvas.FontSize;

 result.Num:=FontSize;

end; 

function POCACanvasFunctionSETFONTSIZE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    FontSize:TpvDouble;
begin 

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for FontSize
 if ArgumentIndex<aCountArguments then begin
  FontSize:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  FontSize:=0.0;
 end;

 Canvas.FontSize:=FontSize;

 result:=aThis;

end; 

function POCACanvasFunctionGETTEXTURE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Texture:TObject;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Texture:=Canvas.Texture;

 if assigned(Texture) and (Texture is TpvVulkanTexture) then begin
  result:=POCANewTexture(aContext,TpvVulkanTexture(Texture));
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end;

function POCACanvasFunctionSETTEXTURE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Texture:TpvVulkanTexture;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Texture
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCATextureGhostPointer) then begin
  Texture:=TpvVulkanTexture(POCAGhostFastGetPointer(aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Texture:=nil;
 end;

 Canvas.Texture:=Texture;

 result:=aThis;

end;

function POCACanvasFunctionGETMASKTEXTURE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    MaskTexture:TObject;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 MaskTexture:=Canvas.MaskTexture;

 if assigned(MaskTexture) and (MaskTexture is TpvVulkanTexture) then begin
  result:=POCANewTexture(aContext,TpvVulkanTexture(MaskTexture));
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;

end; 

function POCACanvasFunctionSETMASKTEXTURE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    MaskTexture:TpvVulkanTexture;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for MaskTexture
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCATextureGhostPointer) then begin
  MaskTexture:=TpvVulkanTexture(POCAGhostFastGetPointer(aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  MaskTexture:=nil;
 end;

 Canvas.MaskTexture:=MaskTexture;

 result:=aThis;

end;

function POCACanvasFunctionGETFILLSTYLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    FillStyle:TpvCanvasFillStyle;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 FillStyle:=Canvas.FillStyle;

 result.Num:=TpvInt32(FillStyle);

end;

function POCACanvasFunctionSETFILLSTYLE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    FillStyle:TpvCanvasFillStyle;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for FillStyle
 if ArgumentIndex<aCountArguments then begin
  FillStyle:=TpvCanvasFillStyle(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  FillStyle:=TpvCanvasFillStyle.Color;
 end;

 Canvas.FillStyle:=FillStyle;

 result:=aThis;

end;

function POCACanvasFunctionGETFILLRULE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    FillRule:TpvCanvasFillRule;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 FillRule:=Canvas.FillRule;

 result.Num:=TpvInt32(FillRule);

end;

function POCACanvasFunctionSETFILLRULE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    FillRule:TpvCanvasFillRule;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for FillRule
 if ArgumentIndex<aCountArguments then begin
  FillRule:=TpvCanvasFillRule(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  FillRule:=TpvCanvasFillRule.EvenOdd;
 end;

 Canvas.FillRule:=FillRule;

 result:=aThis;

end;

function POCACanvasFunctionGETFILLWRAPMODE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    FillWrapMode:TpvCanvasFillWrapMode;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 FillWrapMode:=Canvas.FillWrapMode;

 result.Num:=TpvInt32(FillWrapMode);

end;

function POCACanvasFunctionSETFILLWRAPMODE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    FillWrapMode:TpvCanvasFillWrapMode;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for FillWrapMode
 if ArgumentIndex<aCountArguments then begin
  FillWrapMode:=TpvCanvasFillWrapMode(trunc(POCAGetNumberValue(aContext,aArguments^[ArgumentIndex])));
  inc(ArgumentIndex);
 end else begin
  FillWrapMode:=TpvCanvasFillWrapMode.None;
 end;

 Canvas.FillWrapMode:=FillWrapMode;

 result:=aThis;

end;

function POCACanvasFunctionGETCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Color:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Color:=Canvas.Color;

 result:=POCANewVector4(aContext,Color);

end;

function POCACanvasFunctionSETCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Color:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Color
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector4GhostPointer) then begin
  Color:=POCAGetVector4Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   Color.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Color.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Color.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Color.y:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Color.z:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Color.z:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   Color.w:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Color.w:=1.0;
  end;
 end;

 Canvas.Color:=Color;

 result:=aThis;

end;

function POCACanvasFunctionGETSTARTCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    StartColor:TpvVector4;
begin
 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 StartColor:=Canvas.StartColor;

 result:=POCANewVector4(aContext,StartColor);

end;

function POCACanvasFunctionSETSTARTCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    StartColor:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for StartColor
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector4GhostPointer) then begin
  StartColor:=POCAGetVector4Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   StartColor.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StartColor.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StartColor.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StartColor.y:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StartColor.z:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StartColor.z:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StartColor.w:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StartColor.w:=1.0;
  end;
 end;

 Canvas.StartColor:=StartColor;

 result:=aThis;

end;

function POCACanvasFunctionGETSTOPCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    StopColor:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 StopColor:=Canvas.StopColor;

 result:=POCANewVector4(aContext,StopColor);

end;

function POCACanvasFunctionSETSTOPCOLOR(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    StopColor:TpvVector4;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for StopColor
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCAVector4GhostPointer) then begin
  StopColor:=POCAGetVector4Value(aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  if ArgumentIndex<aCountArguments then begin
   StopColor.x:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StopColor.x:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StopColor.y:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StopColor.y:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StopColor.z:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StopColor.z:=0.0;
  end;
  if ArgumentIndex<aCountArguments then begin
   StopColor.w:=POCAGetNumberValue(aContext,aArguments^[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   StopColor.w:=1.0;
  end;
 end;

 Canvas.StopColor:=StopColor;

 result:=aThis;

end;

function POCAGetMatrix4x4Argument(aContext:PPOCAContext;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;var aArgumentIndex:TPOCAInt32):TpvMatrix4x4D;
begin
 if (aArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[aArgumentIndex])=POCAMatrix4x4GhostPointer) then begin
  result:=POCAGetMatrix4x4Value(aArguments^[aArgumentIndex]);
  inc(aArgumentIndex); 
 end else begin
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[0,0]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[0,0]:=1.0;
  end; 
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[0,1]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[0,1]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[0,2]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[0,2]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[0,3]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[0,3]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[1,0]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[1,0]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[1,1]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[1,1]:=1.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[1,2]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[1,2]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[1,3]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[1,3]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[2,0]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[2,0]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[2,1]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[2,1]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[2,2]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[2,2]:=1.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[2,3]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[2,3]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[3,0]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[3,0]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[3,1]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[3,1]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[3,2]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[3,2]:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.RawComponents[3,3]:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.RawComponents[3,3]:=1.0;
  end;
 end;
end;

function POCAGetVector3Argument(aContext:PPOCAContext;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;var aArgumentIndex:TPOCAInt32):TpvVector3D;
begin
 if (aArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[aArgumentIndex])=POCAVector3GhostPointer) then begin
  result:=POCAGetVector3Value(aArguments^[aArgumentIndex]);
  inc(aArgumentIndex);
 end else begin
  if aArgumentIndex<aCountArguments then begin
   result.x:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.x:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.y:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.y:=0.0;
  end;
  if aArgumentIndex<aCountArguments then begin
   result.z:=POCAGetNumberValue(aContext,aArguments^[aArgumentIndex]);
   inc(aArgumentIndex);
  end else begin
   result.z:=0.0;
  end;
 end;
end;

function POCACanvasFunctionGETPROJECTIONMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    ProjectionMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ProjectionMatrix:=Canvas.ProjectionMatrix;

 result:=POCANewMatrix4x4(aContext,ProjectionMatrix);

end;

function POCACanvasFunctionSETPROJECTIONMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ProjectionMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ProjectionMatrix
 ProjectionMatrix:=POCAGetMatrix4x4Argument(aContext,aArguments,aCountArguments,ArgumentIndex);

 Canvas.ProjectionMatrix:=ProjectionMatrix;

 result:=aThis;

end;

function POCACanvasFunctionGETVIEWMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    ViewMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ViewMatrix:=Canvas.ViewMatrix;

 result:=POCANewMatrix4x4(aContext,ViewMatrix);

end;

function POCACanvasFunctionSETVIEWMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ViewMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ViewMatrix
 ViewMatrix:=POCAGetMatrix4x4Argument(aContext,aArguments,aCountArguments,ArgumentIndex);

 Canvas.ViewMatrix:=ViewMatrix;

 result:=aThis;

end; 

function POCACanvasFunctionGETMODELMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    ModelMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ModelMatrix:=Canvas.ModelMatrix;

 result:=POCANewMatrix4x4(aContext,ModelMatrix);

end;

function POCACanvasFunctionSETMODELMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    ModelMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for ModelMatrix
 ModelMatrix:=POCAGetMatrix4x4Argument(aContext,aArguments,aCountArguments,ArgumentIndex);

 Canvas.ModelMatrix:=ModelMatrix;

 result:=aThis;

end;

function POCACanvasFunctionGETFILLMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    FillMatrix:TpvMatrix4x4D;
begin
 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 FillMatrix:=Canvas.FillMatrix;

 result:=POCANewMatrix4x4(aContext,FillMatrix);

end;

function POCACanvasFunctionSETFILLMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    FillMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for FillMatrix
 FillMatrix:=POCAGetMatrix4x4Argument(aContext,aArguments,aCountArguments,ArgumentIndex);

 Canvas.FillMatrix:=FillMatrix;

 result:=aThis;

end;

function POCACanvasFunctionGETMASKMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    MaskMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 MaskMatrix:=Canvas.MaskMatrix;

 result:=POCANewMatrix4x4(aContext,MaskMatrix);

end;

function POCACanvasFunctionSETMASKMATRIX(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    MaskMatrix:TpvMatrix4x4D;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for MaskMatrix
 MaskMatrix:=POCAGetMatrix4x4Argument(aContext,aArguments,aCountArguments,ArgumentIndex);

 Canvas.MaskMatrix:=MaskMatrix;

 result:=aThis;

end; 

function POCACanvasFunctionSETSTROKEPATTERN(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    StrokePattern:TpvUTF8String;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for StrokePattern
 if ArgumentIndex<aCountArguments then begin
  StrokePattern:=POCAGetStringValue(aContext,aArguments^[ArgumentIndex]);
  inc(ArgumentIndex);
 end else begin
  StrokePattern:='';
 end;

 Canvas.StrokePattern:=StrokePattern;

 result:=aThis;

end;

function POCACanvasFunctionDRAWSHAPE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Canvas:TpvCanvas;
    Shape:TpvCanvasShape;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 ArgumentIndex:=0;
 
 // Check for Shape
 if (ArgumentIndex<aCountArguments) and (POCAGhostGetType(aArguments^[ArgumentIndex])=POCACanvasShapeGhostPointer) then begin
  Shape:=TpvCanvasShape(POCAGhostFastGetPointer(aArguments^[ArgumentIndex]));
  inc(ArgumentIndex);
 end else begin
  Shape:=nil;
 end;

 Canvas.DrawShape(Shape);

 result:=aThis;

end;

function POCACanvasFunctionGETSTROKESHAPE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Shape:TpvCanvasShape;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Shape:=Canvas.GetStrokeShape;

 result:=POCANewCanvasShape(aContext,Shape);

end;

function POCACanvasFunctionGETFILLSHAPE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Canvas:TpvCanvas;
    Shape:TpvCanvasShape;
begin

 if POCAGhostGetType(aThis)<>@POCACanvasGhost then begin
  POCARuntimeError(aContext,'Canvas expected');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Canvas:=TpvCanvas(POCAGhostFastGetPointer(aThis));
 if not assigned(Canvas) then begin
  POCARuntimeError(aContext,'Canvas is null');
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  exit;
 end;

 Shape:=Canvas.GetFillShape;

 result:=POCANewCanvasShape(aContext,Shape);

end;

procedure POCAInitCanvasHash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);
 HostData^.CanvasHash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.CanvasHash);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getWidth',POCACanvasFunctionGETWIDTH); 
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getHeight',POCACanvasFunctionGETHEIGHT); 
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'clear',POCACanvasFunctionCLEAR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledCircle',POCACanvasFunctionDRAWFILLEDCIRCLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledEllipse',POCACanvasFunctionDRAWFILLEDELLIPSE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledRectangle',POCACanvasFunctionDRAWFILLEDRECTANGLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledRectangleCenter',POCACanvasFunctionDRAWFILLEDRECTANGLECENTER);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledRoundedRectangle',POCACanvasFunctionDRAWFILLEDROUNDEDRECTANGLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledRoundedRectangleCenter',POCACanvasFunctionDRAWFILLEDROUNDEDRECTANGLECENTER);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawFilledCircleArcRingSegment',POCACanvasFunctionDRAWFILLEDCIRCLEARCRINGSEGMENT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawTexturedRectangle',POCACanvasFunctionDRAWTEXTUREDRECTANGLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawTexturedRectangleCenter',POCACanvasFunctionDRAWTEXTUREDRECTANGLECENTER);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawSprite',POCACanvasFunctionDRAWSPRITE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawSpriteOriginRotation',POCACanvasFunctionDRAWSPRITEORIGINROTATION);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawSpritePosition',POCACanvasFunctionDRAWSPRITEPOSITION);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawText',POCACanvasFunctionDRAWTEXT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawTextCodePoint',POCACanvasFunctionDRAWTEXTCODEPOINT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'textWidth',POCACanvasFunctionTEXTWIDTH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'textHeight',POCACanvasFunctionTEXTHEIGHT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'textSize',POCACanvasFunctionTEXTSIZE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'textRowHeight',POCACanvasFunctionTEXTROWHEIGHT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'beginPath',POCACanvasFunctionBEGINPATH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'moveTo',POCACanvasFunctionMOVETO);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'lineTo',POCACanvasFunctionLINETO);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'quadraticCurveTo',POCACanvasFunctionQUADRATICCURVETO);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'cubicCurveTo',POCACanvasFunctionCUBICCURVETO);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'arc',POCACanvasFunctionARC);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'arcTo',POCACanvasFunctionARCTO);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'ellipse',POCACanvasFunctionELLIPSE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'circle',POCACanvasFunctionCIRCLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'rectangle',POCACanvasFunctionRECTANGLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'rectangleCenter',POCACanvasFunctionRECTANGLECENTER);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'roundedRectangle',POCACanvasFunctionROUNDEDRECTANGLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'roundedRectangleCenter',POCACanvasFunctionROUNDEDRECTANGLECENTER);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'closePath',POCACanvasFunctionCLOSEPATH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'endPath',POCACanvasFunctionENDPATH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'stroke',POCACanvasFunctionSTROKE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'fill',POCACanvasFunctionFILL);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'push',POCACanvasFunctionPUSH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'pop',POCACanvasFunctionPOP);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'flush',POCACanvasFunctionFLUSH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getClipRect',POCACanvasFunctionGETCLIPRECT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setClipRect',POCACanvasFunctionSETCLIPRECT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setScissor',POCACanvasFunctionSETSCISSOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getBlendingMode',POCACanvasFunctionGETBLENDINGMODE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setBlendingMode',POCACanvasFunctionSETBLENDINGMODE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getLineCap',POCACanvasFunctionGETLINECAP);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setLineCap',POCACanvasFunctionSETLINECAP);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getLineJoin',POCACanvasFunctionGETLINEJOIN);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setLineJoin',POCACanvasFunctionSETLINEJOIN);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getLineWidth',POCACanvasFunctionGETLINEWIDTH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setLineWidth',POCACanvasFunctionSETLINEWIDTH);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getMiterLimit',POCACanvasFunctionGETMITERLIMIT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setMiterLimit',POCACanvasFunctionSETMITERLIMIT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getZPosition',POCACanvasFunctionGETZPOSITION);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setZPosition',POCACanvasFunctionSETZPOSITION);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getTextHorizontalAlignment',POCACanvasFunctionGETTEXTHORIZONTALALIGNMENT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setTextHorizontalAlignment',POCACanvasFunctionSETTEXTHORIZONTALALIGNMENT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getTextVerticalAlignment',POCACanvasFunctionGETTEXTVERTICALALIGNMENT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setTextVerticalAlignment',POCACanvasFunctionSETTEXTVERTICALALIGNMENT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFont',POCACanvasFunctionGETFONT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFont',POCACanvasFunctionSETFONT);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFontSize',POCACanvasFunctionGETFONTSIZE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFontSize',POCACanvasFunctionSETFONTSIZE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getTexture',POCACanvasFunctionGETTEXTURE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setTexture',POCACanvasFunctionSETTEXTURE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getMaskTexture',POCACanvasFunctionGETMASKTEXTURE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setMaskTexture',POCACanvasFunctionSETMASKTEXTURE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFillStyle',POCACanvasFunctionGETFILLSTYLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFillStyle',POCACanvasFunctionSETFILLSTYLE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFillRule',POCACanvasFunctionGETFILLRULE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFillRule',POCACanvasFunctionSETFILLRULE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFillWrapMode',POCACanvasFunctionGETFILLWRAPMODE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFillWrapMode',POCACanvasFunctionSETFILLWRAPMODE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getColor',POCACanvasFunctionGETCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setColor',POCACanvasFunctionSETCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getStartColor',POCACanvasFunctionGETSTARTCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setStartColor',POCACanvasFunctionSETSTARTCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getStopColor',POCACanvasFunctionGETSTOPCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setStopColor',POCACanvasFunctionSETSTOPCOLOR);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getProjectionMatrix',POCACanvasFunctionGETPROJECTIONMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setProjectionMatrix',POCACanvasFunctionSETPROJECTIONMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getViewMatrix',POCACanvasFunctionGETVIEWMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setViewMatrix',POCACanvasFunctionSETVIEWMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getModelMatrix',POCACanvasFunctionGETMODELMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setModelMatrix',POCACanvasFunctionSETMODELMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFillMatrix',POCACanvasFunctionGETFILLMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setFillMatrix',POCACanvasFunctionSETFILLMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getMaskMatrix',POCACanvasFunctionGETMASKMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setMaskMatrix',POCACanvasFunctionSETMASKMATRIX);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'setStrokePattern',POCACanvasFunctionSETSTROKEPATTERN);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'drawShape',POCACanvasFunctionDRAWSHAPE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getStrokeShape',POCACanvasFunctionGETSTROKESHAPE);
 POCAAddNativeFunction(aContext,HostData^.CanvasHash,'getFillShape',POCACanvasFunctionGETFILLSHAPE);

end; 

procedure POCAInitCanvasNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'BlendingMode',POCAInitCanvasBlendMode(aContext));
 POCAHashSetString(aContext,Hash,'LineJoin',POCAInitCanvasLineJoin(aContext));
 POCAHashSetString(aContext,Hash,'LineCap',POCAInitCanvasLineCap(aContext));
 POCAHashSetString(aContext,Hash,'FillRule',POCAInitCanvasFillRule(aContext));
 POCAHashSetString(aContext,Hash,'FillStyle',POCAInitCanvasFillStyle(aContext));
 POCAHashSetString(aContext,Hash,'FillWrapMode',POCAInitCanvasFillWrapMode(aContext));
 POCAHashSetString(aContext,Hash,'TextHorizontalAlignment',POCAInitCanvasTextHorizontalAlignment(aContext));
 POCAHashSetString(aContext,Hash,'TextVerticalAlignment',POCAInitCanvasTextVerticalAlignment(aContext));
 POCAHashSetString(aContext,Hash,'VectorPathFillRule',POCAInitCanvasVectorPathFillRule(aContext));
 POCAHashSetString(aContext,Hash,'SignedDistanceField2DVariant',POCAInitCanvasSignedDistanceField2DVariant(aContext));
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Canvas',Hash);
end;

procedure POCAInitCanvas(aContext:PPOCAContext);
begin
 POCAInitCanvasHash(aContext);
 POCAInitCanvasNamespace(aContext);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Input 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function POCAInitInputEventTypes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'EVENT_NONE',POCANewNumber(aContext,EVENT_NONE));
 POCAHashSetString(aContext,Hash,'EVENT_KEY',POCANewNumber(aContext,EVENT_KEY));
 POCAHashSetString(aContext,Hash,'EVENT_POINTER',POCANewNumber(aContext,EVENT_POINTER));
 POCAHashSetString(aContext,Hash,'EVENT_SCROLLED',POCANewNumber(aContext,EVENT_SCROLLED));
 POCAHashSetString(aContext,Hash,'EVENT_DRAGDROPFILE',POCANewNumber(aContext,EVENT_DRAGDROPFILE));
 result:=Hash;
end;

function POCAInitInputKeyCodes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'KEYCODE_QUIT',POCANewNumber(aContext,KEYCODE_QUIT));
 POCAHashSetString(aContext,Hash,'KEYCODE_ANYKEY',POCANewNumber(aContext,KEYCODE_ANYKEY));
 POCAHashSetString(aContext,Hash,'KEYCODE_UNKNOWN',POCANewNumber(aContext,KEYCODE_UNKNOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_FIRST',POCANewNumber(aContext,KEYCODE_FIRST));
 POCAHashSetString(aContext,Hash,'KEYCODE_BACKSPACE',POCANewNumber(aContext,KEYCODE_BACKSPACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_TAB',POCANewNumber(aContext,KEYCODE_TAB));
 POCAHashSetString(aContext,Hash,'KEYCODE_RETURN',POCANewNumber(aContext,KEYCODE_RETURN));
 POCAHashSetString(aContext,Hash,'KEYCODE_PAUSE',POCANewNumber(aContext,KEYCODE_PAUSE));
 POCAHashSetString(aContext,Hash,'KEYCODE_ESCAPE',POCANewNumber(aContext,KEYCODE_ESCAPE));
 POCAHashSetString(aContext,Hash,'KEYCODE_SPACE',POCANewNumber(aContext,KEYCODE_SPACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_EXCLAIM',POCANewNumber(aContext,KEYCODE_EXCLAIM));
 POCAHashSetString(aContext,Hash,'KEYCODE_QUOTEDBL',POCANewNumber(aContext,KEYCODE_QUOTEDBL));
 POCAHashSetString(aContext,Hash,'KEYCODE_HASH',POCANewNumber(aContext,KEYCODE_HASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_DOLLAR',POCANewNumber(aContext,KEYCODE_DOLLAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_AMPERSAND',POCANewNumber(aContext,KEYCODE_AMPERSAND));
 POCAHashSetString(aContext,Hash,'KEYCODE_APOSTROPHE',POCANewNumber(aContext,KEYCODE_APOSTROPHE));
 POCAHashSetString(aContext,Hash,'KEYCODE_LEFTPAREN',POCANewNumber(aContext,KEYCODE_LEFTPAREN));
 POCAHashSetString(aContext,Hash,'KEYCODE_RIGHTPAREN',POCANewNumber(aContext,KEYCODE_RIGHTPAREN));
 POCAHashSetString(aContext,Hash,'KEYCODE_ASTERISK',POCANewNumber(aContext,KEYCODE_ASTERISK));
 POCAHashSetString(aContext,Hash,'KEYCODE_PLUS',POCANewNumber(aContext,KEYCODE_PLUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_COMMA',POCANewNumber(aContext,KEYCODE_COMMA));
 POCAHashSetString(aContext,Hash,'KEYCODE_MINUS',POCANewNumber(aContext,KEYCODE_MINUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_PERIOD',POCANewNumber(aContext,KEYCODE_PERIOD));
 POCAHashSetString(aContext,Hash,'KEYCODE_SLASH',POCANewNumber(aContext,KEYCODE_SLASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_0',POCANewNumber(aContext,KEYCODE_0));
 POCAHashSetString(aContext,Hash,'KEYCODE_1',POCANewNumber(aContext,KEYCODE_1));
 POCAHashSetString(aContext,Hash,'KEYCODE_2',POCANewNumber(aContext,KEYCODE_2));
 POCAHashSetString(aContext,Hash,'KEYCODE_3',POCANewNumber(aContext,KEYCODE_3));
 POCAHashSetString(aContext,Hash,'KEYCODE_4',POCANewNumber(aContext,KEYCODE_4));
 POCAHashSetString(aContext,Hash,'KEYCODE_5',POCANewNumber(aContext,KEYCODE_5));
 POCAHashSetString(aContext,Hash,'KEYCODE_6',POCANewNumber(aContext,KEYCODE_6));
 POCAHashSetString(aContext,Hash,'KEYCODE_7',POCANewNumber(aContext,KEYCODE_7));
 POCAHashSetString(aContext,Hash,'KEYCODE_8',POCANewNumber(aContext,KEYCODE_8));
 POCAHashSetString(aContext,Hash,'KEYCODE_9',POCANewNumber(aContext,KEYCODE_9));
 POCAHashSetString(aContext,Hash,'KEYCODE_COLON',POCANewNumber(aContext,KEYCODE_COLON));
 POCAHashSetString(aContext,Hash,'KEYCODE_SEMICOLON',POCANewNumber(aContext,KEYCODE_SEMICOLON));
 POCAHashSetString(aContext,Hash,'KEYCODE_LESS',POCANewNumber(aContext,KEYCODE_LESS));
 POCAHashSetString(aContext,Hash,'KEYCODE_EQUALS',POCANewNumber(aContext,KEYCODE_EQUALS));
 POCAHashSetString(aContext,Hash,'KEYCODE_GREATER',POCANewNumber(aContext,KEYCODE_GREATER));
 POCAHashSetString(aContext,Hash,'KEYCODE_QUESTION',POCANewNumber(aContext,KEYCODE_QUESTION));
 POCAHashSetString(aContext,Hash,'KEYCODE_AT',POCANewNumber(aContext,KEYCODE_AT));
 POCAHashSetString(aContext,Hash,'KEYCODE_LEFTBRACKET',POCANewNumber(aContext,KEYCODE_LEFTBRACKET));
 POCAHashSetString(aContext,Hash,'KEYCODE_BACKSLASH',POCANewNumber(aContext,KEYCODE_BACKSLASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_RIGHTBRACKET',POCANewNumber(aContext,KEYCODE_RIGHTBRACKET));
 POCAHashSetString(aContext,Hash,'KEYCODE_CARET',POCANewNumber(aContext,KEYCODE_CARET));
 POCAHashSetString(aContext,Hash,'KEYCODE_UNDERSCORE',POCANewNumber(aContext,KEYCODE_UNDERSCORE));
 POCAHashSetString(aContext,Hash,'KEYCODE_BACKQUOTE',POCANewNumber(aContext,KEYCODE_BACKQUOTE));
 POCAHashSetString(aContext,Hash,'KEYCODE_A',POCANewNumber(aContext,KEYCODE_A));
 POCAHashSetString(aContext,Hash,'KEYCODE_B',POCANewNumber(aContext,KEYCODE_B));
 POCAHashSetString(aContext,Hash,'KEYCODE_C',POCANewNumber(aContext,KEYCODE_C));
 POCAHashSetString(aContext,Hash,'KEYCODE_D',POCANewNumber(aContext,KEYCODE_D));
 POCAHashSetString(aContext,Hash,'KEYCODE_E',POCANewNumber(aContext,KEYCODE_E));
 POCAHashSetString(aContext,Hash,'KEYCODE_F',POCANewNumber(aContext,KEYCODE_F));
 POCAHashSetString(aContext,Hash,'KEYCODE_G',POCANewNumber(aContext,KEYCODE_G));
 POCAHashSetString(aContext,Hash,'KEYCODE_H',POCANewNumber(aContext,KEYCODE_H));
 POCAHashSetString(aContext,Hash,'KEYCODE_I',POCANewNumber(aContext,KEYCODE_I));
 POCAHashSetString(aContext,Hash,'KEYCODE_J',POCANewNumber(aContext,KEYCODE_J));
 POCAHashSetString(aContext,Hash,'KEYCODE_K',POCANewNumber(aContext,KEYCODE_K));
 POCAHashSetString(aContext,Hash,'KEYCODE_L',POCANewNumber(aContext,KEYCODE_L));
 POCAHashSetString(aContext,Hash,'KEYCODE_M',POCANewNumber(aContext,KEYCODE_M));
 POCAHashSetString(aContext,Hash,'KEYCODE_N',POCANewNumber(aContext,KEYCODE_N));
 POCAHashSetString(aContext,Hash,'KEYCODE_O',POCANewNumber(aContext,KEYCODE_O));
 POCAHashSetString(aContext,Hash,'KEYCODE_P',POCANewNumber(aContext,KEYCODE_P));
 POCAHashSetString(aContext,Hash,'KEYCODE_Q',POCANewNumber(aContext,KEYCODE_Q));
 POCAHashSetString(aContext,Hash,'KEYCODE_R',POCANewNumber(aContext,KEYCODE_R));
 POCAHashSetString(aContext,Hash,'KEYCODE_S',POCANewNumber(aContext,KEYCODE_S));
 POCAHashSetString(aContext,Hash,'KEYCODE_T',POCANewNumber(aContext,KEYCODE_T));
 POCAHashSetString(aContext,Hash,'KEYCODE_U',POCANewNumber(aContext,KEYCODE_U));
 POCAHashSetString(aContext,Hash,'KEYCODE_V',POCANewNumber(aContext,KEYCODE_V));
 POCAHashSetString(aContext,Hash,'KEYCODE_W',POCANewNumber(aContext,KEYCODE_W));
 POCAHashSetString(aContext,Hash,'KEYCODE_X',POCANewNumber(aContext,KEYCODE_X));
 POCAHashSetString(aContext,Hash,'KEYCODE_Y',POCANewNumber(aContext,KEYCODE_Y));
 POCAHashSetString(aContext,Hash,'KEYCODE_Z',POCANewNumber(aContext,KEYCODE_Z));
 POCAHashSetString(aContext,Hash,'KEYCODE_LEFTBRACE',POCANewNumber(aContext,KEYCODE_LEFTBRACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_PIPE',POCANewNumber(aContext,KEYCODE_PIPE));
 POCAHashSetString(aContext,Hash,'KEYCODE_RIGHTBRACE',POCANewNumber(aContext,KEYCODE_RIGHTBRACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_TILDE',POCANewNumber(aContext,KEYCODE_TILDE));
 POCAHashSetString(aContext,Hash,'KEYCODE_DELETE',POCANewNumber(aContext,KEYCODE_DELETE));
 POCAHashSetString(aContext,Hash,'KEYCODE_F1',POCANewNumber(aContext,KEYCODE_F1));
 POCAHashSetString(aContext,Hash,'KEYCODE_F2',POCANewNumber(aContext,KEYCODE_F2));
 POCAHashSetString(aContext,Hash,'KEYCODE_F3',POCANewNumber(aContext,KEYCODE_F3));
 POCAHashSetString(aContext,Hash,'KEYCODE_F4',POCANewNumber(aContext,KEYCODE_F4));
 POCAHashSetString(aContext,Hash,'KEYCODE_F5',POCANewNumber(aContext,KEYCODE_F5));
 POCAHashSetString(aContext,Hash,'KEYCODE_F6',POCANewNumber(aContext,KEYCODE_F6));
 POCAHashSetString(aContext,Hash,'KEYCODE_F7',POCANewNumber(aContext,KEYCODE_F7));
 POCAHashSetString(aContext,Hash,'KEYCODE_F8',POCANewNumber(aContext,KEYCODE_F8));
 POCAHashSetString(aContext,Hash,'KEYCODE_F9',POCANewNumber(aContext,KEYCODE_F9));
 POCAHashSetString(aContext,Hash,'KEYCODE_F10',POCANewNumber(aContext,KEYCODE_F10));
 POCAHashSetString(aContext,Hash,'KEYCODE_F11',POCANewNumber(aContext,KEYCODE_F11));
 POCAHashSetString(aContext,Hash,'KEYCODE_F12',POCANewNumber(aContext,KEYCODE_F12));
 POCAHashSetString(aContext,Hash,'KEYCODE_F13',POCANewNumber(aContext,KEYCODE_F13));
 POCAHashSetString(aContext,Hash,'KEYCODE_F14',POCANewNumber(aContext,KEYCODE_F14));
 POCAHashSetString(aContext,Hash,'KEYCODE_F15',POCANewNumber(aContext,KEYCODE_F15));
 POCAHashSetString(aContext,Hash,'KEYCODE_F16',POCANewNumber(aContext,KEYCODE_F16));
 POCAHashSetString(aContext,Hash,'KEYCODE_F17',POCANewNumber(aContext,KEYCODE_F17));
 POCAHashSetString(aContext,Hash,'KEYCODE_F18',POCANewNumber(aContext,KEYCODE_F18));
 POCAHashSetString(aContext,Hash,'KEYCODE_F19',POCANewNumber(aContext,KEYCODE_F19));
 POCAHashSetString(aContext,Hash,'KEYCODE_F20',POCANewNumber(aContext,KEYCODE_F20));
 POCAHashSetString(aContext,Hash,'KEYCODE_F21',POCANewNumber(aContext,KEYCODE_F21));
 POCAHashSetString(aContext,Hash,'KEYCODE_F22',POCANewNumber(aContext,KEYCODE_F22));
 POCAHashSetString(aContext,Hash,'KEYCODE_F23',POCANewNumber(aContext,KEYCODE_F23));
 POCAHashSetString(aContext,Hash,'KEYCODE_F24',POCANewNumber(aContext,KEYCODE_F24));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP0',POCANewNumber(aContext,KEYCODE_KP0));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP1',POCANewNumber(aContext,KEYCODE_KP1));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP2',POCANewNumber(aContext,KEYCODE_KP2));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP3',POCANewNumber(aContext,KEYCODE_KP3));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP4',POCANewNumber(aContext,KEYCODE_KP4));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP5',POCANewNumber(aContext,KEYCODE_KP5));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP6',POCANewNumber(aContext,KEYCODE_KP6));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP7',POCANewNumber(aContext,KEYCODE_KP7));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP8',POCANewNumber(aContext,KEYCODE_KP8));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP9',POCANewNumber(aContext,KEYCODE_KP9));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_PERIOD',POCANewNumber(aContext,KEYCODE_KP_PERIOD));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_DIVIDE',POCANewNumber(aContext,KEYCODE_KP_DIVIDE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MULTIPLY',POCANewNumber(aContext,KEYCODE_KP_MULTIPLY));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MINUS',POCANewNumber(aContext,KEYCODE_KP_MINUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_PLUS',POCANewNumber(aContext,KEYCODE_KP_PLUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_ENTER',POCANewNumber(aContext,KEYCODE_KP_ENTER));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_EQUALS',POCANewNumber(aContext,KEYCODE_KP_EQUALS));
 POCAHashSetString(aContext,Hash,'KEYCODE_UP',POCANewNumber(aContext,KEYCODE_UP));
 POCAHashSetString(aContext,Hash,'KEYCODE_DOWN',POCANewNumber(aContext,KEYCODE_DOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_RIGHT',POCANewNumber(aContext,KEYCODE_RIGHT));
 POCAHashSetString(aContext,Hash,'KEYCODE_LEFT',POCANewNumber(aContext,KEYCODE_LEFT));
 POCAHashSetString(aContext,Hash,'KEYCODE_INSERT',POCANewNumber(aContext,KEYCODE_INSERT));
 POCAHashSetString(aContext,Hash,'KEYCODE_HOME',POCANewNumber(aContext,KEYCODE_HOME));
 POCAHashSetString(aContext,Hash,'KEYCODE_END',POCANewNumber(aContext,KEYCODE_END));
 POCAHashSetString(aContext,Hash,'KEYCODE_PAGEUP',POCANewNumber(aContext,KEYCODE_PAGEUP));
 POCAHashSetString(aContext,Hash,'KEYCODE_PAGEDOWN',POCANewNumber(aContext,KEYCODE_PAGEDOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_CAPSLOCK',POCANewNumber(aContext,KEYCODE_CAPSLOCK));
 POCAHashSetString(aContext,Hash,'KEYCODE_NUMLOCK',POCANewNumber(aContext,KEYCODE_NUMLOCK));
 POCAHashSetString(aContext,Hash,'KEYCODE_SCROLLLOCK',POCANewNumber(aContext,KEYCODE_SCROLLLOCK));
 // Modifier keys
 POCAHashSetString(aContext,Hash,'KEYCODE_RSHIFT',POCANewNumber(aContext,KEYCODE_RSHIFT));
 POCAHashSetString(aContext,Hash,'KEYCODE_LSHIFT',POCANewNumber(aContext,KEYCODE_LSHIFT));
 POCAHashSetString(aContext,Hash,'KEYCODE_RCTRL',POCANewNumber(aContext,KEYCODE_RCTRL));
 POCAHashSetString(aContext,Hash,'KEYCODE_LCTRL',POCANewNumber(aContext,KEYCODE_LCTRL));
 POCAHashSetString(aContext,Hash,'KEYCODE_RALT',POCANewNumber(aContext,KEYCODE_RALT));
 POCAHashSetString(aContext,Hash,'KEYCODE_LALT',POCANewNumber(aContext,KEYCODE_LALT));
 POCAHashSetString(aContext,Hash,'KEYCODE_MODE',POCANewNumber(aContext,KEYCODE_MODE));
 POCAHashSetString(aContext,Hash,'KEYCODE_HELP',POCANewNumber(aContext,KEYCODE_HELP));
 POCAHashSetString(aContext,Hash,'KEYCODE_PRINTSCREEN',POCANewNumber(aContext,KEYCODE_PRINTSCREEN));
 POCAHashSetString(aContext,Hash,'KEYCODE_SYSREQ',POCANewNumber(aContext,KEYCODE_SYSREQ));
 POCAHashSetString(aContext,Hash,'KEYCODE_MENU',POCANewNumber(aContext,KEYCODE_MENU));
 POCAHashSetString(aContext,Hash,'KEYCODE_POWER',POCANewNumber(aContext,KEYCODE_POWER));
 POCAHashSetString(aContext,Hash,'KEYCODE_APPLICATION',POCANewNumber(aContext,KEYCODE_APPLICATION));
 POCAHashSetString(aContext,Hash,'KEYCODE_SELECT',POCANewNumber(aContext,KEYCODE_SELECT));
 POCAHashSetString(aContext,Hash,'KEYCODE_STOP',POCANewNumber(aContext,KEYCODE_STOP));
 POCAHashSetString(aContext,Hash,'KEYCODE_AGAIN',POCANewNumber(aContext,KEYCODE_AGAIN));
 POCAHashSetString(aContext,Hash,'KEYCODE_UNDO',POCANewNumber(aContext,KEYCODE_UNDO));
 POCAHashSetString(aContext,Hash,'KEYCODE_CUT',POCANewNumber(aContext,KEYCODE_CUT));
 POCAHashSetString(aContext,Hash,'KEYCODE_COPY',POCANewNumber(aContext,KEYCODE_COPY));
 POCAHashSetString(aContext,Hash,'KEYCODE_PASTE',POCANewNumber(aContext,KEYCODE_PASTE));
 POCAHashSetString(aContext,Hash,'KEYCODE_FIND',POCANewNumber(aContext,KEYCODE_FIND));
 POCAHashSetString(aContext,Hash,'KEYCODE_MUTE',POCANewNumber(aContext,KEYCODE_MUTE));
 POCAHashSetString(aContext,Hash,'KEYCODE_VOLUMEUP',POCANewNumber(aContext,KEYCODE_VOLUMEUP));
 POCAHashSetString(aContext,Hash,'KEYCODE_VOLUMEDOWN',POCANewNumber(aContext,KEYCODE_VOLUMEDOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_EQUALSAS400',POCANewNumber(aContext,KEYCODE_KP_EQUALSAS400));
 POCAHashSetString(aContext,Hash,'KEYCODE_ALTERASE',POCANewNumber(aContext,KEYCODE_ALTERASE));
 POCAHashSetString(aContext,Hash,'KEYCODE_CANCEL',POCANewNumber(aContext,KEYCODE_CANCEL));
 POCAHashSetString(aContext,Hash,'KEYCODE_CLEAR',POCANewNumber(aContext,KEYCODE_CLEAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_PRIOR',POCANewNumber(aContext,KEYCODE_PRIOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_RETURN2',POCANewNumber(aContext,KEYCODE_RETURN2));
 POCAHashSetString(aContext,Hash,'KEYCODE_SEPARATOR',POCANewNumber(aContext,KEYCODE_SEPARATOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_OUT',POCANewNumber(aContext,KEYCODE_OUT));
 POCAHashSetString(aContext,Hash,'KEYCODE_OPER',POCANewNumber(aContext,KEYCODE_OPER));
 POCAHashSetString(aContext,Hash,'KEYCODE_CLEARAGAIN',POCANewNumber(aContext,KEYCODE_CLEARAGAIN));
 POCAHashSetString(aContext,Hash,'KEYCODE_CRSEL',POCANewNumber(aContext,KEYCODE_CRSEL));
 POCAHashSetString(aContext,Hash,'KEYCODE_EXSEL',POCANewNumber(aContext,KEYCODE_EXSEL));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_00',POCANewNumber(aContext,KEYCODE_KP_00));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_000',POCANewNumber(aContext,KEYCODE_KP_000));
 POCAHashSetString(aContext,Hash,'KEYCODE_THOUSANDSSEPARATOR',POCANewNumber(aContext,KEYCODE_THOUSANDSSEPARATOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_DECIMALSEPARATOR',POCANewNumber(aContext,KEYCODE_DECIMALSEPARATOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_CURRENCYUNIT',POCANewNumber(aContext,KEYCODE_CURRENCYUNIT));
 POCAHashSetString(aContext,Hash,'KEYCODE_CURRENCYSUBUNIT',POCANewNumber(aContext,KEYCODE_CURRENCYSUBUNIT));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_LEFTPAREN',POCANewNumber(aContext,KEYCODE_KP_LEFTPAREN));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_RIGHTPAREN',POCANewNumber(aContext,KEYCODE_KP_RIGHTPAREN));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_LEFTBRACE',POCANewNumber(aContext,KEYCODE_KP_LEFTBRACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_RIGHTBRACE',POCANewNumber(aContext,KEYCODE_KP_RIGHTBRACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_TAB',POCANewNumber(aContext,KEYCODE_KP_TAB));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_BACKSPACE',POCANewNumber(aContext,KEYCODE_KP_BACKSPACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_A',POCANewNumber(aContext,KEYCODE_KP_A));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_B',POCANewNumber(aContext,KEYCODE_KP_B));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_C',POCANewNumber(aContext,KEYCODE_KP_C));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_D',POCANewNumber(aContext,KEYCODE_KP_D));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_E',POCANewNumber(aContext,KEYCODE_KP_E));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_F',POCANewNumber(aContext,KEYCODE_KP_F));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_XOR',POCANewNumber(aContext,KEYCODE_KP_XOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_POWER',POCANewNumber(aContext,KEYCODE_KP_POWER));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_PERCENT',POCANewNumber(aContext,KEYCODE_KP_PERCENT));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_LESS',POCANewNumber(aContext,KEYCODE_KP_LESS));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_GREATER',POCANewNumber(aContext,KEYCODE_KP_GREATER));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_AMPERSAND',POCANewNumber(aContext,KEYCODE_KP_AMPERSAND));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_DBLAMPERSAND',POCANewNumber(aContext,KEYCODE_KP_DBLAMPERSAND));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_VERTICALBAR',POCANewNumber(aContext,KEYCODE_KP_VERTICALBAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_DBLVERTICALBAR',POCANewNumber(aContext,KEYCODE_KP_DBLVERTICALBAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_COLON',POCANewNumber(aContext,KEYCODE_KP_COLON));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_COMMA',POCANewNumber(aContext,KEYCODE_KP_COMMA));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_HASH',POCANewNumber(aContext,KEYCODE_KP_HASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_SPACE',POCANewNumber(aContext,KEYCODE_KP_SPACE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_AT',POCANewNumber(aContext,KEYCODE_KP_AT));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_EXCLAM',POCANewNumber(aContext,KEYCODE_KP_EXCLAM));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMSTORE',POCANewNumber(aContext,KEYCODE_KP_MEMSTORE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMRECALL',POCANewNumber(aContext,KEYCODE_KP_MEMRECALL));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMCLEAR',POCANewNumber(aContext,KEYCODE_KP_MEMCLEAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMADD',POCANewNumber(aContext,KEYCODE_KP_MEMADD));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMSUBTRACT',POCANewNumber(aContext,KEYCODE_KP_MEMSUBTRACT));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMMULTIPLY',POCANewNumber(aContext,KEYCODE_KP_MEMMULTIPLY));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_MEMDIVIDE',POCANewNumber(aContext,KEYCODE_KP_MEMDIVIDE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_PLUSMINUS',POCANewNumber(aContext,KEYCODE_KP_PLUSMINUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_CLEAR',POCANewNumber(aContext,KEYCODE_KP_CLEAR));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_CLEARENTRY',POCANewNumber(aContext,KEYCODE_KP_CLEARENTRY));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_BINARY',POCANewNumber(aContext,KEYCODE_KP_BINARY));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_OCTAL',POCANewNumber(aContext,KEYCODE_KP_OCTAL));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_DECIMAL',POCANewNumber(aContext,KEYCODE_KP_DECIMAL));
 POCAHashSetString(aContext,Hash,'KEYCODE_KP_HEXADECIMAL',POCANewNumber(aContext,KEYCODE_KP_HEXADECIMAL));
 POCAHashSetString(aContext,Hash,'KEYCODE_LGUI',POCANewNumber(aContext,KEYCODE_LGUI));
 POCAHashSetString(aContext,Hash,'KEYCODE_RGUI',POCANewNumber(aContext,KEYCODE_RGUI));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIONEXT',POCANewNumber(aContext,KEYCODE_AUDIONEXT));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIOPREV',POCANewNumber(aContext,KEYCODE_AUDIOPREV));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIOSTOP',POCANewNumber(aContext,KEYCODE_AUDIOSTOP));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIOPLAY',POCANewNumber(aContext,KEYCODE_AUDIOPLAY));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIOMUTE',POCANewNumber(aContext,KEYCODE_AUDIOMUTE));
 POCAHashSetString(aContext,Hash,'KEYCODE_MEDIASELECT',POCANewNumber(aContext,KEYCODE_MEDIASELECT));
 POCAHashSetString(aContext,Hash,'KEYCODE_WWW',POCANewNumber(aContext,KEYCODE_WWW));
 POCAHashSetString(aContext,Hash,'KEYCODE_MAIL',POCANewNumber(aContext,KEYCODE_MAIL));
 POCAHashSetString(aContext,Hash,'KEYCODE_CALCULATOR',POCANewNumber(aContext,KEYCODE_CALCULATOR));
 POCAHashSetString(aContext,Hash,'KEYCODE_COMPUTER',POCANewNumber(aContext,KEYCODE_COMPUTER));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_SEARCH',POCANewNumber(aContext,KEYCODE_AC_SEARCH));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_HOME',POCANewNumber(aContext,KEYCODE_AC_HOME));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_BACK',POCANewNumber(aContext,KEYCODE_AC_BACK));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_FORWARD',POCANewNumber(aContext,KEYCODE_AC_FORWARD));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_STOP',POCANewNumber(aContext,KEYCODE_AC_STOP));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_REFRESH',POCANewNumber(aContext,KEYCODE_AC_REFRESH));
 POCAHashSetString(aContext,Hash,'KEYCODE_AC_BOOKMARKS',POCANewNumber(aContext,KEYCODE_AC_BOOKMARKS));
 POCAHashSetString(aContext,Hash,'KEYCODE_BRIGHTNESSDOWN',POCANewNumber(aContext,KEYCODE_BRIGHTNESSDOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_BRIGHTNESSUP',POCANewNumber(aContext,KEYCODE_BRIGHTNESSUP));
 POCAHashSetString(aContext,Hash,'KEYCODE_DISPLAYSWITCH',POCANewNumber(aContext,KEYCODE_DISPLAYSWITCH));
 POCAHashSetString(aContext,Hash,'KEYCODE_KBDILLUMTOGGLE',POCANewNumber(aContext,KEYCODE_KBDILLUMTOGGLE));
 POCAHashSetString(aContext,Hash,'KEYCODE_KBDILLUMDOWN',POCANewNumber(aContext,KEYCODE_KBDILLUMDOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_KBDILLUMUP',POCANewNumber(aContext,KEYCODE_KBDILLUMUP));
 POCAHashSetString(aContext,Hash,'KEYCODE_EJECT',POCANewNumber(aContext,KEYCODE_EJECT));
 POCAHashSetString(aContext,Hash,'KEYCODE_SLEEP',POCANewNumber(aContext,KEYCODE_SLEEP));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL1',POCANewNumber(aContext,KEYCODE_INTERNATIONAL1));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL2',POCANewNumber(aContext,KEYCODE_INTERNATIONAL2));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL3',POCANewNumber(aContext,KEYCODE_INTERNATIONAL3));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL4',POCANewNumber(aContext,KEYCODE_INTERNATIONAL4));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL5',POCANewNumber(aContext,KEYCODE_INTERNATIONAL5));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL6',POCANewNumber(aContext,KEYCODE_INTERNATIONAL6));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL7',POCANewNumber(aContext,KEYCODE_INTERNATIONAL7));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL8',POCANewNumber(aContext,KEYCODE_INTERNATIONAL8));
 POCAHashSetString(aContext,Hash,'KEYCODE_INTERNATIONAL9',POCANewNumber(aContext,KEYCODE_INTERNATIONAL9));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG1',POCANewNumber(aContext,KEYCODE_LANG1));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG2',POCANewNumber(aContext,KEYCODE_LANG2));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG3',POCANewNumber(aContext,KEYCODE_LANG3));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG4',POCANewNumber(aContext,KEYCODE_LANG4));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG5',POCANewNumber(aContext,KEYCODE_LANG5));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG6',POCANewNumber(aContext,KEYCODE_LANG6));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG7',POCANewNumber(aContext,KEYCODE_LANG7));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG8',POCANewNumber(aContext,KEYCODE_LANG8));
 POCAHashSetString(aContext,Hash,'KEYCODE_LANG9',POCANewNumber(aContext,KEYCODE_LANG9));
 POCAHashSetString(aContext,Hash,'KEYCODE_LOCKINGCAPSLOCK',POCANewNumber(aContext,KEYCODE_LOCKINGCAPSLOCK));
 POCAHashSetString(aContext,Hash,'KEYCODE_LOCKINGNUMLOCK',POCANewNumber(aContext,KEYCODE_LOCKINGNUMLOCK));
 POCAHashSetString(aContext,Hash,'KEYCODE_LOCKINGSCROLLLOCK',POCANewNumber(aContext,KEYCODE_LOCKINGSCROLLLOCK));
 POCAHashSetString(aContext,Hash,'KEYCODE_NONUSBACKSLASH',POCANewNumber(aContext,KEYCODE_NONUSBACKSLASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_NONUSHASH',POCANewNumber(aContext,KEYCODE_NONUSHASH));
 POCAHashSetString(aContext,Hash,'KEYCODE_BACK',POCANewNumber(aContext,KEYCODE_BACK));
 POCAHashSetString(aContext,Hash,'KEYCODE_CAMERA',POCANewNumber(aContext,KEYCODE_CAMERA));
 POCAHashSetString(aContext,Hash,'KEYCODE_CALL',POCANewNumber(aContext,KEYCODE_CALL));
 POCAHashSetString(aContext,Hash,'KEYCODE_CENTER',POCANewNumber(aContext,KEYCODE_CENTER));
 POCAHashSetString(aContext,Hash,'KEYCODE_FORWARD_DEL',POCANewNumber(aContext,KEYCODE_FORWARD_DEL));
 POCAHashSetString(aContext,Hash,'KEYCODE_DPAD_CENTER',POCANewNumber(aContext,KEYCODE_DPAD_CENTER));
 POCAHashSetString(aContext,Hash,'KEYCODE_DPAD_LEFT',POCANewNumber(aContext,KEYCODE_DPAD_LEFT));
 POCAHashSetString(aContext,Hash,'KEYCODE_DPAD_RIGHT',POCANewNumber(aContext,KEYCODE_DPAD_RIGHT));
 POCAHashSetString(aContext,Hash,'KEYCODE_DPAD_DOWN',POCANewNumber(aContext,KEYCODE_DPAD_DOWN));
 POCAHashSetString(aContext,Hash,'KEYCODE_DPAD_UP',POCANewNumber(aContext,KEYCODE_DPAD_UP));
 POCAHashSetString(aContext,Hash,'KEYCODE_ENDCALL',POCANewNumber(aContext,KEYCODE_ENDCALL));
 POCAHashSetString(aContext,Hash,'KEYCODE_ENVELOPE',POCANewNumber(aContext,KEYCODE_ENVELOPE));
 POCAHashSetString(aContext,Hash,'KEYCODE_EXPLORER',POCANewNumber(aContext,KEYCODE_EXPLORER));
 POCAHashSetString(aContext,Hash,'KEYCODE_FOCUS',POCANewNumber(aContext,KEYCODE_FOCUS));
 POCAHashSetString(aContext,Hash,'KEYCODE_GRAVE',POCANewNumber(aContext,KEYCODE_GRAVE));
 POCAHashSetString(aContext,Hash,'KEYCODE_HEADSETHOOK',POCANewNumber(aContext,KEYCODE_HEADSETHOOK));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIO_FAST_FORWARD',POCANewNumber(aContext,KEYCODE_AUDIO_FAST_FORWARD));
 POCAHashSetString(aContext,Hash,'KEYCODE_AUDIO_REWIND',POCANewNumber(aContext,KEYCODE_AUDIO_REWIND));
 POCAHashSetString(aContext,Hash,'KEYCODE_NOTIFICATION',POCANewNumber(aContext,KEYCODE_NOTIFICATION));
 POCAHashSetString(aContext,Hash,'KEYCODE_PICTSYMBOLS',POCANewNumber(aContext,KEYCODE_PICTSYMBOLS));
 POCAHashSetString(aContext,Hash,'KEYCODE_SWITCH_CHARSET',POCANewNumber(aContext,KEYCODE_SWITCH_CHARSET));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_CIRCLE',POCANewNumber(aContext,KEYCODE_BUTTON_CIRCLE));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_A',POCANewNumber(aContext,KEYCODE_BUTTON_A));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_B',POCANewNumber(aContext,KEYCODE_BUTTON_B));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_C',POCANewNumber(aContext,KEYCODE_BUTTON_C));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_X',POCANewNumber(aContext,KEYCODE_BUTTON_X));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_Y',POCANewNumber(aContext,KEYCODE_BUTTON_Y));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_Z',POCANewNumber(aContext,KEYCODE_BUTTON_Z));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_L1',POCANewNumber(aContext,KEYCODE_BUTTON_L1));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_R1',POCANewNumber(aContext,KEYCODE_BUTTON_R1));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_L2',POCANewNumber(aContext,KEYCODE_BUTTON_L2));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_R2',POCANewNumber(aContext,KEYCODE_BUTTON_R2));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_THUMBL',POCANewNumber(aContext,KEYCODE_BUTTON_THUMBL));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_THUMBR',POCANewNumber(aContext,KEYCODE_BUTTON_THUMBR));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_START',POCANewNumber(aContext,KEYCODE_BUTTON_START));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_SELECT',POCANewNumber(aContext,KEYCODE_BUTTON_SELECT));
 POCAHashSetString(aContext,Hash,'KEYCODE_BUTTON_MODE',POCANewNumber(aContext,KEYCODE_BUTTON_MODE));
 POCAHashSetString(aContext,Hash,'KEYCODE_102ND',POCANewNumber(aContext,KEYCODE_102ND));
 POCAHashSetString(aContext,Hash,'KEYCODE_KATAKANAHIRAGANA',POCANewNumber(aContext,KEYCODE_KATAKANAHIRAGANA));
 POCAHashSetString(aContext,Hash,'KEYCODE_HENKAN',POCANewNumber(aContext,KEYCODE_HENKAN));
 POCAHashSetString(aContext,Hash,'KEYCODE_MUHENKAN',POCANewNumber(aContext,KEYCODE_MUHENKAN));
 POCAHashSetString(aContext,Hash,'KEYCODE_HANGEUL',POCANewNumber(aContext,KEYCODE_HANGEUL));
 POCAHashSetString(aContext,Hash,'KEYCODE_HANJA',POCANewNumber(aContext,KEYCODE_HANJA));
 POCAHashSetString(aContext,Hash,'KEYCODE_COUNT',POCANewNumber(aContext,KEYCODE_COUNT));
 result:=Hash;
end;

function POCAInitInputJoystickHats(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_CENTERED',POCANewNumber(aContext,JOYSTICK_HAT_CENTERED));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_LEFT',POCANewNumber(aContext,JOYSTICK_HAT_LEFT));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_RIGHT',POCANewNumber(aContext,JOYSTICK_HAT_RIGHT));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_UP',POCANewNumber(aContext,JOYSTICK_HAT_UP));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_DOWN',POCANewNumber(aContext,JOYSTICK_HAT_DOWN));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_LEFTUP',POCANewNumber(aContext,JOYSTICK_HAT_LEFTUP));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_RIGHTUP',POCANewNumber(aContext,JOYSTICK_HAT_RIGHTUP));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_LEFTDOWN',POCANewNumber(aContext,JOYSTICK_HAT_LEFTDOWN));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_RIGHTDOWN',POCANewNumber(aContext,JOYSTICK_HAT_RIGHTDOWN));
 POCAHashSetString(aContext,Hash,'JOYSTICK_HAT_NONE',POCANewNumber(aContext,JOYSTICK_HAT_NONE));
 result:=Hash;
end;

function POCAInitInputGameControllerBindTypes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BINDTYPE_NONE',POCANewNumber(aContext,GAME_CONTROLLER_BINDTYPE_NONE));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BINDTYPE_BUTTON',POCANewNumber(aContext,GAME_CONTROLLER_BINDTYPE_BUTTON));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BINDTYPE_AXIS',POCANewNumber(aContext,GAME_CONTROLLER_BINDTYPE_AXIS));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BINDTYPE_HAT',POCANewNumber(aContext,GAME_CONTROLLER_BINDTYPE_HAT));
 result:=Hash;
end;

function POCAInitInputGameControllerAxes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_INVALID',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_INVALID));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_LEFTX',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_LEFTX));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_LEFTY',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_LEFTY));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_RIGHTX',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_RIGHTX));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_RIGHTY',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_RIGHTY));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_TRIGGERLEFT',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_TRIGGERLEFT));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_TRIGGERRIGHT',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_TRIGGERRIGHT));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_AXIS_MAX',POCANewNumber(aContext,GAME_CONTROLLER_AXIS_MAX));
 result:=Hash;
end;

function POCAInitInputGameControllerButtons(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_INVALID',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_INVALID));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_A',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_A));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_B',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_B));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_X',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_X));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_Y',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_Y));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_BACK',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_BACK));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_GUIDE',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_GUIDE));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_START',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_START));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_LEFTSTICK',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_LEFTSTICK));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_RIGHTSTICK',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_RIGHTSTICK));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_LEFTSHOULDER',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_LEFTSHOULDER));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_RIGHTSHOULDER',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_RIGHTSHOULDER));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_DPAD_UP',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_DPAD_UP));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_DPAD_DOWN',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_DPAD_DOWN));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_DPAD_LEFT',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_DPAD_LEFT));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_DPAD_RIGHT',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_DPAD_RIGHT));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_MISC1',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_MISC1));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_PADDLE1',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_PADDLE1));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_PADDLE2',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_PADDLE2));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_PADDLE3',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_PADDLE3));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_PADDLE4',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_PADDLE4));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_TOUCHPAD',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_TOUCHPAD));
 POCAHashSetString(aContext,Hash,'GAME_CONTROLLER_BUTTON_MAX',POCANewNumber(aContext,GAME_CONTROLLER_BUTTON_MAX));
 result:=Hash;
end;

function POCAInitInputKeyEventTypes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'KEYEVENT_DOWN',POCANewNumber(aContext,KEYEVENT_DOWN));
 POCAHashSetString(aContext,Hash,'KEYEVENT_UP',POCANewNumber(aContext,KEYEVENT_UP));
 POCAHashSetString(aContext,Hash,'KEYEVENT_TYPED',POCANewNumber(aContext,KEYEVENT_TYPED));
 POCAHashSetString(aContext,Hash,'KEYEVENT_UNICODE',POCANewNumber(aContext,KEYEVENT_UNICODE));
 result:=Hash;
end;

function POCAInitInputKeyModifiers(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_LSHIFT',POCANewNumber(aContext,KEYMODIFIER_LSHIFT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_RSHIFT',POCANewNumber(aContext,KEYMODIFIER_RSHIFT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_LCTRL',POCANewNumber(aContext,KEYMODIFIER_LCTRL));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_RCTRL',POCANewNumber(aContext,KEYMODIFIER_RCTRL));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_LALT',POCANewNumber(aContext,KEYMODIFIER_LALT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_RALT',POCANewNumber(aContext,KEYMODIFIER_RALT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_LMETA',POCANewNumber(aContext,KEYMODIFIER_LMETA));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_RMETA',POCANewNumber(aContext,KEYMODIFIER_RMETA));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_NUM',POCANewNumber(aContext,KEYMODIFIER_NUM));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_CAPS',POCANewNumber(aContext,KEYMODIFIER_CAPS));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_SCROLL',POCANewNumber(aContext,KEYMODIFIER_SCROLL));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_MODE',POCANewNumber(aContext,KEYMODIFIER_MODE));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_RESERVED',POCANewNumber(aContext,KEYMODIFIER_RESERVED));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_CTRL',POCANewNumber(aContext,KEYMODIFIER_CTRL));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_SHIFT',POCANewNumber(aContext,KEYMODIFIER_SHIFT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_ALT',POCANewNumber(aContext,KEYMODIFIER_ALT));
 POCAHashSetString(aContext,Hash,'KEYMODIFIER_META',POCANewNumber(aContext,KEYMODIFIER_META));
 result:=Hash;
end;

function POCAInitInputPointerEventTypes(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'POINTEREVENT_DOWN',POCANewNumber(aContext,POINTEREVENT_DOWN));
 POCAHashSetString(aContext,Hash,'POINTEREVENT_UP',POCANewNumber(aContext,POINTEREVENT_UP));
 POCAHashSetString(aContext,Hash,'POINTEREVENT_MOTION',POCANewNumber(aContext,POINTEREVENT_MOTION));
 POCAHashSetString(aContext,Hash,'POINTEREVENT_DRAG',POCANewNumber(aContext,POINTEREVENT_DRAG));
 result:=Hash;
end;

function POCAInitInputPointerButtons(aContext:PPOCAContext):TPOCAValue;
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_NONE',POCANewNumber(aContext,POINTERBUTTON_NONE));
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_LEFT',POCANewNumber(aContext,POINTERBUTTON_LEFT));
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_MIDDLE',POCANewNumber(aContext,POINTERBUTTON_MIDDLE));
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_RIGHT',POCANewNumber(aContext,POINTERBUTTON_RIGHT));
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_X1',POCANewNumber(aContext,POINTERBUTTON_X1));
 POCAHashSetString(aContext,Hash,'POINTERBUTTON_X2',POCANewNumber(aContext,POINTERBUTTON_X2));
 result:=Hash;
end;

procedure POCAInitInputNamespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAHashSetString(aContext,Hash,'EventTypes',POCAInitInputEventTypes(aContext));
 POCAHashSetString(aContext,Hash,'KeyCodes',POCAInitInputKeyCodes(aContext));
 POCAHashSetString(aContext,Hash,'JoystickHats',POCAInitInputJoystickHats(aContext));
 POCAHashSetString(aContext,Hash,'GameControllerBindTypes',POCAInitInputGameControllerBindTypes(aContext));
 POCAHashSetString(aContext,Hash,'GameControllerAxes',POCAInitInputGameControllerAxes(aContext));
 POCAHashSetString(aContext,Hash,'GameControllerButtons',POCAInitInputGameControllerButtons(aContext));
 POCAHashSetString(aContext,Hash,'KeyEventTypes',POCAInitInputKeyEventTypes(aContext));
 POCAHashSetString(aContext,Hash,'KeyModifiers',POCAInitInputKeyModifiers(aContext));
 POCAHashSetString(aContext,Hash,'PointerEventTypes',POCAInitInputPointerEventTypes(aContext)); 
 POCAHashSetString(aContext,Hash,'PointerButtons',POCAInitInputPointerButtons(aContext));       //}
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Input',Hash);
end;

procedure POCAInitInput(aContext:PPOCAContext);
begin
 POCAInitInputNamespace(aContext);
end;

function ConvertKeyModifiers(const aKeyModifiers:TpvApplicationInputKeyModifiers):TpvUInt32;
begin
 result:=0;
 if TpvApplicationInputKeyModifier.LSHIFT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_LSHIFT);
 end;
 if TpvApplicationInputKeyModifier.RSHIFT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_RSHIFT);
 end;
 if TpvApplicationInputKeyModifier.LCTRL in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_LCTRL);
 end;
 if TpvApplicationInputKeyModifier.RCTRL in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_RCTRL);
 end;
 if TpvApplicationInputKeyModifier.LALT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_LALT);
 end;
 if TpvApplicationInputKeyModifier.RALT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_RALT);
 end;
 if TpvApplicationInputKeyModifier.LMETA in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_LMETA);
 end;
 if TpvApplicationInputKeyModifier.RMETA in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_RMETA);
 end; if TpvApplicationInputKeyModifier.NUM in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_NUM);
 end;
 if TpvApplicationInputKeyModifier.CAPS in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_CAPS);
 end;
 if TpvApplicationInputKeyModifier.SCROLL in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_SCROLL);
 end;
 if TpvApplicationInputKeyModifier.MODE in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_MODE);
 end;
 if TpvApplicationInputKeyModifier.RESERVED in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_RESERVED);
 end;
 if TpvApplicationInputKeyModifier.CTRL in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_CTRL);
 end;
 if TpvApplicationInputKeyModifier.SHIFT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_SHIFT);
 end;
 if TpvApplicationInputKeyModifier.ALT in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_ALT);
 end;
 if TpvApplicationInputKeyModifier.META in aKeyModifiers then begin
  result:=result or (TpvUInt32(1) shl KEYMODIFIER_META);
 end;
end;

function ConvertPointerButton(const aPointerButton:TpvApplicationInputPointerButton):TpvInt32;
begin
 case aPointerButton of
  TpvApplicationInputPointerButton.Left:begin
   result:=POINTERBUTTON_LEFT;
  end;
  TpvApplicationInputPointerButton.Middle:begin
   result:=POINTERBUTTON_MIDDLE;
  end;
  TpvApplicationInputPointerButton.Right:begin
   result:=POINTERBUTTON_RIGHT;
  end;
  TpvApplicationInputPointerButton.X1:begin
   result:=POINTERBUTTON_X1;
  end;
  TpvApplicationInputPointerButton.X2:begin
   result:=POINTERBUTTON_X2;
  end;
  else begin
   result:=POINTERBUTTON_NONE;
  end;
 end;
end;

function ConvertPointerButtons(const aPointerButtons:TpvApplicationInputPointerButtons):TpvUInt32;
begin
 result:=0;
 if TpvApplicationInputPointerButton.None in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_NONE);
 end;
 if TpvApplicationInputPointerButton.Left in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_LEFT);
 end;
 if TpvApplicationInputPointerButton.Middle in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_MIDDLE);
 end;
 if TpvApplicationInputPointerButton.Right in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_RIGHT);
 end;
 if TpvApplicationInputPointerButton.X1 in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_X1);
 end;
 if TpvApplicationInputPointerButton.X2 in aPointerButtons then begin
  result:=result or (TpvUInt32(1) shl POINTERBUTTON_X2);
 end;
end;

function POCANewInputEventHash(const aContext:PPOCAContext):TPOCAValue;
begin
 result:=POCANewHash(aContext);
end;

function POCASetInputEventHashNone(const aContext:PPOCAContext;const aHash:TPOCAValue):TPOCAValue;
begin
 POCAHashSetString(aContext,aHash,'EventType',POCANewNumber(aContext,EVENT_NONE));
 result:=aHash;
end;

function POCASetInputEventHashKey(const aContext:PPOCAContext;const aHash:TPOCAValue;const aKeyEvent:TpvApplicationInputKeyEvent):TPOCAValue;
begin
 POCAHashSetString(aContext,aHash,'EventType',POCANewNumber(aContext,EVENT_KEY));
 case aKeyEvent.KeyEventType of
  TpvApplicationInputKeyEventType.Down:begin
   POCAHashSetString(aContext,aHash,'KeyEventType',POCANewNumber(aContext,KEYEVENT_DOWN));
  end;
  TpvApplicationInputKeyEventType.Up:begin
   POCAHashSetString(aContext,aHash,'KeyEventType',POCANewNumber(aContext,KEYEVENT_UP));
  end;
  TpvApplicationInputKeyEventType.Typed:begin
   POCAHashSetString(aContext,aHash,'KeyEventType',POCANewNumber(aContext,KEYEVENT_TYPED));
  end;
  else {TpvApplicationInputKeyEventType.Unicode:}begin
   POCAHashSetString(aContext,aHash,'KeyEventType',POCANewNumber(aContext,KEYEVENT_UNICODE));
  end;
 end;
 POCAHashSetString(aContext,aHash,'KeyCode',POCANewNumber(aContext,aKeyEvent.KeyCode));
 POCAHashSetString(aContext,aHash,'ScanCode',POCANewNumber(aContext,aKeyEvent.ScanCode));
 POCAHashSetString(aContext,aHash,'KeyModifiers',POCANewNumber(aContext,ConvertKeyModifiers(aKeyEvent.KeyModifiers)));
 result:=aHash;
end;

function POCASetInputEventHashPointer(const aContext:PPOCAContext;const aHash:TPOCAValue;const aPointerEvent:TpvApplicationInputPointerEvent):TPOCAValue;
begin
 POCAHashSetString(aContext,aHash,'EventType',POCANewNumber(aContext,EVENT_POINTER));
 case aPointerEvent.PointerEventType of
  TpvApplicationInputPointerEventType.Down:begin
   POCAHashSetString(aContext,aHash,'PointerEventType',POCANewNumber(aContext,POINTEREVENT_DOWN));
  end;
  TpvApplicationInputPointerEventType.Up:begin
   POCAHashSetString(aContext,aHash,'PointerEventType',POCANewNumber(aContext,POINTEREVENT_UP));
  end;
  TpvApplicationInputPointerEventType.Motion:begin
   POCAHashSetString(aContext,aHash,'PointerEventType',POCANewNumber(aContext,POINTEREVENT_MOTION));
  end;
  else {TpvApplicationInputPointerEventType.Drag:}begin
   POCAHashSetString(aContext,aHash,'PointerEventType',POCANewNumber(aContext,POINTEREVENT_DRAG));
  end;
 end; 
 POCAHashSetString(aContext,aHash,'Position',POCANewVector2(aContext,aPointerEvent.Position));
 POCAHashSetString(aContext,aHash,'RelativePosition',POCANewVector2(aContext,aPointerEvent.RelativePosition));
 POCAHashSetString(aContext,aHash,'Pressure',POCANewNumber(aContext,aPointerEvent.Pressure));
 POCAHashSetString(aContext,aHash,'PointerID',POCANewNumber(aContext,aPointerEvent.PointerID));
 POCAHashSetString(aContext,aHash,'Button',POCANewNumber(aContext,ConvertPointerButton(aPointerEvent.Button)));
 POCAHashSetString(aContext,aHash,'Buttons',POCANewNumber(aContext,ConvertPointerButtons(aPointerEvent.Buttons)));
 POCAHashSetString(aContext,aHash,'KeyModifiers',POCANewNumber(aContext,ConvertKeyModifiers(aPointerEvent.KeyModifiers)));
 result:=aHash;
end;

function POCASetInputEventHashScroll(const aContext:PPOCAContext;const aHash:TPOCAValue;const aRelativeAmount:TpvVector2):TPOCAValue;
begin
 POCAHashSetString(aContext,aHash,'EventType',POCANewNumber(aContext,EVENT_SCROLLED));
 POCAHashSetString(aContext,aHash,'RelativeAmount',POCANewVector2(aContext,aRelativeAmount));
 result:=aHash;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// JSON Conversion
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function JSONToPOCAValue(const aContext:PPOCAContext;const aJSON:TPasJSONItem):TPOCAValue;
var Index:TpvSizeInt;
    HashValue:TPOCAValue;
    ArrayValue:TPOCAValue;
begin
 if assigned(aJSON) then begin
  case aJSON.ItemType of
   TPasJSONItemType.Null:begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
   TPasJSONItemType.Boolean_:begin
    if TPasJSON.GetBoolean(aJSON,false) then begin
     result.Num:=1.0;
    end else begin
     result.Num:=0.0;
    end;
   end;
   TPasJSONItemType.Number:begin
    result:=POCANewNumber(aContext,TPasJSON.GetNumber(aJSON,0.0));
   end;
   TPasJSONItemType.String_:begin
    result:=POCANewString(aContext,TPasJSON.GetString(aJSON,''));
   end;
   TPasJSONItemType.Array_:begin
    ArrayValue:=POCANewArray(aContext);
    for Index:=0 to TPasJSONItemArray(aJSON).Count-1 do begin
     POCAArrayPush(ArrayValue,JSONToPOCAValue(aContext,TPasJSONItemArray(aJSON).Items[Index]));
    end;
    result:=ArrayValue;
   end;
   TPasJSONItemType.Object_:begin
    HashValue:=POCANewHash(aContext);
    for Index:=0 to TPasJSONItemObject(aJSON).Count-1 do begin
     POCAHashSetString(aContext,HashValue,TPasJSONItemObject(aJSON).Keys[Index],JSONToPOCAValue(aContext,TPasJSONItemObject(aJSON).Values[Index]));
    end;
    result:=HashValue;
   end;
   else begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;
 
function POCAValueToJSON(const aContext:PPOCAContext;const aValue:TPOCAValue):TPasJSONItem;
var Index:TpvSizeInt;
    Key,Keys,Value:TPOCAValue;
    KeyString:TPOCARawByteString;
begin
 case POCAGetValueType(aValue) of
  pvtNULL:begin
   result:=TPasJSONItemNull.Create;
  end;
  pvtNUMBER:begin
   result:=TPasJSONItemNumber.Create(aValue.Num);
  end;
  pvtSTRING:begin
   result:=TPasJSONItemString.Create(POCAGetStringValue(aContext,aValue));
  end;
  pvtARRAY:begin
   result:=TPasJSONItemArray.Create;
   for Index:=0 to TpvSizeInt(POCAArraySize(aValue))-1 do begin
    TPasJSONItemArray(result).Add(POCAValueToJSON(aContext,POCAArrayGet(aValue,Index)));
   end;
  end;
  pvtHash:begin
   result:=TPasJSONItemObject.Create;
   POCAHashOwnKeys(aContext,Keys,aValue);
   POCAArraySort(aContext,Keys);
   if POCAGetValueType(Keys)=pvtARRAY then begin
    Value.CastedUInt64:=POCAValueNullCastedUInt64;
    for Index:=0 to POCAArraySize(Keys)-1 do begin
     Key:=POCAArrayGet(Keys,Index);
     if POCAHashGet(aContext,aValue,Key,Value) then begin
      TPasJSONItemObject(result).Add(
       POCAGetStringValue(aContext,Key),
       POCAValueToJSON(aContext,Value)
      );
     end;
    end;
   end;
  end;
  else begin
   result:=TPasJSONItemNull.Create;
  end;
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Audio
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const POCASoundGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Sound'
       );

const POCAMusicGhost:TPOCAGhostType=
       (
        Destroy:nil;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:nil;
        GetKey:nil;
        SetKey:nil;
        Name:'Music'
       );

function POCASoundManagerCreate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    Name,FileName:TpvUTF8String;
    Polyphony,Loop,RealVoices:TpvInt32;
    FadeOutDuration:TpvDouble;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Name:='';
  end;
  if ArgumentIndex<aCountArguments then begin
   FileName:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   FileName:='';
  end;
  if ArgumentIndex<aCountArguments then begin
   Polyphony:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
   inc(ArgumentIndex);
  end else begin
   Polyphony:=1;
  end;
  if ArgumentIndex<aCountArguments then begin
   Loop:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
   inc(ArgumentIndex);
  end else begin
   Loop:=1;
  end;
  if ArgumentIndex<aCountArguments then begin
   RealVoices:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
   inc(ArgumentIndex);
  end else begin
   RealVoices:=-1;
  end;
  if ArgumentIndex<aCountArguments then begin
   FadeOutDuration:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   FadeOutDuration:=0.0;
  end;
  if assigned(Sounds) then begin
   Sound:=Sounds.Add(Name,FileName,Polyphony,Loop,RealVoices,FadeOutDuration);
   if assigned(Sound) then begin
    Sound.Load;
    result:=Sound.fPOCAInstanceValue;
   end else begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundManagerFind(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    Name:TpvUTF8String;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Name:='';
  end;
  if assigned(Sounds) then begin
   Sound:=Sounds.Find(Name);
   if assigned(Sound) then begin
    result:=Sound.fPOCAInstanceValue;
   end else begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundManagerRemove(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    Name:TpvUTF8String;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   if POCAGhostGetType(aArguments[ArgumentIndex])=@POCASoundGhost then begin
    Sound:=POCAGhostFastGetPointer(aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
    if assigned(Sounds) then begin
     Sound:=Sounds.Find(Name);
    end else begin
     Sound:=nil;
    end;
   end;
  end else begin
   Sound:=nil;
  end;
  if assigned(Sounds) and assigned(Sound) then begin
   Sounds.Remove(Sound);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundManagerClear(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  TpvPOCAAudio(aUserData).Clear;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashValid(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  result.Num:=ord(Sounds.fSoundExistHashList.ExistKey(Sound)) and 1;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashDestroy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   Sound.free;
   result.Num:=1.0;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashLoad(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  Sounds:=TpvPOCAAudio(aUserData);
  if assigned(Sounds) then begin
   Sound:=POCAGhostFastGetPointer(aThis);
   if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
    Sound.Load;
    result:=Sound.fPOCAInstanceValue;
   end;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashReload(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  Sounds:=TpvPOCAAudio(aUserData);
  if assigned(Sounds) then begin
   Sound:=POCAGhostFastGetPointer(aThis);
   if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
    Sound.Reload;
    result:=Sound.fPOCAInstanceValue;
   end;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetName(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewString(Sounds.fPOCASubContext,Sound.fName);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetUID(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   if Sound.fUID<=TpvUInt64($001fffffffffffff) then begin
    result:=POCANewNumber(Sounds.fPOCASubContext,Sound.fUID);
   end else begin
    result:=POCANewUniqueString(Sounds.fPOCASubContext,Sound.fUIDString);
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetFileName(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewString(Sounds.fPOCASubContext,Sound.fFileName);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetPolyphony(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewNumber(Sounds.fPOCASubContext,Sound.fPolyphony);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetLoop(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewNumber(Sounds.fPOCASubContext,Sound.fLoop);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetRealVoices(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewNumber(Sounds.fPOCASubContext,Sound.fRealVoices);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashGetFadeOutDuration(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result:=POCANewNumber(Sounds.fPOCASubContext,Sound.fFadeOutDuration);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashPlay(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    Volume,Panning,Rate:TpvFloat;
    VoiceIndexPointer:TpvPointer;
    VoiceID:TpvID;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   Volume:=1.0;
   Panning:=0.0;
   Rate:=1.0;
   VoiceIndexPointer:=nil;
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Volume:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   if ArgumentIndex<aCountArguments then begin
    Panning:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   if ArgumentIndex<aCountArguments then begin
    Rate:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   VoiceIndexPointer:=nil;
   VoiceID:=Sound.Play(Volume,Panning,Rate,VoiceIndexPointer);
   if VoiceID<=$001fffffffffffff then begin
    result:=POCANewNumber(aContext,VoiceID);
   end else begin
    result:=POCANewUniqueString(aContext,UIntToStr(VoiceID));
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashPlaySpatialization(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    Volume,Panning,Rate:TpvFloat;
    Spatialization:LongBool;
    Position,Velocity:TpvVector3D;
    Local:LongBool;
    VoiceIndexPointer:TpvPointer;
    VoiceID:TpvID;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   Volume:=1.0;
   Panning:=0.0;
   Rate:=1.0;
   Spatialization:=false;
   Position:=TpvVector3.Origin;
   Velocity:=TpvVector3.Origin;
   Local:=false;
   VoiceIndexPointer:=nil;
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Volume:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   if ArgumentIndex<aCountArguments then begin
    Panning:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   if ArgumentIndex<aCountArguments then begin
    Rate:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end;
   if ArgumentIndex<aCountArguments then begin
    Spatialization:=(POCAGetNumberValue(aContext,aArguments[ArgumentIndex])<>0);
    inc(ArgumentIndex);
   end;
   if Spatialization then begin
    Position:=POCAGetVector3Argument(aContext,aArguments,aCountArguments,ArgumentIndex);
    Velocity:=POCAGetVector3Argument(aContext,aArguments,aCountArguments,ArgumentIndex);
   end else begin
    Position:=TpvVector3.Origin;
    Velocity:=TpvVector3.Origin;
   end;
   if ArgumentIndex<aCountArguments then begin
    Local:=POCAGetBooleanValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Local:=false;
   end;
   VoiceID:=Sound.PlaySpatialization(Volume,Panning,Rate,Spatialization,Position,Velocity,Local,VoiceIndexPointer);
   if VoiceID<=$001fffffffffffff then begin
    result:=POCANewNumber(aContext,VoiceID);
   end else begin
    result:=POCANewUniqueString(aContext,UIntToStr(VoiceID));
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashStop(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   Sound.Stop(GlobalVoiceID);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashKeyOff(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   Sound.KeyOff(GlobalVoiceID);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashSetVolume(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
    Volume:TpvFloat;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Volume:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Volume:=1.0;
   end;
   Sound.SetVolume(GlobalVoiceID,Volume);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashSetPanning(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
    Panning:TpvFloat;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Panning:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Panning:=0.0;
   end;
   Sound.SetPanning(GlobalVoiceID,Panning);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashSetRate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
    Rate:TpvFloat;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Rate:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Rate:=1.0;
   end;
   Sound.SetRate(GlobalVoiceID,Rate);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashSetPosition(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
    Spatialization:LongBool;
    Origin:TpvVector3D;
    Velocity:TpvVector3D;
    Local:LongBool;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Spatialization:=POCAGetBooleanValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Spatialization:=false;
   end;
   if Spatialization then begin
    Origin:=POCAGetVector3Argument(aContext,aArguments,aCountArguments,ArgumentIndex);
    Velocity:=POCAGetVector3Argument(aContext,aArguments,aCountArguments,ArgumentIndex);
   end else begin
    Origin:=TpvVector3.Origin;
    Velocity:=TpvVector3.Origin;
   end;
   if ArgumentIndex<aCountArguments then begin
    Local:=POCAGetBooleanValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Local:=false;
   end;
   Sound.SetPosition(GlobalVoiceID,Spatialization,Origin,Velocity,Local);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashSetEffectMix(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
    EffectMix:Boolean;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   if ArgumentIndex<aCountArguments then begin
    EffectMix:=POCAGetBooleanValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    EffectMix:=false;
   end;
   Sound.SetEffectMix(GlobalVoiceID,EffectMix);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashIsPlaying(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   result.Num:=ord(Sound.IsPlaying) and 1;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCASoundHashIsVoicePlaying(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Sound:TpvPOCAAudio.TSound;
    GlobalVoiceID:TpvID;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCASoundGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sound:=POCAGhostFastGetPointer(aThis);
  if assigned(Sound) and Sounds.fSoundExistHashList.ExistKey(Sound) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    if POCAGetValueType(aArguments[ArgumentIndex])=pvtNumber then begin
     GlobalVoiceID:=trunc(POCAGetNumberValue(aContext,aArguments[ArgumentIndex]));
    end else begin
     GlobalVoiceID:=StrToUInt64Def(POCAGetStringValue(aContext,aArguments[ArgumentIndex]),0);
    end;
    inc(ArgumentIndex);
   end else begin
    GlobalVoiceID:=0;
   end;
   result.Num:=ord(Sound.IsVoicePlaying(GlobalVoiceID)) and 1;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

// POCA Music API

function POCAMusicManagerCreate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Name,FileName:TpvUTF8String;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Name:='';
  end;
  if ArgumentIndex<aCountArguments then begin
   FileName:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   FileName:='';
  end;
  if assigned(Sounds) then begin
   Music:=Sounds.AddMusic(Name,FileName);
   if assigned(Music) then begin
    Music.Load;
    result:=Music.fPOCAInstanceValue;
   end else begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicManagerFind(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Name:TpvUTF8String;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
   inc(ArgumentIndex);
  end else begin
   Name:='';
  end;
  if assigned(Sounds) then begin
   Music:=Sounds.FindMusic(Name);
   if assigned(Music) then begin
    result:=Music.fPOCAInstanceValue;
   end else begin
    result.CastedUInt64:=POCAValueNullCastedUInt64;
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicManagerRemove(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Name:TpvUTF8String;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  ArgumentIndex:=0;
  if ArgumentIndex<aCountArguments then begin
   if POCAGhostGetType(aArguments[ArgumentIndex])=@POCAMusicGhost then begin
    Music:=POCAGhostFastGetPointer(aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Name:=POCAGetStringValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
    if assigned(Sounds) then begin
     Music:=Sounds.FindMusic(Name);
    end else begin
     Music:=nil;
    end;
   end;
  end else begin
   Music:=nil;
  end;
  if assigned(Sounds) and assigned(Music) then begin
   Sounds.RemoveMusic(Music);
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicManagerClear(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Sounds.fLock.Acquire;
  try
   while Sounds.fMusics.Count>0 do begin
    Sounds.fMusics[Sounds.fMusics.Count-1].Free;
   end;
  finally
   Sounds.fLock.Release;
  end;
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashValid(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  result.Num:=ord(Sounds.fMusicExistHashList.ExistKey(Music)) and 1;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashDestroy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   Music.Free;
   result.Num:=1.0;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashLoad(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  Sounds:=TpvPOCAAudio(aUserData);
  if assigned(Sounds) then begin
   Music:=POCAGhostFastGetPointer(aThis);
   if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
    Music.Load;
    result:=Music.fPOCAInstanceValue;
   end;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashReload(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
  Sounds:=TpvPOCAAudio(aUserData);
  if assigned(Sounds) then begin
   Music:=POCAGhostFastGetPointer(aThis);
   if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
    Music.Reload;
    result:=Music.fPOCAInstanceValue;
   end;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashGetName(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   result:=POCANewString(Sounds.fPOCASubContext,Music.fName);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashGetUID(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   if Music.fUID<=TpvUInt64($001fffffffffffff) then begin
    result:=POCANewNumber(Sounds.fPOCASubContext,Music.fUID);
   end else begin
    result:=POCANewUniqueString(Sounds.fPOCASubContext,Music.fUIDString);
   end;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashGetFileName(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   result:=POCANewString(Sounds.fPOCASubContext,Music.fFileName);
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashPlay(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Volume,Panning,Rate:TpvDouble;
    Loop:boolean;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Volume:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Volume:=1.0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Panning:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Panning:=0.0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Rate:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Rate:=1.0;
   end;
   if ArgumentIndex<aCountArguments then begin
    Loop:=(POCAGetValueType(aArguments[ArgumentIndex])=pvtNUMBER) and (POCAGetNumberValue(aContext,aArguments[ArgumentIndex])<>0.0);
    inc(ArgumentIndex);
   end else begin
    Loop:=false;
   end;
   Music.Play(Volume,Panning,Rate,Loop);
   result:=aThis;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashStop(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   Music.Stop;
   result:=aThis;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashSetVolume(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Volume:TpvDouble;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Volume:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Volume:=1.0;
   end;
   Music.SetVolume(Volume);
   result:=aThis;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashSetPanning(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Panning:TpvDouble;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Panning:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Panning:=0.0;
   end;
   Music.SetPanning(Panning);
   result:=aThis;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashSetRate(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var ArgumentIndex:TPOCAInt32;
    Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
    Rate:TpvDouble;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   ArgumentIndex:=0;
   if ArgumentIndex<aCountArguments then begin
    Rate:=POCAGetNumberValue(aContext,aArguments[ArgumentIndex]);
    inc(ArgumentIndex);
   end else begin
    Rate:=1.0;
   end;
   Music.SetRate(Rate);
   result:=aThis;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

function POCAMusicHashIsPlaying(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Sounds:TpvPOCAAudio;
    Music:TpvPOCAAudio.TMusic;
begin
 if assigned(aUserData) and (TObject(aUserData) is TpvPOCAAudio) and (POCAGhostGetType(aThis)=@POCAMusicGhost) then begin
  Sounds:=TpvPOCAAudio(aUserData);
  Music:=POCAGhostFastGetPointer(aThis);
  if assigned(Music) and Sounds.fMusicExistHashList.ExistKey(Music) then begin
   result.Num:=ord(Music.IsPlaying) and 1;
  end else begin
   result.CastedUInt64:=POCAValueNullCastedUInt64;
  end;
 end else begin
  result.CastedUInt64:=POCAValueNullCastedUInt64;
 end;
end;

{ TpvPOCAAudio.TSound }

constructor TpvPOCAAudio.TSound.Create(const aSounds:TpvPOCAAudio;const aName,aFileName:TpvUTF8String;const aPolyphony:TpvInt32;const aLoop,aRealVoices:TpvInt32;const aFadeOutDuration:TpvDouble);
begin

 inherited Create;

 fPOCAAudio:=aSounds;

 fName:=aName;

 fFileName:=aFileName;

 fReady:=false;

 fPolyphony:=aPolyphony;

 fLoop:=aLoop;

 fRealVoices:=aRealVoices;

 fFadeOutDuration:=aFadeOutDuration;

 fReferenceCounter:=0;

 fPOCAAudio.fUIDFreeListLock.Acquire;
 try
  if not fPOCAAudio.fUIDFreeList.Pop(fUID) then begin
   repeat
    fUID:=TPasMPInterlocked.Increment(fPOCAAudio.fUIDCounter);
   until fUID<>0;
  end;
 finally
  fPOCAAudio.fUIDFreeListLock.Release;
 end;

end;

destructor TpvPOCAAudio.TSound.Destroy;
begin

 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   if assigned(fSoundSample) then begin
    try
     fSoundSample.DecRef;
    finally
     fSoundSample:=nil;
    end;
   end;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;

 if fUID<>0 then begin
  fPOCAAudio.fUIDFreeListLock.Acquire;
  try
   fPOCAAudio.fUIDFreeList.Push(fUID);
  finally
   fPOCAAudio.fUIDFreeListLock.Release;
  end;
 end;

 inherited Destroy;

end;

procedure TpvPOCAAudio.TSound.AfterConstruction;
begin
 inherited AfterConstruction;

 if assigned(fPOCAAudio) then begin

  fPOCAAudio.fLock.Acquire;
  try

   fIndex:=fPOCAAudio.fSounds.Add(self);
   fPOCAAudio.fSoundHashList.Add(fName,self);
   fPOCAAudio.fSoundExistHashList.Add(self,true);

   fPOCAInstanceValue:=POCANewGhost(fPOCAAudio.fPOCASubContext,@POCASoundGhost,self);
   POCAGhostSetHashValue(fPOCAInstanceValue,fPOCAAudio.fPOCASoundGhostHash);
   if fUID<=TpvUInt64($001fffffffffffff) then begin
    fUIDPOCAKeyValue:=POCANewNumber(fPOCAAudio.fPOCASubContext,fUID);
   end else begin
    fUIDPOCAKeyValue:=POCANewUniqueString(fPOCAAudio.fPOCASubContext,fUIDString);
   end;
   POCAHashSet(fPOCAAudio.fPOCASubContext,fPOCAAudio.fPOCASoundHash,fUIDPOCAKeyValue,fPOCAInstanceValue);

   //POCAResetTemporarySaves(fSounds.fPOCASubContext);

  finally
   fPOCAAudio.fLock.Release;
  end;

 end;
end;

procedure TpvPOCAAudio.TSound.BeforeDestruction;
var OtherSound:TSound;
begin
 if assigned(fPOCAAudio) and assigned(fPOCAAudio.fSounds) then begin

  fPOCAAudio.fLock.Acquire;
  try

   if not POCAIsValueNull(fPOCAInstanceValue) then begin
    POCAHashDelete(fPOCAAudio.fPOCASubContext,fPOCAAudio.fPOCASoundHash,fUIDPOCAKeyValue);
    fPOCAInstanceValue:=POCAValueNull;
   end;

   if fIndex>=0 then begin
    try
     if (fIndex+1)<fPOCAAudio.fSounds.Count then begin
      OtherSound:=fPOCAAudio.fSounds[fPOCAAudio.fSounds.Count-1];
      OtherSound.fIndex:=fIndex;
      fPOCAAudio.fSounds[fIndex]:=OtherSound;
      fIndex:=fPOCAAudio.fSounds.Count-1;
     end;
     fPOCAAudio.fSounds.Extract(fIndex);
    finally
     fIndex:=-1;
    end;
    if fPOCAAudio.fSoundHashList.ExistKey(fName) then begin
     fPOCAAudio.fSoundHashList.Delete(fName);
    end;
    if fPOCAAudio.fSoundExistHashList.ExistKey(self) then begin
     fPOCAAudio.fSoundExistHashList.Delete(self);
    end;
   end;

  finally
   fPOCAAudio.fLock.Release;
  end;

 end;

 inherited BeforeDestruction;
end;

procedure TpvPOCAAudio.TSound.IncRef;
begin
 if assigned(self) then begin
  TPasMPInterlocked.Increment(fReferenceCounter);
 end;
end;

procedure TpvPOCAAudio.TSound.DecRef;
begin
 if assigned(self) then begin
  if TPasMPInterlocked.Decrement(fReferenceCounter)=0 then begin
   Free;
  end;
 end;
end;

procedure TpvPOCAAudio.TSound.Load;
begin

 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   if pvApplication.Assets.ExistAsset(fFileName) then begin
    fSoundSample:=pvApplication.Audio.Samples.Load(fName,pvApplication.Assets.GetAssetStream(fFileName),true,fPolyphony,fLoop,fRealVoices);
    fSoundSample.IncRef;
    if fFadeOutDuration>0.0 then begin
     fSoundSample.OnIntervalHook:=SampleOnIntervalHook;
    end;
   end else begin
    fSoundSample:=nil;
   end;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;

end;

procedure TpvPOCAAudio.TSound.Reload;
begin
 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   try
    fSoundSample.DecRef;
   finally
    fSoundSample:=nil;
   end;
   Load;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TSound.UpdateAudio;
begin
end;

function TpvPOCAAudio.TSound.Play(Volume,Panning,Rate:TpvFloat;VoiceIndexPointer:TpvPointer=nil):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) then begin
  result:=pvApplication.Audio.CommandQueue.SampleVoicePlay(fSoundSample,Volume,Panning,Rate);
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.PlaySpatialization(Volume,Panning,Rate:TpvFloat;Spatialization:LongBool;const Position,Velocity:TpvVector3;const Local:LongBool=false;const VoiceIndexPointer:TpvPointer=nil):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) then begin
  result:=pvApplication.Audio.CommandQueue.SampleVoicePlaySpatialization(fSoundSample,Volume,Panning,Rate,Spatialization,Position,Velocity,Local);
 end else begin
  result:=0;
 end;
end;

procedure TpvPOCAAudio.TSound.Stop(GlobalVoiceID:TpvID);
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceStop(GlobalVoiceID);
 end;
end;

procedure TpvPOCAAudio.TSound.KeyOff(GlobalVoiceID:TpvID);
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceKeyOff(GlobalVoiceID);
 end;
end;

function TpvPOCAAudio.TSound.SetVolume(GlobalVoiceID:TpvID;Volume:TpvFloat):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceSetVolume(GlobalVoiceID,Volume);
  result:=GlobalVoiceID;
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.SetPanning(GlobalVoiceID:TpvID;Panning:TpvFloat):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceSetPanning(GlobalVoiceID,Panning);
  result:=GlobalVoiceID;
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.SetRate(GlobalVoiceID:TpvID;Rate:TpvFloat):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceSetRate(GlobalVoiceID,Rate);
  result:=GlobalVoiceID;
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.SetPosition(GlobalVoiceID:TpvID;Spatialization:LongBool;const Origin,Velocity:TpvVector3;const Local:LongBool=false):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceSetPosition(GlobalVoiceID,Spatialization,Origin,Velocity,Local);
  result:=GlobalVoiceID;
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.SetEffectMix(GlobalVoiceID:TpvID;Active:LongBool):TpvID;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  pvApplication.Audio.CommandQueue.SampleVoiceSetEffectMix(GlobalVoiceID,Active);
  result:=GlobalVoiceID;
 end else begin
  result:=0;
 end;
end;

function TpvPOCAAudio.TSound.IsPlaying:boolean;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) then begin
  pvApplication.Audio.Lock;
  try
   result:=fSoundSample.IsPlaying;
  finally
   pvApplication.Audio.Unlock;
  end;
 end else begin
  result:=false;
 end;
end;

function TpvPOCAAudio.TSound.IsVoicePlaying(GlobalVoiceID:TpvID):boolean;
begin
 if assigned(pvApplication.Audio) and assigned(fSoundSample) and (GlobalVoiceID>0) then begin
  result:=pvApplication.Audio.GlobalVoiceManager.CheckGlobalVoiceID(GlobalVoiceID);
 end else begin
  result:=false;
 end;
end;

function TpvPOCAAudio.TSound.SampleOnIntervalHook(const aSampleVoice:TpvAudioSoundSampleVoice;const aDeltaSamples:TpvInt32):boolean;
var v:PpvDouble;
begin
 result:=false;
 if assigned(aSampleVoice) then begin
  if aSampleVoice.KeyOff then begin
   v:=pointer(@aSampleVoice.OtherTag);
   if aSampleVoice.Tag=High(TpvUInt64) then begin
    aSampleVoice.Tag:=0;
    v^:=1.0;
   end;
   if IsZero(v^) then begin
    aSampleVoice.Active:=false;
   end else begin
    v^:=fFadeOutDuration-Min(Max(aSampleVoice.Tag/aSampleVoice.Sample.SampleRate,0.0),fFadeOutDuration);
   end;
   aSampleVoice.DynamicVolume:=Min(Max(trunc(sqr(v^)*32768.0),0),32768);
// aSampleVoice.DynamicRateFactor:=Min(Max(trunc(((sqr(v^)*0.5)+0.5)*65536.0),0),65536);
   aSampleVoice.Tag:=aSampleVoice.Tag+aDeltaSamples;
   result:=true;
  end;
 end;
end;

{ TpvPOCAAudio.TMusic }

constructor TpvPOCAAudio.TMusic.Create(const aSounds:TpvPOCAAudio;const aName,aFileName:TpvUTF8String);
begin

 inherited Create;

 fPOCAAudio:=aSounds;

 fName:=aName;

 fFileName:=aFileName;

 fReady:=false;

 fReferenceCounter:=0;

 fPOCAAudio.fUIDFreeListLock.Acquire;
 try
  if not fPOCAAudio.fUIDFreeList.Pop(fUID) then begin
   repeat
    fUID:=TPasMPInterlocked.Increment(fPOCAAudio.fUIDCounter);
   until fUID<>0;
  end;
 finally
  fPOCAAudio.fUIDFreeListLock.Release;
 end;

end;

destructor TpvPOCAAudio.TMusic.Destroy;
begin

 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   if assigned(fMusic) then begin
    try
     fMusic.Stop;
     fMusic.Free;
    finally
     fMusic:=nil;
    end;
   end;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;

 if fUID<>0 then begin
  fPOCAAudio.fUIDFreeListLock.Acquire;
  try
   fPOCAAudio.fUIDFreeList.Push(fUID);
  finally
   fPOCAAudio.fUIDFreeListLock.Release;
  end;
 end;

 inherited Destroy;

end;

procedure TpvPOCAAudio.TMusic.AfterConstruction;
begin
 inherited AfterConstruction;

 if assigned(fPOCAAudio) then begin

  fPOCAAudio.fLock.Acquire;
  try

   fIndex:=fPOCAAudio.fMusics.Add(self);
   fPOCAAudio.fMusicHashList.Add(fName,self);
   fPOCAAudio.fMusicExistHashList.Add(self,true);

   fPOCAInstanceValue:=POCANewGhost(fPOCAAudio.fPOCASubContext,@POCAMusicGhost,self);
   POCAGhostSetHashValue(fPOCAInstanceValue,fPOCAAudio.fPOCAMusicGhostHash);
   if fUID<=TpvUInt64($001fffffffffffff) then begin
    fUIDPOCAKeyValue:=POCANewNumber(fPOCAAudio.fPOCASubContext,fUID);
   end else begin
    fUIDPOCAKeyValue:=POCANewUniqueString(fPOCAAudio.fPOCASubContext,fUIDString);
   end;

   POCAHashSet(fPOCAAudio.fPOCASubContext,fPOCAAudio.fPOCAMusicHash,fUIDPOCAKeyValue,fPOCAInstanceValue);

  finally
   fPOCAAudio.fLock.Release;
  end;

 end;

end;

procedure TpvPOCAAudio.TMusic.BeforeDestruction;
begin

 if assigned(fPOCAAudio) then begin

  fPOCAAudio.fLock.Acquire;
  try

   POCAHashDelete(fPOCAAudio.fPOCASubContext,fPOCAAudio.fPOCAMusicHash,fUIDPOCAKeyValue);

   fPOCAAudio.fMusicExistHashList.Delete(self);
   fPOCAAudio.fMusicHashList.Delete(fName);
   fPOCAAudio.fMusics.RemoveWithoutFree(self);

  finally
   fPOCAAudio.fLock.Release;
  end;

 end;

 inherited BeforeDestruction;

end;

procedure TpvPOCAAudio.TMusic.IncRef;
begin
 TPasMPInterlocked.Increment(fReferenceCounter);
end;

procedure TpvPOCAAudio.TMusic.DecRef;
begin
 if TPasMPInterlocked.Decrement(fReferenceCounter)=0 then begin
  Free;
 end;
end;

procedure TpvPOCAAudio.TMusic.Load;
begin
 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   if pvApplication.Assets.ExistAsset(fFileName) then begin
    fMusic:=pvApplication.Audio.Musics.Load(fName,pvApplication.Assets.GetAssetStream(fFileName),true);
    fReady:=assigned(fMusic);
   end else begin
    fMusic:=nil;
    fReady:=false;
   end;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.Reload;
begin
 if assigned(pvApplication.Audio) then begin
  pvApplication.Audio.Lock;
  try
   if assigned(fMusic) then begin
    try
     fMusic.Stop;
     fMusic.Free;
    finally
     fMusic:=nil;
    end;
   end;
   Load;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.UpdateAudio;
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   // Music update is handled by audio engine automatically
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.Play(Volume,Panning,Rate:TpvFloat;Loop:boolean);
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   fMusic.Play(Volume,Panning,Rate,Loop);
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.Stop;
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   fMusic.Stop;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.SetVolume(Volume:TpvFloat);
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   fMusic.SetVolume(Volume);
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.SetPanning(Panning:TpvFloat);
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   fMusic.SetPanning(Panning);
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

procedure TpvPOCAAudio.TMusic.SetRate(Rate:TpvFloat);
begin
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   fMusic.SetRate(Rate);
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

function TpvPOCAAudio.TMusic.IsPlaying:boolean;
begin
 result:=false;
 if assigned(pvApplication.Audio) and assigned(fMusic) then begin
  pvApplication.Audio.Lock;
  try
   result:=fMusic.IsPlaying;
  finally
   pvApplication.Audio.Unlock;
  end;
 end;
end;

{ TpvPOCAAudio }

constructor TpvPOCAAudio.Create(const aPOCAInstance:PPOCAInstance);
begin

 inherited Create;

 fPOCAInstance:=aPOCAInstance;

 fLock:=TPasMPCriticalSection.Create;

 fUIDFreeListLock:=TPasMPCriticalSection.Create;

 fUIDFreeList.Initialize;

 fPOCASubContext:=POCAContextCreate(fPOCAInstance);

 fPOCASoundGhostHash:=POCANewHash(fPOCASubContext);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'valid',POCASoundHashValid,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'destroy',POCASoundHashDestroy,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'load',POCASoundHashLoad,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'reload',POCASoundHashReload,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getName',POCASoundHashGetName,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getUID',POCASoundHashGetUID,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getFileName',POCASoundHashGetFileName,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getPolyphony',POCASoundHashGetPolyphony,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getLoop',POCASoundHashGetLoop,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getRealVoices',POCASoundHashGetRealVoices,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'getFadeOutDuration',POCASoundHashGetFadeOutDuration,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'play',POCASoundHashPlay,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'playSpatialization',POCASoundHashPlaySpatialization,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'stop',POCASoundHashStop,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'keyOff',POCASoundHashKeyOff,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'setVolume',POCASoundHashSetVolume,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'setPanning',POCASoundHashSetPanning,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'setRate',POCASoundHashSetRate,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'setPosition',POCASoundHashSetPosition,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'setEffectMix',POCASoundHashSetEffectMix,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'isPlaying',POCASoundHashIsPlaying,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundGhostHash,'isVoicePlaying',POCASoundHashIsVoicePlaying,nil,self);

 fPOCASoundHash:=POCANewHash(fPOCASubContext);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundHash,'create',POCASoundManagerCreate,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundHash,'find',POCASoundManagerFind,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundHash,'remove',POCASoundManagerRemove,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCASoundHash,'clear',POCASoundManagerClear,nil,self);
 POCAHashSetString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'SoundManager',fPOCASoundHash);

 POCAHashSetString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'SoundHash',fPOCASoundGhostHash);

 fPOCAMusicGhostHash:=POCANewHash(fPOCASubContext);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'valid',POCAMusicHashValid,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'destroy',POCAMusicHashDestroy,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'load',POCAMusicHashLoad,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'reload',POCAMusicHashReload,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'getName',POCAMusicHashGetName,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'getUID',POCAMusicHashGetUID,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'getFileName',POCAMusicHashGetFileName,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'play',POCAMusicHashPlay,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'stop',POCAMusicHashStop,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'setVolume',POCAMusicHashSetVolume,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'setPanning',POCAMusicHashSetPanning,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'setRate',POCAMusicHashSetRate,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicGhostHash,'isPlaying',POCAMusicHashIsPlaying,nil,self);

 fPOCAMusicHash:=POCANewHash(fPOCASubContext);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicHash,'create',POCAMusicManagerCreate,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicHash,'find',POCAMusicManagerFind,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicHash,'remove',POCAMusicManagerRemove,nil,self);
 POCAAddNativeFunction(fPOCASubContext,fPOCAMusicHash,'clear',POCAMusicManagerClear,nil,self);
 POCAHashSetString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'MusicManager',fPOCAMusicHash);

 POCAHashSetString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'MusicHash',fPOCAMusicGhostHash);

 fUIDCounter:=0;

 fSoundHashList:=TSoundHashList.Create(nil);

 fSoundExistHashList:=TSoundExistHashList.Create(false);

 fSounds:=TSounds.Create(true);

 fMusicHashList:=TMusicHashList.Create(nil);

 fMusicExistHashList:=TMusicExistHashList.Create(false);

 fMusics:=TMusics.Create(true);

end;

destructor TpvPOCAAudio.Destroy;
begin

 while fMusics.Count>0 do begin
  fMusics[fMusics.Count-1].Free;
 end;
 FreeAndNil(fMusics);

 FreeAndNil(fMusicExistHashList);

 FreeAndNil(fMusicHashList);

 while fSounds.Count>0 do begin
  fSounds[fSounds.Count-1].Free;
 end;
 FreeAndNil(fSounds);

 FreeAndNil(fSoundExistHashList);

 FreeAndNil(fSoundHashList);

 POCAHashDeleteString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'MusicManager');
 POCAHashDeleteString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'MusicHash');
 POCAHashDeleteString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'SoundManager');
 POCAHashDeleteString(fPOCASubContext,fPOCASubContext^.Instance^.Globals.NameSpace,'SoundHash');
 POCAContextDestroy(fPOCASubContext);

 fUIDFreeList.Finalize;

 FreeAndNil(fUIDFreeListLock);

 FreeAndNil(fLock);

 inherited Destroy;

end;

procedure TpvPOCAAudio.Load;
var Index:TpvSizeInt;
begin
 fLock.Acquire;
 try
  for Index:=0 to fSounds.Count-1 do begin
   fSounds[Index].Load;
  end;
  for Index:=0 to fMusics.Count-1 do begin
   fMusics[Index].Load;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvPOCAAudio.UpdateAudio;
var Index:TpvSizeInt;
begin
 fLock.Acquire;
 try
  for Index:=0 to fSounds.Count-1 do begin
   fSounds[Index].UpdateAudio;
  end;
  for Index:=0 to fMusics.Count-1 do begin
   fMusics[Index].UpdateAudio;
  end;
 finally
  fLock.Release;
 end;
end;

function TpvPOCAAudio.Add(const aName,aFileName:TpvUTF8String;const aPolyphony:TpvInt32;const aLoop:TpvInt32;const aRealVoices:TpvInt32;const aFadeOutDuration:TpvDouble):TSound;
begin
 result:=TSound.Create(self,aName,aFileName,aPolyphony,aLoop,aRealVoices,aFadeOutDuration);
end;

function TpvPOCAAudio.Find(const aName:TpvUTF8String):TSound;
begin
 fLock.Acquire;
 try
  if fSoundHashList.ExistKey(aName) then begin
   result:=fSoundHashList[aName];
  end else begin
   result:=nil;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvPOCAAudio.Remove(const aSound:TSound);
begin
 if assigned(aSound) then begin
  aSound.Free;
 end;
end;

procedure TpvPOCAAudio.Remove(const aName:TpvUTF8String);
var Sound:TSound;
begin
 fLock.Acquire;
 try
  Sound:=Find(aName);
  if assigned(Sound) then begin
   Sound.Free;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvPOCAAudio.Clear;
begin
 fLock.Acquire;
 try
  while fMusics.Count>0 do begin
   fMusics[fMusics.Count-1].Free;
  end;
  while fSounds.Count>0 do begin
   fSounds[fSounds.Count-1].Free;
  end;
 finally
  fLock.Release;
 end;
end;

function TpvPOCAAudio.AddMusic(const aName,aFileName:TpvUTF8String):TMusic;
begin
 result:=TMusic.Create(self,aName,aFileName);
end;

function TpvPOCAAudio.FindMusic(const aName:TpvUTF8String):TMusic;
begin
 fLock.Acquire;
 try
  if fMusicHashList.ExistKey(aName) then begin
   result:=fMusicHashList[aName];
  end else begin
   result:=nil;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvPOCAAudio.RemoveMusic(const aMusic:TMusic);
begin
 if assigned(aMusic) then begin
  aMusic.Free;
 end;
end;

procedure TpvPOCAAudio.RemoveMusic(const aName:TpvUTF8String);
var Music:TMusic;
begin
 fLock.Acquire;
 try
  Music:=FindMusic(aName);
  if assigned(Music) then begin
   Music.Free;
  end;
 finally
  fLock.Release;
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure InitializeForPOCAContext(const aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 
 GetMem(HostData,SizeOf(TPOCAHostData));
 FillChar(HostData^,SizeOf(TPOCAHostData),#0);

 HostData^.Instance:=aContext^.Instance;

 aContext^.Instance^.Globals.HostData:=HostData;
 aContext^.Instance^.Globals.HostDataFreeable:=true;

 POCAInitVector2(aContext);

 POCAInitVector3(aContext);

 POCAInitVector4(aContext);

 POCAInitQuaternion(aContext);

 POCAInitMatrix3x3(aContext);

 POCAInitMatrix4x4(aContext);

 POCAInitSprite(aContext);

 POCAInitSpriteAtlas(aContext);

 POCAInitTexture(aContext);

 POCAInitFont(aContext);

 POCAInitCanvasFont(aContext);

 POCAInitCanvasShape(aContext);

 POCAInitCanvas(aContext);

 POCAInitInput(aContext);

end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Finalization
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure FinalizeForPOCAContext(const aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=aContext^.Instance^.Globals.HostData;
 if Assigned(HostData) then begin
  try
   FreeMem(HostData);
  finally
   aContext^.Instance^.Globals.HostData:=nil;
  end; 
 end;
end;

initialization
 POCAVector2GhostPointer:=@POCAVector2Ghost;
 POCAVector3GhostPointer:=@POCAVector3Ghost;
 POCAVector4GhostPointer:=@POCAVector4Ghost;
 POCAQuaternionGhostPointer:=@POCAQuaternionGhost;
 POCAMatrix3x3GhostPointer:=@POCAMatrix3x3Ghost;
 POCAMatrix4x4GhostPointer:=@POCAMatrix4x4Ghost;
 POCASpriteGhostPointer:=@POCASpriteGhost;
 POCASpriteAtlasGhostPointer:=@POCASpriteAtlasGhost;
 POCATextureGhostPointer:=@POCATextureGhost;
 POCAFontGhostPointer:=@POCAFontGhost;
 POCACanvasFontGhostPointer:=@POCACanvasFontGhost;
 POCACanvasGhostPointer:=@POCACanvasGhost;
end.
