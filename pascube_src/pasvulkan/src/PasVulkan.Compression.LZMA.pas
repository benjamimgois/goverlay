unit PasVulkan.Compression.LZMA;
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

{$ifdef fpc}
 {$optimization off}
 {$optimization level1}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Math,
     PasVulkan.Types;

// The old good LZMA, but it is slow, but it compresses very well. It should be used for data, where
// the compression ratio is more important than the decompression speed.

const kNumRepDistances=4;
      kNumStates=12;
      kNumPosSlotBits=6;
      kDicLogSizeMin=0;
//    kDicLogSizeMax=28;
//    kDistTableSizeMax=kDicLogSizeMax*2;

      kNumLenToPosStatesBits=2; // it's for speed optimization
      kNumLenToPosStates=1 shl kNumLenToPosStatesBits;

      kMatchMinLen=2;

      kNumAlignBits=4;
      kAlignTableSize=1 shl kNumAlignBits;
      kAlignMask=(kAlignTableSize-1);

      kStartPosModelIndex=4;
      kEndPosModelIndex=14;
      kNumPosModels=kEndPosModelIndex-kStartPosModelIndex;

      kNumFullDistances=1 shl (kEndPosModelIndex div 2);

      kNumLitPosStatesBitsEncodingMax=4;
      kNumLitContextBitsMax=8;

      kNumPosStatesBitsMax=4;
      kNumPosStatesMax=1 shl kNumPosStatesBitsMax;
      kNumPosStatesBitsEncodingMax=4;
      kNumPosStatesEncodingMax=1 shl kNumPosStatesBitsEncodingMax;

      kNumLowLenBits=3;
      kNumMidLenBits=3;
      kNumHighLenBits=8;
      kNumLowLenSymbols=1 shl kNumLowLenBits;
      kNumMidLenSymbols=1 shl kNumMidLenBits;
      kNumLenSymbols=kNumLowLenSymbols+kNumMidLenSymbols+(1 shl kNumHighLenBits);
      kMatchMaxLen=kMatchMinLen+kNumLenSymbols-1;

      kHash2Size=1 shl 10;
      kHash3Size=1 shl 16;
      kBT2HashSize=1 shl 16;
      kStartMaxLen=1;
      kHash3Offset=kHash2Size;
      kEmptyHashValue=0;
      kMaxValForNormalize=(1 shl 30)-1;

      kNumBitPriceShiftBits=6;
      kTopMask=not ((1 shl 24)-1);
      kNumBitModelTotalBits=11;
      kBitModelTotal=1 shl kNumBitModelTotalBits;
      kNumMoveBits=5;
      kNumMoveReducingBits=2;

      EMatchFinderTypeBT2=0;
      EMatchFinderTypeBT4=1;
      kIfinityPrice:TpvInt32=$fffffff;
      kDefaultDictionaryLogSize=22;
      kNumFastBytesDefault=$20;
      kNumLenSpecSymbols=kNumLowLenSymbols+kNumMidLenSymbols;
      kNumOpts=1 shl 12;
      kPropSize=5;

      CodeProgressInterval=50;

      BufferSize=$10000;

type TLZMAProgressAction=(LPAMax,LPAPos);
     TLZMAProgress=procedure(const Action:TLZMAProgressAction;const Value:TpvInt64) of object;

     psmallints=^smallints;
     smallints=array[0..65535] of TpvInt16;

     TCRC=class
      public
       Value:TpvUInt32;
       constructor Create;
       destructor Destroy; override;
       procedure Init;
       procedure Update(const Data:array of TpvUInt8;const Offset,Size:TpvInt32); overload;
       procedure Update(const Data:array of TpvUInt8); overload;
       procedure UpdateByte(const b:TpvUInt32);
       function GetDigest:TpvInt32;
     end;

     TLZInWindow=class
      public
       bufferBase:array of TpvUInt8;
       Stream:TStream;
       posLimit:TpvInt32;
       streamEndWasReached:boolean;
       pointerToLastSafePosition:TpvInt32;
       bufferOffset:TpvInt32;
       blockSize:TpvInt32;
       pos:TpvInt32;
       keepSizeBefore:TpvInt32;
       keepSizeAfter:TpvInt32;
       streamPos:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       procedure MoveBlock;
       procedure ReadBlock;
       procedure _Free;
       procedure _Create(const aKeepSizeBefore,aKeepSizeAfter,aKeepSizeReserv:TpvInt32); virtual;
       procedure SetStream(const AStream:TStream);
       procedure ReleaseStream;
       procedure Init; virtual;
       procedure MovePos; virtual;
       function GetIndexByte(const index:TpvInt32):TpvUInt8;
       function GetMatchLen(const index:TpvInt32;distance,limit:TpvInt32):TpvInt32;
       function GetNumAvailableBytes:TpvInt32;
       procedure ReduceOffsets(const subValue:TpvInt32);
     end;

     TLZOutWindow=class
      public
       buffer:array of TpvUInt8;
       pos:TpvInt32;
       windowSize:TpvInt32;
       streamPos:TpvInt32;
       Stream:TStream;
       constructor Create;
       destructor Destroy; override;
       procedure _Create(const aWindowSize:TpvInt32);
       procedure SetStream(const AStream:TStream);
       procedure ReleaseStream;
       procedure Init(const solid:boolean);
       procedure Flush;
       procedure CopyBlock(const distance:TpvInt32;len:TpvInt32);
       procedure PutByte(const b:TpvUInt8);
       function GetByte(const distance:TpvInt32):TpvUInt8;
     end;

     TLZBinTree=class(TLZInWindow)
      public
       cyclicBufferPos:TpvInt32;
       cyclicBufferSize:TpvInt32;
       matchMaxLen:TpvInt32;
       son:array of TpvInt32;
       hash:array of TpvInt32;
       cutValue:TpvInt32;
       hashMask:TpvInt32;
       hashSizeSum:TpvInt32;
       HASH_ARRAY:boolean;
       kNumHashDirectBytes:TpvInt32;
       kMinMatchCheck:TpvInt32;
       kFixHashSize:TpvInt32;
       constructor Create;
       procedure SetType(const numHashBytes:TpvInt32);
       procedure Init; override;
       procedure MovePos; override;
       function _Create(const aHistorySize,aKeepAddBufferBefore,aMatchMaxLen,aKeepAddBufferAfter:TpvInt32):boolean; reintroduce;
       function GetMatches(var distances:array of TpvInt32):TpvInt32;
       procedure Skip(num:TpvInt32);
       procedure NormalizeLinks(var items:array of TpvInt32;const numItems,subValue:TpvInt32);
       procedure Normalize;
       procedure SetCutValue(const cutValue:TpvInt32);
     end;

     TRangeDecoder=class
      public
       Range,Code:TpvInt32;
       Stream:TStream;
       procedure SetStream(const AStream:TStream);
       procedure ReleaseStream;
       procedure Init;
       function DecodeDirectBits(const numTotalBits:TpvInt32):TpvInt32;
       function DecodeBit(probs:psmallints;const index:TpvInt32):TpvInt32;
     end;

     TRangeEncoder=class
      private
       ProbPrices:array[0..kBitModelTotal shr kNumMoveReducingBits-1] of TpvInt32;
      public
       Stream:TStream;
       Low,Position:TpvInt64;
       Range,cacheSize,cache:TpvInt32;
       procedure SetStream(const AStream:TStream);
       procedure ReleaseStream;
       procedure Init;
       procedure FlushData;
       procedure FlushStream;
       procedure ShiftLow;
       procedure EncodeDirectBits(const v,numTotalBits:TpvInt32);
       function GetProcessedSizeAdd:TpvInt64;
       procedure Encode(var probs:array of TpvInt16;const index,symbol:TpvInt32);
       constructor Create;
       function GetPrice(const Prob,symbol:TpvInt32):TpvInt32;
       function GetPrice0(const Prob:TpvInt32):TpvInt32;
       function GetPrice1(const Prob:TpvInt32):TpvInt32;
     end;

     TBitTreeDecoder=class
      public
       Models:array of TpvInt16;
       NumBitLevels:TpvInt32;
       constructor Create(const aNumBitLevels:TpvInt32);
       procedure Init;
       function Decode(const rangeDecoder:TRangeDecoder):TpvInt32;
       function ReverseDecode(const rangeDecoder:TRangeDecoder):TpvInt32; overload;
     end;

     TBitTreeEncoder=class
      public
       Models:array of TpvInt16;
       NumBitLevels:TpvInt32;
       constructor Create(const aNumBitLevels:TpvInt32);
       procedure Init;
       procedure Encode(const rangeEncoder:TRangeEncoder;const symbol:TpvInt32);
       procedure ReverseEncode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32);
       function GetPrice(const symbol:TpvInt32):TpvInt32;
       function ReverseGetPrice(symbol:TpvInt32):TpvInt32; overload;
     end;

     TLZMALenDecoder=class;
     TLZMALiteralDecoder=class;

     TLZMADecoder=class
      private
       fOnProgress:TLZMAProgress;
       procedure DoProgress(const Action:TLZMAProgressAction;const Value:TpvInt64);
      public
       m_OutWindow:TLZOutWindow;
       m_RangeDecoder:TRangeDecoder;
       m_IsMatchDecoders:array[0..kNumStates shl kNumPosStatesBitsMax-1] of TpvInt16;
       m_IsRepDecoders:array[0..kNumStates-1] of TpvInt16;
       m_IsRepG0Decoders:array[0..kNumStates-1] of TpvInt16;
       m_IsRepG1Decoders:array[0..kNumStates-1] of TpvInt16;
       m_IsRepG2Decoders:array[0..kNumStates-1] of TpvInt16;
       m_IsRep0LongDecoders:array[0..kNumStates shl kNumPosStatesBitsMax-1] of TpvInt16;
       m_PosSlotDecoder:array[0..kNumLenToPosStates-1] of TBitTreeDecoder;
       m_PosDecoders:array[0..kNumFullDistances-kEndPosModelIndex-1] of TpvInt16;
       m_PosAlignDecoder:TBitTreeDecoder;
       m_LenDecoder:TLZMALenDecoder;
       m_RepLenDecoder:TLZMALenDecoder;
       m_LiteralDecoder:TLZMALiteralDecoder;
       m_DictionarySize:TpvInt32;
       m_DictionarySizeCheck:TpvInt32;
       m_PosStateMask:TpvInt32;       
       constructor Create;
       destructor Destroy; override;
       function SetDictionarySize(const dictionarySize:TpvInt32):boolean;
       function SetLcLpPb(const lc,lp,pb:TpvInt32):boolean;
       procedure Init;
       function Code(const inStream,outStream:TStream;outSize:TpvInt64):boolean;
       function SetDecoderProperties(const properties:array of TpvUInt8):boolean;
       property OnProgress:TLZMAProgress read fOnProgress write fOnProgress;
     end;

     TLZMALenDecoder=class
      public
       m_Choice:array[0..1] of TpvInt16;
       m_LowCoder:array[0..kNumPosStatesMax-1] of TBitTreeDecoder;
       m_MidCoder:array[0..kNumPosStatesMax-1] of TBitTreeDecoder;
       m_HighCoder:TBitTreeDecoder;
       m_NumPosStates:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       procedure _Create(const numPosStates:TpvInt32);
       procedure Init;
       function Decode(const rangeDecoder:TRangeDecoder;const posState:TpvInt32):TpvInt32;
     end;

     TLZMADecoder2=class
      public
       m_Decoders:array[0..$300-1] of TpvInt16;
       procedure Init;
       function DecodeNormal(const rangeDecoder:TRangeDecoder):TpvUInt8;
       function DecodeWithMatchByte(const rangeDecoder:TRangeDecoder;matchByte:TpvUInt8):TpvUInt8;
     end;

     TLZMALiteralDecoder=class
      public
       m_Coders:array of TLZMADecoder2;
       m_NumPrevBits:TpvInt32;
       m_NumPosBits:TpvInt32;
       m_PosMask:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       procedure _Create(const numPosBits,numPrevBits:TpvInt32);
       procedure Init;
       function GetDecoder(const pos:TpvInt32;const prevByte:TpvUInt8):TLZMADecoder2;
     end;

     TLZMAEncoder2=class;
     TLZMALiteralEncoder=class;
     TLZMAOptimal=class;
     TLZMALenPriceTableEncoder=class;

     TLZMAEncoder=class
      private
       fOnProgress:TLZMAProgress;
       procedure DoProgress(const Action:TLZMAProgressAction;const Value:TpvInt64);
      public
       g_FastPos:array[0..(1 shl 11)-1] of TpvUInt8;
       _state:TpvInt32;
       _previousByte:TpvUInt8;
       _repDistances:array[0..kNumRepDistances-1] of TpvInt32;
       _optimum:array[0..kNumOpts-1] of TLZMAOptimal;
       _matchFinder:TLZBinTree;
       _rangeEncoder:TRangeEncoder;
       _isMatch:array[0..(kNumStates shl kNumPosStatesBitsMax)-1] of TpvInt16;
       _isRep:array[0..kNumStates-1] of TpvInt16;
       _isRepG0:array[0..kNumStates-1] of TpvInt16;
       _isRepG1:array[0..kNumStates-1] of TpvInt16;
       _isRepG2:array[0..kNumStates-1] of TpvInt16;
       _isRep0Long:array[0..kNumStates shl kNumPosStatesBitsMax-1] of TpvInt16;
       _posSlotEncoder:array[0..kNumLenToPosStates-1] of TBitTreeEncoder;// kNumPosSlotBits
       _posEncoders:array[0..kNumFullDistances-kEndPosModelIndex-1] of TpvInt16;
       _posAlignEncoder:TBitTreeEncoder;
       _lenEncoder:TLZMALenPriceTableEncoder;
       _repMatchLenEncoder:TLZMALenPriceTableEncoder;
       _literalEncoder:TLZMALiteralEncoder;
       _matchDistances:array[0..(kMatchMaxLen*2)+1] of TpvInt32;
       _numFastBytes:TpvInt32;
       _longestMatchLength:TpvInt32;
       _numDistancePairs:TpvInt32;
       _additionalOffset:TpvInt32;
       _optimumEndIndex:TpvInt32;
       _optimumCurrentIndex:TpvInt32;
       _longestMatchWasFound:boolean;
       _posSlotPrices:array[0..1 shl (kNumPosSlotBits+kNumLenToPosStatesBits)-1] of TpvInt32;
       _distancesPrices:array[0..(kNumFullDistances shl kNumLenToPosStatesBits)-1] of TpvInt32;
       _alignPrices:array[0..kAlignTableSize-1] of TpvInt32;
       _alignPriceCount:TpvInt32;
       _distTableSize:TpvInt32;
       _posStateBits:TpvInt32;
       _posStateMask:TpvInt32;
       _numLiteralPosStateBits:TpvInt32;
       _numLiteralContextBits:TpvInt32;
       _dictionarySize:TpvInt32;
       _dictionarySizePrev:TpvInt32;
       _numFastBytesPrev:TpvInt32;
       nowPos64:TpvInt64;
       _finished:boolean;
       _inStream:TStream;
       _matchFinderType:TpvInt32;
       _writeEndMark:boolean;
       _needReleaseMFStream:boolean;
       reps:array[0..kNumRepDistances-1] of TpvInt32;
       repLens:array[0..kNumRepDistances-1] of TpvInt32;
       backRes:TpvInt32;
       processedInSize:TpvInt64;
       processedOutSize:TpvInt64;
       finished:boolean;
       properties:array[0..kPropSize] of TpvUInt8;
       tempPrices:array[0..kNumFullDistances-1] of TpvInt32;
       _matchPriceCount:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       function GetPosSlot(const pos:TpvInt32):TpvInt32;
       function GetPosSlot2(const pos:TpvInt32):TpvInt32;
       procedure BaseInit;
       procedure _Create;
       procedure SetWriteEndMarkerMode(const writeEndMarker:boolean);
       procedure Init;
       function ReadMatchDistances:TpvInt32;
       procedure MovePos(const num:TpvInt32);
       function GetRepLen1Price(const state,posState:TpvInt32):TpvInt32;
       function GetPureRepPrice(const repIndex,state,posState:TpvInt32):TpvInt32;
       function GetRepPrice(const repIndex,len,state,posState:TpvInt32):TpvInt32;
       function GetPosLenPrice(const pos,len,posState:TpvInt32):TpvInt32;
       function Backward(cur:TpvInt32):TpvInt32;
       function GetOptimum(position:TpvInt32):TpvInt32;
       function ChangePair(const smallDist,bigDist:TpvInt32):boolean;
       procedure WriteEndMarker(const posState:TpvInt32);
       procedure Flush(const nowPos:TpvInt32);
       procedure ReleaseMFStream;
       procedure CodeOneBlock(var inSize,outSize:TpvInt64;var finished:boolean);
       procedure FillDistancesPrices;
       procedure FillAlignPrices;
       procedure SetOutStream(const outStream:TStream);
       procedure ReleaseOutStream;
       procedure ReleaseStreams;
       procedure SetStreams(const inStream,outStream:TStream;const inSize,outSize:TpvInt64);
       procedure Code(const inStream,outStream:TStream;const inSize,outSize:TpvInt64);
       procedure WriteCoderProperties(const outStream:TStream);
       function SetAlgorithm(const algorithm:TpvInt32):boolean;
       function SetDictionarySize(dictionarySize:TpvInt32):boolean;
       function SetNumFastBytes(const numFastBytes:TpvInt32):boolean;
       function SetMatchFinder(const matchFinderIndex:TpvInt32):boolean;
       function SetLcLpPb(const lc,lp,pb:TpvInt32):boolean;
       procedure SetEndMarkerMode(const endMarkerMode:boolean);
       property OnProgress:TLZMAProgress read fOnProgress write fOnProgress;
     end;

     TLZMALiteralEncoder=class
      public
       m_Coders:array of TLZMAEncoder2;
       m_NumPrevBits:TpvInt32;
       m_NumPosBits:TpvInt32;
       m_PosMask:TpvInt32;
       procedure _Create(const numPosBits,numPrevBits:TpvInt32);
       destructor Destroy; override;
       procedure Init;
       function GetSubCoder(const pos:TpvInt32;const prevByte:TpvUInt8):TLZMAEncoder2;
     end;

     TLZMAEncoder2=class
      public
       m_Encoders:array[0..$300-1] of TpvInt16;
       procedure Init;
       procedure Encode(const rangeEncoder:TRangeEncoder;const symbol:TpvUInt8);
       procedure EncodeMatched(const rangeEncoder:TRangeEncoder;const matchByte,symbol:TpvUInt8);
       function GetPrice(const matchMode:boolean;const matchByte,symbol:TpvUInt8):TpvInt32;
     end;

     TLZMALenEncoder=class
      public
       _choice:array[0..1] of TpvInt16;
       _lowCoder:array[0..kNumPosStatesEncodingMax-1] of TBitTreeEncoder;
       _midCoder:array[0..kNumPosStatesEncodingMax-1] of TBitTreeEncoder;
       _highCoder:TBitTreeEncoder;
       constructor Create;
       destructor Destroy; override;
       procedure Init(const numPosStates:TpvInt32);
       procedure Encode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32;const posState:TpvInt32); virtual;
       procedure SetPrices(const posState,numSymbols:TpvInt32;var prices:array of TpvInt32;const st:TpvInt32);
     end;

     TLZMALenPriceTableEncoder=class(TLZMALenEncoder)
      public
       _prices:array[0..kNumLenSymbols shl kNumPosStatesBitsEncodingMax-1] of TpvInt32;
       _tableSize:TpvInt32;
       _counters:array[0..kNumPosStatesEncodingMax-1] of TpvInt32;
       procedure SetTableSize(const tableSize:TpvInt32);
       function GetPrice(const symbol,posState:TpvInt32):TpvInt32;
       procedure UpdateTable(const posState:TpvInt32);
       procedure UpdateTables(const numPosStates:TpvInt32);
       procedure Encode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32;const posState:TpvInt32); override;
     end;

     TLZMAOptimal=class
      public
       State:TpvInt32;

       Prev1IsChar:boolean;
       Prev2:boolean;

       PosPrev2:TpvInt32;
       BackPrev2:TpvInt32;

       Price:TpvInt32;
       PosPrev:TpvInt32;
       BackPrev:TpvInt32;

       Backs0:TpvInt32;
       Backs1:TpvInt32;
       Backs2:TpvInt32;
       Backs3:TpvInt32;

       procedure MakeAsChar;
       procedure MakeAsShortRep;
       function IsShortRep:boolean;
     end;

var RangeEncoder:TRangeEncoder;

function ReadByte(const Stream:TStream):TpvUInt8;
procedure WriteByte(const Stream:TStream;const b:TpvUInt8);

procedure InitBitModels(var probs:array of TpvInt16);

function ReverseDecode(Models:psmallints;const startIndex:TpvInt32;const rangeDecoder:TRangeDecoder;const NumBitLevels:TpvInt32):TpvInt32; overload;

procedure ReverseEncode(var Models:array of TpvInt16;const startIndex:TpvInt32;const rangeEncoder:TRangeEncoder;const NumBitLevels:TpvInt32;symbol:TpvInt32);
function ReverseGetPrice(var Models:array of TpvInt16;const startIndex,NumBitLevels:TpvInt32;symbol:TpvInt32):TpvInt32;

type TpvLZMALevel=0..9;
     PpvLZMALevel=^TpvLZMALevel;

function LZMACompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZMALevel=0;const aWithSize:boolean=true):boolean;

function LZMADecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64=-1;const aWithSize:boolean=true):boolean;

function LZMACompressStream(const aInStream,aOutStream:TStream;const aLevel:TpvLZMALevel):Boolean;

function LZMADecompressStream(const aInStream,aOutStream:TStream):Boolean;

implementation

var CRCTable:array[0..255] of TpvUInt32;

function ReadByte(const Stream:TStream):TpvUInt8;
begin
 Stream.Read(result,SizeOf(TpvUInt8));
end;

procedure WriteByte(const Stream:TStream;const b:TpvUInt8);
begin
 Stream.Write(b,SizeOf(TpvUInt8));
end;

procedure InitBitModels(var probs:array of TpvInt16);
var i:TpvInt32;
begin
 for i:=0 to length(probs)-1 do begin
  probs[i]:=kBitModelTotal shr 1;
 end;
end;

function ReverseDecode(Models:psmallints;const startIndex:TpvInt32;const rangeDecoder:TRangeDecoder;const NumBitLevels:TpvInt32):TpvInt32;
var m,symbol,bitindex,bit:TpvInt32;
begin
 m:=1;
 symbol:=0;
 for bitindex:=0 to numbitlevels-1 do begin
  bit:=rangeDecoder.DecodeBit(Models,startIndex+m);
  m:=(m shl 1)+bit;
  symbol:=symbol or bit shl bitindex;
 end;
 result:=symbol;
end;

function ReverseGetPrice(var Models:array of TpvInt16;const startIndex,NumBitLevels:TpvInt32;symbol:TpvInt32):TpvInt32;
var price,m,i,bit:TpvInt32;
begin
 price:=0;
 m:=1;
 for i:=NumBitLevels downto 1 do begin
  bit:=symbol and 1;
  symbol:=symbol shr 1;
  price:=price+RangeEncoder.GetPrice(Models[startIndex+m],bit);
  m:=(m shl 1) or bit;
 end;
 result:=price;
end;

procedure ReverseEncode(var Models:array of TpvInt16;const startIndex:TpvInt32;const rangeEncoder:TRangeEncoder;const NumBitLevels:TpvInt32;symbol:TpvInt32);
var m,i,bit:TpvInt32;
begin
 m:=1;
 for i:=0 to NumBitLevels-1 do begin
  bit:=symbol and 1;
  rangeEncoder.Encode(Models,startIndex+m,bit);
  m:=(m shl 1) or bit;
  symbol:=symbol shr 1;
 end;
end;                          

function StateInit:TpvInt32;
begin
 result:=0;
end;

function StateUpdateChar(const Index:TpvInt32):TpvInt32;
begin
 if Index<4 then begin
  result:=0;
 end else if index<10 then begin
  result:=index-3;
 end else begin
  result:=index-6;
 end;
end;

function StateUpdateMatch(const Index:TpvInt32):TpvInt32;
begin
 if Index<7 then begin
  result:=7;
 end else begin
  result:=10;
 end;
end;

function StateUpdateRep(const Index:TpvInt32):TpvInt32;
begin
 if Index<7 then begin
  result:=8;
 end else begin
  result:=11;
 end;
end;

function StateUpdateShortRep(const Index:TpvInt32):TpvInt32;
begin
 if index<7 then begin
  result:=9;
 end else begin
  result:=11;
 end;
end;

function StateIsCharState(const Index:TpvInt32):boolean;
begin
 result:=index<7;
end;

function GetLenToPosState(Len:TpvInt32):TpvInt32;
begin
 dec(len,kMatchMinLen);
 if len<kNumLenToPosStates then begin
  result:=len;
 end else begin
  result:=kNumLenToPosStates-1;
 end;
end;

constructor TCRC.Create;
begin
 inherited Create;
 Init;
end;

destructor TCRC.Destroy;
begin
 inherited Destroy;
end;

procedure TCRC.Init;
begin
 Value:=TpvUInt32(TpvInt32(-1));
end;

procedure TCRC.Update(const Data:array of TpvUInt8;const Offset,Size:TpvInt32);
var i:TpvInt32;
begin
 for i:=0 to Size-1 do begin
  Value:=CRCTable[(Value xor TpvUInt32(Data[Offset+i])) and $ff] xor (Value shr 8);
 end;
end;

procedure TCRC.Update(const Data:array of TpvUInt8);
begin
 Update(Data,0,length(Data));
end;

procedure TCRC.UpdateByte(const b:TpvUInt32);
begin
 Value:=CRCTable[(Value xor b) and $ff] xor (Value shr 8);
end;

function TCRC.GetDigest:TpvInt32;
begin
 result:=Value xor TpvUInt32(TpvInt32(-1));
end;

procedure InitCRC;
var i,j,r:TpvUInt32;
begin
 for i:=0 to 255 do begin
  r:=i;
  for j:=0 to 7 do begin
   if (r and 1)<>0 then begin
    r:=(r shr 1) xor TpvUInt32($edb88320);
   end else begin
    r:=r shr 1;
   end;
  end;
  CRCTable[i]:=r;
 end;
end;

constructor TLZInWindow.Create;
begin
 inherited Create;
end;

destructor TLZInWindow.Destroy;
begin
 inherited Destroy;
end;

procedure TLZInWindow.MoveBlock;
var offset,numbytes,i:TpvInt32;
begin
 offset:=(bufferOffset+pos)-keepSizeBefore;
 if offset>0 then begin
  dec(offset);
 end;
 numBytes:=bufferOffset+streamPos-offset;
 for i:=0 to numBytes-1 do begin
  bufferBase[i]:=bufferBase[offset+i];
 end;
 dec(bufferOffset,offset);
end;

procedure TLZInWindow.ReadBlock;
var size,numreadbytes,pointerToPostion:TpvInt32;
begin
 if streamEndWasReached then begin
  exit;
 end;
 while true do begin
  size:=(0-bufferOffset)+blockSize-streamPos;
  if size=0 then begin
   exit;
  end;
  numReadBytes:=Stream.Read(bufferBase[bufferOffset+streamPos],size);
  if numReadBytes=0 then begin
   posLimit:=streamPos;
   pointerToPostion:=bufferOffset+posLimit;
   if pointerToPostion>pointerToLastSafePosition then begin
    posLimit:=pointerToLastSafePosition-bufferOffset;
   end;
   streamEndWasReached:=true;
   exit;
  end;
  inc(streamPos,numReadBytes);
  if streamPos>=(pos+keepSizeAfter) then begin
   posLimit:=streamPos-keepSizeAfter;
  end;
 end;
end;

procedure TLZInWindow._Free;
begin
 setlength(bufferBase,0);
end;

procedure TLZInWindow._Create(const aKeepSizeBefore,aKeepSizeAfter,aKeepSizeReserv:TpvInt32);
var newBlocksize:TpvInt32;
begin
 keepSizeBefore:=aKeepSizeBefore;
 keepSizeAfter:=aKeepSizeAfter;
 newBlockSize:=aKeepSizeBefore+aKeepSizeAfter+aKeepSizeReserv;
 if (length(bufferBase)=0) or (blockSize<>newBlockSize) then begin
  _Free;
  blockSize:=newBlockSize;
  setlength(bufferBase,self.blockSize);
 end;
 pointerToLastSafePosition:=blockSize-keepSizeAfter;
end;

procedure TLZInWindow.SetStream(const AStream:TStream);
begin
 Stream:=AStream;
end;

procedure TLZInWindow.ReleaseStream;
begin
 Stream:=nil;
end;

procedure TLZInWindow.Init;
begin
 bufferOffset:=0;
 pos:=0;
 streamPos:=0;
 streamEndWasReached:=false;
 ReadBlock;
end;

procedure TLZInWindow.MovePos;
var pointerToPostion:TpvInt32;
begin
 inc(pos);
 if pos>posLimit then begin
  pointerToPostion:=bufferOffset+pos;
  if pointerToPostion>pointerToLastSafePosition then begin
   MoveBlock;
  end;
  ReadBlock;
 end;
end;

function TLZInWindow.GetIndexByte(const index:TpvInt32):TpvUInt8;
begin
 result:=bufferBase[bufferOffset+pos+index];
end;

function TLZInWindow.GetMatchLen(const index:TpvInt32;distance,limit:TpvInt32):TpvInt32;
var pby,i:TpvInt32;
begin
 if streamEndWasReached then begin
  if (pos+index)+limit>streamPos then begin
   limit:=streamPos-(pos+index);
  end;
 end;
 inc(distance);
 pby:=bufferOffset+pos+index;
 i:=0;
 while (i<limit) and (bufferBase[pby+i]=bufferBase[pby+i-distance]) do begin
  inc(i);
 end;
 result:=i;
end;

function TLZInWindow.GetNumAvailableBytes:TpvInt32;
begin
 result:=streamPos-pos;
end;

procedure TLZInWindow.ReduceOffsets(const subvalue:TpvInt32);
begin
 inc(bufferOffset,subValue);
 dec(posLimit,subValue);
 dec(pos,subValue);
 dec(streamPos,subValue);
end;

constructor TLZOutWindow.Create;
begin
 inherited Create;
end;

destructor TLZOutWindow.Destroy;
begin
 inherited Destroy;
end;

procedure TLZOutWindow._Create(const aWindowSize:TpvInt32);
begin
 if (length(buffer)=0) or (windowSize<>aWindowSize) then begin
  setlength(buffer,aWindowSize);
 end;
 windowSize:=aWindowSize;
 pos:=0;
 streamPos:=0;
end;

procedure TLZOutWindow.SetStream(const AStream:TStream);
begin
 ReleaseStream;
 Stream:=AStream;
end;

procedure TLZOutWindow.ReleaseStream;
begin
 Flush;
 Stream:=nil;
end;

procedure TLZOutWindow.Init(const solid:boolean);
begin
 if not solid then begin
  streamPos:=0;
  Pos:=0;
 end;
end;

procedure TLZOutWindow.Flush;
var size:TpvInt32;
begin
 size:=pos-streamPos;
 if size=0 then begin
  exit;
 end;
 Stream.Write(buffer[streamPos],size);
 if pos>=windowSize then begin
  pos:=0;
 end;
 streamPos:=pos;
end;

procedure TLZOutWindow.CopyBlock(const distance:TpvInt32;len:TpvInt32);
var pos:TpvInt32;
begin
 pos:=self.pos-distance-1;
 if pos<0 then begin
  inc(pos,windowSize);
 end;
 while len<>0 do begin
  if pos>=windowSize then begin
   pos:=0;
  end;
  buffer[self.pos]:=buffer[pos];
  inc(self.pos);
  inc(pos);
  if Pos>=windowSize then begin
   Flush;
  end;
  dec(len);
 end;
end;

procedure TLZOutWindow.PutByte(const b:TpvUInt8);
begin
 buffer[pos]:=b;
 inc(pos);
 if Pos>=windowSize then begin
  Flush;
 end;
end;

function TLZOutWindow.GetByte(const distance:TpvInt32):TpvUInt8;
var pos:TpvInt32;
begin
 pos:=self.pos-distance-1;
 if pos<0 then begin
  inc(pos,windowSize);
 end;
 result:=buffer[pos];
end;

constructor TLZBinTree.Create;
begin
 inherited Create;
 cyclicBufferSize:=0;
 cutValue:=$ff;
 hashSizeSum:=0;
 HASH_ARRAY:=true;
 kNumHashDirectBytes:=0;
 kMinMatchCheck:=4;
 kFixHashsize:=kHash2Size+kHash3Size;
end;

procedure TLZBinTree.SetType(const numHashBytes:TpvInt32);
begin
 HASH_ARRAY:=numHashBytes>2;
 if HASH_ARRAY then begin
  kNumHashDirectBytes:=0;
  kMinMatchCheck:=4;
  kFixHashSize:=kHash2Size+kHash3Size;
 end else begin
  kNumHashDirectBytes:=2;
  kMinMatchCheck:=2+1;
  kFixHashSize:=0;
 end;
end;

procedure TLZBinTree.Init;
var i:TpvInt32;
begin
 inherited Init;
 for i:=0 to hashSizeSum-1 do begin
  hash[i]:=kEmptyHashValue;
 end;
 cyclicBufferPos:=0;
 ReduceOffsets(-1);
end;

procedure TLZBinTree.MovePos;
begin
 inc(cyclicBufferPos);
 if cyclicBufferPos>=cyclicBufferSize then begin
  cyclicBufferPos:=0;
 end;
 inherited MovePos;
 if pos=kMaxValForNormalize then begin
  Normalize;
 end;
end;

function TLZBinTree._Create(const aHistorySize,aKeepAddBufferBefore,aMatchMaxLen,aKeepAddBufferAfter:TpvInt32):boolean;
var windowReservSize,newCyclicBufferSize,hs:TpvInt32;
begin
 if aHistorySize>(kMaxValForNormalize-256) then begin
  result:=false;
  exit;
 end;
 cutValue:=16+(aMatchMaxLen shr 1);
 windowReservSize:=(aHistorySize+aKeepAddBufferBefore+aMatchMaxLen+aKeepAddBufferAfter) div 2+256;
 inherited _Create(aHistorySize+aKeepAddBufferBefore,aMatchMaxLen+aKeepAddBufferAfter,windowReservSize);
 matchMaxLen:=aMatchMaxLen;
 newCyclicBufferSize:=aHistorySize+1;
 if cyclicBufferSize<>newCyclicBufferSize then begin
  cyclicBufferSize:=newCyclicBufferSize;
  setlength(son,cyclicBufferSize*2);
 end;
 hs:=kBT2HashSize;
 if HASH_ARRAY then begin
  hs:=AHistorySize-1;
  hs:=hs or (hs shr 1);
  hs:=hs or (hs shr 2);
  hs:=hs or (hs shr 4);
  hs:=hs or (hs shr 8);
  hs:=hs shr 1;
  hs:=hs or $ffFF;
  if hs>(1 shl 24) then begin
   hs:=hs shr 1;
  end;
  hashMask:=hs;
  inc(hs);
  hs:=hs+kFixHashSize;
 end;
 if hs<>hashSizeSum then begin
  hashSizeSum:=hs;
  setlength(hash,hashSizeSum);
 end;
 result:=true;
end;

function TLZBinTree.GetMatches(var distances:array of TpvInt32):TpvInt32;
var lenLimit,offset,matchMinPos,cur,maxlen,hashvalue,hash2value,hash3value,
    temp,curmatch,curmatch2,curmatch3,ptr0,ptr1,len0,len1,count,
    delta,cyclicpos,pby1,len:TpvInt32;
begin
 if pos+matchMaxLen<=streamPos then begin
  lenLimit:=matchMaxLen;
 end else begin
  lenLimit:=streamPos-pos;
  if lenLimit<kMinMatchCheck then begin
   MovePos;
   result:=0;
   exit;
  end;
 end;
 offset:=0;
 if (pos>cyclicBufferSize) then begin
  matchMinPos:=pos-cyclicBufferSize;
 end else begin
  matchMinPos:=0;
 end;
 cur:=bufferOffset+pos;
 maxLen:=kStartMaxLen; // to avoid items for len < hashSize;
 hash2Value:=0;
 hash3Value:=0;
 if HASH_ARRAY then begin
  temp:=CrcTable[bufferBase[cur] and $ff] xor (bufferBase[cur+1] and $ff);
  hash2Value:=temp and (kHash2Size-1);
  temp:=temp xor ((bufferBase[cur+2] and $ff) shl 8);
  hash3Value:=temp and (kHash3Size-1);
  hashValue:=(temp xor (TpvInt32(CrcTable[bufferBase[cur+3] and $ff]) shl 5)) and hashMask;
 end else begin
  hashValue:=((bufferBase[cur] and $ff) xor ((bufferBase[cur+1] and $ff) shl 8));
 end;
 curMatch:=hash[kFixHashSize+hashValue];
 if HASH_ARRAY then begin
  curMatch2:=hash[hash2Value];
  curMatch3:=hash[kHash3Offset+hash3Value];
  hash[hash2Value]:=pos;
  hash[kHash3Offset+hash3Value]:=pos;
  if curMatch2>matchMinPos then begin
   if bufferBase[bufferOffset+curMatch2]=bufferBase[cur] then begin
    maxLen:=2;
    distances[offset]:=maxLen;
    inc(offset);
    distances[offset]:=pos-curMatch2-1;
    inc(offset);
   end;
  end;
  if curMatch3>matchMinPos then begin
   if bufferBase[bufferOffset+curMatch3]=bufferBase[cur] then begin
    if curMatch3=curMatch2 then begin
     dec(offset,2);
    end;
    maxLen:=3;
    distances[offset]:=maxlen;
    inc(offset);
    distances[offset]:=pos-curMatch3-1;
    inc(offset);
    curMatch2:=curMatch3;
   end;
  end;
  if (offset<>0) and (curMatch2=curMatch) then begin
   dec(offset,2);
   maxLen:=kStartMaxLen;
  end;
 end;
 hash[kFixHashSize+hashValue]:=pos;
 ptr0:=(cyclicBufferPos shl 1)+1;
 ptr1:=(cyclicBufferPos shl 1);
 len0:=kNumHashDirectBytes;
 len1:=len0;
 if kNumHashDirectBytes<>0 then begin
  if curMatch>matchMinPos then begin
   if bufferBase[bufferOffset+curMatch+kNumHashDirectBytes]<>bufferBase[cur+kNumHashDirectBytes] then begin
    maxLen:=kNumHashDirectBytes;
    distances[offset]:=maxLen;
    inc(offset);
    distances[offset]:=pos-curMatch-1;
    inc(offset);
   end;
  end;
 end;
 count:=cutValue;
 while true do begin
  if (curMatch<=matchMinPos) or (count=0) then begin
   son[ptr1]:=kEmptyHashValue;
   son[ptr0]:=son[ptr1];
   break;
  end;
  dec(count);
  delta:=pos-curMatch;
  if delta<=cyclicBufferPos then begin
   cyclicpos:=(cyclicBufferPos-delta) shl 1;
  end else begin
   cyclicpos:=(cyclicBufferPos-delta+cyclicBufferSize) shl 1;
  end;
  pby1:=bufferOffset+curMatch;
  if len0<len1 then begin
   len:=len0;
  end else begin
   len:=len1;
  end;
  if bufferBase[pby1+len]=bufferBase[cur+len] then begin
   inc(len);
   while len<>lenLimit do begin
    if (bufferBase[pby1+len]<>bufferBase[cur+len]) then begin
     break;
    end;
    inc(len);
   end;
   if maxLen<len then begin
    maxLen:=len;
    distances[offset]:=maxlen;
    inc(offset);
    distances[offset]:=delta-1;
    inc(offset);
    if len=lenLimit then  begin
     son[ptr1]:=son[cyclicPos];
     son[ptr0]:=son[cyclicPos+1];
     break;
    end;
   end;
  end;
  if (bufferBase[pby1+len] and $ff)<(bufferBase[cur+len] and $ff) then begin
   son[ptr1]:=curMatch;
   ptr1:=cyclicPos+1;
   curMatch:=son[ptr1];
   len1:=len;
  end else begin
   son[ptr0]:=curMatch;
   ptr0:=cyclicPos;
   curMatch:=son[ptr0];
   len0:=len;
  end;
 end;
 MovePos;
 result:=offset;
end;

procedure TLZBinTree.Skip(num:TpvInt32);
var lenLimit,matchminpos,cur,hashvalue,temp,hash2value,hash3value,curMatch,
    ptr0,ptr1,len,len0,len1,count,delta,cyclicpos,pby1:TpvInt32;
begin
 repeat
  if pos+matchMaxLen<=streamPos then begin
   lenLimit:=matchMaxLen;
  end else begin
   lenLimit:=streamPos-pos;
   if lenLimit<kMinMatchCheck then begin
    MovePos;
    dec(num);
    continue;
   end;
  end;
  if pos>cyclicBufferSize then begin
   matchminpos:=(pos-cyclicBufferSize);
  end else begin
   matchminpos:=0;
  end;
  cur:=bufferOffset+pos;
  if HASH_ARRAY then begin
   temp:=CrcTable[bufferBase[cur] and $ff] xor (bufferBase[cur+1] and $ff);
   hash2Value:=temp and (kHash2Size-1);
   hash[hash2Value]:=pos;
   temp:=temp xor ((bufferBase[cur+2] and $ff) shl 8);
   hash3Value:=temp and (kHash3Size-1);
   hash[kHash3Offset+hash3Value]:=pos;
   hashValue:=(temp xor (TpvInt32(CrcTable[bufferBase[cur+3] and $ff]) shl 5)) and hashMask;
  end else begin
   hashValue:=((bufferBase[cur] and $ff) xor ((bufferBase[cur+1] and $ff) shl 8));
  end;
  curMatch:=hash[kFixHashSize+hashValue];
  hash[kFixHashSize+hashValue]:=pos;
  ptr0:=(cyclicBufferPos shl 1)+1;
  ptr1:=(cyclicBufferPos shl 1);
  len0:=kNumHashDirectBytes;
  len1:=kNumHashDirectBytes;
  count:=cutValue;
  while true do begin
   if (curMatch<=matchMinPos) or (count=0) then begin
    son[ptr1]:=kEmptyHashValue;
    son[ptr0]:=son[ptr1];
    break;
   end else begin
    dec(count);
   end;
   delta:=pos-curMatch;
   if (delta<=cyclicBufferPos) then begin
    cyclicpos:=(cyclicBufferPos-delta) shl 1;
   end else begin
    cyclicpos:=(cyclicBufferPos-delta+cyclicBufferSize) shl 1;
   end;
   pby1:=bufferOffset+curMatch;
   if len0<len1 then begin
    len:=len0;
   end else begin
    len:=len1;
   end;
   if bufferBase[pby1+len]=bufferBase[cur+len] then begin
    inc(len);
    while len<>lenLimit do begin
     if bufferBase[pby1+len]<>bufferBase[cur+len] then begin
      break;
     end;
     inc(len);
    end;
    if len=lenLimit then begin
     son[ptr1]:=son[cyclicPos];
     son[ptr0]:=son[cyclicPos+1];
     break;
    end;
   end;
   if (bufferBase[pby1+len] and $ff)<(bufferBase[cur+len] and $ff) then begin
    son[ptr1]:=curMatch;
    ptr1:=cyclicPos+1;
    curMatch:=son[ptr1];
    len1:=len;
   end else begin
    son[ptr0]:=curMatch;
    ptr0:=cyclicPos;
    curMatch:=son[ptr0];
    len0:=len;
   end;
  end;
  MovePos;
  dec(num);
 until num=0;
end;

procedure TLZBinTree.NormalizeLinks(var items:array of TpvInt32;const numItems,subValue:TpvInt32);
var i,value:TpvInt32;
begin
 for i:=0 to NumItems-1 do begin
  value:=items[i];
  if value<=subValue then begin
   value:=kEmptyHashValue;
  end else begin
   dec(value,subValue);
  end;
  items[i]:=value;
 end;
end;

procedure TLZBinTree.Normalize;
var subvalue:TpvInt32;
begin
 subValue:=pos-cyclicBufferSize;
 NormalizeLinks(son,cyclicBufferSize*2,subValue);
 NormalizeLinks(hash,hashSizeSum,subValue);
 ReduceOffsets(subValue);
end;

procedure TLZBinTree.SetCutValue(const cutvalue:TpvInt32);
begin
 self.cutValue:=cutValue;
end;

procedure TRangeDecoder.SetStream(const AStream:TStream);
begin
 Stream:=AStream;
end;

procedure TRangeDecoder.ReleaseStream;
begin
 Stream:=nil;
end;

procedure TRangeDecoder.Init;
var i:TpvInt32;
begin
 code:=0;
 Range:=-1;
 for i:=0 to 4 do begin
  code:=(code shl 8) or TpvUInt8(ReadByte(Stream));
 end;
end;

function TRangeDecoder.DecodeDirectBits(const numTotalBits:TpvInt32):TpvInt32;
var i,t:TpvInt32;
begin
 result:=0;
 for i:=numTotalBits downto 1 do begin
  range:=range shr 1;
  t:=(Code-Range) shr 31;
  dec(Code,Range and (t-1));
  result:=(result shl 1) or (1-t);
  if (Range and kTopMask)=0 then begin
   Code:=(Code shl 8) or ReadByte(Stream);
   Range:=Range shl 8;
  end;
 end;
end;

function TRangeDecoder.DecodeBit(probs:psmallints;const index:TpvInt32):TpvInt32;
var prob,newbound:TpvInt32;
begin
 prob:=probs^[index];
 newbound:=(Range shr kNumBitModelTotalBits)*prob;
 if (TpvInt32((TpvInt32(Code) xor TpvInt32($80000000)))<TpvInt32((TpvInt32(newBound) xor TpvInt32($80000000)))) then begin
  Range:=newBound;
  probs[index]:=prob+((kBitModelTotal-prob) shr kNumMoveBits);
  if (Range and kTopMask)=0 then begin
   Code:=(Code shl 8) or ReadByte(Stream);
   Range:=Range shl 8;
  end;
  result:=0;
 end else begin
  dec(Range,newBound);
  dec(Code,newBound);
  probs[index]:=prob-(prob shr kNumMoveBits);
  if (Range and kTopMask)=0 then begin
   Code:=(Code shl 8) or ReadByte(Stream);
   Range:=Range shl 8;             
  end;
  result:=1;
 end;
end;

procedure TRangeEncoder.SetStream(const AStream:TStream);
begin
 Stream:=AStream;
end;

procedure TRangeEncoder.ReleaseStream;
begin
 Stream:=nil;
end;

procedure TRangeEncoder.Init;
begin
 position:=0;
 Low:=0;
 Range:=-1;
 cacheSize:=1;
 cache:=0;
end;

procedure TRangeEncoder.FlushData;
var i:TpvInt32;
begin
 for i:=0 to 4 do begin
  ShiftLow;
 end;
end;

procedure TRangeEncoder.FlushStream;
begin
//Stream.Flush;
end;

procedure TRangeEncoder.ShiftLow;
var LowHi,temp:TpvInt32;
begin
 LowHi:=Low shr 32;
 if (LowHi<>0) or (Low<TpvInt64($ff000000)) then begin
  position:=position+cacheSize;
  temp:=cache;
  repeat
   WriteByte(Stream,temp+LowHi);
   temp:=$ff;
   dec(cacheSize);
  until (cacheSize=0);
  cache:=Low shr 24;
 end;
 inc(cacheSize);
 Low:=(Low and TpvInt32($ffffff)) shl 8;
end;

procedure TRangeEncoder.EncodeDirectBits(const v,numTotalBits:TpvInt32);
var i:TpvInt32;
begin
 for i:=numTotalBits-1 downto 0 do begin
  Range:=Range shr 1;
  if ((v shr i) and 1)=1 then begin
   inc(Low,Range);
  end;
  if (Range and kTopMask)=0 then begin
   Range:=Range shl 8;
   ShiftLow;
  end;
 end;
end;

function TRangeEncoder.GetProcessedSizeAdd:TpvInt64;
begin
 result:=cacheSize+position+4;
end;

procedure TRangeEncoder.Encode(var probs:array of TpvInt16;const index,symbol:TpvInt32);
var prob,newbound:TpvInt32;
begin
 prob:=probs[index];
 newBound:=(Range shr kNumBitModelTotalBits)*prob;
 if symbol=0 then begin
  Range:=newBound;
  probs[index]:=prob+((kBitModelTotal-prob) shr kNumMoveBits);
 end else begin
  inc(Low,newBound and TpvInt64($ffffffff));
  dec(Range,newBound);
  probs[index]:=prob-(prob shr kNumMoveBits);
 end;
 if (Range and kTopMask)=0 then begin
  Range:=Range shl 8;
  ShiftLow;
 end;
end;

constructor TRangeEncoder.Create;
var kNumBits,i,j,start,_end:TpvInt32;
begin
 kNumBits:=(kNumBitModelTotalBits-kNumMoveReducingBits);
 for i:=kNumBits-1 downto 0 do begin
  start:=1 shl (kNumBits-i-1);
  _end:=1 shl (kNumBits-i);
  for j:=start to _end-1 do begin
   ProbPrices[j]:=(i shl kNumBitPriceShiftBits)+(((_end-j) shl kNumBitPriceShiftBits) shr (kNumBits-i-1));
  end;
 end;
end;

function TRangeEncoder.GetPrice(const Prob,symbol:TpvInt32):TpvInt32;
begin
 result:=ProbPrices[(((Prob-symbol) xor ((-symbol))) and (kBitModelTotal-1)) shr kNumMoveReducingBits];
end;

function TRangeEncoder.GetPrice0(const Prob:TpvInt32):TpvInt32;
begin
 result:=ProbPrices[Prob shr kNumMoveReducingBits];
end;

function TRangeEncoder.GetPrice1(const Prob:TpvInt32):TpvInt32;
begin
 result:=ProbPrices[(kBitModelTotal-Prob) shr kNumMoveReducingBits];
end;

constructor TBitTreeDecoder.Create(const aNumBitLevels:TpvInt32);
begin
 NumBitLevels:=aNumBitLevels;
 setlength(Models,1 shl numBitLevels);
end;

procedure TBitTreeDecoder.Init;
begin
 InitBitModels(Models);
end;

function TBitTreeDecoder.Decode(const rangeDecoder:TRangeDecoder):TpvInt32;
var m,bitIndex:TpvInt32;
begin
 m:=1;
 for bitIndex:=NumBitLevels downto 1 do begin
  m:=(m shl 1)+rangeDecoder.DecodeBit(@Models[0],m);
 end;
 result:=m-(1 shl NumBitLevels);
end;

function TBitTreeDecoder.ReverseDecode(const rangeDecoder:TRangeDecoder):TpvInt32;
var m,symbol,bitindex,bit:TpvInt32;
begin
 m:=1;
 symbol:=0;
 for bitindex:=0 to numbitlevels-1 do begin
  bit:=rangeDecoder.DecodeBit(@Models[0],m);
  m:=(m shl 1) or bit;
  symbol:=symbol or (bit shl bitIndex);
 end;
 result:=symbol;
end;

constructor TBitTreeEncoder.Create(const aNumBitLevels:TpvInt32);
begin
 NumBitLevels:=aNumBitLevels;
 setlength(Models,1 shl numBitLevels);
end;

procedure TBitTreeEncoder.Init;
begin
 InitBitModels(Models);
end;

procedure TBitTreeEncoder.Encode(const rangeEncoder:TRangeEncoder;const symbol:TpvInt32);
var m,bitindex,bit:TpvInt32;
begin
 m:=1;
 for bitIndex:=NumBitLevels-1 downto 0 do begin
  bit:=(symbol shr bitIndex) and 1;
  rangeEncoder.Encode(Models,m,bit);
  m:=(m shl 1) or bit;
 end;
end;

procedure TBitTreeEncoder.ReverseEncode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32);
var m,i,bit:TpvInt32;
begin
 m:=1;
 for i:=0 to NumBitLevels-1 do begin
  bit:=symbol and 1;
  rangeEncoder.Encode(Models,m,bit);
  m:=(m shl 1) or bit;
  symbol:=symbol shr 1;
 end;
end;

function TBitTreeEncoder.GetPrice(const symbol:TpvInt32):TpvInt32;
var m,bitindex,bit:TpvInt32;
begin
 result:=0;
 m:=1;
 for bitIndex:=NumBitLevels-1 downto 0 do begin
  bit:=(symbol shr bitIndex) and 1;
  inc(result,rangeEncoder.GetPrice(Models[m],bit));
  m:=(m shl 1) or bit;
 end;
end;

function TBitTreeEncoder.ReverseGetPrice(symbol:TpvInt32):TpvInt32;
var m,i,bit:TpvInt32;
begin
 result:=0;
 m:=1;
 for i:=NumBitLevels downto 1 do begin
  bit:=symbol and 1;
  symbol:=symbol shr 1;
  inc(result,RangeEncoder.GetPrice(Models[m],bit));
  m:=(m shl 1) or bit;
 end;
end;

constructor TLZMALenDecoder.Create;
begin
 inherited Create;
 m_HighCoder:=TBitTreeDecoder.Create(kNumHighLenBits);
 m_NumPosStates:=0;
end;

destructor TLZMALenDecoder.Destroy;
var i:TpvInt32;
begin
 m_HighCoder.Free;
 for i:=low(m_LowCoder) to high(m_LowCoder) do begin
  if assigned(m_LowCoder[i]) then begin
   m_LowCoder[i].Free;
  end;
  if assigned(m_MidCoder[i]) then begin
   m_MidCoder[i].Free;
  end;
 end;
 inherited Destroy;
end;

procedure TLZMALenDecoder._Create(const numPosStates:TpvInt32);
begin
 while m_NumPosStates<numPosStates do begin
  m_LowCoder[m_NumPosStates]:=TBitTreeDecoder.Create(kNumLowLenBits);
  m_MidCoder[m_NumPosStates]:=TBitTreeDecoder.Create(kNumMidLenBits);
  inc(m_NumPosStates);
 end;
end;

procedure TLZMALenDecoder.Init;
var posState:TpvInt32;
begin
 InitBitModels(m_Choice);
 for posState:=0 to m_NumPosStates-1 do begin
  m_LowCoder[posState].Init;
  m_MidCoder[posState].Init;
 end;
 m_HighCoder.Init;
end;

function TLZMALenDecoder.Decode(const rangeDecoder:TRangeDecoder;const posState:TpvInt32):TpvInt32;
begin
 if (rangeDecoder.DecodeBit(@m_Choice[0],0)=0) then begin
  result:=m_LowCoder[posState].Decode(rangeDecoder);
  exit;
 end;
 result:=kNumLowLenSymbols;
 if (rangeDecoder.DecodeBit(@m_Choice[0],1)=0) then begin
  inc(result,m_MidCoder[posState].Decode(rangeDecoder));
 end else begin
  inc(result,kNumMidLenSymbols+m_HighCoder.Decode(rangeDecoder));
 end;
end;

procedure TLZMADecoder2.Init;
begin
 InitBitModels(m_Decoders);
end;

function TLZMADecoder2.DecodeNormal(const rangeDecoder:TRangeDecoder):TpvUInt8;
var symbol:TpvInt32;
begin
 symbol:=1;
 repeat
  symbol:=(symbol shl 1) or rangeDecoder.DecodeBit(@m_Decoders[0],symbol);
 until not (symbol<$100);
 result:=symbol;
end;

function TLZMADecoder2.DecodeWithMatchByte(const rangeDecoder:TRangeDecoder;matchByte:TpvUInt8):TpvUInt8;
var symbol,matchbit,bit:TpvInt32;
begin
 symbol:=1;
 repeat
  matchBit:=(matchByte shr 7) and 1;
  matchByte:=matchByte shl 1;
  bit:=rangeDecoder.DecodeBit(@m_Decoders[0],((1+matchBit) shl 8)+symbol);
  symbol:=(symbol shl 1) or bit;
  if matchBit<>bit then begin
   while symbol<$100 do begin
    symbol:=(symbol shl 1) or rangeDecoder.DecodeBit(@m_Decoders[0],symbol);
   end;
   break;
  end;
 until not (symbol<$100);
 result:=symbol;
end;

constructor TLZMALiteralDecoder.Create;
begin                      
 inherited Create;
end;

procedure TLZMALiteralDecoder._Create(const numPosBits,numPrevBits:TpvInt32);
var numStates,i:TpvInt32;
begin
 if (length(m_Coders)<>0) and (m_NumPrevBits=numPrevBits) and (m_NumPosBits=numPosBits) then begin
  exit;
 end;
 m_NumPosBits:=numPosBits;
 m_PosMask:=(1 shl numPosBits)-1;
 m_NumPrevBits:=numPrevBits;
 numStates:=1 shl (m_NumPrevBits+m_NumPosBits);
 setlength(m_Coders,numStates);
 for i:=0 to numStates-1 do begin
  m_Coders[i]:=TLZMADecoder2.Create;
 end;
end;

destructor TLZMALiteralDecoder.Destroy;
var i:TpvInt32;
begin
 for i:=low(m_Coders) to high(m_Coders) do begin
  if assigned(m_Coders[i]) then begin
   m_Coders[i].Free;
  end;
 end;
 inherited Destroy;
end;

procedure TLZMALiteralDecoder.Init;
var numStates,i:TpvInt32;
begin
 numStates:=1 shl (m_NumPrevBits+m_NumPosBits);
 for i:=0 to numStates-1 do
 begin m_Coders[i].Init;end;
end;

function TLZMALiteralDecoder.GetDecoder(const pos:TpvInt32;const prevByte:TpvUInt8):TLZMADecoder2;
begin
 result:=m_Coders[((pos and m_PosMask) shl m_NumPrevBits)+((prevByte and $ff) shr (8-m_NumPrevBits))];
end;

constructor TLZMADecoder.Create;
var i:TpvInt32;
begin
 inherited Create;
 fOnProgress:=nil;
 m_OutWindow:=TLZOutWindow.Create;
 m_RangeDecoder:=TRangeDecoder.Create;
 m_PosAlignDecoder:=TBitTreeDecoder.Create(kNumAlignBits);
 m_LenDecoder:=TLZMALenDecoder.Create;
 m_RepLenDecoder:=TLZMALenDecoder.Create;
 m_LiteralDecoder:=TLZMALiteralDecoder.Create;
 m_DictionarySize:=-1;
 m_DictionarySizeCheck:=-1;
 for i:=0 to kNumLenToPosStates-1 do begin
  m_PosSlotDecoder[i]:=TBitTreeDecoder.Create(kNumPosSlotBits);
 end;
end;

destructor TLZMADecoder.Destroy;
var i:TpvInt32;
begin
 m_OutWindow.Free;
 m_RangeDecoder.Free;
 m_PosAlignDecoder.Free;
 m_LenDecoder.Free;
 m_RepLenDecoder.Free;
 m_LiteralDecoder.Free;
 for i:=0 to kNumLenToPosStates-1 do begin
  m_PosSlotDecoder[i].Free;
 end;
 inherited Destroy;
end;

function TLZMADecoder.SetDictionarySize(const dictionarySize:TpvInt32):boolean;
begin
 if dictionarySize<0 then begin
  result:=false;
 end else begin
  if m_DictionarySize<>dictionarySize then begin
   m_DictionarySize:=dictionarySize;
   if 1<m_DictionarySize then begin
    m_DictionarySizeCheck:=m_DictionarySize;
   end else begin
    m_DictionarySizeCheck:=1;
   end;
   if (1 shl 12)<m_DictionarySizeCheck then begin
    m_OutWindow._Create(m_DictionarySizeCheck);
   end else begin
    m_OutWindow._Create(1 shl 12);
   end;
  end;
  result:=true;
 end;
end;

function TLZMADecoder.SetLcLpPb(const lc,lp,pb:TpvInt32):boolean;
var numPosStates:TpvInt32;
begin
 if (lc>kNumLitContextBitsMax) or (lp>4) or (pb>kNumPosStatesBitsMax) then begin
  result:=false;
  exit;
 end;
 m_LiteralDecoder._Create(lp,lc);
 numPosStates:=1 shl pb;
 m_LenDecoder._Create(numPosStates);
 m_RepLenDecoder._Create(numPosStates);
 m_PosStateMask:=numPosStates-1;
 result:=true;
end;

procedure TLZMADecoder.Init;
var i:TpvInt32;
begin
 m_OutWindow.Init(false);
 InitBitModels(m_IsMatchDecoders);
 InitBitModels(m_IsRep0LongDecoders);
 InitBitModels(m_IsRepDecoders);
 InitBitModels(m_IsRepG0Decoders);
 InitBitModels(m_IsRepG1Decoders);
 InitBitModels(m_IsRepG2Decoders);
 InitBitModels(m_PosDecoders);
 m_LiteralDecoder.Init;
 for i:=0 to kNumLenToPosStates-1 do begin
  m_PosSlotDecoder[i].Init;
 end;
 m_LenDecoder.Init;
 m_RepLenDecoder.Init;
 m_PosAlignDecoder.Init;
 m_RangeDecoder.Init;
end;

function TLZMADecoder.Code(const inStream,outStream:TStream;outSize:TpvInt64):boolean;
var state,rep0,rep1,rep2,rep3,posState,len,distance,posSlot,
    numDirectBits:TpvInt32;
    nowPos64,lpos,progint:TpvInt64;
    prevByte:TpvUInt8;
    decoder2:TLZMADecoder2;
begin
 DoProgress(TLZMAProgressAction.LPAMax,outSize);
 m_RangeDecoder.SetStream(inStream);
 m_OutWindow.SetStream(outStream);
 Init;
 state:=StateInit;
 rep0:=0;
 rep1:=0;
 rep2:=0;
 rep3:=0;
 nowPos64:=0;
 prevByte:=0;
 progint:=outsize div CodeProgressInterval;
 lpos:=progint;
 while (outSize<0) or (nowPos64<outSize) do begin
  if (nowPos64>=lpos) then begin
   DoProgress(TLZMAProgressAction.LPAPos,nowPos64);
   lpos:=lpos+progint;
  end;
  posState:=nowPos64 and m_PosStateMask;
  if (m_RangeDecoder.DecodeBit(@m_IsMatchDecoders[0],(state shl kNumPosStatesBitsMax)+posState)=0) then begin
   decoder2:=m_LiteralDecoder.GetDecoder(nowPos64,prevByte);
   if not StateIsCharState(state) then begin
    prevByte:=decoder2.DecodeWithMatchByte(m_RangeDecoder,m_OutWindow.GetByte(rep0));
   end else begin
    prevByte:=decoder2.DecodeNormal(m_RangeDecoder);
   end;
   m_OutWindow.PutByte(prevByte);
   state:=StateUpdateChar(state);
   inc(nowPos64);
  end else begin
   if (m_RangeDecoder.DecodeBit(@m_IsRepDecoders[0],state)=1) then begin
    len:=0;
    if (m_RangeDecoder.DecodeBit(@m_IsRepG0Decoders[0],state)=0) then begin
     if (m_RangeDecoder.DecodeBit(@m_IsRep0LongDecoders[0],(state shl kNumPosStatesBitsMax)+posState)=0) then begin
      state:=StateUpdateShortRep(state);
      len:=1;
     end;
    end else begin
     if m_RangeDecoder.DecodeBit(@m_IsRepG1Decoders[0],state)=0 then begin
      distance:=rep1;
     end else begin
      if (m_RangeDecoder.DecodeBit(@m_IsRepG2Decoders[0],state)=0) then begin
       distance:=rep2;
      end else begin
       distance:=rep3;
       rep3:=rep2;
      end;
      rep2:=rep1;
     end;
     rep1:=rep0;
     rep0:=distance;
    end;
    if len=0 then begin
     len:=m_RepLenDecoder.Decode(m_RangeDecoder,posState)+kMatchMinLen;
     state:=StateUpdateRep(state);
    end;
   end else begin
    rep3:=rep2;
    rep2:=rep1;
    rep1:=rep0;
    len :=kMatchMinLen+m_LenDecoder.Decode(m_RangeDecoder,posState);
    state:=StateUpdateMatch(state);
    posSlot:=m_PosSlotDecoder[GetLenToPosState(len)].Decode(m_RangeDecoder);
    if posSlot>=kStartPosModelIndex then begin
     numDirectBits:=(posSlot shr 1)-1;
     rep0:=(2 or (posSlot and 1)) shl numDirectBits;
     if posSlot<kEndPosModelIndex then begin
      rep0:=rep0+ReverseDecode(@m_PosDecoders[0],rep0-posSlot-1,m_RangeDecoder,numDirectBits);
     end else begin
      rep0:=rep0+(m_RangeDecoder.DecodeDirectBits(numDirectBits-kNumAlignBits) shl kNumAlignBits);
      rep0:=rep0+m_PosAlignDecoder.ReverseDecode(m_RangeDecoder);
      if rep0<0 then  begin
       if rep0=-1 then begin
        break;
       end;
       result:=false;
       exit;
      end;
     end;
    end else begin
     rep0:=posSlot;
    end;
   end;
   if (rep0>=nowPos64) or (rep0>=m_DictionarySizeCheck) then begin
    m_OutWindow.Flush;
    result:=false;
    exit;
   end;
   m_OutWindow.CopyBlock(rep0,len);
   nowPos64:=nowPos64+len;
   prevByte:=m_OutWindow.GetByte(0);
  end;
 end;
 m_OutWindow.Flush;
 m_OutWindow.ReleaseStream;
 m_RangeDecoder.ReleaseStream;
 DoProgress(TLZMAProgressAction.LPAPos,nowPos64);
 result:=true;
end;

function TLZMADecoder.SetDecoderProperties(const properties:array of TpvUInt8):boolean;
var val,lc,remainder,lp,pb,dictionarysize,i:TpvInt32;
begin
 if length(properties)<5 then begin
  result:=false;
  exit;
 end;
 val:=properties[0] and $ff;
 lc:=val mod 9;
 remainder:=val div 9;
 lp:=remainder mod 5;
 pb:=remainder div 5;
 dictionarySize:=0;
 for i:=0 to 3 do begin
  inc(dictionarySize,((properties[1+i]) and $ff) shl (i*8));
 end;
 if not SetLcLpPb(lc,lp,pb) then begin
  result:=false;
  exit;
 end;
 result:=SetDictionarySize(dictionarySize);
end;

procedure TLZMADecoder.DoProgress(const Action:TLZMAProgressAction;const Value:TpvInt64);
begin
 if assigned(fOnProgress) then begin
  fOnProgress(Action,Value);
 end;
end;

constructor TLZMAEncoder.Create;
var kFastSlots,c,slotFast,j,k:TpvInt32;
begin
 inherited Create;
 kFastSlots:=22;
 c:=2;
 g_FastPos[0]:=0;
 g_FastPos[1]:=1;
 for slotFast:=2 to kFastSlots-1 do begin
  k:=(1 shl ((slotFast shr 1)-1));
  for j:=0 to k-1 do begin
   g_FastPos[c]:=slotFast;
   inc(c);
  end;
 end;
 _state:=StateInit;
 _matchFinder:=nil;
 _rangeEncoder:=TRangeEncoder.Create;
 _posAlignEncoder:=TBitTreeEncoder.Create(kNumAlignBits);
 _lenEncoder:=TLZMALenPriceTableEncoder.Create;
 _repMatchLenEncoder:=TLZMALenPriceTableEncoder.Create;
 _literalEncoder:=TLZMALiteralEncoder.Create;
 _numFastBytes:=kNumFastBytesDefault;
 _distTableSize:=(kDefaultDictionaryLogSize*2);
 _posStateBits:=2;
 _posStateMask:=(4-1);
 _numLiteralPosStateBits:=0;
 _numLiteralContextBits:=3;
 _dictionarySize:=(1 shl kDefaultDictionaryLogSize);
 _dictionarySizePrev:=-1;
 _numFastBytesPrev:=-1;
 _matchFinderType:=EMatchFinderTypeBT4;
 _writeEndMark:=false;            
 _needReleaseMFStream:=false;
end;

destructor TLZMAEncoder.Destroy;
var i:TpvInt32;
begin
 _rangeEncoder.Free;
 _posAlignEncoder.Free;
 _lenEncoder.Free;
 _repMatchLenEncoder.Free;
 _literalEncoder.Free;
 if assigned(_matchFinder) then begin
  _matchFinder.Free;
 end;
 for i:=0 to kNumOpts-1 do begin
  _optimum[i].Free;
 end;
 for i:=0 to kNumLenToPosStates-1 do begin
  _posSlotEncoder[i].Free;
 end;
 inherited Destroy;
end;

procedure TLZMAEncoder._Create;
var bt:TLZBinTree;
    numHashBytes,i:TpvInt32;
begin
 if not assigned(_matchFinder) then begin
  bt:=TLZBinTree.Create;
  numHashBytes:=4;
  if _matchFinderType=EMatchFinderTypeBT2 then begin
   numHashBytes:=2;
  end;
  bt.SetType(numHashBytes);
  _matchFinder:=bt;
 end;
 _literalEncoder._Create(_numLiteralPosStateBits,_numLiteralContextBits);
 if (_dictionarySize=_dictionarySizePrev) and (_numFastBytesPrev=_numFastBytes) then begin
  exit;
 end;
 _matchFinder._Create(_dictionarySize,kNumOpts,_numFastBytes,kMatchMaxLen+1);
 _dictionarySizePrev:=_dictionarySize;
 _numFastBytesPrev:=_numFastBytes;
 for i:=0 to kNumOpts-1 do begin
  _optimum[i]:=TLZMAOptimal.Create;
 end;
 for i:=0 to kNumLenToPosStates-1 do begin
  _posSlotEncoder[i]:=TBitTreeEncoder.Create(kNumPosSlotBits);
 end;
end;

function TLZMAEncoder.GetPosSlot(const pos:TpvInt32):TpvInt32;
begin
 if pos<(1 shl 11) then begin
  result:=g_FastPos[pos];
 end else if pos<(1 shl 21) then begin
  result:=g_FastPos[pos shr 10]+20;
 end else begin
  result:=g_FastPos[pos shr 20]+40;
 end;
end;

function TLZMAEncoder.GetPosSlot2(const pos:TpvInt32):TpvInt32;
begin
 if pos<1 shl 17 then begin
  result:=g_FastPos[pos shr 6]+12;
 end else if pos<(1 shl 27) then begin
  result:=g_FastPos[pos shr 16]+32;
 end else begin
  result:=g_FastPos[pos shr 26]+52;
 end;
end;

procedure TLZMAEncoder.BaseInit;
var i:TpvInt32;
begin
 _state:=StateInit;
 _previousByte:=0;
 for i:=0 to kNumRepDistances-1 do begin
  _repDistances[i]:=0;
 end;
end;

procedure TLZMAEncoder.SetWriteEndMarkerMode(const writeEndMarker:boolean);
begin
 _writeEndMark:=writeEndMarker;
end;

procedure TLZMAEncoder.Init;
var i:TpvInt32;
begin
 BaseInit;
 _rangeEncoder.Init;
 InitBitModels(_isMatch);
 InitBitModels(_isRep0Long);
 InitBitModels(_isRep);
 InitBitModels(_isRepG0);
 InitBitModels(_isRepG1);
 InitBitModels(_isRepG2);
 InitBitModels(_posEncoders);
 _literalEncoder.Init;
 for i:=0 to kNumLenToPosStates-1 do begin
  _posSlotEncoder[i].Init;
 end;
 _lenEncoder.Init(1 shl _posStateBits);
 _repMatchLenEncoder.Init(1 shl _posStateBits);
 _posAlignEncoder.Init;
 _longestMatchWasFound:=false;
 _optimumEndIndex:=0;
 _optimumCurrentIndex:=0;
 _additionalOffset:=0;
end;

function TLZMAEncoder.ReadMatchDistances:TpvInt32;
begin
 result:=0;
 _numDistancePairs:=_matchFinder.GetMatches(_matchDistances);
 if _numDistancePairs>0 then begin
  result:=_matchDistances[_numDistancePairs-2];
  if result=_numFastBytes then begin
   inc(result,_matchFinder.GetMatchLen(result-1,_matchDistances[_numDistancePairs-1],kMatchMaxLen-result));
  end;
 end;
 inc(_additionalOffset);
end;

procedure TLZMAEncoder.MovePos(const num:TpvInt32);
begin
 if num>0 then begin
  _matchFinder.Skip(num);
  _additionalOffset:=_additionalOffset+num;
 end;
end;

function TLZMAEncoder.GetRepLen1Price(const state,posState:TpvInt32):TpvInt32;
begin
 result:=RangeEncoder.GetPrice0(_isRepG0[state])+RangeEncoder.GetPrice0(_isRep0Long[(state shl kNumPosStatesBitsMax)+posState]);
end;

function TLZMAEncoder.GetPureRepPrice(const repIndex,state,posState:TpvInt32):TpvInt32;
begin
 if repIndex=0 then begin
  result:=RangeEncoder.GetPrice0(_isRepG0[state]);
  inc(result,RangeEncoder.GetPrice1(_isRep0Long[(state shl kNumPosStatesBitsMax)+posState]));
 end else begin
  result:=RangeEncoder.GetPrice1(_isRepG0[state]);
  if repIndex=1 then begin
   inc(result,RangeEncoder.GetPrice0(_isRepG1[state]));
  end else begin
   inc(result,RangeEncoder.GetPrice1(_isRepG1[state]));
   inc(result,RangeEncoder.GetPrice(_isRepG2[state],repIndex-2));
  end;
 end;
end;

function TLZMAEncoder.GetRepPrice(const repIndex,len,state,posState:TpvInt32):TpvInt32;
begin
 result:=_repMatchLenEncoder.GetPrice(len-kMatchMinLen,posState);
 inc(result,GetPureRepPrice(repIndex,state,posState));
end;

function TLZMAEncoder.GetPosLenPrice(const pos,len,posState:TpvInt32):TpvInt32;
var lenToPosState:TpvInt32;
begin
 lenToPosState:=GetLenToPosState(len);
 if pos<kNumFullDistances then begin
  result:=_distancesPrices[(lenToPosState*kNumFullDistances)+pos];
 end else begin
  result:=_posSlotPrices[(lenToPosState shl kNumPosSlotBits)+GetPosSlot2(pos)]+_alignPrices[pos and kAlignMask];
 end;
 result:=result+_lenEncoder.GetPrice(len-kMatchMinLen,posState);
end;

function TLZMAEncoder.Backward(cur:TpvInt32):TpvInt32;
var posMem,backMem,posPrev,backCur:TpvInt32;
begin
 _optimumEndIndex:=cur;
 posMem:=_optimum[cur].PosPrev;
 backMem:=_optimum[cur].BackPrev;
 repeat
  if _optimum[cur].Prev1IsChar then begin
   _optimum[posMem].MakeAsChar;
   _optimum[posMem].PosPrev:=posMem-1;
   if _optimum[cur].Prev2 then begin
    _optimum[posMem-1].Prev1IsChar:=false;
    _optimum[posMem-1].PosPrev:=_optimum[cur].PosPrev2;
    _optimum[posMem-1].BackPrev:=_optimum[cur].BackPrev2;
   end;
  end;
  posPrev:=posMem;
  backCur:=backMem;
  backMem:=_optimum[posPrev].BackPrev;
  posMem :=_optimum[posPrev].PosPrev;
  _optimum[posPrev].BackPrev:=backCur;
  _optimum[posPrev].PosPrev:=cur;
  cur:=posPrev;
 until not (cur>0);
 backRes:=_optimum[0].BackPrev;
 _optimumCurrentIndex:=_optimum[0].PosPrev;
 result:=_optimumCurrentIndex;
end;

function TLZMAEncoder.GetOptimum(position:TpvInt32):TpvInt32;
var lenRes,lenMain,numDistancePairs,numAvailableBytes,repMaxIndex,i,state,pos,
    matchPrice,repMatchPrice,shortRepPrice,lenEnd,len,repLen,price,posPrev,cur,
    curPrice,curAndLenPrice,normalMatchPrice,Offs,distance,newLen,curAnd1Price,
    numAvailableBytesFull,lenTest2,t,state2,posStateNext,nextRepMatchPrice,
    offset,startLen,repIndex,lenTest,lenTestTemp,curAndLenCharPrice,
    nextMatchPrice,curBack:TpvInt32;
    optimum,opt,nextOptimum:TLZMAOptimal;
    currentByte,matchByte,posState:TpvUInt8;
    nextIsChar:boolean;
begin
 if _optimumEndIndex<>_optimumCurrentIndex then begin
  lenRes:=_optimum[_optimumCurrentIndex].PosPrev-_optimumCurrentIndex;
  backRes:=_optimum[_optimumCurrentIndex].BackPrev;
  _optimumCurrentIndex:=_optimum[_optimumCurrentIndex].PosPrev;
  result:=lenRes;
  exit;
 end;
 _optimumCurrentIndex:=0;
 _optimumEndIndex:=0;
 if not _longestMatchWasFound then begin
  lenMain:=ReadMatchDistances;
 end else begin
  lenMain:=_longestMatchLength;
  _longestMatchWasFound:=false;
 end;
 numDistancePairs:=_numDistancePairs;
 numAvailableBytes:=_matchFinder.GetNumAvailableBytes+1;
 if numAvailableBytes<2 then begin
  backRes:=-1;
  result :=1;
  exit;
 end;
{if numAvailableBytes>kMatchMaxLen then begin
  numAvailableBytes:=kMatchMaxLen;
 end;}
 repMaxIndex:=0;
 for i:=0 to kNumRepDistances-1 do begin
  reps[i]:=_repDistances[i];
  repLens[i]:=_matchFinder.GetMatchLen(0-1,reps[i],kMatchMaxLen);
  if repLens[i]>repLens[repMaxIndex] then begin
   repMaxIndex:=i;
  end;
 end;
 if repLens[repMaxIndex]>=_numFastBytes then begin
  backRes:=repMaxIndex;
  lenRes:=repLens[repMaxIndex];
  MovePos(lenRes-1);
  result:=lenRes;
  exit;
 end;
 if lenMain>=_numFastBytes then begin
  backRes:=_matchDistances[numDistancePairs-1]+kNumRepDistances;
  MovePos(lenMain-1);
  result:=lenMain;
  exit;
 end;
 currentByte:=_matchFinder.GetIndexByte(0-1);
 matchByte:=_matchFinder.GetIndexByte(0-_repDistances[0]-1-1);
 if (lenMain<2) and (currentByte<>matchByte) and (repLens[repMaxIndex]<2) then begin
  backRes:=-1;
  result:=1;
  exit;
 end;
 _optimum[0].State:=_state;
 posState:=position and _posStateMask;
 _optimum[1].Price:=RangeEncoder.GetPrice0(_isMatch[(_state shl kNumPosStatesBitsMax)+posState])+_literalEncoder.GetSubCoder(position,_previousByte).GetPrice(not StateIsCharState(_state),matchByte,currentByte);
 _optimum[1].MakeAsChar;
 matchPrice:=RangeEncoder.GetPrice1(_isMatch[(_state shl kNumPosStatesBitsMax)+posState]);
 repMatchPrice:=matchPrice+RangeEncoder.GetPrice1(_isRep[_state]);
 if matchByte=currentByte then begin
  shortRepPrice:=repMatchPrice+GetRepLen1Price(_state,posState);
  if shortRepPrice<_optimum[1].Price then begin
   _optimum[1].Price:=shortRepPrice;
   _optimum[1].MakeAsShortRep;
  end;
 end;
 if lenMain>=repLens[repMaxIndex] then begin
  lenEnd:=lenMain;
 end else begin
  lenEnd:=repLens[repMaxIndex];
 end;
 if lenEnd<2 then begin
  backRes:=_optimum[1].BackPrev;
  result :=1;
  exit;
 end;
 _optimum[1].PosPrev:=0;
 _optimum[0].Backs0:=reps[0];
 _optimum[0].Backs1:=reps[1];
 _optimum[0].Backs2:=reps[2];
 _optimum[0].Backs3:=reps[3];
 len:=lenEnd;
 repeat
  _optimum[len].Price:=kIfinityPrice;
  dec(len);
 until not (len>=2);
 for i:=0 to kNumRepDistances-1 do begin
  repLen:=repLens[i];
  if repLen<2 then begin
   continue;
  end;
  price:=repMatchPrice+GetPureRepPrice(i,_state,posState);
  repeat
   curAndLenPrice:=price+_repMatchLenEncoder.GetPrice(repLen-2,posState);
   optimum:=_optimum[repLen];
   if curAndLenPrice<optimum.Price then begin
    optimum.Price:=curAndLenPrice;
    optimum.PosPrev:=0;
    optimum.BackPrev:=i;
    optimum.Prev1IsChar:=false;
   end;
   dec(replen);
  until not (repLen>=2);
 end;
 normalMatchPrice:=matchPrice+RangeEncoder.GetPrice0(_isRep[_state]);
 if repLens[0]>=2 then begin
  len:=repLens[0]+1;
 end else begin
  len:=2;
 end;
 if len<=lenMain then begin
  offs:=0;
  while len>_matchDistances[offs] do begin
   inc(offs,2);
  end;
  while true do begin
   distance:=_matchDistances[offs+1];
   curAndLenPrice:=normalMatchPrice+GetPosLenPrice(distance,len,posState);
   optimum :=_optimum[len];
   if curAndLenPrice<optimum.Price then begin
    optimum.Price:=curAndLenPrice;
    optimum.PosPrev:=0;
    optimum.BackPrev:=distance+kNumRepDistances;
    optimum.Prev1IsChar:=false;
   end;
   if len=_matchDistances[offs] then begin
    inc(offs,2);
    if offs=numDistancePairs then begin
     break;
    end;
   end;
   inc(len);
  end;
 end;
 cur:=0;
 while true do begin
  inc(cur);
  if cur=lenEnd then begin
   result:=Backward(cur);
   exit;
  end;
  newLen:=ReadMatchDistances;
  numDistancePairs:=_numDistancePairs;
  if newLen>=_numFastBytes then begin
   _longestMatchLength:=newLen;
   _longestMatchWasFound:=true;
   result:=Backward(cur);
   exit;
  end;
  inc(position);
  posPrev:=_optimum[cur].PosPrev;
  if _optimum[cur].Prev1IsChar then begin
   dec(posPrev);
   if _optimum[cur].Prev2 then begin
    state:=_optimum[_optimum[cur].PosPrev2].State;
    if _optimum[cur].BackPrev2<kNumRepDistances then begin
     state:=StateUpdateRep(state);
    end else begin
     state:=StateUpdateMatch(state);
    end;
   end else begin
    state:=_optimum[posPrev].State;
   end;
   state:=StateUpdateChar(state);
  end else begin
   state:=_optimum[posPrev].State;
  end;
  if posPrev=cur-1 then begin
   if _optimum[cur].IsShortRep then begin
    state:=StateUpdateShortRep(state);
   end else begin
    state:=StateUpdateChar(state);
   end;
  end else begin
   if _optimum[cur].Prev1IsChar and _optimum[cur].Prev2 then begin
    posPrev:=_optimum[cur].PosPrev2;
    pos:=_optimum[cur].BackPrev2;
    state:=StateUpdateRep(state);
   end else begin
    pos:=_optimum[cur].BackPrev;
    if pos<kNumRepDistances then begin
     state:=StateUpdateRep(state);
    end else begin
     state:=StateUpdateMatch(state);
    end;
   end;
   opt:=_optimum[posPrev];
   if pos<kNumRepDistances then begin
    if pos=0 then begin
     reps[0]:=opt.Backs0;
     reps[1]:=opt.Backs1;
     reps[2]:=opt.Backs2;
     reps[3]:=opt.Backs3;
    end else if pos=1 then begin
     reps[0]:=opt.Backs1;
     reps[1]:=opt.Backs0;
     reps[2]:=opt.Backs2;
     reps[3]:=opt.Backs3;
    end else if pos=2 then begin
     reps[0]:=opt.Backs2;
     reps[1]:=opt.Backs0;
     reps[2]:=opt.Backs1;
     reps[3]:=opt.Backs3;
    end else begin
     reps[0]:=opt.Backs3;
     reps[1]:=opt.Backs0;
     reps[2]:=opt.Backs1;
     reps[3]:=opt.Backs2;
    end;
   end else begin
    reps[0]:=pos-kNumRepDistances;
    reps[1]:=opt.Backs0;
    reps[2]:=opt.Backs1;
    reps[3]:=opt.Backs2;
   end;
  end;
  _optimum[cur].State:=state;
  _optimum[cur].Backs0:=reps[0];
  _optimum[cur].Backs1:=reps[1];
  _optimum[cur].Backs2:=reps[2];
  _optimum[cur].Backs3:=reps[3];
  curPrice:=_optimum[cur].Price;
  currentByte:=_matchFinder.GetIndexByte(0-1);
  matchByte:=_matchFinder.GetIndexByte(0-reps[0]-1-1);
  posState:=(position and _posStateMask);
  curAnd1Price:=curPrice+
   RangeEncoder.GetPrice0(_isMatch[(state shl kNumPosStatesBitsMax)+posState])+
   _literalEncoder.GetSubCoder(position,_matchFinder.GetIndexByte(0-2)).
   GetPrice(not StateIsCharState(state),matchByte,currentByte);
  nextOptimum:=_optimum[cur+1];
  nextIsChar:=false;
  if curAnd1Price<nextOptimum.Price then begin
   nextOptimum.Price:=curAnd1Price;
   nextOptimum.PosPrev:=cur;
   nextOptimum.MakeAsChar;
   nextIsChar:=true;
  end;
  matchPrice:=curPrice+RangeEncoder.GetPrice1(_isMatch[(state shl kNumPosStatesBitsMax)+posState]);
  repMatchPrice:=matchPrice+RangeEncoder.GetPrice1(_isRep[state]);
  if (matchByte=currentByte) and (not ((nextOptimum.PosPrev<cur) and (nextOptimum.BackPrev=0))) then begin
   shortRepPrice:=repMatchPrice+GetRepLen1Price(state,posState);
   if shortRepPrice<=nextOptimum.Price then begin
    nextOptimum.Price:=shortRepPrice;
    nextOptimum.PosPrev:=cur;
    nextOptimum.MakeAsShortRep;
    nextIsChar:=true;
   end;
  end;
  numAvailableBytesFull:=_matchFinder.GetNumAvailableBytes+1;
  if (kNumOpts-1-cur)<numAvailableBytesFull then begin
   numAvailableBytesFull:=kNumOpts-1-cur;
  end;
  numAvailableBytes:=numAvailableBytesFull;
  if numAvailableBytes<2 then begin
   continue;
  end;
  if numAvailableBytes>_numFastBytes then begin
   numAvailableBytes:=_numFastBytes;
  end;
  if (not nextIsChar) and (matchByte<>currentByte) then begin
   if (numAvailableBytesFull-1)<_numFastBytes then begin
    t:=numAvailableBytesFull-1;
   end else begin
    t:=_numFastBytes;
   end;
   lenTest2:=_matchFinder.GetMatchLen(0,reps[0],t);
   if lenTest2>=2 then  begin
    state2:=StateUpdateChar(state);
    posStateNext:=(position+1) and _posStateMask;
    nextRepMatchPrice:=curAnd1Price+RangeEncoder.GetPrice1(_isMatch[(state2 shl kNumPosStatesBitsMax)+posStateNext])+RangeEncoder.GetPrice1(_isRep[state2]);
    offset:=cur+1+lenTest2;
    while lenEnd<offset do begin
     inc(lenEnd);
     _optimum[lenEnd].Price:=kIfinityPrice;
    end;
    curAndLenPrice:=nextRepMatchPrice+GetRepPrice(0,lenTest2,state2,posStateNext);
    optimum:=_optimum[offset];
    if curAndLenPrice<optimum.Price then begin
     optimum.Price:=curAndLenPrice;
     optimum.PosPrev:=cur+1;
     optimum.BackPrev:=0;
     optimum.Prev1IsChar:=true;
     optimum.Prev2:=false;
    end;
   end;
  end;
  startLen:=2;
  for repIndex:=0 to kNumRepDistances-1 do begin
   lenTest:=_matchFinder.GetMatchLen(0-1,reps[repIndex],numAvailableBytes);
   if lenTest<2 then begin
    continue;
   end;
   lenTestTemp:=lenTest;
   repeat
    while lenEnd<cur+lenTest do begin
     inc(lenEnd);
     _optimum[lenEnd].Price:=kIfinityPrice;
    end;
    curAndLenPrice:=repMatchPrice+GetRepPrice(repIndex,lenTest,state,posState);
    optimum:=_optimum[cur+lenTest];
    if curAndLenPrice<optimum.Price then begin
     optimum.Price:=curAndLenPrice;
     optimum.PosPrev:=cur;
     optimum.BackPrev:=repIndex;
     optimum.Prev1IsChar:=false;
    end;
    dec(lenTest);
   until not (lenTest>=2);
   lenTest:=lenTestTemp;
   if repIndex=0 then begin
    startLen:=lenTest+1;
   end;
   if lenTest<numAvailableBytesFull then begin
    t:=numAvailableBytesFull-1-lenTest;
    if _numFastBytes<t then begin
     t:=_numFastBytes;
    end;
    lenTest2:=_matchFinder.GetMatchLen(lenTest,reps[repIndex],t);
    if lenTest2>=2 then begin
     state2:=StateUpdateRep(state);
     posStateNext:=(position+lenTest) and _posStateMask;
     curAndLenCharPrice:=repMatchPrice+GetRepPrice(repIndex,lenTest,state,posState)+RangeEncoder.GetPrice0(_isMatch[(state2 shl kNumPosStatesBitsMax)+posStateNext])+_literalEncoder.GetSubCoder(position+lenTest,_matchFinder.GetIndexByte(lenTest-1-1)).GetPrice(true,_matchFinder.GetIndexByte(lenTest-1-(reps[repIndex]+1)),_matchFinder.GetIndexByte(lenTest-1));
     state2:=StateUpdateChar(state2);
     posStateNext:=(position+lenTest+1) and _posStateMask;
     nextMatchPrice:=curAndLenCharPrice+RangeEncoder.GetPrice1(_isMatch[(state2 shl kNumPosStatesBitsMax)+posStateNext]);
     nextRepMatchPrice:=nextMatchPrice+RangeEncoder.GetPrice1(_isRep[state2]);
     offset:=lenTest+1+lenTest2;
     while lenEnd<cur+offset do begin
      inc(lenEnd);
      _optimum[lenEnd].Price:=kIfinityPrice;
     end;
     curAndLenPrice:=nextRepMatchPrice+GetRepPrice(0,lenTest2,state2,posStateNext);
     optimum:=_optimum[cur+offset];
     if curAndLenPrice<optimum.Price then begin
      optimum.Price:=curAndLenPrice;
      optimum.PosPrev:=cur+lenTest+1;
      optimum.BackPrev:=0;
      optimum.Prev1IsChar:=true;
      optimum.Prev2:=true;
      optimum.PosPrev2:=cur;
      optimum.BackPrev2:=repIndex;
     end;
    end;
   end;
  end;
  if newLen>numAvailableBytes then begin
   newLen:=numAvailableBytes;
   numDistancePairs:=0;
   while newLen>_matchDistances[numDistancePairs] do begin
    inc(numDistancePairs,2);
   end;
   _matchDistances[numDistancePairs]:=newLen;
   numDistancePairs:=numDistancePairs+2;
  end;
  if newLen>=startLen then begin
   normalMatchPrice:=matchPrice+RangeEncoder.GetPrice0(_isRep[state]);
   while lenEnd<cur+newLen do begin
    inc(lenEnd);
    _optimum[lenEnd].Price:=kIfinityPrice;
   end;
   offs:=0;
   while startLen>_matchDistances[offs] do begin
    inc(offs,2);
   end;
   lenTest:=startLen;
   while true do begin
    curBack:=_matchDistances[offs+1];
    curAndLenPrice:=normalMatchPrice+GetPosLenPrice(curBack,lenTest,posState);
    optimum:=_optimum[cur+lenTest];
    if curAndLenPrice<optimum.Price then begin
     optimum.Price:=curAndLenPrice;
     optimum.PosPrev:=cur;
     optimum.BackPrev:=curBack+kNumRepDistances;
     optimum.Prev1IsChar:=false;
    end;
    if lenTest=_matchDistances[offs] then begin
     if lenTest<numAvailableBytesFull then begin
      t:=numAvailableBytesFull-1-lenTest;
      if _numFastBytes<t then begin
       t:=_numFastBytes;
      end;
      lenTest2:=_matchFinder.GetMatchLen(lenTest,curBack,t);
      if lenTest2>=2 then begin
       state2:=StateUpdateMatch(state);
       posStateNext:=(position+lenTest) and _posStateMask;
       curAndLenCharPrice:=curAndLenPrice+RangeEncoder.GetPrice0(_isMatch[(state2 shl kNumPosStatesBitsMax)+posStateNext])+_literalEncoder.GetSubCoder(position+lenTest,_matchFinder.GetIndexByte(lenTest-1-1)).GetPrice(true,_matchFinder.GetIndexByte(lenTest-(curBack+1)-1),_matchFinder.GetIndexByte(lenTest-1));
       state2:=StateUpdateChar(state2);
       posStateNext:=(position+lenTest+1) and _posStateMask;
       nextMatchPrice:=curAndLenCharPrice+RangeEncoder.GetPrice1(_isMatch[(state2 shl kNumPosStatesBitsMax)+posStateNext]);
       nextRepMatchPrice:=nextMatchPrice+RangeEncoder.GetPrice1(_isRep[state2]);
       offset:=lenTest+1+lenTest2;
       while lenEnd<cur+offset do begin
        inc(lenEnd);
        _optimum[lenEnd].Price:=kIfinityPrice;
       end;
       curAndLenPrice:=nextRepMatchPrice+GetRepPrice(0,lenTest2,state2,posStateNext);
       optimum:=_optimum[cur+offset];
       if curAndLenPrice<optimum.Price then begin
        optimum.Price:=curAndLenPrice;
        optimum.PosPrev:=cur+lenTest+1;
        optimum.BackPrev:=0;
        optimum.Prev1IsChar:=true;
        optimum.Prev2:=true;
        optimum.PosPrev2:=cur;
        optimum.BackPrev2:=curBack+kNumRepDistances;
       end;
      end;
     end;
     inc(offs,2);
     if offs=numDistancePairs then begin
      break;
     end;
    end;
    inc(lenTest);
   end;
  end;
 end;
end;

function TLZMAEncoder.ChangePair(const smallDist,bigDist:TpvInt32):boolean;
var kDif:TpvInt32;
begin
 kDif:=7;
 result:=(smallDist<(1 shl (32-kDif))) and (bigDist>=(smallDist shl kDif));
end;

procedure TLZMAEncoder.WriteEndMarker(const posState:TpvInt32);
var len,posSlot,lenToPosState,footerBits,posReduced:TpvInt32;
begin
 if not _writeEndMark then begin
  exit;
 end;
 _rangeEncoder.Encode(_isMatch,(_state shl kNumPosStatesBitsMax)+posState,1);
 _rangeEncoder.Encode(_isRep,_state,0);
 _state:=StateUpdateMatch(_state);
 len:=kMatchMinLen;
 _lenEncoder.Encode(_rangeEncoder,len-kMatchMinLen,posState);
 posSlot:=(1 shl kNumPosSlotBits)-1;
 lenToPosState:=GetLenToPosState(len);
 _posSlotEncoder[lenToPosState].Encode(_rangeEncoder,posSlot);
 footerBits:=30;
 posReduced:=(1 shl footerBits)-1;
 _rangeEncoder.EncodeDirectBits(posReduced shr kNumAlignBits,footerBits-kNumAlignBits);
 _posAlignEncoder.ReverseEncode(_rangeEncoder,posReduced and kAlignMask);
end;

procedure TLZMAEncoder.Flush(const nowPos:TpvInt32);
begin
 ReleaseMFStream;
 WriteEndMarker(nowPos and _posStateMask);
 _rangeEncoder.FlushData;
 _rangeEncoder.FlushStream;
end;

procedure TLZMAEncoder.CodeOneBlock(var inSize,outSize:TpvInt64;var finished:boolean);
var progressPosValuePrev:TpvInt64;
    posState,len,pos,complexState,distance,i,posSlot,lenToPosState,footerBits,
    baseVal,posReduced:TpvInt32;
    curByte,matchByte:TpvUInt8;
    subcoder:TLZMAEncoder2;
begin
 inSize:=0;
 outSize:=0;
 finished:=true;
 if assigned(_inStream) then begin
  _matchFinder.SetStream(_inStream);
  _matchFinder.Init;
  _needReleaseMFStream:=true;
  _inStream:=nil;
 end;
 if _finished then begin
  exit;
 end;
 _finished:=true;
 progressPosValuePrev:=nowPos64;
 if nowPos64=0 then begin
  if _matchFinder.GetNumAvailableBytes=0 then begin
   Flush(nowPos64);
   exit;
  end;
  ReadMatchDistances;
  posState:=TpvInt32(nowPos64) and _posStateMask;
  _rangeEncoder.Encode(_isMatch,(_state shl kNumPosStatesBitsMax)+posState,0);
  _state:=StateUpdateChar(_state);
  curByte:=_matchFinder.GetIndexByte(0-_additionalOffset);
  _literalEncoder.GetSubCoder(TpvInt32(nowPos64),_previousByte).Encode(_rangeEncoder,curByte);
  _previousByte:=curByte;
  dec(_additionalOffset);
  inc(nowPos64);
 end;
 if _matchFinder.GetNumAvailableBytes=0 then begin
  Flush(TpvInt32(nowPos64));
  exit;
 end;
 while true do begin
  len:=GetOptimum(TpvInt32(nowPos64));
  pos:=backRes;
  posState:=TpvInt32(nowPos64) and _posStateMask;
  complexState:=(_state shl kNumPosStatesBitsMax)+posState;
  if (len=1) and (pos=-1) then begin
   _rangeEncoder.Encode(_isMatch,complexState,0);
   curByte:=_matchFinder.GetIndexByte(0-_additionalOffset);
   subCoder:=_literalEncoder.GetSubCoder(TpvInt32(nowPos64),_previousByte);
   if not StateIsCharState(_state) then begin
    matchByte:=_matchFinder.GetIndexByte(0-_repDistances[0]-1-_additionalOffset);
    subCoder.EncodeMatched(_rangeEncoder,matchByte,curByte);
   end else begin
    subCoder.Encode(_rangeEncoder,curByte);
   end;
   _previousByte:=curByte;
   _state:=StateUpdateChar(_state);
  end else begin
   _rangeEncoder.Encode(_isMatch,complexState,1);
   if pos<kNumRepDistances then begin
    _rangeEncoder.Encode(_isRep,_state,1);
    if pos=0 then begin
     _rangeEncoder.Encode(_isRepG0,_state,0);
     if len=1 then begin
      _rangeEncoder.Encode(_isRep0Long,complexState,0);
     end else begin
      _rangeEncoder.Encode(_isRep0Long,complexState,1);
     end;
    end else begin
     _rangeEncoder.Encode(_isRepG0,_state,1);
     if pos=1 then begin
      _rangeEncoder.Encode(_isRepG1,_state,0);
     end else begin
      _rangeEncoder.Encode(_isRepG1,_state,1);
      _rangeEncoder.Encode(_isRepG2,_state,pos-2);
     end;
    end;
    if len=1 then begin
     _state:=StateUpdateShortRep(_state);
    end else begin
     _repMatchLenEncoder.Encode(_rangeEncoder,len-kMatchMinLen,posState);
     _state:=StateUpdateRep(_state);
    end;
    distance:=_repDistances[pos];
    if pos<>0 then begin
     for i:=pos downto 1 do begin
      _repDistances[i]:=_repDistances[i-1];
     end;
     _repDistances[0]:=distance;
    end;
   end else begin
    _rangeEncoder.Encode(_isRep,_state,0);
    _state:=StateUpdateMatch(_state);
    _lenEncoder.Encode(_rangeEncoder,len-kMatchMinLen,posState);
    pos:=pos-kNumRepDistances;
    posSlot:=GetPosSlot(pos);
    lenToPosState:=GetLenToPosState(len);
    _posSlotEncoder[lenToPosState].Encode(_rangeEncoder,posSlot);
    if posSlot>=kStartPosModelIndex then begin
     footerBits:=TpvInt32((posSlot shr 1)-1);
     baseVal:=((2 or (posSlot and 1)) shl footerBits);
     posReduced:=pos-baseVal;
     if posSlot<kEndPosModelIndex then begin
      ReverseEncode(_posEncoders,baseVal-posSlot-1,_rangeEncoder,footerBits,posReduced);
     end else begin
      _rangeEncoder.EncodeDirectBits(posReduced shr kNumAlignBits,footerBits-kNumAlignBits);
      _posAlignEncoder.ReverseEncode(_rangeEncoder,posReduced and kAlignMask);
      inc(_alignPriceCount);
     end;
    end;
    distance:=pos;
    for i:=kNumRepDistances-1 downto 1 do begin
     _repDistances[i]:=_repDistances[i-1];
    end;
    _repDistances[0]:=distance;
    inc(_matchPriceCount);
   end;
   _previousByte:=_matchFinder.GetIndexByte(len-1-_additionalOffset);
  end;
  _additionalOffset:=_additionalOffset-len;
  nowPos64:=nowPos64+len;
  if _additionalOffset=0 then begin
   if _matchPriceCount>=(1 shl 7) then begin
    FillDistancesPrices;
   end;
   if _alignPriceCount>=kAlignTableSize then begin
    FillAlignPrices;
   end;
   inSize:=nowPos64;
   outSize:=_rangeEncoder.GetProcessedSizeAdd;
   if _matchFinder.GetNumAvailableBytes=0 then begin
    Flush(TpvInt32(nowPos64));
    exit;
   end;
   if (nowPos64-progressPosValuePrev>=(1 shl 12)) then begin
    _finished:=false;
    finished :=false;
    exit;
   end;
  end;
 end;
end;

procedure TLZMAEncoder.ReleaseMFStream;
begin
 if (_matchFinder<>nil) and _needReleaseMFStream then begin
  _matchFinder.ReleaseStream;
  _needReleaseMFStream:=false;
 end;
end;

procedure TLZMAEncoder.SetOutStream(const outStream:TStream);
begin
 _rangeEncoder.SetStream(outStream);
end;

procedure TLZMAEncoder.ReleaseOutStream;
begin
 _rangeEncoder.ReleaseStream;
end;

procedure TLZMAEncoder.ReleaseStreams;
begin
 ReleaseMFStream;
 ReleaseOutStream;
end;

procedure TLZMAEncoder.SetStreams(const inStream,outStream:TStream;const inSize,outSize:TpvInt64);
begin
 _inStream:=inStream;
 _finished:=false;
 _Create;
 SetOutStream(outStream);
 Init;
 FillDistancesPrices;
 FillAlignPrices;
 _lenEncoder.SetTableSize(_numFastBytes+1-kMatchMinLen);
 _lenEncoder.UpdateTables(1 shl _posStateBits);
 _repMatchLenEncoder.SetTableSize(_numFastBytes+1-kMatchMinLen);
 _repMatchLenEncoder.UpdateTables(1 shl _posStateBits);
 nowPos64:=0;
end;

procedure TLZMAEncoder.Code(const inStream,outStream:TStream;const inSize,outSize:TpvInt64);
var lpos,progint,inputsize:TpvInt64;
begin
 if insize=-1 then begin
  inputsize:=instream.Size-instream.Position;
 end else begin
  inputsize:=insize;
 end;
 progint:=inputsize div CodeProgressInterval;
 lpos:=progint;
 _needReleaseMFStream:=false;
 DoProgress(TLZMAProgressAction.LPAMax,inputsize);
 try
  SetStreams(inStream,outStream,inSize,outSize);
  while true do begin
   CodeOneBlock(processedInSize,processedOutSize,finished);
   if finished then begin
    DoProgress(TLZMAProgressAction.LPAPos,inputsize);
    exit;
   end;
   if (processedInSize>=lpos) then begin
    DoProgress(TLZMAProgressAction.LPAPos,processedInSize);
    lpos:=lpos+progint;
   end;
  end;
 finally
  ReleaseStreams;
 end;
end;

procedure TLZMAEncoder.WriteCoderProperties(const outStream:TStream);
var i:TpvInt32;
begin
 properties[0]:=(_posStateBits*5+_numLiteralPosStateBits)*9+_numLiteralContextBits;
 for i:=0 to 3 do begin
  properties[1+i]:=(_dictionarySize shr (8*i));
 end;
 outStream.write(properties,kPropSize);
end;

procedure TLZMAEncoder.FillDistancesPrices;
var i,posSlot,footerBits,baseVal,lenToPosState,st,st2:TpvInt32;
    encoder:TBitTreeEncoder;
begin
 for i:=kStartPosModelIndex to kNumFullDistances-1 do begin
  posSlot:=GetPosSlot(i);
  footerBits:=TpvInt32((posSlot shr 1)-1);
  baseVal:=(2 or (posSlot and 1)) shl footerBits;
  tempPrices[i]:=ReverseGetPrice(_posEncoders,
  baseVal-posSlot-1,footerBits,i-baseVal);
 end;
 for lenToPosState:=0 to kNumLenToPosStates-1 do begin
  encoder:=_posSlotEncoder[lenToPosState];
  st:=(lenToPosState shl kNumPosSlotBits);
  for posSlot:=0 to _distTableSize-1 do begin
   _posSlotPrices[st+posSlot]:=encoder.GetPrice(posSlot);
  end;
  for posSlot:=kEndPosModelIndex to _distTableSize-1 do begin
   _posSlotPrices[st+posSlot]:=_posSlotPrices[st+posSlot]+((((posSlot shr 1)-1)-kNumAlignBits) shl kNumBitPriceShiftBits);
  end;
  st2:=lenToPosState*kNumFullDistances;
  for i:=0 to kStartPosModelIndex-1 do begin
   _distancesPrices[st2+i]:=_posSlotPrices[st+i];
  end;
  for i:=kStartPosModelIndex to kNumFullDistances-1 do begin
   _distancesPrices[st2+i]:=_posSlotPrices[st+GetPosSlot(i)]+tempPrices[i];
  end;
 end;
 _matchPriceCount:=0;
end;

procedure TLZMAEncoder.FillAlignPrices;
var i:TpvInt32;
begin
 for i:=0 to kAlignTableSize-1 do begin
  _alignPrices[i]:=_posAlignEncoder.ReverseGetPrice(i);
 end;
 _alignPriceCount:=0;
end;

function TLZMAEncoder.SetAlgorithm(const algorithm:TpvInt32):boolean;
begin
 result:=true;
end;

function TLZMAEncoder.SetDictionarySize(dictionarySize:TpvInt32):boolean;
var kDicLogSizeMaxCompress,dicLogSize:TpvInt32;
begin
 kDicLogSizeMaxCompress:=29;
 if (dictionarySize<(1 shl kDicLogSizeMin)) or (dictionarySize>(1 shl kDicLogSizeMaxCompress)) then begin
  result:=false;
  exit;
 end;
 _dictionarySize:=dictionarySize;
 dicLogSize:=0;
 while dictionarySize>(1 shl dicLogSize) do begin
  inc(dicLogSize);
 end;
 _distTableSize:=dicLogSize*2;
 result:=true;
end;

function TLZMAEncoder.SetNumFastBytes(const numFastBytes:TpvInt32):boolean;
begin
 if (numFastBytes<5) or (numFastBytes>kMatchMaxLen) then begin
  result:=false;
  exit;
 end;
 _numFastBytes:=numFastBytes;
 result:=true;
end;

function TLZMAEncoder.SetMatchFinder(const matchFinderIndex:TpvInt32):boolean;
var matchFinderIndexPrev:TpvInt32;
begin
 if (matchFinderIndex<0) or (matchFinderIndex>2) then begin
  result:=false;
  exit;
 end;
 matchFinderIndexPrev:=_matchFinderType;
 _matchFinderType:=matchFinderIndex;
 if (_matchFinder<>nil) and (matchFinderIndexPrev<>_matchFinderType) then begin
  _dictionarySizePrev:=-1;
  _matchFinder:=nil;
 end;
 result:=true;
end;

function TLZMAEncoder.SetLcLpPb(const lc,lp,pb:TpvInt32):boolean;
begin
 if (lp<0) or (lp>kNumLitPosStatesBitsEncodingMax) or (lc<0) or (lc>kNumLitContextBitsMax) or (pb<0) or (pb>kNumPosStatesBitsEncodingMax) then begin
  result:=false;
  exit;
 end;
 _numLiteralPosStateBits:=lp;
 _numLiteralContextBits:=lc;
 _posStateBits:=pb;
 _posStateMask:=((1) shl _posStateBits)-1;
 result:=true;
end;

procedure TLZMAEncoder.SetEndMarkerMode(const endMarkerMode:boolean);
begin
 _writeEndMark:=endMarkerMode;
end;

procedure TLZMAEncoder2.Init;
begin
 InitBitModels(m_Encoders);
end;

procedure TLZMAEncoder2.Encode(const rangeEncoder:TRangeEncoder;const symbol:TpvUInt8);
var context,bit,i:TpvInt32;
begin
 context:=1;
 for i:=7 downto 0 do begin
  bit:=((symbol shr i) and 1);
  rangeEncoder.Encode(m_Encoders,context,bit);
  context:=(context shl 1) or bit;
 end;
end;

procedure TLZMAEncoder2.EncodeMatched(const rangeEncoder:TRangeEncoder;const matchByte,symbol:TpvUInt8);
var context,i,bit,state,matchbit:TpvInt32;
    same:boolean;
begin
 context:=1;
 same:=true;
 for i:=7 downto 0 do begin
  bit:=((symbol shr i) and 1);
  state:=context;
  if same then begin
   matchBit:=((matchByte shr i) and 1);
   state:=state+((1+matchBit) shl 8);
   same :=(matchBit=bit);
  end;
  rangeEncoder.Encode(m_Encoders,state,bit);
  context:=(context shl 1) or bit;
 end;
end;

function TLZMAEncoder2.GetPrice(const matchMode:boolean;const matchByte,symbol:TpvUInt8):TpvInt32;
var price,context,i,matchbit,bit:TpvInt32;
begin
 price:=0;
 context:=1;
 i:=7;
 if matchMode then begin
  while i>=0 do begin
   matchBit:=(matchByte shr i) and 1;
   bit:=(symbol shr i) and 1;
   price:=price+RangeEncoder.GetPrice(m_Encoders[((1+matchBit) shl 8)+context],bit);
   context:=(context shl 1) or bit;
   if matchBit<>bit then begin
    dec(i);
    break;
   end;
   dec(i);
  end;
 end;
 while i>=0 do begin
  bit:=(symbol shr i) and 1;
  price:=price+RangeEncoder.GetPrice(m_Encoders[context],bit);
  context:=(context shl 1) or bit;
  dec(i);
 end;
 result:=price;
end;

procedure TLZMALiteralEncoder._Create(const numPosBits,numPrevBits:TpvInt32);
var numstates,i:TpvInt32;
begin
 if (length(m_Coders)<>0) and (m_NumPrevBits=numPrevBits) and (m_NumPosBits=numPosBits) then begin
  exit;
 end;
 m_NumPosBits:=numPosBits;
 m_PosMask:=(1 shl numPosBits)-1;
 m_NumPrevBits:=numPrevBits;
 numStates:=1 shl (m_NumPrevBits+m_NumPosBits);
 setlength(m_coders,numStates);
 for i:=0 to numStates-1 do begin
  m_Coders[i]:=TLZMAEncoder2.Create;
 end;
end;

destructor TLZMALiteralEncoder.Destroy;
var i:TpvInt32;
begin
 for i:=low(m_Coders) to high(m_Coders) do begin
  if assigned(m_Coders[i]) then begin
   m_Coders[i].Free;
  end;
 end;
 inherited Destroy;
end;

procedure TLZMALiteralEncoder.Init;
var numstates,i:TpvInt32;
begin
 numStates:=1 shl (m_NumPrevBits+m_NumPosBits);
 for i:=0 to numStates-1 do begin
  m_Coders[i].Init;
 end;
end;

function TLZMALiteralEncoder.GetSubCoder(const pos:TpvInt32;const prevByte:TpvUInt8):TLZMAEncoder2;
begin
 result:=m_Coders[((pos and m_PosMask) shl m_NumPrevBits)+((prevByte and $ff) shr (8-m_NumPrevBits))];
end;

constructor TLZMALenEncoder.Create;
var posState:TpvInt32;
begin
 _highCoder:=TBitTreeEncoder.Create(kNumHighLenBits);
 for posState:=0 to kNumPosStatesEncodingMax-1 do begin
  _lowCoder[posState]:=TBitTreeEncoder.Create(kNumLowLenBits);
  _midCoder[posState]:=TBitTreeEncoder.Create(kNumMidLenBits);
 end;
end;

destructor TLZMALenEncoder.Destroy;
var posState:TpvInt32;
begin
 _highCoder.Free;
 for posState:=0 to kNumPosStatesEncodingMax-1 do begin
  _lowCoder[posState].Free;
  _midCoder[posState].Free;
 end;
 inherited;
end;

procedure TLZMALenEncoder.Init(const numPosStates:TpvInt32);
var posState:TpvInt32;
begin
 InitBitModels(_choice);
 for posState:=0 to numPosStates-1 do begin
  _lowCoder[posState].Init;
  _midCoder[posState].Init;
 end;
 _highCoder.Init;
end;

procedure TLZMALenEncoder.Encode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32;const posState:TpvInt32);
begin
 if (symbol<kNumLowLenSymbols) then begin
  rangeEncoder.Encode(_choice,0,0);
  _lowCoder[posState].Encode(rangeEncoder,symbol);
 end else begin
  symbol:=symbol-kNumLowLenSymbols;
  rangeEncoder.Encode(_choice,0,1);
  if symbol<kNumMidLenSymbols then begin
   rangeEncoder.Encode(_choice,1,0);
   _midCoder[posState].Encode(rangeEncoder,symbol);
  end else begin
   rangeEncoder.Encode(_choice,1,1);
   _highCoder.Encode(rangeEncoder,symbol-kNumMidLenSymbols);
  end;
 end;
end;

procedure TLZMALenEncoder.SetPrices(const posState,numSymbols:TpvInt32;var prices:array of TpvInt32;const st:TpvInt32);
var a0,a1,b0,b1,i:TpvInt32;
begin
 a0:=RangeEncoder.GetPrice0(_choice[0]);
 a1:=RangeEncoder.GetPrice1(_choice[0]);
 b0:=a1+RangeEncoder.GetPrice0(_choice[1]);
 b1:=a1+RangeEncoder.GetPrice1(_choice[1]);
 i:=0;
 while i<kNumLowLenSymbols do begin
  if i>=numSymbols then begin
   exit;
  end;
  prices[st+i]:=a0+_lowCoder[posState].GetPrice(i);
  inc(i);
 end;
 while i<kNumLowLenSymbols+kNumMidLenSymbols do begin
  if i>=numSymbols then begin
   exit;
  end;
  prices[st+i]:=b0+_midCoder[posState].GetPrice(i-kNumLowLenSymbols);
  inc(i);
 end;
 while i<numSymbols do begin
  prices[st+i]:=b1+_highCoder.GetPrice(i-kNumLowLenSymbols-kNumMidLenSymbols);
  inc(i);
 end;
end;

procedure TLZMALenPriceTableEncoder.SetTableSize(const tableSize:TpvInt32);
begin
 _tableSize:=tableSize;
end;

function TLZMALenPriceTableEncoder.GetPrice(const symbol,posState:TpvInt32):TpvInt32;
begin
 result:=_prices[posState*kNumLenSymbols+symbol];
end;

procedure TLZMALenPriceTableEncoder.UpdateTable(const posState:TpvInt32);
begin
 SetPrices(posState,_tableSize,_prices,posState*kNumLenSymbols);
 _counters[posState]:=_tableSize;
end;

procedure TLZMALenPriceTableEncoder.UpdateTables(const numPosStates:TpvInt32);
var posState:TpvInt32;
begin
 for posState:=0 to numPosStates-1 do begin
  UpdateTable(posState);
 end;
end;

procedure TLZMALenPriceTableEncoder.Encode(const rangeEncoder:TRangeEncoder;symbol:TpvInt32;const posState:TpvInt32);
begin
 inherited Encode(rangeEncoder,symbol,posState);
 dec(_counters[posState]);
 if (_counters[posState]=0) then begin
  UpdateTable(posState);
 end;
end;

procedure TLZMAOptimal.MakeAsChar;
begin
 BackPrev:=-1;
 Prev1IsChar:=false;
end;

procedure TLZMAOptimal.MakeAsShortRep;
begin
 BackPrev:=0;
 Prev1IsChar:=false;
end;

function TLZMAOptimal.IsShortRep:boolean;
begin
 result:=BackPrev=0;
end;

procedure TLZMAEncoder.DoProgress(const Action:TLZMAProgressAction;const Value:TpvInt64);
begin
 if assigned(fOnProgress) then begin
  fOnProgress(Action,Value);
 end;
end;

const LZMA_BASE_SIZE=1846;
      LZMA_LIT_SIZE=768;

      LZMA_PROPERTIES_SIZE=5;

      LZMA_RESULT_OK=true;
      LZMA_RESULT_DATA_ERROR=false;

type TLZMAPropertiesArray=array[0..LZMA_PROPERTIES_SIZE-1] of TpvUInt8;
     PLZMAPropertiesArray=^TLZMAPropertiesArray;

     PLZMASizeArray=^TLZMASizeArray;
     TLZMASizeArray=array[0..7] of TpvUInt8;

     TLZMAProperties=packed record
      lc,LiteralPosition,PositionState:TpvInt32;
     end;
     PLZMAProperties=^TLZMAProperties;

     TLZMADecoderState=packed record
      Properties:TLZMAProperties;
      Probs:pointer;
     end;
     PLZMADecoderState=^TLZMADecoderState;

const kNumTopBits=24;
      kTopValue=1 shl kNumTopBits;

{     kNumBitModelTotalBits=11;
      kBitModelTotal=1 shl kNumBitModelTotalBits;
      kNumMoveBits=5;}

      kNumPosBitsMax=4;
//    kNumPosStatesMax=1 shl kNumPosBitsMax;

      kLenNumLowBits=3;
      kLenNumLowSymbols=1 shl kLenNumLowBits;

      kLenNumMidBits=3;
      kLenNumMidSymbols=1 shl kLenNumMidBits;

      kLenNumHighBits=8;
      kLenNumHighSymbols=1 shl kLenNumHighBits;

      LenChoice=0;
      LenChoice2=LenChoice+1;
      LenLow=LenChoice2+1;
      LenMid=LenLow+(kNumPosStatesMax shl kLenNumLowBits);
      LenHigh=LenMid+(kNumPosStatesMax shl kLenNumMidBits);
      kNumLenProbs=LenHigh+kLenNumHighSymbols;

//    kNumStates=12;
      kNumLitStates=7;

{     kStartPosModelIndex=4;
      kEndPosModelIndex=14;
      kNumFullDistances=1 shl (kEndPosModelIndex shr 1);}

{     kNumPosSlotBits=6;
      kNumLenToPosStates=4;}

{     kNumAlignBits=4;
      kAlignTableSize=1 shl kNumAlignBits;}

//    kMatchMinLen=2;

      IsMatch=0;
      IsRep=IsMatch+(kNumStates shl kNumPosBitsMax);
      IsRepG0=IsRep+kNumStates;
      IsRepG1=IsRepG0+kNumStates;
      IsRepG2=IsRepG1+kNumStates;
      IsRep0Long=IsRepG2+kNumStates;
      PosSlot=IsRep0Long+(kNumStates shl kNumPosBitsMax);
      SpecPos=PosSlot+(kNumLenToPosStates shl kNumPosSlotBits);
      Align=SpecPos+kNumFullDistances-kEndPosModelIndex;
      LenCoder=Align+kAlignTableSize;
      RepLenCoder=LenCoder+kNumLenProbs;
      Literal=RepLenCoder+kNumLenProbs;

      kLZMAStreamWasFinishedId=-1;

type TLZMARangeDecoder=packed record
      Buffer,BufferLim:PpvUInt8;
      Range,Code:TpvUInt32;
      ExtraBytes:TpvInt32;
     end;

function LZMAGetNumProbs(const Properties:TLZMAProperties):TpvUInt32;
begin
 result:=LZMA_BASE_SIZE+(LZMA_LIT_SIZE shl (Properties.lc+Properties.LiteralPosition));
end;

function RangeDecoderReadByte(var Instance:TLZMARangeDecoder):TpvUInt8;
begin
 if Instance.Buffer=Instance.BufferLim then begin
  Instance.ExtraBytes:=1;
  result:=$ff;
  exit;
 end;
 result:=Instance.Buffer^;
 inc(Instance.Buffer);
end;

procedure RangeDecoderInit(var Instance:TLZMARangeDecoder;Stream:PpvUInt8;BufferSize:TpvUInt32);
var Counter:TpvInt32;
begin
 Instance.Buffer:=Stream;
 Instance.BufferLim:=pointer(TpvPtrUInt(TpvPtrUInt(Stream)+BufferSize));
 Instance.ExtraBytes:=0;
 Instance.Code:=0;
 Instance.Range:=$ffffffff;
 for Counter:=0 to 4 do begin
  Instance.Code:=(Instance.Code shl 8) or RangeDecoderReadByte(Instance);
 end;
end;

function RangeDecoderDecodeDirectBits(var Instance:TLZMARangeDecoder;TotalBits:TpvInt32):TpvUInt32;
var Range,Code:TpvUInt32;
    Counter:TpvInt32;
begin
 Range:=Instance.Range;
 Code:=Instance.Code;
 result:=0;
 for Counter:=1 to TotalBits do begin
  Range:=Range shr 1;
  result:=result shl 1;
  if Code>=Range then begin
   dec(Code,Range);
   result:=result or 1;
  end;
  if Range<kTopValue then begin
   Range:=Range shl 8;
   Code:=(Code shl 8) or RangeDecoderReadByte(Instance);
  end;
 end;
 Instance.Range:=Range;
 Instance.Code:=Code;
end;

function RangeDecoderBitDecode(var Instance:TLZMARangeDecoder;Prob:PpvUInt32):TpvInt32;
var Range,Code,Bound:TpvUInt32;
begin
 Range:=Instance.Range;
 Code:=Instance.Code;
 Bound:=(Range shr kNumBitModelTotalBits)*Prob^;
 if Code<Bound then begin
  Range:=Bound;
  inc(Prob^,(kBitModelTotal-Prob^) shr kNumMoveBits);
  result:=0;
 end else begin
  dec(Code,Bound);
  dec(Range,Bound);
  dec(Prob^,Prob^ shr kNumMoveBits);
  result:=1;
 end;
 if Range<kTopValue then begin
  Code:=(Code shl 8) or RangeDecoderReadByte(Instance);
  Range:=Range shl 8;
 end;
 Instance.Range:=Range;
 Instance.Code:=Code;
end;

function RangeDecoderBitTreeDecode(var Instance:TLZMARangeDecoder;Prob:PpvUInt32;Levels:TpvInt32):TpvInt32;
var Counter,Value:TpvInt32;
begin
 Value:=1;
 for Counter:=1 to Levels do begin
  Value:=(Value shl 1) or RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[Value]);
 end;
 result:=Value-(1 shl Levels);
end;

function RangeDecoderReverseBitTreeDecode(var Instance:TLZMARangeDecoder;Prob:PpvUInt32;Levels:TpvInt32):TpvInt32;
var Counter,Value,Bit:TpvInt32;
begin
 result:=0;
 Value:=1;
 for Counter:=0 to Levels-1 do begin
  Bit:=RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[Value]);
  Value:=(Value shl 1) or Bit;
  result:=result or (Bit shl Counter);
 end;
end;

function LzmaLiteralDecode(var Instance:TLZMARangeDecoder;Prob:PpvUInt32):TpvUInt8;
var Symbol:TpvInt32;
begin
 Symbol:=1;
 repeat
  Symbol:=(Symbol shl 1) or RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[Symbol]);
 until not (Symbol<$100);
 result:=Symbol;
end;

function LzmaLiteralDecodeMatch(var Instance:TLZMARangeDecoder;Prob:PpvUInt32;MatchByte:TpvUInt8):TpvUInt8;
var Symbol,Bit,MatchBit:TpvInt32;
begin
 Symbol:=1;
 repeat
  MatchBit:=(MatchByte shr 7) and 1;
  MatchByte:=MatchByte shl 1;
  Bit:=RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[$100+(MatchBit shl 8)+Symbol]);
  Symbol:=(Symbol shl 1) or Bit;
  if MatchBit<>Bit then begin
   while Symbol<$100 do begin
    Symbol:=(Symbol shl 1) or RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[Symbol]);
   end;
   break;
  end;
 until not (Symbol<$100);
 result:=Symbol;
end;

function LZMALenDecode(var Instance:TLZMARangeDecoder;Prob:PpvUInt32;PositionState:TpvInt32):TpvInt32;
begin
 if RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[LenChoice])=0 then begin
  result:=RangeDecoderBitTreeDecode(Instance,@PpvUInt32Array(Prob)^[LenLow+(PositionState shl kLenNumLowBits)],kLenNumLowBits);
 end else if RangeDecoderBitDecode(Instance,@PpvUInt32Array(Prob)^[LenChoice2])=0 then begin
  result:=kLenNumLowSymbols+RangeDecoderBitTreeDecode(Instance,@PpvUInt32Array(Prob)^[LenMid+(PositionState shl kLenNumMidBits)],kLenNumMidBits);
 end else begin
  result:=kLenNumLowSymbols+kLenNumMidSymbols+RangeDecoderBitTreeDecode(Instance,@PpvUInt32Array(Prob)^[LenHigh],kLenNumHighBits);
 end;
end;

function LZMADecodeProperties(var Properties:TLZMAProperties;Data:pchar;Size:TpvInt32):boolean;
var Prop0:TpvUInt8;
begin
 Prop0:=TpvUInt8(Data[0]);
 if Prop0>=(9*5*5) then begin
  result:=LZMA_RESULT_DATA_ERROR;
  exit;
 end;
 Properties.PositionState:=0;
 while Prop0>=(9*5) do begin
  dec(Prop0,9*5);
  inc(Properties.PositionState);
 end;
 Properties.LiteralPosition:=0;
 while Prop0>=9 do begin
  dec(Prop0,9);
  inc(Properties.LiteralPosition);
 end;
 Properties.lc:=Prop0;
 result:=LZMA_RESULT_OK;
end;

function LZMADecode(var DecoderState:TLZMADecoderState;InStream:Pointer;InSize:TpvUInt64;var InSizeProcessed:TpvUInt64;OutStream:Pointer;OutSize:TpvUInt64;var OutSizeProcessed:TpvUInt64):boolean;
var P,Probs:PpvUInt32;
    NowPos:TpvUInt64;
    PreviousByte,MatchByte:TpvUInt8;
    PositionStateMask,LiteralPositionMask,rep0,rep1,rep2,rep3,Counter,NumProbs,Distance:TpvUInt32;
    LC,PositionState,State,len,PositionSlot,L,numDirectBits:TpvInt32;
    RangeDecoder:TLZMARangeDecoder;
begin
 P:=DecoderState.Probs;
 NowPos:=0;
 PreviousByte:=0;
 PositionStateMask:=(1 shl DecoderState.Properties.PositionState)-1;
 LiteralPositionMask:=(1 shl DecoderState.Properties.LiteralPosition)-1;
 LC:=DecoderState.Properties.LC;
 State:=0;
 rep0:=1;
 rep1:=1;
 rep2:=1;
 rep3:=1;
 len:=0;
 InSizeProcessed:=0;
 outSizeProcessed:=0;
 numProbs:=Literal+(LZMA_LIT_SIZE shl (lc+DecoderState.Properties.LiteralPosition));
 for Counter:=0 to NumProbs-1 do begin
  PpvUInt32Array(P)^[Counter]:=kBitModelTotal shr 1;
 end;
 RangeDecoderInit(RangeDecoder,pointer(InStream),InSize);
 if RangeDecoder.ExtraBytes<>0 then begin
  result:=LZMA_RESULT_DATA_ERROR;
  exit;
 end;
 while NowPos<TpvUInt32(OutSize) do begin
  PositionState:=NowPos and PositionStateMask;
  if RangeDecoder.ExtraBytes<>0 then begin
   result:=LZMA_RESULT_DATA_ERROR;
   exit;
  end;
  if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsMatch+(State shl kNumPosBitsMax)+PositionState])=0 then begin
   Probs:=@PpvUInt32Array(P)^[Literal+(LZMA_LIT_SIZE*(((nowPos and LiteralPositionMask) shl lc)+(PreviousByte shr (8-lc))))];
   if State>=kNumLitStates then begin
    MatchByte:=PpvUInt8Array(OutStream)^[nowPos-rep0];
    PreviousByte:=LZMALiteralDecodeMatch(RangeDecoder,Probs,MatchByte);
   end else begin
    PreviousByte:=LZMALiteralDecode(RangeDecoder,Probs);
   end;
   PpvUInt8Array(OutStream)^[NowPos]:=PreviousByte;
   inc(NowPos);
   if State<4 then begin
    State:=0;
   end else if State<10 then begin
    dec(State,3);
   end else begin
    dec(State,6);
   end;
  end else begin
   if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsRep+State])=1 then begin
    if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsRepG0+State])=0 then begin
     if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsRep0Long+(State shl kNumPosBitsMax)+PositionState])=0 then begin
      if NowPos=0 then begin
       result:=LZMA_RESULT_DATA_ERROR;
       exit;
      end;
      if State<7 then begin
       State:=9;
      end else begin
       State:=11;
      end;
      PreviousByte:=PpvUInt8Array(OutStream)^[nowPos-rep0];
      PpvUInt8Array(OutStream)^[NowPos]:=PreviousByte;
      inc(NowPos);
      continue;
     end;
    end else begin
     if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsRepG1+State])=0 then begin
      Distance:=rep1;
     end else begin
      if RangeDecoderBitDecode(RangeDecoder,@PpvUInt32Array(P)^[IsRepG2+State])=0 then begin
       Distance:=rep2;
      end else begin
       Distance:=rep3;
       rep3:=rep2;
      end;
      rep2:=rep1;
     end;
     rep1:=rep0;
     rep0:=Distance;
    end;
    Len:=LZMALenDecode(RangeDecoder,@PpvUInt32Array(P)^[RepLenCoder],PositionState);
    if State<7 then begin
     State:=8;
    end else begin
     State:=11;
    end;
   end else begin
    rep3:=rep2;
    rep2:=rep1;
    rep1:=rep0;
    if State<7 then begin
     State:=7;
    end else begin
     State:=10;
    end;
    len:=LZMALenDecode(RangeDecoder,@PpvUInt32Array(P)^[LenCoder],PositionState);
    if len<kNumLenToPosStates then begin
     l:=len;
    end else begin
     l:=kNumLenToPosStates-1;
    end;
    PositionSlot:=RangeDecoderBitTreeDecode(RangeDecoder,@PpvUInt32Array(P)^[PosSlot+(L shl kNumPosSlotBits)],kNumPosSlotBits);
    if PositionSlot>=kStartPosModelIndex then begin
     numDirectBits:=(PositionSlot shr 1)-1;
     Rep0:=(2 or (PositionSlot and 1)) shl numDirectBits;
     if PositionSlot<kEndPosModelIndex then begin
      inc(rep0,RangeDecoderReverseBitTreeDecode(RangeDecoder,@PpvUInt32Array(P)^[TpvInt32(SpecPos)+TpvInt32(rep0)-PositionSlot-1],numDirectBits));
     end else begin
      inc(rep0,RangeDecoderDecodeDirectBits(RangeDecoder,numDirectBits-kNumAlignBits) shl kNumAlignBits);
      inc(rep0,RangeDecoderReverseBitTreeDecode(RangeDecoder,@PpvUInt32Array(P)^[Align],kNumAlignBits));
     end;
    end else begin
     rep0:=PositionSlot;
    end;
    inc(rep0);
    if TpvUInt32(rep0)=0 then begin
//   len:=kLzmaStreamWasFinishedId;
     break;
    end;
   end;
   inc(len,kMatchMinLen);
   if rep0>nowPos then begin
    result:=LZMA_RESULT_DATA_ERROR;
    exit;
   end;
   repeat
    PreviousByte:=PpvUInt8Array(OutStream)^[nowPos-rep0];
    dec(len);
    PpvUInt8Array(OutStream)^[NowPos]:=PreviousByte;
    inc(NowPos);
   until not ((Len<>0) and (NowPos<TpvUInt32(OutSize)));
  end;
 end;
 InSizeProcessed:=TpvPtrUInt(RangeDecoder.Buffer)-TpvPtrUInt(inStream);
 OutSizeProcessed:=nowPos;
 result:=LZMA_RESULT_OK;
end;

function LZMACompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZMALevel;const aWithSize:boolean):boolean;
var Encoder:TLZMAEncoder;
    InStream,OutStream:TMemoryStream;
    i:TpvInt32;
    u:TpvUInt64;
    b:TpvUInt8;
begin
 InStream:=TMemoryStream.Create;
 try
  OutStream:=TMemoryStream.Create;
  try
   Encoder:=TLZMAEncoder.Create;
   try
    case aLevel of
     TpvLZMALevel(0)..TpvLZMALevel(3):begin
      Encoder.SetAlgorithm(0);
      Encoder.SetDictionarySize(TpvUInt32(1) shl ((TpvInt32(aLevel)*2)+16));
      Encoder.SetNumFastBytes(32);
     end;
     TpvLZMALevel(4)..TpvLZMALevel(6):begin
      Encoder.SetAlgorithm(1);
      Encoder.SetDictionarySize(TpvUInt32(1) shl (TpvInt32(aLevel)+19));
      Encoder.SetNumFastBytes(32);
     end;
     TpvLZMALevel(7):begin
      Encoder.SetAlgorithm(2);
      Encoder.SetDictionarySize(TpvUInt32(1) shl 25);
      Encoder.SetNumFastBytes(64);
     end;
     TpvLZMALevel(8):begin
      Encoder.SetAlgorithm(2);
      Encoder.SetDictionarySize(TpvUInt32(1) shl 26);
      Encoder.SetNumFastBytes(64);
     end;
     else begin
      Encoder.SetAlgorithm(2);
      Encoder.SetDictionarySize(TpvUInt32(1) shl 27);
      Encoder.SetNumFastBytes(64);
     end;
    end;
    Encoder.SetMatchFinder(EMatchFinderTypeBT4);
    Encoder.SetWriteEndMarkerMode(false);
    Encoder.WriteCoderProperties(OutStream);
    InStream.Write(aInData^,aInLen);
    InStream.Seek(0,soBeginning);
    if aWithSize then begin
     u:=InStream.Size;
     for i:=0 to 7 do begin
      b:=(u shr (i shl 3)) and $ff;
      OutStream.WriteBuffer(b,SizeOf(TpvUInt8));
     end;
    end;
    Encoder.Code(InStream,OutStream,-1,-1);
   finally
    FreeAndNil(Encoder);
   end;
   aDestLen:=OutStream.Size;
   OutStream.Seek(0,soBeginning);
   GetMem(aDestData,aDestLen);
   OutStream.Read(aDestData^,aDestLen);
   result:=true;
  finally
   FreeAndNil(OutStream);
  end;
 finally
  FreeAndNil(InStream);
 end;
end;

type TISzAlloc=record
      Alloc:function(P:Pointer;Size:TpvSizeUInt):Pointer; cdecl;
      Free:procedure(P:Pointer;Address:Pointer); cdecl;
     end;
     PISzAlloc=^TISzAlloc;

function _Alloc(P:Pointer;Size:TpvSizeUInt):Pointer; cdecl;
begin
 GetMem(result,Size);
 FillChar(result^,Size,#0);
end;

procedure _Free(P:Pointer;Address:Pointer); cdecl;
begin
 if assigned(Address) then begin
  FreeMem(Address);
 end;
end;

{$ifdef fpc}
const ISzAlloc:TISzAlloc=(Alloc:@_Alloc;Free:@_Free);
{$else}
const ISzAlloc:TISzAlloc=(Alloc:_Alloc;Free:_Free);
{$endif}

{$if defined(Android) and defined(cpu386)}
{$l lzma_c/lzmadec_android_x86_32.o}
{$define HasLZMADec}
{$elseif defined(Android) and defined(cpuamd64)}
{$l lzma_c/lzmadec_android_x86_64.o}
{$define HasLZMADec}
{$elseif defined(Android) and defined(cpuaarch64)}
{$l lzma_c/lzmadec_android_aarch64.o}
{$define HasLZMADec}
{$elseif defined(Linux) and defined(cpu386)}
{$l lzma_c/lzmadec_linux_x86_32.o}
{$define HasLZMADec}
{$elseif defined(Linux) and defined(cpuamd64)}
{$l lzma_c/lzmadec_linux_x86_64.o}
{$define HasLZMADec}
{$elseif defined(Linux) and defined(cpuaarch64)}
{$l lzma_c/lzmadec_linux_aarch64.o}
{$define HasLZMADec}
{$elseif defined(Windows) and defined(cpu386)}
{$l lzma_c\lzmadec_windows_x86_32.o}
{$define HasLZMADec}
{$elseif defined(Windows) and defined(cpuamd64)}
{$l lzma_c\lzmadec_windows_x86_64.o}
{$define HasLZMADec}
{$elseif defined(Windows) and defined(cpuaarch64)}
{$l lzma_c\lzmadec_windows_aarch64.o}
{$define HasLZMADec}
{$else}
{$undef HasLZMADec}
// => Pure-pascal LZMA decoder
{$ifend}
// -{$undef HasLZMADec}

{$ifdef HasLZMADec}
const LZMA_FINISH_ANY=0;
      LZMA_FINISH_END=1;

      SZ_OK=0;

function C_LzmaDecode(dest:pointer;destLen:PpvSizeUInt;src:pointer;srcLen:PpvSizeUInt;propData:pointer;propSize:TpvSizeUInt;finishMode:TpvInt32;status:PpvInt32;alloc:PISzAlloc):TPvInt32; cdecl; external name 'LzmaDecode';
{$endif}

function LZMADecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64;const aWithSize:boolean):boolean;
{$ifdef HasLZMADec}
var SrcLen,
    DestLen:TpvSizeUInt;
    LZMASizeArrayOffset:TpvUInt64;
    LZMASizeArray:PLZMASizeArray;
    Allocated:boolean;
    Status:TpvInt32;
{$else}
var LZMAProperties:TLZMAProperties;
    LZMADecoderState:TLZMADecoderState;
    LZMAProbs:pointer;
    LZMAProbsSize:TpvUInt32;
    CompressedDataBytesProcessed,
    UncompressedDataBytesProcessed,
    LZMASizeArrayOffset:TpvUInt64;
    LZMASizeArray:PLZMASizeArray;
    Allocated:boolean;
{$endif}
begin
 if (aWithSize and (aInLen>=(SizeOf(TLZMAPropertiesArray)+SizeOf(TLZMASizeArray)))) or
    ((not aWithSize) and (aInLen>=SizeOf(TLZMAPropertiesArray))) then begin
{$ifdef HasLZMADec}
  if aWithSize then begin
   LZMASizeArray:=pointer(TpvPtrUInt(TpvPtrUInt(aInData)+SizeOf(TLZMAPropertiesArray)));
   LZMASizeArrayOffset:=SizeOf(TLZMASizeArray);
   aDestLen:=(TpvUInt64(LZMASizeArray^[0]) shl 0) or
             (TpvUInt64(LZMASizeArray^[1]) shl 8) or
             (TpvUInt64(LZMASizeArray^[2]) shl 16) or
             (TpvUInt64(LZMASizeArray^[3]) shl 24) or
             (TpvUInt64(LZMASizeArray^[4]) shl 32) or
             (TpvUInt64(LZMASizeArray^[5]) shl 40) or
             (TpvUInt64(LZMASizeArray^[6]) shl 48) or
             (TpvUInt64(LZMASizeArray^[7]) shl 56);
  end else begin
   LZMASizeArrayOffset:=0;
   if aOutputSize>=0 then begin
    aDestLen:=aOutputSize;
   end else begin
    aDestLen:=0;
   end;
  end;
  if aDestLen>0 then begin
   Allocated:=not assigned(aDestData);
   if Allocated then begin
    GetMem(aDestData,aDestLen);
   end;
   Status:=0;
   SrcLen:=aInLen-(SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset);
   DestLen:=aDestLen;
   result:=C_LzmaDecode(aDestData,
                        @DestLen,
                        pointer(TpvPtrUInt(TpvPtrUInt(aInData)+SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset)),
                        @SrcLen,
                        aInData,
                        SizeOf(TLZMAPropertiesArray),
                        LZMA_FINISH_ANY,
                        @Status,
                        @ISzAlloc
                       )=SZ_OK;
   result:=result and (aDestLen=DestLen);
   if not result then begin
    if Allocated then begin
     FreeMem(aDestData);
     aDestData:=nil;
    end;
    aDestLen:=0;
   end;
  end else begin
   aDestLen:=0;
   result:=true;
  end;
{$else}
  LZMADecodeProperties(LZMAProperties,aInData,0);
  LZMAProbsSize:=LZMAGetNumProbs(LZMAProperties)*SizeOf(TpvUInt32);
  GetMem(LZMAProbs,LZMAProbsSize);
  try
   LZMADecoderState.Properties:=LZMAProperties;
   LZMADecoderState.Probs:=LZMAProbs;
   if aWithSize then begin
    LZMASizeArray:=pointer(TpvPtrUInt(TpvPtrUInt(aInData)+SizeOf(TLZMAPropertiesArray)));
    LZMASizeArrayOffset:=SizeOf(TLZMASizeArray);
    aDestLen:=(TpvUInt64(LZMASizeArray^[0]) shl 0) or
              (TpvUInt64(LZMASizeArray^[1]) shl 8) or
              (TpvUInt64(LZMASizeArray^[2]) shl 16) or
              (TpvUInt64(LZMASizeArray^[3]) shl 24) or
              (TpvUInt64(LZMASizeArray^[4]) shl 32) or
              (TpvUInt64(LZMASizeArray^[5]) shl 40) or
              (TpvUInt64(LZMASizeArray^[6]) shl 48) or
              (TpvUInt64(LZMASizeArray^[7]) shl 56);
   end else begin
    LZMASizeArrayOffset:=0;
    if aOutputSize>=0 then begin
     aDestLen:=aOutputSize;
    end else begin
     aDestLen:=0;
    end;
   end;
   CompressedDataBytesProcessed:=0;
   UncompressedDataBytesProcessed:=0;
   if aDestLen>0 then begin
    Allocated:=not assigned(aDestData);
    if Allocated then begin
     GetMem(aDestData,aDestLen);
    end;
    result:=LZMADecode(LZMADecoderState,
                       pointer(TpvPtrUInt(TpvPtrUInt(aInData)+SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset)),
                       aInLen-(SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset),
                       CompressedDataBytesProcessed,
                       aDestData,
                       aDestLen,
                       UncompressedDataBytesProcessed);
    result:=result and (aDestLen=UncompressedDataBytesProcessed);
    if not result then begin
     if Allocated then begin
      FreeMem(aDestData);
      aDestData:=nil;
     end;
     aDestLen:=0;
    end;
   end else begin
    aDestLen:=0;
    result:=true;
   end;
  finally
   FreeMem(LZMAProbs);
   LZMAProbs:=nil;
  end;
{$endif}
 end else begin
  aDestLen:=0;
  result:=false;
 end;
end;

function LZMACompressStream(const aInStream,aOutStream:TStream;const aLevel:TpvLZMALevel):Boolean;
var Encoder:TLZMAEncoder;
    i:TpvInt32;
    u:TpvUInt64;
    b:TpvUInt8;
begin
 Encoder:=TLZMAEncoder.Create;
 try
  case aLevel of
   TpvLZMALevel(0)..TpvLZMALevel(3):begin
    Encoder.SetAlgorithm(0);
    Encoder.SetDictionarySize(TpvUInt32(1) shl ((TpvInt32(aLevel)*2)+16));
    Encoder.SetNumFastBytes(32);
   end;
   TpvLZMALevel(4)..TpvLZMALevel(6):begin
    Encoder.SetAlgorithm(1);
    Encoder.SetDictionarySize(TpvUInt32(1) shl (TpvInt32(aLevel)+19));
    Encoder.SetNumFastBytes(32);
   end;
   TpvLZMALevel(7):begin
    Encoder.SetAlgorithm(2);
    Encoder.SetDictionarySize(TpvUInt32(1) shl 25);
    Encoder.SetNumFastBytes(64);
   end;
   TpvLZMALevel(8):begin
    Encoder.SetAlgorithm(2);
    Encoder.SetDictionarySize(TpvUInt32(1) shl 26);
    Encoder.SetNumFastBytes(64);
   end;
   else begin
    Encoder.SetAlgorithm(2);
    Encoder.SetDictionarySize(TpvUInt32(1) shl 27);
    Encoder.SetNumFastBytes(64);
   end;
  end;
  Encoder.SetMatchFinder(EMatchFinderTypeBT4);
  Encoder.SetWriteEndMarkerMode(false);
  Encoder.WriteCoderProperties(aOutStream);
  aInStream.Seek(0,soBeginning);
  u:=aInStream.Size;
  for i:=0 to 7 do begin
   b:=(u shr (i shl 3)) and $ff;
   aOutStream.WriteBuffer(b,SizeOf(TpvUInt8));
  end;
  Encoder.Code(aInStream,aOutStream,-1,-1);
  result:=true;
 finally
  FreeAndNil(Encoder);
 end;
end;

function LZMADecompressStream(const aInStream,aOutStream:TStream):Boolean;
{$ifdef HasLZMADec}
var SrcLen,
    DestLen:TpvSizeUInt;
    LZMASizeArrayOffset:TpvUInt64;
    LZMASizeArray:PLZMASizeArray;
    Status:TpvInt32;
    InMemory,OutMemory:Pointer;
    InLen,OutLen:TpvUInt64;
{$else}
var LZMAProperties:TLZMAProperties;
    LZMADecoderState:TLZMADecoderState;
    LZMAProbs:pointer;
    LZMAProbsSize:TpvUInt32;
    CompressedDataBytesProcessed,
    UncompressedDataBytesProcessed,
    LZMASizeArrayOffset:TpvUInt64;
    LZMASizeArray:PLZMASizeArray;
    InMemory,OutMemory:Pointer;
    InLen,OutLen:TpvUInt64;
{$endif}
begin
 if aInStream.Size>=(SizeOf(TLZMAPropertiesArray)+SizeOf(TLZMASizeArray)) then begin
{$ifdef HasLZMADec}
  InLen:=aInStream.Size;
  GetMem(InMemory,InLen);
  try
   aInStream.Seek(0,soBeginning);
   aInStream.ReadBuffer(InMemory^,InLen);
   LZMASizeArray:=pointer(TpvPtrUInt(TpvPtrUInt(InMemory)+SizeOf(TLZMAPropertiesArray)));
   LZMASizeArrayOffset:=SizeOf(TLZMASizeArray);
   OutLen:=(TpvUInt64(LZMASizeArray^[0]) shl 0) or
           (TpvUInt64(LZMASizeArray^[1]) shl 8) or
           (TpvUInt64(LZMASizeArray^[2]) shl 16) or
           (TpvUInt64(LZMASizeArray^[3]) shl 24) or
           (TpvUInt64(LZMASizeArray^[4]) shl 32) or
           (TpvUInt64(LZMASizeArray^[5]) shl 40) or
           (TpvUInt64(LZMASizeArray^[6]) shl 48) or
           (TpvUInt64(LZMASizeArray^[7]) shl 56);
   GetMem(OutMemory,OutLen);
   try
    SrcLen:=aInStream.Size-(SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset);
    DestLen:=OutLen;
    Status:=0;
    result:=C_LzmaDecode(OutMemory,
                         @DestLen,
                         pointer(TpvPtrUInt(TpvPtrUInt(InMemory)+SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset)),
                         @SrcLen,
                         InMemory,
                         SizeOf(TLZMAPropertiesArray),
                         LZMA_FINISH_ANY,
                         @Status,
                         @ISzAlloc
                        )=SZ_OK;
    result:=result and (OutLen=DestLen);
    if result then begin
     aOutStream.WriteBuffer(OutMemory^,OutLen);
    end;
   finally
    FreeMem(OutMemory);
   end; 
  finally
   FreeMem(InMemory);
  end;
{$else}
  LZMAProbsSize:=LZMAGetNumProbs(LZMAProperties)*SizeOf(TpvUInt32);
  GetMem(LZMAProbs,LZMAProbsSize);
  try
   InLen:=aInStream.Size;
   GetMem(InMemory,InLen);
   try
    aInStream.Seek(0,soBeginning);
    aInStream.ReadBuffer(InMemory^,InLen);
    LZMADecodeProperties(LZMAProperties,InMemory,0);
    LZMADecoderState.Properties:=LZMAProperties;
    LZMADecoderState.Probs:=LZMAProbs;
    LZMASizeArrayOffset:=SizeOf(TLZMASizeArray);
    LZMASizeArray:=pointer(TpvPtrUInt(TpvPtrUInt(InMemory)+SizeOf(TLZMAPropertiesArray)));
    OutLen:=(TpvUInt64(LZMASizeArray^[0]) shl 0) or
            (TpvUInt64(LZMASizeArray^[1]) shl 8) or
            (TpvUInt64(LZMASizeArray^[2]) shl 16) or
            (TpvUInt64(LZMASizeArray^[3]) shl 24) or
            (TpvUInt64(LZMASizeArray^[4]) shl 32) or
            (TpvUInt64(LZMASizeArray^[5]) shl 40) or
            (TpvUInt64(LZMASizeArray^[6]) shl 48) or
            (TpvUInt64(LZMASizeArray^[7]) shl 56);
    GetMem(OutMemory,OutLen);
    try
     CompressedDataBytesProcessed:=0;
     UncompressedDataBytesProcessed:=0;
     result:=LZMADecode(LZMADecoderState,
                        pointer(TpvPtrUInt(TpvPtrUInt(InMemory)+SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset)),
                        InLen-(SizeOf(TLZMAPropertiesArray)+LZMASizeArrayOffset),
                        CompressedDataBytesProcessed,
                        OutMemory,
                        OutLen,
                        UncompressedDataBytesProcessed);
     result:=result and (OutLen=UncompressedDataBytesProcessed);
     if result then begin
      aOutStream.WriteBuffer(OutMemory^,OutLen);
     end;
    finally
     FreeMem(OutMemory);
    end;
   finally
    FreeMem(InMemory);
   end; 
  finally
   FreeMem(LZMAProbs);
  end;
{$endif}  
 end else begin
  result:=false;
 end;
end;

initialization
 InitCRC;
 RangeEncoder:=TRangeEncoder.Create;
finalization
 RangeEncoder.Free;
end.
