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
unit PasVulkan.Audio.FlexibleWavelet.Encoder;
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

// Encoder for the Flexible Wavelet Audio (FWA) codec. Pure CPU and self-contained: it takes planar 32-bit
// float PCM (one buffer per channel) plus a parameter record, and writes a complete FWA blob (the same
// container the C "fwa" CLI / the "FWAC" video sub-codec produce) to a caller-owned TStream.
//
// The pipeline mirrors the decoder in reverse: float -> int16 ingest, Mid/Side (and optional multichannel
// pairwise M/S) decorrelation, the optional lossless LMS predictor, then per block the forward wavelet
// (reversible 5/3 for lossless, or lossy CDF 9/7, optionally as a rate-distortion wavelet-packet best
// basis), dead-zone quantisation, and the adaptive range-coder entropy stage. The shared DSP/entropy core
// lives in PasVulkan.Audio.FlexibleWavelet; this unit only adds the forward paths and the container writer.

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Utils,
     PasVulkan.Audio.FlexibleWavelet;

type EpvFlexibleWaveletAudioEncoder=class(EpvFlexibleWaveletAudio);

     { TpvFlexibleWaveletAudioEncoder }
     TpvFlexibleWaveletAudioEncoder=class(TpvFlexibleWaveletAudio)
      public
       const PacketRDLambda=0.0012; // rate-distortion weight for the wavelet-packet best-basis split decision
       type { TpvFlexibleWaveletAudioEncoder.TParams }
            TParams=record
             Quality:TpvInt32; // 0 = lossless (reversible 5/3 or LMS), >= 1 = lossy 9/7 quant step
             Perceptual:boolean; // psychoacoustic per-band quant shaping (lossy)
             Packet:boolean; // wavelet-packet best-basis (lossy, uniform quant)
             Joint:boolean; // joint-stereo intensity (lossy stereo)
             LMS:boolean; // lossless LMS predictor instead of 5/3 (quality 0 only)
             LMSTaps:TpvInt32;
             PairEnabled:boolean; // multichannel (>=3) pairwise Mid/Side
             Adapt:boolean; // per-pair adaptive best-of-both
            end;
            PParams=^TParams;
            { TpvFlexibleWaveletAudioEncoder.TBitWriter }
            TBitWriter=record // MSB-first bit writer for the wavelet-packet preorder tree
             Bytes:array of TpvUInt8;
             BytePosition:TpvSizeUInt;
             BitPosition:TpvInt32;
             procedure Init;
             procedure Put(const aValue:TpvUInt32;const aBits:TpvInt32);
             function ByteLength:TpvSizeUInt;
             procedure Append(const aSource:TBitWriter);
            end;
            TPairArray=array[0..MaxChannelPairs-1,0..1] of TpvInt32;
      private
       fStream:TStream;
       fSynthesisGainSquared:array[0..MaxSynthesisDepth] of TpvDouble;
       fSynthesisGainReady:boolean;
       procedure WriteU8(const aValue:TpvUInt8);
       procedure WriteU16(const aValue:TpvUInt16);
       procedure WriteU32(const aValue:TpvUInt32);
       procedure WriteU64(const aValue:TpvUInt64);
       function GetPairs(const aChannels:TpvInt32;out aPairs:TPairArray):TpvInt32;
       function MSPairBeneficial(const aA,aB:PpvInt32Array;const aCount:TpvInt64):boolean;
       procedure MSPairForward(const aA,aB:PpvInt32Array;const aCount:TpvInt64);
       procedure LMSForward(const aData:PpvInt32Array;const aCount:TpvInt64;const aTaps:TpvInt32);
       function SegmentCost(const aSegment:PpvFloatArray;const aLength:TpvInt32):TpvDouble;
       procedure MeasureSynthesisGain(const aRootLength:TpvInt32);
       function PacketLeafCost(const aSegment:PpvFloatArray;const aLength,aDepth:TpvInt32;const aStep:TpvFloat):TpvDouble;
       function PacketDecompose(const aSegment:PpvFloatArray;const aLength,aDepth,aMaxDepth:TpvInt32;const aStep:TpvFloat;const aScratch:PpvFloatArray;var aTree:TBitWriter):TpvDouble;
       procedure JointStereoZeroSideHighs(const aCoefficients:PpvFloatArray;const aLength:TpvInt32);
       procedure EncodeBlockCoeffs(const aCoefficients:PpvInt32Array;const aLength:TpvInt32;var aCoder:TRangeCoder);
      public
       procedure Encode(const aChannelBuffer:TAudioBuffers;const aSampleRate:TpvInt32;const aParams:TParams;const aStream:TStream);
      end;

implementation

{ TpvFlexibleWaveletAudioEncoder.TBitWriter }

procedure TpvFlexibleWaveletAudioEncoder.TBitWriter.Init;
begin
 Bytes:=nil;
 SetLength(Bytes,256); // fresh, zero-initialised
 BytePosition:=0;
 BitPosition:=0;
end;

procedure TpvFlexibleWaveletAudioEncoder.TBitWriter.Put(const aValue:TpvUInt32;const aBits:TpvInt32);
var Index,Bit:TpvInt32;
begin
 for Index:=aBits-1 downto 0 do begin
  if (BytePosition+1)>=TpvSizeUInt(System.Length(Bytes)) then begin
   SetLength(Bytes,(System.Length(Bytes)+1) shl 1); // grow; new bytes are zero
  end;
  Bit:=(aValue shr Index) and 1;
  Bytes[BytePosition]:=Bytes[BytePosition] or TpvUInt8(Bit shl (7-BitPosition));
  inc(BitPosition);
  if BitPosition=8 then begin
   BitPosition:=0;
   inc(BytePosition);
   Bytes[BytePosition]:=0;
  end;
 end;
end;

function TpvFlexibleWaveletAudioEncoder.TBitWriter.ByteLength:TpvSizeUInt;
begin
 result:=BytePosition;
 if BitPosition>0 then begin
  inc(result);
 end;
end;

procedure TpvFlexibleWaveletAudioEncoder.TBitWriter.Append(const aSource:TBitWriter);
var ByteIndex,BitIndex,Value:TpvSizeUInt;
begin

 // Splice the source's whole bytes, in order
 ByteIndex:=0;
 while ByteIndex<aSource.BytePosition do begin
  Put(aSource.Bytes[ByteIndex],8);
  inc(ByteIndex);
 end;

 // Then its trailing partial byte, bit by bit
 BitIndex:=0;
 while BitIndex<TpvSizeUInt(aSource.BitPosition) do begin
  Value:=(aSource.Bytes[aSource.BytePosition] shr (7-BitIndex)) and 1;
  Put(TpvUInt32(Value),1);
  inc(BitIndex);
 end;

end;

{ TpvFlexibleWaveletAudioEncoder }

procedure TpvFlexibleWaveletAudioEncoder.WriteU8(const aValue:TpvUInt8);
begin
 fStream.WriteBuffer(aValue,SizeOf(TpvUInt8));
end;

procedure TpvFlexibleWaveletAudioEncoder.WriteU16(const aValue:TpvUInt16);
var Bytes:array[0..1] of TpvUInt8;
begin
 Bytes[0]:=aValue and $ff;
 Bytes[1]:=(aValue shr 8) and $ff;
 fStream.WriteBuffer(Bytes[0],2);
end;

procedure TpvFlexibleWaveletAudioEncoder.WriteU32(const aValue:TpvUInt32);
var Bytes:array[0..3] of TpvUInt8;
begin
 Bytes[0]:=aValue and $ff;
 Bytes[1]:=(aValue shr 8) and $ff;
 Bytes[2]:=(aValue shr 16) and $ff;
 Bytes[3]:=(aValue shr 24) and $ff;
 fStream.WriteBuffer(Bytes[0],4);
end;

procedure TpvFlexibleWaveletAudioEncoder.WriteU64(const aValue:TpvUInt64);
begin
 WriteU32(TpvUInt32(aValue and $ffffffff));
 WriteU32(TpvUInt32((aValue shr 32) and $ffffffff));
end;

function TpvFlexibleWaveletAudioEncoder.GetPairs(const aChannels:TpvInt32;out aPairs:TPairArray):TpvInt32;
begin
{
 // Derived from the C canonical_layout_name(channels) -> derive_pairs: front L/R is always (0,1), the
 // surround/rear L/R pairs follow the standard channel orders; an unknown count falls back to just (0,1).
 case aChannels of
  5:begin // 5.0
    aPairs[0,0]:=0; aPairs[0,1]:=1;
    aPairs[1,0]:=3; aPairs[1,1]:=4;
    result:=2;
   end;
  6:begin // 5.1
    aPairs[0,0]:=0; aPairs[0,1]:=1;
    aPairs[1,0]:=4; aPairs[1,1]:=5;
    result:=2;
   end;
  7:begin // 6.1
    aPairs[0,0]:=0; aPairs[0,1]:=1;
    aPairs[1,0]:=5; aPairs[1,1]:=6;
    result:=2;
   end;
  8:begin // 7.1
    aPairs[0,0]:=0; aPairs[0,1]:=1;
    aPairs[1,0]:=4; aPairs[1,1]:=5;
    aPairs[2,0]:=6; aPairs[2,1]:=7;
    result:=3;
   end;
  else begin // 2.1 / 4.0 and any other unrecognised >= 3 channel count: just front L/R
   aPairs[0,0]:=0; aPairs[0,1]:=1;
   result:=1;
  end;
 end;
}
 // Mirrors the C fwa_encode wrapper, which passes an empty layout to fwacodec_encode, so derive_pairs
 // falls back to pairing just the front L/R (channels 0 and 1). The full ffmpeg-layout pairing table is
 // only used by the standalone fwa CLI, which probes the real channel layout. aChannels is accepted for
 // signature parity with that layout-aware variant.
 aPairs[0,0]:=0;
 aPairs[0,1]:=1;
 result:=1;
end;

function TpvFlexibleWaveletAudioEncoder.MSPairBeneficial(const aA,aB:PpvInt32Array;const aCount:TpvInt64):boolean;
var LeftRight,MidSide:TpvDouble;
    Index:TpvInt64;
    Left,Right,Side,Mid:TpvInt32;
begin
 LeftRight:=0.0;
 MidSide:=0.0;
 for Index:=0 to aCount-1 do begin
  Left:=aA^[Index];
  Right:=aB^[Index];
  Side:=Left-Right;
  Mid:=Right+SARLongint(Side,1);
  LeftRight:=LeftRight+(Abs(Left)+Abs(Right));
  MidSide:=MidSide+(Abs(Mid)+Abs(Side));
 end;
 result:=MidSide<LeftRight; // FLAC-style sum-of-magnitudes proxy for coded size
end;

procedure TpvFlexibleWaveletAudioEncoder.MSPairForward(const aA,aB:PpvInt32Array;const aCount:TpvInt64);
var Index:TpvInt64;
    Left,Right,Side:TpvInt32;
begin
 for Index:=0 to aCount-1 do begin
  Left:=aA^[Index];
  Right:=aB^[Index];
  Side:=Left-Right;
  aA^[Index]:=Right+SARLongint(Side,1);
  aB^[Index]:=Side;
 end;
end;

procedure TpvFlexibleWaveletAudioEncoder.LMSForward(const aData:PpvInt32Array;const aCount:TpvInt64;const aTaps:TpvInt32);
var LMS:TLMSState;
    AdaptShift:TpvInt32;
    Index:TpvInt64;
    Sample,Residual:TpvInt32;
begin
 LMS.Init(aTaps);
 AdaptShift:=LMSAdaptShift(aTaps);
 for Index:=0 to aCount-1 do begin
  Sample:=aData^[Index];
  Residual:=Sample-LMS.Predict(aTaps);
  aData^[Index]:=Residual;
  LMS.Update(aTaps,AdaptShift,Sample,Residual);
 end;
end;

function TpvFlexibleWaveletAudioEncoder.SegmentCost(const aSegment:PpvFloatArray;const aLength:TpvInt32):TpvDouble;
var Index:TpvInt32;
begin
 // Additive, basis-independent estimate of the coding bits -> the RATE part of the best-basis cost
 result:=0.0;
 for Index:=0 to aLength-1 do begin
  result:=result+Log2(Abs(aSegment^[Index])+1.0);
 end;
end;

procedure TpvFlexibleWaveletAudioEncoder.MeasureSynthesisGain(const aRootLength:TpvInt32);
var Sizes:TSynthSizes;
    MaxDepth,Depth,Level,Index:TpvInt32;
    Buffer,Scratch:array of TpvFloat;
    Energy,Value:TpvDouble;
begin

 // gain(d)^2 = sample-domain L2 energy of a single unit coefficient in a depth-d leaf, synthesised up
 MaxDepth:=PacketBandSizes(aRootLength,Sizes);
 SetLength(Buffer,aRootLength);
 SetLength(Scratch,aRootLength);
 for Depth:=0 to MaxDepth do begin
  for Index:=0 to aRootLength-1 do begin
   Buffer[Index]:=0.0;
  end;
  Buffer[0]:=1.0;
  for Level:=Depth downto 1 do begin
   DWT97InverseLevel(PpvFloatArray(@Buffer[0]),PpvFloatArray(@Scratch[0]),Sizes[Level-1]);
  end;
  Energy:=0.0;
  for Index:=0 to aRootLength-1 do begin
   Value:=Buffer[Index];
   Energy:=Energy+(Value*Value);
  end;
  fSynthesisGainSquared[Depth]:=Energy;
 end;

 // Clamp the unreachable depths to the deepest measured gain
 for Depth:=MaxDepth+1 to MaxSynthesisDepth do begin
  fSynthesisGainSquared[Depth]:=fSynthesisGainSquared[MaxDepth];
 end;
 fSynthesisGainReady:=true;

end;

function TpvFlexibleWaveletAudioEncoder.PacketLeafCost(const aSegment:PpvFloatArray;const aLength,aDepth:TpvInt32;const aStep:TpvFloat):TpvDouble;
var Rate,GainSquared,PerCoeffVariance,Distortion,StepDouble:TpvDouble;
    ClampedDepth:TpvInt32;
begin

 // Rate (coding bits) + lambda * synthesis-gain-amplified quantisation distortion
 Rate:=SegmentCost(aSegment,aLength);
 if aDepth<0 then begin
  ClampedDepth:=0;
 end else if aDepth>MaxSynthesisDepth then begin
  ClampedDepth:=MaxSynthesisDepth;
 end else begin
  ClampedDepth:=aDepth;
 end;
 if fSynthesisGainReady then begin
  GainSquared:=fSynthesisGainSquared[ClampedDepth];
 end else begin
  GainSquared:=1.0;
 end;
 StepDouble:=aStep; // widen the Single step to Double (matches the C "(double)step")
 PerCoeffVariance:=(StepDouble*StepDouble)/12.0;
 Distortion:=(aLength*PerCoeffVariance)*GainSquared;
 result:=Rate+(PacketRDLambda*Distortion);

end;

function TpvFlexibleWaveletAudioEncoder.PacketDecompose(const aSegment:PpvFloatArray;const aLength,aDepth,aMaxDepth:TpvInt32;const aStep:TpvFloat;const aScratch:PpvFloatArray;var aTree:TBitWriter):TpvDouble;
var LeafCost,LowCost,HighCost:TpvDouble;
    Half:TpvInt32;
    Copy:array of TpvFloat;
    LowTree,HighTree:TBitWriter;
begin

 // Forced leaf: too deep or too short to split further
 LeafCost:=PacketLeafCost(aSegment,aLength,aDepth,aStep);
 if (aDepth>=aMaxDepth) or (aLength<8) then begin
  aTree.Put(0,1);
  result:=LeafCost;
  exit;
 end;

 // Trial split on a copy (so a rejected split leaves the segment untouched)
 SetLength(Copy,aLength);
 Move(aSegment^[0],Copy[0],aLength*SizeOf(TpvFloat));
 DWT97ForwardLevel(PpvFloatArray(@Copy[0]),aScratch,aLength);
 Half:=(aLength+1) div 2;
 LowTree.Init;
 HighTree.Init;
 LowCost:=PacketDecompose(PpvFloatArray(@Copy[0]),Half,aDepth+1,aMaxDepth,aStep,aScratch,LowTree);
 HighCost:=PacketDecompose(PpvFloatArray(@Copy[Half]),aLength-Half,aDepth+1,aMaxDepth,aStep,aScratch,HighTree);

 // Commit the split only when the children code cheaper than the leaf
 if (LowCost+HighCost)<LeafCost then begin
  Move(Copy[0],aSegment^[0],aLength*SizeOf(TpvFloat));
  aTree.Put(1,1);
  aTree.Append(LowTree);
  aTree.Append(HighTree);
  result:=LowCost+HighCost;
 end else begin
  aTree.Put(0,1);
  result:=LeafCost;
 end;

end;

procedure TpvFlexibleWaveletAudioEncoder.JointStereoZeroSideHighs(const aCoefficients:PpvFloatArray;const aLength:TpvInt32);
var Starts:TBandStarts;
    BandCount,FirstZeroedBand,ZeroStart,Index:TpvInt32;
begin
 BandCount:=BandStarts(aLength,Starts);
 if BandCount<=JointTopBands then begin
  exit; // too few bands to keep any stereo high-frequency distinction
 end;
 FirstZeroedBand:=BandCount-JointTopBands;
 ZeroStart:=Starts[FirstZeroedBand];
 for Index:=ZeroStart to aLength-1 do begin
  aCoefficients^[Index]:=0.0;
 end;
end;

procedure TpvFlexibleWaveletAudioEncoder.EncodeBlockCoeffs(const aCoefficients:PpvInt32Array;const aLength:TpvInt32;var aCoder:TRangeCoder);
var ClassContexts:array[0..BandContexts-1] of TClassContext;
    Starts:TBandStarts;
    BandCount,Band,BandContext,Index,Klass:TpvInt32;
    Value,Mantissa:TpvUInt32;
begin

 // Fresh range-coder stream + per-band class contexts (reset per block)
 aCoder.InitEncoder;
 FillChar(ClassContexts,SizeOf(ClassContexts),0);
 for Index:=0 to BandContexts-1 do begin
  ClassContexts[Index].Init;
 end;
 BandCount:=BandStarts(aLength,Starts);

 // Per coefficient: zigzag -> magnitude class (band-context-adaptive), then the raw mantissa bits
 Band:=0;
 for Index:=0 to aLength-1 do begin
  while ((Band+1)<BandCount) and (Index>=Starts[Band+1]) do begin
   inc(Band);
  end;
  if Band<BandContexts then begin
   BandContext:=Band;
  end else begin
   BandContext:=BandContexts-1;
  end;
  Value:=ZigZag(aCoefficients^[Index]);
  Klass:=MagnitudeClass(Value);
  ClassContexts[BandContext].Encode(aCoder,Klass);
  if Klass>1 then begin
   Mantissa:=Value-(TpvUInt32(1) shl (Klass-1));
   aCoder.EncodeBypass(Mantissa,Klass-1);
  end;
 end;

 aCoder.FlushEncoder;

end;

procedure TpvFlexibleWaveletAudioEncoder.Encode(const aChannelBuffer:TAudioBuffers;const aSampleRate:TpvInt32;const aParams:TParams;const aStream:TStream);
var Channels,Channel,Quality,PairIndex,Mode,PairCount,BlockLength,Index,MaxDepth:TpvInt32;
    Frames,Start,Frame:TpvInt64;
    Pairing,JointStereo:boolean;
    Step:TpvFloat;
    HeaderFlags:TpvUInt16;
    Left,Right,Side:TpvInt32;
    Interleaved:array of TpvInt16;
    Planes:array of array of TpvInt32;
    BlockBuffer,Scratch:array of TpvInt32;
    FloatBlock,FloatScratch,StepPerCoeff:array of TpvFloat;
    Pairs:TPairArray;
    PairModes:array[0..MaxChannelPairs-1] of TpvInt32;
    Tree:TBitWriter;
    TreeByteLength,PayloadLength:TpvSizeUInt;
    Coder:TRangeCoder;
begin

 fStream:=aStream;
 fSynthesisGainReady:=false;

 Channels:=Length(aChannelBuffer);
 if Channels<1 then begin
  raise EpvFlexibleWaveletAudioEncoder.Create('No channels to encode');
 end;
 Frames:=Length(aChannelBuffer[0]);
 Quality:=aParams.Quality;

 // float -> interleaved int16 (the codec core works in the int16 domain, like the C ingest)
 SetLength(Interleaved,Frames*Channels);
 for Channel:=0 to Channels-1 do begin
  for Frame:=0 to Frames-1 do begin
   Interleaved[(Frame*Channels)+Channel]:=ClampInt16(Round(aChannelBuffer[Channel][Frame]*32768.0));
  end;
 end;

 // Per-channel decorrelation into int32 planes: stereo Mid/Side, or a plain deinterleave for mono / N
 SetLength(Planes,Channels);
 for Channel:=0 to Channels-1 do begin
  SetLength(Planes[Channel],Frames);
 end;
 if Channels=2 then begin
  for Frame:=0 to Frames-1 do begin
   Left:=Interleaved[(Frame*2)+0];
   Right:=Interleaved[(Frame*2)+1];
   Side:=Left-Right;
   Planes[0][Frame]:=Right+SARLongint(Side,1);
   Planes[1][Frame]:=Side;
  end;
 end else begin
  for Channel:=0 to Channels-1 do begin
   for Frame:=0 to Frames-1 do begin
    Planes[Channel][Frame]:=Interleaved[(Frame*Channels)+Channel];
   end;
  end;
 end;

 // Optional multichannel (>=3) pairwise Mid/Side, with the per-pair plan recorded for the decoder
 Pairing:=aParams.PairEnabled and (Channels>=3);
 PairCount:=0;
 if Pairing then begin
  PairCount:=GetPairs(Channels,Pairs);
  for PairIndex:=0 to PairCount-1 do begin
   if aParams.Adapt then begin
    Mode:=ord(MSPairBeneficial(PpvInt32Array(@Planes[Pairs[PairIndex,0]][0]),PpvInt32Array(@Planes[Pairs[PairIndex,1]][0]),Frames));
   end else begin
    Mode:=1;
   end;
   PairModes[PairIndex]:=Mode;
   if Mode<>0 then begin
    MSPairForward(PpvInt32Array(@Planes[Pairs[PairIndex,0]][0]),PpvInt32Array(@Planes[Pairs[PairIndex,1]][0]),Frames);
   end;
  end;
  Pairing:=PairCount>0;
 end;

 // Optional lossless LMS predictor (replaces the 5/3 wavelet at quality 0)
 if aParams.LMS and (Quality=0) then begin
  for Channel:=0 to Channels-1 do begin
   LMSForward(PpvInt32Array(@Planes[Channel][0]),Frames,aParams.LMSTaps);
  end;
 end;

 // Mode setup + per-block scratch
 if Quality>0 then begin
  Step:=Quality;
 end else begin
  Step:=1;
 end;
 JointStereo:=(Quality>0) and aParams.Joint and (not aParams.Packet) and (Channels=2);
 if aParams.Packet then begin
  MeasureSynthesisGain(BlockSamples);
 end;
 SetLength(BlockBuffer,BlockSamples);
 SetLength(Scratch,BlockSamples);
 SetLength(FloatBlock,BlockSamples);
 SetLength(FloatScratch,BlockSamples);
 SetLength(StepPerCoeff,BlockSamples);

 // Container header (24 bytes, little-endian) + the flag bits (LMS tap count lives in bits 8..15)
 HeaderFlags:=0;
 if aParams.Perceptual then begin
  HeaderFlags:=HeaderFlags or FlagPerceptual;
 end;
 if aParams.Packet then begin
  HeaderFlags:=HeaderFlags or FlagPacket;
 end;
 if JointStereo then begin
  HeaderFlags:=HeaderFlags or FlagJointStereo;
 end;
 if Pairing then begin
  HeaderFlags:=HeaderFlags or FlagPairing;
 end;
 if aParams.LMS and (Quality=0) then begin
  HeaderFlags:=HeaderFlags or FlagLMS or TpvUInt16((aParams.LMSTaps and $ff) shl 8);
 end;
 WriteU32(Magic);
 WriteU32(aSampleRate);
 WriteU16(Channels);
 WriteU16(BlockSamples);
 WriteU16(Quality);
 WriteU16(HeaderFlags);
 WriteU64(Frames);

 // The pairing plan: [u8 count] then per pair [u8 a][u8 b][u8 mode]
 if Pairing then begin
  WriteU8(PairCount);
  for PairIndex:=0 to PairCount-1 do begin
   WriteU8(Pairs[PairIndex,0]);
   WriteU8(Pairs[PairIndex,1]);
   WriteU8(PairModes[PairIndex]);
  end;
 end;

 // Encode every block of every channel
 Start:=0;
 while Start<Frames do begin
  if (Start+BlockSamples)<=Frames then begin
   BlockLength:=BlockSamples;
  end else begin
   BlockLength:=Frames-Start;
  end;
  for Channel:=0 to Channels-1 do begin

   TreeByteLength:=0;
   if Quality=0 then begin // lossless: 5/3 wavelet, or raw LMS residuals (already in the plane)
    Move(Planes[Channel][Start],BlockBuffer[0],BlockLength*SizeOf(TpvInt32));
    if not aParams.LMS then begin
     DWT53Forward(PpvInt32Array(@BlockBuffer[0]),PpvInt32Array(@Scratch[0]),BlockLength);
    end;
   end else if aParams.Packet then begin // lossy 9/7 wavelet-packet best basis (uniform / perceptual quant)
    for Index:=0 to BlockLength-1 do begin
     FloatBlock[Index]:=Planes[Channel][Start+Index];
    end;
    Tree.Init;
    MaxDepth:=DWTLevelCount(BlockLength);
    PacketDecompose(PpvFloatArray(@FloatBlock[0]),BlockLength,0,MaxDepth,Step,PpvFloatArray(@FloatScratch[0]),Tree);
    TreeByteLength:=Tree.ByteLength;
    ComputeSteps(BlockLength,Step,aParams.Perceptual,aSampleRate,PpvFloatArray(@StepPerCoeff[0]));
    QuantizeBlock(PpvFloatArray(@FloatBlock[0]),PpvInt32Array(@BlockBuffer[0]),BlockLength,PpvFloatArray(@StepPerCoeff[0]));
   end else begin // lossy 9/7 dyadic (uniform / perceptual quant, optional joint-stereo on the Side)
    for Index:=0 to BlockLength-1 do begin
     FloatBlock[Index]:=Planes[Channel][Start+Index];
    end;
    DWT97Forward(PpvFloatArray(@FloatBlock[0]),PpvFloatArray(@FloatScratch[0]),BlockLength);
    if JointStereo and (Channel=1) then begin
     JointStereoZeroSideHighs(PpvFloatArray(@FloatBlock[0]),BlockLength);
    end;
    ComputeSteps(BlockLength,Step,aParams.Perceptual,aSampleRate,PpvFloatArray(@StepPerCoeff[0]));
    QuantizeBlock(PpvFloatArray(@FloatBlock[0]),PpvInt32Array(@BlockBuffer[0]),BlockLength,PpvFloatArray(@StepPerCoeff[0]));
   end;

   // Entropy-code the coefficients, then emit [u32 payload_len]([u16 tree_len][tree])[coeff bytes]
   EncodeBlockCoeffs(PpvInt32Array(@BlockBuffer[0]),BlockLength,Coder);
   if aParams.Packet then begin
    PayloadLength:=(2+TreeByteLength)+Coder.Position;
   end else begin
    PayloadLength:=Coder.Position;
   end;
   WriteU32(TpvUInt32(PayloadLength));
   if aParams.Packet then begin
    WriteU16(TpvUInt16(TreeByteLength));
    if TreeByteLength>0 then begin
     fStream.WriteBuffer(Tree.Bytes[0],TreeByteLength);
    end;
   end;
   if Coder.Position>0 then begin
    fStream.WriteBuffer(Coder.Bytes^[0],Coder.Position);
   end;
   Coder.Done;

  end;
  inc(Start,BlockSamples);
 end;

end;

end.
