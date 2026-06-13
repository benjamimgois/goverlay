(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
unit PasVulkan.Audio.FlexibleWavelet;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$rangechecks off}
{$overflowchecks off}

// Shared CPU reference core of the Flexible Wavelet Audio (FWA) codec, as the engine-side decode-only
// (and encode) sister of the C "fwa" CLI / the "FWAC" sub-codec inside the Flexible Wavelet Video (FWV)
// container. This base unit holds only the parts that the decoder and the encoder have in common: the
// format header, the Subbotin carryless range coder plus its adaptive context models, the reversible
// 5/3 and lossy 9/7 wavelet primitives, the QOA-style LMS predictor state, and the psychoacoustic quant
// shaping. PasVulkan.Audio.FlexibleWavelet.Decoder and .Encoder build the actual classes on top of it.
//
// The arithmetic is kept bit-for-bit identical to the C reference: signed right shifts go through the
// SARLongint / SARInt64 helpers of PasVulkan.Math.Utils (Object-Pascal's shr is a logical shift), and the range
// coder works on explicit 32-bit wrap-around values.

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Utils;

type EpvFlexibleWaveletAudio=class(Exception);

     { TpvFlexibleWaveletAudio }
     TpvFlexibleWaveletAudio=class // plain TObject base, resource-system-independent (NOT TpvResource)
      public
       const Magic=TpvUInt32($43415746); // the FWA blob magic 'FWAC' (low byte first: F,W,A,C)
             BlockSamples=8192; // per-block length per channel (non-overlapping blocks)
             MinBand=4; // stop the dyadic split when the low band gets this small
             MaxChannels=16; // sanity cap on the resolved channel count
             MaxChannelPairs=MaxChannels div 2;
             JointTopBands=2; // joint-stereo intensity: top frequency bands of Side collapsed to mono
             MaxSynthesisDepth=40;
             MaxBands=64;
             ClassCount=33; // magnitude-class symbol alphabet (0..32)
             BandContexts=8; // separate entropy contexts for the first subbands
             BinaryContextCap=8192;
             ClassContextCap=16384;
             RangeTop=TpvUInt32(1) shl 24;
             RangeBottom=TpvUInt32(1) shl 16;
             LMSMaxTaps=32;
             PerceptualMaxWeight=8.0;
             FlagPerceptual=1; // header flags bit0: psychoacoustic per-band quant shaping
             FlagPacket=2; // bit1: wavelet-packet best-basis (uniform quant)
             FlagJointStereo=4; // bit2: joint-stereo intensity (Side highs dropped)
             FlagLMS=8; // bit3: lossless LMS predictor (bits 8..15 carry the tap count)
             FlagPairing=16; // bit4: multichannel pairwise-M/S plan present
       const CDF97Alpha:TpvFloat=-1.586134342059924; // typed Single, matching the C float lifting constants
             CDF97Beta:TpvFloat=-0.052980118572961;
             CDF97Gamma:TpvFloat=0.882911075530934;
             CDF97Delta:TpvFloat=0.443506852043971;
             CDF97Scale:TpvFloat=1.230174104914001;
       type TAudioBuffer=array of TpvFloat; // one channel, planar
            TAudioBuffers=array of TAudioBuffer; // [channel] of TAudioBuffer
            PHeader=^THeader;
            { THeader }
            THeader=packed record // 24 bytes, byte-for-byte the C FwaHeader layout
             Magic:TpvUInt32;
             SampleRate:TpvUInt32;
             Channels:TpvUInt16;
             BlockSamples:TpvUInt16;
             Quality:TpvUInt16;
             Flags:TpvUInt16;
             FrameCount:TpvUInt64;
            end;
            TBandStarts=array[0..MaxBands-1] of TpvInt32;
            TSynthSizes=array[0..MaxSynthesisDepth] of TpvInt32;
            PRangeCoder=^TRangeCoder;
            { TRangeCoder }
            TRangeCoder=record // Subbotin carryless range coder (audio-internal, NOT the LZBRRC binary coder)
             Low:TpvUInt32;
             Range:TpvUInt32;
             Code:TpvUInt32; // decoder only
             Bytes:PpvUInt8Array;
             Position:TpvSizeUInt;
             Capacity:TpvSizeUInt; // encoder: allocation; decoder: read limit (a bounded over-read returns 0)
             OwnsBytes:boolean;
             procedure InitEncoder;
             procedure InitDecoder(const aBytes:PpvUInt8Array;const aLength:TpvSizeUInt);
             procedure Done;
             procedure Emit(const aByte:TpvUInt8);
             procedure NormaliseEncode;
             procedure Encode(const aCumulative,aFrequency,aTotal:TpvUInt32);
             procedure FlushEncoder;
             function ReadByte:TpvUInt8;
             function DecodeFreq(const aTotal:TpvUInt32):TpvUInt32;
             procedure DecodeUpdate(const aCumulative,aFrequency:TpvUInt32);
             procedure EncodeBypass(const aValue:TpvUInt32;const aBits:TpvInt32);
             function DecodeBypass(const aBits:TpvInt32):TpvUInt32;
            end;
            PClassContext=^TClassContext;
            { TClassContext }
            TClassContext=record // per-context adaptive multi-symbol model over the magnitude classes
             Counts:array[0..ClassCount-1] of TpvUInt16;
             Total:TpvUInt32;
             procedure Init;
             procedure Update(const aSymbol:TpvInt32);
             procedure Encode(var aCoder:TRangeCoder;const aSymbol:TpvInt32);
             function Decode(var aCoder:TRangeCoder):TpvInt32;
            end;
            PBinaryContext=^TBinaryContext;
            { TBinaryContext }
            TBinaryContext=record // adaptive binary context (counts of 0s and 1s, halved at the cap)
             Count0:TpvUInt16;
             Count1:TpvUInt16;
             procedure Init;
             procedure Update(const aBit:TpvInt32);
             procedure Encode(var aCoder:TRangeCoder;const aBit:TpvInt32);
             function Decode(var aCoder:TRangeCoder):TpvInt32;
            end;
            PLMSState=^TLMSState;
            { TLMSState }
            TLMSState=record // QOA-style 4..32-tap sign-sign LMS predictor (lossless decorrelation option)
             History:array[0..LMSMaxTaps-1] of TpvInt32;
             Weights:array[0..LMSMaxTaps-1] of TpvInt32;
             procedure Init(const aTaps:TpvInt32);
             function Predict(const aTaps:TpvInt32):TpvInt32;
             procedure Update(const aTaps,aAdaptShift,aSample,aResidual:TpvInt32);
            end;
      public
       // Coefficient <-> (class, mantissa) symbol mapping.
       class function ZigZag(const aValue:TpvInt32):TpvUInt32; static; {$ifdef caninline}inline;{$endif}
       class function UnZigZag(const aValue:TpvUInt32):TpvInt32; static; {$ifdef caninline}inline;{$endif}
       class function MagnitudeClass(aValue:TpvUInt32):TpvInt32; static;
       class function ClampInt16(const aValue:TpvInt32):TpvInt32; static; {$ifdef caninline}inline;{$endif}
       // Subband geometry.
       class function Reflect(aIndex,aLength:TpvInt32):TpvInt32; static; {$ifdef caninline}inline;{$endif}
       class function DWTLevelCount(const aLength:TpvInt32):TpvInt32; static;
       class function BandStarts(const aLength:TpvInt32;out aStarts:TBandStarts):TpvInt32; static;
       class function PacketBandSizes(const aRootLength:TpvInt32;out aSizes:TSynthSizes):TpvInt32; static;
       // Psychoacoustic quant shaping.
       class function LMSAdaptShift(const aTaps:TpvInt32):TpvInt32; static;
       class function AthDB(const aFrequency:TpvDouble):TpvDouble; static;
       class procedure ComputeSteps(const aLength:TpvInt32;const aBaseStep:TpvFloat;const aPerceptual:boolean;const aSampleRate:TpvInt32;const aStepPerCoeff:PpvFloatArray); static;
       // Reversible 5/3 (LeGall) wavelet, integer in place.
       class procedure Legall53ForwardLevel(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32); static;
       class procedure Legall53InverseLevel(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32); static;
       class procedure DWT53Forward(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32); static;
       class procedure DWT53Inverse(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32); static;
       // Lossy CDF 9/7 wavelet, float in place.
       class procedure DWT97ForwardLevel(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32); static;
       class procedure DWT97InverseLevel(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32); static;
       class procedure DWT97Forward(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32); static;
       class procedure DWT97Inverse(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32); static;
       // Deadzone quantize / dequantize with a per-coefficient step.
       class procedure QuantizeBlock(const aCoefficients:PpvFloatArray;const aIndices:PpvInt32Array;const aLength:TpvInt32;const aStepPerCoeff:PpvFloatArray); static;
       class procedure DequantizeBlock(const aIndices:PpvInt32Array;const aCoefficients:PpvFloatArray;const aLength:TpvInt32;const aStepPerCoeff:PpvFloatArray); static;
      end;

implementation

{ TpvFlexibleWaveletAudio.TRangeCoder }

procedure TpvFlexibleWaveletAudio.TRangeCoder.InitEncoder;
begin
 Low:=0;
 Range:=TpvUInt32($ffffffff);
 Code:=0;
 Capacity:=1024;
 GetMem(Bytes,Capacity);
 Position:=0;
 OwnsBytes:=true;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.InitDecoder(const aBytes:PpvUInt8Array;const aLength:TpvSizeUInt);
var Index:TpvInt32;
begin
 Low:=0;
 Range:=TpvUInt32($ffffffff);
 Code:=0;
 Bytes:=aBytes;
 Capacity:=aLength;
 Position:=0;
 OwnsBytes:=false;
 for Index:=1 to 4 do begin
  Code:=(Code shl 8) or ReadByte;
 end;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.Done;
begin
 if OwnsBytes and assigned(Bytes) then begin
  FreeMem(Bytes);
 end;
 Bytes:=nil;
 OwnsBytes:=false;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.Emit(const aByte:TpvUInt8);
begin
 if Position>=Capacity then begin
  Capacity:=Capacity shl 1;
  ReallocMem(Bytes,Capacity);
 end;
 Bytes^[Position]:=aByte;
 inc(Position);
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.NormaliseEncode;
var Temp:TpvUInt32;
    Renormalise:boolean;
begin
 repeat
  Renormalise:=false;
  Temp:=Low+Range; // truncates to 32 bits on assignment -> matches the C uint32 wrap-around
  if (Low xor Temp)<TpvFlexibleWaveletAudio.RangeTop then begin
   Renormalise:=true;
  end else if Range<TpvFlexibleWaveletAudio.RangeBottom then begin
   Range:=(TpvUInt32(0)-Low) and (TpvFlexibleWaveletAudio.RangeBottom-1);
   Renormalise:=true;
  end;
  if Renormalise then begin
   Emit(TpvUInt8(Low shr 24));
   Low:=Low shl 8;
   Range:=Range shl 8;
  end;
 until not Renormalise;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.Encode(const aCumulative,aFrequency,aTotal:TpvUInt32);
begin
 Range:=Range div aTotal;
 Low:=Low+(aCumulative*Range);
 Range:=Range*aFrequency;
 NormaliseEncode;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.FlushEncoder;
var Index:TpvInt32;
begin
 for Index:=1 to 4 do begin
  Emit(TpvUInt8(Low shr 24));
  Low:=Low shl 8;
 end;
end;

function TpvFlexibleWaveletAudio.TRangeCoder.ReadByte:TpvUInt8;
begin
 if Position<Capacity then begin
  result:=Bytes^[Position];
 end else begin
  result:=0;
 end;
 inc(Position);
end;

function TpvFlexibleWaveletAudio.TRangeCoder.DecodeFreq(const aTotal:TpvUInt32):TpvUInt32;
var Offset:TpvUInt32;
begin
 Range:=Range div aTotal;
 Offset:=Code-Low; // 32-bit wrap, like the C "(code - low)"
 result:=Offset div Range;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.DecodeUpdate(const aCumulative,aFrequency:TpvUInt32);
var Temp:TpvUInt32;
    Renormalise:boolean;
begin
 Low:=Low+(aCumulative*Range);
 Range:=Range*aFrequency;
 repeat
  Renormalise:=false;
  Temp:=Low+Range;
  if (Low xor Temp)<TpvFlexibleWaveletAudio.RangeTop then begin
   Renormalise:=true;
  end else if Range<TpvFlexibleWaveletAudio.RangeBottom then begin
   Range:=(TpvUInt32(0)-Low) and (TpvFlexibleWaveletAudio.RangeBottom-1);
   Renormalise:=true;
  end;
  if Renormalise then begin
   Code:=(Code shl 8) or ReadByte;
   Low:=Low shl 8;
   Range:=Range shl 8;
  end;
 until not Renormalise;
end;

procedure TpvFlexibleWaveletAudio.TRangeCoder.EncodeBypass(const aValue:TpvUInt32;const aBits:TpvInt32);
var Index:TpvInt32;
begin
 for Index:=aBits-1 downto 0 do begin
  Encode((aValue shr Index) and 1,1,2);
 end;
end;

function TpvFlexibleWaveletAudio.TRangeCoder.DecodeBypass(const aBits:TpvInt32):TpvUInt32;
var Index,Bit:TpvInt32;
    Frequency:TpvUInt32;
begin
 result:=0;
 for Index:=0 to aBits-1 do begin
  Frequency:=DecodeFreq(2);
  if Frequency>=1 then begin
   Bit:=1;
  end else begin
   Bit:=0;
  end;
  DecodeUpdate(TpvUInt32(Bit),1);
  result:=(result shl 1) or TpvUInt32(Bit);
 end;
end;

{ TpvFlexibleWaveletAudio.TClassContext }

procedure TpvFlexibleWaveletAudio.TClassContext.Init;
var Symbol:TpvInt32;
begin
 for Symbol:=0 to TpvFlexibleWaveletAudio.ClassCount-1 do begin
  Counts[Symbol]:=1;
 end;
 Total:=TpvFlexibleWaveletAudio.ClassCount;
end;

procedure TpvFlexibleWaveletAudio.TClassContext.Update(const aSymbol:TpvInt32);
var Symbol:TpvInt32;
begin
 inc(Counts[aSymbol]);
 inc(Total);
 if Total>=TpvUInt32(TpvFlexibleWaveletAudio.ClassContextCap) then begin
  Total:=0;
  for Symbol:=0 to TpvFlexibleWaveletAudio.ClassCount-1 do begin
   Counts[Symbol]:=(Counts[Symbol]+1) shr 1;
   inc(Total,Counts[Symbol]);
  end;
 end;
end;

procedure TpvFlexibleWaveletAudio.TClassContext.Encode(var aCoder:TRangeCoder;const aSymbol:TpvInt32);
var Cumulative:TpvUInt32;
    Symbol:TpvInt32;
begin
 Cumulative:=0;
 for Symbol:=0 to aSymbol-1 do begin
  inc(Cumulative,Counts[Symbol]);
 end;
 aCoder.Encode(Cumulative,Counts[aSymbol],Total);
 Update(aSymbol);
end;

function TpvFlexibleWaveletAudio.TClassContext.Decode(var aCoder:TRangeCoder):TpvInt32;
var Target,Cumulative:TpvUInt32;
    Symbol:TpvInt32;
begin
 Target:=aCoder.DecodeFreq(Total);
 Cumulative:=0;
 Symbol:=0;
 while (Symbol<(TpvFlexibleWaveletAudio.ClassCount-1)) and ((Cumulative+Counts[Symbol])<=Target) do begin
  inc(Cumulative,Counts[Symbol]);
  inc(Symbol);
 end;
 aCoder.DecodeUpdate(Cumulative,Counts[Symbol]);
 Update(Symbol);
 result:=Symbol;
end;

{ TpvFlexibleWaveletAudio.TBinaryContext }

procedure TpvFlexibleWaveletAudio.TBinaryContext.Init;
begin
 Count0:=1;
 Count1:=1;
end;

procedure TpvFlexibleWaveletAudio.TBinaryContext.Update(const aBit:TpvInt32);
begin
 if aBit=0 then begin
  inc(Count0);
 end else begin
  inc(Count1);
 end;
 if (TpvUInt32(Count0)+TpvUInt32(Count1))>=TpvUInt32(TpvFlexibleWaveletAudio.BinaryContextCap) then begin
  Count0:=(Count0+1) shr 1;
  Count1:=(Count1+1) shr 1;
 end;
end;

procedure TpvFlexibleWaveletAudio.TBinaryContext.Encode(var aCoder:TRangeCoder;const aBit:TpvInt32);
var Total:TpvUInt32;
begin
 Total:=TpvUInt32(Count0)+TpvUInt32(Count1);
 if aBit=0 then begin
  aCoder.Encode(0,Count0,Total);
 end else begin
  aCoder.Encode(Count0,Count1,Total);
 end;
 Update(aBit);
end;

function TpvFlexibleWaveletAudio.TBinaryContext.Decode(var aCoder:TRangeCoder):TpvInt32;
var Total,Value:TpvUInt32;
    Bit:TpvInt32;
begin
 Total:=TpvUInt32(Count0)+TpvUInt32(Count1);
 Value:=aCoder.DecodeFreq(Total);
 if Value>=Count0 then begin
  Bit:=1;
 end else begin
  Bit:=0;
 end;
 if Bit=0 then begin
  aCoder.DecodeUpdate(0,Count0);
 end else begin
  aCoder.DecodeUpdate(Count0,Count1);
 end;
 Update(Bit);
 result:=Bit;
end;

{ TpvFlexibleWaveletAudio.TLMSState }

procedure TpvFlexibleWaveletAudio.TLMSState.Init(const aTaps:TpvInt32);
var Index:TpvInt32;
begin
 for Index:=0 to aTaps-1 do begin
  History[Index]:=0;
  Weights[Index]:=0;
 end;
 if aTaps>=2 then begin
  Weights[aTaps-2]:=-(1 shl 13);
  Weights[aTaps-1]:=1 shl 14;
 end;
end;

function TpvFlexibleWaveletAudio.TLMSState.Predict(const aTaps:TpvInt32):TpvInt32;
var Prediction:TpvInt64;
    Index:TpvInt32;
begin
 Prediction:=0;
 for Index:=0 to aTaps-1 do begin
  Prediction:=Prediction+(TpvInt64(Weights[Index])*TpvInt64(History[Index]));
 end;
 result:=TpvInt32(SARInt64(Prediction,13));
end;

procedure TpvFlexibleWaveletAudio.TLMSState.Update(const aTaps,aAdaptShift,aSample,aResidual:TpvInt32);
var Delta,Index:TpvInt32;
begin

 // Sign-sign LMS: nudge each weight by +-delta following the sign of its history tap
 Delta:=SARLongint(aResidual,aAdaptShift);
 for Index:=0 to aTaps-1 do begin
  if History[Index]<0 then begin
   Weights[Index]:=Weights[Index]-Delta;
  end else begin
   Weights[Index]:=Weights[Index]+Delta;
  end;
 end;

 // Shift the history and append the new sample
 for Index:=0 to aTaps-2 do begin
  History[Index]:=History[Index+1];
 end;
 History[aTaps-1]:=aSample;

end;

{ TpvFlexibleWaveletAudio }

class function TpvFlexibleWaveletAudio.ZigZag(const aValue:TpvInt32):TpvUInt32;
begin
 result:=(TpvUInt32(aValue) shl 1) xor TpvUInt32(SARLongint(aValue,31));
end;

class function TpvFlexibleWaveletAudio.UnZigZag(const aValue:TpvUInt32):TpvInt32;
begin
 result:=TpvInt32((aValue shr 1) xor (TpvUInt32(0)-(aValue and 1)));
end;

class function TpvFlexibleWaveletAudio.MagnitudeClass(aValue:TpvUInt32):TpvInt32;
begin
 result:=0;
 while aValue<>0 do begin
  inc(result);
  aValue:=aValue shr 1;
 end;
end;

class function TpvFlexibleWaveletAudio.ClampInt16(const aValue:TpvInt32):TpvInt32;
begin
 if aValue>32767 then begin
  result:=32767;
 end else if aValue<-32768 then begin
  result:=-32768;
 end else begin
  result:=aValue;
 end;
end;

class function TpvFlexibleWaveletAudio.Reflect(aIndex,aLength:TpvInt32):TpvInt32;
begin
 if aIndex<0 then begin
  aIndex:=-aIndex;
 end;
 if aIndex>=aLength then begin
  aIndex:=((2*aLength)-2)-aIndex;
 end;
 if aIndex<0 then begin
  result:=0;
 end else if aIndex>=aLength then begin
  result:=aLength-1;
 end else begin
  result:=aIndex;
 end;
end;

class function TpvFlexibleWaveletAudio.DWTLevelCount(const aLength:TpvInt32):TpvInt32;
var Current:TpvInt32;
begin
 result:=0;
 Current:=aLength;
 while Current>=(MinBand*2) do begin
  inc(result);
  Current:=(Current+1) div 2;
 end;
end;

class function TpvFlexibleWaveletAudio.BandStarts(const aLength:TpvInt32;out aStarts:TBandStarts):TpvInt32;
var Sizes:array[0..MaxBands-1] of TpvInt32;
    Levels,Current,Level,Start,Count:TpvInt32;
begin

 // Sub-band sizes at each level (each level halves the low band)
 Levels:=DWTLevelCount(aLength);
 Current:=aLength;
 for Level:=0 to Levels do begin
  Sizes[Level]:=Current;
  Current:=(Current+1) div 2;
 end;

 // Ascending band start positions: [0, LL_end, next-band, ...]
 Count:=0;
 aStarts[Count]:=0;
 inc(Count);
 for Level:=Levels downto 1 do begin
  Start:=Sizes[Level];
  if (Start>aStarts[Count-1]) and (Start<aLength) then begin
   aStarts[Count]:=Start;
   inc(Count);
  end;
 end;

 result:=Count;

end;

class function TpvFlexibleWaveletAudio.PacketBandSizes(const aRootLength:TpvInt32;out aSizes:TSynthSizes):TpvInt32;
var Depth,Current,Half:TpvInt32;
begin
 Depth:=0;
 Current:=aRootLength;
 aSizes[0]:=Current;
 while (Depth<MaxSynthesisDepth) and (Current>=8) do begin
  Half:=(Current+1) div 2;
  inc(Depth);
  Current:=Half;
  aSizes[Depth]:=Current;
 end;
 result:=Depth;
end;

class function TpvFlexibleWaveletAudio.LMSAdaptShift(const aTaps:TpvInt32):TpvInt32;
var Tap:TpvInt32;
begin
 result:=4;
 Tap:=aTaps;
 while Tap>4 do begin
  inc(result);
  Tap:=Tap shr 1;
 end;
end;

class function TpvFlexibleWaveletAudio.AthDB(const aFrequency:TpvDouble):TpvDouble;
var Frequency:TpvDouble;
begin
 Frequency:=aFrequency/1000.0;
 if Frequency<0.02 then begin
  Frequency:=0.02;
 end;
 result:=((3.64*Power(Frequency,-0.8))-(6.5*Exp((-0.6*(Frequency-3.3))*(Frequency-3.3))))+(0.001*Power(Frequency,4.0));
end;

class procedure TpvFlexibleWaveletAudio.ComputeSteps(const aLength:TpvInt32;const aBaseStep:TpvFloat;const aPerceptual:boolean;const aSampleRate:TpvInt32;const aStepPerCoeff:PpvFloatArray);
var Starts:TBandStarts;
    BandWeight:array[0..MaxBands-1] of TpvDouble;
    BandAth:array[0..MaxBands-1] of TpvDouble;
    BandCount,Levels,BandIndex,Index,Band,DetailLevel:TpvInt32;
    Nyquist,MinimumAth,Center,Weight:TpvDouble;
begin

 // Non-perceptual: a flat base step for every coefficient
 if not aPerceptual then begin
  for Index:=0 to aLength-1 do begin
   aStepPerCoeff^[Index]:=aBaseStep;
  end;
  exit;
 end;

 // Per-band ATH centre frequency -> threshold (and track the most-sensitive band)
 BandCount:=BandStarts(aLength,Starts);
 Levels:=DWTLevelCount(aLength);
 Nyquist:=aSampleRate/2.0;
 MinimumAth:=1e9;
 for BandIndex:=0 to BandCount-1 do begin
  if BandIndex=0 then begin
   Center:=Nyquist/(TpvInt64(1) shl (Levels+1)); // LL (sub-bass)
  end else begin
   DetailLevel:=Levels-BandIndex;
   if DetailLevel<0 then begin
    DetailLevel:=0;
   end;
   Center:=(Nyquist*0.75)/(TpvInt64(1) shl DetailLevel);
  end;
  BandAth[BandIndex]:=AthDB(Center);
  if BandAth[BandIndex]<MinimumAth then begin
   MinimumAth:=BandAth[BandIndex];
  end;
 end;

 // Per-band quant weight = ATH gap above the most-sensitive band, clamped to [1,PerceptualMaxWeight]
 for BandIndex:=0 to BandCount-1 do begin
  Weight:=Power(10.0,(BandAth[BandIndex]-MinimumAth)/20.0);
  if Weight>PerceptualMaxWeight then begin
   Weight:=PerceptualMaxWeight;
  end;
  if Weight<1.0 then begin
   Weight:=1.0;
  end;
  BandWeight[BandIndex]:=Weight;
 end;

 // Spread the per-band weight out to a per-coefficient step
 Band:=0;
 for Index:=0 to aLength-1 do begin
  while ((Band+1)<BandCount) and (Index>=Starts[Band+1]) do begin
   inc(Band);
  end;
  aStepPerCoeff^[Index]:=aBaseStep*BandWeight[Band];
 end;

end;

class procedure TpvFlexibleWaveletAudio.Legall53ForwardLevel(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32);
var Index,Half,Left,Right:TpvInt32;
begin

 // Predict: detail = odd - (left even + right even)/2
 Index:=1;
 while Index<aLength do begin
  Left:=aData^[Index-1];
  Right:=aData^[Reflect(Index+1,aLength)];
  aData^[Index]:=aData^[Index]-SARLongint(Left+Right,1);
  inc(Index,2);
 end;

 // Update: smooth = even + (left detail + right detail + 2)/4
 Index:=0;
 while Index<aLength do begin
  Left:=aData^[Reflect(Index-1,aLength)];
  Right:=aData^[Reflect(Index+1,aLength)];
  aData^[Index]:=aData^[Index]+SARLongint((Left+Right)+2,2);
  inc(Index,2);
 end;

 // Deinterleave: evens -> [0,half), odds -> [half,length)
 Half:=(aLength+1) div 2;
 for Index:=0 to aLength-1 do begin
  if (Index and 1)=0 then begin
   aScratch^[Index shr 1]:=aData^[Index];
  end else begin
   aScratch^[Half+(Index shr 1)]:=aData^[Index];
  end;
 end;
 Move(aScratch^[0],aData^[0],aLength*SizeOf(TpvInt32));

end;

class procedure TpvFlexibleWaveletAudio.Legall53InverseLevel(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32);
var Index,Half,Left,Right:TpvInt32;
begin

 // Interleave back (low half + high half -> evens/odds)
 Half:=(aLength+1) div 2;
 for Index:=0 to aLength-1 do begin
  if (Index and 1)=0 then begin
   aScratch^[Index]:=aData^[Index shr 1];
  end else begin
   aScratch^[Index]:=aData^[Half+(Index shr 1)];
  end;
 end;
 Move(aScratch^[0],aData^[0],aLength*SizeOf(TpvInt32));

 // Undo update
 Index:=0;
 while Index<aLength do begin
  Left:=aData^[Reflect(Index-1,aLength)];
  Right:=aData^[Reflect(Index+1,aLength)];
  aData^[Index]:=aData^[Index]-SARLongint((Left+Right)+2,2);
  inc(Index,2);
 end;

 // Undo predict
 Index:=1;
 while Index<aLength do begin
  Left:=aData^[Index-1];
  Right:=aData^[Reflect(Index+1,aLength)];
  aData^[Index]:=aData^[Index]+SARLongint(Left+Right,1);
  inc(Index,2);
 end;

end;

class procedure TpvFlexibleWaveletAudio.DWT53Forward(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32);
var Current,Levels,Level:TpvInt32;
begin
 Current:=aLength;
 Levels:=DWTLevelCount(aLength);
 for Level:=0 to Levels-1 do begin
  Legall53ForwardLevel(aData,aScratch,Current);
  Current:=(Current+1) div 2;
 end;
end;

class procedure TpvFlexibleWaveletAudio.DWT53Inverse(const aData,aScratch:PpvInt32Array;const aLength:TpvInt32);
var Levels,Current,Level:TpvInt32;
    Sizes:array[0..MaxSynthesisDepth-1] of TpvInt32;
begin
 Levels:=DWTLevelCount(aLength);
 Current:=aLength;
 for Level:=0 to Levels-1 do begin
  Sizes[Level]:=Current;
  Current:=(Current+1) div 2;
 end;
 for Level:=Levels-1 downto 0 do begin
  Legall53InverseLevel(aData,aScratch,Sizes[Level]);
 end;
end;

class procedure TpvFlexibleWaveletAudio.DWT97ForwardLevel(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32);
var Index,Half:TpvInt32;
begin

 // Lifting: the four CDF 9/7 predict/update passes (alpha, beta, gamma, delta)
 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]+(CDF97Alpha*(aData^[Index-1]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]+(CDF97Beta*(aData^[Reflect(Index-1,aLength)]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]+(CDF97Gamma*(aData^[Index-1]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]+(CDF97Delta*(aData^[Reflect(Index-1,aLength)]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 // Scaling: odd (detail) samples * K, even (smooth) samples / K
 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]*CDF97Scale;
  inc(Index,2);
 end;

 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]*(1.0/CDF97Scale);
  inc(Index,2);
 end;

 // Deinterleave: smooth half to the front, detail half to the back
 Half:=(aLength+1) div 2;
 for Index:=0 to aLength-1 do begin
  if (Index and 1)=0 then begin
   aScratch^[Index shr 1]:=aData^[Index];
  end else begin
   aScratch^[Half+(Index shr 1)]:=aData^[Index];
  end;
 end;
 Move(aScratch^[0],aData^[0],aLength*SizeOf(TpvFloat));

end;

class procedure TpvFlexibleWaveletAudio.DWT97InverseLevel(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32);
var Index,Half:TpvInt32;
begin

 // Interleave back (low/high halves -> evens/odds)
 Half:=(aLength+1) div 2;
 for Index:=0 to aLength-1 do begin
  if (Index and 1)=0 then begin
   aScratch^[Index]:=aData^[Index shr 1];
  end else begin
   aScratch^[Index]:=aData^[Half+(Index shr 1)];
  end;
 end;
 Move(aScratch^[0],aData^[0],aLength*SizeOf(TpvFloat));

 // Undo scaling
 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]*CDF97Scale;
  inc(Index,2);
 end;

 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]*(1.0/CDF97Scale);
  inc(Index,2);
 end;

 // Undo the four lifting passes in reverse order (delta, gamma, beta, alpha)
 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]-(CDF97Delta*(aData^[Reflect(Index-1,aLength)]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]-(CDF97Gamma*(aData^[Index-1]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=0;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]-(CDF97Beta*(aData^[Reflect(Index-1,aLength)]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

 Index:=1;
 while Index<aLength do begin
  aData^[Index]:=aData^[Index]-(CDF97Alpha*(aData^[Index-1]+aData^[Reflect(Index+1,aLength)]));
  inc(Index,2);
 end;

end;

class procedure TpvFlexibleWaveletAudio.DWT97Forward(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32);
var Current,Levels,Level:TpvInt32;
begin
 Current:=aLength;
 Levels:=DWTLevelCount(aLength);
 for Level:=0 to Levels-1 do begin
  DWT97ForwardLevel(aData,aScratch,Current);
  Current:=(Current+1) div 2;
 end;
end;

class procedure TpvFlexibleWaveletAudio.DWT97Inverse(const aData,aScratch:PpvFloatArray;const aLength:TpvInt32);
var Levels,Current,Level:TpvInt32;
    Sizes:array[0..MaxSynthesisDepth-1] of TpvInt32;
begin
 Levels:=DWTLevelCount(aLength);
 Current:=aLength;
 for Level:=0 to Levels-1 do begin
  Sizes[Level]:=Current;
  Current:=(Current+1) div 2;
 end;
 for Level:=Levels-1 downto 0 do begin
  DWT97InverseLevel(aData,aScratch,Sizes[Level]);
 end;
end;

class procedure TpvFlexibleWaveletAudio.QuantizeBlock(const aCoefficients:PpvFloatArray;const aIndices:PpvInt32Array;const aLength:TpvInt32;const aStepPerCoeff:PpvFloatArray);
var Index:TpvInt32;
    Scaled:TpvFloat;
begin
 for Index:=0 to aLength-1 do begin
  Scaled:=aCoefficients^[Index]/aStepPerCoeff^[Index];
  if Scaled>=0.0 then begin
   aIndices^[Index]:=Trunc(Scaled+0.5);
  end else begin
   aIndices^[Index]:=Trunc(Scaled-0.5);
  end;
 end;
end;

class procedure TpvFlexibleWaveletAudio.DequantizeBlock(const aIndices:PpvInt32Array;const aCoefficients:PpvFloatArray;const aLength:TpvInt32;const aStepPerCoeff:PpvFloatArray);
var Index:TpvInt32;
begin
 for Index:=0 to aLength-1 do begin
  aCoefficients^[Index]:=aIndices^[Index]*aStepPerCoeff^[Index];
 end;
end;

end.
