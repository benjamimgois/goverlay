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
unit PasVulkan.Audio.FlexibleWavelet.Decoder;
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

// Decoder for the Flexible Wavelet Audio (FWA) codec, the resource-system-independent engine-side reader
// of an FWA blob (the C "fwa" CLI / "FWAC" sub-codec output). It is decode-only and pure CPU: it parses
// the container header and the optional multichannel pairing plan, then per block runs the entropy decode
// + the inverse wavelet pipeline (reversible 5/3 or lossy 9/7 / wavelet-packet), undoes the LMS predictor
// and the Mid/Side decorrelation, and yields 32-bit float PCM.
//
// The caller owns the TStream passed to Create and must keep it alive at least as long as the decoder; the
// decoder reads (and seeks) from it on demand and never frees it. The shared DSP/entropy core lives in
// PasVulkan.Audio.FlexibleWavelet; this unit only adds the inverse paths and the container.
//
// Decoding is on-demand and non-look-ahead: Create only parses the header and scans the block framing into
// an offset index (no sample data is decoded). Decode/Seek then decode one 8192-sample block at a time as
// the play cursor reaches it. The block inverse transforms and the Mid/Side decorrelation are block-local,
// and the LMS predictor (lossless "lms" mode only) is carried forward across blocks; a Seek that is not the
// next forward block in LMS mode replays the predictor from the start (LMS is inherently sequential).
//
// Output forms: FullDecode -> planar float (one buffer per channel); Seek + Decode -> a pull feed of
// interleaved float frames.

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Utils,
     PasVulkan.Audio.FlexibleWavelet;

type EpvFlexibleWaveletAudioDecoder=class(EpvFlexibleWaveletAudio);

     { TpvFlexibleWaveletAudioDecoder }
     TpvFlexibleWaveletAudioDecoder=class(TpvFlexibleWaveletAudio)
      public
       type { TpvFlexibleWaveletAudioDecoder.TBitReader }
            TBitReader=record // MSB-first bit reader for the wavelet-packet preorder tree
             Bytes:PpvUInt8Array;
             BytePosition:TpvSizeUInt;
             BitPosition:TpvInt32;
             procedure Init(const aBytes:PpvUInt8Array);
             function GetBit:TpvInt32;
            end;
            TInt32Plane=array of TpvInt32;
            TInt32Planes=array of TInt32Plane;
            TLMSStates=array of TLMSState;
      private
       fStream:TStream;
       fHeader:THeader;
       fChannels:TpvInt32;
       fSampleRate:TpvInt32;
       fFrameCount:TpvInt64;
       fQuality:TpvInt32;
       fPerceptual:boolean;
       fPacket:boolean;
       fLMS:boolean;
       fLMSTaps:TpvInt32;
       fLMSAdaptShift:TpvInt32;
       fPairing:boolean;
       fPairCount:TpvInt32;
       fPairs:array[0..MaxChannelPairs-1,0..1] of TpvInt32;
       fPairModes:array[0..MaxChannelPairs-1] of TpvInt32;
       fBaseStep:TpvFloat;
       fDataStart:TpvInt64;
       fCursor:TpvInt64;
       fBlockCount:TpvInt32;
       fBlockOffsets:array of TpvInt64; // stream offset of each block's first channel payload
       fCurrentBlock:TpvInt32; // which block is currently held in fBlockInterleaved (-1 = none)
       fBlockFrames:TpvInt32;
       fBlockStartFrame:TpvInt64;
       fLMSNextBlock:TpvInt32; // block index for which fLMSStates are valid at its start
       fBlockInterleaved:array of TpvFloat; // current block's interleaved f32 (BlockSamples*channels)
       fBlockPlanes:TInt32Planes; // [channel] working plane (BlockSamples)
       fLMSStates:TLMSStates; // [channel] carried LMS predictor state
       fBlockBuffer:array of TpvInt32; // decode_block coefficient scratch
       fScratch:array of TpvInt32;
       fFloatBlock:array of TpvFloat;
       fFloatScratch:array of TpvFloat;
       fStepPerCoeff:array of TpvFloat;
       fPayload:array of TpvUInt8;
       function ReadU8:TpvUInt8;
       function ReadU16:TpvUInt16;
       function ReadU32:TpvUInt32;
       function ReadU64:TpvUInt64;
       procedure ParseHeader;
       procedure BuildBlockIndex;
       procedure DecodeBlockEntropy(const aBlock:PpvUInt8Array;const aBlockLength:TpvSizeUInt;const aLength:TpvInt32;const aCoefficients:PpvInt32Array);
       procedure PacketReconstruct(const aData:PpvFloatArray;const aOffset,aLength:TpvInt32;var aReader:TBitReader;const aScratch:PpvFloatArray);
       procedure DecodeBlock(const aBlockIndex:TpvInt32);
       procedure EnsureLMSStateAt(const aBlockIndex:TpvInt32);
       procedure EnsureBlock(const aBlockIndex:TpvInt32);
      public
       constructor Create(const aStream:TStream);
       destructor Destroy; override;
       procedure Seek(const aSamplePosition:TpvUInt64);
       function Decode(const aBuffer:Pointer;const aCount:TpvSizeInt):TpvSizeInt;
       procedure FullDecode(var aChannelBuffer:TAudioBuffers);
       property Channels:TpvInt32 read fChannels;
       property SampleRate:TpvInt32 read fSampleRate;
       property FrameCount:TpvInt64 read fFrameCount;
      end;

implementation

{ TpvFlexibleWaveletAudioDecoder.TBitReader }

procedure TpvFlexibleWaveletAudioDecoder.TBitReader.Init(const aBytes:PpvUInt8Array);
begin
 Bytes:=aBytes;
 BytePosition:=0;
 BitPosition:=0;
end;

function TpvFlexibleWaveletAudioDecoder.TBitReader.GetBit:TpvInt32;
begin
 result:=(Bytes^[BytePosition] shr (7-BitPosition)) and 1;
 inc(BitPosition);
 if BitPosition=8 then begin
  BitPosition:=0;
  inc(BytePosition);
 end;
end;

{ TpvFlexibleWaveletAudioDecoder }

function TpvFlexibleWaveletAudioDecoder.ReadU8:TpvUInt8;
begin
 fStream.ReadBuffer(result,SizeOf(TpvUInt8));
end;

function TpvFlexibleWaveletAudioDecoder.ReadU16:TpvUInt16;
var Bytes:array[0..1] of TpvUInt8;
begin
 fStream.ReadBuffer(Bytes[0],2);
 result:=TpvUInt16(Bytes[0]) or (TpvUInt16(Bytes[1]) shl 8);
end;

function TpvFlexibleWaveletAudioDecoder.ReadU32:TpvUInt32;
var Bytes:array[0..3] of TpvUInt8;
begin
 fStream.ReadBuffer(Bytes[0],4);
 result:=TpvUInt32(Bytes[0]) or (TpvUInt32(Bytes[1]) shl 8) or (TpvUInt32(Bytes[2]) shl 16) or (TpvUInt32(Bytes[3]) shl 24);
end;

function TpvFlexibleWaveletAudioDecoder.ReadU64:TpvUInt64;
var Low,High:TpvUInt32;
begin
 Low:=ReadU32;
 High:=ReadU32;
 result:=TpvUInt64(Low) or (TpvUInt64(High) shl 32);
end;

procedure TpvFlexibleWaveletAudioDecoder.ParseHeader;
var PairIndex:TpvInt32;
begin

 // The 24-byte container header (little-endian, byte-for-byte the C FwaHeader)
 fHeader.Magic:=ReadU32;
 fHeader.SampleRate:=ReadU32;
 fHeader.Channels:=ReadU16;
 fHeader.BlockSamples:=ReadU16;
 fHeader.Quality:=ReadU16;
 fHeader.Flags:=ReadU16;
 fHeader.FrameCount:=ReadU64;
 if fHeader.Magic<>Magic then begin
  raise EpvFlexibleWaveletAudioDecoder.Create('Not a FWA stream');
 end;

 // Derive the decode parameters from the header + its flag bits
 fSampleRate:=fHeader.SampleRate;
 fChannels:=fHeader.Channels;
 fFrameCount:=TpvInt64(fHeader.FrameCount);
 fQuality:=fHeader.Quality;
 fPerceptual:=(fHeader.Flags and FlagPerceptual)<>0;
 fPacket:=(fHeader.Flags and FlagPacket)<>0;
 fLMS:=(fHeader.Flags and FlagLMS)<>0;
 fLMSTaps:=(fHeader.Flags shr 8) and $ff;
 fPairing:=(fHeader.Flags and FlagPairing)<>0;
 if fQuality>0 then begin
  fBaseStep:=fQuality;
 end else begin
  fBaseStep:=1;
 end;

 // Optional multichannel pairing plan: [u8 count] then per pair [u8 a][u8 b][u8 mode]
 fPairCount:=0;
 if fPairing then begin
  fPairCount:=ReadU8;
  for PairIndex:=0 to fPairCount-1 do begin
   fPairs[PairIndex,0]:=ReadU8;
   fPairs[PairIndex,1]:=ReadU8;
   fPairModes[PairIndex]:=ReadU8;
  end;
 end;

 // The block payloads start right after the header (+ plan)
 fDataStart:=fStream.Position;

end;

procedure TpvFlexibleWaveletAudioDecoder.BuildBlockIndex;
var BlockIndex,Channel:TpvInt32;
    EncodedLength:TpvUInt32;
begin
 if fFrameCount>0 then begin
  fBlockCount:=(fFrameCount+(BlockSamples-1)) div BlockSamples;
 end else begin
  fBlockCount:=0;
 end;
 SetLength(fBlockOffsets,fBlockCount);
 fStream.Seek(fDataStart,soBeginning);
 for BlockIndex:=0 to fBlockCount-1 do begin
  fBlockOffsets[BlockIndex]:=fStream.Position;
  for Channel:=0 to fChannels-1 do begin
   EncodedLength:=ReadU32; // only the framing is read; payloads are skipped
   fStream.Seek(TpvInt64(EncodedLength),soCurrent);
  end;
 end;
end;

procedure TpvFlexibleWaveletAudioDecoder.DecodeBlockEntropy(const aBlock:PpvUInt8Array;const aBlockLength:TpvSizeUInt;const aLength:TpvInt32;const aCoefficients:PpvInt32Array);
var Coder:TRangeCoder;
    ClassContexts:array[0..BandContexts-1] of TClassContext;
    Starts:TBandStarts;
    BandCount,Band,BandContext,Index,Klass:TpvInt32;
    Value,Mantissa:TpvUInt32;
begin

 // One fresh range-coder stream per block, with per-band class contexts (reset per block)
 Coder.InitDecoder(aBlock,aBlockLength);
 FillChar(ClassContexts,SizeOf(ClassContexts),0); // silences the bogus "uninitialised" warning; Init sets the real values
 for Index:=0 to BandContexts-1 do begin
  ClassContexts[Index].Init;
 end;
 BandCount:=BandStarts(aLength,Starts);

 // Per coefficient: decode its magnitude class (band-context-adaptive), then the raw mantissa bits
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
  Klass:=ClassContexts[BandContext].Decode(Coder);
  if Klass=0 then begin
   Value:=0;
  end else if Klass=1 then begin
   Value:=1;
  end else begin
   Mantissa:=Coder.DecodeBypass(Klass-1);
   Value:=(TpvUInt32(1) shl (Klass-1))+Mantissa;
  end;
  aCoefficients^[Index]:=UnZigZag(Value);
 end;

 Coder.Done;

end;

procedure TpvFlexibleWaveletAudioDecoder.PacketReconstruct(const aData:PpvFloatArray;const aOffset,aLength:TpvInt32;var aReader:TBitReader;const aScratch:PpvFloatArray);
var Half:TpvInt32;
begin
 if aReader.GetBit=0 then begin
  exit; // leaf: coefficients already in place for this segment
 end;
 Half:=(aLength+1) div 2;
 PacketReconstruct(aData,aOffset,Half,aReader,aScratch);
 PacketReconstruct(aData,aOffset+Half,aLength-Half,aReader,aScratch);
 DWT97InverseLevel(PpvFloatArray(@aData^[aOffset]),aScratch,aLength); // combine children back
end;

procedure TpvFlexibleWaveletAudioDecoder.DecodeBlock(const aBlockIndex:TpvInt32);
var StartFrame:TpvInt64;
    BlockLength,Channel,Index,PairIndex,ChannelA,ChannelB:TpvInt32;
    Mid,Side,Right,Left,Residual,Sample:TpvInt32;
    EncodedLength,CoeffLength:TpvSizeUInt;
    TreeLength:TpvInt32;
    CoeffBytes,TreeBytes:PpvUInt8Array;
    Reader:TBitReader;
begin
 StartFrame:=TpvInt64(aBlockIndex)*BlockSamples;
 if (StartFrame+BlockSamples)<=fFrameCount then begin
  BlockLength:=BlockSamples;
 end else begin
  BlockLength:=fFrameCount-StartFrame;
 end;
 fStream.Seek(fBlockOffsets[aBlockIndex],soBeginning);

 // Decode every channel into its working plane (post-transform samples, or LMS residuals for the lms mode)
 for Channel:=0 to fChannels-1 do begin

  // Read this channel's length-prefixed payload, splitting off the packet tree if present
  EncodedLength:=ReadU32;
  if TpvSizeUInt(Length(fPayload))<EncodedLength then begin
   SetLength(fPayload,EncodedLength);
  end;
  if EncodedLength>0 then begin
   fStream.ReadBuffer(fPayload[0],EncodedLength);
  end;
  if fPacket then begin // payload = [u16 tree_byte_len][tree][coeff bytes]
   TreeLength:=TpvInt32(fPayload[0]) or (TpvInt32(fPayload[1]) shl 8);
   TreeBytes:=PpvUInt8Array(@fPayload[2]);
   CoeffBytes:=PpvUInt8Array(@fPayload[2+TreeLength]);
   CoeffLength:=EncodedLength-(2+TpvSizeUInt(TreeLength));
  end else begin
   TreeBytes:=nil;
   CoeffBytes:=PpvUInt8Array(@fPayload[0]);
   CoeffLength:=EncodedLength;
  end;

  // Entropy-decode the coefficients, then apply the matching inverse transform
  DecodeBlockEntropy(CoeffBytes,CoeffLength,BlockLength,PpvInt32Array(@fBlockBuffer[0]));
  if fQuality=0 then begin // lossless: 5/3 wavelet OR LMS residuals (un-predicted below)
   if not fLMS then begin
    DWT53Inverse(PpvInt32Array(@fBlockBuffer[0]),PpvInt32Array(@fScratch[0]),BlockLength);
   end;
   Move(fBlockBuffer[0],fBlockPlanes[Channel][0],BlockLength*SizeOf(TpvInt32));
  end else if fPacket then begin // lossy 9/7 wavelet-packet: dequantize -> reconstruct -> round
   ComputeSteps(BlockLength,fBaseStep,fPerceptual,fSampleRate,PpvFloatArray(@fStepPerCoeff[0]));
   DequantizeBlock(PpvInt32Array(@fBlockBuffer[0]),PpvFloatArray(@fFloatBlock[0]),BlockLength,PpvFloatArray(@fStepPerCoeff[0]));
   Reader.Init(TreeBytes);
   PacketReconstruct(PpvFloatArray(@fFloatBlock[0]),0,BlockLength,Reader,PpvFloatArray(@fFloatScratch[0]));
   for Index:=0 to BlockLength-1 do begin
    fBlockPlanes[Channel][Index]:=Round(fFloatBlock[Index]);
   end;
  end else begin // lossy 9/7 dyadic: dequantize -> inverse -> round
   ComputeSteps(BlockLength,fBaseStep,fPerceptual,fSampleRate,PpvFloatArray(@fStepPerCoeff[0]));
   DequantizeBlock(PpvInt32Array(@fBlockBuffer[0]),PpvFloatArray(@fFloatBlock[0]),BlockLength,PpvFloatArray(@fStepPerCoeff[0]));
   DWT97Inverse(PpvFloatArray(@fFloatBlock[0]),PpvFloatArray(@fFloatScratch[0]),BlockLength);
   for Index:=0 to BlockLength-1 do begin
    fBlockPlanes[Channel][Index]:=Round(fFloatBlock[Index]);
   end;
  end;
 end;

 // Undo the LMS prediction (lossless lms mode), carrying each channel's predictor state across blocks
 if fLMS and (fQuality=0) then begin
  for Channel:=0 to fChannels-1 do begin
   for Index:=0 to BlockLength-1 do begin
    Residual:=fBlockPlanes[Channel][Index];
    Sample:=Residual+fLMSStates[Channel].Predict(fLMSTaps);
    fBlockPlanes[Channel][Index]:=Sample;
    fLMSStates[Channel].Update(fLMSTaps,fLMSAdaptShift,Sample,Residual);
   end;
  end;
  fLMSNextBlock:=aBlockIndex+1;
 end;

 // Undo the multichannel pairwise M/S (per-sample, block-local)
 for PairIndex:=0 to fPairCount-1 do begin
  if fPairModes[PairIndex]<>0 then begin
   ChannelA:=fPairs[PairIndex,0];
   ChannelB:=fPairs[PairIndex,1];
   for Index:=0 to BlockLength-1 do begin
    Mid:=fBlockPlanes[ChannelA][Index];
    Side:=fBlockPlanes[ChannelB][Index];
    Right:=Mid-SARLongint(Side,1);
    fBlockPlanes[ChannelA][Index]:=Right+Side;
    fBlockPlanes[ChannelB][Index]:=Right;
   end;
  end;
 end;

 // Stereo Mid/Side inverse (or a plain per-channel copy), folding the int16 clamp into the f32 normalise
 if fChannels=2 then begin
  for Index:=0 to BlockLength-1 do begin
   Mid:=fBlockPlanes[0][Index];
   Side:=fBlockPlanes[1][Index];
   Right:=Mid-SARLongint(Side,1);
   Left:=Right+Side;
   fBlockInterleaved[(Index*2)+0]:=ClampInt16(Left)/32768.0;
   fBlockInterleaved[(Index*2)+1]:=ClampInt16(Right)/32768.0;
  end;
 end else begin
  for Channel:=0 to fChannels-1 do begin
   for Index:=0 to BlockLength-1 do begin
    fBlockInterleaved[(Index*fChannels)+Channel]:=ClampInt16(fBlockPlanes[Channel][Index])/32768.0;
   end;
  end;
 end;

 // Publish this block as the current one
 fBlockFrames:=BlockLength;
 fBlockStartFrame:=StartFrame;
 fCurrentBlock:=aBlockIndex;

end;

procedure TpvFlexibleWaveletAudioDecoder.EnsureLMSStateAt(const aBlockIndex:TpvInt32);
var Channel:TpvInt32;
begin
 if not (fLMS and (fQuality=0)) then begin
  exit; // only the lossless LMS mode carries cross-block predictor state
 end;
 if fLMSNextBlock=aBlockIndex then begin
  exit; // already positioned at the start of the requested block
 end;
 if fLMSNextBlock>aBlockIndex then begin // seeking backwards -> rebuild from the very start
  for Channel:=0 to fChannels-1 do begin
   fLMSStates[Channel].Init(fLMSTaps);
  end;
  fLMSNextBlock:=0;
  fCurrentBlock:=-1;
 end;
 while fLMSNextBlock<aBlockIndex do begin // replay forward, advancing the predictor (output is discarded)
  DecodeBlock(fLMSNextBlock);
 end;
end;

procedure TpvFlexibleWaveletAudioDecoder.EnsureBlock(const aBlockIndex:TpvInt32);
begin
 if aBlockIndex=fCurrentBlock then begin
  exit;
 end;
 EnsureLMSStateAt(aBlockIndex);
 DecodeBlock(aBlockIndex);
end;

constructor TpvFlexibleWaveletAudioDecoder.Create(const aStream:TStream);
var Channel:TpvInt32;
begin
 inherited Create;

 // Reference the caller-owned stream and parse the container header
 fStream:=aStream;
 fCursor:=0;
 ParseHeader;

 // One-time per-block scratch buffers (reused for every block)
 SetLength(fBlockBuffer,BlockSamples);
 SetLength(fScratch,BlockSamples);
 SetLength(fFloatBlock,BlockSamples);
 SetLength(fFloatScratch,BlockSamples);
 SetLength(fStepPerCoeff,BlockSamples);
 SetLength(fPayload,BlockSamples*4);
 SetLength(fBlockInterleaved,BlockSamples*Max(fChannels,1));

 // Per-channel working planes and carried LMS state
 SetLength(fBlockPlanes,fChannels);
 SetLength(fLMSStates,fChannels);
 for Channel:=0 to fChannels-1 do begin
  SetLength(fBlockPlanes[Channel],BlockSamples);
  fLMSStates[Channel].Init(fLMSTaps);
 end;
 fLMSAdaptShift:=LMSAdaptShift(fLMSTaps);

 // Nothing decoded yet; scan the block framing into the offset index
 fLMSNextBlock:=0;
 fCurrentBlock:=-1;
 BuildBlockIndex;

end;

destructor TpvFlexibleWaveletAudioDecoder.Destroy;
begin
 fBlockOffsets:=nil; // managed; never frees fStream (caller owns it)
 fBlockInterleaved:=nil;
 fBlockPlanes:=nil;
 fLMSStates:=nil;
 fBlockBuffer:=nil;
 fScratch:=nil;
 fFloatBlock:=nil;
 fFloatScratch:=nil;
 fStepPerCoeff:=nil;
 fPayload:=nil;
 inherited Destroy;
end;

procedure TpvFlexibleWaveletAudioDecoder.Seek(const aSamplePosition:TpvUInt64);
begin
 if aSamplePosition>TpvUInt64(fFrameCount) then begin
  fCursor:=fFrameCount;
 end else begin
  fCursor:=TpvInt64(aSamplePosition);
 end;
end;

function TpvFlexibleWaveletAudioDecoder.Decode(const aBuffer:Pointer;const aCount:TpvSizeInt):TpvSizeInt;
var Destination:PpvFloatArray;
    Produced,Count:TpvSizeInt;
    BlockIndex:TpvInt32;
    OffsetInBlock,Available:TpvInt64;
begin
 Destination:=PpvFloatArray(aBuffer);
 Produced:=0;
 while (Produced<aCount) and (fCursor<fFrameCount) do begin
  BlockIndex:=fCursor div BlockSamples;
  EnsureBlock(BlockIndex);
  OffsetInBlock:=fCursor-fBlockStartFrame;
  Available:=fBlockFrames-OffsetInBlock;
  Count:=aCount-Produced;
  if Count>Available then begin
   Count:=Available;
  end;
  Move(fBlockInterleaved[OffsetInBlock*fChannels],Destination^[Produced*fChannels],(TpvSizeUInt(Count)*TpvSizeUInt(fChannels))*SizeOf(TpvFloat));
  inc(fCursor,Count);
  inc(Produced,Count);
 end;
 result:=Produced;
end;

procedure TpvFlexibleWaveletAudioDecoder.FullDecode(var aChannelBuffer:TAudioBuffers);
var Channel,BlockIndex:TpvInt32;
    Frame,Index:TpvInt64;
begin
 SetLength(aChannelBuffer,fChannels);
 for Channel:=0 to fChannels-1 do begin
  SetLength(aChannelBuffer[Channel],fFrameCount);
 end;
 Seek(0);
 Frame:=0;
 while Frame<fFrameCount do begin
  BlockIndex:=Frame div BlockSamples;
  EnsureBlock(BlockIndex);
  for Index:=0 to fBlockFrames-1 do begin
   for Channel:=0 to fChannels-1 do begin
    aChannelBuffer[Channel][fBlockStartFrame+Index]:=fBlockInterleaved[(Index*fChannels)+Channel];
   end;
  end;
  Frame:=fBlockStartFrame+fBlockFrames;
 end;
end;

end.
