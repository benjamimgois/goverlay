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
unit PasVulkan.Archive.ZIP;
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
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.Compression.Deflate;

type EpvArchiveZIP=class(Exception);

     PpvArchiveZIPHeaderSignature=^TpvArchiveZIPHeaderSignature;
     TpvArchiveZIPHeaderSignature=packed record
      case TpvUInt8 of
       0:(
        Chars:array[0..3] of TpvRawByteChar;
       );
       1:(
        Value:TpvUInt32;
       );
     end;

     TpvArchiveZIPHeaderSignatures=class
      public
       const LocalFileHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#3,#4));
             CentralFileHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#1,#2));
             EndCentralFileHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#5,#6));
             Zip64DataDescriptorHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#7,#8));
             Zip64EndCentralFileHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#6,#6));
             Zip64CentralLocatorHeaderSignature:TpvArchiveZIPHeaderSignature=(Chars:('P','K',#6,#7));
     end;

     TpvArchiveZIPCompressionLevel=0..5;

     TpvArchiveZIPDateTimeUtils=class
      public
       class procedure ConvertDateTimeToZIPDateTime(const aDateTime:TDateTime;out aZIPDate,aZIPTime:TpvUInt16); static;
       class function ConvertZIPDateTimeToDateTime(const aZIPDate,aZIPTime:TpvUInt16):TDateTime; static;
     end;

     PpvArchiveZIPOS=^TpvArchiveZIPOS;
     TpvArchiveZIPOS=
      (
       FAT=0,
       UNIX=3,
       OS2=6,
       NTFS=10,
       VFAT=14,
       OSX=19
      );

     PpvArchiveZIPCRC32=^TpvArchiveZIPCRC32;
     TpvArchiveZIPCRC32=record
      private
       fState:TpvUInt32;
      public
       procedure Initialize;
       procedure Update(const aData;const aDataLength:TpvSizeUInt); overload;
       procedure Update(const aStream:TStream); overload;
       function Finalize:TpvUInt32;
       property State:TpvUInt32 read fState write fState;
     end;

     PpvArchiveZIPLocalFileHeader=^TpvArchiveZIPLocalFileHeader;
     TpvArchiveZIPLocalFileHeader=packed record
      public
       Signature:TpvArchiveZIPHeaderSignature;
       ExtractVersion:TpvUInt16;
       BitFlags:TpvUInt16;
       CompressMethod:TpvUInt16;
       Time:TpvUInt16;
       Date:TpvUInt16;
       CRC32:TpvUInt32;
       CompressedSize:TpvUInt32;
       UncompressedSize:TpvUInt32;
       FileNameLength:TpvUInt16;
       ExtraFieldLength:TpvUInt16;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIPExtensibleDataFieldHeader=^TpvArchiveZIPExtensibleDataFieldHeader;
     TpvArchiveZIPExtensibleDataFieldHeader=packed record
      public
       HeaderID:TpvUInt16;
       DataSize:TpvUInt16;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIP64ExtensibleInfoFieldHeader=^TpvArchiveZIP64ExtensibleInfoFieldHeader;
     TpvArchiveZIP64ExtensibleInfoFieldHeader=packed record
      public
       const HeaderID=$0001;
             DataSize=28;
      public
       OriginalSize:TpvUInt64;
       CompressedSize:TpvUInt64;
       RelativeHeaderOffset:TpvUInt64;
       DiskStartNumber:TpvUInt32;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIPCentralFileHeader=^TpvArchiveZIPCentralFileHeader;
     TpvArchiveZIPCentralFileHeader=packed record
      public
       Signature:TpvArchiveZIPHeaderSignature;
       CreatorVersion:TpvUInt16;
       ExtractVersion:TpvUInt16;
       BitFlags:TpvUInt16;
       CompressMethod:TpvUInt16;
       Time:TpvUInt16;
       Date:TpvUInt16;
       CRC32:TpvUInt32;
       CompressedSize:TpvUInt32;
       UncompressedSize:TpvUInt32;
       FileNameLength:TpvUInt16;
       ExtraFieldLength:TpvUInt16;
       FileCommentLength:TpvUInt16;
       StartDiskNumber:TpvUInt16;
       InternalAttrributes:TpvUInt16;
       ExternalAttrributes:TpvUInt32;
       LocalFileHeaderOffset:TpvUInt32;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIPEndCentralFileHeader=^TpvArchiveZIPEndCentralFileHeader;
     TpvArchiveZIPEndCentralFileHeader=packed record
      public
       Signature:TpvArchiveZIPHeaderSignature;
       DiskNumber:TpvUInt16;
       CentralDirectoryStartDisk:TpvUInt16;
       EntriesThisDisk:TpvUInt16;
       TotalEntries:TpvUInt16;
       CentralDirectorySize:TpvUInt32;
       StartDiskOffset:TpvUInt32;
       CommentLength:TpvUInt16;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIP64EndCentralFileHeader=^TpvArchiveZIP64EndCentralFileHeader;
     TpvArchiveZIP64EndCentralFileHeader=packed record
      public
       Signature:TpvArchiveZIPHeaderSignature;
       RecordSize:TpvUInt64;
       VersionMadeBy:TpvUInt16;
       ExtractVersionRequired:TpvUInt16;
       DiskNumber:TpvUInt32;
       CentralDirectoryStartDisk:TpvUInt32;
       EntriesThisDisk:TpvUInt64;
       TotalEntries:TpvUInt64;
       CentralDirectorySize:TpvUInt64;
       StartDiskOffset:TpvUInt64;
       procedure SwapEndiannessIfNeeded;
     end;

     PpvArchiveZIP64EndCentralLocator=^TpvArchiveZIP64EndCentralLocator;
     TpvArchiveZIP64EndCentralLocator=packed record
      public
       Signature:TpvArchiveZIPHeaderSignature;
       EndOfCentralDirectoryStartDisk:TpvUInt32;
       CentralDirectoryOffset:TpvUInt64;
       TotalDisks:TpvUInt32;
       procedure SwapEndiannessIfNeeded;
     end;

     TpvArchiveZIP=class;

     TpvArchiveZIPEntry=class(TCollectionItem)
      private
       fFileName:TpvRawByteString;
       fAttributes:TpvUInt32;
       fDateTime:TDateTime;
       fCentralHeaderPosition:TpvInt64;
       fHeaderPosition:TpvInt64;
       fRequiresZIP64:boolean;
       fOS:TpvArchiveZIPOS;
       fSize:TpvInt64;
       fStream:TStream;
       fSourceArchive:TpvArchiveZIP;
       fCompressionLevel:TpvArchiveZIPCompressionLevel;
       fLocalFileHeader:TpvArchiveZIPLocalFileHeader;
       fZIP64ExtensibleInfoFieldHeader:TpvArchiveZIP64ExtensibleInfoFieldHeader;
       procedure SetFileName(const aFileName:TpvRawByteString);
       function GetDirectory:boolean;
       function GetLink:boolean;
      protected
       property CentralHeaderPosition:TpvInt64 read fCentralHeaderPosition write fCentralHeaderPosition;
       property HeaderPosition:TpvInt64 read fHeaderPosition write fHeaderPosition;
       property RequiresZIP64:boolean read fRequiresZIP64 write fRequiresZIP64;
      public
       constructor Create(aCollection:TCollection); override;
       destructor Destroy; override;
       procedure Assign(aSource:TPersistent); override;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
       property Stream:TStream read fStream write fStream;
       property SourceArchive:TpvArchiveZIP read fSourceArchive write fSourceArchive;
       property Directory:boolean read GetDirectory;
       property Link:boolean read GetLink;
      published
       property FileName:TpvRawByteString read fFileName write SetFileName;
       property Attributes:TpvUInt32 read fAttributes write fAttributes;
       property DateTime:TDateTime read fDateTime write fDateTime;
       property OS:TpvArchiveZIPOS read fOS write fOS;
       property Size:TpvInt64 read fSize write fSize;
       property CompressionLevel:TpvArchiveZIPCompressionLevel read fCompressionLevel write fCompressionLevel;
     end;

     TpvArchiveZIPEntriesFileNameHashMap=TpvStringHashMap<TpvArchiveZIPEntry>;

     TpvArchiveZIPEntries=class(TCollection)
      private
       fFileNameHashMap:TpvArchiveZIPEntriesFileNameHashMap;
       function GetEntry(const aIndex:TpvSizeInt):TpvArchiveZIPEntry;
       procedure SetEntry(const aIndex:TpvSizeInt;const aEntry:TpvArchiveZIPEntry);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function Add(const aFileName:TpvRawByteString):TpvArchiveZIPEntry; reintroduce;
       function Find(const aFileName:TpvRawByteString):TpvArchiveZIPEntry; reintroduce;
       property Entries[const aIndex:TpvSizeInt]:TpvArchiveZIPEntry read GetEntry write SetEntry; default;
     end;

     TpvArchiveZIP=class
      private
       fEntries:TpvArchiveZIPEntries;
       fStream:TStream;
       fOwnStream:Boolean;
       fZIP64:boolean;
      public
       constructor Create;
       destructor Destroy; override;
       class function CorrectPath(const aFileName:TpvRawByteString):TpvRawByteString; static;
       procedure Clear;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
      published
       property Entries:TpvArchiveZIPEntries read fEntries;
       property ZIP64:boolean read fZIP64 write fZIP64;
     end;

implementation

uses PasVulkan.CPU.Info;

const TpvArchiveZIPCRC32_CRC32Tables:array[0..15,0..255] of TpvUInt32=
       (
        (
         $00000000,$77073096,$ee0e612c,$990951ba,$076dc419,$706af48f,$e963a535,$9e6495a3,
         $0edb8832,$79dcb8a4,$e0d5e91e,$97d2d988,$09b64c2b,$7eb17cbd,$e7b82d07,$90bf1d91,
         $1db71064,$6ab020f2,$f3b97148,$84be41de,$1adad47d,$6ddde4eb,$f4d4b551,$83d385c7,
         $136c9856,$646ba8c0,$fd62f97a,$8a65c9ec,$14015c4f,$63066cd9,$fa0f3d63,$8d080df5,
         $3b6e20c8,$4c69105e,$d56041e4,$a2677172,$3c03e4d1,$4b04d447,$d20d85fd,$a50ab56b,
         $35b5a8fa,$42b2986c,$dbbbc9d6,$acbcf940,$32d86ce3,$45df5c75,$dcd60dcf,$abd13d59,
         $26d930ac,$51de003a,$c8d75180,$bfd06116,$21b4f4b5,$56b3c423,$cfba9599,$b8bda50f,
         $2802b89e,$5f058808,$c60cd9b2,$b10be924,$2f6f7c87,$58684c11,$c1611dab,$b6662d3d,
         $76dc4190,$01db7106,$98d220bc,$efd5102a,$71b18589,$06b6b51f,$9fbfe4a5,$e8b8d433,
         $7807c9a2,$0f00f934,$9609a88e,$e10e9818,$7f6a0dbb,$086d3d2d,$91646c97,$e6635c01,
         $6b6b51f4,$1c6c6162,$856530d8,$f262004e,$6c0695ed,$1b01a57b,$8208f4c1,$f50fc457,
         $65b0d9c6,$12b7e950,$8bbeb8ea,$fcb9887c,$62dd1ddf,$15da2d49,$8cd37cf3,$fbd44c65,
         $4db26158,$3ab551ce,$a3bc0074,$d4bb30e2,$4adfa541,$3dd895d7,$a4d1c46d,$d3d6f4fb,
         $4369e96a,$346ed9fc,$ad678846,$da60b8d0,$44042d73,$33031de5,$aa0a4c5f,$dd0d7cc9,
         $5005713c,$270241aa,$be0b1010,$c90c2086,$5768b525,$206f85b3,$b966d409,$ce61e49f,
         $5edef90e,$29d9c998,$b0d09822,$c7d7a8b4,$59b33d17,$2eb40d81,$b7bd5c3b,$c0ba6cad,
         $edb88320,$9abfb3b6,$03b6e20c,$74b1d29a,$ead54739,$9dd277af,$04db2615,$73dc1683,
         $e3630b12,$94643b84,$0d6d6a3e,$7a6a5aa8,$e40ecf0b,$9309ff9d,$0a00ae27,$7d079eb1,
         $f00f9344,$8708a3d2,$1e01f268,$6906c2fe,$f762575d,$806567cb,$196c3671,$6e6b06e7,
         $fed41b76,$89d32be0,$10da7a5a,$67dd4acc,$f9b9df6f,$8ebeeff9,$17b7be43,$60b08ed5,
         $d6d6a3e8,$a1d1937e,$38d8c2c4,$4fdff252,$d1bb67f1,$a6bc5767,$3fb506dd,$48b2364b,
         $d80d2bda,$af0a1b4c,$36034af6,$41047a60,$df60efc3,$a867df55,$316e8eef,$4669be79,
         $cb61b38c,$bc66831a,$256fd2a0,$5268e236,$cc0c7795,$bb0b4703,$220216b9,$5505262f,
         $c5ba3bbe,$b2bd0b28,$2bb45a92,$5cb36a04,$c2d7ffa7,$b5d0cf31,$2cd99e8b,$5bdeae1d,
         $9b64c2b0,$ec63f226,$756aa39c,$026d930a,$9c0906a9,$eb0e363f,$72076785,$05005713,
         $95bf4a82,$e2b87a14,$7bb12bae,$0cb61b38,$92d28e9b,$e5d5be0d,$7cdcefb7,$0bdbdf21,
         $86d3d2d4,$f1d4e242,$68ddb3f8,$1fda836e,$81be16cd,$f6b9265b,$6fb077e1,$18b74777,
         $88085ae6,$ff0f6a70,$66063bca,$11010b5c,$8f659eff,$f862ae69,$616bffd3,$166ccf45,
         $a00ae278,$d70dd2ee,$4e048354,$3903b3c2,$a7672661,$d06016f7,$4969474d,$3e6e77db,
         $aed16a4a,$d9d65adc,$40df0b66,$37d83bf0,$a9bcae53,$debb9ec5,$47b2cf7f,$30b5ffe9,
         $bdbdf21c,$cabac28a,$53b39330,$24b4a3a6,$bad03605,$cdd70693,$54de5729,$23d967bf,
         $b3667a2e,$c4614ab8,$5d681b02,$2a6f2b94,$b40bbe37,$c30c8ea1,$5a05df1b,$2d02ef8d
        ),
        (
         $00000000,$191b3141,$32366282,$2b2d53c3,$646cc504,$7d77f445,$565aa786,$4f4196c7,
         $c8d98a08,$d1c2bb49,$faefe88a,$e3f4d9cb,$acb54f0c,$b5ae7e4d,$9e832d8e,$87981ccf,
         $4ac21251,$53d92310,$78f470d3,$61ef4192,$2eaed755,$37b5e614,$1c98b5d7,$05838496,
         $821b9859,$9b00a918,$b02dfadb,$a936cb9a,$e6775d5d,$ff6c6c1c,$d4413fdf,$cd5a0e9e,
         $958424a2,$8c9f15e3,$a7b24620,$bea97761,$f1e8e1a6,$e8f3d0e7,$c3de8324,$dac5b265,
         $5d5daeaa,$44469feb,$6f6bcc28,$7670fd69,$39316bae,$202a5aef,$0b07092c,$121c386d,
         $df4636f3,$c65d07b2,$ed705471,$f46b6530,$bb2af3f7,$a231c2b6,$891c9175,$9007a034,
         $179fbcfb,$0e848dba,$25a9de79,$3cb2ef38,$73f379ff,$6ae848be,$41c51b7d,$58de2a3c,
         $f0794f05,$e9627e44,$c24f2d87,$db541cc6,$94158a01,$8d0ebb40,$a623e883,$bf38d9c2,
         $38a0c50d,$21bbf44c,$0a96a78f,$138d96ce,$5ccc0009,$45d73148,$6efa628b,$77e153ca,
         $babb5d54,$a3a06c15,$888d3fd6,$91960e97,$ded79850,$c7cca911,$ece1fad2,$f5facb93,
         $7262d75c,$6b79e61d,$4054b5de,$594f849f,$160e1258,$0f152319,$243870da,$3d23419b,
         $65fd6ba7,$7ce65ae6,$57cb0925,$4ed03864,$0191aea3,$188a9fe2,$33a7cc21,$2abcfd60,
         $ad24e1af,$b43fd0ee,$9f12832d,$8609b26c,$c94824ab,$d05315ea,$fb7e4629,$e2657768,
         $2f3f79f6,$362448b7,$1d091b74,$04122a35,$4b53bcf2,$52488db3,$7965de70,$607eef31,
         $e7e6f3fe,$fefdc2bf,$d5d0917c,$cccba03d,$838a36fa,$9a9107bb,$b1bc5478,$a8a76539,
         $3b83984b,$2298a90a,$09b5fac9,$10aecb88,$5fef5d4f,$46f46c0e,$6dd93fcd,$74c20e8c,
         $f35a1243,$ea412302,$c16c70c1,$d8774180,$9736d747,$8e2de606,$a500b5c5,$bc1b8484,
         $71418a1a,$685abb5b,$4377e898,$5a6cd9d9,$152d4f1e,$0c367e5f,$271b2d9c,$3e001cdd,
         $b9980012,$a0833153,$8bae6290,$92b553d1,$ddf4c516,$c4eff457,$efc2a794,$f6d996d5,
         $ae07bce9,$b71c8da8,$9c31de6b,$852aef2a,$ca6b79ed,$d37048ac,$f85d1b6f,$e1462a2e,
         $66de36e1,$7fc507a0,$54e85463,$4df36522,$02b2f3e5,$1ba9c2a4,$30849167,$299fa026,
         $e4c5aeb8,$fdde9ff9,$d6f3cc3a,$cfe8fd7b,$80a96bbc,$99b25afd,$b29f093e,$ab84387f,
         $2c1c24b0,$350715f1,$1e2a4632,$07317773,$4870e1b4,$516bd0f5,$7a468336,$635db277,
         $cbfad74e,$d2e1e60f,$f9ccb5cc,$e0d7848d,$af96124a,$b68d230b,$9da070c8,$84bb4189,
         $03235d46,$1a386c07,$31153fc4,$280e0e85,$674f9842,$7e54a903,$5579fac0,$4c62cb81,
         $8138c51f,$9823f45e,$b30ea79d,$aa1596dc,$e554001b,$fc4f315a,$d7626299,$ce7953d8,
         $49e14f17,$50fa7e56,$7bd72d95,$62cc1cd4,$2d8d8a13,$3496bb52,$1fbbe891,$06a0d9d0,
         $5e7ef3ec,$4765c2ad,$6c48916e,$7553a02f,$3a1236e8,$230907a9,$0824546a,$113f652b,
         $96a779e4,$8fbc48a5,$a4911b66,$bd8a2a27,$f2cbbce0,$ebd08da1,$c0fdde62,$d9e6ef23,
         $14bce1bd,$0da7d0fc,$268a833f,$3f91b27e,$70d024b9,$69cb15f8,$42e6463b,$5bfd777a,
         $dc656bb5,$c57e5af4,$ee530937,$f7483876,$b809aeb1,$a1129ff0,$8a3fcc33,$9324fd72
        ),
        (
         $00000000,$01c26a37,$0384d46e,$0246be59,$0709a8dc,$06cbc2eb,$048d7cb2,$054f1685,
         $0e1351b8,$0fd13b8f,$0d9785d6,$0c55efe1,$091af964,$08d89353,$0a9e2d0a,$0b5c473d,
         $1c26a370,$1de4c947,$1fa2771e,$1e601d29,$1b2f0bac,$1aed619b,$18abdfc2,$1969b5f5,
         $1235f2c8,$13f798ff,$11b126a6,$10734c91,$153c5a14,$14fe3023,$16b88e7a,$177ae44d,
         $384d46e0,$398f2cd7,$3bc9928e,$3a0bf8b9,$3f44ee3c,$3e86840b,$3cc03a52,$3d025065,
         $365e1758,$379c7d6f,$35dac336,$3418a901,$3157bf84,$3095d5b3,$32d36bea,$331101dd,
         $246be590,$25a98fa7,$27ef31fe,$262d5bc9,$23624d4c,$22a0277b,$20e69922,$2124f315,
         $2a78b428,$2bbade1f,$29fc6046,$283e0a71,$2d711cf4,$2cb376c3,$2ef5c89a,$2f37a2ad,
         $709a8dc0,$7158e7f7,$731e59ae,$72dc3399,$7793251c,$76514f2b,$7417f172,$75d59b45,
         $7e89dc78,$7f4bb64f,$7d0d0816,$7ccf6221,$798074a4,$78421e93,$7a04a0ca,$7bc6cafd,
         $6cbc2eb0,$6d7e4487,$6f38fade,$6efa90e9,$6bb5866c,$6a77ec5b,$68315202,$69f33835,
         $62af7f08,$636d153f,$612bab66,$60e9c151,$65a6d7d4,$6464bde3,$662203ba,$67e0698d,
         $48d7cb20,$4915a117,$4b531f4e,$4a917579,$4fde63fc,$4e1c09cb,$4c5ab792,$4d98dda5,
         $46c49a98,$4706f0af,$45404ef6,$448224c1,$41cd3244,$400f5873,$4249e62a,$438b8c1d,
         $54f16850,$55330267,$5775bc3e,$56b7d609,$53f8c08c,$523aaabb,$507c14e2,$51be7ed5,
         $5ae239e8,$5b2053df,$5966ed86,$58a487b1,$5deb9134,$5c29fb03,$5e6f455a,$5fad2f6d,
         $e1351b80,$e0f771b7,$e2b1cfee,$e373a5d9,$e63cb35c,$e7fed96b,$e5b86732,$e47a0d05,
         $ef264a38,$eee4200f,$eca29e56,$ed60f461,$e82fe2e4,$e9ed88d3,$ebab368a,$ea695cbd,
         $fd13b8f0,$fcd1d2c7,$fe976c9e,$ff5506a9,$fa1a102c,$fbd87a1b,$f99ec442,$f85cae75,
         $f300e948,$f2c2837f,$f0843d26,$f1465711,$f4094194,$f5cb2ba3,$f78d95fa,$f64fffcd,
         $d9785d60,$d8ba3757,$dafc890e,$db3ee339,$de71f5bc,$dfb39f8b,$ddf521d2,$dc374be5,
         $d76b0cd8,$d6a966ef,$d4efd8b6,$d52db281,$d062a404,$d1a0ce33,$d3e6706a,$d2241a5d,
         $c55efe10,$c49c9427,$c6da2a7e,$c7184049,$c25756cc,$c3953cfb,$c1d382a2,$c011e895,
         $cb4dafa8,$ca8fc59f,$c8c97bc6,$c90b11f1,$cc440774,$cd866d43,$cfc0d31a,$ce02b92d,
         $91af9640,$906dfc77,$922b422e,$93e92819,$96a63e9c,$976454ab,$9522eaf2,$94e080c5,
         $9fbcc7f8,$9e7eadcf,$9c381396,$9dfa79a1,$98b56f24,$99770513,$9b31bb4a,$9af3d17d,
         $8d893530,$8c4b5f07,$8e0de15e,$8fcf8b69,$8a809dec,$8b42f7db,$89044982,$88c623b5,
         $839a6488,$82580ebf,$801eb0e6,$81dcdad1,$8493cc54,$8551a663,$8717183a,$86d5720d,
         $a9e2d0a0,$a820ba97,$aa6604ce,$aba46ef9,$aeeb787c,$af29124b,$ad6fac12,$acadc625,
         $a7f18118,$a633eb2f,$a4755576,$a5b73f41,$a0f829c4,$a13a43f3,$a37cfdaa,$a2be979d,
         $b5c473d0,$b40619e7,$b640a7be,$b782cd89,$b2cddb0c,$b30fb13b,$b1490f62,$b08b6555,
         $bbd72268,$ba15485f,$b853f606,$b9919c31,$bcde8ab4,$bd1ce083,$bf5a5eda,$be9834ed
        ),
        (
         $00000000,$b8bc6765,$aa09c88b,$12b5afee,$8f629757,$37def032,$256b5fdc,$9dd738b9,
         $c5b428ef,$7d084f8a,$6fbde064,$d7018701,$4ad6bfb8,$f26ad8dd,$e0df7733,$58631056,
         $5019579f,$e8a530fa,$fa109f14,$42acf871,$df7bc0c8,$67c7a7ad,$75720843,$cdce6f26,
         $95ad7f70,$2d111815,$3fa4b7fb,$8718d09e,$1acfe827,$a2738f42,$b0c620ac,$087a47c9,
         $a032af3e,$188ec85b,$0a3b67b5,$b28700d0,$2f503869,$97ec5f0c,$8559f0e2,$3de59787,
         $658687d1,$dd3ae0b4,$cf8f4f5a,$7733283f,$eae41086,$525877e3,$40edd80d,$f851bf68,
         $f02bf8a1,$48979fc4,$5a22302a,$e29e574f,$7f496ff6,$c7f50893,$d540a77d,$6dfcc018,
         $359fd04e,$8d23b72b,$9f9618c5,$272a7fa0,$bafd4719,$0241207c,$10f48f92,$a848e8f7,
         $9b14583d,$23a83f58,$311d90b6,$89a1f7d3,$1476cf6a,$accaa80f,$be7f07e1,$06c36084,
         $5ea070d2,$e61c17b7,$f4a9b859,$4c15df3c,$d1c2e785,$697e80e0,$7bcb2f0e,$c377486b,
         $cb0d0fa2,$73b168c7,$6104c729,$d9b8a04c,$446f98f5,$fcd3ff90,$ee66507e,$56da371b,
         $0eb9274d,$b6054028,$a4b0efc6,$1c0c88a3,$81dbb01a,$3967d77f,$2bd27891,$936e1ff4,
         $3b26f703,$839a9066,$912f3f88,$299358ed,$b4446054,$0cf80731,$1e4da8df,$a6f1cfba,
         $fe92dfec,$462eb889,$549b1767,$ec277002,$71f048bb,$c94c2fde,$dbf98030,$6345e755,
         $6b3fa09c,$d383c7f9,$c1366817,$798a0f72,$e45d37cb,$5ce150ae,$4e54ff40,$f6e89825,
         $ae8b8873,$1637ef16,$048240f8,$bc3e279d,$21e91f24,$99557841,$8be0d7af,$335cb0ca,
         $ed59b63b,$55e5d15e,$47507eb0,$ffec19d5,$623b216c,$da874609,$c832e9e7,$708e8e82,
         $28ed9ed4,$9051f9b1,$82e4565f,$3a58313a,$a78f0983,$1f336ee6,$0d86c108,$b53aa66d,
         $bd40e1a4,$05fc86c1,$1749292f,$aff54e4a,$322276f3,$8a9e1196,$982bbe78,$2097d91d,
         $78f4c94b,$c048ae2e,$d2fd01c0,$6a4166a5,$f7965e1c,$4f2a3979,$5d9f9697,$e523f1f2,
         $4d6b1905,$f5d77e60,$e762d18e,$5fdeb6eb,$c2098e52,$7ab5e937,$680046d9,$d0bc21bc,
         $88df31ea,$3063568f,$22d6f961,$9a6a9e04,$07bda6bd,$bf01c1d8,$adb46e36,$15080953,
         $1d724e9a,$a5ce29ff,$b77b8611,$0fc7e174,$9210d9cd,$2aacbea8,$38191146,$80a57623,
         $d8c66675,$607a0110,$72cfaefe,$ca73c99b,$57a4f122,$ef189647,$fdad39a9,$45115ecc,
         $764dee06,$cef18963,$dc44268d,$64f841e8,$f92f7951,$41931e34,$5326b1da,$eb9ad6bf,
         $b3f9c6e9,$0b45a18c,$19f00e62,$a14c6907,$3c9b51be,$842736db,$96929935,$2e2efe50,
         $2654b999,$9ee8defc,$8c5d7112,$34e11677,$a9362ece,$118a49ab,$033fe645,$bb838120,
         $e3e09176,$5b5cf613,$49e959fd,$f1553e98,$6c820621,$d43e6144,$c68bceaa,$7e37a9cf,
         $d67f4138,$6ec3265d,$7c7689b3,$c4caeed6,$591dd66f,$e1a1b10a,$f3141ee4,$4ba87981,
         $13cb69d7,$ab770eb2,$b9c2a15c,$017ec639,$9ca9fe80,$241599e5,$36a0360b,$8e1c516e,
         $866616a7,$3eda71c2,$2c6fde2c,$94d3b949,$090481f0,$b1b8e695,$a30d497b,$1bb12e1e,
         $43d23e48,$fb6e592d,$e9dbf6c3,$516791a6,$ccb0a91f,$740cce7a,$66b96194,$de0506f1
        ),
        (
         $00000000,$3d6029b0,$7ac05360,$47a07ad0,$f580a6c0,$c8e08f70,$8f40f5a0,$b220dc10,
         $30704bc1,$0d106271,$4ab018a1,$77d03111,$c5f0ed01,$f890c4b1,$bf30be61,$825097d1,
         $60e09782,$5d80be32,$1a20c4e2,$2740ed52,$95603142,$a80018f2,$efa06222,$d2c04b92,
         $5090dc43,$6df0f5f3,$2a508f23,$1730a693,$a5107a83,$98705333,$dfd029e3,$e2b00053,
         $c1c12f04,$fca106b4,$bb017c64,$866155d4,$344189c4,$0921a074,$4e81daa4,$73e1f314,
         $f1b164c5,$ccd14d75,$8b7137a5,$b6111e15,$0431c205,$3951ebb5,$7ef19165,$4391b8d5,
         $a121b886,$9c419136,$dbe1ebe6,$e681c256,$54a11e46,$69c137f6,$2e614d26,$13016496,
         $9151f347,$ac31daf7,$eb91a027,$d6f18997,$64d15587,$59b17c37,$1e1106e7,$23712f57,
         $58f35849,$659371f9,$22330b29,$1f532299,$ad73fe89,$9013d739,$d7b3ade9,$ead38459,
         $68831388,$55e33a38,$124340e8,$2f236958,$9d03b548,$a0639cf8,$e7c3e628,$daa3cf98,
         $3813cfcb,$0573e67b,$42d39cab,$7fb3b51b,$cd93690b,$f0f340bb,$b7533a6b,$8a3313db,
         $0863840a,$3503adba,$72a3d76a,$4fc3feda,$fde322ca,$c0830b7a,$872371aa,$ba43581a,
         $9932774d,$a4525efd,$e3f2242d,$de920d9d,$6cb2d18d,$51d2f83d,$167282ed,$2b12ab5d,
         $a9423c8c,$9422153c,$d3826fec,$eee2465c,$5cc29a4c,$61a2b3fc,$2602c92c,$1b62e09c,
         $f9d2e0cf,$c4b2c97f,$8312b3af,$be729a1f,$0c52460f,$31326fbf,$7692156f,$4bf23cdf,
         $c9a2ab0e,$f4c282be,$b362f86e,$8e02d1de,$3c220dce,$0142247e,$46e25eae,$7b82771e,
         $b1e6b092,$8c869922,$cb26e3f2,$f646ca42,$44661652,$79063fe2,$3ea64532,$03c66c82,
         $8196fb53,$bcf6d2e3,$fb56a833,$c6368183,$74165d93,$49767423,$0ed60ef3,$33b62743,
         $d1062710,$ec660ea0,$abc67470,$96a65dc0,$248681d0,$19e6a860,$5e46d2b0,$6326fb00,
         $e1766cd1,$dc164561,$9bb63fb1,$a6d61601,$14f6ca11,$2996e3a1,$6e369971,$5356b0c1,
         $70279f96,$4d47b626,$0ae7ccf6,$3787e546,$85a73956,$b8c710e6,$ff676a36,$c2074386,
         $4057d457,$7d37fde7,$3a978737,$07f7ae87,$b5d77297,$88b75b27,$cf1721f7,$f2770847,
         $10c70814,$2da721a4,$6a075b74,$576772c4,$e547aed4,$d8278764,$9f87fdb4,$a2e7d404,
         $20b743d5,$1dd76a65,$5a7710b5,$67173905,$d537e515,$e857cca5,$aff7b675,$92979fc5,
         $e915e8db,$d475c16b,$93d5bbbb,$aeb5920b,$1c954e1b,$21f567ab,$66551d7b,$5b3534cb,
         $d965a31a,$e4058aaa,$a3a5f07a,$9ec5d9ca,$2ce505da,$11852c6a,$562556ba,$6b457f0a,
         $89f57f59,$b49556e9,$f3352c39,$ce550589,$7c75d999,$4115f029,$06b58af9,$3bd5a349,
         $b9853498,$84e51d28,$c34567f8,$fe254e48,$4c059258,$7165bbe8,$36c5c138,$0ba5e888,
         $28d4c7df,$15b4ee6f,$521494bf,$6f74bd0f,$dd54611f,$e03448af,$a794327f,$9af41bcf,
         $18a48c1e,$25c4a5ae,$6264df7e,$5f04f6ce,$ed242ade,$d044036e,$97e479be,$aa84500e,
         $4834505d,$755479ed,$32f4033d,$0f942a8d,$bdb4f69d,$80d4df2d,$c774a5fd,$fa148c4d,
         $78441b9c,$4524322c,$028448fc,$3fe4614c,$8dc4bd5c,$b0a494ec,$f704ee3c,$ca64c78c
        ),
        (
         $00000000,$cb5cd3a5,$4dc8a10b,$869472ae,$9b914216,$50cd91b3,$d659e31d,$1d0530b8,
         $ec53826d,$270f51c8,$a19b2366,$6ac7f0c3,$77c2c07b,$bc9e13de,$3a0a6170,$f156b2d5,
         $03d6029b,$c88ad13e,$4e1ea390,$85427035,$9847408d,$531b9328,$d58fe186,$1ed33223,
         $ef8580f6,$24d95353,$a24d21fd,$6911f258,$7414c2e0,$bf481145,$39dc63eb,$f280b04e,
         $07ac0536,$ccf0d693,$4a64a43d,$81387798,$9c3d4720,$57619485,$d1f5e62b,$1aa9358e,
         $ebff875b,$20a354fe,$a6372650,$6d6bf5f5,$706ec54d,$bb3216e8,$3da66446,$f6fab7e3,
         $047a07ad,$cf26d408,$49b2a6a6,$82ee7503,$9feb45bb,$54b7961e,$d223e4b0,$197f3715,
         $e82985c0,$23755665,$a5e124cb,$6ebdf76e,$73b8c7d6,$b8e41473,$3e7066dd,$f52cb578,
         $0f580a6c,$c404d9c9,$4290ab67,$89cc78c2,$94c9487a,$5f959bdf,$d901e971,$125d3ad4,
         $e30b8801,$28575ba4,$aec3290a,$659ffaaf,$789aca17,$b3c619b2,$35526b1c,$fe0eb8b9,
         $0c8e08f7,$c7d2db52,$4146a9fc,$8a1a7a59,$971f4ae1,$5c439944,$dad7ebea,$118b384f,
         $e0dd8a9a,$2b81593f,$ad152b91,$6649f834,$7b4cc88c,$b0101b29,$36846987,$fdd8ba22,
         $08f40f5a,$c3a8dcff,$453cae51,$8e607df4,$93654d4c,$58399ee9,$deadec47,$15f13fe2,
         $e4a78d37,$2ffb5e92,$a96f2c3c,$6233ff99,$7f36cf21,$b46a1c84,$32fe6e2a,$f9a2bd8f,
         $0b220dc1,$c07ede64,$46eaacca,$8db67f6f,$90b34fd7,$5bef9c72,$dd7beedc,$16273d79,
         $e7718fac,$2c2d5c09,$aab92ea7,$61e5fd02,$7ce0cdba,$b7bc1e1f,$31286cb1,$fa74bf14,
         $1eb014d8,$d5ecc77d,$5378b5d3,$98246676,$852156ce,$4e7d856b,$c8e9f7c5,$03b52460,
         $f2e396b5,$39bf4510,$bf2b37be,$7477e41b,$6972d4a3,$a22e0706,$24ba75a8,$efe6a60d,
         $1d661643,$d63ac5e6,$50aeb748,$9bf264ed,$86f75455,$4dab87f0,$cb3ff55e,$006326fb,
         $f135942e,$3a69478b,$bcfd3525,$77a1e680,$6aa4d638,$a1f8059d,$276c7733,$ec30a496,
         $191c11ee,$d240c24b,$54d4b0e5,$9f886340,$828d53f8,$49d1805d,$cf45f2f3,$04192156,
         $f54f9383,$3e134026,$b8873288,$73dbe12d,$6eded195,$a5820230,$2316709e,$e84aa33b,
         $1aca1375,$d196c0d0,$5702b27e,$9c5e61db,$815b5163,$4a0782c6,$cc93f068,$07cf23cd,
         $f6999118,$3dc542bd,$bb513013,$700de3b6,$6d08d30e,$a65400ab,$20c07205,$eb9ca1a0,
         $11e81eb4,$dab4cd11,$5c20bfbf,$977c6c1a,$8a795ca2,$41258f07,$c7b1fda9,$0ced2e0c,
         $fdbb9cd9,$36e74f7c,$b0733dd2,$7b2fee77,$662adecf,$ad760d6a,$2be27fc4,$e0beac61,
         $123e1c2f,$d962cf8a,$5ff6bd24,$94aa6e81,$89af5e39,$42f38d9c,$c467ff32,$0f3b2c97,
         $fe6d9e42,$35314de7,$b3a53f49,$78f9ecec,$65fcdc54,$aea00ff1,$28347d5f,$e368aefa,
         $16441b82,$dd18c827,$5b8cba89,$90d0692c,$8dd55994,$46898a31,$c01df89f,$0b412b3a,
         $fa1799ef,$314b4a4a,$b7df38e4,$7c83eb41,$6186dbf9,$aada085c,$2c4e7af2,$e712a957,
         $15921919,$dececabc,$585ab812,$93066bb7,$8e035b0f,$455f88aa,$c3cbfa04,$089729a1,
         $f9c19b74,$329d48d1,$b4093a7f,$7f55e9da,$6250d962,$a90c0ac7,$2f987869,$e4c4abcc
        ),
        (
         $00000000,$a6770bb4,$979f1129,$31e81a9d,$f44f2413,$52382fa7,$63d0353a,$c5a73e8e,
         $33ef4e67,$959845d3,$a4705f4e,$020754fa,$c7a06a74,$61d761c0,$503f7b5d,$f64870e9,
         $67de9cce,$c1a9977a,$f0418de7,$56368653,$9391b8dd,$35e6b369,$040ea9f4,$a279a240,
         $5431d2a9,$f246d91d,$c3aec380,$65d9c834,$a07ef6ba,$0609fd0e,$37e1e793,$9196ec27,
         $cfbd399c,$69ca3228,$582228b5,$fe552301,$3bf21d8f,$9d85163b,$ac6d0ca6,$0a1a0712,
         $fc5277fb,$5a257c4f,$6bcd66d2,$cdba6d66,$081d53e8,$ae6a585c,$9f8242c1,$39f54975,
         $a863a552,$0e14aee6,$3ffcb47b,$998bbfcf,$5c2c8141,$fa5b8af5,$cbb39068,$6dc49bdc,
         $9b8ceb35,$3dfbe081,$0c13fa1c,$aa64f1a8,$6fc3cf26,$c9b4c492,$f85cde0f,$5e2bd5bb,
         $440b7579,$e27c7ecd,$d3946450,$75e36fe4,$b044516a,$16335ade,$27db4043,$81ac4bf7,
         $77e43b1e,$d19330aa,$e07b2a37,$460c2183,$83ab1f0d,$25dc14b9,$14340e24,$b2430590,
         $23d5e9b7,$85a2e203,$b44af89e,$123df32a,$d79acda4,$71edc610,$4005dc8d,$e672d739,
         $103aa7d0,$b64dac64,$87a5b6f9,$21d2bd4d,$e47583c3,$42028877,$73ea92ea,$d59d995e,
         $8bb64ce5,$2dc14751,$1c295dcc,$ba5e5678,$7ff968f6,$d98e6342,$e86679df,$4e11726b,
         $b8590282,$1e2e0936,$2fc613ab,$89b1181f,$4c162691,$ea612d25,$db8937b8,$7dfe3c0c,
         $ec68d02b,$4a1fdb9f,$7bf7c102,$dd80cab6,$1827f438,$be50ff8c,$8fb8e511,$29cfeea5,
         $df879e4c,$79f095f8,$48188f65,$ee6f84d1,$2bc8ba5f,$8dbfb1eb,$bc57ab76,$1a20a0c2,
         $8816eaf2,$2e61e146,$1f89fbdb,$b9fef06f,$7c59cee1,$da2ec555,$ebc6dfc8,$4db1d47c,
         $bbf9a495,$1d8eaf21,$2c66b5bc,$8a11be08,$4fb68086,$e9c18b32,$d82991af,$7e5e9a1b,
         $efc8763c,$49bf7d88,$78576715,$de206ca1,$1b87522f,$bdf0599b,$8c184306,$2a6f48b2,
         $dc27385b,$7a5033ef,$4bb82972,$edcf22c6,$28681c48,$8e1f17fc,$bff70d61,$198006d5,
         $47abd36e,$e1dcd8da,$d034c247,$7643c9f3,$b3e4f77d,$1593fcc9,$247be654,$820cede0,
         $74449d09,$d23396bd,$e3db8c20,$45ac8794,$800bb91a,$267cb2ae,$1794a833,$b1e3a387,
         $20754fa0,$86024414,$b7ea5e89,$119d553d,$d43a6bb3,$724d6007,$43a57a9a,$e5d2712e,
         $139a01c7,$b5ed0a73,$840510ee,$22721b5a,$e7d525d4,$41a22e60,$704a34fd,$d63d3f49,
         $cc1d9f8b,$6a6a943f,$5b828ea2,$fdf58516,$3852bb98,$9e25b02c,$afcdaab1,$09baa105,
         $fff2d1ec,$5985da58,$686dc0c5,$ce1acb71,$0bbdf5ff,$adcafe4b,$9c22e4d6,$3a55ef62,
         $abc30345,$0db408f1,$3c5c126c,$9a2b19d8,$5f8c2756,$f9fb2ce2,$c813367f,$6e643dcb,
         $982c4d22,$3e5b4696,$0fb35c0b,$a9c457bf,$6c636931,$ca146285,$fbfc7818,$5d8b73ac,
         $03a0a617,$a5d7ada3,$943fb73e,$3248bc8a,$f7ef8204,$519889b0,$6070932d,$c6079899,
         $304fe870,$9638e3c4,$a7d0f959,$01a7f2ed,$c400cc63,$6277c7d7,$539fdd4a,$f5e8d6fe,
         $647e3ad9,$c209316d,$f3e12bf0,$55962044,$90311eca,$3646157e,$07ae0fe3,$a1d90457,
         $579174be,$f1e67f0a,$c00e6597,$66796e23,$a3de50ad,$05a95b19,$34414184,$92364a30
        ),
        (
         $00000000,$ccaa009e,$4225077d,$8e8f07e3,$844a0efa,$48e00e64,$c66f0987,$0ac50919,
         $d3e51bb5,$1f4f1b2b,$91c01cc8,$5d6a1c56,$57af154f,$9b0515d1,$158a1232,$d92012ac,
         $7cbb312b,$b01131b5,$3e9e3656,$f23436c8,$f8f13fd1,$345b3f4f,$bad438ac,$767e3832,
         $af5e2a9e,$63f42a00,$ed7b2de3,$21d12d7d,$2b142464,$e7be24fa,$69312319,$a59b2387,
         $f9766256,$35dc62c8,$bb53652b,$77f965b5,$7d3c6cac,$b1966c32,$3f196bd1,$f3b36b4f,
         $2a9379e3,$e639797d,$68b67e9e,$a41c7e00,$aed97719,$62737787,$ecfc7064,$205670fa,
         $85cd537d,$496753e3,$c7e85400,$0b42549e,$01875d87,$cd2d5d19,$43a25afa,$8f085a64,
         $562848c8,$9a824856,$140d4fb5,$d8a74f2b,$d2624632,$1ec846ac,$9047414f,$5ced41d1,
         $299dc2ed,$e537c273,$6bb8c590,$a712c50e,$add7cc17,$617dcc89,$eff2cb6a,$2358cbf4,
         $fa78d958,$36d2d9c6,$b85dde25,$74f7debb,$7e32d7a2,$b298d73c,$3c17d0df,$f0bdd041,
         $5526f3c6,$998cf358,$1703f4bb,$dba9f425,$d16cfd3c,$1dc6fda2,$9349fa41,$5fe3fadf,
         $86c3e873,$4a69e8ed,$c4e6ef0e,$084cef90,$0289e689,$ce23e617,$40ace1f4,$8c06e16a,
         $d0eba0bb,$1c41a025,$92cea7c6,$5e64a758,$54a1ae41,$980baedf,$1684a93c,$da2ea9a2,
         $030ebb0e,$cfa4bb90,$412bbc73,$8d81bced,$8744b5f4,$4beeb56a,$c561b289,$09cbb217,
         $ac509190,$60fa910e,$ee7596ed,$22df9673,$281a9f6a,$e4b09ff4,$6a3f9817,$a6959889,
         $7fb58a25,$b31f8abb,$3d908d58,$f13a8dc6,$fbff84df,$37558441,$b9da83a2,$7570833c,
         $533b85da,$9f918544,$111e82a7,$ddb48239,$d7718b20,$1bdb8bbe,$95548c5d,$59fe8cc3,
         $80de9e6f,$4c749ef1,$c2fb9912,$0e51998c,$04949095,$c83e900b,$46b197e8,$8a1b9776,
         $2f80b4f1,$e32ab46f,$6da5b38c,$a10fb312,$abcaba0b,$6760ba95,$e9efbd76,$2545bde8,
         $fc65af44,$30cfafda,$be40a839,$72eaa8a7,$782fa1be,$b485a120,$3a0aa6c3,$f6a0a65d,
         $aa4de78c,$66e7e712,$e868e0f1,$24c2e06f,$2e07e976,$e2ade9e8,$6c22ee0b,$a088ee95,
         $79a8fc39,$b502fca7,$3b8dfb44,$f727fbda,$fde2f2c3,$3148f25d,$bfc7f5be,$736df520,
         $d6f6d6a7,$1a5cd639,$94d3d1da,$5879d144,$52bcd85d,$9e16d8c3,$1099df20,$dc33dfbe,
         $0513cd12,$c9b9cd8c,$4736ca6f,$8b9ccaf1,$8159c3e8,$4df3c376,$c37cc495,$0fd6c40b,
         $7aa64737,$b60c47a9,$3883404a,$f42940d4,$feec49cd,$32464953,$bcc94eb0,$70634e2e,
         $a9435c82,$65e95c1c,$eb665bff,$27cc5b61,$2d095278,$e1a352e6,$6f2c5505,$a386559b,
         $061d761c,$cab77682,$44387161,$889271ff,$825778e6,$4efd7878,$c0727f9b,$0cd87f05,
         $d5f86da9,$19526d37,$97dd6ad4,$5b776a4a,$51b26353,$9d1863cd,$1397642e,$df3d64b0,
         $83d02561,$4f7a25ff,$c1f5221c,$0d5f2282,$079a2b9b,$cb302b05,$45bf2ce6,$89152c78,
         $50353ed4,$9c9f3e4a,$121039a9,$deba3937,$d47f302e,$18d530b0,$965a3753,$5af037cd,
         $ff6b144a,$33c114d4,$bd4e1337,$71e413a9,$7b211ab0,$b78b1a2e,$39041dcd,$f5ae1d53,
         $2c8e0fff,$e0240f61,$6eab0882,$a201081c,$a8c40105,$646e019b,$eae10678,$264b06e6
        ),
        (
         $00000000,$177b1443,$2ef62886,$398d3cc5,$5dec510c,$4a97454f,$731a798a,$64616dc9,
         $bbd8a218,$aca3b65b,$952e8a9e,$82559edd,$e634f314,$f14fe757,$c8c2db92,$dfb9cfd1,
         $acc04271,$bbbb5632,$82366af7,$954d7eb4,$f12c137d,$e657073e,$dfda3bfb,$c8a12fb8,
         $1718e069,$0063f42a,$39eec8ef,$2e95dcac,$4af4b165,$5d8fa526,$640299e3,$73798da0,
         $82f182a3,$958a96e0,$ac07aa25,$bb7cbe66,$df1dd3af,$c866c7ec,$f1ebfb29,$e690ef6a,
         $392920bb,$2e5234f8,$17df083d,$00a41c7e,$64c571b7,$73be65f4,$4a335931,$5d484d72,
         $2e31c0d2,$394ad491,$00c7e854,$17bcfc17,$73dd91de,$64a6859d,$5d2bb958,$4a50ad1b,
         $95e962ca,$82927689,$bb1f4a4c,$ac645e0f,$c80533c6,$df7e2785,$e6f31b40,$f1880f03,
         $de920307,$c9e91744,$f0642b81,$e71f3fc2,$837e520b,$94054648,$ad887a8d,$baf36ece,
         $654aa11f,$7231b55c,$4bbc8999,$5cc79dda,$38a6f013,$2fdde450,$1650d895,$012bccd6,
         $72524176,$65295535,$5ca469f0,$4bdf7db3,$2fbe107a,$38c50439,$014838fc,$16332cbf,
         $c98ae36e,$def1f72d,$e77ccbe8,$f007dfab,$9466b262,$831da621,$ba909ae4,$adeb8ea7,
         $5c6381a4,$4b1895e7,$7295a922,$65eebd61,$018fd0a8,$16f4c4eb,$2f79f82e,$3802ec6d,
         $e7bb23bc,$f0c037ff,$c94d0b3a,$de361f79,$ba5772b0,$ad2c66f3,$94a15a36,$83da4e75,
         $f0a3c3d5,$e7d8d796,$de55eb53,$c92eff10,$ad4f92d9,$ba34869a,$83b9ba5f,$94c2ae1c,
         $4b7b61cd,$5c00758e,$658d494b,$72f65d08,$169730c1,$01ec2482,$38611847,$2f1a0c04,
         $6655004f,$712e140c,$48a328c9,$5fd83c8a,$3bb95143,$2cc24500,$154f79c5,$02346d86,
         $dd8da257,$caf6b614,$f37b8ad1,$e4009e92,$8061f35b,$971ae718,$ae97dbdd,$b9eccf9e,
         $ca95423e,$ddee567d,$e4636ab8,$f3187efb,$97791332,$80020771,$b98f3bb4,$aef42ff7,
         $714de026,$6636f465,$5fbbc8a0,$48c0dce3,$2ca1b12a,$3bdaa569,$025799ac,$152c8def,
         $e4a482ec,$f3df96af,$ca52aa6a,$dd29be29,$b948d3e0,$ae33c7a3,$97befb66,$80c5ef25,
         $5f7c20f4,$480734b7,$718a0872,$66f11c31,$029071f8,$15eb65bb,$2c66597e,$3b1d4d3d,
         $4864c09d,$5f1fd4de,$6692e81b,$71e9fc58,$15889191,$02f385d2,$3b7eb917,$2c05ad54,
         $f3bc6285,$e4c776c6,$dd4a4a03,$ca315e40,$ae503389,$b92b27ca,$80a61b0f,$97dd0f4c,
         $b8c70348,$afbc170b,$96312bce,$814a3f8d,$e52b5244,$f2504607,$cbdd7ac2,$dca66e81,
         $031fa150,$1464b513,$2de989d6,$3a929d95,$5ef3f05c,$4988e41f,$7005d8da,$677ecc99,
         $14074139,$037c557a,$3af169bf,$2d8a7dfc,$49eb1035,$5e900476,$671d38b3,$70662cf0,
         $afdfe321,$b8a4f762,$8129cba7,$9652dfe4,$f233b22d,$e548a66e,$dcc59aab,$cbbe8ee8,
         $3a3681eb,$2d4d95a8,$14c0a96d,$03bbbd2e,$67dad0e7,$70a1c4a4,$492cf861,$5e57ec22,
         $81ee23f3,$969537b0,$af180b75,$b8631f36,$dc0272ff,$cb7966bc,$f2f45a79,$e58f4e3a,
         $96f6c39a,$818dd7d9,$b800eb1c,$af7bff5f,$cb1a9296,$dc6186d5,$e5ecba10,$f297ae53,
         $2d2e6182,$3a5575c1,$03d84904,$14a35d47,$70c2308e,$67b924cd,$5e341808,$494f0c4b
        ),
        (
         $00000000,$efc26b3e,$04f5d03d,$eb37bb03,$09eba07a,$e629cb44,$0d1e7047,$e2dc1b79,
         $13d740f4,$fc152bca,$172290c9,$f8e0fbf7,$1a3ce08e,$f5fe8bb0,$1ec930b3,$f10b5b8d,
         $27ae81e8,$c86cead6,$235b51d5,$cc993aeb,$2e452192,$c1874aac,$2ab0f1af,$c5729a91,
         $3479c11c,$dbbbaa22,$308c1121,$df4e7a1f,$3d926166,$d2500a58,$3967b15b,$d6a5da65,
         $4f5d03d0,$a09f68ee,$4ba8d3ed,$a46ab8d3,$46b6a3aa,$a974c894,$42437397,$ad8118a9,
         $5c8a4324,$b348281a,$587f9319,$b7bdf827,$5561e35e,$baa38860,$51943363,$be56585d,
         $68f38238,$8731e906,$6c065205,$83c4393b,$61182242,$8eda497c,$65edf27f,$8a2f9941,
         $7b24c2cc,$94e6a9f2,$7fd112f1,$901379cf,$72cf62b6,$9d0d0988,$763ab28b,$99f8d9b5,
         $9eba07a0,$71786c9e,$9a4fd79d,$758dbca3,$9751a7da,$7893cce4,$93a477e7,$7c661cd9,
         $8d6d4754,$62af2c6a,$89989769,$665afc57,$8486e72e,$6b448c10,$80733713,$6fb15c2d,
         $b9148648,$56d6ed76,$bde15675,$52233d4b,$b0ff2632,$5f3d4d0c,$b40af60f,$5bc89d31,
         $aac3c6bc,$4501ad82,$ae361681,$41f47dbf,$a32866c6,$4cea0df8,$a7ddb6fb,$481fddc5,
         $d1e70470,$3e256f4e,$d512d44d,$3ad0bf73,$d80ca40a,$37cecf34,$dcf97437,$333b1f09,
         $c2304484,$2df22fba,$c6c594b9,$2907ff87,$cbdbe4fe,$24198fc0,$cf2e34c3,$20ec5ffd,
         $f6498598,$198beea6,$f2bc55a5,$1d7e3e9b,$ffa225e2,$10604edc,$fb57f5df,$14959ee1,
         $e59ec56c,$0a5cae52,$e16b1551,$0ea97e6f,$ec756516,$03b70e28,$e880b52b,$0742de15,
         $e6050901,$09c7623f,$e2f0d93c,$0d32b202,$efeea97b,$002cc245,$eb1b7946,$04d91278,
         $f5d249f5,$1a1022cb,$f12799c8,$1ee5f2f6,$fc39e98f,$13fb82b1,$f8cc39b2,$170e528c,
         $c1ab88e9,$2e69e3d7,$c55e58d4,$2a9c33ea,$c8402893,$278243ad,$ccb5f8ae,$23779390,
         $d27cc81d,$3dbea323,$d6891820,$394b731e,$db976867,$34550359,$df62b85a,$30a0d364,
         $a9580ad1,$469a61ef,$adaddaec,$426fb1d2,$a0b3aaab,$4f71c195,$a4467a96,$4b8411a8,
         $ba8f4a25,$554d211b,$be7a9a18,$51b8f126,$b364ea5f,$5ca68161,$b7913a62,$5853515c,
         $8ef68b39,$6134e007,$8a035b04,$65c1303a,$871d2b43,$68df407d,$83e8fb7e,$6c2a9040,
         $9d21cbcd,$72e3a0f3,$99d41bf0,$761670ce,$94ca6bb7,$7b080089,$903fbb8a,$7ffdd0b4,
         $78bf0ea1,$977d659f,$7c4ade9c,$9388b5a2,$7154aedb,$9e96c5e5,$75a17ee6,$9a6315d8,
         $6b684e55,$84aa256b,$6f9d9e68,$805ff556,$6283ee2f,$8d418511,$66763e12,$89b4552c,
         $5f118f49,$b0d3e477,$5be45f74,$b426344a,$56fa2f33,$b938440d,$520fff0e,$bdcd9430,
         $4cc6cfbd,$a304a483,$48331f80,$a7f174be,$452d6fc7,$aaef04f9,$41d8bffa,$ae1ad4c4,
         $37e20d71,$d820664f,$3317dd4c,$dcd5b672,$3e09ad0b,$d1cbc635,$3afc7d36,$d53e1608,
         $24354d85,$cbf726bb,$20c09db8,$cf02f686,$2ddeedff,$c21c86c1,$292b3dc2,$c6e956fc,
         $104c8c99,$ff8ee7a7,$14b95ca4,$fb7b379a,$19a72ce3,$f66547dd,$1d52fcde,$f29097e0,
         $039bcc6d,$ec59a753,$076e1c50,$e8ac776e,$0a706c17,$e5b20729,$0e85bc2a,$e147d714
        ),
        (
         $00000000,$c18edfc0,$586cb9c1,$99e26601,$b0d97382,$7157ac42,$e8b5ca43,$293b1583,
         $bac3e145,$7b4d3e85,$e2af5884,$23218744,$0a1a92c7,$cb944d07,$52762b06,$93f8f4c6,
         $aef6c4cb,$6f781b0b,$f69a7d0a,$3714a2ca,$1e2fb749,$dfa16889,$46430e88,$87cdd148,
         $1435258e,$d5bbfa4e,$4c599c4f,$8dd7438f,$a4ec560c,$656289cc,$fc80efcd,$3d0e300d,
         $869c8fd7,$47125017,$def03616,$1f7ee9d6,$3645fc55,$f7cb2395,$6e294594,$afa79a54,
         $3c5f6e92,$fdd1b152,$6433d753,$a5bd0893,$8c861d10,$4d08c2d0,$d4eaa4d1,$15647b11,
         $286a4b1c,$e9e494dc,$7006f2dd,$b1882d1d,$98b3389e,$593de75e,$c0df815f,$01515e9f,
         $92a9aa59,$53277599,$cac51398,$0b4bcc58,$2270d9db,$e3fe061b,$7a1c601a,$bb92bfda,
         $d64819ef,$17c6c62f,$8e24a02e,$4faa7fee,$66916a6d,$a71fb5ad,$3efdd3ac,$ff730c6c,
         $6c8bf8aa,$ad05276a,$34e7416b,$f5699eab,$dc528b28,$1ddc54e8,$843e32e9,$45b0ed29,
         $78bedd24,$b93002e4,$20d264e5,$e15cbb25,$c867aea6,$09e97166,$900b1767,$5185c8a7,
         $c27d3c61,$03f3e3a1,$9a1185a0,$5b9f5a60,$72a44fe3,$b32a9023,$2ac8f622,$eb4629e2,
         $50d49638,$915a49f8,$08b82ff9,$c936f039,$e00de5ba,$21833a7a,$b8615c7b,$79ef83bb,
         $ea17777d,$2b99a8bd,$b27bcebc,$73f5117c,$5ace04ff,$9b40db3f,$02a2bd3e,$c32c62fe,
         $fe2252f3,$3fac8d33,$a64eeb32,$67c034f2,$4efb2171,$8f75feb1,$169798b0,$d7194770,
         $44e1b3b6,$856f6c76,$1c8d0a77,$dd03d5b7,$f438c034,$35b61ff4,$ac5479f5,$6ddaa635,
         $77e1359f,$b66fea5f,$2f8d8c5e,$ee03539e,$c738461d,$06b699dd,$9f54ffdc,$5eda201c,
         $cd22d4da,$0cac0b1a,$954e6d1b,$54c0b2db,$7dfba758,$bc757898,$25971e99,$e419c159,
         $d917f154,$18992e94,$817b4895,$40f59755,$69ce82d6,$a8405d16,$31a23b17,$f02ce4d7,
         $63d41011,$a25acfd1,$3bb8a9d0,$fa367610,$d30d6393,$1283bc53,$8b61da52,$4aef0592,
         $f17dba48,$30f36588,$a9110389,$689fdc49,$41a4c9ca,$802a160a,$19c8700b,$d846afcb,
         $4bbe5b0d,$8a3084cd,$13d2e2cc,$d25c3d0c,$fb67288f,$3ae9f74f,$a30b914e,$62854e8e,
         $5f8b7e83,$9e05a143,$07e7c742,$c6691882,$ef520d01,$2edcd2c1,$b73eb4c0,$76b06b00,
         $e5489fc6,$24c64006,$bd242607,$7caaf9c7,$5591ec44,$941f3384,$0dfd5585,$cc738a45,
         $a1a92c70,$6027f3b0,$f9c595b1,$384b4a71,$11705ff2,$d0fe8032,$491ce633,$889239f3,
         $1b6acd35,$dae412f5,$430674f4,$8288ab34,$abb3beb7,$6a3d6177,$f3df0776,$3251d8b6,
         $0f5fe8bb,$ced1377b,$5733517a,$96bd8eba,$bf869b39,$7e0844f9,$e7ea22f8,$2664fd38,
         $b59c09fe,$7412d63e,$edf0b03f,$2c7e6fff,$05457a7c,$c4cba5bc,$5d29c3bd,$9ca71c7d,
         $2735a3a7,$e6bb7c67,$7f591a66,$bed7c5a6,$97ecd025,$56620fe5,$cf8069e4,$0e0eb624,
         $9df642e2,$5c789d22,$c59afb23,$041424e3,$2d2f3160,$eca1eea0,$754388a1,$b4cd5761,
         $89c3676c,$484db8ac,$d1afdead,$1021016d,$391a14ee,$f894cb2e,$6176ad2f,$a0f872ef,
         $33008629,$f28e59e9,$6b6c3fe8,$aae2e028,$83d9f5ab,$42572a6b,$dbb54c6a,$1a3b93aa
        ),
        (
         $00000000,$9ba54c6f,$ec3b9e9f,$779ed2f0,$03063b7f,$98a37710,$ef3da5e0,$7498e98f,
         $060c76fe,$9da93a91,$ea37e861,$7192a40e,$050a4d81,$9eaf01ee,$e931d31e,$72949f71,
         $0c18edfc,$97bda193,$e0237363,$7b863f0c,$0f1ed683,$94bb9aec,$e325481c,$78800473,
         $0a149b02,$91b1d76d,$e62f059d,$7d8a49f2,$0912a07d,$92b7ec12,$e5293ee2,$7e8c728d,
         $1831dbf8,$83949797,$f40a4567,$6faf0908,$1b37e087,$8092ace8,$f70c7e18,$6ca93277,
         $1e3dad06,$8598e169,$f2063399,$69a37ff6,$1d3b9679,$869eda16,$f10008e6,$6aa54489,
         $14293604,$8f8c7a6b,$f812a89b,$63b7e4f4,$172f0d7b,$8c8a4114,$fb1493e4,$60b1df8b,
         $122540fa,$89800c95,$fe1ede65,$65bb920a,$11237b85,$8a8637ea,$fd18e51a,$66bda975,
         $3063b7f0,$abc6fb9f,$dc58296f,$47fd6500,$33658c8f,$a8c0c0e0,$df5e1210,$44fb5e7f,
         $366fc10e,$adca8d61,$da545f91,$41f113fe,$3569fa71,$aeccb61e,$d95264ee,$42f72881,
         $3c7b5a0c,$a7de1663,$d040c493,$4be588fc,$3f7d6173,$a4d82d1c,$d346ffec,$48e3b383,
         $3a772cf2,$a1d2609d,$d64cb26d,$4de9fe02,$3971178d,$a2d45be2,$d54a8912,$4eefc57d,
         $28526c08,$b3f72067,$c469f297,$5fccbef8,$2b545777,$b0f11b18,$c76fc9e8,$5cca8587,
         $2e5e1af6,$b5fb5699,$c2658469,$59c0c806,$2d582189,$b6fd6de6,$c163bf16,$5ac6f379,
         $244a81f4,$bfefcd9b,$c8711f6b,$53d45304,$274cba8b,$bce9f6e4,$cb772414,$50d2687b,
         $2246f70a,$b9e3bb65,$ce7d6995,$55d825fa,$2140cc75,$bae5801a,$cd7b52ea,$56de1e85,
         $60c76fe0,$fb62238f,$8cfcf17f,$1759bd10,$63c1549f,$f86418f0,$8ffaca00,$145f866f,
         $66cb191e,$fd6e5571,$8af08781,$1155cbee,$65cd2261,$fe686e0e,$89f6bcfe,$1253f091,
         $6cdf821c,$f77ace73,$80e41c83,$1b4150ec,$6fd9b963,$f47cf50c,$83e227fc,$18476b93,
         $6ad3f4e2,$f176b88d,$86e86a7d,$1d4d2612,$69d5cf9d,$f27083f2,$85ee5102,$1e4b1d6d,
         $78f6b418,$e353f877,$94cd2a87,$0f6866e8,$7bf08f67,$e055c308,$97cb11f8,$0c6e5d97,
         $7efac2e6,$e55f8e89,$92c15c79,$09641016,$7dfcf999,$e659b5f6,$91c76706,$0a622b69,
         $74ee59e4,$ef4b158b,$98d5c77b,$03708b14,$77e8629b,$ec4d2ef4,$9bd3fc04,$0076b06b,
         $72e22f1a,$e9476375,$9ed9b185,$057cfdea,$71e41465,$ea41580a,$9ddf8afa,$067ac695,
         $50a4d810,$cb01947f,$bc9f468f,$273a0ae0,$53a2e36f,$c807af00,$bf997df0,$243c319f,
         $56a8aeee,$cd0de281,$ba933071,$21367c1e,$55ae9591,$ce0bd9fe,$b9950b0e,$22304761,
         $5cbc35ec,$c7197983,$b087ab73,$2b22e71c,$5fba0e93,$c41f42fc,$b381900c,$2824dc63,
         $5ab04312,$c1150f7d,$b68bdd8d,$2d2e91e2,$59b6786d,$c2133402,$b58de6f2,$2e28aa9d,
         $489503e8,$d3304f87,$a4ae9d77,$3f0bd118,$4b933897,$d03674f8,$a7a8a608,$3c0dea67,
         $4e997516,$d53c3979,$a2a2eb89,$3907a7e6,$4d9f4e69,$d63a0206,$a1a4d0f6,$3a019c99,
         $448dee14,$df28a27b,$a8b6708b,$33133ce4,$478bd56b,$dc2e9904,$abb04bf4,$3015079b,
         $428198ea,$d924d485,$aeba0675,$351f4a1a,$4187a395,$da22effa,$adbc3d0a,$36197165
        ),
        (
         $00000000,$dd96d985,$605cb54b,$bdca6cce,$c0b96a96,$1d2fb313,$a0e5dfdd,$7d730658,
         $5a03d36d,$87950ae8,$3a5f6626,$e7c9bfa3,$9abab9fb,$472c607e,$fae60cb0,$2770d535,
         $b407a6da,$69917f5f,$d45b1391,$09cdca14,$74becc4c,$a92815c9,$14e27907,$c974a082,
         $ee0475b7,$3392ac32,$8e58c0fc,$53ce1979,$2ebd1f21,$f32bc6a4,$4ee1aa6a,$937773ef,
         $b37e4bf5,$6ee89270,$d322febe,$0eb4273b,$73c72163,$ae51f8e6,$139b9428,$ce0d4dad,
         $e97d9898,$34eb411d,$89212dd3,$54b7f456,$29c4f20e,$f4522b8b,$49984745,$940e9ec0,
         $0779ed2f,$daef34aa,$67255864,$bab381e1,$c7c087b9,$1a565e3c,$a79c32f2,$7a0aeb77,
         $5d7a3e42,$80ece7c7,$3d268b09,$e0b0528c,$9dc354d4,$40558d51,$fd9fe19f,$2009381a,
         $bd8d91ab,$601b482e,$ddd124e0,$0047fd65,$7d34fb3d,$a0a222b8,$1d684e76,$c0fe97f3,
         $e78e42c6,$3a189b43,$87d2f78d,$5a442e08,$27372850,$faa1f1d5,$476b9d1b,$9afd449e,
         $098a3771,$d41ceef4,$69d6823a,$b4405bbf,$c9335de7,$14a58462,$a96fe8ac,$74f93129,
         $5389e41c,$8e1f3d99,$33d55157,$ee4388d2,$93308e8a,$4ea6570f,$f36c3bc1,$2efae244,
         $0ef3da5e,$d36503db,$6eaf6f15,$b339b690,$ce4ab0c8,$13dc694d,$ae160583,$7380dc06,
         $54f00933,$8966d0b6,$34acbc78,$e93a65fd,$944963a5,$49dfba20,$f415d6ee,$29830f6b,
         $baf47c84,$6762a501,$daa8c9cf,$073e104a,$7a4d1612,$a7dbcf97,$1a11a359,$c7877adc,
         $e0f7afe9,$3d61766c,$80ab1aa2,$5d3dc327,$204ec57f,$fdd81cfa,$40127034,$9d84a9b1,
         $a06a2517,$7dfcfc92,$c036905c,$1da049d9,$60d34f81,$bd459604,$008ffaca,$dd19234f,
         $fa69f67a,$27ff2fff,$9a354331,$47a39ab4,$3ad09cec,$e7464569,$5a8c29a7,$871af022,
         $146d83cd,$c9fb5a48,$74313686,$a9a7ef03,$d4d4e95b,$094230de,$b4885c10,$691e8595,
         $4e6e50a0,$93f88925,$2e32e5eb,$f3a43c6e,$8ed73a36,$5341e3b3,$ee8b8f7d,$331d56f8,
         $13146ee2,$ce82b767,$7348dba9,$aede022c,$d3ad0474,$0e3bddf1,$b3f1b13f,$6e6768ba,
         $4917bd8f,$9481640a,$294b08c4,$f4ddd141,$89aed719,$54380e9c,$e9f26252,$3464bbd7,
         $a713c838,$7a8511bd,$c74f7d73,$1ad9a4f6,$67aaa2ae,$ba3c7b2b,$07f617e5,$da60ce60,
         $fd101b55,$2086c2d0,$9d4cae1e,$40da779b,$3da971c3,$e03fa846,$5df5c488,$80631d0d,
         $1de7b4bc,$c0716d39,$7dbb01f7,$a02dd872,$dd5ede2a,$00c807af,$bd026b61,$6094b2e4,
         $47e467d1,$9a72be54,$27b8d29a,$fa2e0b1f,$875d0d47,$5acbd4c2,$e701b80c,$3a976189,
         $a9e01266,$7476cbe3,$c9bca72d,$142a7ea8,$695978f0,$b4cfa175,$0905cdbb,$d493143e,
         $f3e3c10b,$2e75188e,$93bf7440,$4e29adc5,$335aab9d,$eecc7218,$53061ed6,$8e90c753,
         $ae99ff49,$730f26cc,$cec54a02,$13539387,$6e2095df,$b3b64c5a,$0e7c2094,$d3eaf911,
         $f49a2c24,$290cf5a1,$94c6996f,$495040ea,$342346b2,$e9b59f37,$547ff3f9,$89e92a7c,
         $1a9e5993,$c7088016,$7ac2ecd8,$a754355d,$da273305,$07b1ea80,$ba7b864e,$67ed5fcb,
         $409d8afe,$9d0b537b,$20c13fb5,$fd57e630,$8024e068,$5db239ed,$e0785523,$3dee8ca6
        ),
        (
         $00000000,$9d0fe176,$e16ec4ad,$7c6125db,$19ac8f1b,$84a36e6d,$f8c24bb6,$65cdaac0,
         $33591e36,$ae56ff40,$d237da9b,$4f383bed,$2af5912d,$b7fa705b,$cb9b5580,$5694b4f6,
         $66b23c6c,$fbbddd1a,$87dcf8c1,$1ad319b7,$7f1eb377,$e2115201,$9e7077da,$037f96ac,
         $55eb225a,$c8e4c32c,$b485e6f7,$298a0781,$4c47ad41,$d1484c37,$ad2969ec,$3026889a,
         $cd6478d8,$506b99ae,$2c0abc75,$b1055d03,$d4c8f7c3,$49c716b5,$35a6336e,$a8a9d218,
         $fe3d66ee,$63328798,$1f53a243,$825c4335,$e791e9f5,$7a9e0883,$06ff2d58,$9bf0cc2e,
         $abd644b4,$36d9a5c2,$4ab88019,$d7b7616f,$b27acbaf,$2f752ad9,$53140f02,$ce1bee74,
         $988f5a82,$0580bbf4,$79e19e2f,$e4ee7f59,$8123d599,$1c2c34ef,$604d1134,$fd42f042,
         $41b9f7f1,$dcb61687,$a0d7335c,$3dd8d22a,$581578ea,$c51a999c,$b97bbc47,$24745d31,
         $72e0e9c7,$efef08b1,$938e2d6a,$0e81cc1c,$6b4c66dc,$f64387aa,$8a22a271,$172d4307,
         $270bcb9d,$ba042aeb,$c6650f30,$5b6aee46,$3ea74486,$a3a8a5f0,$dfc9802b,$42c6615d,
         $1452d5ab,$895d34dd,$f53c1106,$6833f070,$0dfe5ab0,$90f1bbc6,$ec909e1d,$719f7f6b,
         $8cdd8f29,$11d26e5f,$6db34b84,$f0bcaaf2,$95710032,$087ee144,$741fc49f,$e91025e9,
         $bf84911f,$228b7069,$5eea55b2,$c3e5b4c4,$a6281e04,$3b27ff72,$4746daa9,$da493bdf,
         $ea6fb345,$77605233,$0b0177e8,$960e969e,$f3c33c5e,$6eccdd28,$12adf8f3,$8fa21985,
         $d936ad73,$44394c05,$385869de,$a55788a8,$c09a2268,$5d95c31e,$21f4e6c5,$bcfb07b3,
         $8373efe2,$1e7c0e94,$621d2b4f,$ff12ca39,$9adf60f9,$07d0818f,$7bb1a454,$e6be4522,
         $b02af1d4,$2d2510a2,$51443579,$cc4bd40f,$a9867ecf,$34899fb9,$48e8ba62,$d5e75b14,
         $e5c1d38e,$78ce32f8,$04af1723,$99a0f655,$fc6d5c95,$6162bde3,$1d039838,$800c794e,
         $d698cdb8,$4b972cce,$37f60915,$aaf9e863,$cf3442a3,$523ba3d5,$2e5a860e,$b3556778,
         $4e17973a,$d318764c,$af795397,$3276b2e1,$57bb1821,$cab4f957,$b6d5dc8c,$2bda3dfa,
         $7d4e890c,$e041687a,$9c204da1,$012facd7,$64e20617,$f9ede761,$858cc2ba,$188323cc,
         $28a5ab56,$b5aa4a20,$c9cb6ffb,$54c48e8d,$3109244d,$ac06c53b,$d067e0e0,$4d680196,
         $1bfcb560,$86f35416,$fa9271cd,$679d90bb,$02503a7b,$9f5fdb0d,$e33efed6,$7e311fa0,
         $c2ca1813,$5fc5f965,$23a4dcbe,$beab3dc8,$db669708,$4669767e,$3a0853a5,$a707b2d3,
         $f1930625,$6c9ce753,$10fdc288,$8df223fe,$e83f893e,$75306848,$09514d93,$945eace5,
         $a478247f,$3977c509,$4516e0d2,$d81901a4,$bdd4ab64,$20db4a12,$5cba6fc9,$c1b58ebf,
         $97213a49,$0a2edb3f,$764ffee4,$eb401f92,$8e8db552,$13825424,$6fe371ff,$f2ec9089,
         $0fae60cb,$92a181bd,$eec0a466,$73cf4510,$1602efd0,$8b0d0ea6,$f76c2b7d,$6a63ca0b,
         $3cf77efd,$a1f89f8b,$dd99ba50,$40965b26,$255bf1e6,$b8541090,$c435354b,$593ad43d,
         $691c5ca7,$f413bdd1,$8872980a,$157d797c,$70b0d3bc,$edbf32ca,$91de1711,$0cd1f667,
         $5a454291,$c74aa3e7,$bb2b863c,$2624674a,$43e9cd8a,$dee62cfc,$a2870927,$3f88e851
        ),
        (
         $00000000,$b9fbdbe8,$a886b191,$117d6a79,$8a7c6563,$3387be8b,$22fad4f2,$9b010f1a,
         $cf89cc87,$7672176f,$670f7d16,$def4a6fe,$45f5a9e4,$fc0e720c,$ed731875,$5488c39d,
         $44629f4f,$fd9944a7,$ece42ede,$551ff536,$ce1efa2c,$77e521c4,$66984bbd,$df639055,
         $8beb53c8,$32108820,$236de259,$9a9639b1,$019736ab,$b86ced43,$a911873a,$10ea5cd2,
         $88c53e9e,$313ee576,$20438f0f,$99b854e7,$02b95bfd,$bb428015,$aa3fea6c,$13c43184,
         $474cf219,$feb729f1,$efca4388,$56319860,$cd30977a,$74cb4c92,$65b626eb,$dc4dfd03,
         $cca7a1d1,$755c7a39,$64211040,$dddacba8,$46dbc4b2,$ff201f5a,$ee5d7523,$57a6aecb,
         $032e6d56,$bad5b6be,$aba8dcc7,$1253072f,$89520835,$30a9d3dd,$21d4b9a4,$982f624c,
         $cafb7b7d,$7300a095,$627dcaec,$db861104,$40871e1e,$f97cc5f6,$e801af8f,$51fa7467,
         $0572b7fa,$bc896c12,$adf4066b,$140fdd83,$8f0ed299,$36f50971,$27886308,$9e73b8e0,
         $8e99e432,$37623fda,$261f55a3,$9fe48e4b,$04e58151,$bd1e5ab9,$ac6330c0,$1598eb28,
         $411028b5,$f8ebf35d,$e9969924,$506d42cc,$cb6c4dd6,$7297963e,$63eafc47,$da1127af,
         $423e45e3,$fbc59e0b,$eab8f472,$53432f9a,$c8422080,$71b9fb68,$60c49111,$d93f4af9,
         $8db78964,$344c528c,$253138f5,$9ccae31d,$07cbec07,$be3037ef,$af4d5d96,$16b6867e,
         $065cdaac,$bfa70144,$aeda6b3d,$1721b0d5,$8c20bfcf,$35db6427,$24a60e5e,$9d5dd5b6,
         $c9d5162b,$702ecdc3,$6153a7ba,$d8a87c52,$43a97348,$fa52a8a0,$eb2fc2d9,$52d41931,
         $4e87f0bb,$f77c2b53,$e601412a,$5ffa9ac2,$c4fb95d8,$7d004e30,$6c7d2449,$d586ffa1,
         $810e3c3c,$38f5e7d4,$29888dad,$90735645,$0b72595f,$b28982b7,$a3f4e8ce,$1a0f3326,
         $0ae56ff4,$b31eb41c,$a263de65,$1b98058d,$80990a97,$3962d17f,$281fbb06,$91e460ee,
         $c56ca373,$7c97789b,$6dea12e2,$d411c90a,$4f10c610,$f6eb1df8,$e7967781,$5e6dac69,
         $c642ce25,$7fb915cd,$6ec47fb4,$d73fa45c,$4c3eab46,$f5c570ae,$e4b81ad7,$5d43c13f,
         $09cb02a2,$b030d94a,$a14db333,$18b668db,$83b767c1,$3a4cbc29,$2b31d650,$92ca0db8,
         $8220516a,$3bdb8a82,$2aa6e0fb,$935d3b13,$085c3409,$b1a7efe1,$a0da8598,$19215e70,
         $4da99ded,$f4524605,$e52f2c7c,$5cd4f794,$c7d5f88e,$7e2e2366,$6f53491f,$d6a892f7,
         $847c8bc6,$3d87502e,$2cfa3a57,$9501e1bf,$0e00eea5,$b7fb354d,$a6865f34,$1f7d84dc,
         $4bf54741,$f20e9ca9,$e373f6d0,$5a882d38,$c1892222,$7872f9ca,$690f93b3,$d0f4485b,
         $c01e1489,$79e5cf61,$6898a518,$d1637ef0,$4a6271ea,$f399aa02,$e2e4c07b,$5b1f1b93,
         $0f97d80e,$b66c03e6,$a711699f,$1eeab277,$85ebbd6d,$3c106685,$2d6d0cfc,$9496d714,
         $0cb9b558,$b5426eb0,$a43f04c9,$1dc4df21,$86c5d03b,$3f3e0bd3,$2e4361aa,$97b8ba42,
         $c33079df,$7acba237,$6bb6c84e,$d24d13a6,$494c1cbc,$f0b7c754,$e1caad2d,$583176c5,
         $48db2a17,$f120f1ff,$e05d9b86,$59a6406e,$c2a74f74,$7b5c949c,$6a21fee5,$d3da250d,
         $8752e690,$3ea93d78,$2fd45701,$962f8ce9,$0d2e83f3,$b4d5581b,$a5a83262,$1c53e98a
        ),
        (
         $00000000,$ae689191,$87a02563,$29c8b4f2,$d4314c87,$7a59dd16,$539169e4,$fdf9f875,
         $73139f4f,$dd7b0ede,$f4b3ba2c,$5adb2bbd,$a722d3c8,$094a4259,$2082f6ab,$8eea673a,
         $e6273e9e,$484faf0f,$61871bfd,$cfef8a6c,$32167219,$9c7ee388,$b5b6577a,$1bdec6eb,
         $9534a1d1,$3b5c3040,$129484b2,$bcfc1523,$4105ed56,$ef6d7cc7,$c6a5c835,$68cd59a4,
         $173f7b7d,$b957eaec,$909f5e1e,$3ef7cf8f,$c30e37fa,$6d66a66b,$44ae1299,$eac68308,
         $642ce432,$ca4475a3,$e38cc151,$4de450c0,$b01da8b5,$1e753924,$37bd8dd6,$99d51c47,
         $f11845e3,$5f70d472,$76b86080,$d8d0f111,$25290964,$8b4198f5,$a2892c07,$0ce1bd96,
         $820bdaac,$2c634b3d,$05abffcf,$abc36e5e,$563a962b,$f85207ba,$d19ab348,$7ff222d9,
         $2e7ef6fa,$8016676b,$a9ded399,$07b64208,$fa4fba7d,$54272bec,$7def9f1e,$d3870e8f,
         $5d6d69b5,$f305f824,$dacd4cd6,$74a5dd47,$895c2532,$2734b4a3,$0efc0051,$a09491c0,
         $c859c864,$663159f5,$4ff9ed07,$e1917c96,$1c6884e3,$b2001572,$9bc8a180,$35a03011,
         $bb4a572b,$1522c6ba,$3cea7248,$9282e3d9,$6f7b1bac,$c1138a3d,$e8db3ecf,$46b3af5e,
         $39418d87,$97291c16,$bee1a8e4,$10893975,$ed70c100,$43185091,$6ad0e463,$c4b875f2,
         $4a5212c8,$e43a8359,$cdf237ab,$639aa63a,$9e635e4f,$300bcfde,$19c37b2c,$b7abeabd,
         $df66b319,$710e2288,$58c6967a,$f6ae07eb,$0b57ff9e,$a53f6e0f,$8cf7dafd,$229f4b6c,
         $ac752c56,$021dbdc7,$2bd50935,$85bd98a4,$784460d1,$d62cf140,$ffe445b2,$518cd423,
         $5cfdedf4,$f2957c65,$db5dc897,$75355906,$88cca173,$26a430e2,$0f6c8410,$a1041581,
         $2fee72bb,$8186e32a,$a84e57d8,$0626c649,$fbdf3e3c,$55b7afad,$7c7f1b5f,$d2178ace,
         $badad36a,$14b242fb,$3d7af609,$93126798,$6eeb9fed,$c0830e7c,$e94bba8e,$47232b1f,
         $c9c94c25,$67a1ddb4,$4e696946,$e001f8d7,$1df800a2,$b3909133,$9a5825c1,$3430b450,
         $4bc29689,$e5aa0718,$cc62b3ea,$620a227b,$9ff3da0e,$319b4b9f,$1853ff6d,$b63b6efc,
         $38d109c6,$96b99857,$bf712ca5,$1119bd34,$ece04541,$4288d4d0,$6b406022,$c528f1b3,
         $ade5a817,$038d3986,$2a458d74,$842d1ce5,$79d4e490,$d7bc7501,$fe74c1f3,$501c5062,
         $def63758,$709ea6c9,$5956123b,$f73e83aa,$0ac77bdf,$a4afea4e,$8d675ebc,$230fcf2d,
         $72831b0e,$dceb8a9f,$f5233e6d,$5b4baffc,$a6b25789,$08dac618,$211272ea,$8f7ae37b,
         $01908441,$aff815d0,$8630a122,$285830b3,$d5a1c8c6,$7bc95957,$5201eda5,$fc697c34,
         $94a42590,$3accb401,$130400f3,$bd6c9162,$40956917,$eefdf886,$c7354c74,$695ddde5,
         $e7b7badf,$49df2b4e,$60179fbc,$ce7f0e2d,$3386f658,$9dee67c9,$b426d33b,$1a4e42aa,
         $65bc6073,$cbd4f1e2,$e21c4510,$4c74d481,$b18d2cf4,$1fe5bd65,$362d0997,$98459806,
         $16afff3c,$b8c76ead,$910fda5f,$3f674bce,$c29eb3bb,$6cf6222a,$453e96d8,$eb560749,
         $839b5eed,$2df3cf7c,$043b7b8e,$aa53ea1f,$57aa126a,$f9c283fb,$d00a3709,$7e62a698,
         $f088c1a2,$5ee05033,$7728e4c1,$d9407550,$24b98d25,$8ad11cb4,$a319a846,$0d7139d7
        )
       );

{$ifdef FALSE}
// Compute the CRC32 of the buffer, where the buffer length must be at least 64, and a multiple of 16.
function CRC32SSE42SIMD(aData:Pointer;aLength:TpvUInt64;aCRC:TpvUInt32):TpvUInt32; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
{$undef ClangCRC32SSE42SIMDVariant}
{$ifdef ClangCRC32SSE42SIMDVariant}
// Variant generated by Clang, but commented afterwards by hand in order to make it more readable
const LCPI0_0:array[0..1] of TpvUInt64=(0,7631803798);
      LCPI0_1:array[0..1] of TpvUInt64=(0,3433693342);
      LCPI0_2:array[0..1] of TpvUInt64=(0,8439010881);
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Prologue: save callee-saved XMM registers
 sub rsp,88 // allocate stack space
 movdqa oword ptr [rsp+64],xmm10
 movdqa oword ptr [rsp+48],xmm9
 movdqa oword ptr [rsp+32],xmm8
 movdqa oword ptr [rsp+16],xmm7
 movdqa oword ptr [rsp],xmm6

 // Load first 64 bytes and initialize CRC
 movdqu xmm1,oword ptr [rcx]    // load bytes 0-15
 movdqu xmm2,oword ptr [rcx+16] // load bytes 16-31
 movdqu xmm4,oword ptr [rcx+32] // load bytes 32-47
 movdqu xmm3,oword ptr [rcx+48] // load bytes 48-63
 movd xmm0,r8d                  // load initial CRC
 pxor xmm0,xmm1                 // xor CRC into first 16 bytes
 add rdx,-64                    // decrement length by 64
 add rcx,64                     // advance pointer by 64 bytes
 cmp rdx,64
 jb @Entry_Fold128              // if remaining length < 64, jump to 128-bit fold

{$ifdef fpc}
 movabs rax,5708721108          // k1 constant
{$else}
 mov rax,5708721108             // k1 constant
{$endif}
 movq xmm1,rax
 movdqu xmm5,oword ptr [rip+LCPI0_0] // k2 constant

 // Main loop for processing 64-byte blocks
@Loop_MainFold64:
 movdqa xmm6,xmm0            // copy low half
 pclmulqdq xmm6,xmm1,0       // carry-less multiply low by k1
 movdqa xmm7,xmm2            // copy lanes
 pclmulqdq xmm7,xmm1,0
 movdqa xmm8,xmm4
 pclmulqdq xmm8,xmm1,0
 movdqa xmm9,xmm3
 pclmulqdq xmm9,xmm1,0

 // Reduce high halves
 pclmulqdq xmm0,xmm5,17      // high-half multiply for xmm0
 pclmulqdq xmm2,xmm5,17
 pclmulqdq xmm4,xmm5,17
 pclmulqdq xmm3,xmm5,17

 // XOR in new data
 movdqu xmm10,oword ptr [rcx]
 pxor xmm10,xmm6                 // combine low result
 pxor xmm0,xmm10
 movdqu xmm6,oword ptr [rcx+16]
 pxor xmm6,xmm7
 pxor xmm2,xmm6
 movdqu xmm6,oword ptr [rcx+32]
 pxor xmm6,xmm8
 pxor xmm4,xmm6
 movdqu xmm6,oword ptr [rcx+48]
 pxor xmm6,xmm9
 pxor xmm3,xmm6

 add rdx,-64                         // next 64-byte block
 add rcx,64
 cmp rdx,63
 ja @Loop_MainFold64

 // Fold 64->128->64 bits
@Entry_Fold128:
{$ifdef fpc}
 movabs rax,6259578832               // k3 constant
{$else}
 mov rax,6259578832               // k3 constant
{$endif}
 movq xmm1,rax
 movdqa xmm5,xmm0
 pclmulqdq xmm5,xmm1,0               // fold low
 pxor xmm5,xmm2
 movdqu xmm2,oword ptr [rip+LCPI0_1] // k4 constant
 pclmulqdq xmm0,xmm2,17              // fold high
 pxor xmm0,xmm5

 // second fold stage
 movdqa xmm5,xmm0
 pclmulqdq xmm5,xmm1,0
 pxor xmm5,xmm4
 pclmulqdq xmm0,xmm2,17
 pxor xmm0,xmm5
 movdqa xmm4,xmm0
 pclmulqdq xmm4,xmm1,0
 pxor xmm4,xmm3
 pclmulqdq xmm0,xmm2,17
 pxor xmm0,xmm4

 cmp rdx,16
 jb @Label_TailSmall // if remaining length < 16, skip to small-tail processing

 // Tail processing for 16-byte blocks
 lea rax,[rdx-16]
 mov r8d,eax
 not r8d
 test r8b,48
 je @Label_After_Tail16
 mov r8d,eax
 shr r8d,4
 inc r8d
 and r8d,3

 // Process 16-byte blocks
@Loop_Tail16Fold:
 movdqu xmm3,oword ptr [rcx]
 movdqa xmm4,xmm0
 pclmulqdq xmm4,xmm1,0
 pxor xmm4,xmm3
 pclmulqdq xmm0,xmm2,17
 pxor xmm0,xmm4
 add rcx,16
 add rdx,-16
 dec r8
 jne @Loop_Tail16Fold

@Label_After_Tail16:
 movdqa xmm3,xmm0
 cmp rax,48
 jb @Label_FinalCombine // if remaining length < 48, skip 48-byte loop and go to final combine

 // Process remaining 48-byte blocks
@Loop_Tail48Fold:
 movdqa xmm4,xmm0
 pclmulqdq xmm4,xmm1,0
 pclmulqdq xmm0,xmm2,17
 movdqu xmm3,oword ptr [rcx]
 pxor xmm3,xmm4
 pxor xmm3,xmm0
 movdqu xmm0,oword ptr [rcx+16]
 movdqu xmm4,oword ptr [rcx+32]
 movdqu xmm5,oword ptr [rcx+48]
 // Fold into xmm3..xmm5 sequentially
 movdqa xmm6,xmm3
 pclmulqdq xmm6,xmm1,0
 pxor xmm6,xmm0
 pclmulqdq xmm3,xmm2,17
 pxor xmm3,xmm6
 movdqa xmm0,xmm3
 pclmulqdq xmm0,xmm1,0
 pxor xmm0,xmm4
 pclmulqdq xmm3,xmm2,17
 pxor xmm3,xmm0
 movdqa xmm0,xmm3
 pclmulqdq xmm0,xmm1,0
 pxor xmm0,xmm5
 pclmulqdq xmm3,xmm2,17
 pxor xmm3,xmm0
 add rcx,64
 add rdx,-64
 movdqa xmm0,xmm3
 cmp rdx,15
 ja @Loop_Tail48Fold
 jmp @Label_FinalCombine

 // <16-byte final combine
@Label_TailSmall:
 movdqa xmm3,xmm0

@Label_FinalCombine:
 // Barrett reduction and CRC32 finalization
 movdqu xmm0,oword ptr [rip+LCPI0_1]       // load k5 constant
 pclmulqdq xmm0,xmm3,1                     // carry-less multiply folded data by k5 (low half)
 psrldq xmm3,8                             // shift xmm3 right by 8 bytes
 pxor xmm3,xmm0                            // xor folded product with shifted data
 pxor xmm0,xmm0                            // zero xmm0
 pxor xmm1,xmm1                            // zero xmm1
 movss xmm1,xmm3                           // move low 32 bits into xmm1
 psrldq xmm3,4                             // shift xmm3 right by another 4 bytes
{$ifdef fpc}
 movabs rax,5969371428                     // k6 constant
{$else}
 mov rax,5969371428                        // k6 constant
{$endif}
 movq xmm2,rax                             // load k6 into xmm2
 pclmulqdq xmm2,xmm1,0                     // carry-less multiply low half by k6
 pxor xmm2,xmm3                            // xor with shifted data
 xorps xmm1,xmm1                           // zero xmm1
 movss xmm1,xmm2                           // move result low 32 bits
 pclmulqdq xmm1,oword ptr [rip+LCPI0_2],16 // multiply by k0 constant (high half)
 movss xmm0,xmm1                           // move result into xmm0
{$ifdef fpc}
 movabs rax,7976584769                     // k7 constant
{$else}
 mov rax,7976584769                        // k7 constant
{$endif}
 movq xmm1,rax                             // load k7 into xmm1
 pclmulqdq xmm1,xmm0,0                     // multiply low half by k7
 pxor xmm1,xmm2                            // xor with previous result
 pshufd xmm0,xmm1,85                       // shuffle to align CRC
 movd eax,xmm0                             // extract CRC32 result into eax

 // Epilogue: restore XMM registers and return
 movaps xmm6,oword ptr [rsp]
 movaps xmm7,oword ptr [rsp+16]
 movaps xmm8,oword ptr [rsp+32]
 movaps xmm9,oword ptr [rsp+48]
 movaps xmm10,oword ptr [rsp+64]
 add rsp,88
end;
{$else}
// Variant generated by GCC, but commented afterwards by hand in order to make it more readable
{$ifdef fpc}
{$push}
{$align 16}
type TAlignedTwoValues=record
      Values:array[0..1] of TpvUInt64;
     end {$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION>=30301)}align 16{$ifend};
const LC0:TAlignedTwoValues=(Values:(5708721108,7631803798));
      LC1:TAlignedTwoValues=(Values:(6259578832,3433693342));
      LC3:TAlignedTwoValues=(Values:(5969371428,0));
      LC4:TAlignedTwoValues=(Values:(7976584769,8439010881));
{$pop}
{$else}
type TAlignedTwoValues=record
      Values:array[0..1] of TpvUInt64;
     end align 16;
const LC0:TAlignedTwoValues=(Values:(5708721108,7631803798));
      LC1:TAlignedTwoValues=(Values:(6259578832,3433693342));
      LC3:TAlignedTwoValues=(Values:(5969371428,0));
      LC4:TAlignedTwoValues=(Values:(7976584769,8439010881));
{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Initialize CRC and pointers
 movd xmm0,r8d                  // CRC in low 32b
 lea rax,[rdx-64]               // rax = length - 64
 lea r9,[rcx+64]                // r9 = end-pointer + 64

 // Save callee-saved registers
 sub rsp,56
 movaps oword ptr [rsp],xmm6
 movaps oword ptr [rsp+16],xmm7
 movaps oword ptr [rsp+32],xmm8

 // Load initial 64-byte block
 movdqu xmm3,oword ptr [rcx]
 movdqu xmm2,oword ptr [rcx+32]
 movdqu xmm8,oword ptr [rcx+16]
 movdqu xmm1,oword ptr [rcx+48]
 pxor xmm3,xmm0                  // xor CRC into data

 cmp rax,63
 jbe @Entry_Fold128              // if remaining length < 64, skip main loop and jump to fold128

 // Main loop for processing 64-byte blocks
 add rdx,-128
 movdqa xmm0,oword ptr [rip+LC0] // load k1, k2 constants
 mov r8,rdx
 shr r8,6
 lea rax,[r8+2]
 sal rax,6
 add rcx,rax
 mov rax,r9

 // The actual loop for processing 64-byte blocks
@Loop_MainFold64:
 // Parallel carry-less multiply of four 128-bit lanes
 movdqa xmm7,xmm3
 movdqa xmm5,xmm2
 movdqa xmm4,xmm1
 add rax,64                       // advance pointers
 movdqa xmm6,xmm8
 pclmulqdq xmm7,xmm0,0
 pclmulqdq xmm5,xmm0,0
 pclmulqdq xmm4,xmm0,0
 pclmulqdq xmm8,xmm0,17
 pclmulqdq xmm6,xmm0,0
 pclmulqdq xmm3,xmm0,17
 pclmulqdq xmm2,xmm0,17
 pclmulqdq xmm1,xmm0,17

 // XOR with previous results and new data
 pxor xmm3,xmm7
 pxor xmm6,xmm8
 pxor xmm2,xmm5
 movdqu xmm7,oword ptr [rax-64]
 pxor xmm1,xmm4
 movdqu xmm8,oword ptr [rax-48]
 movdqu xmm5,oword ptr [rax-32]
 movdqu xmm4,oword ptr [rax-16]
 pxor xmm3,xmm7
 pxor xmm8,xmm6
 pxor xmm2,xmm5
 pxor xmm1,xmm4

 cmp rax,rcx
 jne @Loop_MainFold64

 // Adjust r8, r9, and rax for entry to 128-bit fold
 neg r8                        // r8 = -blocks_remaining
 sal r8,6                      // r8 = blocks_remaining * 64
 sub r9,r8                     // adjust end-pointer
 lea rax,[rdx+r8]              // pointer to data leftover
 add r9,64                     // restore end-pointer offset

@Entry_Fold128:
 // Fold 64->32 bits via k3,k4 constants
 movdqa xmm4,oword ptr [rip+LC1]
 movdqa xmm0,xmm3
 pclmulqdq xmm0,xmm4,0
 pclmulqdq xmm3,xmm4,17
 pxor xmm3,xmm0
 pxor xmm3,xmm8
 movdqa xmm0,xmm3
 pclmulqdq xmm3,xmm4,17
 pclmulqdq xmm0,xmm4,0
 pxor xmm0,xmm3
 pxor xmm2,xmm0
 movdqa xmm3,xmm2
 pclmulqdq xmm2,xmm4,17
 pclmulqdq xmm3,xmm4,0
 movdqa xmm0,xmm2
 pxor xmm0,xmm3
 pxor xmm0,xmm1
 cmp rax,15
 jbe @Label_TailHandle // if remaining length < 16, skip to tail handling

 // Process up to three 16-byte tail segments

 // First 16-byte segment
 movdqa xmm1,xmm0               // save CRC fold state
 movdqu xmm5,oword ptr [r9]     // load block 1
 pclmulqdq xmm0,xmm4,17         // fold high half by k4
 lea rdx,[rax-16]
 pclmulqdq xmm1,xmm4,0          // fold low half by k4
 pxor xmm0,xmm1                 // combine halves
 pxor xmm0,xmm5                 // xor in block 1
 cmp rdx,15
 jbe @Label_TailHandle          // if remaining length < 16, skip to final reduction

 // Second 16-byte segment
 movdqa xmm1,xmm0               // reuse CRC fold state
 movdqu xmm6,oword ptr [r9+16]  // load block 2
 pclmulqdq xmm0,xmm4,17         // fold high half by k4
 sub rax,32                     // adjust pointer for block 3
 pclmulqdq xmm1,xmm4,0          // fold low half by k4
 pxor xmm0,xmm1                 // combine halves
 pxor xmm0,xmm6                 // xor in block 2
 cmp rax,15
 jbe @Label_TailHandle          // if remaining length < 16, skip to final reduction

 // Third 16-byte segment
 movdqa xmm1,xmm0               // reuse CRC fold state
 pclmulqdq xmm0,xmm4,17         // fold high half by k4
 pclmulqdq xmm1,xmm4,0          // fold low half by k4
 pxor xmm1,xmm0                 // combine halves
 movdqu xmm0,oword ptr [r9+32]  // load block 3
 pxor xmm0,xmm1                 // xor in block 3

@Label_TailHandle:
 // Final Barrett reduction and extract CRC
 movdqa xmm1,xmm0                     // copy the 64-bit folded partial CRC into xmm1
 mov eax,4294967295                   // load 0xffffffff (the CRC bias) into EAX
 movdqa xmm3,oword ptr [rip+LC4]      // load the Barrett polynomial constant (k5) into xmm3
 movaps xmm6,oword ptr [rsp]          // restore one of the saved XMM regs from the stack
 psrldq xmm0,8                        // shift the current 64-bit CRC low by 8 bytes => brings high 32 bits into position
 movq xmm2,rax                        // broadcast the 32-bit bias (0xffffffff) into both halves of xmm2
 movaps xmm7,oword ptr [rsp+16]       // restore another saved XMM reg
 pclmulqdq xmm1,xmm4,16               // carry-less multiply the low 32 bits (in xmm1) with the low half of the poly constant in xmm4
 punpcklqdq xmm2,xmm2                 // duplicate the bias across both halves (for masking)
 pxor xmm1,xmm0                       // XOR the folded product with the shifted CRC (Barrett reduction step)
 movaps xmm8,oword ptr [rsp+32]       // restore another XMM reg
 movdqa xmm0,xmm1                     // move the reduced 64-bit value back into xmm0
 pand xmm1,xmm2                       // mask down to 32 bits by AND-ing with 0xffffffff
 pclmulqdq xmm1,oword ptr [rip+LC3],0 // multiply masked value by the second Barrett constant (k6)
 psrldq xmm0,4                        // shift xmm0 right by 4 bytes => isolate upper 32-bit half
 add rsp,56                           // pop restored XMM regs off the stack
 pxor xmm1,xmm0                       // XOR with the shifted half => finish the two-step Barrett reduction
 movdqa xmm0,xmm1                     // copy into xmm0 for the final multiply
 pand xmm0,xmm2                       // mask again to 32 bits
 pclmulqdq xmm0,xmm3,16               // multiply by k5 (high half)
 pand xmm0,xmm2                       // mask to 32 bits
 pclmulqdq xmm0,xmm3,0                // multiply by k5 (low half)
 pxor xmm0,xmm1                       // combine the halves
 pextrd eax,xmm0,1                    // extract the upper 32 bits of xmm0 into EAX => this is the final CRC
end;
{$endif}
{$endif}

procedure TpvArchiveZIPLocalFileHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIPExtensibleDataFieldHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIP64ExtensibleInfoFieldHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIPCentralFileHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIPEndCentralFileHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIP64EndCentralFileHeader.SwapEndiannessIfNeeded;
begin
end;

procedure TpvArchiveZIP64EndCentralLocator.SwapEndiannessIfNeeded;
begin
end;

class procedure TpvArchiveZIPDateTimeUtils.ConvertDateTimeToZIPDateTime(const aDateTime:TDateTime;out aZIPDate,aZIPTime:TpvUInt16);
var Year,Month,Day,Hour,Minute,Second,Millisecond:TpvUInt16;
begin
 DecodeDate(aDateTime,Year,Month,Day);
 DecodeTime(aDateTime,Hour,Minute,Second,Millisecond);
 if Year<1980 then begin
  Year:=0;
  Month:=1;
  Day:=1;
  Hour:=0;
  Minute:=0;
  Second:=0;
  Millisecond:=0;
 end else begin
  dec(Year,1980);
 end;
 aZIPDate:=Day+(32*Month)+(512*Year);
 aZIPTime:=(Second div 2)+(32*Minute)+(2048*Hour);
end;

class function TpvArchiveZIPDateTimeUtils.ConvertZIPDateTimeToDateTime(const aZIPDate,aZIPTime:TpvUInt16):TDateTime;
begin
 result:=EncodeDate(((aZIPDate shr 9) and 127)+1980,
                    Max(1,(aZIPDate shr 5) and 15),
                    Max(1,aZIPDate and 31))+
         EncodeTime(aZIPTime shr 11,
                    (aZIPTime shr 5) and 63,
                    (aZIPTime and 31) shl 1,
                    0);
end;

procedure TpvArchiveZIPCRC32.Initialize;
begin
 fState:=$ffffffff;
end;

{$ifdef cpuamd64}
function TpvArchiveZIPCRC32_Update(aCRC32:PpvArchiveZIPCRC32;
                                   aData:Pointer;
                                   aDataLength:TpvSizeUInt):TpvUInt32; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Preserve callee-saved registers
 push r15
 push r14
 push r13
 push r12
 push rsi
 push rdi
 push rbp
 push rbx
 sub rsp,24

 // Load initial CRC value into EAX
 mov eax,dword ptr [rcx+TpvArchiveZIPCRC32.fState]

 // If fewer than 16 bytes, skip the 16‑byte unrolled loop
 cmp r8,16
 jb @Skip16

 // Save CRC pointer on stack and load address of CRC table
 mov qword ptr [rsp],rcx
 lea r13,[rip+TpvArchiveZIPCRC32_CRC32Tables]

 // 16‑byte unrolled loop
@Loop16:
 // load 4 bytes at offsets 12,8,4,0 into ecx/eax for table lookups
 mov ecx,dword ptr [rdx+12]
 mov r10d,ecx
 movzx esi,ch
 mov qword ptr [rsp+16],rsi  // save ch for later
 movzx r9d,cl
 mov qword ptr [rsp+8],r9    // save cl for later

 mov ebx,ecx
 mov ecx,dword ptr [rdx+8]
 xor eax,dword ptr [rdx]     // xor next dword
 mov r11d,ecx
 movzx ebp,ch
 movzx r14d,cl
 mov r12d,ecx
 mov ecx,dword ptr [rdx+4]
 mov r15d,ecx
 movzx edi,ch
 movzx esi,cl

 // do eight CRC‑table lookups/xors for the 16 bytes
 shr ebx,24
 shr r10d,14
 and r10d,1020
 mov r9d,eax
 mov r10d,dword ptr [r10+r13+1024]
 xor r10d,dword ptr [r13+rbx*4]
 mov rbx,qword ptr [rsp+16]
 xor r10d,dword ptr [r13+rbx*4+2048]
 mov rbx,qword ptr [rsp+8]
 xor r10d,dword ptr [r13+rbx*4+3072]
 movzx ebx,ah
 shr r12d,24
 xor r10d,dword ptr [r13+r12*4+4096]
 shr r11d,14
 and r11d,1020
 xor r10d,dword ptr [r11+r13+5120]
 xor r10d,dword ptr [r13+rbp*4+6144]
 xor r10d,dword ptr [r13+r14*4+7168]
 movzx r11d,al
 shr ecx,24
 xor r10d,dword ptr [r13+rcx*4+8192]
 shr r15d,14
 and r15d,1020
 xor r10d,dword ptr [r15+r13+9216]
 xor r10d,dword ptr [r13+rdi*4+10240]
 xor r10d,dword ptr [r13+rsi*4+11264]
 shr eax,24
 xor r10d,dword ptr [r13+rax*4+12288]
 shr r9d,14
 and r9d,1020
 xor r10d,dword ptr [r9+r13+13312]
 add rdx,16
 xor r10d,dword ptr [r13+rbx*4+14336]
 mov eax,r10d
 xor eax,dword ptr [r13+r11*4+15360]

 add r8,-16
 cmp r8,15
 ja @Loop16

 // Restore CRC pointer
 mov rcx,qword ptr [rsp]

@Skip16:

 // If fewer than 8 bytes left, skip the 8‑byte loop
 cmp r8,8
 jb @Skip8

 lea r9,[rip+TpvArchiveZIPCRC32_CRC32Tables]

 // 8‑byte unrolled loop
@Loop8:
 mov ebx,dword ptr [rdx+4]
 xor eax,dword ptr [rdx]
 mov r15d,ebx
 movzx esi,bh
 movzx r10d,bl
 mov r11d,ebx
 shr r11d,24
 shr r15d,14
 and r15d,1020
 mov ebx,eax
 movzx edi,ah
 movzx r14d,al
 mov ebp,dword ptr [r15+r9+1024]
 xor ebp,dword ptr [r9+r11*4]
 xor ebp,dword ptr [r9+rsi*4+2048]
 xor ebp,dword ptr [r9+r10*4+3072]
 shr eax,24
 xor ebp,dword ptr [r9+rax*4+4096]
 shr ebx,14
 and ebx,1020
 xor ebp,dword ptr [rbx+r9+5120]
 add rdx,8
 xor ebp,dword ptr [r9+rdi*4+6144]
 mov eax,ebp
 xor eax,dword ptr [r9+r14*4+7168]

 add r8,-8
 cmp r8,7

 ja @Loop8

@Skip8:

 // If fewer than 4 bytes left, skip the 4‑byte loop
 cmp r8,4
 jb @Skip4

 lea r10,[rip+TpvArchiveZIPCRC32_CRC32Tables]

 // 4‑byte unrolled loop
@Loop4:
 xor eax,dword ptr [rdx]
 mov r9d,eax
 movzx esi,ah
 movzx r11d,al
 shr eax,24
 shr r9d,14
 and r9d,1020
 mov r9d,dword ptr [r9+r10+1024]
 xor r9d,dword ptr [r10+rax*4]
 xor r9d,dword ptr [r10+rsi*4+2048]
 xor r9d,dword ptr [r10+r11*4+3072]
 add rdx,4
 add r8,-4
 mov eax,r9d
 cmp r8,3
 ja @Loop4

 // Process remaining 1–3 bytes
 test r8,r8
 je @RemainderZero

@CheckRemainder:
 test r8b,1
 jne @ProcessSingleByte

 // if at least 2 bytes remain
 mov r10,r8
 cmp r8,1
 jne @ProcessTwoByteEntry
 jmp @FinalizeAndStoreCRC

@Skip4:
 mov r9d,eax
 test r8,r8
 jne @CheckRemainder

@RemainderZero:
 // no bytes left: return CRC
 mov eax,r9d
 jmp @FinalizeAndStoreCRC

@ProcessSingleByte:
 // process final single byte
 mov eax,r9d
 xor r9b,byte ptr [rdx]
 shr eax,8
 inc rdx
 movzx r10d,r9b
 lea r9,[rip+TpvArchiveZIPCRC32_CRC32Tables]
 xor eax,dword ptr [r9+r10*4]
 lea r10,[r8-1]
 mov r9d,eax
 cmp r8,1
 je @FinalizeAndStoreCRC

@ProcessTwoByteEntry:
 // prepare for processing two-byte tail
 xor r11d,r11d
 lea r8,[rip+TpvArchiveZIPCRC32_CRC32Tables]
 mov eax,r9d

@ProcessBytePairLoop:
 // loop over each pair of remaining bytes
 mov r9d,eax
 shr r9d,8
 xor al,byte ptr [rdx+r11]
 movzx eax,al
 xor r9d,dword ptr [r8+rax*4]
 mov eax,r9d
 shr eax,8
 xor r9b,byte ptr [rdx+r11+1]
 movzx r9d,r9b
 xor eax,dword ptr [r8+r9*4]
 add r11,2
 cmp r10,r11
 jne @ProcessBytePairLoop

@FinalizeAndStoreCRC:

 // store final CRC back
 mov dword ptr [rcx+TpvArchiveZIPCRC32.fState],eax

 // restore registers
 add rsp,24
 pop rbx
 pop rbp
 pop rdi
 pop rsi
 pop r12
 pop r13
 pop r14
 pop r15
end;

(*
function TpvArchiveZIPCRC32_Update(aCRC32:PpvArchiveZIPCRC32;
                                   aData:Pointer;
                                   aDataLength:TpvSizeUInt):TpvUInt32; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 push rsi
 mov eax,dword ptr [rcx+TpvArchiveZIPCRC32.fState]
 test r8,r8
 je @EndJmp
 add r8,rdx
 lea rsi,[rip+TpvArchiveZIPCRC32_CRC32Tables]
@LoopJmp:
 mov r9d,eax
 xor al,byte ptr [rdx]
 add rdx,1
 movzx eax,al
 shr r9d,8
 xor r9d,dword ptr [rsi+rax*4]
 mov eax,r9d
 cmp r8,rdx
 jne @LoopJmp
@EndJmp:
 mov dword ptr [rcx+TpvArchiveZIPCRC32.fState],eax
 pop rsi
end;*)
{$endif}

procedure TpvArchiveZIPCRC32.Update(const aData;const aDataLength:TpvSizeUInt);
{$ifdef cpuamd64}
var Data:Pointer;
    DataLength,ToDo:TpvUInt64;
begin
 Data:=@aData;
 DataLength:=aDataLength;
{$if declared(CRC32SSE42SIMD)}
 if ((CPUFeatures and CPUFeatures_X86_PCLMUL_Mask)<>0) and (DataLength>=64) then begin
  ToDo:=DataLength and TpvUInt64($fffffffffffffff0);
  fState:=CRC32SSE42SIMD(Data,ToDo,fState);
  dec(DataLength,ToDo);
  if DataLength=0 then begin
   exit;
  end;
  inc(PpvUInt8(Data),ToDo);
 end;
{$ifend}
 TpvArchiveZIPCRC32_Update(@self,Data,DataLength);
end;
{$else}
var Data:PpvUInt8Array;
    Len:TpvSizeUInt;
    State,Data0,Data1,Data2,Data3:TpvUInt32;
begin
 State:=fState;
 Data:=@aData;
 Len:=aDataLength;
 while Len>=16 do begin
  dec(Len,16);
  Data0:=PpvUInt32(Pointer(@Data^[0]))^;
  Data1:=PpvUInt32(Pointer(@Data^[4]))^;
  Data2:=PpvUInt32(Pointer(@Data^[8]))^;
  Data3:=PpvUInt32(Pointer(@Data^[12]))^;
  Data:=Pointer(@Data^[16]);
{$ifdef BIG_ENDIAN}
  Data0:=Data0 xor ((State shr 24) or ((State and TpvUInt32($00ff0000)) shr 8) or ((State and TpvUInt32($0000ff00)) shl 8) or (State shl 24));
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data3 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data3 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data3 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data3 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[4,(Data2 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[5,(Data2 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[6,(Data2 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[7,(Data2 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[8,(Data1 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[9,(Data1 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[10,(Data1 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[11,(Data1 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[12,(Data0 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[13,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[14,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[15,(Data0 shr 24) and $ff];
{$else}
  Data0:=Data0 xor State;
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data3 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data3 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data3 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data3 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[4,(Data2 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[5,(Data2 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[6,(Data2 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[7,(Data2 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[8,(Data1 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[9,(Data1 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[10,(Data1 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[11,(Data1 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[12,(Data0 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[13,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[14,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[15,(Data0 shr 0) and $ff];
{$endif}
 end;
 while Len>=8 do begin
  dec(Len,8);
  Data0:=PpvUInt32(Pointer(@Data^[0]))^;
  Data1:=PpvUInt32(Pointer(@Data^[4]))^;
  Data:=Pointer(@Data^[8]);
{$ifdef BIG_ENDIAN}
  Data0:=Data0 xor ((State shr 24) or ((State and TpvUInt32($00ff0000)) shr 8) or ((State and TpvUInt32($0000ff00)) shl 8) or (State shl 24));
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data1 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data1 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data1 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data1 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[4,(Data0 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[5,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[6,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[7,(Data0 shr 24) and $ff];
{$else}
  Data0:=Data0 xor State;
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data1 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data1 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data1 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data1 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[4,(Data0 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[5,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[6,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[7,(Data0 shr 0) and $ff];
{$endif}
 end;
 while Len>=4 do begin
  dec(Len,4);
  Data0:=PpvUInt32(Pointer(@Data^[0]))^;
  Data:=Pointer(@Data^[4]);
{$ifdef BIG_ENDIAN}
  Data0:=Data0 xor ((State shr 24) or ((State and TpvUInt32($00ff0000)) shr 8) or ((State and TpvUInt32($0000ff00)) shl 8) or (State shl 24));
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data0 shr 0) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data0 shr 24) and $ff];
{$else}
  Data0:=Data0 xor State;
  State:=TpvArchiveZIPCRC32_CRC32Tables[0,(Data0 shr 24) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[1,(Data0 shr 16) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[2,(Data0 shr 8) and $ff] xor
         TpvArchiveZIPCRC32_CRC32Tables[3,(Data0 shr 0) and $ff];
{$endif}
 end;
 while Len>0 do begin
  dec(Len);
  State:=(State shr 8) xor TpvArchiveZIPCRC32_CRC32Tables[0,TpvUInt8(State xor Data^[0]) and $ff];
  Data:=Pointer(@Data^[1]);
 end;
 fState:=State;
end;
{var b:PpvUInt8;
    Index:TpvSizeUInt;
    State:TpvUInt32;
begin
 b:=@aData;
 State:=fState;
 for Index:=1 to aDataLength do begin
//State:=TpvArchiveZIPCRC32_CRC32Tables[0,(State and $ff) xor b^] xor ((State shr 8) and $00ffffff);
  State:=(State shr 8) xor TpvArchiveZIPCRC32_CRC32Tables[0,TpvUInt8(State xor b^) and $ff];
  inc(b);
 end;
 fState:=State;
end;}
{$endif}

procedure TpvArchiveZIPCRC32.Update(const aStream:TStream);
const BufferLen=4096;
var b:TpvUInt8;
    Remaining,ToDo:TpvSizeUInt;
    Buffer:PpvUInt8Array;
begin
 if aStream is TMemoryStream then begin
  Update(TMemoryStream(aStream).Memory^,aStream.Size);
 end else begin
  aStream.Seek(0,soBeginning);
  GetMem(Buffer,BufferLen);
  try
   Remaining:=aStream.Size;
   while Remaining>0 do begin
    if Remaining<BufferLen then begin
     ToDo:=Remaining;
    end else begin
     ToDo:=BufferLen; 
    end;
    aStream.ReadBuffer(Buffer^,ToDo);
    Update(Buffer^,ToDo);
    dec(Remaining,ToDo);
   end; 
  finally
   FreeMem(Buffer);
  end;
 end;
end;

function TpvArchiveZIPCRC32.Finalize:TpvUInt32;
begin
 result:=not fState;
end;

constructor TpvArchiveZIPEntry.Create(aCollection:TCollection);
begin
 inherited Create(aCollection);
 fFileName:='';
 fOS:=TpvArchiveZIPOS.FAT;
//fOS:={$if defined(Unix) or defined(Posix)}TpvArchiveZIPOS.UNIX{$else}TpvArchiveZIPOS.FAT{$ifend};
 fCompressionLevel:=0;
 fDateTime:=Now;
 fRequiresZIP64:=false;
 fAttributes:=0;
 fStream:=nil;
end;

destructor TpvArchiveZIPEntry.Destroy;
begin
 if (Collection is TpvArchiveZIPEntries) and
    (length(fFileName)>0) then begin
  (Collection as TpvArchiveZIPEntries).fFileNameHashMap.Delete(fFileName);
 end;
 FreeAndNil(fStream);
 inherited Destroy;
end;

procedure TpvArchiveZIPEntry.SetFileName(const aFileName:TpvRawByteString);
var NewFileName:TpvRawByteString;
begin
 NewFileName:=TpvArchiveZIP.CorrectPath(aFileName);
 if fFileName<>NewFileName then begin
  if (Collection is TpvArchiveZIPEntries) and
     (length(fFileName)>0) then begin
   (Collection as TpvArchiveZIPEntries).fFileNameHashMap.Delete(fFileName);
  end;
  fFileName:=NewFileName;
  if (Collection is TpvArchiveZIPEntries) and
     (length(fFileName)>0) then begin
   (Collection as TpvArchiveZIPEntries).fFileNameHashMap.Add(fFileName,self);
  end;
 end;
end;

procedure TpvArchiveZIPEntry.Assign(aSource:TPersistent);
var Source:TpvArchiveZIPEntry;
begin
 if assigned(aSource) and (aSource is TpvArchiveZIPEntry) then begin
  Source:=aSource as TpvArchiveZIPEntry;
  SetFileName(Source.fFileName);
  fAttributes:=Source.fAttributes;
  fDateTime:=Source.fDateTime;
  fCentralHeaderPosition:=Source.fCentralHeaderPosition;
  fHeaderPosition:=Source.fHeaderPosition;
  fRequiresZIP64:=Source.fRequiresZIP64;
  fOS:=Source.fOS;
  fSize:=Source.fSize;
  if assigned(Source.fStream) then begin
   fStream:=TMemoryStream.Create;
   Source.fStream.Seek(0,soBeginning);
   fStream.CopyFrom(Source.fStream,Source.fStream.Size);
   fStream.Seek(0,soBeginning);
  end else begin
   FreeAndNil(fStream);
  end;
  fSourceArchive:=Source.fSourceArchive;
  fCompressionLevel:=Source.fCompressionLevel;
 end else begin
  inherited Assign(aSource);
 end;
end;

function TpvArchiveZIPEntry.GetDirectory:boolean;
begin
 result:=((Attributes=0) and (length(fFileName)>0) and (fFileName[length(fFileName)-1]='/')) or
         ((Attributes<>0) and
          ((((fOS=TpvArchiveZIPOS.FAT) and ((fAttributes and faDirectory)<>0))) or
            ((fOS=TpvArchiveZIPOS.UNIX) and ((fAttributes and $f000)=$4000))));
end;

function TpvArchiveZIPEntry.GetLink:boolean;
begin
 result:=(Attributes<>0) and
         ((((fOS=TpvArchiveZIPOS.FAT) and ((fAttributes and faSymLink)<>0))) or
           ((fOS=TpvArchiveZIPOS.UNIX) and ((fAttributes and $f000)=$a000)));
end;

procedure TpvArchiveZIPEntry.LoadFromStream(const aStream:TStream);
begin
 FreeAndNil(fStream);
 fStream:=TMemoryStream.Create;
 aStream.Seek(0,soBeginning);
 fStream.CopyFrom(aStream,aStream.Size);
 aStream.Seek(0,soBeginning);
 fSourceArchive:=nil;
end;

procedure TpvArchiveZIPEntry.LoadFromFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvArchiveZIPEntry.SaveToStream(const aStream:TStream);
var LocalFileHeader:TpvArchiveZIPLocalFileHeader;
    BitBuffer,OriginalCRC:TpvUInt32;
    BitsInBitBuffer,FilePosition,InputBufferPosition,SlideWindowPosition:TpvSizeInt;
    ReachedSize,CompressedSize,UncompressedSize:TpvInt64;
    Offset,StartPosition,From:TpvInt64;
    CRC32:TpvArchiveZIPCRC32;
    ItIsAtEnd:boolean;
    ExtensibleDataFieldHeader:TpvArchiveZIPExtensibleDataFieldHeader;
    ExtensibleInfoFieldHeader:TpvArchiveZIP64ExtensibleInfoFieldHeader;
 function Decompress(const InStream,OutStream:TStream):boolean;
 const StatusOk=0;
       StatusCRCErr=-1;
       StatusWriteErr=-2;
       StatusReadErr=-3;
       StatusZipFileErr=-4;
       StatusUserAbort=-5;
       StatusNotSupported=-6;
       StatusEncrypted=-7;
       StatusInUse=-8;
       StatusInternalError=-9;
       StatusNoMoreItems=-10;
       StatusFileError=-11;
       StatusNoTpvArchiveZIPfile=-12;
       StatusHeaderTooLarge=-13;
       StatusZipFileOpenError=-14;
       StatusSeriousError=-100;
       StatusMissingParameter=-500;

       HuffmanTreeComplete=0;
       HuffmanTreeIncomplete=1;
       HuffmanTreeError=2;
       HuffmanTreeOutOfMemory=3;

       MaxMax=31*1024;
       SlidingDictionaryWindowSize=$8000;
       InBufferSize=1024*4;
       DefaultLiteralBits=9;
       DefaultDistanceBits=6;
       BitLengthCountMax=16;
       OrderOfBitLengthMax=288;
       HuffManTreeBuildMaxValue=16;

       MaxCode=8192;
       MaxStack=8192;
       InitialCodeSize=9;
       FinalCodeSize=13;

       TFileBufferSize=high(TpvInt32)-16;
       TFileNameSize=259;

       SupportedMethods=1 or (1 shl 1) or (1 shl 6) or (1 shl 8);

       MaskBits:array[0..16] of TpvUInt16=($0000,$0001,$0003,$0007,$000f,$001f,$003f,$007f,$00ff,$01ff,$03ff,$07ff,$0fff,$1fff,$3fff,$7fff,$ffff);
       Border:array[0..18] of TpvUInt8=(16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
       CopyLengthLiteralCodes:array[0..30] of TpvUInt16=(3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258,0,0);
       ExtraBitsLiteralCodes:array[0..30] of TpvUInt16=(0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,99,99);
       CopyOffsetDistanceCodes:array[0..29] of TpvUInt16=(1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577);
       ExtraBitsDistanceCodes:array[0..29] of TpvUInt16=(0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13);
       CopyLength2:array[0..63] of TpvUInt16=(2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65);
       CopyLength3:array[0..63] of TpvUInt16=(3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66);
       ExtraBitsTable:array[0..63] of TpvUInt16=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8);
       CopyOffserDistanceCodes4:array[0..63] of TpvUInt16 =(1,65,129,193,257,321,385,449,513,577,641,705,769,833,897,961,1025,1089,1153,1217,1281,1345,1409,1473,1537,1601,1665,1729,1793,1857,1921,1985,2049,2113,2177,2241,2305,2369,2433,2497,2561,2625,2689,2753,2817,2881,2945,3009,3073,3137,3201,3265,3329,3393,3457,3521,3585,3649,3713,3777,3841,3905,3969,4033);
       CopyOffserDistanceCodes8:array[0..63] of TpvUInt16=(1,129,257,385,513,641,769,897,1025,1153,1281,1409,1537,1665,1793,1921,2049,2177,2305,2433,2561,2689,2817,2945,3073,3201,3329,3457,3585,3713,3841,3969,4097,4225,4353,4481,4609,4737,4865,4993,5121,5249,5377,5505,5633,5761,5889,6017,6145,6273,6401,6529,6657,6785,6913,7041,7169,7297,7425,7553,7681,7809,7937,8065);

 type PUSBList=^TUSBList;
      TUSBList=array[0..MaxMax] of TpvUInt16;

      PIOBuffer=^TIOBuffer;
      TIOBuffer=array[0..InBufferSize-1] of TpvUInt8;

      PPHuffManTree=^PHuffManTree;
      PHuffManTree=^THuffManTree;
      PHuffManTreeList=^THuffManTreeList;
      THuffManTree=record
       ExtraBits,CodeBits:TpvUInt8;
       ByteSize:TpvUInt16;
       LinkList:PHuffManTreeList;
      end;
      THuffManTreeList=array[0..8190] of THuffManTree;

      PPreviousCodeTrie=^TPreviousCodeTrie;
      TPreviousCodeTrie=array[257..MaxCode] of TpvInt32;
      PActualCodeTrie=^TActualCodeTrie;
      TActualCodeTrie=array[257..MaxCode] of TpvUInt8;
      PStack=^TStack;
      TStack=array[0..MaxStack] of TpvUInt8;

      PSlide=^TSlide;
      TSlide=array[0..SlidingDictionaryWindowSize-1] of TpvUInt8;

 var Slide:PSlide;
     InputBuffer:TIOBuffer;
     InputBufferPosition:TpvInt32;
     FilePosition:TpvInt32;
     SlideWindowPosition:TpvUInt16;
     BitBuffer:TpvUInt32;
     BitsInBitBuffer:TpvUInt8;
     ReachedSize:int64;
     BitsFlagsType:TpvUInt16;
     UserAbort,ItIsAtEnd:boolean;
     PreviousCode:PPreviousCodeTrie;
     ActualCode:PActualCodeTrie;
     Stack:PStack;
     NextFreeCodeInTrie:TpvInt32;

  procedure UpdateCRC(const IOBuffer:TIOBuffer;InLen:TpvInt32);
  begin
   CRC32.Update(IOBuffer,InLen);
  end;

  procedure Idle;
  begin
  end;

  procedure ReadBuffer;
  begin
   if ReachedSize>(CompressedSize+2) then begin
    FilePosition:=SizeOf(TIOBuffer);
    ItIsAtEnd:=true;
   end else begin
    Idle;
    FilePosition:=InStream.Read(InputBuffer,SizeOf(TIOBuffer));
    if FilePosition<=0 then begin
     FilePosition:=SizeOf(TIOBuffer);
     ItIsAtEnd:=true;
    end;
    inc(ReachedSize,FilePosition);
    dec(FilePosition);
   end;
   InputBufferPosition:=0;
  end;

  procedure ReadByte(var B:TpvUInt8);
  begin
   if InputBufferPosition>FilePosition then begin
    ReadBuffer;
   end;
   B:=InputBuffer[InputBufferPosition];
   inc(InputBufferPosition);
  end;

  procedure NeedBits(Count:TpvUInt8);
  var Value:TpvUInt32;
  begin
   while BitsInBitBuffer<Count do begin
    if InputBufferPosition>FilePosition then begin
     ReadBuffer;
    end;
    Value:=InputBuffer[InputBufferPosition];
    inc(InputBufferPosition);
    BitBuffer:=BitBuffer or (Value shl BitsInBitBuffer);
    inc(BitsInBitBuffer,8);
   end;
  end;

  procedure DumpBits(Count:TpvUInt8);
  begin
   BitBuffer:=BitBuffer shr Count;
   dec(BitsInBitBuffer,Count);
  end;

  function ReadBits(Count:TpvInt32):TpvInt32;
  begin
   if Count>0 then begin
    NeedBits(Count);
    result:=BitBuffer and ((1 shl Count)-1);
    DumpBits(Count);
   end else begin
    result:=0;
   end;
  end;

  function Flush(Bytes:TpvUInt32):boolean;
  begin
   result:=OutStream.Write(Slide^[0],Bytes)=TpvInt32(Bytes);
   CRC32.Update(Slide^[0],Bytes);
  end;

  procedure HuffManTreeFree(T:PHuffManTreeList);
  var P,Q:PHuffManTreeList;
      Z:TpvInt32;
  begin
   P:=T;
   while assigned(P) do begin
    dec(TpvPtrUInt(P),SizeOf(THuffManTree));
    Q:=P^[0].LinkList;
    Z:=P^[0].ByteSize;
    FreeMem(P,(Z+1)*SizeOf(THuffManTree));
    P:=Q;
   end;
  end;

  function HuffManTreeBuild(B:pword;N:TpvUInt16;S:TpvUInt16;D,E:PUSBList;T:PPHuffManTree;var M:TpvInt32):TpvInt32;
  type TBitLengthCountTable=array[0..BitLengthCountMax+1] of TpvUInt16;
  var CodeLengthKCount:TpvUInt16;
      BitLengthCountTable:TBitLengthCountTable;
      CurrentCodeCounterRepeatsEveryFEntries:TpvUInt16;
      MaxCodeLength:TpvInt32;
      TableLevel:TpvInt32;
      CurrentCodeCounter:TpvUInt16;
      Counter:TpvUInt16;
      NumberOfBitsInCurrentCode:TpvInt32;
      P:pword;
      CurrentTable:PHuffManTreeList;
      TableEntry:THuffManTree;
      TableStack:array[0..BitLengthCountMax] of PHuffManTreeList;
      ValuesInOrderOfBitsLength:array[0..OrderOfBitLengthMax] of TpvUInt16;
      BitsBeforeThisTable:TpvInt32;
      BitOffsets:array[0..BitLengthCountMax+1] of TpvUInt16;
      LLevelBitsInTableOfLevel:array[-1..BitLengthCountMax+1] of TpvUInt16;
      BitOffsetPointer:pword;
      NumberOfDummyCodesAdded:TpvInt32;
      NumberOfEntriesInCurrentTable:TpvUInt16;
      PT:PHuffManTree;
      EOBCodeLength:TpvUInt16;
  begin
   if N>256 then begin
    EOBCodeLength:=pword(TpvPtrUInt(TpvPtrUInt(B)+(256*SizeOf(TpvUInt16))))^;
   end else begin
    EOBCodeLength:=HuffManTreeBuildMaxValue;
   end;
   FillChar(BitLengthCountTable,SizeOf(TBitLengthCountTable),#0);

   P:=B;
   CurrentCodeCounter:=N;
   repeat
    if P^>BitLengthCountMax then begin
     T^:=nil;
     M:=0;
     HuffManTreeBuild:=HuffmanTreeError;
     exit;
    end;
    inc(BitLengthCountTable[P^]);
    inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
    dec(CurrentCodeCounter);
   until CurrentCodeCounter=0;
   if BitLengthCountTable[0]=N then begin
    T^:=nil;
    M:=0;
    HuffManTreeBuild:=HuffmanTreeComplete;
    exit;
   end;

   Counter:=1;
   while (Counter<=BitLengthCountMax) and (BitLengthCountTable[Counter]=0) do inc(Counter);
   NumberOfBitsInCurrentCode:=Counter;
   if M<Counter then M:=Counter;
   CurrentCodeCounter:=BitLengthCountMax;
   while (CurrentCodeCounter>0) and (BitLengthCountTable[CurrentCodeCounter]=0) do dec(CurrentCodeCounter);
   MaxCodeLength:=CurrentCodeCounter;
   if M>CurrentCodeCounter then M:=CurrentCodeCounter;

   NumberOfDummyCodesAdded:=1 shl Counter;
   while Counter<CurrentCodeCounter do begin
    dec(NumberOfDummyCodesAdded,BitLengthCountTable[Counter]);
    if NumberOfDummyCodesAdded<0 then begin
     HuffManTreeBuild:=HuffmanTreeError;
     exit;
    end;
    NumberOfDummyCodesAdded:=NumberOfDummyCodesAdded shl 1;
    inc(Counter);
   end;
   dec(NumberOfDummyCodesAdded,BitLengthCountTable[CurrentCodeCounter]);
   if NumberOfDummyCodesAdded<0 then begin
    HuffManTreeBuild:=HuffmanTreeError;
    exit;
   end;
   inc(BitLengthCountTable[CurrentCodeCounter],NumberOfDummyCodesAdded);

   BitOffsets[1]:=0;
   Counter:=0;
   P:=pword(@BitLengthCountTable);
   inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
   BitOffsetPointer:=pword(@BitOffsets);
   inc(TpvPtrUInt(BitOffsetPointer),2*SizeOf(TpvUInt16));
   dec(CurrentCodeCounter);
   while CurrentCodeCounter<>0 do begin
    inc(Counter,P^);
    BitOffsetPointer^:=Counter;
    inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
    inc(TpvPtrUInt(BitOffsetPointer),SizeOf(TpvUInt16));
    dec(CurrentCodeCounter);
   end;

   P:=B;
   CurrentCodeCounter:=0;
   repeat
    Counter:=P^;
    inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
    if Counter<>0 then begin
     ValuesInOrderOfBitsLength[BitOffsets[Counter]]:=CurrentCodeCounter;
     inc(BitOffsets[Counter]);
    end;
    inc(CurrentCodeCounter);
   until CurrentCodeCounter>=N;

   BitOffsets[0]:=0;
   CurrentCodeCounter:=0;
   P:=pword(@ValuesInOrderOfBitsLength);
   TableLevel:=-1;
   LLevelBitsInTableOfLevel[-1]:=0;
   BitsBeforeThisTable:=0;
   TableStack[0]:=nil;
   CurrentTable:=nil;
   NumberOfEntriesInCurrentTable:=0;

   for NumberOfBitsInCurrentCode:=NumberOfBitsInCurrentCode to MaxCodeLength do begin
    for CodeLengthKCount:=BitLengthCountTable[NumberOfBitsInCurrentCode] downto 1 do begin
     while NumberOfBitsInCurrentCode>(BitsBeforeThisTable+LLevelBitsInTableOfLevel[TableLevel]) do begin
      inc(BitsBeforeThisTable,LLevelBitsInTableOfLevel[TableLevel]);
      inc(TableLevel);
      NumberOfEntriesInCurrentTable:=MaxCodeLength-BitsBeforeThisTable;
      if NumberOfEntriesInCurrentTable>M then NumberOfEntriesInCurrentTable:=M;
      Counter:=NumberOfBitsInCurrentCode-BitsBeforeThisTable;
      CurrentCodeCounterRepeatsEveryFEntries:=1 shl Counter;
      if CurrentCodeCounterRepeatsEveryFEntries>(CodeLengthKCount+1) then begin
       dec(CurrentCodeCounterRepeatsEveryFEntries,CodeLengthKCount+1);
       BitOffsetPointer:=@BitLengthCountTable[NumberOfBitsInCurrentCode];
       inc(Counter);
       while Counter<NumberOfEntriesInCurrentTable do begin
         CurrentCodeCounterRepeatsEveryFEntries:=CurrentCodeCounterRepeatsEveryFEntries shl 1;
         inc(TpvPtrUInt(BitOffsetPointer),SizeOf(TpvUInt16));
         if CurrentCodeCounterRepeatsEveryFEntries<=BitOffsetPointer^ then begin
          break;
         end else begin
          dec(CurrentCodeCounterRepeatsEveryFEntries,BitOffsetPointer^);
          inc(Counter);
         end;
        end;
       end;
       if (BitsBeforeThisTable+Counter>EOBCodeLength) and (BitsBeforeThisTable<EOBCodeLength) then Counter:=EOBCodeLength-BitsBeforeThisTable;
       if BitsBeforeThisTable=0 then Counter:=M;
       NumberOfEntriesInCurrentTable:=1 shl Counter;
       LLevelBitsInTableOfLevel[TableLevel]:=Counter;

       GETMEM(CurrentTable,(NumberOfEntriesInCurrentTable+1)*SizeOf(THuffManTree));
       if not assigned(CurrentTable) then begin
        if TableLevel<>0 then HuffManTreeFree(TableStack[0]);
        HuffManTreeBuild:=HuffmanTreeOutOfMemory;
        exit;
       end;
       FillChar(CurrentTable^,(NumberOfEntriesInCurrentTable+1)*SizeOf(THuffManTree),#0);
       CurrentTable^[0].ByteSize:=NumberOfEntriesInCurrentTable;
       T^:=@CurrentTable^[1];
       T:=PPHuffManTree(@CurrentTable^[0].LinkList);
       T^:=nil;
       CurrentTable:=PHuffManTreeList(@CurrentTable^[1]);
       TableStack[TableLevel]:=CurrentTable;
       if TableLevel<>0 then begin
        BitOffsets[TableLevel]:=CurrentCodeCounter;
        TableEntry.CodeBits:=LLevelBitsInTableOfLevel[TableLevel-1];
        TableEntry.ExtraBits:=16+Counter;
        TableEntry.LinkList:=CurrentTable;
        Counter:=(CurrentCodeCounter and ((1 shl BitsBeforeThisTable)-1)) shr (BitsBeforeThisTable-LLevelBitsInTableOfLevel[TableLevel-1]);
        PT:=PHuffManTree(TpvPtrUInt(TpvPtrUInt(TableStack[TableLevel-1])-SizeOf(THuffManTree)));
        if Counter>PT^.ByteSize then begin
         HuffManTreeFree(TableStack[0]);
         HuffManTreeBuild:=HuffmanTreeError;
         exit;
        end;
        PT:=@TableStack[TableLevel-1]^[Counter];
        PT^:=TableEntry;
       end;
      end;

      TableEntry.CodeBits:=TpvUInt16(NumberOfBitsInCurrentCode-BitsBeforeThisTable);
      TableEntry.LinkList:=nil;
      if TpvPtrUInt(P)>=TpvPtrUInt(@ValuesInOrderOfBitsLength[N]) then begin
       TableEntry.ExtraBits:=99;
      end else if P^<S then begin
       if P^<256 then begin
        TableEntry.ExtraBits:=16;
       end else begin
        TableEntry.ExtraBits:=15;
       end;
       TableEntry.ByteSize:=P^;
       inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
      end else begin
       if not (assigned(D) and assigned(E)) then begin
        HuffManTreeFree(TableStack[0]);
        HuffManTreeBuild:=HuffmanTreeError;
        exit;
       end;
       TableEntry.ExtraBits:=TpvUInt16(E^[P^-S]);
       TableEntry.ByteSize:=D^[P^-S];
       inc(TpvPtrUInt(P),SizeOf(TpvUInt16));
      end;

      CurrentCodeCounterRepeatsEveryFEntries:=1 shl(NumberOfBitsInCurrentCode-BitsBeforeThisTable);
      Counter:=CurrentCodeCounter shr BitsBeforeThisTable;
      while Counter<NumberOfEntriesInCurrentTable do begin
       CurrentTable^[Counter]:=TableEntry;
       inc(Counter,CurrentCodeCounterRepeatsEveryFEntries);
      end;

      Counter:=1 shl(NumberOfBitsInCurrentCode-1);
      while(CurrentCodeCounter and Counter)<> 0 do begin
       CurrentCodeCounter:=CurrentCodeCounter xor Counter;
       Counter:=Counter shr 1;
      end;
      CurrentCodeCounter:=CurrentCodeCounter xor Counter;

      while ((CurrentCodeCounter and ((1 shl BitsBeforeThisTable)-1))<>BitOffsets[TableLevel]) do begin
       dec(TableLevel);
       dec(BitsBeforeThisTable,LLevelBitsInTableOfLevel[TableLevel]);
      end;
    end;
   end;
   if (NumberOfDummyCodesAdded<>0) and (MaxCodeLength<>1) then begin
    result:=HuffmanTreeIncomplete;
   end else begin
    result:=HuffmanTreeComplete;
   end;
  end;

  function InflateCodes(LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32):TpvInt32;
  var N,D,ElementLength:TpvUInt16;
      LMask,DMask:TpvUInt16;
      T:PHuffManTree;
      TableEntry:TpvUInt8;
  begin
   LMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   DMask:=MaskBits[DistanceCodeTableLookupBits];
   while not (UserAbort or ItIsAtEnd) do begin
    NeedBits(LiteralLengthCodeTableLookupBits);
    T:=@LiteralLengthCodeTable^[BitBuffer and LMask];
    TableEntry:=T^.ExtraBits;
    if TableEntry>16 then begin
     repeat
      if TableEntry=99 then begin
       result:=StatusZipFileErr;
       exit;
      end;
      DumpBits(T^.CodeBits);
      dec(TableEntry,16);
      NeedBits(TableEntry);
      T:=@T^.LinkList^[BitBuffer and MaskBits[TableEntry]];
      TableEntry:=T^.ExtraBits;
     until TableEntry<=16;
    end;
    DumpBits(T^.CodeBits);
    if TableEntry=16 then begin
     Slide^[SlideWindowPosition]:=T^.ByteSize;
     inc(SlideWindowPosition);
     if SlideWindowPosition=SlidingDictionaryWindowSize then begin
      if not Flush(SlideWindowPosition) then begin
       InflateCodes:=StatusWriteErr;
       exit;
      end;
      SlideWindowPosition:=0;
     end;
    end else begin
     if TableEntry=15 then begin
      InflateCodes:=StatusOk;
      exit;
     end;
     NeedBits(TableEntry);
     N:=T^.ByteSize+(BitBuffer and MaskBits[TableEntry]);
     DumpBits(TableEntry);
     NeedBits(DistanceCodeTableLookupBits);
     T:=@DistanceCodeTable^[BitBuffer and DMask];
     TableEntry:=T^.ExtraBits;
     if TableEntry>16 then begin
      repeat
       if TableEntry=99 then begin
        InflateCodes:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(TableEntry,16);
       NeedBits(TableEntry);
       T:=@T^.LinkList^[BitBuffer and MaskBits[TableEntry]];
       TableEntry:=T^.ExtraBits;
      until TableEntry<=16;
     end;
     DumpBits(T^.CodeBits);
     NeedBits(TableEntry);
     D:=SlideWindowPosition-T^.ByteSize-TpvUInt16(BitBuffer and MaskBits[TableEntry]);
     DumpBits(TableEntry);
     repeat
      D:=D and (SlidingDictionaryWindowSize-1);
      if D>SlideWindowPosition then begin
       ElementLength:=SlidingDictionaryWindowSize-D;
      end else begin
       ElementLength:=SlidingDictionaryWindowSize-SlideWindowPosition;
      end;
      if ElementLength>N then ElementLength:=N;
      dec(N,ElementLength);
      if (SlideWindowPosition-D)>=ElementLength then begin
       Move(Slide^[D],Slide^[SlideWindowPosition],ElementLength);
       inc(SlideWindowPosition,ElementLength);
       inc(D,ElementLength);
      end else begin
       repeat
        Slide^[SlideWindowPosition]:=Slide^[D];
        inc(SlideWindowPosition);
        inc(D);
        dec(ElementLength);
       until ElementLength=0;
      end;
      if SlideWindowPosition=SlidingDictionaryWindowSize then begin
       if not Flush(SlideWindowPosition) then begin
        result:=StatusWriteErr;
        exit;
       end;
       SlideWindowPosition:=0;
      end;
     until N=0;
    end;
   end;
   if UserAbort then begin
    result:=Statususerabort
   end else begin
    result:=StatusreadErr;
   end;
  end;

  function InflateStored:TpvInt32;
  var NumberOfBlockInBlock:TpvUInt16;
  begin
   NumberOfBlockInBlock:=BitsInBitBuffer and 7;
   DumpBits(NumberOfBlockInBlock);

   NeedBits(16);
   NumberOfBlockInBlock:=BitBuffer and $ffff;
   DumpBits(16);
   NeedBits(16);
   if NumberOfBlockInBlock<>((not BitBuffer) and $ffff) then begin
    result:=StatuszipFileErr;
    exit;
   end;
   DumpBits(16);
   while (NumberOfBlockInBlock>0) and not (UserAbort or ItIsAtEnd) do begin
    dec(NumberOfBlockInBlock);
    NeedBits(8);
    Slide^[SlideWindowPosition]:=BitBuffer;
    inc(SlideWindowPosition);
    if SlideWindowPosition=SlidingDictionaryWindowSize then begin
     if not Flush(SlideWindowPosition)then begin
      result:=StatusWriteErr;
      exit;
     end;
     SlideWindowPosition:=0;
    end;
    DumpBits(8);
   end;
   if UserAbort then begin
    result:=StatusUserAbort;
   end else if ItIsAtEnd then begin
    result:=StatusreadErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function InflateFixed:TpvInt32;
  var Counter,Value:TpvInt32;
      LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;
      LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32;
      LengthList:array[0..287] of TpvUInt16;
  begin
   for Counter:=0 to 143 do LengthList[Counter]:=8;
   for Counter:=144 to 255 do LengthList[Counter]:=9;
   for Counter:=256 to 279 do LengthList[Counter]:=7;
   for Counter:=280 to 287 do LengthList[Counter]:=8;
   LiteralLengthCodeTableLookupBits:=7;
   Value:=HuffManTreeBuild(pword(@LengthList),288,257,PUSBList(@CopyLengthLiteralCodes),PUSBList(@ExtraBitsLiteralCodes),PPHuffManTree(@LiteralLengthCodeTable),LiteralLengthCodeTableLookupBits); {@@}
   if Value<>HuffmanTreeComplete then begin
    result:=Value;
    exit;
   end;
   for Counter:=0 to 29 do LengthList[Counter]:=5;
   DistanceCodeTableLookupBits:=5;
   if HuffManTreeBuild(pword(@LengthList),30,0,PUSBList(@CopyOffsetDistanceCodes),PUSBList(@ExtraBitsDistanceCodes),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits)>HuffmanTreeIncomplete then begin
    HuffManTreeFree(LiteralLengthCodeTable);
    result:=StatusZipFileErr;
    exit;
   end;
   result:=InflateCodes(LiteralLengthCodeTable,DistanceCodeTable,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
   HuffManTreeFree(LiteralLengthCodeTable);
   HuffManTreeFree(DistanceCodeTable);
  end;

  function InflateDynamic:TpvInt32;
  var I:TpvInt32;
      J:TpvUInt16;
      LastLength:TpvUInt16;
      BitLengthTableMask:TpvUInt16;
      NumberOfLengthsToGet:TpvUInt16;
      LiteralLengthCodeTable,
      DistanceCodeTable:PHuffManTreeList;
      LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32;
      NumberOfBitLengthCodes,NumberOfLiteralLengthCodes,NumberOfDistanceCodes:TpvUInt16;
      LiteralLengthDistanceCodeLengths:array[0..288+32-1] of TpvUInt16;
  begin
   NeedBits(5);
   NumberOfLiteralLengthCodes:=257+TpvUInt16(BitBuffer) and $1f;
   DumpBits(5);
   NeedBits(5);
   NumberOfDistanceCodes:=1+TpvUInt16(BitBuffer) and $1f;
   DumpBits(5);
   NeedBits(4);
   NumberOfBitLengthCodes:=4+TpvUInt16(BitBuffer) and $f;
   DumpBits(4);
   if (NumberOfLiteralLengthCodes>288) or (NumberOfDistanceCodes>32) then begin
    result:=1;
    exit;
   end;

   FillChar(LiteralLengthDistanceCodeLengths,SizeOf(LiteralLengthDistanceCodeLengths),#0);
   for J:=0 to NumberOfBitLengthCodes-1 do begin
    NeedBits(3);
    LiteralLengthDistanceCodeLengths[Border[J]]:=BitBuffer and 7;
    DumpBits(3);
   end;
   for J:=NumberOfBitLengthCodes to 18 do LiteralLengthDistanceCodeLengths[Border[J]]:=0;

   LiteralLengthCodeTableLookupBits:=7;
   I:=HuffManTreeBuild(pword(@LiteralLengthDistanceCodeLengths),19,19,nil,nil,PPHuffManTree(@LiteralLengthCodeTable),LiteralLengthCodeTableLookupBits); {@@}
   if I<>HuffmanTreeComplete then begin
    if I=HuffmanTreeIncomplete then HuffManTreeFree(LiteralLengthCodeTable);
    result:=StatusZipFileErr;
    exit;
   end;

   NumberOfLengthsToGet:=NumberOfLiteralLengthCodes+NumberOfDistanceCodes;
   BitLengthTableMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   I:=0;
   LastLength:=0;
   while TpvUInt16(I)<NumberOfLengthsToGet do begin
    NeedBits(LiteralLengthCodeTableLookupBits);
    DistanceCodeTable:=PHuffManTreeList(@LiteralLengthCodeTable^[BitBuffer and BitLengthTableMask]);
    J:=PHuffManTree(DistanceCodeTable)^.CodeBits;
    DumpBits(J);
    J:=PHuffManTree(DistanceCodeTable)^.ByteSize;
    if J<16 then begin
     LastLength:=J;
     LiteralLengthDistanceCodeLengths[I]:=LastLength;
     inc(I)
    end else if J=16 then begin
     NeedBits(2);
     J:=3+(BitBuffer and 3);
     DumpBits(2);
     if (I+J)>NumberOfLengthsToGet then begin
      result:=1;
      exit;
     end;
     while J>0 do begin
      LiteralLengthDistanceCodeLengths[I]:=LastLength;
      dec(J);
      inc(I);
     end;
    end else if J=17 then begin
     NeedBits(3);
     J:=3+(BitBuffer and 7);
     DumpBits(3);
     if (I+J)>NumberOfLengthsToGet then begin
      result:=1;
      exit;
     end;
     while J>0 do begin
      LiteralLengthDistanceCodeLengths[I]:=0;
      inc(I);
      dec(J);
     end;
     LastLength:=0;
    end else begin
     NeedBits(7);
     J:=11+(BitBuffer and $7f);
     DumpBits(7);
     if (I+J)>NumberOfLengthsToGet then begin
      result:=StatuszipfileErr;
      exit;
     end;
     while J>0 do begin
      LiteralLengthDistanceCodeLengths[I]:=0;
      dec(J);
      inc(I);
     end;
     LastLength:=0;
    end;
   end;
   HuffManTreeFree(LiteralLengthCodeTable);

   LiteralLengthCodeTableLookupBits:=DefaultLiteralBits;
   I:=HuffManTreeBuild(pword(@LiteralLengthDistanceCodeLengths),NumberOfLiteralLengthCodes,257,PUSBList(@CopyLengthLiteralCodes),PUSBList(@ExtraBitsLiteralCodes),PPHuffManTree(@LiteralLengthCodeTable),LiteralLengthCodeTableLookupBits);
   if I<>HuffmanTreeComplete then begin
    if I=HuffmanTreeIncomplete then HuffManTreeFree(LiteralLengthCodeTable);
    result:=StatusZipFileErr;
    exit;
   end;
   DistanceCodeTableLookupBits:=DefaultDistanceBits;
   I:=HuffManTreeBuild(pword(@LiteralLengthDistanceCodeLengths[NumberOfLiteralLengthCodes]),NumberOfDistanceCodes,0,PUSBList(@CopyOffsetDistanceCodes),PUSBList(@ExtraBitsDistanceCodes),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits);
   if I>HuffmanTreeIncomplete then begin
    if I=HuffmanTreeIncomplete then HuffManTreeFree(DistanceCodeTable);
    HuffManTreeFree(LiteralLengthCodeTable);
    result:=StatusZipFileErr;
    exit;
   end;
   InflateDynamic:=InflateCodes(LiteralLengthCodeTable,DistanceCodeTable,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
   HuffManTreeFree(LiteralLengthCodeTable);
   HuffManTreeFree(DistanceCodeTable);
  end;

  function InflateBlock(var E:TpvInt32):TpvInt32;
  var T:TpvUInt16;
  begin
   NeedBits(1);
   E:=BitBuffer and 1;
   DumpBits(1);

   NeedBits(2);
   T:=BitBuffer and 3;
   DumpBits(2);

   case T of
    0:result:=InflateStored;
    1:result:=InflateFixed;
    2:result:=InflateDynamic;
    else result:=StatusZipFileErr;
   end;
  end;

  function Inflate:TpvInt32;
  var LastBlockFlag:TpvInt32;
  begin
   InputBufferPosition:=0;
   FilePosition:=-1;
   SlideWindowPosition:=0;
   BitsInBitBuffer:=0;
   BitBuffer:=0;
   repeat
    result:=InflateBlock(LastBlockFlag);
    if result<>0 then begin
     exit;
    end;
   until LastBlockFlag<>0;
   if not Flush(SlideWindowPosition) then begin
    result:=StatusWriteErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function CopyStored:TpvInt32;
  var DoReadInBytes,ReadInBytes:TpvInt32;
  begin
   while (ReachedSize<CompressedSize) and not UserAbort do begin
    DoReadInBytes:=CompressedSize-ReachedSize;
    if DoReadInBytes>SlidingDictionaryWindowSize then begin
     DoReadInBytes:=SlidingDictionaryWindowSize;
    end;
    ReadInBytes:=InStream.Read(Slide^[0],DoReadInBytes);
    if ReadInBytes<>DoReadInBytes then begin
     result:=StatusReadErr;
     exit;
    end;
    if not Flush(ReadInBytes) then begin
     result:=StatusWriteErr;
     exit;
    end;
    inc(ReachedSize,ReadInBytes);
    Idle;
   end;
   if UserAbort then begin
    result:=StatusUserabort;
   end else begin
    result:=StatusOk;
   end;
  end;

  function GetTree(l:pword;N:TpvUInt16):TpvInt32;
  var I,K,J,B:TpvUInt16;
      ByteBuffer:TpvUInt8;
  begin
   ReadByte(ByteBuffer);
   I:=ByteBuffer;
   inc(I);
   K:=0;
   repeat
    ReadByte(ByteBuffer);
    J:=ByteBuffer;
    B:=(J and $f)+1;
    J:=((J and $f0) shr 4)+1;
    if (K+J)>N then begin
     result:=4;
     exit;
    end;
    repeat
     l^:=B;
     inc(TpvPtrUInt(l),SizeOf(TpvUInt16));
     inc(K);
     dec(J);
    until J=0;
    dec(I);
   until I=0;
   if K<>N then begin
    result:=4;
   end else begin
    result:=0;
   end;
  end;

  function ExplodeLiteral8k(BitLengthCodeTable,LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;BitLengthCodeTableLookupBits,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32): TpvInt32;
  var S:TpvInt32;
      E:TpvUInt16;
      N,D:TpvUInt16;
      W:TpvUInt16;
      T:PHuffManTree;
      BMask,LMask,DMask:TpvUInt16;
      U:TpvUInt16;
  begin
   BitBuffer:=0;
   BitsInBitBuffer:=0;
   W:=0;
   U:=1;
   BMask:=MaskBits[BitLengthCodeTableLookupBits];
   LMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   DMask:=MaskBits[DistanceCodeTableLookupBits];
   S:=UncompressedSize;
   while (S>0) and not (UserAbort or ItIsAtEnd) do begin
    NeedBits(1);
    if(BitBuffer and 1)<>0 then begin
     DumpBits(1);
     dec(S);
     NeedBits(BitLengthCodeTableLookupBits);
     T:=@BitLengthCodeTable^[BMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     Slide^[W]:=T^.ByteSize;
     inc(W);
     if W=SlidingDictionaryWindowSize then begin
      if not Flush(W) then begin
       result:=StatusWriteErr;
       exit;
      end;
      W:=0;
      U:=0;
     end;
    end else begin
     DumpBits(1);
     NeedBits(7);
     D:=BitBuffer and $7f;
     DumpBits(7);
     NeedBits(DistanceCodeTableLookupBits);
     T:=@DistanceCodeTable^[DMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.Extrabits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     D:=W-D-T^.ByteSize;
     NeedBits(LiteralLengthCodeTableLookupBits);
     T:=@LiteralLengthCodeTable^[LMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     N:=T^.ByteSize;
     if E<>0 then begin
      NeedBits(8);
      inc(N,TpvUInt8(BitBuffer) and $ff);
      DumpBits(8);
     end;
     dec(S,N);
     repeat
      D:=D and (SlidingDictionaryWindowSize-1);
      if D>W then begin
       E:=SlidingDictionaryWindowSize-D;
      end else begin
       E:=SlidingDictionaryWindowSize-W;
      end;
      if E>N then E:=N;
      dec(N,E);
      if (U<>0) and (W<=D) then begin
       FillChar(Slide^[W],E,#0);
       inc(W,E);
       inc(D,E);
      end else if(W-D>=E)then begin
       Move(Slide^[D],Slide^[W],E);
       inc(W,E);
       inc(D,E);
      end else begin
       repeat
        Slide^[W]:=Slide^[D];
        inc(W);
        inc(D);
        dec(E);
       until E=0;
      end;
      if W=SlidingDictionaryWindowSize then begin
       if not Flush(W)then begin
        result:=StatusWriteErr;
        exit;
       end;
       W:=0;
       U:=0;
      end;
     until N=0;
    end;
   end;
   if UserAbort then begin
    result:=StatusUserAbort;
   end else if not Flush(W) then begin
    result:=StatusWriteErr;
   end else if ItIsAtEnd then begin
    result:=StatusReadErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function ExplodeLiteral4k(BitLengthCodeTable,LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;BitLengthCodeTableLookupBits,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32): TpvInt32;
  var S:TpvInt32;
      E:TpvUInt16;
      N,D:TpvUInt16;
      W:TpvUInt16;
      T:PHuffManTree;
      BMask,LMask,DMask:TpvUInt16;
      U:TpvUInt16;
  begin
   BitBuffer:=0;
   BitsInBitBuffer:=0;
   W:=0;
   U:=1;
   BMask:=MaskBits[BitLengthCodeTableLookupBits];
   LMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   DMask:=MaskBits[DistanceCodeTableLookupBits];
   S:=UncompressedSize;
   while (S>0) and not (UserAbort or ItIsAtEnd) do begin
    NeedBits(1);
    if (BitBuffer and 1)<>0 then begin
     DumpBits(1);
     dec(S);
     NeedBits(BitLengthCodeTableLookupBits);
     T:=@BitLengthCodeTable^[BMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     Slide^[W]:=T^.ByteSize;
     inc(W);
     if W=SlidingDictionaryWindowSize then begin
      if not Flush(W) then begin
       result:=StatusWriteErr;
       exit;
      end;
      W:=0;
      U:=0;
     end;
    end else begin
     DumpBits(1);
     NeedBits(6);
     D:=BitBuffer and $3f;
     DumpBits(6);
     NeedBits(DistanceCodeTableLookupBits);
     T:=@DistanceCodeTable^[DMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     D:=W-D-T^.ByteSize;
     NeedBits(LiteralLengthCodeTableLookupBits);
     T:=@LiteralLengthCodeTable^[LMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     N:=T^.ByteSize;
     if E<>0 then begin
      NeedBits(8);
      inc(N,BitBuffer and $ff);
      DumpBits(8);
     end;
     dec(S,N);
     repeat
      D:=D and (SlidingDictionaryWindowSize-1);
      if D>W then begin
       E:=SlidingDictionaryWindowSize-D;
      end else begin
       E:=SlidingDictionaryWindowSize-W;
      end;
      if E>N then E:=N;
      dec(N,E);
      if (U<>0) and (W<=D) then begin
       FillChar(Slide^[W],E,#0);
       inc(W,E);
       inc(D,E);
      end else if (W-D)>=E then begin
       Move(Slide^[D],Slide^[W],E);
       inc(W,E);
       inc(D,E);
      end else begin
       repeat
        Slide^[W]:=Slide^[D];
        inc(W);
        inc(D);
        dec(E);
       until E=0;
      end;
      if W=SlidingDictionaryWindowSize then begin
       if not Flush(W) then begin
        result:=StatusWriteErr;
        exit;
       end;
       W:=0;
       U:=0;
      end;
     until N=0;
    end;
   end;
   if UserAbort then begin
    result:=StatusUserAbort;
   end else if not Flush(W) then begin
    result:=StatusWriteErr;
   end else if ItIsAtEnd then begin
    result:=StatusReadErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function ExplodeNoLiteral8k(LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32): TpvInt32;
  var S:TpvInt32;
      E:TpvUInt16;
      N,D:TpvUInt16;
      W:TpvUInt16;
      T:PHuffManTree;
      LMask,DMask:TpvUInt16;
      U:TpvUInt16;
  begin
   BitBuffer:=0;
   BitsInBitBuffer:=0;
   W:=0;
   U:=1;
   LMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   DMask:=MaskBits[DistanceCodeTableLookupBits];
   S:=UncompressedSize;
   while (S>0) and not (UserAbort or ItIsAtEnd) do begin
    NeedBits(1);
    if(BitBuffer and 1)<>0 then begin
     DumpBits(1);
     dec(S);
     NeedBits(8);
     Slide^[W]:=BitBuffer;
     inc(W);
     if W=SlidingDictionaryWindowSize then begin
      if not Flush(W)then begin
       result:=StatusWriteErr;
       exit;
      end;
      W:=0;
      U:=0;
     end;
     DumpBits(8);
    end else begin
     DumpBits(1);
     NeedBits(7);
     D:=BitBuffer and $7f;
     DumpBits(7);
     NeedBits(DistanceCodeTableLookupBits);
     T:=@DistanceCodeTable^[DMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     D:=W-D-T^.ByteSize;
     NeedBits(LiteralLengthCodeTableLookupBits);
     T:=@LiteralLengthCodeTable^[LMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then begin
      repeat
       if E=99 then begin
        result:=StatusZipFileErr;
        exit;
       end;
       DumpBits(T^.CodeBits);
       dec(E,16);
       NeedBits(E);
       T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
       E:=T^.ExtraBits;
      until E<=16;
     end;
     DumpBits(T^.CodeBits);
     N:=T^.ByteSize;
     if E<>0 then begin
      NeedBits(8);
      inc(N,BitBuffer and $ff);
      DumpBits(8);
     end;
     dec(S,N);
     repeat
      D:=D and (SlidingDictionaryWindowSize-1);
      if D>W then begin
       E:=SlidingDictionaryWindowSize-D;
      end else begin
       E:=SlidingDictionaryWindowSize-W;
      end;
      if E>N then E:=N;
      dec(N,E);
      if (U<>0) and (W<=D) then begin
       FillChar(Slide^[W],E,#0);
       inc(W,E);
       inc(D,E);
      end else if(W-D>=E)then begin
       Move(Slide^[D],Slide^[W],E);
       inc(W,E);
       inc(D,E);
      end else begin
       repeat
        Slide^[W]:=Slide^[D];
        inc(W);
        inc(D);
        dec(E);
       until E=0;
      end;
      if W=SlidingDictionaryWindowSize then begin
       if not Flush(W)then begin
        result:=StatusWriteErr;
        exit;
       end;
       W:=0;
       U:=0;
      end;
     until N=0;
    end;
   end;
   if UserAbort then begin
    result:=StatusUserAbort;
   end else if not Flush(W) then begin
    result:=StatusWriteErr;
   end else if ItIsAtEnd then begin
    result:=StatusReadErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function ExplodeNoLiteral4k(LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32): TpvInt32;
  var S:TpvInt32;
      E:TpvUInt16;
      N,D:TpvUInt16;
      W:TpvUInt16;
      T:PHuffManTree;
      LMask,DMask:TpvUInt16;
      U:TpvUInt16;
  begin
   BitBuffer:=0;
   BitsInBitBuffer:=0;
   W:=0;
   U:=1;
   LMask:=MaskBits[LiteralLengthCodeTableLookupBits];
   DMask:=MaskBits[DistanceCodeTableLookupBits];
   S:=UncompressedSize;
   while (S>0) and not (UserAbort or ItIsAtEnd) do begin
    NeedBits(1);
    if(BitBuffer and 1)<>0 then begin
     DumpBits(1);
     dec(S);
     NeedBits(8);
     Slide^[W]:=BitBuffer;
     inc(W);
     if W=SlidingDictionaryWindowSize then begin
      if not Flush(W) then begin
       result:=StatusWriteErr;
       exit;
      end;
      W:=0;
      U:=0;
     end;
     DumpBits(8);
    end else begin
     DumpBits(1);
     NeedBits(6);
     D:=BitBuffer and $3f;
     DumpBits(6);
     NeedBits(DistanceCodeTableLookupBits);
     T:=@DistanceCodeTable^[DMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then repeat
      if E=99 then begin
       result:=StatusZipFileErr;
       exit;
      end;
      DumpBits(T^.CodeBits);
      dec(E,16);
      NeedBits(E);
      T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
      E:=T^.ExtraBits;
     until E<=16;
     DumpBits(T^.CodeBits);
     D:=W-D-T^.ByteSize;
     NeedBits(LiteralLengthCodeTableLookupBits);
     T:=@LiteralLengthCodeTable^[LMask and not BitBuffer];
     E:=T^.ExtraBits;
     if E>16 then repeat
      if E=99 then begin
       result:=StatusZipFileErr;
       exit;
      end;
      DumpBits(T^.CodeBits);
      dec(E,16);
      NeedBits(E);
      T:=@T^.LinkList^[MaskBits[E] and not BitBuffer];
      E:=T^.ExtraBits;
     until E<=16;
     DumpBits(T^.CodeBits);
     N:=T^.ByteSize;
     if E<>0 then begin
      NeedBits(8);
      inc(N,BitBuffer and $ff);
      DumpBits(8);
     end;
     dec(S,N);
     repeat
      D:=D and (SlidingDictionaryWindowSize-1);
      if D>W then begin
       E:=SlidingDictionaryWindowSize-D;
      end else begin
       E:=SlidingDictionaryWindowSize-W;
      end;
      if E>N then E:=N;
      dec(N,E);
      if (U<>0) and (W<=D) then begin
       FillChar(Slide^[W],E,#0);
       inc(W,E);
       inc(D,E);
      end else if (W-D>=E) then begin
       Move(Slide^[D],Slide^[W],E);
       inc(W,E);
       inc(D,E);
      end else begin
       repeat
        Slide^[W]:=Slide^[D];
        inc(W);
        inc(D);
        dec(E);
       until E=0;
      end;
      if W=SlidingDictionaryWindowSize then begin
       if not Flush(W) then begin
        result:=StatusWriteErr;
        exit;
       end;
       W:=0;
       U:=0;
      end;
     until N=0;
    end;
   end;
   if UserAbort then begin
    result:=StatusUserAbort;
   end else if not Flush(W) then begin
    result:=StatusWriteErr;
   end else if ItIsAtEnd then begin
    result:=StatusReadErr;
   end else begin
    result:=StatusOk;
   end;
  end;

  function Explode:TpvInt32;
  var BitLengthCodeTable,LiteralLengthCodeTable,DistanceCodeTable:PHuffManTreeList;
      BitLengthCodeTableLookupBits,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits:TpvInt32;
      TreeTable:array[0..255] of TpvUInt16;
  begin
   InputBufferPosition:=0;
   FilePosition:=-1;
   LiteralLengthCodeTableLookupBits:=7;
   if CompressedSize>200000 then begin
    DistanceCodeTableLookupBits:=8;
   end else begin
    DistanceCodeTableLookupBits:=7;
   end;
   if (BitsFlagsType and 4)<>0 then begin
    BitLengthCodeTableLookupBits:=9;
    result:=GetTree(@TreeTable[0],256);
    if result<>0 then begin
     result:=StatusZipFileErr;
     exit;
    end;
    result:=HuffManTreeBuild(pword(@TreeTable),256,256,nil,nil,PPHuffManTree(@BitLengthCodeTable),BitLengthCodeTableLookupBits);
    if result<>0 then begin
     if result=HuffmanTreeIncomplete then begin
      HuffManTreeFree(BitLengthCodeTable);
     end;
     result:=StatusZipFileErr;
     exit;
    end;
    result:=GetTree(@TreeTable[0],64);
    if result<>0 then begin
     HuffManTreeFree(BitLengthCodeTable);
     result:=StatusZipFileErr;
     exit;
    end;
    result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyLength3),PUSBList(@ExtraBitsTable),PPHuffManTree(@LiteralLengthCodeTable),LiteralLengthCodeTableLookupBits);
    if result<>0 then begin
     if result=HuffmanTreeIncomplete then begin
      HuffManTreeFree(LiteralLengthCodeTable);
     end;
     HuffManTreeFree(BitLengthCodeTable);
     result:=StatusZipFileErr;
     exit;
    end;
    result:=GetTree(@TreeTable[0],64);
    if result<>0 then begin
     HuffManTreeFree(BitLengthCodeTable);
     HuffManTreeFree(LiteralLengthCodeTable);
     result:=StatusZipFileErr;
     exit;
    end;
    if (BitsFlagsType and 2)<>0 then begin
     result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyOffserDistanceCodes8),PUSBList(@ExtraBitsTable),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits);
     if result<>0 then begin
      if result=HuffmanTreeIncomplete then begin
       HuffManTreeFree(DistanceCodeTable);
      end;
      HuffManTreeFree(BitLengthCodeTable);
      HuffManTreeFree(LiteralLengthCodeTable);
      result:=StatusZipFileErr;
      exit;
     end;
     result:=ExplodeLiteral8k(BitLengthCodeTable,LiteralLengthCodeTable,DistanceCodeTable,BitLengthCodeTableLookupBits,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
    end else begin
     result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyOffserDistanceCodes4),PUSBList(@ExtraBitsTable),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits);
     if result<>0 then begin
      if result=HuffmanTreeIncomplete then begin
       HuffManTreeFree(DistanceCodeTable);
      end;
      HuffManTreeFree(BitLengthCodeTable);
      HuffManTreeFree(LiteralLengthCodeTable);
      result:=StatusZipFileErr;
      exit;
     end;
     result:=ExplodeLiteral4k(BitLengthCodeTable,LiteralLengthCodeTable,DistanceCodeTable,BitLengthCodeTableLookupBits,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
    end;
    HuffManTreeFree(DistanceCodeTable);
    HuffManTreeFree(LiteralLengthCodeTable);
    HuffManTreeFree(BitLengthCodeTable);
   end else begin
    result:=GetTree(@TreeTable[0],64);
    if result<>0 then begin
     result:=StatusZipFileErr;
     exit;
    end;
    result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyLength2),PUSBList(@ExtraBitsTable),PPHuffManTree(@LiteralLengthCodeTable),LiteralLengthCodeTableLookupBits);
    if result<>0 then begin
     if result=HuffmanTreeIncomplete then begin
      HuffManTreeFree(LiteralLengthCodeTable);
     end;
     result:=StatusZipFileErr;
     exit;
    end;
    result:=GetTree(@TreeTable[0],64);
    if result<>0 then begin
     HuffManTreeFree(LiteralLengthCodeTable);
     result:=StatusZipFileErr;
     exit;
    end;
    if (BitsFlagsType and 2)<>0 then begin
     result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyOffserDistanceCodes8),PUSBList(@ExtraBitsTable),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits);
     if result<>0 then begin
      if result=HuffmanTreeIncomplete then begin
       HuffManTreeFree(DistanceCodeTable);
      end;
      HuffManTreeFree(LiteralLengthCodeTable);
      result:=StatusZipFileErr;
      exit;
     end;
     result:=ExplodeNoLiteral8k(LiteralLengthCodeTable,DistanceCodeTable,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
    end else begin
     result:=HuffManTreeBuild(pword(@TreeTable),64,0,PUSBList(@CopyOffserDistanceCodes4),PUSBList(@ExtraBitsTable),PPHuffManTree(@DistanceCodeTable),DistanceCodeTableLookupBits);
     if result<>0 then begin
      if result=HuffmanTreeIncomplete then begin
       HuffManTreeFree(DistanceCodeTable);
      end;
      HuffManTreeFree(LiteralLengthCodeTable);
      result:=StatusZipFileErr;
      exit;
     end;
     result:=ExplodeNoLiteral4k(LiteralLengthCodeTable,DistanceCodeTable,LiteralLengthCodeTableLookupBits,DistanceCodeTableLookupBits);
    end;
    HuffManTreeFree(DistanceCodeTable);
    HuffManTreeFree(LiteralLengthCodeTable);
   end;
  end;

  function WriteChar(C:TpvUInt8):boolean;
  begin
   result:=OutStream.Write(C,SizeOf(TpvUInt8))=SizeOf(TpvUInt8);
   CRC32.Update(C,SizeOf(TpvUInt8));
  end;

  procedure ClearLeafNodes;
  var PreviousCodeValue:TpvInt32;
      index:TpvInt32;
      MaxActualCode:TpvInt32;
      CurrentPreviousCodeTrie:PPreviousCodeTrie;
  begin
   CurrentPreviousCodeTrie:=PreviousCode;
   MaxActualCode:=NextFreeCodeInTrie-1;
   for index:=257 to MaxActualCode do begin
    CurrentPreviousCodeTrie^[index]:=CurrentPreviousCodeTrie^[index] or $8000;
   end;
   for index:=257 to MaxActualCode do begin
    PreviousCodeValue:=CurrentPreviousCodeTrie^[index] and not $8000;
    if PreviousCodeValue>256 then begin
     CurrentPreviousCodeTrie^[PreviousCodeValue]:=CurrentPreviousCodeTrie^[PreviousCodeValue] and not $8000;
    end;
   end;
   PreviousCodeValue:=-1;
   NextFreeCodeInTrie:=-1;
   for index:=257 to MaxActualCode do begin
    if (CurrentPreviousCodeTrie^[index] and $c000)<>0 then begin
     if PreviousCodeValue<>-1 then begin
      CurrentPreviousCodeTrie^[PreviousCodeValue]:=-index;
     end else begin
      NextFreeCodeInTrie:=index;
     end;
     PreviousCodeValue:=index;
    end;
   end;
   if PreviousCodeValue<>-1 then begin
    CurrentPreviousCodeTrie^[PreviousCodeValue]:=-MaxActualCode-1;
   end;
  end;

  function Unshrink:TpvInt32;
   function DoIt:TpvInt32;
   var InputCode:TpvInt32;
       LastInputCode:TpvInt32;
       LastOutputCode:TpvUInt8;
       ActualCodeSize:TpvUInt8;
       StackPtr:TpvInt32;
       NewCode:TpvInt32;
       CodeMask:TpvInt32;
       index:TpvInt32;
       BitsToRead:TpvInt32;
   begin
    InputBufferPosition:=0;
    FilePosition:=-1;

    SlideWindowPosition:=0;
    BitsInBitBuffer:=0;
    BitBuffer:=0;

    FillChar(PreviousCode^,SizeOf(TPreviousCodeTrie),#0);
    FillChar(ActualCode^,SizeOf(TActualCodeTrie),#0);
    FillChar(Stack^,SizeOf(TStack),#0);

    for index:=257 to MaxCode do begin
     PreviousCode^[index]:=-(index+1);
    end;
    NextFreeCodeInTrie:=257;
    StackPtr:=MaxStack;
    ActualCodeSize:=InitialCodeSize;
    CodeMask:=MaskBits[ActualCodeSize];

    NeedBits(ActualCodeSize);
    InputCode:=BitBuffer and CodeMask;
    DumpBits(ActualCodeSize);

    LastInputCode:=InputCode;
    LastOutputCode:=InputCode and $ff;

    if not WriteChar(LastOutputCode) then begin
     result:=StatuswriteErr;
     exit;
    end;

    BitsToRead:=(8*CompressedSize)-ActualCodeSize;

    while (BitsToRead>=ActualCodeSize) and not UserAbort do begin
     NeedBits(ActualCodeSize);
     InputCode:=BitBuffer and CodeMask;
     DumpBits(ActualCodeSize);
     dec(BitsToRead,ActualCodeSize);
     if InputCode=256 then begin
      NeedBits(ActualCodeSize);
      InputCode:=BitBuffer and CodeMask;
      DumpBits(ActualCodeSize);
      dec(BitsToRead,ActualCodeSize);
      case InputCode of
       1:begin
        inc(ActualCodeSize);
        if ActualCodeSize>FinalCodeSize then begin
         result:=StatusZipFileErr;
         exit;
        end;
        CodeMask:=MaskBits[ActualCodeSize];
       end;
       2:begin
        ClearLeafNodes;
       end;
       else begin
        result:=StatusZipFileErr;
        exit;
       end;
      end;
     end else begin
      NewCode:=InputCode;
      if InputCode<256 then begin
       LastOutputCode:=InputCode and $ff;
       if not WriteChar(LastOutputCode) then begin
        result:=StatusWriteErr;
        exit;
       end;
      end else begin
       if PreviousCode^[InputCode]<0 then begin
        Stack^[StackPtr]:=LastOutputCode;
        dec(StackPtr);
        InputCode:=LastInputCode;
       end;
       while InputCode>256 do begin
        Stack^[StackPtr]:=ActualCode^[InputCode];
        dec(StackPtr);
        InputCode:=PreviousCode^[InputCode];
       end;
       LastOutputCode:=InputCode and $ff;
       if not WriteChar(LastOutputCode) then begin
        result:=StatusWriteErr;
        exit;
       end;
       for index:=StackPtr+1 to MaxStack do begin
        if not WriteChar(Stack^[index]) then begin
         result:=StatusWriteErr;
         exit;
        end;
       end;
       StackPtr:=MaxStack;
      end;
      InputCode:=NextFreeCodeInTrie;
      if InputCode<=MaxCode then begin
       NextFreeCodeInTrie:=-PreviousCode^[InputCode];
       PreviousCode^[InputCode]:=LastInputCode;
       ActualCode^[InputCode]:=LastOutputCode;
      end;
      LastInputCode:=NewCode;
     end;
    end;
    if UserAbort then begin
     result:=StatusUserAbort;
    end else begin
     result:=StatusOk;
    end;
   end;
  begin
   if CompressedSize=MAXLONGINT then begin
    result:=StatusNotSupported;
    exit;
   end;
   New(PreviousCode);
   New(ActualCode);
   New(Stack);
   try
    result:=DoIt;
   finally
    Dispose(PreviousCode);
    Dispose(ActualCode);
    Dispose(Stack);
   end;
  end;

  function Unreduce(InputFactor:TpvInt32):TpvInt32;
  const DLE=144;
  type PFArray=^TFArray;
       TFArray=array[0..63] of TpvUInt8;
       PFollowers=^TFollowers;
       TFollowers=array[0..255] of TFArray;
       PSlen=^TSlen;
       TSlen=array[0..255] of TpvUInt8;
  const L_table:array[0..4] of TpvInt32=($00,$7f,$3f,$1f,$0f);
        D_shift:array[0..4] of TpvInt32=($00,$07,$06,$05,$04);
        D_mask:array[0..4] of TpvInt32=($00,$01,$03,$07,$0f);
        B_table:array[0..255] of TpvInt32=(8,1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5,
                                          5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,
                                          6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
                                          6,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,
                                          7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                                          7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                                          7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                                          7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
                                          8,8,8,8);
  var Slen:PSLen;
      Followers:PFollowers;
   function DoIt:TpvInt32;
   var lchar,nchar,ExState,v,Len,s,u,Factor,Follower,BitsNeeded,x,i:TpvInt32;
       e,n,d:TpvUInt32;
   begin
    u:=1;
    v:=0;
    lchar:=0;
    Len:=0;
    ExState:=0;
    Factor:=InputFactor;
    for x:=255 downto 0 do begin
     Slen^[x]:=ReadBits(6);
     for i:=0 to Slen^[x]-1 do begin
      Followers^[x,i]:=ReadBits(8);
     end;
    end;
    SlideWindowPosition:=0;
    S:=UncompressedSize;
    while (S>0) and not (UserAbort or ItIsAtEnd) do begin
     if Slen^[lchar]=0 then begin
      nchar:=ReadBits(8);
     end else begin
      nchar:=ReadBits(1);
      if nchar<>0 then begin
       nchar:=ReadBits(8);
      end else begin
       BitsNeeded:=B_table[Slen^[lchar]];
       Follower:=ReadBits(BitsNeeded);
       nchar:=Followers[lchar,follower];
      end;
     end;
     case ExState of
      0:begin
       if nchar<>DLE then begin
        dec(s);
        Slide^[SlideWindowPosition]:=TpvUInt8(nchar);
        inc(SlideWindowPosition);
        if SlideWindowPosition=$4000 then begin
         if not Flush(SlideWindowPosition) then begin
          result:=StatusWriteErr;
          exit;
         end;
         SlideWindowPosition:=0;
         u:=0;
        end;
       end else begin
        ExState:=1;
       end;
      end;
      1:begin
       if nchar<>0 then begin
        v:=nchar;
        Len:=v and L_table[Factor];
        if Len=L_table[Factor] then begin
         ExState:=2;
        end else begin
         ExState:=3;
        end;
       end else begin
        dec(s);
        Slide^[SlideWindowPosition]:=TpvUInt8(DLE);
        inc(SlideWindowPosition);
        if SlideWindowPosition=$4000 then begin
         if not Flush(SlideWindowPosition) then begin
          result:=StatusWriteErr;
          exit;
         end;
         SlideWindowPosition:=0;
         u:=0;
        end;
        ExState:=0;
       end;
      end;
      2:begin
       inc(Len,nchar);
       ExState:=3;
      end;
      3:begin
       n:=Len+3;
       d:=SlideWindowPosition-(((((v shr D_shift[Factor]) and D_mask[Factor]) shl 8)+nchar)+1);
       dec(s,n);
       repeat
        d:=d and $3fff;
        if d>TpvUInt32(SlideWindowPosition) then begin
         e:=d;
        end else begin
         e:=SlideWindowPosition;
        end;
        e:=$4000-e;
        if e>n then begin
         e:=n;
        end;
        dec(n,e);
        if (u<>0) and (SlideWindowPosition<=d) then begin
         FillChar(Slide^[SlideWindowPosition],e,#0);
         inc(SlideWindowPosition,e);
         inc(d,e);
        end else if (TpvUInt32(SlideWindowPosition)-d)<e then begin
         repeat
          Slide^[SlideWindowPosition]:=Slide^[d];
          inc(SlideWindowPosition);
          inc(d);
          dec(e);
         until e=0;
        end else begin
         Move(Slide^[d],Slide^[SlideWindowPosition],e);
         inc(SlideWindowPosition,e);
         inc(d,e);
        end;
        if SlideWindowPosition=$4000 then begin
         if not Flush(SlideWindowPosition) then begin
          result:=StatusWriteErr;
          exit;
         end;
         SlideWindowPosition:=0;
         u:=0;
        end;
       until n=0;
       ExState:=0;
      end;
     end;
     lchar:=nchar;
    end;
    if UserAbort then begin
     result:=StatusUserAbort;
    end else if s=0 then begin
     result:=StatusOk;
    end else begin
     result:=StatusReadErr;
    end;
   end;
  begin
   if CompressedSize=MAXLONGINT then begin
    result:=StatusNotSupported;
    exit;
   end;
   New(Slen);
   New(Followers);
   try
    result:=DoIt;
   finally
    Dispose(Slen);
    Dispose(Followers);
   end;
  end;

  function DoDecompress(InStream,OutStream:TStream):TpvInt32;
  begin

   GetMem(Slide,SlidingDictionaryWindowSize);
   FillChar(Slide^,SlidingDictionaryWindowSize,#0);
   try

    ReachedSize:=0;

    UserAbort:=false;
    ItIsAtEnd:=false;

    BitsFlagsType:=LocalFileHeader.BitFlags;

    case LocalFileHeader.CompressMethod of
     0:begin
      result:=CopyStored;
     end;
     1:begin
      result:=Unshrink;
     end;
     2..5:begin
      result:=Unreduce(LocalFileHeader.CompressMethod-1);
     end;
     6:begin
      result:=Explode;
     end;
     8:begin
      result:=Inflate;
     end;
     else begin
      result:=StatusNotSupported;
     end;
    end;

    if (result=Statusok) and ((BitsFlagsType and 8)<>0) then begin
     DumpBits(BitsInBitBuffer and 7);
     NeedBits(16);

     DumpBits(16);
     NeedBits(16);
     OriginalCRC:=(BitBuffer and $ffff) shl 16;
     DumpBits(16);
    end;

   finally
    FreeMem(Slide);
   end;

  end;

 begin
  result:=DoDecompress(InStream,OutStream)=StatusOk;
 end;
 procedure Inflate;
 var InData:TpvPointer;
     DestData:TpvPointer;
     DestLen:TpvSizeUInt;
 begin
  if CompressedSize>0 then begin
   DestData:=nil;
   DestLen:=0;
   try
    GetMem(InData,CompressedSize);
    try
     fSourceArchive.fStream.ReadBuffer(InData^,CompressedSize);
     DoInflate(InData,CompressedSize,DestData,DestLen,false);
    finally
     FreeMem(InData);
    end;
    if DestLen>0 then begin
     CRC32.Update(DestData^,DestLen);
     aStream.WriteBuffer(DestData^,DestLen);
    end;
   finally
    if assigned(DestData) then begin
     FreeMem(DestData);
    end;
   end;
  end;
 end;
begin
 if assigned(aStream) then begin

  if aStream is TMemoryStream then begin
   (aStream as TMemoryStream).Clear;
  end else if (aStream is TFileStream) and ((aStream as TFileStream).Size>0) then begin
   (aStream as TFileStream).Size:=0;
  end;

  if assigned(fSourceArchive) then begin

   if fSourceArchive.fStream.Seek(fHeaderPosition,soBeginning)<>fHeaderPosition then begin
    raise EpvArchiveZIP.Create('Seek error');
   end;

   fSourceArchive.fStream.ReadBuffer(LocalFileHeader,SizeOf(TpvArchiveZIPLocalFileHeader));

   if LocalFileHeader.Signature.Value<>TpvArchiveZIPHeaderSignatures.LocalFileHeaderSignature.Value then begin
    raise EpvArchiveZIP.Create('Invalid or corrupt ZIP archive');
   end;

   LocalFileHeader.SwapEndiannessIfNeeded;

   Offset:=fSourceArchive.fStream.Position+LocalFileHeader.FileNameLength+LocalFileHeader.ExtraFieldLength;

   if (LocalFileHeader.BitFlags and 8)=0 then begin
    CompressedSize:=LocalFileHeader.CompressedSize;
    UncompressedSize:=LocalFileHeader.UncompressedSize;
    OriginalCRC:=LocalFileHeader.CRC32;
   end else begin
    CompressedSize:=High(TpvInt64);
    UncompressedSize:=High(TpvInt64);
    OriginalCRC:=0;
   end;

   if LocalFileHeader.ExtraFieldLength>=SizeOf(TpvArchiveZIPExtensibleDataFieldHeader) then begin
    StartPosition:=fSourceArchive.fStream.Position;
    while (fSourceArchive.fStream.Position+(SizeOf(ExtensibleDataFieldHeader)-1))<(StartPosition+LocalFileHeader.ExtraFieldLength) do begin
     fSourceArchive.fStream.ReadBuffer(ExtensibleDataFieldHeader,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader));
     ExtensibleDataFieldHeader.SwapEndiannessIfNeeded;
     From:=fSourceArchive.fStream.Position;
     case ExtensibleDataFieldHeader.HeaderID of
      TpvArchiveZIP64ExtensibleInfoFieldHeader.HeaderID:begin
       fSourceArchive.fStream.ReadBuffer(ExtensibleInfoFieldHeader,SizeOf(TpvArchiveZIP64ExtensibleInfoFieldHeader));
       ExtensibleInfoFieldHeader.SwapEndiannessIfNeeded;
       if (LocalFileHeader.BitFlags and 8)=0 then begin
        if LocalFileHeader.CompressedSize=TpvUInt32($ffffffff) then begin
         CompressedSize:=ExtensibleInfoFieldHeader.CompressedSize;
        end;
        if LocalFileHeader.UncompressedSize=TpvUInt32($ffffffff) then begin
         UncompressedSize:=ExtensibleInfoFieldHeader.OriginalSize;
        end;
       end;
      end;
      $7075:begin
      end;
     end;
     if fSourceArchive.fStream.Seek(From+ExtensibleDataFieldHeader.DataSize,soBeginning)<>(From+ExtensibleDataFieldHeader.DataSize) then begin
      raise EpvArchiveZIP.Create('Seek error');
     end;
    end;
   end else if LocalFileHeader.ExtraFieldLength>0 then begin
    From:=fSourceArchive.fStream.Position;
    if fSourceArchive.fStream.Seek(From+LocalFileHeader.ExtraFieldLength,soBeginning)<>(From+LocalFileHeader.ExtraFieldLength) then begin
     raise EpvArchiveZIP.Create('Seek error');
    end;
   end;

   if (LocalFileHeader.BitFlags and 1)<>0 then begin
    raise EpvArchiveZIP.Create('Encrypted ZIP archive');
   end;

   if (LocalFileHeader.BitFlags and 32)<>0 then begin
    raise EpvArchiveZIP.Create('Patched ZIP archive');
   end;

   if fSourceArchive.fStream.Seek(Offset,soBeginning)<>Offset then begin
    raise EpvArchiveZIP.Create('Seek error');
   end;

   if CompressedSize>0 then begin

    CRC32.Initialize;

    case LocalFileHeader.CompressMethod of
     0:begin
      if aStream.CopyFrom(fSourceArchive.fStream,CompressedSize)<>CompressedSize then begin
       raise EpvArchiveZIP.Create('Read error');
      end;
      CRC32.Update(aStream);
     end;
     1..6:begin
      if not Decompress(fSourceArchive.fStream,aStream) then begin
       raise EpvArchiveZIP.Create('Decompression failed');
      end;
     end;
     8:begin
      if (CompressedSize<high(TpvUInt16)) and
         (UncompressedSize<high(TpvUInt16)) then begin
       Inflate;
      end else begin
       if not Decompress(fSourceArchive.fStream,aStream) then begin
        raise EpvArchiveZIP.Create('Decompression failed');
       end;
      end;
     end;
     else
     begin
      raise EpvArchiveZIP.Create('Non-supported compression method');
     end;
    end;

    if (aStream.Size<>0) and (CRC32.Finalize<>OriginalCRC) then begin
     raise EpvArchiveZIP.Create('Checksum mismatch');
    end;

   end;

  end else if assigned(fStream) then begin
   fStream.Seek(0,soBeginning);
   aStream.CopyFrom(fStream,fStream.Size);
  end;

 end;

end;

procedure TpvArchiveZIPEntry.SaveToFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

constructor TpvArchiveZIPEntries.Create;
begin
 inherited Create(TpvArchiveZIPEntry);
 fFileNameHashMap:=TpvArchiveZIPEntriesFileNameHashMap.Create(nil);
end;

destructor TpvArchiveZIPEntries.Destroy;
begin
 Clear;
 FreeAndNil(fFileNameHashMap);
 inherited Destroy;
end;

function TpvArchiveZIPEntries.GetEntry(const aIndex:TpvSizeInt):TpvArchiveZIPEntry;
begin
 result:=inherited Items[aIndex] as TpvArchiveZIPEntry;
end;

procedure TpvArchiveZIPEntries.SetEntry(const aIndex:TpvSizeInt;const aEntry:TpvArchiveZIPEntry);
begin
 inherited Items[aIndex]:=aEntry;
end;

function TpvArchiveZIPEntries.Add(const aFileName:TpvRawByteString):TpvArchiveZIPEntry;
begin
 result:=TpvArchiveZIPEntry.Create(self);
 result.SetFileName(aFileName);
end;

function TpvArchiveZIPEntries.Find(const aFileName:TpvRawByteString):TpvArchiveZIPEntry;
begin
 result:=fFileNameHashMap[TpvArchiveZIP.CorrectPath(aFileName)];
end;

constructor TpvArchiveZIP.Create;
begin
 inherited Create;
 fEntries:=TpvArchiveZIPEntries.Create;
 fStream:=nil;
 fOwnStream:=false;
 fZIP64:=false;
end;

destructor TpvArchiveZIP.Destroy;
begin
 FreeAndNil(fEntries);
 if fOwnStream then begin
  FreeAndNil(fStream);
  fOwnStream:=false;
 end;
 inherited Destroy;
end;

class function TpvArchiveZIP.CorrectPath(const aFileName:TpvRawByteString):TpvRawByteString;
var Index:TpvSizeInt;
begin
 result:=aFileName;
 for Index:=1 to length(result) do begin
  case result[Index] of
   '\':begin
    result[Index]:='/';
   end;
  end;
 end;
end;

procedure TpvArchiveZIP.Clear;
begin
 if fOwnStream then begin
  FreeAndNil(fStream);
  fOwnStream:=false;
 end else begin
  fStream:=nil;
 end;
 fEntries.Clear;
end;

procedure TpvArchiveZIP.LoadFromStream(const aStream:TStream);
var LocalFileHeader:TpvArchiveZIPLocalFileHeader;
    EndCentralFileHeader:TpvArchiveZIPEndCentralFileHeader;
    ZIP64EndCentralFileHeader:TpvArchiveZIP64EndCentralFileHeader;
    CentralFileHeader:TpvArchiveZIPCentralFileHeader;
    Size,CentralFileHeaderOffset,EndCentralFileHeaderOffset,
    ZIP64EndCentralLocatorOffset,ZIP64EndCentralFileHeaderOffset,
    EntriesThisDisk:TpvInt64;
    Index,Count,FileCount:TpvSizeInt;
    FileName:TpvRawByteString;
    HasExtensibleInfoFieldHeader,OK:boolean;
    FileEntry:TpvArchiveZIPEntry;
    StartPosition,From:TpvInt64;
    ZIPExtensibleDataFieldHeader:TpvArchiveZIPExtensibleDataFieldHeader;
    ZIP64ExtensibleInfoFieldHeader:TpvArchiveZIP64ExtensibleInfoFieldHeader;
    ZIP64EndCentralLocator:TpvArchiveZIP64EndCentralLocator;
begin

 Clear;

 fStream:=aStream;

 Size:=fStream.Size;

 OK:=false;

 fZIP64:=false;

 fStream.Seek(0,soFromBeginning);

 fStream.ReadBuffer(LocalFileHeader,SizeOf(TpvArchiveZIPLocalFileHeader));

 EndCentralFileHeaderOffset:=-1;
 ZIP64EndCentralLocatorOffset:=-1;
 ZIP64EndCentralFileHeaderOffset:=-1;

 if LocalFileHeader.Signature.Value=TpvArchiveZIPHeaderSignatures.LocalFileHeaderSignature.Value then begin

  for Index:=Size-SizeOf(TpvArchiveZipEndCentralFileHeader) downto Size-(65535+SizeOf(TpvArchiveZipEndCentralFileHeader)) do begin
   if Index<0 then begin
    break;
   end else begin
    fStream.Seek(Index,soFromBeginning);
    if fStream.Read(EndCentralFileHeader,SizeOf(TpvArchiveZipEndCentralFileHeader))=SizeOf(TpvArchiveZipEndCentralFileHeader) then begin
     if EndCentralFileHeader.Signature.Value=TpvArchiveZIPHeaderSignatures.EndCentralFileHeaderSignature.Value then begin
      EndCentralFileHeaderOffset:=Index;
      EndCentralFileHeader.SwapEndiannessIfNeeded;
      OK:=true;
      break;
     end;
    end;
   end;
  end;

  if OK then begin

   for Index:=EndCentralFileHeaderOffset-SizeOf(TpvArchiveZIP64EndCentralLocator) downto EndCentralFileHeaderOffset-(65535+SizeOf(TpvArchiveZIP64EndCentralLocator)) do begin
    if Index<0 then begin
     break;
    end else begin
     fStream.Seek(Index,soFromBeginning);
     if fStream.Read(ZIP64EndCentralLocator,SizeOf(TpvArchiveZIP64EndCentralLocator))=SizeOf(TpvArchiveZIP64EndCentralLocator) then begin
      if ZIP64EndCentralLocator.Signature.Value=TpvArchiveZIPHeaderSignatures.Zip64CentralLocatorHeaderSignature.Value then begin
       ZIP64EndCentralLocator.SwapEndiannessIfNeeded;
       ZIP64EndCentralFileHeaderOffset:=Index;
       break;
      end;
     end;
    end;
   end;

   if ZIP64EndCentralLocatorOffset>=0 then begin
    OK:=false;
    ZIP64EndCentralFileHeaderOffset:=ZIP64EndCentralLocator.CentralDirectoryOffset;
    fStream.Seek(ZIP64EndCentralFileHeaderOffset,soFromBeginning);
    if fStream.Read(ZIP64EndCentralFileHeader,SizeOf(TpvArchiveZIP64EndCentralFileHeader))=SizeOf(TpvArchiveZIP64EndCentralFileHeader) then begin
     if ZIP64EndCentralFileHeader.Signature.Value=TpvArchiveZIPHeaderSignatures.Zip64EndCentralFileHeaderSignature.Value then begin
      OK:=true;
      fZIP64:=true;
     end;
    end;
   end else begin
    for Index:=EndCentralFileHeaderOffset-SizeOf(TpvArchiveZIP64EndCentralFileHeader) downto EndCentralFileHeaderOffset-(65535+SizeOf(TpvArchiveZIP64EndCentralFileHeader)) do begin
     if Index<0 then begin
      break;
     end else begin
      fStream.Seek(Index,soFromBeginning);
      if fStream.Read(ZIP64EndCentralFileHeader,SizeOf(TpvArchiveZIP64EndCentralFileHeader))=SizeOf(TpvArchiveZIP64EndCentralFileHeader) then begin
       if ZIP64EndCentralFileHeader.Signature.Value=TpvArchiveZIPHeaderSignatures.Zip64EndCentralFileHeaderSignature.Value then begin
        ZIP64EndCentralFileHeader.SwapEndiannessIfNeeded;
        ZIP64EndCentralFileHeaderOffset:=Index;
        fZIP64:=true;
        break;
       end;
      end;
     end;
    end;
   end;

  end;

 end;

 if not OK then begin
  raise EpvArchiveZIP.Create('Invalid ZIP archive');
 end;

 Count:=0;

 if (ZIP64EndCentralFileHeaderOffset>=0) and (EndCentralFileHeader.StartDiskOffset=TpvUInt32($ffffffff)) then begin
  fStream.Seek(ZIP64EndCentralFileHeader.StartDiskOffset,soFromBeginning);
 end else begin
  fStream.Seek(EndCentralFileHeader.StartDiskOffset,soFromBeginning);
 end;

 if (ZIP64EndCentralFileHeaderOffset>=0) and (EndCentralFileHeader.EntriesThisDisk=TpvUInt32($ffff)) then begin
  EntriesThisDisk:=ZIP64EndCentralFileHeader.EntriesThisDisk;
 end else begin
  EntriesThisDisk:=EndCentralFileHeader.EntriesThisDisk;
 end;

 repeat

  CentralFileHeaderOffset:=fStream.Position;

  if fStream.Read(CentralFileHeader,SizeOf(TpvArchiveZIPCentralFileHeader))<>SizeOf(TpvArchiveZIPCentralFileHeader) then begin
   break;
  end;

  if CentralFileHeader.Signature.Value<>TpvArchiveZIPHeaderSignatures.CentralFileHeaderSignature.Value then begin
   break;
  end;

  CentralFileHeader.SwapEndiannessIfNeeded;

  SetLength(FileName,CentralFileHeader.FileNameLength);
  if CentralFileHeader.FileNameLength>0 then begin
   if fStream.Read(FileName[1],CentralFileHeader.FileNameLength)<>CentralFileHeader.FileNameLength then begin
    break;
   end;
  end;

  if Count<EntriesThisDisk then begin

   HasExtensibleInfoFieldHeader:=false;

   if CentralFileHeader.ExtraFieldLength>=SizeOf(TpvArchiveZIPExtensibleDataFieldHeader) then begin
    StartPosition:=fStream.Position;
    while (fStream.Position+(SizeOf(ZIPExtensibleDataFieldHeader)-1))<(StartPosition+CentralFileHeader.ExtraFieldLength) do begin
     fStream.ReadBuffer(ZIPExtensibleDataFieldHeader,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader));
     ZIPExtensibleDataFieldHeader.SwapEndiannessIfNeeded;
     From:=fStream.Position;
     case ZIPExtensibleDataFieldHeader.HeaderID of
      TpvArchiveZIP64ExtensibleInfoFieldHeader.HeaderID:begin
       fStream.ReadBuffer(ZIP64ExtensibleInfoFieldHeader,SizeOf(TpvArchiveZIP64ExtensibleInfoFieldHeader));
       ZIP64ExtensibleInfoFieldHeader.SwapEndiannessIfNeeded;
       HasExtensibleInfoFieldHeader:=true;
      end;
      $7075:begin
      end;
     end;
     if fStream.Seek(From+ZIPExtensibleDataFieldHeader.DataSize,soBeginning)<>From+ZIPExtensibleDataFieldHeader.DataSize then begin
      raise EpvArchiveZIP.Create('Seek error');
     end;
    end;
   end else if CentralFileHeader.ExtraFieldLength>0 then begin
    fStream.Seek(CentralFileHeader.ExtraFieldLength,soFromCurrent);
   end;

   fStream.Seek(CentralFileHeader.FileCommentLength,soFromCurrent);

   if length(FileName)>0 then begin
    FileEntry:=fEntries.Add(FileName);
    FileEntry.fCentralHeaderPosition:=CentralFileHeaderOffset;
    FileEntry.fRequiresZIP64:=HasExtensibleInfoFieldHeader;
    if HasExtensibleInfoFieldHeader then begin
     if CentralFileHeader.LocalFileHeaderOffset=TpvUInt32($ffffffff) then begin
      FileEntry.fHeaderPosition:=ZIP64ExtensibleInfoFieldHeader.RelativeHeaderOffset;
     end else begin
      FileEntry.fHeaderPosition:=CentralFileHeader.LocalFileHeaderOffset;
     end;
     if CentralFileHeader.UncompressedSize=TpvUInt32($ffffffff) then begin
      FileEntry.Size:=ZIP64ExtensibleInfoFieldHeader.CompressedSize;
     end else begin
      FileEntry.Size:=CentralFileHeader.UncompressedSize;
     end;
    end else begin
     FileEntry.fHeaderPosition:=CentralFileHeader.LocalFileHeaderOffset;
     FileEntry.Size:=CentralFileHeader.UncompressedSize;
    end;
    FileEntry.fSourceArchive:=self;
   end;

   inc(Count);

  end else begin

   Count:=not EntriesThisDisk;
   break;

  end;

 until false;

 if EntriesThisDisk<>Count then begin
  raise EpvArchiveZIP.Create('Invalid ZIP archive');
 end;

end;

procedure TpvArchiveZIP.LoadFromFile(const aFileName:string);
var Stream:TStream;
begin
 if fOwnStream then begin
  FreeAndNil(fStream);
  fOwnStream:=false;
 end else begin
  fStream:=nil;
 end;
 Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
  fOwnStream:=true;
 finally
 end;
end;

procedure TpvArchiveZIP.SaveToStream(const aStream:TStream);
 function CompressShrink(InStream,OutStream:TStream):boolean;
 const BufSize=10240;
       MINBITS=9;
       MAXBITS=13;
       TABLESIZE=8191;
       SPECIAL=256;
       INCSIZE=1;
       CLEARCODE=2;
       FIRSTENTRY=257;
       UNUSED=-1;
       STDATTR=$23;
 type TCodeTableItem=record
       Child:TpvInt32;
       Sibling:TpvInt32;
       Suffix:TpvUInt8;
      end;

      PCodeTable=^TCodeTable;
      TCodeTable=array[0..TABLESIZE] of TCodeTableItem;

      PFreeList=^TFreeList;
      TFreeList=array[FIRSTENTRY..TABLESIZE] of longword;

      PClearList=^TClearList;
      TClearList=array[0..1023] of TpvUInt8;

 var FirstByte:boolean;
     TableFull:boolean;
     SaveByte:TpvUInt8;
     BitsUsed:TpvUInt8;
     CodeSize:TpvUInt8;
     MaxCode:TpvUInt16;
     CodeTable:PCodeTable;
     FreeList:PFreeList;
     ClearList:PClearList;
     NextFree:TpvUInt16;
     LastCode:TpvInt32;

  procedure Prune(Parent:TpvUInt16);
  var CurrentChild,NextSibling:TpvInt32;
  begin
   CurrentChild:=CodeTable^[Parent].Child;
   while (CurrentChild>=0) and (CodeTable^[CurrentChild].Child<0) do begin
    CodeTable^[Parent].Child:=CodeTable^[CurrentChild].Sibling;
    CodeTable^[CurrentChild].Sibling:=-1;
    ClearList^[CurrentChild shr 3]:=(ClearList^[CurrentChild shr 3] or (1 shl (CurrentChild and 7)));
    CurrentChild:=CodeTable^[Parent].Child;
   end;
   if CurrentChild>=0 then begin
    Prune(CurrentChild);
    NextSibling:=CodeTable^[CurrentChild].Sibling;
    while NextSibling>=0 do begin
     if CodeTable^[NextSibling].Child<0 then begin
      CodeTable^[CurrentChild].Sibling:=CodeTable^[NextSibling].Sibling;
      CodeTable^[NextSibling].Sibling:=-1;
      ClearList^[NextSibling shr 3]:=(ClearList^[NextSibling shr 3] or (1 shl (NextSibling and 7)));
      NextSibling:=CodeTable^[CurrentChild].Sibling;
     end else begin
      CurrentChild:=NextSibling;
      Prune(CurrentChild);
      NextSibling:=CodeTable^[CurrentChild].Sibling;
     end;
    end;
   end;
  end;

  procedure TableClear;
  var Node:TpvUInt16;
  begin
   FillChar(ClearList^,sizeof(TClearList),#0);
   for Node:=0 to 255 do begin
    Prune(Node);
   end;
   NextFree:=TABLESIZE+1;
   for Node:=TABLESIZE downto FIRSTENTRY do begin
    if (ClearList^[Node shr 3] and (1 shl (Node and 7)))<>0 then begin
     dec(NextFree);
     FreeList^[NextFree]:=Node;
    end;
   end;
   if NextFree<=TABLESIZE then begin
    TableFull:=false;
   end;
  end;

  procedure TableAdd(Prefix:TpvUInt16;Suffix:TpvUInt8);
  var FreeNode:TpvUInt16;
  begin
   if NextFree<=TABLESIZE then begin
    FreeNode:=FreeList^[NextFree];
    inc(NextFree);
    CodeTable^[FreeNode].Child:=-1;
    CodeTable^[FreeNode].Sibling:=-1;
    CodeTable^[FreeNode].Suffix:=Suffix;
    if CodeTable^[Prefix].Child=-1 then begin
     CodeTable^[Prefix].Child:=FreeNode;
    end else begin
     Prefix:=CodeTable^[Prefix].Child;
     while CodeTable^[Prefix].Sibling<>-1 do begin
      Prefix:=CodeTable^[Prefix].Sibling;
     end;
     CodeTable^[Prefix].Sibling:=FreeNode;
    end;
   end;
   if NextFree>TABLESIZE then begin
    TableFull:=true;
   end;
  end;

  function TableLookup(TargetPrefix:TpvInt32;TargetSuffix:TpvUInt8;var FoundAt:TpvInt32):boolean;
  var TempChild:TpvInt32;
  begin
   result:=false;
   FoundAt:=-1;
   if CodeTable^[TargetPrefix].Child=-1 then begin
    exit;
   end;
   TempChild:=CodeTable^[TargetPrefix].Child;
   while true do begin
    with CodeTable^[TempChild] do begin
     if Suffix=TargetSuffix then begin
      FoundAt:=TempChild;
      result:=true;
      break;
     end;
     if Sibling=-1 then begin
      break;
     end;
     TempChild:=Sibling;
    end;
   end;
  end;

  procedure PutByte(Value:TpvUInt8);
  begin
   OutStream.WriteBuffer(Value,sizeof(TpvUInt8));
  end;

  procedure PutCode(Code:smallint);
  var Mask:TpvUInt16;
      Agent,LocalSaveByte,LocalBitsUsed,LocalCodeSize:TpvUInt8;
  begin
   LocalSaveByte:=SaveByte;
   LocalBitsUsed:=BitsUsed;
   LocalCodeSize:=CodeSize;
   if Code=-1 then begin
    if LocalBitsUsed<>0 then begin
     PutByte(LocalSaveByte);
    end;
   end else begin
    Mask:=$0001;
    repeat
     Agent:=0;
     if (Code and Mask)<>0 then begin
      inc(Agent);
     end;
     Mask:=Mask shl 1;
     Agent:=Agent shl LocalBitsUsed;
     inc(LocalBitsUsed);
     LocalSaveByte:=LocalSaveByte or Agent;
     if LocalBitsUsed=8 then begin
      PutByte(LocalSaveByte);
      LocalSaveByte:=0;
      LocalBitsUsed:=0;
     end;
     dec(LocalCodeSize);
    until LocalCodeSize=0;
    SaveByte:=LocalSaveByte;
    BitsUsed:=LocalBitsUsed;
   end;
  end;

  procedure ProcessSuffix(Suffix:TpvInt32);
  var WhereFound:TpvInt32;
  begin
   if FirstByte then begin
    SaveByte:=0;
    BitsUsed:=0;
    CodeSize:=MINBITS;
    MaxCode:=(1 shl CodeSize)-1;
    LastCode:=Suffix;
    FirstByte:=false;
   end else begin
    if Suffix<>-1 then begin
     if TableFull then begin
      PutCode(LastCode);
      PutCode(SPECIAL);
      PutCode(CLEARCODE);
      TableClear;
      TableAdd(LastCode,Suffix);
      LastCode:=Suffix;
     end else begin
      if TableLookup(LastCode,Suffix,WhereFound) then begin
       LastCode:=WhereFound;
      end else begin
       PutCode(LastCode);
       TableAdd(LastCode,Suffix);
       LastCode:=Suffix;
       if (FreeList^[NextFree]>MaxCode) and (CodeSize<MaxBits) then begin
        PutCode(SPECIAL);
        PutCode(INCSIZE);
        inc(CodeSize);
        MaxCode:=(1 shl CodeSize)-1;
       end;
      end;
     end;
    end else begin
     PutCode(LastCode);
     PutCode(-1);
    end;
   end;
  end;

 var Counter:TpvInt32;
     b:TpvUInt8;
 begin
  result:=false;
  New(CodeTable);
  New(FreeList);
  New(ClearList);
  try
   for Counter:=0 to TABLESIZE do begin
    with CodeTable^[Counter] do begin
     Child:=-1;
     Sibling:=-1;
     if Counter<=255 then begin
      Suffix:=Counter;
     end;
    end;
    if Counter>=FIRSTENTRY then begin
     FreeList^[Counter]:=Counter;
    end;
   end;
   NextFree:=FIRSTENTRY;
   TableFull:=false;
   FirstByte:=true;
   LastCode:=0;
   InStream.Seek(0,soBeginning);
   for Counter:=1 to InStream.Size do begin
    InStream.ReadBuffer(b,SizeOf(TpvUInt8));
    ProcessSuffix(b);
   end;
   ProcessSuffix(-1);
   result:=true;
  finally
   Dispose(CodeTable);
   Dispose(FreeList);
   Dispose(ClearList);
  end;
 end;
var LocalFileHeader:TpvArchiveZIPLocalFileHeader;
    CentralFileHeader:TpvArchiveZIPCentralFileHeader;
    EndCentralFileHeader:TpvArchiveZIPEndCentralFileHeader;
    ZIP64EndCentralFileHeader:TpvArchiveZIP64EndCentralFileHeader;
    ZIPExtensibleDataFieldHeader:TpvArchiveZIPExtensibleDataFieldHeader;
    ZIP64ExtensibleInfoFieldHeader:TpvArchiveZIP64ExtensibleInfoFieldHeader;
    ZIP64EndCentralLocator:TpvArchiveZIP64EndCentralLocator;
    Counter:TpvSizeInt;
    CompressedStream:TStream;
    LocalFile:TpvArchiveZIPEntry;
    Entries:TpvSizeInt;
    StartDiskOffset:TpvInt64;
    CentralFileDirectorySize:TpvInt64;
    CRC32:TpvArchiveZIPCRC32;
    InData:TpvPointer;
    DestData:TpvPointer;
    DestLen:TpvSizeUInt;
    ZIPVersion:TpvUInt32;
begin

 if fEntries.Count=0 then begin
  exit;
 end;

 if aStream is TMemoryStream then begin
  (aStream as TMemoryStream).Clear;
 end else if (aStream is TFileStream) and ((aStream as TFileStream).Size>0) then begin
  (aStream as TFileStream).Size:=0;
 end;

 fZIP64:=fEntries.Count>=$ffff;

 ZIPVersion:=20;

 for Counter:=0 to fEntries.Count-1 do begin
  LocalFile:=fEntries[Counter];
  if assigned(LocalFile) then begin
   CompressedStream:=TMemoryStream.Create;
   try
    FillChar(LocalFileHeader,SizeOf(TpvArchiveZIPLocalFileHeader),#0);
    LocalFileHeader.Signature:=TpvArchiveZIPHeaderSignatures.LocalFileHeaderSignature;
    LocalFileHeader.BitFlags:=$0800; // UTF8
    if LocalFile.Stream.Size>0 then begin
     if LocalFile.CompressionLevel>1 then begin
      LocalFileHeader.BitFlags:=LocalFileHeader.BitFlags or $0002; // Fast (-ef) compression option was used.
      LocalFileHeader.CompressMethod:=8;
      if LocalFile.Stream.Size>0 then begin
       DestData:=nil;
       DestLen:=0;
       try
        GetMem(InData,LocalFile.Stream.Size);
        try
         LocalFile.Stream.Seek(0,soBeginning);
         LocalFile.Stream.ReadBuffer(InData^,LocalFile.Stream.Size);
         case LocalFile.CompressionLevel of
          2:begin
           DoDeflate(InData,LocalFile.Stream.Size,DestData,DestLen,TpvDeflateMode.VeryFast,false);
          end;
          3:begin
           DoDeflate(InData,LocalFile.Stream.Size,DestData,DestLen,TpvDeflateMode.Fast,false);
          end;
          4:begin
           DoDeflate(InData,LocalFile.Stream.Size,DestData,DestLen,TpvDeflateMode.Medium,false);
          end;
          else begin
           DoDeflate(InData,LocalFile.Stream.Size,DestData,DestLen,TpvDeflateMode.Slow,false);
          end;
         end;
        finally
         FreeMem(InData);
        end;
        if DestLen>0 then begin
         CompressedStream.WriteBuffer(DestData^,DestLen);
        end;
       finally
        if assigned(DestData) then begin
         FreeMem(DestData);
        end;
       end;
      end;
     end else if (LocalFile.CompressionLevel=1) and CompressShrink(LocalFile.Stream,CompressedStream) then begin
      LocalFileHeader.CompressMethod:=1;
     end else begin
      LocalFileHeader.CompressMethod:=0;
      LocalFile.Stream.Seek(0,soBeginning);
      CompressedStream.CopyFrom(LocalFile.Stream,LocalFile.Stream.Size);
     end;
     CompressedStream.Seek(0,soBeginning);
    end else begin
     LocalFileHeader.CompressMethod:=0;
    end;

    TpvArchiveZIPDateTimeUtils.ConvertDateTimeToZIPDateTime(LocalFile.DateTime,
                                                            LocalFileHeader.Date,
                                                            LocalFileHeader.Time);

    LocalFileHeader.FileNameLength:=length(LocalFile.FileName);
    LocalFileHeader.CompressedSize:=CompressedStream.Size;

    LocalFile.Stream.Seek(0,soBeginning);

    CRC32.Initialize;
    CRC32.Update(LocalFile.Stream);

    LocalFileHeader.CRC32:=CRC32.Finalize;
    LocalFileHeader.UncompressedSize:=LocalFile.Stream.Size;

    LocalFile.fRequiresZIP64:=(LocalFile.Stream.Size>=High(TpvUInt32)) or (CompressedStream.Size>=High(TpvUInt32));
    if LocalFile.fRequiresZIP64 then begin
     inc(LocalFileHeader.ExtraFieldLength,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader)+TpvArchiveZIP64ExtensibleInfoFieldHeader.DataSize);
     LocalFileHeader.CompressedSize:=TpvUInt32($ffffffff);
     LocalFileHeader.UncompressedSize:=TpvUInt32($ffffffff);
     ZIP64ExtensibleInfoFieldHeader.OriginalSize:=LocalFile.Stream.Size;
     ZIP64ExtensibleInfoFieldHeader.CompressedSize:=CompressedStream.Size;
     ZIP64ExtensibleInfoFieldHeader.DiskStartNumber:=0;
     ZIP64ExtensibleInfoFieldHeader.RelativeHeaderOffset:=0;
     LocalFile.fZIP64ExtensibleInfoFieldHeader:=ZIP64ExtensibleInfoFieldHeader;
     fZIP64:=true;
     LocalFileHeader.ExtractVersion:=45;
     ZIPVersion:=45;
    end else begin
     LocalFileHeader.ExtractVersion:=20;
    end;

    LocalFile.fHeaderPosition:=aStream.Position;
    LocalFile.fLocalFileHeader:=LocalFileHeader;

    LocalFileHeader.SwapEndiannessIfNeeded;
    aStream.WriteBuffer(LocalFileHeader,SizeOf(TpvArchiveZIPLocalFileHeader));
    LocalFileHeader.SwapEndiannessIfNeeded;

    if LocalFileHeader.FileNameLength>0 then begin
     aStream.WriteBuffer(LocalFile.FileName[1],LocalFileHeader.FileNameLength);
    end;

    if LocalFile.fRequiresZIP64 then begin
     ZIPExtensibleDataFieldHeader.HeaderID:=TpvArchiveZIP64ExtensibleInfoFieldHeader.HeaderID;
     ZIPExtensibleDataFieldHeader.DataSize:=TpvArchiveZIP64ExtensibleInfoFieldHeader.DataSize;
     aStream.WriteBuffer(ZIPExtensibleDataFieldHeader,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader));
     aStream.WriteBuffer(ZIP64ExtensibleInfoFieldHeader,SizeOf(TpvArchiveZIP64ExtensibleInfoFieldHeader));
    end;

    if LocalFileHeader.CompressedSize>0 then begin
     if aStream.CopyFrom(CompressedStream,LocalFileHeader.CompressedSize)<>TpvInt32(LocalFileHeader.CompressedSize) then begin
      raise EpvArchiveZIP.Create('Copy error');
     end;
    end;

   finally
    CompressedStream.Free;
   end;

  end;

 end;

 Entries:=0;
 StartDiskOffset:=aStream.Position;
 CentralFileDirectorySize:=0;
 for Counter:=0 to fEntries.Count-1 do begin

  LocalFile:=fEntries[Counter];

  if assigned(LocalFile) then begin

   FillChar(CentralFileHeader,SizeOf(TpvArchiveZIPCentralFileHeader),#0);

   CentralFileHeader.Signature:=TpvArchiveZIPHeaderSignatures.CentralFileHeaderSignature;
   CentralFileHeader.CreatorVersion:=LocalFile.fLocalFileHeader.ExtractVersion;
   CentralFileHeader.ExtractVersion:=LocalFile.fLocalFileHeader.ExtractVersion;
   CentralFileHeader.BitFlags:=LocalFile.fLocalFileHeader.BitFlags;
   CentralFileHeader.CompressMethod:=LocalFile.fLocalFileHeader.CompressMethod;
   CentralFileHeader.Time:=LocalFile.fLocalFileHeader.Time;
   CentralFileHeader.Date:=LocalFile.fLocalFileHeader.Date;
   CentralFileHeader.CRC32:=LocalFile.fLocalFileHeader.CRC32;
   CentralFileHeader.CompressedSize:=LocalFile.fLocalFileHeader.CompressedSize;
   CentralFileHeader.UncompressedSize:=LocalFile.fLocalFileHeader.UncompressedSize;
   CentralFileHeader.FileNameLength:=LocalFile.fLocalFileHeader.FileNameLength;
   CentralFileHeader.ExtraFieldLength:=0;//LocalFile.fLocalFileHeader.ExtraFieldLength;
   CentralFileHeader.ExternalAttrributes:=$20;
   CentralFileHeader.LocalFileHeaderOffset:=LocalFile.fHeaderPosition;
   CentralFileHeader.SwapEndiannessIfNeeded;

   LocalFile.fCentralHeaderPosition:=aStream.Position;

   if LocalFile.fRequiresZIP64 then begin
    inc(CentralFileHeader.ExtraFieldLength,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader)+TpvArchiveZIP64ExtensibleInfoFieldHeader.DataSize);
    CentralFileHeader.CompressedSize:=TpvUInt32($ffffffff);
    CentralFileHeader.UncompressedSize:=TpvUInt32($ffffffff);
    CentralFileHeader.LocalFileHeaderOffset:=TpvUInt32($ffffffff);
    ZIP64ExtensibleInfoFieldHeader:=LocalFile.fZIP64ExtensibleInfoFieldHeader;
    ZIP64ExtensibleInfoFieldHeader.RelativeHeaderOffset:=LocalFile.fHeaderPosition;
   end;

   aStream.WriteBuffer(CentralFileHeader,SizeOf(TpvArchiveZIPCentralFileHeader));

   if CentralFileHeader.FileNameLength>0 then begin
    aStream.WriteBuffer(LocalFile.FileName[1],CentralFileHeader.FileNameLength);
   end;

   if LocalFile.fRequiresZIP64 then begin
    ZIPExtensibleDataFieldHeader.HeaderID:=TpvArchiveZIP64ExtensibleInfoFieldHeader.HeaderID;
    ZIPExtensibleDataFieldHeader.DataSize:=TpvArchiveZIP64ExtensibleInfoFieldHeader.DataSize;
    aStream.WriteBuffer(ZIPExtensibleDataFieldHeader,SizeOf(TpvArchiveZIPExtensibleDataFieldHeader));
    aStream.WriteBuffer(ZIP64ExtensibleInfoFieldHeader,SizeOf(TpvArchiveZIP64ExtensibleInfoFieldHeader));
    fZIP64:=true;
   end;

   inc(Entries);

   inc(CentralFileDirectorySize,SizeOf(TpvArchiveZIPCentralFileHeader)+CentralFileHeader.FileNameLength);

  end;

 end;

 FillChar(EndCentralFileHeader,SizeOf(TpvArchiveZIPEndCentralFileHeader),#0);
 EndCentralFileHeader.Signature:=TpvArchiveZIPHeaderSignatures.EndCentralFileHeaderSignature;

 if fZIP64 then begin

  FillChar(ZIP64EndCentralLocator,SizeOf(TpvArchiveZIP64EndCentralLocator),#0);
  ZIP64EndCentralLocator.Signature:=TpvArchiveZIPHeaderSignatures.Zip64CentralLocatorHeaderSignature;
  ZIP64EndCentralLocator.EndOfCentralDirectoryStartDisk:=0;
  ZIP64EndCentralLocator.CentralDirectoryOffset:=aStream.Position;
  ZIP64EndCentralLocator.TotalDisks:=0;

  FillChar(ZIP64EndCentralFileHeader,SizeOf(TpvArchiveZIP64EndCentralFileHeader),#0);
  ZIP64EndCentralFileHeader.Signature:=TpvArchiveZIPHeaderSignatures.Zip64EndCentralFileHeaderSignature;
  ZIP64EndCentralFileHeader.RecordSize:=48; // 56-12; // SizeOf(TpvArchiveZIP64EndCentralFileHeader)-12;
  ZIP64EndCentralFileHeader.ExtractVersionRequired:=ZIPVersion;
  ZIP64EndCentralFileHeader.VersionMadeBy:=ZIPVersion;
  ZIP64EndCentralFileHeader.EntriesThisDisk:=Entries;
  ZIP64EndCentralFileHeader.TotalEntries:=Entries;
  ZIP64EndCentralFileHeader.StartDiskOffset:=StartDiskOffset;
  ZIP64EndCentralFileHeader.CentralDirectorySize:=CentralFileDirectorySize;
  aStream.WriteBuffer(ZIP64EndCentralFileHeader,SizeOf(TpvArchiveZIP64EndCentralFileHeader));

  aStream.WriteBuffer(ZIP64EndCentralLocator,SizeOf(TpvArchiveZIP64EndCentralLocator));

  EndCentralFileHeader.EntriesThisDisk:=TpvUInt16($ffff);
  EndCentralFileHeader.TotalEntries:=TpvUInt16($ffff);
  EndCentralFileHeader.StartDiskOffset:=TpvUInt32($ffffffff);
  EndCentralFileHeader.CentralDirectorySize:=TpvUInt32($ffffffff);

 end else begin

  EndCentralFileHeader.EntriesThisDisk:=Entries;
  EndCentralFileHeader.TotalEntries:=Entries;
  EndCentralFileHeader.StartDiskOffset:=StartDiskOffset;
  EndCentralFileHeader.CentralDirectorySize:=CentralFileDirectorySize;

 end;

 aStream.WriteBuffer(EndCentralFileHeader,SizeOf(TpvArchiveZIPEndCentralFileHeader));

end;

procedure TpvArchiveZIP.SaveToFile(const aFileName:string);
var Stream:TStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

end.
