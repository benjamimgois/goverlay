(******************************************************************************
 *                     PUCU Pascal UniCode Utils Libary                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2022, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pucu                                         *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 3.0 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that, but if needed, make *
 *    it out-ifdef-able.                                                      *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 *                                                                            *
 ******************************************************************************)
program PUCUConvertUnicode;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define caninline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$ifdef conditionalexpressions}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$ifdef windows}
 {$apptype console}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$assertions on}

uses SysUtils,Classes;

const MaxUnicodeChar=$10ffff;
      CountUnicodeChars=$110000;

type TPUCURawByteString={$ifdef HAS_TYPE_RAWBYTESTRING}RawByteString{$else}AnsiString{$endif};

     TPUCUUnicodeDWords=array[0..MaxUnicodeChar] of longint;

     TPUCUCodePoints=array of longint;

     PPUCUUnicodeCharacterDecompositionMappingItem=^TPUCUUnicodeCharacterDecompositionMappingItem;
     TPUCUUnicodeCharacterDecompositionMappingItem=record
      Type_:TPUCURawByteString;
      Mapping:TPUCUCodePoints;
     end;

     PPUCUUnicodeCharacterDecompositionMappingItems=^TPUCUUnicodeCharacterDecompositionMappingItems;
     TPUCUUnicodeCharacterDecompositionMappingItems=array[0..MaxUnicodeChar] of TPUCUUnicodeCharacterDecompositionMappingItem;

     PPUCUUnicodeCompositionExclusions=^TPUCUUnicodeCompositionExclusions;
     TPUCUUnicodeCompositionExclusions=array[0..((MaxUnicodeChar+31) shr 5)-1] of longword;

     PPUCUUnicodeCharacterDecompositionMapItem=^TPUCUUnicodeCharacterDecompositionMapItem;
     TPUCUUnicodeCharacterDecompositionMapItem=record
      CodePoint:longword;
      Decomposition:TPUCUCodePoints;
     end;

     TPUCUUnicodeCharacterDecompositionMap=array of TPUCUUnicodeCharacterDecompositionMapItem;

     PPUCUUnicodeCharacterCompositionMapItem=^TPUCUUnicodeCharacterCompositionMapItem;
     TPUCUUnicodeCharacterCompositionMapItem=record
      Composition:TPUCUCodePoints;
      CodePoint:longword;
      HashValue:longword;
      Next:longint;
     end;

     TPUCUUnicodeCharacterCompositionMap=array of TPUCUUnicodeCharacterCompositionMapItem;

     TPUCUUnicodeDecompositionSequences=array of longint;

var PUCUUnicodeCategories:TPUCUUnicodeDWords;
    PUCUUnicodeScripts:TPUCUUnicodeDWords;
    PUCUUnicodeCanonicalCombiningClasses:TPUCUUnicodeDWords;
    PUCUUnicodeLowerCaseDeltas:TPUCUUnicodeDWords;
    PUCUUnicodeUpperCaseDeltas:TPUCUUnicodeDWords;
    PUCUUnicodeTitleCaseDeltas:TPUCUUnicodeDWords;
    PUCUUnicodeCharacterDecompositionMappingItems:TPUCUUnicodeCharacterDecompositionMappingItems;
    PUCUUnicodeCompositionExclusions:TPUCUUnicodeCompositionExclusions;
    PUCUUnicodeCharacterDecompositionMap:TPUCUUnicodeCharacterDecompositionMap;
    PUCUUnicodeDecompositionSequences:TPUCUUnicodeDecompositionSequences;
    PUCUUnicodeDecompositionStarts:TPUCUUnicodeDWords;
    PUCUUnicodeCharacterCompositionMap:TPUCUUnicodeCharacterCompositionMap;
    PUCUCategories:TStringList;
    PUCUScripts:TStringList;
    OutputList:TStringList;

function GetUntilSplitter(const Splitter:TPUCURawByteString;var s:TPUCURawByteString):TPUCURawByteString;
var i:longint;
begin
 i:=pos(Splitter,s);
 if i>0 then begin
  result:=trim(copy(s,1,i-1));
  Delete(s,1,(i+length(Splitter))-1);
  s:=trim(s);
 end else begin
  result:=trim(s);
  s:='';
 end;
end;

procedure PackTable(const Table:array of longint;Level:integer;const Name:TPUCURawByteString);
type TBlock=array of longint;
     TBlocks=array of TBlock;
     TIndices=array of longint;
var BestBlockSize,BlockSize,CountBlocks,CountIndices,Index,BlockPosition,Bytes,BestBytes,Bits,BestBits,EntryBytes,IndicesEntryBytes,BestIndicesEntryBytes,i,j,k:longint;
    Block:TBlock;
    Blocks:TBlocks;
    Indices:TIndices;
    BestBlocks:TBlocks;
    BestIndices:TIndices;
    OK:boolean;
    s:TPUCURawByteString;
begin
 if Level<2 then begin
  Block:=nil;
  Blocks:=nil;
  Indices:=nil;
  BestBlocks:=nil;
  BestIndices:=nil;
  try
   BestBlockSize:=length(Table)*2;
   BestBits:=24;
   BlockSize:=1;
   Bits:=0;
   BestBytes:=-1;
   i:=0;
   OK:=true;
   for Index:=0 to length(Table)-1 do begin
    j:=Table[Index];
    if j<0 then begin
     OK:=false;
    end;
    j:=abs(j);
    if i<j then begin
     i:=j;
    end;
   end;
   if OK then begin
    if i<256 then begin
     EntryBytes:=1;
     s:='byte';
    end else if i<65536 then begin
     EntryBytes:=2;
     s:='word';
    end else begin
     EntryBytes:=4;
     s:='longword';
    end;
   end else begin
    if i<128 then begin
     EntryBytes:=1;
     s:='shortint';
    end else if i<32768 then begin
     EntryBytes:=2;
     s:='smallint';
    end else begin
     EntryBytes:=4;
     s:='longint';
    end;
   end;
   BestIndicesEntryBytes:=4;
   while BlockSize<length(Table) do begin
    SetLength(Block,BlockSize);
    SetLength(Blocks,(length(Table) div BlockSize)+1);
    FillChar(Block[0],BlockSize,#$ff);
    BlockPosition:=0;
    CountBlocks:=0;
    CountIndices:=0;
    for Index:=0 to length(Table)-1 do begin
     Block[BlockPosition]:=Table[Index];
     inc(BlockPosition);
     if BlockPosition=BlockSize then begin
      k:=-1;
      for i:=0 to CountBlocks-1 do begin
       OK:=true;
       for j:=0 to BlockSize-1 do begin
        if Blocks[i,j]<>Block[j] then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        k:=i;
        break;
       end;
      end;
      if k<0 then begin
       k:=CountBlocks;
       Blocks[CountBlocks]:=copy(Block);
       inc(CountBlocks);
      end;
      if (CountIndices+1)>=length(Indices) then begin
       i:=1;
       j:=CountIndices+1;
       while i<=j do begin
        inc(i,i);
       end;
       SetLength(Indices,i);
      end;
      Indices[CountIndices]:=k;
      inc(CountIndices);
      BlockPosition:=0;
     end;
    end;
    if CountBlocks<256 then begin
     IndicesEntryBytes:=1;
    end else if CountBlocks<65536 then begin
     IndicesEntryBytes:=2;
    end else begin
     IndicesEntryBytes:=4;
    end;
    Bytes:=((CountBlocks*BlockSize)*EntryBytes)+(CountIndices*IndicesEntryBytes);
    if (BestBytes<0) or (Bytes<=BestBytes) then begin
     BestBytes:=Bytes;
     BestBlockSize:=BlockSize;
     BestBits:=Bits;
     BestIndicesEntryBytes:=EntryBytes;
     BestBlocks:=copy(Blocks,0,CountBlocks);
     BestIndices:=copy(Indices,0,CountIndices);
    end;
    SetLength(Blocks,0);
    SetLength(Indices,0);
    inc(BlockSize,BlockSize);
    inc(Bits);
   end;
   OutputList.Add('// '+Name+': '+IntToStr(BestBytes)+' bytes, '+IntToStr(length(BestBlocks))+' blocks with '+IntToStr(BestBlockSize)+' items per '+IntToStr(EntryBytes)+' bytes and '+IntToStr(length(BestIndices))+' indices per '+IntToStr(BestIndicesEntryBytes)+' bytes');
   OutputList.Add('const '+Name+'BlockBits='+IntToStr(BestBits)+';');
   OutputList.Add('      '+Name+'BlockMask='+IntToStr((1 shl BestBits)-1)+';');
   OutputList.Add('      '+Name+'BlockSize='+IntToStr(BestBlockSize)+';');
   OutputList.Add('      '+Name+'BlockCount='+IntToStr(length(BestBlocks))+';');
   OutputList.Add('      '+Name+'BlockData:array[0..'+IntToStr(length(BestBlocks)-1)+',0..'+IntToStr(BestBlockSize-1)+'] of '+s+'=(');
   s:='';
   for i:=0 to length(BestBlocks)-1 do begin
    s:=s+'(';
    for j:=0 to BestBlockSize-1 do begin
     s:=s+IntToStr(BestBlocks[i,j]);
     if (j+1)<BestBlockSize then begin
      s:=s+',';
     end;
     if length(s)>80 then begin
      OutputList.Add(s);
      s:='';
     end;
    end;
    s:=s+')';
    if (i+1)<length(BestBlocks) then begin
     s:=s+',';
    end;
    OutputList.Add(s);
    s:='';
   end;
   if length(s)>0 then begin
    OutputList.Add(s);
    s:='';
   end;
   OutputList.Add(');');
   if Level=1 then begin
    case BestIndicesEntryBytes of
     1:begin
      s:='byte';
     end;
     2:begin
      s:='word';
     end;
     else begin
      s:='longword';
     end;
    end;
    OutputList.Add('      '+Name+'IndexCount='+IntToStr(length(BestBlocks))+';');
    OutputList.Add('      '+Name+'IndexData:array[0..'+IntToStr(length(BestIndices)-1)+'] of '+s+'=(');
    s:='';
    for i:=0 to length(BestIndices)-1 do begin
     s:=s+IntToStr(BestIndices[i]);
     if (i+1)<length(BestIndices) then begin
      s:=s+',';
     end;
     if length(s)>80 then begin
      OutputList.Add(s);
      s:='';
     end;
    end;
    if length(s)>0 then begin
     OutputList.Add(s);
     s:='';
    end;
    OutputList.Add(');');
    OutputList.Add('');
   end else begin
    OutputList.Add('');
    PackTable(BestIndices,Level+1,Name+'Index');
   end;
  finally
   SetLength(Block,0);
   SetLength(Blocks,0);
   SetLength(Indices,0);
   SetLength(BestBlocks,0);
   SetLength(BestIndices,0);
  end;
 end;
end;

procedure WriteTable(const Table:array of longint;Level:integer;const Name:TPUCURawByteString);
var Index,EntryBytes,i,j,k:longint;
    OK:boolean;
    s:TPUCURawByteString;
begin
 i:=0;
 OK:=true;
 for Index:=0 to length(Table)-1 do begin
  j:=Table[Index];
  if j<0 then begin
   OK:=false;
  end;
  j:=abs(j);
  if i<j then begin
   i:=j;
  end;
 end;
 if OK then begin
  if i<256 then begin
   EntryBytes:=1;
   s:='byte';
  end else if i<65536 then begin
   EntryBytes:=2;
   s:='word';
  end else begin
   EntryBytes:=4;
   s:='longword';
  end;
 end else begin
  if i<128 then begin
   EntryBytes:=1;
   s:='shortint';
  end else if i<32768 then begin
   EntryBytes:=2;
   s:='smallint';
  end else begin
   EntryBytes:=4;
   s:='longint';
  end;
 end;
 OutputList.Add('const '+Name+'Data:array[0..'+IntToStr(length(Table)-1)+'] of '+s+'=(');
 s:='';
 for j:=0 to length(Table)-1 do begin
  s:=s+IntToStr(Table[j]);
  if (j+1)<length(Table) then begin
   s:=s+',';
  end;
  if length(s)>80 then begin
   OutputList.Add(s);
   s:='';
  end;
 end;
 s:=s+');';
 OutputList.Add(s);
end;

procedure ParseBlocks;
type TPUCUUnicodeBlock=record
      Name:TPUCURawByteString;
      FromChar,ToChar:longword;
     end;
var List:TStringList;
    i,j,k,FromChar,ToChar,Count:longint;
    s,p:TPUCURawByteString;
    Blocks:array of TPUCUUnicodeBlock;
begin
 Blocks:=nil;
 try
  Count:=0;
  OutputList.Add('type TPUCUUnicodeBlock=record');
  OutputList.Add('      Name:TPUCURawByteString;');
  OutputList.Add('      FromChar,ToChar:longword;');
  OutputList.Add('     end;');
  List:=TStringList.Create;
  try
   List.LoadFromFile(IncludeTrailingPathDelimiter('UnicodeData')+'Blocks.txt');
   for i:=0 to List.Count-1 do begin
    s:=trim(List[i]);
    if (length(s)=0) or ((length(s)>0) and (s[1]='#')) then begin
     continue;
    end;
    j:=pos('#',s);
    if j>0 then begin
     s:=trim(copy(s,1,j-1));
    end;
    j:=pos(';',s);
    if j=0 then begin
     continue;
    end;
    p:=trim(copy(s,j+1,length(s)-j));
    s:=trim(copy(s,1,j-1));
    j:=pos('..',s);
    if j=0 then begin
     FromChar:=StrToInt('$'+trim(s));
     ToChar:=FromChar;
    end else begin
     FromChar:=StrToInt('$'+trim(copy(s,1,j-1)));
     ToChar:=StrToInt('$'+trim(copy(s,j+2,length(s)-(j+1))));
    end;
    if (Count+1)>=length(Blocks) then begin
     j:=1;
     k:=Count+1;
     while j<=k do begin
      inc(j,j);
     end;
     SetLength(Blocks,j);
    end;
    Blocks[Count].Name:=p;
    Blocks[Count].FromChar:=FromChar;
    Blocks[Count].ToChar:=ToChar;
    inc(Count);
   end;
   SetLength(Blocks,Count);
  finally
   List.Free;
  end;
  OutputList.Add('const PUCUUnicodeBlockCount='+IntToStr(Count)+';');
  OutputList.Add('      PUCUUnicodeBlocks:array[0..'+IntToStr(Count-1)+'] of TPUCUUnicodeBlock=(');
  for i:=0 to Count-1 do begin
   if (i+1)<Count then begin
    OutputList.Add('       (Name:'''+Blocks[i].Name+''';FromChar:'+inttostr(Blocks[i].FromChar)+';ToChar:'+inttostr(Blocks[i].ToChar)+'),');
   end else begin
    OutputList.Add('       (Name:'''+Blocks[i].Name+''';FromChar:'+inttostr(Blocks[i].FromChar)+';ToChar:'+inttostr(Blocks[i].ToChar)+'));');
   end;
  end;
  if Count=0 then begin
   OutputList.Add(');');
  end;
  OutputList.Add('');
 finally
  SetLength(Blocks,0);
 end;
end;

procedure ParseDerivedGeneralCategory;
var List:TStringList;
    i,j,ci,FromChar,ToChar,CurrentChar:longint;
    s,p:TPUCURawByteString;
begin
 List:=TStringList.Create;
 try
  List.LoadFromFile(IncludeTrailingPathDelimiter('UnicodeData')+'DerivedGeneralCategory.txt');
  for i:=0 to List.Count-1 do begin
   s:=trim(List[i]);
   if (length(s)=0) or ((length(s)>0) and (s[1]='#')) then begin
    continue;
   end;
   j:=pos('#',s);
   if j>0 then begin
    s:=trim(copy(s,1,j-1));
   end;
   j:=pos(';',s);
   if j=0 then begin
    continue;
   end;
   p:=trim(copy(s,j+1,length(s)-j));
   ci:=PUCUCategories.IndexOf(p);
   if ci<0 then begin
    ci:=PUCUCategories.Add(p);
   end;
   s:=trim(copy(s,1,j-1));
   j:=pos('..',s);
   if j=0 then begin
    CurrentChar:=StrToInt('$'+trim(s));
    PUCUUnicodeCategories[CurrentChar]:=ci;
   end else begin
    FromChar:=StrToInt('$'+trim(copy(s,1,j-1)));
    ToChar:=StrToInt('$'+trim(copy(s,j+2,length(s)-(j+1))));
    for CurrentChar:=FromChar to ToChar do begin
     PUCUUnicodeCategories[CurrentChar]:=ci;
    end;
   end;
  end;
 finally
  List.Free;
 end;
end;

procedure ParseScripts;
var List:TStringList;
    i,j,si,FromChar,ToChar,CurrentChar:longint;
    s,p:TPUCURawByteString;
begin
 List:=TStringList.Create;
 try
  List.LoadFromFile(IncludeTrailingPathDelimiter('UnicodeData')+'Scripts.txt');
  for i:=0 to List.Count-1 do begin
   s:=trim(List[i]);
   if (length(s)=0) or ((length(s)>0) and (s[1]='#')) then begin
    continue;
   end;
   j:=pos('#',s);
   if j>0 then begin
    s:=trim(copy(s,1,j-1));
   end;
   j:=pos(';',s);
   if j=0 then begin
    continue;
   end;
   p:=trim(copy(s,j+1,length(s)-j));
   si:=PUCUScripts.IndexOf(p);
   if si<0 then begin
    si:=PUCUScripts.Add(p);
   end;
   s:=trim(copy(s,1,j-1));
   j:=pos('..',s);
   if j=0 then begin
    CurrentChar:=StrToInt('$'+trim(s));
    PUCUUnicodeScripts[CurrentChar]:=si;
   end else begin
    FromChar:=StrToInt('$'+trim(copy(s,1,j-1)));
    ToChar:=StrToInt('$'+trim(copy(s,j+2,length(s)-(j+1))));
    for CurrentChar:=FromChar to ToChar do begin
     PUCUUnicodeScripts[CurrentChar]:=si;
    end;
   end;
  end;
 finally
  List.Free;
 end;
end;

procedure ParseUnicodeData;
var List:TStringList;
    i,j,k,ci,OtherChar,CurrentChar:longint;
    s,cs:TPUCURawByteString;
    cdmi:PPUCUUnicodeCharacterDecompositionMappingItem;
begin
 List:=TStringList.Create;
 try
  List.LoadFromFile(IncludeTrailingPathDelimiter('UnicodeData')+'UnicodeData.txt');
  for i:=ord('a') to ord('z') do begin
   PUCUUnicodeUpperCaseDeltas[i]:=longint(ord('A')-ord('a'));
  end;
  for i:=ord('A') to ord('Z') do begin
   PUCUUnicodeLowerCaseDeltas[i]:=ord('a')-ord('A');
  end;
  for i:=$ff21 to $ff3a do begin
   PUCUUnicodeLowerCaseDeltas[i]:=$ff41-$ff21;
  end;
  for i:=$ff41 to $ff5a do begin
   PUCUUnicodeUpperCaseDeltas[i]:=longint($ff21-$ff41);
  end;
  for i:=0 to List.Count-1 do begin
   s:=trim(List[i]);
   if (length(s)=0) or ((length(s)>0) and (s[1]='#')) then begin
    continue;
   end;
   j:=pos('#',s);
   if j>0 then begin
    s:=trim(copy(s,1,j-1));
   end;
   j:=pos(';',s);
   if j=0 then begin
    continue;
   end;
   CurrentChar:=StrToInt('$'+GetUntilSplitter(';',s)); // Code
   GetUntilSplitter(';',s); // Name
   begin
    cs:=GetUntilSplitter(';',s); // Class
    ci:=PUCUCategories.IndexOf(cs);
    if ci<0 then begin
     ci:=PUCUCategories.Add(cs);
    end;
    if PUCUUnicodeCategories[CurrentChar]<>ci then begin
     writeln(ErrOutput,CurrentChar,' has multiple categories?');
     PUCUUnicodeCategories[CurrentChar]:=ci;
    end;
   end;
   begin
    PUCUUnicodeCanonicalCombiningClasses[CurrentChar]:=StrToIntDef(GetUntilSplitter(';',s),0); // Canonical Combining Class
   end;
   GetUntilSplitter(';',s); // Bidirectional Category
   begin
    cs:=GetUntilSplitter(';',s); // Character Decomposition Mapping
    cdmi:=@PUCUUnicodeCharacterDecompositionMappingItems[CurrentChar];
    if length(cs)>0 then begin
     if pos('<',cs)>0 then begin
      GetUntilSplitter('<',cs);
      cdmi^.Type_:=GetUntilSplitter('>',cs);
     end else begin
      cdmi^.Type_:='canonical';
     end;
     cs:=trim(cs);
     cdmi^.Mapping:=nil;
     j:=0;
     try
      while length(cs)>0 do begin
       if length(cdmi^.Mapping)<(j+1) then begin
        SetLength(cdmi^.Mapping,(j+1)*2);
       end;
       cdmi^.Mapping[j]:=StrToIntDef('$'+GetUntilSplitter(' ',cs),0);
       inc(j);
      end;
     finally
      SetLength(cdmi^.Mapping,j);
     end;
    end else begin
     cdmi^.Type_:='none';
     cdmi^.Mapping:=nil;
    end;
   end;
   GetUntilSplitter(';',s); // Decimal digit value
   GetUntilSplitter(';',s); // Digit value
   GetUntilSplitter(';',s); // Numeric value
   GetUntilSplitter(';',s); // Mirrored
   GetUntilSplitter(';',s); // Unicode 1.0 Name
   GetUntilSplitter(';',s); // 10646 comment field
   begin
    OtherChar:=StrToIntDef('$'+GetUntilSplitter(';',s),-1); // UpperChar Code
    if (OtherChar>=0) and (OtherChar<>CurrentChar) then begin
     PUCUUnicodeUpperCaseDeltas[CurrentChar]:=OtherChar-CurrentChar;
    end;
   end;
   begin
    OtherChar:=StrToIntDef('$'+GetUntilSplitter(';',s),-1); // LowerChar Code
    if (OtherChar>=0) and (OtherChar<>CurrentChar) then begin
     PUCUUnicodeLowerCaseDeltas[CurrentChar]:=OtherChar-CurrentChar;
    end;
   end;
   begin
    OtherChar:=StrToIntDef('$'+GetUntilSplitter(';',s),-1); // TitleChar Code
    if (OtherChar>=0) and (OtherChar<>CurrentChar) then begin
     PUCUUnicodeTitleCaseDeltas[CurrentChar]:=OtherChar-CurrentChar;
    end;
   end;
  end;
 finally
  List.Free;
 end;
 List:=TStringList.Create;
 try
  List.LoadFromFile(IncludeTrailingPathDelimiter('UnicodeData')+'CompositionExclusions.txt');
  for i:=0 to List.Count-1 do begin
   s:=trim(List[i]);
   if (length(s)=0) or ((length(s)>0) and (s[1]='#')) then begin
    continue;
   end;
   j:=pos('#',s);
   if j>0 then begin
    s:=trim(copy(s,1,j-1));
   end;
   s:=trim(s);
   j:=pos(' ',s);
   if j>0 then begin
    s:=trim(copy(s,1,j-1));
   end;
   CurrentChar:=StrToInt('$'+GetUntilSplitter(' ',s)); // Code
   PUCUUnicodeCompositionExclusions[CurrentChar shr 5]:=PUCUUnicodeCompositionExclusions[CurrentChar shr 5] or (longword(1) shl (CurrentChar and 31));
  end;
 finally
  List.Free;
 end;
end;

function RecursiveDecomposition(const aCodePoint:longword):TPUCUCodePoints;
var Index,Len,NewLen:longint;
    CodePoints:TPUCUCodePoints;
begin
 result:=nil;
 if (aCodePoint<CountUnicodeChars) and
    (PUCUUnicodeCharacterDecompositionMappingItems[aCodePoint].Type_='canonical') then begin
  Len:=0;
  try
   for Index:=0 to length(PUCUUnicodeCharacterDecompositionMappingItems[aCodePoint].Mapping)-1 do begin
    CodePoints:=nil;
    try
     CodePoints:=RecursiveDecomposition(PUCUUnicodeCharacterDecompositionMappingItems[aCodePoint].Mapping[Index]);
     if length(CodePoints)>0 then begin
      NewLen:=Len+length(CodePoints);
      if length(result)<NewLen then begin
       SetLength(result,NewLen shl 1);
      end;
      Move(CodePoints[0],result[Len],length(CodePoints)*SizeOf(longword));
      Len:=NewLen;
     end;
    finally
     CodePoints:=nil;
    end;
   end;
  finally
   SetLength(result,Len);
  end;
 end else begin
  SetLength(result,1);
  result[0]:=aCodePoint;
 end;
end;

procedure ResolveRecursiveDecompositions;
var CodePoint:longword;
    Count,Index,SequenceLen,StartLen,FoundIndex,SubIndex,SubSubIndex,NewLen:longint;
    PUCUUnicodeCharacterDecompositionMapItem:TPUCUUnicodeCharacterDecompositionMapItem;
    Decomposition:TPUCUCodePoints;
begin
 Count:=0;
 for CodePoint:=0 to MaxUnicodeChar do begin
  if PUCUUnicodeCharacterDecompositionMappingItems[CodePoint].Type_='canonical' then begin
   if length(PUCUUnicodeCharacterDecompositionMap)<(Count+1) then begin
    SetLength(PUCUUnicodeCharacterDecompositionMap,(Count+1)*2);
   end;
   PUCUUnicodeCharacterDecompositionMap[Count].CodePoint:=CodePoint;
   PUCUUnicodeCharacterDecompositionMap[Count].Decomposition:=RecursiveDecomposition(CodePoint);
   inc(Count);
  end;
 end;
 Index:=0;
 while (Index+1)<Count do begin
  if PUCUUnicodeCanonicalCombiningClasses[PUCUUnicodeCharacterDecompositionMap[Index].CodePoint]>PUCUUnicodeCanonicalCombiningClasses[PUCUUnicodeCharacterDecompositionMap[Index+1].CodePoint] then begin
   PUCUUnicodeCharacterDecompositionMapItem:=PUCUUnicodeCharacterDecompositionMap[Index];
   PUCUUnicodeCharacterDecompositionMap[Index]:=PUCUUnicodeCharacterDecompositionMap[Index+1];
   PUCUUnicodeCharacterDecompositionMap[Index+1]:=PUCUUnicodeCharacterDecompositionMapItem;
   if Index>0 then begin
    dec(Index);
   end else begin
    inc(Index);
   end;
  end else begin
   inc(Index);
  end;
 end;
 PUCUUnicodeDecompositionSequences:=nil;
 SequenceLen:=1;
 try
  SetLength(PUCUUnicodeDecompositionSequences,1);
  PUCUUnicodeDecompositionSequences[0]:=0;
  StartLen:=0;
  for Index:=0 to Count-1 do begin
   Decomposition:=PUCUUnicodeCharacterDecompositionMap[Index].Decomposition;
   FoundIndex:=-1;
   for SubIndex:=0 to SequenceLen-length(Decomposition) do begin
    Count:=0;
    for SubSubIndex:=0 to length(Decomposition)-1 do begin
     if Decomposition[SubSubIndex]<>PUCUUnicodeDecompositionSequences[SubIndex+SubSubIndex] then begin
      break;
     end;
     inc(Count);
    end;
    if Count=length(Decomposition) then begin
     FoundIndex:=SubIndex;
     break;
    end;
   end;
   if FoundIndex<0 then begin
    FoundIndex:=SequenceLen;
    NewLen:=SequenceLen+length(Decomposition);
    if length(PUCUUnicodeDecompositionSequences)<NewLen then begin
     SetLength(PUCUUnicodeDecompositionSequences,NewLen*2);
    end;
    Move(Decomposition[0],PUCUUnicodeDecompositionSequences[SequenceLen],length(Decomposition)*SizeOf(longword));
    SequenceLen:=NewLen;
   end;
   PUCUUnicodeDecompositionStarts[PUCUUnicodeCharacterDecompositionMap[Index].CodePoint]:=FoundIndex or ((length(Decomposition)-1) shl 14);
  end;
 finally
  SetLength(PUCUUnicodeDecompositionSequences,SequenceLen);
 end;
end;

procedure ResolveCompositions;
const HashTableBits=10;
      HashTableSize=1 shl HashTableBits;
      HashTableMask=HashTableSize-1;
{function Hash(const s:TPUCUCodePoints):longword;
 begin
  result:=(s[0]*92821) xor (s[1]*486187739);
 end;}
 function Hash(const s:TPUCUCodePoints):longword;
//var Key:uint64;
 begin
  result:=(s[0]*98303927) xor (s[1]*24710753);
//result:=(s[0]*12582917) xor (s[1]*25165843);
{ Key:=(uint64(s[0]) shl 32) or s[1];
  Key:=(not Key)+(Key shl 18);
  Key:=(Key xor (Key shr 31))*21;
  Key:=Key xor (Key shr 11);
  Key:=Key+(Key shl 6);
  result:=longword(Key xor (Key shr 22));}
 end;
var CodePoint:longword;
    Count,Index,SequenceLen,StartLen,FoundIndex,SubIndex,SubSubIndex,NewLen,HashIndex:longint;
    PUCUUnicodeCharacterCompositionMapItem:TPUCUUnicodeCharacterCompositionMapItem;
    HashTable,HashTableLength:array of longint;
begin
 Count:=0;
 try
  for Index:=0 to length(PUCUUnicodeCharacterDecompositionMap)-1 do begin
   CodePoint:=PUCUUnicodeCharacterDecompositionMap[Index].CodePoint;
   if ((PUCUUnicodeCompositionExclusions[CodePoint shr 5] and (longword(1) shl (CodePoint and 31)))=0) and
      (length(PUCUUnicodeCharacterDecompositionMap[Index].Decomposition)=2) and
      (PUCUUnicodeCharacterDecompositionMappingItems[CodePoint].Type_='canonical') and
      (PUCUUnicodeCanonicalCombiningClasses[CodePoint]=0) and
      (PUCUUnicodeCanonicalCombiningClasses[PUCUUnicodeCharacterDecompositionMappingItems[CodePoint].Mapping[0]]=0) then begin
    if length(PUCUUnicodeCharacterCompositionMap)<(Count+1) then begin
     SetLength(PUCUUnicodeCharacterCompositionMap,(Count+1)*2);
    end;
    PUCUUnicodeCharacterCompositionMap[Count].Composition:=PUCUUnicodeCharacterDecompositionMap[Index].Decomposition;
    PUCUUnicodeCharacterCompositionMap[Count].CodePoint:=CodePoint;
    PUCUUnicodeCharacterCompositionMap[Count].HashValue:=Hash(PUCUUnicodeCharacterDecompositionMap[Index].Decomposition);
    PUCUUnicodeCharacterCompositionMap[Count].Next:=-1;
    inc(Count);
   end;
  end;
 finally
  SetLength(PUCUUnicodeCharacterCompositionMap,Count);
 end;
 Index:=0;
 while (Index+1)<Count do begin
  if (PUCUUnicodeCharacterCompositionMap[Index].Composition[0]>PUCUUnicodeCharacterCompositionMap[Index+1].Composition[0]) or
     ((PUCUUnicodeCharacterCompositionMap[Index].Composition[0]=PUCUUnicodeCharacterCompositionMap[Index+1].Composition[0]) and
      (PUCUUnicodeCharacterCompositionMap[Index].Composition[1]>PUCUUnicodeCharacterCompositionMap[Index+1].Composition[1]))  then begin
   PUCUUnicodeCharacterCompositionMapItem:=PUCUUnicodeCharacterCompositionMap[Index];
   PUCUUnicodeCharacterCompositionMap[Index]:=PUCUUnicodeCharacterCompositionMap[Index+1];
   PUCUUnicodeCharacterCompositionMap[Index+1]:=PUCUUnicodeCharacterCompositionMapItem;
   if Index>0 then begin
    dec(Index);
   end else begin
    inc(Index);
   end;
  end else begin
   inc(Index);
  end;
 end;
 HashTable:=nil;
 HashTableLength:=nil;
 try
  SetLength(HashTable,HashTableSize);
  SetLength(HashTableLength,HashTableSize);
  for Index:=0 to HashTableSize-1 do begin
   HashTable[Index]:=-1;
   HashTableLength[Index]:=0;
  end;
  for Index:=0 to length(PUCUUnicodeCharacterCompositionMap)-1 do begin
   HashIndex:=PUCUUnicodeCharacterCompositionMap[Index].HashValue and HashTableMask;
   PUCUUnicodeCharacterCompositionMap[Index].Next:=HashTable[HashIndex];
   HashTable[HashIndex]:=Index;
   inc(HashTableLength[HashIndex]);
  end;
  for Index:=0 to HashTableSize-1 do begin
   inc(HashTable[Index]);
  end;
  OutputList.Add('const PUCUUnicodeCharacterCompositionHashTableBits='+IntToStr(HashTableBits)+';');
  OutputList.Add('      PUCUUnicodeCharacterCompositionHashTableSize='+IntToStr(HashTableSize)+';');
  OutputList.Add('      PUCUUnicodeCharacterCompositionHashTableMask='+IntToStr(HashTableMask)+';');
  WriteTable(HashTable,0,'PUCUUnicodeCharacterCompositionHashTable');
//WriteTable(HashTableLength,0,'PUCUUnicodeCharacterCompositionHashTableLength'); // for debugging usages
  OutputList.Add('type PPUCUUnicodeCharacterCompositionSequence=^TPUCUUnicodeCharacterCompositionSequence;');
  OutputList.Add('     TPUCUUnicodeCharacterCompositionSequence=record');
  OutputList.Add('      Sequence:array[0..1] of longword;');
  OutputList.Add('      CodePoint:longword;');
  case length(PUCUUnicodeCharacterCompositionMap)+1 of
   0..255:begin
    OutputList.Add('      Next:byte;');
   end;
   256..65535:begin
    OutputList.Add('      Next:word;');
   end;
   else begin
    OutputList.Add('      Next:longword;');
   end;
  end;
  OutputList.Add('     end;');
  OutputList.Add('const PUCUUnicodeCharacterCompositionSequenceCount='+IntToStr(length(PUCUUnicodeCharacterCompositionMap)+1)+';');
  OutputList.Add('      PUCUUnicodeCharacterCompositionSequences:array[0..'+IntToStr(length(PUCUUnicodeCharacterCompositionMap))+'] of TPUCUUnicodeCharacterCompositionSequence=(');
  if length(PUCUUnicodeCharacterCompositionMap)>0 then begin
   OutputList.Add('       (Sequence:(0,0);CodePoint:0;Next:0),');
   for Index:=0 to length(PUCUUnicodeCharacterCompositionMap)-1 do begin
    if (Index+1)<length(PUCUUnicodeCharacterCompositionMap) then begin
     OutputList.Add('       (Sequence:('+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Composition[0])+','+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Composition[1])+');CodePoint:'+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].CodePoint)+';Next:'+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Next+1)+'),');
    end else begin
     OutputList.Add('       (Sequence:('+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Composition[0])+','+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Composition[1])+');CodePoint:'+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].CodePoint)+';Next:'+IntToStr(PUCUUnicodeCharacterCompositionMap[Index].Next+1)+')');
    end;
   end;
  end else begin
   OutputList.Add('       (Sequence:(0,0);CodePoint:0)');
  end;
  OutputList.Add('      );');
 finally
  HashTable:=nil;
 end;
end;

var i:longint;
begin
 FillChar(PUCUUnicodeCategories,sizeof(TPUCUUnicodeDWords),#0);
 FillChar(PUCUUnicodeScripts,sizeof(TPUCUUnicodeDWords),#$0);
 FillChar(PUCUUnicodeCanonicalCombiningClasses,sizeof(TPUCUUnicodeDWords),#$0);
 FillChar(PUCUUnicodeUpperCaseDeltas,sizeof(TPUCUUnicodeDWords),#$0);
 FillChar(PUCUUnicodeLowerCaseDeltas,sizeof(TPUCUUnicodeDWords),#$0);
 FillChar(PUCUUnicodeTitleCaseDeltas,sizeof(TPUCUUnicodeDWords),#$0);
 FillChar(PUCUUnicodeCompositionExclusions,sizeof(TPUCUUnicodeCompositionExclusions),#$0);
 FillChar(PUCUUnicodeCharacterDecompositionMappingItems,sizeof(TPUCUUnicodeCharacterDecompositionMappingItems),#$0);
 FillChar(PUCUUnicodeDecompositionStarts,sizeof(TPUCUUnicodeDWords),#$0);
 PUCUUnicodeCharacterDecompositionMap:=nil;
 PUCUUnicodeCharacterCompositionMap:=nil;
 PUCUUnicodeDecompositionSequences:=nil;
 try
  OutputList:=TStringList.Create;
  try
   PUCUCategories:=TStringList.Create;
   PUCUCategories.Add('Cn');
   try
    PUCUScripts:=TStringList.Create;
    PUCUScripts.Add('Unknown');
    PUCUScripts.Add('Common');
    try
     ParseDerivedGeneralCategory;
     ParseScripts;
     ParseUnicodeData;
     OutputList.Add('unit PUCUUnicodePass1;');
     OutputList.Add('{$ifdef fpc}');
     OutputList.Add(' {$mode delphi}');
     OutputList.Add('{$endif}');
     OutputList.Add('interface');
     OutputList.Add('');
     OutputList.Add('type TPUCURawByteString={$ifdef HAS_TYPE_RAWBYTESTRING}RawByteString{$else}AnsiString{$endif};');
     OutputList.Add('type TPUCURawByteChar=AnsiChar;');
     OutputList.Add('');
     ParseBlocks;
     begin
      OutputList.Add('const PUCUUnicodeCategoryIDs:array[0..'+IntToStr(PUCUCategories.Count-1)+'] of TPUCURawByteString=(');
      for i:=0 to PUCUCategories.Count-1 do begin
       if (i+1)<PUCUCategories.Count then begin
        OutputList.Add(''''+PUCUCategories[i]+''',');
       end else begin
        OutputList.Add(''''+PUCUCategories[i]+'''');
       end;
      end;
      OutputList.Add(');');
      for i:=0 to PUCUCategories.Count-1 do begin
       OutputList.Add('      PUCUUnicodeCategory'+PUCUCategories[i]+'='+IntToStr(i)+';');
      end;
      OutputList.Add('      PUCUUnicodeCategoryCount='+IntToStr(PUCUCategories.Count)+';');
      OutputList.Add('      PUCU_CT_UNASSIGNED=PUCUUnicodeCategoryCn;');
      OutputList.Add('      PUCU_CT_UPPERCASE_LETTER=PUCUUnicodeCategoryLu;');
      OutputList.Add('      PUCU_CT_LOWERCASE_LETTER=PUCUUnicodeCategoryLl;');
      OutputList.Add('      PUCU_CT_TITLECASE_LETTER=PUCUUnicodeCategoryLt;');
      OutputList.Add('      PUCU_CT_MODIFIER_LETTER=PUCUUnicodeCategoryLm;');
      OutputList.Add('      PUCU_CT_OTHER_LETTER=PUCUUnicodeCategoryLo;');
      OutputList.Add('      PUCU_CT_NON_SPACING_MARK=PUCUUnicodeCategoryMn;');
      OutputList.Add('      PUCU_CT_ENCLOSING_MARK=PUCUUnicodeCategoryMe;');
      OutputList.Add('      PUCU_CT_COMBINING_SPACING_MARK=PUCUUnicodeCategoryMc;');
      OutputList.Add('      PUCU_CT_DECIMAL_DIGIT_NUMBER=PUCUUnicodeCategoryNd;');
      OutputList.Add('      PUCU_CT_LETTER_NUMBER=PUCUUnicodeCategoryNl;');
      OutputList.Add('      PUCU_CT_OTHER_NUMBER=PUCUUnicodeCategoryNo;');
      OutputList.Add('      PUCU_CT_SPACE_SEPARATOR=PUCUUnicodeCategoryZs;');
      OutputList.Add('      PUCU_CT_LINE_SEPARATOR=PUCUUnicodeCategoryZl;');
      OutputList.Add('      PUCU_CT_PARAGRAPH_SEPARATOR=PUCUUnicodeCategoryZp;');
      OutputList.Add('      PUCU_CT_CONTROL=PUCUUnicodeCategoryCc;');
      OutputList.Add('      PUCU_CT_FORMAT=PUCUUnicodeCategoryCf;');
      OutputList.Add('      PUCU_CT_PRIVATE_USE=PUCUUnicodeCategoryCo;');
      OutputList.Add('      PUCU_CT_SURROGATE=PUCUUnicodeCategoryCs;');
      OutputList.Add('      PUCU_CT_DASH_PUNCTUATION=PUCUUnicodeCategoryPd;');
      OutputList.Add('      PUCU_CT_START_PUNCTUATION=PUCUUnicodeCategoryPs;');
      OutputList.Add('      PUCU_CT_END_PUNCTUATION=PUCUUnicodeCategoryPe;');
      OutputList.Add('      PUCU_CT_INITIAL_PUNCTUATION=PUCUUnicodeCategoryPi;');
      OutputList.Add('      PUCU_CT_FINAL_PUNCTUATION=PUCUUnicodeCategoryPf;');
      OutputList.Add('      PUCU_CT_CONNECTOR_PUNCTUATION=PUCUUnicodeCategoryPc;');
      OutputList.Add('      PUCU_CT_OTHER_PUNCTUATION=PUCUUnicodeCategoryPo;');
      OutputList.Add('      PUCU_CT_MATH_SYMBOL=PUCUUnicodeCategorySm;');
      OutputList.Add('      PUCU_CT_CURRENCY_SYMBOL=PUCUUnicodeCategorySc;');
      OutputList.Add('      PUCU_CT_MODIFIER_SYMBOL=PUCUUnicodeCategorySk;');
      OutputList.Add('      PUCU_CT_OTHER_SYMBOL=PUCUUnicodeCategorySo;');
      OutputList.Add('');
     end;
     begin
      OutputList.Add('const PUCUUnicodeScriptIDs:array[0..'+IntToStr(PUCUScripts.Count-1)+'] of TPUCURawByteString=(');
      for i:=0 to PUCUScripts.Count-1 do begin
       if (i+1)<PUCUScripts.Count then begin
        OutputList.Add(''''+PUCUScripts[i]+''',');
       end else begin
        OutputList.Add(''''+PUCUScripts[i]+'''');
       end;
      end;
      OutputList.Add(');');
      for i:=0 to PUCUScripts.Count-1 do begin
       OutputList.Add('     PUCUUnicodeScript'+PUCUScripts[i]+'='+IntToStr(i)+';');
      end;
      OutputList.Add('     PUCUUnicodeScriptCount='+IntToStr(PUCUScripts.Count)+';');
      OutputList.Add('');
     end;
     ResolveRecursiveDecompositions;
     ResolveCompositions;
     PackTable(PUCUUnicodeCategories,0,'PUCUUnicodeCategoryArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeScripts,0,'PUCUUnicodeScriptArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeCanonicalCombiningClasses,0,'PUCUUnicodeCanonicalCombiningClassArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeDecompositionStarts,0,'PUCUUnicodeDecompositionStartArray');
     OutputList.Add('');
     WriteTable(PUCUUnicodeDecompositionSequences,0,'PUCUUnicodeDecompositionSequenceArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeUpperCaseDeltas,0,'PUCUUnicodeUpperCaseDeltaArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeLowerCaseDeltas,0,'PUCUUnicodeLowerCaseDeltaArray');
     OutputList.Add('');
     PackTable(PUCUUnicodeTitleCaseDeltas,0,'PUCUUnicodeTitleCaseDeltaArray');
     OutputList.Add('');
     OutputList.Add('implementation');
     OutputList.Add('end.');
     OutputList.SaveToFile('PUCUUnicodePass1.pas');
    finally
     PUCUScripts.Free;
    end;
   finally
    PUCUCategories.Free;
   end;
  finally
   OutputList.Free;
  end;
 finally
  PUCUUnicodeCharacterDecompositionMap:=nil;
  PUCUUnicodeCharacterCompositionMap:=nil;
  PUCUUnicodeDecompositionSequences:=nil;
 end;
end.
