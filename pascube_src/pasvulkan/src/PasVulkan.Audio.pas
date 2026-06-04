(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                        Version 2017-07-13-03-19-0000                       *
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
 unit PasVulkan.Audio;
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

uses {$ifdef windows}Windows,{$endif}SysUtils,Classes,Math,SyncObjs,
     PasMP,
     PasJSON,
     PasVulkan.Types,
     {$ifdef UseExternalOGGVorbisTremorLibrary}
      PasVulkan.Audio.OGGVorbisTremor.ExternalLibrary,
     {$else}
      PasVulkan.Audio.OGGVorbisTremor,
     {$endif}
     PasVulkan.Collections,
     PasVulkan.RandomGenerator,
     PasVulkan.Math,
     PasVulkan.Utils,
     PasVulkan.Audio.HRTFTables,
     PasVulkan.IDManager,
     PasVulkan.Resources;

const SampleFixUp=1024;

      SoundLoopModeNONE=0;
      SoundLoopModeFORWARD=1;
      SoundLoopModePINGPONG=2;
      SoundLoopModeBACKWARD=3;

      FixedPointBits=12;
      FixedPointFactor=1 shl FixedPointBits;

      ResamplerFixedPointBits=32;
      ResamplerFixedPointFactor=TpvInt64($100000000);
      ResamplerFixedPointMask=TpvUInt32($ffffffff);

      ResamplerEpsilon:TpvFloat=1e-12;

      ResamplerSINCValueBits=15;
      ResamplerSINCValueLength=1 shl ResamplerSINCValueBits;
      ResamplerSINCFracBits=12;
      ResamplerSINCLength=1 shl ResamplerSINCFracBits;
      ResamplerSINCWidthBits=3;
      ResamplerSINCWidth=1 shl ResamplerSINCWidthBits;
      ResamplerSINCFracShift=ResamplerFixedPointBits-ResamplerSINCFracBits;
      ResamplerSINCFracMask=(1 shl ResamplerSINCFracShift)-1;

      ResamplerCubicSplineValueBits=12;
      ResamplerCubicSplineValueLength=1 shl ResamplerCubicSplineValueBits;
      ResamplerCubicSplineFracBits=12;
      ResamplerCubicSplineLength=1 shl ResamplerCubicSplineFracBits;
      ResamplerCubicSplineFracShift=ResamplerFixedPointBits-ResamplerCubicSplineFracBits;
      ResamplerCubicSplineFracMask=ResamplerCubicSplineLength-1;

      ResamplerLinearInterpolationValueBits=12;
      ResamplerLinearInterpolationValueLength=1 shl ResamplerLinearInterpolationValueBits;
      ResamplerLinearInterpolationFracBits=12;
      ResamplerLinearInterpolationLength=1 shl ResamplerLinearInterpolationFracBits;
      ResamplerLinearInterpolationFracShift=ResamplerFixedPointBits-ResamplerLinearInterpolationFracBits;
      ResamplerLinearInterpolationFracMask=ResamplerLinearInterpolationLength-1;

      ResamplerBufferBits=12;
      ResamplerBufferSize=1 shl ResamplerBufferBits;
      ResamplerBufferMask=ResamplerBufferSize-1;

      WorldUnitsToMeters=1.0;

      MetersToWorldUnits=1.0;

      WorldUnitsToSoundUnits=WorldUnitsToMeters;

{     DopplerFactor=1.0;
      DopplerVelocity=2200.0;}

      DopplerFactor=WorldUnitsToSoundUnits;
      DopplerVelocity=1.0;

      SpeedOfSoundAir=343.3;
      SpeedOfSoundUnderwater=1522.0; //(1484+1560)*0.5;

      SpeedOfSoundAirToUnderwater=SpeedOfSoundAir/SpeedOfSoundUnderwater;

      HalfPanning=0.707106; // sin(HalfPI*0.5)

      HF_DAMP=0.25;
      HF_DAMP_HALF=HF_DAMP*0.5;
      HF_DAMP_FACTOR=1.0-(HF_DAMP*0.25);
      HF_FREQUENCY=3300;

      MinAbsorptionDistance=16;
      MaxAbsorptionDistance=4096;

      AirAbsorptionGainHF=0.99426; // -0.05dB
      AirAbsorptionFactor=0.1;

      // ear-to-ear-distance about 15-20mm
      EAR_DELAY_AIR=(((0.15+0.20)*0.5)/SpeedOfSoundAir)*1000.0;
      EAR_DELAY_UNDERWATER=(((0.15+0.20)*0.5)/SpeedOfSoundUnderwater)*1000.0;

      WATER_LOWPASS_FREQUENCY=300;

      WATER_BOOST_START_FREQUENCY=500;
      WATER_BOOST_END_FREQUENCY=1000;
      WATER_BOOST_FACTOR=4.0;

      LowPassBits=14;
      LowPassLength=1 shl LowPassBits;
      LowPassShift=16;
      LowPassShiftLength=1 shl LowPassShift;

      SpatializationDelayShift=16;
      SpatializationDelayLength=1 shl SpatializationDelayShift;
      SpatializationDelayMask=SpatializationDelayLength-1;

      MaxReverbAllPassFilters=16;

      PitchShifterOutputShift=12;
      PitchShifterOutputLen=1 shl PitchShifterOutputShift;

      PitchShifterBufferShift=10;
      PitchShifterBufferSize=1 shl PitchShifterBufferShift;
      PitchShifterBufferMask=PitchShifterBufferSize-1;

      SPATIALIZATION_NONE=0;
      SPATIALIZATION_PSEUDO=1;
      SPATIALIZATION_HRTF=2;

      MaxAudioSpeakerLayoutListeners=8;

type PpvAudioInt32=^TpvInt32;

     PPPpvAudioInt32s=^TPPpvAudioInt32s;
     PPpvAudioInt32s=^TPpvAudioInt32s;
     PpvAudioInt32s=^TpvAudioInt32s;
     TPPpvAudioInt32s=array[0..$ffff] of PPpvAudioInt32s;
     TPpvAudioInt32s=array[0..$ffff] of PpvAudioInt32s;
     TpvAudioInt32s=array[0..$ffff] of TpvInt32;

     TpvAudioFloat=TpvFloat;
     PpvAudioFloat=PpvFloat;

     TpvAudioFloats=array[0..$ffff] of TpvFloat;
     PpvAudioFloats=^TpvAudioFloats;

     TPpvAudioFloats=array[0..$ffff] of PpvAudioFloats;
     PPpvAudioFloats=^TPpvAudioFloats;

     TpvAudioSoundSampleValue=TpvInt32;
     PpvAudioSoundSampleValue=^TpvAudioSoundSampleValue;

     TpvAudioSoundSampleStereoValue=array[0..1] of TpvInt32;
     PpvAudioSoundSampleStereoValue=^TpvAudioSoundSampleStereoValue;

     TpvAudioSoundSampleValues=array[0..($7ffffff0 div sizeof(TpvAudioSoundSampleValue))-1] of TpvAudioSoundSampleValue;
     PpvAudioSoundSampleValues=^TpvAudioSoundSampleValues;

     PpvAudioSoundSampleLoop=^TpvAudioSoundSampleLoop;
     TpvAudioSoundSampleLoop=record
      Mode:TpvInt32;
      StartSample:TpvInt32;
      EndSample:TpvInt32;
     end;

     TpvAudioSoundSample=class;

     TpvAudio=class;

     TpvAudioSpeakerLayoutListener=record
      public
       Index:TpvInt32;
       YawAngle:TpvScalar;
       DotScale:TpvScalar;
       DotBias:TpvScalar;
       AmbientVolume:TpvScalar;
     end;
     PpvAudioSpeakerLayoutListener=^TpvAudioSpeakerLayoutListener;

     TpvAudioSpeakerLayout=record
      public
       Name:TpvUTF8String;
       CountChannels:TpvInt32;
       Listeners:array[0..MaxAudioSpeakerLayoutListeners-1] of TpvAudioSpeakerLayoutListener;
     end;
     PpvAudioSpeakerLayout=^TpvAudioSpeakerLayout;

     TpvAudioStringHashMap=class(TpvStringHashMap<TpvPointer>);

     TpvAudioHRTFCoefs=array[0..HRIR_MAX_LENGTH-1] of TpvInt32;

     TpvAudioHRTFHistory=array[0..HRIR_MAX_LENGTH-1] of TpvInt32;

     TpvAudioWAVFormat=class
      public
       type TWaveSignature=array[1..4] of ansichar;
            TWaveFileHeader=packed record
             Signature:TWaveSignature;
             Size:TpvUInt32;
             WAVESignature:TWaveSignature;
            end;
            PWaveFileHeader=^TWaveFileHeader;
            TWaveFormatHeader=packed record
             FormatTag:TpvUInt16;
             Channels:TpvUInt16;
             SamplesPerSecond:TpvUInt32;
             AvgBytesPerSecond:TpvUInt32;
             SampleSize:TpvUInt16;
             BitsPerSample:TpvUInt16;
            end;
            PWaveFormatHeader=^TWaveFormatHeader;
            TWaveChunkHeader=packed record
             Signature:TWaveSignature;
             Size:TpvUInt32;
            end;
            PWaveChunkHeader=^TWaveChunkHeader;
       const RIFFSignature:TWaveSignature=('R','I','F','F');
             WAVESignature:TWaveSignature=('W','A','V','E');
             FMTSignature:TWaveSignature=('f','m','t',' ');
             DATASignature:TWaveSignature=('d','a','t','a');
     end;

     TpvAudioWAVStreamDump=class
      private
       fAudioEngine:TpvAudio;
       fStream:TStream;
       fDoFreeStream:boolean;
       fSampleRate:TpvInt32;
       fChannels:TpvInt32;
       fBitsPerSample:TpvInt32;
       fDataOffset:TpvInt64;
       fDataSize:TpvInt64;
       fFileHeaderOffset:TpvInt64;
       fFormatChunkHeaderOffset:TpvInt64;
       fDataChunkHeaderOffset:TpvInt64;
       fWaveFileHeader:TpvAudioWAVFormat.TWaveFileHeader;
       fWaveFormatChunkHeader:TpvAudioWAVFormat.TWaveChunkHeader;
       fWaveFormatHeader:TpvAudioWAVFormat.TWaveFormatHeader;
       fWaveDataChunkHeader:TpvAudioWAVFormat.TWaveChunkHeader;
       fBufferFloats:TpvFloatDynamicArray;
      public
       constructor Create(const aAudioEngine:TpvAudio;const aStream:TStream;const aDoFreeStream:boolean=true);
       destructor Destroy; override;
       procedure Flush;
       procedure Dump(const aData:TpvPointer;const aDataSize:TpvSizeInt);
     end;

     TpvAudioSoundSampleVoiceLowPassHistory=array[0..1] of TpvInt32;

     TpvAudioSoundSampleVoice=class;

     TpvAudioSoundSampleVoiceOnIntervalHook=function(const aSampleVoice:TpvAudioSoundSampleVoice;const aDeltaSamples:TpvInt32):boolean of object;

     { TpvAudioSoundSampleVoice }

     TpvAudioSoundSampleVoice=class
      private
       fPrevious:TpvAudioSoundSampleVoice;
       fNext:TpvAudioSoundSampleVoice;
       fNextFree:TpvAudioSoundSampleVoice;
       fIsOnList:LongBool;
       fActiveVoiceIndex:TpvInt32;
       fAudioEngine:TpvAudio;
       fSample:TpvAudioSoundSample;
       fIndex:TpvInt32;
       fMixToEffect:LongBool;
       fActive:LongBool;
       fKeyOff:LongBool;
       fBackwards:LongBool;
       fVolume:TpvInt32;
       fPanning:TpvInt32;
       fAge:TpvInt64;
       fListenerGeneration:TpvUInt64;
       fPosition:TpvInt64;
       fDynamicRateFactor:TpvInt32;
       fTargetIncrement:TpvInt64;
       fIncrement:TpvInt64;
       fIncrementLast:TpvInt64;
       fIncrementCurrent:TpvInt64;
       fIncrementIncrement:TpvInt64;
       fIncrementRampingRemain:TpvInt32;
       fIncrementRampingStepRemain:TpvInt32;
       fMixIncrement:TpvInt64;
       fRampingSamples:TpvInt32;
       fMulLeft:TpvInt32;
       fMulRight:TpvInt32;
       fDynamicVolume:TpvInt32;
       fVolumeLeft:TpvInt32;
       fVolumeRight:TpvInt32;
       fVolumeLeftLast:TpvInt32;
       fVolumeRightLast:TpvInt32;
       fVolumeLeftCurrent:TpvInt32;
       fVolumeRightCurrent:TpvInt32;
       fVolumeLeftIncrement:TpvInt32;
       fVolumeRightIncrement:TpvInt32;
       fVolumeRampingRemain:TpvInt32;
       fHRTFLeftCoefs:TpvAudioHRTFCoefs;
       fHRTFRightCoefs:TpvAudioHRTFCoefs;
       fHRTFLeftCoefsCurrent:TpvAudioHRTFCoefs;
       fHRTFRightCoefsCurrent:TpvAudioHRTFCoefs;
       fHRTFLeftCoefsIncrement:TpvAudioHRTFCoefs;
       fHRTFRightCoefsIncrement:TpvAudioHRTFCoefs;
       fHRTFLeftHistory:TpvAudioHRTFHistory;
       fHRTFRightHistory:TpvAudioHRTFHistory;
       fHRTFHistoryIndex:TpvInt32;
       fHRTFLeftDelay:TpvInt32;
       fHRTFRightDelay:TpvInt32;
       fHRTFLeftDelayCurrent:TpvInt32;
       fHRTFRightDelayCurrent:TpvInt32;
       fHRTFLeftDelayLast:TpvInt32;
       fHRTFRightDelayLast:TpvInt32;
       fHRTFLeftDelayIncrement:TpvInt32;
       fHRTFRightDelayIncrement:TpvInt32;
       fHRTFCounter:TpvInt32;
       fHRTFRampingRemain:TpvInt32;
       fHRTFRampingStepRemain:TpvInt32;
       fHRTFLength:TpvInt32;
       fHRTFMask:TpvInt32;
       fSpatialization:LongBool;
       fSpatializationLocal:LongBool;
       fSpatializationHasContent:LongBool;
       fSpatializationOrigin:TpvVector3;
       fSpatializationVelocity:TpvVector3;
       fSpatializationVolumeLast:TpvFloat;
       fSpatializationDelayLeft:TpvInt32;
       fSpatializationDelayRight:TpvInt32;
       fSpatializationDelayLeftIndex:TpvInt32;
       fSpatializationDelayRightIndex:TpvInt32;
       fSpatializationDelayLeftLast:TpvInt32;
       fSpatializationDelayRightLast:TpvInt32;
       fSpatializationDelayLeftCurrent:TpvInt32;
       fSpatializationDelayRightCurrent:TpvInt32;
       fSpatializationDelayLeftIncrement:TpvInt32;
       fSpatializationDelayRightIncrement:TpvInt32;
       fSpatializationDelayRampingRemain:TpvInt32;
       fSpatializationDelayLeftLine:array of TpvInt32;
       fSpatializationDelayRightLine:array of TpvInt32;
       fSpatializationLowPassLeftCoef:TpvInt32;
       fSpatializationLowPassRightCoef:TpvInt32;
       fSpatializationLowPassLeftLastCoef:TpvInt32;
       fSpatializationLowPassRightLastCoef:TpvInt32;
       fSpatializationLowPassLeftCurrentCoef:TpvInt32;
       fSpatializationLowPassRightCurrentCoef:TpvInt32;
       fSpatializationLowPassLeftIncrementCoef:TpvInt32;
       fSpatializationLowPassRightIncrementCoef:TpvInt32;
       fSpatializationLowPassLeftHistory:TpvAudioSoundSampleVoiceLowPassHistory;
       fSpatializationLowPassRightHistory:TpvAudioSoundSampleVoiceLowPassHistory;
       fSpatializationLowPassRampingRemain:TpvInt32;
       fLastDirection:TpvVector3;
       fLastLeft:TpvInt32;
       fLastRight:TpvInt32;
       fNewLastLeft:TpvInt32;
       fNewLastRight:TpvInt32;
       fRate:TpvFloat;
       fDopplerRate:TpvFloat;
       fLastElevation:TpvFloat;
       fLastAzimuth:TpvFloat;
       fVoiceIndexPointer:TpvPointer;
       fGlobalVoiceID:TpvID;
       fVolumeSquaredMagnitude:TpvFloat;
       fReadyToPutIntoSleep:Boolean;
       fTag:TpvUInt64;
       fOtherTag:TpvUInt64;
       fCurrentOnIntervalHook:TpvAudioSoundSampleVoiceOnIntervalHook;
       fOnIntervalHook:TpvAudioSoundSampleVoiceOnIntervalHook;
       fOnIntervalHookSampleCounter:TpvInt32;
       fOnIntervalHookTotalSampleCounter:TpvInt64;
       fOnIntervalHookLastTotalSampleCounter:TpvInt64;
       procedure UpdateSpatialization;
       function GetSampleLength(CountSamplesValue:TpvInt32):TpvInt32;
       procedure PreClickRemoval(Buffer:TpvPointer);
       procedure PostClickRemoval(Buffer:TpvPointer;Remain:TpvInt32);
       procedure MixProcSpatializationHRTF(Buffer:TpvPointer;ToDo:TpvInt32);
       procedure MixProcSpatializationPSEUDO(Buffer:TpvPointer;ToDo:TpvInt32);
       procedure MixProcVolumeRamping(Buffer:TpvPointer;ToDo:TpvInt32);
       procedure MixProcNormal(Buffer:TpvPointer;ToDo:TpvInt32);
       procedure UpdateIncrementRamping;
       procedure UpdateTargetVolumes(aMixVolume:TpvInt32);
       procedure UpdateVolumeRamping(aMixVolume:TpvInt32);
       procedure UpdateSpatializationDelayRamping;
       procedure UpdateSpatializationLowPassRamping;
      public
       constructor Create(aAudioEngine:TpvAudio;aSample:TpvAudioSoundSample;aIndex:TpvInt32);
       destructor Destroy; override;
       procedure Enqueue;
       procedure Dequeue;
       procedure Init(aVolume,aPanning,aRate:TpvFloat);
       procedure Prepare;
       procedure MixTo(aBuffer:PpvAudioSoundSampleValues;aMixVolume:TpvInt32;const aRealVoice:Boolean);
      public
       property AudioEngine:TpvAudio read fAudioEngine;
       property Sample:TpvAudioSoundSample read fSample;
       property Tag:TpvUInt64 read fTag write fTag;
       property OtherTag:TpvUInt64 read fOtherTag write fOtherTag;
       property DynamicRateFactor:TpvInt32 read fDynamicRateFactor write fDynamicRateFactor;
       property DynamicVolume:TpvInt32 read fDynamicVolume write fDynamicVolume;
       property Active:LongBool read fActive write fActive;
       property Age:TpvInt64 read fAge;
       property Position:TpvInt64 read fPosition;
      published
       property KeyOff:LongBool read fKeyOff;
       property OnIntervalHook:TpvAudioSoundSampleVoiceOnIntervalHook read fOnIntervalHook write fOnIntervalHook;
     end;

     TpvAudioSoundSampleVoices=array of TpvAudioSoundSampleVoice;

     TpvAudioSoundSamples=class;

     TpvAudioSoundSampleGlobalVoice=record
      public
       SoundSample:TpvAudioSoundSample;
       VoiceNumber:TpvInt32;
       constructor Create(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
     end;
     PpvAudioSoundSampleGlobalVoice=^TpvAudioSoundSampleGlobalVoice;

     TpvAudioSoundSampleGlobalVoices=array of TpvAudioSoundSampleGlobalVoice;

     TpvAudioSoundSampleGlobalVoiceIDs=array of TpvID;

     TpvAudioSoundSampleGlobalVoiceHashMap=class(TpvHashMap<TpvAudioSoundSampleGlobalVoice,TpvID>);

     { TpvAudioSoundSampleGlobalVoiceManager }

     TpvAudioSoundSampleGlobalVoiceManager=class
      private
       fAudioEngine:TpvAudio;
       fLock:TPasMPMultipleReaderSingleWriterLock;
       fGlobalVoices:TpvAudioSoundSampleGlobalVoices;
       fGlobalVoiceIDs:TpvAudioSoundSampleGlobalVoiceIDs;
       fIDManager:TpvIDManager;
       fHashMap:TpvAudioSoundSampleGlobalVoiceHashMap;
      public
       constructor Create(aAudioEngine:TpvAudio);
       destructor Destroy; override;
       function GetGlobalVoiceID(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32):TpvID;
       function GetGlobalVoice(const aGlobalVoiceID:TpvID):TpvAudioSoundSampleGlobalVoice;
       function AllocateGlobalVoice(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32=-1):TpvID;
       procedure SetGlobalVoice(const aGlobalVoiceID:TpvID;const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
       procedure DeallocateGlobalVoice(const aGlobalVoiceID:TpvID); overload;
       procedure DeallocateGlobalVoice(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32); overload;
       procedure DeallocateAllGlobalVoicesForSoundSample(const aSoundSample:TpvAudioSoundSample);
       function CheckGlobalVoiceID(const aGlobalVoiceID:TpvID):Boolean;
     end;

     { TpvAudioCompressor }
     TpvAudioCompressor=class
      public
       type TSettings=class
             private
              fThreshold:TpvDouble;
              fAttackTime:TpvDouble;
              fHoldTime:TpvDouble;
              fReleaseTime:TpvDouble;
              fRatio:TpvDouble;
              fKnee:TpvDouble;
              fMakeUpGain:TpvDouble;
              fAutoGain:Boolean;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure AssignFromJSON(const aJSON:TPasJSONItem);
              procedure Assign(const aSettings:TSettings);
             public
              property Threshold:TpvDouble read fThreshold write fThreshold;
              property AttackTime:TpvDouble read fAttackTime write fAttackTime;
              property HoldTime:TpvDouble read fHoldTime write fHoldTime;
              property ReleaseTime:TpvDouble read fReleaseTime write fReleaseTime;
              property Ratio:TpvDouble read fRatio write fRatio;
              property Knee:TpvDouble read fKnee write fKnee;
              property MakeUpGain:TpvDouble read fMakeUpGain write fMakeUpGain;
              property AutoGain:Boolean read fAutoGain write fAutoGain;
            end;
      private
       fAudioEngine:TpvAudio;
       fHoldTimeSampleCounter:TpvInt32;
       fState:TpvFloat;
       fPeakState:TpvFloat;
       fThreshold:TpvFloat;
       fAttackCoefficient:TpvFloat;
       fHoldTimeSampleDuration:TpvInt32;
       fReleaseCoefficient:TpvFloat;
       fRatio:TpvFloat;
       fOneMinusRatio:TpvFloat;
       fRatioFactor:TpvFloat;
       fKneedB:TpvFloat;
       fKneeFactor:TpvFloat;
       fKneeSign:TpvFloat;
       fThresholddBFactor:TpvFloat;
       fOutputGainFactor:TpvFloat;
       fFirst:LongBool;
       fSettings:TSettings;
      public
       constructor Create(aAudioEngine:TpvAudio); reintroduce;
       destructor Destroy; override;
       procedure Setup(const aSettings:TSettings);
       function Process(const aInput:TpvFloat):TpvFloat;
     end;

     TpvAudioDistanceModel=
      (
       NoAttenuation,
       InverseDistance,
       InverseDistanceClamped,
       LinearDistance,
       LinearDistanceClamped,
       ExponentDistance,
       ExponentDistanceClamped
      );

     TpvAudioSoundSample=class
      public
       AudioEngine:TpvAudio;
       SoundSamples:TpvAudioSoundSamples;
       Name:TpvRawByteString;
       Data:PpvAudioSoundSampleValues;
       SampleLength:TpvInt32;
       SampleRate:TpvInt32;
       Loop:TpvAudioSoundSampleLoop;
       SustainLoop:TpvAudioSoundSampleLoop;
       Voices:TpvAudioSoundSampleVoices;
       ActiveVoices:TpvAudioSoundSampleVoices;
       CountActiveVoices:TpvInt32;
       ReferenceCounter:TpvInt32;
       SampleVirtualVoices:TpvInt32;
       SampleRealVoices:TpvInt32;
       ReservedVoiceIDCounter:TPasMPInt32;
       DistanceModel:TpvAudioDistanceModel;
       MinDistance:TpvFloat;
       MaxDistance:TpvFloat;
       AttenuationRollOff:TpvFloat;
       FreeVoice:TpvAudioSoundSampleVoice;
       MixingBuffer:PpvAudioSoundSampleValues;
       MixToEffect:LongBool;
       Sleepable:LongBool;
       CompressorActive:LongBool;
       Compressor:TpvAudioCompressor;
       CompressorSettings:TpvAudioCompressor.TSettings;
      private
       fOnIntervalHook:TpvAudioSoundSampleVoiceOnIntervalHook;
      public
       constructor Create(aAudioEngine:TpvAudio;aSoundSamples:TpvAudioSoundSamples);
       destructor Destroy; override;
       procedure IncRef;
       procedure DecRef;
       function GetReservedVoiceID:TpvInt32;
       procedure CorrectVoices;
       procedure FixUp;
       procedure SetVirtualVoices(aVirtualVoices:TpvInt32);
       procedure SetRealVoices(aRealVoices:TpvInt32);
       function Play(aVolume,aPanning,aRate:TpvFloat;aVoiceIndexPointer:TpvPointer=nil;aPerreservedGlobalVoiceID:TpvID=0):TpvInt32;
       function PlaySpatialization(aVolume,aPanning,aRate:TpvFloat;aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const Local:LongBool=false;const aVoiceIndexPointer:TpvPointer=nil;aPerreservedGlobalVoiceID:TpvID=0):TpvInt32;
       procedure RandomReseek(aVoiceNumber:TpvInt32);
       procedure ResetLoop(aVoiceNumber:TpvInt32);
       procedure Stop(aVoiceNumber:TpvInt32);
       procedure KeyOff(aVoiceNumber:TpvInt32);
       function SetVolume(aVoiceNumber:TpvInt32;aVolume:TpvFloat):TpvInt32;
       function SetPanning(aVoiceNumber:TpvInt32;aPanning:TpvFloat):TpvInt32;
       function SetRate(aVoiceNumber:TpvInt32;aRate:TpvFloat):TpvInt32;
       function SetPosition(aVoiceNumber:TpvInt32;aSpatialization:LongBool;const aOrigin,aVelocity:TpvVector3;const aLocal:LongBool=false):TpvInt32;
       function SetEffectMix(aVoiceNumber:TpvInt32;aActive:LongBool):TpvInt32;
       function IsPlaying:boolean;
       function IsVoicePlaying(aVoiceNumber:TpvInt32):boolean;
      public
       property OnIntervalHook:TpvAudioSoundSampleVoiceOnIntervalHook read fOnIntervalHook write fOnIntervalHook;
     end;

     PpvAudioSoundMusicBufferSample=^TpvAudioSoundMusicBufferSample;
     TpvAudioSoundMusicBufferSample=record
      Left,Right:TpvInt32;
     end;

     TpvAudioResamplerBuffer=array[0..ResamplerBufferSize-1] of TpvAudioSoundMusicBufferSample;

     PpvAudioResamplerCubicSplineSubArray=^TpvAudioResamplerCubicSplineSubArray;
     TpvAudioResamplerCubicSplineSubArray=packed array[0..3] of TpvInt32;

     PpvAudioResamplerCubicSplineArray=^TpvAudioResamplerCubicSplineArray;
     TpvAudioResamplerCubicSplineArray=packed array[0..ResamplerCubicSplineLength-1] of TpvAudioResamplerCubicSplineSubArray;

     PpvAudioResamplerSINCSubArray=^TpvAudioResamplerSINCSubArray;
     TpvAudioResamplerSINCSubArray=packed array[0..ResamplerSINCWidth-1] of TpvInt32;

     PpvAudioResamplerSINCArray=^TpvAudioResamplerSINCArray;
     TpvAudioResamplerSINCArray=packed array[0..ResamplerSINCLength-1] of TpvAudioResamplerSINCSubArray;

     TpvAudioSoundMusics=class;

     TpvAudioSoundMusic=class
      public
       AudioEngine:TpvAudio;
       SoundMusics:TpvAudioSoundMusics;
       Name:TpvRawByteString;
       Data:TStream;
       Active:LongBool;
       Loop:LongBool;
       KeyOff:LongBool;
       Volume:TpvInt32;
       VolumeLeft:TpvInt32;
       VolumeRight:TpvInt32;
       VolumeLeftCurrent:TpvInt32;
       VolumeRightCurrent:TpvInt32;
       VolumeLeftInc:TpvInt32;
       VolumeRightInc:TpvInt32;
       Panning:TpvInt32;
       VolumeRampingRemain:TpvInt32;
       Age:TpvInt64;
       Position:TpvInt64;
       Increment:TpvInt64;
       LastLeft:TpvInt32;
       LastRight:TpvInt32;
       NewLastLeft:TpvInt32;
       NewLastRight:TpvInt32;
       ResamplerBuffer:TpvAudioResamplerBuffer;
       ResamplerBufferPosition:TpvInt32;
       ResamplerCurrentSample:TpvAudioSoundMusicBufferSample;
       ResamplerLastSample:TpvAudioSoundMusicBufferSample;
       ResamplerPosition:TpvInt64;
       ResamplerIncrement:TpvInt64;
       ResamplerOriginalIncrement:TpvInt64;
       OutBuffer:array[0..4095] of TpvAudioSoundMusicBufferSample;
       OutBufferPosition:TpvInt32;
       OutBufferSize:TpvInt32;
       InBuffer:array[0..4095] of TpvAudioSoundMusicBufferSample;
       InBufferPosition:TpvInt32;
       InBufferSize:TpvInt32;
       PCMBuffer:array [0..65535] of smallint;
       Channels:TpvInt32;
       SampleRate:TpvInt32;
       BitStream:TpvInt32;
       LastSample:TpvAudioSoundMusicBufferSample;
       Table:TpvAudioResamplerSINCArray;
       vf:POggVorbis_File;
       constructor Create(AAudioEngine:TpvAudio;ASoundMusics:TpvAudioSoundMusics);
       destructor Destroy; override;
       procedure InitSINC;
       procedure Play(AVolume,APanning,ARate:TpvFloat;ALoop:boolean);
       procedure Stop;
       procedure SetVolume(AVolume:TpvFloat);
       procedure SetPanning(APanning:TpvFloat);
       procedure SetRate(ARate:TpvFloat);
       procedure GetNextInBuffer;
       procedure Resample;
       procedure MixTo(Buffer:PpvAudioSoundSampleValues;MixVolume:TpvInt32);
       function IsPlaying:boolean;
     end;

     IpvAudioSoundSampleResource=interface(IpvResource)['{9E4ABC9F-7EBE-49D8-BD78-146A875F44FF}']
      procedure FixUp;
      procedure SetVirtualVoices(VirtualVoices:TpvInt32);
      procedure SetRealVoices(RealVoices:TpvInt32);
      function Play(Volume,Panning,Rate:TpvFloat;VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
      function PlaySpatialization(Volume,Panning,Rate:TpvFloat;Spatialization:LongBool;const Position,Velocity:TpvVector3;const Local:LongBool=false;const VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
      procedure RandomReseek(VoiceNumber:TpvInt32);
      procedure ResetLoop(VoiceNumber:TpvInt32);
      procedure Stop(VoiceNumber:TpvInt32);
      procedure KeyOff(VoiceNumber:TpvInt32);
      function SetVolume(VoiceNumber:TpvInt32;Volume:TpvFloat):TpvInt32;
      function SetPanning(VoiceNumber:TpvInt32;Panning:TpvFloat):TpvInt32;
      function SetRate(VoiceNumber:TpvInt32;Rate:TpvFloat):TpvInt32;
      function SetPosition(VoiceNumber:TpvInt32;Spatialization:LongBool;const Origin,Velocity:TpvVector3;const Local:LongBool=false):TpvInt32;
      function SetEffectMix(VoiceNumber:TpvInt32;Active:LongBool):TpvInt32;
      function IsPlaying:boolean;
      function IsVoicePlaying(VoiceNumber:TpvInt32):boolean;
     end;

     TpvAudioSoundSampleResource=class(TpvResource,IpvAudioSoundSampleResource)
      private
       fSample:TpvAudioSoundSample;
      public
       constructor Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource=nil;const aMetaResource:TpvMetaResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None); override;
       destructor Destroy; override;
       function BeginLoad(const aStream:TStream):boolean; override;
       procedure FixUp;
       procedure SetVirtualVoices(VirtualVoices:TpvInt32);
       procedure SetRealVoices(RealVoices:TpvInt32);
       function Play(Volume,Panning,Rate:TpvFloat;VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
       function PlaySpatialization(Volume,Panning,Rate:TpvFloat;Spatialization:LongBool;const Position,Velocity:TpvVector3;const Local:LongBool=false;const VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
       procedure RandomReseek(VoiceNumber:TpvInt32);
       procedure ResetLoop(VoiceNumber:TpvInt32);
       procedure Stop(VoiceNumber:TpvInt32);
       procedure KeyOff(VoiceNumber:TpvInt32);
       function SetVolume(VoiceNumber:TpvInt32;Volume:TpvFloat):TpvInt32;
       function SetPanning(VoiceNumber:TpvInt32;Panning:TpvFloat):TpvInt32;
       function SetRate(VoiceNumber:TpvInt32;Rate:TpvFloat):TpvInt32;
       function SetPosition(VoiceNumber:TpvInt32;Spatialization:LongBool;const Origin,Velocity:TpvVector3;const Local:LongBool=false):TpvInt32;
       function SetEffectMix(VoiceNumber:TpvInt32;Active:LongBool):TpvInt32;
       function IsPlaying:boolean;
       function IsVoicePlaying(VoiceNumber:TpvInt32):boolean;
      published
       property Sample:TpvAudioSoundSample read fSample;
     end;

     IpvAudioSoundMusicResource=interface(IpvResource)['{4F43005B-109A-4DF4-808E-4ECAA3BF00A6}']
      procedure Play(AVolume,APanning,ARate:TpvFloat;ALoop:boolean);
      procedure Stop;
      procedure SetVolume(AVolume:TpvFloat);
      procedure SetPanning(APanning:TpvFloat);
      procedure SetRate(ARate:TpvFloat);
      function IsPlaying:boolean;
     end;

     TpvAudioSoundMusicResource=class(TpvResource,IpvAudioSoundMusicResource)
      private
       fMusic:TpvAudioSoundMusic;
      public
       constructor Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource=nil;const aMetaResource:TpvMetaResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None); override;
       destructor Destroy; override;
       function BeginLoad(const aStream:TStream):boolean; override;
       procedure Play(AVolume,APanning,ARate:TpvFloat;ALoop:boolean);
       procedure Stop;
       procedure SetVolume(AVolume:TpvFloat);
       procedure SetPanning(APanning:TpvFloat);
       procedure SetRate(ARate:TpvFloat);
       function IsPlaying:boolean;
      published
       property Music:TpvAudioSoundMusic read fMusic;
     end;

     TpvAudioSoundSamples=class(TList)
      private
       function GetItem(Index:TpvInt32):TpvAudioSoundSample;
       procedure SetItem(Index:TpvInt32;Item:TpvAudioSoundSample);
      public
       AudioEngine:TpvAudio;
       HashMap:TpvAudioStringHashMap;
       constructor Create(AAudioEngine:TpvAudio);
       destructor Destroy; override;
       function Load(Name:TpvRawByteString;Stream:TStream;DoFree:boolean=true;VirtualVoices:TpvInt32=1;Loop:TpvUInt32=1;RealVoices:TpvInt32=-1):TpvAudioSoundSample;
       property Items[Index:TpvInt32]:TpvAudioSoundSample read GetItem write SetItem; default;
     end;

     TpvAudioSoundMusics=class(TList)
      private
       function GetItem(Index:TpvInt32):TpvAudioSoundMusic;
       procedure SetItem(Index:TpvInt32;Item:TpvAudioSoundMusic);
      public
       AudioEngine:TpvAudio;
       HashMap:TpvAudioStringHashMap;
       constructor Create(AAudioEngine:TpvAudio);
       destructor Destroy; override;
       function Load(Name:TpvRawByteString;Stream:TStream;DoFree:boolean=true):TpvAudioSoundMusic;
       property Items[Index:TpvInt32]:TpvAudioSoundMusic read GetItem write SetItem; default;
     end;

     TpvAudioUpdateHook=procedure of object;

     PpvAudioPitchShifterBuffer=^TpvAudioPitchShifterBuffer;
     TpvAudioPitchShifterBuffer=array[0..PitchShifterBufferSize+16] of TpvAudioSoundSampleStereoValue;

     PpvAudioPitchShifterFadeBuffer=^TpvAudioPitchShifterFadeBuffer;
     TpvAudioPitchShifterFadeBuffer=array[0..PitchShifterBufferSize+1] of TpvAudioSoundSampleValue;

     TpvAudioPitchShifter=class
      public
       AudioEngine:TpvAudio;
       PitchShifterFadeBuffer:TpvAudioPitchShifterFadeBuffer;
       WorkBuffer:TpvAudioPitchShifterBuffer;
       p1:TpvUInt32;
       p2:TpvUInt32;
       InputPointer:TpvUInt32;
       Factor:TpvFloat;
       constructor Create(AAudioEngine:TpvAudio);
       destructor Destroy; override;
       procedure Reset;
       procedure Process(Buffer:TpvPointer;Samples:TpvInt32);
     end;

     TpvAudioReverbAllPassBufferSample=array[0..1] of TpvInt32;

     TpvAudioReverbAllPassBuffer=array of TpvAudioReverbAllPassBufferSample;

     TpvAudioReverbBuffer=array of TpvInt32;

     TpvAudioReverb=class
      private
       AllPassBuffer:array[0..MaxReverbAllPassFilters-1] of TpvAudioReverbAllPassBuffer;
       Counter:array[0..MaxReverbAllPassFilters-1,0..3] of TpvInt32;
       LastLowPassLeft:TpvInt32;
       LastLowPassRight:TpvInt32;
       LeftBuffer:TpvAudioReverbBuffer;
       RightBuffer:TpvAudioReverbBuffer;
       LeftDelayedCounter:TpvInt32;
       RightDelayedCounter:TpvInt32;
       LeftCounter:TpvInt32;
       RightCounter:TpvInt32;
       SampleBufferSize:TpvInt32;
       SampleBufferMask:TpvInt32;
       CutOff:TpvInt32;
      public
       AudioEngine:TpvAudio;
       PreDelay:TpvInt32;
       CombFilterSeparation:TpvInt32;
       RoomSize:TpvInt32;
       FeedBack:TpvFloat;
       Absortion:TpvInt32;
       Dry:TpvFloat;
       Wet:TpvFloat;
       AllPassFilters:TpvInt32;
       constructor Create(AAudioEngine:TpvAudio);
       destructor Destroy; override;
       procedure Reset;
       procedure Init;
       procedure Process(Buffer:TpvPointer;Samples:TpvInt32);
     end;

     TpvAudioThread=class(TThread)
      protected
       procedure Execute; override;
      public
       AudioEngine:TpvAudio;
       Buffer:TpvPointer;
       Event:TEvent;
       ReadEvent:TEvent;
       Sleeping:TpvInt32;
       constructor Create(AAudioEngine:TpvAudio);
       destructor Destroy; override;
       procedure Start;
      published
       property Terminated;
     end;

     { TpvAudioCommandQueue }
     TpvAudioCommandQueue=class
      public
       type TGlobalVoice=record
             Sample:TpvAudioSoundSample;
             VoiceNumber:TpvInt32;
            end;
            PGlobalVoice=^TGlobalVoice;
            TGlobalVoices=array of TGlobalVoice;
            TGlobalVoiceIDManager=TpvIDManager;
            TQueueItem=class
             public
              type TCommandType=
                    (
                     SampleVoicePlay,
                     SampleVoicePlaySpatialization,
                     SampleVoiceRandomReseek,
                     SampleVoiceResetLoop,
                     SampleVoiceStop,
                     SampleVoiceKeyOff,
                     SampleVoiceSetVolume,
                     SampleVoiceSetPanning,
                     SampleVoiceSetRate,
                     SampleVoiceSetPosition,
                     SampleVoiceSetEffectMix,
                     MusicPlay,
                     MusicStop,
                     MusicSetVolume,
                     MusicSetPanning,
                     MusicSetRate
                    );
                    PCommandType=^TCommandType;
             private
              fCommandType:TCommandType;
              fSample:TpvAudioSoundSample;
              fMusic:TpvAudioSoundMusic;
              fGlobalVoiceID:TpvID;
              fVoiceNumber:TpvInt32;
              fVolume:TpvFloat;
              fPanning:TpvFloat;
              fRate:TpvFloat;
              fPosition:TpvVector3;
              fVelocity:TpvVector3;
              fSpatialization:LongBool;
              fLocal:LongBool;
              fLoop:LongBool;
              fActive:LongBool;
              fVoiceIndexPointer:TpvPointer;
             public
            end;
            TQueue=TpvDynamicQueue<TQueueItem>;
            TStack=TpvDynamicStack<TQueueItem>;
      private
       fAudioEngine:TpvAudio;
       fGlobalLock:TPasMPCriticalSection;
       fLock:TPasMPCriticalSection;
       fQueue:TQueue;
       fFreeStack:TStack;
       function AcquireQueueItem:TQueueItem;
      public
       constructor Create(aAudioEngine:TpvAudio);
       destructor Destroy; override;
       procedure Lock;
       procedure Unlock;
       function SampleVoicePlay(const aSample:TpvAudioSoundSample;const aVolume,aPanning,aRate:TpvFloat;const aVoiceIndexPointer:TpvPointer=nil):TpvID;
       function SampleVoicePlaySpatialization(const aSample:TpvAudioSoundSample;const aVolume,aPanning,aRate:TpvFloat;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false;const aVoiceIndexPointer:TpvPointer=nil):TpvID;
       procedure SampleVoiceRandomReseek(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32); overload;
       procedure SampleVoiceRandomReseek(const aGlobalVoiceID:TpvID); overload;
       procedure SampleVoiceResetLoop(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32); overload;
       procedure SampleVoiceResetLoop(const aGlobalVoiceID:TpvID); overload;
       procedure SampleVoiceStop(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32); overload;
       procedure SampleVoiceStop(const aGlobalVoiceID:TpvID); overload;
       procedure SampleVoiceKeyOff(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32); overload;
       procedure SampleVoiceKeyOff(const aGlobalVoiceID:TpvID); overload;
       procedure SampleVoiceSetVolume(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aVolume:TpvFloat); overload;
       procedure SampleVoiceSetVolume(const aGlobalVoiceID:TpvID;const aVolume:TpvFloat); overload;
       procedure SampleVoiceSetPanning(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aPanning:TpvFloat); overload;
       procedure SampleVoiceSetPanning(const aGlobalVoiceID:TpvID;const aPanning:TpvFloat); overload;
       procedure SampleVoiceSetRate(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aRate:TpvFloat); overload;
       procedure SampleVoiceSetRate(const aGlobalVoiceID:TpvID;const aRate:TpvFloat); overload;
       procedure SampleVoiceSetPosition(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false); overload;
       procedure SampleVoiceSetPosition(const aGlobalVoiceID:TpvID;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false); overload;
       procedure SampleVoiceSetEffectMix(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aActive:LongBool); overload;
       procedure SampleVoiceSetEffectMix(const aGlobalVoiceID:TpvID;const aActive:LongBool); overload;
       procedure MusicPlay(const aMusic:TpvAudioSoundMusic;const aVolume,aPanning,aRate:TpvFloat;const aLoop:boolean);
       procedure MusicStop(const aMusic:TpvAudioSoundMusic);
       procedure MusicSetVolume(const aMusic:TpvAudioSoundMusic;const aVolume:TpvFloat);
       procedure MusicSetPanning(const aMusic:TpvAudioSoundMusic;const aPanning:TpvFloat);
       procedure MusicSetRate(const aMusic:TpvAudioSoundMusic;const aRate:TpvFloat);
       procedure Process;
     end;

     TpvAudioOnFillBuffer=procedure(const aBuffer:Pointer;const aCountSamples:TpvSizeInt) of object;

     { TpvAudio }
     TpvAudio=class
      private
       fTemporaryBuffer:PpvAudioFloats;
       fOnFillBuffer:TpvAudioOnFillBuffer;
       procedure CalcEvIndices(ev:TpvFloat;evidx:PpvAudioInt32s;var evmu:TpvFloat);
       procedure CalcAzIndices(evidx:TpvInt32;az:TpvFloat;azidx:PpvAudioInt32s;var azmu:TpvFloat);
       procedure GetLerpedHRTFCoefs(Elevation,Azimuth:TpvFloat;var LeftCoefs,RightCoefs:TpvAudioHRTFCoefs;var LeftDelay,RightDelay:TpvInt32);
      public
       Samples:TpvAudioSoundSamples;
       Musics:TpvAudioSoundMusics;
       SpatializationMode:TpvInt32;
       HRTF:LongBool;
       HRTFPreset:PpvAudioHRTFPreset;
       VoiceFirst:TpvAudioSoundSampleVoice;
       VoiceLast:TpvAudioSoundSampleVoice;
       SampleRate:TpvInt32;
       Channels:TpvInt32;
       Bits:TpvInt32;
       SpatializationWaterLowPassCW:TpvFloat;
       SpatializationWaterWaterBoostLowPassCW:TpvInt32;
       SpatializationWaterWaterBoostHighPassCW:TpvInt32;
       SpatializationWaterWaterBoost:TpvInt32;
       SpatializationLowPassCW:TpvFloat;
       SpatializationDelayAir:TpvFloat;
       SpatializationDelayUnderwater:TpvFloat;
       SpatializationDelayPowerOfTwo:TpvInt32;
       SpatializationDelayMask:TpvInt32;
       BufferSamples:TpvInt32;
       BufferChannelSamples:TpvInt32;
       BufferOutputChannelSamples:TpvInt32;
       MixingBufferSize:TpvInt32;
       OutputBufferSize:TpvInt32;
       MixingBuffer:PpvAudioSoundSampleValues;
       MusicMixingBuffer:PpvAudioSoundSampleValues;
       EffectMixingBuffer:PpvAudioSoundSampleValues;
       OutputBuffer:TpvPointer;
       MasterVolume:TpvInt32;
       SampleVolume:TpvInt32;
       MusicVolume:TpvInt32;
       RampingSamples:TpvInt32;
       RampingStepSamples:TpvInt32;
       AGCActive:LongBool;
       AGC:TpvInt32;
       AGCCounter:TpvInt32;
       AGCInterval:TpvInt32;
       CriticalSection:TPasMPCriticalSection;
       CubicSplineTable:TpvAudioResamplerCubicSplineArray;
       ListenerViewMatrix:TpvMatrix4x4;
       ListenerVelocity:TpvVector3;
       ListenerUnderwater:LongBool;
       ListenerGeneration:TpvUInt64;
       LowPassLeft:TpvInt32;
       LowPassRight:TpvInt32;
       LowPassLast:TpvInt32;
       LowPassCurrent:TpvInt32;
       LowPassIncrement:TpvInt32;
       LowPassRampingLength:TpvInt32;
       WaterBoostLowPassLeft:array[0..3] of TpvInt32;
       WaterBoostLowPassRight:array[0..3] of TpvInt32;
       WaterBoostMiddlePassLeft:TpvInt32;
       WaterBoostMiddlePassRight:TpvInt32;
       WaterBoostHighPassLeft:array[0..3] of TpvInt32;
       WaterBoostHighPassRight:array[0..3] of TpvInt32;
       WaterBoostHistoryLeft:array[0..3] of TpvInt32;
       WaterBoostHistoryRight:array[0..3] of TpvInt32;
       UpdateHook:TpvAudioUpdateHook;
       PitchShifter:TpvAudioPitchShifter;
       Reverb:TpvAudioReverb;
       PanningLUT:array[0..$10000] of TpvInt32;
       RingBuffer:TPasMPSingleProducerSingleConsumerRingBuffer;
       Thread:TpvAudioThread;
       IsReady:LongBool;
       IsMuted:LongBool;
       IsActive:LongBool;
       ConeScale:TpvScalar;
       InnerAngle:TpvScalar;
       OuterAngle:TpvScalar;
       OuterGain:TpvScalar;
       OuterGainHF:TpvScalar;
       GlobalVoiceManager:TpvAudioSoundSampleGlobalVoiceManager;
       CommandQueue:TpvAudioCommandQueue;
       WAVStreamDumpMusic:TpvAudioWAVStreamDump;
       WAVStreamDumpSample:TpvAudioWAVStreamDump;
       WAVStreamDumpFinalMix:TpvAudioWAVStreamDump;
       PCG32:TpvPCG32;
       constructor Create(ASampleRate,AChannels,ABits,ABufferSamples:TpvInt32);
       destructor Destroy; override;
       function GetMixerMasterVolume:TpvFloat;
       function GetMixerMusicVolume:TpvFloat;
       function GetMixerSampleVolume:TpvFloat;
       procedure SetMixerMasterVolume(NewVolume:TpvFloat);
       procedure SetMixerMusicVolume(NewVolume:TpvFloat);
       procedure SetMixerSampleVolume(NewVolume:TpvFloat);
       procedure SetMixerAGC(Enabled:boolean);
       procedure Setup;
       procedure ClipBuffer(p:TpvPointer;Range:TpvInt32);
       procedure FillBuffer;
       procedure Lock;
       procedure Unlock;
       procedure SetActive(Active:boolean);
       procedure Mute;
       procedure Unmute;
       property MixerMasterVolume:TpvFloat read GetMixerMasterVolume write SetMixerMasterVolume;
       property MixerMusicVolume:TpvFloat read GetMixerMusicVolume write SetMixerMusicVolume;
       property MixerSampleVolume:TpvFloat read GetMixerSampleVolume write SetMixerSampleVolume;
       property OnFillBuffer:TpvAudioOnFillBuffer read fOnFillBuffer write fOnFillBuffer;
     end;

const AudioSpeakerLayoutMono:TpvAudioSpeakerLayout=
       (
        Name:'mono';
        CountChannels:1;
        Listeners:(
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:1.0;AmbientVolume:1.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0)
        );
       );

      AudioSpeakerLayoutStereo:TpvAudioSpeakerLayout=
       (
        Name:'stereo';
        CountChannels:2;
        Listeners:(
         (Index:0;YawAngle:90.0;DotScale:0.5;DotBias:0.5;AmbientVolume:1.0),
         (Index:1;YawAngle:270.0;DotScale:0.5;DotBias:0.5;AmbientVolume:1.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0)
        );
       );

      AudioSpeakerLayoutSurround40:TpvAudioSpeakerLayout=
       (
        Name:'surround40';
        CountChannels:4;
        Listeners:(
         (Index:0;YawAngle:45.0;DotScale:0.3;DotBias:0.3;AmbientVolume:0.8),
         (Index:1;YawAngle:315.0;DotScale:0.3;DotBias:0.3;AmbientVolume:0.8),
         (Index:2;YawAngle:135.0;DotScale:0.3;DotBias:0.3;AmbientVolume:0.8),
         (Index:3;YawAngle:225.0;DotScale:0.3;DotBias:0.3;AmbientVolume:0.8),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0)
        );
       );

      AudioSpeakerLayoutSurround51:TpvAudioSpeakerLayout=
       (
        Name:'surround51';
        CountChannels:6;
        Listeners:(
         (Index:0;YawAngle:45.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:1;YawAngle:315.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:2;YawAngle:135.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:3;YawAngle:225.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:4;YawAngle:0.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:5;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:0;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0)
        );
       );

      AudioSpeakerLayoutSurround71:TpvAudioSpeakerLayout=
       (
        Name:'surround71';
        CountChannels:8;
        Listeners:(
         (Index:0;YawAngle:45.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:1;YawAngle:315.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:2;YawAngle:135.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:3;YawAngle:225.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:4;YawAngle:0.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:5;YawAngle:0.0;DotScale:0.0;DotBias:0.0;AmbientVolume:0.0),
         (Index:6;YawAngle:90.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5),
         (Index:7;YawAngle:180.0;DotScale:0.2;DotBias:0.2;AmbientVolume:0.5)
        );
       );

var pvAudioDump:Boolean=false;

implementation

const PositionShift=32;
      PositionFactor:TpvInt64=$100000000;//(1 shl PositionShift);
      PositionMask=$ffffffff;//TpvInt64(1 shl PositionShift)-1;
      PositionDivFactor=1/$100000000;//(1 shl PositionShift);

      SpatializationlRemainBits=14;
      SpatializationlRemainFactor=1 shl SpatializationlRemainBits;

var AudioInstance:TpvAudio=nil;

function SwapWordLittleEndian(Value:TpvUInt16):TpvUInt16; {$ifdef cpu386}register;{$endif}
begin
{$ifdef big_endian}
 result:=((Value and $ff00) shr 8) or ((Value and $ff) shl 8);
{$else}
 result:=Value;
{$endif}
end;

function SwapDWordLittleEndian(Value:TpvUInt32):TpvUInt32; {$ifdef cpu386}register;{$endif}
begin
{$ifdef big_endian}
 result:=((Value and $ff000000) shr 24) or ((Value and $00ff0000) shr 8) or
         ((Value and $0000ff00) shl 8) or ((Value and $000000ff) shl 24);
{$else}
 result:=Value;
{$endif}
end;

function SwapWordBigEndian(Value:TpvUInt16):TpvUInt16; {$ifdef cpu386}register;{$endif}
begin
{$ifdef little_endian}
 result:=((Value and $ff00) shr 8) or ((Value and $ff) shl 8);
{$else}
 result:=Value;
{$endif}
end;

function SwapDWordBigEndian(Value:TpvUInt32):TpvUInt32; {$ifdef cpu386}register;{$endif}
begin
{$ifdef little_endian}
 result:=((Value and $ff000000) shr 24) or ((Value and $00ff0000) shr 8) or
         ((Value and $0000ff00) shl 8) or ((Value and $000000ff) shl 24);
{$else}
 result:=Value;
{$endif}
end;

procedure SwapLittleEndianData16(var Data); {$ifdef cpu386}register;{$endif}
{$ifdef big_endian}
var Value:TpvUInt16 absolute Data;
begin
 Value:=((Value and $ff00) shr 8) or ((Value and $ff) shl 8);
{$else}
begin
{$endif}
end;

procedure SwapLittleEndianData32(var Data); {$ifdef cpu386}register;{$endif}
{$ifdef big_endian}
var Value:TpvUInt32 absolute Data;
begin
 Value:=((Value and $ff000000) shr 24) or ((Value and $00ff0000) shr 8) or
        ((Value and $0000ff00) shl 8) or ((Value and $000000ff) shl 24);
{$else}
begin
{$endif}
end;

procedure SwapBigEndianData16(var Data); {$ifdef cpu386}register;{$endif}
{$ifdef little_endian}
var Value:TpvUInt16 absolute Data;
begin
 Value:=((Value and $ff00) shr 8) or ((Value and $ff) shl 8);
{$else}
begin
 result:=Value;
{$endif}
end;

procedure SwapBigEndianData32(var Data); {$ifdef cpu386}register;{$endif}
{$ifdef little_endian}
var Value:TpvUInt32 absolute Data;
begin
 Value:=((Value and $ff000000) shr 24) or ((Value and $00ff0000) shr 8) or
        ((Value and $0000ff00) shl 8) or ((Value and $000000ff) shl 24);
{$else}
begin
{$endif}
end;

{$ifndef HasSAR}
function SARLongint(Value,Shift:TpvInt32):TpvInt32;
{$if defined(cpu386)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 mov ecx,edx
 sar eax,cl
end;
{$elseif defined(cpux64) or defined(cpuamd64) or defined(cpux86_64)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 mov eax,ecx
 mov ecx,edx
{$else}
 mov eax,edi
 mov ecx,esi
{$ifend}
 sar eax,cl
end;
{$elseif defined(cpuarm)} assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 mov r0,r0,asr r1
{$if defined(cpuarm_has_bx)}
 bx lr
{$else}
 mov pc,lr
{$ifend}
end;
{$else} {$ifdef caninline}inline;{$endif}
begin
{$ifdef HasSAR}
 result:=SARLongint(Value,Shift);
{$else}
 Shift:=Shift and 31;
 result:=(TpvUInt32(Value) shr Shift) or (TpvUInt32(TpvInt32(TpvUInt32(0-TpvUInt32(TpvUInt32(Value) shr 31)) and TpvUInt32(0-TpvUInt32(ord(Shift<>0))))) shl (32-Shift));
{$endif}
end;
{$ifend}
{$endif}

function Clamp(x,a,b:TpvDouble):TpvDouble;
begin
 if x<a then begin
  result:=a;
 end else if x>b then begin
  result:=b;
 end else begin
  result:=x;
 end;
end;

function Lerp(a,b,x:TpvFloat):TpvFloat;
begin
 if x<0 then begin
  result:=a;
 end else if x>1.0 then begin
  result:=b;
 end else begin
  result:=(a*(1.0-x))+(b*x);
 end;
end;

function IntMod(x,y:TpvInt32):TpvInt32;
begin
 result:=x mod y;
{if y>0 then begin
  while result<=-y do begin
   inc(result,y);
  end;
  while result>=y do begin
   dec(result,y);
  end;
 end;}
end;

function FastLog2(const aValue:TpvFloat):TpvFloat;
{$if false}
var ValueCasted:TpvInt32 absolute aValue;
    ResultCasted:TpvUInt32 absolute result;
begin
 ResultCasted:=(TpvUInt32(ValueCasted) and TpvUInt32($807fffff))+TpvUInt32($3f800000);
 result:=(((ValueCasted shr 23) and $ff)-$80)+((((((((-0.0821343513178931783)*result)+0.649732456739820052)*result)-2.13417801862571777)*result)+4.08642207062728868)*result)-1.51984215742349793;
end;
{$else}
const OneDiv23Bit=1.0/(1 shl 23);
var Temporary,OtherTemporary:TpvFloat;
    ValueCasted:TpvUInt32 absolute aValue;
    OtherTemporaryCasted:TpvUInt32 absolute OtherTemporary;
begin
 Temporary:=ValueCasted*OneDiv23Bit;
 OtherTemporaryCasted:=(ValueCasted and $007fffff) or ($7e shl 23);
 result:=((Temporary-124.22544637)-(OtherTemporary*1.498030302))-(1.72587999/(0.3520887068+OtherTemporary));
end;
{$ifend}

function FastLog(const aValue:TpvFloat):TpvFloat;
begin
 result:=FastLog2(aValue)*0.6931471805599453;
end;

function FastExp2(const aValue:TpvFloat):TpvFloat;
{$if false}
var Value:TpvFloat;
    ValueCasted:TpvInt32 absolute aValue;
    ResultCasted:TpvUInt32 absolute result;
begin
 ResultCasted:=round(aValue);
 Value:=aValue-ResultCasted;
 ResultCasted:=($7f+ResultCasted) shl 23;
 result:=result*(1.0+(Value*(0.693292707161004662+(Value*(0.242162975514835621+(Value*0.548668824216034384))))));
end;
{$else}
var w:TpvInt32;
    Offset,Clip,z:TpvFloat;
    ValueCasted:TpvUInt32 absolute aValue;
    ResultCasted:TpvUInt32 absolute result;
begin
 Offset:=ValueCasted shr 31;
 if aValue<-126.0 then begin
  Clip:=-126.0;
 end else begin
  Clip:=aValue;
 end;
 w:=trunc(Clip);
 z:=(Clip-w)+Offset;
 ResultCasted:=trunc((TpvUInt32($800000)*(((Clip+121.2740838)+(27.7280233/(4.84252568-z)))-(1.49012907*z))));
end;
{$ifend}

function FastExp(const aValue:TpvFloat):TpvFloat;
begin
 result:=FastExp2(aValue*1.4426950408889634);
end;

function FastPower(const aBase,aExponent:TpvFloat):TpvFloat;
begin
 result:=FastExp2(aExponent*FastLog2(aBase));
end;

function FastArcTan(const aValue:TpvFloat):TpvFloat;
const PIOverFour=PI/4.0;
begin
 result:=(aValue*PIOverFour)-(aValue*(abs(aValue)-1.0)*(0.2447+(0.0663*abs(aValue))));
end;

function FastSQRT(const aValue:TpvFloat):TpvFloat;
var ResultCasted:UInt32 absolute result;
begin
 result:=aValue;
 ResultCasted:=((ResultCasted-$800000) shr 1)+$20000000;
 result:=result+(aValue/result);
 result:=(result*0.25)+(aValue/result);
end;

constructor TpvAudioWAVStreamDump.Create(const aAudioEngine:TpvAudio;const aStream:TStream;const aDoFreeStream:boolean=true);
begin
 inherited Create;

 fAudioEngine:=aAudioEngine;

 fStream:=aStream;

 fDoFreeStream:=aDoFreeStream;

 fSampleRate:=aAudioEngine.SampleRate;

 fChannels:=2;

 fBitsPerSample:=32;

 fWaveFileHeader.Signature:=TpvAudioWAVFormat.RIFFSignature;
 fWaveFileHeader.Size:=0;
 fWaveFileHeader.WAVESignature:=TpvAudioWAVFormat.WAVESignature;

 fWaveFormatHeader.FormatTag:=3;
 fWaveFormatHeader.Channels:=fChannels;
 fWaveFormatHeader.SamplesPerSecond:=fSampleRate;
 fWaveFormatHeader.AvgBytesPerSecond:=((fSampleRate*fChannels*fBitsPerSample)+7) shr 3;
 fWaveFormatHeader.SampleSize:=((fChannels*fBitsPerSample)+7) shr 3;
 fWaveFormatHeader.BitsPerSample:=fBitsPerSample;

 fWaveFormatChunkHeader.Signature:=TpvAudioWAVFormat.FMTSignature;
 fWaveFormatChunkHeader.Size:=SizeOf(TpvAudioWAVFormat.TWaveFormatHeader);

 fWaveDataChunkHeader.Signature:=TpvAudioWAVFormat.DATASignature;
 fWaveDataChunkHeader.Size:=0;

 fFileHeaderOffset:=fStream.Position;
 fStream.WriteBuffer(fWaveFileHeader,SizeOf(TpvAudioWAVFormat.TWaveFileHeader));

 fFormatChunkHeaderOffset:=fStream.Position;
 fStream.WriteBuffer(fWaveFormatChunkHeader,SizeOf(TpvAudioWAVFormat.TWaveChunkHeader));
 fStream.WriteBuffer(fWaveFormatHeader,SizeOf(TpvAudioWAVFormat.TWaveFormatHeader));

 fDataChunkHeaderOffset:=fStream.Position;
 fStream.WriteBuffer(fWaveDataChunkHeader,SizeOf(TpvAudioWAVFormat.TWaveChunkHeader));

 fDataOffset:=fStream.Position;

 fDataSize:=0;

 fBufferFloats:=nil;

 SetLength(fBufferFloats,65536);

end;

destructor TpvAudioWAVStreamDump.Destroy;
begin
 Flush;
 if fDoFreeStream then begin
  FreeAndNil(fStream);
 end;
 fBufferFloats:=nil;
 inherited Destroy;
end;

procedure TpvAudioWAVStreamDump.Flush;
begin

 if assigned(fStream) and (fDataSize>0) then begin

  fStream.Seek(fDataChunkHeaderOffset,soFromBeginning);
  fWaveDataChunkHeader.Size:=fDataSize;
  fStream.WriteBuffer(fWaveDataChunkHeader,SizeOf(TpvAudioWAVFormat.TWaveChunkHeader));

  fStream.Seek(fFileHeaderOffset,soFromBeginning);
  fWaveFileHeader.Size:=SizeOf(TpvAudioWAVFormat.TWaveChunkHeader)+
                        SizeOf(TpvAudioWAVFormat.TWaveFormatHeader)+
                        SizeOf(TpvAudioWAVFormat.TWaveChunkHeader)+
                        fDataSize;
  fStream.WriteBuffer(fWaveFileHeader,SizeOf(TpvAudioWAVFormat.TWaveFileHeader));

  fStream.Seek(0,soFromEnd);

 end;

end;

procedure TpvAudioWAVStreamDump.Dump(const aData:TpvPointer;const aDataSize:TpvSizeInt);
var CountSamples,Index:TpvSizeInt;
    ValueInt32:TpvInt32;
begin

 if assigned(fStream) and (aDataSize>=SizeOf(TpvUInt32)) then begin

  CountSamples:=aDataSize shr 2; // Mono-wise 32 bit stereo samples

  // Check if buffer is big enough, if not, resize it
  if length(fBufferFloats)<CountSamples then begin
   SetLength(fBufferFloats,CountSamples*2);
  end;

  // Convert 32 bit stereo samples to 32 bit float stereo samples
  for Index:=0 to CountSamples-1 do begin
   ValueInt32:=PpvAudioSoundSampleValues(aData)^[Index];
   fBufferFloats[Index]:=ValueInt32/32768.0;
  end;

  fStream.Seek(fDataOffset+fDataSize,soFromBeginning);
  fStream.WriteBuffer(fBufferFloats[0],aDataSize); // same byte size as aDataSize since uint32 = 4 bytes like float32 as well

  inc(fDataSize,aDataSize);

  Flush; // Flush every time, because we can't know when the stream is closed, so that the header is valid anyway

 end;

end;

function CalculateDelta(OldGain,NewGain:TpvFloat;OldDir,NewDir:TpvVector3):TpvFloat;
var GainChange,AngleChange:TpvFloat;
begin
 OldGain:=Max(OldGain,0.0001);
 NewGain:=Max(NewGain,0.0001);
 GainChange:=abs(log10(NewGain/OldGain)/log10(0.0001));
 AngleChange:=0.0;
 if (GainChange>0.0001) or (NewGain>0.0001) then begin
  if (abs(NewDir.x-OldDir.x)>0.000001) or (abs(NewDir.y-OldDir.y)>0.000001) or (abs(NewDir.z-OldDir.z)>0.000001) then begin
   AngleChange:=ArcCos(Min(Max(OldDir.Dot(NewDir),0.0),1.0))/pi;
  end;
 end;
 result:=Min(Max(AngleChange*25.0,GainChange)*2.0,1.0);
end;

constructor TpvAudioSoundSampleVoice.Create(aAudioEngine:TpvAudio;aSample:TpvAudioSoundSample;aIndex:TpvInt32);
begin
 inherited Create;
 fPrevious:=nil;
 fNext:=nil;
 fNextFree:=nil;
 fIsOnList:=false;
 fActiveVoiceIndex:=-1;
 fAudioEngine:=aAudioEngine;
 fSample:=aSample;
 fIndex:=aIndex;
 fMixToEffect:=false;
 fActive:=false;
 fLastLeft:=0;
 fLastRight:=0;
 fNewLastLeft:=0;
 fNewLastRight:=0;
 fMulLeft:=32768;
 fMulRight:=32768;
 fVolumeRampingRemain:=0;
 fIncrementRampingRemain:=0;
 fIncrementRampingStepRemain:=0;
 FillChar(fHRTFLeftCoefs,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFRightCoefs,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFLeftCoefsCurrent,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFRightCoefsCurrent,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFLeftCoefsIncrement,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFRightCoefsIncrement,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
 FillChar(fHRTFLeftHistory,SizeOf(TpvAudioHRTFHistory),AnsiChar(#0));
 FillChar(fHRTFRightHistory,SizeOf(TpvAudioHRTFHistory),AnsiChar(#0));
 fHRTFHistoryIndex:=0;
 fHRTFLeftDelay:=0;
 fHRTFRightDelay:=0;
 fHRTFLeftDelayCurrent:=0;
 fHRTFRightDelayCurrent:=0;
 fHRTFLeftDelayLast:=0;
 fHRTFRightDelayLast:=0;
 fHRTFLeftDelayIncrement:=0;
 fHRTFRightDelayIncrement:=0;
 fHRTFCounter:=0;
 fHRTFRampingRemain:=0;
 fHRTFRampingStepRemain:=0;
 fLastDirection:=TpvVector3.Null;
 fSpatializationHasContent:=false;
 fSpatializationVolumeLast:=0;
 fSpatializationDelayLeft:=0;
 fSpatializationDelayRight:=0;
 fSpatializationDelayLeftLast:=fSpatializationDelayLeft;
 fSpatializationDelayRightLast:=fSpatializationDelayRight;
 fSpatializationDelayLeftCurrent:=fSpatializationDelayLeft;
 fSpatializationDelayRightCurrent:=fSpatializationDelayRight;
 fSpatializationDelayLeftIncrement:=0;
 fSpatializationDelayRightIncrement:=0;
 fSpatializationDelayRampingRemain:=0;
 fSpatializationDelayLeftLine:=nil;
 fSpatializationDelayRightLine:=nil;
 SetLength(fSpatializationDelayLeftLine,fAudioEngine.SpatializationDelayPowerOfTwo);
 SetLength(fSpatializationDelayRightLine,fAudioEngine.SpatializationDelayPowerOfTwo);
 fSpatializationLowPassLeftCoef:=LowPassLength shl LowPassShift;
 fSpatializationLowPassRightCoef:=LowPassLength shl LowPassShift;
 fSpatializationLowPassLeftLastCoef:=fSpatializationLowPassLeftCoef;
 fSpatializationLowPassRightLastCoef:=fSpatializationLowPassRightCoef;
 fSpatializationLowPassLeftCurrentCoef:=fSpatializationLowPassLeftCoef;
 fSpatializationLowPassRightCurrentCoef:=fSpatializationLowPassRightCoef;
 fSpatializationLowPassLeftIncrementCoef:=0;
 fSpatializationLowPassRightIncrementCoef:=0;
 fSpatializationLowPassRampingRemain:=0;
 fRampingSamples:=fAudioEngine.RampingSamples;
 fVoiceIndexPointer:=nil;
 fSpatialization:=false;
 fSpatializationLocal:=false;
 fSpatializationOrigin:=TpvVector3.Null;
 fSpatializationVelocity:=TpvVector3.Null;
 if fAudioEngine.HRTF then begin
  fHRTFLength:=fAudioEngine.HRTFPreset^.irSize;
 end else begin
  fHRTFLength:=HRIR_MAX_LENGTH;
 end;
 fHRTFMask:=fHRTFLength-1;
 fGlobalVoiceID:=0;
 fTag:=High(TpvUInt64);
 fOtherTag:=High(TpvUInt64);
 fDynamicRateFactor:=65536;
 fDynamicVolume:=32768;
 fOnIntervalHook:=nil;
 fOnIntervalHookSampleCounter:=-1;
 fOnIntervalHookTotalSampleCounter:=0;
 fOnIntervalHookLastTotalSampleCounter:=0;
end;

destructor TpvAudioSoundSampleVoice.Destroy;
begin
 Dequeue;
 SetLength(fSpatializationDelayLeftLine,0);
 SetLength(fSpatializationDelayRightLine,0);
 inherited Destroy;
end;

procedure TpvAudioSoundSampleVoice.Enqueue;
begin
 if not fIsOnList then begin
  if assigned(fAudioEngine.VoiceLast) then begin
   fAudioEngine.VoiceLast.fNext:=self;
   fPrevious:=fAudioEngine.VoiceLast;
   fAudioEngine.VoiceLast:=self;
  end else begin
   fPrevious:=nil;
   fAudioEngine.VoiceFirst:=self;
   fAudioEngine.VoiceLast:=self;
  end;
  fNext:=nil;
  fIsOnList:=true;
 end;
 if (fActiveVoiceIndex<0) and (fSample.CountActiveVoices<length(fSample.ActiveVoices)) then begin
  fActiveVoiceIndex:=fSample.CountActiveVoices;
  inc(fSample.CountActiveVoices);
  fSample.ActiveVoices[fActiveVoiceIndex]:=self;
 end;
end;

procedure TpvAudioSoundSampleVoice.Dequeue;
begin
 if fActiveVoiceIndex>=0 then begin
  // Swap with last fActive voice when needed and remove from list
  if ((fActiveVoiceIndex+1)<fSample.CountActiveVoices) and (fSample.CountActiveVoices>1) then begin
   fSample.ActiveVoices[fActiveVoiceIndex]:=fSample.ActiveVoices[fSample.CountActiveVoices-1];
   fSample.ActiveVoices[fActiveVoiceIndex].fActiveVoiceIndex:=fActiveVoiceIndex;
  end;
  dec(fSample.CountActiveVoices);
  fActiveVoiceIndex:=-1;
 end;
 if fIsOnList then begin
  if assigned(fPrevious) then begin
   fPrevious.fNext:=fNext;
  end else if fAudioEngine.VoiceFirst=self then begin
   fAudioEngine.VoiceFirst:=fNext;
  end;
  if assigned(fNext) then begin
   fNext.fPrevious:=fPrevious;
  end else if fAudioEngine.VoiceLast=self then begin
   fAudioEngine.VoiceLast:=fPrevious;
  end;
  fPrevious:=nil;
  fNext:=nil;
  fIsOnList:=false;
 end;
end;

procedure TpvAudioSoundSampleVoice.Init(aVolume,aPanning,aRate:TpvFloat);
begin
 fActive:=true;
 fKeyOff:=false;
 fBackwards:=false;
 fVolume:=round(Clamp(aVolume,-1.0,1.0)*65536);
 fPanning:=round(Clamp(aPanning,-1.0,1.0)*65536);
 fRate:=aRate;
 fDopplerRate:=1.0;
 fIncrement:=(fSample.SampleRate*round((fRate*fDopplerRate)*TpvInt64($100000000))) div fSample.AudioEngine.SampleRate;
 fIncrementCurrent:=fIncrement shl 16;
 fIncrementLast:=fIncrement;
 fIncrementIncrement:=0;
 fIncrementRampingRemain:=0;
 fIncrementRampingStepRemain:=0;
 fAge:=0;
 fListenerGeneration:=High(TpvUInt64);
 fPosition:=0;
 fLastElevation:=1e+30;
 fLastAzimuth:=1e+30;
 if fAudioEngine.SpatializationMode=SPATIALIZATION_HRTF then begin
  FillChar(fHRTFLeftCoefs,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFRightCoefs,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFLeftCoefsCurrent,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFRightCoefsCurrent,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFLeftCoefsIncrement,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFRightCoefsIncrement,SizeOf(TpvAudioHRTFCoefs),AnsiChar(#0));
  FillChar(fHRTFLeftHistory,SizeOf(TpvAudioHRTFHistory),AnsiChar(#0));
  FillChar(fHRTFRightHistory,SizeOf(TpvAudioHRTFHistory),AnsiChar(#0));
  fHRTFHistoryIndex:=0;
  fHRTFLeftDelay:=0;
  fHRTFRightDelay:=0;
  fHRTFLeftDelayCurrent:=0;
  fHRTFRightDelayCurrent:=0;
  fHRTFLeftDelayLast:=0;
  fHRTFRightDelayLast:=0;
  fHRTFLeftDelayIncrement:=0;
  fHRTFRightDelayIncrement:=0;
  fHRTFRampingRemain:=0;
  fHRTFRampingStepRemain:=0;
  fHRTFLength:=fAudioEngine.HRTFPreset^.irSize;
  fHRTFMask:=fHRTFLength-1;
 end;
 fVolumeRampingRemain:=0;
 fVolumeLeft:=0;
 fVolumeRight:=0;
 fVolumeLeftLast:=0;
 fVolumeRightLast:=0;
 fVolumeLeftCurrent:=0;
 fVolumeRightCurrent:=0;
 fVolumeLeftIncrement:=0;
 fVolumeRightIncrement:=0;
 inc(fLastLeft,fNewLastLeft);
 inc(fLastRight,fNewLastRight);
 fNewLastLeft:=0;
 fNewLastRight:=0;
 if fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF] then begin
  fSpatializationHasContent:=false;
  fSpatializationDelayLeft:=0;
  fSpatializationDelayRight:=0;
  fSpatializationDelayLeftLast:=fSpatializationDelayLeft;
  fSpatializationDelayRightLast:=fSpatializationDelayRight;
  fSpatializationDelayLeftCurrent:=fSpatializationDelayLeft;
  fSpatializationDelayRightCurrent:=fSpatializationDelayRight;
  fSpatializationDelayLeftIncrement:=0;
  fSpatializationDelayRightIncrement:=0;
  fSpatializationDelayRampingRemain:=0;
{end;
 if fAudioEngine.SpatializationMode=SPATIALIZATION_PSEUDO then begin}
  fSpatializationLowPassLeftCoef:=LowPassLength shl LowPassShift;
  fSpatializationLowPassRightCoef:=LowPassLength shl LowPassShift;
  fSpatializationLowPassLeftLastCoef:=fSpatializationLowPassLeftCoef;
  fSpatializationLowPassRightLastCoef:=fSpatializationLowPassRightCoef;
  fSpatializationLowPassLeftCurrentCoef:=fSpatializationLowPassLeftCoef;
  fSpatializationLowPassRightCurrentCoef:=fSpatializationLowPassRightCoef;
  fSpatializationLowPassLeftIncrementCoef:=0;
  fSpatializationLowPassRightIncrementCoef:=0;
  fSpatializationLowPassLeftHistory[0]:=0;
  fSpatializationLowPassLeftHistory[1]:=0;
  fSpatializationLowPassRightHistory[0]:=0;
  fSpatializationLowPassRightHistory[1]:=0;
  fSpatializationLowPassRampingRemain:=0;
 end;
 fRampingSamples:=fAudioEngine.RampingSamples;
 fDynamicRateFactor:=65536;
 fDynamicVolume:=32768;
 fTag:=High(TpvUInt64);
 fOtherTag:=High(TpvUInt64);
 if assigned(fOnIntervalHook) then begin
  fCurrentOnIntervalHook:=fOnIntervalHook;
 end else if assigned(fSample.fOnIntervalHook) then begin
  fCurrentOnIntervalHook:=fSample.fOnIntervalHook;
 end else begin
  fCurrentOnIntervalHook:=nil;
 end;
 if assigned(fCurrentOnIntervalHook) then begin
  fOnIntervalHookSampleCounter:=0;
 end else begin
  fOnIntervalHookSampleCounter:=-1;
 end;
 fOnIntervalHookTotalSampleCounter:=0;
 fOnIntervalHookLastTotalSampleCounter:=0;
end;

procedure TpvAudioSoundSampleVoice.UpdateSpatialization;
 function LowPassCoef(Gain,cw:TpvFloat):TpvFloat;
 begin
  if Gain<0.01 then begin
   Gain:=0.01;
  end;
  if Gain<0.9999 then begin
   result:=((1.0-(Gain*cw))-sqrt((2.0*(Gain*(1.0-cw)))-(sqr(Gain)*(1.0-sqr(cw)))))/(1.0-Gain);
   if result<0.0 then begin
    result:=0.0;
   end else if result>1.0 then begin
    result:=1.0;
   end;
  end else begin
   result:=0.0;
  end;
 end;
const LeftSpeakerAngle=-(pi*0.5);
      RightSpeakerAngle=(pi*0.5);
var Distance,ClampedDistance,AttenuationDistance,Attenuation,Spatialization,SpatializationVolume,SpatializationDelay,
    LeftHFGain,RightHFGain,Gain,Factor,SpeedOfSound,DopplerListener,DopplerSource,Angle,DirectionGain,
    Elevation,Azimuth,Delta{},Scale,ConeVolume,ConeHF{}:TpvFloat;
    RelativeVector,NormalizedRelativeVector,Direction,SourceToListenerVector,ListenerOrigin:TpvVector3;
    Counter:TpvInt32;
    DoIt,IsLocal:boolean;
begin

 ListenerOrigin:=fAudioEngine.ListenerViewMatrix.SimpleInverse.Translation.xyz;

 RelativeVector:=fAudioEngine.ListenerViewMatrix*fSpatializationOrigin;

 NormalizedRelativeVector:=RelativeVector.Normalize;

 IsLocal:=fSpatializationLocal or (fSpatializationOrigin=ListenerOrigin);

 Distance:=RelativeVector.Length;

 ClampedDistance:=Clamp(Distance,fSample.MinDistance,fSample.MaxDistance);

 if IsLocal then begin
  Attenuation:=1.0;
 end else begin
  case fSample.DistanceModel of
   TpvAudioDistanceModel.InverseDistance:begin
    AttenuationDistance:=fSample.MinDistance+(fSample.AttenuationRollOff*(Distance-fSample.MinDistance));
    if AttenuationDistance>0.0 then begin
     Attenuation:=fSample.MinDistance/AttenuationDistance;
    end else begin
     Attenuation:=1.0;
    end;
   end;
   TpvAudioDistanceModel.InverseDistanceClamped:begin
    AttenuationDistance:=fSample.MinDistance+(fSample.AttenuationRollOff*(ClampedDistance-fSample.MinDistance));
    if AttenuationDistance>0.0 then begin
     Attenuation:=fSample.MinDistance/AttenuationDistance;
    end else begin
     Attenuation:=1.0;
    end;
   end;
   TpvAudioDistanceModel.LinearDistance:begin
    Attenuation:=1.0-(fSample.AttenuationRollOff*((Distance-fSample.MinDistance)/(fSample.MaxDistance-fSample.MinDistance)));
   end;
   TpvAudioDistanceModel.LinearDistanceClamped:begin
    Attenuation:=1.0-(fSample.AttenuationRollOff*((ClampedDistance-fSample.MinDistance)/(fSample.MaxDistance-fSample.MinDistance)));
   end;
   TpvAudioDistanceModel.ExponentDistance:begin
    Attenuation:=Power(Distance/fSample.MinDistance,-fSample.AttenuationRollOff);
   end;
   TpvAudioDistanceModel.ExponentDistanceClamped:begin
    Attenuation:=Power(ClampedDistance/fSample.MinDistance,-fSample.AttenuationRollOff);
   end;
   else {TpvAudioDistanceModel.NoAttenuation:}begin
    Attenuation:=1.0;
   end;
  end;
  if Attenuation<0.0 then begin
   Attenuation:=0.0;
  end;
 end;

 if fAudioEngine.InnerAngle<360.0 then begin
  Angle:=(ArcCos(NormalizedRelativeVector.z*fAudioEngine.ConeScale)*RAD2DEG)*2.0;
  if (Angle>fAudioEngine.InnerAngle) and (Angle<=fAudioEngine.OuterAngle) then begin
   Scale:=(Angle-fAudioEngine.InnerAngle)/(fAudioEngine.OuterAngle-fAudioEngine.InnerAngle);
   ConeVolume:=FloatLerp(1.0,fAudioEngine.OuterGain,Scale);
   ConeHF:=FloatLerp(1.0,fAudioEngine.OuterGainHF,Scale);
  end else if Angle>fAudioEngine.OuterAngle then begin
   ConeVolume:=fAudioEngine.OuterGain;
   ConeHF:=fAudioEngine.OuterGainHF;
  end else begin
   ConeVolume:=1.0;
   ConeHF:=1.0;
  end;
 end else begin
  ConeVolume:=1.0;
  ConeHF:=1.0;
 end;

 SpatializationVolume:=Attenuation*ConeVolume;
 if SpatializationVolume<0.0 then begin
  SpatializationVolume:=0.0;
 end else if SpatializationVolume>1.0 then begin
  SpatializationVolume:=1.0;
 end;

 fRampingSamples:=fAudioEngine.RampingSamples;

 if IsLocal then begin
  DirectionGain:=1.0;
 end else begin
  DirectionGain:=sqrt(sqr(NormalizedRelativeVector.x)+sqr(NormalizedRelativeVector.z));
  DirectionGain:=FloatLerp(DirectionGain,1.0,abs(NormalizedRelativeVector.Dot(TpvVector3.YAxis)));
 end;

 DoIt:=false;
 Direction:=NormalizedRelativeVector;
 if fAge=0 then begin
  fSpatializationVolumeLast:=SpatializationVolume;
  fLastDirection:=Direction;
 end else begin
  Delta:=CalculateDelta(fSpatializationVolumeLast,SpatializationVolume,fLastDirection,Direction);
  if Delta>0.001 then begin
   DoIt:=true;
   fRampingSamples:=trunc(Max(floor((Delta*(fAudioEngine.SampleRate*0.015))+0.5),1.0));
   fSpatializationVolumeLast:=SpatializationVolume;
   fLastDirection:=Direction;
  end;
 end;

{if IsLocal then begin
  Angle:=0.0;
 end else begin
  Angle:=ArcTan2(NormalizedRelativeVector.x,-NormalizedRelativeVector.z);
(*if abs(NormalizedRelativeVector.x)>EPSILON then begin
   // x<>0
   if abs(NormalizedRelativeVector.z)>EPSILON then begin // x<>0 z<>0
    Angle:=ArcTan2(NormalizedRelativeVector.x,-NormalizedRelativeVector.z);
   end else begin // x<>0 z=0
    if NormalizedRelativeVector.x<0 then begin
     Angle:=pi*0.5;
    end else begin
     Angle:=-(pi*0.5);
    end;
   end;
  end else begin
   // x=0
   if NormalizedRelativeVector.z>EPSILON then begin // x=0 z<0
    Angle:=-pi;
   end else begin // x=0 z>=0
    Angle:=0.0;
   end;
  end;//*)
 end;

 if IsLocal then begin
  Spatialization:=0.0;
 end else begin
  Spatialization:=Angle;
  if (Spatialization>=LeftSpeakerAngle) and (Spatialization<RightSpeakerAngle) then begin
   Spatialization:=(Angle-(LeftSpeakerAngle+((RightSpeakerAngle-LeftSpeakerAngle)*0.5)))/(RightSpeakerAngle-LeftSpeakerAngle);
  end else begin
   if Spatialization<LeftSpeakerAngle then begin
    Spatialization:=((Angle+(pi*2.0))-LeftSpeakerAngle)/((LeftSpeakerAngle-RightSpeakerAngle)+(pi*2.0));
   end else begin
    Spatialization:=(Angle-LeftSpeakerAngle)/((LeftSpeakerAngle-RightSpeakerAngle)+(pi*2.0));
   end;
  end;
 end;//}

 if IsLocal then begin
  Spatialization:=0.0;
 end else begin
  Spatialization:=NormalizedRelativeVector.x;
  if Spatialization<-1.0 then begin
   Spatialization:=-1.0;
  end else if Spatialization>1.0 then begin
   Spatialization:=1.0;
  end;
 end;//}
 case fAudioEngine.SpatializationMode of
  SPATIALIZATION_HRTF:begin
   fMulLeft:=round(Clamp(SpatializationVolume,-1.0,1.0)*32768.0);
   fMulRight:=fMulLeft;
  end;
  else begin
   fMulLeft:=round(Clamp(SpatializationVolume*DirectionGain*sin(HalfPI*Min(Max(0.0,0.5*(1.0-(Spatialization*HF_DAMP_FACTOR))),1.0)),-1.0,1.0)*32768.0);
   fMulRight:=round(Clamp(SpatializationVolume*DirectionGain*sin(HalfPI*Min(Max(0.0,0.5*(1.0+(Spatialization*HF_DAMP_FACTOR))),1.0)),-1.0,1.0)*32768.0);
  end;
 end;

 LeftHFGain:=1.0;
 RightHFGain:=1.0;

 case fAudioEngine.SpatializationMode of
  SPATIALIZATION_PSEUDO:begin
   fSpatializationDelayLeft:=0;
   fSpatializationDelayRight:=0;
   if fAudioEngine.ListenerUnderwater then begin
    SpatializationDelay:=fAudioEngine.SpatializationDelayUnderwater;
   end else begin
    SpatializationDelay:=fAudioEngine.SpatializationDelayAir;
   end;
   if Spatialization<0.0 then begin
    RightHFGain:=1.0+(Spatialization*HF_DAMP_HALF);
    fSpatializationDelayRight:=round((SpatializationDelay*(-Spatialization))*SpatializationDelayLength);
   end else if Spatialization>0.0 then begin
    LeftHFGain:=1.0-(Spatialization*HF_DAMP_HALF);
    fSpatializationDelayLeft:=round((SpatializationDelay*Spatialization)*SpatializationDelayLength);
   end;
   if NormalizedRelativeVector.z>0 then begin
    Gain:=1.0-(NormalizedRelativeVector.z*HF_DAMP);
    LeftHFGain:=LeftHFGain*Gain;
    RightHFGain:=RightHFGain*Gain;
   end;
  end;
  SPATIALIZATION_HRTF:begin
   if Distance>EPSILON then begin
    Elevation:=AngleClamp(ArcSin(Clamp(NormalizedRelativeVector.y,-1.0,1.0)));
    Azimuth:=AngleClamp(ArcTan2(NormalizedRelativeVector.x,-NormalizedRelativeVector.z));
   end else begin
    Elevation:=0.0;
    Azimuth:=0.0;
   end;
   if IsNaN(Elevation) or IsInfinite(Elevation) or IsNaN(Azimuth) or IsInfinite(Azimuth) then begin
    Elevation:=0.0;
    Azimuth:=0.0;
   end;
   if (fAge=0) or (abs(fLastElevation-Elevation)>=0.25) or (abs(fLastAzimuth-Azimuth)>=0.25) then begin
    fAudioEngine.GetLerpedHRTFCoefs(Elevation,Azimuth,fHRTFLeftCoefs,fHRTFRightCoefs,fHRTFLeftDelay,fHRTFRightDelay);
    fHRTFRampingRemain:=0;
    fHRTFLeftCoefsCurrent:=fHRTFLeftCoefs;
    fHRTFRightCoefsCurrent:=fHRTFRightCoefs;
    for Counter:=0 to fHRTFMask do begin
     fHRTFLeftCoefsIncrement[Counter]:=0;
     fHRTFRightCoefsIncrement[Counter]:=0;
    end;
    fSpatializationDelayLeft:=fHRTFLeftDelay;
    fSpatializationDelayRight:=fHRTFRightDelay;
   end else begin
    if DoIt then begin
     fHRTFRampingRemain:=fRampingSamples;
     fAudioEngine.GetLerpedHRTFCoefs(Elevation,Azimuth,fHRTFLeftCoefs,fHRTFRightCoefs,fHRTFLeftDelay,fHRTFRightDelay);
     for Counter:=0 to fHRTFMask do begin
      fHRTFLeftCoefsIncrement[Counter]:=(fHRTFLeftCoefs[Counter]-fHRTFLeftCoefsCurrent[Counter]) div fHRTFRampingRemain;
      fHRTFRightCoefsIncrement[Counter]:=(fHRTFRightCoefs[Counter]-fHRTFRightCoefsCurrent[Counter]) div fHRTFRampingRemain;
     end;
     fSpatializationDelayLeft:=fHRTFLeftDelay;
     fSpatializationDelayRight:=fHRTFRightDelay;
    end;
   end;
   fLastElevation:=Elevation;
   fLastAzimuth:=Azimuth;
  end;
 end;

 if fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF] then begin
  if Distance>MinAbsorptionDistance then begin
   Factor:=Clamp(power(AirAbsorptionGainHF,AirAbsorptionFactor*((Clamp(Distance,MinAbsorptionDistance,MaxAbsorptionDistance)-MinAbsorptionDistance)*WorldUnitsToMeters)),0.0,1.0);
   if IsNaN(Factor) or IsInfinite(Factor) then begin
    Factor:=1.0;
   end;
   LeftHFGain:=LeftHFGain*Factor;
   RightHFGain:=RightHFGain*Factor;
  end;
  fSpatializationLowPassLeftCoef:=Min(Max(round(Clamp(LowPassCoef(LeftHFGain,fAudioEngine.SpatializationLowPassCW),0.0,1.0)*(LowPassLength shl LowPassShift)),0),LowPassLength shl LowPassShift);
  fSpatializationLowPassRightCoef:=Min(Max(round(Clamp(LowPassCoef(RightHFGain,fAudioEngine.SpatializationLowPassCW),0.0,1.0)*(LowPassLength shl LowPassShift)),0),LowPassLength shl LowPassShift);
 end;

 Factor:=DopplerFactor;
 if Factor>0.0 then begin
  if fAudioEngine.ListenerUnderwater then begin
   SpeedOfSound:=SpeedOfSoundUnderwater;
  end else begin
   SpeedOfSound:=SpeedOfSoundAir;
  end;
  SpeedOfSound:=SpeedOfSound*DopplerVelocity;
  if (SpeedOfSound>0.0) and (SpeedOfSound<1.0) then begin
   Factor:=Factor/SpeedOfSound;
   SpeedOfSound:=1.0;
  end;
  SourceToListenerVector:=(fSpatializationOrigin-ListenerOrigin).Normalize;
  DopplerListener:=Min(fAudioEngine.ListenerVelocity.Dot(SourceToListenerVector)*Factor,SpeedOfSound/Factor);
  DopplerSource:=Min(fSpatializationVelocity.Dot(SourceToListenerVector)*Factor,SpeedOfSound/Factor);
  fDopplerRate:=Clamp(SpeedOfSound+DopplerListener,1.0,(SpeedOfSound*2.0)-1.0)/
               Clamp(SpeedOfSound+DopplerSource,1.0,(SpeedOfSound*2.0)-1.0);
  fIncrement:=(TpvInt64(fSample.SampleRate)*round((fRate*fDopplerRate)*TpvInt64($100000000))) div fAudioEngine.SampleRate;
 end;
end;

function TpvAudioSoundSampleVoice.GetSampleLength(CountSamplesValue:TpvInt32):TpvInt32;
var SmpInc,SmpLen,SmpLoopStart,SmpLoopEnd,CountSamples,SampleBufferSize,Difference:TpvInt64;
    LoopMode:TpvInt32;
begin
 SmpInc:=fIncrementCurrent shr 16;
 if SmpInc=0 then begin
  result:=0;
 end else begin
  SmpLen:=TpvInt64(fSample.SampleLength) shl 32;
  if (fSample.SustainLoop.Mode<>SoundLoopModeNONE) and not fKeyOff then begin
   LoopMode:=fSample.SustainLoop.Mode;
   SmpLoopStart:=TpvInt64(fSample.SustainLoop.StartSample) shl 32;
   SmpLoopEnd:=TpvInt64(fSample.SustainLoop.EndSample) shl 32;
  end else if fSample.Loop.Mode<>SoundLoopModeNONE then begin
   LoopMode:=fSample.Loop.Mode;
   SmpLoopStart:=TpvInt64(fSample.Loop.StartSample) shl 32;
   SmpLoopEnd:=TpvInt64(fSample.Loop.EndSample) shl 32;
  end else begin
   LoopMode:=SoundLoopModeNONE;
   SmpLoopStart:=0;
   SmpLoopEnd:=SmpLen;
  end;
  if LoopMode<>SoundLoopModeNONE then begin
   if fPosition<SmpLoopStart then begin
    if fBackwards then begin
     if LoopMode=SoundLoopModePINGPONG then begin
      fPosition:=SmpLoopStart-(SmpLoopStart-fPosition);
      fBackwards:=false;
      if (fPosition<SmpLoopStart) or (fPosition>=((SmpLoopStart+SmpLoopEnd) div 2)) then begin
       fPosition:=SmpLoopStart;
      end;
     end else if LoopMode=SoundLoopModeBACKWARD then begin
      fPosition:=SmpLen-(SmpLoopStart-fPosition);
      if fPosition>=SmpLoopEnd then begin
       fPosition:=fPosition+(SmpLoopStart-SmpLoopEnd);
       if fPosition<SmpLoopStart then begin
        fPosition:=SmpLoopStart;
       end;
      end;
     end else begin
      fPosition:=SmpLoopEnd-(SmpLoopStart-fPosition);
      fBackwards:=false;
      if fPosition>=SmpLoopEnd then begin
       fPosition:=fPosition+(SmpLoopStart-SmpLoopEnd);
       if fPosition<SmpLoopStart then begin
        fPosition:=SmpLoopStart;
       end;
      end;
     end;
    end else begin
     if fPosition<0 then begin
      fPosition:=0;
     end;
    end;
   end else if fPosition>=SmpLoopEnd then begin
    if LoopMode=SoundLoopModeBACKWARD then begin
     fBackwards:=true;
    end else if LoopMode=SoundLoopModePINGPONG then begin
     fPosition:=SmpLoopEnd-(fPosition-SmpLoopEnd);
     fBackwards:=true;
     if (fPosition<SmpLoopStart) or (fPosition>=((SmpLoopStart+SmpLoopEnd) div 2)) then begin
      fPosition:=SmpLoopStart;
     end;
    end else begin
     fPosition:=fPosition+(SmpLoopStart-SmpLoopEnd);
     if fPosition<SmpLoopStart then begin
      fPosition:=SmpLoopStart;
     end;
    end;
   end;
  end;
  if (fPosition<0) OR (fPosition>=SmpLen) OR
     ((fPosition<SmpLoopStart) AND
      ((fPosition<0) OR fBackwards)) then begin
   result:=0;
   exit;
  end;
  CountSamples:=CountSamplesValue;
  SampleBufferSize:=SpatializationlRemainFactor div ((SmpInc div PositionFactor)+1);
  if SampleBufferSize<2 then begin
   SampleBufferSize:=2;
  end;
  if CountSamplesValue>SampleBufferSize then begin
   CountSamplesValue:=SampleBufferSize;
  end;
  if fBackwards then begin
   Difference:=(fPosition-(SmpInc*(TpvInt64(CountSamplesValue)-1)));
   if Difference<SmpLoopStart then begin
    CountSamples:=(((fPosition-SmpLoopStart)-1) div SmpInc)+1;
   end;
  end else begin
   Difference:=(fPosition+(SmpInc*(TpvInt64(CountSamplesValue)-1)));
   if Difference>=SmpLoopEnd then begin
    CountSamples:=(((SmpLoopEnd-fPosition)-1) div SmpInc)+1;
   end;
  end;
  if CountSamples<=1 then begin
   result:=1;
   exit;
  end else if CountSamples>CountSamplesValue then begin
   result:=CountSamplesValue;
   exit;
  end;
  result:=CountSamples;
 end;
end;

procedure TpvAudioSoundSampleVoice.PreClickRemoval(Buffer:TpvPointer);
var LocalLeft,LocalRight,Counter:TpvInt32;
    Buf:PpvAudioInt32;
begin
 LocalLeft:=fLastLeft;
 LocalRight:=fLastRight;
 if (LocalLeft<>0) or (LocalRight<>0) then begin
  Buf:=TpvPointer(Buffer);
  for Counter:=1 to fSample.AudioEngine.BufferSamples do begin
   dec(LocalLeft,SARLongint(LocalLeft+(SARLongint(-LocalLeft,31) and $ff),8));
   dec(LocalRight,SARLongint(LocalRight+(SARLongint(-LocalRight,31) and $ff),8));
   Buf^:=Buf^+SARLongint(LocalLeft,12);
   inc(Buf);
   Buf^:=Buf^+SARLongint(LocalRight,12);
   inc(Buf);
  end;
  fLastLeft:=LocalLeft;
  fLastRight:=LocalRight;
 end;
end;

procedure TpvAudioSoundSampleVoice.PostClickRemoval(Buffer:TpvPointer;Remain:TpvInt32);
var LocalNewLastLeft,LocalNewLastRight:TpvInt32;
    Buf:PpvAudioInt32;
begin
 Buf:=Buffer;
 LocalNewLastLeft:=fNewLastLeft;
 LocalNewLastRight:=fNewLastRight;
 if (Remain>0) and ((LocalNewLastLeft<>0) or (LocalNewLastRight<>0)) then begin
  while Remain>0 do begin
   dec(LocalNewLastLeft,SARLongint(LocalNewLastLeft+(SARLongint(-LocalNewLastLeft,31) and $ff),8));
   dec(LocalNewLastRight,SARLongint(LocalNewLastRight+(SARLongint(-LocalNewLastRight,31) and $ff),8));
   Buf^:=Buf^+SARLongint(LocalNewLastLeft,12);
   inc(Buf);
   Buf^:=Buf^+SARLongint(LocalNewLastRight,12);
   inc(Buf);
   dec(Remain);
  end;
 end;
 fNewLastLeft:=LocalNewLastLeft;
 fNewLastRight:=LocalNewLastRight;
end;

procedure TpvAudioSoundSampleVoice.MixProcSpatializationHRTF(Buffer:TpvPointer;ToDo:TpvInt32);
var vl,vr,vli,vri,pll,plr,plli,plri,pdl,pdr,pdli,pdri,pdlip,pdrip,pdm,hhi,hm,p,m,s,v,i:TpvInt32;
    pllh,plrh:TpvAudioSoundSampleVoiceLowPassHistory;
    pdlp,pdrp,hl,hr,hli,hri,hlh,hrh:PpvAudioInt32s;
    Buf:PpvAudioInt32;
    p64,i64:TpvInt64;
    d:PpvAudioSoundSampleValues;
begin
 Buf:=TpvPointer(Buffer);
 d:=fSample.Data;
 vl:=fVolumeLeftCurrent;
 vr:=fVolumeRightCurrent;
 vli:=fVolumeLeftIncrement;
 vri:=fVolumeRightIncrement;
 pll:=fSpatializationLowPassLeftCurrentCoef;
 plr:=fSpatializationLowPassRightCurrentCoef;
 plli:=fSpatializationLowPassLeftIncrementCoef;
 plri:=fSpatializationLowPassRightIncrementCoef;
 pllh:=fSpatializationLowPassLeftHistory;
 plrh:=fSpatializationLowPassRightHistory;
 pdl:=fSpatializationDelayLeftCurrent;
 pdr:=fSpatializationDelayRightCurrent;
 pdli:=fSpatializationDelayLeftIncrement;
 pdri:=fSpatializationDelayRightIncrement;
 pdlip:=fSpatializationDelayLeftIndex;
 pdrip:=fSpatializationDelayRightIndex;
 pdlp:=@fSpatializationDelayLeftLine[0];
 pdrp:=@fSpatializationDelayRightLine[0];
 pdm:=fAudioEngine.SpatializationDelayMask;
 hl:=@fHRTFLeftCoefsCurrent[0];
 hr:=@fHRTFRightCoefsCurrent[0];
 hli:=@fHRTFLeftCoefsIncrement[0];
 hri:=@fHRTFRightCoefsIncrement[0];
 hlh:=@fHRTFLeftHistory[0];
 hrh:=@fHRTFRightHistory[0];
 hhi:=fHRTFHistoryIndex;
 hm:=fHRTFMask;
 p64:=fPosition;
 i64:=fMixIncrement;
 while ToDo>0 do begin
  dec(ToDo);
  p:=TpvUInt32(p64 shr PositionShift) shl 1;
  m:=(TpvUInt32(p64 and $ffffffff) shr (PositionShift-12)) and $fff;
  s:=d^[p];
{$ifdef UseDIV}
  inc(s,((d^[p+2]-s)*m) div 4096);
{$else}
  inc(s,SARLongint((d^[p+2]-s)*m,12));
{$endif}
{$ifdef UseDIV}
  inc(s,((pllh[0]-s)*(pll div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((pllh[0]-s)*SARLongint(pll,LowPassShift),LowPassBits));
{$endif}
  pllh[0]:=s;
{$ifdef UseDIV}
  inc(s,((pllh[1]-s)*(pll div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((pllh[1]-s)*SARLongint(pll,LowPassShift),LowPassBits));
{$endif}
  pllh[1]:=s;
  pdlp^[pdlip]:=s;
{$ifdef UseDIV}
  v:=pdl div SpatializationDelayLength;
{$else}
  v:=SARLongint(pdl,SpatializationDelayShift);
{$endif}
  s:=pdlp^[(pdlip-v) and pdm];
{$ifdef UseDIV}
  inc(s,((pdlp^[(pdlip-(v+1)) and pdm]-s)*((pdl and SpatializationDelayMask) shr 4)) div (SpatializationDelayLength shr 4));
{$else}
  inc(s,SARLongint((pdlp^[(pdlip-(v+1)) and pdm]-s)*((pdl and SpatializationDelayMask) shr 4),SpatializationDelayShift-4));
{$endif}
{$ifdef UseDIV}
  s:=(s*(vl div 32768)) div 32768;
{$else}
  s:=SARLongint(s*SARLongint(vl,15),15);
{$endif}
  hlh^[hhi and hm]:=0;
  for i:=0 to hm do begin
   v:=(hhi+1+i) and hm;
{$ifdef UseDIV}
   inc(hlh^[v],((hl^[i] div 32768)*s) div 32768);
{$else}
   inc(hlh^[v],SARLongint(SARLongint(hl^[i],15)*s,15));
{$endif}
   inc(hl^[i],hli^[i]);
  end;
  inc(Buf^,hlh^[(hhi+1) and hm]);
  inc(Buf);
  s:=d^[p+1];
{$ifdef UseDIV}
  inc(s,((d^[p+3]-s)*m) div 4096);
{$else}
  inc(s,SARLongint((d^[p+3]-s)*m,12));
{$endif}
{$ifdef UseDIV}
  inc(s,((plrh[0]-s)*(plr div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((plrh[0]-s)*SARLongint(plr,LowPassShift),LowPassBits));
{$endif}
  plrh[0]:=s;
{$ifdef UseDIV}
  inc(s,((plrh[1]-s)*(plr div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((plrh[1]-s)*SARLongint(plr,LowPassShift),LowPassBits));
{$endif}
  plrh[1]:=s;
  pdrp^[pdrip]:=s;
{$ifdef UseDIV}
  v:=pdr div SpatializationDelayLength;
{$else}
  v:=SARLongint(pdr,SpatializationDelayShift);
{$endif}
  s:=pdrp^[(pdrip-v) and pdm];
{$ifdef UseDIV}
  inc(s,((pdrp^[(pdrip-(v+1)) and pdm]-s)*((pdr and SpatializationDelayMask) shr 4)) div (SpatializationDelayLength shr 4));
{$else}
  inc(s,SARLongint((pdrp^[(pdrip-(v+1)) and pdm]-s)*((pdr and SpatializationDelayMask) shr 4),SpatializationDelayShift-4));
{$endif}
{$ifdef UseDIV}
  s:=(s*(vr div 32768)) div 32768;
{$else}
  s:=SARLongint(s*SARLongint(vr,15),15);
{$endif}
  hrh^[hhi and hm]:=0;
  for i:=0 to hm do begin
   v:=(hhi+1+i) and hm;
{$ifdef UseDIV}
   inc(hrh^[v],((hr^[i] div 32768)*s) div 32768);
{$else}
   inc(hrh^[v],SARLongint(SARLongint(hr^[i],15)*s,15));
{$endif}
   inc(hr^[i],hri^[i]);
  end;
  inc(Buf^,hrh^[(hhi+1) and hm]);
  inc(Buf);
  inc(vl,vli);
  inc(vr,vri);
  inc(pll,plli);
  inc(plr,plri);
  inc(pdl,pdli);
  inc(pdr,pdri);
  pdlip:=(pdlip+1) and pdm;
  pdrip:=(pdrip+1) and pdm;
  hhi:=(hhi+1) and hm;
  inc(p64,i64);
 end;
 fVolumeLeftCurrent:=vl;
 fVolumeRightCurrent:=vr;
 fSpatializationLowPassLeftCurrentCoef:=pll;
 fSpatializationLowPassRightCurrentCoef:=plr;
 fSpatializationLowPassLeftHistory:=pllh;
 fSpatializationLowPassRightHistory:=plrh;
 fSpatializationDelayLeftCurrent:=pdl;
 fSpatializationDelayRightCurrent:=pdr;
 fSpatializationDelayLeftIndex:=pdlip;
 fSpatializationDelayRightIndex:=pdrip;
 fHRTFHistoryIndex:=hhi;
 fPosition:=p64;
end;

procedure TpvAudioSoundSampleVoice.MixProcSpatializationPSEUDO(Buffer:TpvPointer;ToDo:TpvInt32);
var vl,vr,vli,vri,pll,plr,plli,plri,pdl,pdr,pdli,pdri,pdlip,pdrip,pdm,p,m,s,v:TpvInt32;
    pllh,plrh:TpvAudioSoundSampleVoiceLowPassHistory;
    pdlp,pdrp:PpvAudioInt32s;
    Buf:PpvAudioInt32;
    p64,i64:TpvInt64;
    d:PpvAudioSoundSampleValues;
begin
 Buf:=TpvPointer(Buffer);
 d:=fSample.Data;
 vl:=fVolumeLeftCurrent;
 vr:=fVolumeRightCurrent;
 vli:=fVolumeLeftIncrement;
 vri:=fVolumeRightIncrement;
 pll:=fSpatializationLowPassLeftCurrentCoef;
 plr:=fSpatializationLowPassRightCurrentCoef;
 plli:=fSpatializationLowPassLeftIncrementCoef;
 plri:=fSpatializationLowPassRightIncrementCoef;
 pllh:=fSpatializationLowPassLeftHistory;
 plrh:=fSpatializationLowPassRightHistory;
 pdl:=fSpatializationDelayLeftCurrent;
 pdr:=fSpatializationDelayRightCurrent;
 pdli:=fSpatializationDelayLeftIncrement;
 pdri:=fSpatializationDelayRightIncrement;
 pdlip:=fSpatializationDelayLeftIndex;
 pdrip:=fSpatializationDelayRightIndex;
 pdlp:=@fSpatializationDelayLeftLine[0];
 pdrp:=@fSpatializationDelayRightLine[0];
 pdm:=fAudioEngine.SpatializationDelayMask;
 p64:=fPosition;
 i64:=fMixIncrement;
 while ToDo>0 do begin
  dec(ToDo);
  p:=TpvUInt32(p64 shr PositionShift) shl 1;
  m:=(TpvUInt32(p64 and $ffffffff) shr (PositionShift-12)) and $fff;
  s:=d^[p];
{$ifdef UseDIV}
  inc(s,((d^[p+2]-s)*m) div 4096);
{$else}
  inc(s,SARLongint((d^[p+2]-s)*m,12));
{$endif}
{$ifdef UseDIV}
  s:=(s*(vl div 32768)) div 32768;
{$else}
  s:=SARLongint(s*SARLongint(vl,15),15);
{$endif}
{$ifdef UseDIV}
  inc(s,((pllh[0]-s)*(pll div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((pllh[0]-s)*SARLongint(pll,LowPassShift),LowPassBits));
{$endif}
  pllh[0]:=s;
{$ifdef UseDIV}
  inc(s,((pllh[1]-s)*(pll div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((pllh[1]-s)*SARLongint(pll,LowPassShift),LowPassBits));
{$endif}
  pllh[1]:=s;
  pdlp^[pdlip]:=s;
{$ifdef UseDIV}
  v:=pdl div SpatializationDelayLength;
{$else}
  v:=SARLongint(pdl,SpatializationDelayShift);
{$endif}
  s:=pdlp^[(pdlip-v) and pdm];
{$ifdef UseDIV}
  inc(s,((pdlp^[(pdlip-(v+1)) and pdm]-s)*((pdl and SpatializationDelayMask) shr 4)) div (SpatializationDelayLength shr 4));
{$else}
  inc(s,SARLongint((pdlp^[(pdlip-(v+1)) and pdm]-s)*((pdl and SpatializationDelayMask) shr 4),SpatializationDelayShift-4));
{$endif}
  inc(Buf^,s);
  inc(Buf);
  s:=d^[p+1];
{$ifdef UseDIV}
  inc(s,((d^[p+3]-s)*m) div 4096);
{$else}
  inc(s,SARLongint((d^[p+3]-s)*m,12));
{$endif}
{$ifdef UseDIV}
  s:=(s*(vr div 32768)) div 32768;
{$else}
  s:=SARLongint(s*SARLongint(vr,15),15);
{$endif}
{$ifdef UseDIV}
  inc(s,((plrh[0]-s)*(plr div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((plrh[0]-s)*SARLongint(plr,LowPassShift),LowPassBits));
{$endif}
  plrh[0]:=s;
{$ifdef UseDIV}
  inc(s,((plrh[1]-s)*(plr div LowPassShiftLength)) div LowPassLength);
{$else}
  inc(s,SARLongint((plrh[1]-s)*SARLongint(plr,LowPassShift),LowPassBits));
{$endif}
  plrh[1]:=s;
  pdrp^[pdrip]:=s;
{$ifdef UseDIV}
  v:=pdr div SpatializationDelayLength;
{$else}
  v:=SARLongint(pdr,SpatializationDelayShift);
{$endif}
  s:=pdrp^[(pdrip-v) and pdm];
{$ifdef UseDIV}
  inc(s,((pdrp^[(pdrip-(v+1)) and pdm]-s)*((pdr and SpatializationDelayMask) shr 4)) div (SpatializationDelayLength shr 4));
{$else}
  inc(s,SARLongint((pdrp^[(pdrip-(v+1)) and pdm]-s)*((pdr and SpatializationDelayMask) shr 4),SpatializationDelayShift-4));
{$endif}
  inc(Buf^,s);
  inc(Buf);
  inc(vl,vli);
  inc(vr,vri);
  inc(pll,plli);
  inc(plr,plri);
  inc(pdl,pdli);
  inc(pdr,pdri);
  pdlip:=(pdlip+1) and pdm;
  pdrip:=(pdrip+1) and pdm;
  inc(p64,i64);
 end;
 fVolumeLeftCurrent:=vl;
 fVolumeRightCurrent:=vr;
 fSpatializationLowPassLeftCurrentCoef:=pll;
 fSpatializationLowPassRightCurrentCoef:=plr;
 fSpatializationLowPassLeftHistory:=pllh;
 fSpatializationLowPassRightHistory:=plrh;
 fSpatializationDelayLeftCurrent:=pdl;
 fSpatializationDelayRightCurrent:=pdr;
 fSpatializationDelayLeftIndex:=pdlip;
 fSpatializationDelayRightIndex:=pdrip;
 fPosition:=p64;
end;

procedure TpvAudioSoundSampleVoice.MixProcVolumeRamping(Buffer:TpvPointer;ToDo:TpvInt32);
var vl,vr,vli,vri,p,m,s:TpvInt32;
    Buf:PpvAudioInt32;
    p64,i64:TpvInt64;
    d:PpvAudioSoundSampleValues;
begin
 Buf:=TpvPointer(Buffer);
 d:=fSample.Data;
 vl:=fVolumeLeftCurrent;
 vr:=fVolumeRightCurrent;
 vli:=fVolumeLeftIncrement;
 vri:=fVolumeRightIncrement;
 p64:=fPosition;
 i64:=fMixIncrement;
 while ToDo>0 do begin
  dec(ToDo);
  p:=TpvUInt32(p64 shr PositionShift) shl 1;
  m:=(TpvUInt32(p64 and $ffffffff) shr (PositionShift-12)) and $fff;
  s:=d^[p];
{$ifdef UseDIV}
  inc(Buf^,(TpvInt32(s+(((d^[p+2]-s)*m) div 4096))*(vl div 32768)) div 32768);
{$else}
  inc(Buf^,SARLongint(TpvInt32(s+SARLongint((d^[p+2]-s)*m,12))*SARLongint(vl,15),15));
{$endif}
  inc(Buf);
  s:=d^[p+1];
{$ifdef UseDIV}
  inc(Buf^,(TpvInt32(s+(((d^[p+3]-s)*m) div 4096))*(vr div 32768)) div 32768);
{$else}
  inc(Buf^,SARLongint(TpvInt32(s+SARLongint((d^[p+3]-s)*m,12))*SARLongint(vr,15),15));
{$endif}
  inc(Buf);
  inc(vl,vli);
  inc(vr,vri);
  inc(p64,i64);
 end;
 fVolumeLeftCurrent:=vl;
 fVolumeRightCurrent:=vr;
 fPosition:=p64;
end;

procedure TpvAudioSoundSampleVoice.MixProcNormal(Buffer:TpvPointer;ToDo:TpvInt32);
var vl,vr,p,m,s:TpvInt32;
    Buf:PpvAudioInt32;
    p64,i64:TpvInt64;
    d:PpvAudioSoundSampleValues;
begin
 Buf:=TpvPointer(Buffer);
 d:=fSample.Data;
{$ifdef UseDIV}
 vl:=VolumeLeft div 32768;
 vr:=VolumeRight div 32768;
{$else}
 vl:=SARLongint(fVolumeLeft,15);
 vr:=SARLongint(fVolumeRight,15);
{$endif}
 p64:=fPosition;
 i64:=fMixIncrement;
 while ToDo>0 do begin
  dec(ToDo);
  p:=TpvUInt32(p64 shr PositionShift) shl 1;
  m:=(TpvUInt32(p64 and $ffffffff) shr (PositionShift-12)) and $fff;
  s:=d^[p];
{$ifdef UseDIV}
  inc(Buf^,(TpvInt32(s+(((d^[p+2]-s)*m) div 4096))*vl) div 32768);
{$else}
  inc(Buf^,SARLongint(TpvInt32(s+SARLongint((d^[p+2]-s)*m,12))*vl,15));
{$endif}
  inc(Buf);
  s:=d^[p+1];
{$ifdef UseDIV}
  inc(Buf^,(TpvInt32(s+(((d^[p+3]-s)*m) div 4096))*vr) div 32768);
{$else}
  inc(Buf^,SARLongint(TpvInt32(s+SARLongint((d^[p+3]-s)*m,12))*vr,15));
{$endif}
  inc(Buf);
  inc(p64,i64);
 end;
 fPosition:=p64;
end;

procedure TpvAudioSoundSampleVoice.UpdateIncrementRamping;
begin
{$if declared(SARInt64)}
 fTargetIncrement:=SARInt64(fIncrement*fDynamicRateFactor,16);
{$else}
 fTargetIncrement:=(fIncrement*fDynamicRateFactor) div 65536;
{$ifend}
 if fAge=0 then begin
  fIncrementRampingRemain:=0;
  fIncrementRampingStepRemain:=0;
  fIncrementCurrent:=fTargetIncrement shl 16;
  fIncrementLast:=fTargetIncrement;
  fIncrementIncrement:=0;
 end else if fIncrementLast<>fTargetIncrement then begin
  fIncrementRampingRemain:=fRampingSamples;
  fIncrementRampingStepRemain:=Min(Max(fRampingSamples div 10,1),fRampingSamples);
  fIncrementLast:=fTargetIncrement;
  fIncrementIncrement:=((fTargetIncrement shl 16)-fIncrementCurrent) div fIncrementRampingRemain;
 end;
end;

procedure TpvAudioSoundSampleVoice.UpdateTargetVolumes(aMixVolume:TpvInt32);
var MixVolume,Pan:TpvInt32;
begin
 MixVolume:=SARLongint(aMixVolume*fDynamicVolume,15);
 MixVolume:=SARLongint(aMixVolume*SARLongint(fVolume,1),15);
 if fSpatialization then begin
  fVolumeLeft:=SARLongint(MixVolume*fMulLeft,15);
  fVolumeRight:=SARLongint(MixVolume*fMulRight,15);
  if fVolumeLeft<-32768 then begin
   fVolumeLeft:=-32768;
  end else if fVolumeLeft>=32768 then begin
   fVolumeLeft:=32768;
  end;
  if fVolumeRight<-32768 then begin
   fVolumeRight:=-32768;
  end else if fVolumeRight>=32768 then begin
   fVolumeRight:=32768;
  end;
 end else begin
  Pan:=fPanning+65536;
  if Pan<0 then begin
   Pan:=0;
  end else if Pan>=131072 then begin
   Pan:=131072;
  end;
  fVolumeLeft:=SARLongint(fAudioEngine.PanningLUT[SARLongint(131072-Pan,1)]*MixVolume,15);
  fVolumeRight:=SARLongint(fAudioEngine.PanningLUT[SARLongint(Pan,1)]*MixVolume,15);
  if fVolumeLeft<0 then begin
   fVolumeLeft:=0;
  end else if fVolumeLeft>=32768 then begin
   fVolumeLeft:=32768;
  end;
  if fVolumeRight<0 then begin
   fVolumeRight:=0;
  end else if fVolumeRight>=32768 then begin
   fVolumeRight:=32768;
  end;
 end;
 fVolumeLeft:=fVolumeLeft shl 15;
 fVolumeRight:=fVolumeRight shl 15;
end;

procedure TpvAudioSoundSampleVoice.UpdateVolumeRamping(aMixVolume:TpvInt32);
begin
 UpdateTargetVolumes(aMixVolume);
 if fAge=0 then begin
  fVolumeRampingRemain:=0;
  fVolumeLeftLast:=fVolumeLeft;
  fVolumeRightLast:=fVolumeRight;
  fVolumeLeftCurrent:=fVolumeLeft;
  fVolumeRightCurrent:=fVolumeRight;
  fVolumeLeftIncrement:=0;
  fVolumeRightIncrement:=0;
 end else if (fVolumeLeftLast<>fVolumeLeft) or (fVolumeRightLast<>fVolumeRight) then begin
  fVolumeRampingRemain:=fRampingSamples;
  fVolumeLeftLast:=fVolumeLeft;
  fVolumeRightLast:=fVolumeRight;
  fVolumeLeftIncrement:=(fVolumeLeft-fVolumeLeftCurrent) div fVolumeRampingRemain;
  fVolumeRightIncrement:=(fVolumeRight-fVolumeRightCurrent) div fVolumeRampingRemain;
 end;
end;

procedure TpvAudioSoundSampleVoice.UpdateSpatializationDelayRamping;
begin
 if fAge=0 then begin
  fSpatializationDelayRampingRemain:=0;
  fSpatializationDelayLeftLast:=fSpatializationDelayLeft;
  fSpatializationDelayRightLast:=fSpatializationDelayRight;
  fSpatializationDelayLeftCurrent:=fSpatializationDelayLeft;
  fSpatializationDelayRightCurrent:=fSpatializationDelayRight;
  fSpatializationDelayLeftIncrement:=0;
  fSpatializationDelayRightIncrement:=0;
  if fAudioEngine.SpatializationDelayPowerOfTwo>0 then begin
   FillChar(fSpatializationDelayLeftLine[0],fAudioEngine.SpatializationDelayPowerOfTwo*SizeOf(TpvInt32),AnsiChar(#0));
   FillChar(fSpatializationDelayRightLine[0],fAudioEngine.SpatializationDelayPowerOfTwo*SizeOf(TpvInt32),AnsiChar(#0));
  end;
 end else if (fSpatializationDelayLeftLast<>fSpatializationDelayLeft) or (fSpatializationDelayRightLast<>fSpatializationDelayRight) then begin
  fSpatializationDelayRampingRemain:=fRampingSamples;
  fSpatializationDelayLeftLast:=fSpatializationDelayLeft;
  fSpatializationDelayRightLast:=fSpatializationDelayRight;
  fSpatializationDelayLeftIncrement:=(fSpatializationDelayLeft-fSpatializationDelayLeftCurrent) div fSpatializationDelayRampingRemain;
  fSpatializationDelayRightIncrement:=(fSpatializationDelayRight-fSpatializationDelayRightCurrent) div fSpatializationDelayRampingRemain;
 end;
end;

procedure TpvAudioSoundSampleVoice.UpdateSpatializationLowPassRamping;
begin
 if fAge=0 then begin
  fSpatializationLowPassRampingRemain:=0;
  fSpatializationLowPassLeftLastCoef:=fSpatializationLowPassLeftCoef;
  fSpatializationLowPassRightLastCoef:=fSpatializationLowPassRightCoef;
  fSpatializationLowPassLeftCurrentCoef:=fSpatializationLowPassLeftCoef;
  fSpatializationLowPassRightCurrentCoef:=fSpatializationLowPassRightCoef;
  fSpatializationLowPassLeftIncrementCoef:=0;
  fSpatializationLowPassRightIncrementCoef:=0;
  fSpatializationLowPassLeftHistory[0]:=0;
  fSpatializationLowPassLeftHistory[1]:=0;
  fSpatializationLowPassRightHistory[0]:=0;
  fSpatializationLowPassRightHistory[1]:=0;
 end else if (fSpatializationLowPassLeftLastCoef<>fSpatializationLowPassLeftCoef) or (fSpatializationLowPassRightLastCoef<>fSpatializationLowPassRightCoef) then begin
  fSpatializationLowPassRampingRemain:=fRampingSamples;
  fSpatializationLowPassLeftLastCoef:=fSpatializationLowPassLeftCoef;
  fSpatializationLowPassRightLastCoef:=fSpatializationLowPassRightCoef;
  fSpatializationLowPassLeftIncrementCoef:=(fSpatializationLowPassLeftCoef-fSpatializationLowPassLeftCurrentCoef) div fSpatializationLowPassRampingRemain;
  fSpatializationLowPassRightIncrementCoef:=(fSpatializationLowPassRightCoef-fSpatializationLowPassRightCurrentCoef) div fSpatializationLowPassRampingRemain;
 end;
end;

procedure TpvAudioSoundSampleVoice.Prepare;
const OneDivVolume=1.0/1073741824.0;
begin

 if fActive then begin

  if fListenerGeneration<>fAudioEngine.ListenerGeneration then begin
   fListenerGeneration:=fAudioEngine.ListenerGeneration;
   fAge:=0;
  end;

  if fSpatialization then begin
   UpdateSpatialization;
  end;

  UpdateTargetVolumes(32768);

  fVolumeSquaredMagnitude:=sqr(fVolumeLeft*OneDivVolume)+sqr(fVolumeRight*OneDivVolume);

 end else begin

  fVolumeSquaredMagnitude:=0.0;

 end;

 fReadyToPutIntoSleep:=fSample.Sleepable and (((fVolumeRampingRemain or fVolumeLeft or fVolumeRight or fLastLeft or fLastRight)=0) and (fVolumeLeftCurrent=fVolumeLeft) and (fVolumeRightCurrent=fVolumeRight) and not (fSpatializationHasContent or fKeyOff));

end;

procedure TpvAudioSoundSampleVoice.MixTo(aBuffer:PpvAudioSoundSampleValues;aMixVolume:TpvInt32;const aRealVoice:Boolean);
var Remain,ToDo,Counter:TpvInt32;
    Buf:PpvAudioInt32;
    BufEx:PpvAudioInt32s;
begin
 PreClickRemoval(aBuffer);
 if fActive then begin
  Buf:=TpvPointer(aBuffer);

  if aRealVoice or not
     (fSample.Sleepable and (((fVolumeLeft or fVolumeRight or fLastLeft or fLastRight)=0) and (fVolumeLeftCurrent=fVolumeLeft) and (fVolumeRightCurrent=fVolumeRight) and not (fSpatializationHasContent or fKeyOff))) then begin

   if assigned(fCurrentOnIntervalHook) then begin
    if fOnIntervalHookSampleCounter<=0 then begin
     fCurrentOnIntervalHook(self,fOnIntervalHookTotalSampleCounter-fOnIntervalHookLastTotalSampleCounter);
     fOnIntervalHookLastTotalSampleCounter:=fOnIntervalHookTotalSampleCounter;
     fOnIntervalHookSampleCounter:=fRampingSamples;
    end;
   end else begin
    fOnIntervalHookSampleCounter:=-1;
   end;

   UpdateIncrementRamping;

   if aRealVoice then begin
    UpdateVolumeRamping(aMixVolume);
   end else begin
    UpdateVolumeRamping(0);
   end;

   if fSpatialization and (fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF]) then begin
    UpdateSpatializationDelayRamping;
    UpdateSpatializationLowPassRamping;
   end;

   if (fVolumeRampingRemain or fVolumeLeft or fVolumeRight)=0 then begin
    if fIncrementRampingRemain>0 then begin
     fIncrementRampingStepRemain:=fIncrementRampingRemain;
    end;
   end;

   fNewLastLeft:=0;
   fNewLastRight:=0;
   Remain:=fSample.AudioEngine.BufferSamples;
   while (Remain>0) and fActive do begin

    ToDo:=Remain;
    if fIncrementRampingRemain>0 then begin
     if ToDo>=fIncrementRampingRemain then begin
      ToDo:=fIncrementRampingRemain;
     end;
     if (fIncrementRampingStepRemain>0) and (ToDo>=fIncrementRampingStepRemain) then begin
      ToDo:=fIncrementRampingStepRemain;
     end;
    end;
    if (fVolumeRampingRemain>0) and (ToDo>=fVolumeRampingRemain) then begin
     ToDo:=fVolumeRampingRemain;
    end;
    if (fOnIntervalHookSampleCounter>0) and (ToDo>=fOnIntervalHookSampleCounter) then begin
     ToDo:=fOnIntervalHookSampleCounter;
    end;
    if fSpatialization and (fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF]) then begin
     case fAudioEngine.SpatializationMode of
      SPATIALIZATION_PSEUDO:begin
       if (fSpatializationLowPassRampingRemain>0) and (ToDo>=fSpatializationLowPassRampingRemain) then begin
        ToDo:=fSpatializationLowPassRampingRemain;
       end;
      end;
      SPATIALIZATION_HRTF:begin
       if (fHRTFRampingRemain>0) and (ToDo>=fHRTFRampingRemain) then begin
        ToDo:=fHRTFRampingRemain;
       end;
      end;
     end;
     if (fSpatializationDelayRampingRemain>0) and (ToDo>=fSpatializationDelayRampingRemain) then begin
      ToDo:=fSpatializationDelayRampingRemain;
     end;
    end;

    ToDo:=GetSampleLength(ToDo);
    if ToDo=0 then begin
     fActive:=false;
     break;
    end;

    dec(Remain,ToDo);
    inc(fAge,ToDo);

    if fBackwards then begin
     fMixIncrement:=-(fIncrementCurrent shr 16);
    end else begin
     fMixIncrement:=fIncrementCurrent shr 16;
    end;

    if fIncrementRampingRemain>0 then begin
     inc(fIncrementCurrent,fIncrementIncrement*ToDo);
    end;

    if (fVolumeRampingRemain or fVolumeLeftCurrent or fVolumeRightCurrent)=0 then begin
     inc(fPosition,fMixIncrement*ToDo);
     if fSpatialization and (fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF]) then begin
      if (fAudioEngine.SpatializationMode=SPATIALIZATION_HRTF) and (fHRTFRampingRemain>0) then begin
       for Counter:=0 to fHRTFMask do begin
        inc(fHRTFLeftCoefs[Counter],fHRTFLeftCoefsIncrement[Counter]*ToDo);
        inc(fHRTFRightCoefs[Counter],fHRTFRightCoefsIncrement[Counter]*ToDo);
       end;
      end;
      inc(fSpatializationLowPassLeftCurrentCoef,fSpatializationLowPassLeftIncrementCoef*ToDo);
      inc(fSpatializationLowPassRightCurrentCoef,fSpatializationLowPassRightIncrementCoef*ToDo);
      fSpatializationLowPassLeftHistory[0]:=0;
      fSpatializationLowPassLeftHistory[1]:=0;
      fSpatializationLowPassRightHistory[0]:=0;
      fSpatializationLowPassRightHistory[1]:=0;
      inc(fSpatializationDelayLeftCurrent,fSpatializationDelayLeftIncrement*ToDo);
      inc(fSpatializationDelayRightCurrent,fSpatializationDelayRightIncrement*ToDo);
      if fSpatializationHasContent then begin
       fSpatializationHasContent:=false;
       Counter:=ToDo;
       if Counter>fAudioEngine.SpatializationDelayPowerOfTwo then begin
        Counter:=fAudioEngine.SpatializationDelayPowerOfTwo;
       end;
       while Counter>0 do begin
        dec(Counter);
        fSpatializationDelayLeftLine[fSpatializationDelayLeftIndex]:=0;
        fSpatializationDelayLeftIndex:=(fSpatializationDelayLeftIndex+1) and fAudioEngine.SpatializationDelayMask;
        fSpatializationDelayRightLine[fSpatializationDelayRightIndex]:=0;
        fSpatializationDelayRightIndex:=(fSpatializationDelayRightIndex+1) and fAudioEngine.SpatializationDelayMask;
       end;
      end;
     end;
     fNewLastLeft:=0;
     fNewLastRight:=0;
    end else begin
     BufEx:=@PpvAudioInt32s(Buf)^[(ToDo-1) shl 1];
     fNewLastLeft:=BufEx^[0];
     fNewLastRight:=BufEx^[1];
     if fSpatialization and (fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF]) then begin
      case fAudioEngine.SpatializationMode of
       SPATIALIZATION_PSEUDO:begin
        MixProcSpatializationPSEUDO(Buf,ToDo);
       end;
       SPATIALIZATION_HRTF:begin
        MixProcSpatializationHRTF(Buf,ToDo);
       end;
      end;
     end else begin
      // Even for fast fake 3D stereo fSpatialization
      if fVolumeRampingRemain>0 then begin
       MixProcVolumeRamping(Buf,ToDo);
      end else begin
       MixProcNormal(Buf,ToDo);
      end;
     end;
     fSpatializationHasContent:=true;
     fNewLastLeft:=(BufEx^[0]-fNewLastLeft) shl 12;
     fNewLastRight:=(BufEx^[1]-fNewLastRight) shl 12;
    end;

    if fIncrementRampingRemain>0 then begin
     if fIncrementRampingStepRemain>0 then begin
      dec(fIncrementRampingStepRemain,ToDo);
      if fIncrementRampingStepRemain=0 then begin
       fIncrementRampingStepRemain:=fAudioEngine.RampingStepSamples;
      end;
     end;
     dec(fIncrementRampingRemain,ToDo);
     if fIncrementRampingRemain=0 then begin
      fIncrementRampingStepRemain:=0;
      fIncrementCurrent:=fTargetIncrement shl 16;
      fIncrementIncrement:=0;
     end;
    end;

    if fVolumeRampingRemain>0 then begin
     dec(fVolumeRampingRemain,ToDo);
     if fVolumeRampingRemain=0 then begin
      fVolumeLeftCurrent:=fVolumeLeft;
      fVolumeRightCurrent:=fVolumeRight;
      fVolumeLeftIncrement:=0;
      fVolumeRightIncrement:=0;
     end;
    end;

    if fSpatialization and (fAudioEngine.SpatializationMode in [SPATIALIZATION_PSEUDO,SPATIALIZATION_HRTF]) then begin
     if (fAudioEngine.SpatializationMode=SPATIALIZATION_HRTF) and (fHRTFRampingRemain>0) then begin
      dec(fHRTFRampingRemain,ToDo);
      if fHRTFRampingRemain=0 then begin
       for Counter:=0 to fHRTFMask do begin
        fHRTFLeftCoefsCurrent[Counter]:=fHRTFLeftCoefs[Counter];
        fHRTFRightCoefsCurrent[Counter]:=fHRTFRightCoefs[Counter];
        fHRTFLeftCoefsIncrement[Counter]:=0;
        fHRTFRightCoefsIncrement[Counter]:=0;
       end;
      end;
     end;
     if fSpatializationLowPassRampingRemain>0 then begin
      dec(fSpatializationLowPassRampingRemain,ToDo);
      if fSpatializationLowPassRampingRemain=0 then begin
       fSpatializationLowPassLeftCurrentCoef:=fSpatializationLowPassLeftCoef;
       fSpatializationLowPassRightCurrentCoef:=fSpatializationLowPassRightCoef;
       fSpatializationLowPassLeftIncrementCoef:=0;
       fSpatializationLowPassRightIncrementCoef:=0;
      end;
     end;
     if fSpatializationDelayRampingRemain>0 then begin
      dec(fSpatializationDelayRampingRemain,ToDo);
      if fSpatializationDelayRampingRemain=0 then begin
       fSpatializationDelayLeftCurrent:=fSpatializationDelayLeft;
       fSpatializationDelayRightCurrent:=fSpatializationDelayRight;
       fSpatializationDelayLeftIncrement:=0;
       fSpatializationDelayRightIncrement:=0;
      end;
     end;
    end;

    if fOnIntervalHookSampleCounter>0 then begin
     dec(fOnIntervalHookSampleCounter,ToDo);
     if fOnIntervalHookSampleCounter=0 then begin
      if assigned(fOnIntervalHook) then begin
       if fCurrentOnIntervalHook(self,fOnIntervalHookTotalSampleCounter-fOnIntervalHookLastTotalSampleCounter) then begin
        UpdateIncrementRamping;
        if aRealVoice then begin
         UpdateVolumeRamping(aMixVolume);
        end else begin
         UpdateVolumeRamping(0);
        end;
       end;
       fOnIntervalHookLastTotalSampleCounter:=fOnIntervalHookTotalSampleCounter;
       fOnIntervalHookSampleCounter:=fVolumeRampingRemain;
      end;
     end;
    end;

    inc(fOnIntervalHookTotalSampleCounter,ToDo);

    inc(Buf,ToDo shl 1);
   end;

   PostClickRemoval(Buf,Remain);

  end;

  if not fActive then begin
   if assigned(fVoiceIndexPointer) then begin
    InterlockedExchange(TpvInt32(fVoiceIndexPointer^),-1);
    fVoiceIndexPointer:=nil;
   end;
   if fGlobalVoiceID<>0 then begin
    fAudioEngine.GlobalVoiceManager.DeallocateGlobalVoice(fGlobalVoiceID);
    fGlobalVoiceID:=0;
   end;
  end;
 end else begin
  if (fLastLeft=0) and (fLastRight=0) then begin
   Dequeue;
   fNextFree:=fSample.FreeVoice;
   fSample.FreeVoice:=self;
   if fGlobalVoiceID<>0 then begin
    fAudioEngine.GlobalVoiceManager.DeallocateGlobalVoice(fGlobalVoiceID);
    fGlobalVoiceID:=0;
   end;
  end;
 end;
end;

{ TpvAudioSoundSampleGlobalVoice }

constructor TpvAudioSoundSampleGlobalVoice.Create(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
begin
 SoundSample:=aSoundSample;
 VoiceNumber:=aVoiceNumber;
end;

{ TpvAudioSoundSampleGlobalVoiceManager }

constructor TpvAudioSoundSampleGlobalVoiceManager.Create(aAudioEngine:TpvAudio);
begin
 inherited Create;
 fAudioEngine:=aAudioEngine;
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fGlobalVoices:=nil;
 fGlobalVoiceIDs:=nil;
 fIDManager:=TpvIDManager.Create;
 fHashMap:=TpvAudioSoundSampleGlobalVoiceHashMap.Create(0);
end;

destructor TpvAudioSoundSampleGlobalVoiceManager.Destroy;
begin
 FreeAndNil(fHashMap);
 FreeAndNil(fIDManager);
 FreeAndNil(fLock);
 fGlobalVoices:=nil;
 fGlobalVoiceIDs:=nil;
 inherited Destroy;
end;

function TpvAudioSoundSampleGlobalVoiceManager.GetGlobalVoiceID(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32):TpvID;
begin
 fLock.AcquireRead;
 try
  result:=fHashMap.Values[TpvAudioSoundSampleGlobalVoice.Create(aSoundSample,aVoiceNumber)];
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvAudioSoundSampleGlobalVoiceManager.GetGlobalVoice(const aGlobalVoiceID:TpvID):TpvAudioSoundSampleGlobalVoice;
var Index:TpvUInt32;
begin
 fLock.AcquireRead;
 try
  Index:=aGlobalVoiceID and TpvUInt32($ffffffff);
  if (Index>0) and (Index<=length(fGlobalVoices)) then begin
   if fGlobalVoiceIDs[Index]=aGlobalVoiceID then begin
    result:=fGlobalVoices[Index];
   end else begin
    result.SoundSample:=nil;
    result.VoiceNumber:=-1;
   end;
  end else begin
   result.SoundSample:=nil;
   result.VoiceNumber:=-1;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvAudioSoundSampleGlobalVoiceManager.AllocateGlobalVoice(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32):TpvID;
var GlobalVoice:TpvAudioSoundSampleGlobalVoice;
    Index:TpvUInt32;
    OldCount,OtherIndex:TpvSizeInt;
    GlobalVoicePointer:PpvAudioSoundSampleGlobalVoice;
begin
 if assigned(aSoundSample) then begin
  fLock.AcquireWrite;
  try
   if aVoiceNumber<0 then begin
    GlobalVoice:=TpvAudioSoundSampleGlobalVoice.Create(aSoundSample,aSoundSample.GetReservedVoiceID);
   end else begin
    GlobalVoice:=TpvAudioSoundSampleGlobalVoice.Create(aSoundSample,aVoiceNumber);
   end;
   result:=fHashMap.Values[GlobalVoice];
   if result=0 then begin
    result:=fIDManager.AllocateID(0);
    fHashMap.Add(GlobalVoice,result);
    Index:=result and TpvUInt32($ffffffff);
    if (Index+1)>length(fGlobalVoices) then begin
     OldCount:=length(fGlobalVoices);
     SetLength(fGlobalVoices,(Index+1)+((Index+2) shr 1));
     for OtherIndex:=OldCount to length(fGlobalVoices)-1 do begin
      GlobalVoicePointer:=@fGlobalVoices[OtherIndex];
      GlobalVoicePointer^.SoundSample:=nil;
      GlobalVoicePointer^.VoiceNumber:=-1;
     end;
    end;
    if (Index+1)>length(fGlobalVoiceIDs) then begin
     OldCount:=length(fGlobalVoiceIDs);
     SetLength(fGlobalVoiceIDs,(Index+1)+((Index+2) shr 1));
     for OtherIndex:=OldCount to length(fGlobalVoiceIDs)-1 do begin
      fGlobalVoiceIDs[OtherIndex]:=0;
     end;
    end;
    fGlobalVoices[Index]:=GlobalVoice;
    fGlobalVoiceIDs[Index]:=result;
   end;
  finally
   fLock.ReleaseWrite;
  end;
 end else begin
  result:=0;
 end;
end;

procedure TpvAudioSoundSampleGlobalVoiceManager.SetGlobalVoice(const aGlobalVoiceID:TpvID;const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var Index:TpvUInt32;
    GlobalVoice:PpvAudioSoundSampleGlobalVoice;
begin
 fLock.AcquireWrite;
 try
  if fIDManager.CheckID(aGlobalVoiceID) then begin
   Index:=aGlobalVoiceID and TpvUInt32($ffffffff);
   if (Index>0) and (Index<=length(fGlobalVoices)) then begin
    GlobalVoice:=@fGlobalVoices[Index];
    fHashMap.Delete(GlobalVoice^);
    GlobalVoice^.SoundSample:=aSoundSample;
    GlobalVoice^.VoiceNumber:=aVoiceNumber;
    fHashMap.Add(GlobalVoice^,aGlobalVoiceID);
   end;
  end;
 finally
  fLock.ReleaseWrite;
 end;
end;

procedure TpvAudioSoundSampleGlobalVoiceManager.DeallocateGlobalVoice(const aGlobalVoiceID:TpvID);
var Index:TpvUInt32;
    GlobalVoice:PpvAudioSoundSampleGlobalVoice;
begin
 if aGlobalVoiceID<>0 then begin
  fLock.AcquireWrite;
  try
   Index:=aGlobalVoiceID and TpvUInt32($ffffffff);
   if (Index>0) and (Index<=length(fGlobalVoices)) then begin
    fGlobalVoiceIDs[Index]:=0;
    GlobalVoice:=@fGlobalVoices[Index];
    fHashMap.Delete(GlobalVoice^);
    fIDManager.FreeID(aGlobalVoiceID);
    GlobalVoice^.SoundSample:=nil;
    GlobalVoice^.VoiceNumber:=-1;
   end;
  finally
   fLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvAudioSoundSampleGlobalVoiceManager.DeallocateGlobalVoice(const aSoundSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var Index:TpvUInt32;
    GlobalVoiceID:TpvID;
    GlobalVoice:PpvAudioSoundSampleGlobalVoice;
begin
 if assigned(aSoundSample) and (aVoiceNumber>=0) then begin
  fLock.AcquireWrite;
  try
   GlobalVoiceID:=fHashMap.Values[TpvAudioSoundSampleGlobalVoice.Create(aSoundSample,aVoiceNumber)];
   Index:=GlobalVoiceID and TpvUInt32($ffffffff);
   if (Index>0) and (Index<=length(fGlobalVoices)) then begin
    fGlobalVoiceIDs[Index]:=0;
    GlobalVoice:=@fGlobalVoices[Index];
    fHashMap.Delete(GlobalVoice^);
    fIDManager.FreeID(GlobalVoiceID);
    GlobalVoice^.SoundSample:=nil;
    GlobalVoice^.VoiceNumber:=-1;
   end;
  finally
   fLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvAudioSoundSampleGlobalVoiceManager.DeallocateAllGlobalVoicesForSoundSample(const aSoundSample:TpvAudioSoundSample);
type TIDs=array of TpvID;
var Index:TpvUInt32;
    Count:TpvSizeInt;
    GlobalVoice:PpvAudioSoundSampleGlobalVoice;
    Entity:TpvAudioSoundSampleGlobalVoiceHashMap.TEntity;
    IDs:TIDs;
begin
 if assigned(aSoundSample) then begin
  fLock.AcquireWrite;
  try
   IDs:=nil;
   try
    Count:=0;
    for Entity in fHashMap.Entities do begin
     if Entity.Key.SoundSample=aSoundSample then begin
      if (Count+1)>length(IDs) then begin
       SetLength(IDs,(Count+1)*2);
      end;
      IDs[Count]:=Entity.Value;
      inc(Count);
     end;
    end;
    while Count>0 do begin
     dec(Count);
     Index:=IDs[Count] and TpvUInt32($ffffffff);
     fGlobalVoiceIDs[Index]:=0;
     GlobalVoice:=@fGlobalVoices[Index];
     fHashMap.Delete(GlobalVoice^);
     GlobalVoice^.SoundSample:=nil;
     GlobalVoice^.VoiceNumber:=-1;
     fIDManager.FreeID(IDs[Count]);
    end;
   finally
    IDs:=nil;
   end;
  finally
   fLock.ReleaseWrite;
  end;
 end;
end;

function TpvAudioSoundSampleGlobalVoiceManager.CheckGlobalVoiceID(const aGlobalVoiceID:TpvID):Boolean;
var Index:TpvUInt32;
begin
 fLock.AcquireRead;
 try
  Index:=aGlobalVoiceID and TpvUInt32($ffffffff);
  if (Index>0) and (Index<=length(fGlobalVoices)) then begin
   result:=(fGlobalVoiceIDs[Index]=aGlobalVoiceID) and fIDManager.CheckID(aGlobalVoiceID);
  end else begin
   result:=false;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

{ TpvAudioCompressor.TSettings }

constructor TpvAudioCompressor.TSettings.Create;
begin
 inherited Create;
 fThreshold:=-6.0;
 fAttackTime:=3.0;
 fHoldTime:=0.0;
 fReleaseTime:=100.0;
 fRatio:=2.0;
 fKnee:=0.0;
 fMakeUpGain:=0.0;
 fAutoGain:=false;
end;

destructor TpvAudioCompressor.TSettings.Destroy;
begin
 inherited Destroy;
end;

procedure TpvAudioCompressor.TSettings.AssignFromJSON(const aJSON:TPasJSONItem);
begin
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  fThreshold:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['threshold'],fThreshold);
  fAttackTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['attack'],fAttackTime);
  fHoldTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['hold'],fHoldTime);
  fReleaseTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['release'],fReleaseTime);
  fRatio:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['ratio'],fRatio);
  fKnee:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['knee'],fKnee);
  fMakeUpGain:=TPasJSON.GetNumber(TPasJSONItemObject(aJSON).Properties['makeupgain'],fMakeUpGain);
  fAutoGain:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSON).Properties['autogain'],fAutoGain);
 end;
end;

procedure TpvAudioCompressor.TSettings.Assign(const aSettings:TSettings);
begin
 fThreshold:=aSettings.fThreshold;
 fAttackTime:=aSettings.fAttackTime;
 fHoldTime:=aSettings.fHoldTime;
 fReleaseTime:=aSettings.fReleaseTime;
 fRatio:=aSettings.fRatio;
 fKnee:=aSettings.fKnee;
 fMakeUpGain:=aSettings.fMakeUpGain;
 fAutoGain:=aSettings.fAutoGain;
end;

{ TpvAudioCompressor }

constructor TpvAudioCompressor.Create(aAudioEngine:TpvAudio);
begin
 inherited Create;
 fAudioEngine:=aAudioEngine;
 fHoldTimeSampleCounter:=0;
 fState:=1.0;
 fPeakState:=0.0;
 fThreshold:=0.0;
 fAttackCoefficient:=0.0;
 fHoldTimeSampleDuration:=0;
 fReleaseCoefficient:=0.0;
 fRatio:=0.0;
 fOneMinusRatio:=0.0;
 fRatioFactor:=0.0;
 fFirst:=true;
 fSettings:=TSettings.Create;
end;

destructor TpvAudioCompressor.Destroy;
begin
 FreeAndNil(fSettings);
 inherited Destroy;
end;

procedure TpvAudioCompressor.Setup(const aSettings:TSettings);
const Log10DivLog2Div20=0.16609640474436811739351597147447; // (log(10.0)/log(2.0))/20.0
 function dBToLinear(const aDB:TpvDouble):TpvDouble;
 begin
  result:=Power(10.0,aDB*0.05);
 end;
begin

 fSettings.Assign(aSettings);

 fThreshold:=dBToLinear(fSettings.fThreshold);

 if IsZero(fSettings.fAttackTime) or (fSettings.fAttackTime<=0.0) then begin
  fAttackCoefficient:=1.0;
 end else begin
  fAttackCoefficient:=1.0-exp(-1.0/(fSettings.fAttackTime*0.001*fAudioEngine.SampleRate));
 end;

 if IsZero(fSettings.fHoldTime) or (fSettings.fHoldTime<0.0) then begin
  fHoldTimeSampleDuration:=-1;
 end else begin
  fHoldTimeSampleDuration:=round(fSettings.fHoldTime*0.001*fAudioEngine.SampleRate);
 end;

 if IsZero(fSettings.fReleaseTime) or (fSettings.fReleaseTime<=0.0) then begin
  fReleaseCoefficient:=1.0;
 end else begin
  fReleaseCoefficient:=1.0-exp(-1.0/(fSettings.fReleaseTime*0.001*fAudioEngine.SampleRate));
 end;

 if SameValue(fSettings.fRatio,0.0) then begin
  fRatio:=0.0; // Limiter mode
 end else begin
  fRatio:=1.0/fSettings.fRatio;
 end;

 fOneMinusRatio:=1.0-fRatio;

 fRatioFactor:=0.5*(fRatio-1.0);

 fKneedB:=fSettings.fKnee;

 fKneeFactor:=sqr(fKneedB*Log10DivLog2Div20);

 if fKneedB<0 then begin
  fKneeSign:=-1.0;
 end else begin
  fKneeSign:=1.0;
 end;

 fThresholddBFactor:=fSettings.fThreshold*Log10DivLog2Div20;

 fOutputGainFactor:=dBToLinear(fSettings.fMakeUpGain);

 if fSettings.fAutoGain then begin
  fOutputGainFactor:=fOutputGainFactor/Power(fThreshold,fOneMinusRatio);
 end;

end;

function TpvAudioCompressor.Process(const aInput:TpvFloat):TpvFloat;
var Target,TargetSquared,Coefficient:TpvFloat;
begin

 Target:=abs(aInput);

 if fFirst then begin
  fFirst:=false;
  fState:=Target;
 end;

 if fState<Target then begin
  Coefficient:=fAttackCoefficient;
  fHoldTimeSampleCounter:=0;
 end else begin
  if fHoldTimeSampleCounter<fHoldTimeSampleDuration then begin
   inc(fHoldTimeSampleCounter);
   Coefficient:=0.0;
  end else begin
   Coefficient:=fReleaseCoefficient;
  end;
 end;

  fState:=(fState*(1.0-Coefficient))+(Target*Coefficient);
 if abs(fState)>1e+16 then begin
  fState:=1.0;
 end;

 if abs(fKneedB)>1e-10 then begin
  // Soft knee
  result:=(FastLog2(fState)-fThresholddBFactor)*fRatioFactor;
  result:=FastExp2(result+sqrt(sqr(result)+fKneeFactor));
//result:=FastExp2(result+(FastSQRT(sqr(result)+fKneeFactor)*fKneeSign));
 end else begin
  // Hard knee
  if (abs(fState)>1e-10) and (fState>fThreshold) then begin
   if SameValue(fOneMinusRatio,1.0) then begin
    result:=fThreshold/fState;
   end else begin
    result:=FastPower(fThreshold/fState,fOneMinusRatio);
   end;
  end else begin
   result:=1.0;
  end;
 end;

 result:=result*fOutputGainFactor;

end;

{ TpvAudioSoundSample }

constructor TpvAudioSoundSample.Create(aAudioEngine:TpvAudio;aSoundSamples:TpvAudioSoundSamples);
begin
 inherited Create;
 AudioEngine:=aAudioEngine;
 SoundSamples:=aSoundSamples;
 Name:='';
{SoundSamples.Add(self);
 if length(Name)>0 then begin
  SoundSamples.HashMap.Add(Name,self);
 end;}
 Data:=nil;
 Loop.Mode:=SoundLoopModeNONE;
 SustainLoop.Mode:=SoundLoopModeNONE;
 Voices:=nil;
 ActiveVoices:=nil;
 CountActiveVoices:=0;
 ReferenceCounter:=0;
 SampleVirtualVoices:=0;
 SampleRealVoices:=0;
 ReservedVoiceIDCounter:=0;
 DistanceModel:=TpvAudioDistanceModel.InverseDistanceClamped;
 MinDistance:=8.0;
 MaxDistance:=65536.0;
 AttenuationRollOff:=1.0;
 GetMem(MixingBuffer,AudioEngine.MixingBufferSize);
 MixToEffect:=false;
 Sleepable:=false;
 CompressorActive:=false;
 Compressor:=TpvAudioCompressor.Create(AudioEngine);
 CompressorSettings:=TpvAudioCompressor.TSettings.Create;
 fOnIntervalHook:=nil;
end;

destructor TpvAudioSoundSample.Destroy;
var i:TpvInt32;
    Voice:TpvAudioSoundSampleVoice;
begin
 AudioEngine.GlobalVoiceManager.DeallocateAllGlobalVoicesForSoundSample(self);
 SoundSamples.Remove(self);
 if length(Name)>0 then begin
  SoundSamples.HashMap.Delete(Name);
 end;
 for i:=0 to length(Voices)-1 do begin
  Voice:=Voices[i];
  if assigned(Voice) then begin
   Voice.Destroy;
   Voices[i]:=nil;
  end;
 end;
 Voices:=nil;
 ActiveVoices:=nil;
 if assigned(Data) then begin
  dec(PpvAudioInt32(Data),2*SampleFixUp);
  FreeMem(Data);
  Data:=nil;
 end;
 if assigned(MixingBuffer) then begin
  FreeMem(MixingBuffer);
  MixingBuffer:=nil;
 end;
 FreeAndNil(CompressorSettings);
 FreeAndNil(Compressor);
 Name:='';
 inherited Destroy;
end;

procedure TpvAudioSoundSample.IncRef;
begin
 inc(ReferenceCounter);
end;

procedure TpvAudioSoundSample.DecRef;
begin
 if ReferenceCounter>0 then begin
  dec(ReferenceCounter);
  if ReferenceCounter=0 then begin
   Destroy;
  end;
 end;
end;

function TpvAudioSoundSample.GetReservedVoiceID:TpvInt32;
begin
 repeat
  result:=-((TPasMPInterlocked.Increment(ReservedVoiceIDCounter)+2) and $7fffffff);
 until result<=(-2); // May not be 0 or -1, because 0 is voice #0 and -1 is invalid/unused
end;

procedure TpvAudioSoundSample.CorrectVoices;
begin
 if (ReferenceCounter>0) and (SampleVirtualVoices>0) then begin
  SetVirtualVoices(SampleVirtualVoices*ReferenceCounter);
 end;
 if (ReferenceCounter>0) and (SampleRealVoices>0) then begin
  SetRealVoices(SampleRealVoices*ReferenceCounter);
 end;
end;

procedure TpvAudioSoundSample.FixUp;
var Counter,LoopStart,LoopEnd:TpvInt32;
begin
 if assigned(Data) then begin
  if SampleLength>0 then begin
   for Counter:=0 to SampleFixUp-1 do begin
    Data^[(-(Counter+1)*2)]:=Data^[0];
    Data^[(-(Counter+1)*2)+1]:=Data^[1];
    Data^[(SampleLength+Counter)*2]:=Data^[(SampleLength-1)*2];
    Data^[((SampleLength+Counter)*2)+1]:=Data^[((SampleLength-1)*2)+1];
   end;
   case Loop.Mode of
    SoundLoopModeFORWARD,SoundLoopModeBACKWARD:begin
     LoopStart:=Loop.StartSample;
     LoopEnd:=Min(Loop.EndSample,SampleLength);
     if (LoopStart>=0) and (LoopStart<LoopEnd) and (LoopEnd<=SampleLength) then begin
      if LoopStart=0 then begin
       for Counter:=0 to SampleFixUp-1 do begin
        Data^[(LoopStart-(Counter+1))*2]:=Data^[(LoopEnd-(Counter+1))*2];
        Data^[((LoopStart-(Counter+1))*2)+1]:=Data^[((LoopEnd-(Counter+1))*2)+1];
       end;
      end;
      for Counter:=0 to SampleFixUp-1 do begin
       Data^[(LoopEnd+Counter)*2]:=Data^[(LoopStart+Counter)*2];
       Data^[((LoopEnd+Counter)*2)+1]:=Data^[((LoopStart+Counter)*2)+1];
      end;
     end;
    end;
   end;
   case SustainLoop.Mode of
    SoundLoopModeFORWARD,SoundLoopModeBACKWARD:begin
     LoopStart:=SustainLoop.StartSample;
     LoopEnd:=SustainLoop.EndSample;
     if (LoopStart>0) and (LoopEnd>0) and (LoopEnd<=SampleLength) then begin
      for Counter:=0 to SampleFixUp-1 do begin
       Data^[(LoopEnd+Counter)*2]:=Data^[(LoopStart+Counter)*2];
       Data^[((LoopEnd+Counter)*2)+1]:=Data^[((LoopStart+Counter)*2)+1];
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvAudioSoundSample.SetVirtualVoices(aVirtualVoices:TpvInt32);
var i:TpvInt32;
begin
 for i:=0 to length(Voices)-1 do begin
  if assigned(Voices[i]) then begin
   Voices[i].Destroy;
   Voices[i]:=nil;
  end;
 end;
 FreeVoice:=nil;
 SetLength(Voices,aVirtualVoices);
 for i:=0 to length(Voices)-1 do begin
  Voices[i]:=TpvAudioSoundSampleVoice.Create(AudioEngine,self,i);
  Voices[i].fNextFree:=FreeVoice;
  FreeVoice:=Voices[i];
 end;
 SetLength(ActiveVoices,aVirtualVoices);
 for i:=0 to length(ActiveVoices)-1 do begin
  ActiveVoices[i]:=nil;
 end;
 CountActiveVoices:=0;
end;

procedure TpvAudioSoundSample.SetRealVoices(aRealVoices:TpvInt32);
begin

end;

function TpvAudioSoundSample.Play(aVolume,aPanning,aRate:TpvFloat;aVoiceIndexPointer:TpvPointer=nil;aPerreservedGlobalVoiceID:TpvID=0):TpvInt32;
var BestVoice,BestVolume,i:TpvInt32;
    BestAge:TpvInt64;
    Voice:TpvAudioSoundSampleVoice;
begin
 if assigned(FreeVoice) then begin
  Voice:=FreeVoice;
  FreeVoice:=Voice.fNextFree;
  BestVoice:=Voice.fIndex;
 end else begin
  BestVoice:=-1;
  for i:=0 to length(Voices)-1 do begin
   if not Voices[i].fActive then begin
    BestVoice:=i;
    break;
   end;
  end;
  if BestVoice<0 then begin
   BestVolume:=$7fffffff;
   BestAge:=0;
   for i:=0 to length(Voices)-1 do begin
    Voice:=Voices[i];
    if (Voice.fAge>BestAge) or ((Voice.fAge=BestAge) and (Voice.fVolume<=BestVolume)) then begin
     BestAge:=Voices[i].fAge;
     BestVolume:=Voices[i].fVolume;
     BestVoice:=i;
    end;
   end;
  end;
 end;
 if (BestVoice>=0) and (BestVoice<length(Voices)) then begin
  Voice:=Voices[BestVoice];
  if aPerreservedGlobalVoiceID<>0 then begin
   Voice.fGlobalVoiceID:=aPerreservedGlobalVoiceID;
   AudioEngine.GlobalVoiceManager.SetGlobalVoice(aPerreservedGlobalVoiceID,self,BestVoice);
  end else begin
   Voice.fGlobalVoiceID:=AudioEngine.GlobalVoiceManager.AllocateGlobalVoice(self,BestVoice);
  end;
  if assigned(Voice.fVoiceIndexPointer) then begin
   InterlockedExchange(TpvInt32(Voice.fVoiceIndexPointer^),-1);
   Voice.fVoiceIndexPointer:=nil;
  end;
  Voice.Init(aVolume,aPanning,aRate);
  Voice.fVoiceIndexPointer:=aVoiceIndexPointer;
  if assigned(aVoiceIndexPointer) then begin
   InterlockedExchange(TpvInt32(aVoiceIndexPointer^),BestVoice);
  end;
  Voice.Enqueue;
 end;
 result:=BestVoice;
end;

function TpvAudioSoundSample.PlaySpatialization(aVolume,aPanning,aRate:TpvFloat;aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const Local:LongBool=false;const aVoiceIndexPointer:TpvPointer=nil;aPerreservedGlobalVoiceID:TpvID=0):TpvInt32;
begin
 result:=Play(aVolume,aPanning,aRate,aVoiceIndexPointer,aPerreservedGlobalVoiceID);
 SetPosition(result,aSpatialization,aPosition,aVelocity,Local);
end;

procedure TpvAudioSoundSample.RandomReseek(aVoiceNumber:TpvInt32);
var Voice:TpvAudioSoundSampleVoice;
    SmpInc,SmpLen,SmpLoopStart,SmpLoopEnd:TpvInt64;
    LoopMode:TpvInt32;
begin
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  SmpLen:=TpvInt64(SampleLength);
  if (SustainLoop.Mode<>SoundLoopModeNONE) and not Voice.fKeyOff then begin
   LoopMode:=SustainLoop.Mode;
   SmpLoopStart:=TpvInt64(SustainLoop.StartSample);
   SmpLoopEnd:=TpvInt64(SustainLoop.EndSample);
  end else if Loop.Mode<>SoundLoopModeNONE then begin
   LoopMode:=Loop.Mode;
   SmpLoopStart:=TpvInt64(Loop.StartSample);
   SmpLoopEnd:=TpvInt64(Loop.EndSample);
  end else begin
   LoopMode:=SoundLoopModeNONE;
   SmpLoopStart:=0;
   SmpLoopEnd:=SmpLen;
  end;
  if LoopMode<>SoundLoopModeNONE then begin
   Voice.fPosition:=(SmpLoopStart shl 32)+((SmpLoopEnd-SmpLoopStart)*TpvInt64(AudioEngine.PCG32.Get32));
  end;
 end;
end;

procedure TpvAudioSoundSample.ResetLoop(aVoiceNumber:TpvInt32);
var Voice:TpvAudioSoundSampleVoice;
    SmpInc,SmpLen,SmpLoopStart,SmpLoopEnd:TpvInt64;
    LoopMode:TpvInt32;
begin
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  SmpLen:=TpvInt64(SampleLength);
  if (SustainLoop.Mode<>SoundLoopModeNONE) and not Voice.fKeyOff then begin
   LoopMode:=SustainLoop.Mode;
   SmpLoopStart:=TpvInt64(SustainLoop.StartSample);
   SmpLoopEnd:=TpvInt64(SustainLoop.EndSample);
  end else if Loop.Mode<>SoundLoopModeNONE then begin
   LoopMode:=Loop.Mode;
   SmpLoopStart:=TpvInt64(Loop.StartSample);
   SmpLoopEnd:=TpvInt64(Loop.EndSample);
  end else begin
   LoopMode:=SoundLoopModeNONE;
   SmpLoopStart:=0;
   SmpLoopEnd:=SmpLen;
  end;
  if LoopMode<>SoundLoopModeNONE then begin
   Voice.fPosition:=SmpLoopStart shl 32;
  end;
 end;
end;

procedure TpvAudioSoundSample.Stop(aVoiceNumber:TpvInt32);
var Voice:TpvAudioSoundSampleVoice;
begin
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fActive:=false;
  if Voice.fGlobalVoiceID<>0 then begin
   AudioEngine.GlobalVoiceManager.DeallocateGlobalVoice(Voice.fGlobalVoiceID);
   Voice.fGlobalVoiceID:=0;
  end else begin
   AudioEngine.GlobalVoiceManager.DeallocateGlobalVoice(self,aVoiceNumber);
  end;
  if assigned(Voice.fVoiceIndexPointer) then begin
   InterlockedExchange(TpvInt32(Voice.fVoiceIndexPointer^),-1);
   Voice.fVoiceIndexPointer:=nil;
  end;
 end;
end;

procedure TpvAudioSoundSample.KeyOff(aVoiceNumber:TpvInt32);
var Voice:TpvAudioSoundSampleVoice;
begin
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fKeyOff:=true;
  if (Loop.Mode<>SoundLoopModeNONE) or (SustainLoop.Mode=SoundLoopModeNONE) then begin
   Voice.fActive:=false;
   if assigned(Voice.fVoiceIndexPointer) then begin
    TpvInt32(Voice.fVoiceIndexPointer^):=-1;
    Voice.fVoiceIndexPointer:=nil;
   end;
  end;
 end;
end;

function TpvAudioSoundSample.SetVolume(aVoiceNumber:TpvInt32;aVolume:TpvFloat):TpvInt32;
var Voice:TpvAudioSoundSampleVoice;
begin
 result:=aVoiceNumber;
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fVolume:=round(Clamp(aVolume,-1.0,1.0)*65536.0);
 end;
end;

function TpvAudioSoundSample.SetPanning(aVoiceNumber:TpvInt32;aPanning:TpvFloat):TpvInt32;
var Voice:TpvAudioSoundSampleVoice;
begin
 result:=aVoiceNumber;
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fPanning:=round(Clamp(aPanning,-1.0,1.0)*65536.0);
 end;
end;

function TpvAudioSoundSample.SetRate(aVoiceNumber:TpvInt32;aRate:TpvFloat):TpvInt32;
var Voice:TpvAudioSoundSampleVoice;
begin
 result:=aVoiceNumber;
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fRate:=aRate;
  Voice.fIncrement:=(SampleRate*round((aRate*Voice.fDopplerRate)*TpvInt64($100000000))) div AudioEngine.SampleRate;
 end;
end;

function TpvAudioSoundSample.SetPosition(aVoiceNumber:TpvInt32;aSpatialization:LongBool;const aOrigin,aVelocity:TpvVector3;const aLocal:LongBool):TpvInt32;
var Voice:TpvAudioSoundSampleVoice;
begin
 result:=aVoiceNumber;
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fSpatialization:=aSpatialization;
  Voice.fSpatializationOrigin:=aOrigin;
  Voice.fSpatializationVelocity:=aVelocity;
  Voice.fSpatializationLocal:=aLocal;
 end;
end;

function TpvAudioSoundSample.SetEffectMix(aVoiceNumber:TpvInt32;aActive:LongBool):TpvInt32;
var Voice:TpvAudioSoundSampleVoice;
begin
 result:=aVoiceNumber;
 if (aVoiceNumber>=0) and (aVoiceNumber<length(Voices)) then begin
  Voice:=Voices[aVoiceNumber];
  Voice.fMixToEffect:=aActive;
 end;
end;

function TpvAudioSoundSample.IsPlaying:boolean;
var i:TpvInt32;
begin
 result:=false;
 for i:=0 to length(Voices)-1 do begin
  if Voices[i].fActive then begin
   result:=true;
   break;
  end;
 end;
end;

function TpvAudioSoundSample.IsVoicePlaying(aVoiceNumber:TpvInt32):boolean;
begin
 result:=((aVoiceNumber>=0) and (aVoiceNumber<length(Voices))) and Voices[aVoiceNumber].fActive;
end;

constructor TpvAudioSoundMusic.Create(AAudioEngine:TpvAudio;ASoundMusics:TpvAudioSoundMusics);
begin
 inherited Create;
 AudioEngine:=AAudioEngine;
 SoundMusics:=ASoundMusics;
 Name:='';
{SoundMusics.Add(self);
 if length(Name)>0 then begin
  SoundMusics.HashMap.Add(Name,self);
 end;}
 Active:=false;
 VolumeRampingRemain:=0;
 LastLeft:=0;
 LastRight:=0;
 LastSample.Left:=0;
 LastSample.Right:=0;
 Panning:=0;
 Volume:=0;
 VolumeLeft:=-1;
 VolumeRight:=-1;
 VolumeLeftCurrent:=0;
 VolumeRightCurrent:=0;
 VolumeLeftInc:=0;
 VolumeRightInc:=0;
 vf:=nil;
end;

destructor TpvAudioSoundMusic.Destroy;
begin
 SoundMusics.Remove(self);
 if length(Name)>0 then begin
  SoundMusics.HashMap.Delete(Name);
 end;
 if assigned(vf) then begin
  ov_clear(vf);
  Dispose(vf);
 end;
 if assigned(Data) then begin
  Data.Destroy;
 end;
 Name:='';
 inherited Destroy;
end;

procedure TpvAudioSoundMusic.InitSINC;
const Points=ResamplerSINCWidth;
      ThePoints=Points;
      HalfPoints=Points*0.5;
      ExtendedPI=3.1415926535897932384626433832795;
var FracValue,Value,SincValue,WindowValue,WindowFactor,WindowParameter,
    OtherPosition,Position,ResamplerSINCCutOff:{$ifdef cpuarm}TpvFloat{$else}TpvDouble{$endif};
    Counter,SubCounter:TpvInt32;
begin
 ResamplerSINCCutOff:=Clamp(AudioEngine.SampleRate/SampleRate,0.0,1.0);
 for Counter:=0 to ResamplerSINCLength-1 do begin
  FracValue:=(Counter/ResamplerSINCLength)-0.5;
  WindowFactor:=(2*ExtendedPI)/ThePoints;
  for SubCounter:=0 to Points-1 do begin
   OtherPosition:=SubCounter-FracValue;
   Position:=OtherPosition-HalfPoints;
   if abs(Position)<ResamplerEpsilon then begin
    Value:=ResamplerSINCCutOff;
   end else begin
    SincValue:=sin(ResamplerSINCCutOff*Position*ExtendedPI)/(Position*ExtendedPI);
    WindowParameter:=OtherPosition*WindowFactor;
    WindowValue:=0.42-(0.50*cos(WindowParameter))+(0.08*cos(2.0*WindowParameter)); // Blackman exact
    Value:=SincValue*WindowValue;
   end;
   Table[Counter,SubCounter]:=round(Value*ResamplerSINCValueLength);
  end;
 end;
end;

procedure TpvAudioSoundMusic.Play(AVolume,APanning,ARate:TpvFloat;ALoop:boolean);
var Pan,VolLeft,VolRight,MixVolume:TpvInt32;
begin
 inc(LastLeft,LastSample.Left);
 inc(LastRight,LastSample.Right);
 LastSample.Left:=0;
 LastSample.Right:=0;
 ov_raw_seek(vf,0);
 InBufferPosition:=InBufferSize+1;
 OutBufferPosition:=OutBufferSize+1;
 Volume:=round(AVolume*65536.0);
 Panning:=round(APanning*65536.0);
 Loop:=ALoop;
 VolumeRampingRemain:=0;
 Pan:=Panning+65536;
 if Pan<0 then begin
  Pan:=0;
 end else if Pan>=131072 then begin
  Pan:=131071;
 end;
 MixVolume:=SARLongint(Volume*AudioEngine.MusicVolume,16);
 VolLeft:=SARLongint(AudioEngine.PanningLUT[SARLongint(131072-Pan,1)]*MixVolume,15);
 VolRight:=SARLongint(AudioEngine.PanningLUT[SARLongint(Pan,1)]*MixVolume,15);
{VolLeft:=SARLongint((131072-Pan)*MixVolume,17);
 VolRight:=SARLongint(Pan*MixVolume,17);}
 if VolLeft<0 then begin
  VolLeft:=0;
 end else if VolLeft>=4096 then begin
  VolLeft:=4095;
 end;
 if VolRight<0 then begin
  VolRight:=0;
 end else if VolRight>=4096 then begin
  VolRight:=4095;
 end;
 VolLeft:=VolLeft shl 12;
 VolRight:=VolRight shl 12;
 VolumeLeftCurrent:=VolLeft;
 VolumeRightCurrent:=VolRight;
 VolumeLeft:=VolLeft;
 VolumeRight:=VolRight;
 ResamplerPosition:=0;
 if AudioEngine.SampleRate=SampleRate then begin
  ResamplerOriginalIncrement:=ResamplerFixedPointFactor;
 end else begin
  ResamplerOriginalIncrement:=((SampleRate*ResamplerFixedPointFactor)+(AudioEngine.SampleRate div 2)) div AudioEngine.SampleRate;
 end;
 ResamplerIncrement:=(abs(round(ARate*65536.0))*ResamplerOriginalIncrement) shr 16;
 ResamplerBufferPosition:=0;
 FillChar(ResamplerBuffer,SizeOf(ResamplerBuffer),AnsiChar(#0));
 FillChar(ResamplerCurrentSample,SizeOf(TpvAudioSoundMusicBufferSample),AnsiChar(#0));
 FillChar(ResamplerLastSample,SizeOf(TpvAudioSoundMusicBufferSample),AnsiChar(#0));
 Active:=true;
end;

procedure TpvAudioSoundMusic.Stop;
begin
 Active:=false;
 inc(LastLeft,LastSample.Left);
 inc(LastRight,LastSample.Right);
 LastSample.Left:=0;
 LastSample.Right:=0;
end;

procedure TpvAudioSoundMusic.SetVolume(AVolume:TpvFloat);
begin
 Volume:=round(AVolume*65536.0);
 VolumeRampingRemain:=AudioEngine.RampingSamples;
end;

procedure TpvAudioSoundMusic.SetPanning(APanning:TpvFloat);
begin
 Panning:=round(APanning*65536.0);
 VolumeRampingRemain:=AudioEngine.RampingSamples;
end;

procedure TpvAudioSoundMusic.SetRate(ARate:TpvFloat);
begin
 ResamplerIncrement:=(abs(round(ARate*65536.0))*ResamplerOriginalIncrement) shr 16;
end;

procedure TpvAudioSoundMusic.GetNextInBuffer;
var ToRead,BytesIn,Position,Tries:TpvInt32;
begin
 InBufferSize:=0;
 Position:=0;
 Tries:=0;
 while InBufferSize=0 do begin
  ToRead:=((length(InBuffer)-InBufferSize))*sizeof(smallint)*Channels;
  BytesIn:=ov_read(vf,@PCMBuffer[Position],ToRead,@bitstream);
  if BytesIn=OV_HOLE then begin
   continue;
  end else if (BytesIn=OV_EBADLINK) or (BytesIn=OV_EINVAL) or (BytesIn=0) then begin
   if Loop and (Tries<3) then begin
    ov_raw_seek(vf,0);
    inc(Tries);
    continue;
   end else begin
    if InBufferSize=0 then begin
     InBufferSize:=length(InBuffer);
     FillChar(PCMBuffer[0],SizeOf(SmallInt)*length(PCMBuffer),AnsiChar(#0));
    end;
    Active:=false;
   end;
   break;
  end;
  inc(Position,BytesIn div sizeof(smallint));
  inc(InBufferSize,BytesIn div (sizeof(smallint)*Channels));
 end;
 case Channels of
  1:begin
   // Mono
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=PCMBuffer[Position];
    InBuffer[Position].Right:=PCMBuffer[Position];
   end;
  end;
  2:begin
   // Left, right
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=PCMBuffer[(Position*2)+0];
    InBuffer[Position].Right:=PCMBuffer[(Position*2)+1];
   end;
  end;
  3:begin
   // Left, middle, right
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=SARLongint(PCMBuffer[(Position*3)+0]+PCMBuffer[(Position*3)+1],1);
    InBuffer[Position].Right:=SARLongint(PCMBuffer[(Position*3)+2]+PCMBuffer[(Position*3)+1],1);
   end;
  end;
  4:begin
   // Front left, front right, back left, back right
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=SARLongint(PCMBuffer[(Position*4)+0]+PCMBuffer[(Position*4)+2],1);
    InBuffer[Position].Right:=SARLongint(PCMBuffer[(Position*4)+1]+PCMBuffer[(Position*4)+3],1);
   end;
  end;
  5:begin
   // Front left, front middle, front right, back left, back right
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=(PCMBuffer[(Position*5)+0]+PCMBuffer[(Position*5)+1]+PCMBuffer[(Position*5)+3]) div 3;
    InBuffer[Position].Right:=(PCMBuffer[(Position*5)+2]+PCMBuffer[(Position*5)+1]+PCMBuffer[(Position*5)+4]) div 3;
   end;
  end;
  6:begin
   // Front left, front middle, front right, back left, back right, LFE channel (subwoofer)
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=SARLongint(PCMBuffer[(Position*6)+0]+PCMBuffer[(Position*6)+1]+PCMBuffer[(Position*6)+3]+PCMBuffer[(Position*6)+5],2);
    InBuffer[Position].Right:=SARLongint(PCMBuffer[(Position*6)+2]+PCMBuffer[(Position*6)+1]+PCMBuffer[(Position*6)+4]+PCMBuffer[(Position*6)+5],2);
   end;
  end;
  else begin
   // Undefined, so get only the first two channels in account
   for Position:=0 to InBufferSize-1 do begin
    InBuffer[Position].Left:=PCMBuffer[(Position*Channels)+0];
    InBuffer[Position].Right:=PCMBuffer[(Position*Channels)+1];
   end;
  end;
 end;
 InBufferPosition:=0;
end;

procedure TpvAudioSoundMusic.Resample;
var Counter{$ifdef cpuarm},Factor{$endif}:TpvInt32;
    OutSample:PpvAudioSoundMusicBufferSample;
{$ifdef cpuarm}
    InSamples:array[-1..0] of PpvAudioSoundMusicBufferSample;
{$else}
    SINCSubArray:PpvAudioResamplerSINCSubArray;
    InSamples:array[-3..0] of PpvAudioSoundMusicBufferSample;
    SubArray:PpvAudioResamplerCubicSplineSubArray;
{$endif}
begin
 if ResamplerIncrement=ResamplerFixedPointFactor then begin
  for Counter:=low(OutBuffer) to high(OutBuffer) do begin
   if InBufferPosition>=InBufferSize then begin
    GetNextInBuffer;
   end;
   OutBuffer[Counter]:=InBuffer[InBufferPosition];
   inc(InBufferPosition);
  end;
 end else begin
{$ifdef cpuarm}
  // Use simple but fast linear interpolation for up- and downsampling on mobile embedded ARM platforms
  for Counter:=low(OutBuffer) to high(OutBuffer) do begin
   inc(ResamplerPosition,ResamplerIncrement);
   while ResamplerPosition>=ResamplerFixedPointFactor do begin
    dec(ResamplerPosition,ResamplerFixedPointFactor);
    if InBufferPosition>=InBufferSize then begin
     GetNextInBuffer;
    end;
    ResamplerBuffer[ResamplerBufferPosition and ResamplerBufferMask]:=InBuffer[InBufferPosition];
    inc(InBufferPosition);
    ResamplerBufferPosition:=(ResamplerBufferPosition+1) and ResamplerBufferMask;
   end;
   Factor:=(TpvInt32(ResamplerPosition and ResamplerFixedPointMask) shr ResamplerLinearInterpolationFracShift) and ResamplerLinearInterpolationFracMask;
   InSamples[-1]:=@ResamplerBuffer[(ResamplerBufferPosition-2) and ResamplerBufferMask];
   InSamples[0]:=@ResamplerBuffer[(ResamplerBufferPosition-1) and ResamplerBufferMask];
   OutSample:=@OutBuffer[Counter];
   OutSample^.Left:=InSamples[-1]^.Left+SARLongint((InSamples[0]^.Left-InSamples[-1]^.Left)*Factor,ResamplerLinearInterpolationValueBits);
   OutSample^.Right:=InSamples[-1]^.Right+SARLongint((InSamples[0]^.Right-InSamples[-1]^.Right)*Factor,ResamplerLinearInterpolationValueBits);
  end;
{$else}
  if (ResamplerIncrement<ResamplerFixedPointFactor) or (ResamplerIncrement<>ResamplerOriginalIncrement) then begin
   // Upsample (and downsample if not original resampling rate) with cubic spline
   for Counter:=low(OutBuffer) to high(OutBuffer) do begin
    inc(ResamplerPosition,ResamplerIncrement);
    while ResamplerPosition>=ResamplerFixedPointFactor do begin
     dec(ResamplerPosition,ResamplerFixedPointFactor);
     if InBufferPosition>=InBufferSize then begin
      GetNextInBuffer;
     end;
     ResamplerBuffer[ResamplerBufferPosition and ResamplerBufferMask]:=InBuffer[InBufferPosition];
     inc(InBufferPosition);
     ResamplerBufferPosition:=(ResamplerBufferPosition+1) and ResamplerBufferMask;
    end;
    SubArray:=@AudioEngine.CubicSplineTable[(TpvUInt32(ResamplerPosition and ResamplerFixedPointMask) shr ResamplerCubicSplineFracShift) and ResamplerCubicSplineFracMask];
    InSamples[-3]:=@ResamplerBuffer[(ResamplerBufferPosition-4) and ResamplerBufferMask];
    InSamples[-2]:=@ResamplerBuffer[(ResamplerBufferPosition-3) and ResamplerBufferMask];
    InSamples[-1]:=@ResamplerBuffer[(ResamplerBufferPosition-2) and ResamplerBufferMask];
    InSamples[0]:=@ResamplerBuffer[(ResamplerBufferPosition-1) and ResamplerBufferMask];
    OutSample:=@OutBuffer[Counter];
    OutSample^.Left:=SARLongint((SubArray^[0]*InSamples[-3]^.Left)+(SubArray^[1]*InSamples[-1]^.Left)+(SubArray^[2]*InSamples[-2]^.Left)+(SubArray^[3]*InSamples[0]^.Left),ResamplerCubicSplineValueBits);
    OutSample^.Right:=SARLongint((SubArray^[0]*InSamples[-3]^.Right)+(SubArray^[1]*InSamples[-1]^.Right)+(SubArray^[2]*InSamples[-2]^.Right)+(SubArray^[3]*InSamples[0]^.Right),ResamplerCubicSplineValueBits);
   end;
  end else begin
   // Downsample with SINC
   for Counter:=low(OutBuffer) to high(OutBuffer) do begin
    inc(ResamplerPosition,ResamplerIncrement);
    while ResamplerPosition>=ResamplerFixedPointFactor do begin
     dec(ResamplerPosition,ResamplerFixedPointFactor);
     if InBufferPosition>=InBufferSize then begin
      GetNextInBuffer;
     end;
     ResamplerBuffer[ResamplerBufferPosition and ResamplerBufferMask]:=InBuffer[InBufferPosition];
     inc(InBufferPosition);
     ResamplerBufferPosition:=(ResamplerBufferPosition+1) and ResamplerBufferMask;
    end;
    SINCSubArray:=@Table[(TpvUInt32(ResamplerPosition and ResamplerFixedPointMask) shr ResamplerSINCFracShift) and ResamplerSINCFracMask];
    OutSample:=@OutBuffer[Counter];
    OutSample^.Left:=SARLongint(SARLongint((SINCSubArray^[0]*ResamplerBuffer[(ResamplerBufferPosition-8) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[1]*ResamplerBuffer[(ResamplerBufferPosition-7) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[2]*ResamplerBuffer[(ResamplerBufferPosition-6) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[3]*ResamplerBuffer[(ResamplerBufferPosition-5) and ResamplerBufferMask].Left),ResamplerSINCValueBits)+
                                SARLongint((SINCSubArray^[4]*ResamplerBuffer[(ResamplerBufferPosition-4) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[5]*ResamplerBuffer[(ResamplerBufferPosition-3) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[6]*ResamplerBuffer[(ResamplerBufferPosition-2) and ResamplerBufferMask].Left)+
                                           (SINCSubArray^[7]*ResamplerBuffer[(ResamplerBufferPosition-1) and ResamplerBufferMask].Left),ResamplerSINCValueBits),1);
    OutSample^.Right:=SARLongint(SARLongint((SINCSubArray^[0]*ResamplerBuffer[(ResamplerBufferPosition-8) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[1]*ResamplerBuffer[(ResamplerBufferPosition-7) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[2]*ResamplerBuffer[(ResamplerBufferPosition-6) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[3]*ResamplerBuffer[(ResamplerBufferPosition-5) and ResamplerBufferMask].Right),ResamplerSINCValueBits)+
                                 SARLongint((SINCSubArray^[4]*ResamplerBuffer[(ResamplerBufferPosition-4) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[5]*ResamplerBuffer[(ResamplerBufferPosition-3) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[6]*ResamplerBuffer[(ResamplerBufferPosition-2) and ResamplerBufferMask].Right)+
                                            (SINCSubArray^[7]*ResamplerBuffer[(ResamplerBufferPosition-1) and ResamplerBufferMask].Right),ResamplerSINCValueBits),1);
   end;
  end;
{$endif}
 end;
 OutBufferPosition:=0;
 OutBufferSize:=length(OutBuffer);
end;

procedure TpvAudioSoundMusic.MixTo(Buffer:PpvAudioSoundSampleValues;MixVolume:TpvInt32);
var Counter,Pan,VolLeft,VolRight:TpvInt32;
    Sample:TpvAudioSoundMusicBufferSample;
    BufferSample:PpvAudioSoundSampleValue;
begin
 if Active or ((VolumeRampingRemain>0) or ((LastLeft<>0) or (LastRight<>0))) then begin
  Pan:=Panning+65536;
  if Pan<0 then begin
   Pan:=0;
  end else if Pan>=131072 then begin
   Pan:=131071;
  end;
  MixVolume:=SARLongint(Volume*MixVolume,16);
  VolLeft:=SARLongint(AudioEngine.PanningLUT[SARLongint(131072-Pan,1)]*MixVolume,15);
  VolRight:=SARLongint(AudioEngine.PanningLUT[SARLongint(Pan,1)]*MixVolume,15);
{ VolLeft:=SARLongint((131072-Pan)*MixVolume,17);
  VolRight:=SARLongint(Pan*MixVolume,17);}
  if VolLeft<0 then begin
   VolLeft:=0;
  end else if VolLeft>=4096 then begin
   VolLeft:=4095;
  end;
  if VolRight<0 then begin
   VolRight:=0;
  end else if VolRight>=4096 then begin
   VolRight:=4095;
  end;
  VolLeft:=VolLeft shl 12;
  VolRight:=VolRight shl 12;
  if (VolumeLeft<>VolLeft) or (VolumeRight<>VolRight) then begin
   VolumeLeft:=VolLeft;
   VolumeRight:=VolRight;
   if VolumeRampingRemain=0 then begin
    VolumeLeftCurrent:=VolumeLeft;
    VolumeRightCurrent:=VolumeRight;
    VolumeLeftInc:=0;
    VolumeRightInc:=0;
   end else begin
    VolumeLeftInc:=(VolumeLeft-VolumeLeftCurrent) div VolumeRampingRemain;
    VolumeRightInc:=(VolumeRight-VolumeRightCurrent) div VolumeRampingRemain;
   end;
  end;
  BufferSample:=@Buffer^[0];
  for Counter:=1 to AudioEngine.BufferSamples do begin
   if Active then begin
    if OutBufferPosition>=OutBufferSize then begin
     Resample;
    end;
    Sample:=OutBuffer[OutBufferPosition];
    inc(OutBufferPosition);
   end else begin
    Sample.Left:=0;
    Sample.Right:=0;
   end;
   if VolumeRampingRemain>0 then begin
    dec(VolumeRampingRemain);
    VolLeft:=SARLongint(VolumeLeftCurrent,12);
    VolRight:=SARLongint(VolumeRightCurrent,12);
    inc(VolumeLeftCurrent,VolumeLeftInc);
    inc(VolumeRightCurrent,VolumeRightInc);
   end else begin
    VolLeft:=SARLongint(VolumeLeft,12);
    VolRight:=SARLongint(VolumeRight,12);
   end;
   Sample.Left:=SARLongint(Sample.Left*VolLeft,12);
   Sample.Right:=SARLongint(Sample.Right*VolRight,12);
   LastSample:=Sample;
   if (LastLeft<>0) or (LastRight<>0) then begin
    dec(LastLeft,SARLongint(LastLeft+(SARLongint(-LastLeft,31) and $ff),8));
    dec(LastRight,SARLongint(LastRight+(SARLongint(-LastRight,31) and $ff),8));
    inc(Sample.Left,SARLongint(LastLeft,12));
    inc(Sample.Right,SARLongint(LastRight,12));
   end;
   inc(BufferSample^,Sample.Left);
   inc(BufferSample);
   inc(BufferSample^,Sample.Right);
   inc(BufferSample);
  end;
  if VolumeRampingRemain=0 then begin
   VolumeLeftCurrent:=VolumeLeft;
   VolumeRightCurrent:=VolumeRight;
   VolumeLeftInc:=0;
   VolumeRightInc:=0;
  end;
 end;
end;

function TpvAudioSoundMusic.IsPlaying:boolean;
begin
 result:=Active;
end;

constructor TpvAudioSoundSampleResource.Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource;const aMetaResource:TpvMetaResource;const aParallelLoadable:TpvResource.TParallelLoadable);
begin
 inherited Create(aResourceManager,aParent,aMetaResource,aParallelLoadable);
 fSample:=nil;
end;

destructor TpvAudioSoundSampleResource.Destroy;
begin
 FreeAndNil(fSample);
 inherited Destroy;
end;

function TpvAudioSoundSampleResource.BeginLoad(const aStream:TStream):boolean;
begin
 if assigned(MetaData) then begin
  fSample:=AudioInstance.Samples.Load(TPasJSON.GetString(TPasJSONItemObject(MetaData).Properties['name'],FileName),
                                      aStream,
                                      false,
                                      TPasJSON.GetInt64(TPasJSONItemObject(MetaData).Properties['virtualvoices'],1),
                                      TPasJSON.GetInt64(TPasJSONItemObject(MetaData).Properties['loop'],1),
                                      TPasJSON.GetInt64(TPasJSONItemObject(MetaData).Properties['realvoices'],TPasJSON.GetInt64(TPasJSONItemObject(MetaData).Properties['virtualvoices'],1)));
 end else begin
  fSample:=AudioInstance.Samples.Load(FileName,
                                      aStream,
                                      false,
                                      1,
                                      1);
 end;
 result:=assigned(fSample);
end;

procedure TpvAudioSoundSampleResource.FixUp;
begin
 fSample.FixUp;
end;

procedure TpvAudioSoundSampleResource.SetVirtualVoices(VirtualVoices:TpvInt32);
begin
 fSample.SetVirtualVoices(VirtualVoices);
end;

procedure TpvAudioSoundSampleResource.SetRealVoices(RealVoices:TpvInt32);
begin
 fSample.SetVirtualVoices(RealVoices);
end;

function TpvAudioSoundSampleResource.Play(Volume,Panning,Rate:TpvFloat;VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
begin
 result:=fSample.Play(Volume,Panning,Rate,VoiceIndexPointer);
end;

function TpvAudioSoundSampleResource.PlaySpatialization(Volume,Panning,Rate:TpvFloat;Spatialization:LongBool;const Position,Velocity:TpvVector3;const Local:LongBool=false;const VoiceIndexPointer:TpvPointer=nil;PerreservedGlobalVoiceID:TpvID=0):TpvInt32;
begin
 result:=fSample.PlaySpatialization(Volume,Panning,Rate,Spatialization,Position,Velocity,Local,VoiceIndexPointer,PerreservedGlobalVoiceID);
end;

procedure TpvAudioSoundSampleResource.RandomReseek(VoiceNumber:TpvInt32);
begin
 fSample.RandomReseek(VoiceNumber);
end;

procedure TpvAudioSoundSampleResource.ResetLoop(VoiceNumber:TpvInt32);
begin
 fSample.ResetLoop(VoiceNumber);
end;

procedure TpvAudioSoundSampleResource.Stop(VoiceNumber:TpvInt32);
begin
 fSample.Stop(VoiceNumber);
end;

procedure TpvAudioSoundSampleResource.KeyOff(VoiceNumber:TpvInt32);
begin
 fSample.KeyOff(VoiceNumber);
end;

function TpvAudioSoundSampleResource.SetVolume(VoiceNumber:TpvInt32;Volume:TpvFloat):TpvInt32;
begin
 result:=fSample.SetVolume(VoiceNumber,Volume);
end;

function TpvAudioSoundSampleResource.SetPanning(VoiceNumber:TpvInt32;Panning:TpvFloat):TpvInt32;
begin
 result:=fSample.SetPanning(VoiceNumber,Panning);
end;

function TpvAudioSoundSampleResource.SetRate(VoiceNumber:TpvInt32;Rate:TpvFloat):TpvInt32;
begin
 result:=fSample.SetRate(VoiceNumber,Rate);
end;

function TpvAudioSoundSampleResource.SetPosition(VoiceNumber:TpvInt32;Spatialization:LongBool;const Origin,Velocity:TpvVector3;const Local:LongBool):TpvInt32;
begin
 result:=fSample.SetPosition(VoiceNumber,Spatialization,Origin,Velocity,Local);
end;

function TpvAudioSoundSampleResource.SetEffectMix(VoiceNumber:TpvInt32;Active:LongBool):TpvInt32;
begin
 result:=fSample.SetEffectMix(VoiceNumber,Active);
end;

function TpvAudioSoundSampleResource.IsPlaying:boolean;
begin
 result:=fSample.IsPlaying;
end;

function TpvAudioSoundSampleResource.IsVoicePlaying(VoiceNumber:TpvInt32):boolean;
begin
 result:=fSample.IsVoicePlaying(VoiceNumber);
end;

constructor TpvAudioSoundMusicResource.Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource;const aMetaResource:TpvMetaResource;const aParallelLoadable:TpvResource.TParallelLoadable);
begin
 inherited Create(aResourceManager,aParent,aMetaResource,aParallelLoadable);
 fMusic:=nil;
end;

destructor TpvAudioSoundMusicResource.Destroy;
begin
 FreeAndNil(fMusic);
 inherited Destroy;
end;

function TpvAudioSoundMusicResource.BeginLoad(const aStream:TStream):boolean;
begin
 if assigned(MetaData) then begin
  fMusic:=AudioInstance.Musics.Load(TPasJSON.GetString(TPasJSONItemObject(MetaData).Properties['name'],FileName),
                                aStream,
                                false);
 end else begin
  fMusic:=AudioInstance.Musics.Load(FileName,
                                aStream,
                                false);
 end;
 result:=assigned(fMusic);
end;

procedure TpvAudioSoundMusicResource.Play(AVolume,APanning,ARate:TpvFloat;ALoop:boolean);
begin
 fMusic.Play(AVolume,APanning,ARate,ALoop);
end;

procedure TpvAudioSoundMusicResource.Stop;
begin
 fMusic.Stop;
end;

procedure TpvAudioSoundMusicResource.SetVolume(AVolume:TpvFloat);
begin
 fMusic.SetVolume(AVolume);
end;

procedure TpvAudioSoundMusicResource.SetPanning(APanning:TpvFloat);
begin
 fMusic.SetPanning(APanning);
end;

procedure TpvAudioSoundMusicResource.SetRate(ARate:TpvFloat);
begin
 fMusic.SetRate(ARate);
end;

function TpvAudioSoundMusicResource.IsPlaying:boolean;
begin
 result:=fMusic.IsPlaying;
end;

constructor TpvAudioSoundSamples.Create(AAudioEngine:TpvAudio);
begin
 inherited Create;
 AudioEngine:=AAudioEngine;
 HashMap:=TpvAudioStringHashMap.Create(nil);
end;

destructor TpvAudioSoundSamples.Destroy;
begin
 while Count>0 do begin
  TpvAudioSoundSample(inherited Items[0]).Free;
 end;
 Clear;
 HashMap.Free;
 inherited Destroy;
end;

function TpvAudioSoundSamples.GetItem(Index:TpvInt32):TpvAudioSoundSample;
begin
 if (Index>=0) and (Index<Count) then begin
  result:=TpvAudioSoundSample(inherited Items[Index]);
 end else begin
  result:=nil;
 end;
end;

procedure TpvAudioSoundSamples.SetItem(Index:TpvInt32;Item:TpvAudioSoundSample);
begin
 if (Index>=0) and (Index<Count) then begin
  inherited Items[Index]:=TpvPointer(Item);
 end;
end;

function oggread(ptr:TpvPointer;size,nmemb:PasAudioOGGPtrUInt;datasource:TpvPointer):PasAudioOGGPtrUInt; {$ifdef UseExternalOGGVorbisTremorLibrary}cdecl;{$endif}
begin
 result:=TStream(datasource).Read(ptr^,nmemb*size);
end;

function oggseek(datasource:TpvPointer;offset:TpvInt64;whence:TpvInt32):TpvInt32; {$ifdef UseExternalOGGVorbisTremorLibrary}cdecl;{$endif}
begin
 case whence of
  SEEK_SET:begin
   TStream(datasource).Seek(offset,soFromBeginning);
  end;
  SEEK_CUR:begin
   TStream(datasource).Seek(offset,soFromCurrent);
  end;
  SEEK_END:begin
   TStream(datasource).Seek(offset,soFromEnd);
  end;
 end;
 result:=TStream(datasource).Position;
end;

function oggclose(datasource:TpvPointer):TpvInt32; {$ifdef UseExternalOGGVorbisTremorLibrary}cdecl;{$endif}
begin
 result:=0;
end;

function oggtell(datasource:TpvPointer):TpvInt32; {$ifdef UseExternalOGGVorbisTremorLibrary}cdecl;{$endif}
begin
 result:=TStream(datasource).Position;
end;

const _ov_open_callbacks:ov_callbacks=(read_func:oggread;seek_func:oggseek;close_func:oggclose;tell_func:oggtell);

function TpvAudioSoundSamples.Load(Name:TpvRawByteString;Stream:TStream;DoFree:boolean;VirtualVoices:TpvInt32;Loop:TpvUInt32;RealVoices:TpvInt32):TpvAudioSoundSample;
var DataStream:TMemoryStream;
//  WSMPOffset:TpvUInt32;
    DestSample:TpvAudioSoundSample;
 function LoadWAV:boolean;
 type TWaveFileHeader=packed record
       Signatur:array[1..4] of ansichar;
       Size:TpvUInt32;
       WAVESignatur:array[1..4] of ansichar;
      end;
      TWaveFormatHeader=packed record
       FormatTag:TpvUInt16;
       Kaenale:TpvUInt16;
       SamplesProSekunde:TpvUInt32;
       AvgBytesProSekunde:TpvUInt32;
       SampleGroesse:TpvUInt16;
       BitsProSample:TpvUInt16;
      end;
      TWaveSampleHeader=packed record
       Manufacturer:TpvUInt32;
       Produkt:TpvUInt32;
       SamplePeriode:TpvUInt32;
       BasisNote:TpvUInt32;
       PitchFraction:TpvUInt32;
       SMTPEFormat:TpvUInt32;
       SMTPEOffset:TpvUInt32;
       SampleLoops:TpvUInt32;
       SamplerData:TpvUInt32;
      end;
      TWaveSampleLoopHeader=packed record
       Identifier:TpvUInt32;
       SchleifenTyp:TpvUInt32;
       SchleifeStart:TpvUInt32;
       SchleifeEnde:TpvUInt32;
       Fraction:TpvUInt32;
       AnzahlSpielen:TpvUInt32;
      end;
      TWaveInfoHeader=array[1..4] of ansichar;
      TWaveXtraHeader=packed record
       Flags:TpvUInt32;
       Pan:TpvUInt16;
       Volume:TpvUInt16;
       GlobalVolume:TpvUInt16;
       Reserviert:TpvUInt16;
       VibType:TpvUInt8;
       VibSweep:TpvUInt8;
       VibDepth:TpvUInt8;
       VibRate:TpvUInt8;
      end;
      TWaveChunkHeader=packed record
       Signatur:array[1..4] of ansichar;
       Size:TpvUInt32;
      end;
      PSample24Value=^TSample24Value;
      TSample24Value=packed record
       A,B,C:TpvUInt8;
      end;
 const IMAADPCMUnpackTable:array[0..88] of TpvUInt16=(
        7,         8,     9,    10,    11,    12,    13,    14,
        16,       17,    19,    21,    23,    25,    28,    31,
        34,       37,    41,    45,    50,    55,    60,    66,
        73,       80,    88,    97,   107,   118,   130,   143,
        157,     173,   190,   209,   230,   253,   279,   307,
        337,     371,   408,   449,   494,   544,   598,   658,
        724,     796,   876,   963,  1060,  1166,  1282,  1411,
        1552,   1707,  1878,  2066,  2272,  2499,  2749,  3024,
        3327,   3660,  4026,  4428,  4871,  5358,  5894,  6484,
        7132,   7845,  8630,  9493, 10442, 11487, 12635, 13899,
        15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
        32767);
        IMAADPCMIndexTable:array[0..7] of shortint=(-1,-1,-1,-1,2,4,6,8);
 var Header:TWaveFileHeader;
     WaveFormatHeader:TWaveFormatHeader;
     WaveFormatHeaderPCM:TWaveFormatHeader;
     WaveFormatHeaderTemp:TWaveFormatHeader;
     WaveSampleHeader:TWaveSampleHeader;
     WaveSampleLoopHeader:TWaveSampleLoopHeader;
     WaveInfoHeader:TWaveInfoHeader;
     WaveXtraHeader:TWaveXtraHeader;
     WaveChunkHeader:TWaveChunkHeader;
     WaveFormatHeaderExists:boolean;
     WaveFormatHeaderPCMExists:boolean;
     Fact:TpvUInt32;
     Data:TpvUInt32;
     Smpl:TpvUInt32;
     Xtra:TpvUInt32;
     List:TpvUInt32;
     Next:TpvInt32;
     SampleGroesse:TpvUInt32;
     PB:pbyte;
     PW:pword;
     PDW:plongword;
     I:TpvInt32;
     Size,ADPCMLength:TpvInt32;
     ADPCMPointer,ADPCMWorkPointer:pbyte;
     ADPCMCode,ADPCMDiff,ADPCMPredictor,ADPCMStepIndex:TpvInt32;
     ADPCMStep:TpvUInt32;
     Bits,Kaenale:TpvUInt32;
     FloatingPoint:boolean;
     SampleLength{,LengthEx},SampleRate:TpvUInt32;
//   Panning:boolean;
     DataPointer:TpvPointer;
     RealSize:TpvInt32;
     SchleifeStart:TpvUInt32;
     SchleifeEnde:TpvUInt32;
     SustainSchleifeStart:TpvUInt32;
     SustainSchleifeEnde:TpvUInt32;
//   Pan,Volume,GlobalVolume:TpvUInt32;
     Counter,EndValue:TpvInt32;
     LW32:TpvUInt32;
     L32:TpvInt32 absolute LW32;
     S8:pshortint;
     S16:psmallint;
     S24:PSample24Value;
     S32:PpvAudioInt32;
     S32F:PpvAudioFloat;
     S32Out:PpvAudioInt32;
     SampleData:TpvPointer;
     SampleDataSize:TpvUInt32;
//   ItemNr:TpvInt32;
     LoopType:TpvUInt8;
     SustainLoopType:TpvUInt8;
 begin
  result:=false;
  if DataStream.Seek(0,soFromBeginning)<>0 then begin
   exit;
  end;
  if DataStream.Read(Header,sizeof(TWaveFileHeader))<>sizeof(TWaveFileHeader) then begin
   exit;
  end;
  if (Header.Signatur<>'RIFF') and (Header.Signatur<>'LIST') then begin
   exit;
  end;
  if (Header.WAVESignatur<>'WAVE') and (Header.WAVESignatur<>'wave') then begin
   exit;
  end;
 //IF ASSIGNED(WSMPOffset) THEN WSMPOffset^:=0;
  FILLCHAR(WaveFormatHeader,sizeof(TWaveFormatHeader),#0);
  FILLCHAR(WaveFormatHeaderPCM,sizeof(TWaveFormatHeader),#0);
  WaveFormatHeaderExists:=false;
  WaveFormatHeaderPCMExists:=false;
  Fact:=0;
  Data:=0;
  Smpl:=0;
  Xtra:=0;
  List:=0;
  LoopType:=SoundLoopModeNONE;
  SustainLoopType:=SoundLoopModeNONE;
  while (DataStream.Position+8)<DataStream.Size do begin
   if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
    result:=false;
    exit;
   end;
   Next:=DataStream.Position+TpvInt32(WaveChunkHeader.Size);
   if (WaveChunkHeader.Signatur='fmt ') or (WaveChunkHeader.Signatur='fmt'#0) then begin
    if not WaveFormatHeaderExists then begin
     WaveFormatHeaderExists:=true;
     if DataStream.Read(WaveFormatHeader,sizeof(TWaveFormatHeader))<>sizeof(TWaveFormatHeader) then begin
      result:=false;
      exit;
     end;
    end;
   end else if (WaveChunkHeader.Signatur='pcm ') or (WaveChunkHeader.Signatur='pcm'#0) then begin
    if not WaveFormatHeaderPCMExists then begin
     WaveFormatHeaderPCMExists:=true;
     if DataStream.Read(WaveFormatHeaderPCM,sizeof(TWaveFormatHeader))<>sizeof(TWaveFormatHeader) then begin
      result:=false;
      exit;
     end;
    end;
   end else if WaveChunkHeader.Signatur='fact' then begin
    if Fact=0 then begin
     if DataStream.Read(Fact,4)<>4 then begin
      result:=false;
      exit;
     end;
    end;
   end else if WaveChunkHeader.Signatur='data' then begin
    if Data=0 then begin
     Data:=DataStream.Position-sizeof(TWaveChunkHeader);
    end;
   end else if WaveChunkHeader.Signatur='smpl' then begin
    if Smpl=0 then begin
     Smpl:=DataStream.Position-sizeof(TWaveChunkHeader);
    end;
   end else if WaveChunkHeader.Signatur='xtra' then begin
    if Xtra=0 then begin
     Xtra:=DataStream.Position-sizeof(TWaveChunkHeader);
    end;
   end else if WaveChunkHeader.Signatur='list' then begin
    if List=0 then begin
     List:=DataStream.Position-sizeof(TWaveChunkHeader);
    end;
   end else if WaveChunkHeader.Signatur='wsmp' then begin
//  WSMPOffset:=DataStream.Position;
   end;
   if DataStream.Seek(Next,soFromBeginning)<>Next then begin
    result:=false;
    exit;
   end;
  end;
  if WaveFormatHeaderExists and WaveFormatHeaderPCMExists then begin
   if (SwapWordLittleEndian(WaveFormatHeader.FormatTag)<>1) and (SwapWordLittleEndian(WaveFormatHeader.FormatTag)<>3) then begin
    WaveFormatHeaderTemp:=WaveFormatHeader;
    WaveFormatHeader:=WaveFormatHeaderPCM;
    WaveFormatHeaderPCM:=WaveFormatHeaderTemp;
   end else begin
 // WaveFormatHeaderPCMExists:=false;
   end;
  end;
  if (SwapWordLittleEndian(WaveFormatHeader.FormatTag)=1) or (SwapWordLittleEndian(WaveFormatHeader.FormatTag)=3) or (SwapWordLittleEndian(WaveFormatHeader.FormatTag)=$fffe) then begin
   if (SwapWordLittleEndian(WaveFormatHeader.Kaenale)<>1) and (SwapWordLittleEndian(WaveFormatHeader.Kaenale)<>2) then begin
    result:=false;
    exit;
   end;
   if (SwapWordLittleEndian(WaveFormatHeader.BitsProSample)<>8) and (SwapWordLittleEndian(WaveFormatHeader.BitsProSample)<>16) and (SwapWordLittleEndian(WaveFormatHeader.BitsProSample)<>24) and (SwapWordLittleEndian(WaveFormatHeader.BitsProSample)<>32) then begin
    result:=false;
    exit;
   end;
  end else if SwapWordLittleEndian(WaveFormatHeader.FormatTag)=17 then begin
   if SwapWordLittleEndian(WaveFormatHeader.Kaenale)<>1 then begin
    result:=false;
    exit;
   end;
   if SwapWordLittleEndian(WaveFormatHeader.BitsProSample)<>4 then begin
    result:=false;
    exit;
   end;
  end else begin
   result:=false;
   exit;
  end;
  if Data=0 then begin
   result:=false;
   exit;
  end;
  if DataStream.Seek(Data,soFromBeginning)<>TpvInt32(Data) then begin
   result:=false;
   exit;
  end;
  if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
   result:=false;
   exit;
  end;
  Bits:=SwapWordLittleEndian(WaveFormatHeader.BitsProSample);
  Kaenale:=SwapWordLittleEndian(WaveFormatHeader.Kaenale);
  FloatingPoint:=WaveFormatHeader.FormatTag=3;
  if SwapWordLittleEndian(WaveFormatHeader.FormatTag)=17 then begin
   SampleGroesse:=1;
   SampleLength:=(((SwapDWordLittleEndian(WaveChunkHeader.Size)-4)*2)+1) div SampleGroesse;
// LengthEx:=SampleLength;
   FloatingPoint:=false;
  end else begin
   SampleGroesse:=(Kaenale*(Bits shr 3));
   SampleLength:=SwapDWordLittleEndian(WaveChunkHeader.Size) div SampleGroesse;
// LengthEx:=SwapDWordLittleEndian(WaveChunkHeader.Size) div (Bits shr 3);
  end;
  SampleRate:=SwapDWordLittleEndian(WaveFormatHeader.SamplesProSekunde);
//Panning:=false;
  case SwapWordLittleEndian(WaveFormatHeader.FormatTag) of
   1,3,$fffe:begin
    GetMem(DataPointer,SwapDWordLittleEndian(WaveChunkHeader.Size));
    if DataStream.Read(DataPointer^,SwapDWordLittleEndian(WaveChunkHeader.Size))<>TpvInt32(SwapDWordLittleEndian(WaveChunkHeader.Size)) then begin
     result:=false;
     exit;
    end;
    RealSize:=WaveChunkHeader.Size;
    if (Bits=8) and (RealSize>0) then begin
     PB:=DataPointer;
     for I:=1 to RealSize do begin
      PB^:=PB^ xor $80;
      inc(PB);
     end;
    end;
    if (Bits=16) and (RealSize>0) then begin
     PW:=DataPointer;
     for I:=1 to RealSize do begin
      SwapLittleEndianData16(PW^);
      inc(PW);
     end;
    end;
    if (Bits=32) and (RealSize>0) then begin
     PDW:=DataPointer;
     for I:=1 to RealSize do begin
      SwapLittleEndianData32(PDW^);
      inc(PDW);
     end;
    end;
   end;
   17:begin
    Bits:=16;
    ADPCMLength:=SwapDWordLittleEndian(WaveChunkHeader.Size);
    RealSize:=((ADPCMLength-4)*4)+1;
    GetMem(DataPointer,RealSize);
    GetMem(ADPCMPointer,ADPCMLength);
    if DataStream.Read(ADPCMPointer^,ADPCMLength)<>ADPCMLength then begin
     result:=false;
     exit;
    end;
    ADPCMWorkPointer:=ADPCMPointer;
    ADPCMPredictor:=psmallint(ADPCMWorkPointer)^;
    psmallint(DataPointer)^:=ADPCMPredictor;
    ADPCMStepIndex:=TpvUInt8(TpvPointer(@PAnsiChar(ADPCMWorkPointer)[2])^);
    inc(ADPCMWorkPointer,4);
    ADPCMLength:=(ADPCMLength-4) shl 1;
    for I:=0 to ADPCMLength-1 do begin
     ADPCMCode:=TpvUInt8(TpvPointer(@PAnsiChar(ADPCMWorkPointer)[I shr 1])^);
     ADPCMCode:=(ADPCMCode shr ((I and 1) shl 2)) and $f;
     ADPCMStep:=IMAADPCMUnpackTable[ADPCMStepIndex];
     ADPCMDiff:=ADPCMStep shr 3;
     if (ADPCMCode and 1)<>0 then inc(ADPCMDiff,ADPCMStep shr 2);
     if (ADPCMCode and 2)<>0 then inc(ADPCMDiff,ADPCMStep shr 1);
     if (ADPCMCode and 4)<>0 then inc(ADPCMDiff,ADPCMStep);
     if (ADPCMCode and 8)<>0 then ADPCMDiff:=-ADPCMDiff;
     inc(ADPCMPredictor,ADPCMDiff);
     if ADPCMPredictor<-$8000 then begin
      ADPCMPredictor:=-$8000;
     end else if ADPCMPredictor>$7fff then begin
      ADPCMPredictor:=$7fff;
     end;
     smallint(TpvPointer(@PAnsiChar(DataPointer)[(I+1)*sizeof(smallint)])^):=ADPCMPredictor;
     inc(ADPCMStepIndex,IMAADPCMIndexTable[ADPCMCode and 7]);
     if ADPCMStepIndex<0 then begin
      ADPCMStepIndex:=0;
     end else if ADPCMStepIndex>88 then begin
      ADPCMStepIndex:=88;
     end;
    end;
    FreeMem(ADPCMPointer);
   end;
   else begin
 // DataPointer:=NIL;
    result:=false;
    exit;
   end;
  end;
  if Smpl<>0 then begin
   if DataStream.Seek(Smpl,soFromBeginning)<>TpvInt32(Smpl) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveSampleHeader,sizeof(TWaveSampleHeader))<>sizeof(TWaveSampleHeader) then begin
    result:=false;
    exit;
   end;
   if SwapDWordLittleEndian(WaveSampleHeader.SampleLoops)>1 then begin
    if DataStream.Read(WaveSampleLoopHeader,sizeof(TWaveSampleLoopHeader))<>sizeof(TWaveSampleLoopHeader) then begin
     result:=false;
     exit;
    end;
    case WaveSampleLoopHeader.SchleifenTyp of
     1:SustainLoopType:=SoundLoopModePINGPONG;
     2:SustainLoopType:=SoundLoopModeBACKWARD;
     else SustainLoopType:=SoundLoopModeFORWARD;
    end;
    SustainSchleifeStart:=SwapDWordLittleEndian(WaveSampleLoopHeader.SchleifeStart);
    SustainSchleifeEnde:=SwapDWordLittleEndian(WaveSampleLoopHeader.SchleifeEnde);
    if SustainSchleifeStart>=SustainSchleifeEnde then begin
     SustainLoopType:=SoundLoopModeNONE;
    end;
   end;
   if SwapDWordLittleEndian(WaveSampleHeader.SampleLoops)>0 then begin
    if DataStream.Read(WaveSampleLoopHeader,sizeof(TWaveSampleLoopHeader))<>sizeof(TWaveSampleLoopHeader) then begin
     result:=false;
     exit;
    end;
    case WaveSampleLoopHeader.SchleifenTyp of
     1:LoopType:=SoundLoopModePINGPONG;
     2:LoopType:=SoundLoopModeBACKWARD;
     else LoopType:=SoundLoopModeFORWARD;
    end;
    SchleifeStart:=SwapDWordLittleEndian(WaveSampleLoopHeader.SchleifeStart);
    SchleifeEnde:=SwapDWordLittleEndian(WaveSampleLoopHeader.SchleifeEnde);
    if SchleifeStart>=SchleifeEnde then begin
     LoopType:=SoundLoopModeNONE;
    end;
   end;
  end;
  if List<>0 then begin
   if DataStream.Seek(List,soFromBeginning)<>TpvInt32(List) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveInfoHeader,sizeof(TWaveInfoHeader))<>sizeof(TWaveInfoHeader) then begin
    result:=false;
    exit;
   end;
   if WaveInfoHeader='INFO' then begin
    Size:=DataStream.Position+TpvInt32(SwapDWordLittleEndian(WaveChunkHeader.Size));
    while (DataStream.Position+8)<Size do begin
     if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
      result:=false;
      exit;
     end;
     Next:=DataStream.Position+TpvInt32(SwapDWordLittleEndian(WaveChunkHeader.Size));
     if DataStream.Seek(Next,soFromBeginning)<>Next then begin
      result:=false;
      exit;
     end;
    end;
   end;
  end;
  if Xtra<>0 then begin
   if DataStream.Seek(Xtra,soFromBeginning)<>TpvInt32(Xtra) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveChunkHeader,sizeof(TWaveChunkHeader))<>sizeof(TWaveChunkHeader) then begin
    result:=false;
    exit;
   end;
   if DataStream.Read(WaveXtraHeader,sizeof(TWaveXtraHeader))<>sizeof(TWaveXtraHeader) then begin
    result:=false;
    exit;
   end;
   SwapLittleEndianData32(WaveXtraHeader.Flags);
   SwapLittleEndianData16(WaveXtraHeader.Pan);
   SwapLittleEndianData16(WaveXtraHeader.Volume);
   SwapLittleEndianData16(WaveXtraHeader.GlobalVolume);
   SwapLittleEndianData16(WaveXtraHeader.Reserviert);
{  Pan:=WaveXtraHeader.Pan;
   Volume:=WaveXtraHeader.Volume;
   GlobalVolume:=WaveXtraHeader.GlobalVolume;}
  end;
  if assigned(DataPointer) then begin
   SampleDataSize:=SampleLength*2*sizeof(TpvInt32);
   GetMem(SampleData,SampleDataSize);
   S32Out:=SampleData;
   case Kaenale of
    1:begin
     EndValue:=SampleLength;
     case Bits of
      8:begin
       S8:=DataPointer;
       for Counter:=1 to EndValue do begin
        S32Out^:=S8^ shl 8;
        inc(S32Out);
        S32Out^:=S8^ shl 8;
        inc(S32Out);
        inc(S8);
       end;
      end;
      16:begin
       S16:=DataPointer;
       for Counter:=1 to EndValue do begin
        S32Out^:=S16^;
        inc(S32Out);
        S32Out^:=S16^;
        inc(S32Out);
        inc(S16);
       end;
      end;
      24:begin
       S24:=DataPointer;
       for Counter:=1 to EndValue do begin
        LW32:=(S24^.A shl 8) or (S24^.B shl 16) or (S24^.C shl 24);
        S32Out^:=SARLongint(L32,8);
        inc(S32Out);
        S32Out^:=SARLongint(L32,8);
        inc(S32Out);
        inc(S24);
       end;
      end;
      32:begin
       if FloatingPoint then begin
        S32F:=DataPointer;
        for Counter:=1 to EndValue do begin
         S32Out^:=round(S32F^*32767);
         inc(S32Out);
         S32Out^:=round(S32F^*32767);
         inc(S32Out);
         inc(S32F);
        end;
       end else begin
        S32:=DataPointer;
        for Counter:=1 to EndValue do begin
         S32Out^:=SARLongint(S32^,16);
         inc(S32Out);
         S32Out^:=SARLongint(S32^,16);
         inc(S32Out);
         inc(S32);
        end;
       end;
      end;
     end;
    end;
    2:begin
     EndValue:=SampleLength*2;
     case Bits of
      8:begin
       S8:=DataPointer;
       for Counter:=1 to EndValue do begin
        S32Out^:=S8^ shl 8;
        inc(S8);
        inc(S32Out);
       end;
      end;
      16:begin
       S16:=DataPointer;
       for Counter:=1 to EndValue do begin
        S32Out^:=S16^;
        inc(S16);
        inc(S32Out);
       end;
      end;
      24:begin
       S24:=DataPointer;
       for Counter:=1 to EndValue do begin
        LW32:=(S24^.A shl 8) or (S24^.B shl 16) or (S24^.C shl 24);
        S32Out^:=SARLongint(L32,8);
        inc(S24);
        inc(S32Out);
       end;
      end;
      32:begin
       if FloatingPoint then begin
        S32F:=DataPointer;
        for Counter:=1 to EndValue do begin
         S32Out^:=round(S32F^*32767);
         inc(S32F);
         inc(S32Out);
        end;
       end else begin
        S32:=DataPointer;
        for Counter:=1 to EndValue do begin
         S32Out^:=SARLongint(S32^,16);
         inc(S32);
         inc(S32Out);
        end;
       end;
      end;
     end;
    end;
   end;
   try
    DestSample.SampleLength:=SampleLength;
    DestSample.SampleRate:=SampleRate;
    DestSample.Loop.Mode:=LoopType;
    DestSample.Loop.StartSample:=SchleifeStart;
    DestSample.Loop.EndSample:=SchleifeEnde;
    DestSample.SustainLoop.Mode:=SustainLoopType;
    DestSample.SustainLoop.StartSample:=SustainSchleifeStart;
    DestSample.SustainLoop.EndSample:=SustainSchleifeEnde;
    GetMem(DestSample.Data,(SampleLength+(2*SampleFixUp))*2*sizeof(TpvInt32));
    FillChar(DestSample.Data^,(SampleLength+(2*SampleFixUp))*2*sizeof(TpvInt32),#0);
    inc(PpvAudioInt32(DestSample.Data),2*SampleFixUp);
    System.Move(SampleData^,DestSample.Data^,SampleLength*2*sizeof(TpvInt32));
   finally
    FreeMem(SampleData);
    FreeMem(DataPointer);
   end;
  end;
  result:=true;
 end;
 function LoadOGG:boolean;
 var vf:POggVorbis_File;
     FinalData:PpvAudioInt32s;
     Data:PSmallints;
     DataEx:PSmallint;
     Channels,SampleRate,TotalSamples,Total,BytesIn,bitstream,i,Bytes:TpvInt32;
     info:Pvorbis_info;
 begin
  result:=false;
  New(vf);
  try
   if DataStream.Seek(0,soFromBeginning)=0 then begin
    if ov_open_callbacks(DataStream,vf,nil,0,_ov_open_callbacks)=0 then begin
     info:=ov_info(vf,-1);
     Channels:=info^.channels;
     SampleRate:=info^.rate;
     TotalSamples:=ov_pcm_total(vf,-1);
     GetMem(Data,(TotalSamples+4096)*Channels*sizeof(smallint));
     Bytes:=TotalSamples*Channels*sizeof(smallint);
     FillChar(Data^,Bytes,AnsiChar(#0));
     DataEx:=@Data[0];
     Total:=0;
     bitstream:=0;
     while Total<Bytes do begin
      BytesIn:=ov_read(vf,DataEx,Bytes-Total,@bitstream);
      if BytesIn=OV_HOLE then begin
       continue;
      end else if (BytesIn=OV_EBADLINK) or (BytesIn=OV_EINVAL) or (BytesIn=0) then begin
       break;
      end;
      inc(PAnsiChar(TpvPointer(DataEx)),BytesIn);
      inc(Total,BytesIn);
     end;
     if Total>0 then begin
      GetMem(FinalData,(TotalSamples+(2*SampleFixUp))*2*sizeof(TpvInt32));
      FillChar(FinalData^,(TotalSamples+(2*SampleFixUp))*2*sizeof(TpvInt32),#0);
      inc(PpvAudioInt32(FinalData),2*SampleFixUp);
      case Channels of
       1:begin
        // Mono
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=Data^[i];
         FinalData^[(i*2)+1]:=Data^[i];
        end;
       end;
       2:begin
        // Left, right
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=Data^[(i*2)+0];
         FinalData^[(i*2)+1]:=Data^[(i*2)+1];
        end;
       end;
       3:begin
        // Left, middle, right
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=SARLongint(Data^[(i*3)+0]+Data^[(i*3)+1],1);
         FinalData^[(i*2)+1]:=SARLongint(Data^[(i*3)+2]+Data^[(i*3)+1],1);
        end;
       end;
       4:begin
        // Front left, front right, back left, back right
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=SARLongint(Data^[(i*4)+0]+Data^[(i*4)+2],1);
         FinalData^[(i*2)+1]:=SARLongint(Data^[(i*4)+1]+Data^[(i*4)+3],1);
        end;
       end;
       5:begin
        // Front left, front middle, front right, back left, back right
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=(Data^[(i*5)+0]+Data^[(i*5)+1]+Data^[(i*5)+3]) div 3;
         FinalData^[(i*2)+1]:=(Data^[(i*5)+2]+Data^[(i*5)+1]+Data^[(i*5)+4]) div 3;
        end;
       end;
       6:begin
        // Front left, front middle, front right, back left, back right, LFE channel (subwoofer)
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=SARLongint(Data^[(i*6)+0]+Data^[(i*6)+1]+Data^[(i*6)+3]+Data^[(i*6)+5],2);
         FinalData^[(i*2)+1]:=SARLongint(Data^[(i*6)+2]+Data^[(i*6)+1]+Data^[(i*6)+4]+Data^[(i*6)+5],2);
        end;
       end;
       else begin
        // Undefined, so get only the first two channels in account
        for i:=0 to TotalSamples-1 do begin
         FinalData^[(i*2)+0]:=Data^[(i*Channels)+0];
         FinalData^[(i*2)+1]:=Data^[(i*Channels)+1];
        end;
       end;
      end;
      FreeMem(Data);
      DestSample.SampleLength:=TotalSamples;
      DestSample.SampleRate:=SampleRate;
      DestSample.Loop.Mode:=SoundLoopModeNONE;
      DestSample.Loop.StartSample:=0;
      DestSample.Loop.EndSample:=0;
      DestSample.SustainLoop.Mode:=SoundLoopModeNONE;
      DestSample.SustainLoop.StartSample:=0;
      DestSample.SustainLoop.EndSample:=0;
      DestSample.Data:=TpvPointer(FinalData);
      result:=true;
     end else begin
      FreeMem(Data);
     end;
     ov_clear(vf);
    end;
   end;
  finally
   Dispose(vf);
  end;
 end;
var OK:boolean;
    Signature:array[0..3] of ansichar;
begin
 try
  if Loop=0 then begin
   Name:=Name+#0+'oneshot';
  end else if Loop>1 then begin
   Name:=Name+#0+'loop';
  end;
  result:=HashMap[Name];
  if not assigned(result) then begin
   AudioEngine.CriticalSection.Enter;
   OK:=false;
   try
    DestSample:=TpvAudioSoundSample.Create(AudioEngine,self);
    try
     if assigned(Stream) and (Stream.Size>4) then begin
      DestSample.SampleVirtualVoices:=VirtualVoices;
      if RealVoices<=0 then begin
       DestSample.SampleRealVoices:=VirtualVoices;
      end else begin
       DestSample.SampleRealVoices:=RealVoices;
      end;
      DestSample.SetVirtualVoices(VirtualVoices);
      DestSample.SetRealVoices(RealVoices);
      DataStream:=TMemoryStream.Create;
      try
       if Stream.Seek(0,soFromBeginning)=0 then begin
        DataStream.LoadFromStream(Stream);
        if DataStream.Seek(0,soFromBeginning)=0 then begin
         if DataStream.Read(Signature,SizeOf(Signature))=SizeOf(Signature) then begin
          if DataStream.Seek(0,soFromBeginning)=0 then begin
           if (Signature[0]='O') and (Signature[1]='g') and (Signature[2]='g') and (Signature[3]='S') then begin
            OK:=LoadOGG;
           end else if (Signature[0]='R') and (Signature[1]='I') and (Signature[2]='F') and (Signature[3]='F') then begin
            OK:=LoadWAV;
           end else begin
            OK:=false;
           end;
          end;
         end;
        end;
       end;
      finally
       DataStream.Free;
      end;
     end;
     if OK then begin
      if Loop>1 then begin
       if DestSample.Loop.Mode=SoundLoopModeNONE then begin
        DestSample.Loop.Mode:=SoundLoopModeFORWARD;
        DestSample.Loop.StartSample:=0;
        DestSample.Loop.EndSample:=DestSample.SampleLength;
       end;
      end else if Loop=0 then begin
       DestSample.Loop.Mode:=SoundLoopModeNONE;
       DestSample.SustainLoop.Mode:=SoundLoopModeNONE;
      end;
      DestSample.FixUp;
      Add(DestSample);
      DestSample.Name:=Name;
      HashMap.Add(Name,DestSample);
      result:=DestSample;
      DestSample:=nil;
     end;
    finally
     if assigned(DestSample) then begin
      DestSample.Free;
     end;
    end;
   finally
    AudioEngine.CriticalSection.Leave;
   end;
  end;
  if assigned(result) then begin
   result.IncRef;
  end;
 finally
  if DoFree then begin
   Stream.Free;
  end;
 end;
end;

constructor TpvAudioSoundMusics.Create(AAudioEngine:TpvAudio);
begin
 inherited Create;
 AudioEngine:=AAudioEngine;
 HashMap:=TpvAudioStringHashMap.Create(nil);
end;

destructor TpvAudioSoundMusics.Destroy;
begin
 while Count>0 do begin
  TpvAudioSoundMusic(inherited Items[0]).Free;
 end;
 Clear;
 HashMap.Free;
 inherited Destroy;
end;

function TpvAudioSoundMusics.GetItem(Index:TpvInt32):TpvAudioSoundMusic;
begin
 if (Index>=0) and (Index<Count) then begin
  result:=TpvAudioSoundMusic(inherited Items[Index]);
 end else begin
  result:=nil;
 end;
end;

procedure TpvAudioSoundMusics.SetItem(Index:TpvInt32;Item:TpvAudioSoundMusic);
begin
 if (Index>=0) and (Index<Count) then begin
  inherited Items[Index]:=TpvPointer(Item);
 end;
end;

function TpvAudioSoundMusics.Load(Name:TpvRawByteString;Stream:TStream;DoFree:boolean=true):TpvAudioSoundMusic;
var vf:POggVorbis_File;
    Data:TMemoryStream;
    Music:TpvAudioSoundMusic;
    info:Pvorbis_info;
begin
 try
  result:=HashMap[Name];
  if not assigned(result) then begin
   AudioEngine.CriticalSection.Enter;
   try
    New(vf);
    try
     Data:=TMemoryStream.Create;
     try
      if Stream.Seek(0,soFromBeginning)=0 then begin
       Data.LoadFromStream(Stream);
       if Data.Seek(0,soFromBeginning)=0 then begin
        if ov_open_callbacks(Data,vf,nil,0,_ov_open_callbacks)=0 then begin
         Music:=TpvAudioSoundMusic.Create(AudioEngine,self);
         Music.vf:=vf;
         Music.Data:=Data;
         info:=ov_info(vf,-1);
         Music.Channels:=info^.channels;
         Music.SampleRate:=info^.rate;
         Add(Music);
         Music.Name:=Name;
         HashMap.Add(Name,Music);
         result:=Music;
         Music.InitSINC;
         vf:=nil;
         Data:=nil;
        end else begin
         Data.Free;
         Dispose(vf);
         vf:=nil;
        end;
       end else begin
        Data.Free;
        Dispose(vf);
        vf:=nil;
       end;
      end else begin
       Data.Free;
       Dispose(vf);
       vf:=nil;
      end;
     except
      if assigned(Data) then begin
       Data.Destroy;
      end;
     end;
    except
     if assigned(vf) then begin
      Dispose(vf);
     end;
    end;
   finally
    AudioEngine.CriticalSection.Leave;
   end;
  end;
 finally
  if DoFree then begin
   Stream.Free;
  end;
  Name:='';
 end;
end;

constructor TpvAudioPitchShifter.Create(AAudioEngine:TpvAudio);
var i:TpvInt32;
begin
 inherited Create;
 AudioEngine:=AAudioEngine;
 for i:=0 to PitchShifterBufferSize-1 do begin
  PitchShifterFadeBuffer[i]:=round((0.5+(0.5*cos(((i/(PitchShifterBufferSize-1))-0.5)*2*pi)))*4096);
 end;
 Reset;
end;

destructor TpvAudioPitchShifter.Destroy;
begin
 inherited Destroy;
end;

procedure TpvAudioPitchShifter.Reset;
begin
 FillChar(WorkBuffer,SizeOf(TpvAudioPitchShifterBuffer),AnsiChar(#0));
 p1:=0;
 p2:=(PitchShifterBufferSize shr 1) shl PitchShifterOutputShift;
 InputPointer:=0;
 Factor:=1;
end;

procedure TpvAudioPitchShifter.Process(Buffer:TpvPointer;Samples:TpvInt32);
var Sample:PpvAudioSoundSampleStereoValue;
    Counter,v1,v2:TpvInt32;
    OutputIncrement,up1,up2:TpvUInt32;
begin
 Sample:=Buffer;
 OutputIncrement:=round(Factor*PitchShifterOutputLen)-PitchShifterOutputLen;
 if Factor<>1.0 then begin
  for Counter:=1 to Samples do begin
   WorkBuffer[InputPointer and PitchShifterBufferMask]:=Sample^;
   up1:=p1 shr PitchShifterOutputShift;
   up2:=p2 shr PitchShifterOutputShift;
   v1:=PitchShifterFadeBuffer[up1 and PitchShifterBufferMask];
   v2:=PitchShifterFadeBuffer[up2 and PitchShifterBufferMask];
{$ifdef UseDIV}
   Sample^[0]:=((WorkBuffer[(InputPointer-up1) and PitchShifterBufferMask,0]*v1)+
                (WorkBuffer[(InputPointer-up2) and PitchShifterBufferMask,0]*v2)) div 4096;
   Sample^[1]:=((WorkBuffer[(InputPointer-up1) and PitchShifterBufferMask,1]*v1)+
                (WorkBuffer[(InputPointer-up2) and PitchShifterBufferMask,1]*v2)) div 4096;
{$else}
   Sample^[0]:=SARLongint((WorkBuffer[(InputPointer-up1) and PitchShifterBufferMask,0]*v1)+
                          (WorkBuffer[(InputPointer-up2) and PitchShifterBufferMask,0]*v2),12);
   Sample^[1]:=SARLongint((WorkBuffer[(InputPointer-up1) and PitchShifterBufferMask,1]*v1)+
                          (WorkBuffer[(InputPointer-up2) and PitchShifterBufferMask,1]*v2),12);
{$endif}
   dec(p1,OutputIncrement);
   dec(p2,OutputIncrement);
   InputPointer:=(InputPointer+1) and PitchShifterBufferMask;
   inc(Sample);
  end;
 end else begin
  for Counter:=1 to Samples do begin
   WorkBuffer[InputPointer and PitchShifterBufferMask]:=Sample^;
   InputPointer:=(InputPointer+1) and PitchShifterBufferMask;
   dec(p1,OutputIncrement);
   dec(p2,OutputIncrement);
   inc(Sample);
  end;
 end;
end;

constructor TpvAudioReverb.Create(AAudioEngine:TpvAudio);
var i:TpvInt32;
begin
 inherited Create;
 AudioEngine:=AAudioEngine;
 PreDelay:=6400;
 CombFilterSeparation:=1400;
 RoomSize:=700;
 FeedBack:=0.82;
 Absortion:=1000;
 Dry:=0.75;
 Wet:=0.25;
 AllPassFilters:=16;
 FillChar(AllPassBuffer,SizeOf(AllPassBuffer),AnsiChar(#0));
 FillChar(Counter,SizeOf(Counter),AnsiChar(#0));
 LastLowPassLeft:=0;
 LastLowPassRight:=0;
 LeftBuffer:=nil;
 RightBuffer:=nil;
 LeftDelayedCounter:=0;
 RightDelayedCounter:=0;
 LeftCounter:=0;
 RightCounter:=0;
 SampleBufferSize:=TPasMPMath.RoundUpToPowerOfTwo(AudioEngine.SampleRate*2);
 SampleBufferMask:=SampleBufferSize-1;
 for i:=0 to length(AllPassBuffer)-1 do begin
  SetLength(AllPassBuffer[i],SampleBufferSize);
 end;
 SetLength(LeftBuffer,SampleBufferSize);
 SetLength(RightBuffer,SampleBufferSize);
 Reset;
end;

destructor TpvAudioReverb.Destroy;
var i:TpvInt32;
begin
 for i:=0 to length(AllPassBuffer)-1 do begin
  SetLength(AllPassBuffer[i],0);
 end;
 SetLength(LeftBuffer,0);
 SetLength(RightBuffer,0);
 inherited Destroy;
end;

procedure TpvAudioReverb.Reset;
var i:TpvInt32;
begin
 for i:=0 to length(AllPassBuffer)-1 do begin
  FillChar(AllPassBuffer[i,0],length(AllPassBuffer[i])*SizeOf(TpvAudioReverbAllPassBufferSample),AnsiChar(#0));
 end;
 FillChar(Counter,sizeof(Counter),AnsiChar(#0));
 FillChar(LeftBuffer[0],length(LeftBuffer)*SizeOf(TpvInt32),AnsiChar(#0));
 FillChar(RightBuffer[0],length(RightBuffer)*SizeOf(TpvInt32),AnsiChar(#0));
 LastLowPassLeft:=0;
 LastLowPassRight:=0;
 LeftDelayedCounter:=0;
 RightDelayedCounter:=0;
 LeftCounter:=0;
 RightCounter:=0;
 Init;
end;

procedure TpvAudioReverb.Init;
var AllPassFilterCounter,TimeEx,Time:TpvInt32;
begin
 if AllPassFilters>=MaxReverbAllPassFilters then begin
  AllPassFilters:=MaxReverbAllPassFilters;
 end;
 CutOff:=round(sin(Absortion*(0.0001*(44100/AudioEngine.SampleRate))*pi*0.5)*4096);
 LeftCounter:=(SampleBufferSize-4) and SampleBufferMask;
 RightCounter:=(SampleBufferSize-4) and SampleBufferMask;
 LeftDelayedCounter:=(LeftCounter-round((PreDelay*0.00001)*AudioEngine.SampleRate)) and SampleBufferMask;
 RightDelayedCounter:=(RightCounter-round(((PreDelay*0.00001)+(CombFilterSeparation*0.00001))*AudioEngine.SampleRate)) and SampleBufferMask;
 TimeEx:=trunc(min(max(((RoomSize*0.01)/0.17)+0.5,1),640));
 for AllPassFilterCounter:=0 to AllPassFilters-1 do begin
  Time:=(TimeEx*(AllPassFilterCounter+1))+(AllPassFilterCounter*AllPassFilterCounter);
  Counter[AllPassFilterCounter,0]:=(SampleBufferSize-4) and SampleBufferMask;
  Counter[AllPassFilterCounter,2]:=(Counter[AllPassFilterCounter,0]-Time) and SampleBufferMask;
  Counter[AllPassFilterCounter,1]:=(SampleBufferSize-4) and SampleBufferMask;
  Counter[AllPassFilterCounter,3]:=(Counter[AllPassFilterCounter,1]-(Time+round(AllPassFilterCounter*1.3))) and SampleBufferMask;
 end;
end;

procedure TpvAudioReverb.Process(Buffer:TpvPointer;Samples:TpvInt32);
const ExtraAccurateBits=0;
      ExtraAccurateLength=1 shl ExtraAccurateBits;
var Sample:PpvAudioSoundSampleStereoValue;
    SampleCounter,AllPassFilterCounter,WetFactor,DryFactor,FeedBackFactor,
    OutputLeft,OutputRight,LeftOutput,RightOutput:TpvInt32;
begin
 Sample:=Buffer;
 WetFactor:=round(Wet*4096);
 DryFactor:=round(Dry*4096);
 FeedBackFactor:=round(FeedBack*4096);
 for SampleCounter:=1 to Samples do begin
  LeftBuffer[LeftCounter]:=Sample^[0] shl ExtraAccurateBits;
  RightBuffer[RightCounter]:=Sample^[1] shl ExtraAccurateBits;

  OutputLeft:=LeftBuffer[LeftDelayedCounter];
  OutputRight:=RightBuffer[RightDelayedCounter];

  LeftCounter:=(LeftCounter+1) and SampleBufferMask;
  RightCounter:=(RightCounter+1) and SampleBufferMask;
  LeftDelayedCounter:=(LeftDelayedCounter+1) and SampleBufferMask;
  RightDelayedCounter:=(RightDelayedCounter+1) and SampleBufferMask;

  for AllPassFilterCounter:=0 to AllPassFilters-1 do begin
{$ifdef UseDIV}
   LeftOutput:=((OutputLeft*(-FeedBackFactor)) div 4096)+AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,2],0];
   RightOutput:=((OutputRight*(-FeedBackFactor)) div 4096)+AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,3],1];
   AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,0],0]:=OutputLeft+((LeftOutput*FeedBackFactor) div 4096);
   AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,1],1]:=OutputRight+((RightOutput*FeedBackFactor) div 4096);
{$else}
   LeftOutput:=SARLongint(OutputLeft*(-FeedBackFactor),12)+AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,2],0];
   RightOutput:=SARLongint(OutputRight*(-FeedBackFactor),12)+AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,3],1];
   AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,0],0]:=OutputLeft+SARLongint(LeftOutput*FeedBackFactor,12);
   AllPassBuffer[AllPassFilterCounter,Counter[AllPassFilterCounter,1],1]:=OutputRight+SARLongint(RightOutput*FeedBackFactor,12);
{$endif}
   OutputLeft:=LeftOutput;
   OutputRight:=RightOutput;
   Counter[AllPassFilterCounter,0]:=(Counter[AllPassFilterCounter,0]+1) and SampleBufferMask;
   Counter[AllPassFilterCounter,1]:=(Counter[AllPassFilterCounter,1]+1) and SampleBufferMask;
   Counter[AllPassFilterCounter,2]:=(Counter[AllPassFilterCounter,2]+1) and SampleBufferMask;
   Counter[AllPassFilterCounter,3]:=(Counter[AllPassFilterCounter,3]+1) and SampleBufferMask;
  end;

{$ifdef UseDIV}
  inc(LastLowPassLeft,(CutOff*(OutputLeft-LastLowPassLeft)) div 4096);
  inc(LastLowPassRight,(CutOff*(OutputRight-LastLowPassRight)) div 4096);

  Sample^[0]:=((Sample^[0]*DryFactor)+((LastLowPassLeft div ExtraAccurateLength)*WetFactor)) div 4096;
  Sample^[1]:=((Sample^[1]*DryFactor)+((LastLowPassRight div ExtraAccurateLength)*WetFactor)) div 4096;
{$else}
  inc(LastLowPassLeft,SARLongint(CutOff*(OutputLeft-LastLowPassLeft),12));
  inc(LastLowPassRight,SARLongint(CutOff*(OutputRight-LastLowPassRight),12));

  Sample^[0]:=SARLongint((Sample^[0]*DryFactor)+(SARLongint(LastLowPassLeft,ExtraAccurateBits)*WetFactor),12);
  Sample^[1]:=SARLongint((Sample^[1]*DryFactor)+(SARLongint(LastLowPassRight,ExtraAccurateBits)*WetFactor),12);
{$endif}

  inc(Sample);
 end;
end;

constructor TpvAudioThread.Create(AAudioEngine:TpvAudio);
begin
 AudioEngine:=AAudioEngine;
 GetMem(Buffer,AudioEngine.OutputBufferSize);
 FillChar(Buffer^,AudioEngine.OutputBufferSize,AnsiChar(#0));
 FreeOnTerminate:=false;
 Event:=TEvent.Create(nil,false,false,'');
 ReadEvent:=TEvent.Create(nil,false,false,'');
//Priority:=tpHighest;
 inherited Create(false);
end;

destructor TpvAudioThread.Destroy;
begin
 Terminate;
 ReadEvent.SetEvent;
 Event.SetEvent;
 WaitFor;
 FreeAndNil(ReadEvent);
 FreeAndNil(Event);
 FreeMem(Buffer);
 inherited Destroy;
end;

procedure TpvAudioThread.Start;
begin
 Event.SetEvent;
end;

procedure TpvAudioThread.Execute;
begin
{$if declared(NameThreadForDebugging)}
 NameThreadForDebugging('TpvAudioThread');
{$ifend}
 try
(*{$ifdef windows}
  SetThreadAffinityMask(GetCurrentThread,1 shl GDFW.CPUCores[1]);
{$ifdef win32}
{$ifndef fpc}
  SetThreadIdealProcessor(GetCurrentThread,GDFW.CPUCores[1]);
{$endif}
{$endif}
{$endif}//*)
  SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
  while not Terminated do begin
   if AudioEngine.IsReady and AudioEngine.IsActive then begin
    AudioEngine.CriticalSection.Enter;
    try
     AudioEngine.FillBuffer;
    finally
     AudioEngine.CriticalSection.Leave;
    end;
    if AudioEngine.IsMuted then begin
     FillChar(pansichar(AudioEngine.OutputBuffer)[0],AudioEngine.OutputBufferSize,#0);
    end;
    repeat
     if AudioEngine.RingBuffer.AvailableForWrite>=AudioEngine.OutputBufferSize then begin
      AudioEngine.RingBuffer.Write(AudioEngine.OutputBuffer,AudioEngine.OutputBufferSize);
      break;
     end else begin
      ReadEvent.WaitFor(1);
     end;
    until Terminated or not (AudioEngine.IsReady and AudioEngine.IsActive);
   end else begin
    InterlockedExchange(Sleeping,-1);
    Event.WaitFor($ffffffff);
    InterlockedExchange(Sleeping,0);
   end;
  end;
 except
  on e:Exception do begin
//   DumpExceptionCallStack(e);
   raise;
  end;
 end;
end;

{ TpvAudioCommandQueue }

constructor TpvAudioCommandQueue.Create(aAudioEngine:TpvAudio);
begin
 inherited Create;
 fAudioEngine:=aAudioEngine;
 fGlobalLock:=TPasMPCriticalSection.Create;
 fLock:=TPasMPCriticalSection.Create;
 fQueue.Initialize;
 fFreeStack.Initialize;
end;

destructor TpvAudioCommandQueue.Destroy;
var QueueItem:TQueueItem;
begin

 while fFreeStack.Pop(QueueItem) do begin
  FreeAndNil(QueueItem);
 end;
 fFreeStack.Finalize;

 while fQueue.Dequeue(QueueItem) do begin
  FreeAndNil(QueueItem);
 end;
 fQueue.Finalize;

 FreeAndNil(fLock);

 FreeAndNil(fGlobalLock);

 inherited Destroy;

end;

procedure TpvAudioCommandQueue.Lock;
begin
 fGlobalLock.Acquire;
end;

procedure TpvAudioCommandQueue.Unlock;
begin
 fGlobalLock.Release;
end;

function TpvAudioCommandQueue.AcquireQueueItem:TQueueItem;
begin
 if not fFreeStack.Pop(result) then begin
  result:=TQueueItem.Create;
 end;
end;

function TpvAudioCommandQueue.SampleVoicePlay(const aSample:TpvAudioSoundSample;const aVolume,aPanning,aRate:TpvFloat;const aVoiceIndexPointer:TpvPointer=nil):TpvID;
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  result:=fAudioEngine.GlobalVoiceManager.AllocateGlobalVoice(aSample,-1);
  if result<>0 then begin
   fLock.Acquire;
   try
    QueueItem:=AcquireQueueItem;
    try
     QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoicePlay;
     QueueItem.fGlobalVoiceID:=result;
     QueueItem.fSample:=aSample;
     QueueItem.fVoiceNumber:=result;
     QueueItem.fVolume:=aVolume;
     QueueItem.fPanning:=aPanning;
     QueueItem.fRate:=aRate;
     QueueItem.fVoiceIndexPointer:=aVoiceIndexPointer;
    finally
     fQueue.Enqueue(QueueItem);
    end;
   finally
    fLock.Release;
   end;
  end;
 end else begin
  result:=TpvID(0);
 end;
end;

function TpvAudioCommandQueue.SampleVoicePlaySpatialization(const aSample:TpvAudioSoundSample;const aVolume,aPanning,aRate:TpvFloat;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false;const aVoiceIndexPointer:TpvPointer=nil):TpvID;
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  result:=fAudioEngine.GlobalVoiceManager.AllocateGlobalVoice(aSample,-1);
  if result<>0 then begin
   fLock.Acquire;
   try
    QueueItem:=AcquireQueueItem;
    try
     QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoicePlaySpatialization;
     QueueItem.fGlobalVoiceID:=result;
     QueueItem.fSample:=aSample;
     QueueItem.fVoiceNumber:=result;
     QueueItem.fVolume:=aVolume;
     QueueItem.fPanning:=aPanning;
     QueueItem.fRate:=aRate;
     QueueItem.fPosition:=aPosition;
     QueueItem.fVelocity:=aVelocity;
     QueueItem.fSpatialization:=aSpatialization;
     QueueItem.fLocal:=aLocal;
     QueueItem.fVoiceIndexPointer:=aVoiceIndexPointer;
    finally
     fQueue.Enqueue(QueueItem);
    end;
   finally
    fLock.Release;
   end;
  end;
 end else begin
  result:=TpvID(0);
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceRandomReseek(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceRandomReseek;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceRandomReseek(const aGlobalVoiceID:TpvID);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceRandomReseek;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceResetLoop(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceResetLoop;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceResetLoop(const aGlobalVoiceID:TpvID);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceResetLoop;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceStop(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceStop;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceStop(const aGlobalVoiceID:TpvID);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceStop;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceKeyOff(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceKeyOff;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceKeyOff(const aGlobalVoiceID:TpvID);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceKeyOff;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetVolume(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aVolume:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetVolume;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
    QueueItem.fVolume:=aVolume;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetVolume(const aGlobalVoiceID:TpvID;const aVolume:TpvFloat);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetVolume;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
   QueueItem.fVolume:=aVolume;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetPanning(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aPanning:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetPanning;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
    QueueItem.fPanning:=aPanning;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetPanning(const aGlobalVoiceID:TpvID;const aPanning:TpvFloat);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetPanning;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
   QueueItem.fPanning:=aPanning;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetRate(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aRate:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetRate;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
    QueueItem.fRate:=aRate;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetRate(const aGlobalVoiceID:TpvID;const aRate:TpvFloat);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetRate;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
   QueueItem.fRate:=aRate;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetPosition(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetPosition;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
    QueueItem.fPosition:=aPosition;
    QueueItem.fSpatialization:=aSpatialization;
    QueueItem.fLocal:=aLocal;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetPosition(const aGlobalVoiceID:TpvID;const aSpatialization:LongBool;const aPosition,aVelocity:TpvVector3;const aLocal:LongBool=false);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetPosition;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
   QueueItem.fPosition:=aPosition;
   QueueItem.fSpatialization:=aSpatialization;
   QueueItem.fLocal:=aLocal;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetEffectMix(const aSample:TpvAudioSoundSample;const aVoiceNumber:TpvInt32;const aActive:LongBool);
var QueueItem:TQueueItem;
begin
 if assigned(aSample) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetEffectMix;
    QueueItem.fSample:=aSample;
    QueueItem.fVoiceNumber:=aVoiceNumber;
    QueueItem.fGlobalVoiceID:=fAudioEngine.GlobalVoiceManager.GetGlobalVoiceID(aSample,aVoiceNumber);
    QueueItem.fActive:=aActive;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.SampleVoiceSetEffectMix(const aGlobalVoiceID:TpvID;const aActive:LongBool);
var QueueItem:TQueueItem;
begin
 fLock.Acquire;
 try
  QueueItem:=AcquireQueueItem;
  try
   QueueItem.fCommandType:=TQueueItem.TCommandType.SampleVoiceSetEffectMix;
   QueueItem.fGlobalVoiceID:=aGlobalVoiceID;
   QueueItem.fActive:=aActive;
  finally
   fQueue.Enqueue(QueueItem);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvAudioCommandQueue.MusicPlay(const aMusic:TpvAudioSoundMusic;const aVolume,aPanning,aRate:TpvFloat;const aLoop:boolean);
var QueueItem:TQueueItem;
begin
 if assigned(aMusic) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.MusicPlay;
    QueueItem.fMusic:=aMusic;
    QueueItem.fVolume:=aVolume;
    QueueItem.fPanning:=aPanning;
    QueueItem.fRate:=aRate;
    QueueItem.fLoop:=aLoop;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.MusicStop(const aMusic:TpvAudioSoundMusic);
var QueueItem:TQueueItem;
begin
 if assigned(aMusic) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.MusicStop;
    QueueItem.fMusic:=aMusic;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.MusicSetVolume(const aMusic:TpvAudioSoundMusic;const aVolume:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aMusic) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.MusicSetVolume;
    QueueItem.fMusic:=aMusic;
    QueueItem.fVolume:=aVolume;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.MusicSetPanning(const aMusic:TpvAudioSoundMusic;const aPanning:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aMusic) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.MusicSetPanning;
    QueueItem.fMusic:=aMusic;
    QueueItem.fPanning:=aPanning;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.MusicSetRate(const aMusic:TpvAudioSoundMusic;const aRate:TpvFloat);
var QueueItem:TQueueItem;
begin
 if assigned(aMusic) then begin
  fLock.Acquire;
  try
   QueueItem:=AcquireQueueItem;
   try
    QueueItem.fCommandType:=TQueueItem.TCommandType.MusicSetRate;
    QueueItem.fMusic:=aMusic;
    QueueItem.fRate:=aRate;
   finally
    fQueue.Enqueue(QueueItem);
   end;
  finally
   fLock.Release;
  end;
 end;
end;

procedure TpvAudioCommandQueue.Process;
var QueueItem:TQueueItem;
    GlobalVoiceID:TpvID;
    GlobalVoice:TpvAudioSoundSampleGlobalVoice;
    OK:Boolean;
begin
 fGlobalLock.Acquire;
 try
  repeat
   fLock.Acquire;
   try
    OK:=fQueue.Dequeue(QueueItem);
   finally
    fLock.Release;
   end;
   if OK then begin
    try
     case QueueItem.fCommandType of
      TQueueItem.TCommandType.SampleVoicePlay:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.Play(QueueItem.fVolume,QueueItem.fPanning,QueueItem.fRate,QueueItem.fVoiceIndexPointer,GlobalVoiceID);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.Play(QueueItem.fVolume,QueueItem.fPanning,QueueItem.fRate,QueueItem.fVoiceIndexPointer);
       end;
      end;
      TQueueItem.TCommandType.SampleVoicePlaySpatialization:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.PlaySpatialization(QueueItem.fVolume,QueueItem.fPanning,QueueItem.fRate,QueueItem.fSpatialization,QueueItem.fPosition,QueueItem.fVelocity,QueueItem.fLocal,QueueItem.fVoiceIndexPointer,GlobalVoiceID);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.PlaySpatialization(QueueItem.fVolume,QueueItem.fPanning,QueueItem.fRate,QueueItem.fSpatialization,QueueItem.fPosition,QueueItem.fVelocity,QueueItem.fLocal,QueueItem.fVoiceIndexPointer);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceRandomReseek:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.RandomReseek(GlobalVoice.VoiceNumber);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.RandomReseek(QueueItem.fVoiceNumber);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceResetLoop:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.ResetLoop(GlobalVoice.VoiceNumber);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.ResetLoop(QueueItem.fVoiceNumber);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceStop:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.Stop(GlobalVoice.VoiceNumber);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.Stop(QueueItem.fVoiceNumber);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceKeyOff:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.KeyOff(GlobalVoice.VoiceNumber);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.KeyOff(QueueItem.fVoiceNumber);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceSetVolume:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.SetVolume(GlobalVoice.VoiceNumber,QueueItem.fVolume);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.SetVolume(QueueItem.fVoiceNumber,QueueItem.fVolume);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceSetPanning:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.SetPanning(GlobalVoice.VoiceNumber,QueueItem.fPanning);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.SetPanning(QueueItem.fVoiceNumber,QueueItem.fPanning);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceSetRate:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.SetRate(GlobalVoice.VoiceNumber,QueueItem.fRate);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.SetRate(QueueItem.fVoiceNumber,QueueItem.fRate);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceSetPosition:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.SetPosition(GlobalVoice.VoiceNumber,QueueItem.fSpatialization,QueueItem.fPosition,QueueItem.fVelocity,QueueItem.fLocal);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.SetPosition(QueueItem.fVoiceNumber,QueueItem.fSpatialization,QueueItem.fPosition,QueueItem.fVelocity,QueueItem.fLocal);
       end;
      end;
      TQueueItem.TCommandType.SampleVoiceSetEffectMix:begin
       GlobalVoiceID:=QueueItem.fGlobalVoiceID;
       if GlobalVoiceID<>0 then begin
        GlobalVoice:=fAudioEngine.GlobalVoiceManager.GetGlobalVoice(GlobalVoiceID);
        if assigned(GlobalVoice.SoundSample) then begin
         GlobalVoice.SoundSample.SetEffectMix(GlobalVoice.VoiceNumber,QueueItem.fActive);
        end;
       end else if assigned(QueueItem.fSample) then begin
        QueueItem.fSample.SetEffectMix(QueueItem.fVoiceNumber,QueueItem.fActive);
       end;
      end;
      TQueueItem.TCommandType.MusicPlay:begin
       if assigned(QueueItem.fMusic) then begin
        QueueItem.fMusic.Play(QueueItem.fVolume,QueueItem.fPanning,QueueItem.fRate,QueueItem.fLoop);
       end;
      end;
      TQueueItem.TCommandType.MusicStop:begin
       if assigned(QueueItem.fMusic) then begin
        QueueItem.fMusic.Stop;
       end;
      end;
      TQueueItem.TCommandType.MusicSetVolume:begin
       if assigned(QueueItem.fMusic) then begin
        QueueItem.fMusic.SetVolume(QueueItem.fVolume);
       end;
      end;
      TQueueItem.TCommandType.MusicSetPanning:begin
       if assigned(QueueItem.fMusic) then begin
        QueueItem.fMusic.SetPanning(QueueItem.fPanning);
       end;
      end;
      TQueueItem.TCommandType.MusicSetRate:begin
       if assigned(QueueItem.fMusic) then begin
        QueueItem.fMusic.SetRate(QueueItem.fRate);
       end;
      end;
     end;
    finally
     fLock.Acquire;
     try
      fFreeStack.Push(QueueItem);
     finally
      fLock.Release;
     end;
    end;
   end else begin
    break;
   end;
  until false;
 finally
  fGlobalLock.Release;
 end;
end;

{ TpvAudio }

constructor TpvAudio.Create(ASampleRate,AChannels,ABits,ABufferSamples:TpvInt32);
const SqrtThree=1.7320508075688772;
      InvSqrtThree=0.5773502691896258;
      Minus3dB=0.7071067811865475244008443621048490392848359376884740365883398689;
      OneOverMinus3dB=1.0/Minus3dB;
//    OneOverSqrMinus3dB=1.0/sqr(Minus3dB);
var i,TableLengthSize:TpvInt32;
    X,TableLength:{$ifdef cpuarm}TpvFloat{$else}TpvDouble{$endif};
begin
 inherited Create;
 AudioInstance:=self;
 CriticalSection:=TPasMPCriticalSection.Create;
 GlobalVoiceManager:=TpvAudioSoundSampleGlobalVoiceManager.Create(self);
 CommandQueue:=TpvAudioCommandQueue.Create(self);
 SampleRate:=ASampleRate;
 Channels:=AChannels;
 Bits:=ABits;
 BufferSamples:=ABufferSamples;
 BufferChannelSamples:=BufferSamples*2;
 BufferOutputChannelSamples:=BufferSamples*Channels;
 MixingBufferSize:=(BufferSamples*2*32) shr 3;
 OutputBufferSize:=(BufferSamples*Channels*Bits) shr 3;
 GetMem(MixingBuffer,MixingBufferSize);
 GetMem(MusicMixingBuffer,MixingBufferSize);
 GetMem(EffectMixingBuffer,MixingBufferSize);
 GetMem(OutputBuffer,OutputBufferSize);
 GetMem(fTemporaryBuffer,BufferSamples*Channels*SizeOf(TpvAudioFloat));
 fOnFillBuffer:=nil;
 SpatializationWaterLowPassCW:=Min(Max(2*sin(pi*(WATER_LOWPASS_FREQUENCY/SampleRate)),0.0),1.0);
 SpatializationWaterWaterBoostLowPassCW:=round(Min(Max(2*sin(pi*(WATER_BOOST_START_FREQUENCY/SampleRate)),0.0),1.0)*4096);
 SpatializationWaterWaterBoostHighPassCW:=round(Min(Max(2*sin(pi*(WATER_BOOST_END_FREQUENCY/SampleRate)),0.0),1.0)*4096);
 SpatializationWaterWaterBoost:=round(WATER_BOOST_FACTOR*4096);
 SpatializationLowPassCW:=Min(Max(cos(2*pi*(HF_FREQUENCY/SampleRate)),0.0),1.0);
 SpatializationDelayAir:=(SampleRate*EAR_DELAY_AIR)*0.001;
 SpatializationDelayUnderwater:=(SampleRate*EAR_DELAY_UNDERWATER)*0.001;
 SpatializationDelayPowerOfTwo:=TPasMPMath.RoundUpToPowerOfTwo(Max(round(Max(SpatializationDelayAir,SpatializationDelayUnderwater)+0.5),HRIR_MAX_DELAY));
 SpatializationDelayMask:=SpatializationDelayPowerOfTwo-1;
 Samples:=TpvAudioSoundSamples.Create(self);
 Musics:=TpvAudioSoundMusics.Create(self);
 HRTFPreset:=@DefaultHRTFPreset;
 HRTF:=ASampleRate=HRTFPreset^.SampleRate;
 iF HRTF then begin
  SpatializationMode:=SPATIALIZATION_HRTF;
 end else begin
  SpatializationMode:=SPATIALIZATION_PSEUDO;
 end;
 MasterVolume:=4096;
 SampleVolume:=32768;
 MusicVolume:=4096;
 AGCActive:=true;
 AGC:=256;
 AGCCounter:=0;
 AGCInterval:=(SampleRate*25) div 1000;
 if AGCInterval<1 then begin
  AGCInterval:=1;
 end;
 RampingSamples:=Max(10,(SampleRate*10) div 1000);
 RampingStepSamples:=Min(Max(1,SampleRate div 1000),RampingSamples);
 TableLengthSize:=1 shl ResamplerCubicSplineFracBits;
 if TableLengthSize>0 then begin
  TableLength:=1/TableLengthSize;
  for i:=0 to TableLengthSize-1 do begin
   x:=i*TableLength;
   CubicSplineTable[i,0]:=round(((-0.5*x*x*x)+(1.0*x*x)-(0.5*x))*ResamplerCubicSplineValueLength);
   CubicSplineTable[i,1]:=round(((1.5*x*x*x)-(2.5*x*x)+1.0)*ResamplerCubicSplineValueLength);
   CubicSplineTable[i,2]:=round(((-1.5*x*x*x)+(2.0*x*x)+(0.5*x))*ResamplerCubicSplineValueLength);
   CubicSplineTable[i,3]:=round(((0.5*x*x*x)-(0.5*x*x))*ResamplerCubicSplineValueLength);
  end;
 end;
 ListenerViewMatrix:=TpvMatrix4x4.Identity;
 ListenerVelocity:=TpvVector3.Null;
 ListenerUnderwater:=false;
 ListenerGeneration:=0;
 LowPassLeft:=0;
 LowPassRight:=0;
 LowPassLast:=LowPassLength shl LowPassShift;
 LowPassCurrent:=LowPassLength shl LowPassShift;
 LowPassIncrement:=0;
 LowPassRampingLength:=0;
 WaterBoostMiddlePassLeft:=0;
 WaterBoostMiddlePassRight:=0;
 FillChar(WaterBoostLowPassLeft,SizeOf(WaterBoostLowPassLeft),AnsiChar(#0));
 FillChar(WaterBoostLowPassRight,SizeOf(WaterBoostLowPassRight),AnsiChar(#0));
 FillChar(WaterBoostHighPassLeft,SizeOf(WaterBoostHighPassLeft),AnsiChar(#0));
 FillChar(WaterBoostHighPassRight,SizeOf(WaterBoostHighPassRight),AnsiChar(#0));
 FillChar(WaterBoostHistoryLeft,SizeOf(WaterBoostHistoryLeft),AnsiChar(#0));
 FillChar(WaterBoostHistoryRight,SizeOf(WaterBoostHistoryRight),AnsiChar(#0));
 UpdateHook:=nil;
 VoiceFirst:=nil;
 VoiceLast:=nil;
 PitchShifter:=TpvAudioPitchShifter.Create(self);
 Reverb:=TpvAudioReverb.Create(self);
 for i:=0 to high(PanningLUT) do begin
  PanningLUT[i]:=round(sin(HalfPI*(i/high(PanningLUT)))*32768.0);
 end;
 PanningLUT[$10000]:=32768;
 ConeScale:=1.0;
 InnerAngle:=360.0;
 OuterAngle:=360.0;
 OuterGain:=0.0;
 OuterGainHF:=1.0;
 RingBuffer:=TPasMPSingleProducerSingleConsumerRingBuffer.Create(OutputBufferSize*2);
 Thread:=TpvAudioThread.Create(self);
 IsReady:=true;
 IsMuted:=false;
 IsActive:=true;
 if pvAudioDump then begin
  WAVStreamDumpMusic:=TpvAudioWAVStreamDump.Create(self,TFileStream.Create('music.wav',fmCreate),true);
  WAVStreamDumpSample:=TpvAudioWAVStreamDump.Create(self,TFileStream.Create('sample.wav',fmCreate),true);
  WAVStreamDumpFinalMix:=TpvAudioWAVStreamDump.Create(self,TFileStream.Create('finalmix.wav',fmCreate),true);
 end else begin
  WAVStreamDumpMusic:=nil;
  WAVStreamDumpSample:=nil;
  WAVStreamDumpFinalMix:=nil;
 end;
 PCG32.Init(TpvPtrUInt(self));
end;

destructor TpvAudio.Destroy;
begin
 FreeAndNil(Thread);
 FreeAndNil(RingBuffer);
 FreeAndNil(Reverb);
 FreeAndNil(PitchShifter);
 FreeAndNil(Samples);
 FreeAndNil(Musics);
 FreeMem(MixingBuffer);
 FreeMem(MusicMixingBuffer);
 FreeMem(EffectMixingBuffer);
 FreeMem(OutputBuffer);
 FreeAndNil(GlobalVoiceManager);
 FreeAndNil(CommandQueue);
 FreeMem(fTemporaryBuffer);
 FreeAndNil(WAVStreamDumpFinalMix);
 FreeAndNil(WAVStreamDumpSample);
 FreeAndNil(WAVStreamDumpMusic);
 FreeAndNil(CriticalSection);
 AudioInstance:=nil;
 inherited Destroy;
end;

procedure TpvAudio.CalcEvIndices(ev:TpvFloat;evidx:PpvAudioInt32s;var evmu:TpvFloat);
const pi2=pi*2;
begin
 ev:=(pi2+ev)*((HRTFPreset^.evCount-1)/pi);
 evidx^[0]:=IntMod(trunc(ev),HRTFPreset^.evCount);
 evidx^[1]:=Min(evidx^[0]+1,HRTFPreset^.evCount-1);
 evmu:=ev-trunc(ev);
end;

procedure TpvAudio.CalcAzIndices(evidx:TpvInt32;az:TpvFloat;azidx:PpvAudioInt32s;var azmu:TpvFloat);
const pi2=pi*2;
begin
 az:=(pi2+az)*(PpvAudioInt32s(HRTFPreset^.azCount)^[evidx]/pi2);
 azidx^[0]:=IntMod(trunc(az),PpvAudioInt32s(HRTFPreset^.azCount)^[evidx]);
 azidx^[1]:=IntMod(azidx^[0]+1,PpvAudioInt32s(HRTFPreset^.azCount)^[evidx]);
 azmu:=az-floor(az);
end;

procedure TpvAudio.GetLerpedHRTFCoefs(Elevation,Azimuth:TpvFloat;var LeftCoefs,RightCoefs:TpvAudioHRTFCoefs;var LeftDelay,RightDelay:TpvInt32);
var evidx,azidx:array[0..1] of TpvInt32;
    mu:array[0..2] of TpvFloat;
    b:array[0..3] of TpvFloat;
    lidx,ridx:array[0..3] of TpvInt32;
    Factor:TpvFloat;
    i:TpvInt32;
begin
 CalcEvIndices(Elevation,@evidx[0],mu[2]);
 CalcAzIndices(evidx[0],Azimuth,@azidx[0],mu[0]);
 lidx[0]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[0]]+azidx[0];
 lidx[1]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[0]]+azidx[1];
 ridx[0]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[0]]+IntMod(PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[0]]-azidx[0],PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[0]]);
 ridx[1]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[0]]+IntMod(PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[0]]-azidx[1],PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[0]]);
 CalcAzIndices(evidx[1],Azimuth,@azidx[0],mu[1]);
 lidx[2]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[1]]+azidx[0];
 lidx[3]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[1]]+azidx[1];
 ridx[2]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[1]]+IntMod(PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[1]]-azidx[0],PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[1]]);
 ridx[3]:=PpvAudioInt32s(HRTFPreset^.evOffset)^[evidx[1]]+IntMod(PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[1]]-azidx[1],PpvAudioInt32s(HRTFPreset^.azCount)^[evidx[1]]);
 b[0]:=(1.0-mu[0])*(1.0-mu[2]);
 b[1]:=mu[0]*(1.0-mu[2]);
 b[2]:=(1.0-mu[1])*mu[2];
 b[3]:=mu[1]*mu[2];
 if ListenerUnderwater then begin
  Factor:=SpeedOfSoundAirToUnderwater;
 end else begin
  Factor:=1;
 end;
 LeftDelay:=trunc((((PpvAudioInt32s(HRTFPreset^.Delays)^[lidx[0]]*b[0])+
                    (PpvAudioInt32s(HRTFPreset^.Delays)^[lidx[1]]*b[1])+
                    (PpvAudioInt32s(HRTFPreset^.Delays)^[lidx[2]]*b[2])+
                    (PpvAudioInt32s(HRTFPreset^.Delays)^[lidx[3]]*b[3]))*Factor)*SpatializationDelayLength);
 RightDelay:=trunc((((PpvAudioInt32s(HRTFPreset^.Delays)^[ridx[0]]*b[0])+
                     (PpvAudioInt32s(HRTFPreset^.Delays)^[ridx[1]]*b[1])+
                     (PpvAudioInt32s(HRTFPreset^.Delays)^[ridx[2]]*b[2])+
                     (PpvAudioInt32s(HRTFPreset^.Delays)^[ridx[3]]*b[3]))*Factor)*SpatializationDelayLength);
 lidx[0]:=lidx[0]*HRTFPreset^.irSize;
 lidx[1]:=lidx[1]*HRTFPreset^.irSize;
 lidx[2]:=lidx[2]*HRTFPreset^.irSize;
 lidx[3]:=lidx[3]*HRTFPreset^.irSize;
 ridx[0]:=ridx[0]*HRTFPreset^.irSize;
 ridx[1]:=ridx[1]*HRTFPreset^.irSize;
 ridx[2]:=ridx[2]*HRTFPreset^.irSize;
 ridx[3]:=ridx[3]*HRTFPreset^.irSize;
 for i:=0 to HRTFPreset^.irSize-1 do begin
  LeftCoefs[i]:=trunc(((PpvAudioInt32s(HRTFPreset^.Coefs)^[lidx[0]+i]*b[0])+
                       (PpvAudioInt32s(HRTFPreset^.Coefs)^[lidx[1]+i]*b[1])+
                       (PpvAudioInt32s(HRTFPreset^.Coefs)^[lidx[2]+i]*b[2])+
                       (PpvAudioInt32s(HRTFPreset^.Coefs)^[lidx[3]+i]*b[3]))*32768.0);
  RightCoefs[i]:=trunc(((PpvAudioInt32s(HRTFPreset^.Coefs)^[ridx[0]+i]*b[0])+
                        (PpvAudioInt32s(HRTFPreset^.Coefs)^[ridx[1]+i]*b[1])+
                        (PpvAudioInt32s(HRTFPreset^.Coefs)^[ridx[2]+i]*b[2])+
                        (PpvAudioInt32s(HRTFPreset^.Coefs)^[ridx[3]+i]*b[3]))*32768.0);
 end;
end;

function TpvAudio.GetMixerMasterVolume:TpvFloat;
const OneOver4096=1.0/4096.0;
begin
 CriticalSection.Enter;
 try
  result:=Min(Max(MasterVolume*OneOver4096,0.0),1.0);
 finally
  CriticalSection.Leave;
 end;
end;

function TpvAudio.GetMixerMusicVolume:TpvFloat;
const OneOver4096=1.0/4096.0;
begin
 CriticalSection.Enter;
 try
  result:=Min(Max(MusicVolume*OneOver4096,0.0),1.0);
 finally
  CriticalSection.Leave;
 end;
end;

function TpvAudio.GetMixerSampleVolume:TpvFloat;
const OneOver32768=1.0/32768.0;
begin
 CriticalSection.Enter;
 try
  result:=Min(Max(SampleVolume*OneOver32768,0.0),1.0);
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.SetMixerMasterVolume(NewVolume:TpvFloat);
begin
 CriticalSection.Enter;
 try
  MasterVolume:=round(NewVolume*4096);
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.SetMixerMusicVolume(NewVolume:TpvFloat);
begin
 CriticalSection.Enter;
 try
  MusicVolume:=round(NewVolume*4096);
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.SetMixerSampleVolume(NewVolume:TpvFloat);
begin
 CriticalSection.Enter;
 try
  SampleVolume:=round(NewVolume*32768);
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.SetMixerAGC(Enabled:boolean);
begin
 CriticalSection.Enter;
 try
  AGCActive:=Enabled;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.Setup;
var i:TpvInt32;
begin
 for i:=0 to Samples.Count-1 do begin
  Samples[i].CorrectVoices;
 end;
end;

procedure TpvAudio.ClipBuffer(p:TpvPointer;Range:TpvInt32);
type PpvAudioInt32=^TpvInt32;
var pl:PpvAudioInt32;
    i:TpvInt32;
begin
 pl:=p;
{$ifdef UnrolledLoops}
 for i:=1 to BufferChannelSamples shr 2 do begin
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
 end;
 for i:=1 to BufferChannelSamples and 3 do begin
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
 end;
{$else}
 for i:=1 to BufferChannelSamples do begin
  pl^:=SARLongint(TpvInt32((abs(pl^+Range)-1)-abs(pl^-(Range-1))),1);
  inc(pl);
 end;
{$endif}
end;

function CompareVoiceByVolumeSquaredMagnitudes(const a,b:Pointer):TpvInt32;
begin
 result:=Sign(TpvAudioSoundSampleVoice(b).fVolumeSquaredMagnitude-TpvAudioSoundSampleVoice(a).fVolumeSquaredMagnitude);
 if result=0 then begin
  result:=Sign(TpvInt32(Ord(TpvAudioSoundSampleVoice(a).fReadyToPutIntoSleep) and 1)-TpvInt32(Ord(TpvAudioSoundSampleVoice(b).fReadyToPutIntoSleep) and 1));
  if result=0 then begin
   result:=Sign(TpvPtrInt(a)-TpvPtrInt(b));
  end;
 end;
end;

procedure TpvAudio.FillBuffer;
const OneDiv32768=1.0/32768.0;
type pbyte=^TpvUInt8;
     psmallint=^smallint;
     PpvAudioInt32=^TpvInt32;
var i,jl,jr,SampleValue,HighPass,CountSamples,ToDo,LowPassCoef,Coef,SampleIndex,VoiceIndex:TpvInt32;
    p:TpvPointer;
    pl,pll,plr:PpvAudioInt32;
    ps:PpvInt16;
    pb:PpvUInt8;
    pf:PpvAudioFloat;
    Voice,NextVoice:TpvAudioSoundSampleVoice;
    StereoSampleValue:PpvAudioSoundSampleStereoValue;
    Sample:TpvAudioSoundSample;
    MixToEffect:Boolean;
    Factor:TpvFloat;
begin
 CriticalSection.Enter;
 try

  if assigned(UpdateHook) then begin
   UpdateHook;
  end;

  CommandQueue.Process;

  // Clearing
  FillChar(MixingBuffer^,MixingBufferSize,AnsiChar(#0));
  FillChar(MusicMixingBuffer^,MixingBufferSize,AnsiChar(#0));
  FillChar(EffectMixingBuffer^,MixingBufferSize,AnsiChar(#0));

  if assigned(fOnFillBuffer) then begin
   fOnFillBuffer(fTemporaryBuffer,BufferSamples);
   pf:=@fTemporaryBuffer[0];
   pl:=pointer(MixingBuffer);
   for i:=1 to BufferSamples*2 do begin
    SampleValue:=round(pf^*32768.0);
    if SampleValue<-524288 then begin
     SampleValue:=-524288;
    end else if SampleValue>524287 then begin
     SampleValue:=524287;
    end;
    inc(pl^,SampleValue);
    inc(pl);
    inc(pf);
   end;
  end;

  // Mixing all sample voices
  for SampleIndex:=0 to Samples.Count-1 do begin

   Sample:=Samples.Items[SampleIndex];

   if Sample.CountActiveVoices>0 then begin

    // Prepare all voived
    for VoiceIndex:=0 to Sample.CountActiveVoices-1 do begin
     Voice:=Sample.ActiveVoices[VoiceIndex];
     Voice.Prepare;
    end;

    if (Sample.CountActiveVoices>1) and (Sample.CountActiveVoices>Sample.SampleRealVoices) and (Sample.SampleRealVoices<Sample.SampleVirtualVoices) then begin

     // Sort voices by volume magnitudes
     IndirectIntroSort(@Sample.ActiveVoices[0],0,Sample.CountActiveVoices-1,CompareVoiceByVolumeSquaredMagnitudes);

     // Reassigned active voice indices, since they could be in different order after volume sorting
     for VoiceIndex:=0 to Sample.CountActiveVoices-1 do begin
      Sample.ActiveVoices[VoiceIndex].fActiveVoiceIndex:=VoiceIndex;
     end;

    end;

    if Sample.CompressorActive then begin

     // Clear mixing buffer
     FillChar(Sample.MixingBuffer^,MixingBufferSize,AnsiChar(#0));

     // Mix all voices to sample mixing buffer
     MixToEffect:=Sample.MixToEffect;
     for VoiceIndex:=0 to Sample.CountActiveVoices-1 do begin
      Voice:=Sample.ActiveVoices[VoiceIndex];
      if (VoiceIndex>=Sample.SampleRealVoices) and Voice.fReadyToPutIntoSleep then begin
       break;
      end else begin
       Voice.MixTo(Sample.MixingBuffer,32768,VoiceIndex<Sample.SampleRealVoices);
       MixToEffect:=MixToEffect or Voice.fMixToEffect;
      end;
     end;

     // Limit sample mixing buffer
     StereoSampleValue:=TpvPointer(Sample.MixingBuffer);
     Sample.Compressor.Setup(Sample.CompressorSettings);
     for i:=1 to BufferSamples do begin
      Factor:=Sample.Compressor.Process(Max(abs(StereoSampleValue^[0]),abs(StereoSampleValue[1]))*OneDiv32768);
      StereoSampleValue[0]:=round(StereoSampleValue[0]*Factor);
      StereoSampleValue[1]:=round(StereoSampleValue[1]*Factor);
      inc(StereoSampleValue);
     end;

     // Mix to target buffer
     if MixToEffect then begin
      p:=EffectMixingBuffer;
     end else begin
      p:=MixingBuffer;
     end;
     pl:=TpvPointer(p);
     pll:=TpvPointer(Sample.MixingBuffer);
     for i:=1 to BufferSamples do begin
      SampleValue:=pll^;
      if SampleValue<-524288 then begin
       SampleValue:=-524288;
      end else if SampleValue>524287 then begin
       SampleValue:=524287;
      end;
      SampleValue:=SARLongint(SampleValue*((SampleVolume+4) shr 5),12);
      inc(pl^,SampleValue);
      inc(pl);
      inc(pll);
      SampleValue:=pll^;
      if SampleValue<-524288 then begin
       SampleValue:=-524288;
      end else if SampleValue>524287 then begin
       SampleValue:=524287;
      end;
      inc(pl^,SampleValue);
      inc(pl);
      inc(pll);
     end;

    end else begin

     for VoiceIndex:=0 to Sample.CountActiveVoices-1 do begin
      Voice:=Sample.ActiveVoices[VoiceIndex];
      if (VoiceIndex>=Sample.SampleRealVoices) and Voice.fReadyToPutIntoSleep then begin
       break;
      end else begin
       if Sample.MixToEffect or Voice.fMixToEffect then begin
        p:=EffectMixingBuffer;
       end else begin
        p:=MixingBuffer;
       end;
       Voice.MixTo(p,SampleVolume,VoiceIndex<Sample.SampleRealVoices);
      end;
     end;

    end;

   end;

  end;
{ Voice:=VoiceFirst;
  while assigned(Voice) do begin
   NextVoice:=Voice.fNext;
   if Voice.fMixToEffect then begin
    p:=EffectMixingBuffer;
   end else begin
    p:=MixingBuffer;
   end;
   Voice.Prepare;
   Voice.MixTo(p,SampleVolume);
   Voice:=NextVoice;
  end;}
  if assigned(WAVStreamDumpSample) then begin
   WAVStreamDumpSample.Dump(MixingBuffer,MixingBufferSize);
  end;

  // Mixing all music streams
  for i:=0 to Musics.Count-1 do begin
   Musics[i].MixTo(MusicMixingBuffer,MusicVolume);
  end;
  for i:=0 to BufferChannelSamples-1 do begin
   inc(MixingBuffer[i],MusicMixingBuffer[i]);
  end;
  if assigned(WAVStreamDumpMusic) then begin
   WAVStreamDumpMusic.Dump(MusicMixingBuffer,MixingBufferSize);
  end;

  if ListenerUnderwater then begin
   PitchShifter.Factor:=0.7937005; // 2^((-4)/12)
  end else begin
   PitchShifter.Factor:=1.0;
  end;
  PitchShifter.Process(EffectMixingBuffer,BufferSamples);

  if ListenerUnderwater then begin
   ClipBuffer(EffectMixingBuffer,524288);
   pl:=TpvPointer(EffectMixingBuffer);
   for i:=1 to BufferSamples do begin
{$ifdef UseDIV}
    SampleValue:=pl^;
    inc(WaterBoostLowPassLeft[0],((SampleValue-WaterBoostLowPassLeft[0])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassLeft[1],((WaterBoostLowPassLeft[0]-WaterBoostLowPassLeft[1])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassLeft[2],((WaterBoostLowPassLeft[1]-WaterBoostLowPassLeft[2])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassLeft[3],((WaterBoostLowPassLeft[2]-WaterBoostLowPassLeft[3])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostHighPassLeft[0],((SampleValue-WaterBoostHighPassLeft[0])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassLeft[1],((WaterBoostHighPassLeft[0]-WaterBoostHighPassLeft[1])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassLeft[2],((WaterBoostHighPassLeft[1]-WaterBoostHighPassLeft[2])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassLeft[3],((WaterBoostHighPassLeft[2]-WaterBoostHighPassLeft[3])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    HighPass:=WaterBoostHistoryLeft[3]-WaterBoostHighPassLeft[3];
    WaterBoostMiddlePassLeft:=WaterBoostHistoryLeft[3]-(WaterBoostLowPassLeft[3]+HighPass);
    WaterBoostHistoryLeft[3]:=WaterBoostHistoryLeft[2];
    WaterBoostHistoryLeft[2]:=WaterBoostHistoryLeft[1];
    WaterBoostHistoryLeft[1]:=SampleValue;
    pl^:=WaterBoostLowPassLeft[3]+((WaterBoostMiddlePassLeft*SpatializationWaterWaterBoost) div 4096)+HighPass;
    inc(pl);
    SampleValue:=pl^;
    inc(WaterBoostLowPassRight[0],((SampleValue-WaterBoostLowPassRight[0])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassRight[1],((WaterBoostLowPassRight[0]-WaterBoostLowPassRight[1])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassRight[2],((WaterBoostLowPassRight[1]-WaterBoostLowPassRight[2])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostLowPassRight[3],((WaterBoostLowPassRight[2]-WaterBoostLowPassRight[3])*SpatializationWaterWaterBoostLowPassCW) div 4096);
    inc(WaterBoostHighPassRight[0],((SampleValue-WaterBoostHighPassRight[0])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassRight[1],((WaterBoostHighPassRight[0]-WaterBoostHighPassRight[1])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassRight[2],((WaterBoostHighPassRight[1]-WaterBoostHighPassRight[2])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    inc(WaterBoostHighPassRight[3],((WaterBoostHighPassRight[2]-WaterBoostHighPassRight[3])*SpatializationWaterWaterBoostHighPassCW) div 4096);
    HighPass:=WaterBoostHistoryRight[3]-WaterBoostHighPassRight[3];
    WaterBoostMiddlePassRight:=WaterBoostHistoryRight[3]-(WaterBoostLowPassRight[3]+HighPass);
    WaterBoostHistoryRight[3]:=WaterBoostHistoryRight[2];
    WaterBoostHistoryRight[2]:=WaterBoostHistoryRight[1];
    WaterBoostHistoryRight[1]:=SampleValue;
    pl^:=WaterBoostLowPassRight[3]+((WaterBoostMiddlePassRight*SpatializationWaterWaterBoost) div 4096)+HighPass;
    inc(pl);
{$else}
    SampleValue:=pl^;
    inc(WaterBoostLowPassLeft[0],SARLongint((SampleValue-WaterBoostLowPassLeft[0])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassLeft[1],SARLongint((WaterBoostLowPassLeft[0]-WaterBoostLowPassLeft[1])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassLeft[2],SARLongint((WaterBoostLowPassLeft[1]-WaterBoostLowPassLeft[2])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassLeft[3],SARLongint((WaterBoostLowPassLeft[2]-WaterBoostLowPassLeft[3])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostHighPassLeft[0],SARLongint((SampleValue-WaterBoostHighPassLeft[0])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassLeft[1],SARLongint((WaterBoostHighPassLeft[0]-WaterBoostHighPassLeft[1])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassLeft[2],SARLongint((WaterBoostHighPassLeft[1]-WaterBoostHighPassLeft[2])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassLeft[3],SARLongint((WaterBoostHighPassLeft[2]-WaterBoostHighPassLeft[3])*SpatializationWaterWaterBoostHighPassCW,12));
    HighPass:=WaterBoostHistoryLeft[3]-WaterBoostHighPassLeft[3];
    WaterBoostMiddlePassLeft:=WaterBoostHistoryLeft[3]-(WaterBoostLowPassLeft[3]+HighPass);
    WaterBoostHistoryLeft[3]:=WaterBoostHistoryLeft[2];
    WaterBoostHistoryLeft[2]:=WaterBoostHistoryLeft[1];
    WaterBoostHistoryLeft[1]:=SampleValue;
    pl^:=WaterBoostLowPassLeft[3]+SARLongint(WaterBoostMiddlePassLeft*SpatializationWaterWaterBoost,12)+HighPass;
    inc(pl);
    SampleValue:=pl^;
    inc(WaterBoostLowPassRight[0],SARLongint((SampleValue-WaterBoostLowPassRight[0])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassRight[1],SARLongint((WaterBoostLowPassRight[0]-WaterBoostLowPassRight[1])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassRight[2],SARLongint((WaterBoostLowPassRight[1]-WaterBoostLowPassRight[2])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostLowPassRight[3],SARLongint((WaterBoostLowPassRight[2]-WaterBoostLowPassRight[3])*SpatializationWaterWaterBoostLowPassCW,12));
    inc(WaterBoostHighPassRight[0],SARLongint((SampleValue-WaterBoostHighPassRight[0])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassRight[1],SARLongint((WaterBoostHighPassRight[0]-WaterBoostHighPassRight[1])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassRight[2],SARLongint((WaterBoostHighPassRight[1]-WaterBoostHighPassRight[2])*SpatializationWaterWaterBoostHighPassCW,12));
    inc(WaterBoostHighPassRight[3],SARLongint((WaterBoostHighPassRight[2]-WaterBoostHighPassRight[3])*SpatializationWaterWaterBoostHighPassCW,12));
    HighPass:=WaterBoostHistoryRight[3]-WaterBoostHighPassRight[3];
    WaterBoostMiddlePassRight:=WaterBoostHistoryRight[3]-(WaterBoostLowPassRight[3]+HighPass);
    WaterBoostHistoryRight[3]:=WaterBoostHistoryRight[2];
    WaterBoostHistoryRight[2]:=WaterBoostHistoryRight[1];
    WaterBoostHistoryRight[1]:=SampleValue;
    pl^:=WaterBoostLowPassRight[3]+SARLongint(WaterBoostMiddlePassRight*SpatializationWaterWaterBoost,12)+HighPass;
    inc(pl);
{$endif}
   end;
   ClipBuffer(EffectMixingBuffer,524288);
  end else begin
   FillChar(WaterBoostLowPassLeft,SizeOf(WaterBoostLowPassLeft),AnsiChar(#0));
   FillChar(WaterBoostLowPassRight,SizeOf(WaterBoostLowPassRight),AnsiChar(#0));
   FillChar(WaterBoostHighPassLeft,SizeOf(WaterBoostHighPassLeft),AnsiChar(#0));
   FillChar(WaterBoostHighPassRight,SizeOf(WaterBoostHighPassRight),AnsiChar(#0));
   FillChar(WaterBoostHistoryLeft,SizeOf(WaterBoostHistoryLeft),AnsiChar(#0));
   FillChar(WaterBoostHistoryRight,SizeOf(WaterBoostHistoryRight),AnsiChar(#0));
  end;

  if ListenerUnderwater then begin
   LowPassCoef:=round(SpatializationWaterLowPassCW*LowPassLength) shl LowPassShift;
  end else begin
   LowPassCoef:=LowPassLength shl LowPassShift;
  end;
  if LowPassLast<>LowPassCoef then begin
   LowPassLast:=LowPassCoef;
   if ListenerUnderwater then begin
    LowPassRampingLength:=RampingSamples;
   end else begin
    LowPassRampingLength:=Max(RampingSamples,(SampleRate+2) shr 2);
   end;
   LowPassIncrement:=(LowPassCoef-LowPassCurrent) div LowPassRampingLength;
  end;
  pl:=TpvPointer(EffectMixingBuffer);
  if (LowPassRampingLength>0) or (LowPassCoef<>(LowPassLength shl LowPassShift)) then begin
   CountSamples:=BufferSamples;
   while CountSamples>0 do begin
    ToDo:=CountSamples;
    if (LowPassRampingLength>0) and (ToDo>LowPassRampingLength) then begin
     ToDo:=LowPassRampingLength;
    end;
    dec(CountSamples,ToDo);
{$ifdef UseDIV}
    if LowPassRampingLength>0 then begin
     dec(LowPassRampingLength,ToDo);
     for i:=1 to ToDo do begin
      Coef:=LowPassCurrent div LowPassShiftLength;
      inc(LowPassCurrent,LowPassIncrement);
      inc(LowPassLeft,((pl^-LowPassLeft)*Coef) div LowPassLength);
      pl^:=LowPassLeft;
      inc(pl);
      inc(LowPassRight,((pl^-LowPassRight)*Coef) div LowPassLength);
      pl^:=LowPassRight;
      inc(pl);
     end;
     if LowPassRampingLength=0 then begin
      LowPassCurrent:=LowPassCoef;
     end;
    end else begin
     Coef:=LowPassCurrent div LowPassShiftLength;
     for i:=1 to ToDo do begin
      inc(LowPassLeft,((pl^-LowPassLeft)*Coef) div LowPassLength);
      pl^:=LowPassLeft;
      inc(pl);
      inc(LowPassRight,((pl^-LowPassRight)*Coef) div LowPassLength);
      pl^:=LowPassRight;
      inc(pl);
     end;
    end;
{$else}
    if LowPassRampingLength>0 then begin
     dec(LowPassRampingLength,ToDo);
     for i:=1 to ToDo do begin
      Coef:=SARLongint(LowPassCurrent,LowPassShift);
      inc(LowPassCurrent,LowPassIncrement);
      inc(LowPassLeft,SARLongint((pl^-LowPassLeft)*Coef,LowPassBits));
      pl^:=LowPassLeft;
      inc(pl);
      inc(LowPassRight,SARLongint((pl^-LowPassRight)*Coef,LowPassBits));
      pl^:=LowPassRight;
      inc(pl);
     end;
     if LowPassRampingLength=0 then begin
      LowPassCurrent:=LowPassCoef;
     end;
    end else begin
     Coef:=SARLongint(LowPassCurrent,LowPassShift);
     for i:=1 to ToDo do begin
      inc(LowPassLeft,SARLongint((pl^-LowPassLeft)*Coef,LowPassBits));
      pl^:=LowPassLeft;
      inc(pl);
      inc(LowPassRight,SARLongint((pl^-LowPassRight)*Coef,LowPassBits));
      pl^:=LowPassRight;
      inc(pl);
     end;
    end;
{$endif}
   end;
  end else if BufferSamples>1 then begin
   inc(pl,(BufferSamples-1) shl 1);
   LowPassLeft:=pl^;
   inc(pl);
   LowPassRight:=pl^;
  end;

  if ListenerUnderwater then begin
   Reverb.Dry:=1.0;
   Reverb.Wet:=1.0;
  end else begin
   Reverb.Dry:=1.0;
   Reverb.Wet:=0.0;
  end;
  Reverb.Process(EffectMixingBuffer,BufferSamples);

  pl:=TpvPointer(MixingBuffer);
  pll:=TpvPointer(EffectMixingBuffer);
  for i:=1 to BufferSamples do begin
   inc(pl^,pll^);
   inc(pl);
   inc(pll);
   inc(pl^,pll^);
   inc(pl);
   inc(pll);
  end;

  // Apply master volume
  if MasterVolume<>4096 then begin
   ClipBuffer(MixingBuffer,524288);
   pl:=TpvPointer(MixingBuffer);
 {$ifdef UnrolledLoops}
   for i:=1 to BufferChannelSamples shr 2 do begin
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
   end;
   for i:=1 to BufferChannelSamples and 3 do begin
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
   end;
 {$else}
   for i:=1 to BufferChannelSamples do begin
    pl^:=SARLongint(pl^*MasterVolume,12);
    inc(pl);
   end;
 {$endif}
  end;

  if AGCActive then begin
  // Automatic gain control
   pl:=TpvPointer(MixingBuffer);
   for i:=1 to BufferSamples do begin
    jl:=SARLongint(pl^*AGC,8);
    pl^:=SARLongint(TpvInt32((abs(jl+32768)-1)-abs(jl-32767)),1);
    inc(pl);
    jr:=SARLongint(pl^*AGC,8);
    pl^:=SARLongint(TpvInt32((abs(jr+32768)-1)-abs(jr-32767)),1);
    inc(pl);
    if ((jl<-32768) or (jl>32767)) or ((jr<-32768) or (jr>32767)) then begin
     dec(AGC);
     AGCCounter:=0;
    end else begin
     if AGC<256 then begin
      inc(AGCCounter);
      if AGCCounter>=AGCInterval then begin
       AGCCounter:=0;
       inc(AGC);
      end;
     end;
    end;
   end;
  end else begin
   // Clipping (condition-less!)
   pl:=TpvPointer(MixingBuffer);
{$ifdef UnrolledLoops}
   for i:=1 to BufferChannelSamples shr 2 do begin
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
   end;
   for i:=1 to BufferChannelSamples and 3 do begin
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
   end;
{$else}
   for i:=1 to BufferChannelSamples do begin
    pl^:=SARLongint(TpvInt32((abs(pl^+32768)-1)-abs(pl^-32767)),1);
    inc(pl);
   end;
{$endif}
  end;

  if assigned(WAVStreamDumpFinalMix) then begin
   WAVStreamDumpFinalMix.Dump(MixingBuffer,MixingBufferSize);
  end;

  // Downmixing
  if Channels=1 then begin
   pl:=TpvPointer(MixingBuffer);
   pll:=pl;
   plr:=pl;
   inc(plr);
{$ifdef UnrolledLoops}
   for i:=1 to BufferSamples shr 3 do begin
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
   end;
   for i:=1 to BufferSamples and 3 do begin
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
   end;
{$else}
   for i:=1 to BufferSamples do begin
    pl^:=SARLongint(pll^+plr^,1);
    inc(pl);
    inc(pll,2);
    inc(plr,2);
   end;
{$endif}
  end;
  case Bits of
   8:begin
    pb:=TpvPointer(OutputBuffer);
    pl:=TpvPointer(MixingBuffer);
{$ifdef UnrolledLoops}
    for i:=1 to BufferOutputChannelSamples shr 2 do begin
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
    end;
    for i:=1 to BufferOutputChannelSamples and 3 do begin
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
    end;
{$else}
    for i:=1 to BufferOutputChannelSamples do begin
     pb^:=(pl^+32768) shr 8;
     inc(pb);
     inc(pl);
    end;
{$endif}
   end;
   16:begin
    ps:=TpvPointer(OutputBuffer);
    pl:=TpvPointer(MixingBuffer);
{$ifdef UnrolledLoops}
    for i:=1 to BufferOutputChannelSamples shr 2 do begin
     ps^:=pl^;
     inc(ps);
     inc(pl);
     ps^:=pl^;
     inc(ps);
     inc(pl);
     ps^:=pl^;
     inc(ps);
     inc(pl);
     ps^:=pl^;
     inc(ps);
     inc(pl);
    end;
    for i:=1 to BufferOutputChannelSamples and 3 do begin
     ps^:=pl^;
     inc(ps);
     inc(pl);
    end;
{$else}
    for i:=1 to BufferOutputChannelSamples do begin
     ps^:=pl^;
     inc(ps);
     inc(pl);
    end;
{$endif}
   end;
  end;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.Lock;
begin
 CriticalSection.Enter;
 try
  IsReady:=false;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.Unlock;
begin
 CriticalSection.Enter;
 try
  IsReady:=true;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.SetActive(Active:boolean);
begin
 CriticalSection.Enter;
 try
  IsActive:=Active;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.Mute;
begin
 CriticalSection.Enter;
 try
  IsMuted:=true;
 finally
  CriticalSection.Leave;
 end;
end;

procedure TpvAudio.Unmute;
begin
 CriticalSection.Enter;
 try
  IsMuted:=false;
 finally
  CriticalSection.Leave;
 end;
end;

procedure ParseCommandParameters;
var Index:TpvSizeInt;
    Command:String;
begin
 for Index:=1 to ParamCount do begin
  Command:=ParamStr(Index);
  if (Command='/dumpaudio') or (Command='-dumpaudio') or (Command='--dumpaudio') then begin
   pvAudioDump:=true;
   break;
  end;
 end;
end;

initialization
 ParseCommandParameters;
end.
